require "minitest/autorun"
require "openssl"
require "time"
require_relative "../lib/sky_ca"

class SkyCATest < Minitest::Test
  def certificate(ca: true, not_before: Time.now.utc - 60, not_after: Time.now.utc + 3600)
    key = OpenSSL::PKey::RSA.new(2048)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.parse("/CN=Sky Test CA")
    cert.issuer = cert.subject
    cert.public_key = key.public_key
    cert.not_before = not_before
    cert.not_after = not_after

    factory = OpenSSL::X509::ExtensionFactory.new
    factory.subject_certificate = cert
    factory.issuer_certificate = cert
    cert.add_extension(factory.create_extension("basicConstraints", ca ? "CA:TRUE" : "CA:FALSE", true))
    cert.add_extension(factory.create_extension("keyUsage", ca ? "keyCertSign,cRLSign" : "digitalSignature", true))
    cert.sign(key, OpenSSL::Digest::SHA256.new)
    cert
  end

  def test_inspects_self_signed_ca
    report = SkyCA.inspect_pem(certificate.to_pem)

    assert report[:ca]
    assert report[:self_signed]
    assert_equal "RSA", report[:key_type]
    assert_operator report[:key_bits], :>=, 2048
    assert_empty SkyCA.validate_ca(report)
  end

  def test_policy_rejects_non_ca
    report = SkyCA.inspect_pem(certificate(ca: false).to_pem)

    refute report[:ca]
    assert_includes SkyCA.validate_ca(report), "certificate is not marked CA:TRUE"
  end

  def test_reports_expired_certificate
    report = SkyCA.inspect_pem(
      certificate(not_before: Time.now.utc - 7200, not_after: Time.now.utc - 3600).to_pem
    )

    assert report[:expired]
    assert_includes SkyCA.validate_ca(report), "certificate is expired"
  end

  def test_rejects_invalid_pem
    assert_raises(ArgumentError) { SkyCA.inspect_pem("not a certificate") }
  end
end
