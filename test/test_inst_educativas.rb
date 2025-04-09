# frozen_string_literal: true

require "test_helper"
require "rexml/document"

class TestInstEducativas < Minitest::Test
  # Create a +instEducativas+ as a root node in a simple xml document.
  def inst_educativas_with_document
    doc_xml = Nokogiri::XML::Document.new("1.0")
    inst_educativas = Cfdi40::InstEducativas.new
    inst_educativas.xml_document = doc_xml
    inst_educativas.xml_parent = doc_xml
    inst_educativas
  end

  def test_version
    inst_educativas = inst_educativas_with_document
    inst_educativas.create_xml_node

    assert_equal "1.0", inst_educativas.version
  end

  def test_that_use_its_own_namespace
    inst_educativas = inst_educativas_with_document

    assert_equal "iedu", inst_educativas.current_namespace
    inst_educativas.create_xml_node
    xml = REXML::Document.new(inst_educativas.xml_document.to_xml)

    assert_equal "instEducativas", xml.root.name
    assert_equal "http://www.sat.gob.mx/iedu", xml.root.attributes["iedu"]
    assert_equal "http://www.sat.gob.mx/iedu http://www.sat.gob.mx/sitio_internet/cfd/iedu/iedu.xsd",
                 xml.root.attributes["schemaLocation"]
  end

  def test_that_accepts_attributes
    inst_educativas = inst_educativas_with_document
    inst_educativas.nombre_alumno = "SANCHEZ SOTRES KARLA MARIA"
    inst_educativas.curp = "SASK020520MDFNTRC1"
    inst_educativas.nivel_educativo = "Bachillerato o su equivalente"
    inst_educativas.aut_rvoe = "DGETI20089996"
    inst_educativas.rfc_pago = "SONL6308063D9"
    inst_educativas.create_xml_node
    xml = REXML::Document.new(inst_educativas.xml_document.to_xml)

    assert_equal "1.0", xml.root.attributes["version"]
    assert_equal "SANCHEZ SOTRES KARLA MARIA", xml.root.attributes["nombreAlumno"]
    assert_equal "SASK020520MDFNTRC1", xml.root.attributes["CURP"]
    assert_equal "Bachillerato o su equivalente", xml.root.attributes["nivelEducativo"]
    assert_equal "DGETI20089996", xml.root.attributes["autRVOE"]
    assert_equal "SONL6308063D9", xml.root.attributes["rfcPago"]
  end
end
