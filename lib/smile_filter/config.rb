# frozen_string_literal: true

require 'yaml'

module SmileFilter
  module Config
    class << self
      def load(path)
        @config ||= symbolize(YAML.load_file(path))
      end
      
      def host_limitted
        @config[:HostLimitted]
      end
      
      def edit_owner_comment
        @config[:EditOwnerComment]
      end
      
      def max_log_count
        @config[:MaxLogCount]
      end
      
      def security
        @config[:Security]
      end
      
      def proxy_server
        @config[:ProxyServer]
      end
      
      def comment_server
        @config[:CommentServer]
      end
      
      def filter_file
        @config[:FilterFile]
      end
      
      def filter_get(mode)
        filter_file[mode.upcase]
      end
      
      def filter_set(mode, fname)
        return if filter_get(mode) == fname
        filter_file[mode.upcase] = fname
        save_filter(mode)
      end
      
      private
      
      def save_filter(mode)
        fname = filter_get(mode)
        yaml = File.read(Path::USER_CONFIG, mode: 'rb+:BOM|UTF-8')
        File.write(Path::USER_CONFIG,
                   yaml.sub(filter_re(mode), "\\1#{fname}\\2"),
                   mode: 'wb+:BOM|UTF-8')
      end
      
      def filter_re(mode)
        /
          (^\ ++#{mode.upcase}:\ *+)
          .*?[^\\](?:\\\\)*(?<!\ )
          (\ *\#.*)?$
        /x
      end
      
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
