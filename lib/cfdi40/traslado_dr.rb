# frozen_string_literal: true

module Cfdi40
  class TrasladoDR < Node
    define_attribute :base_dr, xml_attribute: "BaseDR", format: :t_ImporteMXN
    define_attribute :impuesto_dr, xml_attribute: "ImpuestoDR", default: "002"
    define_attribute :tipo_factor_dr, xml_attribute: "TipoFactorDR", default: "Tasa"
    define_attribute :tasa_o_cuota_dr, xml_attribute: "TasaOCuotaDR", default: "0.160000", format: :t_Importe
    define_attribute :importe_dr, xml_attribute: "ImporteDR", format: :t_ImporteMXN

    attr_accessor :monto_pago

    def calculate!
      self.base_dr = (monto_pago / (1 + tasa_o_cuota_dr.to_f)).round(2)
      self.importe_dr = (monto_pago - base_dr).round(2)
    end
  end
end
