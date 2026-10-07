# DeeMusiq — Agent Guide

## Repository layout

```
.                         # Monorepo root — three projects + audit docs
├── deemusiq-app/         # Flutter app (rebranded Spotube) — primary deliverable
│   ├── lib/main.dart     # App entrypoint
│   ├── pubspec.yaml      # name: deemusiq, version: x.y.z+N
│   ├── Makefile          # tar, migrate, changelog, dmg, etc.
│   ├── analysis_options.yaml
│   ├── build.yaml        # build_runner config (auto_route, json_serializable, drift)
│   ├── l10n.yaml         # ARB-based localisation → lib/l10n/generated
│   ├── .github/workflows/
│   │   └── deemusiq-android.yml  # App-only copy; dormant in the monorepo (see CI below)
│   ├── metadata/android/en-US/  # Fastlane/F-Droid listing copy (title, descriptions, changelogs)
│   ├── fdroid/             # F-Droid official-inclusion prep (metadata yml + SUBMISSION.md)
│   ├── distribution/       # Self-hosted F-Droid repo guide, Obtainium config, desktop store manifests
│   ├── packages/bramble_dart/  # GPLv3 clean-room Bramble (Briar) protocol core, M1 — NOT linked into the app pubspec/UI; license review before any distribution
│   └── website/          # Astro docs/marketing site (pnpm)
├── deemusiq-site/        # Static HTML/CSS/JS site — no build step
│   ├── .well-known/assetlinks.json  # Android App Links (REPLACE_ME fingerprint until release)
│   ├── llms.txt            # AI-answer-engine summary
│   └── press/              # Self-serve press kit (bio, fact sheet, pitch template)
├── backend/              # Nested git repo — gitignored, see s-b-repo/deemusiq-backend
├── AUDIT_REPORT.md       # POPIA/security audit
└── ANTI_FRAUD.md
```

## Key facts

- **DeeMusiq is a Spotube rebrand** (BSD-4-Clause). `README.md` is upstream's. DeeMusiq-specific docs are in `README.DEEMUSIQ.md`.
- **Internal "spotube" names deliberately kept**: l10n keys, Kotlin source package (`oss.krtirtho.spotube`), plugin IDs, bonsoir service type, flatpak ID. Changing these breaks builds/ecosystem. **But the Android `applicationId` is `za.co.deemusiq.app`** (`android/app/build.gradle:64`; the fdroid flavor adds suffix `.fdroid`, playstore/stable combo strips suffixes) — use the applicationId, not the Kotlin package, for store listings and `assetlinks.json`.
- **Hetu scripting removed** — DeeMusiq uses only native Dart backend plugin.
- **Anti-tamper**: (1) cert SHA256 pin (offline brick; fails closed when `DEEMUSIQ_CERT_SHA256` is pinned), (2) published APK hash check (online, locks wallet; requires valid `X-Body-Signature` Ed25519 header from the download worker when `DEEMUSIQ_INTEGRITY_ED25519_PUBLIC_KEY` is set), (3) active backend TLS-pin probe (`BackendCertPinProbe` in `lib/collections/http-override.dart` — `badCertificateCallback` alone never fires for valid-but-wrong certs; the probe locks the wallet on mismatch via `IntegrityService`). The pin check is scoped to the backend host only — never widen the callback to other hosts.
- **TLS pin rotation is automated**: `deemusiq-app/server-tls-pins.txt` is the source of truth for `DEEMUSIQ_SERVER_CERT_SHA256` (the repo secret is only a fallback now). TLS terminates at the Cloudflare edge, which rotates the cert ~every 90 days without overlap; `.github/workflows/cert-pin-watch.yml` polls every 6h, vets the new cert (issuer allowlist + hostname + validity window — a foreign CA is refused), commits the new pin, dispatches all app rebuilds, and opens an issue. The human step that remains: verify the hash in CT logs and publish the artifacts per DISTRIBUTION.md. Never bypass this with `rejectUnauthorized`-style loosening.
- **Versioning**: `x.y.z+N` in `pubspec.yaml` must match git tag `vx.y.z`. Build number always increments.
- **Backend is a separate project** at `backend/` (nested git, ignored by root `.gitignore`). Node/Express/Prisma/SQLite. All API routes in `src/index.ts`.
- **Admin console is served by the backend** at `/console` (Next standalone bundled into the API image; `basePath: "/console"` in deemusiq-admin). In production it should sit behind Cloudflare Access (`CF_ACCESS_*` env, JWT verified in `src/middleware/cfAccess.ts`); cookie login remains as break-glass.
- **CI lives in root `.github/workflows/`**: `deemusiq-android.yml`, `deemusiq-linux.yml`, `deemusiq-macos.yml`, `deemusiq-windows.yml` (Flutter-app builds, `working-directory: deemusiq-app`) and `deploy-site.yml` (site deploy). `deemusiq-app/.github/` holds a copy of the Android workflow for the "upload only `deemusiq-app/` as its own repo" case; GitHub only auto-discovers root workflows, so the app copy never runs in this checkout.

## Developer commands

### Flutter app (`deemusiq-app/`)

```bash
# Required order for full build:
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed, json, drift, auto_route, envied
flutter analyze --no-fatal-infos
flutter test
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
dart run flutter_native_splash:create

# Build
flutter build apk --release --flavor stable                # Android
flutter build linux --release                               # Linux

# Other
flutter gen-l10n                                           # Regenerate localisations
dart run drift_dev make-migrations                         # DB migrations
git-cliff --unreleased                                     # Changelog (cliff.toml)
```

### `.env` file required

`envied` codegen aborts without `.env`. Create with at minimum:
```
LASTFM_API_KEY=
LASTFM_API_SECRET=
ENABLE_UPDATE_CHECK=1
RELEASE_CHANNEL=stable
HIDE_DONATIONS=1
```

### Backend (`backend/`)

```bash
./scripts/setup.sh      # one-command setup (--dev default, --docker full stack, --seed, --reset)
npm run dev          # tsx watch
npm run build        # tsc
npm start            # node dist/index.js
npm run db:generate  # prisma generate
npm run db:migrate   # prisma migrate dev
npm test             # node --test
```

### Static site (`deemusiq-site/`)

No build step. **Production traffic must be served by the Cloudflare Pages project** — GitHub Pages ignores `_headers` and `functions/_middleware.js` (the Pages Function that sets CSP/XFO/COOP/CORP on every response); the GH Pages mirror must stay unlinked from the custom domain. `js/main.js` registers `sw.js` (network-first for HTML, cache-first for static assets) and auto-displays SHA-256 checksums from `/downloads/<platform>.sha256` next to download buttons. `deploy-site.yml` fails the deploy while `.well-known/assetlinks.json` still contains `REPLACE_ME` fingerprints. The download worker (`cloudflare/worker.js`) verifies bodies against an optional `KNOWN_GOOD_SHA256` pin map and signs sidecar/update responses with `X-Body-Signature` when `RELEASE_ED25519_SECRET_KEY` is set.

### Astro docs site (`deemusiq-app/website/`)

```bash
pnpm install
pnpm dev             # :4321
pnpm build
```

## Build environment

- Flutter `>=3.29.0` (CI uses 3.38.5 stable)
- Dart `>=3.0.0 <4.0.0`
- Java 17 (Zulu) + Rust toolchain + `dart cli/cli.dart install-dependencies` for Android builds
- `--dart-define` at build time: `DEEMUSIQ_BACKEND_URL`, `DEEMUSIQ_CHANNEL_KEY`, `DEEMUSIQ_CERT_SHA256`, `DEEMUSIQ_SERVER_CERT_SHA256` (TLS pin probe), `DEEMUSIQ_PAYMENT_HMAC_SECRET`, `DEEMUSIQ_UPDATE_ED25519_PUBLIC_KEY` (update metadata signature), `DEEMUSIQ_INTEGRITY_ED25519_PUBLIC_KEY` (published-hash signature). The first four come from repo secrets; the two Ed25519 public keys from repo vars.
- Git-sourced deps via `dependency_overrides` in `pubspec.yaml` (media_kit, bonsoir, flutter_secure_storage_linux, etc.)

## CI quality gate

Every branch/PR runs `check` job: `pub get` → create `.env` → `build_runner build` → `flutter analyze --no-fatal-infos` → `flutter test`.

The `android` job builds APK only on `v*` tags or manual dispatch, after `check` passes.

## Gotchas

- `flutter analyze --no-fatal-infos` needed — there are known info-level lints (e.g. `avoid_print` in `lib/services/cli/cli.dart`).
- Upstream Spotube status (checked 2026-09-30): Flutter line frozen at v5.1.2 (master, BSD-4-Clause — fork base, nothing left to port); `dev` branch is an AGPL-3.0 Kotlin/Compose rewrite — **never copy code from `dev`** (AGPL would contaminate this BSD fork; clean-room concept ports only). Org moved KRTirtho/spotube → team-spotube/spotube (redirects work; SHA-pinned deps unaffected).
- The Android workflow exists twice on purpose: the root `.github/workflows/deemusiq-android.yml` (monorepo, `working-directory: deemusiq-app` — the one GitHub runs here) and `deemusiq-app/.github/workflows/deemusiq-android.yml` (for when **only `deemusiq-app/` is uploaded as its own repo**). Keep them in sync; they are not a conflict.
- `NOTICE.md` lists DeeMusiq-specific additions vs upstream (offline DRM, multi-engine extraction, Play Store/F-Droid flavors, iOS, native catalog, wallet).
