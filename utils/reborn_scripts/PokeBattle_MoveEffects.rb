################################################################################
# Superclass that handles moves using a non-existent function code.
# Damaging moves just do damage with no additional effect.
# Non-damaging moves always fail.
################################################################################
class PokeBattle_UnimplementedMove < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @basedamage>0
      return super(attacker,opponent,hitnum,alltargets,showanimation)
    else
      @battle.pbDisplay("But it failed!")
      return -1
    end
  end
end

################################################################################
# Superclass for a failed move.  Always fails.
################################################################################
class PokeBattle_FailedMove < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    @battle.pbDisplay("But it failed!")
    return -1
  end
end

################################################################################
# Pseudomove for confusion damage
################################################################################
class PokeBattle_Confusion < PokeBattle_Move
  def initialize(battle,move)
    @battle=battle
    @basedamage=40
    @type=-1
    @accuracy=100
    @pp=-1
    @addlEffect=0
    @target=0
    @priority=0
    @flags=35
    @thismove=move
    @name=""
    @id=0
  end

  def pbIsPhysical?(type=nil)
    return true
  end

  def pbIsSpecial?(type=@type)
    return false
  end

  def pbCalcDamage(attacker,opponent, hitnum: 0)
    return super(attacker,opponent,
       PokeBattle_Move::NOCRITICAL|PokeBattle_Move::SELFCONFUSE|PokeBattle_Move::NOTYPE|PokeBattle_Move::NOWEIGHTING, hitnum: hitnum)
  end

  def pbEffectMessages(attacker,opponent,ignoretype=false)
    return super(attacker,opponent,true)
  end
end

################################################################################
# Implements the move Struggle.
# For cases where the real move named Struggle is not defined.
################################################################################
class PokeBattle_Struggle < PokeBattle_Move
  def initialize(battle,move,user)
    @battle=battle
    @basedamage=50
    @type=-1
    @accuracy=100
    @pp=-1
    @totalpp=0
    @addlEffect=0
    @target=0
    @priority=0
    @flags=35     #flags abf
    @thismove=nil # not associated with a move
    @name=""
    @id=302#-1        # doesn't work if 0
    @function = 0x02
  end

  def pbIsPhysical?(type=nil)
    return true
  end

  def pbIsSpecial?(type=@type)
    return false
  end

  def pbDisplayUseMessage(attacker)
    @battle.pbDisplayBrief(_INTL("{1} is struggling!",attacker.pbThis))
    return 0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=false)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation=false)
    if opponent.damagestate.calcdamage>0
      attacker.pbReduceHP((attacker.totalhp/4.0).floor)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end

  def pbCalcDamage(attacker,opponent, hitnum: 0)
    return super(attacker,opponent,PokeBattle_Move::IGNOREPKMNTYPES, hitnum: hitnum)
  end
end

################################################################################
# No additional effect.
################################################################################
class PokeBattle_Move_000 < PokeBattle_Move
end

################################################################################
# Does absolutely nothing (Splash / Celebrate).
################################################################################
class PokeBattle_Move_001 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.state.effects[PBEffects::Gravity]>0 if @id == PBMoves::SPLASH
    return false
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @id == PBMoves::CELEBRATE
      ret = super(attacker,opponent,hitnum,alltargets,showanimation)
      @battle.pbDisplay(_INTL("Congratulations, #{$Trainer.name}!"))
      return ret
    end
    if @battle.FE == PBFields::WATERS
      return -1 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,true)
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      ret=opponent.pbReduceStat(PBStats::ACCURACY,1,abilitymessage:false, statdropper: attacker)
      return ret ? 0 : -1
    else
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      @battle.pbDisplay(_INTL("But nothing happened!"))
      return 0
    end
  end
end

################################################################################
# Struggle.  Overrides the default Struggle effect above.
################################################################################
class PokeBattle_Move_002 < PokeBattle_Struggle
end

################################################################################
# Puts the target to sleep. (Dark Void / Grass Whistle / Spore / Sleep Powder /
# Relic Song / Lovely Kiss / Sing / Hypnosis)
################################################################################
class PokeBattle_Move_003 < PokeBattle_Move
  def pbOnStartUse(attacker)
    if (@id == PBMoves::DARKVOID) && !((attacker.species == PBSpecies::DARKRAI) || ((attacker.species == PBSpecies::HYPNO) && (attacker.form == 1)))
    # any non-darkrai Pokemon
      @battle.pbDisplay(_INTL("But {1} can't use the move!",attacker.pbThis))
      return false
    else
      return true
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if opponent.pbCanSleep?(true)
      if (@id == PBMoves::SPORE) || (@id == PBMoves::SLEEPPOWDER) 
        if opponent.pbHasType?(:GRASS)
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
          return -1
        elsif opponent.ability == PBAbilities::OVERCOAT && !(opponent.moldbroken)
          @battle.pbDisplay(_INTL("{1}'s {2} made the attack ineffective!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
          return -1
        elsif (opponent.item == PBItems::SAFETYGOGGLES)
          @battle.pbDisplay(_INTL("{1} avoided the move with its {2}!",
          opponent.pbThis,PBItems.getName(opponent.item),self.name))
          return -1
        end
      end
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbSleep
      @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanSleep?(false)
      opponent.pbSleep
      @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
      return true
    end
    return false
  end
end

################################################################################
# Makes the target drowsy.  It will fall asleep at the end of the next turn. (Yawn)
################################################################################
class PokeBattle_Move_004 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !opponent.pbCanSleep?(true)
    if opponent.effects[PBEffects::Yawn]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Yawn]=2
    @battle.pbDisplay(_INTL("{1} made {2} drowsy!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end

################################################################################
# Poisons the target. (Gunk Shot / Sludge Wave / Sludge Bomb / Poison Jab / Cross Poison 
# / Sludge / Poison Tail / Smog / Poison Sting / Poison Gas / Poison Powder)
################################################################################
class PokeBattle_Move_005 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if (@id == PBMoves::POISONPOWDER)
      if opponent.pbHasType?(:GRASS)
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
        return -1
      elsif (opponent.ability == PBAbilities::OVERCOAT) && !(opponent.moldbroken)
        @battle.pbDisplay(_INTL("{1}'s {2} made the attack ineffective!",
        opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
        return -1
      elsif (opponent.item == PBItems::SAFETYGOGGLES)
        @battle.pbDisplay(_INTL("{1} avoided the move with its {2}!",
        opponent.pbThis,PBItems.getName(opponent.item),self.name))
        return -1
      end
    end
    return -1 if !opponent.pbCanPoison?(true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} is poisoned!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if @battle.FE == PBFields::WASTELAND && ((@id == PBMoves::GUNKSHOT) || (@id == PBMoves::SLUDGEBOMB) || 
      (@id == PBMoves::SLUDGEWAVE) || (@id == PBMoves::SLUDGE)) &&
     ((!opponent.pbHasType?(:POISON) && !opponent.pbHasType?(:STEEL)) || opponent.corroded) &&
     !(opponent.ability == PBAbilities::TOXICBOOST) &&
     !(opponent.ability == PBAbilities::POISONHEAL) &&
     (!(opponent.ability == PBAbilities::IMMUNITY) && !(opponent.moldbroken))
      rnd=@battle.pbRandom(4)
      case rnd
        when 0
          return false if !opponent.pbCanBurn?(false)
          opponent.pbBurn(attacker)
          @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
        when 1
          return false if !opponent.pbCanFreeze?(false)
          opponent.pbFreeze
          @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
        when 2
          return false if !opponent.pbCanParalyze?(false)
          opponent.pbParalyze(attacker)
          @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
        when 3
          return false if !opponent.pbCanPoison?(false)
          opponent.pbPoison(attacker)
          @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
        end
    else
      return false if !opponent.pbCanPoison?(false)
      opponent.pbPoison(attacker)
      @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))

    end
    return true
  end
end

################################################################################
# Badly poisons the target. (Poison Fang / Toxic)
################################################################################
class PokeBattle_Move_006 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanPoison?(true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbPoison(attacker,true)
    @battle.pbDisplay(_INTL("{1} is badly poisoned!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(false)
    opponent.pbPoison(attacker,true)
    @battle.pbDisplay(_INTL("{1} was badly poisoned!",opponent.pbThis))
    return true
  end
end

################################################################################
# Paralyzes the target. (Nuzzle / Dragon Breath / Bolt Strike / Zap Cannon / Thunderbolt
# / Discharge / Thunder Punch / Spark / Thunder Shock / Thunder Wave / Force Palm 
# / Lick / Stun Spore / Body Slam / Glare)
################################################################################
class PokeBattle_Move_007 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanParalyze?(true)
    if (@id == PBMoves::STUNSPORE)
      if opponent.pbHasType?(:GRASS)
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
        return -1
      elsif (opponent.ability == PBAbilities::OVERCOAT) && !(opponent.moldbroken)
        @battle.pbDisplay(_INTL("{1}'s {2} made the attack ineffective!",
        opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
        return -1
      elsif (opponent.item == PBItems::SAFETYGOGGLES)
        @battle.pbDisplay(_INTL("{1} avoided the move with its {2}!",
        opponent.pbThis,PBItems.getName(opponent.item),self.name))
        return -1
      end
    else
      if (@id == PBMoves::THUNDERWAVE)
        typemod=pbTypeModifier(@type,attacker,opponent)
        if typemod==0
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
          return -1
        end
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
    return 0
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.effects[PBEffects::Minimize] && (@id == PBMoves::BODYSLAM)
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed! It may be unable to move!",opponent.pbThis))
    return true
  end
end

################################################################################
# Paralyzes the target.  (Thunder)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
# (Handled in pbAccuracyCheck): Accuracy perfect in rain, 50% in sunshine.
################################################################################
class PokeBattle_Move_008 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed! It may be unable to move!",opponent.pbThis))
    return true
  end
end

################################################################################
# Paralyzes the target.  May cause the target to flinch. (Thunder Fang)
################################################################################
class PokeBattle_Move_009 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanParalyze?(false)
      opponent.pbParalyze(attacker)
      @battle.pbDisplay(_INTL("{1} was paralyzed! It may be unable to move!",opponent.pbThis))
      return true
    end
    return false
  end

  def pbSecondAdditionalEffect(attacker,opponent)
    if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end
end

 
################################################################################
# Burns the target. (Blue Flare / Fire Blast / Heat Wave / Inferno / Searing Shot
# / Flamethrower / Blaze Kick / Lava Plume / Fire Punch / Flame Wheel / Ember
# / Will-O-Wisp / Scald / Steam Eruption)
################################################################################
class PokeBattle_Move_00A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanBurn?(true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(false)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end

################################################################################
# Burns the target.  May cause the target to flinch. (Fire Fang)
################################################################################
class PokeBattle_Move_00B < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanBurn?(false)
      opponent.pbBurn(attacker)
      @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
      return true
    end
    return false
  end

  def pbSecondAdditionalEffect(attacker,opponent)
    if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end
end

################################################################################
# Freezes the target. (Ice Beam / Ice Punch / Powder Snow / Freeze-Dry)
################################################################################
class PokeBattle_Move_00C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanFreeze?(true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbFreeze
    @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanFreeze?(false)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      return true
    end
    return false
  end
end

################################################################################
# Freezes the target. (Blizzard)
# (Handled in pbAccuracyCheck): Accuracy perfect in hail.
################################################################################
class PokeBattle_Move_00D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanFreeze?(true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbFreeze
    @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanFreeze?(false)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      return true
    end
    return false
  end
end

################################################################################
# Freezes the target.  May cause the target to flinch. (Ice Fang)
################################################################################
class PokeBattle_Move_00E < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanFreeze?(false)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      return true
    end
    return false
  end

  def pbSecondAdditionalEffect(attacker,opponent)
    if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end
end

################################################################################
# Causes the target to flinch. (Flinch / Dark Pulse / Bite / Rolling Kick / Air Slash
# / Astonish / Needle Arm / Hyper Fang / Headbutt / Extrasensory / Zen Headbutt
# / Heart Stamp / Rock Slide / Iron Head / Waterfall / Zing Zap)
################################################################################
class PokeBattle_Move_00F < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute 
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end
end

################################################################################
# Causes the target to flinch.  Does double damage if the target is Minimized.
# (Stomp, Steamroller, Dragon Rush)
################################################################################
class PokeBattle_Move_010 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute 
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.effects[PBEffects::Minimize]
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# Causes the target to flinch.  Fails if the user is not asleep. (Snore)
################################################################################
class PokeBattle_Move_011 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute 
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end

  def pbMoveFailed(attacker,opponent)
    return attacker.status!=PBStatuses::SLEEP && attacker.ability != PBAbilities::COMATOSE
  end
end

################################################################################
# Causes the target to flinch.  Fails if this isn't the user's first turn. (Fake Out)
################################################################################
class PokeBattle_Move_012 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute 
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end

  def pbMoveFailed(attacker,opponent)
    return (attacker.turncount != 1 || !attacker.isFirstMoveOfRound)
  end
end

################################################################################
# Confuses the target. (Confusion, Signal Beam, Dynamic Punch, Chatter, Confuse Ray,
# Rock Climb, Dizzy Punch, Supersonic, Sweet Kiss, Teeter Dance, Psybeam, Water Pulse)
################################################################################
class PokeBattle_Move_013 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if @battle.FE == PBFields::FAIRYTALEF && (@id == PBMoves::SWEETKISS)
      if !opponent.damagestate.substitute && opponent.status==PBStatuses::SLEEP
        opponent.pbCureStatus
      end
    end
    if opponent.pbCanConfuse?(true)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanConfuse?(false)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return true
    end
    return false
  end
end

################################################################################
# Confuses the target.  Chance of causing confusion depends on the cry's volume.
# Confusion chance is 0% if user is not Chatot.  (Chatter)
################################################################################
class PokeBattle_Move_014 < PokeBattle_Move
  #TODO: Play the actual chatter cry as part of the move animation
# @battle.scene.pbChatter(attacker,opponent) # Just plays cry
  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanConfuse?(false)
      if (attacker.species == PBSpecies::CHATOT) &&
         !attacker.effects[PBEffects::Transform] &&
         (opponent.ability != PBAbilities::SHIELDDUST || opponent.moldbroken)
        chance=0
        if attacker.pokemon && attacker.pokemon.chatter
          chance+=attacker.pokemon.chatter.intensity*10.0/127
        end
        if pbRandom(100)<chance
          opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
          @battle.pbCommonAnimation("Confusion",opponent,nil)
          @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
          return true
        end
      end
    end
    return false
  end
end

################################################################################
# Confuses the target.  (Hurricane)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
# (Handled in pbAccuracyCheck): Accuracy perfect in rain, 50% in sunshine.
################################################################################
class PokeBattle_Move_015 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if opponent.pbCanConfuse?(true)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanConfuse?(false)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return true
    end
    return false
  end
end

################################################################################
# Attracts the target. (Attract)
################################################################################
class PokeBattle_Move_016 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbCanAttract?(attacker)
      return -1
    end
    if @battle.pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("The Aroma Veil prevents #{opponent.pbThis} from infatuation!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Attract]=attacker.index
    @battle.pbCommonAnimation("Attract",opponent,nil)
    @battle.pbDisplay(_INTL("{1} fell in love!",opponent.pbThis))
    if opponent.hasWorkingItem(:DESTINYKNOT) &&
     attacker.ability != PBAbilities::OBLIVIOUS &&
      attacker.effects[PBEffects::Attract]<0
      attacker.effects[PBEffects::Attract]=opponent.index
      @battle.pbCommonAnimation("Attract",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s {2} infatuated {3}!",opponent.pbThis,
      PBItems.getName(opponent.item),attacker.pbThis(true)))
    end
    return 0
  end
end

################################################################################
# Burns, freezes or paralyzes the target. (Tri Attack)
################################################################################
class PokeBattle_Move_017 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    rnd=@battle.pbRandom(3)
    case rnd
      when 0
        return false if !opponent.pbCanBurn?(false)
        opponent.pbBurn(attacker)
        @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
      when 1
        return false if !opponent.pbCanFreeze?(false)
        opponent.pbFreeze
        @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      when 2
        return false if !opponent.pbCanParalyze?(false)
        opponent.pbParalyze(attacker)
        @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
    end
    return true
  end
end

################################################################################
# Cures user of burn, poison and paralysis. (Refresh)
################################################################################
class PokeBattle_Move_018 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.status!=PBStatuses::BURN &&
       attacker.status!=PBStatuses::POISON &&
       attacker.status!=PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      t=attacker.status
      attacker.status=0
      attacker.statusCount=0
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      if t==PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} was cured of its burn.",attacker.pbThis))
      elsif t==PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbThis))
      elsif t==PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",attacker.pbThis))
      end
      return 0
    end
  end
end

################################################################################
# Cures all party Pokémon of permanent status problems. (Aromatherapy, Heal Bell)
################################################################################
class PokeBattle_Move_019 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if (@id == PBMoves::AROMATHERAPY)
      @battle.pbDisplay(_INTL("A soothing aroma wafted through the area!"))
    else
      @battle.pbDisplay(_INTL("A bell chimed!"))
    end
    activepkmn=[]
    for i in @battle.battlers
      next if attacker.pbIsOpposing?(i.index)
      case i.status
        when PBStatuses::PARALYSIS
          @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",i.pbThis))
        when PBStatuses::SLEEP
          @battle.pbDisplay(_INTL("{1} was woken from its sleep.",i.pbThis))
        when PBStatuses::POISON
          @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",i.pbThis))
        when PBStatuses::BURN
          @battle.pbDisplay(_INTL("{1} was cured of its burn.",i.pbThis))
        when PBStatuses::FROZEN
          @battle.pbDisplay(_INTL("{1} was defrosted.",i.pbThis))
      end
      i.status=0
      i.statusCount=0
      activepkmn.push(i.pokemonIndex)
    end
    party=@battle.pbParty(attacker.index) # NOTE: Considers both parties in multi battles
    for i in 0...party.length
      next if activepkmn.include?(i)
      next if !party[i] || party[i].isEgg?
      case party[i].status
        when PBStatuses::PARALYSIS
          @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",party[i].name))
        when PBStatuses::SLEEP
          @battle.pbDisplay(_INTL("{1} was woken from its sleep.",party[i].name))
        when PBStatuses::POISON
          @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",party[i].name))
        when PBStatuses::BURN
          @battle.pbDisplay(_INTL("{1} was cured of its burn.",party[i].name))
        when PBStatuses::FROZEN
          @battle.pbDisplay(_INTL("{1} was defrosted.",party[i].name))
      end
      party[i].status=0
      party[i].statusCount=0
    end
    return 0
  end
end

################################################################################
# Safeguards the user's side from being inflicted with status problems. (Safeguard)
################################################################################
class PokeBattle_Move_01A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbOwnSide.effects[PBEffects::Safeguard]=5
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team became cloaked in a mystical veil!"))
    else
      @battle.pbDisplay(_INTL("The foe's team became cloaked in a mystical veil!"))
    end
    return 0
  end
end

################################################################################
# User passes its status problem to the target. (Psycho Shift)
################################################################################
class PokeBattle_Move_01B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.status==0 ||
      (attacker.status==PBStatuses::PARALYSIS && !opponent.pbCanParalyze?(false)) ||
      (attacker.status==PBStatuses::SLEEP && !opponent.pbCanSleep?(false)) ||
      (attacker.status==PBStatuses::POISON && !opponent.pbCanPoison?(false)) ||
      (attacker.status==PBStatuses::BURN && !opponent.pbCanBurn?(false)) ||
      (attacker.status==PBStatuses::FROZEN && !opponent.pbCanFreeze?(false))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    case attacker.status
      when PBStatuses::PARALYSIS
        opponent.pbParalyze(attacker)
        @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
        opponent.pbAbilityCureCheck
        @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::PARALYSIS
        attacker.status=0
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",attacker.pbThis))
      when PBStatuses::SLEEP
        opponent.pbSleep
        @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
        opponent.pbAbilityCureCheck
        @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::SLEEP
        attacker.status=0
        attacker.statusCount=0
        @battle.pbDisplay(_INTL("{1} was woken from its sleep.",attacker.pbThis))
      when PBStatuses::POISON
        opponent.pbPoison(attacker,attacker.statusCount!=0)
        if attacker.statusCount!=0
          @battle.pbDisplay(_INTL("{1} is badly poisoned!",opponent.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} is poisoned!",opponent.pbThis))
        end
        opponent.pbAbilityCureCheck
        @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::POISON
        attacker.status=0
        attacker.statusCount=0
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbThis))
      when PBStatuses::BURN
        opponent.pbBurn(attacker)
        @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
        opponent.pbAbilityCureCheck
        @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::BURN
        attacker.status=0
        @battle.pbDisplay(_INTL("{1} was cured of its burn.",attacker.pbThis))
      when PBStatuses::FROZEN
        opponent.pbFreeze
        @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
        opponent.pbAbilityCureCheck
        @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::FROZEN
        attacker.status=0
        @battle.pbDisplay(_INTL("{1} was defrosted.",attacker.pbThis))
    end
    return 0
  end
end

################################################################################
# Increases the user's Attack by 1 stage. (Howl, Sharpen, Meditate, Meteor Mash, Metal Claw, Power-Up Punch)
################################################################################
class PokeBattle_Move_01C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if (@battle.FE == PBFields::RAINBOWF || @battle.FE == PBFields::ASHENB) &&
       (@id == PBMoves::MEDITATE)  # Rainbow/Ashen Field
      ret=attacker.pbIncreaseStat(PBStats::ATTACK,3,abilitymessage:false)
    elsif @battle.FE == PBFields::PSYCHICT && (@id == PBMoves::MEDITATE)  # Psychic Terrain
      ret=attacker.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
      ret=attacker.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
    else
      ret=attacker.pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,abilitymessage:false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's Defense by 1 stage. (Harden, Steel Wing, Withdraw)
################################################################################
class PokeBattle_Move_01D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,abilitymessage:false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's Defense by 1 stage.  User curls up. (Defense Curl)
################################################################################
class PokeBattle_Move_01E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,true)
     pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
     ret=attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
     attacker.effects[PBEffects::DefenseCurl]=true if ret
    end
    if @battle.FE == PBFields::ICYF # Icy Field  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED)
        attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
        @battle.pbCommonAnimation("StatUp",attacker)
        @battle.pbDisplay(_INTL("{1} gained momentum on the ice!",attacker.pbThis))
      end
    end   
    return ret ? 0 : -1
  end
end

################################################################################
# Increases the user's Speed by 1 stage. (Flame Charge)
################################################################################
class PokeBattle_Move_01F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPEED,1,abilitymessage:false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,abilitymessage:false)
      attacker.pbIncreaseStat(PBStats::SPEED,1,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's Special Attack by 1 stage. (Charge Beam, Fiery Dance)
################################################################################
class PokeBattle_Move_020 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPATK,1,abilitymessage:false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,abilitymessage:false)
      attacker.pbIncreaseStat(PBStats::SPATK,1,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's Special Defense by 1 stage.  Charges up Electric attacks. (Charge)
################################################################################
class PokeBattle_Move_021 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::ELECTRICT # Electric Field
    ret=attacker.pbIncreaseStat(PBStats::SPDEF,2,abilitymessage:false)
    else
    ret=attacker.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
    end
    if ret
      attacker.effects[PBEffects::Charge]=2
      @battle.pbDisplay(_INTL("{1} began charging power!",attacker.pbThis))
    end
    return ret ? 0 : -1
  end
end

################################################################################
# Increases the user's evasion by 1 stage. (Double Team)
################################################################################
class PokeBattle_Move_022 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::EVASION,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::MIRRORA
      ret=attacker.pbIncreaseStat(PBStats::EVASION,2,abilitymessage:false)
    else
      ret=attacker.pbIncreaseStat(PBStats::EVASION,1,abilitymessage:false)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,abilitymessage:false)
      attacker.pbIncreaseStat(PBStats::EVASION,1,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's critical hit rate. (Focus Energy)
################################################################################
class PokeBattle_Move_023 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if attacker.effects[PBEffects::FocusEnergy]>=2
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::FocusEnergy]=2
    attacker.effects[PBEffects::FocusEnergy]=3 if @battle.FE == PBFields::ASHENB
    @battle.pbDisplay(_INTL("{1} is getting pumped!",attacker.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.effects[PBEffects::FocusEnergy]<2
      attacker.effects[PBEffects::FocusEnergy]=2
      @battle.pbDisplay(_INTL("{1} is getting pumped!",attacker.pbThis))
    end
    return true
  end
end

################################################################################
# Increases the user's Attack and Defense by 1 stage each. (Bulk Up)
################################################################################
class PokeBattle_Move_024 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for stat in [PBStats::ATTACK,PBStats::DEFENSE]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,1,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Attack, Defense and accuracy by 1 stage each. (Coil)
################################################################################
class PokeBattle_Move_025 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    boost_amount=1
    if @battle.FE == PBFields::GRASSYT # Grassy Field
      boost_amount=2
    end
    for stat in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::ACCURACY]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,boost_amount,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Attack and Speed by 1 stage each. (Dragon Dance)
################################################################################
class PokeBattle_Move_026 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    boost_amount=1
    if (@battle.FE == PBFields::BIGTOPA || @battle.FE == PBFields::DRAGONSD) && (@id == PBMoves::DRAGONDANCE)
      boost_amount=2
    end
    for stat in [PBStats::ATTACK,PBStats::SPEED]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,boost_amount,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Attack and Special Attack by 1 stage each. (Work Up)
################################################################################
class PokeBattle_Move_027 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for stat in [PBStats::ATTACK,PBStats::SPATK]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,1,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Attack and Sp. Attack by 1 stage each (2 each in sunshine).
# (Growth)
################################################################################
class PokeBattle_Move_028 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    increment=(@battle.weather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA)) ? 2 : 1
    if (@battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FORESTF || @battle.FE == PBFields::FLOWERGARDENF) # Grassy/Forest/Flower Garden Field
      increment = 2
      increment = 3 if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter >= 2
    end
    for stat in [PBStats::ATTACK,PBStats::SPATK]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,increment,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Attack and accuracy by 1 stage each. (Hone Claws)
################################################################################
class PokeBattle_Move_029 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for stat in [PBStats::ATTACK,PBStats::ACCURACY]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,1,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Defense and Special Defense by 1 stage each. (Cosmic Power, Defend Order)
################################################################################
class PokeBattle_Move_02A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    boost_amount=1
    if ((@battle.FE == PBFields::MISTYT || @battle.FE == PBFields::RAINBOWF || @battle.FE == PBFields::HOLYF ||
      @battle.FE == PBFields::STARLIGHTA || @battle.FE == PBFields::NEWW || @battle.FE == PBFields::PSYCHICT) &&
      (@id == PBMoves::COSMICPOWER)) || (@battle.FE == PBFields::FORESTF && (@id == PBMoves::DEFENDORDER))
      boost_amount=2
    end
    for stat in [PBStats::DEFENSE,PBStats::SPDEF]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,boost_amount,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Special Attack, Special Defense and Speed  by 1 stage each. (Quiver Dance)
################################################################################
class PokeBattle_Move_02B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    showanim=true
    boost_amount=1
    if @battle.FE == PBFields::BIGTOPA && (@id == PBMoves::QUIVERDANCE)
      boost_amount=2
    end
    for stat in [PBStats::SPATK,PBStats::SPDEF,PBStats::SPEED]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,boost_amount,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Special Attack and Special Defense by 1 stage each. (Calm Mind)
################################################################################
class PokeBattle_Move_02C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    boost_amount=1
    if @battle.FE == PBFields::CHESSB || @battle.FE == PBFields::ASHENB || @battle.FE == PBFields::PSYCHICT # Chess/Ashen/Psychic Field
      boost_amount=2
    end
    for stat in [PBStats::SPATK,PBStats::SPDEF]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,boost_amount,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 stage each. (Ancient Power, Silver Wind, Ominous Wind)
################################################################################
class PokeBattle_Move_02D < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    for stat in 1..5
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,1)
      end
    end
    return true
  end
end

################################################################################
# Increases the user's Attack by 2 stages. (Swords Dance)
################################################################################
class PokeBattle_Move_02E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if (@battle.FE == PBFields::BIGTOPA || @battle.FE == PBFields::FAIRYTALEF) && (@id == PBMoves::SWORDSDANCE)
      ret=attacker.pbIncreaseStat(PBStats::ATTACK,3,abilitymessage:false)
    else
      ret=attacker.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's Defense by 2 stages. (Iron Defense, Acid Armor, Barrier, Diamond Storm)
################################################################################
class PokeBattle_Move_02F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if ((@battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF || @battle.FE == PBFields::MURKWATERS || @battle.FE == PBFields::FAIRYTALEF) && (@id == PBMoves::ACIDARMOR)) || # Corro Fields
     (@battle.FE == PBFields::FACTORYF && (@id == PBMoves::IRONDEFENSE))
      ret=attacker.pbIncreaseStat(PBStats::DEFENSE,3,abilitymessage:false)
    else
      ret=attacker.pbIncreaseStat(PBStats::DEFENSE,2,abilitymessage:false)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,2,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's Speed by 2 stages. (Agility, Rock Polish)
################################################################################
class PokeBattle_Move_030 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,true) && !(@battle.FE == PBFields::CRYSTALC && (attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,true) || attacker.pbCanIncreaseStatStage?(PBStats::SPATK,true)))
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::ROCKYF && (@id == PBMoves::ROCKPOLISH)  # Rocky Fields
      ret=attacker.pbIncreaseStat(PBStats::SPEED,3,abilitymessage:false)
    elsif @battle.FE == PBFields::CRYSTALC && (@id == PBMoves::ROCKPOLISH)  # Crystal Cavern
      ret=attacker.pbIncreaseStat(PBStats::SPEED,2,abilitymessage:false)
      ret=attacker.pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
      ret=attacker.pbIncreaseStat(PBStats::SPATK,1,abilitymessage:false)
    else
      ret=attacker.pbIncreaseStat(PBStats::SPEED,2,abilitymessage:false)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,2,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's Speed by 2 stages.  Halves the user's weight. (Autotomize)
################################################################################
class PokeBattle_Move_031 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::FACTORYF
     ret=attacker.pbIncreaseStat(PBStats::SPEED,3,abilitymessage:false)
    else
      ret=attacker.pbIncreaseStat(PBStats::SPEED,2,abilitymessage:false)
    end
    if ret
      attacker.effects[PBEffects::WeightMultiplier]/=2
      @battle.pbDisplay(_INTL("{1} became nimble!",attacker.pbThis))
    end
    return ret ? 0 : -1
  end
end

################################################################################
# Increases the user's Special Attack by 2 stages. (Nasty Plot)
################################################################################
class PokeBattle_Move_032 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::CHESSB || @battle.FE == PBFields::PSYCHICT # Chess Field, Psychic Terrain
      ret=attacker.pbIncreaseStat(PBStats::SPATK,3,abilitymessage:false)
    else
      ret=attacker.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's Special Defense by 2 stages. (Amnesia)
################################################################################
class PokeBattle_Move_033 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPDEF,2,abilitymessage:false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,2,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's evasion by 2 stages.  Minimizes the user. (Minimize)
################################################################################
class PokeBattle_Move_034 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::EVASION,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::EVASION,2,abilitymessage:false)
    attacker.effects[PBEffects::Minimize]=true if ret
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
      attacker.pbIncreaseStat(PBStats::EVASION,2,abilitymessage:false)
      attacker.effects[PBEffects::Minimize]=true
    end
    return true
  end
end

################################################################################
# Decreases the user's Defense and Special Defense by 1 stage each.
# Increases the user's Attack, Speed and Special Attack by 2 stages each. (Shell Smash)
################################################################################
class PokeBattle_Move_035 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    for stat in [PBStats::DEFENSE,PBStats::SPDEF]
      if attacker.pbCanReduceStatStage?(stat,false,true)
        attacker.pbReduceStat(stat,1,abilitymessage:false, statdropper: attacker)
      end
    end
    for stat in [PBStats::ATTACK,PBStats::SPATK,PBStats::SPEED]
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,2,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Increases the user's Speed by 2 stages, and its Attack by 1 stage. (Shift Gear)
################################################################################
class PokeBattle_Move_036 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      if @battle.FE == PBFields::FACTORYF
        attacker.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
      else
        attacker.pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
      end
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,2,abilitymessage:false)
      showanim=false
    end
    return 0
  end
end

################################################################################
# Increases one random stat of the user by 2 stages (except HP). (Acupressure)
################################################################################
class PokeBattle_Move_037 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.index!=opponent.index && opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    array=[]
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      array.push(i) if opponent.pbCanIncreaseStatStage?(i)
    end
    if array.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",opponent.pbThis))
      return -1
    end
    stat=array[@battle.pbRandom(array.length)]
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbIncreaseStat(stat,2,abilitymessage:false)
    return 0
  end
end

################################################################################
# Increases the user's Defense by 3 stages. (Cotton Guard)
################################################################################
class PokeBattle_Move_038 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,3,abilitymessage:false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,3,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Increases the user's Special Attack by 3 stages. (Tail Glow)
################################################################################
class PokeBattle_Move_039 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPATK,3,abilitymessage:false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::SPATK,3,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Reduces the user's HP by half of max, and sets its Attack to maximum. (Belly Drum)
################################################################################
class PokeBattle_Move_03A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    showanim=showanimation
    if attacker.hp<=(attacker.totalhp/2.0).floor || !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP((attacker.totalhp/2.0).floor, false, false)
    attacker.stages[PBStats::ATTACK]=6
    @battle.pbCommonAnimation("StatUp",attacker,nil)
    @battle.pbDisplay(_INTL("{1} cut its own HP and maximized its Attack!",attacker.pbThis))
    if @battle.FE == PBFields::BIGTOPA
       if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
        attacker.effects[PBEffects::StockpileDef]+=1
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
        attacker.effects[PBEffects::StockpileSpDef]+=1
      end
    end
    return 0
  end
end

################################################################################
# Decreases the user's Attack and Defense by 1 stage each. (Superpower)
################################################################################
class PokeBattle_Move_03B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      for stat in [PBStats::ATTACK,PBStats::DEFENSE]
        if attacker.pbCanReduceStatStage?(stat,false,true)
          attacker.pbReduceStat(stat,1,abilitymessage:false, statdropper: attacker)
        end
      end
    end
    return ret
  end
end

################################################################################
# Decreases the user's Defense and Special Defense by 1 stage each. (Close Combat, Dragon Ascent)
################################################################################
class PokeBattle_Move_03C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      for stat in [PBStats::DEFENSE,PBStats::SPDEF]
        if attacker.pbCanReduceStatStage?(stat,false,true)
          attacker.pbReduceStat(stat,1,abilitymessage:false, statdropper: attacker)
        end
      end
    end
    return ret
  end
end

################################################################################
# Decreases the user's Defense, Special Defense and Speed by 1 stage each. (V-Create)
################################################################################
class PokeBattle_Move_03D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      for stat in [PBStats::SPDEF,PBStats::DEFENSE,PBStats::SPEED]
        if attacker.pbCanReduceStatStage?(stat,false,true)
          attacker.pbReduceStat(stat,1,abilitymessage:false, statdropper: attacker)
        end
      end
    end
    return ret
  end
end

################################################################################
# Decreases the user's Speed by 1 stage. (Hammer Arm, Ice Hammer)
################################################################################
class PokeBattle_Move_03E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.pbCanReduceStatStage?(PBStats::SPEED,false,true)
        attacker.pbReduceStat(PBStats::SPEED,1,abilitymessage:false, statdropper: attacker)
      end
    end
    return ret
  end
end

################################################################################
# Decreases the user's Special Attack by 2 stages. (Overheat, Draco Meteor, Leaf Storm, Psycho Boost, Flear Cannon)
################################################################################
class PokeBattle_Move_03F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.pbCanReduceStatStage?(PBStats::SPATK,false,true)
        attacker.pbReduceStat(PBStats::SPATK,2,abilitymessage:false, statdropper: attacker)
      end
    end
    return ret
  end
end

################################################################################
# Increases the target's Special Attack by 1 stage.  Confuses the target. (Flatter)
################################################################################
class PokeBattle_Move_040 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    ret=-1
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.pbCanIncreaseStatStage?(PBStats::SPATK)
      opponent.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
      ret=0
    end
    if opponent.pbCanConfuse?(true)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      ret=0
    end
    return ret
  end
end

################################################################################
# Increases the target's Attack by 2 stages.  Confuses the target. (Swagger)
################################################################################
class PokeBattle_Move_041 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    ret=-1
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK)
      opponent.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
      ret=0
    end
    if opponent.pbCanConfuse?(true)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      ret=0
    end
    return ret
  end
end

################################################################################
# Decreases the target's Attack by 1 stage. (Growl, Aurora Beam, Baby-Doll Eyes, Play Nice, Play Rough, Lunge, Trop Kick, Breaking Swipe)
################################################################################
class PokeBattle_Move_042 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ATTACK,1,abilitymessage:false, statdropper: attacker)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,false)
      opponent.pbReduceStat(PBStats::ATTACK,1,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's Defense by 1 stage. (Tail Whip, Crunch, Rock Smash, Crush Claw, Leer, Iron Tail, Razor Shell, Fire Lash, Liquidation, Shadow Bone)
################################################################################
class PokeBattle_Move_043 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false, statdropper: attacker)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,false)
      opponent.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's Speed by 1 stage. (Rock Tomb, Electroweb, Low Sweep, Bulldoze, Mud Shot, Glaciate, Icy Wind, Constrict, Bubble Beam, Bubble)
################################################################################
class PokeBattle_Move_044 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPEED,1,abilitymessage:false, statdropper: attacker)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,false)
      opponent.pbReduceStat(PBStats::SPEED,1,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's Special Attack by 1 stage. (Snarl / Confide / Moonblast /
# Mystical Fire / Struggle Bug / Mist Ball)
################################################################################
class PokeBattle_Move_045 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if (@id == PBMoves::CONFIDE) && @battle.FE == PBFields::PSYCHICT
      @battle.pbDisplay(_INTL("Psst... This field is pretty weird, huh?"))
    end
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,1,abilitymessage:false, statdropper: attacker)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,false)
      opponent.pbReduceStat(PBStats::SPATK,1,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's Special Defense by 1 stage. (Bug Buzz / Focus Blast /
# Shadow Ball / Energy Ball / Earth Power / Acid / Psychic / Luster Purge / Flash Cannon)
################################################################################
class PokeBattle_Move_046 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPDEF,1,abilitymessage:false, statdropper: attacker)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPDEF,false)
      opponent.pbReduceStat(PBStats::SPDEF,1,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's accuracy by 1 stage. (Sand Attack, Night Daze, Leaf Tornado, Mod Bomb, Mud-Slap, Flash, Smokescreen, Kinesis, Mirror Shot, Muddy Water, Octazooka)
################################################################################
class PokeBattle_Move_047 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if ((@battle.FE == PBFields::BURNINGF || @battle.FE == PBFields::CORROSIVEMISTF) && (@id == PBMoves::SMOKESCREEN)) ||
       ((@battle.FE == PBFields::DESERTF || @battle.FE == PBFields::ASHENB) && (@id == PBMoves::SANDATTACK)) ||
       ((@battle.FE == PBFields::SHORTCIRCUITF || @battle.FE == PBFields::DARKCRYSTALC || @battle.FE == PBFields::MIRRORA || @battle.FE == PBFields::STARLIGHTA || @battle.FE == PBFields::NEWW) && (@id == PBMoves::FLASH)) ||
       (@battle.FE == PBFields::ASHENB && (@id == PBMoves::KINESIS))
      ret=opponent.pbReduceStat(PBStats::ACCURACY,2,abilitymessage:false, statdropper: attacker)
    elsif @battle.FE == PBFields::PSYCHICT && (@id == PBMoves::KINESIS)
      opponent.pbReduceStat(PBStats::ACCURACY,2,abilitymessage:false, statdropper: attacker)
      attacker.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false) if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false) if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      return 0
    else
      ret=opponent.pbReduceStat(PBStats::ACCURACY,1,abilitymessage:false, statdropper: attacker)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if @battle.FE == PBFields::WASTELAND && (@id == PBMoves::OCTAZOOKA) && 
      ((!opponent.pbHasType?(:POISON) && !opponent.pbHasType?(:STEEL)) || opponent.corroded) &&
      opponent.ability != PBAbilities::TOXICBOOST && opponent.ability != PBAbilities::POISONHEAL &&
      (opponent.ability != PBAbilities::IMMUNITY && !(opponent.moldbroken))
      rnd=@battle.pbRandom(5)
      case rnd
        when 0
          return false if !opponent.pbCanBurn?(false)
          opponent.pbBurn(attacker)
          @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
        when 1
          return false if !opponent.pbCanFreeze?(false)
          opponent.pbFreeze
          @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
        when 2
          return false if !opponent.pbCanParalyze?(false)
          opponent.pbParalyze(attacker)
          @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
        when 3
          return false if !opponent.pbCanPoison?(false)
          opponent.pbPoison(attacker)
          @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
        when 4
          if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,false)
            opponent.pbReduceStat(PBStats::ACCURACY,1,abilitymessage:false, statdropper: attacker)
          end
      end
    else
      if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,false)
        opponent.pbReduceStat(PBStats::ACCURACY,1,abilitymessage:false, statdropper: attacker)
      end
    end
    return true
  end
end

################################################################################
# Decreases the target's evasion by 1 stage. (Sweet Scent)
################################################################################
class PokeBattle_Move_048 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::EVASION,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::FLOWERGARDENF
      case @battle.field.counter
        when 2
          for stat in [PBStats::EVASION,PBStats::DEFENSE,PBStats::SPDEF]
            ret = opponent.pbReduceStat(stat,1,abilitymessage:false, statdropper: attacker)
          end
        when 3
          for stat in [PBStats::EVASION,PBStats::DEFENSE,PBStats::SPDEF]
            ret = opponent.pbReduceStat(stat,2,abilitymessage:false, statdropper: attacker)
          end
        when 4
          for stat in [PBStats::EVASION,PBStats::DEFENSE,PBStats::SPDEF]
            ret = opponent.pbReduceStat(stat,3,abilitymessage:false, statdropper: attacker)
          end
      end
    elsif @battle.FE == PBFields::MISTYT
      for stat in [PBStats::EVASION,PBStats::DEFENSE,PBStats::SPDEF]
        ret = opponent.pbReduceStat(stat,1,abilitymessage:false, statdropper: attacker)
      end
    else
      ret=opponent.pbReduceStat(PBStats::EVASION,1,abilitymessage:false, statdropper: attacker)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::EVASION,false)
      opponent.pbReduceStat(PBStats::EVASION,1,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's evasion by 1 stage. Ends all barriers and entry
# hazards for the target's side. (Defog)
################################################################################
class PokeBattle_Move_049 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::EVASION,1,abilitymessage:false, statdropper: attacker)
     ####
    if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
      attacker.pbOpposingSide.effects[PBEffects::Reflect]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Reflect wore off!"))
      else
          @battle.pbDisplay(_INTL("Your team's Reflect wore off!"))
      end
    end
    if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
      attacker.pbOpposingSide.effects[PBEffects::LightScreen]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Light Screen wore off!"))
      else
        @battle.pbDisplay(_INTL("Your team's Light Screen wore off!"))
      end
    end
    if attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Aurora Veil wore off!"))
      else
        @battle.pbDisplay(_INTL("Your team's Aurora Veil wore off!"))
      end
    end
    if attacker.pbOpposingSide.effects[PBEffects::Mist]>0 || opponent.pbOwnSide.effects[PBEffects::Mist]>0
      opponent.pbOwnSide.effects[PBEffects::Mist]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team is no longer protected by Mist."))
      else
        @battle.pbDisplay(_INTL("Your team is no longer protected by Mist."))
      end
    end
    if attacker.pbOpposingSide.effects[PBEffects::Safeguard]>0 || opponent.pbOwnSide.effects[PBEffects::Safeguard]>0
      opponent.pbOwnSide.effects[PBEffects::Safeguard]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team is no longer protected by Safeguard."))
      else
        @battle.pbDisplay(_INTL("Your team is no longer protected by Safeguard."))
      end
    end
    if attacker.pbOwnSide.effects[PBEffects::Spikes]>0 || opponent.pbOwnSide.effects[PBEffects::Spikes]>0
      attacker.pbOwnSide.effects[PBEffects::Spikes]=0
      opponent.pbOwnSide.effects[PBEffects::Spikes]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The spikes disappeared from around your opponent's team's feet!"))
      else
        @battle.pbDisplay(_INTL("The spikes disappeared from around your team's feet!"))
      end
    end
    if attacker.pbOwnSide.effects[PBEffects::StealthRock] || opponent.pbOwnSide.effects[PBEffects::StealthRock]
      attacker.pbOwnSide.effects[PBEffects::StealthRock]=false
      opponent.pbOwnSide.effects[PBEffects::StealthRock]=false
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The pointed stones disappeared from around your opponent's team!"))
      else
        @battle.pbDisplay(_INTL("The pointed stones disappeared from around your team!"))
      end
    end
    if attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 || opponent.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
      attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
      opponent.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The poison spikes disappeared from around your opponent's team's feet!"))
      else
        @battle.pbDisplay(_INTL("The poison spikes disappeared from around your team's feet!"))
      end
    end
    if attacker.pbOwnSide.effects[PBEffects::StickyWeb] || opponent.pbOwnSide.effects[PBEffects::StickyWeb]
      attacker.pbOwnSide.effects[PBEffects::StickyWeb]=false
      opponent.pbOwnSide.effects[PBEffects::StickyWeb]=false
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The sticky web has disappeared from beneath your opponent's team's feet!"))
      else
        @battle.pbDisplay(_INTL("The sticky web has disappeared from beneath your team's feet!"))
      end
    end
   ####
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::EVASION,false)
      opponent.pbReduceStat(PBStats::EVASION,1,abilitymessage:false, statdropper: attacker)
    end
    opponent.pbOwnSide.effects[PBEffects::Reflect] = 0
    opponent.pbOwnSide.effects[PBEffects::LightScreen] = 0
    opponent.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
    opponent.pbOwnSide.effects[PBEffects::Mist] = 0
    opponent.pbOwnSide.effects[PBEffects::Safeguard] = 0
    opponent.pbOwnSide.effects[PBEffects::Spikes] = 0
    opponent.pbOwnSide.effects[PBEffects::StealthRock] = false
    opponent.pbOwnSide.effects[PBEffects::Toxic] = 0
    opponent.pbOwnSide.effects[PBEffects::StickyWeb] = false
    return true
  end
end

################################################################################
# Decreases the target's Attack and Defense by 1 stage each. (Tickle)
################################################################################
class PokeBattle_Move_04A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    if opponent.pbTooLow?(PBStats::ATTACK) &&
       opponent.pbTooLow?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      return -1
    end
    if ((opponent.ability == PBAbilities::CLEARBODY ||
       opponent.ability == PBAbilities::WHITESMOKE) && !(opponent.moldbroken)) || opponent.ability == PBAbilities::FULLMETALBODY
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim=true
    if opponent.pbReduceStat(PBStats::ATTACK,1,abilitymessage:false, statdropper: attacker)
      ret=0; showanim=false
    end
    if opponent.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false, statdropper: attacker)
      ret=0; showanim=false
    end
    return ret
  end
end

################################################################################
# Decreases the target's Attack by 2 stages. (Charm / Feather Dance)
################################################################################
class PokeBattle_Move_04B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::BIGTOPA && (@id == PBMoves::FEATHERDANCE)
      ret=opponent.pbReduceStat(PBStats::ATTACK,3,abilitymessage:false, statdropper: attacker)
    else
      ret=opponent.pbReduceStat(PBStats::ATTACK,2,abilitymessage:false, statdropper: attacker)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,false)
      opponent.pbReduceStat(PBStats::ATTACK,2,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's Defense by 2 stages. (Screech)
################################################################################
class PokeBattle_Move_04C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::DEFENSE,2,abilitymessage:false, statdropper: attacker)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,false)
      opponent.pbReduceStat(PBStats::DEFENSE,2,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's Speed by 2 stages. (String Shot / Cotton Spore / Scary Face)
################################################################################
class PokeBattle_Move_04D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,true)
    if (@id == PBMoves::COTTONSPORE)
      if opponent.pbHasType?(:GRASS)
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
        return -1
      elsif (opponent.ability == PBAbilities::OVERCOAT) && !(opponent.moldbroken)
        @battle.pbDisplay(_INTL("{1}'s {2} made the attack ineffective!",
        opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
        return -1
      elsif (opponent.item == PBItems::SAFETYGOGGLES)
        @battle.pbDisplay(_INTL("{1} avoided the move with its {2}!",
        opponent.pbThis,PBItems.getName(opponent.item),self.name))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPEED,2,abilitymessage:false, statdropper: attacker)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,false)
      opponent.pbReduceStat(PBStats::SPEED,2,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's Special Attack by 2 stages.  Only works on the opposite
# gender. (Captivate)
################################################################################
class PokeBattle_Move_04E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,true)
    if attacker.gender==2 || opponent.gender==2 ||
       attacker.gender==opponent.gender
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.ability == PBAbilities::OBLIVIOUS && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,2,abilitymessage:false, statdropper: attacker)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if attacker.gender==2 || opponent.gender==2 ||
                    attacker.gender==opponent.gender
    return false if opponent.ability == PBAbilities::OBLIVIOUS && !(opponent.moldbroken)
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,false)
      opponent.pbReduceStat(PBStats::SPATK,2,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Decreases the target's Special Defense by 2 stages. (Fake Tears / Seed Flare 
# Acid Spray / Metal Sound)
################################################################################
class PokeBattle_Move_04F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if (@id == PBMoves::METALSOUND) && (@battle.FE == PBFields::FACTORYF || @battle.FE == PBFields::SHORTCIRCUITF)
      ret=opponent.pbReduceStat(PBStats::SPDEF,3,abilitymessage:false, statdropper: attacker)
    else
      ret=opponent.pbReduceStat(PBStats::SPDEF,2,abilitymessage:false, statdropper: attacker)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPDEF,false)
      opponent.pbReduceStat(PBStats::SPDEF,2,abilitymessage:false, statdropper: attacker)
    end
    return true
  end
end

################################################################################
# Resets all target's stat stages to 0. (Clear Smog)
################################################################################
class PokeBattle_Move_050 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      opponent.stages[PBStats::ATTACK]   = 0
      opponent.stages[PBStats::DEFENSE]  = 0
      opponent.stages[PBStats::SPEED]    = 0
      opponent.stages[PBStats::SPATK]    = 0
      opponent.stages[PBStats::SPDEF]    = 0
      opponent.stages[PBStats::ACCURACY] = 0
      opponent.stages[PBStats::EVASION]  = 0
      @battle.pbDisplay(_INTL("{1}'s stat changes were removed!",opponent.pbThis))
    end
    return ret
  end
end

################################################################################
# Resets all stat stages for all battlers to 0. (Haze)
################################################################################
class PokeBattle_Move_051 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    for i in 0...4
      @battle.battlers[i].stages[PBStats::ATTACK]   = 0
      @battle.battlers[i].stages[PBStats::DEFENSE]  = 0
      @battle.battlers[i].stages[PBStats::SPEED]    = 0
      @battle.battlers[i].stages[PBStats::SPATK]    = 0
      @battle.battlers[i].stages[PBStats::SPDEF]    = 0
      @battle.battlers[i].stages[PBStats::ACCURACY] = 0
      @battle.battlers[i].stages[PBStats::EVASION]  = 0
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("All stat changes were eliminated!"))
    return 0
  end
end

################################################################################
# User and target swap their Attack and Special Attack stat stages. (Power Swap)
################################################################################
class PokeBattle_Move_052 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    astage=attacker.stages
    ostage=opponent.stages
    astage[PBStats::ATTACK],ostage[PBStats::ATTACK]=ostage[PBStats::ATTACK],astage[PBStats::ATTACK]
    astage[PBStats::SPATK],ostage[PBStats::SPATK]=ostage[PBStats::SPATK],astage[PBStats::SPATK]
    @battle.pbDisplay(_INTL("{1} switched all changes to its Attack and Sp. Atk with the target!",attacker.pbThis))
    return 0
  end
end

################################################################################
# User and target swap their Defense and Special Defense stat stages. (Guard Swap)
################################################################################
class PokeBattle_Move_053 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    astage=attacker.stages
    ostage=opponent.stages
    astage[PBStats::DEFENSE],ostage[PBStats::DEFENSE]=ostage[PBStats::DEFENSE],astage[PBStats::DEFENSE]
    astage[PBStats::SPDEF],ostage[PBStats::SPDEF]=ostage[PBStats::SPDEF],astage[PBStats::SPDEF]
    @battle.pbDisplay(_INTL("{1} switched all changes to its Defense and Sp. Def with the target!",attacker.pbThis))
    return 0
  end
end

################################################################################
# User and target swap all their stat stages. (Heart Swap)
################################################################################
class PokeBattle_Move_054 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      attacker.stages[i],opponent.stages[i]=opponent.stages[i],attacker.stages[i]
    end
    @battle.pbDisplay(_INTL("{1} switched stat changes with the target!",attacker.pbThis))

    if @battle.FE == PBFields::NEWW
      if opponent.effects[PBEffects::Substitute]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      olda=attacker.hp
      oldo=opponent.hp
      avhp=((attacker.hp+opponent.hp)/2.0).floor
      attacker.hp=[avhp,attacker.totalhp].min
      opponent.hp=[avhp,opponent.totalhp].min
      @battle.scene.pbHPChanged(attacker,olda)
      @battle.scene.pbHPChanged(opponent,oldo)
      @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    end
    return 0
  end
end

################################################################################
# User copies the target's stat stages. (Psych Up)
################################################################################
class PokeBattle_Move_055 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      attacker.stages[i]=opponent.stages[i]
    end
    @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!",attacker.pbThis,opponent.pbThis(true)))
    if @battle.FE == PBFields::ASHENB
      t=attacker.status
      attacker.status=0
      attacker.statusCount=0
      if t==PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} was cured of its burn.",attacker.pbThis))
      elsif t==PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbThis))
      elsif t==PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",attacker.pbThis))
      end
    end
    if @battle.FE == PBFields::PSYCHICT
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# For 5 rounds, user's and ally's stat stages cannot be lowered by foes. (Mist)
################################################################################
class PokeBattle_Move_056 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Mist]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team became shrouded in mist!"))
    else
      @battle.pbDisplay(_INTL("The foe's team became shrouded in mist!"))
    end

    if !(attacker.item == PBItems::EVERSTONE) && @battle.canChangeFE?(PBFields::MISTYT)
      @battle.setField(PBFields::MISTYT,true)
      @battle.field.duration=3
      @battle.field.duration=6 if (attacker.item == PBItems::AMPLIFIELDROCK)
      @battle.pbDisplay(_INTL("The terrain became misty!"))
    end
    return 0
  end
end

################################################################################
# Swaps the user's Attack and Defense. (Power Trick)
################################################################################
class PokeBattle_Move_057 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.attack, attacker.defense = attacker.defense, attacker.attack
    attacker.effects[PBEffects::PowerTrick]=!attacker.effects[PBEffects::PowerTrick]
    @battle.pbDisplay(_INTL("{1} switched its Attack and Defense!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Averages the user's and target's Attack and Special Attack (separately). (Power Split)
################################################################################
class PokeBattle_Move_058 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    avatk=((attacker.attack+opponent.attack)/2.0).floor
    avspatk=((attacker.spatk+opponent.spatk)/2.0).floor
    attacker.attack=avatk
    opponent.attack=avatk
    attacker.spatk=avspatk
    opponent.spatk=avspatk
    @battle.pbDisplay(_INTL("{1} shared its power with the target!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Averages the user's and target's Defense and Special Defense (separately). (Guard Split)
################################################################################
class PokeBattle_Move_059 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    avdef=((attacker.defense+opponent.defense)/2.0).floor
    avspdef=((attacker.spdef+opponent.spdef)/2.0).floor
    attacker.defense=avdef
    opponent.defense=avdef
    attacker.spdef=avspdef
    opponent.spdef=avspdef
    @battle.pbDisplay(_INTL("{1} shared its guard with the target!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Averages the user's and target's current HP. (Pain Split)
################################################################################
class PokeBattle_Move_05A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    olda=attacker.hp
    oldo=opponent.hp
    avhp=((attacker.hp+opponent.hp)/2.0).floor
    attacker.hp=[avhp,attacker.totalhp].min
    opponent.hp=[avhp,opponent.totalhp].min
    @battle.scene.pbHPChanged(attacker,olda)
    @battle.scene.pbHPChanged(opponent,oldo)
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    return 0
  end
end

################################################################################
# For 4 more rounds, doubles the Speed of all battlers on the user's side. (Tailwind)
################################################################################
class PokeBattle_Move_05B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Tailwind]=4
    attacker.pbOwnSide.effects[PBEffects::Tailwind]=6 if (@battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("The tailwind blew from behind your team!"))
    else
      @battle.pbDisplay(_INTL("The tailwind blew from behind the opposing team!"))
    end
    if (@battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM) && !@battle.state.effects[PBEffects::HeavyRain] && !@battle.state.effects[PBEffects::HarshSunlight]
      @battle.weather=PBWeather::STRONGWINDS
      @battle.weatherduration=6
      @battle.pbCommonAnimation("Wind",nil,nil)
      @battle.pbDisplay(_INTL("Strong winds kicked up around the field!"))
    end
    return 0
  end
end

################################################################################
# This move turns into the last move used by the target, until user switches out. (Mimic)
################################################################################
class PokeBattle_Move_05C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,   # Struggle
       0x14,   # Chatter
       0x69,   # Transform
       0x5C,   # Mimic
       0x5D,   # Sketch
       0xB6    # Metronome
    ]
    if attacker.effects[PBEffects::Transform] ||
       opponent.lastMoveUsed<=0 ||
       blacklist.include?(PBMoveData.new(opponent.lastMoveUsed).function)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in attacker.moves
      if i.id==opponent.lastMoveUsed
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...attacker.moves.length
      if attacker.moves[i].id==@id
        newmove=PBMove.new(opponent.lastMoveUsed)
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,newmove,attacker)
        movename=PBMoves.getName(opponent.lastMoveUsed)
        @battle.pbDisplay(_INTL("{1} learned {2}!",attacker.pbThis,movename))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end

################################################################################
# This move permanently turns into the last move used by the target. (Sketch)
################################################################################
class PokeBattle_Move_05D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,   # Struggle
       0x5D    # Sketch
    ]
    if attacker.effects[PBEffects::Transform] ||
       opponent.lastMoveUsedSketch<=0 ||
       blacklist.include?(PBMoveData.new(opponent.lastMoveUsedSketch).function)
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
    end
    newmove=PBMove.new(opponent.lastMoveUsedSketch) #has to come after confirming there was a last sketched move
    if newmove.id == 161 # Chatter #must be separate due to switching from function code
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in attacker.moves
      if i.id==opponent.lastMoveUsedSketch
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...attacker.moves.length
      if attacker.moves[i].id==@id
        #newmove=PBMove.new(opponent.lastMoveUsedSketch)
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,newmove,attacker)
        party=@battle.pbParty(attacker.index)
        party[attacker.pokemonIndex].moves[i]=newmove
        movename=PBMoves.getName(opponent.lastMoveUsedSketch)
        @battle.pbDisplay(_INTL("{1} sketched {2}!",attacker.pbThis,movename))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end

################################################################################
# Changes user's type to that of a random move of the user, ignoring this one. (Conversion)
################################################################################
class PokeBattle_Move_05E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (attacker.ability == PBAbilities::MULTITYPE) || (attacker.ability == PBAbilities::RKSSYSTEM)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types=[]
    for i in attacker.moves
      next if i.id==@id
      next if PBTypes.isPseudoType?(i.type)
      found=false
      types.push(i.type) if !types.include?(i.type)
    end
    newtype=types[0]
    if attacker.pbHasType?(newtype)
      #@battle.pbDisplay(_INTL("But it failed!"))
      @battle.pbDisplay(_INTL("But {1} is already {2} type!",attacker.pbThis(true),PBTypes.getName(newtype)))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.type1=newtype
    attacker.type2=newtype
    typename=PBTypes.getName(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
    if !(attacker.item == PBItems::EVERSTONE) && @battle.canChangeFE?
      if @battle.field.conversion == 2  # Conversion 2
        @battle.setField(PBFields::GLITCHF,true)
        @battle.field.duration=5
        @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
        @battle.pbDisplay(_INTL("TH~ R0GUE DAa/ta cor$upt?@####"))
      else
        # Conversion lingering
        @battle.field.conversion = 1 # Conversion
        @battle.pbDisplay(_INTL("Some rogue data remains..."))
      end
    end
    return 0
  end
end

################################################################################
# Changes user's type to a random one that resists the last attack used by target. (Conversion2)
################################################################################
class PokeBattle_Move_05F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
   if attacker.ability == PBAbilities::MULTITYPE || attacker.ability == PBAbilities::RKSSYSTEM
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.lastMoveUsed<=0 || PBTypes.isPseudoType?(PBMoveData.new(opponent.lastMoveUsed).type)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    atype=-1
    for i in opponent.moves
      if i.id==opponent.lastMoveUsed
        atype=i.pbType(attacker)
        break
      end
    end
    if atype<0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types = PBTypes.getTypesThatResist(atype)
    types.delete_if {|type| type == attacker.type1 && type == attacker.type2}
    if types.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    newtype=types[@battle.pbRandom(types.length)]
    attacker.type1=newtype
    attacker.type2=newtype
    typename=PBTypes.getName(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
    if !(attacker.item == PBItems::EVERSTONE) && @battle.canChangeFE?
      if @battle.field.conversion == 1  # Conversion
        @battle.setField(PBFields::GLITCHF,true)
        @battle.field.duration=5
        @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
        @battle.pbDisplay(_INTL("TH~ R0GUE DAa/ta cor$upt?@####"))
      else
        # Conversion lingering
        @battle.field.conversion = 2 # Conversion 2
        @battle.pbDisplay(_INTL("Some rogue data remains..."))
      end
    end
    return 0
  end
end

################################################################################
# Changes user's type depending on the environment. (Camouflage)
################################################################################
class PokeBattle_Move_060 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
   if attacker.ability == PBAbilities::MULTITYPE ||
     attacker.ability == PBAbilities::RKSSYSTEM
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    type = 0
    case @battle.FE
      when 25
        type = @battle.field.getRoll
      when 35
        rnd=@battle.pbRandom(18)
        type = rnd
        type = 18 if rnd == 9
      else
        type = @battle.field.mimicry if @battle.field.mimicry
    end
    if type==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.pbHasType?(type)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    newtype=type
    attacker.type1=newtype
    attacker.type2=newtype
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,PBTypes.getName(newtype)))
    return 0
  end
end

################################################################################
# Target becomes Water type. (Soak)
################################################################################
class PokeBattle_Move_061 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (opponent.ability == PBAbilities::MULTITYPE) ||
      (opponent.ability == PBAbilities::RKSSYSTEM)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.type1=(PBTypes::WATER)
    opponent.type2=(PBTypes::WATER)
    typename=PBTypes.getName((PBTypes::WATER))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# User copies target's types. (Reflect Type)
################################################################################
class PokeBattle_Move_062 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (attacker.ability == PBAbilities::MULTITYPE) ||
      (attacker.ability == PBAbilities::RKSSYSTEM)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.pbHasType?(opponent.type1) &&
       attacker.pbHasType?(opponent.type2) &&
       opponent.pbHasType?(attacker.type1) &&
       opponent.pbHasType?(attacker.type2)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.type1=opponent.type1
    attacker.type2=opponent.type2
    @battle.pbDisplay(_INTL("{1}'s type changed to match {2}'s!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end

################################################################################
# Target's ability becomes Simple. (Simple Beam)
################################################################################
class PokeBattle_Move_063 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (PBStuff::FIXEDABILITIES).include?(opponent.ability)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.ability=PBAbilities::SIMPLE || 0
    abilityname=PBAbilities.getName(PBAbilities::SIMPLE)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    
    if opponent.effects[PBEffects::Illusion]!=nil 
      # Animation should go here
      # Break the illusion
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s Illusion was broken!",opponent.pbThis))
    end 
    return 0
  end
end

################################################################################
# Target's ability becomes Insomnia. (Worry Seed)
################################################################################
class PokeBattle_Move_064 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (PBStuff::FIXEDABILITIES).include?(opponent.ability)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.ability=PBAbilities::INSOMNIA || 0
    abilityname=PBAbilities.getName(PBAbilities::INSOMNIA)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    
    if opponent.effects[PBEffects::Illusion]!=nil 
      # Animation should go here
      # Break the illusion
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} was broken!",opponent.pbThis,
      PBAbilities.getName(opponent.ability)))
    end 
    
    return 0
  end
end

################################################################################
# User copies target's ability. (Role Play)
################################################################################
class PokeBattle_Move_065 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.ability==0 || attacker.ability==opponent.ability ||
       (PBStuff::ABILITYBLACKLIST).include?(opponent.ability) ||
       (PBStuff::FIXEDABILITIES).include?(attacker.ability)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.ability=opponent.ability
    abilityname=PBAbilities.getName(opponent.ability)
    @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),abilityname))
    return 0
  end
end

################################################################################
# Target copies user's ability. (Entrainment)
################################################################################
class PokeBattle_Move_066 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.ability==0 || attacker.ability==opponent.ability ||
        (PBStuff::FIXEDABILITIES).include?(opponent.ability) ||
        opponent.ability == PBAbilities::TRUANT
        ((PBStuff::ABILITYBLACKLIST).include?(attacker.ability) && attacker.ability != PBAbilities::WONDERGUARD)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.ability=attacker.ability
    abilityname=PBAbilities.getName(attacker.ability)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    return 0
  end
end

################################################################################
# User and target swap abilities. (Skill Swap)
################################################################################
class PokeBattle_Move_067 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (attacker.ability==0 && opponent.ability==0) ||
       (PBStuff::FIXEDABILITIES - [PBAbilities::ZENMODE] + [PBAbilities::ILLUSION] + [PBAbilities::WONDERGUARD]).include?(attacker.ability) ||
       (PBStuff::FIXEDABILITIES - [PBAbilities::ZENMODE] + [PBAbilities::ILLUSION] + [PBAbilities::WONDERGUARD]).include?(opponent.ability)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.backupability, opponent.backupability = opponent.backupability, attacker.backupability
    attacker.ability = attacker.backupability if attacker.abilityWorks?
    opponent.ability = opponent.backupability if opponent.abilityWorks?

    @battle.pbDisplay(_INTL("{1} swapped its {2} ability with its target's {3} ability!",
       attacker.pbThis,PBAbilities.getName(opponent.backupability),
       PBAbilities.getName(attacker.backupability)))
    attacker.pbAbilitiesOnSwitchIn(true)
    opponent.pbAbilitiesOnSwitchIn(true)
    return 0
  end
end

################################################################################
# Target's ability is negated. (Gastro Acid)
################################################################################
class PokeBattle_Move_068 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (PBStuff::FIXEDABILITIES).include?(opponent.ability) || opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.ability = 0  #Cancel out ability
    opponent.effects[PBEffects::GastroAcid]=true
    opponent.effects[PBEffects::Truant]=false
    @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",opponent.pbThis))
    
    if opponent.effects[PBEffects::Illusion]!=nil 
      # Animation should go here
      # Break the illusion
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} was broken!",opponent.pbThis,
      PBAbilities.getName(opponent.ability)))
    end 
    
    return 0
  end
end

################################################################################
# User transforms into the target. (Transform)
################################################################################
class PokeBattle_Move_069 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Substitute]>0 ||
       PBStuff::TWOTURNMOVE.include?(opponent.effects[PBEffects::TwoTurnAttack]) ||
       opponent.effects[PBEffects::Illusion]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.scene.pbChangePokemon(attacker,opponent.pokemon)
    attackername = attacker.pbThis    #Saves the name pre-transformation for the message
    attacker.effects[PBEffects::Transform]=true
    attacker.species=opponent.species
    attacker.type1=opponent.type1
    attacker.type2=opponent.type2
    attacker.ability=opponent.ability
    attacker.attack=opponent.attack
    attacker.defense=opponent.defense
    attacker.speed=opponent.speed
    attacker.spatk=opponent.spatk
    attacker.spdef=opponent.spdef
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
      attacker.stages[i]=opponent.stages[i]
    end
    for i in 0...4
      attacker.moves[i]=PokeBattle_Move.pbFromPBMove(
         @battle,PBMove.new(opponent.moves[i].id),attacker)
      attacker.moves[i].pp=5
      attacker.moves[i].totalpp=5
    end
    attacker.moves.each {|copiedmove| @battle.ai.addMoveToMemory(attacker,copiedmove)} if !@battle.isOnline?
    opponent.moves.each {|moveloop| @battle.ai.addMoveToMemory(opponent,moveloop) } if !@battle.isOnline?
    attacker.effects[PBEffects::Disable]=0
    attacker.effects[PBEffects::DisableMove]=0
    @battle.pbDisplay(_INTL("{1} transformed into {2}!",attackername,opponent.pbThis(true)))
    attacker.pbAbilitiesOnSwitchIn(true)
    return 0
  end
end

################################################################################
# Inflicts a fixed 20HP damage. (Sonic Boom)
################################################################################
class PokeBattle_Move_06A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.FE == PBFields::RAINBOWF # Rainbow Field
      @battle.pbDisplay(_INTL("It's a Sonic Rainboom!"))
      return pbEffectFixedDamage(140,attacker,opponent,hitnum,alltargets,showanimation)
    else
      return pbEffectFixedDamage(20,attacker,opponent,hitnum,alltargets,showanimation)
    end
  end
end

################################################################################
# Inflicts a fixed 40HP damage. (Dragon Rage)
################################################################################
class PokeBattle_Move_06B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage(40,attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Halves the target's current HP. (Super Fang / Nature Madness)
################################################################################
class PokeBattle_Move_06C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (@id == PBMoves::NATURESMADNESS) && (@battle.FE == PBFields::GRASSYT || #Grassy terrain
      @battle.FE == PBFields::FORESTF || @battle.FE == PBFields::NEWW) # Forest Field, New World
      hploss = (opponent.hp*0.75).floor
    elsif (@id == PBMoves::NATURESMADNESS) && @battle.FE == PBFields::HOLYF # Holy Field
      hploss = (opponent.hp*0.66).floor
    else
      hploss = (opponent.hp/2.0).floor
    end
    return pbEffectFixedDamage(hploss,attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Inflicts damage equal to the user's level. (Seismic Toss / Night Shade)
################################################################################
class PokeBattle_Move_06D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage(attacker.level,attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Inflicts damage to bring the target's HP down to equal the user's HP. (Endeavor)
################################################################################
class PokeBattle_Move_06E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp>=opponent.hp
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return pbEffectFixedDamage(opponent.hp-attacker.hp,attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Inflicts damage between 0.5 and 1.5 times the user's level. (Psywave)
################################################################################
class PokeBattle_Move_06F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    dmg = (attacker.level * (@battle.pbRandom(101) + 50)/100.0).floor
    return pbEffectFixedDamage(dmg,attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# OHKO.  Accuracy increases by difference between levels of user and target. (Fissure/
# Sheer Cold / Guillotine / Horn Drill)
################################################################################
class PokeBattle_Move_070 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return false if opponent.ability == PBAbilities::STURDY && !opponent.moldbroken
    return false if opponent.pokemon.piece==:PAWN && @battle.FE == PBFields::CHESSB
    return false if opponent.level > attacker.level || (@id == PBMoves::SHEERCOLD && opponent.pbHasType?(:ICE))
    return true if opponent.level <= attacker.level && (attacker.ability == PBAbilities::NOGUARD || opponent.ability == PBAbilities::NOGUARD) # no guard OHKO move situation.
    acc = @accuracy + attacker.level - opponent.level
    return @battle.pbRandom(100) < acc
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @id == PBMoves::FISSURE && @battle.FE == PBFields::NEWW  # New World
      @battle.pbDisplay(_INTL("The unformed land diffused the attack..."))
      return -1
    end
    damage = pbEffectFixedDamage(opponent.totalhp,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.hp <= 0
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
    return damage
  end
end

################################################################################
# Counters a physical move used against the user this round, with 2x the power. (Counter)
################################################################################
class PokeBattle_Move_071 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::CounterTarget]>=0 &&
       attacker.pbIsOpposing?(attacker.effects[PBEffects::CounterTarget])
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::CounterTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Counter]<=0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::Counter]*2,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end

################################################################################
# Counters a specical move used against the user this round, with 2x the power. (Mirror Coat)
################################################################################
class PokeBattle_Move_072 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::MirrorCoatTarget]>=0 &&
       attacker.pbIsOpposing?(attacker.effects[PBEffects::MirrorCoatTarget])
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::MirrorCoatTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::MirrorCoat]<=0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.FE  == 30
      for stat in [PBStats::EVASION,PBStats::DEFENSE,PBStats::SPDEF]
        if attacker.pbCanIncreaseStatStage?(stat,false)
          attacker.pbIncreaseStat(stat,1,abilitymessage:false)
        end
      end
    end
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::MirrorCoat]*2,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end

################################################################################
# Counters the last damaging move used against the user this round, with 1.5x
# the power. (Metal Burst)
################################################################################
class PokeBattle_Move_073 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.lastAttacker>=0 && attacker.pbIsOpposing?(attacker.lastAttacker)
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.lastAttacker])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.lastHPLost==0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage((attacker.lastHPLost*1.5).floor,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end

################################################################################
# Damages user's partner 1/16 Max HP (Flame Burst)
################################################################################
class PokeBattle_Move_074 < PokeBattle_Move
#  def pbOnStartUse(attacker)
#    if @battle.FE == PBFields::CORROSIVEMISTF
#      bearer=@battle.pbCheckGlobalAbility(:DAMP)
#      if bearer && @battle.FE == PBFields::CORROSIVEMISTF #Corrosive Mist Field
#        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
#        bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
#        return false
#      end
#    end
#    return true
# end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret = super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if opponent.pbPartner && !opponent.pbPartner.isFainted?
      opponent.pbPartner.pbReduceHP((opponent.pbPartner.totalhp / 16.0).floor)
      @battle.pbDisplay(_INTL("The bursting flame hit {1}!", opponent.pbPartner.pbThis(true)))
      (opponent.pbPartner).pbFaint if (opponent.pbPartner).isFainted?
    end
    return ret
  end
end

################################################################################
# Power is doubled if the target is using Dive. (Surf)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_075 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCB # Dive
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# Power is doubled if the target is using Dig. (Earthquake)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_076 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCA # Dig
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop. (Gust)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_077 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xC9 || # Fly
       $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCC || # Bounce
       $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCE    # Sky Drop
      return basedmg*2
    end
    return basedmg
  end
end

################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop.
# May make the target flinch. (Twister)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_078 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xC9 || # Fly
       $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCC || # Bounce
       $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCE    # Sky Drop
      return basedmg*2
    end
    return basedmg
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute 
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end
end

################################################################################
# Power is doubled if the target has already used Fusion Flare this round. (Fusion Bolt)
################################################################################
class PokeBattle_Move_079 < PokeBattle_UnimplementedMove

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return 0 if !opponent  
    damage=pbCalcDamage(attacker,opponent)
    if attacker.effects[PBEffects::MeFirst]
      damage *= 1.5
    end
    if hitnum == 1 && attacker.effects[PBEffects::ParentalBond] && pbNumHits(attacker)==1
      damage /= 4
    end
    if opponent.damagestate.typemod!=0
      if @battle.previousMove == PBMoves::FUSIONFLARE
        pbShowAnimation(PBMoves::FUSIONBOLT2,attacker,opponent,hitnum,alltargets,showanimation) rescue pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      else 
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      end
    end
    damage=pbReduceHPDamage(damage,attacker,opponent)
    pbEffectMessages(attacker,opponent)
    pbOnDamageLost(damage,attacker,opponent)
    return damage   # The HP lost by the opponent due to this attack
  end
 
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    if @battle.previousMove == PBMoves::FUSIONFLARE
      return (damagemult*2.0).round
    else
      return damagemult
    end
  end
end

################################################################################
# Power is doubled if the target has already used Fusion Bolt this round. (Fusion Flare)
################################################################################
class PokeBattle_Move_07A < PokeBattle_UnimplementedMove

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return 0 if !opponent  
    damage=pbCalcDamage(attacker,opponent)
    if attacker.effects[PBEffects::MeFirst]
      damage *= 1.5
    end
    if hitnum == 1 && attacker.effects[PBEffects::ParentalBond] &&
      pbNumHits(attacker)==1
      damage /= 4
    end
    if opponent.damagestate.typemod!=0
      if @battle.previousMove == PBMoves::FUSIONBOLT
        pbShowAnimation(PBMoves::FUSIONFLARE2,attacker,opponent,hitnum,alltargets,showanimation) rescue pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      else
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      end
    end
    damage=pbReduceHPDamage(damage,attacker,opponent)
    pbEffectMessages(attacker,opponent)
    pbOnDamageLost(damage,attacker,opponent)
    return damage   # The HP lost by the opponent due to this attack
  end
 
  def pbBaseDamageMultiplier(damagemult, attacker, opponent)
    if @battle.previousMove == PBMoves::FUSIONBOLT
      return (damagemult*2.0).round
    else
      return damagemult
    end
  end
end

################################################################################
# Power is doubled if the target is poisoned. (Venoshock)
################################################################################
class PokeBattle_Move_07B < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if (@battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF ||
      @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS) ||
      (opponent.status==PBStatuses::POISON && opponent.effects[PBEffects::Substitute]==0)
      return basedmg*2
    end
    return basedmg
  end
end

################################################################################
# Power is doubled if the target is paralyzed.  Cures the target of paralysis. (Smelling Salts)
################################################################################
class PokeBattle_Move_07C < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status==PBStatuses::PARALYSIS &&
       opponent.effects[PBEffects::Substitute]==0
      return basedmg*2
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       opponent.status==PBStatuses::PARALYSIS && !(attacker.ability == PBAbilities::PARENTALBOND && hitnum==0)
      opponent.status=0
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.",opponent.pbThis))
    end
    return ret
  end
end

################################################################################
# Power is doubled if the target is asleep.  Wakes the target up. (Wake-up Slap)
################################################################################
class PokeBattle_Move_07D < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if (opponent.status==PBStatuses::SLEEP || opponent.ability == PBAbilities::COMATOSE) &&
       opponent.effects[PBEffects::Substitute]==0
      return basedmg*2
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       opponent.status==PBStatuses::SLEEP && !(attacker.ability == PBAbilities::PARENTALBOND && hitnum==0)
      opponent.pbCureStatus
    end
    return ret
  end
end

################################################################################
# Power is doubled if the user is burned, poisoned or paralyzed. (Facade)
################################################################################
class PokeBattle_Move_07E < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if attacker.status==PBStatuses::POISON ||
       attacker.status==PBStatuses::BURN ||
       attacker.status==PBStatuses::PARALYSIS
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# Power is doubled if the target has a status problem. (Hex)
################################################################################
class PokeBattle_Move_07F < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if (opponent.status>0 || opponent.ability == PBAbilities::COMATOSE) &&
       opponent.effects[PBEffects::Substitute]==0
      return basedmg*2
    end
    return basedmg
  end
end

################################################################################
# Power is doubled if the target's HP is down to 1/2 or less. (Brine)
################################################################################
class PokeBattle_Move_080 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if opponent.hp<=(opponent.totalhp/2.0).floor
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# Power is doubled if the user has lost HP due to the target's move this round. 
# (Revenge / Avalanche)
################################################################################
class PokeBattle_Move_081 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.lastHPLost>0 && attacker.lastAttacker==opponent.index
      return basedmg*2
    end
    return basedmg
  end
end

################################################################################
# Power is doubled if the target has already lost HP this round. (Assurance)
################################################################################
class PokeBattle_Move_082 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.lastHPLost>0
      return basedmg*2
    end
    return basedmg
  end
end

################################################################################
# Power is doubled if the user's ally has already used this move this round.
# This move goes immediately after the ally, ignoring priority. (Round)
################################################################################
class PokeBattle_Move_083 < PokeBattle_Move

  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.pbPartner.hasMovedThisRound? &&
       attacker.pbPartner.effects[PBEffects::Round]
       return basedmg*2
    elsif !attacker.pbPartner.hasMovedThisRound?
      # Partner hasn't moved yet,
      # so we flag the user with the
      # Round effect
      attacker.effects[PBEffects::Round] = true
      return basedmg
    else
      # Return base damage with no alterations
      return basedmg
    end
  end

end

################################################################################
# Power is doubled if the target has already moved this round. (Payback)
################################################################################
class PokeBattle_Move_084 < PokeBattle_Move

  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.hasMovedThisRound? && !@battle.switchedOut[opponent.index]
      return basedmg*2
    else
      return basedmg
    end
  end

end

################################################################################
# Power is doubled if a user's teammate fainted last round. (Retaliate)
################################################################################
class PokeBattle_Move_085 < PokeBattle_Move

  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::Retaliate]
      return basedmg*2
    else
      return basedmg
    end
  end

end

################################################################################
# Power is doubled if the user has no held item. (Acrobatics)
################################################################################
class PokeBattle_Move_086 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    movetype = pbType(attacker)
    gem = false
    if attacker.itemWorks? 
      case attacker.item
        when PBItems::NORMALGEM then gem = true if movetype == PBTypes::NORMAL
        when PBItems::FIGHTINGGEM then gem = true if movetype == PBTypes::FIGHTING
        when PBItems::FLYINGGEM then gem = true if movetype == PBTypes::FLYING
        when PBItems::POISONGEM then gem = true if movetype == PBTypes::POISON
        when PBItems::GROUNDGEM then gem = true if movetype == PBTypes::GROUND
        when PBItems::ROCKGEM then gem = true if movetype == PBTypes::ROCK
        when PBItems::BUGGEM then gem = true if movetype == PBTypes::BUG
        when PBItems::GHOSTGEM then gem = true if movetype == PBTypes::GHOST
        when PBItems::STEELGEM then gem = true if movetype == PBTypes::STEEL
        when PBItems::FIREGEM then gem = true if movetype == PBTypes::FIRE
        when PBItems::WATERGEM then gem = true if movetype == PBTypes::WATER
        when PBItems::GRASSGEM then gem = true if movetype == PBTypes::GRASS
        when PBItems::ELECTRICGEM then gem = true if movetype == PBTypes::ELECTRIC
        when PBItems::PSYCHICGEM then gem = true if movetype == PBTypes::PSYCHIC
        when PBItems::ICEGEM then gem = true if movetype == PBTypes::ICE
        when PBItems::DRAGONGEM then gem = true if movetype == PBTypes::DRAGON
        when PBItems::DARKGEM then gem = true if movetype == PBTypes::DARK
        when PBItems::FAIRYGEM then gem = true if movetype == PBTypes::FAIRY
      end
    end
    return basedmg*2 if attacker.item==0 || @battle.FE == PBFields::BIGTOPA || gem
    return basedmg
  end
end

################################################################################
# Power is doubled in weather.  Type changes depending on the weather. (Weather Ball)
################################################################################
class PokeBattle_Move_087 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if @battle.pbWeather!=0 || @battle.FE == PBFields::RAINBOWF
      return basedmg*2
    end
    return basedmg
  end

  def pbType(attacker,type=@type)
    weather=@battle.pbWeather
    type=(PBTypes::NORMAL) || 0
    type=((PBTypes::FIRE) || type) if (weather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
    type=((PBTypes::WATER) || type) if (weather==PBWeather::RAINDANCE && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
    type=((PBTypes::ROCK) || type) if weather==PBWeather::SANDSTORM
    type=((PBTypes::ICE)  || type) if weather==PBWeather::HAIL
    type=super(attacker,type)
    return type
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return if !showanimation
    case @battle.pbWeather
      when PBWeather::RAINDANCE
        @battle.pbAnimation(PBMoves::WEATHERBALLRAIN,attacker,opponent,hitnum) #Weather Ball - Rain
      when PBWeather::SUNNYDAY
        @battle.pbAnimation(PBMoves::WEATHERBALLSUN,attacker,opponent,hitnum) #Weather Ball - Sun
      when PBWeather::HAIL
        @battle.pbAnimation(PBMoves::WEATHERBALLHAIL,attacker,opponent,hitnum) #Weather Ball - Hail
      when PBWeather::SANDSTORM
        @battle.pbAnimation(PBMoves::WEATHERBALLSAND,attacker,opponent,hitnum) #Weather Ball - Sand
      else
        @battle.pbAnimation(id,attacker,opponent,hitnum)
    end
  end
end

################################################################################
# Power is doubled if a foe tries to switch out. (Pursuit)
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
################################################################################
class PokeBattle_Move_088 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg*2 if @battle.switching
    return basedmg
  end
end

################################################################################
# Power increases with the user's happiness. (Return)
################################################################################
class PokeBattle_Move_089 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [(attacker.happiness*2/5.0).floor,1].max
  end
end

################################################################################
# Power decreases with the user's happiness. (Frustration)
################################################################################
class PokeBattle_Move_08A < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [((255-attacker.happiness)*2/5.0).floor,1].max
  end
end

################################################################################
# Power increases with the user's HP. (Eruption / Water Spout)
################################################################################
class PokeBattle_Move_08B < PokeBattle_Move
  def pbOnStartUse(attacker)
    if @battle.FE == PBFields::CORROSIVEMISTF
      if (@id == PBMoves::ERUPTION)
        bearer=@battle.pbCheckGlobalAbility(:DAMP)
        if bearer
          @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
          bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
          return false
        end
      end
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return [(150*(attacker.hp.to_f)/attacker.totalhp).floor,1].max
  end
end

################################################################################
# Power increases with the target's HP. (Wring Out / Crush Grip)
################################################################################
class PokeBattle_Move_08C < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [(120*(opponent.hp.to_f)/opponent.totalhp).floor,1].max
  end
end

################################################################################
# Power increases the quicker the target is than the user. (Gyro Ball)
################################################################################
class PokeBattle_Move_08D < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [[(25*opponent.pbSpeed/attacker.pbSpeed).floor,150].min,1].max
  end
end

################################################################################
# Power increases with the user's positive stat changes (ignores negative ones).
# (Stored Power / Power Trip)
################################################################################
class PokeBattle_Move_08E < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    mult=0
    for i in 1...7
      mult+=attacker.stages[i] if attacker.stages[i]>0
    end
    return 20*(mult+1)
  end
end

################################################################################
# Power increases with the target's positive stat changes (ignores negative ones).
# (Punishment)
################################################################################
class PokeBattle_Move_08F < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    mult=0
    for i in 1...7
      mult+=opponent.stages[i] if opponent.stages[i]>0
    end
    return [20*(mult+3),200].min
  end
end

################################################################################
# Power and type depends on the user's IVs. (Hidden Power)
################################################################################
class PokeBattle_Move_090 < PokeBattle_Move

  def pbType(attacker,type=@type)
    type=pbHiddenPower(attacker.pokemon)
    type=super(attacker,type)
    return type
  end

end

  def pbHiddenPower(user)
    return user.hptype if user.hptype != nil
    type=0
    types=[]
    #for i in 0..PBTypes.maxValue
    #  types.push(i) if !PBTypes.isPseudoType?(i) && i != PBTypes::NORMAL
    #end
    #type|=(user.iv[PBStats::HP]&1)
    #type|=(user.iv[PBStats::ATTACK]&1)<<1
    #type|=(user.iv[PBStats::DEFENSE]&1)<<2
    #type|=(user.iv[PBStats::SPEED]&1)<<3
    #type|=(user.iv[PBStats::SPATK]&1)<<4
    #type|=(user.iv[PBStats::SPDEF]&1)<<5
    #type=(type*(types.length-2)/63).floor
    #user.hptype=types[type]
    #return user.hptype
    
    for i in 0..PBTypes.maxValue
      types.push(i) if !PBTypes.isPseudoType?(i) && i != PBTypes::NORMAL #&& i!= PBTypes::FAIRY
    end
    selected_index = user.personalID % types.length
    user.hptype = types[selected_index]
    return user.hptype
  end

################################################################################
# Power doubles for each consecutive use. (Fury Cutter)
################################################################################
class PokeBattle_Move_091 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    basedmg=basedmg<<(attacker.effects[PBEffects::FuryCutter]-1) # can be 1 to 4
    return basedmg
  end
end

################################################################################
# Power doubles for each consecutive use. (Echoed Voice)
################################################################################
class PokeBattle_Move_092 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    basedmg*=attacker.effects[PBEffects::EchoedVoice] # can be 1 to 5
    return basedmg
  end
end

################################################################################
# User rages until the start of a round in which they don't use this move. (Rage)
# Handled in Battler class: Ups rager's Attack by 1 stage each time it loses HP due to a move.
################################################################################
class PokeBattle_Move_093 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Rage]=true if ret>0
    return ret
  end
end

################################################################################
# Randomly damages or heals the target. (Present)
################################################################################
class PokeBattle_Move_094 < PokeBattle_Move

  def pbBaseDamage(basedmg,attacker,opponent)
    return @calcbasedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    @calcbasedmg=1
    r=@battle.pbRandom(10)
    if r<4
      @calcbasedmg=40
    elsif r<7
      @calcbasedmg=80
    elsif r<8
      @calcbasedmg=120
    else
      if pbTypeModifier(@type,attacker,opponent)==0
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
        return -1
      end
      if opponent.hp==opponent.totalhp
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      damage=pbCalcDamage(attacker,opponent) # Must do this even if it will heal
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation) # Healing animation
      opponent.pbRecoverHP([1,(opponent.totalhp/4.0).floor].max,true)
      @battle.pbDisplay(_INTL("{1} had its HP restored.",opponent.pbThis))
      return 0
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Power is chosen at random.  Power is doubled if the target is using Dig. (Magnitude)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_095 < PokeBattle_Move
  @calcbasedmg=0
  def pbOnStartUse(attacker)
    basedmg=[10,30,50,70,90,110,150]
    magnitudes=[
       4,
       5,5,
       6,6,6,6,
       7,7,7,7,7,7,
       8,8,8,8,
       9,9,
       10
    ]
    magni=magnitudes[@battle.pbRandom(magnitudes.length)]
    @calcbasedmg=basedmg[magni-4]
    @battle.pbDisplay(_INTL("Magnitude {1}!",magni))
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCA # Dig
      return @calcbasedmg*2
    end
    return @calcbasedmg
  end
end

################################################################################
# Power and type depend on the user's held berry.  Destroys the berry. (Natural Gift)
################################################################################
class PokeBattle_Move_096 < PokeBattle_Move
  def initialize(battle,move,user)
    super(battle,move,user)
    @berry=0
  end

  def pbOnStartUse(attacker)
    if !pbIsBerry?(attacker.item)
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    @berry=attacker.item
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.item==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return 0
    end
    attacker.pbDisposeItem(true)
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if @berry!=0
      return !PBStuff::NATURALGIFTDAMAGE[@berry].nil? ? PBStuff::NATURALGIFTDAMAGE[@berry] : 1
    else
      return !PBStuff::NATURALGIFTDAMAGE[attacker.item].nil? ? PBStuff::NATURALGIFTDAMAGE[attacker.item] : 1
    end
  end

  def pbType(attacker,type=@type)
    
    if @berry != 0
      type= !PBStuff::NATURALGIFTTYPE[@berry].nil? ? PBStuff::NATURALGIFTTYPE[@berry] : PBTypes::NORMAL
    else
      type= !PBStuff::NATURALGIFTTYPE[attacker.item].nil? ? PBStuff::NATURALGIFTTYPE[attacker.item] : PBTypes::NORMAL
    end
    return super(attacker,type)
  end
end

################################################################################
# Power increases the less PP this move has. (Trump Card)
################################################################################
class PokeBattle_Move_097 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    dmgs=[200,80,60,50,40]
    ppleft=[@pp,4].min   # PP is reduced before the move is used
    basedmg=dmgs[ppleft]
    return basedmg
  end
end

################################################################################
# Power increases the less HP the user has. (Flail / Reversal)
################################################################################
class PokeBattle_Move_098 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=((48*attacker.hp.to_f)/attacker.totalhp).floor
    ret=20
    ret=40 if n<33
    ret=80 if n<17
    ret=100 if n<10
    ret=150 if n<5
    ret=200 if n<2
    return ret
  end
end

################################################################################
# Power increases the quicker the user is than the target. (Electro Ball)
################################################################################
class PokeBattle_Move_099 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=(attacker.pbSpeed/opponent.pbSpeed).floor
    ret=40
    ret=60 if n>=1
    ret=80 if n>=2
    ret=120 if n>=3
    ret=150 if n>=4
    return ret
  end
end

################################################################################
# Power increases the heavier the target is. (Low Kick / Grass Knot)
################################################################################
class PokeBattle_Move_09A < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    weight=opponent.weight
    ret=20
    ret=40 if weight>100
    ret=60 if weight>250
    ret=80 if weight>500
    ret=100 if weight>1000
    ret=120 if weight>2000
    return ret
  end
end

################################################################################
# Power increases the heavier the user is than the target. (heavy Slam / Heat Crash)
################################################################################
class PokeBattle_Move_09B < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=(attacker.weight/opponent.weight).floor
    ret=40
    ret=60 if n>=2
    ret=80 if n>=3
    ret=100 if n>=4
    ret=120 if n>=5
    return ret
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.effects[PBEffects::Minimize]
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# Powers up the ally's attack this round by 1.5. (Helping Hand)
################################################################################
class PokeBattle_Move_09C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbPartner.isFainted? ||
       attacker.pbPartner.effects[PBEffects::HelpingHand] ||
       @battle.pbGetPriority(attacker) > @battle.pbGetPriority(attacker.pbPartner)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,attacker.pbPartner,hitnum,alltargets,showanimation)
    attacker.pbPartner.effects[PBEffects::HelpingHand]=true
    @battle.pbDisplay(_INTL("{1} is ready to help {2}!",attacker.pbThis,attacker.pbPartner.pbThis(true)))
    return 0
  end
end

################################################################################
# Weakens Electric attacks. (Mud Sport)
################################################################################
class PokeBattle_Move_09D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.state.effects[PBEffects::MudSport]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.state.effects[PBEffects::MudSport]=5
    @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
    return 0
  end
end

################################################################################
# Weakens Fire attacks. (Water Sport)
################################################################################
class PokeBattle_Move_09E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.state.effects[PBEffects::WaterSport]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.state.effects[PBEffects::WaterSport]=5
    @battle.pbDisplay(_INTL("Fire's power was weakened!"))
    return 0
  end
end

################################################################################
# Type depends on the user's held item. (Judgment / Techno Blast / Multi-Attack)
################################################################################
class PokeBattle_Move_09F < PokeBattle_Move
  def pbType(attacker,type=@type)
    if ((@id == PBMoves::JUDGMENT) && (attacker.species == PBSpecies::ARCEUS)) || 
      ((@id == PBMoves::MULTIATTACK) && (attacker.species == PBSpecies::SILVALLY))
      type = attacker.form % 19
    end
    if attacker.itemWorks? && attacker.form<19
      if @id == PBMoves::TECHNOBLAST
        case attacker.item
          when PBItems::SHOCKDRIVE then type = PBTypes::ELECTRIC  
          when PBItems::BURNDRIVE then type = PBTypes::FIRE
          when PBItems::CHILLDRIVE then type = PBTypes::ICE
          when PBItems::DOUSEDRIVE then type = PBTypes::WATER
        end
      elsif @id == PBMoves::MULTIATTACK
        case attacker.item
          when PBItems::FIGHTINGMEMORY then type = PBTypes::FIGHTING  
          when PBItems::FLYINGMEMORY then type = PBTypes::FLYING
          when PBItems::POISONMEMORY then type = PBTypes::POISON
          when PBItems::GROUNDMEMORY then type = PBTypes::GROUND
          when PBItems::ROCKMEMORY then type = PBTypes::ROCK
          when PBItems::BUGMEMORY then type = PBTypes::BUG
          when PBItems::GHOSTMEMORY then type = PBTypes::GHOST
          when PBItems::STEELMEMORY then type = PBTypes::STEEL
          when PBItems::FIREMEMORY then type = PBTypes::FIRE
          when PBItems::WATERMEMORY then type = PBTypes::WATER
          when PBItems::GRASSMEMORY then type = PBTypes::GRASS
          when PBItems::ELECTRICMEMORY then type = PBTypes::ELECTRIC
          when PBItems::PSYCHICMEMORY then type = PBTypes::PSYCHIC
          when PBItems::ICEMEMORY then type = PBTypes::ICE
          when PBItems::DRAGONMEMORY then type = PBTypes::DRAGON
          when PBItems::DARKMEMORY then type = PBTypes::DARK
          when PBItems::FAIRYMEMORY then type = PBTypes::FAIRY
        end
      elsif @id == PBMoves::JUDGMENT
        case attacker.item
          when PBItems::FISTPLATE then type = PBTypes::FIGHTING
          when PBItems::SKYPLATE then type = PBTypes::FLYING
          when PBItems::TOXICPLATE then type = PBTypes::POISON
          when PBItems::EARTHPLATE then type = PBTypes::GROUND
          when PBItems::STONEPLATE then type = PBTypes::ROCK
          when PBItems::INSECTPLATE then type = PBTypes::BUG
          when PBItems::SPOOKYPLATE then type = PBTypes::GHOST
          when PBItems::IRONPLATE then type = PBTypes::STEEL
          when PBItems::FLAMEPLATE then type = PBTypes::FIRE
          when PBItems::SPLASHPLATE then type = PBTypes::WATER
          when PBItems::MEADOWPLATE then type = PBTypes::GRASS
          when PBItems::ZAPPLATE then type = PBTypes::ELECTRIC
          when PBItems::MINDPLATE then type = PBTypes::PSYCHIC
          when PBItems::ICICLEPLATE then type = PBTypes::ICE
          when PBItems::DRACOPLATE then type = PBTypes::DRAGON
          when PBItems::DREADPLATE then type = PBTypes::DARK
          when PBItems::PIXIEPLATE then type = PBTypes::FAIRY
        end
      end
    end
    return super(attacker,type)
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return if !showanimation
    if @id == PBMoves::TECHNOBLAST && attacker.itemWorks?
      case attacker.item
        when PBItems::SHOCKDRIVE
          @battle.pbAnimation(PBMoves::TECHNOBLASTELECTRIC,attacker,opponent,hitnum)
        when PBItems::BURNDRIVE
          @battle.pbAnimation(PBMoves::TECHNOBLASTFIRE,attacker,opponent,hitnum)
        when PBItems::CHILLDRIVE
          @battle.pbAnimation(PBMoves::TECHNOBLASTICE,attacker,opponent,hitnum)
        when PBItems::DOUSEDRIVE
          @battle.pbAnimation(PBMoves::TECHNOBLASTWATER,attacker,opponent,hitnum)
        else
          @battle.pbAnimation(id,attacker,opponent,hitnum)
        end
    end
    if @id == PBMoves::JUDGMENT && attacker.itemWorks?
      case attacker.item
      when PBItems::FISTPLATE, PBItems::FIGHTINIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTFIGHTING,attacker,opponent,hitnum)
      when PBItems::SKYPLATE, PBItems::FLYINIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTFLYING,attacker,opponent,hitnum)
      when PBItems::TOXICPLATE, PBItems::POISONIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTPOISON,attacker,opponent,hitnum)
      when PBItems::EARTHPLATE, PBItems::GROUNDIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTGROUND,attacker,opponent,hitnum)
      when PBItems::STONEPLATE, PBItems::ROCKIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTROCK,attacker,opponent,hitnum)
      when PBItems::INSECTPLATE, PBItems::BUGINIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTBUG,attacker,opponent,hitnum)
      when PBItems::SPOOKYPLATE, PBItems::GHOSTIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTGHOST,attacker,opponent,hitnum)
      when PBItems::IRONPLATE, PBItems::STEELIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTSTEEL,attacker,opponent,hitnum)
      when PBItems::FLAMEPLATE, PBItems::FIRIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTFIRE,attacker,opponent,hitnum)
      when PBItems::SPLASHPLATE, PBItems::WATERIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTWATER,attacker,opponent,hitnum)
      when PBItems::MEADOWPLATE, PBItems::GRASSIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTGRASS,attacker,opponent,hitnum)
      when PBItems::ZAPPLATE, PBItems::ELECTRIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTELECTRIC,attacker,opponent,hitnum)
      when PBItems::MINDPLATE, PBItems::PSYCHIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTPSYCHIC,attacker,opponent,hitnum)
      when PBItems::ICICLEPLATE, PBItems::ICIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTICE,attacker,opponent,hitnum)
      when PBItems::DRACOPLATE, PBItems::DRAGONIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTDRAGON,attacker,opponent,hitnum)
      when PBItems::DREADPLATE, PBItems::DARKINIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTDARK,attacker,opponent,hitnum)
      when PBItems::PIXIEPLATE, PBItems::FAIRIUMZ2
        @battle.pbAnimation(PBMoves::JUDGMENTFAIRY,attacker,opponent,hitnum)
      else @battle.pbAnimation(id,attacker,opponent,hitnum)
      end
    end
    if @id == PBMoves::MULTIATTACKGLITCH
      @battle.pbAnimation(PBMoves::MULTIATTACKGLITCH,attacker,opponent,hitnum)
    elsif @id == PBMoves::MULTIATTACK && attacker.itemWorks?
      case attacker.item
        when PBItems::FIGHTINGMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKFIGHTING,attacker,opponent,hitnum)
        when PBItems::FLYINGMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKFLYING,attacker,opponent,hitnum)
        when PBItems::POISONMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKPOISON,attacker,opponent,hitnum)
        when PBItems::GROUNDMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKGROUND,attacker,opponent,hitnum)
        when PBItems::ROCKMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKROCK,attacker,opponent,hitnum)
        when PBItems::BUGMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKBUG,attacker,opponent,hitnum)
        when PBItems::GHOSTMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKBUG,attacker,opponent,hitnum)
        when PBItems::STEELMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKSTEEL,attacker,opponent,hitnum)
        when PBItems::FIREMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKFIRE,attacker,opponent,hitnum)
        when PBItems::WATERMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKWATER,attacker,opponent,hitnum)
        when PBItems::GRASSMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKGRASS,attacker,opponent,hitnum)
        when PBItems::ELECTRICMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKELECTRIC,attacker,opponent,hitnum)
        when PBItems::PSYCHICMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKPSYCHIC,attacker,opponent,hitnum)
        when PBItems::ICEMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKICE,attacker,opponent,hitnum)
        when PBItems::DRAGONMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKDRAGON,attacker,opponent,hitnum)
        when PBItems::DARKMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKDARK,attacker,opponent,hitnum)
        when PBItems::FAIRYMEMORY
          @battle.pbAnimation(PBMoves::MULTIATTACKFAIRY,attacker,opponent,hitnum)
        else @battle.pbAnimation(id,attacker,opponent,hitnum)
      end
    end
  end
end

################################################################################
# This attack is always a critical hit, if successful. (Storm Throw / Frost Breath)
################################################################################
class PokeBattle_Move_0A0 < PokeBattle_Move
# Handled in superclass, do not edit!
end

################################################################################
# For 5 rounds, foes' attacks cannot become critical hits. (Lucky Chant)
################################################################################
class PokeBattle_Move_0A1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::LuckyChant]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::LuckyChant]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("The Lucky Chant shielded your team from critical hits!"))
    else
      @battle.pbDisplay(_INTL("The Lucky Chant shielded the foe's team from critical hits!"))
    end
    return 0
  end
end

################################################################################
# For 5 rounds, lowers power of physical attacks against the user's side. (Reflect)
################################################################################
class PokeBattle_Move_0A2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Reflect]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Reflect]=5
    attacker.pbOwnSide.effects[PBEffects::Reflect]=8 if attacker.hasWorkingItem(:LIGHTCLAY)
    attacker.pbOwnSide.effects[PBEffects::Reflect]=8 if @battle.FE == PBFields::MIRRORA
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Reflect raised your team's Defense!"))
    else
      @battle.pbDisplay(_INTL("Reflect raised the opposing team's Defense!"))
    end
    if @battle.FE  == 30
      if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
        attacker.pbIncreaseStat(PBStats::EVASION,1,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# For 5 rounds, lowers power of special attacks against the user's side. (Light Screen)
################################################################################
class PokeBattle_Move_0A3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::LightScreen]=5
    attacker.pbOwnSide.effects[PBEffects::LightScreen]=8 if attacker.hasWorkingItem(:LIGHTCLAY)
    attacker.pbOwnSide.effects[PBEffects::LightScreen]=8 if @battle.FE == PBFields::MIRRORA
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Light Screen raised your team's Special Defense!"))
    else
      @battle.pbDisplay(_INTL("Light Screen raised the opposing team's Special Defense!"))
    end
    if @battle.FE  == 30
      if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
        attacker.pbIncreaseStat(PBStats::EVASION,1,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Effect depends on the environment. (Secret power)
################################################################################
class PokeBattle_Move_0A4 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@battle.field.secretPowerAnim,attacker,opponent,hitnum,alltargets,showanimation) unless pbTypeModifier(@type,attacker,opponent)==0
    return super(attacker,opponent,hitnum,alltargets,false)
  end

  def pbAdditionalEffect(attacker,opponent)
    case @battle.FE
    when 1,18 
      return false if !opponent.pbCanParalyze?(false)
      opponent.pbParalyze(attacker)
      @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
    when 2,15,31 
      return false if !opponent.pbCanSleep?(false)
      opponent.pbSleep
      @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
    when 3,29 
      return false if !opponent.pbCanReduceStatStage?(PBStats::SPATK,1,false)
      opponent.pbReduceStat(PBStats::SPATK,1,abilitymessage:false, statdropper: attacker)
    when 4,12,20 
      return false if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,1,false)
      opponent.pbReduceStat(PBStats::ACCURACY,1,abilitymessage:false, statdropper: attacker)
    when 5
      return false if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,1,false)
      opponent.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false, statdropper: attacker)
    when 6,34 
      return false if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,1,false)
      opponent.pbReduceStat(PBStats::SPDEF,1,abilitymessage:false, statdropper: attacker)
    when 7,16,32 
      return false if !opponent.pbCanBurn?(false)
      opponent.pbBurn(attacker)
      @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    when 8,21,24 
      return false if !opponent.pbCanReduceStatStage?(PBStats::SPEED,1,false)
      opponent.pbReduceStat(PBStats::SPEED,1,abilitymessage:false, statdropper: attacker)
    when 9,19,25
      rnd=0
      loop do
        rnd=@battle.pbRandom(6)
        break if (@battle.FE == PBFields::RAINBOWF && rnd != 5) || (@battle.FE == PBFields::WASTELAND && rnd<4) || (@battle.FE == PBFields::CRYSTALC && rnd>2)
      end
      case rnd
        when 0
          return false if !opponent.pbCanParalyze?(false)
          opponent.pbParalyze(attacker)
          @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
        when 1
          return false if !opponent.pbCanPoison?(false)
          opponent.pbPoison(attacker)
          @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
        when 2
          return false if !opponent.pbCanBurn?(false)
          opponent.pbBurn(attacker)
          @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
        when 3
          return false if !opponent.pbCanFreeze?(false)
          opponent.pbFreeze
          @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
        when 4
          return false if !opponent.pbCanSleep?(false)
          opponent.pbSleep
          @battle.pbDisplay(_INTL("{1} fell asleep!",opponent.pbThis))
        when 5
          return false if !opponent.pbCanConfuse?(false)
          opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
          @battle.pbCommonAnimation("Confusion",opponent,nil)
          @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      end
    when 10,11,26
      return false if !opponent.pbCanPoison?(false)
      opponent.pbPoison(attacker)
      @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
    when 13,28 
      return false if !opponent.pbCanFreeze?(false)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen!",opponent.pbThis))
    when 14,23,27 
      return false if opponent.ability == PBAbilities::INNERFOCUS || opponent.damagestate.substitute
      opponent.effects[PBEffects::Flinch]=true
    when 17,22 
      return false if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,1,false)
      opponent.pbReduceStat(PBStats::ATTACK,1,abilitymessage:false, statdropper: attacker)
    when 30
      return false if !opponent.pbCanReduceStatStage?(PBStats::EVASION,1,false)
      opponent.pbReduceStat(PBStats::EVASION,1,abilitymessage:false, statdropper: attacker)
    when 33
      case @battle.field.counter
        when 0,1
          return false if !opponent.pbCanReduceStatStage?(PBStats::EVASION,1,false)
          opponent.pbReduceStat(PBStats::EVASION,1,abilitymessage:false)
        when 2,3
          opponent.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,1,false)
          opponent.pbReduceStat(PBStats::SPDEF,1,abilitymessage:false, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::SPDEF,1,false)
          opponent.pbReduceStat(PBStats::EVASION,1,abilitymessage:false, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::EVASION,1,false)
        when 4
          opponent.pbReduceStat(PBStats::DEFENSE,2,abilitymessage:false, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,1,false)
          opponent.pbReduceStat(PBStats::SPDEF,2,abilitymessage:false, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::SPDEF,1,false)
          opponent.pbReduceStat(PBStats::EVASION,2,abilitymessage:false, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::EVASION,1,false)
      end
    when 35
      for i in 1...7
        opponent.pbReduceStat(i,1,abilitymessage:false, statdropper: attacker) if opponent.pbCanReduceStatStage?(i,1,false)
      end
    when 36, 37
      return false if !opponent.pbCanConfuse?(false)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
    else
      return false if !opponent.pbCanParalyze?(false)
      opponent.pbParalyze(attacker)
      @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
    end
    return true
  end
end

################################################################################
# Always hits. (Feint Attack / Shock Wave / Aura Sphere / Vital Throw / Aerial Ace /
# Shadow Punch / Magical Leaf / Swift / Magnet Bomb / Disarming Voice / Smart Strike)
################################################################################
class PokeBattle_Move_0A5 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end
end

################################################################################
# User's attack next round against the target will definitely hit. (Lock-On / Mind Reader)
################################################################################
class PokeBattle_Move_0A6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::LockOn]=2
    opponent.effects[PBEffects::LockOnPos]=attacker.index
    @battle.pbDisplay(_INTL("{1} took aim at {2}!",attacker.pbThis,opponent.pbThis(true)))
    if @battle.FE == PBFields::PSYCHICT && (@id == PBMoves::MINDREADER)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Target's evasion stat changes are ignored from now on. (Foresight / Odor Sleuth)
# Normal and Fighting moves have normal effectiveness against the Ghost-type target.
################################################################################
class PokeBattle_Move_0A7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Foresight]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Foresight]=true
    @battle.pbDisplay(_INTL("{1} was identified!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Target's evasion stat changes are ignored from now on. (Miracle Eye)
# Psychic moves have normal effectiveness against the Dark-type target.
################################################################################
class PokeBattle_Move_0A8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::MiracleEye]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::MiracleEye]=true
    @battle.pbDisplay(_INTL("{1} was identified!",opponent.pbThis))
    if @battle.FE == PBFields::HOLYF || @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::PSYCHICT
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# This move ignores target's Defense, Special Defense and evasion stat changes.
# (SacredSword / Chip Away / Darkest Lariat)
################################################################################
class PokeBattle_Move_0A9 < PokeBattle_Move
# Handled in superclass, do not edit!
end

################################################################################
# User is protected against moves with the "B" flag this round. (Detect / Protect)
################################################################################
class PokeBattle_Move_0AA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !PBStuff::RATESHARERS.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority = @battle.pbPriority
    if (@battle.doublebattle && attacker == priority[3]) || (!@battle.doublebattle && attacker == priority[1])
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbRandom(65536)<(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::Protect]=true
      attacker.effects[PBEffects::ProtectRate]*=3
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
      return 0
    else
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# User's side is protected against moves with priority greater than 0 this round. (Quick Guard)
################################################################################
class PokeBattle_Move_0AB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !PBStuff::RATESHARERS.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority = @battle.pbPriority
    if (@battle.doublebattle && attacker == priority[3]) || (!@battle.doublebattle && attacker == priority[1])
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbOwnSide.effects[PBEffects::QuickGuard]=true
    attacker.effects[PBEffects::ProtectRate]*=3
    @battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("{1} protected its team!",attacker.pbThis))
    return 0
  end
end

################################################################################
# User's side is protected against moves that target multiple battlers this round. (Wide Guard)
################################################################################
class PokeBattle_Move_0AC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !PBStuff::RATESHARERS.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority = @battle.pbPriority
    if (@battle.doublebattle && attacker == priority[3]) || (!@battle.doublebattle && attacker == priority[1])
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbOwnSide.effects[PBEffects::WideGuard]=true
    attacker.pbPartner.effects[PBEffects::WideGuardUser]=false
    attacker.effects[PBEffects::WideGuardUser]=true
    attacker.effects[PBEffects::ProtectRate]*=3
    @battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("{1} protected its team!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Ignores target's protections.  If successful, all other moves this round
# ignore them too. (Feint)
################################################################################
class PokeBattle_Move_0AD < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::ProtectNegation]=true if ret>0
    if opponent.pbPartner && !opponent.pbPartner.isFainted? && !opponent.pbPartner.effects[PBEffects::Protect] && !opponent.pbPartner.effects[PBEffects::SpikyShield] &&
       !opponent.pbPartner.effects[PBEffects::KingsShield] && !opponent.pbPartner.effects[PBEffects::Obstruct]
      opponent.pbPartner.effects[PBEffects::ProtectNegation]=true
    elsif (opponent.pbPartner.effects[PBEffects::Protect] || opponent.pbPartner.effects[PBEffects::SpikyShield] || opponent.pbPartner.effects[PBEffects::KingsShield] || opponent.pbPartner.effects[PBEffects::Obstruct]) &&
          (opponent.pbOwnSide.effects[PBEffects::CraftyShield] || opponent.pbOwnSide.effects[PBEffects::WideGuard] || opponent.pbOwnSide.effects[PBEffects::QuickGuard] ||
          opponent.pbOwnSide.effects[PBEffects::MatBlock])
      opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false
      opponent.pbOwnSide.effects[PBEffects::WideGuard]=false
      opponent.pbOwnSide.effects[PBEffects::QuickGuard]=false
      opponent.pbOwnSide.effects[PBEffects::MatBlock]=false
    end
    return ret
  end
end

################################################################################
# Uses the last move that the target used. (Mirror Move)
################################################################################
class PokeBattle_Move_0AE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    movedata=PBMoveData.new(opponent.lastMoveUsed)
    if opponent.lastMoveUsed<=0 || movedata.basedamage <= 0
      @battle.pbDisplay(_INTL("The mirror move failed!"))
      return -1
    end
    if @battle.FE  == 30
      for stat in [PBStats::SPATK,PBStats::ATTACK,PBStats::ACCURACY]
        if attacker.pbCanIncreaseStatStage?(stat,false)
          attacker.pbIncreaseStat(stat,1,abilitymessage:false)
        end
      end
    end
    attacker.pbUseMoveSimple(opponent.lastMoveUsed,-1,opponent.index)
    return 0
  end
end

################################################################################
# Uses the last move that was used. (Copycat)
################################################################################
class PokeBattle_Move_0AF < PokeBattle_Move
   def pbEffect(attacker, opponent, hitnum=0, alltargets=nil, showanimation=true)
    moveid = @battle.previousMove
    # TODO: Check Z-Moves
    if !moveid || moveid < 0 || PBStuff::BLACKLISTS[:COPYCAT].include?(moveid)
      @battle.pbDisplay(_INTL("The copycat failed!"))
      return -1
    end
    attacker.pbUseMoveSimple(moveid,-1,-1)
    return 0
  end
end

################################################################################
# Uses the move the target was about to use this round, with 1.5x power. (Me First)
################################################################################
class PokeBattle_Move_0B0 < PokeBattle_Move

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    priorityAttacker = @battle.pbGetPriority(attacker)
    priorityOpponent = @battle.pbGetPriority(opponent)
    count = 0
    # If the opponent's priority is LOWER, that means
    # it attacks BEFORE the attacker
    if priorityOpponent < priorityAttacker
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      moveid = opponent.selectedMove
      # Now we test if the move is valid
      if !moveid || PBStuff::BLACKLISTS[:MEFIRST].include?(moveid) || @battle.zMove.any?{|t1| t1.any?{|t2| t2 == opponent.index}}
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      movedata = PBMoveData.new(moveid)
      # if it's equal or less than zero then it's
      # not an attack move
      if movedata.basedamage <= 0
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      else
      # It's greater than zero, so it works.
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      attacker.effects[PBEffects::MeFirst] = true
      attacker.pbUseMoveSimple(moveid,-1,opponent.index)
      return 0
      end
    end
  end

end

################################################################################
# This round, reflects all moves with the "C" flag targeting the user back at
# their origin. (Magic Coat)
################################################################################
class PokeBattle_Move_0B1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MagicCoat]=true
    @battle.pbDisplay(_INTL("{1} shrouded itself with Magic Coat!",attacker.pbThis))
    return 0
  end
end

################################################################################
# This round, snatches all used moves with the "D" flag. (Snatch)
################################################################################
class PokeBattle_Move_0B2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (@battle.pbGetPriority(attacker)==1 && !@battle.doublebattle) || (@battle.pbGetPriority(attacker)==3 && @battle.doublebattle)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Snatch]=true
    @battle.pbDisplay(_INTL("{1} waits for a target to make a move!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Uses a different move depending on the environment. (Nature Power)
################################################################################
class PokeBattle_Move_0B3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    move=@battle.field.naturePower
    thismovename=PBMoves.getName(@id)
    movename=PBMoves.getName(move)
    @battle.pbDisplay(_INTL("{1} turned into {2}!",thismovename,movename))
    attacker.pbUseMoveSimple(move,-1,opponent.index)
    return 0
  end
end

################################################################################
# Uses a random move the user knows.  Fails if user is not asleep. (Sleep Talk)
################################################################################
class PokeBattle_Move_0B4 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.status!=PBStatuses::SLEEP && attacker.ability != PBAbilities::COMATOSE
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    blacklist = PBStuff::BLACKLISTS[:SLEEPTALK]
    choices = (0...4).to_a.select{|i| (attacker.moves[i].id != 0) && !blacklist.include?(attacker.moves[i].id) && @battle.pbCanChooseMove?(attacker.index,i,false,{sleeptalk: true})}
    if choices.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end

    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    choice=choices[@battle.pbRandom(choices.length)]
    if attacker.moves[choice].id == PBMoves::ACUPRESSURE
       attacker.pbUseMoveSimple(attacker.moves[choice].id,choice,attacker.index)
    else
       attacker.pbUseMoveSimple(attacker.moves[choice].id,choice,attacker.pbOppositeOpposing.index)
    end
    return 0
  end
end

################################################################################
# Uses a random move known by any non-user Pokémon in the user's party. (Assist)
################################################################################
class PokeBattle_Move_0B5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist = PBStuff::BLACKLISTS[:ASSIST]
    moves=[]
    party=@battle.pbParty(attacker.index) # NOTE: pbParty is common to both allies in multi battles
    for i in 0...party.length
      if i != attacker.pokemonIndex && party[i] && !party[i].isEgg?
        for move in party[i].moves
          moveid = move.id
          next if moveid == 0 || blacklist.include?(moveid)
          moves.push(move.id)
        end
      end
    end
    if moves.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    move=moves[@battle.pbRandom(moves.length)]
    attacker.pbUseMoveSimple(move)
    return 0
  end
end

################################################################################
# Uses a random move that exists. (Metronome)
################################################################################
class PokeBattle_Move_0B6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    possiblemoves = (1..694).to_a - PBStuff::BLACKLISTS[:METRONOME]
    if @battle.FE == PBFields::GLITCHF
      possiblemoves = possiblemoves.filter{ |i| $cache.pkmn_move[i][PBMoveData::BASEDAMAGE] >= 70}
    end
    move = possiblemoves.sample()
    if move
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      if move == PBMoves::ACUPRESSURE
        # Metronome always targets the user if it calls Acupressure.
        attacker.pbUseMoveSimple(move,-1,attacker.index)
      else
        attacker.pbUseMoveSimple(move)
      end
      return 0
    else
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# The target can no longer use the same move twice in a row. (Torment)
################################################################################
class PokeBattle_Move_0B7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Torment]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("The Aroma Veil prevents #{opponent.pbThis} from torment!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Torment]=true
    @battle.pbDisplay(_INTL("{1} was subjected to torment!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Disables all target's moves that the user also knows. (Imprison)
################################################################################
class PokeBattle_Move_0B8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Imprison]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Imprison]=true
    @battle.pbDisplay(_INTL("{1} sealed the opponent's move(s)!",attacker.pbThis))
    return 0
  end
end

################################################################################
# For 5 rounds, disables the last move the target used. (Disable)
################################################################################
class PokeBattle_Move_0B9 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Disable]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("The Aroma Veil prevents #{opponent.pbThis} from disabling!"))
      return -1
    end
    for i in opponent.moves
      if i.id>0 && i.id==opponent.lastMoveUsed && (i.pp>0 || i.totalpp==0)
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        opponent.effects[PBEffects::Disable]=4
        opponent.effects[PBEffects::DisableMove]=opponent.lastMoveUsed
        @battle.pbDisplay(_INTL("{1}'s {2} was disabled!",opponent.pbThis,i.name))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end

################################################################################
# For 4 rounds, disables the target's non-damaging moves. (Taunt)
################################################################################
class PokeBattle_Move_0BA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
   # this was unchanged - just a reference of where the following needs to be placed.
    if opponent.effects[PBEffects::Taunt]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("The Aroma Veil prevents #{opponent.pbThis} from taunt!"))
      return -1
    end
    # UPDATE 11/16/2013
    # Oblivious now protects from taunt
    if (opponent.ability == PBAbilities::OBLIVIOUS) && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Taunt]=4
    @battle.pbDisplay(_INTL("{1} fell for the taunt!",opponent.pbThis))
    return 0
  end
end

################################################################################
# For 5 rounds, disables the target's healing moves. (Heal Block)
################################################################################
class PokeBattle_Move_0BB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::HealBlock]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("The Aroma Veil prevents #{opponent.pbThis} from being blocked!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::HealBlock]=5
    @battle.pbDisplay(_INTL("{1} was prevented from healing!",opponent.pbThis))
    return 0
  end
end

################################################################################
# For 4 rounds, the target must use the same move each round. (Encore)
################################################################################
class PokeBattle_Move_0BC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist = PBStuff::BLACKLISTS[:ENCORE]
    moveid = opponent.lastMoveUsed
    if opponent.effects[PBEffects::Encore]>0 || moveid<=0 || blacklist.include?(moveid)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbCheckSideAbility(:AROMAVEIL,opponent) && !opponent.moldbroken
      @battle.pbDisplay(_INTL("The Aroma Veil prevents #{opponent.pbThis} from the encore!"))
      return -1
    end

    # First check if their last choice matches the encore'd move.
    moveIndex = opponent.lastMoveChoice[1]
    # Just to be safe, if it doesn't match, find it manually.
    if opponent.moves[moveIndex].id != moveid
      found = false
      for i in 0...4
        if moveid==opponent.moves[i].id
          found = true
          moveIndex = i
          break
        end
      end
      if !found
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    # Once it's found, make sure it has PP.
    if opponent.moves[moveIndex].pp == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end

    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::BIGTOPA
      opponent.effects[PBEffects::Encore] = 7
    else
      opponent.effects[PBEffects::Encore] = 3
    end
    opponent.effects[PBEffects::EncoreIndex] = moveIndex
    opponent.effects[PBEffects::EncoreMove] = moveid
    @battle.pbDisplay(_INTL("{1} received an encore!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Hits twice. (Gear Grind / Double Hit / Double Kick / Dual Chop / Bonemerang)
################################################################################
class PokeBattle_Move_0BD < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
      return 2
  end
end

################################################################################
# Hits twice.  May poison the targer on each hit. (Twineedle)
################################################################################
class PokeBattle_Move_0BE < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(false)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
    return true
  end
end

################################################################################
# Hits 3 times.  Power is multiplied by the hit number. (Triple Kick)
################################################################################
class PokeBattle_Move_0BF < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 3
  end

  def pbOnStartUse(attacker)
    @calcbasedmg=@basedamage
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    ret=@calcbasedmg
    @calcbasedmg+=basedmg
    return ret
  end
end

################################################################################
# Hits 2-5 times. (Pin Missile / Arm Thrust / Bullet Seed / Bone Rush / Icicle Spear /
# Tail Slap / Spike Cannon / Fury Swipes / barrage / Double Slap / Fury Attack / 
# Rock Blast / Water Shuriken)
################################################################################
class PokeBattle_Move_0C0 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    hitchances=[2,2,3,3,4,5]
    ret=hitchances[@battle.pbRandom(hitchances.length)]
    ret=5 if attacker.ability == PBAbilities::SKILLLINK
    return ret
  end
end

################################################################################
# Hits X times, where X is the number of unfainted status-free Pokémon in the
# user's party (the participants).  Fails if X is 0.
# Base power of each hit depends on the base Attack stat for the species of that
# hit's participant. (Beat Up)
################################################################################
class PokeBattle_Move_0C1 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    if @participants.nil?
      @participants = @battle.pbPartySingleOwner(attacker.index).find_all {|mon| mon && !mon.isEgg? && mon.hp>0 && mon.status==0}
    end
    return @participants.length
  end

  def pbOnStartUse(attacker)
    party=@battle.pbParty(attacker.index)
    @participants = @battle.pbPartySingleOwner(attacker.index).find_all {|mon| mon && !mon.isEgg? && mon.hp>0 && mon.status==0}
    if @participants.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    mon=@participants.shift
    atk=mon.baseStats[1]
    return 5+(atk/10)
  end
end

################################################################################
# Two turn attack.  Attacks first turn, skips second turn (if successful).
# (Roar of Time / Blast Burn / Frenzy Plant / Giga Impact / Hyper Beam / Rock Wrecher /
# Hydro Cannon / Prismatic Laser)
################################################################################
class PokeBattle_Move_0C2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      attacker.effects[PBEffects::HyperBeam]=2
      attacker.currentMove=@id
    end
    return ret
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn. (Razor Wind)
################################################################################
class PokeBattle_Move_0C3 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (@immediate || attacker.effects[PBEffects::TwoTurnAttack]>0) && showanimation==true
      @battle.pbCommonAnimation("Razor Wind charging",attacker,nil)
      @battle.pbDisplay(_INTL("{1} whipped up a whirlwind!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn. (Solar Beam / Solar Blade)
# Power halved in all weather except sunshine.  In sunshine, takes 1 turn instead.
################################################################################
class PokeBattle_Move_0C4 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if attacker.effects[PBEffects::TwoTurnAttack]==0
      @immediate=true if (@battle.pbWeather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
      @immediate=true if @battle.FE == PBFields::RAINBOWF
    end
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @battle.pbWeather!=0 &&
       @battle.pbWeather!=PBWeather::SUNNYDAY
      return (damagemult*0.5).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Solar Beam charging",attacker,nil)
      @battle.pbDisplay(_INTL("{1} took in sunlight!",attacker.pbThis))
    end
     if @battle.FE == PBFields::DARKCRYSTALC && @battle.pbWeather != PBWeather::SUNNYDAY
        @battle.pbDisplay(_INTL("But it failed...",attacker.pbThis))
        attacker.effects[PBEffects::TwoTurnAttack]=0
      return 0
      else
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
    end
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May paralyze the target. (Freeze Shock)
################################################################################
class PokeBattle_Move_0C5 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Freeze Shock charging",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed! It may be unable to move!",opponent.pbThis))
    return true
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May burn the target. (Ice Burn)
################################################################################
class PokeBattle_Move_0C6 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Ice Burn charging",attacker,nil)
      @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(false)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May make the target flinch. (Sky Attack)
################################################################################
class PokeBattle_Move_0C7 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Sky Attack charging",attacker,nil)
      @battle.pbDisplay(_INTL("{1} is glowing!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end
end

################################################################################
# Two turn attack.  Ups user's Defence by 1 stage first turn, attacks second turn. (Skull Bash)
################################################################################
class PokeBattle_Move_0C8 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Skull Bash charging",attacker,nil)
      @battle.pbDisplay(_INTL("{1} lowered its head!",attacker.pbThis))
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
      end
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Fly)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0C9 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.state.effects[PBEffects::Gravity]>0
  end

  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    @immediate=true if @battle.FE == PBFields::CAVE
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.state.effects[PBEffects::Gravity]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      attacker.effects[PBEffects::TwoTurnAttack] = 0
      return -1
    end
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Fly charging",attacker,nil)
      @battle.scene.pbVanishSprite(attacker)
      @battle.pbDisplay(_INTL("{1} flew up high!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    #@battle.scene.pbUnVanishSprite(attacker)
    return super
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Dig)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CA < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Dig charging",attacker,nil)
      @battle.scene.pbVanishSprite(attacker)
      @battle.scene.pbDisableShadowTemp(attacker)
      @battle.pbDisplay(_INTL("{1} burrowed its way under the ground!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    @battle.scene.pbReAbleShadow(attacker)
    #@battle.scene.pbUnVanishSprite(attacker)
    return super
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Dive)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CB < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    @immediate=true if (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER)
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Dive charging",attacker,nil)
      @battle.scene.pbVanishSprite(attacker)
      @battle.scene.pbDisableShadowTemp(attacker)
      @battle.pbDisplay(_INTL("{1} hid underwater!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    @battle.scene.pbReAbleShadow(attacker)
    return super
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Bounce)
# May paralyze the target.
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CC < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.state.effects[PBEffects::Gravity]>0
  end

  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    @immediate=true if @battle.FE == PBFields::CAVE
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.state.effects[PBEffects::Gravity]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      attacker.effects[PBEffects::TwoTurnAttack] = 0
      return -1
    end
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Bounce charging",attacker,nil)
      @battle.scene.pbVanishSprite(attacker)
      @battle.scene.pbDisableShadowTemp(attacker)
      @battle.pbDisplay(_INTL("{1} sprang up!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    @battle.scene.pbReAbleShadow(attacker)
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed! It may be unable to move!",opponent.pbThis))
    return true
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Shadow Force / Phantom Force)
# Is invulnerable during use.
# If successful, negates target's Detect and Protect this round.
################################################################################
class PokeBattle_Move_0CD < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Shadow Force charging",attacker,nil)
      @battle.scene.pbVanishSprite(attacker)
      @battle.pbDisplay(_INTL("{1} vanished instantly!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    #@battle.scene.pbUnVanishSprite(attacker)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::ProtectNegation]=true if ret>0
    if opponent && !opponent.isFainted? && !opponent.effects[PBEffects::Protect] && !opponent.effects[PBEffects::SpikyShield] &&
       !opponent.effects[PBEffects::KingsShield] && !opponent.effects[PBEffects::Obstruct]
      opponent.effects[PBEffects::ProtectNegation]=true
    elsif (opponent.effects[PBEffects::Protect] || opponent.effects[PBEffects::SpikyShield] || opponent.effects[PBEffects::KingsShield] || opponent.effects[PBEffects::Obstruct]) &&
          (opponent.pbOwnSide.effects[PBEffects::CraftyShield] || opponent.pbOwnSide.effects[PBEffects::WideGuard] || opponent.pbOwnSide.effects[PBEffects::QuickGuard] ||
          opponent.pbOwnSide.effects[PBEffects::MatBlock])
      opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false
      opponent.pbOwnSide.effects[PBEffects::WideGuard]=false
      opponent.pbOwnSide.effects[PBEffects::QuickGuard]=false
      opponent.pbOwnSide.effects[PBEffects::MatBlock]=false
    end
    return ret
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Sky Drop)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
# Target is also semi-invulnerable during use, and can't take any action.
# Doesn't damage airborne Pokémon (but still makes them unable to move during).
################################################################################
class PokeBattle_Move_0CE < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.nil?
      @battle.pbDisplay(_INTL("But it failed!"))
      attacker.effects[PBEffects::TwoTurnAttack] = 0
      attacker.effects[PBEffects::SkyDroppee] = nil
      return -1
    end
    if opponent.weight > 2000
      @battle.pbDisplay(_INTL("The opposing {1} is too heavy to be lifted!", opponent.pbThis))
      attacker.effects[PBEffects::TwoTurnAttack] = 0
      attacker.effects[PBEffects::SkyDroppee] = nil
      return -1
    end
    if opponent.effects[PBEffects::TwoTurnAttack] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      attacker.effects[PBEffects::TwoTurnAttack] = 0
      attacker.effects[PBEffects::SkyDroppee] = nil
      return -1
    end
    if opponent.effects[PBEffects::Protect] || opponent.effects[PBEffects::KingsShield] || opponent.effects[PBEffects::SpikyShield] || opponent.effects[PBEffects::Obstruct]
      @battle.pbDisplay(_INTL("But it failed!"))
      attacker.effects[PBEffects::TwoTurnAttack] = 0
      attacker.effects[PBEffects::SkyDroppee] = nil
      return -1
    end
    if opponent.effects[PBEffects::Substitute] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      attacker.effects[PBEffects::TwoTurnAttack] = 0
      attacker.effects[PBEffects::SkyDroppee] = nil
      return -1
    end
    if @battle.state.effects[PBEffects::Gravity]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      attacker.effects[PBEffects::TwoTurnAttack] = 0
      attacker.effects[PBEffects::SkyDroppee] = nil
      return -1
    end
    if @battle.FE == PBFields::CAVE
      @battle.pbDisplay(_INTL("The cave's low ceiling makes flying high impossible!"))
      attacker.effects[PBEffects::TwoTurnAttack] = 0
      attacker.effects[PBEffects::SkyDroppee] = nil
      return -1
    end
    if attacker.effects[PBEffects::TwoTurnAttack]>0
      if opponent.effects[PBEffects::SkyDrop]
        attacker.effects[PBEffects::TwoTurnAttack] = 0
        attacker.effects[PBEffects::SkyDroppee] = nil
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      @battle.pbCommonAnimation("Sky Drop charging",attacker,opponent)
      @battle.scene.pbVanishSprite(attacker)
      @battle.scene.pbVanishSprite(opponent)
      @battle.pbDisplay(_INTL("{1} took {2} into the sky!",attacker.pbThis, opponent.pbThis))
      @battle.pbClearChoices(opponent.index)
      attacker.effects[PBEffects::SkyDroppee] = opponent
      opponent.effects[PBEffects::SkyDrop] = true
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    #@battle.scene.pbUnVanishSprite(attacker)
    #@battle.scene.pbUnVanishSprite(opponent)
    if opponent.pbHasType?(:FLYING) && opponent.effects[PBEffects::SkyDrop]
      opponent.effects[PBEffects::TwoTurnAttack] = 0
      opponent.effects[PBEffects::SkyDrop]       = false
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", opponent.pbThis))
      return -1
    end
    ret = super
    @battle.pbDisplay(_INTL("{1} is freed from Sky Drop effect!",opponent.pbThis))
    opponent.effects[PBEffects::SkyDrop] = false
    attacker.effects[PBEffects::SkyDroppee] = nil
    return ret
  end
end

################################################################################
# Trapping move.  Traps for 4 or 5 rounds.  Trapped Pokémon lose 1/16 of max HP
# at end of each round. (Magma Storm / Fire Spin / Sand Tomb / Bind / Wrap / Clamp /
# Infestation)
################################################################################
class PokeBattle_Move_0CF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !opponent.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute
      if opponent.effects[PBEffects::MultiTurn]==0
        opponent.effects[PBEffects::MultiTurn]=4+@battle.pbRandom(2)
        opponent.effects[PBEffects::MultiTurn]=7 if attacker.hasWorkingItem(:GRIPCLAW)
        opponent.effects[PBEffects::MultiTurnAttack]=@id
        opponent.effects[PBEffects::MultiTurnUser]=attacker.index
        if (@id == PBMoves::BIND)
          @battle.pbDisplay(_INTL("{1} was squeezed by {2}!",opponent.pbThis,attacker.pbThis(true)))
        elsif (@id == PBMoves::CLAMP)
          @battle.pbDisplay(_INTL("{1} clamped {2}!",attacker.pbThis,opponent.pbThis(true)))
        elsif (@id == PBMoves::FIRESPIN)
          @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
        elsif (@id == PBMoves::MAGMASTORM)
          @battle.pbDisplay(_INTL("{1} was trapped by Magma Storm!",opponent.pbThis))
        elsif (@id == PBMoves::SANDTOMB)
          @battle.pbDisplay(_INTL("{1} was trapped by Sand Tomb!",opponent.pbThis))
        elsif (@id == PBMoves::WRAP)
          @battle.pbDisplay(_INTL("{1} was wrapped by {2}!",opponent.pbThis,attacker.pbThis(true)))
        elsif (@id == PBMoves::INFESTATION)
          @battle.pbDisplay(_INTL("{1} has been afflicted with an infestation by {2}!",opponent.pbThis,attacker.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
        end
        if attacker.hasWorkingItem(:BINDINGBAND)
          $bindingband=1
        else
          $bindingband=0
        end
      end
    end
    return ret
  end
end

################################################################################
# Trapping move- Whirlpool specific.  Traps for 4 or 5 rounds.  Trapped Pokémon lose 1/16 of max HP
# at end of each round. (Whirlpool)
# Power is doubled if target is using Dive.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_0D0 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !opponent.isFainted? && opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      if opponent.effects[PBEffects::MultiTurn]==0
        opponent.effects[PBEffects::MultiTurn]=4+@battle.pbRandom(2)
        opponent.effects[PBEffects::MultiTurn]=5 if attacker.hasWorkingItem(:GRIPCLAW)
        opponent.effects[PBEffects::MultiTurnAttack]=@id
        opponent.effects[PBEffects::MultiTurnUser]=attacker.index
        @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
      end
      if @battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER
        if opponent.pbCanConfuse?(false)
          opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
          @battle.pbCommonAnimation("Confusion",opponent,nil)
          @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
        end
      end
    end
    return ret
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCB # Dive
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# User must use this move for 2 more rounds.  No battlers can sleep. (Uproar)
################################################################################
class PokeBattle_Move_0D1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.effects[PBEffects::Uproar]==0
        attacker.effects[PBEffects::Uproar]=3
        @battle.pbDisplay(_INTL("{1} caused an uproar!",attacker.pbThis))
        attacker.currentMove=@id
      end
    end
    return ret
  end
end

################################################################################
# User must use this move for 1 or 2 more rounds.  At end, user becomes confused.
# (Outrage / Petal Dance / Thrash)
################################################################################
class PokeBattle_Move_0D2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && attacker.effects[PBEffects::Outrage]==0 && attacker.status!=PBStatuses::SLEEP  #TODO: Not likely what actually happens, but good enough
      if attacker.ability == PBAbilities::PARENTALBOND
        attacker.effects[PBEffects::Outrage]=4+(@battle.pbRandom(2)*2)
      else
        attacker.effects[PBEffects::Outrage]=2+@battle.pbRandom(2)
      end
      if @battle.FE == PBFields::SUPERHEATEDF
        attacker.effects[PBEffects::Outrage]=1
      end
      attacker.currentMove=@id
    elsif pbTypeModifier(@type,attacker,opponent)==0
      # Cancel effect if attack is ineffective
      attacker.effects[PBEffects::Outrage]=0
    end
    if attacker.effects[PBEffects::Outrage]>0
      attacker.effects[PBEffects::Outrage]-=1
      if attacker.effects[PBEffects::Outrage]==0 && attacker.pbCanConfuseSelf?(false)
        attacker.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
        @battle.pbCommonAnimation("Confusion",attacker,nil)
        @battle.pbDisplay(_INTL("{1} became confused due to fatigue!",attacker.pbThis))
      end
    end
    return ret
  end
end

################################################################################
# User must use this move for 4 more rounds.  Power doubles each round.
# Power is also doubled if user has curled up. (Rollout / Ice Ball)
################################################################################
class PokeBattle_Move_0D3 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    shift=(4-attacker.effects[PBEffects::Rollout]) # from 0 through 4, 0 is most powerful
    shift+=1 if attacker.effects[PBEffects::DefenseCurl]
    basedmg=basedmg<<shift
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    attacker.effects[PBEffects::Rollout]=5 if attacker.effects[PBEffects::Rollout]==0
    attacker.effects[PBEffects::Rollout]-=1
    attacker.currentMove=thismove.id
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage==0 ||
       pbTypeModifier(@type,attacker,opponent)==0 ||
       attacker.status==PBStatuses::SLEEP  #TODO: Not likely what actually happens, but good enough
      # Cancel effect if attack is ineffective
      attacker.effects[PBEffects::Rollout]=0
    end
    return ret
  end
end

################################################################################
# User bides its time this round and next round.  The round after, deals 2x the
# total damage it took while biding to the last battler that damaged it. (Bide)
################################################################################
class PokeBattle_Move_0D4 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    if attacker.effects[PBEffects::Bide]==0
      @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,name))
      attacker.effects[PBEffects::Bide]=2
      attacker.effects[PBEffects::BideDamage]=0
      attacker.effects[PBEffects::BideTarget]=-1
      attacker.currentMove=@id
      #pbShowAnimation(@id,attacker,nil)
      @battle.pbCommonAnimation("Bide",attacker,nil)
      return 1
    else
      attacker.effects[PBEffects::Bide]-=1
      if attacker.effects[PBEffects::Bide]==0
        @battle.pbDisplayBrief(_INTL("{1} unleashed energy!",attacker.pbThis))
        return 0
      else
        @battle.pbDisplayBrief(_INTL("{1} is storing energy!",attacker.pbThis))
        @battle.pbCommonAnimation("Bide",attacker,nil)
        return 2
      end
    end
  end

  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::BideTarget]>=0
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::BideTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::BideDamage]==0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::BideDamage]*2,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::BideDamage]=0
    return ret
  end
end

################################################################################
# Heals user by 1/2 of its max HP. (Heal Order / Milk Drink / recover / Slack Off / Soft-Boiled)
################################################################################
class PokeBattle_Move_0D5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::FORESTF && (@id == PBMoves::HEALORDER)
      attacker.pbRecoverHP(((attacker.totalhp+1) * 0.66).floor,true)
    else
      attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor,true)
    end
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end

################################################################################
# Heals user by 1/2 of its max HP. (Roost)
# User roosts, and its Flying type is ignored for attacks used against it.
################################################################################
class PokeBattle_Move_0D6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor,true)
    attacker.effects[PBEffects::Roost]=true
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end

################################################################################
# Battler in user's position is healed by 1/2 of its max HP, at the end of the
# next round. (Wish)
################################################################################
class PokeBattle_Move_0D7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Wish]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Wish]=2
    if (@battle.FE == PBFields::MISTYT || @battle.FE == PBFields::RAINBOWF || @battle.FE == PBFields::HOLYF || @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::STARLIGHTA)
      attacker.effects[PBEffects::WishAmount]=((attacker.totalhp+1)*0.75).floor
    else
      attacker.effects[PBEffects::WishAmount]=((attacker.totalhp+1)/2).floor
    end
    attacker.effects[PBEffects::WishMaker]=attacker.pokemonIndex
    return 0
  end
end

################################################################################
# Heals user by an amount depending on the weather. (Synthesis / Moonlight / Morning Sun)
################################################################################
class PokeBattle_Move_0D8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    hpgain=0
    if (@battle.pbWeather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
      hpgain=(attacker.totalhp*2/3.0).floor
    elsif @battle.pbWeather!=0
      hpgain=(attacker.totalhp/4.0).floor
    else
      hpgain=(attacker.totalhp/2.0).floor
      if @battle.FE == PBFields::DARKCRYSTALC || @battle.FE == PBFields::STARLIGHTA || @battle.FE == PBFields::NEWW
        if (@id == PBMoves::MOONLIGHT)
          hpgain=(attacker.totalhp*3/4.0).floor
        else
          hpgain=(attacker.totalhp/4.0).floor
        end
      end
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end

################################################################################
# Heals user to full HP.  User falls asleep for 2 more rounds. (Rest)
################################################################################
class PokeBattle_Move_0D9 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanSleep?(true,true,true) || attacker.status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbSleepSelf(3)
    @battle.pbDisplay(_INTL("{1} slept and became healthy!",attacker.pbThis))
    hp=attacker.pbRecoverHP(attacker.totalhp-attacker.hp,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis)) if hp>0
    return 0
  end
end

################################################################################
# Rings the user.  Ringed Pokémon gain 1/16 of max HP at the end of each round. (Aqua Ring)
################################################################################
class PokeBattle_Move_0DA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::AquaRing]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::AquaRing]=true
    @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Ingrains the user.  Ingrained Pokémon gain 1/16 of max HP at the end of each
# round, and cannot flee or switch out. (Ingrain)
################################################################################
class PokeBattle_Move_0DB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Ingrain]=true
    @battle.pbDisplay(_INTL("{1} planted its roots!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Seeds the target.  Seeded Pokémon lose 1/8 of max HP at the end of each
# round, and the Pokémon in the user's position gains the same amount. (Leech Seed)
################################################################################
class PokeBattle_Move_0DC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::LeechSeed]>=0 ||
       opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1} evaded the attack!",opponent.pbThis))
      return -1
    end
    if opponent.pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    #Now handled elsewhere
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::LeechSeed]=attacker.index
    @battle.pbDisplay(_INTL("{1} was seeded!",opponent.pbThis))
    return 0
  end
end

################################################################################
# User gains half the HP it inflicts as damage. (Leech Life / Drain Punch / Giga Drain /
# Horn Leech / Mega Drain / Absorb / Parabolic Charge)
################################################################################
class PokeBattle_Move_0DD < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=((opponent.damagestate.hplost+1)/2).floor
      if (opponent.abilityWorks?(true) && opponent.ability == PBAbilities::LIQUIDOOZE)
        hpgain*=2 if @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS
        attacker.pbReduceHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
      else
        hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
        attacker.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    return ret
  end
end

################################################################################
# User gains half the HP it inflicts as damage. (Dream Eater)
# (Handled in Battler's pbSuccessCheck): Fails if target is not asleep.
################################################################################
class PokeBattle_Move_0DE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=((opponent.damagestate.hplost+1)/2).floor
      hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
      attacker.pbRecoverHP(hpgain,true)
      @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
    end
    return ret
  end
end

################################################################################
# Heals target by 1/2 of its max HP. (Heal Pusle)
################################################################################
class PokeBattle_Move_0DF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.hp==opponent.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",opponent.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    hpgain=((opponent.totalhp+1)/2).floor
    if (attacker.ability == PBAbilities::MEGALAUNCHER)
      hpgain=((opponent.totalhp+1)/1.33).floor
    end
    opponent.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",opponent.pbThis))
    return 0
  end
end

################################################################################
# User faints. (Explosion / Self-Destruct)
################################################################################
class PokeBattle_Move_0E0 < PokeBattle_Move
  def pbOnStartUse(attacker)
    bearer=@battle.pbCheckGlobalAbility(:DAMP)
    if @battle.FE == PBFields::MISTYT ||  @battle.FE == PBFields::SWAMPF
      @battle.pbDisplay(_INTL("The dampness prevents the {1}!",@name))
      return false
    elsif bearer && !(bearer.moldbroken)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
         bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
      return false
    end
    @battle.pbAnimation(@id,attacker,nil)
    pbShowAnimation(@id,attacker,nil)
    attacker.pbReduceHP(attacker.hp)
    return true
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return
  end
end

################################################################################
# Inflicts fixed damage equal to user's current HP.
# User faints (if successful). (Final Gambit)
################################################################################
class PokeBattle_Move_0E1 < PokeBattle_Move
  def pbMoveFailed(attacker, opponent)
    if opponent.effects[PBEffects::Protect]
      return true
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbMoveFailed(attacker, opponent)
      @battle.pbDisplay(_INTL("#{opponent.pbThis} protected itself!"))
      return -1
    end
    if opponent.pbHasType?(:GHOST)
      @battle.pbDisplay(_INTL("It doesn't affect foe #{opponent.pbThis}!"))
     return -1
    end
    ret = pbEffectFixedDamage(attacker.hp,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbReduceHP(attacker.hp)
    return ret
  end
end

################################################################################
# Decreases the target's Attack and Special Attack by 2 stages each.
# User faints (even if effect does nothing). (Memento)
################################################################################
class PokeBattle_Move_0E2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=-1; prevented=false
    if opponent.effects[PBEffects::Protect] &&
       !opponent.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} protected itself!",opponent.pbThis))
      @battle.successStates[attacker.index].protected=true
      prevented=true
    end
    if !prevented && opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      prevented=true
    end
    if !prevented && (((opponent.ability == PBAbilities::CLEARBODY ||
       opponent.ability == PBAbilities::WHITESMOKE) && !(opponent.moldbroken)) || opponent.ability == PBAbilities::FULLMETALBODY)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      prevented=true
    end
    if !prevented && opponent.pbTooLow?(PBStats::ATTACK) &&
       opponent.pbTooLow?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
      prevented=true
    end
    if !prevented
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      showanim=true
      if opponent.pbReduceStat(PBStats::ATTACK,2,abilitymessage:false, statdropper: attacker)
        ret=0; showanim=false
      end
      if opponent.pbReduceStat(PBStats::SPATK,2,abilitymessage:false, statdropper: attacker)
        ret=0; showanim=false
      end
    end
    attacker.pbReduceHP(attacker.hp) # User still faints even if protected by above effects
    return ret
  end
end

################################################################################
# User faints.  The Pokémon that replaces the user is fully healed (HP and
# status).  Fails if user won't be replaced. (Healing Wish)
################################################################################
class PokeBattle_Move_0E3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP(attacker.hp)
    attacker.effects[PBEffects::HealingWish]=true
    attacker.pbFaint if attacker.isFainted?
    return 0
  end
end

################################################################################
# User faints.  The Pokémon that replaces the user is fully healed (HP, PP and
# status).  Fails if user won't be replaced. (Lunar Dance)
################################################################################
class PokeBattle_Move_0E4 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP(attacker.hp)
    attacker.effects[PBEffects::LunarDance]=true
    attacker.pbFaint if attacker.isFainted?
    return 0
  end
end

################################################################################
# All current battlers will perish after 3 more rounds. (Perish Song)
################################################################################
class PokeBattle_Move_0E5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    failed=true
    for i in 0...4
      if @battle.battlers[i].effects[PBEffects::PerishSong]==0 &&
         (@battle.battlers[i].ability != PBAbilities::SOUNDPROOF || @battle.battlers[i].moldbroken)
        failed=false; break
      end
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("All Pokémon hearing the song will faint in three turns!"))
    for i in 0...4
      if @battle.battlers[i].effects[PBEffects::PerishSong]==0
        if @battle.battlers[i].ability == PBAbilities::SOUNDPROOF && !(@battle.battlers[i].moldbroken)
          @battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",@battle.battlers[i].pbThis,
             PBAbilities.getName(@battle.battlers[i].ability),@name))
        else
          @battle.battlers[i].effects[PBEffects::PerishSong]=4
          @battle.battlers[i].effects[PBEffects::PerishSongUser]=attacker.index
        end
      end
    end
    return 0
  end
end

################################################################################
# If user is KO'd before it next moves, the attack that caused it loses all PP. (Grudge)
################################################################################
class PokeBattle_Move_0E6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Grudge]=true
    @battle.pbDisplay(_INTL("{1} wants its target to bear a grudge!",attacker.pbThis))
    return 0
  end
end

################################################################################
# If user is KO'd before it next moves, the battler that caused it also faints. (Destiny Bond)
################################################################################
class PokeBattle_Move_0E7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.previousMove == PBMoves::DESTINYBOND && attacker.effects[PBEffects::DestinyRate] == true
      attacker.effects[PBEffects::DestinyRate] = false
    else
      attacker.effects[PBEffects::DestinyRate] = true
    end
    if attacker.effects[PBEffects::DestinyRate]
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      attacker.effects[PBEffects::DestinyBond] = true
      @battle.pbDisplay(_INTL("{1} is trying to take its foe down with it!",attacker.pbThis))
      return 0
    else
      attacker.effects[PBEffects::DestinyRate] = false
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# If user would be KO'd this round, it survives with 1HP instead. (Endure)
################################################################################
class PokeBattle_Move_0E8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !PBStuff::RATESHARERS.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority = @battle.pbPriority
    if (@battle.doublebattle && attacker == priority[3]) || (!@battle.doublebattle && attacker == priority[1])
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbRandom(65536)<(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::Endure]=true
      attacker.effects[PBEffects::ProtectRate]*=3
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} braced itself!",attacker.pbThis))
      return 0
    else
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# If target would be KO'd by this attack, it survives with 1HP instead. (False Swipe)
################################################################################
class PokeBattle_Move_0E9 < PokeBattle_Move
# Handled in superclass, do not edit!
end

################################################################################
# User flees from battle.  Fails in trainer battles. (Teleport)
################################################################################
class PokeBattle_Move_0EA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    elsif @battle.pbCanRun?(attacker.index)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      pbSEPlay("escape",100)
      @battle.pbDisplay(_INTL("{1} fled from battle!",attacker.pbThis))
      @battle.decision=3
      return 0
    else
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# Target flees from battle. In trainer battles, target switches out instead.
# Fails if target is a higher level than the user. For status moves. (Roar / Whirlwind)
################################################################################
class PokeBattle_Move_0EB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (@id == PBMoves::ROAR) && @battle.FE == PBFields::SWAMPF
      @battle.pbDisplay(_INTL("What are ya doin' in my swamp?!"))
    end
    if (opponent.ability == PBAbilities::SUCTIONCUPS) && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("{1} anchored itself with {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
      return -1
    end
    if opponent.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",opponent.pbThis))
      return -1
    end
    if !@battle.opponent
      if opponent.level>=attacker.level
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.decision=3 # Set decision to escaped
      return 0
    else
      choices=[]
      party=@battle.pbParty(opponent.index)
      for i in 0...party.length
        choices[choices.length]=i if @battle.pbCanSwitchLax?(opponent.index,i,false)
      end
      if choices.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        opponent.forcedSwitch = true
      return 0
    end
  end
end

################################################################################
# Target flees from battle.  In trainer battles, target switches out instead.
# Fails if target is a higher level than the user.  For damaging moves. (Dragon Tail / Circle Throw)
################################################################################
class PokeBattle_Move_0EC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    opponent.vanished=true
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && !opponent.isFainted? &&
     opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
     (opponent.ability != PBAbilities::SUCTIONCUPS || opponent.moldbroken) &&
     !opponent.effects[PBEffects::Ingrain] && !(attacker.ability == PBAbilities::PARENTALBOND && hitnum==0)
      if !@battle.opponent
        if !(opponent.level>attacker.level)
          @battle.decision=3 # Set decision to escaped
        else
          opponent.vanished=false
          @battle.pbCommonAnimation("Fade in",opponent,nil)
        end
      else
        choices=[]
        party=@battle.pbParty(opponent.index)
        for i in 0..party.length-1
          choices[choices.length]=i if @battle.pbCanSwitchLax?(opponent.index,i,false)
        end
        if choices.length>0
         # pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
         #@battle.pbCommonAnimation("Fade in",opponent,nil)
          opponent.forcedSwitch = true
        else
          opponent.vanished=false
          @battle.pbCommonAnimation("Fade in",opponent,nil)
        end
      end
    else
      opponent.vanished=false
    end
    return ret
  end
end

################################################################################
# User switches out.  Various effects affecting the user are passed to the
# replacement. (Baton Pass)
################################################################################
class PokeBattle_Move_0ED < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    #attacker.vanished=true
    if !@battle.pbCanChooseNonActive?(attacker.index)
      #attacker.vanished=false
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    newpoke=0
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    newpoke=@battle.pbSwitchInBetween(attacker.index,true,false)
    @battle.pbMessagesOnReplace(attacker.index,newpoke)
    attacker.pbResetForm
    @battle.pbReplace(attacker.index,newpoke,true)
    @battle.pbOnActiveOne(attacker)
    attacker.pbAbilitiesOnSwitchIn(true)
    return 0
  end
end

################################################################################
# After inflicting damage, user switches out.  Ignores trapping moves.(U-turn, Volt Switch)
################################################################################
class PokeBattle_Move_0EE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    attacker.vanished=true
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && @battle.pbCanChooseNonActive?(attacker.index) &&
       !@battle.pbAllFainted?(@battle.pbParty(opponent.index)) && !(attacker.ability == PBAbilities::PARENTALBOND && hitnum==0)

      if !opponent.hasWorkingItem(:EJECTBUTTON)
        attacker.userSwitch = true if pbTypeModifier(@type,attacker,opponent)!=0 && !(@battle.FE == PBFields::INVERSEF)
      else
        attacker.vanished=false
      end
      if @battle.FE == PBFields::INVERSEF && !opponent.hasWorkingItem(:EJECTBUTTON)
        attacker.userSwitch = true
      else
        attacker.vanished=false
      end
      if @id == PBMoves::VOLTSWITCH && (opponent.ability == PBAbilities::MOTORDRIVE ||
        opponent.ability == PBAbilities::VOLTABSORB || 
        opponent.ability == PBAbilities::LIGHTNINGROD)
        attacker.userSwitch = false
        attacker.vanished=false
      end
      #Going to switch, check for pursuit
      if attacker.userSwitch
        for j in @battle.priority
          next if !attacker.pbIsOpposing?(j.index)
          # if Pursuit and this target was chosen
          if !j.hasMovedThisRound? && @battle.pbChoseMoveFunctionCode?(j.index,0x88) && !j.effects[PBEffects::Pursuit] && (@battle.choices[j.index][3]!=j.pbPartner.index)
            attacker.vanished=false
            @battle.pbCommonAnimation("Fade in",attacker,nil)
            newpoke=@battle.pbPursuitInterrupt(j,attacker)
          end
          break if attacker.isFainted?
        end
      end
    else
      attacker.vanished=false
      @battle.pbCommonAnimation("Fade in",attacker,nil)
    end
    return ret
  end
end

################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
# (Spider Web / Block / Mean Look)
################################################################################
class PokeBattle_Move_0EF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::MeanLook]>=0 ||
       opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::MeanLook]=attacker.index
    @battle.pbDisplay(_INTL("{1} can't escape now!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Target drops its item.  It regains the item at the end of the battle. (Knock Off)
################################################################################
class PokeBattle_Move_0F0 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && opponent.item!=0
      if opponent.hasWorkingItem(:ROCKYHELMET,true) && attacker.ability != PBAbilities::MAGICGUARD &&
        !(opponent.ability == PBAbilities::STICKYHOLD && !(opponent.moldbroken))
        @battle.scene.pbDamageAnimation(attacker,0)
        attacker.pbReduceHP((attacker.totalhp/6.0).floor)
        @battle.pbDisplay(_INTL("{1} was hurt by the {2}!",attacker.pbThis,
        PBItems.getName(opponent.item)))
        if attacker.hp<=0
          return ret
        end
      end      
      if opponent.ability == PBAbilities::STICKYHOLD && !(opponent.moldbroken)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      elsif !@battle.pbIsUnlosableItem(opponent,opponent.item) && !(attacker.ability == PBAbilities::PARENTALBOND && hitnum==0)
        # Items that still work before being knocked of
        if opponent.item==PBItems::WEAKNESSPOLICY && opponent.damagestate.typemod>4 && opponent.hp > 0
          if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK)
            opponent.pbIncreaseStatBasic(PBStats::ATTACK,2)
            @battle.pbCommonAnimation("StatUp",opponent,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Attack!", opponent.pbThis,PBItems.getName(opponent.item)))
            opponent.pbDisposeItem(false)
          end
          if opponent.pbCanIncreaseStatStage?(PBStats::SPATK)
            opponent.pbIncreaseStatBasic(PBStats::SPATK,2)
            @battle.pbCommonAnimation("StatUp",opponent,nil)
            @battle.pbDisplay(_INTL("{1}'s Weakness Policy sharply raised its Special Attack!", opponent.pbThis,PBItems.getName(opponent.item)))
            opponent.pbDisposeItem(false)
          end
        end
        opponent.effects[PBEffects::ChoiceBand]=-1
        if opponent != 0
          # Knocking of the item
          itemname=PBItems.getName(opponent.item)
          opponent.item=0
          @battle.pbDisplay(_INTL("{1} knocked off {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
        end
      end
    end
    return ret
  end
end

################################################################################
# User steals the target's item, if the user has none itself. (Thief / Covet)
# Items stolen from wild Pokémon are kept after the battle.
################################################################################
class PokeBattle_Move_0F1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && opponent.item!=0
      if opponent.ability == PBAbilities::STICKYHOLD && !(opponent.moldbroken)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      elsif !@battle.pbIsUnlosableItem(opponent,opponent.item) &&
            !@battle.pbIsUnlosableItem(attacker,opponent.item) &&
            attacker.item==0 &&
            (@battle.opponent || !@battle.pbIsOpposing?(attacker.index))
        itemname=PBItems.getName(opponent.item)
        attacker.item=opponent.item
        opponent.item=0
        opponent.effects[PBEffects::ChoiceBand]=-1
        # In a wild battle
        if !@battle.opponent && attacker.pokemon.itemInitial==0 && opponent != attacker.pbPartner && opponent.pokemon.itemInitial==attacker.item
          attacker.pokemon.itemInitial=attacker.item
          attacker.pokemon.itemReallyInitialHonestlyIMeanItThisTime=attacker.item
          opponent.pokemon.itemInitial=0
        end
        if (@id == PBMoves::THIEF)
          @battle.pbCommonAnimation("Thief",attacker,opponent)
        else
          @battle.pbCommonAnimation("Covet",attacker,opponent)
        end
        @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
      end
    end
    return ret
  end
end

################################################################################
# User and target swap items.  They remain swapped after the battle. (Trick / Switcheroo)
################################################################################
class PokeBattle_Move_0F2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (attacker.item==0 && opponent.item==0) ||
       (!@battle.opponent && @battle.pbIsOpposing?(attacker.index))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbIsUnlosableItem(opponent,opponent.item) ||
       @battle.pbIsUnlosableItem(attacker,opponent.item) ||
       @battle.pbIsUnlosableItem(opponent,attacker.item) ||
       @battle.pbIsUnlosableItem(attacker,attacker.item)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.ability == PBAbilities::STICKYHOLD && !(opponent.moldbroken)
      abilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,name))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldattitem=attacker.item
    oldoppitem=opponent.item
    oldattitemname=PBItems.getName(oldattitem)
    oldoppitemname=PBItems.getName(oldoppitem)
    tmpitem=attacker.item
    attacker.item=opponent.item
    opponent.item=tmpitem
    if !@battle.opponent && # In a wild battle
       attacker.pokemon.itemInitial==oldattitem &&
       opponent.pokemon.itemInitial==oldoppitem
      attacker.pokemon.itemInitial=oldoppitem
      attacker.pokemon.itemReallyInitialHonestlyIMeanItThisTime=oldoppitem
      opponent.pokemon.itemInitial=oldattitem
      opponent.pokemon.itemReallyInitialHonestlyIMeanItThisTime=oldattitem
    end
    @battle.pbDisplay(_INTL("{1} switched items with its opponent!",attacker.pbThis))
    if oldoppitem>0 && oldattitem>0
      @battle.pbDisplay(_INTL("{1} obtained {2}.",attacker.pbThis,oldoppitemname))
      @battle.pbDisplay(_INTL("{1} obtained {2}.",opponent.pbThis,oldattitemname))
    else
      @battle.pbDisplay(_INTL("{1} obtained {2}.",attacker.pbThis,oldoppitemname)) if oldoppitem>0
      @battle.pbDisplay(_INTL("{1} obtained {2}.",opponent.pbThis,oldattitemname)) if oldattitem>0
    end
    if oldattitem!=oldoppitem # TODO: Not exactly correct
      attacker.effects[PBEffects::ChoiceBand]=-1
    end
    opponent.effects[PBEffects::ChoiceBand]=-1
    return 0
  end
end

################################################################################
# User gives its item to the target.  The item remains given after the battle. (Bestow)
################################################################################
class PokeBattle_Move_0F3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.item==0 || opponent.item!=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbIsUnlosableItem(attacker,attacker.item) ||
       @battle.pbIsUnlosableItem(opponent,attacker.item)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    itemname=PBItems.getName(attacker.item)
    opponent.item=attacker.item
    attacker.item=0
    attacker.effects[PBEffects::ChoiceBand]=-1
    if !@battle.opponent && # In a wild battle
       opponent.pokemon.itemInitial==0 &&
       attacker.pokemon.itemInitial==opponent.item
      opponent.pokemon.itemInitial=opponent.item
      opponent.pokemon.itemReallyInitialHonestlyIMeanItThisTime=opponent.item
      attacker.pokemon.itemInitial=0
    end
    @battle.pbDisplay(_INTL("{1} received {2} from {3}!",opponent.pbThis,itemname,attacker.pbThis(true)))
    return 0
  end
end

################################################################################
# User consumes target's berry and gains its effect. (Bug Bite / Pluck)
################################################################################
class PokeBattle_Move_0F4 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && pbIsBerry?(opponent.item) && !(attacker.ability == PBAbilities::PARENTALBOND && hitnum==0)
      if opponent.ability == PBAbilities::STICKYHOLD && !(opponent.moldbroken)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      else
        item=opponent.item
        itemname=PBItems.getName(item)
        opponent.item=0
        opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==item
        @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!",attacker.pbThis,itemname))
        if attacker.ability != PBAbilities::KLUTZ && attacker.effects[PBEffects::Embargo]==0
           attacker.pbUseBerry(item,true)
          # Get berry's effect here
        end
      end
    end
    return ret
  end
end

################################################################################
# Target's berry is destroyed. (Incinerate)
################################################################################
class PokeBattle_Move_0F5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && (pbIsBerry?(opponent.item) || pbIsTypeGem?(opponent.item))
      item=opponent.item
      itemname=PBItems.getName(item)
      opponent.item=0
      opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==item
      @battle.pbDisplay(_INTL("{1}'s {2} was incinerated!",opponent.pbThis,itemname))
    end
    return ret
  end
end

################################################################################
# User recovers the last item it held and consumed. (Recycle)
################################################################################
class PokeBattle_Move_0F6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pokemon.itemRecycle==0 || attacker.item != 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    item=attacker.pokemon.itemRecycle
    itemname=PBItems.getName(item)
    attacker.item=item
    attacker.pokemon.itemInitial=item if (attacker.pokemon.itemInitial==0 && item == attacker.pokemon.itemReallyInitialHonestlyIMeanItThisTime)
    attacker.pokemon.itemRecycle=0
    @battle.pbDisplay(_INTL("{1} found one {2}!",attacker.pbThis,itemname))
    return 0
  end
end

################################################################################
# User flings its item at the target.  Power and effect depend on the item. (Fling)
################################################################################
class PokeBattle_Move_0F7 < PokeBattle_Move

  def pbMoveFailed(attacker,opponent)
    return true if attacker.item==0 ||
                   @battle.pbIsUnlosableItem(attacker,attacker.item) ||
                   pbIsPokeBall?(attacker.item) ||
                   attacker.ability == PBAbilities::KLUTZ ||
                   attacker.effects[PBEffects::Embargo]>0
    return false if PBStuff::FLINGDAMAGE[attacker.item]
    return false if pbIsBerry?(attacker.item)
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return PBStuff::FLINGDAMAGE[attacker.item] if PBStuff::FLINGDAMAGE[attacker.item]
    return 10 if pbIsBerry?(attacker.item)
    return 1
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.item==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return 0
    end
    if !opponent.effects[PBEffects::Protect]
      @battle.pbDisplay(_INTL("{1} flung its {2}!",attacker.pbThis,PBItems.getName(attacker.item)))
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       (opponent.ability != PBAbilities::SHIELDDUST || opponent.moldbroken)
      if @item.pbGetPocket(attacker.item) ==5
        @battle.pbDisplay(_INTL("{1} ate the {2}!",opponent.pbThis,PBItems.getName(attacker.item)))
        opponent.pbUseBerry(attacker.item,true)
      end
      if attacker.hasWorkingItem(:FLAMEORB)
        if opponent.pbCanBurn?(false)
          opponent.pbBurn(attacker)
          @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
        end
      elsif attacker.hasWorkingItem(:KINGSROCK) ||
            attacker.hasWorkingItem(:RAZORFANG)
        if opponent.ability != PBAbilities::INNERFOCUS && !opponent.damagestate.substitute
          opponent.effects[PBEffects::Flinch]=true
        end
      elsif attacker.hasWorkingItem(:LIGHTBALL)
         if opponent.pbCanParalyze?(false)
          opponent.pbParalyze(attacker)
          @battle.pbDisplay(_INTL("{1} was paralyzed! It may be unable to move!",opponent.pbThis))
        end
      elsif attacker.hasWorkingItem(:MENTALHERB)
        if opponent.effects[PBEffects::Attract]>=0
          opponent.effects[PBEffects::Attract]=-1
          @battle.pbDisplay(_INTL("{1}'s {2} cured {3}'s love problem!",
             attacker.pbThis,PBItems.getName(attacker.item),opponent.pbThis(true)))
        end
      elsif attacker.hasWorkingItem(:POISONBARB)
        if opponent.pbCanPoison?(false)
          opponent.pbPoison(attacker)
          @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
        end
      elsif attacker.hasWorkingItem(:TOXICORB)
        if opponent.pbCanPoison?(false)
          opponent.pbPoison(attacker,true)
          @battle.pbDisplay(_INTL("{1} was badly poisoned!",opponent.pbThis))
        end
      elsif attacker.hasWorkingItem(:WHITEHERB)
        while true
          reducedstats=false
          for i in [PBStats::ATTACK,PBStats::DEFENSE,
                    PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                    PBStats::EVASION,PBStats::ACCURACY]
            if opponent.stages[i]<0
              opponent.stages[i]=0; reducedstats=true
            end
          end
          break if !reducedstats
          @battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s status!",
             attacker.pbThis,PBItems.getName(attacker.item),opponent.pbThis(true)))
        end
      end
    end
    attacker.pbDisposeItem(false)
    return ret
  end
end

################################################################################
# For 5 rounds, the target cannnot use its held item, its held item has no
# effect, and no items can be used on it. (Embargo)
################################################################################
class PokeBattle_Move_0F8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Embargo]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Embargo]=5
    @battle.pbDisplay(_INTL("{1} can't use items anymore!",opponent.pbThis))
    return 0
  end
end

################################################################################
# For 5 rounds, all held items cannot be used in any way and have no effect.
# Held items can still change hands, but can't be thrown. (Magic Room)
################################################################################
class PokeBattle_Move_0F9 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.state.effects[PBEffects::MagicRoom]>0
      @battle.state.effects[PBEffects::MagicRoom]=0
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.pbDisplay(_INTL("The area returned to normal!"))
    else
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.state.effects[PBEffects::MagicRoom]=5
      if @battle.FE == PBFields::NEWW || @battle.FE == PBFields::PSYCHICT || # New World
       (attacker.item == PBItems::AMPLIFIELDROCK)
              @battle.state.effects[PBEffects::MagicRoom]=8
      end
      @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
    end
    return 0
  end
end

################################################################################
# User takes recoil damage equal to 1/4 of the damage this move dealt. (Wild Charge /
# Submission / Head Charge / Take Down)
################################################################################
class PokeBattle_Move_0FA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       attacker.ability != PBAbilities::ROCKHEAD &&
       attacker.ability != PBAbilities::MAGICGUARD &&
       !(@id == PBMoves::WILDCHARGE && @battle.FE == PBFields::ELECTRICT)
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+2)/4).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end
end

################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt. (Brave Bird /
# Double-Edge / Wood Hammer)
################################################################################
class PokeBattle_Move_0FB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       attacker.ability != PBAbilities::ROCKHEAD &&
       attacker.ability != PBAbilities::MAGICGUARD
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+1)/3).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end
end

################################################################################
# User takes recoil damage equal to 1/2 of the damage this move dealt. (Head Smach)
################################################################################
class PokeBattle_Move_0FC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       attacker.ability != PBAbilities::ROCKHEAD &&
       attacker.ability != PBAbilities::MAGICGUARD
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+1)/2).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end
end

################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May paralyze the target. (Volt Tackle)
################################################################################
class PokeBattle_Move_0FD < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       attacker.ability != PBAbilities::ROCKHEAD &&
       attacker.ability != PBAbilities::MAGICGUARD
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+1)/3).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed! It may be unable to move!",opponent.pbThis))
    return true
  end
end

################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May burn the target. (Flare Blitz)
################################################################################
class PokeBattle_Move_0FE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       attacker.ability != PBAbilities::ROCKHEAD &&
       attacker.ability != PBAbilities::MAGICGUARD
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+1)/3).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(false)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end

################################################################################
# Starts sunny weather. (Sunny Day)
################################################################################
class PokeBattle_Move_0FF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.state.effects[PBEffects::HeavyRain]
      @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      return -1
    elsif @battle.state.effects[PBEffects::HarshSunlight]
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    elsif @battle.weather==PBWeather::STRONGWINDS && (@battle.pbCheckGlobalAbility(:DELTASTREAM)) 
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    end

    if @battle.weather==PBWeather::SUNNYDAY
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.FE == PBFields::NEWW || @battle.FE == PBFields::UNDERWATER
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end

    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)

    rainbowhold=0
    if @battle.weather==PBWeather::RAINDANCE
      rainbowhold=5
      if (attacker.item == PBItems::HEATROCK) || @battle.FE == PBFields::DESERTF
        rainbowhold=8
      end
    end

    @battle.weather=PBWeather::SUNNYDAY
    @battle.weatherduration=5
    @battle.weatherduration=8 if (attacker.item == PBItems::HEATROCK) || @battle.FE == PBFields::DESERTF || @battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM

    @battle.pbCommonAnimation("Sunny",nil,nil)
    @battle.pbDisplay("The sunlight turned harsh!")
    @battle.pbDisplay("The sunlight eclipsed the starry sky!") if @battle.FE == PBFields::STARLIGHTA
    
    if rainbowhold != 0
      fieldbefore = @battle.FE
      @battle.setField(PBFields::RAINBOWF,true)
      if fieldbefore != PBFields::RAINBOWF
        @battle.pbDisplay(_INTL("The weather created a rainbow!"))
      else
        @battle.pbDisplay(_INTL("The weather refreshed the rainbow!"))
      end
      @battle.field.duration= rainbowhold
    end
    return 0
  end
end

################################################################################
# Starts rainy weather. (Rain Dance)
################################################################################
class PokeBattle_Move_100 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)

    if @battle.state.effects[PBEffects::HeavyRain]
      @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      return -1
    elsif @battle.state.effects[PBEffects::HarshSunlight]
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    elsif @battle.weather==PBWeather::STRONGWINDS && (@battle.pbCheckGlobalAbility(:DELTASTREAM))
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    end

    if @battle.weather==PBWeather::RAINDANCE
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.FE == PBFields::NEWW || @battle.FE == PBFields::UNDERWATER
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end

    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)

    rainbowhold=0
    if @battle.weather==PBWeather::SUNNYDAY
      rainbowhold=5
      rainbowhold=8 if (attacker.item == PBItems::DAMPROCK) || @battle.FE == PBFields::BIGTOPA
    end
    @battle.weather=PBWeather::RAINDANCE
    @battle.weatherduration=5
    @battle.weatherduration=8 if (attacker.item == PBItems::DAMPROCK) || @battle.FE == PBFields::BIGTOPA

    @battle.pbCommonAnimation("Rain",nil,nil)
    @battle.pbDisplay(_INTL("It started to rain!"))
    @battle.pbDisplay(_INTL("The weather blocked out the starry sky!")) if @battle.FE == PBFields::STARLIGHTA
    if rainbowhold != 0
      fieldbefore = @battle.FE
      @battle.setField(PBFields::RAINBOWF,true)
      if fieldbefore != PBFields::RAINBOWF
        @battle.pbDisplay(_INTL("The weather created a rainbow!"))
      else
        @battle.pbDisplay(_INTL("The weather refreshed the rainbow!"))
      end
      @battle.field.duration= rainbowhold
    end
    return 0
  end
end

################################################################################
# Starts sandstorm weather. (Sandstorm)
################################################################################
class PokeBattle_Move_101 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)

    if @battle.state.effects[PBEffects::HeavyRain]
      @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      return -1
    elsif @battle.state.effects[PBEffects::HarshSunlight]
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    elsif @battle.weather==PBWeather::STRONGWINDS && (@battle.pbCheckGlobalAbility(:DELTASTREAM)) 
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    end

    if @battle.weather==PBWeather::SANDSTORM
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.FE == PBFields::NEWW || @battle.FE == PBFields::UNDERWATER
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end

    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)

    @battle.weather=PBWeather::SANDSTORM
    @battle.weatherduration=5
    @battle.weatherduration=8 if (attacker.item == PBItems::SMOOTHROCK) || @battle.FE == PBFields::DESERTF || @battle.FE == PBFields::ASHENB

    @battle.pbCommonAnimation("Sandstorm",nil,nil)
    @battle.pbDisplay(_INTL("A sandstorm brewed!"))
    @battle.pbDisplay(_INTL("The weather blocked out the starry sky!")) if @battle.FE == PBFields::STARLIGHTA
    return 0
  end
end

################################################################################
# Starts hail weather. (Hail)
################################################################################
class PokeBattle_Move_102 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)

    if @battle.state.effects[PBEffects::HeavyRain]
      @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      return -1
    elsif @battle.state.effects[PBEffects::HarshSunlight]
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    elsif @battle.weather==PBWeather::STRONGWINDS && (@battle.pbCheckGlobalAbility(:DELTASTREAM)) 
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    end

    if @battle.weather==PBWeather::HAIL
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.FE == PBFields::NEWW || @battle.FE == PBFields::UNDERWATER
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end

    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)

    @battle.weather=PBWeather::HAIL
    @battle.weatherduration=5
    @battle.weatherduration=8 if (attacker.item == PBItems::ICYROCK) || @battle.FE == PBFields::ICYF || @battle.FE == PBFields::SNOWYM

    @battle.pbCommonAnimation("Hail",nil,nil)
    @battle.pbDisplay(_INTL("It started to hail!"))
    @battle.pbDisplay(_INTL("The weather blocked out the starry sky!")) if @battle.FE == PBFields::STARLIGHTA

    for facemon in @battle.battlers
      if facemon.species==PBSpecies::EISCUE && facemon.form==1 # Eiscue
        facemon.pbRegenFace
        @battle.pbDisplay(_INTL("{1} transformed!",facemon.name))
      end
    end
    return 0
  end
end

################################################################################
# Entry hazard.  Lays spikes on the opposing side (max. 3 layers). (Spikes)
################################################################################
class PokeBattle_Move_103 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::Spikes]>=3
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    elsif @battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS
      @battle.pbDisplay(_INTL("...The spikes sank into the water and vanished!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...4
      next if !(attacker.pbIsOpposing?(i))
      if (@battle.battlers[i].ability == PBAbilities::MAGICBOUNCE && !PBStuff::TWOTURNMOVE.include?(@battle.battlers[i].effects[PBEffects::TwoTurnAttack])) || 
        (@battle.battlers[i]).effects[PBEffects::MagicCoat]
         attacker.pbOwnSide.effects[PBEffects::Spikes]+=1 if attacker.pbOwnSide.effects[PBEffects::Spikes]<3
         @battle.pbDisplay(_INTL("{1} bounced the Spikes back!",(@battle.battlers[i]).pbThis))
         if @battle.pbIsOpposing?(attacker.index)
             @battle.pbDisplay(_INTL("Spikes were scattered all around the foe's team's feet!"))
         else
             @battle.pbDisplay(_INTL("Spikes were scattered all around your team's feet!"))
         end
       return 0
       break
      end
    end
    attacker.pbOpposingSide.effects[PBEffects::Spikes]+=1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Spikes were scattered all around the feet of the foe's team!"))
    else
      @battle.pbDisplay(_INTL("Spikes were scattered all around the feet of your team!"))
    end
    return 0
  end
end

################################################################################
# Entry hazard.  Lays poison spikes on the opposing side (max. 2 layers). (Toxic Spikes)
################################################################################
class PokeBattle_Move_104 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    elsif @battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS
      @battle.pbDisplay(_INTL("...The spikes sank into the water and vanished!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...4
      next if !(attacker.pbIsOpposing?(i))
      if (@battle.battlers[i].ability == PBAbilities::MAGICBOUNCE && !PBStuff::TWOTURNMOVE.include?(@battle.battlers[i].effects[PBEffects::TwoTurnAttack])) || 
        (@battle.battlers[i]).effects[PBEffects::MagicCoat]
         attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]+=1 if attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]<2
         @battle.pbDisplay(_INTL("{1} bounced the Toxic Spikes back!",(@battle.battlers[i]).pbThis))
         if @battle.pbIsOpposing?(attacker.index)
             @battle.pbDisplay(_INTL("Poison spikes were scattered all around the foe's team's feet!"))
         else
             @battle.pbDisplay(_INTL("Poison spikes were scattered all around your team's feet!"))
         end
       return 0
       break
      end
    end
    attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]+=1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Poison spikes were scattered all around the foe's team's feet!"))
    else
      @battle.pbDisplay(_INTL("Poison spikes were scattered all around your team's feet!"))
    end
    return 0
  end
end

################################################################################
# Entry hazard.  Lays stealth rocks on the opposing side. (Stealth Rock)
################################################################################
class PokeBattle_Move_105 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::StealthRock]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...4
      next if !(attacker.pbIsOpposing?(i))
      if (@battle.battlers[i].ability == PBAbilities::MAGICBOUNCE && !PBStuff::TWOTURNMOVE.include?(@battle.battlers[i].effects[PBEffects::TwoTurnAttack])) || 
        (@battle.battlers[i]).effects[PBEffects::MagicCoat]
         attacker.pbOwnSide.effects[PBEffects::StealthRock]=true
         @battle.pbDisplay(_INTL("{1} bounced the Stealth Rocks back!",(@battle.battlers[i]).pbThis))
         if @battle.pbIsOpposing?(attacker.index)
            @battle.pbDisplay(_INTL("Pointed stones float in the air around your foe's team!"))
         else
            @battle.pbDisplay(_INTL("Pointed stones float in the air around your team!"))
         end
       return 0
       break
      end
    end
    attacker.pbOpposingSide.effects[PBEffects::StealthRock]=true
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Pointed stones float in the air around your foe's team!"))
    else
      @battle.pbDisplay(_INTL("Pointed stones float in the air around your team!"))
    end
    return 0
  end
end

################################################################################
# If used after ally's Fire Pledge, makes a sea of fire on the opposing side. (Grass Pledge)
################################################################################
class PokeBattle_Move_106 < PokeBattle_Move
  # THIS ONE IS GRASS PLEDGE
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    ret if !@battle.canChangeFE?
    fieldbefore = @battle.field.effect
    @battle.setPledge(PBMoves::GRASSPLEDGE)
    if @battle.field.effect == fieldbefore #field didn't change
      case @battle.field.effect
        when PBFields::BURNINGF then @battle.pbDisplay(_INTL("The pledges combined and fanned the flames!"))
        when PBFields::SWAMPF then @battle.pbDisplay(_INTL("The pledges combined and reinforced the swamp!"))
        else #same field; means there wasn't another pledge used
          @battle.pbDisplay(_INTL("The Grass Pledge lingers in the air..."))
          return ret
      end
      if @battle.field.duration > 0 
        @battle.field.duration=4
        @battle.field.duration=7 if (attacker.itemWorks? && attacker.item == PBItems::AMPLIFIELDROCK)
      end
    else
      case @battle.field.effect
        when PBFields::BURNINGF then @battle.pbDisplay(_INTL("The pledges combined and set the field ablaze!"))
        when PBFields::SWAMPF then @battle.pbDisplay(_INTL("The pledges combined and formed a swamp!"))
      end
      @battle.field.duration=4
      @battle.field.duration=7 if (attacker.itemWorks? && attacker.item == PBItems::AMPLIFIELDROCK)
    end
    return ret
  end
end

################################################################################
# If used after ally's Water Pledge, makes a rainbow appear on the user's side. (Fire Pledge)
################################################################################
class PokeBattle_Move_107 < PokeBattle_Move
  # THIS ONE IS FIRE PLEDGE
  def pbOnStartUse(attacker)
    if @battle.FE == PBFields::CORROSIVEMISTF
      bearer=@battle.pbCheckGlobalAbility(:DAMP)
      if bearer && @battle.FE == PBFields::CORROSIVEMISTF #Corrosive Mist Field
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
        bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
        return false
      end
    end
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    ret if !@battle.canChangeFE?
    fieldbefore = @battle.field.effect
    @battle.setPledge(PBMoves::FIREPLEDGE)
    if @battle.field.effect == fieldbefore #field didn't change
      case @battle.field.effect
        when PBFields::BURNINGF then @battle.pbDisplay(_INTL("The pledges combined and fanned the flames!"))
        when PBFields::RAINBOWF then @battle.pbDisplay(_INTL("The pledges combined to refresh the rainbow!"))
        else #same field; means there wasn't another pledge used
          @battle.pbDisplay(_INTL("The Fire Pledge lingers in the air..."))
          return ret
      end
      if @battle.field.duration > 0 
        @battle.field.duration=4
        @battle.field.duration=7 if (attacker.itemWorks? && attacker.item == PBItems::AMPLIFIELDROCK)
      end
    else
      case @battle.field.effect
        when PBFields::BURNINGF then @battle.pbDisplay(_INTL("The pledges combined and set the field ablaze!"))
        when PBFields::RAINBOWF then @battle.pbDisplay(_INTL("The pledges combined to form a rainbow!"))
      end
      @battle.field.duration=4
      @battle.field.duration=7 if (attacker.itemWorks? && attacker.item == PBItems::AMPLIFIELDROCK)
    end
    return ret
  end
end

################################################################################
# If used after ally's Grass Pledge, makes a swamp appear on the opposing side. (water Pledge)
################################################################################
class PokeBattle_Move_108 < PokeBattle_Move
  # THIS ONE IS WATER PLEDGE
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    ret if !@battle.canChangeFE?
    fieldbefore = @battle.field.effect
    @battle.setPledge(PBMoves::WATERPLEDGE)
    if @battle.field.effect == fieldbefore #field didn't change
      case @battle.field.effect
        when PBFields::SWAMPF then @battle.pbDisplay(_INTL("The pledges combined and reinforced the swamp!"))
        when PBFields::RAINBOWF then @battle.pbDisplay(_INTL("The pledges combined to refresh the rainbow!"))
        else #same field; means there wasn't another pledge used
          @battle.pbDisplay(_INTL("The Water Pledge lingers in the air..."))
          return ret
      end
      if @battle.field.duration > 0 
        @battle.field.duration=4
        @battle.field.duration=7 if (attacker.itemWorks? && attacker.item == PBItems::AMPLIFIELDROCK)
      end
    else
      case @battle.field.effect
        when PBFields::SWAMPF then @battle.pbDisplay(_INTL("The pledges combined and formed a swamp!"))
        when PBFields::RAINBOWF then @battle.pbDisplay(_INTL("The pledges combined to form a rainbow!"))
      end
      @battle.field.duration=4
      @battle.field.duration=7 if (attacker.itemWorks? && attacker.item == PBItems::AMPLIFIELDROCK)
    end
    return ret
  end
end

################################################################################
# Scatters coins that the player picks up after winning the battle. (Pay Day)
################################################################################
class PokeBattle_Move_109 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if @battle.pbOwnedByPlayer?(attacker.index)
        @battle.extramoney+=5*attacker.level
        if @battle.FE == PBFields::BIGTOPA || @battle.FE == PBFields::DRAGONSD
          @battle.extramoney+=495*attacker.level
        end
        @battle.extramoney=MAXMONEY if @battle.extramoney>MAXMONEY
      end
      if @battle.FE == PBFields::DRAGONSD
        @battle.pbDisplay(_INTL("Treasure scattered everywhere!"))
      else
        @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
      end
    end
    return ret
  end
end

################################################################################
# Ends the opposing side's Light Screen and Reflect. (Brick Break / Psychic Fangs)
################################################################################
class PokeBattle_Move_10A < PokeBattle_Move
  def pbCalcDamage(attacker,opponent, hitnum: 0)
    return super(attacker,opponent,PokeBattle_Move::NOREFLECT, hitnum: hitnum)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if ret==0
      return ret
    end
    if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
      attacker.pbOpposingSide.effects[PBEffects::Reflect]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Reflect wore off!"))
      else
        @battle.pbDisplay(_INTL("Your team's Reflect wore off!"))
      end
    end
    if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
      attacker.pbOpposingSide.effects[PBEffects::LightScreen]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Light Screen wore off!"))
      else
        @battle.pbDisplay(_INTL("Your team's Light Screen wore off!"))
      end
    end
    if attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Aurora Veil wore off!"))
      else
        @battle.pbDisplay(_INTL("Your team's Aurora Veil wore off!"))
      end
    end
    return ret
  end
end

################################################################################
# If attack misses, user takes crash damage of 1/2 of max HP. (High Jump Kick / Jump Kick)
################################################################################
class PokeBattle_Move_10B < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.state.effects[PBEffects::Gravity]>0
  end
end

################################################################################
# User turns 1/4 of max HP into a substitute. (Substitute)
################################################################################
class PokeBattle_Move_10C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1} already has a substitute!",attacker.pbThis))
      return -1
    end
    sublife=[(attacker.totalhp/4.0).floor,1].max
    if attacker.hp<=sublife
      @battle.pbDisplay(_INTL("It was too weak to make a substitute!"))
      return -1
    end
    attacker.pbReduceHP(sublife,false,false)
    attacker.effects[PBEffects::UsingSubstituteRightNow]=true
    attacker.battle.scene.pbAnimation(self,attacker,opponent,hitnum)  #pbShowAnimation(@id,attacker,nil,hitnum,alltargets,true)
    attacker.effects[PBEffects::UsingSubstituteRightNow]=false
    #@battle.scene.pbSubstituteSprite(attacker,attacker.pbIsOpposing?(1))
    attacker.effects[PBEffects::MultiTurn]=0
    attacker.effects[PBEffects::MultiTurnAttack]=0
    attacker.effects[PBEffects::Substitute]=sublife
    @battle.pbDisplay(_INTL("{1} put in a substitute!",attacker.pbThis))
    return 0
  end
end

################################################################################
# User is not Ghost: Decreases user's Speed, increases user's Attack & Defense by
# 1 stage each. (Curse)
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
################################################################################
class PokeBattle_Move_10D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    failed=false
    if !attacker.pbHasType?(:GHOST)
      lowerspeed=attacker.pbCanReduceStatStage?(PBStats::SPEED,false,true)
      raiseatk=attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      raisedef=attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      if !lowerspeed && !raiseatk && !raisedef
        failed=true
      else
        @battle.pbCommonAnimation("CurseNoGhost",attacker,nil)
        if lowerspeed
          attacker.pbReduceStat(PBStats::SPEED,1,abilitymessage:false, statdropper: attacker)
        end
        showanim=true
        if raiseatk
          attacker.pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
          showanim=false
        end
        if raisedef
          attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
          showanim=false
        end
      end
    else
      if opponent.effects[PBEffects::Curse]
        failed=true
      else
        pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
        attacker.pbReduceHP((attacker.totalhp/2.0).floor,false,false)
        opponent.effects[PBEffects::Curse]=true
        @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!",attacker.pbThis,opponent.pbThis(true)))
      end
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
    end
    return failed ? -1 : 0
  end
end

################################################################################
# Target's last move used loses 4 PP. (Spite)
################################################################################
class PokeBattle_Move_10E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    for i in opponent.moves
      if i.id==opponent.lastMoveUsed && i.id>0 && i.pp>0
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        reduction=[4,i.pp].min
        opponent.pbSetPP(i,i.pp-reduction)
        @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",opponent.pbThis(true),i.name,reduction))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end

################################################################################
# Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
################################################################################
class PokeBattle_Move_10F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (opponent.status!=PBStatuses::SLEEP && opponent.ability != PBAbilities::COMATOSE) ||
       opponent.effects[PBEffects::Nightmare] || opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Nightmare]=true
    @battle.pbDisplay(_INTL("{1} began having a nightmare!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Removes trapping moves, entry hazards and Leech Seed on user/user's side. (Rapid Spin)
################################################################################
class PokeBattle_Move_110 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && opponent.damagestate.calcdamage>0
      if attacker.effects[PBEffects::MultiTurn]>0
        mtattack=PBMoves.getName(attacker.effects[PBEffects::MultiTurnAttack])
        mtuser=@battle.battlers[attacker.effects[PBEffects::MultiTurnUser]]
        @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!",attacker.pbThis,mtuser.pbThis(true),mtattack))
        attacker.effects[PBEffects::MultiTurn]=0
        attacker.effects[PBEffects::MultiTurnAttack]=0
        attacker.effects[PBEffects::MultiTurnUser]=-1
      end
      if attacker.effects[PBEffects::LeechSeed]>=0
        attacker.effects[PBEffects::LeechSeed]=-1
        @battle.pbDisplay(_INTL("{1} shed Leech Seed!",attacker.pbThis))
      end
      if attacker.pbOwnSide.effects[PBEffects::StealthRock]
        attacker.pbOwnSide.effects[PBEffects::StealthRock]=false
        @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",attacker.pbThis))
      end
      if attacker.pbOwnSide.effects[PBEffects::Spikes]>0
        attacker.pbOwnSide.effects[PBEffects::Spikes]=0
        @battle.pbDisplay(_INTL("{1} blew away Spikes!",attacker.pbThis))
      end
      if attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
        @battle.pbDisplay(_INTL("{1} blew away poison spikes!",attacker.pbThis))
      end
      if attacker.pbOwnSide.effects[PBEffects::StickyWeb]
        attacker.pbOwnSide.effects[PBEffects::StickyWeb]=false
        @battle.pbDisplay(_INTL("{1} blew away the sticky webbing!",attacker.pbThis))
      end
    end
    return ret
  end
end

################################################################################
# Attacks 2 rounds in the future. (Future Sight / Doom Desire)
################################################################################
class PokeBattle_Move_111 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::FutureSight]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::FutureSight]=3
    opponent.effects[PBEffects::FutureSightMove]=@id
    opponent.effects[PBEffects::FutureSightUser]=attacker.index
    opponent.effects[PBEffects::FutureSightPokemonIndex]=attacker.pokemonIndex
    if (@id == PBMoves::FUTURESIGHT)
      @battle.pbDisplay(_INTL("{1} foresaw an attack!",attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} chose Doom Desire as its destiny!",attacker.pbThis))
    end
    return 0
  end
end

################################################################################
# Increases user's Defense and Special Defense by 1 stage each.  Ups user's
# stockpile by 1 (max. 3).
################################################################################
class PokeBattle_Move_112 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Stockpile]>=3
      @battle.pbDisplay(_INTL("{1} can't stockpile any more!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Stockpile]+=1
    @battle.pbDisplay(_INTL("{1} stockpiled {2}!",attacker.pbThis,
        attacker.effects[PBEffects::Stockpile]))
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
      attacker.effects[PBEffects::StockpileDef]+=1
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
      attacker.effects[PBEffects::StockpileSpDef]+=1
      showanim=false
    end
    return 0
  end
end

################################################################################
# Power is multiplied by the user's stockpile (X).  Reduces the stockpile to 0.
# Decreases user's Defense and Special Defense by X stages each.
################################################################################
class PokeBattle_Move_113 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return 100*attacker.effects[PBEffects::Stockpile]
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Stockpile]==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.effects[PBEffects::StockpileDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
        attacker.pbReduceStat(PBStats::DEFENSE,attacker.effects[PBEffects::StockpileDef], abilitymessage:false, statdropper: attacker)
        showanim=false
      end
    end
    if attacker.effects[PBEffects::StockpileSpDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::SPDEF,false,true)
        attacker.pbReduceStat(PBStats::SPDEF,attacker.effects[PBEffects::StockpileSpDef], abilitymessage:false, statdropper: attacker)
        showanim=false
      end
    end
    attacker.effects[PBEffects::Stockpile]=0
    attacker.effects[PBEffects::StockpileDef]=0
    attacker.effects[PBEffects::StockpileSpDef]=0
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",attacker.pbThis))
    return ret
  end
end

################################################################################
# Heals user depending on the user's stockpile (X).  Reduces the stockpile to 0.
# Decreases user's Defense and Special Defense by X stages each. (Swallow)
################################################################################
class PokeBattle_Move_114 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    hpgain=0
    case attacker.effects[PBEffects::Stockpile]
      when 0
        @battle.pbDisplay(_INTL("But it failed to swallow a thing!"))
        return -1
      when 1
        hpgain=(attacker.totalhp/4.0).floor
        hpgain=(attacker.totalhp/2.0).floor if @battle.FE == PBFields::WASTELAND
      when 2
        hpgain=(attacker.totalhp/2.0).floor
        hpgain=attacker.totalhp if @battle.FE == PBFields::WASTELAND
      when 3
        hpgain=attacker.totalhp
    end
    if attacker.hp==attacker.totalhp &&
       attacker.effects[PBEffects::StockpileDef]==0 &&
       attacker.effects[PBEffects::StockpileSpDef]==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.FE == PBFields::WASTELAND && attacker.effects[PBEffects::Stockpile]==3
       t=attacker.status
      attacker.status=0
      attacker.statusCount=0
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      if t==PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} was cured of its burn.",attacker.pbThis))
      elsif t==PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbThis))
      elsif t==PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",attacker.pbThis))
      end
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if attacker.pbRecoverHP(hpgain,true)>0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    end
    showanim=true
    if attacker.effects[PBEffects::StockpileDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
        attacker.pbReduceStat(PBStats::DEFENSE,attacker.effects[PBEffects::StockpileDef], abilitymessage:false, statdropper: attacker)
        showanim=false
      end
    end
    if attacker.effects[PBEffects::StockpileSpDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::SPDEF,false,true)
        attacker.pbReduceStat(PBStats::SPDEF,attacker.effects[PBEffects::StockpileSpDef], abilitymessage:false, statdropper: attacker)
        showanim=false
      end
    end
    attacker.effects[PBEffects::Stockpile]=0
    attacker.effects[PBEffects::StockpileDef]=0
    attacker.effects[PBEffects::StockpileSpDef]=0
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",attacker.pbThis))
    return 0
  end
end

#################################################################################
# Fails if user was hit by a damaging move this round. (Focus Punch)
################################################################################
class PokeBattle_Move_115 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    if attacker.lastHPLost>0 || @battle.FE == PBFields::ELECTRICT # Electric Field
      @battle.pbDisplay(_INTL("{1} lost its focus and couldn't move!",attacker.pbThis))
      return -1
    end
    return super(attacker)
  end
end

################################################################################
# Fails if the target didn't chose a damaging move to use this round, or has
# already moved. (Sucker Punch)
################################################################################
class PokeBattle_Move_116 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.hasMovedThisRound?
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.effects[PBEffects::HyperBeam]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.switchedOut[opponent.index]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.itemUsed
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.effects[PBEffects::KingsShield]==true && ((@battle.choices[opponent.index][2] == nil) || (@battle.choices[opponent.index][2] == 0) || (@battle.choices[opponent.index][2] == -1) || (@battle.choices[opponent.index][2].basedamage == 0))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    elsif opponent.effects[PBEffects::KingsShield]==true
      @battle.pbDisplay(_INTL("{1} protected itself!", opponent.pbThis))
      @battle.successStates[attacker.index].protected=true
      attacker.pbReduceStat(PBStats::ATTACK, 2, statdropper: opponent)
      attacker.pbReduceStat(PBStats::SPATK, 2, statdropper: opponent) if @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::CHESSB
      return -1
    end
    if opponent.effects[PBEffects::Obstruct]==true
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.effects[PBEffects::BanefulBunker]==true 
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.effects[PBEffects::SpikyShield]==true && ((@battle.choices[opponent.index][2] == nil) || (@battle.choices[opponent.index][2] == 0) || (@battle.choices[opponent.index][2] == -1) || (@battle.choices[opponent.index][2].basedamage == 0))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    elsif opponent.effects[PBEffects::SpikyShield]==true
      @battle.pbDisplay(_INTL("{1} protected itself!", opponent.pbThis))
      @battle.successStates[attacker.index].protected=true
      if !attacker.hasWorkingAbility(:LONGREACH)
        attacker.pbReduceHP((attacker.totalhp/8.0).floor)
        @battle.pbDisplay(_INTL("{1}'s Spiky Shield hurt {2}!",opponent.pbThis,attacker.pbThis(true)))
      end
      return -1
    end
    if (@battle.choices[opponent.index][2] == nil) || (@battle.choices[opponent.index][2] == 0) || (@battle.choices[opponent.index][2] == -1) || (@battle.choices[opponent.index][2].basedamage == 0)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return super
  end
end

################################################################################
# This round, user becomes the target of attacks that have single targets. 
# (Follow Me, Rage Powder)
################################################################################
class PokeBattle_Move_117 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if (@id == PBMoves::RAGEPOWDER)
      attacker.effects[PBEffects::RagePowder]=true
      if !attacker.pbPartner.isFainted?
        attacker.pbPartner.effects[PBEffects::FollowMe]=false
        attacker.pbPartner.effects[PBEffects::RagePowder]=false
      end
    else
      attacker.effects[PBEffects::FollowMe]=true
      if !attacker.pbPartner.isFainted?
        attacker.pbPartner.effects[PBEffects::FollowMe]=false
        attacker.pbPartner.effects[PBEffects::RagePowder]=false
      end
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!",attacker.pbThis))
    return 0
  end
end

################################################################################
# For 5 rounds, increases gravity on the field.  Pokémon cannot become airborne. (Gravity)
################################################################################
class PokeBattle_Move_118 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.state.effects[PBEffects::Gravity]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.state.effects[PBEffects::Gravity]=5
    @battle.state.effects[PBEffects::Gravity]=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.state.effects[PBEffects::Gravity]=8 if @battle.FE == PBFields::PSYCHICT
    for i in 0...4
      poke=@battle.battlers[i]
      next if !poke
      if $cache.pkmn_move[poke.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xC9 || # Fly
         $cache.pkmn_move[poke.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCC || # Bounce
         $cache.pkmn_move[poke.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCE    # Sky Drop
        poke.effects[PBEffects::TwoTurnAttack]=0
      end
      if poke.effects[PBEffects::SkyDrop]
        poke.effects[PBEffects::SkyDrop]=false
      end
      if poke.effects[PBEffects::MagnetRise]>0
        poke.effects[PBEffects::MagnetRise]=0
      end
      if poke.effects[PBEffects::Telekinesis]>0
        poke.effects[PBEffects::Telekinesis]=0
      end
    end
    @battle.pbDisplay(_INTL("Gravity intensified!"))
    return 0
  end
end

################################################################################
# For 5 rounds, user becomes airborne. (Magnet Rise)
################################################################################
class PokeBattle_Move_119 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (@battle.state.effects[PBEffects::Gravity])
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Ingrain] ||
       attacker.effects[PBEffects::SmackDown] ||
       attacker.effects[PBEffects::MagnetRise]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MagnetRise]=5
    if @battle.FE == PBFields::ELECTRICT || @battle.FE == PBFields::FACTORYF ||
      @battle.FE == PBFields::SHORTCIRCUITF # Electric/Factory Field
          attacker.effects[PBEffects::MagnetRise]=8
    end
    @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",attacker.pbThis))
    return 0
  end
end

################################################################################
# For 3 rounds, target becomes airborne and can always be hit. (Telekinesis)
################################################################################
class PokeBattle_Move_11A < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.state.effects[PBEffects::Gravity]>0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Ingrain] ||
       opponent.effects[PBEffects::SmackDown] ||
       opponent.effects[PBEffects::Telekinesis]>0 ||
       opponent.species==PBSpecies::DIGLETT || opponent.species==PBSpecies::DUGTRIO || opponent.species==PBSpecies::SANDYGAST || opponent.species==PBSpecies::PALOSSAND || (opponent.species==PBSpecies::GENGAR && opponent.form==1)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Telekinesis]=3
    @battle.pbDisplay(_INTL("{1} was hurled into the air!",opponent.pbThis))
    if @battle.FE == PBFields::PSYCHICT
      opponent.pbReduceStat(PBStats::DEFENSE,2,abilitymessage:false, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,false)
      opponent.pbReduceStat(PBStats::SPDEF,2,abilitymessage:false, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::SPDEF,false)
    end
    return 0
  end
end

################################################################################
# Hits airborne semi-invulnerable targets.
################################################################################
class PokeBattle_Move_11B < PokeBattle_Move
# Handled in Battler class, do not edit!
end

################################################################################
# Grounds the target while it remains active. (Smack Down, Thousand Arrows)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_11C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !opponent.effects[PBEffects::Roost]
      opponent.effects[PBEffects::SmackDown]=true
      showmsg=false
      showmsg=true if opponent.pbHasType?(:FLYING) ||
                      opponent.ability == PBAbilities::LEVITATE
      if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xC9 || # Fly
         $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCC    # Bounce
        opponent.effects[PBEffects::TwoTurnAttack]=0; showmsg=true
      end
      if opponent.effects[PBEffects::MagnetRise]>0
        opponent.effects[PBEffects::MagnetRise]=0; showmsg=true
      end
      if opponent.effects[PBEffects::Telekinesis]>0
        opponent.effects[PBEffects::Telekinesis]=0; showmsg=true
      end
      @battle.pbDisplay(_INTL("{1} fell straight down!",opponent.pbThis)) if showmsg
    end
    return ret
  end
end

################################################################################
# Target moves immediately after the user, ignoring priority/speed. (After You)
################################################################################
class PokeBattle_Move_11D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    success = @battle.pbMoveAfter(attacker, opponent)
    if success
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.pbDisplay(_INTL("{1} took the kind offer!", opponent.pbThis))
      return 0
    else
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# Target moves last this round, ignoring priority/speed. (Quash)
################################################################################
class PokeBattle_Move_11E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    success = @battle.pbMoveLast(opponent)
    if success
      @battle.pbDisplay(_INTL("{1}'s move was postponed!", opponent.pbThis))
      return 0
    else
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# For 5 rounds, for each priority bracket, slow Pokémon move before fast ones. (Trick Room)
################################################################################
class PokeBattle_Move_11F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if @battle.trickroom == 0
      @battle.trickroom=5
      if @battle.FE == PBFields::CHESSB || @battle.FE == PBFields::NEWW || @battle.FE == PBFields::PSYCHICT || (attacker.item == PBItems::AMPLIFIELDROCK)
        @battle.trickroom=8
      end
      @battle.pbDisplay(_INTL("{1} twisted the dimensions!",attacker.pbThis))
    else
      @battle.trickroom=0
      @battle.pbDisplay(_INTL("The twisted dimensions returned to normal!",attacker.pbThis))
    end
    for i in @battle.battlers
      if i.hasWorkingItem(:ROOMSERVICE)
        if i.pbCanReduceStatStage?(PBStats::SPEED)
          i.pbReduceStatBasic(PBStats::SPEED,1)
          @battle.pbCommonAnimation("StatDown",i,nil)
          @battle.pbDisplay(_INTL("The Room Service lowered #{i.pbThis}'s Speed!"))
          i.pbDisposeItem(false)
        end
      end
    end
    return 0
  end
end

################################################################################
# User switches places with its ally. (Ally Switch)
################################################################################

class PokeBattle_Move_120 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("{1} went back to {2}!",attacker.pbThis,@battle.pbGetOwner(attacker.index).name))
    newpoke=0
    newpoke=@battle.pbSwitchInBetween(attacker.index,true,false)
    @battle.pbMessagesOnReplace(attacker.index,newpoke)
    attacker.pbResetForm
    @battle.pbReplace(attacker.index,newpoke)
    @battle.pbOnActiveOne(attacker)
    attacker.pbAbilitiesOnSwitchIn(true)
    return 0
  end
end

################################################################################
# Target's Attack is used instead of user's Attack for this move's calculations.
################################################################################
class PokeBattle_Move_121 < PokeBattle_Move
# Handled in superclass, do not edit!
end

################################################################################
# Target's Defense is used instead of its Special Defense for this move's
# calculations.
################################################################################
class PokeBattle_Move_122 < PokeBattle_Move
# Handled in superclass, do not edit!
end

################################################################################
# Only damages Pokémon that share a type with the user. (Synchronoise)
################################################################################
class PokeBattle_Move_123 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbHasType?(attacker.type1) && !opponent.pbHasType?(attacker.type2)
      @battle.pbDisplay(_INTL("{1} was unaffected!",opponent.pbThis))
      return -1
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# For 5 rounds, swaps all battlers' base Defense with base Special Defense. (Wonder Room)
################################################################################
class PokeBattle_Move_124 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.state.effects[PBEffects::WonderRoom] == 0
      @battle.state.effects[PBEffects::WonderRoom] = 5
      if @battle.FE == PBFields::NEWW || @battle.FE == PBFields::PSYCHICT || # New World, Psychic Terrain
       (attacker.itemWorks? && attacker.item == PBItems::AMPLIFIELDROCK)
        @battle.state.effects[PBEffects::WonderRoom] = 8
      end
      for i in @battle.battlers
        i.pbSwapDefenses
      end
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.pbDisplay(_INTL("{1} created a bizarre area in which the Defense and Sp. Def stats are swapped!",attacker.pbThis))
    else
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.state.effects[PBEffects::WonderRoom] = 0
      @battle.pbDisplay(_INTL("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!"))
      for i in @battle.battlers
        i.pbSwapDefenses
      end
    end
    return 0
  end
#### Inuki was here kuro's a LOSER
end

################################################################################
# Fails unless user has already used all other moves it knows. (Last Resort)
################################################################################

class PokeBattle_Move_125 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    totalMoves = []
    for i in attacker.moves
      totalMoves[i.id] = false
      if i.function == 0x125
        totalMoves[i.id] = true
      end
      if i.id == 0
        totalMoves[i.id] = true
      end
    end
    for i in attacker.movesUsed
      for j in attacker.moves
        if i == j.id
          totalMoves[j.id] = true
        end
      end
    end
    for i in attacker.moves
      if !totalMoves[i.id]
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

#===============================================================================
# NOTE: Shadow moves use function codes 126-132 inclusive.  If you're inventing
#       new move effects, use function code 133 and onwards.
#===============================================================================

################################################################################
# 133- King's Shield
################################################################################
class PokeBattle_Move_133 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !PBStuff::RATESHARERS.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority = @battle.pbPriority
    if (@battle.doublebattle && attacker == priority[3]) || (!@battle.doublebattle && attacker == priority[1])
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbRandom(65536)<(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::KingsShield]=true
      attacker.effects[PBEffects::ProtectRate]*=3
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} shielded itself against damage!",attacker.pbThis))
      return 0
    else
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# 134- Electric Terrain
################################################################################
class PokeBattle_Move_134 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::ELECTRICT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::ELECTRICT,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The terrain became electrified!"))
    return 0
  end
end

################################################################################
# 135- Grassy Terrain
################################################################################
class PokeBattle_Move_135 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::GRASSYT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::GRASSYT,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The terrain became grassy!"))
    return 0
  end
end

################################################################################
# 136- Misty Terrain
################################################################################
class PokeBattle_Move_136 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::MISTYT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::MISTYT,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The terrain became misty!"))
    return 0
  end
end

################################################################################
# 137- Flying Press (not type effect; double damage + always hit while
#target is minimized. Accuracy handled in pbAccuracy Check)
################################################################################
class PokeBattle_Move_137 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return false
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.effects[PBEffects::Minimize]
      return (damagemult*2.0).round
    end
    return damagemult
  end
end

################################################################################
# Decreases the target's Attack and Special Attack by 1 stage each. (Noble Roar/Tearful Look)
################################################################################
class PokeBattle_Move_138 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=-1; prevented=false
    if opponent.effects[PBEffects::Protect] &&
       !opponent.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} protected itself!",opponent.pbThis))
      @battle.successStates[attacker.index].protected=true
      prevented=true
    end
    if !prevented && opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      prevented=true
    end
    if !prevented && ((((opponent.ability == PBAbilities::CLEARBODY) ||
       (opponent.ability == PBAbilities::WHITESMOKE)) && !(opponent.moldbroken)) || opponent.ability == PBAbilities::FULLMETALBODY)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      prevented=true
    end
    if !prevented && opponent.pbTooLow?(PBStats::ATTACK) &&
       opponent.pbTooLow?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
      prevented=true
    end
    if !prevented
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      showanim=true
      if (@battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::DRAGONSD)  && (@id == PBMoves::NOBLEROAR)
        if opponent.pbReduceStat(PBStats::ATTACK,2,abilitymessage:false, statdropper: attacker)
          ret=0; showanim=false
        end
        if opponent.pbReduceStat(PBStats::SPATK,2,abilitymessage:false, statdropper: attacker)
          ret=0; showanim=false
        end
      else
        if opponent.pbReduceStat(PBStats::ATTACK,1,abilitymessage:false, statdropper: attacker)
          ret=0; showanim=false
        end
        if opponent.pbReduceStat(PBStats::SPATK,1,abilitymessage:false, statdropper: attacker)
          ret=0; showanim=false
        end
      end
    end
    return ret
  end
end

################################################################################
# User gains 75% of the HP it inflicts as damage. (Draining Kiss/Oblivion Wing)
################################################################################
class PokeBattle_Move_139 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=((opponent.damagestate.hplost+1)*0.75).floor
      if (opponent.ability == PBAbilities::LIQUIDOOZE)
        hpgain*=2 if @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS
        attacker.pbReduceHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
      else
        hpgain=(hpgain*1.3).floor if (attacker.item == PBItems::BIGROOT)
        attacker.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    if @battle.FE == PBFields::FAIRYTALEF && (@id == PBMoves::DRAININGKISS)
      if !opponent.damagestate.substitute && opponent.status==PBStatuses::SLEEP
        opponent.pbCureStatus
      end
    end
    return ret
  end
end

################################################################################
# Spiky Shield
################################################################################
class PokeBattle_Move_140 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !PBStuff::RATESHARERS.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority = @battle.pbPriority
    if (@battle.doublebattle && attacker == priority[3]) || (!@battle.doublebattle && attacker == priority[1])
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbRandom(65536)<(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::SpikyShield]=true
      attacker.effects[PBEffects::ProtectRate]*=3
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} shielded itself against damage!",attacker.pbThis))
      return 0
    else
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# Increases the target's Special Defense by 1 stage. (Aromatic Mist)
################################################################################
class PokeBattle_Move_13A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if !@battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return -1 if !attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::SPDEF,true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::MISTYT
      ret=attacker.pbPartner.pbIncreaseStat(PBStats::SPDEF,2,abilitymessage:false)
    else
      ret=attacker.pbPartner.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      if @battle.FE == PBFields::MISTYT
        attacker.pbPartner.pbIncreaseStat(PBStats::SPDEF,2,abilitymessage:false)
      else
        attacker.pbPartner.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
      end
    end
    return true
  end
end

################################################################################
# Decreases the target's Special Attack by 2 stages. (Eerie Impulse)
################################################################################
class PokeBattle_Move_13B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if @battle.FE == PBFields::ELECTRICT
      ret=opponent.pbReduceStat(PBStats::SPATK,3,abilitymessage:false, statdropper: attacker)
    else
      ret=opponent.pbReduceStat(PBStats::SPATK,2,abilitymessage:false, statdropper: attacker)
    end
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,false)
      if @battle.FE == PBFields::ELECTRICT
        opponent.pbReduceStat(PBStats::SPATK,3,abilitymessage:false, statdropper: attacker)
      else
        opponent.pbReduceStat(PBStats::SPATK,2,abilitymessage:false, statdropper: attacker)
      end
    end
    return true
  end
end

################################################################################
#  Belch
################################################################################
class PokeBattle_Move_13C <PokeBattle_Move
  def pbOnStartUse(attacker)
    if attacker.pokemon.belch == true
      return true
    else
      @battle.pbDisplay("But it failed!")
      return false
    end
  end
end

##################################################################
# After lowering stats, user switches out. (Parting Shot)
##################################################################
class PokeBattle_Move_13D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.pbTooLow?(PBStats::ATTACK) && opponent.pbTooLow?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      return -1
    end
    if (((opponent.ability == PBAbilities::CLEARBODY) ||
       (opponent.ability == PBAbilities::WHITESMOKE)) && !(opponent.moldbroken)) || opponent.ability == PBAbilities::FULLMETALBODY
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim=true
    if opponent.pbReduceStat(PBStats::ATTACK,1,abilitymessage:false, statdropper: attacker)
      ret=0; showanim=false
    end
    if opponent.pbReduceStat(PBStats::SPATK,1,abilitymessage:false, statdropper: attacker)
      ret=0; showanim=false
    end
    if attacker.hp>0 && @battle.pbCanChooseNonActive?(attacker.index) && !@battle.pbAllFainted?(@battle.pbParty(opponent.index))
      @battle.pbDisplay(_INTL("{1} went back to {2}!",attacker.pbThis,@battle.pbGetOwner(attacker.index).name))
      #Going to switch, check for pursuit
      newpoke=0
      newpoke=@battle.pbSwitchInBetween(attacker.index,true,false)
      for j in @battle.priority
        next if !attacker.pbIsOpposing?(j.index)
        # if Pursuit and this target was chosen
        if !j.hasMovedThisRound? && @battle.pbChoseMoveFunctionCode?(j.index,0x88) && !j.effects[PBEffects::Pursuit] && (@battle.choices[j.index][3]!=j.pbPartner.index)
          attacker.vanished=false
          @battle.pbCommonAnimation("Fade in",attacker,nil)
          @battle.pbPursuitInterrupt(j,attacker)
        end
        break if attacker.isFainted?
      end
      @battle.pbMessagesOnReplace(attacker.index,newpoke)
      attacker.pbResetForm
      @battle.pbReplace(attacker.index,newpoke)
      @battle.pbOnActiveOne(attacker)
      attacker.pbAbilitiesOnSwitchIn(true)
    else
      attacker.vanished=false
      @battle.pbCommonAnimation("Fade in",attacker,nil)
    end
    return ret
  end
end

##################################################################
# Skips first turn, boosts Sp.Atk, Sp.Def and Speed on the second. (Geomancy)
##################################################################

class PokeBattle_Move_13E < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if @battle.FE == PBFields::STARLIGHTA
      @immediate=true
      @battle.pbDisplay(_INTL("{1} absorbed the starlight!",attacker.pbThis))
    elsif !@immediate && (attacker.item == PBItems::POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pbDisposeItem(false)
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbCommonAnimation("Geomancy",attacker)
      @battle.pbDisplay(_INTL("{1} absorbed energy!",attacker.pbThis))
    end
    if attacker.effects[PBEffects::TwoTurnAttack]==0
      @battle.pbAnimation(@id,attacker,opponent,hitnum)
      for stat in [PBStats::SPATK,PBStats::SPDEF,PBStats::SPEED]
        if attacker.pbCanIncreaseStatStage?(stat,false)
          attacker.pbIncreaseStat(stat,2)
        end
      end
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
end

##################################################################
# Decreases a poisoned target's Attack, Sp.Atk and Speed by 1 stage. (Venom Drench)
##################################################################

class PokeBattle_Move_13F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    if opponent.status != PBStatuses::POISON && @battle.FE != 10 &&
      @battle.FE != 11 &&  @battle.FE != 19 &&  @battle.FE != 26
      @battle.pbDisplay(_INTL("But it failed!",opponent.pbThis))
      return -1
    end
    if opponent.pbTooLow?(PBStats::ATTACK) && opponent.pbTooLow?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      return -1
    end
    if (((opponent.ability == PBAbilities::CLEARBODY) ||
       (opponent.ability == PBAbilities::WHITESMOKE)) && !(opponent.moldbroken)) || opponent.ability == PBAbilities::FULLMETALBODY
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim=true

    if opponent.status==PBStatuses::POISON || @battle.FE == PBFields::CORROSIVEF ||
      @battle.FE == PBFields::CORROSIVEMISTF || @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS
      if opponent.pbReduceStat(PBStats::ATTACK,1,abilitymessage:false, statdropper: attacker)
        ret=0; showanim=false
      end
      if opponent.pbReduceStat(PBStats::SPATK,1,abilitymessage:false, statdropper: attacker)
        ret=0; showanim=false
      end
      if opponent.pbReduceStat(PBStats::SPEED,1,abilitymessage:false, statdropper: attacker)
        ret=0; showanim=false
      end
    end
    return ret
  end
end

################################################################################
# Entry hazard.  Puts down a sticky web that lowers speed. (Sticky Web)
################################################################################
class PokeBattle_Move_141 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::StickyWeb]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...4
      next if !(attacker.pbIsOpposing?(i))
      if (@battle.battlers[i].ability == PBAbilities::MAGICBOUNCE && !PBStuff::TWOTURNMOVE.include?(@battle.battlers[i].effects[PBEffects::TwoTurnAttack])) || 
        (@battle.battlers[i]).effects[PBEffects::MagicCoat]
         attacker.pbOwnSide.effects[PBEffects::StickyWeb]=true
         @battle.pbDisplay(_INTL("{1} bounced the Sticky Web back!",(@battle.battlers[i]).pbThis))
         if @battle.pbIsOpposing?(attacker.index)
           @battle.pbDisplay(_INTL("A sticky web has been laid out beneath your foe's team's feet!"))
         else
           @battle.pbDisplay(_INTL("A sticky web has been laid out beneath your team's feet!"))
         end
       return 0
       break
      end
    end
    attacker.pbOpposingSide.effects[PBEffects::StickyWeb]=true
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("A sticky web has been laid out beneath your foe's team's feet!"))
    else
      @battle.pbDisplay(_INTL("A sticky web has been laid out beneath your team's feet!"))
    end
    return 0
  end
end

################################################################################
# User inverts the target's stat stages. (Topsy-Turvy)
################################################################################
class PokeBattle_Move_142 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 1..7
      opponent.stages[i]=-opponent.stages[i]
    end
    @battle.pbDisplay(_INTL("{1} inverted {2}'s stat changes!",attacker.pbThis,opponent.pbThis(true)))
    if !(attacker.item == PBItems::EVERSTONE) && @battle.canChangeFE?
      @battle.setField(PBFields::INVERSEF,true)
      @battle.field.duration=3
      @battle.field.duration=6 if (attacker.item == PBItems::AMPLIFIELDROCK)
      @battle.pbDisplay(_INTL("The terrain was inverted!"))
    end
    return 0
  end
end

################################################################################
# Makes the target Grass Type (Forest's Curse)
################################################################################
class PokeBattle_Move_143 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (opponent.ability == PBAbilities::MULTITYPE) ||
      (opponent.ability == PBAbilities::RKSSYSTEM)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.type1=(PBTypes::GRASS)
    opponent.type2=(PBTypes::GRASS)
    typename=PBTypes.getName((PBTypes::GRASS))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    if @battle.FE == PBFields::FORESTF || @battle.FE == PBFields::FAIRYTALEF
      if !opponent.effects[PBEffects::Curse]
        opponent.effects[PBEffects::Curse]=true
        @battle.pbDisplay(_INTL("{1} laid a curse on {2}!",attacker.pbThis,opponent.pbThis(true)))
      end
    end
    return 0
  end
end

################################################################################
# Makes the target Ghost Type- (Trick Or Treat)
################################################################################
class PokeBattle_Move_144 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (opponent.ability == PBAbilities::MULTITYPE) ||
      (opponent.ability == PBAbilities::RKSSYSTEM)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.type1=(PBTypes::GHOST)
    opponent.type2=(PBTypes::GHOST)
    typename=PBTypes.getName((PBTypes::GHOST))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# All active Pokemon can no longer switch out or flee during the next turn. (Fairy Lock)
################################################################################
class PokeBattle_Move_145 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::FairyLockRate]==true
      attacker.effects[PBEffects::FairyLockRate]=false
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.state.effects[PBEffects::FairyLock]=2
    attacker.effects[PBEffects::FairyLockRate]=true
    @battle.pbDisplay(_INTL("No one will be able to run away during the next turn!"))
    return 0
  end
end

################################################################################
# If the user or any allies have Plus or Minus as their ability, raise their
#   Defense and Special Defense by one stage. (Magnetic Flux)
################################################################################
class PokeBattle_Move_146 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbPartner.ability == PBAbilities::PLUS ||
       attacker.pbPartner.ability == PBAbilities::MINUS
       partnerfail=false
      if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::DEFENSE,false) &&
         attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
        showanim=true
        if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
          attacker.pbPartner.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
          showanim=false
        end
        if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
          attacker.pbPartner.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
          showanim=false
        end
      else # partner cannot increase stats, check next attacker
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbPartner.pbThis))
      end
    else
      # partner does not have Plus/Minus
      partnerfail = true
    end
    if attacker.ability == PBAbilities::PLUS ||
       attacker.ability == PBAbilities::MINUS
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false) &&
         attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        pbShowAnimation(@id,attacker,nil,hitnum,alltargets,partnerfail)
        showanim=true
        if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
          attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
          showanim=false
        end
        if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
          attacker.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
          showanim=false
        end
      else # attacker cannot increase stats
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      end
    else
      # attacker does not have Plus/Minus
      if partnerfail
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end

    return 0
  end
end

################################################################################
# If the opponent dies, increase attack by 3 stages (Fell Stinger)
################################################################################
class PokeBattle_Move_147 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if opponent.isFainted? &&
       attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,3,abilitymessage:false)
    end
  end
end

################################################################################
# Ion Deluge
################################################################################
class PokeBattle_Move_148 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.state.effects[PBEffects::IonDeluge]==true
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
    @battle.state.effects[PBEffects::IonDeluge] = true
    if !(attacker.item == PBItems::EVERSTONE) && @battle.canChangeFE?(PBFields::ELECTRICT)
      @battle.setField(PBFields::ELECTRICT,true)
      @battle.field.duration=3
      @battle.field.duration=6 if (attacker.item == PBItems::AMPLIFIELDROCK)
      @battle.pbDisplay(_INTL("The terrain became electrified!"))
    end
    return 0
  end
end

################################################################################
# Crafty Shield
################################################################################
class PokeBattle_Move_149 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !PBStuff::RATESHARERS.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority = @battle.pbPriority
    if (@battle.doublebattle && attacker == priority[3]) || (!@battle.doublebattle && attacker == priority[1])
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbOwnSide.effects[PBEffects::CraftyShield]=true
    attacker.effects[PBEffects::ProtectRate]*=3
    @battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("{1} protected its team!",attacker.pbThis))
    if @battle.FE == PBFields::FAIRYTALEF # Fairy Tale Field
      @battle.pbDisplay(_INTL("{1} boosted its defenses with the shield!",attacker.pbThis))
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Flower Shield
################################################################################
class PokeBattle_Move_150 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    found=false
    for i in 0...4
      if @battle.battlers[i].pbHasType?(:GRASS)
        found=true
      end
    end
    @battle.pbDisplay("But it failed!") unless found
    return -1 unless found
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...4
      if @battle.battlers[i].pbHasType?(:GRASS)
        if @battle.FE == PBFields::FLOWERGARDENF 
          if !(@battle.battlers[i].pbCanIncreaseStatStage?(PBStats::DEFENSE,false)) &&
               !(@battle.battlers[i].pbCanIncreaseStatStage?(PBStats::SPDEF,false))
              @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
          end
        else 
          if !(@battle.battlers[i].pbCanIncreaseStatStage?(PBStats::DEFENSE,false))
              @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
          end
        end
        showanim=true
        if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0
          stat = 1
          if @battle.field.counter>1
            stat=2
          end
          if @battle.battlers[i].pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
            @battle.battlers[i].pbIncreaseStat(PBStats::DEFENSE,stat,abilitymessage:false)
            showanim=false
          end
          if @battle.battlers[i].pbCanIncreaseStatStage?(PBStats::SPDEF,false)
            @battle.battlers[i].pbIncreaseStat(PBStats::SPDEF,stat,abilitymessage:false)
            showanim=false
          end
        else
          if @battle.battlers[i].pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
            @battle.battlers[i].pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
            showanim=false
          end
        end
      end
    end
    if @battle.FE == PBFields::FAIRYTALEF && !attacker.pbHasType?(:GRASS) # Fairy Tale Field
      @battle.pbDisplay(_INTL("{1} boosted its defenses with the shield!"))
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
      end
    end
    if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0 && !attacker.pbHasType?(:GRASS) # Flower Garden
      if @battle.field.counter>1
        if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
          attacker.pbIncreaseStat(PBStats::DEFENSE,2,abilitymessage:false)
        end
        if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
          attacker.pbIncreaseStat(PBStats::SPDEF,2,abilitymessage:false)
        end
      else
        if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
          attacker.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
        end
        if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
          attacker.pbIncreaseStat(PBStats::SPDEF,1,abilitymessage:false)
        end
      end
    end
    return 0
  end
end

################################################################################
# Boosts Attack and Sp. Atk of all Grass-types Pokémon in the field (Rototiller)
################################################################################
class PokeBattle_Move_151 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    found=false
    for i in 0...4
      if @battle.battlers[i].pbHasType?(:GRASS)
        found=true
      end
    end
    @battle.pbDisplay("But it failed!") unless found
    return -1 unless found
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...4
      if @battle.battlers[i].pbHasType?(:GRASS) && !@battle.battlers[i].isAirborne?
        if !@battle.battlers[i].pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
           !@battle.battlers[i].pbCanIncreaseStatStage?(PBStats::ATTACK,false)
          @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",@battle.battlers[i].pbThis))
          return -1
        end
        showanim=true
        if @battle.FE == PBFields::FLOWERGARDENF
          if @battle.battlers[i].pbCanIncreaseStatStage?(PBStats::SPATK,false)
            @battle.battlers[i].pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
            showanim=false
          end
          if @battle.battlers[i].pbCanIncreaseStatStage?(PBStats::ATTACK,false)
            @battle.battlers[i].pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
            showanim=false
          end
        else
          if @battle.battlers[i].pbCanIncreaseStatStage?(PBStats::SPATK,false)
            @battle.battlers[i].pbIncreaseStat(PBStats::SPATK,1,abilitymessage:false)
            showanim=false
          end
          if @battle.battlers[i].pbCanIncreaseStatStage?(PBStats::ATTACK,false)
            @battle.battlers[i].pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
            showanim=false
          end
        end
      end
    end
    if @battle.FE == PBFields::FLOWERGARDENF && !attacker.pbHasType?(:GRASS)
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
        showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
        showanim=false
      end
    end
    return 0
  end
end

################################################################################
# Powder
################################################################################
class PokeBattle_Move_152 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent) if @basedamage>0
    if !opponent.effects[PBEffects::Powder] && (!(opponent.ability == PBAbilities::OVERCOAT) || opponent.moldbroken) && !opponent.pbHasType?(:GRASS) && !opponent.hasWorkingItem(:SAFETYGOGGLES)
      @battle.pbAnimation(@id,attacker,opponent)
      @battle.pbDisplay(_INTL("{1} was covered in a thin powder!",attacker.pbThis))
      opponent.effects[PBEffects::Powder]=true
      return 0
    else
      @battle.pbDisplay(_INTL("But it failed!"))
    end
    return -1
  end
end

################################################################################
# Next move used by the target becomes Electric-type (Electrify)
################################################################################
class PokeBattle_Move_153 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Electrify]==true
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Electrify]=true
    @battle.pbDisplay(_INTL("{1} became electrified!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Mat Block
################################################################################
class PokeBattle_Move_154 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (attacker.turncount!=1)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.pbOwnSide.effects[PBEffects::MatBlock]
      @battle.pbDisplay(_INTL("But it failed!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("{1} kicked up a mat to protect its team!",attacker.pbThis))
    attacker.pbOwnSide.effects[PBEffects::MatBlock]=true
    return 0
  end
end

################################################################################
# Thousand Waves
################################################################################
class PokeBattle_Move_155 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.effects[PBEffects::Substitute]>0
      #@battle.pbDisplay(_INTL("But it failed!"))
      return ret
    end
    typemod=pbTypeModifier(@type,attacker,opponent)
  #  pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.hp > 0 && opponent.effects[PBEffects::MeanLook]==-1 && typemod!=0 && !(@id == PBMoves::THOUSANDWAVES && opponent.pbHasType?(:GHOST))
      opponent.effects[PBEffects::MeanLook]=attacker.index
      @battle.pbDisplay(_INTL("{1} can't escape now!",opponent.pbThis))
    end
    return ret
  end
end
################################################################################
# Thousand Arrows NOT USED
################################################################################
class PokeBattle_Move_156 < PokeBattle_Move

end

###############################################################################
# Always hits and ignores protection (Hyperspace Hole)
###############################################################################
class PokeBattle_Move_157 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::ProtectNegation]=true if ret>0
    if opponent.pbPartner && !opponent.pbPartner.isFainted? && !opponent.pbPartner.effects[PBEffects::Protect] && !opponent.pbPartner.effects[PBEffects::SpikyShield] &&
       !opponent.pbPartner.effects[PBEffects::KingsShield] && !opponent.pbPartner.effects[PBEffects::Obstruct]
      opponent.pbPartner.effects[PBEffects::ProtectNegation]=true
    elsif (opponent.pbPartner.effects[PBEffects::Protect] || opponent.pbPartner.effects[PBEffects::SpikyShield] || opponent.pbPartner.effects[PBEffects::KingsShield] || opponent.pbPartner.effects[PBEffects::Obstruct]) &&
          (opponent.pbOwnSide.effects[PBEffects::CraftyShield] || opponent.pbOwnSide.effects[PBEffects::WideGuard] || opponent.pbOwnSide.effects[PBEffects::QuickGuard] ||
          opponent.effects[PBEffects::MatBlock])
      opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false
      opponent.pbOwnSide.effects[PBEffects::WideGuard]=false
      opponent.pbOwnSide.effects[PBEffects::QuickGuard]=false
      opponent.pbOwnSide.effects[PBEffects::MatBlock]=false
      end
    return ret
  end
end

################################################################################
# User gains 3/4 the HP it inflicts as damage. (OblivionWing) NOT USED
################################################################################
class PokeBattle_Move_158 < PokeBattle_Move
  #*crickets
end

###############################################################################
# Always hits, ignores protection, and lowers defense. Cannot be used by 
#any Pokemon other than Hoopa-Unbound. (Hyperspace Fury)
###############################################################################
class PokeBattle_Move_159 < PokeBattle_Move
  def pbOnStartUse(attacker)
    if (attacker.species == PBSpecies::HOOPA)
      if attacker.form == 1
        return true
      end
      # hoopa not in unbound form
      @battle.pbDisplay(_INTL("Hoopa can't use the move as it is now!"))
      return false
    end
    # any non-hoopa Pokemon
    @battle.pbDisplay(_INTL("But {1} can't use the move!",attacker.pbThis))
    return false
  end

  def pbAccuracyCheck(attacker,opponent)
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::ProtectNegation]=true if ret>0
    if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false)
      attacker.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false, statdropper: attacker)
    end
    return ret
  end
end

################################################################################
# Dummy Move Effect
################################################################################
class PokeBattle_Move_15A < PokeBattle_Move
end

############################################################################################################
# For 5 rounds if hailing, lowers power of physical & special attacks against the user's side. (Aurora Veil)
############################################################################################################
class PokeBattle_Move_15B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>0 || ((@battle.weather!=PBWeather::HAIL ||
      @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE)) &&
      @battle.FE!=4 && @battle.FE!=9 && @battle.FE!=13 &&
      @battle.FE!=25 && @battle.FE!=28 && @battle.FE!=30 && @battle.FE!=34)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if @battle.FE!=30
      attacker.pbOwnSide.effects[PBEffects::AuroraVeil]=5
      attacker.pbOwnSide.effects[PBEffects::AuroraVeil]=8 if attacker.hasWorkingItem(:LIGHTCLAY)
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("An Aurora is protecting your team!"))
      else
        @battle.pbDisplay(_INTL("An Aurora is protecting the opposing team!"))
      end
    else
      attacker.pbOwnSide.effects[PBEffects::AuroraVeil]=8
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("An Aurora is protecting your team!"))
      else
        @battle.pbDisplay(_INTL("An Aurora is protecting the opposing team!"))
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
        attacker.pbIncreaseStat(PBStats::EVASION,1,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Baneful Bunker
################################################################################
class PokeBattle_Move_15C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !PBStuff::RATESHARERS.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority = @battle.pbPriority
    if (@battle.doublebattle && attacker == priority[3]) || (!@battle.doublebattle && attacker == priority[1])
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbRandom(65536)<(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::BanefulBunker]=true
      attacker.effects[PBEffects::ProtectRate]*=3
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} shielded itself against damage!",attacker.pbThis))
      return 0
    else
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end

################################################################################
# Beak Blast
################################################################################
class PokeBattle_Move_15D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    attacker.effects[PBEffects::BeakBlast]=false
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Burn Up
################################################################################
class PokeBattle_Move_15E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbHasType?(:FIRE) || attacker.effects[PBEffects::BurnUp]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.effects[PBEffects::BurnUp]=true
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if (attacker.type1 == PBTypes::FIRE)
      if (attacker.type2 == PBTypes::FIRE)
        attacker.type1=(PBTypes::QMARKS) || 0
      else
        attacker.type1=attacker.type2
      end
    end
    if (attacker.type2 == PBTypes::FIRE)
      attacker.type2=attacker.type1
    end
    @battle.pbDisplay(_INTL("{1} was burnt out!",attacker.pbThis))
    return ret
  end
end

################################################################################
# Decreases the user's Defense by 1 stage. (Spread move)
################################################################################
class PokeBattle_Move_15F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
        attacker.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false, statdropper: attacker) unless attacker.effects[PBEffects::ClangedScales]
        attacker.effects[PBEffects::ClangedScales]=true
      end
    end
    return ret
  end
end

################################################################################
# Core Enforcer
################################################################################
class PokeBattle_Move_160 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.hasMovedThisRound? && !@battle.switchedOut[opponent.index]
      if !(PBStuff::FIXEDABILITIES).include?(opponent.ability)
        opponent.ability = 0  #Cancel out ability
        opponent.effects[PBEffects::GastroAcid]=true
        opponent.effects[PBEffects::Truant]=false
        @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",opponent.pbThis))
        if opponent.effects[PBEffects::Illusion]!=nil 
          opponent.effects[PBEffects::Illusion]=nil
          @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
          @battle.pbDisplay(_INTL("{1}'s {2} was broken!",opponent.pbThis,
          PBAbilities.getName(opponent.ability)))
        end 
      end
    end
    return ret
  end
end

################################################################################
# Fails if this isn't the user's first turn. (First Impression)
################################################################################
class PokeBattle_Move_161 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (attacker.turncount!=1)
  end
end

################################################################################
# Heals target by an amount depending on the terrain. (Floral Healing)
################################################################################
class PokeBattle_Move_162 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.hp==opponent.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",opponent.pbThis))
      return -1
    end
    hpgain=0
    if @battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FAIRYTALEF ||
      (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>1) # Grassy Terrain, Fairytale Field, Flower Garden Field
      hpgain=(opponent.totalhp).floor
    else
      hpgain=(opponent.totalhp/2.0).floor
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",opponent.pbThis))
    if @battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF # Corrosive/Corrosive Mist Field
      if opponent.pbCanPoison?(true)
        opponent.pbPoison(attacker)
        @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
      end
    end
    return 0
  end
end

################################################################################
# If the any allies have Plus or Minus as their ability, raise their
#   Attack and Special Attack by one stage. (Gear Up)
################################################################################
class PokeBattle_Move_163 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.pbPartner.ability == PBAbilities::PLUS ||
       attacker.pbPartner.ability == PBAbilities::MINUS
      if @battle.FE!=17
        if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
           attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::SPATK,false)
          pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
          showanim=true
          if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
            attacker.pbPartner.pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
            showanim=false
          end
          if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::SPATK,false)
            attacker.pbPartner.pbIncreaseStat(PBStats::SPATK,1,abilitymessage:false)
            showanim=false
          end
        else
          @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbPartner.pbThis))
          return -1
        end
      else
        if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
           attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::SPATK,false)
          pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
          showanim=true
          if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
            attacker.pbPartner.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
            showanim=false
          end
          if attacker.pbPartner.pbCanIncreaseStatStage?(PBStats::SPATK,false)
            attacker.pbPartner.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
            showanim=false
          end
        else
          @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbPartner.pbThis))
          return -1
        end
        if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
           attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
          pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
          showanim=true
          if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
            attacker.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
            showanim=false
          end
          if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
            attacker.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
            showanim=false
          end
        else
          @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
          return -1
        end
      end
    else
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end

    return 0
  end
end

################################################################################
# Instruct
################################################################################
class PokeBattle_Move_164 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    otherid = opponent.lastMoveUsed
    # This is needed because it should target the same opponent as before, and use the same moveslot.
    choice = opponent.lastMoveChoice
    begin
      if !choice || choice[1]<0 || !choice[2] || (opponent.moves[choice[1]].id != choice[2].id) || (choice[2].id != otherid) ||
         PBStuff::BLACKLISTS[:INSTRUCT].include?(otherid) || choice[2].zmove || PBStuff::DELAYEDMOVE.include?(@battle.choices[opponent.index][2].id)
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    rescue
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end

    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("{1} instructed {2}!",attacker.pbThis,opponent.pbThis))
    opponent.pbUseMove(choice, {instructed: true, specialusage: false})  # TODO: test whether specialusage should be true or false.
    return 0
  end
end

################################################################################
# Ensures the next hit is critical. (Laser Focus)
################################################################################
class PokeBattle_Move_165 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::LaserFocus]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::LaserFocus]=2
    @battle.pbDisplay(_INTL("{1} is focused!",attacker.pbThis))
    return 0
  end
end

################################################################################
# Moldbreaking moves (Sunsteel Strike/Moongeist Beam)
################################################################################
class PokeBattle_Move_166 < PokeBattle_Move
  #handled elsewhere
end

################################################################################
# Pollen Puff
################################################################################
class PokeBattle_Move_167 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbPartner == opponent
      if opponent.hp==opponent.totalhp
        @battle.pbDisplay(_INTL("{1}'s HP is full!",opponent.pbThis))
        return -1
      end
      hpgain=((opponent.totalhp)/2).floor
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      if !(opponent.ability == PBAbilities::BULLETPROOF || opponent.effects[PBEffects::HealBlock]>0)
        opponent.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1}'s HP was restored.",opponent.pbThis))
        return 0
      else
        @battle.pbDisplay(_INTL("But it failed!",opponent.pbThis))
        return -1
      end
    else
      return super(attacker,opponent,hitnum,alltargets,showanimation)
    end
  end
end

################################################################################
# Psychic Terrain
################################################################################
class PokeBattle_Move_168 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::PSYCHICT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::PSYCHICT,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The terrain became mysterious!"))
    return 0
  end
end

################################################################################
# Heals target by 1/4 of its max HP & removes status conditions. (Purify)
################################################################################
class PokeBattle_Move_169 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.status==0
      @battle.pbDisplay(_INTL("{1} is already healthy!",opponent.pbThis))
      return -1
    else
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.status=0
      opponent.statusCount=0
      @battle.pbDisplay(_INTL("{1} was purified!",opponent.pbThis))
      if attacker.hp!=attacker.totalhp
        hpgain=((attacker.totalhp)/2).floor
        attacker.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} healed itself!",attacker.pbThis))
      end
      return 0
    end
  end
end

################################################################################
# Type depends on the user's. (RevelationDance)
################################################################################
class PokeBattle_Move_16A < PokeBattle_Move
  def pbType(attacker,type=@type)
    type = attacker.type1
    return super(attacker,type)
  end
end

#################################################################################
# Shell Trap
################################################################################
class PokeBattle_Move_16B < PokeBattle_Move

  def pbOnStartUse(attacker)
    @succesful=true
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::ShellTrap] && @succesful
      attacker.effects[PBEffects::ShellTrap]=false
      @battle.pbDisplay(_INTL("{1}'s Shell Trap didn't work.",attacker.name))
      @succesful=false
      return -1
    elsif @succesful
      return super(attacker,opponent,hitnum,alltargets,showanimation)
    else
      return -1
    end
  end

  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::ShellTrapTarget]>=0
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::ShellTrapTarget]])
        attacker.pbRandomTarget(targets)
      end
      attacker.effects[PBEffects::ShellTrapTarget]=-1
    end
  end
end

################################################################################
# Heals user by an amount depending on the weather. (Shore Up)
################################################################################
class PokeBattle_Move_16C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    hpgain=0
    if @battle.FE == PBFields::ASHENB
      hpgain=(attacker.totalhp).floor
    elsif (@battle.pbWeather==PBWeather::SANDSTORM || @battle.FE == PBFields::DESERTF)
      hpgain=(attacker.totalhp*2/3.0).floor
    else
      hpgain=(attacker.totalhp/2.0).floor
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    if (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS) && (attacker.ability == PBAbilities::WATERCOMPACTION)
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE)
        attacker.pbIncreaseStatBasic(PBStats::DEFENSE,2)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Water Compaction sharply raised its Defense!",
          attacker.pbThis,PBAbilities.getName(attacker.ability)))
      end
    end
    return 0
  end
end

################################################################################
# Cures the target's burn (Sparkling Aria)
################################################################################
class PokeBattle_Move_16D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && opponent.status==PBStatuses::BURN
      opponent.pbCureStatus
    end
    return ret
  end
end

################################################################################
# Spectral Thief.
################################################################################
class PokeBattle_Move_16E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    totalboost = 0
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      if opponent.stages[i]>0
        oppboost = opponent.stages[i]
        oppboost *= -1 if attacker.ability == PBAbilities::CONTRARY
        oppboost *= 2 if attacker.ability == PBAbilities::SIMPLE
        attacker.stages[i]+=oppboost
        attacker.stages[i] = attacker.stages[i].clamp(-6, 6)
        totalboost += oppboost
        opponent.stages[i]=0
      end
    end
    if totalboost>0
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1} stole {2}'s stat boosts!",attacker.pbThis,opponent.pbThis))
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end

################################################################################
# Swaps the user's & target's speeds (Speed Swap)
################################################################################
class PokeBattle_Move_16F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    aSwap = attacker.effects[PBEffects::SpeedSwap]
    oSwap = opponent.effects[PBEffects::SpeedSwap]
    if oSwap == 0
      attacker.effects[PBEffects::SpeedSwap]=opponent.speed
    else
      attacker.effects[PBEffects::SpeedSwap]=oSwap
    end
    if aSwap == 0
      opponent.effects[PBEffects::SpeedSwap]=attacker.speed
    else
      opponent.effects[PBEffects::SpeedSwap]=aSwap
    end
    @battle.pbDisplay(_INTL("{1} swapped speeds with {2}!",attacker.pbThis,opponent.pbThis))
    return 0
  end
end

################################################################################
# This round, target becomes the target of attacks that have single targets. (Spotlight)
################################################################################
class PokeBattle_Move_170 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::FollowMe]=true
    if !opponent.pbPartner.isFainted?
      opponent.pbPartner.effects[PBEffects::FollowMe]=false
      opponent.pbPartner.effects[PBEffects::RagePowder]=false
    end
    if @battle.FE == PBFields::BIGTOPA # Big Top Arena
      showanim=true
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
        showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,1,abilitymessage:false)
        showanim=false
      end
      if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        opponent.pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
        showanim=false
      end
      if opponent.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        opponent.pbIncreaseStat(PBStats::SPATK,1,abilitymessage:false)
        showanim=false
      end
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!",opponent.pbThis))
    return 0
  end
end

################################################################################
# Power is doubled if the user's previous move failed (Stomping Tantrum)
################################################################################
class PokeBattle_Move_171 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.effects[PBEffects::Tantrum]
      return basedmg*2
    end
    return basedmg
  end
end

################################################################################
# Strength Sap
################################################################################
class PokeBattle_Move_172 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,true)
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    statstage = opponent.stages[PBStats::ATTACK]

    hpgain = opponent.attack * stagemul[statstage+6] / stagediv[statstage+6]
    hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
    hpgain=(hpgain*1.3).floor if @battle.FE == PBFields::SWAMPF # Swamp Field
    hpgain=(hpgain*1.3).floor if @battle.FE == PBFields::FORESTF # Forest Field
    
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbReduceStat(PBStats::ATTACK,1,abilitymessage:false, statdropper: attacker)
    if attacker.hp!=attacker.totalhp
      attacker.pbRecoverHP(hpgain,true)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    end
    return 0
  end
end

################################################################################
# Throat Chop
################################################################################
class PokeBattle_Move_173 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret = super(attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::ThroatChop]=2
    return ret
  end
end

################################################################################
# Toxic Thread
################################################################################
class PokeBattle_Move_174 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbReduceStat(PBStats::SPEED,1,abilitymessage:false, statdropper: attacker)
    if opponent.pbCanPoison?(true)
      opponent.pbPoison(attacker)
      @battle.pbDisplay(_INTL("{1} is poisoned!",opponent.pbThis))
    end
    return 0
  end
end

################################################################################
# Mind Blown
################################################################################
class PokeBattle_Move_175 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    bearer=@battle.pbCheckGlobalAbility(:DAMP)
    if (@battle.FE == PBFields::MISTYT ||  @battle.FE == PBFields::SWAMPF)
      @battle.pbDisplay(_INTL("The dampness prevents the explosion!",@name))
      return -1
    elsif bearer && !(bearer.moldbroken)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
         bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
      return -1
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 &&
       attacker.ability != PBAbilities::MAGICGUARD
      attacker.pbReduceHP((attacker.totalhp)/2).floor
    end
    return ret
  end
end

################################################################################
# Photon Geyser
################################################################################
class PokeBattle_Move_176 < PokeBattle_Move
  #Moldbreaking handled elsewhere
  def pbIsPhysical?(type=@type)
    attacker = @user
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
    # Physical Stuff
    storedatk = attacker.attack
    atkstage=6
    atkmult = 1.0
    if attacker.class == PokeBattle_Battler
      atkstage=attacker.stages[PBStats::ATTACK]+6
      atkmult *= 1.5 if attacker.hasWorkingItem(:CHOICEBAND)
      atkmult *= 1.5 if attacker.ability == PBAbilities::HUSTLE
      atkmult *= 1.5 if attacker.ability == PBAbilities::TOXICBOOST && (attacker.status==PBStatuses::POISON || @battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF || @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS)
      atkmult *= 1.5 if attacker.ability == PBAbilities::GUTS && attacker.status!=0
      atkmult *= 0.5 if attacker.ability == PBAbilities::SLOWSTART && attacker.turncount<5
      atkmult *= 2 if (attacker.ability == PBAbilities::PUREPOWER && @battle.FE!=37) || attacker.ability == PBAbilities::HUGEPOWER
      atkmult *= 2 if attacker.hasWorkingItem(:THICKCLUB) && ((attacker.pokemon.species == PBSpecies::CUBONE) || (attacker.pokemon.species == PBSpecies::MAROWAK))
      atkmult *= 0.5 if attacker.status==PBStatuses::BURN && !(attacker.ability == PBAbilities::GUTS && attacker.status!=0)
    end
    storedatk*=((stagemul[atkstage]/stagediv[atkstage])*atkmult)
    # Special Stuff
    storedspatk = attacker.spatk
    spatkstage=6
    spatkmult=1.0
    if attacker.class == PokeBattle_Battler
      spatkstage=attacker.stages[PBStats::SPATK]+6
      spatkmult *= 1.5 if attacker.hasWorkingItem(:CHOICESPECS)
      spatkmult *= 2 if attacker.hasWorkingItem(:DEEPSEATOOTH) && (attacker.pokemon.species == PBSpecies::CLAMPERL)
      spatkmult *= 2 if attacker.hasWorkingItem(:LIGHTBALL) && (attacker.pokemon.species == PBSpecies::PIKACHU)
      spatkmult *= 1.5 if attacker.ability == PBAbilities::FLAREBOOST && (attacker.status==PBStatuses::BURN || @battle.FE == PBFields::BURNINGF)
      spatkmult *= 1.5 if attacker.ability == PBAbilities::MINUS && attacker.pbPartner.ability == PBAbilities::PLUS
      spatkmult *= 1.5 if attacker.ability == PBAbilities::PLUS && attacker.pbPartner.ability == PBAbilities::MINUS
      spatkmult *= 1.5 if attacker.ability == PBAbilities::SOLARPOWER && (@battle.pbWeather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
      spatkmult *= 1.3 if attacker.pbPartner.ability == PBAbilities::BATTERY
      spatkmult *= 2 if attacker.ability == PBAbilities::PUREPOWER && @battle.FE == PBFields::PSYCHICT
    end
    storedspatk*=((stagemul[spatkstage]/stagediv[spatkstage])*spatkmult)
    storedspatk= attacker.getSpecialStat if @battle.FE == PBFields::GLITCHF && attacker.class == PokeBattle_Battler
    # Final selection
    if storedatk>storedspatk
      return true
    else
      return false
    end
  end

  def pbIsSpecial?(type=@type)
    return !pbIsPhysical?(type)
  end
end

################################################################################
# Plasma Fists
################################################################################
class PokeBattle_Move_177 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if @battle.state.effects[PBEffects::IonDeluge]!=true
      @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
      @battle.state.effects[PBEffects::IonDeluge] = true
    end
    if !(attacker.item == PBItems::EVERSTONE) && @battle.canChangeFE?(PBFields::ELECTRICT)
      @battle.setField(PBFields::ELECTRICT,true)
      @battle.field.duration=3
      @battle.field.duration=6 if (attacker.item == PBItems::AMPLIFIELDROCK)
      @battle.pbDisplay(_INTL("The terrain became electrified!"))
    end
    return ret
  end
end

#New Gen 8 effects starting below here

################################################################################
# Extra Damage To Megas and similar (Dynamax Cannon and etc)
################################################################################
class PokeBattle_Move_178 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.isMega? || opponent.isUltra? #|| opponent.isGiga?
      basedmg*=2
    end
    return basedmg
  end
end

################################################################################
# Ignores any redirection attempts (Snipe Shot)
################################################################################
class PokeBattle_Move_179 < PokeBattle_Move
  #handled in pbChangeTarget
end

################################################################################
# Eats Berry and then Sharply Raises Defense (Stuff Cheeks)
################################################################################
class PokeBattle_Move_17A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if pbIsBerry?(attacker.item)
      ourberry = attacker.item
      itemname=PBItems.getName(ourberry)
      attacker.item=0
      attacker.pokemon.itemRecycle = ourberry
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==ourberry
      @battle.pbDisplay(_INTL("{1} ate its {2}!",attacker.pbThis,itemname))
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      attacker.pbUseBerry(ourberry,true)
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,true)
       #ret=attacker.pbIncreaseStat(PBStats::DEFENSE,2,false)
       attacker.pbIncreaseStat(PBStats::DEFENSE,2,abilitymessage:false)
      end
      #return ret ? 0 : -1
      return 0
    end
    return -1
  end
end

################################################################################
# Boosts all stats and prevents switching out (No Retreat)
################################################################################
class PokeBattle_Move_17B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::NoRetreat]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
        return -1
      end
      pbShowAnimation(@name,attacker,nil,hitnum,alltargets,showanimation)
      for stat in 1..5
        if attacker.pbCanIncreaseStatStage?(stat,false)
          attacker.pbIncreaseStat(stat,1,abilitymessage:false)
        end
      end
      if attacker.effects[PBEffects::MeanLook]==-1
        attacker.effects[PBEffects::MeanLook]=attacker.index
        @battle.pbDisplay(_INTL("{1} can no longer escape!",attacker.pbThis))
        attacker.effects[PBEffects::NoRetreat] = true
      end
      return 0
    end
  end
end

################################################################################
# Lowers Speed and Forces Fire Weakness (Tar Shot)
################################################################################
class PokeBattle_Move_17C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::TarShot]==true && !opponent.pbCanReduceStatStage?(PBStats::SPEED,false)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbReduceStat(PBStats::SPEED,1, statdropper: attacker) if opponent.pbCanReduceStatStage?(PBStats::SPEED,false)
    if opponent.effects[PBEffects::TarShot]==false
      opponent.effects[PBEffects::TarShot]=true
      @battle.pbDisplay(_INTL("{1} was covered in flammable tar!",opponent.pbThis))
    end
    return 0
  end
end

################################################################################
# Target becomes Psychic type. (Magic Powder)
################################################################################
class PokeBattle_Move_17D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (opponent.ability == PBAbilities::MULTITYPE) ||
      (opponent.ability == PBAbilities::RKSSYSTEM)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.type1=(PBTypes::PSYCHIC)
    opponent.type2=(PBTypes::PSYCHIC)
    typename=PBTypes.getName((PBTypes::PSYCHIC))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# Dragon Darts (Dragon Darts)
################################################################################
class PokeBattle_Move_17E < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return (pbDragonDartTargetting(attacker).length % 2) + 1
  end
end

################################################################################
# All pokemon eat their berries (Teatime)
################################################################################
class PokeBattle_Move_17F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    for mons in @battle.battlers
      if pbIsBerry?(mons.item)
        ourberry = mons.item
        itemname=PBItems.getName(ourberry)
        mons.item=0
        mons.pokemon.itemRecycle = ourberry
        mons.pokemon.itemInitial=0 if mons.pokemon.itemInitial==ourberry
        @battle.pbDisplay(_INTL("{1} ate its {2}!",mons.pbThis,itemname))
        mons.pbUseBerry(ourberry,true) 
      end
    end
    return 0
  end
end

################################################################################
# Traps target and lowers defenses every turn (Octolock)
################################################################################
class PokeBattle_Move_180 < PokeBattle_Move
    def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Octolock]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      if opponent.effects[PBEffects::MeanLook]==-1
        opponent.effects[PBEffects::MeanLook]=opponent.index
        #@battle.pbDisplay(_INTL("{1} can no longer escape!",opponent.pbThis))
      end
      opponent.effects[PBEffects::Octolock] = true
      @battle.pbDisplay(_INTL("{1} was caught in the Octolock!",opponent.pbThis))
      return 0
    end
  end
end

################################################################################
# Double Damage if this pokemon moves before target (Fishious Rend)
################################################################################
class PokeBattle_Move_181 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if !opponent.hasMovedThisRound? || @battle.switchedOut[opponent.index]
      return basedmg*2
    else
      return basedmg
    end
  end
end

################################################################################
# Swaps effects between the sides of the field (Court Change)
################################################################################
class PokeBattle_Move_182 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    sideOneEffects = attacker.pbOwnSide.effects
    sideTwoEffects = attacker.pbOppositeOpposing.pbOwnSide.effects
    attacker.pbOwnSide.effects = sideTwoEffects
    attacker.pbOppositeOpposing.pbOwnSide.effects = sideOneEffects
    @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!",attacker.pbThis))
  end
end

################################################################################
# Cuts HP to boost every stat (Clangorous Soul)
################################################################################
class PokeBattle_Move_183 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      @battle.pbDisplay(_INTL("{1}'s stats are too high!",attacker.pbThis))
      return -1
    end
    clanglife=[(attacker.totalhp/3.0).floor,1].max
    if attacker.hp<=clanglife
      @battle.pbDisplay(_INTL("It was too weak to use the move!"))
      return -1
    end
    attacker.pbReduceHP(clanglife)
    for stat in 1..5
      if attacker.pbCanIncreaseStatStage?(stat,false)
        attacker.pbIncreaseStat(stat,1,abilitymessage:false)
      end
    end
    return 0
  end
end

################################################################################
# Damages based off of defense rather than attack (Body Press)
################################################################################
class PokeBattle_Move_184 < PokeBattle_Move
  # Handled Elsewhere.
end

################################################################################
# Sharply Boosts target's offenses (Decorate)
################################################################################
class PokeBattle_Move_185 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
       !opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      @battle.pbDisplay(_INTL("{1}'s stats are too high!",opponent.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if opponent.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      opponent.pbIncreaseStat(PBStats::SPATK,2,abilitymessage:false)
      showanim=false
    end
    if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      opponent.pbIncreaseStat(PBStats::ATTACK,2,abilitymessage:false)
      showanim=false
    end
    return 0
  end
end

################################################################################
# Boosts Speed and Changes type based on forme (Aura Wheel)
################################################################################
class PokeBattle_Move_186 < PokeBattle_Move
  def pbType(attacker,type=@type)
    type = PBTypes::DARK if attacker.form==1 && attacker.species==PBSpecies::MORPEKO
    return super(attacker,type)
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return if !showanimation
    if attacker.form==1 && attacker.species==PBSpecies::MORPEKO
      @battle.pbAnimation(PBMoves::AURAWHEELMINUS,attacker,opponent,hitnum) #dark type
    else
      @battle.pbAnimation(PBMoves::AURAWHEELPLUS,attacker,opponent,hitnum) #electric type
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,1,abilitymessage:false)
    end
    return true
  end
end

################################################################################
# Heals self and partner 1/4 of max hp (Life Dew)
################################################################################
class PokeBattle_Move_187 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp == attacker.totalhp && attacker.pbPartner.hp == attacker.pbPartner.totalhp
      @battle.pbDisplay(_INTL("Everyone's HP is full!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    hpgain1=((attacker.totalhp+1)/4).floor
    hpgain2=((attacker.pbPartner.totalhp+1)/4).floor
    if attacker.hp != attacker.totalhp
      attacker.pbRecoverHP(hpgain1,true)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    end
    if attacker.pbPartner.totalhp!=0
      if attacker.pbPartner.hp != attacker.pbPartner.totalhp
        attacker.pbPartner.pbRecoverHP(hpgain2,true)
        @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbPartner.pbThis))
      end
    end
    return 0
  end
end

################################################################################
# Protects and sharply lowers def if contact is made (Obstruct)
################################################################################
class PokeBattle_Move_188 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !PBStuff::RATESHARERS.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority = @battle.pbPriority
    if (@battle.doublebattle && attacker == priority[3]) || (!@battle.doublebattle && attacker == priority[1])
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbRandom(65536)<(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::Obstruct]=true
      attacker.effects[PBEffects::ProtectRate]*=3
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} shielded itself against damage!",attacker.pbThis))
      return 0
    else
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end