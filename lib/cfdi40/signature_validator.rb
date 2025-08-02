# frozen_string_literal: true

# Verfies signature
module Cfdi40
  class SignatureValidator
    def initialize(xml)
      @xml_doc = Nokogiri::XML(xml)

    end

    def valid?
      original_content = OriginalContent.generate(@xml_doc.to_s)
      cert.public_key.verify(OpenSSL::Digest.new('SHA256'), sign, original_content)
    end

    def sign
      sign = @xml_doc.root.attributes["Sello"].to_s
      raise Cfdi40::Error, 'CFDI is not signed' if sign == ''

      Base64.decode64 sign
    end

    def cert
      return @cert if defined?(@cert)

      cert_string = @xml_doc.root.attributes["Certificado"].to_s
      raise Cfdi40::Error, 'Certificate is not included in XML' if cert_string == ''
      sat_csd = SatCsd.new
      sat_csd.cert64 = cert_string
      sat_csd.x509_cert.serial

      if @xml_doc.root.attributes["NoCertificado"].to_s != sat_csd.no_certificado
        raise Cfdi40::Error, 'Certificate number in XML does not correspond to the included certificate'
      end

      @cert = sat_csd.x509_cert
    end
  end
end
