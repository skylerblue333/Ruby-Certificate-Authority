# Sky Certificate Authority

A small Ruby/OpenSSL certificate-authority primitive for local development, test PKI, and controlled SKYCOIN4444 engineering workflows.

## Implemented

- Ruby 3.4 implementation using the standard OpenSSL bindings.
- RSA 3072-bit self-signed root CA generation.
- RSA 2048-bit leaf-key generation and SHA-256 certificate signing.
- Explicit CA and leaf X.509 extensions.
- Leaf validity bounded to 397 days.
- Common-name validation and bounded length.
- Random positive serial numbers by default, with deterministic serial injection for tests.
- Trust verification against the generated CA certificate.
- Minitest coverage for issuance, key matching, invalid inputs, and rejection of certificates from another root.
- Ruby syntax/test/OpenSSL CI plus a non-root container self-test.

## Example

```ruby
require_relative "lib/sky_ca"

ca = SkyCA::Authority.new(common_name: "Development Root", validity_days: 365)
issued = ca.issue(common_name: "service.internal", validity_days: 30)
puts ca.verify(issued.fetch(:certificate_pem))
```

## Product and security boundary

Status: **engineering beta / local PKI utility**.

This repository does **not** provide a production network CA, HSM/KMS-backed root-key custody, ACME, OCSP, CRLs, certificate revocation workflows, persistent serial databases, audit-log durability, role-based approval, offline-root ceremony, key rotation, name-constraint policy, multi-tenant isolation, compliance certification, HA, or production deployment.

The root private key exists only in process memory in the current implementation. Production certificate-authority systems require substantially stronger key custody and operational controls than this library claims.

## Run verification

```bash
ruby -c lib/sky_ca.rb
ruby -Ilib:test test/sky_ca_test.rb
docker build -t sky-ca .
docker run --rm sky-ca
```

## License

See `LICENSE`.
