module Cfdi40
  class SatCsd
    attr_reader :x509_cert
    attr_reader :private_key

    def cert_path=(path)
      @cert_path = path
      @x509_cert = OpenSSL::X509::Certificate.new(File.read(path))
    end

    def cert_der=(data)
      @x509_cert = OpenSSL::X509::Certificate.new(data)
    end

    def load_private_key(key_path, key_pass)
      key_pem = load_key_to_pem(File.read(key_path))
      @private_key = OpenSSL::PKey::RSA.new(key_pem, key_pass)
    end

    def set_crypted_private_key(key_der, key_pass)
      key_pem = load_key_to_pem(key_der)
      @private_key = OpenSSL::PKey::RSA.new(key_pem, key_pass)
    end

    def rfc
      return unless subject_data

      unique_identifier = subject_data.select { |data| data[0] == "x500UniqueIdentifier" }.first
      return unless unique_identifier

      unique_identifier[1]
    end

    def name
      return unless subject_data

      subject_name = subject_data.select { |data| data[0] == "name" }.first
      return unless subject_name

      subject_name[1]
    end

    def no_certificado
      return unless x509_cert

      s = ''
      x509_cert.serial.to_s(16).split('').each_with_index do |c, i|
        next if i.even?

        s += c
      end
      s
    end

    def cert64
      return unless x509_cert

      Base64.strict_encode64 x509_cert.to_der
    end

    def valid_pair?
      return false unless x509_cert && private_key

      x509_cert.check_private_key private_key
    end

    private

    def subject_data
      return unless x509_cert

      x509_cert.subject.to_a
    end

    def load_key_to_pem(key_der)
      array_key_pem = []
      array_key_pem << '-----BEGIN ENCRYPTED PRIVATE KEY-----'
      array_key_pem += Base64.strict_encode64(key_der).scan(/.{1,64}/)
      array_key_pem << '-----END ENCRYPTED PRIVATE KEY-----'
      array_key_pem.join("\n")
    end
  end
end