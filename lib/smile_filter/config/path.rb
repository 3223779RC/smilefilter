# frozen_string_literal: true

module SmileFilter
  module Config
    module Path
      ROOT              = File.expand_path('../../../../', __FILE__)
      DEFAULT_CONFIG    = "#{ROOT}/lib/smile_filter/config/default.yml"
      DEFAULT_FILTER    = "#{ROOT}/lib/smile_filter/config/default_filter.rb"
      DEFAULT_LIST_FILE = "#{ROOT}/lib/smile_filter/config/default_list.txt"
      TEMPLATE_PAC_FILE = "#{ROOT}/lib/smile_filter/config/template.pac"
      PAC_FILE          = "#{Path::ROOT}/public_html/proxy.pac"
      DOCUMENT_ROOT     = Initializer.document_root
      USER_DIRECTORY    = Initializer.user_directory
      USER_CONFIG       = "#{USER_DIRECTORY}/config.yml"
      LOG               = "#{USER_DIRECTORY}/log"
      
      class << self
        def filter(mode)
          sprintf('%s/%S', USER_DIRECTORY, filter_get(mode))
        end
      end
    end
  end
end
