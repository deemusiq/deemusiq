const CACHE = 'deemusiq-v1';
const ASSETS = ['/', '/index.html', '/css/styles.css', '/js/main.js'];
self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(cache => cache.addAll(ASSETS)));
});
self.addEventListener('fetch', e => {
  e.respondWith(caches.match(e.request).then(r => r || fetch(e.request)));
});
