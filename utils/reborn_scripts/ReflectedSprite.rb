class ReflectedSprite
  attr_accessor :visible
  attr_accessor :event

  def initialize(sprite,event,viewport=nil)
    @rsprite=sprite
    @sprite=nil
    @event=event
    @disposed=false
    @viewport=viewport
    update
  end

  def dispose
    if !@disposed
      @sprite.dispose if @sprite
      @sprite=nil
      @disposed=true
    end
  end

  def disposed?
    @disposed
  end

  def update
    return if disposed?
    currentY=@event.real_y.to_i/128
    limit=@rsprite.src_rect.height
    rect_height = limit
    shouldShow=false
# Clipping at Y
    i=0
    while i<rect_height+32
      nextY=currentY+1+(i>>5)
      terrain_tag = @event.map.terrain_tag(@event.x,nextY)
      if terrain_tag!=PBTerrain::StillWater && #The terrain types that will have reflections in them       
        terrain_tag!=16   && 
        terrain_tag!=18   && 
        terrain_tag!=19       
        limit= ((nextY * 128)-@event.map.display_y+3).to_i/4
        limit-=@rsprite.y
        break
      else
        shouldShow=true
      end        
      i+=Game_Map::TILEHEIGHT
    end
    shouldShow=false if !visible
    if limit>0 && shouldShow
      # Just-in-time creation of sprite
      if !@sprite
        @sprite=Sprite.new(@viewport)
      end
    else
      # Just-in-time disposal of sprite 
      if @sprite
        @sprite.dispose
        @sprite=nil
      end
      return
    end
    if @sprite
      x=@rsprite.x-@rsprite.ox
      y=@rsprite.y-@rsprite.oy
      terrain_tag = @event.map.terrain_tag(@event.x,@event.y)
      if terrain_tag ==PBTerrain::StillWater ||
         terrain_tag ==PBTerrain::DeepWater
        y-=55; limit+=30  # Arbitrary shift reflection up if on still water
      end
      if @rsprite.character.character_name[/offset/]
        y-=32; limit+=16   # Counter sprites with offset               
      end
      width=@rsprite.src_rect.width
      height=rect_height
      frame=(Graphics.frame_count%40)/10
  #    @sprite.x=x+width/2
  #    @sprite.y=y+height+height/2
  #    @sprite.ox=width/2
  #    @sprite.oy=height/2
  #    @sprite.angle=180.0
  #    @sprite.z=@rsprite.z-1 # below the player
  #    @sprite.zoom_x=@rsprite.zoom_x
  #    @sprite.zoom_y=@rsprite.zoom_y 
      @sprite.x=@rsprite.x
      @sprite.y=@rsprite.y-height/6
      @sprite.ox=@rsprite.ox
      @sprite.oy=@rsprite.oy
      @sprite.angle=180      
      @sprite.z=0 #Don't reflect in cliffs and stuff
      @sprite.zoom_x=@rsprite.zoom_x
      @sprite.zoom_y=@rsprite.zoom_y   
      if @event.map.terrain_tag(@event.x,(@event.y+1))!=19
        if frame==1
          @sprite.zoom_x*=1.05    
        elsif frame==2
          @sprite.zoom_x*=1.1    
        elsif frame==3
          @sprite.zoom_x*=1.05   
        end
      end  
      @sprite.mirror=true
      @sprite.bitmap=@rsprite.bitmap
      @sprite.tone=@rsprite.tone
      @sprite.color=Color.new(248,248,248,96)
      @sprite.opacity=@rsprite.opacity*3/4
      @sprite.src_rect=@rsprite.src_rect
      if limit<rect_height
        diff=rect_height-limit
        @sprite.src_rect.y+=diff
        @sprite.src_rect.height=limit
        @sprite.y-=diff
      end
    end
  end
end