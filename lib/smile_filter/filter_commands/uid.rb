# frozen_string_literal: true

module SmileFilter
  class Uid
    def initialize(expr)
      @expr = expr
      @arg = expr.strip
    end
    
    def exec(chat)
      chat.clear if chat.user_id == @arg
    end
    
    def to_a
      ['uid', @expr]
    end
  end
end
