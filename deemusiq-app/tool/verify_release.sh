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
#   • Windows payload/installer missing a valid Authenticode signature, or
#     signed by two different identities → "Unknown publisher" / looks tampered
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
  # A release without a pin ships the app with NO MITM protection on the
  # backend, so this fails the build rather than warning: a green run must
  # mean the artifact is distributable.
  bad "server-tls-pins.txt empty — the TLS pin probe would ship dormant, leaving the backend with no MITM protection"
else
  IFS=',' read -ra pins <<< "$TLS_PINS"
  for pin in "${pins[@]}"; do
    if contains "$pin"; then ok "pin present (${pin:0:12}…)"; else bad "TLS pin ${pin:0:12}… NOT in binary — define lost"; fi
  done
fi

echo "== Pinned host baked =="
if [ -n "${DEEMUSIQ_PINNED_HOST:-}" ]; then
  if contains "$DEEMUSIQ_PINNED_HOST"; then ok "pinned host baked"; else bad "DEEMUSIQ_PINNED_HOST set but NOT in binary — pin cannot be located"; fi
else
  bad "DEEMUSIQ_PINNED_HOST unset — with a pin configured the probe cannot resolve a host and locks the wallet"
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

if [ "$PLATFORM" = "windows" ]; then
  echo "== Authenticode signing =="
  # Every shipped executable must carry a valid Authenticode signature. Unsigned
  # payloads show "Unknown publisher", and a payload/installer identity mismatch
  # reads as tampering, so both are checked.
  if ! command -v powershell.exe >/dev/null 2>&1; then
    bad "powershell.exe unavailable — cannot verify Authenticode signatures"
  else
    signed_ok=0
    unsigned=""
    # Payload binaries (always present at gate time) plus the installer, once
    # the packaging step has produced it.
    while IFS= read -r target; do
      [ -n "$target" ] || continue
      status=$(powershell.exe -NoProfile -NonInteractive -Command \
        "\$s = Get-AuthenticodeSignature -LiteralPath '$target'; \$s.Status" \
        | tr -d '\r')
      case "$status" in
        Valid) signed_ok=$((signed_ok + 1)) ;;
        *) unsigned="$unsigned\n  - $(basename "$target"): ${status:-NotSigned}" ;;
      esac
    done <<EOF
$(find build/windows/x64/runner/Release -maxdepth 1 -type f \
    \( -name '*.exe' -o -name '*.dll' \) 2>/dev/null; \
  ls dist/*.exe 2>/dev/null || true)
EOF
    if [ "$signed_ok" -gt 0 ]; then
      ok "$signed_ok binary/binaries carry a valid Authenticode signature"
    else
      # Fail closed: an empty scan must not read as "everything is signed".
      bad "no signed Windows binaries found — the signing step did not run or produced nothing"
    fi
    if [ -n "$unsigned" ]; then
      bad "unsigned or invalid Authenticode signature on:$unsigned"
    fi

    # Signer identity must match across payload and installer: users judge trust
    # by the publisher name, and a mismatch between the two is a red flag.
    subs=$(powershell.exe -NoProfile -NonInteractive -Command \
      "Get-ChildItem -Path 'build/windows/x64/runner/Release','dist' -Include *.exe -Recurse -File -ErrorAction SilentlyContinue |
         ForEach-Object { (Get-AuthenticodeSignature -LiteralPath \$_.FullName).SignerCertificate.Subject } |
         Where-Object { \$_ } | Sort-Object -Unique" | tr -d '\r' | grep -v '^$')
    count=$(printf '%s\n' "$subs" | grep -c . || true)
    if [ "${count:-0}" -gt 1 ]; then
      bad "multiple signer identities across binaries — a release must carry one:"
      printf '%s\n' "$subs" | sed 's/^/    /'
    elif [ "${count:-0}" -eq 1 ]; then
      ok "single signer identity: $(printf '%s' "$subs" | head -1)"
    fi
  fi
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "RELEASE VERIFICATION FAILED ($PLATFORM)" >&2
  exit 1
fi
echo "Release verification passed ($PLATFORM)"
