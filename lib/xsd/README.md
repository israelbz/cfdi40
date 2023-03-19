# Local XSD files

## Why?

In order to avoid innecesary and redundant reading from SAT site the
file `cfdv40.xsd` referenced in cfdi standard, has been
prepared for local access.

The `cfdv40.xsd` has been modified to reference the local files:

* `tdCFDI.xsd`,
* `catCFDI.xsd` this file has 5.8MB
* `iedu.xsd`

Local files are imported schemas.

## Use external files

If you want to use the schema in the original location must enable the
external references for Nokogiri:

    require 'net/http'

    xml_doc =  Nokogiri::XML(xml_string)

    options = Nokogiri::XML::ParseOptions.new.nononet
    schema = Nokogiri::XML::Schema(Net::HTTP.get('www.sat.gob.mx', '/sitio_internet/cfd/4/cfdv40.xsd'), options)
    
    schema.validate(xml_doc)

References:

https://nokogiri.org/rdoc/Nokogiri/XML/Schema.html
https://nokogiri.org/rdoc/Nokogiri/XML/ParseOptions.html
