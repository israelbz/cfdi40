# frozen_string_literal: true

# Create and Read XML documents
module Cfdi40
  # root node
  class Comprobante < Node
    define_namespace "xsi", "http://www.w3.org/2001/XMLSchema-instance"
    define_namespace "cfdi", "http://www.sat.gob.mx/cfd/4"
    define_attribute :schema_location,
                     xml_attribute: "xsi:schemaLocation",
                     readonly: true,
                     default: "http://www.sat.gob.mx/cfd/4 " \
                              "http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd"
    define_attribute :version, xml_attribute: "Version", readonly: true, default: "4.0"
    define_attribute :serie, xml_attribute: "Serie"
    define_attribute :folio, xml_attribute: "Folio"
    define_attribute :fecha, xml_attribute: "Fecha", format: :t_FechaH
    define_attribute :sello, xml_attribute: "Sello", readonly: true
    define_attribute :forma_pago, xml_attribute: "FormaPago"
    define_attribute :no_certificado, xml_attribute: "NoCertificado"
    define_attribute :certificado, xml_attribute: "Certificado"
    define_attribute :condiciones_de_pago, xml_attribute: "CondicionesDePago"
    define_attribute :subtotal, xml_attribute: "SubTotal", format: :t_ImporteMXN
    define_attribute :descuento, xml_attribute: "Descuento", format: :t_ImporteMXN
    define_attribute :moneda, xml_attribute: "Moneda", default: "MXN"
    define_attribute :tipo_cambio, xml_attribute: "TipoCambio"
    define_attribute :total, xml_attribute: "Total", format: :t_ImporteMXN
    define_attribute :tipo_de_comprobante, xml_attribute: "TipoDeComprobante", default: "I"
    define_attribute :exportacion, xml_attribute: "Exportacion", default: "01"
    define_attribute :metodo_pago, xml_attribute: "MetodoPago"
    define_attribute :lugar_expedicion, xml_attribute: "LugarExpedicion"
    define_attribute :confirmacion, xml_attribute: "Confirmacion"

    attr_reader :emisor, :receptor, :conceptos, :private_key, :sat_csd, :errors, :cadena_original, :cfdi_relacionados
    attr_writer :key_data, :key_pass, :namespace_pagos_on_root
    attr_accessor :loaded_xml

    def initialize
      super
      @errors = []
      @conceptos = Conceptos.new
      @conceptos.parent_node = self
      @emisor = Emisor.new
      @emisor.parent_node = self
      @receptor = Receptor.new
      @receptor.parent_node = self
      @sat_csd = SatCsd.new
      @fecha ||= Time.now
      @children_nodes = [@emisor, @receptor, @conceptos]
      @cfdi_relacionados = []
      @namespace_pagos_on_root = false
      set_defaults
    end

    # Accept a path to read the certificate.
    # Certificate is a X509 file. SAT generates those files in
    # DER format.
    def cert_path=(path)
      self.cert_der = File.read(path)
    end

    def cert_der=(cert_data)
      @sat_csd ||= SatCsd.new
      @sat_csd.cert_der = cert_data
      emisor.rfc = @sat_csd.rfc
      emisor.nombre ||= @sat_csd.name
      @no_certificado = @sat_csd.no_certificado
      @certificado = @sat_csd.cert64
      true
    end

    def key_path=(path)
      @key_data = File.read(path)
    end

    # Load from attribute 'Certificado' when the CFDi is
    # loaded from a string
    def load_cert
      return if @sat_csd&.cert64

      @sat_csd ||= SatCsd.new
      @sat_csd.cert_der = OpenSSL::X509::Certificate.new(Base64.decode64(certificado))
      true
    rescue StandardError
      # puts "Waring; Unable to load certificate from XML string"
      false
    end

    def sign
      @sat_csd ||= SatCsd.new
      load_private_key if @sat_csd.private_key.nil?
      return unless @sat_csd.private_key

      raise Error, "Key and certificate not match" unless @sat_csd.valid_pair?

      @cadena_original = original_content
      digest = @sat_csd.private_key.sign(OpenSSL::Digest.new("SHA256"), @cadena_original)
      @sello = Base64.strict_encode64 digest
      lock
      @docxml = nil
    end

    # ## Required attributes
    #
    # +clave_prod_serv+:: From SAT catalogue
    # +clave_unidad+:: From SAT catalogue
    # +cantidad+:: Must be greather than 0
    # +descripcion+:: Product or service description
    #
    # ### Price and Taxes attributes
    #
    # +tasa_iva+:: Decimal between 0 and 1. Nil means exempt. Default value is 0.16
    # +tasa_ieps+:: Decimal between 0 and 1. Nil means exempt. Default value is null
    # +precio_bruto+:: Price before apply taxes or gross price.
    #                  All quantities are calculated based on this price and taxes rate.
    # +precio_neto+:: Precio after taxes or net price. All quantities are calculated from this prices.
    #                 When both, +precio_neto+ and +precio_bruto+ exist, +precio_neto+ is used
    #
    # The most common usage requires only the net price (+precio_neto+).
    #
    # ## Optional attributes:
    # +no_identificacion+::
    # +unidad+::
    # +descuento+:: PENDING
    #
    # ## Special attributes
    #
    # ### IEDU attributes
    #
    # IEDU node (path: cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto/cfdi:ComplementoConcepto/iedu:instEducativas) is
    # generated when one of +iedu_nombre_alumno+, +iedu_curp+, +iedu_nivel_educativo+ exist.
    #
    # +iedu_nombre_alumno+::
    # +iedu_curp+::
    # +iedu_nivel_educativo+::
    # +iedu_aut_rvoe+::
    # +iedu_rfc_pago+::
    #
    def add_concepto(attributes = {})
      raise Error, "CFDi tipo pago no acepta conceptos" if tipo_de_comprobante == "P"

      concepto = Concepto.new
      concepto.parent_node = @conceptos
      attributes.each do |key, value|
        method_name = "#{key}=".to_sym
        raise Error, ":#{key} no se puede asignar al concepto" unless concepto.respond_to?(method_name)

        concepto.public_send(method_name, value)
      end
      concepto.calculate!
      @conceptos.children_nodes << concepto
      calculate!
      concepto
    end

    # Load node 'Concepto' from a Nokogiri::XML::Element
    def load_concepto(ng_node)
      concepto = Concepto.new
      concepto.parent_node = @conceptos
      concepto.load_from_ng_node(ng_node)
      concepto.precio_bruto = concepto.valor_unitario.to_f
      @conceptos.children_nodes << concepto
      concepto
    end

    # Load node 'Concepto' (rep) from a Nokogiri::XML::Element
    def load_concepto_rep(ng_node)
      concepto = ConceptoRep.new
      concepto.parent_node = @conceptos
      concepto.load_from_ng_node(ng_node)
      concepto.precio_bruto = concepto.valor_unitario.to_f
      @conceptos.children_nodes << concepto
      concepto
    end

    # Load node cfdi:Comprobante/cfdi:Impuestos
    #
    # Normally this node is calculated but must be read from the
    # XML when a CFDi is loaded
    def load_impuestos(ng_node)
      impuestos.load_from_ng_node(ng_node)
      ng_iva_node = ng_node.xpath("cfdi:Traslados/cfdi:Traslado[@Impuesto='002']").first
      return true if ng_iva_node.nil?

      impuestos.traslado_iva.load_from_ng_node(ng_iva_node)
      true
    end

    # TODO: Doc params add_pago
    # monto
    # uuid
    # folio
    # serie
    # num_parcialidad
    # fecha_pago
    # forma_pago
    # importe_saldo_anterior
    # objeto_impuestos
    def add_pago(attributes = {})
      raise Error, "CFDi debe ser tipo 'P'" unless tipo_de_comprobante == "P"

      add_node_concepto_actividad_pago
      complemento.add_pago(attributes)
    end

    def remove_pago(index)
      return unless defined?(@complemento)
      return if complemento.pagos.pago_nodes.empty?

      complemento.pagos.remove_pago(index.to_i)
    end

    # See test_adding_pago_with_n_docto_relacionados in file test/test_cfdi40_rep.rb
    def add_splitted_pago(attributes = {})
      raise Error, "CFDi debe ser tipo 'P'" unless tipo_de_comprobante == "P"

      add_node_concepto_actividad_pago
      complemento.add_splitted_pago(attributes)
    end

    def add_cfdi_relacionado(tipo_relacion, uuid)
      cfdi_relacionados_node = CfdiRelacionados.new
      cfdi_relacionados_node.tipo_relacion = tipo_relacion
      cfdi_relacionados_node.parent_node = self
      cfdi_relacionados_node.add_cfdi(uuid)
      @children_nodes << cfdi_relacionados_node
      @cfdi_relacionados ||= []
      @cfdi_relacionados << cfdi_relacionados_node
      cfdi_relacionados_node
    end

    def cfdi_relacionados_nodes
      @cfdi_relacionados
    end

    def remove_cfdi_relacionado(index)
      return if @cfdi_relacionados.empty?

      nodo = @cfdi_relacionados[index.to_i]
      return unless nodo

      delete_child(nodo)
      @cfdi_relacionados.delete_at(index.to_i)
    end

    def to_s
      to_xml
    end

    def to_xml
      return loaded_xml if !loaded_xml.nil? && signed?

      sign unless signed?
      return xml_string_ns_pagos_on_root if @namespace_pagos_on_root && pago_nodes.count > 0

      docxml.to_xml
    end

    def valid?
      schema_validator = SchemaValidator.new(to_s)
      return true if schema_validator.valid?

      @errors = schema_validator.errors
      @errors.empty?
    end

    def valid_signature?
      return false unless signed?

      signature_validator = SignatureValidator.new(to_xml)
      signature_validator.valid?
    end

    def signed?
      !docxml.root.attributes["Sello"].nil?
    end

    def original_content
      xml_string = loaded_xml.nil? ? docxml.to_s : loaded_xml

      Cfdi40::OriginalContent.generate(xml_string)
    end

    # Shortcut to attribute TotalImpuestosTrasladados of impuestos node
    def total_impuestos_trasladados
      return nil unless impuestos_node

      impuestos_node.total_impuestos_trasladados
    end

    def calculate!
      return false if readonly

      @docxml = nil
      @subtotal = @conceptos.children_nodes.map(&:importe).map(&:to_f).sum
      @total = @conceptos.children_nodes.map(&:importe_neto).map(&:to_f).sum
      add_traslados_summary_node
      true
    end

    def concepto_nodes
      @conceptos.children_nodes
    end

    def pago_nodes
      return [] unless defined?(@complemento)

      complemento.pago_nodes
    end

    def total_iva_node
      # TODO: Puede haber más de un nodo, cuando hay varias tasas de iva
      return nil unless impuestos_node

      impuestos_node.traslado_iva
    end

    def total_iva
      return 0 unless traslados

      traslados.traslados_iva.map(&:importe).map(&:to_f).sum.round(2)
    end

    def load_tfd(tfd_node)
      timbre = Cfdi40::Timbre.new
      timbre.load_from_ng_node(tfd_node)
      timbre.parent_node = complemento
      complemento.children_nodes << timbre
      timbre
    end

    def load_pagos(pagos_node)
      complemento.load_pagos(pagos_node)
    end

    def timbre
      return nil unless defined?(@complemento)

      complemento.timbre
    end

    # Some PACs require that the namespace pago20 be placed in root node
    def add_namespace_pagos_to_root
      self.class.define_namespace "pago20", "http://www.sat.gob.mx/Pagos20"
      @schema_location += " http://www.sat.gob.mx/Pagos20 " \
                           "http://www.sat.gob.mx/sitio_internet/cfd/Pagos/Pagos20.xsd"
      true
    end

    private

    def add_node_concepto_actividad_pago
      return if @conceptos.children_nodes.size > 0

      @receptor.uso_cfdi = "CP01"
      @concepto_actividad = ConceptoRep.new
      @concepto_actividad.precio_bruto = 0
      @concepto_actividad.tasa_iva = nil
      @concepto_actividad.calculate!
      @conceptos.add_child_node @concepto_actividad
      calculate!
    end

    def docxml
      return @docxml if defined?(@docxml) && !@docxml.nil?

      @docxml = Nokogiri::XML::Document.new("1.0")
      @docxml.encoding = "utf-8"
      add_root_node
      @docxml
    end

    def add_root_node
      self.xml_document = @docxml
      self.xml_parent = @docxml
      create_xml_node
    end

    def add_traslados_summary_node
      return if traslados_summary.empty?

      impuestos.total_impuestos_trasladados = 0
      traslados.children_nodes = []
      traslados_summary.each do |key, value|
        traslado = Traslado.new
        traslado.parent_node = impuestos
        traslado.impuesto, traslado.tasa_o_cuota, traslado.tipo_factor = key
        traslado.base = value[:base]
        traslado.importe = value[:importe]
        traslados.children_nodes << traslado
        impuestos.total_impuestos_trasladados += value[:importe]
      end
    end

    # Returns a hash with a summary.
    # The key is an Array ['impuesto, 'tasa_o_cuota', 'TipoFactor] and the value is
    # another hash the sum of 'Importe' and  'Base'
    def traslados_summary
      summary = {}
      concepto_nodes.map(&:traslado_nodes).flatten.each do |traslado|
        key = [traslado.impuesto, traslado.tasa_o_cuota, traslado.tipo_factor]
        summary[key] ||= { base: 0, importe: 0 }
        summary[key][:base] += traslado.base.to_f
        summary[key][:importe] += traslado.importe.to_f
      end
      summary
    end

    # Returns a Cfdi40::Node for 'Impuestos'
    def impuestos
      return @impuestos if defined?(@impuestos)

      @impuestos = Impuestos.new
      @impuestos.parent_node = self
      @children_nodes << @impuestos
      @impuestos
    end

    def impuestos_node
      children_nodes.select { |n| n.is_a?(Impuestos) }.first
    end

    def traslados
      return nil if impuestos_node.nil?

      impuestos_node.traslados
    end

    def load_private_key
      return unless defined?(@key_data)

      @sat_csd ||= SatCsd.new
      @sat_csd.set_private_key(@key_data, (defined?(@key_pass) ? @key_pass : nil))
    end

    def complemento
      return @complemento if defined?(@complemento)

      @complemento = Complemento.new
      @complemento.parent_node = self
      @children_nodes << @complemento
      @complemento
    end

    # Creates a new XML an change and puts the namespace pagos on root element.
    def xml_string_ns_pagos_on_root
      tmp_nkgdoc = Nokogiri::XML(docxml.to_xml)
      tmp_nkgdoc.root["xmlns:pago20"] = "http://www.sat.gob.mx/Pagos20"
      unless tmp_nkgdoc.root["xsi:schemaLocation"].include?("Pagos20")
        tmp_nkgdoc.root["xsi:schemaLocation"] += " http://www.sat.gob.mx/Pagos20" \
                                                 " http://www.sat.gob.mx/sitio_internet/cfd/Pagos/Pagos20.xsd"
      end
      tmp_nkgdoc.to_xml
    end
  end
end
