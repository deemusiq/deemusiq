// Cache version: bump CACHE_VERSION on every deploy that changes cached
// CSS/JS/fonts/images so old caches are purged in `activate` and visitors
// get fresh assets. (HTML is network-first, so page changes — including
// download links — are picked up without a bump whenever the visitor is online.)
const CACHE_VERSION = 'v4'; // 2026-10-02: v3 → v4 (network-first HTML, SW registration, checksum UI)
const CACHE = `deemusiq-${CACHE_VERSION}`;
// Core assets for the offline fallback. HTML entries here are only a
// fallback — navigations are served network-first (see fetch handler).
const PRECACHE = ['/', '/index.html', '/css/styles.css', '/js/main.js'];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(cache => cache.addAll(PRECACHE))
      // Take over immediately — waiting for old tabs to close would leave
      // users on the stale worker (and stale assets) indefinitely.
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys =>
        Promise.all(keys.filter(k => k !== CACHE && k.startsWith('deemusiq-')).map(k => caches.delete(k)))
      )
      .then(() => self.clients.claim())
  );
});

// js/main.js asks a waiting worker to activate once it spots an update.
self.addEventListener('message', e => {
  if (e.data && e.data.type === 'SKIP_WAITING') self.skipWaiting();
});

// Versioned static assets only (stylesheets, scripts, fonts, images) — the
// things safe to serve from cache. HTML and downloads are NOT in this set.
function isStaticAsset(request, url) {
  return /^\/(css|js|assets)\//.test(url.pathname) ||
    ['style', 'script', 'font', 'image'].includes(request.destination);
}

function cachePut(request, response) {
  const copy = response.clone();
  caches.open(CACHE).then(c => c.put(request, copy));
}

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);
  // Never touch — and never cache — cross-origin responses.
  if (url.origin !== self.location.origin) return;

  // Navigations / HTML: network-first so deploys (including new download
  // links) are seen immediately; fall back to the cache when offline.
  if (e.request.mode === 'navigate' || e.request.destination === 'document') {
    e.respondWith(
      fetch(e.request)
        .then(res => {
          if (res.ok) cachePut(e.request, res);
          return res;
        })
        .catch(() => caches.match(e.request).then(r => r || Response.error()))
    );
    return;
  }

  // Static assets: cache-first, but revalidate in the background so a deploy
  // without a CACHE_VERSION bump still converges on the next visit.
  if (isStaticAsset(e.request, url)) {
    e.respondWith(
      caches.match(e.request).then(cached => {
        const refresh = fetch(e.request)
          .then(res => {
            if (res.ok) cachePut(e.request, res);
            return res;
          })
          .catch(() => cached);
        return cached || refresh;
      })
    );
    return;
  }

  // Everything else same-origin (/downloads/* binaries, .well-known, JSON):
  // network only, never cached — binaries are large and integrity-checked
  // server-side, and pinning them in a browser cache helps no one.
});
