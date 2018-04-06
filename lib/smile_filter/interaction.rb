# frozen_string_literal: true

require 'io/console'
require 'mkmf'


module SmileFilter
  module Interaction
    INDEX_WIDTH = 3
    
    class << self
      def run
        Thread.new do
          loop do
            case $stdin.getch
            when 'e'         then edit
            when 'h'         then display_help
            when 'q', "\C-c" then Process.kill(:INT, $$)
            when 'r'         then switch_filter(:rb)
            when 's'         then current_status
            when 't'         then switch_filter(:txt)
            when 'v'         then display_version
            # when 'd'         then require 'pry'; pry
            end
          end
        end
      end
      
      private
      
      def edit
        if find_executable0(Config.filter_file[:Editor].to_s.tr('\\', '/'))
          files = Dir.glob("*.rb\0*.txt", base: Config::Path::USER_DIRECTORY)
          print list(files, 'Select which filter you want to edit')
          open_editor(files)
        else
          puts <<~EOT
            ### No valid editor is selected ###
            You need to edit config.yml and set Editor to an editor
            which you want to open filter files with.
            
          EOT
        end
      end
      
      def open_editor(files)
        index = gets.to_i
        if (1..files.size).include?(index)
          fname = "#{Config::Path::USER_DIRECTORY}/#{files[index - 1]}"
          spawn("#{Config.filter_file[:Editor]} #{fname}")
          puts "#{files[index - 1]} was opened.\n\n"
        else
          puts "The editting was cancelled.\n\n"
        end
      end
      
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
          e\t\tEdit filters. (Edit)
          h\t\tOutput this help. (Help)
          q, \\C-c\t\tQuit SmileFilter. (Quit)
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
        print list(files, "Select which *.#{mode}-filter you want")
        index = gets.to_i
        if (1..files.size).include?(index)
          fname = files[index - 1]
          Config.filter_set(mode, fname)
          puts "#{fname} was selected.\n\n"
        else
          puts "The switching was cancelled.\n\n"
        end
      end
      
      def list(files, message)
        cf = [Config.filter_get(:RB), Config.filter_get(:TXT)]
        str = files.each_with_index.reduce(+'') do |s, (fname, i)|
          s << sprintf("%s.%s%s\n",
                       (i + 1).to_s.rjust(INDEX_WIDTH),
                       cf.include?(fname) ? '*' : ' ',
                       fname)
        end
        <<~EOT.chomp
          ### #{message} ###
          #{'0'.rjust(INDEX_WIDTH)}. Cancel
          #{str}
            ?  
        EOT
      end
    end
  end
end
