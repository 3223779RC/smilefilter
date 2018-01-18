# frozen_string_literal: true

module SmileFilter
  class Cmt
    def initialize(expr)
      @arg = expr.strip
    end
    
    def exec(chat)
      chat.clear if chat.include?(@arg)
    end
  end
end
