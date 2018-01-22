# frozen_string_literal: true

require 'smile_filter/filter_file_parser'
require 'smile_filter/comment_data_xml'
require 'smile_filter/comment_data_json'
require 'smile_filter/error_handler'

module SmileFilter
  class Filter
    def self.exec(res)
      comment_data = case res.content_type
                     when /json/ then CommentDataJSON.new(res.body)
                     when /xml/  then CommentDataXML.new(res.body)
                     end
      new(comment_data).exec.to_document
    end
    
    def initialize(comment_data)
      @filters = FilterFileParser.load_filters
      @comment_data = comment_data
    end
    
    def exec
      ErrorHandler.catch_filter_error { exec_user_filter }
      exec_filter_list
      @comment_data
    end
    
    private
    
    def exec_user_filter
      return unless UserFilter.private_method_defined?(:exec)
      UserFilter.exec(@comment_data.chats)
    end
    
    def exec_filter_list
      emc = Config.edit_master_comment
      @comment_data.chats.each do |chat|
        next unless emc || !chat.master?
        @filters.each { |cmd| cmd.exec(chat) }
      end
    end
  end
end
