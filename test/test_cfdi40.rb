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
    cfdi.cert_path = "test/files/cert1.cer"

    assert_instance_of Cfdi40::Emisor, cfdi.emisor
    assert_equal "XAMA620210DQ5", cfdi.emisor.rfc
    assert_equal "ALBA XKARAJAM MENDEZ", cfdi.emisor.nombre
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

    assert_empty cfdi.errors
  end

  def test_that_generate_cfdi_with_key_cert_der
    cfdi = simple_cfdi_with_key_cert_der

    assert_equal 1, cfdi.conceptos.children_nodes.count
    cfdi.valid?

    assert_empty cfdi.errors
  end

  def test_that_raise_error_when_key_do_not_match_with_certificate
    cfdi = simple_cfdi
    cfdi.cert_path = "test/files/cert1.cer"
    cfdi.key_path = "test/files/key2.key"
    cfdi.key_pass = "12345678a"
    assert_raises(Cfdi40::Error, "Key and certificate not match") { cfdi.sign }
  end

  def test_that_calculate_default_taxes
    cfdi = cfdi_base
    cfdi.add_concepto(simple_concepto)
    # TODO: assert ObjetoImpuestos
    concepto = cfdi.conceptos.children_nodes.first

    # puts cfdi.to_xml
    assert_instance_of Cfdi40::Concepto, concepto
    assert_equal 3, concepto.cantidad
    assert_in_delta(0.16, concepto.tasa_iva)
    assert_in_epsilon 16.551724, concepto.iva, 0.0000001
    assert_in_epsilon 34.482759, concepto.valor_unitario, 0.0000001
    assert_in_epsilon 103.448277, concepto.importe, 0.0000001
    assert_equal 120, cfdi.total
  end

  def test_that_include_node_impuesto_iva
    cfdi = cfdi_base
    cfdi.add_concepto(simple_concepto)
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto"

    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += "/cfdi:Impuestos"

    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += "/cfdi:Traslados"

    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += "/cfdi:Traslado"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    assert_equal "002", node["Impuesto"]
    assert_equal "Tasa", node["TipoFactor"]
    assert_equal "0.160000", node["TasaOCuota"]
    assert_equal "103.45", node["Base"]
    assert_equal "16.55", node["Importe"]
  end

  def test_that_not_include_taxes_node
    cfdi = cfdi_base
    cfdi.add_concepto(simple_concepto.merge(tasa_iva: nil))
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto"

    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += "/cfdi:Impuestos"

    assert_nil REXML::XPath.first(xml, node_path)
  end

  def test_that_accepts_more_then_one_concepto
    cfdi = simple_cfdi
    cfdi.add_concepto(simple_concepto.merge(cantidad: 1, descripcion: "Segundo", precio_neto: 116))
    cfdi.add_concepto(simple_concepto.merge(cantidad: 5, descripcion: "Tecero", precio_neto: 20))
    xml = REXML::Document.new(cfdi.to_xml)

    assert_equal 3, cfdi.conceptos.children_nodes.count
    node_path = "cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto"
    elements = xml.elements[node_path]

    assert_equal 3, elements.count
  end

  def test_that_include_global_taxes_node
    cfdi = simple_cfdi_with_key_cert_path
    cfdi.add_concepto(simple_concepto.merge(cantidad: 1, descripcion: "Otro", precio_neto: 116))
    xml = REXML::Document.new(cfdi.to_xml)
    node_path = "cfdi:Comprobante/cfdi:Impuestos"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_in_epsilon 21.517241, node["TotalImpuestosTrasladados"].to_f, 0.005
    assert_equal "21.52", node["TotalImpuestosTrasladados"]
    node_path += "/cfdi:Traslados/cfdi:Traslado"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "002", node["Impuesto"]
    assert_equal "Tasa", node["TipoFactor"]
    assert_equal "0.160000", node["TasaOCuota"]
    assert_in_epsilon 134.482759, node["Base"].to_f, 0.005
    assert_equal "134.48", node["Base"]
    assert_in_epsilon 21.517241, node["Importe"].to_f, 0.005
    assert_equal "21.52", node["Importe"]
    cfdi.valid?

    assert_empty cfdi.errors
  end

  def test_accessor_for_total_iva
    cfdi = simple_cfdi_with_key_cert_path
    cfdi.add_concepto(simple_concepto.merge(cantidad: 1, descripcion: "Otro", precio_neto: 116))
    assert_equal 21.52, cfdi.total_iva.to_f
  end

  def test_that_subtotal_and_total_has_two_decimals
    cfdi = simple_cfdi_with_key_cert_path
    xml = REXML::Document.new(cfdi.to_xml)
    node = REXML::XPath.first(xml, "cfdi:Comprobante")

    assert_equal "34.48", node["SubTotal"]
    assert_equal "40.00", node["Total"]
  end

  # TODO: Conceptos con diferente tasa de impuestos

  def test_that_generate_cfdi_with_inst_educativas_node
    cfdi = cfdi_with_iedu
    xml = REXML::Document.new(cfdi.to_xml)
    node_path = "cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto/cfdi:ComplementoConcepto/iedu:instEducativas"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "1.0", node["version"]
    assert_equal "SANCHEZ SOTRES KARLA MARIA", node["nombreAlumno"]
    assert_equal "SASK020520MDFNTRC1", node["CURP"]
    assert_equal "Bachillerato o su equivalente", node["nivelEducativo"]
    assert_equal "DGETI20089996", node["autRVOE"]
    assert_equal "XAXX010101000", node["rfcPago"]
    cfdi.valid?

    assert_empty cfdi.errors
  end

  def test_total_impuestos_trasladados_has_two_decimals
    cfdi = simple_cfdi_with_key_cert_path
    xml = REXML::Document.new(cfdi.to_xml)
    node = REXML::XPath.first(xml, "cfdi:Comprobante/cfdi:Impuestos")

    assert_equal "5.52", node["TotalImpuestosTrasladados"]
  end

  def test_base_in_node_traslados_has_two_decimals
    cfdi = simple_cfdi_with_key_cert_path
    xml = REXML::Document.new(cfdi.to_xml)
    node = REXML::XPath.first(xml, "cfdi:Comprobante/cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado")

    assert_equal '34.48', node["Base"]
  end

  def test_importe_in_node_traslados_has_two_decimals
    cfdi = simple_cfdi_with_key_cert_path
    xml = REXML::Document.new(cfdi.to_xml)
    node = REXML::XPath.first(xml, "cfdi:Comprobante/cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado")

    assert_equal "5.52", node["Importe"]
  end

  def test_that_cadena_original_is_keeped_when_is_signed
    cfdi = simple_cfdi_with_key_cert_path
    refute cfdi.readonly, 'cfdi should not be readonly'
    cfdi.add_concepto(simple_concepto.merge(cantidad: 1, descripcion: "Otro", precio_neto: 116))
    assert_nil cfdi.cadena_original
    cfdi.to_xml
    refute_nil cfdi.cadena_original
  end

  def test_change_to_readonly_when_is_signed
    cfdi = simple_cfdi_with_key_cert_path
    refute cfdi.readonly, 'cfdi should not be readonly'
    cfdi.add_concepto(simple_concepto.merge(cantidad: 1, descripcion: "Otro", precio_neto: 116))
    cfdi.to_xml
    assert cfdi.readonly, 'cfdi shoud be readonly when signed'
  end

  def test_fecha_is_a_time_object
    cfdi = cfdi_base
    # Default value
    assert_instance_of Time, cfdi.fecha

    expected_time = Time.new(2025, 5, 21)
    cfdi.fecha = expected_time
    assert_equal expected_time, cfdi.fecha
    xml = REXML::Document.new(cfdi.to_s)
    assert_equal "2025-05-21T00:00:00", xml.root['Fecha']


    expected_time = Time.new(2025, 1, 14, 16, 21, 13)
    cfdi.fecha = "2025-01-14T16:21:13"
    assert_equal expected_time, cfdi.fecha
    xml = REXML::Document.new(cfdi.to_s)
    assert_equal "2025-01-14T16:21:13", xml.root['Fecha']
  end

  def test_that_generate_signed_xml
    cfdi = cfdi_signed_ewe1709045u0
    xml_doc = REXML::Document.new(cfdi.to_xml)
    # puts cfdi.to_xml
    # File.open('/tmp/cfdi_pruebas_timbrado.xml', 'w') { |file| file.write cfdi.to_xml }
    refute_nil xml_doc.root["Sello"]
  end

  def test_add_cfdi_relacionado
    cfdi = Cfdi40.new
    cfdi.tipo_de_comprobante = "E"
    cfdi.emisor.rfc = "XEXX010101000"
    cfdi.receptor.rfc = "XEXX010101000"

    uuid = "ABC12345-1234-1234-1234-123456789012"
    cfdi.add_cfdi_relacionado("01", uuid)

    assert_equal 1, cfdi.cfdi_relacionados_nodes.count
    nodo = cfdi.cfdi_relacionados_nodes.first
    assert_equal "01", nodo.tipo_relacion
    assert_equal 1, nodo.cfdi_relacionados.count
    assert_equal uuid, nodo.cfdi_relacionados.first.uuid
  end

  def test_load_cfdi_relacionados
    cfdi = Cfdi40.open(File.read("test/files/cfdi_con_un_relacionado.xml"))

    assert_equal 1, cfdi.cfdi_relacionados_nodes.count
    nodo = cfdi.cfdi_relacionados_nodes.first
    assert_equal "01", nodo.tipo_relacion
    assert_equal "ABC12345-1234-1234-1234-123456789012", nodo.cfdi_relacionados.first.uuid
  end

  def test_add_second_cfdi_relacionado
    cfdi = Cfdi40.new
    cfdi.tipo_de_comprobante = "E"
    cfdi.emisor.rfc = "XEXX010101000"
    cfdi.receptor.rfc = "XEXX010101000"

    uuid1 = "AAA11111-1111-1111-1111-111111111111"
    uuid2 = "BBB22222-2222-2222-2222-222222222222"

    cfdi.add_cfdi_relacionado("01", uuid1)
    cfdi.add_cfdi_relacionado("02", uuid2)

    assert_equal 2, cfdi.cfdi_relacionados_nodes.count

    # Nodes are append in first position
    nodo1 = cfdi.cfdi_relacionados_nodes[0]
    assert_equal "02", nodo1.tipo_relacion
    assert_equal uuid2, nodo1.cfdi_relacionados.first.uuid

    nodo2 = cfdi.cfdi_relacionados_nodes[1]
    assert_equal "01", nodo2.tipo_relacion
    assert_equal uuid1, nodo2.cfdi_relacionados.first.uuid
  end

  def test_remove_first_cfdi_relacionado
    cfdi = Cfdi40.new
    cfdi.tipo_de_comprobante = "E"
    cfdi.emisor.rfc = "XEXX010101000"
    cfdi.receptor.rfc = "XEXX010101000"

    uuid1 = "AAA11111-1111-1111-1111-111111111111"
    uuid2 = "BBB22222-2222-2222-2222-222222222222"

    cfdi.add_cfdi_relacionado("01", uuid1)
    cfdi.add_cfdi_relacionado("02", uuid2)
    assert_equal 2, cfdi.cfdi_relacionados_nodes.count

    cfdi.remove_cfdi_relacionado(0)
    assert_equal 1, cfdi.cfdi_relacionados_nodes.count

    nodo = cfdi.cfdi_relacionados_nodes.first
    assert_equal "01", nodo.tipo_relacion
    assert_equal uuid1, nodo.cfdi_relacionados.first.uuid
  end

  def test_remove_last_cfdi_relacionado
    # Nodes are append in first position
    cfdi = Cfdi40.new
    cfdi.tipo_de_comprobante = "E"
    cfdi.emisor.rfc = "XEXX010101000"
    cfdi.receptor.rfc = "XEXX010101000"

    uuid1 = "AAA11111-1111-1111-1111-111111111111"
    uuid2 = "BBB22222-2222-2222-2222-222222222222"

    cfdi.add_cfdi_relacionado("01", uuid1)
    cfdi.add_cfdi_relacionado("02", uuid2)
    assert_equal 2, cfdi.cfdi_relacionados_nodes.count

    cfdi.remove_cfdi_relacionado(1)
    assert_equal 1, cfdi.cfdi_relacionados_nodes.count

    nodo = cfdi.cfdi_relacionados_nodes.first
    assert_equal "02", nodo.tipo_relacion
    assert_equal uuid2, nodo.cfdi_relacionados.first.uuid
  end

  def test_remove_cfdi_relacionado_from_xml
    cfdi = Cfdi40.open(File.read("test/files/cfdi_con_dos_relacionados.xml"))
    assert_equal 2, cfdi.cfdi_relacionados_nodes.count

    cfdi.remove_cfdi_relacionado(0)
    assert_equal 1, cfdi.cfdi_relacionados_nodes.count

    nodo = cfdi.cfdi_relacionados_nodes.first
    assert_equal "01", nodo.tipo_relacion
    assert_equal "AAA11111-1111-1111-1111-111111111111", nodo.cfdi_relacionados.first.uuid
  end
end
