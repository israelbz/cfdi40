module Cfdi40
  class Traslados < Node
    def traslado_iva
      return @traslado_iva if defined?(@traslado_iva)
      
      @traslado_iva = Traslado.new
      # TODO: FIX magic number
      @traslado_iva.impuesto = '002'
      self.children_nodes << @traslado_iva
      @traslado_iva
    end

    def traslado_nodes
      children_nodes
    end
  end
end
