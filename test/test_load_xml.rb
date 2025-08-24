# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestLoad < Minitest::Test
  def test_load_node_comprobante
    xml_string = File.read("test/files/simple_cfdi.xml")
    cfdi = Cfdi40.open(xml_string)

    assert_instance_of Cfdi40::Comprobante, cfdi
    assert_equal "06000", cfdi.lugar_expedicion
    assert_equal 190.00, cfdi.total
    assert_equal Time.new(2025, 4, 8, 20, 33, 8), cfdi.fecha
  end

  def test_load_certificate
    xml_string = File.read("test/files/simple_cfdi.xml")
    xml = REXML::Document.new(xml_string)
    x509_cert = OpenSSL::X509::Certificate.new(Base64.decode64(xml.root["Certificado"]))
    cfdi = Cfdi40.open(xml_string)

    assert_instance_of Cfdi40::Comprobante, cfdi
    assert_equal xml.root["Certificado"], cfdi.certificado
    assert_instance_of OpenSSL::X509::Certificate, cfdi.sat_csd.x509_cert
    assert_equal x509_cert, cfdi.sat_csd.x509_cert
  end

  def test_load_conceptos
    xml_string = File.read("test/files/simple_cfdi.xml")
    xml = REXML::Document.new(xml_string)
    cfdi = Cfdi40.open(xml_string)

    assert_equal 2, cfdi.concepto_nodes.count
    n = 0
    REXML::XPath.each(xml, "cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto") do |node|
      concepto = cfdi.conceptos.children_nodes[n]
      Cfdi40::Concepto.attributes.each do |method, attribute|
        if %w[ValorUnitario Importe Cantidad Descuento].include?(attribute)
          assert_equal node[attribute].to_f, concepto.public_send(method)
        else
          if node[attribute].nil?
            assert_nil concepto.public_send(method)
          else
            assert_equal node[attribute], concepto.public_send(method)
          end
        end
      end
      assert !concepto.importe_neto.nil?, "importe_neto should exist"
      n += 1
    end
  end

  def test_load_traslado_iva
    xml_string = File.read("test/files/simple_cfdi.xml")
    xml = REXML::Document.new(xml_string)
    cfdi = Cfdi40.open(xml_string)
    n = 0
    iva_nodes_count = 0
    REXML::XPath.each(xml, "cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto") do |_node|
      concepto = cfdi.conceptos.children_nodes[n]

      assert_instance_of Cfdi40::Traslado, concepto.traslado_iva_node

      iva_path = "cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto[#{n + 1}]" \
                 "/cfdi:Impuestos[1]/cfdi:Traslados[1]/cfdi:Traslado"
      iva_node = REXML::XPath.each(xml, iva_path).first
      iva_nodes_count += 1
      Cfdi40::Traslado.attributes.each do |method, attribute|
        if iva_node[attribute].nil?
          assert_nil concepto.traslado_iva_node.public_send(method)
        else
          if %w[Base TasaOCuota Importe].include?(attribute)
            assert_equal iva_node.attributes[attribute].to_f.round(2), concepto.traslado_iva_node.public_send(method)
          else
            assert_equal iva_node.attributes[attribute], concepto.traslado_iva_node.public_send(method)
          end
        end
      end
      n += 1
    end

    assert_equal 2, n
    assert_equal 2, iva_nodes_count
  end

  def test_load_impuestos
    xml_string = File.read("test/files/simple_cfdi.xml")
    xml = REXML::Document.new(xml_string)
    cfdi = Cfdi40.open(xml_string)
    impuestos_node = REXML::XPath.first(xml, "cfdi:Comprobante/cfdi:Impuestos")

    assert_equal impuestos_node["TotalImpuestosTrasladados"].to_f, cfdi.total_impuestos_trasladados
    total_iva_path = "cfdi:Comprobante/cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado[@Impuesto='002']"
    total_iva_node = REXML::XPath.first(xml, total_iva_path)
    Cfdi40::Traslado.attributes.each do |method, attribute|
      if total_iva_node[attribute].nil?
        assert_nil cfdi.total_iva_node.public_send(method)
      else
        if %w[Base TasaOCuota Importe].include?(attribute)
          assert_equal total_iva_node[attribute].to_f, cfdi.total_iva_node.public_send(method)
        else
          assert_equal total_iva_node[attribute], cfdi.total_iva_node.public_send(method)
        end
      end
    end
    assert_equal 26.21, cfdi.total_iva
  end

  def test_load_emisor
    xml_string = File.read("test/files/simple_cfdi.xml")
    xml = REXML::Document.new(xml_string)
    cfdi = Cfdi40.open(xml_string)
    emisor_node = REXML::XPath.first(xml, "cfdi:Comprobante/cfdi:Emisor")
    Cfdi40::Emisor.attributes.each do |method, attribute|
      if emisor_node[attribute].nil?
        assert_nil cfdi.emisor.public_send(method)
      else
        assert_equal emisor_node[attribute], cfdi.emisor.public_send(method)
      end
    end
  end

  def test_load_receptor
    xml_string = File.read("test/files/simple_cfdi.xml")
    xml = REXML::Document.new(xml_string)
    cfdi = Cfdi40.open(xml_string)
    receptor_node = REXML::XPath.first(xml, "cfdi:Comprobante/cfdi:Receptor")
    Cfdi40::Receptor.attributes.each do |method, attribute|
      if receptor_node[attribute].nil?
        assert_nil cfdi.receptor.public_send(method)
      else
        assert_equal receptor_node[attribute], cfdi.receptor.public_send(method)
      end
    end
  end

  def test_add_concepto_to_loaded_cfdi
    xml_string = File.read("test/files/simple_cfdi.xml")
    cfdi = Cfdi40.open(xml_string)
    total_xml = cfdi.total
    cfdi.add_concepto(
      cantidad: 2,
      clave_prod_serv: "81111500",
      clave_unidad: "E48",
      descripcion: "Tercer concepto",
      precio_neto: 40
    )

    assert_equal 3, cfdi.conceptos.children_nodes.count
    xml_doc = REXML::Document.new(cfdi.to_xml)

    assert_equal 3, REXML::XPath.match(xml_doc, "//cfdi:Concepto").size
    assert_equal total_xml.to_f + 80, cfdi.total
  end

  def test_that_do_not_calculate_total_in_readonly_mode
    xml_string = File.read("test/files/simple_cfdi.xml")
    xml_string.gsub!(/190.00/, '199.50')
    cfdi = Cfdi40.open(xml_string, mode: 'ro')
    assert_equal 199.50, cfdi.total
  end

  def test_that_cfdi_can_not_be_modified_in_read_only_mode
    xml_string = File.read("test/files/simple_cfdi.xml")
    cfdi = Cfdi40.open(xml_string, mode: 'ro')
    concepto = cfdi.concepto_nodes.first
    assert_raises(Cfdi40::Error) do
      concepto.cantidad = 5
    end
  end

  def test_that_loaded_xml_is_keeped
    xml_string = File.read("test/files/simple_cfdi.xml")
    cfdi = Cfdi40.open(xml_string, mode: 'ro')
    assert_equal xml_string, cfdi.loaded_xml
  end

  def test_that_signed_cfdi_is_readonly
    xml_string = File.read("test/files/signed_cfdi.xml")
    cfdi = Cfdi40.open(xml_string)
    assert cfdi.readonly, "expected readonly cfdi"
  end

  def test_that_signed_cfdi_is_not_modified
    xml_string = File.read("test/files/signed_cfdi.xml")
    cfdi = Cfdi40.open(xml_string)
    assert_equal xml_string, cfdi.to_xml
  end

  def test_that_lodaded_xml_is_removed_when_add_new_concepto
    xml_string = File.read("test/files/simple_cfdi.xml")
    cfdi = Cfdi40.open(xml_string)
    cfdi.add_concepto(
      cantidad: 2,
      clave_prod_serv: "81111500",
      clave_unidad: "E48",
      descripcion: "Tercer concepto",
      precio_neto: 40
    )
    assert_nil cfdi.loaded_xml
  end

  def test_that_lodaded_xml_is_removed_when_fecha_is_changed
    xml_string = File.read("test/files/simple_cfdi.xml")
    cfdi = Cfdi40.open(xml_string)
    cfdi.fecha = Time.now

    assert_nil cfdi.loaded_xml
  end

  def test_nil_timbre
    xml_string = File.read("test/files/simple_cfdi.xml")
    cfdi = Cfdi40.open(xml_string)
    assert_nil cfdi.timbre
  end

  def test_access_to_timbre
    cfdi = Cfdi40.open(File.read('test/files/cfdi_timbrado.xml'))
    assert_instance_of Cfdi40::Timbre, cfdi.timbre
    assert_equal "8E5C7749-7E57-4EC6-9EBD-7971F875DF0A", cfdi.timbre.uuid
  end

  # TODO: Prueba para validar que sea un CFDI y que sea version 4.0
  # TODO: ¿Puede validar la firma (si existe) del cfdi cargado?
end
