# DeeMusiq

*It's a drop day.*

DeeMusiq is a cross-platform music client for desktop and mobile, forked from
[Spotube](https://github.com/krtirtho/spotube) (BSD-4-Clause) and rebranded with
regional pricing, a token wallet, creator payouts, ratings and regional charts.

> **Free code signing provided by SignPath.io, certificate by SignPath
> Foundation** — see the [Code signing policy](./CODE_SIGNING_POLICY.md).

## What's in this repository

This repository contains the **client application only**.

| Path | What it is |
|------|-----------|
| [`deemusiq-app/`](./deemusiq-app) | The Flutter app (Dart) — Android, iOS, Linux, macOS, Windows |
| [`deemusiq-site/`](./deemusiq-site) | The static website, download page and press kit |
| [`.github/workflows/`](./.github) | Release pipelines (Flutter app + site deploy) |

**The backend is not here.** It is a private service in a separate repository
(`s-b-repo/deemusiq-backend`) and is git-ignored from this one. Nothing in this
repository contains backend source, deployment credentials or secrets.

## Downloads

Release binaries and the per-platform SHA-256 checksums are published on the
[releases page](https://github.com/deemusiq/deemusiq/releases) and served from
[deemusiq.co.za](https://deemusiq.co.za/#download). Every artifact is checksummed;
verify it before installing:

```bash
sha256sum -c DeeMusiq-<platform>.sha256
```

## Building

Requires Flutter 3.38.5 (not on `PATH` by default) and Node 20 for tooling.

```bash
export PATH="$HOME/flutter/bin:$PATH"
cd deemusiq-app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # required before analyze
flutter analyze --no-fatal-infos
flutter test
```

Full build, release-gate and signing details are in
[`deemusiq-app/README.DEEMUSIQ.md`](./deemusiq-app/README.DEEMUSIQ.md).

## Licence

BSD-4-Clause — single-licensed, with no additional or commercial dual-licensing.
See [`LICENSE`](./LICENSE). Upstream Spotube is © Kingkor Roy Tirtho; DeeMusiq
modifications are listed in [`deemusiq-app/NOTICE.md`](./deemusiq-app/NOTICE.md).