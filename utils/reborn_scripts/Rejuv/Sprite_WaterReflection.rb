class Sprite_Reflection
  attr_reader :visible
  attr_accessor :event

  def initialize(sprite,event,viewport=nil)
    @rsprite  = sprite
    @sprite   = nil
    @event    = event
    @height   = 0
    @fixedheight = false
    if @event && @event!=$game_player
      if @event.name[/Reflection\((\d+)\)/]
        @height = $~[1].to_i || 0
        @fixedheight = true
      end
    end
    @viewport = viewport
    @disposed = false
    update
  end

  def dispose
    if !@disposed
      @sprite.dispose if @sprite
      @sprite   = nil
      @disposed = true
    end
  end

  def disposed?
    @disposed
  end

  def visible=(value)
    @visible = value
    @sprite.visible = value if @sprite && !@sprite.disposed?
  end

  def update
    return if disposed?
    shouldShow = @rsprite.visible
    if !shouldShow
      # Just-in-time disposal of sprite 
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    # Just-in-time creation of sprite
    @sprite = Sprite.new(@viewport) if !@sprite
    if @sprite
      x = @rsprite.x-@rsprite.ox
      y = @rsprite.y-@rsprite.oy
      y -= 32 if @rsprite.character.character_name[/offset/]
      @height = $PokemonMap.bridge if !@fixedheight
      y += @height*16
      width  = @rsprite.src_rect.width
      height = @rsprite.src_rect.height
      @sprite.x        = x+width/2
      @sprite.y        = y+height+height/2
      @sprite.ox       = width/2
      @sprite.oy       = height/2-2   # Hard-coded 2 pixel shift up
      @sprite.oy       -= @rsprite.character.bob_height*2
      @sprite.z        = -50   # Still water is -100, map is 0 and above
      @sprite.zoom_x   = @rsprite.zoom_x
      @sprite.zoom_y   = @rsprite.zoom_y
      frame = (Graphics.frame_count%40)/10
      case frame
      when 1; @sprite.zoom_x *= 0.95
      when 3; @sprite.zoom_x *= 1.05
      else; @sprite.zoom_x *= 1.0
      end
      @sprite.angle    = 180.0
      @sprite.mirror   = true
      @sprite.bitmap   = @rsprite.bitmap
      @sprite.tone     = @rsprite.tone
      if @height>0
        @sprite.color   = Color.new(48,96,160,255) # Dark still water
        @sprite.opacity = @rsprite.opacity
        @sprite.visible = !ENABLESHADING # Can't time-tone a colored sprite
      else
        @sprite.color   = Color.new(224,224,224,96)
        @sprite.opacity = @rsprite.opacity*3/4
        @sprite.visible = true
        if (@event.map.terrain_tag(@event.x,(@event.y+1))==0)
          @sprite.visible = false
        end
      end
      @sprite.src_rect = @rsprite.src_rect
    end
  end
end