class Spriteset_Map
    attr_accessor :panorama2_name
    attr_accessor :panorama2

    alias _perry_spriteinitialize initialize
    def initialize(map=nil)
        _perry_spriteinitialize(map)
        @panorama2 = AnimatedPlane.new(@viewport1)
        @panorama2.z = -950
    end

    alias _perry_spriteupdate update
    def update
        _perry_spriteupdate
        if @map.panorama2_name && @panorama2_name != @map.panorama2_name && @panorama2
            @panorama2.setPanorama(@map.panorama2_name, 0)
            @panorama2_name= @map.panorama2_name
            Graphics.frame_reset
        end
        if @panorama2
            @panorama2.ox = ((@map.display_x + 960*2+64) / 8 * @panorama2.zoom_x)- DEFAULTSCREENWIDTH/2
            @panorama2.oy = ((@map.display_y + 704*2+64) / 8 * @panorama2.zoom_y)- DEFAULTSCREENHEIGHT/2
            @panorama2.update
        end
    end

    alias _perry_spritedispose dispose
    def dispose
        _perry_spritedispose
        @panorama2.dispose
        @panorama2=nil
    end

    def pbScrollDown(oldmapid,newmapid,hue=0)
        #Take picture of current map and make sprite of it
        mapsprite = pbMakeMapSprite(oldmapid,$game_player.x,$game_player.y)
        #set up zoom + panorama
        @panorama2.setPanorama("map#{newmapid}full.png", hue)
        zoomlevel = @panorama2.zoom_x = @panorama2.zoom_y = 0.5
        @panorama2.ox = ((@map.display_x + 960*2+64) / 8 *(2*@panorama2.zoom_x))- DEFAULTSCREENWIDTH/2
        @panorama2.oy = ((@map.display_y + 704*2+64) / 8 *(2*@panorama2.zoom_y))- DEFAULTSCREENHEIGHT/2
        @tilemap.visible=false 
        @panorama2.update; mapsprite.update; Graphics.frame_reset; Graphics.update; update
        duration = 200
        #zoom in
        for i in 0...duration
            @panorama.oy = (@map.display_y / 8 + 15.0*16/duration*(i+1)).round
            @panorama2.zoom_x+=zoomlevel/duration 
            @panorama2.zoom_y+=zoomlevel/duration
            @panorama2.ox = (((@map.display_x + 960.0*2+64) / 8 *(2*@panorama2.zoom_x)) - DEFAULTSCREENWIDTH/2).round
            @panorama2.oy = (((@map.display_y + 704.0*2+64) / 8 *(2*@panorama2.zoom_y)) - DEFAULTSCREENHEIGHT/2 + 480.0/duration*(i+1)).round
            if i < duration/4
                mapsprite.zoom_x+=2.0/duration
                mapsprite.zoom_y+=2.0/duration
                mapsprite.ox = ((-960.0-64) / 8 *(2*mapsprite.zoom_x))- DEFAULTSCREENWIDTH/2
                mapsprite.oy = ((-704.0-64) / 8 *(2*mapsprite.zoom_y))- DEFAULTSCREENHEIGHT/2 + 1600/duration*(i+1) - 10*32
                mapsprite.update
            end
            if i > duration/4 && mapsprite
                mapsprite.dispose 
                mapsprite=nil
            end
            @panorama2.update; Graphics.update
        end
    end

    def pbScrollUp(oldmapid, newmapid, hue=0)
        mapsprite = pbMakeMapSprite(newmapid,$game_player.x,$game_player.y-15)
        mapsprite.zoom_x = mapsprite.zoom_y = 1.5
        mapsprite.visible=false
        @panorama2.setPanorama("map#{oldmapid}full.png", hue)
        @panorama2.ox = ((@map.display_x + 960*2+64) / 8 *(2*@panorama2.zoom_x))- DEFAULTSCREENWIDTH/2
        @panorama2.oy = ((@map.display_y + 704*2+64) / 8 *(2*@panorama2.zoom_y))- DEFAULTSCREENHEIGHT/2
        @tilemap.visible=false 
        @panorama2.update; mapsprite.update; Graphics.frame_reset; Graphics.update; update
        zoomlevel = 0.5
        duration = 200
        #zoom out
        for i in 0...duration
            @panorama.oy = (@map.display_y / 8 - 15.0*16/duration*(i+1)).round
            @panorama2.zoom_x-=zoomlevel/duration 
            @panorama2.zoom_y-=zoomlevel/duration
            @panorama2.ox = (((@map.display_x + 960.0*2+64) / 8 *(2*@panorama2.zoom_x)) - DEFAULTSCREENWIDTH/2).round
            @panorama2.oy = (((@map.display_y + 704.0*2+64) / 8 *(2*@panorama2.zoom_y)) - DEFAULTSCREENHEIGHT/2 - 240.0/duration*(i+1)).round
            if i > duration*3/4
                mapsprite.visible = true 
                mapsprite.zoom_x-=2.0/duration
                mapsprite.zoom_y-=2.0/duration
                mapsprite.ox = ((-960.0-64) / 8 *(2*mapsprite.zoom_x))- DEFAULTSCREENWIDTH/2
                mapsprite.oy = ((-704.0-64) / 8 *(2*mapsprite.zoom_y))- DEFAULTSCREENHEIGHT/2 + 1600/duration*(duration-i+1) - 10*32 
                mapsprite.update
            end
            @panorama2.update; Graphics.update
        end
        mapsprite.dispose
    end

    def pbMakeMapSprite(mapid,xloc, yloc)
        mapbitmap = createPartMap(mapid,xloc,yloc)
        mapsprite = AnimatedPlane.new(@viewport1)
        mapsprite.bitmap = mapbitmap
        mapsprite.z = 1000
        return mapsprite
    end
end

def createPartMap(mapid, xloc=$game_player.x, yloc=$game_player.y)
    map=$cache.map_load(mapid)
    return BitmapWrapper.new(32,32) if !map
    bitmap=BitmapWrapper.new(Graphics.width,Graphics.height+10*32) #ten tiles extra
    black=Color.new(0,0,0)
    tilesets=$cache.RXtilesets ? $cache.RXtilesets : load_data("Data/tilesets.rxdata")
    tileset=tilesets[map.tileset_id]
    return bitmap if !tileset
    helper=TileDrawingHelper.fromTileset(tileset)
    for y in yloc-6..yloc+16
      next if y<0 || y>map.height
      for x in xloc-8..xloc+8
        next if x<0 || x>map.width
        next if y == yloc && (x == xloc-1 || x == xloc || x == xloc+1)
        next if y == yloc+1 && ( x == xloc-1 || x == xloc || x == xloc+1)
        for z in 0..2
          id=map.data[x,y,z]
          id=0 if !id
          helper.bltTile(bitmap,(x-xloc+7.5)*32,(y-yloc+5.5)*32,id)
        end
      end
    end
    return bitmap
end

def makeMapScreenshot(mapid)
    map=$cache.map_load(mapid)
    return BitmapWrapper.new(32,32) if !map
    bitmap=BitmapWrapper.new(map.width*32,map.height*32)
    tilesets=$cache.RXtilesets ? $cache.RXtilesets : load_data("Data/tilesets.rxdata")
    tileset=tilesets[map.tileset_id]
    return bitmap if !tileset
    helper=TileDrawingHelper.fromTileset(tileset)
    #first do the tiles which don't have priority
    for y in 0...map.height
        for x in 0...map.width
            for z in 0..1
                id=map.data[x,y,z]
                id=0 if !id
                next if tileset.priorities[id] > 0
                helper.bltTile(bitmap,x*32,y*32,id)
            end
        end
    end
    #then all events
    map.events.keys.sort! {|a,b| map.events[a].y <=> map.events[b].y}
    for key in map.events.keys
        event = map.events[key]
        #determine which page is active
        activepage = nil
        for page in event.pages.reverse
            c = page.condition
            next if c.switch1_valid && !checkSwitchOn(c.switch1_id)
            next if c.switch2_valid && !checkSwitchOn(c.switch2_id)
            next if c.variable_valid && $game_variables[c.variable_id] < c.variable_value
            if c.self_switch_valid
                switchkey = [mapid, event.id, c.self_switch_ch]
                next if $game_self_switches[switchkey] != true
            end
            activepage = page
            break
        end
        next if activepage.nil?
        next if !activepage.graphic
        if activepage.graphic.tile_id && activepage.graphic.tile_id >=384
            graphicbitmap = pbGetTileBitmap($cache.RXtilesets[map.tileset_id].tileset_name, activepage.graphic.tile_id, activepage.graphic.character_hue)
            cw = 32 ; ch = 32 ; ox = Game_Map::TILEWIDTH/2 ; oy = Game_Map::TILEHEIGHT
            bitmap.blt(event.x*32, event.y*32, graphicbitmap, Rect.new(0,0,32,32))
        else
            graphicbitmap  = AnimatedBitmap.new("Graphics/Characters/"+activepage.graphic.character_name, activepage.graphic.character_hue).deanimate
            cw = graphicbitmap.width / 4 ; ch = graphicbitmap.height / 4 ; ox = cw / 2 ; oy = activepage.graphic.character_name[/offset/] ? ch - 16 : ch
            sx = activepage.graphic.pattern * cw
            sy = (activepage.graphic.direction - 2) / 2 * ch
            bitmap.blt(event.x*32 + 16 - graphicbitmap.width / 8, (event.y + 1)*32 - graphicbitmap.height / 4 , graphicbitmap, Rect.new(sx, sy , cw, ch))
            #tone isn't handled
        end
    end
    #then do the tiles with priority
    for y in 0...map.height
        for x in 0...map.width
            for z in 0..2
                id=map.data[x,y,z]
                id=0 if !id
                next unless tileset.priorities[id] > 0
                helper.bltTile(bitmap,x*32,y*32,id)
            end
        end
    end
    return bitmap
end

def checkSwitchOn(id)
    switchname=$cache.RXsystem.switches[id]
    return false if !switchname
    if switchname[/^s\:/]
        return eval($~.post_match)
    else
        return $game_switches[id]
    end
end

def pbMapSaveScreenshot(mapid)
    capturefile=nil
    5000.times {|i|
       filename=RTP.getSaveFileName(sprintf("aacapture%03d.bmp",i))
       if !safeExists?(filename)
         capturefile=filename
         break
       end
       i+=1
    }
    begin
      bitmap=makeMapScreenshot(mapid)
      bitmap.to_file(capturefile)
      pbSEPlay("expfull") if FileTest.audio_exist?("Audio/SE/expfull")
    rescue
      nil
    end
end

class Game_Map
    attr_accessor :panorama2_name
    alias _perry_updateTileset updateTileset
    def updateTileset
        @panorama2_name = ""
    end

end
def pbScrollDown(oldmapid,newmapid,hue=0)
    $scene.spriteset.pbScrollDown(oldmapid,newmapid,hue)
end

def pbScrollUp(oldmapid,newmapid,hue=0)
    $scene.spriteset.pbScrollUp(oldmapid,newmapid,hue)
end

def pbSetSecondPanorama(filename)
    $game_map.panorama2_name = filename
end