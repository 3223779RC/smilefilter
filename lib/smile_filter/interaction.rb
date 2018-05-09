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
          print list(files, '編集したいフィルターを選択してください')
          open_editor(files)
        else
          puts <<~EOT
            ### 有効なエディタが設定されていません ###
            config.yml を編集し、フィルターの編集に使用したいエディタを
            Editor に設定してください。
            
          EOT
        end
      end
      
      def open_editor(files)
        index = gets.to_i
        if (1..files.size).include?(index)
          fname = "#{Config::Path::USER_DIRECTORY}/#{files[index - 1]}"
          spawn("#{Config.filter_file[:Editor]} #{fname}")
          puts "#{files[index - 1]} が開かれました。\n\n"
        else
          puts "編集はキャンセルされました。\n\n"
        end
      end
      
      def current_status
        printf(<<~EOT, Config.filter_get(:txt), Config.filter_get(:rb))
          ### 現在適用中のフィルター ###
          txt:\t%s
          rb:\t%s
          
        EOT
      end
      
      def display_help
        puts <<~EOT
          ### ヘルプ ###
          e\t\tエディタを開きフィルターを編集します。 (Edit)
          h\t\tこのヘルプを表示します。 (Help)
          q, \\C-c\t\tSmileFilter を終了します。 (Quit)
          r\t\trbファイルのフィルターを切り替えます。 (Rb)
          s\t\t現在使用中のフィルターを表示します。 (Status)
          t\t\ttxtファイルのフィルターを切り替えます。 (Txt)
          v\t\tバージョン情報を表示します。 (Version)
          
        EOT
      end
      
      def display_version
        puts <<~EOT
          ### バージョン情報 ###
          SmileFilter #{VERSION}
          Ruby #{RUBY_VERSION}
          
        EOT
      end
      
      def switch_filter(mode)
        files = Dir.glob("*.#{mode}", base: Config::Path::USER_DIRECTORY)
        print list(files, "使用する #{mode} ファイルのフィルターを選択してください")
        index = gets.to_i
        if (1..files.size).include?(index)
          fname = files[index - 1]
          Config.filter_set(mode, fname)
          puts "#{fname} が選択されました。\n\n"
        else
          puts "フィルターの切り替えはキャンセルされました。\n\n"
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
          #{'0'.rjust(INDEX_WIDTH)}. キャンセル
          #{str}
            ?  
        EOT
      end
    end
  end
end
