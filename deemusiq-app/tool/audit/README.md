# Person-like UI audit (AI + human)

Drives the **real Linux desktop build** of the app like a person: taps what a
person taps, types what a person types, flicks lists, and saves a PNG after
every step. Built for AI audits — run it, read the failing step + screenshot,
fix, re-run.

## Run

```bash
export PATH="$HOME/flutter/bin:$PATH"          # if flutter is not on PATH
./tool/audit/run_creator_audit.sh              # scenario A (email gate)
./tool/audit/run_creator_audit.sh --with-verify # + scenario B (emailed code)
```

Prerequisites: Flutter Linux toolchain deps, node, redis, backend
`node_modules` + generated prisma client. The runner starts the backend
itself (`npm run dev` with `REDIS_URL` forced so the "dev inbox" is shared);
override with `AUDIT_BACKEND_DIR` / `AUDIT_BACKEND_URL` if yours lives
elsewhere, or `AUDIT_KEEP_BACKEND=1` to keep it up afterwards.

## What each scenario proves

**A — creator email gate** (`creator_studio_audit_test.dart`)
1. First-run onboarding can be skipped.
2. Signed out, the Creator Studio shows the **email sign-in gate** and never
   the dashboard.
3. Signing in with a verified email + password account lands on **claim your
   artist name** (the creator sets the name).
4. After claiming: dashboard with stats, **submit-a-song** form (audio + cover
   pickers), and the **Get Verified** entry point.

**B — verify-email branch** (`verify_email_audit_test.dart`)
1. Device-only sign-in → the studio shows the **add email + password** gate
   with the consent checkbox.
2. After "Save & email code", the emailed 6-digit code unlocks the studio.
   The code is read from the **dev inbox** — the backend's own code issuer
   (`issueEmailCode`) re-mints it through `REDIS_URL`; a real person would
   read their mailbox instead.

## Evidence layout

```
build/audit/<run-id>/
├── 01_first_screen.png … 10_verification_page.png   # one per person-step
├── b01…b06_*.png                                     # scenario B steps
├── FAIL_*.png                                        # captured at the failing step
└── backend.log                                       # if the runner started it
```

`AUDIT_*` env vars (see `run_creator_audit.sh`) parameterise the account,
artist name, screenshot dir, and backend locations. App state is isolated per
run via `XDG_DATA_HOME` — every audit person is a fresh install.

## Known limits (not audited here)

- Native file-picker uploads (audio/cover) — the person picks real files; the
  harness stops at the form being present. Extend with a picker mock if
  uploads need UI-level cover.
- Screenshot capture is best-effort (largest repaint boundary, X11 `scrot`
  fallback); on Wayland-only sessions the state assertions still run and the
  PNG evidence may be absent — each skip is logged.
