module Cfdi40
  class Pago < Node
    define_attribute :monto, xml_attribute: 'Monto'
    define_attribute :fecha_pago, xml_attribute: 'FechaPago'
    define_attribute :forma_pago, xml_attribute: 'FormaDePagoP'
    define_attribute :moneda, xml_attribute: 'MonedaP', readonly: true, default: 'MXN'
    define_attribute :tipo_cambio, xml_attribute: 'TipoCambioP', readonly: true, default: '1'

    attr_accessor :uuid, :serie, :folio, :num_parcialidad, :importe_saldo_anterior, :objeto_impuestos

    # Generate docto_relacionado node
    # Data for dcto_relacionado node is obtained from de accessors
    #  uuid, serie, folio
    def add_docto_relacionado
      docto_relacionado = DoctoRelacionado.new
      docto_relacionado.parent_node = self
      docto_relacionado.id_documento = uuid
      docto_relacionado.serie = serie
      docto_relacionado.folio = folio
      docto_relacionado.num_parcialidad = num_parcialidad
      docto_relacionado.imp_saldo_ant = importe_saldo_anterior.round(2)
      docto_relacionado.imp_pagado = monto
      docto_relacionado.calculate!
      @children_nodes << docto_relacionado
    end

    def add_impuestos_p
      impuestos_p = ImpuestosP.new
      add_child_node impuestos_p
      impuestos_p.traslados_p.add_traslado_p_nodes
    end

    def docto_relacionados
      return @docto_relacionados if defined?(@docto_relacionados)

      @docto_relacionados =
        @children_nodes.select do |child|
          child if child.class.name == 'Cfdi40::DoctoRelacionado'
        end
    end

    def traslados_summary
      return @summary if defined?(@summary)

      summary = {}
      docto_relacionados.each do |docto|
        docto.traslados_summary.each do |key, data|
          summary[key] ||= {base: 0, importe: 0}
          summary[key][:base] += data[:base]
          summary[key][:importe] += data[:importe]
        end
      end
      @summary = summary
    end
  end
end
