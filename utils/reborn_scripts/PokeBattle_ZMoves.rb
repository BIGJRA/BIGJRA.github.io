class PokeBattle_ZMoves < PokeBattle_Move
  attr_accessor(:id)
  attr_reader(:battle)
  attr_reader(:name)
  attr_reader(:function)
# UPDATE 11/21/2013
# Changed from immutable to mutable to allow for sheer force
# changed from: attr_reader(:basedamage)
  attr_accessor(:basedamage)
  attr_reader(:type)
  attr_reader(:accuracy)
  attr_reader(:addlEffect)
  attr_reader(:target)
  attr_reader(:priority)
  attr_reader(:flags)
  attr_reader(:category)
  attr_reader(:thismove)
  attr_accessor(:pp)
  attr_accessor(:totalpp)
  attr_reader(:oldmove)
  attr_reader(:status)
  attr_reader(:oldname)
  attr_accessor(:zmove)

################################################################################
# Z Move data
################################################################################

  def pbZMoveId(oldmove,crystal)
    if @status
      return oldmove.id
    else
      crystal_to_zmove ={                                         PBItems::NORMALIUMZ2 => PBMoves::BREAKNECKBLITZ,
      PBItems::FIGHTINIUMZ2 => PBMoves::ALLOUTPUMMELING,          PBItems::FLYINIUMZ2 => PBMoves::SUPERSONICSKYSTRIKE,
      PBItems::POISONIUMZ2 => PBMoves::ACIDDOWNPOUR,              PBItems::GROUNDIUMZ2 => PBMoves::TECTONICRAGE,
      PBItems::ROCKIUMZ2 => PBMoves::CONTINENTALCRUSH,            PBItems::BUGINIUMZ2 => PBMoves::SAVAGESPINOUT,
      PBItems::GHOSTIUMZ2 => PBMoves::NEVERENDINGNIGHTMARE,       PBItems::STEELIUMZ2 => PBMoves::CORKSCREWCRASH,
      PBItems::FIRIUMZ2 => PBMoves::INFERNOOVERDRIVE,             PBItems::WATERIUMZ2 => PBMoves::HYDROVORTEX,
      PBItems::GRASSIUMZ2 => PBMoves::BLOOMDOOM,                  PBItems::ELECTRIUMZ2 => PBMoves::GIGAVOLTHAVOC,
      PBItems::PSYCHIUMZ2 => PBMoves::SHATTEREDPSYCHE,            PBItems::ICIUMZ2 => PBMoves::SUBZEROSLAMMER,
      PBItems::DRAGONIUMZ2 => PBMoves::DEVASTATINGDRAKE,          PBItems::DARKINIUMZ2 => PBMoves::BLACKHOLEECLIPSE,
      PBItems::FAIRIUMZ2 => PBMoves::TWINKLETACKLE,               PBItems::ALORAICHIUMZ2 => PBMoves::STOKEDSPARKSURFER,
      PBItems::DECIDIUMZ2 => PBMoves::SINISTERARROWRAID,          PBItems::INCINIUMZ2 => PBMoves::MALICIOUSMOONSAULT,
      PBItems::PRIMARIUMZ2 => PBMoves::OCEANICOPERETTA,           PBItems::EEVIUMZ2 => PBMoves::EXTREMEEVOBOOST,
      PBItems::PIKANIUMZ2 => PBMoves::CATASTROPIKA,               PBItems::SNORLIUMZ2 => PBMoves::PULVERIZINGPANCAKE,
      PBItems::MEWNIUMZ2 => PBMoves::GENESISSUPERNOVA,            PBItems::TAPUNIUMZ2 => PBMoves::GUARDIANOFALOLA,
      PBItems::MARSHADIUMZ2 => PBMoves::SOULSTEALING7STARSTRIKE,  PBItems::KOMMONIUMZ2 => PBMoves::CLANGOROUSSOULBLAZE,
      PBItems::LYCANIUMZ2 => PBMoves::SPLINTEREDSTORMSHARDS,      PBItems::MIMIKIUMZ2 => PBMoves::LETSSNUGGLEFOREVER,
      PBItems::SOLGANIUMZ2 => PBMoves::SEARINGSUNRAZESMASH,       PBItems::LUNALIUMZ2 => PBMoves::MENACINGMOONRAZEMAELSTROM,
      PBItems::ULTRANECROZIUMZ2 => PBMoves::LIGHTTHATBURNSTHESKY
      }
      return crystal_to_zmove[crystal]
    end
  end

  ZMOVENAMES = ["Breakneck Blitz","All-Out Pummeling","Supersonic Skystrike","Acid Downpour","Tectonic Rage",
  "Continental Crush","Savage Spin-Out","Never-Ending Nightmare","Corkscrew Crash","Inferno Overdrive",
  "Hydro Vortex","Bloom Doom","Gigavolt Havoc","Shattered Psyche","Subzero Slammer",
  "Devastating Drake","Black Hole Eclipse","Twinkle Tackle","Stoked Sparksurfer","Sinister Arrow Raid",
  "Malicious Moonsault","Oceanic Operetta","Extreme Evoboost","Catastropika","Pulverizing Pancake",
  "Genesis Supernova","Guardian of Alola","Soul-Stealing 7-Star Strike","Clangorous Soulblaze","Splintered Stormshards",
  "Let's Snuggle Forever","Searing Sunraze Smash","Menacing Moonraze Maelstrom","Light That Burns The Sky"]

  ZMOVEFLAGS = ["f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","af","f","","","af","af","","af","kf","f","f","f","f","f"] #good luck

################################################################################
# Creating a z move
################################################################################
  def initialize(battle,battler,move,crystal,simplechoice=false)
    @status     = !(move.pbIsPhysical?(move.type) || move.pbIsSpecial?(move.type))

    @oldmove    = move
    @oldname    = move.name
    @id         = pbZMoveId(move,crystal)
    @battle     = battle
    @name       = pbZMoveName(move,@id)
    # Get data on the move
    oldmovedata = PBMoveData.new(move.id)
    @function   = pbZMoveFunction(move,crystal)
    @basedamage = pbZMoveBaseDamage(move,crystal)
    @type       = move.type
    @accuracy   = pbZMoveAccuracy(move,crystal)
    @addlEffect = 0 #pbZMoveAddlEffectChance(move,crystal)
    if crystal == PBItems::KOMMONIUMZ2
      @target   = PBTargets::AllOpposing
    else
      @target   = move.target
      @target   = PBTargets::SingleNonUser if @basedamage > 0
    end
    @priority   = @oldmove.priority
    @flags      = pbZMoveFlags(move,@id)
    @category   = oldmovedata.category
    @category   = move.pbIsPhysical?(move.type) ? 0 : 1 if @id == PBMoves::LIGHTTHATBURNSTHESKY
    @pp         = 1
    @totalpp    = 1
    @thismove   = self #move
    @zmove      = true
    if !@status
      @priority = 0
    end
    battler.pbBeginTurn(self)
    if !@status
      @battle.pbDisplayBrief(_INTL("{1} unleashed its full force Z-Move!",battler.pbThis))
      @battle.pbDisplayBrief(_INTL("{1}!",@name))
    end
    zchoice=@battle.choices[battler.index] #[0,0,move,move.target]
    zchoice[2]=self
    zchoice[2]=oldmove if @basedamage == 0
    if simplechoice!=false
      zchoice=simplechoice
    end
    ztargets=[]
    user=battler.pbFindUser(zchoice,ztargets)
    user.lastRoundMoved = @battle.turncount
    if @thismove.target==PBTargets::AllOpposing && crystal==PBItems::KOMMONIUMZ2 && ztargets.length!=0
      user.pbAddTarget(ztargets,ztargets[0].pbPartner)
    end
    if user.hasWorkingAbility(:MOLDBREAKER) || user.hasWorkingAbility(:TERAVOLT) || user.hasWorkingAbility(:TURBOBLAZE) ||
       @id==PBMoves::SEARINGSUNRAZESMASH || @id==PBMoves::MENACINGMOONRAZEMAELSTROM || @id==PBMoves::LIGHTTHATBURNSTHESKY # Solgaluna/crozma signatures
      for battlers in ztargets
        battlers.moldbroken = true
      end
    else
      for battlers in ztargets
        battlers.moldbroken = false
      end
    end
    for target in ztargets
      target.damagestate.reset
      if target.hasWorkingItem(:FOCUSBAND) && @battle.pbRandom(10)==0
        target.damagestate.focusband=true
      end
      if target.hasWorkingItem(:FOCUSSASH)
        target.damagestate.focussash=true
      end
    end
    protype=@type
    if battler.ability == PBAbilities::PROTEAN || battler.ability == PBAbilities::LIBERO
      prot1 = battler.type1
      prot2 = battler.type2
      if !battler.pbHasType?(protype) || (defined?(prot2) && prot1 != prot2)
        battler.type1=protype
        battler.type2=protype
        typename=PBTypes.getName(protype)
        @battle.pbDisplay(_INTL("{1} had its type changed to {3}!",battler.pbThis,PBAbilities.getName(battler.ability),typename))
      end
    end
    if isConst?(battler.ability, PBAbilities, :STANCECHANGE)
      battler.pbCheckForm(self)
    end
    ###
    if ztargets.length==0
      if @thismove.target==PBTargets::SingleNonUser ||
         @thismove.target==PBTargets::RandomOpposing ||
         @thismove.target==PBTargets::AllOpposing ||
         @thismove.target==PBTargets::AllNonUsers ||
         @thismove.target==PBTargets::Partner ||
         @thismove.target==PBTargets::UserOrPartner ||
         @thismove.target==PBTargets::SingleOpposing ||
         @thismove.target==PBTargets::OppositeOpposing
        @battle.pbDisplay(_INTL("But there was no target..."))
      else
        #selftarget status moves here
        pbZStatus(@id,battler)
        zchoice[2].name = @name
        battler.pbUseMove(zchoice)
        @oldmove.name = @oldname
      end
    else
      if @status
        #targeted status Z's here
        pbZStatus(@id,battler)
        zchoice[2].name = @name
        battler.pbUseMove(zchoice)
        @oldmove.name = @oldname
      else
        movesucceeded=false
        showanimation=true
        flags = {totaldamage: 0}
        #looping through all targets
        for i in 0...ztargets.length
          userandtarget=[user,ztargets[i]]
          if battler.effects[PBEffects::Powder] && (thismove.type == PBTypes::FIRE)
            @battle.pbDisplay(_INTL("The powder around {1} exploded!",battler.pbThis))
            @battle.pbCommonAnimation("Powder",battler,nil)
            battler.pbReduceHP((battler.totalhp/4.0).floor)
            battler.pbFaint if battler.hp<1
            zchoice[2]=oldmove
            return false
          end
          success = battler.pbChangeTarget(@thismove,userandtarget,ztargets)
          next if !success
          hitcheck = battler.pbProcessMoveAgainstTarget(@thismove,user,ztargets[i],1,flags,false,nil,showanimation) #This is the problem
          showanimation=false unless (hitcheck==0 && (@thismove.pbIsSpecial?(thismove.type) || @thismove.pbIsPhysical?(thismove.type)))
          movesucceeded = true if hitcheck && hitcheck > 0
        end
        if movesucceeded
          if @id == PBMoves::CLANGOROUSSOULBLAZE
            if !user.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
              !user.pbCanIncreaseStatStage?(PBStats::SPDEF,false) &&
              !user.pbCanIncreaseStatStage?(PBStats::SPEED,false) &&
              !user.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
              !user.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
              @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
            end
            for stat in 1..5
              if user.pbCanIncreaseStatStage?(stat,false)
                user.pbIncreaseStat(stat,1,abilitymessage:false)
              end
            end
          end
          if user.forcedSwitch == true
            #remove gem when forced switching out mid attack
            user.forcedSwitch = false
            party=@battle.pbParty(user.index)
            j=-1
            until j!=-1
              j=@battle.pbRandom(party.length)
              if !((user.isFainted? || j!=user.pokemonIndex) && (user.pbPartner.isFainted? || j!=user.pbPartner.pokemonIndex) && party[j] && !party[j].isEgg? && party[j].hp>0)
                  j=-1
              end
              if !@battle.pbCanSwitchLax?(user.index,j,false)
                j=-1
              end
            end
            newpoke=j
            user.vanished=false
            user.pbResetForm
            @battle.pbReplace(user.index,newpoke,false)
            @battle.pbDisplay(_INTL("{1} was dragged out!",user.pbThis))
            @battle.pbOnActiveOne(user)
            user.pbAbilitiesOnSwitchIn(true)
            user.forcedSwitchEarlier = true
          end
        end
        @battle.fieldEffectAfterMove(@thismove)
        battler.pbReducePPOther(@oldmove)
        for i in 0...ztargets.length
          if ztargets[i].userSwitch == true
            ztargets[i].userSwitch = false
            @battle.pbDisplay(_INTL("{1} went back to {2}!",ztargets[i].pbThis,@battle.pbGetOwner(ztargets[0].index).name))
            newpoke=0
            newpoke=@battle.pbSwitchInBetween(ztargets[i].index,true,false)
            @battle.pbMessagesOnReplace(ztargets[i].index,newpoke)
            ztargets[i].vanished=false
            ztargets[i].pbResetForm
            @battle.pbReplace(ztargets[i].index,newpoke,false)
            @battle.pbOnActiveOne(ztargets[i])
            ztargets[i].pbAbilitiesOnSwitchIn(true)
          end
        end
        # End of move usage
        @battle.pbGainEXP
        battler.pbEndTurn(zchoice)
        @battle.pbJudgeSwitch
      end
    end
    zchoice[2]=oldmove
  end

  def pbZMoveName(oldmove,crystal)
    if @status
      return "Z-" + oldmove.name
    else
      PokeBattle_ZMoves::ZMOVENAMES[id-10001]
    end
  end

  def pbZMoveFunction(oldmove,crystal)
    if @status
      return oldmove.function
    else
      "Z"
    end
  end

  def pbZMoveBaseDamage(oldmove,crystal)
    if @status
      return 0
    else
      case crystal
      when PBItems::ALORAICHIUMZ2    then return 175
      when PBItems::DECIDIUMZ2       then return 180
      when PBItems::INCINIUMZ2       then return 180
      when PBItems::PRIMARIUMZ2      then return 195
      when PBItems::EEVIUMZ2         then return 0
      when PBItems::PIKANIUMZ2       then return 210
      when PBItems::SNORLIUMZ2       then return 210
      when PBItems::MEWNIUMZ2        then return 185
      when PBItems::TAPUNIUMZ2       then return 0
      when PBItems::MARSHADIUMZ2     then return 195
      when PBItems::KOMMONIUMZ2      then return 185
      when PBItems::LYCANIUMZ2       then return 190
      when PBItems::MIMIKIUMZ2       then return 190
      when PBItems::SOLGANIUMZ2      then return 200
      when PBItems::LUNALIUMZ2       then return 200
      when PBItems::ULTRANECROZIUMZ2 then return 200
      else
        case @oldmove.id
        when PBMoves::MEGADRAIN      then return 120
        when PBMoves::WEATHERBALL    then return 160
        when PBMoves::HEX            then return 160
        when PBMoves::GEARGRIND      then return 180
        when PBMoves::VCREATE        then return 220
        when PBMoves::FLYINGPRESS    then return 170
        when PBMoves::COREENFORCER   then return 140
        # Variable Power Moves from now
        when PBMoves::CRUSHGRIP      then return 190
        when PBMoves::FLAIL          then return 160
        when PBMoves::FRUSTRATION    then return 160
        when PBMoves::NATURALGIFT    then return 160
        when PBMoves::PRESENT        then return 100
        when PBMoves::RETURN         then return 160
        when PBMoves::SPITUP         then return 100
        when PBMoves::TRUMPCARD      then return 160
        when PBMoves::WRINGOUT       then return 190
        when PBMoves::BEATUP         then return 100
        when PBMoves::FLING          then return 100
        when PBMoves::POWERTRIP      then return 160
        when PBMoves::PUNISHMENT     then return 160
        when PBMoves::ELECTROBALL    then return 160
        when PBMoves::ERUPTION       then return 200
        when PBMoves::HEATCRASH      then return 160
        when PBMoves::GRASSKNOT      then return 160
        when PBMoves::GYROBALL       then return 160
        when PBMoves::HEAVYSLAM      then return 160
        when PBMoves::LOWKICK        then return 160
        when PBMoves::REVERSAL       then return 160
        when PBMoves::MAGNITUDE      then return 140
        when PBMoves::STOREDPOWER    then return 160
        when PBMoves::WATERSPOUT     then return 200
        else
          check=@oldmove.basedamage
          if check<56
            return 100
          elsif check<66
            return 120
          elsif check<76
            return 140
          elsif check<86
            return 160
          elsif check<96
            return 175
          elsif check<101
            return 180
          elsif check<111
            return 185
          elsif check<126
            return 190
          elsif check<131
            return 195
          elsif check>139
            return 200
          end
        end
      end
    end
  end

  def pbZMoveAccuracy(oldmove,crystal)
    if @status
      return oldmove.accuracy
    else
      return 0 #Z Moves can't miss
    end
  end


  def pbZMoveFlags(oldmove,id)
    if @status
      return oldmove.flags
    else
      flaglist = 0
      tempflag = PokeBattle_ZMoves::ZMOVEFLAGS[id-10001]
      flaglist|=1 if tempflag.include?("a")
      flaglist|=2 if tempflag.include?("b")
      flaglist|=4 if tempflag.include?("c")
      flaglist|=8 if tempflag.include?("d")
      flaglist|=16 if tempflag.include?("e")
      flaglist|=32 if tempflag.include?("f")
      flaglist|=64 if tempflag.include?("g")
      flaglist|=128 if tempflag.include?("h")
      flaglist|=256 if tempflag.include?("i")
      flaglist|=512 if tempflag.include?("j")
      flaglist|=1024 if tempflag.include?("k")
      flaglist|=2048 if tempflag.include?("l")
      flaglist|=4096 if tempflag.include?("m")
      flaglist|=8192 if tempflag.include?("n")
      flaglist|=16384 if tempflag.include?("o")
      flaglist|=32768 if tempflag.include?("p")
      return flaglist
    end
  end

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

################################################################################
# PokeBattle_Move Features needed for move use
################################################################################
  def pbModifyDamage(damagemult,attacker,opponent)
    if !opponent.effects[PBEffects::ProtectNegation] && (opponent.pbOwnSide.effects[PBEffects::MatBlock] ||
      opponent.effects[PBEffects::Protect] || opponent.effects[PBEffects::KingsShield] ||
      opponent.effects[PBEffects::SpikyShield] || opponent.effects[PBEffects::BanefulBunker] ||
      opponent.pbOwnSide.effects[PBEffects::WideGuard] && (@target == PBTargets::AllOpposing || @target == PBTargets::AllNonUsers))
      @battle.pbDisplay(_INTL("{1} couldn't fully protect itself!",opponent.pbThis))
      return (damagemult/4.0).floor
    else
      return damagemult
    end
  end

  def pbZMoveEffects(attacker,opponent)
    if @id == PBMoves::STOKEDSPARKSURFER
      if opponent.pbCanParalyze?(false)
        opponent.pbParalyze(attacker)
        @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
      end
      if @battle.canChangeFE?(PBFields::ELECTRICT)
        @battle.setField(PBFields::ELECTRICT,true)
        @battle.field.duration=3
        @battle.pbDisplay(_INTL("The terrain became electrified!"))
      end
    elsif @id == PBMoves::BLOOMDOOM
      if @battle.canChangeFE?([PBFields::GRASSYT,PBFields::FORESTF,PBFields::FLOWERGARDENF])
        @battle.setField(PBFields::GRASSYT,true)
        @battle.field.duration=3
        @battle.pbDisplay(_INTL("The terrain became grassy!"))
      elsif @battle.fieldeffect == PBFields::FLOWERGARDENF
        @battle.growField("Bloom Doom")
      end
    elsif @id == PBMoves::ACIDDOWNPOUR
      if @battle.FE == PBFields::WASTELAND # Wasteland
        if ((!opponent.pbHasType?(:POISON) && !opponent.pbHasType?(:STEEL)) || opponent.corroded) &&
         !(opponent.ability == PBAbilities::TOXICBOOST) &&
         !(opponent.ability == PBAbilities::POISONHEAL) &&
         (!(opponent.ability == PBAbilities::IMMUNITY) && !(opponent.moldbroken))
          rnd=@battle.pbRandom(4)
          case rnd
          when 0
            if opponent.pbCanBurn?(false)
              opponent.pbBurn(attacker)
              @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
            end
          when 1
            if opponent.pbCanFreeze?(false)
              opponent.pbFreeze
              @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
            end
          when 2
            if opponent.pbCanParalyze?(false)
              opponent.pbParalyze(attacker)
              @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
            end
          when 3
            if opponent.pbCanPoison?(false)
              opponent.pbPoison(attacker)
              @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
            end
          end
        end
      elsif @battle.FE == PBFields::UNDERWATER # Underwater
        @battle.setField(PBFields::MURKWATERS)
        @battle.pbDisplay(_INTL("The water was polluted!"))
        @battle.pbDisplay(_INTL("The grime sank beneath the battlers!"))
      elsif @battle.FE == PBFields::FLOWERGARDENF # Flower Garden Field
        if @battle.field.counter>0
          @battle.field.counter = 0
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The acid melted the bloom!"))
        end
      end
    elsif @id == PBMoves::GENESISSUPERNOVA && @battle.canChangeFE?(PBFields::PSYCHICT)
      @battle.setField(PBFields::PSYCHICT,true)
      @battle.field.duration=5
      @battle.pbDisplay(_INTL("The terrain became mysterious!"))
    elsif @id == PBMoves::SHATTEREDPSYCHE && @battle.FE == PBFields::PSYCHICT
      if opponent.pbCanConfuse?(false)
        opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
        @battle.pbCommonAnimation("Confusion",opponent,nil)
        @battle.pbDisplay(_INTL("The field got too weird for {1}!",opponent.pbThis(true)))
      end
    elsif @id == PBMoves::SPLINTEREDSTORMSHARDS # Splintered Stormshards
      if @battle.canChangeFE?
        @battle.breakField
        @battle.pbDisplay(_INTL("The field was devastated!"))
      end
    end
  end
################################################################################
# PokeBattle_ActualScene Feature for playing animation (based on common anims)
################################################################################

  #only Guardian of Alola at the moment
  def pbEffectFixedDamage(damage,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=pbType(attacker)
    typemod=pbTypeModMessages(type,attacker,opponent)
    opponent.damagestate.critical=false
    opponent.damagestate.typemod=0
    opponent.damagestate.calcdamage=0
    opponent.damagestate.hplost=0
    name=@name
    if @id==PBMoves::GUARDIANOFALOLA
      index = attacker.pokemon.species-PBSpecies::TAPUKOKO
      name = index >=0 && index <= 3 ? @name + ["KOKO", "LELE", "BULU", "FINI"][index] : @name + "KOKO"
    end
    if typemod!=0
      opponent.damagestate.calcdamage=damage
      opponent.damagestate.typemod=4
      pbShowAnimation(name,attacker,opponent,hitnum,alltargets,showanimation)
      damage=1 if damage<1 # HP reduced can't be less than 1
      damage=pbReduceHPDamage(damage,attacker,opponent)
      pbEffectMessages(attacker,opponent)
      pbOnDamageLost(damage,attacker,opponent)
      return damage
    end
    return 0
  end

  def pbShowAnimation(movename,user,target,hitnum=0,alltargets=nil,showanimation=true)
    return if !showanimation
    if @battle.battlescene
      animname=movename.delete(" ").delete("-").delete("'").upcase
      $cache.animations = load_data("Data/PkmnAnimations.rxdata") if !$cache.animations
      i = $cache.animations.length
      until i == 0 do
        if user.index&1==0  #Player side
          if $cache.animations[i] && $cache.animations[i].name=="ZMove:"+animname
            @battle.scene.pbAnimationCore($cache.animations[i],user,(target!=nil) ? target : user)
            return
          end
        else
          if $cache.animations[i] && $cache.animations[i].name=="OppZMove:"+animname
            @battle.scene.pbAnimationCore($cache.animations[i],target,(user!=nil) ? user : target)
            return
          elsif $cache.animations[i] && $cache.animations[i].name=="ZMove:"+animname
            @battle.scene.pbAnimationCore($cache.animations[i],user,(target!=nil) ? target : user)
            return
          end
        end
        i-=1
      end
    end
  end

################################################################################
# Z Status Effect check
################################################################################

  def pbZStatus(move,attacker)
    z_effect_hash = pbHashConverter(PBMoves,{
      [PBStats::ATTACK,1] => [:BULKUP,:HONECLAWS,:HOWL,:LASERFOCUS,:LEER,:MEDITATE,:ODORSLEUTH,:POWERTRICK,:ROTOTILLER,:SCREECH,:SHARPEN,
        :TAILWHIP, :TAUNT,:TOPSYTURVY,:WILLOWISP,:WORKUP],
      [PBStats::ATTACK,2] =>   [:MIRRORMOVE],
      [PBStats::ATTACK,3] =>   [:SPLASH],
      [PBStats::DEFENSE,1] =>   [:AQUARING,:BABYDOLLEYES,:BANEFULBUNKER,:BLOCK,:CHARM,:DEFENDORDER,:FAIRYLOCK,:FEATHERDANCE,
        :FLOWERSHIELD,:GRASSYTERRAIN,:GROWL,:HARDEN,:MATBLOCK,:NOBLEROAR,:PAINSPLIT,:PLAYNICE,:POISONGAS,
        :POISONPOWDER,:QUICKGUARD,:REFLECT,:ROAR,:SPIDERWEB,:SPIKES,:SPIKYSHIELD,:STEALTHROCK,:STRENGTHSAP,
        :TEARFULLOOK,:TICKLE,:TORMENT,:TOXIC,:TOXICSPIKES,:VENOMDRENCH,:WIDEGUARD,:WITHDRAW],
      [PBStats::SPATK,1] => [:CONFUSERAY,:ELECTRIFY,:EMBARGO,:FAKETEARS,:GEARUP,:GRAVITY,:GROWTH,:INSTRUCT,:IONDELUGE,
        :METALSOUND,:MINDREADER,:MIRACLEEYE,:NIGHTMARE,:PSYCHICTERRAIN,:REFLECTTYPE,:SIMPLEBEAM,:SOAK,:SWEETKISS,
        :TEETERDANCE,:TELEKINESIS],
      [PBStats::SPATK,2] => [:HEALBLOCK,:PSYCHOSHIFT],
      [PBStats::SPATK,3] => [],
      [PBStats::SPDEF,1] => [:CHARGE,:CONFIDE,:COSMICPOWER,:CRAFTYSHIELD,:EERIEIMPULSE,:ENTRAINMENT,:FLATTER,:GLARE,:INGRAIN,
        :LIGHTSCREEN,:MAGICROOM,:MAGNETICFLUX,:MEANLOOK,:MISTYTERRAIN,:MUDSPORT,:SPOTLIGHT,:STUNSPORE,:THUNDERWAVE,
        :WATERSPORT,:WHIRLWIND,:WISH,:WONDERROOM],
      [PBStats::SPDEF,2] => [:AROMATICMIST,:CAPTIVATE,:IMPRISON,:MAGICCOAT,:POWDER],
      [PBStats::SPEED,1] => [:AFTERYOU,:AURORAVEIL,:ELECTRICTERRAIN,:ENCORE,:GASTROACID,:GRASSWHISTLE,:GUARDSPLIT,:GUARDSWAP,
        :HAIL,:HYPNOSIS,:LOCKON,:LOVELYKISS,:POWERSPLIT,:POWERSWAP,:QUASH,:RAINDANCE,:ROLEPLAY,:SAFEGUARD,
        :SANDSTORM,:SCARYFACE,:SING,:SKILLSWAP,:SLEEPPOWDER,:SPEEDSWAP,:STICKYWEB,:STRINGSHOT,:SUNNYDAY,
        :SUPERSONIC,:TOXICTHREAD,:WORRYSEED,:YAWN],
      [PBStats::SPEED,2] => [:ALLYSWITCH,:BESTOW,:MEFIRST,:RECYCLE,:SNATCH,:SWITCHEROO,:TRICK],
      [PBStats::ACCURACY,1]   => [:COPYCAT,:DEFENSECURL,:DEFOG,:FOCUSENERGY,:MIMIC,:SWEETSCENT,:TRICKROOM],
      [PBStats::EVASION,1]   => [:CAMOUFLAGE,:DETECT,:FLASH,:KINESIS,:LUCKYCHANT,:MAGNETRISE,:SANDATTACK,:SMOKESCREEN],
      [:allstat1]  => [:CONVERSION,:FORESTSCURSE,:GEOMANCY,:PURIFY,:SKETCH,:TRICKORTREAT,:CELEBRATE],
      [:crit1]  => [:ACUPRESSURE,:FORESIGHT,:HEARTSWAP,:SLEEPTALK,:TAILWIND],
      [:reset]  => [:ACIDARMOR,:AGILITY,:AMNESIA,:ATTRACT,:AUTOTOMIZE,:BARRIER,:BATONPASS,:CALMMIND,:COIL,:COTTONGUARD,
        :COTTONSPORE,:DARKVOID,:DISABLE,:DOUBLETEAM,:DRAGONDANCE,:ENDURE,:FLORALHEALING,:FOLLOWME,:HEALORDER,
        :HEALPULSE,:HELPINGHAND,:IRONDEFENSE,:KINGSSHIELD,:LEECHSEED,:MILKDRINK,:MINIMIZE,:MOONLIGHT,:MORNINGSUN,
        :NASTYPLOT,:PERISHSONG,:PROTECT,:QUIVERDANCE,:RAGEPOWDER,:RECOVER,:REST,:ROCKPOLISH,:ROOST,:SHELLSMASH,
        :SHIFTGEAR,:SHOREUP,:SHELLSMASH,:SHIFTGEAR,:SHOREUP,:SLACKOFF,:SOFTBOILED,:SPORE,:SUBSTITUTE,:SWAGGER,
        :SWALLOW,:SWORDSDANCE,:SYNTHESIS,:TAILGLOW],
      [:heal]   => [:AROMATHERAPY,:BELLYDRUM,(:CONVERSION2),:HAZE,:HEALBELL,:MIST,:PSYCHUP,:REFRESH,:SPITE,:STOCKPILE,
        :TELEPORT,:TRANSFORM],
      [:heal2]  => [:MEMENTO,:PARTINGSHOT],
      [:centre] => [:DESTINYBOND,:GRUDGE]
    })
    z_effect_hash.default=[]
    z_effect = z_effect_hash[move]

    # Single stat boosting z-move
    if z_effect.length==2 
      if attacker.pbCanIncreaseStatStage?(z_effect[0],false)
        attacker.pbIncreaseStat(z_effect[0],z_effect[1],abilitymessage:false)
        boostlevel = ["","sharply ", "drastically "]
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power {2}boosted its {3}!",attacker.pbThis,boostlevel[z_effect[1]-1],attacker.pbGetStatName(z_effect[0])))
        return
      end
    end

    #Special effect
    case z_effect[0]
    when :allstat1
      for stat in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPATK,PBStats::SPDEF,PBStats::SPEED]
        if attacker.pbCanIncreaseStatStage?(stat,false)
          attacker.pbIncreaseStat(stat,1,abilitymessage:false)
        end
      end
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its stats!",attacker.pbThis))
    when :crit1
      if attacker.effects[PBEffects::FocusEnergy]<3
        attacker.effects[PBEffects::FocusEnergy]+=2
        attacker.effects[PBEffects::FocusEnergy]=3 if attacker.effects[PBEffects::FocusEnergy]>3
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power is getting it pumped!",attacker.pbThis))
      end
    when :reset
      for i in [PBStats::ATTACK,PBStats::DEFENSE,
                PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                PBStats::EVASION,PBStats::ACCURACY]
        if attacker.stages[i]<0
          attacker.stages[i]=0
        end
      end
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power returned its decreased stats to normal!",attacker.pbThis))
    when :heal
      attacker.pbRecoverHP(attacker.totalhp,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power restored its health!",attacker.pbThis))
    when :heal2
      attacker.effects[PBEffects::ZHeal]=true
    when :centre
      attacker.effects[PBEffects::FollowMe]=true
      if !attacker.pbPartner.isFainted?
        attacker.pbPartner.effects[PBEffects::FollowMe]=false
        attacker.pbPartner.effects[PBEffects::RagePowder]=false
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power made it the centre of attention!",attacker.pbThis))
      end
    end
  end
end