module Cfdi40
  class Impuestos < Node
    define_attribute :total_impuestos_retenidos, xml_attribute: 'TotalImpuestosRetenidos', format: :t_Importe
    define_attribute :total_impuestos_trasladados, xml_attribute: 'TotalImpuestosTrasladados', format: :t_Importe

    def traslados
      return @traslados if defined?(@traslados)

      @traslados = Traslados.new
      self.children_nodes << @traslados
      @traslados
    end

    def traslados_node
      children_nodes.select { |n| n.is_a?(Traslados)}.first
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