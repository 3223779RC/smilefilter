# frozen_string_literal: true

module SmileFilter
  class Commands
    POSITIONS  = %i[ue naka shita]
    COLORS     = %i[
      white red pink orange yellow green cyan blue purple black white2
      niconicowhite red2 truered pink2 orange2 passionorange yellow2 madyellow
      green2 elementalgreen cyan2 blue2 marineblue purple2 nobleviolet black2
    ]
    SIZES      = %i[big medium small]
    FONTS      = %i[defont gothic mincho]
    DEVICES    = %i[3DS WiiU Switch]
    COMMANDS   = %i[
      ender patissier full anonymity is_button position color size font
      iPhone docomo softbank device from_button _live invisible others
    ]
    HEX_COLOR  = /\A#\h{6}\z/
    DEVICE_REG = /\Adevice:(?<suffix>\w+)\z/
    NON_PC_DEVICE = %i[@device @iPhone @docomo @softbank]
#    NICOSCRIPTS = %i[migi hidari hidden @int local @button]
#    SECOND_REG = /\A@(\d+)\z/
    BOOLEAN_COMMANDS = COMMANDS - %i[position color size font device others]
    
    attr_accessor(*COMMANDS)
    
    def initialize(str)
      COMMANDS.each { |cmd| instance_variable_set(add_at_sign(cmd), nil) }
      parse_commands(str)
    end
    
    def to_s
      to_a.join(' ')
    end
    
    def to_a
      COMMANDS.each_with_object([]) do |sym, ary|
        value = instance_variable_get(add_at_sign(sym))
        ary << to_command_name(sym, value) if value
      end
    end
    
    def empty?
      instance_variables.none? { |v| instance_variable_get(v) }
    end
    
    def clear
      instance_variables.each { |sym| remove_instance_variable(sym) }
    end
    
    alias delete clear
    
    def remove(*cmds)
      cmds.each { |cmd| remove_instance_variable(to_var_name(cmd)) }
    end
    
    def add(*cmds)
      cmds.each do |cmd|
        var_name = to_var_name(cmd)
        value = command_value(cmd)
        if var_name == :@others
          add_to_others(value)
        else
          instance_variable_set(var_name, value)
        end
      end
    end
    
    def from_pc?
      NON_PC_DEVICE.none? { |v| instance_variable_get(v) }
    end
    
    private
    
    def add_to_others(value)
      @others ? @others << value : @others = [value]
    end
    
    def parse_commands(str)
      str.split.each do |cmd|
        var_name = to_var_name(cmd)
        if instance_variable_get(var_name)
          add_to_others(cmd)
        else
          instance_variable_set(var_name, command_value(cmd))
        end
      end
    end
    
    def command_value(cmd)
      case cut_at_sign(to_var_name(cmd))
      when :position, :color, :size, :font then cmd.to_sym
      when :device then cmd.match(DEVICE_REG)[:suffix].to_sym
      when *COMMANDS then true
      else
        cmd.to_sym
      end
    end
    
    def to_command_name(var, value)
      case var
      when :position, :color, :size, :font, :others then value
      when :anonymity then :'184'
      when :device    then :"device:#{value}"
      when *COMMANDS  then var
      else
        raise ArgumentError, "undefined command `#{var}'"
      end
    end
    
    def to_var_name(cmd)
      cmd = cmd.to_sym if cmd.kind_of?(String)
      case cmd
      when :'184'             then :@anonymity
      when *POSITIONS         then :@position
      when *COLORS, HEX_COLOR then :@color
      when *SIZES             then :@size
      when *FONTS             then :@font
      when DEVICE_REG         then :@device
      when *COMMANDS          then :"@#{cmd}"
      else
        :@others
      end
    end
    
    def add_at_sign(sym)
      :"@#{sym}"
    end
    
    def cut_at_sign(sym)
      sym[0] == '@' ? sym[1..-1].to_sym : sym
    end
  end
end
