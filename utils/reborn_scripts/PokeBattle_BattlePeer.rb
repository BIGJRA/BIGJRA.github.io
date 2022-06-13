class PokeBattle_RealBattlePeer
  def pbStorePokemon(player,pokemon)
    if player.party.length<6
      player.party[player.party.length]=pokemon
      return -1
    else
      monsent=false
      while !monsent
        if Kernel.pbConfirmMessageSerious(_INTL("The party is full; do you want to send a party member to the PC?"))
          iMon = -2 
          unusablecount = 0
          for i in $Trainer.party
            next if i.isEgg?
            next if i.hp < 1
            unusablecount += 1
          end
          pbFadeOutIn(99999){
            scene=PokemonScreen_Scene.new
            screen=PokemonScreen.new(scene,player.party)
            screen.pbStartScene(_INTL("Choose a Pokémon."),false)
            loop do
              iMon=screen.pbChoosePokemon
              if iMon < 0
                screen.pbEndScene
                break
              end
              if iMon>=0 && [:CUT, :ROCKSMASH, :STRENGTH, :SURF, :WATERFALL, :DIVE, :ROCKCLIMB, :FLASH, :FLY].any? {|tmmove| $Trainer.party[iMon].knowsMove?(tmmove)} && !$game_switches[:EasyHMs_Password]
                Kernel.pbMessage("You can't return a Pokémon that knows a TMX move to the PC.") 
                iMon=-2
              elsif unusablecount<=1 && !($Trainer.party[iMon].isEgg?) && $Trainer.party[iMon].hp>0 && pokemon.isEgg?
                Kernel.pbMessage("That's your last Pokémon!") 
              else
                if $Trainer.party[iMon].item != 0
                  if Kernel.pbConfirmMessage("This Pokémon is holding an item. Do you want to remove it?")
                    $PokemonBag.pbStoreItem($Trainer.party[iMon].item)
                    $Trainer.party[iMon].item=0
                    $Trainer.party[iMon].form=0 if ($Trainer.party[iMon].species==PBSpecies::ARCEUS || $Trainer.party[iMon].species==PBSpecies::GENESECT || $Trainer.party[iMon].species==PBSpecies::SILVALLY)
                  end
                end
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