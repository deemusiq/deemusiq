DeeMusiq — required store listing screenshots
=============================================

We cannot generate real screenshots from this environment, so this file lists
exactly what must be captured and where each file goes. Use a real device or
the emulator at 1080x2400 (or any 20:9 phone resolution), stableFdroid or
stablePlaystore release build, light theme preferred for consistency.

Fastlane/F-Droid phone screenshot directory:

  metadata/android/en-US/images/phoneScreenshots/

File naming: 01.png ... 05.png (PNG, min 320px, max 3840px on the long edge,
16:9 or 9:16 aspect per F-Droid / Google Play rules).

Shot list (5 shots):

  01.png  Home / African catalog
          Caption: "The sound of the continent, front and centre"
          Screen: Home feed showing the African catalog rows and drop-day
          new releases.

  02.png  Player
          Caption: "Now playing — synced lyrics, zero ads"
          Screen: Full player with album art, progress bar and the
          time-synced lyrics panel open.

  03.png  Wallet / top-up
          Caption: "Top up your wallet, support artists directly"
          Screen: Wallet screen showing token balance and the top-up
          options (voucher / EFT / card as available).

  04.png  Artist dashboard
          Caption: "Artists keep ownership and see every cent"
          Screen: Artist dashboard with plays, earnings graph and payout
          history.

  05.png  Offline downloads / library
          Caption: "Download and listen off the grid"
          Screen: Library showing downloaded tracks with the offline
          indicator, ideally on a playlist of South African artists.

Also needed (place alongside phoneScreenshots/):

  icon.png          512x512 app icon (copy from assets/ brand resources)
  featureGraphic.png  1024x500 Google Play feature graphic — tagline
                    "It's a drop day." on brand background.

Do NOT commit placeholder images here — stores reject obviously fake
screenshots and it hurts the F-Droid inclusion review.
