class FEData
	attr_accessor :fieldname
	attr_accessor :intromessage
	attr_accessor :fieldgraphics
	attr_accessor :secretpoweranim
	attr_accessor :naturemoves
	attr_accessor :mimicry
	attr_accessor :seeddata
	attr_accessor :fieldtypedata
	attr_accessor :fieldmovedata
	attr_accessor :movemessagelist
	attr_accessor :typemessagelist
	attr_accessor :changemessagelist
	attr_accessor :statusmoveboost
  attr_accessor :fieldchangeconditions

	def initialize
		@fieldname = nil
		@intromessage = nil
		@fieldgraphics = "IndoorA"
		@secretpoweranim = PBMoves::TRIATTACK
		@naturemoves = PBMoves::TRIATTACK
		@mimicry = PBMoves::TRIATTACK
		@fieldmovedata = {}
		@fieldtypedata = {}
		@seeddata = {}
		@movemessagelist = {}
		@typemessagelist = {}
		@changemessagelist = {}
		@statusmoveboost = []
	end
end

class PokeBattle_Field
  attr_accessor :effect               #field effect ID
  attr_accessor :data                 #associated field information
  attr_accessor :layer                #order of fields, stacked up from base
  attr_accessor :counter              #counter for certain field triggers
  attr_accessor :pledge               #whether a pledge move has been used
  attr_accessor :conversion           #whether conversion has been used
  attr_accessor :duration             #number of turns remaining on a temporary field
  attr_accessor :duration_condition   #condition to still keep remaining on a temporary field
  attr_accessor :permanent_condition  #condition to change a temp field into a permanent field
  attr_accessor :overlay              #layer index of the temporary field
  attr_accessor :roll     
  attr_accessor :old_counter          #old counter value that shouldn't be overwritten when field returns

  def initialize
    @pledge = nil
    @conversion = nil
    @counter = 0
    @duration = 0
    @duration_condition = nil
    @permanent_condition = nil
    @roll = 0
    @overlay = nil 

    basefield= $game_map ? pbGetMetadata($game_map.map_id,MetadataBattleBack) : 0
    #Base field is no field
    @layer=[]
    @layer[0] = FIELDEFFECTS.find_index {|fekey,fevalue| fevalue[:FIELDGRAPHICS] == basefield} || 0
    @layer[0] = 21 if $PokemonGlobal.surfing
    @layer[0] = 26 if $game_map.terrain_tag($game_player.x,$game_player.y) == PBTerrain::PokePuddle #Murkwater
    # Field Effect override from variable
    if $game_variables[:Forced_Field_Effect] <= 42 && $game_variables[:Forced_Field_Effect] > 0 
      @layer.push($game_variables[:Forced_Field_Effect])
    end
    @effect = @layer[-1]
    setData
  end

  def setData
    @data = $cache.FEData[@effect]
  end

  def isFieldEffect?
    return false if @effect == 0
    return false if Reborn && @effect > 37
    return false if Rejuv && @effect > 37
    return false if Desolation && @effect > 37
    return true
  end

  def backup
    return @layer[-2] if @layer[-2]
    return PBFields::NONE
  end

  def resetFieldVars(newfield=nil,oldfield=nil, temp_field=false)
    @old_counter = @counter if temp_field && oldfield == PBFields::FLOWERGARDENF
    @pledge = nil
    @conversion = nil
    @counter = 0
    if @old_counter && newfield == PBFields::FLOWERGARDENF
      @counter = @old_counter 
      @old_counter = nil
    end
  end

  def getRoll(update_roll: true)
    case @effect
      when PBFields::CRYSTALC       then choices = PBStuff::CCROLLS
      when PBFields::SHORTCIRCUITF  then choices = PBStuff::SHORTCIRCUITROLLS
    end
    result=choices[@roll]
    @roll = (@roll + 1) % choices.length if update_roll
    return result
  end

  def checkPermCondition(battle)
    return if !@permanent_condition
    return if !@permanent_condition.call(battle)
    @duration=0
    @overlay=nil
    @permanent_condition=nil
    @duration_condition=nil
  end
  #FIELDEFFECTS hash helpers
  def moveData(moveid)
    return @data.fieldmovedata[moveid]
  end

  def typeData(type)
    return @data.fieldtypedata[type]
  end

  def fieldChangeData
    return @data.fieldchangeconditions
  end

  def introMessage
    return @data.intromessage
  end

  def statusMoves
    return @data.statusmoveboost
  end

  def seeds
    return @data.seeddata
  end

  def mimicry
    return @data.mimicry
  end

  def backdrop
    return "Glitch2" if Reborn && @effect == 24 && $game_map.map_id == 898  # for anna specifically
    return @data.fieldgraphics if @effect > 0 && @effect <= 42
    map_bg = pbGetMetadata($game_map.map_id,MetadataBattleBack)
    return $cache.FEData[0].fieldgraphics if map_bg.nil?
    related_fe = FIELDEFFECTS.find_index {|fekey,fevalue| fevalue[:FIELDGRAPHICS] == map_bg}
    return pbGetMetadata($game_map.map_id,MetadataBattleBack) if related_fe == nil
    return $cache.FEData[0].fieldgraphics
  end

  def naturePower 
    return PBMoves::PETALBLIZZARD if @effect == PBFields::FLOWERGARDENF && @counter == 4
    return @data.naturemoves if @data.naturemoves
    return PBMoves::TRIATTACK
  end

  def secretPowerAnim
    if @counter > 1 && @effect == PBFields::FLOWERGARDENF
      return PBMoves::PETALDANCE if @counter == 4
      return PBMoves::PETALBLIZZARD
    end
    return @data.secretpoweranim if @data.secretpoweranim
    return PBMoves::TRIATTACK
  end

  def checkPledge(moveid)
    return @pledge && @pledge != moveid
  end

  def self.getFieldName(field)
    return "no field" if field == 0
    return $cache.FEData[field].fieldname if $cache.FEData[field].fieldname
    return ""
  end

end

class PokeBattle_FieldOnline < PokeBattle_Field
  def initialize(field)
    @pledge = nil
    @conversion = nil
    @counter = 0
    @duration = 0
    @roll = 0
    @overlay = nil 
    #Base field is no field
    @layer=[]
    @layer[0] = field
    # Field Effect override from variable
    if $feonline <= 42 && $feonline > 0 
      @layer.push($feonline)
    end
    @effect = @layer[-1]
    setData
  end

  def backdrop
    return @data.fieldgraphics if @effect > 0 && @effect <= 42
    return $cache.FEData[0].fieldgraphics
  end

  def self.getFieldName(field)
    return "no field" if field == 0
    return $cache.FEData[field].fieldname if $cache.FEData[field].fieldname
    return ""
  end

end

class PokeBattle_Battle

  def noWeather
    return if @field.effect != PBFields::UNDERWATER && @field.effect != PBFields::NEWW
    if @weather != 0
      @weatherduration=0
      if @field.effect == PBFields::NEWW
        pbDisplay(_INTL("The weather disappeared into space!"))
      elsif @field.effect == PBFields::UNDERWATER
        pbDisplay(_INTL("You're too deep to notice the weather!"))
      else
        case @weather
          when PBWeather::SUNNYDAY then pbDisplay(_INTL("The sunlight faded."))
          when PBWeather::RAINDANCE then pbDisplay(_INTL("The rain stopped."))
          when PBWeather::SANDSTORM then pbDisplay(_INTL("The sandstorm subsided."))
          when PBWeather::HAIL then pbDisplay(_INTL("The hail stopped."))
          when PBWeather::STRONGWINDS then pbDisplay(_INTL("The mysterious air current has dissipated!"))
        end
      end
    end
    pbDisplay(_INTL("The shadow sky faded.")) if isConst?(@weather,PBWeather,:SHADOWSKY)
    @weather=0
  end

  def setField(fieldeffect,temp=false, add_on: false)
    return if @field == fieldeffect
    animfieldref = @field.effect
    @field.effect = fieldeffect
    @field.checkPermCondition(self)
    if temp
      @field.overlay = @field.layer.length if (!@field.overlay || @field.overlay<=0)
    end
    # Setting the new Field
    oldfield = @field.effect
    oldfield = @field.layer.pop if !temp && !add_on
    @field.layer.push(fieldeffect)

    # Animation
    case fieldeffect
      when PBFields::RAINBOWF
        if animfieldref != PBFields::RAINBOWF
          @battle.pbCommonAnimation("RainbowT")
        else
          @battle.pbCommonAnimation("RainbowE")
        end
      when PBFields::GLITCHF
        if animfieldref != PBFields::GLITCHF
          @battle.pbCommonAnimation("GlitchT")
        else
          @battle.pbCommonAnimation("GlitchE")
        end
    end

    # Changes
    @field.resetFieldVars(@field.effect, oldfield, temp || add_on)
    @field.setData
    pbChangeBGSprite
    seedCheck
  end

  def canChangeFE?(newfield=[])
    newfield = [newfield] if newfield && !newfield.is_a?(Array)
    return !([PBFields::UNDERWATER,PBFields::NEWW]+newfield).include?(@field.effect)
  end

  def breakField
    oldfield = @field.layer.pop
    @field.effect = @field.layer[-1] || getNoField
    @field.resetFieldVars(@field.effect, oldfield)
    @field.setData
    pbChangeBGSprite
    seedCheck
  end

  def endTempField
    oldfield = nil
    while @field.layer.length > @field.overlay
      oldfield = @field.layer.pop
    end
    @field.overlay -= 1
   
    @field.effect = @field.layer[-1] || getNoField
    @field.resetFieldVars(@field.effect,oldfield)
    @field.permanent_condition = nil
    @field.duration_condition = nil
    @field.setData
    pbChangeBGSprite
    seedCheck
  end

  def getNoField #for when the base graphic isn't blank
    basefieldbg = $game_map ? pbGetMetadata($game_map.map_id,MetadataBattleBack) : ""
    basefield = FIELDEFFECTS.find_index {|fekey,fevalue| fevalue[:FIELDGRAPHICS] == basefieldbg}
    basefield = 0 if basefield.nil? || basefield < 38
    return basefield
  end

  def canSetWeather?
    return !(@field.effect == PBFields::NEWW || @field.effect == PBFields::UNDERWATER)
  end

  def setPledge(moveid)
    @field.pledge = moveid if @field.pledge == nil
    return if @field.pledge == moveid
    pledgepair = [moveid,@field.pledge]
    setField(PBFields::SWAMPF,true) if !(pledgepair.include?(PBMoves::FIREPLEDGE))
    setField(PBFields::RAINBOWF,true) if !(pledgepair.include?(PBMoves::GRASSPLEDGE))
    setField(PBFields::BURNINGF,true) if !(pledgepair.include?(PBMoves::WATERPLEDGE))
    @field.pledge = nil
  end

  def fieldeffect
    return @field.effect
  end

  def FE
    return @field.effect
  end

  def fieldEffectAfterMove(thismove)
    # FIELD TRANSFORMATIONS
    # sorry cass this seems to be the right timing here but i'm so sorry to do this to your beautiful code
    case @field.effect 
      when PBFields::CORROSIVEMISTF
        @battle.mistExplosion if PBFields::IGNITEMOVES.include?(thismove.id) || [PBMoves::SELFDESTRUCT, PBMoves::EXPLOSION].include?(thismove.id)
      when PBFields::CAVE
        if PBFields::QUAKEMOVES.include?(thismove.id)
          @battle.caveCollapse
          return
        end
      when PBFields::MIRRORA
        @battle.mirrorShatter if PBFields::QUAKEMOVES.include?(thismove.id) || [PBMoves::BOOMBURST, PBMoves::HYPERVOICE, PBMoves::SELFDESTRUCT,PBMoves::EXPLOSION].include?(thismove.id)
      when PBFields::MISTYT # Misty Field
        if (thismove.id == PBMoves::CLEARSMOG || thismove.id == PBMoves::SMOG ||
         thismove.id == PBMoves::POISONGAS || thismove.id == PBMoves::ACIDDOWNPOUR)
         @field.counter += 1
         @field.counter = 2 if thismove.id == PBMoves::ACIDDOWNPOUR
          case @field.counter
            when 1
              pbDisplay(_INTL("Poison spread through the mist!"))
            when 2
              setField(PBFields::CORROSIVEMISTF)
              pbChangeBGSprite
              pbDisplay(_INTL("The mist was corroded!"))
              @field.counter = 0
              seedCheck
          end
        end
      when PBFields::WATERS # Water Surface #Underwater handled ~300 lines above
        if (thismove.id == PBMoves::SLUDGEWAVE || thismove.id==PBMoves::ACIDDOWNPOUR)
          @field.counter += 1 if thismove.id == PBMoves::SLUDGEWAVE
          @field.counter = 2 if thismove.id==PBMoves::ACIDDOWNPOUR
          case @field.counter
            when 1
              pbDisplay(_INTL("Poison spread through the water!"))
            when 2
              setField(PBFields::MURKWATERS)
              pbDisplay(_INTL("The water was polluted!"))
          end
        end
      when PBFields::DRAGONSD # Dragon's Den
        if (thismove.id == PBMoves::MUDDYWATER || thismove.id == PBMoves::SURF || thismove.id == PBMoves::SPARKLINGARIA)
          @field.counter += 1
          case @field.counter
            when 1
              pbDisplay(_INTL("The lava began to harden!"))
            when 2
              setField(PBFields::CAVE)
              pbDisplay(_INTL("The lava solidified!"))
              @field.counter = 0
              seedCheck
          end
        end
      when 33 # Flower Garden Field
        if @field.counter > 1
          if (PBFields::IGNITEMOVES.include?(thismove.id)) && state.effects[PBEffects::WaterSport] <= 0 && pbWeather != PBWeather::RAINDANCE
            setField(PBFields::BURNINGF)
            pbDisplay(_INTL("The garden caught fire!"))
          end
        end
        tempcounter = @field.counter
        if (thismove.id == PBMoves::CUT || thismove.id == PBMoves::XSCISSOR)
          @field.counter-=1 if @field.counter > 0
        end
        if tempcounter > @field.counter
          pbChangeBGSprite
          pbDisplay(_INTL("The garden was cut down a bit!"))
        end
    end
    fieldmove = @field.moveData(thismove.id)
    return if !fieldmove || !fieldmove[:fieldchange]
    change_conditions = @battle.field.fieldChangeData
    if change_conditions[fieldmove[:fieldchange]]
      return if !thismove.runCondition(change_conditions[fieldmove[:fieldchange]])
    end
    pbDisplay(_INTL(@field.data.changemessagelist[fieldmove[:changetext]-1])) if fieldmove[:changetext]
    newfield = fieldmove[:fieldchange]
    if newfield == 0
      breakField 
    elsif newfield > 0
      dont_change_backup = fieldmove[:dontchangebackup]
      setField(newfield, add_on: dont_change_backup)
      noWeather
    end
    eval(fieldmove[:changeeffect]) if fieldmove[:changeeffect]
  end


  #Specific Field Functions
  def mistExplosion
    if !pbCheckGlobalAbility(:DAMP)
      pbDisplay(_INTL("The toxic mist combusted!"))
      for i in @battlers
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
      pbDisplay(_INTL("A Pokémon's Damp ability prevented a complete explosion!"))
      return false
    end
  end

  #Cave
  def caveCollapse
    if @field.counter == 0
      pbDisplay(_INTL("Bits of rock fell from the crumbling ceiling!"))
      @field.counter+=1
    elsif @field.counter > 0
      @field.counter = 0
      pbDisplay(_INTL("The quake collapsed the ceiling!"))
      $game_variables[:Cave_Collapse] = 1
      for i in @battlers
        #rewriting this for sanity purposes. "next if" implies quakedrop == 0
        quakedrop = i.totalhp
        for j in PBStuff::INVULEFFECTS
          quakedrop = 0 if i.effects[j] == true
        end
        next if quakedrop == 0
        next if i.ability == PBAbilities::BULLETPROOF || i.ability == PBAbilities::ROCKHEAD
        next if PBStuff::TWOTURNMOVE.include?(i.effects[PBEffects::TwoTurnAttack])
        next if i.pbOwnSide.effects[PBEffects::WideGuard]
        next if i.effects[PBEffects::SkyDrop]
        quakedrop -= 1 if i.effects[PBEffects::Endure] || i.ability == PBAbilities::STURDY
        quakedrop /= 2 if i.ability == PBAbilities::SHELLARMOR || i.ability == PBAbilities::BATTLEARMOR
        quakedrop /= 3 if i.ability == PBAbilities::PRISMARMOR || i.ability == PBAbilities::SOLIDROCK
        i.pbReduceHP(quakedrop) if quakedrop != 0
        i.pbFaint if i.isFainted?
      end
    end
    return false
  end

  #Mirror
  def mirrorShatter
    pbDisplay(_INTL("The mirror arena shattered!"))
    for i in @battlers
      #rewriting this for sanity purposes. "next if" implies shatter == 0
      shatter = i.totalhp / 2
      for j in PBStuff::INVULEFFECTS
        shatter = 0 if i.effects[j] == true
      end
      next if shatter == 0
      next if PBStuff::TWOTURNMOVE.include?(i.effects[PBEffects::TwoTurnAttack])
      next if i.ability == PBAbilities::SHELLARMOR || i.ability == PBAbilities::BATTLEARMOR
      next if i.pbOwnSide.effects[PBEffects::WideGuard]
      next if i.effects[PBEffects::SkyDrop]
      i.pbReduceHP(shatter) if shatter != 0
      i.pbFaint if i.isFainted?
    end
    return true
  end

  #Flower Garden
  def growField(text)
    return if @field.counter == 4 || @field.effect != PBFields::FLOWERGARDENF
    @field.counter += 1
    pbChangeBGSprite
    pbDisplay(_INTL("{1} grew the garden!",text))
  end

  def NWTypeRoll(mon)
    roll = [0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,18].sample
    mon.type1 = roll
    mon.type2 = roll
    roll += 19 if $game_switches[:Pulse_Arceus] && mon.species == PBSpecies::ARCEUS
    if mon.form != roll
      mon.form = roll
      pbDisplay(_INTL("{1}'s {2} activated!",mon.pbThis,PBAbilities.getName(mon.ability)))
      pbCommonAnimation("TypeRoll",mon,nil)
      mon.form=mon.pokemon.form
      mon.pbUpdate(true)
      @scene.pbChangePokemon(mon,mon.pokemon)
      pbDisplay(_INTL("{1} rolled the {2} type!",mon.pbThis,PBTypes.getName(roll%19)))
    end
  end

  #friendly helpful function to avoid calling triple-nested arrays in the code
  #gosh whose idea was that
  def fieldeffectchecker(parameter,section) #find [thing] in [place]
    if FIELDEFFECTS[@field.effect][section]
      for object in FIELDEFFECTS[@field.effect][section].keys
        for i in FIELDEFFECTS[@field.effect][section][object]
          return object if parameter == i
        end
      end
    end
    return nil
  end
end

class PokeBattle_Move
  def runCondition(code)
    return eval(code)
  end

  def typeFieldMessage(type)
    fieldtype = @battle.field.typeData(type)
    return nil if !fieldtype || !fieldtype[:multtext]
    return @battle.field.data.typemessagelist[fieldtype[:multtext]-1]
  end
  
  def typeFieldBoost(type,attacker=nil,opponent=nil) #returns multiplier value of field boost
    fieldtype = @battle.field.typeData(type)
    return 1 if !fieldtype || !fieldtype[:mult]
    return 1 if fieldtype[:mult] && @battle.field.effect == PBFields::STARLIGHTA && @battle.pbWeather != 0 #starlight arena
    if fieldtype[:condition] && attacker && opponent
      return 1 if !eval(fieldtype[:condition])
    end
    return fieldtype[:mult]
  end

  def moveFieldMessage
    fieldmove = @battle.field.moveData(@id)
    return nil if !fieldmove || !fieldmove[:multtext]
    return @battle.field.data.movemessagelist[fieldmove[:multtext]-1]
  end

  def moveFieldBoost
    fieldmove = @battle.field.moveData(@id)
    return 1 if !fieldmove || !fieldmove[:mult]
    return 1 if fieldmove[:mult] && @battle.field.effect == PBFields::STARLIGHTA && @battle.pbWeather != 0 #starlight arena
    return fieldmove[:mult]
  end

  def changeFieldMessage
    fieldmove = @battle.field.moveData(@id)
    return nil if !fieldmove || !fieldmove[:changetext]
    return @battle.field.data.changemessagelist[fieldmove[:changetext]-1]
  end

  def checkFieldChange(attacker,opponent)
    fieldmove = @battle.field.moveData(@id)
    return nil if !fieldmove || !fieldmove[:fieldchange]
    if fieldmove[:condition]
      return nil if !eval(fieldmove[:condition])
    end
    return fieldmove[:fieldchange]
  end

  def fieldDefenseBoost(type,target)
    defmult = 1
    case @battle.FE
    when PBFields::MISTYT
      defmult*=1.5 if pbHitsSpecialStat?(type) && target.pbHasType?(:FAIRY)
    when PBFields::DARKCRYSTALC
      defmult*=1.5 if target.pbHasType?(:DARK) || target.pbHasType?(:GHOST)
      defmult*=2.0 if target.ability == PBAbilities::PRISMARMOR
    when PBFields::RAINBOWF
      defmult*=2.0 if target.ability == PBAbilities::PRISMARMOR
    when PBFields::DRAGONSD     
      defmult*=1.3 if target.pbHasType?(:DRAGON)
    when PBFields::NEWW
      defmult*=0.9 if target.isAirborne?
    when PBFields::SNOWYM       
      defmult*=1.5 if pbHitsPhysicalStat?(type) && target.pbHasType?(:ICE) && @battle.pbWeather == PBWeather::HAIL
    when PBFields::ICYF         
      defmult*=1.5 if pbHitsPhysicalStat?(type) && target.pbHasType?(:ICE) && @battle.pbWeather == PBWeather::HAIL
    when PBFields::DESERTF      
      defmult*=1.5 if pbHitsSpecialStat?(type) && target.pbHasType?(:GROUND)
    when PBFields::CRYSTALC
      defmult*=2.0 if target.ability == PBAbilities::PRISMARMOR
    end
    return defmult
  end
end

class PokeBattle_Battler
  def burningFieldPassiveDamage?
    return false if pbHasType?(:FIRE) || @effects[PBEffects::AquaRing]
    return false if [PBAbilities::FLAREBOOST,PBAbilities::MAGMAARMOR,PBAbilities::FLAMEBODY,PBAbilities::FLASHFIRE].include?(@ability)
    return false if [PBAbilities::WATERVEIL,PBAbilities::MAGICGUARD,PBAbilities::HEATPROOF,PBAbilities::WATERBUBBLE].include?(@ability)
    return false if [0xCA,0xCB].include?($cache.pkmn_move[@effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]) # Dig, Dive
    return true
  end

  def underwaterFieldPassiveDamamge?
    return false if pbHasType?(:WATER) 
    return false if @ability == PBAbilities::SWIFTSWIM || @ability == PBAbilities::MAGICGUARD
    return false if PBTypes.getCombinedEffectiveness(PBTypes::WATER,@type1,@type2) <= 4
    return true
  end

  def murkyWaterSurfacePassiveDamage?
    return false if pbHasType?(:STEEL) || pbHasType?(:POISON) 
    return false if [PBAbilities::POISONHEAL, PBAbilities::MAGICGUARD, PBAbilities::WONDERGUARD, PBAbilities::TOXICBOOST, PBAbilities::IMMUNITY].include?(@ability)
    return true
  end

  
end
      
