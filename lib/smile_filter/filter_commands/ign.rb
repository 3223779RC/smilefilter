# frozen_string_literal: true

module SmileFilter
  class Ign
    def initialize(expr)
      @expr = expr
    end
    
    def exec(_chat)
      Cmt.class_variable_set(:@@ignore, eval(@expr))
    end
    
    def to_a
      ['ign', @expr]
    end
  end
end
