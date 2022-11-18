# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestSchemaValidator < Minitest::Test

  def test_validates_with_local_xsd_files
    validator = Cfdi40::SchemaValidator.new(File.read('test/files/basic.xml'))
    assert validator.valid?
    assert_equal [], validator.errors
  end

end
