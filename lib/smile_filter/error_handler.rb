# frozen_string_literal: true

require 'smile_filter/comment_data_json'
require 'smile_filter/chat'
require 'smile_filter/sandbox'

module SmileFilter
  module ErrorHandler
    DUMMY_COMMENT_DATA = CommentDataJSON.new(<<-EOT)
      [{"chat": {"thread": "1","no": 1,"vpos": 28094,"leaf": 4,"date": 1500000000,"date_usec": 0,"anonymity": 1,"user_id": "ABCDEFG","nicoru": 10,"mail": "184","content": "foo bar baz"}}]
    EOT
    
    class << self
      
      def catch(type, *args, &block)
        Sandbox.run(&block)
      rescue Exception => ex
        $stderr.print message(ex, type, *args)
      end
      
      def raise?(type, *args)
        case type
        when :txt then check_txt_filter(*args)
        when :rb  then check_rb_filter
        end
        false
      rescue Exception => ex
        $stderr.print message(ex, type, *args)
        true
      end
      
      private
      
      def check_txt_filter(cmd, expr)
        command = SmileFilter.const_get(cmd.capitalize).new(expr.chomp)
        Sandbox.run {
          DUMMY_COMMENT_DATA.chats.each { |chat| command.exec(chat) }
        }
      end
      
      def check_rb_filter
        Sandbox.run {
          UserFilter.exec(DUMMY_COMMENT_DATA.chats)
        }
      end
      
      def message(ex, type, *args)
        fname = Config.filter_get(type)
        bt = backtrace(ex, type, *args)
        msg = "### %s でエラーが発生しました ###\n%s: %s\n%s\n\n"
        sprintf(msg, fname, ex.class, ex.message, bt.join("\n"))
      end
      
      def backtrace(ex, type, *args)
        case type
        when :txt then ["@#{args.join(' ')}"]
        when :rb
          ex.backtrace.take_while { |s| s.include?(Config::Path.filter(:rb)) }
        end
      end
    end
  end
end
