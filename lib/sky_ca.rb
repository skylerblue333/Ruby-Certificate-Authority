require "digest"
require "openssl"

module SkyCA
  module_function

  def inspect_pem(pem, now: Time.now.utc)
    certificate = OpenSSL::X509::Certificate.new(pem)
    basic_constraints = certificate.extensions.find { |extension| extension.oid == "basicConstraints" }
    ca = basic_constraints&.value&.upcase&.include?("CA:TRUE") || false
    public_key = certificate.public_key
    key_type = public_key.class.name.split("::").last
    key_bits = public_key.respond_to?(:n) ? public_key.n.num_bits : nil
    self_signed = certificate.subject == certificate.issuer && certificate.verify(public_key)

    {
      subject: certificate.subject.to_s,
      issuer: certificate.issuer.to_s,
      serial_hex: certificate.serial.to_i.to_s(16),
      not_before: certificate.not_before.utc.iso8601,
      not_after: certificate.not_after.utc.iso8601,
      expired: certificate.not_after < now,
      not_yet_valid: certificate.not_before > now,
      ca: ca,
      self_signed: self_signed,
      key_type: key_type,
      key_bits: key_bits,
      sha256_fingerprint: Digest::SHA256.hexdigest(certificate.to_der).scan(/../).join(":").upcase
    }
  rescue OpenSSL::X509::CertificateError => error
    raise ArgumentError, "invalid X.509 certificate: #{error.message}"
  end

  def validate_ca(report, require_self_signed: true, minimum_rsa_bits: 2048)
    failures = []
    failures << "certificate is not marked CA:TRUE" unless report.fetch(:ca)
    failures << "certificate is expired" if report.fetch(:expired)
    failures << "certificate is not yet valid" if report.fetch(:not_yet_valid)
    failures << "certificate is not self-signed" if require_self_signed && !report.fetch(:self_signed)
    if report.fetch(:key_type) == "RSA" && report[:key_bits] && report[:key_bits] < minimum_rsa_bits
      failures << "RSA key is below #{minimum_rsa_bits} bits"
    end
    failures
  end
end
