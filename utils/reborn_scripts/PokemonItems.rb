ITEMID        = 0
ITEMNAME      = 1
ITEMPOCKET    = 2
ITEMPRICE     = 3
ITEMDESC      = 4
ITEMUSE       = 5
ITEMBATTLEUSE = 6
ITEMTYPE      = 7
ITEMMACHINE   = 8


SEEDS = [PBItems::ELEMENTALSEED,PBItems::MAGICALSEED,PBItems::TELLURICSEED,PBItems::SYNTHETICSEED]
GEMS = [PBItems::FIREGEM,PBItems::WATERGEM,PBItems::ELECTRICGEM,PBItems::GRASSGEM,
  PBItems::ICEGEM,PBItems::FIGHTINGGEM,PBItems::POISONGEM,PBItems::GROUNDGEM,
  PBItems::FLYINGGEM,PBItems::PSYCHICGEM,PBItems::BUGGEM,PBItems::ROCKGEM,
  PBItems::GHOSTGEM,PBItems::DRAGONGEM,PBItems::DARKGEM,PBItems::STEELGEM,
  PBItems::NORMALGEM,PBItems::FAIRYGEM]
EVOSTONES = [PBItems::FIRESTONE,PBItems::THUNDERSTONE,PBItems::WATERSTONE,
  PBItems::LEAFSTONE,PBItems::MOONSTONE,PBItems::SUNSTONE,PBItems::DUSKSTONE,
  PBItems::DAWNSTONE,PBItems::SHINYSTONE,PBItems::LINKSTONE,PBItems::ICESTONE]
MULCH = [PBItems::GROWTHMULCH,PBItems::DAMPMULCH,PBItems::STABLEMULCH,PBItems::GOOEYMULCH]

def pbIsHiddenMove?(move)
  return false if !$cache.items
  for i in 0...$cache.items.length
    next if !$cache.items[i]
    next if !pbIsHiddenMachine?(i)
    atk=$cache.items[i][ITEMMACHINE]
    return true if move==atk
  end
  return false
end

def pbGetPrice(item)
  return $cache.items[item][ITEMPRICE]
end

def pbGetPocket(item)
  return $cache.items[item][ITEMPOCKET]
end

# Important items can't be sold, given to hold, or tossed.
def pbIsImportantItem?(item)
  return $cache.items[item] && (pbIsKeyItem?(item) || pbIsHiddenMachine?(item) ||
                             (INFINITETMS && pbIsTechnicalMachine?(item)) ||
                             pbIsZCrystal2?(item))
end

def pbIsMachine?(item)
  return $cache.items[item] && (pbIsTechnicalMachine?(item) || pbIsHiddenMachine?(item))
end

def pbIsTechnicalMachine?(item)
  return $cache.items[item] && ($cache.items[item][ITEMUSE]==3)
end

def pbIsHiddenMachine?(item)
  return $cache.items[item] && ($cache.items[item][ITEMUSE]==4)
end

def pbIsMail?(item)
  return $cache.items[item] && ($cache.items[item][ITEMTYPE]==1 || $cache.items[item][ITEMTYPE]==2)
end

def pbIsSnagBall?(item)
  return $cache.items[item] && ($cache.items[item][ITEMTYPE]==3 ||
                            ($cache.items[item][ITEMTYPE]==4 && $PokemonGlobal.snagMachine))
end

def pbIsPokeBall?(item)
  return $cache.items[item] && ($cache.items[item][ITEMTYPE]==3 || $cache.items[item][ITEMTYPE]==4)
end

def pbIsBerry?(item)
  return $cache.items[item] && ($cache.items[item][ITEMTYPE]==5)
end

def pbIsSeed?(item)
  return true if SEEDS.include?(item)
  return false  
end

def pbIsTypeGem?(item)
  return true if GEMS.include?(item)
  return false
end

def pbIsKeyItem?(item)
  return $cache.items[item] && ($cache.items[item][ITEMTYPE]==6)
end

def pbIsZCrystal?(item)
  return $cache.items[item] && ($cache.items[item][ITEMTYPE]==7)
end

def pbIsZCrystal2?(item)
  return $cache.items[item] && ($cache.items[item][ITEMTYPE]==8)
end

def pbIsBattleEndingItem?(item)
  return false
end

def pbIsEvolutionStone?(item)
  return true if EVOSTONES.include?(item)
  return false
end

def pbIsMulch?(item)
  return true if MULCH.include?(item)
  return false
end

def pbIsGoodItem(item)
  return [PBItems::CHOICEBAND,PBItems::CHOICESCARF,PBItems::CHOICESPECS,PBItems::FOCUSSASH,
          PBItems::LUCKYEGG,PBItems::EXPSHARE,PBItems::LIFEORB,PBItems::LEFTOVERS,PBItems::EVIOLITE,
          PBItems::ASSAULTVEST,PBItems::ROCKYHELMET].include?(item) || pbGetMegaStoneList.include?(item)
end

def pbTopRightWindow(text)
  window=Window_AdvancedTextPokemon.new(text)
  window.z=99999
  window.width=198
  window.y=0
  window.x=Graphics.width-window.width
  pbPlayDecisionSE()
  loop do
    Graphics.update
    Input.update
    window.update
    if Input.trigger?(Input::C)
      break
    end
  end
  window.dispose
end

class ItemHandlerHash < HandlerHash
  def initialize
    super(:PBItems)
  end
end

module ItemHandlers
  UseFromBag=ItemHandlerHash.new
  UseInField=ItemHandlerHash.new
  UseOnPokemon=ItemHandlerHash.new
  BattleUseOnBattler=ItemHandlerHash.new
  BattleUseOnPokemon=ItemHandlerHash.new
  UseInBattle=ItemHandlerHash.new
  MultipleAtOnce=arrayToConstant(PBItems,[:EXPCANDYL,:EXPCANDYXL,:EXPCANDYM,:EXPCANDYS,:EXPCANDYXS, :RARECANDY])

  def self.addUseFromBag(item,proc)
    UseFromBag.add(item,proc)
  end

  def self.addUseInField(item,proc)
    UseInField.add(item,proc)
  end

  def self.addUseOnPokemon(item,proc)
    UseOnPokemon.add(item,proc)
  end

  def self.addBattleUseOnBattler(item,proc)
    BattleUseOnBattler.add(item,proc)
  end

  def self.addBattleUseOnPokemon(item,proc)
    BattleUseOnPokemon.add(item,proc)
  end

  def self.hasOutHandler(item)                       # Shows "Use" option in Bag
    return UseFromBag[item]!=nil || UseOnPokemon[item]!=nil
  end

  def self.hasKeyItemHandler(item)              # Shows "Register" option in Bag
    return UseInField[item]!=nil
  end

  def self.hasBattleUseOnBattler(item)
    return BattleUseOnBattler[item]!=nil
  end

  def self.hasBattleUseOnPokemon(item)
    return BattleUseOnPokemon[item]!=nil
  end

  def self.hasUseInBattle(item)
    return UseInBattle[item]!=nil
  end

  def self.triggerUseFromBag(item)
    # Return value:
    # 0 - Item not used
    # 1 - Item used, don't end screen
    # 2 - Item used, end screen
    # 3 - Item used, consume item
    # 4 - Item used, end screen, consume item
    if !UseFromBag[item]
      # Check the UseInField handler if present
      if UseInField[item]
        UseInField.trigger(item)
        return 1 # item was used
      end
      return 0 # item was not used
    else
      UseFromBag.trigger(item)
    end
  end

  def self.triggerUseInField(item)
    # No return value
    if !UseInField[item]
      return false
    else
      UseInField.trigger(item)
      return true
    end
  end

  def self.triggerUseOnPokemon(item,pokemon,scene)
    # Returns whether item was used
    if !UseOnPokemon[item]
      return false
    else
      return UseOnPokemon.trigger(item,pokemon,scene)
    end
  end

  def self.triggerBattleUseOnBattler(item,battler,scene)
    # Returns whether item was used
    if !BattleUseOnBattler[item]
      return false
    else
      return BattleUseOnBattler.trigger(item,battler,scene)
    end
  end

  def self.triggerBattleUseOnPokemon(item,pokemon,battler,scene)
    # Returns whether item was used
    if !BattleUseOnPokemon[item]
      return false
    else
      return BattleUseOnPokemon.trigger(item,pokemon,battler,scene)
    end
  end

  def self.triggerUseInBattle(item,battler,battle)
    # Returns whether item was used
    if !UseInBattle[item]
      return
    else
      UseInBattle.trigger(item,battler,battle)
    end
  end
end



def pbItemRestoreHP(pokemon,restorehp)
  newhp=pokemon.hp+restorehp
  newhp=pokemon.totalhp if newhp>pokemon.totalhp
  hpgain=newhp-pokemon.hp
  pokemon.hp=newhp
  return hpgain
end

def pbHPItem(pokemon,restorehp,scene)
  if pokemon.hp<=0 || pokemon.hp==pokemon.totalhp || pokemon.isEgg?
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  else
    hpgain=pbItemRestoreHP(pokemon,restorehp)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pokemon.name,hpgain))
    return true
  end
end

def pbBattleHPItem(pokemon,battler,restorehp,scene)
  if pokemon.hp<=0 || pokemon.hp==pokemon.totalhp || pokemon.isEgg?
    scene.pbDisplay(_INTL("But it had no effect!"))
    return false
  else
    hpgain=pbItemRestoreHP(pokemon,restorehp)
    battler.hp=pokemon.hp if battler
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name,hpgain))
    return true
  end
end

def pbJustRaiseEffortValues(pokemon,ev,evgain)
  totalev=0
  for i in 0...6
    totalev+=pokemon.ev[i]
  end
  if totalev+evgain>510 && !$game_switches[:No_Total_EV_Cap]
    # Bug Fix: must use "-=" instead of "="
    evgain-=totalev+evgain-510
  end
  if pokemon.ev[ev]+evgain>252
    # Bug Fix: must use "-=" instead of "="
    evgain-=pokemon.ev[ev]+evgain-252
  end
  if evgain>0
    pokemon.ev[ev]+=evgain
    pokemon.calcStats
  end
  return evgain
end

def pbRaiseEffortValues(pokemon,ev,evgain=32,evlimit=true)
 # if pokemon.ev[ev]>=100 && evlimit
 #   return 0
 # end
  totalev=0
  for i in 0...6
    totalev+=pokemon.ev[i]
  end
  if totalev+evgain>510 && !$game_switches[:No_Total_EV_Cap]
    evgain=510-totalev
  end
  if pokemon.ev[ev]+evgain>252
    evgain=252-pokemon.ev[ev]
  end
  #if evlimit && pokemon.ev[ev]+evgain>100
  #  evgain=100-pokemon.ev[ev]
  #end
  if evgain>0
    pokemon.ev[ev]+=evgain
    pokemon.calcStats
  end
  return evgain
end

def pbRestorePP(pokemon,move,pp)
  return 0 if pokemon.moves[move].id==0
  return 0 if pokemon.moves[move].totalpp==0
  newpp=pokemon.moves[move].pp+pp
  if newpp>pokemon.moves[move].totalpp
    newpp=pokemon.moves[move].totalpp
  end
  oldpp=pokemon.moves[move].pp
  pokemon.moves[move].pp=newpp
  return newpp-oldpp
end

def pbBattleRestorePP(pokemon,battler,move,pp)
  ret=pbRestorePP(pokemon,move,pp)
  if ret>0
    battler.pbSetPP(battler.moves[move],pokemon.moves[move].pp) if battler
  end
  return ret
end

def pbBikeCheck
  if $PokemonGlobal.surfing ||
     (!$PokemonGlobal.bicycle && (pbGetTerrainTag==PBTerrain::TallGrass || pbGetTerrainTag==PBTerrain::SandDune))
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
    return false
  end
  if $PokemonGlobal.bicycle
    if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
      Kernel.pbMessage(_INTL("You can't dismount your Bike here."))
      return false
    end
    return true
  else
    val=pbGetMetadata($game_map.map_id,MetadataBicycle)
    val=pbGetMetadata($game_map.map_id,MetadataOutdoor) if val==nil
    if !val
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
    return true
  end
end

def pbClosestHiddenItem
  result = []
  playerX=$game_player.x
  playerY=$game_player.y
  for event in $game_map.events.values
    next if event.name!="HiddenItem"
    next if (playerX-event.x).abs>=8
    next if (playerY-event.y).abs>=6
    next if $game_self_switches[[$game_map.map_id,event.id,"A"]]
    next if $game_self_switches[[$game_map.map_id,event.id,"B"]]
    next if $game_self_switches[[$game_map.map_id,event.id,"C"]]
    next if $game_self_switches[[$game_map.map_id,event.id,"D"]]
    result.push(event)
  end
  return nil if result.length==0
  ret=nil
  retmin=0
  for event in result
    dist=(playerX-event.x).abs+(playerY-event.y).abs
    if !ret || retmin>dist
      ret=event
      retmin=dist
    end
  end
  return ret
end

def Kernel.pbUseKeyItemInField(item)
  if !ItemHandlers.triggerUseInField(item)
    Kernel.pbMessage(_INTL("Can't use that here.")) if $game_switches[:Application_Applied] === false
  end
end

def pbSpeciesCompatible?(species,move,pokemon)  
  ret=false
  return false if species<=0
  case species
    when PBSpecies::RATTATA #Rattata
      if pokemon.form==0
        if (move == PBMoves::SLUDGEBOMB) || (move == PBMoves::TORMENT) ||
          (move == PBMoves::QUASH) || (move == PBMoves::EMBARGO) ||
          (move == PBMoves::SHADOWCLAW) || (move == PBMoves::SNARL) ||
          (move == PBMoves::DARKPULSE) || (move == PBMoves::SNATCH)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::WORKUP) || (move == PBMoves::THUNDERBOLT) ||
          (move == PBMoves::THUNDER) || (move == PBMoves::CHARGEBEAM) ||
          (move == PBMoves::THUNDERWAVE) || (move == PBMoves::WILDCHARGE)
        end 
      end
    when PBSpecies::RATICATE #Raticate
      if pokemon.form==0
        if (move == PBMoves::SLUDGEBOMB) || (move == PBMoves::TORMENT) ||
          (move == PBMoves::QUASH) || (move == PBMoves::EMBARGO) ||
          (move == PBMoves::SHADOWCLAW) || (move == PBMoves::SNARL) ||
          (move == PBMoves::DARKPULSE) || (move == PBMoves::BULKUP) ||
          (move == PBMoves::VENOSHOCK) || (move == PBMoves::SLUDGEWAVE) || 
          (move == PBMoves::SNATCH) || (move == PBMoves::KNOCKOFF)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::WORKUP) || (move == PBMoves::THUNDERBOLT) ||
          (move == PBMoves::THUNDER) || (move == PBMoves::CHARGEBEAM) ||
          (move == PBMoves::THUNDERWAVE) || (move == PBMoves::WILDCHARGE)
          return false
        end 
      end      
    when PBSpecies::RAICHU #Raichu
      if pokemon.form==0
        if (move == PBMoves::PSYSHOCK) || (move == PBMoves::CALMMIND) ||
          (move == PBMoves::SAFEGUARD) || (move == PBMoves::PSYCHIC) ||
          (move == PBMoves::REFLECT) || (move == PBMoves::MAGICCOAT) ||
          (move == PBMoves::MAGICROOM) || (move == PBMoves::RECYCLE) ||
          (move == PBMoves::TELEKINESIS) || (move == PBMoves::ALLYSWITCH)
          return false
        end
      elsif pokemon.form==1        
      end     
    when PBSpecies::SANDSHREW #Sandshrew
      if pokemon.form==0
        if (move == PBMoves::WORKUP) || (move == PBMoves::HAIL) ||
          (move == PBMoves::BLIZZARD) || (move == PBMoves::LEECHLIFE) ||
          (move == PBMoves::FROSTBREATH) || (move == PBMoves::IRONHEAD) ||
          (move == PBMoves::ICEPUNCH) || (move == PBMoves::IRONDEFENSE) ||
          (move == PBMoves::ICYWIND) || (move == PBMoves::AQUATAIL) ||
          (move == PBMoves::THROATCHOP)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::SANDSTORM) || (move == PBMoves::ROCKTOMB) ||
          (move == PBMoves::EARTHPOWER) || (move == PBMoves::STOMPINGTANTRUM)
          return false
        end  
      end      
    when PBSpecies::SANDSLASH #Sandslash
      if pokemon.form==0
        if (move == PBMoves::WORKUP) || (move == PBMoves::HAIL) ||
          (move == PBMoves::BLIZZARD) || (move == PBMoves::LEECHLIFE) ||
          (move == PBMoves::AURORAVEIL) || (move == PBMoves::FROSTBREATH) ||
          (move == PBMoves::IRONHEAD) || (move == PBMoves::THROATCHOP) ||
          (move == PBMoves::ICEPUNCH) || (move == PBMoves::IRONDEFENSE) ||
          (move == PBMoves::ICYWIND) || (move == PBMoves::AQUATAIL)          
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::SANDSTORM) || (move == PBMoves::ROCKTOMB) ||
          (move == PBMoves::STONEEDGE) ||
          (move == PBMoves::EARTHPOWER) || (move == PBMoves::STOMPINGTANTRUM)
          return false
        end  
      end      
    when PBSpecies::VULPIX #Vulpix
      if pokemon.form==0
        if (move == PBMoves::HAIL) || (move == PBMoves::ICEBEAM) ||
          (move == PBMoves::BLIZZARD) || (move == PBMoves::RAINDANCE) ||
          (move == PBMoves::AURORAVEIL) || (move == PBMoves::FROSTBREATH) ||
          (move == PBMoves::ICYWIND) || (move == PBMoves::AQUATAIL) || 
          (move == PBMoves::HEALBELL)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::SUNNYDAY) || (move == PBMoves::FLAMETHROWER) ||
          (move == PBMoves::FIREBLAST) || (move == PBMoves::FLAMECHARGE) ||
          (move == PBMoves::OVERHEAT) || (move == PBMoves::ENERGYBALL) ||
          (move == PBMoves::WILLOWISP) ||
          (move == PBMoves::HEATWAVE) 
          return false
        end  
      end      
    when PBSpecies::NINETALES #Ninetales
      if pokemon.form==0
        if (move == PBMoves::HAIL) || (move == PBMoves::ICEBEAM) ||
          (move == PBMoves::BLIZZARD) || (move == PBMoves::RAINDANCE) ||
          (move == PBMoves::AURORAVEIL) || (move == PBMoves::FROSTBREATH) ||
          (move == PBMoves::DAZZLINGGLEAM) || (move == PBMoves::ICYWIND) || 
          (move == PBMoves::AQUATAIL) || (move == PBMoves::WONDERROOM) ||
          (move == PBMoves::HEALBELL)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::SUNNYDAY) || (move == PBMoves::FLAMETHROWER) ||
          (move == PBMoves::FIREBLAST) || (move == PBMoves::FLAMECHARGE) ||
          (move == PBMoves::OVERHEAT) || (move == PBMoves::ENERGYBALL) ||
          (move == PBMoves::WILLOWISP) || (move == PBMoves::SOLARBEAM) ||
          (move == PBMoves::HEATWAVE) 
          return false
        end  
      end  
    when PBSpecies::DIGLETT #Diglett
      if pokemon.form==0
        if (move == PBMoves::WORKUP) || (move == PBMoves::FLASHCANNON) ||
          (move == PBMoves::IRONDEFENSE) || (move == PBMoves::IRONHEAD)
          return false
        end
      elsif pokemon.form==1
      end       
    when PBSpecies::DUGTRIO #Dugtrio
      if pokemon.form==0
        if (move == PBMoves::WORKUP) || (move == PBMoves::FLASHCANNON) ||
          (move == PBMoves::IRONDEFENSE) || (move == PBMoves::IRONHEAD)
          return false
        end
      elsif pokemon.form==1
      end      
    when PBSpecies::MEOWTH #Meowth
      if pokemon.form==0
        if (move == PBMoves::QUASH) || (move == PBMoves::EMBARGO) ||
          (move == PBMoves::SWORDSDANCE) || (move == PBMoves::CRUNCH) ||
          (move == PBMoves::IRONDEFENSE) || (move == PBMoves::GYROBALL) ||
          (move == PBMoves::IRONHEAD)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::SWORDSDANCE) || (move == PBMoves::CRUNCH) ||
          (move == PBMoves::IRONDEFENSE) || (move == PBMoves::GYROBALL) ||
          (move == PBMoves::IRONHEAD)
          return false
        end
      elsif pokemon.form==2
        if (move == PBMoves::ICYWIND) || (move == PBMoves::CHARM) ||
          (move == PBMoves::SWIFT)
          return false
        end
      end 
    when PBSpecies::PERSIAN #Persian
      if pokemon.form==0
        if (move == PBMoves::QUASH) || (move == PBMoves::SNARL)
          return false
        end
      elsif pokemon.form==1
      end 
    when PBSpecies::GEODUDE #Geodude
      if pokemon.form==0
        if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER) ||
          (move == PBMoves::CHARGEBEAM) || (move == PBMoves::BRUTALSWING) ||
          (move == PBMoves::VOLTSWITCH) || (move == PBMoves::MAGNETRISE) ||
          (move == PBMoves::ELECTROWEB)
          return false
        end
      elsif pokemon.form==1
      end   
    when PBSpecies::GRAVELER #Graveler
      if pokemon.form==0
        if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER) ||
          (move == PBMoves::CHARGEBEAM) || (move == PBMoves::BRUTALSWING) ||
          (move == PBMoves::VOLTSWITCH) || (move == PBMoves::MAGNETRISE) ||
          (move == PBMoves::ELECTROWEB) || (move == PBMoves::SHOCKWAVE) ||
          (move == PBMoves::ALLYSWITCH)
          return false
        end
      elsif pokemon.form==1
      end      
    when PBSpecies::GOLEM #Golem
      if pokemon.form==0
        if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER) ||
          (move == PBMoves::CHARGEBEAM) || (move == PBMoves::BRUTALSWING) ||
          (move == PBMoves::VOLTSWITCH) || (move == PBMoves::ECHOEDVOICE) ||
          (move == PBMoves::WILDCHARGE) || (move == PBMoves::MAGNETRISE) ||
          (move == PBMoves::ELECTROWEB) || (move == PBMoves::SHOCKWAVE) ||
          (move == PBMoves::ALLYSWITCH)
          return false
        end
      elsif pokemon.form==1
      end    
    when PBSpecies::GRIMER #Grimer
      if pokemon.form==0
        if (move == PBMoves::BRUTALSWING) || (move == PBMoves::QUASH) ||
          (move == PBMoves::EMBARGO) || (move == PBMoves::ROCKPOLISH) ||
          (move == PBMoves::STONEEDGE) || (move == PBMoves::SNARL) ||
          (move == PBMoves::KNOCKOFF) || (move == PBMoves::GASTROACID) ||
          (move == PBMoves::SPITE)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER)
          return false
        end
      end   
    when PBSpecies::MUK #Muk
      if pokemon.form==0
        if (move == PBMoves::BRUTALSWING) || (move == PBMoves::QUASH) ||
          (move == PBMoves::EMBARGO) || (move == PBMoves::ROCKPOLISH) ||
          (move == PBMoves::STONEEDGE) || (move == PBMoves::SNARL) ||
          (move == PBMoves::KNOCKOFF) || (move == PBMoves::GASTROACID) ||
          (move == PBMoves::SPITE) || (move == PBMoves::RECYCLE)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER)
          return false
        end
      end         
    when PBSpecies::EXEGGUTOR # Exeggutor
      if pokemon.form==0
        if (move == PBMoves::EARTHQUAKE) || (move == PBMoves::BRICKBREAK) ||
          (move == PBMoves::FLAMETHROWER) || (move == PBMoves::BRUTALSWING) ||
          (move == PBMoves::BULLDOZE) || (move == PBMoves::DRAGONTAIL) ||
          (move == PBMoves::IRONHEAD) || (move == PBMoves::SUPERPOWER) ||
          (move == PBMoves::DRAGONPULSE) || (move == PBMoves::IRONTAIL) ||
          (move == PBMoves::KNOCKOFF) || (move == PBMoves::OUTRAGE) ||
          (move == PBMoves::DRACOMETEOR)
          return false
        end
      elsif pokemon.form==1
      end
    when PBSpecies::MAROWAK # Marowak
      if pokemon.form==0
        if (move == PBMoves::RAINDANCE) || (move == PBMoves::THUNDERBOLT) ||
          (move == PBMoves::THUNDER) || (move == PBMoves::SHADOWBALL) ||
          (move == PBMoves::FLAMECHARGE) || (move == PBMoves::WILLOWISP) ||
          (move == PBMoves::DREAMEATER) || (move == PBMoves::DARKPULSE) ||
          (move == PBMoves::HEATWAVE) || (move == PBMoves::PAINSPLIT) ||
          (move == PBMoves::SPITE) || (move == PBMoves::ALLYSWITCH)
          return false
        end
      elsif pokemon.form==1
      end      
    when PBSpecies::LYCANROC # Lycanroc
      if pokemon.form==0
        if (move == PBMoves::DUALCHOP) || (move == PBMoves::UPROAR) ||
          (move == PBMoves::THUNDERPUNCH) || (move == PBMoves::FIREPUNCH) ||
          (move == PBMoves::FOULPLAY) || (move == PBMoves::FOCUSPUNCH) ||
          (move == PBMoves::THROATCHOP) || (move == PBMoves::LASERFOCUS) ||
          (move == PBMoves::OUTRAGE)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::DRILLRUN)
          return false
        end
      elsif pokemon.form==2
        if (move == PBMoves::DUALCHOP) || (move == PBMoves::UPROAR) ||
          (move == PBMoves::THUNDERPUNCH) || (move == PBMoves::FIREPUNCH) ||
          (move == PBMoves::FOULPLAY) || (move == PBMoves::FOCUSPUNCH) ||
          (move == PBMoves::THROATCHOP) || (move == PBMoves::LASERFOCUS)
          return false
        end
      end 
    when PBSpecies::MISDREAVUS # Misdreavus -- Aevian
      if pokemon.form==0
        if (move == PBMoves::WORKUP) || (move == PBMoves::VENOSHOCK) ||
          (move == PBMoves::SOLARBEAM) || (move == PBMoves::SWORDSDANCE) ||
          (move == PBMoves::INFESTATION) || (move == PBMoves::GRASSKNOT) ||
          (move == PBMoves::NATUREPOWER) || (move == PBMoves::LEECHLIFE) ||
          (move == PBMoves::CUT) || (move == PBMoves::BIND) ||
          (move == PBMoves::WORRYSEED) || (move == PBMoves::GIGADRAIN) ||
          (move == PBMoves::SYNTHESIS) || (move == PBMoves::WATERPULSE) ||
          (move == PBMoves::SEEDBOMB) || (move == PBMoves::GASTROACID) ||
          (move == PBMoves::THROATCHOP) || (move == PBMoves::GUNKSHOT) ||
          (move == PBMoves::KNOCKOFF) 
          return false
        end
      elsif pokemon.form==1
        if arrayToConstant(PBMoves,[# TMs
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
          :POWERGEM,:NASTYPLOT,:LEAFSTORM,:POWERWHIP,:VENOMDRENCH]).include?(move)
          return true
        end
        if (move == PBMoves::CALMMIND) || (move == PBMoves::THUNDERBOLT) ||
          (move == PBMoves::THUNDER) || (move == PBMoves::PSYCHIC) ||
          (move == PBMoves::TORMENT) || (move == PBMoves::THIEF) ||
          (move == PBMoves::CHARGEBEAM) || (move == PBMoves::PAYBACK) ||
          (move == PBMoves::THUNDERWAVE) || (move == PBMoves::DREAMEATER) ||
          (move == PBMoves::TRICKROOM) || (move == PBMoves::DARKPULSE) ||
          (move == PBMoves::DAZZLINGGLEAM) || (move == PBMoves::FLASH) 
          (move == PBMoves::FOULPLAY) || (move == PBMoves::HEADBUTT) ||
          (move == PBMoves::ICYWIND) || (move == PBMoves::ROLEPLAY) ||
          (move == PBMoves::SHOCKWAVE) || (move == PBMoves::TELEKINESIS) 
          return false  
        end
      end
    when PBSpecies::MISMAGIUS # Mismagius -- Aevian
      if pokemon.form==0
        if (move == PBMoves::HONECLAWS) || (move == PBMoves::WORKUP) ||
          (move == PBMoves::VENOSHOCK) || (move == PBMoves::SOLARBEAM) ||
          (move == PBMoves::SWORDSDANCE) || (move == PBMoves::INFESTATION) ||
          (move == PBMoves::GRASSKNOT) || (move == PBMoves::NATUREPOWER) ||
          (move == PBMoves::LEECHLIFE) ||  (move == PBMoves::CUT) ||
          (move == PBMoves::STRENGTH) || (move == PBMoves::BIND) ||
          (move == PBMoves::WORRYSEED) || (move == PBMoves::GIGADRAIN) ||
          (move == PBMoves::SYNTHESIS) || (move == PBMoves::WATERPULSE) ||
          (move == PBMoves::SEEDBOMB) || (move == PBMoves::GASTROACID) ||
          (move == PBMoves::THROATCHOP) || (move == PBMoves::GUNKSHOT) ||
          (move == PBMoves::KNOCKOFF)
          return false
        end
      elsif pokemon.form==1
        if arrayToConstant(PBMoves, 
          # TMs
          [:WORKUP,:TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:HYPERBEAM,:PROTECT,:RAINDANCE,:SECRETPOWER,:FRUSTRATION,:SOLARBEAM,:SMACKDOWN,
            :RETURN,:SHADOWBALL,:DOUBLETEAM,:SLUDGEWAVE,:ROCKTOMB,:AERIALACE,:FACADE,:REST,:ATTRACT,:ROUND,:ECHOEDVOICE,:ENERGYBALL,:QUASH,:WILLOWISP,
            :ACROBATICS,:EMBARGO,:SHADOWCLAW,:GIGAIMPACT,:SWORDSDANCE,:PSYCHUP,:XSCISSOR,:INFESTATION,:POISONJAB,:GRASSKNOT,:SWAGGER,:SLEEPTALK,
            :SUBSTITUTE,:NATUREPOWER,:CONFIDE,:LEECHLIFE,:PINMISSILE,:MAGICALLEAF,:SOLARBLADE,:SCREECH,:SCARYFACE,:BULLETSEED,:CROSSPOISON,:HEX,
            :PHANTOMFORCE,:DRAININGKISS,:GRASSYTERRAIN,:HONECLAWS,:SUCKERPUNCH,:CUT,:STRENGTH,
          # Move Tutors
          :SNORE,:HEALBELL,:UPROAR,:BIND,:WORRYSEED,:SNATCH,:SPITE,:GIGADRAIN,:SYNTHESIS,:ALLYSWITCH,:WATERPULSE,:PAINSPLIT,:SEEDBOMB,:LASERFOCUS,:TRICK,
          :MAGICROOM,:WONDERROOM,:GASTROACID,:THROATCHOP,:SKILLSWAP,:GUNKSHOT,:HYPERVOICE,:KNOCKOFF,:SPIKES,:ENDURE,:BATONPASS,:FUTURESIGHT,:MUDDYWATER,
          :LEAFBLADE,:TOXICSPIKES,:POWERGEM,:NASTYPLOT,:LEAFSTORM,:POWERWHIP,:VENOMDRENCH]).include?(move)
          return true
        end
        if (move == PBMoves::CALMMIND) || (move == PBMoves::HYPERBEAM) ||
          (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER) ||
          (move == PBMoves::PSYCHIC) || (move == PBMoves::TORMENT) ||
          (move == PBMoves::THIEF) || (move == PBMoves::CHARGEBEAM) ||
          (move == PBMoves::PAYBACK) || (move == PBMoves::GIGAIMPACT) ||
          (move == PBMoves::THUNDERWAVE) || (move == PBMoves::DREAMEATER) ||
          (move == PBMoves::TRICKROOM) || (move == PBMoves::DARKPULSE) ||
          (move == PBMoves::DAZZLINGGLEAM) || (move == PBMoves::FLASH) ||
          (move == PBMoves::FOULPLAY) || (move == PBMoves::HEADBUTT) ||
          (move == PBMoves::ICYWIND) || (move == PBMoves::ROLEPLAY) ||
          (move == PBMoves::SHOCKWAVE) || (move == PBMoves::TELEKINESIS) 
          return false
        end
      end
    when PBSpecies::PONYTA # Ponyta
      if pokemon.form==0
        if (move == PBMoves::IMPRISON) || (move == PBMoves::PSYCHIC) ||
          (move == PBMoves::FUTURESIGHT) || (move == PBMoves::CALMMIND) ||
          (move == PBMoves::ZENHEADBUTT) || (move == PBMoves::STOREDPOWER) ||
          (move == PBMoves::DAZZLINGGLEAM)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::SOLARBEAM) || (move == PBMoves::SOLARBLADE) ||
          (move == PBMoves::FIRESPIN) || (move == PBMoves::SUNNYDAY) || 
          (move == PBMoves::WILLOWISP) || (move == PBMoves::FLAMETHROWER) || 
          (move == PBMoves::FIREBLAST) || (move == PBMoves::HEATWAVE) ||
          (move == PBMoves::OVERHEAT) || (move == PBMoves::FLAREBLITZ)
          return false
        end
      end
    when PBSpecies::RAPIDASH # Rapidash
      if pokemon.form==0
        if (move == PBMoves::IMPRISON) || (move == PBMoves::PSYCHOCUT) || 
          (move == PBMoves::TRICKROOM) || (move == PBMoves::WONDERROOM) || 
          (move == PBMoves::MAGICROOM) || (move == PBMoves::MISTYTERRAIN) || 
          (move == PBMoves::PSYCHICTERRAIN) || (move == PBMoves::PSYCHIC) ||
          (move == PBMoves::FUTURESIGHT) || (move == PBMoves::CALMMIND) ||
          (move == PBMoves::ZENHEADBUTT) || (move == PBMoves::STOREDPOWER) ||
          (move == PBMoves::DAZZLINGGLEAM)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::SOLARBEAM) || (move == PBMoves::SOLARBLADE) ||
          (move == PBMoves::FIRESPIN) || (move == PBMoves::SUNNYDAY) || 
          (move == PBMoves::WILLOWISP) || (move == PBMoves::FLAMETHROWER) || 
          (move == PBMoves::FIREBLAST) || (move == PBMoves::HEATWAVE) ||
          (move == PBMoves::OVERHEAT) || (move == PBMoves::FLAREBLITZ) ||
          (move == PBMoves::POISONJAB)
          return false
        end
      end
    when PBSpecies::FARFETCHD # Farfetch'd
      if pokemon.form==0
        if (move == PBMoves::BRICKBREAK) || (move == PBMoves::ASSURANCE) || 
          (move == PBMoves::SUPERPOWER)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::FLY) || (move == PBMoves::THIEF) || 
          (move == PBMoves::SWIFT) || (move == PBMoves::UTURN) || 
          (move == PBMoves::ACROBATICS) || (move == PBMoves::FALSESWIPE) || 
          (move == PBMoves::AIRSLASH) || (move == PBMoves::AGILITY) || 
          (move == PBMoves::BATONPASS) ||  (move == PBMoves::IRONTAIL) || 
          (move == PBMoves::UPROAR) || (move == PBMoves::HEATWAVE)
          return false
        end
      end
    when PBSpecies::WEEZING # Weezing
      if pokemon.form==0
        if (move == PBMoves::WONDERROOM) || (move == PBMoves::MISTYTERRAIN) ||
          (move == PBMoves::BRUTALSWING) || (move == PBMoves::OVERHEAT) ||
          (move == PBMoves::PLAYROUGH) || (move == PBMoves::DAZZLINGGLEAM)
          return false
        end
      elsif pokemon.form==1
      end
    when PBSpecies::MRMIME # Mr Mime
      if pokemon.form==0
        if (move == PBMoves::SCREECH) || (move == PBMoves::HAIL) || 
          (move == PBMoves::ICICLESPEAR) || (move == PBMoves::AVALANCHE) || 
          (move == PBMoves::STOMPINGTANTRUM) || (move == PBMoves::ICEBEAM) || 
          (move == PBMoves::BLIZZARD)
          return false
        end
      elsif pokemon.form==2
        if (move == PBMoves::FIREPUNCH) || (move == PBMoves::THUNDERPUNCH) || 
          (move == PBMoves::MAGICALLEAF) || (move == PBMoves::MYSTICALFIRE)
          return false
        end
      end
    when PBSpecies::CORSOLA # Corsola
      if pokemon.form==0
        if (move == PBMoves::GIGADRAIN) || (move == PBMoves::WILLOWISP) ||
          (move == PBMoves::HEX)
          return false
        end
      elsif pokemon.form==1
      end
    when PBSpecies::ZIGZAGOON # Zigzagoon
      if pokemon.form==0
        if (move == PBMoves::SCREECH) || (move == PBMoves::SCARYFACE) ||
          (move == PBMoves::FAKETEARS) || (move == PBMoves::PAYBACK) ||
          (move == PBMoves::ASSURANCE) || (move == PBMoves::SNARL) ||
          (move == PBMoves::TAUNT)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::CHARM) || (move == PBMoves::TAILSLAP)
          return false
        end
      end
    when PBSpecies::LINOONE # Linoone
      if pokemon.form==0
        if (move == PBMoves::SCREECH) || (move == PBMoves::SCARYFACE) ||
          (move == PBMoves::FAKETEARS) || (move == PBMoves::PAYBACK) ||
          (move == PBMoves::ASSURANCE) || (move == PBMoves::SNARL) ||
          (move == PBMoves::TAUNT)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::CHARM) || (move == PBMoves::TAILSLAP) ||
          (move == PBMoves::PLAYROUGH) || (move == PBMoves::BODYPRESS)
          return false
        end
      end
    when PBSpecies::WORMADAM # Wormadam 
      if pokemon.form==0    # Plant Cloak
        if (move == PBMoves::EARTHQUAKE) || (move == PBMoves::SANDSTORM) ||
          (move == PBMoves::ROCKTOMB) || (move == PBMoves::BULLDOZE) ||
          (move == PBMoves::EARTHPOWER) || (move == PBMoves::STEALTHROCK) || 
          (move == PBMoves::GYROBALL) || (move == PBMoves::FLASHCANNON) || 
          (move == PBMoves::GUNKSHOT) || (move == PBMoves::IRONDEFENSE) || 
          (move == PBMoves::IRONHEAD) || (move == PBMoves::MAGNETRISE)
          return false
        end
      elsif pokemon.form==1   # Sandy Cloak
        if (move == PBMoves::SOLARBEAM) || (move == PBMoves::ENERGYBALL) || 
          (move == PBMoves::GRASSKNOT) || (move == PBMoves::GIGADRAIN) || 
          (move == PBMoves::SEEDBOMB) || (move == PBMoves::SYNTHESIS) ||
          (move == PBMoves::WORRYSEED) || (move == PBMoves::GYROBALL) || 
          (move == PBMoves::FLASHCANNON) || (move == PBMoves::GUNKSHOT) || 
          (move == PBMoves::IRONDEFENSE) || (move == PBMoves::IRONHEAD) || 
          (move == PBMoves::MAGNETRISE)
          return false
        end
      elsif pokemon.form==2   # Trash Cloak
        if (move == PBMoves::SOLARBEAM) || (move == PBMoves::ENERGYBALL) || 
          (move == PBMoves::GRASSKNOT) || (move == PBMoves::GIGADRAIN) || 
          (move == PBMoves::SEEDBOMB) || (move == PBMoves::SYNTHESIS) ||
          (move == PBMoves::WORRYSEED) || (move == PBMoves::EARTHQUAKE) || 
          (move == PBMoves::SANDSTORM) || (move == PBMoves::ROCKTOMB) || 
          (move == PBMoves::BULLDOZE) || (move == PBMoves::EARTHPOWER) 
          return false
        end
      end 
    when PBSpecies::DARUMAKA # Darumaka
      if pokemon.form==0
        if (move == PBMoves::ICEPUNCH) || (move == PBMoves::AVALANCHE) || 
          (move == PBMoves::ICEFANG) || (move == PBMoves::ICEBEAM) || 
          (move == PBMoves::BLIZZARD) 
          return false
        end
      elsif pokemon.form==2
      end
    when PBSpecies::DARMANITAN # Darmanitan
      if pokemon.form==0
        if (move == PBMoves::ICEPUNCH) || (move == PBMoves::AVALANCHE) || 
          (move == PBMoves::ICEFANG) || (move == PBMoves::ICEBEAM) || 
          (move == PBMoves::BLIZZARD) 
          return false
        end
      elsif pokemon.form==2
        if (move == PBMoves::POWERSWAP) || (move == PBMoves::GUARDSWAP) || 
          (move == PBMoves::MYSTICALFIRE) || (move == PBMoves::FUTURESIGHT) || 
          (move == PBMoves::TRICK)
          return false
        end
      end
    when PBSpecies::YAMASK # Yamask
      if pokemon.form==0
        if (move == PBMoves::ROCKSLIDE) || (move == PBMoves::SANDSTORM) ||
          (move == PBMoves::ROCKTOMB) || (move == PBMoves::BRUTALSWING) ||
          (move == PBMoves::EARTHQUAKE) || (move == PBMoves::EARTHPOWER)
          return false
        end
      elsif pokemon.form==1
      end
    when PBSpecies::STUNFISK # Stunfisk
      if pokemon.form==0
        if (move == PBMoves::SCREECH) || (move == PBMoves::ICEFANG) ||  
          (move == PBMoves::CRUNCH) ||  (move == PBMoves::IRONDEFENSE) ||  
          (move == PBMoves::FLASHCANNON) 
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::ELECTROWEB) || (move == PBMoves::ELECTRICTERRAIN) ||  
          (move == PBMoves::EERIEIMPULSE) ||  (move == PBMoves::THUNDERBOLT) ||  
          (move == PBMoves::THUNDER)
          return false
        end
      end
  end    
  return false if !$cache.tm_data[move]
  return $cache.tm_data[move].any? {|item| item==species }
end

def pbForgetMove(pokemon,moveToLearn)
  ret=-1
  pbFadeOutIn(99999){
     scene=PokemonSummaryScene.new
     screen=PokemonSummary.new(scene)
     ret=screen.pbStartForgetScreen([pokemon],0,moveToLearn)
  }
  return ret
end

def pbLearnMove(pokemon,move,ignoreifknown=false,bymachine=false)
  return false if !pokemon
  movename=PBMoves.getName(move)
  if pokemon.isEgg? && !$DEBUG
    Kernel.pbMessage(_INTL("{1} can't be taught to an Egg.",movename))
    return false
  end
  if pokemon.respond_to?("isShadow?") && pokemon.isShadow?
    Kernel.pbMessage(_INTL("{1} can't be taught to this Pokémon.",movename))
    return false
  end
  pkmnname=pokemon.name
  for i in 0...4
    if pokemon.moves[i].id==move
      Kernel.pbMessage(_INTL("{1} already knows\r\n{2}.",pkmnname,movename)) if !ignoreifknown
      return false
    end
    if pokemon.moves[i].id==0
      pokemon.moves[i]=PBMove.new(move)
      Kernel.pbMessage(_INTL("{1} learned {2}!\\se[itemlevel]",pkmnname,movename))
      return true
    end
  end
  loop do
    Kernel.pbMessage(_INTL("{1} is trying to\r\nlearn {2}.\1",pkmnname,movename))
    Kernel.pbMessage(_INTL("But {1} can't learn more than four moves.\1",pkmnname))
    if Kernel.pbConfirmMessage(_INTL("Delete a move to make\r\nroom for {1}?",movename))
      Kernel.pbMessage(_INTL("Which move should be forgotten?"))
      forgetmove=pbForgetMove(pokemon,move)
      if forgetmove>=0
        oldmovename=PBMoves.getName(pokemon.moves[forgetmove].id)
        oldmovepp=pokemon.moves[forgetmove].pp
        pokemon.moves[forgetmove]=PBMove.new(move) # Replaces current/total PP
        pokemon.moves[forgetmove].pp=[oldmovepp,pokemon.moves[forgetmove].totalpp].min if bymachine
        Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
        Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pkmnname,oldmovename))
        Kernel.pbMessage(_INTL("And...\1"))
        Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[itemlevel]",pkmnname,movename))
        return true
      elsif Kernel.pbConfirmMessage(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
        Kernel.pbMessage(_INTL("{1} did not learn {2}.",pkmnname,movename))
        return false
      end
    elsif Kernel.pbConfirmMessage(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
      Kernel.pbMessage(_INTL("{1} did not learn {2}.",pkmnname,movename))
      return false
    end
  end
end

def pbCheckUseOnPokemon(item,pokemon,screen)
  return pokemon && !pokemon.isEgg?
end

def pbConsumeItemInBattle(bag,item)
  if item!=0 && $cache.items[item][ITEMBATTLEUSE]!=3 && $cache.items[item][ITEMBATTLEUSE]!=4 && $cache.items[item][ITEMBATTLEUSE]!=0
    # Delete the item just used from stock
    $PokemonBag.pbDeleteItem(item)
  end
end

def pbUseItemOnPokemon(item,pokemon,scene)
  if $cache.items[item][ITEMUSE]==3 || $cache.items[item][ITEMUSE]==4    # TM or HM
    machine=$cache.items[item][ITEMMACHINE]
    return false if machine==nil
    movename=PBMoves.getName(machine)
    if (pokemon.isShadow? rescue false)
      Kernel.pbMessage(_INTL("Shadow Pokémon can't be taught any moves."))
    elsif !pokemon.isCompatibleWithMove?(machine)
      Kernel.pbMessage(_INTL("{1} and {2} are not compatible.",pokemon.name,movename))
      Kernel.pbMessage(_INTL("{1} can't be learned.",movename))
    else
      if pbIsHiddenMachine?(item)
        Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TMX."))
        Kernel.pbMessage(_INTL("It contained {1}.\1",movename))
      else
        Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TM."))
        Kernel.pbMessage(_INTL("It contained {1}.\1",movename))
      end
      if Kernel.pbConfirmMessage(_INTL("Teach {1} to {2}?",movename,pokemon.name))
        if pbLearnMove(pokemon,machine,false,true)
          $PokemonBag.pbDeleteItem(item) if pbIsTechnicalMachine?(item) && !INFINITETMS
          return true
        end
      end
    end
    return false
  else
    ret=ItemHandlers.triggerUseOnPokemon(item,pokemon,scene)
    if ret && $cache.items[item][ITEMUSE]==1 # Usable on Pokémon, consumed
      $PokemonBag.pbDeleteItem(item)
    end
    if $PokemonBag.pbQuantity(item)<=0
      Kernel.pbMessage(_INTL("You used your last {1}.",PBItems.getName(item)))
    end
    return ret
  end
  Kernel.pbMessage(_INTL("Can't use that on {1}.",pokemon.name))
  return false
end

def pbUseItem(bag,item,bagscene=nil)
  found=false
  if $cache.items[item][ITEMUSE]==3 || $cache.items[item][ITEMUSE]==4    # TM or HM
    machine=$cache.items[item][ITEMMACHINE]
    ret=true
    return 0 if machine==nil
    if $Trainer.pokemonCount==0
      Kernel.pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    movename=PBMoves.getName(machine)
    if pbIsHiddenMachine?(item)
      Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TMX."))
      Kernel.pbMessage(_INTL("It contained {1}.\1",movename))
    else
      Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TM."))
      Kernel.pbMessage(_INTL("It contained {1}.\1",movename))
    end
    if !Kernel.pbConfirmMessage(_INTL("Teach {1} to a Pokémon?",movename))
      return 0
    elsif pbMoveTutorChoose(machine,nil,true)
      bag.pbDeleteItem(item) if pbIsTechnicalMachine?(item) && !INFINITETMS
      return 1
    else
      return 0
    end
  elsif $cache.items[item][ITEMUSE]==1 || $cache.items[item][ITEMUSE]==5 # Item is usable on a Pokémon
    if $Trainer.pokemonCount==0
      Kernel.pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret=false
    annot=nil
    if pbIsEvolutionStone?(item)
      annot=[]
      for pkmn in $Trainer.party
        if item != PBItems::LINKSTONE
          elig=(pbCheckEvolution(pkmn,item)>0)
          annot.push(elig ? _INTL("ABLE") : _INTL("NOT ABLE"))
        else
          elig =(pbTradeCheckEvolution(pkmn,item,true)>0)
          annot.push(elig ? _INTL("ABLE") : _INTL("NOT ABLE"))
        end
      end
    end     
    pbFadeOutIn(99999){
      scene=PokemonScreen_Scene.new
      screen=PokemonScreen.new(scene,$Trainer.party)
      screen.pbStartScene(_INTL("Use on which Pokémon?"),false,annot)
      loop do
        scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        chosen=screen.pbChoosePokemon
        if chosen>=0
          pokemon=$Trainer.party[chosen]
          if !pbCheckUseOnPokemon(item,pokemon,screen)
            pbPlayBuzzerSE()
            next
          end
          # Option to use multiple of the item at once
          if ItemHandlers::MultipleAtOnce.include?(item)
            # Asking how many
            viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
            viewport.z=99999
            helpwindow=Window_UnformattedTextPokemon.new("")
            helpwindow.viewport=viewport
            amount=UIHelper.pbChooseNumber(helpwindow,'How many do you want to use?',bag.pbQuantity(item))
            helpwindow.dispose
            viewport.dispose
            ret=true

            # Applying it 
            ret, amount_consumed=ItemHandlers::UseOnPokemon.trigger(item,pokemon,scene,amount)
            if ret && $cache.items[item][ITEMUSE]==1 # Usable on Pokémon, consumed
              bag.pbDeleteItem(item, amount_consumed)
            end
            if bag.pbQuantity(item)<=0
              Kernel.pbMessage(_INTL("You used your last {1}.",
                PBItems.getName(item))) if bag.pbQuantity(item)<=0
              break
            end
            break if !ret
          else
            ret=ItemHandlers.triggerUseOnPokemon(item,pokemon,screen)
            if ret && $cache.items[item][ITEMUSE]==1 # Usable on Pokémon, consumed
              bag.pbDeleteItem(item)
            end
            if bag.pbQuantity(item)<=0
              Kernel.pbMessage(_INTL("You used your last {1}.",
                PBItems.getName(item))) if bag.pbQuantity(item)<=0
              break
            end
          end
        else
          ret=false
          break
        end
      end
      screen.pbEndScene
      bagscene.pbRefresh if bagscene
    }
    return ret ? 1 : 0
  elsif $cache.items[item][ITEMUSE]==2 # Item is usable from bag
    intret=ItemHandlers.triggerUseFromBag(item)
    case intret
      when 0
        return 0
      when 1 # Item used
        return 1
      when 2 # Item used, end screen
        return 2
      when 3 # Item used, consume item
        bag.pbDeleteItem(item)
        return 1
      when 4 # Item used, end screen and consume item
        bag.pbDeleteItem(item)
        return 2
      else
        Kernel.pbMessage(_INTL("Can't use that here."))
        return 0
    end
  else
    Kernel.pbMessage(_INTL("Can't use that here."))
    return 0
  end
end

def Kernel.pbChooseItem(var=0)
  ret=0
  scene=PokemonBag_Scene.new
  screen=PokemonBagScreen.new(scene,$PokemonBag)
  pbFadeOutIn(99999) { 
    ret=screen.pbChooseItemScreen
  }
  $game_variables[var]=ret if var>0
  return ret
end

# Shows a list of items to choose from, with the chosen item's ID being stored
# in the given Global Variable. Only items which the player has are listed.
def pbChooseItemFromList(message,variable,*args)
  commands=[]
  itemid=[]
  for item in args
    if hasConst?(PBItems,item)
      id=getConst(PBItems,item)
      if $PokemonBag.pbQuantity(id)>0
        commands.push(PBItems.getName(id))
        itemid.push(id)
      end
    end
  end
  if commands.length==0
    $game_variables[variable]=0
    return 0
  end
  commands.push(_INTL("Cancel"))
  itemid.push(0)
  ret=Kernel.pbMessage(message,commands,-1)
  if ret<0 || ret>=commands.length-1
    $game_variables[variable]=-1
    return -1
  else
    $game_variables[variable]=itemid[ret]
    return itemid[ret]
  end
end
