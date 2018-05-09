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
      @whole_data = REXML::Document.new(xml)
      @chats = parse_chat
    end
    
    def to_document
      merge_chats
      @whole_data.to_s
    end
    
    private
    
    def parse_chat
      @whole_data.root.elements.each_with_object([]) do |elem, chats|
        chats << Chat.new(xml_to_hash(elem)) if elem.name == 'chat'
      end
    end
    
    def xml_to_hash(element)
      h = {content: element.text}
      element.attributes.each_with_object(h) do |(name, value), hash|
        value = value.to_i if name != 'user_id' &&
                              name != 'thread' &&
                              value.match?(/\A-?\d+\z/)
        hash[name.to_sym] = value
      end
    end
    
    def merge_chats
      @whole_data.root.elements.select { |elem| elem.name == 'chat' }
        .zip(@chats) { |elem, chat| merge_chat(elem, chat) }
    end
    
    def merge_chat(elem, chat)
      chat.instance_variables.each do |var|
        value = chat.instance_variable_get(var)
        next elem.text = value if var == :@content
        next elem.delete_attribute('mail') if var == :@mail && value.empty?
        elem.add_attribute(remove_at_sign(var), value)
      end
    end
    
    def remove_at_sign(var_name)
      var_name[0] == '@' ? var_name[1..-1] : var_name
    end
  end
end
