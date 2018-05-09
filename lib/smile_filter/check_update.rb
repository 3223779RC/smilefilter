# frozen_string_literal: true

require 'open-uri'

module SmileFilter
  module CheckUpdate
    MAX_TRIALS = 3
    WAIT_TIMES = MAX_TRIALS.times.map { |i| 1 << i }
    INTERVAL   = 10
    
    @@last_check = Time.new(0)
    
    class << self
      def run
        return(reject) if Time.now - @@last_check < INTERVAL
        WAIT_TIMES.each do |wtime|
          @@last_check = Time.now
          return if get_newest_version(wtime)
        end
        failed_to_open
      end
      
      private
      
      def get_newest_version(wtime)
        newest_version = open(Config.check_update)
        check_version(newest_version.read)
        true
      rescue SocketError, OpenURI::HTTPError => ex
        sleep(wtime)
        false
      end
      
      def reject
        rest = 10 - (Time.now - @@last_check)
        printf("### %.3f 秒経ってから再度お試しください ###\n\n", rest)
        sleep(0.3)
      end
      
      def check_version(newest_version)
        using = VERSION.split('.').map(&:to_i)
        newest = newest_version.split('.').map(&:to_i)
        if using == newest
          puts "### SmileFIlter は最新です ###\n\n"
        else
          navigate(newest_version)
        end
      end
      
      def navigate(newest_version)
        dl_uri = "#{Config.check_update[%r(.+/apps)]}/download.shtml"
        printf(<<~EOT.chomp)
          ### 最新のバージョンの SmileFIlter がダウンロードできます ###
          現在のバージョン:\t#{VERSION}
          最新のバージョン:\t#{newest_version}
          ダウンロード・ページ:\t#{dl_uri}
          
          ダウンロード・ページをブラウザで開きますか？
            0. キャンセル
            1. はい
            2. いいえ
            
            ?  
        EOT
        if gets.to_i == 1
          launch_browser(dl_uri)
          puts "ブラウザを起動しました。\n\n"
        else
          puts "ブラウザを起動しませんでした。\n\n"
        end
      end
      
      def failed_to_open
        puts "### バージョン情報の取得に失敗しました ###\n\n"
      end
      
      def launch_browser(uri)
        system("start #{uri}")
      end
    end
  end
end
