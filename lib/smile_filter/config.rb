# frozen_string_literal: true

require 'yaml'

module SmileFilter
  module Config
    VERSION = '1.0.0'
    
    class << self
      def load(path)
        @config ||= symbolize(YAML.load_file(path)).freeze
      end
      
      def host_limitted
        @config[:HostLimitted]
      end
      
      def edit_master_comment
        @config[:EditMasterComment]
      end
      
      def max_log_count
        @config[:MaxLogCount]
      end
      
      def proxy_server
        @config[:ProxyServer]
      end
      
      def comment_server
        @config[:CommentServer]
      end
      
      private
      
      def symbolize(obj)
        case obj
        when Array then obj.map { |e| symbolize(e) }
        when Hash
          obj.each_with_object({}) do |(k, v), h|
            h[k.to_sym] = symbolize(v)
          end
        else
          obj
        end
      end
    end
  end
end
