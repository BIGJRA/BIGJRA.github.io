ITEMID        = 0
ITEMNAME      = 1
ITEMPOCKET    = 2
ITEMPRICE     = 3
ITEMDESC      = 4
ITEMUSE       = 5
ITEMBATTLEUSE = 6
ITEMTYPE      = 7
ITEMMACHINE   = 8

def pbIsHiddenMove?(move)
  return false if !$ItemData
  for i in 0...$ItemData.length
    next if !pbIsHiddenMachine?(i)
    atk=$ItemData[i][ITEMMACHINE]
    return true if move==atk
  end
  return false
end

def pbGetPrice(item)
  return $ItemData[item][ITEMPRICE]
end

def pbGetPocket(item)
  return $ItemData[item][ITEMPOCKET]
end

# Important items can't be sold, given to hold, or tossed.
def pbIsImportantItem?(item)
  return $ItemData[item] && (pbIsKeyItem?(item) || pbIsHiddenMachine?(item) || (INFINITETMS && pbIsTechnicalMachine?(item)) || pbIsZCrystal2?(item) )
end

def pbIsMachine?(item)
  return $ItemData[item] && (pbIsTechnicalMachine?(item) || pbIsHiddenMachine?(item))
end

def pbIsTechnicalMachine?(item)
  return $ItemData[item] && ($ItemData[item][ITEMUSE]==3)
end

def pbIsHiddenMachine?(item)
  return $ItemData[item] && ($ItemData[item][ITEMUSE]==4)
end

def pbIsMail?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==1 || $ItemData[item][ITEMTYPE]==2)
end

def pbIsSnagBall?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==3 ||
                            ($ItemData[item][ITEMTYPE]==4 && $PokemonGlobal.snagMachine))
end

def pbIsPokeBall?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==3 || $ItemData[item][ITEMTYPE]==4)
end

def pbIsBerry?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==5)
end

def pbIsSeed?(item)
  return true if isConst?(item,PBItems,:ELEMENTALSEED) ||
                 isConst?(item,PBItems,:MAGICALSEED) ||
                 isConst?(item,PBItems,:TELLURICSEED) ||
                 isConst?(item,PBItems,:SYNTHETICSEED)
  return false  
end


def pbIsTypeGem?(item)
  return true if isConst?(item,PBItems,:FIREGEM) ||
                 isConst?(item,PBItems,:WATERGEM) ||
                 isConst?(item,PBItems,:ELECTRICGEM) ||
                 isConst?(item,PBItems,:GRASSGEM) ||
                 isConst?(item,PBItems,:ICEGEM) ||
                 isConst?(item,PBItems,:FIGHTINGGEM) ||
                 isConst?(item,PBItems,:POISONGEM) ||
                 isConst?(item,PBItems,:GROUNDGEM) ||
                 isConst?(item,PBItems,:FLYINGGEM) ||
                 isConst?(item,PBItems,:PSYCHICGEM) ||
                 isConst?(item,PBItems,:BUGGEM) ||
                 isConst?(item,PBItems,:ROCKGEM) ||
                 isConst?(item,PBItems,:GHOSTGEM) ||
                 isConst?(item,PBItems,:DRAGONGEM) ||
                 isConst?(item,PBItems,:DARKGEM) ||
                 isConst?(item,PBItems,:STEELGEM) ||
                 isConst?(item,PBItems,:NORMALGEM) ||
                 isConst?(item,PBItems,:FAIRYGEM)
  return false
end

def pbIsKeyItem?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==6)
end

def pbIsZCrystal?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==7)
end

def pbIsZCrystal2?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==8)
end

def pbIsBattleEndingItem?(item)
  return false
end

def pbIsEvolutionStone?(item)
  return true if isConst?(item,PBItems,:FIRESTONE) ||
                 isConst?(item,PBItems,:THUNDERSTONE) ||
                 isConst?(item,PBItems,:WATERSTONE) ||
                 isConst?(item,PBItems,:LEAFSTONE) ||
                 isConst?(item,PBItems,:MOONSTONE) ||
                 isConst?(item,PBItems,:SUNSTONE) ||
                 isConst?(item,PBItems,:DUSKSTONE) ||
                 isConst?(item,PBItems,:DAWNSTONE) ||
                 isConst?(item,PBItems,:SHINYSTONE) ||
                 isConst?(item,PBItems,:XENWASTE) ||
                 isConst?(item,PBItems,:NIGHTMAREFUEL) ||
                 #isConst?(item,PBItems,:LINKHEART) ||
                 isConst?(item,PBItems,:APOPHYLLPAN) ||
                 isConst?(item,PBItems,:ICESTONE) ||
                 isConst?(item,PBItems,:SWEETAPPLE) ||
                 isConst?(item,PBItems,:TARTAPPLE) ||
                 isConst?(item,PBItems,:CHIPPEDPOT) ||
                 isConst?(item,PBItems,:CRACKEDPOT)
                 
  return false
end

def pbIsMulch?(item)
  return true if isConst?(item,PBItems,:GROWTHMULCH) ||
                 isConst?(item,PBItems,:DAMPMULCH) ||
                 isConst?(item,PBItems,:STABLEMULCH) ||
                 isConst?(item,PBItems,:GOOEYMULCH)
  return false
end

def pbIsCrest?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==13)
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
  if totalev+evgain>510
    # Bug Fix: must use "-=" instead of "="
    evgain-=totalev+evgain-510
  end
  if pokemon.ev[ev]+evgain>255
    # Bug Fix: must use "-=" instead of "="
    evgain-=pokemon.ev[ev]+evgain-255
  end
  if evgain>0
    pokemon.ev[ev]+=evgain
    pokemon.calcStats
  end
  return evgain
end

def pbRaiseEffortValues(pokemon,ev,evgain=10,evlimit=true)
  if pokemon.ev[ev]>=100 && evlimit
    return 0
  end
  totalev=0
  for i in 0...6
    totalev+=pokemon.ev[i]
  end
  if totalev+evgain>510
    evgain=510-totalev
  end
  if pokemon.ev[ev]+evgain>255
    evgain=255-pokemon.ev[ev]
  end
  if evlimit && pokemon.ev[ev]+evgain>100
    evgain=100-pokemon.ev[ev]
  end
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
     (!$PokemonGlobal.bicycle && pbGetTerrainTag==PBTerrain::TallGrass)
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
    Kernel.pbMessage(_INTL("Can't use that here.")) if $game_switches[715] == false
  end
end

def pbSpeciesCompatible?(species,move,pokemon)  
  ret=false
  return false if species<=0
  case species
    when 19 #Rattata
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
    when 20 #Raticate
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
    when 26 #Raichu
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
    when 27 #Sandshrew
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
    when 28 #Sandslash
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
    when 37 #Vulpix
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
    when 38 #Ninetales
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
    when 50 #Diglett
      if pokemon.form==0
        if (move == PBMoves::WORKUP) || (move == PBMoves::FLASHCANNON) ||
          (move == PBMoves::IRONDEFENSE) || (move == PBMoves::IRONHEAD)
          return false
        end
      elsif pokemon.form==1
      end       
    when 51 #Dugtrio
      if pokemon.form==0
        if (move == PBMoves::WORKUP) || (move == PBMoves::FLASHCANNON) ||
          (move == PBMoves::IRONDEFENSE) || (move == PBMoves::IRONHEAD)
          return false
        end
      elsif pokemon.form==1
      end      
    when 52 #Meowth
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
    when 53 #Persian
      if pokemon.form==0
        if (move == PBMoves::QUASH) || (move == PBMoves::SNARL)
          return false
        end
      elsif pokemon.form==1
      end 
    when 74 #Geodude
      if pokemon.form==0
        if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER) ||
          (move == PBMoves::CHARGEBEAM) || (move == PBMoves::BRUTALSWING) ||
          (move == PBMoves::VOLTSWITCH) || (move == PBMoves::MAGNETRISE) ||
          (move == PBMoves::ELECTROWEB)
          return false
        end
      elsif pokemon.form==1
      end   
    when 75 #Graveler
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
    when 76 #Golem
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
    when 88 #Grimer
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
    when 89 #Muk
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
    when 103 # Exeggutor
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
    when 105 # Marowak
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
    when 745 # Lycanroc
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
    when 77 # Ponyta
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
          (move == PBMoves::OVERHEAT) || (move == PBMoves::FLAREBLITZ) ||  (move == PBMoves::LAVASURF)  
          return false
        end
      end
    when 78 # Rapidash
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
          (move == PBMoves::POISONJAB) ||  (move == PBMoves::LAVASURF) 
          return false
        end
      end
    when 83 # Farfetch'd
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
    when 110 # Weezing
      if pokemon.form==0
        if (move == PBMoves::WONDERROOM) || (move == PBMoves::MISTYTERRAIN) ||
          (move == PBMoves::BRUTALSWING) || (move == PBMoves::OVERHEAT) ||
          (move == PBMoves::PLAYROUGH) || (move == PBMoves::DAZZLINGGLEAM)
          return false
        end
      elsif pokemon.form==1
      end
    when 110 # Weezing
      if pokemon.form==0
        if (move == PBMoves::WONDERROOM) || (move == PBMoves::MISTYTERRAIN) ||
          (move == PBMoves::BRUTALSWING) || (move == PBMoves::OVERHEAT) ||
          (move == PBMoves::PLAYROUGH) || (move == PBMoves::DAZZLINGGLEAM)
          return false
        end
      elsif pokemon.form==1
      end
    when 122 # Mr Mime
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
    when 222 # Corsola
      if pokemon.form==0
        if (move == PBMoves::GIGADRAIN) || (move == PBMoves::WILLOWISP) ||
          (move == PBMoves::HEX)
          return false
        end
      elsif pokemon.form==1
      end
    when 200 # Misdreavus
      if pokemon.form==0
        if (move == PBMoves::GIGADRAIN) || (move == PBMoves::MAGICALLEAF) ||
          (move == PBMoves::THUNDER) || (move == PBMoves::THUNDERWAVE) || 
          (move == PBMoves::DRAININGKISS) || (move == PBMoves::PHANTOMFORCE) ||
          (move == PBMoves::SUCKERPUNCH) || (move == PBMoves::PINMISSILE) ||
          (move == PBMoves::PINMISSILE)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::MYSTICALFIRE) || (move == PBMoves::THUNDERBOLT) ||
          (move == PBMoves::THUNDER) || (move == PBMoves::THUNDERWAVE)
          return false
        end
      end
    when 315 # Roselia
      if pokemon.form==0
        if (move == PBMoves::SANDTOMB) || (move == PBMoves::MUDSHOT) ||
          (move == PBMoves::LOWSWEEP) || (move == PBMoves::FOCUSBLAST) || 
          (move == PBMoves::ROCKTOMB) || (move == PBMoves::ROCKSLIDE) ||
          (move == PBMoves::WEATHERBALL) || (move == PBMoves::VACUUMWAVE) ||
          (move == PBMoves::EARTHPOWER) || (move == PBMoves::FOULPLAY) ||
          (move == PBMoves::AURASPHERE)
          return false
        end
      elsif pokemon.form==2
        if (move == PBMoves::GIGADRAIN) || (move == PBMoves::GRASSKNOT) ||
          (move == PBMoves::SLUDGEBOMB) || (move == PBMoves::LEAFSTORM) ||
          (move == PBMoves::MAGICALLEAF)
          return false
        end
      end
    when 406 # Budew
      if pokemon.form==0
        if (move == PBMoves::SANDTOMB) || (move == PBMoves::MUDSHOT) ||
          (move == PBMoves::LOWSWEEP) || (move == PBMoves::FOCUSBLAST) || 
          (move == PBMoves::ROCKTOMB) || (move == PBMoves::ROCKSLIDE) ||
          (move == PBMoves::WEATHERBALL) || (move == PBMoves::VACUUMWAVE) ||
          (move == PBMoves::EARTHPOWER) || (move == PBMoves::FOULPLAY) ||
          (move == PBMoves::AURASPHERE)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::GIGADRAIN) || (move == PBMoves::GRASSKNOT) ||
          (move == PBMoves::SLUDGEBOMB) || (move == PBMoves::LEAFSTORM) ||
          (move == PBMoves::MAGICALLEAF)
          return false
        end
      end
    when 407 # Budew
      if pokemon.form==0
        if (move == PBMoves::SANDTOMB) || (move == PBMoves::MUDSHOT) ||
          (move == PBMoves::LOWSWEEP) || (move == PBMoves::FOCUSBLAST) || 
          (move == PBMoves::ROCKTOMB) || (move == PBMoves::ROCKSLIDE) ||
          (move == PBMoves::WEATHERBALL) || (move == PBMoves::VACUUMWAVE) ||
          (move == PBMoves::EARTHPOWER) || (move == PBMoves::FOULPLAY) ||
          (move == PBMoves::AURASPHERE)
          return false
        end
      elsif pokemon.form==2
        if (move == PBMoves::GIGADRAIN) || (move == PBMoves::GRASSKNOT) ||
          (move == PBMoves::SLUDGEBOMB) || (move == PBMoves::LEAFSTORM) ||
          (move == PBMoves::MAGICALLEAF)
          return false
        end
      end
    when 263 # Zigzagoon
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
    when 264 # Linoone
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
    when 349 # Feebas
      if pokemon.form==0
        if (move == PBMoves::SLUDGEBOMB) || (move == PBMoves::SLUDGEWAVE) || 
          (move == PBMoves::DAZZLINGGLEAM) || (move == PBMoves::VENOSHOCK) || 
          (move == PBMoves::MISTYTERRAIN) || (move == PBMoves::SNARL) || (move == PBMoves::DRAININGKISS) 
          return false
        end
      elsif pokemon.form==2
        if (move == PBMoves::DRAGONPULSE)
          return false
        end
      end
    when 350 # Milotic
      if pokemon.form==0
        if (move == PBMoves::SLUDGEBOMB) || (move == PBMoves::SLUDGEWAVE) || 
          (move == PBMoves::DAZZLINGGLEAM) || (move == PBMoves::VENOSHOCK) || 
          (move == PBMoves::MISTYTERRAIN) || (move == PBMoves::SNARL) || (move == PBMoves::DRAININGKISS) ||
          (move == PBMoves::LEECHLIFE)  || (move == PBMoves::POISONSWEEP)  || (move == PBMoves::THUNDERWAVE) ||
          (move == PBMoves::KNOCKOFF) || (move == PBMoves::PLAYROUGH) || (move == PBMoves::GUNKSHOT) 
          return false
        end
      elsif pokemon.form==2
        if (move == PBMoves::DRAGONPULSE)
          return false
        end
      end
    when 413 # Wormadam 
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
    when 554 # Darumaka
      if pokemon.form==0
        if (move == PBMoves::ICEPUNCH) || (move == PBMoves::AVALANCHE) || 
          (move == PBMoves::ICEFANG) || (move == PBMoves::ICEBEAM) || 
          (move == PBMoves::BLIZZARD) 
          return false
        end
      elsif pokemon.form==2
      end
    when 554 # Darmanitan
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
    when 562 # Yamask
      if pokemon.form==0
        if (move == PBMoves::ROCKSLIDE) || (move == PBMoves::SANDSTORM) ||
          (move == PBMoves::ROCKTOMB) || (move == PBMoves::BRUTALSWING) ||
          (move == PBMoves::EARTHQUAKE) || (move == PBMoves::EARTHPOWER)
          return false
        end
      elsif pokemon.form==1
      end
    when 131 # Lapras
      if pokemon.form==0
        if (move == PBMoves::ROCKSLIDE) || (move == PBMoves::SHADOWBALL) ||
          (move == PBMoves::ROCKTOMB) || (move == PBMoves::STONEEDGE) ||
          (move == PBMoves::CALMMIND) || (move == PBMoves::PSYSHOCK) || (move == PBMoves::REFLECT) ||
          (move == PBMoves::LIGHTSCREEN) || (move == PBMoves::TRICKROOM) || (move == PBMoves::FLASHCANNON) ||
          (move == PBMoves::WEATHERBALL) || (move == PBMoves::PSYCHICTERRAIN) || (move == PBMoves::LAVASURF)
          return false
        end
      elsif pokemon.form==2
        if (move == PBMoves::SURF) || (move == PBMoves::WATERFALL) ||
          (move == PBMoves::HYDROPUMP) || (move == PBMoves::HAIL) ||
          (move == PBMoves::CHARM) || (move == PBMoves::AVALANCHE) || (move == PBMoves::DIVE) ||
          (move == PBMoves::WHIRLPOOL) || (move == PBMoves::BRINE) || (move == PBMoves::LIQUIDATION)
          return false
        end
      end
    when 517 # Munna
      if pokemon.form==0
        if (move == PBMoves::DRAININGKISS) || (move == PBMoves::SHADOWCLAW) ||
          (move == PBMoves::TAUNT) || (move == PBMoves::SWORDSDANCE) ||
          (move == PBMoves::HONECLAWS) || (move == PBMoves::LEECHLIFE) || (move == PBMoves::SNARL) ||
          (move == PBMoves::PAYBACK) || (move == PBMoves::PAINSPLIT) || (move == PBMoves::KNOCKOFF) ||
          (move == PBMoves::PLAYROUGH)
          return false
        end
      elsif pokemon.form==1
      end
    when 518 # Musharna
      if pokemon.form==0
        if (move == PBMoves::DRAININGKISS) || (move == PBMoves::SHADOWCLAW) ||
          (move == PBMoves::TAUNT) || (move == PBMoves::SWORDSDANCE) ||
          (move == PBMoves::HONECLAWS) || (move == PBMoves::LEECHLIFE) || (move == PBMoves::SNARL) ||
          (move == PBMoves::PAYBACK) || (move == PBMoves::PAINSPLIT) || (move == PBMoves::KNOCKOFF) ||
          (move == PBMoves::PLAYROUGH)
          return false
        end
      elsif pokemon.form==1
      end
    when 607 # Litwick
      if pokemon.form==0
        if (move == PBMoves::THUNDERWAVE) || (move == PBMoves::THUNDERBOLT) ||
          (move == PBMoves::THUNDER) || (move == PBMoves::ZAPCANNON) ||
          (move == PBMoves::CHARGEBEAM) || (move == PBMoves::SOLARBEAM)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::FLAMETHROWER) || (move == PBMoves::FIREBLAST) ||
          (move == PBMoves::LAVASURF) || (move == PBMoves::HEATWAVE) ||
          (move == PBMoves::MYSTICALFIRE) || (move == PBMoves::WILLOWISP) || (move == PBMoves::SOLARBEAM)
          return false
        end
      end
    when 608 # Lampent
        if pokemon.form==01
          if (move == PBMoves::THUNDERWAVE) || (move == PBMoves::THUNDERBOLT) ||
            (move == PBMoves::THUNDER) || (move == PBMoves::ZAPCANNON) ||
            (move == PBMoves::CHARGEBEAM) || (move == PBMoves::SOLARBEAM)
            return false
          end
        elsif pokemon.form==1
          if (move == PBMoves::FLAMETHROWER) || (move == PBMoves::FIREBLAST) ||
            (move == PBMoves::LAVASURF) || (move == PBMoves::HEATWAVE) ||
            (move == PBMoves::MYSTICALFIRE) || (move == PBMoves::WILLOWISP) || (move == PBMoves::SOLARBEAM)
            return false
          end
        end
    when 609 # Chandelure
      if pokemon.form==0
        if (move == PBMoves::THUNDERWAVE) || (move == PBMoves::THUNDERBOLT) ||
          (move == PBMoves::THUNDER) || (move == PBMoves::ZAPCANNON) ||
          (move == PBMoves::CHARGEBEAM) || (move == PBMoves::SOLARBEAM)
          return false
        end
      elsif pokemon.form==1
        if (move == PBMoves::FLAMETHROWER) || (move == PBMoves::FIREBLAST) ||
          (move == PBMoves::LAVASURF) || (move == PBMoves::HEATWAVE) ||
          (move == PBMoves::MYSTICALFIRE) || (move == PBMoves::WILLOWISP) || (move == PBMoves::SOLARBEAM)
          return false
        end
      end
    when 618 # Stunfisk
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
  data=load_data("Data/tm.dat")
  return false if !data[move]
  return data[move].any? {|item| item==species }
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
  pkmnname=pokemon.name
  if pokemon.isEgg? && !$DEBUG
    Kernel.pbMessage(_INTL("{1} can't be taught to an Egg.",movename))
    return false
  end
  if $game_switches[1235] && !($game_switches[1408])
    Kernel.pbMessage(_INTL("...? the TM isn't working on {1} for some reason.",pkmnname)) 
    return false
  elsif pokemon.respond_to?("isShadow?") && pokemon.isShadow?
    Kernel.pbMessage(_INTL("{1} can't be taught to this Pokémon.",movename))
    return false
  end
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
  if item!=0 && $ItemData[item][ITEMBATTLEUSE]!=3 &&
                $ItemData[item][ITEMBATTLEUSE]!=4 &&
                $ItemData[item][ITEMBATTLEUSE]!=0
    # Delete the item just used from stock
    $PokemonBag.pbDeleteItem(item)
    
  end
end

def pbUseItemOnPokemon(item,pokemon,scene)
  if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4    # TM or HM
    machine=$ItemData[item][ITEMMACHINE]
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
          Achievements.incrementProgress("ITEMS_USED",1)
          return true
        end
      end
    end
    return false
  else
    ret=ItemHandlers.triggerUseOnPokemon(item,pokemon,scene)
    if ret && $ItemData[item][ITEMUSE]==1 # Usable on Pokémon, consumed
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
  if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4    # TM or HM
    machine=$ItemData[item][ITEMMACHINE]
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
      Achievements.incrementProgress("ITEMS_USED",1)
      return 1
    else
      return 0
    end
  elsif $ItemData[item][ITEMUSE]==1 || $ItemData[item][ITEMUSE]==5 # Item is usable on a Pokémon
    if $Trainer.pokemonCount==0
      Kernel.pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret=false
    annot=nil
    if pbIsEvolutionStone?(item)
      annot=[]
      for pkmn in $Trainer.party
        elig=(pbCheckEvolution(pkmn,item)>0)
        annot.push(elig ? _INTL("ABLE") : _INTL("NOT ABLE"))
      end
    end
    if pbIsZCrystal2?(item)
      annot=[]
      for pkmn in $Trainer.party
        case item
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
          if !(pkmn.species==785 || pkmn.species==786 || pkmn.species==787 || pkmn.species==788)
            canuse=false
          end
        when getID(PBItems,:INTERCEPTZ)
          canuse=true
        when getID(PBItems,:MARSHADIUMZ)
          canuse=false   
          for move in pkmn.moves
            if move.id==getID(PBMoves,:SPECTRALTHIEF)
              canuse=true
            end
          end
          if pkmn.species!=802
            canuse=false
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
          if !(pkmn.species==791 || (pkmn.species==800 && pkmn.form==1))
            canuse=false
          end                     
        when getID(PBItems,:LUNALIUMZ)
          canuse=false   
          for move in pkmn.moves
            if move.id==getID(PBMoves,:MOONGEISTBEAM)
              canuse=true
            end
          end
          if !(pkmn.species==792 || (pkmn.species==800 && pkmn.form==2))
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
        annot.push(canuse ? _INTL("ABLE") : _INTL("NOT ABLE"))
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
           else
             ret=ItemHandlers.triggerUseOnPokemon(item,pokemon,screen)
             if ret && $ItemData[item][ITEMUSE]==1 # Usable on Pokémon, consumed
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
  elsif $ItemData[item][ITEMUSE]==2 # Item is usable from bag
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
  pbFadeOutIn(99999) { 
    scene=PokemonBag_Scene.new
    screen=PokemonBagScreen.new(scene,$PokemonBag)
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