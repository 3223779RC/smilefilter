# frozen_string_literal: true

module SmileFilter
  class Cmt
    def initialize(expr)
      @expr = expr
      @arg = expr.strip
    end
    
    def exec(chat)
      chat.clear if chat.include?(@arg)
    end
    
    def to_a
      ['cmt', @expr]
    end
  end
end
