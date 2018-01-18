# frozen_string_literal: true

module SmileFilter
  class Uid
    def initialize(expr)
      @arg = expr.strip
    end
    
    def exec(chat)
      chat.clear if chat.user_id == @arg
    end
  end
end
