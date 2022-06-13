=begin
A sprite whose sole purpose is to display an animation.  This sprite
can be displayed anywhere on the map and is disposed
automatically when its animation is finished.
=end
class AnimationSprite < RPG::Sprite
  def initialize(animID,map,tileX,tileY,viewport=nil,tinting=false)
    super(viewport)
    @tileX=tileX
    @tileY=tileY
    self.bitmap=Bitmap.new(1,1)
    self.bitmap.clear
    @map=map
    self.x=((@tileX*Game_Map.realResX)-@map.display_x+3)/4+(Game_Map::TILEWIDTH/2)
    self.y=((@tileY*Game_Map.realResY)-@map.display_y+3)/4+(Game_Map::TILEHEIGHT)
    pbDayNightTint(self) if tinting
    self.animation($data_animations[animID],true)
  end

  def dispose
    self.bitmap.dispose
    super
  end

  def update
    if !self.disposed?
      self.x=((@tileX*Game_Map.realResX)-@map.display_x+3)/4+(Game_Map::TILEWIDTH/2)
      self.y=((@tileY*Game_Map.realResY)-@map.display_y+3)/4+(Game_Map::TILEHEIGHT)
      super
      self.dispose if !self.effect?
    end
  end
end



class Spriteset_Map
  alias _animationSprite_initialize initialize
  alias _animationSprite_update update
  alias _animationSprite_dispose dispose

  def initialize(map=nil)
    @usersprites=[]
    _animationSprite_initialize(map)
  end

  def addUserAnimation(animID,x,y,tinting=false)
    viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z=99999
    sprite=AnimationSprite.new(animID,$game_map,x,y,viewport,tinting)
    addUserSprite(sprite)
    return sprite
  end

  def addUserSprite(sprite)
    for i in 0...@usersprites.length
      if @usersprites[i]==nil || @usersprites[i].disposed?
        @usersprites[i]=sprite
        return
      end
    end
    @usersprites.push(sprite)
  end

  def dispose
    _animationSprite_dispose
    for i in 0...@usersprites.length
      @usersprites[i].dispose
    end
    @usersprites.clear
  end

  def update
    return if @tilemap.disposed?
    if $RPGVX || $PokemonSystem.tilemap==0
      if self.map==$game_map
        pbDayNightTint(@viewport3)
      else
        @viewport3.tone.set(0,0,0,0)
      end
    else
      pbDayNightTint(@tilemap)
      @viewport3.tone.set(0,0,0,0)
    end
    _animationSprite_update
    for i in 0...@usersprites.length
      @usersprites[i].update if !@usersprites[i].disposed?
    end
  end
end