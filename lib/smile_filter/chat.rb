# frozen_string_literal: true

require 'smile_filter/commands'

module SmileFilter
  class Chat
    OPTIONS = %i[
      thread fork no vpos leaf date date_usec score premium anonymity user_id
      nicoru mail deleted content
    ]
    AT_SIGNED_OPTIONS = OPTIONS.map { |sym| :"@#{sym}" }
    
    AT_SIGNED_OPTIONS.each { |var| instance_variable_set(var, nil) }
    
    attr_accessor(*OPTIONS)
    
    class << self
      private
      
      def passive_question(sym)
        sym[-1] == 'e' ? :"#{sym}d?" : "#{sym}ed?"
      end
      
      def add_question(sym)
        :"#{sym}?"
      end
      
      def add_equals(sym)
        :"#{sym}="
      end
      
      def add_at_sign(sym)
        :"@#{sym}"
      end
    end
    
    def initialize(opt)
      OPTIONS.each do |opts|
        instance_variable_set(add_at_sign(opts), opt[opts])
      end
      @mail = Commands.new(opt[:mail].to_s)
    end
    
    def to_h
      opt_hash = OPTIONS.each_with_object({}) do |opt, h|
        h[opt] = instance_variable_get(add_at_sign(opt))
      end
      opt_hash[:mail] =  @mail.empty? ? nil : @mail.to_s
      {chat: opt_hash.compact}
    end
    
    def add_at_sign(sym)
      :"@#{sym}"
    end
    
    def clear
      @content = nil
      @deleted = 2
    end
    
    alias delete clear
    
    def master?
      @fork == 1
    end
    
    def premium?
      @premium == 1
    end
    
    def anonymous?
      @anonymity == 1
    end
    
    def deleted?
      !@deleted.nil?
    end
    
    def empty?
      @content.nil?
    end
    
    def from_pc?
      @mail.from_pc?
    end
    
    def include?(str)
      @content && @content.include?(str)
    end
    
    def match?(str)
      @content && @content.match?(str)
    end
    
    def match(str)
      @content && @content.match(str)
    end
    
    %i[position color size font device].each do |sym|
      at_sym = add_at_sign(sym)
      define_method(sym) {
        @mail.instance_variable_get(at_sym)
      }
      define_method(passive_question(sym)) {
        !@mail.instance_variable_get(at_sym).nil?
      }
      define_method(add_question(sym)) { |arg|
        @mail.instance_variable_get(at_sym) == arg
      }
      define_method(add_equals(sym)) { |arg|
        @mail.instance_variable_set(at_sym, arg)
      }
    end
    
    Commands::BOOLEAN_COMMANDS.each do |sym|
      next if sym == :anonymity
      at_sym = add_at_sign(sym)
      define_method(sym) {
        @mail.instance_variable_get(at_sym)
      }
      define_method(add_question(sym)) {
        !@mail.instance_variable_get(at_sym).nil?
      }
      define_method(add_equals(sym)) { |arg|
        @mail.instance_variable_set(at_sym, arg)
      }
    end
  end
end
