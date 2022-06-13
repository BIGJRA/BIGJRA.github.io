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
    update
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
      ret.blt(0,y,bitmap,Rect.new(0,y,ret.width,cy)) if cy>=0
      ret.blt(0,y+cy,bitmap,Rect.new(0,y+cy,ret.width,2),170) if cy>=0    
      ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85) if cy+2>=0    
    end
    return ret
  end

  def self.pbBushDepthTile(bitmap,depth)
    ret=Bitmap.new(bitmap.width,bitmap.height)
    charheight=ret.height
    cy=charheight-depth-2
    y=charheight
    ret.blt(0,y,bitmap,Rect.new(0,y,ret.width,cy)) if cy>=0
    ret.blt(0,y+cy,bitmap,Rect.new(0,y+cy,ret.width,2),170) if cy>=0    
    ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85) if cy+2>=0    
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
    super
    currentbushdepth = bush_depth
    if @tile_id != @character.tile_id || @character_name != @character.character_name || @character_hue != @character.character_hue ||  @oldbushdepth != currentbushdepth
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
        self.ox = Game_Map::TILEWIDTH/2
        self.oy = Game_Map::TILEHEIGHT
      else
        @charbitmap.dispose if @charbitmap
        @charbitmap = AnimatedBitmap.new( "Graphics/Characters/"+@character.character_name, @character.character_hue)
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
    if @character.bush_depth==0
      self.bitmap=@charbitmapAnimated ? @charbitmap.bitmap : @charbitmap
    else
      if !@bushbitmap
        @bushbitmap=BushBitmap.new(@charbitmap,@tile_id >= 384,@character.bush_depth)
      end
      self.bitmap=@bushbitmap.bitmap
    end
    self.visible = !@character.transparent
    if @tile_id == 0
      if @character==$game_player 
        if $PokemonGlobal.surfing || $PokemonGlobal.diving || $PokemonGlobal.lavasurfing
          bob=((Graphics.frame_count%60)/15).floor
          self.oy=(bob>=2) ? @ch-16-2 : @ch-16
        end
      end
      if @character==$game_player && !$PokemonGlobal.fishing && ($PokemonGlobal.surfing || $PokemonGlobal.diving || $PokemonGlobal.lavasurfing)
        sx = bob * @cw
        sy = (@character.direction - 2) / 2 * @ch
        self.src_rect.set(sx, sy, @cw, @ch)
      else
        sx = @character.pattern * @cw
        sy = (@character.direction - 2) / 2 * @ch
        self.src_rect.set(sx, sy, @cw, @ch)
      end
    end
    if self.visible
      if $PokemonSystem.tilemap==0 || (@character.is_a?(Game_Event) && @character.name=="RegularTone")
        self.tone.set(0,0,0,0)
      else
        pbDayNightTint(self)
      end
    end
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
#    self.zoom_x = Game_Map::TILEWIDTH/32.0
#    self.zoom_y = Game_Map::TILEHEIGHT/32.0
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
#    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end