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
    sat_csd.set_private_key(key_der, '12345678a')
    assert sat_csd.valid_pair?
  end

  def unencrypted_key_pem_format
    lines = []
    lines << "-----BEGIN ENCRYPTED PRIVATE KEY-----"
    lines += Base64.strict_encode64(File.read('test/files/key_pm1.key')).scan(/.{1,64}/)
    lines << "-----END ENCRYPTED PRIVATE KEY-----"
    OpenSSL::PKey::RSA.new(lines.join("\n"), '12345678a').to_pem
  end

  def test_that_accepts_uncrypted_key_in_pem_format
    sat_csd = Cfdi40::SatCsd.new
    sat_csd.cert_path = 'test/files/cert_pm1.cer'
    sat_csd.set_private_key(unencrypted_key_pem_format)
    assert sat_csd.valid_pair?
  end

  def test_that_exctrat_rfc_from_legal_person_cert
    sat_csd = Cfdi40::SatCsd.new
    sat_csd.cert_path = 'test/files/cert_pm1.cer'
    assert_equal "EKU9003173C9", sat_csd.rfc
  end
end
