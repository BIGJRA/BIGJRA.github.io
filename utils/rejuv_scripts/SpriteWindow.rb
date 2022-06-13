module MessageConfig
  FontName        = "PokemonEmerald"
  # in Graphics/Windowskins/ (specify empty string to use the default windowskin)
  TextSkinName    = "speech hgss 1"
  ChoiceSkinName  = "choice 1"
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
     "Power Red and Blue"=>"Pokemon RS",
     "Power Red and Green"=>"Pokemon FireLeaf",
     "Power Green"=>"Pokemon Emerald",
     "Power Green Narrow"=>"Pokemon Emerald Narrow",
     "Power Green Small"=>"Pokemon Emerald Small",
     "Power Clear"=>"Pokemon DP"
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
    @@systemFont=MessageConfig.pbTryFonts(value,"Arial Narrow","Arial")
  end

  def self.pbSetTextSpeed(value)
    @@textSpeed=value-6
  end
end


#############################
#############################


# Works around a problem with FileTest.directory if directory contains accent marks
def safeIsDirectory?(f)
  ret=false
  Dir.chdir(f) { ret=true } rescue nil
  return ret
end

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

# Similar to "Dir.glob", but designed to work around a problem with accessing
# files if a path contains accent marks.
# "dir" is the directory path, "wildcard" is the filename pattern to match.
def safeGlob(dir,wildcard)
  ret=[]
  afterChdir=false
  begin
    Dir.chdir(dir){
       afterChdir=true
       Dir.glob(wildcard){|f|
          ret.push(dir+"/"+f)
       }
    }
    rescue Errno::ENOENT
    raise if afterChdir
  end
  if block_given?
    ret.each{|f|
       yield(f)
    }
  end
  return (block_given?) ? nil : ret
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
    
  #### StatBoosts - START
  def aSetBitmap(bitmap)
    @bitmap.aSetBitmap(bitmap)
  end
  #### StatBoosts - END
end

def pbGetTileBitmap(filename, tile_id, hue)
  if !filename.nil?
    return BitmapCache.tileEx(filename, tile_id, hue){|f|
      AnimatedBitmap.new("Graphics/Tilesets/"+filename).deanimate;
    }
  end
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
    return AnimatedBitmap.new("Graphics/Autotiles/"+name,hue).deanimate
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


#############################
#############################


if System.platform[/Windows/] # ~Zoro
module MiniRegistry
  HKEY_CLASSES_ROOT = 0x80000000
  HKEY_CURRENT_USER = 0x80000001
  HKEY_LOCAL_MACHINE = 0x80000002
  HKEY_USERS = 0x80000003
  FormatMessageA=Win32API.new("kernel32","FormatMessageA","LPLLPLP","L")
  RegOpenKeyExA=Win32API.new("advapi32","RegOpenKeyExA","LPLLP","L")
  RegCloseKey=Win32API.new("advapi32","RegCloseKey","L","L")
  RegQueryValueExA=Win32API.new("advapi32","RegQueryValueExA","LPLPPP","L")

  def self.open(hkey,subkey,bit64=false)
    key=0.chr*4
    flag=bit64 ? 0x20119 : 0x20019
    rg=RegOpenKeyExA.call(hkey, subkey, 0, flag, key)
    if rg!=0
      return nil
    end
    key=key.unpack("V")[0]
    if block_given?
      begin; yield(key)
      ensure; check(RegCloseKey.call(key)); end
    else
      return key
    end
  end

  def self.close(hkey); check(RegCloseKey.call(hkey)) if hkey; end

  def self.get(hkey,subkey,name,defaultValue=nil,bit64=false)
    self.open(hkey,subkey,bit64){|key| 
       return self.read(key,name) rescue defaultValue
    }
    return defaultValue
  end

  def self.read(hkey,name)
    hkey=0 if !hkey
    type=0.chr*4; size=0.chr*4
    check(RegQueryValueExA.call(hkey,name,0,type,0,size))
    data=" "*size.unpack("V")[0]
    check(RegQueryValueExA.call(hkey,name,0,type,data,size))
    type=type.unpack("V")[0]
    data=data[0,size.unpack("V")[0]]
    case type
      when 1; return data.chop # REG_SZ
      when 2; return data.gsub(/%([^%]+)%/) { ENV[$1] || $& } # REG_EXPAND_SZ
      when 3; return data # REG_BINARY
      when 4; return data.unpack("V")[0] # REG_DWORD
      when 5; return data.unpack("V")[0] # REG_DWORD_BIG_ENDIAN
      when 11; qw=data.unpack("VV"); return (data[1]<<32|data[0]) # REG_QWORD
      else; raise "Type #{type} not supported."
    end
  end

  private

  def self.check(code)
    if code!=0
      msg="\0"*1024
      len = FormatMessageA.call(0x1200, 0, code, 0, msg, 1024, 0)
      raise msg[0, len].tr("\r", '').chomp
    end
  end
end
end # if System.platform[/Windows/]

def nil_or_empty?(string)
  return string.nil? || !string.is_a?(String) || string.size == 0
end

module RTP
  @rtpPaths = nil
  
  def nil_or_empty?(string)
    return string.nil? || !string.is_a?(String) || string.size == 0
  end
  
  def self.exists?(filename,extensions=[])
    return false if nil_or_empty?(filename)
    eachPathFor(filename) { |path|
      return true if safeExists?(path)
      for ext in extensions
        return true if safeExists?(path+ext)
      end
    }
    return false
  end

  def self.getImagePath(filename)
    return self.getPath(filename,["",".png",".gif"])   # ".jpg", ".jpeg", ".bmp"
  end

  def self.getAudioPath(filename)
    return self.getPath(filename,["",".mp3",".wav",".wma",".mid",".ogg",".midi"])
  end

  def self.getPath(filename,extensions=[])
    return filename if nil_or_empty?(filename)
    eachPathFor(filename) { |path|
      return path if safeExists?(path)
      for ext in extensions
        file = path+ext
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
      RTP.eachPath { |path|
        if path=="./"
          yield filename
        else
          yield path+filename
        end
      }
    end
  end

  # Gets all RGSS search paths.
  # This function basically does nothing now, because
  # the passage of time and introduction of MKXP make
  # it useless, but leaving it for compatibility
  # reasons
  def self.eachPath
    # XXX: Use "." instead of Dir.pwd because of problems retrieving files if
    # the current directory contains an accent mark
    yield ".".gsub(/[\/\\]/,"/").gsub(/[\/\\]$/,"")+"/"
  end

  private

  def self.getSaveFileName(fileName)
    File.join(getSaveFolder, fileName)
  end

  def self.getSaveFolder
    if System.platform[/Windows/]
      savefolder = ENV['USERPROFILE'] + "/Saved Games/Pokemon Rejuvenation/"
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
    panorama=BitmapCache.load_bitmap(file,hue)
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
      bitmap=BitmapCache.load_bitmap(file,hue)
    rescue
      bitmap=nil
    end
    if !bitmap || (bitmap.width==32 && bitmap.height==32)
      if !file || file.length<1 || file[file.length-1]!=0x2F
        if (filestring=pbGetFileChar(file))
          filestrName=file
        elsif (filestring=pbGetFileChar(file+".gif"))
          filestrName=file+".gif"
        elsif (filestring=pbGetFileChar(file+".png"))
          filestrName=file+".png"
        elsif (filestring=pbGetFileChar(file+".jpg"))
          filestrName=file+".jpg"
        elsif (filestring=pbGetFileChar(file+".bmp"))
          filestrName=file+".bmp"
        end
      end
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
        BitmapCache.setKey(file,@gifbitmaps[0])
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
  
  #### StatBoosts - START
  def aSetBitmap(bitmap)
    @gifbitmaps[@currentIndex] = bitmap
  end
  #### StatBoosts - END
end


########################
########################


def pbStringToAudioFile(str)
  if str[/^(.*)\:\s*(\d+)\s*\:\s*(\d+)\s*$/]
    file=$1
    volume=$2.to_i
    pitch=$3.to_i
    return RPG::AudioFile.new(file,volume,pitch)
  elsif str[/^(.*)\:\s*(\d+)\s*$/]
    file=$1
    volume=$2.to_i
    return RPG::AudioFile.new(file,volume,100)
  else
    return RPG::AudioFile.new(str,100,100)
  end
end

# Converts an object to an audio file. 
# str -- Either a string showing the filename or an RPG::AudioFile object.
# Possible formats for _str_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbResolveAudioFile(str,volume=nil,pitch=nil)
  if str.is_a?(String)
    str=pbStringToAudioFile(str)
    str.volume=100
    str.volume=volume if volume
    str.pitch=100
    str.pitch=pitch if pitch
  end
  if str.is_a?(RPG::AudioFile)
    if volume || pitch
      return RPG::AudioFile.new(str.name,
                                volume||str.volume||100,
                                pitch||str.pitch||100)
    else
      return str
    end
  end
  return str
end

# Plays a BGM file.
# param -- Either a string showing the filename 
# (relative to Audio/BGM/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGMPlay(param,volume=nil,pitch=nil)
  return if !param
  if volume and $PokemonSystem.volume
    volume = volume * ($PokemonSystem.volume/100.00)
  elsif !volume and param.is_a?(RPG::AudioFile) and $PokemonSystem.volume
    volume = param.volume * ($PokemonSystem.volume/100.00)
  elsif !volume and $PokemonSystem.volume
    volume = $PokemonSystem.volume 
  end
  param=pbResolveAudioFile(param,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("bgm_play")
      $game_system.bgm_play(param)
      return
    elsif (RPG.const_defined?(:BGM) rescue false)
      b=RPG::BGM.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.bgm_play(canonicalize("Audio/BGM/"+param.name),param.volume,param.pitch)
  end
end

# Plays an ME file.
# param -- Either a string showing the filename 
# (relative to Audio/ME/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbMEPlay(param,volume=nil,pitch=nil)
  return if !param
  if volume and $PokemonSystem.volume
    volume = volume * ($PokemonSystem.volume/100.00)
  elsif !volume and param.is_a?(RPG::AudioFile) and $PokemonSystem.volume
    volume = param.volume * ($PokemonSystem.volume/100.00)
  elsif !volume and $PokemonSystem.volume
    volume = $PokemonSystem.volume 
  end
  param=pbResolveAudioFile(param,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("me_play")
      $game_system.me_play(param)
      return
    elsif (RPG.const_defined?(:ME) rescue false)
      b=RPG::ME.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.me_play(canonicalize("Audio/ME/"+param.name),param.volume,param.pitch)
  end
end

# Plays a BGS file.
# param -- Either a string showing the filename 
# (relative to Audio/BGS/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGSPlay(param,volume=nil,pitch=nil)
  return if !param
  if volume and $PokemonSystem.volume
    volume = volume * ($PokemonSystem.volume/100.00)
  elsif !volume and param.is_a?(RPG::AudioFile) and $PokemonSystem.volume
    volume = param.volume * ($PokemonSystem.volume/100.00)
  elsif !volume and $PokemonSystem.volume
    volume = $PokemonSystem.volume 
  end
  param=pbResolveAudioFile(param,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("bgs_play")
      $game_system.bgs_play(param)
      return
    elsif (RPG.const_defined?(:BGS) rescue false)
      b=RPG::BGS.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.bgs_play(canonicalize("Audio/BGS/"+param.name),param.volume,param.pitch)
  end
end

# Plays an SE file.
# param -- Either a string showing the filename 
# (relative to Audio/SE/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbSEPlay(param,volume=nil,pitch=nil)
  return if !param
  if volume && $PokemonSystem.sevolume
    volume = volume * ($PokemonSystem.sevolume/100.00) #($PokemonSystem.volume/100.00)
  elsif !volume and param.is_a?(RPG::AudioFile) and $PokemonSystem.volume
    volume = param.volume * ($PokemonSystem.volume/100.00)
  elsif !volume && $PokemonSystem.sevolume
    volume = $PokemonSystem.sevolume 
  end
  param=pbResolveAudioFile(param,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("se_play")
      $game_system.se_play(param)
      return
    elsif (RPG.const_defined?(:SE) rescue false)
      b=RPG::SE.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.se_play(canonicalize("Audio/SE/"+param.name),param.volume,param.pitch)
  end
end

# Stops SE playback.
def pbSEFade(x=0.0); pbSEStop(x);end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEFade(x=0.0); pbMEStop(x);end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMFade(x=0.0); pbBGMStop(x);end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSFade(x=0.0); pbBGSStop(x);end

# Stops SE playback.
def pbSEStop(timeInSeconds=0.0)
  if $game_system
    $game_system.se_stop
  elsif (RPG.const_defined?(:SE) rescue false)
    RPG::SE.stop rescue nil
  else
    Audio.se_stop
  end
end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEStop(timeInSeconds=0.0)
  if $game_system && timeInSeconds>0.0 && $game_system.respond_to?("me_fade")
    $game_system.me_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("me_stop")
    $game_system.me_stop(nil)
    return
  elsif (RPG.const_defined?(:ME) rescue false)
    begin
      (timeInSeconds>0.0) ? RPG::ME.fade((timeInSeconds*1000).floor) : RPG::ME.stop
      return
      rescue
    end
  end
  (timeInSeconds>0.0) ? Audio.me_fade((timeInSeconds*1000).floor) : Audio.me_stop
end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMStop(timeInSeconds=0.0)
  if $game_system && timeInSeconds>0.0 && $game_system.respond_to?("bgm_fade")
    $game_system.bgm_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("bgm_stop")
    $game_system.bgm_stop
    return
  elsif (RPG.const_defined?(:BGM) rescue false)
    begin
      (timeInSeconds>0.0) ? RPG::BGM.fade((timeInSeconds*1000).floor) : RPG::BGM.stop
      return
      rescue
    end
  end
  (timeInSeconds>0.0) ? Audio.bgm_fade((timeInSeconds*1000).floor) : Audio.bgm_stop
end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSStop(timeInSeconds=0.0)
  if $game_system && timeInSeconds>0.0 && $game_system.respond_to?("bgs_fade")
    $game_system.bgs_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("bgs_play")
    $game_system.bgs_play(nil)
    return
  elsif (RPG.const_defined?(:BGS) rescue false)
    begin
      (timeInSeconds>0.0) ? RPG::BGS.fade((timeInSeconds*1000).floor) : RPG::BGS.stop
      return
      rescue
    end
  end
  (timeInSeconds>0.0) ? Audio.bgs_fade((timeInSeconds*1000).floor) : Audio.bgs_stop
end

# Plays a sound effect that plays when a decision is confirmed or a choice is made.
def pbPlayDecisionSE()
  if $data_system && $data_system.respond_to?("decision_se") &&
     $data_system.decision_se && $data_system.decision_se.name!=""
    pbSEPlay($data_system.decision_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[1] && $data_system.sounds[1].name!=""
    pbSEPlay($data_system.sounds[1])
  elsif FileTest.audio_exist?("Audio/SE/Choose")
    pbSEPlay("Choose",80)
  end
end

# Plays a sound effect that plays when the player moves the cursor.
def pbPlayCursorSE()
  if $data_system && $data_system.respond_to?("cursor_se") &&
     $data_system.cursor_se && $data_system.cursor_se.name!=""
    pbSEPlay($data_system.cursor_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[0] && $data_system.sounds[0].name!=""
    pbSEPlay($data_system.sounds[0])
  elsif FileTest.audio_exist?("Audio/SE/Choose")
    pbSEPlay("Choose",80)
  end
end

# Plays a sound effect that plays when a choice is canceled.
def pbPlayCancelSE()
  if $data_system && $data_system.respond_to?("cancel_se") &&
     $data_system.cancel_se && $data_system.cancel_se.name!=""
    pbSEPlay($data_system.cancel_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[2] && $data_system.sounds[2].name!=""
    pbSEPlay($data_system.sounds[2])
  elsif FileTest.audio_exist?("Audio/SE/Choose")
    pbSEPlay("Choose",80)
  end
end

# Plays a buzzer sound effect.
def pbPlayBuzzerSE()
  if $data_system && $data_system.respond_to?("buzzer_se") &&
     $data_system.buzzer_se && $data_system.buzzer_se.name!=""
    pbSEPlay($data_system.buzzer_se)
  elsif $data_system && $data_system.respond_to?("sounds") &&
     $data_system.sounds && $data_system.sounds[3] && $data_system.sounds[3].name!=""
    pbSEPlay($data_system.sounds[3])
  elsif FileTest.audio_exist?("Audio/SE/buzzer")
    pbSEPlay("buzzer",80)
  end
end


#########################


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

def using(window)
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


#===============================================================================
# Fades and window activations for sprite hashes
#===============================================================================
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
  bitmapName=pbResolveBitmap("Graphics/Pictures/#{background}")
  if bitmapName==nil
    # Plane should exist in any case
    sprites[planename]=ColoredPlane.new(color,@viewport)
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
  elsif fontname == "PokemonEmerald"
    bitmap.font.size=36
  else
    bitmap.font.size=31
  end
end

# Gets the name of the system small font.
def pbSmallFontName()
  return MessageConfig.pbTryFonts("Power Green Small","Pokemon Emerald Small",
     "Arial Narrow","Arial")
end

# Gets the name of the system narrow font.
def pbNarrowFontName()
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


#########################################################################


class StringInput
  include Enumerable

  class << self
    def new( str )
      if block_given?
        begin; f = super; yield f
        ensure; f.close if f; end
      else; super; end
    end
    alias open new
  end

  def initialize( str )
    @string = str
    @pos = 0
    @closed = false
    @lineno = 0
  end

  attr_reader :lineno,:string

  def inspect
    return "#<#{self.class}:#{@closed ? 'closed' : 'open'},src=#{@string[0,30].inspect}>"
  end

  def close
    raise IOError, 'closed stream' if @closed
    @pos=nil; @closed=true
  end

  def closed?; @closed; end

  def pos
    raise IOError, 'closed stream' if @closed
    [@pos, @string.size].min
  end

  alias tell pos

  def rewind; seek(0); end

  def pos=(value); seek(value); end

  def seek( offset, whence=IO::SEEK_SET )
    raise IOError, 'closed stream' if @closed
    case whence
      when IO::SEEK_SET
        @pos=offset
      when IO::SEEK_CUR
        @pos+=offset
      when IO::SEEK_END
        @pos=@string.size - offset
      else
        raise ArgumentError, "unknown seek flag: #{whence}"
    end
    @pos = 0 if @pos < 0
    @pos = [@pos, @string.size + 1].min
    offset
  end

  def eof?
    raise IOError, 'closed stream' if @closed
    @pos > @string.size
  end

  def each( &block )
    raise IOError, 'closed stream' if @closed
    begin
      @string.each(&block)
    ensure
      @pos = 0
    end
  end

  def gets
    raise IOError, 'closed stream' if @closed
    if idx = @string.index(?\n, @pos)
      idx += 1  # "\n".size
      line = @string[ @pos ... idx ]
      @pos = idx
      @pos += 1 if @pos == @string.size
    else
      line = @string[ @pos .. -1 ]
      @pos = @string.size + 1
    end
    @lineno += 1
    line
  end

  def getc
    raise IOError, 'closed stream' if @closed
    ch = @string[@pos]
    @pos += 1
    @pos += 1 if @pos == @string.size
    ch
  end

  def read( len = nil )
    raise IOError, 'closed stream' if @closed
    if !len
      return nil if eof?
      rest = @string[@pos ... @string.size]
      @pos = @string.size + 1
      return rest
    end
    str = @string[@pos, len]
    @pos += len
    @pos += 1 if @pos == @string.size
    str
  end

  def read_all; read(); end

  alias sysread read
end



module ::Marshal
  class << self
    if !@oldloadAliased
      alias oldload load
      @oldloadAliased=true
    end

    def neverload
      return @@neverload
    end

    @@neverload=false

    def neverload=(value)
      @@neverload=value
    end

    def load(port,*arg)
      if @@neverload
        if port.is_a?(IO)
          return port.read
        else
          return port
        end
      end
      oldpos=port.pos if port.is_a?(IO)
      begin
        oldload(port,*arg)
      rescue
        p [$!.class,$!.message,$!.backtrace]
        if port.is_a?(IO)
          port.pos=oldpos
          return port.read
        else
          return port
        end
      end
    end
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
    @window=window
    @x=0
    @y=0
    @width=0
    @height=0
  end

  attr_reader :x,:y,:width,:height

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

  def width=(value)
    @width=value
    privRefresh(true)
  end

  def height=(value)
    @height=value
    privRefresh(true)
  end

  def pause=(value)
    @pause=value
    @pauseopacity=0 if !value
    privRefresh if @visible
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
      if value && value.is_a?(Bitmap) && !value.disposed? && value.width==128
        @rpgvx=true
      else
        @rpgvx=false
      end
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
    if (@compat & CompatBits::CorrectZ)>0 && @skinformat==0 && !@rpgvx
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
      if @rpgvx
        trimX=64
        trimY=0
        backRect=Rect.new(0,0,64,64)
        blindsRect=Rect.new(0,64,64,64)
      else
        trimX=128
        trimY=0
        backRect=Rect.new(0,0,128,128)
        blindsRect=nil
      end
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
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
    @curframe=MessageConfig.pbGetSystemFrame()
    @curfont=MessageConfig.pbGetSystemFontName()
    @sysframe=AnimatedBitmap.new(@curframe)
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



class SpriteWindow_Selectable < SpriteWindow_Base
  attr_reader :index

  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @virtualOy=0
    @index = -1
    @row_height = 32
    @column_spacing = 32
    @ignore_input = false
  end

  def itemCount
    return @item_max || 0
  end

  def index=(index)
    if @index!=index
      @index = index
      priv_update_cursor_rect(true)
    end
  end

  def rowHeight
    return @row_height || 32
  end

  def rowHeight=(value)
    if @row_height!=value
      oldTopRow=self.top_row
      @row_height=[1,value].max
      self.top_row=oldTopRow
      update_cursor_rect
    end
  end

  def columns
    return @column_max || 1
  end

  def columns=(value)
    if @column_max!=value
      @column_max=[1,value].max
      update_cursor_rect
    end
  end

  def columnSpacing
    return @column_spacing || 32
  end

  def columnSpacing=(value)
    if @column_spacing!=value
      @column_spacing=[0,value].max
      update_cursor_rect
    end
  end

  def ignore_input=(value)
    @ignore_input=value
  end

  def count
    return @item_max
  end

  def row_max
    return ((@item_max + @column_max - 1) / @column_max).to_i
  end

  def top_row
    return (@virtualOy / (@row_height || 32)).to_i
  end

  def top_item
    return top_row * @column_max
  end

  def update_cursor_rect
    priv_update_cursor_rect
  end

  def top_row=(row)
    if row>row_max-1
      row=row_max-1
    end
    if row<0 # NOTE: The two comparison checks must be reversed since row_max can be 0
      row=0
    end
    @virtualOy=row*@row_height
  end

  def page_row_max
    return priv_page_row_max.to_i
  end

  def page_item_max
    return priv_page_item_max.to_i
  end

  def itemRect(item)
    if item<0 || item>=@item_max || item<self.top_item ||
       item>self.top_item+self.page_item_max
      return Rect.new(0,0,0,0)
    else
      cursor_width = (self.width-self.borderX-(@column_max-1)*@column_spacing) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = item / @column_max * @row_height - @virtualOy
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def update
    super
    if self.active and @item_max > 0 and @index >= 0 and !@ignore_input
      if Input.repeat?(Input::DOWN)
        if (Input.trigger?(Input::DOWN) && (@item_max%@column_max)==0) or
           @index < @item_max - @column_max
          oldindex=@index
          @index = (@index + @column_max) % @item_max
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::UP)
        if (Input.trigger?(Input::UP) && (@item_max%@column_max)==0) or
           @index >= @column_max
          oldindex=@index
          @index = (@index - @column_max + @item_max) % @item_max
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::RIGHT)
        if @column_max >= 2 and @index < @item_max - 1
          oldindex=@index
          @index += 1
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::LEFT)
        if @column_max >= 2 and @index > 0
          oldindex=@index
          @index -= 1
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::R)
        if self.index < @item_max-1
          oldindex=@index
          @index = [self.index+self.page_item_max, @item_max-1].min
          if @index!=oldindex
            pbPlayCursorSE()
            self.top_row += self.page_row_max
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::L)
        if self.index > 0
          oldindex=@index
          @index = [self.index-self.page_item_max, 0].max
          if @index!=oldindex
            pbPlayCursorSE()
            self.top_row -= self.page_row_max
            update_cursor_rect
          end
        end
      end
    end
  end

  def refresh; ;end

  private

  def priv_page_row_max
    return (self.height - self.borderY) / @row_height
  end

  def priv_page_item_max
    return (self.height - self.borderY) / @row_height * @column_max
  end

  def priv_update_cursor_rect(force=false)
    if @index < 0
      self.cursor_rect.empty
      self.refresh
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
      dorefresh=true
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
      dorefresh=true
    end
    self.top_row = [self.top_row, self.row_max - self.page_row_max].min  # ADDED
    cursor_width = (self.width-self.borderX) / @column_max
    x = self.index % @column_max * (cursor_width + @column_spacing)
    y = self.index / @column_max * @row_height - @virtualOy
    self.cursor_rect.set(x, y, cursor_width, @row_height)
    self.refresh if dorefresh || force
  end
end



module UpDownArrowMixin
  def initUpDownArrow
    @uparrow=AnimatedSprite.create("Graphics/Pictures/uparrow",8,2,self.viewport)
    @downarrow=AnimatedSprite.create("Graphics/Pictures/downarrow",8,2,self.viewport)
    @uparrow.z=99998
    @downarrow.z=99998
    @uparrow.visible=false
    @downarrow.visible=false
    @uparrow.play
    @downarrow.play
  end

  def dispose
    @uparrow.dispose
    @downarrow.dispose
    super
  end

  def viewport=(value)
    super
    @uparrow.viewport=self.viewport
    @downarrow.viewport=self.viewport
  end

  def color=(value)
    super
    @uparrow.color=value
    @downarrow.color=value
  end
  
  def adjustForZoom(sprite)
    sprite.zoom_x=self.zoom_x
    sprite.zoom_y=self.zoom_y
    sprite.x=(sprite.x*self.zoom_x+self.offset_x/self.zoom_x)
    sprite.y=(sprite.y*self.zoom_y+self.offset_y/self.zoom_y)
  end

  def update
    super
    @uparrow.x=self.x+(self.width/2)-(@uparrow.framewidth/2)
    @downarrow.x=self.x+(self.width/2)-(@downarrow.framewidth/2)
    @uparrow.y=self.y
    @downarrow.y=self.y+self.height-@downarrow.frameheight
    @uparrow.visible=self.visible && self.active && (self.top_item!=0 &&
       @item_max > self.page_item_max)
    @downarrow.visible=self.visible && self.active &&
       (self.top_item+self.page_item_max<@item_max && @item_max > self.page_item_max)
    @uparrow.z=self.z+1
    @downarrow.z=self.z+1
    adjustForZoom(@uparrow)
    adjustForZoom(@downarrow)
    @uparrow.viewport=self.viewport
    @downarrow.viewport=self.viewport
    @uparrow.update
    @downarrow.update
  end
end



class SpriteWindow_SelectableEx < SpriteWindow_Selectable
  include UpDownArrowMixin

  def initialize(*arg)
    super(*arg)
    initUpDownArrow
  end
end



class Window_DrawableCommand < SpriteWindow_SelectableEx
  attr_reader :baseColor
  attr_reader :shadowColor

  def textWidth(bitmap,text)
    return tmpbitmap.text_size(i).width
  end

  def getAutoDims(commands,dims,width=nil)
    rowMax=((commands.length + self.columns - 1) / self.columns).to_i
    windowheight=(rowMax*self.rowHeight)
    windowheight+=self.borderY
    if !width || width<0
      width=0
      tmpbitmap=BitmapWrapper.new(1,1)
      pbSetSystemFont(tmpbitmap)
      for i in commands
        width=[width,tmpbitmap.text_size(i).width].max
      end
      # one 16 to allow cursor
      width+=16+16+SpriteWindow_Base::TEXTPADDING
      tmpbitmap.dispose
    end
    # Store suggested width and height of window
    dims[0]=[self.borderX+1,(width*self.columns)+self.borderX+
       (self.columns-1)*self.columnSpacing].max
    dims[1]=[self.borderY+1,windowheight].max
    dims[1]=[dims[1],Graphics.height].min
  end

  def initialize(x,y,width,height,viewport=nil)
    super(x,y,width,height)
    self.viewport=viewport if viewport
    @selarrow=AnimatedBitmap.new("Graphics/Pictures/selarrow")
    @index=0
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    refresh
  end

  def drawCursor(index,rect)
    if self.index==index
      pbCopyBitmap(self.contents,@selarrow.bitmap,rect.x,rect.y)
    end
    return Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
  end

  def dispose
    @selarrow.dispose
    super
  end

  def baseColor=(value)
    @baseColor=value
    refresh
  end

  def shadowColor=(value)
    @shadowColor=value
    refresh
  end

  def itemCount # to be implemented by derived classes
    return 0
  end

  def drawItem(index,count,rect) # to be implemented by derived classes
  end

  def refresh
    @item_max=itemCount()
    dwidth=self.width-self.borderX
    dheight=self.height-self.borderY
    self.contents=pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...@item_max
      if i<self.top_item || i>self.top_item+self.page_item_max
        next
      end
      drawItem(i,@item_max,itemRect(i))
    end
  end

  def update
    oldindex=self.index
    super
    refresh if self.index!=oldindex
  end
end



class Window_CommandPokemon < Window_DrawableCommand
  attr_reader :commands

  def initialize(commands,width=nil)
    @starting=true
    @commands=[]
    dims=[]
    super(0,0,32,32)
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
    @commands=commands
    self.active=true
    colors=getDefaultTextColors(self.windowskin)
    self.baseColor=colors[0]
    self.shadowColor=colors[1]
    refresh
    @starting=false
  end

  def self.newWithSize(commands,x,y,width,height,viewport=nil)
    ret=self.new(commands,width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def self.newEmpty(x,y,width,height,viewport=nil)
    ret=self.new([],width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def index=(value)
    super
    refresh if !@starting
  end

  def commands=(value)
    @commands=value
    @item_max=commands.length  
    self.update_cursor_rect
    self.refresh
  end

  def width=(value)
    super
    if !@starting
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def height=(value)
    super
    if !@starting
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def resizeToFit(commands,width=nil)
    dims=[]
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
  end

  def itemCount
    return @commands ? @commands.length : 0
  end

  def drawItem(index,count,rect)
    pbSetSystemFont(self.contents) if @starting
    rect=drawCursor(index,rect)
    pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,
       @commands[index],self.baseColor,self.shadowColor)
  end
end



class Window_AdvancedCommandPokemon < Window_DrawableCommand
  attr_reader :commands

  def textWidth(bitmap,text)
    dims=[nil,0]
    chars=getFormattedText(bitmap,0,0,
       Graphics.width-self.borderX-SpriteWindow_Base::TEXTPADDING-16,
       -1,text,self.rowHeight,true,true)
    for ch in chars
      dims[0]=dims[0] ? [dims[0],ch[1]].min : ch[1]
      dims[1]=[dims[1],ch[1]+ch[3]].max
    end
    dims[0]=0 if !dims[0]
    return dims[1]-dims[0]
  end

  def initialize(commands,width=nil)
    @starting=true
    @commands=[]
    dims=[]
    super(0,0,32,32)
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
    @commands=commands
    self.active=true
    colors=getDefaultTextColors(self.windowskin)
    self.baseColor=colors[0]
    self.shadowColor=colors[1]
    refresh
    @starting=false
  end

  def self.newWithSize(commands,x,y,width,height,viewport=nil)
    ret=self.new(commands,width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def self.newEmpty(x,y,width,height,viewport=nil)
    ret=self.new([],width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def index=(value)
    super
    refresh if !@starting
  end

  def commands=(value)
    @commands=value
    @item_max=commands.length
    self.update_cursor_rect
    self.refresh
  end

  def width=(value)
    oldvalue=self.width
    super
    if !@starting && oldvalue!=value
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def height=(value)
    oldvalue=self.height
    super
    if !@starting && oldvalue!=value
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def resizeToFit(commands,width=nil)
    dims=[]
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
  end

  def itemCount
    return @commands ? @commands.length : 0
  end

  def drawItem(index,count,rect)
    pbSetSystemFont(self.contents)
    rect=drawCursor(index,rect)
    if toUnformattedText(@commands[index]).gsub(/\n/,"")==@commands[index]
      # Use faster alternative for unformatted text without line breaks
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,
         @commands[index],self.baseColor,self.shadowColor)
    else
      chars=getFormattedText(
         self.contents,rect.x,rect.y,rect.width,rect.height,
         @commands[index],rect.height,true,true)
      drawFormattedChars(self.contents,chars)
    end
  end
end



# Represents a window with no formatting capabilities.  Its text color can be set,
# though, and line breaks are supported, but the text is generally unformatted.
class Window_UnformattedTextPokemon < SpriteWindow_Base
  attr_reader :text
  attr_reader :baseColor
  attr_reader :shadowColor
  # Letter-by-letter mode.  This mode is not supported in this class.
  attr_accessor :letterbyletter

  def text=(value)
    @text=value
    refresh
  end

  def baseColor=(value)
    @baseColor=value
    refresh
  end

  def shadowColor=(value)
    @shadowColor=value
    refresh
  end

  def initialize(text="")
    super(0,0,33,33)
    self.contents=Bitmap.new(1,1)
    pbSetSystemFont(self.contents)
    @text=text
    @letterbyletter=false # Not supported in this class
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    resizeToFit(text)
  end

  def self.newWithSize(text,x,y,width,height,viewport=nil)
    ret=self.new(text)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    ret.refresh
    return ret
  end

  def resizeToFitInternal(text,maxwidth) # maxwidth is maximum acceptable window width
    dims=[0,0]
    cwidth=maxwidth<0 ? Graphics.width : maxwidth
    getLineBrokenChunks(self.contents,text,
       cwidth-self.borderX-SpriteWindow_Base::TEXTPADDING,dims,true)
    return dims
  end

  def setTextToFit(text,maxwidth=-1)
    resizeToFit(text,maxwidth)
    self.text=text
  end

  def resizeToFit(text,maxwidth=-1) # maxwidth is maximum acceptable window width
    dims=resizeToFitInternal(text,maxwidth)
    self.width=dims[0]+self.borderX+SpriteWindow_Base::TEXTPADDING
    self.height=dims[1]+self.borderY
    refresh
  end

  def resizeHeightToFit(text,width=-1) # width is current window width
    dims=resizeToFitInternal(text,width)
    self.width=width<0 ? Graphics.width : width
    self.height=dims[1]+self.borderY
    refresh
  end

  def refresh
    self.contents=pbDoEnsureBitmap(self.contents,self.width-self.borderX,
       self.height-self.borderY)
    self.contents.clear
    drawTextEx(self.contents,0,0,self.contents.width,0,
       @text.gsub(/\r/,""),@baseColor,@shadowColor)
  end
end



class Window_AdvancedTextPokemon < SpriteWindow_Base
  attr_reader :text
  attr_reader :baseColor
  attr_reader :shadowColor
  attr_accessor :letterbyletter
  attr_reader :lineHeight

  def lineHeight(value)
    @lineHeight=value
    self.text=self.text
  end

  def text=(value)
    setText(value)
  end

  def textspeed
    @frameskip
  end

  def textspeed=(value)
    @frameskip=value
    @frameskipChanged=true
  end

  def waitcount
    @waitcount
  end

  def waitcount=(value)
    @waitcount=(value<=0) ? 0 : value
  end

  def setText(value)
    @waitcount=0
    @curchar=0
    @drawncurchar=-1
    @lastDrawnChar=-1
    oldtext=@text
    @text=value
    @textlength=unformattedTextLength(value)
    @scrollstate=0
    @scrollY=0
    @linesdrawn=0
    @realframes=0
    @textchars=[]
    width=1
    height=1
    numlines=0
    visiblelines=(self.height-self.borderY)/32
    if value.length==0
      @fmtchars=[]
      @bitmapwidth=width
      @bitmapheight=height
      @numtextchars=0
    else
      if !@letterbyletter
        @fmtchars=getFormattedText(self.contents,0,0,
           self.width-self.borderX-SpriteWindow_Base::TEXTPADDING,-1,
           shadowctag(@baseColor,@shadowColor)+value,32,true)
        @oldfont=self.contents.font.clone
        for ch in @fmtchars
          chx=ch[1]+ch[3]
          chy=ch[2]+ch[4]
          width=chx if width<chx
          height=chy if height<chy
          @textchars.push(ch[5] ? "" : ch[0])
        end
      else
        @fmtchars=[]
        fmt=getFormattedText(self.contents,0,0,
           self.width-self.borderX-SpriteWindow_Base::TEXTPADDING,-1,
           shadowctag(@baseColor,@shadowColor)+value,32,true)
        @oldfont=self.contents.font.clone
        for ch in fmt
          chx=ch[1]+ch[3]
          chy=ch[2]+ch[4]
          width=chx if width<chx
          height=chy if height<chy
          if !ch[5] && ch[0]=="\n" && @letterbyletter
            numlines+=1
            if numlines>=visiblelines
              fclone=ch.clone
              fclone[0]="\1"
              @fmtchars.push(fclone)
              @textchars.push("\1")
            end
          end
          # Don't add newline characters, since they
          # can slow down letter-by-letter display
          if ch[5] || (ch[0]!="\r")
            @fmtchars.push(ch)
            @textchars.push(ch[5] ? "" : ch[0])
          end
        end
        fmt.clear
      end
      @bitmapwidth=width
      @bitmapheight=height
      @numtextchars=@textchars.length
    end
    stopPause
    @displaying=@letterbyletter
    @needclear=true
    @nodraw=@letterbyletter
    refresh
  end

  def baseColor=(value)
    @baseColor=value
    refresh
  end

  def shadowColor=(value)
    @shadowColor=value
    refresh
  end

  def busy?
    return @displaying
  end

  def pausing?
    return @pausing && @displaying
  end

  def resume
    if !busy?
      self.stopPause
      return true
    end
    if @pausing
      @pausing=false
      self.stopPause
      return false
    else
      return true
    end
  end

  def dispose
    return if disposed?
    @pausesprite.dispose if @pausesprite
    @pausesprite=nil
    super
  end

  attr_reader :cursorMode

  def cursorMode=(value)
    @cursorMode=value
    moveCursor
  end

  def moveCursor
    if @pausesprite
      cursor=@cursorMode
      cursor=2 if cursor==0 && !@endOfText
      case cursor
        when 0 # End of text
          @pausesprite.x=self.x+self.startX+@endOfText.x+@endOfText.width-2
          @pausesprite.y=self.y+self.startY+@endOfText.y-@scrollY
        when 1 # Lower right
          pauseWidth=@pausesprite.bitmap ? @pausesprite.framewidth : 16
          pauseHeight=@pausesprite.bitmap ? @pausesprite.frameheight : 16
          @pausesprite.x=self.x+self.width-(20*2)+(pauseWidth/2)
          @pausesprite.y=self.y+self.height-(30*2)+(pauseHeight/2)
        when 2 # Lower middle
          pauseWidth=@pausesprite.bitmap ? @pausesprite.framewidth : 16
          pauseHeight=@pausesprite.bitmap ? @pausesprite.frameheight : 16
          @pausesprite.x=self.x+(self.width/2)-(pauseWidth/2)
          @pausesprite.y=self.y+self.height-(18*2)+(pauseHeight/2)
      end
    end
  end

  def initialize(text="")
    @cursorMode=MessageConfig::CURSORMODE
    @endOfText=nil
    @scrollstate=0
    @realframes=0
    @scrollY=0
    @nodraw=false
    @lineHeight=32
    @linesdrawn=0
    @bufferbitmap=nil
    @letterbyletter=false
    @starting=true
    @displaying=false
    @lastDrawnChar=-1
    @fmtchars=[]
    @frameskipChanged=false
    @frameskip=MessageConfig.pbGetTextSpeed()
    super(0,0,33,33)
    @pausesprite=nil
    @text=""
    self.contents=Bitmap.new(1,1)
    pbSetSystemFont(self.contents)
    self.resizeToFit(text,Graphics.width)
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    self.text=text
    @starting=false
  end

  def self.newWithSize(text,x,y,width,height,viewport=nil)
    ret=self.new(text)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def width=(value)
    super
    if !@starting
      self.text=self.text
    end
  end

  def height=(value)
    super
    if !@starting
      self.text=self.text
    end
  end

  def resizeToFitInternal(text,maxwidth)
    dims=[0,0]
    cwidth=maxwidth<0 ? Graphics.width : maxwidth
    chars=getFormattedTextForDims(self.contents,0,0,
       cwidth-self.borderX-2-6,-1,text,@lineHeight,true)
    for ch in chars
      dims[0]=[dims[0],ch[1]+ch[3]].max
      dims[1]=[dims[1],ch[2]+ch[4]].max
    end
    return dims
  end

  def resizeToFit2(text,maxwidth,maxheight)
    dims=resizeToFitInternal(text,maxwidth)
    oldstarting=@starting
    @starting=true
    self.width=[dims[0]+self.borderX+SpriteWindow_Base::TEXTPADDING,maxwidth].min
    self.height=[dims[1]+self.borderY,maxheight].min
    @starting=oldstarting
    redrawText
  end

  def setTextToFit(text,maxwidth=-1)
    resizeToFit(text,maxwidth)
    self.text=text
  end

  def resizeToFit(text,maxwidth=-1)
    dims=resizeToFitInternal(text,maxwidth)
    oldstarting=@starting
    @starting=true
    self.width=dims[0]+self.borderX+SpriteWindow_Base::TEXTPADDING
    self.height=dims[1]+self.borderY
    @starting=oldstarting
    redrawText
  end

  def resizeHeightToFit(text,width=-1)
    dims=resizeToFitInternal(text,width)
    oldstarting=@starting
    @starting=true
    self.width=width<0 ? Graphics.width : width
    self.height=dims[1]+self.borderY
    @starting=oldstarting
    redrawText
  end

  def refresh
    oldcontents=self.contents
    self.contents=pbDoEnsureBitmap(oldcontents,@bitmapwidth,@bitmapheight)
    self.oy=@scrollY
    numchars=@numtextchars
    startchar=0
    numchars=[@curchar,@numtextchars].min if self.letterbyletter
    if busy? && @drawncurchar==@curchar && @scrollstate==0
      return
    end
    if !self.letterbyletter || !oldcontents.equal?(self.contents)
      @drawncurchar=-1
      @needclear=true
    end
    if @needclear
      self.contents.font=@oldfont if @oldfont
      self.contents.clear
      @needclear=false
    end
    if @nodraw
      @nodraw=false
      return
    end
    maxX=self.width-self.borderX
    maxY=self.height-self.borderY
    for i in @drawncurchar+1..numchars
      next if i>=@fmtchars.length
      if !self.letterbyletter
        next if @fmtchars[i][1]>=maxX
        next if @fmtchars[i][2]>=maxY
      end
      drawSingleFormattedChar(self.contents,@fmtchars[i])
      @lastDrawnChar=i
    end
    if !self.letterbyletter
      # all characters were drawn, reset old font
      self.contents.font=@oldfont if @oldfont
    end
    if numchars>0 && numchars!=@numtextchars
      fch=@fmtchars[numchars-1]
      if fch
        rcdst=Rect.new(fch[1],fch[2],fch[3],fch[4])
        if @textchars[numchars]=="\1"
          @endOfText=rcdst
          allocPause
          moveCursor()
        else
          @endOfText=Rect.new(rcdst.x+rcdst.width,rcdst.y,8,1)
        end
      end
    end
    @drawncurchar=@curchar
  end

  def maxPosition
    pos=0
    for ch in @fmtchars
      # index after the last character's index
      pos=ch[14]+1 if pos<ch[14]+1
    end
    return pos
  end

  def position
    if @lastDrawnChar<0
      return 0
    elsif @lastDrawnChar>=@fmtchars.length
      return @numtextchars
    else
      # index after the last character's index
      return @fmtchars[@lastDrawnChar][14]+1 
    end
  end

  def redrawText
    if !@letterbyletter
      self.text=self.text
    else
      oldPosition=self.position
      self.text=self.text
      oldPosition=@numtextchars if oldPosition>@numtextchars
      while self.position!=oldPosition
        refresh
        updateInternal
      end
    end
  end

  def updateInternal
    curcharskip=@frameskip<0 ? @frameskip.abs : 1
    visiblelines=(self.height-self.borderY)/@lineHeight
    if @textchars[@curchar]=="\1"
      if !@pausing
        @realframes+=1
        if @realframes>=@frameskip || @frameskip<0
          curcharSkip(curcharskip)
          @realframes=0
        end
      end
    elsif @textchars[@curchar]=="\n"
      if @linesdrawn>=visiblelines-1
        if @scrollstate<@lineHeight
          @scrollstate+=[(@lineHeight/4),1].max
          @scrollY+=[(@lineHeight/4),1].max
        end
        if @scrollstate>=@lineHeight
          @realframes+=1
          if @realframes>=@frameskip || @frameskip<0
            curcharSkip(curcharskip)
            @linesdrawn+=1
            @scrollstate=0
            @realframes=0
          end
        end
      else
        @realframes+=1
        if @realframes>=@frameskip || @frameskip<0
          curcharSkip(curcharskip)
          @linesdrawn+=1
          @realframes=0
        end
      end
    elsif @curchar<=@numtextchars
      @realframes+=1
      if @realframes>=@frameskip || @frameskip<0
        curcharSkip(curcharskip)
        @realframes=0
      end
      if @textchars[@curchar]=="\1"
        @pausing=true if @curchar<@numtextchars-1
        self.startPause
        refresh
      end
    else
      @displaying=false
      @scrollstate=0
      @scrollY=0
      @linesdrawn=0
    end
  end

  def update
    super
    if @pausesprite && @pausesprite.visible
      @pausesprite.update
    end
    if @waitcount>0
      @waitcount-=1
      return
    end
    if busy?
      refresh if !@frameskipChanged
      updateInternal
      # following line needed to allow "textspeed=-999" to work seamlessly
      refresh if @frameskipChanged 
    end
    @frameskipChanged=false
  end

  def allocPause
    if !@pausesprite
      @pausesprite=AnimatedSprite.create("Graphics/Pictures/pause",4,3)
      @pausesprite.z=100000
      @pausesprite.visible=false
    end
  end

  def startPause
    allocPause
    @pausesprite.visible=true
    @pausesprite.frame=0
    @pausesprite.start
    moveCursor
  end

  def stopPause
    if @pausesprite
      @pausesprite.stop
      @pausesprite.visible=false
    end
  end

  private

  def curcharSkip(skip)
    skip.times do
      @curchar+=1
      break if @textchars[@curchar]=="\n" || # newline
               @textchars[@curchar]=="\1" || # pause
               @textchars[@curchar]=="\2" || # letter-by-letter break
               @textchars[@curchar]==nil
    end
  end
end



class Window_InputNumberPokemon < SpriteWindow_Base
  attr_reader :number
  attr_reader :sign

  def initialize(digits_max)
    @digits_max=digits_max
    @number=0
    @frame=0
    @sign=false
    @negative=false
    super(0,0,32,32)
    self.width=digits_max*24+8+self.borderX
    self.height=32+self.borderY
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    @index=digits_max-1
    self.active=true
    refresh
  end

  def active=(value)
    super
    refresh
  end

  def number
    @number*(@sign && @negative ? -1 : 1)
  end

  def sign=(value)
    @sign=value
    self.width=@digits_max*24+8+self.borderX+(@sign ? 24 : 0)
    @index=(@digits_max-1)+(@sign ? 1 : 0)
    refresh
  end

  def number=(value)
    value=0 if !value.is_a?(Numeric)
    if @sign
      @negative=(value<0)
      @number = [value.abs, 10 ** @digits_max - 1].min
    else
      @number = [[value, 0].max, 10 ** @digits_max - 1].min
    end
    refresh
  end

  def refresh
    self.contents=pbDoEnsureBitmap(self.contents,
       self.width-self.borderX,self.height-self.borderY)
    pbSetSystemFont(self.contents)
    self.contents.clear
    s=sprintf("%0*d",@digits_max,@number.abs)
    x=0
    if @sign
      textHelper(0,0,@negative ? "-" : "+",0)
    end
    for i in 0...@digits_max
      index=i+(@sign ? 1 : 0)
      textHelper(index*24,0,s[i,1],index)
    end
  end

  def update
    super
    digits=@digits_max+(@sign ? 1 : 0)
    refresh if @frame%15==0
    if self.active
      if Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN)
        pbPlayCursorSE()
        if @index==0 && @sign
          @negative=!@negative
        else
          place = 10 ** (digits - 1 - @index)
          n = @number / place % 10
          @number -= n*place
          if Input.repeat?(Input::UP)
            n = (n + 1) % 10
          elsif Input.repeat?(Input::DOWN)
            n = (n + 9) % 10
          end
          @number += n*place
        end
        refresh
      elsif Input.repeat?(Input::RIGHT)
        if digits >= 2
          pbPlayCursorSE()
          @index = (@index + 1) % digits
          @frame=0
          refresh
        end
      elsif Input.repeat?(Input::LEFT)
        if digits >= 2
          pbPlayCursorSE()
          @index = (@index + digits - 1) % digits
          @frame=0
          refresh
        end
      end
    end
    @frame=(@frame+1)%30
  end

  private

  def textHelper(x,y,text,i)
    textwidth=self.contents.text_size(text).width
    self.contents.font.color=@shadowColor
    pbDrawShadow(self.contents,x+(12-textwidth/2),y, textwidth+4, 32, text)
    self.contents.font.color=@baseColor
    self.contents.draw_text(x+(12-textwidth/2),y, textwidth+4, 32, text)    
    if @index==i && @active && @frame/15==0
      colors=getDefaultTextColors(self.windowskin)
      self.contents.fill_rect(x+(12-textwidth/2),y+30,textwidth,2,colors[0])
    end
  end
end



class AnimatedSprite < SpriteWrapper
  attr_reader :frame
  attr_reader :framewidth
  attr_reader :frameheight
  attr_reader :framecount
  attr_reader :animname

  def initializeLong(animname,framecount,framewidth,frameheight,frameskip)
    @animname=pbBitmapName(animname)
    @realframes=0
    @frameskip=[1,frameskip].max
    raise _INTL("Frame width is 0") if framewidth==0
    raise _INTL("Frame height is 0") if frameheight==0
    begin
      @animbitmap=AnimatedBitmap.new(animname).deanimate
      rescue
      @animbitmap=Bitmap.new(framewidth,frameheight)
    end
    if @animbitmap.width%framewidth!=0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame width ({2}) [Bitmap={3}]",
         @animbitmap.width,framewidth,animname)
    end
    if @animbitmap.height%frameheight!=0
      raise _INTL("Bitmap's height ({1}) is not a multiple of frame height ({2}) [Bitmap={3}]",
         @animbitmap.height,frameheight,animname)
    end
    @framecount=framecount
    @framewidth=framewidth
    @frameheight=frameheight
    @framesperrow=@animbitmap.width/@framewidth
    @playing=false
    self.bitmap=@animbitmap
    self.src_rect.width=@framewidth
    self.src_rect.height=@frameheight
    self.frame=0
  end

  # Shorter version of AnimationSprite.  All frames are placed on a single row
  # of the bitmap, so that the width and height need not be defined beforehand
  def initializeShort(animname,framecount,frameskip)
    @animname=pbBitmapName(animname)
    @realframes=0
    @frameskip=[1,frameskip].max
    begin
      @animbitmap=AnimatedBitmap.new(animname).deanimate
      rescue
      @animbitmap=Bitmap.new(framecount*4,32)
    end
    if @animbitmap.width%framecount!=0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame count ({2}) [Bitmap={3}]",
         @animbitmap.width,framewidth,animname)
    end
    @framecount=framecount
    @framewidth=@animbitmap.width/@framecount
    @frameheight=@animbitmap.height
    @framesperrow=framecount
    @playing=false
    self.bitmap=@animbitmap
    self.src_rect.width=@framewidth
    self.src_rect.height=@frameheight
    self.frame=0
  end

  def initialize(*args)
    if args.length==1
      super(args[0][3])
      initializeShort(args[0][0],args[0][1],args[0][2])
    else
      super(args[5])
      initializeLong(args[0],args[1],args[2],args[3],args[4])
    end
  end

  def self.create(animname,framecount,frameskip,viewport=nil)
    return self.new([animname,framecount,frameskip,viewport])
  end

  def dispose
    return if disposed?
    @animbitmap.dispose
    @animbitmap=nil
    super
  end

  def playing?
    return @playing
  end

  def frame=(value)
    @frame=value
    @realframes=0
    self.src_rect.x=@frame%@framesperrow*@framewidth
    self.src_rect.y=@frame/@framesperrow*@frameheight
  end

  def start
    @playing=true
    @realframes=0
  end

  alias play start

  def stop
    @playing=false
  end

  def update
    super
    if @playing
      @realframes+=1
      if @realframes==@frameskip
        @realframes=0 
        self.frame+=1
        self.frame%=self.framecount
      end
    end
  end
end



# Displays an icon bitmap in a sprite. Supports animated images.
class IconSprite < SpriteWrapper
  attr_reader :name

  def initialize(*args)
    if args.length==0
      super(nil)
      self.bitmap=nil
    elsif args.length==1
      super(args[0])
      self.bitmap=nil
    elsif args.length==2
      super(nil)
      self.x=args[0]
      self.y=args[1]
    else
      super(args[2])
      self.x=args[0]
      self.y=args[1]
    end
    @name=""
    @_iconbitmap=nil
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      if self.bitmap!=@_iconbitmap.bitmap
        oldrc=self.src_rect
        self.bitmap=@_iconbitmap.bitmap
        self.src_rect=oldrc
      end
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.bitmap=nil if !self.disposed?
  end

  # Sets the icon's filename.  Alias for setBitmap.
  def name=(value)
    setBitmap(value)
  end

  # Sets the icon's filename.
  def setBitmap(file,hue=0)
    oldrc=self.src_rect
    clearBitmaps()
    @name=file
    return if file==nil
    if file!=""
      @_iconbitmap=AnimatedBitmap.new(file,hue)
      # for compatibility
      self.bitmap=@_iconbitmap ? @_iconbitmap.bitmap : nil
      self.src_rect=oldrc
    else
      @_iconbitmap=nil
    end
  end
end



# Old GifSprite class, retained for compatibility
class GifSprite < IconSprite
  def initialize(path)
    super(0,0)
    setBitmap(path)
  end
end



# Sprite class that maintains a bitmap of its own.
# This bitmap can't be changed to a different one.
class BitmapSprite < SpriteWrapper
  def initialize(width,height,viewport=nil)
    super(viewport)
    self.bitmap=Bitmap.new(width,height)
    @initialized=true
  end

  def bitmap=(value)
    super(value) if !@initialized
  end

  def dispose
    self.bitmap.dispose if !self.disposed?
    super
  end
end



class Plane
  def update; end
  def refresh; end
end



# This class works around a limitation that planes are always
# 640 by 480 pixels in size regardless of the window's size.
class LargePlane < Plane
  attr_accessor :borderX
  attr_accessor :borderY

  def initialize(viewport=nil)
    @__sprite=Sprite.new(viewport)
    @__disposed=false
    @__ox=0
    @__oy=0
    @__bitmap=nil
    @__visible=true
    @__sprite.visible=false
    @borderX=0
    @borderY=0
  end

  def disposed?
    return @__disposed
  end

  def dispose
    if !@__disposed
      @__sprite.bitmap.dispose if @__sprite.bitmap
      @__sprite.dispose
      @__sprite=nil
      @__bitmap=nil
      @__disposed=true
    end
  end

  def ox; @__ox; end
  def oy; @__oy; end
  
  def ox=(value); 
    if @__ox!=value
      @__ox=value; refresh
    end
  end

  def oy=(value); 
    if @__oy!=value
      @__oy=value; refresh
    end
  end

  def bitmap
    return @__bitmap
  end

  def bitmap=(value)
    if value==nil
      if @__bitmap!=nil
        @__bitmap=nil
        @__sprite.visible=(@__visible && !@__bitmap.nil?)
      end
    elsif @__bitmap!=value && !value.disposed?
      @__bitmap=value
      refresh
    elsif value.disposed?
      if @__bitmap!=nil
        @__bitmap=nil
        @__sprite.visible=(@__visible && !@__bitmap.nil?)
      end
    end
  end

  def viewport; @__sprite.viewport; end
  def zoom_x; @__sprite.zoom_x; end
  def zoom_y; @__sprite.zoom_y; end
  def opacity; @__sprite.opacity; end
  def blend_type; @__sprite.blend_type; end
  def visible; @__visible; end
  def z; @__sprite.z; end
  def color; @__sprite.color; end
  def tone; @__sprite.tone; end

  def zoom_x=(v); 
    if @__sprite.zoom_x!=v
      @__sprite.zoom_x=v; refresh
    end
  end

  def zoom_y=(v); 
    if @__sprite.zoom_y!=v
      @__sprite.zoom_y=v; refresh
    end
  end

  def opacity=(v); @__sprite.opacity=(v); end
  def blend_type=(v); @__sprite.blend_type=(v); end
  def visible=(v); @__visible=v; @__sprite.visible=(@__visible && !@__bitmap.nil?); end
  def z=(v); @__sprite.z=(v); end
  def color=(v); @__sprite.color=(v); end
  def tone=(v); @__sprite.tone=(v); end
  def update; ;end

  def refresh
    @__sprite.visible=(@__visible && !@__bitmap.nil?)
    if @__bitmap
      if !@__bitmap.disposed?
        @__ox+=@__bitmap.width*@__sprite.zoom_x if @__ox<0                   # ADDED
        @__oy+=@__bitmap.height*@__sprite.zoom_y if @__oy<0                  # ADDED
        @__ox-=@__bitmap.width*@__sprite.zoom_x if @__ox>@__bitmap.width     # ADDED
        @__oy-=@__bitmap.height*@__sprite.zoom_y if @__oy>@__bitmap.height   # ADDED
        dwidth=(Graphics.width/@__sprite.zoom_x+@borderX).to_i # +2
        dheight=(Graphics.height/@__sprite.zoom_y+@borderY).to_i # +2
        @__sprite.bitmap=ensureBitmap(@__sprite.bitmap,dwidth,dheight)
        @__sprite.bitmap.clear
        tileBitmap(@__sprite.bitmap,@__bitmap,@__bitmap.rect)
      else
        @__sprite.visible=false
      end
    end
  end

  private

  def ensureBitmap(bitmap,dwidth,dheight)
    if !bitmap||bitmap.disposed?||bitmap.width<dwidth||bitmap.height<dheight
      bitmap.dispose if bitmap
      bitmap=Bitmap.new([1,dwidth].max,[1,dheight].max)
    end
    return bitmap
  end

  def tileBitmap(dstbitmap,srcbitmap,srcrect)
    return if !srcbitmap || srcbitmap.disposed?
    dstrect=dstbitmap.rect
    left=dstrect.x-@__ox/@__sprite.zoom_x
    top=dstrect.y-@__oy/@__sprite.zoom_y
    left=left.to_i; top=top.to_i
    while left>0; left-=srcbitmap.width; end
    while top>0; top-=srcbitmap.height; end
    y=top; while y<dstrect.height
      x=left; while x<dstrect.width
        dstbitmap.blt(x+@borderX,y+@borderY,srcbitmap,srcrect)
        x+=srcrect.width
      end
      y+=srcrect.height
    end
  end
end



# A plane class that displays a single color.
class ColoredPlane < LargePlane
  def initialize(color,viewport=nil)
    super(viewport)
    self.bitmap=Bitmap.new(32,32)
    setPlaneColor(color)
  end

  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end

  def update; super; end

  def setPlaneColor(value)
    self.bitmap.fill_rect(0,0,self.bitmap.width,self.bitmap.height,value)
    self.refresh
  end
end



# A plane class that supports animated images.
class AnimatedPlane < LargePlane
  def initialize(viewport)
    super(viewport)
    @bitmap=nil
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @bitmap
      @bitmap.update
      self.bitmap=@bitmap.bitmap
    end
  end

  def clearBitmaps
    @bitmap.dispose if @bitmap
    @bitmap=nil
    self.bitmap=nil if !self.disposed?
  end

  def setPanorama(file, hue=0)
    clearBitmaps()
    return if file==nil
    @bitmap=AnimatedBitmap.new("Graphics/Panoramas/"+file,hue)
  end

  def setFog(file, hue=0)
    clearBitmaps()
    return if file==nil
    @bitmap=AnimatedBitmap.new("Graphics/Fogs/"+file,hue)
  end

  def setBitmap(file, hue=0)
    clearBitmaps()
    return if file==nil
    @bitmap=AnimatedBitmap.new(file,hue)
  end
end



# Displays an icon bitmap in a window. Supports animated images.
class IconWindow < SpriteWindow_Base
  attr_reader :name

  def initialize(x,y,width,height,viewport=nil)
    super(x,y,width,height)
    self.viewport=viewport
    self.contents=nil
    @name=""
    @_iconbitmap=nil
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.contents=@_iconbitmap.bitmap
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.contents=nil if !self.disposed?
  end

  # Sets the icon's filename.  Alias for setBitmap.
  def name=(value)
    setBitmap(value)
  end

  # Sets the icon's filename.
  def setBitmap(file,hue=0)
    clearBitmaps()
    @name=file
    return if file==nil
    if file!=""
      @_iconbitmap=AnimatedBitmap.new(file,hue)
      # for compatibility
      self.contents=@_iconbitmap ? @_iconbitmap.bitmap : nil
    else
      @_iconbitmap=nil
    end
  end
end



# Displays an icon bitmap in a window. Supports animated images.
# Accepts bitmaps and paths to bitmap files in its constructor
class PictureWindow < SpriteWindow_Base
  def initialize(pathOrBitmap)
    super(0,0,32,32)
    self.viewport=viewport
    self.contents=nil
    @_iconbitmap=nil
    setBitmap(pathOrBitmap)
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @_iconbitmap
      if @_iconbitmap.is_a?(Bitmap)
        self.contents=@_iconbitmap
      else
        @_iconbitmap.update
        self.contents=@_iconbitmap.bitmap
      end
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.contents=nil if !self.disposed?
  end

  # Sets the icon's bitmap or filename. (hue parameter
  # is ignored unless pathOrBitmap is a filename)
  def setBitmap(pathOrBitmap,hue=0)
    clearBitmaps()
    if pathOrBitmap!=nil && pathOrBitmap!=""
      if pathOrBitmap.is_a?(Bitmap)
        @_iconbitmap=pathOrBitmap
        self.contents=@_iconbitmap
        self.width=@_iconbitmap.width+self.borderX
        self.height=@_iconbitmap.height+self.borderY
      elsif pathOrBitmap.is_a?(AnimatedBitmap)
        @_iconbitmap=pathOrBitmap
        self.contents=@_iconbitmap.bitmap
        self.width=@_iconbitmap.bitmap.width+self.borderX
        self.height=@_iconbitmap.bitmap.height+self.borderY
      else
        @_iconbitmap=AnimatedBitmap.new(pathOrBitmap,hue)
        self.contents=@_iconbitmap ? @_iconbitmap.bitmap : nil
        self.width=@_iconbitmap ? @_iconbitmap.bitmap.width+self.borderX : 
           32+self.borderX
        self.height=@_iconbitmap ? @_iconbitmap.bitmap.height+self.borderY :
           32+self.borderY
      end
    else
      @_iconbitmap=nil
      self.width=32+self.borderX
      self.height=32+self.borderY
    end
  end
end



class Window_CommandPokemonEx < Window_CommandPokemon
end



class Window_AdvancedCommandPokemonEx < Window_AdvancedCommandPokemon
end