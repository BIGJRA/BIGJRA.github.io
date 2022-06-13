# Loads data from a file "safely", similar to load_data. If an encrypted archive
# exists, the real file is deleted to ensure that the file is loaded from the
# encrypted archive.
def pbSafeLoad(file)
  if (safeExists?("./Game.rgssad") || safeExists?("./Game.rgss2a")) && safeExists?(file)
    File.delete(file) rescue nil
  end
  return load_data(file)
end

def pbLoadRxData(file) # :nodoc:
  if $RPGVX
    return load_data(file+".rvdata")
  else
    return load_data(file+".rxdata") 
  end
end

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
  begin
    trainer=nil
    framecount=0
    havedata=false
    game_system=nil
    pokemonSystem=nil
    if tempsave>1
      if autosave !=nil
         File.open(RTP.getSaveFileName("Game_"+tempsave.to_s+"_autosave.rxdata")){|f|
         trainer=Marshal.load(f)
         framecount=Marshal.load(f)
         game_system=Marshal.load(f)
         pokemonSystem=Marshal.load(f)
        }
      else
        File.open(RTP.getSaveFileName("Game_"+tempsave.to_s+".rxdata")){|f|
         trainer=Marshal.load(f)
         framecount=Marshal.load(f)
         game_system=Marshal.load(f)
         pokemonSystem=Marshal.load(f)
        }
      end  
    elsif  autosave !=nil
      File.open(RTP.getSaveFileName("Game_autosave.rxdata")){|f|
         trainer=Marshal.load(f)
         framecount=Marshal.load(f)
         game_system=Marshal.load(f)
         pokemonSystem=Marshal.load(f)
        }
    else
      filePicker = "Game_"
      filePicker = "Game_"  
      lastsave_location = RTP.getSaveFileName("LastSave.dat")
      strVar = File.open(lastsave_location, 'rb') {|f| f.readline}  
      strVar = strVar.strip  
      if strVar == "0"  
        filePicker = "Game"  
        strVar = nil  
      end
      File.open(RTP.getSaveFileName(filePicker.to_s+strVar.to_s+".rxdata")){|f|
       trainer=Marshal.load(f)
       framecount=Marshal.load(f)
       game_system=Marshal.load(f)
       pokemonSystem=Marshal.load(f)
    }
    end
    raise "Corrupted file" if !trainer.is_a?(PokeBattle_Trainer)
    raise "Corrupted file" if !framecount.is_a?(Numeric)
    raise "Corrupted file" if !game_system.is_a?(Game_System)
    raise "Corrupted file" if !pokemonSystem.is_a?(PokemonSystem)
    havedata=true
  rescue
    pokemonSystem=PokemonSystem.new
    game_system=Game_System.new
  end
  if !$INEDITOR
    $PokemonSystem=pokemonSystem
    $game_system=Game_System
    $ResizeOffsetX=0 #[0,0][$PokemonSystem.screensize]
    $ResizeOffsetY=0 #[0,0][$PokemonSystem.screensize]
    resizefactor=[0.5,1.0,2.0][$PokemonSystem.screensize]
    pbSetResizeFactor(resizefactor) 
  else
    pbSetResizeFactor(1.0)
  end
  # Load constants
  begin
    consts=pbSafeLoad("Data/Constants.rxdata")
    consts=[] if !consts
  rescue
    consts=[]
  end
  for script in consts
    next if !script
    eval(Zlib::Inflate.inflate(script[2]),nil,script[1])
  end
  if LANGUAGES.length>=2
    if !havedata
      pokemonSystem.language=pbChooseLanguage
    end
    pbLoadMessages("Data/"+LANGUAGES[pokemonSystem.language][1])
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
    if trigger?(:F7)
      pbDebugF7
    end
    if triggerex?(:LALT) || triggerex?(:M)
      pbTurbo()
    end
    if triggerex?(:F10)
      if $is_profile != true
        $is_profile = true
        Kernel.pbMessage("Begin profiling")
        CP_Profiler.begin
      end
    end
    if triggerex?(:F11)
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

def pbTurbo()  
  if Graphics.frame_rate==44
    $PokemonSystem.turbospeed = 2 if !$PokemonSystem.turbospeed
    case $PokemonSystem.turbospeed
    when 0
      Graphics.frame_rate=88
    when 1
      Graphics.frame_rate=110
    when 2
      Graphics.frame_rate=132
    when 3
      Graphics.frame_rate=176
    end
  else
    Graphics.frame_rate=44
  end
end

def pbDebugF7
  if $DEBUG
    Console::setup_console
    begin
      debugBitmaps
      rescue
    end
    pbSEPlay("expfull") if FileTest.audio_exist?("Audio/SE/expfull")
  end
end

pbSetUpSystem()