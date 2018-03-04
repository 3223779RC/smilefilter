# frozen_string_literal: true

require 'smile_filter/error_handler'
require 'smile_filter/filter_commands/cmd'
require 'smile_filter/filter_commands/cmt'
require 'smile_filter/filter_commands/dbg'
require 'smile_filter/filter_commands/reg'
require 'smile_filter/filter_commands/uid'
require 'smile_filter/filter_commands/evl'
require 'smile_filter/filter_commands/ign'

module SmileFilter
  module FilterParser
    COMMANDS   = %w[cmd cmt uid reg dbg evl ign]
    COMMAND_RE = /^@(#{Regexp.union(COMMANDS)}) +(.*)$/
    
    class << self
      def load_filters
        @@last ||= {rb: {}, txt: {}}
        %i[rb txt].each { |mode| update_filter(mode) }
        @@txt_filter
      end
      
      private
      
      def update_filter(mode)
        fpath = Config::Path.filter(mode)
        mtime = File::Stat.new(fpath).mtime
        return if @@last[mode][:path] == fpath && @@last[mode][:mtime] == mtime
        @@last[mode] = {path: fpath, mtime: mtime}
        load_filter(mode, fpath)
      end
      
      def load_filter(mode, fpath)
        case mode
        when :txt then @@txt_filter = parse(fpath)
        when :rb
          SmileFilter.class_eval { remove_const :UserFilter }
          ErrorHandler.catch(:rb) { load(Config::Path.filter(:rb)) }
          ErrorHandler.raise?(:rb) if UserFilter.private_method_defined?(:exec)
        end
      end
      
      def parse(path)
        File.read(path, mode: 'r:BOM|UTF-8').scan(COMMAND_RE)
          .each_with_object([]) do |(cmd, expr), ary|
            next if ErrorHandler.raise?(:txt, cmd, expr)
            ary << SmileFilter.const_get(cmd.capitalize).new(expr.chomp)
          end
      end
    end
  end
end
