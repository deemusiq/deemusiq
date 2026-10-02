/**
 * Cloudflare Pages Functions middleware (advanced mode) — security headers.
 *
 * The GitHub Pages mirror IGNORES `_headers`, so CSP/X-Frame-Options only
 * exist when the site is served by the Cloudflare Pages project. This
 * middleware makes the header set code rather than host config: every
 * response (HTML, assets, 404s) is cloned and re-sent with the full
 * security-header set. Keep these values in sync with `_headers` — both
 * mechanisms must agree. Production traffic (apex + www) MUST be attached
 * to the Pages project for any of this to apply.
 */

// Mirrors `_headers`. CSP note: the two 'sha256-…' hashes cover the inline
// JSON-LD blocks in index.html — recompute them if those blocks are edited.
const SECURITY_HEADERS = {
  "Strict-Transport-Security": "max-age=31536000; includeSubDomains; preload",
  "X-Frame-Options": "DENY",
  "X-Content-Type-Options": "nosniff",
  "Referrer-Policy": "strict-origin-when-cross-origin",
  "Permissions-Policy": "camera=(), microphone=(), geolocation=()",
  "Content-Security-Policy":
    "default-src 'self'; " +
    "script-src 'self' 'sha256-rWRwtxA29pFvTVdZ2zDApPB8tPZYQkKxDwNTFx8a3To=' 'sha256-tHpwTawQWyxSyhx63MKahElDUoOC5y/vZlYnyXWLDpU='; " +
    "style-src 'self'; " +
    "font-src 'self'; " +
    "img-src 'self' data:; " +
    "connect-src 'self'; " +
    "form-action 'self'; " +
    "object-src 'none'; " +
    "base-uri 'self'; " +
    "frame-ancestors 'none'",
  "Cross-Origin-Opener-Policy": "same-origin",
  "Cross-Origin-Resource-Policy": "same-origin",
};

export async function onRequest(context) {
  const response = await context.env.ASSETS.fetch(context.request);
  // Clone: the asset response's headers are immutable, so rebuild a mutable
  // response and stamp the security set. Deliberately NO
  // Access-Control-Allow-Origin — nothing here is meant for cross-origin use.
  const out = new Response(response.body, response);
  for (const [name, value] of Object.entries(SECURITY_HEADERS)) {
    out.headers.set(name, value);
  }
  return out;
}
