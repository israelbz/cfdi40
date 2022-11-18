# Cfdi40

Herramienta para crear, leer, validar y firmam CFDis en
versión 4.0.

El CFDi (Comprobante Fiscal Digital por internet) es un
documento en formato XML usado en México.

Esta herramienta tiene la intención de simplificar la
generación de los archivos XML, para ello, se pretende
que esta herramienta:

* Ofrezca una interfaz simple para colocar la
  información esencial para la elaboración del CFDi.
* Realice los cálculos complementarios como impuestos,
  totales, etcétera.
* Valide el CFDi contra los CSD
* Selle el CFDi.

# Uso

## Ejemplo básico

    # Inicia un cfdi
    cfdi = Cfdi40.new

    # Datos del emisor
    cfdi.lugar_expedicion = '06000'
    cfdi.emisor.regimen_fiscal = '612'

    # Datos del receptor
    cfdi.receptor.nombre = 'JUAN PUEBLO BUENO'
    cfdi.receptor.rfc = 'XAXX010101000'
    cfdi.receptor.domicilio_fiscal = '06000'
    cfdi.receptor.regimen_fiscal = '616'
    cfdi.receptor.uso_cfdi = 'G03'

    # Agrega un concepto en pesos,
    # precio final al cliente (neto)
    # causa IVA con tasa de 16% (default)
    cfdi.add_concepto(
      clave_prod_serv: '81111500',
      clave_unidad: "E48",
      descripcion: 'Prueba de concepto',
      precio_neto: 40
    )

    # Archivos CSD
    cfdi.cert_path = '/path_to/certificado.cer'
    cfdi.key_path = '/path_to/llave_privada.key'
    cfdi.key_pass = 'contraseña'

    # Genera CFDI firmado
    xml_string = cfdi.to_xml


# ¿Que sigue?

* Complemento de pagos
* Retenciones
* IEPS
* Complemento para colegiaturas
