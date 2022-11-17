# frozen_string_literal: true

require "nokogiri"
require_relative "cfdi40/version"
require_relative "cfdi40/comprobante"

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
