# frozen_string_literal: true

require "nokogiri"
require "base64"
require "openssl"
require_relative "cfdi40/version"
require_relative "cfdi40/schema_validator"
require_relative "cfdi40/sat_csd"
require_relative "cfdi40/node"
require_relative "cfdi40/comprobante"
require_relative "cfdi40/emisor"
require_relative "cfdi40/receptor"
require_relative "cfdi40/conceptos"
require_relative "cfdi40/concepto"
require_relative "cfdi40/impuestos"
require_relative "cfdi40/traslados"
require_relative "cfdi40/traslado"
require_relative "cfdi40/complemento_concepto"
require_relative "cfdi40/inst_educativas"

# Leading module and entry point for all features and classes
#
#  # NEW
#  Creates a new CFDi with minumum data
module Cfdi40
  class Error < StandardError; end
  # Your code goes here...

  def self.new
    Comprobante.new
  end
end
