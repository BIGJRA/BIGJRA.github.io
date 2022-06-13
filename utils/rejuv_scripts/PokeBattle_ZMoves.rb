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
  # hi the commenting here before was shite so i will try and at least put some down for the changes i had to make

  def pbZMoveId(oldmove,crystal,moveindex=0)
    if @status && !(crystal==(PBItems::INTERCEPTZ2))
      return oldmove.id
    else
      case crystal
      when (PBItems::NORMALIUMZ2)
        return PBMoves::BREAKNECKBLITZ
      when (PBItems::FIGHTINIUMZ2)
        return PBMoves::ALLOUTPUMMELING
      when (PBItems::FLYINIUMZ2)
        return PBMoves::SUPERSONICSKYSTRIKE
      when (PBItems::POISONIUMZ2)
        return PBMoves::ACIDDOWNPOUR
      when (PBItems::GROUNDIUMZ2)
        return PBMoves::TECTONICRAGE
      when (PBItems::ROCKIUMZ2)
        return PBMoves::CONTINENTALCRUSH
      when (PBItems::BUGINIUMZ2)
        return PBMoves::SAVAGESPINOUT
      when (PBItems::GHOSTIUMZ2)
        return PBMoves::NEVERENDINGNIGHTMARE
      when (PBItems::STEELIUMZ2)
        return PBMoves::CORKSCREWCRASH
      when (PBItems::FIRIUMZ2)
        return PBMoves::INFERNOOVERDRIVE
      when (PBItems::WATERIUMZ2)
        return PBMoves::HYDROVORTEX
      when (PBItems::GRASSIUMZ2)
        return PBMoves::BLOOMDOOM
      when (PBItems::ELECTRIUMZ2)
        return PBMoves::GIGAVOLTHAVOC
      when (PBItems::PSYCHIUMZ2)
        return PBMoves::SHATTEREDPSYCHE
      when (PBItems::ICIUMZ2)
        return PBMoves::SUBZEROSLAMMER
      when (PBItems::DRAGONIUMZ2)
        return PBMoves::DEVASTATINGDRAKE
      when (PBItems::DARKINIUMZ2)
        return PBMoves::BLACKHOLEECLIPSE
      when (PBItems::FAIRIUMZ2)
        return PBMoves::TWINKLETACKLE
      when (PBItems::ALORAICHIUMZ2)
        return PBMoves::STOKEDSPARKSURFER
      when (PBItems::DECIDIUMZ2)
        return PBMoves::SINISTERARROWRAID
      when (PBItems::INCINIUMZ2)
        return PBMoves::MALICIOUSMOONSAULT
      when (PBItems::PRIMARIUMZ2)
        return PBMoves::OCEANICOPERETTA
      when (PBItems::EEVIUMZ2)
        return PBMoves::EXTREMEEVOBOOST
      when (PBItems::PIKANIUMZ2)
        return PBMoves::CATASTROPIKA
      when (PBItems::SNORLIUMZ2)
        return PBMoves::PULVERIZINGPANCAKE
      when (PBItems::MEWNIUMZ2)
        return PBMoves::GENESISSUPERNOVA
      when (PBItems::TAPUNIUMZ2)
        return PBMoves::GUARDIANOFALOLA
      when (PBItems::MARSHADIUMZ2)
        return PBMoves::SOULSTEALING7STARSTRIKE
      when (PBItems::KOMMONIUMZ2)
        return PBMoves::CLANGOROUSSOULBLAZE
      when (PBItems::LYCANIUMZ2)
        return PBMoves::SPLINTEREDSTORMSHARDS
      when (PBItems::MIMIKIUMZ2)
        return PBMoves::LETSSNUGGLEFOREVER
      when (PBItems::SOLGANIUMZ2)
        return PBMoves::SEARINGSUNRAZESMASH
      when (PBItems::LUNALIUMZ2)
        return PBMoves::MENACINGMOONRAZEMAELSTROM
      when (PBItems::ULTRANECROZIUMZ2)
        return PBMoves::LIGHTTHATBURNSTHESKY
      when (PBItems::INTERCEPTZ2) # added 4 moves for intercept-z, one for each move index(0-3)
        if moveindex==0
          return PBMoves::THEOLIADASH
        elsif moveindex==1
          return PBMoves::THEOLIASHIELD
        elsif moveindex==2
          return PBMoves::THEOLIAILLUSION
        elsif moveindex==3
          return PBMoves::THEOLIASTRIKE
        end
      end
    end
  end
  
  ZMOVENAMES = ["Breakneck Blitz","All-Out Pummeling","Supersonic Skystrike","Acid Downpour","Tectonic Rage",
    "Continental Crush","Savage Spin-Out","Never-Ending Nightmare","Corkscrew Crash","Inferno Overdrive",
    "Hydro Vortex","Bloom Doom","Gigavolt Havoc","Shattered Psyche","Subzero Slammer",
    "Devastating Drake","Black Hole Eclipse","Twinkle Tackle","Stoked Sparksurfer","Sinister Arrow Raid",
    "Malicious Moonsault","Oceanic Operetta","Extreme Evoboost","Catastropika","Pulverizing Pancake",
    "Genesis Supernova","Guardian of Alola","Soul-Stealing 7-Star Strike","Clangorous Soulblaze","Splintered Stormshards",
    "Let's Snuggle Forever","Searing Sunraze Smash","Menacing Moonraze Maelstrom","Light That Burns The Sky","Dash","Shield",
    "Illusion","Strike"]
  
  ZMOVEFLAGS = ["f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","f","af","f","","","af","af","","af","kf","f","f","f","f","f","f","f","f","f"] #good luck
  
  ################################################################################
  # Creating a z move
  ################################################################################
  def initialize(battle,battler,move,crystal,simplechoice=false,setup=false,moveindex=0) 
    # added 2 arguments here, setup is for making z-moves display in the fightbox, moveindex is the 
    if !(crystal == PBItems::INTERCEPTZ2)
      @status     = !(move.pbIsPhysical?(move.type) || move.pbIsSpecial?(move.type))
      @oldmove    = move
      @oldname    = move.name
      @id         = pbZMoveId(move,crystal,moveindex)
      @battle     = battle
      @name       = pbZMoveName(move,@id,crystal)
      # Get data on the move
      oldmovedata = PBMoveData.new(move.id)
      @function   = pbZMoveFunction(move,crystal,moveindex)
      @basedamage = pbZMoveBaseDamage(move,crystal,moveindex,@id)
      @type       = move.type
      @accuracy   = pbZMoveAccuracy(move,crystal)
      @addlEffect = 0 #pbZMoveAddlEffectChance(move,crystal)
      if crystal == PBItems::KOMMONIUMZ2
        @target   = PBTargets::AllOpposing
      else
        @target   = move.target
      end
      @priority   = @oldmove.priority
      @flags      = pbZMoveFlags(move,@id,crystal)
      @category   = oldmovedata.category
      @pp         = 1
      @totalpp    = 1
      @thismove   = self #move
      @zmove      = true
      if !@status
        @priority = 0
      end
      if setup==false
        battler.pbBeginTurn(self)
        @battle.pbDisplayBrief(_INTL("{1} unleashed its full force Z-Move!",battler.pbThis))
        @battle.pbDisplayBrief(_INTL("{1}!",@name))   
        zchoice=@battle.choices[battler.index] #[0,0,move,move.target]
        if simplechoice!=false
          zchoice=simplechoice
        end   
      end  
    else
      @status     = (moveindex==1 || moveindex==2)
      @oldmove    = move
      @oldname    = move.name
      @id         = pbZMoveId(move,crystal,moveindex)
      @battle     = battle
      @name       = pbZMoveName(move,@id,crystal)
      # Get data on the move
      oldmovedata = PBMoveData.new(move.id)
      @function   = pbZMoveFunction(move,crystal,moveindex)
      @basedamage = pbZMoveBaseDamage(move,crystal,moveindex,@id)
      @type       = 9
      @accuracy   = pbZMoveAccuracy(move,crystal)
      @addlEffect = 0 #pbZMoveAddlEffectChance(move,crystal)
      @thismove   = self #move
      if crystal == PBItems::KOMMONIUMZ2
        @target   = PBTargets::AllOpposing
      elsif (crystal == PBItems::INTERCEPTZ2)
        if (moveindex==1 || moveindex==2)
          @target = PBTargets::User
        elsif (moveindex==0 || moveindex==4)
          @target = PBTargets::SingleOpposing
        else
          @target   = move.target
        end
      else
        @target   = move.target
      end
      @priority   = @oldmove.priority
      @flags      = pbZMoveFlags(move,@id,crystal)
      if battler.attack>battler.spatk
        @category   = 0
      else
        @category   = 1
      end
      @pp         = 1
      @totalpp    = 1
      @zmove      = true
      if !@status
        if (crystal == PBItems::INTERCEPTZ2)
          if moveindex==0
            @priority = 1
          else
            @priority = 0
          end
        else
          @priority = 0
        end
      end
      if setup==false
        battler.pbBeginTurn(self)
        @battle.pbDisplayBrief(_INTL("{1} unleashed its full force Z-Move!",battler.pbThis))
        @battle.pbDisplayBrief(_INTL("{1}!",@name))   
        zchoice=@battle.choices[battler.index] #[0,0,move,move.target]
        if simplechoice!=false
          zchoice=simplechoice
        end   
      end
    end   
    if setup==false
      ztargets=[]
      user=battler.pbFindUser(zchoice,ztargets)
      if @thismove.target==PBTargets::AllOpposing && crystal==PBItems::KOMMONIUMZ2 && ztargets.length!=0
        user.pbAddTarget(ztargets,ztargets[0].pbPartner)
      end
      if user.hasWorkingAbility(:MOLDBREAKER) || user.hasWorkingAbility(:TERAVOLT) || user.hasWorkingAbility(:TURBOBLAZE)
        for battlers in ztargets
          battlers.moldbroken = true
        end
      else
        for battlers in ztargets
          battlers.moldbroken = false
        end
      end 
      ###
      for target in ztargets
        target.damagestate.reset
        if target.hasWorkingItem(:FOCUSBAND) && @battle.pbRandom(10)==0
          target.damagestate.focusband=true
        end
        if target.hasWorkingItem(:FOCUSSASH)
          target.damagestate.focussash=true
        end
        if target.hasWorkingItem(:RAMPCREST) && target.pokemon.species == PBSpecies::RAMPARDOS
          target.damagestate.rampcrest=true
        end
      end
      protype=@type
      if isConst?(battler.ability,PBAbilities,:PROTEAN) ||
        isConst?(battler.ability,PBAbilities,:LIBERO)
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
      if ztargets.length==0 && !(crystal == PBItems::INTERCEPTZ2)    
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
          if !(crystal == PBItems::INTERCEPTZ2)    
            zchoice[2].name = @name
            battler.pbUseMove(zchoice)
            @oldmove.name = @oldname
          end
        end      
      else
        if @status
          #targeted status Z's here
          pbZStatus(@id,battler)
          if !(crystal == PBItems::INTERCEPTZ2)
            zchoice[2].name = @name
            battler.pbUseMove(zchoice)
            @oldmove.name = @oldname
          end
        else
          movesucceeded=false
          turneffects=[]
          turneffects[PBEffects::SpecialUsage]=false
          turneffects[PBEffects::PassedTrying]=false
          turneffects[PBEffects::TotalDamage]=0
          #looping through all targets
          for i in 0...ztargets.length
            userandtarget=[user,ztargets[i]]
            if battler.effects[PBEffects::Powder] && (thismove.type == PBTypes::FIRE)
              @battle.pbDisplay(_INTL("The powder around {1} exploded!",battler.pbThis))
              @battle.pbCommonAnimation("Powder",battler,nil)
              battler.pbReduceHP((battler.totalhp/4.0).floor)
              battler.pbFaint if battler.hp<1
              return false
            end
            success = battler.pbChangeTarget(@thismove,userandtarget,ztargets)
            next if !success
            hitcheck = battler.pbProcessMoveAgainstTarget(@thismove,user,ztargets[0],1,turneffects,false,nil,true)
            movesucceeded = true if hitcheck && hitcheck > 0
          end
          if movesucceeded
            if @id==PBMoves::THEOLIASTRIKE
              if battler.pbOpposingSide.effects[PBEffects::Reflect]>0
                battler.pbOpposingSide.effects[PBEffects::Reflect]=0
                if !@battle.pbIsOpposing?(battler.index)
                  @battle.pbDisplay(_INTL("The opposing team's Reflect wore off!"))
                else
                  @battle.pbDisplayPaused(_INTL("Your team's Reflect wore off!"))
                end
              end
              if battler.pbOpposingSide.effects[PBEffects::LightScreen]>0
                battler.pbOpposingSide.effects[PBEffects::LightScreen]=0
                if !@battle.pbIsOpposing?(battler.index)
                  @battle.pbDisplay(_INTL("The opposing team's Light Screen wore off!"))
                else
                  @battle.pbDisplay(_INTL("Your team's Light Screen wore off!"))
                end
              end
              if battler.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
                battler.pbOpposingSide.effects[PBEffects::AuroraVeil]=0
                if !@battle.pbIsOpposing?(battler.index)
                  @battle.pbDisplay(_INTL("The opposing team's Aurora Veil wore off!"))
                else
                  @battle.pbDisplay(_INTL("Your team's Aurora Veil wore off!"))
                end
              end
              if battler.pbOpposingSide.effects[PBEffects::AreniteWall]>0
                battler.pbOpposingSide.effects[PBEffects::AreniteWall]=0
                if !@battle.pbIsOpposing?(battler.index)
                  @battle.pbDisplay(_INTL("The opposing team's Arenite Wall wore off!"))
                else
                  @battle.pbDisplay(_INTL("Your team's Arenite Wall wore off!"))
                end
              end
            end
            if @id == PBMoves::CLANGOROUSSOULBLAZE
              if !user.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
                !user.pbCanIncreaseStatStage?(PBStats::SPDEF,false) &&
                !user.pbCanIncreaseStatStage?(PBStats::SPEED,false) &&
                !user.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
                !user.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
                @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
              end
              showanim=true
              if user.pbCanIncreaseStatStage?(PBStats::SPATK,false)
                user.pbIncreaseStat(PBStats::SPATK,1,false,showanim,nil,showanim)
                showanim=false
              end
              if user.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
                user.pbIncreaseStat(PBStats::SPDEF,1,false,showanim,nil,showanim)
                showanim=false
              end
              if user.pbCanIncreaseStatStage?(PBStats::SPEED,false)
                user.pbIncreaseStat(PBStats::SPEED,1,false,showanim,nil,showanim)
                showanim=false
              end
              if user.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
                user.pbIncreaseStat(PBStats::ATTACK,1,false,showanim,nil,showanim)
                showanim=false
              end
              if user.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
                user.pbIncreaseStat(PBStats::DEFENSE,1,false,showanim,nil,showanim)
                showanim=false
              end
            end
          end
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
    end  
  end
  
  def pbZMoveName(oldmove,id,crystal)
    if (crystal == PBItems::INTERCEPTZ2)
      PokeBattle_ZMoves::ZMOVENAMES[@id-10001]
    elsif @status 
      return "Z-" + oldmove.name
    else
      PokeBattle_ZMoves::ZMOVENAMES[@id-10001]
    end
  end
  
  def pbZMoveFunction(oldmove,crystal,moveindex)
    if @status && !(crystal == PBItems::INTERCEPTZ2)
      return oldmove.function
    elsif (crystal == PBItems::INTERCEPTZ2)
      if moveindex==1
        return 0xAA
      elsif moveindex==2
        return 0x10C
      end
    else
      "Z"
    end 
  end
  
  def pbZMoveBaseDamage(oldmove,crystal,moveindex=0,id=oldmove.id)
    if @status
      return 0
    else
      case crystal
      when (PBItems::ALORAICHIUMZ2)
        return 175
      when (PBItems::DECIDIUMZ2)
        return 180
      when (PBItems::INCINIUMZ2)
        return 180
      when (PBItems::PRIMARIUMZ2)
        return 195
      when (PBItems::EEVIUMZ2)
        return 0
      when (PBItems::PIKANIUMZ2)
        return 210
      when (PBItems::SNORLIUMZ2)
        return 210
      when (PBItems::MEWNIUMZ2)
        return 185
      when (PBItems::TAPUNIUMZ2)
        return 0
      when (PBItems::MARSHADIUMZ2)
        return 195
      when (PBItems::KOMMONIUMZ2)
        return 185
      when (PBItems::LYCANIUMZ2)
        return 190
      when (PBItems::MIMIKIUMZ2)
        return 190
      when (PBItems::SOLGANIUMZ2)
        return 200
      when (PBItems::LUNALIUMZ2)
        return 200
      when (PBItems::ULTRANECROZIUMZ2)
        return 200
      else
        case @oldmove.id
        when PBMoves::MEGADRAIN
          return 120
        when PBMoves::WEATHERBALL
          return 160
        when PBMoves::HEX
          return 160
        when PBMoves::GEARGRIND
          return 180
        when PBMoves::VCREATE
          return 220
        when PBMoves::FLYINGPRESS
          return 170
        when PBMoves::COREENFORCER
          return 140
        when PBMoves::CRUSHGRIP # Variable Power Moves from now
          return 190
        when PBMoves::FLAIL
          return 160
        when PBMoves::FRUSTRATION
          return 160
        when PBMoves::NATURALGIFT
          return 160
        when PBMoves::PRESENT
          return 100
        when PBMoves::RETURN
          return 160
        when PBMoves::SPITUP
          return 100
        when PBMoves::TRUMPCARD
          return 160
        when PBMoves::WRINGOUT
          return 190
        when PBMoves::BEATUP
          return 100
        when PBMoves::FLING
          return 100
        when PBMoves::POWERTRIP
          return 160
        when PBMoves::PUNISHMENT
          return 160
        when PBMoves::ELECTROBALL
          return 160
        when PBMoves::ERUPTION
          return 200
        when PBMoves::HEATCRASH
          return 160
        when PBMoves::GRASSKNOT
          return 160
        when PBMoves::GYROBALL
          return 160
        when PBMoves::HEAVYSLAM
          return 160
        when PBMoves::LOWKICK
          return 160
        when PBMoves::REVERSAL
          return 160
        when PBMoves::MAGNITUDE
          return 140
        when PBMoves::STOREDPOWER
          return 160
        when PBMoves::WATERSPOUT
          return 200
        else
          case id
          when PBMoves::THEOLIADASH
            return 70
          when PBMoves::THEOLIASTRIKE
            return 120
          end
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
  
  
  def pbZMoveFlags(oldmove,id,crystal)
    if @status && !(crystal == PBItems::INTERCEPTZ2)
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
  
  ################################################################################
  # PokeBattle_Move Features needed for move use
  ################################################################################
  def pbModifyDamage(damagemult,attacker,opponent)
    if !opponent.effects[PBEffects::ProtectNegation] && (opponent.pbOwnSide.effects[PBEffects::MatBlock] ||
        opponent.effects[PBEffects::Protect] || opponent.effects[PBEffects::KingsShield] ||  opponent.effects[PBEffects::Obstruct] ||
        opponent.effects[PBEffects::SpikyShield] || opponent.effects[PBEffects::BanefulBunker])
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
      if $fefieldeffect!=1 && $fefieldeffect!=35 
        if $febackup>0 && $febackup<46 && @battle.field.effects[PBEffects::Splintered]==0 
          if @battle.field.effects[PBEffects::ElectricTerrain]==0
            @battle.field.effects[PBEffects::ElectricTerrain]=3
            @battle.pbDisplay(_INTL("The terrain became electrified!"))
          end  
        else          
          $fetempfield = 1 
          $fefieldeffect = $fetempfield
          @battle.pbChangeBGSprite
          @battle.field.effects[PBEffects::Terrain]=3
          @battle.field.effects[PBEffects::ElectricTerrain]=3 
          @battle.pbDisplay(_INTL("The terrain became electrified!"))
        end  
        @battle.seedCheck
      end
    elsif @id == PBMoves::TECTONICRAGE # Tectonic Rage
      if $fefieldeffect == 1 # Electric Terrain
        if $fefieldeffect == $febackup
          $fefieldeffect = 0
        else
          $fefieldeffect = $febackup
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The hyper-charged terrain shorted out!"))
        @battle.field.effects[PBEffects::Terrain]=0
        @battle.seedCheck
      elsif $fefieldeffect == 4 # Dark Crystal Cavern
        $fefieldeffect = 23
        $febackup = 23
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The dark crystals were shattered!"))
        @battle.seedCheck    
      elsif $fefieldeffect == 13 # Icy Field
        if $fefieldeffect == $febackup
          $fefieldeffect = 23
        else
          $fefieldeffect = $febackup
          if $febackup==21 || $febackup==26
            hazardsExist = false
            if user.pbOwnSide.effects[PBEffects::Spikes]>0 || user.pbOpposingSide.effects[PBEffects::Spikes]>0
              user.pbOwnSide.effects[PBEffects::Spikes] = 0
              user.pbOpposingSide.effects[PBEffects::Spikes] = 0
              hazardsExist = true
            end
            if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 || user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
              user.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
              user.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
              hazardsExist = true
            end
            if user.pbOwnSide.effects[PBEffects::StealthRock] || user.pbOpposingSide.effects[PBEffects::StealthRock]
              user.pbOwnSide.effects[PBEffects::StealthRock] = false
              user.pbOpposingSide.effects[PBEffects::StealthRock] = false
              hazardsExist = true
            end
            if user.pbOwnSide.effects[PBEffects::StickyWeb] || user.pbOpposingSide.effects[PBEffects::StickyWeb]
              user.pbOwnSide.effects[PBEffects::StickyWeb] = false
              user.pbOpposingSide.effects[PBEffects::StickyWeb] = false
              hazardsExist = true
            end
            if hazardsExist
              @battle.pbDisplay(_INTL("Removed all hazards from field!"))
            end
          end
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The quake broke up the ice!"))
        @battle.seedCheck
      elsif $fefieldeffect == 17 # Factory Field
        $fefieldeffect = 18
        $febackup = 18
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The field was broken!"))
        @battle.seedCheck
      elsif $fefieldeffect == 23 # Cave
        $fecounter+=1 
        case $fecounter
        when 1
          @battle.pbDisplay(_INTL("Bits of rock fell from the crumbling ceiling!"))
        when 2
          @battle.pbDisplay(_INTL("The quake collapsed the ceiling!"))
          for i in 0...4
            quakedrop = @battle.battlers[i].hp
            next if quakedrop==0
            invulcheck=$pkmn_move[@battle.battlers[i].effects[PBEffects::TwoTurnAttack]][0]
            case invulcheck
            when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
              quakedrop = 0
            end
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::SkyDrop]
            quakedrop-=1 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::STURDY)                 
            quakedrop/=3 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::SOLIDROCK)
            quakedrop/=2 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::SHELLARMOR)
            quakedrop/=2 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::BATTLEARMOR)
            quakedrop =0 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::BULLETPROOF)
            quakedrop =0 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::ROCKHEAD)
            quakedrop/=3 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::PRISMARMOR)
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::Protect] == true
            quakedrop=0 if @battle.battlers[i].isbossmon
            quakedrop =0 if @battle.battlers[i].pbOwnSide.effects[PBEffects::WideGuard] == true
            quakedrop-=1 if @battle.battlers[i].effects[PBEffects::Endure] == true
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::KingsShield] == true
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::Obstruct] == true
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::SpikyShield] == true
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::MatBlock] == true
            @battle.battlers[i].pbReduceHP(quakedrop) if quakedrop != 0
            @battle.battlers[i].pbFaint if @battle.battlers[i].isFainted?           
          end 
        end       
      elsif $fefieldeffect == 25 # Crystal Cavern
        $fefieldeffect = 23
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The crystals were broken up!"))
        @battle.seedCheck             
      elsif $fefieldeffect == 30 # Mirror Arena
        @battle.pbDisplay(_INTL("The mirror arena shattered!"))
        for i in 0...4
          shatter = @battle.battlers[i].totalhp
          next if shatter==0
          shatter/=2
          invulcheck=$pkmn_move[@battle.battlers[i].effects[PBEffects::TwoTurnAttack]][0]
          case invulcheck
          when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
            shatter = 0
          end
          shatter =0 if @battle.battlers[i].effects[PBEffects::SkyDrop]
          shatter =0 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::SHELLARMOR)
          shatter =0 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::BATTLEARMOR)
          shatter =0 if @battle.battlers[i].effects[PBEffects::Protect] == true
          shatter =0 if @battle.battlers[i].pbOwnSide.effects[PBEffects::WideGuard] == true
          shatter =0 if @battle.battlers[i].effects[PBEffects::Obstruct] == true
          shatter =0 if @battle.battlers[i].effects[PBEffects::KingsShield] == true
          shatter =0 if @battle.battlers[i].effects[PBEffects::SpikyShield] == true
          shatter =0 if @battle.battlers[i].effects[PBEffects::MatBlock] == true
          @battle.battlers[i].pbReduceHP(shatter) if shatter != 0
          @battle.battlers[i].pbFaint if @battle.battlers[i].isFainted?
          $fefieldeffect = 0
          $febackup = 0
          @battle.pbChangeBGSprite           
          @battle.seedCheck            
        end 
      end
    elsif @id == PBMoves::BLOOMDOOM
      if $fefieldeffect!=2 && $fefieldeffect!=35
        if ($febackup>0 && $febackup<46 && @battle.field.effects[PBEffects::Splintered]==0) ||  ($game_map.map_id==53)
          if @battle.field.effects[PBEffects::GrassyTerrain]==0
            @battle.field.effects[PBEffects::GrassyTerrain]=3
            @battle.pbDisplay(_INTL("The terrain became grassy!"))
          end  
        else           
          $fetempfield = 2
          $fefieldeffect = $fetempfield
          @battle.pbChangeBGSprite
          @battle.field.effects[PBEffects::Terrain]=3 
          @battle.field.effects[PBEffects::GrassyTerrain]=3
          @battle.pbDisplay(_INTL("The terrain became grassy!"))
        end  
        @battle.seedCheck        
      end          
      if $fefieldeffect==33
        if $fecounter<4
          $fecounter+=1
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("Bloom Doom grew the garden a little!"))
        end  
      end        
    elsif @id == PBMoves::ACIDDOWNPOUR
      if $fefieldeffect==2  # Grassy
        $fetempfield = 10
        $fefieldeffect = $fetempfield
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The grassy terrain was corroded!"))
        @battle.seedCheck     
      elsif $fefieldeffect==3 # Misty 
        $fetempfield = 11
        $fefieldeffect = $fetempfield
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("Poison spread through the mist!"))
        @battle.seedCheck   
      elsif $fefieldeffect==19 # Wasteland
        if ((!opponent.pbHasType?(:POISON) && !opponent.pbHasType?(:STEEL)) || opponent.corroded) &&
          !(opponent.ability == PBAbilities::TOXICBOOST) &&
          !(opponent.ability == PBAbilities::POISONHEAL) &&
          !((opponent.species==PBSpecies::ZANGOOSE && opponent.item==PBItems::ZANGCREST))
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
      elsif $fefieldeffect==22 # Underwater
        $fefieldeffect = 26
        $febackup = 26
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The water was polluted!"))
        @battle.pbDisplay(_INTL("The grime sank beneath the battlers!"))
        $fecounter = 0
        @battle.seedCheck
      elsif $fefieldeffect==33 # Flower Garden Field
        if $fecounter>0
          $fecounter = 0
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The acid melted the bloom!"))
        end
      end
    elsif @id == PBMoves::GENESISSUPERNOVA && $fefieldeffect!=37 && $fefieldeffect!=35 && $fefieldeffect!=22 && $fefieldeffect!=38 && $fefieldeffect!=39
      if $febackup>0 && $febackup<38 && @battle.field.effects[PBEffects::Splintered]==0 
        if @battle.field.effects[PBEffects::PsychicTerrain]==0
          @battle.field.effects[PBEffects::PsychicTerrain]=5
          @battle.pbDisplay(_INTL("The terrain became mysterious!"))
        end  
      else      
        $fetempfield = 37
        $fefieldeffect = $fetempfield
        @battle.pbChangeBGSprite
        @battle.field.effects[PBEffects::Terrain]=5
        @battle.pbDisplay(_INTL("The terrain became mysterious!"))
      end   
      @battle.seedCheck
    elsif @id == PBMoves::INFERNOOVERDRIVE # Inferno Overdrive
      if $fefieldeffect==13  # Icy Field
        if $fefieldeffect == $febackup
          $fefieldeffect = 23
        else
          $fefieldeffect = $febackup
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The ice melted away!"))
        @battle.seedCheck  
      elsif $fefieldeffect == 11 # Corrosive Mist Field
        dampcheck=0
        for i in 0...4
          dampcheck = 1 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::DAMP)
        end
        if dampcheck == 0
          for i in 0...4
            combust = @battle.battlers[i].hp
            next if combust==0
            invulcheck=$pkmn_move[@battle.battlers[i].effects[PBEffects::TwoTurnAttack]][0]
            case invulcheck
            when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
              combust = 0
            end
            combust =0 if @battle.battlers[i].effects[PBEffects::SkyDrop]
            combust-=1 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::STURDY)
            combust =0 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::FLASHFIRE)
            combust =0 if @battle.battlers[i].effects[PBEffects::Protect] == true
            combust =0 if @battle.battlers[i].pbOwnSide.effects[PBEffects::WideGuard] == true
            combust-=1 if @battle.battlers[i].effects[PBEffects::Endure] == true
            combust =0 if @battle.battlers[i].effects[PBEffects::Obstruct] == true
            combust =0 if @battle.battlers[i].effects[PBEffects::KingsShield] == true
            combust =0 if @battle.battlers[i].effects[PBEffects::SpikyShield] == true
            combust =0 if @battle.battlers[i].effects[PBEffects::MatBlock] == true
            @battle.battlers[i].pbReduceHP(combust) if combust != 0
            @battle.battlers[i].pbFaint if @battle.battlers[i].isFainted?
          end
        else
          @battle.pbDisplay(_INTL("A Pokemon's Damp ability prevented a complete explosion!"))
        end        
        if $fefieldeffect == $febackup
          $fefieldeffect = 0
        else
          $fefieldeffect = $febackup
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The toxic mist combusted!"))
        @battle.field.effects[PBEffects::Terrain]=0
        @battle.seedCheck 
      elsif $fefieldeffect == 27 # Mountain
        $fefieldeffect = 16
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The mountain erupted!"))
        @battle.seedCheck 
      elsif $fefieldeffect == 28 # Snowy Mountain
        $fefieldeffect = 27
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The snow melted away!"))
        @battle.seedCheck 
      elsif $fefieldeffect==33 # Flower Garden Field
        if $fecounter>0
          $fefieldeffect = 7
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The garden caught fire!"))
          @battle.seedCheck
        end 
      end
    elsif @id == PBMoves::CONTINENTALCRUSH # Continental Crush
      if $fefieldeffect == 7 # Volcanic Field
        if $fefieldeffect == $febackup
          $fefieldeffect = 23
        else
          $fefieldeffect = $febackup
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The sand snuffed out the flame!"))
        @battle.field.effects[PBEffects::Terrain]=0
        @battle.seedCheck
      elsif $fefieldeffect == 23 # Cave
        $fecounter+=1 
        case $fecounter
        when 1
          @battle.pbDisplay(_INTL("Bits of rock fell from the crumbling ceiling!"))
        when 2
          @battle.pbDisplay(_INTL("The quake collapsed the ceiling!"))
          for i in 0...4
            quakedrop = @battle.battlers[i].hp
            next if quakedrop==0
            invulcheck=$pkmn_move[@battle.battlers[i].effects[PBEffects::TwoTurnAttack]][0]
            case invulcheck
            when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
              quakedrop = 0
            end
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::SkyDrop]
            quakedrop-=1 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::STURDY)                 
            quakedrop/=3 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::SOLIDROCK)
            quakedrop/=2 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::SHELLARMOR)
            quakedrop/=2 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::BATTLEARMOR)
            quakedrop =0 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::BULLETPROOF)
            quakedrop =0 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::ROCKHEAD)
            quakedrop/=3 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::PRISMARMOR)
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::Protect] == true
            quakedrop =0 if @battle.battlers[i].pbOwnSide.effects[PBEffects::WideGuard] == true
            quakedrop-=1 if @battle.battlers[i].effects[PBEffects::Endure] == true
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::Obstruct] == true
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::KingsShield] == true
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::SpikyShield] == true
            quakedrop =0 if @battle.battlers[i].effects[PBEffects::MatBlock] == true
            @battle.battlers[i].pbReduceHP(quakedrop) if quakedrop != 0
            @battle.battlers[i].pbFaint if @battle.battlers[i].isFainted?            
          end
        end         
      end   
    elsif @id == PBMoves::SUBZEROSLAMMER # Subzero Slammer
      if $fefieldeffect == 16 # Volcanic Top Field
        if $fefieldeffect == $febackup
          $fefieldeffect = 27
        else
          $fefieldeffect = $febackup
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The field cooled off!"))
        @battle.seedCheck
      elsif $fefieldeffect == 21 # Water Surface
        $febackup=21
        $fefieldeffect = 13
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The water froze over!"))
        @battle.seedCheck 
      elsif $fefieldeffect == 23 # Cave Field
        $fefieldeffect = 13
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The cavern froze over!"))
        @battle.seedCheck 
      elsif $fefieldeffect == 26 # Murkwater Surface
        $febackup=26
        $fefieldeffect = 13
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The toxic water froze over!"))
        @battle.seedCheck     
      elsif $fefieldeffect == 27 # Mountain
        $fefieldeffect = 28
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The mountain was covered in snow!"))
        @battle.seedCheck                   
      end  
    elsif @id == PBMoves::HYDROVORTEX # Hydro Vortex
      if $fefieldeffect == 7 # Burning Field
        if $fefieldeffect == $febackup
          $fefieldeffect = 23
        else
          $fefieldeffect = $febackup
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The water snuffed out the flame!"))
        @battle.field.effects[PBEffects::Terrain]=0
        @battle.seedCheck
      elsif $fefieldeffect == 16 # Volcanic Top Field
        @battle.pbDisplay(_INTL("Steam shot up from the field!"))
        for i in 0...4
          canthit = 0
          invulcheck=$pkmn_move[@battle.battlers[i].effects[PBEffects::TwoTurnAttack]][0]
          case invulcheck
          when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
            canthit = 1
          end
          canthit =1 if @battle.battlers[i].effects[PBEffects::SkyDrop]
          if canthit = 0 && @battle.battlers[i].pbCanReduceStatStage?(PBStats::ACCURACY)
            @battle.battlers[i].pbReduceStatBasic(PBStats::ACCURACY,1)
            @battle.pbCommonAnimation("StatDown",@battle.battlers[i],nil)
            @battle.pbDisplay(_INTL("{1}'s Accuracy fell!",@battle.battlers[i].pbThis))
          end
        end                     
      end     
    elsif @id == PBMoves::GIGAVOLTHAVOC # Gigavolt Havoc
      if $fefieldeffect==17 # Factory Field
        $fefieldeffect = 18
        $febackup = 18
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The field shorted out!"))
        @battle.seedCheck     
      elsif $fefieldeffect==18 # Short-Circuit Field
        $fefieldeffect = 17
        $febackup = 17
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("SYSTEM ONLINE."))
        @battle.seedCheck       
      end       
    elsif @id == PBMoves::OCEANICOPERETTA # Oceanic Operetta
      if $fefieldeffect == 7 # Volcanic Field
        if $fefieldeffect == $febackup
          $fefieldeffect = 23
        else
          $fefieldeffect = $febackup
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The water snuffed out the flame!"))
        @battle.field.effects[PBEffects::Terrain]=0
        @battle.seedCheck
      elsif $fefieldeffect == 16 # Volcanic Top Field
        @battle.pbDisplay(_INTL("Steam shot up from the field!"))
        for i in 0...4
          canthit = 0
          invulcheck=$pkmn_move[@battle.battlers[i].effects[PBEffects::TwoTurnAttack]][0]
          case invulcheck
          when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
            canthit = 1
          end
          canthit =1 if @battle.battlers[i].effects[PBEffects::SkyDrop]
          if canthit = 0 && @battle.battlers[i].pbCanReduceStatStage?(PBStats::ACCURACY)
            @battle.battlers[i].pbReduceStatBasic(PBStats::ACCURACY,1)
            @battle.pbCommonAnimation("StatDown",@battle.battlers[i],nil)
            @battle.pbDisplay(_INTL("{1}'s Accuracy fell!",@battle.battlers[i].pbThis))
          end
        end    
      end     
    elsif @id == PBMoves::SUPERSONICSKYSTRIKE # Supersonic Skystrike
      if $fefieldeffect == 3 # Misty Terrain
        if $fefieldeffect == $febackup
          $fefieldeffect = 0
        else
          $fefieldeffect = $febackup
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The mist was blown away!"))
        @battle.field.effects[PBEffects::Terrain]=0
        @battle.seedCheck
      elsif $fefieldeffect == 11 # Corrosive Mist
        if $fefieldeffect == $febackup
          $fefieldeffect = 0
        else
          $fefieldeffect = $febackup
        end
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The mist was blown away!"))
        @battle.field.effects[PBEffects::Terrain]=0
        @battle.seedCheck
      end     
    elsif @id == PBMoves::DEVASTATINGDRAKE 
      if $fefieldeffect == 23 # Cave Field
        @battle.basefield==23
        $fefieldeffect = 32
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The explosion of draconic energy mutated the field!"))
        @battle.seedCheck
      end
    elsif @id == PBMoves::SHATTEREDPSYCHE && $fefieldeffect==37
      if opponent.pbCanConfuse?(false)
        opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
        @battle.pbCommonAnimation("Confusion",opponent,nil)
        @battle.pbDisplay(_INTL("The field got too weird for {1}!",opponent.pbThis(true)))
      end
    elsif @id == PBMoves::SPLINTEREDSTORMSHARDS # Splintered Stormshards
      if $fefieldeffect!=35 && $fefieldeffect!=0 && $fefieldeffect!=22 && $fefieldeffect<46
        $febackup=$fefieldeffect
        $fetempfield = 0
        $fefieldeffect = $fetempfield
        @battle.pbChangeBGSprite
        @battle.field.effects[PBEffects::Splintered]=3 if $febackup>0 && $febackup<46
        @battle.field.effects[PBEffects::Terrain]=3
        @battle.pbDisplay(_INTL("The field was devastated!"))
      end
    end
  end
################################################################################
# PokeBattle_ActualScene Feature for playing animation (based on common anims)
################################################################################    

def pbShowAnimation(movename,user,target,hitnum=0,alltargets=nil,showanimation=true)
  if @battle.battlescene
    animname=movename.delete(" ").delete("-").upcase
    $pkmn_animations = load_data_anim("Data/PkmnAnimations.rxdata") if !$pkmn_animations
    animations=$pkmn_animations
    i = animations.length
    until i == 0 do
      if @battle.pbBelongsToPlayer?(user.index)
        if animations[i] && animations[i].name=="ZMove:"+animname && showanimation
          @battle.scene.pbAnimationCore(animations[i],user,(target!=nil) ? target : user)
          return
        end
      else
        if animations[i] && animations[i].name=="OppZMove:"+animname && showanimation
          @battle.scene.pbAnimationCore(animations[i],target,(user!=nil) ? user : target)
          return
        elsif animations[i] && animations[i].name=="ZMove:"+animname && showanimation
          @battle.scene.pbAnimationCore(animations[i],user,(target!=nil) ? target : user)
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
  atk1 =   [PBMoves::BULKUP,PBMoves::HONECLAWS,PBMoves::HOWL,PBMoves::LASERFOCUS,PBMoves::LEER,PBMoves::MEDITATE,PBMoves::ODORSLEUTH,PBMoves::POWERTRICK,PBMoves::ROTOTILLER,PBMoves::SCREECH,PBMoves::SHARPEN,PBMoves::TAILWHIP,PBMoves::TAUNT,PBMoves::TOPSYTURVY,PBMoves::WILLOWISP,PBMoves::WORKUP]
  atk2 =   [PBMoves::MIRRORMOVE,PBMoves::OCTOLOCK]
  atk3 =   [PBMoves::SPLASH]
  def1 =   [PBMoves::AQUARING,PBMoves::BABYDOLLEYES,PBMoves::BANEFULBUNKER,PBMoves::BLOCK,PBMoves::CHARM,PBMoves::DEFENDORDER,PBMoves::FAIRYLOCK,PBMoves::FEATHERDANCE,PBMoves::FLOWERSHIELD,PBMoves::GRASSYTERRAIN,PBMoves::GROWL,PBMoves::HARDEN,PBMoves::MATBLOCK,PBMoves::NOBLEROAR,PBMoves::PAINSPLIT,PBMoves::PLAYNICE,PBMoves::POISONGAS,PBMoves::POISONPOWDER,PBMoves::QUICKGUARD,PBMoves::REFLECT,PBMoves::ROAR,PBMoves::SPIDERWEB,PBMoves::SPIKES,PBMoves::SPIKYSHIELD,PBMoves::STEALTHROCK,PBMoves::STRENGTHSAP,PBMoves::TEARFULLOOK,PBMoves::TICKLE,PBMoves::TORMENT,PBMoves::TOXIC,PBMoves::TOXICSPIKES,PBMoves::VENOMDRENCH,PBMoves::WIDEGUARD,PBMoves::WITHDRAW]
  def2 =   []
  def3 =   []
  spatk1 = [PBMoves::CONFUSERAY,PBMoves::ELECTRIFY,PBMoves::EMBARGO,PBMoves::FAKETEARS,PBMoves::GEARUP,PBMoves::GRAVITY,PBMoves::GROWTH,PBMoves::INSTRUCT,PBMoves::IONDELUGE,PBMoves::METALSOUND,PBMoves::MINDREADER,PBMoves::MIRACLEEYE,PBMoves::NIGHTMARE,PBMoves::PSYCHICTERRAIN,PBMoves::REFLECTTYPE,PBMoves::SIMPLEBEAM,PBMoves::SOAK,PBMoves::MAGICPOWDER,PBMoves::SWEETKISS,PBMoves::TEETERDANCE,PBMoves::TELEKINESIS]
  spatk2 = [PBMoves::HEALBLOCK,PBMoves::PSYCHOSHIFT,PBMoves::TARSHOT]
  spatk3 = []
  spdef1 = [PBMoves::CHARGE,PBMoves::CONFIDE,PBMoves::COSMICPOWER,PBMoves::CRAFTYSHIELD,PBMoves::EERIEIMPULSE,PBMoves::ENTRAINMENT,PBMoves::FLATTER,PBMoves::GLARE,PBMoves::INGRAIN,PBMoves::LIGHTSCREEN,PBMoves::MAGICROOM,PBMoves::MAGNETICFLUX,PBMoves::MEANLOOK,PBMoves::MISTYTERRAIN,PBMoves::MUDSPORT,PBMoves::SPOTLIGHT,PBMoves::STUNSPORE,PBMoves::THUNDERWAVE,PBMoves::WATERSPORT,PBMoves::WHIRLWIND,PBMoves::WISH,PBMoves::WONDERROOM]
  spdef2 = [PBMoves::AROMATICMIST,PBMoves::CAPTIVATE,PBMoves::IMPRISON,PBMoves::MAGICCOAT,PBMoves::POWDER]
  spdef3 = []
  speed1 = [PBMoves::AFTERYOU,PBMoves::AURORAVEIL,PBMoves::ELECTRICTERRAIN,PBMoves::ENCORE,PBMoves::GASTROACID,PBMoves::GRASSWHISTLE,PBMoves::GUARDSPLIT,PBMoves::GUARDSWAP,PBMoves::HAIL,PBMoves::HYPNOSIS,PBMoves::LOCKON,PBMoves::LOVELYKISS,PBMoves::POWERSPLIT,PBMoves::POWERSWAP,PBMoves::QUASH,PBMoves::RAINDANCE,PBMoves::ROLEPLAY,PBMoves::SAFEGUARD,PBMoves::SANDSTORM,PBMoves::SCARYFACE,PBMoves::SING,PBMoves::SKILLSWAP,PBMoves::SLEEPPOWDER,PBMoves::SPEEDSWAP,PBMoves::STICKYWEB,PBMoves::STRINGSHOT,PBMoves::SUNNYDAY,PBMoves::SUPERSONIC,PBMoves::TOXICTHREAD,PBMoves::WORRYSEED,PBMoves::YAWN]
  speed2 = [PBMoves::ALLYSWITCH,PBMoves::BESTOW,PBMoves::MEFIRST,PBMoves::RECYCLE,PBMoves::SNATCH,PBMoves::SWITCHEROO,PBMoves::TRICK]
  speed3 = []
  acc1   = [PBMoves::COPYCAT,PBMoves::DEFENSECURL,PBMoves::DEFOG,PBMoves::FOCUSENERGY,PBMoves::MIMIC,PBMoves::SWEETSCENT,PBMoves::TRICKROOM]
  acc2   = []
  acc3   = []
  eva1   = [PBMoves::CAMOUFLAGE,PBMoves::DETECT,PBMoves::FLASH,PBMoves::KINESIS,PBMoves::LUCKYCHANT,PBMoves::MAGNETRISE,PBMoves::SANDATTACK,PBMoves::SMOKESCREEN]
  eva2   = []
  eva3   = []
  stat1  = [PBMoves::CONVERSION,PBMoves::FORESTSCURSE,PBMoves::GEOMANCY,PBMoves::PURIFY,PBMoves::SKETCH,PBMoves::TRICKORTREAT,PBMoves::TEATIME,PBMoves::STUFFCHEEKS]
  stat2  = []
  stat3  = []
  crit1  = [PBMoves::ACUPRESSURE,PBMoves::FORESIGHT,PBMoves::HEARTSWAP,PBMoves::SLEEPTALK,PBMoves::TAILWIND]
  reset  = [PBMoves::ACIDARMOR,PBMoves::AGILITY,PBMoves::AMNESIA,PBMoves::ATTRACT,PBMoves::AUTOTOMIZE,PBMoves::BARRIER,PBMoves::BATONPASS,PBMoves::CALMMIND,PBMoves::CLANGOROUSSOUL,PBMoves::COIL,PBMoves::COTTONGUARD,PBMoves::COTTONSPORE,PBMoves::COURTCHANGE,PBMoves::DARKVOID,PBMoves::DISABLE,PBMoves::DOUBLETEAM,PBMoves::DRAGONDANCE,PBMoves::ENDURE,PBMoves::FLORALHEALING,PBMoves::FOLLOWME,PBMoves::HEALORDER,PBMoves::HEALPULSE,PBMoves::HELPINGHAND,PBMoves::IRONDEFENSE,PBMoves::KINGSSHIELD,PBMoves::LEECHSEED,PBMoves::MILKDRINK,PBMoves::MINIMIZE,PBMoves::MOONLIGHT,PBMoves::MORNINGSUN,PBMoves::NASTYPLOT,PBMoves::NORETREAT,PBMoves::OBSTRUCT,PBMoves::PERISHSONG,PBMoves::PROTECT,PBMoves::QUIVERDANCE,PBMoves::RAGEPOWDER,PBMoves::RECOVER,PBMoves::REST,PBMoves::ROCKPOLISH,PBMoves::ROOST,PBMoves::SHELLSMASH,PBMoves::SHIFTGEAR,PBMoves::SHOREUP,PBMoves::SHELLSMASH,PBMoves::SHIFTGEAR,PBMoves::SHOREUP,PBMoves::SLACKOFF,PBMoves::SOFTBOILED,PBMoves::SPORE,PBMoves::SUBSTITUTE,PBMoves::SWAGGER,PBMoves::SWALLOW,PBMoves::SWORDSDANCE,PBMoves::SYNTHESIS,PBMoves::TAILGLOW]
  heal   = [PBMoves::AROMATHERAPY,PBMoves::BELLYDRUM,PBMoves::CONVERSION2,PBMoves::DECORATE,PBMoves::HAZE,PBMoves::HEALBELL,PBMoves::LIFEDEW,PBMoves::MIST,PBMoves::PSYCHUP,PBMoves::REFRESH,PBMoves::SPITE,PBMoves::STOCKPILE,PBMoves::TELEPORT,PBMoves::TRANSFORM]
  heal2  = [PBMoves::MEMENTO,PBMoves::PARTINGSHOT]
  centre = [PBMoves::DESTINYBOND,PBMoves::GRUDGE]
  protectmove   = [PBMoves::THEOLIASHIELD]
  illusion = [PBMoves::THEOLIAILLUSION]
  if illusion.include?(move)
    if attacker.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1} already has a substitute!",attacker.pbThis))
      return -1
    end
    sublife=[(attacker.totalhp/4).floor,1].max
    if attacker.hp<=sublife
      @battle.pbDisplay(_INTL("It was too weak to make a substitute!"))
      return -1  
    end    
    #@battle.scene.pbSubstituteSprite(attacker,attacker.pbIsOpposing?(1))
    attacker.effects[PBEffects::MultiTurn]=0
    attacker.effects[PBEffects::MultiTurnAttack]=0
    attacker.effects[PBEffects::Substitute]=sublife
    @battle.pbDisplayBrief(_INTL("{1} put in a substitute!",attacker.pbThis))
  elsif protectmove.include?(move)
    attacker.effects[PBEffects::Protect]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplayBrief(_INTL("{1} protected itself!",attacker.pbThis)) 
  elsif atk1.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its Attack!",attacker.pbThis))
    end
  elsif atk2.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,2,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its Attack!",attacker.pbThis))
    end
  elsif atk3.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,3,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its Attack!",attacker.pbThis))
    end
  elsif def1.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its Defense!",attacker.pbThis))
    end
  elsif def2.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,2,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its Defense!",attacker.pbThis))
    end
  elsif def3.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,3,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its Defense!",attacker.pbThis))
    end
  elsif spatk1.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,1,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its Special Attack!",attacker.pbThis))
    end
  elsif spatk2.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,2,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its Special Attack!",attacker.pbThis))
    end
  elsif spatk3.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,3,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its Special Attack!",attacker.pbThis))
    end
  elsif spdef1.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its special Defense!",attacker.pbThis))
    end
  elsif spdef2.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,2,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its special Defense!",attacker.pbThis))
    end
  elsif spdef3.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,3,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its special Defense!",attacker.pbThis))
    end
  elsif speed1.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,1,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its Speed!",attacker.pbThis))
    end
  elsif speed2.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,2,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its Speed!",attacker.pbThis))
    end
  elsif speed3.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,3,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its Speed!",attacker.pbThis))
    end
  elsif acc1.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
      attacker.pbIncreaseStat(PBStats::ACCURACY,1,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its Accuracy!",attacker.pbThis))
    end
  elsif acc2.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
      attacker.pbIncreaseStat(PBStats::ACCURACY,2,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its Accuracy!",attacker.pbThis))
    end
  elsif acc3.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
      attacker.pbIncreaseStat(PBStats::ACCURACY,3,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its Accuracy!",attacker.pbThis))
    end
  elsif eva1.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
      attacker.pbIncreaseStat(PBStats::EVASION,1,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its Evasion!",attacker.pbThis))
    end
  elsif eva2.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
      attacker.pbIncreaseStat(PBStats::EVASION,2,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its Evasion!",attacker.pbThis))
    end
  elsif eva3.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
      attacker.pbIncreaseStat(PBStats::EVASION,3,false,nil,nil,false,true,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its Evasion!",attacker.pbThis))
    end
  elsif stat1.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,1,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,1,false,nil,nil,false,true,false)
    end
    @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its stats!",attacker.pbThis))
  elsif stat2.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,2,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,2,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,2,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,2,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,2,false,nil,nil,false,true,false)
    end
    @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its stats!",attacker.pbThis))
  elsif stat3.include?(move)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,3,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,3,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,3,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,3,false,nil,nil,false,true,false)
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,3,false,nil,nil,false,true,false)
    end
    @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its stats!",attacker.pbThis))
  elsif crit1.include?(move)
    if attacker.effects[PBEffects::FocusEnergy]<3
      attacker.effects[PBEffects::FocusEnergy]+=2
      attacker.effects[PBEffects::FocusEnergy]=3 if attacker.effects[PBEffects::FocusEnergy]>3
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power is getting it pumped!",attacker.pbThis))
    end
  elsif reset.include?(move)
    for i in [PBStats::ATTACK,PBStats::DEFENSE,
        PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
        PBStats::EVASION,PBStats::ACCURACY]
      if attacker.stages[i]<0
        attacker.stages[i]=0
      end
    end
    @battle.pbDisplayBrief(_INTL("{1}'s Z-Power returned its decreased stats to normal!",attacker.pbThis))
  elsif heal.include?(move)
    attacker.pbRecoverHP(attacker.totalhp,false)
    @battle.pbDisplayBrief(_INTL("{1}'s Z-Power restored its health!",attacker.pbThis))
  elsif heal2.include?(move)
    attacker.effects[PBEffects::ZHeal]=true
  elsif centre.include?(move)
    attacker.effects[PBEffects::FollowMe]=true
    if !attacker.pbPartner.isFainted?
      attacker.pbPartner.effects[PBEffects::FollowMe]=false
      attacker.pbPartner.effects[PBEffects::RagePowder]=false  
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power made it the centre of attention!",attacker.pbThis))
    end
  end    
end

end
