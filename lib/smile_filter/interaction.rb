# frozen_string_literal: true

require 'io/console'


module SmileFilter
  module Interaction
    INDEX_WIDTH = 3
    
    class << self
      def run
        Thread.new do
          loop do
            case $stdin.getch
            when 'h'         then display_help
            when 'q', "\C-c" then Process.kill(:INT, $$)
            when 'r'         then switch_filter(:rb)
            when 's'         then current_status
            when 't'         then switch_filter(:txt)
            when 'v'         then display_version
            when 'd'         then (require "pry"; pry) ### debug
            else
              p$_ ### debug
            end
          end
        end
      end
      
      private
      
      def current_status
        printf(<<~EOT, Config.filter_get(:txt), Config.filter_get(:rb))
          ### Information about the current filters ###
          txt:\t%s
          rb:\t%s
          
        EOT
      end
      
      def display_help
        puts <<~EOT
          ### Usage information ###
           h\t\tOutput this help. (Help)
           q, \\C-c\tQuit SmileFilter. (Quit)
           r\t\tSwitch *.rb-filters. (Rb)
           s\t\tDisplay current filters. (Status)
           t\t\tSwitch *.txt-filters. (Txt)
           v\t\tOutput version information. (Version)
           
           EOT
      end
      
      def display_version
        puts <<~EOT
          ### Version information ###
           SmileFilter #{VERSION}
           Ruby #{RUBY_VERSION}
           
           EOT
      end
      
      def switch_filter(mode)
        files = Dir.glob("*.#{mode}", base: Config::Path::USER_DIRECTORY)
        print filter_selection(mode, files)
        index = gets.to_i
        puts
        return unless (1..files.size).include?(index)
        Config.filter_set(mode, files[index - 1])
      end
      
      def filter_selection(mode, files)
        list = files.each_with_index.reduce(+'') do |s, (fname, i)|
          s << sprintf("%s.%s%s\n",
                       (i + 1).to_s.rjust(INDEX_WIDTH),
                       fname == Config.filter_get(mode) ? '*' : ' ',
                       fname)
        end
        <<~EOT.chomp
        ### Select which *.#{mode}-filter you want ###
          0. Cansel
        #{list}
          ?  
        EOT
      end
    end
  end
end
