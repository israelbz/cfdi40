# frozen_string_literal: true

module Cfdi40
  class CfdiRelacionado < Node
    define_attribute :uuid, xml_attribute: "UUID"
  end
end