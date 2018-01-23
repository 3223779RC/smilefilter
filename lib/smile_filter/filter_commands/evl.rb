# frozen_string_literal: true

module SmileFilter
  class Evl
    def initialize(expr)
      @arg = expr
    end
    
    def exec(chat)
      eval(@arg) if chat.content
    end
  end
end
