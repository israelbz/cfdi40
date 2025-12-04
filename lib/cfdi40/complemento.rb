# frozen_string_literal: true

module Cfdi40
  class Complemento < Node
    # See Comprobante#add_pago
    def add_pago(attributes = {})
      pagos.totales_node
      pagos.add_pago(attributes)
    end

    def add_splitted_pago(attributes = {})
      pagos.totales_node
      pagos.add_splitted_pago(attributes)
    end

    def pago_nodes
      return [] unless defined?(@pagos)

      pagos.pago_nodes
    end

    def pagos
      return @pagos if defined?(@pagos)

      @pagos = Pagos.new
      @pagos.parent_node = self
      @children_nodes << @pagos
      @pagos
    end

    def timbre
      @children_nodes.select { |children| children.is_a?(Cfdi40::Timbre) }.first
    end
  end
end
