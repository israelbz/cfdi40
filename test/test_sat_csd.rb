# frozen_string_literal: true

require "test_helper"

class TestSatCsd < Minitest::Test
  def test_that_extract_rfc_from_certificate
    sat_csd = Cfdi40::SatCsd.new
    sat_csd.cert_path = 'test/files/cert1.cer'
    assert_equal 'XAMA620210DQ5', sat_csd.rfc
  end

  def test_that_extract_name_from_certificate
    sat_csd = Cfdi40::SatCsd.new
    sat_csd.cert_path = 'test/files/cert1.cer'
    assert_equal 'ALBA XKARAJAM MENDEZ', sat_csd.name
  end

  def test_that_extract_number_from_certificate
    sat_csd = Cfdi40::SatCsd.new
    sat_csd.cert_path = 'test/files/cert1.cer'
    assert_equal '30001000000400002310', sat_csd.no_certificado
  end

  def test_that_open_private_key
    sat_csd = Cfdi40::SatCsd.new
    sat_csd.load_private_key('test/files/key1.key', '12345678a')
    assert_instance_of OpenSSL::PKey::RSA, sat_csd.private_key
  end

  def test_that_validates_pair_key_cert
    sat_csd = Cfdi40::SatCsd.new
    sat_csd.cert_path = 'test/files/cert1.cer'
    sat_csd.load_private_key('test/files/key1.key', '12345678a')
    assert sat_csd.valid_pair?

    sat_csd.cert_path = 'test/files/cert2.cer'
    assert !sat_csd.valid_pair?
  end

  def test_that_accepts_certificate_in_der_format
    sat_csd = Cfdi40::SatCsd.new
    cert_der = File.read('test/files/cert1.cer')
    sat_csd.cert_der = cert_der
    sat_csd.load_private_key('test/files/key1.key', '12345678a')
    assert sat_csd.valid_pair?
  end

  def test_that_accepts_crypted_key_in_der_format
    sat_csd = Cfdi40::SatCsd.new
    sat_csd.cert_path = 'test/files/cert1.cer'
    key_der = File.read('test/files/key1.key')
    sat_csd.set_crypted_private_key(key_der, '12345678a')
    assert sat_csd.valid_pair?
  end
end
