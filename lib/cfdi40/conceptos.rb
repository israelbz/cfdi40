# frozen_string_literal: true

module Cfdi40
  class Conceptos < Node
    def delete_at(index)
      result = @children_nodes.delete_at(index)
      parent_node.calculate!
      result
    end
  end
end
