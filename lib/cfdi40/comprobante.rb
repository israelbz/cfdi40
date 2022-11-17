# frozen_string_literal: true

# Create and Read XML documents
class Comprobante
  attr_reader :docxml

  def initialize
    new_docxml
  end

  def to_s
    docxml.to_xml
  end

  private

  def new_docxml
    @docxml = Nokogiri::XML::Document.new("1.0")
    @docxml.encoding = "utf-8"
    root = @docxml.create_element "cfdi:Comprobante"
    root.add_namespace "xsi", "http://www.w3.org/2001/XMLSchema-instance"
    root.add_namespace "cfdi", "http://www.sat.gob.mx/cfd/4"
    root["xsi:schemaLocation"] = "http://www.sat.gob.mx/cfd/3 " \
                                 "http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd"
    root["Version"] = "4.0"

    @docxml.add_child root
    @docxml
  end
end
