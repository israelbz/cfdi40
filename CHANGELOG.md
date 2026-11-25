# Cfdi40

Please see `README_es-MX.md`

## [Unreleased]

## [0.5.0] - 2026-11-25

### Changed

- La cadena original se genera con los XSLT locales: `cadenaoriginal_local.xslt` ya no
  incluye las plantillas hospedadas en `sat.gob.mx`, usa los archivos de `lib/xslt/`
- `nokogiri` 1.15.7 → 1.19.7 y `minitest` 5.15.0 → 5.27.0 en el `Gemfile.lock`
- Bundler 2.3.7 → 2.6.4 (`BUNDLED WITH`)

### Added

- `base64` como dependencia, dejó de ser un default gem a partir de Ruby 3.4
- `rexml` como dependencia de desarrollo, lo usan las pruebas

## [0.4.9] - 2026-04-23

### Fixed

- Mejora en el orden de los nodos
- Pruebas rotas

## [0.4.8] - 2026-04-21

### Added

- Nodo `cfdi:CfdiRelacionados` / `cfdi:CfdiRelacionado`
- `remove_cfdi_relacionado` para eliminar un CFDI relacionado

### Changed

- Mejoras en las pruebas

## [0.4.7] - 2026-03-12

### Fixed

- Carga del `concepto` en el REP

## [0.4.6] - 2026-03-11

### Fixed

- `Concepto.cantidad` debe ser 1 en el REP

## [0.4.5] - 2026-03-11

### Fixed

- Solo un `<concepto>` en el REP

### Changed

- Nombres de archivos REP

## [0.4.4] - 2025-12-17

### Fixed

- El `xmlns` de `pago20` puede estar en el nodo raíz
- Carga del nodo `ImpuestosP`
- Orden de los nodos

## [0.4.3] - 2025-12-04

### Added

- Carga del nodo `pagos`

## [0.4.2] - 2025-12-03

### Added

- `pago` con múltiples `docto_relacionado`

## [0.4.1] - 2025-12-02

### Added

- Acceso directo a `pago_nodes`
- Documentación del uso de `remove_pago`

## [0.4.0] - 2025-12-02

### Changed

- Dos decimales en el monto del pago
- `Node#define_writer` se omite para métodos personalizados

### Removed

- Nodos `pago20:Pago`

## [0.3.2] - 2025-10-27

### Fixed

- Atributo `descripcion` de `concepto` truncado a 1,000 caracteres

## [0.3.1] - 2025-09-04

### Fixed

- Se conserva la `cadena_original` al firmar

## [0.3.0] - 2025-08-24

### Added

- Lectura del nodo TFD (Timbre Fiscal Digital)

## [0.2.1] - 2025-08-23

### Fixed

- Ajuste de decimales según las reglas del PAC

## [0.2.0] - 2025-08-14

### Added

- Validación de firma, mejoras de formato y modo de solo lectura
- Lectura de certificados con caracteres no ASCII

## [0.1.2] - 2025-06-18

### Added

- Accesor `total_iva`
- Pruebas adicionales para la eliminación de conceptos

## [0.1.1] - 2025-06-18

### Fixed

- Cálculo del total al modificar un XML cargado

## [0.1.0] - 2025-06-05

### Added

- Actualización y eliminación de conceptos

## [0.0.9] - 2025-05-19

### Fixed

- Cálculos sobre un XML cargado

## [0.0.8] - 2025-05-14

### Added

- Carga de una factura CFDi simple desde XML

### Changed

- Actualización de versiones de las gems

## [0.0.7] - 2023-04-22

### Added

- Validaciones adicionales requeridas por el PAC

## [0.0.6] - 2023-04-11

### Added

- Recibo de pago electrónico básico (REP)

## [0.0.5] - 2023-04-08

### Added

- Nuevo procedimiento para el cálculo de impuestos
- Archivos XSD y XSLT
- XML de prueba con nodo de timbre fiscal

### Changed

- Tasa de impuestos nula significa exento; tasa cero genera el nodo de traslados
- Decimales en los atributos requeridos

## [0.0.4] - 2023-03-19

### Added

- Elemento para el complemento `instEducativas`
- `key_pass` ya no es requerido

### Changed

- `SubTotal` y `Total` usan `t_ImporteMXN`
- Actualización de dependencias

## [0.0.2] - 2022-11-17

### Added

- CFDi básico firmado

## [0.0.1.alfa] - 2022-11-17

### Added

- Invoice CFDi signed and valid for general public as receiver
- Initial release, proof of concept
