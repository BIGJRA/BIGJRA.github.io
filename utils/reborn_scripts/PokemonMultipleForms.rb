class PokeBattle_Pokemon
	def form
    return @form || 0
  end

  def form=(value)
    @form=value
    self.calcStats
    pbSeenForm(self)
  end

  def getForm (pkmn)
   if pkmn.species == PBSpecies::GIRATINA
      maps = [] #Maps for Origin Form, currently not functional
      return (pkmn.item == PBItems::GRISEOUSORB || ($game_map && maps.include?($game_map.map_id))) ? 1 : 0
   end
   if pkmn.species == PBSpecies::ARCEUS
      case pkmn.item
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
   if pkmn.species == PBSpecies::GENESECT
      case pkmn.item
         when PBItems::SHOCKDRIVE   then return 1
         when PBItems::BURNDRIVE    then return 2
         when PBItems::CHILLDRIVE   then return 3
         when PBItems::DOUSEDRIVE   then return 4
      else return 0
      end
   end
   if pkmn.species == PBSpecies::SILVALLY
      case pkmn.item
         when PBItems::FIGHTINGMEMORY  then return 1
         when PBItems::FLYINGMEMORY    then return 2
         when PBItems::POISONMEMORY    then return 3
         when PBItems::GROUNDMEMORY    then return 4
         when PBItems::ROCKMEMORY      then return 5
         when PBItems::BUGMEMORY       then return 6
         when PBItems::GHOSTMEMORY     then return 7
         when PBItems::STEELMEMORY     then return 8
         when PBItems::FIREMEMORY      then return 10
         when PBItems::WATERMEMORY     then return 11
         when PBItems::GRASSMEMORY     then return 12
         when PBItems::ELECTRICMEMORY  then return 13
         when PBItems::PSYCHICMEMORY   then return 14
         when PBItems::ICEMEMORY       then return 15
         when PBItems::DRAGONMEMORY    then return 16
         when PBItems::DARKMEMORY      then return 17
         when PBItems::FAIRYMEMORY     then return 18
      else return 0
      end
   end
   return pkmn.form
  end

	def getFormName
		formnames = PokemonForms.dig(@species,:FormName)
		return if !formnames
		return formnames[self.form]
	end

  def hasMegaForm?
    v=PokemonForms.dig(@species,:MegaForm)
    v=PokemonForms.dig(@species,:PulseForm) if (Reborn && !v)
    return false if !v
    if @species==PBSpecies::RAYQUAZA && !pbIsZCrystal?(@item)
      for i in @moves
         return true if i.id==PBMoves::DRAGONASCENT
      end
   end
	return PBStuff::POKEMONTOMEGASTONE[@species].include?(@item)
  end

  def hasUltraForm?
    return @species == PBSpecies::NECROZMA && @item == PBItems::ULTRANECROZIUMZ2 && self.form!=0
  end

  #when you learn a new coding trick and have to use it everywhere
  def hasZMove?
    pkmn=self
    canuse=false
    case pkmn.item
      when PBItems::NORMALIUMZ   then canuse=pkmn.moves.any?{|move| move.type == PBTypes::NORMAL}
      when PBItems::FIGHTINIUMZ  then canuse=pkmn.moves.any?{|move| move.type == PBTypes::FIGHTING}
      when PBItems::FLYINIUMZ    then canuse=pkmn.moves.any?{|move| move.type == PBTypes::FLYING}
      when PBItems::POISONIUMZ   then canuse=pkmn.moves.any?{|move| move.type == PBTypes::POISON}
      when PBItems::GROUNDIUMZ   then canuse=pkmn.moves.any?{|move| move.type == PBTypes::GROUND}
      when PBItems::ROCKIUMZ     then canuse=pkmn.moves.any?{|move| move.type == PBTypes::ROCK}
      when PBItems::BUGINIUMZ    then canuse=pkmn.moves.any?{|move| move.type == PBTypes::BUG}
      when PBItems::GHOSTIUMZ    then canuse=pkmn.moves.any?{|move| move.type == PBTypes::GHOST}
      when PBItems::STEELIUMZ    then canuse=pkmn.moves.any?{|move| move.type == PBTypes::STEEL}
      when PBItems::FIRIUMZ      then canuse=pkmn.moves.any?{|move| move.type == PBTypes::FIRE}
      when PBItems::WATERIUMZ    then canuse=pkmn.moves.any?{|move| move.type == PBTypes::WATER}
      when PBItems::GRASSIUMZ    then canuse=pkmn.moves.any?{|move| move.type == PBTypes::GRASS}
      when PBItems::ELECTRIUMZ   then canuse=pkmn.moves.any?{|move| move.type == PBTypes::ELECTIC}
      when PBItems::PSYCHIUMZ    then canuse=pkmn.moves.any?{|move| move.type == PBTypes::PSYCHIC}
      when PBItems::ICIUMZ       then canuse=pkmn.moves.any?{|move| move.type == PBTypes::ICE}
      when PBItems::DRAGONIUMZ   then canuse=pkmn.moves.any?{|move| move.type == PBTypes::DRAGON}
      when PBItems::DARKINIUMZ   then canuse=pkmn.moves.any?{|move| move.type == PBTypes::DARK}
      when PBItems::FAIRIUMZ     then canuse=pkmn.moves.any?{|move| move.type == PBTypes::FAIRY}
         
      when PBItems::ALORAICHIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::THUNDERBOLT} if pkmn.species==PBSpecies::RAICHU && pkmn.form
      when PBItems::DECIDIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::SPIRITSHACKLE} if pkmn.species==PBSpecies::DECIDUEYE
      when PBItems::INCINIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::DARKESTLARIAT} if pkmn.species==PBSpecies::INCINEROAR
      when PBItems::PRIMARIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::SPARKLINGARIA} if pkmn.species==PBSpecies::PRIMARINA
      when PBItems::EEVIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::LASTRESORT} if pkmn.species==PBSpecies::EEVEE
      when PBItems::PIKANIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::VOLTTACKLE} if pkmn.species==PBSpecies::PIKACHU
      when PBItems::SNORLIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::GIGAIMPACT} if pkmn.species==PBSpecies::SNORLAX
      when PBItems::MEWNIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::PSYCHIC} if pkmn.species==PBSpecies::MEW
      when PBItems::TAPUNIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::NATURESMADNESS} if pkmn.species==PBSpecies::TAPUKOKO || pkmn.species==PBSpecies::TAPULELE || pkmn.species==PBSpecies::TAPUFINI || pkmn.species==PBSpecies::TAPUBULU
      when PBItems::MARSHADIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::SPECTRALTHIEF} if pkmn.species==PBSpecies::MARSHADOW
      when PBItems::KOMMONIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::CLANGINGSCALES} if pkmn.species==PBSpecies::KOMMOO
      when PBItems::LYCANIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::STONEEDGE} if pkmn.species==PBSpecies::LYCANROC
      when PBItems::MIMIKIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::PLAYROUGH} if pkmn.species==PBSpecies::MIMIKYU
      when PBItems::SOLGANIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::SUNSTEELSTRIKE} if (pkmn.species==PBSpecies::NECROZMA && pkmn.form==1) || pkmn.species==PBSpecies::SOLGALEO
      when PBItems::LUNALIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::MOONGEISTBEAM} if (pkmn.species==PBSpecies::NECROZMA && pkmn.form==2) || pkmn.species==PBSpecies::LUNALA
      when PBItems::ULTRANECROZIUMZ then canuse=pkmn.moves.any?{|move| move.id == PBMoves::PHOTONGEYSER} if pkmn.species==PBSpecies::NECROZMA && pkmn.form!=0
    end
    return canuse
  end

  def isMega?
    v=PokemonForms.dig(@species,:MegaForm)
    v=PokemonForms.dig(@species,:PulseForm) if v == nil && Reborn
    return true if v.is_a?(Hash) && v.values.include?(self.form)
    return false if v.is_a?(Hash)
    return v!=nil && self.form >= v
  end

  def makeMega
  	v=PokemonForms.dig(@species,:MegaForm)
    v=PokemonForms.dig(@species,:PulseForm) if v == nil && Reborn
    self.form=v if v.is_a?(Integer)
    self.form=v[@item] if v.is_a?(Hash)
  end

  def makeUnmega
    v=PokemonForms.dig(@species,:DefaultForm)
    self.form=v if v!=nil
  end

  def megaName
		return ""
    v=PokemonForms.dig(@species,:FormName)
    return v if v!=nil
    return ""
  end

  def isUltra?
    v=PokemonForms.dig(@species,:UltraForm)
    return v!=nil && v==self.form
  end

  def makeUltra
    v=PokemonForms.dig(@species,:UltraForm)
    self.form=v if v!=nil
  end

  def makeUnultra(startform)
    self.form=startform
  end

  def ultraName
		return ""
    v=MultipleForms.call("getUltraName",self)
    return v if v!=nil
    return ""
  end

  def isPulse?
		v=PokemonForms.dig(@species,:PulseForm)
    return false if !v
    if v.is_a?(Hash)
       return v.values.include?(self.form)
    else
       return (self.form >= v)
    end
  end

  alias __mf_baseStats baseStats
  alias __mf_ability ability
  alias __mf_type1 type1
  alias __mf_type2 type2
  alias __mf_weight weight
	#alias __mf_height height
  alias __mf_getMoveList getMoveList
  alias __mf_wildHoldItems wildHoldItems
	alias __mf_baseExp baseExp
  alias __mf_evYield evYield
  alias __mf_initialize initialize

  def baseStats
		return self.__mf_baseStats if self.form == 0
		name = getFormName
		v = PokemonForms.dig(@species,name,:BaseStats)
    return v if v!=nil
    return self.__mf_baseStats
  end

  def ability
   unless @species == PBSpecies::MEOWSTIC && gender == 1
      return self.__mf_ability if self.form == 0
   end
	name = getFormName
   name = "Female" if @species == PBSpecies::MEOWSTIC && gender == 1
	v = PokemonForms.dig(@species,name,:Ability)
	if v!=nil
    	return v if !v.is_a?(Array)
		return v[self.abilityIndex] if v[self.abilityIndex]
      return v[0]
	end
   return self.__mf_ability
  end

  def type1
    return self.__mf_type1 if self.form == 0
		name = getFormName
		v = PokemonForms.dig(@species,name,:Type1)
    return v if v!=nil
    return self.__mf_type1
  end

  def type2
    return self.__mf_type2 if self.form == 0
		name = getFormName
		v = PokemonForms.dig(@species,name,:Type2)
    return v if v!=nil
    return self.__mf_type2
  end

  def weight
    return self.__mf_weight if self.form == 0
		name = getFormName
		v = PokemonForms.dig(@species,name,:Weight)
    return v if v!=nil
    return self.__mf_weight
  end

	def height
    return self.__mf_height if self.form == 0
		name = getFormName
		v = PokemonForms.dig(@species,name,:Height)
    return v if v!=nil
    return self.__mf_height
  end

  def getMoveList
      unless @species == PBSpecies::MEOWSTIC && gender == 1
         return self.__mf_getMoveList if self.form == 0
      end
		name = getFormName
      name = "Female" if @species == PBSpecies::MEOWSTIC && gender == 1
		v = PokemonForms.dig(@species,name,:Movelist)
      return v if v!=nil
      return self.__mf_getMoveList
  end

  def wildHoldItems
    return self.__mf_wildHoldItems if self.form == 0
		name = getFormName
		v = PokemonForms.dig(@species,name,:WildHoldItems)
    return v if v!=nil
    return self.__mf_wildHoldItems
  end

  def baseExp
    #v=MultipleForms.call("baseExp",self)
    #return v if v!=nil
    return self.__mf_baseExp
  end

  def evYield
    return self.__mf_evYield if self.form == 0
		name = getFormName
		v = PokemonForms.dig(@species,name,:EVs)
    return v if v!=nil
    return self.__mf_evYield
  end

  def initialize(*args)
    __mf_initialize(*args)
		v = PokemonForms.dig(@species,:OnCreation)
    if v
			f = v.call
      self.form=f
      self.resetMoves
    end
  end

end

class PokeBattle_RealBattlePeer
  def pbOnEnteringBattle(battle,pokemon)
  end
end

def drawSpot(bitmap,spotpattern,x,y,red,green,blue)
  height=spotpattern.length
  width=spotpattern[0].length
  for yy in 0...height
    spot=spotpattern[yy]
    for xx in 0...width
      if spot[xx]==1
        xOrg=(x+xx)<<1
        yOrg=(y+yy)<<1
        color=bitmap.get_pixel(xOrg,yOrg)
        r=color.red+red
        g=color.green+green
        b=color.blue+blue
        color.red=[[r,0].max,255].min
        color.green=[[g,0].max,255].min
        color.blue=[[b,0].max,255].min
        bitmap.set_pixel(xOrg,yOrg,color)
        bitmap.set_pixel(xOrg+1,yOrg,color)
        bitmap.set_pixel(xOrg,yOrg+1,color)
        bitmap.set_pixel(xOrg+1,yOrg+1,color)
      end
    end
  end
end

def pbSpindaSpots(pokemon,bitmap)
  spot1=[
     [0,0,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,0,0]
  ]
  spot2=[
     [0,0,1,1,1,0,0],
     [0,1,1,1,1,1,0],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [0,1,1,1,1,1,0],
     [0,0,1,1,1,0,0]
  ]
  spot3=[
     [0,0,0,0,0,1,1,1,1,0,0,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,0,0,0,1,1,1,0,0,0,0,0]
  ]
  spot4=[
     [0,0,0,0,1,1,1,0,0,0,0,0],
     [0,0,1,1,1,1,1,1,1,0,0,0],
     [0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,0,1,1,1,1,1,0,0,0]
  ]
  id=pokemon.personalID
  h=(id>>28)&15
  g=(id>>24)&15
  f=(id>>20)&15
  e=(id>>16)&15
  d=(id>>12)&15
  c=(id>>8)&15
  b=(id>>4)&15
  a=(id)&15
  if pokemon.isShiny?
    drawSpot(bitmap,spot1,b+43,a+35,-120,-120,-20)
    drawSpot(bitmap,spot2,d+31,c+34,-120,-120,-20)
    drawSpot(bitmap,spot3,f+49,e+17,-120,-120,-20)
    drawSpot(bitmap,spot4,h+25,g+16,-120,-120,-20)
  else
    drawSpot(bitmap,spot1,b+43,a+35,0,-115,-75)
    drawSpot(bitmap,spot2,d+31,c+34,0,-115,-75)
    drawSpot(bitmap,spot3,f+49,e+17,0,-115,-75)
    drawSpot(bitmap,spot4,h+25,g+16,0,-115,-75)
  end
end
=begin
MultipleForms.register(PBSpecies::UNOWN,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(28)
}
})


MultipleForms.register(PBSpecies::FLABEBE,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(5)
}
})
MultipleForms.register(PBSpecies::FLOETTE,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(5)
}
})
MultipleForms.register(PBSpecies::FLORGES,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(5)
}
})

MultipleForms.register(PBSpecies::SPINDA,{
"alterBitmap"=>proc{|pokemon,bitmap|
   pbSpindaSpots(pokemon,bitmap)
}
})

MultipleForms.register(PBSpecies::CASTFORM,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0              # Normal Form
   case pokemon.form
     when 1; next (PBTypes::FIRE)  # Sunny Form
     when 2; next (PBTypes::WATER) # Rainy Form
     when 3; next (PBTypes::ICE)   # Snowy Form
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Normal Form
   case pokemon.form
     when 1; next (PBTypes::FIRE)  # Sunny Form
     when 2; next (PBTypes::WATER) # Rainy Form
     when 3; next (PBTypes::ICE)   # Snowy Form
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::DEOXYS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal Forme
   case pokemon.form
     when 1; next [50,180, 20,150,180, 20] # Attack Forme
     when 2; next [50, 70,160, 90, 70,160] # Defense Forme
     when 3; next [50, 95, 90,180, 95, 90] # Speed Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0      # Normal Forme
   case pokemon.form
     when 1; next [0,2,0,0,1,0] # Attack Forme
     when 2; next [0,0,2,0,0,1] # Defense Forme
     when 3; next [0,0,0,3,0,0] # Speed Forme
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,PBMoves::LEER],[1,PBMoves::WRAP],[7,PBMoves::NIGHTSHADE],[13,PBMoves::TELEPORT],
                        [19,PBMoves::TAUNT],[25,PBMoves::PURSUIT],[31,PBMoves::PSYCHIC],[37,PBMoves::SUPERPOWER],
                        [43,PBMoves::PSYCHOSHIFT],[49,PBMoves::ZENHEADBUTT],[55,PBMoves::COSMICPOWER],
                        [61,PBMoves::ZAPCANNON],[67,PBMoves::PSYCHOBOOST],[73,PBMoves::HYPERBEAM]]
     when 2 ; movelist=[[1,PBMoves::LEER],[1,PBMoves::WRAP],[7,PBMoves::NIGHTSHADE],[13,PBMoves::TELEPORT],
                        [19,PBMoves::KNOCKOFF],[25,PBMoves::SPIKES],[31,PBMoves::PSYCHIC],[37,PBMoves::SNATCH],
                        [43,PBMoves::PSYCHOSHIFT],[49,PBMoves::ZENHEADBUTT],[55,PBMoves::IRONDEFENSE],
                        [55,PBMoves::AMNESIA],[61,PBMoves::RECOVER],[67,PBMoves::PSYCHOBOOST],
                        [73,PBMoves::COUNTER],[73,PBMoves::MIRRORCOAT]]
     when 3 ; movelist=[[1,PBMoves::LEER],[1,PBMoves::WRAP],[7,PBMoves::NIGHTSHADE],[13,PBMoves::DOUBLETEAM],
                        [19,PBMoves::KNOCKOFF],[25,PBMoves::PURSUIT],[31,PBMoves::PSYCHIC],[37,PBMoves::SWIFT],
                        [43,PBMoves::PSYCHOSHIFT],[49,PBMoves::ZENHEADBUTT],[55,PBMoves::AGILITY],
                        [61,PBMoves::RECOVER],[67,PBMoves::PSYCHOBOOST],[73,PBMoves::EXTREMESPEED]]
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::BURMY,{
"getFormOnCreation"=>proc{|pokemon|


},
"getFormOnEnteringBattle"=>proc{|pokemon|
   begin #horribly stupid section to make the battle stress test work
   case $fefieldeffect
      when 1,5,6,10,11,17,18,19,24,26,29,30,35,36,37
        next 2 # Trash Cloak
      when 2,3,7,8,9,15,21,22,31,33,34
        next 0 # Plant Cloak
      when 4,12,13,14,16,20,23,25,27,28,32
        next 1 # Sandy CloaK
      end

   env=pbGetEnvironment()

      if env==PBEnvironment::Sand ||
            env==PBEnvironment::Rock ||
            env==PBEnvironment::Cave
      next 1 # Sandy Cloak
      elsif !pbGetMetadata($game_map.map_id,MetadataOutdoor)
      next 2 # Trash Cloak
      else
      next 0 # Plant Cloak
      end
   rescue
      next 0
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::WORMADAM,{
"getFormOnCreation"=>proc{|pokemon|
   begin #horribly stupid section to make the battle stress test work
   case $fefieldeffect
      when 1,5,6,10,11,17,18,19,24,26,29,30,35,36,37
        next 2 # Trash Cloak
      when 2,3,7,8,9,15,21,22,31,33,34
        next 0 # Plant Cloak
      when 4,12,13,14,16,20,23,25,27,28,32
        next 1 # Sandy CloaK
      end

   env=pbGetEnvironment()

      if env==PBEnvironment::Sand ||
            env==PBEnvironment::Rock ||
            env==PBEnvironment::Cave
      next 1 # Sandy Cloak
      elsif !pbGetMetadata($game_map.map_id,MetadataOutdoor)
      next 2 # Trash Cloak
      else
      next 0 # Plant Cloak
      end
   rescue
      next 0
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0               # Plant Cloak
   case pokemon.form
     when 1; next (PBTypes::GROUND) # Sandy Cloak
     when 2; next (PBTypes::STEEL)  # Trash Cloak
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0              # Plant Cloak
   case pokemon.form
     when 1; next [60,79,105,36,59, 85] # Sandy Cloak
     when 2; next [60,69, 95,36,69, 95] # Trash Cloak
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0      # Plant Cloak
   case pokemon.form
     when 1; next [0,0,2,0,0,0] # Sandy Cloak
     when 2; next [0,0,1,0,0,1] # Trash Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[0,PBMoves::QUIVERDANCE],[1,PBMoves::SUCKERPUNCH],
                        [1,PBMoves::TACKLE],[1,PBMoves::PROTECT],[1,PBMoves::BUGBITE],
                        [10,PBMoves::PROTECT],[15,PBMoves::BUGBITE],[20,PBMoves::HIDDENPOWER],
                        [23,PBMoves::CONFUSION],[26,PBMoves::ROCKBLAST],[29,PBMoves::HARDEN],[32,PBMoves::PSYBEAM],
                        [35,PBMoves::CAPTIVATE],[38,PBMoves::FLAIL],[41,PBMoves::ATTRACT],[44,PBMoves::PSYCHIC],
                        [47,PBMoves::FISSURE],[50,PBMoves::BUGBUZZ]]
     when 2 ; movelist=[[0,PBMoves::QUIVERDANCE],[1,PBMoves::METALBURST],[1,PBMoves::SUCKERPUNCH],
                        [1,PBMoves::TACKLE],[1,PBMoves::PROTECT],[10,PBMoves::PROTECT],[15,PBMoves::BUGBITE],
                        [20,PBMoves::HIDDENPOWER],[23,PBMoves::CONFUSION],[26,PBMoves::MIRRORSHOT],
                        [29,PBMoves::METALSOUND],[32,PBMoves::PSYBEAM],[35,PBMoves::CAPTIVATE],[38,PBMoves::FLAIL],
                        [41,PBMoves::ATTRACT],[44,PBMoves::PSYCHIC],[47,PBMoves::IRONHEAD],[50,PBMoves::BUGBUZZ]]
   end
   next movelist
}
})

MultipleForms.register(PBSpecies::SHELLOS,{
"getFormOnCreation"=>proc{|pokemon|
   maps=[206,513,519,522,526,528,530,536,538,547,553,555,556,558,562,563,565,566,567,569,574,585,586,603,604,605,608,610]
   # Map IDs for second form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
}
})

MultipleForms.copy(:SHELLOS,:GASTRODON)

MultipleForms.register(PBSpecies::ROTOM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Normal Form
   next [50,65,107,86,105,107] # All alternate forms
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0               # Normal Form
   case pokemon.form
     when 1; next (PBTypes::FIRE)   # Heat, Microwave
     when 2; next (PBTypes::WATER)  # Wash, Washing Machine
     when 3; next (PBTypes::ICE)    # Frost, Refrigerator
     when 4; next (PBTypes::FLYING) # Fan
     when 5; next (PBTypes::GRASS)  # Mow, Lawnmower
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves=[
      :OVERHEAT,  # Heat, Microwave
      :HYDROPUMP, # Wash, Washing Machine
      :BLIZZARD,  # Frost, Refrigerator
      :AIRSLASH,  # Fan
      :LEAFSTORM  # Mow, Lawnmower
   ]
   moves.each{|move|
      pbDeleteMoveByID(pokemon,getID(PBMoves,move))
   }
   if form>0
     pokemon.pbLearnMove(moves[form-1])
   end
   if pokemon.moves.find_all{|i| i.id!=0}.length==0
     pokemon.pbLearnMove(:THUNDERSHOCK)
   end
}
})

MultipleForms.register(PBSpecies::GIRATINA,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next PBAbilities::LEVITATE # Origin Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 6500               # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Altered Forme
   next [150,120,100,90,120,100] # Origin Forme
},
"getForm"=>proc{|pokemon|
   maps=[49,50,51,72,73]   # Map IDs for Origin Forme
   if (pokemon.item == PBItems::GRISEOUSORB) ||
      ($game_map && maps.include?($game_map.map_id))
     next 1
   end
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SHAYMIN,{
"type2"=>proc{|pokemon|
   next if pokemon.form==0     # Land Forme
   next (PBTypes::FLYING) # Sky Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0              # Land Forme
   next PBAbilities::SERENEGRACE # Sky Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next 52                 # Sky Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [100,103,75,127,120,75] # Sky Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next [0,0,0,3,0,0]      # Sky Forme
},
"getForm"=>proc{|pokemon|
   next 0 if PBDayNight.isNight?(pbGetTimeNow) && $Trainer.id == pokemon.trainerID ||
             pokemon.hp<=0 || pokemon.status==PBStatuses::FROZEN
   next nil
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,PBMoves::GROWTH],[10,PBMoves::MAGICALLEAF],[19,PBMoves::LEECHSEED],
                        [28,PBMoves::QUICKATTACK],[37,PBMoves::SWEETSCENT],[46,PBMoves::NATURALGIFT],
                        [55,PBMoves::WORRYSEED],[64,PBMoves::AIRSLASH],[73,PBMoves::ENERGYBALL],
                        [82,PBMoves::SWEETKISS],[91,PBMoves::LEAFSTORM],[100,PBMoves::SEEDFLARE]]
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::ARCEUS,{
"type1"=>proc{|pokemon|
   types=[PBTypes::NORMAL,PBTypes::FIGHTING,PBTypes::FLYING,PBTypes::POISON,PBTypes::GROUND,
          PBTypes::ROCK,PBTypes::BUG,PBTypes::GHOST,PBTypes::STEEL,PBTypes::QMARKS,
          PBTypes::FIRE,PBTypes::WATER,PBTypes::GRASS,PBTypes::ELECTRIC,PBTypes::PSYCHIC,
          PBTypes::ICE,PBTypes::DRAGON,PBTypes::DARK,PBTypes::FAIRY]
    type1 = pokemon.form
    if $game_switches[:Pulse_Arceus] == true
        type1-= 19
    end
    next types[type1]
},
"type2"=>proc{|pokemon|
   types=[PBTypes::NORMAL,PBTypes::FIGHTING,PBTypes::FLYING,PBTypes::POISON,PBTypes::GROUND,
          PBTypes::ROCK,PBTypes::BUG,PBTypes::GHOST,PBTypes::STEEL,PBTypes::QMARKS,
          PBTypes::FIRE,PBTypes::WATER,PBTypes::GRASS,PBTypes::ELECTRIC,PBTypes::PSYCHIC,
          PBTypes::ICE,PBTypes::DRAGON,PBTypes::DARK,PBTypes::FAIRY]
    type2 = pokemon.form
    if $game_switches[:Pulse_Arceus] == true
        type2-= 19
    end
    next types[type2]
},
"getBaseStats"=>proc{|pokemon|
   next [255,125,185,160,125,185] if $game_switches[:Pulse_Arceus] == true # Pulse
   next # Standard
},
"getForm"=>proc{|pokemon|
  if $fefieldeffect == PBFields::NEWW
    if $fecounter == 1
     form = 0
     loop do
       form = $OnlineBattle.nil? ? rand(19) : $OnlineBattle.pbRandom(19)
       break if form != 9
     end
     if $game_switches[:Pulse_Arceus] == true
      form+=19
    end
     next form
    end
  else
     next 1  if (pokemon.item == PBItems::FISTPLATE) || (pokemon.item == PBItems::FIGHTINIUMZ2)
     next 2  if (pokemon.item == PBItems::SKYPLATE) || (pokemon.item == PBItems::FLYINIUMZ2)
     next 3  if (pokemon.item == PBItems::TOXICPLATE) || (pokemon.item == PBItems::POISONIUMZ2)
     next 4  if (pokemon.item == PBItems::EARTHPLATE) || (pokemon.item == PBItems::GROUNDIUMZ2)
     next 5  if (pokemon.item == PBItems::STONEPLATE) || (pokemon.item == PBItems::ROCKIUMZ2)
     next 6  if (pokemon.item == PBItems::INSECTPLATE) || (pokemon.item == PBItems::BUGINIUMZ2)
     next 7  if (pokemon.item == PBItems::SPOOKYPLATE) || (pokemon.item == PBItems::GHOSTIUMZ2)
     next 8  if (pokemon.item == PBItems::IRONPLATE) || (pokemon.item == PBItems::STEELIUMZ2)
     next 10 if (pokemon.item == PBItems::FLAMEPLATE) || (pokemon.item == PBItems::FIRIUMZ2)
     next 11 if (pokemon.item == PBItems::SPLASHPLATE) || (pokemon.item == PBItems::WATERIUMZ2)
     next 12 if (pokemon.item == PBItems::MEADOWPLATE) || (pokemon.item == PBItems::GRASSIUMZ2)
     next 13 if (pokemon.item == PBItems::ZAPPLATE) || (pokemon.item == PBItems::ELECTRIUMZ2)
     next 14 if (pokemon.item == PBItems::MINDPLATE) || (pokemon.item == PBItems::PSYCHIUMZ2)
     next 15 if (pokemon.item == PBItems::ICICLEPLATE) || (pokemon.item == PBItems::ICIUMZ2)
     next 16 if (pokemon.item == PBItems::DRACOPLATE) || (pokemon.item == PBItems::DRAGONIUMZ2)
     next 17 if (pokemon.item == PBItems::DREADPLATE) || (pokemon.item == PBItems::DARKINIUMZ2)
     next 18 if (pokemon.item == PBItems::PIXIEPLATE) || (pokemon.item == PBItems::FAIRIUMZ2)
     next 0 if $game_switches[:Pulse_Arceus] == false
  end
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Arceus") if $game_switches[:Pulse_Arceus] == true
   next
},
"weight"=>proc{|pokemon|
   next 9084 if $game_switches[:Pulse_Arceus] == true
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form>=19
   next
}
})

MultipleForms.register(PBSpecies::BASCULIN,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(2)
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0                 # Red-Striped
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
     next PBAbilities::ROCKHEAD     # Blue-Striped
   end
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Red-Striped
   next [0,PBItems::DEEPSEASCALE,0] # Blue-Striped
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::DARMANITAN,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "When wounded, it stops moving. It goes as still as stone to meditate, sharpening its mind and spirit." if pokemon.form==1  # Normal Zen Mode
   next "Though it has a gentle disposition, it's also very strong. It will quickly freeze the snowball on its head before going for a headbutt." if pokemon.form==2  # Galar
   next "Darmanitan takes this form when enraged. It won't stop spewing flames until its rage has settled, even if its body starts to melt." if pokemon.form==3  # Galar Zen Mode
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galarian form
   if $game_map && maps.include?($game_map.map_id)
     next 2
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form!=2      # Normal
   next 1.7                     # Galarian
},
"weight"=>proc{|pokemon|
   next if pokemon.form!=2      # Normal
   next 120                      # Galarian
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Standard Mode
   next [105,30,105,55,140,105] if pokemon.form==1  # Normal Zen Mode
   next if pokemon.form==2  # Galar
   next [105,160,135,55,30,55] if pokemon.form==1  # Galar Zen Mode
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::FIRE) if pokemon.form==1      # Zen
   next (PBTypes::ICE) if pokemon.form==2      # Galar
   next (PBTypes::ICE) if pokemon.form==3      # Galar Zen

},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::PSYCHIC) if pokemon.form==1      # Zen
   next (PBTypes::ICE) if pokemon.form==2      # Galar
   next (PBTypes::FIRE) if pokemon.form==3      # Galar Zen

},
"evYield"=>proc{|pokemon|
   next [0,0,0,0,2,0] if pokemon.form==2      # Zen Mode
   next # Otherwise
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=2      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[0,PBMoves::ICICLECRASH],[1,PBMoves::ICICLECRASH],[1,PBMoves::POWDERSNOW],[1,PBMoves::TACKLE],[1,PBMoves::TAUNT],[1,PBMoves::BITE],
                        [12,PBMoves::AVALANCHE],[16,PBMoves::WORKUP],[20,PBMoves::ICEFANG],[24,PBMoves::HEADBUTT],
                        [28,PBMoves::ICEPUNCH],[32,PBMoves::UPROAR],[38,PBMoves::BELLYDRUM],
                        [44,PBMoves::BLIZZARD],[50,PBMoves::THRASH],[56,PBMoves::SUPERPOWER]]
   end
   next movelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   next if pokemon.form==1 # Normal Zen Mode
   next if pokemon.form==3 # Galar Zen Mode
   if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::GORILLATACTICS
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::ZENMODE
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::DEERLING,{
"getFormOnCreation"=>proc{|pokemon|
   #time=pbGetTimeNow
   #next (time.month-1)%4
   maps=[710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,742]
   randomnum = rand(2)
   if $game_map && maps.include?($game_map.map_id)
     if randomnum==0
       next 2
     elsif randomnum==1
       next 3
     end
   else
     if randomnum==0
       next 0
     elsif randomnum==1
       next 1
     end
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.copy(PBSpecies::DEERLING,PBSpecies::SAWSBUCK)

MultipleForms.register(PBSpecies::TORNADUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,100,80,121,110,90] # Therian Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0                # Incarnate Forme
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next PBAbilities::REGENERATOR # Therian Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,3,0,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::THUNDURUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,105,70,101,145,80] # Therian Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0               # Incarnate Forme
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next PBAbilities::VOLTABSORB # Therian Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,0,3,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::LANDORUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0    # Incarnate Forme
   next [89,145,90,91,105,80] # Therian Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0               # Incarnate Forme
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next PBAbilities::INTIMIDATE # Therian Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,3,0,0,0,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::KYUREM,{
"getBaseStats"=>proc{|pokemon|
   case pokemon.form
     when 1; next [125,120, 90,95,170,100] # White Kyurem
     when 2; next [125,170,100,95,120, 90] # Black Kyurem
     else;   next                          # Kyurem
   end
},
"ability"=>proc{|pokemon|
   case pokemon.form
     when 1; next PBAbilities::TURBOBLAZE # White Kyurem
     when 2; next PBAbilities::TERAVOLT   # Black Kyurem
     else;   next                                # Kyurem
   end
},
"evYield"=>proc{|pokemon|
   case pokemon.form
     when 1; next [0,0,0,0,3,0] # White Kyurem
     when 2; next [0,3,0,0,0,0] # Black Kyurem
     else;   next               # Kyurem
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1; movelist=[[1,PBMoves::ICYWIND],[1,PBMoves::DRAGONRAGE],[8,PBMoves::IMPRISON],
                       [15,PBMoves::ANCIENTPOWER],[22,PBMoves::ICEBEAM],[29,PBMoves::DRAGONBREATH],
                       [36,PBMoves::SLASH],[43,PBMoves::FUSIONFLARE],[50,PBMoves::ICEBURN],
                       [57,PBMoves::DRAGONPULSE],[64,PBMoves::IMPRISON],[71,PBMoves::ENDEAVOR],
                       [78,PBMoves::BLIZZARD],[85,PBMoves::OUTRAGE],[92,PBMoves::HYPERVOICE]]
     when 2; movelist=[[1,PBMoves::ICYWIND],[1,PBMoves::DRAGONRAGE],[8,PBMoves::IMPRISON],
                       [15,PBMoves::ANCIENTPOWER],[22,PBMoves::ICEBEAM],[29,PBMoves::DRAGONBREATH],
                       [36,PBMoves::SLASH],[43,PBMoves::FUSIONBOLT],[50,PBMoves::FREEZESHOCK],
                       [57,PBMoves::DRAGONPULSE],[64,PBMoves::IMPRISON],[71,PBMoves::ENDEAVOR],
                       [78,PBMoves::BLIZZARD],[85,PBMoves::OUTRAGE],[92,PBMoves::HYPERVOICE]]
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::KELDEO,{
"getForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(PBMoves::SECRETSWORD) # Resolute Form
   next 0                                     # Ordinary Form
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::MELOETTA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [100,128,90,128,77,77] # Pirouette Forme
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0       # Aria Forme
   next (PBTypes::FIGHTING) # Pirouette Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Aria Forme
   next [0,1,1,1,0,0]      # Pirouette Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GENESECT,{
"getForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::SHOCKDRIVE)
   next 2 if (pokemon.item == PBItems::BURNDRIVE)
   next 3 if (pokemon.item == PBItems::CHILLDRIVE)
   next 4 if (pokemon.item == PBItems::DOUSEDRIVE)
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::MEOWSTIC,{
   "ability"=>proc{|pokemon|
      next if pokemon.gender==0 # Male Meowstic
      if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
         next PBAbilities::COMPETITIVE # Female Meowstic
      end
   },

   "getMoveList"=>proc{|pokemon|
   next if pokemon.gender==0 # Male Meowstic
   movelist=[]
   case pokemon.gender
   when 1 ; movelist=[[1,PBMoves::STOREDPOWER],[1,PBMoves::MEFIRST],[1,PBMoves::MAGICALLEAF],[1,PBMoves::SCRATCH],
   [1,PBMoves::LEER],[1,PBMoves::COVET],[1,PBMoves::CONFUSION],[5,PBMoves::COVET],[9,PBMoves::CONFUSION],[13,PBMoves::LIGHTSCREEN],
   [17,PBMoves::PSYBEAM],[19,PBMoves::FAKEOUT],[22,PBMoves::DISARMINGVOICE],[25,PBMoves::PSYSHOCK],[28,PBMoves::CHARGEBEAM],
   [31,PBMoves::SHADOWBALL],[35,PBMoves::EXTRASENSORY],[40,PBMoves::PSYCHIC],
   [43,PBMoves::ROLEPLAY],[45,PBMoves::SIGNALBEAM],[48,PBMoves::SUCKERPUNCH],
   [50,PBMoves::FUTURESIGHT],[53,PBMoves::STOREDPOWER]] # Female Meowstic
   end
   next movelist
   }
})

MultipleForms.register(PBSpecies::AEGISLASH,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0    # Shield Forme
      next [60,150,50,60,150,50] if pokemon.form==1 # Blade Forme
      next [200,150,150,70,150,150] if pokemon.form==2 # Crystal Aegislash
    },
    "type2"=>proc{|pokemon|
       next if pokemon.form < 2
       next (PBTypes::FAIRY) # Crystal Aegislash
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form < 2
      next PBAbilities::FRIENDGUARD # Crystal Aegislash
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
})

MultipleForms.register(PBSpecies::ZYGARDE,{
"dexEntry"=>proc{|pokemon|
   case pokemon.form
   when 0
     next  # 50%
   when 1
     next "Its sharp fangs make short work of finishing off its enemies, but it's unable to maintain this body indefinitely. After a period of time, it falls apart." # 10%
   when 2
     next "This is Zygarde's form at times when it uses its overwhelming power to suppress those who endanger the ecosystem." # 100%
   end
},
"getBaseStats"=>proc{|pokemon|
   case pokemon.form
   when 0 # 50%
     next
   when 1 # 10%
     next [54,100,71,115,61,85]
   when 2 # 100%
     next [216,100,121,85,91,95]
   end
},
"height"=>proc{|pokemon|
   case pokemon.form
   when 0 # 50%
     next
   when 1 # 10%
     next 12
   when 2 # 100%
     next 45
   end
},
"weight"=>proc{|pokemon|
   case pokemon.form
   when 0 # 50%
     next
   when 1 # 10%
     next 335
   when 2 # 100%
     next 6100
   end
   next 490 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::HOOPA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   next [80,160,60,80,170,130] # Unbound Forme
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0
   next (PBTypes::DARK) # Unbound Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next PBAbilities::MAGICIAN # Unbound Forme
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,PBMoves::HYPERSPACEFURY],[1,PBMoves::TRICK],[1,PBMoves::DESTINYBOND],[1,PBMoves::ALLYSWITCH],
                        [1,PBMoves::CONFUSION],[6,PBMoves::ASTONISH],[10,PBMoves::MAGICCOAT],[15,PBMoves::LIGHTSCREEN],
                        [19,PBMoves::PSYBEAM],[25,PBMoves::SKILLSWAP],[29,PBMoves::POWERSPLIT],[29,PBMoves::GUARDSPLIT],
                        [46,PBMoves::KNOCKOFF],[50,PBMoves::WONDERROOM],[50,PBMoves::TRICKROOM],[55,PBMoves::DARKPULSE],
                        [75,PBMoves::PSYCHIC],[85,PBMoves::HYPERSPACEFURY]]
   end
   next movelist
},
"height"=>proc{|pokemon|
   next 650 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 4900 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::ORICORIO,{
"dexEntry"=>proc{|pokemon|
   case pokemon.form
   when 0
     next  # Baile
   when 1
     next "It creates an electric charge by rubbing its feathers together. It dances over to its enemies and delivers shocking electrical punches." # Pom-Pom
   when 2
     next "This Oricorio relaxes by swaying gently. This increases its psychic energy, which it then fires at its enemies." # Pa'u
   when 3
     next "It summons the dead with its dreamy dancing. From their malice, it draws power with which to curse its enemies." # Sensu
   end
},
"type1"=>proc{|pokemon|
   case pokemon.form
   when 0
     next #(PBTypes::FIRE) # Baile
   when 1
     next (PBTypes::ELECTRIC) # Pom-Pom
   when 2
     next (PBTypes::PSYCHIC) # Pa'u
   when 3
     next (PBTypes::GHOST) # Sensu
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::LYCANROC,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Midday
   next "It goads its enemies into attacking, withstands the hits, and in return, delivers a headbutt, crushing their bones with its rocky mane." if pokemon.form==1   # Midnight
   next "Bathed in the setting sun of evening, Lycanroc has undergone a special kind of evolution. An intense fighting spirit underlies its calmness." if pokemon.form==2 # Dusk
},
"height"=>proc{|pokemon|
   next 11 if pokemon.form==1  # Midnight
   next                         # Midday
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0        # Midday
   next [85,115,75,82,55,75] if pokemon.form==1 # Midnight
   next [75,117,65,110,55,65] if pokemon.form==2 # Dusk
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Midday
   movelist=[]
   case pokemon.form            # Midnight, Dusk
     when 1 ; movelist=[[0,PBMoves::COUNTER],[1,PBMoves::REVERSAL],[1,PBMoves::TAUNT],
                        [1,PBMoves::TACKLE],[1,PBMoves::LEER],[1,PBMoves::SANDATTACK],
                        [1,PBMoves::BITE],[4,PBMoves::SANDATTACK],[7,PBMoves::BITE],[12,PBMoves::HOWL],
                        [15,PBMoves::ROCKTHROW],[18,PBMoves::ODORSLEUTH],[23,PBMoves::ROCKTOMB],
                        [26,PBMoves::ROAR],[29,PBMoves::STEALTHROCK],[34,PBMoves::ROCKSLIDE],
                        [37,PBMoves::SCARYFACE],[40,PBMoves::CRUNCH],[45,PBMoves::ROCKCLIMB],
                        [48,PBMoves::STONEEDGE]]
     when 2 ; movelist=[[0,PBMoves::THRASH],[1,PBMoves::ACCELEROCK],[1,PBMoves::COUNTER],
                        [1,PBMoves::TACKLE],[1,PBMoves::LEER],[1,PBMoves::SANDATTACK],
                        [1,PBMoves::BITE],[4,PBMoves::SANDATTACK],[7,PBMoves::BITE],[12,PBMoves::HOWL],
                        [15,PBMoves::ROCKTHROW],[18,PBMoves::ODORSLEUTH],[23,PBMoves::ROCKTOMB],
                        [26,PBMoves::ROAR],[29,PBMoves::STEALTHROCK],[34,PBMoves::ROCKSLIDE],
                        [37,PBMoves::SCARYFACE],[40,PBMoves::CRUNCH],[45,PBMoves::ROCKCLIMB],
                        [48,PBMoves::STONEEDGE]]
   end
   next movelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Midday
   case pokemon.form
     when 1 # Midnight
       if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
         next PBAbilities::VITALSPIRIT
       elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
         next PBAbilities::NOGUARD
       end
     when 2 # Dusk
       next PBAbilities::TOUGHCLAWS
   end
},
"getFormOnCreation"=>proc{|pokemon|
   daytime = PBDayNight.isDay?(pbGetTimeNow)
   dusktime = PBDayNight.isDusk?(pbGetTimeNow)
   # Map IDs for second form
   if dusktime
     next 2
   elsif daytime
     next 0
   else
     next 1
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::WISHIWASHI,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Solo
   next "At their appearance, even Gyarados will flee. When they team up to use Water Gun, its power exceeds that of Hydro Pump."     # School
},
"height"=>proc{|pokemon|
   next 82 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 786 if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Solo
   next [45,140,130,35,140,135]   # School
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::SILVALLY,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Type: Normal
   next "Upon awakening, its RKS System is activated. By employing specific memories, this Pokémon can adapt its type to confound its enemies."     # All other types
},
"type1"=>proc{|pokemon|
   types=[PBTypes::NORMAL,PBTypes::FIGHTING,PBTypes::FLYING,PBTypes::POISON,PBTypes::GROUND,
          PBTypes::ROCK,PBTypes::BUG,PBTypes::GHOST,PBTypes::STEEL,PBTypes::QMARKS,
          PBTypes::FIRE,PBTypes::WATER,PBTypes::GRASS,PBTypes::ELECTRIC,PBTypes::PSYCHIC,
          PBTypes::ICE,PBTypes::DRAGON,PBTypes::DARK,PBTypes::FAIRY]
   next types[pokemon.form]
},
"type2"=>proc{|pokemon|
   types=[PBTypes::NORMAL,PBTypes::FIGHTING,PBTypes::FLYING,PBTypes::POISON,PBTypes::GROUND,
          PBTypes::ROCK,PBTypes::BUG,PBTypes::GHOST,PBTypes::STEEL,PBTypes::QMARKS,
          PBTypes::FIRE,PBTypes::WATER,PBTypes::GRASS,PBTypes::ELECTRIC,PBTypes::PSYCHIC,
          PBTypes::ICE,PBTypes::DRAGON,PBTypes::DARK,PBTypes::FAIRY]
   next types[pokemon.form]
},
"getForm"=>proc{|pokemon|
  if $fefieldeffect == PBFields::NEWW
    if $fecounter == 1
     form = 0
     loop do
       form = $OnlineBattle.nil? ? rand(19) : $OnlineBattle.pbRandom(19)
       break if form != 9
     end
     next form
    end
  else
     next 9  if $fefieldeffect == PBFields::GLITCHF # ??? on Glitch Field
     next 17 if $fefieldeffect == PBFields::HOLYF # Dark on Holy Field (Because Science is evil)
     next 1  if (pokemon.item == PBItems::FIGHTINGMEMORY)
     next 2  if (pokemon.item == PBItems::FLYINGMEMORY)
     next 3  if (pokemon.item == PBItems::POISONMEMORY)
     next 4  if (pokemon.item == PBItems::GROUNDMEMORY)
     next 5  if (pokemon.item == PBItems::ROCKMEMORY)
     next 6  if (pokemon.item == PBItems::BUGMEMORY)
     next 7  if (pokemon.item == PBItems::GHOSTMEMORY)
     next 8  if (pokemon.item == PBItems::STEELMEMORY)
     next 10 if (pokemon.item == PBItems::FIREMEMORY)
     next 11 if (pokemon.item == PBItems::WATERMEMORY)
     next 12 if (pokemon.item == PBItems::GRASSMEMORY)
     next 13 if (pokemon.item == PBItems::ELECTRICMEMORY)
     next 14 if (pokemon.item == PBItems::PSYCHICMEMORY)
     next 15 if (pokemon.item == PBItems::ICEMEMORY)
     next 16 if (pokemon.item == PBItems::DRAGONMEMORY)
     next 17 if (pokemon.item == PBItems::DARKMEMORY)
     next 18 if (pokemon.item == PBItems::FAIRYMEMORY)
     next 0
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::MINIOR,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form!=7      # Core
   next "Originally making its home in the ozone layer, it hurtles to the ground when the shell enclosing its body grows too heavy."     # Meteor
},
"getFormOnCreation"=>proc{|pokemon|
   next rand(7)
},
"weight"=>proc{|pokemon|
   next 400 if pokemon.form==7
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form!=7      # Core
   next [60,60,100,60,60,100]   # Meteor
},
"catchrate"=>proc{|pokemon|
   next 30 if pokemon.form==7
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::NECROZMA,{
"dexEntry"=>proc{|pokemon|
   case pokemon.form
     when 0 # Normal
       next
     when 1 # Dusk Mane
       next "This is its form while it is devouring the light of Solgaleo. It pounces on foes and then slashes them with the claws on its four limbs and back."
     when 2 # Dawn Wings
       next "This is its form while it's devouring the light of Lunala. It grasps foes in its giant claws and rips them apart with brute force."
     when 3 # Ultra
       next "The light pouring out from all over its body affects living things and nature, impacting them in various ways."
   end
},
"height"=>proc{|pokemon|
   next 38 if pokemon.form==1 # Dusk Mane
   next 42 if pokemon.form==2 # Dawn Wings
   next 75 if pokemon.form==3 # Ultra
   next # Normal
},
"weight"=>proc{|pokemon|
   next 4600 if pokemon.form==1 # Dusk Mane
   next 3500 if pokemon.form==2 # Dawn Wings
   next 2300 if pokemon.form==3 # Ultra
   next # Normal
},
"getUltraForm"=>proc{|pokemon|
   next 3 if (pokemon.item == PBItems::ULTRANECROZIUMZ2) && pokemon.form!=0
   next
},
"getUltraName"=>proc{|pokemon|
   next _INTL("Ultra Necrozma") if pokemon.form==3
   next
},
"getBaseStats"=>proc{|pokemon|
   case pokemon.form
     when 1; next [97,157,127,77,113,109] # Dusk Mane
     when 2; next [97,113,109,77,157,127] # Dawn Wings
     when 3; next [97,167,97,129,167,97]  # Ultra
     else;   next                         # Normal
   end
},
"type2"=>proc{|pokemon|
   next (PBTypes::STEEL) if pokemon.form==1  # Dusk Mane
   next (PBTypes::GHOST) if pokemon.form==2  # Dawn Wings
   next (PBTypes::DRAGON) if pokemon.form==3 # Ultra
   next # Normal
},
"ability"=>proc{|pokemon|
   case pokemon.form
     when 3; next PBAbilities::NEUROFORCE # Ultra
     else;   next                                # Other formes
   end
},
"evYield"=>proc{|pokemon|
   case pokemon.form
   when 2; next [0,0,0,0,3,0] # Dawn Wings
   when 3; next [0,1,0,1,1,0]  # Ultra
   when 1; next [0,3,0,0,0,0] # Dusk Mane
     else;   next                         # Normal
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
      moves=[
      PBMoves::CONFUSION,        # Normal
      PBMoves::SUNSTEELSTRIKE,  # Dusk Mane
      PBMoves::MOONGEISTBEAM,   # Dawn Wings
   ]
   if form!=3
     moves.each{|movething|
        pbDeleteMoveByID(pokemon,movething)
     }
     pokemon.pbLearnMove(moves[form])
   end
}
})

MultipleForms.register(PBSpecies::EISCUE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0                 # Ice Forme
   case pokemon.form
     when 1; next [75,80,70,130,65,50] # Noice Forme
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


### Regional Variants ###

MultipleForms.register(PBSpecies::RATTATA,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "With its incisors, it gnaws through doors and infiltrates people's homes. Then, with a twitch of its whiskers, it steals whatever food it finds."     # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[170, 524]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 38                     # Alola
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DARK)    # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::NORMAL)  # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::TACKLE],[1,PBMoves::TAILWHIP],[4,PBMoves::QUICKATTACK],
                        [7,PBMoves::FOCUSENERGY],[10,PBMoves::BITE],[13,PBMoves::PURSUIT],
                        [16,PBMoves::HYPERFANG],[19,PBMoves::ASSURANCE],[22,PBMoves::CRUNCH],
                        [25,PBMoves::SUCKERPUNCH],[29,PBMoves::SUPERFANG],[31,PBMoves::DOUBLEEDGE],
                        [34,PBMoves::ENDEAVOR]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Alola
     when 1 ; eggmovelist=[PBMoves::COUNTER,PBMoves::FINALGAMBIT,PBMoves::FURYSWIPES,PBMoves::MEFIRST,
                           PBMoves::REVENGE,PBMoves::REVERSAL,PBMoves::SNATCH,PBMoves::STOCKPILE,
                           PBMoves::SWALLOW,PBMoves::SWITCHEROO,PBMoves::UPROAR]
   end
   next eggmovelist
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal
   next [0,PBItems::PECHABERRY,0]   # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::GLUTTONY
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::HUSTLE
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::THICKFAT
   end
},
"getEvo"=>proc{|pokemon|
   next if pokemon.form==0                  # Normal
   next [[30,20,20]]                        # Alola    [LevelNight,20,Raticate]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::RATICATE,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "It forms a group of Rattata, which it assumes command of. Each group has its own territory, and disputes over food happen often."     # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[170, 524]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 255                     # Alola
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DARK)    # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::NORMAL)  # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[0,PBMoves::SCARYFACE],[1,PBMoves::SWORDSDANCE],[1,PBMoves::TACKLE],
                        [1,PBMoves::TAILWHIP],[1,PBMoves::QUICKATTACK],[1,PBMoves::FOCUSENERGY],
                        [4,PBMoves::QUICKATTACK],[7,PBMoves::FOCUSENERGY],[10,PBMoves::BITE],[13,PBMoves::PURSUIT],
                        [16,PBMoves::HYPERFANG],[19,PBMoves::ASSURANCE],[24,PBMoves::CRUNCH],
                        [29,PBMoves::SUCKERPUNCH],[34,PBMoves::SUPERFANG],[39,PBMoves::DOUBLEEDGE],
                        [44,PBMoves::ENDEAVOR]]
   end
   next movelist
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal
   next [0,PBItems::PECHABERRY,0]   # Alola
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [75,71,70,77,40,80]   # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::GLUTTONY
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::HUSTLE
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::THICKFAT
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::RAICHU,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "It uses psychokinesis to control electricity. It hops aboard its own tail, using psychic power to lift the tail and move about while riding it."  # Alola
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 7                     # Alola
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 210                    # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::PSYCHIC)  # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[0,PBMoves::PSYCHIC],[1,PBMoves::SPEEDSWAP],[1,PBMoves::THUNDERSHOCK],
                        [1,PBMoves::TAILWHIP],[1,PBMoves::QUICKATTACK],[1,PBMoves::THUNDERBOLT]]
   end
   next movelist
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [60,85,50,110,95,85]    # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0              # Normal
   next PBAbilities::SURGESURFER # Alola
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SANDSHREW,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "It lives on snowy mountains. Its steel shell is very hard—so much so, it can't roll its body up into a ball."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[364, 366, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 390, 396, 430, 433, 434, 440, 441, 442]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 6                     # Alola
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 400                    # Alola
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ICE)     # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::STEEL)   # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::SCRATCH],[1,PBMoves::DEFENSECURL],[3,PBMoves::BIDE],
                        [5,PBMoves::POWDERSNOW],[7,PBMoves::ICEBALL],[9,PBMoves::RAPIDSPIN],
                        [11,PBMoves::FURYCUTTER],[14,PBMoves::METALCLAW],[17,PBMoves::SWIFT],
                        [20,PBMoves::FURYSWIPES],[23,PBMoves::IRONDEFENSE],[26,PBMoves::SLASH],
                        [30,PBMoves::IRONHEAD],[34,PBMoves::GYROBALL],[38,PBMoves::SWORDSDANCE],
                        [42,PBMoves::HAIL],[46,PBMoves::BLIZZARD]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Alola
     when 1 ; eggmovelist=[PBMoves::AMNESIA,PBMoves::CHIPAWAY,PBMoves::COUNTER,PBMoves::CRUSHCLAW,PBMoves::CURSE,
                           PBMoves::ENDURE,PBMoves::FLAIL,PBMoves::HONECLAWS,PBMoves::ICICLECRASH,PBMoves::ICICLESPEAR,
                           PBMoves::METALCLAW,PBMoves::NIGHTSLASH]
   end
   next eggmovelist
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [50,75,90,40,10,35]     # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::SNOWCLOAK
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::SLUSHRUSH
   elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
     check = (pokemon.personalID)&1
     next PBAbilities::SNOWCLOAK if check==0
     next PBAbilities::SLUSHRUSH if check==1
   end
},
"getEvo"=>proc{|pokemon|
   next if pokemon.form==0                  # Normal
   next [[7,692,28]]                        # Alola    [Item,Ice Stone,Sandslash]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SANDSLASH,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "This Pokémon's steel spikes are sheathed in ice. Stabs from these spikes cause deep wounds and severe frostbite as well."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[364, 366, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 390, 396, 430, 433, 434, 440, 441, 442, 749, 750, 834, 882]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 12                     # Alola
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 550                    # Alola
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ICE)     # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::STEEL)   # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[0,PBMoves::ICICLESPEAR],[1,PBMoves::METALBURST],[1,PBMoves::ICICLECRASH],
                        [1,PBMoves::SLASH],[1,PBMoves::DEFENSECURL],[1,PBMoves::ICEBALL],
                        [1,PBMoves::METALCLAW]]
   end
   next movelist
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [75,100,120,65,25,65]     # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::SNOWCLOAK
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::SLUSHRUSH
   elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
     check = (pokemon.personalID)&1
     next PBAbilities::SNOWCLOAK if check==0
     next PBAbilities::SLUSHRUSH if check==1
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::VULPIX,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "In hot weather, this Pokémon makes ice shards with its six tails and sprays them around to cool itself off."     # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[439]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ICE)     # Alola
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ICE)     # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ICE)     # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::POWDERSNOW],[4,PBMoves::TAILWHIP],[7,PBMoves::ROAR],
                        [9,PBMoves::BABYDOLLEYES],[10,PBMoves::ICESHARD],[12,PBMoves::CONFUSERAY],
                        [15,PBMoves::ICYWIND],[18,PBMoves::PAYBACK],[20,PBMoves::MIST],
                        [23,PBMoves::FEINTATTACK],[26,PBMoves::HEX],[28,PBMoves::AURORABEAM],
                        [31,PBMoves::EXTRASENSORY],[34,PBMoves::SAFEGUARD],[36,PBMoves::ICEBEAM],
                        [39,PBMoves::IMPRISON],[42,PBMoves::BLIZZARD],[44,PBMoves::GRUDGE],
                        [47,PBMoves::CAPTIVATE],[50,PBMoves::SHEERCOLD]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Alola
     when 1 ; eggmovelist=[PBMoves::AGILITY,PBMoves::CHARM,PBMoves::DISABLE,PBMoves::ENCORE,
                           PBMoves::EXTRASENSORY,PBMoves::FLAIL,PBMoves::FREEZEDRY,PBMoves::HOWL,
                           PBMoves::HYPNOSIS,PBMoves::MOONBLAST,PBMoves::POWERSWAP,PBMoves::SPITE,
                           PBMoves::SECRETPOWER,PBMoves::TAILSLAP]
   end
   next eggmovelist
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal
   next [0,PBItems::SNOWBALL,0]     # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::SNOWCLOAK
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::SNOWWARNING
   elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
     check = (pokemon.personalID)&1
     next PBAbilities::SNOWCLOAK if check==0
     next PBAbilities::SNOWWARNING if check==1
   end
},
"getEvo"=>proc{|pokemon|
   next if pokemon.form==0                  # Normal
   next [[7,692,38]]                        # Alola    [Item,Ice Stone,Ninetales]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::NINETALES,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Possessing a calm demeanor, this Pokémon was revered as a deity incarnate before it was identified as a regional variant of Ninetales."     # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[439,721,723,725,726,727,729,794]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ICE)     # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::FAIRY)   # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[0,PBMoves::DAZZLINGGLEAM],[1,PBMoves::IMPRISON],[1,PBMoves::NASTYPLOT],
                        [1,PBMoves::ICEBEAM],[1,PBMoves::ICESHARD],[1,PBMoves::CONFUSERAY],
                        [1,PBMoves::SAFEGUARD]]
   end
   next movelist
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal
   next [0,PBItems::SNOWBALL,0]     # Alola
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [0,0,0,2,0,0]           # Alola
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [73,67,75,109,81,100]   # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::SNOWCLOAK
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::SNOWWARNING
   elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
     check = (pokemon.personalID)&1
     next PBAbilities::SNOWCLOAK if check==0
     next PBAbilities::SNOWWARNING if check==1
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::DIGLETT,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Its head sports an altered form of whiskers made of metal. When in communication with its comrades, its whiskers wobble to and fro."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[33, 34, 35, 199, 201, 202, 203, 204]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 10                     # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::STEEL)   # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::SANDATTACK],[1,PBMoves::METALCLAW],[4,PBMoves::GROWL],
                        [7,PBMoves::ASTONISH],[10,PBMoves::MUDSLAP],[14,PBMoves::MAGNITUDE],
                        [18,PBMoves::BULLDOZE],[22,PBMoves::SUCKERPUNCH],[25,PBMoves::MUDBOMB],
                        [28,PBMoves::EARTHPOWER],[31,PBMoves::DIG],[35,PBMoves::IRONHEAD],
                        [39,PBMoves::EARTHQUAKE],[43,PBMoves::FISSURE]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Alola
     when 1 ; eggmovelist=[PBMoves::ANCIENTPOWER,PBMoves::BEATUP,PBMoves::ENDURE,PBMoves::FEINTATTACK,
                           PBMoves::FINALGAMBIT,PBMoves::HEADBUTT,PBMoves::MEMENTO,PBMoves::METALSOUND,
                           PBMoves::PURSUIT,PBMoves::REVERSAL,PBMoves::FLASH]
   end
   next eggmovelist
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [10,55,30,90,35,40]     # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Alola
     next PBAbilities::TANGLINGHAIR
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::DUGTRIO,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Its shining gold hair provides it with protection. It's reputed that keeping any of its fallen hairs will bring bad luck."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[33, 34, 35, 199, 201, 202, 203, 204]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 666                    # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::STEEL)   # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[0,PBMoves::SANDTOMB],[1,PBMoves::ROTOTILLER],[1,PBMoves::NIGHTSLASH],
                        [1,PBMoves::TRIATTACK],[1,PBMoves::SANDATTACK],[1,PBMoves::METALCLAW],[1,PBMoves::GROWL],
                        [4,PBMoves::GROWL],[7,PBMoves::ASTONISH],[10,PBMoves::MUDSLAP],[14,PBMoves::MAGNITUDE],
                        [18,PBMoves::BULLDOZE],[22,PBMoves::SUCKERPUNCH],[25,PBMoves::MUDBOMB],
                        [30,PBMoves::EARTHPOWER],[35,PBMoves::DIG],[41,PBMoves::IRONHEAD],
                        [47,PBMoves::EARTHQUAKE],[53,PBMoves::FISSURE]]
   end
   next movelist
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [0,2,0,0,0,0]           # Alola
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [35,100,60,110,50,70]     # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Alola
     next PBAbilities::TANGLINGHAIR
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::MEOWTH,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "When its delicate pride is wounded, or when the gold coin on its forehead is dirtied, it flies into a hysterical rage." if pokemon.form==1  # Alola
   next "These daring Pokémon have coins on their foreheads. Darker coins are harder, and harder coins garner more respect among Meowth." # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   aMaps=[170, 524]
   gMaps=[]
   # Map IDs for alolan and galarian forms respectively
   if $game_map && aMaps.include?($game_map.map_id)
     next 1
   elsif $game_map && gMaps.include?($game_map.map_id)
     next 2
   else
     next 0
   end
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DARK) if pokemon.form==1   # Alola
   next (PBTypes::STEEL)    # GALAR
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DARK) if pokemon.form==1   # Alola
   next (PBTypes::STEEL)    # Galar
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alolan and Galarian
     when 1 ; movelist=[[1,PBMoves::SCRATCH],[1,PBMoves::GROWL],[6,PBMoves::BITE],
                        [9,PBMoves::FAKEOUT],[14,PBMoves::FURYSWIPES],[17,PBMoves::SCREECH],
                        [22,PBMoves::FEINTATTACK],[25,PBMoves::TAUNT],[30,PBMoves::PAYDAY],
                        [33,PBMoves::SLASH],[38,PBMoves::NASTYPLOT],[41,PBMoves::ASSURANCE],
                        [46,PBMoves::CAPTIVATE],[49,PBMoves::NIGHTSLASH],[50,PBMoves::FEINT],
                        [55,PBMoves::DARKPULSE]]
     when 2 ; movelist=[[1,PBMoves::FAKEOUT],[1,PBMoves::GROWL],[4,PBMoves::HONECLAWS],
                        [8,PBMoves::SCRATCH],[12,PBMoves::PAYDAY],[16,PBMoves::METALCLAW],
                        [20,PBMoves::TAUNT],[24,PBMoves::SWAGGER],[29,PBMoves::FURYSWIPES],
                        [32,PBMoves::SCREECH],[36,PBMoves::SLASH],[40,PBMoves::METALSOUND],
                        [44,PBMoves::THRASH]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Alolan and Galarian
     when 1 ; eggmovelist=[PBMoves::AMNESIA,PBMoves::ASSIST,PBMoves::CHARM,PBMoves::COVET,PBMoves::FLAIL,PBMoves::FLATTER,
                           PBMoves::FOULPLAY,PBMoves::HYPNOSIS,PBMoves::PARTINGSHOT,PBMoves::PUNISHMENT,
                           PBMoves::SNATCH,PBMoves::SPITE]
     when 2 ; eggmovelist=[PBMoves::COVET,PBMoves::FLAIL,PBMoves::SPITE,PBMoves::DOUBLEEDGE,PBMoves::CURSE,PBMoves::NIGHTSLASH]
   end
   next eggmovelist
},
"evYield"=>proc{|pokemon|
   next if pokemon.form!=2      # Normal/Alola
   next [0,1,0,0,0,0]           # Galarian
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   case pokemon.form
     when 1 ; next [40,35,35,90,50,40]     # Alola
     when 2 ; next [50,65,55,40,40,40]     # Galarian
   end
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   case pokemon.form
     when 1
     if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2) # Alola
       next PBAbilities::RATTLED
     end
     when 2
     if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Galar
       next PBAbilities::TOUGHCLAWS
     end
   end
},
"getEvo"=>proc{|pokemon|
   next if pokemon.form==0                  # Normal
   next [[1,0,53]]                          # Alola    [Happiness,,Persian]
   next [[4,28,863]]                        # Galar    [Level,28,Perrserker]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::PERSIAN,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "It looks down on everyone other than itself. Its preferred tactics are sucker punches and blindside attacks."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[170, 524, 866]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 11                     # Alola
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 330                    # Alola
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DARK)    # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DARK)    # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[0,PBMoves::SWIFT],[1,PBMoves::QUASH],[1,PBMoves::PLAYROUGH],[1,PBMoves::SWITCHEROO],
                        [1,PBMoves::SCRATCH],[1,PBMoves::GROWL],[1,PBMoves::BITE],[1,PBMoves::FAKEOUT],[6,PBMoves::BITE],
                        [9,PBMoves::FAKEOUT],[14,PBMoves::FURYSWIPES],[17,PBMoves::SCREECH],
                        [22,PBMoves::FEINTATTACK],[25,PBMoves::TAUNT],[32,PBMoves::POWERGEM],
                        [37,PBMoves::SLASH],[44,PBMoves::NASTYPLOT],[49,PBMoves::ASSURANCE],
                        [56,PBMoves::CAPTIVATE],[61,PBMoves::NIGHTSLASH],[65,PBMoves::FEINT],
                        [69,PBMoves::DARKPULSE]]
   end
   next movelist
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [65,60,60,115,75,65]    # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::FURCOAT
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::RATTLED
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GEODUDE,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "If you accidentally step on a Geodude sleeping on the ground, you'll hear a crunching sound and feel a shock ripple through your entire body."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[231, 247, 251, 258, 259, 260, 261, 262, 263, 264, 340, 341, 342, 343, 344, 346, 347, 348, 349, 371, 614, 615, 616, 618]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 203                    # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ELECTRIC)# Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::TACKLE],[1,PBMoves::DEFENSECURL],[4,PBMoves::CHARGE],
                        [6,PBMoves::ROCKPOLISH],[10,PBMoves::ROLLOUT],[12,PBMoves::SPARK],
                        [16,PBMoves::ROCKTHROW],[18,PBMoves::SMACKDOWN],[22,PBMoves::THUNDERPUNCH],
                        [24,PBMoves::SELFDESTRUCT],[28,PBMoves::STEALTHROCK],[30,PBMoves::ROCKBLAST],
                        [34,PBMoves::DISCHARGE],[36,PBMoves::EXPLOSION],[40,PBMoves::DOUBLEEDGE],
                        [42,PBMoves::STONEEDGE]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Alola
     when 1 ; eggmovelist=[PBMoves::AUTOTOMIZE,PBMoves::BLOCK,PBMoves::COUNTER,PBMoves::CURSE,PBMoves::ENDURE,PBMoves::FLAIL,
                           PBMoves::MAGNETRISE,PBMoves::ROCKCLIMB,PBMoves::SCREECH,PBMoves::WIDEGUARD]
   end
   next eggmovelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::MAGNETPULL
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::GALVANIZE
   end
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal
   next [0,PBItems::CELLBATTERY,0]  # Alola
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GRAVELER,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "They eat rocks and often get into a scrap over them. The shock of Graveler smashing together causes a flash of light and a booming noise."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[231, 247, 251, 258, 259, 260, 261, 262, 263, 264, 340, 341, 342, 343, 344, 346, 347, 348, 349, 371, 614, 615, 616, 618]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 1100                   # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ELECTRIC)# Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::TACKLE],[1,PBMoves::DEFENSECURL],[4,PBMoves::CHARGE],[1,PBMoves::ROCKPOLISH],
                        [1,PBMoves::CHARGE],[6,PBMoves::ROCKPOLISH],[10,PBMoves::ROLLOUT],[12,PBMoves::SPARK],
                        [16,PBMoves::ROCKTHROW],[18,PBMoves::SMACKDOWN],[22,PBMoves::THUNDERPUNCH],
                        [24,PBMoves::SELFDESTRUCT],[30,PBMoves::STEALTHROCK],[34,PBMoves::ROCKBLAST],
                        [40,PBMoves::DISCHARGE],[44,PBMoves::EXPLOSION],[50,PBMoves::DOUBLEEDGE],
                        [54,PBMoves::STONEEDGE]]
   end
   next movelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::MAGNETPULL
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::GALVANIZE
   end
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal
   next [0,PBItems::CELLBATTERY,0]  # Alola
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GOLEM,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Because it can't fire boulders at a rapid pace, it's been known to seize nearby Geodude and fire them from its back."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[231, 247, 251, 258, 259, 260, 261, 262, 263, 264, 340, 341, 342, 343, 344, 346, 347, 348, 349, 371, 614, 615, 616, 618, 834, 847]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 17                     # Alola
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 3160                   # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ELECTRIC)# Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::HEAVYSLAM],[1,PBMoves::TACKLE],[1,PBMoves::DEFENSECURL],[1,PBMoves::CHARGE],
                        [1,PBMoves::ROCKPOLISH],[4,PBMoves::CHARGE],[6,PBMoves::ROCKPOLISH],[10,PBMoves::ROLLOUT],
                        [12,PBMoves::SPARK],[16,PBMoves::ROCKTHROW],[18,PBMoves::SMACKDOWN],[22,PBMoves::THUNDERPUNCH],
                        [24,PBMoves::SELFDESTRUCT],[30,PBMoves::STEALTHROCK],[34,PBMoves::ROCKBLAST],
                        [40,PBMoves::DISCHARGE],[44,PBMoves::EXPLOSION],[50,PBMoves::DOUBLEEDGE],
                        [54,PBMoves::STONEEDGE]]
   end
   next movelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::MAGNETPULL
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::GALVANIZE
   end
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal
   next [0,0,PBItems::CELLBATTERY]  # Alola
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GRIMER,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "The crystals on Grimer's body are lumps of toxins. If one falls off, lethal poisons leak out."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 7                     # Alola
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 420                    # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DARK)    # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::POUND],[1,PBMoves::POISONGAS],[4,PBMoves::HARDEN],[7,PBMoves::BITE],
                        [12,PBMoves::DISABLE],[15,PBMoves::ACIDSPRAY],[18,PBMoves::POISONFANG],
                        [21,PBMoves::MINIMIZE],[26,PBMoves::FLING],[29,PBMoves::KNOCKOFF],[32,PBMoves::CRUNCH],
                        [37,PBMoves::SCREECH],[40,PBMoves::GUNKSHOT],[43,PBMoves::ACIDARMOR],
                        [46,PBMoves::BELCH],[48,PBMoves::MEMENTO]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Alola
     when 1 ; eggmovelist=[PBMoves::ASSURANCE,PBMoves::CLEARSMOG,PBMoves::CURSE,PBMoves::IMPRISON,PBMoves::MEANLOOK,PBMoves::POWERUPPUNCH,
                           PBMoves::PURSUIT,PBMoves::SCARYFACE,PBMoves::SHADOWSNEAK,PBMoves::SPITE,
                           PBMoves::SPITUP,PBMoves::STOCKPILE,PBMoves::SWALLOW]
   end
   next eggmovelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::POISONTOUCH
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::GLUTTONY
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::POWEROFALCHEMY
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

# Muk is handled with it's PULSE form

MultipleForms.register(PBSpecies::EXEGGUTOR,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "As it grew taller and taller, it outgrew its reliance on psychic powers, while within it awakened the power of the sleeping dragon."  # Alola
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 109                    # Alola
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 4156                   # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DRAGON)  # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[0,PBMoves::DRAGONHAMMER],[1,PBMoves::SEEDBOMB],[1,PBMoves::BARRAGE],
                        [1,PBMoves::HYPNOSIS],[1,PBMoves::CONFUSION],[17,PBMoves::PSYSHOCK],
                        [27,PBMoves::EGGBOMB],[37,PBMoves::WOODHAMMER],[47,PBMoves::LEAFSTORM]]
   end
   next movelist
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [95,105,85,45,125,75]   # Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::FRISK
   elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
     check = (pokemon.personalID)&1
     next PBAbilities::FRISK if check==0
     next PBAbilities::HARVEST if check==1
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::MAROWAK,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "The bones it possesses were once its mother's. Its mother's regrets have become like a vengeful spirit protecting this Pokémon."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   chancemaps=[669,880]
   # Map IDs for alolan form
   if $game_map && chancemaps.include?($game_map.map_id)
     randomnum = rand(2)
     if randomnum == 1
       next 1
     elsif randomnum == 0
       next 0
     end
   else
     next 0
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 340                    # Alola
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::FIRE)    # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::GHOST)   # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::GROWL],[1,PBMoves::TAILWHIP],[1,PBMoves::BONECLUB],[1,PBMoves::FLAMEWHEEL],
                        [3,PBMoves::TAILWHIP],[7,PBMoves::BONECLUB],[11,PBMoves::FLAMEWHEEL],[13,PBMoves::LEER],
                        [17,PBMoves::HEX],[21,PBMoves::BONEMERANG],[23,PBMoves::WILLOWISP],
                        [27,PBMoves::SHADOWBONE],[33,PBMoves::THRASH],[37,PBMoves::FLING],
                        [43,PBMoves::STOMPINGTANTRUM],[49,PBMoves::ENDEAVOR],[53,PBMoves::FLAREBLITZ],
                        [59,PBMoves::RETALIATE],[65,PBMoves::BONERUSH]]
   end
   next movelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::CURSEDBODY
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::LIGHTNINGROD
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::ROCKHEAD
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

## Galarian Forms (except Meowth, Mr. Mime & Darmanitan)

MultipleForms.register(PBSpecies::PONYTA,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "This Pokémon will look into your eyes and read the contents of your heart. If it finds evil there, it promptly hides away."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galarian form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 0.8                     # Galarian
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 24                     # Galarian
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::PSYCHIC)    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::PSYCHIC)  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[1,PBMoves::TACKLE],[1,PBMoves::GROWL],[5,PBMoves::TAILWHIP],
                        [10,PBMoves::CONFUSION],[15,PBMoves::FAIRYWIND],
                        [20,PBMoves::AGILITY],[25,PBMoves::PSYBEAM],[30,PBMoves::STOMP],
                        [35,PBMoves::HEALPULSE],[41,PBMoves::TAKEDOWN],[45,PBMoves::DAZZLINGGLEAM],
                        [50,PBMoves::PSYCHIC],[55,PBMoves::HEALINGWISH]]
   end
   next movelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::PASTELVEIL
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::ANTICIPATION
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::RAPIDASH,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Brave and prideful, this Pokémon dashes airily through the forest, its steps aided by the psychic power stored in the fur on its fetlocks."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galarian form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 1.7                     # Galarian
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 80                    # Galarian
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::PSYCHIC)    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::FAIRY)  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[0,PBMoves::PSYCHOCUT],[1,PBMoves::PSYCHOCUT],[1,PBMoves::MEGAHORN],
                        [1,PBMoves::TACKLE],[1,PBMoves::QUICKATTACK],[1,PBMoves::GROWL],
                        [1,PBMoves::TAILWHIP],[1,PBMoves::CONFUSION],[15,PBMoves::FAIRYWIND],
                        [20,PBMoves::AGILITY],[25,PBMoves::PSYBEAM],[30,PBMoves::STOMP],
                        [35,PBMoves::HEALPULSE],[43,PBMoves::TAKEDOWN],[49,PBMoves::DAZZLINGGLEAM],
                        [56,PBMoves::PSYCHIC],[63,PBMoves::HEALINGWISH]]
   end
   next movelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::PASTELVEIL
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::ANTICIPATION
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::FARFETCHD,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "The stalks of leeks are thicker and longer in the Galar region. Farfetch'd that adapted to these stalks took on a unique form."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galariann form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 0.8                     # Galarian
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 42                    # Galarian
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [52,95,55,55,58,62]   # Galar
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::FIGHTING)    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::FIGHTING)  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[1,PBMoves::PECK],[1,PBMoves::SANDATTACK],[5,PBMoves::LEER],
                        [10,PBMoves::FURYCUTTER],[15,PBMoves::ROCKSMASH],
                        [20,PBMoves::BRUTALSWING],[25,PBMoves::DETECT],[30,PBMoves::KNOCKOFF],
                        [35,PBMoves::DEFOG],[40,PBMoves::BRICKBREAK],[45,PBMoves::SWORDSDANCE],
                        [50,PBMoves::SLAM],[55,PBMoves::LEAFBLADE],[60,PBMoves::FINALGAMBIT],
                        [65,PBMoves::BRAVEBIRD]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Galar
     when 1 ; eggmovelist=[PBMoves::QUICKATTACK,PBMoves::FLAIL,PBMoves::CURSE,PBMoves::COVET,PBMoves::NIGHTSLASH,
                           PBMoves::SIMPLEBEAM,PBMoves::FEINT,PBMoves::SKYATTACK,PBMoves::COUNTER,PBMoves::QUICKGUARD,
                           PBMoves::DOUBLEEDGE]
   end
   next eggmovelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::STEADFAST
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::SCRAPPY
   end
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal
   next [PBItems::LEEK,0,0]   # Alola
},
"getEvo"=>proc{|pokemon|
   next if pokemon.form==0                  # Normal
   next [[31,3,865]]                        # Galarian    [BattleCrits,3,Sirfetch'd]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::WEEZING,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Long ago, during a time when droves of factories fouled the air with pollution, Weezing changed into this form for some reason."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galariann form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 3                     # Galarian
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 16                     # Galarian
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::POISON)    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::FAIRY)  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[0,PBMoves::DOUBLEHIT],[1,PBMoves::DOUBLEHIT],[1,PBMoves::STRANGESTEAM],
                        [1,PBMoves::DEFOG],[1,PBMoves::HEATWAVE],[1,PBMoves::SMOG],[1,PBMoves::SMOKESCREEN],
                        [1,PBMoves::HAZE],[1,PBMoves::POISONGAS],[1,PBMoves::TACKLE],[1,PBMoves::FAIRYWIND],
                        [1,PBMoves::AROMATICMIST],[12,PBMoves::CLEARSMOG],[16,PBMoves::ASSURANCE],
                        [20,PBMoves::SLUDGE],[24,PBMoves::AROMATHERAPY],[28,PBMoves::SELFDESTRUCT],
                        [32,PBMoves::SLUDGEBOMB],[38,PBMoves::TOXIC],[44,PBMoves::BELCH],[50,PBMoves::EXPLOSION],
                        [56,PBMoves::MEMENTO],[62,PBMoves::DESTINYBOND],[68,PBMoves::MISTYTERRAIN]]
   end
   next movelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::MISTYSURGE
   end
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal
   next [0,0,PBItems::ELEMENTALSEED]   # Galar
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::CORSOLA,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Sudden climate change wiped out this ancient kind of Corsola. This Pokémon absorbs others' life-force through its branches."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galariann form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 0.6                     # Galarian
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 0.5                    # Galarian
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [60,55,100,30,65,100]   # Galar
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::GHOST)    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::GHOST)  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[1,PBMoves::TACKLE],[1,PBMoves::HARDEN],[5,PBMoves::WATERGUN],[10,PBMoves::AQUARING],
                        [15,PBMoves::ENDURE],[20,PBMoves::ANCIENTPOWER],[25,PBMoves::BUBBLEBEAM],
                        [30,PBMoves::FLAIL],[35,PBMoves::LIFEDEW],[40,PBMoves::POWERGEM],
                        [45,PBMoves::EARTHPOWER],[50,PBMoves::RECOVER],[55,PBMoves::MIRRORCOAT]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Galar
     when 1 ; eggmovelist=[PBMoves::CONFUSERAY,PBMoves::NATUREPOWER,PBMoves::WATERPULSE,PBMoves::HEADSMASH,PBMoves::HAZE,
                           PBMoves::DESTINYBOND]
   end
   next eggmovelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::WEAKARMOR
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::CURSEDBODY
   end
},

"getEvo"=>proc{|pokemon|
   next if pokemon.form==0                  # Normal
   next [[4,38,864]]                        # Galarian    [Level,38,Cursola]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::ZIGZAGOON,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Thought to be the oldest form of Zigzagoon, it moves in zigzags and wreaks havoc upon its surroundings."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galariann form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DARK)    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::NORMAL)  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[1,PBMoves::TACKLE],[1,PBMoves::LEER],[3,PBMoves::SANDATTACK],[6,PBMoves::LICK],
                        [9,PBMoves::SNARL],[12,PBMoves::HEADBUTT],[15,PBMoves::BABYDOLLEYES],
                        [18,PBMoves::PINMISSILE],[21,PBMoves::REST],[24,PBMoves::TAKEDOWN],
                        [27,PBMoves::SCARYFACE],[30,PBMoves::COUNTER],[33,PBMoves::TAUNT],
                        [36,PBMoves::DOUBLEEDGE]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Galar
     when 1 ; eggmovelist=[PBMoves::PARTINGSHOT,PBMoves::QUICKGUARD,PBMoves::KNOCKOFF]
   end
   next eggmovelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::LINOONE,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "This very aggressive Pokémon will recklessly challenge opponents stronger than itself."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galariann form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::DARK)    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::NORMAL)  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[0,PBMoves::NIGHTSLASH],[1,PBMoves::NIGHTSLASH],[1,PBMoves::SWITCHEROO],
                        [1,PBMoves::PINMISSILE],[1,PBMoves::BABYDOLLEYES],[1,PBMoves::TACKLE],
                        [1,PBMoves::LEER],[1,PBMoves::SANDATTACK],[1,PBMoves::LICK],
                        [9,PBMoves::SNARL],[12,PBMoves::HEADBUTT],[15,PBMoves::HONECLAWS],
                        [18,PBMoves::FURYSWIPES],[23,PBMoves::REST],[28,PBMoves::TAKEDOWN],
                        [33,PBMoves::SCARYFACE],[38,PBMoves::COUNTER],[43,PBMoves::TAUNT],
                        [48,PBMoves::DOUBLEEDGE]]
   end
   next movelist
},
"getEvo"=>proc{|pokemon|
   next if pokemon.form==0                  # Normal
   next [[30,35,862]]                        # Galarian    [LevelNight,35,Obstagoon]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::DARUMAKA,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "The colder they get, the more energetic they are. They freeze their breath to make snowballs, using them as ammo for playful snowball fights."  if pokemon.form==2   # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galariann form
   if $game_map && maps.include?($game_map.map_id)
     next 2
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 0.7 if pokemon.form==2                     # Galarian
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 40  if pokemon.form==2                    # Galarian
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ICE) if pokemon.form==2    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::ICE) if pokemon.form==2  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 2 ; movelist=[[1,PBMoves::POWDERSNOW],[1,PBMoves::TACKLE],[4,PBMoves::TAUNT],[8,PBMoves::BITE],
                        [12,PBMoves::AVALANCHE],[16,PBMoves::WORKUP],[20,PBMoves::ICEFANG],[24,PBMoves::HEADBUTT],
                        [28,PBMoves::ICEPUNCH],[32,PBMoves::UPROAR],[36,PBMoves::BELLYDRUM],
                        [40,PBMoves::BLIZZARD],[44,PBMoves::THRASH],[48,PBMoves::SUPERPOWER]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Galar
     when 2 ; eggmovelist=[PBMoves::FOCUSPUNCH,PBMoves::HAMMERARM,PBMoves::TAKEDOWN,PBMoves::FLAMEWHEEL,PBMoves::YAWN,
                           PBMoves::FREEZEDRY,PBMoves::INCINERATE,PBMoves::POWERUPPUNCH]
   end
   next eggmovelist
},
"getEvo"=>proc{|pokemon|
   next if pokemon.form==0                  # Normal
   next [[7,652,555]] if pokemon.form==2                       # Galarian    [Item,Ice Stone,Darmanitan]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::YAMASK,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "It's said that this Pokémon was formed when an ancient clay tablet was drawn to a vengeful spirit."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galariann form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [38,55,85,30,30,65]   # Galar
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::GROUND)    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::GHOST)  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[1,PBMoves::ASTONISH],[1,PBMoves::PROTECT],[4,PBMoves::HAZE],[8,PBMoves::NIGHTSHADE],
                        [10,PBMoves::DISABLE],[14,PBMoves::BRUTALSWING],[16,PBMoves::CRAFTYSHIELD],
                        [20,PBMoves::HEX],[24,PBMoves::MEANLOOK],[28,PBMoves::SLAM],[32,PBMoves::CURSE],
                        [36,PBMoves::SHADOWBALL],[40,PBMoves::EARTHQUAKE],[44,PBMoves::POWERSPLIT],
                        [48,PBMoves::GUARDSPLIT],[52,PBMoves::DESTINYBOND]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Galar
     when 1 ; eggmovelist=[PBMoves::MEMENTO]
   end
   next eggmovelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   next PBAbilities::WANDERINGSPIRIT # Galar
},
"getEvo"=>proc{|pokemon|
   next if pokemon.form==0                  # Normal
   next [[32,49,867]]                        # Galarian    [TakeDamage,49,Runerigas]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::STUNFISK,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Its conspicuous lips lure prey in as it lies in wait in the mud. When prey gets close, Stunfisk clamps its jagged steel fins down on them."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galariann form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 20.5                    # Galarian
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [109,81,99,32,66,84]   # Galar
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::GROUND)    # Galarian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::STEEL)  # Galarian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 1 ; movelist=[[1,PBMoves::MUDSLAP],[1,PBMoves::TACKLE],[1,PBMoves::WATERGUN],[1,PBMoves::METALCLAW],
                        [5,PBMoves::ENDURE],[10,PBMoves::MUDSHOT],[15,PBMoves::REVENGE],[20,PBMoves::METALSOUND],
                        [25,PBMoves::SUCKERPUNCH],[30,PBMoves::IRONDEFENSE],[35,PBMoves::BOUNCE],
                        [40,PBMoves::MUDDYWATER],[45,PBMoves::SNAPTRAP],[50,PBMoves::FLAIL],[55,PBMoves::FISSURE]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Galar
     when 1 ; eggmovelist=[PBMoves::YAWN,PBMoves::ASTONISH,PBMoves::CURSE,PBMoves::SPITE,
                           PBMoves::PAINSPLIT,PBMoves::REFLECTTYPE,PBMoves::BIND,PBMoves::COUNTER]
   end
   next eggmovelist
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   next PBAbilities::MIMICRY
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::MISDREAVUS,{
   "dexEntry"=>proc{|pokemon|
     case pokemon.form
     when 0  # Normal
       next
     when 1  # Aevian
       next "It knows the swamp it lives in like no other and blends in perfectly. It's more timid than its regular counterpart, and doesn't like showing itself to bypassers."  # Aevian
     end
   },
   "getBaseStats"=>proc{|pokemon|
     case pokemon.form
     when 0  # Normal
       next
     when 1  # Aevian
       next [60,85,60,85,85,60]
     end
   },
   "type1"=>proc{|pokemon|
     case pokemon.form
     when 0  # Normal
       next
     when 1  # Aevian
       next getID(PBTypes,:GRASS)
     end
   },
   "type2"=>proc{|pokemon|
     case pokemon.form
     when 0  # Normal
       next
     when 1  # Aevian
       next getID(PBTypes,:GHOST)
     end
   },
   "getMoveList"=>proc{|pokemon|
     next if pokemon.form==0      # Normal
     movelist=[]
     case pokemon.form            # Aevian
     when 1 ; movelist=[[1,PBMoves::GROWL],[1,PBMoves::VINEWHIP],[5,PBMoves::POISONPOWDER],[10,PBMoves::ASTONISH],
         [14,PBMoves::CONFUSERAY],[19,PBMoves::SNAPTRAP],[23,PBMoves::HEX],[28,PBMoves::GIGADRAIN],
         [32,PBMoves::INGRAIN],[37,PBMoves::GRUDGE],[41,PBMoves::SHADOWBALL],
         [46,PBMoves::PERISHSONG],[50,PBMoves::POWERWHIP],[55,PBMoves::POWERGEM]]
     end
     next movelist
   },
   "getEggMoves"=>proc{|pokemon|
     next if pokemon.form==0      # Normal
     eggmovelist=[]
     case pokemon.form            # Aevian
     when 1 ; eggmovelist=[PBMoves::CURSE,PBMoves::DESTINYBOND,PBMoves::GROWTH,PBMoves::MEFIRST,PBMoves::MEMENTO,
         PBMoves::NASTYPLOT,PBMoves::CLEARSMOG,PBMoves::SCREECH,PBMoves::SHADOWSNEAK,PBMoves::LIFEDEW,
         PBMoves::TOXIC,PBMoves::SUCKERPUNCH,PBMoves::WONDERROOM]
     end
     for i in eggmovelist
       i=getID(PBMoves,i)
     end
     next eggmovelist
   },
   "getMoveCompatibility"=>proc{|pokemon|
     next if pokemon.form==0
     movelist=[]
     case pokemon.form
     when 1; movelist=[# TMs
         PBMoves::WORKUP,PBMoves::TOXIC,PBMoves::VENOSHOCK,PBMoves::HIDDENPOWER,PBMoves::SUNNYDAY,PBMoves::TAUNT,
         PBMoves::PROTECT,PBMoves::RAINDANCE,PBMoves::SECRETPOWER,PBMoves::FRUSTRATION,PBMoves::SOLARBEAM,
         PBMoves::RETURN,PBMoves::SHADOWBALL,PBMoves::DOUBLETEAM,PBMoves::AERIALACE,PBMoves::FACADE,PBMoves::REST,
         PBMoves::ATTRACT,PBMoves::ROUND,PBMoves::ECHOEDVOICE,PBMoves::ENERGYBALL,PBMoves::QUASH,PBMoves::WILLOWISP,
         PBMoves::EMBARGO,PBMoves::SWORDSDANCE,PBMoves::PSYCHUP,PBMoves::INFESTATION,PBMoves::GRASSKNOT,
         PBMoves::SWAGGER,PBMoves::SLEEPTALK,PBMoves::SUBSTITUTE,PBMoves::NATUREPOWER,PBMoves::CONFIDE,
         PBMoves::LEECHLIFE,PBMoves::PINMISSILE,PBMoves::MAGICALLEAF,PBMoves::SCREECH,PBMoves::SCARYFACE,
         PBMoves::BULLETSEED,PBMoves::CROSSPOISON,PBMoves::HEX,PBMoves::PHANTOMFORCE,PBMoves::DRAININGKISS,
         PBMoves::SUCKERPUNCH,PBMoves::CUT,
         # Move Tutors
         PBMoves::SNORE,PBMoves::HEALBELL,PBMoves::UPROAR,PBMoves::BIND,PBMoves::WORRYSEED,PBMoves::SNATCH,PBMoves::SPITE,
         PBMoves::GIGADRAIN,PBMoves::SYNTHESIS,PBMoves::ALLYSWITCH,PBMoves::WATERPULSE,PBMoves::PAINSPLIT,
         PBMoves::SEEDBOMB,PBMoves::LASERFOCUS,PBMoves::TRICK,PBMoves::MAGICROOM,PBMoves::WONDERROOM,
         PBMoves::GASTROACID,PBMoves::THROATCHOP,PBMoves::SKILLSWAP,PBMoves::HYPERVOICE,PBMoves::SPIKES,
         PBMoves::ENDURE,PBMoves::BATONPASS,PBMoves::FUTURESIGHT,PBMoves::LEAFBLADE,PBMoves::TOXICSPIKES,
         PBMoves::POWERGEM,PBMoves::NASTYPLOT,PBMoves::LEAFSTORM,PBMoves::POWERWHIP,PBMoves::VENOMDRENCH]
     end
     next movelist
   },
   "ability"=>proc{|pokemon|
     case pokemon.form
     when 0 # Normal
       next
     when 1 # Aevian
       if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
         next getID(PBAbilities,:MAGICBOUNCE)
       elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
         next getID(PBAbilities,:POISONPOINT)
       elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
         next getID(PBAbilities,:TANGLINGHAIR)
       end
     end
   },
   "getEvo"=>proc{|pokemon|
     next if pokemon.form==0                  # Normal
     next [[7,15,429]]                        # Aevian    [Item,Leaf Stone,Mismagius]
   },
   "onSetForm"=>proc{|pokemon,form|
     pbSeenForm(pokemon)
   },
   "getFormOnCreation"=>proc{|pokemon|
     maps=[]   # Map IDs for Aevian form
     if $game_map && maps.include?($game_map.map_id)
       next 1
     else
       next 0
     end
   }
 })

MultipleForms.register(PBSpecies::MISMAGIUS,{
   "dexEntry"=>proc{|pokemon|
     case pokemon.form
     when 0  # Normal
       next
     when 1  # Aevian
       next "A gentle but misleadingly strong Pokémon, it helps those who got lost in the wetlands find their way out... At the cost of a little of their life force."  # Aevian
     end
   },
   "getBaseStats"=>proc{|pokemon|
     case pokemon.form
     when 0  # Normal
       next
     when 1  # Aevian
       next [60,105,60,105,105,60]
     end
   },
   "type1"=>proc{|pokemon|
     case pokemon.form
     when 0  # Normal
       next
     when 1  # Aevian
       next getID(PBTypes,:GRASS)
     end
   },
   "type2"=>proc{|pokemon|
     case pokemon.form
     when 0  # Normal
       next
     when 1  # Aevian
       next getID(PBTypes,:GHOST)
     end
   },
   "getMoveList"=>proc{|pokemon|
     next if pokemon.form==0      # Normal
     movelist=[]
     case pokemon.form            # Alola
     when 1 ; movelist=[[1,PBMoves::POISONJAB],[1,PBMoves::POWERGEM],[1,PBMoves::PHANTOMFORCE],[1,PBMoves::LUCKYCHANT],[1,PBMoves::MAGICALLEAF],[1,PBMoves::GROWL],[1,PBMoves::VINEWHIP],[1,PBMoves::POISONPOWDER],[1,PBMoves::ASTONISH],[0,PBMoves::SHADOWCLAW]]
     end
     next movelist
   },
   "getMoveCompatibility"=>proc{|pokemon|
     next if pokemon.form==0
     movelist=[]
     case pokemon.form
     when 1; movelist=[# TMs
         PBMoves::WORKUP,PBMoves::TOXIC,PBMoves::VENOSHOCK,PBMoves::HIDDENPOWER,
         PBMoves::SUNNYDAY,PBMoves::TAUNT,PBMoves::HYPERBEAM,PBMoves::PROTECT,
         PBMoves::RAINDANCE,PBMoves::SECRETPOWER,PBMoves::FRUSTRATION,PBMoves::SOLARBEAM,
         PBMoves::SMACKDOWN,PBMoves::RETURN,PBMoves::SHADOWBALL,PBMoves::DOUBLETEAM,
         PBMoves::SLUDGEWAVE,PBMoves::ROCKTOMB,PBMoves::AERIALACE,PBMoves::FACADE,
         PBMoves::REST,PBMoves::ATTRACT,PBMoves::ROUND,PBMoves::ECHOEDVOICE,
         PBMoves::ENERGYBALL,PBMoves::QUASH,PBMoves::WILLOWISP,PBMoves::ACROBATICS,
         PBMoves::EMBARGO,PBMoves::SHADOWCLAW,PBMoves::GIGAIMPACT,PBMoves::SWORDSDANCE,
         PBMoves::PSYCHUP,PBMoves::XSCISSOR,PBMoves::INFESTATION,PBMoves::POISONJAB,
         PBMoves::GRASSKNOT,PBMoves::SWAGGER,PBMoves::SLEEPTALK,PBMoves::SUBSTITUTE,
         PBMoves::NATUREPOWER,PBMoves::CONFIDE,PBMoves::SLASHANDBURN,PBMoves::LEECHLIFE,
         PBMoves::PINMISSILE,PBMoves::MAGICALLEAF,PBMoves::SOLARBLADE,PBMoves::SCREECH,
         PBMoves::SCARYFACE,PBMoves::BULLETSEED,PBMoves::CROSSPOISON,PBMoves::HEX,
         PBMoves::PHANTOMFORCE,PBMoves::DRAININGKISS,PBMoves::GRASSYTERRAIN,
         PBMoves::HONECLAWS,PBMoves::SUCKERPUNCH,PBMoves::CUT,PBMoves::STRENGTH,
         # Move Tutors
         PBMoves::SNORE,PBMoves::HEALBELL,PBMoves::UPROAR,PBMoves::BIND,PBMoves::WORRYSEED,
         PBMoves::SNATCH,PBMoves::SPITE,PBMoves::GIGADRAIN,PBMoves::SYNTHESIS,
         PBMoves::ALLYSWITCH,PBMoves::WATERPULSE,PBMoves::PAINSPLIT,PBMoves::SEEDBOMB,
         PBMoves::LASERFOCUS,PBMoves::TRICK,PBMoves::MAGICROOM,PBMoves::WONDERROOM,
         PBMoves::GASTROACID,PBMoves::THROATCHOP,PBMoves::SKILLSWAP,PBMoves::GUNKSHOT,
         PBMoves::HYPERVOICE,PBMoves::KNOCKOFF,PBMoves::SPIKES,PBMoves::ENDURE,
         PBMoves::BATONPASS,PBMoves::FUTURESIGHT,PBMoves::MUDDYWATER,PBMoves::LEAFBLADE,
         PBMoves::TOXICSPIKES,PBMoves::POWERGEM,PBMoves::NASTYPLOT,PBMoves::LEAFSTORM,
         PBMoves::POWERWHIP,PBMoves::VENOMDRENCH
      ]
     end
     next movelist
   },
   "ability"=>proc{|pokemon|
   case pokemon.form
   when 0 # Normal
     next
   when 1 # Aevian
     if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
       next getID(PBAbilities,:MAGICBOUNCE)
     elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
       next getID(PBAbilities,:POISONPOINT)
     elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
       next getID(PBAbilities,:TANGLINGHAIR)
     end
   end
   },
   "onSetForm"=>proc{|pokemon,form|
     pbSeenForm(pokemon)
   }
 })

## End of Regional Variants ##


MultipleForms.register(PBSpecies::KYOGRE,{
"getMegaName"=>proc{|pokemon|
   next _INTL("Primal Kyogre") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   next [100,150,90,90,180,160] # Primal
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0
   next PBAbilities::PRIMORDIALSEA # Primal
},
"height"=>proc{|pokemon|
   next 98 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 4300 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::GROUDON,{
"getMegaName"=>proc{|pokemon|
   next _INTL("Primal Groudon") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   next [100,180,160,90,150,90] # Primal
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0
   next (PBTypes::FIRE)  # Primal
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0
   next PBAbilities::DESOLATELAND # Primal
},
"height"=>proc{|pokemon|
   next 50 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 9997 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(PBSpecies::ZACIAN,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Able to cut down anything with a single strike, it became known as the Fairy King's Sword, and it inspired awe in friend and foe alike." # Crowned Sword
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [92,170,115,148,80,115]   # Crowned Sword
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::FAIRY)    # Crowned Sword
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next (PBTypes::STEEL)  # Crowned Sword
},
"weight"=>proc{|pokemon|
   next 355.0 if pokemon.form==1
   next
},
"getForm"=>proc{|pokemon|
   next 1  if (pokemon.item == PBItems::RUSTEDSWORD)
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::ZAMAZENTA,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next "Its ability to deflect any attack led to it being known as the Fighting Master's Shield. It was feared and respected by all." # Crowned Shield
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [92,130,145,128,80,145]   # Crowned Shield
},
"type1"=>proc{|pokemon|
   next if pokemon.form==0       # Normal
   next (PBTypes::FIGHTING) # Crowned Shield
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0    # Normal
   next (PBTypes::STEEL) # Crowned Shield
},
"weight"=>proc{|pokemon|
   next 785.0 if pokemon.form==1
   next
},
"getForm"=>proc{|pokemon|
   next 1  if (pokemon.item == PBItems::RUSTEDSHIELD)
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})



##### Mega Evolution forms #####################################################


MultipleForms.register(PBSpecies::VENUSAUR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::VENUSAURITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Venusaur") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,100,123,80,122,120] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::THICKFAT if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 24 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1555 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::CHARIZARD,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::CHARIZARDITEX)
   next 2 if (pokemon.item == PBItems::CHARIZARDITEY)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Charizard X") if pokemon.form==1
   next _INTL("Mega Charizard Y") if pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [78,130,111,100,130,85] if pokemon.form==1
   next [78,104,78,100,159,115] if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::DRAGON) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::TOUGHCLAWS if pokemon.form==1
   next PBAbilities::DROUGHT if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 1105 if pokemon.form==1
   next 1005 if pokemon.form==2
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::BLASTOISE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::BLASTOISINITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Blastoise") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [79,103,120,78,135,115] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::MEGALAUNCHER if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1011 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::ALAKAZAM,{

"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::ALAKAZITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Alakazam") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [55,50,65,150,175,105] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::TRACE if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 480 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GENGAR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::GENGARITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Gengar") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [60,65,80,130,170,95] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SHADOWTAG if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 405 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::KANGASKHAN,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::KANGASKHANITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Kangaskhan") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [105,125,100,100,60,100] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|

   next PBAbilities::PARENTALBOND if pokemon.form==1

   next
},
"weight"=>proc{|pokemon|
   next 1000 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::PINSIR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PINSIRITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Pinsir") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,155,120,105,65,90] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::FLYING) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::AERILATE if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 590 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GYARADOS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::GYARADOSITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Gyarados") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,155,109,81,70,130] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::DARK) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::MOLDBREAKER if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3050 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::AERODACTYL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::AERODACTYLITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Aerodactyl") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,135,85,150,70,95] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::TOUGHCLAWS if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 790 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::MEWTWO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::MEWTWONITEX)
   next 2 if (pokemon.item == PBItems::MEWTWONITEY)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Mewtwo X") if pokemon.form==1
   next _INTL("Mega Mewtwo Y") if pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [106,190,100,130,154,100] if pokemon.form==1
   next [106,150,70,140,194,120] if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::FIGHTING) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::STEADFAST if pokemon.form==1
   next PBAbilities::INSOMNIA if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 1270 if pokemon.form==1
   next 330 if pokemon.form==2
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::AMPHAROS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::AMPHAROSITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Ampharos") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [90,95,105,45,165,110] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::DRAGON) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::MOLDBREAKER if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 615 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SCIZOR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::SCIZORITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Scizor") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,150,140,75,65,100] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::TECHNICIAN if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1250 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::HERACROSS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::HERACRONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Heracross") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,185,115,75,40,105] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SKILLLINK if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 625 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::HOUNDOOM,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::HOUNDOOMINITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Houndoom") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,90,90,115,140,90] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SOLARPOWER if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 495 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::TYRANITAR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::TYRANITARITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Tyranitar") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,164,150,71,95,120] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SANDSTREAM if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 2550 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::BLAZIKEN,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::BLAZIKENITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Blaziken") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,160,80,100,130,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SPEEDBOOST if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 520 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GARDEVOIR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::GARDEVOIRITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   if pokemon.form==2
     next nil
    else
     next 0
    end
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Rift Gardevoir") if pokemon.form==2
   next _INTL("Mega Gardevoir") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,130,90,110,175,145] if pokemon.form==2
   next [68,85,65,100,165,135] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::DUSKILATE if pokemon.form==2
   next PBAbilities::PIXILATE if pokemon.form==1
   next
},
"type1"=>proc{|pokemon|
   next (PBTypes::DARK) if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 484 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::MAWILE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::MAWILITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Mawile") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [50,105,125,50,55,95] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::HUGEPOWER if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 235 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::AGGRON,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::AGGRONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Aggron") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,140,230,50,60,80] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::STEEL) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::FILTER if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3950 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::MEDICHAM,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::MEDICHAMITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Medicham") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [60,100,85,100,80,85] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::PUREPOWER if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 315 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::MANECTRIC,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::MANECTITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Manectric") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,75,80,135,135,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::INTIMIDATE if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 440 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::BANETTE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::BANETTITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Banette") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [64,165,75,75,93,83] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::PRANKSTER if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 130 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::ABSOL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::ABSOLITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Absol") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,150,60,115,115,60] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::MAGICBOUNCE if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 490 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GARCHOMP,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::GARCHOMPITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Garchomp") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [108,170,115,92,120,95] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SANDFORCE if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 950 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::LUCARIO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::LUCARIONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Lucario") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,145,88,112,140,70] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::ADAPTABILITY if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 575 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::ABOMASNOW,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::ABOMASITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Abomasnow") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [90,132,105,30,132,105] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SNOWWARNING if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1850 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::BEEDRILL,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::BEEDRILLITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Beedrill") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,150,40,145,15,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::ADAPTABILITY if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 14 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 405 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::PIDGEOT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PIDGEOTITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Pidgeot") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [83,80,80,121,135,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::NOGUARD if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 22 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 505 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SLOWBRO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::SLOWBRONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Slowbro") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,75,180,30,130,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SHELLARMOR if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 20 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1200 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::STEELIX,{
"getMegaForm"=>proc{|pokemon|
   next 1 if pokemon.item == PBItems::STEELIXITE && pokemon.form==0
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Steelix") if pokemon.form==1 || pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,125,230,30,55,95] if pokemon.form==1 || pokemon.form==2
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SANDFORCE if pokemon.form==1 || pokemon.form==2
   next
},
"height"=>proc{|pokemon|
   next 105 if pokemon.form==1 || pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 7400 if pokemon.form==1 || pokemon.form==2
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SCEPTILE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::SCEPTILITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Sceptile") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,110,75,145,145,85] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::DRAGON) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::LIGHTNINGROD if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 19 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 552 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SWAMPERT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::SWAMPERTITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Swampert") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,150,110,70,85,110] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SWIFTSWIM if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 19 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1020 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SABLEYE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::SABLENITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Sableye") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [50,85,125,20,85,115] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::MAGICBOUNCE if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 5 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1610 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SHARPEDO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::SHARPEDONITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Sharpedo") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,140,70,105,110,65] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::STRONGJAW if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1303 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::CAMERUPT,{ # Also PULSE
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::CAMERUPTITE)
   next 2 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Camerupt") if pokemon.form==1
   next _INTL("PULSE Camerupt") if pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,120,100,20,145,105] if pokemon.form==1
   next [1,10,10,10,170,10] if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::GHOST) if pokemon.form==2
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SHEERFORCE if pokemon.form==1
   next PBAbilities::STURDY if pokemon.form==2
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3205 if pokemon.form==1
   next 2707 if pokemon.form==2
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form==2
   next
}
})

MultipleForms.register(PBSpecies::ALTARIA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::ALTARIANITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Altaria") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,110,110,80,110,105] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::FAIRY) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::PIXILATE if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 15 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 2060 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GLALIE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::GLALITITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Glalie") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,120,80,100,120,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::REFRIGERATE if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 21 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3502 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::SALAMENCE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::SALAMENCITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Salamence") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,145,130,120,120,90] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::AERILATE if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 18 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1125 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::METAGROSS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::METAGROSSITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Metagross") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,145,150,110,105,110] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::TOUGHCLAWS if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 25 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 9429 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::LATIAS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::LATIASITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Latias") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,100,120,110,140,150] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::LEVITATE if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 18 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 520 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::LATIOS,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::LATIOSITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Latios") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,130,100,110,160,120] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::LEVITATE if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 23 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 700 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::RAYQUAZA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(:DRAGONASCENT)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Rayquaza") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [105,180,100,115,180,100] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::DELTASTREAM if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 108 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 3920 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::LOPUNNY,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::LOPUNNITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Lopunny") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [65,136,94,135,54,96] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::FIGHTING) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SCRAPPY if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 13 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 283 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::GALLADE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::GALLADITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Gallade") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [68,165,95,110,65,115] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::INNERFOCUS if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 16 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 564 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::AUDINO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::AUDINITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Audino") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [103,60,126,50,80,126] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::FAIRY) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::HEALER if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 15 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 320 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::DIANCIE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::DIANCITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Diancie") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [50,160,110,110,160,110] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::MAGICBOUNCE if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 11 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 278 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

####### PULSE Forms #########################################################


MultipleForms.register(:GARBODOR,{
   "getMegaForm"=>proc{|pokemon|
     next 1 if (pokemon.item == PBItems::PULSEHOLD)
     next
   },
   "getUnmegaForm"=>proc{|pokemon|
     next 0
   },
   "getMegaName"=>proc{|pokemon|
     next _INTL("Mega Garbodor") if pokemon.form==1
     next
   },
   "getBaseStats"=>proc{|pokemon|
     next [80,135,107,85,60,107] if pokemon.form==1
     next
   },
   "ability"=>proc{|pokemon|
     next getID(PBAbilities,:NEUTRALIZINGGAS) if pokemon.form==1
     next
   },
   "height"=>proc{|pokemon|
     next 6033 if pokemon.form==1
     next
   },
   "weight"=>proc{|pokemon|
     next 2366 if pokemon.form==1
     next
   },
   "onSetForm"=>proc{|pokemon,form|
     pbSeenForm(pokemon)
   }
 })


MultipleForms.register(PBSpecies::TANGROWTH,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Tangrowth") if pokemon.form>=1
   next
},
"weight"=>proc{|pokemon|
   next 2675 if pokemon.form>=1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,70,200,10,70,160] if pokemon.form>=1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::POISON) if pokemon.form==1
   next (PBTypes::GROUND) if pokemon.form==2
   next (PBTypes::ROCK) if pokemon.form==3
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::FILTER if pokemon.form==1
   next PBAbilities::ARENATRAP if pokemon.form==2
   next PBAbilities::STAMINA if pokemon.form==3
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if [1,2,3].include?(pokemon.form)
   next
}
})


MultipleForms.register(PBSpecies::MUK,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form!=1      # Normal
   next "While it's unexpectedly quiet and friendly, if it's not fed any trash for a while, it will smash its Trainer's furnishings and eat up the fragments."  # Alola
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 879]
   # Map IDs for alolan form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"height"=>proc{|pokemon|
   next if pokemon.form!=1      # Normal/PULSE
   next 7                     # Alola
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next 1023 if pokemon.form==2 # PULSE
   next 420                    # Alola
},
"type2"=>proc{|pokemon|
   next if pokemon.form!=1      # Normal/PULSE
   next (PBTypes::DARK)    # Alola
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form!=1      # Normal/PULSE
   movelist=[]
   case pokemon.form            # Alola
     when 1 ; movelist=[[0,PBMoves::VENOMDRENCH],[1,PBMoves::POUND],[1,PBMoves::POISONGAS],[1,PBMoves::HARDEN],
                        [1,PBMoves::BITE],[4,PBMoves::HARDEN],[7,PBMoves::BITE],[12,PBMoves::DISABLE],[15,PBMoves::ACIDSPRAY],
                        [18,PBMoves::POISONFANG],[21,PBMoves::MINIMIZE],[26,PBMoves::FLING],[29,PBMoves::KNOCKOFF],
                        [32,PBMoves::CRUNCH],[37,PBMoves::SCREECH],[40,PBMoves::GUNKSHOT],[46,PBMoves::ACIDARMOR],
                        [52,PBMoves::BELCH],[57,PBMoves::MEMENTO]]
   end
   next movelist
},
"getMegaForm"=>proc{|pokemon|
   next 2 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
  if pokemon.form == 2
   next 0
 else
   next nil
 end
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Muk") if pokemon.form==2     # PULSE
   next                                           # Normal/Alola
},
"getBaseStats"=>proc{|pokemon|
   next [105,105,70,40,97,250] if pokemon.form==2 # PULSE
   next                                           # Normal/Alola
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0 # Normal
   next PBAbilities::PROTEAN if pokemon.form==2 # PULSE
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
     next PBAbilities::POISONTOUCH
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::GLUTTONY
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::POWEROFALCHEMY
   end
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form==2
   next
}
})


MultipleForms.register(PBSpecies::ABRA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Abra") if pokemon.form!=0
   next
},
"weight"=>proc{|pokemon|
   next 862 if pokemon.form!=0
   next
},
"getBaseStats"=>proc{|pokemon|
   next [25,20,115,140,195,155] if pokemon.form!=0
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::STEEL) if pokemon.form!=0
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::MAGICGUARD if pokemon.form!=0
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::AVALUGG,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Avalugg") if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 8780 if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [105,160,255,10,97,255] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SOLIDROCK if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::SWALOT,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Swalot") if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::WATER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 4621 if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [100,73,210,40,110,210] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::WATERABSORB if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::MAGNEZONE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Magnezone") if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1673 if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,70,160,70,230,140] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::LEVITATE if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::HYPNO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Hypno") if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 208 if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [120,65,190,80,125,225] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::DARK) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::NOGUARD if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::CLAWITZER,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Clawitzer") if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 573 if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [252,1,60,252,120,70] if pokemon.form==1
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::DRAGON) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::CONTRARY if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form==1
   next
}
})

#PULSE and Galarian form
MultipleForms.register(PBSpecies::MRMIME,{
"dexEntry"=>proc{|pokemon|
   next if pokemon.form!=2      # Normal, Pulse
   next "It can radiate chilliness from the bottoms of its feet. It'll spend the whole day tap-dancing on a frozen floor."     # Galarian
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]
   # Map IDs for Galarian form
   if $game_map && maps.include?($game_map.map_id)
     next 2
   else
     next 0
   end
},
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::PULSEHOLD)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("PULSE Mr. Mime") if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 1.4 if pokemon.form==2 # Galarian
   next
},
"weight"=>proc{|pokemon|
   next 483 if pokemon.form==1 # PULSE
   next 56.8 if pokemon.form==2 # Galarian
   next
},
"evYield"=>proc{|pokemon|
   next if pokemon.form!=2      # Normal/PULSE
   next [0,0,0,2,0,0]           # Galarian
},
"getBaseStats"=>proc{|pokemon|
   next [252,1,252,252,1,252] if pokemon.form==1 # PULSE
   next [50,65,65,100,90,90] if pokemon.form==2 # Galarian
   next
},
"type1"=>proc{|pokemon|
   next (PBTypes::DARK) if pokemon.form==1 # PULSE
   next (PBTypes::ICE) if pokemon.form==2 # Galar
   next
},
"type2"=>proc{|pokemon|
   next (PBTypes::GHOST) if pokemon.form==1 # PULSE
   next (PBTypes::PSYCHIC) if pokemon.form==2 # Galar
   next
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Galarian
     when 2 ; movelist=[[1,PBMoves::COPYCAT],[1,PBMoves::ENCORE],[1,PBMoves::ROLEPLAY],[1,PBMoves::PROTECT],
                        [1,PBMoves::RECYCLE],[1,PBMoves::MIMIC],[1,PBMoves::LIGHTSCREEN],[1,PBMoves::REFLECT],
                        [1,PBMoves::SAFEGUAR],[1,PBMoves::DAZZLINGGLEAM],[1,PBMoves::MISTYTERRAIN],
                        [1,PBMoves::POUND],[1,PBMoves::RAPIDSPIN],[1,PBMoves::BATONPASS],[1,PBMoves::ICESHARD],
                        [12,PBMoves::CONFUSION],[16,PBMoves::ALLYSWITCH],[20,PBMoves::ICYWIND],
                        [24,PBMoves::DOUBLEKICK],[28,PBMoves::PSYBEAM],[32,PBMoves::HYPNOSIS],
                        [36,PBMoves::MIRRORCOAT],[40,PBMoves::SUCKERPUNCH],[44,PBMoves::FREEZEDRY],
                        [48,PBMoves::PSYCHIC],[52,PBMoves::TEETERDANCE]]
   end
   next movelist
},
"getEggMoves"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   eggmovelist=[]
   case pokemon.form            # Galar
     when 2 ; eggmovelist=[PBMoves::FAKEOUT,PBMoves::CONFUSERAY,PBMoves::POWERSPLIT,PBMoves::TICKLE]
   end
   next eggmovelist
},
"ability"=>proc{|pokemon|
   next PBAbilities::WONDERGUARD if pokemon.form==1
   next if pokemon.form==0
   if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
     next PBAbilities::VITALSPIRIT
   elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
     next PBAbilities::SCREENCLEANER
   elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
     next PBAbilities::ICEBODY
   end
},
"getEvo"=>proc{|pokemon|
   next if pokemon.form!=2                  # Normal, PULSE
   next [[4,42,866]]                        # Galarian    [Level,42,Mr. Rime]
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},
"getPulseForm"=>proc{|pokemon|
   next true if pokemon.form==1
   next
}
})

##### Misc forms ###############################################################


MultipleForms.register(PBSpecies::KECLEON,{
"getMegaName"=>proc{|pokemon|
   next _INTL("Purple Kecleon") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   next [130,120,90,95,60,130] # Purple
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::BRELOOM,{
"getMegaName"=>proc{|pokemon|
   next _INTL("Breloom Bot") if pokemon.form==1
   next
},
"type1"=>proc{|pokemon|
   next (PBTypes::STEEL) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 5328 if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   next [210,160,140,100,60,100] # Bot
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

##### Deso Megas ####

MultipleForms.register(PBSpecies::MIGHTYENA,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::MIGHTYENITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Mightyena") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,125,70,125,60,70] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::STRONGJAW if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},   
"type2"=>proc{|pokemon|
   next (PBTypes::GHOST) if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::DARKRAI,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::DARKRITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Darkrai Perfection") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [70,90,95,170,165,100] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::BADDREAMS if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1011 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
},   
"type2"=>proc{|pokemon|
   next (PBTypes::GHOST) if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::TOXICROAK,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::TOXICROAKITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Toxicroak") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [83,136,70,115,116,70] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::ADAPTABILITY if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::CINCCINO,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::CINCCINITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Cinccino") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [75,125,110,135,40,80] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::SKILLLINK if pokemon.form==1
   next  
},
"type2"=>proc{|pokemon|
   next (PBTypes::FAIRY) if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::UMBREON,{
"getMegaForm"=>proc{|pokemon|
   next 1 if (pokemon.item == PBItems::DARKRITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Umbreon Perfection") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [95,75,130,75,120,130] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next PBAbilities::MAGICBOUNCE if pokemon.form==1
   next   
},
"type2"=>proc{|pokemon|
   next (PBTypes::PSYCHIC) if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
##### Developer Team Forms #####

MultipleForms.register(PBSpecies::GLACEON,{
"getMegaName"=>proc{|pokemon|
   next _INTL("Mismageon") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   next [65,60,110,105,130,105] # Mismageon
},
"type2"=>proc{|pokemon|
   next (PBTypes::GHOST) if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(PBSpecies::CINCCINO,{
"getMegaName"=>proc{|pokemon|
   next _INTL("Meech") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0
   next [100,95,70,115,65,105] # Meech
},
"type2"=>proc{|pokemon|
   next (PBTypes::WATER) if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})



MultipleForms.register(PBSpecies::LILLIGANT,{
"ability"=>proc{|pokemon|
   next PBAbilities::SIMPLE if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::RIBOMBEE,{
"ability"=>proc{|pokemon|
   next PBAbilities::SIMPLE if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::DEDENNE,{
"ability"=>proc{|pokemon|
   next PBAbilities::VOLTABSORB if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::SMEARGLE,{
"ability"=>proc{|pokemon|
   next PBAbilities::PRANKSTER if pokemon.form==1
   next
}
})

MultipleForms.register(PBSpecies::MARSHADOW,{
"ability"=>proc{|pokemon|
   next PBAbilities::SIMPLE if pokemon.form==1
   next
}
})
=end
