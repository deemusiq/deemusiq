# Listing DeeMusiq on AppImageHub (appimage.github.io)

Data file draft: `DeeMusiq` (this directory) — one line, the repo URL.
That is the entire submission format: appimage.github.io pulls all
metadata **out of the AppImage itself** and stores no other copy.

## Before you start

1. **The filename rules** (their CI rejects anything else): the file in
   `data/` must be named exactly like the app in its desktop file —
   `DeeMusiq` — with no extension, no version, no architecture, no
   "AppImage"/"Linux" suffix.
2. **Content rules**: one line, a link. Ideally the GitHub project page
   (not a specific AppImage); their bot then picks the x86_64 AppImage
   from the newest release. Our asset name
   `DeeMusiq-linux-x86_64.AppImage` is unambiguous in the v1.1.0
   release (only one AppImage), so the plain repo link works.
3. **Verified against the real AppImage** (v1.1.0, sha256
   `34794ff2a194db3bd311c108b3a7dfc96da77a8d55304f3adf8285822cfe5c99`):
   - type-2 AppImage (magic `AI\x02`), SquashFS — OK per their checklist
   - contains `deemusiq.desktop` (`Name=DeeMusiq`, matching the data
     filename) and `deemusiq.png` at the AppDir root
4. **Known risks for their automated test** — check the bot's comment on
   the PR and be ready to fix upstream in the AppImage packaging:
   - the app must show its **main window within 30 s without network**;
     a streaming app that blocks on connectivity fails the screenshot
     test. If it fails, the AppImage build needs an offline-capable
     first screen.
   - the embedded desktop file has no `Comment=`/`StartupNotify=` —
     cosmetic, but tightening it to match the deb's launcher costs
     nothing.
   - they test on X11 only; Flutter defaults to X11 there anyway.
   - an AppStream metainfo file in `usr/share/metainfo/` is optional
     but gives you a proper screenshot/description on the listing.

## Open the PR

1. Fork https://github.com/AppImage/appimage.github.io.
2. Add **exactly one file** at `data/DeeMusiq` (their CI fails PRs that
   touch anything else):
   ```bash
   git clone git@github.com:<you>/appimage.github.io.git
   cd appimage.github.io
   cp /path/to/distribution/appimagehub/DeeMusiq data/DeeMusiq
   git add data/DeeMusiq
   git commit -m "Add DeeMusiq"
   git push origin master   # then open the PR from your fork
   ```
   Or use their web shortcut:
   https://github.com/AppImage/appimage.github.io/new/master/data
3. In the PR body: note DeeMusiq is a BSD-4-Clause rebrand of Spotube,
   homepage https://deemusiq.co.za, source
   https://github.com/deemusiq/deemusiq.
4. The bot runs immediately and posts either a screenshot (pass,
   `screenshot-ok` label) or an `error-*` label with a hint. Comment
   `/retest` after publishing a fix release; a comment like
   "fixed in 1.1.1" also re-triggers the test automatically.
5. Maintainer merge is manual — **days to a few weeks**. Nothing else is
   needed from you meanwhile.

## Updating later

Nothing, usually: the entry tracks "the newest release" forever. Only
re-open a PR if the AppImage download location or the app name changes.
