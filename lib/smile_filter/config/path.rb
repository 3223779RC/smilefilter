# frozen_string_literal: true

module SmileFilter
  module Config
    module Path
      ROOT              = File.expand_path('../../../../', __FILE__)
      if ENV.key?('OCRA_EXECUTABLE')
        EXE_ROOT        = File.dirname(ENV['OCRA_EXECUTABLE']).gsub('\\', '/')
      end
      DEFAULT_CONFIG    = "#{ROOT}/lib/smile_filter/config/default.yml"
      DEFAULT_FILTER    = "#{ROOT}/lib/smile_filter/config/default_filter.rb"
      DEFAULT_LIST_FILE = "#{ROOT}/lib/smile_filter/config/default_list.txt"
      TEMPLATE_PAC_FILE = "#{ROOT}/lib/smile_filter/config/template.pac"
      DOCUMENT_ROOT     = Initializer.document_root
      PAC_FILE          = Initializer.pac_file
      USER_DIRECTORY    = Initializer.user_directory
      LIST_FILE         = "#{USER_DIRECTORY}/list.txt"
      USER_FILTER       = "#{USER_DIRECTORY}/filter.rb"
      USER_CONFIG       = "#{USER_DIRECTORY}/config.yml"
      LOG               = "#{USER_DIRECTORY}/log"
    end
  end
end
