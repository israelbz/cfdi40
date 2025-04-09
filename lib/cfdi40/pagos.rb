# frozen_string_literal: true

module Cfdi40
  class Pagos < Node
    define_namespace "pago20", "http://www.sat.gob.mx/Pagos20"
    define_attribute :schema_location,
                     xml_attribute: "xsi:schemaLocation",
                     readonly: true,
                     default: "http://www.sat.gob.mx/Pagos20 " \
                              "http://www.sat.gob.mx/sitio_internet/cfd/Pagos/Pagos20.xsd"
    define_attribute :version, xml_attribute: "Version", readonly: true, default: "2.0"

    def add_pago(attributes = {})
      pago = Pago.new
      pago.parent_node = self
      attributes.each do |key, value|
        method_name = "#{key}=".to_sym
        raise Error, ":#{key} no se puede asignar al nodo Pago" unless pago.respond_to?(method_name)

        pago.public_send(method_name, value)
      end
      pago.monto = pago.monto.round(2)
      pago.add_docto_relacionado
      pago.add_impuestos_p
      @children_nodes << pago
      update_totales
      true
    end

    def update_totales
      update_totales_traslado_iva16
      update_total_monto
    end

    def update_totales_traslado_iva16
      key = ["002", "Tasa", "0.160000"]
      return if traslados_summary[key].nil?

      totales_node.base_iva16 = traslados_summary[key][:base]
      totales_node.importe_iva16 = traslados_summary[key][:importe]
    end

    def update_total_monto
      totales_node.monto_total = pago_nodes.map(&:monto).sum
    end

    def traslados_summary
      @traslados_summary if defined?(@traslados_summary)

      summary = {}
      pago_nodes.each do |pago|
        pago.traslados_summary.each do |key, data|
          summary[key] ||= { base: 0, importe: 0 }
          summary[key][:base] += data[:base]
          summary[key][:importe] += data[:importe]
        end
      end
      @traslados_summary = summary
    end

    def totales_node
      return @totales_node if defined?(@totales_node)

      @totales_node = Totales.new
      add_child_node @totales_node
      @totales_node
    end

    def pago_nodes
      @children_nodes.select { |node| node.instance_of?(::Cfdi40::Pago) }
    end
  end
end
