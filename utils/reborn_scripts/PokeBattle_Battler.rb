class PokeBattle_Battler
  attr_reader :battle
  attr_accessor :pokemon
  attr_reader :personalID
  attr_reader :name
  attr_reader :index
  attr_reader :pokemonIndex
  attr_reader :totalhp
  attr_reader :fainted
  attr_reader :usingsubmove
  attr_reader :level
  attr_accessor :lastAttacker
  attr_accessor :turncount
  attr_accessor :effects
  attr_accessor :species
  attr_accessor :type1
  attr_accessor :type2
  attr_accessor :ability
  attr_accessor :gender
  attr_accessor :attack
  attr_accessor :defense
  attr_accessor :spatk
  attr_accessor :spdef
  attr_accessor :speed
  attr_accessor :baseExp
  attr_accessor :evYield
  attr_accessor :stages
  attr_accessor :iv
  attr_accessor :moves
  attr_accessor :participants
  attr_accessor :lastHPLost
  attr_accessor :lastMoveUsed
  attr_accessor :lastMoveUsedSketch
  attr_accessor :lastRegularMoveUsed
  attr_accessor :lastRoundMoved
  attr_accessor :movesUsed
  attr_accessor :currentMove
  attr_accessor :damagestate
  attr_accessor :unburdened
  attr_accessor :previousMove
  attr_accessor :selectedMove
  attr_accessor :wonderroom
  attr_accessor :itemUsed
  attr_accessor :itemUsed2  #Stays while the battler is out
  attr_accessor :userSwitch
  attr_accessor :forcedSwitch
  attr_accessor :forcedSwitchEarlier
  attr_accessor :midwayThroughMove
  attr_accessor :vanished
  attr_accessor :custap
  attr_accessor :moldbroken
  attr_accessor :corroded
  attr_accessor :startform
  attr_accessor :statLowered
  attr_accessor :missAcc
  attr_accessor :backupability
  attr_accessor :takegem
  attr_accessor :lastMoveChoice
  attr_accessor :isFirstMoveOfRound
  attr_accessor :statupanimplayed
  attr_accessor :statdownanimplayed
  attr_accessor :statrepeat
  def inHyperMode?; return false; end
  def isShadow?; return false; end

################################################################################
# Complex accessors
################################################################################
  def nature
    return (@pokemon) ? @pokemon.nature : 0
  end

  def ev
    return (@pokemon) ? @pokemon.ev : 0
  end

  def happiness
    return (@pokemon) ? @pokemon.happiness : 0
  end

  def pokerusStage
    return (@pokemon) ? @pokemon.pokerusStage : 0
  end

  attr_reader :form

  def form=(value)
    @form=value
    @pokemon.form=value if @pokemon
  end

  def name=(value)
    @name=value
  end

  def hasMega?
    if @pokemon
      return (@pokemon.hasMegaForm? rescue false)
    end
    return false
  end

  def hasUltra?
    if @pokemon
      return (@pokemon.hasUltraForm? rescue false)
    end
    return false
  end

  def pbZCrystalFromType(type)
    return PBStuff::TYPETOZCRYSTAL[type]
  end

  def hasZMove?
    pkmn=self
    canuse=false

    zcrystal_to_type = PBStuff::TYPETOZCRYSTAL.invert
    canuse = pkmn.moves.any?{|stuffthings| stuffthings.type == zcrystal_to_type[pkmn.item]} if zcrystal_to_type[pkmn.item]
    
    case pkmn.item
    when (PBItems::ALORAICHIUMZ2)
      if pkmn.pokemon.species==PBSpecies::RAICHU && pkmn.form==1
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::THUNDERBOLT}
      end
    when (PBItems::DECIDIUMZ2)
      if pkmn.pokemon.species==PBSpecies::DECIDUEYE
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::SPIRITSHACKLE}
      end
    when (PBItems::INCINIUMZ2)
      if pkmn.pokemon.species==PBSpecies::INCINEROAR
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::DARKESTLARIAT}
      end
    when (PBItems::PRIMARIUMZ2)
      if pkmn.pokemon.species==PBSpecies::PRIMARINA
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::SPARKLINGARIA}
      end
    when (PBItems::EEVIUMZ2)
      if pkmn.pokemon.species==PBSpecies::EEVEE
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::LASTRESORT}
      end
    when (PBItems::PIKANIUMZ2)
      if pkmn.pokemon.species==PBSpecies::PIKACHU
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::VOLTTACKLE}
      end
    when (PBItems::SNORLIUMZ2)
      if pkmn.pokemon.species==PBSpecies::SNORLAX
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::GIGAIMPACT}
      end
    when (PBItems::MEWNIUMZ2)
      if pkmn.pokemon.species==PBSpecies::MEW
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::PSYCHIC}
      end
    when (PBItems::TAPUNIUMZ2)
      if pkmn.pokemon.species==PBSpecies::TAPUKOKO || pkmn.pokemon.species==PBSpecies::TAPULELE || pkmn.pokemon.species==PBSpecies::TAPUFINI || pkmn.pokemon.species==PBSpecies::TAPUBULU
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::NATURESMADNESS}
      end
    when (PBItems::MARSHADIUMZ2)
      if pkmn.pokemon.species==PBSpecies::MARSHADOW
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::SPECTRALTHIEF}
      end
    when (PBItems::KOMMONIUMZ2)
      if pkmn.pokemon.species==PBSpecies::KOMMOO
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::CLANGINGSCALES}
      end
    when (PBItems::LYCANIUMZ2)
      if pkmn.pokemon.species==PBSpecies::LYCANROC
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::STONEEDGE}
      end
    when (PBItems::MIMIKIUMZ2)
      if pkmn.pokemon.species==PBSpecies::MIMIKYU
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::PLAYROUGH}
      end
    when (PBItems::SOLGANIUMZ2)
      if (pkmn.pokemon.species==PBSpecies::NECROZMA && pkmn.form==1) || pkmn.pokemon.species==PBSpecies::SOLGALEO
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::SUNSTEELSTRIKE}
      end
    when (PBItems::LUNALIUMZ2)
      if (pkmn.pokemon.species==PBSpecies::NECROZMA && pkmn.form==2) || pkmn.pokemon.species==PBSpecies::LUNALA
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::MOONGEISTBEAM}
      end
    when (PBItems::ULTRANECROZIUMZ2)
      if pkmn.pokemon.species==PBSpecies::NECROZMA && pkmn.form==3
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::PHOTONGEYSER}
      end
    end
    return canuse
  end

  def pbCompatibleZMoveFromMove?(move,moveindex = false)
    pkmn=self
    move = pkmn.moves[move] if moveindex == true

    zcrystal_to_type = PBStuff::TYPETOZCRYSTAL.invert
    return true if zcrystal_to_type[pkmn.item] == move.type

    case pkmn.item
      when PBItems::ALORAICHIUMZ2     then return true if move.id==PBMoves::THUNDERBOLT
      when PBItems::DECIDIUMZ2        then return true if move.id==PBMoves::SPIRITSHACKLE
      when PBItems::INCINIUMZ2        then return true if move.id==PBMoves::DARKESTLARIAT
      when PBItems::PRIMARIUMZ2       then return true if move.id==PBMoves::SPARKLINGARIA
      when PBItems::EEVIUMZ2          then return true if move.id==PBMoves::LASTRESORT
      when PBItems::PIKANIUMZ2        then return true if move.id==PBMoves::VOLTTACKLE
      when PBItems::SNORLIUMZ2        then return true if move.id==PBMoves::GIGAIMPACT
      when PBItems::MEWNIUMZ2         then return true if move.id==PBMoves::PSYCHIC
      when PBItems::TAPUNIUMZ2        then return true if move.id==PBMoves::NATURESMADNESS
      when PBItems::MARSHADIUMZ2      then return true if move.id==PBMoves::SPECTRALTHIEF
      when PBItems::KOMMONIUMZ2       then return true if move.id==PBMoves::CLANGINGSCALES
      when PBItems::LYCANIUMZ2        then return true if move.id==PBMoves::STONEEDGE
      when PBItems::MIMIKIUMZ2        then return true if move.id==PBMoves::PLAYROUGH
      when PBItems::SOLGANIUMZ2       then return true if move.id==PBMoves::SUNSTEELSTRIKE
      when PBItems::LUNALIUMZ2        then return true if move.id==PBMoves::MOONGEISTBEAM
      when PBItems::ULTRANECROZIUMZ2  then return true if move.id==PBMoves::PHOTONGEYSER
    end
    return false
  end

  def battlerToPokemon
    return @pokemon
  end

  def isMega?
    if @pokemon
      return (@pokemon.isMega? rescue false)
    end
    return false
  end

  def isUltra?
    if @pokemon
      return (@pokemon.isUltra? rescue false)
    end
    return false
  end

  def makeUnultra
    if isUltra?
      return self.form = @startform
    end
    return false
  end

  def level=(value)
    @level=value
    @pokemon.level=(value) if @pokemon
  end

  attr_reader :status

  def status=(value)
    if @status==PBStatuses::SLEEP && value==0
      @effects[PBEffects::Truant]=false
    end
    @status=value
    @pokemon.status=value if @pokemon
    if value!=PBStatuses::POISON
      @effects[PBEffects::Toxic]=0
    end
    if value!=PBStatuses::POISON && value!=PBStatuses::SLEEP
      @statusCount=0
      @pokemon.statusCount=0 if @pokemon
    end
  end

  attr_reader :statusCount

  def statusCount=(value)
    @statusCount=value
    @pokemon.statusCount=value if @pokemon
  end

  attr_reader :hp

  def hp=(value)
    @hp=value.to_i
    @pokemon.hp=value.to_i if @pokemon
  end

  attr_reader :item

  def item=(value)
    # UPDATE 11/19/2013
    # Initial pass for implementing UNBURDEN
    # pokemon has lost their item
    if @item != 0 && value == 0
      if @ability == PBAbilities::UNBURDEN && !@unburdened
        @unburdened = true
      end
    end
    # end update
    @item=value
    @pokemon.item=value if @pokemon
  end

  def weight
    w=(@pokemon) ? @pokemon.weight : 500
    w*=2 if self.ability == PBAbilities::HEAVYMETAL && !(self.moldbroken)
    w/=2 if self.ability == PBAbilities::LIGHTMETAL && !(self.moldbroken)
    w/=2 if self.hasWorkingItem(:FLOATSTONE)
    w*=@effects[PBEffects::WeightMultiplier]
    w=1 if w<1
    return w
  end

  def owned
    return (@pokemon) ? $Trainer.owned[@pokemon.species] && !@battle.opponent : false
  end

################################################################################
# Creating a battler
################################################################################
  def initialize(btl,index,fakebattler=false)
    @battle       = btl
    @index        = index
    @hp           = 0
    @totalhp      = 0
    @fainted      = true
    @usingsubmove = false
    @stages       = []
    @effects      = []
    @damagestate  = PokeBattle_DamageState.new
    @unburdened   = false
    @wonderroom   = false
    @userSwitch   = false
    @forcedSwitch = false
    @forcedSwitchEarlier = false
    @midwayThroughMove = false
    @vanished     = false
    @custap       = false
    @moldbroken   = false
    @corroded     = false
    @takegem      = false
    @statupanimplayed = false
    @statdownanimplayed = false
    @statrepeat = false
    pbInitBlank
    pbInitEffects(false,fakebattler)
    pbInitPermanentEffects
  end

  def pbInitPokemon(pkmn,pkmnIndex)
    if pkmn.isEgg?
      raise _INTL("An egg can't be an active Pokémon")
    end
    @name         = pkmn.name
    @species      = pkmn.species
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @gender       = pkmn.gender
    @ability      = pkmn.ability
    @backupability= pkmn.ability
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @form         = pkmn.form
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @speed        = pkmn.speed
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @baseExp      = pkmn.baseExp
    @evYield      = pkmn.evYield
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @personalID   = pkmn.personalID
    @pokemon      = pkmn
    @pokemonIndex = pkmnIndex
    @participants = [] # Participants will earn Exp. Points if this battler is defeated
    @moves        = [
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[0],pkmn),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[1],pkmn),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[2],pkmn),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[3],pkmn)
    ]
    @iv           = []
    @iv[0]        = pkmn.iv[0]
    @iv[1]        = pkmn.iv[1]
    @iv[2]        = pkmn.iv[2]
    @iv[3]        = pkmn.iv[3]
    @iv[4]        = pkmn.iv[4]
    @iv[5]        = pkmn.iv[5]
    @item         = pkmn.item
    @startform = @form
  end

  def pbInitBlank
    @name         = ""
    @species      = 0
    @level        = 0
    @hp           = 0
    @totalhp      = 0
    @gender       = 0
    @ability      = 0
    @type1        = 0
    @type2        = 0
    @form         = 0
    @attack       = 0
    @defense      = 0
    @speed        = 0
    @spatk        = 0
    @spdef        = 0
    @baseExp      = 0
    @evYield      = [0,0,0,0,0,0]
    @status       = 0
    @statusCount  = 0
    @pokemon      = nil
    @pokemonIndex = -1
    @participants = []
    @moves        = [nil,nil,nil,nil]
    @iv           = [0,0,0,0,0,0]
    @item         = 0
    @weight       = nil
  end

  def pbInitPermanentEffects
    # These effects are always retained even if a Pokémon is replaced
    @effects[PBEffects::FutureSight]       = 0
    @effects[PBEffects::FutureSightMove]   = 0
    @effects[PBEffects::FutureSightUser]   = -1
    @effects[PBEffects::HealingWish]       = false
    @effects[PBEffects::LunarDance]        = false
    @effects[PBEffects::Wish]              = 0
    @effects[PBEffects::WishAmount]        = 0
    @effects[PBEffects::WishMaker]         = -1
    @effects[PBEffects::ZHeal]             = false
  end

  def pbInitEffects(batonpass, fakebattler=false)
    if !batonpass
      # These effects are retained if Baton Pass is used
      @stages[PBStats::ATTACK]   = 0
      @stages[PBStats::DEFENSE]  = 0
      @stages[PBStats::SPEED]    = 0
      @stages[PBStats::SPATK]    = 0
      @stages[PBStats::SPDEF]    = 0
      @stages[PBStats::EVASION]  = 0
      @stages[PBStats::ACCURACY] = 0
      @effects[PBEffects::AquaRing]    = false
      @effects[PBEffects::Confusion]   = 0
      @effects[PBEffects::Curse]       = false
      @effects[PBEffects::Embargo]     = 0
      @effects[PBEffects::FocusEnergy] = 0
      @effects[PBEffects::LaserFocus]  = 0
      @effects[PBEffects::GastroAcid]  = false
      @effects[PBEffects::HealBlock]   = 0
      @effects[PBEffects::Ingrain]     = false
      @effects[PBEffects::LeechSeed]   = -1
      @effects[PBEffects::LockOn]      = 0
      @effects[PBEffects::LockOnPos]   = -1
      for i in 0...4
        next if !@battle.battlers[i] || fakebattler
        if @battle.battlers[i].effects[PBEffects::LockOnPos]==@index &&
           @battle.battlers[i].effects[PBEffects::LockOn]>0
          @battle.battlers[i].effects[PBEffects::LockOn]=0
          @battle.battlers[i].effects[PBEffects::LockOnPos]=-1
        end
      end
      @effects[PBEffects::MagnetRise]     = 0
      @effects[PBEffects::PerishSong]     = 0
      @effects[PBEffects::PerishSongUser] = -1
      @effects[PBEffects::PowerTrick]     = false
      @effects[PBEffects::Substitute]     = 0
      @effects[PBEffects::Telekinesis]    = 0
    else
      if @effects[PBEffects::LockOn]>0
        @effects[PBEffects::LockOn]=2
      else
        @effects[PBEffects::LockOn]=0
      end
      if @effects[PBEffects::PowerTrick]
        self.attack, self.defense = self.defense, self.attack
      end
    end

    @damagestate.reset
    @fainted              = false
    @lastAttacker         = -1
    @lastHPLost           = 0
    @lastMoveUsed         = -1
    @previousMove         = -1
    @lastRegularMoveUsed  = -1
    @lastMoveUsedSketch   = -1
    @lastRoundMoved       = -1
    @itemUsed             = false
    @itemUsed2            = false
    @movesUsed            = []
    @turncount            = 0
    @effects[PBEffects::Disguise]         = false
    @effects[PBEffects::IceFace]          = false
    @effects[PBEffects::Disguise]         = true if self.species==PBSpecies::MIMIKYU && self.form==0 # Mimikyu
    @effects[PBEffects::IceFace]          = true if self.species==875 && self.form==0 # Eiscue
    @effects[PBEffects::Attract]          = -1
    @effects[PBEffects::Bide]             = 0
    @effects[PBEffects::BideDamage]       = 0
    @effects[PBEffects::BideTarget]       = -1
    @effects[PBEffects::Charge]           = 0
    @effects[PBEffects::ChoiceBand]       = -1
    @effects[PBEffects::Counter]          = -1
    @effects[PBEffects::CounterTarget]    = -1
    @effects[PBEffects::DefenseCurl]      = false
    @effects[PBEffects::DestinyBond]      = false
    @effects[PBEffects::Disable]          = 0
    @effects[PBEffects::DisableMove]      = 0
    @effects[PBEffects::EchoedVoice]      = 0
    @effects[PBEffects::Encore]           = 0
    @effects[PBEffects::EncoreIndex]      = 0
    @effects[PBEffects::EncoreMove]       = 0
    @effects[PBEffects::Endure]           = false
    @effects[PBEffects::FairyLockRate]    = false
    @effects[PBEffects::FlashFire]        = false
    @effects[PBEffects::Flinch]           = false
    @effects[PBEffects::FollowMe]         = false
    @effects[PBEffects::RagePowder]       = false
    @effects[PBEffects::Foresight]        = false
    @effects[PBEffects::FuryCutter]       = 0
    @effects[PBEffects::Grudge]           = false
    @effects[PBEffects::HelpingHand]      = false
    @effects[PBEffects::HyperBeam]        = 0
    @effects[PBEffects::Imprison]         = false
    @effects[PBEffects::MagicCoat]        = false
    @effects[PBEffects::MagicBounced]     = false
    @effects[PBEffects::MeanLook]         = -1
    @effects[PBEffects::NoRetreat]        = false
    @effects[PBEffects::Octolock ]        = false
    @effects[PBEffects::ShellTrapTarget]  = -1
    @effects[PBEffects::BouncedMove]      =  0
    @effects[PBEffects::Metronome]        = 0
    @effects[PBEffects::Minimize]         = false
    @effects[PBEffects::MiracleEye]       = false
    @effects[PBEffects::MirrorCoat]       = -1
    @effects[PBEffects::MirrorCoatTarget] = -1
    #@effects[PBEffects::MudSport]         = false
    @effects[PBEffects::MultiTurn]        = 0
    @effects[PBEffects::MultiTurnAttack]  = 0
    @effects[PBEffects::MultiTurnUser]    = -1
    @effects[PBEffects::Nightmare]        = false
    @effects[PBEffects::Outrage]          = 0
    @effects[PBEffects::Pinch]            = false
    @effects[PBEffects::Protect]          = false
    @effects[PBEffects::Obstruct]         = false
    @effects[PBEffects::KingsShield]      = false # add this line
    @effects[PBEffects::SpikyShield]      = false # and this one
    @effects[PBEffects::WideGuardCheck]   = false
    @effects[PBEffects::WideGuardUser]    = false
    @effects[PBEffects::BanefulBunker]    = false
    @effects[PBEffects::ProtectNegation]  = false
    @effects[PBEffects::ProtectRate]      = 1
    @effects[PBEffects::DestinyRate]      = false
    @effects[PBEffects::Pursuit]          = false
    @effects[PBEffects::Rage]             = false
    @effects[PBEffects::Revenge]          = 0
    @effects[PBEffects::Rollout]          = 0
    @effects[PBEffects::Roost]            = false
    @effects[PBEffects::SkyDrop]          = false
    @effects[PBEffects::SmackDown]        = false
    @effects[PBEffects::Snatch]           = false
    @effects[PBEffects::Stockpile]        = 0
    @effects[PBEffects::StockpileDef]     = 0
    @effects[PBEffects::StockpileSpDef]   = 0
    @effects[PBEffects::Taunt]            = 0
    @effects[PBEffects::Torment]          = false
    @effects[PBEffects::Toxic]            = 0
    @effects[PBEffects::Trace]            = false
    @effects[PBEffects::TracedAbility]    = 0
    @effects[PBEffects::Transform]        = false
    @effects[PBEffects::Truant]           = false
    @effects[PBEffects::TwoTurnAttack]    = 0
    @effects[PBEffects::SkyDroppee]       = nil
    @effects[PBEffects::Uproar]           = 0
    @effects[PBEffects::UsingSubstituteRightNow] = false
    #@effects[PBEffects::WaterSport]       = false
    @effects[PBEffects::WeightMultiplier] = 1.0
    @effects[PBEffects::Yawn]             = 0
    @effects[PBEffects::BeakBlast]        = false
    @effects[PBEffects::BurnUp]           = false
    @effects[PBEffects::ClangedScales]    = false
    @effects[PBEffects::ShellTrap]        = false
    @effects[PBEffects::SpeedSwap]        = 0
    @effects[PBEffects::Tantrum]          = false
    @effects[PBEffects::ThroatChop]      = 0
    #@effects[PBEffects::Belch]            = false
    @effects[PBEffects::ParentalBond]     = false
    @effects[PBEffects::Round]            = false
    @effects[PBEffects::Powder]           = false
    @effects[PBEffects::Electrify]        = false
    @effects[PBEffects::TarShot]          = false
    @effects[PBEffects::MeFirst]          = false
    for i in 0...4
      next if !@battle.battlers[i] || fakebattler
      if @battle.battlers[i].effects[PBEffects::MultiTurnUser]==@index
        @battle.battlers[i].effects[PBEffects::MultiTurn]=0
        @battle.battlers[i].effects[PBEffects::MultiTurnUser]=-1
      end
      if @battle.battlers[i].effects[PBEffects::MeanLook]==@index
        @battle.battlers[i].effects[PBEffects::MeanLook]=-1
      end
      if @battle.battlers[i].effects[PBEffects::Attract]==@index
        @battle.battlers[i].effects[PBEffects::Attract]=-1
      end
    end
    if (self.ability == PBAbilities::ILLUSION) 
      party=@battle.pbPartySingleOwner(@index) #new method for splitting teams
      party=party.find_all {|item| item && !item.egg? && item.hp>0 }
      if party[party.length-1] != @pokemon
        @effects[PBEffects::Illusion] = party[party.length-1]
      end
    end 
  end

  def pbUpdate(fullchange=false)
    if @pokemon
      @pokemon.calcStats
      @level     = @pokemon.level
      @hp        = @pokemon.hp
      @totalhp   = @pokemon.totalhp
      if !@effects[PBEffects::Transform]
        @attack    = @pokemon.attack
        @defense   = @pokemon.defense
        @speed     = @pokemon.speed
        @spatk     = @pokemon.spatk
        @spdef     = @pokemon.spdef
        @spdef, @defense = @defense, @spdef if @wonderroom
        @attack, @defense = @defense, @attack if @effects[PBEffects::PowerTrick]
        if fullchange
          @baseExp   = @pokemon.baseExp
          @evYield   = @pokemon.evYield
          @ability = @pokemon.ability if abilityWorks?
          @type1   = @pokemon.type1
          @type2   = @pokemon.type2
        end
      end
    end
  end

  def pbInitialize(pkmn,index,batonpass)
    # Cure status of previous Pokemon with Natural Cure
    if self.ability == PBAbilities::NATURALCURE || (self.ability == PBAbilities::TRACE &&
      self.effects[PBEffects::TracedAbility]==PBAbilities::NATURALCURE) && @pokemon
      self.status=0
    end
    if (self.ability == PBAbilities::REGENERATOR || (self.ability == PBAbilities::TRACE &&
      self.effects[PBEffects::TracedAbility]==PBAbilities::REGENERATOR)) && @pokemon && @hp>0
        self.pbRecoverHP((totalhp/3.0).floor)
    end
    pbInitPokemon(pkmn,index)
    pbInitEffects(batonpass)
  end

# Used only to erase the battler of a Shadow Pokémon that has been snagged.
  def pbReset
    @pokemon                = nil
    @pokemonIndex           = -1
    self.hp                 = 0
    pbInitEffects(false)
    # reset status
    self.status             = 0
    self.statusCount        = 0
    @fainted                = true
    # reset choice
    @battle.choices[@index] = [0,0,nil,-1]
    return true
  end

# Update Pokémon who will gain EXP if this battler is defeated
  def pbUpdateParticipants
    return if self.isFainted? # can't update if already fainted
    if @battle.pbIsOpposing?(@index)
      found1=false
      found2=false
      for i in @participants
        found1=true if i==pbOpposing1.pokemonIndex
        found2=true if i==pbOpposing2.pokemonIndex
      end
      if !found1 && !pbOpposing1.isFainted?
        @participants.push(pbOpposing1.pokemonIndex)
      end
      if !found2 && !pbOpposing2.isFainted?
        @participants.push(pbOpposing2.pokemonIndex)
      end
    end
  end

  def formFromItem
    if @species == PBSpecies::SILVALLY
      case @item
        when PBItems::FIGHTINGMEMORY    then return 1
        when PBItems::FLYINGMEMORY      then return 2
        when PBItems::POISONMEMORY      then return 3
        when PBItems::GROUNDMEMORY      then return 4
        when PBItems::ROCKMEMORY        then return 5
        when PBItems::BUGMEMORY         then return 6
        when PBItems::GHOSTMEMORY       then return 7
        when PBItems::STEELMEMORY       then return 8
        when PBItems::FIREMEMORY        then return 10
        when PBItems::WATERMEMORY       then return 11
        when PBItems::GRASSMEMORY       then return 12
        when PBItems::ELECTRICMEMORY    then return 13
        when PBItems::PSYCHICMEMORY     then return 14
        when PBItems::ICEMEMORY         then return 15
        when PBItems::DRAGONMEMORY      then return 16
        when PBItems::DARKMEMORY        then return 17
        when PBItems::FAIRYMEMORY       then return 18
        else return 0
      end
    elsif @species == PBSpecies::ARCEUS
      case @item
        when PBItems::FISTPLATE, PBItems::FIGHTINIUMZ2    then return 1
        when PBItems::SKYPLATE, PBItems::FLYINIUMZ2       then return 2
        when PBItems::TOXICPLATE, PBItems::POISONIUMZ2    then return 3
        when PBItems::EARTHPLATE, PBItems::GROUNDIUMZ2    then return 4
        when PBItems::STONEPLATE, PBItems::ROCKIUMZ2      then return 5
        when PBItems::INSECTPLATE, PBItems::BUGINIUMZ2    then return 6
        when PBItems::SPOOKYPLATE, PBItems::GHOSTIUMZ2    then return 7
        when PBItems::IRONPLATE, PBItems::STEELIUMZ2      then return 8
        when PBItems::FLAMEPLATE, PBItems::FIRIUMZ2       then return 10
        when PBItems::SPLASHPLATE, PBItems::WATERIUMZ2    then return 11
        when PBItems::MEADOWPLATE, PBItems::GRASSIUMZ2    then return 12
        when PBItems::ZAPPLATE, PBItems::ELECTRIUMZ2      then return 13
        when PBItems::MINDPLATE, PBItems::PSYCHIUMZ2      then return 14
        when PBItems::ICICLEPLATE, PBItems::ICIUMZ2       then return 15
        when PBItems::DRACOPLATE, PBItems::DRAGONIUMZ2    then return 16
        when PBItems::DREADPLATE, PBItems::DARKINIUMZ2    then return 17
        when PBItems::PIXIEPLATE, PBItems::FAIRIUMZ2      then return 18
        else return 0
      end
    end
  end

################################################################################
# About this battler
################################################################################
  def pbThis(lowercase=false)
    if @battle.pbIsOpposing?(@index)
      if @battle.opponent
        return lowercase ? _INTL("the foe {1}",PBSpecies.getName(self.species)) : _INTL("The foe {1}",PBSpecies.getName(self.species))
      else
        return lowercase ? _INTL("the wild {1}",self.name) : _INTL("The wild {1}",self.name)
      end
    elsif @battle.pbOwnedByPlayer?(@index)
      return _INTL("{1}",self.name)
    else
      return lowercase ? _INTL("the ally {1}",self.name) : _INTL("The ally {1}",self.name)
    end
  end

  def name 
    return @effects[PBEffects::Illusion] != nil  ? @effects[PBEffects::Illusion].name : @name
  end 

  def species 
    return @effects[PBEffects::Illusion] != nil  ? @effects[PBEffects::Illusion].species : @species
  end

  def pbHasType?(type)
    if type.is_a?(Symbol) || type.is_a?(String)
      ret=isConst?(self.type1,PBTypes,type.to_sym) ||
          isConst?(self.type2,PBTypes,type.to_sym)
      return ret
    else
      return (self.type1==type || self.type2==type)
    end
  end

  def hasType?(type) # for typemod non-battler ease
    if type.is_a?(Symbol) || type.is_a?(String)
      ret=isConst?(self.type1,PBTypes,type.to_sym) ||
          isConst?(self.type2,PBTypes,type.to_sym)
      return ret
    else
      return (self.type1==type || self.type2==type)
    end
  end

  def pbHasMove?(id)
    if id.is_a?(String) || id.is_a?(Symbol)
      id=(PBMoves::id)
    end
    return false if !id || id==0
    for i in @moves
      next if i.nil?
      return true if i.id==id
    end
    return false
  end

  def pbHasMoveFunction?(code)
    return false if !code
    for i in @moves
      return true if i.function==code
    end
    return false
  end

  def hasMovedThisRound?
    return false if !@lastRoundMoved
    return @lastRoundMoved==@battle.turncount
  end

  def isFainted?
    return @hp<=0
  end

  def abilityWorks?(ignorefainted=false)
    return false if self.isFainted? if !ignorefainted
    return false if @effects[PBEffects::GastroAcid]
    return false if @battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)
    return true
  end

  def hasWorkingAbility(ability,ignorefainted=false)
    ability = PBAbilities.const_get(ability.to_sym)
    return false if self.isFainted? if !ignorefainted
    return false if @effects[PBEffects::GastroAcid]
    if !(PBStuff::FIXEDABILITIES).include?(ability) && ability!=PBAbilities::NEUTRALIZINGGAS
      return false if @battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)
    end
    return @ability == ability
  end

  def itemWorks?(ignorefainted=false)
    return false if self.isFainted? if !ignorefainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.state.effects[PBEffects::MagicRoom]>0
    return false if self.ability == PBAbilities::KLUTZ
    return true
  end

  def hasWorkingItem(item,ignorefainted=false)
    return false if self.isFainted? if !ignorefainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.state.effects[PBEffects::MagicRoom]>0
    return false if self.ability == PBAbilities::KLUTZ
    return @item == PBItems.const_get(item.to_sym)
  end

  def isAirborne?
    return false if self.item == PBItems::IRONBALL
    return false if @effects[PBEffects::Ingrain]
    return false if @effects[PBEffects::SmackDown]
    return false if @battle.state.effects[PBEffects::Gravity]>0
    return true if self.pbHasType?(:FLYING) && @effects[PBEffects::Roost]==false
    return true if self.ability == PBAbilities::LEVITATE
    return true if self.item == PBItems::AIRBALLOON && self.itemWorks?
    return true if @effects[PBEffects::MagnetRise]>0
    return true if @effects[PBEffects::Telekinesis]>0
    return false
  end

  def nullsElec?
    return [PBAbilities::VOLTABSORB,PBAbilities::LIGHTNINGROD,PBAbilities::MOTORDRIVE].include?(@ability) || pbPartner.ability == PBAbilities::LIGHTNINGROD
  end

  def nullsWater?
    return [PBAbilities::WATERABSORB,PBAbilities::STORMDRAIN,PBAbilities::DRYSKIN].include?(@ability) || pbPartner.ability == PBAbilities::STORMDRAIN
  end

  def nullsFire?
    return @ability == PBAbilities::FLASHFIRE
  end

  def nullsGrass?
    return @ability == PBAbilities::SAPSIPPER
  end

  def pbSpeed()
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    if @effects[PBEffects::SpeedSwap] == 0
      speed=@speed
    else
      speed=@effects[PBEffects::SpeedSwap]
    end
    stage=@stages[PBStats::SPEED]+6
    speed=(speed*stagemul[stage]/stagediv[stage]).floor
    if @unburdened
      speed=speed*2
    end
    if self.pbOwnSide.effects[PBEffects::Tailwind]>0
      speed=speed*2
    end
    case self.ability
      when PBAbilities::SWIFTSWIM
        speed*=2 if @battle.pbWeather==PBWeather::RAINDANCE && !self.hasWorkingItem(:UTILITYUMBRELLA) || [PBFields::WATERS,PBFields::UNDERWATER,PBFields::MURKWATERS].include?(@battle.FE)
      when PBAbilities::SURGESURFER
        speed*=2 if [PBFields::ELECTRICT,PBFields::SHORTCIRCUITF,PBFields::WATERS,PBFields::UNDERWATER,PBFields::MURKWATERS].include?(@battle.FE)
      when PBAbilities::TELEPATHY
        speed*=2 if (@battle.FE == PBFields::PSYCHICT)
      when PBAbilities::CHLOROPHYLL
        speed*=2 if (@battle.pbWeather==PBWeather::SUNNYDAY || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter > 2)) && !self.hasWorkingItem(:UTILITYUMBRELLA)
      when PBAbilities::QUICKFEET
        speed*=1.5 if self.status>0
      when PBAbilities::SANDRUSH
        speed*=2 if @battle.pbWeather==PBWeather::SANDSTORM || @battle.FE == PBFields::DESERTF || @battle.FE == PBFields::ASHENB
      when PBAbilities::SLUSHRUSH
        speed*=2 if @battle.pbWeather==PBWeather::HAIL || @battle.FE==PBFields::ICYF || @battle.FE==PBFields::SNOWYM
      when PBAbilities::SLOWSTART
        speed*=0.5 if self.turncount<5
    end
    case @battle.FE
      when PBFields::NEWW
        speed*=0.75 if !self.isAirborne?
      when PBFields::WATERS, PBFields::MURKWATERS
        speed*=0.75 if !self.isAirborne? && self.ability != PBAbilities::SURGESURFER && self.ability != PBAbilities::SWIFTSWIM && !self.pbHasType?(:WATER)
      when PBFields::UNDERWATER
        speed*=0.5 if !self.pbHasType?(:WATER) && self.ability != PBAbilities::SWIFTSWIM && self.ability != PBAbilities::STEELWORKER
    end
    if self.itemWorks?
      if (self.item == PBItems::CHOICESCARF)
        speed=(speed*1.5).floor
      elsif (self.item == PBItems::MACHOBRACE) || (self.item == PBItems::POWERWEIGHT) || (self.item == PBItems::POWERBRACER) || (self.item == PBItems::POWERBELT) || (self.item == PBItems::POWERANKLET) || (self.item == PBItems::POWERLENS) || (self.item == PBItems::POWERBAND)
        speed=(speed/2.0).floor
      end
    end
    speed*=0.5 if self.item == PBItems::IRONBALL
    if self.status==PBStatuses::PARALYSIS && self.ability != PBAbilities::QUICKFEET
      speed=(speed/2.0).floor
    end
    speed = 1 if speed <= 1
    return speed
  end

################################################################################
# Change HP
################################################################################
  def pbReduceHP(amt,anim=false,emercheck=true)
    if amt>=self.hp
      amt=self.hp
    elsif amt<=0 && !self.isFainted?
      amt=1
    end
    oldhp=self.hp
    self.hp-=amt
    raise _INTL("HP less than 0") if self.hp<0
    raise _INTL("HP greater than total HP") if self.hp>@totalhp
    @battle.scene.pbHPChanged(self,oldhp,anim) if amt>0
    pbEmergencyExitCheck(oldhp) if emercheck
    return amt
  end

  def pbRecoverHP(amt,anim=false)
    if self.hp+amt>@totalhp
      amt=@totalhp-self.hp
    elsif amt<=0 && self.hp!=@totalhp
      amt=1
    end
    oldhp=self.hp
    self.hp+=amt
    raise _INTL("HP less than 0") if self.hp<0
    raise _INTL("HP greater than total HP") if self.hp>@totalhp
    @battle.scene.pbHPChanged(self,oldhp,anim) if amt>0
    return amt
  end

  def pbFaint(showMessage=true)
    if !self.isFainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0") if $INTERNAL
      return true
    end
    if @fainted
      return true
    end
    @battle.scene.pbFainted(self)
    if (pbPartner.ability == PBAbilities::POWEROFALCHEMY || pbPartner.ability == PBAbilities::RECEIVER) && pbPartner.hp > 0
      if PBStuff::ABILITYBLACKLIST.none? {|forbidden_ability| forbidden_ability==@ability}
        oldability = pbPartner.ability
        partnerability=@ability
        pbPartner.ability=partnerability
        abilityname=PBAbilities.getName(partnerability)
        if oldability == PBAbilities::POWEROFALCHEMY
          @battle.pbDisplay(_INTL("{1} took on {2}'s {3}!",pbPartner.pbThis,pbThis,abilityname))
        else
          @battle.pbDisplay(_INTL("{1} received {2}'s {3}!",pbPartner.pbThis,pbThis,abilityname))
        end
        if pbPartner.ability == PBAbilities::INTIMIDATE
          for i in @battle.battlers
            next if i.isFainted? || !pbIsOpposing?(i.index)
            i.pbReduceAttackStatStageIntimidate(pbPartner)
          end
        end
      end
    end
    for i in @battle.battlers
      next if i.isFainted?
      if i.ability == PBAbilities::SOULHEART && !i.pbTooHigh?(PBStats::SPATK)
        @battle.pbDisplay(_INTL("{1}'s Soul-heart activated!",i.pbThis))
        i.pbIncreaseStat(PBStats::SPATK,1)
        if (@battle.FE==PBFields::MISTYT || @battle.FE==PBFields::RAINBOWF || @battle.FE==PBFields::FAIRYTALEF) && !i.pbTooHigh?(PBStats::SPDEF)
          i.pbIncreaseStat(PBStats::SPDEF,1)
        end
      end
    end
    droprelease = self.effects[PBEffects::SkyDroppee]
    #if locked in sky drop while fainting
    if self.effects[PBEffects::SkyDrop]
      for i in @battle.battlers
        next if i.isFainted?
        if i.effects[PBEffects::SkyDroppee]==self
          @battle.scene.pbUnVanishSprite(i)
          i.effects[PBEffects::TwoTurnAttack] = 0
          i.effects[PBEffects::SkyDroppee] = nil
        end
      end
    end
    @battle.pbDisplayPaused(_INTL("{1} fainted!",pbThis)) if showMessage
    pbInitEffects(false)
    self.vanished=false
    # reset status
    self.status=0
    self.statusCount=0
    if @pokemon && @battle.internalbattle
      @pokemon.changeHappiness("faint")
    end
    if self.isMega?
      @pokemon.makeUnmega
    end
    if self.isUltra?
      @pokemon.makeUnultra(@startform)
    end
    @fainted=true
    # reset choice
    @battle.choices[@index]=[0,0,nil,-1]
    if @userSwitch
      @userSwitch = false
    end
    #reset mimikyu form if it faints
    if @species==PBSpecies::MIMIKYU && @pokemon.form==1
      self.form=0
    end
    #deactivate ability
    self.ability=0
    if droprelease!=nil
      oppmon = droprelease
      oppmon.effects[PBEffects::SkyDrop]=false
      @battle.scene.pbUnVanishSprite(oppmon)
      @battle.pbDisplay(_INTL("{1} is freed from Sky Drop effect!",oppmon.pbThis))
    end
    # set ace message flag
    if (self.index==1 || self.index==3) && !@battle.pbIsWild? && !@battle.opponent.is_a?(Array) && @battle.pbPokemonCount(@battle.party2)==1 && !@battle.ace_message_handled
      @battle.ace_message=true
    end
    @battle.scene.partyBetweenKO1(self.index==1 || self.index==3) unless (@battle.doublebattle || pbNonActivePokemonCount==0)
    PBDebug.log("[#{pbThis} fainted]") if $INTERNAL
    return true
  end

################################################################################
# Find other battlers/sides in relation to this battler
################################################################################
# Returns the data structure for this battler's side
  def pbOwnSide
    return @battle.sides[@index&1] # Player: 0 and 2; Foe: 1 and 3
  end

# Returns the data structure for the opposing Pokémon's side
  def pbOpposingSide
    return @battle.sides[(@index&1)^1] # Player: 1 and 3; Foe: 0 and 2
  end

# Returns whether the position belongs to the opposing Pokémon's side
  def pbIsOpposing?(i)
    return (@index&1)!=(i&1)
  end

# Returns the battler's partner
  def pbPartner
    return @battle.battlers[(@index^2)]
  end

# Returns the battler's first opposing Pokémon
  def pbOpposing1
    return @battle.battlers[((@index&1)^1)]
  end

# Returns the battler's second opposing Pokémon
  def pbOpposing2
    return @battle.battlers[((@index&1)^1)+2]
  end

  def pbOppositeOpposing
    return @battle.doublebattle ? @battle.battlers[(@index^3)] : @battle.battlers[(@index^1)]
  end

  def pbCrossOpposing
    return @battle.doublebattle ? @battle.battlers[(@index^1)] : @battle.battlers[(@index^3)]
  end

  def pbNonActivePokemonCount()
    count=0
    party=@battle.pbPartySingleOwner(self.index)
    for i in 0...party.length
      if (self.isFainted? || i!=self.pokemonIndex) && (pbPartner.isFainted? || i!=self.pbPartner.pokemonIndex) && party[i] && !party[i].isEgg? && party[i].hp>0
        count+=1
      end
    end
    return count
  end

################################################################################
# Forms
################################################################################
  def pbCheckForm(thismove = nil) # TODO: try and find a different way of doing this - I'm not liking this    return if @effects[PBEffects::Transform]
    transformed=false
    # Forecast
    if (self.pokemon && self.pokemon.species == PBSpecies::CASTFORM)
      if self.ability == PBAbilities::FORECAST
        case @battle.pbWeather
          when PBWeather::SUNNYDAY
            if !self.hasWorkingItem(:UTILITYUMBRELLA)
              if self.form!=1
                self.form=1
                transformed=true
              end
            end
          when PBWeather::RAINDANCE
            if !self.hasWorkingItem(:UTILITYUMBRELLA)
              if self.form!=2
                self.form=2
                transformed=true
              end
            end
          when PBWeather::HAIL
            if self.form!=3
              self.form=3
              transformed=true
            end
          else
            if self.form!=0
              self.form=0
              transformed=true
            end
        end
      else
        if self.form!=0
          self.form=0
          pbUpdate(false)
          @battle.scene.pbChangePokemon(self,@pokemon)
          @type1   = @pokemon.type1
          @type2   = @pokemon.type2
        end
      end
      showmessage=transformed
    end
    # Cherrim
    if (self.pokemon && self.pokemon.species == PBSpecies::CHERRIM) && !self.isFainted?
      if (self.ability == PBAbilities::FLOWERGIFT)
        case @battle.pbWeather
          when PBWeather::SUNNYDAY
            if !self.hasWorkingItem(:UTILITYUMBRELLA)
              if self.form!=1
                self.form=1
                transformed=true
              end
            end
          else
            if @battle.FE == PBFields::FLOWERGARDENF
              if self.form!=1
                self.form=1
                transformed=true
              end
            elsif self.form!=0
              self.form=0
              transformed=true
            end
        end
      else
        if self.form!=0
          self.form=0
          @battle.pbCommonAnimation("FlowerGiftNotSun",self,nil)
          pbUpdate(false)
          @battle.scene.pbChangePokemon(self,@pokemon)
          @type1   = @pokemon.type1
          @type2   = @pokemon.type2
        end
      end
    end
    # Shaymin
    if (self.pokemon && self.pokemon.species == PBSpecies::SHAYMIN) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Giratina
    if (self.pokemon && self.pokemon.species == PBSpecies::GIRATINA) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Zen Mode
    if (self.pokemon && self.pokemon.species == PBSpecies::DARMANITAN) && !self.isFainted?
      if self.ability == PBAbilities::ZENMODE
        if @hp<=((@totalhp/2.0).floor) || @battle.FE == PBFields::ASHENB
          if self.form!=1
            self.form=1; transformed=true
          end
        else
          if self.form!=0
            self.form=0; transformed=true
          end
        end
      else
        if self.form!=0
          self.form=0; transformed=true
        end
      end
    end
    # Keldeo
    if (self.pokemon && self.pokemon.species == PBSpecies::KELDEO) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
   # Genesect
    if (self.pokemon && self.pokemon.species == PBSpecies::GENESECT) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # UPDATE 1/18/2014
    # Aegislash
    if (self.pokemon && self.pokemon.species == PBSpecies::AEGISLASH) && !self.isFainted?
      if (self.ability == PBAbilities::STANCECHANGE && !@effects[PBEffects::Transform])
        # in Shield Forme and used a damaging move
        if self.form == 0 && !thismove.nil? && thismove.basedamage > 0
          self.form = 1 ; transformed = true
        # in Blade Forme and used King's Shield
        elsif self.form == 1 && !thismove.nil? && thismove.id == PBMoves::KINGSSHIELD
          self.form = 0 ; transformed = true
        end
      end
    end # end of update
    # If the form of the Pokémon changed
    if transformed
      @battle.pbCommonAnimation("Forecast",self,nil) if self.species == PBSpecies::CASTFORM
      if self.species == PBSpecies::CHERRIM
        if self.form == 1
          @battle.pbCommonAnimation("FlowerGiftSun",self,nil)
        else
          @battle.pbCommonAnimation("FlowerGiftNotSun",self,nil)
        end
      end
      @battle.pbCommonAnimation("ZenMode",self,nil) if self.species == PBSpecies::DARMANITAN
      if self.species == PBSpecies::AEGISLASH
        if self.form == 1
          @battle.pbCommonAnimation("StanceAttack",self,nil)
        else
          if self.index == 0 || self.index == 2
            @battle.pbCommonAnimation("StanceProtect",self,nil)
          else
            @battle.pbCommonAnimation("StanceProtectOpp",self,nil)
          end
        end
      end
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self,@pokemon)
      @battle.pbDisplay(_INTL("{1} transformed!",pbThis))
      if (self.ability == PBAbilities::STANCECHANGE) && @battle.FE == PBFields::FAIRYTALEF
        if self.form == 0
          self.pbReduceStat(PBStats::ATTACK,1,abilitymessage:false)
          self.pbIncreaseStat(PBStats::DEFENSE,1,abilitymessage:false)
        else
          self.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false)
          self.pbIncreaseStat(PBStats::ATTACK,1,abilitymessage:false)
        end
      end
    end
  end

  def pbCheckFormRoundEnd
    # Wishiwashi
    if (self.species == PBSpecies::WISHIWASHI) && !self.isFainted?
      if self.ability == PBAbilities::SCHOOLING && !@effects[PBEffects::Transform]
        schoolHP = (self.totalhp/4.0).floor
        if (self.hp>schoolHP && self.level>19) || [PBFields::WATERS,PBFields::UNDERWATER,PBFields::MURKWATERS].include?(@battle.FE)
          if self.form!=1
            self.form=1
            @battle.pbCommonAnimation("SchoolForm",self,nil)
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("{1} formed a school!",pbThis))
          end
        else
          if self.form!=0
            self.form=0
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("{1} stopped schooling!",pbThis))
          end
        end
      end
    end
    # Minior
    if (self.species == PBSpecies::MINIOR) && !self.isFainted?
      if self.ability == PBAbilities::SHIELDSDOWN && !@effects[PBEffects::Transform]
        coreHP = (self.totalhp/2.0).floor
        if self.hp>coreHP
          if self.form!=7
            self.form=7
            @battle.pbCommonAnimation("ShieldsUp",self,nil)
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("{1}'s shields came up!",pbThis))
          end
        else
          if self.form!=self.startform
            self.form=self.startform
            @battle.pbCommonAnimation("ShieldsDown",self,nil)
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("{1}'s shields went down!",pbThis))
          end
        end
      end
    end
    # Zygarde
    if (self.pokemon && self.pokemon.species == PBSpecies::ZYGARDE) && !self.isFainted? && !self.effects[PBEffects::Transform]
      if self.ability == PBAbilities::POWERCONSTRUCT
        completeHP = (self.totalhp/2.0).floor
        if self.hp<=completeHP
          if self.form!=2
             @battle.pbDisplay(_INTL("You sense the presence of many!"))
            self.form=2
            @battle.pbCommonAnimation("ZygardeForms",self,nil)
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("{1} transformed into its Complete Forme!",pbThis))
          end
        end
      end
    end
    # Silvally / Arceus
    if ((self.ability == PBAbilities::RKSSYSTEM && self.species == PBSpecies::SILVALLY) ||
      (self.ability == PBAbilities::MULTITYPE && self.species == PBSpecies::ARCEUS)) && !self.isFainted?
      oldform = self.form
      if @battle.field.effect == PBFields::NEWW
        @battle.NWTypeRoll(self) 
        transformed=true
        return
      else
        if oldform==0 #Trying to avoid overwriting PBS set forms for them
          self.form = formFromItem 
          self.form += 19 if $game_switches[:Pulse_Arceus] && self.species == PBSpecies::ARCEUS
          self.type1 = self.form % 19
          self.type2 = self.form % 19
        end
      end
      if self.species == PBSpecies::SILVALLY && (@battle.field.effect == PBFields::GLITCHF || @battle.field.effect == PBFields::HOLYF)
        if @battle.field.effect == PBFields::GLITCHF
          roll = 9
        elsif @battle.field.effect == PBFields::HOLYF
          roll = 17
        end
        self.type1 = roll
        self.type2 = roll
        self.form = roll
        if self.form != oldform
          pbUpdate(true)
          if @battle.field.effect == PBFields::GLITCHF
            @battle.pbCommonAnimation("SilvallyGlitch",self,nil)
          elsif @battle.field.effect == PBFields::HOLYF
            @battle.pbCommonAnimation("SilvallyHoly",self,nil)
          end
          @battle.scene.pbChangePokemon(self,@pokemon)
          if @battle.field.effect == PBFields::GLITCHF
            @battle.pbDisplay(_INTL("{1} was corrupted by the rogue data!",pbThis))
          elsif @battle.field.effect == PBFields::HOLYF
            @battle.pbDisplay(_INTL("A false god holds no power here..."))
          end
          transformed=true
          return
        end
      end
      if self.form != oldform && transformed==true
        pbUpdate(true)
        @battle.pbCommonAnimation("TypeRoll",self,nil)
        @battle.scene.pbChangePokemon(self,@pokemon)
        @battle.pbDisplay(_INTL("{1} reverted to the {2} type!",pbThis,PBTypes.getName(self.type1)))
      end
    end
  end

  def pbCheckBurnyForm
    return if self.species != PBSpecies::BURMY || self.isFainted?
    originalform = self.form
    case @battle.FE
    when 1,5,6,10,11,17,18,19,24,26,29,30,35,36,37
      self.form=2 # Trash Cloak
    when 2,3,7,8,9,15,21,22,31,33,34
      self.form=0 # Plant Cloak
    when 4,12,13,14,16,20,23,25,27,28,32
      self.form=1 # Sandy CloaK
    else
      env=@battle.environment   
      if env==PBEnvironment::Sand || env==PBEnvironment::Rock || env==PBEnvironment::Cave
        self.form=1 # Sandy Cloak
      elsif !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        self.form=2 # Trash Cloak
      else
        self.form=0 # Plant Cloak
      end
    end
    if originalform != self.form
      case self.form
      when 1 then @battle.pbCommonAnimation("BurmySandy",self,nil)
      when 2 then @battle.pbCommonAnimation("BurmyTrash",self,nil)
      else @battle.pbCommonAnimation("BurmyPlant",self,nil)
      end
      @battle.scene.pbChangePokemon(self,@pokemon)
      @battle.pbDisplay(_INTL("{1} changed form to match the environment!",pbThis))
    end
  end

  def pbBreakDisguise
    self.form=1
    pbUpdate(true)
    if self.index == 0 || self.index == 2
      @battle.pbCommonAnimation("DisguiseBust1",self,nil)
    else
      @battle.pbCommonAnimation("DisguiseBust1Opp",self,nil)
    end
    @battle.scene.pbChangePokemon(self,@pokemon)
    if self.index == 0 || self.index == 2
      @battle.pbCommonAnimation("DisguiseBust2",self,nil)
    else
      @battle.pbCommonAnimation("DisguiseBust2Opp",self,nil)
    end
  end

  def pbRegenFace
    self.form=0
    @effects[PBEffects::IceFace] = true
    pbUpdate(true)
    @battle.scene.pbChangePokemon(self,@pokemon)
  end

  def pbResetForm
    if !@effects[PBEffects::Transform]
      if (self.species == PBSpecies::CASTFORM)   ||
        (self.species == PBSpecies::CHERRIM)    ||
        (self.species == PBSpecies::DARMANITAN) ||
        #(self.species == PBSpecies::MELOETTA)   ||
        (self.species == PBSpecies::AEGISLASH && self.form < 2)  ||
        (self.species == PBSpecies::KYOGRE)     ||
        (self.species == PBSpecies::GROUDON)    ||
        (self.species == PBSpecies::WISHIWASHI) ||
        self.species == PBSpecies::DITTO        ||
        self.species == PBSpecies::MEW        

        self.form=0
      elsif (self.species == PBSpecies::ZYGARDE) ||
        (self.species == PBSpecies::MINIOR)
        self.form=@startform
      end
    end
    pbUpdate(true)
  end

################################################################################
# Ability effects
################################################################################
  def pbAbilitiesOnSwitchIn(onactive)
    return if @hp<=0
    if (self.species == PBSpecies::KYOGRE && self.item== PBItems::BLUEORB) || (self.species == PBSpecies::GROUDON && self.item== PBItems::REDORB)
      if self.form == 0 
        if self.species == PBSpecies::KYOGRE
          @battle.pbCommonAnimation("PrimalReversionKyogre",self,nil)
        else          
          @battle.pbCommonAnimation("PrimalReversionGroudon",self,nil)
        end
        self.form = 1
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon)
        @battle.pbDisplay(_INTL("{1}'s Primal Reversion! It reverted to its primal form!",pbThis))
      end
    end
    #### END OF PRIMAL REVERSIONS

    self.pbCheckFormRoundEnd if onactive
    pbCheckBurnyForm if onactive

    #### START OF WEATHER ABILITIES
    rainbowhold=0
    if onactive
      if (ability == PBAbilities::PRIMORDIALSEA) && !@battle.state.effects[PBEffects::HeavyRain] && @battle.canSetWeather?
        @battle.state.effects[PBEffects::HeavyRain] = true
        @battle.state.effects[PBEffects::HarshSunlight] = false
        @battle.weatherduration=-1
        @battle.pbDisplay(_INTL("A heavy rain began to fall!"))
        if @battle.weather==PBWeather::SUNNYDAY
          rainbowhold=5
          rainbowhold=8 if (self.item == PBItems::DAMPROCK && self.itemWorks?)
        end
        @battle.weather=PBWeather::RAINDANCE
        @battle.pbCommonAnimation("Rain",nil,nil)
      end

      if (ability == PBAbilities::DESOLATELAND) && !@battle.state.effects[PBEffects::HarshSunlight] && @battle.canSetWeather?
        @battle.state.effects[PBEffects::HarshSunlight] = true
        @battle.state.effects[PBEffects::HeavyRain] = false
        @battle.weatherduration=-1
        @battle.pbDisplay(_INTL("The sunlight turned extremely harsh!"))
        if @battle.weather==PBWeather::RAINDANCE
          rainbowhold=5
          rainbowhold=8 if (self.item == PBItems::HEATROCK && self.itemWorks?)
        end
        @battle.weather=PBWeather::SUNNYDAY
        @battle.pbCommonAnimation("Sunny",nil,nil)
      end

      if (ability == PBAbilities::DELTASTREAM) && @battle.weather!=PBWeather::STRONGWINDS && @battle.canSetWeather?
        @battle.weather=PBWeather::STRONGWINDS
        @battle.state.effects[PBEffects::HarshSunlight] = false
        @battle.state.effects[PBEffects::HeavyRain] = false
        @battle.weatherduration=-1
        @battle.pbDisplay(_INTL("A mysterious air current is protecting Flying-type Pokemon!"))
      end
    end

    if @battle.state.effects[PBEffects::HeavyRain] || @battle.state.effects[PBEffects::HarshSunlight] || @battle.weather == PBWeather::STRONGWINDS
      if !@battle.pbCheckGlobalAbility(:PRIMORDIALSEA)
        if @battle.state.effects[PBEffects::HeavyRain]
          @battle.pbDisplay(_INTL("The heavy rain has lifted."))
          @battle.state.effects[PBEffects::HeavyRain] = false
          unless ((ability == PBAbilities::PRIMORDIALSEA) || (ability == PBAbilities::DESOLATELAND) || (ability == PBAbilities::DELTASTREAM)) && onactive
            @battle.weatherduration = 0
            @battle.weather = 0
          end
        end
      end
      if !@battle.pbCheckGlobalAbility(:DESOLATELAND)
        if @battle.state.effects[PBEffects::HarshSunlight]
          @battle.pbDisplay(_INTL("The harsh sunlight faded!"))
          @battle.state.effects[PBEffects::HarshSunlight] = false
          unless ((ability == PBAbilities::PRIMORDIALSEA) || (ability == PBAbilities::DESOLATELAND) || (ability == PBAbilities::DELTASTREAM)) && onactive
            @battle.weatherduration = 0
            @battle.weather = 0
          end
        end
      end
      if !@battle.pbCheckGlobalAbility(:DELTASTREAM) && $game_screen.weather_type != 6 && self.pbOwnSide.effects[PBEffects::Tailwind]<=0 && self.pbOpposingSide.effects[PBEffects::Tailwind]<=0
        if @battle.weather == PBWeather::STRONGWINDS
          @battle.pbDisplay(_INTL("The mysterious air current has dissipated!"))
          unless ((ability == PBAbilities::PRIMORDIALSEA) || (ability == PBAbilities::DESOLATELAND) || (ability == PBAbilities::DELTASTREAM)) && onactive
            @battle.weatherduration = 0
            @battle.weather = 0
          end
        end
      end
    end
    # END OF PRIMAL WEATHER DEACTIVATION TESTS
    # Trace
    if self.ability == PBAbilities::TRACE
      @effects[PBEffects::TracedAbility]=0
      if @effects[PBEffects::Trace] || onactive
        choices=[]
        for i in 0...4
          if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
            abilitycheck = true
            abilitycheck = false if (PBStuff::ABILITYBLACKLIST).include?(@battle.battlers[i].ability) || @battle.battlers[i].ability==0
            abilitycheck = true if @battle.battlers[i].ability == PBAbilities::WONDERGUARD
            choices.push(i) if abilitycheck == true
          end
        end
        if choices.length==0
          @effects[PBEffects::Trace]=true
        else
          choice=choices.sample
          battlername=@battle.battlers[choice].pbThis(true)
          battlerability=@battle.battlers[choice].ability
          @ability=battlerability
          abilityname=PBAbilities.getName(battlerability)
          @effects[PBEffects::TracedAbility]=battlerability
          @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!",pbThis,battlername,abilityname))
          @effects[PBEffects::Trace]=false
        end
      end
    end
    #Surges
    current_field = @battle.field.effect
    if self.ability == PBAbilities::ELECTRICSURGE && onactive && @battle.canChangeFE?(PBFields::ELECTRICT)
      @battle.setField(PBFields::ELECTRICT,true)
      @battle.pbDisplay(_INTL("The terrain became electrified!"))
    elsif self.ability == PBAbilities::GRASSYSURGE && onactive && @battle.canChangeFE?(PBFields::GRASSYT)
      @battle.setField(PBFields::GRASSYT,true)
      @battle.pbDisplay(_INTL("The terrain became grassy!"))
    elsif self.ability == PBAbilities::MISTYSURGE && onactive && @battle.canChangeFE?(PBFields::MISTYT)
      @battle.setField(PBFields::MISTYT,true)
      @battle.pbDisplay(_INTL("The terrain became misty!"))
    elsif self.ability == PBAbilities::PSYCHICSURGE && onactive && @battle.canChangeFE?(PBFields::PSYCHICT)
      @battle.setField(PBFields::PSYCHICT,true)
      @battle.pbDisplay(_INTL("The terrain became mysterious!"))
    end
    if current_field != @battle.field.effect
      @battle.field.duration=5
      @battle.field.duration=8 if (@item == PBItems::AMPLIFIELDROCK && self.itemWorks?)
    end

    # Field Seeds
    @battle.seedCheck if @battle.turncount!=0

    # Weather Abilities
    if (ability == PBAbilities::DRIZZLE) && onactive && @battle.weather!=PBWeather::RAINDANCE
      if @battle.state.effects[PBEffects::HeavyRain]
        @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      elsif @battle.state.effects[PBEffects::HarshSunlight]
        @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      elsif @battle.weather==PBWeather::STRONGWINDS && (@battle.battlers[0].ability == PBAbilities::DELTASTREAM || @battle.battlers[1].ability == PBAbilities::DELTASTREAM ||
        @battle.battlers[2].ability == PBAbilities::DELTASTREAM || @battle.battlers[3].ability == PBAbilities::DELTASTREAM)
        @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      elsif @battle.FE == PBFields::NEWW
        @battle.pbDisplay(_INTL("The weather disappeared into space!"))
      elsif @battle.FE == PBFields::UNDERWATER
        @battle.pbDisplay(_INTL("You're too deep to notice the weather!"))
      else
        if @battle.weather==PBWeather::SUNNYDAY
          rainbowhold=5
          rainbowhold=8 if (self.item == PBItems::DAMPROCK && self.itemWorks?)
        end
        @battle.weather=PBWeather::RAINDANCE
        @battle.weatherduration=5
        @battle.weatherduration=8 if (self.item == PBItems::DAMPROCK && self.itemWorks?)
        @battle.weatherduration=-1 if $game_switches[:Gen_5_Weather]==true
        @battle.pbCommonAnimation("Rain",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Drizzle made it rain!",pbThis))
      end
    end

    if (ability == PBAbilities::SANDSTREAM) && onactive && @battle.weather!=PBWeather::SANDSTORM
      if @battle.state.effects[PBEffects::HeavyRain]
        @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      elsif @battle.state.effects[PBEffects::HarshSunlight]
        @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      elsif @battle.weather==PBWeather::STRONGWINDS && @battle.pbCheckGlobalAbility(:DELTASTREAM)
        @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      elsif @battle.FE == PBFields::NEWW
        @battle.pbDisplay(_INTL("The weather disappeared into space!"))
      elsif @battle.FE == PBFields::UNDERWATER
        @battle.pbDisplay(_INTL("You're too deep to notice the weather!"))
      else
        @battle.weather=PBWeather::SANDSTORM
        @battle.weatherduration=5
        @battle.weatherduration=8 if (self.item == PBItems::SMOOTHROCK && self.itemWorks?) || @battle.FE == PBFields::DESERTF || @battle.FE == PBFields::ASHENB
        @battle.weatherduration=-1 if $game_switches[:Gen_5_Weather]==true
        @battle.pbCommonAnimation("Sandstorm",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Sand Stream whipped up a sandstorm!",pbThis))
      end
    end

    if (ability == PBAbilities::DROUGHT) && onactive && @battle.weather!=PBWeather::SUNNYDAY
      if @battle.state.effects[PBEffects::HeavyRain]
        @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      elsif @battle.state.effects[PBEffects::HarshSunlight]
        @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      elsif @battle.weather==PBWeather::STRONGWINDS && (@battle.battlers[0].ability == PBAbilities::DELTASTREAM || @battle.battlers[1].ability == PBAbilities::DELTASTREAM ||
        @battle.battlers[2].ability == PBAbilities::DELTASTREAM || @battle.battlers[3].ability == PBAbilities::DELTASTREAM)
        @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      elsif @battle.FE == PBFields::NEWW
        @battle.pbDisplay(_INTL("The weather disappeared into space!"))
      elsif @battle.FE == PBFields::UNDERWATER
        @battle.pbDisplay(_INTL("You're too deep to notice the weather!"))
      else
        if @battle.weather==PBWeather::RAINDANCE
          rainbowhold=5
          rainbowhold=8 if (self.item == PBItems::HEATROCK && self.itemWorks?)
        end
        @battle.weather=PBWeather::SUNNYDAY
        @battle.weatherduration=5
        @battle.weatherduration=8 if (self.item == PBItems::HEATROCK && self.itemWorks?) ||
          @battle.FE == PBFields::DESERTF || @battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM
        @battle.weatherduration=-1 if $game_switches[:Gen_5_Weather]==true
        @battle.pbCommonAnimation("Sunny",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Drought intensified the sun's rays!",pbThis))
        if @battle.FE == PBFields::DARKCRYSTALC
          @battle.setField(PBFields::CRYSTALC,true)
          @battle.field.duration = @battle.weatherduration
          @battle.pbDisplay(_INTL("The sun lit up the crystal cavern!"))
        end
      end
    end

    if (ability == PBAbilities::SNOWWARNING) && onactive && @battle.weather!=PBWeather::HAIL
      if @battle.state.effects[PBEffects::HeavyRain]
        @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      elsif @battle.state.effects[PBEffects::HarshSunlight]
        @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      elsif @battle.weather==PBWeather::STRONGWINDS && (@battle.battlers[0].ability == PBAbilities::DELTASTREAM || @battle.battlers[1].ability == PBAbilities::DELTASTREAM ||
        @battle.battlers[2].ability == PBAbilities::DELTASTREAM || @battle.battlers[3].ability == PBAbilities::DELTASTREAM)
        @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      elsif @battle.FE == PBFields::NEWW
        @battle.pbDisplay(_INTL("The weather disappeared into space!"))
      elsif @battle.FE == PBFields::UNDERWATER
        @battle.pbDisplay(_INTL("You're too deep to notice the weather!"))
      else
        @battle.weather=PBWeather::HAIL
        @battle.weatherduration=5
        @battle.weatherduration=8 if (self.item == PBItems::ICYROCK && self.itemWorks?) || @battle.FE == 13 || @battle.FE == 28
        @battle.weatherduration=-1 if $game_switches[:Gen_5_Weather]==true
        @battle.pbCommonAnimation("Hail",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Snow Warning made it hail!",pbThis))
        for facemon in @battle.battlers
          if facemon.species==875 && facemon.form==1 # Eiscue
            facemon.pbRegenFace
            @battle.pbDisplayPaused(_INTL("{1} transformed!",facemon.name))
          end
        end
      end
    end

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
    #### END OF WEATHER ABILITIES
    if onactive
      case self.ability
        when PBAbilities::AIRLOCK, PBAbilities::CLOUDNINE then @battle.pbDisplay(_INTL("The effects of the weather disappeared."))
        when PBAbilities::PRESSURE then @battle.pbDisplay(_INTL("{1} is exerting its Pressure!",pbThis))
        when PBAbilities::MOLDBREAKER then @battle.pbDisplay(_INTL("{1} breaks the mold!",pbThis))
        when PBAbilities::COMATOSE then @battle.pbDisplay(_INTL("{1} is drowsing!",pbThis))
        when PBAbilities::TERAVOLT then @battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",pbThis))
        when PBAbilities::TURBOBLAZE then @battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",pbThis))
        when PBAbilities::FAIRYAURA then @battle.pbDisplay(_INTL("{1} is radiating a Fairy aura!",pbThis))
        when PBAbilities::DARKAURA then @battle.pbDisplay(_INTL("{1} is radiating a Dark aura!",pbThis))
        when PBAbilities::AURABREAK then @battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",pbThis))
        when PBAbilities::NEUTRALIZINGGAS then @battle.pbDisplay(_INTL("{1}'s gas neutralized all other Pokémon's abilities!",pbThis))
      end
    end
    # End of Update
    # Balloon
    if self.hasWorkingItem(:AIRBALLOON) && onactive
      @battle.pbDisplay(_INTL("{1} is floating on its balloon!",pbThis))
    end
    
    # Mimicry
    if self.ability == PBAbilities::MIMICRY && onactive
      protype = -1
      case @battle.FE
        when 25
          protype = @battle.field.getRoll
        when 35
          rnd=@battle.pbRandom(18)
          protype = rnd
          protype = 18 if rnd == 9
        else
          protype = @battle.field.mimicry if @battle.field.mimicry
      end
      prot1 = self.type1
      prot2 = self.type2
      camotype = protype
      if camotype>0 && (!self.pbHasType?(camotype) || (defined?(prot2) && prot1 != prot2))
        self.type1=camotype
        self.type2=camotype
        typename=PBTypes.getName(camotype)
        @battle.pbDisplay(_INTL("{1} had its type changed to {2}!",pbThis,typename))
      end
    end
    # Pastel Veil
    if self.ability == PBAbilities::PASTELVEIL && onactive
      if self.pbPartner.status == PBStatuses::PARALYSIS
          @battle.pbDisplay(_INTL("{1}'s Pastel Veil cured its partner's poison problem!",self.pbThis))
      end
      self.pbPartner.status=0
      self.pbPartner.statusCount=0
    end
    # Intimidate
    if self.ability == PBAbilities::INTIMIDATE && onactive
      for i in 0...4
        next if !pbIsOpposing?(i) || @battle.battlers[i].isFainted?
        @battle.battlers[i].pbReduceAttackStatStageIntimidate(self)
      end
    end
    # Download
    if self.ability == PBAbilities::DOWNLOAD && onactive
      stagemult=[2,2,2,2,2,2,2,3,4,5,6,7,8]
      stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
      odef=ospdef=0
      opp1=pbOpposing1
      opp2=pbOpposing2
      odef+=(opp1.defense*stagemult[opp1.stages[PBStats::DEFENSE]+6]/stagediv[opp1.stages[PBStats::DEFENSE]+6]) if opp1.hp>0
      ospdef+=(opp1.spdef*stagemult[opp1.stages[PBStats::SPDEF]+6]/stagediv[opp1.stages[PBStats::SPDEF]+6]) if opp1.hp>0
      if opp2
        odef+=(opp2.defense*stagemult[opp2.stages[PBStats::DEFENSE]+6]/stagediv[opp2.stages[PBStats::DEFENSE]+6]) if opp2.hp>0
        ospdef+=(opp2.spdef*stagemult[opp2.stages[PBStats::SPDEF]+6]/stagediv[opp2.stages[PBStats::SPDEF]+6]) if opp2.hp>0
      end
      if ospdef>odef
        if !pbTooHigh?(PBStats::ATTACK)
          if @battle.FE == PBFields::FACTORYF
            pbIncreaseStatBasic(PBStats::ATTACK,2)
            @battle.pbCommonAnimation("StatUp",self)
            @battle.pbDisplay(_INTL("{1}'s {2} sharply boosted its Attack!", pbThis,PBAbilities.getName(ability)))
          else
            pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battle.pbCommonAnimation("StatUp",self)
            @battle.pbDisplay(_INTL("{1}'s {2} boosted its Attack!", pbThis,PBAbilities.getName(ability)))
          end
        end
      else
        if !pbTooHigh?(PBStats::SPATK)
          if @battle.FE == PBFields::FACTORYF
            pbIncreaseStatBasic(PBStats::SPATK,2)
            @battle.pbCommonAnimation("StatUp",self)
            @battle.pbDisplay(_INTL("{1}'s {2} sharply boosted its Special Attack!", pbThis,PBAbilities.getName(ability)))
          else
            pbIncreaseStatBasic(PBStats::SPATK,1)
            @battle.pbCommonAnimation("StatUp",self)
            @battle.pbDisplay(_INTL("{1}'s {2} boosted its Special Attack!", pbThis,PBAbilities.getName(ability)))
          end
        end
      end
    end
    # Screen Cleaner
    if self.ability == PBAbilities::SCREENCLEANER && onactive
      pbOwnSide.effects[PBEffects::Reflect]     = 0
      pbOwnSide.effects[PBEffects::LightScreen] = 0
      pbOwnSide.effects[PBEffects::AuroraVeil]  = 0
      pbOpposingSide.effects[PBEffects::Reflect]     = 0
      pbOpposingSide.effects[PBEffects::LightScreen] = 0
      pbOpposingSide.effects[PBEffects::AuroraVeil]  = 0
      @battle.pbDisplay(_INTL("{1} has {2}!",pbThis,PBAbilities.getName(self.ability)))
      @battle.pbDisplay(_INTL("The effects of protective barriers disappeared."))
    end
    # Dauntless Shield
    if self.ability == PBAbilities::DAUNTLESSSHIELD && onactive
      if !pbTooHigh?(PBStats::DEFENSE)
        pbIncreaseStatBasic(PBStats::DEFENSE,1)
        @battle.pbDisplay(_INTL("{1}'s {2} boosted its Defense!", pbThis,PBAbilities.getName(ability)))
      end
    end
    # Intrepid Sword
    if self.ability == PBAbilities::INTREPIDSWORD && onactive
      if !pbTooHigh?(PBStats::ATTACK)
        pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbDisplay(_INTL("{1}'s {2} boosted its Attack!", pbThis,PBAbilities.getName(ability)))
      end
    end
    # Slow Start
    if self.ability == PBAbilities::SLOWSTART && onactive
      @battle.pbDisplay(_INTL("{1} can't get it going!",pbThis))
    end
    # Mirror Field Entry
    if @battle.FE == PBFields::MIRRORA
      if !pbTooHigh?(PBStats::EVASION)
        if (self.ability == PBAbilities::SNOWCLOAK || self.ability == PBAbilities::SANDVEIL || self.ability == PBAbilities::TANGLEDFEET || self.ability == PBAbilities::MAGICBOUNCE || self.ability == PBAbilities::COLORCHANGE) && onactive
          pbIncreaseStatBasic(PBStats::EVASION,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} boosted its Evasion!", pbThis,PBAbilities.getName(ability)))
        elsif self.ability == PBAbilities::ILLUSION && onactive
          pbIncreaseStatBasic(PBStats::EVASION,2)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s ability sharply boosted its Evasion!", pbThis,PBAbilities.getName(ability)))
        end
        if (self.hasWorkingItem(:BRIGHTPOWDER) || self.hasWorkingItem(:LAXINCENSE)) && onactive
          pbIncreaseStatBasic(PBStats::EVASION,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s item boosted its Evasion!", pbThis,PBAbilities.getName(ability)))
        end
        
      end
      # Keen Eye / Compound Eye
      if (self.ability == PBAbilities::KEENEYE || self.ability == PBAbilities::COMPOUNDEYES || self.hasWorkingItem(:ZOOMLENS) || self.hasWorkingItem(:WIDELENS)) && onactive
        if !pbTooHigh?(PBStats::ACCURACY)
          pbIncreaseStatBasic(PBStats::ACCURACY,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          if self.ability == PBAbilities::KEENEYE || self.ability == PBAbilities::COMPOUNDEYES
            @battle.pbDisplay(_INTL("{1}'s {2} boosted its Accuracy!", pbThis,PBAbilities.getName(self.ability)))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} boosted its Accuracy!", pbThis,PBItems.getName(self.item)))
          end
        end
        self.effects[PBEffects::LaserFocus] = 1
        @battle.pbDisplay(_INTL("{1} is focused!",pbThis))
      end
      # Illuminate
      if self.ability == PBAbilities::ILLUMINATE && onactive
        for i in 0...4
          if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
            @battle.battlers[i].pbReduceIlluminate(self)
          end
        end
      end
      
    end
    # Fairy Tale Field Entry
    if @battle.FE == PBFields::FAIRYTALEF
      if !pbTooHigh?(PBStats::DEFENSE)
        if (self.ability == PBAbilities::BATTLEARMOR || self.ability == PBAbilities::SHELLARMOR || self.ability == PBAbilities::POWEROFALCHEMY) && onactive
          pbIncreaseStatBasic(PBStats::DEFENSE,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s shining armor boosted its Defense!",
           pbThis,PBAbilities.getName(ability)))
        end
        if (self.ability == PBAbilities::STANCECHANGE) && onactive
          pbIncreaseStatBasic(PBStats::DEFENSE,1)
        end
      end
      if !pbTooHigh?(PBStats::SPDEF)
        if (self.ability == PBAbilities::MAGICGUARD || self.ability == PBAbilities::MAGICBOUNCE || self.ability == PBAbilities::POWEROFALCHEMY) && onactive
          pbIncreaseStatBasic(PBStats::SPDEF,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s magical power boosted its Special Defense!",
           pbThis,PBAbilities.getName(ability)))
        end
      end
      if !pbTooHigh?(PBStats::SPATK)
        if (self.ability == PBAbilities::MAGICIAN) && onactive
          pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s magical power boosted its Special Attack!",
           pbThis,PBAbilities.getName(ability)))
        end
      end
    end
    # Dragon's Den Entry
    if @battle.FE == PBFields::DRAGONSD
      if (self.ability == PBAbilities::MAGMAARMOR) && onactive
        @battle.pbDisplay(_INTL("{1}'s Magma Armor boosted its defenses!",
         pbThis,PBAbilities.getName(ability)))
        if !pbTooHigh?(PBStats::DEFENSE)
          pbIncreaseStatBasic(PBStats::DEFENSE,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
        end
        if !pbTooHigh?(PBStats::SPDEF)
          pbIncreaseStatBasic(PBStats::SPDEF,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
        end
      end
    end
    # Flower Garden Entry
    if @battle.field.effect == PBFields::FLOWERGARDENF && [PBAbilities::FLOWERGIFT,PBAbilities::FLOWERVEIL,PBAbilities::DROUGHT,PBAbilities::DRIZZLE].include?(ability) && onactive
      message = _INTL("{1}'s {2}", pbThis,PBAbilities.getName(ability))
      @battle.growField(message)
    end
    # Starlight Arena Entry
    if @battle.FE == PBFields::STARLIGHTA
      if !pbTooHigh?(PBStats::SPATK)
        if (self.ability == PBAbilities::ILLUMINATE) && onactive
          pbIncreaseStatBasic(PBStats::SPATK,2)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} flared up with starlight!",
           pbThis,PBAbilities.getName(ability)))
        end
      end
    end
    # Psychic Terrain Entry
    if @battle.FE == PBFields::PSYCHICT
      if !pbTooHigh?(PBStats::SPATK)
        if (self.ability == PBAbilities::ANTICIPATION) && onactive
          pbIncreaseStatBasic(PBStats::SPATK,2)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s Anticipation raised its Special Attack!",
           pbThis))
        end
      end
    end
    # Misty Terrain + Corrosive Mist Entry
    if @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::CORROSIVEMISTF
      if !pbTooHigh?(PBStats::DEFENSE)
        if (self.ability == PBAbilities::WATERCOMPACTION) && onactive
          pbIncreaseStatBasic(PBStats::DEFENSE,2)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s Water Compaction sharply raised its defense!",
           pbThis,PBAbilities.getName(ability)))
        end
      end
    end
    # Frisk
    if self.ability == PBAbilities::FRISK && @battle.pbOwnedByPlayer?(@index) && onactive
      items=[]
      items.push(pbOpposing1) if pbOpposing1.item>0 && !pbOpposing1.isFainted?
      items.push(pbOpposing2) if pbOpposing2.item>0 && !pbOpposing2.isFainted?
      for i in items
       itemname=PBItems.getName(i.item)
       @battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",pbThis,i.pbThis(true),itemname))
      end
    end
    # Anticipation
    if self.ability == PBAbilities::ANTICIPATION && onactive
      found=false
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.isFainted?
        for j in foe.moves
          movedata=PBMoveData.new(j.id)
          eff=PBTypes.getCombinedEffectiveness(movedata.type,type1,type2)
          if (movedata.basedamage>0 && eff>4 &&
             movedata.function!=0x71 && # Counter
             movedata.function!=0x72 && # Mirror Coat
             movedata.function!=0x73) || # Metal Burst
             (movedata.function==0x70 && eff>0) # OHKO
            found=true
            break
          end
        end
        break if found
      end
      @battle.pbDisplay(_INTL("{1} shuddered with anticipation!",pbThis)) if found
    end
    if self.ability == PBAbilities::UNNERVE && onactive
       if @battle.pbOwnedByPlayer?(@index)
       @battle.pbDisplay(_INTL("The opposing team is too nervous to eat berries!",pbThis))
       elsif !@battle.pbOwnedByPlayer?(@index)
       @battle.pbDisplay(_INTL("Your team is too nervous to eat berries!",pbThis))
       end
     end
    # Forewarn
    if self.ability == PBAbilities::FOREWARN && onactive
      highpower=0
      moves=[]
      chosenopponent = []
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.isFainted?
        for j in foe.moves
          movedata=PBMoveData.new(j.id)
          power=movedata.basedamage
          power=160 if movedata.function==0x70    # OHKO
          power=150 if movedata.function==0x8B    # Eruption
          power=120 if movedata.function==0x71 || # Counter
                       movedata.function==0x72 || # Mirror Coat
                       movedata.function==0x73    # Metal Burst
          power=80 if movedata.function==0x6A ||  # SonicBoom
                      movedata.function==0x6B ||  # Dragon Rage
                      movedata.function==0x6D ||  # Night Shade
                      movedata.function==0x6E ||  # Endeavor
                      movedata.function==0x6F ||  # Psywave
                      movedata.function==0x89 ||  # Return
                      movedata.function==0x8A ||  # Frustration
                      movedata.function==0x8C ||  # Crush Grip
                      movedata.function==0x8D ||  # Gyro Ball
                      movedata.function==0x90 ||  # Hidden Power
                      movedata.function==0x96 ||  # Natural Gift
                      movedata.function==0x97 ||  # Trump Card
                      movedata.function==0x98 ||  # Flail
                      movedata.function==0x9A     # Grass Knot
          if power>highpower
            moves=[j.id]; highpower=power; chosenopponent=[foe]
          elsif power==highpower
            moves.push(j.id) ; chosenopponent.push(foe)
          end
        end
      end
      if moves.length>0
        chosenmovenumber = @battle.pbRandom(moves.length)
        move=moves[chosenmovenumber]
        movename=PBMoves.getName(move)
        @battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",pbThis,movename))
        # AI CHANGES
        if !@battle.isOnline?
          warnedMove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(move),self)
          @battle.ai.addMoveToMemory(chosenopponent[chosenmovenumber], warnedMove)
        end
        if (self.index==1 || self.index==3) && !@battle.isOnline? # Move memory system for AI
          warnedMove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(move),self)
          if @battle.aiMoveMemory[0].length==0 && warnedMove.basedamage!=0
            @battle.aiMoveMemory[0].push(warnedMove)
          elsif @battle.aiMoveMemory[0].length!=0 && warnedMove.basedamage!=0
            dam1=@battle.pbRoughDamage(warnedMove,self,@battle.battlers[1],255,warnedMove.basedamage)
            dam2=@battle.pbRoughDamage(@battle.aiMoveMemory[0][0],self,@battle.battlers[1],255,@battle.aiMoveMemory[0][0].basedamage)
            if dam1>dam2
              @battle.aiMoveMemory[0].clear
              @battle.aiMoveMemory[0].push(warnedMove)
            end
          end
          if @battle.aiMoveMemory[1].length==0
            @battle.aiMoveMemory[1].push(warnedMove)
          else
            dupecheck=0
            for i in @battle.aiMoveMemory[1]
              dupecheck+=1 if i.id == warnedMove.id
            end
            @battle.aiMoveMemory[1].push(warnedMove) if dupecheck==0
          end
          if @battle.aiMoveMemory[2][self.pokemonIndex].length==0
            @battle.aiMoveMemory[2][self.pokemonIndex].push(warnedMove)
          else
            dupecheck=0
            for i in @battle.aiMoveMemory[2][self.pokemonIndex]
              dupecheck+=1 if i.id == warnedMove.id
            end
            @battle.aiMoveMemory[2][self.pokemonIndex].push(warnedMove) if dupecheck==0
          end
        end
      end
    end
    # Imposter
    if self.ability == PBAbilities::IMPOSTER && !@effects[PBEffects::Transform] && onactive && pbOppositeOpposing.hp>0
      choice=pbOppositeOpposing
      if choice.effects[PBEffects::Substitute]>0 ||
         choice.effects[PBEffects::Transform] ||
         choice.effects[PBEffects::SkyDrop] ||
         PBStuff::TWOTURNMOVE.include?(choice.effects[PBEffects::TwoTurnAttack]) ||
         choice.effects[PBEffects::Illusion]
        # Can't transform into chosen Pokémon, so forget it
      else
        @battle.pbAnimation(PBMoves::TRANSFORM,self,choice)
        @battle.scene.pbChangePokemon(self,choice.pokemon)
        @effects[PBEffects::Transform]=true
        oldname = pbThis
        @species=choice.species
        @type1=choice.type1
        @type2=choice.type2
        @ability=choice.ability
        @attack=choice.attack
        @defense=choice.defense
        @speed=choice.speed
        @spatk=choice.spatk
        @spdef=choice.spdef
        @form=choice.form
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                  PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
          @stages[i]=choice.stages[i]
        end
        for i in 0...4
          @moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(choice.moves[i].id),self)
          @moves[i].pp=5
          @moves[i].totalpp=5
        end
        @moves.each {|copiedmove| @battle.ai.addMoveToMemory(self,copiedmove) } if !@battle.isOnline?
        choice.moves.each {|moveloop| @battle.ai.addMoveToMemory(choice,moveloop) }  if !@battle.isOnline?
        @effects[PBEffects::Disable]=0
        @effects[PBEffects::DisableMove]=0
        @battle.pbDisplay(_INTL("{1} transformed into {2}!",oldname,choice.pbThis(true)))
        self.pbAbilitiesOnSwitchIn(true)
      end
    end
    if ability == PBAbilities::NEUTRALIZINGGAS && onactive
      for i in 0...4
        @battle.battlers[i].ability = 0 if !(PBStuff::FIXEDABILITIES).include?(@battle.battlers[i].ability)
      end
    end
  end

  def pbEffectsOnDealingDamage(move,user,target,damage,innards)
    movetype=move.pbType(user)
    if damage>0 && move.isContactMove? && !user.hasWorkingAbility(:LONGREACH) && !(user.hasWorkingItem(:PROTECTIVEPADS) || target.hasWorkingItem(:PROTECTIVEPADS))
      if !target.damagestate.substitute
        if target.hasWorkingItem(:STICKYBARB,true) && user.item==0 && !user.isFainted?
          user.item=target.item
          target.item=0
          if !@battle.opponent && !@battle.pbIsOpposing?(user.index)
            if user.pokemon.itemInitial==0 && target.pokemon.itemInitial==user.item
              user.pokemon.itemInitial=user.item
              target.pokemon.itemInitial=0
            end
          end
          @battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",target.pbThis,PBItems.getName(user.item),user.pbThis(true)))
        end
        if target.hasWorkingItem(:ROCKYHELMET,true) && !user.isFainted? && !user.hasWorkingAbility(:MAGICGUARD)
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/6.0).floor)
          @battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis, PBItems.getName(target.item)))
         end
        if target.effects[PBEffects::BeakBlast] && !user.hasWorkingAbility(:MAGICGUARD) && user.pbCanBurn?(false)
          user.pbBurn(target)
          @battle.pbDisplay(_INTL("{1} was burned by the heat!",user.pbThis))
        end


        if target.abilityWorks?(true)   #implemented in a desperate attempt to tame this disaster of a function
          if target.ability == PBAbilities::AFTERMATH && !user.isFainted? && target.hp <= 0 && !@battle.pbCheckGlobalAbility(:DAMP) && !user.hasWorkingAbility(:MAGICGUARD)
            PBDebug.log("[#{user.pbThis} hurt by Aftermath]")
            @battle.scene.pbDamageAnimation(user,0)
            if @battle.FE == PBFields::CORROSIVEMISTF
              user.pbReduceHP((user.totalhp/2.0).floor)
              @battle.pbDisplay(_INTL("{1} was caught in the toxic aftermath!",user.pbThis))
            else
              user.pbReduceHP((user.totalhp/4.0).floor)
              @battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
            end
          end
          # UPDATE 11/16/2013
          eschance = 3
          eschance = 6 if (@battle.FE == PBFields::FORESTF || @battle.FE == PBFields::WASTELAND)
          eschance.to_i
          #Effect Spore
          if !user.pbHasType?(:GRASS) && !user.hasWorkingAbility(:OVERCOAT) && target.ability == PBAbilities::EFFECTSPORE && @battle.pbRandom(10) < eschance
            rnd=@battle.pbRandom(3)
            if rnd==0 && user.pbCanPoison?(false)
              user.pbPoison(target)
              @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis, PBAbilities.getName(target.ability),user.pbThis(true)))
            elsif rnd==1 && user.pbCanSleep?(false)
              user.pbSleep
              @battle.pbDisplay(_INTL("{1}'s {2} made {3} sleep!",target.pbThis, PBAbilities.getName(target.ability),user.pbThis(true)))
            elsif rnd==2 && user.pbCanParalyze?(false)
              user.pbParalyze(target)
              @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!", target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            end
          end
          if target.ability == PBAbilities::FLAMEBODY && @battle.pbRandom(10)<3 && user.pbCanBurn?(false)
            user.pbBurn(target)
            @battle.pbDisplay(_INTL("{1}'s {2} burned {3}!",target.pbThis,
              PBAbilities.getName(target.ability),user.pbThis(true)))
          end
          if target.ability == PBAbilities::IRONBARBS && !user.isFainted? && !user.hasWorkingAbility(:MAGICGUARD)
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP((user.totalhp/8.0).floor)
            @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis, PBAbilities.getName(target.ability),user.pbThis(true)))
          end
          if target.ability == PBAbilities::MUMMY && !user.isFainted?
            if !(user.ability == PBAbilities::MUMMY) && !PBStuff::FIXEDABILITIES.include?(user.ability)
              user.ability=PBAbilities::MUMMY || 0
              @battle.pbDisplay(_INTL("{1} was mummified by {2}!", user.pbThis,target.pbThis(true)))
            end
          end
          if target.ability == PBAbilities::WANDERINGSPIRIT && !user.isFainted? #&& !@user.isBoss
            if !(user.ability == PBAbilities::WANDERINGSPIRIT) && !PBStuff::FIXEDABILITIES.include?(user.ability)
              tmp=user.ability
              user.ability=target.ability
              target.ability=tmp
              @battle.pbDisplay(_INTL("{1} swapped its {2} Ability with its target!", target.pbThis,PBAbilities.getName(target.ability)))
              user.pbAbilitiesOnSwitchIn(true)
              target.pbAbilitiesOnSwitchIn(true)
            end
          end
          if target.ability == PBAbilities::GOOEY
            if user.hasWorkingAbility(:CONTRARY)
              if @battle.FE == PBFields::SWAMPF || @battle.FE == PBFields::MURKWATERS
                user.pbReduceStat(PBStats::SPEED,2,statmessage:false)
                @battle.pbDisplay(_INTL("{1}'s {2} sharply boosted {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
              else
                user.pbReduceStat(PBStats::SPEED,1,statmessage:false)
                @battle.pbDisplay(_INTL("{1}'s {2} boosted {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
              end
            elsif user.hasWorkingAbility(:WHITESMOKE) || user.hasWorkingAbility(:CLEARBODY) || user.hasWorkingAbility(:FULLMETALBODY)
              @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",user.pbThis,PBAbilities.getName(user.ability)))
            elsif @battle.FE == PBFields::SWAMPF || @battle.FE == PBFields::MURKWATERS
              user.pbReduceStat(PBStats::SPEED,2,statmessage:false)
              @battle.pbDisplay(_INTL("{1}'s {2} harshly lowered {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            else
              user.pbReduceStat(PBStats::SPEED,1,statmessage:false)
              @battle.pbDisplay(_INTL("{1}'s {2} lowered {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            end
            if @battle.FE == PBFields::WASTELAND && user.pbCanPoison?(false)
              user.pbPoison(target)
              @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis, PBAbilities.getName(target.ability),user.pbThis(true)))
            end
          end
          if target.ability == PBAbilities::TANGLINGHAIR
            if user.hasWorkingAbility(:CONTRARY)
              user.pbReduceStat(PBStats::SPEED,1,statmessage:false)
              @battle.pbDisplay(_INTL("{1}'s {2} boosted {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            elsif user.hasWorkingAbility(:WHITESMOKE) || user.hasWorkingAbility(:CLEARBODY) || user.hasWorkingAbility(:FULLMETALBODY)
              @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",user.pbThis,PBAbilities.getName(user.ability)))
            else
              user.pbReduceStat(PBStats::SPEED,1,statmessage:false)
              @battle.pbDisplay(_INTL("{1}'s {2} lowered {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            end
          end
          eschance = 3
          eschance = 6 if @battle.FE == PBFields::WASTELAND
          eschance.to_i
          if target.ability == PBAbilities::POISONPOINT && @battle.pbRandom(10) < eschance && user.pbCanPoison?(false)
            user.pbPoison(target)
            @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis, PBAbilities.getName(target.ability),user.pbThis(true)))
          end
          if target.ability == PBAbilities::ROUGHSKIN && !user.isFainted? && !user.hasWorkingAbility(:MAGICGUARD)
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP((user.totalhp/8.0).floor)
            @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis, PBAbilities.getName(target.ability),user.pbThis(true)))
          end
          eschance = 3
          eschance = 6 if @battle.FE == PBFields::SHORTCIRCUITF
          eschance.to_i
          if target.ability == PBAbilities::STATIC && @battle.pbRandom(10) < eschance && user.pbCanParalyze?(false)
            user.pbParalyze(target)
            @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!", target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
          end
          if user.hasWorkingAbility(:POISONTOUCH,true) && @battle.pbRandom(10)<3 && target.pbCanPoison?(false)
            target.pbPoison(user)
            @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",user.pbThis, PBAbilities.getName(user.ability),target.pbThis(true)))
          end
          if target.ability == PBAbilities::PERISHBODY && user.effects[PBEffects::PerishSong]==0 && target.effects[PBEffects::PerishSong]==0
            @battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
            user.effects[PBEffects::PerishSong]=4
            target.effects[PBEffects::PerishSong]=4
          end
        end

        if target.hasWorkingAbility(:CUTECHARM) && @battle.pbRandom(10)<3
          if !user.hasWorkingAbility(:OBLIVIOUS) &&
           ((user.gender==1 && target.gender==0) || (user.gender==0 && target.gender==1)) && user.effects[PBEffects::Attract]<0 && !user.isFainted?
            user.effects[PBEffects::Attract]=target.index
            @battle.pbDisplay(_INTL("{1}'s {2} infatuated {3}!",target.pbThis, PBAbilities.getName(target.ability),user.pbThis(true)))
            if user.hasWorkingItem(:DESTINYKNOT) && !target.hasWorkingAbility(:OBLIVIOUS) && target.effects[PBEffects::Attract]<0
              target.effects[PBEffects::Attract]=user.index
              @battle.pbDisplay(_INTL("{1}'s {2} infatuated {3}!",user.pbThis, PBItems.getName(user.item),target.pbThis(true)))
            end
          end
        end
        if target.hasWorkingAbility(:PICKPOCKET)
          if target.item==0 && user.item>0 && user.effects[PBEffects::Substitute]==0 && target.effects[PBEffects::Substitute]==0 && !user.hasWorkingAbility(:STICKYHOLD) && 
            !@battle.pbIsUnlosableItem(user,user.item) && !@battle.pbIsUnlosableItem(target,user.item) && (@battle.opponent || !@battle.pbIsOpposing?(target.index))
            target.item=user.item
            user.item=0
            if @battle.pbIsWild? && target.pokemon.itemInitial==0 && user.pokemon.itemInitial==target.item  # In a wild battle
              target.pokemon.itemInitial=target.item
              target.pokemon.itemReallyInitialHonestlyIMeanItThisTime=target.item
              user.pokemon.itemInitial=0
            end
            @battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
             user.pbThis(true),PBItems.getName(target.item)))
          end
        end
      end
    end
    if damage>0
      if target.effects[PBEffects::ShellTrap] && move.pbIsPhysical?(movetype)
        target.effects[PBEffects::ShellTrap]=false
      end
      if target.hasWorkingAbility(:INNARDSOUT,true) && !user.isFainted? &&
        target.hp <= 0 && !user.hasWorkingAbility(:MAGICGUARD)
        PBDebug.log("[#{user.pbThis} hurt by Innards Out]")
        @battle.scene.pbDamageAnimation(user,0)
        user.pbReduceHP(innards)
        @battle.pbDisplay(_INTL("{2}'s innards hurt {1}!",user.pbThis,target.pbThis))
      end
      if @battle.FE == PBFields::GLITCHF # Glitch Field Hyper Beam Reset
        if user.hp>0 && target.hp<=0
          user.effects[PBEffects::HyperBeam]=0
        end
      end
      if user.hasWorkingAbility(:BEASTBOOST) && user.hp>0 && target.hp<=0
        aBoost = user.attack
        dBoost = user.defense
        saBoost = user.spatk
        sdBoost = user.spdef
        spdBoost = user.speed
        boostStat = [aBoost,dBoost,saBoost,sdBoost,spdBoost].max
        case boostStat
          when aBoost
            if !user.pbTooHigh?(PBStats::ATTACK)
              @battle.pbCommonAnimation("StatUp",self,nil)
              user.pbIncreaseStatBasic(PBStats::ATTACK,1)
              @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Attack!",user.pbThis))
            end
          when dBoost
            if !user.pbTooHigh?(PBStats::DEFENSE)
              @battle.pbCommonAnimation("StatUp",self,nil)
              user.pbIncreaseStatBasic(PBStats::DEFENSE,1)
              @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Defense!",user.pbThis))
            end
          when saBoost
            if !user.pbTooHigh?(PBStats::SPATK)
              @battle.pbCommonAnimation("StatUp",self,nil)
              user.pbIncreaseStatBasic(PBStats::SPATK,1)
              @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Special Attack!",user.pbThis))
            end
          when sdBoost
            if !user.pbTooHigh?(PBStats::SPDEF)
              @battle.pbCommonAnimation("StatUp",self,nil)
              user.pbIncreaseStatBasic(PBStats::SPDEF,1)
              @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Special Defense!",user.pbThis))
            end
          when spdBoost
            if !user.pbTooHigh?(PBStats::SPEED)
              @battle.pbCommonAnimation("StatUp",self,nil)
              user.pbIncreaseStatBasic(PBStats::SPEED,1)
              @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Speed!",user.pbThis))
            end
        end
      end
      if !target.damagestate.substitute
        if target.hasWorkingAbility(:CURSEDBODY,true) && @battle.pbRandom(10)<3 && @battle.FE != PBFields::HOLYF
          if user.effects[PBEffects::Disable]<=0 && move.pp>0 && !user.isFainted?
            user.effects[PBEffects::Disable]=4
            user.effects[PBEffects::DisableMove]=move.id
            @battle.pbDisplay(_INTL("{1}'s {2} disabled {3}!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:GULPMISSILE,true) && target.species == PBSpecies::CRAMORANT && !user.isFainted? &&
          !user.hasWorkingAbility(:MAGICGUARD) && target.form!=0
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/4.0).floor)
          if target.form==1 # Gulping Form
            if target.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
              target.pbReduceStatBasic(PBStats::DEFENSE,1)
              @battle.pbCommonAnimation("StatDown",target,nil)
              @battle.pbDisplay(_INTL("{1}'s {2} lowered its Defense!",
               target.pbThis,PBAbilities.getName(target.ability)))
            end
          elsif target.form==2 # Gorging Form
            if user.pbCanParalyze?(false)
              user.pbParalyze(target)
              @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
             target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            end
          end
          @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
          target.form = 0
          transformed = true
          target.pbUpdate(false)
          @battle.scene.pbChangePokemon(target,target.pokemon)
          @battle.pbDisplay(_INTL("{1} returned to normal!",target.pbThis))
        end
        # Illusion goes here
        if (target.ability == PBAbilities::ILLUSION) 
          if target.effects[PBEffects::Illusion]!=nil
            target.effects[PBEffects::Illusion]=nil
            @battle.scene.pbChangePokemon(target,target.pokemon)
            @battle.pbDisplay(_INTL("{1}'s {2} was broken!",target.pbThis, PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:JUSTIFIED) && (movetype == PBTypes::DARK)
          if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
            stat = @battle.FE == PBFields::HOLYF ? 2 : 1
            target.pbIncreaseStatBasic(PBStats::ATTACK,stat)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!", target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if user.hasWorkingAbility(:MAGICIAN) && target.damagestate.calcdamage>0 &&
         !target.damagestate.substitute && target.item!=0
          if target.hasWorkingAbility(:STICKYHOLD)
            abilityname=PBAbilities.getName(target.ability)
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,abilityname,@name))
          elsif !@battle.pbIsUnlosableItem(target,target.item) && !@battle.pbIsUnlosableItem(user,user.item) && user.item==0 && (target || !pbIsOpposing?(user.index))
            itemname=PBItems.getName(target.item)
            user.item=target.item
            target.item=0
            target.effects[PBEffects::ChoiceBand]=-1
            if @battle.pbIsWild? && # In a wild battle
              user.pokemon.itemInitial==0 &&
              target.pokemon.itemInitial==user.item
              user.pokemon.itemInitial=user.item
              user.pokemon.itemReallyInitialHonestlyIMeanItThisTime=user.item
              target.pokemon.itemInitial=0
            end
            @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,target.pbThis(true),itemname))
          end
        end
        if target.hasWorkingAbility(:RATTLED) && ((movetype == PBTypes::BUG) || (movetype == PBTypes::DARK) || (movetype == PBTypes::GHOST))
          if target.pbCanIncreaseStatStage?(PBStats::SPEED)
            target.pbIncreaseStatBasic(PBStats::SPEED,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!", target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:WEAKARMOR) && move.pbIsPhysical?(movetype)
          if target.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
            target.pbReduceStatBasic(PBStats::DEFENSE,1)
            @battle.pbCommonAnimation("StatDown",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} lowered its Defense!", target.pbThis,PBAbilities.getName(target.ability)))
          end
          if target.pbCanIncreaseStatStage?(PBStats::SPEED)
            target.pbIncreaseStatBasic(PBStats::SPEED,2)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Speed!", target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:STAMINA)
          if target.pbCanIncreaseStatStage?(PBStats::DEFENSE)
            target.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Defense!", target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:WATERCOMPACTION) && (movetype == PBTypes::WATER)
          if @battle.FE!=PBFields::ASHENB
            if target.pbCanIncreaseStatStage?(PBStats::DEFENSE)
              target.pbIncreaseStatBasic(PBStats::DEFENSE,2)
              @battle.pbCommonAnimation("StatUp",target,nil)
              @battle.pbDisplay(_INTL("{1}'s Water Compaction sharply raised its Defense!",
               target.pbThis,PBAbilities.getName(target.ability)))
             end
           else
            boost = false
            if target.pbCanIncreaseStatStage?(PBStats::DEFENSE)
              target.pbIncreaseStatBasic(PBStats::DEFENSE,2)
              @battle.pbCommonAnimation("StatUp",target,nil) if !boost
              #@battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Defense!",
               #target.pbThis,PBAbilities.getName(target.ability)))
              boost = true
            end
            if target.pbCanIncreaseStatStage?(PBStats::SPDEF)
              target.pbIncreaseStatBasic(PBStats::SPDEF,2)
              @battle.pbCommonAnimation("StatUp",target,nil) if !boost
              #@battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Defense!",
               #target.pbThis,PBAbilities.getName(target.ability)))
              boost = true
            end
            @battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Defense and Special Defense!",target.pbThis,PBAbilities.getName(target.ability))) if boost
          end
        end
      end
      # Cotton Down
      if target.hasWorkingAbility(:COTTONDOWN)
        @battle.pbDisplay(_INTL("{1}'s {2} scatters cotton around!",
         target.pbThis,PBAbilities.getName(target.ability)))
        for i in @battle.battlers
          next if i==target
          if i.pbCanReduceStatStage?(PBStats::SPEED)
            i.pbReduceStat(PBStats::SPEED,1,abilitymessage:false)
            #@battle.pbCommonAnimation("StatDown",i,nil)
            @battle.pbDisplay(_INTL("The cotton reduces {1}'s Speed!",i.pbThis))
          end
        end
      end
      # Sand Spit
      if target.hasWorkingAbility(:SANDSPIT)
        if !(@battle.state.effects[PBEffects::HeavyRain] || @battle.state.effects[PBEffects::HarshSunlight] ||
           @battle.weather==PBWeather::STRONGWINDS || @battle.weather==PBWeather::SANDSTORM ||
           @battle.FE==PBFields::NEWW)
          @battle.pbAnimation(PBMoves::SANDSTORM,self,nil)
          @battle.weather=PBWeather::SANDSTORM
          @battle.weatherduration=5
          @battle.weatherduration=8 if (target.hasWorkingItem(:SMOOTHROCK) ||
           @battle.FE == PBFields::DESERTF || @battle.FE == PBFields::ASHENB || @battle.FE == 43)
          @battle.pbCommonAnimation("Sandstorm")
          @battle.pbDisplay(_INTL("A sandstorm brewed!"))
        end
      end
      # Steam Engine
      if target.hasWorkingAbility(:STEAMENGINE) &&
        ((movetype == PBTypes::WATER) || (movetype == PBTypes::FIRE))
        if target.pbCanIncreaseStatStage?(PBStats::SPEED)
          target.pbIncreaseStatBasic(PBStats::SPEED,6)
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s {2} drastically raised its Speed!",
           target.pbThis,PBAbilities.getName(target.ability)))
        end
      end
      if target.hasWorkingItem(:AIRBALLOON,true)
        target.pbDisposeItem(false)
        @battle.pbDisplay(_INTL("{1}'s Air Balloon popped!",target.pbThis))
      end
      if target.hasWorkingItem(:ABSORBBULB) && movetype == PBTypes::WATER
        if target.pbCanIncreaseStatStage?(PBStats::SPATK)
          target.pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!", target.pbThis,PBItems.getName(target.item)))
             target.pbDisposeItem(false)
        end
      end
      if target.hasWorkingItem(:CELLBATTERY) && movetype == PBTypes::ELECTRIC
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
          target.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!", target.pbThis,PBItems.getName(target.item)))
          target.pbDisposeItem(false)
        end
      end
      if target.hasWorkingItem(:SNOWBALL) && movetype == PBTypes::ICE
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
          target.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!", target.pbThis,PBItems.getName(target.item)))
          target.pbDisposeItem(false)
        end
      end
      if target.hasWorkingItem(:LUMINOUSMOSS) && movetype == PBTypes::WATER
        if target.pbCanIncreaseStatStage?(PBStats::SPDEF)
          target.pbIncreaseStatBasic(PBStats::SPDEF,1)
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Defense!", target.pbThis,PBItems.getName(target.item)))
          target.pbDisposeItem(false)
        end
      end

      if target.hasWorkingItem(:KEEBERRY) && move.pbIsPhysical?(movetype)
        if target.pbCanIncreaseStatStage?(PBStats::DEFENSE)
          target.pbIncreaseStatBasic(PBStats::DEFENSE,1)
          @battle.pbCommonAnimation("Nom",target)
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Defense!", target.pbThis,PBItems.getName(target.item)))
          target.pbDisposeItem(true)
        end
      end

      if target.hasWorkingItem(:MARANGABERRY) && move.pbIsSpecial?(movetype)
        if target.pbCanIncreaseStatStage?(PBStats::SPDEF)
          target.pbIncreaseStatBasic(PBStats::SPDEF,1)
          @battle.pbCommonAnimation("Nom",target)
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Defense!", target.pbThis,PBItems.getName(target.item)))
          target.pbDisposeItem(true)
        end
      end

      if target.hasWorkingItem(:JABOCABERRY,true) && !user.isFainted? && move.pbIsPhysical?(movetype)
        @battle.pbCommonAnimation("Nom",target)
        @battle.scene.pbDamageAnimation(user,0)
        user.pbReduceHP((user.totalhp/8.0).floor)
        @battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis, PBItems.getName(target.item)))
        target.pbDisposeItem(true)
      end
      if target.hasWorkingItem(:ROWAPBERRY,true) && !user.isFainted? && move.pbIsSpecial?(movetype)
        @battle.pbCommonAnimation("Nom",target)
        @battle.scene.pbDamageAnimation(user,0)
        user.pbReduceHP((user.totalhp/8.0).floor)
        @battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis, PBItems.getName(target.item)))
        target.pbDisposeItem(true)
      end

      if target.hasWorkingItem(:WEAKNESSPOLICY) && target.damagestate.typemod>4
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
          target.pbIncreaseStatBasic(PBStats::ATTACK,2)
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Attack!", target.pbThis,PBItems.getName(target.item)))
          target.pbDisposeItem(false)
        end
        if target.pbCanIncreaseStatStage?(PBStats::SPATK)
          target.pbIncreaseStatBasic(PBStats::SPATK,2)
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s Weakness Policy sharply raised its Special Attack!", target.pbThis,PBItems.getName(target.item)))
          target.pbDisposeItem(false)
        end
      end
      if target.hasWorkingAbility(:ANGERPOINT)
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK) && target.damagestate.critical
          target.stages[PBStats::ATTACK]=6
          @battle.pbCommonAnimation("StatUp",target)
          @battle.pbDisplay(_INTL("{1}'s {2} maxed its Attack!",
           target.pbThis,PBAbilities.getName(target.ability)))
         end
      end
      if target.hasWorkingItem(:REDCARD) && !target.damagestate.substitute
        choices = []
        party=@battle.pbParty(user.index)
        for i in 0...party.length
          choices[choices.length]=i if @battle.pbCanSwitchLax?(user.index,i,false)
        end
        if choices.length!=0
          @battle.pbDisplay(_INTL("#{target.pbThis}'s Red Card activates!"))
          target.pbDisposeItem(false)
          if user.hasWorkingAbility(:SUCTIONCUPS)
           @battle.pbDisplay(_INTL("{1} anchored itself with {2}!",user.pbThis,PBAbilities.getName(user.ability)))
          elsif user.effects[PBEffects::Ingrain]
            @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",user.pbThis))
          else
            user.forcedSwitch = true
          end
        end
      end
    end
    user.pbAbilityCureCheck
    target.pbAbilityCureCheck
    # Synchronize here
    s=@battle.synchronize[0]
    t=@battle.synchronize[1]
    if s>=0 && t>=0 && @battle.battlers[s].hasWorkingAbility(:SYNCHRONIZE) &&
       @battle.synchronize[2]>0 && !@battle.battlers[t].isFainted?
      # see [2024281]&0xF0, [202420C]
      sbattler=@battle.battlers[s]
      tbattler=@battle.battlers[t]
      if @battle.synchronize[2]==PBStatuses::POISON && tbattler.pbCanPoisonSynchronize?(sbattler,true)
        # UPDATE 11/17/2013
        # allows for transfering of `badly poisoned` instead of just poison.
        #changed from: tbattler.pbPoison(sbattler)
        tbattler.pbPoison(sbattler, sbattler.statusCount == 1)
            @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",sbattler.pbThis,
           PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      elsif @battle.synchronize[2]==PBStatuses::BURN && tbattler.pbCanBurnSynchronize?(sbattler,true)
        tbattler.pbBurn(sbattler)
        @battle.pbDisplay(_INTL("{1}'s {2} burned {3}!",sbattler.pbThis,
           PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      elsif @battle.synchronize[2]==PBStatuses::PARALYSIS && tbattler.pbCanParalyzeSynchronize?(sbattler,true)
        tbattler.pbParalyze(sbattler)
        @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           sbattler.pbThis,PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      end
    end
  end

  def pbAbilityCureCheck
    return if self.isFainted?
    if self.ability == PBAbilities::LIMBER && self.status==PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1}'s Limber cured its paralysis problem!",pbThis))
      self.status=0
    end
    if self.ability == PBAbilities::OBLIVIOUS && @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1}'s Oblivious cured its love problem!",pbThis))
      @effects[PBEffects::Attract]=-1
    end
    if self.ability == PBAbilities::VITALSPIRIT && self.status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1}'s Vital Spirit cured its sleep problem!",pbThis))
      self.status=0
    end
    if self.ability == PBAbilities::INSOMNIA && self.status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1}'s Insomnia cured its sleep problem!",pbThis))
      self.status=0
    end
    if self.ability == PBAbilities::IMMUNITY && self.status==PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1}'s Immunity cured its poison problem!",pbThis))
      self.status=0
    end
    if self.ability == PBAbilities::OWNTEMPO && @effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1}'s Own Tempo cured its confusion problem!",pbThis))
      @effects[PBEffects::Confusion]=0
    end
    if self.ability == PBAbilities::MAGMAARMOR && self.status==PBStatuses::FROZEN
      @battle.pbDisplay(_INTL("{1}'s Magma Armor cured its ice problem!",pbThis))
      self.status=0
    end
    if self.ability == PBAbilities::WATERVEIL && self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1}'s Water Veil cured its burn problem!",pbThis))
      self.status=0
    end
  end

  def pbEmergencyExitCheck(oldhp)
    if oldhp >= (@totalhp/2.0).floor && (self.hp + self.pbBerryRecoverAmount) < (@totalhp/2.0).floor && self.hp!=0
      if (self.ability == PBAbilities::WIMPOUT || self.ability == PBAbilities::EMERGENCYEXIT) && 
        ((@battle.pbCanChooseNonActive?(self.index) && !@battle.pbAllFainted?(@battle.pbParty(self.index))) || @battle.pbIsWild?)
        if @battle.pbIsWild?
          return if @battle.cantescape || $game_switches[:Never_Escape] == true
          @battle.decision=3 # Set decision to escaped
        else
          self.userSwitch = true
        end
        @battle.pbDisplay(_INTL("{1} tactically retreated!",self.pbThis)) if self.ability == PBAbilities::EMERGENCYEXIT
        @battle.pbDisplay(_INTL("{1} wimped out!",self.pbThis)) if self.ability == PBAbilities::WIMPOUT
      end
    end
  end

################################################################################
# Held item effects
################################################################################
  def pbBerryRecoverAmount
    return 0 if self.isFainted?
    return 0 if pbOpposing1.hasWorkingAbility(:UNNERVE) || pbOpposing2.hasWorkingAbility(:UNNERVE)
    healing = 0
    case self.item
      when PBItems::ORANBERRY then healing = 10 if self.hp<=(self.totalhp/2.0).floor
      when PBItems::SITRUSBERRY then healing = (self.totalhp/4.0).floor if self.hp<=(self.totalhp/2.0).floor
      when PBItems::ENIGMABERRY then healing = (self.totalhp/4.0).floor if self.damagestate.typemod>4
      when PBItems::BERRYJUICE then healing = 20 if self.hp<=(self.totalhp/2.0).floor
      when PBItems::FIGYBERRY, PBItems::WIKIBERRY, PBItems::MAGOBERRY, PBItems::AGUAVBERRY, PBItems::IAPAPABERRY
        healing = (self.totalhp/2.0).floor if self.hp<=(self.totalhp/4.0).floor || (self.ability == PBAbilities::GLUTTONY && self.hp<=(self.totalhp/2.0).floor)
    end
    healing*=2 if self.ability==PBAbilities::RIPEN
    return healing
  end

  def pbBerryCureCheck(hpcure=false)
    return if self.isFainted?
    return if !self.itemWorks?
    return if self.item==0
    itemname=PBItems.getName(self.item)
    #non-berries go first!
    hpcure=false if @effects[PBEffects::HealBlock]!=0
    if hpcure && (self.item == PBItems::LEFTOVERS || (self.item == PBItems::BLACKSLUDGE && pbHasType?(:POISON))) && self.hp!=self.totalhp
      pbRecoverHP((self.totalhp/16.0).floor,true)
      @battle.pbDisplay(_INTL("{1}'s {2} restored its HP a little!",pbThis,itemname))
      return
    end
    if hpcure && (self.item == PBItems::BLACKSLUDGE && !pbHasType?(:POISON)) && self.ability != PBAbilities::MAGICGUARD
      pbReduceHP((self.totalhp/8.0).floor,true)
      @battle.pbDisplay(_INTL("{1} was hurt by its {2}!",pbThis,itemname))
      pbFaint if self.isFainted?
      return
    end
    if self.item == PBItems::WHITEHERB
      reducedstats=false
      for i in 1..7
        if @stages[i]<0
          @stages[i]=0; reducedstats=true
        end
      end
      if reducedstats
        @battle.pbDisplay(_INTL("{1}'s {2} restored its status!",pbThis,itemname))
        pbDisposeItem(false)
        return
      end
    end
    if self.item == PBItems::MENTALHERB && (@effects[PBEffects::Attract]>=0 || @effects[PBEffects::Taunt]>0 || @effects[PBEffects::Encore]>0 ||
       @effects[PBEffects::Torment] || @effects[PBEffects::Disable]>0 || @effects[PBEffects::HealBlock]>0)
      @battle.pbDisplay(_INTL("{1}'s {2} cured its love problem!",pbThis,itemname)) if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1} is taunted no more!",pbThis)) if @effects[PBEffects::Taunt]>0
      @battle.pbDisplay(_INTL("{1}'s encore ended!",pbThis)) if @effects[PBEffects::Encore]>0
      @battle.pbDisplay(_INTL("{1} is tormented no more!",pbThis)) if @effects[PBEffects::Torment]
      @battle.pbDisplay(_INTL("{1} is disabled no more!",pbThis)) if @effects[PBEffects::Disable]>0
      @battle.pbDisplay(_INTL("{1}'s heal block ended!",pbThis)) if @effects[PBEffects::HealBlock]>0
      @effects[PBEffects::Attract]=-1
      @effects[PBEffects::Taunt]=0
      @effects[PBEffects::Encore]=0
      @effects[PBEffects::EncoreMove]=0
      @effects[PBEffects::EncoreIndex]=0
      @effects[PBEffects::Torment]=false
      @effects[PBEffects::Disable]=0
      @effects[PBEffects::HealBlock]=0
      pbDisposeItem(false)
      return
    end
    #berries go now!
    #non-berries can get the fuck out of here
    return if pbOpposing1.hasWorkingAbility(:UNNERVE) || pbOpposing2.hasWorkingAbility(:UNNERVE) || !(pbIsBerry?(self.item) || self.item == PBItems::BERRYJUICE)
    pbUseBerry
  end

  def pbUseBerry(berry=0,special=false)
    #split from berrycurecheck to allow bug bite to skip everything
    #healing also acts as a way to check if a berry was eaten
    healing = -1
    confu_berry = false
    stat_berry = false
    status_berry = false
    berry = self.item if berry == 0
    health_threshold = self.ability == PBAbilities::GLUTTONY ? (self.totalhp/2.0).floor : (self.totalhp/4.0).floor
    itemname=PBItems.getName(berry)
    case berry
      when PBItems::ORANBERRY   then healing = 10 if self.hp <= (self.totalhp/2.0).floor || special
      when PBItems::SITRUSBERRY then healing = (self.totalhp/4.0).floor if self.hp <= (self.totalhp/2.0).floor || special
      when PBItems::ENIGMABERRY then healing = (self.totalhp/4.0).floor if self.damagestate.typemod > 4 || special
      when PBItems::BERRYJUICE  then healing = 20 if self.hp <= (self.totalhp/2.0).floor || special
      when PBItems::FIGYBERRY, PBItems::WIKIBERRY, PBItems::MAGOBERRY, PBItems::AGUAVBERRY, PBItems::IAPAPABERRY
        healing = (self.totalhp/2.0).floor if self.hp <= health_threshold || special
        confu_berry = true
      when PBItems::CHERIBERRY
        healing = 0 if self.status==PBStatuses::PARALYSIS
        status_berry = true 
        status = "paralysis"
      when PBItems::CHESTOBERRY
        healing = 0 if self.status==PBStatuses::SLEEP
        status_berry = true 
        status = "sleep"
      when PBItems::PECHABERRY
        healing = 0 if self.status==PBStatuses::POISON
        status_berry = true 
        status = "poison"
      when PBItems::RAWSTBERRY
        healing = 0 if self.status==PBStatuses::BURN
        status_berry = true 
        status = "burn"
      when PBItems::ASPEARBERRY
        healing = 0 if self.status==PBStatuses::FROZEN
        status_berry = true 
        status = "ice"
      when PBItems::PERSIMBERRY
        healing = 0 if @effects[PBEffects::Confusion]>0
        status_berry = true 
        status = "confusion"
      when PBItems::LUMBERRY
        healing = 0 if self.status>0 || @effects[PBEffects::Confusion]>0
        status_berry = true 
        status = "status"
      when PBItems::LIECHIBERRY, PBItems::GANLONBERRY, PBItems::SALACBERRY, PBItems::PETAYABERRY, PBItems::APICOTBERRY, PBItems::STARFBERRY
        healing = 0 if self.hp <= health_threshold
        stat_berry = true
        if berry == PBItems::STARFBERRY
          stats=[]
          for i in 1..5
            stats.push(i) if !pbTooHigh?(i)
          end
          return if stats.length == 0
          chosen_stat = stats[@battle.pbRandom(stats.length)]
          stat_amt = 2
        else
          case berry
            when PBItems::LIECHIBERRY then chosen_stat = 1
            when PBItems::GANLONBERRY then chosen_stat = 2
            when PBItems::SALACBERRY then chosen_stat = 3
            when PBItems::PETAYABERRY then chosen_stat = 4
            when PBItems::APICOTBERRY then chosen_stat = 5
          end
          return if self.pbTooHigh?(chosen_stat)
          stat_amt = 1
        end
      when PBItems::LANSATBERRY #unique berry, doing the processing now
        if @effects[PBEffects::FocusEnergy]<3 && self.hp <= health_threshold
          healing = 0 
          message = _INTL("{1} used its {2} to get pumped!",pbThis,itemname)
          @effects[PBEffects::FocusEnergy]+=1 
        end
      when PBItems::LEPPABERRY #unique berry, doing the processing now
        if @pokemon.moves.any?{|move| move.id!=0 && move.pp==0}
          healing = 0 
          for i in 0...@pokemon.moves.length
            pokemove=@pokemon.moves[i]
            next if pokemove.pp!=0 && pokemove.id!=0
            pokemove.pp = self.ability == PBAbilities::RIPEN ? 20 : 10
            pokemove.pp=pokemove.totalpp if pokemove.pp>pokemove.totalpp
            self.moves[i].pp=pokemove.pp
            break
          end
          message = _INTL("{1}'s {2} restored {3}'s PP!",pbThis,itemname,PBMoves.getName(pokemove.id))
        end
    end
    #return if berry didn't trigger
    return if healing == -1 && !special
    @battle.pbCommonAnimation("Nom",self,nil)
    if healing > 0  #this berry is ACTUALLY a healing berry
      healing*=2 if self.ability==PBAbilities::RIPEN
      self.pbRecoverHP(healing,true)
      message = _INTL("{1}'s {2} restored health!",pbThis,itemname)
    elsif status_berry
      self.status = 0 if berry != PBItems::PERSIMBERRY
      @effects[PBEffects::Confusion] = 0 if berry == PBItems::PERSIMBERRY || berry == PBItems::LUMBERRY
      message = _INTL("{1}'s {2} cured its {3} problem!",pbThis,itemname,status)
    elsif stat_berry
      case chosen_stat
        when PBStats::ATTACK then message = _INTL("Using its {1}, the Attack of {2} rose!",itemname,pbThis(true))
        when PBStats::DEFENSE then message = _INTL("Using its {1}, the Defense of {2} rose!",itemname,pbThis(true))
        when PBStats::SPEED then message = _INTL("Using its {1}, the Speed of {2} rose!",itemname,pbThis(true))
        when PBStats::SPATK then message = _INTL("Using its {1}, the Special Attack of {2} rose!",itemname,pbThis(true))
        when PBStats::SPDEF then message = _INTL("Using its {1}, the Special Defense of {2} rose!",itemname,pbThis(true))
      end
      stat_amt*=2 if self.ability==PBAbilities::RIPEN
      @battle.pbCommonAnimation("StatUp",self,nil)
      pbIncreaseStatBasic(chosen_stat,stat_amt)
    elsif confu_berry
      case berry
        when PBItems::FIGYBERRY then flavor = 0; flavor_text = "spicy"
        when PBItems::WIKIBERRY then flavor = 3; flavor_text = "dry"
        when PBItems::MAGOBERRY then flavor = 2; flavor_text = "sweet"
        when PBItems::AGUAVBERRY then flavor = 4; flavor_text = "bitter"
        when PBItems::IAPAPABERRY then flavor = 1; flavor_text = "sour"
      end
      confusion = (self.nature%5) == flavor && (self.nature/5).floor != (self.nature%5)
    end
    @battle.pbDisplay(message) if message
    if confusion && pbCanConfuseSelf?(true,false)
      @battle.pbDisplay(_INTL("For {1}, the {2} was too {3}!",pbThis(true),itemname,flavor_text,true))
      if @effects[PBEffects::Confusion]==0 && self.ability != PBAbilities::OWNTEMPO
        @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
        @battle.pbCommonAnimation("Confusion",self,nil)
        @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
      end
    end
    if special
      pbBurp
      pbSymbiosis
    else
      pbDisposeItem
    end
  end

  def pbCustapBerry
    if self.hasWorkingItem(:CUSTAPBERRY) && ((self.ability == PBAbilities::GLUTTONY && self.hp<=(self.totalhp/2.0).floor) || self.hp<=(self.totalhp/4.0).floor)
      @custap = true
      @battle.pbCommonAnimation("Nom",self,nil)
      @battle.pbDisplay(_INTL("{1} ate its Custap Berry to move first!",pbThis))
      self.pbDisposeItem(true)
    else
      @custap = false
    end
  end

  def pbDisposeItem(berry=true,symbiosis=true)
    self.pokemon.itemRecycle=self.item
    self.pokemon.itemInitial=0 if self.pokemon.itemInitial==self.item
    self.item=0
    pbBurp(self) if berry
    pbSymbiosis(self)
  end

  def pbBurp(target=self)
    target.pokemon.belch = true
    if target.ability == PBAbilities::CHEEKPOUCH
      target.pbRecoverHP((target.totalhp/3.0).floor,true)
      @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,PBAbilities.getName(target.ability)))
    end
  end

  def pbSymbiosis(target=self)
    return if !@battle.doublebattle || target.hp == 0 || target.pbPartner.hp == 0
    return if target.pbPartner.ability != PBAbilities::SYMBIOSIS
    return if target.pbPartner.item == 0 || target.item != 0
    @battle.pbDisplay(_INTL("{1} received {2}'s {3} from symbiosis! ",target.pbThis, target.pbPartner.pbThis, PBItems.getName(target.pbPartner.item)))
    target.item = target.pbPartner.item
    target.pokemon.itemInitial = target.pbPartner.item
    target.pbPartner.pokemon.itemInitial = 0
    target.pbPartner.item=0
  end


################################################################################
# Move user and targets
################################################################################
  def pbFindUser(choice,targets)
    move=choice[2]
    target=choice[3]
    user=self   # Normally, the user is self
    # Targets in normal cases
    if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter == 4 && PBFields::MAXGARDENMOVES.include?(move.id)
      # Just pbOpposing1 because partner is determined late
      pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
    else
      case pbTarget(move)
        when PBTargets::SingleNonUser
          if target>=0
            targetBattler=@battle.battlers[target]
            if !pbIsOpposing?(targetBattler.index)
              if !pbAddTarget(targets,targetBattler) && move.id != PBMoves::INSTRUCT
                pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
              end
            else
              pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
            end
          else
            pbRandomTarget(targets)
          end
        when PBTargets::SingleOpposing
          if target>=0
            targetBattler=@battle.battlers[target]
            if !pbIsOpposing?(targetBattler.index)
              if !pbAddTarget(targets,targetBattler)
                pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
              end
            else
              pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
            end
          else
            pbRandomTarget(targets)
          end
        when PBTargets::OppositeOpposing
          pbAddTarget(targets,pbCrossOpposing) if !pbAddTarget(targets,pbOppositeOpposing)
          pbRandomTarget(targets) if targets.length==0
        when PBTargets::RandomOpposing
          pbRandomTarget(targets)
        when PBTargets::AllOpposing
          # Just pbOpposing1 because partner is determined late
          pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
        when PBTargets::AllNonUsers
          for i in 0...4 # not ordered by priority
            pbAddTarget(targets,@battle.battlers[i]) if i!=@index
          end
        when PBTargets::DragonDarts
          smartDart = move.pbDragonDartTargetting(user)
          case smartDart.length
            when 1
              pbAddTarget(targets,smartDart[0])
            when 2
              pbAddTarget(targets,smartDart[0])
              pbAddTarget(targets,smartDart[1])
          end
          # doesn't work for singles, but as a proof of concept does what I want!
          #if pbOpposing1.pbHasType?(:NORMAL)
          #  pbAddTarget(targets,pbOpposing2)
          #else
          #  pbAddTarget(targets,pbOpposing2) && pbAddTarget(targets,pbOpposing1)
          #end
        when PBTargets::UserOrPartner
          if target>=0 # Pre-chosen target
            targetBattler=@battle.battlers[target]
            pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
          else
            pbAddTarget(targets,self)
          end
        when PBTargets::Partner
          pbAddTarget(targets,pbPartner)
        else
          move.pbAddTarget(targets,self)
      end
    end
    return user
  end

  def pbChangeUser(thismove,user)
    priority=@battle.pbPriority
    # Change user to user of Snatch
    if thismove.canSnatch?
      for i in priority
        if i.effects[PBEffects::Snatch]
          @battle.pbDisplay(_INTL("{1} snatched {2}'s move!",i.pbThis,user.pbThis(true)))
          i.effects[PBEffects::Snatch]=false
          target=user
          user=i
          # Snatch's PP is reduced if old user has Pressure
          userchoice=@battle.choices[user.index][1]
          if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
            pressuremove=user.moves[userchoice]
            pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
          end
        end
      end
    end
    return user
  end

  def pbTarget(move)
    target=move.target
    if move.function==0x10D && pbHasType?(:GHOST) # Curse
      target=PBTargets::SingleNonUser
    end
    side=(pbIsOpposing?(self.index)) ? 1 : 0
    owner=@battle.pbGetOwnerIndex(self.index)
    if @battle.zMove[side][owner]==self.index && self.item == PBItems::KOMMONIUMZ2
      target=PBTargets::AllOpposing
    elsif @battle.zMove[side][owner]==self.index && move.category != 2
      target=PBTargets::SingleNonUser
    end
    return target
  end

  def pbAddTarget(targets,target)
    if !target.isFainted?
      targets[targets.length]=target
      return true
    end
    return false
  end

  def pbRandomTarget(targets)
    choices=[]
    pbAddTarget(choices,pbOpposing1)
    pbAddTarget(choices,pbOpposing2)
    if choices.length>0
      pbAddTarget(targets,choices[@battle.pbRandom(choices.length)])
    end
  end

  def pbChangeTarget(thismove,userandtarget,targets)
    priority=@battle.pbPriority
    changeeffect=0
    user=userandtarget[0]
    target=userandtarget[1]
    if (thismove.function==0x179) || user.hasWorkingAbility(:STALWART) || user.hasWorkingAbility(:PROPELLERTAIL)
      return true
    end
    # LightningRod here, considers Hidden Power as Normal
    if targets.length==1 && thismove.pbType(user) == PBTypes::ELECTRIC && !target.hasWorkingAbility(:LIGHTNINGROD)
      for i in priority # use Pokémon earliest in priority
        next if i.index==user.index || i.isFainted?
        if i.ability == PBAbilities::LIGHTNINGROD && !i.moldbroken
          target=i # X's LightningRod took the attack!
          changeeffect=1
          break
        end
      end
    end
    # Storm Drain here, considers Hidden Power as Normal
    if targets.length==1 && thismove.type == PBTypes::WATER && !target.hasWorkingAbility(:STORMDRAIN)
      for i in priority # use Pokémon earliest in priority
        next if !pbIsOpposing?(i.index) || i.isFainted?
        if i.ability == PBAbilities::STORMDRAIN && !i.moldbroken
          target=i # X's Storm Drain took the attack!
          changeeffect=2
          break
        end
      end
    end
    # Change target to user of Follow Me (overrides Magic Coat
    # because check for Magic Coat below uses this target)
    if thismove.target==PBTargets::SingleNonUser ||
       thismove.target==PBTargets::SingleOpposing ||
       thismove.target==PBTargets::RandomOpposing ||
       thismove.target==PBTargets::OppositeOpposing
      for i in priority # use Pokémon latest in priority
        next if !pbIsOpposing?(i.index) || i.isFainted?
        if i.effects[PBEffects::FollowMe] || i.effects[PBEffects::RagePowder]
          unless (i.effects[PBEffects::RagePowder] && (self.ability == PBAbilities::OVERCOAT || self.pbHasType?(:GRASS) || self.hasWorkingItem(:SAFETYGOGGLES)))# change target to this
            target=i
            changeeffect = 0
          end
        end
      end
    end
    # TODO: Pressure here is incorrect if Magic Coat redirects target
    if target.hasWorkingAbility(:PRESSURE)
      pbReducePP(thismove) # Reduce PP
    end
    # Change user to user of Snatch
    if thismove.canSnatch?
      for i in priority
        if i.effects[PBEffects::Snatch]
          @battle.pbDisplay(_INTL("{1} Snatched {2}'s move!",i.pbThis,user.pbThis(true)))
          i.effects[PBEffects::Snatch]=false
          target=user
          user=i
          # Snatch's PP is reduced if old user has Pressure
          userchoice=@battle.choices[user.index][1]
          if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
            pressuremove=user.moves[userchoice]
            pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
          end
        end
      end
    end
    userandtarget[0]=user
    userandtarget[1]=target
    if target.hasWorkingAbility(:SOUNDPROOF) && thismove.isSoundBased? &&
       thismove.function!=0x19 &&   # Heal Bell handled elsewhere
       thismove.function!=0xE5 &&   # Perish Song handled elsewhere
       !(target.moldbroken)
      @battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",target.pbThis,
         PBAbilities.getName(target.ability),thismove.name))
      return false
    end
    if thismove.canMagicCoat? && target.effects[PBEffects::MagicCoat]
      # switch user and target
      changeeffect=3
      target.effects[PBEffects::MagicCoat]=false
      user, target = target, user

      # Magic Coat's PP is reduced if old user has Pressure
      userchoice=@battle.choices[user.index][1]
      if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
        pressuremove=user.moves[userchoice]
        pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
      end
    end
    if !(user.effects[PBEffects::MagicBounced]) && thismove.canMagicCoat? && target.hasWorkingAbility(:MAGICBOUNCE) && !(target.moldbroken) &&
      !(thismove.function==0x103) && !(thismove.function==0x104) && !(thismove.function==0x105) && !(thismove.function==0x141) &&
      !PBStuff::TWOTURNMOVE.include?(target.effects[PBEffects::TwoTurnAttack]) && changeeffect != 3
      target.effects[PBEffects::MagicBounced]=true
      target.effects[PBEffects::BouncedMove]=thismove
    end
    if changeeffect==1
      @battle.pbDisplay(_INTL("{1}'s Lightningrod took the move!",target.pbThis))
    elsif changeeffect==2
      @battle.pbDisplay(_INTL("{1}'s Storm Drain took the move!",target.pbThis))
    elsif changeeffect==3
      # Target refers to the move's old user
      @battle.pbDisplay(_INTL("{1}'s {2} was bounced back by Magic Coat!",user.pbThis,thismove.name))
    end
    userandtarget[0]=user
    userandtarget[1]=target
    if thismove.zmove
      targets[0]=target
    end
    return true
  end

  def pbFutureSightUserPlusMove()
    moveuser=nil
    disabled_items = {}
    #check if battler on the field
    for indexx in [@effects[PBEffects::FutureSightUser],@effects[PBEffects::FutureSightUser]^2]
      moveuser=@battle.battlers[indexx] if @battle.battlers[indexx].pokemonIndex == @effects[PBEffects::FutureSightPokemonIndex]
    end
    #if battler not on the field, make a fake one
    if moveuser.nil?
      moveuser=PokeBattle_Battler.new(@battle,@effects[PBEffects::FutureSightUser],true)
      begin
        moveuser.pbInitPokemon(@battle.pbParty(@effects[PBEffects::FutureSightUser])[@effects[PBEffects::FutureSightPokemonIndex]],@effects[PBEffects::FutureSightUser])
      rescue
        moveuser.pbInitPokemon(@battle.pbParty(@effects[PBEffects::FutureSightUser]^1)[@effects[PBEffects::FutureSightPokemonIndex]],@effects[PBEffects::FutureSightUser])
      end
      disabled_items = {:item => moveuser.item.clone, :ability => moveuser.ability.clone}
      moveuser.item=0
      moveuser.ability=0
      
    end
    if @effects[PBEffects::FutureSightMove] == PBMoves::DOOMDESIRE
      move=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(PBMoves::DOOMDUMMY),moveuser)
    elsif @effects[PBEffects::FutureSightMove] == PBMoves::FUTURESIGHT
      move=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(PBMoves::FUTUREDUMMY),moveuser)
    end
    return move, moveuser, disabled_items
  end

################################################################################
# Move PP
################################################################################
  def pbSetPP(move,pp)
    move.pp=pp
    #Not effects[PBEffects::Mimic], since Mimic can't copy Mimic
    if move.thismove && move.id==move.thismove.id && !@effects[PBEffects::Transform]
      move.thismove.pp=pp
    end
  end

  def pbReducePP(move)
    #TODO: Pressure
    if @effects[PBEffects::TwoTurnAttack]>0 ||
       @effects[PBEffects::Bide]>0 ||
       @effects[PBEffects::Outrage]>0 ||
       @effects[PBEffects::Rollout]>0 ||
       @effects[PBEffects::HyperBeam]>0 ||
       @effects[PBEffects::Uproar]>0
      # No need to reduce PP if two-turn attack
      return true
    end
    return true if move.pp<0   # No need to reduce PP for special calls of moves
    return true if move.totalpp==0   # Infinite PP, can always be used
    return false if move.pp==0
    if move.pp>0
      pbSetPP(move,move.pp-1)
    end
    return true
  end

  def pbReducePPOther(move)
    pbSetPP(move,move.pp-1) if move.pp>0
  end

################################################################################
# Using a move
################################################################################
  def pbObedienceCheck?(choice)
    return true if @battle.isOnline?
    return true if choice[0]!=1
    return true if self.pokemon.obedient
    if @battle.pbOwnedByPlayer?(@index) && @battle.internalbattle
      badgelevel=LEVELCAPS[@battle.pbPlayer.numbadges]
      move=choice[2]
      disobedient=false
      a=((@level+badgelevel)*@battle.pbRandom(256)/255.0).floor
      disobedient|=a<badgelevel
      if self.respond_to?("pbHyperModeObedience")
        disobedient|=!self.pbHyperModeObedience(move)
      end
      if disobedient
        @effects[PBEffects::Rage]=false
        if self.status==PBStatuses::SLEEP &&
           (move.function==0x11 || move.function==0xB4) # Snore, Sleep Talk
          @battle.pbDisplay(_INTL("{1} ignored orders while asleep!",pbThis))
          return false
        end
        b=((@level+badgelevel)*@battle.pbRandom(256)/255.0).floor
        #if b<badgelevel
        #  return false if !@battle.pbCanShowFightMenu?(@index)
        #  othermoves=[]
        #  for i in 0...4
        #    next if i==choice[1]
        #    othermoves[othermoves.length]=i if @battle.pbCanChooseMove?(@index,i,false)
        #  end
        #  if othermoves.length>0
        #    @battle.pbDisplay(_INTL("{1} ignored orders!",pbThis))
        #    newchoice=othermoves[@battle.pbRandom(othermoves.length)]
        #    choice[1]=newchoice
        #    choice[2]=@moves[newchoice]
        #    choice[3]=-1
        #  end
        #  return true
        #elsif self.status!=PBStatuses::SLEEP
        if self.status!=PBStatuses::SLEEP
          c=@level-b
          r=@battle.pbRandom(256)
          if r<c && pbCanSleep?(false,true)
            pbSleepSelf()
            @battle.pbDisplay(_INTL("{1} took a nap!",pbThis))
            return false
          end
          r-=c
          if r<c
            @battle.pbDisplay(_INTL("{1} won't obey!",pbThis))
            @battle.pbDisplay(_INTL("It hurt itself from its confusion!"))
            pbConfusionDamage
          else
            message=@battle.pbRandom(4)
            @battle.pbDisplay(_INTL("{1} ignored orders!",pbThis)) if message==0
            @battle.pbDisplay(_INTL("{1} turned away!",pbThis)) if message==1
            @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis)) if message==2
            @battle.pbDisplay(_INTL("{1} pretended not to notice!",pbThis)) if message==3
          end
          return false
        end
      end
      return true
    else
      return true
    end
  end

  def pbSuccessCheck(thismove,user,target,flags,accuracy=true)
    if user.hasWorkingAbility(:PRANKSTER) && (!(thismove.pbIsPhysical?(thismove.type) || thismove.pbIsSpecial?(thismove.type)) || (!thismove.zmove && !flags[:instructed] && @battle.choices[user.index][2]!=thismove))
      if target.pbHasType?(:DARK)
        @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
        return false
      end
    end
    if ((((target.abilityWorks? && (target.ability == PBAbilities::DAZZLING || target.ability == PBAbilities::QUEENLYMAJESTY)) || 
      (target.pbPartner.abilityWorks? && (target.pbPartner.ability == PBAbilities::DAZZLING || target.pbPartner.ability == PBAbilities::QUEENLYMAJESTY))) && !target.moldbroken) ||
      @battle.FE == PBFields::PSYCHICT && !target.isAirborne?) && target.pbPartner!=user
      if thismove.positivePriority?(user) || (user.hasWorkingAbility(:PRANKSTER) && !thismove.zmove && !flags[:instructed] && @battle.choices[user.index][2]!=thismove)
        @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
        return false
      end
    end

    if user.effects[PBEffects::TwoTurnAttack]>0
      PBDebug.log("[Using two-turn attack]") if $INTERNAL
      return true
    end
    # TODO: "Before Protect" applies to Counter/Mirror Coat
    if thismove.function==0xDE && ((target.status!=PBStatuses::SLEEP && !target.hasWorkingAbility(:COMATOSE)) || !(user.effects[PBEffects::HealBlock]==0))  # Dream Eater
      @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
      return false
    end
    if (thismove.function==0xDD || thismove.function==0x139 || thismove.function==0x158) && !(user.effects[PBEffects::HealBlock]==0) # Absorbtion Moves
      @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
      return false
    end
    if thismove.function==0x113 && user.effects[PBEffects::Stockpile]==0 # Spit Up
      @battle.pbDisplay(_INTL("But it failed to spit up a thing!"))
      return false
    end

    if !thismove.zmove # Z-Moves handle protection stuff elsewhere
      if target.pbOwnSide.effects[PBEffects::MatBlock] && ((thismove.id == PBMoves::PHANTOMFORCE) || (thismove.id == PBMoves::SHADOWFORCE) ||
          (thismove.id == PBMoves::HYPERSPACEHOLE) || (thismove.id == PBMoves::HYPERSPACEFURY))
            @battle.pbDisplay(_INTL("The Mat Block was broken!"))
      end

      if target.pbOwnSide.effects[PBEffects::MatBlock] && (thismove.pbIsPhysical?(thismove.type) || thismove.pbIsSpecial?(thismove.type)) &&
        thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation]
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        @battle.successStates[user.index].protected=true
        return false
      end

      if target.pbOwnSide.effects[PBEffects::CraftyShield] && thismove.basedamage == 0 && !target.effects[PBEffects::ProtectNegation]
        @battle.pbDisplay(_INTL("{1}'s Crafty Shield activated!",target.pbThis))
        user.pbCancelMoves
        @battle.successStates[user.index].protected=true
        return false
      end

      if target.pbOwnSide.effects[PBEffects::WideGuard] && (thismove.target == PBTargets::AllOpposing ||
        thismove.target == PBTargets::AllNonUsers) && thismove.basedamage > 0 && thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation]
        if !target.pbPartner.effects[PBEffects::WideGuardCheck]
          if target.effects[PBEffects::WideGuardUser]
            @battle.pbDisplay(_INTL("{1}'s Wide Guard prevented damage!",target.pbThis))
            user.pbCancelMoves
            @battle.successStates[user.index].protected=true
          elsif target.pbPartner.effects[PBEffects::WideGuardUser]
            @battle.pbDisplay(_INTL("{1}'s Wide Guard prevented damage!",target.pbPartner.pbThis))
            user.pbCancelMoves
            @battle.successStates[user.index].protected=true
          end
          target.effects[PBEffects::WideGuardCheck]=true
        else
          target.pbPartner.effects[PBEffects::WideGuardCheck]=false
          user.pbCancelMoves
          @battle.successStates[user.index].protected=true
        end
        return false
      end
      if target.pbOwnSide.effects[PBEffects::QuickGuard] && thismove.positivePriority?(user) && thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation]
        @battle.pbDisplay(_INTL("{1}'s Quick Guard prevented damage!",target.pbThis))
        user.pbCancelMoves
        @battle.successStates[user.index].protected=true
        return false
      end
      # Protect / King's Shield / Obstruct / Spiky Shield / Baneful Bunker
      if !target.effects[PBEffects::ProtectNegation] && thismove.canProtectAgainst? && thismove.function!=0x116 &&
        ((target.effects[PBEffects::KingsShield] && (thismove.basedamage > 0 || @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::CHESSB)) || target.effects[PBEffects::Protect] ||
        (target.effects[PBEffects::Obstruct] && thismove.basedamage > 0) || target.effects[PBEffects::SpikyShield] || target.effects[PBEffects::BanefulBunker])
        @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
        @battle.successStates[user.index].protected=true
        # physical contact
        if thismove.hasFlags?('a') && !(user.abilityWorks? && user.ability == PBAbilities::LONGREACH)
          if target.effects[PBEffects::KingsShield]
            user.pbReduceStat(PBStats::ATTACK,2)
            user.pbReduceStat(PBStats::SPATK,2) if @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::CHESSB
          elsif target.effects[PBEffects::Obstruct]
            user.pbReduceStat(PBStats::DEFENSE,2)
          elsif target.effects[PBEffects::SpikyShield]
            user.pbReduceHP((user.totalhp/8.0).floor)
            @battle.pbDisplay(_INTL("{1}'s Spiky Shield hurt {2}!",target.pbThis,user.pbThis(true)))
          elsif target.effects[PBEffects::BanefulBunker] && user.pbCanPoison?(false)
            user.pbPoison(target)
            @battle.pbDisplay(_INTL("{1}'s Baneful Bunker poisoned {2}!",target.pbThis,user.pbThis(true)))
          end
        end
        return false
      end
    end
    # TODO: Mind Reader/Lock-On
    # --Sketch/FutureSight/PsychUp work even on Fly/Bounce/Dive/Dig
    if thismove.pbMoveFailed(user,target) # TODO: Applies to Snore/Fake Out
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if accuracy
      if target.effects[PBEffects::LockOn]>0 && target.effects[PBEffects::LockOnPos]==user.index
        return true
      end
      invulmiss=false
      invulmove=$cache.pkmn_move[target.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]
      case invulmove
        when 0xC9, 0xCC # Fly, Bounce
          invulmiss=true unless PBStuff::AIRHITMOVES.include?(thismove.id) || (thismove.function==0x10D && !user.pbHasType?(:GHOST)) || (thismove.id == PBMoves::WHIRLWIND)
        when 0xCA # Dig
          (invulmiss=true) unless thismove.function==0x76 || thismove.function==0x95 || (thismove.function==0x10D && !user.pbHasType?(:GHOST)) # Curse
        when 0xCB # Dive
          (invulmiss=true) unless thismove.function==0x75 || thismove.function==0xD0 || (thismove.function==0x10D && !user.pbHasType?(:GHOST)) # Curse
        when 0xCD # Shadow Force
          (invulmiss=true)
        when 0xCE # Sky Drop
          invulmiss=true unless PBStuff::AIRHITMOVES.include?(thismove.id) || (thismove.function==0x10D && !user.pbHasType?(:GHOST))
      end
      if target.effects[PBEffects::SkyDrop]
        invulmiss=true unless thismove.function==0xCE || PBStuff::AIRHITMOVES.include?(thismove.id) || (thismove.function==0x10D && !user.pbHasType?(:GHOST))
      end
      if user.hasWorkingAbility(:NOGUARD) || target.hasWorkingAbility(:NOGUARD) || (user.hasWorkingAbility(:FAIRYAURA) && @battle.FE==PBFields::FAIRYTALEF)
        invulmiss=false
      end
      if invulmiss
        if thismove.target==PBTargets::AllOpposing && (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) > 1
          # All opposing Pokémon
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.target==PBTargets::AllNonUsers &&
           (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) + (!user.pbPartner.isFainted? ? 1 : 0) > 1
          # All non-users
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.function==0xDC # Leech Seed
          @battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))          
        elsif thismove.function==0x70 && (((target.hasWorkingAbility(:STURDY) && !target.moldbroken) || user.level < target.level) || target.pokemon.piece==:PAWN && @battle.FE==PBFields::CHESSB)
          @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
        elsif thismove.function==0x70 && !((target.hasWorkingAbility(:STURDY)) || (user.level<target.level))
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s attack missed!",user.pbThis))
        end
        user.missAcc = true
        return false
      end
    end
    if thismove.id==PBMoves::THUNDERWAVE && thismove.pbTypeModMessages(thismove.type,user,target)==0
      return false
    end
    #if damage dealing move
    if thismove.basedamage>0 && thismove.function!=0x02 && thismove.function!=0x111 # Struggle / Future Sight
      type=thismove.pbType(user)
      typemod=thismove.pbTypeModifier(type,user,target)
      typemod=thismove.fieldTypeChange(user,target,typemod)
      if (type == PBTypes::GROUND) && target.isAirborne? && !target.hasWorkingItem(:RINGTARGET) && @battle.FE != PBFields::CAVE && thismove.id != PBMoves::THOUSANDARROWS
        if target.hasWorkingAbility(:LEVITATE) && !(target.moldbroken)
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Levitate!",target.pbThis))
          return false
        end
        if target.hasWorkingItem(:AIRBALLOON)
          @battle.pbDisplay(_INTL("{1}'s Air Balloon makes Ground moves miss!",target.pbThis))
          return false
        end
        if target.effects[PBEffects::MagnetRise]>0
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Magnet Rise!",target.pbThis))
          return false
        end
        if target.effects[PBEffects::Telekinesis]>0
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Telekinesis!",target.pbThis))
          return false
        end
      end
      if target.hasWorkingAbility(:WONDERGUARD) && typemod<=4 && type>=0  && !(target.moldbroken)
        @battle.pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",target.pbThis))
        return false
      end
      if typemod==0 && !thismove.function==0x111 #Future Sight/Doom Desire
        @battle.pbDisplay(_INTL("It doesn't affect\r\n{1}...",target.pbThis(true)))
        return false
      end
      if typemod==0 && thismove.function==0x10B # (Hi) Jump Kick
        @battle.pbDisplay(_INTL("It doesn't affect\r\n{1}...",target.pbThis(true)))
        return false
      end
    end
    if thismove.basedamage==0 #Status move type absorb abilities
      type=thismove.pbType(user)
      if thismove.pbStatusMoveAbsorption(type,user,target)==0
        return false
      end
    end
    if accuracy
      if target.effects[PBEffects::LockOn]>0 && target.effects[PBEffects::LockOnPos]==user.index
        return true
      end
      if !thismove.pbAccuracyCheck(user,target) # Includes Counter/Mirror Coat
        if thismove.target==PBTargets::AllOpposing && (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) > 1
          # All opposing Pokémon
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.target==PBTargets::AllNonUsers && (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) + (!user.pbPartner.isFainted? ? 1 : 0) > 1
          # All non-users
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.function==0xDC # Leech Seed
          @battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
        elsif thismove.function==0x70 && (((target.hasWorkingAbility(:STURDY) && !target.moldbroken) || user.level < target.level) || @battle.FE==PBFields::CHESSB && target.pokemon.piece==:PAWN)
          @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
        elsif thismove.function==0x70 && !((target.hasWorkingAbility(:STURDY)) || (user.level<target.level))
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s attack missed!",user.pbThis))
          if user.effects[PBEffects::SkyDroppee]!=nil
            target.effects[PBEffects::SkyDrop]=false
            user.effects[PBEffects::SkyDroppee] = nil
            @battle.scene.pbUnVanishSprite(target)
            @battle.pbDisplay(_INTL("{1} is freed from the Sky Drop effect!",target.pbThis))
          end
          if @battle.FE == PBFields::MIRRORA && thismove.basedamage>0 && (thismove.target==PBTargets::SingleNonUser || thismove.id == PBMoves::MIRRORCOAT) && 
           (thismove.flags&0x01)==0 && thismove.pbIsSpecial?(type) && target.stages[PBStats::EVASION]>0
            @battle.pbDisplay(_INTL("The attack was reflected by the mirror!",user.pbThis))
            @battle.field.counter = 1
            return true
          end
        end
        return false
      end
    end
    return true
  end

  def pbTryUseMove(choice,thismove,flags={passedtrying: false, instructed: false})
    return true if flags[:passedtrying]
    # TODO: Return true if attack has been Mirror Coated once already
    return false if !pbObedienceCheck?(choice)
    return false if self.forcedSwitchEarlier
     # Stance Change moved from here to end of method to match Gen VII mechanics.
    # TODO: If being Sky Dropped, return false
    # TODO: Gravity prevents airborne-based moves here
    if @effects[PBEffects::Taunt]>0 && thismove.basedamage==0
      @battle.pbDisplay(_INTL("{1} can't use {2} after the taunt!", pbThis,thismove.name))
      return false
    end
    if @effects[PBEffects::HealBlock]>0 && thismove.isHealingMove?
      @battle.pbDisplay(_INTL("{1} can't use {2} after the Heal Block!", pbThis,thismove.name))
      return false
    end
    if thismove.isSoundBased? && self.effects[PBEffects::ThroatChop]>0
      @battle.pbDisplay(_INTL("{1} can't use sound-based moves because of it's throat damage!",pbThis))
      return false
    end
    if @effects[PBEffects::Torment] && !flags[:instructed] && thismove.id==@lastMoveUsed &&
       thismove.id!=@battle.struggle.id
      @battle.pbDisplay(_INTL("{1} can't use the same move in a row due to the torment!",
         pbThis))
      return false
    end
    if pbOpposing1.effects[PBEffects::Imprison] && !@simplemove
      if thismove.id==pbOpposing1.moves[0].id || thismove.id==pbOpposing1.moves[1].id || thismove.id==pbOpposing1.moves[2].id || thismove.id==pbOpposing1.moves[3].id
        @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!",
           pbThis,thismove.name))
        PBDebug.log("[#{pbOpposing1.pbThis} has: #{pbOpposing1.moves[0].id}, #{pbOpposing1.moves[1].id},#{pbOpposing1.moves[2].id} #{pbOpposing1.moves[3].id}]") if $INTERNAL
        return false
      end
    end
    if pbOpposing2.effects[PBEffects::Imprison] && !@simplemove
      if thismove.id==pbOpposing2.moves[0].id || thismove.id==pbOpposing2.moves[1].id || thismove.id==pbOpposing2.moves[2].id || thismove.id==pbOpposing2.moves[3].id
        @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!", pbThis,thismove.name))
        PBDebug.log("[#{pbOpposing2.pbThis} has: #{pbOpposing2.moves[0].id}, #{pbOpposing2.moves[1].id},#{pbOpposing2.moves[2].id} #{pbOpposing2.moves[3].id}]") if $INTERNAL
        return false
      end
    end
    if @effects[PBEffects::Disable]>0 && thismove.id==@effects[PBEffects::DisableMove]
      @battle.pbDisplayPaused(_INTL("{1}'s {2} is disabled!",pbThis,thismove.name))
      return false
    end
    if self.ability == PBAbilities::TRUANT && @effects[PBEffects::Truant]
      @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis))
      return false
    end
    if choice[1]==-2 # Battle Palace
      @battle.pbDisplay(_INTL("{1} appears incapable of using its power!",pbThis))
      return false
    end
    if @effects[PBEffects::HyperBeam]>0
      @battle.pbDisplay(_INTL("{1} must recharge!",pbThis))
      return false
    end
    if self.status==PBStatuses::SLEEP && !@simplemove
      self.statusCount-=1
      self.statusCount-=1 if self.ability == PBAbilities::EARLYBIRD
      if self.statusCount<=0
        self.pbCureStatus
      else
        self.pbContinueStatus
        if !thismove.pbCanUseWhileAsleep? # Snore/Sleep Talk
          return false
        end
      end
    end
    if self.status==PBStatuses::FROZEN
      if thismove.canThawUser?
        self.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1} was defrosted by {2}!",pbThis,thismove.name))
        pbCheckForm
      elsif @battle.pbRandom(10)<2
        self.pbCureStatus
        pbCheckForm
      elsif !thismove.canThawUser?
        self.pbContinueStatus
        return false
      end
    end

    if @effects[PBEffects::Flinch]
      @effects[PBEffects::Flinch]=false
      if @battle.FE == PBFields::ROCKYF
        if !(self.ability == PBAbilities::STEADFAST) && !(self.ability == PBAbilities::STURDY) && !(self.ability == PBAbilities::INNERFOCUS) && (self.stages[PBStats::DEFENSE] < 1)
          @battle.pbDisplay(_INTL("{1} was knocked into a rock!",pbThis))
          damage=[1,(self.totalhp/4.0).floor].max
          if damage>0
            @battle.scene.pbDamageAnimation(self,0)
            self.pbReduceHP(damage)
          end
          if self.hp<=0
            self.pbFaint
            return false
          end
        end
      end
      if self.ability == PBAbilities::INNERFOCUS
        @battle.pbDisplay(_INTL("{1} won't flinch because of its {2}!", self.pbThis,PBAbilities.getName(self.ability)))
      elsif self.stages[PBStats::DEFENSE] >= 1 && @battle.FE == PBFields::ROCKYF
        @battle.pbDisplay(_INTL("{1} won't flinch because of its bolstered Defenses!", self.pbThis,PBAbilities.getName(self.ability)))
      else
        @battle.pbDisplay(_INTL("{1} flinched and couldn't move!",self.pbThis))
        if self.ability == PBAbilities::STEADFAST
          if pbCanIncreaseStatStage?(PBStats::SPEED)
            pbIncreaseStat(PBStats::SPEED,1,statmessage: false)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!", self.pbThis,PBAbilities.getName(self.ability)))
          end
        end
        return false
      end
    end

    if @effects[PBEffects::Confusion]>0 && !@simplemove
      @effects[PBEffects::Confusion]-=1
      if @effects[PBEffects::Confusion]<=0
        pbCureConfusion
      else
        pbContinueConfusion
        if @battle.pbRandom(3)==0
          @battle.pbDisplay(_INTL("It hurt itself from its confusion!"))
          pbConfusionDamage
          return false
        end
      end
    end

    if @effects[PBEffects::Attract]>=0 && !@simplemove && !thismove.zmove
      pbAnnounceAttract(@battle.battlers[@effects[PBEffects::Attract]])
      if @battle.pbRandom(2)==0
        pbContinueAttract
        return false
      end
    end
    if self.status==PBStatuses::PARALYSIS && !@simplemove && !thismove.zmove
      if @battle.pbRandom(4)==0
        pbContinueStatus
        return false
      end
    end
    # UPDATE 2/13/2014
    # implementing Protean
    protype=thismove.type
    if (thismove.id == PBMoves::HIDDENPOWER)
      protype = pbHiddenPower(self.pokemon)
    end
    if (self.ability == PBAbilities::PROTEAN || self.ability == PBAbilities::LIBERO) && thismove.id != PBMoves::STRUGGLE
      prot1 = self.type1
      prot2 = self.type2
      if !self.pbHasType?(protype) || (defined?(prot2) && prot1 != prot2)
        self.type1=protype
        self.type2=protype
        typename=PBTypes.getName(protype)
        @battle.pbDisplay(_INTL("{1} had its type changed to {3}!",pbThis,PBAbilities.getName(self.ability),typename))
      end
    end # end of update
    if (self.ability == PBAbilities::STANCECHANGE)
      pbCheckForm(thismove)
    end
    flags[:passedtrying]=true
    return true
  end

  def pbConfusionDamage
    self.damagestate.reset
    confmove=PokeBattle_Confusion.new(@battle,nil)
    confmove.pbEffect(self,self)
    pbFaint if self.isFainted?
  end

  def pbProcessMoveAgainstTarget(thismove,user,target,numhits,flags={totaldamage: 0},nocheck=false,alltargets=nil,showanimation=true)
    realnumhits=0
    flags[:totaldamage] = 0 if !flags[:totaldamage]
    totaldamage=flags[:totaldamage]
    destinybond=false
    wimpcheck=false
    berserkcheck=false
    if target
      aboveHalfHp = target.hp>(target.totalhp/2.0).floor
    end

    for i in 0...numhits
      if user.status==PBStatuses::SLEEP && !thismove.pbCanUseWhileAsleep? && !@simplemove
        realnumhits = i
        break
      end
      if target
        innardsOutHp = target.hp
      end
      if !target
       tantrumCheck = thismove.pbEffect(user,target,i,alltargets,showanimation)
       if tantrumCheck == -1
         user.effects[PBEffects::Tantrum]=true
       else
         user.effects[PBEffects::Tantrum]=false
       end
        return
      end
      # Check success (accuracy/evasion calculation)
      if !nocheck && !pbSuccessCheck(thismove,user,target,flags,i==0 || thismove.function==0xBF) # Triple Kick
       if thismove.function==0xC9 || thismove.function==0xCA || thismove.function==0xCB ||
          thismove.function==0xCC || thismove.function==0xCD || thismove.function==0xCE #Sprites for two turn moves
          @battle.scene.pbUnVanishSprite(user)
        end
        if thismove.function==0xBF && realnumhits>0   # Triple Kick
          break   # Considered a success if Triple Kick hits at least once
        elsif thismove.function==0x10B   # Hi Jump Kick, Jump Kick
          #TODO: Not shown if message is "It doesn't affect XXX..."
          @battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
          damage=[1,(user.totalhp/2.0).floor].max
          if (user.ability == PBAbilities::MAGICGUARD)
            damage=0
          end
          if damage>0
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP(damage)
          end
          user.pbFaint if user.isFainted?
          # Rocky Field Crash
        elsif @battle.FE == PBFields::ROCKYF  && (thismove.flags&0x01)!=0 &&
         !(user.ability == PBAbilities::ROCKHEAD) && (!(target.effects[PBEffects::SpikyShield] || target.effects[PBEffects::Protect] || target.effects[PBEffects::KingsShield] ||
          target.effects[PBEffects::BanefulBunker] || target.effects[PBEffects::Obstruct]))
          @battle.pbDisplay(_INTL("{1} hit a rock instead!",user.pbThis))
          damage=[1,(user.totalhp/8.0).floor].max
          if damage>0
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP(damage)
          end
          user.pbFaint if user.isFainted?
        elsif @battle.FE == PBFields::MIRRORA && (thismove.flags&0x01)!=0
          @battle.pbDisplay(_INTL("{1} hit a mirror instead!",user.pbThis))
          @battle.pbDisplay(_INTL("The mirror shattered!",user.pbThis))
          damage=[1,(user.totalhp/4.0).floor].max
          if damage>0
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP(damage)
          end
          user.pbFaint if user.isFainted?
          user.pbReduceStat(PBStats::EVASION,1) if user.stages[PBStats::EVASION] > 0
        end
        if user.hasWorkingItem(:BLUNDERPOLICY) && user.missAcc
          if user.pbCanIncreaseStatStage?(PBStats::SPEED)
            user.pbIncreaseStatBasic(PBStats::SPEED,1)
            @battle.pbCommonAnimation("StatUp",user)
            @battle.pbDisplay(_INTL("The Blunder Policy raised #{user.pbThis}'s Speed!"))
            user.pbDisposeItem(false)
          end
        end
        user.effects[PBEffects::Tantrum]=true
        user.effects[PBEffects::Outrage]=0 if thismove.function==0xD2 # Outrage
        user.effects[PBEffects::Rollout]=0 if thismove.function==0xD3 # Rollout
        user.effects[PBEffects::Charge]-=1 if user.effects[PBEffects::Charge]>0 # Charge wearing off
        user.effects[PBEffects::FuryCutter]=0 if thismove.function==0x91 # Fury Cutter
        user.effects[PBEffects::EchoedVoice]+=1 if thismove.function==0x92 # Echoed Voice
        user.effects[PBEffects::EchoedVoice]=0 if thismove.function!=0x92 # Not Echoed Voice
        user.effects[PBEffects::Stockpile]=0 if thismove.function==0x113 # Spit Up
        return 0
      end
      if thismove.function==0x91 # Fury Cutter
        user.effects[PBEffects::FuryCutter]+=1 if user.effects[PBEffects::FuryCutter]<3
      else
        user.effects[PBEffects::FuryCutter]=0
      end
      if thismove.function==0x92 # Echoed Voice
        user.effects[PBEffects::EchoedVoice]+=1 if user.effects[PBEffects::EchoedVoice]<5
      else
        user.effects[PBEffects::EchoedVoice]=0
      end
      # This hit will happen; count it
      realnumhits+=1
      # Damage calculation and/or main effect
      revanish=false
      if target.vanished && !((thismove.function==0xC9 || thismove.function==0xCA || thismove.function==0xCB ||
          thismove.function==0xCC || thismove.function==0xCD) && !user.vanished)
        revanish=true
        revanish=false if thismove.function==0xCE
        revanish=false if thismove.function==0x11C
        revanish=false if (thismove.function==0x10D && !user.pbHasType?(:GHOST)) # Curse
        @battle.scene.pbUnVanishSprite(target) unless ((thismove.function==0x10D && !user.pbHasType?(:GHOST)) || thismove.function==0xCE) # Curse
      end
      # Special Move Effects are applied here
      damage = thismove.pbEffect(user,target,i,alltargets,showanimation)
      user.effects[PBEffects::Tantrum]= (damage == -1)
      totaldamage += damage if damage && damage > 0
      if user.isFainted?
        user.pbFaint # no return
      end
      if revanish && !(target.isFainted?)
        @battle.pbCommonAnimation("Fade out",target,nil)
        @battle.scene.pbVanishSprite(target)
      end
      if numhits>1 && target.damagestate.calcdamage<=0
        unless thismove.id == PBMoves::ROCKBLAST && @battle.FE == PBFields::CRYSTALC
          return
        end
      end
      @battle.pbJudgeCheckpoint(user,thismove)

      # Additional effect
      if target.damagestate.calcdamage>0 && ((!target.hasWorkingAbility(:SHIELDDUST) || target.moldbroken) || thismove.hasFlags?("m")) && !user.hasWorkingAbility(:SHEERFORCE)
        addleffect=thismove.addlEffect
        addleffect*=2 if user.hasWorkingAbility(:SERENEGRACE) || @battle.FE == PBFields::RAINBOWF
        addleffect=100 if $DEBUG && Input.press?(Input::CTRL) && !@battle.isOnline?
        addleffect=100 if thismove.id == PBMoves::MIRRORSHOT && @battle.FE == PBFields::MIRRORA
        if @battle.pbRandom(100)<addleffect
          thismove.pbAdditionalEffect(user,target)
        end
        if @battle.pbRandom(100)<addleffect
          thismove.pbSecondAdditionalEffect(user,target)
        end

        # Gulp Missile
        if (self.species == PBSpecies::CRAMORANT) && self.ability == PBAbilities::GULPMISSILE && !self.isFainted? && (thismove.id == 538 || thismove.id == 541) # Surf or Dive
          if self.form==0
            if self.hp*2.0 > self.totalhp
              self.form = 1 # Gulping Form
            else
              self.form = 2 # Gorging Form
            end
          end
          transformed = true
          pbUpdate(false)
          @battle.scene.pbChangePokemon(self,@pokemon)
          if self.form==1
            @battle.pbDisplay(_INTL("{1} transformed into Gulping Forme!",pbThis))
          elsif self.form==2
            @battle.pbDisplay(_INTL("{1} transformed into Gorging Forme!",pbThis))
          end
        end
      end

      # Corrosion random status
      if user.ability == PBAbilities::CORROSION && @battle.FE == PBFields::WASTELAND && damage > 0
        if @battle.pbRandom(10)==0
          case @battle.pbRandom(4)
            when 0 then target.pbBurn(user)       if target.pbCanBurn?(false)
            when 1 then target.pbPoison(user)     if target.pbCanPoison?(false)
            when 2 then target.pbParalyze(user)   if target.pbCanParalyze?(false)
            when 3 then target.pbFreeze           if target.pbCanFreeze?(false)
          end
        end
      end

      # Ability effects
      pbEffectsOnDealingDamage(thismove,user,target,damage,innardsOutHp)

      # Berserk
      if !target.isFainted? && aboveHalfHp && target.hp<=(target.totalhp/2.0).floor && !berserkcheck
        if target.hasWorkingAbility(:BERSERK)
          if !pbTooHigh?(PBStats::SPATK)
            target.pbIncreaseStatBasic(PBStats::SPATK,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s Berserk boosted its Special Attack!",
            target.pbThis))
            berserkcheck=true
          end
        end
      end
      # Emergency Exit / Wimp Out
      if !target.isFainted? && aboveHalfHp && (target.hp + target.pbBerryRecoverAmount)<=(target.totalhp/2.0).floor
        if (target.abilityWorks? && (target.ability == PBAbilities::EMERGENCYEXIT || target.ability == PBAbilities::WIMPOUT)) && 
          ((@battle.pbCanChooseNonActive?(target.index) && !@battle.pbAllFainted?(@battle.pbParty(target.index))) || @battle.pbIsWild?)
          if !wimpcheck
            @battle.pbDisplay(_INTL("{1} tactically retreated!",target.pbThis)) if target.ability == PBAbilities::EMERGENCYEXIT
            @battle.pbDisplay(_INTL("{1} wimped out!",target.pbThis)) if target.ability == PBAbilities::WIMPOUT
            wimpcheck=true
          end
          @battle.pbClearChoices(target.index)
          if @battle.pbIsWild? && !(@battle.cantescape || $game_switches[:Never_Escape] == true)
            @battle.decision=3 # Set decision to escaped
          else
            target.userSwitch = true
            if user.userSwitch
              @battle.scene.pbUnVanishSprite(user)
              user.userSwitch=false
            end
          end
        end
      end
      # Grudge
      if !user.isFainted? && target.isFainted?
        if target.effects[PBEffects::Grudge] && target.pbIsOpposing?(user.index)
          pbSetPP(thismove,thismove.pp=0)
          @battle.pbDisplay(_INTL("{1}'s {2} lost all its PP due to the grudge!",
             user.pbThis,thismove.name))
        end
      end
      # Throat Spray
      if user.hasWorkingItem(:THROATSPRAY) && thismove.isSoundBased? && user.hp>0
        if user.pbCanIncreaseStatStage?(PBStats::SPATK)
          user.pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",user,nil)
          @battle.pbDisplay(_INTL("The Throat Spray raised #{user.pbThis}'s Sp.Atk!"))
          user.pbDisposeItem(false)
        end
      end
      # Eject Pack
      if target.hasWorkingItem(:EJECTPACK) && target.statLowered
        if !target.isFainted? && @battle.pbCanChooseNonActive?(target.index) && !@battle.pbAllFainted?(@battle.pbParty(target.index))
          @battle.pbDisplay(_INTL("#{target.pbThis}'s Eject Pack activates!"))
          target.pbDisposeItem(false,false)
          @battle.pbClearChoices(target.index)
          target.userSwitch = true
        end
      end
      if target.isFainted?
          ###YUMIL - 1 - NPC REACTION MOD - START  
         if @battle.recorded == true
           $battleDataArray.last().pokemonFaintedAnEnemy(@battle.battlers,user,target,thismove)
         end
         ### YUMIL - 1 - NPC REACTION MOD - END 
        destinybond=destinybond || target.effects[PBEffects::DestinyBond]
      end
      ###YUMIL - 2 - NPC REACTION MOD - START 
      #user.pbFaint if user.isFainted? # no return
      if user.isFainted?
        user.pbFaint
        if @battle.recorded == true
          $battleDataArray.last().pokemonFaintedAnEnemy(@battle.battlers,target,user,thismove)
        end
      end
        ### YUMIL - 2 - NPC REACTION MOD - END 
      break if user.isFainted?
      break if target.isFainted?
      # Make the target flinch
      if target.damagestate.calcdamage>0 && !target.damagestate.substitute
        if (!(target.ability == PBAbilities::SHIELDDUST) || target.moldbroken) || thismove.hasFlags?("m")
          if (user.hasWorkingItem(:KINGSROCK) || user.hasWorkingItem(:RAZORFANG)) &&
           thismove.canKingsRock? # && target.status!=PBStatuses::SLEEP && target.status!=PBStatuses::FROZEN #Gen 2 only thing #perry
            if @battle.pbRandom(10)==0
              target.effects[PBEffects::Flinch]=true
            end
          elsif user.hasWorkingAbility(:STENCH) &&
           thismove.function!=0x09 && # Thunder Fang
           thismove.function!=0x0B && # Fire Fang
           thismove.function!=0x0E && # Ice Fang
           thismove.function!=0x0F && # flinch-inducing moves
           thismove.function!=0x10 && # Stomp
           thismove.function!=0x11 && # Snore
           thismove.function!=0x12 && # Fake Out
           thismove.function!=0x78 && # Twister
           thismove.function!=0xC7 #&& # Sky Attack
            if (@battle.pbRandom(10)==0 || ((@battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS) && @battle.pbRandom(10) < 2))
              target.effects[PBEffects::Flinch]=true
            end
          end
        end
      end
      if target.damagestate.calcdamage>0 && !target.isFainted?
        # Defrost
        if (thismove.pbType(user) == PBTypes::FIRE || thismove.function==0x0A) && target.status==PBStatuses::FROZEN && !(user.hasWorkingAbility(:PARENTALBOND) && i==0)
          target.pbCureStatus
        end
        # Rage
        if target.effects[PBEffects::Rage] && target.pbIsOpposing?(user.index)
          # TODO: Apparently triggers if opposing Pokémon uses Future Sight after a Future Sight attack
          if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
            target.pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s rage is building!",target.pbThis))
          end
        end
      end
      user.pbFaint if user.isFainted? # no return
      break if user.isFainted?
      break if target.isFainted?
      # Berry check (maybe just called by ability effect, since only necessary Berries are checked)
      for j in 0...4
        @battle.battlers[j].pbBerryCureCheck
      end
      if target.damagestate.calcdamage<=0
        unless thismove.id == PBMoves::ROCKBLAST && @battle.FE == PBFields::CRYSTALC #rock blast on crystal cavern
          break
        end
      end
    end
    flags[:totaldamage]+=totaldamage if totaldamage>0
    # Battle Arena only - attack is successful
    @battle.successStates[user.index].useState=2
    @battle.successStates[user.index].typemod=target.damagestate.typemod
    # Type effectiveness
    if numhits>1
      if target.damagestate.typemod>4
        @battle.pbDisplay(_INTL("It's super effective!"))
      elsif target.damagestate.typemod>=1 && target.damagestate.typemod<4
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
      if realnumhits==1
        @battle.pbDisplay(_INTL("Hit {1} time!",realnumhits))
      else
        @battle.pbDisplay(_INTL("Hit {1} times!",realnumhits))
      end
    end
    # Faint if 0 HP
    target.pbFaint if target.isFainted?
    user.pbFaint if user.isFainted? # no return
    if target.isFainted?
      if user.hasWorkingAbility(:MOXIE) && user.hp>0 && target.hp<=0
        if !user.pbTooHigh?(PBStats::ATTACK)
          @battle.pbCommonAnimation("StatUp",self,nil)
          user.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbDisplay(_INTL("{1}'s Moxie raised its Attack!",user.pbThis))
        end
      end
    end
    # TODO: If Poison Point, etc. triggered above, user's Synchronize somehow triggers
    #       here even if condition is removed before now [true except for Triple Kick]
    # Destiny Bond
    if !user.isFainted? && target.isFainted?
      if destinybond && target.pbIsOpposing?(user.index)
        @battle.pbDisplay(_INTL("{1} took its attacker down with it!",target.pbThis))
        user.pbReduceHP(user.hp)
        user.pbFaint # no return
        @battle.pbJudgeCheckpoint(user)
      end
    end
    # Color Change
    movetype=thismove.pbType(user)
    if target.hasWorkingAbility(:COLORCHANGE) && totaldamage>0 && !PBTypes.isPseudoType?(movetype) && !target.pbHasType?(movetype)
      target.type1=movetype
      target.type2=movetype
      @battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
         PBAbilities.getName(target.ability),PBTypes.getName(movetype)))
    end
    # Eject Button
    if target.hasWorkingItem(:EJECTBUTTON) && !target.damagestate.substitute && target.damagestate.calcdamage>0
      if !target.isFainted? && @battle.pbCanChooseNonActive?(target.index) && !@battle.pbAllFainted?(@battle.pbParty(target.index))
        @battle.pbDisplay(_INTL("#{target.pbThis}'s Eject Button activates!"))
        target.pbDisposeItem(false,false)
       # @battle.pbDisplay(_INTL("{1} went back to {2}!",target.pbThis,@battle.pbGetOwner(target.index).name))
        @battle.pbClearChoices(target.index)
        target.userSwitch = true
      end
    end
    # Berry check
    for j in 0...4
      @battle.battlers[j].pbBerryCureCheck
    end
    return damage
  end

  def pbUseMoveSimple(moveid,index=-1,target=-1,danced=false)
    choice=[]
    choice[0]=1       # "Use move"
    choice[1]=index   # Index of move to be used in user's moveset
    choice[2]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(moveid),self) # PokeBattle_Move object of the move
    choice[2].pp=-1
    choice[3]=target  # Target (-1 means no target yet)
    @simplemove=(danced==false) ? true : false
    if index>=0
      @battle.choices[@index][1]=index
    end
    @usingsubmove=true
    side=(@battle.pbIsOpposing?(self.index)) ? 1 : 0
    owner=@battle.pbGetOwnerIndex(self.index)
    if @battle.zMove[side][owner]==self.index && choice[2].basedamage>0
      crystal = pbZCrystalFromType(choice[2].type)
      PokeBattle_ZMoves.new(@battle,self,choice[2],crystal,choice)
    else
      pbUseMove(choice, {specialusage: true, danced: danced})
    end
    @usingsubmove=false
    @simplemove=false
    return
  end

  def pbDancerMoveCheck(id)
    if self.ability == PBAbilities::DANCER && @battle.FE == PBFields::BIGTOPA # Big Top
      if (PBStuff::DANCEMOVE).include?(id)
        boost=false
        if !pbTooHigh?(PBStats::SPATK)
          pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",self,nil) if !boost
          boost=true
        end
        if !pbTooHigh?(PBStats::SPEED)
          pbIncreaseStatBasic(PBStats::SPEED,1)
          @battle.pbCommonAnimation("StatUp",self,nil) if !boost
          boost=true
        end
        @battle.pbDisplay(_INTL("{1}'s Dancer boosted its Special Attack and Speed!", pbThis)) if boost
      end
    end
    for i in @battle.battlers
      next if i == self
      if i.ability == PBAbilities::DANCER && (PBStuff::DANCEMOVE).include?(id) && !self.effects[PBEffects::MagicBounced]
        @battle.pbDisplay(_INTL("{1} joined in with the dance!",i.pbThis))
        i.pbUseMoveSimple(id,-1,-1,true)
      end
    end
  end

  def pbUseMove(choice, flags={danced: false, totaldamage: 0, specialusage: false})
    danced=flags[:danced]
    # TODO: lastMoveUsed is not to be updated on nested calls
    flags[:totaldamage] = 0 if !flags[:totaldamage]
    # hasMovedThisRound by itself isn't enough for, say, Fake Out + Instruct.
    @isFirstMoveOfRound = !self.hasMovedThisRound?
    # Start using the move
    pbBeginTurn(choice)
    # Force the use of certain moves if they're already being used
    if (@effects[PBEffects::TwoTurnAttack]>0 || @effects[PBEffects::HyperBeam]>0 || @effects[PBEffects::Outrage]>0 || @effects[PBEffects::Rollout]>0 || @effects[PBEffects::Uproar]>0 || @effects[PBEffects::Bide]>0)
      PBDebug.log("[Continuing move]") if $INTERNAL
      choice[2]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@currentMove),self)
      flags[:specialusage]=true
    elsif @effects[PBEffects::Encore]>0
      if @battle.pbCanShowCommands?(@index) && @battle.pbCanChooseMove?(@index,@effects[PBEffects::EncoreIndex],false,flags)
        PBDebug.log("[Using Encore move]") if $INTERNAL
        if choice[1]!=@effects[PBEffects::EncoreIndex] # Was Encored mid-round
          choice[1]=@effects[PBEffects::EncoreIndex]
          choice[2]=@moves[@effects[PBEffects::EncoreIndex]]
          if choice[2].id == PBMoves::ACUPRESSURE
            choice[3]=self.index
          else
            choice[3]=-1 # No target chosen
          end
        end
      end
    end
    thismove=choice[2]
    return if !thismove || thismove.id==0 # if move was not chosen
    if !flags[:specialusage]
      # TODO: Quick Claw message
    end
    PBDebug.log("#{self.name} used #{thismove.name}") if $INTERNAL
    return false if self.effects[PBEffects::SkyDrop]
    if !pbTryUseMove(choice,thismove,flags)
      if self.vanished
        @battle.scene.pbUnVanishSprite(self)
        droprelease = self.effects[PBEffects::SkyDroppee]
        if droprelease!=nil
          oppmon = droprelease
          oppmon.effects[PBEffects::SkyDrop]=false
          @effects[PBEffects::SkyDroppee] = nil
          @battle.scene.pbUnVanishSprite(oppmon)
          @battle.pbDisplay(_INTL("{1} is freed from the Sky Drop effect!",oppmon.pbThis))
        end
      end
      self.lastMoveUsed=-1
      if !flags[:specialusage]
        self.lastMoveUsedSketch=-1 if self.effects[PBEffects::TwoTurnAttack]==0
        self.lastRegularMoveUsed=-1
        self.lastRoundMoved=@battle.turncount
      end
      pbCancelMoves
      @battle.pbGainEXP
      pbEndTurn(choice)
      @battle.pbJudgeSwitch
      return
    end
    if !flags[:specialusage]
      if !pbReducePP(thismove)
        @battle.pbDisplay(_INTL("{1} used\r\n{2}!",pbThis,thismove.name))
        @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
        self.lastMoveUsed=-1
        if !flags[:specialusage]
          self.lastMoveUsedSketch=-1 if self.effects[PBEffects::TwoTurnAttack]==0
          self.lastRegularMoveUsed=-1
          self.lastRoundMoved=@battle.turncount
        end
        pbEndTurn(choice)
        @battle.pbJudgeSwitch
        return
      end
    end
    if thismove.function!=0x92 # Echoed Voice
      self.effects[PBEffects::EchoedVoice]=0
    end
    if thismove.function!=0x91 # Fury Cutter
      self.effects[PBEffects::FuryCutter]=0
    end
    if @effects[PBEffects::Powder] && (thismove.type == PBTypes::FIRE)
      @battle.pbDisplay(_INTL("The powder around {1} exploded!",pbThis))
      @battle.pbCommonAnimation("Powder",self,nil)
      pbReduceHP((@totalhp/4.0).floor)
      pbFaint if @hp<1
      return false
    end
    # Remember that user chose a two-turn move
    if thismove.pbTwoTurnAttack(self)
      # Beginning use of two-turn attack
      @effects[PBEffects::TwoTurnAttack]=thismove.id
      @currentMove=thismove.id
    else
      @effects[PBEffects::TwoTurnAttack]=0 # Cancel use of two-turn attack
      @effects[PBEffects::SkyDroppee] = nil if thismove.id != PBMoves::SKYDROP
    end
    # "X used Y!" message
    case thismove.pbDisplayUseMessage(self)
      when 2   # Continuing Bide
        if !flags[:specialusage]
          self.lastRoundMoved=@battle.turncount
        end
        return
      when 1   # Starting Bide
        self.lastMoveUsed=thismove.id
        @lastMoveChoice = choice.clone
        if !flags[:specialusage]
          self.lastMoveUsedSketch=thismove.id if self.effects[PBEffects::TwoTurnAttack]==0
          self.lastRegularMoveUsed=thismove.id
          self.movesUsed.push(thismove.id)   # For Last Resort
          self.lastRoundMoved=@battle.turncount
        end
        @battle.lastMoveUsed=thismove.id
        @battle.lastMoveUser=self.index
        @battle.successStates[self.index].useState=2
        @battle.successStates[self.index].typemod=4
        return
      when -1   # Was hurt while readying Focus Punch, fails use
        self.lastMoveUsed=thismove.id
        @lastMoveChoice = choice.clone
        if !flags[:specialusage]
          self.lastMoveUsedSketch=thismove.id if self.effects[PBEffects::TwoTurnAttack]==0
          self.lastRegularMoveUsed=thismove.id
          self.movesUsed.push(thismove.id)   # For Last Resort
          self.lastRoundMoved=@battle.turncount
        end
        @battle.lastMoveUsed=thismove.id
        @battle.lastMoveUser=self.index
        @battle.successStates[self.index].useState=2 # somehow treated as a success
        @battle.successStates[self.index].typemod=4
        return
      end
    # Find the user and target(s)
    targets=[]
    user=pbFindUser(choice,targets)
    if (user.abilityWorks? && (user.ability == PBAbilities::MOLDBREAKER || user.ability == PBAbilities::TERAVOLT || user.ability == PBAbilities::TURBOBLAZE)) ||
       thismove.function==0x166 || thismove.function==0x176 || thismove.id==PBMoves::SEARINGSUNRAZESMASH || thismove.id==PBMoves::MENACINGMOONRAZEMAELSTROM || thismove.id==PBMoves::LIGHTTHATBURNSTHESKY # Solgaluna/crozma signatures
      for i in 0..3
        @battle.battlers[i].moldbroken = true
      end
    else
      for i in 0..3
        @battle.battlers[i].moldbroken = false
      end
    end
    if user.hasWorkingAbility(:CORROSION)
      for battlers in targets
        battlers.corroded = true
      end
    else
      for battlers in targets
        battlers.corroded = false
      end
    end
    # Battle Arena only - assume failure
    @battle.successStates[user.index].useState=1
    @battle.successStates[user.index].typemod=4
    # Check whether Selfdestruct works
    selffaint=(thismove.function==0xE0) # Selfdestruct
    if !thismove.pbOnStartUse(user) # Only Selfdestruct can return false here
      user.lastMoveUsed=thismove.id
      @lastMoveChoice = choice.clone
      if !flags[:specialusage]
        user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
        user.lastRegularMoveUsed=thismove.id
        user.movesUsed.push(thismove.id)   # For Last Resort
        user.lastRoundMoved=@battle.turncount
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=user.index
      # Might pbEndTurn need to be called here?
      return
    end
    if selffaint
      user.hp=0
      user.pbFaint # no return
      user.ability = user.pokemon.ability # restore ability just for this turn
    end
    # Record move as having been used
    user.lastMoveUsed=thismove.id
    @lastMoveChoice = choice.clone
    user.lastRoundMoved=@battle.turncount
    if !flags[:specialusage]
      user.lastMoveUsedSketch=thismove.id
      user.lastRegularMoveUsed=thismove.id
      user.movesUsed.push(thismove.id)   # For Last Resort
      user.effects[PBEffects::Metronome]=0 if thismove.id != user.movesUsed[-2]
    end
    @battle.lastMoveUsed=thismove.id
    @battle.lastMoveUser=user.index

    # Try to use move against user if there aren't any targets
    if targets.length==0 && !(@effects[PBEffects::TwoTurnAttack]>0)
      user=pbChangeUser(thismove,user)
      if thismove.target==PBTargets::SingleNonUser || thismove.target==PBTargets::RandomOpposing || thismove.target==PBTargets::AllOpposing || thismove.target==PBTargets::AllNonUsers || thismove.target==PBTargets::Partner || thismove.target==PBTargets::UserOrPartner || thismove.target==PBTargets::SingleOpposing || thismove.target==PBTargets::OppositeOpposing
        @battle.pbDisplay(_INTL("But there was no target..."))
        @effects[PBEffects::Rollout]=0 if @effects[PBEffects::Rollout]>0
        if PBStuff::TWOTURNMOVE.include?(thismove.id) #Sprites for two turn moves
          @battle.scene.pbUnVanishSprite(user)
        end
      else
        PBDebug.logonerr{
           thismove.pbEffect(user,nil)
        }
      end
      # fuckin flower garden
      if @battle.field.effect == PBFields::FLOWERGARDENF # Flower Garden Stages
        @battle.growField("The move") if PBFields::GROWMOVES.include?(thismove.id)
      end
      unless !thismove
        pbDancerMoveCheck(thismove.id) unless danced
      end
    else
      # We have targets
      movesucceeded=false
      showanimation=true
      disguisecheck=false
      disguisebustcheck=false
      alltargets=[]
      thismove.fieldmessageshown = false
      thismove.fieldmessageshown_type = false

      if @effects[PBEffects::TwoTurnAttack]>0 && targets.length==0
        numhits=thismove.pbNumHits(user)
        pbProcessMoveAgainstTarget(thismove,user,nil,numhits,flags,false,alltargets,showanimation)
      end
      for i in 0...targets.length
        alltargets.push(targets[i].index)
      end

      # For each target in turn
      i=0; loop do break if i>=targets.length
        # Get next target
        userandtarget=[user,targets[i]]
        success=pbChangeTarget(thismove,userandtarget,targets)
        user=userandtarget[0]
        target=userandtarget[1]
        if i==0 && (thismove.target==PBTargets::AllOpposing || (@battle.field.effect == PBFields::FLOWERGARDENF && PBFields::MAXGARDENMOVES.include?(thismove.id)))
          # Add target's partner to list of targets
          pbAddTarget(targets,target.pbPartner)
        end
        if target.effects[PBEffects::MagicBounced]
          success=false
        end
        if !success
          i+=1
          next
        end
        numhits=thismove.pbNumHits(user)

        # Parental bond
        if numhits == 1 && user.hasWorkingAbility(:PARENTALBOND)
         counter1=0
         counter2=0
          for k in @battle.battlers
           next if k.isFainted?
           counter1+=1
          end
          for j in @battle.battlers
            next unless user.pbIsOpposing?(j.index)
            next if j.isFainted?
            counter2+=1
          end
          user.effects[PBEffects::ParentalBond] = true unless ((thismove.target == PBTargets::AllNonUsers && !(counter1==2)) || (thismove.target == PBTargets::AllOpposing && !(counter2==1)))
          numhits = 2  unless ((thismove.target == PBTargets::AllNonUsers && !(counter1==2)) || (thismove.target == PBTargets::AllOpposing && !(counter2==1)))
        else
          user.effects[PBEffects::ParentalBond] = false
        end

        # Reset damage state, set Focus Band/Focus Sash to available
        target.damagestate.reset
        if target.hasWorkingItem(:FOCUSBAND) && @battle.pbRandom(10)==0
          target.damagestate.focusband=true
        end
        if target.hasWorkingItem(:FOCUSSASH)
          target.damagestate.focussash=true
        end

        # Use move against the current target
        disguisecheck = true if (target.index==0 || target.index==1) && target.effects[PBEffects::Disguise] # Only used to stop anim playing after a disguise is broken
        hitcheck = pbProcessMoveAgainstTarget(thismove,user,target,numhits,flags,false,alltargets,showanimation)
        disguisebustcheck = true if disguisecheck==true && !target.effects[PBEffects::Disguise]
        showanimation=false unless (hitcheck==0 && disguisebustcheck==false && @effects[PBEffects::TwoTurnAttack]==0 && (thismove.pbIsSpecial?(thismove.type) || thismove.pbIsPhysical?(thismove.type)))
        movesucceeded = true if hitcheck && hitcheck > 0
        i+=1
      end
      thismove.fieldmessageshown = false
      thismove.fieldmessageshown_type = false  

      # Metronome item
      if user.hasWorkingItem(:METRONOME) && movesucceeded
        user.effects[PBEffects::Metronome]+=1
      else
        user.effects[PBEffects::Metronome]=0
      end

      # Magic Bounce
      for i in targets
        if i.effects[PBEffects::BouncedMove]!=0 #lía
          move=i.effects[PBEffects::BouncedMove].id
          i.effects[PBEffects::BouncedMove]=0
          @battle.pbDisplay(_INTL("{1} bounced the {2} back!",i.pbThis,thismove.name))
          if @battle.FE == PBFields::MIRRORA
            if i.pbCanIncreaseStatStage?(PBStats::EVASION)
              i.pbIncreaseStatBasic(PBStats::EVASION,1)
              @battle.pbCommonAnimation("StatUp",i,nil)
              @battle.pbDisplay(_INTL("{1}'s Magic Bounce increased its evasion!",i.pbThis,thismove.name))
            end
          end
          #pbUseMoveSimple(moveid,index=-1,target=-1,danced=false)
          i.pbUseMoveSimple(move,-1,user.index,false)
          i.effects[PBEffects::MagicBounced]=false
        end
      end

      # Mold Breaker reset
      for battlers in targets
        battlers.moldbroken = false
        battlers.corroded = false
      end

      # Misc Field Effects 2
      case @battle.FE
        when PBFields::ICYF # Icy Field
          if PBFields::QUAKEMOVES.include?(thismove.id)
            if @battle.field.backup == PBFields::WATERS
              @battle.setField(PBFields::WATERS)
              @battle.pbDisplay(_INTL("The quake broke up the ice and revealed the water beneath!"))
            else
              spikevar=false
              if @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes]<3
                @battle.battlers[0].pbOwnSide.effects[PBEffects::Spikes]+=1
                spikevar=true
              end
              if @battle.battlers[1].pbOwnSide.effects[PBEffects::Spikes]<3
                @battle.battlers[1].pbOwnSide.effects[PBEffects::Spikes]+=1
                spikevar=true
              end
              if spikevar == true
                @battle.pbDisplay(_INTL("The quake broke up the ice into spiky pieces!"))
              end
            end
          end
          if (thismove.id == PBMoves::SCALD || thismove.id == PBMoves::STEAMERUPTION) # Icy Field => Water Surface
            @battle.field.counter += 1
            case @battle.field.counter
            when 1
              @battle.pbDisplay(_INTL("Parts of the ice melted!"))
            when 2
              @battle.setField(PBFields::WATERS)
              @battle.pbDisplay(_INTL("The hot water melted the ice!"))
            end
          end
        when PBFields::SUPERHEATEDF # Superheated Steam
          if (thismove.id == PBMoves::SURF || thismove.id == PBMoves::MUDDYWATER ||
           thismove.id == PBMoves::WATERPLEDGE || thismove.id == PBMoves::WATERSPOUT ||
           thismove.id == PBMoves::SPARKLINGARIA || thismove.id == PBMoves::OCEANICOPERETTA ||
           thismove.id == PBMoves::HYDROVORTEX)
            @battle.pbDisplay(_INTL("Steam shot up from the field!"))
            for i in 0...4
              canthit = PBStuff::TWOTURNMOVE.include?(@battle.battlers[i].effects[PBEffects::TwoTurnAttack])
              canthit = true if @battle.battlers[i].effects[PBEffects::SkyDrop]
              if !canthit && @battle.battlers[i].pbCanReduceStatStage?(PBStats::ACCURACY)
                @battle.battlers[i].pbReduceStat(PBStats::ACCURACY,1,abilitymessage:false)
              end
            end
          end
        when PBFields::ASHENB # Ashen Beach Ash
          if ((thismove.type == PBTypes::FLYING) && thismove.pbIsSpecial?(thismove.type)) || (thismove.id == PBMoves::LEAFTORNADO || thismove.id == PBMoves::FIRESPIN || thismove.id == PBMoves::TWISTER || thismove.id == PBMoves::RAZORWIND || thismove.id == PBMoves::WHIRLPOOL)
            @battle.pbDisplay(_INTL("The attack stirred up the ash on the ground!"))
            for i in 0...4
              canthit = PBStuff::TWOTURNMOVE.include?(@battle.battlers[i].effects[PBEffects::TwoTurnAttack])
              canthit = true if @battle.battlers[i].effects[PBEffects::SkyDrop]
              if !canthit && @battle.battlers[i].pbCanReduceStatStage?(PBStats::ACCURACY)
                @battle.battlers[i].pbReduceStat(PBStats::ACCURACY,1,abilitymessage:false)
              end
            end
          end
        when PBFields::UNDERWATER # Underwater -> Murkwater Surface
          if (thismove.id == PBMoves::SLUDGEWAVE)
            @battle.field.counter += 1
            case @battle.field.counter
              when 1
                @battle.pbDisplay(_INTL("Poison spread through the water!"))
              when 2
                @battle.pbDisplay(_INTL("The water was polluted!"))
                for i in 0...4
                  toxicdrown = @battle.battlers[i].totalhp
                  next if toxicdrown==0
                  toxicdrown =0 if PBStuff::TWOTURNMOVE.include?(@battle.battlers[i].effects[PBEffects::TwoTurnAttack])
                  toxicdrown =0 if @battle.battlers[i].pbHasType?(:POISON)
                  toxicdrown =0 if @battle.battlers[i].pbHasType?(:STEEL)
                  @battle.battlers[i].pbReduceHP(toxicdrown) if toxicdrown != 0
                  @battle.battlers[i].pbFaint if @battle.battlers[i].isFainted?
                  @battle.field.counter = 0
                end
                @battle.setField(PBFields::MURKWATERS)
                @battle.pbDisplay(_INTL("The grime sank beneath the battlers!"))
            end
          end
      end

      # Sheer Force affected items
      if !(user.hasWorkingAbility(:SHEERFORCE) && thismove.addlEffect>0)

        # Shell Bell
        if user.hasWorkingItem(:SHELLBELL) && flags[:totaldamage]>0 && @effects[PBEffects::HealBlock]==0
          hpgain = @battle.FE == PBFields::ASHENB ? flags[:totaldamage]/4.0 : flags[:totaldamage]/8.0
          hpgain=user.pbRecoverHP([hpgain.floor,1].max,true)
          if hpgain>0
            @battle.pbDisplay(_INTL("{1} restored a little HP using its Shell Bell!",user.pbThis))
          end
        end

        # Life Orb
        if user.hasWorkingItem(:LIFEORB) && flags[:totaldamage]>0 && !user.hasWorkingAbility(:MAGICGUARD)
          hploss=user.pbReduceHP([(user.totalhp/10.0).floor,1].max,true)
          if hploss>0
            @battle.pbDisplay(_INTL("{1} lost some of its HP!",user.pbThis))
          end
        end

        user.pbFaint if user.isFainted? # no return
      end

      # Dancer
      unless !thismove
        pbDancerMoveCheck(thismove.id) unless danced
      end
      if danced
        if user.effects[PBEffects::Outrage]>0
          user.effects[PBEffects::Outrage]=0
        end
      end
      # Switch moves
      for i in @battle.battlers
        if i.userSwitch == true
          i.userSwitch = false
          #remove gem when switching out before hitting pbEndTurn
          if i.takegem == true
            i.pbDisposeItem(false)
            i.takegem=false
          end
          @battle.pbDisplay(_INTL("{1} went back to {2}!",i.pbThis,@battle.pbGetOwner(i.index).name))
          newpoke=0
          newpoke=@battle.pbSwitchInBetween(i.index,true,false)
          @battle.pbMessagesOnReplace(i.index,newpoke)
          i.vanished=false
          i.pbResetForm
          @battle.pbReplace(i.index,newpoke,false)
          @battle.pbOnActiveOne(i)
          i.pbAbilitiesOnSwitchIn(true)
        end
        if i.forcedSwitch == true
          #remove gem when forced switching out mid attack
          if i.takegem == true
            i.pbDisposeItem(false)
            i.takegem=false
          end
          i.forcedSwitch = false
          party=@battle.pbParty(i.index)
          j=-1
          until j!=-1
            j=@battle.pbRandom(party.length)
            if !((i.isFainted? || j!=i.pokemonIndex) && (pbPartner.isFainted? || j!=i.pbPartner.pokemonIndex) && party[j] && !party[j].isEgg? && party[j].hp>0)
                j=-1
            end
            if !@battle.pbCanSwitchLax?(i.index,j,false)
              j=-1
            end
          end
          newpoke=j
          i.vanished=false
          i.pbResetForm
          @battle.pbReplace(i.index,newpoke,false)
          @battle.pbDisplay(_INTL("{1} was dragged out!",i.pbThis))
          @battle.pbOnActiveOne(i)
          i.pbAbilitiesOnSwitchIn(true)
          i.forcedSwitchEarlier = true
        end
      end
    end
    if selffaint
      user.ability = 0
    end
    @battle.fieldEffectAfterMove(thismove)
    if user.effects[PBEffects::LaserFocus]>0
      user.effects[PBEffects::LaserFocus]-=1
    end
    user.effects[PBEffects::Charge]-=1 if user.effects[PBEffects::Charge]>0 # Charge wearing off
    @battle.pbGainEXP
    # Battle Arena only - update skills
    for i in 0...4
      @battle.successStates[i].updateSkill
    end

    # Check if move order should be switched for shell trap

    # End of move usage
    pbEndTurn(choice)
    @battle.pbJudgeSwitch
    return
  end

  def pbCancelMoves
    # If failed pbTryUseMove or have already used Pursuit to chase a switching foe
    # Cancel multi-turn attacks (note: Hyper Beam effect is not canceled here)
    @effects[PBEffects::TwoTurnAttack]=0 if @effects[PBEffects::TwoTurnAttack]>0
    @effects[PBEffects::Outrage]=0
    @effects[PBEffects::Rollout]=0
    @effects[PBEffects::Uproar]=0
    @effects[PBEffects::Bide]=0
    @currentMove=0
    # Reset counters for moves which increase them when used in succession
    @effects[PBEffects::FuryCutter]=0
    @effects[PBEffects::EchoedVoice]=0
  end

################################################################################
# Field Handlers
################################################################################

  def ignitecheck
    return @battle.state.effects[PBEffects::WaterSport] <= 0 && @battle.pbWeather != PBWeather::RAINDANCE
  end

  def suncheck
    @battle.field.duration = @battle.weatherduration
  end

  def mistExplosion
    if !@battle.pbCheckGlobalAbility(:DAMP)
      pbDisplay(_INTL("The toxic mist combusted!"))
      for i in @battle.battlers
        #rewriting this for sanity purposes. "next if" implies combustdamage == 0
        combustdamage = i.totalhp
        for j in PBStuff::INVULEFFECTS
          combustdamage = 0 if i.effects[j]  == true
        end
        next if combustdamage == 0
        next if PBStuff::TWOTURNMOVE.include?(i.effects[PBEffects::TwoTurnAttack])
        next if i.pbOwnSide.effects[PBEffects::WideGuard]
        next if i.ability == PBAbilities::FLASHFIRE
        next if i.effects[PBEffects::SkyDrop]
        combustdamage -= 1 if i.effects[PBEffects::Endure] || i.ability == PBAbilities::STURDY
        i.pbReduceHP(combustdamage) if combustdamage != 0
        i.pbFaint if i.isFainted?
      end
      return true
    else
      @battle.pbDisplay(_INTL("A Pokémon's Damp ability prevented a complete explosion!"))
      return false
    end
  end

  def getSpecialStat(unaware=false, which_is_higher: false)
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
    spatkmult = 1
    spatkmult *= 1.5 if self.item == PBItems::CHOICESPECS
    spatkmult *= 2 if self.item == PBItems::DEEPSEATOOTH && self.pokemon.species == PBSpecies::CLAMPERL
    spatkmult *= 2 if self.item == PBItems::LIGHTBALL && self.pokemon.species == PBSpecies::PIKACHU
    spatkmult *= 1.5 if self.ability == PBAbilities::MINUS && self.pbPartner.ability == PBAbilities::PLUS
    spatkmult *= 1.5 if self.ability == PBAbilities::PLUS && self.pbPartner.ability == PBAbilities::MINUS
    spatkmult *= 1.5 if self.ability == PBAbilities::SOLARPOWER && @battle.pbWeather==PBWeather::SUNNYDAY
    spatkmult *= 1.3 if self.pbPartner.ability == PBAbilities::BATTERY
    spdefmult = 1
    spdefmult *= 1.5 if self.item == PBItems::ASSAULTVEST
    spdefmult *= 1.5 if self.item == PBItems::EVIOLITE && pbGetEvolvedFormData(self.pokemon.species).length>0
    spdefmult *= 1.5 if self.item == PBItems::EEVIUMZ2 && self.species == PBSpecies::EEVEE
    spdefmult *= 1.5 if self.item == PBItems::PIKANIUMZ2 && self.species == PBSpecies::PIKACHU
    spdefmult *= 1.5 if self.item == PBItems::LIGHTBALL && self.species == PBSpecies::PIKACHU
    spdefmult *= 2 if self.item == PBItems::DEEPSEASCALE && self.pokemon.species == PBSpecies::CLAMPERL
    spdefmult *= 1.5 if self.item == PBItems::METALPOWDER && self.pokemon.species == PBSpecies::DITTO && !self.effects[PBEffects::Transform]
    spdefmult *= 1.5 if self.ability == PBAbilities::FLOWERGIFT && @battle.pbWeather==PBWeather::SUNNYDAY
    spdefmult *= 1.5 if @battle.pbWeather==PBWeather::SANDSTORM &&pbHasType?(:ROCK)
    
    return [spatkmult*self.spatk,spdefmult*self.spdef].max if unaware
    
    spatk = self.spatk*stagemul[self.stages[PBStats::SPATK]+6]/stagediv[self.stages[PBStats::SPATK]+6]
    spdef = self.spdef*stagemul[self.stages[PBStats::SPDEF]+6]/stagediv[self.stages[PBStats::SPDEF]+6]
    
    #If we only want to know which stat is higher
    return PBStats::SPATK if spatkmult*spatk > spdefmult*spdef && which_is_higher
    return PBStats::SPDEF if which_is_higher

    return [spatkmult*spatk,spdefmult*spdef].max
  end

################################################################################
# Turn processing
################################################################################
  def pbBeginTurn(choice)
    # Cancel some lingering effects which only apply until the user next moves
    @effects[PBEffects::DestinyBond]=false
    @effects[PBEffects::Grudge]=false
    # Encore's effect ends if the encored move is no longer available
    if @effects[PBEffects::Encore]>0 &&
       @moves[@effects[PBEffects::EncoreIndex]].id!=@effects[PBEffects::EncoreMove]
      PBDebug.log("[Resetting Encore effect]") if $INTERNAL
      @effects[PBEffects::Encore]=0
      @effects[PBEffects::EncoreIndex]=0
      @effects[PBEffects::EncoreMove]=0
    end
    # Wake up in an uproar
    if self.status==PBStatuses::SLEEP && self.ability != PBAbilities::SOUNDPROOF
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          pbCureStatus(false)
          @battle.pbDisplay(_INTL("{1} woke up in the uproar!",pbThis))
        end
      end
    end
  end

  def pbEndTurn(choice)
    # True end(?)
    if @lastRegularMoveUsed
      if @effects[PBEffects::ChoiceBand]<0 && @lastRegularMoveUsed>=0 && !self.isFainted? && (self.hasWorkingItem(:CHOICEBAND) || self.hasWorkingItem(:CHOICESPECS) || self.hasWorkingItem(:CHOICESCARF) || self.ability == PBAbilities::GORILLATACTICS)
        @effects[PBEffects::ChoiceBand]=@lastRegularMoveUsed
      end
    end
    @selectedMove = nil
    @battle.synchronize[0]=-1
    @battle.synchronize[1]=-1
    @battle.synchronize[2]=0
    for i in 0...4
      @battle.battlers[i].pbAbilityCureCheck
      @battle.battlers[i].pbBerryCureCheck
      @battle.battlers[i].pbAbilitiesOnSwitchIn(false)
      @battle.battlers[i].pbCheckForm
      #End of turn ability nullification check
      if @battle.battlers[i].ability != @battle.battlers[i].backupability #Ability has changed
        if @battle.battlers[i].ability == 0   #Ability was nullified
          if @battle.battlers[i].abilityWorks?  #Revert ability if source is gone
            @battle.battlers[i].ability = @battle.battlers[i].backupability
          end
        else #Ability was changed (by mummy, receiver, etc)
          @battle.battlers[i].backupability = @battle.battlers[i].ability #No going back
        end
      end
    end
    #remove the gem if consumed this turn
    if self.takegem == true
      pbDisposeItem(false)
      self.takegem=false
    end

    self.missAcc = false
    for i in 0...4
      @battle.battlers[i].statLowered = false
      @battle.battlers[i].statdownanimplayed = false
      @battle.battlers[i].statupanimplayed = false
      @battle.battlers[i].statrepeat = false
    end
  end

  def pbProcessTurn(choice)
    # Can't use a move if fainted
    return if self.isFainted?
    # Wild roaming Pokémon always flee if possible
    if !@battle.opponent && @battle.pbIsOpposing?(self.index) && @battle.rules["alwaysflee"] && @battle.pbCanRun?(self.index) &&
         $PokemonTemp.roamerIndex && $game_variables[RoamingSpecies[$PokemonTemp.roamerIndex][:variable]]<=@battle.turncount
      pbBeginTurn(choice)
      pbSEPlay("escape",100)
      @battle.pbDisplay(_INTL("{1} fled!",self.pbThis))
      @battle.decision=3
      pbEndTurn(choice)
      return
    end
    # If this battler's action for this round wasn't "use a move"
    if choice[0]!=1
      # Clean up effects that end at battler's turn
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return
    end
    # Turn is skipped if Pursuit was used during switch
    if @effects[PBEffects::Pursuit]
      @effects[PBEffects::Pursuit]=false
      pbCancelMoves
      pbEndTurn(choice)
      @battle.pbJudgeSwitch
      return
    end
    # Use the move
    if choice[2].zmove && !@effects[PBEffects::Flinch] && (@status!=PBStatuses::SLEEP || choice[2].pbCanUseWhileAsleep? || @statusCount==1 || (@statusCount==2 && self.ability == PBAbilities::EARLYBIRD))
      if self.status==PBStatuses::SLEEP
        self.statusCount-=1
        self.statusCount-=1 if self.ability == PBAbilities::EARLYBIRD
        if self.statusCount<=0
          self.pbCureStatus
        end
      end
      if self.status==PBStatuses::FROZEN
        if @battle.pbRandom(10)<2
          self.pbCureStatus
          pbCheckForm
        else #failed while frozen
          self.pbContinueStatus
          choice[2].zmove=false
          @battle.previousMove = @battle.lastMoveUsed
          @previousMove = @lastMoveUsed
          pbBeginTurn(choice)
          pbCancelMoves
          @battle.pbGainEXP
          pbEndTurn(choice)
          @battle.pbJudgeSwitch
          return
        end
      end
      #choice[2].zmove=false
      @battle.lastMoveUsed = -1
      @lastMoveUsed = -1
      @battle.previousMove = @battle.lastMoveUsed
      @previousMove = @lastMoveUsed
      @battle.pbUseZMove(self.index,choice[2],self.item)
      choice[2].zmove = false
    else
      choice[2].zmove=false if choice[2].zmove # For flinches
      @battle.previousMove = @battle.lastMoveUsed
      @previousMove = @lastMoveUsed
      PBDebug.logonerr{
         pbUseMove(choice, {specialusage: choice[2]==@battle.struggle})
      }
      if !@battle.isOnline? #perry aimemory
        @battle.ai.addMoveToMemory(self,choice[2])
      end
    end
#   @battle.pbDisplayPaused("After: [#{@lastMoveUsedSketch},#{@lastMoveUsed}]")
  end

  def pbSwapDefenses
    @spdef, @defense = @defense, @spdef
    if @wonderroom
      @wonderroom = false
    else
      @wonderroom = true
    end
  end

end