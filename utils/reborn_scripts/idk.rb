def buildClientData
    $idk = {}
    $idk[:saveslot] = 1
    pokemonSystem=nil
    lastsavefile = RTP.getSaveFileName("LastSave.dat")
    if File.exists?(lastsavefile)
        $idk[:saveslot] = File.open(lastsavefile).first.to_i
    end
    File.delete(RTP.getSaveFileName("latest_save.txt")) if File.exists?(RTP.getSaveFileName("latest_save.txt"))
    $idk[:saveslot] = 1 if $idk[:saveslot] == 0
    savefile = RTP.getSaveSlotPath($idk[:saveslot])
    if File.exists?(savefile)
        File.open(savefile){|f|
            Marshal.load(f)
            Marshal.load(f)
            Marshal.load(f)
            settings = Marshal.load(f)
            if settings.is_a?(String)
                $idk[:settings]=PokemonOptions.new
            else
                $idk[:settings]=PokemonOptions.new(settings) 
            end
        }
    else
        $idk[:settings]=PokemonOptions.new
    end
    save_data($idk,RTP.getSaveFileName("Game.dat"))
end

def loadClientData
    begin
        File.open(RTP.getSaveFileName("Game.dat")){|f|
            $idk = Marshal.load(f)
        }
    rescue 
       print ("Client settings are corrupted and will be deleted. Save files will not be affected.") 
       File.delete(RTP.getSaveFileName("Game.dat")) if File.exist?(RTP.getSaveFileName("Game.dat"))
       buildClientData
    end
end

def saveClientData(data=$idk)
    save_data(data,RTP.getSaveFileName("Game.dat"))
end

def startup
    if !(File.exist?(RTP.getSaveFileName("Game.dat")))
        buildClientData
    else
        loadClientData
    end
    pbSetUpSystem
    
    
    Dir["./Data/Mods/*.rb"].each {|file| load File.expand_path(file) }
end

def getNGPData
    $idk[:starterQ] = ($game_variables[:Starter_Quest]>=21) if $idk[:starterQ] != true
    $idk[:magicS] = $game_switches[:Magic_Square_Done] if $idk[:magicS] != true
    $idk[:dexQ] = $game_switches[:Dex_Quest_Done] if $idk[:dexQ] != true
    #$idk[:spiritQ] = ($game_variables[:Spirit_Rewards]>=25) if $idk[:spiritQ] != true
    $idk[:treePuzzle] = ($game_variables[:Xernyvel]>=19) if $idk[:treePuzzle] != true
    $idk[:vrGem3] = $game_switches[:VR_Gem3] if $idk[:vrGem3] != true
    $idk[:vrGem4] = $game_switches[:VR_Gem4] if $idk[:vrGem4] != true
    $idk[:vrGem5] = $game_switches[:VR_Gem5] if $idk[:vrGem5] != true
    $idk[:southAv] = $game_switches[:HearPinsir_Puzzle] if $idk[:southAv] != true
    $idk[:chessPuzzle] = ($game_variables[:E10_Story]>=40) if $idk[:chessPuzzle] != true
    saveClientData
end