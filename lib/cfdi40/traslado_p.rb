module Cfdi40
  class TrasladoP < Node
    define_attribute :base_p, xml_attribute: 'BaseP', format: :t_ImporteMXN
    define_attribute :impuesto_p, xml_attribute: 'ImpuestoP', default: '002'
    define_attribute :tipo_factor_p, xml_attribute: 'TipoFactorP', default: 'Tasa'
    define_attribute :tasa_o_cuota_p, xml_attribute: 'TasaOCuotaP', default: '0.160000', format: :t_Importe
    define_attribute :importe_p, xml_attribute: 'ImporteP', format: :t_ImporteMXN
  end
end
