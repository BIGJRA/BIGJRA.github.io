class PokemonTemp
  attr_accessor :dependentEvents

  def dependentEvents
    @dependentEvents=DependentEvents.new if !@dependentEvents
    return @dependentEvents
  end
end

def pbRemoveDependencies()
  $PokemonTemp.dependentEvents.removeAllEvents()
  pbDeregisterPartner() rescue nil
end

def pbAddDependency(event)
  $PokemonTemp.dependentEvents.addEvent(event)
end

def pbRemoveDependency(event)
  $PokemonTemp.dependentEvents.removeEvent(event)
end

def pbAddDependency2(eventID, eventName, commonEvent)
  $PokemonTemp.dependentEvents.addEvent($game_map.events[eventID],eventName,commonEvent)
end

def pbDependentEventOpacity(opacity)
  $PokemonTemp.dependentEvents.eachEvent {|e,d|   
    e.opacity = opacity
    }
end

# Gets the Game_Character object associated with a dependent event.
def pbGetDependency(eventName)
  return $PokemonTemp.dependentEvents.getEventByName(eventName)
end

def pbRemoveDependency2(eventName)
  $PokemonTemp.dependentEvents.removeEventByName(eventName)
end



class PokemonGlobalMetadata
  attr_accessor :dependentEvents

  def dependentEvents
    @dependentEvents=[] if !@dependentEvents
    return @dependentEvents
  end
end



class Game_Event
  def set_starting
    @starting=true
  end
end



def pbTestPass(follower,x,y,direction=nil)
  return $MapFactory.isPassableStrict?(follower.map.map_id,x,y,follower)
end

# Same map only
def moveThrough(follower,direction)
  oldThrough=follower.through
  follower.through=true
  case direction
    when 2 # down
      follower.move_down
    when 4 # left
      follower.move_left
    when 6 # right
      follower.move_right
    when 8 # up
      follower.move_up
  end 
  follower.through=oldThrough
end

# Same map only
def moveFancy(follower,direction)
  deltaX=(direction == 6 ? 1 : (direction == 4 ? -1 : 0))
  deltaY=(direction == 2 ? 1 : (direction == 8 ? -1 : 0))
  newX = follower.x + deltaX
  newY = follower.y + deltaY
  # Move if new position is the player's, or the new position is passable,
  # or the current position is not passable
  if ($game_player.x==newX && $game_player.y==newY) ||
    passable?(newX,newY) ||
     pbTestPass(follower,newX,newY,0) ||
     !pbTestPass(follower,follower.x,follower.y,0)
    oldThrough=follower.through
    follower.through=true
    case direction
      when 1 # down-right
        follower.move_lower_right
      when 2 # down
        follower.move_down
      when 3 # down-left
        follower.move_lower_left
      when 4 # left
        follower.move_left
      when 5 # up-right
        follower.move_upper_right
      when 6 # right
        follower.move_right
      when 7 # up-left
        follower.move_upper_left
      when 8 # up
        follower.move_up
    end 
    follower.through=oldThrough
  end
end

# Same map only
def jumpFancy(follower,direction,distance)
  deltaX=(direction == 6 ? distance : (direction == 4 ? -distance : 0))
  deltaY=(direction == 2 ? distance : (direction == 8 ? -distance : 0))
  halfDeltaX=(direction == 6 ? 1 : (direction == 4 ? -1 : 0))
  halfDeltaY=(direction == 2 ? 1 : (direction == 8 ? -1 : 0))
  middle=pbTestPass(follower,follower.x+halfDeltaX,follower.y+halfDeltaY,0)
  ending=pbTestPass(follower,follower.x+deltaX,    follower.y+deltaY,    0)
  follower.jump(deltaX,deltaY)
  return
end

def pbFancyMoveTo(follower,newX,newY)
  if follower.y-newY==1 && follower.x==newX
    moveFancy(follower,8)
  elsif follower.x-newX==-1 && follower.y==newY
    moveFancy(follower,6)
  elsif follower.x-newX==1 && follower.y==newY
    moveFancy(follower,4)
  elsif follower.y-newY==-1 && follower.x==newX
    moveFancy(follower,2)
  elsif follower.y-newY==1 && follower.x-newX==1
    moveFancy(follower,7)
  elsif follower.y-newY==1 && follower.x-newX==-1
    moveFancy(follower,5)
  elsif follower.y-newY==-1 && follower.x-newX==1
    moveFancy(follower,3)
  elsif follower.y-newY==-1 && follower.x-newX==-1
    moveFancy(follower,1)
  elsif follower.x-newX==-3 && follower.y==newY
    jumpFancy(follower,6,3)
  elsif follower.x-newX==3 && follower.y==newY
    jumpFancy(follower,4,3)
  elsif follower.y-newY==-3 && follower.x==newX
    jumpFancy(follower,2,3)
  elsif follower.y-newY==3 && follower.x==newX
    jumpFancy(follower,8,3)
  elsif follower.x-newX==-2 && follower.y==newY
    jumpFancy(follower,6,2)
  elsif follower.x-newX==2 && follower.y==newY
    jumpFancy(follower,4,2)
  elsif follower.y-newY==-2 && follower.x==newX
    jumpFancy(follower,2,2)
  elsif follower.y-newY==2 && follower.x==newX
    jumpFancy(follower,8,2)
  elsif follower.x!=newX || follower.y!=newY
    follower.moveto(newX,newY)
  end
end



class DependentEvents
  def createEvent(eventData)
    rpgEvent=RPG::Event.new(eventData[3],eventData[4])
    rpgEvent.id=eventData[1]
    if eventData[9]
      # Must setup common event list here and now
      commonEvent=Game_CommonEvent.new(eventData[9])
      rpgEvent.pages[0].list=commonEvent.list
    end
    newEvent=Game_Event.new(eventData[0],rpgEvent,
       $MapFactory.getMap(eventData[2]))
    newEvent.character_name=eventData[6]
    newEvent.character_hue=eventData[7]
    case eventData[5] # direction
      when 2 # down
        newEvent.turn_down
      when 4 # left
        newEvent.turn_left
      when 6 # right
        newEvent.turn_right
      when 8 # up
        newEvent.turn_up
    end
    return newEvent
  end

  attr_reader :lastUpdate

  def initialize
    # Original map, Event ID, Current map, X, Y, Direction
    events=$PokemonGlobal.dependentEvents
    @realEvents=[]
    @lastUpdate=-1
    for event in events
      @realEvents.push(createEvent(event))
    end
  end

  def pbEnsureEvent(event, newMapID)
    events=$PokemonGlobal.dependentEvents
    found=-1
    for i in 0...events.length
      # Check original map ID and original event ID 
      if events[i][0]==event.map_id && events[i][1]==event.id
        # Change current map ID
        events[i][2]=newMapID
        newEvent=createEvent(events[i])
        # Replace event
        @realEvents[i]=newEvent
        @lastUpdate+=1
        return i
      end
    end
    return -1
  end

  def pbFollowEventAcrossMaps(leader,follower,instant=false,leaderIsTrueLeader=true)
    d=leader.direction
    olderX = follower.x
    olderY = follower.y
    areConnected=$MapFactory.areConnected?(leader.map.map_id,follower.map.map_id)
    # Get the rear facing tile of leader
    facingDirection=[0,0,8,0,6,0,4,0,2][d]
    if !leaderIsTrueLeader && areConnected
      relativePos=$MapFactory.getThisAndOtherEventRelativePos(leader,follower)
      if (relativePos[1]==0 && relativePos[0]==2) # 2 spaces to the right of leader
        facingDirection=6
      elsif (relativePos[1]==0 && relativePos[0]==-2) # 2 spaces to the left of leader
        facingDirection=4
      elsif relativePos[1]==-2 && relativePos[0]==0 # 2 spaces above leader
        facingDirection=8
      elsif relativePos[1]==2 && relativePos[0]==0 # 2 spaces below leader
        facingDirection=2
      end
    end
    facings=[facingDirection] # Get facing from behind
    facings.push([0,0,4,0,8,0,2,0,6][d]) # Get right facing
    facings.push([0,0,6,0,2,0,8,0,4][d]) # Get left facing
    if !leaderIsTrueLeader
      facings.push([0,0,2,0,4,0,6,0,8][d]) # Get forward facing
    end
    mapTile=nil
    if areConnected
      bestRelativePos=-1
      oldthrough=follower.through
      follower.through=false
      for i in 0...facings.length
        facing=facings[i]
        tile=$MapFactory.getFacingTile(facing,leader)
        # The commented passability check is incorrect. There is better
        # check later in moveFancy function so no need to do it here.
        # passable=tile && $MapFactory.isPassableStrict?(tile[0],tile[1],tile[2],follower)
        passable=true        
        if i==0 && !passable && tile && 
           $MapFactory.getTerrainTag(tile[0],tile[1],tile[2])==PBTerrain::Ledge
          # If the tile isn't passable and the tile is a ledge,
          # get tile from further behind
          tile=$MapFactory.getFacingTileFromPos(tile[0],tile[1],tile[2],facing)
          passable=tile && $MapFactory.isPassableStrict?(tile[0],tile[1],tile[2],follower)
        end
        if passable
          relativePos=$MapFactory.getThisAndOtherPosRelativePos(
             follower,tile[0],tile[1],tile[2])
          distance=Math.sqrt(relativePos[0]*relativePos[0]+relativePos[1]*relativePos[1])
          if bestRelativePos==-1 || bestRelativePos>distance
            bestRelativePos=distance
            mapTile=tile
          end
          if i==0 && distance<=1 # Prefer behind if tile can move up to 1 space
            break
          end
        end
      end
      follower.through=oldthrough
    else
      tile=$MapFactory.getFacingTile(facings[0],leader)
      passable=tile && $MapFactory.isPassableStrict?(
         tile[0],tile[1],tile[2],follower)
      mapTile=passable ? mapTile : nil
    end
    if mapTile && follower.map.map_id==mapTile[0]
      # Follower is on same map
      newX=mapTile[1]
      newY=mapTile[2]
      deltaX=(d == 6 ? -1 : d == 4 ? 1 : 0)
      deltaY=(d == 2 ? -1 : d == 8 ? 1 : 0)
      posX = newX + deltaX
      posY = newY + deltaY
      newX = @oldXLed if @oldXLed   #added for better movement of dependent events
      newY = @oldYLed if @oldYLed
      follower.move_speed=leader.move_speed # sync movespeed
      if (follower.x-newX>=-3 && follower.x-newX <=3 && follower.y==newY) ||
         (follower.y-newY>=-3 && follower.y-newY <=3 && follower.x==newX) ||
         (follower.y-newY==1 && follower.x-newX==1) ||
         (follower.y-newY==-1 && follower.x-newX==1) ||
         (follower.y-newY==1 && follower.x-newX==-1) ||
         (follower.y-newY==-1 && follower.x-newX==-1)
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,newX,newY)
        end
      elsif follower.x!=posX || follower.y!=posY
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,posX,posY)
          pbFancyMoveTo(follower,newX,newY)
        end
      end
      pbTurnTowardEvent(follower,leader)
    else
      if !mapTile
        # Make current position into leader's position        
        mapTile=[leader.map.map_id,leader.x,leader.y]               
      end
      if follower.map.map_id==mapTile[0]
        # Follower is on same map as leader
        #follower.moveto(leader.x,leader.y) # THIS LINE WAS COMMENTED OUT SO DEPENDENT STAYS IF IT WOULD BE FORCED TO GO TO THE SAME SPOT AS PLAYER
        pbTurnTowardEvent(follower,leader)
      else
        # Follower will move to different map
        events=$PokemonGlobal.dependentEvents
        eventIndex=pbEnsureEvent(follower,mapTile[0])
        if eventIndex>=0
          newFollower=@realEvents[eventIndex]
          newEventData=events[eventIndex]
          newFollower.moveto(mapTile[1],mapTile[2])
          newEventData[3]=mapTile[1]
          newEventData[4]=mapTile[2]
          if mapTile[0]==leader.map.map_id
            pbTurnTowardEvent(follower,leader)
          end
        end
      end
    end
  end

  def debugEcho
    self.eachEvent {|e,d|
       echoln d
       echoln [e.map_id,e.map.map_id,e.id]
    }
  end

  def pbMapChangeMoveDependentEvents
    events=$PokemonGlobal.dependentEvents
    updateDependentEvents
    leader=$game_player
    for i in 0...events.length
      event=@realEvents[i]
      pbFollowEventAcrossMaps(leader,event,true,i==0)
      # Update X and Y for this event
      events[i][3]=event.x
      events[i][4]=event.y
      events[i][5]=event.direction
      # Set leader to this event
      leader=event
    end
  end

  def pbMoveDependentEvents(oldXleader,oldYleader)
    events=$PokemonGlobal.dependentEvents
    updateDependentEvents
    leader=$game_player
    @oldXLed = oldXleader
    @oldYLed = oldYleader
    for i in 0...events.length
      event=@realEvents[i]
      pbFollowEventAcrossMaps(leader,event,false,i==0)
      # Update X and Y for this event
      events[i][3]=event.x
      events[i][4]=event.y
      events[i][5]=event.direction
      # Set leader to this event
      leader=event
    end
  end  

  def pbTurnDependentEvents
    events=$PokemonGlobal.dependentEvents
    updateDependentEvents
    leader=$game_player
    for i in 0...events.length
      event=@realEvents[i]
      pbTurnTowardEvent(event,leader)
      # Update direction for this event
      events[i][5]=event.direction
      # Set leader to this event
      leader=event
    end
  end

  def eachEvent
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      yield @realEvents[i],events[i]
    end   
  end

  def updateDependentEvents
    events=$PokemonGlobal.dependentEvents
    return if events.length==0
    for i in 0...events.length
      event=@realEvents[i]
      next if !@realEvents[i]
      event.transparent=$game_player.transparent
      if (event.jumping? || event.moving?) || !($game_player.jumping? || $game_player.moving?) then
        event.update
      elsif !event.starting
        event.set_starting
        event.update
        event.clear_starting
      end
      events[i][3]=event.x
      events[i][4]=event.y
      events[i][5]=event.direction
    end
    # Check event triggers
    if Input.trigger?(Input::C) && !pbMapInterpreterRunning?
      # Get position of tile facing the player
      facingTile=$MapFactory.getFacingTile()
      self.eachEvent {|e,d|
         next if !d[9]
         if e.x==$game_player.x && e.y==$game_player.y
           # On same position
           if !e.jumping? && (!e.respond_to?("over_trigger") || e.over_trigger?)
             if e.list.size>1
               # Start event
               $game_map.refresh if $game_map.need_refresh
               e.lock
               pbMapInterpreter.setup(e.list,e.id,e.map.map_id)
             end
           end
         elsif facingTile && e.map.map_id==facingTile[0] &&
               e.x==facingTile[1] && e.y==facingTile[2]
           # On facing tile
           if !e.jumping? && (!e.respond_to?("over_trigger") || !e.over_trigger?)
             if e.list.size>1
               # Start event
               $game_map.refresh if $game_map.need_refresh
               e.lock
               pbMapInterpreter.setup(e.list,e.id,e.map.map_id)
             end
           end
         end
      }
    end
  end

  def removeEvent(event)
    events=$PokemonGlobal.dependentEvents
    mapid=$game_map.map_id
    for i in 0...events.length
      if events[i][2]==mapid && # Refer to current map
         events[i][0]==event.map_id && # Event's map ID is original ID
         events[i][1]==event.id
        events[i]=nil
        @realEvents[i]=nil
        @lastUpdate+=1
      end
      events.compact!
      @realEvents.compact!
    end
  end

  def getEventByName(name)
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]==name # Arbitrary name given to dependent event
        return @realEvents[i]
      end
    end
    return nil
  end

  def removeAllEvents
    events=$PokemonGlobal.dependentEvents
    events.clear
    @realEvents.clear
    @lastUpdate+=1
  end

  def removeEventByName(name)
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]==name # Arbitrary name given to dependent event
        events[i]=nil
        @realEvents[i]=nil
        @lastUpdate+=1
      end
      events.compact!
      @realEvents.compact!
    end
  end

  def addEvent(event,eventName=nil,commonEvent=nil)
    return if !event
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][0]==$game_map.map_id && events[i][1]==event.id
        # Already exists
        return
      end
    end
    # Original map ID, original event ID, current map ID,
    # event X, event Y, event direction,
    # event's filename,
    # event's hue, event's name, common event ID    
    eventData=[
       $game_map.map_id,event.id,$game_map.map_id,
       event.x,event.y,event.direction,
       event.character_name.clone,
       event.character_hue,eventName,commonEvent
    ]
    newEvent=createEvent(eventData)
    events.push(eventData)
    @realEvents.push(newEvent)
    @lastUpdate+=1
    event.erase
  end
end



class DependentEventSprites
  def refresh
    for sprite in @sprites
      sprite.dispose
    end
    @sprites.clear
    $PokemonTemp.dependentEvents.eachEvent {|event,data|
       if data[0]==@map.map_id # Check original map
         @map.events[data[1]].erase if @map.events[data[1]]
       end
       if data[2]==@map.map_id # Check current map
         @sprites.push(Sprite_Character.new(@viewport,event))
       end
    }
  end

  def initialize(viewport,map)
    @disposed=false
    @sprites=[]
    @map=map
    @viewport=viewport
    refresh
    @lastUpdate=nil
  end

  def update
    if $PokemonTemp.dependentEvents.lastUpdate!=@lastUpdate
      refresh
      @lastUpdate=$PokemonTemp.dependentEvents.lastUpdate
    end
    for sprite in @sprites
      sprite.update
    end
  end

  def dispose
    return if @disposed
    for sprite in @sprites
      sprite.dispose
    end
    @sprites.clear
    @disposed=true
  end

  def disposed?
    @disposed
  end
end



Events.onSpritesetCreate+=proc{|sender,e|
   spriteset=e[0] # Spriteset being created
   viewport=e[1] # Viewport used for tilemap and characters
   map=spriteset.map # Map associated with the spriteset (not necessarily the current map).
   spriteset.addUserSprite(DependentEventSprites.new(viewport,map))
}

Events.onMapSceneChange+=proc{|sender,e|
   scene=e[0]
   mapChanged=e[1]
   if mapChanged
     $PokemonTemp.dependentEvents.pbMapChangeMoveDependentEvents
   end
}