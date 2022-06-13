#===============================================================================
# ** Modified Scene_Map class for Pokémon.
#-------------------------------------------------------------------------------
class Scene_Map          #
  def initialize         #
#                        #
#========================#
# Config, edit to adjust #
#========================#
    @as_interval = 10     # Save interval:
                         #   Time between saves
                         #
    @as_type = "m"       # Save type:
                         #   s = seconds
                         #   m = minutes
                         #   h = hours
#========================#
# Stop editing           #
#========================#
#                        #
#                        # Autosave Script made by CaysCollapse
#                        # Please credit me.
#===============================================================================
    @counter = 0
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
    if $PokemonSystem.autosave == 999
      time = @as_interval * 30
      @counter += 1
      case @as_type
      when "m"
        time = @as_interval * 30
        time *= 60
      when "h"
        time = @as_interval * 30
        time *= 60    
        time *= 60    
      else
      end
      if @counter==time
        pbSave
        if !File.exist?("Graphics/Icons/saveDisk.png") or 
            !File.exist?("Graphics/Icons/saveArrow.png")
          @counter = 0
          return
        end
        @as_disk = Sprite.new
        @as_disk.x = @as_disk.y = 32
        @as_disk.opacity = 0
        @as_disk.bitmap = Bitmap.new("Graphics/Icons/saveDisk")
        @as_arrow = Sprite.new
        @as_arrow.x = 32
        @as_disk.y = 16
        @as_arrow.opacity = 0
        @as_arrow.bitmap = Bitmap.new("Graphics/Icons/saveArrow")
      end
      if @counter >= time and @counter < time + 17
        @as_disk.opacity += 15
        @as_arrow.opacity += 15
      end
      if @counter >= time + 17 and @counter < time + 25
        @as_arrow.y += 1
      end
      if @counter >= time + 34
        @as_disk.opacity -= 15
        @as_arrow.opacity -= 15
      end
      if @counter > time + 100
        @as_disk.dispose
        @as_arrow.dispose
        @counter = 0
      end
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
end