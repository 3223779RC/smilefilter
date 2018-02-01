# frozen_string_literal: true

require 'smile_filter/error_handler'
require 'smile_filter/filter_commands/cmd'
require 'smile_filter/filter_commands/cmt'
require 'smile_filter/filter_commands/dbg'
require 'smile_filter/filter_commands/reg'
require 'smile_filter/filter_commands/uid'
require 'smile_filter/filter_commands/evl'

module SmileFilter
  module FilterFileParser
    class << self
      COMMANDS    = %w[cmd cmt uid reg dbg evl]
      COMMAND_REG = /^@(#{Regexp.union(COMMANDS)}) +(.*)$/
      
      def load_filters
        load_filter_rb
        load_list_txt
        @@list_txt
      end
      
      private
      
      def load_list_txt
        mtime = File::Stat.new(Config::Path::LIST_FILE).mtime
        if !class_variable_defined?(:@@list_txt_mtime) ||
           @@list_txt_mtime != mtime
          @@list_txt_mtime = mtime
          @@list_txt = parse(Config::Path::LIST_FILE)
        end
      end
      
      def load_filter_rb
        mtime = File::Stat.new(Config::Path::USER_FILTER).mtime
        if !class_variable_defined?(:@@filter_rb_mtime) ||
           @@filter_rb_mtime != mtime
          @@filter_rb_mtime = mtime
          ErrorHandler.catch(:rb) { load(Config::Path::USER_FILTER) }
          ErrorHandler.raise?(:rb) if UserFilter.private_method_defined?(:exec)
        end
      end
      
      def parse(path)
        File.read(path, mode: 'r:BOM|UTF-8').scan(COMMAND_REG)
          .each_with_object([]) do |(cmd, expr), ary|
            next if ErrorHandler.raise?(:txt, cmd, expr)
            ary << SmileFilter.const_get(cmd.capitalize).new(expr.chomp)
          end
      end
    end
  end
end
