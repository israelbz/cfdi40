# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestConcepto < Minitest::Test
  def test_that_calculate_tax_breakdown
    concepto = Cfdi40::Concepto.new
    concepto.cantidad = 5
    concepto.precio_neto = 30
    concepto.calculate!

    assert_equal 150, concepto.importe_neto
    assert_in_epsilon 129.310345, concepto.importe_bruto, 0.001
    assert_in_epsilon 129.310345, concepto.importe, 0.001
    assert_in_epsilon 129.310345, concepto.base_iva, 0.001
    assert_in_epsilon 20.689655, concepto.iva, 0.001
    assert_in_epsilon 25.862069, concepto.valor_unitario, 0.000001
    assert_in_epsilon 25.862069, concepto.precio_bruto, 0.000001
  end

  def test_that_calculate_tax_and_amount
    concepto = Cfdi40::Concepto.new
    concepto.cantidad = 125
    concepto.precio_bruto = 50
    concepto.calculate!

    assert_equal 7_250, concepto.importe_neto
    assert_in_epsilon 6_250, concepto.importe_bruto, 0.000001
    assert_in_epsilon 6_250, concepto.importe, 0.000001
    assert_in_epsilon 6_250, concepto.base_iva, 0.000001
    assert_in_epsilon 1_000, concepto.iva, 0.000001
    assert_in_epsilon 50, concepto.valor_unitario, 0.000001
    assert_in_epsilon 58, concepto.precio_neto, 0.000001
  end

  def test_that_calculate_from_valor_unitario
    concepto = Cfdi40::Concepto.new
    concepto.valor_unitario = 100
    concepto.calculate!

    assert_in_epsilon 100, concepto.precio_bruto, 0.000001
    assert_in_epsilon 116, concepto.precio_neto, 0.000001
    assert_in_epsilon 100, concepto.importe, 0.000001
    assert_in_epsilon 100, concepto.base_iva, 0.000001
    assert_in_epsilon 16, concepto.iva, 0.000001
    assert_equal 116, concepto.importe_neto
  end

  def test_that_return_an_array_of_traslados
    concepto = Cfdi40::Concepto.new

    assert_instance_of Array, concepto.traslado_nodes
    assert_equal 0, concepto.traslado_nodes.count
    concepto.precio_neto = 116
    concepto.calculate!

    assert_equal "02", concepto.objeto_impuestos
    assert_equal 1, concepto.traslado_nodes.count
    assert_instance_of Cfdi40::Traslado, concepto.traslado_nodes.first
  end

  def test_that_include_taxes_when_tasa_iva_is_zero
    concepto = Cfdi40::Concepto.new
    concepto.valor_unitario = 100
    concepto.tasa_iva = 0
    concepto.calculate!

    assert_equal "02", concepto.objeto_impuestos
    assert_equal 1, concepto.traslado_nodes.count
    assert_in_epsilon 100, concepto.precio_bruto, 0.000001
    assert_in_epsilon 100, concepto.base_iva, 0.000001
    assert_in_epsilon 0, concepto.iva, 0.000001
    assert_equal 100, concepto.importe_neto
  end

  def test_that_traslados_node_not_exist_when_tasa_iva_is_null
    concepto = Cfdi40::Concepto.new
    concepto.valor_unitario = 100
    concepto.tasa_iva = nil
    concepto.calculate!

    assert_equal "01", concepto.objeto_impuestos
    assert_equal 0, concepto.traslado_nodes.count
    assert_in_epsilon 100, concepto.precio_bruto, 0.000001
    assert_in_epsilon 100, concepto.base_iva, 0.000001
    assert_in_epsilon 0, concepto.iva, 0.000001
    assert_equal 100, concepto.importe_neto
  end
end
