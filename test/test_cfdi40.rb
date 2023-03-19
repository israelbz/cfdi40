# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestCfdi40 < Minitest::Test
  include Cfdi40Helper

  def test_that_it_has_a_version_number
    refute_nil ::Cfdi40::VERSION
  end

  def test_that_create_a_new_cfdi
    cfdi = Cfdi40.new

    assert_instance_of Cfdi40::Comprobante, cfdi
  end

  def test_cfdi_namespaces
    xml = REXML::Document.new(Cfdi40.new.to_s)

    assert_equal "Comprobante", xml.root.name
    assert_equal "http://www.sat.gob.mx/cfd/4", xml.root.attributes["cfdi"]
  end

  def test_cfdi_schema_location
    xml = REXML::Document.new(Cfdi40.new.to_s)

    assert_equal "http://www.w3.org/2001/XMLSchema-instance", xml.root.attributes["xsi"]
    assert_equal "http://www.sat.gob.mx/cfd/4 " \
                 "http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd",
                 xml.root.attributes["schemaLocation"]
  end

  def test_cfdi_version
    xml = REXML::Document.new(Cfdi40.new.to_s)

    assert_equal "4.0", xml.root.attributes["Version"]
  end

  def test_that_emisor_takes_data_from_certificate
    cfdi = Cfdi40.new
    cfdi.cert_path = 'test/files/cert1.cer'
    assert_instance_of Cfdi40::Emisor, cfdi.emisor
    assert_equal 'XAMA620210DQ5', cfdi.emisor.rfc
    assert_equal 'ALBA XKARAJAM MENDEZ', cfdi.emisor.nombre
  end

  def test_that_exist_receptor
    cfdi = Cfdi40.new
    assert_instance_of Cfdi40::Receptor, cfdi.receptor
  end

  def test_that_generate_original_content_string
    cfdi = simple_cfdi_with_key_cert_path
    assert_match(/\A||.*||\z/, cfdi.original_content)
    assert_match(/XAXX010101000/, cfdi.original_content)
    assert_match(/XAMA620210DQ5/, cfdi.original_content)
  end

  def test_that_generate_a_new_cfdi_with_minimum_data
    cfdi = simple_cfdi_with_key_cert_path
    assert_equal 1, cfdi.conceptos.children_nodes.count
    cfdi.valid?
    assert_equal [], cfdi.errors
  end

  def test_that_generate_cfdi_with_key_cert_der
    cfdi = simple_cfdi_with_key_cert_der
    assert_equal 1, cfdi.conceptos.children_nodes.count
    cfdi.valid?
    assert_equal [], cfdi.errors
  end

  def test_that_raise_error_when_key_do_not_match_with_certificate
    cfdi = simple_cfdi
    cfdi.cert_path = 'test/files/cert1.cer'
    cfdi.key_path = 'test/files/key2.key'
    cfdi.key_pass = '12345678a'
    assert_raises(Cfdi40::Error, 'Key and certificate not match') { cfdi.sign }
  end

  def test_that_calculate_default_taxes
    cfdi = cfdi_base
    cfdi.add_concepto(simple_concepto)
    # TODO: assert ObjetoImpuestos
    concepto = cfdi.conceptos.children_nodes.first
    assert_instance_of Cfdi40::Concepto, concepto
    assert_equal 3, concepto.cantidad
    assert_equal 0.16, concepto.tasa_iva
    assert_in_epsilon 16.551724, concepto.iva, 0.000001
    assert_in_epsilon 34.482759, concepto.valor_unitario, 0.000001
    assert_in_epsilon 103.448276, concepto.importe, 0.000001
    assert_equal 120, cfdi.total
  end

  def test_that_include_node_impuesto_iva
    cfdi = cfdi_base
    cfdi.add_concepto(simple_concepto)
    xml = REXML::Document.new(cfdi.to_s)
    node_path = 'cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto'
    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += '/cfdi:Impuestos'
    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += '/cfdi:Traslados'
    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += '/cfdi:Traslado'
    node = REXML::XPath.first(xml, node_path)
    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    assert_equal '002', node["Impuesto"]
    assert_equal 'Tasa', node["TipoFactor"]
    assert_equal '0.160000', node["TasaOCuota"]
    assert_equal '103.448276', node["Base"]
    assert_equal '16.551724', node["Importe"]
  end

  def test_that_not_include_taxes_node
    cfdi = cfdi_base
    cfdi.add_concepto(simple_concepto.merge(tasa_iva: 0))
    xml = REXML::Document.new(cfdi.to_s)
    node_path = 'cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto'
    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += '/cfdi:Impuestos'
    assert_nil REXML::XPath.first(xml, node_path)
  end

  def test_that_accepts_more_then_one_concepto
    cfdi = simple_cfdi
    cfdi.add_concepto(simple_concepto.merge(cantidad: 1, descripcion: 'Segundo', precio_neto: 116))
    cfdi.add_concepto(simple_concepto.merge(cantidad: 5, descripcion: 'Tecero', precio_neto: 20))
    xml = REXML::Document.new(cfdi.to_xml)
    assert_equal 3, cfdi.conceptos.children_nodes.count
    node_path = 'cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto'
    elements = xml.elements[node_path]
    assert_equal 3, elements.count
  end

  def test_that_include_global_taxes_node
    cfdi = simple_cfdi_with_key_cert_path
    cfdi.add_concepto(simple_concepto.merge(cantidad: 1, descripcion: 'Otro', precio_neto: 116))
    xml = REXML::Document.new(cfdi.to_xml)
    node_path = 'cfdi:Comprobante/cfdi:Impuestos'
    node = REXML::XPath.first(xml, node_path)
    assert_instance_of REXML::Element, node
    assert_equal '21.517241', node['TotalImpuestosTrasladados']
    node_path += '/cfdi:Traslados/cfdi:Traslado'
    node = REXML::XPath.first(xml, node_path)
    assert_instance_of REXML::Element, node
    assert_equal '002', node["Impuesto"]
    assert_equal 'Tasa', node["TipoFactor"]
    assert_equal '0.160000', node["TasaOCuota"]
    assert_equal '134.482759', node["Base"]
    assert_equal '21.517241', node["Importe"]
    cfdi.valid?
    assert_equal [], cfdi.errors
  end

  # TODO: Conceptos con diferente tasa de impuestos

  def test_that_generate_cfdi_with_inst_educativas_node
    cfdi = cfdi_with_iedu
    xml = REXML::Document.new(cfdi.to_xml)
    node_path = 'cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto/cfdi:ComplementoConcepto/iedu:instEducativas'
    node = REXML::XPath.first(xml, node_path)
    assert_instance_of REXML::Element, node
    assert_equal '1.0', node["version"]
    assert_equal 'SANCHEZ SOTRES KARLA MARIA', node["nombreAlumno"]
    assert_equal 'SASK020520MDFNTRC1', node["CURP"]
    assert_equal 'Bachillerato o su equivalente', node["nivelEducativo"]
    assert_equal "DGETI20089996", node["autRVOE"]
    assert_equal "XAXX010101000", node["rfcPago"]
    cfdi.valid?
    assert_equal [], cfdi.errors
  end
end
