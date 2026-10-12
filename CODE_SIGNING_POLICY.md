# Code signing policy

Free code signing provided by SignPath.io, certificate by SignPath Foundation

DeeMusiq is an open-source project (BSD-4-Clause, see [`LICENSE`](./LICENSE)) and
uses SignPath Foundation's free code signing service for its Windows binaries.
The certificate is issued to **SignPath Foundation**, not to this project, so
Windows shows *SignPath Foundation* as the publisher. SignPath Foundation
vouches for the binary by verifying it was built from this public repository.

## Roles

Signing requires that the team responsible for code signing is also the team
responsible for development and maintenance, including ownership of the source
repository.

| Role | Who |
|------|-----|
| **Committers and reviewers** | [deemusiq org members](https://github.com/orgs/deemusiq/people) |
| **Approvers** | [deemusiq owners](https://github.com/orgs/deemusiq/teams/owners) |

All members of the above roles use MFA on both GitHub and SignPath. A release
is approved by an approver before it is signed; no contributor can sign their
own unreviewed artifact.

## What is signed

- **Own binaries only.** Only software built from this repository is signed.
  Upstream OSS binaries bundled inside our installers (for example the
  `media_kit_libs_windows_audio` libmpv DLLs, and `flutter_secure_storage_linux`)
  are **not** signed by this project and are included unmodified, as permitted by
  the SignPath Foundation terms.
- Every release requires **manual approval** before signing.
- Binaries must be built from source in a **verifiable way**: the release
  workflow in `.github/workflows/deemusiq-windows.yml` builds, signs and uploads
  in a single job, and `tool/verify_release.sh windows` hard-fails the build
  unless the TLS pin, backend wiring, payment HMAC and Authenticode signatures
  are all correct.
- Signing is **not** used to identify or exploit security vulnerabilities, and
  this project ships no vulnerability-scanning or offensive tooling. Its
  security features (certificate pinning, anti-tamper integrity checks,
  anti-fraud controls) are defensive protections for our own service.

## Changes to this policy

Any change to this policy is reviewed by the approvers above before it takes
effect, and is committed to this repository so the history is auditable.