# DRAFT — Homebrew cask for DeeMusiq (macOS).
#
# USER MUST FILL:
#   * sha256 — sha256 of DeeMusiq-macos-universal.dmg from the v1.1.0
#     GitHub Release:  shasum -a 256 DeeMusiq-macos-universal.dmg
#   * Confirm the url matches the real published asset (CI deemusiq-macos.yml
#     produces dist/DeeMusiq-macos-universal.dmg).
#   * `livecheck`/`zap` paths — verify the app's real support directories on
#     a macOS machine before submitting.

cask "deemusiq" do
  version "1.1.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/deemusiq/deemusiq/releases/download/v#{version}/DeeMusiq-macos-universal.dmg"
  name "DeeMusiq"
  desc "African music streaming — it's a drop day; artists keep ownership and get paid fairly"
  homepage "https://deemusiq.co.za"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "DeeMusiq.app"

  # DRAFT — verify these paths on a real install before submitting:
  zap trash: [
    "~/Library/Application Support/za.co.deemusiq.app",
    "~/Library/Caches/za.co.deemusiq.app",
    "~/Library/Preferences/za.co.deemusiq.app.plist",
  ]

  caveats <<~EOS
    DeeMusiq is not notarized. On first launch: right-click DeeMusiq.app →
    Open, or run:
      xattr -cr /Applications/DeeMusiq.app
  EOS
end
