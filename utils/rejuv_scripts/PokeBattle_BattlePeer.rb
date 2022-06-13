class PokeBattle_RealBattlePeer
  def pbStorePokemon(player,pokemon)
    if player.party.length<6
      player.party[player.party.length]=pokemon
      return -1
    else
      monsent=false
      while !monsent
        if !$game_switches[1235] && Kernel.pbConfirmMessageSerious(_INTL("The party is full; do you want to send someone to the PC?"))
          iMon = -2 
          eggcount = 0
          for i in $Trainer.party
            next if i.isEgg?
            eggcount += 1
          end
          pbFadeOutIn(99999){
            scene=PokemonScreen_Scene.new
            screen=PokemonScreen.new(scene,player.party)
            screen.pbStartScene(_INTL("Choose a Pokémon."),false)
            loop do
              iMon=screen.pbChoosePokemon
              if iMon>=0 && ($Trainer.party[iMon].knowsMove?(:CUT) || $Trainer.party[iMon].knowsMove?(:ROCKSMASH) || $Trainer.party[iMon].knowsMove?(:STRENGTH) || $Trainer.party[iMon].knowsMove?(:SURF) || $Trainer.party[iMon].knowsMove?(:WATERFALL) || $Trainer.party[iMon].knowsMove?(:DIVE) || $Trainer.party[iMon].knowsMove?(:ROCKCLIMB) || $Trainer.party[iMon].knowsMove?(:FLASH) || $Trainer.party[iMon].knowsMove?(:FLY))
                Kernel.pbMessage("You can't return a Pokémon that knows a TMX move to the PC.") 
                iMon=-2
              elsif eggcount<=1 && !($Trainer.party[iMon].isEgg?) && pokemon.isEgg?
                Kernel.pbMessage("That's your last Pokémon!") 
              else
                screen.pbEndScene
                break
              end
            end
          }
          if !(iMon < 0)
            iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
            if iBox >= 0
              monsent=true
              player.party[iMon].heal
              Kernel.pbMessage(_INTL("{1} was sent to {2}.", player.party[iMon].name, $PokemonStorage[iBox].name))
              player.party[iMon] = nil
              player.party.compact!
              player.party[player.party.length]=pokemon
              return -1
            else
              Kernel.pbMessage("No space left in the PC")
              return false
            end
          end      
        else
          monsent=true
          pokemon.heal
          oldcurbox=$PokemonStorage.currentBox
          storedbox=$PokemonStorage.pbStoreCaught(pokemon)
          if storedbox<0
            pbDisplayPaused(_INTL("Can't catch any more..."))
            return oldcurbox
          else
            return storedbox
          end
        end
      end      
    end
  end

  def pbGetStorageCreator()
    creator=nil
    if $PokemonGlobal && $PokemonGlobal.seenStorageCreator
      creator=Kernel.pbGetStorageCreator
    end
    return creator
  end

  def pbCurrentBox()
    return $PokemonStorage.currentBox
  end

  def pbBoxName(box)
   return box<0 ? "" : $PokemonStorage[box].name
  end
end



class PokeBattle_BattlePeer
  def self.create
    return PokeBattle_RealBattlePeer.new
  end
end