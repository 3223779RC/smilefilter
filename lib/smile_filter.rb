# frozen_string_literal: true

$LOAD_PATH << File.dirname(File.expand_path(__FILE__))

require 'uri'
require 'webrick'
require 'webrick/httpproxy'
require 'smile_filter/backward_compatibility' if RUBY_VERSION < '2.4.0'
require 'smile_filter/version'
require 'smile_filter/config'
require 'smile_filter/config/initializer'
require 'smile_filter/config/path'
require 'smile_filter/handler'

module SmileFilter
  PAC_MIME_TYPE = {'pac' => 'application/x-ns-proxy-autoconfig'}
  UserFilter    = Module.new
  
  class << self
    def start
      puts "Hello, SmileFilter #{VERSION}!", Time.now
      init_settings
      srv = WEBrick::HTTPProxyServer.new(server_config)
      trap_signal(srv)
      begin
        srv.start
      ensure
        srv.shutdown
      end
    end
    
    private
    
    def init_settings
      Config.load(Config::Path::USER_CONFIG)
      Config::Initializer.set_up_pac_file
      FilterFileParser.load_filters
    end
    
    def trap_signal(server)
      %i[INT TERM].each { |s| Signal.trap(s) { server.shutdown } }
    end
    
    def server_config
      {
        BindAddress: Config.proxy_server[:BindAddress],
        Port: Config.proxy_server[:Port],
        Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN),
        AccessLog: [],
        ProxyContentHandler: Handler.make,
        ProxyVia: false,
        ProxyURI: another_proxy_uri,
        DocumentRoot: Config::Path::DOCUMENT_ROOT,
        MimeTypes: WEBrick::HTTPUtils::DefaultMimeTypes.merge(PAC_MIME_TYPE)
      }
    end
    
    def another_proxy_uri
      if uri = Config.proxy_server[:ProxyURI]
        URI.parse(uri)
      else
        WEBrick::Config::HTTP[:ProxyURI]
      end
    end
  end
end
