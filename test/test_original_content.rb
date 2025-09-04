require "test_helper"
require "rexml/document"

class TestOriginalContent < Minitest::Test
  def test_generates_original_content
    xml_string = File.read("test/files/simple_cfdi.xml")
    expected_string =
      "||4.0|2025-04-08T20:33:08|30001000000400002310|163.79|MXN|190.00|I|01|06000|XAMA620210DQ5" \
      "|ALBA XKARAJAM MENDEZ|612|XAXX010101000|JUAN PUEBLO BUENO|06000|616|G03|81111500|1|E48" \
      "|Prueba de concepto|34.482759|34.482759|02|34.482759|002|Tasa|0.160000|5.52|81111500|1" \
      "|E48|Otro concepto concepto|129.310345|129.310345|02|129.310345|002|Tasa|0.160000|20.69" \
      "|163.79|002|Tasa|0.160000|26.21|26.21||"
    assert_equal expected_string, Cfdi40::OriginalContent.generate(xml_string)
  end
end
