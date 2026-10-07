#!/usr/bin/env bash
# Post-build release verification — the last step before artifacts upload.
#
# Catches the failure classes that previously shipped silently:
#   • TLS pin missing from the binary (define typo / empty env) → app bricks
#     on the next edge-cert rotation
#   • channel key / payment HMAC define silently empty → checkouts fail closed
#   • APK signed by a different keystore than DEEMUSIQ_CERT_SHA256 pins
#     (e.g. secrets rotated mid-build) → app fails its own anti-tamper check
#   • APK sha256 sidecar disagreeing with the APK → integrity check chaos
#
# Presence checks grep the compiled bundle for the exact string WITHOUT
# printing it — these are compile-time values shipped in the binary anyway
# (accepted risk H4). Nothing secret is ever logged.
#
# Usage (from deemusiq-app/):  tool/verify_release.sh <android|linux|windows|macos>
# Inputs via env: DEEMUSIQ_BACKEND_URL DEEMUSIQ_CHANNEL_KEY
#                 DEEMUSIQ_PAYMENT_HMAC_SECRET DEEMUSIQ_CERT_SHA256 (android)
set -euo pipefail

PLATFORM="${1:?usage: verify_release.sh <android|linux|windows|macos>}"
fail=0

note() { printf '  %s\n' "$1"; }
ok()   { printf '  ✓ %s\n' "$1"; }
bad()  { printf '  ✗ %s\n' "$1" >&2; fail=1; }

# Current TLS pin(s): source of truth is server-tls-pins.txt (cert-pin-watch.yml
# rotates it); a 64-hex token per pin, comma-separated in the define.
TLS_PINS=$(grep -oiE '[0-9a-f]{64}' server-tls-pins.txt 2>/dev/null | tr 'A-F' 'a-f' | sort -u | paste -sd, - || true)

# Locate the compiled payload to grep.
PAYLOAD=""
PAYLOAD_TMP=""
cleanup() {
  # Must always return 0: with `set -e` the EXIT trap's status becomes the
  # script's exit code, and a false `[ -n ... ]` would turn a PASS into a
  # failed build on platforms that never populate PAYLOAD_TMP.
  if [ -n "$PAYLOAD_TMP" ]; then rm -f "$PAYLOAD_TMP"; fi
}
trap cleanup EXIT

case "$PLATFORM" in
  android)
    APK=$(ls dist/DeeMusiq.apk 2>/dev/null || ls build/app/outputs/flutter-apk/*release*.apk 2>/dev/null | head -1)
    [ -n "${APK:-}" ] || { bad "no APK found"; echo "$fail"; exit 1; }
    PAYLOAD_TMP=$(mktemp)
    unzip -p "$APK" lib/arm64-v8a/libapp.so > "$PAYLOAD_TMP"
    PAYLOAD="$PAYLOAD_TMP"
    ;;
  linux)   PAYLOAD="build/linux/x64/release/bundle" ;;
  windows) PAYLOAD="build/windows/x64/runner/Release" ;;
  macos)   PAYLOAD="build/macos/Build/Products/Release" ;;
esac

# contains <string> — true when the exact bytes appear anywhere in the payload.
contains() {
  if [ -d "$PAYLOAD" ]; then
    LC_ALL=C grep -rqlF "$1" "$PAYLOAD" 2>/dev/null
  else
    LC_ALL=C grep -qF "$1" "$PAYLOAD" 2>/dev/null
  fi
}

echo "== TLS pin baked =="
if [ -z "$TLS_PINS" ]; then
  note "server-tls-pins.txt empty — pin intentionally dormant, skipping"
else
  IFS=',' read -ra pins <<< "$TLS_PINS"
  for pin in "${pins[@]}"; do
    if contains "$pin"; then ok "pin present (${pin:0:12}…)"; else bad "TLS pin ${pin:0:12}… NOT in binary — define lost"; fi
  done
fi

echo "== Backend wiring baked =="
if [ -n "${DEEMUSIQ_BACKEND_URL:-}" ]; then
  host=$(printf '%s' "$DEEMUSIQ_BACKEND_URL" | sed -E 's|https?://([^/:]+).*|\1|')
  if contains "$host"; then ok "backend host baked"; else bad "backend host '$host' NOT in binary"; fi
else
  note "DEEMUSIQ_BACKEND_URL unset — offline-default build, skipping"
fi
if [ -n "${DEEMUSIQ_CHANNEL_KEY:-}" ]; then
  if contains "$DEEMUSIQ_CHANNEL_KEY"; then ok "channel key baked"; else bad "DEEMUSIQ_CHANNEL_KEY set but NOT in binary"; fi
fi
if [ -n "${DEEMUSIQ_PAYMENT_HMAC_SECRET:-}" ]; then
  if contains "$DEEMUSIQ_PAYMENT_HMAC_SECRET"; then ok "payment HMAC baked"; else bad "DEEMUSIQ_PAYMENT_HMAC_SECRET set but NOT in binary — checkouts would ship unsigned"; fi
fi

if [ "$PLATFORM" = "android" ]; then
  echo "== APK signing =="
  actual=$(python3 tool/verify_apk_signing.py "$APK") || { bad "could not parse APK signing block"; exit 1; }
  if [ -n "${DEEMUSIQ_CERT_SHA256:-}" ]; then
    if [ "$actual" = "$DEEMUSIQ_CERT_SHA256" ]; then
      ok "signing cert matches DEEMUSIQ_CERT_SHA256"
    else
      bad "signing cert $actual != pinned $DEEMUSIQ_CERT_SHA256 — the app would fail its own anti-tamper check (temp keystore?)"
    fi
  else
    note "DEEMUSIQ_CERT_SHA256 unset — informational only; actual signer: ${actual:0:16}…"
  fi
  if [ -f dist/DeeMusiq.apk.sha256 ]; then
    sidecar=$(awk '{print $1}' dist/DeeMusiq.apk.sha256)
    real=$(sha256sum "$APK" | awk '{print $1}')
    if [ "$sidecar" = "$real" ]; then ok "sha256 sidecar consistent"; else bad "sha256 sidecar mismatch"; fi
  fi
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "RELEASE VERIFICATION FAILED ($PLATFORM)" >&2
  exit 1
fi
echo "Release verification passed ($PLATFORM)"
