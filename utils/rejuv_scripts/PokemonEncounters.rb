module EncounterTypes
  Land         = 0
  Cave         = 1
  Water        = 2
  RockSmash    = 3
  OldRod       = 4
  GoodRod      = 5
  SuperRod     = 6
  HeadbuttLow  = 7
  HeadbuttHigh = 8
  LandMorning  = 9
  LandDay      = 10
  LandNight    = 11
  BugContest   = 12
  Names=[
     "Land",
     "Cave",
     "Water",
     "RockSmash",
     "OldRod",
     "GoodRod",
     "SuperRod",
     "HeadbuttLow",
     "HeadbuttHigh",
     "LandMorning",
     "LandDay",
     "LandNight",
     "BugContest"
  ]
  EnctypeChances=[
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [60,30,5,4,1],
     [60,30,5,4,1],
     [70,30],
     [60,20,20],
     [40,40,15,4,1],
     [30,25,20,10,5,5,4,1],
     [30,25,20,10,5,5,4,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1]
  ]
  EnctypeDensities=[25,10,10,0,0,0,0,0,0,25,25,25,25]
  EnctypeCompileDens=[1,2,3,0,0,0,0,0,0,1,1,1,1]
end



class PokemonEncounters
  def initialize
    @enctypes=[]
    @density=nil
  end

  def stepcount
    return @stepcount
  end

  def clearStepCount
    @stepcount=0
  end

  def hasEncounter?(enc)
    return false if @density==nil || enc<0
    return @enctypes[enc] ? true : false  
  end

  def isCave?
    return false if @density==nil
    return @enctypes[EncounterTypes::Cave] ? true : false
  end

  def isGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight] ||
            @enctypes[EncounterTypes::BugContest]) ? true : false
  end

  def isRegularGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight]) ? true : false
  end

  def isWater?
    return false if @density==nil
    return @enctypes[EncounterTypes::Water] ? true : false
  end

  def isDesert?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight]) ? true : false
  end
  
  def pbEncounterType
    if $PokemonGlobal && $PokemonGlobal.surfing
      return EncounterTypes::Water
    elsif self.isCave?
      return EncounterTypes::Cave
    elsif self.isGrass?
      time=pbGetTimeNow
      enctype=EncounterTypes::Land
      enctype=EncounterTypes::LandNight if self.hasEncounter?(EncounterTypes::LandNight) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::LandDay if self.hasEncounter?(EncounterTypes::LandDay) && PBDayNight.isDay?(time)
      enctype=EncounterTypes::LandMorning if self.hasEncounter?(EncounterTypes::LandMorning) && PBDayNight.isMorning?(time)
      if pbInBugContest? && self.hasEncounter?(EncounterTypes::BugContest)
        enctype=EncounterTypes::BugContest
      end
      return enctype
    elsif self.isDesert?
      time=pbGetTimeNow
      enctype=EncounterTypes::Land
      enctype=EncounterTypes::LandNight if self.hasEncounter?(EncounterTypes::LandNight) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::LandDay if self.hasEncounter?(EncounterTypes::LandDay) && PBDayNight.isDay?(time)
      enctype=EncounterTypes::LandMorning if self.hasEncounter?(EncounterTypes::LandMorning) && PBDayNight.isMorning?(time)
      if pbInBugContest? && self.hasEncounter?(EncounterTypes::BugContest)
        enctype=EncounterTypes::BugContest
      end
      return enctype
    end
    return -1
  end

  def isEncounterPossibleHere?
    if $PokemonGlobal && $PokemonGlobal.surfing
      return true
    elsif pbGetTerrainTag($game_player)==PBTerrain::Ice
      return false
    elsif self.isCave?
      return true
    elsif self.isGrass?
      return pbIsGrassTag?($game_map.terrain_tag($game_player.x,$game_player.y))
    elsif self.isDesert?
      return pbIsDesertTag?($game_map.terrain_tag($game_player.x,$game_player.y))
    end
    return false
  end

  def setup(mapID)
    @density=nil
    @stepcount=0
    @enctypes=[]
    begin
      data=load_data("Data/encounters.dat")
      if data.is_a?(Hash) && data[mapID]
        @density=data[mapID][0]
        @enctypes=data[mapID][1]
      else
        @density=nil
        @enctypes=[]
      end
      rescue
      @density=nil
      @enctypes=[]
    end
  end

  def pbMapHasEncounter?(mapID,enctype)
    data=load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[mapID]
      enctypes=data[mapID][1]
      density=data[mapID][0]
    else
      return false
    end
    return false if density==nil || enctype<0
    return enctypes[enctype] ? true : false  
  end

  def pbMapEncounter(mapID,enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    data=load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[mapID]
      enctypes=data[mapID][1]
    else
      return nil
    end
    return nil if enctypes[enctype]==nil
    chances=EncounterTypes::EnctypeChances[enctype]
    chancetotal=0
    chances.each {|a| chancetotal+=a}
    rnd=rand(chancetotal)
    chosenpkmn=0
    chance=0
    for i in 0...chances.length
      chance+=chances[i]
      if rnd<chance
        chosenpkmn=i
        break
      end
    end
    encounter=enctypes[enctype][chosenpkmn]
    level=encounter[1]+rand(1+encounter[2]-encounter[1])
    return [encounter[0],level]
  end

# UPDATE 11/18/2013
# the following functions were copied from PokeBattle_Pokemon and slightly
# modified to fit the needs for this problem.
# they are used to determine the type of possible pokemon encounters
  def hasType?(species, type)
    if type.is_a?(String) || type.is_a?(Symbol)
      return isConst?(type1(species),PBTypes,type)||isConst?(type2(species),PBTypes,type)
    else
      return type1==type || type2==type
    end
  end
# Returns this Pokémon's first type.
  def type1(species)
    return $pkmn_dex[species][3]
  end

# Returns this Pokémon's second type.
  def type2(species)
    return $pkmn_dex[species][4]
  end

# adjusts the chances of finding a Pokemon of type by mult
# Note: This does NOT increase the find chance by mult (strictly speaking)
# Since a random number is created between 0 <= r < sum of chances
# Increasing these numbers will shift around the find rate of all of them.
  def shiftChances(chances, enctype, type, mult)
    for i in 0...chances.length
      pkmn = @enctypes[enctype][i]
      chances[i] *= mult if hasType?(pkmn[0], type)
      chances[i] = 1 if chances[i] < 1
      chances[i] = chances[i].to_i
    end
    return chances
  end
# end of update
  
def pbEncounteredPokemon(enctype,tries=1)
  if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
    raise ArgumentError.new(_INTL("Encounter type out of range"))
  end
  return nil if @enctypes[enctype]==nil
  encounters = @enctypes[enctype]
  chances    = EncounterTypes::EnctypeChances[enctype]
  if !$Trainer.party[0].egg?
    firstpoke = $Trainer.party[0] 
  else
    firstpoke = false
  end
  dexdata = pbOpenDexData
  
  if firstpoke && rand(2)==0
    type = -1
    if isConst?(firstpoke.ability,PBAbilities,:STATIC) # || isConst?(firstpoke.ability,PBAbilities,:STATIC) gen 8
      type = (PBTypes::ELECTRIC)
    elsif isConst?(firstpoke.ability,PBAbilities,:MAGNETPULL)
      type = (PBTypes::STEEL)
    elsif isConst?(firstpoke.ability,PBAbilities,:FLASHFIRE)
      type = (PBTypes::FIRE)
    end
    if type>=0
      newencs = []; newchances = []
      dexdata = pbOpenDexData
      for i in 0...encounters.length
        t1 = $pkmn_dex[encounters[i][0]][3]
        t2 = $pkmn_dex[encounters[i][0]][4]
        if pbISActuallyAlolanType(encounters[i][0]) != [0,0]
          t1,t2 = self.pbISActuallyAlolanType(encounters[i][0])
        end
        if t1==type || t2==type
          newencs.push(encounters[i])
          newchances.push(chances[i])
        end
      end
      if newencs.length>0
        encounters = newencs
        chances    = newchances
      end
    end
  end
  chancetotal = 0
  chances.each {|a| chancetotal += a }
  rnd = 0
  tries.times do
    r = rand(chancetotal)
    rnd = r if rnd<r
  end
  chosenpkmn = 0
  chance = 0
  for i in 0...chances.length
    chance += chances[i]
    if rnd<chance
      chosenpkmn = i
      break
    end
  end
  encounter = encounters[chosenpkmn]
  return nil if !encounter
# UPDATE 11/19/2013
# pressure, hustle and vital spirit will now have a 150% chance of
# finding higher leveled pokemon in encounters
  if !$Trainer.party[0].egg?
    abl = $Trainer.party[0].ability
    if (isConst?(abl, PBAbilities, :PRESSURE) ||
      isConst?(abl, PBAbilities, :HUSTLE) ||
      isConst?(abl, PBAbilities, :VITALSPIRIT)) &&
      rand(2) == 0
    # increase the lower bound to half way in-between lower and upper
      encounter[1] += (encounter[2] - encounter[1]) / 2
    end
  end
# end of update
  level=encounter[1]+rand(1+encounter[2]-encounter[1])
  return [encounter[0],level]
end

def pbISActuallyAlolanType(species)
  case species
    when 27  #Sandshrew
      maps= [364, 366, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 390, 396, 430, 433, 434, 440, 441, 442]
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::ICE), (PBTypes::STEEL)
        return [type1,type2]
      end
    when 28 #Sandslash
      maps=[364, 366, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 390, 396, 430, 433, 434, 440, 441, 442, 749, 750, 834]   
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::ICE), (PBTypes::STEEL)
        return [type1,type2]
      end
    when 50 #Diglett
      maps=[33, 34, 35, 199, 201, 202, 203, 204]
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::GROUND), (PBTypes::STEEL)
        return [type1,type2]
      end
    when 51 #Dugtrio
      maps=[33, 34, 35, 199, 201, 202, 203, 204] 
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::GROUND), (PBTypes::STEEL)
        return [type1,type2]
      end
    when 51 #Geodude
      maps=[231, 247, 251, 258, 259, 260, 261, 262, 263, 264, 340, 341, 342, 343, 344, 346, 347, 348, 349, 371, 614, 615, 616, 618]    
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::ROCK), (PBTypes::ELECTRIC)
        return [type1,type2]
      end
    when 51 #Graveler
      maps=[231, 247, 251, 258, 259, 260, 261, 262, 263, 264, 340, 341, 342, 343, 344, 346, 347, 348, 349, 371, 614, 615, 616, 618]   
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::ROCK), (PBTypes::ELECTRIC)
        return [type1,type2]
      end
    when 51 #Golem
      maps=[231, 247, 251, 258, 259, 260, 261, 262, 263, 264, 340, 341, 342, 343, 344, 346, 347, 348, 349, 371, 614, 615, 616, 618, 834]   
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::ROCK), (PBTypes::ELECTRIC)
        return [type1,type2]
      end
    when 37   #Vulpix
      maps=[439]
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::ICE), (PBTypes::ICE)
        return [type1,type2]
      end
      
    when 38 #Ninetails
      maps=[439,721,723,725,726,727,729,794]
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::ICE), (PBTypes::FAIRY)
        return [type1,type2]
      end
    #when 52 #Meowth
      #maps=???
      #if $game_map && maps.include?($game_map.map_id)
      #  type1, type2 = (PBTypes::STEEL), (PBTypes::STEEL)
      #  return [type1,type2]
      #end
    when 105 #Marowak   #technically only half the time this pokemon is alolan form on this map
      maps=[669]
      if $game_map && maps.include?($game_map.map_id)
        type1, type2 = (PBTypes::FIRE), (PBTypes::GHOST)
        return [type1,type2]
      end
    #when 77 #Ponyta
      #maps=???
      #if $game_map && maps.include?($game_map.map_id)
      #  type1, type2 = (PBTypes::PSYCHIC), (PBTypes::PSYCHIC)
      #  return [type1,type2]
      #end
    #when 78 #Rapidash
      #maps=???
      #if $game_map && maps.include?($game_map.map_id)
      #  type1, type2 = (PBTypes::PSYCHIC), (PBTypes::FAIRY)
      #  return [type1,type2]
      #end
    #when 222 #Corsola
      #maps=???
      #if $game_map && maps.include?($game_map.map_id)
      #  type1, type2 = (PBTypes::GHOST), (PBTypes::GHOST)
      #  return [type1,type2]
      #end
    #when #Darumaka
      #maps=???
      #if $game_map && maps.include?($game_map.map_id)
      #  type1, type2 = (PBTypes::ICE), (PBTypes::ICE)
      #  return [type1,type2]
      #end
    #when 554 #Darmanitan
      #maps=???
      #if $game_map && maps.include?($game_map.map_id)
      #  type1, type2 = (PBTypes::GHOST), (PBTypes::GHOST)
      #  return [type1,type2]
      #end
    #when 618 #Stunfisk
      #maps=???
      #if $game_map && maps.include?($game_map.map_id)
      #  type1, type2 = (PBTypes::GROUND), (PBTypes::STEEL)
      #  return [type1,type2]
      #end
  end
  return [0,0]  
end

  def pbCanEncounter?(encounter,repel)
    return false if $game_system.encounter_disabled
    return false if !encounter || !$Trainer
    return false if $DEBUG && Input.press?(Input::CTRL)
    if !pbPokeRadarOnShakingGrass
      return false if $PokemonGlobal.repel>0 && $Trainer.ablePokemonCount>0 &&
                      encounter[1]<$Trainer.ablePokemonParty[0].level
    end
    return true
  end

  def pbGenerateEncounter(enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @density==nil
    return nil if @density[enctype]==0 || !@density[enctype]
    return nil if @enctypes[enctype]==nil
    @stepcount+=1
    return nil if @stepcount<=3 # Check three steps after battle ends
    encount=@density[enctype]*16
    if $PokemonGlobal.bicycle
      encount=(encount*4/5)
    end
#    if $PokemonMap.blackFluteUsed
#      encount/=2
#    end
#    if $PokemonMap.whiteFluteUsed
#      encount=(encount*3/2)
#    end
    if $Trainer.party.length>0 && !$Trainer.party[0].isEgg?
      if isConst?($Trainer.party[0].item,PBItems,:CLEANSETAG)
        encount=(encount*2/3)
      elsif isConst?($Trainer.party[0].item,PBItems,:PUREINCENSE)
        encount=(encount*2/3)
      else   # Ignore ability effects if an item effect applies
        if isConst?($Trainer.party[0].ability,PBAbilities,:STENCH)
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:WHITESMOKE)
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:QUICKFEET)
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:INFILTRATOR)
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:SNOWCLOAK) &&
           $game_screen.weather_type==3
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:SANDVEIL) &&
           $game_screen.weather_type==4
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:SWARM)
          encount=(encount*3/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:ILLUMINATE)
          encount=(encount*2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:ARENATRAP)
          encount=(encount*2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:NOGUARD)
          encount=(encount*2)
        end
      end
    end
    return nil if rand(180*16)>=encount
    encpoke=pbEncounteredPokemon(enctype)
    if $Trainer.party.length>0 && !$Trainer.party[0].isEgg?
      if encpoke && isConst?($Trainer.party[0].ability,PBAbilities,:INTIMIDATE) &&
         encpoke[1]<=$Trainer.party[0].level-5 && rand(2)==0
        encpoke=nil
      end
      if encpoke && isConst?($Trainer.party[0].ability,PBAbilities,:KEENEYE) &&
         encpoke[1]<=$Trainer.party[0].level-5 && rand(2)==0
        encpoke=nil
      end
    end
    return encpoke
  end
end