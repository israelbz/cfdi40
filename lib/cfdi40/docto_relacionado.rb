module Cfdi40
  class DoctoRelacionado < Node
    define_attribute :id_documento, xml_attribute: 'IdDocumento'
    define_attribute :serie, xml_attribute: 'Serie'
    define_attribute :folio, xml_attribute: 'Folio'
    define_attribute :moneda_dr, xml_attribute: 'MonedaDR', default: 'MXN'
    define_attribute :equivalencia_dr, xml_attribute: 'EquivalenciaDR'
    define_attribute :num_parcialidad, xml_attribute: 'NumParcialidad'
    define_attribute :imp_saldo_ant, xml_attribute: 'ImpSaldoAnt', format: :t_ImporteMXN
    define_attribute :imp_pagado, xml_attribute: 'ImpPagado', format: :t_ImporteMXN
    define_attribute :imp_saldo_insoluto, xml_attribute: 'ImpSaldoInsoluto', format: :t_ImporteMXN
    define_attribute :objeto_imp_dr, xml_attribute: 'ObjetoImpDR', default: '02'

    def calculate!
      self.imp_saldo_insoluto = (imp_saldo_ant - imp_pagado).round(2)
      add_impuestos
    end

    # Add nodes for 'traslado_dr' and/or 'retencion_dr' and intermetiate nodes
    def add_impuestos
      add_traslado if objeto_imp_dr == '02'
    end

    def add_traslado
      return unless objeto_imp_dr == '02'

      # Taxes values for IVA rate 0.16 assumming that all 'conceptos' in the realted document 
      # has the same tax rate. This could not be true but the is the most common case.
      traslado_dr = TrasladoDR.new
      traslado_dr.monto_pago = imp_pagado.round(2)
      traslado_dr.calculate!
      traslados_dr.add_child_node(traslado_dr)
      traslado_dr
    end

    # Return a hash. The key is an array [impuesto, tipo_factor, tasa_o_cuot]
    # and the value is another hash with the keys :base, :importe
    def traslados_summary
      return {} unless defined?(@traslados_dr)

      summary = {}
      @traslados_dr.children_nodes.each do |traslado_dr|
        key = [traslado_dr.impuesto_dr, traslado_dr.tipo_factor_dr, traslado_dr.tasa_o_cuota_dr]
        summary[key] ||= { base: 0, importe: 0 }
        summary[key][:base] += traslado_dr.base_dr.to_f
        summary[key][:importe] += traslado_dr.importe_dr.to_f
      end
      summary
    end

    def traslados_dr
      return @traslados_dr if defined?(@traslados_dr)

      @traslados_dr = impuestos_dr.traslados_dr
    end

    def impuestos_dr
      return @impuestos_dr if defined?(@impuestos_dr)
      
      @impuestos_dr = ImpuestosDR.new
      @impuestos_dr.parent_node = self
      @children_nodes << @impuestos_dr
      @impuestos_dr
    end
  end
end
