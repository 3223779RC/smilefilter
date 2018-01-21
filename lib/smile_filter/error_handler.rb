# frozen_string_literal: true

require 'smile_filter/comment_data'
require 'smile_filter/chat'

module SmileFilter
  module ErrorHandler
    DUMMY_COMMENT_DATA = CommentData.new(<<-EOT)
      [{"chat": {"thread": "1515668313","no": 1,"vpos": 28094,"leaf": 4,"date": 1515671696,"date_usec": 918021,"anonymity": 1,"user_id": "j9_7arWl2P-kB73lHn3ZFoC2fmw","mail": "184","content": "foo bar baz"}}]
    EOT
    
    module_function
    
    def catch_filter_error
      yield
    rescue Exception => ex
      print error_message(ex, :filter)
    end
    
    def list_raising_error?(cmd, expr)
      command = SmileFilter.const_get(cmd.capitalize).new(expr.chomp)
      DUMMY_COMMENT_DATA.chats.each { |chat| command.exec(chat) }
      false
    rescue Exception => ex
      print error_message(ex, :list, cmd, expr.chomp)
      true
    end
    
    def error_message(ex, type, *args)
      bt = backtrace(ex, type, *args)
      fname = "#{type}.#{type == :list ? 'txt' : 'rb'}"
      msg = "### %s raises an error ###\n%s\n%s\n"
      sprintf(msg, fname, ex, bt.join("\n"))
    end
    
    def backtrace(ex, type, *args)
      case type
      when :list then ["@#{args.join(' ')}"]
      when :filter
        ex.backtrace.take_while { |s| s.include?(Config::Path::USER_FILTER) }
      end
    end
  end
end
