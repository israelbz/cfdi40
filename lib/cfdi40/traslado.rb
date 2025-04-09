# frozen_string_literal: true

module Cfdi40
  class Traslado < Node
    define_attribute :base, xml_attribute: "Base", format: :t_ImporteMXN
    define_attribute :impuesto, xml_attribute: "Impuesto"
    define_attribute :tipo_factor, xml_attribute: "TipoFactor", default: "Tasa"
    define_attribute :tasa_o_cuota, xml_attribute: "TasaOCuota", format: :t_Importe
    define_attribute :importe, xml_attribute: "Importe", format: :t_ImporteMXN
  end
end
