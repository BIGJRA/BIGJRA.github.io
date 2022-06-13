class SafariState
  attr_accessor :ballcount
  attr_accessor :decision
  attr_accessor :steps

  def initialize
    @start=nil
    @ballcount=0
    @inProgress=false
    @steps=0
    @decision=0
  end

  def pbReceptionMap
    return @inProgress ? @start[0] : 0
  end

  def inProgress?
    return @inProgress
  end

  def pbGoToStart
    if $scene.is_a?(Scene_Map)
      pbFadeOutIn(99999){
         $game_temp.player_transferring = true
         $game_temp.transition_processing = true
         $game_temp.player_new_map_id = @start[0]
         $game_temp.player_new_x = @start[1]
         $game_temp.player_new_y = @start[2]
         $game_temp.player_new_direction = 2
         $scene.transfer_player
      }
    end
  end

  def pbStart(ballcount)
    @start=[$game_map.map_id,$game_player.x,$game_player.y,$game_player.direction]
    @ballcount=ballcount
    @inProgress=true
    @steps=SAFARISTEPS
  end

  def pbEnd
    @start=nil
    @ballcount=0
    @inProgress=false
    @steps=0
    @decision=0
    $game_map.need_refresh=true
  end
end



Events.onMapChange+=proc{|sender,args|
   if !pbInSafari?
     pbSafariState.pbEnd
   end
}

def pbInSafari?
  if pbSafariState.inProgress?
    # Reception map is handled separately from safari map since the reception
    # map can be outdoors, with its own grassy patches.
    reception=pbSafariState.pbReceptionMap
    return true if $game_map.map_id==reception
    if pbGetMetadata($game_map.map_id,MetadataSafariMap)
      return true
    end
  end
  return false
end

def pbSafariState
  if !$PokemonGlobal.safariState
    $PokemonGlobal.safariState=SafariState.new
  end
  return $PokemonGlobal.safariState
end

Events.onStepTakenTransferPossible+=proc {|sender,e|
   handled=e[0]
   next if handled[0]
   if pbInSafari? && pbSafariState.decision==0 && SAFARISTEPS>0
     pbSafariState.steps-=1
     if pbSafariState.steps<=0
       Kernel.pbMessage(_INTL("PA:  Ding-dong!\1")) 
       Kernel.pbMessage(_INTL("PA:  Your safari game is over!"))
       pbSafariState.decision=1
       pbSafariState.pbGoToStart
       handled[0]=true
     end
   end
}

Events.onWildBattleOverride+= proc { |sender,e|
   species=e[0]
   level=e[1]
   handled=e[2]
   next if handled[0]!=nil
   next if !pbInSafari?
   handled[0]=pbSafariBattle(species,level)
}

def pbSafariBattle(species,level)
  genwildpoke=pbGenerateWildPokemon(species,level)
  scene=pbNewBattleScene
  battle=PokeBattle_SafariZone.new(scene,$Trainer,[genwildpoke])
  battle.ballcount=pbSafariState.ballcount
  battle.environment=pbGetEnvironment
  decision=0
  pbBattleAnimation(0,pbGetWildBattleBGM(species)) { 
     pbSceneStandby {
        decision=battle.pbStartBattle
     }
  }
  pbSafariState.ballcount=battle.ballcount
  Input.update
  if pbSafariState.ballcount<=0
    if decision!=2 && decision!=5
      Kernel.pbMessage(_INTL("Announcer:  You're out of Safari Balls! Game over!")) 
    end
    pbSafariState.decision=1
    pbSafariState.pbGoToStart
  end
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  return decision
end