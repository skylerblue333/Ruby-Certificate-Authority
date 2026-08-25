# Sky CA Inspector

Sky CA Inspector is a small Ruby CLI/library for inspecting X.509 certificates and applying a narrow certificate-authority policy check. It parses certificate metadata, detects CA basic constraints, checks validity windows and self-signature, reports key type/size, and emits a SHA-256 certificate fingerprint.

**Status: engineering beta.** Despite the historical repository name, this project does **not** issue certificates, create or store CA private keys, publish CRLs, provide OCSP, rotate keys, or operate a production certificate authority.

## Inspect a certificate

```bash
ruby bin/sky-ca-inspect certificate.pem
```

The JSON report includes subject, issuer, serial number, validity window, CA flag, self-signed status, public-key type/size, and SHA-256 fingerprint.

Apply the built-in CA policy:

```bash
ruby bin/sky-ca-inspect --require-ca root-ca.pem
```

The policy currently requires `CA:TRUE`, a valid time window, self-signature, and at least 2048 bits for RSA keys. A policy failure exits `1`; malformed input or invocation exits `2`.

## Verification

```bash
ruby -c lib/sky_ca.rb
ruby -c bin/sky-ca-inspect
ruby -Ilib:test test/sky_ca_test.rb
```

Container:

```bash
docker build -t sky-ca-inspect .
docker run --rm -v "$PWD:/certs:ro" sky-ca-inspect /certs/root-ca.pem
```

The image runs as non-root UID `10001`. CI checks Ruby syntax, Minitest coverage, container build, non-root configuration, and CLI startup.

## SKYCOIN4444 integration

The inspector can be used by deployment or security pipelines to reject malformed, expired, or policy-incompatible certificates before configuration is promoted. Integrations should invoke the CLI/library contract and keep private-key operations in a dedicated, reviewed PKI system.

## Security limits

A successful inspection is not a complete PKI audit. The tool does not validate an arbitrary trust chain against a trust store, check revocation, enforce hostname/SAN identity, assess every cryptographic algorithm, manage key custody, or prove operational CA security. Production PKI should use established CA/HSM tooling, documented ceremonies, access controls, revocation infrastructure, monitoring, and independent review.
