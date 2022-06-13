class Game_Player
  @@bobframespeed = 1.0/15
  
  def fullPattern
    case self.direction
      when 2
        return self.pattern
      when 4
        return 4+self.pattern
      when 6
        return 8+self.pattern
      when 8
        return 12+self.pattern
      else
        return 0
    end
  end

  def setDefaultCharName(chname,pattern)
    return if pattern<0 || pattern>=16
    @defaultCharacterName=chname
    @direction=[2,4,6,8][pattern/4]
    @pattern=pattern%4
  end

  def pbCanRun?
    terrain=pbGetTerrainTag
      return ($game_switches[392] && !Input.press?(Input::A) ||
           (!$game_switches[392] && Input.press?(Input::A))) &&
       !pbMapInterpreterRunning? && !@move_route_forcing &&
       $PokemonGlobal && $PokemonGlobal.runningShoes &&
       !$PokemonGlobal.diving && !$PokemonGlobal.surfing &&
       !$PokemonGlobal.bicycle && terrain!=PBTerrain::TallGrass &&
       terrain!=PBTerrain::Ice && !$game_switches[999] && !$PokemonGlobal.lavasurfing
  end

  def pbIsRunning?
    return !moving? && !@move_route_forcing && $PokemonGlobal && pbCanRun?
  end

  def character_name
    if !@defaultCharacterName
      @defaultCharacterName=""
    end
    if @defaultCharacterName!=""
      return @defaultCharacterName
    end
    if !moving? && !@move_route_forcing && $PokemonGlobal
      meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
      if $PokemonGlobal.playerID>=0 && meta && 
         !$PokemonGlobal.bicycle && 
         !$PokemonGlobal.diving && 
         !$PokemonGlobal.surfing && 
         !$PokemonGlobal.lavasurfing &&
         !$PokemonGlobal.rock
        if meta[4] && meta[4]!="" && Input.dir4!=0 && passable?(@x,@y,Input.dir4) && pbCanRun?
          # Display running character sprite
          @character_name=pbGetPlayerCharset(meta,4)
        else
          # Display normal character sprite 
          @character_name=pbGetPlayerCharset(meta,1)
        end
      end
    end
    return @character_name
  end

  alias update_old update

  def update
     if pbGetTerrainTag==PBTerrain::Ice
      @move_speed = $RPGVX ? 6.5 : 4.8
    elsif !moving? && !@move_route_forcing && $PokemonGlobal
      if $PokemonGlobal.bicycle
        @move_speed = $RPGVX ? 8 : 5.5
      elsif $game_switches[999]
        @move_speed = $RPGVX ? 6.5 : 5.2
      elsif pbCanRun? || $PokemonGlobal.surfing || $PokemonGlobal.lavasurfing
        @move_speed = $RPGVX ? 6.5 : 4.8
      else
        @move_speed = $RPGVX ? 4.5 : 4.0
      end
    end
    update_old
  end

  def update_pattern
    if $PokemonGlobal.surfing || $PokemonGlobal.diving
      p = ((Graphics.frame_count%60)*@@bobframespeed).floor
      @pattern = p if !@lock_pattern
      @pattern_surf = p
      @bob_height = (p>=2) ? 2 : 0
    else
      super
    end
  end
end



class Game_Character
  alias update_old2 update

  def update
    if self.is_a?(Game_Event)
      if @dependentEvents
        for i in 0...@dependentEvents.length
          if @dependentEvents[i][0]==$game_map.map_id &&
             @dependentEvents[i][1]==self.id
            @move_speed=$game_player.move_speed
            break
          end
        end
      end
    end
    update_old2
  end
end