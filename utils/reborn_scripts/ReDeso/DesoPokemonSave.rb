class PokemonSaveScene

    def pbAutoSave(safesave=false)
        if $game_variables[27]>1
            savename="Game_"+$game_variables[27].to_s+"_autosave.rxdata"
        else
            savename="Game_autosave.rxdata"
        end
        begin
            File.open(RTP.getSaveFileName(savename),"wb"){|f|
            Marshal.dump($Trainer,f)
            Marshal.dump(Graphics.frame_count,f)
            if $cache.RXsystem.respond_to?("magic_number")
                $game_system.magic_number = $cache.RXsystem.magic_number
            else
                $game_system.magic_number = $cache.RXsystem.version_id
            end
            $game_system.save_count+=1
            Marshal.dump($game_system,f)
            Marshal.dump($PokemonSystem,f)
            #Marshal.dump($game_map.map_id,f)
            Marshal.dump($game_switches,f)
            Marshal.dump($game_variables,f)
            Marshal.dump($game_self_switches,f)
            Marshal.dump($game_screen,f)
            Marshal.dump($MapFactory,f)
            Marshal.dump($game_player,f)
            $PokemonGlobal.safesave=safesave
            Marshal.dump($PokemonGlobal,f)
            #Marshal.dump($PokemonMap,f)
            Marshal.dump($PokemonBag,f)
            Marshal.dump($PokemonStorage,f)
            ###Yumil - 36 - Quest Log - Begin
            Marshal.dump($QuestLog,f) 
            ###Yumil - 36 - Quest Log - End
            ###Yumil - 13 - NPC Reaction - Begin
            Marshal.dump($battleDataArray,f)
            ###Yumil - 13 - NPC Reaction - End
            }
            Graphics.frame_reset
            rescue
            return false
        end
        pbStoredLastPlayed($game_variables[27],true)
        return true
    end

    def pbSaveOld(safesave=false)
        $Trainer.metaID=$PokemonGlobal.playerID
        if $game_variables[27]>1
            savename="Game_"+$game_variables[27].to_s+".rxdata"
        else
            savename="Game.rxdata"
        end
        begin  
            File.open(RTP.getSaveFileName(savename),"wb"){|f|
                Marshal.dump($Trainer,f)
                playtime = Graphics.time_passed + 40*(Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i #turn into frames
                Marshal.dump(playtime,f)
                if $cache.RXsystem.respond_to?("magic_number")
                $game_system.magic_number = $cache.RXsystem.magic_number
                else
                $game_system.magic_number = $cache.RXsystem.version_id
                end
                $game_system.save_count+=1
                Marshal.dump($game_system,f)
                Marshal.dump($PokemonSystem,f)
                Marshal.dump($game_map.map_id,f)
                Marshal.dump($game_switches,f)
                Marshal.dump($game_variables,f)
                Marshal.dump($game_self_switches,f)
                Marshal.dump($game_screen,f)
                Marshal.dump($MapFactory,f)
                Marshal.dump($game_player,f)
                $PokemonGlobal.safesave=safesave
                Marshal.dump($PokemonGlobal,f)
                Marshal.dump($PokemonMap,f)
                Marshal.dump($PokemonBag,f)
                Marshal.dump($PokemonStorage,f)
                ###Yumil - Quest Log - Begin
                Marshal.dump($QuestLog,f)
                ###Yumil - Quest Log - End
                ###Yumil - 12 - NPC Reaction - Begin
                Marshal.dump($battleDataArray,f)
                ###Yumil - 12- NPC Reaction - End
            }
            Graphics.frame_reset
            rescue
            return false
        end
        pbStoredLastPlayed($game_variables[27],nil)
        return true
    end
end