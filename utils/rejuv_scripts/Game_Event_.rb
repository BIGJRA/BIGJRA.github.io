class Game_Event < Game_Character
  attr_reader   :trigger                
  attr_reader   :list                   
  attr_reader   :starting               
  attr_reader   :tempSwitches # Temporary self-switches
  attr_accessor :need_refresh
  attr_accessor :need_update

  def initialize(map_id, event, map=nil)
    super(map)
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @need_refresh=false
    @route_erased=false
    @through = true
    @tempSwitches={}
    moveto(@event.x, @event.y) if map
    refresh
  end

  #--------------------------------------------------------------------------
  # * Get Screen Z-Coordinates
  #     height : character height
  #--------------------------------------------------------------------------
  def screen_z(height = 0)
    # If display flag on closest surface is ON
    if @always_on_top
      # 999, unconditional
      return 999
    end
    # Get screen coordinates from real coordinates and map display position
    z = (@real_y - $game_map.display_y + 3) / 4 + 32
    # If tile
    if @tile_id > 0
      # Add tile priority * 32
      return z + $game_map.priorities[@tile_id] * 32
    # If character
    else
      # If height exceeds 32, then add 31
      if @event.name[-6,6] == "bottom"
        return z - 32
      end
      return z + ((height > 32) ? 31 : 0)
    end
  end
  
  def map_id
    @map_id
  end

  def clear_starting
    @starting = false
  end

  def over_trigger?
    if @character_name != "" and not @through
      return false
    end
    if @event.name=="HiddenItem"
      return false
    end
    unless self.map.passable?(@x, @y, 0)
      return false
    end
    return true
  end

  def start
    if @list.size > 1
      @starting = true
    end
  end

  def erase
    @erased = true
    refresh
  end

  def erase_route
    @route_erased=true
    refresh
  end

  def name
   return @event.name
  end

  def id
   return @event.id
  end

  def pbCheckEventTriggerAfterTurning
    if $game_system.map_interpreter.running? || @starting
      return
    end
    if @event.name[/^Trainer\((\d+)\)$/]
      distance=$~[1].to_i
      if @trigger == 2 and pbEventCanReachPlayer?(self,$game_player,distance)
         if not jumping? and not over_trigger?
           start
         end
      end
    end
  end

  def tsOn?(c)
    return @tempSwitches && @tempSwitches[c]==true
  end

  def tsOff?(c)
    return !@tempSwitches || !@tempSwitches[c]
  end

  def setTempSwitchOn(c)
    @tempSwitches[c]=true    
    refresh
  end

  def setTempSwitchOff(c)
    @tempSwitches[c]=false
    refresh
  end

  def variable
    return nil if !$PokemonGlobal.eventvars
    return $PokemonGlobal.eventvars[[@map_id,@event.id]]
  end

  def setVariable(variable)
    $PokemonGlobal.eventvars[[@map_id,@event.id]]=variable
  end

  def varAsInt
    return 0 if !$PokemonGlobal.eventvars
    return $PokemonGlobal.eventvars[[@map_id,@event.id]].to_i
  end

  def expired?(secs=86400)
    ontime=self.variable
    time=pbGetTimeNow
    return ontime && (time.to_i>ontime+secs)
  end

  def expiredDays?(days=1)
    ontime=self.variable.to_i
    return false if !ontime
    now=pbGetTimeNow
    elapsed=(now.to_i-ontime)/86400
    elapsed+=1 if (now.to_i-ontime)%86400>(now.hour*3600+now.min*60+now.sec)
    return elapsed>=days
  end

  def onEvent?
    return @map_id==$game_map.map_id &&
       $game_player.x==self.x && $game_player.y==self.y
     end
    
  def isOff?(c)
    return !$game_self_switches[[@map_id,@event.id,c]]
  end

  def switchIsOn?(id)
    switchname=$data_system.switches[id]
    return false if !switchname
    if switchname[/^s\:/]
      return eval($~.post_match)
    else
      return $game_switches[id]
    end
  end

  def graphicName
    return @event.pages[0].graphic.character_name
  end
  
  def refresh
    new_page = nil
    unless @erased
      for page in @event.pages.reverse
        c = page.condition
        if c.switch1_valid
          if !switchIsOn?(c.switch1_id)
            next
          end
        end
        if c.switch2_valid
          if !switchIsOn?(c.switch2_id)
            next
          end
        end
        if c.variable_valid
          if $game_variables[c.variable_id] < c.variable_value
            next
          end
        end
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        new_page = page
        break
      end
    end
    if new_page == @page
      return
    end
    @page = new_page
    clear_starting
    if @page == nil
      @tile_id = 0
      @character_name = ""
      @character_hue = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      return
    end
    @tile_id = @page.graphic.tile_id
    @character_name = @page.graphic.character_name
    @character_hue = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end
    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed * 1.25
    @move_frequency = @page.move_frequency
    @move_route = @route_erased ? RPG::MoveRoute.new : @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list
    @interpreter = nil
    if @trigger == 4
      @interpreter = Interpreter.new
    end
    check_event_trigger_auto
  end

  def check_event_trigger_touch(x, y)
    if $game_system.map_interpreter.running?
      return
    end
    return if @trigger!=2
    return if x != $game_player.x || y != $game_player.y
    if not jumping? and not over_trigger?
      start
    end
  end

  def check_event_trigger_auto
    if @trigger == 2 and @x == $game_player.x and @y == $game_player.y
      if not jumping? and over_trigger?
        start
      end
    end
    if @trigger == 3
      start
    end
  end

  def update
    last_moving=moving?
    super
    if !moving? && last_moving
      $game_player.pbCheckEventTriggerFromDistance([2])
    end
    if @need_refresh
      @need_refresh=false
      refresh
    end
    check_event_trigger_auto
    if @interpreter != nil
      unless @interpreter.running?
        @interpreter.setup(@list, @event.id, @map_id)
      end
      @interpreter.update
    end
  end
end
