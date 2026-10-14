#!/usr/bin/env bash
# DeeMusiq — person-like UI audit runner (Linux desktop).
#
# Boots (or reuses) a local backend, seeds a verified email account, then
# drives the REAL Flutter Linux build like a person: taps, typing, scrolls,
# and a PNG screenshot after every step. An AI can run this, read the failing
# step + screenshot, fix, and re-run — no human eyes required.
#
# Usage:
#   ./tool/audit/run_creator_audit.sh                 # scenario A (email gate)
#   ./tool/audit/run_creator_audit.sh --with-verify   # + scenario B (code entry)
#
# Env overrides:
#   AUDIT_BACKEND_DIR     backend checkout (default: sibling ../deemusiq-backend)
#   AUDIT_KEEP_BACKEND=1  leave the backend running after the audit
#   AUDIT_KEEP_SERVICES=1 leave the disposable postgres/redis running
#
# Everything the audit needs is disposable and isolated: its own podman
# postgres/redis, its own backend port (8099 — never touches a dev server on
# 8080), and its own app-state directory. Host services are deliberately NOT
# reused: this workstation's :5432 turned out to be a throwaway postgres in
# /tmp that lost its schema between runs.
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL_DIR="$APP_DIR/tool/audit"
BACKEND_DIR="${AUDIT_BACKEND_DIR:-}"
if [ -z "$BACKEND_DIR" ]; then
  # Sibling checkout layouts: <ws>/deemusiq/deemusiq-app → <ws>/deemusiq-backend
  # or <ws>/deemusiq/deemusiq-app → <ws>/deemusiq/backend
  for candidate in "$APP_DIR/../deemusiq-backend" "$APP_DIR/../../deemusiq-backend" "$APP_DIR/backend"; do
    if [ -d "$candidate/src" ]; then BACKEND_DIR="$(cd "$candidate" && pwd)"; break; fi
  done
fi
BACKEND_PORT="${AUDIT_BACKEND_PORT:-8099}"
BACKEND_URL="http://127.0.0.1:$BACKEND_PORT"
RUN_ID="$(date +%Y%m%d-%H%M%S)"
SHOTS="$APP_DIR/build/audit/$RUN_ID"
EMAIL="audit.$RUN_ID@example.test"
# No "audit" substring: the password policy rejects passwords containing the
# account's email, so the seed credentials stay lexically unrelated.
PASSWORD="Kite-Mango-$RUN_ID-Raft7"
ARTIST="Audit Artist $RUN_ID"
WITH_VERIFY="${1:-}"

command -v flutter >/dev/null || { echo "flutter is not on PATH"; exit 1; }
command -v node >/dev/null || { echo "node is not on PATH"; exit 1; }
if [ -z "$BACKEND_DIR" ] || [ ! -d "$BACKEND_DIR/src" ]; then
  echo "backend checkout not found (set AUDIT_BACKEND_DIR)"; exit 1
fi
mkdir -p "$SHOTS/appdata" "$SHOTS/config/dconf"
echo "audit run   : $RUN_ID"
echo "screenshots : $SHOTS"
echo "backend     : $BACKEND_URL ($BACKEND_DIR)"

BACKEND_STARTED=0
BACKEND_PGID=""
PG_CONTAINER="deemusiq-audit-pg"
REDIS_CONTAINER="deemusiq-audit-redis"
cleanup() {
  if [ "$BACKEND_STARTED" = "1" ] && [ "${AUDIT_KEEP_BACKEND:-0}" != "1" ] && [ -n "$BACKEND_PGID" ]; then
    kill -- "-$BACKEND_PGID" 2>/dev/null || true
  fi
  if [ "${AUDIT_KEEP_SERVICES:-0}" != "1" ]; then
    [ -n "${PG_STARTED:-}" ] && podman rm -f "$PG_CONTAINER" >/dev/null 2>&1 || true
    [ -n "${REDIS_STARTED:-}" ] && podman rm -f "$REDIS_CONTAINER" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

# ── disposable services (podman) ─────────────────────────────────────────────
# Fresh containers per run keep the audit deterministic: empty DB (the backend
# boot applies migrations itself) and a Redis the backend AND the harness both
# reach (the dev inbox for the emailed code).
command -v podman >/dev/null || { echo "podman is required for the disposable audit services"; exit 1; }
PG_CONTAINER="deemusiq-audit-pg"
REDIS_CONTAINER="deemusiq-audit-redis"

# A leftover app instance from a crashed/aborted audit still owns the
# za.co.deemusiq.app GApplication name on the session bus — every new launch
# then times out registering and exits code 1 (boot flake that is actually a
# stale-instance lock). Clear our own stale test binaries first.
pkill -9 -f "build/linux/x64/debug/bundle/deemusiq" 2>/dev/null || true
sleep 1
cleanup() {
  if [ "$BACKEND_STARTED" = "1" ] && [ "${AUDIT_KEEP_BACKEND:-0}" != "1" ]; then
    # tsx watch runs the server as a bare `node ... src/index.ts` child whose
    # argv matches no name pattern — kill whatever actually listens on the
    # audit port instead of guessing.
    local lpid
    lpid=$(ss -ltnp 2>/dev/null | grep ":$BACKEND_PORT" | grep -oP 'pid=\K[0-9]+' | head -1)
    [ -n "$lpid" ] && kill -9 "$lpid" 2>/dev/null || true
    [ -n "$BACKEND_PGID" ] && kill -- "-$BACKEND_PGID" 2>/dev/null || true
  fi
  if [ "${AUDIT_KEEP_SERVICES:-0}" != "1" ]; then
    podman rm -f "$PG_CONTAINER" >/dev/null 2>&1 || true
    podman rm -f "$REDIS_CONTAINER" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "services: fresh postgres + redis (podman, 127.0.0.1:55432 / :6399)"
podman rm -f "$PG_CONTAINER" "$REDIS_CONTAINER" >/dev/null 2>&1 || true
podman run -d --name "$PG_CONTAINER" \
  -e POSTGRES_USER=deemusiq -e POSTGRES_PASSWORD=deemusiq \
  -e POSTGRES_DB=deemusiq_audit \
  -p "127.0.0.1:55432:5432" docker.io/library/postgres:16-alpine >/dev/null || {
  echo "disposable postgres failed to start"; exit 1; }
podman run -d --name "$REDIS_CONTAINER" \
  -p "127.0.0.1:6399:6379" docker.io/library/redis:7-alpine >/dev/null || {
  echo "disposable redis failed to start"; exit 1; }
export PGPASSWORD=deemusiq
AUDIT_DB_URL="postgresql://deemusiq:deemusiq@127.0.0.1:55432/deemusiq_audit"
REDIS_AUDIT="redis://127.0.0.1:6399"
ok=""
for _ in $(seq 1 30); do
  pg_isready -h 127.0.0.1 -p 55432 >/dev/null 2>&1 && ok=1 && break
  sleep 1
done
[ -n "$ok" ] || { echo "disposable postgres never became ready"; exit 1; }
ok=""
for _ in $(seq 1 15); do
  redis-cli -u "$REDIS_AUDIT" ping 2>/dev/null | grep -q PONG && ok=1 && break
  sleep 1
done
[ -n "$ok" ] || { echo "disposable redis never became ready"; exit 1; }

if curl -sf -m 2 "$BACKEND_URL/health" >/dev/null 2>&1; then
  echo "refusing to start: something already listens on $BACKEND_PORT"
  echo "(set AUDIT_BACKEND_PORT=<free port> to move the audit backend)"
  exit 1
fi

echo "backend: starting fresh (npm run dev, audit DB + redis forced)"
(
  cd "$BACKEND_DIR" &&
  # Empty VAULT_* overrides: the dev .env points Vault at a docker hostname;
  # the audit host has no vault, so take the sanctioned local path (local
  # ENCRYPTION_KEY instead of Transit) instead of a fail-closed boot. dotenv
  # never overrides already-set (even empty) variables.
  setsid env VAULT_ADDR="" VAULT_TOKEN="" VAULT_ROLE_ID="" VAULT_SECRET_ID="" \
    DATABASE_URL="$AUDIT_DB_URL" REDIS_URL="$REDIS_AUDIT" PORT="$BACKEND_PORT" \
    npm run dev >"$SHOTS/backend.log" 2>&1 &
)
BACKEND_PGID="$(pgrep -f "npm run dev" | head -1 || true)"
BACKEND_STARTED=1
ok=""
for _ in $(seq 1 120); do
  if curl -sf -m 2 "$BACKEND_URL/health" >/dev/null 2>&1; then ok=1; break; fi
  sleep 1
done
if [ -z "$ok" ]; then
  echo "backend failed to start — log: $SHOTS/backend.log"
  tail -30 "$SHOTS/backend.log" || true
  exit 1
fi
echo "backend: up on $BACKEND_URL (migrations applied at boot)"

echo "seed: verified account $EMAIL"
(
  cd "$BACKEND_DIR" &&
  AUDIT_BACKEND_URL="$BACKEND_URL" DATABASE_URL="$AUDIT_DB_URL" \
    node "$TOOL_DIR/seed_audit_user.mjs" "$EMAIL" "$PASSWORD"
)

export AUDIT_BACKEND_URL="$BACKEND_URL"
export AUDIT_EMAIL="$EMAIL"
export AUDIT_EMAIL2="audit.attach.$RUN_ID@example.test"
export AUDIT_PASSWORD="$PASSWORD"
export AUDIT_ARTIST_NAME="$ARTIST"
export AUDIT_SHOTS="$SHOTS"
export AUDIT_BACKEND_DIR="$BACKEND_DIR"
export AUDIT_REDIS_URL="$REDIS_AUDIT"
export AUDIT_ABUSE_TS="file://$BACKEND_DIR/src/util/distributedAbuse.ts"
# Fresh app state per run — the audit person is a new install every time.
# shared_preferences on Linux reads XDG_DATA_HOME. Do NOT override HOME (the
# build shells out to cargo) and do NOT override XDG_CONFIG_HOME either: GTK
# plugins (titlebar_buttons, dconf) read the theme from there and a bare
# config dir makes them throw during layout, wedging the audit.
export XDG_CACHE_HOME="$SHOTS/appdata/cache"
export XDG_DATA_HOME="$SHOTS/appdata"

echo "scenario A: email gate -> sign in -> claim -> submit form"
# The Linux desktop build can segfault during native boot (tray/DBus/GTK on
# some sessions) before the VM service connects — an environment flake, not a
# flow failure. Only that specific "Unable to start the app on the device"
# tool exit is retried (3 attempts); a failed STEP inside the test is never
# retried, it is the audit finding itself.
run_flutter_test() {
  local test_file="$1" out
  out="$SHOTS/$(basename "$test_file" .dart).log"
  local attempt
  for attempt in 1 2 3; do
    # Stream live (tee) so the walk is observable, and remember the exit code.
    set +e
    (cd "$APP_DIR" &&
      env ${2:+AUDIT_EMAIL="$2"} flutter test "$test_file" \
        -d linux --dart-define="DEEMUSIQ_BACKEND_URL=$BACKEND_URL") 2>&1 | tee "$out"
    local rc=${PIPESTATUS[0]}
    set -e
    [ "$rc" = "0" ] && return 0
    # Boot flakes: the native side (tray/DBus/GTK under the test runner) can
    # die before the VM service connects ("Unable to start...") or seconds
    # into boot ("did not complete") — neither produces any [audit] evidence,
    # and neither is a flow failure. Retry those; never retry a step failure
    # (the walk produced audit output, i.e. the app was alive and the failure
    # is the finding).
    if ! grep -q "\[audit\] screenshot:" "$out" && {
       grep -q "Unable to start the app on the device" "$out" ||
       grep -q "did not complete" "$out"; }; then
      echo "  attempt $attempt: app died before any audit step (boot flake) — retrying"
      continue
    fi
    return 1
  done
  return 1
}
run_flutter_test integration_test/audit/creator_studio_audit_test.dart || {
  echo "scenario A failed — see $SHOTS"
  exit 1
}

if [ "$WITH_VERIFY" = "--with-verify" ]; then
  echo "scenario B: device -> attach email -> emailed code -> verified"
  B_EMAIL="audit.verify.$RUN_ID@example.test"
  # A separate app-state dir: a fresh device identity, so scenario B exercises
  # the add-email gate instead of landing on the dashboard scenario A claimed.
  XDG_DATA_HOME="$SHOTS/appdata-b" XDG_CACHE_HOME="$SHOTS/appdata-b/cache" \
    run_flutter_test integration_test/audit/verify_email_audit_test.dart "$B_EMAIL" || {
    echo "scenario B failed — see $SHOTS"
    exit 1
  }
fi

echo ""
echo "AUDIT PASSED — evidence in $SHOTS"
