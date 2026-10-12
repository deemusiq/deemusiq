# Code signing policy

Free code signing provided by [SignPath.io](https://about.signpath.io), certificate by [SignPath Foundation](https://signpath.org)

DeeMusiq is an open-source project (BSD-4-Clause, see [`LICENSE`](./LICENSE)) and
uses SignPath Foundation's free code signing service for its Windows binaries.
The certificate is issued to **SignPath Foundation**, not to this project, so
Windows displays *SignPath Foundation* as the publisher. SignPath Foundation
vouches for each artifact by verifying it is a valid automated build of the
source code in this repository.

## Team roles

Signing is only performed by people in the **Approvers** role, and only after a
release has been reviewed.

| Role | Responsibility | Members |
|------|----------------|---------|
| **Authors** | Trusted to modify source code without additional review | [Members team](https://github.com/orgs/deemusiq/people) |
| **Reviewers** | Review every change proposed by someone who is not a committer, via pull request | [Members team](https://github.com/orgs/deemusiq/people) |
| **Approvers** | Decide whether a given release may be code signed; approve each signing request | [Owners](https://github.com/orgs/deemusiq/people?query=role%3Aowner) |

Every member of all three roles uses **multi-factor authentication** on both
GitHub and SignPath.

## Privacy policy

DeeMusiq's privacy policy is published at
<https://deemusiq.co.za/privacy> and in this repository at
[`deemusiq-site/privacy.html`](./deemusiq-site/privacy.html).

Because DeeMusiq is a network service, it **does** transfer user data to systems
not specified by the user: account and authentication data, listening history,
ratings, and wallet/payment data are transmitted to the DeeMusiq backend to
provide the features the user has asked for. Accordingly the Windows installer:

1. **displays the privacy policy during installation**, and
2. **provides an installation option to disable optional data transfer** —
   an "Check for application updates" checkbox, which when cleared writes a
   sentinel file that stops the client contacting the update endpoint entirely.

Update checking is the only *optional* outbound transfer; signing in,
synchronising a library and using the wallet are core to the product the user
installed and are disclosed rather than optional. The same update check can also
be turned off at any time from within the app.

Third-party services whose policies affect our users are described in the
privacy policy, including Last.fm scrobbling (disabled unless the user supplies
their own API credentials), payment processors, and the YouTube-derived playback
engines.

## What is signed

- **Own binaries only.** Only artifacts built from this repository are signed.
  A signature confirms the binary is a valid automated build of the source code
  in this repository, including its build scripts and CI configuration.
- Upstream open-source binaries bundled unmodified inside our installers — for
  example the libmpv libraries from `media_kit_libs_windows_audio` and
  `flutter_secure_storage_linux` — are **not** signed by this project and are
  included as published, as permitted by the SignPath Foundation terms.
- DeeMusiq ships **no features designed to identify or exploit security
  vulnerabilities** and no vulnerability-scanning tooling. Its security features
  — certificate pinning, APK integrity checks and anti-fraud controls — are
  defensive protections for our own service.
- Signed binaries carry **product name** metadata set to the project name and a
  consistent **product version** per build, as required by SignPath's artifact
  configuration.

## Process

- Binaries are built from source in a **verifiable way**:
  [`.github/workflows/deemusiq-windows.yml`](./.github/workflows/deemusiq-windows.yml)
  builds, signs and uploads in a single job, and
  [`tool/verify_release.sh windows`](./deemusiq-app/tool/verify_release.sh) fails
  the build unless the TLS pin, backend wiring, payment HMAC and Authenticode
  signatures are all correct.
- **Every release requires manual approval** by an Approver before signing.
- If SignPath or the approval is unavailable at release time, the pipeline
  falls back to a project-controlled (or self-signed) certificate under a
  **different publisher identity**. Only artifacts carrying the "SignPath
  Foundation" signature are represented as covered by this policy.
- The installer includes a working uninstaller.

## Changes to this policy

Changes are reviewed by the Approvers before taking effect and are committed to
this repository so the history is auditable. Violations of the SignPath
Foundation Code of Conduct may result in the subscription being paused or the
certificate revoked without prior notice.