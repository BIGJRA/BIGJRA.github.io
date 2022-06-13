def convertSaveFolder
    Dir.foreach(RTP.getSaveFolder) do |filename|
        next if filename == '.' or filename == '..'
        newsave = {}
        newsave[:trainer]    = Marshal.load(filename)
        newsave[:playtime]   = Marshal.load(filename)
        newsave[:system]     = Marshal.load(filename)
        Marshal.load(filename) # Current map id no longer needed
        newsave[:switches]  = Marshal.load(filename) # Why does removing these break shit
        newsave[:variable]  = Marshal.load(filename)
        newsave[:self_switches]     = Marshal.load(filename)
        newsave[:game_screen]   = Marshal.load(filename)
        newsave[:MapFactory]    = Marshal.load(filename)
        newsave[:game_player]   = Marshal.load(filename)
        newsave[:PokemonGlobal]     = Marshal.load(filename)
        newsave[:PokemonMap]    = Marshal.load(filename)
        newsave[:PokemonBag]    = Marshal.load(filename)
        newsave[:PokemonStorage]    = Marshal.load(filename)
    end
end

def makeSaveHash
    $Trainer.metaID=$PokemonGlobal.playerID
    playtime = Graphics.time_passed + 40*(Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i #turn into frames
    savehash = {}
    savehash[:Trainer]        = $Trainer
    savehash[:playtime]       = playtime
    savehash[:system]         = $game_system
    savehash[:switches]       = $game_switches
    savehash[:variable]       = $game_variables
    savehash[:self_switches]  = $game_self_switches
    savehash[:game_screen]    = $game_screen
    savehash[:MapFactory]      = $MapFactory
    savehash[:game_player]    = $game_player
    savehash[:Pokemonglobal]  = $PokemonGlobal
    savehash[:PokemonMap]     = $PokemonMap
    savehash[:PokemonBag]     = $PokemonBag
    savehash[:PokemonStorage] = $PokemonStorage
    
    return savehash
end
  
  def makeSaveFromHash(hash, name= "Anna's Wish Game")
    # Making the save file name
    if $game_variables[:Save_Slot]>1
      savename= name + "_"+$game_variables[:Save_Slot].to_s+".rxdata"
    else
      savename= name + ".rxdata"
    end
  
    # Saving the hash in a file
    File.open(RTP.getSaveFileName(savename),"wb"){|f|
      f.write(hash[:Trainer])
      f.write(hash[:playtime])
      f.write(hash[:system])
      f.write(hash[:map_id])
      f.write(hash[:switches])
      f.write(hash[:variable])
      f.write(hash[:self_switches])
      f.write(hash[:game_screen])
      f.write(hash[:MapFactory])
      f.write(hash[:game_player])
      f.write(hash[:Pokemonglobal])
      f.write(hash[:PokemonMap])
      f.write(hash[:PokemonBag])
      f.write(hash[:PokemonStorage])
    }
  end