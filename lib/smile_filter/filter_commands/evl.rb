# frozen_string_literal: true

module SmileFilter
  class Evl
    def initialize(expr)
      @expr = expr
    end
    
    def exec(chat)
      eval(@expr) if chat.content
    end
    
    def to_a
      ['evl', @expr]
    end
  end
end
