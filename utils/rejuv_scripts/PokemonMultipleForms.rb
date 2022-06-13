class PokeBattle_Pokemon
  def form
    v=MultipleForms.call("getForm",self)
    if v!=nil
      self.form=v if !@form || v!=@form
      return v
    end
    return @form || 0
  end
  
  def form=(value)
    @form=value
    self.calcStats
    MultipleForms.call("onSetForm",self,value)
  end
  
  def hasMegaForm?
    v=MultipleForms.call("getMegaForm",self)
    return v!=nil
  end
  
  def hasZMove?
    canuse=false
    pkmn=self
    case pkmn.item
    when getID(PBItems,:NORMALIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==0
          canuse=true
        end
      end   
    when getID(PBItems,:FIGHTINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==1
          canuse=true
        end
      end     
    when getID(PBItems,:FLYINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==2
          canuse=true
        end
      end   
    when getID(PBItems,:POISONIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==3
          canuse=true
        end
      end           
    when getID(PBItems,:GROUNDIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==4
          canuse=true
        end
      end    
    when getID(PBItems,:ROCKIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==5
          canuse=true
        end
      end           
    when getID(PBItems,:BUGINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==6
          canuse=true
        end
      end  
    when getID(PBItems,:GHOSTIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==7
          canuse=true
        end
      end           
    when getID(PBItems,:STEELIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==8
          canuse=true
        end
      end           
    when getID(PBItems,:FIRIUMZ)
      canuse=false
      for move in pkmn.moves
        if move.type==10
          canuse=true
        end
      end       
    when getID(PBItems,:WATERIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==11
          canuse=true
        end
      end           
    when getID(PBItems,:GRASSIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==12
          canuse=true
        end
      end               
    when getID(PBItems,:ELECTRIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==13
          canuse=true
        end
      end          
    when getID(PBItems,:PSYCHIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==14
          canuse=true
        end
      end   
    when getID(PBItems,:ICIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==15
          canuse=true
        end
      end               
    when getID(PBItems,:DRAGONIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==16
          canuse=true
        end
      end               
    when getID(PBItems,:DARKINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==17
          canuse=true
        end
      end           
    when getID(PBItems,:FAIRIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==18
          canuse=true
        end
      end                     
    when getID(PBItems,:ALORAICHIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:THUNDERBOLT)
          canuse=true
        end
      end
      if pkmn.species!=26 || pkmn.form!=1
        canuse=false
      end 
    when getID(PBItems,:DECIDIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SPIRITSHACKLE)
          canuse=true
        end
      end
      if pkmn.species!=724
        canuse=false
      end          
    when getID(PBItems,:INCINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:DARKESTLARIAT)
          canuse=true
        end
      end
      if pkmn.species!=727
        canuse=false
      end           
    when getID(PBItems,:PRIMARIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SPARKLINGARIA)
          canuse=true
        end
      end
      if pkmn.species!=724
        canuse=false
      end  
    when getID(PBItems,:EEVIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:LASTRESORT)
          canuse=true
        end
      end
      if pkmn.species!=133
        canuse=false
      end           
    when getID(PBItems,:PIKANIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:VOLTTACKLE)
          canuse=true
        end
      end
      if pkmn.species!=25
        canuse=false
      end    
    when getID(PBItems,:SNORLIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:GIGAIMPACT)
          canuse=true
        end
      end
      if pkmn.species!=143
        canuse=false
      end      
    when getID(PBItems,:MEWNIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:PSYCHIC)
          canuse=true
        end
      end
      if pkmn.species!=151
        canuse=false
      end   
    when getID(PBItems,:TAPUNIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:NATURESMADNESS)
          canuse=true
        end
      end
      if !(pokemon.species==785 || pokemon.species==786 || pokemon.species==787 || pokemon.species==788)
        canuse=false
      end   
    when getID(PBItems,:MARSHADIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SPECTRALTHIEF)
          canuse=true
        end
      end  
    when getID(PBItems,:KOMMONIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:CLANGINGSCALES)
          canuse=true
        end
      end
      if pkmn.species!=784
        canuse=false
      end      
    when getID(PBItems,:LYCANIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:STONEEDGE)
          canuse=true
        end
      end
      if pkmn.species!=745
        canuse=false
      end              
    when getID(PBItems,:MIMIKIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:PLAYROUGH)
          canuse=true
        end
      end
      if pkmn.species!=778
        canuse=false
      end 
    when getID(PBItems,:SOLGANIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SUNSTEELSTRIKE)
          canuse=true
        end
      end
      if pkmn.species!=791 && !(pkmn.species==800 && pkmn.form==1) 
        canuse=false
      end   
    when getID(PBItems,:LUNALIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:MOONGEISTBEAM)
          canuse=true
        end
      end
      if pkmn.species!=792 && !(pkmn.species==800 && pkmn.form==2) 
        canuse=false
      end              
    when getID(PBItems,:ULTRANECROZIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:PHOTONGEYSER)
          canuse=true
        end
      end
      if pkmn.species!=800 || pkmn.form==0
        canuse=false
      end 
    end
    return canuse
  end  
  
  def isMega?
    v=MultipleForms.call("getMegaForm",self)
    return (v!=nil && v==@form)
  end
  
  def makeMega
    v=MultipleForms.call("getMegaForm",self)
    self.form=v if v!=nil
  end
  
  def makeUnmega
    v=MultipleForms.call("getUnmegaForm",self)
    self.form=v if v!=nil
  end
  
  def megaName
    v=MultipleForms.call("getMegaName",self)
    return v if v!=nil
    return ""
  end
  
  alias __mf_baseStats baseStats
  alias __mf_ability ability
  alias __mf_type1 type1
  alias __mf_type2 type2
  alias __mf_height height
  alias __mf_weight weight
  alias __mf_getMoveList getMoveList
  alias __mf_isCompatibleWithMove? isCompatibleWithMove?
  alias __mf_wildHoldItems wildHoldItems
  alias __mf_baseExp baseExp
  alias __mf_evYield evYield
  alias __mf_initialize initialize
  
  def baseStats
    v=MultipleForms.call("getBaseStats",self)
    return v if v!=nil
    return self.__mf_baseStats
  end
  
  def ability
    v=MultipleForms.call("ability",self)
    return v if v!=nil
    return self.__mf_ability
  end
  
  def type1
    v=MultipleForms.call("type1",self)
    return v if v!=nil
    return self.__mf_type1
  end
  
  def type2
    v=MultipleForms.call("type2",self)
    return v if v!=nil
    return self.__mf_type2
  end
  
  def height
    v=MultipleForms.call("height",self)
    return v if v!=nil
    return self.__mf_height
  end
  
  def weight
    v=MultipleForms.call("weight",self)
    return v if v!=nil
    return self.__mf_weight
  end
  
  def getMoveList
    v=MultipleForms.call("getMoveList",self)
    return v if v!=nil
    return self.__mf_getMoveList
  end
  
  def isCompatibleWithMove?(move)
    v=MultipleForms.call("getMoveCompatibility",self)
    if v!=nil
      return v.any? {|j| j==move }
    end
    return self.__mf_isCompatibleWithMove?(move)
  end
  
  def wildHoldItems
    v=MultipleForms.call("wildHoldItems",self)
    return v if v!=nil
    return self.__mf_wildHoldItems
  end
  
  def baseExp
    v=MultipleForms.call("baseExp",self)
    return v if v!=nil
    return self.__mf_baseExp
  end
  
  def evYield
    v=MultipleForms.call("evYield",self)
    return v if v!=nil
    return self.__mf_evYield
  end
  
  def initialize(*args)
    __mf_initialize(*args)
    f=MultipleForms.call("getFormOnCreation",self)
    if f
      self.form=f
      self.resetMoves
    end
  end
end



class PokeBattle_RealBattlePeer
  def pbOnEnteringBattle(battle,pokemon)
    f=MultipleForms.call("getFormOnEnteringBattle",pokemon)
    if f
      pokemon.form=f
    end
  end
end

class PokeBattle_Battle
  def pbBelongsToPlayer?(pokemon)
    if @player.is_a?(Array) && @player.length>1
      return pokemon==0
    else
      return (pokemon%2)==0
    end
    return false
  end
end

module MultipleForms
  @@formSpecies=HandlerHash.new(:PBSpecies)
  
  def self.copy(sym,*syms)
    @@formSpecies.copy(sym,*syms)
  end
  
  def self.register(sym,hash)
    @@formSpecies.add(sym,hash)
  end
  
  def self.registerIf(cond,hash)
    @@formSpecies.addIf(cond,hash)
  end
  
  def self.hasFunction?(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return sp && sp[func]
  end
  
  def self.getFunction(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return (sp && sp[func]) ? sp[func] : nil
  end
  
  def self.call(func,pokemon,*args)
    sp=@@formSpecies[pokemon.species]
    return nil if !sp || !sp[func]
    return sp[func].call(pokemon,*args)
  end
  
  def self.call2(func,pokemon,*args)       #For when only given a species
    sp=@@formSpecies[pokemon.species]
    return nil if !sp || !sp[func]
    return sp[func].call(pokemon,*args)
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
    drawSpot(bitmap,spot1,b+33,a+25,-120,-120,-20)
    drawSpot(bitmap,spot2,d+21,c+24,-120,-120,-20)
    drawSpot(bitmap,spot3,f+39,e+7,-120,-120,-20)
    drawSpot(bitmap,spot4,h+15,g+6,-120,-120,-20)
  else
    drawSpot(bitmap,spot1,b+33,a+25,0,-115,-75)
    drawSpot(bitmap,spot2,d+21,c+24,0,-115,-75)
    drawSpot(bitmap,spot3,f+39,e+7,0,-115,-75)
    drawSpot(bitmap,spot4,h+15,g+6,0,-115,-75)
  end
end

MultipleForms.register(:UNOWN,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(28)
    }
  })


MultipleForms.register(:FLABEBE,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(5)
    }
  })
MultipleForms.register(:FLOETTE,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(5)
    }
  })
MultipleForms.register(:FLORGES,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(5)
    }
  })

MultipleForms.register(:SPINDA,{
    "alterBitmap"=>proc{|pokemon,bitmap|
      pbSpindaSpots(pokemon,bitmap)
    }
  })

MultipleForms.register(:CASTFORM,{
    "type1"=>proc{|pokemon|
      next if pokemon.form==0              # Normal Form
      case pokemon.form
      when 1; next getID(PBTypes,:FIRE)  # Sunny Form
      when 2; next getID(PBTypes,:WATER) # Rainy Form
      when 3; next getID(PBTypes,:ICE)   # Snowy Form
      end
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0              # Normal Form
      case pokemon.form
      when 1; next getID(PBTypes,:FIRE)  # Sunny Form
      when 2; next getID(PBTypes,:WATER) # Rainy Form
      when 3; next getID(PBTypes,:ICE)   # Snowy Form
      end
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal Forme
      next if !isConst?(pokemon.item,PBItems,:CASTCREST) # No crest
      case pokemon.form
      when 1; next [ 70, 70, 70,100, 90, 70] # Sunny Form
      when 2; next [100, 70, 80, 70, 70, 80] # Rainy Form
      when 3; next [ 70, 70, 70, 90,100, 70] # Snowy Form
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:DEOXYS,{
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
      when 1 ; movelist=[[1,:LEER],[1,:WRAP],[7,:NIGHTSHADE],[13,:TELEPORT],
          [19,:TAUNT],[25,:PURSUIT],[31,:PSYCHIC],[37,:SUPERPOWER],
          [43,:PSYCHOSHIFT],[49,:ZENHEADBUTT],[55,:COSMICPOWER],
          [61,:ZAPCANNON],[67,:PSYCHOBOOST],[73,:HYPERBEAM]]
      when 2 ; movelist=[[1,:LEER],[1,:WRAP],[7,:NIGHTSHADE],[13,:TELEPORT],
          [19,:KNOCKOFF],[25,:SPIKES],[31,:PSYCHIC],[37,:SNATCH],
          [43,:PSYCHOSHIFT],[49,:ZENHEADBUTT],[55,:IRONDEFENSE],
          [55,:AMNESIA],[61,:RECOVER],[67,:PSYCHOBOOST],
          [73,:COUNTER],[73,:MIRRORCOAT]]
      when 3 ; movelist=[[1,:LEER],[1,:WRAP],[7,:NIGHTSHADE],[13,:DOUBLETEAM],
          [19,:KNOCKOFF],[25,:PURSUIT],[31,:PSYCHIC],[37,:SWIFT],
          [43,:PSYCHOSHIFT],[49,:ZENHEADBUTT],[55,:AGILITY],
          [61,:RECOVER],[67,:PSYCHOBOOST],[73,:EXTREMESPEED]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:BURMY,{
    "getFormOnCreation"=>proc{|pokemon|
      env=pbGetEnvironment()
      if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        next 2 # Trash Cloak
      elsif env==PBEnvironment::Sand ||
        env==PBEnvironment::Rock ||
        env==PBEnvironment::Cave
        next 1 # Sandy Cloak
      else
        next 0 # Plant Cloak
      end
    },
    "getFormOnEnteringBattle"=>proc{|pokemon|
      env=pbGetEnvironment()
      if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        next 2 # Trash Cloak
      elsif env==PBEnvironment::Sand ||
        env==PBEnvironment::Rock ||
        env==PBEnvironment::Cave
        next 1 # Sandy Cloak
      else
        next 0 # Plant Cloak
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:WORMADAM,{
    "getFormOnCreation"=>proc{|pokemon|
      env=pbGetEnvironment()
      if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        next 2 # Trash Cloak
      elsif env==PBEnvironment::Sand || env==PBEnvironment::Rock ||
        env==PBEnvironment::Cave
        next 1 # Sandy Cloak
      else
        next 0 # Plant Cloak
      end
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0               # Plant Cloak
      case pokemon.form
      when 1; next getID(PBTypes,:GROUND) # Sandy Cloak
      when 2; next getID(PBTypes,:STEEL)  # Trash Cloak
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
      when 1 ; movelist=[[0,:QUIVERDANCE],[1,:SUCKERPUNCH],[1,:TACKLE],
          [1,:PROTECT],[1,:BUGBITE],[10,:PROTECT],[15,:BUGBITE],
          [20,:HIDDENPOWER],[23,:CONFUSION],[26,:ROCKBLAST],
          [29,:HARDEN],[32,:PSYBEAM],[35,:CAPTIVATE],[38,:FLAIL],
          [41,:ATTRACT],[44,:PSYCHIC],[47,:FISSURE],[50,:BUGBUZZ]]
      when 2 ; movelist=[[0,:QUIVERDANCE],[1,:METALBURST],[1,:SUCKERPUNCH],[1,:TACKLE],
          [1,:PROTECT],[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],
          [20,:HIDDENPOWER],[23,:CONFUSION],[26,:MIRRORSHOT],
          [29,:METALSOUND],[32,:PSYBEAM],[35,:CAPTIVATE],[38,:FLAIL],
          [41,:ATTRACT],[44,:PSYCHIC],[47,:IRONHEAD],[50,:BUGBUZZ]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    }
  })

MultipleForms.register(:SHELLOS,{
    "getFormOnCreation"=>proc{|pokemon|
      maps=[]   
      # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.copy(:SHELLOS,:GASTRODON)

MultipleForms.register(:ROTOM,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     # Normal Form
      next [50,65,107,86,105,107] # All alternate forms
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0               # Normal Form
      case pokemon.form
      when 1; next getID(PBTypes,:FIRE)   # Heat, Microwave
      when 2; next getID(PBTypes,:WATER)  # Wash, Washing Machine
      when 3; next getID(PBTypes,:ICE)    # Frost, Refrigerator
      when 4; next getID(PBTypes,:FLYING) # Fan
      when 5; next getID(PBTypes,:GRASS)  # Mow, Lawnmower
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

MultipleForms.register(:GIRATINA,{
    "ability"=>proc{|pokemon|
      next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:LEVITATE) # Origin Forme
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
      if isConst?(pokemon.item,PBItems,:GRISEOUSORB) ||
        ($game_map && maps.include?($game_map.map_id))
        next 1
      end
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SHAYMIN,{
    "type2"=>proc{|pokemon|
      next if pokemon.form==0     # Land Forme
      next getID(PBTypes,:FLYING) # Sky Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0              # Land Forme
      next getID(PBAbilities,:SERENEGRACE) # Sky Forme
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
      next 0 if PBDayNight.isNight?(pbGetTimeNow) ||
      pokemon.hp<=0 || pokemon.status==PBStatuses::FROZEN
      next nil
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1 ; movelist=[[1,:GROWTH],[10,:MAGICALLEAF],[19,:LEECHSEED],
          [28,:QUICKATTACK],[37,:SWEETSCENT],[46,:NATURALGIFT],
          [55,:WORRYSEED],[64,:AIRSLASH],[73,:ENERGYBALL],
          [82,:SWEETKISS],[91,:LEAFSTORM],[100,:SEEDFLARE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ARCEUS,{
    "type1"=>proc{|pokemon|
      types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
        :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
        :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
        :ICE,:DRAGON,:DARK,:FAIRY]
      next getID(PBTypes,types[pokemon.form])
    },
    "type2"=>proc{|pokemon|
      types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
        :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
        :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
        :ICE,:DRAGON,:DARK,:FAIRY]
      next getID(PBTypes,types[pokemon.form])
    },
    "getForm"=>proc{|pokemon|
      if $fefieldeffect == 35
        if $fecounter == 1
          form = 0
          loop do
            form = rand(19)
            break if form != 9
          end
          next form
        end
      else
        next 1  if isConst?(pokemon.item,PBItems,:FISTPLATE) || isConst?(pokemon.item,PBItems,:FIGHTINIUMZ2)
        next 2  if isConst?(pokemon.item,PBItems,:SKYPLATE) || isConst?(pokemon.item,PBItems,:FLYINIUMZ2)
        next 3  if isConst?(pokemon.item,PBItems,:TOXICPLATE) || isConst?(pokemon.item,PBItems,:POISONIUMZ2)
        next 4  if isConst?(pokemon.item,PBItems,:EARTHPLATE) || isConst?(pokemon.item,PBItems,:GROUNDIUMZ2)
        next 5  if isConst?(pokemon.item,PBItems,:STONEPLATE) || isConst?(pokemon.item,PBItems,:ROCKIUMZ2)
        next 6  if isConst?(pokemon.item,PBItems,:INSECTPLATE) || isConst?(pokemon.item,PBItems,:BUGINIUMZ2)
        next 7  if isConst?(pokemon.item,PBItems,:SPOOKYPLATE) || isConst?(pokemon.item,PBItems,:GHOSTIUMZ2)
        next 8  if isConst?(pokemon.item,PBItems,:IRONPLATE) || isConst?(pokemon.item,PBItems,:STEELIUMZ2)
        next 10 if isConst?(pokemon.item,PBItems,:FLAMEPLATE) || isConst?(pokemon.item,PBItems,:FIRIUMZ2)
        next 11 if isConst?(pokemon.item,PBItems,:SPLASHPLATE) || isConst?(pokemon.item,PBItems,:WATERIUMZ2)
        next 12 if isConst?(pokemon.item,PBItems,:MEADOWPLATE) || isConst?(pokemon.item,PBItems,:GRASSIUMZ2)
        next 13 if isConst?(pokemon.item,PBItems,:ZAPPLATE) || isConst?(pokemon.item,PBItems,:ELECTRIUMZ2)
        next 14 if isConst?(pokemon.item,PBItems,:MINDPLATE) || isConst?(pokemon.item,PBItems,:PSYCHIUMZ2)
        next 15 if isConst?(pokemon.item,PBItems,:ICICLEPLATE) || isConst?(pokemon.item,PBItems,:ICIUMZ2)
        next 16 if isConst?(pokemon.item,PBItems,:DRACOPLATE) || isConst?(pokemon.item,PBItems,:DRAGONNIUMZ2)
        next 17 if isConst?(pokemon.item,PBItems,:DREADPLATE) || isConst?(pokemon.item,PBItems,:DARKINIUMZ2)
        next 18 if isConst?(pokemon.item,PBItems,:PIXIEPLATE) || isConst?(pokemon.item,PBItems,:FAIRIUMZ2)
        next 0
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:BASCULIN,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(2)
    },
    "ability"=>proc{|pokemon|
    next if pokemon.form==0               # Incarnate Forme
    if pokemon.abilityflag && pokemon.abilityflag!=2
      next getID(PBAbilities,:ROCKHEAD) # Therian Forme
    end
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Red-Striped
      next [0,getID(PBItems,:DEEPSEASCALE),0] # Blue-Striped
    }
  })

MultipleForms.register(:DARMANITAN,{
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
      next getID(PBTypes,:FIRE) if pokemon.form==1      # Zen
      next getID(PBTypes,:ICE) if pokemon.form==2      # Galar
      next getID(PBTypes,:ICE) if pokemon.form==3      # Galar Zen
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:PSYCHIC) if pokemon.form==1      # Zen
      next getID(PBTypes,:ICE) if pokemon.form==2      # Galar
      next getID(PBTypes,:FIRE) if pokemon.form==3      # Galar Zen
    },
    "evYield"=>proc{|pokemon|
      next [0,0,0,0,2,0] if pokemon.form==2      # Zen Mode
      next # Otherwise
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form!=2      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 2 ; movelist=[[0,:ICICLECRASH],[1,:ICICLECRASH],[1,:POWDERSNOW],[1,:TACKLE],[1,:TAUNT],[1,:BITE],
          [12,:AVALANCHE],[16,:WORKUP],[20,:ICEFANG],[24,:HEADBUTT],
          [28,:ICEPUNCH],[32,:UPROAR],[38,:BELLYDRUM],
          [44,:BLIZZARD],[50,:THRASH],[56,:SUPERPOWER]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 
      movelist=[]
      case pokemon.form
      when 2; movelist=[# TMs
			:WORKUP,:TOXIC,:BULKUP,:HIDDENPOWER,:SUNNYDAY,:TAUNT,
			:ICEBEAM,:BLIZZARD,:HYPERBEAM,:PROTECT,:SECRETPOWER,
			:FRUSTRATION,:SOLARBEAM,:EARTHQUAKE,:RETURN,:DIG,:PSYCHIC,
			:BRICKBREAK,:DOUBLETEAM,:FLAMETHROWER,:FIREBLAST,:ROCKTOMB,
			:FACADE,:FLAMECHARGE,:REST,:ATTRACT,:THIEF,:ROUND,:OVERHEAT,
			:FOCUSBLAST,:FLING,:INCINERATE,:WILLOWISP,:PAYBACK,:GIGAIMPACT,
			:STONEEDGE,:GYROBALL,:BULLDOZE,:ROCKSLIDE,:GRASSKNOT,:SWAGGER,
			:SLEEPTALK,:UTURN,:SUBSTITUTE,POWERUPPUNCH,:CONFIDE,
			:POISONSWEEP,:STACKINGSHOT,:LAVASURF,:MEGAPUNCH,:MEGAKICK,
			:FIRESPIN,:ICEFANG,:FIREFANG,:AVALANCHE,:STRENGTH,
			# Move Tutors
			:SNORE,:UPROAR,:IRONDEFENSE,:FIREPUNCH,:ICEPUNCH,:IRONHEAD,
			:FOCUSPUNCH,:ZENHEADBUTT,:TRICK,:HEATWAVE,:SUPERPOWER,:BODYSLAM,
			:FOCUSENERGY,:REVERSAL,:ENDURE,:ENCORE,FUTURESIGHT,:FLAREBLITZ,
			:BODYPRESS]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      next if pokemon.form==1 # Normal-Zen Mode
      if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:GORILLATACTICS)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:ZENMODE)  
      end
    },"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:DEERLING,{
    "getForm"=>proc{|pokemon|
      time=pbGetTimeNow
      next (time.month-1)%4
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.copy(:DEERLING,:SAWSBUCK)

MultipleForms.register(:TORNADUS,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     # Incarnate Forme
      next [79,100,80,121,110,90] # Therian Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0                # Incarnate Forme
      if pokemon.abilityflag && pokemon.abilityflag!=2
        next getID(PBAbilities,:REGENERATOR) # Therian Forme
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

MultipleForms.register(:THUNDURUS,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     # Incarnate Forme
      next [79,105,70,101,145,80] # Therian Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0               # Incarnate Forme
      if pokemon.abilityflag && pokemon.abilityflag!=2
        next getID(PBAbilities,:VOLTABSORB) # Therian Forme
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

MultipleForms.register(:LANDORUS,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0    # Incarnate Forme
      next [89,145,90,71,105,80] # Therian Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0               # Incarnate Forme
      if pokemon.abilityflag && pokemon.abilityflag!=2
        next getID(PBAbilities,:INTIMIDATE) # Therian Forme
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

MultipleForms.register(:KYUREM,{
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 1; next [125,120, 90,95,170,100] # White Kyurem
      when 2; next [125,170,100,95,120, 90] # Black Kyurem
      else;   next                          # Kyurem
      end
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 1; next getID(PBAbilities,:TURBOBLAZE) # White Kyurem
      when 2; next getID(PBAbilities,:TERAVOLT)   # Black Kyurem
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
      when 1; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
          [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
          [36,:SLASH],[43,:FUSIONFLARE],[50,:ICEBURN],
          [57,:DRAGONPULSE],[64,:NOBLEROAR],[71,:ENDEAVOR],
          [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
      when 2; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
          [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
          [36,:SLASH],[43,:FUSIONBOLT],[50,:FREEZESHOCK],
          [57,:DRAGONPULSE],[64,:NOBLEROAR],[71,:ENDEAVOR],
          [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:KELDEO,{
    "getForm"=>proc{|pokemon|
      next 1 if pokemon.knowsMove?(:SECRETSWORD) # Resolute Form
      next 0                                     # Ordinary Form
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MELOETTA,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     # Aria Forme
      next [100,128,90,128,77,77] # Pirouette Forme
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0       # Aria Forme
      next getID(PBTypes,:FIGHTING) # Pirouette Forme
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0 # Aria Forme
      next [0,1,1,1,0,0]      # Pirouette Forme
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:GENESECT,{
    "getForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:SHOCKDRIVE)
      next 2 if isConst?(pokemon.item,PBItems,:BURNDRIVE)
      next 3 if isConst?(pokemon.item,PBItems,:CHILLDRIVE)
      next 4 if isConst?(pokemon.item,PBItems,:DOUSEDRIVE)
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MEOWSTIC,{
    "ability"=>proc{|pokemon|
      next if pokemon.gender==0 # Male Meowstic
      #### JERICHO - 015 - START
      if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        #### JERICHO - 015 - END
        next getID(PBAbilities,:COMPETITIVE) # Female Meowstic
      end
    },
    
    "getMoveList"=>proc{|pokemon|
      next if pokemon.gender==0 # Male Meowstic
      movelist=[]
      case pokemon.gender
      when 1 ; movelist=[[1,:STOREDPOWER],[1,:MEFIRST],[1,:MAGICALLEAF],[1,:SCRATCH],
          [1,:LEER],[1,:COVET],[1,:CONFUSION],[5,:COVET],[9,:CONFUSION],[13,:LIGHTSCREEN],
          [17,:PSYBEAM],[19,:FAKEOUT],[22,:DISARMINGVOICE],[25,:PSYSHOCK],[28,:CHARGEBEAM],
          [31,:SHADOWBALL],[35,:EXTRASENSORY],[40,:PSYCHIC],
          [43,:ROLEPLAY],[45,:SIGNALBEAM],[48,:SUCKERPUNCH],
          [50,:FUTURESIGHT],[53,:STOREDPOWER]] # Female Meowstic
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    }
  })

MultipleForms.register(:AEGISLASH,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0 # Shield Forme
      next [60,140,50,60,140,50] if pokemon.form==1  # Blade Forme
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ZYGARDE,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form      
      when 0
        next  # 50%
      when 1
        next "Its sharp fangs make short work of finishing off its enemies, but it’s unable to maintain this body indefinitely. After a period of time, it falls apart." # 10%
      when 2
        next "This is Zygarde’s form at times when it uses its overwhelming power to suppress those who endanger the ecosystem." # 100%
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
        next 1.2
      when 2 # 100%
        next 4.5
      end  
    },
    "weight"=>proc{|pokemon|
      case pokemon.form
      when 0 # 50%
        next   
      when 1 # 10%       
        next 33.5
      when 2 # 100%
        next 610.0
      end  
      next 490 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:HOOPA,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     
      next [80,160,60,80,170,130] # Unbound Forme
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0       
      next getID(PBTypes,:DARK) # Unbound Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0               
      if pokemon.abilityflag && pokemon.abilityflag!=2
        next getID(PBAbilities,:MAGICIAN) # Unbound Forme
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1 ; movelist=[[1,:HYPERSPACEFURY],[1,:TRICK],[1,:DESTINYBOND],[1,:ALLYSWITCH],
          [1,:CONFUSION],[6,:ASTONISH],[10,:MAGICCOAT],[15,:LIGHTSCREEN],
          [19,:PSYBEAM],[25,:SKILLSWAP],[29,:POWERSPLIT],[29,:GUARDSPLIT],
          [46,:KNOCKOFF],[50,:WONDERROOM],[50,:TRICKROOM],[55,:DARKPULSE],
          [75,:PSYCHIC],[85,:HYPERSPACEFURY]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "height"=>proc{|pokemon|
      next 65 if pokemon.form==1
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


MultipleForms.register(:ORICORIO,{
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
        next #getID(PBTypes,:FIRE) # Baile
      when 1
        next getID(PBTypes,:ELECTRIC) # Pom-Pom
      when 2
        next getID(PBTypes,:PSYCHIC) # Pa'u
      when 3
        next getID(PBTypes,:GHOST) # Sensu
      end
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[405]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        maps=[406]   # Map IDs for second form
        if $game_map && maps.include?($game_map.map_id)
          next 2
        else
          maps=[408]   # Map IDs for second form
          if $game_map && maps.include?($game_map.map_id)
            next 3
          else
            next 0
          end
        end
      end
    }
  })

MultipleForms.register(:ROCKRUFF,{
  "ability"=>proc{|pokemon|
    next if pokemon.form==0 # Male Meowstic
    #### JERICHO - 015 - START
      #### JERICHO - 015 - END
    next getID(PBAbilities,:OWNTEMPO) # Female Meowstic
  }})

MultipleForms.register(:LYCANROC,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 1; next "They live alone without forming packs. They will only listen to orders from Trainers who can draw out their true power." # Midnight
      when 2; next "Bathed in the setting sun of evening, Lycanroc has undergone a special kind of evolution. An intense fighting spirit underlies its calmness." # Dusk
      else;   next     # Midday
      end
    },
    "height"=>proc{|pokemon|
      case pokemon.form
      when 1; next 1.1 # Midnight
      when 2; next 0.8 # Dusk
      else;   next     # Midday
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 1; next [85,115, 75, 82, 55, 75] # Midnight
      when 2; next [75,117, 65,110, 55, 65] # Dusk
      else;   next                          # Midday
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Midday
      movelist=[]
      case pokemon.form            # Midnight
      when 1 ; movelist=[[0,:COUNTER],[1,:REVERSAL],[1,:TAUNT],
          [1,:TACKLE],[1,:LEER],[1,:SANDATTACK],
          [1,:BITE],[4,:SANDATTACK],[7,:BITE],[12,:HOWL],
          [15,:ROCKTHROW],[18,:ODORSLEUTH],[23,:ROCKTOMB],
          [26,:ROAR],[29,:STEALTHROCK],[34,:ROCKSLIDE],
          [37,:SCARYFACE],[40,:CRUNCH],[45,:ROCKCLIMB],
          [48,:STONEEDGE]]
      when 2 ; movelist=[[0,:THRASH],[1,:ACCELEROCK],[1,:BITE],
          [1,:COUNTER],[1,:LEER],[1,:SANDATTACK],
          [1,:TACKLE],[4,:SANDATTACK],[7,:BITE],[12,:HOWL],
          [15,:ROCKTHROW],[18,:ODORSLEUTH],[23,:ROCKTOMB],
          [26,:ROAR],[29,:STEALTHROCK],[34,:ROCKSLIDE],
          [37,:SCARYFACE],[40,:CRUNCH],[45,:ROCKCLIMB],
          [48,:STONEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :ROAR,:TOXIC,:BULKUP,:HIDDENPOWER,:TAUNT,:PROTECT,
          :FRUSTRATION,:RETURN,:BRICKBREAK,:DOUBLETEAM,:ROCKTOMB,
          :FACADE,:REST,:ATTRACT,:ROUND,:ECHOEDVOICE,:ROCKPOLISH,
          :STONEEDGE,:SWORDSDANCE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:SNARL,:CONFIDE,
          # Move Tutors
          :COVET,:DUALCHOP,:EARTHPOWER,:ENDEAVOR,:FIREPUNCH,
          :FOCUSPUNCH,:FOULPLAY,:HYPERVOICE,:IRONDEFENSE,:IRONHEAD,
          :IRONTAIL,:LASERFOCUS,:LASTRESORT,:OUTRAGE,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM,:THROATCHOP,
          :THUNDERPUNCH,:UPROAR,:ZENHEADBUTT]
      when 2; movelist=[# TMs
          :ROAR,:TOXIC,:BULKUP,:HIDDENPOWER,:TAUNT,:PROTECT,
          :FRUSTRATION,:RETURN,:BRICKBREAK,:DOUBLETEAM,:ROCKTOMB,
          :FACADE,:REST,:ATTRACT,:ROUND,:ECHOEDVOICE,:ROCKPOLISH,
          :STONEEDGE,:SWORDSDANCE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:SNARL,:CONFIDE,
          # Move Tutors
          :COVET,:DRILLRUN,:EARTHPOWER,:ENDEAVOR,:HYPERVOICE,
          :IRONDEFENSE,:IRONHEAD,:IRONTAIL,:LASTRESORT,:OUTRAGE,
          :SNORE,:STEALTHROCK,:STOMPINGTANTRUM,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Midday
      if pokemon.form==1      # Midnight
        if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Midnight
          next getID(PBAbilities,:VITALSPIRIT)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
          next getID(PBAbilities,:NOGUARD)  
        end
      end
      if pokemon.form==2      # Dusk
        next getID(PBAbilities,:TOUGHCLAWS)
      end  
    },
    "getFormOnCreation"=>proc{|pokemon|
      #   maps=[321]   # Map IDs for second form
      #   if $game_map && maps.include?($game_map.map_id)
      #     next 1
      #   else
      #     next 0
      #   end
      daytime = PBDayNight.isDay?(pbGetTimeNow)
      dusktime = PBDayNight.isDusk?(pbGetTimeNow)
      # Map IDs for second form
      if daytime
        next 0
      else
        next 1
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:WISHIWASHI,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Solo
      next "At their appearance, even Gyarados will flee. When they team up to use Water Gun, its power exceeds that of Hydro Pump."     # School
    },
    "height"=>proc{|pokemon|
      next 8.2 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 78.6 if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Solo
      next [45,140,130,30,140,135]   # School
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })


MultipleForms.register(:SILVALLY,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Type: Normal
      next "Upon awakening, its RKS System is activated. By employing specific memories, this Pokémon can adapt its type to confound its enemies."     # All other types
    },
    "type1"=>proc{|pokemon|
      types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
        :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
        :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
        :ICE,:DRAGON,:DARK,:FAIRY]
      next getID(PBTypes,types[pokemon.form])
    },
    "type2"=>proc{|pokemon|
      types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
        :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
        :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
        :ICE,:DRAGON,:DARK,:FAIRY]
      next getID(PBTypes,types[pokemon.form])
    },
    "getForm"=>proc{|pokemon|
      next 9  if $fefieldeffect == 24 # ??? on Glitch Field
      next 17 if $fefieldeffect == 29 # Dark on Holy Field (Because Science is evil)
      next 1  if isConst?(pokemon.item,PBItems,:FIGHTINGMEMORY)
      next 2  if isConst?(pokemon.item,PBItems,:FLYINGMEMORY)
      next 3  if isConst?(pokemon.item,PBItems,:POISONMEMORY)
      next 4  if isConst?(pokemon.item,PBItems,:GROUNDMEMORY)
      next 5  if isConst?(pokemon.item,PBItems,:ROCKMEMORY)
      next 6  if isConst?(pokemon.item,PBItems,:BUGMEMORY)
      next 7  if isConst?(pokemon.item,PBItems,:GHOSTMEMORY)
      next 8  if isConst?(pokemon.item,PBItems,:STEELMEMORY)
      next 10 if isConst?(pokemon.item,PBItems,:FIREMEMORY)
      next 11 if isConst?(pokemon.item,PBItems,:WATERMEMORY)
      next 12 if isConst?(pokemon.item,PBItems,:GRASSMEMORY)
      next 13 if isConst?(pokemon.item,PBItems,:ELECTRICMEMORY)
      next 14 if isConst?(pokemon.item,PBItems,:PSYCHICMEMORY)
      next 15 if isConst?(pokemon.item,PBItems,:ICEMEMORY)
      next 16 if isConst?(pokemon.item,PBItems,:DRAGONMEMORY)
      next 17 if isConst?(pokemon.item,PBItems,:DARKMEMORY)
      next 18 if isConst?(pokemon.item,PBItems,:FAIRYMEMORY)
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MINIOR,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form!=6      # Core
      next "Originally making its home in the ozone layer, it hurtles to the ground when the shell enclosing its body grows too heavy."     # Meteor
    },
    "getFormOnCreation"=>proc{|pokemon|
      next rand(6)
    },
    "weight"=>proc{|pokemon|
      next 40.0 if pokemon.form==6
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form!=6     # Core
      next [60,60,100,60,60,100]   # Meteor
    },
    "catchrate"=>proc{|pokemon|
      next 30 if pokemon.form==6
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:VIVILLON,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(9)
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:NECROZMA,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 1; next "This is its form while it is devouring the light of Solgaleo. It pounces on foes and then slashes them with the claws on its four limbs and back." # Dusk Mane Necrozma
      when 2; next "This is its form while it's devouring the light of Lunala. It grasps foes in its giant claws and rips them apart with brute force." # Dawn Wings Necrozma
      when 3; next "The light pouring out from all over its body affects living things and nature, impacting them in various ways." # Ultra Necrozma
      else;   next                          # Necrozma
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 1; next [97,157,127, 77,113,109] # Dusk Mane Necrozma
      when 2; next [97,113,109, 77,157,127] # Dawn Wings Necrozma
      when 3; next [97,167, 97,129,167, 97] # Ultra Necrozma
      else;   next                          # Necrozma
      end
    },
    "height"=>proc{|pokemon|
      case pokemon.form
      when 1; next 3.8 # Dusk Mane Necrozma
      when 2; next 4.2 # Dawn Wings Necrozma
      when 3; next 7.5 # Ultra Necrozma
      else;   next     # Necrozma
      end
    },
    "weight"=>proc{|pokemon|
      case pokemon.form
      when 1; next 460 # Dusk Mane Necrozma
      when 2; next 350 # Dawn Wings Necrozma
      when 3; next 230 # Ultra Necrozma
      else;   next     # Necrozma
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 1; next getID(PBTypes,:PSYCHIC) # Dusk Mane Necrozma
      when 2; next getID(PBTypes,:PSYCHIC) # Dawn Wings Necrozma
      when 3; next getID(PBTypes,:PSYCHIC) # Ultra Necrozma
      else;   next     # Necrozma
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 1; next getID(PBTypes,:STEEL)  # Dusk Mane Necrozma
      when 2; next getID(PBTypes,:GHOST)  # Dawn Wings Necrozma
      when 3; next getID(PBTypes,:DRAGON) # Ultra Necrozma
      else;   next                        # Necrozma
      end
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 3; next (PBAbilities::NEUROFORCE) # Ultra
      else;   next                                # Other formes
      end
    },
    "evYield"=>proc{|pokemon|
      case pokemon.form
      when 1; next [0,3,0,0,0,0] # Dusk Mane Necrozma
      when 2; next [0,0,0,0,3,0] # Dawn Wings Necrozma
      when 3; next [0,1,0,1,1,0] # Ultra Necrozma
      else;   next               # Necrozma
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ZACIAN,{
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
      next getID(PBTypes,:FAIRY)    # Crowned Sword
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)  # Crowned Sword
    },
    "weight"=>proc{|pokemon|
      next 355.0 if pokemon.form==1
      next
    },
    "getForm"=>proc{|pokemon|
      next 1  if isConst?(pokemon.item,PBItems,:RUSTEDSWORD)
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ZAMAZENTA,{
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
      next getID(PBTypes,:FIGHTING) # Crowned Shield
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0    # Normal
      next getID(PBTypes,:STEEL) # Crowned Shield
    },
    "weight"=>proc{|pokemon|
      next 785.0 if pokemon.form==1
      next
    },
    "getForm"=>proc{|pokemon|
      next 1  if isConst?(pokemon.item,PBItems,:RUSTEDSHIELD)
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:EISCUE,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0             # Ice Forme
      case pokemon.form
      when 1; next [75,80,70,130,65,50] # Noice Forme
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

### Regional Variants ###
MultipleForms.register(:RATTATA,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "With its incisors, it gnaws through doors and infiltrates people’s homes. Then, with a twitch of its whiskers, it steals whatever food it finds."     # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 38                      # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:NORMAL)  # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:TACKLE],[1,:TAILWHIP],[4,:QUICKATTACK],
          [7,:FOCUSENERGY],[10,:BITE],[13,:PURSUIT],
          [16,:HYPERFANG],[19,:ASSURANCE],[22,:CRUNCH],
          [25,:SUCKERPUNCH],[28,:SUPERFANG],[31,:DOUBLEEDGE],
          [34,:ENDEAVOR]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:COUNTER,:FINALGAMBIT,:FURYSWIPES,:MEFIRST,
          :REVENGE,:REVERSAL,:SNATCH,:STOCKPILE,
          :SWALLOW,:SWITCHEROO,:UPROAR]
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
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:ICEBEAM,:BLIZZARD,
          :PROTECT,:RAINDANCE,:FRUSTRATION,:RETURN,:SHADOWBALL,
          :DOUBLETEAM,:SLUDGEBOMB,:TORMENT,:FACADE,:REST,:ATTRACT,
          :ROUND,:QUASH,:EMBARGO,:SHADOWCLAW,:GRASSKNOT,:SWAGGER,
          :SLEEPTALK,:UTURN,:SUBSTITUTE,:SNARL,:DARKPULSE,:CONFIDE,
          # Move Tutors
          :COVET,:ENDEAVOR,:ICYWIND,:IRONTAIL,:LASTRESORT,:SHOCKWAVE,
          :SNATCH,:SNORE,:SUPERFANG,:UPROAR,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    }, 
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:PECHABERRY),0]   # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:GLUTTONY)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:HUSTLE)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:THICKFAT)  
      end
    },
    
    "getFormOnCreation"=>proc{|pokemon|
      maps=[55,58,59,91,144,194,209,218]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
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

MultipleForms.register(:RATICATE,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It forms a group of Rattata, which it assumes command of. Each group has its own territory, and disputes over food happen often."     # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 255                     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:NORMAL)  # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:SCARYFACE],[1,:SWORDSDANCE],[1,:TACKLE],
          [1,:TAILWHIP],[1,:QUICKATTACK],[1,:FOCUSENERGY],
          [4,:QUICKATTACK],[7,:FOCUSENERGY],[10,:BITE],[13,:PURSUIT],
          [16,:HYPERFANG],[19,:ASSURANCE],[24,:CRUNCH],
          [29,:SUCKERPUNCH],[34,:SUPERFANG],[39,:DOUBLEEDGE],
          [44,:ENDEAVOR]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :ROAR,:TOXIC,:BULKUP,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,
          :TAUNT,:ICEBEAM,:BLIZZARD,:HYPERBEAM,:PROTECT,:RAINDANCE,
          :FRUSTRATION,:RETURN,:SHADOWBALL,:DOUBLETEAM,:SLUDGEWAVE,
          :SLUDGEBOMB,:TORMENT,:FACADE,:REST,:ATTRACT,:THIEF,:ROUND,
          :QUASH,:EMBARGO,:SHADOWCLAW,:GIGAIMPACT,:SWORDSDANCE,
          :GRASSKNOT,:SWAGGER,:SLEEPTALK,:UTURN,:SUBSTITUTE,:SNARL,
          :DARKPULSE,:CONFIDE,
          # Move Tutors
          :COVET,:ENDEAVOR,:ICYWIND,:IRONTAIL,:KNOCKOFF,:LASTRESORT,
          :SHOCKWAVE,:SNATCH,:SNORE,:STOMPINGTANTRUM,:SUPERFANG,
          :THROATCHOP,:UPROAR,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:PECHABERRY),0]   # Alola
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [75,71,70,77,40,80]   # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:GLUTTONY)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:HUSTLE)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:THICKFAT)  
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[55,58,59,91,144]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:RAICHU,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It uses psychokinesis to control electricity. It hops aboard its own tail, using psychic power to lift the tail and move about while riding it."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 7                       # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 210                    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:PSYCHIC)  # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:PSYCHIC],[1,:SPEEDSWAP],[1,:THUNDERSHOCK],
          [1,:TAILWHIP],[1,:QUICKATTACK],[1,:THUNDERBOLT]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :PSYSHOCK,:CALMMIND,:TOXIC,:HIDDENPOWER,:HYPERBEAM,
          :LIGHTSCREEN,:PROTECT,:RAINDANCE,:SAFEGUARD,:FRUSTRATION,
          :THUNDERBOLT,:THUNDER,:RETURN,:PSYCHIC,:BRICKBREAK,
          :DOUBLETEAM,:REFLECT,:FACADE,:REST,:ATTRACT,:THIEF,
          :ROUND,:ECHOEDVOICE,:FOCUSBLAST,:FLING,:CHARGEBEAM,
          :GIGAIMPACT,:VOLTSWITCH,:THUNDERWAVE,:GRASSKNOT,:SWAGGER,
          :SLEEPTALK,:SUBSTITUTE,:WILDCHARGE,:CONFIDE,
          # Move Tutors
          :ALLYSWITCH,:COVET,:ELECTROWEB,:FOCUSPUNCH,:HELPINGHAND,
          :IRONTAIL,:KNOCKOFF,:LASERFOCUS,:MAGICCOAT,:MAGICROOM,
          :MAGNETRISE,:RECYCLE,:SHOCKWAVE,:SIGNALBEAM,:SNORE,
          :TELEKINESIS,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [60,85,50,110,95,85]    # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0              # Normal   
      next getID(PBAbilities,:SURGESURFER) # Alola
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SANDSHREW,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It lives on snowy mountains. Its steel shell is very hard—so much so, it can’t roll its body up into a ball."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 7                       # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 400                    # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:SCRATCH],[1,:DEFENSECURL],[3,:BIDE],
          [5,:POWDERSNOW],[7,:ICEBALL],[9,:RAPIDSPIN],
          [11,:FURYCUTTER],[14,:METALCLAW],[17,:SWIFT],
          [20,:FURYSWIPES],[23,:IRONDEFENSE],[26,:SLASH],
          [30,:IRONHEAD],[34,:GYROBALL],[38,:SWORDSDANCE],
          [42,:HAIL],[46,:BLIZZARD]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:AMNESIA,:CHIPAWAY,:COUNTER,:CRUSHCLAW,:CURSE,
          :ENDURE,:FLAIL,:ICICLECRASH,:ICICLESPEAR,
          :METALCLAW,:NIGHTSLASH,:HONECLAWS]
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
          :WORKUP,:TOXIC,:HAIL,:HIDDENPOWER,:SUNNYDAY,:BLIZZARD,
          :PROTECT,:SAFEGUARD,:FRUSTRATION,:EARTHQUAKE,:RETURN,
          :LEECHLIFE,:BRICKBREAK,:DOUBLETEAM,:AERIALACE,:FACADE,:REST,
          :ATTRACT,:THIEF,:ROUND,:FLING,:SHADOWCLAW,:AURORAVEIL,
          :GYROBALL,:SWORDSDANCE,:BULLDOZE,:FROSTBREATH,:ROCKSLIDE,
          :XSCISSOR,:POISONJAB,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:CONFIDE,
          # Move Tutors
          :AQUATAIL,:COVET,:FOCUSPUNCH,:ICEPUNCH,:ICYWIND,:IRONDEFENSE,
          :IRONHEAD,:IRONTAIL,:KNOCKOFF,:SNORE,:STEALTHROCK,:SUPERFANG,
          :THROATCHOP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [50,75,90,40,10,35]     # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:SNOWCLOAK)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SLUSHRUSH)  
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:SNOWCLOAK) if check==0
        next getID(PBAbilities,:SLUSHRUSH) if check==1
      end
    },
    "getFormOnCreation"=>proc{|pokemon|
    maps=[146,150,165,171,174,178,181,269,479,480,481,482,483,485,486,490,491] # Map IDs for second form
    if $game_map && maps.include?($game_map.map_id)
      next 1
    else
      next 0
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

MultipleForms.register(:SANDSLASH,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "This Pokémon’s steel spikes are sheathed in ice. Stabs from these spikes cause deep wounds and severe frostbite as well."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 12                      # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 550                    # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:ICICLESPEAR],[1,:METALBURST],[1,:ICICLECRASH],
          [1,:SLASH],[1,:DEFENSECURL],[1,:ICEBALL],
          [1,:METALCLAW]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HAIL,:HIDDENPOWER,:SUNNYDAY,:BLIZZARD,
          :HYPERBEAM,:PROTECT,:SAFEGUARD,:FRUSTRATION,:EARTHQUAKE,
          :RETURN,:LEECHLIFE,:BRICKBREAK,:DOUBLETEAM,:AERIALACE,
          :FACADE,:REST,:ATTRACT,:THIEF,:ROUND,:FOCUSBLAST,:FLING,
          :SHADOWCLAW,:GIGAIMPACT,:AURORAVEIL,:GYROBALL,:SWORDSDANCE,
          :BULLDOZE,:FROSTBREATH,:ROCKSLIDE,:XSCISSOR,:POISONJAB,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:CONFIDE,
          # Move Tutors
          :AQUATAIL,:COVET,:DRILLRUN,:FOCUSPUNCH,:ICEPUNCH,:ICYWIND,
          :IRONDEFENSE,:IRONHEAD,:IRONTAIL,:KNOCKOFF,:SNORE,
          :STEALTHROCK,:SUPERFANG,:THROATCHOP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
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
        next getID(PBAbilities,:SNOWCLOAK)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SLUSHRUSH)  
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:SNOWCLOAK) if check==0
        next getID(PBAbilities,:SLUSHRUSH) if check==1
      end
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[146,150,165,171,174,178,181,269,479,480,481,482,483,485,486,490,491] # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:VULPIX,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "In hot weather, this Pokémon makes ice shards with its six tails and sprays them around to cool itself off."     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:POWDERSNOW],[4,:TAILWHIP],[7,:ROAR],
          [9,:BABYDOLLEYES],[10,:ICESHARD],[12,:CONFUSERAY],
          [15,:ICYWIND],[18,:PAYBACK],[20,:MIST],
          [23,:FEINTATTACK],[26,:HEX],[28,:AURORABEAM],
          [31,:EXTRASENSORY],[34,:SAFEGUARD],[36,:ICEBEAM],
          [39,:IMPRISON],[42,:BLIZZARD],[44,:GRUDGE],                        
          [47,:CAPTIVATE],[50,:SHEERCOLD]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:AGILITY,:CHARM,:DISABLE,:ENCORE,
          :EXTRASENSORY,:FLAIL,:FREEZEDRY,:HOWL,
          :HYPNOSIS,:MOONBLAST,:POWERSWAP,:SPITE,
          :SECRETPOWER,:TAILSLAP]
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
          :ROAR,:TOXIC,:HAIL,:HIDDENPOWER,:ICEBEAM,:BLIZZARD,:PROTECT,
          :RAINDANCE,:SAFEGUARD,:FRUSTRATION,:RETURN,:DOUBLETEAM,
          :FACADE,:REST,:ATTRACT,:ROUND,:PAYBACK,:AURORAVEIL,:PSYCHUP,
          :FROSTBREATH,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:DARKPULSE,
          :CONFIDE,
          # Move Tutors
          :AQUATAIL,:COVET,:FOULPLAY,:HEALBELL,:ICYWIND,:IRONTAIL,
          :PAINSPLIT,:ROLEPLAY,:SNORE,:SPITE,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:SNOWBALL),0]     # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:SNOWCLOAK)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SNOWWARNING)  
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:SNOWCLOAK) if check==0
        next getID(PBAbilities,:SNOWWARNING) if check==1
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

MultipleForms.register(:NINETALES,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Possessing a calm demeanor, this Pokémon was revered as a deity incarnate before it was identified as a regional variant of Ninetales."     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FAIRY)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:DAZZLINGGLEAM],[1,:IMPRISON],[1,:NASTYPLOT],
          [1,:ICEBEAM],[1,:ICESHARD],[1,:CONFUSERAY],
          [1,:SAFEGUARD]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :PSYCHOCK,:CALMMIND,:ROAR,:TOXIC,:HAIL,:HIDDENPOWER,
          :ICEBEAM,:BLIZZARD,:HYPERBEAM,:PROTECT,:RAINDANCE,
          :SAFEGUARD,:FRUSTRATION,:RETURN,:DOUBLETEAM,:FACADE,
          :REST,:ATTRACT,:ROUND,:PAYBACK,:GIGAIMPACT,:AURORAVEIL,
          :PSYCHUP,:FROSTBREATH,:DREAMEATER,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:DARKPULSE,:DAZZLINGGLEAM,:CONFIDE,
          # Move Tutors
          :AQUATAIL,:COVET,:FOULPLAY,:HEALBELL,:ICYWIND,:IRONTAIL,
          :LASERFOCUS,:PAINSPLIT,:ROLEPLAY,:SNORE,:SPITE,
          :WONDERROOM,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:SNOWBALL),0]     # Alola
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
        next getID(PBAbilities,:SNOWCLOAK)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SNOWWARNING)  
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:SNOWCLOAK) if check==0
        next getID(PBAbilities,:SNOWWARNING) if check==1
      end
    },
    
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:DIGLETT,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Its head sports an altered form of whiskers made of metal. When in communication with its comrades, its whiskers wobble to and fro."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 10                      # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:SANDATTACK],[1,:METALCLAW],[4,:GROWL],
          [7,:ASTONISH],[10,:MUDSLAP],[14,:MAGNITUDE],
          [18,:BULLDOZE],[22,:SUCKERPUNCH],[25,:MUDBOMB],
          [28,:EARTHPOWER],[31,:DIG],[35,:IRONHEAD],
          [39,:EARTHQUAKE],[43,:FISSURE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:ANCIENTPOWER,:BEATUP,:ENDURE,:FEINTATTACK,
          :FINALGAMBIT,:HEADBUTT,:MEMENTO,:METALSOUND,
          :PURSUIT,:REVERSAL,:FLASH]
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
          :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:FRUSTRATION,
          :EARTHQUAKE,:RETURN,:DOUBLETEAM,:SLUDGEBOMB,:SANDSTORM,
          :ROCKTOMB,:AERIALACE,:FACADE,:REST,:ATTRACT,:THIEF,:ROUND,
          :ECHOEDVOICE,:SHADOWCLAW,:BULLDOZE,:ROCKSLIDE,:SWAGGER,
          :SLEEPTALK,:SUBSTITUTE,:FLASHCANNON,:CONFIDE,:SLASHANDBURN,
          # Move Tutors
          :EARTHPOWER,:IRONDEFENSE,:IRONHEAD,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [10,55,30,90,35,40]     # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Alola
        next getID(PBAbilities,:TANGLINGHAIR) 
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[97,116,403,404]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:DUGTRIO,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Its shining gold hair provides it with protection. It’s reputed that keeping any of its fallen hairs will bring bad luck."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 666                     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:SANDTOMB],[1,:ROTOTILLER],[1,:NIGHTSLASH],
          [1,:TRIATTACK],[1,:SANDATTACK],[1,:METALCLAW],[1,:GROWL],
          [4,:GROWL],[7,:ASTONISH],[10,:MUDSLAP],[14,:MAGNITUDE],
          [18,:BULLDOZE],[22,:SUCKERPUNCH],[25,:MUDBOMB],
          [30,:EARTHPOWER],[35,:DIG],[41,:IRONHEAD],
          [47,:EARTHQUAKE],[53,:FISSURE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,:PROTECT,
          :FRUSTRATION,:EARTHQUAKE,:RETURN,:DOUBLETEAM,:SLUDGEWAVE,
          :SLUDGEBOMB,:SANDSTORM,:ROCKTOMB,:AERIALACE,:FACADE,:REST,
          :ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,:SHADOWCLAW,:GIGAIMPACT,
          :STONEEDGE,:BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:FLASHCANNON,:CONFIDE,:SLASHANDBURN,
          # Move Tutors
          :EARTHPOWER,:IRONDEFENSE,:IRONHEAD,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
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
        next getID(PBAbilities,:TANGLINGHAIR) 
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MEOWTH,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "When its delicate pride is wounded, or when the gold coin on its forehead is dirtied, it flies into a hysterical rage." if pokemon.form==1  # Alola
      next "These daring Pokémon have coins on their foreheads. Darker coins are harder, and harder coins garner more respect among Meowth." # Galarian
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK) if pokemon.form==1   # Alola
      next getID(PBTypes,:STEEL)    # GALAR
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK) if pokemon.form==1   # Alola
      next getID(PBTypes,:STEEL)    # Galar
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alolan and Galarian
      when 1 ; movelist=[[1,:SCRATCH],[1,:GROWL],[6,:BITE],
          [9,:FAKEOUT],[14,:FURYSWIPES],[17,:SCREECH],
          [22,:FEINTATTACK],[25,:TAUNT],[30,:PAYDAY],
          [33,:SLASH],[38,:NASTYPLOT],[41,:ASSURANCE],
          [46,:CAPTIVATE],[49,:NIGHTSLASH],[50,:FEINT],
          [55,:DARKPULSE]]
      when 2 ; movelist=[[1,:FAKEOUT],[1,:GROWL],[4,:HONECLAWS],
          [8,:SCRATCH],[12,:PAYDAY],[16,:METALCLAW],
          [20,:TAUNT],[24,:SWAGGER],[29,:FURYSWIPES],
          [32,:SCREECH],[36,:SLASH],[40,:METALSOUND],
          [44,:THRASH]]  
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alolan and Galarian
      when 1 ; eggmovelist=[:AMNESIA,:ASSIST,:CHARM,:COVET,:FLAIL,:FLATTER,
          :FOULPLAY,:HYPNOSIS,:PARTINGSHOT,:PUNISHMENT,
          :SNATCH,:SPITE]
      when 2 ; eggmovelist=[:COVET,:FLAIL,:SPITE,:DOUBLEEDGE,:CURSE,:NIGHTSLASH]
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
          :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:PROTECT,
          :RAINDANCE,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,
          :SHADOWBALL,:DOUBLETEAM,:AERIALACE,:TORMENT,:FACADE,:REST,
          :ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,:QUASH,:EMBARGO,
          :SHADOWCLAW,:PAYBACK,:PSYCHUP,:DREAMEATER,:SWAGGER,
          :SLEEPTALK,:UTURN,:SUBSTITUTE,:DARKPULSE,:CONFIDE,
          # Move Tutors
          :COVET,:FOULPLAY,:GUNKSHOT,:HYPERVOICE,:ICEWIND,:IRONTAIL,
          :KNOCKOFF,:LASTRESORT,:SEEDBOMB,:SHOCKWAVE,:SNATCH,:SNORE,
          :SPITE,:THROATCHOP,:UPROAR,:WATERPULSE]
    when 2; movelist=[:TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:PROTECT,
          :RAINDANCE,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,
          :SHADOWBALL,:DOUBLETEAM,:AERIALACE,:TORMENT,:FACADE,:REST,:GYROBALL,
          :ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,:SWORDSDANCE,:QUASH,:EMBARGO,
          :SHADOWCLAW,:PAYBACK,:PSYCHUP,:DREAMEATER,:SWAGGER,
          :SLEEPTALK,:UTURN,:SUBSTITUTE,:DARKPULSE,:CONFIDE,
          # Move Tutors
          :COVET,:CRUNCH,:FOULPLAY,:GUNKSHOT,:IRONDEFENSE,:HYPERVOICE,:ICEWIND,:IRONTAIL,
          :KNOCKOFF,:LASTRESORT,:SEEDBOMB,:SHOCKWAVE,:SNATCH,:SNORE,:AMNESIA,:PAYDAY,
          :SPITE,:THROATCHOP,:UPROAR,:WATERPULSE]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
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
          next getID(PBAbilities,:RATTLED)
        end
      when 2
        if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Galar
          next getID(PBAbilities,:TOUGHCLAWS)    
        end
      end
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[1,0,53]] if pokemon.form==1                                    # Alola    [Happiness,,Persian]  
      next [[4,28,863]] if pokemon.form==2                        # Galar    [Level,28,Perrserker]   
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      aMaps=[24,82,91,390,391]   # Map IDs for second form
      gMaps=[97,238]
      # Map IDs for alolan and galarian forms respectively
      if $game_map && aMaps.include?($game_map.map_id)
        next 1
      elsif $game_map && gMaps.include?($game_map.map_id)
        next 2
      else
        next 0
      end
    }
  })

MultipleForms.register(:PERSIAN,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It looks down on everyone other than itself. Its preferred tactics are sucker punches and blindside attacks."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 11                      # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 330                     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:SWIFT],[1,:QUASH],[1,:PLAYROUGH],[1,:SWITCHEROO],
          [1,:SCRATCH],[1,:GROWL],[1,:BITE],[1,:FAKEOUT],[6,:BITE],                        
          [9,:FAKEOUT],[14,:FURYSWIPES],[17,:SCREECH],
          [22,:FEINTATTACK],[25,:TAUNT],[32,:POWERGEM],
          [37,:SLASH],[44,:NASTYPLOT],[49,:ASSURANCE],
          [56,:CAPTIVATE],[61,:NIGHTSLASH],[65,:FEINT],
          [69,:DARKPULSE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:ROAR,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,
          :HYPERBEAM,:PROTECT,:RAINDANCE,:FRUSTRATION,:THUNDERBOLT,
          :THUNDER,:RETURN,:SHADOWBALL,:DOUBLETEAM,:AERIALACE,:TORMENT,
          :FACADE,:REST,:ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,:QUASH,
          :EMBARGO,:SHADOWCLAW,:PAYBACK,:GIGAIMPACT,:PSYCHUP,
          :DREAMEATER,:SWAGGER,:SLEEPTALK,:UTURN,:SUBSTITUTE,:SNARL,
          :DARKPULSE,:CONFIDE,
          # Move Tutors
          :COVET,:FOULPLAY,:GUNKSHOT,:HYPERVOICE,:ICEWIND,:IRONTAIL,
          :KNOCKOFF,:LASTRESORT,:SEEDBOMB,:SHOCKWAVE,:SNATCH,:SNORE,
          :SPITE,:THROATCHOP,:UPROAR,:WATERPULSE]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
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
        next getID(PBAbilities,:FURCOAT)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:RATTLED)  
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[390,391]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:GEODUDE,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "If you accidentally step on a Geodude sleeping on the ground, you’ll hear a crunching sound and feel a shock ripple through your entire body."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 203                     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ELECTRIC)# Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:TACKLE],[1,:DEFENSECURL],[4,:CHARGE],
          [6,:ROCKPOLISH],[10,:ROLLOUT],[12,:SPARK],
          [16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
          [24,:SELFDESTRUCT],[28,:STEALTHROCK],[30,:ROCKBLAST],
          [34,:DISCHARGE],[36,:EXPLOSION],[40,:DOUBLEEDGE],
          [42,:STONEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:AUTOTOMIZE,:BLOCK,:COUNTER,:CURSE,:ENDURE,:FLAIL,
          :MAGNETRISE,:ROCKCLIMB,:SCREECH,:WIDEGUARD]
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
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:FRUSTRATION,
          :SMACKDOWN,:THUNDERBOLT,:THUNDER,:EARTHQUAKE,:RETURN,
          :BRICKBREAK,:DOUBLETEAM,:FLAMETHROWER,:SANDSTORM,
          :FIREBLAST,:ROCKTOMB,:FACADE,:REST,:ATTRACT,:ROUND,
          :FLING,:CHARGEBEAM,:BRUTALSWING,:EXPLOSION,:ROCKPOLISH,
          :STONEEDGE,:VOLTSWITCH,:GYROBALL,:BULLDOZE,:ROCKSLIDE,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:NATUREPOWER,:CONFIDE,
          # Move Tutors
          :BLOCK,:EARTHPOWER,:ELECTROWEB,:FIREPUNCH,:FOCUSPUNCH,
          :IRONDEFENSE,:MAGNETRISE,:SNORE,:STEALTHROCK,
          :SUPERPOWER,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:MAGNETPULL)  
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:GALVANIZE)       
      end
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:CELLBATTERY),0]  # Alola
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:GRAVELER,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "They eat rocks and often get into a scrap over them. The shock of Graveler smashing together causes a flash of light and a booming noise."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 1100                    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ELECTRIC)# Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:TACKLE],[1,:DEFENSECURL],[1,:CHARGE],[1,:ROCKPOLISH],
          [4,:CHARGE],[6,:ROCKPOLISH],[10,:ROLLOUT],[12,:SPARK],
          [16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
          [24,:SELFDESTRUCT],[30,:STEALTHROCK],[34,:ROCKBLAST],
          [40,:DISCHARGE],[44,:EXPLOSION],[50,:DOUBLEEDGE],
          [54,:STONEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:FRUSTRATION,
          :SMACKDOWN,:THUNDERBOLT,:THUNDER,:EARTHQUAKE,:RETURN,
          :BRICKBREAK,:DOUBLETEAM,:FLAMETHROWER,:SANDSTORM,
          :FIREBLAST,:ROCKTOMB,:FACADE,:REST,:ATTRACT,:ROUND,
          :FLING,:CHARGEBEAM,:BRUTALSWING,:EXPLOSION,:ROCKPOLISH,
          :STONEEDGE,:VOLTSWITCH,:GYROBALL,:BULLDOZE,:ROCKSLIDE,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:NATUREPOWER,:CONFIDE,
          # Move Tutors
          :ALLYSWITCH,:BLOCK,:EARTHPOWER,:ELECTROWEB,:FIREPUNCH,
          :FOCUSPUNCH,:IRONDEFENSE,:MAGNETRISE,:SHOCKWAVE,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM,:SUPERPOWER,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:MAGNETPULL)  
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:GALVANIZE)       
      end
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:CELLBATTERY),0]  # Alola
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[269,289,419,489,569]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:GOLEM,{
    "getMegaForm"=>proc{|pokemon|
      next 2 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0 if pokemon.form==2
      next
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Golem") if pokemon.form==2
      next
    },
    
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next "Because it can’t fire boulders at a rapid pace, it’s been known to seize nearby Geodude and fire them from its back."  # Alola
      when 2  # Rift
        next
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next
      when 2  # Rift
        next [100,100,150,10,100,150]
      end
    },
    "height"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next 17
      when 2  # Rift
        next
      end
    },
    "weight"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next 3160
      when 2  # Rift
        next 2560
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next
      when 2  # Rift
        next getID(PBTypes,:DARK)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next getID(PBTypes,:ELECTRIC)
      when 2  # Rift
        next getID(PBTypes,:FIGHTING)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:HEAVYSLAM],[1,:TACKLE],[1,:DEFENSECURL],[1,:CHARGE],
          [1,:ROCKPOLISH],[4,:CHARGE],[6,:ROCKPOLISH],[10,:STEAMROLLER],
          [12,:SPARK],[16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
          [24,:SELFDESTRUCT],[30,:STEALTHROCK],[34,:ROCKBLAST],
          [40,:DISCHARGE],[44,:EXPLOSION],[50,:DOUBLEEDGE],
          [54,:STONEEDGE],[60,:HEAVYSLAM]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :ROAR,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,:PROTECT,
          :FRUSTRATION,:SMACKDOWN,:THUNDERBOLT,:THUNDER,:EARTHQUAKE,
          :RETURN,:BRICKBREAK,:DOUBLETEAM,:FLAMETHROWER,:SANDSTORM,
          :FIREBLAST,:ROCKTOMB,:FACADE,:REST,:ATTRACT,:ROUND,
          :ECHOEDVOICE,:FOCUSBLAST,:FLING,:CHARGEBEAM,:BRUTALSWING,
          :EXPLOSION,:GIGAIMPACT,:ROCKPOLISH,:STONEEDGE,:VOLTSWITCH,
          :GYROBALL,:BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:WILDCHARGE,:NATUREPOWER,:CONFIDE,
          # Move Tutors
          :ALLYSWITCH,:BLOCK,:EARTHPOWER,:ELECTROWEB,:FIREPUNCH,
          :FOCUSPUNCH,:IRONDEFENSE,:MAGNETRISE,:SHOCKWAVE,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM,:SUPERPOWER,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Alola
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:MAGNETPULL)  
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:STURDY)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
          next getID(PBAbilities,:GALVANIZE)       
        end
      when 2 # Rift
        next getID(PBAbilities,:CONTRARY)
      end  
    },
    "wildHoldItems"=>proc{|pokemon|
      case pokemon.form
      when 0
        next          # Normal
      when 1
        next [0,0,getID(PBItems,:CELLBATTERY)]  # Alola
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:GRIMER,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "The crystals on Grimer’s body are lumps of toxins. If one falls off, lethal poisons leak out."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 7                       # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 420                    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:POUND],[1,:POISONGAS],[4,:HARDEN],[7,:BITE],
          [12,:DISABLE],[15,:ACIDSPRAY],[18,:POISONFANG],
          [21,:MINIMIZE],[26,:FLING],[29,:KNOCKOFF],[32,:CRUNCH],
          [37,:SCREECH],[40,:GUNKSHOT],[43,:ACIDARMOR],
          [46,:BELCH],[48,:MEMENTO]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:ASSURANCE,:CLEARSMOG,:CURSE,:IMPRISON,:MEANLOOK,
          :PURSUIT,:SCARYFACE,:SHADOWSNEAK,:SPITE,
          :SPITUP,:STOCKPILE,:SWALLOW,:POWERUPPUNCH]
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
          :TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:PROTECT,
          :RAINDANCE,:FRUSTRATION,:RETURN,:SHADOWBALL,:DOUBLETEAM,
          :SLUDGEWAVE,:FLAMETHROWER,:SLUDGEBOMB,:FIREBLAST,:ROCKTOMB,
          :TORMENT,:FACADE,:REST,:ATTRACT,:THIEF,:ROUND,:FLING,
          :BRUTALSWING,:QUASH,:EMBARGO,:EXPLOSION,:PAYBACK,
          :ROCKPOLISH,:STONEEDGE,:ROCKSLIDE,:INFESTATION,:POISONJAB,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:SNARL,:CONFIDE,
          # Move Tutors
          :FIREPUNCH,:GASTROACID,:GIGADRAIN,:GUNKSHOT,:ICEPUNCH,
          :KNOCKOFF,:PAINSPLIT,:SHOCKWAVE,:SNORE,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:POISONTOUCH) 
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:GLUTTONY)     
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:POWEROFALCHEMY)       
      end
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[64,66,138]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MUK,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal
      next "While it’s unexpectedly quiet and friendly, if it’s not fed any trash for a while, it will smash its Trainer’s furnishings and eat up the fragments."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal/PULSE
      next 10                      # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal/PULSE
      next 520                     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal/PULSE
      next getID(PBTypes,:DARK)    # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal/PULSE
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:VENOMDRENCH],[1,:POUND],[1,:POISONGAS],[1,:HARDEN],
          [1,:BITE],[4,:HARDEN],[7,:BITE],[12,:DISABLE],[15,:ACIDSPRAY],
          [18,:POISONFANG],[21,:MINIMIZE],[26,:FLING],[29,:KNOCKOFF],
          [32,:CRUNCH],[37,:SCREECH],[40,:GUNKSHOT],[46,:ACIDARMOR],                        
          [52,:BELCH],[57,:MEMENTO]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:HYPERBEAM,
          :PROTECT,:RAINDANCE,:FRUSTRATION,:RETURN,:SHADOWBALL,
          :BRICKBREAK,:DOUBLETEAM,:SLUDGEWAVE,:FLAMETHROWER,
          :SLUDGEBOMB,:FIREBLAST,:ROCKTOMB,:TORMENT,:FACADE,:REST,
          :ATTRACT,:THIEF,:ROUND,:FOCUSBLAST,:FLING,:BRUTALSWING,
          :QUASH,:EMBARGO,:EXPLOSION,:PAYBACK,:GIGAIMPACT,:ROCKPOLISH,
          :STONEEDGE,:ROCKSLIDE,:INFESTATION,:POISONJAB,:SWAGGER,
          :SLEEPTALK,:SUBSTITUTE,:SNARL,:DARKPULSE,:CONFIDE,
          # Move Tutors
          :BLOCK,:FIREPUNCH,:FOCUSPUNCH,:GASTROACID,:GIGADRAIN,
          :GUNKSHOT,:ICEPUNCH,:KNOCKOFF,:PAINSPLIT,:RECYCLE,
          :SHOCKWAVE,:SNORE,:SPITE,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
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
      next getID(PBAbilities,:PROTEAN) if pokemon.form==2 # PULSE
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:POISONTOUCH) 
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:GLUTTONY)     
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:POWEROFALCHEMY)       
      end   
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[64,66,138]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:EXEGGUTOR,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "As it grew taller and taller, it outgrew its reliance on psychic powers, while within it awakened the power of the sleeping dragon."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 109                     # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 4156                    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DRAGON)  # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:DRAGONHAMMER],[1,:SEEDBOMB],[1,:BARRAGE],
          [1,:HYPNOSIS],[1,:CONFUSION],[17,:PSYSHOCK],
          [27,:EGGBOMB],[37,:WOODHAMMER],[47,:LEAFSTORM]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :PSYSHOCK,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,
          :LIGHTSCREEN,:PROTECT,:FRUSTRATION,:SOLARBEAM,
          :EARTHQUAKE,:RETURN,:PSYCHIC,:BRICKBREAK,:DOUBLETEAM,
          :REFLECT,:FLAMETHROWER,:SLUDGEBOMB,:FACADE,:REST,:ATTRACT,
          :THIEF,:ROUND,:ENERGYBALL,:BRUTALSWING,:EXPLOSION,
          :GIGAIMPACT,:SWORDSDANCE,:PSYCHUP,:BULLDOZE,:DRAGONTAIL,
          :INFESTATION,:DREAMEATER,:GRASSKNOT,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:TRICKROOM,:NATUREPOWER,:CONFIDE,
          # Move Tutors
          :BLOCK,:DRACOMETEOR,:DRAGONPULSE,:GIGADRAIN,:GRAVITY,
          :IRONHEAD,:IRONTAIL,:KNOCKOFF,:LOWKICK,:OUTRAGE,:SEEDBOMB,
          :SKILLSWAP,:SNORE,:STOMPINGTANTRUM,:SUPERPOWER,:SYNTHESIS,
          :TELEKINESIS,:WORRYSEED,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
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
        next getID(PBAbilities,:FRISK)
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:FRISK) if check==0
        next getID(PBAbilities,:HARVEST) if check==1
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MAROWAK,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "The bones it possesses were once its mother’s. Its mother’s regrets have become like a vengeful spirit protecting this Pokémon."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 340                     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FIRE)    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:GHOST)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:GROWL],[1,:TAILWHIP],[1,:BONECLUB],[1,:FLAMEWHEEL],
          [3,:TAILWHIP],[7,:BONECLUB],[11,:FLAMEWHEEL],[13,:LEER],
          [17,:HEX],[21,:BONEMERANG],[23,:WILLOWISP],
          [27,:SHADOWBONE],[33,:THRASH],[37,:FLING],
          [43,:STOMPINGTANTRUM],[49,:ENDEAVOR],[53,:FLAREBLITZ],
          [59,:RETALIATE],[65,:BONERUSH]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:ICEBEAM,:BLIZZARD,:HYPERBEAM,
          :PROTECT,:RAINDANCE,:FRUSTRATION,:SMACKDOWN,:THUNDERBOLT,
          :THUNDER,:EARTHQUAKE,:RETURN,:SHADOWBALL,:BRICKBREAK,
          :DOUBLETEAM,:REFLECT,:FLAMETHROWER,:SANDSTORM,:FIREBLAST,
          :ROCKTOMB,:AERIALACE,:FACADE,:FLAMECHARGE,:REST,:ATTRACT,
          :THIEF,:ROUND,:ECHOEDVOICE,:FOCUSBLAST,:FALSESWIPE,
          :FLING,:BRUTALSWING,:WILLOWISP,:GIGAIMPACT,:STONEEDGE,
          :SWORDSDANCE,:BULLDOZE,:ROCKSLIDE,:DREAMEATER,:SWAGGER,
          :SLEEPTALK,:SUBSTITUTE,:DARKPULSE,:CONFIDE,:SLASHANDBURN,
          # Move Tutors
          :ALLYSWITCH,:EARTHPOWER,:ENDEAVOR,:FIREPUNCH,:FOCUSPUNCH,
          :HEATWAVE,:ICYWIND,:IRONDEFENSE,:IRONHEAD,:IRONTAIL,
          :KNOCKOFF,:LASERFOCUS,:OUTRAGE,:PAINSPLIT,:SNORE,:SPITE,
          :STEALTHROCK,:STOMPINGTANTRUM,:THROATCHOP,:THUNDERPUNCH,
          :UPROAR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:CURSEDBODY) 
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2) 
        next getID(PBAbilities,:ROCKHEAD)      
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:PONYTA,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "This Pokémon will look into your eyes and read the contents of your heart. If it finds evil there, it promptly hides away."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[357,358,359,360,368]  
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
      next getID(PBTypes,:PSYCHIC)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:PSYCHIC)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:TACKLE],[1,:GROWL],[5,:TAILWHIP],
          [10,:CONFUSION],[15,:FAIRYWIND],
          [20,:AGILITY],[25,:PSYBEAM],[30,:STOMP],
          [35,:HEALPULSE],[41,:TAKEDOWN],[45,:DAZZLINGGLEAM],
          [50,:PSYCHIC],[55,:HEALINGWISH]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
    next if pokemon.form==0 
    movelist=[]
    case pokemon.form
    when 1; movelist=[# TMs
        :HIDDENPOWER,:TOXIC,:REST,:SNORE,:PROTECT,:CHARM,:ATTRACT,:FACADE,
        :SWIFT,:IMPRISON,:BOUNCE,:ROUND,:MYSTICALFIRE,:BODYSLAM,
        :LOWKICK,:PSYCHIC,:AGILITY,:SUBSTITUTE,
        :ENDURE,:SLEEPTALK,:IRONTAIL,:FUTURESIGHT,:CALMMIND,:ZENHEADBUTT,
        :STOREDPOWER,:ALLYSWITCH,:WILDCHARGE,:PLAYROUGH,:DAZZLINGGLEAM,
        :HIGHHORSEPOWER,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:DARKPULSE,
        :CONFIDE]
    end
    for i in 0...movelist.length
      movelist[i]=getConst(PBMoves,movelist[i])
    end
    next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:PASTELVEIL)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:ANTICIPATION)  
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:RAPIDASH,{
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
      next getID(PBTypes,:PSYCHIC)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FAIRY)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[0,:PSYCHOCUT],[1,:PSYCHOCUT],[1,:MEGAHORN],
          [1,:TACKLE],[1,:QUICKATTACK],[1,:GROWL],
          [1,:TAILWHIP],[1,:CONFUSION],[15,:FAIRYWIND],
          [20,:AGILITY],[25,:PSYBEAM],[30,:STOMP],
          [35,:HEALPULSE],[43,:TAKEDOWN],[49,:DAZZLINGGLEAM],
          [56,:PSYCHIC],[63,:HEALINGWISH]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
    next if pokemon.form==0 
    movelist=[]
    case pokemon.form
    when 1; movelist=[# TMs
        :HIDDENPOWER,:TOXIC,:REST,:SNORE,:PROTECT,:CHARM,:ATTRACT,:FACADE,
        :SWIFT,:IMPRISON,:BOUNCE,:ROUND,:MYSTICALFIRE,:BODYSLAM,:SMARTSTRIKE,:MEGAHORN,
        :LOWKICK,:PSYCHIC,:AGILITY,:SUBSTITUTE,:MISTYTERRAIN,:PSYCHICTERRAIN,
        :ENDURE,:SLEEPTALK,:IRONTAIL,:FUTURESIGHT,:CALMMIND,:ZENHEADBUTT,:BOUNCE,:THROATCHOP,
        :STOREDPOWER,:ALLYSWITCH,:WILDCHARGE,:PLAYROUGH,:DAZZLINGGLEAM,
        :HIGHHORSEPOWER,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:DARKPULSE,
        :CONFIDE]
    end
    for i in 0...movelist.length
      movelist[i]=getConst(PBMoves,movelist[i])
    end
    next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:PASTELVEIL)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:ANTICIPATION)  
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:FARFETCHD,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "The stalks of leeks are thicker and longer in the Galar region. Farfetch'd that adapted to these stalks took on a unique form."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[245]  
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
      next getID(PBTypes,:FIGHTING)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FIGHTING)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:PECK],[1,:SANDATTACK],[5,:LEER],
          [10,:FURYCUTTER],[15,:ROCKSMASH],
          [20,:BRUTALSWING],[25,:DETECT],[30,:KNOCKOFF],
          [35,:DEFOG],[40,:BRICKBREAK],[45,:SWORDSDANCE],
          [50,:SLAM],[55,:LEAFBLADE],[60,:FINALGAMBIT],
          [65,:BRAVEBIRD]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 
      movelist=[]
      case pokemon.form
      when 1; movelist=[#TMs
			:WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:SECRETPOWER,
			:FRUSTRATION,:RETURN,:BRICKBREAK,:DOUBLETEAM,:FACADE,:REST,
			:ATTRACT,:ROUND,:STEELWING,:SWORDSDANCE,:POISONJAB,:SWAGGER,
			:SLEEPTALK,:SUBSTITUTE,:ROCKSMASH,:CONFIDE,:STACKINGSHOT,
			:SLASHANDBURN,:BRUTALSWING,:SOLARBLADE,:ASSURANCE,:RETALIATE,
			:CUT,
          # Move Tutors
			:SNORE,:HELPINGHAND,:COVET,:SKYATTACK,:THROATCHOP,:SUPERPOWER,
			:KNOCKOFF,:BODYSLAM,:FOCUSENERGY,:ENDURE,:LEAFBLADE,
			:CLOSECOMBAT,:BRAVEBIRD]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:QUICKATTACK,:FLAIL,:CURSE,:COVET,:NIGHTSLASH,
          :SIMPLEBEAM,:FEINT,:SKYATTACK,:COUNTER,:QUICKGUARD,
          :DOUBLEEDGE]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:STEADFAST)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:SCRAPPY)  
      end
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [getID(PBItems,:LEEK),0,0]   # Galarian
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[31,0,865]]                        # Galarian    [BattleCrits,3,Sirfetch'd]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:WEEZING,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Long ago, during a time when droves of factories fouled the air with pollution, Weezing changed into this form for some reason."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[257]  
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
      next getID(PBTypes,:POISON)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FAIRY)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[0,:DOUBLEHIT],[1,:DOUBLEHIT],[1,:STRANGESTEAM],
          [1,:DEFOG],[1,:HEATWAVE],[1,:SMOG],[1,:SMOKESCREEN],
          [1,:HAZE],[1,:POISONGAS],[1,:TACKLE],[1,:FAIRYWIND],
          [1,:AROMATICMIST],[12,:CLEARSMOG],[16,:ASSURANCE],
          [20,:SLUDGE],[24,:AROMATHERAPY],[28,:SELFDESTRUCT],
          [32,:SLUDGEBOMB],[38,:TOXIC],[44,:BELCH],[50,:EXPLOSION],
          [56,:MEMENTO],[62,:DESTINYBOND],[68,:MISTYTERRAIN]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:HYPERBEAM,
          :PROTECT,:RAINDANCE,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,
          :SHADOWBALL,:DOUBLETEAM,:FLAMETHROWER,:FIREBLAST,
          :TORMENT,:FACADE,:REST,:ATTRACT,:THIEF,:ROUND,
          :WILLOWISP,:EXPLOSION,:PAYBACK,:GIGAIMPACT,:GYROBALL,
          :INFESTATION,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:DARKPULSE,
          :CONFIDE,
          # Move Tutors
          :PAINSPLIT,:SHOCKWAVE,:SPITE,:UPROAR,:WONDERROOM,:MISTYTERRAIN,:BRUTALSWING,
          :OVERHEAT,:PLAYROUGH,:DAZZLINGGLEAM,:DEFOG,:TOXICSPIKES,:PLAYROUGH,:VENOMDRENCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:MISTYSURGE)  
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:CORSOLA,{
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
      next getID(PBTypes,:GHOST)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:GHOST)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:TACKLE],[1,:HARDEN],[5,:WATERGUN],[10,:AQUARING],
          [15,:ENDURE],[20,:ANCIENTPOWER],[25,:BUBBLEBEAM],
          [30,:FLAIL],[35,:LIFEDEW],[40,:POWERGEM],
          [45,:EARTHPOWER],[50,:RECOVER],[55,:MIRRORCOAT]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
	"getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
			:CALMMIND,:ROAR,:TOXIC,:HAIL,:HIDDENPOWER,:SUNNYDAY,
			:ICEBEAM,:BLIZZARD,:LIGHTSCREEN,:PROTECT,:RAINDANCE,
			:SECRETPOWER,:SAFEGUARD,:FRUSTRATION,:EARTHQUAKE,:RETURN,
			:DIG,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:REFLECT,:SLUDGEBOMB,
			:SANDSTORM,:FIREBLAST,:ROCKTOMB,:FACADE,:REST,:ATTRACT,
			:ROUND,:SCALD,:WILLOWISP,:EXPLOSION,:STONEEDGE,:BULLDOZE,
			:ROCKSLIDE,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:ROCKSMASH,
			:NATUREPOWER,:CONFIDE,:IRRITATION,:SELFDESTRUCT,:WHIRLPOOL,
			:ICICLESPEAR,:ROCKBLAST,:BRINE,:HEX,:SURF,
			#Move Tutors
			:SNORE,:SPITE,:GIGADRAIN,:GRAVITY,:STEALTHROCK,
			:IRONDEFENSE,:WATERPULSE,:ICYWIND,:LIQUIDATION,:FOULPLAY,
			:THROATCHOP,:STOMPINGTANTRUM,:EARTHPOWER,:BODYSLAM,
			:HYDROPUMP,:AMNESIA,:ENDURE,:POWERGEM]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:CONFUSERAY,:NATUREPOWER,:WATERPULSE,:HEADSMASH,:HAZE,
          :DESTINYBOND]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:WEAKARMOR)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:CURSEDBODY)  
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

MultipleForms.register(:ZIGZAGOON,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Thought to be the oldest form of Zigzagoon, it moves in zigzags and wreaks havoc upon its surroundings."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[12,95]  
      # Map IDs for Galariann form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:NORMAL)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:TACKLE],[1,:LEER],[3,:SANDATTACK],[6,:LICK],
          [9,:SNARL],[12,:HEADBUTT],[15,:BABYDOLLEYES],
          [18,:PINMISSILE],[21,:REST],[24,:TAKEDOWN],
          [27,:SCARYFACE],[30,:COUNTER],[33,:TAUNT],
          [36,:DOUBLEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
			:WORKUP,:ROAR,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,
			:ICEBEAM,:BLIZZARD,:PROTECT,:RAINDANCE,:SECRETPOWER,
			:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,:DIG,
			:SHADOWBALL,:DOUBLETEAM,:FACADE,:REST,:ATTRACT,:ROUND,
			:FLING,:PAYBACK,:THUNDERWAVE,:GRASSKNOT,:SWAGGER,
			:SLEEPTALK,:SUBSTITUTE,:ROCKSMASH,:SNARL,:CONFIDE,
			:PINMISSILE,:SCREECH,:SCARYFACE,:FAKETEARS,:MUDSHOT,
			:ASSURANCE,:RETALIATE,:CUT,:SURF,
			# Move Tutors
			:SNORE,:HELPINGHAND,:IRONTAIL,:ICYWIND,:SEEDBOMB,
			:TRICK,:SUPERFANG,:HYPERVOICE,:KNOCKOFF,:BODYSLAM,
			:ENDURE]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:PARTINGSHOT,:QUICKGUARD,:KNOCKOFF]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:LINOONE,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "This very aggressive Pokémon will recklessly challenge opponents stronger than itself."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[12,95]  
      # Map IDs for Galarian form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:NORMAL)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[0,:NIGHTSLASH],[1,:NIGHTSLASH],[1,:SWITCHEROO],
          [1,:PINMISSILE],[1,:BABYDOLLEYES],[1,:TACKLE],
          [1,:LEER],[1,:SANDATTACK],[1,:LICK],
          [9,:SNARL],[12,:HEADBUTT],[15,:HONECLAWS],
          [18,:FURYSWIPES],[23,:REST],[28,:TAKEDOWN],
          [33,:SCARYFACE],[38,:COUNTER],[43,:TAUNT],
          [48,:DOUBLEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
			:WORKUP,:ROAR,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,
			:ICEBEAM,:BLIZZARD,:HYPERBEAM,:PROTECT,:RAINDANCE,
			:SECRETPOWER,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,
			:DIG,:SHADOWBALL,:DOUBLETEAM,:FACADE,:REST,:ATTRACT,
			:ROUND,:FLING,:SHADOWCLAW,:PAYBACK,:GIGAIMPACT,:THUNDERWAVE,
			:GRASSKNOT,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:ROCKSMASH,
			:SNARL,:CONFIDE,:ROCKCLIMB,:POISONSWEEP,:SLASHANDBURN,
			:PINMISSILE,:SCREECH,:SCARYFACE,:FAKETEARS,:MUDSHOT,
			:ASSURANCE,:HONECLAWS,:RETALIATE,:CUT,:SURF,:STRENGTH,
			# Move Tutors
			:SNORE,:HELPINGHAND,:IRONTAIL,:ICYWIND,:SEEDBOMB,
			:TRICK,:SUPERFANG,:THROATCHOP,:STOMPINGTANTRUM,:GUNKSHOT,
			:HYPERVOICE,:KNOCKOFF,:BODYSLAM,:ENDURE,:BODYPRESS]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
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

MultipleForms.register(:DARUMAKA,{
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
      next getID(PBTypes,:ICE) if pokemon.form==2    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE) if pokemon.form==2  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 2 ; movelist=[[1,:POWDERSNOW],[1,:TACKLE],[4,:TAUNT],[8,:BITE],
          [12,:AVALANCHE],[16,:WORKUP],[20,:ICEFANG],[24,:HEADBUTT],
          [28,:ICEPUNCH],[32,:UPROAR],[36,:BELLYDRUM],
          [40,:BLIZZARD],[44,:THRASH],[48,:SUPERPOWER]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
			:WORKUP,:TOXIC,:BULKUP,:HIDDENPOWER,:SUNNYDAY,:TAUNT,
			:ICEBEAM,:BLIZZARD,:PROTECT,:SECRETPOWER,:FRUSTRATION,
			:SOLARBEAM,:RETURN,:DIG,:BRICKBREAK,:DOUBLETEAM,
			:FLAMETHROWER,:FIREBLAST,:ROCKTOMB,:FACADE,:FLAMECHARGE,
			:REST,:ATTRACT,:THIEF,:ROUND,:OVERHEAT,:FLING,:INCINERATE,
			:WILLOWISP,:GYROBALL,:ROCKSLIDE,:GRASSKNOT,:SWAGGER,
			:SLEEPTALK,:UTURN,:SUBSTITUTE,:POWERUPPUNCH,:CONFIDE,
			:STACKINGSHOT,:LAVASURF,:MEGAPUNCH,:MEGAKICK,:FIRESPIN,
			:ICEFANG,:FIREFANG,:AVALANCHE,:STRENGTH,
			# Move Tutors
			:SNORE,:UPROAR,:FIREPUNCH,:ICEPUNCH,:FOCUSPUNCH,
			:ZENHEADBUTT,:HEATWAVE,:SUPERPOWER,:FOCUSENERGY,
			:ENDURE,:ENCORE,:FLAREBLITZ]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 2 ; eggmovelist=[:FOCUSPUNCH,:HAMMERARM,:TAKEDOWN,:FLAMEWHEEL,:YAWN,
          :FREEZEDRY,:INCINERATE,:POWERUPPUNCH]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[7,652,555]] if pokemon.form==2    # Galarian    [Item,Ice Stone,Darmanitan]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:YAMASK,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It's said that this Pokémon was formed when an ancient clay tablet was drawn to a vengeful spirit."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[489,508]  
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
      next getID(PBTypes,:GROUND)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:GHOST)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:ASTONISH],[1,:PROTECT],[4,:HAZE],[8,:NIGHTSHADE],
          [10,:DISABLE],[14,:BRUTALSWING],[16,:CRAFTYSHIELD],
          [20,:HEX],[24,:MEANLOOK],[28,:SLAM],[32,:CURSE],
          [36,:SHADOWBALL],[40,:EARTHQUAKE],[44,:POWERSPLIT],
          [48,:GUARDSPLIT],[52,:DESTINYBOND]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
			:CALMMIND,:TOXIC,:HIDDENPOWER,:PROTECT,:RAINDANCE,:SECRETPOWER,
			:SAFEGUARD,:FRUSTRATION,:EARTHQUAKE,:RETURN,:PSYCHIC,
			:SHADOWBALL,:DOUBLETEAM,:SANDSTORM,:ROCKTOMB,:FACADE,
			:REST,:ATTRACT,:THIEF,:ROUND,:ENERGYBALL,:WILLOWISP,:PAYBACK,
			:BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:TRICKROOM,
			:CONFIDE,:ARENITEWALL,:IRRITATION,:BRUTALSWING,:FAKETEARS,:HEX,
			# Move Tutors
			:SNORE,:BLOCK,:ALLYSWITCH,:GRAVITY,:IRONDEFENSE,:PAINSPLIT,
			:ZENHEADBUTT,:TRICK,:MAGICCOAT,:WONDERROOM,:SKILLSWAP,:EARTHPOWER,
			:ENDURE,:TOXICSPIKES,:NASTYPLOT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:MEMENTO]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      next getID(PBAbilities,:WANDERINGSPIRIT) # Galar
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[32,0,867]]                       # Galarian    [TakeDamage,49,Runerigas]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:STUNFISK,{
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
      next getID(PBTypes,:GROUND)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:MUDSLAP],[1,:TACKLE],[1,:WATERGUN],[1,:METALCLAW],
          [5,:ENDURE],[10,:MUDSHOT],[15,:REVENGE],[20,:METALSOUND],
          [25,:SUCKERPUNCH],[30,:IRONDEFENSE],[35,:BOUNCE],
          [40,:MUDDYWATER],[45,:SNAPTRAP],[50,:FLAIL],[55,:FISSURE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 
      movelist=[]
      case pokemon.form
      when 1; movelist=[#TMs
			:TOXIC,:HIDDENPOWER,:PROTECT,:RAINDANCE,:SECRETPOWER,
			:FRUSTRATION,:EARTHQUAKE,:RETURN,:DIG,:DOUBLETEAM,:SLUDGEWAVE,
			:SLUDGEBOMB,:SANDSTORM,:ROCKTOMB,:FACADE,:REST,:ATTRACT,
			:ROUND,:SCALD,:PAYBACK,:STONEEDGE,:THUNDERWAVE,:BULLDOZE,
			:ROCKSLIDE,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:FLASHCANNON,
			:CONFIDE,:ARENITEWALL,:IRRITATION,:MUDSHOT,:ICEFANG,:SUCKERPUNCH,
			:SURF,
			#Move Tutors
			:SNORE,:UPROAR,:BIND,:HELPINGHAND,:SPITE,:STEALTHROCK,
			:IRONDEFENSE,:BOUNCE,:PAINSPLIT,:FOULPLAY,:STOMPINGTANTRUM,
			:EARTHPOWER,:ENDURE,:CRUNCH,:MUDDYWATER]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:YAWN,:ASTONISH,:CURSE,:SPITE,:PAINSPLIT,:REFLECTTYPE,:BIND,:COUNTER]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      next getID(PBAbilities,:MIMICRY)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[221]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MRMIME,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It can radiate chilliness from the bottoms of its feet. It'll spend the whole day tap-dancing on a frozen floor."     # Galarian
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
      next 1.4 if pokemon.form==1 # Galarian
      next
    },
    "weight"=>proc{|pokemon|
      next 56.8 if pokemon.form==1 # Galarian
      next
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [0,0,0,2,0,0]           # Galarian
    },
    "getBaseStats"=>proc{|pokemon|
      next [50,65,65,100,90,90] if pokemon.form==1 # Galarian
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:ICE) if pokemon.form==1 # Galar
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:PSYCHIC) if pokemon.form==1 # Galar
      next
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:COPYCAT],[1,:ENCORE],[1,:ROLEPLAY],[1,:PROTECT],
          [1,:RECYCLE],[1,:MIMIC],[1,:LIGHTSCREEN],[1,:REFLECT],
          [1,:SAFEGUARD],[1,:DAZZLINGGLEAM],[1,:MISTYTERRAIN],
          [1,:POUND],[1,:RAPIDSPIN],[1,:BATONPASS],[1,:ICESHARD],
          [12,:CONFUSION],[16,:ALLYSWITCH],[20,:ICYWIND],
          [24,:DOUBLEKICK],[28,:PSYBEAM],[32,:HYPNOSIS],
          [36,:MIRRORCOAT],[40,:SUCKERPUNCH],[44,:FREEZEDRY],
          [48,:PSYCHIC],[52,:TEETERDANCE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:FAKEOUT,:CONFUSERAY,:POWERSPLIT,:TICKLE]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
        next getID(PBAbilities,:VITALSPIRIT)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SCREENCLEANER)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:ICEBODY)  
      end
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[4,42,866]]                        # Galarian    [Level,42,Mr. Rime]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

# Aevian Variants

MultipleForms.register(:LAPRAS,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Normal
        next 
      when 2  # Aevian
        next "This unique Lapras was previously fossilized, but the strange energy the crystals in Amethyst cave seem to give off slowly revived it and altered its appearance."  # Aevian
      end
    },
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:LAPRASITE) || pokemon.isPreMega?
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0 if pokemon.form==1
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Lapras") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1
        next [130,135,105,90,70,105] 
      when 2  # Aevian
        next [135,95,80,60,85,85]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1 # Mega
        next
      when 2  # Aevian
        next getID(PBTypes,:ROCK)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1 # Mega
        next 
      when 2  # Aevian
        next getID(PBTypes,:PSYCHIC)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0  || pokemon.form==1     # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 2; movelist=[[1,:HARDEN],[1,:PSYWAVE],[5,:SING],[10,:ROCKPOLISH],
          [15,:GRAVITY],[20,:POWERGEM],[25,:CONFUSERAY],[30,:ROCKSLIDE],
          [35,:ZENHEADBUTT],[40,:BODYSLAM],[45,:PSYCHIC],[50,:SANDSTORM],
          [55,:MIRACLEEYE],[60,:PERISHSONG],[65,:STONEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0 || pokemon.form==1     # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 2 ; eggmovelist=[:ANCIENTPOWER,:CURSE,:DRAGONDANCE,:HEAVYSLAM,
          :ROCKTOMB,:TELEPORT]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 || pokemon.form==1
      movelist=[]
      case pokemon.form
      when 2; movelist=[# TMs
          :PSYSHOCK,:CALMMIND,:ROAR,:TOXIC,:HIDDENPOWER,:ICEBEAM,
          :BLIZZARD,:HYPERBEAM,:LIGHTSCREEN,:PROTECT,:SECRETPOWER,
          :SAFEGUARD,:FRUSTRATION,:SMACKDOWN,:EARTHQUAKE,:RETURN,
          :PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:REFLECT,:SANDSTORM,
          :ROCKTOMB,:FACADE,:REST,:ATTRACT,:ROUND,:ECHOEDVOICE,
          :FOCUSBLAST,:EXPLOSION,:GIGAIMPACT,:ROCKPOLISH,:FLASH,
          :STONEEDGE,:THUNDERWAVE,:GYROBALL,:BULLDOZE,:FROSTBREATH,
          :ROCKSLIDE,:DRAGONTAIL,:DREAMEATER,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:FLASHCANNON,:TRICKROOM,:ROCKSMASH,:NATUREPOWER,
          :DAZZLINGGLEAM,:CONFIDE,:ROCKCLIMB,:ARENITEWALL,:LAVASURF,
          :SMARTSTRIKE,:SCREECH,:SELFDESTRUCT,:CHARM,:WEATHERBALL,
          :ROCKBLAST,:POWERSWAP,:GUARDSWAP,:SPEEDSWAP,:PSYCHOCUT,
          :PSYCHICTERRAIN,:BREAKINGSWIPE,:AVALANCHE,:ZAPCANNON,
          :STRENGTH,
          # Move Tutors
          :SNORE,:HEALBELL,:UPROAR,:HELPINGHAND,:SHOCKWAVE,:BLOCK,
          :IRONTAIL,:AFTERYOU,:ALLYSWITCH,:GRAVITY,:STEALTHROCK,
          :IRONDEFENSE,:TELEKINESIS,:IRONHEAD,:ZENHEADBUTT,:DRILLRUN,
          :MAGICCOAT,:MAGICROOM,:WONDERROOM,:OUTRAGE,:STOMPINGTANTRUM,
          :EARTHPOWER,:HYPERVOICE,:DRAGONPULSE,:BODYSLAM,:AMNESIA,
          :ENDURE,:MEGAHORN,:ENCORE,:FUTURESIGHT,:COSMICPOWER,
          :DRAGONDANCE,:POWERGEM,:HEAVYSLAM,:PSYCHICFANGS,:BODYPRESS]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Mega
        next getID(PBAbilities,:HYDRATION) 
      when 2 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:SOLIDROCK)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:FOREWARN)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
          next getID(PBAbilities,:NOGUARD)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MAREEP,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "The cold climate of Neverwinter made Mareep's wool even thicker, making it a popular companion in the region."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [55,40,45,35,65,40]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:ICE)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:ELECTRIC)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 1 ; movelist=[[1,:TACKLE],[1,:HAIL],[4,:THUNDERWAVE],[8,:THUNDERSHOCK],
          [11,:COTTONSPORE],[15,:ICYWIND],[18,:TAKEDOWN],
          [22,:ICEBALL],[25,:CONFUSERAY],[29,:POWERGEM],
          [32,:DISCHARGE],[36,:COTTONGUARD],[39,:REST],[43,:REFLECT],
          [46,:THUNDER]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:AFTERYOU,:AGILITY,:BODYSLAM,:CHARGE,:EERIEIMPULSE,
          :ELECTRICTERRAIN,:FLATTER,:IRONTAIL,:FROSTBREATH,
          :SANDATTACK,:SCREECH,:TAKEDOWN]
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
          :TOXIC,:HAIL,:HIDDENPOWER,:ICEBEAM,:BLIZZARD,:PROTECT,
          :RAINDANCE,:SECRETPOWER,:SAFEGUARD,:FRUSTRATION,:THUNDERBOLT,
          :THUNDER,:DOUBLETEAM,:REFLECT,:FACADE,:REST,:ROUND,
          :ECHOEDVOICE,:CHARGEBEAM,:PAYBACK,:FLASH,:VOLTSWITCH,
          :THUNDERWAVE,:FROSTBREATH,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,
          :FLASHCANNON,:WILDCHARGE,:CONFIDE,:AURORAVEIL,:PAYDAY,
          :WEATHERBALL,:ICICLESPEAR,:GUARDSWAP,:EERIEIMPULSE,
          :AVALANCHE,:ZAPCANNON,
          # Move Tutors
          :SNORE,:HEALBELL,:ELECTROWEB,:SHOCKWAVE,:RECYCLE,:IRONTAIL,
          :AFTERYOU,:SIGNALBEAM,:MAGNETRISE,:ROLEPLAY,:WATERPULSE,
          :ENDEAVOR,:ICYWIND,:LASERFOCUS,:MAGICCOAT,:OUTRAGE,
          :SKILLSWAP,:DRAGONPULSE,:ENDURE,:POWERGEM,:ELECTROBALL]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:FILTER)
        elsif pokemon.abilityIndex!=0 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:COTTONDOWN)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:FLAAFFY,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "The frigid environment caused Flaaffy to not lose its fluffy coat upon evolution. Its horns and tail are warm to the touch due to the constant flow of electricity."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [70,55,60,45,80,50]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:ICE)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:ELECTRIC)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 1 ; movelist=[[1,:TACKLE],[1,:HAIL],[1,:THUNDERWAVE],[1,:THUNDERSHOCK],[4,:THUNDERWAVE],[8,:THUNDERSHOCK],[11,:COTTONSPORE],[16,:ICYWIND],[20,:TAKEDOWN],[25,:ICEBALL],[29,:CONFUSERAY],[34,:POWERGEM],[38,:DISCHARGE],[43,:COTTONGUARD],[47,:REST],[52,:REFLECT],[56,:THUNDER]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:HAIL,:HIDDENPOWER,:ICEBEAM,:BLIZZARD,:PROTECT,
          :RAINDANCE,:SECRETPOWER,:SAFEGUARD,:FRUSTRATION,
          :THUNDERBOLT,:THUNDER,:RETURN,:DOUBLETEAM,:REFLECT,:FACADE,
          :REST,:ROUND,:ECHOEDVOICE,:FLING,:CHARGEBEAM,:PAYBACK,
          :FLASH,:VOLTSWITCH,:THUNDERWAVE,:FROSTBREATH,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:FLASHCANNON,:WILDCHARGE,:ROCKSMASH,:CONFIDE,:AURORAVEIL,:MEGAPUNCH,:MEGAKICK,:PAYDAY,:BEATUP,:WEATHERBALL,:FAKETEARS,:ICICLESPEAR,:GUARDSWAP,:ELECTRICTERRAIN,:EERIEIMPULSE,:BREAKINGSWIPE,:AVALANCHE,:ZAPCANNON,:METRONOME,:DYNAMICPUNCH,:STRENGTH,
          # Move Tutors
          :SNORE,:HEALBELL,:ELECTROWEB,:SHOCKWAVE,:SNATCH,:RECYCLE,:IRONTAIL,:AFTERYOU,:SIGNALBEAM,:MAGNETRISE,:ROLEPLAY,:WATERPULSE,:ICEPUNCH,:THUNDERPUNCH,:ENDEAVOR,:ICYWIND,:LASERFOCUS,:MAGICCOAT,:OUTRAGE,:SKILLSWAP,:DRAGONPULSE,:AGILITY,:ENDURE,:POWERGEM,:ELECTROBALL]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:FILTER)
        elsif pokemon.abilityIndex!=0 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:COTTONDOWN)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })


MultipleForms.register(:MISDREAVUS,{
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
      when 1 ; movelist=[[1,:GROWL],[1,:VINEWHIP],[5,:POISONPOWDER],[10,:ASTONISH],
          [14,:CONFUSERAY],[19,:SNAPTRAP],[23,:HEX],[28,:GIGADRAIN],
          [32,:INGRAIN],[37,:GRUDGE],[41,:SHADOWBALL],
          [46,:PERISHSONG],[50,:POWERWHIP],[55,:POWERGEM]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:CURSE,:DESTINYBOND,:GROWTH,:MEFIRST,:MEMENTO,
          :NASTYPLOT,:CLEARSMOG,:SCREECH,:SHADOWSNEAK,:LIFEDEW,
          :TOXIC,:SUCKERPUNCH,:WONDERROOM]
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
          :WORKUP,:TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,
          :PROTECT,:RAINDANCE,:SECRETPOWER,:FRUSTRATION,:SOLARBEAM,
          :RETURN,:SHADOWBALL,:DOUBLETEAM,:AERIALACE,:FACADE,:REST,
          :ATTRACT,:ROUND,:ECHOEDVOICE,:ENERGYBALL,:QUASH,:WILLOWISP,
          :EMBARGO,:SWORDSDANCE,:PSYCHUP,:INFESTATION,:GRASSKNOT,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:NATUREPOWER,:CONFIDE,
          :LEECHLIFE,:PINMISSILE,:MAGICALLEAF,:SCREECH,:SCARYFACE,
          :BULLETSEED,:CROSSPOISON,:HEX,:PHANTOMFORCE,:DRAININGKISS,
          :SUCKERPUNCH,:CUT,
          # Move Tutors
          :SNORE,:HEALBELL,:UPROAR,:BIND,:WORRYSEED,:SNATCH,:SPITE,
          :GIGADRAIN,:SYNTHESIS,:ALLYSWITCH,:WATERPULSE,:PAINSPLIT,
          :SEEDBOMB,:LASERFOCUS,:TRICK,:MAGICROOM,:WONDERROOM,
          :GASTROACID,:THROATCHOP,:SKILLSWAP,:HYPERVOICE,:SPIKES,
          :ENDURE,:BATONPASS,:FUTURESIGHT,:LEAFBLADE,:TOXICSPIKES,
          :POWERGEM,:NASTYPLOT,:LEAFSTORM,:POWERWHIP,:VENOMDRENCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
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
      maps=[221]   # Map IDs for Aevian form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end   
    }
  })

MultipleForms.register(:MISMAGIUS,{
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
      when 1 ; movelist=[[1,:POISONJAB],[1,:POWERGEM],[1,:PHANTOMFORCE],[1,:LUCKYCHANT],[1,:MAGICALLEAF],[1,:GROWL],[1,:VINEWHIP],[1,:POISONPOWDER],[1,:ASTONISH],[0,:HEXINGSLASH]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:HYPERBEAM,:PROTECT,:RAINDANCE,:SECRETPOWER,:FRUSTRATION,:SOLARBEAM,:SMACKDOWN,:RETURN,:SHADOWBALL,:DOUBLETEAM,:SLUDGEWAVE,:ROCKTOMB,:AERIALACE,:FACADE,:REST,:ATTRACT,:ROUND,:ECHOEDVOICE,:ENERGYBALL,:QUASH,:WILLOWISP,:ACROBATICS,:EMBARGO,:SHADOWCLAW,:GIGAIMPACT,:SWORDSDANCE,:PSYCHUP,:XSCISSOR,:INFESTATION,:POISONJAB,:GRASSKNOT,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:NATUREPOWER,:CONFIDE,:SLASHANDBURN,:LEECHLIFE,:PINMISSILE,:MAGICALLEAF,:SOLARBLADE,:SCREECH,:SCARYFACE,:BULLETSEED,:CROSSPOISON,:HEX,:PHANTOMFORCE,:DRAININGKISS,:GRASSYTERRAIN,:HONECLAWS,:SUCKERPUNCH,:CUT,:STRENGTH,
          # Move Tutors
          :SNORE,:HEALBELL,:UPROAR,:BIND,:WORRYSEED,:SNATCH,:SPITE,:GIGADRAIN,:SYNTHESIS,:ALLYSWITCH,:WATERPULSE,:PAINSPLIT,:SEEDBOMB,:LASERFOCUS,:TRICK,:MAGICROOM,:WONDERROOM,:GASTROACID,:THROATCHOP,:SKILLSWAP,:GUNKSHOT,:HYPERVOICE,:KNOCKOFF,:SPIKES,:ENDURE,:BATONPASS,:FUTURESIGHT,:MUDDYWATER,:LEAFBLADE,:TOXICSPIKES,:POWERGEM,:NASTYPLOT,:LEAFSTORM,:POWERWHIP,:VENOMDRENCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
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


MultipleForms.register(:BUDEW,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "Having to suddenly adapt to the desert climate after the calamity lead to Budew drying out but barely surviving. It hides itself in sand dunes from predators."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [40,30,35,55,50,70]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:GROUND)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:GROUND)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:MUDSLAP],[4,:SANDATTACK],[7,:MUDSPORT],
          [10,:CAMOUFLAGE],[13,:ROCKTHROW],[16,:CHARM]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:EARTHPOWER,:EXTRASENSORY,:FINALGAMBIT,:MINDREADER,
          :MORNINGSUN,:MUDSHOT,:NATURALGIFT,:PINMISSILE,:REVENGE,
          :ROCKBLAST,:SANDSTORM,:SPIKES,:WEATHERBALL,:YAWN]
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
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:SECRETPOWER,
          :FRUSTRATION,:SMACKDOWN,:EARTHQUAKE,:RETURN,:DOUBLETEAM,
          :SANDSTORM,:ROCKTOMB,:FACADE,:REST,:ATTRACT,:THIEF,:LOWSWEEP,
          :ROUND,:ECHOEDVOICE,:FOCUSBLAST,:BULLDOZE,:ROCKSLIDE,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:NATUREPOWER,:CONFIDE,
          :ARENITEWALL,:PINMISSILE,:CHARM,:WEATHERBALL,:SANDTOMB,
          :MUDSHOT,:ROCKBLAST,:VACUUMWAVE,:CUT,
          # Move Tutors
          :SNORE,:UPROAR,:COVET,:SNATCH,:STEALTHROCK,:ROLEPLAY,
          :ENDEAVOR,:LASERFOCUS,:FOULPLAY,:THROATCHOP,:EARTHPOWER,
          :REVERSAL,:SPIKES,:ENDURE,:ENCORE,:TOXICSPIKES,:AURASPHERE,
          :POWERGEM]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:DRYSKIN)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:TECHNICIAN)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:SANDVEIL)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[373,478,510,515,523,525]   # Map IDs for Aevian form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end   
    }
  })

MultipleForms.register(:ROSELIA,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "It fights dirty to survive; it blinds foes with the sand circling around its neck, then bludgeons them with crystals that formed in the desert sand it picked up."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [50,60,45,65,100,80]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:GROUND)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:FIGHTING)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 1 ; movelist=[[1,:MUDSLAP],[4,:SANDATTACK],[7,:ROCKSMASH],
          [10,:CAMOUFLAGE],[13,:ROCKTHROW],[16,:KNOCKOFF],
          [19,:MUDSHOT],[22,:VACUUMWAVE],[25,:ANCIENTPOWER],
          [28,:TORMENT],[31,:SANDTOMB],[34,:TAUNT],[37,:LOWSWEEP],
          [40,:FOULPLAY],[43,:AURASPHERE],[46,:MORNINGSUN],
          [50,:CLOSECOMBAT]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:EARTHPOWER,:EXTRASENSORY,:FINALGAMBIT,:FOCUSBLAST,
          :MINDREADER,:MORNINGSUN,:MUDSHOT,:NATURALGIFT,
          :PINMISSILE,:REVENGE,:ROCKBLAST,:SANDSTORM,:SPIKES,
          :WEATHERBALL,:YAWN]
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
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:SECRETPOWER,
          :FRUSTRATION,:SMACKDOWN,:EARTHQUAKE,:RETURN,:SHADOWBALL,
          :BRICKBREAK,:DOUBLETEAM,:SANDSTORM,:ROCKTOMB,:AERIALACE,
          :TORMENT,:FACADE,:REST,:ATTRACT,:THIEF,:LOWSWEEP,:ROUND,
          :ECHOEDVOICE,:FOCUSBLAST,:BULLDOZE,:ROCKSLIDE,:POISONJAB,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:ROCKSMASH,:NATUREPOWER,
          :DARKPULSE,:POWERUPPUNCH,:CONFIDE,:POISONSWEEP,:STACKINGSHOT,
          :ARENITEWALL,:MEGAPUNCH,:PINMISSILE,:CHARM,:WEATHERBALL,
          :SANDTOMB,:MUDSHOT,:ROCKBLAST,:DYNAMICPUNCH,:VACUUMWAVE,:CUT,
          :STRENGTH,
          # Move Tutors
          :SNORE,:DEFOG,:LOWKICK,:UPROAR,:LASTRESORT,:COVET,:SNATCH,
          :STEALTHROCK,:ROLEPLAY,:FIREPUNCH,:ENDEAVOR,:LASERFOCUS,
          :FOULPLAY,:THROATCHOP,:EARTHPOWER,:GUNKSHOT,:DUALCHOP,
          :DRAINPUNCH,:SUPERPOWER,:KNOCKOFF,:REVERSAL,:SPIKES,:ENDURE,
          :ENCORE,:CLOSECOMBAT,:TOXICSPIKES,:AURASPHERE,:POWERGEM,
          :STOREDPOWER]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[7,17,407]]                        # Aevian     
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:DRYSKIN)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:TECHNICIAN)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:SANDVEIL)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ROSERADE,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "Now predator instead of prey, Roserade hunts for resources during sandstorms, its sand cloak allowing for perfect camouflage. It defends its territory fiercely."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [60,70,65,90,125,105]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:GROUND)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:FIGHTING)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 1 ; movelist=[[1,:EARTHPOWER],[1,:ROTOTILLER],[1,:POWERGEM],[1,:ROCKSMASH],[1,:ROCKTHROW],[1,:MUDSHOT],[1,:VACUUMWAVE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,:PROTECT,:SECRETPOWER,:FRUSTRATION,:SMACKDOWN,:EARTHQUAKE,:RETURN,:DIG,:SHADOWBALL,:BRICKBREAK,:DOUBLETEAM,:SANDSTORM,:ROCKTOMB,:AERIALACE,:TORMENT,:FACADE,:REST,:ATTRACT,:THIEF,:LOWSWEEP,:ROUND,:ECHOEDVOICE,:FOCUSBLAST,:PAYBACK,:GIGAIMPACT,:ROCKPOLISH,:STONEEDGE,:BULLDOZE,:ROCKSLIDE,:POISONJAB,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:ROCKSMASH,:SNARL,:NATUREPOWER,:DARKPULSE,:POWERUPPUNCH,:CONFIDE,:POISONSWEEP,:STACKINGSHOT,:ARENITEWALL,:BRUTALSWING,:MEGAPUNCH,:PINMISSILE,:CHARM,:BEATUP,:WEATHERBALL,:SANDTOMB,:MUDSHOT,:ROCKBLAST,:METRONOME,:SUCKERPUNCH,:RETALIATE,:DYNAMICPUNCH,:VACUUMWAVE,:CUT,:STRENGTH,
          # Move Tutors
          :SNORE,:DEFOG,:LOWKICK,:UPROAR,:LASTRESORT,:COVET,:SNATCH,:STEALTHROCK,:ROLEPLAY,:FIREPUNCH,:ENDEAVOR,:FOCUSPUNCH,:LASERFOCUS,:FOULPLAY,:THROATCHOP,:STOMPINGTANTRUM,:EARTHPOWER,:GUNKSHOT,:DUALCHOP,:DRAINPUNCH,:SUPERPOWER,:KNOCKOFF,:REVERSAL,:SPIKES,:ENDURE,:ENCORE,:CLOSECOMBAT,:TOXICSPIKES,:AURASPHERE,:POWERGEM,:STOREDPOWER,:PLAYROUGH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:DRYSKIN)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:TECHNICIAN)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:SANDVEIL)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:LITWICK,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "It took on this form during the industrial era. If you see one in your house, take a break as these Litwick drain energy from overworked people."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [50,35,55,20,65,55]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:GHOST)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:FIRE)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 1 ; movelist=[[1,:EMBER],[1,:ASTONISH],[3,:CHARGE],[7,:SMOG],
          [10,:EMBER],[13,:NIGHTSHADE],[16,:FLASH],[20,:FIRESPIN],
          [24,:EERIEIMPULSE],[28,:HEX],[33,:MEMENTO],
          [38,:CHARGEBEAM],[40,:ZAPCANNON],[43,:CURSE],[49,:SHADOWBALL],
          [55,:PAINSPLIT],[60,:DISCHARGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:ACID,:ACIDARMOR,:CAPTIVATE,:CLEARSMOG,:ENDURE,:HAZE,
          :DISCHARGE,:POWERSPLIT]
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
          :CALMMIND,:TOXIC,:HIDDENPOWER,:TAUNT,:PROTECT,:SECRETPOWER,
          :SAFEGUARD,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,
          :PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:TORMENT,:FACADE,
          :FLAMECHARGE,:REST,:ATTRACT,:THIEF,:ROUND,:OVERHEAT,
          :WILLOWISP,:EMBARGO,:PAYBACK,:FLASH,:PSYCHUP,:DREAMEATER,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:TRICKROOM,:DARKPULSE,
          :CONFIDE,:FIRESPIN,:HEX,:EERIEIMPULSE,:ZAPCANNON,
          # Move Tutors
          :SNORE,:ELECTROWEB,:UPROAR,:SHOCKWAVE,:RECYCLE,:SPITE,
          :ALLYSWITCH,:SIGNALBEAM,:IRONDEFENSE,:MAGNETRISE,:PAINSPLIT,
          :ICYWIND,:LASERFOCUS,:TRICK,:MAGICROOM,:WONDERROOM,:FOULPLAY,
          :SKILLSWAP,:SPIKES,:ENDURE,:FUTURESIGHT,:ELECTROBALL,
          :STOREDPOWER]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:ILLUMINATE)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:FLASHFIRE)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:INFILTRATOR)
        end
      end  
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[20,67,608]]                       # Aevian    [HasMove,Zap Cannon,Lampent]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[111]   # Map IDs for Aevian form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:LAMPENT,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "Rumors amongst factory workers say that encountering these Lampent is a bad omen, as often accidents at the workplace thought to be caused by them follow suit."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [60,40,60,55,95,60]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:GHOST)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:ELECTRIC)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:EMBER],[1,:ASTONISH],[3,:CHARGE],[7,:SMOG],[10,:EMBER],[13,:NIGHTSHADE],[16,:FLASH],[20,:FIRESPIN],[24,:EERIEIMPULSE],[28,:HEX],[33,:MEMENTO],[38,:CHARGEBEAM],[45,:CURSE],[53,:SHADOWBALL],[61,:PAINSPLIT],[69,:DISCHARGE],[75,:OVERHEAT]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :CALMMIND,:TOXIC,:HIDDENPOWER,:TAUNT,:PROTECT,:RAINDANCE,:SECRETPOWER,:SAFEGUARD,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:TORMENT,:FACADE,:FLAMECHARGE,:REST,:ATTRACT,:THIEF,:ROUND,:OVERHEAT,:CHARGEBEAM,:WILLOWISP,:EMBARGO,:PAYBACK,:FLASH,:VOLTSWITCH,:THUNDERWAVE,:PSYCHUP,:DREAMEATER,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:FLASHCANNON,:TRICKROOM,:DARKPULSE,:CONFIDE,:FIRESPIN,:HEX,:ELECTRICTERRAIN,:EERIEIMPULSE,:ZAPCANNON,
          # Move Tutors
          :SNORE,:ELECTROWEB,:UPROAR,:SHOCKWAVE,:RECYCLE,:SPITE,:ALLYSWITCH,:SIGNALBEAM,:IRONDEFENSE,:MAGNETRISE,:PAINSPLIT,:ICYWIND,:LASERFOCUS,:TRICK,:MAGICROOM,:WONDERROOM,:FOULPLAY,:SKILLSWAP,:SPIKES,:ENDURE,:FUTURESIGHT,:ELECTROBALL,:STOREDPOWER]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:ILLUMINATE)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:VOLTABSORB)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:LEVITATE)
        end
      end  
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[7,13,609]]                        # Aevian    [Item,Thunder Stone,Chandelure]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })


MultipleForms.register(:TOXTRICITY,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Normal
        next
      when 2  # Normal
        next
      when 4  # Aevian
        next "This form of Toxtricity is newly discovered as Toxel only started appearing in Aevium in the last ten years. It burns the poison in its body and spews out the toxic fumes to attack."  # Aevian
      end
    },
    "getMegaForm"=>proc{|pokemon|
      next 3 if isConst?(pokemon.item,PBItems,:TOXTRICITITE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0 if pokemon.form==3
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Toxtricity") if pokemon.form==3
      next
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 3  # Mega
        next [75,123,95,100,139,70]
      when 4  # Aevian
        next [70,75,70,98,114,70]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 3
        next
      when 4  # Aevian
        next getID(PBTypes,:FIRE)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 3 
        next
      when 4  # Aevian
        next getID(PBTypes,:POISON)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form!=4  # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 4 ; movelist=[[1,:FLAMEBURST],[1,:SUNNYDAY],[1,:BELCH],[1,:TEARFULLOOK],[1,:WILLOWISP],[1,:GROWL],[1,:FLAIL],[1,:ACID],[1,:EMBER],[1,:ACIDSPRAY],[1,:LEER],[1,:NOBLEROAR],[4,:EMBER],[8,:INCINERATE],[12,:SCARYFACE],[16,:TAUNT],[20,:VENOSHOCK],[24,:SCREECH],[28,:SWAGGER],[32,:TOXIC],[36,:LAVAPLUME],[40,:POISONJAB],[44,:OVERHEAT],[48,:BOOMBURST],[52,:SHIFTGEAR]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form!=4
      movelist=[]
      case pokemon.form
      when 4; movelist=[# TMs
          :WORKUP,:DRAGONCLAW,:ROAR,:TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,:PROTECT,:SECRETPOWER,:FRUSTRATION,:SOLARBEAM,:THUNDER,:RETURN,:DIG,:DOUBLETEAM,:SLUDGEWAVE,:FLAMETHROWER,:SLUDGEBOMB,:FIREBLAST,:FACADE,:FLAMECHARGE,:REST,:ATTRACT,:ROUND,:ECHOEDVOICE,:OVERHEAT,:INCINERATE,:WILLOWISP,:PAYBACK,:GIGAIMPACT,:STONEEDGE,:PSYCHUP,:POISONJAB,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:WILDCHARGE,:ROCKSMASH,:SNARL,:POWERUPPUNCH,:CONFIDE,:ROCKCLIMB,:POISONSWEEP,:LAVASURF,:MEGAPUNCH,:MEGAKICK,:SOLARBLADE,:FIRESPIN,:SCREECH,:SCARYFACE,:FIREFANG,:THUNDERFANG,:CROSSPOISON,:MYSTICALFIRE,:SUCKERPUNCH,:DYNAMICPUNCH,:STRENGTH,
          # Move Tutors
          :SNORE,:DEFOG,:UPROAR,:AFTERYOU,:SIGNALBEAM,:BOUNCE,:ROLEPLAY,:FIREPUNCH,:THUNDERPUNCH,:ENDEAVOR,:LASERFOCUS,:GASTROACID,:OUTRAGE,:THROATCHOP,:STOMPINGTANTRUM,:GUNKSHOT,:DUALCHOP,:DRAINPUNCH,:HEATWAVE,:HYPERVOICE,:KNOCKOFF,:AGILITY,:ENDURE,:BATONPASS,:ENCORE,:BLAZEKICK,:FLAREBLITZ,:STOREDPOWER,:HEATCRASH,:VENOMDRENCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 3
        next getID(PBAbilities,:PUNKROCK)
      when 4 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:GALVANIZE)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:PUNKROCK)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:SOLIDROCK)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })


MultipleForms.register(:PARAS,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "The environment caused the species of mushroom infesting Paras to mutate. Their poison is strong enough to shock the host back to life when on the brink of death."  # Aevian
      when 2  # Aevian post-revival
        next "The environment caused the species of mushroom infesting Paras to mutate. Their poison is strong enough to shock the host back to life when on the brink of death."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [35,70,55,25,45,55]
      when 2  # Aevian post-revival
        next [15,100,25,75,45,25]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:BUG)
      when 2  # Aevian post-revival
        next getID(PBTypes,:GHOST)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:POISON)
      when 2  # Aevian
        next getID(PBTypes,:POISON)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:SCRATCH],[6,:POISONPOWDER],[6,:STUNSPORE],[11,:POISONSTING],
          [17,:FURYCUTTER],[22,:TOXIC],[27,:SLASH],
          [33,:AROMATHERAPY],[38,:CROSSPOISON],[43,:VENOMDRENCH],
          [49,:SLEEPPOWDER],[54,:XSCISSOR],[73,:GUNKSHOT]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:AGILITY,:BUGBITE,:METALCLAW,:CROSSPOISON,:ENDURE,
          :LEECHSEED,:FLAIL,:KNOCKOFF,:PURSUIT,:PSYBEAM,:SCREECH,:DISABLE]
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
          :TOXIC,:VENOSHOCK,:HIDDENPOWER,:PROTECT,:RAINDANCE,:SECRETPOWER,
          :FRUSTRATION,:RETURN,:DOUBLETEAM,:SLUDGEBOMB,:AERIALACE,:FACADE,
          :REST,:ATTRACT,:THIEF,:ROUND,:FLING,:FALSESWIPE,
          :STRUGGLEBUG,:XSCISSOR,:INFESTATION,:POISONJAB,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:ROCKSMASH,:CONFIDE,:POISONSWEEP,:IRRITATION,:LEECHLIFE,
          :PINMISSILE,:SCREECH,:SCARYFACE,:MUDSHOT,:CROSSPOISON,
          :CUT,
          # Move Tutors
          :SNORE,:ELECTROWEB,:BUGBITE,:RECYCLE,:SPITE,:GIGADRAIN,
          :SIGNALBEAM,:WATERPULSE,:PAINSPLIT,:ENDEAVOR,:ICYWIND,
          :LASERFOCUS,:MAGICROOM,:WONDERROOM,:GASTROACID,:GUNKSHOT,
          :KNOCKOFF,:ENDURE,:TOXICSPIKES,:POLLENPUFF]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[33,1041,47]]                        # Aevian    
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[64] # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:RESUSCITATION)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:RESUSCITATION)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:RESUSCITATION)
        end
      when 2 # Aevian post-revival
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:RESUSCITATION)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:RESUSCITATION)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:RESUSCITATION)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:PARASECT,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "The poisonous ooze dripping from the mushrooms on its back is postulated to have medicinal uses, however verification of this rumour's validity is still ongoing."  # Aevian
      when 2  # Aevian post-revival
        next "The poisonous ooze dripping from the mushrooms on its back is postulated to have medicinal uses, however verification of this rumour's validity is still ongoing."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [60,90,80,30,60,80]
      when 2  # Aevian post-revival
        next [40,130,40,105,50,40]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:BUG)
      when 2  # Aevian post-revival
        next getID(PBTypes,:GHOST)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:POISON)
      when 2  # Aevian post-revival
        next getID(PBTypes,:POISON)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:SHADOWCLAW],[1,:PHANTOMFORCE],[1,:SHADOWSNEAK],[1,:SCRATCH],[6,:POISONPOWDER],[6,:STUNSPORE],[11,:POISONSTING],
          [17,:FURYCUTTER],[22,:TOXIC],[29,:SLASH],
          [37,:AROMATHERAPY],[44,:CROSSPOISON],[51,:VENOMDRENCH],
          [59,:SLEEPPOWDER],[66,:XSCISSOR],[73,:GUNKSHOT]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:VENOSHOCK,:HIDDENPOWER,:PROTECT,:RAINDANCE,:SECRETPOWER,
          :FRUSTRATION,:SHADOWBALL,:BRICKBREAK,:RETURN,:DOUBLETEAM,:SLUDGEBOMB,:AERIALACE,:FACADE,
          :REST,:ATTRACT,:THIEF,:ROUND,:FLING,:FALSESWIPE,:WILLOWISP,:SHADOWCLAW,:PAYBACK,:GIGAIMPACT,
          :STRUGGLEBUG,:XSCISSOR,:INFESTATION,:POISONJAB,:SWAGGER,:SLEEPTALK,:UTURN,
          :SUBSTITUTE,:ROCKSMASH,:CONFIDE,:ROCKCLIMB,:POISONSWEEP,:IRRITATION,:SLASHANDBURN,:LEECHLIFE,
          :PINMISSILE,:SCREECH,:SCARYFACE,:MUDSHOT,:SPEEDSWAP,:CROSSPOISON,:PHANTOMFORCE,
          :CUT,:RETALIATE,
          # Move Tutors
          :SNORE,:ELECTROWEB,:BUGBITE,:RECYCLE,:SPITE,:GIGADRAIN,
          :SIGNALBEAM,:WATERPULSE,:PAINSPLIT,:ENDEAVOR,:ICYWIND,
          :LASERFOCUS,:MAGICROOM,:WONDERROOM,:GASTROACID,:GUNKSHOT,
          :KNOCKOFF,:ENDURE,:TOXICSPIKES,:POLLENPUFF]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        next getID(PBAbilities,:RESUSCITATION)
      when 2 # Aevian post-revival
        next getID(PBAbilities,:RESUSCITATION)
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })


MultipleForms.register(:FEEBAS,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "A rare type of Feebas that has become particularly popular with collectors. The bright fins serve as a warning to predators about the toxins it carries in its body."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [20,15,20,80,10,55]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:POISON)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:FAIRY)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 1 ; movelist=[[1,:SPLASH],[15,:TACKLE],[25,:FLAIL]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:BRINE,:CONFUSERAY,:CAPTIVATE,:TOXICSPIKES,:HAZE,
          :MUDSPORT,:BELCH,:CAPTIVATE,:HYPNOSIS]
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
          :TOXIC,:VENOSHOCK,:HIDDENPOWER,:ICEBEAM,:BLIZZARD,:HYPERBEAM,
          :PROTECT,:RAINDANCE,:FRUSTRATION,:DOUBLETEAM,:SLUDGEWAVE,
          :SLUDGEBOMB,:FACADE,:REST,:ATTRACT,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:SNARL,:DAZZLINGGLEAM,:CONFIDE,:CHARM,:WHIRLPOOL,
          :BRINE,:MISTYTERRAIN,:SURF,
          # Move Tutors
          :SNORE,:LASTRESORT,:BOUNCE,:AMNESIA,:ENCORE,:TOXICSPIKES]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:POISONPOINT)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:STENCH)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:SCRAPPY)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MILOTIC,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next "Beautiful but highly dangerous, it's seen as a status symbol among the wealthy. Its venom is potent enough to completely immobilize an adult within seconds."  # Aevian
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next [95,100,79,81,60,125]
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:POISON)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:FAIRY)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 1 ; movelist=[[1,:POISONTAIL],[1,:WRAP],[1,:POISONSTING],[1,:FAIRYWIND],
          [1,:REFRESH],[0,:POISONTAIL],[4,:FAIRYWIND],[7,:REFRESH],
          [11,:DISARMINGVOICE],[14,:SLAM],[17,:VENOMDRENCH],
          [21,:CHARM],[24,:DRAGONTAIL],
          [31,:PLAYROUGH],[34,:ATTRACT],[37,:PAINSPLIT],[41,:POISONGAS],[44,:POISONJAB],[51,:TOXIC],[58,:GUNKSHOT],
          [67,:COIL]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HAIL,:VENOSHOCK,:HIDDENPOWER,:TAUNT,:ICEBEAM,
          :BLIZZARD,:HYPERBEAM,:PROTECT,:RAINDANCE,:SECRETPOWER,
          :FRUSTRATION,:DOUBLETEAM,:SLUDGEWAVE,:SLUDGEBOMB,:ROCKTOMB,
          :TORMENT,:FACADE,:REST,:ATTRACT,:THIEF,:ROUND,:ECHOEDVOICE,
          :QUASH,:EMBARGO,:PAYBACK,:GIGAIMPACT,:THUNDERWAVE,:PSYCHUP,
          :BULLDOZE,:DRAGONTAIL,:INFESTATION,:DREAMEATER,:SWAGGER,
          :SLEEPTALK,:SUBSTITUTE,:SNARL,:DAZZLINGGLEAM,:CONFIDE,
          :ROCKCLIMB,:POISONSWEEP,:IRRITATION,:LEECHLIFE,:CHARM,
          :WHIRLPOOL,:FAKETEARS,:MUDSHOT,:BRINE,:ASSURANCE,:POWERSWAP,
          :TAILSLAP,:DRAININGKISS,:MISTYTERRAIN,:SURF,:STRENGTH,
          :WATERFALL,:DIVE,
          # Move Tutors
          :SNORE,:UPROAR,:BIND,:LASTRESORT,:COVET,:SNATCH,:IRONTAIL,
          :SPITE,:ALLYSWITCH,:SIGNALBEAM,:BOUNCE,:WATERPULSE,:AQUATAIL,
          :PAINSPLIT,:ICYWIND,:MAGICCOAT,:GASTROACID,:SKILLSWAP,
          :GUNKSHOT,:KNOCKOFF,:BODYSLAM,:DRAGONDANCE,:TOXICSPIKES,
          :PLAYROUGH,:VENOMDRENCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:POISONPOINT)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:MERCILESS)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
          next getID(PBAbilities,:DEFIANT)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })


MultipleForms.register(:SANDYGAST,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0
      next "After floods from Route 5's river drove it into Mt. Valor, it has adapted to the whims of the mountain. The mood crystal particles it carries allow it to change forms."
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0
      next [55,55,80,15,70,45] # Aevian
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0
      next getID(PBTypes,:GHOST)
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian #1
        next getID(PBTypes,:ROCK)
      when 2  # Aevian #2
        next getID(PBTypes,:FIRE)
      when 3  # Aevian #3
        next getID(PBTypes,:ICE)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal 0
      movelist=[]
      case pokemon.form            # Aevian 1-3
      when 1 ; movelist=[[1,:HARDEN],[1,:ABSORB],[5,:ASTONISH],[9,:STEALTHROCK],
          [14,:ROCKBLAST],[18,:MEGADRAIN],[23,:ROCKTOMB],[27,:HYPNOSIS],
          [32,:IRONDEFENSE],[36,:GIGADRAIN],[41,:SHADOWBALL],[45,:POWERGEM],
          [50,:MORNINGSUN],[54,:SANDSTORM]]
      when 2 ; movelist=[[1,:HARDEN],[1,:ABSORB],[5,:ASTONISH],[9,:WILLOWISP],
          [14,:FIRESPIN],[18,:MEGADRAIN],[23,:FLAMEBURST],[27,:HYPNOSIS],
          [32,:IRONDEFENSE],[36,:GIGADRAIN],[41,:SHADOWBALL],[45,:LAVAPLUME],
          [50,:MORNINGSUN],[54,:SUNNYDAY]]
      when 3 ; movelist=[[1,:HARDEN],[1,:ABSORB],[5,:ASTONISH],[9,:HAZE],
          [14,:ICESHARD],[18,:MEGADRAIN],[23,:AURORABEAM],[27,:HYPNOSIS],
          [32,:IRONDEFENSE],[36,:GIGADRAIN],[41,:SHADOWBALL],[45,:FREEZEDRY],
          [50,:MOONLIGHT],[54,:HAIL]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:AMNESIA,:ANCIENTPOWER,:CAMOUFLAGE,:CURSE,:DESTINYBOND,
          :SPITUP,:STOCKPILE,:SWALLOW]
      when 2 ; eggmovelist=[:AMNESIA,:ANCIENTPOWER,:CAMOUFLAGE,:CURSE,:DESTINYBOND,
          :SPITUP,:STOCKPILE,:SWALLOW]
      when 3 ; eggmovelist=[:AMNESIA,:ANCIENTPOWER,:CAMOUFLAGE,:CURSE,:DESTINYBOND,
          :SPITUP,:STOCKPILE,:SWALLOW]
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
          :TOXIC,:HIDDENPOWER,:TAUNT,:PROTECT,:SECRETPOWER,:FRUSTRATION,
          :SMACKDOWN,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:SLUDGEWAVE,
          :SANDSTORM,:ROCKTOMB,:FACADE,:REST,:ATTRACT,:ROUND,
          :ENERGYBALL,:EXPLOSION,:ROCKPOLISH,:STONEEDGE,:BULLDOZE,
          :ROCKSLIDE,:DREAMEATER,:GRASSKNOT,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:NATUREPOWER,:CONFIDE,:ARENITEWALL,:SELFDESTRUCT,
          :ROCKBLAST,:BRINE,:HEX,
          # Move Tutors
          :RECYCLE,:BLOCK,:SPITE,:AFTERYOU,:GIGADRAIN,
          :WATERPULSE,:PAINSPLIT,:TRICK,:LASERFOCUS,:SNORE,
          :STEALTHROCK,:SKILLSWAP,:ENDURE,:POWERGEM]
      when 2; movelist=[# TMs
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:PROTECT,:SECRETPOWER,:FRUSTRATION,
          :SOLARBEAM,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:FLAMETHROWER,:SLUDGEWAVE,
          :SANDSTORM,:FIREBLAST,:FACADE,:FLAMECHARGE,:REST,:ATTRACT,:ROUND,:OVERHEAT,:FOCUSBLAST,
          :ENERGYBALL,:INCINERATE,:WILLOWISP,:EXPLOSION,:BULLDOZE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:NATUREPOWER,:CONFIDE,:LAVASURF,:SELFDESTRUCT,
          :ROCKBLAST,:FIRESPIN,:HEX,:PHANTOMFORCE,
          # Move Tutors
          :SHOCKWAVE,:RECYCLE,:BLOCK,:SPITE,:AFTERYOU,:GIGADRAIN,
          :PAINSPLIT,:TRICK,:LASERFOCUS,:SNORE,
          :STEALTHROCK,:SKILLSWAP,:ENDURE,:HEATWAVE]
      when 3; movelist=[# TMs
          :CALMMIND,:TOXIC,:HIDDENPOWER,:HAIL,:ICEBEAM,:BLIZZARD,:TAUNT,:PROTECT,:SECRETPOWER,:FRUSTRATION,
          :SOLARBEAM,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:FACADE,:REST,:ATTRACT,:ROUND,:FOCUSBLAST,
          :THUNDERWAVE,:FROSTBREATH,:GYROBALL,:EXPLOSION,:BULLDOZE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:NATUREPOWER,:CONFIDE,:FLASHCANNON,:SELFDESTRUCT,
          :ICICLESPEAR,:BRINE,:HEX,:PHANTOMFORCE,
          # Move Tutors
          :SHOCKWAVE,:RECYCLE,:BLOCK,:SPITE,:AFTERYOU,:GIGADRAIN,
          :PAINSPLIT,:TRICK,:LASERFOCUS,:SNORE,:SKILLSWAP,:ENDURE,:ICYWIND]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian #1
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:CLEARBODY)
        elsif pokemon.abilityIndex!=0 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:STORMDRAIN)
        end
      when 2 # Aevian #2
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:FLAMEBODY)
        elsif pokemon.abilityIndex!=0 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:STEAMENGINE)
        end
      when 3 # Aevian #3
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:ICEBODY)
        elsif pokemon.abilityIndex!=0 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:BULLETPROOF)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      amaps=[6,139]# Map IDs for Aevian form
      bmaps=[42,140]
      cmaps=[45,146]
      if $game_map && amaps.include?($game_map.map_id)
        next 1
      elsif $game_map && bmaps.include?($game_map.map_id)
        next 2
      elsif $game_map && cmaps.include?($game_map.map_id)
        next 3
      else
        next 0
      end 
    }
  })

MultipleForms.register(:PALOSSAND,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0
      next "Palossand uses materials from the ruins within Mt. Valor to fortify itself. It's a mystery where it got the scarf and carrot it has in its Ice form, however."
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0
      next [85,75,110,35,100,75] # Aevian
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0
      next getID(PBTypes,:GHOST)
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian #1
        next getID(PBTypes,:ROCK)
      when 2  # Aevian #2
        next getID(PBTypes,:FIRE)
      when 3  # Aevian #3
        next getID(PBTypes,:ICE)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:HARDEN],[1,:ABSORB],[1,:ASTONISH],[1,:STEALTHROCK],
          [5,:ASTONISH],[9,:STEALTHROCK],[14,:ROCKBLAST],[18,:MEGADRAIN],[23,:ROCKTOMB],[27,:HYPNOSIS],
          [32,:IRONDEFENSE],[36,:GIGADRAIN],[41,:SHADOWBALL],[47,:POWERGEM],
          [57,:RECOVER],[60,:SANDSTORM]]
      when 2 ; movelist=[[1,:HARDEN],[1,:ABSORB],[5,:ASTONISH],[9,:WILLOWISP],
          [5,:ASTONISH],[9,:WILLOWISP],[14,:FIRESPIN],[18,:MEGADRAIN],[23,:FLAMEBURST],
          [27,:HYPNOSIS],[32,:IRONDEFENSE],[36,:GIGADRAIN],[41,:SHADOWBALL],[47,:LAVAPLUME],
          [57,:MORNINGSUN],[60,:SUNNYDAY]]
      when 3 ; movelist=[[1,:HARDEN],[1,:ABSORB],[1,:ASTONISH],[1,:HAZE],
          [5,:ASTONISH],[9,:HAZE],[14,:ICESHARD],[18,:MEGADRAIN],[23,:AURORABEAM],
          [27,:HYPNOSIS],[32,:IRONDEFENSE],[36,:GIGADRAIN],[41,:SHADOWBALL],
          [47,:FREEZEDRY],[57,:MOONLIGHT],[60,:HAIL]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:HIDDENPOWER,:TAUNT,:HYPERBEAM,:PROTECT,:SECRETPOWER,:FRUSTRATION,
          :SMACKDOWN,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:SLUDGEWAVE,
          :SANDSTORM,:ROCKTOMB,:FACADE,:REST,:ATTRACT,:ROUND,:EMBARGO,:FLING,
          :ENERGYBALL,:EMBARGO,:EXPLOSION,:ROCKPOLISH,:GIGAIMPACT,:STONEEDGE,:BULLDOZE,
          :ROCKSLIDE,:DREAMEATER,:GRASSKNOT,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:NATUREPOWER,:CONFIDE,:ARENITEWALL,:SELFDESTRUCT,
          :ROCKBLAST,:BRINE,:HEX,
          # Move Tutors
          :RECYCLE,:BLOCK,:SPITE,:AFTERYOU,:GIGADRAIN,
          :WATERPULSE,:PAINSPLIT,:TRICK,:LASERFOCUS,:SNORE,
          :STEALTHROCK,:SKILLSWAP,:ENDURE,:POWERGEM,:STRENGTH]
      when 2; movelist=[# TMs
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:HYPERBEAM,:PROTECT,:SECRETPOWER,:FRUSTRATION,
          :SOLARBEAM,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:FLAMETHROWER,:SLUDGEWAVE,
          :SANDSTORM,:FIREBLAST,:FACADE,:FLAMECHARGE,:REST,:ATTRACT,:ROUND,:OVERHEAT,:FOCUSBLAST,
          :ENERGYBALL,:INCINERATE,:WILLOWISP,:EMBARGO,:EXPLOSION,:GIGAIMPACT,:BULLDOZE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:NATUREPOWER,:CONFIDE,:LAVASURF,:SELFDESTRUCT,
          :ROCKBLAST,:FIRESPIN,:HEX,:PHANTOMFORCE,
          # Move Tutors
          :SHOCKWAVE,:RECYCLE,:BLOCK,:SPITE,:AFTERYOU,:GIGADRAIN,
          :PAINSPLIT,:TRICK,:LASERFOCUS,:SNORE,
          :STEALTHROCK,:SKILLSWAP,:ENDURE,:HEATWAVE]
      when 3; movelist=[# TMs
          :CALMMIND,:TOXIC,:HIDDENPOWER,:HAIL,:ICEBEAM,:BLIZZARD,:TAUNT,:HYPERBEAM,:PROTECT,:SECRETPOWER,:FRUSTRATION,
          :SOLARBEAM,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:FACADE,:REST,:ATTRACT,:ROUND,:FOCUSBLAST,
          :THUNDERWAVE,:FROSTBREATH,:GYROBALL,:EMBARGO,:EXPLOSION,:GIGAIMPACT,:BULLDOZE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:NATUREPOWER,:CONFIDE,:FLASHCANNON,:SELFDESTRUCT,
          :ICICLESPEAR,:BRINE,:HEX,:PHANTOMFORCE,:WHIRLPOOL,
          # Move Tutors
          :SHOCKWAVE,:RECYCLE,:BLOCK,:SPITE,:AFTERYOU,:GIGADRAIN,
          :PAINSPLIT,:TRICK,:LASERFOCUS,:SNORE,:SKILLSWAP,:ENDURE,:ICYWIND]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian #1
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:CLEARBODY)
        elsif pokemon.abilityIndex!=0 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:SOLIDROCK)
        end
      when 2 # Aevian #2
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:FLAMEBODY)
        elsif pokemon.abilityIndex!=0 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:STEAMENGINE)
        end
      when 3 # Aevian #3
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:ICEBODY)
        elsif pokemon.abilityIndex!=0 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:BULLETPROOF)
        end
      end  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

## End of Regional Variants ##

#### KUROTSUNE - 001 - START
MultipleForms.register(:KYOGRE,{
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
      next getID(PBAbilities,:PRIMORDIALSEA) # Primal
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


MultipleForms.register(:GROUDON,{
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
      next getID(PBTypes,:FIRE)  # Primal
    },   
    "ability"=>proc{|pokemon|
      next if pokemon.form==0               
      next getID(PBAbilities,:DESOLATELAND) # Primal
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



#### KUROTSUNE - 001 - END
##### Mega Evolution forms #####################################################


MultipleForms.register(:VENUSAUR,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:VENUSAURITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:THICKFAT) if pokemon.form==1
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


MultipleForms.register(:CHARIZARD,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:CHARIZARDITEX) || pokemon.isPreMega?)
      next 2 if (isConst?(pokemon.item,PBItems,:CHARIZARDITEY) || pokemon.isPreMega?)
      next 3 if (isConst?(pokemon.item,PBItems,:CHARIZARDITEG) || pokemon.isPreMega?)
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Charizard X") if pokemon.form==1
      next _INTL("Mega Charizard Y") if pokemon.form==2
      next _INTL("Mega Charizard G") if pokemon.form==3
    },
    "getBaseStats"=>proc{|pokemon|
      next [78,130,111,100,130,85] if pokemon.form==1
      next [78,104,78,100,159,115] if pokemon.form==2
      next [78,119,98,105,134,105] if pokemon.form==3
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:DRAGON) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:TOUGHCLAWS) if pokemon.form==1
      next getID(PBAbilities,:DROUGHT) if pokemon.form==2
      next getID(PBAbilities,:SOLARPOWER) if pokemon.form==3
    },
    "weight"=>proc{|pokemon|
      next 1105 if pokemon.form==1
      next 1005 if pokemon.form==2
      next 2216 if pokemon.form==3
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:BLASTOISE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:BLASTOISINITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:MEGALAUNCHER) if pokemon.form==1
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

MultipleForms.register(:ALAKAZAM,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:ALAKAZITE)|| pokemon.isPreMega?)
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
      next getID(PBAbilities,:TRACE) if pokemon.form==1
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

MultipleForms.register(:GENGAR,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:GENGARITE) || pokemon.isPreMega?)
      next 2 if isConst?(pokemon.item,PBItems,:GENGARITEG)
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Gengar") if pokemon.form==1
      next _INTL("Mega Gengar G") if pokemon.form==2
    },
    "getBaseStats"=>proc{|pokemon|
      next [60,65,80,130,170,95] if pokemon.form==1
      next [90,150,100,110,65,115] if pokemon.form==2
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:SHADOWTAG) if pokemon.form==1
      next getID(PBAbilities,:CURSEDBODY) if pokemon.form==2
    },
    "height"=>proc{|pokemon|
    next 611 if pokemon.form==1
    next
    },
    "weight"=>proc{|pokemon|
      next 405 if pokemon.form==1
      next 611 if pokemon.form==2
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:KANGASKHAN,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:KANGASKHANITE) || pokemon.isPreMega?)
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
      #### KUROTSUNE - 004 - START
      next getID(PBAbilities,:PARENTALBOND) if pokemon.form==1
      #### KUROTSUNE - 004 - END
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

MultipleForms.register(:PINSIR,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:PINSIRITE) || pokemon.isPreMega?)
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
      next getID(PBTypes,:FLYING) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:AERILATE) if pokemon.form==1
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

MultipleForms.register(:GYARADOS,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:GYARADOSITE) || pokemon.isPreMega?)
      next 2 if ((pokemon.item == PBItems::DEMONSTONE) && pokemon.form==0)
      next 3 if ((pokemon.item == PBItems::DEMONSTONE) && pokemon.form==3)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
      next 3 if pokemon.form==3
      next
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Gyarados") if pokemon.form==1
      next _INTL("Rift Gyarados") if pokemon.form==2
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [95,155,109,81,70,130] if pokemon.form==1
      next [70,110,100,100,90,78] if pokemon.form==2
      next [300,110,150,51,100,150] if pokemon.form==3
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:DARK) if pokemon.form==1
      next getID(PBTypes,:GHOST) if pokemon.form==2
      next getID(PBTypes,:STEEL) if pokemon.form==3
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:MOLDBREAKER) if pokemon.form==1
      next getID(PBAbilities,:INTIMIDATE2) if pokemon.form==2
      next getID(PBAbilities,:LIQUIDVOICE) if pokemon.form==3
      next
    },
    "weight"=>proc{|pokemon|
      next 3050 if pokemon.form==1
      next 3060 if pokemon.form==2
      next 9060 if pokemon.form==3
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:AERODACTYL,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:AERODACTYLITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:TOUGHCLAWS) if pokemon.form==1
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

MultipleForms.register(:MEWTWO,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:MEWTWONITEX) || pokemon.isPreMega?)
      next 2 if (isConst?(pokemon.item,PBItems,:MEWTWONITEY) || pokemon.isPreMega?)
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
      next getID(PBTypes,:FIGHTING) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:STEADFAST) if pokemon.form==1
      next getID(PBAbilities,:INSOMNIA) if pokemon.form==2
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

MultipleForms.register(:AMPHAROS,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:AMPHAROSITE) || pokemon.isPreMega?)
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0 if pokemon.form==1
      next 2 if pokemon.form==2
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Ampharos") if pokemon.form==1
    },
    "dexEntry"=>proc{|pokemon|
      next "Its tail and horns glow bright enough to be clearly visible in even the harshest of snowstorms, making it invaluable for rescue missions during extreme weather." if pokemon.form==2 # Aevian
      next 
    },
    
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Mega
        next [90,95,105,45,165,110]
      when 2 # Aevian
        next [90,75,90,55,115,85]    
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Mega
        next
      when 2  # Aevian
        next getID(PBTypes,:ICE)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Mega
        next getID(PBTypes,:DRAGON)
      when 2  # Aevian
        next getID(PBTypes,:ELECTRIC)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0 || pokemon.form==1     # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 2 ; movelist=[[1,:THUNDERPUNCH],[1,:ZAPCANNON],[1,:HAZE],[1,:BLIZZARD],[1,:ICEPUNCH],[1,:TACKLE],[1,:HAIL],[1,:THUNDERWAVE],[1,:THUNDERSHOCK],[0,:THUNDERPUNCH],[4,:THUNDERWAVE],[8,:THUNDERSHOCK],[11,:COTTONSPORE],[16,:ICYWIND],[20,:TAKEDOWN],[25,:ICEBALL],[29,:CONFUSERAY],[35,:POWERGEM],[40,:DISCHARGE],[46,:COTTONGUARD],[51,:REST],[57,:REFLECT],[62,:THUNDER],[65,:BLIZZARD]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 || pokemon.form==1
      movelist=[]
      case pokemon.form
      when 2; movelist=[# TMs
          :TOXIC,:HAIL,:HIDDENPOWER,:TAUNT,:ICEBEAM,:BLIZZARD,:HYPERBEAM,:PROTECT,:RAINDANCE,:SECRETPOWER,:SAFEGUARD,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,:SHADOWBALL,:DOUBLETEAM,:REFLECT,:FACADE,:REST,:ROUND,:ECHOEDVOICE,:FLING,:CHARGEBEAM,:PAYBACK,:GIGAIMPACT,:FLASH,:VOLTSWITCH,:THUNDERWAVE,:GYROBALL,:FROSTBREATH,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:FLASHCANNON,:WILDCHARGE,:ROCKSMASH,:CONFIDE,:ROCKCLIMB,:AURORAVEIL,:BRUTALSWING,:MEGAPUNCH,:MEGAKICK,:PAYDAY,:BEATUP,:WEATHERBALL,:FAKETEARS,:ICICLESPEAR,:GUARDSWAP,:TAILSLAP,:ELECTRICTERRAIN,:EERIEIMPULSE,:BREAKINGSWIPE,:AVALANCHE,:ZAPCANNON,:METRONOME,:DYNAMICPUNCH,:STRENGTH,
          # Move Tutors
          :SNORE,:HEALBELL,:ELECTROWEB,:SHOCKWAVE,:SNATCH,:RECYCLE,:IRONTAIL,:AFTERYOU,:SIGNALBEAM,:MAGNETRISE,:ROLEPLAY,:WATERPULSE,:ICEPUNCH,:THUNDERPUNCH,:ENDEAVOR,:FOCUSPUNCH,:ICYWIND,:LASERFOCUS,:MAGICCOAT,:OUTRAGE,:SKILLSWAP,:DRAGONPULSE,:BODYSLAM,:AGILITY,:ENDURE,:DRAGONDANCE,:POWERGEM,:ELECTROBALL,:PLAYROUGH,:BODYPRESS]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1
        next getID(PBAbilities,:MOLDBREAKER)
      when 2 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:FILTER)
        elsif pokemon.abilityIndex!=0 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:COTTONDOWN)
        end
      end  
    },
    "weight"=>proc{|pokemon|
      next 615 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SCIZOR,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:SCIZORITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:TECHNICIAN) if pokemon.form==1
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

MultipleForms.register(:HERACROSS,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:HERACRONITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:SKILLLINK) if pokemon.form==1
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

MultipleForms.register(:HOUNDOOM,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:HOUNDOOMINITE) || pokemon.isPreMega?
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
      next getID(PBAbilities,:SOLARPOWER) if pokemon.form==1
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

MultipleForms.register(:TYRANITAR,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:TYRANITARITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:SANDSTREAM) if pokemon.form==1
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

MultipleForms.register(:BLAZIKEN,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:BLAZIKENITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:SPEEDBOOST) if pokemon.form==1
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

MultipleForms.register(:GARDEVOIR,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:GARDEVOIRITE) || pokemon.isPreMega?
      next 2 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Gardevoir") if pokemon.form==1
      next _INTL("Rift Gardevoir") if pokemon.form==2
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [68,85,65,100,165,135] if pokemon.form==1
      next [150,200,150,110,180,200] if pokemon.form==2
      next [100,130,100,240,100,100] if pokemon.form==3
      next [88,65,135,100,165,135] if pokemon.form==4
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:PIXILATE) if pokemon.form==1
      next getID(PBAbilities,:EXECUTION) if pokemon.form==2
      next getID(PBAbilities,:EXECUTION) if pokemon.form==3
      next getID(PBAbilities,:PIXILATE) if pokemon.form==4
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:FAIRY) if pokemon.form==2
      next getID(PBTypes,:FAIRY) if pokemon.form==3
      next getID(PBTypes,:FAIRY) if pokemon.form==4
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:DARK) if pokemon.form==2
      next getID(PBTypes,:DARK) if pokemon.form==3
      next getID(PBTypes,:DARK) if pokemon.form==4
      next
    },
    "weight"=>proc{|pokemon|
      next 484 if pokemon.form==1
      next 110 if pokemon.form==2
      next 80 if pokemon.form==3
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MAWILE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:MAWILITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:HUGEPOWER) if pokemon.form==1
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

MultipleForms.register(:AGGRON,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:AGGRONITE) || pokemon.isPreMega?)
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
      next getID(PBTypes,:STEEL) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:FILTER) if pokemon.form==1
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

MultipleForms.register(:MEDICHAM,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:MEDICHAMITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:PUREPOWER) if pokemon.form==1
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

MultipleForms.register(:MANECTRIC,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:MANECTITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:INTIMIDATE) if pokemon.form==1
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

MultipleForms.register(:BANETTE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:BANETTITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:PRANKSTER) if pokemon.form==1
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

MultipleForms.register(:ABSOL,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:ABSOLITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:MAGICBOUNCE) if pokemon.form==1
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

MultipleForms.register(:GARCHOMP,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:GARCHOMPITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:SANDFORCE) if pokemon.form==1
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

MultipleForms.register(:LUCARIO,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:LUCARIONITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:ADAPTABILITY) if pokemon.form==1
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

MultipleForms.register(:ABOMASNOW,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:ABOMASITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:SNOWWARNING) if pokemon.form==1
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

MultipleForms.register(:BEEDRILL,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:BEEDRILLITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:ADAPTABILITY) if pokemon.form==1
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

MultipleForms.register(:PIDGEOT,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:PIDGEOTITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:NOGUARD) if pokemon.form==1
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

MultipleForms.register(:SLOWBRO,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:SLOWBRONITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:SHELLARMOR) if pokemon.form==1
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

MultipleForms.register(:STEELIX,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:STEELIXITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Steelix") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [75,125,230,30,55,95] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:SANDFORCE) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 105 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 7400 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SCEPTILE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:SCEPTILITE) || pokemon.isPreMega?)
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
      next getID(PBTypes,:DRAGON) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:LIGHTNINGROD) if pokemon.form==1
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

MultipleForms.register(:SWAMPERT,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:SWAMPERTITE) || pokemon.isPreMega?
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
      next [100,150,110,70,95,110] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:SWIFTSWIM) if pokemon.form==1
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

MultipleForms.register(:SABLEYE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:SABLENITE) || pokemon.isPreMega?
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
      next getID(PBAbilities,:MAGICBOUNCE) if pokemon.form==1
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

MultipleForms.register(:SHARPEDO,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:SHARPEDONITE) || pokemon.isPreMega?
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
      next getID(PBAbilities,:STRONGJAW) if pokemon.form==1
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

MultipleForms.register(:CAMERUPT,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:CAMERUPTITE) || pokemon.isPreMega?
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Camerupt") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [70,120,100,20,145,105] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:SHEERFORCE) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 25 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 3205 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ALTARIA,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:ALTARIANITE) || pokemon.isPreMega?
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
      next getID(PBTypes,:FAIRY) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:PIXILATE) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 15 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 206 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:GLALIE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:GLALITITE) || pokemon.isPreMega?
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
      next getID(PBAbilities,:REFRIGERATE) if pokemon.form==1
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

MultipleForms.register(:SALAMENCE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:SALAMENCITE) || pokemon.isPreMega?
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
      next getID(PBAbilities,:AERILATE) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 18 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 1126 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:METAGROSS,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:METAGROSSITE) || pokemon.isPreMega?
      next 1 if pokemon.isPreMega?
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
      next getID(PBAbilities,:TOUGHCLAWS) if pokemon.form==1
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

MultipleForms.register(:LATIAS,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:LATIASITE)
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
      next getID(PBAbilities,:LEVITATE) if pokemon.form==1
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

MultipleForms.register(:LATIOS,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:LATIOSITE) || pokemon.isPreMega?)
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
      next getID(PBAbilities,:LEVITATE) if pokemon.form==1
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

MultipleForms.register(:RAYQUAZA,{
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
      next getID(PBAbilities,:DELTASTREAM) if pokemon.form==1
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

MultipleForms.register(:LOPUNNY,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:LOPUNNITE)
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
      next getID(PBTypes,:FIGHTING) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:SCRAPPY) if pokemon.form==1
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

MultipleForms.register(:GALLADE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:GALLADITE)
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
      next getID(PBAbilities,:INNERFOCUS) if pokemon.form==1
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

MultipleForms.register(:AUDINO,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:AUDINITE)
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
      next getID(PBTypes,:FAIRY) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:HEALER) if pokemon.form==1
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

MultipleForms.register(:DIANCIE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DIANCITE)
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
      next getID(PBAbilities,:MAGICBOUNCE) if pokemon.form==1
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
#######################GIGANTAMAX MEGAS##############################
MultipleForms.register(:BUTTERFREE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:BUTTERFREENITE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Butterfree") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [60,45,50,120,140,80] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:TINTEDLENS) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 307 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 705 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MACHAMP,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:MACHAMPITE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Machamp") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [90,170,105,65,70,105] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:NOGUARD) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 503 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2866 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:KINGLER,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:KINGLERITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Kingler") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [55,169,135,96,60,60] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:SHEERFORCE) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 403 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 1332 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SNORLAX,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:SNORLAXITE) || pokemon.isPreMega?)
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Snorlax") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [160,140,95,20,75,150] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:THICKFAT) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 7111 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 100141 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:GARBODOR,{
    "getMegaForm"=>proc{|pokemon|
      next 2 if (isConst?(pokemon.item,PBItems,:GARBODORITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Garbodor") if pokemon.form==2
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [80,135,107,85,60,107] if pokemon.form==2
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:NEUTRALIZINGGAS) if pokemon.form==2
      next
    },
    "height"=>proc{|pokemon|
      next 6033 if pokemon.form==2
      next
    },
    "weight"=>proc{|pokemon|
      next 2366 if pokemon.form==2
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MELMETAL,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:MELMETALITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Melmetal") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [135,183,163,45,85,85] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:IRONFIST) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 802 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 17637 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:CORVIKNIGHT,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:CORVIKNITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Corviknight") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [98,122,145,67,53,110] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:MIRRORARMOR) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 703 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 1653 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ORBEETLE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:ORBEETLENITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Orbeetle") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [60,75,130,105,95,140] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:PRANKSTER) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 1011 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 899 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:DREDNAW,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:DREDNAWTITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Drednaw") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [90,155,110,94,48,88] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:STRONGJAW) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:COALOSSAL,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:COALOSSALITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Coalossal") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [110,135,150,35,80,100] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:STEAMENGINE) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 13710 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 8845 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:FLAPPLE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:FLAPPLETITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Flapple") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [70,130,105,90,110,80] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:OWNTEMPO) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:APPLETUN,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:APPLETUNITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Appletun") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [110,95,110,20,140,110] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:THICKFAT) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SANDACONDA,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:SANDACONDITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Sandaconda") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [72,127,125,91,105,90] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:THICKFAT) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })



MultipleForms.register(:CENTISKORCH,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:CENTISKORCHITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Centiskorch") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [100,140,75,110,90,110] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:FLASHFIRE) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:HATTERENE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:HATTERENITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Hatterene") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [57,107,115,25,166,130] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:MAGICBOUNCE) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:GRIMMSNARL,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:GRIMMSNARLITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Grimmsnarl") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [95,145,105,80,75,105] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:PRANKSTER) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })


MultipleForms.register(:ALCREMIE,{
    "getMegaForm"=>proc{|pokemon|
      next 8 if (isConst?(pokemon.item,PBItems,:ALCREMITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Alcremie") if pokemon.form==8
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [65,80,105,74,130,141] if pokemon.form==8
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:AROMAVEIL) if pokemon.form==8
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==8
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==8
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:COPPERAJAH,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:COPPERAJITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Copperajah") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [122,155,84,40,94,105] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:SHEERFORCE) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:DURALUDON,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if (isConst?(pokemon.item,PBItems,:DURALUDONITE) || pokemon.isPreMega?)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Mega Duraludon") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [70,95,130,110,150,80] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:LIGHTNINGROD) if pokemon.form==1
      next
    },
    "height"=>proc{|pokemon|
      next 303 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 2456 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })
#######################DIMENSIONAL RIFT FORMS##############################
MultipleForms.register(:GALVANTULA,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Galvantula") if pokemon.form==1
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:POISON) if pokemon.form==1
      next
    },   
    "getBaseStats"=>proc{|pokemon|
      next [70,80,100,130,80,160] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:PARENTALBOND) if pokemon.form==1
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
MultipleForms.register(:VOLCANION,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("DEMON Volcanion") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [110,60,80,20,90,200] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:WATERABSORB) if pokemon.form==1
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
MultipleForms.register(:CHANDELURE,{
    "getMegaForm"=>proc{|pokemon|
      next 2 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0 if pokemon.form==2
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Aevian Chandelure") if pokemon.form==1
      next _INTL("Rift Chandelure") if pokemon.form==2
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0
        next
      when 1
        next [65,55,90,80,145,90]
      when 2
        next [110,25,69,100,200,110] 
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:GHOST)
      when 2  # Rift
        next 
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Aevian
        next getID(PBTypes,:ELECTRIC)
      when 2  # Rift
        next 
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0 || pokemon.form==1      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1; movelist=[[1,:THUNDERSHOCK],[1,:THUNDERWAVE],[1,:PAINSPLIT],[1,:CONFUSERAY],[1,:HEX],[1,:ZAPCANNON]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0 || pokemon.form==1
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :CALMMIND,:TOXIC,:HIDDENPOWER,:TAUNT,:HYPERBEAM,:PROTECT,:RAINDANCE,:SECRETPOWER,:SAFEGUARD,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:TORMENT,:FACADE,:FLAMECHARGE,:REST,:ATTRACT,:THIEF,:ROUND,:OVERHEAT,:CHARGEBEAM,:WILLOWISP,:EMBARGO,:PAYBACK,:GIGAIMPACT,:FLASH,:VOLTSWITCH,:THUNDERWAVE,:PSYCHUP,:DREAMEATER,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:FLASHCANNON,:TRICKROOM,:DARKPULSE,:CONFIDE,:FIRESPIN,:HEX,:ELECTRICTERRAIN,:EERIEIMPULSE,:ZAPCANNON,
          # Move Tutors
          :SNORE,:ELECTROWEB,:UPROAR,:SHOCKWAVE,:RECYCLE,:SPITE,:ALLYSWITCH,:SIGNALBEAM,:IRONDEFENSE,:MAGNETRISE,:PAINSPLIT,:ICYWIND,:LASERFOCUS,:TRICK,:MAGICROOM,:WONDERROOM,:FOULPLAY,:SKILLSWAP,:SPIKES,:ENDURE,:FUTURESIGHT,:ELECTROBALL,:STOREDPOWER]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Aevian
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:ILLUMINATE)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:VOLTABSORB)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:LEVITATE)
        end
      when 2 # Rift
        next getID(PBAbilities,:PROTEAN)
      end  
    },
    "weight"=>proc{|pokemon|
      next 1011 if pokemon.form==2
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })
MultipleForms.register(:CARNIVINE,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Carnivine") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [80,110,75,115,120,100] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:THICKFAT) if pokemon.form==1
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:DRAGON) if pokemon.form==1
    },
    "weight"=>proc{|pokemon|
      next 1011 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })
MultipleForms.register(:GARBODOR,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Garbodor") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [120,80,190,10,120,190] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:POISONHEAL) if pokemon.form==1
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:DARK) if pokemon.form==1
    },
    "weight"=>proc{|pokemon|
      next 1011 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:FERROTHORN,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Ferrothorn") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [300,80,240,20,80,250] if pokemon.form==1
      next [600,250,100,240,80,100] if pokemon.form==2
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:SHIFT) if pokemon.form==1
      next getID(PBAbilities,:SHIFT) if pokemon.form==2
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:FIRE) if pokemon.form==1
      next getID(PBTypes,:FIRE) if pokemon.form==2
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:STEEL) if pokemon.form==1
      next getID(PBTypes,:STEEL) if pokemon.form==2
      next
    },
    "weight"=>proc{|pokemon|
      next 110 if pokemon.form==1
      next 2101 if pokemon.form==2
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })
MultipleForms.register(:DARKRAI,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Puppet Master") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [500,50,300,1,60,300] if pokemon.form==1
      next [500,1,80,1,80,1] if pokemon.form==2
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:WORLDOFNIGHTMARES) if pokemon.form==1
      next getID(PBAbilities,:WORLDOFNIGHTMARES) if pokemon.form==1
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:DARK) if pokemon.form==1
      next getID(PBTypes,:DARK) if pokemon.form==2
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:PSYCHIC) if pokemon.form==1
      next getID(PBTypes,:PSYCHIC) if pokemon.form==2
    },
    "weight"=>proc{|pokemon|
      next 1011 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:XERNEAS,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Storm-9 Wind") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [450,70,150,20,140,150] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:TEMPEST) if pokemon.form==1
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:FLYING) if pokemon.form==1
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:FLYING) if pokemon.form==1
    },
    "weight"=>proc{|pokemon|
      next 0001 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:REGIROCK,{
    "getBaseStats"=>proc{|pokemon|
      next [200,120,200,160,120,150] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:SAVAGERY) if pokemon.form==1
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:ROCK) if pokemon.form==1
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:FIGHTING) if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 110 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })
MultipleForms.register(:TANGELA,{
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:TANGLINGHAIR) if pokemon.form==1
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:GRASS) if pokemon.form==1
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:DARK) if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })
MultipleForms.register(:TANGROWTH,{
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:TANGLINGHAIR) if pokemon.form==1
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:GRASS) if pokemon.form==1
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:GHOST) if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })
MultipleForms.register(:RALTS,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Ralts") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [100,50,80,105,50,80] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:FRIENDGUARD) if pokemon.form==1
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:FAIRY) if pokemon.form==1
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:POISON) if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 70 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })
MultipleForms.register(:KIRLIA,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Kirlia") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [100,50,90,105,50,90] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:FRIENDGUARD) if pokemon.form==1
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:FAIRY) if pokemon.form==1
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:FIRE) if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 110 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:HIPPOWDON,{
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:POISON) if pokemon.form==1
      next getID(PBTypes,:POISON) if pokemon.form==2
      next
    },  
    "getBaseStats"=>proc{|pokemon|
      next [200,152,180,47,152,142] if pokemon.form==1
      next [158,162,158,47,118,122] if pokemon.form==2
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:ACCUMULATION) if pokemon.form==1
      next getID(PBAbilities,:ACCUMULATION) if pokemon.form==2
      next
    },
    "weight"=>proc{|pokemon|
      next 2025 if pokemon.form==1
      next 1855 if pokemon.form==2
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:FROSLASS,{
    "getMegaForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Froslass and Rotom") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [300,60,150,60,130,150] if pokemon.form==1 #Clefairy Doll
      next [500,60,130,180,300,130] if pokemon.form==2 #Released Form
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:TEMPORALSHIFT) if pokemon.form==1
      next getID(PBAbilities,:TEMPORALSHIFT) if pokemon.form==2
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:ELECTRIC) if pokemon.form==1
      next getID(PBTypes,:ELECTRIC) if pokemon.form==2
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:FAIRY) if pokemon.form==1
      next getID(PBTypes,:ICE) if pokemon.form==2
      next
    },
    "weight"=>proc{|pokemon|
      next 10 if pokemon.form==1
      next 60 if pokemon.form==2
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

#### MECH Variants ############################################################
MultipleForms.register(:MAGNETON,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                        # Standard Mode
      next [80,1,90,40,150,120] if pokemon.form==1 # Amalgamation
      
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [0,0,0,0,0,0] if pokemon.form==1 # Amalgamation
      
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:ADAPTABILITY) if pokemon.form==1
      next
    }
  })

MultipleForms.register(:CLAYDOL,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                       # Standard Mode
      next [120,1,180,50,70,180] if pokemon.form==1 # Amalgamation
      
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [0,0,0,0,0,0] if pokemon.form==1 # Amalgamation
      
    },
    
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:STEEL) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:AFTERMATH) if pokemon.form==1
      next
    }
  })

MultipleForms.register(:GOLURK,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                       # Standard Mode
      next [120,180,90,40,90,90] if pokemon.form==1 # Amalgamation
      
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [0,0,0,0,0,0] if pokemon.form==1 # Amalgamation
      
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:STEEL) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:AFTERMATH) if pokemon.form==1
      next
    }
  })

MultipleForms.register(:SIGILYPH,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                         # Standard Mode
      next [80,50,70,80,150,90] if pokemon.form==1 # Amalgamation
      
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [0,0,0,0,0,0] if pokemon.form==1 # Amalgamation
      
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:STEEL) if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:AFTERMATH) if pokemon.form==1
      next
    }
  })

MultipleForms.register(:METANG,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                         # Standard Mode
      next [80,120,120,80,60,90] if pokemon.form==1 # Amalgamation
      
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [0,0,0,0,0,0] if pokemon.form==1 # Amalgamation
      
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:IRONFIST) if pokemon.form==1
      next
    }
  })

MultipleForms.register(:LAIRON,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                         # Standard Mode
      next [80,110,90,140,70,70] if pokemon.form==1 # Amalgamation
      
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [0,0,0,0,0,0] if pokemon.form==1 # Amalgamation
      
    },
    "type2"=>proc{|pokemon|
      next (PBTypes::STEEL) if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 7500 if pokemon.form==1
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:STRONGJAW) if pokemon.form==1
      next
    }
  })

##### Misc forms ###############################################################
MultipleForms.register(:MUNNA,{
    "getBaseStats"=>proc{|pokemon|
      next [76,67,45,24,25,45] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Aevian
        next getID(PBAbilities,:BADDREAMS)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SHEDSKIN)  
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
          next getID(PBAbilities,:TOUGHCLAWS)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 1 ; movelist=[[1,:DRAININGKISS],[1,:LEER],[5,:SCRATCH],[7,:YAWN],[11,:ASSURANCE],[13,:NIGHTMARE],[17,:MOONLIGHT],[19,:HYPNOSIS],
          [23,:NIGHTSLASH],[25,:SLASH],[29,:PLAYROUGH],[31,:SHADOWCLAW],[35,:HONECLAWS],[41,:LOVELYKISS],[43,:GLARE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HAIL,:HIDDENPOWER,:TAUNT,:HYPERBEAM,:PROTECT,:SECRETPOWER,:FRUSTRATION,
          :SMACKDOWN,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:SANDSTORM,:ROCKTOMB,:AERIALACE,:TORMENT,
          :FACADE,:REST,:ATTRACT,:FALSESWIPE,:FLING,:CHARGEBEAM,:QUASH,:SHADOWCLAW,:PAYBACK,:GIGAIMPACT,
          :GYROBALL,:SWORDSDANCE,:PSYCHUP,:DREAMEATER,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:TRICKROOM,:SNARL,
          :DARKPULSE,:DAZZLINGGLEAM,:CONFIDE,:LEECHLIFE,:SCREECH,:SCARYFACE,:FAKETEARS,:ASSURANCE,
          :POWERSWAP,:DRAININGKISS,:HONECLAWS,:CUT,
        # Move Tutors
          :SNORE,:UPROAR,:WORRYSEED,:SNATCH,:SPITE,:GRAVITY,:WATERPULSE,:PAINSPLIT,:LASERFOCUS,:TRICK,
          :MAGICROOM,:WONDERROOM,:GASTROACID,:THROATCHOP,:SKILLSWAP,:KNOCKOFF,:AMNESIA,:BATONPASS,:ENCORE,
          :FUTURESIGHT,:AURASPHERE,:PLAYROUGH]
    end
    for i in 0...movelist.length
      movelist[i]=getConst(PBMoves,movelist[i])
    end
    next movelist
  },
  "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:ASSIST,:CURSE,:DISABLE,:ENCORE,
          :MEANLOOK,:MEMENTO,:NIGHTSHADE,:SNORE,
          :SONICBOOM]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
  "type1"=>proc{|pokemon|
    next getID(PBTypes,:DARK) if pokemon.form==1
  },
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:FAIRY) if  pokemon.form==1
  },
  "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[33,1042,518]]                        # Aevian   
  },
  "weight"=>proc{|pokemon|
    next 101 if pokemon.form==1
    next
  },
  "getFormOnCreation"=>proc{|pokemon|
      maps=[57] # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
  "onSetForm"=>proc{|pokemon,form|
    pbSeenForm(pokemon)
  }
})
MultipleForms.register(:MUSHARNA,{
    "getMegaForm"=>proc{|pokemon|
      next 2 if isConst?(pokemon.item,PBItems,:PULSEPLUS)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0 if pokemon.form==2
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Pulse+ Musharna") if pokemon.form==2
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [116,107,85,29,65,85] if pokemon.form==1
      next [115,50,90,10,90,80] if pokemon.form==2
      next
    },
    
    "ability"=>proc{|pokemon|
      next if pokemon.form==0
      if pokemon.form==1
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
          next getID(PBAbilities,:BADDREAMS)
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:SHEDSKIN)  
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
            next getID(PBAbilities,:TOUGHCLAWS)
        end
      end
      next getID(PBAbilities,:MISTYSURGE) if pokemon.form==2
      next
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Aevian
      when 1 ; movelist=[[1,:MISTYTERRAIN],[1,:DRAININGKISS],[1,:LEER],
        [1,:ASSURANCE],[1,:LOVELYKISS]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HAIL,:HIDDENPOWER,:TAUNT,:HYPERBEAM,:PROTECT,:SECRETPOWER,
          :FRUSTRATION,:SMACKDOWN,:RETURN,:PSYCHIC,:SHADOWBALL,:DOUBLETEAM,:SANDSTORM,
          :ROCKTOMB,:AERIALACE,:TORMENT,:FACADE,:REST,:ATTRACT,:FALSESWIPE,:FLING,:CHARGEBEAM,
          :QUASH,:WILLOWISP,:EXPLOSION,:SHADOWCLAW,:PAYBACK,:GIGAIMPACT,:GYROBALL,:SWORDSDANCE,
          :PSYCHUP,:ROCKSLIDE,:XSCISSOR,:POISONJAB,:DREAMEATER,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,
          :TRICKROOM,:ROCKSMASH,:SNARL,:DARKPULSE,:DAZZLINGGLEAM,:CONFIDE,:ROCKCLIMB,:SLASHANDBURN,
          :BRUTALSWING,:LEECHLIFE,:SCREECH,:SELFDESTRUCT,:SCARYFACE,:BEATUP,:FAKETEARS,:ASSURANCE,
          :POWERSWAP,:PSYCHOCUT,:CROSSPOISON,:PHANTOMFORCE,:DRAININGKISS,:MISTYTERRAIN,:EERIEIMPULSE,
          :BREAKINGSWIPE,:HONECLAWS,:CUT,:FLY,:STRENGTH,
        # Move Tutors
        :SNORE,:UPROAR,:BLOCK,:WORRYSEED,:SNATCH,:SPITE,:GRAVITY,:WATERPULSE,
        :PAINSPLIT,:ZENHEADBUTT,:LASERFOCUS,:TRICK,:MAGICROOM,:WONDERROOM,:GASTROACID,
        :FOULPLAY,:THROATCHOP,:SKILLSWAP,:DUALCHOP,:KNOCKOFF,:BODYSLAM,:AMNESIA,:BATONPASS,:ENCORE,
        :FUTURESIGHT,:AURASPHERE,:POWERGEM,:STOREDPOWER,:PLAYROUGH,:VENOMDRENCH,:DARKESTLARIAT,:BODYPRESS]
    end
    for i in 0...movelist.length
      movelist[i]=getConst(PBMoves,movelist[i])
    end
    next movelist
  },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Aevian
      when 1 ; eggmovelist=[:ASSIST,:CURSE,:DISABLE,:ENCORE,
          :MEANLOOK,:MEMENTO,:NIGHTSHADE,:SNORE,
          :SONICBOOM]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
  "type1"=>proc{|pokemon|
    next getID(PBTypes,:DARK) if pokemon.form==1
  },
  "type2"=>proc{|pokemon|
    next getID(PBTypes,:FAIRY) if  pokemon.form==1
    next getID(PBTypes,:FAIRY) if  pokemon.form==2
  },
  "weight"=>proc{|pokemon|
    next 1011 if pokemon.form==2
    next
  },
  "onSetForm"=>proc{|pokemon,form|
    pbSeenForm(pokemon)
  }
})


MultipleForms.register(:SOLROCK,{
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 1; next [90,110,90,44,75,90] # Solrock Dominant
      when 2; next [90,44,90,75,110,90] # Lunatone Dominant
      else;   next                          
      end
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 1; next getID(PBAbilities,:SOLARIDOL)
      when 2; next getID(PBAbilities,:LUNARIDOL)
      else;   next                                
      end
    },
    "evYield"=>proc{|pokemon|
      case pokemon.form
      when 1; next [0,3,0,0,0,0] # Solrock dom
      when 2; next [0,0,0,0,3,0] # Solrock dom
      else;   next               # Kyurem
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[[1,:FIRESPIN],[1,:ROCKTOMB],[8,:IMPRISON],
          [15,:COSMICPOWER],[22,:SMACKDOWN],[29,:ROCKPOLISH],
          [32,:STONEEDGE],[37,:TAKEDOWN],[43,:BULLDOZE],
          [46,:PSYCHIC],[50,:ZENHEADBUTT],[58,:FLAREBLITZ],
          [68,:SOLARBEAM],[80,:SOLARFLARE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    }
  })

MultipleForms.register(:JIGGLYPUFF,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                       # Standard Mode
      next [73,73,73,121,127,73] if pokemon.form==1 # Tuff Puff
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [0,2,0,0,2,0] if pokemon.form==1 # Tuff Puff
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0               # Normal
      if pokemon.abilityflag && pokemon.abilityflag!=2
        next getID(PBAbilities,:BEASTBOOST) if pokemon.form==1 # Tuff Puff
      end
    }
  })

MultipleForms.register(:GOOMY,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                           # Standard Mode
      next [90,90,90,90,90,90] if pokemon.form==1       # Goomink
      next [100,130,95,95,95,110] if pokemon.form==2    # Goomink Hero
      next [120,150,140,100,100,140] if pokemon.form==3 # Goomink Actual Hero
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [0,2,0,0,2,0] if pokemon.form==1 # Goomink
      next [0,4,0,0,0,0] if pokemon.form==2 # Goomink Actual Hero
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:JUSTIFIED) if pokemon.form==2
      next getID(PBAbilities,:JUSTIFIED) if pokemon.form==3
      next
    }
  })

MultipleForms.register(:WAILORD,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                        # Standard Mode
      next [800,100,80,80,90,100] if pokemon.form==1 # Kawopudunga
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [4,0,0,0,0,0] if pokemon.form==1 # Kawopudunga
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:WATERVEIL) if pokemon.form==1
      next
    }
  })

MultipleForms.register(:EMBOAR,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                        # Standard Mode
      next [120,195,110,80,10,10] if pokemon.form==1 # Big Betty
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [0,4,0,0,0,0] if pokemon.form==1 # Big Betty
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:RECKLESS) if pokemon.form==1
      next
    }
  })

MultipleForms.register(:PIKACHU,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0             # Normal
      case pokemon.form
      when 2; next [55,80,50,120,75,60] # Tazer/Partner Forme
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:EEVEE,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0             # Normal
      case pokemon.form
      when 2; next [65,75,70,75,65,85] # Tazer/Partner Forme
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MELTAN,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0               # Standard Mode
      next [5,5,5,5,5,5] if pokemon.form==1 # HP
      next [5,5,5,5,5,5] if pokemon.form==2 # ATTACK
      next [5,5,5,5,5,5] if pokemon.form==3 # DEFENSE
      next [5,5,5,5,5,5] if pokemon.form==4 # SPEED
      next [5,5,5,5,5,5] if pokemon.form==5 # SP. DEF
      next [5,5,5,5,5,5] if pokemon.form==6 # SP ATT
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0 # Standard Mode
      next [12,0,0,0,0,0] if pokemon.form==1 # HP
      next [0,12,0,0,0,0] if pokemon.form==2 # ATT
      next [0,0,12,0,0,0] if pokemon.form==3 # DEF
      next [0,0,0,12,0,0] if pokemon.form==4 # SPEED
      next [0,0,0,0,12,0] if pokemon.form==5 # SP DEF
      next [0,0,0,0,0,12] if pokemon.form==6 # SP ATT
    }
  })

MultipleForms.register(:DELPHOX,{
    "getMegaName"=>proc{|pokemon|
      next _INTL("Augmented Delphox") if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next [95,145,95,120,153,98] if pokemon.form==1
      next
    },
    "ability"=>proc{|pokemon|
      next getID(PBAbilities,:ADAPTABILITY) if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 86 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })