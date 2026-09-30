# Submitting DeeMusiq to winget (microsoft/winget-pkgs)

Manifest drafts (this directory):

- `DeeMusiq.DeeMusiq.yaml` — version manifest
- `DeeMusiq.DeeMusiq.installer.yaml` — installer manifest (NSIS, x64)
- `DeeMusiq.DeeMusiq.locale.en-US.yaml` — metadata/locale manifest

## Fill first

- **InstallerSha256** in the installer manifest — hash the real
  `DeeMusiq-windows-x86_64-setup.exe` from the `v1.1.0` GitHub Release:
  ```powershell
  certutil -hashfile DeeMusiq-windows-x86_64-setup.exe SHA256
  ```
- Confirm the `InstallerUrl` matches the published asset name (CI:
  `deemusiq-windows.yml` → `dist/DeeMusiq-windows-x86_64-setup.exe`).

## Submit with wingetcreate (the supported path)

```powershell
winget install wingetcreate   # or download from microsoft/winget-create releases

# Easiest: let wingetcreate generate from the real URL, then diff against
# these drafts and keep our metadata:
wingetcreate new https://github.com/deemusiq/deemusiq/releases/download/v1.1.0/DeeMusiq-windows-x86_64-setup.exe

# Or submit the pre-filled drafts directly:
wingetcreate submit <path-to-this-winget-folder>
```

`wingetcreate submit` forks `microsoft/winget-pkgs` under your GitHub account,
places the manifests at
`manifests/d/DeeMusiq/DeeMusiq/1.1.0/`, and opens the PR for you
(GitHub token with `public_repo` scope required when prompted).

## Validate locally before submitting

```powershell
winget validate --manifest <path-to-this-winget-folder>
winget install --manifest <path-to-this-winget-folder>   # smoke-test install
```

## What happens next

- Microsoft validation pipeline runs automatically (installer download,
  hash match, smartscreen, silent-install check). NSIS installers pass
  cleanly when `/S` silent install works — verify the packaging
  `installer.nsi` supports it.
- A moderator reviews new packages; expect **a few days to ~2 weeks**.
- After merge: `winget install DeeMusiq.DeeMusiq` works within ~a day.

## Updating later

```powershell
wingetcreate update DeeMusiq.DeeMusiq --version 1.1.1 --urls <new-setup.exe-url> --submit
```
