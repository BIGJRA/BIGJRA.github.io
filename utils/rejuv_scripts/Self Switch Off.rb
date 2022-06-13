#===============================================================================
# Set Self-Switches to All Events on Map                           Author: KK20
#------------------------------------------------------------------------------
# Purpose:
#   Sets all events' self-switch(es) on a specific map to either ON or OFF.
#
# How to Use:
#   Script can be placed anywhere above Main.
#   In an event, use a 'Script' event command, and type in
#
#                set_self_switches(MAP_ID, SWITCH, VALUE)
#
# Parameters:
#  MAP_ID => An integer; the map ID you wish to reset the self-switches for.
#            If the value is nil, assumes the current map the player is on.
#  SWITCH => A string or array of strings; the self-switch keys you want to
#            change on all events in the map. If nil, will change all of the
#            default self-switch values (i.e. letters A through E).
#  VALUE  => A boolean; choose to set all self-switches to either ON (true) or
#            OFF (false). The default value is false.
#
# Examples of uses:
#   set_self_switches
#     => Turns all the events' self-switches on the current map to OFF
#   set_self_switches(nil, ['A', 'B'], true)
#     => Turns all the events' self-switches A and B on the current map to ON
#   set_self_switches(3, 'A')y
#     => Turns all the events' self-switches A on map #3 to OFF
#   set_self_switches(1)
#     => Turns all the events' self-switches on map #1 to OFF
#
#===============================================================================
class Interpreter
  def set_self_switches(map_id = nil, switch = nil, value = false)
    map_id = $game_map.map_id if map_id.nil?
    switch = ['A','B','C','D','E'] if switch.nil?
    switch = Array(switch)
    
    map = load_data(sprintf("Data/Map%03d.rxdata", map_id))
    map.events.keys.each{|event_id|
      switch.each{|switch_type|
        key = [map_id, event_id, switch_type]
        $game_self_switches[key] = value
      }
    }
    $game_map.need_refresh = ($game_map.map_id == map_id)
  end
end