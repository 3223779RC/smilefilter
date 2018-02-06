# frozen_string_literal: true

module SmileFilter
  class Dbg
    NON_TRIVIAL_COMMANDS = Commands::COMMANDS - 
                           %i[anonymity color size position]
    def initialize(expr)
      @expr = expr
      @arg = expr.strip
    end
    
    def exec(chat)
      send(@arg, chat) if chat.content
    end
    
    def show_all_commands(chat)
      str = chat.mail.to_a.join(',')
      chat.content.concat(":#{str}") unless str.empty?
    end
    
    # I: invisible, P: premium, O: onymous, D: deleted,
    # positive integer: nicoru, negative integer: NG score
    def show_nontrivial_parameters(chat)
      ppt = properties(chat)
      cmd = commands(chat).join(',')
      str = sprintf('%s%s%s%s',
                    ppt.empty? ? '' : ':',
                    ppt,
                    cmd.empty? ? '' : ':',
                    cmd)
      chat.content.concat(str)
    end
    
    def to_a
      ['dbg', @expr]
    end
    
    private
    
    def properties(chat)
      str = +''
      if chat.invisible?
        str.concat('I')
        chat.mail.remove(:invisible)
      end
      str.concat('O') unless chat.anonymous?
      str.concat('P') if chat.premium?
      if chat.deleted   == 1
        str.concat('D')
        chat.deleted = nil
      end
      chat.nicoru ? str.concat(chat.nicoru.to_s) : str
      chat.score ? str.concat(chat.score.to_s) : str
    end
    
    def commands(chat)
      NON_TRIVIAL_COMMANDS.each_with_object([]) do |sym, ary|
        next unless value = chat.mail.instance_variable_get(:"@#{sym}")
        ary << (value == true ? sym : value)
      end
    end
  end
end
