# Submitting DeeMusiq to the official F-Droid repository

This guide walks through opening the merge request against `fdroiddata` that
gets DeeMusiq listed on f-droid.org.

## 0. Read this first — package name

F-Droid metadata files are named after the APK's `applicationId`, **not** the
Kotlin source package. DeeMusiq's real ids (from
`android/app/build.gradle`):

- `defaultConfig { applicationId "za.co.deemusiq.app" }`
- `fdroid` store flavor adds `applicationIdSuffix ".fdroid"`

So the F-Droid build (`--flavor stableFdroid`, the same one CI publishes)
produces **`za.co.deemusiq.app.fdroid`**, and the metadata file is:

```
metadata/za.co.deemusiq.app.fdroid.yml
```

A ready draft ships in this directory (`za.co.deemusiq.app.fdroid.yml`).
`oss.krtirtho.spotube` is only the upstream Spotube **Kotlin source package**,
deliberately kept (see `AGENTS.md`) — never use it as the F-Droid package name.

## 1. Prerequisites on your machine

```bash
sudo apt install fdroidserver   # or: pip install fdroidserver
git clone https://gitlab.com/fdroid/fdroiddata.git
cd fdroiddata
```

F-Droid builds on Linux with the Android SDK; `fdroidserver` will fetch what
it needs into `$ANDROID_SDK_ROOT` if you let it.

## 2. Prepare the fork

1. Fork `https://gitlab.com/fdroid/fdroiddata` on GitLab (account required).
2. Add your fork as a remote:
   ```bash
   git remote add mine git@gitlab.com:<you>/fdroiddata.git
   git checkout -b deemusiq
   ```
3. Copy the metadata file into place:
   ```bash
   cp /path/to/deemusiq-app/fdroid/za.co.deemusiq.app.fdroid.yml metadata/
   ```
4. Localize fastlane metadata comes free: F-Droid reads
   `deemusiq-app/metadata/android/en-US/` from our repo **only if** the
   fdroiddata yml uses the `fastlane` triple — simplest is to rely on the
   `Summary:`/`Description:` fields already in the yml for the first MR and
   add fastlane pickup later.

## 3. Lint and build locally

```bash
fdroid lint za.co.deemusiq.app.fdroid
fdroid readmeta          # sanity-check the whole tree parses
fdroid rewritemeta za.co.deemusiq.app.fdroid   # normalise formatting
```

Then the real test — the commented `Builds:` block in the yml is a skeleton;
uncomment it, then:

```bash
fdroid build za.co.deemusiq.app.fdroid:47
```

Known friction points to solve before the MR (be honest in the MR description):

- **Flutter SDK pin**: reproducible builds need exactly Flutter **3.38.5**
  (our CI pin). Use the fdroidserver Flutter srclib/install snippet in `sudo:`
  or `init:`.
- **`.env` requirement**: `envied` codegen aborts without a `.env`; the
  skeleton documents the minimal keys. These are compile-time only.
- **Git-sourced `dependency_overrides`** in `pubspec.yaml` (media_kit,
  bonsoir, flutter_secure_storage_linux, ...) — the F-Droid buildserver fetches
  from the network during build, but reviewers may ask for `srclibs:` pinning.
- **Rust toolchain** + `dart cli/cli.dart install-dependencies` for Android.
- **Monorepo**: `subdir: deemusiq-app` is required.
- **Anti-tamper hash check**: the app verifies its own APK hash online and
  locks the wallet on mismatch — F-Droid builds are signed by F-Droid, so the
  hash will never match ours. This is handled by a compile-time kill switch:
  pass `--dart-define=DEEMUSIQ_FDROID=true` in the build (see the `Builds:`
  skeleton). It disables ONLY the signing-cert check and the published
  APK-hash check (both assume our release key/artifact); the backend TLS pin
  probe, payment HMAC and update-metadata signature are untouched. The flag
  defaults off, so our own CI builds are unaffected.

## 4. Inclusion-policy risks for a Spotube rebrand — and how to disclose them

F-Droid's inclusion policy issues we must address head-on in the MR:

1. **NonFreeNet (expected, declared)** — audio comes from YouTube/YouTube
   Music, plus our first-party backend. Already declared as `AntiFeatures:
   NonFreeNet`. Spotube itself carries the same anti-feature, so precedent
   is on our side.
2. **Rebrand provenance** — reviewers will notice the Spotube lineage
   (Kotlin package `oss.krtirtho.spotube`, flatpak id
   `com.github.KRTirtho.Spotube`). State plainly in the MR: "DeeMusiq is a
   BSD-4-Clause rebrand/continuation of Spotube; upstream names kept
   deliberately for ecosystem compatibility." Link the LICENSE and NOTICE.md.
   Hiding this is what sinks rebrands; disclosing it is routine.
3. **Upstream repo is a placeholder** — `deemusiq/deemusiq` must be a real,
   public, tagged repo before the MR, with the `v1.1.0` tag matching
   `pubspec.yaml` `1.1.0+47`. No tag, no build, no merge.
4. **Wallet/payments** — the token wallet touches money. Expect questions
   about the `Payments`/`Money` anti-features; argue it funds artists directly
   and is optional (guest listening works without it).
5. **First-party backend** — the catalog API is hosted, not free-software
   reproducible infrastructure; that is covered by the NonFreeNet disclosure.

## 5. Open the MR

```bash
git add metadata/za.co.deemusiq.app.fdroid.yml
git commit -m "New app: DeeMusiq (za.co.deemusiq.app.fdroid)"
git push mine deemusiq
```

Open the MR on GitLab against `fdroid/fdroiddata` `master`. In the
description: link the source repo and the `v1.1.0` tag, state the Spotube
rebrand disclosure, list the AntiFeatures, paste your local
`fdroid lint` / `fdroid build` results, and note the Flutter 3.38.5 pin.

## 6. Expected timeline

Realistically **several weeks to a few months**:

- CI on the MR runs `lint` + build automatically (~hours).
- Reviewer triage for new apps is the long pole — new-app MRs commonly wait
  2–8 weeks for a first human review.
- Each fix round-trip adds days-to-weeks. Flutter apps historically need a
  few rounds (srclibs, scanignore findings, version pinning).
- After merge, the app appears on f-droid.org with the next build cycle
  (a few days).

Keep the MR small and responsive: one app, fast answers to reviewer comments.

## 7. While you wait

Ship the self-hosted F-Droid repo (see `../distribution/FDROID_REPO.md`) so
users can install via F-Droid today — the official-repo MR and the self-hosted
repo are complementary, not either/or.
