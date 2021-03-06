# frozen_string_literal: true

module SmileFilter
  class Reg
    def initialize(expr)
      @expr = expr
      @reg, @word = parse(expr)
    end
    
    def exec(chat)
      return unless chat.match?(@reg)
      @word ? chat.content.gsub!(@reg, @word) : chat.clear
    end
    
    # expr: "reg" or "reg" => "word"
    def parse(expr)
      eval("[#{expr}]")
    end
    
    def to_a
      ['reg', @expr]
    end
  end
end
