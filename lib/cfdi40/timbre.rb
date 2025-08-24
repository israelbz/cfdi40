# frozen_string_literal: true
module Cfdi40
  class Timbre < Node
    define_attribute :version, readonly: true, xml_attribute: "Version"
    define_attribute :rfc_prov_certif, readonly: true, xml_attribute: "RfcProvCertif"
    define_attribute :fecha_timbrado, readonly: true, xml_attribute: "FechaTimbrado", format: :t_FechaH
    define_attribute :uuid, readonly: true, xml_attribute: "UUID"
    define_attribute :sello_cfd, readonly: true, xml_attribute: "SelloCFD"
    define_attribute :sello_sat, readonly: true, xml_attribute: "SelloSAT"
    define_attribute :no_certificado_sat, readonly: true, xml_attribute: "NoCertificadoSAT"
  end
end
