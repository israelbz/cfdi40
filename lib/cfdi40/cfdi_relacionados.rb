# frozen_string_literal: true

module Cfdi40
  class CfdiRelacionados < Node
    define_attribute :tipo_relacion, xml_attribute: "TipoRelacion"

    def add_cfdi(uuid)
      cfdi_relacionado = CfdiRelacionado.new
      cfdi_relacionado.uuid = uuid
      cfdi_relacionado.parent_node = self
      @children_nodes << cfdi_relacionado
      cfdi_relacionado
    end

    def cfdi_relacionados
      @children_nodes
    end
  end
end