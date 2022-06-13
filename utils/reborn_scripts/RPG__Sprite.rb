class SpriteAnimation
  @@_animations = []
  @@_reference_count = {}

  def initialize(sprite)
    @sprite=sprite
  end

  %w[
     x y ox oy viewport flash src_rect opacity tone
  ].each_with_index do |s, i|
  eval <<-__END__

  def #{s}(*arg)
    @sprite.#{s}(*arg)
  end

  __END__
  end

  def self.clear
    @@_animations.clear
  end

  def dispose
    dispose_animation
    dispose_loop_animation
  end

  def animation(animation, hit)
    dispose_animation
    @_animation = animation
    return if @_animation == nil
    @_animation_hit = hit
    @_animation_duration = @_animation.frame_max
    animation_name = @_animation.animation_name
    animation_hue = @_animation.animation_hue
    bitmap = pbGetAnimation(animation_name, animation_hue)
    if @@_reference_count.include?(bitmap)
      @@_reference_count[bitmap] += 1
    else
      @@_reference_count[bitmap] = 1
    end
    @_animation_sprites = []
    if @_animation.position != 3 || !@@_animations.include?(animation)
      for i in 0..15
        sprite = ::Sprite.new(self.viewport)
        sprite.bitmap = bitmap
        sprite.visible = false
        @_animation_sprites.push(sprite)
      end
      unless @@_animations.include?(animation)
        @@_animations.push(animation)
      end
    end
    update_animation
  end

  def loop_animation(animation)
    return if animation == @_loop_animation
    dispose_loop_animation
    @_loop_animation = animation
    return if @_loop_animation == nil
    @_loop_animation_index = 0
    animation_name = @_loop_animation.animation_name
    animation_hue = @_loop_animation.animation_hue
    bitmap = pbGetAnimation(animation_name, animation_hue)
    if @@_reference_count.include?(bitmap)
      @@_reference_count[bitmap] += 1
    else
      @@_reference_count[bitmap] = 1
    end
    @_loop_animation_sprites = []
    for i in 0..15
      sprite = ::Sprite.new(self.viewport)
      sprite.bitmap = bitmap
      sprite.visible = false
      @_loop_animation_sprites.push(sprite)
    end
    update_loop_animation
  end

  def dispose_animation
    if @_animation_sprites != nil
      sprite = @_animation_sprites[0]
      if sprite != nil
        @@_reference_count[sprite.bitmap] -= 1
        if @@_reference_count[sprite.bitmap] == 0
          sprite.bitmap.dispose
        end
      end
      for sprite in @_animation_sprites
        sprite.dispose
      end
      @_animation_sprites = nil
      @_animation = nil
    end
  end

  def dispose_loop_animation
    if @_loop_animation_sprites != nil
      sprite = @_loop_animation_sprites[0]
      if sprite != nil
        @@_reference_count[sprite.bitmap] -= 1
        if @@_reference_count[sprite.bitmap] == 0
          sprite.bitmap.dispose
        end
      end
      for sprite in @_loop_animation_sprites
        sprite.dispose
      end
      @_loop_animation_sprites = nil
      @_loop_animation = nil
    end
  end

  def active?
    @_loop_animation_sprites != nil ||
    @_animation_sprites != nil
  end

  def effect?
    @_animation_duration > 0
  end

  def update
    if @_animation != nil && (Graphics.frame_count % 2 == 0)
      @_animation_duration -= 1
      update_animation
    end
    if @_loop_animation != nil && (Graphics.frame_count % 2 == 0)
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

  def update_loop_animation
    frame_index = @_loop_animation_index
    cell_data = @_loop_animation.frames[frame_index].cell_data
    position = @_loop_animation.position
    animation_set_sprites(@_loop_animation_sprites, cell_data, position)
    for timing in @_loop_animation.timings
      if timing.frame == frame_index
        animation_process_timing(timing, true)
      end
    end
  end

  def animation_set_sprites(sprites, cell_data, position)
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
      sprite.z = 2000
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

  def animation_process_timing(timing, hit)
    if (timing.condition == 0) ||
       (timing.condition == 1 && hit == true) ||
       (timing.condition == 2 && hit == false)
      if timing.se.name != ""
        se = timing.se
        pbSEPlay(se)
      end
      case timing.flash_scope
        when 1
          self.flash(timing.flash_color, timing.flash_duration * 2)
        when 2
          if self.viewport != nil
            self.viewport.flash(timing.flash_color, timing.flash_duration * 2)
          end
        when 3
          self.flash(nil, timing.flash_duration * 2)
      end
    end
  end

  def x=(x)
    sx = x - self.x
    if sx != 0
      if @_animation_sprites != nil
        for i in 0..15
          @_animation_sprites[i].x += sx
        end
      end
      if @_loop_animation_sprites != nil
        for i in 0..15
          @_loop_animation_sprites[i].x += sx
        end
      end
    end
  end

  def y=(y)
    sy = y - self.y
    if sy != 0
      if @_animation_sprites != nil
        for i in 0..15
          @_animation_sprites[i].y += sy
        end
      end
      if @_loop_animation_sprites != nil
        for i in 0..15
          @_loop_animation_sprites[i].y += sy
        end
      end
    end
  end
end

class Sprite_Timer
  def initialize(viewport=nil)
    @viewport=viewport
    @timer=nil
    @total_sec=nil
    @disposed=false
  end

  def dispose
    @timer.dispose if @timer
    @timer=nil
    @disposed=true
  end

  def disposed?
    @disposed
  end

  def update
    return if disposed?
    if $game_system.timer_working
      if !@timer
        @timer=Window_AdvancedTextPokemon.newWithSize("",Graphics.width-120,0,120,64)
        @timer.width=@timer.borderX+96
        @timer.x=Graphics.width-@timer.width
        @timer.viewport=@viewport
        @timer.z=99998
      end
      curtime=$game_system.timer / Graphics.frame_rate
      curtime=0 if curtime<0
      if curtime != @total_sec
        # Calculate total number of seconds
        @total_sec = curtime
        # Make a string for displaying the timer
        min = @total_sec / 60
        sec = @total_sec % 60
        @timer.text = _ISPRINTF("<ac>{1:02d}:{2:02d}", min, sec)
      end
      @timer.update
    else
      @timer.visible=false if @timer
    end
  end
end

class Sprite_Picture
  def initialize(viewport, picture)
    @viewport = viewport
    @picture = picture
    @sprite = nil
    update
  end

  def dispose
    @sprite.dispose if @sprite
  end
  
  def sprite
    return @sprite
  end

  def update
    @sprite.update if @sprite
    # If picture file name is different from current one
    if @picture_name != @picture.name
      # Remember file name to instance variables
      @picture_name = @picture.name
      # If file name is not empty
      if @picture_name != ""
        # Get picture graphic
        @sprite=IconSprite.new(0,0,@viewport) if !@sprite
        @sprite.setBitmap("Graphics/Pictures/"+@picture_name)
      else    #adding this here to avoid an extra conditional
        if @sprite
        @sprite.dispose if @sprite
        @sprite=nil
      end
      return
      end
    end
    # If file name is empty
    if @picture_name == ""
      # Set sprite to invisible
      if @sprite
        @sprite.dispose if @sprite
        @sprite=nil
      end
      return
    end
    # Set sprite to visible
    @sprite.visible = true
    # Set transfer starting point
    if @picture.origin == 0
      @sprite.ox = 0
      @sprite.oy = 0
    else
      @sprite.ox = @sprite.bitmap.width / 2
      @sprite.oy = @sprite.bitmap.height / 2
    end
    # Set sprite coordinates
    @sprite.x = @picture.x
    @sprite.y = @picture.y
    @sprite.z = @picture.number
    # Set zoom rate, opacity level, and blend method
    @sprite.zoom_x = @picture.zoom_x / 100.0
    @sprite.zoom_y = @picture.zoom_y / 100.0
    @sprite.opacity = @picture.opacity
    @sprite.blend_type = @picture.blend_type
    # Set rotation angle and color tone
    @sprite.angle = @picture.angle
    @sprite.tone = @picture.tone
  end
end

module RPG
  class Sprite < ::Sprite
    def initialize(viewport = nil)
      super(viewport)
      @_whiten_duration = 0
      @_appear_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
      @_damage_duration = 0
      @_animation_duration = 0
      @_blink = false
      @animations=[]
      @loopAnimations=[]
    end

    def dispose
      dispose_damage
      dispose_animation
      dispose_loop_animation
      super
    end

    def whiten
      self.blend_type = 0
      self.color.set(255, 255, 255, 128)
      self.opacity = 255
      @_whiten_duration = 16
      @_appear_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
    end

    def appear
      self.blend_type = 0
      self.color.set(0, 0, 0, 0)
      self.opacity = 0
      @_appear_duration = 16
      @_whiten_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
    end

    def escape
      self.blend_type = 0
      self.color.set(0, 0, 0, 0)
      self.opacity = 255
      @_escape_duration = 32
      @_whiten_duration = 0
      @_appear_duration = 0
      @_collapse_duration = 0
    end

    def collapse
      self.blend_type = 1
      self.color.set(255, 64, 64, 255)
      self.opacity = 255
      @_collapse_duration = 48
      @_whiten_duration = 0
      @_appear_duration = 0
      @_escape_duration = 0
    end

    def damage(value, critical)
      dispose_damage
      if value.is_a?(Numeric)
        damage_string = value.abs.to_s
      else
        damage_string = value.to_s
      end
      bitmap = Bitmap.new(160, 48)
      bitmap.font.name = "Arial Black"
      bitmap.font.size = 32
      bitmap.font.color.set(0, 0, 0)
      bitmap.draw_text(-1, 12-1, 160, 36, damage_string, 1)
      bitmap.draw_text(+1, 12-1, 160, 36, damage_string, 1)
      bitmap.draw_text(-1, 12+1, 160, 36, damage_string, 1)
      bitmap.draw_text(+1, 12+1, 160, 36, damage_string, 1)
      if value.is_a?(Numeric) && value < 0
        bitmap.font.color.set(176, 255, 144)
      else
        bitmap.font.color.set(255, 255, 255)
      end
      bitmap.draw_text(0, 12, 160, 36, damage_string, 1)
      if critical
        bitmap.font.size = 20
        bitmap.font.color.set(0, 0, 0)
        bitmap.draw_text(-1, -1, 160, 20, "CRITICAL", 1)
        bitmap.draw_text(+1, -1, 160, 20, "CRITICAL", 1)
        bitmap.draw_text(-1, +1, 160, 20, "CRITICAL", 1)
        bitmap.draw_text(+1, +1, 160, 20, "CRITICAL", 1)
        bitmap.font.color.set(255, 255, 255)
        bitmap.draw_text(0, 0, 160, 20, "CRITICAL", 1)
      end
      @_damage_sprite = ::Sprite.new(self.viewport)
      @_damage_sprite.bitmap = bitmap
      @_damage_sprite.ox = 80
      @_damage_sprite.oy = 20
      @_damage_sprite.x = self.x
      @_damage_sprite.y = self.y - self.oy / 2
      @_damage_sprite.z = 3000
      @_damage_duration = 40
    end

    def pushAnimation(array,anim)
      for i in 0...array.length
        if !array[i] || !array[i].active?
          array[i]=anim
          return
        end
      end
      array.push(anim)
    end

    def animation(animation, hit)
      anim=SpriteAnimation.new(self)
      anim.animation(animation,hit)
      pushAnimation(@animations,anim)
    end

    def loop_animation(animation)
      anim=SpriteAnimation.new(self)
      anim.loop_animation(animation)
      pushAnimation(@loopAnimations,anim)
    end

    def dispose_damage
      if @_damage_sprite != nil
        @_damage_sprite.bitmap.dispose
        @_damage_sprite.dispose
        @_damage_sprite = nil
        @_damage_duration = 0
      end
    end

    def dispose_animation
      for a in @animations
        a.dispose_animation if a
      end
      @animations.clear
    end

    def dispose_loop_animation
      for a in @loopAnimations
        a.dispose_loop_animation if a
      end
      @loopAnimations.clear
    end

    def blink_on
      unless @_blink
        @_blink = true
        @_blink_count = 0
      end
    end

    def blink_off
      if @_blink
        @_blink = false
        self.color.set(0, 0, 0, 0)
      end
    end

    def blink?
      @_blink
    end

    def effect?
      return true if @_whiten_duration > 0 ||
        @_appear_duration > 0 ||
        @_escape_duration > 0 ||
        @_collapse_duration > 0 ||
        @_damage_duration > 0
      for a in @animations
        return true if a.effect?
      end
      return false
    end

    def update
      super
      if @_whiten_duration > 0
        @_whiten_duration -= 1
        self.color.alpha = 128 - (16 - @_whiten_duration) * 10
      end
      if @_appear_duration > 0
        @_appear_duration -= 1
        self.opacity = (16 - @_appear_duration) * 16
      end
      if @_escape_duration > 0
        @_escape_duration -= 1
        self.opacity = 256 - (32 - @_escape_duration) * 10
      end
      if @_collapse_duration > 0
        @_collapse_duration -= 1
        self.opacity = 256 - (48 - @_collapse_duration) * 6
      end
      if @_damage_duration > 0
        @_damage_duration -= 1
        case @_damage_duration
        when 38..39
          @_damage_sprite.y -= 4
        when 36..37
          @_damage_sprite.y -= 2
        when 34..35
          @_damage_sprite.y += 2
        when 28..33
          @_damage_sprite.y += 4
        end
        @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32
        if @_damage_duration == 0
          dispose_damage
        end
      end
      for a in @animations
        a.update
      end
      for a in @loopAnimations
        a.update
      end
      if @_blink
        @_blink_count = (@_blink_count + 1) % 32
        if @_blink_count < 16
          alpha = (16 - @_blink_count) * 6
        else
          alpha = (@_blink_count - 16) * 6
        end
        self.color.set(255, 255, 255, alpha)
      end
      SpriteAnimation.clear
    end

    def update_animation
      for a in @animations
        a.update_animation if a && a.active?
      end
    end

    def update_loop_animation
      for a in @loopAnimations
        a.update_loop_animation if a && a.active?
      end
    end

    def x=(x)
      sx = x - self.x
      for a in @animations
        a.x=x
      end
      for a in @loopAnimations
        a.x=x
      end
      super
    end

    def y=(y)
      sy = y - self.y
      for a in @animations
        a.x=x
      end
      for a in @loopAnimations
        a.x=x
      end
      super
    end
  end
end

class BushBitmap
  def initialize(bitmap,isTile,depth)
    @bitmaps=[]
    @bitmap=bitmap
    @isTile=isTile
    @isBitmap=@bitmap.is_a?(Bitmap)
    @depth=depth
  end

  def dispose
    for b in @bitmaps
      b.dispose if b
    end
  end

  def bitmap
    thisBitmap=@isBitmap ? @bitmap : @bitmap.bitmap
    current=@isBitmap ? 0 : @bitmap.currentIndex
    if !@bitmaps[current]
      if @isTile
        @bitmaps[current]=Sprite_Character.pbBushDepthTile(thisBitmap,@depth)
      else
        @bitmaps[current]=Sprite_Character.pbBushDepthBitmap(thisBitmap,@depth)
      end
    end
    return @bitmaps[current]
  end
end

class Sprite_Character < RPG::Sprite
  attr_accessor :character

  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    @oldbushdepth=0
    #update
  end

  def groundY
    return @character.screen_y_ground
  end

  def self.pbBushDepthBitmap(bitmap,depth)
    ret=Bitmap.new(bitmap.width,bitmap.height)
    charheight=ret.height/4
    for i in 0...4
      cy=charheight-depth-2
      y=i*charheight
      if cy>=0 
        ret.blt(0,y,bitmap,Rect.new(0,y,ret.width,cy)) 
        ret.blt(0,y+cy,bitmap,Rect.new(0,y+cy,ret.width,2),170) 
        ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85)
      elsif cy+2>=0
        ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85)
      end
    end
    return ret
  end

  def self.pbBushDepthTile(bitmap,depth)
    ret=Bitmap.new(bitmap.width,bitmap.height)
    charheight=ret.height
    cy=charheight-depth-2
    y=charheight
    if cy>=0 
      ret.blt(0,y,bitmap,Rect.new(0,y,ret.width,cy)) 
      ret.blt(0,y+cy,bitmap,Rect.new(0,y+cy,ret.width,2),170) 
      ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85)
    elsif cy+2>=0
      ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85)
    end
    return ret
  end

  def dispose
    @bushbitmap.dispose if @bushbitmap
    @bushbitmap=nil
    @charbitmap.dispose if @charbitmap
    @charbitmap=nil
    super
  end

  def update
    if !@character.graphicalNow?
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      self.visible = false
      #@charbitmap.dispose if @charbitmap
      return
    end
    super
    outdoor = $game_map.outdoor
    #splits into indoor/outdoor
    bush_depth = @character.bush_depth
    if @tile_id != @character.tile_id || @character_name != @character.character_name || @character_hue != @character.character_hue ||  @oldbushdepth != bush_depth
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      if @tile_id >= 384
        @charbitmap.dispose if @charbitmap
        @charbitmap = pbGetTileBitmap(@character.map.tileset_name,
          @tile_id, @character.character_hue)
        @charbitmapAnimated=false
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap=nil
        @cw = 32  # added
        @ch = 32  # added
        self.src_rect.set(0, 0, 32, 32)
        self.ox = 16 #Game_Map::TILEWIDTH/2
        self.oy = 32 #Game_Map::TILEHEIGHT
      else
        @charbitmap.dispose if @charbitmap
        @charbitmap = AnimatedBitmap.new( "Graphics/Characters/"+@character.character_name, @character.character_hue)
        RPG::Cache.retain('Graphics/Characters/', @character_name, @character_hue) if @character == $game_player
        @charbitmapAnimated=true
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap=nil
        @cw = @charbitmap.width / 4
        @ch = @charbitmap.height / 4
        self.ox = @cw / 2
        if @character_name[/offset/]
          self.oy = @ch - 16
        else
          self.oy = @ch
        end
      end
    end
    @charbitmap.update if @charbitmapAnimated
    if bush_depth==0
      self.bitmap=@charbitmapAnimated ? @charbitmap.bitmap : @charbitmap
    else
      if !@bushbitmap
        @bushbitmap=BushBitmap.new(@charbitmap,@tile_id >= 384,bush_depth)
      end
      self.bitmap=@bushbitmap.bitmap
    end
    self.visible = !@character.transparent
    if @tile_id == 0
      if (@character==$game_player) && ($PokemonGlobal.surfing || $PokemonGlobal.diving)
        self.oy = @ch - 16
        if !$PokemonGlobal.fishing
          sx = ((Graphics.frame_count%60)/15).floor * @cw
        else
          sx = @character.pattern * @cw
        end
      else
        sx = @character.pattern * @cw
      end
      sy = (@character.direction - 2) / 2 * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    if outdoor == true
      if self.visible
        if @character.is_a?(Game_Event) && @character.name=="RegularTone"
          self.tone.set(0,0,0,0)
        else
          pbDayNightTint2(self,outdoor)
        end
      end
    end
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    if @character.animation_id != 0
      animation = $cache.RXanimations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end