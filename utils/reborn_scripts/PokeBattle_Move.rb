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
  attr_accessor(:category)
  attr_reader(:accuracy)
  attr_reader(:addlEffect)
  attr_reader(:target)
  attr_accessor(:priority)
  attr_accessor(:flags)
  attr_reader(:thismove)
  attr_accessor(:pp)
  attr_accessor(:totalpp)
  attr_accessor(:zmove)
  attr_reader(:user)
  attr_accessor :fieldmessageshown
  attr_accessor :fieldmessageshown_type

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
    @name = PBMoves.getName(@id)   # Get the move's name
    # Get data on the move
    @function    = $cache.pkmn_move[@id][PBMoveData::FUNCTION]
    @basedamage  = $cache.pkmn_move[@id][PBMoveData::BASEDAMAGE]
    @type        = $cache.pkmn_move[@id][PBMoveData::TYPE]
    @category    = $cache.pkmn_move[@id][PBMoveData::CATEGORY]
    @accuracy    = $cache.pkmn_move[@id][PBMoveData::ACCURACY]
    @addlEffect  = $cache.pkmn_move[@id][PBMoveData::ADDLEFFECT]
    @target      = $cache.pkmn_move[@id][PBMoveData::TARGET]
    @priority    = $cache.pkmn_move[@id][PBMoveData::PRIORITY]
    @flags       = $cache.pkmn_move[@id][PBMoveData::FLAGS]
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
    className=sprintf("PokeBattle_Move_%03X",$cache.pkmn_move[move.id][PBMoveData::FUNCTION]) if move
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

  def pbType(attacker,type=@type)
    case @battle.FE
      when PBFields::ASHENB then  type=PBTypes::FIGHTING  if @id == PBMoves::STRENGTH
      when PBFields::GLITCHF then  type=PBTypes::NORMAL    if type == PBTypes::DARK || type == PBTypes::STEEL || type == PBTypes::FAIRY
      when PBFields::MURKWATERS then  type=PBTypes::WATER     if (@id == PBMoves::MUDSLAP || @id == PBMoves::MUDBOMB ||  @id == PBMoves::MUDSHOT || @id == PBMoves::THOUSANDWAVES)
      when PBFields::FAIRYTALEF then  type=PBTypes::STEEL     if (@id == PBMoves::SACREDSWORD || @id == PBMoves::CUT || @id == PBMoves::SLASH || @id == PBMoves::SECRETSWORD)
      when PBFields::STARLIGHTA then  type=PBTypes::FAIRY     if @id == PBMoves::SOLARBEAM || @id == PBMoves::SOLARBLADE
    end
    if type>=0
      case attacker.ability
      when PBAbilities::NORMALIZE   then type=PBTypes::NORMAL
      when PBAbilities::PIXILATE    then type=PBTypes::FAIRY    if type==PBTypes::NORMAL && @battle.FE != PBFields::GLITCHF
      when PBAbilities::AERILATE    then type=PBTypes::FLYING   if type==PBTypes::NORMAL
      when PBAbilities::GALVANIZE   then type=PBTypes::ELECTRIC if type==PBTypes::NORMAL
      when PBAbilities::REFRIGERATE then type=PBTypes::ICE      if type==PBTypes::NORMAL
      when PBAbilities::DUSKILATE   then type=PBTypes::DARK     if type==PBTypes::NORMAL && @battle.FE != PBFields::GLITCHF
      when PBAbilities::LIQUIDVOICE then type= @battle.FE==PBFields::ICYF ? PBTypes::ICE : PBTypes::WATER if isSoundBased?
      end
    end
    if attacker.effects[PBEffects::Electrify] || type == PBTypes::NORMAL && @battle.state.effects[PBEffects::IonDeluge] == true
      type=(PBTypes::ELECTRIC)
    end
    return type
  end

  def pbIsPhysical?(type = PBTypes::NORMAL)
    if @battle.FE == PBFields::GLITCHF
      return (!PBTypes.isSpecialType?(type) && @category!=2)
    else
      return @category==0
    end
  end

  def pbIsSpecial?(type = @type)
    if @battle.FE == PBFields::GLITCHF
      return (PBTypes.isSpecialType?(type) && @category!=2)
    else
      return @category==1
    end
  end

  def pbIsStatus?
    return @category==2
  end

  def pbHitsSpecialStat?(type = @type)
    return false if @function == 0x122  # Psyshock/Psystrike
    return pbIsSpecial?(type)
  end

  def pbHitsPhysicalStat?(type = @type)
    return true if @function == 0x122
    return pbIsPhysical?(type)
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
    if PBStuff::TWOTURNMOVE.include?(opp2.effects[PBEffects::TwoTurnAttack])
      return [opp1]
    end
    if PBStuff::TWOTURNMOVE.include?(opp1.effects[PBEffects::TwoTurnAttack])
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
    if opp1.effects[PBEffects::Protect] || opp1.effects[PBEffects::SpikyShield] || opp2.effects[PBEffects::BanefulBunker] ||
       opp1.effects[PBEffects::KingsShield] || opp1.effects[PBEffects::Obstruct]
      return [opp2]
    end
    if opp2.effects[PBEffects::Substitute]>0 || opp2.effects[PBEffects::Disguise] || opp2.effects[PBEffects::IceFace]
      return [opp1]
    end
    if opp1.effects[PBEffects::Substitute]>0 || opp1.effects[PBEffects::Disguise] || opp1.effects[PBEffects::IceFace]
      return [opp2]
    end
    return [opp1,opp2]
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

  def pbSecondAdditionalEffect(attacker,opponent)
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
    return 4 if (type == PBTypes::GROUND) && opponent.pbHasType?(:FLYING) && opponent.hasWorkingItem(:IRONBALL)
    atype=type # attack type
    otype1=opponent.type1
    otype2=opponent.type2
    if zorovar # ai being fooled by illusion
      otype1=opponent.effects[PBEffects::Illusion].type1 #17
      otype2=opponent.effects[PBEffects::Illusion].type2 #17
    end
    if (otype1 == PBTypes::FLYING) && opponent.effects[PBEffects::Roost]
      if (otype2 == PBTypes::FLYING)
        otype1=(PBTypes::NORMAL) || 0
      else
        otype1=otype2
      end
    end
    if (otype2 == PBTypes::FLYING) && opponent.effects[PBEffects::Roost]
      otype2=otype1
    end
    if (otype1 == PBTypes::FIRE) && opponent.effects[PBEffects::BurnUp]
      if (otype2 == PBTypes::FIRE)
        otype1=(PBTypes::QMARKS) || 0
      else
        otype1=otype2
      end
    end
    if (otype2 == PBTypes::FIRE) && opponent.effects[PBEffects::BurnUp]
      otype2=otype1
    end
    mod1=PBTypes.getEffectiveness(atype,otype1)
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    if attacker.ability == PBAbilities::SCRAPPY || opponent.effects[PBEffects::Foresight]
      mod1=2 if otype1 == PBTypes::GHOST && (atype == PBTypes::NORMAL || atype == PBTypes::FIGHTING)
      mod2=2 if otype2 == PBTypes::GHOST && (atype == PBTypes::NORMAL || atype == PBTypes::FIGHTING)
    end
    if @battle.FE == PBFields::HOLYF
      mod1=4 if (otype1 == PBTypes::GHOST || otype1 == PBTypes::DARK) && atype == PBTypes::NORMAL
      mod2=4 if (otype2 == PBTypes::GHOST || otype2 == PBTypes::DARK) && atype == PBTypes::NORMAL
    end
    if @battle.FE == PBFields::FAIRYTALEF
      mod1=4 if (otype1 == PBTypes::DRAGON) && atype == PBTypes::STEEL
      mod2=4 if (otype2 == PBTypes::DRAGON) && atype == PBTypes::STEEL
    end
    if attacker.ability == PBAbilities::PIXILATE || attacker.ability == PBAbilities::AERILATE || attacker.ability == PBAbilities::DUSKILATE || attacker.ability == PBAbilities::REFRIGERATE || attacker.ability == PBAbilities::GALVANIZE || (attacker.ability == PBAbilities::LIQUIDVOICE && isSoundBased?)
      mod1=2 if (otype1 == PBTypes::GHOST) && (atype == PBTypes::NORMAL)
      mod2=2 if (otype2 == PBTypes::GHOST) && (atype == PBTypes::NORMAL)
    end
    if attacker.ability == PBAbilities::NORMALIZE
      mod1=2 if isConst?(otype1,PBTypes,(:GROUND || :FAIRY || :FLYING || :NORMAL || :DARK))
      mod1=1 if (otype1 == PBTypes::STEEL)
      mod1=0 if (otype1 == PBTypes::GHOST) && !opponent.effects[PBEffects::Foresight]
      mod2=2 if isConst?(otype2,PBTypes,(:GROUND || :FAIRY || :FLYING || :NORMAL || :DARK))
      mod2=1 if (otype2 == PBTypes::STEEL)
      mod2=0 if (otype2 == PBTypes::GHOST) && !opponent.effects[PBEffects::Foresight]
    end
    if opponent.effects[PBEffects::Electrify]
      mod1=0 if (otype1 == PBTypes::GROUND)
      mod1=4 if (otype1 == PBTypes::FLYING)
      mod1=2 if isConst?(otype1,PBTypes,(:GHOST || :FAIRY || :NORMAL || :DARK))
      mod2=0 if (otype2 == PBTypes::GROUND)
      mod2=4 if (otype2 == PBTypes::FLYING)
      mod2=2 if isConst?(otype2,PBTypes,(:GHOST || :FAIRY || :NORMAL || :DARK))
    end
    if @battle.FE == PBFields::GLITCHF
      mod1=0 if (otype1 == PBTypes::GHOST) && isConst?(atype,PBTypes,(:FAIRY || :DARK || :STEEL))
      mod2=0 if (otype2 == PBTypes::GHOST) && isConst?(atype,PBTypes,(:FAIRY || :DARK || :STEEL))
    end
    if opponent.effects[PBEffects::Ingrain] || opponent.effects[PBEffects::SmackDown] || @battle.state.effects[PBEffects::Gravity]>0
      mod1=2 if (otype1 == PBTypes::FLYING) && (atype == PBTypes::GROUND)
      mod2=2 if (otype2 == PBTypes::FLYING) && (atype == PBTypes::GROUND)
    end
    if opponent.effects[PBEffects::MiracleEye]
      mod1=2 if (otype1 == PBTypes::DARK) && (atype == PBTypes::PSYCHIC)
      mod2=2 if (otype2 == PBTypes::DARK) && (atype == PBTypes::PSYCHIC)
    end
    if (opponent.item == PBItems::RINGTARGET)
      mod1=2 if mod1==0
      mod2=2 if mod2==0
    end
    if !opponent.moldbroken
      if (atype == PBTypes::FIRE && opponent.ability == PBAbilities::FLASHFIRE) || 
        (atype == PBTypes::GRASS && opponent.ability == PBAbilities::SAPSIPPER) ||
        (atype == PBTypes::WATER && (opponent.ability == PBAbilities::WATERABSORB || opponent.ability == PBAbilities::STORMDRAIN || opponent.ability == PBAbilities::DRYSKIN)) ||
        (atype == PBTypes::ELECTRIC && (opponent.ability == PBAbilities::VOLTABSORB || opponent.ability == PBAbilities::LIGHTNINGROD || opponent.ability == PBAbilities::MOTORDRIVE)) ||
        (atype == PBTypes::GROUND && opponent.ability == PBAbilities::LEVITATE && @battle.FE != PBFields::CAVE && @id != PBMoves::THOUSANDARROWS && opponent.isAirborne?) 
        mod1=0
      end
    end
    if @battle.FE == PBFields::CAVE || @id == PBMoves::THOUSANDARROWS
      mod1=2 if (otype1 == PBTypes::FLYING) && (atype == PBTypes::GROUND)
      mod2=2 if (otype2 == PBTypes::FLYING) && (atype == PBTypes::GROUND)
    end
    mod2=(otype1==otype2) ? 2 : mod2

    # Inversemode password
    if $game_switches[:Inversemode] && @battle.FE != PBFields::INVERSEF
      mod1 = 1 if mod1==0
      mod2 = 1 if mod2==0
      return 16 / (mod1 * mod2)
    end
    return mod1*mod2
  end

  def pbTypeModifierNonBattler(type,attacker,opponent)
    return 4 if type<0
    return 4 if (type == PBTypes::GROUND) && opponent.hasType?(:FLYING) && (opponent.item == PBItems::IRONBALL)
    atype=type # attack type
    otype1=opponent.type1
    otype2=opponent.type2
    mod1=PBTypes.getEffectiveness(atype,otype1)
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    if @battle.FE == PBFields::CAVE || @id == PBMoves::THOUSANDARROWS
      mod1=2 if (otype1 == PBTypes::FLYING) && (atype == PBTypes::GROUND)
      mod2=2 if (otype2 == PBTypes::FLYING) && (atype == PBTypes::GROUND)
    end
    if (opponent.item == PBItems::RINGTARGET)
      mod1=2 if mod1==0
      mod2=2 if mod2==0
    end
    if (attacker.ability == PBAbilities::SCRAPPY)
      mod1=2 if (otype1 == PBTypes::GHOST) && ((atype == PBTypes::NORMAL) || (atype == PBTypes::FIGHTING))
      mod2=2 if (otype2 == PBTypes::GHOST) && ((atype == PBTypes::NORMAL) || (atype == PBTypes::FIGHTING))
    end
    if @battle.FE == PBFields::HOLYF
      mod1=2 if (otype1 == PBTypes::GHOST) && (atype == PBTypes::NORMAL)
      mod2=2 if (otype2 == PBTypes::GHOST) && (atype == PBTypes::NORMAL)
    end
    if (attacker.ability == PBAbilities::PIXILATE) || (attacker.ability == PBAbilities::AERILATE) || (attacker.ability == PBAbilities::DUSKILATE) || (attacker.ability == PBAbilities::REFRIGERATE) || (attacker.ability == PBAbilities::GALVANIZE) || ((attacker.ability == PBAbilities::LIQUIDVOICE) && isSoundBased?)
      mod1=2 if (otype1 == PBTypes::GHOST) && (atype == PBTypes::NORMAL)
      mod2=2 if (otype2 == PBTypes::GHOST) && (atype == PBTypes::NORMAL)
    end
    if (attacker.ability == PBAbilities::NORMALIZE)
      mod1=2 if isConst?(otype1,PBTypes,(:GROUND || :FAIRY || :FLYING || :NORMAL || :DARK))
      mod1=1 if (otype1 == PBTypes::STEEL)
      mod1=0 if (otype1 == PBTypes::GHOST)
      mod2=2 if isConst?(otype2,PBTypes,(:GROUND || :FAIRY || :FLYING || :NORMAL || :DARK))
      mod2=1 if (otype2 == PBTypes::STEEL)
      mod2=0 if (otype2 == PBTypes::GHOST)
    end
    if @battle.FE == PBFields::GLITCHF
      mod1=0 if (otype1 == PBTypes::GHOST) && isConst?(atype,PBTypes,(:FAIRY || :DARK || :STEEL))
      mod2=0 if (otype2 == PBTypes::GHOST) && isConst?(atype,PBTypes,(:FAIRY || :DARK || :STEEL))
    end

    if @battle.state.effects[PBEffects::Gravity]>0
      mod1=2 if (otype1 == PBTypes::FLYING) && (atype == PBTypes::GROUND)
      mod2=2 if (otype2 == PBTypes::FLYING) && (atype == PBTypes::GROUND)
    end
    return mod1*mod2
  end

  def pbStatusMoveAbsorption(type,attacker,opponent)
    if opponent.ability == PBAbilities::SAPSIPPER && !(opponent.moldbroken) && type == PBTypes::GRASS
      if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK)
        opponent.pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!", opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end
    if (opponent.ability == PBAbilities::STORMDRAIN && type == PBTypes::WATER) || (opponent.ability == PBAbilities::LIGHTNINGROD && type == PBTypes::ELECTRIC) && !(opponent.moldbroken)
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
    if (opponent.ability == PBAbilities::MOTORDRIVE) && type == PBTypes::ELECTRIC && !(opponent.moldbroken)
      if opponent.pbCanIncreaseStatStage?(PBStats::SPEED)
        if @battle.FE == PBFields::SHORTCIRCUITF
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
    if !(opponent.moldbroken) && (((opponent.ability == PBAbilities::DRYSKIN || opponent.ability == PBAbilities::WATERABSORB) &&  type == PBTypes::WATER) || (opponent.ability == PBAbilities::VOLTABSORB && type == PBTypes::ELECTRIC)) 
      if opponent.effects[PBEffects::HealBlock]==0
        if opponent.pbRecoverHP((opponent.totalhp/4.0).floor,true)>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",
             opponent.pbThis,PBAbilities.getName(opponent.ability)))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} useless!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),@name))
        end
        return 0
      end
    end
    if opponent.ability == PBAbilities::FLASHFIRE && !(opponent.moldbroken) && type == PBTypes::FIRE
      if !opponent.effects[PBEffects::FlashFire]
        opponent.effects[PBEffects::FlashFire]=true
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Fire power!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end
    if opponent.ability == PBAbilities::MAGMAARMOR && type == PBTypes::FIRE && @battle.FE == PBFields::DRAGONSD && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
       opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      return 0
    end
    if (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS) && (type == PBTypes::GROUND)
      @battle.pbDisplay(_INTL("...But there was no solid ground to attack from!"))
      return 0
    end
    if @battle.FE == PBFields::UNDERWATER && type == PBTypes::FIRE
      @battle.pbDisplay(_INTL("...But the attack was doused instantly!"))
      return 0
    end
    return 4
  end
  
  def pbTypeModMessages(type,attacker,opponent)
    return 4 if type<0
    secondtype = fieldTypeChange(attacker,opponent,1,true)
    if opponent.ability == PBAbilities::SAPSIPPER && !(opponent.moldbroken) && (type == PBTypes::GRASS || secondtype==PBTypes::GRASS)
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
    if (opponent.ability == PBAbilities::STORMDRAIN && (type == PBTypes::WATER || secondtype==PBTypes::WATER)) ||
       (opponent.ability == PBAbilities::LIGHTNINGROD && (type == PBTypes::ELECTRIC || secondtype==PBTypes::ELECTRIC)) && !(opponent.moldbroken)
      if opponent.pbCanIncreaseStatStage?(PBStats::SPATK)
        opponent.pbIncreaseStatBasic(PBStats::SPATK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      if @function==0xCB #Dive
        @battle.scene.pbUnVanishSprite(attacker)
      end
      return 0
    end
    if (opponent.ability == PBAbilities::MOTORDRIVE) && (type == PBTypes::ELECTRIC || secondtype==PBTypes::ELECTRIC) && !(opponent.moldbroken)
      if opponent.pbCanIncreaseStatStage?(PBStats::SPEED)
        if @battle.FE == PBFields::SHORTCIRCUITF
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
    if ((opponent.ability == PBAbilities::DRYSKIN && !(opponent.moldbroken)) && (type == PBTypes::WATER || secondtype==PBTypes::WATER)) ||
      (opponent.ability == PBAbilities::VOLTABSORB && !(opponent.moldbroken) && (type == PBTypes::ELECTRIC || secondtype==PBTypes::ELECTRIC)) ||
      (opponent.ability == PBAbilities::WATERABSORB && !(opponent.moldbroken) && (type == PBTypes::WATER || secondtype==PBTypes::WATER))
      if opponent.effects[PBEffects::HealBlock]==0
        if opponent.pbRecoverHP((opponent.totalhp/4.0).floor,true)>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",
              opponent.pbThis,PBAbilities.getName(opponent.ability)))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} useless!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),@name))
        end
        if @function==0xCB #Dive
          @battle.scene.pbUnVanishSprite(attacker)
        end
        return 0
      end
    end
    if (opponent.ability == PBAbilities::BULLETPROOF) && !(opponent.moldbroken)
      if (PBStuff::BULLETMOVE).include?(@id)
        @battle.pbDisplay(_INTL("{1}'s {2} blocked the attack!",
        opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
        return 0
      end
    end
    if @battle.FE == PBFields::ROCKYF && (opponent.effects[PBEffects::Substitute]>0 || opponent.stages[PBStats::DEFENSE] > 0)
      if (PBStuff::BULLETMOVE).include?(@id)
        @battle.pbDisplay(_INTL("{1} hid behind a rock to dodge the attack!",
        opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
        return 0
      end
    end
    if opponent.ability == PBAbilities::FLASHFIRE && !(opponent.moldbroken) && (type == PBTypes::FIRE || secondtype==PBTypes::FIRE)
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
    if opponent.ability == PBAbilities::MAGMAARMOR && (type == PBTypes::FIRE || secondtype==PBTypes::FIRE) &&
      @battle.FE == PBFields::DRAGONSD && !(opponent.moldbroken)
      @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
       opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      return 0
    end
    if (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS) &&
      ((type == PBTypes::GROUND) || secondtype==PBTypes::GROUND)
      @battle.pbDisplay(_INTL("...But there was no solid ground to attack from!"))
      if @function==0xCA #Dig
        @battle.scene.pbUnVanishSprite(attacker)
      end
      return 0
    end
    if @battle.FE == PBFields::UNDERWATER && (type == PBTypes::FIRE || secondtype==PBTypes::FIRE)
      @battle.pbDisplay(_INTL("...But the attack was doused instantly!"))
      return 0
    end
    #Telepathy
    if ((opponent.ability == PBAbilities::TELEPATHY  && !opponent.moldbroken) || @battle.FE == PBFields::HOLYF) && @basedamage>0
      if opponent.index == attacker.pbPartner.index
        @battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",opponent.pbThis))
        return 0
      end
    end
    # UPDATE Implementing Flying Press + Freeze Dry
    typemod=pbTypeModifier(type,attacker,opponent)
    typemod2= nil
    typemod3= nil
    if type == PBTypes::FIRE && opponent.effects[PBEffects::TarShot]
      typemod*=2
    end
    if type == PBTypes::WATER && opponent.hasType?(PBTypes::WATER) && @battle.FE == PBFields::UNDERWATER
      typemod *= 2
    end
    if @battle.FE == PBFields::GLITCHF # Glitch Field
      typemod = 4 if type == PBTypes::DRAGON
      typemod = 0 if type == PBTypes::GHOST && opponent.hasType?(PBTypes::PSYCHIC)
      typemod *= 4 if type == PBTypes::BUG && opponent.hasType?(PBTypes::POISON)
      typemod *= 2 if type == PBTypes::ICE && opponent.hasType?(PBTypes::FIRE)
      typemod *= 2 if type == PBTypes::POISON && opponent.hasType?(PBTypes::BUG)
    end
    typemod *= 4 if @id == PBMoves::FREEZEDRY && opponent.hasType?(PBTypes::WATER)
    if @id == PBMoves::CUT && opponent.hasType?(PBTypes::GRASS) && (@battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter > 0))
      typemod *= 2
    end
    if @id == PBMoves::FLYINGPRESS
      typemod2=pbTypeModifier(PBTypes::FLYING,attacker,opponent)
      typemod3= ((typemod*typemod2)/4)
      typemod=typemod3
    end

    # Field Effect second type changes 
    typemod=fieldTypeChange(attacker,opponent,typemod,false)

    # Cutting typemod in half
    if @battle.pbWeather==PBWeather::STRONGWINDS && (opponent.hasType?(PBTypes::FLYING) && !opponent.effects[PBEffects::Roost]) &&
      (PBTypes.getEffectiveness(type, PBTypes::FLYING) > 2) ^ (PBTypes.getEffectiveness(type, PBTypes::FLYING) < 2 && ($game_switches[:Inversemode] ^ (@battle.FE == PBFields::INVERSEF)))
       typemod /= 2
     end
     if @battle.FE == PBFields::DRAGONSD && opponent.ability == PBAbilities::MULTISCALE && (type == PBTypes::FAIRY || type == PBTypes::ICE || type == PBTypes::DRAGON) && !(opponent.moldbroken)
       typemod /= 2
     end
     if @battle.FE == PBFields::FLOWERGARDENF && opponent.pbHasType?(PBTypes::GRASS) && @battle.field.counter >= 3 &&
       PBTypes.getEffectiveness(type, PBTypes::GRASS) > 2
       typemod /= 2
     end

    if typemod==0
      if @function==0x111
        return 1
      else
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
        if PBStuff::TWOTURNMOVE.include?(@id)
          @battle.scene.pbUnVanishSprite(attacker)
        end
      end
    end
    return typemod
  end

  def fieldTypeChange(attacker,opponent,typemod,return_type=false)

    case @battle.FE
      when PBFields::RAINBOWF # Rainbow Field
        if (pbType(attacker) == PBTypes::NORMAL) && pbIsSpecial?(pbType(attacker)) 
          moddedtype = 1+@battle.pbRandom(18)
        end
      when PBFields::CORROSIVEMISTF # Corrosive Mist Field
        if (pbType(attacker) == PBTypes::FLYING) && !pbIsPhysical?(pbType(attacker))
          moddedtype = PBTypes::POISON
        end
      when PBFields::SHORTCIRCUITF # Shortcircuit Field
        if (pbType(attacker) == PBTypes::STEEL) && attacker.ability == PBAbilities::STEELWORKER
          moddedtype = PBTypes::ELECTRIC
        end
      when PBFields::CRYSTALC # Crystal Cavern
        if (pbType(attacker) == PBTypes::ROCK) || (@id == PBMoves::JUDGMENT || @id == PBMoves::ROCKCLIMB || @id == PBMoves::STRENGTH || @id == PBMoves::MULTIATTACK || @id == PBMoves::PRISMATICLASER)
          moddedtype = @battle.field.getRoll(update_roll: caller_locations.any? {|string| string.to_s.include?("pbCalcDamage")} && !return_type)
        end
      when PBFields::INVERSEF # Inverse Field
        if !$game_switches[:Inversemode]
          if typemod == 0
            typevar1 = PBTypes.getEffectiveness(@type,opponent.type1)
            typevar2 = PBTypes.getEffectiveness(@type,opponent.type2)
            typevar1 = 1 if typevar1==0
            typevar2 = 1 if typevar2==0
            typemod = typevar1 * typevar2
          end
          typemod = 16 / typemod
          #inverse field can (and should) just skip the rest
          return typemod if !return_type
        end
    end
    moddedtype = @battle.fieldeffectchecker(@id,:MOVETYPEMOD) if !moddedtype
    if !moddedtype #if moddedtype is STILL nil
      currenttype = pbType(attacker)
      moddedtype = @battle.fieldeffectchecker(currenttype,:TYPETYPEMOD)
    end
    if return_type
      return moddedtype ? moddedtype : @type
    else
      return typemod if !moddedtype
      newtypemod = pbTypeModifier(moddedtype,attacker,opponent)
      typemod = ((typemod*newtypemod) * 0.25).ceil
      return typemod
    end
  end
  
################################################################################
# This move's accuracy check
################################################################################
  def pbAccuracyCheck(attacker,opponent)
    baseaccuracy=@accuracy
    return true if baseaccuracy==0
    return true if attacker.ability == PBAbilities::NOGUARD || opponent.ability == PBAbilities::NOGUARD || (attacker.hasWorkingAbility(:FAIRYAURA) && @battle.FE == PBFields::FAIRYTALEF)
    return true if opponent.effects[PBEffects::Telekinesis]>0
    return true if @function==0x0D && @battle.pbWeather==PBWeather::HAIL # Blizzard
    return true if (@function==0x08 || @function==0x15) && @battle.pbWeather==PBWeather::RAINDANCE # Thunder, Hurricane
    return true if @function==0x08 && (@battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM) # Thunder
    return true if @type == PBTypes::ELECTRIC && @battle.FE == PBFields::UNDERWATER
    return true if attacker.pbHasType?(:POISON) && @id == PBMoves::TOXIC
    return true if (@function==0x10 || @id == PBMoves::BODYSLAM ||
                    @function==0x137 || @function==0x9B) &&
                    opponent.effects[PBEffects::Minimize] # Flying Press, Stomp, DRush
    return true if @battle.FE == PBFields::MIRRORA && (PBFields::BLINDINGMOVES + [PBMoves::MIRRORSHOT]).include?(@id)
    # One-hit KO accuracy handled elsewhere
    # Field Effects
    fieldmove = @battle.field.moveData(@id)
		baseaccuracy = fieldmove[:accmod] if fieldmove && fieldmove[:accmod]
   # if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter > 1 # Flower Garden
   #   if @id == PBMoves::SLEEPPOWDER || @id == PBMoves::STUNSPORE || @id == PBMoves::POISONPOWDER
   #     baseaccuracy=85
   #   end
   # end
    if @function==0x08 || @function==0x15 # Thunder, Hurricane
      baseaccuracy=50 if (@battle.pbWeather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
    end
    accstage=attacker.stages[PBStats::ACCURACY]
    accstage=0 if opponent.ability == PBAbilities::UNAWARE && !(opponent.moldbroken)
    accuracy=(accstage>=0) ? (accstage+3)*100.0/3 : 300.0/(3-accstage)
    evastage=opponent.stages[PBStats::EVASION]
    evastage-=2 if @battle.state.effects[PBEffects::Gravity]>0
    evastage=-6 if evastage<-6
    evastage=0 if opponent.effects[PBEffects::Foresight] || opponent.effects[PBEffects::MiracleEye] || @function==0xA9 || # Chip Away
                  attacker.ability == PBAbilities::UNAWARE && !(opponent.moldbroken)
    evasion=(evastage>=0) ? (evastage+3)*100.0/3 : 300.0/(3-evastage)
    if attacker.ability == PBAbilities::COMPOUNDEYES
      accuracy*=1.3
    end
    if attacker.hasWorkingItem(:MICLEBERRY)
      if (attacker.ability == PBAbilities::GLUTTONY && attacker.hp<=(attacker.totalhp/2.0).floor) ||
        attacker.hp<=(attacker.totalhp/4.0).floor
        accuracy*=1.2
        attacker.pbDisposeItem(true)
      end
    end
    if attacker.ability == PBAbilities::VICTORYSTAR
      accuracy*=1.1
    end
    partner=attacker.pbPartner
    if partner && partner.ability == PBAbilities::VICTORYSTAR
      accuracy*=1.1
    end
    if attacker.hasWorkingItem(:WIDELENS)
      accuracy*=1.1
    end
    if attacker.hasWorkingItem(:ZOOMLENS) && attacker.speed < opponent.speed
      accuracy*=1.2
    end
    if attacker.ability == PBAbilities::HUSTLE && @basedamage>0 && pbIsPhysical?(pbType(attacker))
      accuracy*=0.8
    end
    if attacker.ability == PBAbilities::LONGREACH && (@battle.FE == PBFields::ROCKYF || @battle.FE == PBFields::FORESTF) # Rocky/ Forest Field
      accuracy*=0.9
    end
    if opponent.ability == PBAbilities::WONDERSKIN && @basedamage==0 && attacker.pbIsOpposing?(opponent.index) && !(opponent.moldbroken)
      if @battle.FE == PBFields::RAINBOWF
        accuracy*=0
      else
        accuracy*=0.5
      end
    end
    if opponent.ability == PBAbilities::TANGLEDFEET && opponent.effects[PBEffects::Confusion]>0 && !(opponent.moldbroken)
      evasion*=1.2
    end
    if opponent.ability == PBAbilities::SANDVEIL && (@battle.pbWeather==PBWeather::SANDSTORM || @battle.FE == PBFields::DESERTF || @battle.FE == PBFields::ASHENB) && !(opponent.moldbroken)
      evasion*=1.2
    end
    if opponent.ability == PBAbilities::SNOWCLOAK && (@battle.pbWeather==PBWeather::HAIL || @battle.FE == PBFields::ICYF || @battle.FE == PBFields::SNOWYM) && !(opponent.moldbroken)
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
    evasion = 100 if attacker.ability == PBAbilities::KEENEYE
    evasion = 100 if @battle.FE == PBFields::ASHENB && (attacker.ability == PBAbilities::OWNTEMPO || attacker.ability == PBAbilities::INNERFOCUS || attacker.ability == PBAbilities::PUREPOWER || attacker.ability == PBAbilities::SANDVEIL || attacker.ability == PBAbilities::STEADFAST) && opponent.ability != PBAbilities::UNNERVE
    return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)
  end

################################################################################
# Damage calculation and modifiers
################################################################################
  def pbCritRate?(attacker,opponent)
    return -1 if (opponent.ability == PBAbilities::BATTLEARMOR || opponent.ability == PBAbilities::SHELLARMOR) && !(opponent.moldbroken)
    return -1 if opponent.pbOwnSide.effects[PBEffects::LuckyChant]>0
    return 3 if attacker.effects[PBEffects::LaserFocus]>0 || @function==0xA0 # Frost Breath
    return 3 if attacker.ability == PBAbilities::MERCILESS && (opponent.status == PBStatuses::POISON || [10,11,19,26].include?(@battle.FE))
    c=0    
    c+=attacker.effects[PBEffects::FocusEnergy]
    c+=1 if hasHighCriticalRate?
    c+=1 if attacker.ability == PBAbilities::SUPERLUCK
    c+=2 if attacker.hasWorkingItem(:STICK) && (attacker.pokemon.species == PBSpecies::FARFETCHD)
    c+=2 if attacker.hasWorkingItem(:LUCKYPUNCH) && (attacker.pokemon.species == PBSpecies::CHANSEY)
    if @battle.FE == PBFields::MIRRORA
      buffs = 0
      buffs = attacker.stages[PBStats::EVASION] if attacker.stages[PBStats::EVASION] > 0
      buffs = buffs.to_i + attacker.stages[PBStats::ACCURACY] if attacker.stages[PBStats::ACCURACY] > 0
      buffs = buffs.to_i - opponent.stages[PBStats::EVASION] if opponent.stages[PBStats::EVASION] < 0
      buffs = buffs.to_i - opponent.stages[PBStats::ACCURACY] if opponent.stages[PBStats::ACCURACY] < 0
      buffs = buffs.to_i
      c += buffs if buffs > 0
    end
    c+=1 if attacker.hasWorkingItem(:RAZORCLAW)
    c+=1 if attacker.hasWorkingItem(:SCOPELENS)
    c+=1 if attacker.speed > opponent.speed && @battle.FE == PBFields::GLITCHF
    c=3 if c>3
    return c
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
  
  def pbCalcDamage(attacker,opponent,options=0, hitnum: 0)
    opponent.damagestate.critical=false
    opponent.damagestate.typemod=0
    opponent.damagestate.calcdamage=0
    opponent.damagestate.hplost=0
    return 0 if @basedamage==0
    if (options&NOCRITICAL)==0
      critchance = pbCritRate?(attacker,opponent)
      if critchance >= 0
        ratios=[24,8,2,1]
        opponent.damagestate.critical= @battle.pbRandom(ratios[critchance])==0
      end
    end
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
    if (options&NOTYPE)==0
      type=pbType(attacker)
    else
      type=-1 # Will be treated as physical
    end
    ##### Calcuate base power of move #####
    basedmg=@basedamage # From PBS file
    basedmg=pbBaseDamage(basedmg,attacker,opponent) # Some function codes alter base power
    damagemult=0x1000
    #classic prep stuff
    attitemworks = attacker.itemWorks?(true)
    oppitemworks = opponent.itemWorks?(true)
    if attacker.ability == PBAbilities::TECHNICIAN
      if basedmg<=60
        damagemult=(damagemult*1.5).round
      elsif @battle.FE == PBFields::FACTORYF && basedmg<=80
        damagemult=(damagemult*1.5).round
      end
    elsif attacker.ability == PBAbilities::STRONGJAW
      damagemult=(damagemult*1.5).round if (PBStuff::BITEMOVE).include?(@id)
    elsif attacker.ability == PBAbilities::TOUGHCLAWS && (@flags&0x01)!=0 # Makes direct contact
      damagemult=(damagemult*1.3).round
    elsif attacker.ability == PBAbilities::IRONFIST && isPunchingMove?
      damagemult=(damagemult*1.2).round
    elsif attacker.ability == PBAbilities::RECKLESS
      if @function==0xFA ||  # Take Down, etc.
        @function==0xFB ||  # Double-Edge, etc.
        @function==0xFC ||  # Head Smash
        @function==0xFD ||  # Volt Tackle
        @function==0xFE ||  # Flare Blitz
        @function==0x10B || # Jump Kick, Hi Jump Kick
        @function==0x130    # Shadow End
        damagemult=(damagemult*1.2).round
      end
    elsif attacker.ability == PBAbilities::FLAREBOOST && (attacker.status==PBStatuses::BURN || @battle.FE == PBFields::BURNINGF) && pbIsSpecial?(type)
      damagemult=(damagemult*1.5).round
    elsif attacker.ability == PBAbilities::TOXICBOOST && (attacker.status==PBStatuses::POISON || @battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF || @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS) && pbIsPhysical?(type)
      damagemult=(damagemult*1.5).round
    elsif attacker.ability == PBAbilities::PUNKROCK && isSoundBased?
      damagemult=(damagemult*1.3).round
    elsif attacker.ability == PBAbilities::RIVALRY && attacker.gender!=2 && opponent.gender!=2
      if attacker.gender==opponent.gender
        damagemult=(damagemult*1.25).round
      else
        damagemult=(damagemult*0.75).round
      end
    elsif (attacker.ability == PBAbilities::MEGALAUNCHER)
      if @id == PBMoves::AURASPHERE || @id == PBMoves::DRAGONPULSE || @id == PBMoves::DARKPULSE || @id == PBMoves::WATERPULSE || @id == PBMoves::ORIGINPULSE
        damagemult=(damagemult*1.5).round
      end
    elsif attacker.ability == PBAbilities::SANDFORCE && (@battle.pbWeather==PBWeather::SANDSTORM || @battle.FE == PBFields::DESERTF|| @battle.FE == PBFields::ASHENB) && (type == PBTypes::ROCK || type == PBTypes::GROUND || type == PBTypes::STEEL)
      damagemult=(damagemult*1.3).round
    elsif attacker.ability == PBAbilities::ANALYTIC && (@battle.battlers.find_all {|battler| battler && battler.hp > 0 && !battler.hasMovedThisRound? }).length == 0
      damagemult = (damagemult*1.3).round
    elsif attacker.ability == PBAbilities::SHEERFORCE && @addlEffect>0
      damagemult=(damagemult*1.3).round
    elsif @type == PBTypes::NORMAL
      if attacker.ability == PBAbilities::AERILATE
        if @battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM # Snowy Mountain && Mountain
          damagemult=(damagemult*1.5).round
        else
          damagemult=(damagemult*1.2).round
        end
      elsif attacker.ability == PBAbilities::GALVANIZE
        if @battle.FE == PBFields::ELECTRICT || @battle.FE == PBFields::FACTORYF # Electric or Factory Fields
          damagemult=(damagemult*1.5).round
        elsif @battle.FE == PBFields::SHORTCIRCUITF # Short-Circuit Field
          damagemult=(damagemult*2).round
        else
          damagemult=(damagemult*1.2).round
        end
      elsif attacker.ability == PBAbilities::PIXILATE
        if @battle.FE == PBFields::MISTYT # Misty Field
          damagemult=(damagemult*1.5).round
        else
          damagemult=(damagemult*1.2).round
        end
      elsif attacker.ability == PBAbilities::DUSKILATE
        damagemult=(damagemult*1.2).round
      elsif attacker.ability == PBAbilities::REFRIGERATE
        if @battle.FE == PBFields::ICYF || @battle.FE == PBFields::SNOWYM # Icy Fields
          damagemult=(damagemult*1.5).round
        else
          damagemult=(damagemult*1.2).round
        end
      end
    elsif attacker.ability == PBAbilities::NORMALIZE
      damagemult=(damagemult*1.2).round
    end
    if opponent.ability == PBAbilities::HEATPROOF && !(opponent.moldbroken) && type == PBTypes::FIRE
      damagemult=(damagemult*0.5).round
    elsif opponent.ability == PBAbilities::DRYSKIN && !(opponent.moldbroken) && type == PBTypes::FIRE
      damagemult=(damagemult*1.25).round
    end
    if attitemworks
      case type
        when PBTypes::NORMAL
          if attacker.item == PBItems::SILKSCARF
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::NORMALGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::FIGHTING
          if attacker.item == PBItems::BLACKBELT || attacker.item == PBItems::FISTPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::FIGHTINGGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::FLYING
          if attacker.item == PBItems::SHARPBEAK || attacker.item == PBItems::SKYPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::FLYINGGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::POISON
          if attacker.item == PBItems::POISONBARB || attacker.item == PBItems::TOXICPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::POISONGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::GROUND
          if attacker.item == PBItems::SOFTSAND || attacker.item == PBItems::EARTHPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::GROUNDGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::ROCK
          if attacker.item == PBItems::HARDSTONE || attacker.item == PBItems::STONEPLATE || attacker.item == PBItems::ROCKINCENSE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::ROCKGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::BUG
          if attacker.item == PBItems::SILVERPOWDER || attacker.item == PBItems::INSECTPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::BUGGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::GHOST
          if attacker.item == PBItems::SPELLTAG || attacker.item == PBItems::SPOOKYPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::GHOSTGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::STEEL
          if attacker.item == PBItems::METALCOAT || attacker.item == PBItems::IRONPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::STEELGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when 9 #?????
        when PBTypes::FIRE
          if attacker.item == PBItems::CHARCOAL || attacker.item == PBItems::FLAMEPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::FIREGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::WATER
          if attacker.item == PBItems::MYSTICWATER || attacker.item == PBItems::SPLASHPLATE || attacker.item == PBItems::SEAINCENSE || attacker.item == PBItems::WAVEINCENSE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::WATERGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::GRASS
          if attacker.item == PBItems::MIRACLESEED || attacker.item == PBItems::MEADOWPLATE || attacker.item == PBItems::ROSEINCENSE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::GRASSGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::ELECTRIC
          if attacker.item == PBItems::MAGNET || attacker.item == PBItems::ZAPPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::ELECTRICGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::PSYCHIC
          if attacker.item == PBItems::TWISTEDSPOON || attacker.item == PBItems::MINDPLATE || attacker.item == PBItems::ODDINCENSE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::PSYCHICGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::ICE
          if attacker.item == PBItems::NEVERMELTICE || attacker.item == PBItems::ICICLEPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::ICEGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::DRAGON
          if attacker.item == PBItems::DRAGONFANG || attacker.item == PBItems::DRACOPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::DRAGONGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::DARK
          if attacker.item == PBItems::BLACKGLASSES || attacker.item == PBItems::DREADPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::DARKGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
        when PBTypes::FAIRY
          if attacker.item == PBItems::PIXIEPLATE
            damagemult=(damagemult*1.2).round
          elsif attacker.item == PBItems::FAIRYGEM
            damagemult=(damagemult*1.3).round
            attacker.takegem=true
          end
      end
      @battle.pbDisplay(_INTL("The {1} strengthened {2}'s power!",PBItems.getName(attacker.item),self.name)) if attacker.takegem==true
      # Muscle Band
      if (attacker.item == PBItems::MUSCLEBAND) && pbIsPhysical?(type)
        damagemult=(damagemult*1.1).round
      # Wise Glasses
      elsif (attacker.item == PBItems::WISEGLASSES) && pbIsSpecial?(type)
        damagemult=(damagemult*1.1).round
      # Legendary Orbs
      elsif attacker.item == PBItems::LUSTROUSORB
        if (attacker.pokemon.species == PBSpecies::PALKIA) && (type == PBTypes::DRAGON || type == PBTypes::WATER)
          damagemult=(damagemult*1.2).round
        end
      elsif attacker.item == PBItems::ADAMANTORB
        if (attacker.pokemon.species == PBSpecies::DIALGA) && (type == PBTypes::DRAGON || type == PBTypes::STEEL)
          damagemult=(damagemult*1.2).round
        end
      elsif attacker.item == PBItems::GRISEOUSORB
        if (attacker.pokemon.species == PBSpecies::GIRATINA) && (type == PBTypes::DRAGON || type == PBTypes::GHOST)
          damagemult=(damagemult*1.2).round
        end
      elsif attacker.item == PBItems::SOULDEW
        if (attacker.pokemon.species == PBSpecies::LATIAS) || (attacker.pokemon.species == PBSpecies::LATIOS) &&
          (type == PBTypes::DRAGON || type == PBTypes::PSYCHIC)
          damagemult=(damagemult*1.2).round
        end
      end
    end
    damagemult=pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if attacker.effects[PBEffects::Charge]>0 && type == PBTypes::ELECTRIC
      damagemult=(damagemult*2.0).round
    end
    if attacker.effects[PBEffects::HelpingHand] && (options&SELFCONFUSE)==0
      damagemult=(damagemult*1.5).round
    end
    # Water/Mud Sport
    if type == PBTypes::FIRE
      if @battle.state.effects[PBEffects::WaterSport]>0
        damagemult=(damagemult*0.33).round
      end
    elsif type == PBTypes::ELECTRIC
      if @battle.state.effects[PBEffects::MudSport]>0
        damagemult=(damagemult*0.33).round
      end
    # Dark Aura/Aurabreak
    elsif type == PBTypes::DARK
      for i in @battle.battlers
        if i.ability == PBAbilities::DARKAURA
          breakaura=0
          for j in @battle.battlers
            if j.ability == PBAbilities::AURABREAK
              breakaura+=1
            end
          end
          if breakaura!=0
            damagemult=(damagemult*2.0/3).round
          else
            damagemult=(damagemult*1.33).round
          end
        end
      end
    # Fairy Aura/Aurabreak
    elsif type == PBTypes::FAIRY
      for i in @battle.battlers
        if i.ability == PBAbilities::FAIRYAURA
          breakaura=0
          for j in @battle.battlers
            if j.ability == PBAbilities::AURABREAK
              breakaura+=1
            end
          end
          if breakaura!=0
            damagemult=(damagemult*2.0/3).round
          else
            damagemult=(damagemult*1.3).round
          end
        end
      end
    end
    # Knock Off
    if @id == PBMoves::KNOCKOFF && opponent.item !=0 && !@battle.pbIsUnlosableItem(opponent,opponent.item)
      damagemult=(damagemult*1.5).round
    end
    # Minimize for z-move
    if @id == PBMoves::MALICIOUSMOONSAULT
      if opponent.effects[PBEffects::Minimize]
        damagemult=(damagemult*2.0).round
      end
    end
    #Specific Field Effects
    if @battle.FE != 0
      fieldmult = moveFieldBoost
      if fieldmult != 1
        damagemult=(damagemult*fieldmult).round
        fieldmessage =moveFieldMessage
        if fieldmessage && !@fieldmessageshown
          if @id == PBMoves::LIGHTTHATBURNSTHESKY #some moves have a {1} in them and we gotta deal.
            @battle.pbDisplay(_INTL(fieldmessage,attacker.pbThis))
          elsif (@id == PBMoves::SMACKDOWN || @id == PBMoves::THOUSANDARROWS ||
            @id == PBMoves::VITALTHROW || @id == PBMoves::CIRCLETHROW ||
            @id == PBMoves::STORMTHROW || @id == PBMoves::DOOMDUMMY || 
            @id == PBMoves::BLACKHOLEECLIPSE || @id == PBMoves::TECTONICRAGE || @id == PBMoves::CONTINENTALCRUSH)
            @battle.pbDisplay(_INTL(fieldmessage,opponent.pbThis))
          else
            @battle.pbDisplay(_INTL(fieldmessage))
          end
          @fieldmessageshown = true
        end
      end
    end
    case @battle.FE
      when 5 # Chess Board
        if (PBFields::CHESSMOVES).include?(@id)
          if (opponent.ability == PBAbilities::ADAPTABILITY) || (opponent.ability == PBAbilities::ANTICIPATION) || (opponent.ability == PBAbilities::SYNCHRONIZE) || (opponent.ability == PBAbilities::TELEPATHY)
            damagemult=(damagemult*0.5).round
          end
          if (opponent.ability == PBAbilities::OBLIVIOUS) || (opponent.ability == PBAbilities::KLUTZ) || (opponent.ability == PBAbilities::UNAWARE) || (opponent.ability == PBAbilities::SIMPLE) || opponent.effects[PBEffects::Confusion]>0
            damagemult=(damagemult*2).round
          end
          @battle.pbDisplay("The chess piece slammed forward!") if !@fieldmessageshown
          @fieldmessageshown = true
        end
        # Queen piece boost
        if attacker.pokemon.piece==:QUEEN || attacker.ability == PBAbilities::QUEENLYMAJESTY
          damagemult=(damagemult*1.5).round
          if attacker.pokemon.piece==:QUEEN
            @battle.pbDisplay("The Queen is dominating the board!")  && !@fieldmessageshown
            @fieldmessageshown = true
          end
        end

        #Knight piece boost
        if attacker.pokemon.piece==:KNIGHT && opponent.pokemon.piece==:QUEEN
          damagemult=(damagemult*3.0).round
          @battle.pbDisplay("An unblockable attack on the Queen!") if !@fieldmessageshown
          @fieldmessageshown = true
        end
      when 6 # Big Top
        if ((type == PBTypes::FIGHTING && pbIsPhysical?(type)) || (PBFields::STRIKERMOVES).include?(@id)) # Continental Crush
          striker = 1+@battle.pbRandom(14)
          @battle.pbDisplay("WHAMMO!") if !@fieldmessageshown
          @fieldmessageshown = true
          if attacker.ability == PBAbilities::HUGEPOWER || attacker.ability == PBAbilities::GUTS || attacker.ability == PBAbilities::PUREPOWER || attacker.ability == PBAbilities::SHEERFORCE
            if striker >=9
              striker = 15
            else
              striker = 14
            end
          end
          strikermod = attacker.stages[PBStats::ATTACK]
          striker = striker + strikermod
          if striker >= 15
            @battle.pbDisplay("...OVER 9000!!!")
            damagemult=(damagemult*3).round
          elsif striker >=13
            @battle.pbDisplay("...POWERFUL!")
            damagemult=(damagemult*2).round
          elsif striker >=9
            @battle.pbDisplay("...NICE!")
            damagemult=(damagemult*1.5).round
          elsif striker >=3
            @battle.pbDisplay("...OK!")
          else
            @battle.pbDisplay("...WEAK!")
            damagemult=(damagemult*0.5).round
          end
        end
        if (@flags&0x400)!= 0
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay("Loud and clear!") if !@fieldmessageshown
          @fieldmessageshown = true
        end
      when 13 # Icy Field
        if (@priority >= 1 && @basedamage > 0 && (@flags&0x01)!=0 && attacker.ability != PBAbilities::LONGREACH) || (@id == PBMoves::FEINT || @id == PBMoves::ROLLOUT || @id == PBMoves::DEFENSECURL || @id == PBMoves::STEAMROLLER || @id == PBMoves::LUNGE)
          if !attacker.isAirborne?
            if attacker.pbCanIncreaseStatStage?(PBStats::SPEED)
              attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
              @battle.pbCommonAnimation("StatUp",attacker,nil)
              @battle.pbDisplay(_INTL("{1} gained momentum on the ice!",attacker.pbThis)) if !@fieldmessageshown
              @fieldmessageshown = true
            end
          end
        end
      when 18 # Shortcircuit Field
        if type == PBTypes::ELECTRIC
          messageroll = ["Bzzt.", "Bzzapp!" , "Bzt...", "Bzap!", "BZZZAPP!"][@battle.field.roll]
          damageroll = @battle.field.getRoll()

          @battle.pbDisplay(messageroll) if !@fieldmessageshown
          damagemult=(damagemult*damageroll).round

          @fieldmessageshown = true
        end
      when 23 # Cave
        if (@flags&0x400)!= 0
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("ECHO-Echo-echo!",opponent.pbThis)) if !@fieldmessageshown
          @fieldmessageshown = true
        end
      when 27 # Mountain
        if (PBFields::WINDMOVES).include?(@id) && @battle.pbWeather==PBWeather::STRONGWINDS
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The wind strengthened the attack!",opponent.pbThis)) if !@fieldmessageshown
          @fieldmessageshown = true
        end
      when 28 # Snowy Mountain
        if (PBFields::WINDMOVES).include?(@id) && @battle.pbWeather==PBWeather::STRONGWINDS
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The wind strengthened the attack!",opponent.pbThis)) if !@fieldmessageshown
          @fieldmessageshown = true
        end
      when 30 # Mirror
        if (PBFields::MIRRORMOVES).include?(@id) && opponent.stages[PBStats::EVASION]>0
          damagemult=(damagemult*2).round
          @battle.pbDisplay(_INTL("The beam was focused from the reflection!",opponent.pbThis)) if !@fieldmessageshown
          @fieldmessageshown = true
        end
        @battle.field.counter = 0
      when 33 # Flower Garden
        if (@id == PBMoves::CUT) && @battle.field.counter > 0
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("{1} was cut down to size!",opponent.pbThis)) if !@fieldmessageshown
          @fieldmessageshown = true
        end
        if (@id == PBMoves::PETALBLIZZARD || @id == PBMoves::PETALDANCE || @id == PBMoves::FLEURCANNON) && @battle.field.counter == 2
          damagemult=(damagemult*1.2).round
          @battle.pbDisplay(_INTL("The fresh scent of flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown
          @fieldmessageshown = true
        end
        if (@id == PBMoves::PETALBLIZZARD || @id == PBMoves::PETALDANCE || @id == PBMoves::FLEURCANNON) && @battle.field.counter > 2
          damagemult=(damagemult*1.5).round
          @battle.pbDisplay(_INTL("The vibrant aroma scent of flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown
          @fieldmessageshown = true
        end
    end
    #End S.Field Effects
    basedmg=(basedmg*damagemult*1.0/0x1000).round
    ##### Calculate attacker's attack stat #####
    atk=attacker.attack
    atkstage=attacker.stages[PBStats::ATTACK]+6
    if @function==0x121 # Foul Play
      atk=opponent.attack
      atkstage=opponent.stages[PBStats::ATTACK]+6
    elsif @function==0x184 # Body Press
      atk=attacker.defense
      atkstage=attacker.stages[PBStats::DEFENSE]+6
    end
    if type>=0 && pbIsSpecial?(type)
      atk=attacker.spatk
      atkstage=attacker.stages[PBStats::SPATK]+6
      if @function==0x121 # Foul Play
        atk=opponent.spatk
        atkstage=opponent.stages[PBStats::SPATK]+6
      end
      if @battle.FE == PBFields::GLITCHF
				atk = attacker.getSpecialStat(opponent.ability == PBAbilities::UNAWARE)
				atkstage = 6 #getspecialstat handles unaware
			end
    end
    if opponent.ability != PBAbilities::UNAWARE || opponent.moldbroken
      atkstage=6 if opponent.damagestate.critical && atkstage<6
      atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
    end
    if attacker.ability == PBAbilities::UNAWARE &&(options&SELFCONFUSE)!=0
       atkstage=attacker.stages[PBStats::ATTACK]+6
       atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
    end
    if attacker.ability == PBAbilities::HUSTLE && pbIsPhysical?(type)
      atk=(atk*1.5).round
    end
    atkmult=0x1000
    if attacker.pbPartner.ability == PBAbilities::POWERSPOT
      atkmult=(atkmult*1.3).round
    end

    if @battle.FE == PBFields::BURNINGF && (attacker.ability == PBAbilities::BLAZE && type == PBTypes::FIRE)
      atkmult=(atkmult*1.5).round
    elsif @battle.FE == PBFields::FORESTF && (attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS)
      atkmult=(atkmult*1.5).round
    elsif @battle.FE == PBFields::FORESTF && (attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG)
      atkmult=(atkmult*1.5).round
    elsif (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER) && (attacker.ability == PBAbilities::TORRENT && type == PBTypes::WATER)
      atkmult=(atkmult*1.5).round
    elsif @battle.FE == PBFields::FLOWERGARDENF && (attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG)
      atkmult=(atkmult*1.5).round if @battle.field.counter == 0 || @battle.field.counter == 1
      atkmult=(atkmult*1.8).round if @battle.field.counter == 2 || @battle.field.counter == 3
      atkmult=(atkmult*2).round if @battle.field.counter == 4
    elsif @battle.FE == PBFields::FLOWERGARDENF && (attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS)
      case @battle.field.counter
        when 1 then atkmult=(atkmult*1.5).round if attacker.hp<=(attacker.totalhp*0.67).floor
        when 2 then atkmult=(atkmult*1.6).round
        when 3 then atkmult=(atkmult*1.8).round
        when 4 then atkmult=(atkmult*2).round
      end
    elsif attacker.hp<=(attacker.totalhp/3.0).floor
      if (attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS) ||
      (attacker.ability == PBAbilities::BLAZE && type == PBTypes::FIRE) ||
      (attacker.ability == PBAbilities::TORRENT && type == PBTypes::WATER) ||
      (attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG)
        atkmult=(atkmult*1.5).round
      end
    end
    case attacker.ability
    when PBAbilities::GUTS
      atkmult=(atkmult*1.5).round if attacker.status!=0 && pbIsPhysical?(type)
    when PBAbilities::PLUS, PBAbilities::MINUS
      if pbIsSpecial?(type) && @battle.FE != 24
        partner=attacker.pbPartner
        if partner.ability == PBAbilities::PLUS || partner.ability == PBAbilities::MINUS
          atkmult=(atkmult*1.5).round
        elsif @battle.FE == PBFields::SHORTCIRCUITF
          atkmult=(atkmult*1.5).round
        end
      end
    when PBAbilities::DEFEATIST
      atkmult=(atkmult*0.5).round if attacker.hp<=(attacker.totalhp/2.0).floor
    when PBAbilities::HUGEPOWER
      atkmult=(atkmult*2.0).round if pbIsPhysical?(type)
    when PBAbilities::PUREPOWER
      if @battle.FE == PBFields::PSYCHICT
        atkmult=(atkmult*2.0).round if pbIsSpecial?(type)
      else
        atkmult=(atkmult*2.0).round if pbIsPhysical?(type)
      end
    when PBAbilities::SOLARPOWER 
      if (@battle.pbWeather==PBWeather::SUNNYDAY && !(attitemworks && attacker.item == PBItems::UTILITYUMBRELLA)) && pbIsSpecial?(type) && @battle.FE != 24
        atkmult=(atkmult*1.5).round
      end
    when PBAbilities::SLOWSTART
      atkmult=(atkmult*0.5).round if attacker.turncount<5 && pbIsPhysical?(type)
    when PBAbilities::GORILLATACTICS 
      atkmult=(atkmult*1.5).round if pbIsPhysical?(type)
    end
    if ((@battle.pbWeather==PBWeather::SUNNYDAY && !(attitemworks && attacker.item == PBItems::UTILITYUMBRELLA)) || @battle.FE == PBFields::FLOWERGARDENF) && pbIsPhysical?(type)
      if attacker.ability == PBAbilities::FLOWERGIFT || attacker.pbPartner.ability == PBAbilities::FLOWERGIFT
        atkmult=(atkmult*1.5).round
      end
    end

    if attacker.pbPartner.hasWorkingAbility(:BATTERY) && pbIsSpecial?(type) && @battle.FE != 24
      atkmult=(atkmult*1.3).round
    end
    if (attacker.pbPartner.ability == PBAbilities::STEELYSPIRIT || attacker.ability == PBAbilities::STEELYSPIRIT) && type == PBTypes::STEEL
      atkmult=(atkmult*1.5).round
    end
    
    atkmult=(atkmult*1.5).round if attacker.effects[PBEffects::FlashFire] && type == PBTypes::FIRE

    if attitemworks
      if attacker.item == PBItems::THICKCLUB 
        atkmult=(atkmult*2.0).round if attacker.pokemon.species == PBSpecies::CUBONE || attacker.pokemon.species == PBSpecies::MAROWAK && pbIsPhysical?(type)
      elsif attacker.item == PBItems::DEEPSEATOOTH 
        atkmult=(atkmult*2.0).round if attacker.pokemon.species == PBSpecies::CLAMPERL && pbIsSpecial?(type) && @battle.FE !=24
      elsif attacker.item == PBItems::LIGHTBALL
        atkmult=(atkmult*2.0).round if attacker.pokemon.species == PBSpecies::PIKACHU && @battle.FE !=24
      elsif attacker.item == PBItems::CHOICEBAND
        atkmult=(atkmult*1.5).round if pbIsPhysical?(type)
      elsif attacker.item == PBItems::CHOICESPECS 
        atkmult=(atkmult*1.5).round if pbIsSpecial?(type) && @battle.FE !=24
      end
    end
    if @battle.FE !=0
      if @battle.FE == PBFields::STARLIGHTA || @battle.FE == PBFields::NEWW
        if attacker.ability == PBAbilities::VICTORYSTAR
          atkmult=(atkmult*1.5).round
        end
        partner=attacker.pbPartner
        if partner && partner.ability == PBAbilities::VICTORYSTAR
          atkmult=(atkmult*1.5).round
        end
      end
      if @battle.FE == PBFields::UNDERWATER 
        atkmult=(atkmult*0.5).round if pbIsPhysical?(type) && type != PBTypes::WATER && attacker.ability != PBAbilities::STEELWORKER
      end
      if attacker.ability == PBAbilities::QUEENLYMAJESTY
        atkmult=(atkmult*1.5).round if @battle.FE == PBFields::FAIRYTALEF
      elsif attacker.ability == PBAbilities::LONGREACH
        atkmult=(atkmult*1.5).round if @battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM
      elsif attacker.ability == PBAbilities::CORROSION
        atkmult=(atkmult*1.5).round if (@battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF)
      end
    end

    if opponent.ability == PBAbilities::THICKFAT && (type == PBTypes::ICE || type == PBTypes::FIRE) && !(opponent.moldbroken)
      atkmult=(atkmult*0.5).round
    end
    atk=(atk*atkmult*1.0/0x1000).round

    ##### Calculate opponent's defense stat #####
    defense=opponent.defense
    defstage=opponent.stages[PBStats::DEFENSE]+6
    # TODO: Wonder Room should apply around here
    
    applysandstorm=false
    if type>=0 && pbHitsSpecialStat?(type)
      defense=opponent.spdef
      defstage=opponent.stages[PBStats::SPDEF]+6
      applysandstorm=true
      if @battle.FE == PBFields::GLITCHF
        defense = opponent.getSpecialStat(attacker.ability == PBAbilities::UNAWARE)
        defstage = 6 # getspecialstat handles unaware
        applysandstorm=false # getSpecialStat handles sandstorm
      end
    end
    if attacker.ability != PBAbilities::UNAWARE
      defstage=6 if @function==0xA9 # Chip Away (ignore stat stages)
      defstage=6 if opponent.damagestate.critical && defstage>6
      defense=(defense*1.0*stagemul[defstage]/stagediv[defstage]).floor
    end
    if @battle.pbWeather==PBWeather::SANDSTORM &&
       opponent.pbHasType?(:ROCK) && applysandstorm
      defense=(defense*1.5).round
    end
    defmult=0x1000

    # Field Effect defense boost
    defmult*=fieldDefenseBoost(type,opponent)

    #Abilities defense boost
    if opponent.ability == PBAbilities::ICESCALES && pbIsSpecial?(type)
      defmult=(defmult*2).round
    end
    if @battle.FE == PBFields::GLITCHF && @function==0xE0
      defmult=(defmult*0.5).round
    end
    if opponent.ability == PBAbilities::MARVELSCALE && pbIsPhysical?(type) &&
      (opponent.status>0 || @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::RAINBOWF ||
      @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::DRAGONSD || @battle.FE == PBFields::STARLIGHTA) && !(opponent.moldbroken)
      defmult=(defmult*1.5).round
    end
    if opponent.ability == PBAbilities::GRASSPELT && pbIsPhysical?(type) &&
    (@battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FORESTF) # Grassy Field
      defmult=(defmult*1.5).round
    end
    if opponent.ability == PBAbilities::FLUFFY && !(opponent.moldbroken)
      if isContactMove? && attacker.ability != PBAbilities::LONGREACH
        defmult=(defmult*2).round
      end
      if type == PBTypes::FIRE
        defmult=(defmult*0.5).round
      end
    end
    if opponent.ability == PBAbilities::FURCOAT && pbIsPhysical?(type) && !(opponent.moldbroken)
      defmult=(defmult*2).round
    end
    if opponent.ability == PBAbilities::PUNKROCK && isSoundBased?
      defmult=(defmult*2).round
    end
    if ((@battle.pbWeather==PBWeather::SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA)) || @battle.FE == PBFields::FLOWERGARDENF) &&
      !(opponent.moldbroken) && pbIsSpecial?(type)
      if opponent.ability == PBAbilities::FLOWERGIFT && opponent.species == PBSpecies::CHERRIM
        defmult=(defmult*1.5).round
      end
      if opponent.pbPartner.ability == PBAbilities::FLOWERGIFT  && opponent.pbPartner.species == PBSpecies::CHERRIM
        defmult=(defmult*1.5).round
      end
    end

    #Item defense boost
    if opponent.hasWorkingItem(:EVIOLITE) && @battle.FE != PBFields::GLITCHF
      evos=pbGetEvolvedFormData(opponent.pokemon.species)
      if evos && evos.length>0
        defmult=(defmult*1.5).round
      end
    end
    #if opponent.item == PBItems::EEVIUMZ2 && opponent.pokemon.species == PBSpecies::EEVEE && @battle.FE != PBFields::GLITCHF
    #  defmult=(defmult*1.5).round
    #end
    if opponent.item == PBItems::PIKANIUMZ2 && opponent.pokemon.species == PBSpecies::PIKACHU && @battle.FE != PBFields::GLITCHF
      defmult=(defmult*1.5).round
    end
    if opponent.item == PBItems::LIGHTBALL && opponent.pokemon.species == PBSpecies::PIKACHU && @battle.FE != PBFields::GLITCHF
      defmult=(defmult*1.5).round
    end
    if opponent.hasWorkingItem(:ASSAULTVEST) && pbIsSpecial?(type) && @battle.FE != PBFields::GLITCHF
      defmult=(defmult*1.5).round
    end
    if opponent.hasWorkingItem(:DEEPSEASCALE) && @battle.FE != PBFields::GLITCHF &&
       (opponent.pokemon.species == PBSpecies::CLAMPERL) && pbIsSpecial?(type)
      defmult=(defmult*2.0).round
    end
    if opponent.hasWorkingItem(:METALPOWDER) && (opponent.pokemon.species == PBSpecies::DITTO) &&
       !opponent.effects[PBEffects::Transform] && pbIsPhysical?(type)
      defmult=(defmult*2.0).round
    end

    # Total defense stat
    defense=(defense*defmult*1.0/0x1000).round

    ##### Main damage calculation #####
    damage=(((2.0*attacker.level/5+2).floor*basedmg*atk/defense).floor/50.0).floor+2
    # Multi-targeting attacks
    if pbTargetsAll?(attacker) || attacker.midwayThroughMove
      if attacker.pokemon.piece == :KNIGHT && battle.FE == PBFields::CHESSB && @target==PBTargets::AllOpposing
        @battle.pbDisplay(_INTL("The knight forked the opponents!")) if !attacker.midwayThroughMove
        damage=(damage*1.25).round
      else
        damage=(damage*0.75).round
      end
      attacker.midwayThroughMove = true
    end
    # Field Effects
    fieldBoost = typeFieldBoost(type,attacker,opponent)
    if fieldBoost != 1
      damage=(damage*fieldBoost).floor
      fieldmessage = typeFieldMessage(type)
      @battle.pbDisplay(_INTL(fieldmessage)) if fieldmessage && !@fieldmessageshown_type
      @fieldmessageshown_type = true
    end
    case @battle.FE
      when PBFields::MOUNTAIN
        if type == PBTypes::FLYING && !pbIsPhysical?(type) && @battle.pbWeather==PBWeather::STRONGWINDS
          damage=(damage*1.5).floor
        end
      when PBFields::SNOWYM
        if type == PBTypes::FLYING && !pbIsPhysical?(type) && @battle.pbWeather==PBWeather::STRONGWINDS
          damage=(damage*1.5).floor
        end
      when PBFields::FLOWERGARDENF
        if type == PBTypes::GRASS
          case @battle.field.counter
            when 1
              damage=(damage*1.1).floor
              @battle.pbDisplay(_INTL("The garden's power boosted the attack!",opponent.pbThis)) if !@fieldmessageshown_type
              @fieldmessageshown_type = true
            when 2
              damage=(damage*1.3).floor
              @battle.pbDisplay(_INTL("The budding flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown_type
              @fieldmessageshown_type = true
            when 3
              damage=(damage*1.5).floor
              @battle.pbDisplay(_INTL("The blooming flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown_type
              @fieldmessageshown_type = true
            when 4
              damage=(damage*2).floor
              @battle.pbDisplay(_INTL("The thriving flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown_type
              @fieldmessageshown_type = true
          end
        end
        if @battle.field.counter > 1
          if type == PBTypes::FIRE
            damage=(damage*1.5).floor
            @battle.pbDisplay(_INTL("The nearby flowers caught flame!",opponent.pbThis)) if !@fieldmessageshown_type
            @fieldmessageshown_type = true
          end
        end
        if @battle.field.counter > 3
          if type == PBTypes::BUG
            damage=(damage*2).floor
            @battle.pbDisplay(_INTL("The attack infested the flowers!",opponent.pbThis)) if !@fieldmessageshown_type
            @fieldmessageshown_type = true
          end
        elsif @battle.field.counter > 1
          if type == PBTypes::BUG
            damage=(damage*1.5).floor
            @battle.pbDisplay(_INTL("The attack infested the garden!",opponent.pbThis)) if !@fieldmessageshown_type
            @fieldmessageshown_type = true
          end
        end
    end
    case @battle.pbWeather
      when PBWeather::SUNNYDAY
        if @battle.state.effects[PBEffects::HarshSunlight] && type == PBTypes::WATER
          @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
          @battle.scene.pbUnVanishSprite(attacker) if @function==0xCB #Dive
          return 0
        end
      when PBWeather::RAINDANCE
        if @battle.state.effects[PBEffects::HeavyRain] && type == PBTypes::FIRE
          @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
          return 0
        end
    end

    # FIELD TRANSFORMATIONS
    fieldmove = @battle.field.moveData(@id)
    if fieldmove && fieldmove[:fieldchange]
      change_conditions = @battle.field.fieldChangeData
      handled = change_conditions[fieldmove[:fieldchange]] ? eval(change_conditions[fieldmove[:fieldchange]]) : true
      if handled  #don't continue if conditions to change are not met
        damage=(damage*1.3).floor if damage >= 0
        #@battle.pbDisplay(_INTL(changeFieldMessage)) if changeFieldMessage
      end
    end
    case @battle.FE
      when PBFields::FACTORYF
        if (@id == PBMoves::DISCHARGE)
          @battle.setField(PBFields::SHORTCIRCUITF)
          @battle.pbDisplay(_INTL("The field shorted out!"))
          damage=(damage*1.3).floor if damage >= 0
        end
      when PBFields::SHORTCIRCUITF
        if (@id == PBMoves::DISCHARGE)
          @battle.setField(PBFields::FACTORYF)
          @battle.pbDisplay(_INTL("SYSTEM ONLINE."))
          damage=(damage*1.3).floor if damage >= 0
        end
    end

    # Weather
    case @battle.pbWeather
      when PBWeather::SUNNYDAY
        if type == PBTypes::FIRE
          damage=(damage*1.5).round
        elsif type == PBTypes::WATER
          damage=(damage*0.5).round
        end
      when PBWeather::RAINDANCE
        if type == PBTypes::FIRE
          damage=(damage*0.5).round
        elsif type == PBTypes::WATER
          damage=(damage*1.5).round
        end
    end
    
    # Critical hits
    if opponent.damagestate.critical
      damage=(damage*1.5).round
      if attacker.ability == PBAbilities::SNIPER
        damage=(damage*1.5).round
      end
    end
    if attacker.ability == PBAbilities::WATERBUBBLE && type == PBTypes::WATER
      damage=(damage*=2).round
    end

    # Random variance
    if (options&NOWEIGHTING)==0 
      if !$game_switches[:No_Damage_Rolls] || @battle.isOnline?
        random=85+@battle.pbRandom(16)
        damage=(damage*random/100.0).floor
      elsif $game_switches[:No_Damage_Rolls] && !@battle.isOnline?
        damage=(damage*0.93).round
      end
    end

    # STAB
    if (attacker.pbHasType?(type) || (attacker.ability == PBAbilities::STEELWORKER && type == PBTypes::STEEL)) && (options&IGNOREPKMNTYPES)==0
      if attacker.ability == PBAbilities::ADAPTABILITY
        damage=(damage*2).round
      elsif (attacker.ability == PBAbilities::STEELWORKER && type == PBTypes::STEEL) && @battle.FE == PBFields::FACTORYF # Factory Field
        damage=(damage*2).round
      else
        damage=(damage*1.5).round
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
    if opponent.ability == PBAbilities::WATERBUBBLE && type == PBTypes::FIRE
      damage=(damage*=0.5).round
    end
    # Burn
    if attacker.status==PBStatuses::BURN && pbIsPhysical?(type) &&
       attacker.ability != PBAbilities::GUTS&& @id != PBMoves::FACADE
      damage=(damage*0.5).round
    end
    # Make sure damage is at least 1
    damage=1 if damage<1
    
    # Final damage modifiers
    finaldamagemult=0x1000
    if !opponent.damagestate.critical && (options&NOREFLECT)==0 &&
       attacker.ability != PBAbilities::INFILTRATOR
      # Reflect
      if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 && pbIsPhysical?(type) && opponent.pbOwnSide.effects[PBEffects::AuroraVeil]==0
        # TODO: should apply even if partner faints during an attack]
        if !opponent.pbPartner.isFainted? || attacker.midwayThroughMove
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
    if ((opponent.ability == PBAbilities::MULTISCALE && !(opponent.moldbroken)) || opponent.ability == PBAbilities::SHADOWSHIELD) && opponent.hp==opponent.totalhp
      finaldamagemult=(finaldamagemult*0.5).round
    end
    if attacker.ability == PBAbilities::TINTEDLENS && opponent.damagestate.typemod<4
      finaldamagemult=(finaldamagemult*2.0).round
    end
    if opponent.pbPartner.ability == PBAbilities::FRIENDGUARD && !(opponent.moldbroken)
      finaldamagemult=(finaldamagemult*0.75).round
    end
    if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter >1
      if (opponent.pbPartner.ability == PBAbilities::FLOWERVEIL && opponent.pbHasType?(:GRASS)) ||
       (opponent.ability == PBAbilities::FLOWERVEIL && !(opponent.moldbroken))
        finaldamagemult=(finaldamagemult*0.75).round
        @battle.pbDisplay(_INTL("The Flower Veil softened the attack!"))
      end
      #if opponent.pbHasType?(:GRASS)
      #  case @battle.field.counter
      #    when 2 then finaldamagemult=(finaldamagemult*0.75).round
      #    when 3 then finaldamagemult=(finaldamagemult*0.67).round
      #    when 4 then finaldamagemult=(finaldamagemult*0.5).round
      #  end
      #end
    end
    if (((opponent.ability == PBAbilities::SOLIDROCK || opponent.ability == PBAbilities::FILTER) && !opponent.moldbroken) ||
       opponent.ability == PBAbilities::PRISMARMOR) && opponent.damagestate.typemod>4
      finaldamagemult=(finaldamagemult*0.75).round
    end
    if opponent.ability == PBAbilities::SHADOWSHIELD && [PBFields::STARLIGHTA, PBFields::NEWW, PBFields::DARKCRYSTALC].include?(@battle.FE)
      finaldamagemult=(finaldamagemult*0.75).round if opponent.damagestate.typemod>4
    end
    if attacker.ability == PBAbilities::STAKEOUT && @battle.switchedOut[opponent.index]
      finaldamagemult=(finaldamagemult*2.0).round
    end
    if (attitemworks && attacker.item == PBItems::METRONOME) && attacker.movesUsed[-2] == attacker.movesUsed[-1]
      if attacker.effects[PBEffects::Metronome]>4
        finaldamagemult=(finaldamagemult*2.0).round
      else
        met=1.0+attacker.effects[PBEffects::Metronome]*0.2
        finaldamagemult=(finaldamagemult*met).round
      end
    end
    if (attitemworks && attacker.item == PBItems::EXPERTBELT) && opponent.damagestate.typemod > 4
      finaldamagemult=(finaldamagemult*1.2).round
    end
    if (attacker.ability == PBAbilities::NEUROFORCE) && opponent.damagestate.typemod > 4
      finaldamagemult=(finaldamagemult*1.25).round
    end
    
    if (attitemworks && attacker.item == PBItems::LIFEORB)
      finaldamagemult=(finaldamagemult*1.3).round
    end
    if opponent.damagestate.typemod>4 && (options&IGNOREPKMNTYPES)==0 && opponent.itemWorks? && opponent.effects[PBEffects::Substitute]==0
      hasberry = false
      case type
        when PBTypes::FIGHTING   then hasberry = opponent.item == PBItems::CHOPLEBERRY
        when PBTypes::FLYING     then hasberry = opponent.item == PBItems::COBABERRY
        when PBTypes::POISON     then hasberry = opponent.item == PBItems::KEBIABERRY
        when PBTypes::GROUND     then hasberry = opponent.item == PBItems::SHUCABERRY
        when PBTypes::ROCK       then hasberry = opponent.item == PBItems::CHARTIBERRY
        when PBTypes::BUG        then hasberry = opponent.item == PBItems::TANGABERRY
        when PBTypes::GHOST      then hasberry = opponent.item == PBItems::KASIBBERRY
        when PBTypes::STEEL      then hasberry = opponent.item == PBItems::BABIRIBERRY
        when PBTypes::FIRE       then hasberry = opponent.item == PBItems::OCCABERRY
        when PBTypes::WATER      then hasberry = opponent.item == PBItems::PASSHOBERRY
        when PBTypes::GRASS      then hasberry = opponent.item == PBItems::RINDOBERRY
        when PBTypes::ELECTRIC   then hasberry = opponent.item == PBItems::WACANBERRY
        when PBTypes::PSYCHIC    then hasberry = opponent.item == PBItems::PAYAPABERRY
        when PBTypes::ICE        then hasberry = opponent.item == PBItems::YACHEBERRY
        when PBTypes::DRAGON     then hasberry = opponent.item == PBItems::HABANBERRY
        when PBTypes::DARK       then hasberry = opponent.item == PBItems::COLBURBERRY
        when PBTypes::FAIRY      then hasberry = opponent.item == PBItems::ROSELIBERRY
      end
      if hasberry
        if opponent.ability == PBAbilities::RIPEN
          finaldamagemult=(finaldamagemult*0.25).round
        else
          finaldamagemult=(finaldamagemult*0.5).round
        end
        opponent.pbDisposeItem(true)
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("{2}'s {1} weakened the damage from the attack!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
        else
          @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
        end
      end
    end
    if opponent.hasWorkingItem(:CHILANBERRY) && type == PBTypes::NORMAL && (options&IGNOREPKMNTYPES)==0  && opponent.itemWorks? && opponent.effects[PBEffects::Substitute]==0
      if opponent.ability == PBAbilities::RIPEN
        finaldamagemult=(finaldamagemult*0.25).round
      else
        finaldamagemult=(finaldamagemult*0.5).round
      end
      opponent.pbDisposeItem(true)
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("{2}'s {1} weakened the damage from the attack!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
      else
        @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
      end
    end
    finaldamagemult=pbModifyDamage(finaldamagemult,attacker,opponent)
    damage=(damage*finaldamagemult*1.0/0x1000).round
    opponent.damagestate.calcdamage=damage
    return damage
  end

  def pbReduceHPDamage(damage,attacker,opponent)
    endure=false
    moveid1=PBMoves::FUTUREDUMMY
    moveid2=PBMoves::DOOMDUMMY
    if (@id == moveid1 || @id == moveid2)
      if attacker.effects[PBEffects::LaserFocus] ==0
        damage=pbCalcDamage(attacker,opponent,PokeBattle_Move::NOCRITICAL)
      else
        damage=pbCalcDamage(attacker,opponent)
      end
    end
    if opponent.effects[PBEffects::Substitute]>0 && (!attacker || attacker.index!=opponent.index) &&
     attacker.ability != PBAbilities::INFILTRATOR && !isSoundBased? && 
     @id!=PBMoves::SPECTRALTHIEF &&  @id!=PBMoves::HYPERSPACEHOLE &&  @id!=PBMoves::HYPERSPACEFURY #spectral thief/ hyperspace hole/ hyperspace fury
      damage=opponent.effects[PBEffects::Substitute] if damage>opponent.effects[PBEffects::Substitute]
      opponent.effects[PBEffects::Substitute]-=damage
      opponent.damagestate.substitute=true
      if damage > 0
        @battle.scene.pbDamageAnimation(opponent,0)
        @battle.pbDisplay(_INTL("The substitute took damage for {1}!",opponent.name))
        if opponent.effects[PBEffects::Substitute]<=0
          opponent.effects[PBEffects::Substitute]=0
          @battle.scene.pbUnSubstituteSprite(opponent,opponent.pbIsOpposing?(1))
          @battle.pbDisplay(_INTL("{1}'s substitute faded!",opponent.name))
        end
      end
      opponent.damagestate.hplost=damage
      damage=0
    elsif opponent.effects[PBEffects::Disguise] && (!attacker || attacker.index!=opponent.index) &&
      opponent.effects[PBEffects::Substitute]<=0 && opponent.damagestate.typemod!=0 && !opponent.moldbroken
      opponent.pbBreakDisguise
      @battle.pbDisplay(_INTL("{1}'s Disguise was busted!",opponent.name))
      opponent.effects[PBEffects::Disguise]=false
      damage=0
    elsif opponent.effects[PBEffects::IceFace] && pbIsPhysical?(type) && (!attacker || attacker.index!=opponent.index) &&
      opponent.effects[PBEffects::Substitute]<=0 && opponent.damagestate.typemod!=0 && !opponent.moldbroken
      opponent.pbBreakDisguise
      @battle.pbDisplay(_INTL("{1} transformed!",opponent.name))
      opponent.effects[PBEffects::IceFace]=false
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
        elsif damage==opponent.totalhp && @battle.FE == PBFields::CHESSB && opponent.pokemon.piece==:PAWN && !opponent.damagestate.pawnsturdyused
          opponent.damagestate.pawnsturdyused = true
          opponent.damagestate.pawnsturdy = true
          damage=damage-1
        elsif damage==opponent.totalhp && opponent.ability == PBAbilities::STURDY && !opponent.moldbroken
          opponent.damagestate.sturdy=true
          damage=damage-1
        elsif opponent.damagestate.focussash && damage==opponent.totalhp && opponent.item!=0
          opponent.damagestate.focussashused=true
          damage=damage-1
          opponent.pbDisposeItem(false)
        elsif opponent.damagestate.focusband
          opponent.damagestate.focusbandused=true
          damage=damage-1
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
    end
    return damage
  end

################################################################################
# Effects
################################################################################
  def pbEffectMessages(attacker,opponent,ignoretype=false)
    if opponent.damagestate.critical
      @battle.pbDisplay(_INTL("A critical hit!"))
    end
    if !pbIsMultiHit && !attacker.effects[PBEffects::ParentalBond]
      if opponent.damagestate.typemod>4
        @battle.pbDisplay(_INTL("It's super effective!"))
      elsif opponent.damagestate.typemod>=1 && opponent.damagestate.typemod<4
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
    end
    if opponent.damagestate.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!",opponent.pbThis))
    elsif opponent.damagestate.pawnsturdy
      opponent.damagestate.pawnsturdy=false
      @battle.pbDisplay(_INTL("{1} hung on the edge of the board!",opponent.pbThis))
    elsif opponent.damagestate.sturdy
      @battle.pbDisplay(_INTL("{1} hung on with Sturdy!",opponent.pbThis))
      opponent.damagestate.sturdy=false
    elsif opponent.damagestate.focussashused
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",opponent.pbThis))
      opponent.damagestate.focussashused=false
    elsif opponent.damagestate.focusbandused
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",opponent.pbThis))
    end
  end

  def pbEffectFixedDamage(damage,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=pbType(attacker)
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
    if @id == PBMoves::GUARDIANOFALOLA
      return pbEffectFixedDamage((opponent.hp*3.0/4).floor,attacker,opponent,hitnum,alltargets,showanimation)
    elsif @id == PBMoves::EXTREMEEVOBOOST  
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
          attacker.pbIncreaseStat(stat,2)
        end
      end
      return 0            
    end
    
    damage=pbCalcDamage(attacker,opponent,hitnum: hitnum)
    
    damage *= 1.5 if attacker.effects[PBEffects::MeFirst]
    damage /= 4 if hitnum == 1 && attacker.effects[PBEffects::ParentalBond] && pbNumHits(attacker)==1
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
    damage=pbReduceHPDamage(damage,attacker,opponent)
    pbEffectMessages(attacker,opponent)
    pbOnDamageLost(damage,attacker,opponent)
    pbZMoveEffects(attacker,opponent) if (opponent.damagestate.typemod!=0 && @id > 10000)
    return damage   # The HP lost by the opponent due to this attack
  end

  def positivePriority?(attacker)
    pri = @priority
    pri = 0 if @zmove && @basedamage > 0
    pri += 1 if @battle.FE == PBFields::CHESSB && attacker.pokemon && attacker.pokemon.piece == :KING
    pri += 1 if attacker.ability == PBAbilities::PRANKSTER && @basedamage==0 && attacker.effects[PBEffects::TwoTurnAttack] == 0 # Is status move
    pri += 1 if attacker.ability == PBAbilities::GALEWINGS && @type==PBTypes::FLYING && ((attacker.hp == attacker.totalhp) || ((@battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM) && @battle.weather == PBWeather::STRONGWINDS))
    pri += 3 if attacker.ability == PBAbilities::TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@function)
    return pri > 0
  end

  def pbIsPriorityMoveAI(attacker)
    if @id==PBMoves::FAKEOUT || @id==PBMoves::FIRSTIMPRESSION
      return false if attacker.turncount != 0
    end
    return positivePriority?(attacker)
  end

################################################################################
# cass's lazy field effect thingy section (i never said i knew what i was doing)
################################################################################
  def ignitecheck
    return @battle.state.effects[PBEffects::WaterSport] <= 0 && @battle.pbWeather != PBWeather::RAINDANCE
  end

  def suncheck
    return false
  end

  #def mistExplosion
  #  return !@battle.pbCheckGlobalAbility(:DAMP)
  #end

################################################################################
# Using the move
################################################################################
  def pbOnStartUse(attacker)
    return true
  end

  def pbAddTarget(targets,attacker)
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
    type=pbType(attacker)
    if opponent.effects[PBEffects::Bide]>0
      opponent.effects[PBEffects::BideDamage]+=damage
      opponent.effects[PBEffects::BideTarget]=attacker.index
    end
    if pbIsPhysical?(type) && opponent.effects[PBEffects::ShellTrap]==true
      opponent.effects[PBEffects::ShellTrapTarget]=attacker.index
    end
    if @function==0x90 # Hidden Power
      type=(PBTypes::NORMAL) || 0
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