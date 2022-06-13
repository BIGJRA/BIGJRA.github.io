class PokeBattle_Battle

    def pbSendOut(index,pokemon)
        #AI CHANGES
        @aiMoveMemory[0].clear
        @aiMoveMemory[1].clear if !pbIsOpposing?(index)
        @ai.addMonToMemory(pokemon,index)
        pbSetSeen(pokemon)
        @peer.pbOnEnteringBattle(self,pokemon)
        if pbIsOpposing?(index)
            #  in-battle text
            #@scene.pbTrainerSendOut(index,pokemon)
            # Last Pokemon script; credits to venom12 and HelioAU
            processBattleStateChanges(index,pokemon)
        else
            processBattleStateChanges2(index,pokemon)
        end
        @scene.pbResetMoveIndex(index)
    end


###this is just the bit of code that process the state of the opponent's team
###when they send out their pokemon and displays text accordingly, shoved into
###it's own thing to modify it more easily.

    def processBattleStateChanges(index,pokemon)
        #  in-battle text      
       
        @scene.pbTrainerSendOut(index,pokemon)
        # Define any trainers that you want to activate this script below
        # For each defined trainer, add the BELOW section for them
        if !@opponent.is_a?(Array)
            trainertext = @opponent
            if pbPokemonCount(@party2)==1
                # Define any trainers that you want to activate this script below
                # For each defined trainer, add the BELOW section for the
                if isConst?(trainertext.trainertype,PBTrainers,:NOVA)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("Your fire... It's intensity..."))
                        @scene.pbHideOpponent
                    end
                elsif isConst?(trainertext.trainertype,PBTrainers,:ADERYN)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("You're soaring so high... But I can soar higher!"))
                        @scene.pbHideOpponent
                    end
                elsif isConst?(trainertext.trainertype,PBTrainers,:EMILY)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("It's time to OVERLOAD! WEEEEOW!"))
                        @scene.pbHideOpponent
                    end
                elsif isConst?(trainertext.trainertype,PBTrainers,:AMELIA2)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("I won't lose to you! Not again!"))
                        @scene.pbHideOpponent
                    end
                elsif isConst?(trainertext.trainertype,PBTrainers,:DREAMCATCHER)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("You're no different than the rest."))
                        @scene.pbHideOpponent
                    end
                elsif isConst?(trainertext.trainertype,PBTrainers,:RIVAL2)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("Not bad... You've improved."))
                        @scene.pbHideOpponent
                    end
                elsif isConst?(trainertext.trainertype,PBTrainers,:BLACKFOXACE)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("This isn't what I expected."))
                        @scene.pbHideOpponent
                    end
                elsif isConst?(trainertext.trainertype,PBTrainers,:NINJA)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("Tell me your dream!"))
                        @scene.pbHideOpponent
                    end
                elsif isConst?(trainertext.trainertype,PBTrainers,:ROSETTA)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("Your strength... it's beautiful!"))
                        @scene.pbHideOpponent
                    end
                elsif isConst?(trainertext.trainertype,PBTrainers,:FOXHARDY)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("Some things never change..."))
                        @scene.pbHideOpponent
                    end  
                elsif isConst?(trainertext.trainertype,PBTrainers,:ADERYN2)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("I can still fly higher, you know!"))
                        @scene.pbHideOpponent
                    end 
                elsif isConst?(trainertext.trainertype,PBTrainers,:AARON)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("You're tough, I'll give you that."))
                        @scene.pbHideOpponent
                    end 
                elsif isConst?(trainertext.trainertype,PBTrainers,:AGENT)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("You're pretty good, but it ain't over yet!"))
                        @scene.pbHideOpponent
                    end 
                elsif isConst?(trainertext.trainertype,PBTrainers,:GARRET)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("This ain't over yet, damn it!"))
                        @scene.pbHideOpponent
                    end 
                elsif isConst?(trainertext.trainertype,PBTrainers,:BARON)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("You don't know what you're dealing with..."))
                        @scene.pbHideOpponent
                    end 
                elsif isConst?(trainertext.trainertype,PBTrainers,:LILITH)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("You're playing right into their hands!"))
                        @scene.pbHideOpponent
                    end 
                elsif isConst?(trainertext.trainertype,PBTrainers,:SUPERNERD)
                    if $game_variables[192] == 0
                        @scene.pbShowOpponent(0)
                        pbDisplayPaused(_INTL("Oh, come on! This is a fluke!"))
                        @scene.pbHideOpponent
                    end 
                end
            end       
        # For each defined trainer, add the ABOVE section for them            
        end
    end

    def processBattleStateChanges2(index,pokemon)
        @scene.pbSendOut(index,pokemon)
    end
end