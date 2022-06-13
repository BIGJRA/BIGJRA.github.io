class PokeBattle_Battler
  # Streamlining of Minior
  def pbShieldsUp?
    return false if @species != PBSpecies::MINIOR
    return false if (@ability != PBAbilities::SHIELDSDOWN) || @effects[PBEffects::Transform]
    return false if self.form != 7
    return true
  end
  # End of Minior streamlining

  def pbCanStatus?(showMessages) #catchall true/false for situations where one can't be statused
    if ((@ability == PBAbilities::FLOWERVEIL || pbPartner.ability == PBAbilities::FLOWERVEIL) && pbHasType?(:GRASS)) && !(self.moldbroken)
      @battle.pbDisplay(_INTL("{1} is protected by Flower Veil!",pbThis)) if showMessages
      return false
    end
    if @battle.FE == PBFields::MISTYT && !isAirborne? # Misty Field
      @battle.pbDisplay(_INTL("Misty Terrain prevents {1} from being inflicted by status!",pbThis(true))) if showMessages
      return false
    end
    return true
  end

#===============================================================================
# Sleep 
#===============================================================================
  def pbCanSleep?(showMessages,selfsleep=false,ignorestatus=false)
    return false if isFainted?
    return false if !pbCanStatus?(showMessages)
    
    if (!ignorestatus && status==PBStatuses::SLEEP) || ability == PBAbilities::COMATOSE
      @battle.pbDisplay(_INTL("{1} is already asleep!",pbThis)) if showMessages
      return false
    end
    if !selfsleep && (status!=0 || damagestate.substitute || (@effects[PBEffects::Substitute]>0 && !PBMoveData.new(@battle.lastMoveUsed).isSoundBased?)) || pbShieldsUp?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if !(self.ability == PBAbilities::SOUNDPROOF)
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
          return false
        end
      end
    end
    if (self.ability == PBAbilities::VITALSPIRIT) || (self.ability == PBAbilities::INSOMNIA) || (self.ability == PBAbilities::SWEETVEIL) ||
      ((self.ability == PBAbilities::LEAFGUARD) && ((@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) ||
       @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0))) && !(self.moldbroken)
         abilityname=PBAbilities.getName(self.ability)
         @battle.pbDisplay(_INTL("{1} stayed awake using its {2}!",pbThis,abilityname)) if showMessages
         return false
    end
    if (pbPartner.ability == PBAbilities::SWEETVEIL) && !(self.moldbroken)
      abilityname=PBAbilities.getName(pbPartner.ability)
      @battle.pbDisplay(_INTL("{1} stayed awake using its partner's {2}!",pbThis,abilityname)) if showMessages
      return false
    end
    if !selfsleep && pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    if @battle.FE == PBFields::ELECTRICT && !isAirborne?
        @battle.pbDisplay(_INTL("The electricity jolted {1} awake!",pbThis)) if showMessages
        return false
    end
    return true
  end

  def pbCanSleepYawn?
    return false if status!=0 || @ability == PBAbilities::COMATOSE
    return false if !pbCanStatus?(true)
    if !(@ability == PBAbilities::SOUNDPROOF)
      for i in 0...4
        return false if @battle.battlers[i].effects[PBEffects::Uproar]>0
      end
    end
    if (@ability == PBAbilities::VITALSPIRIT) || (@ability == PBAbilities::INSOMNIA) || ((@ability == PBAbilities::LEAFGUARD) &&
     ((@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) ||
      @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0))) && !(self.moldbroken) || pbShieldsUp?
      return false
    end
    if (pbPartner.ability == PBAbilities::SWEETVEIL || @ability == PBAbilities::SWEETVEIL) && !(self.moldbroken)
       @battle.pbDisplay(_INTL("{1} is protected by Sweet Veil!",pbThis)) #if showMessages
      return false
    end
    if @battle.FE == PBFields::ELECTRICT && !isAirborne?
        @battle.pbDisplay(_INTL("The electricity jolted {1} awake!",pbThis)) #if showMessages
        return false
    end
    return true
  end

  def pbSleep
    self.status=PBStatuses::SLEEP
    self.statusCount=2+@battle.pbRandom(3)
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
  end

  def pbSleepSelf(duration=-1)
    self.status=PBStatuses::SLEEP
    if duration>0
      self.statusCount=duration
    else
      self.statusCount=2+@battle.pbRandom(3)
    end
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
  end

#===============================================================================
# Poison
#===============================================================================
  def pbCanPoison?(showMessages, ownToxicOrb=false, corrosion=false)
    return false if isFainted?
    return false if !pbCanStatus?(showMessages)
    if status==PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} is already poisoned.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || damagestate.substitute && !ownToxicOrb || (@effects[PBEffects::Substitute]>0 && !ownToxicOrb && !PBMoveData.new(@battle.lastMoveUsed).isSoundBased?) || ability == PBAbilities::COMATOSE || pbShieldsUp?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (pbHasType?(:POISON) || (pbHasType?(:STEEL) && !hasWorkingItem(:RINGTARGET))) && !(self.corroded || corrosion)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if (self.ability == PBAbilities::IMMUNITY) || (self.ability == PBAbilities::PASTELVEIL) || ((self.ability == PBAbilities::LEAFGUARD) &&
      ((@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) ||
      @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0))) && !(self.moldbroken)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents poisoning!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
    end
    if (pbPartner.ability == PBAbilities::PASTELVEIL) && !(self.moldbroken)
      abilityname=PBAbilities.getName(pbPartner.ability)
      @battle.pbDisplay(_INTL("{1} stayed healthy using its partner's {2}!",pbThis,abilityname)) if showMessages
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR) && !ownToxicOrb
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    
    return true
  end

  def pbCanPoisonSynchronize?(opponent,showMessages=false)
    return false if isFainted?
    return false if !pbCanStatus?(showMessages)
    if pbHasType?(:POISON) || (pbHasType?(:STEEL) && !hasWorkingItem(:RINGTARGET))
      @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
        opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
      return false
    end
    return false if self.status!=0 || ability == PBAbilities::COMATOSE
    return false if pbShieldsUp?
    if (self.ability == PBAbilities::IMMUNITY) || (self.ability == PBAbilities::PASTELVEIL) || ((self.ability == PBAbilities::LEAFGUARD) &&
      ((@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) ||
        @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0)))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
      pbThis,PBAbilities.getName(self.ability),
      opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if (pbPartner.ability == PBAbilities::PASTELVEIL) && !(self.moldbroken)
      abilityname=PBAbilities.getName(pbPartner.ability)
      @battle.pbDisplay(_INTL("{1} stayed healthy using its partner's {2}!",pbThis,abilityname)) if showMessages
      return false
    end
    return true
  end

  def pbCanPoisonSpikes?(showMessages=false)
    return false if isFainted?
    return false if self.status!=0 || ability == PBAbilities::COMATOSE
    return false if pbHasType?(:POISON) || pbHasType?(:STEEL)
    return false if (self.ability == PBAbilities::IMMUNITY)
    return false if (self.ability == PBAbilities::PASTELVEIL)
    return false if pbShieldsUp?
    return false if (self.ability == PBAbilities::LEAFGUARD) && ((@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) ||
                    @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0))
    return false if pbOwnSide.effects[PBEffects::Safeguard]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR)
    return false if @battle.FE == PBFields::MISTYT
    return false if @effects[PBEffects::Substitute]>0 || damagestate.substitute

    if (((ability == PBAbilities::FLOWERVEIL) || (pbPartner.ability == PBAbilities::FLOWERVEIL)) && pbHasType?(:GRASS))
      @battle.pbDisplay(_INTL("{1} is protected by Flower Veil!",pbThis)) if showMessages
      return false
    end
    if (pbPartner.ability == PBAbilities::PASTELVEIL) && !(self.moldbroken)
      abilityname=PBAbilities.getName(pbPartner.ability)
      @battle.pbDisplay(_INTL("{1} stayed healthy using its partner's {2}!",pbThis,abilityname)) if showMessages
      return false
    end
    return true
  end

  def pbPoison(attacker,toxic=false)
    self.status=PBStatuses::POISON
    if toxic
      self.statusCount=1
      self.effects[PBEffects::Toxic]=0
    else
      self.statusCount=0
    end
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::POISON
    end
    @battle.pbCommonAnimation("Poison",self,nil)
  end

#===============================================================================
# Burn
#===============================================================================
  def pbCanBurn?(showMessages,ownFlameOrb=false)
    return false if isFainted?
    return false if !pbCanStatus?(showMessages)
    if (self.ability == PBAbilities::WATERBUBBLE) && !(self.moldbroken)
      @battle.pbDisplay(_INTL("{1} is protected by its Water Bubble!",pbThis)) if showMessages
      return false
    end
    if self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} already has a burn.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || damagestate.substitute && !ownFlameOrb || (@effects[PBEffects::Substitute]>0 && !ownFlameOrb && !PBMoveData.new(@battle.lastMoveUsed).isSoundBased?) || ability == PBAbilities::COMATOSE || pbShieldsUp?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if pbHasType?(:FIRE)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if (self.ability == PBAbilities::WATERVEIL) || (self.ability == PBAbilities::LEAFGUARD && ((@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) || @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0))) && !(self.moldbroken)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents burns!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR) && !ownFlameOrb
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    
    return true
  end

  def pbCanBurnSynchronize?(opponent,showMessages=false)
    return false if isFainted?
    return false if self.status!=0 || ability == PBAbilities::COMATOSE
    return false if pbShieldsUp?
    return false if !pbCanStatus?(showMessages)
    if (self.ability == PBAbilities::WATERBUBBLE) && !(self.moldbroken)
      @battle.pbDisplay(_INTL("{1} is protected by its Water Bubble!",pbThis)) if showMessages
      return false
    end
    if pbHasType?(:FIRE)
      @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
      return false
    end
    if (self.ability == PBAbilities::WATERVEIL) || (self.ability == PBAbilities::LEAFGUARD &&
      ((@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) ||
      @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0)))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
      pbThis,PBAbilities.getName(self.ability),
      opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    
    return true
  end

  def pbBurn(attacker)
    self.status=PBStatuses::BURN
    self.statusCount=0
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::BURN
    end
    @battle.pbCommonAnimation("Burn",self,nil)
  end

#===============================================================================
# Paralyze
#===============================================================================
  def pbCanParalyze?(showMessages)
    return false if isFainted?
    return false if !pbCanStatus?(showMessages)
    if pbHasType?(:ELECTRIC)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if status==PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} is already paralyzed!",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || damagestate.substitute || (@effects[PBEffects::Substitute]>0 && !PBMoveData.new(@battle.lastMoveUsed).isSoundBased?) || ability == PBAbilities::COMATOSE || pbShieldsUp?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (self.ability == PBAbilities::LIMBER) || (self.ability == PBAbilities::LEAFGUARD &&
      ((@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) ||
      @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0))) && !(self.moldbroken)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents paralysis!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR)
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanParalyzeSynchronize?(opponent,showMessages=false)
    return false if self.status!=0 || ability == PBAbilities::COMATOSE
    return false if pbShieldsUp?
    return false if !pbCanStatus?(showMessages)
    if pbHasType?(:ELECTRIC)
      return false
    end
    if (self.ability == PBAbilities::LIMBER) || (self.ability == PBAbilities::LEAFGUARD &&
      ((@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) ||
      @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0)))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
        pbThis,PBAbilities.getName(self.ability),
        opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
        return false
    end
    return true
  end

  def pbParalyze(attacker)
    self.status=PBStatuses::PARALYSIS
    self.statusCount=0
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::PARALYSIS
    end
    @battle.pbCommonAnimation("Paralysis",self,nil)
  end

#===============================================================================
# Petrify
#===============================================================================
  def pbCanPetrify?(showMessages=true)
    return false if isFainted?           
    if pbHasType?(:ROCK)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if status==PBStatuses::PETRIFIED
      @battle.pbDisplay(_INTL("{1} is already petrified!",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || damagestate.substitute || (effects[PBEffects::Substitute]>0 && !PBMoveData.new(@battle.lastMoveUsed).isSoundBased?) || (isConst?(ability,PBAbilities,:COMATOSE) && @battle.FE!=PBFields::ELECTRICT) || pbShieldsUp?
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR)    
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    if (@battle.FE == PBFields::MISTYT ||  @battle.state.effects[PBEffects::MistyTerrain]>0) && !isAirborne? # Misty Field
      @battle.pbDisplay(_INTL("Misty Terrain prevents {1} from being inflicted by status!",pbThis)) if showMessages
      return false
    end
    if @battle.FE == PBFields::DRAGONSD && hasWorkingItem(:AMULETCOIN) # Dragon's Den
      @battle.pbDisplay(_INTL("Amulet Coin prevents {1} from being inflicted by status on Dragon's Den!",pbThis)) if showMessages
      return false
    end
    if @battle.FE == 38 && effects[PBEffects::Obstruct]==true # Dimensional Field
      @battle.pbDisplay(_INTL("Dimensional Field obstructs {1} from being inflicted by status!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanPetrifySynchronize?(opponent)
    return false            
  end

  def pbPetrify(attacker)
    self.status=PBStatuses::PETRIFIED
    self.statusCount=0
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::PETRIFIED
    end
  end


#===============================================================================
# Freeze
#===============================================================================
  def pbCanFreeze?(showMessages)
    return false if isFainted?
    return false if !pbCanStatus?(showMessages)
    if (@battle.pbWeather==PBWeather::SUNNYDAY && !hasWorkingItem(:UTILITYUMBRELLA)) ||
      self.status!=0 || ability == PBAbilities::COMATOSE ||
      (self.ability == PBAbilities::LEAFGUARD && @battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0)) ||
      (self.ability == PBAbilities::MAGMAARMOR) || pbOwnSide.effects[PBEffects::Safeguard]>0 ||
      (pbOwnSide.effects[PBEffects::Safeguard]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR)) ||
      damagestate.substitute || (@effects[PBEffects::Substitute]>0 && !PBMoveData.new(@battle.lastMoveUsed).isSoundBased?) ||
      @battle.FE == PBFields::SWAMPF && !(self.moldbroken) || pbShieldsUp? || (pbHasType?(:ICE) && !hasWorkingItem(:RINGTARGET))
        return false
    end
    
    return true
  end

  def pbFreeze
    self.status=PBStatuses::FROZEN
    self.statusCount=0
    pbCancelMoves
    @battle.pbCommonAnimation("Frozen",self,nil)
  end

#===============================================================================
# Generalised status displays
#===============================================================================
  def pbContinueStatus(showAnim=true)
    case self.status
      when PBStatuses::SLEEP
        @battle.pbCommonAnimation("Sleep",self,nil)
        @battle.pbDisplay(_INTL("{1} is fast asleep.",pbThis))
      when PBStatuses::POISON
        @battle.pbCommonAnimation("Poison",self,nil)
        @battle.pbDisplay(_INTL("{1} is hurt by poison!",pbThis))
      when PBStatuses::BURN
        @battle.pbCommonAnimation("Burn",self,nil)
        @battle.pbDisplay(_INTL("{1} is hurt by its burn!",pbThis))
      when PBStatuses::PARALYSIS
        @battle.pbCommonAnimation("Paralysis",self,nil)
        @battle.pbDisplay(_INTL("{1} is paralyzed! It can't move!",pbThis)) 
      when PBStatuses::FROZEN
        @battle.pbCommonAnimation("Frozen",self,nil)
        @battle.pbDisplay(_INTL("{1} is frozen solid!",pbThis))
    end
  end

  def pbCureStatus(showMessages=true)
    oldstatus=self.status
    if self.status==PBStatuses::SLEEP
      self.effects[PBEffects::Nightmare]=false
    end
    self.status=0
    self.statusCount=0
    if showMessages
      case oldstatus
        when PBStatuses::SLEEP
          @battle.pbDisplay(_INTL("{1} woke up!",pbThis))
        when PBStatuses::POISON
        when PBStatuses::BURN
        when PBStatuses::PARALYSIS
        when PBStatuses::FROZEN
          @battle.pbDisplay(_INTL("{1} was defrosted!",pbThis))
      end
    end
  end

#===============================================================================
# Confuse
#===============================================================================
  def pbCanConfuse?(showMessages=true)
    return false if isFainted?
    if damagestate.substitute || (@effects[PBEffects::Substitute]>0 && !PBMoveData.new(@battle.lastMoveUsed).isSoundBased?)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if !pbCanConfuseSelf?(showMessages, true)
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR)
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanConfuseSelf?(showMessages, moldbreakercheck=false)
    return false if isFainted?
    if @effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if (self.ability == PBAbilities::OWNTEMPO) && !(self.moldbroken && moldbreakercheck)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    if @battle.FE == PBFields::ASHENB && (pbHasType?(:FIGHTING) || (self.ability == PBAbilities::INNERFOCUS))
      @battle.pbDisplay(_INTL("{1} broke through the confusion!",pbThis)) if showMessages
      return false
    end
    if @battle.FE == PBFields::MISTYT && !isAirborne? # Misty Field
      @battle.pbDisplay(_INTL("Misty Terrain prevents {1} from being inflicted by status!",pbThis(true))) if showMessages
      return false
    end
    return true
  end

  def pbConfuseSelf
    if @effects[PBEffects::Confusion]==0 && !(self.ability == PBAbilities::OWNTEMPO)
      @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",self,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
    end
  end

  def pbContinueConfusion
    @battle.pbCommonAnimation("Confusion",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is confused!",pbThis))
  end

  def pbCureConfusion(showMessages=true)
    @effects[PBEffects::Confusion]=0
    @battle.pbDisplay(_INTL("{1} snapped out of confusion!",pbThis)) if showMessages
  end

  #===============================================================================
  # Attraction
  #===============================================================================
  def pbCanAttract?(attacker,showMessages=true)
    return false if isFainted?
    return false if !attacker
    if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    agender=attacker.gender
    ogender=self.gender
    if agender==2 || ogender==2 || agender==ogender
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if hasWorkingAbility(:OBLIVIOUS) && !(self.moldbroken) 
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",pbThis,
        PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    return true
  end

  def pbAnnounceAttract(seducer)
    @battle.pbCommonAnimation("Attract",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is in love with {2}!",
      pbThis,seducer.pbThis(true)))
  end

  def pbContinueAttract
    @battle.pbDisplay(_INTL("{1} is immobilized by love!",pbThis)) 
  end

  #===============================================================================
  # Increase stat stages
  #===============================================================================
  def pbTooHigh?(stat)
    return @stages[stat]>=6
  end

  def pbCanIncreaseStatStage?(stat,showMessages=false)
    return false if isFainted?
    if pbTooHigh?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!",pbThis,pbGetStatName(stat))) if showMessages
      return false
    end
    return true
  end

  def pbIncreaseStatBasic(stat,increment)
    increment*=2 if (self.ability == PBAbilities::SIMPLE) && !(self.moldbroken)
    @stages[stat]+=increment
    @stages[stat]=6 if @stages[stat]>6
  end

  # UPDATE 11/29/2013
  # Contrary
  # calls reduce stat from here if we have contrary
  # Added an extra parameter to determine if this was called from reduce stat
  # changed from: def pbIncreaseStat(stat,increment,showMessages,attacker=nil,upanim=true)
  def pbIncreaseStat(stat,increment,abilitymessage:true,statmessage:true)
    # here we call reduce instead
    if (self.ability == PBAbilities::CONTRARY) && !(self.moldbroken) && @statrepeat == false
      @statrepeat = true
      return pbReduceStat(stat,increment,abilitymessage:abilitymessage,statmessage:statmessage)
    end
    # end of update
    arrStatTexts=[_INTL("{1}'s {2} rose!",pbThis,pbGetStatName(stat)), _INTL("{1}'s {2} rose sharply!",pbThis,pbGetStatName(stat)), _INTL("{1}'s {2} rose drastically!",pbThis,pbGetStatName(stat)), _INTL("{1}'s {2} went way up!",pbThis,pbGetStatName(stat))]
    if pbCanIncreaseStatStage?(stat,abilitymessage)
      pbIncreaseStatBasic(stat,increment)
      if !@statupanimplayed
        @battle.pbCommonAnimation("StatUp",self,nil)
        @statupanimplayed = true
      end
      increment*=2 if (self.ability == PBAbilities::SIMPLE) && !(self.moldbroken)
      if increment>3
        @battle.pbDisplay(arrStatTexts[3]) if statmessage
      elsif increment==3
        @battle.pbDisplay(arrStatTexts[2]) if statmessage
      elsif increment==2
        @battle.pbDisplay(arrStatTexts[1]) if statmessage
      else
        @battle.pbDisplay(arrStatTexts[0]) if statmessage
      end
      @statrepeat = false
      return true
    end
    @statrepeat = false
    return false
  end

  #===============================================================================
  # Decrease stat stages
  #===============================================================================
  def pbTooLow?(stat)
    return @stages[stat]<=-6
  end

  # Tickle (04A) and Memento (0E2) can't use this, but replicate it instead.
  # (Reason is they lower more than 1 stat independently, and therefore could
  # show certain messages twice which is undesirable.)
  def pbCanReduceStatStage?(stat,showMessages=false,selfreduce=false)
    return false if isFainted?
    if !selfreduce
      abilityname=PBAbilities.getName(self.ability) if self.ability
      if damagestate.substitute || (@effects[PBEffects::Substitute]>0 && !PBMoveData.new(@battle.lastMoveUsed).isSoundBased?) &&
        @battle.lastMoveUsed != PBMoves::PLAYNICE
        @battle.pbDisplay(_INTL("But it failed!")) if showMessages
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR)
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showMessages
        return false
      end
      if (((self.ability == PBAbilities::CLEARBODY) || (self.ability == PBAbilities::WHITESMOKE)) && !(self.moldbroken)) || (self.ability == PBAbilities::FULLMETALBODY)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
        return false
      end
      if stat==PBStats::ATTACK && (self.ability == PBAbilities::HYPERCUTTER) && !(self.moldbroken)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",pbThis,abilityname)) if showMessages
        return false
      end
      if stat==PBStats::DEFENSE && (self.ability == PBAbilities::BIGPECKS) && !(self.moldbroken)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents Defense loss!",pbThis,abilityname)) if showMessages
        return false
      end
      if stat==PBStats::ACCURACY && !(self.moldbroken) && (self.ability == PBAbilities::KEENEYE)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents Accuracy loss!",pbThis,abilityname)) if showMessages
        return false
      end
      if (((ability == PBAbilities::FLOWERVEIL) || (pbPartner.ability == PBAbilities::FLOWERVEIL)) && pbHasType?(:GRASS)) && !(self.moldbroken)
        @battle.pbDisplay(_INTL("{1} is protected by Flower Veil!",pbThis)) if showMessages
        return false
      end
    end
    if pbTooLow?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",pbThis,pbGetStatName(stat))) if showMessages
      return false
    end
    return true
  end

  def pbReduceStatBasic(stat,increment)
    increment*=2 if (self.ability == PBAbilities::SIMPLE) && !(self.moldbroken)
    @stages[stat]-=increment
    @stages[stat]=-6 if @stages[stat]<-6
    @statLowered = true
  end

  def pbReduceStat(stat,increment,abilitymessage:true,statmessage:true, statdropper: nil, defiant_proc: true)
    # here we play uno reverse if we have Mirror Armor
    if (self.ability == PBAbilities::MIRRORARMOR) && false
      if !attacker.nil?
        if attacker.hp!=0
          @battle.pbDisplay(_INTL("{1}'s Mirror Armor reflected the stat drop!", pbThis))
          return attacker.pbReduceStat(stat,increment,abilitymessage,self,downanim=true,selfreduce=false, cont_call=false, statmessage=true, true)
        end
      else
        mirrorOpp = self.pbOppositeOpposing
        if mirrorOpp.hp!=0
          @battle.pbDisplay(_INTL("{1}'s Mirror Armor reflected the stat drop!", pbThis))
          return mirrorOpp.pbReduceStat(stat,increment,abilitymessage,self,downanim=true,selfreduce=false, cont_call=false, statmessage=true, true)
        elsif mirrorOpp.pbPartner.hp!=0
          @battle.pbDisplay(_INTL("{1}'s Mirror Armor reflected the stat drop!", pbThis))
          return mirrorOpp.pbPartner.pbReduceStat(stat,increment,abilitymessage,self,downanim=true,selfreduce=false, cont_call=false, statmessage=true, true)
        end
      end
      @battle.pbDisplay(_INTL("{1}'s Mirror Armor blocked the stat drop!", pbThis))
    end
    # here we call increase if we have contrary
    if (self.ability == PBAbilities::CONTRARY) && @statrepeat == false && !(self.moldbroken)
      @statrepeat = true
      return pbIncreaseStat(stat,increment,abilitymessage:abilitymessage,statmessage:statmessage)
    end
    if pbCanReduceStatStage?(stat,abilitymessage,statdropper==self)
      pbReduceStatBasic(stat,increment)
      if !@statdownanimplayed
        @battle.pbCommonAnimation("StatDown",self)
        @statdownanimplayed = true
      end
      increment*=2 if (self.ability == PBAbilities::SIMPLE) && !(self.moldbroken)
      harsh = ""
      harsh = "harshly " if increment==2
      harsh = "dramatically " if increment>=3
      stat_text = _INTL("{1}'s {2} {3}fell!",pbThis,pbGetStatName(stat),harsh)
      @battle.pbDisplay(stat_text) if statmessage
      if defiant_proc
        if (self.ability == PBAbilities::DEFIANT) && pbCanIncreaseStatStage?(PBStats::ATTACK) && (statdropper.nil? || self.pbIsOpposing?(statdropper.index))
          pbIncreaseStat(PBStats::ATTACK,2,statmessage:false)
          @battle.pbDisplay(_INTL("Defiant sharply raised {1}'s Attack!", pbThis))
        end
        if (self.ability == PBAbilities::COMPETITIVE) && pbCanIncreaseStatStage?(PBStats::SPATK) && (statdropper.nil? || self.pbIsOpposing?(statdropper.index))
          pbIncreaseStat(PBStats::SPATK,2,statmessage:false)
          @battle.pbDisplay(_INTL("Competitive sharply raised {1}'s Special Attack!", pbThis))
        end
      end
      @statrepeat = false
      return true
    end
    @statrepeat = false
    return false
  end

  def pbReduceAttackStatStageIntimidate(opponent)
    return false if isFainted?
    return false if @effects[PBEffects::Substitute]>0
    if (self.ability == PBAbilities::CLEARBODY) || (self.ability == PBAbilities::WHITESMOKE) || (self.ability == PBAbilities::HYPERCUTTER) || (self.ability == PBAbilities::FULLMETALBODY)
      abilityname=PBAbilities.getName(self.ability)
      oppabilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!", pbThis,abilityname,opponent.pbThis(true),oppabilityname))
      if hasWorkingItem(:ADRENALINEORB) && pbCanIncreaseStatStage?(PBStats::SPEED,false) && self.stages[PBStats::ATTACK] > -6
        pbIncreaseStat(PBStats::SPEED,1,statmessage:false)
        @battle.pbDisplay(_INTL("{1}'s Adrenaline orb boosts its Speed!",pbThis(true)))
        opponent.pbDisposeItem(false)
      end
      return false
    end
    if pbOwnSide.effects[PBEffects::Mist]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR)
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis))
      if hasWorkingItem(:ADRENALINEORB) && pbCanIncreaseStatStage?(PBStats::SPEED,false) && self.stages[PBStats::ATTACK] > -6
        pbIncreaseStat(PBStats::SPEED,1,statmessage:false)
        @battle.pbDisplay(_INTL("{1}'s Adrenaline orb boosts its Speed!",pbThis(true)))
        pbDisposeItem(false)
      end
      return false
    end
    if pbCanReduceStatStage?(PBStats::ATTACK,false)
      pbReduceStat(PBStats::ATTACK,1,statmessage:false, statdropper: opponent, defiant_proc: false)
      oppabilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} cuts {3}'s Attack!",opponent.pbThis,
        oppabilityname,pbThis(true))) if !(self.ability == PBAbilities::CONTRARY)
      if (self.ability == PBAbilities::CONTRARY)
        @battle.pbDisplay(_INTL("{1}'s {2} boosts {3}'s Attack!",opponent.pbThis,
          oppabilityname,pbThis(true)))
      end
      if (self.ability == PBAbilities::DEFIANT)
        pbIncreaseStat(PBStats::ATTACK,2,statmessage:false)
        @battle.pbDisplay(_INTL("Defiant sharply raised {1}'s Attack!", pbThis))
      end
      if (self.ability == PBAbilities::COMPETITIVE)
        pbIncreaseStat(PBStats::SPATK,2,statmessage:false)
        @battle.pbDisplay(_INTL("Competitive sharply raised {1}'s Special Attack!", pbThis))
      end
      if hasWorkingItem(:ADRENALINEORB) && pbCanIncreaseStatStage?(PBStats::SPEED,false)
        pbIncreaseStat(PBStats::SPEED,1,statmessage:false)
        @battle.pbDisplay(_INTL("{1}'s Adrenaline orb boosts its Speed!",pbThis(true)))
        pbDisposeItem(false)
      end
      if hasWorkingItem(:WHITEHERB)
        reducedstats=false
        for i in 1..7
        if self.stages[i]<0
          self.stages[i]=0; reducedstats=true
          end
        end
        if reducedstats
          itemname=(self.item==0) ? "" : PBItems.getName(self.item)
          @battle.pbDisplay(_INTL("{1}'s {2} restored its status!",pbThis,itemname))
          pbDisposeItem(false)
        end
      end
      return true
    end
    return false
  end

  def pbReduceIlluminate(opponent)
    return false if isFainted?
    return false if @effects[PBEffects::Substitute]>0
    if (self.ability == PBAbilities::CLEARBODY) || (self.ability == PBAbilities::WHITESMOKE) ||
      (self.ability == PBAbilities::FULLMETALBODY) || (self.ability == PBAbilities::KEENEYE)
      abilityname=PBAbilities.getName(self.ability)
      oppabilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
        pbThis,abilityname,opponent.pbThis(true),oppabilityname))
      return false
    end
    if pbOwnSide.effects[PBEffects::Mist]>0 && !(@battle.battlers[@battle.lastMoveUser]).hasWorkingAbility(:INFILTRATOR)
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis))
      return false
    end
    if pbCanReduceStatStage?(PBStats::ACCURACY,false)
      pbReduceStat(PBStats::ACCURACY,1,statmessage:false)
      oppabilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} cuts {3}'s Accuracy!",opponent.pbThis,
        oppabilityname,pbThis(true)))
      return true
    end
    return false
  end

  def pbGetStatName(stat)
    #can't use STATSTRINGS for this bc that doesn't have Acc and Eva 
    return ["HP","Attack", "Defense", "Speed", "Sp. Attack", "Sp. Defense", "Accuracy", "Evasion"][stat]
  end
end