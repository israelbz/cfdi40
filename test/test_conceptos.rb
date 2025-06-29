# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestCfdi40 < Minitest::Test
  include Cfdi40Helper

  def test_that_delete_concepto
    cfdi = simple_cfdi
    cfdi.add_concepto(simple_concepto.merge(cantidad: 1, descripcion: "Segundo", precio_neto: 116))
    cfdi.add_concepto(simple_concepto.merge(cantidad: 5, descripcion: "Tecero", precio_neto: 20))
    xml = REXML::Document.new(cfdi.to_xml)
    node_conceptos_path = "cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto"

    assert_equal 3, REXML::XPath.match(xml, node_conceptos_path).size
    assert_equal "256.00", xml.root["Total"]

    cfdi.conceptos.delete_at(1)
    xml = REXML::Document.new(cfdi.to_xml)

    assert_equal 2, REXML::XPath.match(xml, node_conceptos_path).size
    assert_equal "140.00", xml.root["Total"]
  end

  def test_that_update_total_when_delete_loaded_concepto
    xml_string = File.read("test/files/simple_cfdi.xml")
    cfdi = Cfdi40.open(xml_string)
    assert_equal 190.00, cfdi.total.to_f
    cfdi.conceptos.delete_at(0)
    assert_equal 150.00, cfdi.total.to_f
    cfdi.conceptos.delete_at(0)
    assert_equal 0, cfdi.total.to_f
  end
end
