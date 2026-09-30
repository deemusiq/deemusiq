# Submitting DeeMusiq to Flathub

Manifest draft: `com.github.KRTirtho.Spotube.yml` (this directory).

## Before you start

1. **Keep the flatpak ID.** `com.github.KRTirtho.Spotube` is baked into
   `linux/my_application.cc` and the appstream file; changing it breaks the
   Linux build and the tray/desktop integration (see `AGENTS.md`). Flathub
   allows this — the ID just must be unique and appstream-consistent.
2. **Publish a real release first.** The manifest pulls
   `deemusiq-linux-1.1.0-x86_64.tar.xz` from the GitHub Releases of the
   (placeholder) repo `deemusiq/deemusiq`. No asset → no build.
3. **Fill the placeholders**: the tarball `sha256` and the Flutter 3.38.5
   git commit pin. Helper:
   ```bash
   cd deemusiq-app
   python3 scripts/update_flathub_version.py 1.1.0   # run in a dir containing the yml
   ```
   That script downloads the tarball, hashes it, and rewrites
   `modules[-1].sources[0]` url+sha256 in place.
4. Validate locally:
   ```bash
   flatpak install flathub org.flatpak.Builder
   flatpak run org.flatpak.Builder build-dir \
     --user --install-deps-from=flathub --force-clean \
     com.github.KRTirtho.Spotube.yml
   flatpak run --command=flathub-build org.flatpak.Builder \
     --lint com.github.KRTirtho.Spotube.yml   # or use appstream-util validate
   ```

## Open the PR

1. Fork `https://github.com/flathub/flathub` on GitHub.
2. Create a branch, add **only** the manifest (plus any flathub.json if you
   need e.g. `only-arches: [x86_64]`):
   ```bash
   git checkout -b com.github.KRTirtho.Spotube
   mkdir com.github.KRTirtho.Spotube
   cp com.github.KRTirtho.Spotube.yml com.github.KRTirtho.Spotube/
   git add . && git commit -m "Add com.github.KRTirtho.Spotube (DeeMusiq)"
   git push origin com.github.KRTirtho.Spotube
   ```
3. Open the PR against `flathub/flathub` with title
   `Add com.github.KRTirtho.Spotube`.
4. In the PR body disclose: DeeMusiq is a BSD-4-Clause rebrand of Spotube; the
   ID is upstream's and intentionally retained; network access streams from
   YouTube Music plus the first-party DeeMusiq backend (appstream/app will
   note this).
5. The bot builds the PR; fix lint/build errors as they come (expect
   appstream screenshot/icon nags — screenshots must be reachable HTTPS URLs
   in the appdata file).

## Timeline

Flathub review is typically **days to ~2 weeks** for a clean submission —
much faster than F-Droid. Once merged, the app appears on flathub.org within
hours.
