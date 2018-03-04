# frozen_string_literal: true

require 'smile_filter/filter_parser'
require 'smile_filter/comment_data_xml'
require 'smile_filter/comment_data_json'
require 'smile_filter/error_handler'

module SmileFilter
  class Filter
    def self.exec(res)
      comment_data = case res.content_type
                     when /\bjson\b/ then CommentDataJSON.new(res.body)
                     when /\bxml\b/  then CommentDataXML.new(res.body)
                     else
                       return res.body
                     end
      new(comment_data).exec.to_document
    end
    
    def initialize(comment_data)
      @filters = FilterFileParser.load_filters
      @comment_data = comment_data
    end
    
    def exec
      exec_filter_rb
      exec_list_txt
      @comment_data
    end
    
    private
    
    def exec_filter_rb
      return unless UserFilter.private_method_defined?(:exec)
      ErrorHandler.catch(:rb) { UserFilter.exec(@comment_data.chats) }
    end
    
    def exec_list_txt
      eoc = Config.edit_owner_comment
      @comment_data.chats.each do |chat|
        next unless eoc || !chat.owner?
        @filters.each { |cmd|
          ErrorHandler.catch(:txt, *cmd) { cmd.exec(chat) }
        }
      end
    end
  end
end
