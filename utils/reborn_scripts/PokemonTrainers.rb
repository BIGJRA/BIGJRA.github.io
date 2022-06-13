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
TPDEFAULTS = [0,10,0,0,0,0,0,nil,nil,0,false,PBNatures::HARDY,10,70,nil,false,0,17,0,0,0,0,0,0]

def pbLoadTrainer(trainerid,trainername,partyid=0)
  begin
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
    trainerarray = $cache.trainers[trainerid]
    trainer = trainerarray.dig(trainername,partyid)
    items=trainer[1]
    name=pbGetMessageFromHash(MessageTypes::TrainerNames,trainername)
    opponent=PokeBattle_Trainer.new(name,trainerid)
    opponent.setForeignID($Trainer) if $Trainer
    for poke in trainer[0]
      species=poke[TPSPECIES]
      level=poke[TPLEVEL]
      pokemon=PokeBattle_Pokemon.new(species,level,opponent)
      pokemon.form=poke[TPFORM]
      pokemon.resetMoves
      pokemon.setItem(poke[TPITEM])
      if poke[TPMOVE1]>0 || poke[TPMOVE2]>0 || poke[TPMOVE3]>0 || poke[TPMOVE4]>0
        k=0
        for move in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
          pokemon.moves[k]=PBMove.new(poke[move])
          if level >=100 && opponent.skill>=PokeBattle_AI::BESTSKILL
            pokemon.moves[k].ppup=3
            pokemon.moves[k].pp=pokemon.moves[k].totalpp
          end
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
      if iv==32 # Trick room IVS
        for i in 0...6
          pokemon.iv[i]=31
        end
        pokemon.iv[3]=0
      else
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
        end
      end
      # New EV method
      evsum = poke[TPHPEV]+poke[TPATKEV]+poke[TPDEFEV]+poke[TPSPEEV]+poke[TPSPAEV]+poke[TPSPDEV]
      #if evsum<=510 && evsum>0
      if evsum>0 # What is an EV cap? PULSE2 away tbh
        pokemon.ev=[poke[TPHPEV], poke[TPATKEV], poke[TPDEFEV], poke[TPSPEEV], poke[TPSPAEV], poke[TPSPDEV]]
      elsif evsum == 0
        for i in 0...6
          pokemon.ev[i]=[85,level*3/2].min
        end
      end
      if $game_switches[:Only_Pulse_2] == true && ($game_switches[:Grinding_Trainer_Money_Cut] == false || $game_switches[:Penniless_Mode] == true) # pulse 2 mode
        for i in 0...6
          pokemon.ev[i]=252 if pokemon.ev[i] < 252
        end
        pokemon.ev[3] = 0 if iv == 32 # speed, right...?
        for i in 0...6
          pokemon.iv[i]=31 if iv != 32
        end
      end
      
      if $game_switches[:Empty_IVs_And_EVs_Password] == true # empty ev mode
        for i in 0...6
          pokemon.ev[i]=0
          pokemon.iv[i]=0
        end
      end
      pokemon.ev=[85,85,85,85,85,85] if $game_switches[:Flat_EV_Password]
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
  rescue
    print "Team could not be loaded, please report this: #{trainerid}, #{trainername}, #{partyid} \n ty <3"
  end
  return success ? [opponent,items,party] : nil
end

def pbLoadCopiedTrainer(trainerid,trainername,partyid,party)
  opponent=PokeBattle_Trainer.new(trainername,trainerid)
  items=[]
  for trainer in $cache.trainers
    next if trainerid!=trainer[0] || partyid!=trainer[4]
    items=trainer[2].clone
  end
  return [opponent,items,party]
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
#pbDoubleTrainerBattle(PBTrainers::AsterKnight,"Aster",0,_I("Dammit! Eclipse, are you even trying?!"),PBTrainers::EclipseDame,"Eclipse",0,_I("Not really, no."),switch_sprites: true)
def pbDoubleTrainerBattle(trainerid1, trainername1, trainerparty1, endspeech1,
                          trainerid2, trainername2, trainerparty2, endspeech2, 
                          canlose=false,variable=nil, switch_sprites: false ,recorded:false)
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
  ###Yumil - 15 - NPC Reaction - Begin
  battle=PokeBattle_Battle.new(scene,
  playerparty,combinedParty,playertrainer,[trainer1[0],trainer2[0]],recorded)
  ###Yumil - 15 - NPC Reaction - End
  trainerbgm=pbGetTrainerBattleBGM([trainer1[0],trainer2[0]])
  battle.fullparty1=fullparty1
  battle.fullparty2=true
  battle.doublebattle=battle.pbDoubleBattleAllowed?()
  battle.endspeech=endspeech1
  battle.endspeech2=endspeech2
  battle.items=[trainer1[1],trainer2[1]]
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
  pbBattleAnimation(trainerbgm,[trainerid1,trainerid2], [trainer1[0].name, trainer2[0].name],switch_sprites) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
        i.heal
      end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
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
  return (decision==1)
end

def pbTrainerBattle(trainerid,trainername,endspeech, doublebattle=false,trainerparty=0,canlose=false,variable=nil,opponent_team: [],recorded:false, items_overwrite: nil)
  $game_switches[:In_Battle] = true
  if $Trainer.pokemonCount==0
    Kernel.pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    $game_switches[:In_Battle] = false
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
      trainer= opponent_team.length==0 ? pbLoadTrainer(trainerid,trainername,trainerparty) : pbLoadCopiedTrainer(trainerid,trainername,trainerparty,opponent_team)
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      if !trainer
        pbMissingTrainer(trainerid,trainername,trainerparty)
        $game_switches[:In_Battle] = false
        return false
      end
      if trainer[2].length<=6 # 3
        $PokemonTemp.waitingTrainer=[trainer,thisEvent.id,endspeech]
        $game_switches[:In_Battle] = false
        return false
      end
    end
  end
  trainer= opponent_team.length==0 ? pbLoadTrainer(trainerid,trainername,trainerparty) : pbLoadCopiedTrainer(trainerid,trainername,trainerparty,opponent_team)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  if !trainer
    pbMissingTrainer(trainerid,trainername,trainerparty)
    $game_switches[:In_Battle] = false
    return false
  end
  if $PokemonGlobal.partner && ($PokemonTemp.waitingTrainer || doublebattle)
    othertrainer=PokeBattle_Trainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
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
    ###Yumil - 17 - NPC Reaction - Begin
    battle=PokeBattle_Battle.new(scene,playerparty,combinedParty,playertrainer,
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]],recorded)
    ###Yumil - 17 - NPC Reaction - End
    trainerbgm=pbGetTrainerBattleBGM(
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
    battle.fullparty1=fullparty1
    battle.fullparty2=fullparty2
    battle.doublebattle=battle.pbDoubleBattleAllowed?()
    battle.endspeech=$PokemonTemp.waitingTrainer[2]
    battle.endspeech2=endspeech
    battle.items=[$PokemonTemp.waitingTrainer[0][1],trainer[1]]
  else
    scene=pbNewBattleScene
    if opponent_team.length > 0
       ###Yumil - 18-2 - NPC Reaction - Begin
      battle=PokeBattle_Battle.new(scene,playerparty,opponent_team,playertrainer,trainer[0],recorded)
      ###Yumil - 18-2 - NPC Reaction - End
    else
      ###Yumil - 18 - NPC Reaction - Begin
      battle=PokeBattle_Battle.new(scene,playerparty,trainer[2],playertrainer,trainer[0],recorded)
      ###Yumil - 18 - NPC Reaction - End
    end
    battle.fullparty1=fullparty1
    battle.doublebattle=doublebattle ? battle.pbDoubleBattleAllowed?() : false
    battle.endspeech=endspeech
    battle.items=trainer[1]
    battle.items=items_overwrite if items_overwrite
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
    $game_switches[:In_Battle] = false
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  Audio.me_stop
  pbBattleAnimation(trainerbgm,trainer[0].trainertype,trainer[0].name) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
        i.heal
      end
     end
     if decision==2 || decision==5
       if canlose
         for i in 0...$Trainer.party.length; $Trainer.party[i].heal if !$game_switches[:Nuzlocke_Mode] || !battle.fainted_mons[i] ; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
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
  Input.update
  pbSet(variable,decision)
  $PokemonTemp.waitingTrainer=nil
  $game_switches[:In_Battle] = false
  return (decision==1)
end

def pbTrainerBattle100(trainerid,trainername,endspeech,
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
  #creating player party
  if $PokemonGlobal.partner && ($PokemonTemp.waitingTrainer || doublebattle)
    othertrainer=PokeBattle_Trainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
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
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    playertrainer=$Trainer
    fullparty1=false
  end
  olditems=$Trainer.party.transform{|p| p.item }
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
    battle.items=[$PokemonTemp.waitingTrainer[0][1],trainer[1]]
  else
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,playerparty,trainer[2],playertrainer,trainer[0])
    battle.fullparty1=fullparty1
    battle.doublebattle=doublebattle ? battle.pbDoubleBattleAllowed?() : false
    battle.endspeech=endspeech
    battle.items=trainer[1]
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
  #disable exp gain for this battle
  battle.disableExpGain=true
  #making all pokemon lvl 100
  pokemonexp = []
  pokemonlevels = []
  for i in playerparty
    next if i.nil?
    unless i.isEgg?
      pokemonexp.push(i.exp)
      pokemonlevels.push(i.level)
      i.level = 100
      i.calcStats
    end
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  Audio.me_stop
  pbBattleAnimation(trainerbgm,trainer[0].trainertype,trainer[0].name) { 
    pbSceneStandby {
       decision=battle.pbStartBattle(canlose)
    }
    partyindex=0
    for i in playerparty
      next if i.nil?
      unless i.isEgg?
        i.level = pokemonlevels[partyindex]
        i.exp = pokemonexp[partyindex]
        i.calcStats
        partyindex+=1
      end
    end
    for i in 0...$Trainer.party.length; $Trainer.party[i].setItem(olditems[i]); end
    if $PokemonGlobal.partner
      pbHealAll
      for i in $PokemonGlobal.partner[3]
        i.heal
      end
    end
    if decision==2 || decision==5
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
      else
        $game_system.bgm_unpause
        $game_system.bgs_unpause
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
  Input.update
  pbSet(variable,decision)
  $PokemonTemp.waitingTrainer=nil
  return (decision==1)
end

def pbDoubleTrainerBattle100(trainerid1, trainername1, trainerparty1, endspeech1,
                          trainerid2, trainername2, trainerparty2, endspeech2, 
                          canlose=false,variable=nil, switch_sprites: false)
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
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    playertrainer=$Trainer
    fullparty1=false
  end
  olditems=$Trainer.party.transform{|p| p.item }
  pokemonexp = []
  pokemonlevels = []
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
  battle.items=[trainer1[1],trainer2[1]]
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2 && battle.endspeech2!=""
    return true
  end
  #disable exp gain for this battle
  battle.disableExpGain=true
  for i in playerparty
    next if i.nil?
    unless i.isEgg?
      pokemonexp.push(i.exp)
      pokemonlevels.push(i.level)
      i.level = 100
      i.calcStats
    end
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  pbBattleAnimation(trainerbgm,[trainerid1,trainerid2], [trainer1[0].name, trainer2[0].name],switch_sprites) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     partyindex=0
     for i in playerparty
      next if i.nil?
       unless i.isEgg?
         i.level = pokemonlevels[partyindex]
         i.exp = pokemonexp[partyindex]
         partyindex+=1
         i.calcStats
       end
     end
     for i in 0...$Trainer.party.length; $Trainer.party[i].setItem(olditems[i]); end

     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
         i.heal
       end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
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
  return (decision==1)
end