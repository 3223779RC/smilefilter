# frozen_string_literal: true

require 'json'

module SmileFilter
  class CommentData
    class << self
      def parse(json)
        new(json)
      end
    end
    
    attr_reader :chats
    
    def initialize(res)
      @chats, @whole_data = parse(res)
#      @chats, @whole_data = parse_json(res.body)
#      @content_type = res.content_type
    end
    
    def to_document
      case @content_type
      when /json/ then to_json(space: ' ')
      when /xml/  then to_xml
      else
        ''
      end
    end
    
    private
    
    def to_json(opt = {})
      @whole_data.map(&:to_h).to_json(opt)
    end
    
    def to_xml
      
    end
    
    def parse
      case @content_type
      when /json/ then parse_json
      when /xml/  then parse_xml
      else
        ''
      end
    end
    
    def parse_json(json)
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
