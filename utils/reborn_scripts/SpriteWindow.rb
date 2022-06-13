module MessageConfig
  FontName        = "PokemonEmerald"
  # in Graphics/Windowskins/ (specify empty string to use the default windowskin)
  TextSkinName    = "PRWS- speech1"
  ChoiceSkinName  = "PRWS- menu1"
  WindowOpacity   = 255
  TextSpeed       = -6 # can be positive to wait frames or negative to
                        # show multiple characters in a single frame
  LIGHTTEXTBASE   = Color.new(248,248,248)
  LIGHTTEXTSHADOW = Color.new(72,80,88)
  DARKTEXTBASE    = Color.new(88,88,80)
  DARKTEXTSHADOW  = Color.new(168,184,184)
  # 0 = Pause cursor is displayed at end of text
  # 1 = Pause cursor is displayed at bottom right
  # 2 = Pause cursor is displayed at lower middle side
  CURSORMODE      = 1
  FontSubstitutes = {
     "Power Green Narrow"=>"Pokemon Emerald Narrow",
     "Power Green Small"=>"Pokemon Emerald Small",
  }
  @@systemFrame     = nil
  @@defaultTextSkin = nil
  @@systemFont      = nil
 @@textSpeed       = -6
 
  def self.pbTryFonts(*args)
    for a in args
      if a && a.is_a?(String)
        return a if Font.exist?(a)
        a=MessageConfig::FontSubstitutes[a] || a
        return a if Font.exist?(a)
      elsif a && a.is_a?(Array)
        for aa in a
          ret=MessageConfig.pbTryFonts(aa)
          return ret if ret!=""
        end
      end
    end
    return ""
  end

  def self.pbDefaultTextSpeed
    return TextSpeed ? TextSpeed : (Graphics.width > 400) ? -2 : 1
  end

  def self.pbDefaultSystemFrame
    return "" if !MessageConfig::ChoiceSkinName
    return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::ChoiceSkinName)||""
  end

  def self.pbDefaultSpeechFrame
    return "" if !MessageConfig::TextSkinName
    return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::TextSkinName)||""
  end

  def self.pbDefaultSystemFontName
    return MessageConfig.pbTryFonts(MessageConfig::FontName,"Arial Narrow","Arial")
  end

  def self.pbDefaultWindowskin
    skin=load_data("Data/System.rxdata").windowskin_name rescue nil
    if skin && skin!=""
      skin=pbResolveBitmap("Graphics/Windowskins/"+skin) || ""
    end
    if !skin || skin==""
      skin=pbResolveBitmap("Graphics/System/Window")
    end
    if !skin || skin==""
      skin=pbResolveBitmap("Graphics/Windowskins/001-Blue01")
    end
    return skin || ""
  end

  def self.pbGetSpeechFrame
    if !@@defaultTextSkin
      skin=MessageConfig.pbDefaultSpeechFrame()
      if !skin || skin==""
        skin=MessageConfig.pbDefaultWindowskin()
      end
      @@defaultTextSkin=skin || ""
    end
    return @@defaultTextSkin
  end

  def self.pbGetTextSpeed
    if !@@textSpeed
      @@textSpeed=pbDefaultTextSpeed()
    end
    return @@textSpeed
  end

  def self.pbGetSystemFontName
    if !@@systemFont
      @@systemFont=pbDefaultSystemFontName()
    end
    if $game_switches
      if $game_switches[:Wing_Dings]
        return "Untitled1"
      end
    end
    return @@systemFont
  end

  def self.pbGetSystemFrame
    if !@@systemFrame
      skin=MessageConfig.pbDefaultSystemFrame()
      if !skin || skin==""
        skin=MessageConfig.pbDefaultWindowskin()
      end
      @@systemFrame=skin || ""
    end
    return @@systemFrame
  end

  def self.pbSetSystemFrame(value)
    @@systemFrame=pbResolveBitmap(value) || ""
  end

  def self.pbSetSpeechFrame(value)
    @@defaultTextSkin=pbResolveBitmap(value) || ""
  end

  def self.pbSetSystemFontName(value)
    @@systemFont=MessageConfig.pbTryFonts(value,"PokemonEmerald","Arial Narrow","Arial")
  end

  def self.pbSetTextSpeed(value)
    @@textSpeed=value-6
  end
end


#############################
#############################

# Works around a problem with FileTest.exist if path contains accent marks
def safeExists?(f)
  ret=false
  if f[/\A[\x20-\x7E]*\z/]
    return FileTest.exist?(f)
  end
  begin
    File.open(f,"rb") { ret=true }
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES
    ret=false
  end
  return ret
end

#############################
#############################


class AnimatedBitmap
  def initialize(file,hue=0)
    raise "filename is nil" if file==nil
    if file[/^\[(\d+)\]/]
      @bitmap=PngAnimatedBitmap.new(file,hue)
    else
      @bitmap=GifBitmap.new(file,hue)
    end
  end

  def [](index); @bitmap[index]; end
  def width; @bitmap.bitmap.width; end
  def height; @bitmap.bitmap.height; end
  def length; @bitmap.length; end
  def each; @bitmap.each {|item| yield item }; end
  def bitmap; @bitmap.bitmap; end
  def currentIndex; @bitmap.currentIndex; end
  def frameDelay; @bitmap.frameDelay; end
  def totalFrames; @bitmap.totalFrames; end
  def disposed?; @bitmap.disposed?; end
  def update; @bitmap.update; end
  def dispose; @bitmap.dispose; end
  def deanimate; @bitmap.deanimate; end
  def copy; @bitmap.copy; end
  def setBitmap(bitmap); @bitmap.setBitmap(bitmap); end
end

def pbGetTileBitmap(filename, tile_id, hue, width = 1, height = 1)
  return RPG::Cache.tileEx(filename, tile_id, hue, width, height) { |f|
    AnimatedBitmap.new("Graphics/Tilesets/" + filename).deanimate
  }
end

def pbGetAnimation(name,hue=0)
	if !name.nil?
		return AnimatedBitmap.new("Graphics/Animations/"+name,hue).deanimate
	end
end

def pbGetTileset(name,hue=0)
	if !name.nil?
		return AnimatedBitmap.new("Graphics/Tilesets/"+name,hue).deanimate
	end
end

def pbGetAutotile(name,hue=0)
	if !name.nil?
		ret = AnimatedBitmap.new("Graphics/Autotiles/"+name,hue).deanimate
    if ret.height==128 && ret.width==768
      newbitmap = ret.copy
      frame=Graphics.frame_count/15 % 8
      src_rect1=Rect.new(0,0,ret.width*frame/8,ret.height)
      src_rect2=Rect.new(ret.width*frame/8,0,ret.width-ret.width*frame/8,ret.height)
      newbitmap.blt(0,0,ret,src_rect2)
      newbitmap.blt(ret.width-ret.width*frame/8,0,ret,src_rect1)
      ret=newbitmap
    end
    return ret
	end
end

#########################
#
# Message support
#
#########################
if !defined?(_INTL)
  def _INTL(*args); 
    string=args[0].clone
    for i in 1...args.length
      string.gsub!(/\{#{i}\}/,"#{args[i]}")
    end
    return string    
  end
end

if !defined?(_ISPRINTF)
  def _ISPRINTF(*args);
    string=args[0].clone
    for i in 1...args.length
      string.gsub!(/\{#{i}\:([^\}]+?)\}/){|m|
         next sprintf("%"+$1,args[i])
      }
    end
    return string
  end
end

if !defined?(_MAPINTL)
  def _MAPINTL(*args);
    string=args[1].clone
    for i in 2...args.length
      string.gsub!(/\{#{i}\}/,"#{args[i+1]}")
    end
    return string  
  end
end

module Graphics
  if !self.respond_to?("width")
    def self.width; return 640; end
  end
  if !self.respond_to?("height")
    def self.height; return 480; end
  end
end

module RTP
  @rtpPaths=nil

  def self.exists?(filename,extensions=[])
    return false if !filename || filename==""
    eachPathFor(filename) {|path|
       return true if safeExists?(path)
       for ext in extensions
         return true if safeExists?(path+ext)
       end
    }
    return false
  end

  def self.getImagePath(filename)
    return self.getPath(filename,["",".png",".jpg",".gif",".bmp",".jpeg"])
  end

  def self.getAudioPath(filename)
    return self.getPath(filename,["",".mp3",".wav",".wma",".mid",".ogg",".midi"])
  end

  def self.getPath(filename,extensions=[])
    return filename if !filename || filename==""
    eachPathFor(filename) {|path|
       return path if safeExists?(path)
       for ext in extensions
         file=path+ext
         return file if safeExists?(file)
       end
    }
    return filename
  end

 # Gets the absolute RGSS paths for the given file name
  def self.eachPathFor(filename)
    return if !filename
    if filename[/^[A-Za-z]\:[\/\\]/] || filename[/^[\/\\]/] 
      # filename is already absolute
      yield filename
    else
      # relative path
      RTP.eachPath {|path| 
         if path=="./"
           yield filename
         else
           yield path+filename
         end
      }
    end
  end

  # Gets all RGSS search paths
  def self.eachPath
    # XXX: Use "." instead of Dir.pwd because of problems retrieving files if
    # the current directory contains an accent mark
    yield ".".gsub(/[\/\\]/,"/").gsub(/[\/\\]$/,"")+"/"
  end

  private

  def self.getSaveFileName(filename)
    return getSaveFolder().gsub(/[\/\\]$/,"")+"/"+filename
  end

  def self.getSaveSlotPath(slot=1)
    number = (slot==1 ? "" : "_"+slot.to_s)
    filename = "Game"+ number +".rxdata"
    return getSaveFolder().gsub(/[\/\\]$/,"")+"/"+filename
  end

  def self.getSaveFolder
    if System.platform[/Windows/]
      savewrapper = ENV['USERPROFILE'] + "/Saved Games/"
      Dir.mkdir(savewrapper) unless (File.exists?(savewrapper))
      savefolder = ENV['USERPROFILE'] + "/Saved Games/#{GAMETITLE}/"
      Dir.mkdir(savefolder) unless (File.exists?(savefolder))
      return savefolder
    else
      # MKXP makes sure that this folder has been created
      # once it starts. The location differs depending on
      # the operating system:
      # Windows: %APPDATA%
      # Linux: $HOME/.local/share
      # macOS (unsandboxed): $HOME/Library/Application Support
      return System.data_directory
    end
  end
end

module FileTest
  Image_ext = ['.bmp', '.png', '.jpg', '.jpeg', '.gif']
  Audio_ext = ['.mp3', '.mid', '.midi', '.ogg', '.wav', '.wma']

  def self.audio_exist?(filename)
    return RTP.exists?(filename,Audio_ext)
  end

  def self.image_exist?(filename)
    return RTP.exists?(filename,Image_ext)
  end
end
###########

class PngAnimatedBitmap # :nodoc:
  # Creates an animated bitmap from a PNG file.  
  def initialize(file,hue=0)
    @frames=[]
    @currentFrame=0
    @framecount=0
    panorama = RPG::Cache.load_bitmap(dir, filename, hue)
    if file[/^\[(\d+)\]/]
      # File has a frame count
      numFrames=$1.to_i
      if numFrames<=0
        raise "Invalid frame count in #{file}"
      end
      if panorama.width % numFrames != 0
        raise "Bitmap's width (#{panorama.width}) is not divisible by frame count: #{file}"
      end
      subWidth=panorama.width/numFrames
      for i in 0...numFrames
        subBitmap=BitmapWrapper.new(subWidth,panorama.height)
        subBitmap.blt(0,0,panorama,Rect.new(subWidth*i,0,subWidth,panorama.height))
        @frames.push(subBitmap)
      end
      panorama.dispose
    else
      @frames=[panorama]
    end
  end

  def [](index)
    return @frames[index]
  end

  def width; self.bitmap.width; end
  
  def height; self.bitmap.height; end
  
  def deanimate
    for i in 1...@frames.length
      @frames[i].dispose
    end
    @frames=[@frames[0]]
    @currentFrame=0
    return @frames[0]
  end

  def bitmap
    @frames[@currentFrame]
  end

  def currentIndex
    @currentFrame
  end

  def frameDelay(index)
    return 10
  end

  def length
    @frames.length
  end

  def each
    @frames.each {|item| yield item}
  end

  def totalFrames
    10*@frames.length
  end

  def disposed?
    @disposed
  end

  def update
    return if disposed?
    if @frames.length>1
      @framecount+=1
      if @framecount>=10
        @framecount=0
        @currentFrame+=1
        @currentFrame%=@frames.length
      end
    end
  end

  def dispose
    if !@disposed
      for i in @frames
        i.dispose
      end
    end
    @disposed=true
  end

  attr_accessor :frames # internal

  def copy
    x=self.clone
    x.frames=x.frames.clone
    for i in 0...x.frames.length
      x.frames[i]=x.frames[i].copy
    end
    return x
  end
end



#internal class
class GifBitmap
  # Creates a bitmap from a GIF file with the specified
  # optional viewport.  Can also load non-animated bitmaps.
  def initialize(file,hue=0)
    @gifbitmaps=[]
    @gifdelays=[]
    @totalframes=0
    @framecount=0
    @currentIndex=0
    @disposed=false
    bitmap=nil
    filestring=nil
    filestrName=nil
    file="" if !file
    file=canonicalize(file)
    begin
      bitmap=RPG::Cache.load_bitmap(file,hue)
    rescue
      bitmap=nil
    end
    if bitmap && filestring && filestring[0]==0x47 &&
       bitmap.width==32 && bitmap.height==32
      #File.open("debug.txt","ab"){|f| f.puts("rejecting bitmap") }
      bitmap.dispose
      bitmap=nil
    end 
    if bitmap
      #File.open("debug.txt","ab"){|f| f.puts("reusing bitmap") }
      # Have a regular non-animated bitmap
      @totalframes=1
      @framecount=0
      @gifbitmaps=[bitmap]
      @gifdelays=[1]
    else
      tmpBase=File.basename(file)+"_tmp_"
      filestring=pbGetFileString(filestrName) if filestring
      if @gifbitmaps.length==0
        @gifbitmaps=[BitmapWrapper.new(32,32)]
        @gifdelays=[1]
      end
      if @gifbitmaps.length==1
        RPG::Cache.setKey(file,@gifbitmaps[0])
      end
    end
  end

  def [](index)
    return @gifbitmaps[index]
  end

  def width; self.bitmap.width; end

  def height; self.bitmap.height; end

  def deanimate
    for i in 1...@gifbitmaps.length
      @gifbitmaps[i].dispose
    end
    @gifbitmaps=[@gifbitmaps[0]]
    @currentIndex=0
    return @gifbitmaps[0]
  end

  def bitmap
    @gifbitmaps[@currentIndex]
  end

  def currentIndex
    @currentIndex
  end

  def frameDelay(index)
    return @gifdelay[index]/2 # Due to frame count being incremented by 2
  end

  def length
    @gifbitmaps.length
  end

  def each
    @gifbitmaps.each {|item| yield item }
  end

  def totalFrames
    @totalframes/2 # Due to frame count being incremented by 2
  end

  def disposed?
    @disposed
  end

  def width
    @gifbitmaps.length==0 ? 0 : @gifbitmaps[0].width
  end

  def height
    @gifbitmaps.length==0 ? 0 : @gifbitmaps[0].height
  end

 # This function must be called in order to animate the GIF image.
  def update
    return if disposed?
    if @gifbitmaps.length>0
      @framecount+=2
      @framecount=@totalframes<=0 ? 0 : @framecount%@totalframes
      frametoshow=0
      for i in 0...@gifdelays.length
        frametoshow=i if @gifdelays[i]<=@framecount
      end
      @currentIndex=frametoshow
    end
  end

  def dispose
    if !@disposed
      for i in @gifbitmaps
        i.dispose
      end
    end
    @disposed=true
  end

 attr_accessor :gifbitmaps # internal
 attr_accessor :gifdelays # internal

  def copy
    x=self.clone
    x.gifbitmaps=x.gifbitmaps.clone
    x.gifdelays=x.gifdelays.clone
    for i in 0...x.gifbitmaps.length
      x.gifbitmaps[i]=x.gifbitmaps[i].copy
    end
    return x
  end

  def setBitmap(bitmap)
    @gifbitmaps[@currentIndex]=bitmap
  end
end

def pbDrawShadow(bitmap,x,y,width,height,string)
  return if !bitmap || !string
  pbDrawShadowText(bitmap,x,y,width,height,string,nil,bitmap.font.color)
end

def pbDrawShadowText(bitmap,x,y,width,height,string,baseColor,shadowColor=nil,align=0)
  return if !bitmap || !string
  width=(width<0) ? bitmap.text_size(string).width+4 : width
  height=(height<0) ? bitmap.text_size(string).height+4 : height
  if shadowColor
    bitmap.font.color=shadowColor
    bitmap.draw_text(x+2,y,width,height,string,align)
    bitmap.draw_text(x,y+2,width,height,string,align)
    bitmap.draw_text(x+2,y+2,width,height,string,align)
  end
  if baseColor
    bitmap.font.color=baseColor
    bitmap.draw_text(x,y,width,height,string,align)
  end
end

def pbDrawOutlineText(bitmap,x,y,width,height,string,baseColor,shadowColor=nil,align=0)
  return if !bitmap || !string
  width=(width<0) ? bitmap.text_size(string).width+4 : width
  height=(height<0) ? bitmap.text_size(string).height+4 : height
  if shadowColor
    bitmap.font.color=shadowColor
    bitmap.draw_text(x-2,y-2,width,height,string,align)
    bitmap.draw_text(x,y-2,width,height,string,align)
    bitmap.draw_text(x+2,y-2,width,height,string,align)
    bitmap.draw_text(x-2,y,width,height,string,align)
    bitmap.draw_text(x+2,y,width,height,string,align)
    bitmap.draw_text(x-2,y+2,width,height,string,align)
    bitmap.draw_text(x,y+2,width,height,string,align)
    bitmap.draw_text(x+2,y+2,width,height,string,align)
  end
  if baseColor
    bitmap.font.color=baseColor
    bitmap.draw_text(x,y,width,height,string,align)
  end
end

def pbCopyBitmap(dstbm,srcbm,x,y,opacity=255)
  rc=Rect.new(0,0,srcbm.width,srcbm.height)
  dstbm.blt(x,y,srcbm,rc,opacity)
end

def using_block(window)
  begin
    yield if block_given?
    ensure
    window.dispose
  end
end

def pbBottomRight(window)
  window.x=Graphics.width-window.width
  window.y=Graphics.height-window.height
end

def pbBottomLeft(window)
  window.x=0
  window.y=Graphics.height-window.height
end

def pbBottomLeftLines(window,lines,width=nil)
  window.x=0
  window.width=width ? width : Graphics.width
  window.height=(window.borderY rescue 32)+lines*32
  window.y=Graphics.height-window.height
end

def pbDisposed?(x)
  return true if !x
  if x.is_a?(Viewport)
    begin
      x.rect=x.rect
      rescue
      return true
    end
    return false
  else
    return x.disposed?
  end
end

def isDarkBackground(background,rect=nil)
  if !background || background.disposed?
    return true
  end
  rect=background.rect if !rect
  if rect.width<=0 || rect.height<=0
    return true
  end
  xSeg=(rect.width/16)
  xLoop=(xSeg==0) ? 1 : 16
  xStart=(xSeg==0) ? rect.x+(rect.width/2) : rect.x+xSeg/2
  ySeg=(rect.height/16)
  yLoop=(ySeg==0) ? 1 : 16
  yStart=(ySeg==0) ? rect.y+(rect.height/2) : rect.y+ySeg/2
  count=0
  y=yStart
  r=0; g=0; b=0
  yLoop.times {
     x=xStart
     xLoop.times {
        clr=background.get_pixel(x,y)
        if clr.alpha!=0
          r+=clr.red; g+=clr.green; b+=clr.blue
          count+=1
        end
        x+=xSeg
     }
     y+=ySeg
  }
  return true if count==0
  r/=count
  g/=count
  b/=count
  return (r*0.299+g*0.587+b*0.114)<128
end

def isDarkWindowskin(windowskin)
  if !windowskin || windowskin.disposed?
    return true
  end
  if windowskin.width==192 && windowskin.height==128
    return isDarkBackground(windowskin,Rect.new(0,0,128,128))
  elsif windowskin.width==128 && windowskin.height==128
    return isDarkBackground(windowskin,Rect.new(0,0,64,64))
  else
    clr=windowskin.get_pixel(windowskin.width/2, windowskin.height/2)
    return (clr.red*0.299+clr.green*0.587+clr.blue*0.114)<128
  end
end

def getDefaultTextColors(windowskin)
  if !windowskin || windowskin.disposed? || 
     windowskin.width!=128 || windowskin.height!=128
    if isDarkWindowskin(windowskin)
      return [MessageConfig::LIGHTTEXTBASE,MessageConfig::LIGHTTEXTSHADOW] # White
    else
      return [MessageConfig::DARKTEXTBASE,MessageConfig::DARKTEXTSHADOW] # Dark gray
    end
  else # VX windowskin
    color=windowskin.get_pixel(64, 96)
    shadow=nil
    isdark=(color.red+color.green+color.blue)/3 < 128
    if isdark
      shadow=Color.new(color.red+64,color.green+64,color.blue+64)
    else
      shadow=Color.new(color.red-64,color.green-64,color.blue-64)
    end
    return [color,shadow]
  end
end

def pbDoEnsureBitmap(bitmap,dwidth,dheight)
  if !bitmap || bitmap.disposed? || bitmap.width<dwidth || bitmap.height<dheight
    oldfont=(bitmap && !bitmap.disposed?) ? bitmap.font : nil
    bitmap.dispose if bitmap
    bitmap=Bitmap.new([1,dwidth].max,[1,dheight].max)
    if !oldfont
      pbSetSystemFont(bitmap)
    else
      bitmap.font=oldfont
    end
    if bitmap.font && bitmap.font.respond_to?("shadow")
      bitmap.font.shadow=false
    end
  end
  return bitmap
end

def pbUpdateSpriteHash(windows)
  for i in windows
    window=i[1]
    if window 
      if window.is_a?(Sprite) || window.is_a?(Window)
        window.update if !pbDisposed?(window)
      elsif window.is_a?(Plane)
        begin
          window.update if !window.disposed?
        rescue NoMethodError
        end
      elsif window.respond_to?("update")
        begin
          window.update
        rescue RGSSError
        end
      end
    end
  end
end

# Disposes all objects in the specified hash.
def pbDisposeSpriteHash(sprites)
  if sprites
    for i in sprites.keys
      pbDisposeSprite(sprites,i)
    end
    sprites.clear
  end
end

# Disposes the specified graphics object within the specified hash. Basically like:
#   sprites[id].dispose
def pbDisposeSprite(sprites,id)
  sprite=sprites[id]
  if sprite && !pbDisposed?(sprite)
    sprite.dispose
  end
  sprites[id]=nil
end

# Draws text on a bitmap. _textpos_ is an array
# of text commands. Each text command is an array
# that contains the following:
#  0 - Text to draw
#  1 - X coordinate
#  2 - Y coordinate
#  3 - If true or 1, the text is right aligned. If 2, the text is centered.
#   Otherwise, the text is left aligned.
#  4 - Base color
#  5 - Shadow color
def pbDrawTextPositions(bitmap,textpos)
  for i in textpos
    textsize=bitmap.text_size(i[0])
    x=i[1]
    y=i[2]
    if i[3]==true || i[3]==1 # right align
      x-=textsize.width
    elsif i[3]==2 # centered
      x-=(textsize.width/2)
    end
    if i[6]==true || i[6]==1 # outline text
      pbDrawOutlineText(bitmap,x,y,textsize.width,textsize.height,i[0],i[4],i[5])
    else
      pbDrawShadowText(bitmap,x,y,textsize.width,textsize.height,i[0],i[4],i[5])
    end
  end
end

def pbDrawImagePositions(bitmap,textpos)
  for i in textpos
    srcbitmap=AnimatedBitmap.new(pbBitmapName(i[0]))
    x=i[1]
    y=i[2]
    srcx=i[3]
    srcy=i[4]
    width=i[5]>=0 ? i[5] : srcbitmap.width
    height=i[6]>=0 ? i[6] : srcbitmap.height
    srcrect=Rect.new(srcx,srcy,width,height)
    bitmap.blt(x,y,srcbitmap.bitmap,srcrect)
    srcbitmap.dispose
  end
end

def pbDrawImagePositions2(bitmap,textpos,blend=nil)
  for i in textpos
    srcbitmap=AnimatedBitmap.new(pbBitmapName(i[0]))
    x=i[1]-srcbitmap.width/8
    y=i[2]-srcbitmap.height/8
    srcx=i[3]
    srcy=i[4]
    width=srcbitmap.width/4
    height=srcbitmap.height/4
    srcrect=Rect.new(srcx,srcy,width,height)
    srcbitmap.blend_type = 1 if blend
    bitmap.blt(x,y,srcbitmap.bitmap,srcrect)
    srcbitmap.dispose
  end
end

class Game_Temp
  attr_accessor :fadestate

  def fadestate
    return (@fadestate) ? @fadestate : 0
  end
end

def pbPushFade
  $game_temp.fadestate = [$game_temp.fadestate+1,0].max if $game_temp
end

def pbPopFade
  $game_temp.fadestate = [$game_temp.fadestate-1,0].max if $game_temp
end

def pbIsFaded?
  return ($game_temp) ? $game_temp.fadestate>0 : false
end

# pbFadeOutIn(z) { block }
# Fades out the screen before a block is run and fades it back in after the
# block exits.  z indicates the z-coordinate of the viewport used for this effect
def pbFadeOutIn(z)
  col=Color.new(0,0,0,0)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=z
  for j in 0..17
    col.set(0,0,0,j*15)
    viewport.color=col
    Graphics.update
    Input.update
  end
  pbPushFade
  begin
    yield if block_given?
  ensure
    pbPopFade
    for j in 0..17
      col.set(0,0,0,(17-j)*15)
      viewport.color=col
      Graphics.update
      Input.update
    end
    viewport.dispose
  end
end

def pbFadeOutAndHide(sprites)
  visiblesprites={}
  pbDeactivateWindows(sprites){
     for j in 0..17
       pbSetSpritesToColor(sprites,Color.new(0,0,0,j*15))
       block_given? ? yield : pbUpdateSpriteHash(sprites)
     end
  }
  for i in sprites
    next if !i[1]
    next if pbDisposed?(i[1])
    visiblesprites[i[0]]=true if i[1].visible
    i[1].visible=false
  end
  return visiblesprites
end

def pbFadeInAndShow(sprites,visiblesprites=nil)
  if visiblesprites
    for i in visiblesprites
      if i[1] && sprites[i[0]] && !pbDisposed?(sprites[i[0]])
        sprites[i[0]].visible=true
      end
    end
  end
  pbDeactivateWindows(sprites){
     for j in 0..17
       pbSetSpritesToColor(sprites,Color.new(0,0,0,((17-j)*15)))
       block_given? ? yield : pbUpdateSpriteHash(sprites)
     end 
  }
end

# Restores which windows are active for the given sprite hash.
# _activeStatuses_ is the result of a previous call to pbActivateWindows
def pbRestoreActivations(sprites,activeStatuses)
  return if !sprites || !activeStatuses
  for k in activeStatuses.keys
    if sprites[k] && sprites[k].is_a?(Window) && !pbDisposed?(sprites[k])
      sprites[k].active=activeStatuses[k] ? true : false
    end
  end
end

# Deactivates all windows. If a code block is given, deactivates all windows,
# runs the code in the block, and reactivates them.
def pbDeactivateWindows(sprites)
  if block_given?
    pbActivateWindow(sprites,nil) { yield }
  else
    pbActivateWindow(sprites,nil)
  end
end

# Activates a specific window of a sprite hash. _key_ is the key of the window
# in the sprite hash. If a code block is given, deactivates all windows except
# the specified window, runs the code in the block, and reactivates them.
def pbActivateWindow(sprites,key)
  return if !sprites
  activeStatuses={}
  for i in sprites
    if i[1] && i[1].is_a?(Window) && !pbDisposed?(i[1])
      activeStatuses[i[0]]=i[1].active
      i[1].active=(i[0]==key)
    end
  end
  if block_given?
    begin; yield; ensure
      pbRestoreActivations(sprites,activeStatuses)
    end
    return {}
  else
    return activeStatuses
  end
end

def pbAlphaBlend(dstColor,srcColor)
  r=(255*(srcColor.red-dstColor.red)/255)+dstColor.red
  g=(255*(srcColor.green-dstColor.green)/255)+dstColor.green
  b=(255*(srcColor.blue-dstColor.blue)/255)+dstColor.blue
  a=(255*(srcColor.alpha-dstColor.alpha)/255)+dstColor.alpha
  return Color.new(r,g,b,a)
end

def pbSrcOver(dstColor,srcColor)
  er=srcColor.red*srcColor.alpha/255
  eg=srcColor.green*srcColor.alpha/255
  eb=srcColor.blue*srcColor.alpha/255
  iea=255-srcColor.alpha
  cr=dstColor.red*dstColor.alpha/255
  cg=dstColor.green*dstColor.alpha/255
  cb=dstColor.blue*dstColor.alpha/255
  ica=255-dstColor.alpha
  a=255-(iea*ica)/255
  r=(iea*cr)/255+er
  g=(iea*cg)/255+eg
  b=(iea*cb)/255+eb
  r=(a==0) ? 0 : r*255/a
  g=(a==0) ? 0 : g*255/a
  b=(a==0) ? 0 : b*255/a
  return Color.new(r,g,b,a)
end

def pbSetSpritesToColor(sprites,color)
  return if !sprites||!color
  colors={}
  for i in sprites
    next if !i[1] || pbDisposed?(i[1])
    colors[i[0]]=i[1].color.clone
    i[1].color=pbSrcOver(i[1].color,color)
  end
  Graphics.update
  Input.update
  for i in colors
    next if !sprites[i[0]]
    sprites[i[0]].color=i[1]
  end
end

def pbTryString(x)
  ret=pbGetFileChar(x)
  return (ret!=nil && ret!="") ? x : nil
end

# Finds the real path for an image file.  This includes paths in encrypted
# archives.  Returns _x_ if the path can't be found.
def pbBitmapName(x)
  ret=pbResolveBitmap(x)
  return ret ? ret : x
end

# Finds the real path for an image file.  This includes paths in encrypted
# archives.  Returns nil if the path can't be found.
def pbResolveBitmap(x)
  return nil if !x
  noext=x.gsub(/\.(bmp|png|gif|jpg|jpeg)$/,"")
  filename=nil
#  RTP.eachPathFor(x) {|path|
#     filename=pbTryString(path) if !filename
#     filename=pbTryString(path+".gif") if !filename
#  }
  RTP.eachPathFor(noext) {|path|
     filename=pbTryString(path+".png") if !filename
     filename=pbTryString(path+".gif") if !filename
#     filename=pbTryString(path+".jpg") if !filename
#     filename=pbTryString(path+".jpeg") if !filename
#     filename=pbTryString(path+".bmp") if !filename
  }
  return filename
end

# Adds a background to the sprite hash.
# _planename_ is the hash key of the background.
# _background_ is a filename within the Graphics/Pictures/ folder and can be
#     an animated image.
# _viewport_ is a viewport to place the background in.
def addBackgroundPlane(sprites,planename,background,viewport=nil)
  sprites[planename]=AnimatedPlane.new(viewport)
  bitmapName=pbResolveBitmap("Graphics/Pictures/#{background}")
  if bitmapName==nil
    # Plane should exist in any case
    sprites[planename].bitmap=nil
    sprites[planename].visible=false
  else
    sprites[planename].setBitmap(bitmapName)
    for spr in sprites.values
      if spr.is_a?(Window)
        spr.windowskin=nil
      end
    end
  end
end

# Adds a background to the sprite hash.
# _planename_ is the hash key of the background.
# _background_ is a filename within the Graphics/Pictures/ folder and can be
#       an animated image.
# _color_ is the color to use if the background can't be found.
# _viewport_ is a viewport to place the background in.
def addBackgroundOrColoredPlane(sprites,planename,background,color,viewport=nil)
  # Needed for Reborn, why was this commented out?
  #return if GAMETITLE != "Pokemon Reborn"
  bitmapName=pbResolveBitmap("Graphics/Pictures/#{background}")
  if bitmapName==nil
    # Plane should exist in any case
    sprites[planename]=ColoredPlane.new(color,viewport)
  else
    sprites[planename]=AnimatedPlane.new(viewport)
    sprites[planename].setBitmap(bitmapName)
    for spr in sprites.values
      if spr.is_a?(Window)
        spr.windowskin=nil
      end
    end
  end
end

# Sets a bitmap's font to the system font.
def pbSetSystemFont(bitmap)
  fontname=MessageConfig.pbGetSystemFontName()
  bitmap.font.name=fontname
  if fontname=="Pokemon FireLeaf" || fontname=="Power Red and Green"
    bitmap.font.size=29
  elsif fontname=="Pokemon Emerald Small" || fontname=="Power Green Small"
    bitmap.font.size=25
  else
    bitmap.font.size=36
  end
end

# Gets the name of the system small font.
def pbSmallFontName()
  if $game_switches
    if $game_switches[:Wing_Dings]
      return "Untitled1"
    end
  end
  return MessageConfig.pbTryFonts("Power Green Small","Pokemon Emerald Small",
     "Arial Narrow","Arial")
end

# Gets the name of the system narrow font.
def pbNarrowFontName()
  if $game_switches
    if $game_switches[:Wing_Dings]
      return "Untitled1"
    end
  end
  return MessageConfig.pbTryFonts("Power Green Narrow","Pokemon Emerald Narrow",
     "Arial Narrow","Arial")
end


# Sets a bitmap's font to the system small font.
def pbSetSmallFont(bitmap)
  bitmap.font.name=pbSmallFontName()
  bitmap.font.size=25
end

# Sets a bitmap's font to the system narrow font.
def pbSetNarrowFont(bitmap)
  bitmap.font.name=pbNarrowFontName()
  bitmap.font.size=31
end



################################################################################
# SpriteWrapper is a class based on Sprite which wraps Sprite's properties.
################################################################################
class SpriteWrapper < Sprite
  def initialize(viewport=nil)
    @sprite=Sprite.new(viewport)
  end

  def dispose
    @sprite.dispose
  end

  def disposed?
    return @sprite.disposed?
  end

  def viewport
    return @sprite.viewport
  end

  def flash(color,duration)
    return @sprite.flash(color,duration)
  end

  def update
    return @sprite.update
  end

  def x
    @sprite.x
  end

  def x=(value)
    @sprite.x=value
  end

  def y
    @sprite.y
  end

  def y=(value)
    @sprite.y=value
  end

  def bitmap
    @sprite.bitmap
  end

  def bitmap=(value)
    @sprite.bitmap=value
  end

  def src_rect
    @sprite.src_rect
  end

  def src_rect=(value)
    @sprite.src_rect=value
  end

  def visible
    @sprite.visible
  end

  def visible=(value)
    @sprite.visible=value
  end

  def z
    @sprite.z
  end

  def z=(value)
    @sprite.z=value
  end

  def ox
    @sprite.ox
  end

  def ox=(value)
    @sprite.ox=value
  end

  def oy
    @sprite.oy
  end

  def oy=(value)
    @sprite.oy=value
  end

  def zoom_x
    @sprite.zoom_x
  end

  def zoom_x=(value)
    @sprite.zoom_x=value
  end

  def zoom_y
    @sprite.zoom_y
  end

  def zoom_y=(value)
    @sprite.zoom_y=value
  end

  def angle
    @sprite.angle
  end

  def angle=(value)
    @sprite.angle=value
  end

  def mirror
    @sprite.mirror
  end

  def mirror=(value)
    @sprite.mirror=value
  end

  def bush_depth
    @sprite.bush_depth
  end

  def bush_depth=(value)
    @sprite.bush_depth=value
  end

  def opacity
    @sprite.opacity
  end

  def opacity=(value)
    @sprite.opacity=value
  end

  def blend_type
    @sprite.blend_type
  end

  def blend_type=(value)
    @sprite.blend_type=value
  end

  def color
    @sprite.color
  end

  def color=(value)
    @sprite.color=value
  end

  def tone
    @sprite.tone
  end

  def tone=(value)
    @sprite.tone=value
  end

  def viewport=(value)
    return if self.viewport==value
    bitmap=@sprite.bitmap
    src_rect=@sprite.src_rect
    visible=@sprite.visible
    x=@sprite.x
    y=@sprite.y
    z=@sprite.z
    ox=@sprite.ox
    oy=@sprite.oy
    zoom_x=@sprite.zoom_x
    zoom_y=@sprite.zoom_y
    angle=@sprite.angle
    mirror=@sprite.mirror
    bush_depth=@sprite.bush_depth
    opacity=@sprite.opacity
    blend_type=@sprite.blend_type
    color=@sprite.color
    tone=@sprite.tone
    @sprite.dispose
    @sprite=Sprite.new(value)
    @sprite.bitmap=bitmap
    @sprite.src_rect=src_rect
    @sprite.visible=visible
    @sprite.x=x
    @sprite.y=y
    @sprite.z=z
    @sprite.ox=ox
    @sprite.oy=oy
    @sprite.zoom_x=zoom_x
    @sprite.zoom_y=zoom_y
    @sprite.angle=angle
    @sprite.mirror=mirror
    @sprite.bush_depth=bush_depth
    @sprite.opacity=opacity
    @sprite.blend_type=blend_type
    @sprite.color=color
    @sprite.tone=tone
  end
end


# Used to determine whether a data file exists (rather than a graphics or
# audio file). Doesn't check RTP, but does check encrypted archives.
def pbRgssExists?(filename)
  filename=canonicalize(filename)
  if (safeExists?("./Game.rgssad") || safeExists?("./Game.rgss2a"))
    return pbGetFileChar(filename)!=nil
  else
    return safeExists?(filename)
  end
end

# Opens an IO, even if the file is in an encrypted archive.
# Doesn't check RTP for the file.
def pbRgssOpen(file,mode=nil)
  #File.open("debug.txt","ab"){|fw| fw.write([file,mode,Time.now.to_f].inspect+"\r\n") }
  if !safeExists?("./Game.rgssad") && !safeExists?("./Game.rgss2a")
    if block_given?
      File.open(file,mode){|f| yield f }
      return nil
    else
      return File.open(file,mode)
    end
  end
  file=canonicalize(file)
  Marshal.neverload=true
  begin
    str=load_data(file)
  ensure
    Marshal.neverload=false
  end
  if block_given?
    StringInput.open(str){|f| yield f }
    return nil
  else
    return StringInput.open(str)
  end
end

# Gets at least the first byte of a file. Doesn't check RTP, but does check
# encrypted archives.
def pbGetFileChar(file)
  file=canonicalize(file)
  if !(safeExists?("./Game.rgssad") || safeExists?("./Game.rgss2a"))
    return nil if !safeExists?(file)
    begin
      File.open(file,"rb"){|f|
         return f.read(1) # read one byte
      }
    rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES, Errno::EISDIR
      return nil
    end
  end
  Marshal.neverload=true
  str=nil
  begin
    str=load_data(file)
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES, RGSSError
    str=nil
  ensure
    Marshal.neverload=false
  end
  return str
end

# Gets the contents of a file. Doesn't check RTP, but does check
# encrypted archives.
def pbGetFileString(file)
  file=canonicalize(file)
  if !(safeExists?("./Game.rgssad") || safeExists?("./Game.rgss2a"))
    return nil if !safeExists?(file)
    begin
      File.open(file,"rb"){|f|
         return f.read # read all data
      }
    rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES, Errno::EISDIR
      return nil
    end
  end
  Marshal.neverload=true
  str=nil
  begin
    str=load_data(file)
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES, RGSSError
    str=nil
  ensure
    Marshal.neverload=false
  end
  return str
end



#===============================================================================
# SpriteWindow is a class based on Window which emulates Window's functionality.
# This class is necessary in order to change the viewport of windows (with
# viewport=) and to make windows fade in and out (with tone=).
#===============================================================================
class SpriteWindowCursorRect < Rect
  def initialize(window)
    super(0,0,0,0)
    @window=window
  end

  def empty
    needupdate=@x!=0 || @y!=0 || @width!=0 || @height!=0
    if needupdate
      @x=0
      @y=0
      @width=0
      @height=0
      @window.width=@window.width
    end
  end

  def isEmpty?
    return @x==0 && @y==0 && @width==0 && @height==0
  end

  def set(x,y,width,height)
    needupdate=@x!=x || @y!=y || @width!=width || @height!=height
    if needupdate
      @x=x
      @y=y
      @width=width
      @height=height
      @window.width=@window.width
    end
  end

  def height=(value)
    @height=value; @window.width=@window.width
  end

  def width=(value)
    @width=value; @window.width=@window.width
  end

  def x=(value)
    @x=value; @window.width=@window.width
  end

  def y=(value)
    @y=value; @window.width=@window.width
  end
end



class SpriteWindow < Window
  attr_reader :tone
  attr_reader :color
  attr_reader :viewport
  attr_reader :contents
  attr_reader :ox
  attr_reader :oy
  attr_reader :x
  attr_reader :y
  attr_reader :z
  attr_reader :zoom_x
  attr_reader :zoom_y
  attr_reader :offset_x
  attr_reader :offset_y
  attr_reader :width
  attr_reader :active
  attr_reader :pause
  attr_reader :height
  attr_reader :opacity
  attr_reader :back_opacity
  attr_reader :contents_opacity
  attr_reader :visible
  attr_reader :cursor_rect
  attr_reader :contents_blend_type
  attr_reader :blend_type
  attr_reader :openness

  def windowskin
    @_windowskin
  end

  # Flags used to preserve compatibility
  # with RGSS/RGSS2's version of Window
  module CompatBits 
    CorrectZ=1
    ExpandBack=2
    ShowScrollArrows=4
    StretchSides=8
    ShowPause=16
    ShowCursor=32
  end

  attr_reader :compat

  def compat=(value)
    @compat=value
    privRefresh(true)
  end

  def initialize(viewport=nil)
    @sprites={}
    @spritekeys=[
       "back",
       "corner0","side0","scroll0",
       "corner1","side1","scroll1",
       "corner2","side2","scroll2",
       "corner3","side3","scroll3",
       "cursor","contents","pause"
    ]
    @viewport=viewport
    @sidebitmaps=[nil,nil,nil,nil]
    @cursorbitmap=nil
    @bgbitmap=nil
    for i in @spritekeys
      @sprites[i]=Sprite.new(@viewport)
    end
    @disposed=false
    @tone=Tone.new(0,0,0)
    @color=Color.new(0,0,0,0)
    @blankcontents=Bitmap.new(1,1) # RGSS2 requires this
    @contents=@blankcontents
    @_windowskin=nil
    @rpgvx=false
    @compat=CompatBits::ExpandBack|CompatBits::StretchSides
    @x=0
    @y=0
    @width=0
    @height=0
    @offset_x=0
    @offset_y=0
    @zoom_x=1.0
    @zoom_y=1.0
    @ox=0
    @oy=0
    @z=0
    @stretch=true
    @visible=true
    @active=true
    @openness=255
    @opacity=255
    @back_opacity=255
    @blend_type=0
    @contents_blend_type=0
    @contents_opacity=255
    @cursor_rect=SpriteWindowCursorRect.new(self)
    @cursorblink=0
    @cursoropacity=255
    @pause=false
    @pauseframe=0
    @flash=0
    @pauseopacity=0
    @skinformat=0
    @skinrect=Rect.new(0,0,0,0)
    @trim=[16,16,16,16]
    privRefresh(true)
  end

  def dispose
    if !self.disposed?
      for i in @sprites
        i[1].dispose if i[1]
        @sprites[i[0]]=nil
      end
      for i in 0...@sidebitmaps.length
        @sidebitmaps[i].dispose if @sidebitmaps[i]
        @sidebitmaps[i]=nil
      end
      @blankcontents.dispose
      @cursorbitmap.dispose if @cursorbitmap
      @backbitmap.dispose if @backbitmap
      @sprites.clear
      @sidebitmaps.clear
      @_windowskin=nil
      @disposed=true
    end
  end

  def stretch=(value)
    @stretch=value
    privRefresh(true)
  end

  def visible=(value)
    @visible=value
    privRefresh
  end

  def viewport=(value)
    @viewport=value
    for i in @spritekeys
      @sprites[i].dispose if @sprites[i]
    end
    for i in @spritekeys
      if @sprites[i].is_a?(Sprite)
        @sprites[i]=Sprite.new(@viewport)
      else
        @sprites[i]=nil
      end
    end
    privRefresh(true)
  end

  def z=(value)
    @z=value
    privRefresh
  end

  def disposed?
    return @disposed
  end

  def contents=(value)
    if @contents!=value
      @contents=value
      privRefresh if @visible
    end
  end

  def ox=(value)
    if @ox!=value
      @ox=value
      privRefresh if @visible
    end
  end

  def oy=(value)
    if @oy!=value
      @oy=value
      privRefresh if @visible
    end
  end

  def active=(value)
     @active=value
     privRefresh(true)
  end

  def cursor_rect=(value)
    if !value
      @cursor_rect.empty
    else
      @cursor_rect.set(value.x,value.y,value.width,value.height)
    end
  end

  def openness=(value)
    @openness=value
    @openness=0 if @openness<0
    @openness=255 if @openness>255
    privRefresh
  end
  
  def pause=(value)
    @pause=value
    @pauseopacity=0 if !value
    privRefresh if @visible
  end
  
  def width=(value)
    @width=value
    privRefresh(true)
  end

  def height=(value)
    @height=value
    privRefresh(true)
  end

  #bulk variable setting functions: for when it's not necessary to refresh every time
  
  def height_width(hi,wi)
    @height=hi
    @width=wi
    privRefresh(true)
  end
  
  def setXYZ(ecks,why,zee=nil)
    @x=ecks
    @y=why
    @z=zee
    privRefreshOnlyHW_XYZ
  end
  
  def setHW_XYZ(hi,wi,ecks,why,zee=nil)
    @x=ecks
    @y=why
    @z=zee if zee
    @height=hi
    @width=wi
    privRefreshOnlyHW_XYZ(true)
  end
    
  def x=(value)
    @x=value
    privRefresh if @visible
  end

  def y=(value)
    @y=value
    privRefresh if @visible
  end

  def zoom_x=(value)
    @zoom_x=value
    privRefresh if @visible
  end

  def zoom_y=(value)
    @zoom_y=value
    privRefresh if @visible
  end

  def offset_x=(value)
    @x=value
    privRefresh if @visible
  end

  def offset_y=(value)
    @y=value
    privRefresh if @visible
  end

  def opacity=(value)
    @opacity=value
    @opacity=0 if @opacity<0
    @opacity=255 if @opacity>255
    privRefresh if @visible
  end

  def back_opacity=(value)
    @back_opacity=value
    @back_opacity=0 if @back_opacity<0
    @back_opacity=255 if @back_opacity>255
    privRefresh if @visible
  end

  def contents_opacity=(value)
    @contents_opacity=value
    @contents_opacity=0 if @contents_opacity<0
    @contents_opacity=255 if @contents_opacity>255
    privRefresh if @visible
  end

  def tone=(value)
    @tone=value
    privRefresh if @visible
  end

  def color=(value)
    @color=value
    privRefresh if @visible
  end

  def blend_type=(value)
    @blend_type=value
    privRefresh if @visible
  end

  def flash(color,duration)
    return if disposed?
    @flash=duration+1
    for i in @sprites
      i[1].flash(color,duration)
    end
  end

  def update
    return if disposed?
    mustchange=false
    if @active
      if @cursorblink==0
        @cursoropacity-=8
        @cursorblink=1 if @cursoropacity<=128
      else
        @cursoropacity+=8
        @cursorblink=0 if @cursoropacity>=255
      end
      privRefreshCursor
    else
      @cursoropacity=128
      privRefreshCursor
    end
    if @pause
      oldpauseframe=@pauseframe
      oldpauseopacity=@pauseopacity
      @pauseframe=(Graphics.frame_count / 8) % 4
      @pauseopacity=[@pauseopacity+64,255].min
      mustchange=@pauseframe!=oldpauseframe || @pauseopacity!=oldpauseopacity
    end
    privRefresh if mustchange
    if @flash>0
      for i in @sprites.values
        i.update
      end
      @flash-=1
    end
  end

  #############
  attr_reader :skinformat
  attr_reader :skinrect

  def loadSkinFile(file)
    if (self.windowskin.width==80 || self.windowskin.width==96) &&
       self.windowskin.height==48
      # Body = X, Y, width, height of body rectangle within windowskin
      @skinrect.set(32,16,16,16)
      # Trim = X, Y, width, height of trim rectangle within windowskin
      @trim=[32,16,16,16]
    elsif self.windowskin.width==80 && self.windowskin.height==80
      @skinrect.set(32,32,16,16)
      @trim=[32,16,16,48]
    end
  end

  def windowskin=(value)
    oldSkinWidth=(@_windowskin && !@_windowskin.disposed?) ? @_windowskin.width : -1
    oldSkinHeight=(@_windowskin && !@_windowskin.disposed?) ? @_windowskin.height : -1
    @_windowskin=value
    if @skinformat==1
      @rpgvx=false
      if @_windowskin && !@_windowskin.disposed?
        if @_windowskin.width!=oldSkinWidth || @_windowskin.height!=oldSkinHeight
          # Update skinrect and trim if windowskin's dimensions have changed
          @skinrect.set((@_windowskin.width-16)/2,(@_windowskin.height-16)/2,16,16)
          @trim=[@skinrect.x,@skinrect.y,@skinrect.x,@skinrect.y]
        end
      else
        @skinrect.set(16,16,16,16)
        @trim=[16,16,16,16]
      end
    else
      @trim=[16,16,16,16]
    end
    privRefresh(true)
  end

  def skinrect=(value)
    @skinrect=value
    privRefresh
  end

  def skinformat=(value)
    if @skinformat!=value
      @skinformat=value  
      privRefresh(true)
    end
  end

  def borderX
    return 32 if !@trim || skinformat==0
    if @_windowskin && !@_windowskin.disposed?
      return @trim[0]+(@_windowskin.width-@trim[2]-@trim[0])
    end
    return 32
  end

  def borderY
    return 32 if !@trim || skinformat==0
    if @_windowskin && !@_windowskin.disposed?
      return @trim[1]+(@_windowskin.height-@trim[3]-@trim[1])
    end
    return 32
  end

  def leftEdge; self.startX; end
  def topEdge; self.startY; end
  def rightEdge; self.borderX-self.leftEdge; end
  def bottomEdge; self.borderY-self.topEdge; end

  def startX
    return !@trim || skinformat==0  ? 16 : @trim[0]
  end

  def startY
    return !@trim || skinformat==0  ? 16 : @trim[1]
  end

  def endX
    return !@trim || skinformat==0  ? 16 : @trim[2]
  end

  def endY
    return !@trim || skinformat==0  ? 16 : @trim[3]
  end

  def startX=(value)
    @trim[0]=value
    privRefresh
  end

  def startY=(value)
    @trim[1]=value
    privRefresh
  end

  def endX=(value)
    @trim[2]=value
    privRefresh
  end

  def endY=(value)
    @trim[3]=value
    privRefresh
  end

  #############
  private

  def ensureBitmap(bitmap,dwidth,dheight)
    if !bitmap||bitmap.disposed?||bitmap.width<dwidth||bitmap.height<dheight
      bitmap.dispose if bitmap
      bitmap=Bitmap.new([1,dwidth].max,[1,dheight].max)
    end
    return bitmap
  end

  def tileBitmap(dstbitmap,dstrect,srcbitmap,srcrect)
    return if !srcbitmap || srcbitmap.disposed?
    left=dstrect.x
    top=dstrect.y
    y=0;loop do break unless y<dstrect.height
      x=0;loop do break unless x<dstrect.width
        dstbitmap.blt(x+left,y+top,srcbitmap,srcrect)
        x+=srcrect.width
      end
     y+=srcrect.height
   end
 end

  def privRefreshCursor
    contopac=self.contents_opacity
    cursoropac=@cursoropacity*contopac/255
    @sprites["cursor"].opacity=cursoropac
  end

  def privRefreshOnlyHW_XYZ(changeBitmap=false)
    trimStartX=@trim[0]
    trimStartY=@trim[1]
    cx=@skinrect.x+@skinrect.width # right side of BODY rect
    cy=@skinrect.y+@skinrect.height # bottom side of BODY rect
    endX=(!@_windowskin || @_windowskin.disposed?) ? @skinrect.x : @_windowskin.width-cx
    endY=(!@_windowskin || @_windowskin.disposed?) ? @skinrect.y : @_windowskin.height-cy
    startX=@skinrect.x
    startY=@skinrect.y
    @sprites["contents"].x=@x+trimStartX
    @sprites["contents"].y=@y+trimStartY
    for i in @spritekeys
      @sprites[i].z=@z
    end
    if @_windowskin && !@_windowskin.disposed?
      backTrimX=startX+endX
      backTrimY=startX+endX
      @sprites["corner0"].x=@x
      @sprites["corner0"].y=@y
      @sprites["corner1"].x=@x+@width-endX
      @sprites["corner1"].y=@y
      @sprites["corner2"].x=@x
      @sprites["corner2"].y=@y+@height-endY
      @sprites["corner3"].x=@x+@width-endX
      @sprites["corner3"].y=@y+@height-endY
      @sprites["side0"].x=@x+startX
      @sprites["side0"].y=@y
      @sprites["side1"].x=@x
      @sprites["side1"].y=@y+startY
      @sprites["side2"].x=@x+@width-endX
      @sprites["side2"].y=@y+startY
      @sprites["side3"].x=@x+startX
      @sprites["side3"].y=@y+@height-endY
      @sprites["scroll0"].x = @x+@width / 2 - 8
      @sprites["scroll0"].y = @y+8
      @sprites["scroll1"].x = @x+8
      @sprites["scroll1"].y = @y+@height / 2 - 8
      @sprites["scroll2"].x = @x+@width - 16
      @sprites["scroll2"].y = @y+@height / 2 - 8
      @sprites["scroll3"].x = @x+@width / 2 - 8
      @sprites["scroll3"].y = @y+@height - 16
      @sprites["cursor"].x=@x+startX+@cursor_rect.x
      @sprites["cursor"].y=@y+startY+@cursor_rect.y
      if (@compat & CompatBits::ExpandBack)>0 && @skinformat==0
        # Compatibility mode: Expand background
        @sprites["back"].x=@x+2
        @sprites["back"].y=@y+2
      else
        @sprites["back"].x=@x+startX
        @sprites["back"].y=@y+startY
      end
    end
    for k in @spritekeys
      sprite=@sprites[k]
      y=sprite.y
      sprite.y=0
      sprite.oy=-y
      sprite.x+=@offset_x
      sprite.y+=@offset_y
    end
  end 
  
  def privRefresh(changeBitmap=false)
    return if !self || self.disposed?
    backopac=self.back_opacity*self.opacity/255
    contopac=self.contents_opacity
    cursoropac=@cursoropacity*contopac/255
    haveskin=@_windowskin && !@_windowskin.disposed?
    for i in 0...4
      @sprites["corner#{i}"].bitmap=@_windowskin
      @sprites["scroll#{i}"].bitmap=@_windowskin
    end
    @sprites["pause"].bitmap=@_windowskin
    @sprites["contents"].bitmap=@contents
    if haveskin
      for i in 0...4
        @sprites["corner#{i}"].opacity=@opacity
        @sprites["corner#{i}"].tone=@tone
        @sprites["corner#{i}"].color=@color
        @sprites["corner#{i}"].visible=@visible
        @sprites["corner#{i}"].blend_type=@blend_type
        @sprites["side#{i}"].opacity=@opacity
        @sprites["side#{i}"].tone=@tone
        @sprites["side#{i}"].color=@color
        @sprites["side#{i}"].blend_type=@blend_type
        @sprites["side#{i}"].visible=@visible
        @sprites["scroll#{i}"].opacity=@opacity
        @sprites["scroll#{i}"].tone=@tone
        @sprites["scroll#{i}"].color=@color
        @sprites["scroll#{i}"].visible=@visible
        @sprites["scroll#{i}"].blend_type=@blend_type
      end
      for i in ["back","cursor","pause","contents"]
        @sprites[i].color=@color
        @sprites[i].tone=@tone
        @sprites[i].blend_type=@blend_type
      end
      @sprites["contents"].blend_type=@contents_blend_type
      @sprites["back"].opacity=backopac
      @sprites["contents"].opacity=contopac
      @sprites["cursor"].opacity=cursoropac
      @sprites["pause"].opacity=@pauseopacity
      supported=(@skinformat==0)
      hascontents=(@contents && !@contents.disposed?)
      @sprites["back"].visible=@visible
      @sprites["contents"].visible=@visible && @openness==255
      @sprites["pause"].visible=supported && @visible && @pause && 
         (@combat & CompatBits::ShowPause)
      @sprites["cursor"].visible=supported && @visible && @openness==255 && 
         (@combat & CompatBits::ShowCursor)
      @sprites["scroll0"].visible = false
      @sprites["scroll1"].visible = false
      @sprites["scroll2"].visible = false
      @sprites["scroll3"].visible = false
    else
      for i in 0...4
        @sprites["corner#{i}"].visible=false
        @sprites["side#{i}"].visible=false
        @sprites["scroll#{i}"].visible=false
      end
      @sprites["contents"].visible=@visible && @openness==255
      @sprites["contents"].color=@color
      @sprites["contents"].tone=@tone
      @sprites["contents"].blend_type=@contents_blend_type
      @sprites["contents"].opacity=contopac
      @sprites["back"].visible=false
      @sprites["pause"].visible=false
      @sprites["cursor"].visible=false
    end
    for i in @spritekeys
      @sprites[i].z=@z
    end
    if (@compat & CompatBits::CorrectZ)>0 && @skinformat==0
      # Compatibility Mode: Cursor, pause, and contents have higher Z
      @sprites["cursor"].z=@z+1
      @sprites["contents"].z=@z+2
      @sprites["pause"].z=@z+2
    end
    if @skinformat==0
      startX=16
      startY=16
      endX=16
      endY=16
      trimStartX=16
      trimStartY=16
      trimWidth=32
      trimHeight=32
      trimX=128
      trimY=0
      backRect=Rect.new(0,0,128,128)
      blindsRect=nil
      if @_windowskin && !@_windowskin.disposed?
        @sprites["corner0"].src_rect.set(trimX,trimY+0,16,16);
        @sprites["corner1"].src_rect.set(trimX+48,trimY+0,16,16);
        @sprites["corner2"].src_rect.set(trimX,trimY+48,16,16);
        @sprites["corner3"].src_rect.set(trimX+48,trimY+48,16,16);
        @sprites["scroll0"].src_rect.set(trimX+24, trimY+16, 16, 8) # up
        @sprites["scroll3"].src_rect.set(trimX+24, trimY+40, 16, 8) # down
        @sprites["scroll1"].src_rect.set(trimX+16, trimY+24, 8, 16) # left
        @sprites["scroll2"].src_rect.set(trimX+40, trimY+24, 8, 16) # right
        cursorX=trimX
        cursorY=trimY+64
        sideRects=[
           Rect.new(trimX+16,trimY+0,32,16),
           Rect.new(trimX,trimY+16,16,32),
           Rect.new(trimX+48,trimY+16,16,32),
           Rect.new(trimX+16,trimY+48,32,16)
        ]
        pauseRects=[
           trimX+32,trimY+64,
           trimX+48,trimY+64,
           trimX+32,trimY+80,
           trimX+48,trimY+80,
        ]
        pauseWidth=16
        pauseHeight=16
        @sprites["pause"].src_rect.set(
           pauseRects[@pauseframe*2],
           pauseRects[@pauseframe*2+1],
           pauseWidth,pauseHeight
        )
      end
    else
      trimStartX=@trim[0]
      trimStartY=@trim[1]
      trimWidth=@trim[0]+(@skinrect.width-@trim[2]+@trim[0])
      trimHeight=@trim[1]+(@skinrect.height-@trim[3]+@trim[1])
      if @_windowskin && !@_windowskin.disposed?
        # width of left end of window
        startX=@skinrect.x
        # width of top end of window
        startY=@skinrect.y
        backWidth=@skinrect.width
        backHeight=@skinrect.height
        cx=@skinrect.x+@skinrect.width # right side of BODY rect
        cy=@skinrect.y+@skinrect.height # bottom side of BODY rect
        # width of right end of window
        endX=(!@_windowskin || @_windowskin.disposed?) ? @skinrect.x : @_windowskin.width-cx
        # height of bottom end of window
        endY=(!@_windowskin || @_windowskin.disposed?) ? @skinrect.y : @_windowskin.height-cy
        @sprites["corner0"].src_rect.set(0,0,startX,startY);
        @sprites["corner1"].src_rect.set(cx,0,endX,startY);
        @sprites["corner2"].src_rect.set(0,cy,startX,endY);
        @sprites["corner3"].src_rect.set(cx,cy,endX,endY);
        backRect=Rect.new(@skinrect.x,@skinrect.y,
           @skinrect.width,@skinrect.height);
        blindsRect=nil
        sideRects=[
           Rect.new(startX,0,@skinrect.width,startY),  # side0 (top)
           Rect.new(0,startY,startX,@skinrect.height), # side1 (left)
           Rect.new(cx,startY,endX,@skinrect.height),  # side2 (right)
           Rect.new(startX,cy,@skinrect.width,endY)    # side3 (bottom)
        ]
      end
    end
    if @width>trimWidth && @height>trimHeight
      @sprites["contents"].src_rect.set(@ox,@oy,@width-trimWidth,@height-trimHeight)
    else
      @sprites["contents"].src_rect.set(0,0,0,0)
    end
    @sprites["contents"].x=@x+trimStartX
    @sprites["contents"].y=@y+trimStartY
    if (@compat & CompatBits::ShowScrollArrows)>0 && @skinformat==0
      # Compatibility mode: Make scroll arrows visible
      if @skinformat==0 && @_windowskin && !@_windowskin.disposed? && 
         @contents && !@contents.disposed?
        @sprites["scroll0"].visible = @visible && hascontents && @oy > 0
        @sprites["scroll1"].visible = @visible && hascontents && @ox > 0
        @sprites["scroll2"].visible = @visible && (@contents.width - @ox) > @width-trimWidth
        @sprites["scroll3"].visible = @visible && (@contents.height - @oy) > @height-trimHeight
      end
    end
    if @_windowskin && !@_windowskin.disposed?
      backTrimX=startX+endX
      backTrimY=startX+endX
      borderX=startX+endX
      borderY=startY+endY
      @sprites["corner0"].x=@x
      @sprites["corner0"].y=@y
      @sprites["corner1"].x=@x+@width-endX
      @sprites["corner1"].y=@y
      @sprites["corner2"].x=@x
      @sprites["corner2"].y=@y+@height-endY
      @sprites["corner3"].x=@x+@width-endX
      @sprites["corner3"].y=@y+@height-endY
      @sprites["side0"].x=@x+startX
      @sprites["side0"].y=@y
      @sprites["side1"].x=@x
      @sprites["side1"].y=@y+startY
      @sprites["side2"].x=@x+@width-endX
      @sprites["side2"].y=@y+startY
      @sprites["side3"].x=@x+startX
      @sprites["side3"].y=@y+@height-endY
      @sprites["scroll0"].x = @x+@width / 2 - 8
      @sprites["scroll0"].y = @y+8
      @sprites["scroll1"].x = @x+8
      @sprites["scroll1"].y = @y+@height / 2 - 8
      @sprites["scroll2"].x = @x+@width - 16
      @sprites["scroll2"].y = @y+@height / 2 - 8
      @sprites["scroll3"].x = @x+@width / 2 - 8
      @sprites["scroll3"].y = @y+@height - 16
      @sprites["cursor"].x=@x+startX+@cursor_rect.x
      @sprites["cursor"].y=@y+startY+@cursor_rect.y
      if (@compat & CompatBits::ExpandBack)>0 && @skinformat==0
        # Compatibility mode: Expand background
        @sprites["back"].x=@x+2
        @sprites["back"].y=@y+2
      else
        @sprites["back"].x=@x+startX
        @sprites["back"].y=@y+startY
      end
    end
    if changeBitmap && @_windowskin && !@_windowskin.disposed?
      if @skinformat==0
        @sprites["cursor"].x=@x+startX+@cursor_rect.x
        @sprites["cursor"].y=@y+startY+@cursor_rect.y
        width=@cursor_rect.width
        height=@cursor_rect.height
        if width > 0 && height > 0
          cursorrects=[
             # sides
             Rect.new(cursorX+2, cursorY+0, 28, 2),
             Rect.new(cursorX+0, cursorY+2, 2, 28),
             Rect.new(cursorX+30, cursorY+2, 2, 28),
             Rect.new(cursorX+2, cursorY+30, 28, 2),
             # corners
             Rect.new(cursorX+0, cursorY+0, 2, 2),
             Rect.new(cursorX+30, cursorY+0, 2, 2),
             Rect.new(cursorX+0, cursorY+30, 2, 2),
             Rect.new(cursorX+30, cursorY+30, 2, 2),
             # back
             Rect.new(cursorX+2, cursorY+2, 28, 28)
          ]
          margin=2
          fullmargin=4
          @cursorbitmap = ensureBitmap(@cursorbitmap, width, height)
          @cursorbitmap.clear
          @sprites["cursor"].bitmap=@cursorbitmap
          @sprites["cursor"].src_rect.set(0,0,width,height)
          rect = Rect.new(margin,margin,width - fullmargin, height - fullmargin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[8])
          @cursorbitmap.blt(0, 0, @_windowskin, cursorrects[4])# top left
          @cursorbitmap.blt(width-margin, 0, @_windowskin, cursorrects[5]) # top right
          @cursorbitmap.blt(0, height-margin, @_windowskin, cursorrects[6]) # bottom right
          @cursorbitmap.blt(width-margin, height-margin, @_windowskin, cursorrects[7]) # bottom left
          rect = Rect.new(margin, 0,width - fullmargin, margin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[0])
          rect = Rect.new(0, margin,margin, height - fullmargin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[1])
          rect = Rect.new(width - margin, margin, margin, height - fullmargin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[2])
          rect = Rect.new(margin, height-margin, width - fullmargin, margin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[3])
        else
          @sprites["cursor"].visible=false
          @sprites["cursor"].src_rect.set(0,0,0,0)
        end
      end
      for i in 0..3
        case i
          when 0
            dwidth=@width-startX-endX
            dheight=startY
          when 1
            dwidth=startX
            dheight=@height-startY-endY
          when 2
            dwidth=endX
            dheight=@height-startY-endY
          when 3
            dwidth=@width-startX-endX
            dheight=endY
        end
        @sidebitmaps[i]=ensureBitmap(@sidebitmaps[i],dwidth,dheight)
        @sprites["side#{i}"].bitmap=@sidebitmaps[i]
        @sprites["side#{i}"].src_rect.set(0,0,dwidth,dheight)
        @sidebitmaps[i].clear
        if sideRects[i].width>0 && sideRects[i].height>0
          if (@compat & CompatBits::StretchSides)>0 && @skinformat==0
            # Compatibility mode: Stretch sides
            @sidebitmaps[i].stretch_blt(@sprites["side#{i}"].src_rect,
               @_windowskin,sideRects[i])
          else
            tileBitmap(@sidebitmaps[i],@sprites["side#{i}"].src_rect,
               @_windowskin,sideRects[i])
          end
        end
      end
      if (@compat & CompatBits::ExpandBack)>0 && @skinformat==0
        # Compatibility mode: Expand background
        backwidth=@width-4
        backheight=@height-4
      else
        backwidth=@width-borderX
        backheight=@height-borderY
      end
      if backwidth>0 && backheight>0
        @backbitmap=ensureBitmap(@backbitmap,backwidth,backheight)
        @sprites["back"].bitmap=@backbitmap
        @sprites["back"].src_rect.set(0,0,backwidth,backheight)
        @backbitmap.clear
        if @stretch
          @backbitmap.stretch_blt(@sprites["back"].src_rect,@_windowskin,backRect)
        else
          tileBitmap(@backbitmap,@sprites["back"].src_rect,@_windowskin,backRect)
        end
        if blindsRect
          tileBitmap(@backbitmap,@sprites["back"].src_rect,@_windowskin,blindsRect)
        end
      else
        @sprites["back"].visible=false
        @sprites["back"].src_rect.set(0,0,0,0)
      end
    end
    if @openness!=255
      opn=@openness/255.0
      for k in @spritekeys
        sprite=@sprites[k]
        ratio=(@height<=0) ? 0 : (sprite.y-@y)*1.0/@height
        sprite.zoom_y=opn
        sprite.zoom_x=1.0
        sprite.oy=0
        sprite.y=(@y+(@height/2.0)+(@height*ratio*opn)-(@height/2*opn)).floor
        oldbitmap=sprite.bitmap
        oldsrcrect=sprite.src_rect.clone
      end
    else
      for k in @spritekeys
        sprite=@sprites[k]
        sprite.zoom_x=1.0
        sprite.zoom_y=1.0
      end
    end
    i=0
    # Ensure Z order
    for k in @spritekeys
      sprite=@sprites[k]
      y=sprite.y
      sprite.y=i
      sprite.oy=(sprite.zoom_y<=0) ? 0 : (i-y)/sprite.zoom_y
      sprite.zoom_x*=@zoom_x
      sprite.zoom_y*=@zoom_y
      sprite.x*=@zoom_x
      sprite.y*=@zoom_y
      sprite.x+=(@offset_x/sprite.zoom_x)
      sprite.y+=(@offset_y/sprite.zoom_y)
    end
  end
end



class SpriteWindow_Base < SpriteWindow
  TEXTPADDING=4 # In pixels

  def initialize(x, y, width, height)
    super()
    self.setHW_XYZ(height,width,x,y,100)
    @curframe=MessageConfig.pbGetSystemFrame()
    @curfont=MessageConfig.pbGetSystemFontName()
    @sysframe=AnimatedBitmap.new(@curframe)
    RPG::Cache.retain(@curframe) if @curframe && !@curframe.empty?
    @customskin=nil
    __setWindowskin(@sysframe.bitmap)
    __resolveSystemFrame()
    pbSetSystemFont(self.contents) if self.contents
  end

  def __setWindowskin(skin)
    if skin && (skin.width==192 && skin.height==128) ||  # RPGXP Windowskin
               (skin.width==128 && skin.height==128)     # RPGVX Windowskin
      self.skinformat=0
    else
      self.skinformat=1
    end
    self.windowskin=skin
  end

  def __resolveSystemFrame
    if self.skinformat==1
      if !@resolvedFrame
        @resolvedFrame=MessageConfig.pbGetSystemFrame()
        @resolvedFrame.sub!(/\.[^\.\/\\]+$/,"")
      end
      self.loadSkinFile("#{@resolvedFrame}.txt") if @resolvedFrame!=""
    end
  end

  def setSkin(skin) # Filename of windowskin to apply. Supports XP, VX, and animated skins.
    @customskin.dispose if @customskin
    @customskin=nil
    resolvedName=pbResolveBitmap(skin)
    return if !resolvedName || resolvedName==""
    @customskin=AnimatedBitmap.new(resolvedName)
    RPG::Cache.retain(resolvedName)
    __setWindowskin(@customskin.bitmap)
    if self.skinformat==1
      skinbase=resolvedName.sub(/\.[^\.\/\\]+$/,"")
      self.loadSkinFile("#{skinbase}.txt")
    end
  end

  def setSystemFrame
    @customskin.dispose if @customskin
    @customskin=nil
    __setWindowskin(@sysframe.bitmap)
    __resolveSystemFrame()
  end

  def update
    super
    if self.windowskin
      if @customskin
        if @customskin.totalFrames>1
          @customskin.update
          __setWindowskin(@customskin.bitmap)
        end
      elsif @sysframe
        if @sysframe.totalFrames>1
          @sysframe.update
          __setWindowskin(@sysframe.bitmap)
        end
      end
    end
    if @curframe!=MessageConfig.pbGetSystemFrame()
      @curframe=MessageConfig.pbGetSystemFrame()
      if @sysframe && !@customskin
        @sysframe.dispose if @sysframe
        @sysframe=AnimatedBitmap.new(@curframe)
        RPG::Cache.retain(@curframe) if @curframe && !@curframe.empty?
        @resolvedFrame=nil
        __setWindowskin(@sysframe.bitmap)
        __resolveSystemFrame()   
      end
      begin
        refresh
        rescue NoMethodError
      end
    end
    if @curfont!=MessageConfig.pbGetSystemFontName()
      @curfont=MessageConfig.pbGetSystemFontName()
      if self.contents && !self.contents.disposed?
        pbSetSystemFont(self.contents)
      end
      begin
        refresh
        rescue NoMethodError
      end
    end
  end

  def dispose
    self.contents.dispose if self.contents
    @sysframe.dispose
    @customskin.dispose if @customskin
    super
  end
end
