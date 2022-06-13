#####MODDED
Dir["./Data/Mods/*.rb"].each {|file| load File.expand_path(file) }
#####/MODDED

class Scene_DebugIntro
  def main
    Graphics.transition(0)
    lastsave_location = RTP.getSaveFileName("LastSave.dat")
    if File.exists?(lastsave_location)
      lastsave=pbGetLastPlayed
      if lastsave[1].to_s=="true"
        if lastsave[0]==0 || lastsave[0]==1
          savefile=RTP.getSaveFileName("Game_autosave.rxdata")
        else  
          savefile = RTP.getSaveFileName("Game_#{lastsave[0]}_autosave.rxdata")
        end 
      elsif lastsave[0]==0 || lastsave[0]==1
        savefile=RTP.getSaveFileName("Game.rxdata")
      else
        savefile = RTP.getSaveFileName("Game_#{lastsave[0]}.rxdata")
      end
      lastsave[1]=nil if lastsave[1]!="true"
      if safeExists?(savefile)
        sscene=PokemonLoadScene.new
        sscreen=PokemonLoad.new(sscene)
        sscreen.pbStartLoadScreen(lastsave[0].to_i,lastsave[1],"Save File #{lastsave[0]}")
      else
        sscene=PokemonLoadScene.new
        sscreen=PokemonLoad.new(sscene)
        sscreen.pbStartLoadScreen
      end
    else
      sscene=PokemonLoadScene.new
      sscreen=PokemonLoad.new(sscene)
      sscreen.pbStartLoadScreen
    end
    Graphics.freeze
  end
end

def pbCallTitle #:nodoc:
    # First parameter is an array of images in the Titles
    # directory without a file extension, to show before the
    # actual title screen.  Second parameter is the actual
    # title screen filename, also in Titles with no extension.
    splash_files = ['sp1', 'sp2', 'sp3', 'sp4', 'sp5', 'sp6']
    splash = splash_files[rand(splash_files.length)]
    return Scene_Intro.new(['intro1'], splash)
end

def mainFunction #:nodoc:
  if $DEBUG
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def mainFunctionDebug #:nodoc:
  begin
    $data_animations    = pbLoadRxData("Data/Animations")
    $data_tilesets      = pbLoadRxData("Data/Tilesets")
    $data_common_events = pbLoadRxData("Data/CommonEvents")
    $data_system        = pbLoadRxData("Data/System")
    $mapinfos           = load_data("Data/MapInfos.rxdata")
    $game_system        = Game_System.new

    #Game data preloading
    $pkmn_dex           = load_data("Data/dexdata.rxdata")
    $pkmn_move          = load_data("Data/moves.rxdata")
    
    setScreenBorderName("border") # Sets image file for the border
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    while $scene != nil
      $scene.main
    end
    Graphics.transition(20)
  rescue Hangup
    pbEmergencySave
    raise
  end
end

loop do
  retval=mainFunction
  if retval==0 # failed
    loop do
      Graphics.update
    end
  elsif retval==1 # ended successfully
    break
  end
end

#Audio.mci_eval('close all')
