class PokemonGlobalMetadata
  attr_accessor :roamPosition
  attr_accessor :roamHistory
  attr_accessor :roamedAlready
  attr_accessor :roamEncounter
  attr_accessor :roamPokemon
  attr_accessor :roamPokemonCaught

  def roamPokemonCaught
    if !@roamPokemonCaught
      @roamPokemonCaught=[]
    end
    return @roamPokemonCaught
  end
end



# Resets all roaming Pokemon that were defeated without having been caught.
def pbResetAllRoamers()
  if $PokemonGlobal && $PokemonGlobal.roamPokemon
    for i in 0...$PokemonGlobal.roamPokemon.length
      if $PokemonGlobal.roamPokemon[i]==true && $PokemonGlobal.roamPokemonCaught[i]!=true
        $PokemonGlobal.roamPokemon[i]=nil
      end
    end
  end
end

# Gets the roaming areas for a particular Pokémon.
def pbRoamingAreas(index)
  data=RoamingSpecies[index]
  return data[:areas] if data && data[:areas]
  return RoamingAreas
end

# Puts a roamer in a completely random map available to it.
def pbRandomRoam(index)
  if $PokemonGlobal.roamPosition
    keys=pbRoamingAreas(index).keys
    $PokemonGlobal.roamPosition[index]=keys[rand(keys.length)]
  end
end

# Roams all roamers, if their Switch is on.
def pbRoamPokemon(ignoretrail=false)
  # Start all roamers off in random maps
  if !$PokemonGlobal.roamPosition
    $PokemonGlobal.roamPosition={}
    for i in 0...RoamingSpecies.length
      species=getID(PBSpecies,RoamingSpecies[i][:species])
      next if !species || species<=0
      keys=pbRoamingAreas(i).keys
      $PokemonGlobal.roamPosition[i]=keys[rand(keys.length)]
    end
  end
  $PokemonGlobal.roamHistory=[] if !$PokemonGlobal.roamHistory
  $PokemonGlobal.roamPokemon=[] if !$PokemonGlobal.roamPokemon
  # Roam each Pokémon in turn
  for i in 0...RoamingSpecies.length
    poke=RoamingSpecies[i]
    if $game_switches[poke[:switch]]
      species=getID(PBSpecies,poke[:species])
      next if !species || species<=0
      choices=[]
      keys=pbRoamingAreas(i).keys
      currentArea=$PokemonGlobal.roamPosition[i]
      if !currentArea
        $PokemonGlobal.roamPosition[i]=keys[rand(keys.length)]
      end
      newAreas=pbRoamingAreas(i)[currentArea]
      next if !newAreas
      for area in newAreas
        inhistory=$PokemonGlobal.roamHistory.include?(area)
        inhistory=false if ignoretrail
        choices.push(area) if !inhistory
      end
      if rand(32)==0 && keys.length>0
        area=keys[rand(keys.length)]
        inhistory=$PokemonGlobal.roamHistory.include?(area)
        inhistory=false if ignoretrail
        choices.push(area) if !inhistory
      end
      if choices.length>0 
        area=choices[rand(choices.length)]
        $PokemonGlobal.roamPosition[i]=area
        if $game_switches[:Rayquaza_Roam] && $MapFactory.areConnected?($PokemonGlobal.roamPosition[0],$game_map.map_id)
          $game_switches[:Force_Weather]=true
          $game_variables[106]=6
        elsif $game_switches[:Rayquaza_Roam] && !$MapFactory.areConnected?($PokemonGlobal.roamPosition[0],$game_map.map_id)
          $game_switches[:Force_Weather]=false
        end
        $game_screen.setWeather
      end
    end
  end
end

Events.onMapChange+=lambda {|sender,e|
    return if !$PokemonGlobal || caller_locations.any? {|string| string.to_s.include?("PokemonLoad")}
    pbRoamPokemon
    if $PokemonGlobal.roamHistory.length>=2
      $PokemonGlobal.roamHistory.shift
    end
    if $game_switches[:Rayquaza_Roam] && $MapFactory.areConnected?($PokemonGlobal.roamPosition[0],$game_map.map_id)
      $game_switches[:Force_Weather]=true
      $game_variables[106]=6
    elsif $game_switches[:Rayquaza_Roam] && !$MapFactory.areConnected?($PokemonGlobal.roamPosition[0],$game_map.map_id)
      $game_switches[:Force_Weather]=false
    end
    $PokemonGlobal.roamHistory.push($game_map.map_id)
}



class PokemonTemp
  attr_accessor :nowRoaming
  attr_accessor :roamerIndex
end



Events.onWildBattleOverride+= lambda { |sender,e|
   species=e[0]
   level=e[1]
   handled=e[2]
   next if handled[0]!=nil
   next if !$PokemonTemp.nowRoaming
   next if $PokemonTemp.roamerIndex==nil
   next if !$PokemonGlobal.roamEncounter
   handled[0]=pbRoamingPokemonBattle(species,level)
}

def pbRoamingPokemonBattle(species,level)
  index=$PokemonTemp.roamerIndex
  if $PokemonGlobal.roamPokemon[index] && 
     $PokemonGlobal.roamPokemon[index].is_a?(PokeBattle_Pokemon)
    genwildpoke=$PokemonGlobal.roamPokemon[index]
  else
    genwildpoke=pbGenerateWildPokemon(species,level)
  end
  Events.onStartBattle.trigger(nil,genwildpoke)
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke],$Trainer,nil)
  battle.internalbattle=true
  battle.cantescape=false
  battle.rules["alwaysflee"]=true
  pbPrepareBattle(battle)
  decision=0
  pbBattleAnimation(pbGetWildBattleBGM(species)) { 
     pbSceneStandby {
        decision=battle.pbStartBattle
     }
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
        i.heal
      end
     end
     if decision==2 || decision==5
       $game_system.bgm_unpause
       $game_system.bgs_unpause
       Kernel.pbStartOver
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  if decision==4  #Caught
    $game_variables[RoamingSpecies[index][:variable]] = 0
    $PokemonGlobal.roamPokemon[index]=true
    $PokemonGlobal.roamPokemonCaught[index]=true
    $game_switches[RoamingSpecies[index][:switch]]=false
    $game_switches[RoamingSpecies[index][:caughtswitch]]=true if RoamingSpecies[index][:caughtswitch]
    $game_switches[:Force_Weather]=false if getID(PBSpecies,RoamingSpecies[index][:species])==PBSpecies::RAYQUAZA
  else
    genwildpoke.heal if decision==1 #Defeated
    $game_variables[RoamingSpecies[index][:variable]] += 1
    pbRoamPokemon
    $PokemonGlobal.roamPokemon[index]=genwildpoke
  end
  $PokemonGlobal.roamEncounter=nil
  #$PokemonGlobal.roamedAlready=true
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  return (decision!=2 && decision!=5)
end

EncounterModifier.register(lambda {|encounter|
  $PokemonTemp.nowRoaming=false
  $PokemonTemp.roamerIndex=nil
  return nil if !encounter
  #return encounter if $PokemonGlobal.roamedAlready
  return encounter if $PokemonGlobal.partner
  return encounter if $PokemonTemp.pokeradar
  return encounter if rand(2)!=0
  roam=[]
  for i in 0...RoamingSpecies.length
    poke=RoamingSpecies[i]
    species=getID(PBSpecies,poke[:species])
    next if !species || species<=0
    if $game_switches[poke[:switch]] && $PokemonGlobal.roamPokemon[i]!=true 
      if $MapFactory.areConnected?($PokemonGlobal.roamPosition[i],$game_map.map_id) && pbRoamingMethodAllowed(poke[:type])
        # Change encounter to species and level, with BGM on end
        roam.push([i,species,poke[:level],poke[:bgm]])
      end
    end
  end
  if roam.length>0
    rnd=rand(roam.length)
    roamEncounter=roam[rnd]
    $PokemonGlobal.roamEncounter=roamEncounter
    $PokemonTemp.nowRoaming=true
    $PokemonTemp.roamerIndex=roamEncounter[0]
    if roamEncounter[3] && roamEncounter[3]!=""
      $PokemonGlobal.nextBattleBGM=roamEncounter[3]
    end
    return [roamEncounter[1],roamEncounter[2]]
  end
  return encounter
})

EncounterModifier.registerEncounterEnd(lambda {
   $PokemonTemp.nowRoaming=false
   $PokemonTemp.roamerIndex=nil
})

def pbRoamingMethodAllowed(enctype)
  encounter=$PokemonEncounters.pbEncounterType
  case enctype
    when 0   # Any encounter method (except triggered ones and Bug Contest)
      return true if encounter==EncounterTypes::Land
      return true if encounter==EncounterTypes::LandMorning
      return true if encounter==EncounterTypes::LandDay
      return true if encounter==EncounterTypes::LandNight
      return true if encounter==EncounterTypes::Water
      return true if encounter==EncounterTypes::Cave
    when 1   # Grass (except Bug Contest)/walking in caves only
      return true if encounter==EncounterTypes::Land
      return true if encounter==EncounterTypes::LandMorning
      return true if encounter==EncounterTypes::LandDay
      return true if encounter==EncounterTypes::LandNight
      return true if encounter==EncounterTypes::Cave
    when 2   # Surfing only
      return true if encounter==EncounterTypes::Water
    when 3   # Fishing only
      return true if encounter==EncounterTypes::OldRod
      return true if encounter==EncounterTypes::GoodRod
      return true if encounter==EncounterTypes::SuperRod
    when 4   # Water-based only
      return true if encounter==EncounterTypes::Water
      return true if encounter==EncounterTypes::OldRod
      return true if encounter==EncounterTypes::GoodRod
      return true if encounter==EncounterTypes::SuperRod
  end
  return false
end