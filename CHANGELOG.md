# Changelog

## 0.1.0 - 2026-08-24

- replace unrelated Python queue behavior with a Ruby X.509 certificate inspector
- add CA basic-constraints, validity-window, self-signature, RSA key-size, and SHA-256 fingerprint inspection
- add optional CA policy validation and meaningful CLI exit codes
- add native Minitest coverage and Ruby syntax checks
- add non-root container packaging and CLI smoke verification
- remove unrelated Python and Node scaffolding
- explicitly exclude certificate issuance, CA private-key management, revocation, and production PKI claims
