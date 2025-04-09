# frozen_string_literal: true

module Cfdi40
  class InstEducativas < Node
    define_element_name "instEducativas"
    define_namespace "xsi", "http://www.w3.org/2001/XMLSchema-instance"
    define_namespace "iedu", "http://www.sat.gob.mx/iedu"
    define_attribute :schema_location,
                     xml_attribute: "xsi:schemaLocation",
                     readonly: true,
                     default: "http://www.sat.gob.mx/iedu http://www.sat.gob.mx/sitio_internet/cfd/iedu/iedu.xsd"
    define_attribute :version, xml_attribute: "version", readonly: true, default: "1.0"
    define_attribute :nombre_alumno, xml_attribute: "nombreAlumno"
    define_attribute :curp, xml_attribute: "CURP"
    define_attribute :nivel_educativo, xml_attribute: "nivelEducativo"
    define_attribute :aut_rvoe, xml_attribute: "autRVOE"
    define_attribute :rfc_pago, xml_attribute: "rfcPago"
  end
end
