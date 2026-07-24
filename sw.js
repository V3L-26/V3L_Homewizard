// Service worker: maakt het dashboard zelf (de "app-schil") offline-beschikbaar,
// zodat de app na installatie zonder internet kan opstarten. De live meterdata
// wordt NOOIT gecachet - die moet altijd vers over je lokale wifi opgehaald worden.

const CACHE_NAME = 'p1-dashboard-v3.3';
const ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './v3l-logo.png',
  './v3l-icon-256.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(ASSETS))
      .catch(() => {}) // niet blokkeren als een asset niet te cachen is
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Live meterdata: altijd rechtstreeks naar het netwerk, nooit uit cache serveren.
  if (url.pathname.indexOf('/api/v1/data') !== -1) {
    return;
  }

  // App-schil (html/manifest/deze worker): cache-first met network fallback,
  // en ververs de cache op de achtergrond zodat updates alsnog doorkomen.
  event.respondWith(
    caches.match(event.request).then((cached) => {
      const network = fetch(event.request)
        .then((response) => {
          if (response && response.ok) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
          }
          return response;
        })
        .catch(() => cached);
      return cached || network;
    })
  );
}