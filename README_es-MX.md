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
* Valide el CFDi contra los XSD
* Selle el CFDi.

Hasta ahora:

* Genera CFDIs de ingreso básicos con IVA
* Genera CFDIs con complemento de pago para colegiaturas
* Genera CFDIs complementos de pago básicos.

# Uso

## Ejemplo básico

    # Inicia un cfdi
    cfdi = Cfdi40.new

    # Datos del emisor. RFC y Nombre se extraen del certificado
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

## Ejemplo CFDI con complemento de pago

    # Inicia un cfdi
    cfdi = Cfdi40.new
    cfdi.tipo_de_comprobante = 'P'

    # Datos del emisor.
    # RFC y Nombre se extraen del certificado si no existen
    cfdi.lugar_expedicion = '06000'
    cfdi.emisor.regimen_fiscal = '612'

    # Datos del receptor
    cfdi.receptor.nombre = 'JUAN PUEBLO BUENO'
    cfdi.receptor.rfc = 'XAXX010101000'
    cfdi.receptor.domicilio_fiscal = '06000'
    cfdi.receptor.regimen_fiscal = '616'
    cfdi.receptor.uso_cfdi = 'CP01'

    # Agrega un concepto en pesos,
    # precio final al cliente (neto)
    # causa IVA con tasa de 16% (default)
    cfdi.add_pago(
      monto: 200.17,
      uuid: 'e40229b3-5c4b-46fb-9ba8-707df828a5bc',
      serie: 'A',
      folio: '12345',
      num_parcialidad: 2,
      fecha_pago: '2023-04-01T12:20:34',
      forma_pago: '01',
      importe_saldo_anterior: 845.673
    )

    # Archivos CSD
    cfdi.cert_path = '/path_to/certificado.cer'
    cfdi.key_path = '/path_to/llave_privada.key'
    cfdi.key_pass = 'contraseña'

    # Genera CFDI firmado
    xml_string = cfdi.to_xml

# Cargar un CFDI a partir de un XML:

    # cfdi.xml es un archivo con un CFDi versión 4.0
    xml_string = File.read('cfdi.xml')
    cfdi = Cfdi40.open(xml_string)

Una vez cargado el xml se pueden leer los atributos
y/o hacer modificaciones

# Editar el n-ésimo concepto

En el siguiente ejemplo la variable `cfdi` es un CFDi creado o cargado
desde un xml y se desea cambiar el tercer
cantidad, precio y clave SAT de producto

    concepto = cfdi.concepto_nodes[2]
    concepto.update(
      cantidad: 2,
      precio_neto: 1_640,
      descripcion: "Tablero de control de proyectos",
      clave_prod_serv: "44111901"
    )

# Eliminar el n-esimo concepto

Para eliminar el segundo concepto de un `cfdi` dado:

    cfdi.conceptos.delete_at(1)

# Lo que sigue

* Nodo de Traslados cuando hay tasa de IEPS
* Retenciones de impuestos
* CFDI de pagos con varios pagos y varios documentos en cada pago

# Cambios

# 0.1.0
* Elimina conceptos
* Edición de conceptos

# 0.0.9
* FIX cálculos en un xml cargado

# 0.0.8
* Carga básica de un CFDI desde XML.

# 0.0.7
* Ajustes al CFDi con complemento de pagos por validaciones del PAC.

# 0.0.6
* CFDi con complemento de pagos

# 0.0.5

* IVA tasa 0 e IVA excento. Los conceptos con iva tasa 0 deben llevar el
  nodo de traslados de impuestos. Los conceptos excentos de iva no
  llevan el nodo de traslado. Al agregar el concepto usar `nil` para el
  IVA cuando sea excento.
* Nuevo cálculo de impuestos e importes. El PAC solo acepta 2 decimales
  en los nodos de traslado. Esto puede generar discrepancias al sumar
  los conceptos si no se maneja el mismo número de decimales. Solamente
  el valor unitario se manejará con 6 decimales.

# 0.0.4

* Atributos 'Total' y 'Subtotal' van con 2 decimales. Aunque el anexo 20
  indica que el tipo es `t_Importe` (6 decimales) el PAC acepta solo 2
  decimales si el CFDi está en pesos mexicanos.

# 0.0.3

* Lee RFC en certificados de personas morales. Los certificados de
  personas morales tienen el RFC de la persona moral y el del
  representante legal en el `UniqueIdentifier` del `Subject` del
  certificado
* Actepta llaves previamente descifradas en formato PEM.

# 0.0.2

* Definición básica de la intefaz.
* Carga certificado y llave desde archivo.
* Acepta certificado y llave previamente leídos.
* Genera CFDI de ingresos básico. Con desglose de impuestos, sello
  digital
* Valida correspondencia de certificado y llave

# 0.0.1

* Versión inicial. Esqueleto para desarrollo

# ¿Que sigue?

* Retenciones
* Complemento de pagos con retenciones
