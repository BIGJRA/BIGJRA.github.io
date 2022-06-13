module BallHandlers
  IsUnconditional=ItemHandlerHash.new
  ModifyCatchRate=ItemHandlerHash.new
  OnCatch=ItemHandlerHash.new
  OnFailCatch=ItemHandlerHash.new

  def self.isUnconditional?(ball,battle,battler)
    if !IsUnconditional[ball]
      return false
    end
    return IsUnconditional.trigger(ball,battle,battler)
  end

  def self.modifyCatchRate(ball,catchRate,battle,battler)
    if !ModifyCatchRate[ball]
      return catchRate
    end
    return ModifyCatchRate.trigger(ball,catchRate,battle,battler)
  end

  def self.onCatch(ball,battle,pokemon)
    if OnCatch[ball]
      OnCatch.trigger(ball,battle,pokemon)
    end
  end

  def self.onFailCatch(ball,battle,pokemon)
    if OnFailCatch[ball]
      OnFailCatch.trigger(ball,battle,pokemon)
    end
  end
end



def pbBallTypeToBall(balltype)
  if $BallTypes[balltype]
    ret=getID(PBItems,$BallTypes[balltype])
    return ret if ret!=0
  end
  if $BallTypes[0]
    ret=getID(PBItems,$BallTypes[0])
    return ret if ret!=0
  end
  return PBItems::POKEBALL
end

def pbGetBallType(ball)
  ball=getID(PBItems,ball)
  for key in $BallTypes.keys
    return key if isConst?(ball,PBItems,$BallTypes[key])
  end
  return 0
end

def pbIsUltraBeast?(battler)
  if (battler.species == PBSpecies::NIHILEGO) ||
    (battler.species == PBSpecies::BUZZWOLE) ||
    (battler.species == PBSpecies::PHEROMOSA) ||
    (battler.species == PBSpecies::XURKITREE) ||
    (battler.species == PBSpecies::CELESTEELA) ||
    (battler.species == PBSpecies::KARTANA) ||
    (battler.species == PBSpecies::GUZZLORD) ||
    (battler.species == PBSpecies::POIPOLE) ||
    (battler.species == PBSpecies::NAGANADEL) ||
    (battler.species == PBSpecies::STAKATAKA) ||
    (battler.species == PBSpecies::BLACEPHALON) 
    return true
  else
    return false
  end
end


################################

$BallTypes={
   0=>:POKEBALL,
   1=>:GREATBALL,
   2=>:SAFARIBALL,
   3=>:ULTRABALL,
   4=>:MASTERBALL,
   5=>:NETBALL,
   6=>:DIVEBALL,
   7=>:NESTBALL,
   8=>:REPEATBALL,
   9=>:TIMERBALL,
   10=>:LUXURYBALL,
   11=>:PREMIERBALL,
   12=>:DUSKBALL,
   13=>:HEALBALL,
   14=>:QUICKBALL,
   15=>:CHERISHBALL,
   16=>:FASTBALL,
   17=>:LEVELBALL,
   18=>:LUREBALL,
   19=>:HEAVYBALL,
   20=>:LOVEBALL,
   21=>:FRIENDBALL,
   22=>:MOONBALL,
   23=>:SPORTBALL,
   24=>:BEASTBALL,
   25=>:GLITTERBALL, 
   26=>:DREAMBALL
}

BallHandlers::ModifyCatchRate.add(:GREATBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*1.5).floor
})

BallHandlers::ModifyCatchRate.add(:SAFARIBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*1.5).floor
})

BallHandlers::ModifyCatchRate.add(:ULTRABALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*2).floor
})

BallHandlers::IsUnconditional.add(:MASTERBALL,proc{|ball,battle,battler|
   next true
})

BallHandlers::ModifyCatchRate.add(:NETBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate*=3.5 if battler.pbHasType?(:BUG) || battler.pbHasType?(:WATER)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:DIVEBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate=(catchRate*3.5).floor if battle.environment==PBEnvironment::Underwater || battle.FE == PBFields::WATERS || battle.FE == PBFields::UNDERWATER
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:NESTBALL,proc{|ball,catchRate,battle,battler|
 #  if battler.level<=40
 #    catchRate*=(41-battler.level)/10
 #  end
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   modifier = [8-0.2*(battler.level - 1),1].max
   catchRate*=modifier
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:REPEATBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate*=3.5 if battle.pbPlayer.owned[battler.species]
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:TIMERBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   multiplier=[1+(0.3*battle.turncount),4].min
   catchRate*=multiplier
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:DUSKBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate*=3.5 if PBDayNight.isNight?(pbGetTimeNow) || battle.FE == PBFields::DARKCRYSTALC || battle.FE == PBFields::SHORTCIRCUITF || battle.FE == PBFields::UNDERWATER || battle.FE == PBFields::CAVE || battle.FE == PBFields::CRYSTALC || battle.FE == PBFields::DRAGONSD || battle.FE == PBFields::STARLIGHTA || battle.FE == PBFields::NEWW || battle.FE == PBFields::INVERSEF 
   next catchRate
})

BallHandlers::OnCatch.add(:HEALBALL,proc{|ball,battle,pokemon|
   pokemon.heal
})

BallHandlers::ModifyCatchRate.add(:QUICKBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate*=5 if battle.turncount<=1
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:FASTBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   basespeed = $cache.pkmn_dex[battler.species][:BaseStats][3]
   catchRate*=4 if basespeed>=100
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:LEVELBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   pbattler=battle.battlers[0].level
   pbattler=battle.battlers[2].level if battle.battlers[2] &&
                                        battle.battlers[2].level>pbattler
   if pbattler>=battler.level*4
     catchRate*=8
   elsif pbattler>=battler.level*2
     catchRate*=4
   elsif pbattler>battler.level
     catchRate*=2
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:LUREBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate*=5 if $PokemonTemp.encounterType==EncounterTypes::OldRod ||
                   $PokemonTemp.encounterType==EncounterTypes::GoodRod ||
                   $PokemonTemp.encounterType==EncounterTypes::SuperRod
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:HEAVYBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   weight=battler.weight
   if weight>4000
     catchRate+=40
   elsif weight>3000
     catchRate+=30
   elsif weight>=2050
     catchRate+=20
   else
     catchRate-=20
   end
   catchRate=[catchRate,1].max
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:LOVEBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   pbattler=battle.battlers[0]
   pbattler2=battle.battlers[2] if battle.battlers[2]
   if pbattler.species==battler.species &&
      ((battler.gender==0 && pbattler.gender==1) ||
      (battler.gender==1 && pbattler.gender==0))
     catchRate*=8
   elsif pbattler2 && pbattler2.species==battler.species &&
      ((battler.gender==0 && pbattler2.gender==1) ||
       (battler.gender==1 && pbattler2.gender==0))
     catchRate*=8
   end
   next catchRate
})

BallHandlers::OnCatch.add(:FRIENDBALL,proc{|ball,battle,pokemon|
   pokemon.happiness=200
})

BallHandlers::ModifyCatchRate.add(:MOONBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   if (battler.species == PBSpecies::NIDORANfE) ||
      (battler.species == PBSpecies::NIDORINA) ||
      (battler.species == PBSpecies::NIDOQUEEN) ||
      (battler.species == PBSpecies::NIDORANmA) ||
      (battler.species == PBSpecies::NIDORINO) ||
      (battler.species == PBSpecies::NIDOKING) ||
      (battler.species == PBSpecies::CLEFFA) ||
      (battler.species == PBSpecies::CLEFAIRY) ||
      (battler.species == PBSpecies::CLEFABLE) ||
      (battler.species == PBSpecies::IGGLYBUFF) ||
      (battler.species == PBSpecies::JIGGLYPUFF) ||
      (battler.species == PBSpecies::WIGGLYTUFF) ||
      (battler.species == PBSpecies::SKITTY) ||
      (battler.species == PBSpecies::DELCATTY) ||
      (battler.species == PBSpecies::MUNNA) ||
      (battler.species == PBSpecies::MUSHARNA)
     catchRate*=4
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:SPORTBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*3/2).floor
})

BallHandlers::ModifyCatchRate.add(:BEASTBALL,proc{|ball,catchRate,battle,battler|
   if pbIsUltraBeast?(battler)
     next (catchRate*5).floor
   else
     next (catchRate*1/10).floor
   end   
})

BallHandlers::ModifyCatchRate.add(:DREAMBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*4).floor if battler.status==PBStatuses::SLEEP
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:GLITTERBALL,proc{|ball,catchRate,battle,battler|
  catchRate = (catchRate*0.1).floor if pbIsUltraBeast?(battler)
  catchRate = (catchRate*8).floor if battler.pokemon.isShiny?
  next catchRate
})

BallHandlers::OnCatch.add(:GLITTERBALL,proc{|ball,battle,pokemon|
  pokemon.makeShiny
})
