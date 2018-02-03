# frozen_string_literal: true

module SmileFilter
  class Cmt
    @@ignore = ''
    
    def initialize(expr)
      @expr = expr
      @arg = expr.strip
    end
    
    def exec(chat)
      return unless chat.content
      cmt = @@ignore.empty? ? chat.content : chat.content.delete(@@ignore)
      chat.clear if cmt.include?(@arg)
    end
    
    def to_a
      ['cmt', @expr]
    end
  end
end
