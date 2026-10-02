#!/usr/bin/env bash
#
# DeeMusiq — Linux AppImage build + verification pipeline.
#
# WHY THIS EXISTS
# ---------------
# A Flutter Linux release is not a single binary: the runner resolves almost
# everything *relative to the executable*, i.e. it needs
#
#   <dir-of-executable>/data/flutter_assets/**     (Dart assets)
#   <dir-of-executable>/data/icudtl.dat            (ICU data)
#   <dir-of-executable>/lib/libapp.so              (AOT snapshot)
#   <dir-of-executable>/lib/libflutter_linux_gtk.so + plugin .so files
#
# An AppDir that ships `usr/bin/deemusiq` but forgets `usr/bin/data` or
# `usr/bin/lib` still launches a window and then dies with
#
#   Failed to start Flutter engine: Failed to create AOT data
#   gtk.dart: failed to call method: No engine to send to
#
# So this script builds the bundle, assembles the AppDir exactly the way the
# Flutter embedder expects it, packs the image, and then *verifies* the packed
# result (layout + AOT digest + headless smoke run). A regression fails the
# build instead of shipping a broken download.
#
# USAGE
#   scripts/build-linux-appimage.sh                  # build, pack, verify, smoke
#   scripts/build-linux-appimage.sh --skip-build     # re-pack the existing bundle
#   scripts/build-linux-appimage.sh --no-smoke       # no Xvfb smoke run
#   scripts/build-linux-appimage.sh --skip-deps      # don't bundle system libs
#   scripts/build-linux-appimage.sh --verify-only dist/DeeMusiq-linux-x86_64.AppImage
#   scripts/build-linux-appimage.sh --dart-define=APP_ENV=dev --dart-define=A=B
#
# ENVIRONMENT
#   FLUTTER, APPIMAGETOOL, LINUXDEPLOY   explicit tool paths
#   ARCH=x64|arm64, DIST_DIR, OUTPUT_NAME, WORK_DIR, SMOKE_TIMEOUT
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$APP_DIR/.." && pwd)"

ARCH="${ARCH:-x64}"
BUNDLE_DIR="$APP_DIR/build/linux/$ARCH/release/bundle"
DIST_DIR="${DIST_DIR:-$REPO_ROOT}"
OUTPUT_NAME="${OUTPUT_NAME:-DeeMusiq-linux-x86_64.AppImage}"
OUTPUT="$DIST_DIR/$OUTPUT_NAME"
WORK_DIR="${WORK_DIR:-${TMPDIR:-/tmp}/deemusiq-appimage-build}"
APPDIR="$WORK_DIR/AppDir"
SMOKE_TIMEOUT="${SMOKE_TIMEOUT:-25}"

SKIP_BUILD=0
SKIP_SMOKE=0
SKIP_DEPS=0
VERIFY_ONLY=""
DEFINES=()

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-build) SKIP_BUILD=1 ;;
    --no-smoke) SKIP_SMOKE=1 ;;
    --skip-deps) SKIP_DEPS=1 ;;
    --verify-only)
      [ $# -ge 2 ] || die "--verify-only needs a path"
      VERIFY_ONLY="$2"
      shift
      ;;
    --output)
      [ $# -ge 2 ] || die "--output needs a path"
      OUTPUT="$2"
      shift
      ;;
    --dart-define=*) DEFINES+=("$1") ;;
    --dart-define)
      [ $# -ge 2 ] || die "--dart-define needs KEY=VALUE"
      DEFINES+=("--dart-define=$2")
      shift
      ;;
    -h|--help)
      sed -n '2,40p' "$0"
      exit 0
      ;;
    *) die "unknown argument: $1" ;;
  esac
  shift
done

resolve_tool() {
  # $1 = tool name on PATH, $2 = env var with an explicit path
  local name="$1" envname="$2" explicit="" candidate=""
  eval "explicit=\${$envname:-}"
  if [ -n "$explicit" ]; then
    [ -x "$explicit" ] || die "$envname=$explicit is not executable"
    printf '%s\n' "$explicit"
    return 0
  fi
  for candidate in \
    "$(command -v "$name" 2>/dev/null || true)" \
    "$REPO_ROOT/.tools/$name" \
    "$HOME/tools/$name"; do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 0
}

resolve_flutter() {
  local explicit="${FLUTTER:-}" candidate=""
  if [ -n "$explicit" ]; then
    [ -x "$explicit" ] || die "FLUTTER=$explicit is not executable"
    printf '%s\n' "$explicit"
    return 0
  fi
  for candidate in \
    "$(command -v flutter 2>/dev/null || true)" \
    "$HOME/flutter/bin/flutter" \
    /opt/flutter/bin/flutter; do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 0
}

# ---------------------------------------------------------------- build -----

build_bundle() {
  local flutter_bin="$1"
  [ -n "$flutter_bin" ] || die "flutter not found — install it or set FLUTTER=/path/to/flutter"
  if [ -f "$APP_DIR/.fvmrc" ]; then
    log "Project pins Flutter $(sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' "$APP_DIR/.fvmrc") (FVM); using $flutter_bin"
  fi
  log "flutter build linux --release ${DEFINES[*]:-}"
  ( cd "$APP_DIR" && "$flutter_bin" build linux --release ${DEFINES[@]+"${DEFINES[@]}"} )
}

REQUIRED_BUNDLE_FILES=(
  "deemusiq"
  "data/icudtl.dat"
  "data/flutter_assets/AssetManifest.bin"
  "data/flutter_assets/version.json"
  "lib/libapp.so"
  "lib/libflutter_linux_gtk.so"
)

check_bundle() {
  [ -d "$BUNDLE_DIR" ] || die "no Linux bundle at $BUNDLE_DIR (run without --skip-build)"
  local rel=""
  for rel in "${REQUIRED_BUNDLE_FILES[@]}"; do
    [ -f "$BUNDLE_DIR/$rel" ] ||
      die "bundle is incomplete: $BUNDLE_DIR/$rel is missing (a Debug bundle has no libapp.so — always build --release)"
  done
  [ -x "$BUNDLE_DIR/deemusiq" ] || die "bundle executable is not executable: $BUNDLE_DIR/deemusiq"
  log "Bundle looks complete ($(du -sh "$BUNDLE_DIR" | cut -f1) at $BUNDLE_DIR)"
}

# --------------------------------------------------------------- AppDir -----

assemble_appdir() {
  log "Assembling AppDir at $APPDIR"
  rm -rf "$APPDIR"
  mkdir -p "$APPDIR/usr/bin" \
           "$APPDIR/usr/lib" \
           "$APPDIR/usr/share/applications" \
           "$APPDIR/usr/share/icons/hicolor/256x256/apps"

  # The whole bundle lands under usr/bin so that <exe>/data and <exe>/lib keep
  # the layout the Flutter engine resolves at runtime. This single line is the
  # difference between a working AppImage and "Failed to create AOT data".
  cp -a "$BUNDLE_DIR/." "$APPDIR/usr/bin/"

  local desktop="$APP_DIR/linux/deemusiq.desktop"
  [ -f "$desktop" ] || die "missing desktop entry: $desktop"
  cp "$desktop" "$APPDIR/usr/share/applications/deemusiq.desktop"

  local icon="$APP_DIR/assets/branding/deemusiq-logo.png"
  [ -f "$icon" ] || icon="$APP_DIR/assets/branding/spotube-logo.png"
  [ -f "$icon" ] || die "no application icon found under assets/branding"
  cp "$icon" "$APPDIR/usr/share/icons/hicolor/256x256/apps/deemusiq-icon.png"

  ln -sf usr/share/applications/deemusiq.desktop "$APPDIR/deemusiq.desktop"
  ln -sf usr/share/icons/hicolor/256x256/apps/deemusiq-icon.png "$APPDIR/deemusiq-icon.png"
  ln -sf deemusiq-icon.png "$APPDIR/.DirIcon"

  cat > "$APPDIR/AppRun" <<'APPRUN'
#!/bin/sh
# DeeMusiq AppRun.
#
# media_kit's Linux plugin dlopen()s libmpv.so.1 from inside the plugin, so the
# loader consults LD_LIBRARY_PATH — not the runner's RUNPATH. Exporting the two
# bundled library directories keeps bundled playback working on hosts that have
# no mpv/ffmpeg/GTK stack of their own.
set -eu
APPDIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export LD_LIBRARY_PATH="$APPDIR/usr/bin/lib:$APPDIR/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="$APPDIR/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
exec "$APPDIR/usr/bin/deemusiq" "$@"
APPRUN
  chmod 0755 "$APPDIR/AppRun"
}

deploy_runtime_deps() {
  local linuxdeploy_bin="$1"
  if [ -z "$linuxdeploy_bin" ]; then
    warn "linuxdeploy not found — the AppImage will use the host's GTK/mpv/ffmpeg libraries"
    return 0
  fi
  log "Deploying runtime dependencies with $linuxdeploy_bin"
  APPIMAGE_EXTRACT_AND_RUN=1 "$linuxdeploy_bin" \
    --appdir "$APPDIR" \
    --executable "$APPDIR/usr/bin/deemusiq" \
    --library "$APPDIR/usr/bin/lib/libflutter_linux_gtk.so" \
    --library "$APPDIR/usr/bin/lib/libmedia_kit_libs_linux_plugin.so" \
    --library "$APPDIR/usr/bin/lib/libsqlite3_flutter_libs_plugin.so" \
    --library "$APPDIR/usr/bin/lib/libflutter_secure_storage_linux_plugin.so" \
    --library "$APPDIR/usr/bin/lib/libflutter_discord_rpc.so" \
    --library "$APPDIR/usr/bin/lib/libmetadata_god.so" \
    --library "$APPDIR/usr/bin/lib/libdesktop_webview_window_plugin.so" \
    || die "linuxdeploy failed to collect runtime dependencies"
}

pack_appimage() {
  local appimagetool_bin="$1"
  [ -n "$appimagetool_bin" ] || die "appimagetool not found — install it or set APPIMAGETOOL=/path/to/appimagetool"
  log "Packing $OUTPUT"
  mkdir -p "$(dirname "$OUTPUT")"
  rm -f "$OUTPUT"
  APPIMAGE_EXTRACT_AND_RUN=1 ARCH=x86_64 "$appimagetool_bin" "$APPDIR" "$OUTPUT" >/dev/null ||
    die "appimagetool failed"
}

# ----------------------------------------------------------- verification ---

verify_appimage() {
  local image="$1"
  local extract_dir="$WORK_DIR/verify"
  [ -f "$image" ] || die "no AppImage to verify at $image"

  log "Verifying the packed layout of $(basename "$image")"
  rm -rf "$extract_dir"
  mkdir -p "$extract_dir"
  ( cd "$extract_dir" && APPIMAGE_EXTRACT_AND_RUN=1 "$image" --appimage-extract >/dev/null )
  local root="$extract_dir/squashfs-root"

  local rel=""
  for rel in \
    "AppRun" \
    "usr/bin/deemusiq" \
    "usr/bin/data/icudtl.dat" \
    "usr/bin/data/flutter_assets/AssetManifest.bin" \
    "usr/bin/data/flutter_assets/version.json" \
    "usr/bin/lib/libapp.so" \
    "usr/bin/lib/libflutter_linux_gtk.so"; do
    [ -e "$root/$rel" ] ||
      die "the AppImage is missing $rel — the Flutter engine would refuse to start (Failed to create AOT data)"
  done

  [ -x "$root/usr/bin/deemusiq" ] || die "usr/bin/deemusiq is not executable"
  [ -x "$root/AppRun" ] || die "AppRun is not executable"
  grep -q 'LD_LIBRARY_PATH' "$root/AppRun" ||
    die "AppRun does not export LD_LIBRARY_PATH (bundled mpv/GTK libs would be ignored)"
  cmp -s "$BUNDLE_DIR/lib/libapp.so" "$root/usr/bin/lib/libapp.so" ||
    die "libapp.so inside the AppImage differs from the AOT snapshot that was built"

  log "Layout OK — assets, ICU data and AOT snapshot are present and intact"
}

smoke_test() {
  local image="$1"
  local smoke_log="$WORK_DIR/smoke.log"
  if ! command -v xvfb-run >/dev/null 2>&1; then
    warn "xvfb-run not installed — skipping the headless smoke run"
    return 0
  fi

  log "Smoke running $(basename "$image") for ${SMOKE_TIMEOUT}s under Xvfb"
  if [ -e /dev/fuse ]; then
    set -- "$image"
  else
    set -- env APPIMAGE_EXTRACT_AND_RUN=1 "$image"
  fi

  local status=0
  set +e
  timeout "$SMOKE_TIMEOUT" xvfb-run -a "$@" >"$smoke_log" 2>&1 </dev/null
  status=$?
  set -e

  if grep -qE 'Failed to create AOT data|Failed to start Flutter engine|No engine to send to' "$smoke_log"; then
    sed -n '1,40p' "$smoke_log" >&2
    die "smoke test failed: the Flutter engine did not start"
  fi
  if grep -qE 'Failed to create GL context|Unable to create a GL context|Failed to initialize EGL|libGL error' "$smoke_log"; then
    # A machine without a GPU/GL driver (some CI runners) cannot open a window;
    # that is an environment limit, not a packaging defect, so do not fail here.
    warn "smoke run could not create a GL context in this environment — layout checks still passed"
    return 0
  fi
  # 124 = still running when the timeout hit, which is what a healthy GUI app does.
  if [ "$status" -ne 0 ] && [ "$status" -ne 124 ]; then
    sed -n '1,40p' "$smoke_log" >&2
    die "smoke test failed: exit status $status"
  fi
  log "Smoke test OK — engine started with no AOT/asset errors"
}

# -------------------------------------------------------------- main flow ---

if [ -n "$VERIFY_ONLY" ]; then
  verify_appimage "$VERIFY_ONLY"
  [ "$SKIP_SMOKE" -eq 1 ] || smoke_test "$VERIFY_ONLY"
  printf '\nVerified: %s\n' "$VERIFY_ONLY"
  exit 0
fi

if [ "$SKIP_BUILD" -eq 1 ]; then
  log "Reusing the existing bundle (--skip-build)"
else
  build_bundle "$(resolve_flutter)"
fi
check_bundle
assemble_appdir
[ "$SKIP_DEPS" -eq 1 ] || deploy_runtime_deps "$(resolve_tool linuxdeploy LINUXDEPLOY)"
pack_appimage "$(resolve_tool appimagetool APPIMAGETOOL)"
verify_appimage "$OUTPUT"
[ "$SKIP_SMOKE" -eq 1 ] || smoke_test "$OUTPUT"

sha256sum "$OUTPUT" > "$OUTPUT.sha256"
printf '\nDone: %s (%s)\n' "$OUTPUT" "$(du -h "$OUTPUT" | cut -f1)"
printf 'SHA-256: %s\n' "$(cut -d' ' -f1 < "$OUTPUT.sha256")"
