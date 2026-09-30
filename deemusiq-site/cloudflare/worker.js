/**
 * DeeMusiq download proxy + hardening worker.
 *
 * Deployed on the zone (route: `deemusiq.co.za/downloads/*`, or as a Pages
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

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (url.protocol !== "https:" && url.hostname !== "localhost") {
      // Belt & braces on top of Cloudflare "Always Use HTTPS".
      return Response.redirect(`https://${url.host}${url.pathname}${url.search}`, 301);
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
      return new Response(JSON.stringify({ versions }), {
        status: 200,
        headers: withSecurityHeaders({
          "Content-Type": "application/json",
          "Cache-Control": "public, max-age=300",
        }),
      });
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

    // Forward the client's Range header so interrupted APK downloads can
    // resume: upstream answers 206 + Content-Range, which we pass through.
    const upstreamHeaders = new Headers();
    const range = request.headers.get("range");
    if (range) upstreamHeaders.set("range", range);

    // For binary downloads, grab the published .sha256 sidecar alongside the
    // asset (small, edge-cached 5 min) so the expected digest can travel as
    // the X-Content-SHA256 response header. The worker does NOT verify the
    // body itself: Web Crypto offers only one-shot subtle.digest (no
    // incremental/streaming hashing), so self-verification would mean
    // buffering the whole APK — tens of MB against the 128MB worker memory
    // limit — and delaying the first byte until the last one arrives.
    // Streaming through untouched and letting the client verify avoids both.
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
    } else {
      if (!headers.has("Content-Type")) {
        headers.set("Content-Type", "application/octet-stream");
      }
      // The filename comes from operator config, but a stray quote/CR/LF in
      // it would split the header — strip those characters defensively.
      const safeFile = String(file).replace(/["\r\n]/g, "");
      headers.set("Content-Disposition", `attachment; filename="${safeFile}"`);
      if (expectedSha256) headers.set("X-Content-SHA256", expectedSha256);
    }

    // Pass through the upstream status: 200 for full responses, 206 when a
    // Range was honoured (Content-Range/Content-Length came via the allowlist).
    return new Response(upstreamRes.body, { status: upstreamRes.status, headers });
  },
};
