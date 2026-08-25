# frozen_string_literal: true

require "openssl"
require "securerandom"

module SkyCA
  class Error < StandardError; end

  class Authority
    attr_reader :certificate

    def initialize(common_name:, validity_days: 3650)
      raise Error, "common name is required" if common_name.to_s.strip.empty?
      raise Error, "validity_days must be between 1 and 3650" unless (1..3650).cover?(validity_days)

      @key = OpenSSL::PKey::RSA.new(3072)
      @certificate = build_ca_certificate(common_name.strip, validity_days)
    end

    def issue(common_name:, validity_days: 90, serial: nil)
      name = common_name.to_s.strip
      raise Error, "common name is required" if name.empty? || name.bytesize > 253
      raise Error, "validity_days must be between 1 and 397" unless (1..397).cover?(validity_days)

      leaf_key = OpenSSL::PKey::RSA.new(2048)
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = serial || SecureRandom.random_number(2**63 - 1) + 1
      cert.subject = OpenSSL::X509::Name.parse("/CN=#{escape_name(name)}")
      cert.issuer = @certificate.subject
      cert.public_key = leaf_key.public_key
      cert.not_before = Time.now.utc - 60
      cert.not_after = cert.not_before + validity_days * 86_400

      extension_factory = OpenSSL::X509::ExtensionFactory.new
      extension_factory.subject_certificate = cert
      extension_factory.issuer_certificate = @certificate
      cert.add_extension(extension_factory.create_extension("basicConstraints", "CA:FALSE", true))
      cert.add_extension(extension_factory.create_extension("keyUsage", "digitalSignature,keyEncipherment", true))
      cert.add_extension(extension_factory.create_extension("subjectKeyIdentifier", "hash", false))
      cert.add_extension(extension_factory.create_extension("authorityKeyIdentifier", "keyid:always", false))
      cert.sign(@key, OpenSSL::Digest::SHA256.new)

      { certificate_pem: cert.to_pem, private_key_pem: leaf_key.private_to_pem, serial: cert.serial }
    end

    def verify(certificate_pem)
      cert = OpenSSL::X509::Certificate.new(certificate_pem)
      store = OpenSSL::X509::Store.new
      store.add_cert(@certificate)
      store.verify(cert)
    rescue OpenSSL::X509::CertificateError
      false
    end

    def certificate_pem
      @certificate.to_pem
    end

    private

    def build_ca_certificate(common_name, validity_days)
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = SecureRandom.random_number(2**63 - 1) + 1
      cert.subject = OpenSSL::X509::Name.parse("/CN=#{escape_name(common_name)}")
      cert.issuer = cert.subject
      cert.public_key = @key.public_key
      cert.not_before = Time.now.utc - 60
      cert.not_after = cert.not_before + validity_days * 86_400

      extension_factory = OpenSSL::X509::ExtensionFactory.new
      extension_factory.subject_certificate = cert
      extension_factory.issuer_certificate = cert
      cert.add_extension(extension_factory.create_extension("basicConstraints", "CA:TRUE,pathlen:0", true))
      cert.add_extension(extension_factory.create_extension("keyUsage", "keyCertSign,cRLSign", true))
      cert.add_extension(extension_factory.create_extension("subjectKeyIdentifier", "hash", false))
      cert.add_extension(extension_factory.create_extension("authorityKeyIdentifier", "keyid:always", false))
      cert.sign(@key, OpenSSL::Digest::SHA256.new)
      cert
    end

    def escape_name(value)
      value.gsub(/[\\\/]/) { |char| "\\#{char}" }
    end
  end
end
