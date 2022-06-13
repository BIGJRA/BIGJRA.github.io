class PokeBattle_Battler
  attr_reader :battle
  attr_reader :pokemon
  attr_reader :name
  attr_reader :index
  attr_accessor :pokemonIndex
  attr_reader :totalhp
  attr_accessor :fainted
  attr_reader :usingsubmove
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
  attr_accessor :aiMoveMemory
  #### KUROTSUNE - 010 - START
  attr_accessor :selectedMove
  #### KUROTSUNE - 010 - END
  #### KUROTSUNE - 014 - START
  attr_accessor :wonderroom
  #### KUROTSUNE - 014 - END
  attr_accessor :itemUsed
  attr_accessor :itemUsed2  #Stays while the battler is out
  attr_accessor :userSwitch 
  attr_accessor :forcedSwitch
  attr_accessor :forcedSwitchEarlier
  attr_accessor :vanished
  attr_accessor :custap  
  attr_accessor :moldbroken  
  attr_accessor :corroded
  attr_accessor :startform
  attr_accessor :sleeptalkUsed
  attr_accessor :missed
  attr_accessor :missAcc
  attr_accessor :statLowered
  attr_accessor :isBoss
  attr_accessor :hasmegad
  attr_accessor :abilitynulled 
  attr_accessor :passing 
  attr_accessor :obhp  
  attr_accessor :obatk
  attr_accessor :obdef 
  attr_accessor :obspe 
  attr_accessor :obspa 
  attr_accessor :obspd
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
  
  def isbossmon
    return (@pokemon) ? @pokemon.isbossmon : false
  end  
  
  def premega
    return (@pokemon) ? @pokemon.premega : false
  end  
  
  attr_reader :form
  
  def form=(value)
    @form=value
    @pokemon.form=value if @pokemon
  end
  
  def hasMega?
    if @pokemon
      return (@pokemon.hasMegaForm? rescue false)
    end
    return false
  end
  
  def pbZCrystalFromType(type)
    case type
    when 0
      crystal = (PBItems::NORMALIUMZ2)
    when 1
      crystal = (PBItems::FIGHTINIUMZ2)
    when 2
      crystal = (PBItems::FLYINIUMZ2)
    when 3
      crystal = (PBItems::POISONIUMZ2)
    when 4
      crystal = (PBItems::GROUNDIUMZ2)
    when 5
      crystal = (PBItems::ROCKIUMZ2)
    when 6
      crystal = (PBItems::BUGINIUMZ2)
    when 7
      crystal = (PBItems::GHOSTIUMZ2)
    when 8
      crystal = (PBItems::STEELIUMZ2)
    when 10
      crystal = (PBItems::FIRIUMZ2)
    when 11
      crystal = (PBItems::WATERIUMZ2)
    when 12
      crystal = (PBItems::GRASSIUMZ2)
    when 13
      crystal = (PBItems::ELECTRIUMZ2)
    when 14
      crystal = (PBItems::PSYCHIUMZ2)
    when 15
      crystal = (PBItems::ICIUMZ2)
    when 16
      crystal = (PBItems::DRAGONIUMZ2)
    when 17
      crystal = (PBItems::DARKINIUMZ2)
    when 18
      crystal = (PBItems::FAIRIUMZ2)
    end
    return crystal
  end

  def obhp
    return (@pokemon) ? @pokemon.obhp : 0
  end
  def obatk
    return (@pokemon) ? @pokemon.obatk : 0
  end
  def obdef
    return (@pokemon) ? @pokemon.obdef : 0
  end
  def obspe
    return (@pokemon) ? @pokemon.obspe: 0
  end
  def obspa
    return (@pokemon) ? @pokemon.obspa : 0
  end
  def obspd
    return (@pokemon) ? @pokemon.obspd : 0
  end

  def hasZMove?
    pkmn=self
    canuse=false
    case pkmn.item
    when (PBItems::NORMALIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 0}
    when (PBItems::FIGHTINIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 1}
    when (PBItems::FLYINIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 2}
    when (PBItems::POISONIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 3}
    when (PBItems::GROUNDIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 4}
    when (PBItems::ROCKIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 5}
    when (PBItems::BUGINIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 6}
    when (PBItems::GHOSTIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 7}
    when (PBItems::STEELIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 8}
    when (PBItems::FIRIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 10}
    when (PBItems::WATERIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 11}
    when (PBItems::GRASSIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 12}
    when (PBItems::ELECTRIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 13}
    when (PBItems::PSYCHIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 14}
    when (PBItems::ICIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 15}
    when (PBItems::DRAGONIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 16}
    when (PBItems::DARKINIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 17}
    when (PBItems::FAIRIUMZ2)
      canuse=pkmn.moves.any?{|stuffthings| stuffthings.type == 18}
    when (PBItems::ALORAICHIUMZ2)
      if pkmn.pokemon.species==26 && pkmn.form==1
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::THUNDERBOLT}
      end
    when (PBItems::DECIDIUMZ2)
      if pkmn.pokemon.species==724
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::SPIRITSHACKLE}
      end
    when (PBItems::INCINIUMZ2)
      if pkmn.pokemon.species==727
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::DARKESTLARIAT}
      end
    when (PBItems::PRIMARIUMZ2)
      if pkmn.pokemon.species==730
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::SPARKLINGARIA}
      end
    when (PBItems::EEVIUMZ2)
      if pkmn.pokemon.species==133
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::LASTRESORT}
      end
    when (PBItems::PIKANIUMZ2)
      if pkmn.pokemon.species==25
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::VOLTTACKLE}
      end
    when (PBItems::SNORLIUMZ2)
      if pkmn.pokemon.species==143
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::GIGAIMPACT}
      end
    when (PBItems::MEWNIUMZ2)
      if pkmn.pokemon.species==151
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::PSYCHIC}
      end
    when (PBItems::TAPUNIUMZ2)
      if pokemon.species==785 || pokemon.species==786 || pokemon.species==787 || pokemon.species==788
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::NATURESMADNESS}
      end
    when (PBItems::MARSHADIUMZ2)
      if pkmn.pokemon.species==802
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::SPECTRALTHIEF}
      end
    when (PBItems::KOMMONIUMZ2)
      if pkmn.pokemon.species==784
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::CLANGINGSCALES}
      end
    when (PBItems::LYCANIUMZ2)
      if pkmn.pokemon.species==745
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::STONEEDGE}
      end
    when (PBItems::MIMIKIUMZ2)
      if pkmn.pokemon.species==778
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::PLAYROUGH}
      end
    when (PBItems::SOLGANIUMZ2)
      if (pkmn.pokemon.species==800 && pkmn.form==1) || pkmn.pokemon.species==791
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::SUNSTEELSTRIKE}
      end
    when (PBItems::LUNALIUMZ2)
      if (pkmn.pokemon.species==800 && pkmn.form==2) || pkmn.pokemon.species==792
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::MOONGEISTBEAM}
      end
    when (PBItems::ULTRANECROZIUMZ2)
      if pkmn.pokemon.species==800 && pkmn.form==3
         canuse=pkmn.moves.any?{|stuffthings| stuffthings.id == PBMoves::PHOTONGEYSER}
      end
    when (PBItems::INTERCEPTZ2)
      if $game_variables[646]>=95 && $game_variables[646]<100
        canuse=true
      end
    end
    return canuse
  end

  def pbCompatibleZMoveFromMove?(move)
    pkmn=self
    case pkmn.item
    when PBItems::NORMALIUMZ2
        return true if move.type==0
    when PBItems::FIGHTINIUMZ2
        return true if move.type==1
    when PBItems::FLYINIUMZ2
        return true if move.type==2
    when PBItems::POISONIUMZ2
        return true if move.type==3
    when PBItems::GROUNDIUMZ2
        return true if move.type==4
    when PBItems::ROCKIUMZ2
        return true if move.type==5
    when PBItems::BUGINIUMZ2
        return true if move.type==6
    when PBItems::GHOSTIUMZ2
        return true if move.type==7
    when PBItems::STEELIUMZ2
        return true if move.type==8
    when PBItems::FIRIUMZ2
        return true if move.type==10
    when PBItems::WATERIUMZ2
        return true if move.type==11
    when PBItems::GRASSIUMZ2
        return true if move.type==12
    when PBItems::ELECTRIUMZ2
        return true if move.type==13
    when PBItems::PSYCHIUMZ2
        return true if move.type==14
    when PBItems::ICIUMZ2
        return true if move.type==15
    when PBItems::DRAGONIUMZ2
        return true if move.type==16
    when PBItems::DARKINIUMZ2
        return true if move.type==17
    when PBItems::FAIRIUMZ2
        return true if move.type==18
    when PBItems::ALORAICHIUMZ2
        return true if move.id==(PBMoves::THUNDERBOLT)
    when PBItems::DECIDIUMZ2
        return true if move.id==(PBMoves::SPIRITSHACKLE)
    when PBItems::INCINIUMZ2
        return true if move.id==(PBMoves::DARKESTLARIAT)
    when PBItems::PRIMARIUMZ2
        return true if move.id==(PBMoves::SPARKLINGARIA)
    when PBItems::EEVIUMZ2
        return true if move.id==(PBMoves::LASTRESORT)
    when PBItems::PIKANIUMZ2
        return true if move.id==(PBMoves::VOLTTACKLE)
    when PBItems::SNORLIUMZ2
        return true if move.id==(PBMoves::GIGAIMPACT)
    when PBItems::MEWNIUMZ2
        return true if move.id==(PBMoves::PSYCHIC)
    when PBItems::TAPUNIUMZ2
        return true if move.id==(PBMoves::NATURESMADNESS)
    when PBItems::MARSHADIUMZ2
        return true if move.id==(PBMoves::SPECTRALTHIEF)
    when PBItems::KOMMONIUMZ2
        return true if move.id==(PBMoves::CLANGINGSCALES)
    when PBItems::LYCANIUMZ2
        return true if move.id==(PBMoves::STONEEDGE)
    when PBItems::MIMIKIUMZ2
        return true if move.id==(PBMoves::PLAYROUGH)
    when PBItems::SOLGANIUMZ2
        return true if move.id==(PBMoves::SUNSTEELSTRIKE)
    when PBItems::LUNALIUMZ2
        return true if move.id==(PBMoves::MOONGEISTBEAM)
    when PBItems::ULTRANECROZIUMZ2
        return true if move.id==(PBMoves::PHOTONGEYSER)
    when PBItems::INTERCEPTZ2
        return true
    end
    return false
  end

  def pbCompatibleZMoveFromIndex?(moveindex)
    pkmn=self
    case pkmn.item
    when PBItems::NORMALIUMZ2
        return true if pkmn.moves[moveindex].type==0
    when PBItems::FIGHTINIUMZ2
        return true if pkmn.moves[moveindex].type==1
    when PBItems::FLYINIUMZ2
        return true if pkmn.moves[moveindex].type==2
    when PBItems::POISONIUMZ2
        return true if pkmn.moves[moveindex].type==3
    when PBItems::GROUNDIUMZ2
        return true if pkmn.moves[moveindex].type==4
    when PBItems::ROCKIUMZ2
        return true if pkmn.moves[moveindex].type==5
    when PBItems::BUGINIUMZ2
        return true if pkmn.moves[moveindex].type==6
    when PBItems::GHOSTIUMZ2
        return true if pkmn.moves[moveindex].type==7
    when PBItems::STEELIUMZ2
        return true if pkmn.moves[moveindex].type==8
    when PBItems::FIRIUMZ2
        return true if pkmn.moves[moveindex].type==10
    when PBItems::WATERIUMZ2
        return true if pkmn.moves[moveindex].type==11
    when PBItems::GRASSIUMZ2
        return true if pkmn.moves[moveindex].type==12
    when PBItems::ELECTRIUMZ2
        return true if pkmn.moves[moveindex].type==13
    when PBItems::PSYCHIUMZ2
        return true if pkmn.moves[moveindex].type==14
    when PBItems::ICIUMZ2
        return true if pkmn.moves[moveindex].type==15
    when PBItems::DRAGONIUMZ2
        return true if pkmn.moves[moveindex].type==16
    when PBItems::DARKINIUMZ2
        return true if pkmn.moves[moveindex].type==17
    when PBItems::FAIRIUMZ2
        return true if pkmn.moves[moveindex].type==18
    when PBItems::ALORAICHIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::THUNDERBOLT)
    when PBItems::DECIDIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::SPIRITSHACKLE)
    when PBItems::INCINIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::DARKESTLARIAT)
    when PBItems::PRIMARIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::SPARKLINGARIA)
    when PBItems::EEVIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::LASTRESORT)
    when PBItems::PIKANIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::VOLTTACKLE)
    when PBItems::SNORLIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::GIGAIMPACT)
    when PBItems::MEWNIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::PSYCHIC)
    when PBItems::TAPUNIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::NATURESMADNESS)
    when PBItems::MARSHADIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::SPECTRALTHIEF)
    when PBItems::KOMMONIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::CLANGINGSCALES)
    when PBItems::LYCANIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::STONEEDGE)
    when PBItems::MIMIKIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::PLAYROUGH)
    when PBItems::SOLGANIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::SUNSTEELSTRIKE)
    when PBItems::LUNALIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::MOONGEISTBEAM)
    when PBItems::ULTRANECROZIUMZ2
        return true if pkmn.moves[moveindex].id==(PBMoves::PHOTONGEYSER)
    when PBItems::INTERCEPTZ2
        return true
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
  
  def hasCrest?
    if isConst?(self.species,PBSpecies,:MAGCARGO) &&
      isConst?(self.item,PBItems,:MAGCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:FEAROW) &&
      isConst?(self.item,PBItems,:FEARCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:STANTLER) &&
      isConst?(self.item,PBItems,:STANTCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:HYPNO) &&
      isConst?(self.item,PBItems,:HYPCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:GLACEON) &&
      isConst?(self.item,PBItems,:GLACCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:LEAFEON) &&
      isConst?(self.item,PBItems,:LEAFCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:RELICANTH) &&
      isConst?(self.item,PBItems,:RELICREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:ORICORIO) &&
      isConst?(self.item,PBItems,:ORICREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:SEVIPER) &&
      isConst?(self.item,PBItems,:SEVCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:COFAGRIGUS) &&
      isConst?(self.item,PBItems,:COFCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:DUSKNOIR) &&
      isConst?(self.item,PBItems,:DUSKCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:SKUNTANK) &&
      isConst?(self.item,PBItems,:SKUNCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:DARMANITAN) &&
      isConst?(self.item,PBItems,:DARMCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:CHERRIM) &&
      isConst?(self.item,PBItems,:CHERCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:CLAYDOL) &&
      isConst?(self.item,PBItems,:CLAYCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:DEDENNE) &&
      isConst?(self.item,PBItems,:DEDECREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:ZANGOOSE) &&
      isConst?(self.item,PBItems,:ZANGCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:BASTIODON) &&
      isConst?(self.item,PBItems,:BASTCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:MEGANIUM) &&
      isConst?(self.item,PBItems,:MEGCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:TYPHLOSION) &&
      isConst?(self.item,PBItems,:TYPHCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:FERALIGATR) &&
      isConst?(self.item,PBItems,:FERACREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:RAMPARDOS) &&
      isConst?(self.item,PBItems,:RAMPCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:LEDIAN) &&
      isConst?(self.item,PBItems,:LEDICREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:ARIADOS) &&
      isConst?(self.item,PBItems,:ARIACREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:SPIRITOMB) &&
      isConst?(self.item,PBItems,:SPIRITCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:WHISCASH) &&
      isConst?(self.item,PBItems,:WHISCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:BEHEEYEM) &&
      isConst?(self.item,PBItems,:BEHECREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:TORTERRA) &&
      isConst?(self.item,PBItems,:TORCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:INFERNAPE) &&
      isConst?(self.item,PBItems,:INFCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:EMPOLEON) &&
      isConst?(self.item,PBItems,:EMPCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:CRYOGONAL) &&
      isConst?(self.item,PBItems,:CRYCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:CASTFORM) &&
      isConst?(self.item,PBItems,:CASTCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:THIEVUL) &&
      isConst?(self.item,PBItems,:THIEVCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:LUXRAY) &&
      isConst?(self.item,PBItems,:LUXCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:SAMUROTT) &&
      isConst?(self.item,PBItems,:SAMUCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:PHIONE) &&
      isConst?(self.item,PBItems,:PHIONECREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:BOLTUND) &&
      isConst?(self.item,PBItems,:BOLTCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:NOCTOWL) &&
      isConst?(self.item,PBItems,:NOCCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:VESPIQUEN) &&
      isConst?(self.item,PBItems,:VESPICREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:DRUDDIGON) &&
      isConst?(self.item,PBItems,:DRUDDICREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:CINCCINO) &&
      isConst?(self.item,PBItems,:CINCCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:PROBOPASS) &&
      isConst?(self.item,PBItems,:PROBOCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:DELCATTY) &&
      isConst?(self.item,PBItems,:DELCREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:SWALOT) &&
      isConst?(self.item,PBItems,:SWACREST)
      return true
    end
    if isConst?(self.species,PBSpecies,:SILVALLY) 
      if ((@battle.pbOwnedByPlayer?(self.index) && $PokemonBag.pbHasItem?(:SILVCREST)))
        return true
      end
      if (!@battle.pbOwnedByPlayer?(self.index))   
        return true
      end
    end
    return false
  end
  
  
  attr_reader :level
  
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
  attr_reader :critted
  
  def critted=(value)
    @critted=value
    @pokemon.critted=value if @pokemon
  end

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
      if isConst?(@ability, PBAbilities, :UNBURDEN) && !@unburdened
        @unburdened = true
      end
    end
    # end update
    @item=value
    @pokemon.item=value if @pokemon
  end
  
  def weight
    w=(@pokemon) ? @pokemon.weight : 500
    w*=2 if self.hasWorkingAbility(:HEAVYMETAL) && !(self.moldbroken)
    w/=2 if self.hasWorkingAbility(:LIGHTMETAL) && !(self.moldbroken)
    w/=2 if self.hasWorkingItem(:FLOATSTONE)
    w*=@effects[PBEffects::WeightMultiplier]
    w=1 if w<1
    return w
  end
  
  def owned(form=0)
    if form==0
      return (@pokemon) ? $Trainer.owned[@pokemon.species] && !@battle.opponent : false
    else
      return (@pokemon) ? $Trainer.owned[@pokemon.species] && !@battle.opponent && @pokemon.form==form : false
    end
  end
  
  ################################################################################
  # Creating a battler
  ################################################################################
  def initialize(btl,index)
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
    @vanished     = false
    @passing      = false
    @custap       = false
    @moldbroken   = false
    @corroded     = false
    @abilitynulled = false
    @critted      = false
    @sleeptalk    = false
    @missed       = true
    @missAcc      = false
    @statLowered  = false
    @isBoss       = (($game_switches[1305] || $game_switches[1500]) && @battle.pbIsOpposing?(@index))
    @hasmegad     = false
    pbInitBlank
    pbInitEffects(false,true,true)
    pbInitPermanentEffects
  end
  
  def pbInitPokemon(pkmn,pkmnIndex,wonderroom=false)
    @name         = pkmn.name
    @species      = pkmn.species
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @gender       = pkmn.gender
    @ability      = pkmn.ability
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @form         = pkmn.form
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @speed        = pkmn.speed
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    if wonderroom
      aux=pkmn.spdef
      @spdef=pkmn.defense
      @defense = aux
    end
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
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
    @missed       = true
    @missAcc      = false
    @statLowered  = false
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
    @status       = 0
    @statusCount  = 0
    @pokemon      = nil
    @pokemonIndex = -1
    @participants = []
    @moves        = [nil,nil,nil,nil]
    @iv           = [0,0,0,0,0,0]
    @item         = 0
    @weight       = nil
    @missed       = true
    @missAcc      = false
    @statLowered  = false
  end
  
  def pbInitPermanentEffects
    # These effects are always retained even if a Pokémon is replaced
    @effects[PBEffects::FutureSight]       = 0
    @effects[PBEffects::FutureSightDamage] = 0
    @effects[PBEffects::FutureSightMove]   = 0
    @effects[PBEffects::FutureSightUser]   = -1
    @effects[PBEffects::HealingWish]       = false
    @effects[PBEffects::LunarDance]        = false    
    @effects[PBEffects::Wish]              = 0
    @effects[PBEffects::WishAmount]        = 0
    @effects[PBEffects::WishMaker]         = -1
    @effects[PBEffects::ZHeal]             = false
    @effects[PBEffects::Blazed]            = false
    @effects[PBEffects::Savagery]          = 0
    @effects[PBEffects::RampCrestUsage]    = false
  end
  
  def pbInitEffects(batonpass,illusion=true,effectnegate=false)
    if !batonpass
      # These effects are retained if Baton Pass is used
      @stages[PBStats::ATTACK]   = 0
      @stages[PBStats::DEFENSE]  = 0
      @stages[PBStats::SPEED]    = 0
      @stages[PBStats::SPATK]    = 0
      @stages[PBStats::SPDEF]    = 0
      @stages[PBStats::EVASION]  = 0
      @stages[PBStats::ACCURACY] = 0
      @lastMoveUsedSketch        = -1
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
      @effects[PBEffects::Petrification]   = -1
      @effects[PBEffects::LockOn]      = 0
      @effects[PBEffects::LockOnPos]   = -1
      if !effectnegate
        for i in 0...4
          next if !@battle.battlers[i]
          next if @battle.battlers[i].effects[PBEffects::LockOn]!=0
          if @battle.battlers[i].effects[PBEffects::LockOnPos]==@index &&
            @battle.battlers[i].effects[PBEffects::LockOn]>0
            @battle.battlers[i].effects[PBEffects::LockOn]=0
            @battle.battlers[i].effects[PBEffects::LockOnPos]=-1
          end
        end
      end
      @effects[PBEffects::MagnetRise]         = 0
      @effects[PBEffects::PerishSong]         = 0
      @effects[PBEffects::PerishSongUser]     = -1
      @effects[PBEffects::PowerTrick]         = false
      @effects[PBEffects::Substitute]         = 0
      @effects[PBEffects::Telekinesis]        = 0
    else
      if @effects[PBEffects::LockOn]>0
        @effects[PBEffects::LockOn]=2
      else
        @effects[PBEffects::LockOn]=0
      end
      #      if @effects[PBEffects::PowerTrick]
      #        s=@attack
      #        @attack=@defense
      #        @defense=a
      #      end
    end
    @damagestate.reset
    @fainted        = false
    @lastAttacker   = -1
    @lastHPLost     = 0
    @lastMoveUsed   = -1
    @lastRoundMoved = -1
    @itemUsed       = false
    @itemUsed2      = false
    @movesUsed      = []
    @turncount      = 0
    @effects[PBEffects::Attract]          = -1
    if !effectnegate
      for i in 0...4
        next if !@battle.battlers[i]
        if @battle.battlers[i].effects[PBEffects::Attract]==@index
          @battle.battlers[i].effects[PBEffects::Attract]=-1
        end
      end
    end
    @effects[PBEffects::Bide]             = 0
    @effects[PBEffects::BideDamage]       = 0
    @effects[PBEffects::BideTarget]       = -1
    @effects[PBEffects::Charge]           = 0
    @effects[PBEffects::WillMega]         = false
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
    @effects[PBEffects::Disguise]         = false 
    @effects[PBEffects::IceFace]          = false 
    @effects[PBEffects::Disguise]         = true if self.species==778 && self.form==0 # Mimikyu
    @effects[PBEffects::IceFace]          = true if self.species==875 && self.form==0 # Eiscue
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
    if !effectnegate
      for i in 0...4
        next if !@battle.battlers[i]
        if @battle.battlers[i].effects[PBEffects::MeanLook]==@index
          @battle.battlers[i].effects[PBEffects::MeanLook]=-1
        end
      end
    end
    @effects[PBEffects::Metronome]        = 0
    @effects[PBEffects::Minimize]         = false
    @effects[PBEffects::MiracleEye]       = false
    @effects[PBEffects::MirrorCoat]       = -1
    @effects[PBEffects::MirrorCoatTarget] = -1
    #    @effects[PBEffects::MudSport]         = false
    @effects[PBEffects::MultiTurn]        = 0
    @effects[PBEffects::MultiTurnAttack]  = 0
    @effects[PBEffects::MultiTurnUser]    = -1
    if !effectnegate
      for i in 0...4
        next if !@battle.battlers[i]
        #next if @battle.battlers[i].effects[PBEffects::MultiTurn]!=0 #&& @battle.battlers[i].effects[PBEffects::MultiTurnUser]==@index
        if @battle.battlers[i].effects[PBEffects::MultiTurnUser]==@index
          @battle.battlers[i].effects[PBEffects::MultiTurn]=0
          @battle.battlers[i].effects[PBEffects::MultiTurnUser]=-1
        end
      end
    end
    @effects[PBEffects::Nightmare]        = false
    @effects[PBEffects::Outrage]          = 0
    @effects[PBEffects::Octolock]         = false
    @effects[PBEffects::Pinch]            = false
    @effects[PBEffects::Protect]          = false
    @effects[PBEffects::KingsShield]      = false # add this line
    @effects[PBEffects::SpikyShield]      = false # and this one
    @effects[PBEffects::WideGuardCheck]   = false 
    @effects[PBEffects::WideGuardUser]    = false    
    @effects[PBEffects::BanefulBunker]    = false
    @effects[PBEffects::ProtectNegation]  = false
    @effects[PBEffects::ProtectRate]      = 1
    @effects[PBEffects::DestinyRate]      = 1
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
    @effects[PBEffects::TarShot]          = false
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
    @effects[PBEffects::Attacking]        = false
    @effects[PBEffects::AttackingTarget]  = []
    @effects[PBEffects::FeverPitch]       = false    
    @effects[PBEffects::UsingSubstituteRightNow] = false
    #   @effects[PBEffects::WaterSport]       = false
    @effects[PBEffects::WeightMultiplier] = 1.0
    @effects[PBEffects::Yawn]             = 0
    @effects[PBEffects::BeakBlast]        = false
    @effects[PBEffects::BurnUp]           = false
    @effects[PBEffects::ClangedScales]    = false
    @effects[PBEffects::ShellTrap]        = false
    @effects[PBEffects::SpeedSwap]        = 0
    @effects[PBEffects::Tantrum]          = false
    @effects[PBEffects::ThroatChop]      = 0
    @effects[PBEffects::ShieldLife]      = 0
    #### JERICHO - 001 - START
    if illusion==true
      if isConst?(self.ability,PBAbilities,:ILLUSION) #Illusion
        party=@battle.pbParty(@index)
        party=party.find_all {|item| item && !item.egg? && item.hp>0 }
        if party[party.length-1] != @pokemon
          @effects[PBEffects::Illusion] = party[party.length-1]
        end
      end
    end #Illusion
    #### JERICHO - 001 - END    
    #### KUROTSUNE - 004 - START
    @effects[PBEffects::ParentalBond]     = false
    #### KUROTSUNE - 004 - END
    #### KUROTSUNE - 010 - START
    @effects[PBEffects::Round]            = false
    #### KUROTSUNE - 010 - END
    #### KUROTSUNE - 024 - START
    @effects[PBEffects::Powder]           = false
    #### KUROTSUNE - 023 - END
    #### KUROTSUNE - 024 - START
    @effects[PBEffects::Electrify]        = false
    #### KUROTSUNE - 024 - END
    #### KUROTSUNE - 032 - START
    @effects[PBEffects::MeFirst]          = false
    #### KUROTSUNE - 032 - END
    @effects[PBEffects::TyphBond]         = false
    @effects[PBEffects::Switching]         = false
    @effects[PBEffects::SwitchingTo]      = nil
    @effects[PBEffects::SomethingCrazy]      = nil
    @effects[PBEffects::Switched]         = false
    @effects[PBEffects::VoreCopy]         = false
    @effects[PBEffects::NoRetreat]        = false
    @effects[PBEffects::BallFetch]        = 0
    @effects[PBEffects::ThunderRaidHit]   = 0
    @effects[PBEffects::ThunderRaidStat]  = [0,0,0,0,0]
    @effects[PBEffects::KinesisBoost]     = false  
    @effects[PBEffects::TarShot]          = false  
    @effects[PBEffects::CritCount]        = 0  
    @effects[PBEffects::SusCrit]          = false  
    @effects[PBEffects::Obstruct]         = false
    @effects[PBEffects::VespiCrest]       = -1
    @effects[PBEffects::DesertsMark]      = false
    @effects[PBEffects::UsingItem]      = []
    @effects[PBEffects::WorldOfNightmares]= 0
  end
  
  def pbUpdate(fullchange=false,wonderroom=false)
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
        if wonderroom
          aux = @pokemon.spdef
          @spdef = @pokemon.defense
          @defense = aux
        end
        if fullchange
          @ability = @pokemon.ability
          @type1   = @pokemon.type1
          @type2   = @pokemon.type2
        end
      end
    end
  end
  
  def pbInitialize(pkmn,index,batonpass)
    # Cure status of previous Pokemon with Natural Cure
    if self.hasWorkingAbility(:NATURALCURE) || (self.hasWorkingAbility(:TRACE) &&
        self.effects[PBEffects::TracedAbility]==30) && @pokemon
      self.status=0
    end
    if self.hasWorkingAbility(:REGENERATOR) || @battle.SilvallyCheck(self, "poison") || 
      (self.hasWorkingAbility(:TRACE) && self.effects[PBEffects::TracedAbility]==144) && 
      @pokemon
      self.pbRecoverHP((totalhp/3).floor)
    end
    pbInitPokemon(pkmn,index)
    pbInitEffects(batonpass)
    if self.isbossmon 
      self.isBoss=true
      @battle.shieldCount = $game_variables[704]
      shieldlife=[(self.totalhp/4).floor,1].max
      self.effects[PBEffects::ShieldLife]=shieldlife
    end
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
        @participants[@participants.length]=pbOpposing1.pokemonIndex
      end
      if !found2 && !pbOpposing2.isFainted?
        @participants[@participants.length]=pbOpposing2.pokemonIndex
      end
    end
  end
  
  ################################################################################
  # About this battler
  ################################################################################
  #### JERICHO - 001 - START  
  def pbThis(lowercase=false)
    if @battle.pbIsOpposing?(@index)
      if @battle.opponent && !@battle.battlers[@index].isBoss
        return lowercase ? _INTL("the foe {1}",self.name) : _INTL("The foe {1}",self.name)
      elsif @battle.battlers[@index].isBoss
        return lowercase ? _INTL("{1}",self.name) : _INTL("{1}",self.name)
      else
        return lowercase ? _INTL("the wild {1}",self.name) : _INTL("The wild {1}",self.name)
      end
    elsif @battle.pbOwnedByPlayer?(@index)
      return _INTL("{1}",self.name)
    else
      return lowercase ? _INTL("the ally {1}",self.name) : _INTL("The ally {1}",self.name)
    end
  end
  
  def name #Illusion
    return @effects[PBEffects::Illusion] != nil  ? @effects[PBEffects::Illusion].name : @name
  end #Illusion
  #### JERICHO - 001 - END  
  
  def species #Illusion
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
      id=getID(PBMoves,id)
    end
    return false if !id || id==0
    for i in @moves
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
    if @battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)
      return false 
    end
    return true
  end
  
  def hasWorkingAbility(ability,ignorefainted=false)
    return false if self.isFainted? if !ignorefainted
    if !((ability == :NEUTRALIZINGGAS) || ability == :STANCECHANGE || ability == :SCHOOLING)
      if @battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)
        return false 
      end
    end
    return false if @effects[PBEffects::GastroAcid]
    return isConst?(@ability,PBAbilities,ability)
  end
  
  def itemWorks?(ignorefainted=false)
    return false if self.isFainted? if !ignorefainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.field.effects[PBEffects::MagicRoom]>0
    return false if self.ability == PBAbilities::KLUTZ && !self.abilitynulled
    return true
  end
  
  def hasWorkingItem(item,ignorefainted=false)
    return false if self.isFainted? if !ignorefainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.field.effects[PBEffects::MagicRoom]>0
    return false if self.ability == PBAbilities::KLUTZ && !self.abilitynulled
    return isConst?(@item,PBItems,item)
  end
  
  def isAirborne?
    return false if self.hasWorkingItem(:IRONBALL)
    return false if @effects[PBEffects::Ingrain]
    return false if @effects[PBEffects::DesertsMark]
    return false if @effects[PBEffects::SmackDown]
    return false if @battle.field.effects[PBEffects::Gravity]>0
    return true if self.pbHasType?(:FLYING) && @effects[PBEffects::Roost]==false
    return true if self.hasWorkingAbility(:LEVITATE)
    return true if (self.hasWorkingAbility(:SOLARIDOL) || self.hasWorkingAbility(:LUNARIDOL))
    return true if self.hasWorkingItem(:AIRBALLOON)
    return true if @effects[PBEffects::MagnetRise]>0
    return true if @effects[PBEffects::Telekinesis]>0
    return false
  end
  
  #>>>>DemICE entered the chat
  def pbCalcAttack()
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]    
    atk=@attack
    atkstage=@stages[PBStats::ATTACK]+6
    if @effects[PBEffects::PowerTrick]
      atk=@defense
      atkstage=@stages[PBStats::DEFENSE]+6
    end    
    if @stages[PBStats::ATTACK] >= 0
      stagemulp=1+0.5*@stages[PBStats::ATTACK]
      atk=(atk*1.0*stagemulp).floor  
    else        
      atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
    end  
    if self.hasWorkingAbility(:HUSTLE)
      atk=(atk*1.5).round
    end
    if self.hasWorkingItem(:LIGHTBALL) && isConst?(self.species,PBSpecies,:PIKACHU)
      atk=self.pbSpeed
    end
    atkmult=0x1000           
    if self.hasWorkingAbility(:GUTS) &&
      self.status!=0 
      atkmult=(atkmult*1.5).round
    end   
    if self.hasWorkingAbility(:DEFEATIST) &&
      self.hp<=(self.totalhp/2).floor
      atkmult=(atkmult*0.5).round
    end
    if ((self.hasWorkingAbility(:PUREPOWER) && $fefieldeffect!=37) ||
        self.hasWorkingAbility(:HUGEPOWER))
      atkmult=(atkmult*2.0).round
    end  
    if self.hasWorkingAbility(:SLOWSTART) &&
      self.turncount<5 
      atkmult=(atkmult*0.5).round
    end
    if (@battle.pbWeather==PBWeather::SUNNYDAY || $fefieldeffect == 33 || $fefieldeffect == 42 || 
        (self.hasWorkingItem(:CHERCREST) && isConst?(self.species,PBSpecies,:CHERRIM)) || 
        (self.pbPartner.hasWorkingItem(:CHERCREST) && isConst?(self.pbPartner.species,PBSpecies,:CHERRIM)) )
      if self.hasWorkingAbility(:FLOWERGIFT) &&
        isConst?(self.species,PBSpecies,:CHERRIM)
        atkmult=(atkmult*1.5).round
      end
      if self.pbPartner.hasWorkingAbility(:FLOWERGIFT)  &&
        isConst?(self.pbPartner.species,PBSpecies,:CHERRIM)
        atkmult=(atkmult*1.5).round
      end
    end
    if self.hasWorkingItem(:THICKCLUB) &&
      (isConst?(self.species,PBSpecies,:CUBONE) ||
        isConst?(self.species,PBSpecies,:MAROWAK))
      atkmult=(atkmult*2.0).round
    end
    if self.hasWorkingItem(:LIGHTBALL) &&
      isConst?(self.species,PBSpecies,:PIKACHU)
      atkmult=(atkmult*2.0).round
    end
    if self.hasWorkingItem(:CHOICEBAND)
      atkmult=(atkmult*1.5).round
    end 
    if self.hasWorkingAbility(:QUEENLYMAJESTY) &&
      ($fefieldeffect==5 || $fefieldeffect==31)
      atkmult=(atkmult*1.5).round
    end 
    if self.hasWorkingAbility(:LONGREACH) &&
      ($fefieldeffect==27 || $fefieldeffect==28)
      atkmult=(atkmult*1.5).round
    end     
    if self.hasWorkingAbility(:CORROSION) &&
      ($fefieldeffect==10 || $fefieldeffect==11 ||  $fefieldeffect==41)
      atkmult=(atkmult*1.5).round
    end     
    atk=(atk*atkmult*1.0/0x1000).round
    return atk
  end
  
  def pbCalcSpAtk()
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]    
    atk=@spatk
    atkstage=@stages[PBStats::SPATK]+6
    if @stages[PBStats::SPATK] >= 0
      stagemulp=1+0.5*@stages[PBStats::SPATK]
      atk=(atk*1.0*stagemulp).floor  
    else        
      atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
    end  
    atkmult=0x1000
    if (self.hasWorkingAbility(:PLUS) || self.hasWorkingAbility(:MINUS))
      partner=self.pbPartner
      if partner.hasWorkingAbility(:PLUS) || partner.hasWorkingAbility(:MINUS) 
        atkmult=(atkmult*1.5).round
      elsif $fefieldeffect == 18
        atkmult=(atkmult*1.5).round
      end
    end
    if (self.pbPartner).hasWorkingAbility(:BATTERY)
      atkmult=(atkmult*1.3).round
    end    
    if self.hasWorkingAbility(:DEFEATIST) &&
      self.hp<=(self.totalhp/2).floor
      atkmult=(atkmult*0.5).round
    end
    if self.hasWorkingAbility(:PUREPOWER) && $fefieldeffect==37
      atkmult=(atkmult*2.0).round
    end    
    if self.hasWorkingAbility(:SOLARPOWER) &&
      @battle.pbWeather==PBWeather::SUNNYDAY
      atkmult=(atkmult*1.5).round
    end
    if self.hasWorkingItem(:DEEPSEATOOTH) &&
      isConst?(self.species,PBSpecies,:CLAMPERL)
      atkmult=(atkmult*2.0).round
    end
    if self.hasWorkingItem(:LIGHTBALL) &&
      isConst?(self.species,PBSpecies,:PIKACHU)
      atkmult=(atkmult*2.0).round
    end
    if self.hasWorkingItem(:CHOICESPECS)
      atkmult=(atkmult*1.5).round
    end
    if $fefieldeffect == 34 || $fefieldeffect == 35
      if self.hasWorkingAbility(:VICTORYSTAR)
        atkmult=(atkmult*1.5).round
      end
      partner=self.pbPartner
      if partner && partner.hasWorkingAbility(:VICTORYSTAR)
        atkmult=(atkmult*1.5).round
      end
    end
    if self.hasWorkingAbility(:QUEENLYMAJESTY) &&
      ($fefieldeffect==5 || $fefieldeffect==31)
      atkmult=(atkmult*1.5).round
    end 
    if self.hasWorkingAbility(:LONGREACH) &&
      ($fefieldeffect==27 || $fefieldeffect==28)
      atkmult=(atkmult*1.5).round
    end     
    if self.hasWorkingAbility(:CORROSION) &&
      ($fefieldeffect==10 || $fefieldeffect==11)
      atkmult=(atkmult*1.5).round
    end  
    atk=(atk*atkmult*1.0/0x1000).round
    return atk
  end  
  
  def pbCalcDefense()
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]      
    defense=@defense
    defstage=@stages[PBStats::DEFENSE]+6
    if @effects[PBEffects::PowerTrick]
      defense=@attack
      defstage=@stages[PBStats::DEFENSE]+6
    end       
    # TODO: Wonder Room should apply around here
    if @stages[PBStats::DEFENSE] >= 0
      stagemulp=1+0.5*@stages[PBStats::DEFENSE]
      defense=(defense*1.0*stagemulp).floor
    else        
      defense=(defense*1.0*stagemul[defstage]/stagediv[defstage]).floor
    end  
    defmult=0x1000  
    if $fefieldeffect == 24 && @function==0xE0
      defmult=(defmult*0.5).round
    end      
    if self.hasWorkingAbility(:MARVELSCALE) && 
      (self.status>0 || $fefieldeffect == 3 || $fefieldeffect == 9 ||
        $fefieldeffect == 31 || $fefieldeffect == 32 || $fefieldeffect == 34)
      defmult=(defmult*1.5).round
    end
    if isConst?(self.ability,PBAbilities,:GRASSPELT) && 
      ($fefieldeffect == 2 || $fefieldeffect == 15) # Grassy Field
      defmult=(defmult*1.5).round
    end
    #### AME - 005 - START
    if self.hasWorkingAbility(:FURCOAT)
      defmult=(defmult*2).round
    end
    if self.hasWorkingItem(:EVIOLITE)
      evos=pbGetEvolvedFormData(self.species)
      if evos && evos.length>0
        defmult=(defmult*1.5).round
      end
    end
    if self.hasWorkingItem(:METALPOWDER) &&
      isConst?(self.species,PBSpecies,:DITTO) &&
      !self.effects[PBEffects::Transform]
      defmult=(defmult*2.0).round
    end
    if (self.hasWorkingAbility(:PRISMARMOR) || 
        self.hasWorkingAbility(:SHADOWSHIELD)) && $fefieldeffect==4
      defmult=(defmult*2.0).round
    end    
    if self.hasWorkingAbility(:PRISMARMOR) && ($fefieldeffect==9 || $fefieldeffect==25)
      defmult=(defmult*2.0).round
    end   
    if self.hasWorkingAbility(:SHADOWSHIELD) && ($fefieldeffect==34 || $fefieldeffect==35)
      defmult=(defmult*2.0).round
    end        
    defense=(defense*defmult*1.0/0x1000).round    
    return defense
  end    
  
  def pbCalcSpDef()
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]    
    applysandstorm=false
    defense=@spdef
    defstage=@stages[PBStats::SPDEF]+6
    applysandstorm=true
    if !self.hasWorkingAbility(:UNAWARE)
      if @stages[PBStats::SPDEF] >= 0
        stagemulp=1+0.5*@stages[PBStats::SPDEF]
        defense=(defense*1.0*stagemulp).floor
      else        
        defense=(defense*1.0*stagemul[defstage]/stagediv[defstage]).floor
      end  
    end    
    if @battle.pbWeather==PBWeather::SANDSTORM &&
      self.pbHasType?(:ROCK) && applysandstorm
      defense=(defense*1.5).round
    end
    defmult=0x1000
    if $fefieldeffect == 24 && @function==0xE0
      defmult=(defmult*0.5).round
    end
    if $fefieldeffect == 3  &&
      self.pbHasType?(:FAIRY)
      defmult=(defmult*1.5).round
    end
    if $fefieldeffect == 12  &&
      self.pbHasType?(:GROUND)
      defmult=(defmult*1.5).round
    end
    if $fefieldeffect == 32 && 
      self.pbHasType?(:DRAGON)
      defmult=(defmult*1.5).round
    end
    #### AME - 005 - END
    if (@battle.pbWeather==PBWeather::SUNNYDAY || $fefieldeffect == 33 || $fefieldeffect == 42 || 
        (self.hasWorkingItem(:CHERCREST) && isConst?(self.species,PBSpecies,:CHERRIM)) || 
        (self.pbPartner.hasWorkingItem(:CHERCREST) && isConst?(self.pbPartner.species,PBSpecies,:CHERRIM)) )
      if self.hasWorkingAbility(:FLOWERGIFT) &&
        isConst?(self.species,PBSpecies,:CHERRIM)
        defmult=(defmult*1.5).round
      end
      if self.pbPartner.hasWorkingAbility(:FLOWERGIFT)  &&
        isConst?(self.pbPartner.species,PBSpecies,:CHERRIM)
        defmult=(defmult*1.5).round
      end
    end
    if self.hasWorkingItem(:EVIOLITE)
      evos=pbGetEvolvedFormData(self.species)
      if evos && evos.length>0
        defmult=(defmult*1.5).round
      end
    end
    if self.hasWorkingItem(:ASSAULTVEST)
      defmult=(defmult*1.5).round
    end
    if self.hasWorkingItem(:DEEPSEASCALE) &&
      isConst?(self.species,PBSpecies,:CLAMPERL)
      defmult=(defmult*2.0).round
    end  
    if self.hasWorkingItem(:METALPOWDER) &&
      isConst?(self.species,PBSpecies,:DITTO) &&
      !self.effects[PBEffects::Transform]
      defmult=(defmult*2.0).round
    end
    if (self.hasWorkingAbility(:PRISMARMOR) || 
        self.hasWorkingAbility(:SHADOWSHIELD)) && $fefieldeffect==4
      defmult=(defmult*2.0).round
    end    
    if self.hasWorkingAbility(:PRISMARMOR) && ($fefieldeffect==9 || $fefieldeffect==25)
      defmult=(defmult*2.0).round
    end   
    if self.hasWorkingAbility(:SHADOWSHIELD) && ($fefieldeffect==34 || $fefieldeffect==35)
      defmult=(defmult*2.0).round
    end        
    defense=(defense*defmult*1.0/0x1000).round
    return defense
  end  
  
  
  def pbCalcAcc()
    accstage=self.stages[PBStats::ACCURACY]
    accuracy=(accstage>=0) ? (accstage+3)*100/3 : 300/(3-accstage)
    if self.hasWorkingAbility(:COMPOUNDEYES)
      accuracy*=1.3
    end
    if self.hasWorkingAbility(:VICTORYSTAR)
      accuracy*=1.1
    end
    partner=self.pbPartner
    if partner && partner.hasWorkingAbility(:VICTORYSTAR)
      accuracy*=1.1
    end
    if self.hasWorkingItem(:WIDELENS)
      accuracy*=1.1
    end
    if self.hasWorkingAbility(:LONGREACH) && ($fefieldeffect==14 || # Rocky Field
        $fefieldeffect==15) # Forest Field
      accuracy*=0.9
    end 
    return accuracy
  end  
  
  def pbCalcEva()
    evastage=self.stages[PBStats::EVASION]
    evastage-=2 if @battle.field.effects[PBEffects::Gravity]>0
    evastage=-6 if evastage<-6
    evastage=6 if evastage>6  #>>DemICE
    evastage=0 if self.effects[PBEffects::Foresight] ||
    self.effects[PBEffects::MiracleEye]
    evasion=(evastage>=0) ? (evastage+3)*100/3 : 300/(3-evastage)
    if self.hasWorkingAbility(:TANGLEDFEET) &&
      self.effects[PBEffects::Confusion]>0
      evasion*=1.2
    end
    if self.hasWorkingAbility(:SANDVEIL) &&
      (@battle.pbWeather==PBWeather::SANDSTORM ||
        $fefieldeffect == 12 || $fefieldeffect == 20)
      evasion*=1.2
    end
    if self.hasWorkingAbility(:SNOWCLOAK) &&
      (@battle.pbWeather==PBWeather::HAIL || $fefieldeffect == 13 ||
        $fefieldeffect == 28)
      evasion*=1.2
    end
    if self.hasWorkingItem(:BRIGHTPOWDER)
      evasion*=1.1
    end
    if self.hasWorkingItem(:LAXINCENSE)
      evasion*=1.1
    end    
    return evasion
  end  
  
  def pbCalcCrit()
    
    #### KUROTSUNE - 029 - END      
    $buffs = 0
    if $fefieldeffect == 30
      $buffs = self.stages[PBStats::EVASION] if self.stages[PBStats::EVASION] > 0
      $buffs = $buffs.to_i + self.stages[PBStats::ACCURACY] if self.stages[PBStats::ACCURACY] > 0
    end   
    c=0
    c+=self.effects[PBEffects::FocusEnergy]
    c+=1 if self.hasWorkingAbility(:SUPERLUCK) || self.hasWorkingAbility(:LONGREACH)
    if self.hasWorkingItem(:STICK) &&
      (isConst?(self.species,PBSpecies,:FARFETCHD) || isConst?(self.species,PBSpecies,:SIRFETCHD))
      c+=2
    end
    if self.hasWorkingItem(:LUCKYPUNCH) &&
      isConst?(self.species,PBSpecies,:CHANSEY)
      c+=2
    end
    c+=1 if self.hasWorkingItem(:RAZORCLAW)
    c+=1 if self.hasWorkingItem(:SCOPELENS)
    if $fefieldeffect == 30
      c += $buffs
    end
    c=3 if c>3
    return c
  end      
  #DemICE left the chat>>>>
  
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
    if isConst?(@ability, PBAbilities, :UNBURDEN) && @unburdened
      speed=speed*2
    end
    if self.pbOwnSide.effects[PBEffects::Tailwind]>0
      speed=speed*2
    end
    if self.hasWorkingAbility(:SWIFTSWIM) && @battle.pbWeather==PBWeather::RAINDANCE && 
      !self.hasWorkingItem(:UTILITYUMBRELLA)
      speed=speed*2
    elsif ($fefieldeffect == 21 || $fefieldeffect == 22 || $fefieldeffect == 26) &&
      self.hasWorkingAbility(:SWIFTSWIM)
      speed=speed*2
    elsif (!self.pbHasType?(:WATER) && !self.hasWorkingAbility(:SWIFTSWIM) && !self.hasWorkingAbility(:STEELWORKER)) && 
      $fefieldeffect == 22
      speed=(speed*0.25).floor
    end
    if ((self.hasWorkingAbility(:SLUSHRUSH) || isConst?(self.species,PBSpecies,:EMPOLEON) && self.hasWorkingItem(:EMPCREST)) || (isConst?(self.species,PBSpecies,:CASTFORM) && isConst?(self.item,PBItems,:CASTCREST) && self.form==3)) && 
      (@battle.pbWeather==PBWeather::HAIL || $fefieldeffect==13 || $fefieldeffect==28 || $fefieldeffect==39)
      speed=speed*2  
    end   
    if self.hasWorkingAbility(:SURGESURFER) && (($fefieldeffect == 1) || 
        ($fefieldeffect==18) || ($fefieldeffect==21) || ($fefieldeffect==22) || 
        ($fefieldeffect==26) || (@battle.field.effects[PBEffects::ElectricTerrain]>0))
      speed=speed*2  
    end   
    if self.hasWorkingAbility(:TELEPATHY) && ($fefieldeffect==37)
      speed=speed*2  
    end    
    if $fefieldeffect == 35 && !self.isAirborne?
      speed=(speed*0.5).floor
    end
    if self.hasWorkingAbility(:CHLOROPHYLL) && 
      (@battle.pbWeather==PBWeather::SUNNYDAY ||
        ($fefieldeffect == 33 && $fecounter > 2)) &&
      !self.hasWorkingItem(:UTILITYUMBRELLA)
      speed=speed*2
    end
    if self.hasWorkingAbility(:SANDRUSH) &&
      (@battle.pbWeather==PBWeather::SANDSTORM || 
        $fefieldeffect == 12 || $fefieldeffect == 20)
      speed=speed*2
    end
    if self.hasWorkingAbility(:QUICKFEET) && self.status>0
      speed=(speed*1.5).floor
    end
    if self.hasWorkingItem(:MACHOBRACE) ||
      self.hasWorkingItem(:POWERWEIGHT) ||
      self.hasWorkingItem(:POWERBRACER) ||
      self.hasWorkingItem(:POWERBELT) ||
      self.hasWorkingItem(:POWERANKLET) ||
      self.hasWorkingItem(:POWERLENS) ||
      self.hasWorkingItem(:POWERBAND)
      speed=(speed/2).floor
    end
    if self.hasWorkingItem(:CHOICESCARF)
      speed=(speed*1.5).floor
    end
    if isConst?(self.item,PBItems,:IRONBALL)
      speed=(speed/2).floor
    end
    if isConst?(self.species,PBSpecies,:DITTO) && !@effects[PBEffects::Transform] &&
      self.hasWorkingItem(:QUICKPOWDER)
      speed=speed*2
    end
    if self.hasWorkingAbility(:SLOWSTART) && self.turncount<=5
      speed=(speed/2).floor
    end
    if self.status==PBStatuses::PARALYSIS && !self.hasWorkingAbility(:QUICKFEET)
      speed=(speed/2).floor
    end
    if @battle.internalbattle && @battle.pbOwnedByPlayer?(@index)
      speed=(speed*1.1).floor if @battle.pbPlayer.numbadges>=BADGESBOOSTSPEED
    end
    return speed
  end
  
  ################################################################################
  # Change HP
  ################################################################################
  def pbReduceHP(amt,anim=false)
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
    
    if @battle.raidbattle && !@battle.pbBelongsToPlayer?(self.index)
      limit = self.totalhp * 0.25
      if self.hp > 0 && oldhp > limit && self.hp < limit
        @battle.pbDisplay(_INTL("{1} has dropped its guard!!",pbThis))
      end
    end
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
      #      PBDebug.log("!!!***Can't faint if already fainted") if $INTERNAL
      return true
    end
    if ((@species==PBSpecies::PARAS && @pokemon.form==1 || @species==PBSpecies::PARASECT && @pokemon.form==1) && @effects[PBEffects::Resusitated]==false)
      @battle.scene.pbFakeOutFainted(self)
      @effects[PBEffects::Resusitated]=true
      pbUpdate(true)
      self.pbRecoverHP((self.totalhp).floor,true)
      @battle.pbDisplayPaused(_INTL("{1} was resuscitated!",self.pbThis))
      if $fefieldeffect==40
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
          PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
          @stages[i]=0 if @stages[i]<0
        end
      end
      return false
    else
      @battle.scene.pbFainted(self)     
    end
    if pbPartner.hasWorkingAbility(:POWEROFALCHEMY)
      if (!isConst?(@ability,PBAbilities,:MULTITYPE) && 
          !isConst?(@ability,PBAbilities,:COMATOSE) &&
          !isConst?(@ability,PBAbilities,:DISGUISE) &&
          !isConst?(@ability,PBAbilities,:SCHOOLING) &&
          !isConst?(@ability,PBAbilities,:RKSSYSTEM) &&
          !isConst?(@ability,PBAbilities,:IMPOSTER) &&
          !isConst?(@ability,PBAbilities,:SHIELDSDOWN))      
        partnerability=@ability
        pbPartner.ability=partnerability
        abilityname=PBAbilities.getName(partnerability)      
        @battle.pbDisplay(_INTL("{1} took on {2}'s {3}!",pbPartner.pbThis,pbThis,abilityname))
      end
    end    
    if pbPartner.hasWorkingAbility(:RECEIVER)
      if (!isConst?(@ability,PBAbilities,:MULTITYPE) && 
          !isConst?(@ability,PBAbilities,:COMATOSE) &&
          !isConst?(@ability,PBAbilities,:DISGUISE) &&
          !isConst?(@ability,PBAbilities,:SCHOOLING) &&
          !isConst?(@ability,PBAbilities,:RKSSYSTEM) &&
          !isConst?(@ability,PBAbilities,:IMPOSTER) &&
          !isConst?(@ability,PBAbilities,:SHIELDSDOWN))      
        partnerability=@ability
        pbPartner.ability=partnerability
        abilityname=PBAbilities.getName(partnerability)      
        @battle.pbDisplay(_INTL("{1} received {2}'s {3}!",pbPartner.pbThis,pbThis,abilityname))
      end
    end  
    for i in @battle.battlers
      next if i.isFainted?
      if i.hasWorkingAbility(:SOULHEART) && !i.pbTooHigh?(PBStats::SPATK)
        @battle.pbDisplay(_INTL("{1}'s Soul-heart activated!",i.pbThis))
        i.pbIncreaseStat(PBStats::SPATK,1,true)
        if ($fefieldeffect==3 || $fefieldeffect==9 || $fefieldeffect==31) && !i.pbTooHigh?(PBStats::SPDEF)
          i.pbIncreaseStat(PBStats::SPDEF,1,true)
        end
      end
    end    
    if self.ability == PBAbilities::NEUTRALIZINGGAS && !abilitynulled
      self.effects[PBEffects::GastroAcid]=true
      @battle.pbDisplayBrief(_INTL("The effects of the Neutralizing Gas wore off!"))	
      for i in @battle.battlers
        next if i.isFainted?
        i.pbAbilitiesOnSwitchIn(false)
      end
    end 
    droprelease = self.effects[PBEffects::SkyDroppee]
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
    if @battle.field.effects[PBEffects::WonderRoom] > 0
      for m in @battle.battlers
        if m.isFainted?
          if m.wonderroom
            m.pbSwapDefenses
          end
        end
      end
    end
    @fainted=true
    # reset choice
    @battle.choices[@index]=[0,0,nil,-1]
    @battle.pbDisplay(_INTL("{1} fainted!",pbThis)) if showMessage
    #@effects[PBEffects::Resusitated]==false
    #reset mimikyu form if it faints
    if @species==PBSpecies::MIMIKYU && @pokemon.form==1
      self.form=0
    end
    if @species==PBSpecies::PARASECT && @pokemon.form==2 
      self.form=1
    end
    if droprelease!=nil
      oppmon = droprelease
      oppmon.effects[PBEffects::SkyDrop]=false
      @battle.scene.pbUnVanishSprite(oppmon)
      @battle.pbDisplay(_INTL("{1} is freed from Sky Drop effect!",oppmon.pbThis))
    end    
    @battle.scene.partyBetweenKO1(self.index==1 || self.index==3) unless (@battle.doublebattle || pbNonActivePokemonCount==0)
    #PBDebug.log("[#{pbThis} fainted]") if $INTERNAL
    return true
  end
  
  ################################################################################
  # Find other battlers/sides in relation to this battler
  ################################################################################
  # Returns the data structure for this battler's side
  def pbOwnSide
    return @battle.sides[index&1] # Player: 0 and 2; Foe: 1 and 3
  end
  
  # Returns the data structure for the opposing Pokémon's side
  def pbOpposingSide
    return @battle.sides[(index&1)^1] # Player: 1 and 3; Foe: 0 and 2
  end
  
  # Returns whether the position belongs to the opposing Pokémon's side
  def pbIsOpposing?(i)
    return (@index&1)!=(i&1)
  end
  
  # Returns the battler's partner
  def pbPartner
    return @battle.battlers[(@index&1)|((@index&2)^2)]
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
    return @battle.battlers[(@index^1)]
  end
  
  def pbOppositeOpposing2
    return @battle.battlers[(@index^1)|((@index&2)^2)]
  end
  
  def pbNonActivePokemonCount()
    count=0
    party=@battle.pbParty(self.index)
    for i in 0...party.length
      if (self.isFainted? || i!=self.pokemonIndex) &&
        (pbPartner.isFainted? || i!=self.pbPartner.pokemonIndex) &&
        party[i] && !party[i].isEgg? && party[i].hp>0
        count+=1
      end
    end
    return count
  end
  
  def pbFaintedPokemonCount()
    count=0
    party=@battle.pbParty(self.index)
    for i in 0...party.length
      if party[i] && !party[i].isEgg? && party[i].hp==0
        count+=1
      end
    end
    return count
  end
  
  def pbEnemyNonActivePokemonCount()
    count=0
    party=@battle.pbParty(pbOppositeOpposing.index)
    for i in 0...party.length
      if (self.isFainted? || i!=self.pokemonIndex) &&
        (pbPartner.isFainted? || i!=self.pbPartner.pokemonIndex) &&
        party[i] && !party[i].isEgg? && party[i].hp>0
        count+=1
      end
    end
    return count
  end
  
  def pbEnemyFaintedPokemonCount()
    count=0
    party=@battle.pbParty(pbOppositeOpposing.index)
    for i in 0...party.length
      if party[i] && !party[i].isEgg? && party[i].hp==0
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
    if isConst?(self.species,PBSpecies,:CASTFORM)
      if self.hasWorkingAbility(:FORECAST)
        if @battle.pbWeather==PBWeather::SUNNYDAY && !self.hasWorkingItem(:UTILITYUMBRELLA)
          if self.form!=1
            self.form=1
            transformed=true
          end
        elsif @battle.pbWeather==PBWeather::RAINDANCE && !self.hasWorkingItem(:UTILITYUMBRELLA)
          if self.form!=2
            self.form=2
            transformed=true
          end
        elsif @battle.pbWeather==PBWeather::HAIL
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
          transformed=true
        end
      end      
      showmessage=transformed
    end
    # Cherrim
    if isConst?(self.species,PBSpecies,:CHERRIM) && !self.isFainted?
      if self.hasWorkingAbility(:FLOWERGIFT) && !self.hasWorkingItem(:UTILITYUMBRELLA)
        case @battle.pbWeather
        when PBWeather::SUNNYDAY
          if self.form!=1
            self.form=1
            transformed=true
          end
        else
          if ($fefieldeffect == 33 || $fefieldeffect == 42 || isConst?(self.item,PBItems,:CHERCREST))
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
          transformed=true
        end
      end      
    end   
    # Shaymin
    if isConst?(self.species,PBSpecies,:SHAYMIN) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Giratina
    if isConst?(self.species,PBSpecies,:GIRATINA) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Arceus
    if isConst?(self.ability,PBAbilities,:MULTITYPE) &&
      isConst?(self.species,PBSpecies,:ARCEUS) && !self.isFainted?
      if self.form!=@pokemon.form
        if $fefieldeffect == 35 && $fecounter == 1
          @battle.pbDisplay(_INTL("{1}'s Multitype activated!",pbThis))           
          $fecounter = 0         
        end
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Silvally
    if isConst?(self.ability,PBAbilities,:RKSSYSTEM) &&
      isConst?(self.species,PBSpecies,:SILVALLY) && !self.isFainted?
      if self.form!=@pokemon.form
        if $fefieldeffect == 35 && $fecounter == 1
          @battle.pbDisplay(_INTL("{1}'s RKS System activated!",pbThis))           
          $fecounter = 0         
        end
        self.form=@pokemon.form
        transformed=true
      end
    end    
    # Zen Mode
    if isConst?(self.species,PBSpecies,:DARMANITAN) && !self.isFainted?
      if self.hasWorkingAbility(:ZENMODE) ||  (isConst?(self.item,PBItems,:DARMCREST) && self.form==0)
        if ($fefieldeffect == 20 ||  $fefieldeffect == 37) || (isConst?(self.item,PBItems,:DARMCREST) && self.form==0)
          if self.form==0
            self.form=1; transformed = true
          elsif self.form==2
            self.form=3; transformed = true
          end
        elsif @hp<=((@totalhp/2).floor)
          if self.form == 0
            self.form = 1; transformed=true   
          elsif self.form == 2
            self.form = 3; transformed=true
          end
        elsif @hp>((@totalhp/2).floor) && !(isConst?(self.item,PBItems,:DARMCREST) && self.form==1)
          if self.form == 1
            self.form = 0; transformed=true
          elsif self.form == 3
            self.form = 2; transformed=true
          end
        end
      end
    end
    # Shift
    if @battle.shieldCount==0
      if isConst?(self.species,PBSpecies,:FERROTHORN) && !self.isFainted?
        if self.hasWorkingAbility(:SHIFT)
          if self.form!=2
            self.form=2; transformed=true
            pbBGMPlay("Battle - Pseudo Contribution",110)
            @battle.pbDisplay(_INTL("{1}'s form shifted!",pbThis)) 
          end 
        end
      end
    end
    # Temporal Shift
    if isConst?(self.species,PBSpecies,:FROSLASS) && !self.isFainted?
      if self.hasWorkingAbility(:TEMPORALSHIFT)
        if @battle.shieldCount==0
          if self.form!=2
            self.form=2; transformed=true
            @battle.pbDisplay(_INTL("{1}'s form shifted!",pbThis)) 
          end 
        end
      end
    end
    # Keldeo
    if isConst?(self.species,PBSpecies,:KELDEO) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Genesect
    if isConst?(self.species,PBSpecies,:GENESECT) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # UPDATE 1/18/2014
    # Aegislash
    if isConst?(self.species, PBSpecies, :AEGISLASH) && !self.isFainted?
      if isConst?(self.ability, PBAbilities, :STANCECHANGE)
        
        # in Shield Forme and used a damaging move
        if self.form == 0 && !thismove.nil? && thismove.basedamage > 0
          self.form = 1 ; transformed = true
          # in Blade Forme and used King's Shield
        elsif self.form == 1 && !thismove.nil? && thismove.id == 584 # King's Shield
          self.form = 0 ; transformed = true
        end
      end
    end # end of update
    # Silvally
    if isConst?(self.ability,PBAbilities,:RKSSYSTEM) &&
      isConst?(self.species,PBSpecies,:SILVALLY) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    if transformed
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self,@pokemon)
      if $fefieldeffect == 35 && (isConst?(self.species,PBSpecies,:ARCEUS) || isConst?(self.species,PBSpecies,:SILVALLY))
        typename=PBTypes.getName(@pokemon.type1)    
        @battle.pbDisplay(_INTL("{1} rolled the {2} type!",pbThis,typename))
      else
        @battle.pbDisplay(_INTL("{1} transformed!",pbThis))
      end
      if isConst?(self.ability, PBAbilities, :STANCECHANGE) && 
        ($fefieldeffect == 5 || $fefieldeffect == 31)
        if self.form == 1
          self.pbReduceStat(PBStats::DEFENSE,1,false)
          self.pbIncreaseStat(PBStats::ATTACK,1,false)
        else
          self.pbReduceStat(PBStats::ATTACK,1,false)
          self.pbIncreaseStat(PBStats::DEFENSE,1,false)
        end
      end
    end
  end
  
  def pbCheckFormRoundEnd(thismove = nil) 
    # Wishiwashi
    if isConst?(self.species,PBSpecies,:WISHIWASHI) && !self.isFainted?
      if self.hasWorkingAbility(:SCHOOLING) 
        schoolHP = (self.totalhp/4).floor
        if (self.hp>schoolHP && self.level>19) || $fefieldeffect==21 || 
          $fefieldeffect==22 || $fefieldeffect==26
          if self.form!=1
            self.form=1
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
    if isConst?(self.species,PBSpecies,:MINIOR) && !self.isFainted?
      if self.hasWorkingAbility(:SHIELDSDOWN)
        coreHP = (self.totalhp/2).floor
        if self.hp>coreHP
          if self.form!=6
            self.form=6
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("{1} shields came up!",pbThis))  
          end
        else
          if self.form!=self.startform
            self.form=self.startform
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("{1}'s shields went down!",pbThis))  
          end
        end
      end      
    end   
    # Zygarde
    if isConst?(self.species,PBSpecies,:ZYGARDE) && !self.isFainted?
      if self.hasWorkingAbility(:POWERCONSTRUCT)
        completeHP = (self.totalhp/2).floor
        if self.hp<=completeHP
          if self.form!=2
            @battle.pbDisplay(_INTL("You sense the presence of many!"))  
            self.form=2
            pbUpdate(true)
            @battle.scene.pbChangePokemon(self,@pokemon)
            @battle.pbDisplay(_INTL("{1} transformed into its Complete Forme!",pbThis))  
          end        
        end
      end      
    end      
  end  
  
  def pbBreakDisguise
    self.form=1
    pbUpdate(true)
    @battle.scene.pbChangePokemon(self,@pokemon)
  end
  
  def pbSUSlmao
    self.form=2
    @effects[PBEffects::Resusitated]=true
    pbUpdate(true)
    @battle.scene.pbChangePokemon(self,@pokemon)
  end
  
  def pbRegenFace
    self.form=0
    @effects[PBEffects::IceFace] = true
    pbUpdate(true)
    @battle.scene.pbChangePokemon(self,@pokemon)
  end
  
  def pbResetForm
    #### KUROTSUNE - 001 - START
    if !@effects[PBEffects::Transform]
      if isConst?(self.species,PBSpecies,:CASTFORM)   ||
        isConst?(self.species,PBSpecies,:CHERRIM)    ||
        isConst?(self.species,PBSpecies,:DARMANITAN) ||
        #isConst?(self.species,PBSpecies,:MELOETTA)   ||
        isConst?(self.species,PBSpecies,:AEGISLASH)  ||
        isConst?(self.species,PBSpecies,:KYOGRE)     ||
        isConst?(self.species,PBSpecies,:GROUDON)    ||
        isConst?(self.species,PBSpecies,:WISHIWASHI)
        self.form=0
      elsif isConst?(self.species,PBSpecies,:ZYGARDE) ||
        isConst?(self.species,PBSpecies,:MINIOR)        
        self.form=startform
      end
    end
    #### KUROTSUNE - 001 - END
    pbUpdate(true)
  end
  
  ################################################################################
  # Ability effects
  ################################################################################
  def pbAbilitiesOnSwitchIn(onactive,megad=false)
    return if hp<=0
    if self.hasWorkingAbility(:NEUTRALIZINGGAS)	&& onactive		
      @battle.pbDisplay(_INTL("Neutralizing Gas fills the area! Abilities are suppressed!"))
    end		
    if self.hasWorkingAbility(:HUNGERSWITCH) && isConst?(self.species,PBSpecies,:MORPEKO) && $fefieldeffect == 39 && !self.isFainted?
      self.form = 1
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self,@pokemon)
    end
    ##### KUROTSUNE - 001 - START
    
    #### PRIMAL REVERSIONS
    
    #### Kyogre primal reversion
    #### Checks if the pokemon is Kyogre and is not fainted
    if isConst?(self.species, PBSpecies, :KYOGRE) && !self.isFainted?
      #### Checks if Kyogre is holding Blue Orb
      if isConst?(self.item, PBItems, :BLUEORB)
        #### Checks if Kyogre is already Primal or not
        if self.form == 0
          #### Sets new form and updates sprite.
          self.form = 1
          pbUpdate(true)
          @battle.scene.pbChangePokemon(self,@pokemon)
          @battle.pbDisplay(_INTL("Kyogre's Primal Reversion! It reverted to its primal form!",pbThis))
        end
      end
    end
    
    #### Groudon primal reversion
    #### Checks if the pokemon is Groudon and is not fainted
    if isConst?(self.species, PBSpecies, :GROUDON) && !self.isFainted?
      #### Checks if Groudon is holding Red Orb
      if isConst?(self.item, PBItems, :REDORB)
        #### Checks if Groudon is already Primal or not
        if self.form == 0
          #### Sets new for and updates sprite.
          self.form = 1
          pbUpdate(true)
          @battle.scene.pbChangePokemon(self,@pokemon)
          @battle.pbDisplay(_INTL("Groudon's Primal Reversion! It reverted to its primal form!",pbThis))
        end
      end
    end 
    #### END OF PRIMAL REVERSIONS    
    if isConst?(self.species, PBSpecies, :EISCUE) && !self.isFainted? &&
      self.effects[PBEffects::IceFace] && ($fefieldeffect==7 || $fefieldeffect==16 || $fefieldeffect==45)
      @battle.scene.pbDamageAnimation(self,0)
      self.pbBreakDisguise
      @battle.pbDisplayPaused(_INTL("{1} transformed!",self.name))
      self.effects[PBEffects::IceFace]=false
    end  
    #### START OF WEATHER ABILITIES
    
    if isConst?(ability,PBAbilities,:PRIMORDIALSEA) && onactive && 
      !@battle.field.effects[PBEffects::HeavyRain]
      @battle.field.effects[PBEffects::HeavyRain] = true
      @battle.weather=PBWeather::RAINDANCE
      @battle.weatherduration=-1
      @battle.pbDisplay(_INTL("A heavy rain began to fall!"))
      @battle.pbCommonAnimation("Rain",nil,nil)
    end
    
    if isConst?(ability,PBAbilities,:DESOLATELAND) && onactive && 
      !@battle.field.effects[PBEffects::HarshSunlight]
      @battle.field.effects[PBEffects::HarshSunlight] = true
      @battle.weather=PBWeather::SUNNYDAY
      @battle.weatherduration=-1
      @battle.pbDisplay(_INTL("The sunlight turned extremely harsh!"))
      @battle.pbCommonAnimation("Sunny",nil,nil)
      # eruption check
      if $fefieldeffect == 16
        @battle.eruption = true
        @battle.pbDisplay(_INTL("The volcano top erupted!"))
      end
    end
    
    if isConst?(ability,PBAbilities,:DELTASTREAM) && onactive && 
      @battle.weather!=PBWeather::STRONGWINDS
      @battle.weather=PBWeather::STRONGWINDS
      @battle.weatherduration=-1
      @battle.pbDisplay(_INTL("A mysterious air current is protecting Flying-type Pokemon!"))
    end
    
    # PRIMORDIAL WEATHER DEACTIVATION TESTS
    # Any primordial weather active?    
    if @battle.field.effects[PBEffects::HeavyRain]     ||
      @battle.field.effects[PBEffects::HarshSunlight] ||
      @battle.weather == PBWeather::STRONGWINDS
      #      Flag to check whether weather should stay active
      primordialsea = false
      desolateland  = false
      deltastream   = false
      cloudnine     = false
      for i in 0..3
        if @battle.battlers[i].hasWorkingAbility(:PRIMORDIALSEA) 
          primordialsea = true
        elsif @battle.battlers[i].hasWorkingAbility(:DESOLATELAND)
          desolateland  = true
        elsif @battle.battlers[i].hasWorkingAbility(:DELTASTREAM)
          deltastream   = true
        elsif @battle.battlers[i].hasWorkingAbility(:CLOUDNINE)# && $fefieldeffect == 43
          cloudnine     = true
        end
      end
      if cloudnine
        primordialsea = false
        desolateland  = false
        deltastream   = false
      end
      
      if !primordialsea
        if @battle.field.effects[PBEffects::HeavyRain]
          @battle.pbDisplay(_INTL("The heavy rain has lifted."))
          @battle.field.effects[PBEffects::HeavyRain] = false
          unless ((ability == PBAbilities::PRIMORDIALSEA) || (ability == PBAbilities::DESOLATELAND) ||
              (ability == PBAbilities::DELTASTREAM)) && onactive
            @battle.weatherduration = 0 
            @battle.weather = 0
          end
          #### DemICE  - persistentweather - START
          if @battle.weatherbackup!=0  
            @battle.pbCommonAnimation(@battle.weatherbackupanim,nil,nil)            
            @battle.weather = @battle.weatherbackup
            @weatherduration=-1
            @battle.pbDisplay(_INTL("The initial weather took over again!"))
          end  
          #### DemICE
        end
      end
      if !desolateland
        if @battle.field.effects[PBEffects::HarshSunlight]
          @battle.pbDisplay(_INTL("The harsh sunlight faded!"))
          @battle.field.effects[PBEffects::HarshSunlight] = false
          unless ((ability == PBAbilities::PRIMORDIALSEA) || (ability == PBAbilities::DESOLATELAND) ||
              (ability == PBAbilities::DELTASTREAM)) && onactive
            @battle.weatherduration = 0 
            @battle.weather = 0
          end
          #### DemICE  - persistentweather - START
          if @battle.weatherbackup!=0  
            @battle.pbCommonAnimation(@battle.weatherbackupanim,nil,nil)            
            @battle.weather = @battle.weatherbackup
            @weatherduration=-1
            @battle.pbDisplay(_INTL("The initial weather took over again!"))
          end  
          #### DemICE
        end
      end 
      if !($fefieldeffect==16 || $fefieldeffect==27 || $fefieldeffect==28 || $fefieldeffect==43)
        if !deltastream && $game_screen.weather_type != 8 && !ability == PBAbilities::TEMPEST
          if @battle.weather == PBWeather::STRONGWINDS
            @battle.pbDisplay(_INTL("The mysterious air current has dissipated!"))
            unless ((ability == PBAbilities::PRIMORDIALSEA) || (ability == PBAbilities::DESOLATELAND) ||
                (ability == PBAbilities::DELTASTREAM)) && onactive
              @battle.weatherduration = 0 
              @battle.weather = 0
            end
            #### DemICE - persistentweather - START
            if @battle.weatherbackup!=0
              @battle.pbCommonAnimation(@battle.weatherbackupanim,nil,nil)              
              @battle.weather = @battle.weatherbackup
              @weatherduration=-1
              @battle.pbDisplay(_INTL("The initial weather took over again!"))
            end
            #### DemICE
          end
        end
      end
    end
    # END OF PRIMAL WEATHER DEACTIVATION TESTS  
    #Surges
    if isConst?(ability,PBAbilities,:ELECTRICSURGE) && onactive  &&  ($fefieldeffect!=35)
      @battle.pbAnimation(571,self,nil)
      if ($febackup>0 && $febackup<46 && @battle.field.effects[PBEffects::Splintered]==0) || ($game_map.map_id==53)
        if @battle.field.effects[PBEffects::ElectricTerrain]==0
          @battle.field.effects[PBEffects::ElectricTerrain]=5
          if isConst?(self.item,PBItems,:AMPLIFIELDROCK) 
            @battle.field.effects[PBEffects::ElectricTerrain]=8
          end          
          @battle.pbDisplay(_INTL("The terrain became electrified!"))
        end  
      else        
        $fetempfield = 1 
        $fefieldeffect = $fetempfield
        @battle.pbChangeBGSprite
        @battle.field.effects[PBEffects::Terrain]=5 
        @battle.field.effects[PBEffects::ElectricTerrain]=5 if ($fefieldeffect!=1)
        @battle.field.effects[PBEffects::Terrain]=8 if isConst?(self.item,PBItems,:AMPLIFIELDROCK)  
        @battle.field.effects[PBEffects::ElectricTerrain]=8 if isConst?(self.item,PBItems,:AMPLIFIELDROCK) && ($fefieldeffect!=1)
        @battle.pbDisplay(_INTL("The terrain became electrified!"))
      end  
    end  
    if isConst?(ability,PBAbilities,:GRASSYSURGE) && onactive && ($fefieldeffect!=35)
      @battle.pbAnimation(581,self,nil)
      if ($febackup>0 && $febackup<46 && @battle.field.effects[PBEffects::Splintered]==0) || ($game_map.map_id==53)
        if @battle.field.effects[PBEffects::GrassyTerrain]==0
          @battle.field.effects[PBEffects::GrassyTerrain]=5
          @battle.field.effects[PBEffects::GrassyTerrain]=8 if $fefieldeffect==42
          if isConst?(self.item,PBItems,:AMPLIFIELDROCK)      
            @battle.field.effects[PBEffects::GrassyTerrain]=8
          end          
          @battle.pbDisplay(_INTL("The terrain became grassy!"))        
        end  
      else        
        $fetempfield = 2 
        $fefieldeffect = $fetempfield
        @battle.pbChangeBGSprite
        @battle.field.effects[PBEffects::Terrain]=5
        @battle.field.effects[PBEffects::GrassyTerrain]=5 if ($fefieldeffect!=2)
        @battle.field.effects[PBEffects::Terrain]=8 if isConst?(self.item,PBItems,:AMPLIFIELDROCK) 
        @battle.field.effects[PBEffects::GrassyTerrain]=8 if isConst?(self.item,PBItems,:AMPLIFIELDROCK) && ($fefieldeffect!=2)
        @battle.pbDisplay(_INTL("The terrain became grassy!"))
      end  
    end          
    if isConst?(ability,PBAbilities,:MISTYSURGE) && onactive  &&  ($fefieldeffect!=35)
      @battle.pbAnimation(588,self,nil)
      if ($febackup>0 && $febackup<46 && @battle.field.effects[PBEffects::Splintered]==0) || ($game_map.map_id==53)
        if @battle.field.effects[PBEffects::MistyTerrain]==0
          @battle.field.effects[PBEffects::MistyTerrain]=5
          if isConst?(self.item,PBItems,:AMPLIFIELDROCK) 
            @battle.field.effects[PBEffects::MistyTerrain]=8
          end          
          @battle.pbDisplay(_INTL("The terrain became misty!"))
        end  
      else        
        $fetempfield = 3 
        $fefieldeffect = $fetempfield
        @battle.pbChangeBGSprite
        @battle.field.effects[PBEffects::Terrain]=5
        @battle.field.effects[PBEffects::MistyTerrain]=5 if ($fefieldeffect!=3)
        @battle.field.effects[PBEffects::Terrain]=8 if isConst?(self.item,PBItems,:AMPLIFIELDROCK) 
        @battle.field.effects[PBEffects::MistyTerrain]=8 if isConst?(self.item,PBItems,:AMPLIFIELDROCK) && ($fefieldeffect!=3)
        @battle.pbDisplay(_INTL("The terrain became misty!"))
      end  
    end  
    if isConst?(ability,PBAbilities,:PSYCHICSURGE) && onactive  &&  ($fefieldeffect!=35)
      @battle.pbAnimation(719,self,nil)
      if ($febackup>0 && $febackup<46 && @battle.field.effects[PBEffects::Splintered]==0) || ($game_map.map_id==53)
        if @battle.field.effects[PBEffects::PsychicTerrain]==0
          @battle.field.effects[PBEffects::PsychicTerrain]=5
          if isConst?(self.item,PBItems,:AMPLIFIELDROCK)
            @battle.field.effects[PBEffects::PsychicTerrain]=8
          end          
          @battle.pbDisplay(_INTL("The terrain became mysterious!"))
        end  
      else        
        $fetempfield = 37 
        $fefieldeffect = $fetempfield
        @battle.pbChangeBGSprite
        @battle.field.effects[PBEffects::Terrain]=5
        @battle.field.effects[PBEffects::PsychicTerrain]=5 if ($fefieldeffect!=37)
        @battle.field.effects[PBEffects::Terrain]=8 if isConst?(self.item,PBItems,:AMPLIFIELDROCK) 
        @battle.field.effects[PBEffects::PsychicTerrain]=8 if isConst?(self.item,PBItems,:AMPLIFIELDROCK) && ($fefieldeffect!=37)
        @battle.pbDisplay(_INTL("The terrain became mysterious!"))
      end  
    end       
    rainbowhold=0
    # Field Seeds
    @battle.seedCheck
    # Weather Abilities
    if isConst?(ability,PBAbilities,:DRIZZLE) && onactive  && $fefieldeffect != 38 &&
      @battle.weather!=PBWeather::RAINDANCE
      if @battle.field.effects[PBEffects::HeavyRain]
        @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      elsif @battle.field.effects[PBEffects::HarshSunlight]
        @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      elsif @battle.weather==PBWeather::STRONGWINDS #&& (@battle.battlers[0].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[1].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[2].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[3].hasWorkingAbility(:DELTASTREAM))
        @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      elsif $fefieldeffect == 35
        @battle.pbDisplay(_INTL("The weather disappeared into space!"))
      else
        if @battle.weather==PBWeather::SUNNYDAY
          rainbowhold=5
          rainbowhold=8 if isConst?(self.item,PBItems,:DAMPROCK)
        end
        @battle.weather=PBWeather::RAINDANCE
        @battle.weatherduration=5
        @battle.weatherduration=8 if isConst?(self.item,PBItems,:DAMPROCK) || $fefieldeffect == 43
        if self.isbossmon
          @battle.weatherduration=-1
          @battle.weatherbackup=PBWeather::RAINDANCE
          @battle.weatherbackupanim="Rain"
        end
        @battle.pbCommonAnimation("Rain",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Drizzle made it rain!",pbThis))
      end
    end
    if isConst?(ability,PBAbilities,:SANDSTREAM) && onactive && $fefieldeffect != 38 && 
      @battle.weather!=PBWeather::SANDSTORM
      if @battle.field.effects[PBEffects::HeavyRain]
        @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      elsif @battle.field.effects[PBEffects::HarshSunlight]
        @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      elsif @battle.weather==PBWeather::STRONGWINDS #&& (@battle.battlers[0].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[1].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[2].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[3].hasWorkingAbility(:DELTASTREAM))
        @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      elsif $fefieldeffect == 35
        @battle.pbDisplay(_INTL("The weather disappeared into space!"))
      else
        @battle.weather=PBWeather::SANDSTORM
        @battle.weatherduration=5
        @battle.weatherduration=8 if isConst?(self.item,PBItems,:SMOOTHROCK) ||
        $fefieldeffect == 12 || $fefieldeffect == 20 || $fefieldeffect == 43
        if self.isbossmon
          @battle.weatherduration=-1
          @battle.weatherbackup=PBWeather::SANDSTORM
          @battle.weatherbackupanim="Sandstorm"
        end
        @battle.pbCommonAnimation("Sandstorm",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Sand Stream whipped up a sandstorm!",pbThis))
      end
    end
    if isConst?(ability,PBAbilities,:TEMPEST) && onactive 
      weathers=rand(5)
      case weathers
       when 0
          @battle.weather=PBWeather::RAINDANCE
          @battle.weatherduration=8
          @battle.pbCommonAnimation("Rain",nil,nil)
          @battle.pbDisplay(_INTL("Storm-9 created a downpour!"))
       when 1
          @battle.weather=PBWeather::HAIL
          @battle.weatherduration=8
          @battle.pbCommonAnimation("Hail",nil,nil)
          @battle.pbDisplay(_INTL("Storm-9 brought hailfall!"))
       when 2
          @battle.weather=PBWeather::SANDSTORM
          @battle.weatherduration=8
          @battle.pbCommonAnimation("Sandstorm",nil,nil)
          @battle.pbDisplay(_INTL("Storm-9 whipped up a duststorm!"))
       when 3
          @battle.weather=PBWeather::STRONGWINDS
          @battle.weatherduration=8
          @battle.pbCommonAnimation("Wind",nil,nil)
          @battle.pbDisplay(_INTL("Storm-9 whipped up terrible winds!"))
       when 4
          @battle.weather=PBWeather::SHADOWSKY
          @battle.weatherduration=8
          @battle.pbCommonAnimation("ShadowSky",nil,nil)
          @battle.pbDisplay(_INTL("Storm-9 shrouded the sky in a dark aura..."))
       end
     end
    if isConst?(ability,PBAbilities,:DROUGHT) && onactive && $fefieldeffect != 38 && 
      @battle.weather!=PBWeather::SUNNYDAY
      if @battle.field.effects[PBEffects::HeavyRain]
        @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      elsif @battle.field.effects[PBEffects::HarshSunlight]
        @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      elsif @battle.weather==PBWeather::STRONGWINDS #&& (@battle.battlers[0].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[1].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[2].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[3].hasWorkingAbility(:DELTASTREAM))
        @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))         
      elsif $fefieldeffect == 35
        @battle.pbDisplay(_INTL("The weather disappeared into space!"))
      else
        if @battle.weather==PBWeather::RAINDANCE
          rainbowhold=5
          rainbowhold=8 if isConst?(self.item,PBItems,:HEATROCK)
        end
        @battle.weather=PBWeather::SUNNYDAY
        @battle.weatherduration=5
        @battle.weatherduration=8 if isConst?(self.item,PBItems,:HEATROCK) || 
        $fefieldeffect == 12 || $fefieldeffect == 27 || $fefieldeffect == 28 || $fefieldeffect == 43
        if self.isbossmon
          @battle.weatherduration=-1
          @battle.weatherbackup=PBWeather::SUNNYDAY
          @battle.weatherbackupanim="Sunny"
        end
        @battle.pbCommonAnimation("Sunny",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Drought intensified the sun's rays!",pbThis))
        if $fefieldeffect == 4
          $fefieldeffect = 25
          @battle.pbChangeBGSprite
          @effects[PBEffects::Terrain] = @battle.weatherduration
          @battle.pbDisplay(_INTL("The sun lit up the crystal cavern!"))
        end
      end
    end
    if isConst?(ability,PBAbilities,:SNOWWARNING) && onactive  && $fefieldeffect != 38 && 
      @battle.weather!=PBWeather::HAIL
      if @battle.field.effects[PBEffects::HeavyRain]
        @battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
      elsif @battle.field.effects[PBEffects::HarshSunlight]
        @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      elsif @battle.weather==PBWeather::STRONGWINDS #&& (@battle.battlers[0].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[1].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[2].hasWorkingAbility(:DELTASTREAM) || @battle.battlers[3].hasWorkingAbility(:DELTASTREAM))
        @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      elsif $fefieldeffect == 35
        @battle.pbDisplay(_INTL("The weather disappeared into space!"))
      else
        @battle.weather=PBWeather::HAIL
        @battle.weatherduration=5
        @battle.weatherduration=8 if isConst?(self.item,PBItems,:ICYROCK) ||
        $fefieldeffect == 13 || $fefieldeffect == 28 || $fefieldeffect == 39 || $fefieldeffect == 43
        if self.isbossmon
          @battle.weatherduration=-1
          @battle.weatherbackup=PBWeather::HAIL
          @battle.weatherbackupanim="Hail"
        end
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
    if rainbowhold != 0 && @battle.field.effects[PBEffects::Splintered]==0
      if $fefieldeffect != 9
        @battle.pbCommonAnimation("RainbowT",nil,nil)
      end
      if $febackup>0 && $febackup<46 && @battle.field.effects[PBEffects::Splintered]==0
        @battle.pbDisplay(_INTL("The weather created a rainbow!"))
        @battle.field.effects[PBEffects::Rainbow]= rainbowhold
      else
        $fefieldeffect = 9
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("The weather created a rainbow!"))
        @battle.field.effects[PBEffects::Terrain]= rainbowhold
        @battle.field.effects[PBEffects::Rainbow]= rainbowhold
      end
    end
    # Castform Crest
    if isConst?(self.species,PBSpecies,:CASTFORM) && isConst?(self.item,PBItems,:CASTCREST) && 
      self.turncount==0
      
      for i in self.moves
        movedata=PBMoveData.new(i.id)
        if movedata.function==0xFF # Sunny Day
          if @battle.weather!=PBWeather::SUNNYDAY
            @battle.weather=PBWeather::SUNNYDAY
            @battle.weatherduration=5
            @battle.weatherduration=8 if $fefieldeffect == 12 || $fefieldeffect == 27 || $fefieldeffect == 28 || $fefieldeffect == 43
            @battle.pbCommonAnimation("Sunny",nil,nil)
            @battle.pbDisplay(_INTL("{1}'s Sunny Day intensified the sun's rays!",pbThis))
            self.pbCheckForm
          end
          break
        end
        if movedata.function==0x100 # Rain Dance
          if @battle.weather!=PBWeather::RAINDANCE
            @battle.weather=PBWeather::RAINDANCE
            @battle.weatherduration=5
            @battle.weatherduration=8 if $fefieldeffect == 43
            @battle.pbCommonAnimation("Rain",nil,nil)
            @battle.pbDisplay(_INTL("{1}'s Rain Dance made it rain!",pbThis))
            self.pbCheckForm
          end
          break
        end
        if movedata.function==0x101 # Sandstorm
          if @battle.weather!=PBWeather::SANDSTORM
            @battle.weather=PBWeather::SANDSTORM
            @battle.weatherduration=5
            @battle.weatherduration=8 if $fefieldeffect == 12 || $fefieldeffect == 20 || $fefieldeffect == 43
            @battle.pbCommonAnimation("Sandstorm",nil,nil)
            @battle.pbDisplay(_INTL("{1}'s Sandstorm whipped up a sandstorm!",pbThis))
            self.pbCheckForm
          end
          break
        end
        if movedata.function==0x102 # Hail
          if @battle.weather!=PBWeather::HAIL
            @battle.weather=PBWeather::HAIL
            @battle.weatherduration=5
            @battle.weatherduration=8 if $fefieldeffect == 13 || $fefieldeffect == 28 || $fefieldeffect == 39 || $fefieldeffect == 43
            @battle.pbCommonAnimation("Hail",nil,nil)
            @battle.pbDisplay(_INTL("{1}'s Hail made it hail!",pbThis))
            self.pbCheckForm
          end
          break
        end
      end
    end
    #### END OF WEATHER ABILITIES
    
    #### START OF WEATHER-CANCELLING ABILITIES
    if self.hasWorkingAbility(:AIRLOCK) && onactive
      @battle.pbDisplay(_INTL("The effects of the weather disappeared."))
    end
    
    if self.hasWorkingAbility(:CLOUDNINE) && onactive
      @battle.pbDisplay(_INTL("The effects of the weather disappeared."))
    end
    
    #### END OF WEATHER-CANCELLING ABILITIES     
    
    ##### KUROTSUNE - 001 - END
    # Pressure message
    if self.hasWorkingAbility(:PRESSURE) && onactive
      @battle.pbDisplay(_INTL("{1} is exerting its Pressure!",pbThis))
    end
    # UPDATE : Mold Breaker
    if isConst?(ability,PBAbilities,:MOLDBREAKER) && onactive
      @battle.pbDisplay(_INTL("{1} breaks the mold!",pbThis))
    end
    if isConst?(ability,PBAbilities,:COMATOSE) && onactive && $fefieldeffect!=1
      @battle.pbDisplay(_INTL("{1} is drowsing!",pbThis))
    end    
    #### AME - 001 - START
    if isConst?(ability,PBAbilities,:TERAVOLT) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",pbThis))
    end
    if isConst?(ability,PBAbilities,:TURBOBLAZE) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",pbThis))
    end
    #### AME - 001 - END    
    if isConst?(ability,PBAbilities,:FAIRYAURA) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a Fairy aura!",pbThis))
    end
    if isConst?(ability,PBAbilities,:DARKAURA) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a Dark aura!",pbThis))
    end
    if isConst?(ability,PBAbilities,:AURABREAK) && onactive
      @battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",pbThis))
    end
    # End of Update
    #### SARDINES - v17 - START
    # Slow Start Message
    if isConst?(ability,PBAbilities,:SLOWSTART) && onactive
      @battle.pbDisplay(_INTL("{1} can't get it going because of its {2}", pbThis, PBAbilities.getName(ability)))
    end
    #### SARDINES - v17 - END
    # Balloon
    if self.hasWorkingItem(:AIRBALLOON) && onactive && !megad
      @battle.pbDisplay(_INTL("{1} is floating on its balloon!",pbThis))
    end
    # Trace
    if self.hasWorkingAbility(:TRACE) || (self.hasWorkingAbility(:ADAPTABILITY) &&
        $fefieldeffect == 34)
      @effects[PBEffects::TracedAbility]=0
      if @effects[PBEffects::Trace] || onactive
        choices=[]
        for i in 0...4
          if pbIsOpposing?(i) && !@battle.battlers[i].isFainted? && !@battle.battlers[i].isBoss
            choices[choices.length]=i if @battle.battlers[i].ability!=0 &&
            (!isConst?(@battle.battlers[i].ability,PBAbilities,:MULTITYPE) && 
              !isConst?(@battle.battlers[i].ability,PBAbilities,:COMATOSE) &&
              !isConst?(@battle.battlers[i].ability,PBAbilities,:DISGUISE) &&
              !isConst?(@battle.battlers[i].ability,PBAbilities,:ACCUMULATION) &&
              !isConst?(@battle.battlers[i].ability,PBAbilities,:EXECUTION) &&
              !isConst?(@battle.battlers[i].ability,PBAbilities,:SCHOOLING) &&
              !isConst?(@battle.battlers[i].ability,PBAbilities,:IMPOSTER) &&
              !isConst?(@battle.battlers[i].ability,PBAbilities,:SHIELDSDOWN) &&
              !isConst?(@battle.battlers[i].ability,PBAbilities,:RKSSYSTEM))
          end
        end
        if choices.length==0
          @effects[PBEffects::Trace]=true
        else
          choice=choices[@battle.pbRandom(choices.length)]
          battlername=@battle.battlers[choice].pbThis(true)
          battlerability=@battle.battlers[choice].ability
          @ability=battlerability
          abilityname=PBAbilities.getName(battlerability)
          @effects[PBEffects::TracedAbility]=battlerability
          if self.hasWorkingAbility(:ADAPTABILITY)
            @battle.pbDisplay(_INTL("{1} took on {2}'s {3}!",pbThis,battlername,abilityname))
          else
            @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!",pbThis,battlername,abilityname))
          end
          @effects[PBEffects::Trace]=false
        end
      end
    end
    # Mimicry
    if self.hasWorkingAbility(:MIMICRY) && onactive
      protype = -1
      case $fefieldeffect
      when 1
        protype = :ELECTRIC || 0
      when 2
        protype = :GRASS || 0
      when 3
        protype = :FAIRY || 0
      when 4
        protype = :DARK || 0
      when 5
        protype = :PSYCHIC || 0
      when 6
        protype = :NORMAL || 0
      when 7
        protype = :FIRE || 0
      when 8
        protype = :WATER || 0
      when 9
        protype = :DRAGON || 0
      when 10
        protype = :POISON || 0
      when 11
        protype = :POISON || 0
      when 12
        protype = :GROUND || 0
      when 13
        protype = :ICE || 0
      when 14
        protype = :ROCK || 0
      when 15
        protype = :BUG || 0
      when 16
        protype = :FIRE || 0
      when 17
        protype = :STEEL || 0
      when 18
        protype = :ELECTRIC || 0
      when 19
        protype = :POISON || 0
      when 20
        protype = :GROUND || 0
      when 21
        protype = :WATER || 0
      when 22
        protype = :WATER || 0
      when 23
        protype = :ROCK || 0
      when 24
        protype = :QMARKS || 0
      when 25
        rnd=@battle.pbRandom(4)
        case rnd
        when 0
          protype = :GRASS || 0
        when 1
          protype = :WATER || 0
        when 2
          protype = :FIRE || 0
        when 3
          protype = :PSYCHIC || 0
        end
      when 26
        protype = :POISON || 0
      when 27
        protype = :ROCK || 0
      when 28
        protype = :ICE || 0
      when 29
        protype = :NORMAL || 0
      when 30
        protype = :STEEL || 0
      when 31
        protype = :FAIRY || 0
      when 32
        protype = :DRAGON || 0
      when 33
        protype = :GRASS || 0
      when 34
        protype = :DARK || 0
      when 35
        rnd=@battle.pbRandom(18)
        case rnd
        when 0
          protype = :NORMAL || 0
        when 1
          protype = :WATER || 0
        when 2
          protype = :FIRE || 0
        when 3
          protype = :ELECTRIC || 0
        when 4
          protype = :GRASS || 0
        when 5
          protype = :ICE || 0
        when 6
          protype = :FIGHTING || 0
        when 7
          protype = :POISON || 0
        when 8
          protype = :GROUND || 0
        when 9
          protype = :PSYCHIC || 0
        when 10
          protype = :ROCK || 0
        when 11
          protype = :FLYING || 0
        when 12
          protype = :BUG || 0
        when 13
          protype = :GHOST || 0
        when 14
          protype = :DRAGON || 0
        when 15
          protype = :DARK || 0
        when 16
          protype = :STEEL || 0
        when 17
          protype = :FAIRY || 0
        end
      when 36
        protype = :NORMAL || 0
      when 37
        protype = :PSYCHIC || 0 
      when 38
        protype = :DARK || 0   
      when 39
        protype = :ICE || 0  
      when 40
        protype = :GHOST || 0  
      when 41
        protype = :POISON || 0  
      when 42
        protype = :FAIRY || 0
      when 43
        protype = :FLYING || 0
      when 44
        protype = :STEEL || 0
      when 45
        protype = :FIRE || 0
      end
      prot1 = self.type1
      prot2 = self.type2 
      camotype = getConst(PBTypes,protype) || 0
      if camotype>0 && (!self.pbHasType?(camotype) || (defined?(prot2) && prot1 != prot2))
        self.type1=camotype
        self.type2=camotype
        typename=PBTypes.getName(camotype)
        @battle.pbDisplay(_INTL("{1} had its type changed to {2}!",pbThis,typename))
      end
    end
    # Pastel Veil
    if self.hasWorkingAbility(:PASTELVEIL) && $fefieldeffect!=45 && onactive
      if self.pbPartner.status == PBStatuses::POISON
        pbDisplay(_INTL("{1}'s Pastel Veil cured its partner's poison problem!",i.pbThis))
      end
      self.pbPartner.status=0
      self.pbPartner.statusCount=0
    end
    # Intimidate
    if self.hasWorkingAbility(:INTIMIDATE) && onactive
      for i in 0...4
        if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
          @battle.battlers[i].pbReduceAttackStatStageIntimidate(self)
        end
      end
    end
    # Intimidate
    if self.hasWorkingAbility(:INTIMIDATE2) && onactive
      for i in 0...4
        if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
          @battle.battlers[i].pbReduceAttackStatStageIntimidate(self)
        end
      end
    end
    # Download
    if (self.hasWorkingAbility(:DOWNLOAD) ||  @battle.SilvallyCheck(self,PBTypes::ELECTRIC)) && onactive
      odef=ospdef=0
      odef+=pbOpposing1.defense if pbOpposing1.hp>0
      ospdef+=pbOpposing1.spdef if pbOpposing1.hp>0
      if pbOpposing2
        odef+=pbOpposing2.defense if pbOpposing2.hp>0
        ospdef+=pbOpposing1.spdef if pbOpposing2.hp>0
      end
      if ospdef>odef
        if !pbTooHigh?(PBStats::ATTACK)
          if $fefieldeffect == 17
            pbIncreaseStatBasic(PBStats::ATTACK,2)
            @battle.pbDisplay(_INTL("{1}'s {2} sharply boosted its Attack!",
                pbThis,PBAbilities.getName(ability)))
          else
            pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battle.pbDisplay(_INTL("{1}'s {2} boosted its Attack!",
                pbThis,PBAbilities.getName(ability)))
          end
        end
        if $fefieldeffect == 18 || $fefieldeffect == 24
          if !pbTooHigh?(PBStats::SPATK)
              pbIncreaseStatBasic(PBStats::SPATK,1)
              @battle.pbDisplay(_INTL("{1}'s {2} boosted its SpecialAttack!",
                  pbThis,PBAbilities.getName(ability)))
          end
        end
      else
        if !pbTooHigh?(PBStats::SPATK)
          if $fefieldeffect == 17
            pbIncreaseStatBasic(PBStats::SPATK,2)
            @battle.pbDisplay(_INTL("{1}'s {2} sharply boosted its Special Attack!",
                pbThis,PBAbilities.getName(ability)))
          else
            pbIncreaseStatBasic(PBStats::SPATK,1)
            @battle.pbDisplay(_INTL("{1}'s {2} boosted its Special Attack!",
                pbThis,PBAbilities.getName(ability)))
          end
        end
        if $fefieldeffect == 18 || $fefieldeffect == 24
          if !pbTooHigh?(PBStats::ATTACK)
              pbIncreaseStatBasic(PBStats::ATTACK,1)
              @battle.pbDisplay(_INTL("{1}'s {2} boosted its Attack!",
                  pbThis,PBAbilities.getName(ability)))
          end
        end
      end
    end
    # Screen Cleaner
    if self.hasWorkingAbility(:SCREENCLEANER) && onactive
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
    if self.hasWorkingAbility(:DAUNTLESSSHIELD) && onactive
      if !pbTooHigh?(PBStats::DEFENSE)
        pbIncreaseStatBasic(PBStats::DEFENSE,1)
        @battle.pbDisplay(_INTL("{1}'s {2} boosted its Defense!",
            pbThis,PBAbilities.getName(ability)))
      end
    end
    # Intrepid Sword
    if self.hasWorkingAbility(:INTREPIDSWORD) && onactive
      if !pbTooHigh?(PBStats::ATTACK)
        pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbDisplay(_INTL("{1}'s {2} boosted its Attack!",
            pbThis,PBAbilities.getName(ability)))
      end
    end
    # Mirror Field Entry
    if $fefieldeffect == 30
      if !pbTooHigh?(PBStats::EVASION)
        if (self.hasWorkingAbility(:SNOWCLOAK) || self.hasWorkingAbility(:SANDVEIL) ||
            self.hasWorkingAbility(:TANGLEDFEET) || self.hasWorkingAbility(:MAGICBOUNCE) ||
            @battle.SilvallyCheck(self, "psychic") || 
            self.hasWorkingAbility(:COLORCHANGE)) && onactive
          pbIncreaseStatBasic(PBStats::EVASION,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} boosted its Evasion!",
              pbThis,PBAbilities.getName(ability)))
        elsif self.hasWorkingAbility(:ILLUSION)
          pbIncreaseStatBasic(PBStats::EVASION,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s ability boosted its Evasion!",
              pbThis,PBAbilities.getName(ability)))
        end        
        if (self.hasWorkingItem(:BRIGHTPOWDER) || 
            self.hasWorkingItem(:LAXINCENSE)) && onactive
          pbIncreaseStatBasic(PBStats::EVASION,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s item boosted its Evasion!",
              pbThis,PBAbilities.getName(ability)))
        end    
      end
      # Illuminate
      if self.hasWorkingAbility(:ILLUMINATE) && onactive
        for i in 0...4
          if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
            @battle.battlers[i].pbReduceIlluminate(self)
          end
        end
      end
    end
    # Fairy Tale Field Entry
    if $fefieldeffect == 31
      if !pbTooHigh?(PBStats::DEFENSE)
        if (self.hasWorkingAbility(:BATTLEARMOR) || self.hasWorkingAbility(:SHELLARMOR) || 
            self.hasWorkingAbility(:POWEROFALCHEMY) || self.hasWorkingAbility(:MIRRORARMOR)
            self.hasWorkingAbility(:DAUNTLESSSHIELD)) && onactive
          @battle.pbCommonAnimation("StatUp",self,nil)
          if self.hasWorkingAbility(:MIRRORARMOR)
            pbIncreaseStatBasic(PBStats::SPDEF,1)
            @battle.pbDisplay(_INTL("{1}'s shining armor boosted its Special Defense!",pbThis,PBAbilities.getName(ability)))
          elsif self.hasWorkingAbility(:DAUNTLESSSHIELD) 
            pbIncreaseStatBasic(PBStats::DEFENSE,1)
            @battle.pbDisplay(_INTL("{1}'s blessed shield boosted its Defense!",pbThis,PBAbilities.getName(ability)))
          else
            pbIncreaseStatBasic(PBStats::DEFENSE,1)
            @battle.pbDisplay(_INTL("{1}'s shining armor boosted its Defense!",pbThis,PBAbilities.getName(ability)))
          end
        end     
        if ((!self.abilitynulled && self.ability == PBAbilities::STANCECHANGE)) && onactive
          @battle.pbCommonAnimation("StatUp",self,nil)
          pbIncreaseStatBasic(PBStats::DEFENSE,1)
        end
      end
      if !pbTooHigh?(PBStats::SPDEF)
        if (self.hasWorkingAbility(:MAGICGUARD) || self.hasWorkingAbility(:MAGICBOUNCE) || 
            self.hasWorkingAbility(:POWEROFALCHEMY) || 
            self.hasWorkingAbility(:PASTELVEIL) ||
            self.hasWorkingAbility(:DAUNTLESSSHIELD) || @battle.SilvallyCheck(self,PBTypes::PSYCHIC)) && onactive
          pbIncreaseStatBasic(PBStats::SPDEF,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s magical power boosted its Special Defense!",
              pbThis,PBAbilities.getName(ability)))
        end     
      end
      if !pbTooHigh?(PBStats::ATTACK)
        if (self.hasWorkingAbility(:INTREPIDSWORD)) && onactive
          pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s magical power boosted its Attack!",
              pbThis,PBAbilities.getName(ability)))
        end     
      end
      if !pbTooHigh?(PBStats::SPATK)
        if (self.hasWorkingAbility(:MAGICIAN) || self.hasWorkingAbility(:INTREPIDSWORD)) && onactive
          pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s magical power boosted its Special Attack!",
              pbThis,PBAbilities.getName(ability)))
        end     
      end
    end
    # Chess Board Entry  
    if $fefieldeffect == 5  
      if (self.hasWorkingAbility(:STALL)) && onactive  
        @battle.pbDisplay(_INTL("{1}'s Stall boosted its defenses!",  
            pbThis,PBAbilities.getName(ability)))  
        if !pbTooHigh?(PBStats::DEFENSE)  
          pbIncreaseStatBasic(PBStats::DEFENSE,1)  
          @battle.pbCommonAnimation("StatUp",self,nil)  
        end  
      end  
    end
    if isConst?(self.species,PBSpecies,:VESPIQUEN) && isConst?(self.item,PBItems,:VESPICREST) && onactive  
      self.effects[PBEffects::VespiCrest]  = 1
      pbIncreaseStatBasic(PBStats::ATTACK,1)  
      pbIncreaseStatBasic(PBStats::SPATK,1)  
    end
    # Dragon's Den Entry
    if $fefieldeffect == 32
      if (self.hasWorkingAbility(:MAGMAARMOR)) && onactive
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
      if (self.hasWorkingAbility(:SHELLARMOR)) && onactive
        @battle.pbDisplay(_INTL("{1}'s Shell Armor boosted its Defense!",
            pbThis,PBAbilities.getName(ability)))
        if !pbTooHigh?(PBStats::DEFENSE)
          pbIncreaseStatBasic(PBStats::DEFENSE,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
        end   
      end
    end
    # Flower Garden Entry
    if $fefieldeffect == 33
      tempcounter = $fecounter
      if (self.hasWorkingAbility(:FLOWERGIFT) || 
          self.hasWorkingAbility(:FLOWERVEIL) || 
          @battle.SilvallyCheck(self, "grass") ||
          self.hasWorkingAbility(:DROUGHT) || 
          self.hasWorkingAbility(:DRIZZLE)) && onactive
        $fecounter+=1 if $fecounter < 4
      end
      if tempcounter < $fecounter
        @battle.pbChangeBGSprite
        @battle.pbDisplay(_INTL("{1}'s {2} caused the garden to grow a little bit!",
            pbThis,PBAbilities.getName(ability)))
      end
    end
    # Starlight Arena Entry
    if $fefieldeffect == 34
      if !pbTooHigh?(PBStats::SPATK)
        if (self.hasWorkingAbility(:ILLUMINATE)) && onactive
          pbIncreaseStatBasic(PBStats::SPATK,2)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} flared up with starlight!",
              pbThis,PBAbilities.getName(ability)))
          if self.pbPartner.hasWorkingAbility(:MIRRORARMOR)
            self.pbPartner.effects[PBEffects::FollowMe]=true
            @battle.pbAnimation(getConst(PBMoves,:SPOTLIGHT),self,self.pbPartner)
            @battle.pbDisplay(_INTL("{1}'s dazzling shine put a spotlight on its partner!",
            pbThis))
          end
        end     
      end
    end
    # Psychic Terrain Entry
    if $fefieldeffect == 37 || @battle.field.effects[PBEffects::PsychicTerrain]>0
      if !pbTooHigh?(PBStats::SPATK)
        if (self.hasWorkingAbility(:ANTICIPATION) || self.hasWorkingAbility(:FOREWARN)) && onactive
          if $fefieldeffect==37
            pbIncreaseStatBasic(PBStats::SPATK,2)
          elsif @battle.field.effects[PBEffects::PsychicTerrain]>0 && self.hasWorkingAbility(:ANTICIPATION)
            pbIncreaseStatBasic(PBStats::SPATK,1)
          end
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!",
              pbThis,PBAbilities.getName(ability)))
        end
      end
    end  
    # Electric Terrain Entry
    if $fefieldeffect == 1 || @battle.field.effects[PBEffects::ElectricTerrain]>0
      if !pbTooHigh?(PBStats::SPEED)
        if (self.hasWorkingAbility(:STEADFAST)) && onactive
          pbIncreaseStatBasic(PBStats::SPEED,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",
              pbThis,PBAbilities.getName(ability)))
        end
      end
    end      
    # Misty Terrain + Corrosive Mist Entry
    if $fefieldeffect == 3 || @battle.field.effects[PBEffects::MistyTerrain]>0 || $fefieldeffect == 11
      if !pbTooHigh?(PBStats::DEFENSE)
        if (self.hasWorkingAbility(:WATERCOMPACTION)) && onactive
          pbIncreaseStatBasic(PBStats::DEFENSE,2)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s Water Compaction sharply raised its defense!",
              pbThis,PBAbilities.getName(ability)))
        end     
      end
    end
    # Dimensional + Frozen Dimensional + Haunted Entry
    if $fefieldeffect == 38 || $fefieldeffect == 39 || $fefieldeffect == 40
      if !pbTooHigh?(PBStats::SPEED)
        if (self.hasWorkingAbility(:RATTLED)) && onactive
          pbIncreaseStatBasic(PBStats::SPEED,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s Rattled raised its speed!",
              pbThis,PBAbilities.getName(ability)))
        end     
      end
    end
    # Sky Field Entry
    if $fefieldeffect == 43
      if !pbTooHigh?(PBStats::DEFENSE)
        if (self.hasWorkingAbility(:BIGPECKS)) && onactive
          pbIncreaseStatBasic(PBStats::DEFENSE,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its defense in the skies!",
              pbThis,PBAbilities.getName(ability)))
        end     
      end
      if !pbTooHigh?(PBStats::SPEED)
        if (self.hasWorkingAbility(:LEVITATE) || self.hasWorkingAbility(:SOLARIDOL) || self.hasWorkingAbility(:LUNARIDOL)) && onactive
          pbIncreaseStatBasic(PBStats::SPEED,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} made it go faster in the open skies!",
              pbThis,PBAbilities.getName(ability)))
        end
      end
      if self.hasWorkingAbility(:CLOUDNINE) && @battle.pbWeather!=0
        @battle.pbWeather == 0
        @battle.pbDisplay(_INTL("{1}'s {2} removed all weather effects!",
            pbThis,PBAbilities.getName(ability)))
      end
    end
    # Colosseum Field Entry  
    if $fefieldeffect == 44  
      if !pbTooHigh?(PBStats::DEFENSE)  
        if (self.hasWorkingAbility(:DAUNTLESSSHIELD) || self.hasWorkingAbility(:BATTLEARMOR) ||  
            self.hasWorkingAbility(:SHELLARMOR)) && onactive  
          pbIncreaseStatBasic(PBStats::DEFENSE,1)  
          @battle.pbCommonAnimation("StatUp",self,nil)  
          @battle.pbDisplay(_INTL("{1}'s shining armor boosted its Defense!",  
              pbThis,PBAbilities.getName(ability)))  
        end       
      end  
      if !pbTooHigh?(PBStats::SPDEF)  
        if (self.hasWorkingAbility(:DAUNTLESSSHIELD) || self.hasWorkingAbility(:MIRRORARMOR) ||  
            self.hasWorkingAbility(:MAGICGUARD)) && onactive  
          pbIncreaseStatBasic(PBStats::SPDEF,1)  
          @battle.pbCommonAnimation("StatUp",self,nil)  
          @battle.pbDisplay(_INTL("{1}'s magical power boosted its Special Defense!",  
              pbThis,PBAbilities.getName(ability)))  
        end       
      end  
      if !pbTooHigh?(PBStats::ATTACK)  
        if (self.hasWorkingAbility(:INTREPIDSWORD) || self.hasWorkingAbility(:NOGUARD) ||  
            self.hasWorkingAbility(:JUSTIFIED)) && onactive  
          pbIncreaseStatBasic(PBStats::ATTACK,1)  
          @battle.pbCommonAnimation("StatUp",self,nil)  
          @battle.pbDisplay(_INTL("{1}'s ferocious heart boosted its Attack!",  
              pbThis,PBAbilities.getName(ability)))  
        end       
      end  
      if !pbTooHigh?(PBStats::SPATK)  
        if (self.hasWorkingAbility(:INTREPIDSWORD) || self.hasWorkingAbility(:NOGUARD) ||  
            self.hasWorkingAbility(:JUSTIFIED)) && onactive  
          pbIncreaseStatBasic(PBStats::SPATK,1)  
          @battle.pbCommonAnimation("StatUp",self,nil)  
          @battle.pbDisplay(_INTL("{1}'s ferocious heart boosted its Special Attack!",  
              pbThis,PBAbilities.getName(ability)))  
        end       
      end  
    end  
    # Infernal Field Entry  
    if $fefieldeffect == 45  
      if !pbTooHigh?(PBStats::DEFENSE)  
        if (self.hasWorkingAbility(:MAGMAARMOR) || self.hasWorkingAbility(:FLAMEBODY) ||  
            self.hasWorkingAbility(:DESOLATELAND)) && onactive  
          pbIncreaseStatBasic(PBStats::DEFENSE,1)  
          @battle.pbCommonAnimation("StatUp",self,nil)  
          @battle.pbDisplay(_INTL("{1}'s armor boosted its Defense!",  
              pbThis,PBAbilities.getName(ability)))  
        end       
      end  
      if !pbTooHigh?(PBStats::SPDEF)  
        if (self.hasWorkingAbility(:MAGMAARMOR) || self.hasWorkingAbility(:FLAMEBODY) ||  
            self.hasWorkingAbility(:DESOLATELAND)) && onactive  
          pbIncreaseStatBasic(PBStats::SPDEF,1)  
          @battle.pbCommonAnimation("StatUp",self,nil)  
          @battle.pbDisplay(_INTL("{1}'s armor boosted its Special Defense!",  
              pbThis,PBAbilities.getName(ability)))  
        end       
      end  
    end
    # Frisk
    if (self.hasWorkingAbility(:FRISK) && @battle.pbOwnedByPlayer?(@index) && onactive) 
      foes=[]
      foes.push(pbOpposing1) if pbOpposing1.item>0 && !pbOpposing1.isFainted?
      foes.push(pbOpposing2) if pbOpposing2.item>0 && !pbOpposing2.isFainted?
      for i in foes
        itemname=PBItems.getName(i.item)
        @battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",pbThis,i.pbThis(true),itemname))
      end
    end
    # Anticipation
    if self.hasWorkingAbility(:ANTICIPATION) && @battle.pbOwnedByPlayer?(@index) && onactive
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
    if self.hasWorkingAbility(:UNNERVE) && onactive
      if @battle.pbOwnedByPlayer?(@index)
        @battle.pbDisplay(_INTL("The opposing team is too nervous to eat berries!",pbThis))
      elsif !@battle.pbOwnedByPlayer?(@index)
        @battle.pbDisplay(_INTL("Your team is too nervous to eat berries!",pbThis))
      end
    end
    # Forewarn
    if self.hasWorkingAbility(:FOREWARN) && @battle.pbOwnedByPlayer?(@index) && onactive
      highpower=0
      moves=[]
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.isFainted?
        for j in foe.moves
          movedata=PBMoveData.new(j.id)
          power=movedata.basedamage
          power=160 if movedata.function==0x70    # OHKO
          power=150 if movedata.function==0x8B    # Eruption
          power=120 if movedata.function==0x71 || # Counter
          movedata.function==0x72 || # Mirror Coat
          movedata.function==0x73 || # Metal Burst
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
            moves=[j.id]; highpower=power
          elsif power==highpower
            moves.push(j.id)
          end
        end
      end
      if moves.length>0
        move=moves[@battle.pbRandom(moves.length)]
        movename=PBMoves.getName(move)
        @battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",pbThis,movename))
        if (self.index==0 || self.index==2) && !@battle.isOnline? # Move memory system for AI
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
    if !(self.abilityWorks?)
       self.abilitynulled = true 
    else
      self.abilitynulled = false
    end
    # Imposter
    if self.hasWorkingAbility(:IMPOSTER) && !@effects[PBEffects::Transform] &&
      onactive && ((@battle.doublebattle && pbOppositeOpposing.pbPartner.hp>0) || (!@battle.doublebattle && pbOppositeOpposing.hp>0)) # !@effects[PBEffects::Illusion]
      if !@battle.doublebattle
        choice=pbOppositeOpposing
      else
        choice=pbOppositeOpposing.pbPartner
      end
      blacklist=[
        0xC9,    # Fly
        0xCA,    # Dig
        0xCB,    # Dive
        0xCC,    # Bounce
        0xCD,    # Shadow Force
        0xCE     # Sky Drop
      ]
      if choice.effects[PBEffects::Substitute]>0 ||
        choice.effects[PBEffects::Transform] ||
        choice.effects[PBEffects::SkyDrop] || choice.isBoss ||
        blacklist.include?(PBMoveData.new(choice.effects[PBEffects::TwoTurnAttack]).function)
        # Can't transform into chosen Pokémon, so forget it
      else
        @battle.pbAnimation(getConst(PBMoves,:TRANSFORM),self,choice)
        @effects[PBEffects::Transform]=true
        @species=choice.species
        @type1=choice.type1
        @type2=choice.type2
        @ability=choice.ability
        irregularcopy=choice.clone
        totalev=0
        for k in 0...6
          totalev+=choice.ev[k]
        end
        if totalev>510
          ev1=0
          ev2=0
          count=0
          for i in choice.ev
            if i==choice.ev.max
              ev1=count
            elsif i==choice.ev.max_nth(2)
              ev2=count
            end
            count+=1
          end
          stat1=choice.ev.max
          stat2=choice.ev.max_nth(2)                  
          for i in 1...6
            irregularcopy.ev[i]=0
          end
          if stat1>252
            irregularcopy.ev[ev1]=252 
          else
            irregularcopy.ev[ev1]=stat1
          end
          if stat2>252
            irregularcopy.ev[ev2]=252 
          else
            irregularcopy.ev[ev2]=stat2
          end    
        else
          for i in 1...6
            if irregularcopy.ev[i]>252
              irregularcopy.ev[i]=252
            end
          end    
        end
        irregularcopy.pbUpdate(true)
        @attack=irregularcopy.attack
        @defense=irregularcopy.defense
        @speed=irregularcopy.speed
        @spatk=irregularcopy.spatk
        @spdef=irregularcopy.spdef        
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
            PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
          @stages[i]=choice.stages[i]
        end
        for i in 0...4
          @moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(choice.moves[i].id),self)
          @moves[i].pp=5
          @moves[i].totalpp=5
        end
        @effects[PBEffects::Disable]=0
        @effects[PBEffects::DisableMove]=0
        @battle.pbDisplay(_INTL("{1} transformed into {2}!",pbThis,choice.pbThis(true)))
      end
    end
  end
  def pbEffectsOnDealingDamage(move,user,target,damage,innards)
    movetype=move.pbType(move.type,user,target)
    if damage>0 && move.isContactMove? && !user.hasWorkingAbility(:LONGREACH) && 
      !(user.hasWorkingItem(:PROTECTIVEPADS) || target.hasWorkingItem(:PROTECTIVEPADS))
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
          @battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
              target.pbThis,PBItems.getName(user.item),user.pbThis(true)))
        end
        if target.hasWorkingItem(:ROCKYHELMET,true) && !user.isFainted? &&
          !user.hasWorkingAbility(:MAGICGUARD) && !(user.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/6).floor)
          @battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,
              PBItems.getName(target.item)))
        end
        if target.effects[PBEffects::BeakBlast] && user.pbCanBurn?(false) &&
          !user.hasWorkingAbility(:MAGICGUARD) && !(user.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
          user.pbBurn(target)
          @battle.pbDisplay(_INTL("{1} was burned by the heat!",user.pbThis))
        end
        if target.hasWorkingAbility(:AFTERMATH,true) && !user.isFainted? && !user.isBoss &&
          target.hp <= 0 && !@battle.pbCheckGlobalAbility(:DAMP)  &&
          !user.hasWorkingAbility(:MAGICGUARD) && !(user.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
          PBDebug.log("[#{user.pbThis} hurt by Aftermath]")
          @battle.scene.pbDamageAnimation(user,0)
          #### AME - 006 - START
          if $fefieldeffect == 11
            user.pbReduceHP((user.totalhp/2).floor)
            @battle.pbDisplay(_INTL("{1} was caught in the toxic aftermath!",user.pbThis))
          else
            user.pbReduceHP((user.totalhp/4).floor)
            @battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
          end
          #### AME - 006 - END
        end     
        if target.hasWorkingAbility(:CUTECHARM) && @battle.pbRandom(10)<3
          if !user.hasWorkingAbility(:OBLIVIOUS) &&
            ((user.gender==1 && target.gender==0) ||
              (user.gender==0 && target.gender==1)) &&
            user.effects[PBEffects::Attract]<0 && !user.isFainted?
            user.effects[PBEffects::Attract]=target.index
            @battle.pbDisplay(_INTL("{1}'s {2} infatuated {3}!",target.pbThis,
                PBAbilities.getName(target.ability),user.pbThis(true)))
            if user.hasWorkingItem(:DESTINYKNOT) &&
              !target.hasWorkingAbility(:OBLIVIOUS) &&
              target.effects[PBEffects::Attract]<0
              target.effects[PBEffects::Attract]=user.index
              @battle.pbDisplay(_INTL("{1}'s {2} infatuated {3}!",user.pbThis,
                  PBItems.getName(user.item),target.pbThis(true)))
            end
          end
        end
        # UPDATE 11/16/2013
        eschance = 3
        eschance = 6 if ($fefieldeffect == 15 || $fefieldeffect == 19 || $fefieldeffect == 41 || $fefieldeffect == 42)
        eschance.to_i 
        if !user.pbHasType?(:GRASS) && !user.hasWorkingAbility(:OVERCOAT) && target.ability == PBAbilities::EFFECTSPORE && @battle.pbRandom(10) < eschance
          rnd=@battle.pbRandom(3)
          if rnd==0 && user.pbCanPoison?(false)
            user.pbPoison(target)
            @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
                PBAbilities.getName(target.ability),user.pbThis(true)))
          elsif rnd==1 && user.pbCanSleep?(false)
            user.pbSleep
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} sleep!",target.pbThis,
                PBAbilities.getName(target.ability),user.pbThis(true)))
          elsif rnd==2 && user.pbCanParalyze?(false)
            user.pbParalyze(target)
            @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
                target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:FLAMEBODY,true) && $fefieldeffect!=39 &&
          @battle.pbRandom(10)<3 && user.pbCanBurn?(false)
          user.pbBurn(target)
          @battle.pbDisplay(_INTL("{1}'s {2} burned {3}!",target.pbThis,
              PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:IRONBARBS,true) && !user.isFainted? &&
          !user.hasWorkingAbility(:MAGICGUARD) && !(user.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/8).floor)
          @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
              PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if (target.hasWorkingAbility(:MUMMY,true) || @battle.SilvallyCheck(target,PBTypes::GHOST)) && !user.isFainted? && !user.isBoss
          if !isConst?(user.ability,PBAbilities,:MULTITYPE) && !((PBStuff::FIXEDABILITIES).include?(user.ability))
            user.ability=getConst(PBAbilities,:MUMMY) || 0
            @battle.pbDisplay(_INTL("{1} was mummified by {2}!",
                user.pbThis,target.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:WANDERINGSPIRIT,true) && !user.isFainted? && !user.isBoss
          if !isConst?(user.ability,PBAbilities,:WANDERINGSPIRIT) && !((PBStuff::FIXEDABILITIES).include?(user.ability))
            tmp=user.ability
            user.ability=target.ability
            target.ability=tmp
            @battle.pbDisplay(_INTL("{1} swapped its {2} Ability with its target!",
                target.pbThis,PBAbilities.getName(target.ability)))
            user.pbAbilitiesOnSwitchIn(true)
            target.pbAbilitiesOnSwitchIn(true)
          end
        end
        if target.hasWorkingAbility(:GOOEY,true) 
          if user.hasWorkingAbility(:CONTRARY)
            if $fefieldeffect == 8 || $fefieldeffect == 26
              user.pbReduceStat(PBStats::SPEED,2,false,nil,nil,true,false,false,false)
              @battle.pbDisplay(_INTL("{1}'s {2} sharply boosted {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            else
              user.pbReduceStat(PBStats::SPEED,1,false,nil,nil,true,false,false,false)
              @battle.pbDisplay(_INTL("{1}'s {2} boosted {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            end
          elsif user.hasWorkingAbility(:WHITESMOKE) || user.hasWorkingAbility(:CLEARBODY) || 
            user.hasWorkingAbility(:FULLMETALBODY) || user.hasWorkingAbility(:TEMPORALSHIFT)
            @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",user.pbThis,PBAbilities.getName(user.ability)))
          elsif $fefieldeffect == 8 || $fefieldeffect == 26
            user.pbReduceStat(PBStats::SPEED,2,false,nil,nil,true,false,false,false)
            @battle.pbDisplay(_INTL("{1}'s {2} harshly lowered {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
          else
            user.pbReduceStat(PBStats::SPEED,1,false,nil,nil,true,false,false,false)
            @battle.pbDisplay(_INTL("{1}'s {2} lowered {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
          end
          if $fefieldeffect ==19 && user.pbCanPoison?(false)
            user.pbPoison(target)
            @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
                PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:TANGLINGHAIR,true) 
          if user.hasWorkingAbility(:CONTRARY)
            user.pbReduceStat(PBStats::SPEED,1,false,nil,nil,true,false,false,false)
            @battle.pbDisplay(_INTL("{1}'s {2} boosted {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
          elsif user.hasWorkingAbility(:WHITESMOKE) || user.hasWorkingAbility(:CLEARBODY) || 
            user.hasWorkingAbility(:FULLMETALBODY) || user.hasWorkingAbility(:TEMPORALSHIFT)
            @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",user.pbThis,PBAbilities.getName(user.ability)))
          else
            user.pbReduceStat(PBStats::SPEED,1,false,nil,nil,true,false,false,false)
            @battle.pbDisplay(_INTL("{1}'s {2} lowered {3}'s Speed!",target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end        
        eschance = 3
        eschance = 6 if ($fefieldeffect == 19 || $fefieldeffect == 41)
        eschance.to_i  
        if target.ability == PBAbilities::POISONPOINT && @battle.pbRandom(10) < eschance && user.pbCanPoison?(false)
          user.pbPoison(target)
          @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis, PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:ROUGHSKIN,true) && !user.isFainted? && !user.hasWorkingAbility(:MAGICGUARD) && !(user.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/8).floor)
          @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
              PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        eschance = 3
        eschance = 6 if $fefieldeffect == 18
        eschance.to_i 
        if target.hasWorkingAbility(:STATIC,true) && 
          @battle.pbRandom(10) < eschance && user.pbCanParalyze?(false)
          user.pbParalyze(target)
          @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
              target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:PICKPOCKET) &&
          !target.hasWorkingAbility(:OBLIVIOUS) &&
          !(target.hasWorkingAbility(:SHEERFORCE) || @battle.SilvallyCheck(target,PBTypes::GROUND))
          if target.item==0 && user.item>0 &&
            user.effects[PBEffects::Substitute]==0 &&
            target.effects[PBEffects::Substitute]==0 &&
            !user.hasWorkingAbility(:STICKYHOLD) &&
            !@battle.pbIsUnlosableItem(user,user.item) &&
            !@battle.pbIsUnlosableItem(target,user.item) &&
            (@battle.opponent || !@battle.pbIsOpposing?(target.index))
            target.item=user.item
            user.item=0
            if @battle.pbIsWild? &&   # In a wild battle
              target.pokemon.itemInitial==0 &&
              user.pokemon.itemInitial==target.item
              target.pokemon.itemInitial=target.item
              user.pokemon.itemInitial=0
            end
            @battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
                user.pbThis(true),PBItems.getName(target.item)))
          end
        end
      end
      if user.hasWorkingAbility(:POISONTOUCH,true) && target.pbCanPoison?(false) &&
        (@battle.pbRandom(10)<3 || (@battle.pbRandom(10)<6 && $fefieldeffect==41))
        target.pbPoison(user)
        @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",user.pbThis,
            PBAbilities.getName(user.ability),target.pbThis(true)))
      end
      if target.hasWorkingAbility(:PERISHBODY,true) && !$fefieldeffect==29 &&
        user.effects[PBEffects::PerishSong]==0 && target.effects[PBEffects::PerishSong]==0
        @battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
        if $fefieldeffect == 45  
          user.effects[PBEffects::PerishSong]=2  
          target.effects[PBEffects::PerishSong]=2  
        else  
          user.effects[PBEffects::PerishSong]=4  
          target.effects[PBEffects::PerishSong]=4  
        end  
        if $fefieldeffect == 38 || $fefieldeffect == 40 || $fefieldeffect == 45
          target.effects[PBEffects::MeanLook]=user.index
          @battle.pbDisplay(_INTL("{1} can't escape now!",target.pbThis))
        end
      end
    end
    if damage>0
      if target.effects[PBEffects::ShellTrap] && move.pbIsPhysical?(movetype)
        target.effects[PBEffects::ShellTrap]=false
      end        
      if target.hasWorkingAbility(:INNARDSOUT,true) && !user.isFainted? && !user.isBoss &&
        target.hp <= 0 && !user.hasWorkingAbility(:MAGICGUARD) && !(user.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
        PBDebug.log("[#{user.pbThis} hurt by Innards Out]")
        @battle.scene.pbDamageAnimation(user,0)
        user.pbReduceHP(innards)
        @battle.pbDisplay(_INTL("{1} was hurt by {2}'s innards!",user.pbThis,target.pbThis))
      end         
      if (user.hasWorkingAbility(:MOXIE) || @battle.SilvallyCheck(user, PBTypes::FIRE)) && 
        user.hp>0 && target.hp<=0
        if !user.pbTooHigh?(PBStats::ATTACK)
          @battle.pbCommonAnimation("StatUp",self,nil)
          user.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbDisplay(_INTL("{1}'s Moxie raised its Attack!",user.pbThis))
        end
      end
      if user.hasWorkingAbility(:EXECUTION) && 
        user.hp>0 && target.hp<=0
        hpgain=(damage/8).floor
        hpgain=user.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1}'s Execution healed some of its wounds!",user.pbThis))
      end
      if user.hasWorkingAbility(:BEASTBOOST) && user.hp>0 && target.hp<=0
        increment = 1
        increment = 2 if $fefieldeffect == 38
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
            user.pbIncreaseStatBasic(PBStats::ATTACK,increment)
            @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Attack!",user.pbThis))
          end
        when dBoost
          if !user.pbTooHigh?(PBStats::DEFENSE)
            @battle.pbCommonAnimation("StatUp",self,nil)
            user.pbIncreaseStatBasic(PBStats::DEFENSE,increment)
            @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Defense!",user.pbThis))
          end        
        when saBoost
          if !user.pbTooHigh?(PBStats::SPATK)
            @battle.pbCommonAnimation("StatUp",self,nil)
            user.pbIncreaseStatBasic(PBStats::SPATK,increment)
            @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Special Attack!",user.pbThis))
          end            
        when sdBoost
          if !user.pbTooHigh?(PBStats::SPDEF)
            @battle.pbCommonAnimation("StatUp",self,nil)
            user.pbIncreaseStatBasic(PBStats::SPDEF,increment)
            @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Special Defense!",user.pbThis))
          end 
        when spdBoost
          if !user.pbTooHigh?(PBStats::SPEED)
            @battle.pbCommonAnimation("StatUp",self,nil)
            user.pbIncreaseStatBasic(PBStats::SPEED,increment)
            @battle.pbDisplay(_INTL("{1}'s Beast Boost raised its Speed!",user.pbThis))
          end
        end
      end
      if $fefieldeffect == 44 && user.hp>0 && target.hp<=0  
        aBoost = target.attack  
        dBoost = target.defense  
        saBoost = target.spatk  
        sdBoost = target.spdef  
        spdBoost = target.speed  
        boostStat = [aBoost,dBoost,saBoost,sdBoost,spdBoost].max  
        case boostStat  
        when aBoost              
          if !user.pbTooHigh?(PBStats::ATTACK)  
            @battle.pbCommonAnimation("StatUp",self,nil)  
            user.pbIncreaseStatBasic(PBStats::ATTACK,increment)  
            @battle.pbDisplay(_INTL("The cheering audience raised {1}'s Attack!",user.pbThis))  
          end  
        when dBoost  
          if !user.pbTooHigh?(PBStats::DEFENSE)  
            @battle.pbCommonAnimation("StatUp",self,nil)  
            user.pbIncreaseStatBasic(PBStats::DEFENSE,increment)  
            @battle.pbDisplay(_INTL("The cheering audience raised {1}'s Defense!",user.pbThis))  
          end          
        when saBoost  
          if !user.pbTooHigh?(PBStats::SPATK)  
            @battle.pbCommonAnimation("StatUp",self,nil)  
            user.pbIncreaseStatBasic(PBStats::SPATK,increment)  
            @battle.pbDisplay(_INTL("The cheering audience raised {1}'s Special Attack!",user.pbThis))  
          end              
        when sdBoost  
          if !user.pbTooHigh?(PBStats::SPDEF)  
            @battle.pbCommonAnimation("StatUp",self,nil)  
            user.pbIncreaseStatBasic(PBStats::SPDEF,increment)  
            @battle.pbDisplay(_INTL("The cheering audience raised {1}'s Special Defense!",user.pbThis))  
          end   
        when spdBoost  
          if !user.pbTooHigh?(PBStats::SPEED)  
            @battle.pbCommonAnimation("StatUp",self,nil)  
            user.pbIncreaseStatBasic(PBStats::SPEED,increment)  
            @battle.pbDisplay(_INTL("The cheering audience raised {1}'s Speed!",user.pbThis))  
          end  
        end          
      end
      if !target.damagestate.substitute
        if target.hasWorkingAbility(:CURSEDBODY,true) && (@battle.pbRandom(10)<3 || target.isFainted? && $fefieldeffect == 40)
          if $fefieldeffect != 29
            if user.effects[PBEffects::Disable]<=0 && move.pp>0 && !user.isFainted?
              user.effects[PBEffects::Disable]=4
              user.effects[PBEffects::DisableMove]=move.id
              @battle.pbDisplay(_INTL("{1}'s {2} disabled {3}!",target.pbThis,
                  PBAbilities.getName(target.ability),user.pbThis(true)))
            end
          end
        end
        if target.hasWorkingAbility(:GULPMISSILE,true) && isConst?(target.species, PBSpecies, :CRAMORANT) && !user.isFainted? &&
          !user.hasWorkingAbility(:MAGICGUARD) && !(user.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44) && target.form!=0
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/4).floor)
          if target.form==1 # Gulping Form
            if user.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
              user.pbReduceStatBasic(PBStats::DEFENSE,1)
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
        if isConst?(target.species,PBSpecies,:BEHEEYEM) && target.hasWorkingItem(:BEHECREST,true)
          if user.effects[PBEffects::Disable]<=0 && move.pp>0 && !user.isFainted?
            user.effects[PBEffects::Disable]=4
            user.effects[PBEffects::DisableMove]=move.id
            @battle.pbDisplay(_INTL("{1}'s {2} disabled {3}!",target.pbThis,
                PBItems.getName(target.item),user.pbThis(true)))
          end
        end
        # Illusion goes here
        #### JERICHO - 001 - START
        if isConst?(target.ability,PBAbilities,:ILLUSION) #ILLUSION
          if target.effects[PBEffects::Illusion]!=nil
            # Break the illusion
            # Animation should go here
            target.effects[PBEffects::Illusion]=nil
            @battle.scene.pbChangePokemon(target,target.pokemon)
            @battle.pbDisplay(_INTL("{1}'s {2} was broken!",target.pbThis,
                PBAbilities.getName(target.ability)))
          end
        end #ILLUSION
        #### JERICHO - 001 - END
        if target.hasWorkingAbility(:JUSTIFIED) &&
          isConst?(movetype,PBTypes,:DARK)
          if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
            if $fefieldeffect == 29
              target.pbIncreaseStatBasic(PBStats::ATTACK,2)
            else
              target.pbIncreaseStatBasic(PBStats::ATTACK,1)
            end
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",
                target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if user.hasWorkingAbility(:MAGICIAN) && target.damagestate.calcdamage>0 &&
          !target.damagestate.substitute && target.item!=0
          if target.hasWorkingAbility(:STICKYHOLD)
            abilityname=PBAbilities.getName(target.ability(true))
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,abilityname,@name))
          elsif !@battle.pbIsUnlosableItem(target,target.item) &&
            !@battle.pbIsUnlosableItem(user,user.item) &&
            user.item==0 &&
            (target || !pbIsOpposing?(user.index))
            itemname=PBItems.getName(target.item)
            user.item=target.item
            target.item=0
            target.effects[PBEffects::ChoiceBand]=-1
            if @battle.pbIsWild? && # In a wild battle
              user.pokemon.itemInitial==0 &&
              target.pokemon.itemInitial==user.item
              user.pokemon.itemInitial=user.item
              target.pokemon.itemInitial=0
            end
            @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,target.pbThis(true),itemname))
          end
        end
        if target.hasWorkingAbility(:RATTLED) &&
          (isConst?(movetype,PBTypes,:BUG) ||
            isConst?(movetype,PBTypes,:DARK) ||
            isConst?(movetype,PBTypes,:GHOST))
          if target.pbCanIncreaseStatStage?(PBStats::SPEED)
            target.pbIncreaseStatBasic(PBStats::SPEED,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!",
                target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:WEAKARMOR) && move.pbIsPhysical?(movetype)
          if target.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
            target.pbReduceStatBasic(PBStats::DEFENSE,1)
            @battle.pbCommonAnimation("StatDown",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} lowered its Defense!",
                target.pbThis,PBAbilities.getName(target.ability)))
          end
          if target.pbCanIncreaseStatStage?(PBStats::SPEED)
            target.pbIncreaseStatBasic(PBStats::SPEED,2)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Speed!",
                target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:STAMINA)
          if target.pbCanIncreaseStatStage?(PBStats::DEFENSE)
            target.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Defense!",
                target.pbThis,PBAbilities.getName(target.ability)))
          end
        end   
        if target.hasWorkingAbility(:WATERCOMPACTION) && isConst?(movetype,PBTypes,:WATER)
          if $fefieldeffect!=20
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
            @battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Defense and Special Defense!",
                target.pbThis,PBAbilities.getName(target.ability))) if boost
          end          
        end        
      end
      # Steam Engine
      if target.hasWorkingAbility(:STEAMENGINE) && 
        (isConst?(movetype,PBTypes,:WATER) || isConst?(movetype,PBTypes,:FIRE))
        if target.pbCanIncreaseStatStage?(PBStats::SPEED)
          target.pbIncreaseStatBasic(PBStats::SPEED,6)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} drastically raised its Speed!",
              target.pbThis,PBAbilities.getName(target.ability)))
        end
      end
      # Cotton Down
      if target.hasWorkingAbility(:COTTONDOWN,true)
        @battle.pbDisplay(_INTL("{1}'s {2} scatters cotton around!",
            target.pbThis,PBAbilities.getName(target.ability)))
        for i in @battle.battlers
          next if i==target
          if i.pbCanReduceStatStage?(PBStats::SPEED)
            boost = 1
            if ($fefieldeffect == 2 || $fefieldeffect == 42)
              boost = 2
            end
            i.pbReduceStat(PBStats::SPEED,boost,false)
          end
        end
      end
      # Sand Spit
      if target.hasWorkingAbility(:SANDSPIT,true)
        if !(@battle.field.effects[PBEffects::HeavyRain] || @battle.field.effects[PBEffects::HarshSunlight] ||
            @battle.weather==PBWeather::STRONGWINDS || @battle.weather==PBWeather::SANDSTORM ||
            $fefieldeffect==35)
          @battle.pbAnimation(getConst(PBMoves,:SANDSTORM),self,nil)
          @battle.weather=PBWeather::SANDSTORM
          @battle.weatherduration=5
          @battle.weatherduration=8 if (target.hasWorkingItem(:SMOOTHROCK) ||
            $fefieldeffect == 12 || $fefieldeffect == 20 || $fefieldeffect == 43)
          @battle.pbCommonAnimation("Sandstorm",nil,nil)
          @battle.pbDisplay(_INTL("A sandstorm brewed!"))
        end
        if ($fefieldeffect == 12 || $fefieldeffect == 20) && user.pbCanReduceStatStage?(PBStats::ACCURACY)
          user.pbReduceStatBasic(PBStats::ACCURACY,1)
          @battle.pbCommonAnimation("StatDown",user,nil)
          @battle.pbDisplay(_INTL("{1}'s accuracy fell!",user.pbThis))
        end
      end
      if target.hasWorkingItem(:AIRBALLOON,true)
        target.pokemon.itemRecycle=target.item
        target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
        target.item=0
        @battle.pbDisplay(_INTL("{1}'s Air Balloon popped!",target.pbThis))
      end
      if target.hasWorkingItem(:ABSORBBULB) && isConst?(movetype,PBTypes,:WATER)
        if target.pbCanIncreaseStatStage?(PBStats::SPATK)
          target.pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!",
              target.pbThis,PBItems.getName(target.item)))
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
      end
      if target.hasWorkingItem(:CELLBATTERY) && isConst?(movetype,PBTypes,:ELECTRIC)
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
          target.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",
              target.pbThis,PBItems.getName(target.item)))
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
      end
      if target.hasWorkingItem(:SNOWBALL) &&
        isConst?(movetype,PBTypes,:ICE)
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
          target.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",
              target.pbThis,PBItems.getName(target.item)))
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
      end
      if target.hasWorkingItem(:LUMINOUSMOSS) &&
        isConst?(movetype,PBTypes,:WATER)
        if target.pbCanIncreaseStatStage?(PBStats::SPDEF)
          target.pbIncreaseStatBasic(PBStats::SPDEF,1)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Defense!",
              target.pbThis,PBItems.getName(target.item)))
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
      end
      #### JERICHO - 007 - START
      if target.hasWorkingItem(:KEEBERRY) && move.pbIsPhysical?(movetype)
        #### JERICHO - 007 - END          
        if target.pbCanIncreaseStatStage?(PBStats::DEFENSE)
          target.pbIncreaseStatBasic(PBStats::DEFENSE,1)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Defense!",
              target.pbThis,PBItems.getName(target.item)))
          berryconsumed = true
          $belch=true             
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
      end
      #### JERICHO - 007 - START
      if target.hasWorkingItem(:MARANGABERRY) && move.pbIsSpecial?(movetype)
        #### JERICHO - 007 - END          
        if target.pbCanIncreaseStatStage?(PBStats::SPDEF)
          target.pbIncreaseStatBasic(PBStats::SPDEF,1)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Defense!",
              target.pbThis,PBItems.getName(target.item)))
          berryconsumed = true
          $belch=true             
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
      end
      #### JERICHO - 012 - START
      if target.hasWorkingItem(:JABOCABERRY,true) && !user.isFainted? && move.pbIsPhysical?(movetype) &&
        @battle.scene.pbDamageAnimation(user,0)
        if target.hasWorkingAbility(:RIPEN)
          user.pbReduceHP((user.totalhp/4).floor)
        else
          user.pbReduceHP((user.totalhp/8).floor)
        end
        @battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,
            PBItems.getName(target.item)))
        berryconsumed = true
        $belch=true
        target.pokemon.itemRecycle=target.item
        target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
        target.item=0
      end
      if target.hasWorkingItem(:ROWAPBERRY,true) && !user.isFainted? && move.pbIsSpecial?(movetype) &&
        @battle.scene.pbDamageAnimation(user,0)
        if target.hasWorkingAbility(:RIPEN)
          user.pbReduceHP((user.totalhp/4).floor)
        else
          user.pbReduceHP((user.totalhp/8).floor)
        end
        @battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,
            PBItems.getName(target.item)))
        berryconsumed = true
        $belch=true
        target.pokemon.itemRecycle=target.item
        target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
        target.item=0
      end
      #### JERICHO - 012 - END
      if target.hasWorkingItem(:WEAKNESSPOLICY) && target.damagestate.typemod>4
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
          target.pbIncreaseStatBasic(PBStats::ATTACK,2)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} sharply raised its Attack!",
              target.pbThis,PBItems.getName(target.item)))
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
        if target.pbCanIncreaseStatStage?(PBStats::SPATK)
          target.pbIncreaseStatBasic(PBStats::SPATK,2)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s Weakness Policy sharply raised its Special Attack!",
              target.pbThis,PBItems.getName(target.item)))
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
      end      
      if target.hasWorkingAbility(:ANGERPOINT)
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK) &&
          target.damagestate.critical
          target.stages[PBStats::ATTACK]=6
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} maxed its Attack!",
              target.pbThis,PBAbilities.getName(target.ability)))
        end
      end
      if target.hasWorkingItem(:REDCARD) && !target.damagestate.substitute &&
        !(@battle.pbIsWild? && (@battle.pbParty(user.index) == @battle.party2))
        choices = []
        party=@battle.pbParty(user.index)
        for i in 0...party.length
          choices[choices.length]=i if @battle.pbCanSwitchLax?(user.index,i,false)
        end
        if choices.length!=0
          @battle.pbDisplay(_INTL("#{target.pbThis}'s Red Card activates!")) 
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
          if user.hasWorkingAbility(:SUCTIONCUPS)
            @battle.pbDisplay(_INTL("{1} anchored itself with {2}!",user.pbThis,PBAbilities.getName(user.ability)))  
          elsif user.effects[PBEffects::Ingrain]
            @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",user.pbThis))  
          else
            user.forcedSwitch = true
            # newpoke=choices[@battle.pbRandom(choices.length)]
            # user.pbResetForm
            # @battle.pbReplace(user.index,newpoke,false)
            # @battle.pbDisplay(_INTL("{1} was dragged out!",user.pbThis))
            # @battle.pbOnActiveOne(user)
            # user.pbAbilitiesOnSwitchIn(true)
          end
        end 
      end
      if target.hasWorkingItem(:EJECTBUTTON) && !target.damagestate.substitute
        if !target.isFainted? && @battle.pbCanChooseNonActive?(target.index) &&
          !@battle.pbAllFainted?(@battle.pbParty(target.index))
          @battle.pbDisplay(_INTL("#{target.pbThis}'s Eject Button activates!"))    
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
          # @battle.pbDisplay(_INTL("{1} went back to {2}!",target.pbThis,@battle.pbGetOwner(target.index).name))
          @battle.pbClearChoices(target.index)
          target.userSwitch = true
          # newpoke=0
          # newpoke=@battle.pbSwitchInBetween(target.index,true,false)
          # @battle.pbMessagesOnReplace(target.index,newpoke)
          # @battle.pbRecallAndReplace(target.index,newpoke,true)
          # target.pbResetForm
          # @battle.pbOnActiveOne(target)
          # target.pbAbilitiesOnSwitchIn(true)
        end
      end
      # Record that Red Card/Eject Button triggered
      # Knock Off's effect(?)
    end
    user.pbAbilityCureCheck
    target.pbAbilityCureCheck
    # Synchronize here
    s=@battle.synchronize[0]
    t=@battle.synchronize[1]
    #   PBDebug.log("[synchronize: #{@battle.synchronize.inspect}]")
    if s>=0 && t>=0 && @battle.battlers[s].hasWorkingAbility(:SYNCHRONIZE) &&
      @battle.synchronize[2]>0 && !@battle.battlers[t].isFainted?
      # see [2024281]&0xF0, [202420C]
      sbattler=@battle.battlers[s]
      tbattler=@battle.battlers[t]
      if @battle.synchronize[2]==PBStatuses::POISON &&
        tbattler.pbCanPoisonSynchronize?(sbattler)
        # UPDATE 11/17/2013
        # allows for transfering of `badly poisoned` instead of just poison.
        #changed from: tbattler.pbPoison(sbattler)
        tbattler.pbPoison(sbattler, sbattler.statusCount == 1)
        @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",sbattler.pbThis,
            PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      elsif @battle.synchronize[2]==PBStatuses::BURN &&
        tbattler.pbCanBurnSynchronize?(sbattler)
        tbattler.pbBurn(sbattler)
        @battle.pbDisplay(_INTL("{1}'s {2} burned {3}!",sbattler.pbThis,
            PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      elsif @battle.synchronize[2]==PBStatuses::PARALYSIS &&
        tbattler.pbCanParalyzeSynchronize?(sbattler)
        tbattler.pbParalyze(sbattler)
        @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
            sbattler.pbThis,PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      end
    end
  end
  
  def pbAbilityCureCheck
    return if self.isFainted?
    if self.hasWorkingAbility(:LIMBER) && self.status==PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1}'s Limber cured its paralysis problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:OBLIVIOUS) && @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1}'s Oblivious cured its love problem!",pbThis))
      @effects[PBEffects::Attract]=-1
    end
    if self.hasWorkingAbility(:VITALSPIRIT) && self.status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1}'s Vital Spirit cured its sleep problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:INSOMNIA) && self.status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1}'s Insomnia cured its sleep problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:IMMUNITY) && self.status==PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1}'s Immunity cured its poison problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:OWNTEMPO) && @effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1}'s Own Tempo cured its confusion problem!",pbThis))
      @effects[PBEffects::Confusion]=0
    end
    if self.hasWorkingAbility(:MAGMAARMOR) && self.status==PBStatuses::FROZEN && $fefieldeffect!=39
      @battle.pbDisplay(_INTL("{1}'s Magma Armor cured its ice problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:WATERVEIL) && self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1}'s Water Veil cured its burn problem!",pbThis))
      self.status=0
    end
  end
  
  ################################################################################
  # Held item effects
  ################################################################################
  berryconsumed = false
  def pbConfusionBerry(symbol,flavor,message1,message2)
    if isConst?(self.item,PBItems,symbol) && ((self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) || self.hp<=(self.totalhp/4).floor)
      if self.hasWorkingAbility(:RIPEN)
        pbRecoverHP(((2*self.totalhp)/3).floor,true)
      else
        pbRecoverHP((self.totalhp/3).floor,true)
      end
      @battle.pbDisplay(message1)
      if (self.nature%5) == flavor && (self.nature/5).floor != (self.nature%5)
        @battle.pbDisplay(message2)
        if @effects[PBEffects::Confusion]==0 && !self.hasWorkingAbility(:OWNTEMPO)
          @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
          @battle.pbCommonAnimation("Confusion",self,nil)
          @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
        end
      end
      @pokemon.itemRecycle=self.item
      @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
      self.item=0
    end
  end
  
  def pbStatIncreasingBerry(symbol,stat,message)
    if isConst?(self.item,PBItems,symbol) && !self.pbTooHigh?(stat)
      if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
        self.hp<=(self.totalhp/4).floor
        #### JERICHO - 010 - START         
        @battle.pbCommonAnimation("StatUp",self,nil)
        #### JERICHO - 010 - END
        if self.hasWorkingAbility(:RIPEN)
          pbIncreaseStatBasic(stat,2)
        else
          pbIncreaseStatBasic(stat,1)
        end
        @battle.pbDisplay(message)
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
    end
  end
  
  def pbBerryCureCheck(hpcure=false)
    return if self.isFainted?
    unnerver=(pbOpposing1.hasWorkingAbility(:UNNERVE) ||
      pbOpposing2.hasWorkingAbility(:UNNERVE))
    itemname=(self.item==0) ? "" : PBItems.getName(self.item)
    if self.hasWorkingItem(:BERRYJUICE) && self.hp<=(self.totalhp/2).floor && 
      @effects[PBEffects::HealBlock]==0
      self.pbRecoverHP(20,true)
      @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
      @pokemon.itemRecycle=self.item
      $belch=true
      @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
      self.item=0
    end        
    if !unnerver
      if self.hasWorkingItem(:ORANBERRY) && self.hp<=(self.totalhp/2).floor && 
        @effects[PBEffects::HealBlock]==0
        berryconsumed = true
        if self.hasWorkingAbility(:RIPEN)
          self.pbRecoverHP(20,true)
        else
          self.pbRecoverHP(10,true)
        end
        @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      if self.hasWorkingItem(:SITRUSBERRY) && self.hp<=(self.totalhp/2).floor && 
        @effects[PBEffects::HealBlock]==0
        berryconsumed = true
        if self.hasWorkingAbility(:RIPEN)
          self.pbRecoverHP((self.totalhp/2).floor,true)
        else
          self.pbRecoverHP((self.totalhp/4).floor,true)
        end
        @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      #### JERICHO - 014 - START        
      if self.hasWorkingItem(:ENIGMABERRY) && self.damagestate.typemod>4 && 
        @effects[PBEffects::HealBlock]==0
        berryconsumed = true
        if self.hasWorkingAbility(:RIPEN)
          self.pbRecoverHP((self.totalhp/2).floor,true)
        else
          self.pbRecoverHP((self.totalhp/4).floor,true)
        end
        @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      #### JERICHO - 014 - END        
      if self.hasWorkingItem(:CHERIBERRY) && self.status==PBStatuses::PARALYSIS
        berryconsumed = true
        self.status=0
        @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis problem!",pbThis,itemname))
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      if self.hasWorkingItem(:CHESTOBERRY) && self.status==PBStatuses::SLEEP
        berryconsumed = true
        self.status=0
        @battle.pbDisplay(_INTL("{1}'s {2} cured its sleep problem!",pbThis,itemname))
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      if self.hasWorkingItem(:PECHABERRY) && self.status==PBStatuses::POISON
        berryconsumed = true
        self.status=0
        @battle.pbDisplay(_INTL("{1}'s {2} cured its poison problem!",pbThis,itemname))
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      if self.hasWorkingItem(:RAWSTBERRY) && self.status==PBStatuses::BURN
        berryconsumed = true
        self.status=0
        @battle.pbDisplay(_INTL("{1}'s {2} cured its burn problem!",pbThis,itemname))
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      if self.hasWorkingItem(:ASPEARBERRY) && self.status==PBStatuses::FROZEN
        berryconsumed = true
        self.status=0
        @battle.pbDisplay(_INTL("{1}'s {2} cured its ice problem!",pbThis,itemname))
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      if self.hasWorkingItem(:LEPPABERRY)
        berryconsumed = true
        for i in 0...@pokemon.moves.length
          pokemove=@pokemon.moves[i]
          battlermove=self.moves[i]
          if pokemove.pp==0 && pokemove.id!=0
            movename=PBMoves.getName(pokemove.id)
            pokemove.pp=10
            pokemove.pp=pokemove.totalpp if pokemove.pp>pokemove.totalpp 
            battlermove.pp=pokemove.pp
            @battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s PP!",pbThis,itemname,movename)) 
            @pokemon.itemRecycle=self.item
            $belch=true
            @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
            self.item=0
            break
          end
        end
      end
      if self.hasWorkingItem(:PERSIMBERRY) && @effects[PBEffects::Confusion]>0
        berryconsumed = true
        @effects[PBEffects::Confusion]=0
        @battle.pbDisplay(_INTL("{1}'s {2} cured its confusion problem!",pbThis,itemname))
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      if self.hasWorkingItem(:LUMBERRY) && (self.status>0 || @effects[PBEffects::Confusion]>0)
        berryconsumed = true
        st=self.status; conf=@effects[PBEffects::Confusion]
        self.status=0
        @effects[PBEffects::Confusion]=0
        if conf>0
          @battle.pbDisplay(_INTL("{1}'s {2} cured its confusion problem!",pbThis,itemname))
        else
          case st
          when PBStatuses::PARALYSIS
            @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis problem!",pbThis,itemname))
          when PBStatuses::SLEEP
            @battle.pbDisplay(_INTL("{1}'s {2} cured its sleep problem!",pbThis,itemname))
          when PBStatuses::POISON
            @battle.pbDisplay(_INTL("{1}'s {2} cured its poison problem!",pbThis,itemname))
          when PBStatuses::BURN
            @battle.pbDisplay(_INTL("{1}'s {2} cured its burn problem!",pbThis,itemname))
          when PBStatuses::FROZEN
            @battle.pbDisplay(_INTL("{1}'s {2} cured its frozen problem!",pbThis,itemname))
          end
        end
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      pbConfusionBerry(:FIGYBERRY,0,
        _INTL("{1}'s {2} restored health!",pbThis,itemname),
        _INTL("For {1}, the {2} was too spicy!",pbThis(true),itemname))
      pbConfusionBerry(:WIKIBERRY,3,
        _INTL("{1}'s {2} restored health!",pbThis,itemname),
        _INTL("For {1}, the {2} was too dry!",pbThis(true),itemname))
      pbConfusionBerry(:MAGOBERRY,2,
        _INTL("{1}'s {2} restored health!",pbThis,itemname),
        _INTL("For {1}, the {2} was too sweet!",pbThis(true),itemname))
      pbConfusionBerry(:AGUAVBERRY,4,
        _INTL("{1}'s {2} restored health!",pbThis,itemname),
        _INTL("For {1}, the {2} was too bitter!",pbThis(true),itemname))
      pbConfusionBerry(:IAPAPABERRY,1,
        _INTL("{1}'s {2} restored health!",pbThis,itemname),
        _INTL("For {1}, the {2} was too sour!",pbThis(true),itemname))
      pbStatIncreasingBerry(:LIECHIBERRY,PBStats::ATTACK,
        _INTL("Using its {1}, the Attack of {2} rose!",itemname,pbThis(true)))
      pbStatIncreasingBerry(:GANLONBERRY,PBStats::DEFENSE,
        _INTL("Using its {1}, the Defense of {2} rose!",itemname,pbThis(true)))
      pbStatIncreasingBerry(:SALACBERRY,PBStats::SPEED,
        _INTL("Using its {1}, the Speed of {2} rose!",itemname,pbThis(true)))
      pbStatIncreasingBerry(:PETAYABERRY,PBStats::SPATK,
        _INTL("Using its {1}, the Special Attack of {2} rose!",itemname,pbThis(true)))
      pbStatIncreasingBerry(:APICOTBERRY,PBStats::SPDEF,
        _INTL("Using its {1}, the Special Defense of {2} rose!",itemname,pbThis(true)))
      if self.hasWorkingItem(:LANSATBERRY) && @effects[PBEffects::FocusEnergy]==0
        berryconsumed = true
        if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
          (self.hp<=(self.totalhp/4).floor)
          @battle.pbDisplay(_INTL("{1} used its {2} to get pumped!",pbThis,itemname))
          @effects[PBEffects::FocusEnergy]=2
          @pokemon.itemRecycle=self.item
          $belch=true
          @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
          self.item=0
        end
      end
      if self.hasWorkingItem(:STARFBERRY)
        berryconsumed = true
        if (self.hasWorkingAbility(:GLUTTONY) && 
            self.hp<=(self.totalhp/2).floor) || (self.hp<=(self.totalhp/4).floor)
          stats=[]
          messages=[]
          messages[PBStats::ATTACK]=_INTL("Using {1}, the Attack of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::DEFENSE]=_INTL("Using {1}, the Defense of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::SPEED]=_INTL("Using {1}, the Speed of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::SPATK]=_INTL("Using {1}, the Special Attack of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::SPDEF]=_INTL("Using {1}, the Special Defense of {2} rose sharply!",itemname,pbThis(true))
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
            stats[stats.length]=i if !pbTooHigh?(i)
          end
          if stats.length>0
            stat=stats[@battle.pbRandom(stats.length)]
            pbIncreaseStatBasic(stat,2)
            @battle.pbDisplay(messages[stat])
            @pokemon.itemRecycle=self.item
            $belch=true
            @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
            self.item=0
          end
        end
      end
      if berryconsumed && self.hasWorkingAbility(:CHEEKPOUCH) && 
        @effects[PBEffects::HealBlock]==0
        self.pbRecoverHP((self.totalhp/3).floor,true)
        @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,PBAbilities.getName(self.ability)))
        berryconsumed = false
      end
    end
    if self.hasWorkingItem(:WHITEHERB)
      reducedstats=false
      for i in [PBStats::ATTACK,PBStats::DEFENSE,
          PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
          PBStats::EVASION,PBStats::ACCURACY]
        if @stages[i]<0
          @stages[i]=0; reducedstats=true
        end
      end
      if reducedstats
        @battle.pbDisplay(_INTL("{1}'s {2} restored its status!",pbThis,itemname))
        @pokemon.itemRecycle=self.item
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
    end
    if self.hasWorkingItem(:MENTALHERB) &&
      (@effects[PBEffects::Attract]>=0 ||
        @effects[PBEffects::Taunt]>0 ||
        @effects[PBEffects::Encore]>0 ||
        @effects[PBEffects::Torment] ||
        @effects[PBEffects::Disable]>0)
      @battle.pbDisplay(_INTL("{1}'s {2} cured its love problem!",pbThis,itemname)) if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1} is taunted no more!",pbThis)) if @effects[PBEffects::Taunt]>0
      @battle.pbDisplay(_INTL("{1}'s encore ended!",pbThis)) if @effects[PBEffects::Encore]>0
      @battle.pbDisplay(_INTL("{1} is tormented no more!",pbThis)) if @effects[PBEffects::Torment]
      @battle.pbDisplay(_INTL("{1} is disabled no more!",pbThis)) if @effects[PBEffects::Disable]>0
      @effects[PBEffects::Attract]=-1
      @effects[PBEffects::Taunt]=0
      @effects[PBEffects::Encore]=0
      @effects[PBEffects::EncoreMove]=0
      @effects[PBEffects::EncoreIndex]=0
      @effects[PBEffects::Torment]=false
      @effects[PBEffects::Disable]=0
      @pokemon.itemRecycle=self.item
      @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
      self.item=0
    end
    if hpcure && self.hp!=self.totalhp && @effects[PBEffects::HealBlock]==0
      if (isConst?(self.species,PBSpecies,:INFERNAPE) && isConst?(self.item,PBItems,:INFCREST)) || self.hasWorkingItem(:LEFTOVERS)
        pbRecoverHP((self.totalhp/16).floor,true)
        @battle.pbDisplay(_INTL("{1}'s {2} restored its HP a little!",pbThis,itemname))
      end
    end
    if hpcure && isConst?(self.species,PBSpecies,:SPIRITOMB) && self.hasWorkingItem(:SPIRITCREST) && 
      self.hp!=self.totalhp
      enemyfainted = pbEnemyFaintedPokemonCount
      pbRecoverHP(((self.totalhp*enemyfainted)/20).floor,true)
      @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",pbThis,itemname))
    end
    
    if hpcure && self.hasWorkingItem(:BLACKSLUDGE)
      if pbHasType?(:POISON) && @effects[PBEffects::HealBlock]==0
        if self.hp!=self.totalhp
          hpgain = self.totalhp/16
          hpgain = self.totalhp/8 if $fefieldeffect == 41
          pbRecoverHP((hpgain).floor,true)
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP a little!",pbThis,itemname))
        end
      elsif !self.hasWorkingAbility(:MAGICGUARD) && !(self.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
        hploss = self.totalhp/8
        hploss = self.totalhp/4 if $fefieldeffect == 41
        pbReduceHP((hploss).floor,true)
        @battle.pbDisplay(_INTL("{1} was hurt by its {2}!",pbThis,itemname))
      end
      pbFaint if self.isFainted?
    end
  end
  
  def pbSpecialBerryUse(berry)
    if berry == 398
      berryconsumed=true
      pbItemRestoreHP(self,self.totalhp/4)
      @battle.pbDisplay(_INTL("{1} restored its HP!",pbThis))
    elsif berry == 397 && self.status!=0
      self.status=0
      self.statusCount=0
      @battle.pbDisplay(_INTL("{1} became healthy.",pbThis))      
    elsif berry == 389 && self.status!=PBStatuses::PARALYSIS
      berryconsumed=true
      self.status=0
      self.statusCount=0
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.",pbThis))
    elsif berry == 390 && self.status!=PBStatuses::SLEEP
      berryconsumed=true
      self.status=0
      self.statusCount=0
      @battle.pbDisplay(_INTL("{1} woke up.",pbThis)) 
    elsif berry == 391 && self.status!=PBStatuses::POISON  
      berryconsumed=true
      self.status=0
      self.statusCount=0
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",pbThis))  
    elsif berry == 392 && self.status!=PBStatuses::BURN   
      berryconsumed=true
      self.status=0
      self.statusCount=0
      @battle.pbDisplay(_INTL("{1}'s burn was healed.",pbThis))      
    elsif berry == 393 && self.status!=PBStatuses::FROZEN 
      berryconsumed=true
      self.status=0
      self.statusCount=0
      @battle.pbDisplay(_INTL("{1} was thawed out.",pbThis)) 
    elsif berry == 395
      berryconsumed=true
      pbItemRestoreHP(self,10)
      @battle.pbDisplay(_INTL("{1} restored its HP!",pbThis))  
    elsif berry == 396 && self.effects[PBEffects::Confusion]>0
      berryconsumed=true
      self.effects[PBEffects::Confusion]=0
      @battle.pbDisplay(_INTL("{1} snapped out of confusion.",pbThis))
    elsif berry == 399 
      berryconsumed=true
      pbConfusionBerry(:FIGYBERRY,0,
        _INTL("{1} restored health!",pbThis),
        _INTL("For {1}, the {2} was too spicy!",pbThis(true),PBItems.getName(berry)))     
    elsif berry == 400   
      berryconsumed=true
      pbConfusionBerry(:WIKIBERRY,3,
        _INTL("{1} restored health!",pbThis),
        _INTL("For {1}, the {2} was too dry!",pbThis(true),PBItems.getName(berry)))     
    elsif berry == 401
      berryconsumed=true
      pbConfusionBerry(:MAGOBERRY,2,
        _INTL("{1} restored health!",pbThis),
        _INTL("For {1}, the {2} was too sweet!",pbThis(true),PBItems.getName(berry)))      
    elsif berry == 402
      berryconsumed=true
      pbConfusionBerry(:AGUAVBERRY,4,
        _INTL("{1} restored health!",pbThis),
        _INTL("For {1}, the {2} was too bitter!",pbThis(true),PBItems.getName(berry)))
    elsif berry == 403
      berryconsumed=true
      pbConfusionBerry(:IAPAPABERRY,1,
        _INTL("{1} restored health!",pbThis),
        _INTL("For {1}, the {2} was too sour!",pbThis(true),PBItems.getName(berry)))      
    elsif berry == 441 && self.pbCanIncreaseStatStage?(PBStats::ATTACK)
      berryconsumed=true
      self.pbIncreaseStatBasic(PBStats::ATTACK,1)
      @battle.pbCommonAnimation("StatUp",self,nil)
      @battle.pbDisplay(_INTL("{1} raised its Attack!",pbThis))
    elsif berry == 442 && self.pbCanIncreaseStatStage?(PBStats::DEFENSE)
      berryconsumed=true
      self.pbIncreaseStatBasic(PBStats::DEFENSE,1)
      @battle.pbCommonAnimation("StatUp",self,nil)
      @battle.pbDisplay(_INTL("{1} raised its Defense!",pbThis)) 
    elsif berry == 443 && self.pbCanIncreaseStatStage?(PBStats::SPEED)  
      berryconsumed=true
      self.pbIncreaseStatBasic(PBStats::SPEED,1)
      @battle.pbCommonAnimation("StatUp",self,nil)
      @battle.pbDisplay(_INTL("{1} raised its Speed!",pbThis))  
    elsif berry == 444 && self.pbCanIncreaseStatStage?(PBStats::SPATK) 
      berryconsumed=true
      self.pbIncreaseStatBasic(PBStats::SPATK,1)
      @battle.pbCommonAnimation("StatUp",self,nil)
      @battle.pbDisplay(_INTL("{1} raised its Special Attack!",pbThis)) 
    elsif berry == 445 && self.pbCanIncreaseStatStage?(PBStats::SPDEF)  
      berryconsumed=true
      self.pbIncreaseStatBasic(PBStats::SPDEF,1)
      @battle.pbCommonAnimation("StatUp",self,nil)
      @battle.pbDisplay(_INTL("{1} raised its Special Defense!",pbThis))
    elsif berry == 446 && @effects[PBEffects::FocusEnergy]==0  
      berryconsumed=true
      @effects[PBEffects::FocusEnergy]=1 
      @battle.pbDisplay(_INTL("{1} is getting pumped!",pbThis)) 
    elsif berry == 447
      berryconsumed=true
      stats=[]
      messages=[]
      messages[PBStats::ATTACK]=_INTL("{1}'s Attack rose sharply!",pbThis)
      messages[PBStats::DEFENSE]=_INTL("{1}'s Defense rose sharply!",pbThis)
      messages[PBStats::SPEED]=_INTL("{1}'s Speed rose sharply!",pbThis)
      messages[PBStats::SPATK]=_INTL("{1}'s Special Attack rose sharply!",pbThis)
      messages[PBStats::SPDEF]=_INTL("{1}'s Special Defense rose sharply!",pbThis)
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
        stats[stats.length]=i if !pbTooHigh?(i)
      end
      if stats.length>0
        stat=stats[@battle.pbRandom(stats.length)]
        pbIncreaseStatBasic(stat,2)
        @battle.pbCommonAnimation("StatUp",self,nil)        
        @battle.pbDisplay(messages[stat])
      end      
    end
    if berryconsumed and self.hasWorkingAbility(:CHEEKPOUCH)
      self.pbRecoverHP((self.totalhp/3).floor,true)
      @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,PBAbilities.getName(self.ability)))
      berryconsumed = false
    end
  end  
  
  def pbCustapBerry
    if self.hasWorkingItem(:CUSTAPBERRY)
      if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
        (self.hp<=(self.totalhp/4).floor)
        @custap = true
        @battle.pbDisplay(_INTL("{1} ate its Custap berry to move first!",pbThis))
        @pokemon.itemRecycle=self.item
        $belch=true
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0    
        if self.hasWorkingAbility(:CHEEKPOUCH)
          self.pbRecoverHP((self.totalhp/3).floor,true)
          @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,PBAbilities.getName(self.ability)))          
        end
      end
    else
      @custap = false
    end
  end    
  
  ################################################################################
  # Move user and targets
  ################################################################################
  def pbFindUser(choice,targets,moveid=choice[2].id)
    move=choice[2]
    if (moveid== 792 && choice[3].class== PokeBattle_Battler)
      target=choice[3].index
    else
      if (moveid== 395 && self.hasWorkingAbility(:ACCUMULATION))
        target=choice[3].index
      elsif !(choice[3].is_a?(Integer))
        if choice[3].index==0
          target=2
        else
          target=0
        end
      else
        target=choice[3]
      end
    end
    user=self   # Normally, the user is self
    # Targets in normal cases
    if $fefieldeffect == 33 && $fecounter == 4 &&
      (move.id == 192 || move.id == 214 || move.id == 218 || 
        move.id == 219 || move.id == 220 || move.id == 445 || 
        move.id == 596 || move.id == 600)
      # Just pbOpposing1 because partner is determined late
      pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1) 
    elsif self.hasWorkingAbility(:WORLDOFNIGHTMARES) && (move.id == 188)
      pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1) 
    elsif $fefieldeffect == 40 && (move.id == 147 || move.id == 379)
      pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1) 
    elsif self.hasWorkingAbility(:TEMPEST) && (move.id == 304)
      pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1) 
    else
      case pbTarget(move)
      when PBTargets::SingleNonUser
        if moveid== 395 || target>=0 || moveid== 792 
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
        pbAddTarget(targets,pbOppositeOpposing) if !pbAddTarget(targets,pbOppositeOpposing2)
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
      when PBTargets::ThunderRaid
        randomThunder = move.pbThunderRaidTargetting(user)
        case randomThunder.length
        when 1
          pbAddTarget(targets,randomThunder[0])
        when 5
          pbAddTarget(targets,randomThunder[0])
          pbAddTarget(targets,randomThunder[1])
          pbAddTarget(targets,randomThunder[2])
          pbAddTarget(targets,randomThunder[3])
          pbAddTarget(targets,randomThunder[4])
        end
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
        if self.hasWorkingItem(:INTERCEPTZ2)
          if choice[1]==1 || choice[1]==3
            if target>=0 || moveid== 792
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
          else
            move.pbAddTarget(targets,self)
          end
        else
          move.pbAddTarget(targets,self)
        end
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
    elsif @battle.zMove[side][owner]==self.index && (move.pbIsPhysical?(move.type) || move.pbIsSpecial?(move.type))
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
    if thismove.function==0x179
      return true
    end
    priority=@battle.pbPriority
    changeeffect=0
    user=userandtarget[0]
    target=userandtarget[1]
    if (thismove.function==0x179) || user.hasWorkingAbility(:STALWART) || user.hasWorkingAbility(:PROPELLERTAIL)
      return true
    end
    # LightningRod here, considers Hidden Power as Normal
    # if movetype = Electric OR (if move = Revelation Dance AND usertype = Electric)
    if targets.length==1 && !target.hasWorkingAbility(:LIGHTNINGROD) &&
      (isConst?(thismove.type,PBTypes,:ELECTRIC) || 
        (thismove.name =="Revelation Dance" && isConst?(user.type1,PBTypes,:ELECTRIC)))
      for i in priority # use Pokémon earliest in priority
        #next if !pbIsOpposing?(i.index)
        if i.hasWorkingAbility(:LIGHTNINGROD) && i!=user
          target=i # X's LightningRod took the attack!
          changeeffect=1
          break
        end
      end
    end
    # Storm Drain here, considers Hidden Power as Normal
    if targets.length==1 && isConst?(thismove.type,PBTypes,:WATER) && 
      !target.hasWorkingAbility(:STORMDRAIN)
      for i in priority # use Pokémon earliest in priority
        next if !pbIsOpposing?(i.index)
        if i.hasWorkingAbility(:STORMDRAIN)
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
        next if !pbIsOpposing?(i.index)
        if i.effects[PBEffects::FollowMe]==true || i.effects[PBEffects::RagePowder]==true
          target=i unless (i.effects[PBEffects::RagePowder] && (self.hasWorkingAbility(:OVERCOAT) || self.pbHasType?(:GRASS) || self.hasWorkingItem(:SAFETYGOGGLES)))# change target to this
        end
      end
    end
    # TODO: Pressure here is incorrect if Magic Coat redirects target
    if target.hasWorkingAbility(:PRESSURE)
      pbReducePP(thismove) # Reduce PP
      if $fefieldeffect==38
        pbReducePP(thismove)
      end
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
            if $fefieldeffect==38
              pressuremove=user.moves[userchoice]
              pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
            end
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
      tmp=user
      user=target
      target=tmp
      # Magic Coat's PP is reduced if old user has Pressure
      userchoice=@battle.choices[user.index][1]
      if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
        pressuremove=user.moves[userchoice]
        pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
        if $fefieldeffect==38
          pressuremove=user.moves[userchoice]
          pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
        end
      end
    end
    if thismove.canMagicCoat? && (target.hasWorkingAbility(:MAGICBOUNCE) || @battle.SilvallyCheck(target, "psychic")) && !(target.moldbroken)
      target.effects[PBEffects::MagicBounced]=true
      # switch user and target
      changeeffect=4
      tmp=user
      user=target
      target=tmp
    end
    if changeeffect==1
      @battle.pbDisplay(_INTL("{1}'s Lightningrod took the move!",target.pbThis))
    elsif changeeffect==2
      @battle.pbDisplay(_INTL("{1}'s Storm Drain took the move!",target.pbThis))
    elsif changeeffect==3
      # Target refers to the move's old user
      @battle.pbDisplay(_INTL("{1}'s {2} was bounced back by Magic Coat!",user.pbThis,thismove.name))
    elsif changeeffect==4 && !(thismove.target==PBTargets::AllOpposing && (user.index==0 || user.index==1))
      # Target refers to the move's old user
      # UPDATE 11/17/2013
      # not a listed bug - but I came across it.
      # was previously stating the incorrect Pokemon name (not the one that bounced it back
      # but instead the one that received it).
      # changed from: @battle.pbDisplay(_INTL("{1} bounced the {2} back!",target.pbThis,thismove.name))
      @battle.pbDisplay(_INTL("{1} bounced the {2} back!",user.pbThis,thismove.name))
      if $fefieldeffect == 30
        if user.pbCanIncreaseStatStage?(PBStats::EVASION)
          user.pbIncreaseStatBasic(PBStats::EVASION,1)
          @battle.pbCommonAnimation("StatUp",user,nil)
          @battle.pbDisplay(_INTL("{1}'s Magic Bounce increased its evasion!",user.pbThis,thismove.name))
        end
      end
    end
    userandtarget[0]=user
    userandtarget[1]=target
    if thismove.zmove
      targets[0]=target
    end
    return true
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
    if @effects[PBEffects::TwoTurnAttack]>0 ||
      @effects[PBEffects::Bide]>0 || 
      @effects[PBEffects::Outrage]>0 ||
      @effects[PBEffects::Rollout]>0 ||
      @effects[PBEffects::HyperBeam]>0 ||
      @effects[PBEffects::Uproar]>0
      # No need to reduce PP if two-turn attack
      return true
    end
    return true if isBossPokemon?(self) # by SH
    return true if isBossPokemonInRiftForm?(self)
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
    if (@battle.pbOwnedByPlayer?(@index) && @battle.internalbattle) || (!@battle.pbOwnedByPlayer?(@index) && @index==@battle.battlers[2].index && isConst?(self.species,PBSpecies,:CHARIZARD) && $game_variables[246]==17)
      #### SARDINES - Disobedience - START
      levelLimits = [18, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 85, 90]
      badgelevel = levelLimits[@battle.pbPlayer.numbadges]
      #### SARDINES - Disobedience - END
      move=choice[2] 
      disobedient=false 
      if @level>badgelevel
        a=((@level+badgelevel)*@battle.pbRandom(256)/255).floor
        disobedient|=a<badgelevel
      end
      if self.respond_to?("pbHyperModeObedience")
        disobedient|=!self.pbHyperModeObedience(move)
      end
      if disobedient && !$game_switches[1235]
        @effects[PBEffects::Rage]=false
        if self.status==PBStatuses::SLEEP && 
          (move.function==0x11 || move.function==0xB4) # Snore, Sleep Talk
          @battle.pbDisplay(_INTL("{1} ignored orders while asleep!",pbThis)) 
          return false
        end
        b=((@level+badgelevel)*@battle.pbRandom(256)/255).floor
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
  
  
  def pbSuccessCheck(thismove,user,target,accuracy=true)
    if $fefieldeffect == 4
      if thismove.function==0xC4
        if @effects[PBEffects::TwoTurnAttack]>0
          @effects[PBEffects::TwoTurnAttack] = 0
        end
        @battle.pbDisplay(_INTL("But it failed...",target.pbThis))
        return false
      end
    end
    if $fefieldeffect == 5 && user.hasWorkingAbility(:KLUTZ)  
      if isConst?(@id,PBMoves,:PSYCHIC) || isConst?(@id,PBMoves,:STRENGTH) ||  
        isConst?(@id,PBMoves,:ANCIENTPOWER) || isConst?(@id,PBMoves,:BARRAGE) ||  
        isConst?(@id,PBMoves,:ROCKTHROW)  
        if @effects[PBEffects::TwoTurnAttack]>0  
          @effects[PBEffects::TwoTurnAttack] = 0  
        end  
        @battle.pbDisplay(_INTL("It was too much of a klutz to move the chess piece.",target.pbThis))  
        return false          
      end  
    end
    if $fefieldeffect == 12
      if thismove.function==0x61
        if @effects[PBEffects::TwoTurnAttack]>0
          @effects[PBEffects::TwoTurnAttack] = 0
        end
        @battle.pbDisplay(_INTL("But it failed...",target.pbThis))
        return false
      end
    end
    if $fefieldeffect == 24
      if thismove.function==0xEB
        if @effects[PBEffects::TwoTurnAttack]>0
          @effects[PBEffects::TwoTurnAttack] = 0
        end
        @battle.pbDisplay(_INTL("But it failed...",target.pbThis))
        return false
      end
    end
    if $fefieldeffect == 43
      if thismove.function==0x95 || thismove.function==0xCA ||
        thismove.function==0x151 || thismove.function==0x76
        if @effects[PBEffects::TwoTurnAttack]>0
          @effects[PBEffects::TwoTurnAttack] = 0
        end
        @battle.pbDisplay(_INTL("But it failed...",target.pbThis))
        return false
      end
    end
    if $fefieldeffect == 44  
      if thismove.fucnction==0xED || thismove.function==0xBC  
        if @effects[PBEffects::TwoTurnAttack]>0  
          @effects[PBEffects::TwoTurnAttack] = 0  
        end  
        @battle.pbDisplay(_INTL("But it failed...",target.pbThis))  
        return false  
      end  
    end
    
    if !(thismove.pbIsPhysical?(thismove.type) || thismove.pbIsSpecial?(thismove.type)) && 
      user.hasWorkingAbility(:PRANKSTER)
      if target.pbHasType?(:DARK) && $fefieldeffect!=42
        @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
        return false
      end
    end      
    if ((target.hasWorkingAbility(:DAZZLING) || 
          target.hasWorkingAbility(:QUEENLYMAJESTY)) && !target.moldbroken) ||
      $fefieldeffect == 37 && !(target.isAirborne?) || ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR) && !target.moldbroken) ||
      (target.pbPartner.hasWorkingAbility(:DAZZLING) || target.pbPartner.hasWorkingAbility(:QUEENLYMAJESTY)  || ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR)) && !target.moldbroken)
      if thismove.priority>0
        if ((target.hasWorkingAbility(:DAZZLING) || 
              target.hasWorkingAbility(:QUEENLYMAJESTY)) && !target.moldbroken) || 
              ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR) && !!target.moldbroken) ||
              (target.pbPartner.hasWorkingAbility(:DAZZLING) || target.pbPartner.hasWorkingAbility(:QUEENLYMAJESTY)  || ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR)) && !target.moldbroken)
        end
        @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
        return false
      elsif !(thismove.pbIsPhysical?(thismove.type) || thismove.pbIsSpecial?(thismove.type)) && 
        user.hasWorkingAbility(:PRANKSTER) && thismove.priority==0
        if ((target.hasWorkingAbility(:DAZZLING) || 
              target.hasWorkingAbility(:QUEENLYMAJESTY)) && !target.moldbroken) ||
               ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR) && !!target.moldbroken) ||
               (target.pbPartner.hasWorkingAbility(:DAZZLING) || target.pbPartner.hasWorkingAbility(:QUEENLYMAJESTY)  || ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR)) && !target.moldbroken)
          @battle.pbDisplay(_INTL("{1} activated!",PBAbilities.getName(target.ability)))
        end
        @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
        return false     
      elsif thismove.type==2 && ((user.hasWorkingAbility(:GALEWINGS) || @battle.SilvallyCheck(user, "flying")) && user.hp==user.totalhp) && thismove.priority>-1
        if ((target.hasWorkingAbility(:DAZZLING) || 
              target.hasWorkingAbility(:QUEENLYMAJESTY)) && !target.moldbroken) ||
             ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR) && !!target.moldbroken) ||
             (target.pbPartner.hasWorkingAbility(:DAZZLING) || target.pbPartner.hasWorkingAbility(:QUEENLYMAJESTY)  || ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR)) && !target.moldbroken)
          @battle.pbDisplay(_INTL("{1} activated!",PBAbilities.getName(target.ability)))
        end
        @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
        return false
      else
        healfunctions = [0xD5,0xD6,0xD7,0xD8,0xD9,0xDD,0xDE,0xDF,0xE3,0xE4,0x114,0x139,0x158,0x162,0x169,0x16C,0x172]
        if user.hasWorkingAbility(:TRIAGE)
          for j in healfunctions
            if thismove.function == j && (thismove.priority==0 || thismove.priority==-1 || thismove.priority==-2)
              if ((target.hasWorkingAbility(:DAZZLING) || 
                    target.hasWorkingAbility(:QUEENLYMAJESTY)) && !target.moldbroken) ||
                     ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR) && !!target.moldbroken) ||
                     (target.pbPartner.hasWorkingAbility(:DAZZLING) || target.pbPartner.hasWorkingAbility(:QUEENLYMAJESTY)  || ($fefieldeffect == 34 && target.hasWorkingAbility(:MIRRORARMOR)) && !target.moldbroken)
                @battle.pbDisplay(_INTL("{1} activated!",PBAbilities.getName(target.ability)))
              end
              @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
              return false
            end
          end
        end
      end
    end
    if user.effects[PBEffects::TwoTurnAttack]>0
      PBDebug.log("[Using two-turn attack]") if $INTERNAL
      self.missed = false
      return true
    end
    # TODO: "Before Protect" applies to Counter/Mirror Coat
    if thismove.function==0xDE && ((target.status!=PBStatuses::SLEEP && (!target.hasWorkingAbility(:COMATOSE) && $fefieldeffect!=1) && (!user.hasWorkingAbility(:WORLDOFNIGHTMARES))) || !(user.effects[PBEffects::HealBlock]==0))  # Dream Eater
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
    #### KUROTSUNE - 025 - START
    if !thismove.zmove # Z-Moves handle protection stuff elsewhere
      $fecounter=3 if $fefieldeffect == 13 && isConst?(thismove.id,PBMoves,:DIVE)
      if target.pbOwnSide.effects[PBEffects::MatBlock] && (isConst?(thismove.id,PBMoves,:PHANTOMFORCE) || isConst?(thismove.id,PBMoves,:SHADOWFORCE) ||
          isConst?(thismove.id,PBMoves,:HYPERSPACEHOLE) || isConst?(thismove.id,PBMoves,:HYPERSPACEFURY))
        @battle.pbDisplay(_INTL("The Mat Block was broken!"))
      end
      
      if target.pbOwnSide.effects[PBEffects::MatBlock] && (thismove.pbIsPhysical?(thismove.type) || thismove.pbIsSpecial?(thismove.type)) &&
        thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation]
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        @battle.successStates[user.index].protected=true
        return false
      end
      #### KUROTSUNE - 025 - END
      if target.effects[PBEffects::Protect] && thismove.canProtectAgainst? && thismove.function!=0x116 &&
        !target.effects[PBEffects::ProtectNegation]
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        @battle.successStates[user.index].protected=true
        return false
      end
      #### KUROTSUNE - 016 - START
      if target.pbOwnSide.effects[PBEffects::CraftyShield] && thismove.basedamage == 0 && !target.effects[PBEffects::ProtectNegation]
        @battle.pbDisplay(_INTL("{1}'s Crafty Shield activated!",target.pbThis))
        user.pbCancelMoves
        @battle.successStates[user.index].protected=true
        return false
      end
      #### KUROTSUNE - 016 - END      
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
      if target.pbOwnSide.effects[PBEffects::QuickGuard] && thismove.priority > 0 && thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation]
        @battle.pbDisplay(_INTL("{1}'s Quick Guard prevented damage!",target.pbThis))
        user.pbCancelMoves
        @battle.successStates[user.index].protected=true
        return false
      end
      # UPDATE 1/19/2014
      # King's Shield
      if target.effects[PBEffects::KingsShield] && ((thismove.basedamage > 0) || $fefieldeffect == 5 || $fefieldeffect == 31) && (!target.effects[PBEffects::ProtectNegation]) && (thismove.function!=0x116) && thismove.hasFlags?('b')
        @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
        @battle.successStates[user.index].protected=true
        # physical contact
        if thismove.hasFlags?('a') && !user.hasWorkingAbility(:LONGREACH)
          if ($fefieldeffect == 31 || $fefieldeffect == 44 )
            user.pbReduceStat(PBStats::ATTACK, 2, true)  
            user.pbReduceStat(PBStats::SPATK, 2, true)  
          else  
            user.pbReduceStat(PBStats::ATTACK, 2, true) 
          end
        end
        return false
      end # end of update
      # Spiky Shield
      if target.effects[PBEffects::SpikyShield] && 
        !target.effects[PBEffects::ProtectNegation] && thismove.canProtectAgainst? && thismove.function!=0x116
        @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
        @battle.successStates[user.index].protected=true
        # physical contact
        if thismove.hasFlags?('a') && !user.hasWorkingAbility(:LONGREACH)
          #@scene.pbDamageAnimation(user,0) TODO: Fix animation
          if user.effects[PBEffects::ShieldLife]>0
            spikydamage=user.totalhp/8
            @battle.pbShieldDamage(user,spikydamage)
          else
            if $fefieldeffect == 44  
              user.pbReduceHP((user.totalhp/4).floor)  
            else  
              user.pbReduceHP((user.totalhp/8).floor)  
            end
          end
        end
        return false
      end
      # Obstruct
      if target.effects[PBEffects::Obstruct] && !target.effects[PBEffects::ProtectNegation] && thismove.canProtectAgainst?  && thismove.function!=0x116 && ((thismove.basedamage > 0) || $fefieldeffect == 5 || $fefieldeffect == 38)
        @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
        @battle.successStates[user.index].protected=true
        # physical contact
        if thismove.hasFlags?('a') && !user.hasWorkingAbility(:LONGREACH)# && !(thismove.id==PBMoves::SACREDSWORD && $fefieldeffect==31)
          user.pbReduceStat(PBStats::DEFENSE,2,true)  
        end
        return false
      end
      # Baneful Bunker
      if target.effects[PBEffects::BanefulBunker] && 
        ((thismove.basedamage > 0)) && 
        !target.effects[PBEffects::ProtectNegation] && thismove.canProtectAgainst? && thismove.function!=0x116
        @battle.pbDisplay(_INTL("{1} protected itself!", target.pbThis))
        @battle.successStates[user.index].protected=true
        # physical contact
        if thismove.hasFlags?('a') && user.pbCanPoison?(false) && !user.hasWorkingAbility(:LONGREACH)
          #@scene.pbDamageAnimation(user,0) TODO: Fix animation
          user.pbPoison(target)
          @battle.pbDisplay(_INTL("{1}'s Baneful Bunker poisoned {2}!",target.pbThis,user.pbThis(true)))
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
        self.missed = false
        return true
      end
      invulmiss=false
      invulmove=PBMoveData.new(target.effects[PBEffects::TwoTurnAttack]).function
      case invulmove
      when 0xC9, 0xCC # Fly, Bounce
        (invulmiss=true)                 unless thismove.function==0x08 ||  # Thunder
        thismove.function==0x15 ||  # Hurricane
        thismove.function==0x77 ||  # Gust
        thismove.function==0x78 ||  # Twister
        (thismove.function==0x10D && !user.pbHasType?(:GHOST)) ||  # Curse
        thismove.function==0x11B || # Sky Uppercut
        thismove.function==0x11C || # Smack Down
        thismove.id      ==630   ||
        isConst?(thismove.id,PBMoves,:WHIRLWIND)
      when 0xCA # Dig
        (invulmiss=true)                 unless thismove.function==0x76 || # Earthquake
        thismove.function==0x95 || # Magnitude
        (thismove.function==0x10D && !user.pbHasType?(:GHOST)) # Curse
      when 0xCB # Dive
        (invulmiss=true)                 unless thismove.function==0x75 || # Surf
        thismove.function==0xD0 || # Whirlpool
        (thismove.function==0x10D && !user.pbHasType?(:GHOST)) # Curse
      when 0xCD # Shadow Force
        (invulmiss=true)
      when 0xCE # Sky Drop
        (invulmiss=true)                 unless thismove.function==0x08 ||  # Thunder
        thismove.function==0x15 ||  # Hurricane
        thismove.function==0x77 ||  # Gust
        thismove.function==0x78 ||  # Twister
        (thismove.function==0x10D && !user.pbHasType?(:GHOST)) ||  # Curse
        thismove.function==0x11B || # Sky Uppercut
        thismove.function==0x11C ||   # Smack Down
        thismove.id      ==630   
      end
      if target.effects[PBEffects::SkyDrop]
        (invulmiss=true)                 unless thismove.function==0x08 ||  # Thunder
        thismove.function==0x15 ||  # Hurricane
        thismove.function==0x77 ||  # Gust
        thismove.function==0x78 ||  # Twister
        (thismove.function==0x10D && !user.pbHasType?(:GHOST)) ||  # Curse
        thismove.function==0x11B || # Sky Uppercut
        thismove.function==0x11C ||  # Smack Down
        #### KUROTSUNE - 022 - START                         
        thismove.function==0xCE  ||  # Sky Drop
        #### KUROTSUNE - 022 - END                         
        thismove.id              == 630
      end
      if invulmiss 
        if thismove.target==PBTargets::AllOpposing && 
          (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) > 1
          # All opposing Pokémon
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.target==PBTargets::AllNonUsers && 
          (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) + (!user.pbPartner.isFainted? ? 1 : 0) > 1
          # All non-users
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.function==0xDC # Leech Seed
          @battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
        elsif thismove.function==0x70 && (((target.hasWorkingAbility(:STURDY)) && !(target.moldbroken)) || (user.level<target.level))
          @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
        elsif thismove.function==0x70 && !((target.hasWorkingAbility(:STURDY)) || (user.level<target.level))
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s attack missed!",user.pbThis)) 
        end
        return false
      end
    end    
    if thismove.id==83  && thismove.pbTypeModMessages(thismove.type,user,target)==0
      return false
    end      
    if thismove.basedamage>0 && thismove.function!=0x02 && # Struggle
      thismove.function!=0x111 # Future Sight
      type=thismove.pbType(thismove.type,user,target)
      typemod=thismove.pbTypeModifier(type,user,target)
      typemod=thismove.FieldTypeChange(user,target,typemod)
      if isConst?(type,PBTypes,:GROUND)     && 
        target.isAirborne?                 &&
        !target.hasWorkingItem(:RINGTARGET) &&
        $fefieldeffect != 23                && 
        (thismove.id != 664 && thismove.id != 674)
        if target.hasWorkingAbility(:LEVITATE)  &&
          !(target.moldbroken)          
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Levitate!",target.pbThis))
          return false
        end
        if (target.hasWorkingAbility(:SOLARIDOL) || target.hasWorkingAbility(:LUNARIDOL))  && !(target.moldbroken)          
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with {2}!",target.pbThis,PBAbilities.getName(target.ability)))
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
      #### KUROTSUNE - 029 - START         
      if target.hasWorkingAbility(:WONDERGUARD) && 
        typemod<=4 && 
        type>=0  && 
        !(target.moldbroken)
        #### KUROTSUNE - 029 - END         
        @battle.pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",target.pbThis))
        return false 
      end
      if (typemod==0 && !thismove.function==0x111) || (typemod==0 && thismove.function==0x10B)
        @battle.pbDisplay(_INTL("It doesn't affect\r\n{1}...",target.pbThis(true)))
        return false 
      end
    end
    if accuracy
      if target.effects[PBEffects::LockOn]>0 && target.effects[PBEffects::LockOnPos]==user.index
        self.missed = false
        return true
      end
      if !thismove.pbAccuracyCheck(user,target) # Includes Counter/Mirror Coat
        if thismove.target==PBTargets::AllOpposing && 
          (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) > 1
          # All opposing Pokémon
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))          
        elsif thismove.target==PBTargets::AllNonUsers && 
          (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) + (!user.pbPartner.isFainted? ? 1 : 0) > 1
          # All non-users
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.function==0xDC # Leech Seed
          @battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
        elsif thismove.function==0x70 && (((target.hasWorkingAbility(:STURDY)) && !(target.moldbroken)) || (user.level<target.level))
          @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
        elsif thismove.function==0x70 && !((target.hasWorkingAbility(:STURDY)) || (user.level<target.level))
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s attack missed!",user.pbThis))
          if user.effects[PBEffects::SkyDroppee]!=nil
            target.effects[PBEffects::SkyDrop]=false
            @battle.scene.pbUnVanishSprite(target)
            @battle.pbDisplay(_INTL("{1} is freed from the Sky Drop effect!",target.pbThis))
          end
          if $fefieldeffect == 30 && thismove.basedamage>0 &&
            (thismove.flags&0x01)==0 && thismove.pbIsSpecial?(type) &&
            @battle.pbRandom(10)<5
            @battle.pbDisplay(_INTL("The attack was reflected by the mirror!",user.pbThis))
            $fecounter = 1
            self.missed = false
            return true
          end
        end
        user.missAcc = true
        return false
      end
    end
    self.missed = false
    return true
  end
  
  def pbTryUseMove(choice,thismove,turneffects)
    return true if turneffects[PBEffects::PassedTrying]
    # TODO: Return true if attack has been Mirror Coated once already
    return false if !pbObedienceCheck?(choice)
    return false if self.forcedSwitchEarlier
    # implementing Stance Change
    if isConst?(self.ability, PBAbilities, :STANCECHANGE)
      pbCheckForm(thismove)
    end 
    if isConst?(self.species,PBSpecies,:VESPIQUEN) && isConst?(self.item,PBItems,:VESPICREST)
      changed=false
      if thismove.basedamage==0 && (isConst?(thismove.id,PBMoves,:DEFENDORDER) || isConst?(thismove.id,PBMoves,:HEALORDER))
        if @effects[PBEffects::VespiCrest]!=0
          @effects[PBEffects::VespiCrest]  = 0
          changed=true
        end
      elsif thismove.basedamage>0
        if @effects[PBEffects::VespiCrest]!=1
          @effects[PBEffects::VespiCrest]  = 1
          changed=true
        end
      end
      if @effects[PBEffects::VespiCrest]!=-1 && changed==true
        if @effects[PBEffects::VespiCrest]==0
          self.pbReduceStat(PBStats::ATTACK,1,false)
          self.pbReduceStat(PBStats::SPATK,1,false)
          self.pbIncreaseStat(PBStats::DEFENSE,1,false)
          self.pbIncreaseStat(PBStats::SPDEF,1,false)
          @battle.pbDisplay(_INTL("{1} switched to Defense Stance!",pbThis))
        else
          self.pbReduceStat(PBStats::DEFENSE,1,false)
          self.pbReduceStat(PBStats::SPDEF,1,false)
          self.pbIncreaseStat(PBStats::ATTACK,1,false)
          self.pbIncreaseStat(PBStats::SPATK,1,false)
          @battle.pbDisplay(_INTL("{1} switched to Attack Stance!",pbThis))
        end
      end
    end
    # end of update
    # TODO: If being Sky Dropped, return false
    # TODO: Gravity prevents airborne-based moves here
    if @effects[PBEffects::Taunt]>0 && thismove.basedamage==0
      @battle.pbDisplay(_INTL("{1} can't use {2} after the taunt!",
          pbThis,thismove.name))
      return false
    end
    if @effects[PBEffects::HealBlock]>0 && thismove.isHealingMove?
      @battle.pbDisplay(_INTL("{1} can't use {2} after the Heal Block!",
          pbThis,thismove.name))
      return false
    end
    if thismove.isSoundBased? && self.effects[PBEffects::ThroatChop]>0
      @battle.pbDisplay(_INTL("{1} can't use sound-based moves because of it's throat damage!",pbThis))
      return false    
    end    
    if @effects[PBEffects::Torment] && thismove.id==@lastMoveUsed &&
      thismove.id!=@battle.struggle.id
      @battle.pbDisplay(_INTL("{1} can't use the same move in a row due to the torment!",
          pbThis))
      return false
    end
    if pbOpposing1.effects[PBEffects::Imprison] && !@simplemove
      if thismove.id==pbOpposing1.moves[0].id ||
        thismove.id==pbOpposing1.moves[1].id ||
        thismove.id==pbOpposing1.moves[2].id ||
        thismove.id==pbOpposing1.moves[3].id
        @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!",
            pbThis,thismove.name))
        PBDebug.log("[#{pbOpposing1.pbThis} has: #{pbOpposing1.moves[0].id}, #{pbOpposing1.moves[1].id},#{pbOpposing1.moves[2].id} #{pbOpposing1.moves[3].id}]") if $INTERNAL
        return false
      end
    end
    if pbOpposing2.effects[PBEffects::Imprison] && !@simplemove
      if thismove.id==pbOpposing2.moves[0].id ||
        thismove.id==pbOpposing2.moves[1].id ||
        thismove.id==pbOpposing2.moves[2].id ||
        thismove.id==pbOpposing2.moves[3].id
        @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!",
            pbThis,thismove.name))
        PBDebug.log("[#{pbOpposing2.pbThis} has: #{pbOpposing2.moves[0].id}, #{pbOpposing2.moves[1].id},#{pbOpposing2.moves[2].id} #{pbOpposing2.moves[3].id}]") if $INTERNAL
        return false
      end
    end
    if @effects[PBEffects::Disable]>0 && thismove.id==@effects[PBEffects::DisableMove]
      @battle.pbDisplayPaused(_INTL("{1}'s {2} is disabled!",pbThis,thismove.name))
      return false
    end
    if self.hasWorkingAbility(:TRUANT) && @effects[PBEffects::Truant]
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
      self.statusCount-=1 if self.hasWorkingAbility(:EARLYBIRD)
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
        if !self.isBoss
          self.pbContinueStatus
          return false
        else 
          self.pbCureStatus
          pbCheckForm
        end
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
          #          if $fefieldeffect == 30
          #            if self.pbCanReduceStatStage?(PBStats::EVASION)
          #              self.pbReduceStatBasic(PBStats::EVASION,1)
          #              @battle.pbCommonAnimation("StatDown",self,nil)
          #              @battle.pbDisplay(_INTL("{1}'s evasion fell!",self.pbThis))
          #            end
          #          end
          return false
        end
      end
    end
    #### AME - 004 - START
    if @effects[PBEffects::Flinch]
      @effects[PBEffects::Flinch]=false
      if self.hasWorkingAbility(:INNERFOCUS)
        @battle.pbDisplay(_INTL("{1} won't flinch because of its {2}!",
            self.pbThis,PBAbilities.getName(self.ability)))
      elsif self.isBoss
        @battle.pbDisplay(_INTL("{1} endured the pain!",self.pbThis))
      elsif $fefieldeffect == 14  # Rocky Field
        if !isConst?(self.ability,PBAbilities,:STEADFAST) &&
          !isConst?(self.ability,PBAbilities,:STURDY) &&
          !isConst?(self.ability,PBAbilities,:INNERFOCUS)
          @battle.pbDisplay(_INTL("{1} was knocked into a rock!",pbThis))
          damage=[1,(self.totalhp/16).floor].max
          if damage>0
            @battle.scene.pbDamageAnimation(self,0)
            self.pbReduceHP(damage)
          end
          if self.hp<=0
            user.pbFaint 
          else
            @battle.pbDisplay(_INTL("{1} flinched and couldn't move!",self.pbThis))
            if self.hasWorkingAbility(:STEADFAST)
              if pbCanIncreaseStatStage?(PBStats::SPEED)
                pbIncreaseStat(PBStats::SPEED,1,false)
                @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!",
                    self.pbThis,PBAbilities.getName(self.ability)))
              end
            end
            return false            
          end
        end  
      else
        @battle.pbDisplay(_INTL("{1} flinched and couldn't move!",self.pbThis))
        if self.hasWorkingAbility(:STEADFAST)
          if pbCanIncreaseStatStage?(PBStats::SPEED)
            pbIncreaseStat(PBStats::SPEED,1,false)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!",
                self.pbThis,PBAbilities.getName(self.ability)))
          end
        end
        return false
      end
    end
    #### AME - 004 - END
    if @effects[PBEffects::Attract]>=0 && !@simplemove
      pbAnnounceAttract(@battle.battlers[@effects[PBEffects::Attract]])
      if @battle.pbRandom(2)==0
        pbContinueAttract
        return false
      end
    end
    if self.status==PBStatuses::PARALYSIS && !@simplemove
      if @battle.pbRandom(4)==0 && !self.isBoss && !(!@battle.pbOwnedByPlayer?(@index) && isConst?(self.ability,PBAbilities,:QUICKFEET))
        pbContinueStatus
        return false
      end
    end
    # UPDATE 2/13/2014
    # implementing Protean / Libero
    protype=thismove.type
    if (thismove.id == 333) 
      hp = pbHiddenPower(self.iv)
      protype = hp[0] 
    end
    if (isConst?(self.ability,PBAbilities,:PROTEAN) || isConst?(self.ability,PBAbilities,:LIBERO)) && !(self.abilitynulled)
      prot1 = self.type1
      prot2 = self.type2 
      if !self.pbHasType?(protype) || (defined?(prot2) && prot1 != prot2)
        self.type1=protype
        self.type2=protype
        typename=PBTypes.getName(protype)
        @battle.pbDisplay(_INTL("{1} had its type changed to {3}!",pbThis,PBAbilities.getName(self.ability),typename))
      end
    end # end of update 
    turneffects[PBEffects::PassedTrying]=true
    return true
  end
  
  def pbConfusionDamage
    self.damagestate.reset
    confmove=PokeBattle_Confusion.new(@battle,nil)
    confmove.pbEffect(self,self)
    pbFaint if self.isFainted?
  end
  
  def pbUpdateTargetedMove(thismove,user)
    # TODO: Snatch, moves that use other moves
    # TODO: All targeting cases
    # Two-turn attacks, Magic Coat, Future Sight, Counter/MirrorCoat/Bide handled
  end
  
  def pbProcessMoveAgainstTarget(thismove,user,target,numhits,turneffects,nocheck=false,alltargets=nil,showanimation=true)
    realnumhits=0
    totaldamage=0
    destinybond=false
    wimpcheck=false
    if $fefieldeffect == 5  
      user.effects[PBEffects::SusCrit] = false  
      target.effects[PBEffects::SusCrit] = false  
    end
    $feshutup=0
    $feshutup2=0
    if target
      aboveHalfHp = target.hp>(target.totalhp/2).floor
      innardsOutHp = target.hp
    end
    for i in 0...numhits
      if user.status==PBStatuses::SLEEP && !thismove.pbCanUseWhileAsleep? && !@simplemove
        realnumhits = i
        break
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
      if !nocheck &&
        !pbSuccessCheck(thismove,user,target,i==0 || thismove.function==0xBF) # Triple Kick
        if thismove.function==0xBF && realnumhits>0   # Triple Kick
          break   # Considered a success if Triple Kick hits at least once
        elsif thismove.function==0x10B   # Hi Jump Kick, Jump Kick
          #TODO: Not shown if message is "It doesn't affect XXX..."
          @battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
          damage=[1,(user.totalhp/2).floor].max
          if damage>0
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP(damage)
          end
          user.pbFaint if user.isFainted?
        elsif thismove.function==0xC9 || thismove.function==0xCA || thismove.function==0xCB ||
          thismove.function==0xCC || thismove.function==0xCD || thismove.function==0xCE #Sprites for two turn moves
          @battle.scene.pbUnVanishSprite(user)
          if thismove.function==0xCE
            @battle.scene.pbUnVanishSprite(target)
          end             
          # Rocky Field Crash
        elsif $fefieldeffect == 14  && (thismove.flags&0x01)!=0 &&
          !isConst?(user.ability,PBAbilities,:ROCKHEAD)
          @battle.pbDisplay(_INTL("{1} hit a rock instead!",user.pbThis)) 
          damage=[1,(user.totalhp/8).floor].max
          if isConst?(user.ability,PBAbilities,:GORILLATACTICS)
            damage=[1,(user.totalhp/4).floor].max
          end
          if damage>0 
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP(damage) 
          end 
          user.pbFaint if user.isFainted?
        elsif $fefieldeffect == 30  && (thismove.flags&0x01)!=0
          @battle.pbDisplay(_INTL("{1} hit a mirror instead!",user.pbThis)) 
          @battle.pbDisplay(_INTL("The mirror shattered!",user.pbThis)) 
          damage=[1,(user.totalhp/4).floor].max 
          if damage>0 
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP(damage) 
          end 
          user.pbFaint if user.isFainted?
        end
        if user.hasWorkingItem(:BLUNDERPOLICY) && user.missAcc
          if user.pbCanIncreaseStatStage?(PBStats::SPEED)
            user.pbIncreaseStatBasic(PBStats::SPEED,1)
            @battle.pbCommonAnimation("StatUp",user,nil)
            @battle.pbDisplay(_INTL("The Blunder Policy raised #{user.pbThis}'s Speed!"))
            user.pokemon.itemRecycle=user.item
            user.pokemon.itemInitial=0 if user.pokemon.itemInitial==user.item
            user.item=0
          end
        end
        
        user.effects[PBEffects::Tantrum]=true
        user.effects[PBEffects::Outrage]=0 if thismove.function==0xD2 # Outrage
        user.effects[PBEffects::Rollout]=0 if thismove.function==0xD3 # Rollout
        user.effects[PBEffects::FuryCutter]=0 if thismove.function==0x91 # Fury Cutter
        user.effects[PBEffects::EchoedVoice]+=1 if thismove.function==0x92 # Echoed Voice        
        user.effects[PBEffects::EchoedVoice]=0 if thismove.function!=0x92 # Not Echoed Voice
        user.effects[PBEffects::Stockpile]=0 if thismove.function==0x113 # Spit Up
        return 0
      end
      # Add to counters for moves which increase them when used in succession
      if thismove.id == user.movesUsed[-2] && user.hasWorkingItem(:METRONOME)
        user.effects[PBEffects::Metronome]+=1
      else
        user.effects[PBEffects::Metronome]=0
      end
      
      if thismove.function==0x91 # Fury Cutter
        #### JERICHO - 011 - START        
        user.effects[PBEffects::FuryCutter]+=1 if user.effects[PBEffects::FuryCutter]<3
        #### JERICHO - 011 - END        
      else
        user.effects[PBEffects::FuryCutter]=0
      end
      if thismove.function==0x92 # Echoed Voice
        user.effects[PBEffects::EchoedVoice]+=1 if user.effects[PBEffects::EchoedVoice]<5
      else
        user.effects[PBEffects::EchoedVoice]=0
      end
      if $fefieldeffect == 5  
        if thismove.function==0x171 || thismove.id==53 || thismove.id==268  
          user.effects[PBEffects::SusCrit] = true  
        end  
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
        @battle.scene.pbUnVanishSprite(target) unless (thismove.function==0x10D && !user.pbHasType?(:GHOST)) # Curse
      end
      damage=thismove.pbEffect(user,target,i,alltargets,showanimation) # Recoil/drain, etc. are applied here
      if isConst?(target.species,PBSpecies,:BASTIODON) && target.hasWorkingItem(:BASTCREST,true)
        if target.damagestate.calcdamage>0 && !target.damagestate.substitute &&
          !user.hasWorkingAbility(:ROCKHEAD) && !user.hasWorkingAbility(:MAGICGUARD) && !user.isBoss &&
          !(user.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
          user.pbReduceHP([1,((target.damagestate.hplost)/2).floor].max)
          target.pbRecoverHP([1,((target.damagestate.hplost)/2).floor].max) if !target.isFainted?
          @battle.pbDisplay(_INTL("{1}'s crest causes {2} to take recoil damage and {3} to recover!",
              target.pbThis,user.pbThis(true),target.pbThis))
          
        end
      end
      if damage == -1
        user.effects[PBEffects::Tantrum]=true
      else
        user.effects[PBEffects::Tantrum]=false
      end
      totaldamage += target.damagestate.calcdamage unless damage <0
      if user.isFainted?
        user.pbFaint # no return
      end
      if revanish && !(target.isFainted?)
        @battle.pbCommonAnimation("Fade out",target,nil)
        @battle.scene.pbVanishSprite(target) 
      end       
      return if numhits>1 && target.damagestate.calcdamage<=0
      @battle.pbJudgeCheckpoint(user,thismove)
      # Additional effect
      if target.damagestate.calcdamage>0 &&
        !(user.hasWorkingAbility(:SHEERFORCE) || @battle.SilvallyCheck(user,PBTypes::GROUND)) &&
        ((!target.hasWorkingAbility(:SHIELDDUST) || target.moldbroken) || thismove.hasFlags?("m"))
        addleffect=thismove.addlEffect
        if (thismove.function!=0x09 && thismove.function!=0x0B && thismove.function!=0x0E && 
            thismove.function!=0x0F && thismove.function!=0x10 && thismove.function!=0x11 && 
            thismove.function!=0x12 && thismove.function!=0x78 &&  thismove.function!=0xC7) && $fefieldeffect == 9
          if user.hasWorkingAbility(:SERENEGRACE) 
            addleffect*=4
          else
            addleffect*=2
          end
          # Rainbow Field doubles effect chance for everything and stacks with Serene Grace if the move does NOT flinch. 
        else
          addleffect*=2 if user.hasWorkingAbility(:SERENEGRACE) || $fefieldeffect == 9 || @battle.field.effects[PBEffects::Rainbow]>0 || ($fefieldeffect == 13 && (thismove.function==0x00E ||
              thismove.function==0x00D || thismove.function==0x00C))
        end
        addleffect=100 if $DEBUG && Input.press?(Input::CTRL)
        addleffect=100 if thismove.id == 522 && $fefieldeffect == 30
        addleffect=40 if thismove.id == 177 && $fefieldeffect == 40
        addleffect=100 if thismove.id == 182 && $fefieldeffect == 40
        addleffect=100 if thismove.id == 784 && $fefieldeffect == 31
        addleffect=0 if (isConst?(user.species,PBSpecies,:LEDIAN) && user.hasWorkingItem(:LEDICREST) && i>1) || (isConst?(user.species,PBSpecies,:CINCCINO) && user.hasWorkingItem(:CINCCREST) && i>1)
        if @battle.pbRandom(100)<addleffect
          thismove.pbAdditionalEffect(user,target)
        end
        # Meloetta
        if isConst?(self.species, PBSpecies, :MELOETTA) && !self.isFainted? && thismove.id == 286
          if self.form==0
            self.form = 1 
          elsif self.form==1
            self.form = 0
          end
          transformed = true
          pbUpdate(false)
          @battle.scene.pbChangePokemon(self,@pokemon)
          if self.form==0
            @battle.pbDisplay(_INTL("{1} transformed into Aria Forme!",pbThis))
          elsif self.form==1
            @battle.pbDisplay(_INTL("{1} transformed into Pirouette Forme!",pbThis))
          end
        end
        # Gulp Missile
        if isConst?(self.species, PBSpecies, :CRAMORANT) && self.hasWorkingAbility(:GULPMISSILE) && !self.isFainted? && (thismove.id == 538 || thismove.id == 541) # Surf or Dive
          if self.form==0
            if ($fefieldeffect == 1 || $fefieldeffect == 17 ||
                $fefieldeffect == 18)
              self.form = 2     # Gorging Form
            elsif ($fefieldeffect == 8 || $fefieldeffect == 21 ||
                $fefieldeffect == 22)
              self.form = 1     # Gulping Form
            else
              if self.hp*2.0 > self.totalhp
                self.form = 1   # Gulping Form
              else
                self.form = 2   # Gorging Form
              end
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
      # Ability effects
      pbEffectsOnDealingDamage(thismove,user,target,damage,innardsOutHp)
      # Berserk
      if !target.isFainted? && aboveHalfHp && target.hp<=(target.totalhp/2).floor
        if target.hasWorkingAbility(:BERSERK)
          if !pbTooHigh?(PBStats::SPATK)
            increment = 1
            increment = 2 if ($fefieldeffect == 32 || $fefieldeffect == 39)
            target.pbIncreaseStatBasic(PBStats::SPATK,increment)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s Berserk boosted its Special Attack!",
                target.pbThis)) 
          end
        end
      end      
      # Emergency Exit
      if !target.isFainted? && aboveHalfHp && target.hp<=(target.totalhp/2).floor && !user.isBoss
        if target.hasWorkingAbility(:EMERGENCYEXIT) && ((@battle.pbCanChooseNonActive?(target.index) &&  
              !@battle.pbAllFainted?(@battle.pbParty(target.index))) || @battle.pbIsWild?)  
          if $fefieldeffect == 44  
            if !wimpcheck  
              if user.pbCanIncreaseStatStage?(PBStats::SPEED)  
                user.pbIncreaseStatBasic(PBStats::SPEED,2)  
                @battle.pbCommonAnimation("StatUp",user,nil)  
                @battle.pbDisplay(_INTL("Emergency Exit raised #{user.pbThis}'s Speed!"))  
              end  
              wimpcheck=true  
            end  
          else  
            if !target.isBoss
              if !wimpcheck  
                @battle.pbDisplay(_INTL("{1} tactically retreated!",target.pbThis))  
                wimpcheck=true  
              end  
              @battle.pbClearChoices(target.index)  
              if @battle.pbIsWild?  
                @battle.decision=3 # Set decision to escaped  
              else  
                target.userSwitch = true            
              end  
            end
          end  
        end  
      end
      # Wimp Out
      if !target.isFainted? && aboveHalfHp && target.hp<=(target.totalhp/2).floor && !user.isBoss
        if target.hasWorkingAbility(:WIMPOUT) && ((@battle.pbCanChooseNonActive?(target.index) &&
              !@battle.pbAllFainted?(@battle.pbParty(target.index))) || @battle.pbIsWild?)
          if !wimpcheck
            @battle.pbDisplay(_INTL("{1} wimped out!",target.pbThis))
            wimpcheck=true
          end
          if !target.isBoss
            @battle.pbClearChoices(target.index)
            if @battle.pbIsWild?
              @battle.decision=3 # Set decision to escaped
            else
              target.userSwitch = true          
            end  
          end       
        end
      end
      # Grudge
      if !user.isFainted? && target.isFainted?
        if target.effects[PBEffects::Grudge] && target.pbIsOpposing?(user.index) && !user.isBoss
          pbSetPP(thismove,thismove.pp=0)
          @battle.pbDisplay(_INTL("{1}'s {2} lost all its PP due to the grudge!",
              user.pbThis,thismove.name))
        end
      end
      # gen8 items
      if user.hasWorkingItem(:THROATSPRAY) && thismove.isSoundBased? && user.hp>0
        if user.pbCanIncreaseStatStage?(PBStats::SPATK)
          user.pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",user,nil)
          @battle.pbDisplay(_INTL("The Throat Spray raised #{user.pbThis}'s Sp.Atk!"))
          user.pokemon.itemRecycle=user.item
          user.pokemon.itemInitial=0 if user.pokemon.itemInitial==user.item
          user.item=0
        end
      end
      if target.hasWorkingItem(:EJECTPACK) && target.statLowered
        if !target.isFainted? && @battle.pbCanChooseNonActive?(target.index) &&
          !@battle.pbAllFainted?(@battle.pbParty(target.index))
          @battle.pbDisplay(_INTL("#{target.pbThis}'s Eject Pack activates!"))    
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
          @battle.pbClearChoices(target.index)
          target.userSwitch = true
        end
      end
      if target.isFainted?
        destinybond=destinybond || target.effects[PBEffects::DestinyBond]
        #        target.pbFaint # no return
      end
      user.pbFaint if user.isFainted? # no return
      break if user.isFainted?
      break if target.isFainted?
      # Moxie goes here
      # Make the target flinch
      if target.damagestate.calcdamage>0 && !target.damagestate.substitute
        if !isConst?(target.ability,PBAbilities,:SHIELDDUST) || target.moldbroken || thismove.hasFlags?("m")
          if (user.hasWorkingItem(:KINGSROCK) || user.hasWorkingItem(:RAZORFANG)) &&
            thismove.canKingsRock? && target.status!=PBStatuses::SLEEP && target.status!=PBStatuses::FROZEN
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
            thismove.function!=0xC7 && # Sky Attack
            target.status!=PBStatuses::SLEEP && target.status!=PBStatuses::FROZEN
            if (@battle.pbRandom(10)==0 || (($fefieldeffect == 19 ||
                    $fefieldeffect == 26) &&
                  @battle.pbRandom(10) < 2))
              target.effects[PBEffects::Flinch]=true
            end
          end
        end
      end
      if target.damagestate.calcdamage>0 && !target.isFainted?
        # Defrost
        if isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:FIRE) &&
          target.status==PBStatuses::FROZEN
          target.pbCureStatus
        elsif thismove.name=="Scald" && target.status==PBStatuses::FROZEN
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
      #      target.pbFaint if target.isFainted? # no return
      user.pbFaint if user.isFainted? # no return
      break if user.isFainted?
      break if target.isFainted?      
      # Berry check (maybe just called by ability effect, since only necessary Berries are checked)
      for j in 0...4
        @battle.battlers[j].pbBerryCureCheck
      end
      target.pbUpdateTargetedMove(thismove,user)
      break if target.damagestate.calcdamage<=0
    end
    if totaldamage>0
      turneffects[PBEffects::TotalDamage]+=totaldamage 
    end
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
    if ($fefieldeffect == 24 && target.isFainted? && thismove.function==0xC2)
      @effects[PBEffects::HyperBeam] = 0
    end
    if ($fefieldeffect == 34 && thismove.id==788)
      @effects[PBEffects::HyperBeam] = 0
    end
    # Faint if 0 HP
    target.pbFaint if target.isFainted?
    user.pbFaint if user.isFainted? # no return
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
    movetype=thismove.pbType(thismove.type,user,target)
    if target.hasWorkingAbility(:COLORCHANGE) && totaldamage>0 && !PBTypes.isPseudoType?(movetype) && !target.pbHasType?(movetype)
      target.type1=movetype
      target.type2=movetype
      @battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
          PBAbilities.getName(target.ability),PBTypes.getName(movetype)))
    end
    # Berry check
    for j in 0...4
      @battle.battlers[j].pbBerryCureCheck
    end
    target.pbUpdateTargetedMove(thismove,user)
    if realnumhits != numhits && (thismove.name=="Thunder Raid")
      @battle.pbCommonAnimation("Failsafe",self,nil)
      @battle.scene.pbUnVanishSprite(self)
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
    @simplemove=true
    if index>=0
      @battle.choices[@index][1]=index
    end
    @usingsubmove=true
    side=(@battle.pbIsOpposing?(self.index)) ? 1 : 0
    owner=@battle.pbGetOwnerIndex(self.index)
    if @battle.zMove[side][owner]==self.index
      crystal = pbZCrystalFromType(choice[2].type)
      PokeBattle_ZMoves.new(@battle,self,choice[2],crystal,choice)
    else
      pbUseMove(choice,true,danced,moveid)
    end
    @usingsubmove=false
    @simplemove=false
    return
  end
  
  def pbDancerMoveCheck(id)
    dancemoves = [17,63,138,170,192,418,420,483,721]
    if $fefieldeffect == 6 # Big Top
      if self.hasWorkingAbility(:DANCER)
        for i in dancemoves
          if id == i
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
            if boost
              @battle.pbDisplay(_INTL("{1}'s Dancer boosted its Special Attack and Speed!",
                  pbThis))
            end   
          end
        end
      end
    end    
    for i in @battle.battlers
      next if i == self
      for j in dancemoves
        if id == j
          if i.hasWorkingAbility(:DANCER)
            @battle.pbDisplay(_INTL("{1} joined in with the dance!",i.pbThis))
            i.pbUseMoveSimple(id,-1,-1,true)
            i.effects[PBEffects::Outrage]=0
          end
        end
      end
    end
  end
  
  def pbVoreMoveCheck(id,target=0,danced)
    voremoves = [339,415]
    for i in @battle.battlers
      next if i != self
      for j in voremoves
        if id == j && danced==false
          if i.hasWorkingAbility(:ACCUMULATION)
            if id ==339
              moveuse=415
            elsif id == 415
              moveuse=399
            end
            @battle.pbDisplay(_INTL("{1} attacked again!",i.pbThis))
            i.effects[PBEffects::VoreCopy] = true
            if !(target.pbPartner.isFainted?)
              movetarget=target.pbPartner
            else
              movetarget=target
            end
            i.pbUseMoveSimple(id,moveuse,movetarget,true)
            if id == 339
              if i.effects[PBEffects::StockpileDef]>0
                if i.pbCanReduceStatStage?(PBStats::DEFENSE,false,true) && i.stages[PBStats::DEFENSE]>0
                  i.stages[PBStats::DEFENSE]=0
                end
              end
              if i.effects[PBEffects::StockpileSpDef]>0
                if i.pbCanReduceStatStage?(PBStats::SPDEF,false,true) && i.stages[PBStats::SPDEF]>0
                  i.stages[PBStats::SPDEF]=0
                end
              end
              i.effects[PBEffects::Stockpile]=0
              i.effects[PBEffects::StockpileDef]=0
              i.effects[PBEffects::StockpileSpDef]=0
              @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",i.pbThis))
            end
            i.effects[PBEffects::VoreCopy] = false
            i.effects[PBEffects::Outrage]=0
          end
        end
      end
    end
  end
  
  def pbUseMove(choice,specialusage=false,danced=false,moveid=choice[2].id)
    # TODO: lastMoveUsed is not to be updated on nested calls
    turneffects=[]
    turneffects[PBEffects::SpecialUsage]=specialusage
    turneffects[PBEffects::PassedTrying]=false
    turneffects[PBEffects::TotalDamage]=0
    # Start using the move
    pbBeginTurn(choice)
    # Force the use of certain moves if they're already being used
    if @effects[PBEffects::TwoTurnAttack]>0 ||
      @effects[PBEffects::HyperBeam]>0 ||
      @effects[PBEffects::Outrage]>0 ||
      @effects[PBEffects::Rollout]>0 ||
      @effects[PBEffects::SkyDroppee]
      @effects[PBEffects::Uproar]>0 ||
      @effects[PBEffects::Bide]>0
      PBDebug.log("[Continuing move]") if $INTERNAL
      choice[2]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@currentMove),self) rescue nil
      turneffects[PBEffects::SpecialUsage]=true
      self.lastRoundMoved=@battle.turncount
    elsif @effects[PBEffects::Encore]>0
      if @battle.pbCanShowCommands?(@index) &&
        @battle.pbCanChooseMove?(@index,@effects[PBEffects::EncoreIndex],false)
        PBDebug.log("[Using Encore move]") if $INTERNAL
        if choice[1]!=@effects[PBEffects::EncoreIndex] # Was Encored mid-round
          choice[1]=@effects[PBEffects::EncoreIndex]
          choice[2]=@moves[@effects[PBEffects::EncoreIndex]]
          choice[3]=-1 # No target chosen
        end
        self.lastRoundMoved=@battle.turncount
      end
    end
    thismove=choice[2]
    return if !thismove || thismove.id==0 # if move was not chosen
    if !turneffects[PBEffects::SpecialUsage]
      # TODO: Quick Claw message
    end
    # TODO: Record that self has moved this round (for Payback, etc.)
    # Stance Change goes here
    # Try to use the move
    #return false if self.effects[PBEffects::SkyDrop]
    if !pbTryUseMove(choice,thismove,turneffects)
      if self.vanished
        @battle.scene.pbUnVanishSprite(self)
        droprelease = self.effects[PBEffects::SkyDroppee]
        if droprelease!=nil
          oppmon = droprelease
          oppmon.effects[PBEffects::SkyDrop]=false
          @battle.scene.pbUnVanishSprite(oppmon)
          @battle.pbDisplay(_INTL("{1} is freed from the Sky Drop effect!",oppmon.pbThis))
        end
      end         
      self.lastMoveUsed=-1
      if !turneffects[PBEffects::SpecialUsage]
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
    if !turneffects[PBEffects::SpecialUsage]
      if !pbReducePP(thismove)
        @battle.pbDisplay(_INTL("{1} used\r\n{2}!",pbThis,thismove.name))
        @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
        self.lastMoveUsed=-1
        if !turneffects[PBEffects::SpecialUsage]
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
    #### KUROTSUNE - 023 - START
    if @effects[PBEffects::Powder] && isConst?(thismove.type,PBTypes,:FIRE)
      @battle.pbDisplay(_INTL("The powder around {1} exploded!",pbThis))
      pbReduceHP((@totalhp/4).floor)
      pbFaint if @hp<1
      return false
    end
    #### KUROTSUNE - 023 - END
    # Remember that user chose a two-turn move
    if thismove.pbTwoTurnAttack(self)
      # Beginning use of two-turn attack
      @effects[PBEffects::TwoTurnAttack]=thismove.id
      @currentMove=thismove.id
    else
      @effects[PBEffects::TwoTurnAttack]=0 # Cancel use of two-turn attack
      @effects[PBEffects::SkyDroppee] = nil
    end
    # "X used Y!" message
    case thismove.pbDisplayUseMessage(self)
    when 2   # Continuing Bide
      if !turneffects[PBEffects::SpecialUsage]
        self.lastRoundMoved=@battle.turncount
      end
      return
    when 1   # Starting Bide
      self.lastMoveUsed=thismove.id
      if !turneffects[PBEffects::SpecialUsage]
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
      if !turneffects[PBEffects::SpecialUsage]
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
    user=pbFindUser(choice,targets,moveid)
    if user.hasWorkingAbility(:MOLDBREAKER) ||       
      user.hasWorkingAbility(:TERAVOLT)   ||
      user.hasWorkingAbility(:TURBOBLAZE) ||
      thismove.function==0x166 || # Solgaluna signatures
      (thismove.name=="Decimation")
      for battlers in targets
        battlers.moldbroken = true
      end
    else
      for battlers in targets
        battlers.moldbroken = false
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
      if !turneffects[PBEffects::SpecialUsage]
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
    end
    # Record move as having been used
    if @battle.pbOwnedByPlayer?(user.index)
      $game_variables[530] += 1
    end
    user.lastMoveUsed=thismove.id
    if !turneffects[PBEffects::SpecialUsage]
      user.lastMoveUsedSketch=thismove.id
      user.lastRegularMoveUsed=thismove.id
      user.movesUsed.push(thismove.id)   # For Last Resort
      user.lastRoundMoved=@battle.turncount
    end
    @battle.lastMoveUsed=thismove.id
    @battle.lastMoveUser=user.index
    # Try to use move against user if there aren't any targets
    if targets.length==0 && !(@effects[PBEffects::TwoTurnAttack]>0)
      user=pbChangeUser(thismove,user)
      if thismove.target==PBTargets::SingleNonUser ||
        thismove.target==PBTargets::RandomOpposing ||
        thismove.target==PBTargets::AllOpposing ||
        thismove.target==PBTargets::AllNonUsers ||
        thismove.target==PBTargets::Partner ||
        thismove.target==PBTargets::UserOrPartner ||
        thismove.target==PBTargets::SingleOpposing ||
        thismove.target==PBTargets::OppositeOpposing    
        @battle.pbDisplay(_INTL("But there was no target..."))
        if thismove.function==0xC9 || thismove.function==0xCA || thismove.function==0xCB ||
          thismove.function==0xCC || thismove.function==0xCD || thismove.function==0xCE #Sprites for two turn moves            
          @battle.scene.pbUnVanishSprite(user)
        end            
      else
        PBDebug.logonerr{
          thismove.pbEffect(user,nil)
        }
      end
      flashed=false
      # Misc Field Effects 1
      case $fefieldeffect
      when 33 # Flower Garden Stages
        tempcounter = $fecounter
        if (thismove.id == PBMoves::GROWTH || 
            thismove.id == PBMoves::FLOWERSHIELD ||
            thismove.id == PBMoves::RAINDANCE ||
            thismove.id == PBMoves::SUNNYDAY ||
            thismove.id == PBMoves::ROTOTILLER ||
            thismove.id == PBMoves::INGRAIN)
          $fecounter+=1 if $fecounter < 4
          if user.hasWorkingAbility(:RIPEN)
            $fecounter+=1 if $fecounter < 4
          end
        end
      end
      # FIELD TRANSFORMATIONS 1
      case $fefieldeffect
      when 1 # Electric Field
        if (thismove.id == PBMoves::MUDSPORT)
          if $fefieldeffect == $febackup
            $fefieldeffect = 0
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The hyper-charged terrain shorted out!"))
          @battle.field.effects[PBEffects::Terrain]=0
          @battle.seedCheck
        end
      when 3 # Misty Field
        if (thismove.id == PBMoves::TAILWIND)
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
      when 4 # Dark Crystal Cavern
        if (thismove.id == PBMoves::SUNNYDAY)
          $fefieldeffect = 25
          @effects[PBEffects::Terrain] = @battle.weatherduration
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The sun lit up the crystal cavern!"))
          @battle.seedCheck
        end
      when 7 # Burning Field
        if (thismove.id == PBMoves::WATERSPORT)
          if $fefieldeffect == $febackup
            $fefieldeffect = 23
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The flame was put out!"))
        end
      when 11 # Corrosive Mist Field
        if (thismove.id == PBMoves::TAILWIND)
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
        if (thismove.id == PBMoves::GRAVITY)
          $fefieldeffect = 10
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The toxic mist collected on the ground!"))
          @battle.seedCheck
        end
      when 21 # Water Surface
        if (thismove.id == PBMoves::GRAVITY)
          $fefieldeffect = 22
          $febackup = 22
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The battle sunk into the depths!"))
          @battle.seedCheck
        end
      when 29 # Holy
        if (thismove.id == PBMoves::CURSE && (isConst?(user.type1,PBTypes,:GHOST) || isConst?(user.type2,PBTypes,:GHOST))  || thismove.id == PBMoves::TRICKORTREAT)
          $febackup = 40
          $fefieldeffect = 40
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("Evil spirits gathered!"))
          @battle.seedCheck
        end
      when 33 # Flower Garden Field
        if tempcounter < $fecounter
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The garden grew a little bit!"))
        end
      when 35 # New World
        if (thismove.id == PBMoves::GRAVITY)
          $fefieldeffect = 34
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The world's matter reformed!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::GEOMANCY)
          $fefieldeffect = 34
          $febackup = 34
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The world was regenerated!"))
          @battle.seedCheck
        end
      when 40 # Haunted
        if (thismove.id == PBMoves::PURIFY)
          if $fefieldeffect == $febackup
            $fefieldeffect = 29
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The evil spirits have been exorcised!"))
          @battle.seedCheck
        end  
      when 41 # Corrupted cave
        if thismove.id == PBMoves::PURIFY
          if $fefieldeffect == $febackup
            $fefieldeffect = 23
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The cave was purified!"))
          @battle.seedCheck
        end
      when 42 # Bewitched woods
        if (thismove.id == PBMoves::PURIFY)
          if $fefieldeffect == $febackup
            $fefieldeffect = 15
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The evil spirits have been exorcised!"))
          @battle.seedCheck
        end
      when 43 # Sky Field
        if (thismove.id == PBMoves::GRAVITY || thismove.id == PBMoves::INGRAIN)
          $fefieldeffect = 27
          $febackup = 27
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The battle has been brought down to the mountains!"))
          @battle.seedCheck
        end
      when 45 # Infernal Field  
        if thismove.id == PBMoves::PURIFY  
          $fefieldeffect = 7  
          $febackup = 7 
          @battle.pbChangeBGSprite  
          @battle.pbDisplay(_INTL("The hellish flames were purified!"))  
          @battle.seedCheck  
        end
      end
      #End Field Transformations
      unless !thismove
        pbDancerMoveCheck(thismove.id) unless danced
      end
    else
      # We have targets
      showanimation=true
      alltargets=[]
      if @effects[PBEffects::TwoTurnAttack]>0 && targets.length==0
        numhits=thismove.pbNumHits(user)
        pbProcessMoveAgainstTarget(thismove,user,nil,numhits,turneffects,false,alltargets,showanimation)
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
        if i==0 && (thismove.target==PBTargets::AllOpposing ||
            ($fefieldeffect == 33 && $fecounter == 4 &&
              (thismove.id == 192 || thismove.id == 214 || thismove.id == 218 || 
                thismove.id == 219 || thismove.id == 220 || thismove.id == 445 || 
                thismove.id == 596 || thismove.id == 600)) || $fefieldeffect == 40 &&
            (thismove.id == 147 || thismove.id == 379) || user.hasWorkingAbility(:WORLDOFNIGHTMARES) &&
            (thismove.id == 188) || user.hasWorkingAbility(:TEMPEST) && (thismove.id == 304))  
          # Add target's partner to list of targets
          pbAddTarget(targets,target.pbPartner)
        end
        # If couldn't get the next target
        if !success
          i+=1
          next
        end
        numhits=thismove.pbNumHits(user)
        if (thismove.flags&0x04)==0 && numhits<2
          if user.isBoss && @battle.pbIsOpposing?(user.index)
            numhits = [$game_variables[699],1].max
          end
          if isConst?(user.species,PBSpecies,:LEDIAN) && user.hasWorkingItem(:LEDICREST) &&
            thismove.isPunchingMove?
            numhits = 4
          end
          if isConst?(user.species,PBSpecies,:CINCCINO) && user.hasWorkingItem(:CINCCREST) &&
            !thismove.pbIsMultiHit
            hitchances=[2,2,3,3,4,5]
            ret=hitchances[@battle.pbRandom(hitchances.length)]
            ret=5 if user.ability == PBAbilities::SKILLLINK
            numhits = ret
          end
        end
        #### KUROTSUNE - 004 - START
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
        #### KUROTSUNE - 004 - END
        if numhits == 1 && thismove.isContactMove? &&
          isConst?(user.species,PBSpecies,:TYPHLOSION) && user.hasWorkingItem(:TYPHCREST)
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
          user.effects[PBEffects::TyphBond] = true unless ((thismove.target == PBTargets::AllNonUsers && !(counter1==2)) || (thismove.target == PBTargets::AllOpposing && !(counter2==1)))
          numhits = 2  unless ((thismove.target == PBTargets::AllNonUsers && !(counter1==2)) || (thismove.target == PBTargets::AllOpposing && !(counter2==1)))
        else
          user.effects[PBEffects::TyphBond] = false
        end
        # Reset damage state, set Focus Band/Focus Sash to available
        target.damagestate.reset
        if target.hasWorkingItem(:FOCUSBAND) && @battle.pbRandom(10)==0 
          target.damagestate.focusband=true
        end
        if target.hasWorkingItem(:FOCUSSASH)
          target.damagestate.focussash=true
        end
        if isConst?(target.species,PBSpecies,:RAMPARDOS) && target.hasWorkingItem(:RAMPCREST) && 
          !target.effects[PBEffects::RampCrestUsage]
          target.damagestate.rampcrest=true
        end
        
        # Use move against the current target
        hitcheck = pbProcessMoveAgainstTarget(thismove,user,target,numhits,turneffects,false,alltargets,showanimation)
        showanimation=false unless (hitcheck==0 && (thismove.pbIsSpecial?(thismove.type) || thismove.pbIsPhysical?(thismove.type)))
        if thismove.function==0x15E && hitcheck>0
          @battle.pbDisplay(_INTL("{1} was burnt out!",self.pbThis))
        end
        unless !thismove
          pbVoreMoveCheck(thismove.id,target,danced) unless danced
        end
       # Probopass Crest
        if isConst?(user.species,PBSpecies,:PROBOPASS) && user.hasWorkingItem(:PROBOCREST)
          if thismove.basedamage > 0 && thismove.id != PBMoves::PROBOPOG
            move=getConst(PBMoves,:PROBOPOG) || 0
            movename=PBMoves.getName(move)
            @battle.pbDisplay(_INTL("{1}'s mini noses followed up on the attack!",user.pbThis))
            if thismove.target==PBTargets::AllOpposing || thismove.target==PBTargets::AllNonUsers
              movetarget=user.pbOppositeOpposing
            else
              movetarget=target
            end
            user.pbUseMoveSimple(move,-1,movetarget)
          end
        end
        i+=1
      end
      for battlers in targets
        battlers.moldbroken = false
        battlers.corroded = false
      end       
      # Misc Field Effects 2
      case $fefieldeffect
      when 11 # Corrosive Mist Combustion
        if (thismove.id == PBMoves::HEATWAVE || 
            thismove.id == PBMoves::LAVAPLUME ||
            thismove.id == PBMoves::FLAMEBURST ||
            thismove.id == PBMoves::SEARINGSHOT ||
            thismove.id == PBMoves::SELFDESTRUCT ||
            thismove.id == PBMoves::EXPLOSION ||
            thismove.id == PBMoves::ERUPTION ||
            thismove.id == PBMoves::FIREPLEDGE)
          dampcheck=0
          for i in 0...4
            dampcheck = 1 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::DAMP)
          end
          if dampcheck == 0
            for i in 0...4
              combust = @battle.battlers[i].hp
              next if combust==0
              invulcheck=PBMoveData.new(@battle.battlers[i].effects[PBEffects::TwoTurnAttack]).function
              case invulcheck
              when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
                combust = 0
              end
              combust =0 if @battle.battlers[i].effects[PBEffects::SkyDrop]
              combust-=1 if @battle.battlers[i].hasWorkingAbility(:STURDY)
              combust =0 if @battle.battlers[i].hasWorkingAbility(:FLASHFIRE)
              if @battle.battlers[i].isbossmon && @battle.shieldCount>0
                combust =0 
              end
              combust =0 if @battle.battlers[i].effects[PBEffects::Protect] == true
              combust =0 if @battle.battlers[i].effects[PBEffects::WideGuard] == true
              combust-=1 if @battle.battlers[i].effects[PBEffects::Endure] == true
              combust =0 if @battle.battlers[i].effects[PBEffects::KingsShield] == true
              combust =0 if @battle.battlers[i].effects[PBEffects::SpikyShield] == true
              combust =0 if @battle.battlers[i].effects[PBEffects::MatBlock] == true
              @battle.battlers[i].pbReduceHP(combust) if combust != 0
              @battle.battlers[i].pbFaint if @battle.battlers[i].isFainted?
            end
          else
            @battle.pbDisplay(_INTL("A Pokemon's Damp ability prevented a complete explosion!"))
          end
        end
      when 16 # Superheated Steam
        if (thismove.id == PBMoves::SURF || thismove.id == PBMoves::MUDDYWATER ||
            thismove.id == PBMoves::WATERPLEDGE || thismove.id == PBMoves::WATERSPOUT ||
            thismove.id == PBMoves::SPARKLINGARIA || thismove.id == PBMoves::HYDROPUMP)
          @battle.pbDisplay(_INTL("Steam shot up from the field!"))
          for i in 0...4
            canthit = 0
            invulcheck=PBMoveData.new(@battle.battlers[i].effects[PBEffects::TwoTurnAttack]).function
            case invulcheck
            when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
              canthit = 1
            end
            canthit =1 if @battle.battlers[i].effects[PBEffects::SkyDrop]
            if canthit = 0 && @battle.battlers[i].pbCanReduceStatStage?(PBStats::ACCURACY)
              @battle.battlers[i].pbReduceStatBasic(PBStats::ACCURACY,1)
              @battle.pbCommonAnimation("StatDown",@battle.battlers[i],nil)
              @battle.pbDisplay(_INTL("{1}'s accuracy fell!",@battle.battlers[i].pbThis))
            end
          end
        end
      when 20 # Ashen Beach Ash
        if (isConst?(thismove.type,PBTypes,:FLYING) && thismove.pbIsSpecial?(thismove.type)) ||
          (thismove.id == PBMoves::LEAFTORNADO || thismove.id == PBMoves::FIRESPIN ||
            thismove.id == PBMoves::TWISTER || thismove.id == PBMoves::RAZORWIND ||
            thismove.id == PBMoves::WHIRLPOOL)
          @battle.pbDisplay(_INTL("The attack stirred up the ash on the ground!"))
          for i in 0...4
            canthit = 0
            invulcheck=PBMoveData.new(@battle.battlers[i].effects[PBEffects::TwoTurnAttack]).function
            case invulcheck
            when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
              canthit = 1
            end
            canthit =1 if @battle.battlers[i].effects[PBEffects::SkyDrop]
            if canthit = 0 && @battle.battlers[i].pbCanReduceStatStage?(PBStats::ACCURACY)
              @battle.battlers[i].pbReduceStatBasic(PBStats::ACCURACY,1)
              @battle.pbCommonAnimation("StatDown",@battle.battlers[i],nil)
              @battle.pbDisplay(_INTL("{1}'s accuracy fell!",@battle.battlers[i].pbThis))
            end
          end
        end
      when 23 # Cave Collapse
        if (thismove.id == PBMoves::EARTHQUAKE || thismove.id == PBMoves::MAGNITUDE || thismove.id == PBMoves::BULLDOZE)
          $fecounter+=1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Bits of rock fell from the crumbling ceiling!"))
          when 2
            @battle.pbDisplay(_INTL("The quake collapsed the ceiling!"))
            for i in 0...4
              quakedrop = @battle.battlers[i].hp
              next if quakedrop==0
              invulcheck=PBMoveData.new(@battle.battlers[i].effects[PBEffects::TwoTurnAttack]).function
              case invulcheck
              when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
                quakedrop = 0
              end
              quakedrop =0 if @battle.battlers[i].effects[PBEffects::SkyDrop]
              quakedrop-=1 if @battle.battlers[i].hasWorkingAbility(:STURDY)                 
              quakedrop/=3 if (@battle.battlers[i].hasWorkingAbility(:SOLIDROCK) || @battle.SilvallyCheck(@battle.battlers[i],PBTypes::ROCK))
              quakedrop/=2 if @battle.battlers[i].hasWorkingAbility(:SHELLARMOR)
              quakedrop/=2 if @battle.battlers[i].hasWorkingAbility(:BATTLEARMOR)
              quakedrop =0 if @battle.battlers[i].hasWorkingAbility(:BULLETPROOF)
              quakedrop =0 if @battle.battlers[i].isbossmon
              quakedrop =0 if @battle.battlers[i].hasWorkingAbility(:ROCKHEAD)
              quakedrop =0 if @battle.battlers[i].hasWorkingAbility(:STALWART)
              quakedrop/=3 if @battle.battlers[i].hasWorkingAbility(:PRISMARMOR)
              quakedrop =0 if @battle.battlers[i].effects[PBEffects::Protect] == true
              quakedrop =0 if @battle.battlers[i].effects[PBEffects::WideGuard] == true
              quakedrop-=1 if @battle.battlers[i].effects[PBEffects::Endure] == true
              quakedrop =0 if @battle.battlers[i].effects[PBEffects::KingsShield] == true
              quakedrop =0 if @battle.battlers[i].effects[PBEffects::SpikyShield] == true
              quakedrop =0 if @battle.battlers[i].effects[PBEffects::MatBlock] == true
              quakedrop/=3 if @battle.battlers[i].pbOwnSide.effects[PBEffects::AreniteWall]>0
              @battle.battlers[i].pbReduceHP(quakedrop) if quakedrop != 0
              @battle.battlers[i].pbFaint if @battle.battlers[i].isFainted?
            end
          end
        end
      when 30 # Mirror Shatter
        if (thismove.id == PBMoves::EARTHQUAKE || thismove.id == PBMoves::BULLDOZE ||  thismove.id == PBMoves::MAGNITUDE ||
            thismove.id == PBMoves::BOOMBURST || thismove.id == PBMoves::HYPERVOICE)
          @battle.pbDisplay(_INTL("The mirror arena shattered!"))
          for i in 0...4
            shatter = @battle.battlers[i].totalhp
            next if shatter==0
            shatter/=2
            invulcheck=PBMoveData.new(@battle.battlers[i].effects[PBEffects::TwoTurnAttack]).function
            case invulcheck
            when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
              shatter = 0
            end
            shatter =0 if @battle.battlers[i].effects[PBEffects::SkyDrop]
            shatter =0 if @battle.battlers[i].hasWorkingAbility(:SHELLARMOR)
            shatter =0 if @battle.battlers[i].hasWorkingAbility(:BATTLEARMOR)
            shatter =0 if @battle.battlers[i].effects[PBEffects::Protect] == true
            shatter =0 if @battle.battlers[i].effects[PBEffects::WideGuard] == true
            shatter =0 if @battle.battlers[i].effects[PBEffects::KingsShield] == true
            shatter =0 if @battle.battlers[i].effects[PBEffects::SpikyShield] == true
            shatter =0 if @battle.battlers[i].effects[PBEffects::MatBlock] == true
            @battle.battlers[i].pbReduceHP(shatter) if shatter != 0
            @battle.battlers[i].pbFaint if @battle.battlers[i].isFainted?
          end
        end
      when 33 # Flower Garden Stages
        tempcounter = $fecounter
        if (thismove.id == PBMoves::CUT)
          $fecounter-=1 if $fecounter > 0
        end
      when 38 # Dimensional
        combust = user.totalhp
        if combust!=0
          if (thismove.id == PBMoves::DIG || thismove.id == PBMoves::DIVE ||
              thismove.id == PBMoves::FLY || thismove.id == PBMoves::BOUNCE) && 
            user.effects[PBEffects::TwoTurnAttack] > 0
            combust-=1 if user.hasWorkingAbility(:STURDY)
            combust =0 if user.effects[PBEffects::WideGuard] == true
            combust =0 if user.effects[PBEffects::MatBlock] == true
            @battle.pbDisplay(_INTL("The corrupted field damaged {1}!",user.pbThis)) if combust != 0
            user.pbReduceHP(combust) if combust != 0
            user.pbFaint if user.isFainted?
          end
        end
      when 41 # Corrupted Cave damage
        if (thismove.id == PBMoves::HEATWAVE || 
            thismove.id == PBMoves::BLASTBURN ||
            thismove.id == PBMoves::ERUPTION ||
            thismove.id == PBMoves::LAVAPLUME)
          dampcheck=0
          for i in 0...4
            dampcheck = 1 if (!@battle.battlers[i].abilitynulled && @battle.battlers[i].ability == PBAbilities::DAMP)
          end
          if dampcheck == 0
            for i in 0...4
              combust = (@battle.battlers[i].totalhp)/2
              next if combust==0
              invulcheck=PBMoveData.new(@battle.battlers[i].effects[PBEffects::TwoTurnAttack]).function
              case invulcheck
              when 0xC9, 0xCC, 0xCA, 0xCB, 0xCD, 0xCE
                combust = 0
              end
              combust =0 if @battle.battlers[i].effects[PBEffects::SkyDrop]
              #combust-=1 if @battle.battlers[i].hasWorkingAbility(:STURDY)
              combust =0 if @battle.battlers[i].hasWorkingAbility(:FLASHFIRE)
              if (@battle.battlers[i].isbossmon && @battle.shieldCount>0)
                combust =0 
              elsif (@battle.battlers[i].isbossmon && @battle.shieldCount==0)
                combust = 0.5
              end
              combust =0 if @battle.battlers[i].effects[PBEffects::Protect] == true
              combust =0 if @battle.battlers[i].effects[PBEffects::WideGuard] == true
              #combust-=1 if @battle.battlers[i].effects[PBEffects::Endure] == true
              combust =0 if @battle.battlers[i].effects[PBEffects::KingsShield] == true
              combust =0 if @battle.battlers[i].effects[PBEffects::SpikyShield] == true
              combust =0 if @battle.battlers[i].effects[PBEffects::MatBlock] == true
              @battle.battlers[i].pbReduceHP(combust) if combust != 0
              @battle.battlers[i].pbFaint if @battle.battlers[i].isFainted?
            end
          else
            @battle.pbDisplay(_INTL("A Pokemon's Damp ability prevented a complete explosion!"))
          end
        end
      end
      # FIELD TRANSFORMATIONS 2
      case $fefieldeffect
      when 2 # Grassy Field
        if (thismove.id == PBMoves::SLUDGEWAVE)
          $fefieldeffect = 10
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The grassy terrain was corroded!"))
          @battle.seedCheck
        end
      when 3 # Misty Field
        if (thismove.id == PBMoves::WHIRLWIND || thismove.id == PBMoves::GUST ||
            thismove.id == PBMoves::RAZORWIND || thismove.id == PBMoves::HURRICANE ||
            thismove.id == PBMoves::DEFOG || thismove.id == PBMoves::TWISTER ||
            thismove.id == PBMoves::TAILWIND)
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
        if (thismove.id == PBMoves::CLEARSMOG || thismove.id == PBMoves::SMOG ||
            thismove.id == PBMoves::POISONGAS)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Poison spread through the mist!"))
          when 2
            $fefieldeffect = 11
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The mist was corroded!"))
            $fecounter = 0
            @battle.seedCheck
          end
        end
      when 4 # Dark Crystal Cavern
        if (thismove.id == PBMoves::EARTHQUAKE || thismove.id == PBMoves::BULLDOZE ||
            thismove.id == PBMoves::MAGNITUDE || thismove.id == PBMoves::TECTONICRAGE)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("The crystals began to crack..."))
          when 2
            $fefieldeffect = 23
            $febackup = 23
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The crystals shattered!"))
            $fecounter = 0
            @battle.seedCheck
          end
        end
      when 7 # Burning Field
        if (thismove.id == PBMoves::WHIRLWIND || thismove.id == PBMoves::GUST ||
            thismove.id == PBMoves::RAZORWIND || thismove.id == PBMoves::DEFOG ||
            thismove.id == PBMoves::HURRICANE || thismove.id == PBMoves::TAILWIND)
          $fefieldeffect = 23
          $febackup = 23
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The wind snuffed out the flame!"))
          @battle.field.effects[PBEffects::Terrain]=0
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::SURF || thismove.id == PBMoves::MUDDYWATER ||
            thismove.id == PBMoves::WATERSPOUT || thismove.id == PBMoves::WATERPLEDGE ||
            thismove.id == PBMoves::WATERSPORT || thismove.id == PBMoves::SPARKLINGARIA)
          if $fefieldeffect == $febackup
            $fefieldeffect = 23
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The water snuffed out the flame!"))
          @battle.field.effects[PBEffects::Terrain]=0
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::SANDTOMB)
          if $fefieldeffect == $febackup
            $fefieldeffect = 23
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The sand snuffed out the flame!"))
          @battle.field.effects[PBEffects::Terrain]=0
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::BLIZZARD)
          $fefieldeffect = 23
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The intense cold choked out the flames!"))
          @battle.field.effects[PBEffects::Terrain]=0
          @battle.seedCheck
        end
      when 10 # Corrosive Field
        if (thismove.id == PBMoves::SEEDFLARE || thismove.id == PBMoves::PURIFY)
          $fefieldeffect = 2
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The polluted field was purified!"))
          @battle.seedCheck
        end
      when 11 # Corrosive Mist Field
        if (thismove.id == PBMoves::HEATWAVE || thismove.id == PBMoves::ERUPTION ||
            thismove.id == PBMoves::SEARINGSHOT || thismove.id == PBMoves::FLAMEBURST ||
            thismove.id == PBMoves::LAVAPLUME || thismove.id == PBMoves::FIREPLEDGE ||
            thismove.id == PBMoves::EXPLOSION || thismove.id == PBMoves::SELFDESTRUCT)
          if $fefieldeffect == $febackup
            $fefieldeffect = 0
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The toxic mist combusted!"))
          @battle.field.effects[PBEffects::Terrain]=0
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::GUST || thismove.id == PBMoves::HURRICANE ||
            thismove.id == PBMoves::RAZORWIND || thismove.id == PBMoves::WHIRLWIND ||
            thismove.id == PBMoves::DEFOG || thismove.id == PBMoves::TWISTER ||
            thismove.id == PBMoves::TAILWIND)
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
      when 13 # Icy Field
        if (thismove.id == PBMoves::HEATWAVE || thismove.id == PBMoves::ERUPTION ||
            thismove.id == PBMoves::SEARINGSHOT || thismove.id == PBMoves::FLAMEBURST ||
            thismove.id == PBMoves::LAVAPLUME || thismove.id == PBMoves::FIREPLEDGE ||
            thismove.id == PBMoves::LAVASURF)
          if ($fefieldeffect == $febackup)
            $fecounter+=1
            if $fecounter==2
              $fefieldeffect = 23
              @battle.pbChangeBGSprite
              @battle.pbDisplay(_INTL("The ice melted away!"))
            end
          else
            if $febackup==21 
              $fefieldeffect = 21
            elsif $febackup==26
              $fefieldeffect = 26
            else
              $fefieldeffect = 23
            end
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The ice melted away!"))
          end    
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
              @battle.pbDisplay(_INTL("Removed all hazards from the field!"))
            end
          end
          @battle.seedCheck
        elsif (thismove.id == PBMoves::DIVE)
          if ($fefieldeffect != $febackup) && ($febackup==21 || $febackup==22 || $febackup==26)
            if $fecounter==3
              if $febackup==22
                $fefieldeffect = 21
              else
                $fefieldeffect = $febackup
              end
              @battle.pbChangeBGSprite
              @battle.pbDisplay(_INTL("The ice was broken from underneath!"))
              @battle.seedCheck  
              $fecounter=0            
            end
          end                   
        end
        if (thismove.id == PBMoves::EARTHQUAKE || thismove.id == PBMoves::MAGNITUDE ||
            thismove.id == PBMoves::BULLDOZE)
            if $fefieldeffect == $febackup
              $fecounter+=1
              if $fecounter==2
                $fefieldeffect = 23
                @battle.pbChangeBGSprite
              end
            else
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
                  @battle.pbDisplay(_INTL("Removed all hazards from the field!"))
                end
                $fefieldeffect = $febackup
                @battle.pbChangeBGSprite   
              else
                $fefieldeffect=23
                @battle.pbChangeBGSprite   
              end   
            end
            @battle.pbDisplay(_INTL("The quake broke up the ice!"))
            @battle.seedCheck
        end
      when 16 # Volcanic Top Field
        if (thismove.id == PBMoves::FLY || thismove.id == PBMoves::BOUNCE ||
            thismove.id == PBMoves::HEAVENLYWING)
          $fefieldeffect = 43
          $febackup = 43
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The battle was taken to the skies!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::BLIZZARD || thismove.id == PBMoves::GLACIATE)
          $fefieldeffect = 27
          $febackup = 27
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The field was doused of it's fire!"))
          @battle.seedCheck
        end
        # eruption check
        if (thismove.id == PBMoves::BULLDOZE || thismove.id == PBMoves::EARTHQUAKE ||
            thismove.id == PBMoves::MAGNITUDE || thismove.id == PBMoves::ERUPTION ||
            thismove.id == PBMoves::PRECIPICEBLADES || thismove.id == PBMoves::LAVAPLUME ||
            thismove.id == PBMoves::LAVASURF || thismove.id == PBMoves::EARTHPOWER)
          @battle.eruption = true
          @battle.pbDisplay(_INTL("The volcano top erupted!"))
        elsif thismove.id == PBMoves::HOTTEMPO
          @battle.eruption = true
          @battle.pbDisplay(_INTL("The tremors from the attack caused the volcano top to erupt!"))
        end
      when 17 # Factory Field
        if (thismove.id == PBMoves::DISCHARGE  || thismove.id == PBMoves::IONDELUGE ||
            thismove.id == PBMoves::OVERDRIVE || thismove.id == PBMoves::AURAWHEEL)
          @battle.pbDisplay(_INTL("SYSTEM ONLINE."))
        end
        if (thismove.id == PBMoves::EXPLOSION || thismove.id == PBMoves::SELFDESTRUCT ||
            thismove.id == PBMoves::MAGNITUDE || thismove.id == PBMoves::EARTHQUAKE ||
            thismove.id == PBMoves::FISSURE || thismove.id == PBMoves::BULLDOZE)
          $febackup = 18
          $fefieldeffect = 18
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The field was broken!"))
          @battle.seedCheck
        end
      when 18 # Shortcircuit Field
        if (thismove.id == PBMoves::PARABOLICCHARGE || thismove.id == PBMoves::WILDCHARGE || 
            thismove.id == PBMoves::CHARGEBEAM)
          $febackup = 17
          $fefieldeffect = 17
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("SYSTEM ONLINE."))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::DISCHARGE || thismove.id == PBMoves::IONDELUGE ||
            thismove.id == PBMoves::OVERDRIVE || thismove.id == PBMoves::AURAWHEEL)
          @battle.pbDisplay(_INTL("The field shorted out!"))
        end
      when 21 # Water Surface
        if (thismove.id == PBMoves::DIVE || thismove.id == PBMoves::GRAVITY ||
            thismove.id == PBMoves::ANCHORSHOT || thismove.id == PBMoves::GRAVAPPLE)
          $fefieldeffect = 22
          $febackup = 22
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The battle was pulled underwater!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::BLIZZARD || thismove.id == PBMoves::GLACIATE)
          $febackup = 21
          $fefieldeffect = 13
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The water froze over!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::SLUDGEWAVE)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Poison spread through the water!"))
          when 2
            $fefieldeffect = 26
            $febackup = 26
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The water was polluted!"))
            $fecounter = 0
            @battle.seedCheck
          end
        end
      when 22 # Underwater
        if (thismove.id == PBMoves::DIVE || thismove.id == PBMoves::SKYDROP ||
            thismove.id == PBMoves::FLY || thismove.id == PBMoves::BOUNCE ||
            thismove.id == PBMoves::SHOREUP)
          $fefieldeffect = 21
          $febackup = 21
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The battle resurfaced!"))
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
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::SLUDGEWAVE) 
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Poison spread through the water!"))
          when 2
            $fefieldeffect = 26
            $febackup = 26
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The water was polluted!"))
            @battle.pbDisplay(_INTL("The grime sunk beneath the battlers!"))
            $fecounter = 0
            @battle.seedCheck
          end
        end
      when 23 # Cave
        if (thismove.id == PBMoves::POWERGEM || thismove.id == PBMoves::DIAMONDSTORM)
          $fefieldeffect = 25
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The cave was littered with crystals!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::HOTTEMPO || thismove.id == PBMoves::LAVASURF ||
            thismove.id == PBMoves::ERUPTION || thismove.id == PBMoves::LAVAPLUME  ||
            thismove.id == PBMoves::HEATWAVE || thismove.id == PBMoves::OVERHEAT || 
            thismove.id == PBMoves::FUSIONFLARE)
          $fefieldeffect = 7
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The overwhelming heat melted the cave into slag!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::SLUDGEWAVE || thismove.id == PBMoves::ACIDDOWNPOUR)
          $fefieldeffect = 41
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The cave was corrupted!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::BLIZZARD)
          $fefieldeffect = 13
          $febackup = 23
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The cavern froze over!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::DRACOMETEOR)
          @battle.basefield = 25
          $fefieldeffect = 32
          $febackup = 32
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The draconic energy mutated the field!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::DRAGONPULSE)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Draconic energy seeps in..."))
          when 2
            @battle.basefield = 25
            $fefieldeffect = 32
            $febackup = 32
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The draconic energy mutated the field!"))
            $fecounter = 0
            @battle.seedCheck
          end
        end
      when 25 # Crystal Cavern
        if (thismove.id == PBMoves::DARKPULSE || thismove.id == PBMoves::DARKVOID ||
            thismove.id == PBMoves::NIGHTDAZE)
          $fefieldeffect = 4
          $febackup = 4
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The crystal's light was warped by the darkness!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::BULLDOZE || thismove.id == PBMoves::EARTHQUAKE ||
            thismove.id == PBMoves::MAGNITUDE)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("The crystals are cracking..."))
          when 2
            $fefieldeffect = 23
            $febackup = 23
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The crystals were broken up!"))
            $fecounter = 0
            @battle.seedCheck
          end
        end
      when 26 # Murkwater Surface
        if (thismove.id == PBMoves::WHIRLPOOL)
          $fefieldeffect = 21
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The maelstrom flushed out the poison!"))    
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
          
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::PURIFY)
          $febackup = 21
          $fefieldeffect = 21
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The attack cleared the waters!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::BLIZZARD || thismove.id == PBMoves::GLACIATE)
          $febackup = 26
          $fefieldeffect = 13
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The toxic water froze over!"))
          @battle.seedCheck
        end
      when 27 # Mountain
        if (thismove.id == PBMoves::FLY || thismove.id == PBMoves::BOUNCE ||
            thismove.id == PBMoves::HEAVENLYWING)
          $fefieldeffect = 43
          $febackup = 43
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The battle was taken to the skies!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::BLIZZARD)
          $fefieldeffect = 28
          $febackup = 28
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The mountain was covered in snow!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::LAVAPLUME || thismove.id == PBMoves::LAVASURF ||
            thismove.id == PBMoves::ERUPTION)
          $fefieldeffect = 16
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The mountain erupted!"))
          @battle.seedCheck
        end
      when 28 # Snowy Mountain
        if (thismove.id == PBMoves::FLY || thismove.id == PBMoves::BOUNCE || 
            thismove.id == PBMoves::HEAVENLYWING)
          $fefieldeffect = 43
          $febackup = 43
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The battle was taken to the skies!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::HEATWAVE || thismove.id == PBMoves::FLAMEBURST ||
            thismove.id == PBMoves::LAVAPLUME || thismove.id == PBMoves::SEARINGSHOT ||
            thismove.id == PBMoves::FIREPLEDGE)
          $fefieldeffect = 27
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The snow melted away!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::ERUPTION || thismove.id == PBMoves::LAVASURF)
          $fefieldeffect = 16
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The mountain erupted!"))
          @battle.seedCheck
        end
      when 29 # Holy
        if ((thismove.id == PBMoves::CURSE && (isConst?(user.type1,PBTypes,:GHOST) || isConst?(user.type2,PBTypes,:GHOST))) || thismove.id == PBMoves::PHANTOMFORCE ||
            thismove.id == PBMoves::SHADOWFORCE || thismove.id == PBMoves::SPECTRALSCREAM ||
            thismove.id == PBMoves::OMINOUSWIND)
          if $fefieldeffect == $febackup
            $fefieldeffect = 40
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("Evil spirits gathered!"))
        end
      when 30 # Mirror
        if (thismove.id == PBMoves::EARTHQUAKE || thismove.id == PBMoves::BOOMBURST ||
            thismove.id == PBMoves::BULLDOZE || thismove.id == PBMoves::HYPERVOICE ||
            thismove.id == PBMoves::MAGNITUDE)
          $fefieldeffect = 0
          $febackup = 0
          @battle.pbChangeBGSprite
          @battle.seedCheck
        end
      when 32 # Dragon's Den
        if (thismove.id == PBMoves::MISTBALL)
          @battle.basefield = 0
          $fefieldeffect = 31
          $febackup = 31
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The mist-ical energy altered the surroundings!"))
          @battle.seedCheck
        end
      when 33 # Flower Garden Field
        if $fecounter >1
          if (thismove.id == PBMoves::HEATWAVE || thismove.id == PBMoves::ERUPTION ||
              thismove.id == PBMoves::SEARINGSHOT || thismove.id == PBMoves::FLAMEBURST ||
              thismove.id == PBMoves::LAVAPLUME || thismove.id == PBMoves::FIREPLEDGE) &&
            @battle.field.effects[PBEffects::WaterSport] <= 0 &&
            @battle.pbWeather != PBWeather::RAINDANCE
            $fecounter-=2
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The garden caught fire!"))
            @battle.seedCheck
          end
        end
        if tempcounter > $fecounter
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The garden was cut down a bit!"))
        end
      when 38 # Dimensional Rift
        if (thismove.id == PBMoves::BLIZZARD || thismove.id == PBMoves::COLDTRUTH ||
            thismove.id == PBMoves::ICEBURN || thismove.id == PBMoves::FREEZESHOCK || 
            thismove.id == PBMoves::GLACIATE || thismove.id == PBMoves::SHEERCOLD)
          $febackup = 39
          $fefieldeffect = 39
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The dimension froze up!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::SEEDFLARE || thismove.id == PBMoves::PURIFY) &&
          @battle.pbWeather != PBWeather::SHADOWSKY
          $febackup = 0
          $fefieldeffect = 0
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The dimension was purified!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::PRECIPICEBLADES)  
          $fefieldeffect = 45  
          $febackup = 45  
          @battle.pbChangeBGSprite  
          @battle.pbDisplay(_INTL("The field went up in flames!"))  
          @battle.seedCheck  
        end
      when 39 # Angie
        if (thismove.id == PBMoves::HEATWAVE || thismove.id == PBMoves::ERUPTION ||
            thismove.id == PBMoves::INFERNO || thismove.id == PBMoves::FLAMEBURST ||
            thismove.id == PBMoves::LAVAPLUME || thismove.id == PBMoves::BLASTBURN ||
            thismove.id == PBMoves::BURNUP || thismove.id == PBMoves::INFERNOOVERDRIVE)
          $febackup = 38
          $fefieldeffect = 38
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The dimension thawed away!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::PURIFY)
          $febackup = 13
          $fefieldeffect = 13
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The dimension cleared was purified!"))
          @battle.seedCheck
        end
      when 40 # Haunted
        if (thismove.id == PBMoves::JUDGMENT || thismove.id == PBMoves::SACREDFIRE ||
            thismove.id == PBMoves::ORIGINPULSE)
          if $fefieldeffect == $febackup
            $fefieldeffect = 29
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The evil spirits have been exorcised!"))
          @battle.seedCheck
        elsif (thismove.id == PBMoves::DAZZLINGGLEAM || thismove.id == PBMoves::FLASH || thismove.id == PBMoves::PURIFY)
          if $game_map.map_id!=111
            if $fefieldeffect == $febackup
              $fefieldeffect = 0
            else
              $fefieldeffect = $febackup
            end
            @battle.field.effects[PBEffects::Terrain]=3
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The evil spirits have been forced back!"))
            @battle.seedCheck
          end
        end
      when 41 # Corrupted cave
        if (thismove.id == PBMoves::SEEDFLARE || thismove.id == PBMoves::SOLARBEAM ||
            thismove.id == PBMoves::SOLARBLADE || thismove.id == PBMoves::PURIFY)
          if $fefieldeffect == $febackup
            $fefieldeffect = 23
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The cave was purified!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::HEATWAVE || thismove.id == PBMoves::BLASTBURN ||
            thismove.id == PBMoves::ERUPTION || thismove.id == PBMoves::LAVAPLUME ||
            thismove.id == PBMoves::INFERNOOVERDRIVE)
          if $fefieldeffect == $febackup
            $fefieldeffect = 7
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The cave's corruption combusted!"))
          @battle.seedCheck
        end
      when 42 # Bewitched Woods
        if (thismove.id == PBMoves::PURIFY)
          if $fefieldeffect == $febackup
            $fefieldeffect = 15
          else
            $fefieldeffect = $febackup
          end
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The evil spirits have been exorcised!"))
          @battle.seedCheck
        end
      when 43 # Sky Field
        if (thismove.id == PBMoves::GRAVITY || thismove.id == PBMoves::INGRAIN ||
            thismove.id == PBMoves::THOUSANDARROWS)
          $fefieldeffect = 27
          $febackup = 27
          @battle.pbChangeBGSprite
          @battle.pbDisplay(_INTL("The battle has been brought down to the mountains!"))
          @battle.seedCheck
        end
        if (thismove.id == PBMoves::SMACKDOWN || thismove.id == PBMoves::GRAVAPPLE)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Altitude is being lost!"))
          when 2
            $fefieldeffect = 27
            $febackup = 27
            @battle.pbChangeBGSprite
            @battle.pbDisplay(_INTL("The battle has been brought down to the mountains!"))
            $fecounter = 0
            @battle.seedCheck
          end            
        end
      when 45 # Infernal Field  
        if (thismove.id == PBMoves::JUDGMENT || thismove.id == PBMoves::ORIGINPULSE)  
          $fefieldeffect = 7  
          $febackup = 7  
          @battle.pbChangeBGSprite  
          @battle.pbDisplay(_INTL("The hellish landscape was purified!"))  
          @battle.seedCheck  
        end  
        if (thismove.id == PBMoves::GLACIATE)  
          $fefieldeffect = 39  
          $febackup = 39  
          @battle.pbChangeBGSprite  
          @battle.pbDisplay(_INTL("The hellish landscape was doused of it's fire!"))  
          @battle.seedCheck  
        end
      end
      #End Field Transformations
      # TODO: Sheer Force should prevent effects of items/abilities/moves that
      #       trigger here - which ones?
      if !((user.hasWorkingAbility(:SHEERFORCE) || @battle.SilvallyCheck(user,PBTypes::GROUND)) && thismove.addlEffect>0)
        # Shell Bell
        if user.hasWorkingItem(:SHELLBELL) && turneffects[PBEffects::TotalDamage]>0 && @effects[PBEffects::HealBlock]==0
          hpgain=user.pbRecoverHP([(turneffects[PBEffects::TotalDamage]/8).floor,1].max,true)
          if hpgain>0
            @battle.pbDisplay(_INTL("{1} restored a little HP using its Shell Bell!",user.pbThis))
          end
        end
        # Life Orb
        if user.hasWorkingItem(:LIFEORB) && turneffects[PBEffects::TotalDamage]>0 &&
          !user.hasWorkingAbility(:MAGICGUARD) && !(user.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
          if user.effects[PBEffects::ShieldLife]>0
            lifeorbdamage=(user.totalhp/10).floor
            hploss=lifeorbdamage
            @battle.pbShieldDamage(user,lifeorbdamage,thismove)
          else
            hploss=user.pbReduceHP([(user.totalhp/10).floor,1].max,true)
          end
          if hploss>0
            @battle.pbDisplay(_INTL("{1} lost some of its HP!",user.pbThis))
          end
        end
        user.pbFaint if user.isFainted? # no return
      end
      unless !thismove
        pbDancerMoveCheck(thismove.id) unless danced
      end      
      # Switch moves
      for i in @battle.battlers
        if i.userSwitch == true
          i.userSwitch = false
          if !(@battle.pbIsWild? && !@battle.pbOwnedByPlayer?(i.index))
            @battle.pbDisplay(_INTL("{1} went back to {2}!",i.pbThis,@battle.pbGetOwner(i.index).name))
          end
          newpoke=0
          newpoke=@battle.pbSwitchInBetween(i.index,true,false) 
          @battle.pbMessagesOnReplace(i.index,newpoke)
          i.vanished=false
          i.pbResetForm
          @battle.pbReplace(i.index,newpoke,false)
          @battle.pbOnActiveOne(i)
          i.pbAbilitiesOnSwitchIn(true)
          if @battle.field.effects[PBEffects::WonderRoom] > 0
            if !(i.isFainted?)
              if i.wonderroom==false
                i.pbSwapDefenses
              end
            end
          end
        end
        if i.forcedSwitch == true          
          i.forcedSwitch = false
          party=@battle.pbParty(i.index)
          j=-1
          until j!=-1
            j=@battle.pbRandom(party.length)
            if !((i.isFainted? || j!=i.pokemonIndex) &&
                (pbPartner.isFainted? || j!=i.pbPartner.pokemonIndex) &&
                party[j] && !party[j].isEgg? && party[j].hp>0)
              j=-1
            end
            if !@battle.pbCanSwitchLax?(i.index,j,false)  
              j=-1
            end            
          end                            
          newpoke=j#@battle.pbParty(i.index)[j]
          # newpoke=@battle.choices[@battle.pbRandom(@battle.choices.length)]
          i.vanished=false
          i.pbResetForm
          @battle.pbReplace(i.index,newpoke,false)
          @battle.pbOnActiveOne(i)
          i.pbAbilitiesOnSwitchIn(true)
          if @battle.field.effects[PBEffects::WonderRoom] > 0
            if !(i.isFainted?)
              if i.wonderroom==false
                i.pbSwapDefenses
              end
            end
          end
          @battle.pbDisplay(_INTL("{1} was dragged out!",i.pbThis))
          i.forcedSwitchEarlier = true
        end
      end
    end
    if user.effects[PBEffects::LaserFocus]>0
      user.effects[PBEffects::LaserFocus]-=1
    end
    @battle.pbGainEXP
    # Battle Arena only - update skills
    for i in 0...4
      @battle.successStates[i].updateSkill
    end
    # Swalot Crest
    if isConst?(user.species,PBSpecies,:SWALOT) && user.hasWorkingItem(:SWACREST)
      if thismove.id == PBMoves::BELCH
        move=getConst(PBMoves,:SPITUP) || 0
        movename=PBMoves.getName(move)
        @battle.pbDisplay(_INTL("{1} used {2}!",user.pbThis,movename))
        user.pbUseMoveSimple(move)
      end
      if(thismove.id!=PBMoves::STOCKPILE && thismove.id!=PBMoves::SPITUP &&
          thismove.id!=PBMoves::SWALLOW) && user.effects[PBEffects::Stockpile] < 3
        user.effects[PBEffects::Stockpile]+=1
        @battle.pbDisplay(_INTL("{1} stockpiled {2}!",user.pbThis,
            user.effects[PBEffects::Stockpile]))
        showanim=true
        if user.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
          user.pbIncreaseStat(PBStats::DEFENSE,1,false,showanim)
          user.effects[PBEffects::StockpileDef]+=1
          showanim=false
        end
        if user.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
          user.pbIncreaseStat(PBStats::SPDEF,1,false,showanim)
          user.effects[PBEffects::StockpileSpDef]+=1
          showanim=false
        end
      end
    end
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
    if self.status==PBStatuses::SLEEP && !self.hasWorkingAbility(:SOUNDPROOF)
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Uproar]>0 || @battle.battlers[i].effects[PBEffects::FeverPitch]==true
          pbCureStatus(false)
          @battle.pbDisplay(_INTL("{1} woke up in the uproar!",pbThis))
        end
      end
    end
  end
  
  def pbEndTurn(choice)
    # True end(?)
    if @effects[PBEffects::ChoiceBand]<0 && @lastMoveUsed>=0 && !self.isFainted? && 
      (self.hasWorkingItem(:CHOICEBAND) ||
        self.hasWorkingItem(:CHOICESPECS) ||
        self.hasWorkingItem(:CHOICESCARF) ||
        self.hasWorkingAbility(:GORILLATACTICS))
      @effects[PBEffects::ChoiceBand]=@lastMoveUsed
    end
    @battle.synchronize[0]=-1
    @battle.synchronize[1]=-1
    @battle.synchronize[2]=0
    for i in 0...4
      @battle.battlers[i].pbAbilityCureCheck
      @battle.battlers[i].pbBerryCureCheck
      @battle.battlers[i].pbAbilitiesOnSwitchIn(false)
      @battle.battlers[i].pbCheckForm
      #End of turn ability nullification check
      if @battle.battlers[i].abilitynulled == true 
        if !(@battle.battlers[i].abilityWorks?)
          @battle.battlers[i].abilitynulled = true
        else
          @battle.battlers[i].abilitynulled = false
        end
      end
    end
    #### JERICHO - 013 - START    
    if !self.missed && $takegem == 1 && (self.isConst?(item,PBItems,:NORMALGEM) || self.isConst?(item,PBItems,:FIGHTINGGEM) || 
        self.isConst?(item,PBItems,:FLYINGGEM) || self.isConst?(item,PBItems,:POISONGEM) || 
        self.isConst?(item,PBItems,:GROUNDGEM) || self.isConst?(item,PBItems,:ROCKGEM) ||
        self.isConst?(item,PBItems,:BUGGEM) || self.isConst?(item,PBItems,:GHOSTGEM) || 
        self.isConst?(item,PBItems,:STEELGEM) || self.isConst?(item,PBItems,:FIREGEM) || 
        self.isConst?(item,PBItems,:WATERGEM) || self.isConst?(item,PBItems,:GRASSGEM) ||
        self.isConst?(item,PBItems,:ELECTRICGEM) || self.isConst?(item,PBItems,:PSYCHICGEM) || 
        self.isConst?(item,PBItems,:ICEGEM) || self.isConst?(item,PBItems,:DRAGONGEM) || 
        self.isConst?(item,PBItems,:DARKGEM)) || self.isConst?(item,PBItems,:FAIRYGEM)
      self.item=0
    end
    #### JERICHO - 013 - END
    @effects[PBEffects::ThunderRaidHit]=0
    @effects[PBEffects::ThunderRaidStat]=[0,0,0,0,0]
    self.missed = true
    self.missAcc = false
    self.statLowered = false
  end
  
  def pbProcessTurn(choice)
    # Can't use a move if fainted
    return if self.isFainted?
    # Wild roaming Pokémon always flee if possible
    if !@battle.opponent && @battle.pbIsOpposing?(self.index) &&
      @battle.rules["alwaysflee"] && @battle.pbCanRun?(self.index)
      pbBeginTurn(choice)
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
    if choice[2].zmove && !@effects[PBEffects::Flinch] && @status!=PBStatuses::SLEEP && @status!=PBStatuses::FROZEN
      choice[2].zmove=false
      @battle.pbUseZMove(self.index,choice[2],self.item,choice[1])
    else
      choice[2].zmove=false if choice[2].zmove # For flinches
      #    @battle.pbDisplayPaused("Before: [#{@lastMoveUsedSketch},#{@lastMoveUsed}]")
      @battle.previousMove = @battle.lastMoveUsed
      @previousMove = @lastMoveUsed
      PBDebug.logonerr{
        pbUseMove(choice,choice[2]==@battle.struggle)
      }
      if !(@battle.pbOwnedByPlayer?(self.index))
        if @battle.revealedMoves[0][self.pokemonIndex].length==0 
          @battle.revealedMoves[0][self.pokemonIndex].push(choice[2])       
        else
          dupecheck=0
          for i in @battle.revealedMoves[0][self.pokemonIndex]
            dupecheck+=1 if i.id == choice[2].id
          end
          @battle.revealedMoves[0][self.pokemonIndex].push(choice[2]) if dupecheck==0
        end    
      end
      if (self.index==0 || self.index==2) && !@battle.isOnline? # Move memory system for AI
        if @battle.aiMoveMemory[0].length==0 && choice[2].basedamage!=0
          @battle.aiMoveMemory[0].push(choice[2])
        elsif @battle.aiMoveMemory[0].length!=0 && choice[2].basedamage!=0          
          dam1=@battle.pbRoughDamage(choice[2],self,@battle.battlers[1],255,choice[2].basedamage)
          dam2=@battle.pbRoughDamage(@battle.aiMoveMemory[0][0],self,@battle.battlers[1],255,@battle.aiMoveMemory[0][0].basedamage)
          if dam1>dam2
            @battle.aiMoveMemory[0].clear
            @battle.aiMoveMemory[0].push(choice[2])
          end          
        end                    
        if @battle.aiMoveMemory[1].length==0 
          @battle.aiMoveMemory[1].push(choice[2])        
        else
          dupecheck=0
          for i in @battle.aiMoveMemory[1]
            dupecheck+=1 if i.id == choice[2].id
          end
          @battle.aiMoveMemory[1].push(choice[2]) if dupecheck==0
        end 
        if @battle.aiMoveMemory[2][self.pokemonIndex].length==0 
          @battle.aiMoveMemory[2][self.pokemonIndex].push(choice[2])        
        else
          dupecheck=0
          for i in @battle.aiMoveMemory[2][self.pokemonIndex]
            dupecheck+=1 if i.id == choice[2].id
          end
          @battle.aiMoveMemory[2][self.pokemonIndex].push(choice[2]) if dupecheck==0
        end         
      end
    end    
    #   @battle.pbDisplayPaused("After: [#{@lastMoveUsedSketch},#{@lastMoveUsed}]")
  end
  #### KUROTSUNE - 014 - START
  def pbSwapDefenses
    aux = @spdef
    @spdef = defense
    @defense = aux
    if @wonderroom
      @wonderroom = false
    else
      @wonderroom = true
    end
  end
  #### KUROTSUNE - 014 - END
end



