#===============================================================================
# ■ Fly Animation V1 by KleinStudio
# http://pokemonfangames.com
#===============================================================================
BIRD_ANIMATION_TIME = 24

class Game_Character
  def setOpacity(value)
    @opacity=(value)
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
  flybird.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/flybird.png")
      
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
