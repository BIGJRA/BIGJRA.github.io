#===============================================================================
# This script implements items included by default in Pokemon Essentials.
#===============================================================================

#===============================================================================
# UseFromBag handlers
# Return values: 0 = not used
#                1 = used, item not consumed
#                2 = close the Bag to use, item not consumed
#                3 = used, item consumed
#                4 = close the Bag to use, item consumed
#===============================================================================

def pbRepel(item,steps)
  if $PokemonGlobal.repel>0
    Kernel.pbMessage(_INTL("But the effects of a Repel lingered from earlier."))
    return 0
  else
    Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
    $PokemonGlobal.repel=steps
    return 3
  end
end

def pbNecrozmaMoves(pokemon)
  moves=[
    PBMoves::CONFUSION,        # Normal
    PBMoves::SUNSTEELSTRIKE,  # Dusk Mane
    PBMoves::MOONGEISTBEAM,   # Dawn Wings
  ]
  if pokemon.form!=3
    moves.each{|movething|
      pbDeleteMoveByID(pokemon,movething)
    }
    pokemon.pbLearnMove(moves[pokemon.form])
  end
end

ItemHandlers::UseFromBag.add(:REPEL,proc{|item|  pbRepel(item,200)  })

ItemHandlers::UseFromBag.add(:SUPERREPEL,proc{|item|  pbRepel(item,400)  })

ItemHandlers::UseFromBag.add(:MAXREPEL,proc{|item|  pbRepel(item,500)  })

Events.onStepTaken+=proc {
   if $game_player.terrain_tag!=PBTerrain::Ice   # Shouldn't count down if on ice
     if $PokemonGlobal.repel>0
       $PokemonGlobal.repel-=1
       if $PokemonGlobal.repel<=0
        $game_switches[:Stop_Arrows_Shooting] = true
        $game_switches[:Stop_Icycle_Falling] = true
        Kernel.pbMessage(_INTL("Repel's effect wore off..."))
        ret=pbChooseItemFromList(_INTL("Do you want to use another Repel?"),1,:REPEL,:SUPERREPEL,:MAXREPEL)
         pbUseItem($PokemonBag,ret) if ret>0
         $game_switches[:Stop_Arrows_Shooting] = false
         $game_switches[:Stop_Icycle_Falling] = false
       end
     end
   end
}

ItemHandlers::UseFromBag.add(:BLACKFLUTE,proc{|item|
   Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
   Kernel.pbMessage(_INTL("Wild Pokémon will be repelled."))
   $PokemonMap.blackFluteUsed=true
   $PokemonMap.whiteFluteUsed=false
   next 1
})

ItemHandlers::UseFromBag.add(:WHITEFLUTE,proc{|item|
   Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
   Kernel.pbMessage(_INTL("Wild Pokémon will be lured."))
   $PokemonMap.blackFluteUsed=false
   $PokemonMap.whiteFluteUsed=true
   next 1
})

ItemHandlers::UseFromBag.add(:HONEY,proc{|item|  next 4  })

ItemHandlers::UseFromBag.add(:ESCAPEROPE,proc{|item|
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     next 0
   end
   if ($PokemonGlobal.escapePoint rescue false) && $PokemonGlobal.escapePoint.length>0
     next 4 # End screen and consume item
   else
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
   end
})

ItemHandlers::UseFromBag.add(:SACREDASH,proc{|item|
   revived=0
   if $Trainer.pokemonCount==0
     Kernel.pbMessage(_INTL("There is no Pokémon."))
     next 0
   end
   pbFadeOutIn(99999){
      scene=PokemonScreen_Scene.new
      screen=PokemonScreen.new(scene,$Trainer.party)
      screen.pbStartScene(_INTL("Using item..."),false)
      for i in $Trainer.party
       if i.hp<=0 && !i.isEgg?
         revived+=1
         i.heal
         screen.pbDisplay(_INTL("{1}'s HP was restored.",i.name))
       end
     end
     if revived==0
       screen.pbDisplay(_INTL("It won't have any effect."))
     end
     screen.pbEndScene
   }
   next (revived==0) ? 0 : 3
})


# 0 not used, 1 used but not consumed
ItemHandlers::UseFromBag.add(:EXPALL,proc{|item|
   if $game_switches[:Exp_All_On]
     if Kernel.pbConfirmMessage(_INTL("Exp. All is currently ON, would you like to turn it OFF?"))
       $game_switches[:Exp_All_On] = false
       next 1
     else
       next 0
     end
   else
     if Kernel.pbConfirmMessage(_INTL("Exp. All is currently OFF, would you like to turn it ON?"))
       $game_switches[:Exp_All_On] = true
       next 1
     else
       next 0
     end
   end        
})

ItemHandlers::UseFromBag.add(:BICYCLE,proc{|item|
   next pbBikeCheck ? 2 : 0
})

ItemHandlers::UseFromBag.add(:REMOTEPC,proc{|item|
  if $game_variables[:E4_Tracker] > 0
    Kernel.pbMessage(_INTL("Cannot use the Remote PC here."))
    next 0
  end
  if $game_switches[:Free_Remote_PC] == true
    pbPokeCenterPC
    next 1
  end
  if $PokemonBag.pbQuantity(PBItems::CELLBATTERY) > 0
    Kernel.pbMessage(_INTL("Used a Cell Battery to power the PC."))
    $PokemonBag.pbDeleteItem(PBItems::CELLBATTERY)
    pbPokeCenterPC
    next 1
  else
    Kernel.pbMessage(_INTL("No Cell Battery to power the PC."))
    next 0
  end
})

#ItemHandlers::UseFromBag.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

ItemHandlers::UseFromBag.add(:OLDROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if ((pbIsWaterTag?(terrain) || pbIsGrimeTag?(terrain)) && !$PokemonGlobal.surfing && notCliff) ||
      (pbIsWaterTag?(terrain) && $PokemonGlobal.surfing)
 next 2
   else
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
   end
})
ItemHandlers::UseFromBag.copy(:OLDROD,:GOODROD,:SUPERROD)

ItemHandlers::UseFromBag.add(:ITEMFINDER,proc{|item| next 2 })

ItemHandlers::UseFromBag.copy(:ITEMFINDER,:DOWSINGMCHN)

ItemHandlers::UseFromBag.add(:TOWNMAP,proc{|item|
   pbShowMap(-1,false)
   next 1 # Continue
})

ItemHandlers::UseFromBag.add(:MEMBERSHIPCARD,proc{|item|
   # Kernel.pbMessage(_INTL("Stickers: {1}",$game_variables[175]))
   $game_switches[:Show_Department_Card] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:BLUEORB3,proc{|item|
  $game_switches[:Blue_Orb_Quest] = true
  next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:COINCASE,proc{|item|
   Kernel.pbMessage(_INTL("Coins: {1}",$PokemonGlobal.coins))
   next 1 # Continue
}) 

#ItemHandlers::UseFromBag.add(:POKEBLOCKCASE,proc{|item| next 2 })

ItemHandlers::UseFromBag.add(:SPIRITTRACKER,proc{|item|
   Kernel.pbMessage(_INTL("Spirits Released: {1}",$game_variables[548]))
   next 1 # Continue
})

ItemHandlers::UseFromBag.add(:GATHERCUBE,proc{|item|
  Kernel.pbMessage(_INTL("Z-cells gathered: {1}",$game_variables[590]))
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:SPYCEAPP,proc{|item|  
  $game_variables[330] = 1
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:LIBRARYAPP,proc{|item|  
  $game_variables[330] = 2
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:SWEETAPP,proc{|item|  
  $game_variables[330] = 3
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:CRITICALAPP,proc{|item|  
  $game_variables[330] = 4
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:MEDICINEAPP,proc{|item|  
  $game_variables[330] = 5
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:SALONAPP,proc{|item|  
  $game_variables[330] = 6
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:GLAMAPP,proc{|item|  
  $game_variables[330] = 7
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:NIGHTCLUBAPP,proc{|item|  
  $game_variables[330] = 8
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:CYCLEAPP,proc{|item|  
  $game_variables[330] = 9
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:SILPHAPP,proc{|item|  
  $game_variables[330] = 10
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:CIRCUSAPP,proc{|item|  
  $game_variables[330] = 11
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:SOLICEAPP,proc{|item|  
  $game_variables[330] = 12
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:CONSTRUCTIONAPP,proc{|item|  
  $game_variables[330] = 13
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})

ItemHandlers::UseFromBag.add(:APOPHYLLAPP,proc{|item|  
  $game_variables[330] = 14
  $game_switches[:Get_A_Job_Quest] = true
   next 2 # Close without consuming
})
#===============================================================================
# UseOnPokemon handlers
#===============================================================================

ItemHandlers::UseOnPokemon.add(:FIRESTONE,proc{|item,pokemon,scene|
   if item != PBItems::LINKSTONE
     newspecies=pbCheckEvolution(pokemon,item)
   else
     newspecies=pbTradeCheckEvolution(pokemon,item)
   end
    if (pokemon.isShadow? rescue false)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
   if newspecies<=0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pbFadeOutInWithMusic(99999){
        evo=PokemonEvolutionScene.new
        evo.pbStartScreen(pokemon,newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
        if item != PBItems::LINKSTONE
          scene.pbRefreshAnnotations(proc{|p| pbCheckEvolution(p,item)>0 })
        else
          scene.pbRefreshAnnotations(proc{|p| pbTradeCheckEvolution(p,item,true)>0 })
        end
        scene.pbRefresh
     }
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:FIRESTONE,
   :THUNDERSTONE,:WATERSTONE,:LEAFSTONE,:MOONSTONE,
   :SUNSTONE,:DUSKSTONE,:DAWNSTONE,:SHINYSTONE,:LINKSTONE,:ICESTONE)
   
ItemHandlers::UseOnPokemon.add(:POTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.add(:SUPERPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,60,scene)
})

ItemHandlers::UseOnPokemon.add(:HYPERPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,120,scene)
})

ItemHandlers::UseOnPokemon.add(:ULTRAPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,200,scene)
})

ItemHandlers::UseOnPokemon.add(:MAXPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,pokemon.totalhp-pokemon.hp,scene)
})

ItemHandlers::UseOnPokemon.add(:BERRYJUICE,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:SWEETHEART,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.add(:FRESHWATER,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,30,scene)
})

ItemHandlers::UseOnPokemon.add(:SODAPOP,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,50,scene)
})

ItemHandlers::UseOnPokemon.add(:LEMONADE,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,70,scene)
})

ItemHandlers::UseOnPokemon.add(:BUBBLETEA,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,180,scene)
})

ItemHandlers::UseOnPokemon.add(:MEMEONADE,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,103,scene)
})

ItemHandlers::UseOnPokemon.add(:VANILLAIC,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,30,scene)
     pokemon.changeHappiness("candy")
     next true
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:CHOCOLATEIC,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,70,scene)
     pokemon.changeHappiness("candy")
     next true
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:STRAWBIC,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,90,scene)
     pokemon.changeHappiness("candy")
     next true
   end
   next false

})

ItemHandlers::UseOnPokemon.add(:BLUEMIC,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,200,scene)
     pokemon.changeHappiness("bluecandy")
     next true
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:MOOMOOMILK,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,100,scene)
})

ItemHandlers::UseOnPokemon.add(:ORANBERRY,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,10,scene)
})

ItemHandlers::UseOnPokemon.add(:SITRUSBERRY,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,(pokemon.totalhp/4.0).floor,scene)
})

ItemHandlers::UseOnPokemon.add(:AWAKENING,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::SLEEP
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} woke up.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:AWAKENING,:CHESTOBERRY,:BLUEFLUTE,:POKEFLUTE)

ItemHandlers::UseOnPokemon.add(:ANTIDOTE,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::POISON
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its poisoning.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:ANTIDOTE,:PECHABERRY)

ItemHandlers::UseOnPokemon.add(:BURNHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::BURN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s burn was healed.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:BURNHEAL,:RAWSTBERRY)

ItemHandlers::UseOnPokemon.add(:PARLYZHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::PARALYSIS
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of paralysis.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:PARLYZHEAL,:CHERIBERRY)

ItemHandlers::UseOnPokemon.add(:ICEHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::FROZEN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was thawed out.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

ItemHandlers::UseOnPokemon.add(:FULLHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:BIGMALASADA,:LUMBERRY,:MEDICINE)

ItemHandlers::UseOnPokemon.add(:FULLRESTORE,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && pokemon.hp==pokemon.totalhp)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     hpgain=pbItemRestoreHP(pokemon,pokemon.totalhp-pokemon.hp)
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     if hpgain>0
       scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pokemon.name,hpgain))
     else
       scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     end
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:REVIVE,proc{|item,pokemon,scene|
   if pokemon.hp>0 || $game_switches[:Nuzlocke_Mode]==true
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=(pokemon.totalhp/2.0).floor
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:REVIVE,proc{|item,pokemon,scene|
   if pokemon.hp>0 || $game_switches[:Nuzlocke_Mode]==true
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=1+(pokemon.totalhp/2.0).floor
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:PEPPERMINT,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::POISON
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its poisoning.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CHEWINGGUM,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::PARALYSIS
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its paralysis.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:REDHOTS,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::FROZEN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} thawed out.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:SALTWATERTAFFY,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::BURN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s burn was healed.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:POPROCKS,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::SLEEP
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} woke up.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:COTTONCANDY,proc{|item,pokemon,scene|
   if pokemon.hp>0 || $game_switches[:Nuzlocke_Mode]==true
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=1+(pokemon.totalhp/2.0).floor
     pokemon.hp=1 if pokemon.hp <= 0
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:POKESNAX,proc{|item,pokemon,scene|
   if pokemon.happiness==255
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.changeHappiness("level up")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} ate the Pokesnax happily!",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:MAXREVIVE,proc{|item,pokemon,scene|
   if pokemon.hp>0 || $game_switches[:Nuzlocke_Mode]==true
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=pokemon.totalhp
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:ENERGYPOWDER,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,60,scene)
     pokemon.changeHappiness("powder")
     next true
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:ENERGYROOT,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,120,scene)
     pokemon.changeHappiness("Energy Root")
     next true
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:HEALPOWDER,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     pokemon.changeHappiness("powder")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:REVIVALHERB,proc{|item,pokemon,scene|
   if pokemon.hp>0 || $game_switches[:Nuzlocke_Mode]==true
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=pokemon.totalhp
     pokemon.changeHappiness("Revival Herb")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})


ItemHandlers::BattleUseOnPokemon.add(:PEPPERMINT,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::POISON
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its poisoning.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:CHEWINGGUM,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::PARALYSIS
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its paralysis.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REDHOTS,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::FROZEN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} thawed out.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:SALTWATERTAFFY,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::BURN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s burn was healed.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:POPROCKS,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::SLEEP
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} woke up.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:COTTONCANDY,proc{|item,pokemon,battler,scene|
   if pokemon.hp>0 || $game_switches[:Nuzlocke_Mode]==true
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=(pokemon.totalhp/2.0)
     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbReset if battler
         #battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     pokemon.changeHappiness("candy")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})
ItemHandlers::UseOnPokemon.add(:ETHER,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbRestorePP(pokemon,move,10)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
      scene.pbDisplay(_INTL("PP was restored."))
      next true
    end
  end
  next false
})

ItemHandlers::UseOnPokemon.copy(:ETHER,:LEPPABERRY)

ItemHandlers::UseOnPokemon.add(:MAXETHER,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbRestorePP(pokemon,move,pokemon.moves[move].totalpp-pokemon.moves[move].pp)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       scene.pbDisplay(_INTL("PP was restored."))
       next true
     end
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:ELIXIR,proc{|item,pokemon,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbRestorePP(pokemon,i,10)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:MAXELIXIR,proc{|item,pokemon,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbRestorePP(pokemon,i,pokemon.moves[i].totalpp-pokemon.moves[i].pp)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:PPUP,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Boost PP of which move?"))
   if move>=0
     if pokemon.moves[move].totalpp==0 || pokemon.moves[move].ppup>=3
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       pokemon.moves[move].ppup+=1
       movename=PBMoves.getName(pokemon.moves[move].id)
       scene.pbDisplay(_INTL("{1}'s PP increased.",movename))
       next true
     end
   end
})

ItemHandlers::UseOnPokemon.add(:PPMAX,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Boost PP of which move?"))
   if move>=0
     if pokemon.moves[move].totalpp==0 || pokemon.moves[move].ppup>=3
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       pokemon.moves[move].ppup=3
       movename=PBMoves.getName(pokemon.moves[move].id)
       scene.pbDisplay(_INTL("{1}'s PP increased.",movename))
       next true
     end
   end
})

ItemHandlers::UseOnPokemon.add(:PPALL,proc{|item,pokemon,scene|
  for i in 0..3
    hasmoves = true if pokemon.moves[i].totalpp!=0 && pokemon.moves[i].ppup<3
  end 
  if !hasmoves
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    for i in 0..3
      next if pokemon.moves[i].totalpp==0
      pokemon.moves[i].ppup=3
    end 
    scene.pbDisplay(_INTL("The PP of {1}'s moves was maximixed.",pokemon.name))
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:HPUP,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,0)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:PROTEIN,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,1)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:IRON,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,2)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CALCIUM,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,4)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:ZINC,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,5)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CARBOS,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,3)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Speed increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:HEALTHWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,0,4,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP increased.",pokemon.name))
     pokemon.changeHappiness("wing")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:MUSCLEWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,1,4,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Attack increased.",pokemon.name))
     pokemon.changeHappiness("wing")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:RESISTWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,2,4,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Defense increased.",pokemon.name))
     pokemon.changeHappiness("wing")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:GENIUSWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,4,4,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Attack increased.",pokemon.name))
     pokemon.changeHappiness("wing")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CLEVERWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,5,4,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Defense increased.",pokemon.name))
     pokemon.changeHappiness("wing")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:SWIFTWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,3,4,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Speed increased.",pokemon.name))
     pokemon.changeHappiness("wing")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:PRISONBOTTLE,proc{|item,pokemon,scene|
   if (pokemon.species == PBSpecies::HOOPA) && pokemon.form==0 &&
      pokemon.hp>=0
     pokemon.form=1
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
     next true
    elsif (pokemon.species == PBSpecies::HOOPA) && pokemon.form==1 &&
      pokemon.hp>=0
     pokemon.form=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
     next true
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

##################################################################################
# Z Crystals                                                                     #
##################################################################################
ItemHandlers::UseOnPokemon.add(:BUGINIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::BUGINIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:BUGINIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:BUGINIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:DARKINIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::DARKINIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:DARKINIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:DARKINIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:DRAGONIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::DRAGONIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:DRAGONIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:DRAGONIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:ELECTRIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::ELECTRIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:ELECTRIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:ELECTRIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:FAIRIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::FAIRIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:FAIRIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:FAIRIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:FIGHTINIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::FIGHTINIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:FIGHTINIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:FIGHTINIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:FIRIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::FIRIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:FIRIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:FIRIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:FLYINIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::FLYINIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:FLYINIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:FLYINIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:GHOSTIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::GHOSTIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:GHOSTIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:GHOSTIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:GRASSIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::GRASSIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:GRASSIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:GRASSIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:GROUNDIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::GROUNDIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:GROUNDIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:GROUNDIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:ICIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::ICIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:ICIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:ICIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:NORMALIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::NORMALIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:NORMALIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:NORMALIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:POISONIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::POISONIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:POISONIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:POISONIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:PSYCHIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::PSYCHIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:PSYCHIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:PSYCHIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:ROCKIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::ROCKIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:ROCKIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:ROCKIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:STEELIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::STEELIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:STEELIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:STEELIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:WATERIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::WATERIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:WATERIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:WATERIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:ALORAICHIUMZ,proc{|item,pokemon,scene|
  canquip=false
  unless pokemon.item==PBItems::ALORAICHIUMZ2
    canequip=true      
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:ALORAICHIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:ALORAICHIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:DECIDIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::DECIDIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:DECIDIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:DECIDIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:INCINIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::INCINIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:INCINIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:INCINIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:PRIMARIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::PRIMARIUMZ2
    canequip=true
  end
  if canequip   
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:PRIMARIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:PRIMARIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:EEVIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::EEVIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:EEVIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:EEVIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:PIKANIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::PIKANIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:PIKANIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:PIKANIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:SNORLIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::SNORLIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:SNORLIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:SNORLIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MEWNIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::MEWNIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:MEWNIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:MEWNIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:TAPUNIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::TAPUNIUMZ2
    canequip=true
  end
  if canequip
     scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
     if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:TAPUNIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:TAPUNIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MARSHADIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::MARSHADIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:MARSHADIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:MARSHADIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:KOMMONIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::KOMMONIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:KOMMONIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:KOMMONIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})


ItemHandlers::UseOnPokemon.add(:LYCANIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::LYCANIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:LYCANIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:LYCANIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MIMIKIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::MIMIKIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:MIMIKIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:MIMIKIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:SOLGANIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::SOLGANIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:SOLGANIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:SOLGANIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:LUNALIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::LUNALIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:LUNALIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:LUNALIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:ULTRANECROZIUMZ,proc{|item,pokemon,scene|
  canequip=false
  unless pokemon.item==PBItems::ULTRANECROZIUMZ2
    canequip=true
  end
  if canequip
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(:ULTRANECROZIUMZ2)
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          pokemon.form = pokemon.getForm(pokemon)
          next true
        end
      end
    else
      pokemon.setItem(:ULTRANECROZIUMZ2)
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      pokemon.form = pokemon.getForm(pokemon)
      next true      
    end
  else       
    itemname=PBItems.getName(pokemon.item)
    scene.pbDisplay(_INTL("{1} is already holding one {2}.",pokemon.name,itemname))
    next false
  end
})
##################################################################################
# End of Z Crystals                                                              #
##################################################################################
 
def pbChangeLevel(pokemon,newlevel,scene)
  newlevel=1 if newlevel<1
  newlevel=PBExperience::MAXLEVEL if newlevel>PBExperience::MAXLEVEL
  return Kernel.pbMessage(_INTL("{1}'s level remained unchanged.",pokemon.name)) if pokemon.level==newlevel

  # Stat differences
  oldlevel = pokemon.level
  attackdiff  = pokemon.attack
  defensediff = pokemon.defense
  speeddiff   = pokemon.speed
  spatkdiff   = pokemon.spatk
  spdefdiff   = pokemon.spdef
  totalhpdiff = pokemon.totalhp
  

  # General new level stuff
  pokemon.level=newlevel
  pokemon.poklevel = newlevel
  pokemon.calcStats
  scene.pbRefresh

  # Change in stats
  attackdiff=pokemon.attack-attackdiff
  defensediff=pokemon.defense-defensediff
  speeddiff=pokemon.speed-speeddiff
  spatkdiff=pokemon.spatk-spatkdiff
  spdefdiff=pokemon.spdef-spdefdiff
  totalhpdiff=pokemon.totalhp-totalhpdiff

  # Message
  if oldlevel > newlevel
    Kernel.pbMessage(_INTL("{1} was downgraded to Level {2}!",pokemon.name,pokemon.level))
  else
    pokemon.changeHappiness("level up")
    Kernel.pbMessage(_INTL("{1} was elevated to Level {2}!",pokemon.name,pokemon.level))
  end

  # Show stat changes
  pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
    totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
  pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
    pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
  
  
  if newlevel > oldlevel
    # New moves learned in region
    movelist=pokemon.getMoveList
    for i in movelist
      if i[0]<=pokemon.level && i[0] > oldlevel
        pbLearnMove(pokemon,i[1],true)
      end
    end

    # Possible evolution
    newspecies=pbCheckEvolution(pokemon)
    if newspecies>0
      pbFadeOutInWithMusic(99999){
         evo=PokemonEvolutionScene.new
         evo.pbStartScreen(pokemon,newspecies)
         evo.pbEvolution
         evo.pbEndScreen
      }
    end
  end
end


def IncreaseExp(pokemon, exp, scene) # For Exp Candies
  newexp=PBExperience.pbAddExperience(pokemon.exp,exp,pokemon.growthrate)
  exp=newexp-pokemon.exp
  oldlevel=pokemon.level
  if exp>0
    scene.pbDisplay(_INTL("{1} gained {2} Exp. Points!",pokemon.name,exp))
    newlevel=PBExperience.pbGetLevelFromExperience(newexp,pokemon.growthrate)
    tempexp=0
    curlevel=pokemon.level
    if newlevel<curlevel
      debuginfo="#{pokemon.name}: #{pokemon.level}/#{newlevel} | #{pokemon.exp}/#{newexp} | gain: #{exp}"
      raise RuntimeError.new(_INTL("The new level ({1}) is less than the Pokémon's\r\ncurrent level ({2}), which shouldn't happen.\r\n[Debug: {3}]",
                             newlevel,curlevel,debuginfo))
      return
    end
    attackdiff=pokemon.attack
    defensediff=pokemon.defense
    speeddiff=pokemon.speed
    spatkdiff=pokemon.spatk
    spdefdiff=pokemon.spdef
    totalhpdiff=pokemon.totalhp
    passedlevels = []
    loop do
      # EXP Bar increment
      startexp=PBExperience.pbGetStartExperience(curlevel,pokemon.growthrate)
      endexp=PBExperience.pbGetStartExperience(curlevel+1,pokemon.growthrate)
      tempexp2=(endexp<newexp) ? endexp : newexp
      pokemon.exp=tempexp2
      tempexp1=tempexp2
      curlevel+=1
      if curlevel>newlevel
        pokemon.calcStats 
        break
      else
        passedlevels.push(curlevel)
      end
      pokemon.poklevel = newlevel 
      pokemon.changeHappiness("level up")
      pokemon.calcStats
    end
    if pokemon.level>oldlevel
      attackdiff=pokemon.attack-attackdiff
      defensediff=pokemon.defense-defensediff
      speeddiff=pokemon.speed-speeddiff
      spatkdiff=pokemon.spatk-spatkdiff
      spdefdiff=pokemon.spdef-spdefdiff
      totalhpdiff=pokemon.totalhp-totalhpdiff
      scene.pbDisplay(_INTL("{1} grew to Level {2}!",pokemon.name,newlevel))
      pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
                       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
      pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                       pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
    
      # New moves learned
      movelist=pokemon.getMoveList
      for j in passedlevels
        for i in movelist
          if i[0] == j          
            pbLearnMove(pokemon,i[1],true)
          end
        end
      end

      # Evolution
      newspecies=pbCheckEvolution(pokemon)
      if newspecies>0
        pbFadeOutInWithMusic(99999){
          evo=PokemonEvolutionScene.new
          evo.pbStartScreen(pokemon,newspecies)
          evo.pbEvolution
          evo.pbEndScreen
        }
      end
    end
  end
end

ItemHandlers::UseOnPokemon.add(:RARECANDY,proc{|item,pokemon,scene, amount=1|
  finallevelcap = 100 + $game_variables[:Extended_Max_Level]
  if pokemon.level>=PBExperience::MAXLEVEL || (pokemon.isShadow? rescue false) || (pokemon.level >= finallevelcap) || $game_switches[:No_EXP_Gain]==true
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  else
    amount = amount
    amount = PBExperience::MAXLEVEL - pokemon.level if PBExperience::MAXLEVEL - pokemon.level < amount
    amount = finallevelcap - pokemon.level if finallevelcap - pokemon.level < amount
    pbChangeLevel(pokemon,pokemon.level+amount,scene)
    scene.pbHardRefresh
    next true, amount
  end
})

ItemHandlers::UseOnPokemon.add(:COMMONCANDY,proc{|item,pokemon,scene|
   if pokemon.level==1 || (pokemon.isShadow? rescue false)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pbChangeLevel(pokemon,pokemon.level-1,scene)
     pokemon.changeHappiness("badcandy")
     scene.pbHardRefresh
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE,proc{|item,pokemon,scene|
  form       = pokemon.form
  tempabil   = pokemon.abilityIndex
  abilid     = pokemon.ability
  abillist   = pokemon.getAbilityList
  name       = pokemon.getFormName
  
  if abillist.length == 1 || pokemon.species == PBSpecies::ZYGARDE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end

  commands=[]
  command_option=[]
  abils = []
  for i in abillist.keys
    next if abillist[i] == abilid
    next if abils.include?(abillist[i])
    commands.push((i < 2 ? "" : "(H) ") + PBAbilities.getName(abillist[i]))
    command_option.push(i)
    abils.push(abillist[i])
  end
  
  cmd=scene.pbShowCommands("Which ability would you like to change to?",commands)
  next false if cmd==-1
  
  pokemon.setAbility(command_option[cmd])
  scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!",pokemon.name,PBAbilities.getName(pokemon.ability)))
  next true
})

def pbRaiseHappinessAndLowerEV(pokemon,scene,ev,messages)
  if pokemon.happiness==255 && pokemon.ev[ev]==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  elsif pokemon.happiness==255
    pokemon.ev[ev]-=20
    pokemon.ev[ev]=0 if pokemon.ev[ev]<0
    pokemon.calcStats
    scene.pbRefresh
    scene.pbDisplay(messages[0])
    return true
  elsif pokemon.ev[ev]==0
    pokemon.changeHappiness("EV berry")
    scene.pbRefresh
    scene.pbDisplay(messages[1])
    return true
  else
    pokemon.changeHappiness("EV berry")
    pokemon.ev[ev]-=20
    pokemon.ev[ev]=0 if pokemon.ev[ev]<0
    pokemon.calcStats
    scene.pbRefresh
    scene.pbDisplay(messages[2])
    return true
  end
end

def pbResetEVStat(pokemon,scene,ev,messages)
  if pokemon.ev[ev]==0 && messages[0] != "skip"
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  else
    pokemon.ev[ev]=0
    pokemon.calcStats
    scene.pbRefresh
    if messages[0] != "skip"
      scene.pbDisplay(messages[0])
    end
    return true
  end
end


ItemHandlers::UseOnPokemon.add(:POMEGBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,0,[
      _INTL("{1} adores you!\nThe base HP fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base HP can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base HP fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:KELPSYBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,1,[
      _INTL("{1} adores you!\nThe base Attack fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Attack can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Attack fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:QUALOTBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,2,[
      _INTL("{1} adores you!\nThe base Defense fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Defense can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Defense fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:HONDEWBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,4,[
      _INTL("{1} adores you!\nThe base Special Attack fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Special Attack can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Special Attack fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:GREPABERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,5,[
      _INTL("{1} adores you!\nThe base Special Defense fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Special Defense can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Special Defense fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:TAMATOBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,3,[
      _INTL("{1} adores you!\nThe base Speed fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Speed can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Speed fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:HPRESETBAG,proc{|item,pokemon,scene|
   next pbResetEVStat(pokemon,scene,0,[
      _INTL("{1} forgot it's HP training!\nIt's base HP was reset!",pokemon.name),
   ])
})

ItemHandlers::UseOnPokemon.add(:ATKRESETBAG,proc{|item,pokemon,scene|
   next pbResetEVStat(pokemon,scene,1,[
      _INTL("{1} forgot its Attack training!\nIts base Attack was reset!",pokemon.name),
   ])
})

ItemHandlers::UseOnPokemon.add(:DEFRESETBAG,proc{|item,pokemon,scene|
   next pbResetEVStat(pokemon,scene,2,[
      _INTL("{1} forgot its Defense training!\nIts base Defense was reset!",pokemon.name),
   ])
})

ItemHandlers::UseOnPokemon.add(:SPARESETBAG,proc{|item,pokemon,scene|
   next pbResetEVStat(pokemon,scene,4,[
      _INTL("{1} forgot its Sp. Attack training!\nIts base Sp. Attack was reset!",pokemon.name),
   ])
})

ItemHandlers::UseOnPokemon.add(:SPDRESETBAG,proc{|item,pokemon,scene|
   next pbResetEVStat(pokemon,scene,5,[
      _INTL("{1} forgot its Sp. Defense training!\nIts base Sp. Defense was reset!",pokemon.name),
   ])
})

ItemHandlers::UseOnPokemon.add(:SPERESETBAG,proc{|item,pokemon,scene|
   next pbResetEVStat(pokemon,scene,3,[
      _INTL("{1} forgot its Speed training!\nIts base Speed was reset!",pokemon.name),
   ])
})

ItemHandlers::UseOnPokemon.add(:FULLRESETBAG,proc{|item,pokemon,scene|
   pbResetEVStat(pokemon,scene,0,["skip"]) 
   pbResetEVStat(pokemon,scene,1,["skip"])
   pbResetEVStat(pokemon,scene,2,["skip"])
   pbResetEVStat(pokemon,scene,3,["skip"])
   pbResetEVStat(pokemon,scene,4,["skip"])
   pbResetEVStat(pokemon,scene,5,["skip"])
   scene.pbDisplay(_INTL("{1} forgot all its training!\nIts base stats were reset!",pokemon.name))
})

ItemHandlers::UseOnPokemon.add(:EVTUNER,proc{|item,pokemon,scene|
  #make stat list
  stats=STATSTRINGS
  evcommands=[]
  ret=false
  loop do
    for i in 0...stats.length
      evcommands.push(stats[i]+" (#{pokemon.ev[i]})")
    end
    cmd=0
    #Show menu with stats to chose from
    cmd=scene.pbShowCommands("Select first EV stat to swap.",evcommands)
    if cmd==-1#cancelled
      break
    elsif cmd>=0 && cmd<stats.length #choose first stat
      evcommands2=[]
      loop do
        for i in 0...stats.length
          if i==cmd
            evcommands2.push("[X]" + stats[i]+" (#{pokemon.ev[i]})")
          else
            evcommands2.push(stats[i]+" (#{pokemon.ev[i]})")
          end
        end
        cmd2=0
        #Show menu with stats to chose from
        cmd2=scene.pbShowCommands("Select second EV stat to swap with first one.",evcommands2)
        if cmd2==-1 #cancelled
          break
        elsif cmd==cmd2 #chose same stat
          scene.pbDisplay("Can't swap a stat with itself!")
          break
        elsif cmd2>=0 && cmd2<stats.length #chose second stat
          if Kernel.pbConfirmMessage(_INTL("Do you want to swap #{pokemon.name}'s #{stats[cmd]} stat with its #{stats[cmd2]} stat?"))
            pokemon.ev[cmd], pokemon.ev[cmd2] = pokemon.ev[cmd2], pokemon.ev[cmd]
            scene.pbDisplay("Swapped the two stats EVs around!")
            pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
              pokemon.ev[0],pokemon.ev[1],pokemon.ev[2],pokemon.ev[4],pokemon.ev[5],pokemon.ev[3]))
            ret=true
            pokemon.calcStats
          end
          break
        end
      end
      break
    end
  end
  next ret
})

ItemHandlers::UseOnPokemon.add(:EVBOOSTER,proc{|item,pokemon,scene|
  #make stat list
  stats=STATSTRINGS
  ret=false
  if pokemon.ev.sum >=510 && !$game_switches[:No_Total_EV_Cap]
    scene.pbDisplay("#{pokemon.name} already reached its max EVs!")
    next ret
  elsif pokemon.ev.sum >=1512 && $game_switches[:No_Total_EV_Cap]
    scene.pbDisplay("#{pokemon.name} already reached its max EVs!")
    next ret
  end
  loop do
    evcommands=[]
    for i in 0...stats.length
      evcommands.push(stats[i]+" (#{pokemon.ev[i]})")
    end
    cmd=0
    #Show menu with stats to chose from
    cmd=scene.pbShowCommands("Select which EV stat to boost.",evcommands)
    if cmd==-1 #cancelled
      break
    elsif cmd>=0 && cmd<stats.length #choose first stat
      if pokemon.ev[cmd] >= 252
        scene.pbDisplay("The #{stats[cmd]} stat is already maxed!")
        next
      end
      if Kernel.pbConfirmMessage(_INTL("Do you want to boost #{pokemon.name}'s #{stats[cmd]} stat?"))
        evs_left = 510 - pokemon.ev.sum
        if evs_left > 252 - pokemon.ev[cmd]
          pokemon.ev[cmd] = 252 
        else
          pokemon.ev[cmd] += evs_left
        end
        scene.pbDisplay("Boosted the #{stats[cmd]} stat!")
        scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
          pokemon.ev[0],pokemon.ev[1],pokemon.ev[2],pokemon.ev[4],pokemon.ev[5],pokemon.ev[3]))
        ret=true
        pokemon.calcStats
      end
      break
    end
  end
  next ret
})

##################################################################################
# New Gen 8 Items
##################################################################################

ItemHandlers::UseOnPokemon.add(:EXPCANDYXS,proc{|item,pokemon,scene,amount=1|
  if pokemon.level>=PBExperience::MAXLEVEL || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end
  exp = 100 * amount
  result = LevelLimitExpGain(pokemon, exp)

  if result == -1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end

  exp = result
  amount_consumed = (result / 100.0).ceil
  IncreaseExp(pokemon, exp, scene)
  
  scene.pbHardRefresh
  next true, amount_consumed
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYS,proc{|item,pokemon,scene,amount=1|
  if pokemon.level>=PBExperience::MAXLEVEL || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end
  exp = 800 * amount
  result = LevelLimitExpGain(pokemon, exp)

  if result == -1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end

  exp = result
  amount_consumed = (result / 800.0).ceil
  IncreaseExp(pokemon, exp, scene)
  
  scene.pbHardRefresh
  next true, amount_consumed
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYM,proc{|item,pokemon,scene,amount=1|
  if pokemon.level>=PBExperience::MAXLEVEL || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end
  exp = 3000 * amount
  result = LevelLimitExpGain(pokemon, exp)

  if result == -1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end

  exp = result
  amount_consumed = (result / 3000.0).ceil
  IncreaseExp(pokemon, exp, scene)
  
  scene.pbHardRefresh
  next true, amount_consumed
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYL,proc{|item,pokemon,scene,amount=1|
  if pokemon.level>=PBExperience::MAXLEVEL || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end
  exp = 10000 * amount
  result = LevelLimitExpGain(pokemon, exp)

  if result == -1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end

  exp = result
  amount_consumed = (result / 10000.0).ceil
  IncreaseExp(pokemon, exp, scene)
  
  scene.pbHardRefresh
  next true, amount_consumed
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYXL,proc{|item,pokemon,scene,amount=1|
  if pokemon.level>=PBExperience::MAXLEVEL || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end
  exp = 30000 * amount
  result = LevelLimitExpGain(pokemon, exp)

  if result == -1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false, 0
  end
  
  exp = result
  amount_consumed = (result / 30000.0).ceil
  IncreaseExp(pokemon, exp, scene)
  
  scene.pbHardRefresh
  next true, amount_consumed
})

ItemHandlers::UseOnPokemon.add(:ADAMANTMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::ADAMANT || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::ADAMANT)
    scene.pbDisplay(_INTL("{1} becomes Adamant!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:LONELYMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::LONELY || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::LONELY)
    scene.pbDisplay(_INTL("{1} feels Lonely!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:NAUGHTYMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::NAUGHTY || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::NAUGHTY)
    scene.pbDisplay(_INTL("{1} becomes Naughty!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:BRAVEMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::BRAVE || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::BRAVE)
    scene.pbDisplay(_INTL("{1} becomes Brave!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:BOLDMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::BOLD || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::BOLD)
    scene.pbDisplay(_INTL("{1} becomes Bold!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:IMPISHMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::IMPISH || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::IMPISH)
    scene.pbDisplay(_INTL("{1} becomes Impish!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:LAXMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::LAX || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::LAX)
    scene.pbDisplay(_INTL("{1} becomes Lax!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:RELAXEDMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::RELAXED || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::RELAXED)
    scene.pbDisplay(_INTL("{1} feels Relaxed!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:MODESTMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::MODEST || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::MODEST)
    scene.pbDisplay(_INTL("{1} becomes Modest!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:MILDMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::MILD || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::MILD)
    scene.pbDisplay(_INTL("{1} becomes Mild!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:RASHMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::RASH || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::RASH)
    scene.pbDisplay(_INTL("{1} becomes Rash!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:QUIETMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::QUIET || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::QUIET)
    scene.pbDisplay(_INTL("{1} becomes Quiet!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:CALMMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::CALM || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::CALM)
    scene.pbDisplay(_INTL("{1} feels Calm!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:GENTLEMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::GENTLE || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::GENTLE)
    scene.pbDisplay(_INTL("{1} becomes Gentle!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:CAREFULMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::CAREFUL || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::CAREFUL)
    scene.pbDisplay(_INTL("{1} becomes Careful!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:SASSYMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::SASSY || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::SASSY)
    scene.pbDisplay(_INTL("{1} becomes Sassy!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:TIMIDMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::TIMID || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::TIMID)
    scene.pbDisplay(_INTL("{1} becomes Timid!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:HASTYMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::HASTY || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::HASTY)
    scene.pbDisplay(_INTL("{1} becomes Hasty!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:JOLLYMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::JOLLY || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::JOLLY)
    scene.pbDisplay(_INTL("{1} feels Jolly!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:NAIVEMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::NAIVE || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::NAIVE)
    scene.pbDisplay(_INTL("{1} becomes Naive!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:SERIOUSMINT,proc{|item,pokemon,scene|
  if pokemon.nature==PBNatures::SERIOUS || (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pokemon.setNature(PBNatures::SERIOUS)
    scene.pbDisplay(_INTL("{1} becomes Serious!",pokemon.name))
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:CELLIMPRINT, proc {|item,pokemon,scene|
  ivsmaxed = true
  ivnames = STATSTRINGS
  ivorder = [0,1,2,4,5,3]
  listindexes = []
  possible_ivs = []
  for i in ivorder
    if pokemon.iv[i] != 31
      ivsmaxed = false
      listindexes.push(i)
      possible_ivs.push(ivnames[i] + ": " + pokemon.iv[i].to_s)
    end
  end
  if ivsmaxed
    scene.pbDisplay(_INTL("All of {1}'s IVs are already maxed out.",pokemon.name))
    next false
  else
    possible_ivs.push("Cancel")
    ret = Kernel.pbMessage(_INTL("Which IV would you like to max?"),possible_ivs,possible_ivs.length)
    if ret == possible_ivs.length-1
      next false
    else
      pokemon.iv[listindexes[ret]]=31
      scene.pbDisplay(_INTL("{1}'s {2} was maxed out!",pokemon.name , ivnames[listindexes[ret]]))
      pokemon.calcStats
      next true
    end
  end
})

ItemHandlers::UseOnPokemon.add(:NEGATIVEIMPRINT, proc {|item,pokemon,scene|
  ivsminned = true
  ivnames = STATSTRINGS
  ivorder = [0,1,2,4,5,3]
  listindexes = []
  possible_ivs = []
  for i in ivorder
    if pokemon.iv[i] != 0
      ivsminned = false
      listindexes.push(i)
      possible_ivs.push(ivnames[i] + ": " + pokemon.iv[i].to_s)
    end
  end
  if ivsminned
    scene.pbDisplay(_INTL("All of {1}'s IVs are already minimized.",pokemon.name))
    next false
  else
    possible_ivs.push("Cancel")
    ret = Kernel.pbMessage(_INTL("Which IV would you like to minimize?"),possible_ivs,possible_ivs.length)
    if ret == possible_ivs.length-1
      next false
    else
      pokemon.iv[listindexes[ret]]=0
      scene.pbDisplay(_INTL("{1}'s {2} was minimized!",pokemon.name , ivnames[listindexes[ret]]))
      pokemon.calcStats
      next true
    end
  end
})

##################################################################################
# New Gen 8 Items end
##################################################################################

ItemHandlers::UseOnPokemon.add(:GRACIDEA,proc{|item,pokemon,scene|
   if (pokemon.species == PBSpecies::SHAYMIN) && pokemon.hp>=0 && pokemon.status!=PBStatuses::FROZEN
     if pokemon.form == 0
      pokemon.form = 1 
     elsif pokemon.form == 1
      pokemon.form = 0
     end
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
     next true
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:REVEALGLASS,proc{|item,pokemon,scene|
   if ((pokemon.species == PBSpecies::TORNADUS) ||
      (pokemon.species == PBSpecies::THUNDURUS) ||
      (pokemon.species == PBSpecies::LANDORUS)) && pokemon.hp>=0
     pokemon.form=(pokemon.form==0) ? 1 : 0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
     next true
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS,proc{|item,pokemon,scene|
   if (pokemon.species == PBSpecies::KYUREM) && pokemon.hp>=0
     if pokemon.fused!=nil
       if $Trainer.party.length>=6
         scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.",pokemon.name))
         next false
       else
         $Trainer.party[$Trainer.party.length]=pokemon.fused
         pokemon.fused=nil
         pokemon.form=0
         scene.pbHardRefresh
         scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
         next true
       end
     else
       chosen=scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
       if chosen>=0
         poke2=$Trainer.party[chosen]
         if (isConst?(poke2.species,PBSpecies,:RESHIRAM) ||
            isConst?(poke2.species,PBSpecies,:ZEKROM)) && poke2.hp>=0
           pokemon.form=1 if isConst?(poke2.species,PBSpecies,:RESHIRAM)
           pokemon.form=2 if isConst?(poke2.species,PBSpecies,:ZEKROM)
           pokemon.fused=poke2
           pbRemovePokemonAt(chosen)
           scene.pbHardRefresh
           scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
           next true
         elsif pokemon==poke2
           scene.pbDisplay(_INTL("{1} can't be fused with itself!",pokemon.name))
         else
           scene.pbDisplay(_INTL("{1} can't be fused with {2}.",poke2.name,pokemon.name))
         end
       else
         next false
       end
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:NSOLARIZER,proc{|item,pokemon,scene|
   if (pokemon.species == PBSpecies::NECROZMA) && pokemon.hp>=0
     if pokemon.fused!=nil
       if $Trainer.party.length>=6
         scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.",pokemon.name))
         next false
       else
         $Trainer.party[$Trainer.party.length]=pokemon.fused
         pokemon.fused=nil
         pokemon.form=0
         scene.pbHardRefresh
         scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
         pbNecrozmaMoves(pokemon)
         next true
       end
     else
       chosen=scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
       if chosen>=0
         poke2=$Trainer.party[chosen]
         if isConst?(poke2.species,PBSpecies,:SOLGALEO) && poke2.hp>=0
           pokemon.form=1
           pokemon.fused=poke2
           pbRemovePokemonAt(chosen)
           scene.pbHardRefresh
           scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
           pbNecrozmaMoves(pokemon)
           next true
         elsif pokemon==poke2
           scene.pbDisplay(_INTL("{1} can't be fused with itself!",pokemon.name))
         elsif isConst?(poke2.species,PBSpecies,:LUNALA)
           scene.pbDisplay(_INTL("This item can't fuse {1} with {2}.",poke2.name,pokemon.name))
         else
           scene.pbDisplay(_INTL("{1} can't be fused with {2}.",poke2.name,pokemon.name))
         end
       else
         next false
       end
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:NLUNARIZER,proc{|item,pokemon,scene|
   if (pokemon.species == PBSpecies::NECROZMA) && pokemon.hp>=0
     if pokemon.fused!=nil
       if $Trainer.party.length>=6
         scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.",pokemon.name))
         next false
       else
         $Trainer.party[$Trainer.party.length]=pokemon.fused
         pokemon.fused=nil
         pokemon.form=0
         scene.pbHardRefresh
         scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
         pbNecrozmaMoves(pokemon)
         next true
       end
     else
       chosen=scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
       if chosen>=0
         poke2=$Trainer.party[chosen]
         if isConst?(poke2.species,PBSpecies,:LUNALA) && poke2.hp>=0
           pokemon.form=2
           pokemon.fused=poke2
           pbRemovePokemonAt(chosen)
           scene.pbHardRefresh
           scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
           pbNecrozmaMoves(pokemon)
           next true
         elsif pokemon==poke2
           scene.pbDisplay(_INTL("{1} can't be fused with itself!",pokemon.name))
          elsif isConst?(poke2.species,PBSpecies,:SOLGALEO)
           scene.pbDisplay(_INTL("This item can't fuse {1} with {2}.",poke2.name,pokemon.name))
         else
           scene.pbDisplay(_INTL("{1} can't be fused with {2}.",poke2.name,pokemon.name))
         end
       else
         next false
       end
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:REDNECTAR,proc{|item,pokemon,scene|
   if (pokemon.species == PBSpecies::ORICORIO) && pokemon.form!=0 &&
      pokemon.hp>=0 
     pokemon.form=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} transformed!",pokemon.name))
     next true
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:YELLOWNECTAR,proc{|item,pokemon,scene|
   if (pokemon.species == PBSpecies::ORICORIO) && pokemon.form!=1 &&
      pokemon.hp>=0 
     pokemon.form=1
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} transformed!",pokemon.name))
     next true
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:PINKNECTAR,proc{|item,pokemon,scene|
   if (pokemon.species == PBSpecies::ORICORIO) && pokemon.form!=2 &&
      pokemon.hp>=0 
     pokemon.form=2
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} transformed!",pokemon.name))
     next true
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:PURPLENECTAR,proc{|item,pokemon,scene|
   if (pokemon.species == PBSpecies::ORICORIO) && pokemon.form!=3 &&
      pokemon.hp>=0 
     pokemon.form=3
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} transformed!",pokemon.name))
     next true
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})
#===============================================================================
# UseInField handlers
#===============================================================================

ItemHandlers::UseInField.add(:HONEY,proc{|item|  
   Kernel.pbMessage(_INTL("{1} used the {2}!",$Trainer.name,PBItems.getName(item)))
   pbSweetScent
})

ItemHandlers::UseInField.add(:ESCAPEROPE,lambda{|item|
   escape=($PokemonGlobal.escapePoint rescue nil)
   if !escape || escape==[]
     Kernel.pbMessage(_INTL("Can't use that here."))
     next
   end
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     next
   end
   Kernel.pbMessage(_INTL("{1} used the Escape Rope.",$Trainer.name))
   pbFadeOutIn(99999){
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id=escape[0]
      $game_temp.player_new_x=escape[1]
      $game_temp.player_new_y=escape[2]
      $game_temp.player_new_direction=escape[3]
      pbToneChangeAll(Tone.new(-255,-255,-255),0)
      $scene.transfer_player
      pbToneChangeAll(Tone.new(0,0,0),8)
      $game_map.autoplay
      $game_map.refresh
      if pbIsWaterTag?(Kernel.pbFacingTerrainTag) && !$PokemonGlobal.surfing 
        $PokemonEncounters.clearStepCount
        $PokemonGlobal.surfing=true
        $game_switches[:Faux_Surf]=true
        $game_map.refresh
        Kernel.pbUpdateVehicle      
      end      
      $game_variables[:Forced_Field_Effect] = 0
   }
   pbEraseEscapePoint
  #$game_screen.setWeather
})

ItemHandlers::UseInField.add(:BICYCLE,proc{|item|
   if pbBikeCheck
     if $PokemonGlobal.bicycle
       Kernel.pbDismountBike
     else
       Kernel.pbMountBike 
     end
   end
})

ItemHandlers::UseInField.add(:REMOTEPC,proc{|item|
  if $game_variables[:E4_Tracker] > 0
    Kernel.pbMessage(_INTL("Cannot use the Remote PC here."))
    next 0
  end
  if $game_switches[:Free_Remote_PC] == true
    pbPokeCenterPC
    next 1
  end
  if $PokemonBag.pbQuantity(PBItems::CELLBATTERY) > 0
    Kernel.pbMessage(_INTL("Used a Cell Battery to power the PC."))
    $PokemonBag.pbDeleteItem(PBItems::CELLBATTERY)
    pbPokeCenterPC
    next 1
  else
    Kernel.pbMessage(_INTL("No Cell Battery to power the PC."))
    next 0
  end
})

#ItemHandlers::UseInField.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

ItemHandlers::UseInField.add(:OLDROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
 if (!pbIsWaterTag?(terrain) && !pbIsGrimeTag?(terrain)) || 
     (!notCliff && !$PokemonGlobal.surfing)
     Kernel.pbMessage(_INTL("Can't use that here.")) 
     next
   end
   encounter=$PokemonEncounters.hasEncounter?(EncounterTypes::OldRod)
   if pbFishing(encounter,1)
     pbEncounter(EncounterTypes::OldRod)
   end
})

ItemHandlers::UseInField.add(:GOODROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
 if (!pbIsWaterTag?(terrain) && !pbIsGrimeTag?(terrain)) || 
     (!notCliff && !$PokemonGlobal.surfing)
     Kernel.pbMessage(_INTL("Can't use that here.")) 
     next
   end
   encounter=$PokemonEncounters.hasEncounter?(EncounterTypes::GoodRod)
   if pbFishing(encounter,2)
     pbEncounter(EncounterTypes::GoodRod)
   end
})

ItemHandlers::UseInField.add(:SUPERROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
     if (!pbIsWaterTag?(terrain) && !pbIsGrimeTag?(terrain)) || 
     (!notCliff && !$PokemonGlobal.surfing)
     Kernel.pbMessage(_INTL("Can't use that here.")) 
     next
   end
   encounter=$PokemonEncounters.hasEncounter?(EncounterTypes::SuperRod)
   if pbFishing(encounter,3)
     pbEncounter(EncounterTypes::SuperRod)
   end
})

ItemHandlers::UseInField.add(:ITEMFINDER,proc{|item|
   event=pbClosestHiddenItem
   pbSEPlay("itemfinder1")   
   if !event
     Kernel.pbMessage(_INTL("... ... ... ...Nope!\r\nThere's no response."))
   else
     offsetX=event.x-$game_player.x
     offsetY=event.y-$game_player.y
     if offsetX==0 && offsetY==0
       for i in 0...32
         Graphics.update
         Input.update
         $game_player.turn_right_90 if (i&7)==0
         pbUpdateSceneMap
       end
       $scene.spriteset.addUserAnimation(PLANT_SPARKLE_ANIMATION_ID,event.x,event.y,true)
       Kernel.pbMessage(_INTL("The {1}'s indicating something right underfoot!\1",PBItems.getName(item)))
     else
       direction=$game_player.direction
       if offsetX.abs>offsetY.abs
         direction=(offsetX<0) ? 4 : 6         
       else
         direction=(offsetY<0) ? 8 : 2
       end
       for i in 0...8
         Graphics.update
         Input.update
         if i==0
           $game_player.turn_down if direction==2
           $game_player.turn_left if direction==4
           $game_player.turn_right if direction==6
           $game_player.turn_up if direction==8
         end
         pbUpdateSceneMap
       end
       $scene.spriteset.addUserAnimation(PLANT_SPARKLE_ANIMATION_ID,event.x,event.y,true)
      # Kernel.pbMessage(_INTL("Huh?\nThe {1}'s responding!\1",PBItems.getName(item)))
      # Kernel.pbMessage(_INTL("There's an item buried around here!"))
     end
   end
})

ItemHandlers::UseInField.copy(:ITEMFINDER,:DOWSINGMCHN)

ItemHandlers::UseInField.add(:TOWNMAP,proc{|item|
   pbShowMap(-1,false)
})

ItemHandlers::UseInField.add(:COINCASE,proc{|item|
   Kernel.pbMessage(_INTL("Coins: {1}",$PokemonGlobal.coins))
   next 1 # Continue
})

ItemHandlers::UseInField.add(:MEMBERSHIPCARD,proc{|item|
   # Kernel.pbMessage(_INTL("Stickers: {1}",$game_variables[175]))
   $game_switches[:Show_Department_Card] = true
   next 2 # Close without consuming
})

ItemHandlers::UseInField.add(:SPIRITTRACKER,proc{|item|
   Kernel.pbMessage(_INTL("Spirits Released: {1}",$game_variables[548]))
   next 1 # Continue
})

#ItemHandlers::UseInField.add(:POKEBLOCKCASE,proc{|item|
#   Kernel.pbMessage(_INTL("Can't use that here."))   
#})

ItemHandlers::UseInField.add(:BLUEORB3,proc{|item|
   $game_switches[:Blue_Orb_Quest] = true
   next 2 # Close without consuming
})

#===============================================================================
# BattleUseOnPokemon handlers
#===============================================================================

ItemHandlers::BattleUseOnPokemon.add(:POTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SUPERPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,60,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:HYPERPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,120,scene)
})
 
ItemHandlers::BattleUseOnPokemon.add(:ULTRAPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,200,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MAXPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,pokemon.totalhp-pokemon.hp,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:BERRYJUICE,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:RAGECANDYBAR,proc{|item,pokemon,battler,scene|
 if pokemon.hp<=0 || (pokemon.status==0 && (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:SWEETHEART,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FRESHWATER,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,30,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SODAPOP,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,50,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:VANILLAIC,proc{|item,pokemon,battler,scene|
    if pbBattleHPItem(pokemon,battler,30,scene)
     pokemon.changeHappiness("candy")
     next true
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:CHOCOLATEIC,proc{|item,pokemon,battler,scene|
    if pbBattleHPItem(pokemon,battler,70,scene)
     pokemon.changeHappiness("candy")
     next true
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:STRAWBIC,proc{|item,pokemon,battler,scene|
     if pbBattleHPItem(pokemon,battler,90,scene)
     pokemon.changeHappiness("candy")
     next true
   end
   next false

})
 
ItemHandlers::BattleUseOnPokemon.add(:BLUEMIC,proc{|item,pokemon,battler,scene|
     if pbBattleHPItem(pokemon,battler,200,scene)
     pokemon.changeHappiness("bluecandy")
     next true
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:LEMONADE,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,70,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:BUBBLETEA,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,180,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MEMEONADE,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,103,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MOOMOOMILK,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,100,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ORANBERRY,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,10,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SITRUSBERRY,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,(pokemon.totalhp/4.0).floor,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:AWAKENING,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::SLEEP
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} woke up.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:AWAKENING,:CHESTOBERRY,:BLUEFLUTE,:POKEFLUTE)

ItemHandlers::BattleUseOnPokemon.add(:ANTIDOTE,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::POISON
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its poisoning.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:ANTIDOTE,:PECHABERRY)

ItemHandlers::BattleUseOnPokemon.add(:BURNHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::BURN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s burn was healed.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:BURNHEAL,:RAWSTBERRY)

ItemHandlers::BattleUseOnPokemon.add(:PARLYZHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::PARALYSIS
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of paralysis.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:PARLYZHEAL,:CHERIBERRY)

ItemHandlers::BattleUseOnPokemon.add(:ICEHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::FROZEN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was thawed out.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

ItemHandlers::BattleUseOnPokemon.add(:FULLHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:BIGMALASADA,:LUMBERRY,:MEDICINE)

ItemHandlers::BattleUseOnPokemon.add(:FULLRESTORE,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && pokemon.hp==pokemon.totalhp &&
      (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     hpgain=pbItemRestoreHP(pokemon,pokemon.totalhp-pokemon.hp)
     battler.hp=pokemon.hp if battler
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     scene.pbRefresh
     if hpgain>0
       scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pokemon.name,hpgain))
     else
       scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     end
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVE,proc{|item,pokemon,battler,scene|
   if pokemon.hp>0 || $game_switches[:Nuzlocke_Mode]==true
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=1+(pokemon.totalhp/2.0).floor
     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbReset if battler
         #battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:MAXREVIVE,proc{|item,pokemon,battler,scene|
   if pokemon.hp>0 || $game_switches[:Nuzlocke_Mode]==true
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=pokemon.totalhp
     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbReset if battler
         #battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYPOWDER,proc{|item,pokemon,battler,scene|
   if pbBattleHPItem(pokemon,battler,60,scene)
     pokemon.changeHappiness("powder")
     next true
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYROOT,proc{|item,pokemon,battler,scene|
   if pbBattleHPItem(pokemon,battler,120,scene)
     pokemon.changeHappiness("Energy Root")
     next true
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:HEALPOWDER,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     pokemon.changeHappiness("powder")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVALHERB,proc{|item,pokemon,battler,scene|
   if pokemon.hp>0 || $game_switches[:Nuzlocke_Mode]==true
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=pokemon.totalhp
     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbReset if battler
         #battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     pokemon.changeHappiness("Revival Herb")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:ETHER,proc{|item,pokemon,battler,scene|
#   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
#   if move>=0
#     if pbBattleRestorePP(pokemon,battler,move,10)==0
#       scene.pbDisplay(_INTL("It won't have any effect."))
#       next false
#     else
       scene.pbDisplay(_INTL("PP was restored."))
       next true
#     end
#   end
#   next false
})

ItemHandlers::BattleUseOnPokemon.copy(:ETHER,:LEPPABERRY)

ItemHandlers::BattleUseOnPokemon.add(:MAXETHER,proc{|item,pokemon,battler,scene|
#   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
#   if move>=0
#     if pbBattleRestorePP(pokemon,battler,move,pokemon.moves[move].totalpp-pokemon.moves[move].pp)==0
#       scene.pbDisplay(_INTL("It won't have any effect."))
#       next false
#     else
       scene.pbDisplay(_INTL("PP was restored."))
       next true
#     end
#   end
#   next false
})
ItemHandlers::BattleUseOnPokemon.add(:ELIXIR,proc{|item,pokemon,battler,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbBattleRestorePP(pokemon,battler,i,10)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:MAXELIXIR,proc{|item,pokemon,battler,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbBattleRestorePP(pokemon,battler,i,pokemon.moves[i].totalpp-pokemon.moves[i].pp)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REDFLUTE,proc{|item,pokemon,battler,scene|
   if battler && battler.effects[PBEffects::Attract]>=0
     battler.effects[PBEffects::Attract]=-1
     scene.pbDisplay(_INTL("{1} got over its infatuation.",pokemon.name))
     next true # :consumed:
   else
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
})

ItemHandlers::BattleUseOnPokemon.add(:YELLOWFLUTE,proc{|item,pokemon,battler,scene|
   if battler && battler.effects[PBEffects::Confusion]>0
     battler.effects[PBEffects::Confusion]=0
     scene.pbDisplay(_INTL("{1} snapped out of confusion.",pokemon.name))
     next true # :consumed:
   else
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:YELLOWFLUTE,:PERSIMBERRY)

#===============================================================================
# BattleUseOnBattler handlers
#===============================================================================

ItemHandlers::BattleUseOnBattler.add(:XATTACK,lambda{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   itemname=PBItems.getName(item)
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
   if battler.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
     battler.pbIncreaseStat(PBStats::ATTACK,2)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XDEFEND,lambda{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   itemname=PBItems.getName(item)
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
   if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
     battler.pbIncreaseStat(PBStats::DEFENSE,2)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPECIAL,lambda{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   itemname=PBItems.getName(item)
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
   if battler.pbCanIncreaseStatStage?(PBStats::SPATK,false)
     battler.pbIncreaseStat(PBStats::SPATK,2)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF,lambda{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   itemname=PBItems.getName(item)
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
   if battler.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
     battler.pbIncreaseStat(PBStats::SPDEF,2)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED,lambda{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   itemname=PBItems.getName(item)
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
   if battler.pbCanIncreaseStatStage?(PBStats::SPEED,false)
     battler.pbIncreaseStat(PBStats::SPEED,2)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY,lambda{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   itemname=PBItems.getName(item)
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
   if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
     battler.pbIncreaseStat(PBStats::ACCURACY,2)
     return true
   else
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false  
   end
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT,lambda{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   itemname=PBItems.getName(item)
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
   if battler.effects[PBEffects::FocusEnergy]>=2
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false
   else
     battler.effects[PBEffects::FocusEnergy]=2
     scene.pbDisplay(_INTL("{1} is getting pumped!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:GUARDSPEC,lambda{|item,battler,scene|
   playername=battler.battle.pbPlayer.name
   itemname=PBItems.getName(item)
   scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
   if battler.pbOwnSide.effects[PBEffects::Mist]>0
     scene.pbDisplay(_INTL("But it had no effect!"))
     return false
   else
     battler.pbOwnSide.effects[PBEffects::Mist]=5
     if !battler.pbIsOpposing?(battler.index) #Item not implemented for enemies. Messages may be incorrect for them if it is.
       scene.pbDisplay(_INTL("Your team became shrouded in mist!"))
     else
       scene.pbDisplay(_INTL("The foe's team became shrouded in mist!"))
     end
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:POKEDOLL,lambda{|item,battler,scene|
   battle=battler.battle
   if battle.opponent
     scene.pbDisplay(_INTL("Can't use that here."))
     return false
   else
     playername=battle.pbPlayer.name
     itemname=PBItems.getName(item)
     scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.copy(:POKEDOLL,:FLUFFYTAIL,:POKETOY)

ItemHandlers::BattleUseOnBattler.addIf(lambda{|item|
                pbIsPokeBall?(item)},lambda{|item,battler,scene|  # Any Poké Ball
   battle=battler.battle
   if !battler.pbOpposing1.isFainted? && !battler.pbOpposing2.isFainted?
     if !pbIsSnagBall?(item)
       scene.pbDisplay(_INTL("It's no good!  It's impossible to aim when there are two Pokémon!"))
       return false
     end
   end
   if battle.pbPlayer.party.length>=6 && $PokemonStorage.full?
     scene.pbDisplay(_INTL("There is no room left in the PC!"))
     return false
   end
   return true
})

#===============================================================================
# UseInBattle handlers
#===============================================================================

ItemHandlers::UseInBattle.add(:POKEDOLL,proc{|item,battler,battle|
   battle.decision=3
   pbSEPlay("escape",100)
   battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseInBattle.copy(:POKEDOLL,:FLUFFYTAIL,:POKETOY)

ItemHandlers::UseInBattle.addIf(proc{|item|
   pbIsPokeBall?(item)},proc{|item,battler,battle|  # Any Poké Ball 
      battle.pbThrowPokeBall(battler.index,item)
})
