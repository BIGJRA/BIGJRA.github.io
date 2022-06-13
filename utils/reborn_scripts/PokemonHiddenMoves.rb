class MoveHandlerHash < HandlerHash
  def initialize
    super(:PBMoves)
  end
end



module HiddenMoveHandlers
  CanUseMove=MoveHandlerHash.new
  UseMove=MoveHandlerHash.new

  def self.addCanUseMove(item,proc)
    CanUseMove.add(item,proc)
  end

  def self.addUseMove(item,proc)
    UseMove.add(item,proc)
  end 

  def self.hasHandler(item)
    return CanUseMove[item]!=nil && UseMove[item]!=nil
  end

  def self.triggerCanUseMove(item,pokemon)
    # Returns whether move can be used
    if !CanUseMove[item]
      return false
    else
      return CanUseMove.trigger(item,pokemon)
    end
  end

  def self.triggerUseMove(item,pokemon)
    # Returns whether move was used
    if !UseMove[item]
      return false
    else
      return UseMove.trigger(item,pokemon)
    end
  end
end



def pbHiddenMoveAnimation(pokemon)
  return false if !pokemon || $game_switches[:EasyHMs_Password] == true
  viewport=Viewport.new(0,0,0,0)
  viewport.z=99999
  bg=Sprite.new(viewport)
  bg.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/hiddenMovebg")
  sprite=PokemonSprite.new(viewport)
  sprite.setPokemonBitmap(pokemon)
  sprite.z=1
  sprite.ox=sprite.bitmap.width/2
  sprite.oy=sprite.bitmap.height/2
  sprite.visible=false
  strobebitmap=AnimatedBitmap.new("Graphics/Pictures/hiddenMoveStrobes")
  strobes=[]
  15.times do |i|
    strobe=BitmapSprite.new(26*2,8*2,viewport)
    strobe.bitmap.blt(0,0,strobebitmap.bitmap,Rect.new(0,(i%2)*8*2,26*2,8*2))
    strobe.z=((i%2)==0 ? 2 : 0)
    strobe.visible=false
    strobes.push(strobe)
  end
  strobebitmap.dispose
  interp=RectInterpolator.new(
     Rect.new(0,Graphics.height/2,Graphics.width,0),
     Rect.new(0,(Graphics.height-bg.bitmap.height)/2,Graphics.width,bg.bitmap.height),
     10)
  ptinterp=nil
  phase=1
  frames=0
  begin
    Graphics.update
    Input.update
    case phase
      when 1 # Expand viewport height from zero to full
        interp.update
        interp.set(viewport.rect)
        bg.oy=(bg.bitmap.height-viewport.rect.height)/2
        if interp.done?
          phase=2
          ptinterp=PointInterpolator.new(
             Graphics.width+(sprite.bitmap.width/2),bg.bitmap.height/2,
             Graphics.width/2,bg.bitmap.height/2,
             16)
        end
      when 2 # Slide Pokémon sprite in from right to centre
        ptinterp.update
        sprite.x=ptinterp.x
        sprite.y=ptinterp.y
        sprite.visible=true
        if ptinterp.done?
          phase=3
          pbPlayCry(pokemon)
          frames=0
        end
      when 3 # Wait
        frames+=1
        if frames>30
          phase=4
          ptinterp=PointInterpolator.new(
             Graphics.width/2,bg.bitmap.height/2,
             -(sprite.bitmap.width/2),bg.bitmap.height/2,
             16)
          frames=0
        end
      when 4 # Slide Pokémon sprite off from centre to left
        ptinterp.update
        sprite.x=ptinterp.x
        sprite.y=ptinterp.y
        if ptinterp.done?
          phase=5
          sprite.visible=false
          interp=RectInterpolator.new(
             Rect.new(0,(Graphics.height-bg.bitmap.height)/2,Graphics.width,bg.bitmap.height),
             Rect.new(0,Graphics.height/2,Graphics.width,0),
             10)
        end
      when 5 # Shrink viewport height from full to zero
        interp.update
        interp.set(viewport.rect)
        bg.oy=(bg.bitmap.height-viewport.rect.height)/2
        phase=6 if interp.done?    
    end
    for strobe in strobes
      strobe.ox=strobe.viewport.rect.x
      strobe.oy=strobe.viewport.rect.y
      if !strobe.visible
        randomY=16*(1+rand(bg.bitmap.height/16-2))
        strobe.y=randomY+(Graphics.height-bg.bitmap.height)/2
        strobe.x=rand(Graphics.width)
        strobe.visible=true
      elsif strobe.x<Graphics.width
        strobe.x+=32
      else
        randomY=16*(1+rand(bg.bitmap.height/16-2))
        strobe.y=randomY+(Graphics.height-bg.bitmap.height)/2
        strobe.x=-strobe.bitmap.width-rand(Graphics.width/4)
      end
    end
    pbUpdateSceneMap
  end while phase!=6
  sprite.dispose
  for strobe in strobes
    strobe.dispose
  end
  strobes.clear
  bg.dispose
  viewport.dispose
  return true
end

#===============================================================================
# Rock Climb
#===============================================================================
def Kernel.pbRockClimb
  $game_switches[:Stop_Icycle_Falling] = true
  if $DEBUG || (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORROCKCLIMB : $Trainer.badges[BADGEFORROCKCLIMB])
    movefinder=Kernel.pbCheckMove(:ROCKCLIMB)
    if $DEBUG || movefinder
      $game_switches[:Rock_Climb_Convenience] = true and return true if $game_switches[:Rock_Climb_Convenience] == true
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} used Rock Climb!",speciesname))
      pbHiddenMoveAnimation(movefinder)
      $game_switches[:Rock_Climb_Convenience] = true
      $game_switches[:Stop_Icycle_Falling] = false
      return true
    end
  end
  Kernel.pbMessage(_INTL("The wall is very rocky. A Pokémon might be able to climb it."))
  $game_switches[:Stop_Icycle_Falling] = false
  return false
end

#===============================================================================
# Cut
#===============================================================================
def Kernel.pbCut
  if $DEBUG ||
     (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORCUT : $Trainer.badges[BADGEFORCUT])
    movefinder=Kernel.pbCheckMove(:CUT)
    if $DEBUG || movefinder
      if $game_switches[:Cut_Convenience] == true
        pbSEPlay("PRSFX- Cut")
        return true
      end 
      Kernel.pbMessage(_INTL("This tree looks like it can be cut down!\1"))
      if Kernel.pbConfirmMessage(_INTL("Would you like to cut it?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Cut!",speciesname))
        pbHiddenMoveAnimation(movefinder)    
        pbSEPlay("PRSFX- Cut")   
        $game_switches[:Cut_Convenience] = true
        return true
      end
    else
      Kernel.pbMessage(_INTL("This tree looks like it can be cut down."))
    end
  else
    Kernel.pbMessage(_INTL("This tree looks like it can be cut down."))
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:CUT,lambda{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORCUT : $Trainer.badges[BADGEFORCUT])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Tree"
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:CUT,lambda{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     facingEvent.erase
     $PokemonMap.addErasedEvent(facingEvent.id)
   end
   return true
})

#===============================================================================
# Headbutt
#===============================================================================
def Kernel.pbHeadbuttEffect(event)
  if !pbEncounter(EncounterTypes::HeadbuttHigh)
    Kernel.pbMessage(_INTL("Nope.  Nothing..."))
  end
end

def Kernel.pbHeadbutt(event)
  movefinder=Kernel.pbCheckMove(:HEADBUTT)
  if $DEBUG || movefinder
    if Kernel.pbConfirmMessage(_INTL("A Pokémon could be in this tree.  Would you like to use Headbutt?"))
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} used Headbutt.",speciesname))
      pbHiddenMoveAnimation(movefinder)
      Kernel.pbHeadbuttEffect(event)
    end
  else
    Kernel.pbMessage(_INTL("A Pokémon could be in this tree.  Maybe a Pokémon could shake it."))
  end
  Input.update
  return
end

def Kernel.pbHeadbutt2(event)
  movefinder=Kernel.pbCheckMove(:HEADBUTT)
  if $DEBUG || movefinder
    if Kernel.pbConfirmMessage(_INTL("A Pokémon might fall from this pole.  Want to headbutt it?"))
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} did a headbutt!",speciesname))
      pbHiddenMoveAnimation(movefinder)
      Kernel.pbHeadbuttEffect(event)
    end
  else
    Kernel.pbMessage(_INTL("A Pokémon might fall from this pole.  Maybe a Pokémon could shake it."))
  end
  Input.update
  return
end

HiddenMoveHandlers::CanUseMove.add(:HEADBUTT,lambda{|move,pkmn|
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="HeadbuttTree"
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:HEADBUTT,lambda{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}.",pokemon.name,PBMoves.getName(move)))
   end
   facingEvent=$game_player.pbFacingEvent
   Kernel.pbHeadbuttEffect(facingEvent)
})

#===============================================================================
# Rock Smash
#===============================================================================
def pbRockSmashRandomEncounter
  if rand(100)<25
    pbEncounter(EncounterTypes::RockSmash)
  end
end

def Kernel.pbRockSmash
  if $DEBUG ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORROCKSMASH : $Trainer.badges[BADGEFORROCKSMASH])
    movefinder=Kernel.pbCheckMove(:ROCKSMASH)
    if $DEBUG || movefinder    
      if $game_switches[:Rock_Smash_Convenience] == true
        pbSEPlay("PRSFX- Rock Smash")
        return true
      end 
      if $game_switches[:Wall_Smash] == true
        if Kernel.pbConfirmMessage(_INTL("This wall appears to be breakable.  Would you like to use Rock Smash?"))
          speciesname=!movefinder ? $Trainer.name : movefinder.name
          Kernel.pbMessage(_INTL("{1} used Rock Smash!",speciesname))
          pbHiddenMoveAnimation(movefinder)
          pbSEPlay("PRSFX- Rock Smash")
          $game_switches[:Rock_Smash_Convenience] = true
          return true      
        end
      else
        $game_switches[:Stop_Arrows_Shooting] = true
        $game_switches[:Stop_Icycle_Falling] = true
        if Kernel.pbConfirmMessage(_INTL("This rock appears to be breakable.  Would you like to use Rock Smash?"))
          speciesname=!movefinder ? $Trainer.name : movefinder.name
          Kernel.pbMessage(_INTL("{1} used Rock Smash!",speciesname))
          pbHiddenMoveAnimation(movefinder)
          pbSEPlay("PRSFX- Rock Smash")
          $game_switches[1260] = false
          $game_switches[:Stop_Icycle_Falling] = false
          $game_switches[:Rock_Smash_Convenience] = true
          return true
        end
      end
    else
      if $game_switches[:Wall_Smash] == true
        Kernel.pbMessage(_INTL("It's a brittle wall. A Pokémon may be able to smash it."))
      else
        Kernel.pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
      end
    end
  else
    if $game_switches[:Wall_Smash] == true
      Kernel.pbMessage(_INTL("It's a brittle wall. A Pokémon may be able to smash it."))
    else
      Kernel.pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
    end  
  end
  $game_switches[:Stop_Arrows_Shooting] = false
  $game_switches[:Stop_Icycle_Falling] = false
  return false
end

HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH,lambda{|move,pkmn|
   terrain=Kernel.pbFacingTerrainTag
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORROCKSMASH : $Trainer.badges[BADGEFORROCKSMASH])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Rock"
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true  
})

HiddenMoveHandlers::UseMove.add(:ROCKSMASH,lambda{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     facingEvent.erase
     $PokemonMap.addErasedEvent(facingEvent.id)
     pbRockSmashRandomEncounter
   end
   return true  
})

#===============================================================================
# Strength
#===============================================================================
def Kernel.pbStrength
  $game_switches[:Stop_Icycle_Falling] = true
  if $PokemonMap.strengthUsed
    Kernel.pbMessage(_INTL("Strength made it possible to move boulders around."))
  elsif $DEBUG ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSTRENGTH : $Trainer.badges[BADGEFORSTRENGTH])
    movefinder=Kernel.pbCheckMove(:STRENGTH)
    
    if $DEBUG || movefinder
      Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside."))
      if Kernel.pbConfirmMessage(_INTL("Would you like to use Strength?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Strength!\1",speciesname))
        pbHiddenMoveAnimation(movefinder)
        Kernel.pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",speciesname))
        $PokemonMap.strengthUsed=true
        $game_switches[:Stop_Icycle_Falling] = false
        return true
      end
    else
      Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside."))
    end
  else
    Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside."))
  end
  $game_switches[:Stop_Icycle_Falling] = false
  return false
end

Events.onAction+=lambda{|sender,e|
   facingEvent=$game_player.pbFacingEvent
   $surfnodive=false #Fringe cases with diving
   if facingEvent
     if facingEvent.name=="Boulder"
       Kernel.pbStrength
       return
     end
   end
}

HiddenMoveHandlers::CanUseMove.add(:STRENGTH,lambda{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSTRENGTH : $Trainer.badges[BADGEFORSTRENGTH])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if $PokemonMap.strengthUsed
     Kernel.pbMessage(_INTL("Strength is already being used."))
     return false
   end
   return true  
})

HiddenMoveHandlers::UseMove.add(:STRENGTH,lambda{|move,pokemon|
   pbHiddenMoveAnimation(pokemon)
   Kernel.pbMessage(_INTL("{1} used {2}!\1",pokemon.name,PBMoves.getName(move)))
   Kernel.pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",pokemon.name))
   $PokemonMap.strengthUsed=true
   return true  
})

#===============================================================================
# Surf
#===============================================================================
def Kernel.pbSurf
  if $game_player.pbHasDependentEvents?
    return false
  end
  if $game_switches[:Cant_Surf]==true
    return false
  end
  if $DEBUG ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSURF : $Trainer.badges[BADGEFORSURF])
    movefinder=Kernel.pbCheckMove(:SURF)
    if $DEBUG || movefinder
      if $game_switches[:Surf_Convenience] == true
        surfbgm=pbGetMetadata(0,MetadataSurfBGM)
        if surfbgm && $idk[:settings].bike_and_surf_music==1
          pbBGMPlay(surfbgm)
        end
        pbStartSurfing()
        return true
      end
      if Kernel.pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Surf!",speciesname))
        pbHiddenMoveAnimation(movefinder)
        surfbgm=pbGetMetadata(0,MetadataSurfBGM)
        if surfbgm && $idk[:settings].bike_and_surf_music==1
          pbBGMPlay(surfbgm)
        end
        pbStartSurfing()
        $game_switches[:Surf_Convenience] = true
        return true
      end
    end
  end
  return false
end

def pbStartSurfing()
  Kernel.pbCancelVehicles
  $PokemonEncounters.clearStepCount
  $PokemonGlobal.surfing=true
  $game_switches[:Faux_Surf]=true
  $game_map.refresh
  Kernel.pbUpdateVehicle
  Kernel.pbJumpToward
  Kernel.pbUpdateVehicle
  pbSEPlay("Surf Splash")
  $game_player.check_event_trigger_here([1,2])
end

def pbEndSurf(xOffset,yOffset)
  return false if !$PokemonGlobal.surfing
  x=$game_player.x
  y=$game_player.y
  currentTag=$game_map.terrain_tag(x,y)
  facingTag=Kernel.pbFacingTerrainTag
  if pbIsSurfableTag?(currentTag) && !pbIsSurfableTag?(facingTag)
    if Kernel.pbJumpToward(1,false,true)      
#      Kernel.pbCancelVehicles
      $game_switches[:Faux_Surf]=false
      $game_map.autoplayAsCue
      $game_player.increase_steps
      result=$game_player.check_event_trigger_here([1,2])
      Kernel.pbOnStepTaken(result)
      $game_map.refresh
    end
    return true
  end
  return false
end

def Kernel.pbTransferSurfing(mapid,xcoord,ycoord,direction=$game_player.direction)
  pbFadeOutIn(99999){
     $game_temp.player_new_map_id=mapid
     $game_temp.player_new_x=xcoord
     $game_temp.player_new_y=ycoord
     $game_temp.player_new_direction=direction
     Kernel.pbCancelVehicles
     $PokemonGlobal.surfing=true
     Kernel.pbUpdateVehicle
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
  }
end

Events.onAction+=lambda{|sender,e|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if pbIsSurfableTag?(terrain) && !$PokemonGlobal.surfing && 
      !pbGetMetadata($game_map.map_id,MetadataBicycleAlways) && notCliff
     $surfnodive=true #Fringe cases with diving 
     Kernel.pbSurf
     return
   end
}

HiddenMoveHandlers::CanUseMove.add(:SURF,lambda{|move,pkmn|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSURF : $Trainer.badges[BADGEFORSURF])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if $PokemonGlobal.surfing
     Kernel.pbMessage(_INTL("You're already surfing."))
     return false
   end
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     return false
   end
   if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
     Kernel.pbMessage(_INTL("Let's enjoy cycling!"))
     return false
   end
   if !pbIsSurfableTag?(terrain) || !notCliff
     Kernel.pbMessage(_INTL("No surfing here!"))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:SURF,lambda{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   $game_temp.menu_calling = false
   pbStartSurfing()
   return true
})

#===============================================================================
# Waterfall
#===============================================================================
def Kernel.pbAscendWaterfall(event=nil)
  event=$game_player if !event
  return if !event
 return if event.direction==4 || event.direction==6 # can't ascend if not facing up
  oldthrough=event.through
  oldmovespeed=event.move_speed
  terrain=Kernel.pbFacingTerrainTag
  return if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  event.through=true
  event.move_speed=2
  loop do
    if event.direction==8
    event.move_up
    elsif event.direction==2
    event.move_down
    end
    terrain=pbGetTerrainTag(event)
    break if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  end
  event.through=oldthrough
  facingEvent=$game_player.pbFacingEvent
  if facingEvent
    if facingEvent.name=="WTele"
      if event.direction==8
       event.move_up
      elsif event.direction==2
       event.move_down
      end
    end
  end
  event.move_speed=oldmovespeed
end

def Kernel.pbDescendWaterfall(event=nil)
  event=$game_player if !event
  return if !event
  return if event.direction!=2 # Can't descend if not facing down
  oldthrough=event.through
  oldmovespeed=event.move_speed
  terrain=Kernel.pbFacingTerrainTag
  return if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  event.through=true
  event.move_speed=2
  loop do
    event.move_down
    terrain=pbGetTerrainTag(event)
    break if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  end
  event.through=oldthrough
  event.move_speed=oldmovespeed
end

def Kernel.pbWaterfall
  if $DEBUG ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORWATERFALL : $Trainer.badges[BADGEFORWATERFALL])
    movefinder=Kernel.pbCheckMove(:WATERFALL)
    if $DEBUG || movefinder
      if $game_switches[:Waterfall_Convenience] == true
        pbAscendWaterfall
        return true
      end
      if Kernel.pbConfirmMessage(_INTL("It's a large waterfall.  Would you like to use Waterfall?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Waterfall.",speciesname))
        pbHiddenMoveAnimation(movefinder)
        pbAscendWaterfall
        $game_switches[:Waterfall_Convenience] = true
        return true
      end
    else
      Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    end
  else
    Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
  end
  return false
end

Events.onAction+=lambda{|sender,e|
   terrain=Kernel.pbFacingTerrainTag
   if terrain==PBTerrain::Waterfall
     Kernel.pbWaterfall
     return
   end
   if terrain==PBTerrain::WaterfallCrest
     Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
     return
   end
}

HiddenMoveHandlers::CanUseMove.add(:WATERFALL,lambda{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORWATERFALL : $Trainer.badges[BADGEFORWATERFALL])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   terrain=Kernel.pbFacingTerrainTag
   if terrain!=PBTerrain::Waterfall
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:WATERFALL,lambda{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}.",pokemon.name,PBMoves.getName(move)))
   end
   Kernel.pbAscendWaterfall
   return true
})

#===============================================================================
# Dive
#===============================================================================
def Kernel.pbDive
  divemap=pbGetMetadata($game_map.map_id,MetadataDiveMap)
  return false if !divemap
  if $DEBUG ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE])
    movefinder=Kernel.pbCheckMove(:DIVE)
    if $DEBUG || movefinder
      if Kernel.pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Dive.",speciesname))
        pbHiddenMoveAnimation(movefinder)
        pbFadeOutIn(99999){
           $game_temp.player_new_map_id=divemap
           $game_temp.player_new_x=$game_player.x
           $game_temp.player_new_y=$game_player.y
           $game_temp.player_new_direction=$game_player.direction
           Kernel.pbCancelVehicles
           $PokemonGlobal.diving=true
           Kernel.pbUpdateVehicle
           $scene.transfer_player(false)
           $game_map.autoplay
           $game_map.refresh
        }
        return true
      end
    else
      Kernel.pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
    end
  else
    Kernel.pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
  end
  return false
end

def Kernel.pbSurfacing
  return if !$PokemonGlobal.diving
  divemap=nil
  meta=pbLoadMetadata
  facingEvent=$game_player.pbFacingEvent
  for i in 0...meta.length
    if meta[i] && meta[i][MetadataDiveMap]
      if meta[i][MetadataDiveMap]==$game_map.map_id
        divemap=i
        break
      end
    end
  end
  return if !divemap
  movefinder=Kernel.pbCheckMove(:DIVE)
  if !facingEvent
  if $DEBUG || (movefinder &&
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE]) )
    if Kernel.pbConfirmMessage(_INTL("Light is filtering down from above.  Would you like to use Dive?"))
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} used Dive.",speciesname))
      pbHiddenMoveAnimation(movefinder)
      pbFadeOutIn(99999){
         $game_temp.player_new_map_id=divemap
         $game_temp.player_new_x=$game_player.x
         $game_temp.player_new_y=$game_player.y
         $game_temp.player_new_direction=$game_player.direction
         Kernel.pbCancelVehicles
         $PokemonGlobal.surfing=true
         Kernel.pbUpdateVehicle
         $game_switches[:Faux_Surf]=true
         $scene.transfer_player(false)
         surfbgm=pbGetMetadata(0,MetadataSurfBGM)
         if surfbgm && $idk[:settings].bike_and_surf_music==1
           pbCueBGM(surfbgm, 0.5)
         else
           $game_map.autoplayAsCue
         end
         $game_map.refresh
      }
      return true
    end
  else
    Kernel.pbMessage(_INTL("Light is filtering down from above.  A Pokémon may be able to surface here."))
  end
  end
  return false
end

def Kernel.pbTransferUnderwater(mapid,xcoord,ycoord,direction=$game_player.direction)
  pbFadeOutIn(99999){
     $game_temp.player_new_map_id=mapid
     $game_temp.player_new_x=xcoord
     $game_temp.player_new_y=ycoord
     $game_temp.player_new_direction=direction
     Kernel.pbCancelVehicles
     $PokemonGlobal.diving=true
     Kernel.pbUpdateVehicle
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
  }
end

Events.onAction+=lambda{|sender,e|
   terrain=$game_player.terrain_tag
   if terrain==PBTerrain::DeepWater && !$surfnodive
     Kernel.pbDive
     return
   end
   if $PokemonGlobal.diving
     if DIVINGSURFACEANYWHERE
       Kernel.pbSurfacing
       return
     else
       divemap=nil
       meta=pbLoadMetadata
       for i in 0...meta.length
         if meta[i] && meta[i][MetadataDiveMap]
           if meta[i][MetadataDiveMap]==$game_map.map_id
             divemap=i
             break
           end
         end
       end
       if $MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y)==PBTerrain::DeepWater
         Kernel.pbSurfacing
         return
       end
     end
   end
}

HiddenMoveHandlers::CanUseMove.add(:DIVE,lambda{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if $PokemonGlobal.diving
     return true if DIVINGSURFACEANYWHERE
     divemap=nil
     meta=pbLoadMetadata
     for i in 0...meta.length
       if meta[i] && meta[i][MetadataDiveMap]
         if meta[i][MetadataDiveMap]==$game_map.map_id
           divemap=i
           break
         end
       end
     end
     if $MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y)==PBTerrain::DeepWater
       return true
     else
       Kernel.pbMessage(_INTL("Can't use that here."))
       return false
     end
   end
   if $game_player.terrain_tag!=PBTerrain::DeepWater
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataDiveMap)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:DIVE,lambda{|move,pokemon|
   wasdiving=$PokemonGlobal.diving
   if $PokemonGlobal.diving
     divemap=nil
     meta=pbLoadMetadata
     for i in 0...meta.length
       if meta[i] && meta[i][MetadataDiveMap]
         if meta[i][MetadataDiveMap]==$game_map.map_id
           divemap=i
           break
         end
       end
     end
   else
     divemap=pbGetMetadata($game_map.map_id,MetadataDiveMap)
   end
   return false if !divemap
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}.",pokemon.name,PBMoves.getName(move)))
   end
   pbFadeOutIn(99999){
      $game_temp.player_new_map_id=divemap
      $game_temp.player_new_x=$game_player.x
      $game_temp.player_new_y=$game_player.y
      $game_temp.player_new_direction=$game_player.direction
      Kernel.pbCancelVehicles
      if wasdiving
        $PokemonGlobal.surfing=true
      else
        $PokemonGlobal.diving=true
      end
      Kernel.pbUpdateVehicle
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
   }
   return true
})

#===============================================================================
# Fly
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLY,lambda{|move,pkmn|
   if (!$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORFLY : $Trainer.badges[BADGEFORFLY]))
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end 
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     return false
   end
   if $game_switches[:Riding_Tauros]
     Kernel.pbMessage(_INTL("It can't be used while riding a Pokemon."))
     return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:FLY,lambda{|move,pokemon|
   if !$PokemonTemp.flydata
     Kernel.pbMessage(_INTL("Can't use that here."))
   end
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   pbFlyAnimation
   pbSEPlay("PRSFX- Fly2")
   pbFadeOutIn(99999){
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
      $game_temp.player_new_x=$PokemonTemp.flydata[1]
      $game_temp.player_new_y=$PokemonTemp.flydata[2]
      $PokemonTemp.flydata=nil
      $game_temp.player_new_direction=2
      pbToneChangeAll(Tone.new(-255,-255,-255),0)
      $scene.transfer_player
      pbToneChangeAll(Tone.new(0,0,0),8)
      $game_map.autoplay
      $game_map.refresh
      $game_variables[:Forced_Field_Effect] = 0
      # for rage/sleep powder
      $game_switches[:Rage_Powder_Vial] = false
      $game_switches[:Sleep_Powder_Vial] = false
   }
   pbFlyAnimation(true)
   pbEraseEscapePoint
    #$game_screen.setWeather
   return true
})

#===============================================================================
# Flash
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLASH,lambda{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORFLASH : $Trainer.badges[BADGEFORFLASH])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataDarkMap)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if $PokemonGlobal.flashUsed
     Kernel.pbMessage(_INTL("This is in use already."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:FLASH,lambda{|move,pokemon|
   darkness=$PokemonTemp.darknessSprite
   return false if !darkness || darkness.disposed?
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   $PokemonGlobal.flashUsed=true
   while darkness.radius<192
     Graphics.update
     Input.update
     pbUpdateSceneMap
     darkness.radius+=4
   end
   return true
})

#===============================================================================
# Teleport
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:TELEPORT,lambda{|move,pkmn|
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if Reborn && ($game_map.map_id == 887 || $game_map.map_id == 854) # for Taka ... also Sigmund. 
     Kernel.pbMessage(_INTL("It can't be used here."))
     return false
   end
   if $game_switches[:Riding_Tauros]
     Kernel.pbMessage(_INTL("It can't be used while riding a Pokemon."))
     return false
   end
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     return false
   end
   healing=$PokemonGlobal.healingSpot
   if !healing
     healing=pbGetMetadata(0,MetadataHome) # Home
   end
   if healing
     mapname=pbGetMapNameFromId(healing[0])
     if Kernel.pbConfirmMessage(_INTL("Want to return to the healing spot used last in {1}?",mapname))
       return true
     end
     return false
   else
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
})

HiddenMoveHandlers::UseMove.add(:TELEPORT,lambda{|move,pokemon|
   healing=$PokemonGlobal.healingSpot
   if !healing
     healing=pbGetMetadata(0,MetadataHome)
   end
   if healing
     if !pbHiddenMoveAnimation(pokemon)
       Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
     end
     pbFadeOutIn(99999){
        Kernel.pbCancelVehicles
        $game_temp.player_new_map_id=healing[0]
        $game_temp.player_new_x=healing[1]
        $game_temp.player_new_y=healing[2]
        $game_temp.player_new_direction=2
        pbToneChangeAll(Tone.new(-255,-255,-255),0)
        $scene.transfer_player
        pbToneChangeAll(Tone.new(0,0,0),8)
        $game_map.autoplay
        $game_map.refresh
        $game_variables[:Forced_Field_Effect] = 0
        # for rage/sleep powder
        $game_switches[:Rage_Powder_Vial] = false
        $game_switches[:Sleep_Powder_Vial] = false
     }
     pbEraseEscapePoint
    #$game_screen.setWeather
    return true
   end
   return false
})

#===============================================================================
# Dig
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:DIG,lambda{|move,pkmn|
   escape=($PokemonGlobal.escapePoint rescue nil)
   if !escape || escape==[]
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     return false
   end
   mapname=pbGetMapNameFromId(escape[0])
   if Kernel.pbConfirmMessage(_INTL("Want to escape from here and return to {1}?",mapname))
     return true
   end
   return false
})

HiddenMoveHandlers::UseMove.add(:DIG,lambda{|move,pokemon|
   escape=($PokemonGlobal.escapePoint rescue nil)
   if escape
     if !pbHiddenMoveAnimation(pokemon)
       Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
     end
     pbFadeOutIn(99999){
        Kernel.pbCancelVehicles
        $game_temp.player_new_map_id=escape[0]
        $game_temp.player_new_x=escape[1]
        $game_temp.player_new_y=escape[2]
        $game_temp.player_new_direction=escape[3]
        pbToneChangeAll(Tone.new(-255,-255,-255),0)
        $scene.transfer_player
        pbToneChangeAll(Tone.new(0,0,0),8)
        $game_map.autoplay
        $game_map.refresh
        if pbIsWaterTag?(Kernel.pbFacingTerrainTag) && !$PokemonGlobal.surfing 
          $PokemonEncounters.clearStepCount
          $PokemonGlobal.surfing=true
          $game_switches[:Faux_Surf]=true
          $game_map.refresh
          Kernel.pbUpdateVehicle      
        end          
        $game_variables[:Forced_Field_Effect] = 0
     }
     
     pbEraseEscapePoint
     terrain=Kernel.pbFacingTerrainTag
     if pbIsWaterTag?(terrain) && !$PokemonGlobal.surfing 
      pbStartSurfing()
        return true
      end
    #$game_screen.setWeather     
     return true
   end
   return false
})

def pbFakeDig
     escape=($PokemonGlobal.escapePoint rescue nil)
     if escape
     pbFadeOutIn(99999){
        Kernel.pbCancelVehicles
        $game_temp.player_new_map_id=escape[0]
        $game_temp.player_new_x=escape[1]
        $game_temp.player_new_y=escape[2]
        $game_temp.player_new_direction=escape[3]
        pbToneChangeAll(Tone.new(-255,-255,-255),0)
        $scene.transfer_player
        pbToneChangeAll(Tone.new(0,0,0),8)
        $game_map.autoplay
        $game_map.refresh
        if pbIsWaterTag?(Kernel.pbFacingTerrainTag) && !$PokemonGlobal.surfing 
          $PokemonEncounters.clearStepCount
          $PokemonGlobal.surfing=true
          $game_switches[:Faux_Surf]=true
          $game_map.refresh
          Kernel.pbUpdateVehicle      
        end          
        $game_variables[:Forced_Field_Effect] = 0        
     }
          
     
     pbEraseEscapePoint
     terrain=Kernel.pbFacingTerrainTag
     if pbIsWaterTag?(terrain) && !$PokemonGlobal.surfing 
      pbStartSurfing()
        return true
      end 
     return true
   end
   end

#===============================================================================
# Sweet Scent
#===============================================================================
def pbSweetScent
  if $game_screen.weather_type!=0
    Kernel.pbMessage(_INTL("The sweet scent faded for some reason..."))
    return
  end
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  count=0
  viewport.color.alpha-=10 
  begin
    if viewport.color.alpha<128 && count==0
      viewport.color.red=255
      viewport.color.green=0
      viewport.color.blue=0
      viewport.color.alpha+=8
    else
      count+=1
      if count>10
        viewport.color.alpha-=8 
      end
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end until viewport.color.alpha<=0
  viewport.dispose
  encounter=nil
  enctype=nil
  enctype=$PokemonEncounters.pbEncounterType
  if enctype<0 || !$PokemonEncounters.isEncounterPossibleHere?() ||
     !pbEncounter(enctype)
    Kernel.pbMessage(_INTL("There appears to be nothing here..."))
  end
end

HiddenMoveHandlers::CanUseMove.add(:SWEETSCENT,lambda{|move,pkmn|
   return true
})

HiddenMoveHandlers::UseMove.add(:SWEETSCENT,lambda{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   pbSweetScent
   return true
})

#===============================================================================
# Relic Song
#===============================================================================

#actually already preformes the change so it happens in the menu instead of weirdly going to 
HiddenMoveHandlers::CanUseMove.add(:RELICSONG,lambda{|move,pokemon|
  if pokemon.species == PBSpecies::MELOETTA && (pokemon.form==0 || pokemon.form==1)
    Kernel.pbMessage(_INTL("{1} used {2} to change its form!",pokemon.name,PBMoves.getName(move)))
    pbHiddenMoveAnimation(pokemon)
    pokemon.form= pokemon.form==0 ? 1 : 0
  else
    Kernel.pbMessage(_INTL("{1} used {2}! \nBut nothing happened.",pokemon.name,PBMoves.getName(move)))
  end
  return false
})

HiddenMoveHandlers::UseMove.add(:RELICSONG,lambda{|move,pokemon|
  return true
})

#===============================================================================
# General functions
#===============================================================================

def Kernel.pbCanUseHiddenMove?(pkmn,move)
  return HiddenMoveHandlers.triggerCanUseMove(move,pkmn)
end

def Kernel.pbUseHiddenMove(pokemon,move)
  return HiddenMoveHandlers.triggerUseMove(move,pokemon)
end

def Kernel.pbHiddenMoveEvent
  Events.onAction.trigger(nil)
end