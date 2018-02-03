# frozen_string_literal: true

module SmileFilter
  class Ign
    def initialize(expr)
      @expr = expr
    end
    
    def exec(_chat)
      Cmt.class_variable_set(:@@ignore, parse)
    end
    
    def parse
      arg = @expr.strip
      literal = arg[0]
      if !["'", '"'].include?(literal) || arg.size < 2 || literal != arg[-1]
        raise SyntaxError, 'unterminated string meets end of input'
      end
      arg[1..-2]
    end
    
    def to_a
      ['ign', @expr]
    end
  end
end
