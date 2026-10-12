# Submitting DeeMusiq to Flathub

Manifest: `com.github.KRTirtho.Spotube.yml` (this directory).

## What's in this directory

Everything the Flathub PR needs, self-contained:

- `com.github.KRTirtho.Spotube.yml` — the manifest.
- `com.github.KRTirtho.Spotube.desktop` — copy of `deemusiq-app/linux/deemusiq.desktop`.
- `com.github.KRTirtho.Spotube.appdata.xml` — copy of
  `deemusiq-app/linux/com.deemusiq.deemusiq.appdata.xml` (renamed to the
  flatpak ID; its appstream `<id>` is already `com.github.KRTirtho.Spotube`).
- `deemusiq-icon.png` — copy of `deemusiq-app/assets/branding/deemusiq-logo.png`
  (the icon the deb/AppImage packaging uses). Installed as
  `com.github.KRTirtho.Spotube.png`; the manifest rewrites the desktop file's
  `Icon=` key with `desktop-file-edit`.
- `flathub.json` — `only-arches: [x86_64]` (the release ships no aarch64
  Linux tarball).
- `shared-modules/` — vendored subset of `github.com/flathub/shared-modules`
  (libappindicator + intltool + dbus-glib + patches) needed for the tray icon.
  In the real PR you may replace this with the usual
  `git submodule add https://github.com/flathub/shared-modules.git`.

**Re-copy the desktop/appdata/icon from the app repo on every release** and add
the new `<release>` to the appdata `<releases>` block.

## Before you start

1. **Keep the flatpak ID.** `com.github.KRTirtho.Spotube` is baked into
   `linux/my_application.cc` and the appstream file; changing it breaks the
   Linux build and tray/desktop integration (see `AGENTS.md`).
2. **The ID is already published on Flathub by upstream Spotube.** A PR adding
   `com.github.KRTirtho.Spotube` to `flathub/flathub` will be rejected as a
   duplicate. Resolve this FIRST (see "Open the PR" step 0).
3. **Release asset name.** The manifest pulls
   `DeeMusiq-linux-x86_64.tar.gz` from the v1.1.0 GitHub Release on
   `deemusiq/deemusiq`. (Older drafts referenced
   `deemusiq-linux-1.1.0-x86_64.tar.xz` — that asset name never existed.)
4. **Bumping the version:**
   ```bash
   cd deemusiq-app/distribution/flathub
   python3 ../../scripts/update_flathub_version.py 1.2.0
   ```
   The script downloads `DeeMusiq-linux-x86_64.tar.gz` for `v<version>`,
   hashes it, and rewrites `modules[-1].sources[0]` url+sha256 in place (the
   `deemusiq` module must stay last in the manifest). Note it re-dumps the
   YAML and drops comments — review the diff afterwards.
5. **Flutter pin** is filled: tag `3.38.5`, commit
   `f6ff1529fd6d8af5f706051d9251ac9231c83407`. The module is provenance-only
   (the flatpak repackages the prebuilt tarball; the SDK is not installed).

## Why the manifest looks like this

- `runtime: org.gnome.Platform "50"` — the binary links GTK 3, WebKitGTK 4.1,
  libsoup-3.0, libsecret and libnotify; only the GNOME runtime provides them.
  `org.freedesktop.Platform` (earlier draft) cannot launch the app.
- `libmpv` module — media_kit `dlopen`s `libmpv.so.1/.so.2` via Dart FFI; it
  is neither in the tarball nor in any runtime. Module chain (mpv, libplacebo,
  jinja, glad, libass) is copied from upstream Spotube's published manifest.
- `libappindicator` (shared-modules) — `tray_manager` links
  `libappindicator3.so.1` + `libdbusmenu-glib.so.4`; not in any runtime.
- `org.freedesktop.Platform.ffmpeg-full` extension — full codec set for mpv.
- Extra `finish-args` vs the first draft: `org.freedesktop.secrets`
  (flutter_secure_storage), MPRIS own-name, Avahi (bonsoir), Discord RPC dir.

## Local validation (done 2026-10-07, flatpak 1.18.1 + org.flatpak.Builder)

- `python3 yaml.safe_load` — manifest parses.
- `xmllint` + `desktop-file-validate` — appdata/desktop clean.
- `appstreamcli validate --no-net` — passes (2 infos: deprecated
  `developer_name`, pedantic note on the uppercase letters in the ID — both
  inherent to the kept ID).
- `flatpak-builder-lint manifest` — one expected error:
  `appid-uses-code-hosting-domain` (com.github.* IDs need a Flathub
  exception — upstream Spotube already has one for this exact ID; request it
  in the PR). One info: GNOME runtime 51 available (50 is still supported and
  matches upstream).
- Full `flatpak run org.flatpak.Builder build-dir ...` build — **passes**
  (~10 min cold: SDK download, intltool/dbus-glib/libappindicator and
  libplacebo/libass/mpv compiles, flutter git clone). Appstream compose
  succeeds; desktop/icon/metainfo export cleanly. Note: flatpak-builder
  strips the archive's single top-level `bundle/` directory, so the build
  commands reference `deemusiq`, `lib/`, `data/` at the build root.
- `flatpak-builder-lint builddir` on the built tree — two errors, both known
  and tracked under "Known gaps": `metainfo-missing-screenshots` and
  `appid-uses-code-hosting-domain`.
- Link check inside the GNOME 50 sandbox (`flatpak build` + `ldd` on
  `/app/bin/deemusiq` and every bundled `.so`) — **all NEEDED libraries
  resolve** (GTK/WebKitGTK/libsecret/libnotify from the runtime,
  libmpv/libappindicator from the built modules).

Re-run before opening the PR:
  ```bash
  flatpak install --user flathub org.flatpak.Builder
  flatpak run org.flatpak.Builder build-dir \
    --user --install-deps-from=flathub --force-clean \
    com.github.KRTirtho.Spotube.yml
  flatpak run --command=flatpak-builder-lint org.flatpak.Builder \
    builddir build-dir
  ```

## Known gaps before the PR

- **No screenshots.** The appdata has no `<screenshots>` block and no
  DeeMusiq screenshot exists at a reachable HTTPS URL (checked the repo,
  fastlane metadata, deemusiq.co.za/press). Flathub's linter rejects GUI apps
  without screenshots — capture 1–3 PNG screenshots of the Linux build, host
  them (repo or site), and add the block to
  `deemusiq-app/linux/com.deemusiq.deemusiq.appdata.xml`, then re-copy here.
- **ID collision with upstream** (see above).

## Open the PR

0. **Resolve the ID first.** Either ask the Flathub admins (via an issue on
   `flathub/com.github.KRTirtho.Spotube` or the Discourse/matrix) about
   co-maintenance/transfer given DeeMusiq is a BSD-4-Clause rebrand of the
   frozen upstream, or accept a new ID — which this guide deliberately does
   NOT do (see AGENTS.md).
1. Fork `https://github.com/flathub/flathub` on GitHub.
2. Create a branch and copy **this whole directory** (minus SUBMIT.md) in:
   ```bash
   git checkout -b com.github.KRTirtho.Spotube
   cp -r com.github.KRTirtho.Spotube.yml com.github.KRTirtho.Spotube.desktop \
     com.github.KRTirtho.Spotube.appdata.xml deemusiq-icon.png flathub.json \
     shared-modules <flathub-fork>/
   git add . && git commit -m "Add com.github.KRTirtho.Spotube (DeeMusiq)"
   git push origin com.github.KRTirtho.Spotube
   ```
3. Open the PR against `flathub/flathub` titled `Add com.github.KRTirtho.Spotube`.
4. In the PR body disclose: DeeMusiq is a BSD-4-Clause rebrand of Spotube; the
   ID is upstream's and intentionally retained (request the
   `appid-uses-code-hosting-domain` exception — precedent: the existing
   upstream app with this same ID); network access streams from YouTube Music
   plus the first-party DeeMusiq backend.
5. The bot builds the PR; fix lint/build errors as they come.

## Timeline

Flathub review is typically **days to ~2 weeks** for a clean submission.
Once merged, the app appears on flathub.org within hours.
