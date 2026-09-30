# Self-hosted F-Droid repository for DeeMusiq

Publish your own F-Droid repo so users can install and **auto-update** DeeMusiq
through the F-Droid client today, straight from the APKs already attached to
GitHub Releases — no Play Store, no waiting on the official-repo review.

Users add one repo URL (or scan one QR code), and every `DeeMusiq.apk` you
attach to a `v*` GitHub Release shows up as an update in their F-Droid client.

---

## Option A — fdroidserver (full control, recommended)

### 1. Install

```bash
sudo apt install fdroidserver android-sdk
# or: pip install fdroidserver
```

### 2. Initialise the repo

```bash
mkdir deemusiq-fdroid && cd deemusiq-fdroid
fdroid init
```

Edit `config.yml` that `fdroid init` generated:

```yaml
repo_url: https://deemusiq.co.za/fdroid/repo
repo_name: DeeMusiq
repo_icon: fdroid-icon.png
repo_description: |
    DeeMusiq — African music streaming. It's a drop day.
    Artists keep ownership and get paid fairly.
archive_older: 3
```

### 3. Drop in APKs and update the index

Pull the APK from the latest GitHub Release (the same one CI attaches):

```bash
mkdir -p repo
curl -L -o repo/DeeMusiq.apk \
  https://github.com/deemusiq/deemusiq/releases/download/v1.1.0/DeeMusiq.apk

fdroid update --create-metadata   # first run creates metadata template
fdroid update                     # subsequent runs just re-index
```

`fdroid update` builds `repo/index-v2.json`, the signed index, and per-app
metadata. Re-run it every time you add a new release APK. This is easy to wire
into CI as a post-release job.

### 4. Signing

On first run, `fdroid init` generates a **repo signing key** in `keystore.jks`
(plus `config.yml` entries). This key is your repo's identity:

- Back it up like a release signing key. Losing it = every user must remove
  and re-add the repo.
- The repo's **fingerprint** (shown by `fdroid update` output and stored in
  the index) is what users verify when adding the repo.

### 5. Host it

The whole `repo/` directory is static files. Two easy targets:

- **Same domain**: rsync `repo/` to your web server at
  `https://deemusiq.co.za/fdroid/repo/` (same nginx that serves
  `/downloads/*`). Users add `https://deemusiq.co.za/fdroid/repo`.
- **GitHub Pages**: push `repo/` to a `fdroid-repo` branch/repo with Pages
  enabled → `https://deemusiq.github.io/fdroid/repo`.

Either way the URL must be **HTTPS** — F-Droid clients refuse plain HTTP.

### 6. Fingerprint + QR code

```bash
fdroid update   # prints the repo fingerprint, e.g.:
# Fingerprint: AB12 CD34 ... (SHA-256 of the repo signing cert)
```

Generate the add-repo QR code users can scan in the F-Droid client:

```bash
# The QR encodes: https://deemusiq.co.za/fdroid/repo?fingerprint=<FINGERPRINT>
qrencode -o repo-qr.png \
  "https://deemusiq.co.za/fdroid/repo?fingerprint=<FINGERPRINT_HEX_NO_SPACES>"
```

Put `repo-qr.png` and the fingerprint (as text, for manual entry) on the
downloads page next to the APK link.

---

## Option B — Repomaker (web UI, low effort)

[Repomaker](https://gitlab.com/fdroid/repomaker) is a hosted-style web app for
running an F-Droid repo without the CLI:

1. `pip install repomaker` (or run the Docker image).
2. Create a repo in the web UI, upload `DeeMusiq.apk` from each GitHub
   Release.
3. Repomaker hosts the static repo itself and shows the repo URL +
   fingerprint + QR code on the repo page.
4. Point a subdomain (e.g. `fdroid.deemusiq.co.za`) at it, or reverse-proxy it
   from your main domain.

Good for getting something live in an afternoon; fdroidserver is better for
CI-driven releases long-term.

---

## The trust caveat — tell users this

A self-hosted repo means **users trust DeeMusiq's signing keys directly**,
with no F-Droid.org review or rebuild in the middle:

- Updates install only if the APK signature matches what they first installed
  (standard Android behavior) — so they must install from *our* repo/APK first;
  an F-Droid.org build later would be signed differently and would not
  cross-update.
- The repo fingerprint is the out-of-band check: publish it on the downloads
  page **and** in the GitHub repo README so users can verify they added the
  genuine repo.
- Because the app pins its own APK hash (anti-tamper), the APK in this repo
  must be byte-identical to the GitHub Releases asset `DeeMusiq.apk` — do not
  re-sign or re-zipalign it.

---

## Ready-to-use repo description text

Short (for `repo_description` / store blurbs):

> DeeMusiq — African music streaming. It's a drop day. Artists keep ownership
> and get paid fairly. Official releases, straight from the source.

Long (for the downloads page):

> **DeeMusiq F-Droid repo** — install DeeMusiq with the F-Droid client and get
> every new drop as an automatic update. Add the repo by scanning the QR code
> or entering `https://deemusiq.co.za/fdroid/repo`, then verify the
> fingerprint shown there matches the one published on
> `github.com/deemusiq/deemusiq`. This repository is operated and signed by
> the DeeMusiq project itself; APKs are identical to the GitHub Releases
> assets.
