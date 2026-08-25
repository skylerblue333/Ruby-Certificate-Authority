# frozen_string_literal: true

require "minitest/autorun"
require "openssl"
require_relative "../lib/sky_ca"

class SkyCATest < Minitest::Test
  def setup
    @ca = SkyCA::Authority.new(common_name: "Sky Test Root", validity_days: 30)
  end

  def test_issues_and_verifies_leaf_certificate
    issued = @ca.issue(common_name: "service.internal", validity_days: 7, serial: 42)
    cert = OpenSSL::X509::Certificate.new(issued.fetch(:certificate_pem))
    key = OpenSSL::PKey.read(issued.fetch(:private_key_pem))

    assert_equal 42, issued.fetch(:serial)
    assert_equal "/CN=service.internal", cert.subject.to_s
    assert cert.check_private_key(key)
    assert @ca.verify(issued.fetch(:certificate_pem))
  end

  def test_rejects_invalid_names_and_validity
    assert_raises(SkyCA::Error) { SkyCA::Authority.new(common_name: "") }
    assert_raises(SkyCA::Error) { @ca.issue(common_name: "") }
    assert_raises(SkyCA::Error) { @ca.issue(common_name: "valid", validity_days: 398) }
  end

  def test_does_not_verify_untrusted_certificate
    other = SkyCA::Authority.new(common_name: "Other Root", validity_days: 30)
    issued = other.issue(common_name: "other.internal", validity_days: 7)
    refute @ca.verify(issued.fetch(:certificate_pem))
  end
end
