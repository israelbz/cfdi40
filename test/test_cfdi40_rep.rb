# frozen_string_literal: true

require "test_helper"
require "rexml/document"

# Test for CFDis where 'tipo_documento' is 'P'
# This CFDIs contain a node "cfdi:Complemento/pagos20:Pago" known as "Complemento de pagos" or
# "Recibo electónico de pagos" (electronic payment receipt)
#
# This type of CFDi has a fixed 'concepto' and all data is added to the node "cfdi:Complemento/pagos20:Pago"
class TestCfdi40Rep < Minitest::Test
  include Cfdi40Helper

  # TODO: Varios pagos en un CFDI
  # TODO: Varios documentos en un pago
  # TODO: Varias tasas de impuestos trasladados en un documento
  # TODO: Retenciones en el pago

  def test_that_not_accept_conceptos
    cfdi = Cfdi40.new
    cfdi.tipo_de_comprobante = "P"
    assert_raises Cfdi40::Error, "CFDi tipo pago no acepta conceptos" do
      cfdi.add_concepto(simple_concepto)
    end
  end

  def datos_pago
    {
      monto: 200.17,
      uuid: "e40229b3-5c4b-46fb-9ba8-707df828a5bc",
      serie: "A",
      folio: "12345",
      num_parcialidad: 2,
      fecha_pago: "2023-04-01T12:20:34",
      forma_pago: "01",
      importe_saldo_anterior: 845.673
    }
  end

  def cfdi_pago
    cfdi = cfdi_base
    cfdi.tipo_de_comprobante = "P"
    cfdi.moneda = "XXX"

    cfdi.add_pago(datos_pago)
    cfdi
  end

  def test_that_accepts_info_for_pago
    cfdi = Cfdi40.new
    cfdi.tipo_de_comprobante = "P"

    assert cfdi.add_pago(datos_pago)
  end

  def test_version_and_xsi_pagos_node
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Complemento/pago20:Pagos"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "2.0", node["Version"]
    assert_equal "http://www.sat.gob.mx/Pagos20", node["xmlns:pago20"]
    assert_equal "http://www.sat.gob.mx/Pagos20 http://www.sat.gob.mx/sitio_internet/cfd/Pagos/Pagos20.xsd",
                 node["xsi:schemaLocation"]
  end

  def test_attributes_of_pago
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Complemento/pago20:Pagos/pago20:Pago"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "MXN", node["MonedaP"]
    assert_equal "01", node["FormaDePagoP"]
    assert_equal "2023-04-01T12:20:34", node["FechaPago"]
    assert_equal "200.17", node["Monto"]
    assert_equal "1", node["TipoCambioP"]
  end

  def test_that_include_docto_relacionado_node
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Complemento/pago20:Pagos/pago20:Pago/pago20:DoctoRelacionado"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "e40229b3-5c4b-46fb-9ba8-707df828a5bc", node["IdDocumento"]
    assert_equal "A", node["Serie"]
    assert_equal "12345", node["Folio"]
    assert_equal "MXN", node["MonedaDR"]
    assert_equal "1", node["EquivalenciaDR"]
    assert_equal "2", node["NumParcialidad"]
    assert_equal "845.67", node["ImpSaldoAnt"]
    assert_equal "200.17", node["ImpPagado"]
    assert_equal "645.50", node["ImpSaldoInsoluto"]
    assert_equal "02", node["ObjetoImpDR"]
  end

  def test_that_include_impuestos_docto_relacionado
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Complemento/pago20:Pagos/pago20:Pago/pago20:DoctoRelacionado/pago20:ImpuestosDR"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
  end

  def test_that_include_traslados_impuestos_docto_relacionado
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Complemento/pago20:Pagos/pago20:Pago/pago20:DoctoRelacionado" \
                "/pago20:ImpuestosDR/pago20:TrasladosDR"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
  end

  def test_that_include_iva_trasladado_docto_relacionado
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Complemento/pago20:Pagos/pago20:Pago/pago20:DoctoRelacionado" \
                "/pago20:ImpuestosDR/pago20:TrasladosDR/pago20:TrasladoDR"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "172.56", node["BaseDR"]
    assert_equal "002", node["ImpuestoDR"]
    assert_equal "Tasa", node["TipoFactorDR"]
    assert_equal "0.160000", node["TasaOCuotaDR"]
    assert_equal "27.61", node["ImporteDR"]
  end

  def test_that_include_total_impuestos
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Complemento/pago20:Pagos/pago20:Pago/pago20:ImpuestosP"

    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += "/pago20:TrasladosP"

    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
    node_path += "/pago20:TrasladoP"

    assert_instance_of REXML::Element, REXML::XPath.first(xml, node_path)
  end

  def test_that_node_traslado_p_has_correct_values
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Complemento/pago20:Pagos/pago20:Pago/pago20:ImpuestosP" \
                "/pago20:TrasladosP/pago20:TrasladoP"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "172.56", node["BaseP"]
    assert_equal "002", node["ImpuestoP"]
    assert_equal "Tasa", node["TipoFactorP"]
    assert_equal "0.160000", node["TasaOCuotaP"]
    assert_equal "27.61", node["ImporteP"]
  end

  def test_node_totales
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Complemento/pago20:Pagos/pago20:Totales"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "172.56", node["TotalTrasladosBaseIVA16"]
    assert_equal "27.61", node["TotalTrasladosImpuestoIVA16"]
    assert_equal "200.17", node["MontoTotalPagos"]
  end

  def test_that_insert_concepto_node
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "0", node["ValorUnitario"]
    assert_equal "01", node["ObjetoImp"]
    assert_equal "Pago", node["Descripcion"]
    assert_equal "1", node["Cantidad"]
    assert_equal "0", node["Importe"]
    assert_equal "ACT", node["ClaveUnidad"]
    assert_equal "84111506", node["ClaveProdServ"]
  end

  def test_uso_cfdi_with_complemento
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante/cfdi:Receptor"
    node = REXML::XPath.first(xml, node_path)

    assert_equal "CP01", node["UsoCFDI"]
  end

  def test_subtotal_and_total_should_be_zero
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "0", node["SubTotal"]
    assert_equal "0", node["Total"]
  end

  def test_moneda_attribute_has_fixed_value
    cfdi = cfdi_pago
    xml = REXML::Document.new(cfdi.to_s)
    node_path = "cfdi:Comprobante"
    node = REXML::XPath.first(xml, node_path)

    assert_instance_of REXML::Element, node
    assert_equal "XXX", node["Moneda"]
  end

  def test_valid_cfdi_complemento_pago
    cfdi = cfdi_pago
    cfdi.cert_path = "test/files/cert1.cer"
    cfdi.key_path = "test/files/key1.key"
    cfdi.key_pass = "12345678a"
    cfdi.valid?

    assert_empty cfdi.errors
  end
end
