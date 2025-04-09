# frozen_string_literal: true

module Cfdi40
  class Receptor < Node
    define_attribute :rfc, xml_attribute: "Rfc"
    define_attribute :nombre, xml_attribute: "Nombre"
    define_attribute :domicilio_fiscal, xml_attribute: "DomicilioFiscalReceptor"
    define_attribute :residencia_fiscal, xml_attribute: "ResidenciaFiscal"
    define_attribute :num_reg_id_trib, xml_attribute: "NumRegIdTrib"
    define_attribute :regimen_fiscal, xml_attribute: "RegimenFiscalReceptor"
    define_attribute :uso_cfdi, xml_attribute: "UsoCFDI"
  end
end
