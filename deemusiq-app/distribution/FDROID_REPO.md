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

### 5. Host it — worker proxy to GitHub Releases (current setup, 2026-10-07)

The repo is **live-ready** at `https://deemusiq.co.za/fdroid/repo`, proxied by
the download worker (`deemusiq-site/cloudflare/worker.js`,
`serveFdroidFile`). Neither Cloudflare Pages (25 MB/file) nor GitHub Pages
(100 MB/file) can host the 122 MB APK, so the worker streams everything from
GitHub Releases instead:

- **Repo files** (index, entry point, icons, diffs) are flattened
  (`/` → `--`, `fdroid--` prefix, `=` stripped — GitHub removes base64
  padding from asset names) and attached to the machine-managed **`fdroid`
  release tag** on `deemusiq/deemusiq`. That tag is file storage, not an app
  release.
- **APKs** are NOT on the `fdroid` tag — the worker streams them from the
  latest app release, so they stay byte-identical to `/downloads/android`
  (the signed index pins their hashes; a re-signed APK would fail installs).

Working repo checkout: `~/fdroid-work` (config.yml, keystore.p12 — **the repo
signing identity, back it up**; losing it = every user must re-add the repo).
fdroidserver lives in `~/fdroid-venv`, build-tools in `~/android-sdk`,
a full JDK (for `jar`) in `~/jdk`.

Repo fingerprint (users verify this when adding the repo):

```
4C35 C0EE EDCA E6B2 EEAA DB32 A53F 6890 E9E7 8D37 D187 7A74 573C 4F7D 8CEF 40D8
```

**Publish flow on each app release** (after CI attaches `DeeMusiq.apk` to the
new `v*` release):

```bash
cd ~/fdroid-work
export ANDROID_HOME=~/android-sdk PATH="$HOME/jdk/bin:$PATH"
curl -L -o repo/DeeMusiq.apk \
  https://github.com/deemusiq/deemusiq/releases/latest/download/DeeMusiq.apk
~/fdroid-venv/bin/fdroid update        # re-indexes + re-signs
cd repo && find . -type f ! -name 'DeeMusiq.apk' ! -path './status/*' | while read -r f; do
  rel="${f#./}"
  flat="fdroid--$(printf '%s' "${rel//\//--}" | tr -d '=')"   # GitHub strips "=" from asset names
  cp "$f" "/tmp/$flat"
done
cd /tmp && gh release upload fdroid ./fdroid--* --clobber --repo deemusiq/deemusiq
rm -f /tmp/fdroid--*
```

The worker itself deploys with `wrangler deploy` from
`deemusiq-site/cloudflare/` (routes for `/fdroid/*` are in `wrangler.toml`;
see `cloudflare/RELEASE.md`).

### 6. Fingerprint + QR code

A ready QR encoding
`https://deemusiq.co.za/fdroid/repo?fingerprint=4C35C0EEEDCAE6B2EEAADB32A53F6890E9E78D37D1877A74573C4F7D8CEF40D8`
is at `~/fdroid-work/repo-qr.png`. Regenerate after any repo-key change with:

```bash
~/fdroid-venv/bin/python -c "import qrcode; qrcode.make('<url>').save('repo-qr.png')"
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
