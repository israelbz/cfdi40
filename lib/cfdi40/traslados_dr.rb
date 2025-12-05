# frozen_string_literal: true

module Cfdi40
  class TrasladosDR < Node
    def load_traslado_dr(tr_dr_node)
      tr_dr = TrasladoDR.new
      tr_dr.load_from_ng_node(tr_dr_node)
      tr_dr.parent_node = self
      @children_nodes << tr_dr
      tr_dr
    end
  end
end
