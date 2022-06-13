#===============================================================================
# ** Game_CommonEvent
#-------------------------------------------------------------------------------
#  This class handles common events. It includes execution of parallel process
#  event. This class is used within the Game_Map class ($game_map).
#===============================================================================
class Game_CommonEvent
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     common_event_id : common event ID
  #-----------------------------------------------------------------------------
  def initialize(common_event_id)
    @common_event_id = common_event_id
    @interpreter = nil
    refresh
  end
  #-----------------------------------------------------------------------------
  # * Get Name
  #-----------------------------------------------------------------------------
  def name
    return $cache.RXevents[@common_event_id].name
  end
  #-----------------------------------------------------------------------------
  # * Get Trigger
  #-----------------------------------------------------------------------------
  def trigger
    return $cache.RXevents[@common_event_id].trigger
  end
  #-----------------------------------------------------------------------------
  # * Get Condition Switch ID
  #-----------------------------------------------------------------------------
  def switch_id
    return $cache.RXevents[@common_event_id].switch_id
  end
  #-----------------------------------------------------------------------------
  # * Get List of Event Commands
  #-----------------------------------------------------------------------------
  def list
    return $cache.RXevents[@common_event_id].list
  end
  #-----------------------------------------------------------------------------
  # * Checks if switch is on
  #-----------------------------------------------------------------------------
  def switchIsOn?(id)
    switchname=$cache.RXsystem.switches[id]
    return false if !switchname
    if switchname[/^s\:/]
      return eval($~.post_match)
    else
      return $game_switches[id]
    end
  end
  #-----------------------------------------------------------------------------
  # * Refresh
  #-----------------------------------------------------------------------------
  def refresh
    # Create an interpreter for parallel process if necessary
    if self.trigger == 2 and switchIsOn?(self.switch_id)
      if @interpreter == nil
        @interpreter = Interpreter.new
      end
    else
      @interpreter = nil
    end
  end
  
  def interpreter
    return @interpreter
  end
  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    # If parallel process is valid
    if @interpreter != nil
      # If not running
      unless @interpreter.running?
        # Set up event
        @interpreter.setup(self.list, 0)
      end
      # Update interpreter
      @interpreter.update
    end
  end
end