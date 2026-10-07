# Submitting DeeMusiq to the Snap Store

Manifest draft: `snapcraft.yaml` + `gui/deemusiq.desktop` +
`gui/deemusiq.png` (this directory).

This is a **binary repack**: the `dump` plugin unpacks the published
`DeeMusiq-linux-x86_64.tar.gz` from the GitHub Release; nothing is
compiled. The Flutter binary finds its bundled libraries via
`RUNPATH $ORIGIN/lib`, so `command: bundle/deemusiq` works as extracted.

## Before you start

1. **Register the name.** The snap name `deemusiq` must be claimed before
   the first upload:
   ```bash
   snapcraft login
   snapcraft register deemusiq
   ```
   If the name is taken, file a name dispute at
   https://forum.snapcraft.io/c/store-requests — or rename in
   `snapcraft.yaml` (and the `Exec=` line stays as-is; only `name:`
   changes the store identity).
2. **The tarball ships no desktop file or icon.** Unlike the `.deb`, the
   release `tar.gz` is only `bundle/` (binary + `lib/` + `data/`). The
   snap therefore carries its own launcher assets under `gui/` — the
   desktop file is modelled on the deb's, and `gui/deemusiq.png` is the
   1024×1024 icon extracted from the deb. If the tarball ever grows its
   own `*.desktop`/icon, delete `gui/` and point snapcraft at those.
3. **desktop-file-validate false positive.** It flags
   `Icon=${SNAP}/meta/gui/deemusiq.png` as a relative path — `${SNAP}` is
   expanded by snapd at install time and this is the documented snap
   convention, so ignore that one error.
4. **Don't "fix" the upstream desktop ID.** The flatpak/appstream ID is
   `com.github.KRTirtho.Spotube` on purpose (see `distribution/flathub/SUBMIT.md`
   and `AGENTS.md`). The snap is named `deemusiq` independently of that
   ID; leave both alone.
5. The sha256 in `source-checksum` was hashed from the real release
   asset. Re-verify after any re-upload of the release:
   ```bash
   curl -LO https://github.com/deemusiq/deemusiq/releases/download/v1.1.0/DeeMusiq-linux-x86_64.tar.gz
   sha256sum DeeMusiq-linux-x86_64.tar.gz
   ```

## Build

```bash
sudo snap install snapcraft --classic   # or: sudo apt install snapcraft

# Local build (needs LXD or a --destructive-mode run on a matching base):
snapcraft pack --destructive-mode

# Or build on Canonical's builders (no local toolchain needed):
snapcraft remote-build
```

Local smoke test of the resulting snap:

```bash
sudo snap install --dangerous deemusiq_1.1.0_amd64.snap
snap run deemusiq
```

## Upload and release

```bash
snapcraft upload deemusiq_1.1.0_amd64.snap --release=stable
```

A first-time upload to `stable` triggers a **manual review** by the Snap
Store team — expect **a few days up to ~1 week**. Subsequent uploads pass
automated review in minutes. Automatic review may flag:

- `pulseaudio` + `audio-playback` both declared — keep them; the first
  covers strict-confinement audio on classic desktops, the second is the
  modern interface name. If the reviewer asks to drop one, drop
  `pulseaudio`.
- Requests for `classic` confinement — we don't need it; strict is
  correct for this app.

## Updating later

Bump `version:` and the `source:` URL, recompute `source-checksum`, then
`snapcraft remote-build && snapcraft upload --release=stable`. Consider
wiring this into the `deemusiq-linux.yml` CI workflow once the store
credentials exist (`snapcraft export-login`).
