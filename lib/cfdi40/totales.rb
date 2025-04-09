# frozen_string_literal: true

module Cfdi40
  class Totales < Node
    define_attribute :ret_iva, xml_attribute: "TotalRetencionesIVA"
    define_attribute :ret_isr, xml_attribute: "TotalRetencionesISR"
    define_attribute :ret_ieps, xml_attribute: "TotalRetencionesIEPS"
    define_attribute :base_iva16, xml_attribute: "TotalTrasladosBaseIVA16"
    define_attribute :importe_iva16, xml_attribute: "TotalTrasladosImpuestoIVA16"
    define_attribute :base_iva8, xml_attribute: "TotalTrasladosBaseIVA8"
    define_attribute :importe_iva8, xml_attribute: "TotalTrasladosImpuestoIVA8"
    define_attribute :base_iva0, xml_attribute: "TotalTrasladosBaseIVA0"
    define_attribute :importe_iva0, xml_attribute: "TotalTrasladosImpuestoIVA0"
    define_attribute :base_iva_excento, xml_attribute: "TotalTrasladosBaseIVAExento"
    define_attribute :monto_total, xml_attribute: "MontoTotalPagos"
  end
end
