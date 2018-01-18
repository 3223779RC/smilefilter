# frozen_string_literal: true

module SmileFilter
  class Filter
    def self.exec(json)
      new(CommentData.new(json)).exec.to_json(space: ' ')
    end
    
    def initialize(comment_data)
      @filters = FilterFileParser.load_filters
      @comment_data = comment_data
    end
    
    def exec
      if UserFilter.private_method_defined?(:exec)
        UserFilter.exec(@comment_data.chats)
      end
      emc = Config.edit_master_comment
      @comment_data.chats.each do |chat|
        @filters.each { |cmd| cmd.exec(chat) } if emc || chat.master?
      end
      @comment_data
    end
  end
end
