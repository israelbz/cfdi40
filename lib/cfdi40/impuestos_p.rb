# frozen_string_literal: true

module Cfdi40
  class ImpuestosP < Node
    def traslados_p
      return @traslados_p if defined?(@traslados_p)

      @traslados_p = TrasladosP.new
      add_child_node @traslados_p
      @traslados_p
    end
  end
end
