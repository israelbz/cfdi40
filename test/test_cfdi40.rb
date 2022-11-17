# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestCfdi40 < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Cfdi40::VERSION
  end

  def test_that_create_a_new_cfdi
    cfdi = Cfdi40.new

    assert_instance_of Comprobante, cfdi
  end

  def test_cfdi_namespaces
    xml = REXML::Document.new(Cfdi40.new.to_s)

    assert_equal "Comprobante", xml.root.name
    assert_equal "http://www.sat.gob.mx/cfd/4", xml.root.attributes["cfdi"]
  end

  def test_cfdi_schema_location
    xml = REXML::Document.new(Cfdi40.new.to_s)

    assert_equal "http://www.w3.org/2001/XMLSchema-instance", xml.root.attributes["xsi"]
    assert_equal "http://www.sat.gob.mx/cfd/3 " \
                 "http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd",
                 xml.root.attributes["schemaLocation"]
  end

  def test_cfdi_version
    xml = REXML::Document.new(Cfdi40.new.to_s)

    assert_equal "4.0", xml.root.attributes["Version"]
  end
end
