TPSPECIES   = 0
TPLEVEL     = 1
TPITEM      = 2
TPMOVE1     = 3
TPMOVE2     = 4
TPMOVE3     = 5
TPMOVE4     = 6
TPABILITY   = 7
TPGENDER    = 8
TPFORM      = 9
TPSHINY     = 10
TPNATURE    = 11
TPIV        = 12
TPHAPPINESS = 13
TPNAME      = 14
TPSHADOW    = 15
TPBALL      = 16
TPHIDDENPOWER = 17
TPHPEV        = 18
TPATKEV       = 19
TPDEFEV       = 20
TPSPEEV       = 21
TPSPAEV       = 22
TPSPDEV       = 23
TPPREMEGA     = 24
TPBOSS        = 25
TPHPOB        = 26
TPATKOB       = 27
TPDEFOB       = 28
TPSPEOB       = 29
TPSPAOB       = 30
TPSPDOB       = 31
TPDEFAULTS = [0,10,0,0,0,0,0,nil,nil,0,false,nil,10,70,nil,false,0,17,0,0,0,0,0,0,false,false,0,0,0,0,0,0]

def pbLoadTrainerDifficult(trainerid,trainername,partyid=0,procedure=nil)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid=getID(PBTrainers,trainerid)
  end
  success=false
  items=[]
  party=[]
  opponent=nil
  $trainerdata=load_data("Data/trainers.dat") if !$trainerdata
  for trainer in $trainerdata
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
    items=trainer[2].clone
    name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVALNAMES
      if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
        name=$game_variables[i[1]]
      end
    end
    opponent=PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer) if $Trainer
    for poke in trainer[3]
      species=poke[TPSPECIES]
      level = DifficultModes.applyLevelProcedure(poke[1],procedure)
      pokemon=PokeBattle_Pokemon.new(species,level,opponent)
      pokemon.form=poke[TPFORM]
      pokemon.resetMoves
      pokemon.setItem(poke[TPITEM])
      if poke[TPMOVE1]>0 || poke[TPMOVE2]>0 || poke[TPMOVE3]>0 || poke[TPMOVE4]>0
        k=0
        for move in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
          pokemon.moves[k]=PBMove.new(poke[move])
          k+=1
        end
        pokemon.moves.compact!
      end
      pokemon.setAbility(poke[TPABILITY])
      pokemon.setGender(poke[TPGENDER])
      if poke[TPSHINY]   # if this is a shiny Pokémon
        pokemon.makeShiny
      else
        pokemon.makeNotShiny
      end
      pokemon.setNature(poke[TPNATURE])
      iv=poke[TPIV]
      for i in 0...6
        if iv == 32
          pokemon.iv[0]=31
          pokemon.iv[1]=31
          pokemon.iv[2]=31
          pokemon.iv[3]=0
          pokemon.iv[4]=31
          pokemon.iv[5]=31
        else
          pokemon.iv[i]=iv&0x1F
        end
      end
      if poke[TPPREMEGA]=="true"
        pokemon.enablepremega
      end
      if poke[TPBOSS]=="true"
        pokemon.enablebossmon
      end
      # New EV method
      evsum = poke[TPHPEV].to_i+poke[TPATKEV].to_i+poke[TPDEFEV].to_i+poke[TPSPEEV].to_i+poke[TPSPAEV].to_i+poke[TPSPDEV].to_i
      #if evsum<=510 && evsum>0
      if evsum>0 # no EV cap :woke:
      pokemon.ev=[poke[TPHPEV].to_i,
                          poke[TPATKEV].to_i,
                          poke[TPDEFEV].to_i,
                          poke[TPSPEEV].to_i,
                          poke[TPSPAEV].to_i,
                          poke[TPSPDEV].to_i]
      elsif evsum == 0
        for i in 0...6
          pokemon.ev[i]=[85,level*3/2].min
        end
      end
      pokemon.obhp=poke[TPHPOB].to_i
      pokemon.obatk=poke[TPATKOB].to_i
      pokemon.obdef=poke[TPDEFOB].to_i
      pokemon.obspe=poke[TPSPEOB].to_i
      pokemon.obspa=poke[TPSPAOB].to_i
      pokemon.obspd=poke[TPSPDOB].to_i   
      pokemon.happiness=poke[TPHAPPINESS]
      pokemon.name=poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""
      if poke[TPSHADOW]   # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves(true) rescue nil
        pokemon.makeNotShiny
      end
      pokemon.ballused=poke[TPBALL]
      pokemon.calcStats
      party.push(pokemon)
    end
    success=true
    break
  end
  return success ? [opponent,items,party] : nil
end

def pbConvertTrainerData
  data=load_data("Data/trainertypes.dat")
  trainertypes=[]
  for i in 0...data.length
    record=data[i]
    if record
      trainertypes[record[0]]=record[2]
    end
  end
  MessageTypes.setMessages(MessageTypes::TrainerTypes,trainertypes)
  pbSaveTrainerTypes()
  pbSaveTrainerBattles()
end

def pbNewTrainer(trainerid,trainername,trainerparty)
  pokemon=[]
  level=TPDEFAULTS[TPLEVEL]
  for i in 1..6
    if i==1
      Kernel.pbMessage(_INTL("Please enter the first Pokémon.",i))
    else
      break if !Kernel.pbConfirmMessage(_INTL("Add another Pokémon?"))
    end
    loop do
      species=pbChooseSpeciesOrdered(1)
      if species<=0
        if i==1
          Kernel.pbMessage(_INTL("This trainer must have at least 1 Pokémon!"))
        else
          break
        end
      else
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setDefaultValue(level)
        level=Kernel.pbMessageChooseNumber(_INTL("Set the level for {1}.",
           PBSpecies.getName(species)),params)
        tempPoke=PokeBattle_Pokemon.new(species,level)
        pokemon.push([species,level,0,
           tempPoke.moves[0].id,
           tempPoke.moves[1].id,
           tempPoke.moves[2].id,
           tempPoke.moves[3].id
        ])
        break
      end
    end
  end
  trainer=[trainerid,trainername,[],pokemon,trainerparty]
  data=load_data("Data/trainers.dat")
  data.push(trainer)
  data=save_data(data,"Data/trainers.dat")
  pbConvertTrainerData
  Kernel.pbMessage(_INTL("The Trainer's data was added to the list of battles and at PBS/trainers.txt."))
  return trainer
end

def pbTrainerTypeCheck(symbol)
  ret=true
  if $DEBUG
    if !hasConst?(PBTrainers,symbol)
      ret=false
    else
      trtype=PBTrainers.const_get(symbol)
      data=load_data("Data/trainertypes.dat")
      ret=false if !data || !data[trtype]
    end
    if !ret
      if Kernel.pbConfirmMessage(_INTL("Add new trainer type {1}?",symbol))
        pbTrainerTypeEditorNew(symbol.to_s)
      end
      pbMapInterpreter.command_end if pbMapInterpreter
    end
  end
  return ret
end

def pbGetFreeTrainerParty(trainerid,trainername)
  for i in 0...256
    trainer=pbLoadTrainer(trainerid,trainername,i)
    return i if !trainer
  end
  return -1
end

def pbTrainerCheck(trainerid,trainername,maxbattles,startBattleId=0)
  if $DEBUG
    if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
      pbTrainerTypeCheck(trainerid)
      return false if !hasConst?(PBTrainers,trainerid)
      trainerid=PBTrainers.const_get(trainerid)
    end
    for i in 0...maxbattles
      trainer=pbLoadTrainer(trainerid,trainername,i+startBattleId)
      if !trainer
        traineridstring="#{trainerid}"
        traineridstring=getConstantName(PBTrainers,trainerid) rescue "-"
        if Kernel.pbConfirmMessage(_INTL("Add new battle {1} (of {2}) for ({3}, {4})?",
          i+1,maxbattles,traineridstring,trainername))
          pbNewTrainer(trainerid,trainername,i)
        end
      end
    end
  end
  return true
end

def pbMissingTrainer(trainerid, trainername, trainerparty)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid=getID(PBTrainers,trainerid)
  end
  traineridstring="#{trainerid}"
  traineridstring=getConstantName(PBTrainers,trainerid) rescue "-"
  if $DEBUG
    message=""
    if trainerparty!=0
      message=(_INTL("Add new trainer ({1}, {2}, ID {3})?",traineridstring,trainername,trainerparty))
    else
      message=(_INTL("Add new trainer ({1}, {2})?",traineridstring,trainername))
    end
    cmd=Kernel.pbMessage(message,[_INTL("Yes"),_INTL("No")],2)
    if cmd==0
      pbNewTrainer(trainerid,trainername,trainerparty)
    end
    return cmd
  else
    raise _INTL("Can't find trainer ({1}, {2}, ID {3})",traineridstring,trainername,trainerparty)
  end
end

def pbDoubleTrainerBattle(trainerid1, trainername1, trainerparty1, endspeech1,
                          trainerid2, trainername2, trainerparty2, endspeech2, 
                          canlose=false,variable=nil)
  trainer1=pbLoadTrainer(trainerid1,trainername1,trainerparty1)
  Events.onTrainerPartyLoad.trigger(nil,trainer1)
  if !trainer1
    pbMissingTrainer(trainerid1,trainername1,trainerparty1)
  end
  trainer2=pbLoadTrainer(trainerid2,trainername2,trainerparty2)
  Events.onTrainerPartyLoad.trigger(nil,trainer2)
  if !trainer2
    pbMissingTrainer(trainerid2,trainername2,trainerparty2)
  end
  if !trainer1 || !trainer2
    return false
  end
  if $PokemonGlobal.partner
    othertrainer=PokeBattle_Trainer.new($PokemonGlobal.partner[1],
                                        $PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      playerparty[6+i]=othertrainer.party[i]
    end
    fullparty1=true
    playertrainer=[$Trainer,othertrainer]
  else
    playerparty=$Trainer.party
    playertrainer=$Trainer
    fullparty1=false
  end
  combinedParty=[]
  for i in 0...trainer1[2].length
    combinedParty[i]=trainer1[2][i]
  end
  for i in 0...trainer2[2].length
    combinedParty[6+i]=trainer2[2][i]
  end
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,
     playerparty,combinedParty,playertrainer,[trainer1[0],trainer2[0]])
  trainerbgm=pbGetTrainerBattleBGM([trainer1[0],trainer2[0]])
  battle.fullparty1=fullparty1
  battle.fullparty2=true
  battle.doublebattle=battle.pbDoubleBattleAllowed?()
  battle.endspeech=endspeech1
  battle.endspeech2=endspeech2
  if $PokemonGlobal.partner
    battle.items=[trainer1[1],trainer2[1],$PokemonGlobal.partner[4]] rescue battle.items=[trainer1[1],trainer2[1]]
  else 
    battle.items=[trainer1[1],trainer2[1]]
  end
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2 && battle.endspeech2!=""
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  pbBattleAnimation((battle.doublebattle) ? 3 : 1,trainerbgm) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     Achievements.incrementProgress("MOVES_USED",$game_variables[530])
     Achievements.incrementProgress("ITEMS_USED",$game_variables[536])
     Achievements.incrementProgress("ITEMS_USED_IN_BATTLE",$game_variables[536])
     Achievements.incrementProgress("MAX_FRIENDSHIP",$game_variables[541])
     for i in $Trainer.party; (i.makeUnmega rescue nil); end
     for i in $Trainer.party
       if isConst?(i.species,PBSpecies,:MIMIKYU)
         i.form=0
       end
       if isConst?(i.species,PBSpecies,:CRAMORANT)
        i.form=0
      end
      if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
        if i.form==2
          i.form=1
        end
      end
     end
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
         i.heal
         i.makeUnmega rescue nil
         if isConst?(i.species,PBSpecies,:MIMIKYU)
           i.form=0
         end
         if isConst?(i.species,PBSpecies,:CRAMORANT)
          i.form=0
        end
        if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
          if i.form==2
            i.form=1
          end
        end
       end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
         PokemonSelection.restore
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  pbSet(variable,decision)
  Achievements.incrementProgress("TRAINER_BATTLES",1)
  $game_variables[704]=0
  $game_variables[699]=0
  $game_variables[702]=0
  $game_variables[298]=0
  $game_variables[708]=0
  return (decision==1)
end

def pbTrainerBattle(trainerid,trainername,endspeech,
                    doublebattle=false,trainerparty=0,canlose=false,variable=nil)
  if $Trainer.pokemonCount==0
    Kernel.pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    return false
  end
  if !$PokemonTemp.waitingTrainer && pbMapInterpreterRunning?
    thisEvent=pbMapInterpreter.get_character(0)
    triggeredEvents=$game_player.pbTriggeredTrainerEvents([2],false)
    otherEvent=[]
    for i in triggeredEvents
      if i.id!=thisEvent.id && !$game_self_switches[[$game_map.map_id,i.id,"A"]]
        otherEvent.push(i)
      end
    end
    if otherEvent.length==1
      trainer=pbLoadTrainer(trainerid,trainername,trainerparty)
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      if !trainer
        pbMissingTrainer(trainerid,trainername,trainerparty)
        return false
      end
      if trainer[2].length<=6 # 3
        $PokemonTemp.waitingTrainer=[trainer,thisEvent.id,endspeech]
        return false
      end
    end
  end
  trainer=pbLoadTrainer(trainerid,trainername,trainerparty)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  if !trainer
    pbMissingTrainer(trainerid,trainername,trainerparty)
    return false
  end
  if $PokemonGlobal.partner && ($PokemonTemp.waitingTrainer || doublebattle)
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      playerparty[6+i]=othertrainer.party[i]
    end
    fullparty1=true
    playertrainer=[$Trainer,othertrainer]
    doublebattle=true
  else
    playerparty=$Trainer.party
    playertrainer=$Trainer
    fullparty1=false
  end
  if $PokemonTemp.waitingTrainer
    combinedParty=[]
    fullparty2=false
    if false
      if $PokemonTemp.waitingTrainer[0][2].length>3
        raise _INTL("Opponent 1's party has more than three Pokémon, which is not allowed")
      end
      if trainer[2].length>3
        raise _INTL("Opponent 2's party has more than three Pokémon, which is not allowed")
      end
    elsif $PokemonTemp.waitingTrainer[0][2].length>3 || trainer[2].length>3
      for i in 0...$PokemonTemp.waitingTrainer[0][2].length
        combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
      end
      for i in 0...trainer[2].length
        combinedParty[6+i]=trainer[2][i]
      end
      fullparty2=true
    else
      for i in 0...$PokemonTemp.waitingTrainer[0][2].length
        combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
      end
      for i in 0...trainer[2].length
        combinedParty[3+i]=trainer[2][i]
      end
      fullparty2=false
    end
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,playerparty,combinedParty,playertrainer,
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
    trainerbgm=pbGetTrainerBattleBGM(
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
    battle.fullparty1=fullparty1
    battle.fullparty2=fullparty2
    battle.doublebattle=battle.pbDoubleBattleAllowed?()
    battle.endspeech=$PokemonTemp.waitingTrainer[2]
    battle.endspeech2=endspeech
    battle.items=[$PokemonTemp.waitingTrainer[0][1],trainer[1],$PokemonGlobal.partner[4]] rescue [$PokemonTemp.waitingTrainer[0][1],trainer[1]]
  else
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,playerparty,trainer[2],playertrainer,trainer[0])
    battle.fullparty1=fullparty1
    battle.doublebattle=doublebattle #? battle.pbDoubleBattleAllowed?() : false
    battle.endspeech=endspeech
    if $PokemonGlobal.partner
      battle.items=trainer[1]
    else 
      battle.items=trainer[1]
    end
    trainerbgm=pbGetTrainerBattleBGM(trainer[0])
  end
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2
    if $PokemonTemp.waitingTrainer
      pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
      $PokemonTemp.waitingTrainer=nil
    end
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  Audio.me_stop
  pbBattleAnimation((battle.doublebattle) ? 3 : 1,trainerbgm,trainer[0].trainertype,trainer[0].name) { 
    pbSceneStandby {
      decision=battle.pbStartBattle(canlose)
    }
    Achievements.incrementProgress("MOVES_USED",$game_variables[530])
    Achievements.incrementProgress("ITEMS_USED",$game_variables[536])
    Achievements.incrementProgress("ITEMS_USED_IN_BATTLE",$game_variables[536])
    Achievements.incrementProgress("MAX_FRIENDSHIP",$game_variables[541])
    for i in $Trainer.party; (i.makeUnmega rescue nil); end
    for i in $Trainer.party
      if isConst?(i.species,PBSpecies,:MIMIKYU)
        i.form=0
      end
      if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
        if i.form==2
          i.form=1
        end
      end
    end
    if $PokemonGlobal.partner
      pbHealAll
      for i in $PokemonGlobal.partner[3]
        i.heal
        i.makeUnmega rescue nil
        if isConst?(i.species,PBSpecies,:MIMIKYU)
          i.form=0
        end
        if isConst?(i.species,PBSpecies,:CRAMORANT)
          i.form=0
        end
        if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
          if i.form==2
            i.form=1
          end
        end
      end
    end
    if decision==2 || decision==5
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
        PokemonSelection.restore
      else
        $game_system.bgm_unpause if $game_switches[1404] != true #don't stop the music switch
        $game_system.bgs_unpause if $game_switches[1404] != true #don't stop the music switch
        #EXTREMELY CLUNKY PICTURE FIX
        $game_screen.pictures[1].erase
        $game_screen.pictures[2].erase
        #DOUBLY CLUNKY THROUGH FIX
        $game_player.through = false
        Kernel.pbStartOver
      end
    else
      Events.onEndBattle.trigger(nil,decision)
      if decision==1
        if $PokemonTemp.waitingTrainer
          pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
        end
      end
    end
  }
  $game_switches[290]=false
  $game_variables[704]=0
  $game_variables[699]=0
  $game_variables[702]=0
  $game_variables[298]=0
  $game_variables[708]=0
  $game_switches[1500]=false
  $game_switches[1121]=false
  Input.update
  pbSet(variable,decision)
  $PokemonTemp.waitingTrainer=nil
  Achievements.incrementProgress("TRAINER_BATTLES",1)
  return (decision==1)
end