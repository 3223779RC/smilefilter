# frozen_string_literal: true

require 'json'

module SmileFilter
  class CommentDataJSON
    class << self
      def parse(json)
        new(json)
      end
    end
    
    attr_reader :chats
    
    def initialize(json)
      @chats, @whole_data = parse(json)
    end
    
    def to_document
      @whole_data.map(&:to_h).to_json(space: ' ')
    end
    
    private
    
    def parse(json)
      JSON.parse(json, symbolize_names: true)
        .each_with_object([[], []]) do |comment_data, (chats, whole_data)|
          if comment_data[:chat]
            comment_data = Chat.new(comment_data[:chat])
            chats << comment_data
          end
          whole_data << comment_data
        end
    end
  end
end
