# frozen_string_literal: true

# Create and Read XML documents
module Cfdi40
  class Comprobante < Node
    define_namespace "xsi", "http://www.w3.org/2001/XMLSchema-instance"
    define_namespace "cfdi", "http://www.sat.gob.mx/cfd/4"
    define_attribute :schema_location,
                     xml_attribute: 'xsi:schemaLocation',
                     readonly: true,
                     default: "http://www.sat.gob.mx/cfd/4 " \
                              "http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd"
    define_attribute :version, xml_attribute: 'Version', readonly: true, default: '4.0'
    define_attribute :serie, xml_attribute: 'Serie'
    define_attribute :folio, xml_attribute: 'Folio'
    define_attribute :fecha, xml_attribute: 'Fecha'
    define_attribute :sello, xml_attribute: 'Sello', readonly: true
    define_attribute :forma_pago, xml_attribute: 'FormaPago'
    define_attribute :no_certificado, xml_attribute: 'NoCertificado'
    define_attribute :certificado, xml_attribute: 'Certificado'
    define_attribute :condiciones_de_pago, xml_attribute: 'CondicionesDePago'
    define_attribute :subtotal, xml_attribute: 'SubTotal', format: :t_ImporteMXN
    define_attribute :descuento, xml_attribute: 'Descuento', format: :t_ImporteMXN
    define_attribute :moneda, xml_attribute: 'Moneda', default: 'MXN'
    define_attribute :tipo_cambio, xml_attribute: 'TipoCambio'
    define_attribute :total, xml_attribute: 'Total', format: :t_ImporteMXN
    define_attribute :tipo_de_comprobante, xml_attribute: 'TipoDeComprobante', default: 'I'
    define_attribute :exportacion, xml_attribute: 'Exportacion', default: '01'
    define_attribute :metodo_pago, xml_attribute: 'MetodoPago'
    define_attribute :lugar_expedicion, xml_attribute: 'LugarExpedicion'
    define_attribute :confirmacion, xml_attribute: 'Confirmacion'

    attr_reader :emisor, :receptor, :x509_cert, :conceptos, :private_key
    attr_reader :errors
    attr_writer :key_data, :key_pass

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
      @fecha ||= Time.now.strftime("%Y-%m-%dT%H:%M:%S")
      @children_nodes = [@emisor, @receptor, @conceptos]
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
      emisor.nombre = @sat_csd.name
      @no_certificado = @sat_csd.no_certificado
      @certificado = @sat_csd.cert64
      true
    end

    def key_path=(path)
      @key_data = File.read(path)
    end

    def sign
      @sat_csd ||= SatCsd.new
      load_private_key if @sat_csd.private_key.nil?
      return unless @sat_csd.private_key

      raise Error, 'Key and certificate not match' unless @sat_csd.valid_pair?

      digest = @sat_csd.private_key.sign(OpenSSL::Digest.new('SHA256'), original_content)
      @sello = Base64.strict_encode64 digest
      @docxml = nil
    end

    # clave_prod_serv
    # no_identificacion
    # cantidad
    # clave_unidad
    # unidad
    # descripcion
    # valor_unitario
    # importe
    # descuento
    # objeto_imp
    #
    # TODO: Document accepted attributes and its use
    def add_concepto(attributes = {})
      concepto = Concepto.new
      concepto.parent_node = @conceptos
      attributes.each do |key, value|
        method_name = "#{key}=".to_sym
        if concepto.respond_to?(method_name)
          concepto.public_send(method_name, value)
        else
          raise Error, ":#{key} no se puede asignar al concepto"
        end
      end
      concepto.calculate!
      @conceptos.children_nodes << concepto
      calculate!
      concepto
    end

    def to_s
      to_xml
    end

    def to_xml
      sign
      docxml.to_xml
    end

    def valid?
      schema_validator = SchemaValidator.new(to_s)
      return true if schema_validator.valid?

      @errors = schema_validator.errors
      @errors.empty?
    end

    def cadena_original
      original_content
    end

    def original_content
      xslt_path = File.join(File.dirname(__FILE__), '..', '..', 'lib/xslt/cadenaoriginal_local.xslt')
      xslt = Nokogiri::XSLT(File.open(xslt_path))
      transformed = xslt.transform(docxml)
      # The ampersand (&) char must be used in original content
      # even though the documentation indicates otherwise
      transformed.children.to_s.gsub('&amp;', '&').strip
    end

    private

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

    def calculate!
      @subtotal = @conceptos.children_nodes.map(&:importe).sum
      @total = @conceptos.children_nodes.map(&:importe_neto).sum
      add_traslados_summary_node
    end

    def add_traslados_summary_node
      return if traslados_summary.empty?

      impuestos.total_impuestos_trasladados = 0
      traslados.children_nodes = []
      traslados_summary.each do |key, value|
        #TODO: Sumar los impuestos y agregarlos a los nodos globales de traslados
        traslado = Traslado.new
        traslado.parent_node = impuestos
        traslado.impuesto, traslado.tasa_o_cuota, traslado.tipo_factor = key
        traslado.base = value[:base]
        traslado.importe = value[:importe]
        traslados.children_nodes << traslado
        impuestos.total_impuestos_trasladados += value[:importe]
      end
    end

    def concepto_nodes
      @conceptos.children_nodes
    end

    # Returns a hash with a summary.
    # The key is an Array ['impuesto, 'tasa_o_cuota', 'TipoFactor] and the value is
    # another hash the sum of 'Importe' and  'Base'
    def traslados_summary
      summary = {}
      concepto_nodes.map(&:traslado_nodes).flatten.each do |traslado|
        key = [traslado.impuesto, traslado.tasa_o_cuota, traslado.tipo_factor]
        summary[key] ||= { base: 0, importe: 0 }
        summary[key][:base] += traslado.base
        summary[key][:importe] += traslado.importe
      end
      summary
    end

    # TODO: Este método tiene que ser 'impuestos'
    #       si nos atenemos a que los que acaban con _node buscan en los hijos
    #       y los que no terminan con _node crean el nodo
    def impuestos
      return @impuestos if defined?(@impuestos)

      @impuestos = Impuestos.new
      @impuestos.parent_node = self
      @children_nodes << @impuestos
      @impuestos
    end

    def impuestos_node
      children_nodes.select { |n| n.is_a?(Impuestos)}.first
    end

    def traslados
      return nil if impuestos_node.nil?

      impuestos_node.traslados
    end

    # Eliminar
    def traslado_iva_node
      impuestos_node.traslado_iva
    end

    def load_private_key
      return unless defined?(@key_data)
      
      @sat_csd ||= SatCsd.new
      @sat_csd.set_private_key(@key_data, (defined?(@key_pass) ? @key_pass : nil))
    end
  end
end
