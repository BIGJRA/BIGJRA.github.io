#===============================================================================
# ** Modified Scene_Map class for Pokémon.
#-------------------------------------------------------------------------------
#  
#===============================================================================
class Scene_Map
  def spriteset
    for i in @spritesets.values
      return i if i.map==$game_map
    end
    return @spritesets.values[0]
  end

  def disposeSpritesets
    return if !@spritesets
    for i in @spritesets.keys
      if @spritesets[i]
        @spritesets[i].dispose
        @spritesets[i]=nil
      end
    end
    @spritesets.clear
    @spritesets={}
#    @spritesetglobal.dispose
#    @spritesetglobal=nil
  end

  def createSpritesets
    @spritesets={}
    for map in $MapFactory.maps
      @spritesets[map.map_id]=Spriteset_Map.new(map)
    end
#    @spritesetglobal=Spriteset_Global.new
    $MapFactory.setSceneStarted(self)
    updateSpritesets
  end

  def updateMaps
    for map in $MapFactory.maps
      map.update
    end
    $MapFactory.updateMaps(self)
  end

  def updateSpritesets
    @spritesets={} if !@spritesets
    keys=@spritesets.keys.clone
    for i in keys
      if !$MapFactory.hasMap?(i)
        @spritesets[i].dispose if @spritesets[i]
        @spritesets[i]=nil
        @spritesets.delete(i)
      else
        @spritesets[i].update
      end
    end
#    @spritesetglobal.update
    for map in $MapFactory.maps
      if !@spritesets[map.map_id]
        @spritesets[map.map_id]=Spriteset_Map.new(map)
      end
    end
    Events.onMapUpdate.trigger(self)
  end

  def main
    createSpritesets
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    disposeSpritesets
    if $game_temp.to_title
      Graphics.transition
      Graphics.freeze
    end
  end

  def miniupdate
    $PokemonTemp.miniupdate=true if $PokemonTemp
    loop do
      updateMaps
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end
      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    updateSpritesets
    $PokemonTemp.miniupdate=false if $PokemonTemp
  end

  def update
    loop do
      updateMaps
      pbMapInterpreter.update
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end
      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    updateSpritesets
    if $game_temp.to_title
      $scene = pbCallTitle
      return
    end
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
           $game_temp.transition_name)
      end
    end
    if $game_temp.message_window_showing
      return
    end    
    if Input.trigger?(Input::C)
      unless pbMapInterpreterRunning?
        $PokemonTemp.hiddenMoveEventCalling=true
      end
    end      
    if Input.trigger?(Input::B)
      unless pbMapInterpreterRunning? or $game_system.menu_disabled or $game_player.moving?
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
     if Input.trigger?(Input::Y)
      $game_switches[392] = !$game_switches[392]
    end
# QUICKSAVE UPDATE
    if Input.trigger?(Input::Z)
      if Kernel.pbConfirmMessage(_INTL("Would you like to save the game?"))
        if pbSave
          Kernel.pbMessage("Saved the game!")
        else
          Kernel.pbMessage("Save failed.")
        end
      end
    end
# END OF UPDATE
    unless pbMapInterpreterRunning?
      for keyNumber in 0...Input::ITEMKEYS.size
        if Input.trigger?(Input::ITEMKEYS[keyNumber]) && $PokemonTemp
          $PokemonTemp.keyItemCalling = keyNumber
        end
      end
    end
    if $DEBUG and Input.press?(Input::F9)
      $game_temp.debug_calling = true
    end
    unless $game_player.moving?
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      elsif $PokemonTemp && $PokemonTemp.keyItemCalling
# MULTIPLE REGISTRATION CODE
        $game_player.straighten
        Kernel.pbUseKeyItem($PokemonTemp.keyItemCalling)
        $PokemonTemp.keyItemCalling=nil
      elsif $PokemonTemp && $PokemonTemp.hiddenMoveEventCalling
        $PokemonTemp.hiddenMoveEventCalling=false
        $game_player.straighten
        Events.onAction.trigger(self)
      end
    end
  end

  def call_name
    $game_temp.name_calling = false
    $game_player.straighten
    $game_map.update
  end

  def call_menu
    $game_player.straighten
    $game_map.update
    sscene=PokemonMenu_Scene.new
    sscreen=PokemonMenu.new(sscene) 
    sscreen.pbStartPokemonMenu
    $game_temp.menu_calling = false 
  end

  def call_debug
    $game_temp.debug_calling = false
    pbPlayDecisionSE()
    $game_player.straighten
    $scene = Scene_Debug.new
  end

  def autofade(mapid)
    playingBGS=$game_system.playing_bgs
    playingBGM=$game_system.playing_bgm
    return if !playingBGM && !playingBGS
    map=pbLoadRxData(sprintf("Data/Map%03d", mapid))
    if playingBGM && map.autoplay_bgm
      if (PBDayNight.isNight?(pbGetTimeNow) rescue false)
        if playingBGM.name!=map.bgm.name && playingBGM.name!=map.bgm.name+"n"
          pbBGMFade(0.8)
        end
      else
        if playingBGM.name!=map.bgm.name
          pbBGMFade(0.8)
        end
      end
    end
    if playingBGS && map.autoplay_bgs
      if playingBGS.name!=map.bgs.name
        pbBGMFade(0.8)
      end
    end
    Graphics.frame_reset
  end

  def transfer_player(cancelVehicles=true)
    $game_temp.player_transferring = false
    if cancelVehicles && $game_switches[649] == false
      Kernel.pbCancelVehicles($game_temp.player_new_map_id)
    end
    autofade($game_temp.player_new_map_id)
#    pbBridgeOff
    if $game_map.map_id!=$game_temp.player_new_map_id
      $MapFactory.setup($game_temp.player_new_map_id)
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    case $game_temp.player_new_direction
    when 2; $game_player.turn_down
    when 4; $game_player.turn_left
    when 6; $game_player.turn_right
    when 8; $game_player.turn_up
    end
    $game_player.straighten
    $game_map.update
    disposeSpritesets
    #GC.start
    createSpritesets
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition(20)
    end
    $game_map.autoplay
    Graphics.frame_reset
    Input.update
  end
end