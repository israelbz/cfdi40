module Cfdi40
  class Emisor < Node
    define_attribute :rfc, xml_attribute: 'Rfc'
    define_attribute :nombre, xml_attribute: 'Nombre'
    define_attribute :regimen_fiscal, xml_attribute: 'RegimenFiscal'
  end
end
