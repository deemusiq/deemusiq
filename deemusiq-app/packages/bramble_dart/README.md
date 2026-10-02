# bramble_dart

A **clean-room** Dart implementation of the [Bramble](https://code.briarproject.org/briar/briar-spec)
protocols (the peer-to-peer transport family behind Briar), written **from the
publicly published protocol specifications only**. No Briar Java source code was
copied or consulted for this implementation.

## License boundary — read before linking

`bramble_dart` is licensed under the **GNU General Public License v3** (see
`LICENSE`). It is a deliberate copyleft island inside the DeeMusiq monorepo:

- **Do NOT import or link this package from the proprietary DeeMusiq app
  (`deemusiq-app`) without a license review.** GPL linking obligations would
  propagate to the app. The app does not depend on this package today; if a
  future milestone wants to use it, that integration must be decided
  explicitly (relicense, separation, or exception).
- Contributions to this package are GPL by definition.

## Milestone 1 scope (what exists today)

Per the [Bramble Handshake Protocol 0.1](https://code.briarproject.org/briar/briar-spec/-/raw/master/protocols/BHP.md)
specification (retrieved 2026-09-30; used as the single normative source):

- **Identity** (`lib/src/identity.dart`): long-term keypair generation —
  an Ed25519 signing pair and an X25519 agreement pair — plus deterministic
  regeneration from 32-byte seeds and base64 public-key encoding for
  out-of-band exchange (BHP §1.2 leaves the exchange channel to the caller).
- **Key agreement** (`lib/src/key_agreement.dart`): X25519 ECDH and the BHP
  framing functions — `HASH` (BLAKE2b-256 over length-prefixed arguments) and
  `KDF` (keyed BLAKE2b-256 as MAC) per BHP §1.4 — and the ephemeral master key
  derivation of BHP §2.3, including the all-zero shared-secret abort rule.
- **Handshake state machine** (`lib/src/handshake.dart`): BHP §2 record codec
  (4-byte header `int8(version) || int8(type) || int16be(len)`, 48 KiB payload
  cap) and the four-step Alice/Bob exchange, including `MINOR_VERSION` records
  (required — a peer that never sends one aborts the run), unknown-record-type
  tolerance for forward compatibility, and proof-of-ownership verification.
- **Transport abstraction** (`lib/src/transport.dart`): `TransportConnection`
  (bidirectional byte stream) and `TransportReader` (record framing) interfaces
  only — **no Bluetooth/WiFi transport ships in M1**. Tests use an in-memory
  pair.

### Deliberate simplifications / assumptions in M1

- BHP assigns Alice/Bob roles by lexicographic order of the long-term public
  keys "compared as byte strings" (§1.2). We use the **X25519 agreement public
  key** for this ordering; the Ed25519 signing key is identity material for
  later milestones (BSP signing) and is not used by BHP itself.
- The MINOR_VERSION record is sent immediately after each peer's
  EPHEMERAL_PUBLIC_KEY record (the spec mandates its receipt but not its
  position); readers accept it in any order.
- No read/write timeouts inside the state machine — callers wrap `run()` with
  their own deadline. M1 targets trusted, already-paired transports.
- Handshake errors are signaled with `BrambleHandshakeException`; the
  connection is closed on abort.

## Not in M1 (remaining milestones)

- **M2** — Bramble Transport Protocol (BTP) handshake/transport modes, stream
  segmentation and forward secrecy upgrade using the BHP master key.
- **M3** — Bramble Synchronisation Protocol (BSP) record exchange + the sync
  layer DeeMusiq needs for message/collection sharing.
- **M4** — Bluetooth transport (`TransportConnection` over RFCOMM/BLE) and QR
  bootstrap (Bramble QR Code Protocol) for key exchange.
- **M5** — Integration decision for DeeMusiq (subject to the GPL boundary
  above).

## Development

```bash
dart pub get
dart test
```

The package is intentionally standalone (no Flutter, no app imports) so it can
be extracted to its own repository later.
