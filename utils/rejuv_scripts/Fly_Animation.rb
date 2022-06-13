#===============================================================================
# ■ Fly Animation V1 by KleinStudio
# http://pokemonfangames.com
#===============================================================================
BIRD_ANIMATION_TIME = 24

HiddenMoveHandlers::UseMove.add(:FLY,lambda{|move,pokemon|
   if !$PokemonTemp.flydata
     Kernel.pbMessage(_INTL("Can't use that here."))
   end
      
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   
   pbFlyAnimation
   pbFadeOutIn(99999){
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
      $game_temp.player_new_x=$PokemonTemp.flydata[1]
      $game_temp.player_new_y=$PokemonTemp.flydata[2]
      $PokemonTemp.flydata=nil
      $game_temp.player_new_direction=2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
   }
   pbFlyAnimation(true)
   pbEraseEscapePoint
   return true
})

class Game_Character
  def setOpacity(value)
    opacity=(value)
  end
end

def pbFlyAnimation(landing=false)
  if !landing
    $game_player.turn_left
    pbSEPlay("flybird")
  end
  initialy = DEFAULTSCREENHEIGHT/4
  middley = DEFAULTSCREENHEIGHT/2+96
  
  flybird = Sprite.new
  flybird.bitmap = RPG::Cache.picture("flybird")
      
  flyAnimation=PictureEx.new(flybird.z)
  flyAnimation.moveOrigin(1,PictureOrigin::Center)
  flyAnimation.moveXY(0,1,DEFAULTSCREENWIDTH+flybird.bitmap.width,initialy)
  flyAnimation.moveCurve(BIRD_ANIMATION_TIME,1,
    DEFAULTSCREENWIDTH+flybird.bitmap.width, initialy,
    DEFAULTSCREENWIDTH/2, middley, 
    -flybird.bitmap.width-1, initialy
  )
  
  loop do
    pbUpdateSceneMap
    flyAnimation.update
    setPictureSprite(flybird,flyAnimation)
    $game_player.setOpacity(landing ? 255 : 0) if flybird.x<=DEFAULTSCREENWIDTH/2
    Graphics.update
    break if flybird.x<=-flybird.bitmap.width
  end
    
  flybird.dispose
  flybird = nil
end
