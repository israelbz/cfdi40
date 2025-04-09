# frozen_string_literal: true

# Validates Schema Using xsd files
module Cfdi40
  class SchemaValidator
    # options = Nokogiri::XML::ParseOptions.new.nononet
    # schema = Nokogiri::XML::Schema(Net::HTTP.get('www.sat.gob.mx', '/sitio_internet/cfd/4/cfdv40.xsd'), options)
    # schema = Nokogiri::XML::Schema(File.open("/home/israel/git/cfdi40/lib/xsd/cfdv40.xsd"), options)

    attr_reader :errors

    LOCAL_XSD_PATH = File.join(File.dirname(__FILE__), "..", "xsd", "cfdv40.xsd")

    # Param xml is xml string
    def initialize(xml)
      @xml_doc = Nokogiri::XML(xml)
      @schema = Nokogiri::XML::Schema(File.open(LOCAL_XSD_PATH))
    end

    def valid?
      validate unless defined?(@errors)

      @errors.empty?
    end

    private

    def validate
      @errors = @schema.validate(@xml_doc)
    end
  end
end
