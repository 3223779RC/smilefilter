# frozen_string_literal: true

require 'smile_filter/comment_data_json'
require 'smile_filter/chat'

module SmileFilter
  module ErrorHandler
    DUMMY_COMMENT_DATA = CommentDataJSON.new(<<-EOT)
      [{"chat": {"thread": "1","no": 1,"vpos": 28094,"leaf": 4,"date": 1500000000,"date_usec": 0,"anonymity": 1,"user_id": "ABCDEFG","nicoru": 10,"mail": "184","content": "foo bar baz"}}]
    EOT
    
    module_function
    
    def catch_filter_error
      yield
    rescue Exception => ex
      $strerr.print error_message(ex, :filter)
    end
    
    def list_raising_error?(cmd, expr)
      command = SmileFilter.const_get(cmd.capitalize).new(expr.chomp)
      DUMMY_COMMENT_DATA.chats.each { |chat| command.exec(chat) }
      false
    rescue Exception => ex
      $stderr.print error_message(ex, :list, cmd, expr.chomp)
      true
    end
    
    def error_message(ex, type, *args)
      bt = backtrace(ex, type, *args)
      fname = "#{type}.#{type == :list ? 'txt' : 'rb'}"
      msg = "### %s raised an error ###\n%s\n%s\n"
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
