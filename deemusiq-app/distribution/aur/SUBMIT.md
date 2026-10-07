# Submitting DeeMusiq to the AUR (`deemusiq-bin`)

Package drafts (this directory):

- `PKGBUILD` — repacks the prebuilt `DeeMusiq-linux-x86_64.tar.gz`
- `deemusiq.desktop` — launcher file (the release tarball ships none,
  see below)

## Before you start

1. **Verify the sha256** against the real release asset (already filled
   in from the v1.1.0 download — re-check after any re-upload):
   ```bash
   curl -LO https://github.com/deemusiq/deemusiq/releases/download/v1.1.0/DeeMusiq-linux-x86_64.tar.gz
   sha256sum DeeMusiq-linux-x86_64.tar.gz
   ```
2. **Tarball layout note.** The `tar.gz` contains only `bundle/`
   (`deemusiq` binary + `lib/` + `data/`) — no `.desktop` file and no
   icon (unlike the `.deb`, which has both). The PKGBUILD therefore:
   - installs `bundle/` to `/opt/deemusiq` (the binary resolves its
     bundled `.so` files via `RUNPATH $ORIGIN/lib` — verified),
   - ships `deemusiq.desktop` alongside the PKGBUILD (modelled on the
     deb's launcher),
   - reuses the 1024×1024 branding PNG inside the bundle as the
     hicolor icon.
3. **Dependencies** mirror the deb's declared `Depends`
   (`libgtk-3-0 libmpv2 libnotify4 libappindicator3-1` →
   `gtk3 mpv libnotify libappindicator-gtk3`), plus `optdepends` for the
   webview-login and secure-storage plugins the deb under-declares.
4. **License file.** Arch convention wants the license text in
   `/usr/share/licenses/`. The tarball doesn't carry the DeeMusiq
   BSD-4-Clause text, so the PKGBUILD installs the Flutter-aggregated
   `data/flutter_assets/LICENSE` for now. **Fix upstream**: add the repo
   `LICENSE` to the tarball root in the Linux CI workflow, then point
   the last `install` line at it.
5. **Don't "fix" upstream IDs.** The flatpak/desktop ID
   `com.github.KRTirtho.Spotube` is intentionally retained upstream
   (see `AGENTS.md`); the AUR package name `deemusiq-bin` is independent
   of it.

## Test locally (on Arch / an Arch container)

```bash
cd distribution/aur
makepkg --printsrcinfo > .SRCINFO   # regenerate after every PKGBUILD edit
makepkg -si                          # builds, then installs with pacman
deemusiq                             # smoke test
pacman -Ql deemusiq-bin              # audit the file list
namcap PKGBUILD                      # if namcap is installed: lint the packaging
```

## Publish

1. Create an AUR account at https://aur.archlinux.org and add an SSH
   public key to it.
2. Clone the (initially empty) package repo, copy the files in, commit:
   ```bash
   git clone ssh://aur@aur.archlinux.org/deemusiq-bin.git
   cd deemusiq-bin
   cp /path/to/distribution/aur/{PKGBUILD,deemusiq.desktop} .
   makepkg --printsrcinfo > .SRCINFO   # mandatory — the AUR refuses pushes without it
   git add PKGBUILD .SRCINFO deemusiq.desktop
   git commit -m "Initial import: deemusiq-bin 1.1.0-1"
   git push
   ```
3. The package appears on the AUR immediately — there is **no review
   queue**. Users install it with `yay -S deemusiq-bin` or plain
   `makepkg -si`.

## Updating later

Bump `pkgver`, reset `pkgrel=1`, update the first `sha256sums` entry
(`updpkgsums` from pacman-contrib does this for you), regenerate
`.SRCINFO`, commit, push.

## Handing over

AUR `-bin` packages for popular apps are often adopted and maintained by
community members later. That's fine and expected — add responsive
co-maintainers via the package page rather than letting it go stale; an
out-of-date package can be flagged and eventually orphaned by anyone.
