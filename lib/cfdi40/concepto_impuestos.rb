# frozen_string_literal: true

# /cfdi:Comprobante/cfdi:Conceptos/cfdiConcepto/cfdi:Impuestos
module Cfdi40
  class ConceptoImpuestos < Node
    define_element_name "Impuestos"

    def traslados
      return @traslados if defined?(@traslados)

      @traslados = Traslados.new
      @traslados.parent_node = self
      children_nodes << @traslados
      @traslados
    end

    def traslados_node
      children_nodes.select { |n| n.is_a?(Traslados) }.first
    end

    def traslado_nodes
      return [] if traslados_node.nil?

      traslados_node.traslado_nodes
    end

    def traslado_iva
      traslados.traslado_iva
    end
  end
end
