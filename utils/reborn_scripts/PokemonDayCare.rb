def pbEggGenerated?
  return false if pbDayCareDeposited!=2
  return $PokemonGlobal.daycareEgg==1
end

def pbDayCareDeposited
  ret=0
  for i in 0...2
    ret+=1 if $PokemonGlobal.daycare[i][0]
  end
  return ret
end

def pbDayCareDeposit(index)
  for i in 0...2
    if !$PokemonGlobal.daycare[i][0]
      $PokemonGlobal.daycare[i][0]=$Trainer.party[index]
      $PokemonGlobal.daycare[i][1]=$Trainer.party[index].level
      $PokemonGlobal.daycare[i][0].heal if $game_switches[:Nuzlocke_Mode] == false
      $Trainer.party[index]=nil
      $Trainer.party.compact!
      $PokemonGlobal.daycareEgg=0
      $PokemonGlobal.daycareEggSteps=0
      return
    end
  end
  raise _INTL("No room to deposit a Pokémon") 
end

def pbDayCareGetLevelGain(index,nameVariable,levelVariable)
  pkmn=$PokemonGlobal.daycare[index][0]
  return false if !pkmn
  $game_variables[nameVariable]=pkmn.name
  $game_variables[levelVariable]=pkmn.level-$PokemonGlobal.daycare[index][1]
  return true
end

def pbDayCareGetDeposited(index,nameVariable,costVariable)
  for i in 0...2
    if (index<0||i==index) && $PokemonGlobal.daycare[i][0]
      cost=$PokemonGlobal.daycare[i][0].level-$PokemonGlobal.daycare[i][1]
      cost+=1
      cost*=100
      $game_variables[costVariable]=cost if costVariable>=0
      $game_variables[nameVariable]=$PokemonGlobal.daycare[i][0].name if nameVariable>=0
      return
    end
  end
  raise _INTL("Can't find deposited Pokémon")
end

def pbIsDitto?(pokemon)
  compat10=$cache.pkmn_dex[pokemon.species][:EggGroups][0]
  compat11=$cache.pkmn_dex[pokemon.species][:EggGroups][1]
  return (compat10==13 || compat11==13)
end

def pbDayCareCompatibleGender(pokemon1,pokemon2)
  if (pokemon1.isFemale? && pokemon2.isMale?) ||
     (pokemon1.isMale? && pokemon2.isFemale?)
    return true
  end
  ditto1=pbIsDitto?(pokemon1)
  ditto2=pbIsDitto?(pokemon2)
  return true if ditto1 && !ditto2
  return true if ditto2 && !ditto1
  return false
end

def pbDayCareGetCompat
  if pbDayCareDeposited==2
    pokemon1=$PokemonGlobal.daycare[0][0]
    pokemon2=$PokemonGlobal.daycare[1][0]
    return 0 if (pokemon1.isShadow? rescue false)
    return 0 if (pokemon2.isShadow? rescue false)
    compat10=$cache.pkmn_dex[pokemon1.species][:EggGroups][0]
    compat11=$cache.pkmn_dex[pokemon1.species][:EggGroups][1]
    compat20=$cache.pkmn_dex[pokemon2.species][:EggGroups][0]
    compat21=$cache.pkmn_dex[pokemon2.species][:EggGroups][1]
    if (compat10==compat20 || compat11==compat20 ||
       compat10==compat21 || compat11==compat21 ||
       compat10==13 || compat11==13 || compat20==13 || compat21==13) &&
       compat10!=15 && compat11!=15 && compat20!=15 && compat21!=15
      if pbDayCareCompatibleGender(pokemon1,pokemon2)
        if pokemon1.species==pokemon2.species
          return (pokemon1.trainerID==pokemon2.trainerID) ? 2 : 3
        else
          return (pokemon1.trainerID==pokemon2.trainerID) ? 1 : 2
        end
      end
    end
  end
  return 0
end

def pbDayCareGetCompatibility(variable)
  $game_variables[variable]=pbDayCareGetCompat
end

def pbDayCareWithdraw(index)
  if !$PokemonGlobal.daycare[index][0]
    raise _INTL("There's no Pokémon here...")
  else
    pbAddPokemonSilent($PokemonGlobal.daycare[index][0])
    lvldiff=$PokemonGlobal.daycare[index][0].level-$PokemonGlobal.daycare[index][1]
    pkmn=$PokemonGlobal.daycare[index][0]
    movelist=pkmn.getMoveList
    for i in 1..lvldiff
      for j in movelist
        pkmn.pbLearnMove(j[1]) if j[0]==($PokemonGlobal.daycare[index][1]+i)      # Learned a new move
      end
    end    
    $PokemonGlobal.daycare[index][0]=nil
    $PokemonGlobal.daycare[index][1]=0
    $PokemonGlobal.daycareEgg=0
  end  
end

def pbDayCareChoose(text,variable)
  count=pbDayCareDeposited
  if count==0
    raise _INTL("There's no Pokémon here...")
  elsif count==1
    $game_variables[variable]=$PokemonGlobal.daycare[0][0] ? 0 : 1
  else
    choices=[]
    for i in 0...2
      pokemon=$PokemonGlobal.daycare[i][0]
      if pokemon.isMale?
        choices.push(_ISPRINTF("{1:s} (M, Lv{2:d})",pokemon.name,pokemon.level))
      elsif pokemon.isFemale?
        choices.push(_ISPRINTF("{1:s} (F, Lv{2:d})",pokemon.name,pokemon.level))
      else
        choices.push(_ISPRINTF("{1:s} (Lv{2:d})",pokemon.name,pokemon.level))
      end
    end
    choices.push(_INTL("CANCEL"))
    command=Kernel.pbMessage(text,choices,choices.length)
    $game_variables[variable]=(command==2) ? -1 : command
  end
end

# Given a baby species, returns the lowest possible evolution of that species
# assuming no incense is involved.
def pbGetNonIncenseLowestSpecies(baby)
  if (baby == PBSpecies::MUNCHLAX) && hasConst?(PBSpecies,:SNORLAX)
    return PBSpecies::SNORLAX
  elsif (baby == PBSpecies::WYNAUT) && hasConst?(PBSpecies,:WOBBUFFET)
    return PBSpecies::WOBBUFFET
  elsif (baby == PBSpecies::HAPPINY) && hasConst?(PBSpecies,:CHANSEY)
    return PBSpecies::CHANSEY
  elsif (baby == PBSpecies::MIMEJR) && hasConst?(PBSpecies,:MRMIME)
    return PBSpecies::MRMIME
  elsif (baby == PBSpecies::CHINGLING) && hasConst?(PBSpecies,:CHIMECHO)
    return PBSpecies::CHIMECHO
  elsif (baby == PBSpecies::BONSLY) && hasConst?(PBSpecies,:SUDOWOODO)
    return PBSpecies::SUDOWOODO
  elsif (baby == PBSpecies::BUDEW) && hasConst?(PBSpecies,:ROSELIA)
    return PBSpecies::ROSELIA
  elsif (baby == PBSpecies::AZURILL) && hasConst?(PBSpecies,:MARILL)
    return PBSpecies::MARILL
  elsif (baby == PBSpecies::MANTYKE) && hasConst?(PBSpecies,:MANTINE)
    return PBSpecies::MANTINE
  end
  return baby
end

def pbDayCareGenerateEgg
  if pbDayCareDeposited!=2
    return
 # elsif $Trainer.party.length>=6
 #   raise _INTL("Can't store the egg")
  end
  pokemon0=$PokemonGlobal.daycare[0][0]
  pokemon1=$PokemonGlobal.daycare[1][0]
  mother=nil
  father=nil
  babyspecies=0
  ditto0=pbIsDitto?(pokemon0)
  ditto1=pbIsDitto?(pokemon1)
  if (pokemon0.isFemale? || ditto0)
    babyspecies=(ditto0) ? pokemon1.species : pokemon0.species
    mother=pokemon0
    father=pokemon1
  else
    babyspecies=(ditto1) ? pokemon0.species : pokemon1.species
    mother=pokemon1
    father=pokemon0
  end
  if babyspecies == mother.species
    mainparent = mother
  else
    mainparent = father
  end  
  babyspecies=pbGetBabySpecies(babyspecies)
  parentspecies=babyspecies
  if (babyspecies == PBSpecies::MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    babyspecies=PBSpecies::PHIONE
  end
  if (babyspecies == PBSpecies::NIDORANfE) && hasConst?(PBSpecies,:NIDORANmA)
    babyspecies=[(PBSpecies::NIDORANmA), (PBSpecies::NIDORANfE)][rand(2)]
  elsif (babyspecies == PBSpecies::NIDORANmA) && hasConst?(PBSpecies,:NIDORANfE)
    babyspecies=[(PBSpecies::NIDORANmA), (PBSpecies::NIDORANfE)][rand(2)]
  elsif (babyspecies == PBSpecies::VOLBEAT) && hasConst?(PBSpecies,:ILLUMISE)
    babyspecies=[PBSpecies::VOLBEAT, PBSpecies::ILLUMISE][rand(2)]
  elsif (babyspecies == PBSpecies::ILLUMISE) && hasConst?(PBSpecies,:VOLBEAT)
    babyspecies=[PBSpecies::VOLBEAT, PBSpecies::ILLUMISE][rand(2)]
  elsif (babyspecies == PBSpecies::MUNCHLAX) && !(mother.item == PBItems::FULLINCENSE) && !(father.item == PBItems::FULLINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif (babyspecies == PBSpecies::WYNAUT) && !(mother.item == PBItems::LAXINCENSE) && !(father.item == PBItems::LAXINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif (babyspecies == PBSpecies::HAPPINY) && !(mother.item == PBItems::LUCKINCENSE) && !(father.item == PBItems::LUCKINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif (babyspecies == PBSpecies::MIMEJR) && !(mother.item == PBItems::ODDINCENSE) && !(father.item == PBItems::ODDINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif (babyspecies == PBSpecies::CHINGLING) && !(mother.item == PBItems::PUREINCENSE) && !(father.item == PBItems::PUREINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif (babyspecies == PBSpecies::BONSLY) && !(mother.item == PBItems::ROCKINCENSE) && !(father.item == PBItems::ROCKINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif (babyspecies == PBSpecies::BUDEW) && !(mother.item == PBItems::ROSEINCENSE) && !(father.item == PBItems::ROSEINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif (babyspecies == PBSpecies::AZURILL) && !(mother.item == PBItems::SEAINCENSE) && !(father.item == PBItems::SEAINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif (babyspecies == PBSpecies::MANTYKE) && !(mother.item == PBItems::WAVEINCENSE) && !(father.item == PBItems::WAVEINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  end
  # Generate egg
  egg=PokeBattle_Pokemon.new(babyspecies,EGGINITIALLEVEL,$Trainer)
  egg.form = mainparent.form unless egg.species == PBSpecies::ROTOM # New form inheriting
  if parentspecies == PBSpecies::OBSTAGOON
    egg.form=1
  end
  # Randomise personal ID
  pid=rand(65536)
  pid|=(rand(65536)<<16)
  egg.personalID=pid
  # Inheriting form redone above
#  if (babyspecies == PBSpecies::BURMY) ||
#     (babyspecies == PBSpecies::SHELLOS) ||
#     (babyspecies == PBSpecies::BASCULIN)
#    egg.form=mother.form
#  end
  # Inheriting Moves
  moves=[]
  othermoves=[] 
  movefather=father
  movefather=mother if pbIsDitto?(movefather) && mother.gender!=1
  # Initial Moves
  initialmoves=egg.getMoveList
  for k in initialmoves
    if k[0]<=EGGINITIALLEVEL
      moves.push(k[1])
    else
      othermoves.push(k[1]) if mother.knowsMove?(k[1]) && father.knowsMove?(k[1])
    end
  end
  # Inheriting Natural Moves
  for move in othermoves
    moves.push(move)
  end
  # Inheriting Machine Moves
 # for i in 0...$cache.items.length
 #   next if !$cache.items[i]
 #   atk=$cache.items[i][ITEMMACHINE]
 #   next if !atk || atk==0
 #   if pbSpeciesCompatible?(babyspecies,atk)
 #     moves.push(atk) if movefather.knowsMove?(atk)
 #   end
 # end
  # Inheriting Egg Moves
  name = egg.getFormName
	formcheck = PokemonForms.dig(egg.species,name,:EggMoves)
  if formcheck!=nil
    for move in formcheck
      atk = getID(PBMoves,move)
      moves.push(atk) if father.knowsMove?(atk)
      moves.push(atk) if mother.knowsMove?(atk)
    end
  else 
    movelist = $cache.pkmn_egg[babyspecies]
    if movelist
      for i in movelist
        atk = getID(PBMoves,i)
        moves.push(atk) if father.knowsMove?(atk)
        moves.push(atk) if mother.knowsMove?(atk)
      end
    end
  end
  # Volt Tackle
  lightball=false
  if ((father.species == PBSpecies::PIKACHU) || 
      (father.species == PBSpecies::RAICHU)) && 
      (father.item == PBItems::LIGHTBALL)
    lightball=true
  end
  if ((mother.species == PBSpecies::PIKACHU) || 
      (mother.species == PBSpecies::RAICHU)) && 
      (mother.item == PBItems::LIGHTBALL)
    lightball=true
  end
  if lightball && (babyspecies == PBSpecies::PICHU) &&
     hasConst?(PBMoves,:VOLTTACKLE)
    moves.push(PBMoves::VOLTTACKLE)
  end
  moves = moves.reverse
  moves|=[] # remove duplicates
  moves = moves.reverse # This is to ensure deletion of duplicates is from the start, not the end
  # Assembling move list
  finalmoves=[]
  listend=moves.length-4
  listend=0 if listend<0
  j=0
  for i in listend..listend+3
    moveid=(i>=moves.length) ? 0 : moves[i]
    finalmoves[j]=PBMove.new(moveid)
    j+=1
  end 
  # Inheriting Individual Values
  ivs=[]
  for i in 0...6
    ivs[i]=rand(32)
  end
  ivinherit=[]
  powercount = 0
  for i in 0...2
    parent=[mother,father][i]
    if (parent.item == PBItems::POWERWEIGHT)
      ivinherit[i]=PBStats::HP 
      powercount+=1
    end  
    if (parent.item == PBItems::POWERBRACER)
      ivinherit[i]=PBStats::ATTACK 
      powercount+=1
    end  
    if (parent.item == PBItems::POWERBELT)
      ivinherit[i]=PBStats::DEFENSE 
      powercount+=1
    end  
    if (parent.item == PBItems::POWERANKLET)
      ivinherit[i]=PBStats::SPEED 
      powercount+=1
    end  
    if (parent.item == PBItems::POWERLENS)
      ivinherit[i]=PBStats::SPATK 
      powercount+=1
    end  
    if (parent.item == PBItems::POWERBAND)
      ivinherit[i]=PBStats::SPDEF 
      powercount+=1
    end
  end
  num=0; r=rand(2)
  for i in 0...2
    if ivinherit[r]!=nil
      parent=[mother,father][r]
      ivs[ivinherit[r]]=parent.iv[ivinherit[r]]
      num+=1
      break if num == powercount
    end
    r=(r+1)%2
  end

# Destiny Knot and Inheriting IVs
  destiny=false
  knot0=(mother.item == PBItems::DESTINYKNOT)
  knot1=(father.item == PBItems::DESTINYKNOT)
  
  if !knot0 && !knot1
    destiny=false
  else
    destiny=true
  end
  
  i=0; stats=[PBStats::HP,PBStats::ATTACK,PBStats::DEFENSE,
              PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
  loop do
    r=stats[rand(stats.length)]
    if !ivinherit.include?(r)
      parent=[mother,father][rand(2)]
      ivs[r]=parent.iv[r]
      ivinherit.push(r)
      i+=1
    end
    
    # inheriting conditional
    # d.knot
    if destiny
      break if i == 4 && powercount == 1
      break if i == 5
    # no d.knot; power item(s)
    elsif powercount>0
      break if i == 2
    # no d.knot; no power item(s)
    else 
      break if i == 3
    end
  end
  
  # Inheriting nature
  newnatures=[]
  newnatures.push(mother.nature) if (mother.item == PBItems::EVERSTONE)
  newnatures.push(father.nature) if (father.item == PBItems::EVERSTONE)
  if newnatures.length>0
    egg.setNature(newnatures[rand(newnatures.length)])
  end
  # Masuda method and Shiny Charm
  shinyretries=0
  shinyretries+=5 if father.language!=mother.language
  shinyretries+=2 if hasConst?(PBItems,:SHINYCHARM) &&
                     $PokemonBag.pbQuantity(:SHINYCHARM)>0
  if shinyretries>0
    for i in 0...shinyretries
      break if egg.isShiny?
      egg.personalID=rand(65536)|(rand(65536)<<16)
    end
  end
  # Inheriting ability from the mother
 # if !ditto0 && !ditto1
 #   if mother.abilityflag && mother.abilityIndex==2
 #     egg.setAbility(2) if rand(10)<6
 #   else
 #     if rand(10)<8
 #       egg.setAbility(mother.abilityIndex)
 #     else
 #       egg.setAbility((mother.abilityIndex+1)%2)
 #     end
 #   end
 # end
 
  # Inheriting Poké Ball from the mother
  if mother.isFemale? &&
     pbBallTypeToBall(mother.ballused) != PBItems::MASTERBALL && pbBallTypeToBall(mother.ballused) != PBItems::CHERISHBALL
    egg.ballused=mother.ballused
  elsif ditto0 || ditto1
     pbBallTypeToBall(father.ballused) != PBItems::MASTERBALL && pbBallTypeToBall(father.ballused) != PBItems::CHERISHBALL
    egg.ballused=father.ballused    
  end  
  egg.iv[0]=ivs[0]
  egg.iv[1]=ivs[1]
  egg.iv[2]=ivs[2]
  egg.iv[3]=ivs[3]
  egg.iv[4]=ivs[4]
  egg.iv[5]=ivs[5]
  egg.iv.map! {|_| 31} if $game_switches[:Full_IVs]
  egg.iv.map! {|_| 0} if $game_switches[:Empty_IVs_Password]
  egg.moves[0]=finalmoves[0]
  egg.moves[1]=finalmoves[1]
  egg.moves[2]=finalmoves[2]
  egg.moves[3]=finalmoves[3]
  egg.calcStats
  egg.obtainText=_INTL("Day-Care Couple")
  egg.name=_INTL("Egg")
  eggsteps=$cache.pkmn_dex[mother.species][:EggSteps]
  egg.eggsteps=eggsteps
  if rand(65536)<POKERUSCHANCE
    egg.givePokerus
  end
  #$Trainer.party[$Trainer.party.length]=egg
  pbAddPokemonSilent(egg)
end

Events.onStepTaken+=proc {|sender,e|
   next if !$Trainer
   deposited=pbDayCareDeposited
   if deposited==2 && $PokemonGlobal.daycareEgg==0
     $PokemonGlobal.daycareEggSteps=0 if !$PokemonGlobal.daycareEggSteps
     $PokemonGlobal.daycareEggSteps+=1
     if $PokemonGlobal.daycareEggSteps==256
       $PokemonGlobal.daycareEggSteps=0
       compatval=[0,20,50,70][pbDayCareGetCompat]
       if hasConst?(PBItems,:OVALCHARM) && $PokemonBag.pbQuantity(PBItems::OVALCHARM)>0
         compatval=[0,40,80,88][pbDayCareGetCompat]
       end
       rnd=rand(100)
       if rnd<compatval
         # Egg is generated
         $PokemonGlobal.daycareEgg=1
       end
     end
   end
   for i in 0...2
     pkmn=$PokemonGlobal.daycare[i][0]
     next if !pkmn     
     maxexp=PBExperience.pbGetMaxExperience(pkmn.growthrate)
     if $game_switches[:Hard_Level_Cap] # Rejuv-style Level Cap
       badgenum = $Trainer.numbadges
       if badgenum!=18
         maxexp = PBExperience.pbGetStartExperience(LEVELCAPS[badgenum], pkmn.growthrate)
       end
     end
     if pkmn.exp < maxexp && !$game_switches[:No_EXP_Gain]
       pkmn.exp+=1
       newlevel = PBExperience.pbGetLevelFromExperience(pkmn.exp,pkmn.growthrate)
       if newlevel!=pkmn.level
        pkmn.level=newlevel
         pkmn.calcStats
#         movelist=pkmn.getMoveList
#         for i in movelist
#           pkmn.pbLearnMove(i[1]) if i[0]==pkmn.level       # Learned a new move
#         end
       end
     end
   end
}