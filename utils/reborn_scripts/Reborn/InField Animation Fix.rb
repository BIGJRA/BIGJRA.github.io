#===============================================================================
# ■ In-field animation fix V1.2 by KleinStudio
# http://kleinstudio.deviantart.com
#===============================================================================
# Add here the animations (ids) you want to be fixed
#===============================================================================
ANIMATIONS_TO_FIX=[
  GRASS_ANIMATION_ID,
  DUST_ANIMATION_ID,
]


class Spriteset_Map
  attr_accessor :viewport1
  
  def addUserAnimation(animID,x,y,tinting=false)
    rsprite=nil
    for sprite in @character_sprites.values
      rsprite=sprite if sprite.character.x==x && sprite.character.y==y
    end
    sprite=AnimationSprite.new(rsprite,animID,$game_map,x,y,@viewport1,tinting)
    addUserSprite(sprite)
    return sprite
  end
end

class AnimationSprite < RPG::Sprite
  def initialize(rsprite,animID,map,tileX,tileY,viewport=nil,tinting=false)
    super(viewport)
    @rsprite=rsprite
    @tileX=tileX
    @tileY=tileY
    self.bitmap=Bitmap.new(1,1)
    self.bitmap.clear
    @map=map
    self.x=((@tileX*Game_Map.realResX)-@map.display_x+3)/4+(Game_Map::TILEWIDTH/2)
    self.y=((@tileY*Game_Map.realResY)-@map.display_y+3)/4+(Game_Map::TILEHEIGHT)
    pbDayNightTint(self) if tinting
    self.animation($cache.RXanimations[animID],true,@rsprite,tileY,animID)
  end
end

module RPG
  class Sprite < ::Sprite
    def animation(animation, hit,rsprite=nil,tileY=nil,animID=nil)
      anim=SpriteAnimation.new(self,rsprite,tileY,animID)
      anim.animation(animation,hit)
      pushAnimation(@animations,anim)
    end
  end
end

class SpriteAnimation
  def initialize(sprite,rsprite,tileY,animID)
    @sprite=sprite
    @rsprite=rsprite
    @tileY=tileY
    @real_y=tileY==nil ? 0 : @tileY*Game_Map.realResY 
    @alwaysontop=true
    for anims in ANIMATIONS_TO_FIX
      @alwaysontop=false if anims==animID
    end
    update_z
  end

  def update
    if @_animation != nil and (Graphics.frame_count % 2 == 0)
      @_animation_duration -= 1
      update_animation
    end
    if @_loop_animation != nil and (Graphics.frame_count % 2 == 0)
      update_loop_animation
      @_loop_animation_index += 1
      @_loop_animation_index %= @_loop_animation.frame_max
    end
  end

  def update_animation
    if @_animation_duration > 0
      frame_index = @_animation.frame_max - @_animation_duration
      cell_data = @_animation.frames[frame_index].cell_data
      position = @_animation.position
      animation_set_sprites(@_animation_sprites, cell_data, position)
      for timing in @_animation.timings
        if timing.frame == frame_index
          animation_process_timing(timing, @_animation_hit)
        end
      end
    else
      dispose_animation
    end
  end
  
  def screen_z
    z = (@real_y - $game_map.display_y.floor + 3) / 4 + 32
    z = 2000 if @alwaysontop
    return z + ((48 > 32) ? 31 : 0)
  end
  
  def update_z
    @z=(@tileY==nil && @rsprite==nil) ? 2000 : screen_z
    if !@_animation_sprites.nil?
      for sprite in @_animation_sprites
        sprite.z=@z
      end
    end
  end
  
  alias klein_update_fix update
  def update
    update_z
    klein_update_fix
  end
  
  alias klein_update_animation_fix update_animation
  def update_animation
    update_z
    klein_update_animation_fix
  end
  
  def animation_set_sprites(sprites, cell_data, position)
    update_z
    for i in 0..15
      sprite = sprites[i]
      pattern = cell_data[i, 0]
      if sprite == nil || pattern == nil || pattern == -1
        sprite.visible = false if sprite != nil
        next
      end
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)
      if position == 3
        if self.viewport != nil
          sprite.x = self.viewport.rect.width / 2
          sprite.y = self.viewport.rect.height - 160
        else
          sprite.x = 320
          sprite.y = 240
        end
      else
        sprite.x = self.x - self.ox + self.src_rect.width / 2
        sprite.y = self.y - self.oy + self.src_rect.height / 2
        sprite.y -= self.src_rect.height / 4 if position == 0
        sprite.y += self.src_rect.height / 4 if position == 2
      end
      sprite.x += cell_data[i, 1]
      sprite.y += cell_data[i, 2]
      sprite.z = @z
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.angle = cell_data[i, 4]
      sprite.mirror = (cell_data[i, 5] == 1)
      sprite.tone=self.tone
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
end

class Sprite_Character
  def real_y
    return @character.real_y
  end
end