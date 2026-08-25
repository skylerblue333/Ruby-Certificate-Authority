# Security

Sky CA Inspector is an engineering-beta certificate inspection utility. Report suspected vulnerabilities privately to the repository owner rather than publishing exploit details in an issue.

## Current controls

- parses X.509 input with Ruby OpenSSL
- exposes certificate metadata without private-key handling
- detects CA basic constraints, validity windows, self-signature, RSA key size, and SHA-256 fingerprint
- uses native tests and syntax checks in CI
- container runs as non-root UID `10001`

## Not implemented

This repository does not issue or sign certificates, store CA keys, validate full trust chains, check revocation, provide OCSP/CRLs, manage HSMs, enforce hostname/SAN identity, or establish production PKI security. Use established PKI tooling and reviewed key-management procedures for certificate issuance and private keys.
