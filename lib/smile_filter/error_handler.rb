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
        when :txt then check_list_txt(*args)
        when :rb  then check_filter_rb
        end
        false
      rescue Exception => ex
        $stderr.print message(ex, type, *args)
        true
      end
      
      private
      
      def check_list_txt(cmd, expr)
        command = SmileFilter.const_get(cmd.capitalize).new(expr.chomp)
        Sandbox.run {
          DUMMY_COMMENT_DATA.chats.each { |chat| command.exec(chat) }
        }
      end
      
      def check_filter_rb
        Sandbox.run {
          UserFilter.exec(DUMMY_COMMENT_DATA.chats)
        }
      end
      
      def message(ex, type, *args)
        bt = backtrace(ex, type, *args)
        fname = type == :txt ? 'list.txt' : 'filter.rb'
        msg = "### %s raised an error ###\n%s: %s\n%s\n\n"
        sprintf(msg, fname, ex.class, ex.message, bt.join("\n"))
      end
      
      def backtrace(ex, type, *args)
        case type
        when :txt then ["@#{args.join(' ')}"]
        when :rb
          ex.backtrace.take_while { |s| s.include?(Config::Path::USER_FILTER) }
        end
      end
    end
  end
end
