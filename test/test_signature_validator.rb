# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestSignatureValidator < Minitest::Test
  def test_validates_signed_xml
    validator = Cfdi40::SignatureValidator.new(File.read("test/files/signed_cfdi.xml"))
    assert_predicate validator, :valid?
  end

  def test_wrong_signature_xml
    validator = Cfdi40::SignatureValidator.new(File.read("test/files/error_signed_cfdi.xml"))
    refute_predicate validator, :valid?
  end
end
