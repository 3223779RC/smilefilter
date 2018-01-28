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
    COMMANDS    = %w[cmd cmt uid reg dbg evl]
    COMMAND_REG = /^@(#{Regexp.union(COMMANDS)}) +(.*)$/
    
    module_function
    
    def load_filters
      load_user_filter
      load_filter_list
    end
    
    def load_user_filter
      mtime = File::Stat.new(Config::Path::USER_FILTER).mtime
      if @@user_filter_mtime != mtime
        @@user_filter_mtime = mtime
        ErrorHandler.catch_filter_error { load(Config::Path::USER_FILTER) }
      end
    end
    
    def load_filter_list(init = false)
      mtime = File::Stat.new(Config::Path::LIST_FILE).mtime
      if init || mtime != @@filter_list_mtime
        @@filter_list_mtime = mtime
        @@filter_list = parse(Config::Path::LIST_FILE)
      end
      @@filter_list
    end
    
    def parse(path)
      File.read(path, mode: 'r:BOM|UTF-8').scan(COMMAND_REG)
        .each_with_object([]) do |(cmd, expr), ary|
          next if !COMMANDS.include?(cmd) ||
                  ErrorHandler.list_raising_error?(cmd, expr)
          ary << SmileFilter.const_get(cmd.capitalize).new(expr.chomp)
        end
    end
    
    @@user_filter_mtime = nil
    @@filter_list_mtime = nil
    @@filter_list = load_filter_list(true)
  end
end
