# frozen_string_literal: true

module SmileFilter
  module Config
    module Initializer
      PAC_FILE_REG = /PROXY (?<bind_address>\d+\.\d+\.\d+\.\d):(?<port>\d+)/m
      
      class << self
        def document_root
          root = ENV.key?('OCRA_EXECUTABLE') ? Path::EXE_ROOT : Path::ROOT
          path = "#{root}/public_html"
          Dir.mkdir(path) unless Dir.exist?(path)
          path
        end
        
        def pac_file
          root = ENV.key?('OCRA_EXECUTABLE') ? Path::EXE_ROOT : Path::ROOT
          "#{root}/public_html/proxy.pac"
        end
        
        def user_directory
          root = ENV.key?('OCRA_EXECUTABLE') ? Path::EXE_ROOT : Path::ROOT
          ud = if Dir.exist?(path = "#{root}/smilefilter")
                 path
               else
                 "#{Dir.home}/smilefilter"
               end
          initialize_user_directory(ud)
          ud
        end
        
        def set_up_pac_file
          pac = sprintf(File.read(Path::TEMPLATE_PAC_FILE),
                        Config.comment_server[:Host],
                        Config.proxy_server[:BindAddress],
                        Config.proxy_server[:Port])
          unless File.exist?(Path::PAC_FILE) && same_settings?(Path::PAC_FILE)
            File.write(Path::PAC_FILE, pac)
          end
        end
        
        private
        
        def same_settings?(pac_path)
          m = File.read(pac_path).match(PAC_FILE_REG)
          Config.proxy_server[:BindAddress] == m[:bind_address] &&
          Config.proxy_server[:Port] == m[:port]
        end
        
        def initialize_user_directory(path)
          Dir.mkdir(path) unless Dir.exist?(path)
          [
            ["#{path}/config.yml", Path::DEFAULT_CONFIG],
            ["#{path}/filter.rb",  Path::DEFAULT_FILTER],
            ["#{path}/list.txt",   Path::DEFAULT_LIST_FILE]
          ].each do |fname, default|
            File.write(fname, File.read(default)) unless File.exist?(fname)
          end
        end
      end
    end
  end
end
