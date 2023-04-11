module Cfdi40
  class ImpuestosDR < Node
    def traslados_dr
      return @traslados_dr if defined?(@traslados_dr)

      @traslados_dr = TrasladosDR.new
      @traslados_dr.parent_node = self
      @children_nodes << @traslados_dr
      @traslados_dr
    end
  end
end
