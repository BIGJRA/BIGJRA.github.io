class PBTargets
  SingleNonUser    = 0x00
  NoTarget         = 0x01
  RandomOpposing   = 0x02
  AllOpposing      = 0x04
  AllNonUsers      = 0x08
  User             = 0x10
  UserSide         = 0x20
  BothSides        = 0x40
  OpposingSide     = 0x80
  Partner          = 0x100
  UserOrPartner    = 0x200
  SingleOpposing   = 0x400
  OppositeOpposing = 0x800
  DragonDarts      = 0x1000
  ThunderRaid      = 0x2000
end


class PokeBattle_Move
  attr_accessor(:id)
  attr_reader(:battle)
# Changed from immutable to mutable to allow for Z-status moves
# changed from: attr_reader(:name)
  attr_accessor(:name)
  attr_reader(:function)
# UPDATE 11/21/2013
# Changed from immutable to mutable to allow for sheer force
# changed from: attr_reader(:basedamage)
  attr_accessor(:basedamage)
  attr_accessor(:type)
  attr_reader(:accuracy)
  attr_reader(:addlEffect)
  attr_reader(:target)
  attr_reader(:priority)
  attr_accessor(:flags)
  attr_reader(:thismove)
  attr_accessor(:pp)
  attr_accessor(:totalpp)
  attr_accessor(:zmove)
  attr_reader(:user)

  NOTYPE          = 0x01
  IGNOREPKMNTYPES = 0x02
  NOWEIGHTING     = 0x04
  NOCRITICAL      = 0x08
  NOREFLECT       = 0x10
  SELFCONFUSE     = 0x20

################################################################################
# Creating a move
################################################################################
  def initialize(battle,move,user)
    @id = move.id
    @battle = battle
    @name = PBMoves.getName(id)   # Get the move's name
    # Get data on the move
    @function    = $pkmn_move[@id][0]
    @basedamage  = $pkmn_move[@id][1]
    @type        = $pkmn_move[@id][2]
    @category    = $pkmn_move[@id][3]
    @accuracy    = $pkmn_move[@id][4]
    #@totalpp     = $pkmn_move[@id][5]
    @addlEffect  = $pkmn_move[@id][6]
    @target      = $pkmn_move[@id][7]
    @priority    = $pkmn_move[@id][8]
    @flags       = $pkmn_move[@id][9]
    @thismove   = move
    @pp         = move.pp   # Can be changed with Mimic/Transform
    @zmove      = false
    @user       = user
  end
  
# This is the code actually used to generate a PokeBattle_Move object.  The
# object generated is a subclass of this one which depends on the move's
# function code (found in the script section PokeBattle_MoveEffect).
  def PokeBattle_Move.pbFromPBMove(battle,move,user)
    className="" if !move
    className=sprintf("PokeBattle_Move_%03X",$pkmn_move[move.id][0]) if move
    if Object.const_defined?(className)
      return Kernel.const_get(className).new(battle,move,user)
    else
      return PokeBattle_UnimplementedMove.new(battle,move,user)
    end
  end

################################################################################
# About the move
################################################################################
# UPDATE 11/16
# simplifies flag usage - can now ask hasFlags?("m")
# to determine if flag `m` is set.
# or also hasFlags?("abcdef") will also work if all flags are set
# This makes it much easier for anyone not versed in bitwise operations
# to define new flags.
# Note: I tested most edge cases of this - although I could've missed something
  def hasFlags?(flag)
    # must be a string
    return false if !flag.is_a? String
    flag.each_byte do |c|
      # must be a lower case letter
      return false if c > 122 || c < 97
      n = c - 97 # number of bits to shift
      # if the nth bit isn't set
      return false if (@flags & (1 << n)) == 0
    end
    return true
  end

  def totalpp
    return @totalpp if @totalpp && @totalpp>0
    return @thismove.totalpp if @thismove
  end

  def to_int
    return @id
  end

  def pbType(type,attacker,opponent)
    if type>=0 && attacker.hasWorkingAbility(:NORMALIZE)
      type=getConst(PBTypes,:NORMAL) || 0
    end
    if $fefieldeffect == 24 && (isConst?(type,PBTypes,:FAIRY))
      type=getConst(PBTypes,:NORMAL) || 0
    end
#### KUROTSUNE - 024 - START
    if type>=0 && attacker.effects[PBEffects::Electrify]==true #Electrify
      type=getConst(PBTypes,:ELECTRIC) || 0
    end # Electrify
#### KUROTSUNE - 024 - END
    case $fefieldeffect
      when 13 # icy
        if isConst?(type,PBTypes,:ROCK)
          type=getConst(PBTypes,:ICE) || 0
        end
      when 20 # ashen beach
        if id == PBMoves::STRENGTH
          type=getConst(PBTypes,:FIGHTING) || 0
        end
      when 26 # murkwater surface
        if (id == PBMoves::MUDSLAP || id == PBMoves::MUDBOMB ||
          id == PBMoves::MUDSHOT || id == PBMoves::THOUSANDWAVES)
          type=getConst(PBTypes,:WATER) || 0
        end
      when 34 # starlight arena
        if id == PBMoves::SOLARBEAM || id == PBMoves::SOLARBLADE
          type=getConst(PBTypes,:FAIRY) || 0
        end
    end
    return type
  end

  def pbIsPhysical?(type)
    if USEMOVECATEGORY
      if $fefieldeffect == 24
        return (!PBTypes.isSpecialType?(type) && @category!=2)
      else
        return @category==0
      end
    else
      return !PBTypes.isSpecialType?(type)
    end
  end

  def pbIsSpecial?(type)
    if USEMOVECATEGORY
      if $fefieldeffect == 24
        return (PBTypes.isSpecialType?(type) && @category!=2)
      else
        return @category==1
      end
    else
      return PBTypes.isSpecialType?(type)
    end
  end

  def pbTargetsAll?(attacker)
    if @target==PBTargets::AllOpposing 
      # TODO: should apply even if partner faints during an attack
      numtargets=0
      numtargets+=1 if !attacker.pbOpposing1.isFainted?
      numtargets+=1 if !attacker.pbOpposing2.isFainted?
      return numtargets>1
    elsif @target==PBTargets::AllNonUsers
      # TODO: should apply even if partner faints during an attack
      numtargets=0
      numtargets+=1 if !attacker.pbOpposing1.isFainted?
      numtargets+=1 if !attacker.pbOpposing2.isFainted?
      numtargets+=1 if !attacker.pbPartner.isFainted?
      return numtargets>1
    end
    return false
  end

  def pbDragonDartTargetting(attacker)
    opp1 = attacker.pbOpposing1
    opp2 = attacker.pbOpposing2
    if opp2.isFainted?
      return [opp1]
    end
    if opp1.isFainted?
      return [opp2]
    end
    if opp2.pbHasType?(:FAIRY) 
      return [opp1]
    end
    if opp1.pbHasType?(:FAIRY) 
      return [opp2]
    end
    invulmoves = [0xC9,0xCA,0xCB,0xCC,0xCD,0xCE]
    if invulmoves.include?(opp2.effects[PBEffects::TwoTurnAttack])
      return [opp1]
    end
    if invulmoves.include?(opp1.effects[PBEffects::TwoTurnAttack])
      return [opp2]
    end
    if opp2.effects[PBEffects::SkyDrop]
      return [opp1]
    end
    if opp1.effects[PBEffects::SkyDrop]
      return [opp2]
    end
    if opp2.effects[PBEffects::Protect] || opp2.effects[PBEffects::SpikyShield] || opp2.effects[PBEffects::BanefulBunker] ||
       opp2.effects[PBEffects::KingsShield] || opp2.effects[PBEffects::Obstruct]
      return [opp1]
    end
    if opp1.effects[PBEffects::Protect] || opp1.effects[PBEffects::SpikyShield] || opp1.effects[PBEffects::BanefulBunker] ||
       opp1.effects[PBEffects::KingsShield] || opp1.effects[PBEffects::Obstruct]
      return [opp2]
    end
    if opp2.effects[PBEffects::Substitute]>0 || opp2.effects[PBEffects::Disguise] ||
       opp2.effects[PBEffects::IceFace]
      return [opp1]
    end
    if opp1.effects[PBEffects::Substitute]>0 || opp1.effects[PBEffects::Disguise] ||
       opp1.effects[PBEffects::IceFace]
      return [opp2]
    end
    return [opp1,opp2]
  end
  
  def pbThunderRaidTargetting(attacker)
    opp1 = attacker.pbOpposing1
    opp2 = attacker.pbOpposing2
    if opp2.isFainted?
      return [opp1]
    end
    if opp1.isFainted?
      return [opp2]
    end
    if opp2.pbHasType?(:GROUND) 
      return [opp1]
    end
    if opp1.pbHasType?(:GROUND) 
      return [opp2]
    end
    targets = []
    for i in 1..5 do
      if rand(2) == 0
        targets.push(opp1)
      else
        targets.push(opp2)
      end
    end
    return targets
  end
  
  def pbNumHits(attacker)
    return 1
  end

  def pbIsMultiHit   # not the same as pbNumHits>1
    return false
  end

  def pbTwoTurnAttack(attacker,checking=false)
    return false
  end

  def pbAdditionalEffect(attacker,opponent)
  end

  def pbCanUseWhileAsleep?
    return false
  end

  def isContactMove?
    return (@flags&0x01)!=0 # flag a: Makes contact
  end

  def canProtectAgainst?
    return (@flags&0x02)!=0 # flag b: Protect/Detect
  end

  def canMagicCoat?
    return (@flags&0x04)!=0 # flag c: Magic Coat
  end

  def canSnatch?
    return (@flags&0x08)!=0 # flag d: Snatch
  end

  def canMirrorMove? # This method isn't used
    return (@flags&0x10)!=0 # flag e: Copyable by Mirror Move
  end

  def canKingsRock?
    return (@flags&0x20)!=0 # flag f: King's Rock
  end

  def canThawUser?
    return (@flags&0x40)!=0 # flag g: Thaws user before moving
  end

  def hasHighCriticalRate?
    return (@flags&0x80)!=0 # flag h: Has high critical hit rate
  end

  def isHealingMove?
    return (@flags&0x100)!=0 # flag i: Is healing move
  end

  def isPunchingMove?
    return (@flags&0x200)!=0 # flag j: Is punching move
  end

  def isSoundBased?
    return (@flags&0x400)!=0 # flag k: Is sound-based move
  end

  def unusableInGravity?
    return (@flags&0x800)!=0 # flag l: Can't use in Gravity
  end
  
  def isBeamMove?
    return (@flags&0x2000)!=0 # flag n: Is a beam move
  end

################################################################################
# This move's type effectiveness
################################################################################
  def pbTypeModifier(type,attacker,opponent,zorovar=false)
    return 4 if type<0
    return 4 if isConst?(type,PBTypes,:GROUND) && opponent.pbHasType?(:FLYING) &&
                opponent.hasWorkingItem(:IRONBALL)
    atype=type # attack type
    otype1=opponent.type1
    otype2=opponent.type2
    if zorovar # ai being fooled by illusion
      otype1=opponent.effects[PBEffects::Illusion].type1 #17
      otype2=opponent.effects[PBEffects::Illusion].type2 #17
    end
    if id == PBMoves::VENAMSKISS
      if isConst?(otype1,PBTypes,:STEEL)
        if !isConst?(otype2,PBTypes,:GRASS)
          otype1=getConst(PBTypes,:GRASS) || 0
          if isConst?(otype2,PBTypes,:STEEL)
            otype2=getConst(PBTypes,:GRASS) || 0
          end
        else
          otype1=getConst(PBTypes,:FAIRY) || 0
        end
      end
      if isConst?(otype2,PBTypes,:STEEL)
        if !isConst?(otype1,PBTypes,:GRASS)
          otype2=getConst(PBTypes,:GRASS) || 0
        else
          otype2=getConst(PBTypes,:FAIRY) || 0
        end
      end
    end
    if isConst?(otype1,PBTypes,:FLYING) && opponent.effects[PBEffects::Roost]
      if isConst?(otype2,PBTypes,:FLYING)
        otype1=getConst(PBTypes,:NORMAL) || 0
      else
        otype1=otype2
      end
    end
    if isConst?(otype2,PBTypes,:FLYING) && opponent.effects[PBEffects::Roost]
      otype2=otype1
    end
    if isConst?(otype1,PBTypes,:FIRE) && opponent.effects[PBEffects::BurnUp]
      if isConst?(otype2,PBTypes,:FIRE)
        otype1=getConst(PBTypes,:QMARKS) || 0
      else
        otype1=otype2
      end
    end
    if isConst?(otype2,PBTypes,:FIRE) && opponent.effects[PBEffects::BurnUp]
      otype2=otype1
    end
    mod1=PBTypes.getEffectiveness(atype,otype1)
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    if $fefieldeffect == 23 || id == PBMoves::THOUSANDARROWS
      mod1=2 if isConst?(otype1,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
      mod2=2 if isConst?(otype2,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
    end
    if opponent.hasWorkingItem(:RINGTARGET)
      mod1=2 if mod1==0
      mod2=2 if mod2==0
    end
    if attacker.hasWorkingAbility(:SCRAPPY) || !@battle.pbOwnedByPlayer?(attacker.index) && attacker.species==PBSpecies::SILVALLY || opponent.effects[PBEffects::Foresight] || (@battle.SilvallyCheck(opponent,PBTypes::NORMAL) rescue nil)
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) &&
        (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) &&
        (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
    end
    if attacker.hasWorkingAbility(:ADAPTABILITY) && $fefieldeffect==5
      mod1=1 if mod1==0
      mod2=1 if mod2==0
    end
    if $fefieldeffect == 29
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) &&
        isConst?(atype,PBTypes,:NORMAL)
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) &&
        isConst?(atype,PBTypes,:NORMAL)
    end
    if $fefieldeffect == 40
      mod1=2 if isConst?(otype1,PBTypes,:NORMAL) &&
        isConst?(atype,PBTypes,:GHOST)
      mod2=2 if isConst?(otype2,PBTypes,:NORMAL) &&
        isConst?(atype,PBTypes,:GHOST)
    end
    if attacker.hasWorkingAbility(:PIXILATE) || 
     attacker.hasWorkingAbility(:AERILATE) || 
     attacker.hasWorkingAbility(:REFRIGERATE) ||
     attacker.hasWorkingAbility(:GALVANIZE) ||
     (attacker.hasWorkingAbility(:LIQUIDVOICE) && isSoundBased?)
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) && isConst?(atype,PBTypes,:NORMAL)
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) && isConst?(atype,PBTypes,:NORMAL)
    end
    if attacker.hasWorkingAbility(:NORMALIZE)
      mod1=2 if isConst?(otype1,PBTypes,(:GROUND || :FAIRY || :FLYING || :NORMAL || :DARK))
      mod1=1 if isConst?(otype1,PBTypes,:STEEL)
      mod1=0 if isConst?(otype1,PBTypes,:GHOST) && !opponent.effects[PBEffects::Foresight]
      mod2=2 if isConst?(otype2,PBTypes,(:GROUND || :FAIRY || :FLYING || :NORMAL || :DARK))
      mod2=1 if isConst?(otype2,PBTypes,:STEEL)
      mod2=0 if isConst?(otype2,PBTypes,:GHOST) && !opponent.effects[PBEffects::Foresight]
    end
    if opponent.effects[PBEffects::Electrify]
      mod1=0 if isConst?(otype1,PBTypes,:GROUND)
      mod1=4 if isConst?(otype1,PBTypes,:FLYING)
      mod1=2 if isConst?(otype1,PBTypes,(:GHOST || :FAIRY || :NORMAL || :DARK))
      mod2=0 if isConst?(otype2,PBTypes,:GROUND)
      mod2=4 if isConst?(otype2,PBTypes,:FLYING)
      mod2=2 if isConst?(otype2,PBTypes,(:GHOST || :FAIRY || :NORMAL || :DARK))
    end
    if $fefieldeffect == 24
      mod1=0 if isConst?(otype1,PBTypes,:GHOST) && isConst?(atype,PBTypes,(:FAIRY || :DARK || :STEEL))
      mod2=0 if isConst?(otype2,PBTypes,:GHOST) && isConst?(atype,PBTypes,(:FAIRY || :DARK || :STEEL))
    end
    if (opponent.effects[PBEffects::Ingrain] || opponent.effects[PBEffects::SmackDown] || (@battle.field.effects[PBEffects::Gravity]>0 rescue nil)) 
      mod1=2 if isConst?(otype1,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
      mod2=2 if isConst?(otype2,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
    end
    if opponent.effects[PBEffects::MiracleEye]
      mod1=2 if isConst?(otype1,PBTypes,:DARK) && isConst?(atype,PBTypes,:PSYCHIC)
      mod2=2 if isConst?(otype2,PBTypes,:DARK) && isConst?(atype,PBTypes,:PSYCHIC)
    end
    return mod1*mod2
  end

  def pbTypeModifierNonBattler(type,attacker,opponent)
    return 4 if type<0
    return 4 if isConst?(type,PBTypes,:GROUND) && opponent.hasType?(:FLYING) &&
                isConst?(opponent.item,PBItems,:IRONBALL)
    atype=type # attack type
    otype1=opponent.type1
    otype2=opponent.type2
    mod1=PBTypes.getEffectiveness(atype,otype1)
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    if $fefieldeffect == 23 || id == PBMoves::THOUSANDARROWS
      mod1=2 if isConst?(otype1,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
      mod2=2 if isConst?(otype2,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
    end
    if isConst?(opponent.item,PBItems,:RINGTARGET)
      mod1=2 if mod1==0
      mod2=2 if mod2==0
    end
    if isConst?(attacker.ability,PBAbilities,:SCRAPPY) || @battle.SilvallyCheck(attacker,PBTypes::NORMAL)
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) &&
        (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) &&
        (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
    end
    if $fefieldeffect == 29
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) &&
        isConst?(atype,PBTypes,:NORMAL)
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) &&
        isConst?(atype,PBTypes,:NORMAL)
    end
    if $fefieldeffect == 40
      mod1=2 if isConst?(otype1,PBTypes,:NORMAL) &&
        isConst?(atype,PBTypes,:GHOST)
      mod2=2 if isConst?(otype2,PBTypes,:NORMAL) &&
        isConst?(atype,PBTypes,:GHOST)
    end
    if isConst?(attacker.ability,PBAbilities,:PIXILATE) || 
     isConst?(attacker.ability,PBAbilities,:AERILATE) || 
     isConst?(attacker.ability,PBAbilities,:REFRIGERATE) ||
     isConst?(attacker.ability,PBAbilities,:GALVANIZE) ||
     (isConst?(attacker.ability,PBAbilities,:LIQUIDVOICE) && isSoundBased?)
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) && isConst?(atype,PBTypes,:NORMAL)
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) && isConst?(atype,PBTypes,:NORMAL)
    end
    if attacker.hasWorkingAbility(:ADAPTABILITY) && $fefieldeffect==5
      mod1=1 if mod1==0
      mod2=1 if mod2==0
    end
    if isConst?(attacker.ability,PBAbilities,:NORMALIZE)
      mod1=2 if isConst?(otype1,PBTypes,(:GROUND || :FAIRY || :FLYING || :NORMAL || :DARK))
      mod1=1 if isConst?(otype1,PBTypes,:STEEL)
      mod1=0 if isConst?(otype1,PBTypes,:GHOST) #&& !opponent.effects[PBEffects::Foresight]
      mod2=2 if isConst?(otype2,PBTypes,(:GROUND || :FAIRY || :FLYING || :NORMAL || :DARK))
      mod2=1 if isConst?(otype2,PBTypes,:STEEL)
      mod2=0 if isConst?(otype2,PBTypes,:GHOST) #&& !opponent.effects[PBEffects::Foresight]
    end 
    if $fefieldeffect == 24
      mod1=0 if isConst?(otype1,PBTypes,:GHOST) && isConst?(atype,PBTypes,(:FAIRY || :DARK || :STEEL))
      mod2=0 if isConst?(otype2,PBTypes,:GHOST) && isConst?(atype,PBTypes,(:FAIRY || :DARK || :STEEL))
    end   
    if @battle.field.effects[PBEffects::Gravity]>0
      mod1=2 if isConst?(otype1,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
      mod2=2 if isConst?(otype2,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
    end
    return mod1*mod2
  end
  
  def pbTypeModMessages(type,attacker,opponent)
    return 4 if type<0
    if (opponent.hasWorkingAbility(:SAPSIPPER) && (isConst?(type,PBTypes,:GRASS) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::GRASS)) && 
       !(opponent.moldbroken)
      if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK)
        opponent.pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end
    if (opponent.hasWorkingAbility(:STORMDRAIN) && (isConst?(type,PBTypes,:WATER) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::WATER)) ||
       (opponent.hasWorkingAbility(:LIGHTNINGROD) && (isConst?(type,PBTypes,:ELECTRIC) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::ELECTRIC)) &&
       !(opponent.moldbroken)
      if opponent.pbCanIncreaseStatStage?(PBStats::SPATK)
        opponent.pbIncreaseStatBasic(PBStats::SPATK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end
    if ((isConst?(opponent.ability,PBAbilities,:MOTORDRIVE)) || opponent.hasWorkingItem(:SHOCKDRIVE) && (opponent.pokemon.species == PBSpecies::GENESECT) && $fefieldeffect==24) &&
      (isConst?(type,PBTypes,:ELECTRIC) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::ELECTRIC) &&
      !(opponent.moldbroken) 
      if opponent.pbCanIncreaseStatStage?(PBStats::SPEED)
        if $fefieldeffect == 17
          opponent.pbIncreaseStatBasic(PBStats::SPEED,2)
          @battle.pbCommonAnimation("StatUp",opponent,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Speed!",
          opponent.pbThis,PBAbilities.getName(opponent.ability)))
        else
          opponent.pbIncreaseStatBasic(PBStats::SPEED,1)
          @battle.pbCommonAnimation("StatUp",opponent,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",
          opponent.pbThis,PBAbilities.getName(opponent.ability)))
        end
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
        opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end    
    if isConst?(opponent.species,PBSpecies,:SKUNTANK) && opponent.hasWorkingItem(:SKUNCREST) && 
      (isConst?(type,PBTypes,:GROUND) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::GROUND) &&
      !(opponent.moldbroken) 
      if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK)
        opponent.pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s Crest raised its Attack!",
        opponent.pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s Crest made {2} ineffective!",
        opponent.pbThis,self.name))
      end
      return 0
    end
    if isConst?(opponent.species,PBSpecies,:WHISCASH) && opponent.hasWorkingItem(:WHISCREST) && 
      (isConst?(type,PBTypes,:GRASS) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::GRASS) &&
      !(opponent.moldbroken) 
      if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK)
        opponent.pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s Crest raised its Attack!",
        opponent.pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s Crest made {2} ineffective!",
        opponent.pbThis,self.name))
      end
      return 0
    end
    if ((opponent.hasWorkingAbility(:DRYSKIN) && !(opponent.moldbroken)) && (isConst?(type,PBTypes,:WATER) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::WATER)) ||
       (opponent.hasWorkingAbility(:VOLTABSORB) && !(opponent.moldbroken) && (isConst?(type,PBTypes,:ELECTRIC) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::ELECTRIC)) ||
       (opponent.hasWorkingAbility(:WATERABSORB) && !(opponent.moldbroken) && (isConst?(type,PBTypes,:WATER) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::WATER)) ||
       (isConst?(opponent.species,PBSpecies,:DRUDDIGON) && opponent.hasWorkingItem(:DRUDDICREST) && !(opponent.moldbroken) && (isConst?(type,PBTypes,:FIRE) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::FIRE))
       if opponent.effects[PBEffects::HealBlock]==0
        if opponent.pbRecoverHP((opponent.totalhp/4).floor,true)>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",
             opponent.pbThis,PBAbilities.getName(opponent.ability)))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} useless!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),@name))
        end
        return 0
      end
    end
    if $fefieldeffect == 12 && @battle.pbWeather==PBWeather::SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA) &&
     (opponent.pbHasType?(:WATER) || opponent.pbHasType?(:GRASS)) && isConst?(type,PBTypes,:WATER)
      if opponent.effects[PBEffects::HealBlock]==0
        if opponent.pbRecoverHP((opponent.totalhp/4).floor,true)>0
          @battle.pbDisplay(_INTL("{1} instead restored {2}'s HP!",
          @name,opponent.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} was made useless!",
          @name))
        end
        return 0
      end
    end
    if isConst?(opponent.ability,PBAbilities,:BULLETPROOF) && !(opponent.moldbroken)
      if (id == PBMoves::ACIDSPRAY || id == PBMoves::AURASPHERE ||
       id == PBMoves::BARRAGE || id == PBMoves::BULLETSEED ||
       id == PBMoves::EGGBOMB || id == PBMoves::ELECTROBALL ||
       id == PBMoves::ENERGYBALL || id == PBMoves::FOCUSBLAST ||
       id == PBMoves::GYROBALL || id == PBMoves::ICEBALL ||
       id == PBMoves::MAGNETBOMB || id == PBMoves::MISTBALL ||
       id == PBMoves::MUDBOMB || id == PBMoves::OCTAZOOKA ||
       id == PBMoves::ROCKWRECKER || id == PBMoves::SEARINGSHOT ||
       id == PBMoves::SEEDBOMB || id == PBMoves::SHADOWBALL ||
       id == PBMoves::SLUDGEBOMB || id == PBMoves::WEATHERBALL ||
       id == PBMoves::ZAPCANNON || id == PBMoves::BEAKBLAST)
        @battle.pbDisplay(_INTL("{1}'s {2} blocked the attack!",
        opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
        return 0
      end
    end
    if $fefieldeffect == 14 && (opponent.effects[PBEffects::Substitute]>0 ||
     opponent.stages[PBStats::EVASION] > 0)
      if (id == PBMoves::ACIDSPRAY || id == PBMoves::AURASPHERE ||
       id == PBMoves::BARRAGE || id == PBMoves::BULLETSEED ||
       id == PBMoves::EGGBOMB || id == PBMoves::ELECTROBALL ||
       id == PBMoves::ENERGYBALL || id == PBMoves::FOCUSBLAST ||
       id == PBMoves::GYROBALL || id == PBMoves::ICEBALL ||
       id == PBMoves::MAGNETBOMB || id == PBMoves::MISTBALL ||
       id == PBMoves::MUDBOMB || id == PBMoves::OCTAZOOKA ||
       id == PBMoves::ROCKWRECKER || id == PBMoves::SEARINGSHOT ||
       id == PBMoves::SEEDBOMB || id == PBMoves::SHADOWBALL ||
       id == PBMoves::SLUDGEBOMB || id == PBMoves::WEATHERBALL ||
       id == PBMoves::ZAPCANNON || id == PBMoves::BEAKBLAST)
        @battle.pbDisplay(_INTL("{1} hid behind a rock to dodge the attack!",
        opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
        return 0
      end
    end
    if opponent.hasWorkingAbility(:FLASHFIRE) && !(opponent.moldbroken) && $fefieldeffect!=39 &&
       (isConst?(type,PBTypes,:FIRE) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::FIRE)
      if !opponent.effects[PBEffects::FlashFire]
        opponent.effects[PBEffects::FlashFire]=true
        @battle.pbDisplay(_INTL("{1}'s {2} activated!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end
    if opponent.hasWorkingItem(:BURNDRIVE) && (opponent.pokemon.species == PBSpecies::GENESECT) && $fefieldeffect==24 &&
       (isConst?(type,PBTypes,:FIRE) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::FIRE)
      if !opponent.effects[PBEffects::FlashFire]
        opponent.effects[PBEffects::FlashFire]=true
        @battle.pbDisplay(_INTL("{1}'s {2} activated!",
           opponent.pbThis,PBItems.getName(opponent.item)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBItems.getName(opponent.item),self.name))
      end
      return 0
    end
    if opponent.hasWorkingItem(:CHILLDRIVE) && (opponent.pokemon.species == PBSpecies::GENESECT) && $fefieldeffect==24 &&
      (isConst?(type,PBTypes,:ICE) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::ICE)
      if opponent.effects[PBEffects::HealBlock]==0
        if opponent.pbRecoverHP((opponent.totalhp/4).floor,true)>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",
          opponent.pbThis,PBItems.getName(opponent.item)))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} useless!",
          opponent.pbThis,PBItems.getName(opponent.item),self.name))
        end
        return 0
      end
     return 0
    end
    if opponent.hasWorkingItem(:DOUSEDRIVE) && (opponent.pokemon.species == PBSpecies::GENESECT) && $fefieldeffect==24 &&
      (isConst?(type,PBTypes,:ICE) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::WATER)
      if opponent.effects[PBEffects::HealBlock]==0
        if opponent.pbRecoverHP((opponent.totalhp/4).floor,true)>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",
          opponent.pbThis,PBItems.getName(opponent.item)))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} useless!",
          opponent.pbThis,PBItems.getName(opponent.item),self.name))
        end
        return 0
      end
     return 0
    end
    if opponent.hasWorkingAbility(:MAGMAARMOR) && (isConst?(type,PBTypes,:FIRE) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::FIRE) &&
     ($fefieldeffect == 16 || $fefieldeffect == 32 || $fefieldeffect == 45) && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
       opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      return 0
    end
    if ($fefieldeffect == 21 || $fefieldeffect == 26) &&
      (isConst?(type,PBTypes,:GROUND) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::GROUND)
      @battle.pbDisplay(_INTL("...But there was no solid ground to attack from!"))
      return 0
    end
    if $fefieldeffect == 22 && (isConst?(type,PBTypes,:FIRE) || FieldTypeChange(attacker,opponent,1,true)==PBTypes::FIRE)
      @battle.pbDisplay(_INTL("...But the attack was doused instantly!"))
      return 0
    end
    #Telepathy
    if opponent.hasWorkingAbility(:TELEPATHY) && 
     @basedamage>0 &&
     !(opponent.moldbroken)
      partner=attacker.pbPartner
      if opponent.index == partner.index
        # if !@battle.pbIsOpposing?(attacker.index) #If it's your partner
        @battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",opponent.pbThis))
        return 0
      end
    end
    # UPDATE Implementing Flying Press + Freeze Dry
    typemod=pbTypeModifier(type,attacker,opponent)
    typemod2= nil
    typemod3= nil
    # Field Effect type changes go here
    if $fefieldeffect!=0
      typemod=FieldTypeChange(attacker,opponent,typemod,false)
    end
    if $fefieldeffect == 22
      if isConst?(type,PBTypes,:WATER) && opponent.pbHasType?(PBTypes::WATER)
        typemod *= 2
      end
    end
    if $fefieldeffect == 24
      if isConst?(type,PBTypes,:DRAGON)
        typemod = 4
      end
      if isConst?(type,PBTypes,:GHOST) && opponent.pbHasType?(PBTypes::PSYCHIC)
        typemod = 0
      end
      if isConst?(type,PBTypes,:BUG) && opponent.pbHasType?(PBTypes::POISON)
        typemod *= 4
      end
      if isConst?(type,PBTypes,:ICE) && opponent.pbHasType?(PBTypes::FIRE)
        typemod *= 2
      end
      if isConst?(type,PBTypes,:POISON) && opponent.pbHasType?(PBTypes::BUG)
        typemod *= 2
      end
      if (isConst?(type,PBTypes,:GHOST) || isConst?(type,PBTypes,:DARK)) &&
       opponent.pbHasType?(PBTypes::STEEL)
        typemod /= 2
      end
    end
    if $fefieldeffect == 29
      if isConst?(type,PBTypes,:NORMAL) && (opponent.pbHasType?(PBTypes::DARK) ||
       opponent.pbHasType?(PBTypes::GHOST))
        typemod *= 2
      end
    end
    if $fefieldeffect == 31
      if isConst?(type,PBTypes,:STEEL) && (opponent.pbHasType?(PBTypes::DRAGON))
        typemod *= 2
      end
    end
    if $fefieldeffect == 40
      if isConst?(type,PBTypes,:GHOST) && (opponent.pbHasType?(PBTypes::NORMAL))
        typemod *= 2
      end
    end
    if id == PBMoves::FREEZEDRY && opponent.pbHasType?(PBTypes::WATER)
      typemod *= 4
    end
    if id == PBMoves::SPIRITBREAK && opponent.pbHasType?(PBTypes::GHOST) &&
     ($fefieldeffect == 29 || $fefieldeffect == 40)
      typemod *= 2
    end   
    if id == PBMoves::CUT && opponent.pbHasType?(PBTypes::GRASS) &&
     $fefieldeffect == 33 && $fecounter > 0 
      typemod *= 2
    end   
    if $fefieldeffect == 42
      if isConst?(type,PBTypes,:GRASS) && opponent.pbHasType?(PBTypes::STEEL)
        typemod *= 4
      end
      if isConst?(type,PBTypes,:FAIRY) && opponent.pbHasType?(PBTypes::STEEL)
        typemod *= 4
      end
      if isConst?(type,PBTypes,:POISON) && opponent.pbHasType?(PBTypes::GRASS)
        typemod /= 2
      end
      if isConst?(type,PBTypes,:POISON) && opponent.pbHasType?(PBTypes::FAIRY)
        typemod /= 2
      end
      if isConst?(type,PBTypes,:DARK) && opponent.pbHasType?(PBTypes::FAIRY)
        typemod *= 2
      end
      if isConst?(type,PBTypes,:FAIRY) && opponent.pbHasType?(PBTypes::DARK)
        typemod /= 2
      end
    end
    if $fefieldeffect == 45  
      if isConst?(type,PBTypes,:FIRE) && opponent.pbHasType?(PBTypes::GHOST)  
        typemod *= 2  
      end  
    end
    if isConst?(opponent.species,PBSpecies,:GLACEON) && opponent.hasWorkingItem(:GLACCREST)
      if isConst?(type,PBTypes,:ROCK) || isConst?(type,PBTypes,:FIGHTING)
        typemod /= 4
      end
    end
    if isConst?(opponent.species,PBSpecies,:LEAFEON) && opponent.hasWorkingItem(:LEAFCREST)
      if isConst?(type,PBTypes,:FIRE) || isConst?(type,PBTypes,:FLYING)
        typemod /= 4
      end
    end
    if isConst?(opponent.species,PBSpecies,:LUXRAY) && opponent.hasWorkingItem(:LUXCREST)
      if isConst?(type,PBTypes,:DARK) || isConst?(type,PBTypes,:GHOST)
        typemod /= 2
      end
      if isConst?(type,PBTypes,:PSYCHIC)
        typemod = 0
      end      
    end
    # Custom Terrains
    if @battle.field.effects[PBEffects::ElectricTerrain]>0 && $fefieldeffect!=1 
      if ((id == PBMoves::EXPLOSION || id == PBMoves::SELFDESTRUCT ||
            id == PBMoves::SMACKDOWN || id == PBMoves::HURRICANE ||
            id == PBMoves::HYDROVORTEX ||
            id == PBMoves::THOUSANDARROWS) && $fefieldeffect!=1) || 
        ((id == PBMoves::SURF || id == PBMoves::MUDDYWATER) && $fefieldeffect!=18 && $fefieldeffect!=1)      
        typemod2=pbTypeModifier(PBTypes::ELECTRIC,attacker,opponent)
        typemod3= ((typemod*typemod2) * 0.25).ceil
        typemod=typemod3
        typeChange=PBTypes::ELECTRIC
      end  
    end
    if isConst?(pbType(type,attacker,opponent),PBTypes,:NORMAL) && !pbIsPhysical?(pbType(@type,attacker,opponent)) && @battle.field.effects[PBEffects::Rainbow]>0 && $fefieldeffect!=9 # Rainbow Field
      randoms=[]
      rand=1+rand(17)
      randoms.push(rand)
      typemod2=pbTypeModifier(randoms[0],attacker,opponent)
      typemod3= ((typemod*typemod2) * 0.25).ceil
      typemod=typemod3
      typeChange=randoms[0]
    end
    if isConst?(opponent.species,PBSpecies,:SAMUROTT) && opponent.hasWorkingItem(:SAMUCREST)
      if isConst?(type,PBTypes,:DARK) || isConst?(type,PBTypes,:BUG) || isConst?(type,PBTypes,:ROCK)
        typemod /= 2
      end
    end
    if isConst?(opponent.species,PBSpecies,:NOCTOWL) && opponent.hasWorkingItem(:NOCCREST)
      if isConst?(type,PBTypes,:PSYCHIC) || isConst?(type,PBTypes,:FIGHTING)
        typemod /= 2
      end
    end
    if @battle.pbWeather==PBWeather::STRONGWINDS && 
     (opponent.pbHasType?(PBTypes::FLYING) && 
     !opponent.effects[PBEffects::Roost]) &&
     (isConst?(type,PBTypes,:ELECTRIC) || isConst?(type,PBTypes,:ICE) ||
     isConst?(type,PBTypes,:ROCK) )
      #if !(attacker.hasWorkingAbility(:CLOUDNINE) || opponent.hasWorkingAbility(:CLOUDNINE))
        typemod /= 2
      #end
    end
    if ($fefieldeffect == 28) && # Ice-fields Ice Scales\
     ((opponent.hasWorkingAbility(:ICESCALES) ) && 
     (isConst?(type,PBTypes,:FIGHT) || isConst?(type,PBTypes,:FIRE) ||
     isConst?(type,PBTypes,:ROCK) || isConst?(type,PBTypes,:STEEL)) && !(opponent.moldbroken))
      typemod /= 2
    end
    if $fefieldeffect == 32 && # Dragons Den Multiscale
     (opponent.hasWorkingAbility(:MULTISCALE) || @battle.SilvallyCheck(opponent,PBTypes::DRAGON)) && 
     (isConst?(type,PBTypes,:FAIRY) || isConst?(type,PBTypes,:ICE) ||
     isConst?(type,PBTypes,:DRAGON)) && !(opponent.moldbroken)
      typemod /= 2
    end
    if $fefieldeffect == 42 && # Bewitched Woods Pastel Veil
     (opponent.hasWorkingAbility(:PASTELVEIL)) && 
     (isConst?(type,PBTypes,:POISON) || isConst?(type,PBTypes,:STEEL)) && 
     !(opponent.moldbroken)
      typemod /= 2
    end
    if !($fefieldeffect==36) && isConst?(opponent.species,PBSpecies,:TORTERRA) && isConst?(opponent.item,PBItems,:TORCREST)
      temptypemod = typemod
      #temptypemod = 8 if typemod == 0 
      temptypemod = 16 if typemod == 1
      temptypemod = 8 if typemod == 2
      temptypemod = 2 if typemod == 8
      temptypemod = 1 if typemod == 16
      temptypemod = 0.5 if typemod == 32
      temptypemod = 32 if typemod == 0.5
      typemod = temptypemod
    end
    if id == PBMoves::FLYINGPRESS
      if $fefieldeffect==43 
        if (opponent.hasType?(PBTypes::GRASS) || opponent.hasType?(PBTypes::FIGHTING) || opponent.hasType?(PBTypes::BUG) || opponent.hasType?(PBTypes::FIGHTING))
          typemod*=2
        end
      else
        typemod2=pbTypeModifier(PBTypes::FLYING,attacker,opponent)
        typemod3= ((typemod*typemod2)/4)
        typemod=typemod3
      end
    end
    if typemod==0
      if @function==0x111
        return 1
      else        
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      end      
    end
    return typemod
  end

  def FieldTypeChange(attacker,opponent,typemod,absorbtion=false)
    case $fefieldeffect
      when 1 # Electric Field
        if (id == PBMoves::EXPLOSION || id == PBMoves::SELFDESTRUCT ||
         id == PBMoves::SMACKDOWN || id == PBMoves::SURF ||
         id == PBMoves::MUDDYWATER || id == PBMoves::HURRICANE ||
         id == PBMoves::THOUSANDARROWS || id == PBMoves::HYDROVORTEX)
          typemod2=pbTypeModifier(PBTypes::ELECTRIC,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::ELECTRIC
        end
      when 5 # Chess Field
        if (id == PBMoves::STRENGTH || id == PBMoves::PSYCHIC ||
         id == PBMoves::BARRAGE)
          typemod2=pbTypeModifier(PBTypes::ROCK,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::ROCK
        end
      when 7 # Burning Field
        if (id == PBMoves::SMACKDOWN || id == PBMoves::THOUSANDARROWS || 
           id == PBMoves::ROCKSLIDE || id == PBMoves::SMOG ||
           id == PBMoves::CLEARSMOG)
          typemod2=pbTypeModifier(PBTypes::FIRE,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::FIRE
        end
      when 8 # Swamp Field
        if (id == PBMoves::SMACKDOWN || id == PBMoves::THOUSANDARROWS)
          typemod2=pbTypeModifier(PBTypes::WATER,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::WATER
        end
      when 9
        if isConst?(pbType(type,attacker,opponent),PBTypes,:NORMAL) &&
         !pbIsPhysical?(pbType(@type,attacker,opponent)) # Rainbow Field
          randoms=[]
          rand=1+rand(17)
          randoms.push(rand)
          typemod2=pbTypeModifier(randoms[0],attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=randoms[0]
        end
      when 10 # Corrosive Field
        if isConst?(pbType(type,attacker,opponent),PBTypes,:GRASS)
          typemod2=pbTypeModifier(PBTypes::POISON,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::POISON
        end
        if (id == PBMoves::SMACKDOWN || id == PBMoves::MUDSLAP ||
         id == PBMoves::MUDSHOT || id == PBMoves::MUDDYWATER ||
         id == PBMoves::WHIRLPOOL || id == PBMoves::MUDBOMB || 
         id == PBMoves::THOUSANDARROWS)
          typemod2=pbTypeModifier(PBTypes::POISON,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::POISON
        end
      when 11 # Corrosive Mist Field
        if isConst?(pbType(type,attacker,opponent),PBTypes,:FLYING) &&
        !pbIsPhysical?(pbType(@type,attacker,opponent))
          typemod2=pbTypeModifier(PBTypes::POISON,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::POISON
        end
        if (id == PBMoves::BUBBLE || id == PBMoves::BUBBLEBEAM ||
         id == PBMoves::ENERGYBALL || id == PBMoves::SPARKLINGARIA ||
         id == PBMoves::APPLEACID)
          typemod2=pbTypeModifier(PBTypes::POISON,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::POISON
        end
      when 14 # Rocky Field
        if (id == PBMoves::ROCKCLIMB || id == PBMoves::EARTHQUAKE ||
         id == PBMoves::MAGNITUDE || id == PBMoves::STRENGTH ||
         id == PBMoves::BULLDOZE)
          typemod2=pbTypeModifier(PBTypes::ROCK,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::ROCK
        end
      when 15 # Forest Field
        if (id == PBMoves::CUT || id == PBMoves::AIRSLASH ||
            id == PBMoves::GALESTRIKE || id == PBMoves::SLASH ||
            id == PBMoves::FURYCUTTER || id == PBMoves::AIRCUTTER ||
            id == PBMoves::PSYCHOCUT || id == PBMoves::BREAKINGSWIPE)
          typemod2=pbTypeModifier(PBTypes::GRASS,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::GRASS
        end
      when 16 # Volcanic Top
        if isConst?(pbType(type,attacker,opponent),PBTypes,:ROCK)
          typemod2=pbTypeModifier(PBTypes::FIRE,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::FIRE
        end
        if (id == PBMoves::EXPLOSION || id == PBMoves::SELFDESTRUCT ||
           id == PBMoves::MAGNETBOMB || id == PBMoves::EGGBOMB ||
           id == PBMoves::DIVE || 
           id == PBMoves::SEISMICTOSS || id == PBMoves::DIG)
          typemod2=pbTypeModifier(PBTypes::FIRE,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::FIRE
        end
        if (id == PBMoves::OMINOUSWIND || id == PBMoves::SILVERWIND ||
         id == PBMoves::RAZORWIND || id == PBMoves::ICYWIND ||
         id == PBMoves::GUST || id == PBMoves::TWISTER ||
         id == PBMoves::PRECIPICEBLADES || id == PBMoves::SMOG ||
         id == PBMoves::CLEARSMOG)
          typemod2=pbTypeModifier(PBTypes::FIRE,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::FIRE
        end
      when 18 # Shortcircuit Field
        if (id == PBMoves::SURF || id == PBMoves::MUDDYWATER ||
         id == PBMoves::MAGNETBOMB || id == PBMoves::GYROBALL ||
         id == PBMoves::GEARGRIND || id == PBMoves::HYDROVORTEX ||
         id == PBMoves::STEELBEAM)
          typemod2=pbTypeModifier(PBTypes::ELECTRIC,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::ELECTRIC
        end
        if isConst?(pbType(type,attacker,opponent),PBTypes,:STEEL) && attacker.hasWorkingAbility(:STEELWORKER)
          typemod2=pbTypeModifier(PBTypes::ELECTRIC,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::STEEL
        end        
      when 19 # Wasteland Field
        if (id == PBMoves::MUDBOMB || id == PBMoves::MUDSLAP ||
         id == PBMoves::MUDSHOT)
          typemod2=pbTypeModifier(PBTypes::POISON,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::POISON
        end
      when 20 # Ashen Beach
        if (id == PBMoves::STRENGTH)
          typemod2=pbTypeModifier(PBTypes::PSYCHIC,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::PSYCHIC
        end
      when 22 # Underwater
        if isConst?(pbType(type,attacker,opponent),PBTypes,:GROUND) || 
         id == PBMoves::GRAVAPPLE || id == PBMoves::DRAGONDARTS
          typemod2=pbTypeModifier(PBTypes::WATER,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::WATER
        end
      when 25 # Crystal Cavern
        if isConst?(type,PBTypes,:ROCK) || (id == PBMoves::JUDGMENT ||
          id == PBMoves::ROCKCLIMB || id == PBMoves::STRENGTH ||
          id == PBMoves::MULTIATTACK || id == PBMoves::PRISMATICLASER)
          if !defined?($randtype)
            $randtype = 1+rand(4)
          else
            if $randtype==0
              $randtype = 1+rand(4)
            end
          end
          case $randtype
            when 1
              typemod2=pbTypeModifier(PBTypes::WATER,attacker,opponent)
              typemod3= ((typemod*typemod2) * 0.25).ceil
              typemod=typemod3
              typeChange=PBTypes::WATER
            when 2
              typemod2=pbTypeModifier(PBTypes::GRASS,attacker,opponent)
              typemod3= ((typemod*typemod2) * 0.25).ceil
              typemod=typemod3
              typeChange=PBTypes::GRASS
            when 3
              typemod2=pbTypeModifier(PBTypes::FIRE,attacker,opponent)
              typemod3= ((typemod*typemod2) * 0.25).ceil
              typemod=typemod3
              typeChange=PBTypes::FIRE
            when 4
              typemod2=pbTypeModifier(PBTypes::PSYCHIC,attacker,opponent)
              typemod3= ((typemod*typemod2) * 0.25).ceil
              typemod=typemod3
              typeChange=PBTypes::PSYCHIC
          end
        end
      when 26 # Murkwater Surface
        if isConst?(pbType(type,attacker,opponent),PBTypes,:WATER) || id == PBMoves::MUDBOMB || 
        id == PBMoves::MUDSLAP || id == PBMoves::MUDSHOT || 
        id == PBMoves::SMACKDOWN || id == PBMoves::THOUSANDWAVES
          typemod2=pbTypeModifier(PBTypes::POISON,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::POISON
        end
        if id == PBMoves::SLUDGEWAVE
          typemod2=pbTypeModifier(PBTypes::WATER,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::WATER
        end
        if id == PBMoves::APPLEACID
          typemod2=pbTypeModifier(PBTypes::POISON,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::POISON
        end
      when 28 # Snowy Mountain
        if isConst?(pbType(type,attacker,opponent),PBTypes,:ROCK)
          typemod2=pbTypeModifier(PBTypes::ICE,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::ICE
        end
      when 31 # Fairy Tale
        if isConst?(pbType(type,attacker,opponent),PBTypes,:FIRE)
          typemod2=pbTypeModifier(PBTypes::DRAGON,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::DRAGON
        end
      when 32 # Dragon's Den
        if (id == PBMoves::SMACKDOWN || id == PBMoves::THOUSANDARROWS)
          typemod2=pbTypeModifier(PBTypes::FIRE,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::FIRE
        end
        if (id == PBMoves::STRENGTH || id == PBMoves::ROCKCLIMB)
          typemod2=pbTypeModifier(PBTypes::ROCK,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::ROCK
        end
      when 34 # Starlight Arena
        if isConst?(pbType(type,attacker,opponent),PBTypes,:DARK)
          typemod2=pbTypeModifier(PBTypes::FAIRY,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::FAIRY
        end
        if (id == PBMoves::DOOMDUMMY)
          typemod2=pbTypeModifier(PBTypes::FIRE,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::FIRE
        end
      when 35 # New World
        if (id == PBMoves::DOOMDUMMY)
          typemod2=pbTypeModifier(PBTypes::FIRE,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::FIRE
        end
      when 36 # Inverse Field
        temptypemod = typemod
        temptypemod = 8 if typemod == 0 && !(isConst?(opponent.species,PBSpecies,:TORTERRA) && 
         isConst?(opponent.item,PBItems,:TORCREST))
        temptypemod = 16 if typemod == 1
        temptypemod = 8 if typemod == 2
        temptypemod = 2 if typemod == 8
        temptypemod = 1 if typemod == 16
        temptypemod = 0.5 if typemod == 32
        temptypemod = 32 if typemod == 0.5
        typemod = temptypemod
      when 37 # Psychic Terrain
        if (id == PBMoves::STRENGTH || id == PBMoves::ANCIENTPOWER ||
         id == PBMoves::DRAGONPULSE|| id == PBMoves::WATERPULSE)
          typemod2=pbTypeModifier(PBTypes::PSYCHIC,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::PSYCHIC
        end
      when 39 # Angie
        if (id == PBMoves::SURF || id == PBMoves::WATERPULSE ||
         id == PBMoves::DARKPULSE || id == PBMoves::NIGHTSLASH ||
         id == PBMoves::HYDROPUMP|| id == PBMoves::MUDDYWATER)
          typemod2=pbTypeModifier(PBTypes::ICE,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::ICE
        end
      when 40 # Haunted
        if (id == PBMoves::FLAMEBURST || id == PBMoves::FIRESPIN || 
            id == PBMoves::INFERNO || id == PBMoves::FLAMECHARGE)
          typemod2=pbTypeModifier(PBTypes::GHOST,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::GHOST
        end
      when 41 # Corrupted Cave
        if (id == PBMoves::ROCKSLIDE || id == PBMoves::SMACKDOWN ||
         id == PBMoves::STONEEDGE|| id == PBMoves::ROCKTOMB ||
         id == PBMoves::DIAMONDSTORM || id == PBMoves::APPLEACID)
          typemod2=pbTypeModifier(PBTypes::POISON,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::POISON
        end
        if (id == PBMoves::GUNKSHOT || id == PBMoves::SLUDGEWAVE)
          typemod2=pbTypeModifier(PBTypes::ROCK,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::ROCK
        end
      when 43 # Sky Field
        if (id == PBMoves::DIVE || id == PBMoves::TWISTER)
          typemod2=pbTypeModifier(PBTypes::FLYING,attacker,opponent)
          typemod3= ((typemod*typemod2) * 0.25).ceil
          typemod=typemod3
          typeChange=PBTypes::FLYING
        end
      when 45 # Infernal Field  
        if (id == PBMoves::AURASPHERE || id == PBMoves::FRUSTRATION ||  
         id == PBMoves::SPIRITBREAK)  
          typemod2=pbTypeModifier(PBTypes::DARK,attacker,opponent)  
          typemod3= ((typemod*typemod2) * 0.25).ceil  
          typemod=typemod3  
          typeChange=PBTypes::DARK  
        end  
        if isConst?(pbType(type,attacker,opponent),PBTypes,:GROUND) ||  
           isConst?(pbType(type,attacker,opponent),PBTypes,:STEEL) ||  
           isConst?(pbType(type,attacker,opponent),PBTypes,:ROCK)  
          typemod2=pbTypeModifier(PBTypes::FIRE,attacker,opponent)  
          typemod3= ((typemod*typemod2) * 0.25).ceil  
          typemod=typemod3  
          typeChange=PBTypes::FIRE  
        end
      end
      if absorbtion
        return typeChange
      else
        return typemod
      end
    end    
  
################################################################################
# This move's accuracy check
################################################################################
  def pbAccuracyCheck(attacker,opponent)
    type=pbType(@type,attacker,opponent)
    
    baseaccuracy=@accuracy
    return true if baseaccuracy==0
    return true if attacker.hasWorkingAbility(:NOGUARD) ||
                   opponent.hasWorkingAbility(:NOGUARD)
    return true if opponent.effects[PBEffects::Telekinesis]>0
    return true if @function==0x0D && @battle.pbWeather==PBWeather::HAIL # Blizzard
    return true if (@function==0x08 || @function==0x15) && # Thunder, Hurricane
                   @battle.pbWeather==PBWeather::RAINDANCE
    return true if @function==0x08 && # Thunder
                   ($fefieldeffect == 16 || $fefieldeffect == 27 || $fefieldeffect == 28)
    return true if attacker.pbHasType?(:POISON) && id == PBMoves::TOXIC
    return true if (@function==0x10 || @function==0x9B || id==PBMoves::BODYSLAM || id==PBMoves::FLYINGPRESS) &&
                    opponent.effects[PBEffects::Minimize] # Flying Press, Stomp, DRush
    
    return true if opponent.hasWorkingAbility(:LIGHTNINGROD) && isConst?(type,PBTypes,:ELECTRIC)
    return true if opponent.hasWorkingAbility(:STORMDRAIN) && isConst?(type,PBTypes,:WATER)
    return true if (id == PBMoves::WILLOWISP || id == PBMoves::DARKVOID || id == PBMoves::INFERNO) &&  
                    $fefieldeffect == 45
    if $fefieldeffect == 30
      if (id == PBMoves::AURORABEAM || id == PBMoves::SIGNALBEAM ||
         id == PBMoves::FLASHCANNON || id == PBMoves::LUSTERPURGE ||
         id == PBMoves::DAZZLINGGLEAM || id == PBMoves::TECHNOBLAST || 
         id == PBMoves::DOOMDUMMY || id == PBMoves::MIRRORSHOT ||
         id == PBMoves::PRISMATICLASER)
        return true 
      end
    end
    if $fefieldeffect == 38 # Dimensional Field
      if (id == PBMoves::DARKPULSE || id == PBMoves::DARKVOID ||
          id == PBMoves::NIGHTDAZE)
        return true
      end
    end
    if $fefieldeffect == 43 # Sky Field
      if (id == PBMoves::THUNDER || id == PBMoves::HURRICANE)
        return true
      end
    end
# One-hit KO accuracy handled elsewhere
    # Field Effects
    case $fefieldeffect
    when 2 # Grassy Field
      if id == PBMoves::GRASSWHISTLE
        baseaccuracy=80
      end
    when 3 # Misty Field
      if id == PBMoves::SWEETKISS
        baseaccuracy=100
      end
    when 4 # Dark Crystal Cavern
      if id == PBMoves::DARKVOID
      baseaccuracy=100
    end
    when 6 # Big Top
    if id == PBMoves::SING
      baseaccuracy=100
    end
    when 7 # Burning Field
      if id == PBMoves::WILLOWISP
        baseaccuracy=100
      end
    when 8 # Swamp Field
      if id == PBMoves::SLEEPPOWDER
        baseaccuracy=100
      end
    when 10 # Corrosive Field
      if (id == PBMoves::POISONPOWDER || id == PBMoves::SLEEPPOWDER ||
       id == PBMoves::STUNSPORE || id == PBMoves::TOXIC)
        baseaccuracy=100
      end
    when 11 # Corrosive Mist Field
      if id == PBMoves::TOXIC
        baseaccuracy=100
      end
    when 18 # Shortcircuit Field
      if id == PBMoves::ZAPCANNON
        baseaccuracy=80
      end
    when 24 # Glitch Field
      if id == PBMoves::BLIZZARD
        baseaccuracy=90
      end
    when 32 # Dragon's Den
      if id == PBMoves::DRAGONRUSH
        baseaccuracy=100
      end
    when 33 # Flower Garden
      if $fecounter > 1
        if id == PBMoves::SLEEPPOWDER || id == PBMoves::STUNSPORE ||
         id == PBMoves::POISONPOWDER
          baseaccuracy=100
        end
      end
    when 35 # New World
      if id == PBMoves::DARKVOID
        baseaccuracy=100
      end
    when 37 # Psychic Terrain
      if id == PBMoves::HYPNOSIS
        baseaccuracy=90
      end
    when 38 # Dimensional Field
      if id == PBMoves::DARKVOID
        baseaccuracy=100
      end
    when 39 # Frozen Dimensional Field
      if id == PBMoves::DARKVOID
        baseaccuracy=100
      end
    when 40 # Haunted
      if (id == PBMoves::WILLOWISP || id == PBMoves::HYPNOSIS)
        baseaccuracy=90
      end
    when 42 # Darchlight Field
      if (id == PBMoves::POISONPOWDER || id == PBMoves::SLEEPPOWDER ||
          id == PBMoves::GRASSWHISTLE || id == PBMoves::STUNSPORE)
        baseaccuracy=95
      end
    end
    # END
    if @function==0x08 || @function==0x15 # Thunder, Hurricane
      baseaccuracy=50 if @battle.pbWeather==PBWeather::SUNNYDAY
    end
    accstage=attacker.stages[PBStats::ACCURACY]
    accstage=0 if (opponent.hasWorkingAbility(:UNAWARE) || @battle.SilvallyCheck(opponent,PBTypes::FAIRY)) && !(opponent.moldbroken)
    accuracy=(accstage>=0) ? (accstage+3)*100.0/3 : 300.0/(3-accstage)
    evastage=opponent.stages[PBStats::EVASION]
    evastage-=2 if @battle.field.effects[PBEffects::Gravity]>0
    evastage=-6 if evastage<-6
    evastage=0 if opponent.effects[PBEffects::Foresight] ||
                  opponent.effects[PBEffects::MiracleEye] ||
                  @function==0xA9 || # Chip Away
                  (attacker.hasWorkingAbility(:UNAWARE) || @battle.SilvallyCheck(attacker,PBTypes::FAIRY)) && !(opponent.moldbroken)
    evasion=(evastage>=0) ? (evastage+3)*100.0/3 : 300.0/(3-evastage)
    if attacker.hasWorkingAbility(:COMPOUNDEYES)
      accuracy*=1.3
    end
    if !@battle.pbOwnedByPlayer?(attacker.index) && ($game_variables[200] == 2)    
      accuracy*=1.1
      if $Trainer.numbadges>=11 && @basedamage>0
        accuracy*=1.2
      end   
    end       
    if attacker.hasWorkingItem(:MICLEBERRY)
      if (attacker.hasWorkingAbility(:GLUTTONY) && attacker.hp<=(attacker.totalhp/2).floor) ||
         attacker.hp<=(attacker.totalhp/4).floor
        accuracy*=1.2
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
      end
    end
    if attacker.hasWorkingAbility(:VICTORYSTAR)
      accuracy*=1.1
    end
    partner=attacker.pbPartner
    if partner && partner.hasWorkingAbility(:VICTORYSTAR)
      accuracy*=1.1
    end
    if attacker.hasWorkingItem(:WIDELENS)
      accuracy*=1.1
    end
    if attacker.hasWorkingItem(:ZOOMLENS) && attacker.speed < opponent.speed
      accuracy*=1.2
    end
    if attacker.hasWorkingAbility(:HUSTLE) && @basedamage>0 &&
       pbIsPhysical?(pbType(@type,attacker,opponent))
      accuracy*=0.8
    end  
    if (opponent.hasWorkingAbility(:WONDERSKIN) && @basedamage==0 &&
     attacker.pbIsOpposing?(opponent.index) && !(opponent.moldbroken))
      if ($fefieldeffect == 9 || @battle.field.effects[PBEffects::Rainbow]>0)
        accuracy*=0
      else
        accuracy/=2
      end
    end
    if opponent.hasWorkingAbility(:MAGICIAN) && @basedamage==0 &&
     attacker.pbIsOpposing?(opponent.index) && !(opponent.moldbroken) &&
     $fefieldeffect == 37
      accuracy/=2
    end
    if isConst?(attacker.species,PBSpecies,:STANTLER) && attacker.hasWorkingItem(:STANTCREST)
      accuracy*=1.5
    end
    if isConst?(attacker.species,PBSpecies,:HYPNO) && attacker.hasWorkingItem(:HYPCREST)
      accuracy*=1.5
    end
    if opponent.hasWorkingAbility(:TANGLEDFEET) &&
       opponent.effects[PBEffects::Confusion]>0 && !(opponent.moldbroken)
      evasion*=1.2
    end
    if opponent.hasWorkingAbility(:SANDVEIL) &&(@battle.pbWeather==PBWeather::SANDSTORM || $fefieldeffect == 12 || $fefieldeffect == 20) && !(opponent.moldbroken) 
      evasion*=1.2
    end
    if opponent.hasWorkingAbility(:SNOWCLOAK) && (@battle.pbWeather==PBWeather::HAIL || $fefieldeffect == 13 || $fefieldeffect == 28 || $fefieldeffect == 39) && !(opponent.moldbroken)
      evasion*=1.2
    end
    if opponent.hasWorkingItem(:BRIGHTPOWDER)
      evasion*=1.1
    end
    if opponent.hasWorkingItem(:LAXINCENSE)
      evasion*=1.1
    end
    # UPDATE 11/17/2013
    # keen eye should now ignore evasion increases
    # since in the above nothing can lower evasion, this will work
    # this is not a solution if the above code can lower evasion - that would
    # be counter-intuitive to keen-eye.
    evasion = 100 if attacker.hasWorkingAbility(:KEENEYE)
    evasion = 100 if $fefieldeffect == 20 &&
    (attacker.hasWorkingAbility(:OWNTEMPO) ||
    attacker.hasWorkingAbility(:INNERFOCUS) ||
    attacker.hasWorkingAbility(:PUREPOWER) ||
    attacker.hasWorkingAbility(:STEADFAST)) &&
    !opponent.hasWorkingAbility(:UNNERVE)
    return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)
  end

################################################################################
# Damage calculation and modifiers
################################################################################
  def pbIsCritical?(attacker,opponent)
    if (opponent.hasWorkingAbility(:BATTLEARMOR) ||
        opponent.hasWorkingAbility(:SHELLARMOR)) &&
        !(opponent.moldbroken)  
            return false 
    end
#### KUROTSUNE - 029 - END      
    return false if opponent.pbOwnSide.effects[PBEffects::LuckyChant]>0
    if attacker.effects[PBEffects::LaserFocus]>0
      attacker.effects[PBEffects::LaserFocus]-=1
      return true
    end    
    return true if @function==0xA0 # Frost Breath
    return true if @function==0x202 && attacker.hp<=((attacker.totalhp)*0.5).floor
    return true if attacker.hasWorkingAbility(:MERCILESS) && (opponent.status == PBStatuses::POISON || 
    $fefieldeffect==10 || $fefieldeffect==11 || $fefieldeffect==19 || $fefieldeffect==26)
    if isConst?(attacker.species,PBSpecies,:ARIADOS) && attacker.hasWorkingItem(:ARIACREST)
      if opponent.stages[PBStats::SPEED] < 0 || opponent.status == PBStatuses::POISON
        return true
      end
    end
    return true if (opponent.hasWorkingAbility(:RATTLED) || opponent.hasWorkingAbility(:WIMPOUT)) &&   
    ($fefieldeffect==44)
    $buffs = 0
    if $fefieldeffect == 30
      $buffs = attacker.stages[PBStats::EVASION] if attacker.stages[PBStats::EVASION] > 0
      $buffs = $buffs.to_i + attacker.stages[PBStats::ACCURACY] if attacker.stages[PBStats::ACCURACY] > 0
      $buffs = $buffs.to_i - opponent.stages[PBStats::EVASION] if opponent.stages[PBStats::EVASION] < 0
      $buffs = $buffs.to_i - opponent.stages[PBStats::ACCURACY] if opponent.stages[PBStats::ACCURACY] < 0
      $buffs = $buffs.to_i
    end
    c=0
    ratios=[24,8,2,1]
    c+=attacker.effects[PBEffects::FocusEnergy]
    if hasHighCriticalRate?
      c+=1
    end  
    if (attacker.inHyperMode? rescue false) && isConst?(self.type,PBTypes,:SHADOW)
      c+=1
    end
    c+=1 if attacker.hasWorkingAbility(:SUPERLUCK)
    if attacker.hasWorkingItem(:STICK) &&
      (isConst?(attacker.species,PBSpecies,:FARFETCHD) || isConst?(attacker.species,PBSpecies,:SIRFETCHD))
      c+=2
    end
    if attacker.hasWorkingItem(:LUCKYPUNCH) &&
       isConst?(attacker.species,PBSpecies,:CHANSEY)
      c+=2
    end
    c+=1 if attacker.hasWorkingItem(:RAZORCLAW)
    c+=1 if attacker.hasWorkingItem(:SCOPELENS)
    c+=1 if attacker.speed > opponent.speed && $fefieldeffect == 24
    if $fefieldeffect == 30
      c += $buffs if $buffs > 0
    end
    if $fefieldeffect == 5  
      if (opponent.hasWorkingAbility(:GORRILLATACTICS) || opponent.hasWorkingAbility(:RECKLESS))  
        c+=1  
      end  
      if attacker.hasWorkingAbility(:MERCILESS)  
        frac = (1.0*opponent.hp) / (1.0*opponent.totalhp)  
        if frac < 0.8  
          c+=1  
        elsif frac < 0.6  
          c+=2  
        elsif frac < 0.4  
          c+=3  
        end  
      end  
    end
    if isConst?(attacker.species,PBSpecies,:FEAROW) && attacker.hasWorkingItem(:FEARCREST) && 
     opponent.hp<=((opponent.totalhp)*0.5).floor
      c+=3
    end
    c=3 if c>3
    return @battle.pbRandom(ratios[c])==0
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg
  end

  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    return damagemult
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    return damagemult
  end
  
  def pbCalcDamage(attacker,opponent,options=0)
    opponent.damagestate.critical=false
    opponent.damagestate.typemod=0
    opponent.damagestate.calcdamage=0
    opponent.damagestate.hplost=0
    return 0 if @basedamage==0
    if (options&NOCRITICAL)==0
      opponent.damagestate.critical=pbIsCritical?(attacker,opponent)
    end
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
    if (options&NOTYPE)==0
      type=pbType(@type,attacker,opponent)
    else
      type=-1 # Will be treated as physical
    end
    ##### Calcuate base power of move #####
    basedmg=@basedamage # From PBS file
    basedmg=pbBaseDamage(basedmg,attacker,opponent) # Some function codes alter base power
    damagemult=0x1000
    if attacker.species == PBSpecies::CINCCINO && attacker.hasWorkingItem(:CINCCREST) && !pbIsMultiHit
      basedmg=(basedmg*0.3).round
      puts(basedmg)
    end
    if (isConst?(attacker.ability,PBAbilities,:TECHNICIAN) && (basedmg<=60))
      damagemult=(damagemult*1.5).round
    elsif ($fefieldeffect == 17) && ((isConst?(attacker.ability,PBAbilities,:TECHNICIAN) || isConst?(attacker.species,PBSpecies,:DUSKNOIR) && isConst?(attacker.item,PBItems,:DUSKCREST)) && basedmg<=80) 
      damagemult=(damagemult*1.5).round
    elsif isConst?(attacker.species,PBSpecies,:DUSKNOIR) && isConst?(attacker.item,PBItems,:DUSKCREST) && basedmg<=60
      damagemult=(damagemult*1.5).round
    end
    if (isConst?(attacker.ability,PBAbilities,:SKILLLINK))
      if $fefieldeffect==44
        damagemult=(damagemult*1.2).round
      end
    end
    if (isConst?(attacker.ability,PBAbilities,:STRONGJAW) || @battle.SilvallyCheck(attacker,PBTypes::DARK))
      if (id == PBMoves::BITE || id == PBMoves::CRUNCH ||
       id == PBMoves::THUNDERFANG || id == PBMoves::FIREFANG ||
       id == PBMoves::ICEFANG || id == PBMoves::POISONFANG ||
       id == PBMoves::HYPERFANG || id == PBMoves::PSYCHICFANGS ||
       id == PBMoves::JAWLOCK || id == PBMoves::FISHIOUSREND)
        damagemult=(damagemult*1.5).round
      end
    end
    if isConst?(attacker.species,PBSpecies,:FERALIGATR) && attacker.hasWorkingItem(:FERACREST)
      if (id == PBMoves::BITE || id == PBMoves::CRUNCH ||
       id == PBMoves::THUNDERFANG || id == PBMoves::FIREFANG ||
       id == PBMoves::ICEFANG || id == PBMoves::POISONFANG ||
       id == PBMoves::HYPERFANG || id == PBMoves::PSYCHICFANGS ||
       id == PBMoves::JAWLOCK || id == PBMoves::FISHIOUSREND)
        damagemult=(damagemult*1.5).round
      end
    end
    if isConst?(attacker.species,PBSpecies,:BOLTUND) && attacker.hasWorkingItem(:BOLTCREST)
      if !opponent.hasMovedThisRound? || @battle.switchedOut[opponent.index]
        if (id == PBMoves::BITE || id == PBMoves::CRUNCH ||
       id == PBMoves::THUNDERFANG || id == PBMoves::FIREFANG ||
       id == PBMoves::ICEFANG || id == PBMoves::POISONFANG ||
       id == PBMoves::HYPERFANG || id == PBMoves::PSYCHICFANGS ||
       id == PBMoves::JAWLOCK || id == PBMoves::FISHIOUSREND)
          damagemult=(damagemult*1.5).round
        end
      end
    end
    if isConst?(attacker.species,PBSpecies,:CLAYDOL) && attacker.hasWorkingItem(:CLAYCREST) &&
     isBeamMove?
      damagemult=(damagemult*1.5).round
    end
    if isConst?(attacker.species,PBSpecies,:DRUDDIGON) && attacker.hasWorkingItem(:DRUDDICREST) && (isConst?(type,PBTypes,:FIRE) || isConst?(type,PBTypes,:DRAGON))
      damagemult=(damagemult*1.3).round
    end
    if isConst?(attacker.ability,PBAbilities,:TOUGHCLAWS) && isContactMove? # Makes direct contact
      damagemult=(damagemult*1.3).round
    end
    if attacker.hasWorkingAbility(:IRONFIST) && isPunchingMove?
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingAbility(:RECKLESS)
      if @function==0xFA ||  # Take Down, etc.
         @function==0xFB ||  # Double-Edge, etc.
         @function==0xFC ||  # Head Smash
         @function==0xFD ||  # Volt Tackle
         @function==0xFE ||  # Flare Blitz
         @function==0x10B || # Jump Kick, Hi Jump Kick
         @function==0x130    # Shadow End
        damagemult=(damagemult*1.2).round
      end
    end
    if attacker.hasWorkingAbility(:FLAREBOOST) && $fefieldeffect!=39 &&
     (attacker.status==PBStatuses::BURN ||
      $fefieldeffect == 7 || $fefieldeffect == 45) && pbIsSpecial?(type)
      damagemult=(damagemult*1.5).round
    end
    if attacker.hasWorkingAbility(:TOXICBOOST) &&(attacker.status==PBStatuses::POISON || 
     $fefieldeffect == 10 || $fefieldeffect == 11 ||
     $fefieldeffect == 19 || $fefieldeffect == 26) && pbIsPhysical?(type)
      if $fefieldeffect == 41
        damagemult=(damagemult*2.0).round
      else
        damagemult=(damagemult*1.5).round
      end
    end
    #if attacker.hasWorkingAbility(:ANALYTIC) &&
    #   move isn't Future Sight/Doom Desire && target has already moved this turn
    #  damagemult=(damagemult*1.3).round
    #end
    if attacker.hasWorkingAbility(:RIVALRY) &&
       attacker.gender!=2 && opponent.gender!=2
      if attacker.gender==opponent.gender
        damagemult=(damagemult*1.25).round
      else
        damagemult=(damagemult*0.75).round
      end
    end
    if attacker.hasWorkingAbility(:SANDFORCE) &&
     (@battle.pbWeather==PBWeather::SANDSTORM ||
     $fefieldeffect == 12|| $fefieldeffect == 20) &&
     (isConst?(type,PBTypes,:ROCK) ||
     isConst?(type,PBTypes,:GROUND) ||
     isConst?(type,PBTypes,:STEEL))
      damagemult=(damagemult*1.3).round
    end
    if attacker.hasWorkingAbility(:SOLARIDOL) &&
     (isConst?(type,PBTypes,:FIRE))
      damagemult=(damagemult*1.5).round
    end
    if attacker.hasWorkingAbility(:LUNARIDOL) &&
     (isConst?(type,PBTypes,:ICE))
      damagemult=(damagemult*1.5).round
    end
    if (opponent.hasWorkingAbility(:HEATPROOF) || @battle.SilvallyCheck(opponent,PBTypes::STEEL)) && !(opponent.moldbroken) && isConst?(type,PBTypes,:FIRE)
      damagemult=(damagemult*0.5).round
    end
#### KUROTSUNE - 003 START
    if attacker.hasWorkingAbility(:ANALYTIC) && opponent.hasMovedThisRound?
      damagemult = (damagemult*1.3).round
    end
#### KUROTSUNE - 003 END
    if opponent.hasWorkingAbility(:DRYSKIN) && !(opponent.moldbroken) && isConst?(type,PBTypes,:FIRE)
      damagemult=(damagemult*1.25).round
    end
    if (attacker.hasWorkingAbility(:SHEERFORCE) || @battle.SilvallyCheck(attacker,PBTypes::GROUND)) && @addlEffect>0
      damagemult=(damagemult*1.3).round
    end
    if (attacker.hasWorkingItem(:SILKSCARF) && isConst?(type,PBTypes,:NORMAL)) ||
       (attacker.hasWorkingItem(:BLACKBELT) && isConst?(type,PBTypes,:FIGHTING)) ||
       (attacker.hasWorkingItem(:SHARPBEAK) && isConst?(type,PBTypes,:FLYING)) ||
       (attacker.hasWorkingItem(:POISONBARB) && isConst?(type,PBTypes,:POISON)) ||
       (attacker.hasWorkingItem(:SOFTSAND) && isConst?(type,PBTypes,:GROUND)) ||
       (attacker.hasWorkingItem(:HARDSTONE) && isConst?(type,PBTypes,:ROCK)) ||
       (attacker.hasWorkingItem(:SILVERPOWDER) && isConst?(type,PBTypes,:BUG)) ||
       (attacker.hasWorkingItem(:SPELLTAG) && isConst?(type,PBTypes,:GHOST)) ||
       (attacker.hasWorkingItem(:METALCOAT) && isConst?(type,PBTypes,:STEEL)) ||
       (attacker.hasWorkingItem(:CHARCOAL) && isConst?(type,PBTypes,:FIRE)) ||
       (attacker.hasWorkingItem(:MYSTICWATER) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingItem(:MIRACLESEED) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingItem(:MAGNET) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (attacker.hasWorkingItem(:TWISTEDSPOON) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (attacker.hasWorkingItem(:NEVERMELTICE) && isConst?(type,PBTypes,:ICE)) ||
       (attacker.hasWorkingItem(:DRAGONFANG) && isConst?(type,PBTypes,:DRAGON)) ||
       (attacker.hasWorkingItem(:BLACKGLASSES) && isConst?(type,PBTypes,:DARK))
      damagemult=(damagemult*1.2).round
    end
    if (attacker.hasWorkingItem(:FISTPLATE) && isConst?(type,PBTypes,:FIGHTING)) ||
       (attacker.hasWorkingItem(:SKYPLATE) && isConst?(type,PBTypes,:FLYING)) ||
       (attacker.hasWorkingItem(:TOXICPLATE) && isConst?(type,PBTypes,:POISON)) ||
       (attacker.hasWorkingItem(:EARTHPLATE) && isConst?(type,PBTypes,:GROUND)) ||
       (attacker.hasWorkingItem(:STONEPLATE) && isConst?(type,PBTypes,:ROCK)) ||
       (attacker.hasWorkingItem(:INSECTPLATE) && isConst?(type,PBTypes,:BUG)) ||
       (attacker.hasWorkingItem(:SPOOKYPLATE) && isConst?(type,PBTypes,:GHOST)) ||
       (attacker.hasWorkingItem(:IRONPLATE) && isConst?(type,PBTypes,:STEEL)) ||
       (attacker.hasWorkingItem(:FLAMEPLATE) && isConst?(type,PBTypes,:FIRE)) ||
       (attacker.hasWorkingItem(:SPLASHPLATE) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingItem(:MEADOWPLATE) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingItem(:ZAPPLATE) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (attacker.hasWorkingItem(:MINDPLATE) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (attacker.hasWorkingItem(:ICICLEPLATE) && isConst?(type,PBTypes,:ICE)) ||
       (attacker.hasWorkingItem(:DRACOPLATE) && isConst?(type,PBTypes,:DRAGON)) ||
       (attacker.hasWorkingItem(:DREADPLATE) && isConst?(type,PBTypes,:DARK)) ||
       (attacker.hasWorkingItem(:PIXIEPLATE) && isConst?(type,PBTypes,:FAIRY))
          damagemult=(damagemult*1.2).round
    end
# Gems
    if (attacker.hasWorkingItem(:NORMALGEM) && isConst?(type,PBTypes,:NORMAL)) ||
       (attacker.hasWorkingItem(:FIGHTINGGEM) && isConst?(type,PBTypes,:FIGHTING)) ||
       (attacker.hasWorkingItem(:FLYINGGEM) && isConst?(type,PBTypes,:FLYING)) ||
       (attacker.hasWorkingItem(:POISONGEM) && isConst?(type,PBTypes,:POISON)) ||
       (attacker.hasWorkingItem(:GROUNDGEM) && isConst?(type,PBTypes,:GROUND)) ||
       (attacker.hasWorkingItem(:ROCKGEM) && isConst?(type,PBTypes,:ROCK)) ||
       (attacker.hasWorkingItem(:BUGGEM) && isConst?(type,PBTypes,:BUG)) ||
       (attacker.hasWorkingItem(:GHOSTGEM) && isConst?(type,PBTypes,:GHOST)) ||
       (attacker.hasWorkingItem(:STEELGEM) && isConst?(type,PBTypes,:STEEL)) ||
       (attacker.hasWorkingItem(:FIREGEM) && isConst?(type,PBTypes,:FIRE)) ||
       (attacker.hasWorkingItem(:WATERGEM) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingItem(:GRASSGEM) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingItem(:ELECTRICGEM) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (attacker.hasWorkingItem(:PSYCHICGEM) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (attacker.hasWorkingItem(:ICEGEM) && isConst?(type,PBTypes,:ICE)) ||
       (attacker.hasWorkingItem(:DRAGONGEM) && isConst?(type,PBTypes,:DRAGON)) ||
       (attacker.hasWorkingItem(:DARKGEM) && isConst?(type,PBTypes,:DARK)) ||
       (attacker.hasWorkingItem(:FAIRYGEM) && isConst?(type,PBTypes,:FAIRY))
      damagemult=(damagemult*1.3).round
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
  #### JERICHO - 013 - START
      @battle.pbDisplayPaused(_INTL("The {1} strengthened {2}'s power!",PBItems.getName(attacker.pokemon.itemRecycle),self.name))      
      $takegem=1
    else
      $takegem=0  
  #### JERICHO - 013 - END  
    end
    if attacker.hasWorkingItem(:ROCKINCENSE) && isConst?(type,PBTypes,:ROCK)
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingItem(:ROSEINCENSE) && isConst?(type,PBTypes,:GRASS)
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingItem(:SEAINCENSE) && isConst?(type,PBTypes,:WATER)
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingItem(:WAVEINCENSE) && isConst?(type,PBTypes,:WATER)
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingItem(:ODDINCENSE) && isConst?(type,PBTypes,:PSYCHIC)
      damagemult=(damagemult*1.2).round
    end
    if isConst?(attacker.species,PBSpecies,:PALKIA) &&
       attacker.hasWorkingItem(:LUSTROUSORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:WATER))
      damagemult=(damagemult*1.2).round
    end
    if isConst?(attacker.species,PBSpecies,:DIALGA) &&
       attacker.hasWorkingItem(:ADAMANTORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:STEEL))
      damagemult=(damagemult*1.2).round
    end
    if isConst?(attacker.species,PBSpecies,:GIRATINA) &&
       attacker.hasWorkingItem(:GRISEOUSORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:GHOST))
      damagemult=(damagemult*1.2).round
    end
    if (isConst?(attacker.species,PBSpecies,:LATIAS) || isConst?(attacker.species,PBSpecies,:LATIOS)) &&
       attacker.hasWorkingItem(:SOULDEW) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:PSYCHIC))
      damagemult=(damagemult*1.2).round
    end    
    damagemult=pbBaseDamageMultiplier(damagemult,attacker,opponent)
    #if move was called using Me First
    #  damagemult=(damagemult*1.5).round
    #end
    if attacker.effects[PBEffects::Charge]>0 && isConst?(type,PBTypes,:ELECTRIC)
      damagemult=(damagemult*2.0).round
    end
    if attacker.effects[PBEffects::HelpingHand] && (options&SELFCONFUSE)==0
      damagemult=(damagemult*1.5).round
    end
    if isConst?(type,PBTypes,:FIRE)
      if @battle.field.effects[PBEffects::WaterSport]>0
        damagemult=(damagemult*0.33).round
      end
    end
    if isConst?(type,PBTypes,:ELECTRIC)
      if @battle.field.effects[PBEffects::MudSport]>0
        damagemult=(damagemult*0.33).round
      end
    end
    if isConst?(type,PBTypes,:NORMAL) &&
     isConst?(attacker.ability,PBAbilities,:AERILATE)
      type=PBTypes::FLYING
      if $fefieldeffect==16 || $fefieldeffect==27 || $fefieldeffect==28 || $fefieldeffect == 43 # Mountain and Sky Fields
        damagemult=(damagemult*1.5).round
      else
        damagemult=(damagemult*1.2).round
      end
    end
    if isConst?(type,PBTypes,:NORMAL) && isConst?(attacker.ability,PBAbilities,:GALVANIZE)
      type=PBTypes::ELECTRIC
      if $fefieldeffect == 1 || $fefieldeffect == 17 || @battle.field.effects[PBEffects::ElectricTerrain]>0 # Electric or Factory Fields
        damagemult=(damagemult*1.5).round
      elsif $fefieldeffect == 18 # Short-Circuit Field
        damagemult=(damagemult*2).round
      else
        damagemult=(damagemult*1.2).round
      end
    end    
    if isSoundBased? &&
     isConst?(attacker.ability,PBAbilities,:LIQUIDVOICE)
      if $fefieldeffect==13
        type=PBTypes::ICE
      else       
       type=PBTypes::WATER
      end    
    end
    if $fefieldeffect == 31 # Fairy Tale
      if id == PBMoves::CUT || id == PBMoves::SACREDSWORD ||
       id == PBMoves::SLASH || id == PBMoves::SECRETSWORD
        type=PBTypes::STEEL
      end
    end
    if $fefieldeffect == 32 # Dragon's Den
      if id == PBMoves::ROCKCLIMB || id == PBMoves::STRENGTH 
        type=PBTypes::FIRE
      end
    end
    if isConst?(type,PBTypes,:DARK)
      for i in @battle.battlers
        if isConst?(i.ability,PBAbilities,:DARKAURA)
         breakaura=0
         for j in @battle.battlers
           if isConst?(j.ability,PBAbilities,:AURABREAK)
             breakaura+=1
           end
         end
          if breakaura!=0
            damagemult=(damagemult*2/3).round
          else
            damagemult=(damagemult*1.3).round
          end
        end
      end
    end 
    if attacker.hasWorkingItem(:MUSCLEBAND) && pbIsPhysical?(type)
      damagemult=(damagemult*1.1).round
    end
    if attacker.hasWorkingItem(:WISEGLASSES) && pbIsSpecial?(type)
      damagemult=(damagemult*1.1).round
    end
    if isConst?(type,PBTypes,:FAIRY)
      for i in @battle.battlers
        if isConst?(i.ability,PBAbilities,:FAIRYAURA)
         breakaura=0
         for j in @battle.battlers
           if isConst?(j.ability,PBAbilities,:AURABREAK)
             breakaura+=1
           end
         end
          if breakaura!=0
            damagemult=(damagemult*2/3).round
          else
            damagemult=(damagemult*1.3).round
          end
        end
      end
    end 
    #### KUROTSUNE - 013 - START
    if isConst?(type,PBTypes,:NORMAL) &&  
     @battle.field.effects[PBEffects::IonDeluge] == true
      type = PBTypes::ELECTRIC
    end
    #### KUROTSUNE - 013 - END
    if isConst?(type,PBTypes,:NORMAL) &&
     isConst?(attacker.ability,PBAbilities,:PIXILATE)
      type=PBTypes::FAIRY unless $fefieldeffect == 24
      if $fefieldeffect == 3 || @battle.field.effects[PBEffects::MistyTerrain]>0# Misty Field
        damagemult=(damagemult*1.5).round
      else
        damagemult=(damagemult*1.2).round
      end
    end
    if isConst?(type,PBTypes,:NORMAL) &&
     isConst?(attacker.ability,PBAbilities,:REFRIGERATE)
      type=PBTypes::ICE
      if $fefieldeffect == 13 || $fefieldeffect == 28 || $fefieldeffect == 39 # Icy Fields
        damagemult=(damagemult*1.5).round
      else
        damagemult=(damagemult*1.2).round
      end
    end
    if isConst?(attacker.ability,PBAbilities,:NORMALIZE)
        damagemult=(damagemult*1.2).round
    end    
    #Knockoff
    if id == PBMoves::KNOCKOFF && opponent.item !=0 && !@battle.pbIsUnlosableItem(opponent,opponent.item)
       damagemult=(damagemult*1.5).round
    end
    # End Knockoff
    if isConst?(attacker.ability,PBAbilities,:MEGALAUNCHER)
      if id == PBMoves::AURASPHERE || id == PBMoves::DRAGONPULSE ||
       id == PBMoves::DARKPULSE || id == PBMoves::WATERPULSE
        damagemult=(damagemult*1.5).round
      end
    end  
    if @battle.field.effects[PBEffects::ElectricTerrain]>0 && $fefieldeffect!=1 # Electric Terrain
      if (id == PBMoves::EXPLOSION || id == PBMoves::SELFDESTRUCT) 
        damagemult=(damagemult*1.3).round
        @battle.pbDisplay(_INTL("The explosion became hyper-charged!",opponent.pbThis))
      end
      if (id == PBMoves::HURRICANE || id == PBMoves::SMACKDOWN || id == PBMoves::THOUSANDARROWS ||
          id == PBMoves::SURF || id == PBMoves::MUDDYWATER || id == PBMoves::PLASMAFISTS) # || (id == PBMoves::SMACKDOWN && $fefieldeffect!=32)
        damagemult=(damagemult*1.3).round
        @battle.pbDisplay(_INTL("The attack became hyper-charged!",opponent.pbThis))
      end
      if (id == PBMoves::MAGNETBOMB)
        damagemult=(damagemult*2).round
        @battle.pbDisplay(_INTL("The attack powered up!",opponent.pbThis))
      end        
    end  
    if (id == PBMoves::OMINOUSWIND || id == PBMoves::ICYWIND || 
      id == PBMoves::SILVERWIND || id == PBMoves::TWISTER || 
      id == PBMoves::RAZORWIND || id == PBMoves::FAIRYWIND || 
      id == PBMoves::GUST) && (@battle.field.effects[PBEffects::GrassyTerrain]>0 && $fefieldeffect!=2)
      damagemult=(damagemult*1.5).round
      @battle.pbDisplay(_INTL("The wind picked up strength from the field!",opponent.pbThis)) if $feshutup == 0
      $feshutup+=1
    end    
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && $fefieldeffect!=3
      if (id == PBMoves::MYSTICALFIRE ||
          id == PBMoves::MAGICALLEAF ||
          id == PBMoves::DOOMDUMMY || id == PBMoves::ICYWIND ||
          id == PBMoves::HIDDENPOWER ||
          id == PBMoves::MISTBALL || id == PBMoves::AURASPHERE ||
          id == PBMoves::STEAMERUPTION ||
          id == PBMoves::SILVERWIND || id == PBMoves::MOONGEISTBEAM)
        damagemult=(damagemult*1.3).round
        @battle.pbDisplay(_INTL("The mist's energy strengthened the attack!",opponent.pbThis)) if $feshutup == 0
        $feshutup+=1
      end      
    end
    if @battle.field.effects[PBEffects::PsychicTerrain]>0 && $fefieldeffect!=37
      if (id == PBMoves::HEX || id == PBMoves::MAGICALLEAF ||
          id == PBMoves::MYSTICALFIRE || id == PBMoves::MOONBLAST ||
          id == PBMoves::AURASPHERE || id == PBMoves::MINDBLOWN)
        damagemult=(damagemult*1.3).round
        @battle.pbDisplay(_INTL("The psychic energy strengthened the attack!",opponent.pbThis)) if $feshutup == 0
        $feshutup+=1
      end         
    end
    if @battle.field.effects[PBEffects::Rainbow]>0 && $fefieldeffect!=9
      if (id == PBMoves::SILVERWIND || id == PBMoves::MYSTICALFIRE ||
          id == PBMoves::DRAGONPULSE || id == PBMoves::TRIATTACK ||
          id == PBMoves::SACREDFIRE || id == PBMoves::FIREPLEDGE ||
          id == PBMoves::WATERPLEDGE || id == PBMoves::GRASSPLEDGE ||
          id == PBMoves::AURORABEAM || id == PBMoves::JUDGMENT ||
          id == PBMoves::RELICSONG || id == PBMoves::HIDDENPOWER ||
          id == PBMoves::SECRETPOWER || id == PBMoves::WEATHERBALL ||
          id == PBMoves::LUSTERPURGE || id == PBMoves::HEARTSTAMP ||
          id == PBMoves::ZENHEADBUTT ||
          id == PBMoves::SPARKLINGARIA || id == PBMoves::FLEURCANNON ||
          id == PBMoves::PRISMATICLASER)
        damagemult=(damagemult*1.3).round
        @battle.pbDisplay(_INTL("The attack was rainbow-charged!",opponent.pbThis)) if $feshutup == 0
        $feshutup+=1
      end    
    end  
    #Specific Field Effects
    case $fefieldeffect
      when 1 # Electric Field
        if (id == PBMoves::EXPLOSION || id == PBMoves::SELFDESTRUCT) 
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The explosion became hyper-charged!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::HURRICANE || id == PBMoves::SURF ||
          id == PBMoves::SMACKDOWN || id == PBMoves::MUDDYWATER ||
          id == PBMoves::THOUSANDARROWS ||  id == PBMoves::HYDROVORTEX)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The attack became hyper-charged!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if id == PBMoves::MAGNETBOMB || id == PBMoves::PLASMAFISTS 
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The attack powered-up!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 2 # Grassy Field
        if (id == PBMoves::FAIRYWIND || id == PBMoves::SILVERWIND)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The wind picked up strength from the field!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::MUDDYWATER || id == PBMoves::SURF || id == PBMoves::EARTHQUAKE || 
          id == PBMoves::MAGNITUDE || id == PBMoves::BULLDOZE)
          damagemult=(damagemult*0.5).round
          @battle.pbDisplay(_INTL("The grass softened the attack...",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 3 # Misty Field
        if (id == PBMoves::MYSTICALFIRE || id == PBMoves::MAGICALLEAF ||
         id == PBMoves::DOOMDUMMY || id == PBMoves::ICYWIND ||
         id == PBMoves::MISTBALL || id == PBMoves::AURASPHERE ||
         id == PBMoves::STEAMERUPTION || id == PBMoves::SILVERWIND || 
         id == PBMoves::STRANGESTEAM)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The mist's energy strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::DARKPULSE || id == PBMoves::SHADOWBALL ||
         id == PBMoves::NIGHTDAZE)
          damagemult=(damagemult*0.5).round
          @battle.pbDisplay(_INTL("The mist softened the attack...",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 4 # Dark Crystal Cavern
        if (id == PBMoves::DARKPULSE ||
         id == PBMoves::NIGHTDAZE || id == PBMoves::NIGHTSLASH ||
         id == PBMoves::SHADOWBALL || id == PBMoves::SHADOWPUNCH ||
         id == PBMoves::SHADOWCLAW || id == PBMoves::SHADOWSNEAK ||
         id == PBMoves::SHADOWFORCE || id == PBMoves::SHADOWBONE ||
         id == PBMoves::BLACKHOLEECLIPSE)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The darkness strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::AURORABEAM || id == PBMoves::SIGNALBEAM ||
         id == PBMoves::FLASHCANNON || id == PBMoves::LUSTERPURGE ||
         id == PBMoves::DAZZLINGGLEAM || id == PBMoves::MIRRORSHOT ||
         id == PBMoves::TECHNOBLAST || id == PBMoves::DOOMDUMMY ||
         id == PBMoves::POWERGEM || id == PBMoves::MOONGEISTBEAM || 
         id == PBMoves::MENACINGMOONRAZEMAELSTROM)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The crystals' light strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::PRISMATICLASER)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The crystal split the attack!")) if $feshutup == 0
          $feshutup+=1
        end      
      when 5 # Chess Board
        if (id == PBMoves::STRENGTH || id == PBMoves::ANCIENTPOWER || id == PBMoves::CONTINENTALCRUSH ||
         id == PBMoves::PSYCHIC || id == PBMoves::ROCKTHROW)
          damagemult=(damagemult*1.5).round
          if isConst?(opponent.ability,PBAbilities,:ADAPTABILITY) ||
           isConst?(opponent.ability,PBAbilities,:ANTICIPATION) ||
           isConst?(opponent.ability,PBAbilities,:SYNCHRONIZE) ||
           isConst?(opponent.ability,PBAbilities,:TELEPATHY)
            damagemult=(damagemult*0.5).round
          end
          if isConst?(opponent.ability,PBAbilities,:OBLIVIOUS) ||
           isConst?(opponent.ability,PBAbilities,:KLUTZ) ||
           isConst?(opponent.ability,PBAbilities,:DEFEATIST) ||
           isConst?(opponent.ability,PBAbilities,:UNAWARE) ||
           @battle.SilvallyCheck(opponent, PBTypes::FAIRY) ||
           isConst?(opponent.ability,PBAbilities,:SIMPLE) ||
           opponent.effects[PBEffects::Confusion]>0
            damagemult=(damagemult*2).round
          end
          if attacker.effects[PBEffects::KinesisBoost]  
            damagemult=(damagemult*2).round  
          end  
          @battle.pbDisplay(_INTL("The chess piece slammed forward!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
        if (id == PBMoves::BARRAGE)  
          damagemult=(damagemult*2.0).round  
          if isConst?(opponent.ability,PBAbilities,:ADAPTABILITY) ||  
           isConst?(opponent.ability,PBAbilities,:ANTICIPATION) ||  
           isConst?(opponent.ability,PBAbilities,:SYNCHRONIZE) ||  
           isConst?(opponent.ability,PBAbilities,:TELEPATHY)  
            damagemult=(damagemult*0.5).round  
          end  
          if isConst?(opponent.ability,PBAbilities,:OBLIVIOUS) ||  
           isConst?(opponent.ability,PBAbilities,:KLUTZ) ||  
           isConst?(opponent.ability,PBAbilities,:UNAWARE) ||  
           isConst?(opponent.ability,PBAbilities,:DEFEATIST) ||
           @battle.SilvallyCheck(opponent, PBTypes::FAIRY) ||  
           isConst?(opponent.ability,PBAbilities,:SIMPLE) ||  
           opponent.effects[PBEffects::Confusion]>0  
            damagemult=(damagemult*2).round  
          end  
          if attacker.effects[PBEffects::KinesisBoost]  
            damagemult=(damagemult*2).round  
          end
          @battle.pbDisplay(_INTL("The chess piece slammed forward!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::FEINT || id == PBMoves::FEINTATTACK ||
         id == PBMoves::FAKEOUT || id == PBMoves::SUCKERPUNCH)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("En passant!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 6 # Big Top
        if ((isConst?(type,PBTypes,:FIGHTING) && pbIsPhysical?(type)) ||
         id == PBMoves::STRENGTH || id == PBMoves::WOODHAMMER ||
         id == PBMoves::DUALCHOP || id == PBMoves::HEATCRASH ||
         id == PBMoves::SKYDROP || id == PBMoves::BULLDOZE ||
         id == PBMoves::ICICLECRASH || id == PBMoves::BODYSLAM ||
         id == PBMoves::STOMP || id == PBMoves::GIGAIMPACT ||
         id == PBMoves::POUND || id == PBMoves::SMACKDOWN ||
         id == PBMoves::IRONTAIL ||  id == PBMoves::METEORMASH ||
         id == PBMoves::CRABHAMMER || id == PBMoves::DRAGONRUSH ||
         id == PBMoves::BOUNCE || id == PBMoves::SLAM ||
         id == PBMoves::HEAVYSLAM || id == PBMoves::EARTHQUAKE ||
         id == PBMoves::MAGNITUDE || id == PBMoves::HIGHHORSEPOWER ||
         id == PBMoves::ICEHAMMER || id == PBMoves::DRAGONHAMMER ||
         id == PBMoves::BRUTALSWING || id == PBMoves::STOMPINGTANTRUM ||
         id == PBMoves::CONTINENTALCRUSH || id == PBMoves::GRAVAPPLE || id == PBMoves::DOUBLEIRONBASH)
          striker = 1+rand(14)
          @battle.pbDisplay(_INTL("WHAMMO!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
          if (attacker.hasWorkingAbility(:HUGEPOWER) || attacker.hasWorkingAbility(:GUTS) || attacker.hasWorkingAbility(:PUREPOWER) ||
             attacker.hasWorkingAbility(:SHEERFORCE) || attacker.hasWorkingAbility(:IRONFIST))
           @battle.SilvallyCheck(attacker,PBTypes::GROUND)
            if striker >=9
              striker = 15
            else
              striker = 14
            end
          end
          strikermod = attacker.stages[PBStats::ATTACK]
          striker = striker + strikermod
          if striker >= 15
            @battle.pbDisplay(_INTL("...OVER 9000!!!",opponent.pbThis))
            damagemult=(damagemult*3).round
          elsif striker >=13
            @battle.pbDisplay(_INTL("...POWERFUL!",opponent.pbThis))
            damagemult=(damagemult*2).round
          elsif striker >=9
            @battle.pbDisplay(_INTL("...NICE!",opponent.pbThis))
            damagemult=(damagemult*1.5).round
          elsif striker >=3
            @battle.pbDisplay(_INTL("...OK!",opponent.pbThis))
          else
            @battle.pbDisplay(_INTL("...WEAK!",opponent.pbThis))
            damagemult=(damagemult*0.5).round
          end
        end
        if (id == PBMoves::PAYDAY)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("And a little extra for you, darling!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::VINEWHIP || id == PBMoves::POWERWHIP ||
          id == PBMoves::FIRELASH)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Back, foul beast!",opponent.pbThis))
        end
        if (id == PBMoves::FIERYDANCE || id == PBMoves::PETALDANCE ||
          id == PBMoves::REVELATIONDANCE || id == PBMoves::DRUMBEATING)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("What grace!",opponent.pbThis))
        end
        if (id == PBMoves::FLY || id == PBMoves::ACROBATICS)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("An extravagant aerial finish!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::FIRSTIMPRESSION)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("And what an entrance it is!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if isSoundBased?   # Sound-based moves
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Loud and clear!",opponent.pbThis))
        end
      when 7 # Burning Field
        if (id == PBMoves::SMOG || id == PBMoves::CLEARSMOG)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The flames spread from the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::SMACKDOWN || id == PBMoves::THOUSANDARROWS || id == PBMoves::ROCKSLIDE)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("{1} was knocked into the flames!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 8 # Swamp Field
        if (id == PBMoves::MUDBOMB || id == PBMoves::MUDSHOT ||
         id == PBMoves::MUDSLAP || id == PBMoves::MUDDYWATER ||
         id == PBMoves::SURF || id == PBMoves::SLUDGEWAVE ||
         id == PBMoves::GUNKSHOT || id == PBMoves::BRINE ||
         id == PBMoves::HYDROVORTEX || id == PBMoves::SMACKDOWN || id == PBMoves::THOUSANDARROWS)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The murk strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 9 # Rainbow Field
        if (id == PBMoves::SILVERWIND || id == PBMoves::MYSTICALFIRE ||
         id == PBMoves::DRAGONPULSE || id == PBMoves::TRIATTACK ||
         id == PBMoves::SACREDFIRE || id == PBMoves::FIREPLEDGE ||
         id == PBMoves::WATERPLEDGE || id == PBMoves::GRASSPLEDGE ||
         id == PBMoves::AURORABEAM || id == PBMoves::JUDGMENT ||
         id == PBMoves::RELICSONG || id == PBMoves::HIDDENPOWER ||
         id == PBMoves::SECRETPOWER || id == PBMoves::WEATHERBALL ||
         id == PBMoves::MISTBALL || id == PBMoves::HEARTSTAMP ||
         id == PBMoves::MOONBLAST || id == PBMoves::ZENHEADBUTT ||
         id == PBMoves::SPARKLINGARIA || id == PBMoves::FLEURCANNON ||
         id == PBMoves::PRISMATICLASER || id == PBMoves::TWINKLETACKLE)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The attack was rainbow-charged!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::DARKPULSE || id == PBMoves::SHADOWBALL ||
         id == PBMoves::NIGHTDAZE || id == PBMoves::NEVERENDINGNIGHTMARE)
          damagemult=(damagemult*0.5).round
          @battle.pbDisplay(_INTL("The rainbow softened the attack...",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 10 # Corrosive Field
        if (id == PBMoves::SMACKDOWN || id == PBMoves::MUDSLAP ||
         id == PBMoves::MUDSHOT || id == PBMoves::MUDBOMB ||
         id == PBMoves::MUDDYWATER || id == PBMoves::WHIRLPOOL ||
         id == PBMoves::THOUSANDARROWS || id == PBMoves::APPLEACID)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The corrosion strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::ACID || id == PBMoves::ACIDSPRAY ||
         id == PBMoves::GRASSKNOT || id == PBMoves::SNAPTRAP)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The corrosion strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 11 # Corrosive Mist Field
        if (id == PBMoves::BUBBLEBEAM || id == PBMoves::ACIDSPRAY ||
         id == PBMoves::BUBBLE || id == PBMoves::SMOG ||
         id == PBMoves::CLEARSMOG || id == PBMoves::SPARKLINGARIA ||
         id == PBMoves::APPLEACID || id == PBMoves::OCEANICOPERETTA)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The poison strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 12 # Desert Field
        if (id == PBMoves::NEEDLEARM || id == PBMoves::PINMISSILE || id == PBMoves::SCALD || id == PBMoves::STEAMERUPTION ||
         id == PBMoves::DIG || id == PBMoves::SANDTOMB || id == PBMoves::SCORCHINGSANDS || 
         id == PBMoves::HEATWAVE || id == PBMoves::THOUSANDWAVES ||
         id == PBMoves::BURNUP)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The desert strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 13 # Icy Field
        if (@priority >= 1 && @basedamage > 0 && (@flags&0x01)!=0 && 
          !attacker.hasWorkingAbility(:LONGREACH)) ||
         (id == PBMoves::FEINT || id == PBMoves::ROLLOUT ||
          id == PBMoves::DEFENSECURL || id == PBMoves::STEAMROLLER ||
          id == PBMoves::LUNGE)
          isgrounded=pbTypeModifier(PBTypes::GROUND,opponent,attacker)
          if isgrounded != 0
            if attacker.pbCanIncreaseStatStage?(PBStats::SPEED)
              attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
              @battle.pbCommonAnimation("StatUp",attacker,nil)
              @battle.pbDisplay(_INTL("{1} gained momentum on the ice!",attacker.pbThis)) if $feshutup == 0
              $feshutup+=1
            end
          end
        end
        if (id == PBMoves::SCALD || id == PBMoves::STEAMERUPTION)
          damagemult=(damagemult*0.5).round
          @battle.pbDisplay(_INTL("The cold softened the attack...",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 14 # Rocky Field
        if (id == PBMoves::ROCKSMASH)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("SMASH'D!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::ROCKCLIMB || id == PBMoves::STRENGTH ||
          id == PBMoves::MAGNITUDE || id == PBMoves::EARTHQUAKE ||
          id == PBMoves::BULLDOZE || id == PBMoves::ACCELEROCK)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The rocks strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 15 # Forest Field
        if (id == PBMoves::CUT)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("A tree slammed down!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::AIRSLASH || id == PBMoves::GALESTRIKE ||
           id == PBMoves::SLASH || id == PBMoves::FURYCUTTER ||
           id == PBMoves::AIRCUTTER || id == PBMoves::PSYCHOCUT ||
           id == PBMoves::BREAKINGSWIPE)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("A tree slammed down!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::ATTACKORDER)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("They're coming out of the woodwork!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::SURF || id == PBMoves::MUDDYWATER)
          damagemult=(damagemult*0.5).round
          @battle.pbDisplay(_INTL("The forest softened the attack...",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 16 # Volcanic TOp
        if (id == PBMoves::STEAMERUPTION)
          damagemult=(damagemult*1.667).round
          @battle.pbDisplay(_INTL("The field super-heated the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::ERUPTION || id == PBMoves::HEATWAVE ||
         id == PBMoves::MAGMASTORM || id == PBMoves::LAVAPLUME ||
         id == PBMoves::LAVASURF)
          damagemult=(damagemult*1.3).round
          @battle.pbDisplay(_INTL("The field powers up the flaming attacks!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::OMINOUSWIND || id == PBMoves::SILVERWIND ||
         id == PBMoves::RAZORWIND || id == PBMoves::ICYWIND ||
         id == PBMoves::GUST || id == PBMoves::TWISTER ||
         id == PBMoves::PRECIPICEBLADES || id == PBMoves::SMOG ||
         id == PBMoves::CLEARSMOG)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The field super-heated the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::THUNDER)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The field powers up the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 17 # Factory Field
        if (id == PBMoves::FLASHCANNON || id == PBMoves::GYROBALL ||
         id == PBMoves::MAGNETBOMB || id == PBMoves::GEARGRIND ||
         id == PBMoves::DOUBLEIRONBASH)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("ATTACK SEQUENCE INITIATE.",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::STEAMROLLER || id == PBMoves::TECHNOBLAST)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("ATTACK SEQUENCE UPDATE.",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 18 # Shortcircuit Field
        if isConst?(type,PBTypes,:ELECTRIC)
          striker = 1+rand(14)
          striker = 13 if @battle.field.effects[PBEffects::ElectricTerrain]>0 
          if striker >= 13
            @battle.pbDisplay(_INTL("BZZZAPP!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
            damagemult=(damagemult*2.0).round
          elsif striker >= 9
            @battle.pbDisplay(_INTL("Bzzapp!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
            damagemult=(damagemult*1.5).round
          elsif striker >= 6
            @battle.pbDisplay(_INTL("Bzap!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
            damagemult=(damagemult*1.2).round
          elsif striker >= 3
            @battle.pbDisplay(_INTL("Bzzt.",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
            damagemult=(damagemult*0.8).round
          else
            @battle.pbDisplay(_INTL("Bzt...",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
            damagemult=(damagemult*0.5).round
          end
        end
        if (id == PBMoves::DAZZLINGGLEAM) || (id == PBMoves::FLASHCANNON)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Blinding!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::STEELBEAM)
          damagemult=(damagemult*1.667).round
          @battle.pbDisplay(_INTL("WARNING! ELECTRICAL OVERLOAD!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::DARKPULSE || id == PBMoves::PHANTOMFORCE ||
         id == PBMoves::NIGHTDAZE || id == PBMoves::NIGHTSLASH ||
         id == PBMoves::SHADOWBALL || id == PBMoves::SHADOWPUNCH ||
         id == PBMoves::SHADOWCLAW || id == PBMoves::SHADOWSNEAK ||
         id == PBMoves::SHADOWFORCE || id == PBMoves::SHADOWBONE)
          damagemult=(damagemult*1.3).round
          @battle.pbDisplay(_INTL("The darkness strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::SURF || id == PBMoves::MUDDYWATER ||
         id == PBMoves::MAGNETBOMB || id == PBMoves::GYROBALL ||
         id == PBMoves::GEARGRIND)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The attack picked up electricity!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 19 # Wasteland
        if (id == PBMoves::OCTAZOOKA || id == PBMoves::SLUDGE ||
         id == PBMoves::GUNKSHOT || id == PBMoves::SLUDGEWAVE ||
         id == PBMoves::SLUDGEBOMB || id == PBMoves::ACIDDOWNPOUR)
          damagemult=(damagemult*1.2).round
          @battle.pbDisplay(_INTL("The waste joined the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::SPITUP)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("BLEAAARGGGGH!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::VINEWHIP || id == PBMoves::POWERWHIP)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The waste did it for the vine!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::MUDSLAP || id == PBMoves::MUDBOMB ||
         id == PBMoves::MUDSHOT)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The waste was added to the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::EARTHQUAKE || id == PBMoves::MAGNITUDE ||
         id == PBMoves::BULLDOZE)
          damagemult=(damagemult*0.25).round
          @battle.pbDisplay(_INTL("Wibble-wibble wobble-wobb...",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 20 # Ashen Beach
        if (id == PBMoves::MUDSLAP || id == PBMoves::MUDSHOT ||
          id == PBMoves::MUDBOMB  || id == PBMoves::SANDTOMB)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("Ash mixed into the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::HIDDENPOWER || id == PBMoves::STRENGTH)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("...And with pure focus!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::LANDSWRATH || id == PBMoves::THOUSANDWAVES)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The sand strengthened the atttack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::PSYCHIC)
          damagemult=(damagemult*1.2).round
          @battle.pbDisplay(_INTL("...And with focus...!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::STOREDPOWER || id == PBMoves::ZENHEADBUTT ||
         id == PBMoves::FOCUSBLAST || id == PBMoves::AURASPHERE)
          damagemult=(damagemult*1.3).round
          @battle.pbDisplay(_INTL("...And with full focus...!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::SURF|| id == PBMoves::MUDDYWATER)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Surf's up!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 21 # Water Surface
        if (id == PBMoves::SURF || id == PBMoves::MUDDYWATER || id == PBMoves::ORIGINPULSE ||
         id == PBMoves::WHIRLPOOL || id == PBMoves::DIVE || id == PBMoves::HYDROVORTEX)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The attack rode the current!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (@priority >= 1 && @basedamage > 0 && (attacker.ability == (PBAbilities::PROPELLERTAIL)))  
          damagemult=(damagemult*1.5).round  
          @battle.pbDisplay(_INTL("{1} propelled through the water!",attacker.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end
      when 22 # Underwater
        if (id == PBMoves::WATERPULSE)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Jet-streamed!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::ANCHORSHOT || id == PBMoves::DRAGONDARTS)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("From the depths!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end    
        if (@priority >= 1 && @basedamage > 0 && (attacker.ability == (PBAbilities::PROPELLERTAIL)))  
          damagemult=(damagemult*1.5).round  
          @battle.pbDisplay(_INTL("{1} propelled through the water!",attacker.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end    
      when 23 # Cave
        if isSoundBased? # Sound-based move
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("ECHO-Echo-echo!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::ROCKTOMB)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("...Piled on!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 25 # Crystal Cavern
        if (id == PBMoves::AURORABEAM || id == PBMoves::SIGNALBEAM ||
         id == PBMoves::FLASHCANNON || id == PBMoves::DAZZLINGGLEAM || 
         id == PBMoves::MIRRORSHOT || id == PBMoves::TECHNOBLAST || 
         id == PBMoves::DOOMDUMMY || id == PBMoves::MOONGEISTBEAM ||
         id == PBMoves::MENACINGMOONRAZEMAELSTROM || id == PBMoves::PHOTONGEYSER)
          damagemult=(damagemult*1.3).round
          @battle.pbDisplay(_INTL("The crystals' light strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::POWERGEM || id == PBMoves::DIAMONDSTORM || 
         id == PBMoves::ANCIENTPOWER || id == PBMoves::ROCKTOMB || 
         id == PBMoves::ROCKSMASH || 
         id == PBMoves::MULTIATTACK || id == PBMoves::LUSTERPURGE || 
         id == PBMoves::JUDGMENT || id == PBMoves::STRENGTH || 
         id == PBMoves::ROCKCLIMB || 
         id == PBMoves::LIGHTTHATBURNSTHESKY)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The crystals strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 26 # Murkwater Surface
        if (id == PBMoves::MUDBOMB || id == PBMoves::MUDSLAP || 
         id == PBMoves::MUDSHOT || id == PBMoves::SMACKDOWN || 
         id == PBMoves::ACID || id == PBMoves::ACIDSPRAY || 
         id == PBMoves::BRINE || id == PBMoves::THOUSANDWAVES ||
         id == PBMoves::APPLEACID)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The toxic water strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 27 # Mountain
        if (id == PBMoves::VITALTHROW || id == PBMoves::CIRCLETHROW || 
         id == PBMoves::STORMTHROW)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("{1} was thrown down partway the mountain!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::OMINOUSWIND || id == PBMoves::ICYWIND || 
         id == PBMoves::SILVERWIND || id == PBMoves::TWISTER || 
         id == PBMoves::RAZORWIND || id == PBMoves::FAIRYWIND)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The wind strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::OMINOUSWIND || id == PBMoves::ICYWIND || 
         id == PBMoves::SILVERWIND || id == PBMoves::TWISTER || 
         id == PBMoves::RAZORWIND || id == PBMoves::FAIRYWIND || 
         id == PBMoves::GUST) && @battle.pbWeather==PBWeather::STRONGWINDS
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The wind strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::THUNDER || id == PBMoves::ERUPTION|| 
         id == PBMoves::AVALANCHE)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The mountain strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 28 # Snowy Mountain
        if (id == PBMoves::VITALTHROW || id == PBMoves::CIRCLETHROW || 
         id == PBMoves::STORMTHROW)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("{1} was thrown partway down the mountain!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::OMINOUSWIND ||
         id == PBMoves::SILVERWIND || id == PBMoves::TWISTER || 
         id == PBMoves::RAZORWIND || id == PBMoves::FAIRYWIND)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The wind strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::ICYWIND)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The frigid wind strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::OMINOUSWIND || id == PBMoves::ICYWIND || 
         id == PBMoves::SILVERWIND || id == PBMoves::TWISTER || 
         id == PBMoves::RAZORWIND || id == PBMoves::FAIRYWIND || 
         id == PBMoves::GUST) && @battle.pbWeather==PBWeather::STRONGWINDS
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The wind strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::SCALD || id == PBMoves::STEAMERUPTION)
          damagemult=(damagemult*0.5).round
          @battle.pbDisplay(_INTL("The cold softened the attack...",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::AVALANCHE || id == PBMoves::POWDERSNOW)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The snow strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 29 # Blessed Field
        if (id == PBMoves::MYSTICALFIRE || id == PBMoves::MAGICALLEAF ||
          id == PBMoves::ANCIENTPOWER || id == PBMoves::JUDGMENT ||
          id == PBMoves::SACREDFIRE)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The holy energy resonated with the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::PSYSTRIKE || id == PBMoves::AEROBLAST ||
         id == PBMoves::ORIGINPULSE || id == PBMoves::PRECIPICEBLADES ||
         id == PBMoves::DRAGONASCENT || id == PBMoves::DOOMDUMMY ||
         id == PBMoves::MISTBALL || id == PBMoves::LUSTERPURGE ||
         id == PBMoves::PSYCHOBOOST || id == PBMoves::SPACIALREND ||
         id == PBMoves::ROAROFTIME || id == PBMoves::CRUSHGRIP ||
         id == PBMoves::SECRETSWORD || id == PBMoves::RELICSONG ||
         id == PBMoves::HYPERSPACEHOLE || id == PBMoves::LANDSWRATH ||
         id == PBMoves::MOONGEISTBEAM || id == PBMoves::SUNSTEELSTRIKE ||         
         id == PBMoves::PRISMATICLASER || id == PBMoves::FLEURCANNON ||
         (id == PBMoves::MULTIPULSE && type != PBTypes::NORMAL) || id == PBMoves::BEHEMOTHBLADE ||
         id == PBMoves::BEHEMOTHBASH || id == PBMoves::DYNAMAXCANNON ||
         id == PBMoves::ETERNABEAM || id == PBMoves::GENESISSUPERNOVA)
          damagemult=(damagemult*1.3).round
          @battle.pbDisplay(_INTL("The legendary energy resonated with the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 30 # Mirror
        if (id == PBMoves::MIRRORSHOT)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The mirrors strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::CHARGEBEAM || id == PBMoves::SOLARBEAM || 
         id == PBMoves::PSYBEAM || id == PBMoves::TRIATTACK ||
         id == PBMoves::BUBBLEBEAM || id == PBMoves::HYPERBEAM ||
         id == PBMoves::ICEBEAM || id == PBMoves::ORIGINPULSE ||
         id == PBMoves::MOONGEISTBEAM || id == PBMoves::FLEURCANNON) && 
         $fecounter == 1
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The beam was focused from the reflection!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::AURORABEAM || id == PBMoves::SIGNALBEAM ||
         id == PBMoves::FLASHCANNON || id == PBMoves::LUSTERPURGE ||
         id == PBMoves::DAZZLINGGLEAM || id == PBMoves::TECHNOBLAST || 
         id == PBMoves::DOOMDUMMY || id == PBMoves::PRISMATICLASER)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The reflected light was blinding!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        $fecounter = 0
      when 31 # Fairy Tale
        if (id == PBMoves::DRAININGKISS)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("True love never hurt so badly!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::MISTBALL)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The magical energy strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::NIGHTSLASH || id == PBMoves::LEAFBLADE || 
          id == PBMoves::PSYCHOCUT || id == PBMoves::SMARTSTRIKE || 
          id == PBMoves::SOLARBLADE || id == PBMoves::RAZORSHELL ||
          id == PBMoves::BEHEMOTHBLADE)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The blade cuts true!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if id == PBMoves::BEHEMOTHBASH
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("For Justice!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::MAGICALLEAF || id == PBMoves::MYSTICALFIRE ||
         id == PBMoves::ANCIENTPOWER || id == PBMoves::RELICSONG ||
         id == PBMoves::SPARKLINGARIA || id == PBMoves::MOONGEISTBEAM ||
         id == PBMoves::FLEURCANNON)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The magical energy strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 32 # Dragon's Den
        if (id == PBMoves::MEGAKICK)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Trial of the Dragon!!!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::STOMPINGTANTRUM)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Wrath of the Dragon!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::ROCKCLIMB || id == PBMoves::STRENGTH)         
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Unrivaled Power!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::SMACKDOWN || id == PBMoves::THOUSANDARROWS)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("{1} was knocked into the lava!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::MAGMASTORM || id == PBMoves::LAVAPLUME || 
         id == PBMoves::SHELLTRAP || id == PBMoves::EARTHPOWER || 
         id == PBMoves::LAVASURF)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The lava strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::POWERGEM || id == PBMoves::DIAMONDSTORM ||
         id == PBMoves::MATRIXSHOT)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Sparkling treasure!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::LUSTERPURGE || id == PBMoves::MISTBALL)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("Draconic energy boosted the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::DRAGONASCENT)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The draconic energy boosted the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::PAYDAY)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("Sparkling treasure!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 33 # Flower Garden
        if (id == PBMoves::CUT) && $fecounter > 0
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("{1} was cut down to size!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::PETALBLIZZARD || id == PBMoves::PETALDANCE || id == PBMoves::FLEURCANNON) && $fecounter = 2
          damagemult=(damagemult*1.2).round
          @battle.pbDisplay(_INTL("The fresh scent of flowers boosted the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::PETALBLIZZARD || id == PBMoves::PETALDANCE || id == PBMoves::FLEURCANNON) && $fecounter > 2
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The vibrant aroma scent of flowers boosted the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 34 # Starlight Arena
        if (id == PBMoves::AURORABEAM || id == PBMoves::SIGNALBEAM ||
         id == PBMoves::FLASHCANNON || id == PBMoves::LUSTERPURGE ||
         id == PBMoves::DAZZLINGGLEAM || id == PBMoves::MIRRORSHOT ||
         id == PBMoves::TECHNOBLAST || id == PBMoves::SOLARBEAM ||
         id == PBMoves::PRISMATICLASER || id ==PBMoves::PHOTONGEYSER)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Starlight surged through the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::MOONBLAST)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Lunar energy surged through the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::DRACOMETEOR || id == PBMoves::METEORMASH ||
         id == PBMoves::COMETPUNCH || id == PBMoves::SPACIALREND ||
         id == PBMoves::SWIFT || id == PBMoves::HYPERSPACEHOLE ||
         id == PBMoves::HYPERSPACEFURY || id == PBMoves::MOONGEISTBEAM ||
         id == PBMoves::BLACKHOLEECLIPSE || id == PBMoves::SEARINGSUNRAZESMASH || id == PBMoves::MENACINGMOONRAZEMAELSTROM || id == PBMoves::LIGHTTHATBURNSTHESKY ||
         id == PBMoves::SUNSTEELSTRIKE || id == PBMoves::METEORASSAULT)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The astral energy boosted the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::DOOMDUMMY)
          damagemult=(damagemult*4).round
          @battle.pbDisplay(_INTL("A star came crashing down!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 35 # New World
        if (id == PBMoves::AURORABEAM || id == PBMoves::SIGNALBEAM ||
         id == PBMoves::FLASHCANNON || id == PBMoves::DAZZLINGGLEAM || 
         id == PBMoves::MIRRORSHOT)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The light shone through the infinite darkness!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::EARTHPOWER || id == PBMoves::POWERGEM ||
         id == PBMoves::ERUPTION || id == PBMoves::CONTINENTALCRUSH)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The germinal matter amassed in the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::PSYSTRIKE || id == PBMoves::AEROBLAST || 
         id == PBMoves::SACREDFIRE || id == PBMoves::MISTBALL || 
         id == PBMoves::LUSTERPURGE || id == PBMoves::ORIGINPULSE ||
         id == PBMoves::PRECIPICEBLADES || id == PBMoves::DRAGONASCENT ||
         id == PBMoves::PSYCHOBOOST || id == PBMoves::ROAROFTIME ||
         id == PBMoves::MAGMASTORM || id == PBMoves::CRUSHGRIP ||
         id == PBMoves::JUDGMENT || id == PBMoves::SEEDFLARE ||
         id == PBMoves::SHADOWFORCE || id == PBMoves::SEARINGSHOT ||
         id == PBMoves::VCREATE || id == PBMoves::SECRETSWORD ||
         id == PBMoves::SACREDSWORD || id == PBMoves::RELICSONG ||
         id == PBMoves::GLACIATE || 
         id == PBMoves::GENESISSUPERNOVA || id == PBMoves::SOULSTEALING7STARSTRIKE
         id == PBMoves::FUSIONBOLT || id == PBMoves::FUSIONFLARE ||
         id == PBMoves::ICEBURN || id == PBMoves::FREEZESHOCK ||
         id == PBMoves::BOLTSTRIKE || id == PBMoves::BLUEFLARE ||
         id == PBMoves::TECHNOBLAST || id == PBMoves::OBLIVIONWING ||
         id == PBMoves::LANDSWRATH || id == PBMoves::THOUSANDARROWS ||
         id == PBMoves::THOUSANDWAVES || id == PBMoves::DIAMONDSTORM ||
         id == PBMoves::STEAMERUPTION || id == PBMoves::COREENFORCER ||
         id == PBMoves::FLEURCANNON || id == PBMoves::PRISMATICLASER ||
         id == PBMoves::SUNSTEELSTRIKE || id == PBMoves::SPECTRALTHIEF ||
         id == PBMoves::MOONGEISTBEAM || id == PBMoves::MULTIATTACK)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The ethereal energy strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::VACUUMWAVE || id == PBMoves::DRACOMETEOR ||
         id == PBMoves::METEORMASH || id == PBMoves::MOONBLAST || 
         id == PBMoves::COMETPUNCH || id == PBMoves::SWIFT || 
         id == PBMoves::SEARINGSUNRAZESMASH || id == PBMoves::MENACINGMOONRAZEMAELSTROM || 
         id == PBMoves::HYPERSPACEHOLE || id == PBMoves::SPACIALREND || 
         id == PBMoves::HYPERSPACEFURY|| id == PBMoves::ANCIENTPOWER ||
         id == PBMoves::FUTUREDUMMY)
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The astral energy boosted the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if id == PBMoves::BLACKHOLEECLIPSE
          damagemult=(damagemult*4).round
          @battle.pbDisplay(_INTL("The void swallowed up {1}!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if id == PBMoves::LIGHTTHATBURNSTHESKY
          damagemult=(damagemult*4).round
          @battle.pbDisplay(_INTL("The Blinding One shone down upon the New World!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::DOOMDUMMY)
          damagemult=(damagemult*4).round
          @battle.pbDisplay(_INTL("A star came crashing down on {1}!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 37 # Psychic Terrain
        if (id == PBMoves::HEX || id == PBMoves::MAGICALLEAF ||
         id == PBMoves::MYSTICALFIRE || id == PBMoves::MOONBLAST || 
         id == PBMoves::AURASPHERE || id == PBMoves::MINDBLOWN)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The psychic energy strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end 
      when 38 # Dimensional 
        if (id == PBMoves::HYPERSPACEFURY || id == PBMoves::HYPERSPACEHOLE || 
         id == PBMoves::SPACIALREND || id == PBMoves::ROAROFTIME || 
         id == PBMoves::DYNAMAXCANNON || id == PBMoves::ETERNABEAM || 
         id == PBMoves::SHADOWFORCE)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The attack has been corrupted.",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::DARKPULSE || id == PBMoves::NIGHTDAZE)
          damagemult=(damagemult*1.2).round
          @battle.pbDisplay(_INTL("The attack has been corrupted.",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 39 # Frozen Dimensional
        if (id == PBMoves::SURF || id == PBMoves::MUDDYWATER || 
         id == PBMoves::WATERPULSE || id == PBMoves::HYDROPUMP ||
         id == PBMoves::NIGHTSLASH || id == PBMoves::DARKPULSE || 
         id == PBMoves::HYPERSPACEFURY || id == PBMoves::HYPERSPACEHOLE) 
          damagemult=(damagemult*1.2).round
          @battle.pbDisplay(_INTL("The ice warped the attack.",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 40 # Haunted
        if (id == PBMoves::FLAMEBURST || id == PBMoves::INFERNO || 
            id == PBMoves::FIRESPIN || id == PBMoves::FLAMECHARGE)
          damagemult=(damagemult*1.3).round
          @battle.pbDisplay(_INTL("Will-o'-wisps joined the attack...",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::SPIRITBREAK)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Busted!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 41 # Corrupted cave
        if (id == PBMoves::SEEDFLARE || id == PBMoves::APPLEACID) 
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The move absorbed the filth!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 42 # Bewitched Woods
        if (id == PBMoves::ICEBEAM || id == PBMoves::HYPERBEAM || 
         id == PBMoves::SIGNALBEAM || id == PBMoves::AURORABEAM ||
         id == PBMoves::BUBBLEBEAM || id == PBMoves::CHARGEBEAM ||
         id == PBMoves::PSYBEAM || id == PBMoves::FLASHCANNON ||
         id == PBMoves::MAGICALLEAF)
          damagemult=(damagemult*1.4).round
          @battle.pbDisplay(_INTL("Magic aura amplified the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::DARKPULSE || id == PBMoves::NIGHTDAZE ||
         id == PBMoves::MOONBLAST)
          damagemult=(damagemult*1.2).round
          @battle.pbDisplay(_INTL("The forest is cursed with nightfall!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
        if (id == PBMoves::HEX || id == PBMoves::MYSTICALFIRE || 
         id == PBMoves::HEXDUMMY || id == PBMoves::SPIRITBREAK)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("Magic aura amplified the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 43 # Sky Field
        if (id == PBMoves::ICYWIND || id == PBMoves::OMINOUSWIND || 
         id == PBMoves::SILVERWIND || id == PBMoves::RAZORWIND ||
         id == PBMoves::FAIRYWIND || id == PBMoves::AEROBLAST ||
         id == PBMoves::SKYUPPERCUT || id == PBMoves::FLYINGPRESS ||
         id == PBMoves::THUNDERSHOCK || id == PBMoves::THUNDERBOLT ||
         id == PBMoves::THUNDER || id == PBMoves::STEELWING ||
         id == PBMoves::TWISTER || id == PBMoves::DRAGONDARTS || 
         id == PBMoves::GRAVAPPLE || id == PBMoves::DRAGONASCENT)
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The open skies strengthened the attack!",opponent.pbThis)) if $feshutup == 0
          $feshutup+=1
        end
      when 44 # Colosseum Field  
        if id == PBMoves::BEATUP  
          damagemult=(damagemult*2.0).round  
          @battle.pbDisplay(_INTL("The fighters rallied together!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
        if id == PBMoves::FELLSTINGER  
          damagemult=(damagemult*2.0).round  
          @battle.pbDisplay(_INTL("The coup de grâce!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
        if id == PBMoves::PAYDAY  
          damagemult=(damagemult*2.0).round  
          @battle.pbDisplay(_INTL("The audience hurled coins down!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
        if (id == PBMoves::REVERSAL)  
          damagemult=(damagemult*2.0).round  
          @battle.pbDisplay(_INTL("For Honor!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
        if (id == PBMoves::PURSUIT)  
          damagemult=(damagemult*2.0).round  
          @battle.pbDisplay(_INTL("There is no escape!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
        if (id == PBMoves::SACREDSWORD || id == PBMoves::SECRETSWORD ||  
            id == PBMoves::SUBMISSION || id == PBMoves::METEORASSAULT ||  
            id == PBMoves::SMARTSTRIKE || id == PBMoves::SMACKDOWN ||  
            id == PBMoves::BRUTALSWING)  
          damagemult=(damagemult*1.5).round  
          @battle.pbDisplay(_INTL("For Honor!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
        if (id == PBMoves::ELECTROWEB || id == PBMoves::VINEWHIP ||  
            id == PBMoves::PSYCHOCUT || id == PBMoves::NIGHTSLASH ||  
            id == PBMoves::BONEMERANG || id == PBMoves::FIRSTIMPRESSION ||  
            id == PBMoves::BONERUSH || id == PBMoves::BONECLUB ||  
            id == PBMoves::LEAFBLADE || id == PBMoves::PAYBACK ||  
            id == PBMoves::PUNISHMENT || id == PBMoves::METEORMASH ||  
            id == PBMoves::BULLETPUNCH || id == PBMoves::CLANGINGSCALES ||  
            id == PBMoves::STEAMROLLER)  
          damagemult=(damagemult*1.5).round  
          @battle.pbDisplay(_INTL("For Glory!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
        if (id == PBMoves::STORMTHROW)  
          damagemult=(damagemult*1.2).round  
          @battle.pbDisplay(_INTL("For Honor!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1            
        end  
        if (id == PBMoves::WOODHAMMER || id == PBMoves::DRAGONHAMMER ||  
            id == PBMoves::POWERWHIP || id == PBMoves::SPIRITSHACKLE ||  
            id == PBMoves::DRILLRUN || id == PBMoves::DRILLPECK ||  
            id == PBMoves::ICEHAMMER || id == PBMoves::ICICLESPEAR ||  
            id == PBMoves::ANCHORSHOT || id == PBMoves::CRABHAMMER ||  
            id == PBMoves::SHADOWBONE || id == PBMoves::FIRELASH ||  
            id == PBMoves::SUCKERPUNCH || id == PBMoves::THROATCHOP)  
          damagemult=(damagemult*1.2).round  
          @battle.pbDisplay(_INTL("For Glory!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
      when 45 # Infernal Field  
        if (id == PBMoves::BLASTBURN || id == PBMoves::EARTHPOWER ||  
            id == PBMoves::PRECIPICEBLADES || id == PBMoves::INFERNO
            id == PBMoves::INFERNOOVERDRIVE)  
          damagemult=(damagemult*1.5).round  
          @battle.pbDisplay(_INTL("Infernal flames strengthened the attack!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end  
        if (id == PBMoves::PUNISHMENT || id == PBMoves::SMOG ||  
            id == PBMoves::DREAMEATER)  
          damagemult=(damagemult*2.0).round  
          @battle.pbDisplay(_INTL("The coup de grâce!",opponent.pbThis)) if $feshutup == 0  
          $feshutup+=1  
        end
    end      
    #End S.Field Effects
    basedmg=(basedmg*damagemult*1.0/0x1000).round
    ##### Calculate attacker's attack stat #####
    atk=attacker.attack
    atkstage=attacker.stages[PBStats::ATTACK]+6
    if attacker.effects[PBEffects::PowerTrick]
      atk=attacker.defense
      atkstage=attacker.stages[PBStats::DEFENSE]+6
    end
    if @function==0x121 # Foul Play
      atk=opponent.attack
      atkstage=opponent.stages[PBStats::ATTACK]+6
      if opponent.effects[PBEffects::PowerTrick]
        atk=opponent.defense
        atkstage=opponent.stages[PBStats::DEFENSE]+6
      end         
    end
    if @function==0x184 # Body Press
      atk=attacker.defense 
      atkstage=attacker.stages[PBStats::DEFENSE]+6
      if attacker.effects[PBEffects::PowerTrick]
        atk=attacker.attack
        atkstage=attacker.stages[PBStats::ATTACK]+6
      end         
    end
    if @function==0x209
      atk=attacker.spdef
      atkstage=attacker.stages[PBStats::SPDEF]+6
    end
    if @function==0x175 # Photon Geyser 
      atk=attacker.spatk
      atkstage=attacker.stages[PBStats::SPATK]+6  
      if attacker.attack > attacker.spatk
        atk=attacker.attack
        atkstage=attacker.stages[PBStats::ATTACK]+6
      end
    end  
    if type>=0 && (pbIsSpecial?(type) || @function==0x208 || (isConst?(attacker.species,PBSpecies,:CRYOGONAL) && attacker.hasWorkingItem(:CRYCREST)))
      atk=attacker.spatk
      atkstage=attacker.stages[PBStats::SPATK]+6
      if @function==0x121 # Foul Play
        atk=opponent.spatk
        atkstage=opponent.stages[PBStats::SPATK]+6
      end
      if $fefieldeffect == 24
        gl1 = 0
        gl2 = 0
        gl3 = 0
        gl4 = 0
        avBoost = 1
        specsBoost = 1    
        evioBoost = 1
        dstBoost = 1
        lbBoost = 1
       # dewBoost = 1
        dssBoost = 1
        mpBoost = 1
        fbBoost = 1
        minusBoost = 1
        plusBoost = 1
        solarBoost = 1
        fgBoost = 1
        batteryBoost = 1
        wiseBoost = 1
        avBoost = 1.5 if attacker.hasWorkingItem(:ASSAULTVEST)
        specsBoost = 1.5 if attacker.hasWorkingItem(:CHOICESPECS)
        evioBoost = 1.5 if attacker.hasWorkingItem(:EVIOLITE) && pbGetEvolvedFormData(attacker.species).length>0
        dstBoost = 2 if attacker.hasWorkingItem(:DEEPSEATOOTH) && isConst?(attacker.species,PBSpecies,:CLAMPERL)
        lbBoost = 2 if attacker.hasWorkingItem(:LIGHTBALL) && isConst?(attacker.species,PBSpecies,:PIKACHU)
#        dewBoost = 1.5 if attacker.hasWorkingItem(:SOULDEW) && (isConst?(attacker.species,PBSpecies,:LATIAS) || isConst?(attacker.species,PBSpecies,:LATIOS))
        dssBoost = 2 if attacker.hasWorkingItem(:DEEPSEASCALE) && isConst?(attacker.species,PBSpecies,:CLAMPERL)        
        mpBoost = 1.5 if attacker.hasWorkingItem(:METALPOWDER) && isConst?(attacker.species,PBSpecies,:DITTO)
        fbBoost = 1.5 if attacker.hasWorkingAbility(:FLAREBOOST) && attacker.status==PBStatuses::BURN
        minusboost = 1.5 if attacker.hasWorkingAbility(:MINUS) && attacker.pbPartner.hasWorkingAbility(:PLUS)
        plusboost = 1.5 if attacker.hasWorkingAbility(:PLUS) && attacker.pbPartner.hasWorkingAbility(:MINUS)
        solarBoost = 1.5 if (attacker.hasWorkingAbility(:SOLARPOWER) || (isConst?(attacker.species,PBSpecies,:CASTFORM) && isConst?(attacker.item,PBItems,:CASTCREST) && attacker.form==1) ) && @battle.pbWeather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
        fgBoost = 1.5 if attacker.hasWorkingAbility(:FLOWERGIFT) && @battle.pbWeather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA)
        batteryBoost = 1.3 if attacker.pbPartner.hasWorkingAbility(:BATTERY)
        wiseBoost = 1.1 if attacker.hasWorkingItem(:WISEGLASSES)
        gl1 = attacker.spatk
        gl2 = attacker.spdef
        gl3 = attacker.stages[PBStats::SPDEF]+6
        gl4 = attacker.stages[PBStats::SPATK]+6
        gl2=(gl2*1.0*avBoost*evioBoost*dssBoost*fgBoost*stagemul[gl3]/stagediv[gl3]).floor
        gl1=(gl1*1.0*specsBoost*dstBoost*lbBoost*fbBoost*minusBoost*plusBoost*solarBoost*wiseBoost*batteryBoost*stagemul[gl4]/stagediv[gl4]).floor
        if gl1 < gl2
          atk=attacker.spdef
          atkstage=attacker.stages[PBStats::SPDEF]+6
        end
      end
    end
    if @function==0x208 # Super UMD  
      atk=attacker.spdef
      atkstage=attacker.stages[PBStats::SPDEF]+6
    end
    if attacker.hasWorkingItem(:CLAYCREST) && isConst?(attacker.species,PBSpecies,:CLAYDOL) # Claydol Crest
        atk=attacker.defense
    end  
    if attacker.hasWorkingItem(:TYPHCREST) && isConst?(attacker.species,PBSpecies,:TYPHLOSION) # Typhlosion Crest
        atk=attacker.spatk
        atkstage=attacker.stages[PBStats::SPATK]+6
    end 
    if (!(opponent.hasWorkingAbility(:UNAWARE) || @battle.SilvallyCheck(opponent, PBTypes::FAIRY)) || (options&SELFCONFUSE)!=0 || opponent.moldbroken)
      atkstage=6 if opponent.damagestate.critical && atkstage<6
      atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
    end
    if attacker.hasWorkingAbility(:HUSTLE) && pbIsPhysical?(type)
      atk=(atk*1.5).round
    end
    atkmult=0x1000
    if attacker.hasWorkingItem(:ASSAULTVEST) && (@function==0x208 || pbIsSpecial?(type)) &&
      $fefieldeffect == 24
      if gl1 < gl2
        atkmult=(atkmult*1.5).round
      end
    end
#    if attacker.hasWorkingItem(:SOULDEW) && (isConst?(attacker.species,PBSpecies,:LATIAS) || 
#      isConst?(attacker.species,PBSpecies,:LATIOS))  && $fefieldeffect == 24
#      if gl1 < gl2
#        atkmult=(atkmult*1.5).round
#      end
#    end    
    if attacker.hasWorkingItem(:DEEPSEASCALE) && 
      isConst?(attacker.species,PBSpecies,:CLAMPERL) && $fefieldeffect == 24
      if gl1 < gl2
        atkmult=(atkmult*2).round
      end
    end  
    if attacker.hasWorkingItem(:METALPOWDER) && 
      isConst?(attacker.species,PBSpecies,:DITTO) && $fefieldeffect == 24
      if gl1 < gl2
        atkmult=(atkmult*1.5).round
      end
    end     
    if attacker.hasWorkingAbility(:FLOWERGIFT) && 
       @battle.pbWeather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA) &&
       $fefieldeffect == 24
      if gl1 < gl2
        atkmult=(atkmult*1.5).round
      end
    end
    if opponent.hasWorkingAbility(:ICESCALES) && pbIsSpecial?(type)
      atkmult=(atkmult*0.5).round
    end
    if attacker.pbPartner.hasWorkingAbility(:POWERSPOT)
      if ($fefieldeffect == 29 || $fefieldeffect == 37 || 
          $fefieldeffect == 40 ||$fefieldeffect == 42)
        atkmult=(atkmult*1.5).round
      else
        atkmult=(atkmult*1.3).round
      end
    end
    if @battle.internalbattle
      if !@battle.pbOwnedByPlayer?(attacker.index) && pbIsPhysical?(type) &&
         isConst?(attacker.species,PBSpecies,:AEGISLASH) && attacker.form==1 && $game_variables[200]==2
        atkmult=(atkmult*1.1).round
      end
      if @battle.pbOwnedByPlayer?(attacker.index) && pbIsSpecial?(type) &&
         isConst?(attacker.species,PBSpecies,:AEGISLASH) && attacker.form==1 && $game_variables[200]==2
        atkmult=(atkmult*1.1).round
      end
    end
    if (opponent.hasWorkingAbility(:THICKFAT) || @battle.SilvallyCheck(opponent,PBTypes::ICE)) &&
       (isConst?(type,PBTypes,:ICE) || isConst?(type,PBTypes,:FIRE)) && !(opponent.moldbroken)
      atkmult=(atkmult*0.5).round
    end
    if (opponent.hasWorkingAbility(:PASTELVEIL) || opponent.pbPartner.hasWorkingAbility(:PASTELVEIL)) &&
       ($fefieldeffect==3 || $fefieldeffect==9|| @battle.field.effects[PBEffects::MistyTerrain]>0 ) && isConst?(type,PBTypes,:POISON) && !(opponent.moldbroken)
      atkmult=(atkmult*0.5).round
    end
    if attacker.hasWorkingAbility(:PUNKROCK) && isSoundBased?
      if ($fefieldeffect == 6 || $fefieldeffect == 23)
        atkmult=(atkmult*1.5).round
      else
        atkmult=(atkmult*1.3).round
      end
    end
    if attacker.hp<=(attacker.totalhp/3).floor
      if (attacker.hasWorkingAbility(:OVERGROW) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingAbility(:BLAZE) && isConst?(type,PBTypes,:FIRE) && $fefieldeffect!=39) ||
       (attacker.hasWorkingAbility(:TORRENT) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingAbility(:SWARM) && isConst?(type,PBTypes,:BUG))
        atkmult=(atkmult*1.5).round
      end
    elsif $fefieldeffect == 7 && (attacker.hasWorkingAbility(:BLAZE) &&
      isConst?(type,PBTypes,:FIRE))
      atkmult=(atkmult*1.5).round
    elsif $fefieldeffect == 15 && (attacker.hasWorkingAbility(:OVERGROW) &&
      isConst?(type,PBTypes,:GRASS))
      atkmult=(atkmult*1.5).round
    elsif $fefieldeffect == 15 && (attacker.hasWorkingAbility(:SWARM) &&
      isConst?(type,PBTypes,:BUG))
      atkmult=(atkmult*1.5).round
    elsif $fefieldeffect == 16 && (attacker.hasWorkingAbility(:BLAZE) &&
      isConst?(type,PBTypes,:FIRE)) && attacker.effects[PBEffects::Blazed]
      atkmult=(atkmult*1.5).round
    elsif ($fefieldeffect == 21 || $fefieldeffect == 22) &&
     (attacker.hasWorkingAbility(:TORRENT) && isConst?(type,PBTypes,:WATER))
      atkmult=(atkmult*1.5).round
    elsif $fefieldeffect == 33 && (attacker.hasWorkingAbility(:SWARM) &&
      isConst?(type,PBTypes,:BUG))
      atkmult=(atkmult*1.5).round if $fecounter == 0 || $fecounter == 1
      atkmult=(atkmult*2).round if $fecounter == 2 || $fecounter == 3
      atkmult=(atkmult*3).round if $fecounter == 4
    elsif $fefieldeffect == 33 && (attacker.hasWorkingAbility(:OVERGROW) &&
      isConst?(type,PBTypes,:GRASS))
      case $fecounter
        when 1
          if attacker.hp<=(attacker.totalhp*0.67).floor
            atkmult=(atkmult*1.5).round
          end
        when 2
            atkmult=(atkmult*1.5).round
        when 3
            atkmult=(atkmult*2).round
        when 4
            atkmult=(atkmult*3).round
      end
    elsif $fefieldeffect == 45 && (attacker.hasWorkingAbility(:BLAZE) &&  
      isConst?(type,PBTypes,:FIRE))  
      atkmult=(atkmult*1.5).round
    end
    # Execution
    if attacker.hasWorkingAbility(:EXECUTION)
      if opponent.hp <= (opponent.totalhp/2).floor
        atkmult=(atkmult*2).round
      end
    end
    if attacker.hasWorkingAbility(:GUTS) &&
      attacker.status!=0 && pbIsPhysical?(type)
      atkmult=(atkmult*1.5).round
    end
    if (attacker.hasWorkingAbility(:PLUS) || attacker.hasWorkingAbility(:MINUS)) &&
      pbIsSpecial?(type)
      partner=attacker.pbPartner
      if partner.hasWorkingAbility(:PLUS) || partner.hasWorkingAbility(:MINUS)
        atkmult=(atkmult*1.5).round
      elsif $fefieldeffect == 18 || $fefieldeffect == 1 || @battle.field.effects[PBEffects::ElectricTerrain]>0 
        atkmult=(atkmult*1.5).round
      end
    end
    if attacker.hasWorkingItem(:MUSCLEBAND) && pbIsPhysical?(type)
      atkmult=(atkmult*1.1).round
    end
    if attacker.hasWorkingItem(:WISEGLASSES) && pbIsSpecial?(type)
      atkmult=(atkmult*1.1).round
    end
    if (attacker.pbPartner).hasWorkingAbility(:BATTERY) && pbIsSpecial?(type)
      atkmult=(atkmult*1.3).round
    end    
    if attacker.hasWorkingAbility(:DEFEATIST) &&
       attacker.hp<=(attacker.totalhp/2).floor
      atkmult=(atkmult*0.5).round
    end
    if $fefieldeffect == 5  
      if (attacker.hasWorkingAbility(:ILLUSION) && attacker.effects[PBEffects::Illusion]!=nil)  
        atkmult=(atkmult*1.2).round  
      end  
      if (attacker.hasWorkingAbility(:GORILLATACTICS) || attacker.hasWorkingAbility(:RECKLESS))  
        atkmult=(atkmult*1.2).round  
      end  
      if attacker.hasWorkingAbility(:COMPETITIVE)  
        frac = (1.0*attacker.hp)/(1.0*attacker.totalhp)  
        multiplier = 1.0  
        multiplier += ((1.0-frac)/0.8)  
        if frac < 0.2  
          multiplier = 2.0  
        end  
        atkmult=(atkmult*multiplier).round  
      end  
    end
    if (attacker.hasWorkingAbility(:PUREPOWER) && $fefieldeffect!=37) ||
       attacker.hasWorkingAbility(:HUGEPOWER) && pbIsPhysical?(type)
      atkmult=(atkmult*2.0).round
    end
    if attacker.hasWorkingAbility(:PUREPOWER) && ($fefieldeffect==37 || @battle.field.effects[PBEffects::PsychicTerrain]>0) && 
      pbIsSpecial?(type)
      atkmult=(atkmult*2.0).round
    end
    if (attacker.hasWorkingAbility(:SOLARPOWER) || 
       (isConst?(attacker.species,PBSpecies,:CASTFORM) && isConst?(attacker.item,PBItems,:CASTCREST) && attacker.form==1) ) &&
       $fefieldeffect!=39 && @battle.pbWeather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA) && pbIsSpecial?(type)
      atkmult=(atkmult*1.5).round
    end
    if attacker.hasWorkingAbility(:FLASHFIRE) && $fefieldeffect!=39 &&
       attacker.effects[PBEffects::FlashFire] && isConst?(type,PBTypes,:FIRE)
      atkmult=(atkmult*1.5).round
    end
    if attacker.hasWorkingAbility(:SLOWSTART) &&
       attacker.turncount<5 && pbIsPhysical?(type)
      atkmult=(atkmult*0.5).round
    end
    if !(@battle.pbOwnedByPlayer?(attacker.index)) && @battle.pbPlayer.numbadges>=12 && $game_variables[200]==2
      atkmult=(atkmult*1.1).round
    end
    if ((@battle.pbWeather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA)) || $fefieldeffect == 33 || $fefieldeffect == 42 || 
     (attacker.hasWorkingItem(:CHERCREST) && isConst?(attacker.species,PBSpecies,:CHERRIM)) || 
     (attacker.pbPartner.hasWorkingItem(:CHERCREST) && isConst?(attacker.pbPartner.species,PBSpecies,:CHERRIM)) ) && 
     pbIsPhysical?(type)
      if attacker.hasWorkingAbility(:FLOWERGIFT) &&
         isConst?(attacker.species,PBSpecies,:CHERRIM)
        atkmult=(atkmult*1.5).round
      end
      if attacker.pbPartner.hasWorkingAbility(:FLOWERGIFT)  &&
         isConst?(attacker.pbPartner.species,PBSpecies,:CHERRIM)
        atkmult=(atkmult*1.5).round
      end
    end
    if (attacker.pbPartner.hasWorkingAbility(:STEELYSPIRIT) || attacker.hasWorkingAbility(:STEELYSPIRIT)) && isConst?(type,PBTypes,:STEEL)
      if $fefieldeffect == 31
        atkmult=(atkmult*2.0).round
      else
        atkmult=(atkmult*1.5).round
      end
    end
    if attacker.hasWorkingItem(:THICKCLUB) &&
       (isConst?(attacker.species,PBSpecies,:CUBONE) ||
       isConst?(attacker.species,PBSpecies,:MAROWAK)) && pbIsPhysical?(type)
      atkmult=(atkmult*2.0).round
    end
    if attacker.hasWorkingItem(:DEEPSEATOOTH) &&
       isConst?(attacker.species,PBSpecies,:CLAMPERL) && pbIsSpecial?(type)
      atkmult=(atkmult*2.0).round
    end
    if attacker.hasWorkingItem(:LIGHTBALL) &&
       isConst?(attacker.species,PBSpecies,:PIKACHU)
      atkmult=(atkmult*2.0).round
    end
#    if attacker.hasWorkingItem(:SOULDEW) &&
#       (isConst?(attacker.species,PBSpecies,:LATIAS) ||
#       isConst?(attacker.species,PBSpecies,:LATIOS)) && pbIsSpecial?(type) &&
#       !@battle.rules["souldewclause"]
#      atkmult=(atkmult*1.5).round
#    end
    if attacker.hasWorkingAbility(:GORILLATACTICS) && pbIsPhysical?(type)
      atkmult=(atkmult*1.5).round
    end
    if attacker.hasWorkingItem(:CHOICEBAND) && pbIsPhysical?(type)
      atkmult=(atkmult*1.5).round
    end
    if attacker.hasWorkingItem(:CHOICESPECS) && pbIsSpecial?(type)
      atkmult=(atkmult*1.5).round
    end
    if isConst?(attacker.species,PBSpecies,:STANTLER) && attacker.hasWorkingItem(:STANTCREST) && 
     pbIsPhysical?(type)
      atkmult=(atkmult*1.5).round
    end
    if isConst?(attacker.species,PBSpecies,:HYPNO) && attacker.hasWorkingItem(:HYPCREST) && 
     pbIsSpecial?(type)
      atkmult=(atkmult*1.5).round
    end
    if $fefieldeffect == 34 || $fefieldeffect == 35
      if attacker.hasWorkingAbility(:VICTORYSTAR)
        atkmult=(atkmult*1.5).round
      end
      partner=attacker.pbPartner
      if partner && partner.hasWorkingAbility(:VICTORYSTAR)
        atkmult=(atkmult*1.5).round
      end
    end
    if attacker.hasWorkingAbility(:QUEENLYMAJESTY) && ($fefieldeffect==5 || $fefieldeffect==31)
      atkmult=(atkmult*1.5).round
    end 
    if attacker.hasWorkingAbility(:LONGREACH) && ($fefieldeffect==27 || $fefieldeffect==28)
      atkmult=(atkmult*1.5).round
    end
    if attacker.hasWorkingAbility(:CORROSION) && ($fefieldeffect==10 || $fefieldeffect==11 || $fefieldeffect==41)
      atkmult=(atkmult*1.5).round
    end
    if isConst?(opponent.species,PBSpecies,:BEHEEYEM) && opponent.hasWorkingItem(:BEHECREST)
      priorityAttacker = @battle.pbGetPriority(attacker)
      priorityOpponent = @battle.pbGetPriority(opponent)
      if priorityAttacker < priorityOpponent
        atkmult=(atkmult*0.66).round
      end
    end
    if isConst?(attacker.species,PBSpecies,:SPIRITOMB) && attacker.hasWorkingItem(:SPIRITCREST)
      allyfainted = attacker.pbFaintedPokemonCount
      modifier = (allyfainted * 0.2) + 1.0
      atkmult=(atkmult*modifier).round
    end
    atk=(atk*atkmult*1.0/0x1000).round
    ##### Calculate opponent's defense stat #####
    defense=opponent.defense
    defstage=opponent.stages[PBStats::DEFENSE]+6
    if @function==0x205 # Matrix Shot
      defense=opponent.spdef
      defstage=opponent.stages[PBStats::SPDEF]+6
    end
    if opponent.effects[PBEffects::PowerTrick]
      defense=opponent.attack
      defstage=opponent.stages[PBStats::ATTACK]+6
    end    
    # TODO: Wonder Room should apply around here
    applysandstorm=false
    gl1 = 0
    gl2 = 0
    gl3 = 0
    gl4 = 0  
    if type>=0 && pbIsSpecial?(type) && @function!=0x122 # Psyshock
      defense=opponent.spdef
      defstage=opponent.stages[PBStats::SPDEF]+6
      if $fefieldeffect == 24      
        avBoost = 1
        iceScalesBoost = 1
        specsBoost = 1    
        evioBoost = 1
        dstBoost = 1
        lbBoost = 1
#        dewBoost = 1
        dssBoost = 1
        mpBoost = 1
        fbBoost = 1
        minusBoost = 1
        plusBoost = 1
        solarBoost = 1
        fgBoost = 1
        batteryBoost = 1
        wiseBoost = 1
        avBoost = 1.5 if opponent.hasWorkingItem(:ASSAULTVEST)
        specsBoost = 1.5 if opponent.hasWorkingItem(:CHOICESPECS)
        evioBoost = 1.5 if opponent.hasWorkingItem(:EVIOLITE) && pbGetEvolvedFormData(opponent.species).length>0
        dstBoost = 2 if opponent.hasWorkingItem(:DEEPSEATOOTH) && isConst?(opponent.species,PBSpecies,:CLAMPERL)
        lbBoost = 2 if opponent.hasWorkingItem(:LIGHTBALL) && isConst?(opponent.species,PBSpecies,:PIKACHU)
#        dewBoost = 1.5 if opponent.hasWorkingItem(:SOULDEW) && (isConst?(opponent.species,PBSpecies,:LATIAS) || isConst?(opponent.species,PBSpecies,:LATIOS))
        dssBoost = 2 if opponent.hasWorkingItem(:DEEPSEASCALE) && isConst?(opponent.species,PBSpecies,:CLAMPERL)        
        mpBoost = 1.5 if opponent.hasWorkingItem(:METALPOWDER) && isConst?(opponent.species,PBSpecies,:DITTO)
        fbBoost = 1.5 if opponent.hasWorkingAbility(:FLAREBOOST) && opponent.status==PBStatuses::BURN
        minusboost = 1.5 if opponent.hasWorkingAbility(:MINUS) && opponent.pbPartner.hasWorkingAbility(:PLUS)
        plusboost = 1.5 if opponent.hasWorkingAbility(:PLUS) && opponent.pbPartner.hasWorkingAbility(:MINUS)
        solarBoost = 1.5 if (opponent.hasWorkingAbility(:SOLARPOWER) || (isConst?(opponent.species,PBSpecies,:CASTFORM) && isConst?(opponent.item,PBItems,:CASTCREST) && opponent.form==1) ) && @battle.pbWeather==PBWeather::SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
        fgBoost = 1.5 if opponent.hasWorkingAbility(:FLOWERGIFT) && @battle.pbWeather==PBWeather::SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
        batteryBoost = 1.3 if attacker.pbPartner.hasWorkingAbility(:BATTERY)
        wiseBoost = 1.1 if opponent.hasWorkingItem(:WISEGLASSES)
        gl1 = opponent.spatk
        gl2 = opponent.spdef
        gl3 = opponent.stages[PBStats::SPDEF]+6
        gl4 = opponent.stages[PBStats::SPATK]+6
        gl2=(gl2*1.0*avBoost*evioBoost*dssBoost*fgBoost*stagemul[gl3]/stagediv[gl3]).floor
        gl1=(gl1*1.0*specsBoost*dstBoost*lbBoost*fbBoost*minusBoost*plusBoost*solarBoost*wiseBoost*batteryBoost*stagemul[gl4]/stagediv[gl4]).floor
        if gl1 > gl2
          defense=opponent.spatk
          defstage=opponent.stages[PBStats::SPATK]+6
        end
      end
      applysandstorm=true
    end
    if !(attacker.hasWorkingAbility(:UNAWARE) || @battle.SilvallyCheck(attacker,PBTypes::FAIRY)) || (options&SELFCONFUSE)!=0
    #if !attacker.hasWorkingAbility(:UNAWARE)
      defstage=6 if @function==0xA9  # Chip Away 
      defstage=6 if (opponent.damagestate.critical || @function==0x208) && defstage>6
      defense=(defense*1.0*stagemul[defstage]/stagediv[defstage]).floor
    end
    if @battle.pbWeather==PBWeather::SANDSTORM &&
       opponent.pbHasType?(:ROCK) && applysandstorm
      defense=(defense*1.5).round
    end
    defmult=0x1000
    if opponent.hasWorkingItem(:CHOICESPECS) && $fefieldeffect == 24
      if gl1 > gl2   
        defmult=(defmult*1.5).round
      end
    end    
    if opponent.hasWorkingItem(:DEEPSEATOOTH) && 
      isConst?(opponent.species,PBSpecies,:CLAMPERL) && $fefieldeffect == 24
      if gl1 > gl2   
        defmult=(defmult*2).round
      end
    end       
    if opponent.hasWorkingItem(:LIGHTBALL) && 
      isConst?(opponent.species,PBSpecies,:PIKACHU) && $fefieldeffect == 24
      if gl1 > gl2   
        defmult=(defmult*2).round
      end
    end   
#    if opponent.hasWorkingItem(:SOULDEW) && (isConst?(opponent.species,PBSpecies,:LATIAS) || 
#      isConst?(opponent.species,PBSpecies,:LATIOS)) && $fefieldeffect == 24
#      if gl1 > gl2   
#        defmult=(defmult*1.5).round
#      end
#    end   
    if opponent.hasWorkingAbility(:FLAREBOOST) && 
      opponent.status==PBStatuses::BURN && $fefieldeffect == 24
      if gl1 > gl2   
        defmult=(defmult*1.5).round
      end
    end  
    if opponent.hasWorkingAbility(:MINUS) && 
    opponent.pbPartner.hasWorkingAbility(:PLUS) && $fefieldeffect == 24
      if gl1 > gl2   
        defmult=(defmult*1.5).round
      end
    end      
    if opponent.hasWorkingAbility(:PLUS) && 
      opponent.pbPartner.hasWorkingAbility(:MINUS) && $fefieldeffect == 24 
      if gl1 > gl2   
        defmult=(defmult*1.5).round
      end
    end      
    if opponent.pbPartner.hasWorkingAbility(:BATTERY) && 
      $fefieldeffect == 24
      if gl1 > gl2   
        defmult=(defmult*1.3).round
      end
    end        
    if opponent.hasWorkingItem(:WISEGLASSES) &&
      $fefieldeffect == 24
      if gl1 > gl2   
        defmult=(atkmult*1.1).round
      end
    end
    if ((opponent.hasWorkingAbility(:SOLARPOWER) || 
       (isConst?(opponent.species,PBSpecies,:CASTFORM) && isConst?(opponent.item,PBItems,:CASTCREST) && opponent.form==1)) && 
       (@battle.pbWeather==PBWeather::SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA)) && $fefieldeffect == 24)
      if gl1 > gl2   
        defmult=(defmult*1.5).round
      end
    end    
    if !@battle.pbOwnedByPlayer?(attacker.index) && pbIsPhysical?(type) &&
         isConst?(attacker.species,PBSpecies,:AEGISLASH) && attacker.form==0 && $game_variables[200]==2
        defmult=(defmult*1.1).round
    end
    if !@battle.pbOwnedByPlayer?(attacker.index) && pbIsSpecial?(type) &&
        isConst?(attacker.species,PBSpecies,:AEGISLASH) && attacker.form==0 && $game_variables[200]==2
        defmult=(defmult*1.1).round
    end
    if $fefieldeffect == 24 && @function==0xE0
      defmult=(defmult*0.5).round
    end
    if (opponent.hasWorkingAbility(:MARVELSCALE) || @battle.SilvallyCheck(opponent,PBTypes::WATER)) && 
     pbIsPhysical?(type) &&
     (opponent.status>0 || $fefieldeffect == 3 || $fefieldeffect == 9 || @battle.field.effects[PBEffects::Rainbow]>0 || @battle.field.effects[PBEffects::MistyTerrain]>0 
      $fefieldeffect == 31 || $fefieldeffect == 32 || $fefieldeffect == 34) && !(opponent.moldbroken) 
      defmult=(defmult*1.5).round
    end
    if isConst?(opponent.ability,PBAbilities,:GRASSPELT) && pbIsPhysical?(type) &&
     ($fefieldeffect == 2 || $fefieldeffect == 15 || ($fefieldeffect == 33 && $fecounter>1) || @battle.field.effects[PBEffects::GrassyTerrain]>0) # Grassy Field
      defmult=(defmult*1.5).round
    end
#### AME - 005 - START
    if opponent.hasWorkingAbility(:FLUFFY) && !(opponent.moldbroken) 
      if isContactMove? && !attacker.hasWorkingAbility(:LONGREACH)
        defmult=(defmult*2).round
      end      
      if isConst?(type,PBTypes,:FIRE)
        defmult=(defmult*0.5).round
      end      
    end
    if opponent.hasWorkingAbility(:FURCOAT) && pbIsPhysical?(type) && !(opponent.moldbroken)
      defmult=(defmult*2).round
    end
    if opponent.hasWorkingAbility(:STALWART) && pbIsPhysical?(type) && !(opponent.moldbroken)
      if ((PBStuff::SYNTHETICFIELDS).include?($fefieldeffect))
        defmult=(defmult*2).round
      end
    end
    if opponent.hasWorkingAbility(:PUNKROCK) && isSoundBased?
      defmult=(defmult*2).round
    end
    if $fefieldeffect == 3 && pbIsSpecial?(type) &&
     opponent.pbHasType?(:FAIRY)
      defmult=(defmult*1.5).round
    end
    if $fefieldeffect == 12 && pbIsSpecial?(type) &&
     opponent.pbHasType?(:GROUND)
      defmult=(defmult*1.5).round
    end
    if $fefieldeffect == 22 && pbIsPhysical?(type) &&
     !isConst?(type,PBTypes,:WATER) && !attacker.pbHasType?(:WATER) &&
     !attacker.hasWorkingAbility(:SWIFTSWIM) && !attacker.hasWorkingAbility(:STEELWORKER)
      defmult=(defmult*2).round
    end
    if $fefieldeffect == 32 && pbIsSpecial?(type) && opponent.pbHasType?(:DRAGON)
      defmult=(defmult*1.5).round
    end
#### AME - 005 - END
    if ((@battle.pbWeather==PBWeather::SUNNYDAY  && !opponent.hasWorkingItem(:UTILITYUMBRELLA)) || $fefieldeffect == 33 || $fefieldeffect == 42 || 
     (opponent.hasWorkingItem(:CHERCREST) && isConst?(opponent.species,PBSpecies,:CHERRIM)) || 
     (opponent.pbPartner.hasWorkingItem(:CHERCREST) && isConst?(opponent.pbPartner.species,PBSpecies,:CHERRIM)) ) && 
     !(opponent.moldbroken) && pbIsSpecial?(type)
      if opponent.hasWorkingAbility(:FLOWERGIFT) &&
         isConst?(opponent.species,PBSpecies,:CHERRIM)
        defmult=(defmult*1.5).round
      end
      if opponent.pbPartner.hasWorkingAbility(:FLOWERGIFT)  &&
         isConst?(opponent.pbPartner.species,PBSpecies,:CHERRIM)
        defmult=(defmult*1.5).round
      end
    end
    if opponent.hasWorkingItem(:EVIOLITE)
      evos=pbGetEvolvedFormData(opponent.species)
      if evos && evos.length>0
        defmult=(defmult*1.5).round
      end
    end
    if opponent.hasWorkingItem(:ASSAULTVEST) && pbIsSpecial?(type)
      defmult=(defmult*1.5).round
    end
    if opponent.hasWorkingItem(:DEEPSEASCALE) &&
       isConst?(opponent.species,PBSpecies,:CLAMPERL) && pbIsSpecial?(type)
      defmult=(defmult*2.0).round
    end
    if opponent.hasWorkingItem(:METALPOWDER) &&
       isConst?(opponent.species,PBSpecies,:DITTO) &&
       !opponent.effects[PBEffects::Transform] && pbIsPhysical?(type)
      defmult=(defmult*2.0).round
    end
    if (opponent.hasWorkingAbility(:PRISMARMOR) || 
      opponent.hasWorkingAbility(:SHADOWSHIELD)) && $fefieldeffect==4
      defmult=(defmult*2.0).round
    end    
    if opponent.hasWorkingAbility(:PRISMARMOR) && ($fefieldeffect==9 || $fefieldeffect==25 || @battle.field.effects[PBEffects::Rainbow]>0)
      defmult=(defmult*2.0).round
    end   
    if opponent.hasWorkingAbility(:SHADOWSHIELD) && ($fefieldeffect==34 || $fefieldeffect==35 || $fefieldeffect==38)
      defmult=(defmult*2.0).round
    end        
#    if opponent.hasWorkingItem(:SOULDEW) &&
#       (isConst?(opponent.species,PBSpecies,:LATIAS) ||
#       isConst?(opponent.species,PBSpecies,:LATIOS)) && pbIsSpecial?(type) &&
#       !@battle.rules["souldewclause"]
#      defmult=(defmult*1.5).round
#    end
    defense=(defense*defmult*1.0/0x1000).round
    ##### Main damage calculation #####
    damage=(((2.0*attacker.level/5+2).floor*basedmg*atk/defense).floor/50).floor+2
    # Multi-targeting attacks
    if pbTargetsAll?(attacker)
      damage=(damage*0.75).round
    end
    # Custom Overlay Terrains
    if isConst?(type,PBTypes,:ELECTRIC) && @battle.field.effects[PBEffects::ElectricTerrain]>0 && $fefieldeffect!=1 && $fefieldeffect!=18
      isgrounded=pbTypeModifier(PBTypes::GROUND,opponent,attacker)
      isgrounded = 4 if (isgrounded==0 && attacker.effects[PBEffects::Roost])          
      isgrounded = 0 if attacker.effects[PBEffects::MagnetRise]>0       
      isgrounded = 0 if attacker.hasWorkingAbility(:LEVITATE) || attacker.hasWorkingAbility(:SOLARIDOL) || attacker.hasWorkingAbility(:LUNARIDOL)
      isgrounded = 0 if attacker.hasWorkingItem(:AIRBALLOON)
      if isgrounded != 0 || $fefieldeffect==17 || $fefieldeffect==21 || $fefieldeffect==26
        damage=(damage*1.5).floor
        @battle.pbDisplay(_INTL("The Electric Terrain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0 && $fefieldeffect!=17 && $fefieldeffect!=18 && $fefieldeffect!=21 && $fefieldeffect!=26
        $feshutup2+=1 if $fefieldeffect!=18 && $fefieldeffect!=18 && $fefieldeffect!=21 && $fefieldeffect!=26
      elsif $fefieldeffect==22
        damage=(damage*2).floor
      end  
    end  
    if isConst?(type,PBTypes,:GRASS) && @battle.field.effects[PBEffects::GrassyTerrain]>0 && $fefieldeffect!=2
      isgrounded=pbTypeModifier(PBTypes::GROUND,opponent,attacker)
      isgrounded = 4 if (isgrounded==0 && attacker.effects[PBEffects::Roost])          
      isgrounded = 0 if attacker.effects[PBEffects::MagnetRise]>0       
      isgrounded = 0 if attacker.hasWorkingAbility(:LEVITATE) || attacker.hasWorkingAbility(:SOLARIDOL) || attacker.hasWorkingAbility(:LUNARIDOL)
      isgrounded = 0 if attacker.hasWorkingItem(:AIRBALLOON)
      if isgrounded != 0 || $fefieldeffect==15 ||  $fefieldeffect==42  
        damage=(damage*1.5).floor 
        @battle.pbDisplay(_INTL("The Grassy Terrain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0 && $fefieldeffect!=15 && $fefieldeffect!=42
        $feshutup2+=1  if $fefieldeffect!=15 && $fefieldeffect!=42
      elsif $fefieldeffect==33
        case $fecounter
          when 1
            damage=(damage*1.5).floor
          when 2
            damage=(damage*1.5).floor            
          when 3
            damage=(damage*2).floor            
          when 4
            damage=(damage*3).floor
        end          
      end  
    end      
    if isConst?(type,PBTypes,:FAIRY) && @battle.field.effects[PBEffects::MistyTerrain]>0 && ($fefieldeffect!=3)
      damage=(damage*1.3).floor
      @battle.pbDisplay(_INTL("The Misty Terrain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0 && !($fefieldeffect==42 || $fefieldeffect==34 ||  $fefieldeffect==29 && $fefieldeffect==31)
      $feshutup2+=1
    end        
    if isConst?(type,PBTypes,:PSYCHIC) && (@battle.field.effects[PBEffects::PsychicTerrain]>0 && $fefieldeffect!=37)
      isgrounded=pbTypeModifier(PBTypes::GROUND,opponent,attacker)
      isgrounded = 4 if (isgrounded==0 && attacker.effects[PBEffects::Roost])          
      isgrounded = 0 if attacker.effects[PBEffects::MagnetRise]>0     
      isgrounded = 0 if attacker.hasWorkingAbility(:LEVITATE) || attacker.hasWorkingAbility(:SOLARIDOL) || attacker.hasWorkingAbility(:LUNARIDOL)
      isgrounded = 0 if attacker.hasWorkingItem(:AIRBALLOON)
      if (isgrounded != 0  || $fefieldeffect==24 || $fefieldeffect==29 || $fefieldeffect==34)
        damage=(damage*1.5).floor 
        @battle.pbDisplay(_INTL("The Psychic Terrain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0 && $fefieldeffect!=24 && $fefieldeffect!=29 && $fefieldeffect!=34
        $feshutup2+=1  if $fefieldeffect!=24 && $fefieldeffect!=29 && $fefieldeffect!=34
      end
    end    
    if isConst?(type,PBTypes,:NORMAL) && !pbIsPhysical?(pbType(@type,attacker,opponent)) && @battle.field.effects[PBEffects::Rainbow]>0 && $fefieldeffect!=9 && $fefieldeffect!=29
      damage=(damage*1.5).floor
      @battle.pbDisplay(_INTL("The rainbow energized the attack!",opponent.pbThis)) if $feshutup2 == 0
      $feshutup2+=1
    end
    # Field Effects
    case $fefieldeffect
      when 1 # Electric Field
        if isConst?(type,PBTypes,:ELECTRIC)
          isgrounded=pbTypeModifier(PBTypes::GROUND,opponent,attacker)
          if isgrounded != 0
            damage=(damage*1.5).floor if @battle.field.effects[PBEffects::ElectricTerrain]==0
            @battle.pbDisplay(_INTL("The Electric Terrain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
            $feshutup2+=1
          end
        end
      when 2 # Grassy Field
        if isConst?(type,PBTypes,:GRASS)
        isgrounded=pbTypeModifier(PBTypes::GROUND,opponent,attacker)
          if isgrounded != 0
            damage=(damage*1.5).floor if @battle.field.effects[PBEffects::GrassyTerrain]==0
            @battle.pbDisplay(_INTL("The Grassy Terrain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
            $feshutup2+=1
          end
        end
        if isConst?(type,PBTypes,:FIRE)
          isgrounded=pbTypeModifier(PBTypes::GROUND,attacker,opponent)
          if isgrounded != 0
            damage=(damage*1.5).floor
            @battle.pbDisplay(_INTL("The grass below caught flame!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
          end
        end
      when 3 # Misty Field
        if isConst?(type,PBTypes,:DRAGON)
          damage=(damage*0.5).floor
            @battle.pbDisplay(_INTL("The Misty Terrain weakened the attack!",opponent.pbThis)) if $feshutup2 == 0
            $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FAIRY)
          damage=(damage*1.5).floor if @battle.field.effects[PBEffects::MistyTerrain]==0
            @battle.pbDisplay(_INTL("The Misty Terrain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
            $feshutup2+=1
        end
      when 7 # Burning Field
        if isConst?(type,PBTypes,:FIRE)
          isgrounded=pbTypeModifier(PBTypes::GROUND,opponent,attacker)
          if isgrounded != 0
            damage=(damage*1.5).floor
            @battle.pbDisplay(_INTL("The blaze amplified the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
          end
        end
        if isConst?(type,PBTypes,:GRASS)
         isgrounded=pbTypeModifier(PBTypes::GROUND,attacker,opponent)
          if isgrounded != 0
            damage=(damage*0.5).floor
            @battle.pbDisplay(_INTL("The blaze softened the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
          end
        end
        if isConst?(type,PBTypes,:ICE)
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The blaze softened the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 8 # Swamp Field
        if isConst?(type,PBTypes,:POISON)
          isgrounded=pbTypeModifier(PBTypes::GROUND,attacker,opponent)
          if isgrounded != 0
            damage=(damage*1.5).floor
            @battle.pbDisplay(_INTL("The poison infected the nearby murk!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
          end
        end
      when 9 # Rainbow Field
        if isConst?(type,PBTypes,:NORMAL) &&
         !pbIsPhysical?(pbType(@type,attacker,opponent))
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The rainbow energized the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 11 # Corrosive Field
        if isConst?(type,PBTypes,:FIRE)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The toxic mist caught flame!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 12 # DESERT Field
        if isConst?(type,PBTypes,:WATER) && id!=PBMoves::SCALD && id!=PBMoves::STEAMERUPTION
          isgrounded=pbTypeModifier(PBTypes::GROUND,opponent,attacker)
          if isgrounded != 0
            damage=(damage*0.5).floor
            @battle.pbDisplay(_INTL("The desert softened the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
          end
        end
        if isConst?(type,PBTypes,:ELECTRIC)
          isgrounded=pbTypeModifier(PBTypes::GROUND,attacker,opponent)
          if isgrounded != 0
            damage=(damage*0.5).floor
            @battle.pbDisplay(_INTL("The desert softened the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
          end
        end
      when 13 # Icy Field
        if isConst?(type,PBTypes,:FIRE)
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The cold softened the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:ICE)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The cold strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 14 # Rocky Field
        if isConst?(type,PBTypes,:ROCK)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The field strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 15 # Forest Field
        if isConst?(type,PBTypes,:GRASS)
          damage=(damage*1.5).floor if @battle.field.effects[PBEffects::GrassyTerrain]==0
          @battle.pbDisplay(_INTL("The forestry strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:BUG) &&
         !pbIsPhysical?(pbType(@type,attacker,opponent))
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The attack spreads through the forest!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 16 # Volcanic Top
        if isConst?(type,PBTypes,:FIRE)
          damage=(damage*1.2).floor
          @battle.pbDisplay(_INTL("The attack was super-heated!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:ICE)
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The extreme heat softened the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:WATER) && !(id == PBMoves::STEAMERUPTION)
          if !pbIsPhysical?(pbType(@type,attacker,opponent))
            damage=(damage*0.5).floor
          else
            damage=(damage*0.9).floor
          end
          @battle.pbDisplay(_INTL("The extreme heat softened the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 17 # Factory Field
        if isConst?(type,PBTypes,:ELECTRIC)
          damage=(damage*1.2).floor if @battle.field.effects[PBEffects::ElectricTerrain]==0
          @battle.pbDisplay(_INTL("The attack took energy from the field!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 21 # Water Surface
        if isConst?(type,PBTypes,:WATER)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The water strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:ELECTRIC)
          damage=(damage*1.5).floor if @battle.field.effects[PBEffects::ElectricTerrain]==0
          @battle.pbDisplay(_INTL("The water conducted the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FIRE)
          isgrounded=pbTypeModifier(PBTypes::GROUND,attacker,opponent)
          if isgrounded != 0
            damage=(damage*0.5).floor
            @battle.pbDisplay(_INTL("The water deluged the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
          end
        end
      when 22 # Underwater
        if isConst?(type,PBTypes,:WATER)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The water strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:ELECTRIC)
          damage=(damage*2).floor if @battle.field.effects[PBEffects::ElectricTerrain]==0
          @battle.pbDisplay(_INTL("The water super-conducted the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 23 # Cave
        if isConst?(type,PBTypes,:FLYING) && (@flags&0x01)==0 #not a contact move
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The cave choked out the air!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:ROCK)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The cavern strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 24 # Glitch
        if isConst?(type,PBTypes,:PSYCHIC)
          damage=(damage*1.2).floor if @battle.field.effects[PBEffects::PsychicTerrain]==0
          @battle.pbDisplay(_INTL(".0P pl$ nerf!-//",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 25 # Crystal Cavern
        if isConst?(type,PBTypes,:ROCK)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The crystals charged the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:DRAGON)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The crystal energy strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 26 # Murkwater Surface
        if isConst?(type,PBTypes,:WATER) || isConst?(type,PBTypes,:POISON)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The toxic water strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:ELECTRIC)
          damage=(damage*1.5).floor  if @battle.field.effects[PBEffects::ElectricTerrain]==0
          @battle.pbDisplay(_INTL("The toxic water conducted the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 27 # Mountain
        if isConst?(type,PBTypes,:ROCK)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The mountain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FLYING)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The open air strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FLYING) &&
         !pbIsPhysical?(pbType(@type,attacker,opponent)) && 
         @battle.pbWeather==PBWeather::STRONGWINDS
          damage=(damage*1.5).floor
        end
      when 28 # Snowy Mountain
        if isConst?(type,PBTypes,:ROCK) || isConst?(type,PBTypes,:ICE)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The snowy mountain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FLYING)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The open air strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FLYING) &&
         !pbIsPhysical?(pbType(@type,attacker,opponent)) && 
         @battle.pbWeather==PBWeather::STRONGWINDS
          damage=(damage*1.5).floor
        end
        if isConst?(type,PBTypes,:FIRE)
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The cold softened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 29 # Holy Field
        if (isConst?(type,PBTypes,:GHOST) || (isConst?(type,PBTypes,:DARK)) &&
         !pbIsPhysical?(pbType(@type,attacker,opponent)))
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The attack was cleansed...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if (isConst?(type,PBTypes,:FAIRY) ||(isConst?(type,PBTypes,:NORMAL)) &&
         !pbIsPhysical?(pbType(@type,attacker,opponent)))
          damage=(damage*1.5).floor if isConst?(type,PBTypes,:FAIRY) && @battle.field.effects[PBEffects::MistyTerrain]==0
          damage=(damage*1.5).floor if isConst?(type,PBTypes,:NORMAL)
          @battle.pbDisplay(_INTL("The holy energy resonated with the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:PSYCHIC) || isConst?(type,PBTypes,:DRAGON)
          damage=(damage*1.2).floor if isConst?(type,PBTypes,:PSYCHIC) && @battle.field.effects[PBEffects::PsychicTerrain]==0
          damage=(damage*1.2).floor if isConst?(type,PBTypes,:DRAGON)
          @battle.pbDisplay(_INTL("The legendary energy resonated with the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 31# Fairy Tale
        if isConst?(type,PBTypes,:STEEL)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("For justice!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FAIRY)
          damage=(damage*1.5).floor if @battle.field.effects[PBEffects::MistyTerrain]==0
          @battle.pbDisplay(_INTL("For ever after!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:DRAGON)
          damage=(damage*2).floor
          @battle.pbDisplay(_INTL("The foul beast's attack gained strength!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 32 # Dragon's Den
        if isConst?(type,PBTypes,:ROCK)
          damage=(damage*1.3).floor
          @battle.pbDisplay(_INTL("The caverns boosted the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FIRE)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The lava's heat boosted the flame!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
         if isConst?(type,PBTypes,:ICE) || isConst?(type,PBTypes,:WATER)
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The lava's heat softened the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:DRAGON)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The draconic energy boosted the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 33 # Flower Field
        if isConst?(type,PBTypes,:GRASS)
          case $fecounter
            when 1
              damage=(damage*1.2).floor  if @battle.field.effects[PBEffects::GrassyTerrain]==0
              @battle.pbDisplay(_INTL("The garden's power boosted the attack!",opponent.pbThis)) if $feshutup2 == 0
              $feshutup2+=1
            when 2
              damage=(damage*1.5).floor  if @battle.field.effects[PBEffects::GrassyTerrain]==0
              @battle.pbDisplay(_INTL("The budding flowers boosted the attack!",opponent.pbThis)) if $feshutup2 == 0
              $feshutup2+=1              
            when 3
              damage=(damage*2).floor  if @battle.field.effects[PBEffects::GrassyTerrain]==0
              @battle.pbDisplay(_INTL("The blooming flowers boosted the attack!",opponent.pbThis)) if $feshutup2 == 0
              $feshutup2+=1              
            when 4
              damage=(damage*3).floor  if @battle.field.effects[PBEffects::GrassyTerrain]==0
              @battle.pbDisplay(_INTL("The thriving flowers boosted the attack!",opponent.pbThis)) if $feshutup2 == 0
              $feshutup2+=1
          end
        end
        if $fecounter > 1
          if isConst?(type,PBTypes,:FIRE)
            damage=(damage*1.5).floor
            @battle.pbDisplay(_INTL("The nearby flowers caught flame!",opponent.pbThis)) if $feshutup2 == 0
            $feshutup2+=1
          end
        end
        if $fecounter > 3
          if isConst?(type,PBTypes,:BUG)
            damage=(damage*2).floor
            @battle.pbDisplay(_INTL("The attack infested the flowers!",opponent.pbThis)) if $feshutup2 == 0
            $feshutup2+=1
          end
        elsif $fecounter > 1
          if isConst?(type,PBTypes,:BUG)
            damage=(damage*1.5).floor
            @battle.pbDisplay(_INTL("The attack infested the garden!",opponent.pbThis)) if $feshutup2 == 0
            $feshutup2+=1
          end
        end
      when 34 # Starlight Arena
        if isConst?(type,PBTypes,:DARK)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The night sky boosted the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:PSYCHIC)
          damage=(damage*1.5).floor if @battle.field.effects[PBEffects::PsychicTerrain]==0
          @battle.pbDisplay(_INTL("The astral energy boosted the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FAIRY) 
          damage=(damage*1.3).floor if @battle.field.effects[PBEffects::MistyTerrain]==0
          @battle.pbDisplay(_INTL("Starlight supercharged the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 35 # New World
        if isConst?(type,PBTypes,:DARK)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("Infinity boosted the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 37 # Psychic Terrain
        if isConst?(type,PBTypes,:PSYCHIC)
          isgrounded=pbTypeModifier(PBTypes::GROUND,opponent,attacker)
          if isgrounded != 0
            damage=(damage*1.5).floor
            @battle.pbDisplay(_INTL("The psychic terrain strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
            $feshutup2+=1
          end
        end
      when 38 # Dimensional
        if isConst?(type,PBTypes,:FAIRY)
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The evil aura depleted the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:GHOST)
          damage=(damage*1.2).floor
          @battle.pbDisplay(_INTL("The evil aura powered up the attack...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:DARK) 
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The darkness is here...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:SHADOW)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The shadow is strengthened...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 39 # Angie
        if isConst?(type,PBTypes,:FIRE)
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The fire withered away...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:ICE)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The dimension mutated the ice!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:DARK)
          damage=(damage*1.2).floor
          @battle.pbDisplay(_INTL("The darkness is here...",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 40 # Haunted
        if isConst?(type,PBTypes,:GHOST)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The evil aura powered up the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 41 # Corrupted Cave
        if isConst?(type,PBTypes,:POISON)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The chemicals strengthened the attack.",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:ROCK) || isConst?(type,PBTypes,:GRASS)
          damage=(damage*1.2).floor
          @battle.pbDisplay(_INTL("The corruption morphed the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
       if isConst?(type,PBTypes,:FAIRY)
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The corruption weakened the attack.",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:FLYING) && (@flags&0x01)==0 #not a contact move
          damage=(damage*0.5).floor
          @battle.pbDisplay(_INTL("The cave choked out the air!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 42 # Darchlight
        if isConst?(type,PBTypes,:FAIRY)
          damage=(damage*1.5).floor if @battle.field.effects[PBEffects::MistyTerrain]==0
          @battle.pbDisplay(_INTL("The fairy aura amplified the attack's power!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:GRASS)
          damage=(damage*1.5).floor if @battle.field.effects[PBEffects::GrassyTerrain]==0
          @battle.pbDisplay(_INTL("Flourish!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
        if isConst?(type,PBTypes,:DARK)
          damage=(damage*1.3).floor
          @battle.pbDisplay(_INTL("The dark aura amplified the attack's power!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 43 # Sky Field
        if isConst?(type,PBTypes,:FLYING)
          damage=(damage*1.5).floor
          @battle.pbDisplay(_INTL("The open air strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0
          $feshutup2+=1
        end
      when 44 # Colosseum Field  
        if isConst?(type,PBTypes,:FLYING)  
          damage=(damage*0.5).floor  
          @battle.pbDisplay(_INTL("The colosseum choked out the air!",opponent.pbThis)) if $feshutup2 == 0  
          $feshutup2+=1  
        end  
      when 45 # Infernal Field  
        if isConst?(type,PBTypes,:FIRE) || isConst?(type,PBTypes,:DARK)  
          damage=(damage*1.5).floor  
          @battle.pbDisplay(_INTL("The infernal flames strengthened the attack!",opponent.pbThis)) if $feshutup2 == 0  
          $feshutup2+=1  
        end  
        if isConst?(type,PBTypes,:FAIRY) || isConst?(type,PBTypes,:WATER)  
          if (id != PBMoves::SPIRITBREAK)  
            damage=(damage*0.5).floor  
            @battle.pbDisplay(_INTL("The hellfire burnt out the attack!",opponent.pbThis)) if $feshutup2 == 0  
            $feshutup2+=1  
          end  
        end
    end
    # FIELD TRANSFORMATIONS
    case $fefieldeffect
      when 2 # Grassy Field
        if (id == PBMoves::SLUDGEWAVE || id == PBMoves::ACIDDOWNPOUR)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 3 # Misty Field
        if (id == PBMoves::WHIRLWIND || id == PBMoves::GUST ||
         id == PBMoves::RAZORWIND || id == PBMoves::HURRICANE||
         id == PBMoves::DEFOG || id == PBMoves::TAILWIND ||
         id == PBMoves::TWISTER || id == PBMoves::SUPERSONICSKYSTRIKE)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::CLEARSMOG || id == PBMoves::SMOG || id == PBMoves::ACIDDOWNPOUR)
          damage=(damage*1.5).floor if damage >= 0
        end
      when 4 # Dark Crystal Cavern
        if (id == PBMoves::EARTHQUAKE || id == PBMoves::BULLDOZE ||
         id == PBMoves::MAGNITUDE || id == PBMoves::TECTONICRAGE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 7 # Burning Field
        if (id == PBMoves::WHIRLWIND || id == PBMoves::GUST ||
         id == PBMoves::RAZORWIND || id == PBMoves::DEFOG ||
         id == PBMoves::TAILWIND || id == PBMoves::HURRICANE)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::SURF || id == PBMoves::MUDDYWATER ||
         id == PBMoves::WATERSPORT || id == PBMoves::WATERSPOUT ||
         id == PBMoves::WATERPLEDGE || id == PBMoves::SPARKLINGARIA || id == PBMoves::OCEANICOPERETTA ||
         id == PBMoves::BLIZZARD || id == PBMoves::HYDROVORTEX)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::SANDTOMB || id == PBMoves::CONTINENTALCRUSH)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 10 # Corrosive Field
        if (id == PBMoves::SEEDFLARE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 11 # Corrosive Mist Field
        if (id == PBMoves::HEATWAVE || id == PBMoves::ERUPTION ||
         id == PBMoves::SEARINGSHOT || id == PBMoves::FLAMEBURST ||
         id == PBMoves::LAVAPLUME || id == PBMoves::FIREPLEDGE ||
         id == PBMoves::EXPLOSION || id == PBMoves::SELFDESTRUCT ||
         id == PBMoves::TWISTER  || id == PBMoves::INFERNOOVERDRIVE)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::GUST || id == PBMoves::HURRICANE ||
         id == PBMoves::RAZORWIND || id == PBMoves::SUPERSONICSKYSTRIKE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 13 # Icy Field
        if (id == PBMoves::HEATWAVE || id == PBMoves::ERUPTION ||
         id == PBMoves::SEARINGSHOT || id == PBMoves::FLAMEBURST ||
         id == PBMoves::LAVAPLUME || id == PBMoves::FIREPLEDGE ||
         id == PBMoves::LAVASURF || id == PBMoves::INFERNOOVERDRIVE)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::EARTHQUAKE || id == PBMoves::MAGNITUDE ||
         id == PBMoves::BULLDOZE || id == PBMoves::TECTONICRAGE || id == PBMoves::DIVE)
         damage=(damage*1.3).floor if damage >= 0
         end
      when 16 # Volcanic Top Field
        if (id == PBMoves::FLY || id == PBMoves::BOUNCE ||
         id == PBMoves::HEAVENLYWING || id == PBMoves::BLIZZARD ||
         id == PBMoves::GLACIATE || id == PBMoves::SUBZEROSLAMMER)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 17 # Factory Field
        if (id == PBMoves::DISCHARGE || id == PBMoves::GIGAVOLTHAVOC || id == PBMoves::CORKSCREWCRASH ||
          id == PBMoves::OVERDRIVE || id == PBMoves::AURAWHEEL)
          $fefieldeffect = 18
          $febackup = 18
          damage=(damage*1.3).floor if damage >= 0
          @battle.pbChangeBGSprite
          @battle.seedCheck
        end
        if (id == PBMoves::EXPLOSION || id == PBMoves::SELFDESTRUCT ||
         id == PBMoves::MAGNITUDE || id == PBMoves::EARTHQUAKE ||
         id == PBMoves::BULLDOZE || id == PBMoves::TECTONICRAGE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 18 # Shortcircuit Field
        if (id == PBMoves::DISCHARGE || id == PBMoves::GIGAVOLTHAVOC  || id == PBMoves::IONDELUGE  || 
          id == PBMoves::OVERDRIVE || id == PBMoves::AURAWHEEL)
          $fefieldeffect = 17
          $febackup = 17
          damage=(damage*1.3).floor if damage >= 0
          @battle.pbChangeBGSprite
          @battle.seedCheck
        end
        if (id == PBMoves::PARABOLICCHARGE ||
         id == PBMoves::WILDCHARGE || id == PBMoves::CHARGEBEAM)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 21 # Water Surface
        if (id == PBMoves::DIVE || id == PBMoves::ANCHORSHOT)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::BLIZZARD || id == PBMoves::GLACIATE || id == PBMoves::SUBZEROSLAMMER)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::SLUDGEWAVE || id == PBMoves::ACIDDOWNPOUR)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 22 # Underwater
        if (id == PBMoves::DIVE || id == PBMoves::SKYDROP ||
            id == PBMoves::FLY || id == PBMoves::BOUNCE || 
            id == PBMoves::SUPERSONICSKYSTRIKE)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::SLUDGEWAVE || id == PBMoves::ACIDDOWNPOUR)
          damage=(damage*2).floor if damage >= 0
        end
      when 23 # Cave Field
        if (id == PBMoves::POWERGEM || id == PBMoves::DIAMONDSTORM)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::HOTTEMPO || id == PBMoves::LAVASURF ||
         id == PBMoves::LAVAPLUME || id == PBMoves::ERUPTION ||
         id == PBMoves::HEATWAVE || id == PBMoves::INFERNO ||
         id == PBMoves::OVERHEAT || id == PBMoves::FIRELASH ||
         id == PBMoves::FUSIONFLARE || id == PBMoves::INFERNOOVERDRIVE)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::DRACOMETEOR || id == PBMoves::DEVASTATINGDRAKE)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::SLUDGEWAVE || id == PBMoves::BLIZZARD ||
          id == PBMoves::SUBZEROSLAMMER || id == PBMoves::ACIDDOWNPOUR)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 25 # Crystal Cavern
        if (id == PBMoves::DARKPULSE || id == PBMoves::NIGHTDAZE ||
         id == PBMoves::BULLDOZE|| id == PBMoves::EARTHQUAKE ||
            id == PBMoves::MAGNITUDE || id == PBMoves::TECTONICRAGE ||
            id == PBMoves::BLACKHOLEECLIPSE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 26 # Murkwater Surface
        if (id == PBMoves::BLIZZARD || id == PBMoves::GLACIATE ||
         id == PBMoves::WHIRLPOOL || id == PBMoves::SUBZEROSLAMMER)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 27 # Mountain
        if (id == PBMoves::FLY || id == PBMoves::BOUNCE ||
          id == PBMoves::BLIZZARD || id == PBMoves::HEAVENLYWING)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::LAVAPLUME || id == PBMoves::LAVASURF ||
          id == PBMoves::ERUPTION || id == PBMoves::SUBZEROSLAMMER || id == PBMoves::INFERNOOVERDRIVE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 28 # Snowy Mountain 
        if (id == PBMoves::HEATWAVE || id == PBMoves::FLAMEBURST ||
         id == PBMoves::LAVAPLUME || id == PBMoves::SEARINGSHOT || 
         id == PBMoves::FIREPLEDGE || id == PBMoves::FLY ||
         id == PBMoves::HEAVENLYWING || id == PBMoves::BOUNCE)
          damage=(damage*1.3).floor if damage >= 0
        end
        if (id == PBMoves::ERUPTION || id == PBMoves::LAVASURF ||
          id == PBMoves::INFERNOOVERDRIVE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 30 # Mirror Arena
        if (id == PBMoves::BOOMBURST || id == PBMoves::BULLDOZE ||
         id == PBMoves::HYPERVOICE || id == PBMoves::EARTHQUAKE ||
         id == PBMoves::MAGNITUDE || id == PBMoves::TECTONICRAGE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 32 # Mirror Arena
        if (id == PBMoves::MISTBALL)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 33 # Flower Garden Field
        if $fecounter > 1
          if (id == PBMoves::HEATWAVE || id == PBMoves::ERUPTION ||
           id == PBMoves::SEARINGSHOT || id == PBMoves::FLAMEBURST ||
              id == PBMoves::LAVAPLUME || id == PBMoves::FIREPLEDGE ||
              id == PBMoves::INFERNOOVERDRIVE) &&
           @battle.field.effects[PBEffects::WaterSport] <= 0 &&
           @battle.pbWeather != PBWeather::RAINDANCE
            damage=(damage*1.3).floor if damage >= 0
          end
        end
      when 38 # Dimensional
        if id == PBMoves::BLIZZARD || id == PBMoves::COLDTRUTH ||
          id == PBMoves::ICEBURN || id == PBMoves::FREEZESHOCK || 
          id == PBMoves::GLACIATE || id == PBMoves::SHEERCOLD
          damage=(damage*1.3).floor if damage >= 0
        end
      when 39 # Angie
        if (id == PBMoves::BLASTBURN || id == PBMoves::INFERNO ||
         id == PBMoves::LAVAPLUME || id == PBMoves::HEATWAVE ||
         id == PBMoves::ERUPTION || id == PBMoves::FLAMEBURST ||
         id == PBMoves::BURNUP || id == PBMoves::INFERNOOVERDRIVE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 40 # Haunted Field
        if (id == PBMoves::JUDGMENT || id == PBMoves::ORIGINPULSE ||
          id == PBMoves::SACREDFIRE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 41 # Corrupted Cave
        if (id == PBMoves::SEEDFLARE || id == PBMoves::SOLARBEAM ||
         id == PBMoves::SOLARBLADE || id == PBMoves::HEATWAVE ||
         id == PBMoves::BLASTBURN || id == PBMoves::ERUPTION ||
         id == PBMoves::LAVAPLUME || id == PBMoves::INFERNOOVERDRIVE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 43 # Sky Field
        if (id == PBMoves::SMACKDOWN || id == PBMoves::THOUSANDARROWS ||
         id == PBMoves::GRAVAPPLE)
          damage=(damage*1.3).floor if damage >= 0
        end
      when 45 # Infernal  
        if (id == PBMoves::JUDGMENT || id == PBMoves::ORIGINPULSE ||  
         id == PBMoves::GLACIATE)  
          damage=(damage*1.3).floor if damage >= 0  
        end
    end
    #End Field Transformations
    # Weather
    case @battle.pbWeather
      when PBWeather::SUNNYDAY
##### KUROTSUNE - 001 - START
        if @battle.field.effects[PBEffects::HarshSunlight] &&
           isConst?(type,PBTypes,:WATER)
          @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
          return 0
        end
##### KUROTSUNE - 001 - END
        if isConst?(type,PBTypes,:FIRE) && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
          damage=(damage*1.5).round
        elsif isConst?(type,PBTypes,:WATER) && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
          damage=(damage*0.5).round
        end
      when PBWeather::RAINDANCE
##### KUROTSUNE - 001 - START
        if @battle.field.effects[PBEffects::HeavyRain] &&
        isConst?(type,PBTypes,:FIRE)
          @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
          return 0
        end
##### KUROTSUNE - 001 - END
        if isConst?(type,PBTypes,:FIRE) && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
          damage=(damage*0.5).round
        elsif isConst?(type,PBTypes,:WATER) && !opponent.hasWorkingItem(:UTILITYUMBRELLA)
          damage=(damage*1.5).round
        end
    end
    if isConst?(attacker.species,PBSpecies,:FEAROW) && attacker.hasWorkingItem(:FEARCREST)
      if attacker.hasWorkingAbility(:SNIPER)
        damage=(damage*1.5).round
      end
    end
    # Critical hits
    if opponent.damagestate.critical
      damage=(damage*1.5).round
      if attacker.hasWorkingAbility(:SNIPER)
        if !(isConst?(attacker.species,PBSpecies,:FEAROW) && attacker.hasWorkingItem(:FEARCREST))
          damage=(damage*1.5).round
        end
      end
#      if $fefieldeffect == 30
#        if $buffs == 1
#          damage=(damage*1.5).round
#          @battle.pbDisplay(_INTL("{1} came into focus with the attack!",attacker.pbThis))
#        elsif $buffs == 2
#          damage=(damage*2).round
#          @battle.pbDisplay(_INTL("{1} came into focus with the attack!",attacker.pbThis))
#        elsif $buffs >= 3
#          damage=(damage*2.5).round
#          @battle.pbDisplay(_INTL("{1} came into focus with the attack!",attacker.pbThis))
#        end
#        attacker.stages[PBStats::EVASION]=0 if attacker.stages[PBStats::EVASION] > 0
#        attacker.stages[PBStats::ACCURACY]=0 if attacker.stages[PBStats::ACCURACY] > 0
#        opponent.stages[PBStats::EVASION]=0 if opponent.stages[PBStats::EVASION] < 0
#        opponent.stages[PBStats::ACCURACY]=0 if opponent.stages[PBStats::ACCURACY] < 0
#      end
    end
    if attacker.hasWorkingAbility(:WATERBUBBLE) && type == PBTypes::WATER
      damage=(damage*=2).round
    end      
    # STAB
    if (attacker.pbHasType?(type) || attacker.isShadow? && (type==attacker.pokemon.type1 || type==attacker.pokemon.type2) || (attacker.hasWorkingAbility(:STEELWORKER) && type==PBTypes::STEEL) ||
      (isConst?(attacker.species,PBSpecies,:EMPOLEON) && attacker.hasWorkingItem(:EMPCREST) && type==PBTypes::ICE) ||
      (isConst?(attacker.species,PBSpecies,:LUXRAY) && attacker.hasWorkingItem(:LUXCREST) && type==PBTypes::DARK) ||
      (isConst?(attacker.species,PBSpecies,:SAMUROTT) && attacker.hasWorkingItem(:SAMUCREST) && type==PBTypes::FIGHTING) ||
      (isConst?(attacker.species,PBSpecies,:NOCTOWL) && attacker.hasWorkingItem(:NOCCREST) && type==PBTypes::PSYCHIC)) && 
      (options&IGNOREPKMNTYPES)==0
      if attacker.hasWorkingAbility(:ADAPTABILITY)
        damage=(damage*2).round
      elsif (attacker.hasWorkingAbility(:STEELWORKER) && type == PBTypes::STEEL) && $fefieldeffect==17 # Factory Field
        damage=(damage*2).round
      else
        damage=(damage*1.5).round
      end
      if isConst?(attacker.species,PBSpecies,:SILVALLY)
        if @battle.pbOwnedByPlayer?(attacker.index) && $PokemonBag.pbHasItem?(:SILVCREST)
          damage=(damage*1.2).round
        end
        if !@battle.pbOwnedByPlayer?(attacker.index) 
          damage=(damage*1.2).round
        end
      end
    end  
    # Type effectiveness
    if (options&IGNOREPKMNTYPES)==0
      typemod=pbTypeModMessages(type,attacker,opponent)
      damage=(damage*typemod/4.0).round
      opponent.damagestate.typemod=typemod
      if typemod==0
        opponent.damagestate.calcdamage=0
        opponent.damagestate.critical=false
        return 0
      end
    else
      opponent.damagestate.typemod=4
    end
    if opponent.hasWorkingAbility(:WATERBUBBLE) && type == PBTypes::FIRE
      damage=(damage*=0.5).round
    end    
    # Burn
    if attacker.status==PBStatuses::BURN && pbIsPhysical?(type) && !attacker.hasWorkingAbility(:GUTS) && !(id==PBMoves::FACADE)
      damage=(damage*0.5).round
    end
    # Random variance
    if (options&NOWEIGHTING)==0
      random=92
      damage=(damage*random/100.0).floor
    end
    # Make sure damage is at least 1
    damage=1 if damage<1
    # Final damage modifiers
    finaldamagemult=0x1000
    if !opponent.damagestate.critical && (options&NOREFLECT)==0 &&
       !attacker.hasWorkingAbility(:INFILTRATOR)
      # Reflect
      if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 && pbIsPhysical?(type) && opponent.pbOwnSide.effects[PBEffects::AuroraVeil]==0
        # TODO: should apply even if partner faints during an attack]
        if !opponent.pbPartner.isFainted?
          finaldamagemult=(finaldamagemult*0.66).round
        else
          finaldamagemult=(finaldamagemult*0.5).round
        end
      end
      # Light Screen
      if opponent.pbOwnSide.effects[PBEffects::LightScreen]>0 && pbIsSpecial?(type) && opponent.pbOwnSide.effects[PBEffects::AuroraVeil]==0
        # TODO: should apply even if partner faints during an attack]
        if !opponent.pbPartner.isFainted?
          finaldamagemult=(finaldamagemult*0.66).round
        else
          finaldamagemult=(finaldamagemult*0.5).round
        end
      end
      # Aurora Veil
      if opponent.pbOwnSide.effects[PBEffects::AuroraVeil]>0
        # TODO: should apply even if partner faints during an attack]
        if !opponent.pbPartner.isFainted?
          finaldamagemult=(finaldamagemult*0.66).round
        else
          finaldamagemult=(finaldamagemult*0.5).round
        end
      end     
    end
    if (( (opponent.hasWorkingAbility(:MULTISCALE) || @battle.SilvallyCheck(opponent,PBTypes::DRAGON)) &&
        !(opponent.moldbroken)) || opponent.hasWorkingAbility(:SHADOWSHIELD)) && opponent.hp==opponent.totalhp 
      finaldamagemult=(finaldamagemult*0.5).round
    end
#### JERICHO - 006 - START    
    if (attacker.hasWorkingAbility(:TINTEDLENS) || @battle.SilvallyCheck(attacker,PBTypes::BUG)) &&
#### JERICHO - 006 - END      
     opponent.damagestate.typemod<4
      finaldamagemult=(finaldamagemult*2.0).round
    end
    if opponent.pbPartner.hasWorkingAbility(:FRIENDGUARD) && !(opponent.moldbroken)
      finaldamagemult=(finaldamagemult*0.75).round
    end
    if $fefieldeffect == 33 && $fecounter >1 
      if ((opponent.pbPartner.hasWorkingAbility(:FLOWERVEIL) || @battle.SilvallyCheck(opponent.pbPartner,PBTypes::GRASS)) &&
       opponent.pbHasType?(:GRASS)) ||
       (opponent.hasWorkingAbility(:FLOWERVEIL) || @battle.SilvallyCheck(opponent,PBTypes::GRASS)) && !(opponent.moldbroken)
        finaldamagemult=(finaldamagemult*0.5).round
        @battle.pbDisplay(_INTL("The Flower Veil softened the attack!"))
      end
      case $fecounter
        when 2
          if opponent.pbHasType?(:GRASS)
            finaldamagemult=(finaldamagemult*0.75).round
          end
        when 3
          if opponent.pbHasType?(:GRASS)
            finaldamagemult=(finaldamagemult*0.67).round
          end
        when 4
          if opponent.pbHasType?(:GRASS)
            finaldamagemult=(finaldamagemult*0.5).round
          end
      end
    end
    if opponent.pbOwnSide.effects[PBEffects::AreniteWall]>0 &&
     opponent.damagestate.typemod>4 
      finaldamagemult=(finaldamagemult*0.5).round
    end
    if (((opponent.hasWorkingAbility(:SOLIDROCK) || @battle.SilvallyCheck(opponent,PBTypes::ROCK) ||
       opponent.hasWorkingAbility(:FILTER)) && 
        !(opponent.moldbroken)) || opponent.hasWorkingAbility(:PRISMARMOR)) && opponent.damagestate.typemod>4 
      finaldamagemult=(finaldamagemult*0.75).round
    end
    if opponent.hasWorkingAbility(:STALWART) && pbIsPhysical?(type) && !(opponent.moldbroken)  && opponent.damagestate.typemod>4 
      if ((PBStuff::SYNTHETICFIELDS).include?($fefieldeffect))
        finaldamagemult=(finaldamagemult*0.5).round
      end
    end
    if attacker.hasWorkingAbility(:STAKEOUT) && @battle.switchedOut[opponent.index]
      finaldamagemult=(finaldamagemult*2.0).round
    end    
    if attacker.hasWorkingItem(:METRONOME)
      if attacker.effects[PBEffects::Metronome]>4
        finaldamagemult=(finaldamagemult*2.0).round
      else
        met=1.0+attacker.effects[PBEffects::Metronome]*0.2
        finaldamagemult=(finaldamagemult*met).round
      end
    end
    if attacker.hasWorkingItem(:EXPERTBELT) && opponent.damagestate.typemod>4
      finaldamagemult=(finaldamagemult*1.2).round
    end
    if (attacker.ability == (PBAbilities::NEUROFORCE)) && (!attacker.abilitynulled && opponent.damagestate.typemod>4)
      finaldamagemult=(finaldamagemult*1.25).round
    end
    if attacker.hasWorkingItem(:LIFEORB)
      finaldamagemult=(finaldamagemult*1.3).round
    end
    if opponent.damagestate.typemod>4 && (options&IGNOREPKMNTYPES)==0 && !(attacker.hasWorkingAbility(:UNNERVE) || attacker.pbPartner.hasWorkingAbility(:UNNERVE))
      if (opponent.hasWorkingItem(:CHOPLEBERRY) && isConst?(type,PBTypes,:FIGHTING)) ||
       (opponent.hasWorkingItem(:COBABERRY) && isConst?(type,PBTypes,:FLYING)) ||
       (opponent.hasWorkingItem(:KEBIABERRY) && isConst?(type,PBTypes,:POISON)) ||
       (opponent.hasWorkingItem(:SHUCABERRY) && isConst?(type,PBTypes,:GROUND)) ||
       (opponent.hasWorkingItem(:CHARTIBERRY) && isConst?(type,PBTypes,:ROCK)) ||
       (opponent.hasWorkingItem(:TANGABERRY) && isConst?(type,PBTypes,:BUG)) ||
       (opponent.hasWorkingItem(:KASIBBERRY) && isConst?(type,PBTypes,:GHOST)) ||
       (opponent.hasWorkingItem(:BABIRIBERRY) && isConst?(type,PBTypes,:STEEL)) ||
       (opponent.hasWorkingItem(:OCCABERRY) && isConst?(type,PBTypes,:FIRE)) ||
       (opponent.hasWorkingItem(:PASSHOBERRY) && isConst?(type,PBTypes,:WATER)) ||
       (opponent.hasWorkingItem(:RINDOBERRY) && isConst?(type,PBTypes,:GRASS)) ||
       (opponent.hasWorkingItem(:WACANBERRY) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (opponent.hasWorkingItem(:PAYAPABERRY) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (opponent.hasWorkingItem(:YACHEBERRY) && isConst?(type,PBTypes,:ICE)) ||
       (opponent.hasWorkingItem(:HABANBERRY) && isConst?(type,PBTypes,:DRAGON)) ||
       (opponent.hasWorkingItem(:COLBURBERRY) && isConst?(type,PBTypes,:DARK)) ||
       (opponent.hasWorkingItem(:ROSELIBERRY) && isConst?(type,PBTypes,:FAIRY))
        if opponent.hasWorkingAbility(:RIPEN)
          finaldamagemult=(finaldamagemult*0.25).round
        else
          finaldamagemult=(finaldamagemult*0.5).round
        end
        opponent.pokemon.itemRecycle=opponent.item
        opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
        opponent.item=0
#### JERICHO - 008 - START      
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("{2}'s {1} weakened the damage from the attack!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
        else
          @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
        end
#### JERICHO - 008 - END  
      end  
    end
    if opponent.hasWorkingItem(:CHILANBERRY) && isConst?(type,PBTypes,:NORMAL) &&
       (options&IGNOREPKMNTYPES)==0
      finaldamagemult=(finaldamagemult*0.5).round
      opponent.pokemon.itemRecycle=opponent.item
      opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
      opponent.item=0
    end
    if (isConst?(opponent.species,PBSpecies,:MEGANIUM) && opponent.hasWorkingItem(:MEGCREST)) || 
     (isConst?(opponent.pbPartner.species,PBSpecies,:MEGANIUM) && opponent.pbPartner.hasWorkingItem(:MEGCREST))
      finaldamagemult=(finaldamagemult*0.8).round
    end
    if (isConst?(attacker.species,PBSpecies,:SEVIPER) && attacker.hasWorkingItem(:SEVCREST))
      multiplier = 0.5*(opponent.pokemon.hp*1.0)/(opponent.pokemon.totalhp*1.0)
      multiplier += 1.0
      finaldamagemult=(finaldamagemult*multiplier).round
    end
    finaldamagemult=pbModifyDamage(finaldamagemult,attacker,opponent)
    damage=(damage*finaldamagemult*1.0/0x1000).round
    opponent.damagestate.calcdamage=damage
    return damage
  end

  def pbReduceHPDamage(damage,attacker,opponent,hitnum=0)
    endure=false
    if (@id == 740 || @id == 741)
      if attacker.effects[PBEffects::LaserFocus] ==0
        damage=pbCalcDamage(attacker,opponent,PokeBattle_Move::NOCRITICAL)
      else
        damage=pbCalcDamage(attacker,opponent)
      end
    end
    if (@id == 754)
      damage=pbCalcDamage(attacker,opponent,PokeBattle_Move::NOCRITICAL)
      if (opponent.status>0 || (opponent.hasWorkingAbility(:COMATOSE) && $fefieldeffect!=1)) &&
       opponent.effects[PBEffects::Substitute]==0
        damage *= 2
      end
    end
    if opponent.effects[PBEffects::Substitute]>0 && (!attacker || attacker.index!=opponent.index) &&
     !attacker.hasWorkingAbility(:INFILTRATOR) && !isSoundBased? && @id!=677 && $fefieldeffect!=14
      damage=opponent.effects[PBEffects::Substitute] if damage>opponent.effects[PBEffects::Substitute]
      opponent.effects[PBEffects::Substitute]-=damage
      opponent.damagestate.substitute=true
      @battle.scene.pbDamageAnimation(opponent,0)
      @battle.pbDisplayPaused(_INTL("The substitute took damage for {1}!",opponent.name))
      if opponent.effects[PBEffects::Substitute]<=0
        opponent.effects[PBEffects::Substitute]=0
        opponent.damagestate.substitute=false
        @battle.scene.pbUnSubstituteSprite(opponent,opponent.pbIsOpposing?(1))
        @battle.pbDisplayPaused(_INTL("{1}'s substitute faded!",opponent.name))
      end
      opponent.damagestate.hplost=damage
      damage=0
    elsif opponent.effects[PBEffects::Disguise] && (!attacker || attacker.index!=opponent.index) && 
     opponent.effects[PBEffects::Substitute]<=0 && opponent.damagestate.typemod!=0 && 
     !attacker.hasWorkingAbility(:MOLDBREAKER) && !attacker.hasWorkingAbility(:TERAVOLT) && 
     !attacker.hasWorkingAbility(:TURBOLAZE)
      @battle.scene.pbDamageAnimation(opponent,0)
      opponent.pbBreakDisguise
      @battle.pbDisplayPaused(_INTL("{1}'s Disguise was busted!",opponent.name))
      opponent.pbReduceHP([(opponent.totalhp/8).floor,1].max)
      opponent.effects[PBEffects::Disguise]=false
      damage=0
    elsif opponent.effects[PBEffects::IceFace] && ($fefieldeffect==39 || ( pbIsPhysical?(type) && (!attacker || attacker.index!=opponent.index) && 
     opponent.effects[PBEffects::Substitute]<=0 && opponent.damagestate.typemod!=0 && 
     !attacker.hasWorkingAbility(:MOLDBREAKER) && !attacker.hasWorkingAbility(:TERAVOLT) && !attacker.hasWorkingAbility(:TURBOLAZE) ) )
      @battle.scene.pbDamageAnimation(opponent,0)
      opponent.pbBreakDisguise
      @battle.pbDisplayPaused(_INTL("{1} transformed!",opponent.name))
      opponent.effects[PBEffects::IceFace]=false
      damage=0
    elsif (@battle.pbIsOpposing?(opponent.index)) && @battle.shieldCount>0 && opponent.damagestate.typemod!=0 && opponent.isBoss
      if opponent.effects[PBEffects::ShieldLife]==0
        shieldlife=[(opponent.totalhp/4).floor,1].max
        opponent.effects[PBEffects::ShieldLife]=shieldlife
      end
      if hitnum==0
        @battle.pbShieldDamage(opponent,damage,@thismove)
      end
      damage=0
    else
      opponent.damagestate.substitute=false
      if damage>=opponent.hp
        damage=opponent.hp
        if @function==0xE9 # False Swipe
          damage=damage-1
        elsif opponent.effects[PBEffects::Endure]
          damage=damage-1
          opponent.damagestate.endured=true
        elsif opponent.hasWorkingAbility(:STURDY) && damage==opponent.totalhp && !(opponent.moldbroken)
          opponent.damagestate.sturdy=true
          damage=damage-1                
        elsif opponent.damagestate.focussash && damage==opponent.totalhp
          opponent.damagestate.focussashused=true
          damage=damage-1
          opponent.pokemon.itemRecycle=opponent.item
          opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
          opponent.item=0
        elsif opponent.damagestate.focusband
          opponent.damagestate.focusbandused=true
          damage=damage-1
        elsif opponent.damagestate.rampcrest
          opponent.damagestate.rampcrestused=true
          opponent.effects[PBEffects::RampCrestUsage]=true
          damage=damage-1
        elsif $fefieldeffect==44 && opponent.hasWorkingAbility(:STALWART)  
          if opponent.hp == opponent.totalhp  
            damage=damage-1  
            opponent.damagestat.stalwart=true  
          end
        end
        damage=0 if damage<0
      end
      oldhp=opponent.hp
      opponent.hp-=damage
      effectiveness=0
      if opponent.damagestate.typemod<4
        effectiveness=1   # "Not very effective"
      elsif opponent.damagestate.typemod>4
        effectiveness=2   # "Super effective"
      end
      if opponent.damagestate.typemod!=0
        @battle.scene.pbDamageAnimation(opponent,effectiveness)
      end
      @battle.scene.pbHPChanged(opponent,oldhp)
      opponent.damagestate.hplost=damage
      if @battle.raidbattle && !@battle.pbBelongsToPlayer?(opponent.index) && @battle.pbIsOpposing?(opponent.index)
        limit = opponent.totalhp * 0.25
        if opponent.hp > 0 && oldhp > limit && opponent.hp < limit
          @battle.pbDisplay(_INTL("{1} has dropped its guard!!",opponent.pbThis))
        end
      end
    end
    if (@id == PBMoves::ULTRAMEGADEATH)
      @battle.ultramegadeath = (@battle.ultramegadeath+1)%2
    end
    #@battle.pbDisplay(_INTL("{1} damage!",damage))
    puts(damage)
    return damage
  end

################################################################################
# Effects
################################################################################
  def pbEffectMessages(attacker,opponent,ignoretype=false)
    if opponent.damagestate.critical
      @battle.pbDisplay(_INTL("A critical hit!"))
      attacker.effects[PBEffects::CritCount]+=1
      if attacker.effects[PBEffects::CritCount]>=3
        party=@battle.pbParty(attacker.index)
        for i in 0...party.length
          next if (i!=attacker.pokemonIndex) 
          next if party[i].critted==true
          party[i].critted=true
        end
      end
    end
    if !pbIsMultiHit
      if opponent.damagestate.typemod>4
        @battle.pbDisplay(_INTL("It's super effective!"))
      elsif opponent.damagestate.typemod>=1 && opponent.damagestate.typemod<4
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
    end
    if opponent.damagestate.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!",opponent.pbThis))
    elsif opponent.damagestate.sturdy
      @battle.pbDisplay(_INTL("{1} hung on with Sturdy!",opponent.pbThis))
      opponent.damagestate.sturdy=false
    elsif opponent.damagestate.focussashused
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",opponent.pbThis))
    elsif opponent.damagestate.focusbandused
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",opponent.pbThis))
    elsif opponent.damagestate.rampcrestused
      @battle.pbDisplay(_INTL("{1} hung on using its Rampardos Crest!",opponent.pbThis))
    elsif opponent.damagestate.stalwart  
      @battle.pbDisplay(_INTL("{1} hung on with Stalwart in the Colosseum!",opponent.pbThis))
    end
  end

  def pbEffectFixedDamage(damage,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return 0 if @battle.shieldSetup>0 && hitnum>0
    type=@type
    type=pbType(type,attacker,opponent)
    typemod=pbTypeModMessages(type,attacker,opponent)
    opponent.damagestate.critical=false
    opponent.damagestate.typemod=0
    opponent.damagestate.calcdamage=0
    opponent.damagestate.hplost=0
    if typemod!=0
      opponent.damagestate.calcdamage=damage
      opponent.damagestate.typemod=4
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      damage=1 if damage<1 # HP reduced can't be less than 1
      damage=pbReduceHPDamage(damage,attacker,opponent)
      pbEffectMessages(attacker,opponent)
      pbOnDamageLost(damage,attacker,opponent)
      return damage
    end
    return 0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return 0 if !opponent
    type=@type
    type=pbType(type,attacker,opponent)
    #typemod=pbTypeModMessages(type,attacker,opponent)
    if id == 10027 # Guardian of Alola
      return pbEffectFixedDamage((opponent.hp*3.0/4).floor,attacker,opponent,hitnum,alltargets,showanimation)
    elsif id == 10023 # Extreme Evoboost  
      if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
        return -1
      end
      pbShowAnimation(@name,attacker,nil,hitnum,alltargets,showanimation)
      showanim=true
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,2,false,showanim,nil,showanim)
          showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,2,false,showanim,nil,showanim)
        showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
        attacker.pbIncreaseStat(PBStats::SPEED,2,false,showanim,nil,showanim)
        showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,2,false,showanim,nil,showanim)
        showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,2,false,showanim,nil,showanim)
        showanim=false
      end      
      return 0            
    end  
    if self.function==0x209 && attacker.species == PBSpecies::PROBOPASS && attacker.hasWorkingItem(:PROBOCREST)
      case hitnum
      when 0
          self.type=PBTypes::STEEL
      when 1
          self.type=PBTypes::ROCK
      when 2 
          self.type=PBTypes::ELECTRIC
      end
    end
    damage=pbCalcDamage(attacker,opponent)    
#### KUROTSUNE - 032 - START
    if attacker.effects[PBEffects::MeFirst]
      damage *= 1.5
    end
#### KUROTSUNE - 032 - END
#### KUROTSUNE - 004 - START
    if hitnum == 1 && attacker.effects[PBEffects::ParentalBond]
      damage /= 4
    end
    if hitnum == 1 && attacker.effects[PBEffects::TyphBond]
      damage *= 0.3
    end
#### KUROTSUNE - 004 - END
    if opponent.damagestate.typemod!=0 
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation) if @id < 10000
      pbShowAnimation(@name,attacker,opponent,hitnum,alltargets,showanimation) if @id > 10000
      if self.function==0xC9 || self.function==0xCA || self.function==0xCB ||
        self.function==0xCC || self.function==0xCD || self.function==0xCE #Sprites for two turn moves            
        @battle.scene.pbUnVanishSprite(attacker,false)
        if self.function==0xCE
          @battle.scene.pbUnVanishSprite(opponent,false)
        end
      end       
    end
    #return 0 if @battle.shieldSetup>0 && hitnum>0
    damage=pbReduceHPDamage(damage,attacker,opponent,hitnum)
    pbEffectMessages(attacker,opponent)
    pbOnDamageLost(damage,attacker,opponent)
    pbZMoveEffects(attacker,opponent) if (opponent.damagestate.typemod!=0 && id > 10000)
    if self.function==0x207
      thunder_index = attacker.effects[PBEffects::ThunderRaidHit]
      if damage>0
        if thunder_index == 0
          if opponent.pbCanReduceStatStage?(PBStats::ATTACK,false)
            opponent.pbReduceStat(PBStats::ATTACK,1,false,207)
            attacker.effects[PBEffects::ThunderRaidStat][thunder_index] = 1
          end
        elsif thunder_index == 1
          if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,false)
            opponent.pbReduceStat(PBStats::DEFENSE,1,false,207)
            attacker.effects[PBEffects::ThunderRaidStat][thunder_index] = 1
          end
        elsif thunder_index == 2
          if opponent.pbCanReduceStatStage?(PBStats::SPATK,false)
            opponent.pbReduceStat(PBStats::SPATK,1,false,207)
            attacker.effects[PBEffects::ThunderRaidStat][thunder_index] = 1
          end
        elsif thunder_index == 3
          if opponent.pbCanReduceStatStage?(PBStats::SPDEF,false)
            opponent.pbReduceStat(PBStats::SPDEF,1,false,207)
            attacker.effects[PBEffects::ThunderRaidStat][thunder_index] = 1
          end
        elsif thunder_index == 4
          if opponent.pbCanReduceStatStage?(PBStats::SPEED,false)
            opponent.pbReduceStat(PBStats::SPEED,1,false,207)
            attacker.effects[PBEffects::ThunderRaidStat][thunder_index] = 1
          end
        end
      end
      if thunder_index == 4
        status_strings = ["Atk", "Def", "Sp. Atk", "Sp. Def", "Speed"]
        stat_string = ""
        for i in 0..4
          if attacker.effects[PBEffects::ThunderRaidStat][i]
            stat_string = stat_string + status_strings[i] + ", "
          end
        end
        if stat_string.length > 0
          stat_string = stat_string[0...-2]
          stat_str = stat_string.reverse.sub(", ".reverse, " and ".reverse).reverse
          @battle.pbCommonAnimation("StatDown",opponent,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} fell!",opponent.pbThis, stat_str))
        end
      end
      attacker.effects[PBEffects::ThunderRaidHit] = (attacker.effects[PBEffects::ThunderRaidHit]+1)%5
    end
    return damage   # The HP lost by the opponent due to this attack
  end

################################################################################
# Using the move
################################################################################
  def pbOnStartUse(attacker)
    return true
  end

  def pbAddTarget(targets,attacker)
  end

  def pbSuccessCheck(attacker,opponent,numtargets)
  end

  def pbDisplayUseMessage(attacker)
  # Return values:
  # -1 if the attack should exit as a failure
  # 1 if the attack should exit as a success
  # 0 if the attack should proceed its effect
  # 2 if Bide is storing energy
    @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,name))
    return 0
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return if !showanimation
    @battle.pbAnimation(id,attacker,opponent,hitnum)
  end

  def pbOnDamageLost(damage,attacker,opponent)
    #Used by Counter/Mirror Coat/Revenge/Focus Punch/Bide
    type=@type
    type=pbType(type,attacker,opponent)
    if opponent.effects[PBEffects::Bide]>0
      opponent.effects[PBEffects::BideDamage]+=damage
      opponent.effects[PBEffects::BideTarget]=attacker.index
    end
    if @function==0x90 # Hidden Power
      type=getConst(PBTypes,:NORMAL) || 0
    end
    if pbIsPhysical?(type)
      opponent.effects[PBEffects::Counter]=damage
      opponent.effects[PBEffects::CounterTarget]=attacker.index
    end
    if pbIsSpecial?(type)
      opponent.effects[PBEffects::MirrorCoat]=damage
      opponent.effects[PBEffects::MirrorCoatTarget]=attacker.index
    end
    opponent.lastHPLost=damage # for Revenge/Focus Punch/Metal Burst
    opponent.lastAttacker=attacker.index # for Revenge/Metal Burst
  end

  def pbMoveFailed(attacker,opponent)
    # Called to determine whether the move failed
    return false
  end
end