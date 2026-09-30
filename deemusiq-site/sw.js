// Cache version: bump CACHE_VERSION on every deploy that changes cached HTML/CSS/JS
// so old caches are purged in `activate` and visitors get fresh pages.
const CACHE_VERSION = 'v3'; // 2026-09-30: v2 → v3 (downloads page markup: Obtainium link)
const CACHE = `deemusiq-${CACHE_VERSION}`;
const ASSETS = ['/', '/index.html', '/css/styles.css', '/js/main.js'];
self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(cache => cache.addAll(ASSETS)));
});
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE && k.startsWith('deemusiq-')).map(k => caches.delete(k)))
    )
  );
});
self.addEventListener('fetch', e => {
  e.respondWith(caches.match(e.request).then(r => r || fetch(e.request)));
});
