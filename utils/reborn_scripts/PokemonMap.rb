################################################################################
# This class keeps track of erased and moved events so their position
# can remain after a game is saved and loaded.  This class also includes
# variables that should remain valid only for the current map.
################################################################################
class PokemonMapMetadata
  attr_reader :erasedEvents
  attr_reader :movedEvents    
  attr_accessor :strengthUsed
  attr_accessor :blackFluteUsed
  attr_accessor :whiteFluteUsed
  attr_accessor :bridge

  def initialize
    clear
  end

  def clear
    @erasedEvents={}
    @movedEvents={}
    @strengthUsed=false
    @blackFluteUsed=false
    @whiteFluteUsed=false
    $game_switches[:Rock_Climb_Convenience] = false
    $game_switches[:Cut_Convenience] = false
    $game_switches[:Waterfall_Convenience] = false
    $game_switches[:Surf_Convenience] = false
    $game_switches[:Rock_Smash_Convenience] = false
    @bridge=0
  end

  def addErasedEvent(eventID)
    key=[$game_map.map_id,eventID]
    @erasedEvents[key]=true
  end

  def addMovedEvent(eventID)
    key=[$game_map.map_id,eventID]
    event=$game_map.events[eventID]
    @movedEvents[key]=[event.x,event.y,event.direction,event.through]
  end

  def updateMap
    for i in @erasedEvents
      if i[0][0]==$game_map.map_id && i[1]
        event=$game_map.events[i[0][1]]
        event.erase if event
      end
    end
    for i in @movedEvents
      if i[0][0]==$game_map.map_id && i[1]
        next if !$game_map.events[i[0][1]]
        $game_map.events[i[0][1]].moveto(i[1][0],i[1][1])
        case i[1][2]
          when 2
            $game_map.events[i[0][1]].turn_down
          when 4
            $game_map.events[i[0][1]].turn_left
          when 6
            $game_map.events[i[0][1]].turn_right
          when 8
            $game_map.events[i[0][1]].turn_up
        end
      end
      if i[1][3]!=nil
        $game_map.events[i[0][1]].through=i[1][3]
      end
    end
  end
end

################################################################################
# Global metadata not specific to a map.  This class holds
# field state data that span multiple maps.
################################################################################
class PokemonGlobalMetadata
  attr_accessor :bicycle
  attr_accessor :riding
  attr_accessor :surfing
  attr_accessor :diving
  attr_accessor :sliding
  attr_accessor :fishing
  attr_accessor :repel
  attr_accessor :flashUsed
  attr_accessor :runningShoes
  attr_accessor :snagMachine
 # attr_accessor :megaRing
  attr_accessor :seenStorageCreator
  attr_accessor :startTime
  attr_accessor :creditsPlayed
  attr_accessor :playerID
  attr_accessor :coins
  attr_accessor :sootsack
  attr_accessor :mailbox
  attr_accessor :pcItemStorage
  attr_accessor :stepcount
  attr_accessor :happinessSteps
  attr_accessor :pokerusTime
  attr_accessor :daycare
  attr_accessor :daycareEgg
  attr_accessor :daycareEggSteps
  attr_accessor :pokedexUnlocked # Array storing which Dexes are unlocked
  attr_accessor :pokedexViable   # All Dexes of non-zero length and unlocked
  attr_accessor :pokedexDex      # Dex currently looking at (-1 is National Dex)
  attr_accessor :pokedexIndex    # Last species viewed per Dex
  attr_accessor :pokedexMode     # Search mode
  attr_accessor :healingSpot
  attr_accessor :escapePoint
  attr_accessor :pokecenterMapId
  attr_accessor :pokecenterX
  attr_accessor :pokecenterY
  attr_accessor :pokecenterDirection
  attr_accessor :visitedMaps
  attr_accessor :mapTrail
  attr_accessor :nextBattleBGM
  attr_accessor :nextBattleME
  attr_accessor :nextBattleBack
  attr_accessor :safariState
  attr_accessor :partner
  attr_accessor :challenge
  attr_accessor :lastbattle
  attr_accessor :phoneNumbers
  attr_accessor :phoneTime
  attr_accessor :eventvars
  attr_accessor :safesave

  def initialize
    @riding = false
    @bicycle              = false
    @surfing              = false
    @diving               = false
    @sliding              = false
    @fishing              = false
    @repel                = 0
    @flashused            = false
    @runningShoes         = false
    @snagMachine          = false
    @seenStorageCreator   = false
    @startTime            = Time.now
    @creditsPlayed        = false
    @playerID             = -1
    @coins                = 0
    @sootsack             = 0
    @mailbox              = nil
    @pcItemStorage        = nil
    @stepcount            = 0
    @happinessSteps       = 0
    @pokerusTime          = nil
    @daycare              = [[nil,0],[nil,0]]
    @daycareEgg           = false
    @daycareEggSteps      = 0
    numRegions = 0
    @pokedexUnlocked      = []
    @pokedexViable        = []
    @pokedexDex           = (numRegions==0) ? -1 : 0
    @pokedexIndex         = []
    @pokedexMode          = 0
    for i in 0...numRegions+1     # National Dex isn't a region, but is included
      @pokedexIndex[i]    = 0
      @pokedexUnlocked[i] = (i==0)
    end
    @healingSpot          = nil
    @escapePoint          = []
    @pokecenterMapId      = -1
    @pokecenterX          = -1
    @pokecenterY          = -1
    @pokecenterDirection  = -1
    @visitedMaps          = []
    @mapTrail             = []
    @nextBattleBGM        = nil
    @nextBattleME         = nil
    @nextBattleBack       = nil
    @safariState          = nil
    @partner              = nil
    @challenge            = nil
    @lastbattle           = nil
    @phoneNumbers         = []
    @phoneTime            = 0
    @eventvars            = {}
    @safesave             = false
  end
end

################################################################################
# Temporary data which is not saved and which is erased when a game restarts.
################################################################################

class PokemonTemp
  attr_accessor :menuLastChoice
  attr_accessor :keyItemCalling
  attr_accessor :hiddenMoveEventCalling
  attr_accessor :begunNewGame
  attr_accessor :miniupdate
  attr_accessor :waitingTrainer
  attr_accessor :darknessSprite
  attr_accessor :pokemonMetadata
  attr_accessor :pokemonDexData
  attr_accessor :lastbattle
  attr_accessor :flydata

  def initialize
    @menuLastChoice         = 0
    @keyItemCalling         = false
    @hiddenMoveEventCalling = false
    @begunNewGame           = false
    @miniupdate             = false
    @waitingTrainer         = nil
    @darknessSprite         = nil
    @pokemonDexData         = nil
    @pokemonMetadata        = nil
    @pokemonPhoneData       = nil
    @lastbattle             = nil
    @flydata                = nil
  end
end

MetadataHome             = 1
MetadataWildBattleBGM    = 2
MetadataTrainerBattleBGM = 3
MetadataWildVictoryME    = 4
MetadataTrainerVictoryME = 5
MetadataSurfBGM          = 6
MetadataBicycleBGM       = 7
MetadataPlayerA          = 8
MetadataPlayerB          = 9
MetadataPlayerC          = 10
MetadataPlayerD          = 11
MetadataPlayerE          = 12
MetadataPlayerF          = 13
MetadataPlayerG          = 14
MetadataPlayerH          = 15
MetadataPlayerI          = 16
MetadataPlayerJ          = 17
MetadataPlayerK          = 18
MetadataPlayerL          = 19
MetadataPlayerM          = 20
MetadataPlayerN          = 21
MetadataPlayerO          = 22
MetadataPlayerP          = 23
MetadataPlayerQ          = 24
MetadataPlayerR          = 25
MetadataPlayerS          = 26
MetadataPlayerT          = 27
MetadataPlayerU          = 28
MetadataPlayerV          = 29
MetadataPlayerW          = 30
MetadataPlayerX          = 31
MetadataPlayerY          = 32

MetadataOutdoor             = 1
MetadataShowArea            = 2
MetadataBicycle             = 3
MetadataBicycleAlways       = 4
MetadataHealingSpot         = 5
MetadataWeather             = 6
MetadataMapPosition         = 7
MetadataDiveMap             = 8
MetadataDarkMap             = 9
MetadataSafariMap           = 10
MetadataSnapEdges           = 11
MetadataDungeon             = 12
MetadataBattleBack          = 13
MetadataMapWildBattleBGM    = 14
MetadataMapTrainerBattleBGM = 15
MetadataMapWildVictoryME    = 16
MetadataMapTrainerVictoryME = 17
MetadataMapSize             = 18



module PokemonMetadata
  GlobalTypes = {
     "Home"             => [MetadataHome,"uuuu"],
     "WildBattleBGM"    => [MetadataWildBattleBGM,"s"],
     "TrainerBattleBGM" => [MetadataTrainerBattleBGM,"s"],
     "WildVictoryME"    => [MetadataWildVictoryME,"s"],
     "TrainerVictoryME" => [MetadataTrainerVictoryME,"s"],
     "SurfBGM"          => [MetadataSurfBGM,"s"],
     "BicycleBGM"       => [MetadataBicycleBGM,"s"],
     "PlayerA"          => [MetadataPlayerA,"esssssss",:PBTrainers],
     "PlayerB"          => [MetadataPlayerB,"esssssss",:PBTrainers],
     "PlayerC"          => [MetadataPlayerC,"esssssss",:PBTrainers],
     "PlayerD"          => [MetadataPlayerD,"esssssss",:PBTrainers],
     "PlayerE"          => [MetadataPlayerE,"esssssss",:PBTrainers],
     "PlayerF"          => [MetadataPlayerF,"esssssss",:PBTrainers],
     "PlayerG"          => [MetadataPlayerG,"esssssss",:PBTrainers],
     "PlayerH"          => [MetadataPlayerH,"esssssss",:PBTrainers],
     "PlayerI"          => [MetadataPlayerI,"esssssss",:PBTrainers],
     "PlayerJ"          => [MetadataPlayerJ,"esssssss",:PBTrainers],
     "PlayerK"          => [MetadataPlayerK,"esssssss",:PBTrainers],
     "PlayerL"          => [MetadataPlayerL,"esssssss",:PBTrainers],
     "PlayerM"          => [MetadataPlayerM,"esssssss",:PBTrainers],
     "PlayerN"          => [MetadataPlayerN,"esssssss",:PBTrainers],
     "PlayerO"          => [MetadataPlayerO,"esssssss",:PBTrainers],
     "PlayerP"          => [MetadataPlayerP,"esssssss",:PBTrainers],
     "PlayerQ"          => [MetadataPlayerQ,"esssssss",:PBTrainers],
     "PlayerR"          => [MetadataPlayerR,"esssssss",:PBTrainers],
     "PlayerS"          => [MetadataPlayerS,"esssssss",:PBTrainers],
     "PlayerT"          => [MetadataPlayerT,"esssssss",:PBTrainers],
     "PlayerU"          => [MetadataPlayerU,"esssssss",:PBTrainers],
     "PlayerV"          => [MetadataPlayerV,"esssssss",:PBTrainers],
     "PlayerW"          => [MetadataPlayerW,"esssssss",:PBTrainers],
     "PlayerX"          => [MetadataPlayerX,"esssssss",:PBTrainers],
     "PlayerY"          => [MetadataPlayerY,"esssssss",:PBTrainers]
  } 
  NonGlobalTypes = {
     "Outdoor"          => [MetadataOutdoor,"b"],
     "ShowArea"         => [MetadataShowArea,"b"],
     "Bicycle"          => [MetadataBicycle,"b"],
     "BicycleAlways"    => [MetadataBicycleAlways,"b"],
     "HealingSpot"      => [MetadataHealingSpot,"uuu"],
     "Weather"          => [MetadataWeather,"eu",["","Rain","Storm","Snow","Sandstorm","Sunny","HeavyRain","Blizzard"]],
     "MapPosition"      => [MetadataMapPosition,"uuu"],
     "DiveMap"          => [MetadataDiveMap,"u"],
     "DarkMap"          => [MetadataDarkMap,"b"],
     "SafariMap"        => [MetadataSafariMap,"b"],
     "SnapEdges"        => [MetadataSnapEdges,"b"],
     "Dungeon"          => [MetadataDungeon,"b"],
     "BattleBack"       => [MetadataBattleBack,"s"],
     "WildBattleBGM"    => [MetadataMapWildBattleBGM,"s"],
     "TrainerBattleBGM" => [MetadataMapTrainerBattleBGM,"s"],
     "WildVictoryME"    => [MetadataMapWildVictoryME,"s"],
     "TrainerVictoryME" => [MetadataMapTrainerVictoryME,"s"],
     "MapSize"          => [MetadataMapSize,"us"],
  }
end

def pbClearData
  if $PokemonTemp
    $PokemonTemp.pokemonDexData=nil
    $PokemonTemp.pokemonMetadata=nil
    $PokemonTemp.pokemonPhoneData=nil
  end
  MapFactoryHelper.clear
  if $game_map && $PokemonEncounters
    $PokemonEncounters.setup($game_map.map_id)
  end
  if pbRgssExists?("Data/tilesets.rxdata")
    $cache.RXtilesets=load_data("Data/tilesets.rxdata")
  end
end

def pbLoadMetadata
  $cache.metadata      = load_data("Data/metadata.dat") if !$cache.metadata
  return $cache.metadata
end

def pbGetMetadata(mapid,metadataType)
  meta=pbLoadMetadata
  return meta[mapid][metadataType] if meta[mapid]
  return nil
end

module MapFactoryHelper
  @@MapConnections=nil
  @@MapDims=nil

  def self.clear
    @@MapConnections=nil
    @@MapDims=nil
  end

  # Returns the X or Y coordinate of an edge on the map with id.
  # Considers the special strings "N","W","E","S"
  def self.getMapEdge(id,edge)
    return 0 if edge=="N" || edge=="W"
    dims=getMapDims(id) # Get dimensions
    return dims[0] if edge=="E"
    return dims[1] if edge=="S"
    return dims[0] # real dimension (use width)
  end

  # Gets the height and width of the map with id
  def self.getMapDims(id)
    # Create cache if doesn't exist
    if !@@MapDims
      @@MapDims=[]
    end
    # Add map to cache if can't be found
    if !@@MapDims[id]
      begin
        map = $cache.map_load(id)
        @@MapDims[id]=[map.width,map.height]
      rescue
        @@MapDims[id]=[0,0]
      end
    end
    # Return map in cache
    return @@MapDims[id]
  end

  def self.getMapConnections
    begin
      @@MapConnections=load_data("Data/mapcons.dat")
    rescue
      puts "Uh-oh"
    end
    if !@@MapConnections
      @@MapConnections=[]
      begin
        conns = $cache.map_conns
      rescue
        conns=[]
      end
      for i in 0...conns.length
        conn=conns[i]
        v=getMapEdge(conn[0],conn[1])
        dims=getMapDims(conn[0])
        next if dims[0]==0 || dims[1]==0
        if conn[1]=="N" || conn[1]=="S"
          conn[1]=conn[2]
          conn[2]=v
        elsif conn[1]=="E" || conn[1]=="W"
          conn[1]=v
        end
        v=getMapEdge(conn[3],conn[4])
        dims=getMapDims(conn[3])
        next if dims[0]==0 || dims[1]==0
        if conn[4]=="N" || conn[4]=="S"
          conn[4]=conn[5]
          conn[5]=v
        elsif conn[4]=="E" || conn[4]=="W"
          conn[4]=v
        end
        @@MapConnections.push(conn)
      end
    end
    return @@MapConnections
  end

  def self.hasConnections?(id)
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      return true if conn[0]==id || conn[3]==id
    end
    return false
  end

  def self.mapInRange?(map)
    dispx=map.display_x
    dispy=map.display_y
    return false if dispx>=map.width*Game_Map.realResX+768
    return false if dispy>=map.height*Game_Map.realResY+768
    return false if dispx<=-(Graphics.width*Game_Map::XSUBPIXEL+768)
    return false if dispy<=-(Graphics.height*Game_Map::YSUBPIXEL+768)
    return true
  end

  def self.mapInRangeById?(id,dispx,dispy)
    dims=MapFactoryHelper.getMapDims(id)
    return false if dispx>=dims[0]*Game_Map.realResX+768
    return false if dispy>=dims[1]*Game_Map.realResY+768
    return false if dispx<=-(Graphics.width*Game_Map::XSUBPIXEL+768)
    return false if dispy<=-(Graphics.height*Game_Map::XSUBPIXEL+768)
    return true
  end
end

class Game_Map
  def updateTileset
    tileset = $cache.RXtilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
  end
end

class PokemonMapFactory
  attr_reader :maps

  def initialize(id)
    @fixup=false
    @maps=[]
    @mapChanged=false # transient instance variable
    setup(id)
  end

  def map
    @mapIndex=0 if !@mapIndex || @mapIndex<0
    if !@maps[@mapIndex]
      if @maps.length==0
        raise "No maps in save file... (mapIndex=#{@mapIndex})"
      else
        for i in 0...@maps.length
          if @maps[i]
            echo("Using next map, may be incorrect (mapIndex=#{@mapIndex}, length=#{@maps.length})")
            return @maps[i]
          end
          raise "No maps in save file... (all maps empty; mapIndex=#{@mapIndex})"
        end
      end
    else
      return @maps[@mapIndex]
    end
  end

  # Clears all maps and sets up the current map with id.  This function also sets
  # the positions of neighboring maps and notifies the game system of a map change.
  def setup(id)
    @maps.clear
    @maps[0]=Game_Map.new
    @mapIndex=0
    oldID= !$game_map ? 0 : $game_map.map_id
    if oldID!=0 && oldID!=@maps[0]
      setMapChanging(id,@maps[0])
    end
    $game_map=@maps[0]
    @maps[0].setup(id)
    getNewMapConnections
    setMapsInRange
    setMapChanged(oldID)
  end

  def hasMap?(id)
    for map in @maps
      return true if map.map_id==id
    end
    return false
  end

  def getMapIndex(id)
    for i in 0...@maps.length
      return i if @maps[i].map_id==id
    end
    return -1
  end

  def setMapChanging(newID,newMap)
    Events.onMapChanging.trigger(self,newID,newMap)
  end

  def setMapChanged(prevMap)
    Events.onMapChange.trigger(self,prevMap)
    @mapChanged=true
  end

  def setSceneStarted(scene)
    Events.onMapSceneChange.trigger(self,scene,@mapChanged)
    @mapChanged=false
  end

  # Similar to Game_Player#passable?, but supports map connections
  def isPassableFromEdge?(x,y)
    return true if $game_map.valid?(x,y)
    newmap=getNewMap(x,y)
    return false if !newmap
    return isPassable?(newmap[0].map_id,newmap[1],newmap[2])
  end

  def isPassableStrict?(mapID,x,y,thisEvent=nil)
    thisEvent=$game_player if !thisEvent
    map=getMapNoAdd(mapID)
    return false if !map
    return false if !map.valid?(x,y)
    return true if thisEvent.through
    if thisEvent==$game_player
      return false unless ($DEBUG && Input.press?(Input::CTRL)) || 
         map.passableStrict?(x,y,0,thisEvent)
    else
      return false unless map.passableStrict?(x,y,0,thisEvent)
    end
    for event in map.events.values
      if event!=thisEvent && event.x == x && event.y == y
        return false if !event.through && (event.character_name!="")
      end
    end
    return true
  end

  def isPassable?(mapID,x,y,thisEvent=nil)
    thisEvent=$game_player if !thisEvent
    map=getMapNoAdd(mapID)
    return false if !map
    return false if !map.valid?(x,y)
    return true if thisEvent.through
    if thisEvent==$game_player
      return false unless ($DEBUG && Input.press?(Input::CTRL)) || 
         map.passable?(x,y,0,thisEvent)
    else
      return false unless map.passable?(x,y,0,thisEvent)
    end
    for event in map.events.values
      if event.x == x && event.y == y
        return false if !event.through && (event.character_name!="")
      end
    end
    if thisEvent.is_a?(Game_Player)
      if thisEvent.x == x && thisEvent.y == y
        return false if !thisEvent.through && thisEvent.character_name != ""
      end
    end
    return true
  end

  def getMap(id)
    for map in @maps
      if map.map_id==id
        return map
      end
    end
    map=Game_Map.new
    map.setup(id)
    @maps.push(map)
    return map
  end

  def getMapNoAdd(id)
    for map in @maps
      if map.map_id==id
        return map
      end
    end
    map=Game_Map.new
    map.setup(id)
    return map
  end

  def updateMaps(scene)
    updateMapsInternal()
    if @mapChanged
      $MapFactory.setSceneStarted(scene)
    end
  end

  def updateMapsInternal # :internal:
    return if $game_player.moving?
    getNewMapConnections if @RelevantMapConnections.nil?
    if !@RelevantMapConnections.length==0
      return if @maps.length==1
      for i in 0...@maps.length
        @maps[i]=nil if $game_map.map_id!=@maps[i].map_id
      end
      @maps.compact!
      @mapIndex=getMapIndex($game_map.map_id)
      return
    end
    setMapsInRange
    deleted=false
    for i in 0...@maps.length
      if !MapFactoryHelper.mapInRange?(@maps[i])
        @maps[i]=nil
        deleted=true 
      end
    end
    if deleted
      @maps.compact!
      @mapIndex=getMapIndex($game_map.map_id)
    end
  end

  def areConnected?(mapID1,mapID2)
    return true if mapID1==mapID2
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      if (conn[0]==mapID1 && conn[3]==mapID2) ||
         (conn[0]==mapID2 && conn[3]==mapID1)
        return true
      end
    end
    return false
  end

  def getNewMap(playerX,playerY)
    id=$game_map.map_id
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      next if conn[0]!=id && conn[3]!=id
      mapidB=nil
      newx=0
      newy=0
      if conn[0]==id
        mapidB=conn[3]
        mapB=MapFactoryHelper.getMapDims(conn[3])
        newx=(conn[4]-conn[1]) + playerX
        newy=(conn[5]-conn[2]) + playerY
      else
        mapidB=conn[0]
        mapB=MapFactoryHelper.getMapDims(conn[0])
        newx=(conn[1]-conn[4]) + playerX
        newy=(conn[2]-conn[5]) + playerY
      end
      if (newx>=0 && newx<mapB[0] && newy>=0 && newy<mapB[1])
        return [getMap(mapidB),newx,newy]
      end
    end
    return nil
  end

  def setCurrentMap
    return if $game_player.moving?
    return if $game_map.valid?($game_player.x,$game_player.y)
    newmap=getNewMap($game_player.x,$game_player.y)
    if newmap
      oldmap=$game_map.map_id
      if oldmap!=0 && oldmap!=newmap[0].map_id
        setMapChanging(newmap[0].map_id,newmap[0])
      end
      $game_map=newmap[0]
      @mapIndex=getMapIndex($game_map.map_id)
      getNewMapConnections                  ###experimental
      $game_player.moveto(newmap[1],newmap[2])
      $game_map.update
      pbAutoplayOnTransition
      $game_map.refresh
      setMapChanged(oldmap)
      $game_screen.setWeather
    end
  end

  def getTerrainTag(mapid,x,y)
    map=getMapNoAdd(mapid)
    return map.terrain_tag(x,y)
  end

  def getFacingTerrainTag(dir=nil,event=nil)
    tile=getFacingTile(dir,event)
    return 0 if !tile
    return getTerrainTag(tile[0],tile[1],tile[2])
  end

  def getRelativePos(thisMapID,thisX,thisY,otherMapID,otherX,otherY)
    if thisMapID==otherMapID
      # Both events share the same map
      return [otherX-thisX,otherY-thisY]
    end
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      if conn[0]==thisMapID && conn[1]==otherMapID
        posX=(thisX+conn[4]-conn[1])+otherX
        posY=(thisY+conn[5]-conn[2])+otherY
        return [posX,posY]
      elsif conn[1]==thisMapID && conn[0]==otherMapID
        posX=(thisX+conn[1]-conn[4])+otherX
        posY=(thisY+conn[2]-conn[5])+otherY
        return [posX,posY]
      end
    end
    return [0,0]
  end

  # Gets the distance from this event to another event.  Example: If this event's
  # coordinates are (2,5) and the other event's coordinates are (5,1), returns
  # the array (3,-4), because (5-2=3) and (1-5=-4).
  def getThisAndOtherEventRelativePos(thisEvent,otherEvent)
    return [0,0] if !thisEvent || !otherEvent
    return getRelativePos(
       thisEvent.map.map_id,thisEvent.x,thisEvent.y,
       otherEvent.map.map_id,otherEvent.x,otherEvent.y)
  end

  def getThisAndOtherPosRelativePos(thisEvent,otherMapID,otherX,otherY)
    return [0,0] if !thisEvent
    return getRelativePos(
       thisEvent.map.map_id,thisEvent.x,thisEvent.y,
       otherMapID,otherX,otherY)  
  end

  def getOffsetEventPos(event,xOffset,yOffset)
    event=$game_player if !event
    return nil if !event
    return getRealTilePos(event.map.map_id,event.x+xOffset,event.y+yOffset)
  end

  def getRealTilePos(mapID,x,y)
    id=mapID
    return [id,x,y] if getMapNoAdd(id).valid?(x,y)
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      if conn[0]==id
        newX=(x+conn[4]-conn[1])
        newY=(y+conn[5]-conn[2])
        next if newX<0 || newY<0
        dims=MapFactoryHelper.getMapDims(conn[3])
        next if newX>=dims[0] || newY>=dims[1]
        return [conn[3],newX,newY]
      elsif conn[3]==id
        newX=(x+conn[1]-conn[4])
        newY=(y+conn[2]-conn[5])
        next if newX<0 || newY<0
        dims=MapFactoryHelper.getMapDims(conn[0])
        next if newX>=dims[0] || newY>=dims[1]
        return [conn[0],newX,newY]
      end
    end
    return nil
  end

  def getFacingTileFromPos(mapID,x,y,direction=0,steps=1)
    id=mapID
    case direction
      when 1; y+=steps; x-=steps
      when 2; y+=steps
      when 3; y+=steps; x+=steps
      when 4; x-=steps
      when 6; x+=steps
      when 7; y-=steps; x-=steps
      when 8; y-=steps
      when 9; y-=steps; x+=steps
      else
        return [id,x,y]
    end
    return getRealTilePos(mapID,x,y)
  end

  def getFacingCoords(x,y,direction=0,steps=1)
    case direction
    when 1; y+=steps; x-=steps
    when 2; y+=steps
    when 3; y+=steps; x+=steps
    when 4; x-=steps
    when 6; x+=steps
    when 7; y-=steps; x-=steps
    when 8; y-=steps
    when 9; y-=steps; x+=steps
    end
    return [x,y]
  end

  def getFacingTile(direction=nil,event=nil,steps=1)
    event=$game_player if event==nil
    return [0,0,0] if !event
    x=event.x
    y=event.y
    id=event.map.map_id
    direction=event.direction if direction==nil
    return getFacingTileFromPos(id,x,y,direction,steps)
  end

  def getNewMapConnections
    @RelevantMapConnections = []
    id=$game_map.map_id
    conns=MapFactoryHelper.getMapConnections
    for conn in conns
      next if conn[0]!=id && conn[3]!=id
      @RelevantMapConnections.push(conn)
    end
    if @RelevantMapConnections.length ==0
      return false
    else
      return true
    end
  end

  def setMapsInRange
    return if @fixup
    getNewMapConnections if @RelevantMapConnections.nil?
    return if @RelevantMapConnections.length == 0
    @fixup=true
    id=$game_map.map_id
    for conn in @RelevantMapConnections
      if conn[0]==id
        mapA=getMap(conn[0])
        newdispx=(conn[4]-conn[1]) * Game_Map.realResX + mapA.display_x
        newdispy=(conn[5]-conn[2]) * Game_Map.realResY + mapA.display_y
        if hasMap?(conn[3]) || MapFactoryHelper.mapInRangeById?(conn[3],newdispx,newdispy)
          mapB=getMap(conn[3])
          mapB.display_x=newdispx if mapB.display_x!=newdispx
          mapB.display_y=newdispy if mapB.display_y!=newdispy
        end
      elsif conn[3]==id
        mapA=getMap(conn[3])
        newdispx=(conn[1]-conn[4]) * Game_Map.realResX + mapA.display_x
        newdispy=(conn[2]-conn[5]) * Game_Map.realResY + mapA.display_y
        if hasMap?(conn[0]) || MapFactoryHelper.mapInRangeById?(conn[0],newdispx,newdispy)
          mapB=getMap(conn[0])
          mapB.display_x=newdispx if mapB.display_x!=newdispx
          mapB.display_y=newdispy if mapB.display_y!=newdispy
        end
      end
    end
    @fixup=false
  end
end