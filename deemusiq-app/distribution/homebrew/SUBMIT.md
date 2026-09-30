# Submitting the DeeMusiq cask to homebrew-cask

Cask draft: `deemusiq.rb` (this directory).

## Fill first

1. **sha256** — hash the real DMG from the `v1.1.0` GitHub Release:
   ```bash
   curl -LO https://github.com/deemusiq/deemusiq/releases/download/v1.1.0/DeeMusiq-macos-universal.dmg
   shasum -a 256 DeeMusiq-macos-universal.dmg
   ```
2. Verify the `zap` paths against the app's real macOS support directories
   (the draft guesses them from the bundle/application id).
3. Sanity-check on a Mac:
   ```bash
   brew install --cask ./deemusiq.rb
   brew audit --cask --new deemusiq.rb   # must pass before the PR
   brew style --fix deemusiq.rb
   ```

## Notarisation gate (read this)

Homebrew cask policy requires apps to be **signed and notarized** for
`brew audit --new` to pass on recent macOS. The current CI DMG
(`deemusiq-macos.yml`) is unsigned — the cask includes a `caveats` quarantine
workaround, but homebrew-cask reviewers may still reject an unsigned new
cask. Two options:

- **Preferred**: add Apple Developer signing + notarization to the macOS CI
  workflow first, then submit.
- **Or** ship via a **tap** instead: `brew install deemusiq/tap/deemusiq`
  from a `deemusiq/homebrew-tap` repo — no notarization gate, works today.
  Copy `deemusiq.rb` to `Casks/deemusiq.rb` in that repo.

## Open the PR (homebrew-cask)

1. Fork `https://github.com/Homebrew/homebrew-cask`.
2. Place the cask at `Casks/d/deemusiq.rb` (first-letter subdirectory).
3. Commit message format: `deemusiq 1.1.0 (new cask)`.
4. Push and open the PR. In the body: link the homepage, the release, and
   note DeeMusiq is the BSD-4-Clause successor/rebrand of Spotube with a
   universal (Intel + Apple Silicon) DMG.
5. CI runs `brew audit`/`brew style` automatically; maintainers typically
   merge clean new casks within **days**.

## Updating later

```bash
brew bump-cask-pr --version 1.1.1 deemusiq
```

That command fetches the new DMG, recomputes the sha256, and opens the
version-bump PR automatically.
