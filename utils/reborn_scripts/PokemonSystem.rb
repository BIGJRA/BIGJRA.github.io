
def pbChooseLanguage
  commands=[]
  for lang in LANGUAGES
    commands.push(lang[0])
  end
  return Kernel.pbShowCommands(nil,commands)
end

#############
#############

def pbSetUpSystem(tempsave=0,autosave=nil)
  if defined?($game_system)
    offsetX=[0,BORDERWIDTH][$idk[:settings].border]
    offsetY=[0,BORDERHEIGHT][$idk[:settings].border]
    setScreenBorderName("border")
    if Graphics.width != DEFAULTSCREENWIDTH || Graphics.height != DEFAULTSCREENHEIGHT || offsetX != $ResizeOffsetX || offsetY != $ResizeOffsetY
      $ResizeOffsetX=offsetX
      $ResizeOffsetY=offsetY
      $game_system=Game_System
      pbSetResizeFactor($idk[:settings].screensize)
    end
    $random_dex = nil
    $random_items = nil
    $random_moveset = nil
    $random_typeChart = nil
    $random_movedata = nil
  else
    $game_system=Game_System
    $ResizeOffsetX=0
    $ResizeOffsetY=0
    pbSetResizeFactor($idk[:settings].screensize)
  end
  MessageConfig.pbSetSystemFontName("PokemonEmerald")

  if LANGUAGES.length>=2
    if !havedata
      $idk[:settings].language=pbChooseLanguage
    end
    pbLoadMessages("Data/"+LANGUAGES[$idk[:settings].language][1])
  end
end

def pbScreenCapture
  capturefile=nil
  5000.times {|i|
     filename=RTP.getSaveFileName(sprintf("capture%03d.bmp",i))
     if !safeExists?(filename)
       capturefile=filename
       break
     end
     i+=1
  }
  begin
    Graphics.snap_to_bitmap.to_file(capturefile)
    pbSEPlay("expfull") if FileTest.audio_exist?("Audio/SE/expfull")
  rescue
    nil
  end
end

module Input
  unless defined?(update_KGC_ScreenCapture)
    class << Input
      alias update_KGC_ScreenCapture update
    end
  end

  def self.update
    update_KGC_ScreenCapture
    if trigger?(:F8)
      pbScreenCapture
    end
    if triggerex?(:LALT) || (triggerex?(:M) && Input.text_input != true) || triggerex?(:RALT)
      pbTurbo()
    end
    if triggerex?(:F7)
      if $game_system
        $game_system.toggle_mute
      end
    end
    if triggerex?(:F10) && $DEBUG
      if $is_profile != true
        $is_profile = true
        Kernel.pbMessage("Begin profiling")
        CP_Profiler.begin
      end
    end
    if triggerex?(:F11) && $DEBUG
      CP_Profiler.print
      $is_profile = false
    end
    if triggerex?(:F6) && $DEBUG
      begin
        Input.text_input = true
        code = Kernel.pbMessageFreeText(_INTL("What code would you like to run?"),"",false,999,500)
        eval(code)
        Input.text_input = false
      rescue
        pbPrintException($!)
        Input.text_input = false
      end
    end
  end
end

#for a soft-reset, let the speed-up persist
Graphics.frame_rate=120 if $speed_up

def pbTurbo()  
  if Graphics.frame_rate==40
    Graphics.frame_rate=120
    $speed_up = true
  else
    $speed_up = false
    Graphics.frame_rate=40
  end
end

def pbSetWindowText(string)
  System.set_window_title(string || System.game_title)
end

#I don't think this does anything, but the game doesn't load if I don't add it
class ControlConfig
  attr_reader :controlAction
  attr_accessor :keyCode
  
  def initialize(controlAction,defaultKey)
    @controlAction = controlAction
    @keyCode = Keys.getKeyCode(defaultKey)
  end
  
  def keyName
    return Keys.getKeyName(@keyCode)
  end  
end