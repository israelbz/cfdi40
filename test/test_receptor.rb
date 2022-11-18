# frozen_string_literal: true

require "test_helper"

class TestReceptor < Minitest::Test

  def test_rfc_setter
    receptor = Cfdi40::Receptor.new
    receptor.rfc = 'XAXX010101000'
    assert_equal 'XAXX010101000', receptor.rfc
  end


  def test_nombre_setter
    receptor = Cfdi40::Receptor.new
    receptor.nombre = 'PUBLICO EN GENERAL'
    assert_equal 'PUBLICO EN GENERAL', receptor.nombre
  end

  def test_domicilio_fiscal_setter
    receptor = Cfdi40::Receptor.new
    receptor.domicilio_fiscal = '06000'
    assert_equal '06000', receptor.domicilio_fiscal
  end

  def test_regimen_fiscal_setter
    receptor = Cfdi40::Receptor.new
    receptor.regimen_fiscal = '616'
    assert_equal '616', receptor.regimen_fiscal
  end

  def test_uso_cfdi_setter
    receptor = Cfdi40::Receptor.new
    receptor.uso_cfdi = 'G03'
    assert_equal 'G03', receptor.uso_cfdi
  end
end
