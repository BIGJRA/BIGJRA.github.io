class Game_Character
  attr_reader   :id
  attr_reader   :x
  attr_reader   :y
  attr_reader   :real_x 
  attr_reader   :real_y
  attr_reader   :tile_id  
  attr_accessor :character_name
  attr_accessor :character_hue 
  attr_accessor   :opacity   
  attr_reader   :blend_type 
  attr_reader   :direction  
  attr_reader   :pattern    
  attr_reader   :move_route_forcing   
  attr_accessor :through            
  attr_accessor :animation_id       
  attr_accessor :transparent        
  attr_reader   :map
  attr_accessor :move_speed
  attr_accessor :walk_anime

  def map
    return @map
  end

  def initialize(map=nil)
    @map=map
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_hue = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    @move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @locked = false
    @prelock_direction = 0
  end

  def moving?
    return (@real_x != @x*128 || @real_y != @y*128)
  end

  def jumping?
    return @jump_count > 0
  end

  def pattern=(value)
    @pattern=value
  end

  def straighten
    if @walk_anime || @step_anime
      @pattern = 0
    end
    @anime_count = 0
    @prelock_direction = 0
  end

  def force_move_route(move_route)
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
    move_type_custom
  end

  def passableEx?(x, y, d, strict=false)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    return false unless self.map.valid?(new_x, new_y)
    return true if @through
    if strict
      return false unless self.map.passableStrict?(x, y, d, self)
      return false unless self.map.passableStrict?(new_x, new_y, 10 - d, self)
    else
      return false unless self.map.passable?(x, y, d, self)
      return false unless self.map.passable?(new_x, new_y, 10 - d, self)
    end
    for event in self.map.events.values
      if event.x == new_x && event.y == new_y
        unless event.through
          return false if self != $game_player || event.character_name != ""
        end
      end
    end
    if $game_player.x == new_x && $game_player.y == new_y
      unless $game_player.through
        return false if @character_name != ""
      end
    end
    return true
  end

  def passable?(x,y,d)
    return passableEx?(x,y,d,false)
  end

  def passableStrict?(x,y,d)
    return passableEx?(x,y,d,true)
  end

  def lock
    if @locked
      return
    end
    @prelock_direction = @direction
    turn_toward_player
    @locked = true
  end

  def lock?
    return @locked
  end

  def unlock
    unless @locked
      return
    end
    @locked = false
    unless @direction_fix
      if @prelock_direction != 0
        @direction = @prelock_direction
      end
    end
  end

  def triggerLeaveTile
    if @oldX && @oldY && @oldMap &&
         (@oldX!=self.x || @oldY!=self.y || @oldMap!=self.map.map_id)
      Events.onLeaveTile.trigger(self,self,@oldMap,@oldX,@oldY)
     end
     @oldX=self.x
     @oldY=self.y
     @oldMap=self.map.map_id
  end

  def moveto(x, y)
    @x = x % self.map.width
    @y = y % self.map.height
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
    triggerLeaveTile()
  end

  def screen_x
    return (@real_x / 4 - self.map.display_x.to_i / 4) + 16
  end

  def screen_y
    y = screen_y_ground
    if jumping?
      if @jump_count >= @jump_peak
        n = @jump_count - @jump_peak
      else
        n = @jump_peak - @jump_count
      end
      return (y - (@jump_peak * @jump_peak - n * n) / 2).floor
    else
      return y
    end
  end

  def screen_y_ground
    return ( @real_y / 4 - self.map.display_y.to_i / 4) + 32
  end

  def screen_z(height = 0)
    if @always_on_top
      return 999
    end
    z = screen_y_ground
    if @tile_id > 0
      return z + self.map.priorities[@tile_id] * 32
    else
      # Add Z if height exceeds 32
      return z + ((height > 32) ? 31 : 0)
    end
  end

  def bush_depth
    if @tile_id > 0 || @always_on_top
      return 0
    end
    xbehind=(@direction==4) ? @x+1 : (@direction==6) ? @x-1 : @x
    ybehind=(@direction==8) ? @y+1 : (@direction==2) ? @y-1 : @y
    if @jump_count <= 0 && self.map.deepBush?(@x, @y) && self.map.deepBush?(xbehind, ybehind)
      return 32
    elsif @jump_count <= 0 && self.map.bush?(@x, @y) && !moving?
      return 12
    else
      return 0
    end
  end

  def terrain_tag
    return self.map.terrain_tag(@x, @y)
  end

# Updating stuff ###############################################################
  def update
    return if $game_temp.menu_calling
    #cass note: pulled from Walk_Run
    if @dependentEvents
      for i in 0...@dependentEvents.length
        if @dependentEvents[i][0]==$game_map.map_id &&
           @dependentEvents[i][1]==self.id
          @move_speed=$game_player.move_speed
          break
        end
      end
    end
    if jumping?
      update_jump
    elsif moving?
      update_move
    elsif !(self==$game_player && $PokemonGlobal.fishing)
      update_stop
    end

    update_pattern unless self==$game_player && $PokemonGlobal.fishing
    if @wait_count > 0
      @wait_count -= 1
      return
    end
    if @move_route_forcing
      move_type_custom
      return
    end
    if @starting || @locked
      return
    end
    if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
      case @move_type
        when 1 then move_type_random
        when 2 then move_type_toward_player
        when 3 then move_type_custom
      end
    end
  end
  
  def update_pattern
    return if @lock_pattern
    @anime_count = 20 if !@step_anime && @stop_count>0
    if @anime_count > 18-@move_speed*3
      if !@step_anime && @stop_count>0
        @pattern = @original_pattern
      else
        @pattern = (@pattern+1)%4
      end
      @anime_count = 0
    end
  end

  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x * 128) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 128) / (@jump_count + 1)
    if !jumping? && !moving?
      Events.onStepTakenFieldMovement.trigger(self,self)
    end
  end

  def update_move
    distance = 2 ** @move_speed
    at_x = @x * 128
    at_y = @y * 128
    if at_y > @real_y
      @real_y = [@real_y + distance, at_y].min
    elsif at_y < @real_y
      @real_y = [@real_y - distance, at_y].max
    end
    if at_x < @real_x
      @real_x = [@real_x - distance, at_x].max
    elsif at_x > @real_x
      @real_x = [@real_x + distance, at_x].min
    end
    if !jumping?
      if !moving?
        Events.onStepTakenFieldMovement.trigger(self,self)
      end
    end
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end

  def update_stop
    if @step_anime
      @anime_count += 1
    elsif @pattern != @original_pattern
      @pattern=@original_pattern
      @anime_count=0
    end
    unless @starting || lock?
      @stop_count += 1
    end
  end

  def move_type_random
    case rand(6)
      when 0..3
        move_random
      when 4 
        move_forward
      when 5
        @stop_count = 0
    end
  end

  def move_type_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    abs_sx = sx > 0 ? sx : -sx
    abs_sy = sy > 0 ? sy : -sy
    if sx + sy >= 20
      move_random
      return
    end
    case rand(6)
      when 0..3 
        move_toward_player
      when 4 
        move_random
      when 5  
        move_forward
    end
  end

  def move_type_custom
    if jumping? || moving?
      return
    end
    while @move_route_index < @move_route.list.size
      #KotH wait
      if $game_switches[:In_Battle] || $game_switches[:Mid_quicksave]
        @wait_count +=1
        return
      else
        command = @move_route.list[@move_route_index]
      end
      if command.code == 0
        if @move_route.repeat
          @move_route_index = 0
        end
        unless @move_route.repeat
          if @move_route_forcing && !@move_route.repeat 
            @move_route_forcing = false
            @move_route = @original_move_route
            @move_route_index = @original_move_route_index 
            @original_move_route = nil
          end
          @stop_count = 0
        end
        return
      end
      if command.code <= 14
        case command.code
          when 1 then move_down
          when 2 then move_left
          when 3 then move_right
          when 4 then move_up
          when 5 then move_lower_left
          when 6 then move_lower_right
          when 7 then move_upper_left
          when 8 then move_upper_right
          when 9 then move_random
          when 10 then move_toward_player
          when 11 then move_away_from_player
          when 12 then move_forward(true)
          when 13 then move_backward
          when 14 then jump(command.parameters[0], command.parameters[1])
        end
        if !@move_route.skippable && !moving? && !jumping?
          return
        end
        @move_route_index += 1
        return
      end
      if command.code == 15
        @wait_count = command.parameters[0] * 2 - 1
        @move_route_index += 1
        return
      end
      if command.code >= 16 && command.code <= 26
        case command.code
          when 16 then turn_down
          when 17 then turn_left
          when 18 then turn_right
          when 19 then turn_up
          when 20 then turn_right_90
          when 21 then turn_left_90
          when 22 then turn_180
          when 23 then turn_right_or_left_90
          when 24 then turn_random
          when 25 then turn_toward_player
          when 26 then turn_away_from_player
        end
        @move_route_index += 1
        return
      end
      if command.code >= 27
        case command.code
          when 27 then $game_switches[command.parameters[0]] = true; self.map.need_refresh = true
          when 28 then $game_switches[command.parameters[0]] = false; self.map.need_refresh = true
          when 29 then @move_speed = command.parameters[0]
          when 30 then @move_frequency = command.parameters[0]
          when 31 then @walk_anime = true
          when 32 then @walk_anime = false
          when 33 then @step_anime = true
          when 34 then @step_anime = false
          when 35 then @direction_fix = true
          when 36 then @direction_fix = false
          when 37 then @through = true
          when 38 then @through = false
          when 39 then @always_on_top = true
          when 40 then @always_on_top = false
          when 41
            @tile_id = 0
            @character_name = command.parameters[0]
            @character_hue = command.parameters[1]
            if @original_direction != command.parameters[2]
              @direction = command.parameters[2]
              @original_direction = @direction
              @prelock_direction = 0
            end
            if @original_pattern != command.parameters[3]
              @pattern = command.parameters[3]
              @original_pattern = @pattern
            end
          when 42 then @opacity = command.parameters[0]
          when 43 then @blend_type = command.parameters[0]
          when 44 then pbSEPlay(command.parameters[0])
          when 45 then result = eval(command.parameters[0])
        end
        @move_route_index += 1
      end
    end
  end

  def increase_steps
    @stop_count = 0
    triggerLeaveTile()
  end

# Movement stuff ###############################################################
  def move_down(turn_enabled = true)
    if turn_enabled
      turn_down
    end
    if passable?(@x, @y, 2)
      turn_down
      @y += 1
      increase_steps
    else
      check_event_trigger_touch(@x, @y+1)
    end
  end

  def move_left(turn_enabled = true)
    if turn_enabled
      turn_left
    end
    if passable?(@x, @y, 4)
      turn_left
      @x -= 1
      increase_steps
    else
      check_event_trigger_touch(@x-1, @y)
    end
  end

  def move_right(turn_enabled = true)
    if turn_enabled
      turn_right
    end
    if passable?(@x, @y, 6)
      turn_right
      @x += 1
      increase_steps
    else
      check_event_trigger_touch(@x+1, @y)
    end
  end

  def move_up(turn_enabled = true)
    if turn_enabled
      turn_up
    end
    if passable?(@x, @y, 8)
      turn_up
      @y -= 1
      increase_steps
    else
      check_event_trigger_touch(@x, @y-1)
    end
  end

  def move_lower_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y, 2) && passable?(@x, @y + 1, 4)) ||
       (passable?(@x, @y, 4) && passable?(@x - 1, @y, 2))
      @x -= 1
      @y += 1
      if self.is_a?(Game_Player)
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x+1,@y-1)
      end
      increase_steps
    end
  end

  def move_lower_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y, 2) && passable?(@x, @y + 1, 6)) ||
       (passable?(@x, @y, 6) && passable?(@x + 1, @y, 2))
      @x += 1
      @y += 1
      if self.is_a?(Game_Player)
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x-1,@y-1)
      end
      increase_steps
    end
  end

  def move_upper_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y, 8) && passable?(@x, @y - 1, 4)) ||
       (passable?(@x, @y, 4) && passable?(@x - 1, @y, 8))
      @x -= 1
      @y -= 1
      if self.is_a?(Game_Player)
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x+1,@y+1)
      end
      increase_steps
    end
  end

  def move_upper_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y, 8) && passable?(@x, @y - 1, 6)) ||
       (passable?(@x, @y, 6) && passable?(@x + 1, @y, 8))
      @x += 1
      @y -= 1
      if self.is_a?(Game_Player)
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x-1,@y+1)
      end
      increase_steps
    end
  end

  def move_random
    case rand(4)
      when 0 then move_down(false)
      when 1 then move_left(false)
      when 2 then move_right(false)
      when 3 then move_up(false)
    end
  end

  def move_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx == 0 && sy == 0
      return
    end
    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    if abs_sx > abs_sy
      sx > 0 ? move_left : move_right
      if !moving? && sy != 0
        sy > 0 ? move_up : move_down
      end
    else
      sy > 0 ? move_up : move_down
      if !moving? && sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end

  def move_away_from_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx == 0 && sy == 0
      return
    end
    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    if abs_sx > abs_sy
      sx > 0 ? move_right : move_left
      if !moving? && sy != 0
        sy > 0 ? move_down : move_up
      end
    else
      sy > 0 ? move_down : move_up
      if !moving? && sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end

  def move_forward(turn_enabled_overwrite=false)
    case @direction
      when 2
        move_down(turn_enabled_overwrite)
      when 4
        move_left(turn_enabled_overwrite)
      when 6
        move_right(turn_enabled_overwrite)
      when 8
        move_up(turn_enabled_overwrite)
    end
  end

  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
      when 2 
        move_up(false)
      when 4 
        move_right(false)
      when 6 
        move_left(false)
        
      when 8 
        move_down(false)
    end
    @direction_fix = last_direction_fix
  end

  def jump(x_plus, y_plus)
    if x_plus != 0 || y_plus != 0
      if x_plus.abs > y_plus.abs
        x_plus < 0 ? turn_left : turn_right
      else
        y_plus < 0 ? turn_up : turn_down
      end
    end
    new_x = @x + x_plus
    new_y = @y + y_plus
    oldX=@x
    oldY=@y
    if (x_plus == 0 && y_plus == 0) || passable?(new_x, new_y, 0)
      straighten
      @x = new_x
      @y = new_y
      distance = [4, x_plus * x_plus + y_plus * y_plus].max
      @jump_peak = 6 + distance - @move_speed
      @jump_peak = @jump_peak.floor
      #print @jump_peak
      @jump_peak = [@jump_peak,18].min #maybe don't yeet the player off the entire top of the screen if that's cool with everyone?
      @jump_count = @jump_peak * 2
      @stop_count = 0
      if self.is_a?(Game_Player)
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(oldX,oldY)
      end
      triggerLeaveTile()
    end
  end

  def turnGeneric(dir)
    unless @direction_fix
      oldDirection=@direction
      @direction=dir
      @stop_count=0
      if dir!=oldDirection
        pbCheckEventTriggerAfterTurning
      end
    end
  end

  def turn_down; turnGeneric(2); end

  def turn_left; turnGeneric(4); end

  def turn_right; turnGeneric(6); end

  def turn_up; turnGeneric(8); end

  def turn_right_90
    case @direction
      when 2
        turn_left
      when 4
        turn_up
      when 6
        turn_down
      when 8
        turn_right
    end
  end

  def turn_left_90
    case @direction
      when 2
        turn_right
      when 4
        turn_down
      when 6
        turn_up
      when 8
        turn_left
    end
  end

  def turn_180
    case @direction
      when 2
        turn_up
      when 4
        turn_right
      when 6
        turn_left
      when 8
        turn_down
    end
  end

  def turn_right_or_left_90
    if rand(2) == 0
      turn_right_90
    else
      turn_left_90
    end
  end

  def turn_random
    case rand(4)
      when 0
        turn_up
      when 1
        turn_right
      when 2
        turn_left
      when 3
        turn_down
    end
  end

  def turn_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx == 0 && sy == 0
      return
    end
    if sx.abs > sy.abs
      sx > 0 ? turn_left : turn_right
    else
      sy > 0 ? turn_up : turn_down
    end
  end

  def turn_away_from_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx == 0 && sy == 0
      return
    end
    if sx.abs > sy.abs
      sx > 0 ? turn_right : turn_left
    else
      sy > 0 ? turn_down : turn_up
    end
  end

  def graphical?
    return @character_name != "" || @tile_id != 0
  end
  alias graphicalNow? graphical?
end