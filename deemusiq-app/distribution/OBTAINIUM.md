# Obtainium — DeeMusiq app config

`obtainium.json` in this directory is an Obtainium import/export file that adds
DeeMusiq from the GitHub Releases source:

- Source: `https://github.com/deemusiq/deemusiq` (repo placeholder — must be
  the real public repo before publishing this file)
- Release asset filter: `^DeeMusiq\.apk$` — matches the APK asset CI attaches
  to every `v*` release (root workflow `deemusiq-android.yml` copies the
  `stableFdroid` build to `dist/DeeMusiq.apk`)
- Version extraction: `^v?(.+)$` against the tag (`v1.1.0` → `1.1.0`)

Users import it in Obtainium via **Import/Export → Obtainium import**.

## Adding the obtainium:// deep link to the downloads page

Obtainium registers an `obtainium://` URL scheme. Add a link on the downloads
page (site `js/main.js` → `DOWNLOADS`, near the APK link) like:

```html
<a href="obtainium://add/https://github.com/deemusiq/deemusiq">
  Get it on Obtainium
</a>
```

Tapping it on a phone with Obtainium installed opens the "Add App" screen
pre-filled with the GitHub source — the user just confirms. Keep the plain
APK link and the F-Droid repo (see `FDROID_REPO.md`) as alternatives; the
deep link does nothing on devices without Obtainium, so label it clearly.
