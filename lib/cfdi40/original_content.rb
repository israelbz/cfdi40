# Extracts the "cadena original" from a XML
module Cfdi40
  class OriginalContent
    LOCAL_XSLT_PATH = File.join(File.dirname(__FILE__), "..", "..", "lib/xslt/cadenaoriginal_local.xslt")

    def self.generate(xml_string)
      generator = new(xml_string)
      generator.original_content
    end

    def initialize(xml)
      @xml_doc = Nokogiri::XML(xml)
    end

    def original_content
      xslt = Nokogiri::XSLT(File.open(LOCAL_XSLT_PATH))
      transformed = xslt.transform(@xml_doc)
      # The ampersand (&) char must be used in original content
      # even though the documentation indicates otherwise
      transformed.children.to_s.gsub("&amp;", "&").strip
    end
  end
end
