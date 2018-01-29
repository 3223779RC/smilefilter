# frozen_string_literal: true

require "fileutils"

module SmileFilter
  module Sandbox
    class << self
      IO_ = File
      BC = [File, IO_, Dir, FileTest, FileUtils, ObjectSpace]
      BCC = BC + BC.map{|c| c.singleton_class}
      BM = [:eval_, :system, :exec, :`, :spawn, :require, :load, :trap]
      # ObjectSpace.each_object
      
      def censor
        trace_call.tap(&:enable).instance_eval do
          yield
          p [:censor, self]
          disable
        end
      end
      
      def test
        b = binding
        censor do
          print '>>'
          while gets
            begin
              p eval $_, b
            rescue SecurityError => ex
              puts ex
            rescue => ex
              puts ex
            ensure
              print '>>'
            end
          end
        end
      end
      
      private
      
      def trace_call
        tp = TracePoint.new(:call, :c_call) do |tp|
          next unless censored?(tp)
          puts caller
          raise SecurityError, "not allowed method `#{inspect_method(tp)}'"
        end
        tp.singleton_class.class_eval { private :disable }
        tp
      end
      
      def inspect_method(trace)
        klass = trace.defined_class
        klass_name = klass.singleton_class? ? klass.to_s[/:\K\w+/] : klass
        separator = klass.singleton_class? ? '.' : '#'
        "#{klass_name}#{separator}#{trace.method_id}"
      end
      
      def censored?(trace)
        klass = trace.defined_class
        BCC.include?(klass) ||
        klass == Kernel && [:banned_methods].include?(trace.method_id)
      end
    end
  end
end

#ファイルテスト演算子の使用、ファイルの更新時刻比較
#トップレベルへの Kernel.#load (第二引数を指定してラップすれば実行可能)
