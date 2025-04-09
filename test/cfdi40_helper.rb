# frozen_string_literal: true

module Cfdi40Helper
  def cfdi_base
    cfdi = Cfdi40.new
    cfdi.lugar_expedicion = "06000"
    cfdi.emisor.regimen_fiscal = "612"
    cfdi.receptor.nombre = "JUAN PUEBLO BUENO"
    cfdi.receptor.rfc = "XAXX010101000"
    cfdi.receptor.domicilio_fiscal = "06000"
    cfdi.receptor.regimen_fiscal = "616"
    cfdi.receptor.uso_cfdi = "G03"
    cfdi
  end

  def simple_cfdi
    # Minimum data is only one 'concepto' and a name for 'Receptor'
    # 'Emisor' data and 'Certificado' can be readed from a yml file
    cfdi = cfdi_base
    cfdi.add_concepto(
      clave_prod_serv: "81111500",
      clave_unidad: "E48",
      descripcion: "Prueba de concepto",
      precio_neto: 40
    )
    cfdi
  end

  def simple_cfdi_with_key_cert_path
    cfdi = simple_cfdi
    cfdi.cert_path = "test/files/cert1.cer"
    cfdi.key_path = "test/files/key1.key"
    cfdi.key_pass = "12345678a"
    cfdi
  end

  def simple_cfdi_with_key_cert_der
    cfdi = simple_cfdi
    cfdi.cert_der = File.read("test/files/cert1.cer")
    cfdi.key_data = File.read("test/files/key1.key")
    cfdi.key_pass = "12345678a"
    cfdi
  end

  def simple_concepto
    {
      clave_prod_serv: "81111500",
      clave_unidad: "E48",
      descripcion: "Prueba de concepto",
      cantidad: 3,
      precio_neto: 40
    }
  end

  def iedu_concepto
    {
      clave_prod_serv: "86121600",
      clave_unidad: "E48",
      descripcion: "COLEGIATURA NOVIEMBRE 2020",
      precio_neto: 950,
      tasa_iva: nil,
      iedu_nombre_alumno: "SANCHEZ SOTRES KARLA MARIA",
      iedu_curp: "SASK020520MDFNTRC1",
      iedu_nivel_educativo: "Bachillerato o su equivalente",
      iedu_aut_rvoe: "DGETI20089996",
      iedu_rfc_pago: "XAXX010101000"
    }
  end

  def cfdi_with_iedu
    cfdi = cfdi_base
    cfdi.serie = "IEDU"
    cfdi.folio = "007357"
    cfdi.add_concepto(iedu_concepto)
    cfdi.cert_path = "test/files/cert1.cer"
    cfdi.key_path = "test/files/key1.key"
    cfdi.key_pass = "12345678a"
    cfdi
  end
end
