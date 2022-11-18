# frozen_string_literal: true

require "test_helper"

class TestEmisor < Minitest::Test
  def test_rfc_setter
    emisor = Cfdi40::Emisor.new
    emisor.rfc = 'XAMA620210DQ5'
    assert_equal 'XAMA620210DQ5', emisor.rfc
  end

  def test_name_setter
    emisor = Cfdi40::Emisor.new
    emisor.nombre = 'PUBLICO EN GENERAL'
    assert_equal 'PUBLICO EN GENERAL', emisor.nombre
  end

  def test_regimen_fiscal_setter
    emisor = Cfdi40::Emisor.new
    emisor.regimen_fiscal = '626'
    assert_equal '626', emisor.regimen_fiscal
  end
end
