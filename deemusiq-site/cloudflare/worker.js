/**
 * DeeMusiq download proxy + hardening worker.
 *
 * Deployed on the zone (routes: `deemusiq.co.za/downloads/*` for binaries,
 * `deemusiq.co.za/fdroid/*` for the self-hosted F-Droid repo, or as a Pages
 * function). Clients only ever see THIS domain — the GitHub release URLs live
 * solely in worker env vars, never in shipped HTML/JS, never in redirects
 * (the asset is streamed through, not 302'd) and never in response headers
 * (upstream headers are rebuilt from an explicit allowlist before returning).
 *
 * Env vars (wrangler.toml [vars] or `wrangler secret put`):
 *   GITHUB_REPO   e.g. "deemusiq/deemusiq"
 *   DOWNLOADS     JSON map platform→filename,
 *                 e.g. {"android":"DeeMusiq.apk","windows":"DeeMusiq-setup.exe"}
 *   VERSIONS      JSON map platform→latest version string,
 *                 e.g. {"android":"1.4.0","windows":"1.4.0",...}
 *                 Served at /downloads/version.json so the app's update check
 *                 never touches GitHub directly.
 *   KNOWN_GOOD_SHA256   (optional) JSON map platform→expected lowercase hex
 *                 sha256 of the release binary. Platforms in the map are
 *                 fully buffered and hash-verified before any byte is sent
 *                 (mismatch → generic 502, nothing of the body); platforms
 *                 absent from the map stream through as before.
 *   RELEASE_ED25519_SECRET_KEY   (optional) hex-encoded 32-byte Ed25519
 *                 seed (RFC 8032). When set, the .sha256 sidecar and
 *                 version.json responses carry an `X-Body-Signature` header:
 *                 hex Ed25519 signature over the exact raw response-body
 *                 bytes, which the app verifies on update checks.
 */

const SECURITY_HEADERS = {
  "Strict-Transport-Security": "max-age=31536000; includeSubDomains; preload",
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
  "Referrer-Policy": "strict-origin-when-cross-origin",
  "Permissions-Policy": "camera=(), microphone=(), geolocation=()",
};

// Only these upstream headers may cross to the client. Anything else the
// origin sends (x-github-*, x-served-by, server, location, …) is dropped, so
// the response carries no fingerprint of where the file is actually hosted.
const PASS_THROUGH_HEADERS = [
  "content-type",
  "content-length",
  "content-range",
  "etag",
  "last-modified",
];

// Cache release binaries at the edge for an hour, but never let a failed
// release (missing asset, upstream outage) sit in the cache for that hour.
const CACHE_TTL_BY_STATUS = { "200-299": 3600, "404": 60, "500-599": 30 };
const HASH_CACHE_TTL_BY_STATUS = { "200-299": 300, "404": 60, "500-599": 30 };

const FDROID_CONTENT_TYPES = {
  ".apk": "application/vnd.android.package-archive",
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".jar": "application/java-archive",
  ".json": "application/json",
  ".png": "image/png",
  ".xml": "application/xml",
};

// /fdroid/repo/<file> — the self-hosted F-Droid repository. The small repo
// files (index, entry point, icons) are flattened (`/` → `--`, `fdroid--`
// prefix) onto the `fdroid` release tag, which is machine-managed storage,
// not an app release; APKs stream from the latest app release so they stay
// byte-identical to /downloads/android — the repo index pins their hashes.
// Index files get the short TTL: they are re-published on every app release.
async function serveFdroidFile(file, request, env) {
  if (!env.GITHUB_REPO) {
    return new Response(JSON.stringify({ error: "unavailable" }), {
      status: 404,
      headers: withSecurityHeaders({ "Content-Type": "application/json" }),
    });
  }
  const isApk = file.endsWith(".apk");
  // GitHub strips "=" from asset names on upload (fdroidserver's hashed icon
  // names carry base64 padding), so the flattened asset name drops them too.
  const flattened = `fdroid--${file.replace(/\//g, "--").replace(/=/g, "")}`;
  const upstream = isApk
    ? `https://github.com/${env.GITHUB_REPO}/releases/latest/download/${encodeURIComponent(file)}`
    : `https://github.com/${env.GITHUB_REPO}/releases/download/fdroid/${encodeURIComponent(flattened)}`;

  const upstreamHeaders = new Headers();
  const range = request.headers.get("range");
  if (range && isApk) upstreamHeaders.set("range", range);

  let upstreamRes;
  try {
    upstreamRes = await fetch(upstream, {
      redirect: "follow",
      headers: upstreamHeaders,
      cf: {
        cacheEverything: true,
        cacheTtlByStatus: isApk ? CACHE_TTL_BY_STATUS : HASH_CACHE_TTL_BY_STATUS,
      },
    });
  } catch {
    // Same contract as the downloads path: upstream DNS/timeout → JSON, not
    // an unhandled worker exception (which would drop the security headers).
    upstreamRes = null;
  }
  if (!upstreamRes || !upstreamRes.ok || !upstreamRes.body) {
    if (upstreamRes && upstreamRes.status === 416) {
      const h = withSecurityHeaders({ "Content-Type": "text/plain" });
      const cr = upstreamRes.headers.get("content-range");
      if (cr) h.set("Content-Range", cr);
      return new Response("Range not satisfiable", { status: 416, headers: h });
    }
    return new Response(JSON.stringify({ error: "unavailable" }), {
      status: 404,
      headers: withSecurityHeaders({ "Content-Type": "application/json" }),
    });
  }

  const headers = withSecurityHeaders({});
  for (const name of PASS_THROUGH_HEADERS) {
    const value = upstreamRes.headers.get(name);
    if (value !== null) headers.set(name, value);
  }
  headers.set("Accept-Ranges", "bytes");
  headers.set("Cache-Control", isApk ? "public, max-age=3600" : "public, max-age=300");
  const ext = file.slice(file.lastIndexOf("."));
  headers.set("Content-Type", FDROID_CONTENT_TYPES[ext] || "application/octet-stream");
  return new Response(upstreamRes.body, { status: upstreamRes.status, headers });
}

function withSecurityHeaders(headers) {
  const out = new Headers(headers);
  for (const [k, v] of Object.entries(SECURITY_HEADERS)) out.set(k, v);
  return out;
}

function parseDownloads(env) {
  let map = {};
  try {
    map = JSON.parse(env.DOWNLOADS || "{}");
  } catch {
    map = {};
  }
  // Normalise keys to lowercase alphanumerics so /downloads/Android works.
  const norm = {};
  for (const [k, v] of Object.entries(map)) {
    norm[String(k).toLowerCase()] = v;
  }
  return norm;
}

// Fetch the published "<asset>.sha256" sidecar and return the digest, or null.
// Sidecar format is the usual `sha256sum` output: "<hex>  <filename>".
async function fetchExpectedSha256(url) {
  try {
    const res = await fetch(url, {
      redirect: "follow",
      cf: { cacheEverything: true, cacheTtlByStatus: HASH_CACHE_TTL_BY_STATUS },
    });
    if (!res.ok) return null;
    const text = await res.text();
    const m = text.match(/\b([0-9a-fA-F]{64})\b/);
    return m ? m[1].toLowerCase() : null;
  } catch {
    return null;
  }
}

function hexToBytes(hex) {
  const out = new Uint8Array(hex.length / 2);
  for (let i = 0; i < out.length; i++) out[i] = parseInt(hex.slice(i * 2, i * 2 + 2), 16);
  return out;
}

function bytesToHex(buf) {
  return Array.from(new Uint8Array(buf), (b) => b.toString(16).padStart(2, "0")).join("");
}

// Fixed-length, non-short-circuiting hex compare — both inputs are validated
// sha256 hex digests (64 chars), so this never leaks a matching prefix.
function hexEqual(a, b) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

// KNOWN_GOOD_SHA256: optional operator pin, JSON map platform → expected
// lowercase hex sha256. Presence of a platform switches it to full-buffer
// verification (see the download path below).
function knownGoodSha256(env, platform) {
  let map = {};
  try {
    map = JSON.parse(env.KNOWN_GOOD_SHA256 || "{}");
  } catch {
    map = {};
  }
  const v = map[platform];
  return typeof v === "string" && /^[0-9a-f]{64}$/i.test(v) ? v.toLowerCase() : null;
}

// Parse a single "bytes=…" Range against a known body length.
// Returns {start,end} inclusive, {unsatisfiable:true} for a well-formed but
// out-of-bounds range, or null when there is no usable range (caller then
// serves the full body, which RFC 7233 permits).
function sliceByteRange(header, total) {
  const m = /^bytes=(\d*)-(\d*)$/.exec(header.trim());
  if (!m || (m[1] === "" && m[2] === "")) return null;
  let start, end;
  if (m[1] === "") {
    const n = parseInt(m[2], 10); // suffix form: last N bytes
    if (!n) return { unsatisfiable: true };
    start = Math.max(total - n, 0);
    end = total - 1;
  } else {
    start = parseInt(m[1], 10);
    end = m[2] === "" ? total - 1 : Math.min(parseInt(m[2], 10), total - 1);
    if (start > end || start >= total) return { unsatisfiable: true };
  }
  return { start, end };
}

// PKCS#8 v1 envelope prefix for an Ed25519 seed (RFC 8410): wrapping the raw
// 32-byte seed in this DER header is what lets WebCrypto import it as a
// private key via importKey("pkcs8", …, "Ed25519").
const ED25519_PKCS8_PREFIX = new Uint8Array([
  0x30, 0x2e, 0x02, 0x01, 0x00, 0x30, 0x05, 0x06,
  0x03, 0x2b, 0x65, 0x70, 0x04, 0x22, 0x04, 0x20,
]);

// RELEASE_ED25519_SECRET_KEY: hex-encoded 32-byte Ed25519 seed (RFC 8032) —
// the key format chosen here; document any change alongside the app's
// verifier. Returns null when unset or malformed.
async function ed25519Key(env) {
  const hex = (env.RELEASE_ED25519_SECRET_KEY || "").trim();
  if (!/^[0-9a-fA-F]{64}$/.test(hex)) return null;
  const seed = hexToBytes(hex);
  const pkcs8 = new Uint8Array(ED25519_PKCS8_PREFIX.length + seed.length);
  pkcs8.set(ED25519_PKCS8_PREFIX, 0);
  pkcs8.set(seed, ED25519_PKCS8_PREFIX.length);
  return crypto.subtle.importKey("pkcs8", pkcs8, { name: "Ed25519" }, false, ["sign"]);
}

// Sign the exact raw response-body bytes and set X-Body-Signature (hex
// Ed25519) — the Flutter app verifies this header against the bytes it
// receives. Best-effort: a runtime without Ed25519 support or a bad key
// serves the response unsigned rather than breaking downloads for everyone.
async function signBody(headers, body, env) {
  try {
    const key = await ed25519Key(env);
    if (!key) return;
    const sig = await crypto.subtle.sign({ name: "Ed25519" }, key, body);
    headers.set("X-Body-Signature", bytesToHex(sig));
  } catch {
    /* unsigned — see comment above */
  }
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (url.protocol !== "https:" && url.hostname !== "localhost") {
      // Belt & braces on top of Cloudflare "Always Use HTTPS".
      return Response.redirect(`https://${url.host}${url.pathname}${url.search}`, 301);
    }

    // /fdroid/repo/<file> — self-hosted F-Droid repository (see serveFdroidFile).
    // Segments are whitelisted and dot-prefixed ones (incl. "..") rejected, so
    // this route can never proxy arbitrary upstream paths.
    const fdroidPath = url.pathname.match(/^\/fdroid\/repo((?:\/[A-Za-z0-9._=-]+)*)\/?$/);
    if (fdroidPath) {
      const segments = (fdroidPath[1] || "").split("/").filter(Boolean);
      if (segments.every((s) => !s.startsWith("."))) {
        return serveFdroidFile(segments.join("/") || "index.html", request, env);
      }
    }

    // /downloads/<platform>          → binary asset (attachment)
    // /downloads/<platform>.sha256   → published hash consumed by the app's
    //                                  anti-tamper check (DEEMUSIQ_INTEGRITY_HASH_URL)
    // /downloads/version.json        → latest versions per platform (update check)
    if (url.pathname === "/downloads/version.json") {
      let versions = {};
      try {
        versions = JSON.parse(env.VERSIONS || "{}");
      } catch {
        versions = {};
      }
      const body = new TextEncoder().encode(JSON.stringify({ versions }));
      const headers = withSecurityHeaders({
        "Content-Type": "application/json",
        "Cache-Control": "public, max-age=300",
      });
      // Sign the exact bytes served so the app's update check can verify them.
      await signBody(headers, body, env);
      return new Response(body, { status: 200, headers });
    }
    const m = url.pathname.match(/^\/downloads\/([a-z0-9_-]+?)(\.sha256)?\/?$/i);
    if (!m) {
      return new Response("Not found", {
        status: 404,
        headers: withSecurityHeaders({ "Content-Type": "text/plain" }),
      });
    }

    const platform = m[1].toLowerCase();
    const wantHash = Boolean(m[2]);
    const file = parseDownloads(env)[platform];
    if (!file || !env.GITHUB_REPO) {
      return new Response(JSON.stringify({ error: "unavailable" }), {
        status: 404,
        headers: withSecurityHeaders({ "Content-Type": "application/json" }),
      });
    }

    // Fetch THROUGH the latest-release permalink and stream the bytes back —
    // no redirect is ever issued, so no client ever learns the github.com URL
    // (view-source, devtools Network tab, curl -sIL all show only this domain).
    const asset = wantHash ? `${file}.sha256` : file;
    const upstream = `https://github.com/${env.GITHUB_REPO}/releases/latest/download/${encodeURIComponent(asset)}`;

    // Pinned platforms (KNOWN_GOOD_SHA256) are fetched whole and verified
    // before a single byte leaves the worker — see the download path below.
    const pinnedSha = wantHash ? null : knownGoodSha256(env, platform);

    // Forward the client's Range header so interrupted APK downloads can
    // resume: upstream answers 206 + Content-Range, which we pass through.
    // Ranges are only forwarded when the body will stream through untouched:
    // pinned platforms must fetch the whole object (a partial body can't be
    // hash-verified) and serve slices from the verified buffer, and the tiny
    // sidecars are served whole so their signature covers the full file.
    const upstreamHeaders = new Headers();
    const range = request.headers.get("range");
    if (range && !pinnedSha && !wantHash) upstreamHeaders.set("range", range);

    // For binary downloads, grab the published .sha256 sidecar alongside the
    // asset (small, edge-cached 5 min) so the expected digest can travel as
    // the X-Content-SHA256 response header. By default the body itself is NOT
    // verified: Web Crypto offers only one-shot subtle.digest (no
    // incremental/streaming hashing), so self-verification means buffering
    // the whole asset and delaying the first byte until the last one arrives.
    // Platforms pinned in KNOWN_GOOD_SHA256 opt into exactly that tradeoff
    // (full buffer → digest → constant-time compare) so a tampered upstream
    // release can never reach a client; everything else streams through
    // untouched and the client verifies.
    const hashUrl = `https://github.com/${env.GITHUB_REPO}/releases/latest/download/${encodeURIComponent(file)}.sha256`;
    let upstreamRes;
    let expectedSha256 = null;
    try {
      [upstreamRes, expectedSha256] = await Promise.all([
        fetch(upstream, {
          redirect: "follow",
          headers: upstreamHeaders,
          cf: { cacheEverything: true, cacheTtlByStatus: CACHE_TTL_BY_STATUS },
        }),
        wantHash ? Promise.resolve(null) : fetchExpectedSha256(hashUrl),
      ]);
    } catch {
      // DNS/timeout on the upstream fetch throws — answer 502 JSON, not an
      // unhandled worker exception (which would also drop security headers).
      upstreamRes = null;
    }

    if (!upstreamRes || !upstreamRes.ok || !upstreamRes.body) {
      // An unsatisfiable Range on an unpinned platform must surface as 416
      // (with Content-Range), not a generic 502 — download managers rely on
      // the 416 to restart the transfer instead of retrying the bad range.
      if (upstreamRes && upstreamRes.status === 416) {
        const h = withSecurityHeaders({ "Content-Type": "text/plain" });
        const cr = upstreamRes.headers.get("content-range");
        if (cr) h.set("Content-Range", cr);
        return new Response("Range not satisfiable", { status: 416, headers: h });
      }
      return new Response(JSON.stringify({ error: "unavailable" }), {
        status: 502,
        headers: withSecurityHeaders({ "Content-Type": "application/json" }),
      });
    }

    // Rebuild the response headers from an explicit allowlist — nothing else
    // the origin sent (including any github-identifying header) crosses over.
    const headers = withSecurityHeaders({});
    for (const name of PASS_THROUGH_HEADERS) {
      const value = upstreamRes.headers.get(name);
      if (value !== null) headers.set(name, value);
    }
    // Advertise range support on full 200 responses too, so download managers
    // know up front that a later Range request will be honoured.
    headers.set("Accept-Ranges", "bytes");
    // Our own cache policy, not the origin's.
    headers.set(
      "Cache-Control",
      wantHash ? "public, max-age=300" : "public, max-age=3600"
    );

    if (wantHash) {
      // .sha256 sidecars are tiny text files; force a friendly content type.
      headers.set("Content-Type", "text/plain; charset=utf-8");
      // Buffer the (tiny) sidecar so the exact bytes served can be signed for
      // the app's anti-tamper check. No Range was forwarded upstream, so this
      // is always the complete file.
      const body = await upstreamRes.arrayBuffer();
      await signBody(headers, body, env);
      return new Response(body, { status: upstreamRes.status, headers });
    }

    if (!headers.has("Content-Type")) {
      headers.set("Content-Type", "application/octet-stream");
    }
    // The filename comes from operator config, but a stray quote/CR/LF in
    // it would split the header — strip those characters defensively.
    const safeFile = String(file).replace(/["\r\n]/g, "");
    headers.set("Content-Disposition", `attachment; filename="${safeFile}"`);
    if (expectedSha256) headers.set("X-Content-SHA256", expectedSha256);

    if (pinnedSha) {
      // Pinned platform: the whole object was fetched (no Range forwarded),
      // so buffer it, hash it, and only then decide what to serve.
      // TRADEOFF (deliberate): full-buffering disables streaming for pinned
      // platforms — the first byte waits for the entire body + digest, and
      // the body counts against the worker memory limit. A mismatch means
      // the upstream release was tampered with or the pin is stale: answer
      // a generic 502 and send NOTHING of the body.
      const body = await upstreamRes.arrayBuffer();
      const digest = bytesToHex(await crypto.subtle.digest("SHA-256", body));
      if (!hexEqual(digest, pinnedSha)) {
        return new Response(JSON.stringify({ error: "unavailable" }), {
          status: 502,
          headers: withSecurityHeaders({ "Content-Type": "application/json" }),
        });
      }
      const total = body.byteLength;
      const slice = range ? sliceByteRange(range, total) : null;
      if (slice && slice.unsatisfiable) {
        // Drop the full-body Content-Length copied from the upstream 200 —
        // a 416 carries no body, and a mismatched length hangs the client.
        headers.delete("Content-Length");
        headers.set("Content-Range", `bytes */${total}`);
        return new Response(null, { status: 416, headers });
      }
      if (slice) {
        // Serve the requested slice of the verified bytes — resume still
        // works on pinned platforms, just from the buffer instead of upstream.
        headers.set("Content-Range", `bytes ${slice.start}-${slice.end}/${total}`);
        headers.set("Content-Length", String(slice.end - slice.start + 1));
        return new Response(body.slice(slice.start, slice.end + 1), { status: 206, headers });
      }
      headers.set("Content-Length", String(total));
      return new Response(body, { status: 200, headers });
    }

    // Pass through the upstream status: 200 for full responses, 206 when a
    // Range was honoured (Content-Range/Content-Length came via the allowlist).
    return new Response(upstreamRes.body, { status: upstreamRes.status, headers });
  },
};
