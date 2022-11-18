# Represents node 'concepto'
#
# * Attribute +Importe+ represente gross amount. Gross amount id before taxes and the result of multiply
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

    def initialize
      @tasa_iva = 0.16
      @tasa_ieps = 0
      super
    end

    # Calculate taxes, amounts from gross price
    # or net price
    def calculate!
      set_defaults
      assign_objeto_imp
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
      @importe_neto = precio_neto * cantidad
      breakdown_taxes
      update_xml_attributes
    end

    def breakdown_taxes
      @base_iva = @importe_neto / (1 + tasa_iva)
      @iva = @importe_neto - @base_iva
      @base_ieps = @base_iva / (1 + tasa_ieps)
      @ieps = @base_iva - @base_ieps 
      @importe_bruto = @base_ieps
      @precio_bruto = @importe_bruto / @cantidad
    end

    def calculate_from_gross_price
      @importe_bruto = @precio_bruto * cantidad
      add_taxes
      update_xml_attributes
    end

    def add_taxes
      @base_ieps = @importe_bruto
      @ieps = @base_ieps * tasa_ieps
      @base_iva = @base_ieps + @ieps
      @iva = @base_iva * tasa_iva
      @importe_neto = @base_iva + @iva
      @precio_neto = @importe_neto / cantidad
    end

    def update_xml_attributes
      self.importe = @importe_bruto
      self.valor_unitario = @precio_bruto
    end

    def add_info_to_traslado_iva
      return unless @iva > 0

      traslado_iva_node.importe = @iva
      traslado_iva_node.base = @base_iva
      traslado_iva_node.tasa_o_cuota = @tasa_iva
    end

    def assign_objeto_imp
      return if objeto_impuestos == '03'

      self.objeto_impuestos = (@tasa_iva > 0 || @tasa_ieps > 0 ? '02' : '01')
    end

    def impuestos_node
      return @impuestos_node if defined?(@impuestos_node)
      return nil unless objeto_impuestos?

      @impuestos_node = children_nodes.select { |child| child.is_a?(Impuestos) }.first
      return if @impuestos_node

      @impuestos_node = Impuestos.new
      self.children_nodes << @impuestos_node
      @impuestos_node
    end

    def traslado_iva_node
      return nil unless impuestos_node.is_a?(Impuestos)

      impuestos_node.traslado_iva
    end
  end
end
