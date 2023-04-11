module Cfdi40
  class Complemento < Node
    # See Comprobante#add_pago
    def add_pago(attributes={})
      pagos.totales_node
      pagos.add_pago(attributes)
    end

    def pagos
      return @pagos if defined?(@pagos)
      
      @pagos = Pagos.new
      @pagos.parent_node = self
      @children_nodes << @pagos
      @pagos
    end
  end
end
