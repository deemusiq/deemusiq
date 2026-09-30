# DeeMusiq — Website

> *It's a drop day.* Africa's home-grown music platform — stream & download, artists own their work.

A fast, single-page, fully static website (no build step). Production deploys to
**Cloudflare Pages**; it also works on any static web host.

---

## What's inside

```
deemusiq-site/
├── index.html              # the whole page
├── css/styles.css          # all styling (dark / honeycomb / orange theme)
├── js/main.js              # nav, scroll reveals, contact form, download buttons
├── assets/img/             # logo, favicons + your own artwork
├── cloudflare/             # Pages config + /downloads/* proxy worker + release docs
├── _headers                # security headers (CSP/HSTS) applied by the host
├── sw.js                   # service worker (bump CACHE_VERSION on markup changes)
└── README.md               # this file
```

---

## 🚀 Deploy

The site deploys to Cloudflare Pages (no build step, output = this directory) and
app downloads are proxied same-origin through a Cloudflare Worker bound to
`/downloads/*`, so visitors never see where the build files are hosted.

Full instructions — DNS/TLS, Pages project, worker deploy, cache rules — live in
[`cloudflare/README.md`](cloudflare/README.md). Release publishing steps are in
[`cloudflare/RELEASE.md`](cloudflare/RELEASE.md). `DEPLOY.md` is a legacy
quick-start kept for reference.

---

## ✏️ Things to update (search & replace)

| What | Where | Current value |
|------|-------|---------------|
| Contact email | `index.html` (mailto link) **and** `js/main.js` (`CONTACT_EMAIL`) | `deemusiq@protonmail.com` ✅ from client docs |
| Phone / WhatsApp | `index.html` → search `+27 73 725 3454` | `+27 73 725 3454` ✅ from client docs |
| Social links | `index.html` → `contact__socials` | real handles |
| Download links | `js/main.js` → the `DOWNLOADS` object | same-origin `/downloads/<platform>` |

### Wiring up the app downloads
Download buttons point at same-origin paths served by the worker — no file-host
URLs ever appear in shipped HTML/JS:

```js
var DOWNLOADS = {
  android: "/downloads/android",
  windows: "/downloads/windows",
  linux:   "/downloads/linux",
  macos:   "/downloads/macos"
};
```
The worker maps each platform to the current release file via its `DOWNLOADS`
env var (see `cloudflare/wrangler.toml`). Any button left as `""` automatically
sends visitors to the contact form to request early access — so the page is
never broken while you wait for a build.

---

## 📬 Want a real contact form (no email app popup)?

The form currently opens the visitor's email app (works everywhere, no signup).
For a hosted form that lands in your inbox:

1. Create a free form at <https://formspree.io> → copy your form ID.
2. In `index.html`, change the `<form>` tag to:
   ```html
   <form class="contact__form" id="contactForm" action="https://formspree.io/f/XXXX" method="POST">
   ```
3. In `js/main.js`, delete the `contact form → mailto` block (so the browser submits normally).

---

## 🌐 Custom domain

`deemusiq.co.za` (apex + www) is attached to the Cloudflare Pages project — see
`cloudflare/README.md` §1 for DNS, TLS and HSTS settings.

---

## Credits & licensing
- Brand, artwork and content © DeeMusiq / The Dembe Group.
- The companion **DeeMusiq app** is open source under the **BSD-4-Clause**
  license. Keep the bundled `LICENSE` and copyright notices in the app
  distribution (see the app folder's README); attributions are in `LICENSE`.
