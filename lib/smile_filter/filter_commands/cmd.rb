# frozen_string_literal: true

module SmileFilter
  class Cmd
    ARROW  = '=>'
    
    def initialize(expr)
      @args = expr.split(ARROW).map { |a| a.split.map(&:to_sym) }
    end
    
    def exec(chat)
      return chat.mail.clear if @args.first == [:all]
      return unless (@args.first - chat.mail.to_a).empty?
      return chat.clear if @args.size == 1
      chat.mail.remove(*@args.first)
      chat.mail.add(*@args.last)
    end
  end
end
