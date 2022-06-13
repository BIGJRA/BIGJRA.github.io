#===============================================================================
# ** Game_Switches
#-------------------------------------------------------------------------------
#  This class handles switches. It's a wrapper for the built-in class "Array."
#  Refer to "$game_switches" for the instance of this class.
#===============================================================================

class Game_Switches
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #-----------------------------------------------------------------------------
  # * Get Switch
  #     switch_id : switch ID
  #-----------------------------------------------------------------------------
  def [](switch_id)
    switch_id = Switches[switch_id] if switch_id.is_a?(Symbol)
    return false if switch_id.nil?
    if switch_id <= 5000 && @data[switch_id] != nil
      return @data[switch_id]
    else
      return false
    end
  end
  #-----------------------------------------------------------------------------
  # * Set Switch
  #     switch_id : switch ID
  #     value     : ON (true) / OFF (false)
  #-----------------------------------------------------------------------------
  def []=(switch_id, value)
    switch_id = Switches[switch_id] if switch_id.is_a?(Symbol)
    return if switch_id.nil?
    if switch_id <= 5000
      @data[switch_id] = value
    end
  end
end

#===============================================================================
# ** Game_SelfSwitches
#-------------------------------------------------------------------------------
#  This class handles self switches. It's a wrapper for the built-in class
#  "Hash." Refer to "$game_self_switches" for the instance of this class.
#===============================================================================

class Game_SelfSwitches
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @data = {}
  end
  #-----------------------------------------------------------------------------
  # * Get Self Switch 
  #     key : key
  #-----------------------------------------------------------------------------
  def [](key)
    return @data[key] == true ? true : false
  end
  #-----------------------------------------------------------------------------
  # * Set Self Switch
  #     key   : key
  #     value : ON (true) / OFF (false)
  #-----------------------------------------------------------------------------
  def []=(key, value)
    @data[key] = value
  end
end

#===============================================================================
# ** Game_Variables
#-------------------------------------------------------------------------------
#  This class handles variables. It's a wrapper for the built-in class "Array."
#  Refer to "$game_variables" for the instance of this class.
#===============================================================================

class Game_Variables
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #-----------------------------------------------------------------------------
  # * Get Variable
  #     variable_id : variable ID
  #-----------------------------------------------------------------------------
  def [](variable_id)
    variable_id = Variables[variable_id] if variable_id.is_a?(Symbol)
    if variable_id <= 5000 && @data[variable_id] != nil
      return @data[variable_id]
    else
      return 0
    end
  end
  #-----------------------------------------------------------------------------
  # * Set Variable
  #     variable_id : variable ID
  #     value       : the variable's value
  #-----------------------------------------------------------------------------
  def []=(variable_id, value)
    variable_id = Variables[variable_id] if variable_id.is_a?(Symbol)
    if variable_id <= 5000
      @data[variable_id] = value
    end
  end
end