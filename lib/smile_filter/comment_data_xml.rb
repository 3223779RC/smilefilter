# frozen_string_literal: true

require 'rexml/document'

module SmileFilter
  class CommentDataXML
    class << self
      def parse(xml)
        new(xml)
      end
    end
    
    attr_reader :chats
    
    def initialize(xml)
      @chats, @whole_data = parse(xml)
    end
    
    def to_document
      @whole_data.map do |dat|
        next dat unless dat.kind_of?(SmileFilter::Chat)
        h = dat.to_h
        elem = REXML::Element.new('chat')
        elem.add_text(h.delete(:context))
        elem.add_attributes(h)
        elem
      end.document
    end
    
    private
    
    def parse(xml)
      elems = REXML::Document.new(xml).root.elements
      elems.each_with_object([[], []]) do |elem, (chats, whole_data)|
        if elem.name == 'chat'
          elem = Chat.new(xml_to_hash(elem))
          chats << elem
        end
        whole_data << elem
      end
    end
    
    def xml_to_hash(element)
      h = {content: element.text}
      element.attributes.each_with_object(h) do |(name, value), hash|
        value = value.to_i if name != 'user_id' && value.match?(/\A\d+\z/)
        hash[name.to_sym] = value
      end
    end
    
    def chat_to_xml(chat)
      chat.to_h[:chat].reduce(+'<chat') do |str, (key, value)|
        key == :content ? str << ">#{value}</chat>" : str << " #{key}=\"#{value}\""
      end
    end
  end
end
