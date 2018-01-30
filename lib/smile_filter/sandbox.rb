# frozen_string_literal: true

require 'timeout'
require 'fileutils'
require 'smile_filter/config'

module SmileFilter
  module Sandbox
    class << self
      BLACKLIST = {
        :class => [
                    File, IO, Dir, FileTest, FileUtils, ObjectSpace
                  ].flat_map { |klass| [klass, klass.singleton_class] }.freeze,
        Kernel => %i[system exec ` spawn require trap].freeze,
        Module => %i[class_eval module_eval].freeze
      }.freeze
      WHITELIST = {
        :class => [].freeze,
        IO     => %i[set_encoding].freeze
      }.freeze
      
      def run
        Timeout.timeout(Config.security[:Timeout]) do
          return yield unless Config.security[:Level] == 1
          trace_call.tap(&:enable).instance_eval do
            begin
              yield
            ensure
              disable
            end
          end
        end
      end
      
      def test(level, sec)
        security = {Security: {Level: level, Timeout: sec}}
        Config.instance_variable_set(:@config, security)
        while (print '>>'; gets)
          begin
            return if $_.strip == 'exit'
            eval("run { p(#{$_}) }")
          rescue Exception => ex
            puts ex
          end
        end
      end
      
      private
      
      def trace_call
        tp = TracePoint.new(:call, :c_call) do |tp|
          next unless censored?(tp)
          raise SecurityError, "not allowed method `#{inspect_method(tp)}'"
        end
        tp.singleton_class.class_eval { private :disable }
        tp
      end
      
      def inspect_method(trace)
        klass = trace.defined_class
        klass_re = /#<Class:\K[\w:]+/
        klass_name = klass.singleton_class? ? klass.to_s[klass_re] : klass
        separator = klass.singleton_class? ? '.' : '#'
        "#{klass_name}#{separator}#{trace.method_id}"
      end
      
      def censored?(trace)
        klass = trace.defined_class
        method = trace.method_id
        !whitelist?(klass, method) && blacklist?(klass, method)
      end
      
      def whitelist?(klass, method)
        WHITELIST[:class].include?(klass) ||
        WHITELIST[klass] && WHITELIST[klass].include?(method)
      end
      
      def blacklist?(klass, method)
        BLACKLIST[:class].include?(klass) ||
        BLACKLIST[klass] && BLACKLIST[klass].include?(method)
      end
    end
  end
end
