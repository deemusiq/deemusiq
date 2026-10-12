#!/usr/bin/env bash
# Finalize a tag release: coordinate the four platform builds, deploy the
# download worker with fresh VERSIONS/RELEASES metadata, then verify the
# live download/update chain end-to-end.
#
# Subcommands (run by .github/workflows/release-finalize.yml):
#   check  <tag>  all four platform workflows succeeded for <tag>?
#   deploy <tag>  wrangler deploy with VERSIONS/RELEASES from the release
#   verify <tag>  version.json + every /downloads/<platform>[.sha256] live
#
# Required env: GH_TOKEN (check/deploy), CLOUDFLARE_API_TOKEN (deploy).
set -euo pipefail

CMD="${1:?usage: finalize-release.sh <check|deploy|verify> <tag>}"
TAG="${2:?usage: finalize-release.sh <check|deploy|verify> <tag>}"

WORKFLOWS=(
  "Build DeeMusiq (Android APK)"
  "Build DeeMusiq (Windows)"
  "Build DeeMusiq (macOS)"
  "Build DeeMusiq (Linux)"
)
PLATFORMS=(android linux windows macos)
SIDECAR_DIR="$RUNNER_TEMP/sidecars"

# platform → release asset whose .sha256 sidecar pins the download
asset_for() {
  case "$1" in
    android) echo "DeeMusiq.apk" ;;
    linux)   echo "DeeMusiq-linux-x86_64.AppImage" ;;
    windows) echo "DeeMusiq-windows-x86_64-setup.exe" ;;
    macos)   echo "DeeMusiq-macos-universal.dmg" ;;
    *) return 1 ;;
  esac
}

version_parts() {
  # Sets VERSION_NAME and BUILD_NUMBER from pubspec.yaml AT THE TAG.
  local line
  line=$(git show "$TAG:deemusiq-app/pubspec.yaml" | grep -E '^version:')
  line=${line#version: }
  VERSION_NAME=${line%%+*}
  BUILD_NUMBER=${line##*+}
  if [ -z "$VERSION_NAME" ] || [ -z "$BUILD_NUMBER" ] || [ "$BUILD_NUMBER" = "$VERSION_NAME" ]; then
    echo "::error::could not parse version line '$line' at $TAG" >&2
    exit 1
  fi
}

download_sidecars() {
  mkdir -p "$SIDECAR_DIR"
  gh release download "$TAG" --pattern "*.sha256" --dir "$SIDECAR_DIR" --clobber
  for p in "${PLATFORMS[@]}"; do
    [ -s "$SIDECAR_DIR/$(asset_for "$p").sha256" ] || {
      echo "::error::release $TAG is missing $(asset_for "$p").sha256" >&2
      exit 1
    }
  done
}

sidecar_digest() {
  grep -oE '[0-9a-f]{64}' "$SIDECAR_DIR/$(asset_for "$1").sha256" | head -1
}

case "$CMD" in
  check)
    # Latest run per platform workflow for this tag. All must exist with
    # conclusion=success. Still-running builds exit quietly — the last
    # completing workflow re-triggers this job.
    runs=$(gh run list --branch "$TAG" --limit 40 --json workflowName,status,conclusion,createdAt)
    pending=0
    for wf in "${WORKFLOWS[@]}"; do
      row=$(python3 -c "
import json, sys
runs = json.loads(sys.argv[1])
mine = [r for r in runs if r['workflowName'] == sys.argv[2]]
if not mine: print('missing'); raise SystemExit
latest = sorted(mine, key=lambda r: r['createdAt'])[-1]
print(latest['status'] + ':' + str(latest['conclusion']))
" "$runs" "$wf")
      case "$row" in
        completed:success) echo "  ✓ $wf" ;;
        missing) echo "::notice::$wf has not run for $TAG yet"; pending=1 ;;
        completed:*) echo "::error::$wf ended as $row — fix and re-run before finalizing $TAG"; exit 1 ;;
        *) echo "::notice::$wf still $row"; pending=1 ;;
      esac
    done
    if [ "$pending" -ne 0 ]; then
      echo "::notice::waiting for remaining builds — this job re-fires on each completion"
      exit 0
    fi
    ;;

  deploy)
    [ -n "${CLOUDFLARE_API_TOKEN:-}" ] || { echo "::error::CLOUDFLARE_API_TOKEN secret is not set"; exit 1; }
    version_parts
    download_sidecars

    VERSIONS=$(python3 -c "
import json
print(json.dumps({p: '$VERSION_NAME' for p in ['android','linux','windows','macos']}, separators=(',', ':')))")

    RELEASES=$(python3 - <<PYEOF
import json
out = {}
for p, digest in {
$(for p in "${PLATFORMS[@]}"; do echo "    '$p': '$(sidecar_digest "$p")',"; done)
}.items():
    out[p] = {
        'version': '$VERSION_NAME',
        'build_number': int('$BUILD_NUMBER'),
        'download_url': f'https://deemusiq.co.za/downloads/{p}',
        'sha256': digest,
    }
print(json.dumps(out, separators=(',', ':')))
PYEOF
)

    echo "Deploying worker for $TAG ($VERSION_NAME+$BUILD_NUMBER)"
    cd deemusiq-site/cloudflare
    npx --yes wrangler@latest deploy \
      --var "VERSIONS:$VERSIONS" \
      --var "RELEASES:$RELEASES"
    ;;

  verify)
    version_parts
    download_sidecars

    # Edge cache on version.json / sidecars is up to 5 minutes — poll until
    # the freshly deployed metadata shows up instead of failing on a stale hit.
    deadline=$(( $(date +%s) + 600 ))
    while true; do
      body=$(curl -fsS --max-time 20 https://deemusiq.co.za/downloads/version.json) || body=""
      stale=0
      for p in "${PLATFORMS[@]}"; do
        echo "$body" | python3 -c "
import json, sys
data = json.load(sys.stdin)
ok = data.get('versions', {}).get('$p') == '$VERSION_NAME' \
     and data.get('releases', {}).get('$p', {}).get('build_number') == int('$BUILD_NUMBER')
sys.exit(0 if ok else 1)
" || stale=1
      done
      [ "$stale" -eq 0 ] && break
      if [ "$(date +%s)" -ge "$deadline" ]; then
        echo "::error::version.json did not converge to $VERSION_NAME+$BUILD_NUMBER within 10 minutes: $body"
        exit 1
      fi
      sleep 30
    done
    echo "  ✓ version.json serves $VERSION_NAME+$BUILD_NUMBER for all platforms"

    for p in "${PLATFORMS[@]}"; do
      want=$(sidecar_digest "$p")
      got=$(curl -fsS --max-time 20 "https://deemusiq.co.za/downloads/$p.sha256" | grep -oE '[0-9a-f]{64}' | head -1 || true)
      if [ "$got" != "$want" ]; then
        echo "::error::/downloads/$p.sha256 ($got) != published sidecar ($want)"
        exit 1
      fi
      code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 30 -r 0-0 "https://deemusiq.co.za/downloads/$p")
      if [ "$code" != "200" ] && [ "$code" != "206" ]; then
        echo "::error::/downloads/$p answered HTTP $code"
        exit 1
      fi
      echo "  ✓ /downloads/$p live, sidecar matches release"
    done
    echo "Release $TAG verified end-to-end."
    ;;

  *)
    echo "unknown subcommand: $CMD" >&2
    exit 2
    ;;
esac
