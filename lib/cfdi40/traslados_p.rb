# frozen_string_literal: true

module Cfdi40
  class TrasladosP < Node
    def add_traslado_p_nodes
      pago = parent_node.parent_node
      pago.traslados_summary.each do |key, data|
        traslado_p = TrasladoP.new
        traslado_p.impuesto_p = key[0]
        traslado_p.tipo_factor_p = key[1]
        traslado_p.tasa_o_cuota_p = key[2]
        traslado_p.base_p = data[:base]
        traslado_p.importe_p = data[:importe]
        add_child_node traslado_p
      end
    end

    def traslado_p_nodes
      @children_nodes.select { |child| child.instance_of?(Cfdi40::TrasladoP) }
    end

    def load_traslado_p(ng_node)
      traslado_p = TrasladoP.new
      traslado_p.load_from_ng_node(ng_node)
      add_child_node traslado_p
      traslado_p
    end
  end
end
