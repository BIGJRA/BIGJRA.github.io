class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions
  attr_accessor :options

  def initialize(options,x,y,width,height)
    @options=options
    @nameBaseColor=Color.new(24*8,15*8,0)
    @nameShadowColor=Color.new(31*8,22*8,10*8)
    @selBaseColor=Color.new(31*8,6*8,3*8)
    @selShadowColor=Color.new(31*8,17*8,16*8)
    @optvalues=[]
    @mustUpdateOptions=false
    for i in 0...@options.length
      @optvalues[i]=0
    end
    super(x,y,width,height)
  end

  def [](i)
    return @optvalues[i]
  end

  def []=(i,value)
    @optvalues[i]=value
    refresh
  end

  def itemCount
    return @options.length+1
  end

  def drawItem(index,count,rect)
    rect=drawCursor(index,rect)
    optionname=(index==@options.length) ? _INTL("Cancel") : @options[index].name
    optionwidth=(rect.width*9/20)
    pbDrawShadowText(self.contents,rect.x,rect.y,optionwidth,rect.height,optionname,
       @nameBaseColor,@nameShadowColor)
    self.contents.draw_text(rect.x,rect.y,optionwidth,rect.height,optionname)
    return if index==@options.length
    if @options[index].is_a?(EnumOption)
      if @options[index].values.length>1
        totalwidth=0
        for value in @options[index].values
          totalwidth+=self.contents.text_size(value).width
        end
        spacing=(optionwidth-totalwidth)/(@options[index].values.length-1)
        spacing=0 if spacing<0
        xpos=optionwidth+rect.x
        ivalue=0
        for value in @options[index].values
          pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
             (ivalue==self[index]) ? @selBaseColor : self.baseColor,
             (ivalue==self[index]) ? @selShadowColor : self.shadowColor
          )
          self.contents.draw_text(xpos,rect.y,optionwidth,rect.height,value)
          xpos+=self.contents.text_size(value).width
          xpos+=spacing
          ivalue+=1
        end
      else
        pbDrawShadowText(self.contents,rect.x+optionwidth,rect.y,optionwidth,rect.height,
           optionname,self.baseColor,self.shadowColor)
      end
    elsif @options[index].is_a?(NumberOption)
      value=_ISPRINTF("{1:d}",@options[index].optstart+self[index])
      xpos=optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    else
      value=@options[index].values[self[index]]
      xpos=optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
      self.contents.draw_text(xpos,rect.y,optionwidth,rect.height,value)
    end
  end

  def update
    dorefresh=false
    oldindex=self.index
    @mustUpdateOptions=false
    super
    dorefresh=self.index!=oldindex
    if self.active && self.index<@options.length
      if Input.repeat?(Input::LEFT)
        self[self.index]=@options[self.index].prev(self[self.index])
        dorefresh=true
        @mustUpdateOptions=true
      elsif Input.repeat?(Input::RIGHT)
        self[self.index]=@options[self.index].next(self[self.index])
        dorefresh=true
        @mustUpdateOptions=true
      elsif Input.repeat?(Input::UP) || Input.repeat?(Input::DOWN)
        @mustUpdateOptions=true
      end
    end
    refresh if dorefresh
  end
end

module PropertyMixin
  def get
    @getProc ? @getProc.call() : nil
  end

  def set(value)
    @setProc.call(value) if @setProc
  end
end

class EnumOption
  include PropertyMixin
  attr_reader :values
  attr_reader :name
  attr_reader :description

  def initialize(name,options,getProc,setProc,description="")            
    @values=options
    @name=name
    @getProc=getProc
    @setProc=setProc
    @description=description
  end

  def next(current)
    index=current+1
    index=@values.length-1 if index>@values.length-1
    return index
  end

  def prev(current)
    index=current-1
    index=0 if index<0
    return index
  end
end

class NumberOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart
  attr_reader :description

  def initialize(name,format,optstart,optend,getProc,setProc,description="")
    @name=name
    @format=format
    @optstart=optstart
    @optend=optend
    @getProc=getProc
    @setProc=setProc
    @description=description
  end

  def next(current)
    index=current+@optstart
    index+=1
    if index>@optend
      index=@optstart
    end
    return index-@optstart
  end

  def prev(current)
    index=current+@optstart
    index-=1
    if index<@optstart
      index=@optend
    end
    return index-@optstart
  end
end


def pbSettingToTextSpeed(speed)
  return 2 if speed==0
  return 1 if speed==1
  return -2 if speed==2
  return MessageConfig::TextSpeed if MessageConfig::TextSpeed
  return ((Graphics.frame_rate>40) ? -2 : 1)
end

module MessageConfig
  def self.pbDefaultSystemFrame
    return pbResolveBitmap(TextFrames[$idk[:settings].frame])||""
  end

  def self.pbDefaultSpeechFrame
    return pbResolveBitmap("Graphics/Windowskins/"+SpeechFrames[$idk[:settings].textskin])||""
  end

  def self.pbDefaultSystemFontName
    return MessageConfig.pbTryFonts(VersionStyles[0][0],"Arial Narrow","Arial")
  end

  def self.pbDefaultTextSpeed
    return pbSettingToTextSpeed($idk[:settings].textspeed)
  end

  def pbGetSystemTextSpeed
    return $idk[:settings].textspeed
  end
end

class PokemonOptions
  attr_accessor :textspeed
  attr_accessor :volume
  attr_accessor :sevolume
  attr_accessor :bagsorttype
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :font
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :border
  attr_accessor :backup
  attr_accessor :maxBackup
  attr_accessor :field_effects_highlights
  attr_accessor :remember_commands
  attr_accessor :photosensitive
  attr_accessor :autosave
  attr_accessor :autorunning
  attr_accessor :bike_and_surf_music
  attr_accessor :streamermode
  attr_accessor :unrealTimeDiverge
  attr_accessor :unrealTimeClock
  attr_accessor :unrealTimeTimeScale

  def initialize(system=nil)
    @textspeed   = (system != nil ? system.textspeed : 1)   # Text speed (0=slow, 1=mid, 2=fast)
    @volume      = (system != nil ? system.volume : 100.00) # Volume (0 - 100 )
    @sevolume    = (system != nil ? system.sevolume : 100.00) # Volume (0 - 100 )
    @bagsorttype = (system != nil ? system.bagsorttype : 0)   # Bag sorting (0=by name, 1=by type)
    @battlescene = (system != nil ? system.battlescene : 0)   # Battle scene (animations) (0=on, 1=off)
    @battlestyle = (system != nil ? system.battlestyle : 0)   # Battle style (0=shift, 1=set)
    @frame       = (system != nil ? system.frame : 0)   # Default window frame (see also TextFrames)
    @textskin    = (system != nil ? system.textskin : 0)   # Speech frame
    @font        = (system != nil ? system.font : 0)   # Font (see also VersionStyles)
    @screensize  = (system != nil ? system.screensize : (DEFAULTSCREENZOOM).floor).to_i # 0=half size, 1=full size, 2=double size
    @border      = (system != nil ? system.border : 0)   # Screen border (0=off, 1=on)
    @language    = (system != nil ? system.language : 0)   # Language (see also LANGUAGES in script PokemonSystem)
    @backup      = (system != nil ? system.backup : 0)   # Backup on/off
    @maxBackup   = (system != nil ? system.maxBackup : 50)   # Backup on/off
    @field_effects_highlights = (system != nil  ? system.field_effects_highlights : 0)   #Field effect UI highlights on/off
    @remember_commands        = (system != nil ? system.remember_commands : 0)
    @photosensitive           = (system != nil  ? system.photosensitive : 0) # a mode that disables flahses and shakes (0=off, 1 = onn)
    @autorunning              = (system != nil ? system.autorunning : 0) # 0 is on, 1 is off
    @bike_and_surf_music      = (system != nil ? system.bike_and_surf_music : 0) # 0 is off, 1 is on
    @streamermode             = (system != nil ? system.streamermode : 0)
    @unrealTimeDiverge        = (system != nil ? system.unrealTimeDiverge : 0)   # Unreal Time on/off
    @unrealTimeClock          = (system != nil ? system.unrealTimeClock : 2)    # Unreal Time Clock (0=always, 1=pause menu, 2=pokegear only)
    @unrealTimeTimeScale      = (system != nil ? system.unrealTimeTimeScale : 30)   # Unreal Time Timescale (default 30x real time)
  end
end

class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :volume
  attr_accessor :sevolume
  attr_accessor :bagsorttype
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :font
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :border
  attr_accessor :backup
  attr_accessor :maxBackup
  attr_accessor :field_effects_highlights
  attr_accessor :remember_commands
  attr_accessor :photosensitive
  attr_accessor :autosave
  attr_accessor :autorunning
  attr_accessor :bike_and_surf_music
  attr_accessor :streamermode

  attr_accessor :unrealTimeDiverge
  attr_accessor :unrealTimeClock
  attr_accessor :unrealTimeTimeScale

  def language
    return (!@language) ? 0 : @language
  end

  def textskin
    return (!@textskin) ? 0 : @textskin
  end

  def border
    return (!@border) ? 0 : @border
  end

  def photosensitive
    return (!@photosensitive) ? 0 : @photosensitive
  end

  def remember_commands
    return (!@remember_commands) ? 0 : @remember_commands
  end 

  def field_effects_highlights
    return (!@field_effects_highlights) ? 0 : @field_effects_highlights
  end
  
  def tilemap; return MAPVIEWMODE; end

  def unrealTimeDiverge
    return (!@unrealTimeDiverge) ? 1 : @unrealTimeDiverge
  end

  def unrealTimeClock
    return (!@unrealTimeClock) ? 2 : @unrealTimeClock
  end

  def unrealTimeTimeScale
    return (!@unrealTimeTimeScale) ? 30 : @unrealTimeTimeScale
  end

  def autorunning
    return (!@autorunning) ? 0 : @autorunning
  end

  def bike_and_surf_music
    return (!@bike_and_surf_music) ? 0 : @bike_and_surf_music
  end

  def streamermode
    return (!@streamermode) ? 0 : @streamermode
  end


  def initialize
    @textspeed   = 1   # Text speed (0=slow, 1=mid, 2=fast)
    @volume      = 100.00 # Volume (0 - 100 )
    @sevolume    = 100.00 # Volume (0 - 100 )
    @bagsorttype = 0   # Bag sorting (0=by name, 1=by type)
    @battlescene = 0   # Battle scene (animations) (0=on, 1=off)
    @battlestyle = 0   # Battle style (0=shift, 1=set)
    @frame       = 0   # Default window frame (see also TextFrames)
    @textskin    = 0   # Speech frame
    @font        = 0   # Font (see also VersionStyles)
    @screensize  = (DEFAULTSCREENZOOM.floor).to_i # 0=half size, 1=full size, 2=double size
    @border      = 0   # Screen border (0=off, 1=on)
    @language    = 0   # Language (see also LANGUAGES in script PokemonSystem)
    @backup      = 0   # Backup on/off
    @maxBackup   = 50   # Backup on/off
    @field_effects_highlights = 0   #Field effect UI highlights on/off
    @remember_commands        = 0
    @photosensitive           = 0 # a mode that disables flahses and shakes (0=off, 1 = onn)
    @autorunning              = 0 # 0 is on, 1 is off
    @bike_and_surf_music      = 0 # 0 is off, 1 is on
    @streamermode             = 0 # 0 is off, 1 is on
    @unrealTimeDiverge = 0   # Unreal Time on/off
    @unrealTimeClock = 2    # Unreal Time Clock (0=always, 1=pause menu, 2=pokegear only)
    @unrealTimeTimeScale = 30   # Unreal Time Timescale (default 30x real time)
  end

  def reload
    MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+SpeechFrames[@textskin])
    MessageConfig.pbSetSystemFrame(TextFrames[@frame]) 
    MessageConfig.pbSetTextSpeed(pbSettingToTextSpeed(@textspeed)) 
    MessageConfig.pbSetSystemFontName(VersionStyles[0])
  end
end

class PokemonOptionScene
  OptionList=[
    EnumOption.new(_INTL("Autorunning"),[_INTL("On"),_INTL("Off")],
        proc { $idk[:settings].autorunning },
        proc {|value|  $idk[:settings].autorunning = value }
    ),
    EnumOption.new(_INTL("Text Speed"),[_INTL("Normal"),_INTL("Fast"),_INTL("Max")],
       proc { $idk[:settings].textspeed },
       proc {|value|  
          $idk[:settings].textspeed=value 
          MessageConfig.pbSetTextSpeed(pbSettingToTextSpeed(value)) 
       }
    ),
    NumberOption.new(_INTL("BGM Volume"),_INTL("Type %d"),0,100,
       proc { $idk[:settings].volume },
       proc {|value|  $idk[:settings].volume=value
       if $game_map
          $game_map.autoplay
       end
      },
      "Volume of Background Music."
    ),       
    NumberOption.new(_INTL("SE Volume"),_INTL("Type %d"),0,100,
       proc { $idk[:settings].sevolume },
       proc {|value|  $idk[:settings].sevolume=value
       if $game_map
          $game_map.autoplay
       end
      },
      "Volume of Sound Effects."
    ),
    EnumOption.new(_INTL("Bike and Surf Music"),[_INTL("Off"),_INTL("On")],
       proc { $idk[:settings].bike_and_surf_music },
       proc {|value| $idk[:settings].bike_and_surf_music=value },
       "Enables bike and surf music to play"
    ),
    EnumOption.new(_INTL("Bag Sorting"),[_INTL("By Name"),_INTL("By Type")],
       proc { $idk[:settings].bagsorttype },
       proc {|value| $idk[:settings].bagsorttype=value },
       "How to sort items in the bag."
    ),
    EnumOption.new(_INTL("Battle Scene"),[_INTL("On"),_INTL("Off")],
       proc { $idk[:settings].battlescene },
       proc {|value|  $idk[:settings].battlescene=value },
       "Show animations during battle."
    ),
    EnumOption.new(_INTL("Battle Style"),[_INTL("Shift"),_INTL("Set")],
       proc { $idk[:settings].battlestyle },
       proc {|value|  $idk[:settings].battlestyle=value }
    ),
    EnumOption.new(_INTL("Photosensitivity"),[_INTL("Off"),_INTL("On")],
       proc { $idk[:settings].photosensitive },
       proc {|value|  $idk[:settings].photosensitive=value },
       "Disables battle animations, screen flashes and shakes for photosensitivity."
    ),
    EnumOption.new(_INTL("Streamer mode"),[_INTL("Off"),_INTL("On")],
       proc { $idk[:settings].streamermode },
       proc {|value|  $idk[:settings].streamermode=value },
       "Hides private information for safety and compatibility."
    ),
    NumberOption.new(_INTL("Speech Frame"),_INTL("Type %d"),1,SpeechFrames.length,
       proc { $idk[:settings].textskin },
       proc {|value|  $idk[:settings].textskin=value;
          MessageConfig.pbSetSpeechFrame(
             "Graphics/Windowskins/"+SpeechFrames[value]) },
       proc { _INTL("Speech frame {1}.",1+$idk[:settings].textskin) }
    ),
    NumberOption.new(_INTL("Menu Frame"),_INTL("Type %d"),1,TextFrames.length,
       proc { $idk[:settings].frame },
       proc {|value|  
          $idk[:settings].frame=value
          MessageConfig.pbSetSystemFrame(TextFrames[value]) 
       },
       proc { _INTL("Menu frame {1}.",1+$idk[:settings].frame) }
    ),
    EnumOption.new(_INTL("Field UI highlights"),[_INTL("On"),_INTL("Off")],
       proc { $idk[:settings].field_effects_highlights},
       proc {|value|  $idk[:settings].field_effects_highlights=value },
       "Shows boxes around move if boosted or decreased by field effect."
    ),
    EnumOption.new(_INTL("Battle Cursor"),[_INTL("Fight"),_INTL("Last Used")],
       proc { $idk[:settings].remember_commands},
       proc {|value|  $idk[:settings].remember_commands=value },
       "Sets default position of cursor in battle."
    ),
    EnumOption.new(_INTL("Backup"),[_INTL("On"),_INTL("Off")],
       proc { $idk[:settings].backup },
       proc {|value|  $idk[:settings].backup=value },
       "Preserves overwritten files on each save for later recovery."
    ),
    NumberOption.new(_INTL("Max Backup Number"),_INTL("Type %d"),1,101,
       proc { $idk[:settings].maxBackup==999_999 ? 100 : $idk[:settings].maxBackup },
       proc {|value| value == 100 ? $idk[:settings].maxBackup=999_999 : $idk[:settings].maxBackup=value }, #+1 
      "The maximum number of backup save files to keep. (101 is infinite)"
    ),
    EnumOption.new(_INTL("Screen Size"),[_INTL("S"),_INTL("M"),_INTL("L"),_INTL("XL"),_INTL("Full")],
       proc { $idk[:settings].screensize },
       proc {|value|
          oldvalue=$idk[:settings].screensize
          $idk[:settings].screensize=value
          if value!=oldvalue
            pbSetResizeFactor($idk[:settings].screensize)
          end
       }
    ),    
    EnumOption.new(_INTL("Screen Border"),[_INTL("Off"),_INTL("On")],
       proc { $idk[:settings].border },
       proc {|value|
          oldvalue=$idk[:settings].border
          $idk[:settings].border=value
          if value!=oldvalue
            pbSetResizeFactor($idk[:settings].screensize)
          end
       }
    )]

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
       _INTL("Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    #@sprites["textbox"].text=_INTL("Speech frame {1}.",1+$idk[:settings].textskin)
    # These are the different options in the game.  To add an option, define a
    # setter and a getter for that option.  To delete an option, comment it out
    # or delete it.  The game's options may be placed in any order.
    ### YUMIL - 30 - BEGIN - BRAVELY DEFAULT-STYLE ENCOUNTER RATE
    if $game_switches && $game_switches[:Unreal_Time] == true
      utOpt1 = EnumOption.new(_INTL("Unreal Time"),[_INTL("Off"),_INTL("On")],
        proc { $idk[:settings].unrealTimeDiverge},
        proc {|value|  $idk[:settings].unrealTimeDiverge=value },
        "Uses in-game time instead of computer clock."
      )
      utOpt2 = EnumOption.new(_INTL("Show Clock"),[_INTL("Always"),_INTL("Menu"),_INTL("Gear")],
        proc { $idk[:settings].unrealTimeClock},
        proc {|value|  $idk[:settings].unrealTimeClock=value },
        "Shows an in-game clock that displays the current time."
      )
      utOpt3 = NumberOption.new(_INTL("Unreal Time Scale"),_INTL("Type %d"),1,60,
        proc { $idk[:settings].unrealTimeTimeScale-1 },
        proc {|value|  $idk[:settings].unrealTimeTimeScale=value+1 },
        "Sets the rate at which unreal time passes."
      )
      unless OptionList.any? {|opt| opt.name == "Unreal Time" }
        OptionList.push(utOpt1)
        OptionList.push(utOpt2)
        OptionList.push(utOpt3)
      end
    end
    if Desolation
      OptionList.push(NumberOption2.new(_INTL("Encounter Rate"),$EncounterValues,
         proc {if ! defined?($encountermultiplier)
         $encountermultiplier=1
         end
         $EncounterValues.index((($encountermultiplier*100).to_i).to_s)},
         proc {|value|  
         $encountermultiplier=($EncounterValues[value].to_f/100).to_f
         if defined?($game_map.map_id)
           $PokemonEncounters.setup($game_map.map_id)
         end
        } 
        ### YUMIL - 30 - END
      ))
    end
    @sprites["option"]=Window_PokemonOption.new(OptionList,0,
       @sprites["title"].height,Graphics.width,
       Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport=@viewport
    @sprites["option"].visible=true
    # Get the values of each option
    for i in 0...OptionList.length
      @sprites["option"][i]=(OptionList[i].get || 0)
    end
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbOptions
    pbActivateWindow(@sprites,"option"){
       loop do
         Graphics.update
         Input.update
         pbUpdate
         if @sprites["option"].mustUpdateOptions
           # Set the values of each option
           for i in 0...OptionList.length
             OptionList[i].set(@sprites["option"][i])
           end
           @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
           @sprites["textbox"].width=@sprites["textbox"].width  # Necessary evil
           pbSetSystemFont(@sprites["textbox"].contents)
           if @sprites["option"].options[@sprites["option"].index].description.is_a?(Proc)
            @sprites["textbox"].text=@sprites["option"].options[@sprites["option"].index].description.call
           else
            @sprites["textbox"].text=@sprites["option"].options[@sprites["option"].index].description
           end
         end
         if Input.trigger?(Input::B)
          saveClientData
           break
         end
         if Input.trigger?(Input::C) && @sprites["option"].index==OptionList.length
           break
         end
       end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    for i in 0...OptionList.length
      OptionList[i].set(@sprites["option"][i])
    end
    Kernel.pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
  end
end

$ResizeFactor=1.0
$ResizeFactorMul=100
$ResizeOffsetX=0 if !defined?($ResizeOffsetX)
$ResizeOffsetY=0 if !defined?($ResizeOffsetY)
$ResizeFactorSet=false if !defined?($ResizeFactorSet)
$HaveResizeBorder = false if !defined?($HaveResizeBorder)

def pbSetResizeFactor(factor)
  begin
    if factor < 0 || factor == 4
      setScreenBorder
      Graphics.resize_screen(DEFAULTSCREENWIDTH + 2*$ResizeOffsetX,DEFAULTSCREENHEIGHT+2*$ResizeOffsetY)
      setScreenBorderName("border")
      Graphics.fullscreen = true if !Graphics.fullscreen
      resizeSpritesAndViewports
    else
      setScreenBorder
      Graphics.resize_screen(DEFAULTSCREENWIDTH + 2*$ResizeOffsetX,DEFAULTSCREENHEIGHT+2*$ResizeOffsetY)
      Graphics.center
      setScreenBorderName("border")
      resizeSpritesAndViewports
      Graphics.fullscreen = false if Graphics.fullscreen
      Graphics.scale = [0.5,1,1.5,2.0][factor]
      Graphics.center
    end
  rescue
    factor = 2
    Graphics.fullscreen = false if Graphics.fullscreen
    Graphics.scale = [0.5,1,1.5,2.0][factor]
    Graphics.center
  end
end

def resizeSpritesAndViewports
  # Resize every sprite and viewport
  ObjectSpace.each_object(Sprite){|o|
    next if o.disposed?
    o.x=o.x
    o.y=o.y
    o.ox=o.ox
    o.oy=o.oy
    o.zoom_x=o.zoom_x
    o.zoom_y=o.zoom_y
  }
  ObjectSpace.each_object(Viewport){|o|
    next if o.disposed?
    begin
      o.rect=o.rect
      o.ox=o.ox
      o.oy=o.oy
    rescue RGSSError
    end
  }
end

def setScreenBorder
  $ResizeBorder=ScreenBorder.new if !$ResizeBorder || $ResizeBorder.sprite.disposed?
  $ResizeBorder.refresh
  border=$idk[:settings].border
  $ResizeOffsetX=[0,BORDERWIDTH][border]
  $ResizeOffsetY=[0,BORDERHEIGHT][border]
end

def setScreenBorderName(border)
  $ResizeBorder=ScreenBorder.new
  $HaveResizeBorder=true
  $ResizeBorder.bordername=border
end

class ScreenBorder
  attr_accessor :sprite
  def initialize
    initializeInternal
    refresh
  end

  def initializeInternal
    @maximumZ=500000
    @bordername=""
    @sprite=IconSprite.new(0,0) rescue Sprite.new
    @defaultwidth=640
    @defaultheight=480
    @defaultbitmap=Bitmap.new(@defaultwidth,@defaultheight)
  end

  def dispose
    @borderbitmap.dispose if @borderbitmap
    @defaultbitmap.dispose
    @sprite.dispose
  end

  def adjustZ(z)
    if z>=@maximumZ
      @maximumZ=z+1
      @sprite.z=@maximumZ
    end
  end

  def bordername=(value)
    @bordername=value
    refresh
  end

  def refresh
    @sprite.z=@maximumZ
    @sprite.x=-BORDERWIDTH
    @sprite.y=-BORDERHEIGHT
    @sprite.visible=($idk[:settings] && $idk[:settings].border==1)
    @sprite.bitmap=nil
    if @sprite.visible
      if @bordername!=nil && @bordername!=""
        setSpriteBitmap("Graphics/Pictures/"+@bordername)
      else
        setSpriteBitmap(nil)
        @sprite.bitmap=@defaultbitmap
      end
    end
    @defaultbitmap.clear
    @defaultbitmap.fill_rect(0,0,@defaultwidth,$ResizeOffsetY,Color.new(0,0,0))
    @defaultbitmap.fill_rect(0,$ResizeOffsetY,
       $ResizeOffsetX,@defaultheight-$ResizeOffsetY,Color.new(0,0,0))
    @defaultbitmap.fill_rect(@defaultwidth-$ResizeOffsetX,$ResizeOffsetY,
       $ResizeOffsetX,@defaultheight-$ResizeOffsetY,Color.new(0,0,0))
    @defaultbitmap.fill_rect($ResizeOffsetX,@defaultheight-$ResizeOffsetY,
       @defaultwidth-$ResizeOffsetX*2,$ResizeOffsetY,Color.new(0,0,0))
  end

  private

  def setSpriteBitmap(x)
    if (@sprite.is_a?(IconSprite) rescue false)
      @sprite.setBitmap(x)
    else
      @sprite.bitmap=x ? RPG::Cache.load_bitmap("",x) : nil
    end
  end
end

class PokemonOption
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbOptions
    @scene.pbEndScene
  end
end
