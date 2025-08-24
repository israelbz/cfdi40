# frozen_string_literal: true

# Methods related to create a new Comprobante
# from an XML (string)
module Cfdi40
  class XmlLoader
    attr_reader :cfdi, :xml_doc, :mode

    def initialize(xml_string, mode)
      @xml_doc = Nokogiri::XML(xml_string)
      @mode = mode
      # TODO. validar versión del CFDI definido en xml_doc
      @cfdi = Cfdi40::Comprobante.new
      @cfdi.load_from_ng_node(xml_doc.root)
      @cfdi.load_cert
      load_emisor
      load_receptor
      load_conceptos
      load_impuestos
      load_tfd

      @cfdi.lock if readonly?
      @cfdi.loaded_xml = xml_string
      @cfdi
    end

    private

    def readonly?
      return true if mode == 'ro'

      @xml_doc.root.attributes["Sello"].to_s != ''
    end

    def load_conceptos
      n_concepto = 0
      xml_doc.xpath("//cfdi:Concepto").each do |node|
        n_concepto += 1
        concepto = @cfdi.load_concepto(node)
        iva_path = "//cfdi:Concepto[#{n_concepto}]/cfdi:Impuestos[1]/cfdi:Traslados[1]/cfdi:Traslado[@Impuesto='002']"
        iva_node = xml_doc.xpath(iva_path).first
        concepto.load_traslado_iva(iva_node) if iva_node
      end
    end

    def load_emisor
      ng_emisor_node = xml_doc.xpath("//cfdi:Emisor").first
      return if ng_emisor_node.nil?

      @cfdi.emisor.load_from_ng_node(ng_emisor_node)
    end

    def load_receptor
      ng_receptor_node = xml_doc.xpath("//cfdi:Receptor").first
      return if ng_receptor_node.nil?

      @cfdi.receptor.load_from_ng_node(ng_receptor_node)
    end

    def load_impuestos
      impuestos_node = xml_doc.xpath("cfdi:Comprobante/cfdi:Impuestos").first
      return if impuestos_node.nil?

      @cfdi.load_impuestos(impuestos_node)
    end

    def load_tfd
      tfd_namespace = { "tfd" => "http://www.sat.gob.mx/TimbreFiscalDigital" }
      tfd_node = xml_doc.xpath("//tfd:TimbreFiscalDigital", tfd_namespace).first
      return if tfd_node.nil?

      @cfdi.load_tfd(tfd_node)
    end
  end
end
