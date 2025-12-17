# frozen_string_literal: true

module Cfdi40
  class ImpuestosP < Node
    def traslados_p
      return @traslados_p if defined?(@traslados_p)

      @traslados_p = TrasladosP.new
      add_child_node @traslados_p
      @traslados_p
    end

    def traslados_p_node
      @children_nodes.select {|child| child.instance_of?(Cfdi40::TrasladosP) }.first
    end

    def load_traslados_p_node(ng_node)
      @traslados_p = TrasladosP.new
      @traslados_p.load_from_ng_node(ng_node)
      add_child_node @traslados_p
      ng_node.xpath("//pago20:TrasladoP", { "pago20" => "http://www.sat.gob.mx/Pagos20" }).each do |trsld_p_node|
        @traslados_p.load_traslado_p(trsld_p_node)
      end
      @traslados_p
    end
  end
end
