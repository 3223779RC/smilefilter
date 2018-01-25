# frozen_string_literal: true

require 'zlib'
require 'smile_filter/filter'
module SmileFilter
  module Handler
    CONTENT_LENGTH    = 'content-length'
    CONTENT_ENCODING  = 'content-encoding'
    
    class << self
      def make
        ->(req, res) { handle(req, res) }
      end
      
      private
      
      def handle(req, res)
        return unless Config.host_limitted || comment_server?(req)
        puts connection_info(req, res)
        extract_gzip(res) if res[CONTENT_ENCODING] == 'gzip'
        save_log(res, :raw) unless Config.max_log_count.zero?
        res.body = Filter.exec(res)
        save_log(res) unless Config.max_log_count.zero?
        res.header.delete(CONTENT_ENCODING)
        res.header.delete(CONTENT_LENGTH)
      end
      
      def connection_info(req, res)
        sprintf("\n%s %s Bytes\n%s %s %s %s",
                Time.now,
                res.content_length,
                req.unparsed_uri ,
                res.content_type,
                res.body.encoding,
                res[CONTENT_ENCODING])
      end
      
      def comment_server?(req)
        req.host == Config.comment_server[:Host]
      end
      
      def extract_gzip(res)
        ascii_8bit_str = Zlib::GzipReader.wrap(StringIO.new(res.body)).read
        res.body = ascii_8bit_str.force_encoding(Encoding::UTF_8)
      end
      
      def compress_with_gzip(res)
        Zlib::GzipWriter.wrap(io = StringIO.new) { |g|
          g.write(res.body)
          res.body = io.string
        }
      end
      
      def save_log(res, suffix = nil)
        Dir.mkdir(Config::Path::LOG) unless Dir.exist?(Config::Path::LOG)
        remove_excess_logs unless Config.max_log_count == -1
        log_type = res.content_type['json'] ? 'json' : 'xml'
        file_name = sprintf('%s/%s%s.%s',
                            Config::Path::LOG,
                            Time.now.strftime('%F-%T-%L').tr(':', '-'),
                            suffix,
                            log_type)
        File.write(file_name, res.body)
      end
      
      def remove_excess_logs
        log_files = Dir.glob("#{Config::Path::LOG}/*.*")
        excess_count = log_files.size - Config.max_log_count
        return if excess_count.negative?
        log_files.sort[0..excess_count].each { |f| File.delete(f) }
      end
    end
  end
end
