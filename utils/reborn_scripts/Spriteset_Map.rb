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

    #Viewport
    @viewport1 = Viewport.new(0, 0, Graphics.width,Graphics.height) # Panorama, map, events, player, fog
    @viewport1a = Viewport.new(0, 0, Graphics.width,Graphics.height) # Weather
    @viewport1b = Viewport.new(0, 0, Graphics.width,Graphics.height) # HP Hud
    @viewport2 = Viewport.new(0, 0, Graphics.width,Graphics.height) # "Show Picture" event command pictures
    @viewport3 = Viewport.new(0, 0, Graphics.width,Graphics.height) # Flashing
    @viewport1a.z = 100
    @viewport1b.z = 99998
    @viewport2.z = 200
    @viewport3.z = 500

    #Tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.tileset = pbGetTileset(@map.tileset_name)
    for i in 0...7
      autotile_name = @map.autotile_names[i]
      next if autotile_name == ""
      @tilemap.autotiles[i] = pbGetAutotile(autotile_name)
    end
    @tilemap.map_data = @map.data
    @tilemap.priorities = @map.priorities

    #Panorama and fog
    @panorama = AnimatedPlane.new(@viewport1)
    @panorama.z = -1000
    @fog = AnimatedPlane.new(@viewport1)
    @fog.z = 3000

    #Sprites
    @reflectedSprites=[]
    @character_sprites = {}
    for i in @map.events.keys.sort
      next if !@map.events[i].graphical?
      sprite = Sprite_Character.new(@viewport1, @map.events[i])
      @character_sprites[i] = sprite
      if $game_map.map_id == 506
        @reflectedSprites.push(ReflectedSprite.new(sprite,@map.events[i],@viewport1))
      end
    end
    playersprite=Sprite_Character.new(@viewport1, $game_player)
    @playersprite=playersprite
    @reflectedSprites.push(ReflectedSprite.new(playersprite,$game_player,@viewport1))
    @character_sprites[$game_player.id] = playersprite

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
    for sprite in @character_sprites.values
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
    test_y = object.real_y - @map.display_y
    return false if test_y <= -512
    return false if test_y >= Graphics.height*4+512
    test_x = object.real_x - @map.display_x
    return false if test_x <= -512
    return false if test_x >= Graphics.width*4+512
    return true
  end

  def update
    for i in @map.events.keys
      if !@character_sprites.include?(i) && @map.events[i].graphical?
        sprite = Sprite_Character.new(@viewport1, @map.events[i])
        @character_sprites[i] = sprite
        if $game_map.map_id == 506
          @reflectedSprites.push(ReflectedSprite.new(sprite,@map.events[i],@viewport1))
        end
      end
    end
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
    @viewport1.rect.set(0,0,Graphics.width,Graphics.height)
    @viewport1.ox=0
    @viewport1.oy=0
    @viewport1.ox += $game_screen.shake
    @tilemap.update
    @panorama.ox = @map.display_x / 8
    @panorama.oy = @map.display_y / 8
    fog_zoom = @map.fog_zoom / 100.0
    @fog.zoom_x = fog_zoom
    @fog.zoom_y = fog_zoom
    @fog.opacity = @map.fog_opacity
    @fog.blend_type = @map.fog_blend_type
    @fog.ox = @map.display_x / 4 + @map.fog_ox
    @fog.oy = @map.display_y / 4 + @map.fog_oy
    @fog.tone = @map.fog_tone
    @panorama.update
    @fog.update
    for sprite in @character_sprites.values
      sprite.update
    end
    for sprite in @reflectedSprites
      sprite.visible=true
      sprite.visible=(@map==$game_map) if sprite.event==$game_player
      sprite.update if sprite.visible
    end
    # Avoids overlap effect of player sprites if player is near edge of
    # a connected map
    @playersprite.visible=@playersprite.visible && (
       self.map==$game_map || $game_player.x<=0 || $game_player.y<=0 ||
       ($game_map && ($game_player.x>=$game_map.width ||
       $game_player.y>=$game_map.height)))
    if self.map!=$game_map
      if @weather.max>0
        @weather.max-=2 
      elsif @weather.max<0
        @weather.max=0
      else
        @weather.type = 0 
        @weather.ox = 0 
        @weather.oy = 0
      end
    else
      @weather.type = $game_screen.weather_type
      @weather.max = $game_screen.weather_max
      @weather.ox = @map.display_x / 4
      @weather.oy = @map.display_y / 4
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
    @viewport1b.update
    @viewport3.update
  end
end