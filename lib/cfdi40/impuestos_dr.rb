# frozen_string_literal: true

module Cfdi40
  class ImpuestosDR < Node
    def traslados_dr
      return @traslados_dr if defined?(@traslados_dr)

      @traslados_dr = TrasladosDR.new
      @traslados_dr.parent_node = self
      @children_nodes << @traslados_dr
      @traslados_dr
    end

    def load_traslados_dr(traslados_dr_node)
      @traslados_dr = TrasladosDR.new
      @traslados_dr.load_from_ng_node(traslados_dr_node)
      @traslados_dr.parent_node = self
      @children_nodes << @traslados_dr
      traslados_dr_node.xpath("//pago20:TrasladoDR", Cfdi40::Pagos::NG_NAMESPACE).each do |tr_dr_node|
        @traslados_dr.load_traslado_dr(tr_dr_node)
      end
      @traslados_dr
    end
  end
end
