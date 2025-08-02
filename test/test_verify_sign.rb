# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestVerifySign < Minitest::Test
  def test_that_verify_when_load_a_signed_xml
    cfdi = Cfdi40.open(File.read("test/files/signed_cfdi.xml"))
    assert_predicate cfdi, :valid_signature?, "no valid signature"
  end
end

