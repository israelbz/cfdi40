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

# Cambios

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

* Complemento de pagos
* Retenciones
* IEPS
* Complemento para colegiaturas
