# frozen_string_literal: true

class Hash
  def compact
    select { |_key, value| value }
  end
end

if RUBY_VERSION < '2.3.0'
  class Integer
    def negative?
      self < 0
    end
  end
  
  class String
    def +@
      frozen? ? new(self) : self
    end
  end
end
