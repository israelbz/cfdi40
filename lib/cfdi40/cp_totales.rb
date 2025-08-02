# frozen_string_literal: true

module Cfdi40
  class CpTotales < Node
    define_element_name 'Totales'
    define_attribute :ret_iva, xml_attribute: "TotalRetencionesIVA", format: :t_ImporteMXN
    define_attribute :ret_isr, xml_attribute: "TotalRetencionesISR", format: :t_ImporteMXN
    define_attribute :ret_ieps, xml_attribute: "TotalRetencionesIEPS", format: :t_ImporteMXN
    define_attribute :base_iva16, xml_attribute: "TotalTrasladosBaseIVA16", format: :t_ImporteMXN
    define_attribute :importe_iva16, xml_attribute: "TotalTrasladosImpuestoIVA16", format: :t_ImporteMXN
    define_attribute :base_iva8, xml_attribute: "TotalTrasladosBaseIVA8", format: :t_ImporteMXN
    define_attribute :importe_iva8, xml_attribute: "TotalTrasladosImpuestoIVA8", format: :t_ImporteMXN
    define_attribute :base_iva0, xml_attribute: "TotalTrasladosBaseIVA0", format: :t_ImporteMXN
    define_attribute :importe_iva0, xml_attribute: "TotalTrasladosImpuestoIVA0", format: :t_ImporteMXN
    define_attribute :base_iva_excento, xml_attribute: "TotalTrasladosBaseIVAExento", format: :t_ImporteMXN
    define_attribute :monto_total, xml_attribute: "MontoTotalPagos", format: :t_ImporteMXN
  end
end
