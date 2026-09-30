# Cloudflare deployment — encrypted site + hidden download links

Goals:

1. **Everything for visitors runs on Cloudflare** — static site on **Pages**,
   HTTPS/HSTS enforced, origin hidden.
2. **Clients can never see where builds are hosted.** Download buttons point at
   same-origin `/downloads/<platform>` paths served by the worker in this
   directory, which streams assets through from the release host. The upstream
   URL exists only in worker env — never in shipped HTML/JS, never as a
   redirect, and never in response headers (the worker rebuilds headers from
   an allowlist).
3. **API + admin** ride a named **Tunnel** (`api.deemusiq.co.za`,
   `admin.deemusiq.co.za`) — see `deemusiq-backend/DEPLOY_TUNNEL.md`.

---

## 1. DNS + TLS (dashboard)

1. `deemusiq.co.za` zone on Cloudflare.
2. **Pages project** `deemusiq-site` → custom domains `@` and `www`
   (build command empty; output = site root). A legacy static mirror
   (`deploy-site.yml`) stays as a backup — do **not** also attach the
   custom domain there.
3. Tunnel hostnames auto-create proxied `api` / `admin` records.
4. R2 bucket custom domain → `media.deemusiq.co.za` (proxied).
5. **SSL/TLS → Overview**: **Full (strict)**. Never "Flexible".
6. **SSL/TLS → Edge Certificates**: Always HTTPS ON, min TLS 1.2, HSTS
   (`max-age 31536000; includeSubDomains; preload`), TLS 1.3 ON.
7. **Security**: Bot Fight Mode + managed WAF; rate-limit `/auth/*` and
   `/creator/uploads/*`.
8. **Caching → Cache Rules**:
   - Cache: `GET /metadata/*`, `/catalog*`, `/pricing*`, `/leaderboard*`
     (respect origin Cache-Control)
   - Bypass: `/auth*`, `/creator*`, `/admin*`, `/webhooks*`, `/payments*`

## 2. Deploy the static site (Pages) + download proxy (Worker)

```bash
cd cloudflare
npx wrangler login

# Pages (site body) — from the site directory:
npx wrangler pages deploy .. --project-name=deemusiq-site

# Worker (only /downloads/*):
npx wrangler secret put GITHUB_REPO      # e.g. deemusiq/deemusiq
npx wrangler deploy
```

The route binding means only `/downloads/*` hits the worker; everything else
is Pages.

Publishing a new app release (assets, version bumps, verification): see
[`RELEASE.md`](RELEASE.md).

What clients see vs. what they can't:

| Client observes                        | Reveals the file host? |
| -------------------------------------- | ---------------------- |
| `href="/downloads/android"`            | No              |
| `curl -sIL https://…/downloads/android` | No — bytes are streamed through, no redirect |
| DevTools Network tab                   | No — single same-origin request |

## 3. App integrity hash

Build the app with its anti-tamper hash check pointed at the proxy too, so the
release host's domain never appears in APK strings either:

```
--dart-define=DEEMUSIQ_INTEGRITY_HASH_URL=https://deemusiq.co.za/downloads/android.sha256
```

## 4. Backend audio (hide the music source)

On the backend host set:

```bash
STREAM_MODE=true
STREAM_TTL_SECONDS=3600          # signed play URLs live 1h
STREAM_SECRET=<openssl rand -hex 32>
YT_DLP_PATH=/usr/local/bin/yt-dlp  # needed only for YouTube-sourced tracks
```

With that on, the API hands clients short-lived signed URLs on YOUR backend
(`/metadata/audio/:id`) which fetch/resolves audio server-side — youtube video
ids and file hosts never reach the app. The catalog feed stops emitting
`youtubeId`; the Flutter app plays the proxied URL via its existing
direct-URL path (no republish required for old builds — they fall back to
YouTube search only when a track has neither id nor stream URL).

## Limits to be honest about

- Proxying audio/downloads routes traffic through CF Workers (free tier:
  ~100k req/day) or your backend — watch bandwidth for large releases.
- A *modified* client can still log where its bytes come from (your proxy's
  domain). This hides origin hosts from normal users, network snoopers and the
  shipped app code; it cannot stop someone instrumenting their own player.
- Signed stream URLs are bearer tokens until they expire — that's why the TTL
  is configurable and `STREAM_SECRET` rotation invalidates all of them.
