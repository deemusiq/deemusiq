# Deploying the DeeMusiq Site

> **This guide is superseded.** Production deploys to **Cloudflare Pages** with
> a Worker proxying `/downloads/*` — follow
> [`cloudflare/README.md`](cloudflare/README.md) for the full deployment and
> [`cloudflare/RELEASE.md`](cloudflare/RELEASE.md) for publishing app releases.
> This file is kept only as a minimal generic-static-host fallback.

> **Security headers require Cloudflare Pages.** The GitHub Pages mirror
> (`.github/workflows/deploy-site.yml`) **ignores `_headers`** — no CSP, no
> X-Frame-Options. Production traffic (apex `deemusiq.co.za` + `www`) MUST be
> attached to the Cloudflare Pages project, where `_headers` and
> `functions/_middleware.js` apply the full security-header set. The GitHub
> Pages mirror must stay **unlinked from the custom domain** (backup/staging
> only).

## Generic static host fallback

The site is fully static (no build step). To host it anywhere:

1. Copy the contents of this directory to any static web host's docroot.
2. Make sure the host serves `_headers` (or configure the equivalent security
   headers manually — see that file for the CSP/HSTS values).
3. Without the Cloudflare Worker, `/downloads/*` links will 404 — either deploy
   the worker (see `cloudflare/README.md`) or leave a platform value empty in
   `js/main.js` → `DOWNLOADS` so its button routes visitors to the contact
   form for early access.

## Custom domain checklist

1. Point the domain's DNS at the host.
2. Enforce HTTPS (HSTS values are in `_headers`).
3. Verify `https://<domain>/downloads/version.json` returns the versions JSON
   once the worker is deployed.
