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
│   │   └── deemusiq-android.yml  # Only workflow present in this checkout
│   └── website/          # Astro docs/marketing site (pnpm)
├── deemusiq-site/        # Static HTML/CSS/JS site — no build step
├── backend/              # Nested git repo — gitignored, see s-b-repo/deemusiq-backend
├── AUDIT_REPORT.md       # POPIA/security audit
└── ANTI_FRAUD.md
```

## Key facts

- **DeeMusiq is a Spotube rebrand** (BSD-4-Clause). `README.md` is upstream's. DeeMusiq-specific docs are in `README.DEEMUSIQ.md`.
- **Internal "spotube" names deliberately kept**: l10n keys, Kotlin package (`oss.krtirtho.spotube`), plugin IDs, bonsoir service type, flatpak ID. Changing these breaks builds/ecosystem.
- **Hetu scripting removed** — DeeMusiq uses only native Dart backend plugin.
- **Anti-tamper**: (1) cert SHA256 pin (offline brick), (2) published APK hash check (online, locks wallet).
- **Versioning**: `x.y.z+N` in `pubspec.yaml` must match git tag `vx.y.z`. Build number always increments.
- **Backend is a separate project** at `backend/` (nested git, ignored by root `.gitignore`). Node/Express/Prisma/SQLite. All API routes in `src/index.ts`.
- **CI only for Android** in this checkout. Other platform workflows (`deemusiq-linux.yml`, etc.) exist in the upstream repo but aren't here.

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
- CI workflow comments note these workflows are designed for when **only `deemusiq-app/` is uploaded as its own repo**. In the full monorepo the root `.github/workflows/` is empty — CI lives under `deemusiq-app/.github/`.
- `cliff.toml` still points to `KRTirtho/spotube` — update repo URL before running `git-cliff`.
- `NOTICE.md` lists DeeMusiq-specific additions vs upstream (offline DRM, multi-engine extraction, Play Store/F-Droid flavors, iOS, native catalog, wallet).
