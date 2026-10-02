# Release plumbing — publishing a DeeMusiq app release

GitHub Releases is the **file host only**. End users must never see the host:
not in HTML/JS, not in response headers, not via redirect. The worker in this
directory streams the bytes through same-origin (`/downloads/*`), rebuilds the
response headers from an allowlist, and serves version info itself. Keep it
that way: never put a release URL in the site, the app, or any client-visible
file.

## 1. Build + tag

1. Bump `deemusiq-app/pubspec.yaml` → `version: x.y.z+N` (build number `N`
   always increments).
2. Tag the release commit: `git tag vx.y.z && git push --tags`. The tag must
   match the pubspec version (`x.y.z`).
3. The platform workflows (`.github/workflows/deemusiq-*.yml`) build the
   artifacts on `v*` tags.

## 2. Publish the GitHub Release

Create the release for tag `vx.y.z` and attach **all** of:

| Asset | Notes |
|---|---|
| `DeeMusiq.apk` | Android build (`stableFdroid` output copied to `dist/`) |
| `DeeMusiq.apk.sha256` | `sha256sum DeeMusiq.apk > DeeMusiq.apk.sha256` |
| `DeeMusiq-setup.exe` | Windows installer |
| `DeeMusiq.AppImage` | Linux |
| `DeeMusiq.dmg` | macOS |

Asset filenames must match `DOWNLOADS` in `wrangler.toml` exactly — the worker
fetches `…/releases/latest/download/<filename>` and `<filename>.sha256`.

**The `.sha256` sidecar is mandatory**: the worker reads it and sends the
digest as the `X-Content-SHA256` response header, and the app's anti-tamper
check fetches `/downloads/android.sha256`. A release without the sidecar
ships without integrity verification.

## 3. Bump versions together

In the **same commit**, update:

- `deemusiq-app/pubspec.yaml` → `version: x.y.z+N`
- `cloudflare/wrangler.toml` → `VERSIONS` JSON, every platform to `x.y.z`
- `index.html` JSON-LD `softwareVersion`, `llms.txt`, `press/` fact sheet
  (these say `1.1.0` today)

Redeploy the worker after editing `wrangler.toml`:

```bash
cd deemusiq-site/cloudflare
npx wrangler deploy
```

## 4. Verify (all from a shell, as a client would)

```bash
# a. No host fingerprint in headers — must print NOTHING:
curl -sI https://deemusiq.co.za/downloads/android | grep -i github

# b. Resume works — expect "HTTP/2 206", Content-Range, Accept-Ranges,
#    Content-Length, and X-Content-SHA256:
curl -sI -H 'Range: bytes=0-99' https://deemusiq.co.za/downloads/android

# c. Full download advertises ranges too — expect 200 + Accept-Ranges: bytes:
curl -sI https://deemusiq.co.za/downloads/android | grep -i accept-ranges

# d. Update check reflects the new version:
curl -s https://deemusiq.co.za/downloads/version.json

# e. Hash sidecar matches the published release:
curl -s https://deemusiq.co.za/downloads/android.sha256
```

If (a) prints anything, the worker header allowlist regressed — do not
announce the release until it's clean.

## 5. Site cache rule

If the release changes the **downloads page markup** (`index.html` download
section, `js/main.js` `DOWNLOADS`, the Obtainium link), bump `CACHE_VERSION`
in `deemusiq-site/sw.js` so returning visitors' service-worker caches are
purged and they see the new page. Version-string-only releases (worker env +
JSON-LD) don't need it.

## Notes

- Edge cache: 200s are cached 1 h at the edge; 404s 60 s; 5xx 30 s
  (`cacheTtlByStatus` in `worker.js`). A botched release upload therefore
  self-heals within a minute — just fix the release assets.
- The worker never buffers the APK unless the platform is pinned via
  `KNOWN_GOOD_SHA256` (full-buffer verification disables streaming for those
  platforms — see the comment in `worker.js`), so there is no size limit
  concern on the default proxy path; range/resume is passed straight through
  from the origin.
