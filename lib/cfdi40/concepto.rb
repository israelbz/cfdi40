# Represents node 'concepto'
#
# * Attribute +Importe+ represente gross amount. Gross amount is before taxes and the result of multiply
#   +ValorUnitario+ by +Cantidad+
#   
module Cfdi40
  class Concepto < Node
    define_attribute :clave_prod_serv, xml_attribute: 'ClaveProdServ'
    define_attribute :no_identificacion,xml_attribute: 'NoIdentificacion'
    define_attribute :cantidad, xml_attribute: 'Cantidad', default: 1
    define_attribute :clave_unidad, xml_attribute: 'ClaveUnidad'
    define_attribute :unidad, xml_attribute: 'Unidad'
    define_attribute :descripcion, xml_attribute: 'Descripcion'
    define_attribute :valor_unitario, xml_attribute: 'ValorUnitario', format: :t_Importe
    define_attribute :importe, xml_attribute: 'Importe', format: :t_Importe
    define_attribute :descuento, xml_attribute: 'Descuento', format: :t_Importe
    define_attribute :objeto_impuestos, xml_attribute: 'ObjetoImp', default: '01'

    attr_accessor :tasa_iva, :tasa_ieps, :precio_neto, :precio_bruto
    attr_reader :iva, :ieps, :base_iva, :importe_neto, :importe_bruto

    # accesors for instEducativas
    attr_accessor :iedu_nombre_alumno, :iedu_curp, :iedu_nivel_educativo, :iedu_aut_rvoe, :iedu_rfc_pago

    def initialize
      @tasa_iva = 0.16
      @tasa_ieps = nil
      super
    end

    # Calculate taxes, amounts from gross price
    # or net price
    def calculate!
      set_defaults
      assign_objeto_imp
      # TODO: accept discount
      if defined?(@precio_neto) && !@precio_neto.nil?
        calculate_from_net_price
      elsif defined?(@precio_bruto) && !@precio_bruto.nil?
        calculate_from_gross_price
      elsif !self.valor_unitario.nil?
        @precio_bruto = valor_unitario
        calculate_from_gross_price
      end
      add_info_to_traslado_iva
      # TODO: add_info_to_traslado_ieps if @ieps > 0
      add_inst_educativas
      true
    end

    def objeto_impuestos?
      objeto_impuestos == '02'
    end

    def traslado_nodes
      return [] if impuestos_node.nil?

      impuestos_node.traslado_nodes
    end

    private

    def calculate_from_net_price
      set_defaults
      @precio_neto = @precio_neto.round(2)
      @precio_bruto = (@precio_neto / ((1 + tasa_iva.to_f) * (1 + tasa_ieps.to_f))).round(6)
      calculate_taxes
      update_xml_attributes
    end

    def calculate_from_gross_price
      @precio_bruto = @precio_bruto.round(6)
      calculate_taxes
      @precio_neto = (@importe_neto / cantidad).round(2)
      update_xml_attributes
    end

    def calculate_taxes
      @base_ieps = (@precio_bruto * cantidad).round(2)
      @ieps = (@base_ieps * tasa_ieps.to_f).round(2)
      @base_iva = (@base_ieps + @ieps).round(2)
      @iva = (@base_iva * tasa_iva.to_f).round(2)
      @importe_bruto = @base_ieps
      @importe_neto = (@base_iva + @iva).round(2)
    end

    def update_xml_attributes
      self.importe = @importe_bruto
      self.valor_unitario = @precio_bruto
    end

    def add_info_to_traslado_iva
      return if @tasa_iva.nil?

      traslado_iva_node.importe = @iva
      traslado_iva_node.base = @base_iva
      traslado_iva_node.tasa_o_cuota = @tasa_iva
    end

    def assign_objeto_imp
      #01 No objeto de impuesto.
      #02  Sí objeto de impuesto.
      #03  Sí objeto del impuesto y no obligado al desglose.

      return if objeto_impuestos == '03'

      self.objeto_impuestos = (!@tasa_iva.nil? || !@tasa_ieps.nil? ? '02' : '01')
    end

    def impuestos_node
      return @impuestos_node if defined?(@impuestos_node)
      return nil unless objeto_impuestos?

      @impuestos_node = children_nodes.select { |child| child.is_a?(Impuestos) }.first
      return if @impuestos_node

      @impuestos_node = Impuestos.new
      @impuestos_node.parent_node = self
      self.children_nodes << @impuestos_node
      @impuestos_node
    end

    def traslado_iva_node
      return nil unless impuestos_node.is_a?(Impuestos)

      impuestos_node.traslado_iva
    end

    def add_inst_educativas
      return unless inst_educativas_present?

      inst_educativas_node.nombre_alumno = iedu_nombre_alumno
      inst_educativas_node.curp = iedu_curp
      inst_educativas_node.nivel_educativo = iedu_nivel_educativo
      inst_educativas_node.aut_rvoe = iedu_aut_rvoe
      inst_educativas_node.rfc_pago = iedu_rfc_pago
    end

    def inst_educativas_present?
      return false if iedu_nombre_alumno.nil?
      return false if iedu_nivel_educativo.nil?
      return false if iedu_aut_rvoe.nil?

      true
    end

    def concepto_complemento_node
      return @complemento_concepto_node if defined?(@complemento_concepto_node)

      @complemento_concepto_node = ComplementoConcepto.new
      @complemento_concepto_node.parent_node = self
      self.children_nodes << @complemento_concepto_node
      @complemento_concepto_node
    end

    def inst_educativas_node
      return nil unless concepto_complemento_node.is_a?(ComplementoConcepto)

      concepto_complemento_node.inst_educativas_node
    end
  end
end
