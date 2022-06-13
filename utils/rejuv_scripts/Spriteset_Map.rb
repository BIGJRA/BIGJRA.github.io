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
    currentY=@event.real_y.to_i/(4*Game_Map::TILEHEIGHT)
    limit=@rsprite.src_rect.height
    shouldShow=false
# Clipping at Y
    i=0
    while i<@rsprite.src_rect.height+Game_Map::TILEHEIGHT
      nextY=currentY+1+(i>>5)
      map_tag = @event.map.terrain_tag(@event.x,nextY)
      if map_tag!=PBTerrain::StillWater && #The terrain types that will have reflections in them
        map_tag!=16 && map_tag!=18
        limit= ((nextY * (4*Game_Map::TILEHEIGHT))-@event.map.display_y+3).to_i/4
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
      if @event.map.terrain_tag(@event.x,@event.y)==PBTerrain::StillWater ||
         @event.map.terrain_tag(@event.x,@event.y)==PBTerrain::DeepWater
        y-=55; limit+=30  # Arbitrary shift reflection up if on still water
      end
      if @rsprite.character.character_name[/offset/]
        y-=32; limit+=16   # Counter sprites with offset               
      end
      width=@rsprite.src_rect.width
      height=@rsprite.src_rect.height
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
      if limit<@sprite.src_rect.height
        diff=@sprite.src_rect.height-limit
        @sprite.src_rect.y+=diff
        @sprite.src_rect.height=limit
        @sprite.y-=diff
      end
    end
  end
end



class ClippableSprite < Sprite_Character
  def initialize(viewport,event,tilemap)
    @tilemap=tilemap
    @_src_rect=Rect.new(0,0,0,0)
    super(viewport,event)
  end

  def update
    super
    @_src_rect=self.src_rect
    tmright=@tilemap.map_data.xsize*Game_Map::TILEWIDTH-@tilemap.ox
    echoln("x=#{self.x},ox=#{self.ox},tmright=#{tmright},tmox=#{@tilemap.ox}")
    if @tilemap.ox-self.ox<-self.x
      # clipped on left
      diff=(-self.x)-(@tilemap.ox-self.ox)
      self.src_rect=Rect.new(@_src_rect.x+diff,@_src_rect.y,
         @_src_rect.width-diff,@_src_rect.height)
      echoln("clipped out left: #{diff} #{@tilemap.ox-self.ox} #{self.x}")
    elsif tmright-self.ox<self.x
      # clipped on right
      diff=(self.x)-(tmright-self.ox)
      self.src_rect=Rect.new(@_src_rect.x,@_src_rect.y,
         @_src_rect.width-diff,@_src_rect.height)
      echoln("clipped out right: #{diff} #{tmright+self.ox} #{self.x}")
    else
      echoln("-not- clipped out left: #{diff} #{@tilemap.ox-self.ox} #{self.x}")
    end
  end
end



class Spriteset_Map
  attr_reader :map
  attr_reader :viewport1

  def initialize(map=nil)
    @map=map ? map : $game_map
    @viewport1 = Viewport.new(0, 0, Graphics.width,Graphics.height) # Panorama, map, events, player, fog
    @viewport1a = Viewport.new(0, 0, Graphics.width,Graphics.height) # Weather
    @viewport2 = Viewport.new(0, 0, Graphics.width,Graphics.height) # "Show Picture" event command pictures
    @viewport3 = Viewport.new(0, 0, Graphics.width,Graphics.height) # Flashing
    @viewport1a.z = 100
    @viewport2.z = 200
    @viewport3.z = 500
    @tilemap = TilemapLoader.new(@viewport1)
    @tilemap.tileset = pbGetTileset(@map.tileset_name)
    for i in 0...7
      autotile_name = @map.autotile_names[i]
      next if autotile_name == ""
      @tilemap.autotiles[i] = pbGetAutotile(autotile_name)
    end
    @tilemap.map_data = @map.data
    @tilemap.priorities = @map.priorities
    @panorama = AnimatedPlane.new(@viewport1)
    @panorama.z = -1000
    @fog = AnimatedPlane.new(@viewport1)
    @fog.z = 3000
    @reflectedSprites=[]
    @character_sprites = []
    for i in @map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, @map.events[i])
      @character_sprites.push(sprite)
#### Cass speedup ####
#      if !@map.events[i].name[/noreflect/]
#        @reflectedSprites.push(ReflectedSprite.new(sprite,@map.events[i],@viewport1))
#      end
## Incorrect Fishtake
#      map_tag = @map.events[i].terrain_tag
#      if map_tag==PBTerrain::Puddle || map_tag==16 || map_tag==18
#        @reflectedSprites.push(ReflectedSprite.new(sprite,@map.events[i],@viewport1))
#      end
    end
    playersprite=Sprite_Character.new(@viewport1, $game_player)
    @playersprite=playersprite
    @reflectedSprites.push(ReflectedSprite.new(playersprite,$game_player,@viewport1))
    @character_sprites.push(playersprite)
    @weather = RPG::Weather.new(@viewport1a)
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,$game_screen.pictures[i]))
    end
    @timer_sprite = Sprite_Timer.new
    Kernel.pbOnSpritesetCreate(self,@viewport1)
    update
  end

  def dispose
    @tilemap.tileset.dispose
    for i in 0...7
      @tilemap.autotiles[i].dispose if @tilemap.autotiles[i]
    end
    @tilemap.dispose
    @panorama.dispose
    @fog.dispose
    for sprite in @character_sprites
      sprite.dispose
    end
    for sprite in @reflectedSprites
      sprite.dispose
    end
    @weather.dispose
    for sprite in @picture_sprites
      sprite.dispose
    end
    @timer_sprite.dispose
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    @tilemap=nil
    @panorama=nil
    @fog=nil
    @character_sprites.clear
    @reflectedSprites.clear
    @weather=nil
    @picture_sprites.clear
    @viewport1=nil
    @viewport2=nil
    @viewport3=nil
    @timer_sprite=nil
  end

  def in_range?(object)
    return true if $PokemonSystem.tilemap==2
    return false if object.real_x <= @map.display_x - 512
    return false if object.real_x >= @map.display_x + Graphics.width*4 + 512
    return false if object.real_y <= @map.display_y - 512
    return false if object.real_y >= @map.display_y + Graphics.height*4 + 512
    return true
  end

  def update
    if @panorama_name != @map.panorama_name || @panorama_hue != @map.panorama_hue
      @panorama_name = @map.panorama_name
      @panorama_hue = @map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.setPanorama(nil)
      end
      if @panorama_name != ""
        @panorama.setPanorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    if @fog_name != @map.fog_name || @fog_hue != @map.fog_hue
      @fog_name = @map.fog_name
      @fog_hue = @map.fog_hue
      if @fog.bitmap != nil
        @fog.setFog(nil)
      end
      if @fog_name != ""
        @fog.setFog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    tmox = @map.display_x.to_i / 4
    tmoy = @map.display_y.to_i / 4
    @tilemap.ox=tmox
    @tilemap.oy=tmoy
    if $PokemonSystem.tilemap==0
      # Original Map View only, to prevent wrapping
      @viewport1.rect.x=[-tmox,0].max
      @viewport1.rect.y=[-tmoy,0].max
      @viewport1.rect.width=
         [@tilemap.map_data.xsize*Game_Map::TILEWIDTH-tmox,Graphics.width].min
      @viewport1.rect.height=
         [@tilemap.map_data.ysize*Game_Map::TILEHEIGHT-tmoy,Graphics.height].min
      @viewport1.ox=[-tmox,0].max
      @viewport1.oy=[-tmoy,0].max
    else
      @viewport1.rect.set(0,0,Graphics.width,Graphics.height)
      @viewport1.ox=0
      @viewport1.oy=0     
    end
    @viewport1.ox += $game_screen.shake
    @tilemap.update
    @panorama.ox = tmox / 2
    @panorama.oy = tmoy / 2
    @fog.zoom_x = @map.fog_zoom / 100.0
    @fog.zoom_y = @map.fog_zoom / 100.0
    @fog.opacity = @map.fog_opacity
    @fog.blend_type = @map.fog_blend_type
    @fog.ox = tmox + @map.fog_ox
    @fog.oy = tmoy + @map.fog_oy
    @fog.tone = @map.fog_tone
    @panorama.update
    @fog.update
    for sprite in @character_sprites
      sprite.update
    end
    for sprite in @reflectedSprites
      sprite.visible=true
      sprite.visible=(@map==$game_map) if sprite.event==$game_player
      sprite.update
    end
    # Avoids overlap effect of player sprites if player is near edge of
    # a connected map
    @playersprite.visible=@playersprite.visible && (self.map==$game_map || $game_player.x<=0 || $game_player.y<=0 || ($game_map && ($game_player.x>=$game_map.width || $game_player.y>=$game_map.height)))
    if self.map!=$game_map
      @weather.max-=2 if @weather.max>0
      @weather.max=0 if @weather.max<0
      @weather.type = 0 if @weather.max==0
      @weather.ox = 0 if @weather.max==0
      @weather.oy = 0 if @weather.max==0
    else
      @weather.type = $game_screen.weather_type
      @weather.max = $game_screen.weather_max
      @weather.ox = tmox
      @weather.oy = tmoy
    end
    @weather.update
    for sprite in @picture_sprites
      sprite.update
    end
    @timer_sprite.update
    @viewport1.tone = $game_screen.tone
    @viewport1a.ox += $game_screen.shake
    @viewport3.color = $game_screen.flash_color
    @viewport1.update
    @viewport1a.update
    @viewport3.update
  end
end