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
- **Anti-tamper**: (1) cert SHA256 pin (offline brick), (2) published APK hash check (online, locks wallet).
- **Versioning**: `x.y.z+N` in `pubspec.yaml` must match git tag `vx.y.z`. Build number always increments.
- **Backend is a separate project** at `backend/` (nested git, ignored by root `.gitignore`). Node/Express/Prisma/SQLite. All API routes in `src/index.ts`.
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
npm run dev          # tsx watch
npm run build        # tsc
npm start            # node dist/index.js
npm run db:generate  # prisma generate
npm run db:migrate   # prisma migrate dev
npm test             # node --test
```

### Static site (`deemusiq-site/`)

No build step. Deploy by copying files to any static host. Download links in `js/main.js` → `DOWNLOADS`.

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
- `--dart-define` at build time: `DEEMUSIQ_BACKEND_URL`, `DEEMUSIQ_CHANNEL_KEY`, `DEEMUSIQ_CERT_SHA256`
- Git-sourced deps via `dependency_overrides` in `pubspec.yaml` (media_kit, bonsoir, flutter_secure_storage_linux, etc.)

## CI quality gate

Every branch/PR runs `check` job: `pub get` → create `.env` → `build_runner build` → `flutter analyze --no-fatal-infos` → `flutter test`.

The `android` job builds APK only on `v*` tags or manual dispatch, after `check` passes.

## Gotchas

- `flutter analyze --no-fatal-infos` needed — there are known info-level lints (e.g. `avoid_print` in `lib/services/cli/cli.dart`).
- The Android workflow exists twice on purpose: the root `.github/workflows/deemusiq-android.yml` (monorepo, `working-directory: deemusiq-app` — the one GitHub runs here) and `deemusiq-app/.github/workflows/deemusiq-android.yml` (for when **only `deemusiq-app/` is uploaded as its own repo**). Keep them in sync; they are not a conflict.
- `NOTICE.md` lists DeeMusiq-specific additions vs upstream (offline DRM, multi-engine extraction, Play Store/F-Droid flavors, iOS, native catalog, wallet).
