class CustomTilemapAutotiles
  attr_accessor :changed

  def initialize
    @changed=true
    @tiles=[nil,nil,nil,nil,nil,nil,nil]
  end

  def []=(i,value)
    @tiles[i]=value
    @changed=true
  end

  def [](i)
    return @tiles[i]
  end
end



#Console::setup_console
class CustomTilemapSprite < Sprite
end



class CustomTilemap
  Animated_Autotiles_Frames = 15 # Frequency of updating an animated autotile
  Autotiles = [
     [ [27, 28, 33, 34], [ 5, 28, 33, 34], [27,  6, 33, 34], [ 5,  6, 33, 34],
       [27, 28, 33, 12], [ 5, 28, 33, 12], [27,  6, 33, 12], [ 5,  6, 33, 12] ],
     [ [27, 28, 11, 34], [ 5, 28, 11, 34], [27,  6, 11, 34], [ 5,  6, 11, 34],
       [27, 28, 11, 12], [ 5, 28, 11, 12], [27,  6, 11, 12], [ 5,  6, 11, 12] ],
     [ [25, 26, 31, 32], [25,  6, 31, 32], [25, 26, 31, 12], [25,  6, 31, 12],
       [15, 16, 21, 22], [15, 16, 21, 12], [15, 16, 11, 22], [15, 16, 11, 12] ],
     [ [29, 30, 35, 36], [29, 30, 11, 36], [ 5, 30, 35, 36], [ 5, 30, 11, 36],
       [39, 40, 45, 46], [ 5, 40, 45, 46], [39,  6, 45, 46], [ 5,  6, 45, 46] ],
     [ [25, 30, 31, 36], [15, 16, 45, 46], [13, 14, 19, 20], [13, 14, 19, 12],
       [17, 18, 23, 24], [17, 18, 11, 24], [41, 42, 47, 48], [ 5, 42, 47, 48] ],
     [ [37, 38, 43, 44], [37,  6, 43, 44], [13, 18, 19, 24], [13, 14, 43, 44],
       [37, 42, 43, 48], [17, 18, 47, 48], [13, 18, 43, 48], [ 1,  2,  7,  8] ]
  ]
  FlashOpacity=[100,90,80,70,80,90]
  attr_reader :tileset
  attr_reader :autotiles
  attr_reader :map_data
  attr_accessor :flash_data
  attr_accessor :priorities
  attr_reader :visible
  attr_accessor :ox
  attr_accessor :oy
  attr_reader :viewport
  attr_accessor :tone
  attr_accessor :color

  def graphicsHeight
    return @graphicsHeight
  end

  def graphicsWidth
    return @graphicsWidth
  end

  def initialize(viewport)
    @tileset    = nil  # Refers to Map Tileset Name
    @autotiles  = CustomTilemapAutotiles.new
    @map_data   = nil  # Refers to 3D Array Of Tile Settings
    @flash_data = nil  # Refers to 3D Array of Tile Flashdata
    @priorities = nil  # Refers to Tileset Priorities
    @visible    = true # Refers to Tileset Visibleness
    @ox         = 0    # Bitmap Offsets
    @oy         = 0    # bitmap Offsets
    @plane      = false
    @haveGraphicsWH=Graphics.width!=nil rescue false
    if @haveGraphicsWH
      @graphicsWidth=Graphics.width
      @graphicsHeight=Graphics.height
    else
      @graphicsWidth=640
      @graphicsHeight=480
    end
    @tileWidth = Game_Map::TILEWIDTH rescue 32
    @tileHeight = Game_Map::TILEHEIGHT rescue 32
    @tileSrcWidth = 32
    @tileSrcHeight = 32
    @diffsizes=(@tileWidth!=@tileSrcWidth)||(@tileHeight!=@tileSrcHeight)
    @tone=Tone.new(0,0,0,0)
    @color=Color.new(0,0,0,0)
    @oldtone=Tone.new(0,0,0,0)
    @oldcolor=Color.new(0,0,0,0)
    @selfviewport=Viewport.new(0,0,graphicsWidth,graphicsHeight)
    @viewport=viewport ? viewport : @selfviewport
    @tiles=[]
    @autotileInfo=[]
    @regularTileInfo=[]
    @oldOx=0
    @oldOy=0
    @oldViewportOx=0
    @oldViewportOy=0
    @layer0=CustomTilemapSprite.new(viewport)
    @layer0.visible=true
    @nowshown=false
    @layer0.bitmap=Bitmap.new([graphicsWidth+320,1].max,[graphicsHeight+320,1].max)
    @flash=nil
    @layer0.ox=0
    @layer0.oy=0
    @oxLayer0=0
    @oyLayer0=0
    @oxFlash=0
    @oyFlash=0
    @layer0.z=0
    @priotiles=[]
    @priotilesfast=[]
    @prioautotiles=[]
    @autosprites=[]
    @framecount=[0,0,0,0,0,0,0,0]
    @tilesetChanged=true
    @flashChanged=false
    @firsttime=true
    @disposed=false
    @usedsprites=false
    @layer0clip=true
    @firsttimeflash=true
    @fullyrefreshed=false
    @fullyrefreshedautos=false
  end

  def disposed?
    return @disposed
  end

  def flash_data=(value)
    @flash_data=value
    @flashChanged=true
  end

  def update
    if @haveGraphicsWH
      @graphicsWidth=Graphics.width
      @graphicsHeight=Graphics.height
    end
    if @oldtone!=@tone
      @layer0.tone=@tone
      @flash.tone=@tone if @flash
      for sprite in @autosprites
        sprite.tone=@tone if sprite.is_a?(Sprite)
      end
      for sprite in @tiles
        sprite.tone=@tone if sprite.is_a?(Sprite)
      end
      @oldtone=@tone.clone
    end
    if @oldcolor!=@color
      @layer0.color=@color
      @flash.color=@color if @flash
      for sprite in @autosprites
        sprite.color=@color if sprite.is_a?(Sprite)
      end
      for sprite in @tiles
        sprite.color=@color if sprite.is_a?(Sprite)
      end
      @oldcolor=@color.clone
    end
    if @autotiles.changed
      refresh_autotiles
      repaintAutotiles
    end
    if @flashChanged
      refresh_flash
    end
    if @tilesetChanged
      refresh_tileset
    end
    if @flash
      @flash.opacity=FlashOpacity[(Graphics.frame_count/2) % 6]
    end
    mustrefresh=!(@oldOx==@ox && @oldOy==@oy &&
       !@tilesetChanged && !@autotiles.changed)
    if @viewport.ox!=@oldViewportOx || @viewport.oy!=@oldViewportOy
      mustrefresh=true
      @oldViewportOx=@viewport.ox
      @oldViewportOy=@viewport.oy
    end
    if mustrefresh
      refresh
    end
    if (Graphics.frame_count % Animated_Autotiles_Frames == 0) || @nowshown
      repaintAutotiles
      refresh(true)
    end
    @nowshown=false
    @autotiles.changed=false
    @tilesetChanged=false
  end

  def priorities=(value)
    @priorities=value
    @tilesetChanged=true
  end

  def tileset=(value)
    @tileset=value
    @tilesetChanged=true
  end

  def shown?
    return false if !@visible
    ysize=@map_data.ysize
    xsize=@map_data.xsize
    xStart=(@ox/@tileWidth)-1
    xEnd=((@ox+@viewport.rect.width)/@tileWidth)+1
    yStart=(@oy/@tileHeight)-1
    yEnd=((@oy+@viewport.rect.height)/@tileHeight)+1
    xStart=0 if xStart<0
    xStart=xsize-1 if xStart>=xsize
    xEnd=0 if xEnd<0
    xEnd=xsize-1 if xEnd>=xsize
    yStart=0 if yStart<0
    yStart=ysize-1 if yStart>=ysize
    yEnd=0 if yEnd<0
    yEnd=ysize-1 if yEnd>=ysize
    return (xStart<xEnd && yStart<yEnd)
  end

  def dispose
    return if disposed?
    @help.dispose if @help
    @help=nil
    i=0;len=@autotileInfo.length;while i<len
      if @autotileInfo[i]
        @autotileInfo[i].dispose
        @autotileInfo[i]=nil
      end
      i+=1
    end
    i=0;len=@regularTileInfo.length;while i<len
      if @regularTileInfo[i]
        @regularTileInfo[i].dispose
        @regularTileInfo[i]=nil
      end
      i+=1
    end
    i=0;len=@tiles.length;while i<len
      @tiles[i].dispose
      @tiles[i]=nil
      i+=2
    end
    i=0;len=@autosprites.length;while i<len
      @autosprites[i].dispose
      @autosprites[i]=nil
      i+=2
    end
    if @layer0
      @layer0.bitmap.dispose if !@layer0.disposed?
      @layer0.bitmap=nil if !@layer0.disposed?
      @layer0.dispose
      @layer0=nil
    end
    if @flash
      @flash.bitmap.dispose if !@flash.disposed?
      @flash.bitmap=nil if !@flash.disposed?
      @flash.dispose
      @flash=nil
    end
    for i in 0...7
      self.autotiles[i]=nil
    end
    @tiles.clear
    @autosprites.clear
    @autotileInfo.clear
    @regularTileInfo.clear
    @tilemap=nil
    @tileset=nil
    @priorities=nil
    @selfviewport.dispose
    @selfviewport=nil
    @disposed=true
  end

  def bltAutotile(bitmap,x,y,id,frame)
    return if frame<0
    autotile=@autotiles[id/48-1]
    return if !autotile || autotile.disposed?
    if autotile.height==@tileSrcHeight
      anim=frame*@tileSrcWidth
      src_rect=Rect.new(anim,0,@tileSrcWidth,@tileSrcHeight)
      if @diffsizes
        bitmap.stretch_blt(Rect.new(x,y,@tileWidth,@tileHeight),autotile,src_rect)
      else
        bitmap.blt(x,y,autotile,src_rect)
      end
    else
      anim=frame*3*@tileSrcWidth
      id%=48
      tiles = Autotiles[id>>3][id&7]
      src=Rect.new(0,0,0,0)
      halfTileWidth=@tileWidth>>1
      halfTileHeight=@tileHeight>>1
      halfTileSrcWidth=@tileSrcWidth>>1
      halfTileSrcHeight=@tileSrcHeight>>1
      for i in 0...4
        tile_position = tiles[i] - 1
        src.set( (tile_position % 6)*halfTileSrcWidth + anim,
           (tile_position / 6)*halfTileSrcHeight, halfTileSrcWidth, halfTileSrcHeight)
        if @diffsizes
          bitmap.stretch_blt(
             Rect.new(i%2*halfTileWidth+x,i/2*halfTileHeight+y,halfTileWidth,halfTileHeight),
             autotile,src)
        else
          bitmap.blt(i%2*halfTileWidth+x,i/2*halfTileHeight+y, autotile, src)
        end
      end
    end
  end

  def autotileNumFrames(id)
    autotile=@autotiles[id/48-1]
    return 0 if !autotile || autotile.disposed?
    frames=1
    if autotile.height==@tileHeight
      frames=autotile.width/@tileWidth
    else
      frames=autotile.width/(3*@tileWidth)
    end
    return frames
  end

  def autotileFrame(id)
    autotile=@autotiles[id/48-1]
    return -1 if !autotile || autotile.disposed?
    frames=1
    if autotile.height==@tileHeight
      frames=autotile.width/@tileWidth
    else
      frames=autotile.width/(3*@tileWidth)
    end
    return (Graphics.frame_count/Animated_Autotiles_Frames)%frames
  end

  def repaintAutotiles
    for i in 0...@autotileInfo.length
      next if !@autotileInfo[i]
      frame=autotileFrame(i)
      @autotileInfo[i].clear
      bltAutotile(@autotileInfo[i],0,0,i,frame)
    end
  end

  def getAutotile(sprite,id)
    frames=@framecount[id/48-1]
    if frames<=1
      anim=0
    else
      anim=(Graphics.frame_count/Animated_Autotiles_Frames)%frames
    end
    return if anim<0
    bitmap=@autotileInfo[id]
    if !bitmap
       bitmap=Bitmap.new(@tileWidth,@tileHeight)
       bltAutotile(bitmap,0,0,id,anim)
       @autotileInfo[id]=bitmap
    end
    if sprite.bitmap!=bitmap
      sprite.bitmap=bitmap
    end
  end

  def getRegularTile(sprite,id)
    if !@diffsizes
      if sprite.bitmap!=@tileset
        sprite.bitmap=@tileset
      end
      sprite.src_rect.set(((id - 384)&7)*@tileSrcWidth,((id - 384)>>3)*@tileSrcHeight,
         @tileSrcWidth,@tileSrcHeight)
    else
      bitmap=@regularTileInfo[id]
      if !bitmap
        bitmap=Bitmap.new(@tileWidth,@tileHeight)
        rect=Rect.new(((id - 384)&7)*@tileSrcWidth,((id - 384)>>3)*@tileSrcHeight,
           @tileSrcWidth,@tileSrcHeight)
        bitmap.stretch_blt(Rect.new(0,0,@tileWidth,@tileHeight),@tileset,rect)
        @regularTileInfo[id]=bitmap
      end
      if sprite.bitmap!=bitmap
        sprite.bitmap=bitmap
      end
    end
  end

  def addTile(tiles,count,xpos,ypos,id)
    if id>=384
      if count>=tiles.length
        sprite=CustomTilemapSprite.new(@viewport)
        tiles.push(sprite,0)
      else
        sprite=tiles[count]
        tiles[count+1]=0
      end
      sprite.visible=@visible
      sprite.x=xpos
      sprite.y=ypos
      sprite.tone=@tone
      sprite.color=@color
      getRegularTile(sprite,id)
      spriteZ=(@priorities[id]==0 || !@priorities[id]) ? 0 : ypos+@priorities[id]*32+32
      sprite.z=spriteZ
      count+=2
    else
      if count>=tiles.length
        sprite=CustomTilemapSprite.new(@viewport)
        tiles.push(sprite,1)
      else
        sprite=tiles[count]
        tiles[count+1]=1
      end
      sprite.visible=@visible
      sprite.x=xpos
      sprite.y=ypos
      sprite.tone=@tone
      sprite.color=@color
      getAutotile(sprite,id)
      spriteZ=(@priorities[id]==0 || !@priorities[id]) ? 0 : ypos+@priorities[id]*32+32
      sprite.z=spriteZ
      count+=2
    end
    return count
  end

  def refresh_tileset
    i=0;len=@regularTileInfo.length;while i<len
      if @regularTileInfo[i]
        @regularTileInfo[i].dispose
        @regularTileInfo[i]=nil
      end
      i+=1
    end
    @regularTileInfo.clear
    @priotiles.clear
    ysize=@map_data.ysize
    xsize=@map_data.xsize
    zsize=@map_data.zsize
    if xsize>100 || ysize>100
      @fullyrefreshed=false
    else
      for z in 0...zsize
        for y in 0...ysize
          for x in 0...xsize
            id = @map_data[x, y, z]
            next if id==0 || !@priorities[id]
            next if @priorities[id]==0
            @priotiles.push([x,y,z,id])
          end
        end
      end
      @fullyrefreshed=true
    end
  end

  def refresh_flash
    if @flash_data && !@flash
      @flash=CustomTilemapSprite.new(viewport)
      @flash.visible=true
      @flash.z=1
      @flash.tone=tone
      @flash.color=color
      @flash.blend_type=1
      @flash.bitmap=Bitmap.new([graphicsWidth*2,1].max,[graphicsHeight*2,1].max)
      @firsttimeflash=true
    elsif !@flash_data && @flash
      @flash.bitmap.dispose if @flash.bitmap
      @flash.dispose
      @flash=nil
      @firsttimeflash=false
    end
  end

  def refresh_autotiles
    i=0;len=@autotileInfo.length;while i<len
      if @autotileInfo[i]
        @autotileInfo[i].dispose
        @autotileInfo[i]=nil
      end
      i+=1
    end
    i=0;len=@autosprites.length;while i<len
      if @autosprites[i]
        @autosprites[i].dispose
        @autosprites[i]=nil
      end
      i+=2
    end
    @autosprites.clear
    @autotileInfo.clear
    @prioautotiles.clear
    @priorect=nil
    @priorectautos=nil
    hasanimated=false
    for i in 0...7
      numframes=autotileNumFrames(48*(i+1))
      hasanimated=true if numframes>=2
      @framecount[i]=numframes
    end
    if hasanimated
      ysize=@map_data.ysize
      xsize=@map_data.xsize
      zsize=@map_data.zsize
      if xsize>100 || ysize>100
        @fullyrefreshedautos=false
      else
        for y in 0...ysize
          for x in 0...xsize
            haveautotile=false
            for z in 0...zsize
              id = @map_data[x, y, z]
              next if id==0 || id>=384 || @priorities[id]!=0 || !@priorities[id]
              next if @framecount[id/48-1]<2
              haveautotile=true
              break
            end
            @prioautotiles.push([x,y]) if haveautotile
          end
        end
        @fullyrefreshedautos=true
      end
    else
      @fullyrefreshedautos=true 
    end
  end

  def map_data=(value)
    @map_data=value
    @tilesetChanged=true
  end

  def refreshFlashSprite
    return if !@flash || @flash_data.nil?
    ptX=@ox-@oxFlash
    ptY=@oy-@oyFlash
    if !@firsttimeflash && !@usedsprites &&
       ptX>=0 && ptX+@viewport.rect.width<=@flash.bitmap.width &&
       ptY>=0 && ptY+@viewport.rect.height<=@flash.bitmap.height
      @flash.ox=0
      @flash.oy=0
      @flash.src_rect.set(ptX.round,ptY.round,
         @viewport.rect.width,@viewport.rect.height)
      return
    end
    width=@flash.bitmap.width
    height=@flash.bitmap.height
    bitmap=@flash.bitmap
    ysize=@map_data.ysize
    xsize=@map_data.xsize
    zsize=@map_data.zsize
    @firsttimeflash=false
    @oxFlash=@ox-(width>>2)
    @oyFlash=@oy-(height>>2)
    @flash.ox=0
    @flash.oy=0
    @flash.src_rect.set(width>>2,height>>2,
       @viewport.rect.width,@viewport.rect.height)
    @flash.bitmap.clear
    @oxFlash=@oxFlash.floor
    @oyFlash=@oyFlash.floor
    xStart=(@oxFlash/@tileWidth)
    xStart=0 if xStart<0
    yStart=(@oyFlash/@tileHeight)
    yStart=0 if yStart<0
    xEnd=xStart+(width/@tileWidth)+1
    yEnd=yStart+(height/@tileHeight)+1
    xEnd=xsize if xEnd>=xsize
    yEnd=ysize if yEnd>=ysize
    if xStart<xEnd && yStart<yEnd
      yrange=yStart...yEnd
      xrange=xStart...xEnd
      tmpcolor=Color.new(0,0,0,0)
      for y in yrange
        ypos=(y*@tileHeight)-@oyFlash
        for x in xrange
          xpos=(x*@tileWidth)-@oxFlash
          id = @flash_data[x, y, 0]
          r=(id>>8)&15
          g=(id>>4)&15
          b=(id)&15
          tmpcolor.set(r<<4,g<<4,b<<4)
          bitmap.fill_rect(xpos,ypos,@tileWidth,@tileHeight,tmpcolor)
        end
      end
    end
  end

  def refreshLayer0(autotiles=false)
    if autotiles
      return true if !shown?
    end
    ptX=@ox-@oxLayer0
    ptY=@oy-@oyLayer0
    if !autotiles && !@firsttime && !@usedsprites &&
       ptX>=0 && ptX+@viewport.rect.width<=@layer0.bitmap.width &&
       ptY>=0 && ptY+@viewport.rect.height<=@layer0.bitmap.height
      if @layer0clip && @viewport.ox==0 && @viewport.oy==0
        @layer0.ox=0
        @layer0.oy=0
        @layer0.src_rect.set(ptX.round,ptY.round,
           @viewport.rect.width,@viewport.rect.height)
      else
        @layer0.ox=ptX.round
        @layer0.oy=ptY.round
        @layer0.src_rect.set(0,0,@layer0.bitmap.width,@layer0.bitmap.height)
      end
      return true
    end
    width=@layer0.bitmap.width
    height=@layer0.bitmap.height
    bitmap=@layer0.bitmap
    ysize=@map_data.ysize
    xsize=@map_data.xsize
    zsize=@map_data.zsize
    twidth=@tileWidth
    theight=@tileHeight
    mapdata=@map_data
    if autotiles
      return true if @fullyrefreshedautos && @prioautotiles.length==0
      xStart=(@oxLayer0/twidth)
      xStart=0 if xStart<0
      yStart=(@oyLayer0/theight)
      yStart=0 if yStart<0
      xEnd=xStart+(width/twidth)+1
      yEnd=yStart+(height/theight)+1
      xEnd=xsize if xEnd>xsize
      yEnd=ysize if yEnd>ysize
      return true if xStart>=xEnd || yStart>=yEnd
      trans=Color.new(0,0,0,0)
      temprect=Rect.new(0,0,0,0)
      tilerect=Rect.new(0,0,twidth,theight)
      zrange=0...zsize
      overallcount=0
      count=0
      if !@fullyrefreshedautos
        for y in yStart..yEnd
          for x in xStart..xEnd
            haveautotile=false
            for z in zrange
              id = mapdata[x, y, z]
              next if !id || id<48 || id>=384
              prioid=@priorities[id]
              next if prioid!=0 || !prioid
              fcount=@framecount[id/48-1]
              next if !fcount || fcount<2
              if !haveautotile
                haveautotile=true
                overallcount+=1
                xpos=(x*twidth)-@oxLayer0
                ypos=(y*theight)-@oyLayer0
                bitmap.fill_rect(xpos,ypos,twidth,theight,trans) if overallcount<=2000
                break
              end
            end
            for z in zrange
              id = mapdata[x,y,z]
              next if !id || id<48
              prioid=@priorities[id]
              next if prioid!=0 || !prioid
              if overallcount>2000
                xpos=(x*twidth)-@oxLayer0
                ypos=(y*theight)-@oyLayer0
                count=addTile(@autosprites,count,xpos,ypos,id)
                next
              elsif id>=384
                temprect.set(((id - 384)&7)*@tileSrcWidth,((id - 384)>>3)*@tileSrcHeight,
                   @tileSrcWidth,@tileSrcHeight)
                xpos=(x*twidth)-@oxLayer0
                ypos=(y*theight)-@oyLayer0
                if @diffsizes
                  bitmap.stretch_blt(Rect.new(xpos,ypos,twidth,theight),@tileset,temprect)
                else
                  bitmap.blt(xpos,ypos,@tileset,temprect)
                end
              else
                tilebitmap=@autotileInfo[id]
                if !tilebitmap
                  anim=autotileFrame(id)
                  next if anim<0
                  tilebitmap=Bitmap.new(twidth,theight)
                  bltAutotile(tilebitmap,0,0,id,anim)
                  @autotileInfo[id]=tilebitmap
                end
                xpos=(x*twidth)-@oxLayer0
                ypos=(y*theight)-@oyLayer0
                bitmap.blt(xpos,ypos,tilebitmap,tilerect)
              end
            end
          end
        end
        Graphics.frame_reset
      else
        if !@priorect || !@priorectautos || @priorect[0]!=xStart ||
           @priorect[1]!=yStart ||
           @priorect[2]!=xEnd ||
           @priorect[3]!=yEnd
          @priorectautos=@prioautotiles.find_all{|tile|
             x=tile[0]
             y=tile[1]
             # "next" means "return" here
             next !(x<xStart||x>xEnd||y<yStart||y>yEnd)
          }
          @priorect=[xStart,yStart,xEnd,yEnd]
        end
   #   echoln ["autos",@priorect,@priorectautos.length,@prioautotiles.length]
        for tile in @priorectautos
          x=tile[0]
          y=tile[1]
          overallcount+=1
          xpos=(x*twidth)-@oxLayer0
          ypos=(y*theight)-@oyLayer0
          bitmap.fill_rect(xpos,ypos,twidth,theight,trans)
          z=0
          while z<zsize
            id = mapdata[x,y,z]
            z+=1
            next if !id || id<48
            prioid=@priorities[id]
            next if prioid!=0 || !prioid
            if id>=384
              temprect.set(((id - 384)&7)*@tileSrcWidth,((id - 384)>>3)*@tileSrcHeight,
                 @tileSrcWidth,@tileSrcHeight)
              if @diffsizes
                bitmap.stretch_blt(Rect.new(xpos,ypos,twidth,theight),@tileset,temprect)
              else
                bitmap.blt(xpos,ypos,@tileset,temprect)
              end
            else
              tilebitmap=@autotileInfo[id]
              if !tilebitmap
                anim=autotileFrame(id)
                next if anim<0
                tilebitmap=Bitmap.new(twidth,theight)
                bltAutotile(tilebitmap,0,0,id,anim)
                @autotileInfo[id]=tilebitmap
              end
              bitmap.blt(xpos,ypos,tilebitmap,tilerect)
            end
          end
        end
        Graphics.frame_reset if overallcount>500
      end
      @usedsprites=false
      return true
    end
    return false if @usedsprites
    @firsttime=false
    @oxLayer0=@ox-(width>>2)
    @oyLayer0=@oy-(height>>2)
    if @layer0clip
      @layer0.ox=0
      @layer0.oy=0
      @layer0.src_rect.set(width>>2,height>>2,
         @viewport.rect.width,@viewport.rect.height)
    else
      @layer0.ox=(width>>2)
      @layer0.oy=(height>>2)
    end
    @layer0.bitmap.clear
    @oxLayer0=@oxLayer0.floor
    @oyLayer0=@oyLayer0.floor
    xStart=(@oxLayer0/twidth)
    xStart=0 if xStart<0
    yStart=(@oyLayer0/theight)
    yStart=0 if yStart<0
    xEnd=xStart+(width/twidth)+1
    yEnd=yStart+(height/theight)+1
    xEnd=xsize if xEnd>=xsize
    yEnd=ysize if yEnd>=ysize
    if xStart<xEnd && yStart<yEnd
      tmprect=Rect.new(0,0,0,0)
      yrange=yStart...yEnd
      xrange=xStart...xEnd
      for z in 0...zsize
        for y in yrange
          ypos=(y*theight)-@oyLayer0
          for x in xrange
            xpos=(x*twidth)-@oxLayer0
            id = mapdata[x, y, z]
            next if id==0 || @priorities[id]!=0 || !@priorities[id]
            if id>=384
              tmprect.set( ((id - 384)&7)*@tileSrcWidth,((id - 384)>>3)*@tileSrcHeight,
                 @tileSrcWidth,@tileSrcHeight)
              if @diffsizes
                bitmap.stretch_blt(Rect.new(xpos,ypos,twidth,theight),@tileset,tmprect)
              else
                bitmap.blt(xpos,ypos,@tileset,tmprect)
              end
            else
              frames=@framecount[id/48-1]
              if frames<=1
                frame=0
              else
                frame=(Graphics.frame_count/Animated_Autotiles_Frames)%frames
              end
              bltAutotile(bitmap,xpos,ypos,id,frame)
            end
          end
        end
      end
      Graphics.frame_reset
    end
    return true
  end

  def getResizeFactor
    return $ResizeFactor ? $ResizeFactor : 1.0
  end

  def ox=(val)
    rf=getResizeFactor
    if rf!=1.0
      val=(val*rf).to_i
      val=(val/rf).to_i
    end
    wasshown=self.shown?
    @ox=val.floor
    @nowshown=(!wasshown && self.shown?)
  end

  def oy=(val)
    rf=getResizeFactor
    if rf!=1.0
      val=(val*rf).to_i
      val=(val/rf).to_i
    end
    wasshown=self.shown?
    @oy=val.floor
    @nowshown=(!wasshown && self.shown?)
  end

  def visible=(val)
    wasshown=@visible
    @visible=val
    @nowshown=(!wasshown && val)
  end

  def refresh(autotiles=false)
    @oldOx=@ox
    @oldOy=@oy
    usesprites=false
    if @layer0
      @layer0.visible=@visible
      usesprites=!refreshLayer0(autotiles)
      if autotiles && !usesprites
        return
      end
    else
      usesprites=true
    end
    refreshFlashSprite
    vpx=@viewport.rect.x
    vpy=@viewport.rect.y
    vpr=@viewport.rect.width+vpx
    vpb=@viewport.rect.height+vpy
    xsize=@map_data.xsize
    ysize=@map_data.ysize
    minX=(@ox/@tileWidth)-1
    maxX=((@ox+@viewport.rect.width)/@tileWidth)+1
    minY=(@oy/@tileHeight)-1
    maxY=((@oy+@viewport.rect.height)/@tileHeight)+1
    minX=0 if minX<0
    minX=xsize-1 if minX>=xsize
    maxX=0 if maxX<0
    maxX=xsize-1 if maxX>=xsize
    minY=0 if minY<0
    minY=ysize-1 if minY>=ysize
    maxY=0 if maxY<0
    maxY=ysize-1 if maxY>=ysize
    count=0
    if minX<maxX && minY<maxY
      @usedsprites=usesprites || @usedsprites
      if @layer0
        @layer0.visible=false if usesprites
      end
      if @fullyrefreshed
        if !@priotilesrect || !@priotilesfast || 
           @priotilesrect[0]!=minX ||
           @priotilesrect[1]!=minY ||
           @priotilesrect[2]!=maxX ||
           @priotilesrect[3]!=maxY
          @priotilesfast=@priotiles.find_all{|tile|
             x=tile[0]
             y=tile[1]
             # "next" means "return" here
             next !(x<minX || x>maxX || y<minY || y>maxY)
          }
          @priotilesrect=[minX,minY,maxX,maxY]
        end
        #   echoln [minX,minY,maxX,maxY,@priotilesfast.length,@priotiles.length]
        for prio in @priotilesfast
          xpos=(prio[0]*@tileWidth)-@ox
          ypos=(prio[1]*@tileHeight)-@oy
          count=addTile(@tiles,count,xpos,ypos,prio[3])
        end
      else
        if !@priotilesrect || !@priotilesfast || 
           @priotilesrect[0]!=minX ||
           @priotilesrect[1]!=minY ||
           @priotilesrect[2]!=maxX ||
           @priotilesrect[3]!=maxY
          @priotilesfast=[]
          for z in 0...@map_data.zsize
            for y in minY..maxY
              for x in minX..maxX
                id = @map_data[x, y, z]
                next if id==0 || !@priorities[id]
                next if @priorities[id]==0
                @priotilesfast.push([x,y,z,id])
              end
            end
          end
          @priotilesrect=[minX,minY,maxX,maxY]
        end
        for prio in @priotilesfast
          xpos=(prio[0]*@tileWidth)-@ox
          ypos=(prio[1]*@tileHeight)-@oy
          count=addTile(@tiles,count,xpos,ypos,prio[3])
        end
      end
    end
    if count<@tiles.length
      bigchange=(count<=(@tiles.length*2/3)) && (@tiles.length*2/3)>25
      j=count;len=@tiles.length;while j<len
        sprite=@tiles[j]
        @tiles[j+1]=-1
        if bigchange
          sprite.dispose
          @tiles[j]=nil
          @tiles[j+1]=nil
        elsif !@tiles[j].disposed?
          sprite.visible=false if sprite.visible
        end
        j+=2
      end
      @tiles.compact! if bigchange
    end
  end
end



class SynchronizedTilemapAutotilesInternal
  def initialize(oldat)
    @atdisposables=[[],[],[],[],[],[],[]]
    @atframes=[[],[],[],[],[],[],[]]
    @atframe=[-1,-1,-1,-1,-1,-1,-1]
    @autotiles=[]
    @oldat=oldat
  end

  def dispose
    for i in 0...7
      for bitmap in @atdisposables[i]
        bitmap.dispose
      end
      @atdisposables[i].clear
      @atframes[i].clear
    end
  end

  def [](i)
    return @autotiles[i]
  end

  def []=(i,value)
    for frame in @atdisposables[i]
      frame.dispose
    end
    @atframe[i]=-1
    @atframes[i].clear
    @atdisposables[i].clear
    if value && !value.disposed?
      if value.height==32
        frames=value.width/32
        for j in 0...frames
          @atdisposables[i][j]=Bitmap.new(32,32)
          @atdisposables[i][j].blt(0,0,value,Rect.new(j*32,0,32,32))
          @atframes[i][j]=@atdisposables[i][j]
        end
      elsif value.height==128
        frames=value.width/96
        for j in 0...frames
          @atdisposables[i][j]=Bitmap.new(96,128)
          @atdisposables[i][j].blt(0,0,value,Rect.new(j*96,0,96,128))
          @atframes[i][j]=@atdisposables[i][j]
        end
      else
        @atframes[i][0]=value
      end
    else
      @atframes[i][0]=value
    end
    @autotiles[i]=value
    sync
  end

  def sync
    frameused=[]
    for i in 0...7
      frames=[1,@atframes[i].length].max
      frame=(Graphics.frame_count/15)%frames
      if frames>1 && @atframe[i]!=frame
        @oldat[i]=@atframes[i][frame]
        @atframe[i]=frame
      end
    end
  end
end



class SynchronizedTilemapAutotiles
  def initialize(autotiles)
    @autotiles=autotiles
  end

  def [](i)
    @autotiles[i]
  end

  def []=(i,value)
    @autotiles[i]=value
  end
end



class SynchronizedTilemap < Tilemap
  # This class derives from Tilemap just to synchronize
  # the tilemap animation.
  attr_accessor :numupdates

  def initialize(viewport=nil)
    super(viewport)
    @updating=true
    @autotiles=SynchronizedTilemapAutotilesInternal.new(self.autotiles)
    @autos=SynchronizedTilemapAutotiles.new(@autotiles)
    @updating=false
  end

  def dispose
    @autotiles.dispose
    super
  end

  def autotiles
    if @updating
      super
    else
      return @autos
    end   
  end

  def update
   return if disposed?
   @autotiles.sync
   super
  end
end