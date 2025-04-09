# frozen_string_literal: true

module Cfdi40
  class ComplementoConcepto < Node
    def inst_educativas_node
      return @inst_educativas_node if defined?(@inst_educativas_node)

      @inst_educativas_node = InstEducativas.new
      @inst_educativas_node.parent_node = self
      children_nodes << @inst_educativas_node
      @inst_educativas_node
    end
  end
end
