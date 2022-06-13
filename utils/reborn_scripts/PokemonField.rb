################################################################################
# Interpolators
################################################################################
class RectInterpolator
  def initialize(oldrect,newrect,frames)
    restart(oldrect,newrect,frames)
  end

  def restart(oldrect,newrect,frames)
    @oldrect=oldrect
    @newrect=newrect
    @frames=[frames,1].max
    @curframe=0
    @rect=oldrect.clone
  end

  def set(rect)
    rect.set(@rect.x,@rect.y,@rect.width,@rect.height)
  end

  def done?
    @curframe>@frames
  end

  def update
    return if done?
    t=(@curframe*1.0/@frames)
    x1=@oldrect.x
    x2=@newrect.x
    x=x1+t*(x2-x1)
    y1=@oldrect.y
    y2=@newrect.y
    y=y1+t*(y2-y1)
    rx1=@oldrect.x+@oldrect.width
    rx2=@newrect.x+@newrect.width
    rx=rx1+t*(rx2-rx1)
    ry1=@oldrect.y+@oldrect.height
    ry2=@newrect.y+@newrect.height
    ry=ry1+t*(ry2-ry1)
    minx=x<rx ? x : rx
    maxx=x>rx ? x : rx
    miny=y<ry ? y : ry
    maxy=y>ry ? y : ry
    @rect.set(minx,miny,maxx-minx,maxy-miny)
    @curframe+=1
  end
end



class PointInterpolator
  def initialize(oldx,oldy,newx,newy,frames)
    restart(oldx,oldy,newx,newy,frames)
  end

  def restart(oldx,oldy,newx,newy,frames)
    @oldx=oldx
    @oldy=oldy
    @newx=newx
    @newy=newy
    @frames=frames
    @curframe=0
    @x=oldx
    @y=oldy
  end

  def x; @x;end
  def y; @y;end

  def done?
    @curframe>@frames
  end

  def update
    return if done?
    t=(@curframe*1.0/@frames)
    rx1=@oldx
    rx2=@newx
    @x=rx1+t*(rx2-rx1)
    ry1=@oldy
    ry2=@newy
    @y=ry1+t*(ry2-ry1)
    @curframe+=1
  end
end



################################################################################
# Visibility circle in dark maps
################################################################################
class DarknessSprite < SpriteWrapper
  attr_reader :radius

  def initialize(viewport=nil)
    super(viewport)
    @darkness=BitmapWrapper.new(Graphics.width,Graphics.height)
    @radius=80
    self.bitmap=@darkness
    self.z=99997
    refresh
  end

  def dispose
    @darkness.dispose
    super
  end

  def radius=(value)
    @radius=value
    refresh
  end

  def refresh
    @darkness.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0,255))
    cx=Graphics.width/2
    cy=Graphics.height/2
    cradius=@radius
    numfades=5
    for i in 1..numfades
      for j in cx-cradius..cx+cradius
        diff2 = (cradius * cradius) - ((j - cx) * (j - cx))
        diff = Math.sqrt(diff2)
        @darkness.fill_rect(j,cy-diff,1,diff*2,
           Color.new(0, 0, 0, 255.0*(numfades-i)/numfades ))
      end
     cradius=(cradius*0.9).floor
    end
  end
end



################################################################################
# Location signpost
################################################################################
class LocationWindow
  def initialize(name)
    @window=Window_AdvancedTextPokemon.new(name)
    @window.resizeToFit(name,Graphics.width)
    @window.setXYZ(0,-@window.height,99999)
    @currentmap=$game_map.map_id
    @frames=0
  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    if $game_temp.message_window_showing ||
       @currentmap!=$game_map.map_id
      @window.dispose
      return
    end
    if @frames>80
      @window.y-=4
      @window.dispose if @window.y+@window.height<0
    else
      @window.y+=4 if @window.y<0
      @frames+=1
    end
  end
end



################################################################################
# Lights
################################################################################
class LightEffect
  def initialize(event,viewport=nil,map=nil,filename=nil)
    @light = IconSprite.new(0,0,viewport)
    if filename!=nil && filename!="" && pbResolveBitmap("Graphics/Pictures/"+filename)
      @light.setBitmap("Graphics/Pictures/"+filename)
    else
      @light.setBitmap("Graphics/Pictures/LE")
    end
    @light.z = 1000
    @event = event
    @map=map ? map : $game_map
    @disposed=false
  end

  def disposed?
    return @disposed
  end

  def dispose
    @light.dispose
    @map=nil
    @event=nil
    @disposed=true
  end

  def update
    @light.update
  end
end



class LightEffect_Lamp < LightEffect
  def initialize(event,viewport=nil,map=nil)
    @light = Sprite.new(viewport)
    lamp = AnimatedBitmap.new("Graphics/Pictures/LE")
    @light.bitmap = Bitmap.new(128,64)
    src_rect = Rect.new(0, 0, 64, 64) 
    @light.bitmap.blt(0, 0, lamp.bitmap, src_rect) 
    @light.bitmap.blt(20, 0, lamp.bitmap, src_rect) 
    lamp.dispose
    @light.visible = true
    @light.z = 1000
    @map=map ? map : $game_map
    @event = event
  end
end

def passable?(passages,tile_id)
  return false if tile_id == nil
  return false if passages[tile_id] == nil
  return (passages[tile_id]<15) 
end

module ScreenPosHelper
  def self.pbScreenZoomX(ch)
    zoom=1.0
    return Game_Map::TILEWIDTH/32.0
  end

  def self.pbScreenZoomY(ch)
    return Game_Map::TILEHEIGHT/32.0
  end

  def self.pbScreenX(ch)
    return ch.screen_x
  end

  def self.pbScreenY(ch)
    return ch.screen_y
  end

  @heightcache={}

  def self.bmHeight(bm)
    h=@heightcache[bm]
    if !h
      bmap=AnimatedBitmap.new("Graphics/Characters/"+bm,0)
      h=bmap.height
      @heightcache[bm]=h
      bmap.dispose
    end
    return h
  end

  def self.pbScreenZ(ch,height=nil)
    if height==nil
      height=0
      if ch.tile_id > 0
        height=32
      elsif ch.character_name!=""
        height=bmHeight(ch.character_name)/4
      end
    end
    return ch.screen_z(height)
  end
end

class LightEffect_Basic < LightEffect
  def initialize(event,viewport=nil,map=nil,filename=nil)
    super
  end

  def update
    return if !@light || !@event
    super
    @light.opacity = 100
    @light.ox=32
    @light.oy=48
    if (Object.const_defined?(:ScreenPosHelper) rescue false)
      @light.x = ScreenPosHelper.pbScreenX(@event)
      @light.y = ScreenPosHelper.pbScreenY(@event)
      @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
    else
      @light.x = @event.screen_x
      @light.y = @event.screen_y
      @light.zoom_x = 1.0
    end
    @light.zoom_y = @light.zoom_x
    @light.tone=$game_screen.tone
  end
end



class LightEffect_DayNight < LightEffect
  def initialize(event,viewport=nil,map=nil,filename=nil)
    super
  end

  def update
    return if !@light || !@event
    super
    shade=PBDayNight.getShade
    if shade>=144   # If light enough, call it fully day.
      shade=255
    elsif shade<=64   # If dark enough, call it fully night.
      shade=0
    else
      shade=255-(255*(144-shade)/(144-64))
    end
    @light.opacity = 255-shade
    if @light.opacity>0
      @light.ox=32
      @light.oy=48
      if (Object.const_defined?(:ScreenPosHelper) rescue false)
        @light.x = ScreenPosHelper.pbScreenX(@event)
        @light.y = ScreenPosHelper.pbScreenY(@event)
        @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
        @light.zoom_y = ScreenPosHelper.pbScreenZoomY(@event)
      else
        @light.x = @event.screen_x
        @light.y = @event.screen_y
        @light.zoom_x = 1.0
        @light.zoom_y = 1.0
      end
      @light.tone.set($game_screen.tone.red, $game_screen.tone.green, $game_screen.tone.blue, $game_screen.tone.gray)
    end
  end  
end



################################################################################
# This module stores encounter-modifying events that can happen during the game.
# A procedure can subscribe to an event by adding itself to the event.  It will
# then be called whenever the event occurs.
################################################################################
module EncounterModifier
  @@procs=[]
  @@procsEnd=[]

  def self.register(p)
    @@procs.push(p)
  end

  def self.registerEncounterEnd(p)
    @@procsEnd.push(p)
  end

  def self.trigger(encounter)
    for prc in @@procs
      encounter=prc.call(encounter)
    end
    return encounter
  end

  def self.triggerEncounterEnd()
    for prc in @@procsEnd
      prc.call()
    end
  end
end



################################################################################
# This module stores events that can happen during the game.  A procedure can
# subscribe to an event by adding itself to the event.  It will then be called
# whenever the event occurs.
################################################################################
module Events
  @@OnMapChange=Event.new
  @@OnMapSceneChange=Event.new
  @@OnMapUpdate=Event.new
  @@OnMapChanging=Event.new
  @@OnLeaveTile=Event.new
  @@OnStepTaken=Event.new
  @@OnStepTakenTransferPossible=Event.new
  @@OnStepTakenFieldMovement=Event.new
  @@OnWildBattleOverride=Event.new
  @@OnWildBattleEnd=Event.new
  @@OnWildPokemonCreate=Event.new
  @@OnTrainerPartyLoad=Event.new
  @@OnSpritesetCreate=Event.new
  @@OnStartBattle=Event.new
  @@OnEndBattle=Event.new
  @@OnMapCreate=Event.new
  @@OnAction=Event.new

# Triggers when the player presses the Action button on the map.
  def self.onAction=(v)
    @@OnAction=v
  end

  def self.onAction
    @@OnAction
  end

  def self.onStartBattle=(v)
    @@OnStartBattle=v
  end

  def self.onStartBattle
    @@OnStartBattle
  end

  def self.onEndBattle=(v)
    @@OnEndBattle=v
  end

  def self.onEndBattle
    @@OnEndBattle
  end

# Fires whenever a map is created. Event handler receives two parameters: the
# map (RPG::Map) and the tileset (RPG::Tileset)
  def self.onMapCreate=(v)
    @@OnMapCreate=v
  end

  def self.onMapCreate
    @@OnMapCreate
  end

# Fires whenever the player moves to a new map. Event handler receives the old
# map ID or 0 if none.  Also fires when the first map of the game is loaded
  def self.onMapChange=(v)
    @@OnMapChange=v
  end

  def self.onMapChange
    @@OnMapChange
  end

# Fires whenever one map is about to change to a different one. Event handler
# receives the new map ID and the Game_Map object representing the new map.
# When the event handler is called, $game_map still refers to the old map.
  def self.onMapChanging=(v)
    @@OnMapChanging=v
  end

  def self.onMapChanging
    @@OnMapChanging
  end

# Fires whenever the player takes a step.
  def self.onStepTaken=(v)
    @@OnStepTaken=v
  end

  def self.onStepTaken
    @@OnStepTaken
  end

# Fires whenever the player or another event leaves a tile.
# Parameters:
# e[0] - Event that just left the tile.
# e[1] - Map ID where the tile is located (not necessarily
#  the current map). Use "$MapFactory.getMap(e[1])" to
#  get the Game_Map object corresponding to that map.
# e[2] - X-coordinate of the tile
# e[3] - Y-coordinate of the tile
  def self.onLeaveTile=(v)
    @@OnLeaveTile=v
  end

  def self.onLeaveTile
    @@OnLeaveTile
  end

# Fires whenever the player or another event enters a tile.
# Parameters:
# e[0] - Event that just entered a tile.
  def self.onStepTakenFieldMovement=(v)
    @@OnStepTakenFieldMovement=v
  end

  def self.onStepTakenFieldMovement
    @@OnStepTakenFieldMovement
  end

# Fires whenever the player takes a step. The event handler may possibly move
# the player elsewhere.
# Parameters:
# e[0] = Array that contains a single boolean value.
#  If an event handler moves the player to a new map, it should set this value
# to true. Other event handlers should check this parameter's value.
  def self.onStepTakenTransferPossible=(v)
    @@OnStepTakenTransferPossible=v
  end

  def self.onStepTakenTransferPossible
    @@OnStepTakenTransferPossible
  end

# Fires each frame during a map update.
  def self.onMapUpdate=(v)
    @@OnMapUpdate=v
  end

  def self.onMapUpdate
    @@OnMapUpdate
  end

# Triggers at the start of a wild battle.  Event handlers can provide their own
# wild battle routines to override the default behavior.
  def self.onWildBattleOverride=(v)
    @@OnWildBattleOverride=v
  end

  def self.onWildBattleOverride
    @@OnWildBattleOverride
  end

# Triggers whenever a wild Pokémon battle ends
# Parameters: 
# e[0] - Pokémon species
# e[1] - Pokémon level
# e[2] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
  def self.onWildBattleEnd=(v)
    @@OnWildBattleEnd=v
  end

  def self.onWildBattleEnd
    @@OnWildBattleEnd
  end

# Triggers whenever a wild Pokémon is created
# Parameters: 
# e[0] - Pokémon being created
  def self.onWildPokemonCreate=(v)
    @@OnWildPokemonCreate=v
  end

  def self.onWildPokemonCreate
    @@OnWildPokemonCreate
  end

# Triggers whenever an NPC trainer's Pokémon party is loaded
# Parameters: 
# e[0] - Trainer
# e[1] - Items possessed by the trainer
# e[2] - Party
  def self.onTrainerPartyLoad=(v)
    @@OnTrainerPartyLoad=v
  end

  def self.onTrainerPartyLoad
    @@OnTrainerPartyLoad
  end

# Fires whenever the map scene is regenerated and soon after the player moves
# to a new map.
# Parameters:
# e[0] = Scene_Map object.
# e[1] = Whether the player just moved to a new map (either true or false).  If
#   false, some other code had called $scene.createSpritesets to regenerate the
#   map scene without transferring the player elsewhere
  def self.onMapSceneChange=(v)
    @@OnMapSceneChange=v
  end

  def self.onMapSceneChange
    @@OnMapSceneChange
  end

# Fires whenever a spriteset is created.
# Parameters:
# e[0] = Spriteset being created
# e[1] = Viewport used for tilemap and characters
# e[0].map = Map associated with the spriteset (not necessarily the current map).
  def self.onSpritesetCreate=(v)
    @@OnSpritesetCreate=v
  end

  def self.onSpritesetCreate
    @@OnSpritesetCreate
  end
end



################################################################################
# Terrain tags
################################################################################
class PBTerrain
  Ledge           = 1
  Grass           = 2
  Sand            = 3
  Rock            = 4
  DeepWater       = 5
  StillWater      = 6
  Water           = 7
  Waterfall       = 8
  WaterfallCrest  = 9
  TallGrass       = 10
  UnderwaterGrass = 11
  Ice             = 12
  Neutral         = 13
  SootGrass       = 14
  Bridge          = 15
  Puddle          = 16
  Grime           = 17
  PokePuddle      = 18
  Dummy           = 19  
  DownConveyor    = 20
  LeftConveyor    = 21
  RightConveyor   = 22
  UpConveyor      = 23  
  SandDune        = 24
end 

def pbIsSurfableTag?(tag)
  return pbIsWaterTag?(tag)
end

def pbIsWaterTag?(tag)
  return tag==PBTerrain::DeepWater ||
         tag==PBTerrain::Water ||
         tag==PBTerrain::StillWater ||
         tag==PBTerrain::WaterfallCrest ||
         tag==PBTerrain::Waterfall
end

def pbIsGrimeTag?(tag)
  return tag==PBTerrain::Grime
end


def pbIsPassableWaterTag?(tag) 
  return tag==PBTerrain::DeepWater ||
         tag==PBTerrain::Water ||
         tag==PBTerrain::StillWater ||
         tag==PBTerrain::WaterfallCrest
end

def pbIsJustWaterTag?(tag)
  return tag==PBTerrain::DeepWater ||
         tag==PBTerrain::Water ||
         tag==PBTerrain::StillWater
end

def pbIsGrassTag?(tag)
  return tag==PBTerrain::Grass ||
         tag==PBTerrain::TallGrass ||
         tag==PBTerrain::UnderwaterGrass ||
         tag==PBTerrain::PokePuddle
end

def pbIsJustGrassTag?(tag)
  return tag==PBTerrain::Grass
end

################################################################################
# Battles
################################################################################
class Game_Temp
  attr_accessor :background_bitmap
end

def pbNewBattleScene
  return PokeBattle_Scene.new
end

def pbSceneStandby
  if $scene && $scene.is_a?(Scene_Map)
    $scene.disposeSpritesets
  end
  GC.start
  RPG::Cache.clear
  Graphics.frame_reset
  yield
  if $scene && $scene.is_a?(Scene_Map)
    $scene.createSpritesets
  end
end

def pbBattleAnimation(bgm=nil,trainerid=-1,trainername="",switch_sprites=false)
  handled=false
  playingBGS=nil
  playingBGM=nil
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS=$game_system.getPlayingBGS
    playingBGM=$game_system.getPlayingBGM
    playingBGMposition = Audio.bgm_pos if playingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  pbMEFade(0.25)
  pbWait(10)
  pbMEStop
  if bgm
    pbBGMPlay(bgm)
  else
    pbBGMPlay(pbGetWildBattleBGM(0))
  end
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  # Fade to gray a few times.
  if $idk[:settings].photosensitive != 1
    viewport.color=Color.new(17*8,17*8,17*8)
    3.times do
      viewport.color.alpha=0
      6.times do
        viewport.color.alpha+=30
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
      6.times do
        viewport.color.alpha-=30
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
  end
  ################################################################################
  # VS. animation, by Luka S.J.
  # Tweaked by Maruno.
  # Tweaked by Perry to allow for doubles!
  ###############################################################################
  if trainerid.is_a?(Array) || trainerid>=0
    if trainerid.is_a?(Array)
      tbargraphic=sprintf("Graphics/Transitions/vsBar%d",trainerid[0])
      tbargraphic2=sprintf("Graphics/Transitions/vsBar%d",trainerid[1])
      tgraphic=sprintf("Graphics/Transitions/vsTrainer%d",trainerid[0])
      tgraphic2=sprintf("Graphics/Transitions/vsTrainer%d",trainerid[1])
    else
      tbargraphic=sprintf("Graphics/Transitions/vsBar%d",trainerid)
      tgraphic=sprintf("Graphics/Transitions/vsTrainer%d",trainerid)
    end
    if $PokemonGlobal.partner
      partnergraphic = sprintf("Graphics/Transitions/vsTrainer%d",$PokemonGlobal.partner[0])
    end
    if (trainerid.is_a?(Array) && ((pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic)) ||
      (pbResolveBitmap(tbargraphic2) && pbResolveBitmap(tgraphic2)))) || pbResolveBitmap(tbargraphic) && pbResolveBitmap(tgraphic)
      outfit=$Trainer ? $Trainer.outfit : 0
      # Set up
      viewplayer=Viewport.new(0,Graphics.height/3,Graphics.width/2,128)
      viewplayer.z=viewport.z
      viewopp=Viewport.new(Graphics.width/2,Graphics.height/3,Graphics.width/2,128)
      viewopp.z=viewport.z
      viewvs=Viewport.new(0,0,Graphics.width,Graphics.height)
      viewvs.z=viewport.z
      xoffset=(Graphics.width/2)/10
      xoffset=xoffset.round
      xoffset=xoffset*10

      fade=Sprite.new(viewport)
      fade.bitmap  = RPG::Cache.transition("Graphics/Transitions/vsFlash")
      fade.tone=Tone.new(-255,-255,-255)
      fade.opacity=100
      overlay=Sprite.new(viewport)
      overlay.bitmap=Bitmap.new(Graphics.width,Graphics.height)
      pbSetSystemFont(overlay.bitmap)

      bar1=Sprite.new(viewplayer)
      pbargraphic=sprintf("Graphics/Transitions/vsBar%d_%d",$Trainer.trainertype,outfit)
      pbargraphic=sprintf("Graphics/Transitions/vsBar%d",$Trainer.trainertype) if !pbResolveBitmap(pbargraphic)
      bar1.bitmap = RPG::Cache.transition(pbargraphic)
      bar1.x=-xoffset
      bar2=Sprite.new(viewopp)
      if trainerid.is_a?(Array) && !pbResolveBitmap(tgraphic)
        bar2.bitmap = RPG::Cache.transition(tbargraphic2)
      else
        bar2.bitmap = RPG::Cache.transition(tbargraphic)
      end
      bar2.x=xoffset

      vs=Sprite.new(viewvs)
      vs.bitmap  = RPG::Cache.transition("Graphics/Transitions/vs")
      vs.ox=vs.bitmap.width/2
      vs.oy=vs.bitmap.height/2
      vs.x=Graphics.width/2
      vs.y=Graphics.height/1.5
      vs.visible=false
      flash=Sprite.new(viewvs)
      flash.bitmap  = RPG::Cache.transition("Graphics/Transitions/vsFlash")
      flash.opacity=0

      # Animation
      10.times do
        bar1.x+=xoffset/10
        bar2.x-=xoffset/10
        pbWait(1)
      end
      pbSEPlay("Flash2")
      pbSEPlay("Sword2")
      flash.opacity=255 if $idk[:settings].photosensitive != 1
      bar1.dispose
      bar2.dispose

      bar1=AnimatedPlane.new(viewplayer)
      bar1.bitmap = RPG::Cache.transition(pbargraphic)
      player=Sprite.new(viewplayer)
      pgraphic=sprintf("Graphics/Transitions/vsTrainer%d_%d",$Trainer.trainertype,outfit)
      pgraphic=sprintf("Graphics/Transitions/vsTrainer%d",$Trainer.trainertype) if !pbResolveBitmap(pgraphic)
      player.bitmap=RPG::Cache.transition(pgraphic)
      player.x=-xoffset
      partner = nil
      if $PokemonGlobal.partner && pbResolveBitmap(partnergraphic)
        partner = Sprite.new(viewplayer) if pbResolveBitmap(partnergraphic)
        partner.bitmap=RPG::Cache.transition(partnergraphic)
        partner.x=-xoffset + partner.width/30
        player.x-= partner.width/4.5
        partner.mirror = true 
      end
      bar2=AnimatedPlane.new(viewopp)
      if trainerid.is_a?(Array) && !pbResolveBitmap(tgraphic)
        bar2.bitmap = RPG::Cache.transition(tbargraphic2)
      else
        bar2.bitmap = RPG::Cache.transition(tbargraphic)
      end
      trainer=BitmapSprite.new(Graphics.width, Graphics.height, viewopp)
      if trainerid.is_a?(Array) && pbResolveBitmap(tgraphic) && pbResolveBitmap(tgraphic2) # both trainers have sprite
        trainer1bitmap = RPG::Cache.transition(tgraphic)
        trainer2bitmap = RPG::Cache.transition(tgraphic2)
        if !switch_sprites
          trainer.bitmap.blt(-trainer1bitmap.width/6,0,trainer1bitmap,Rect.new(0,0,trainer1bitmap.width,trainer1bitmap.height))
          trainer.bitmap.blt(trainer2bitmap.width/4,0,trainer2bitmap,Rect.new(0,0,trainer2bitmap.width,trainer2bitmap.height))
        else
          trainer.bitmap.blt(-trainer2bitmap.width/4,0,trainer2bitmap,Rect.new(0,0,trainer2bitmap.width,trainer2bitmap.height))
          trainer.bitmap.blt(trainer1bitmap.width/4,0,trainer1bitmap,Rect.new(0,0,trainer1bitmap.width,trainer1bitmap.height))
        end
      elsif trainerid.is_a?(Array) && pbResolveBitmap(tgraphic2) # only second one has sprite
        trainer2bitmap = RPG::Cache.transition(tgraphic2)
        trainer.bitmap.blt(0,0,trainer2bitmap,Rect.new(0,0,trainer2bitmap.width,trainer2bitmap.height))
      else
        trainer1bitmap = RPG::Cache.transition(tgraphic)
        trainer.bitmap.blt(0,0,trainer1bitmap,Rect.new(0,0,trainer1bitmap.width,trainer1bitmap.height))
      end
      trainer.x=xoffset
      trainer.tone=Tone.new(-255,-255,-255)
      trainer.visible=false
      partner.visible=false if partner
      
      25.times do
        flash.opacity-=51 if flash.opacity>0
        bar1.ox-=16
        bar2.ox+=16
        pbWait(1)
      end
      trainer.visible=true
      partner.visible=true if partner
      11.times do
        bar1.ox-=16
        bar2.ox+=16
        player.x+=xoffset/10
        partner.x+=xoffset/10 if partner
        trainer.x-=xoffset/10
        pbWait(1)
      end
      2.times do
        bar1.ox-=16
        bar2.ox+=16
        player.x-=xoffset/20
        partner.x+=xoffset/20 if partner
        trainer.x+=xoffset/20
        pbWait(1)
      end
      10.times do
        bar1.ox-=16
        bar2.ox+=16
        pbWait(1)
      end
      val=2
      flash.opacity=255 if $idk[:settings].photosensitive != 1
      vs.visible=true
      trainer.tone=Tone.new(0,0,0)
      #Opponents name
      if trainerid.is_a?(Array) && pbResolveBitmap(tgraphic) && pbResolveBitmap(tgraphic2)
        trainername = _INTL("{1} & {2}",trainername[0],trainername[1])
      elsif trainerid.is_a?(Array) && pbResolveBitmap(tgraphic)
        trainername = _INTL("{1}",trainername[0])
      elsif trainerid.is_a?(Array) && pbResolveBitmap(tgraphic2)
        trainername =  _INTL("{1}",trainername[1])
      end
      trainername2 = ""
      if trainername.length > 16
        splits = trainername.split(/ /,trainername[0,16].split(/ /).length)
        trainername2 = splits.delete_at(-1)
        trainername = splits.join(" ")
      end

      #player name
      playername = $Trainer.name
      if $PokemonGlobal.partner && pbResolveBitmap(partnergraphic)
        playername =  _INTL("{1} & {2}",$Trainer.name,$PokemonGlobal.partner[1])
      end
      playername2 = ""
      if playername.length > 16
        splits = playername.split(/ /,playername[0,16].split(/ /).length)
        playername2 = splits.delete_at(-1)
        playername = splits.join(" ")
      end
      #placing names
      textpos=[
        [_INTL("{1}",playername) ,   Graphics.width/4  - 16,(Graphics.height/1.5)+10,2, Color.new(248,248,248),Color.new(12*6,12*6,12*6)],
        [_INTL("{1}",trainername),(3*Graphics.width/4) + 16,(Graphics.height/1.5)+10,2, Color.new(248,248,248),Color.new(12*6,12*6,12*6)]
      ]
      textpos.push( [_INTL("{1}",trainername2),(3*Graphics.width/4) + 16,(Graphics.height/1.5)+42,2, Color.new(248,248,248),Color.new(12*6,12*6,12*6)]) if trainername2 != ""
      textpos.push( [_INTL("{1}",playername2),    Graphics.width/4  - 16,(Graphics.height/1.5)+42,2, Color.new(248,248,248),Color.new(12*6,12*6,12*6)]) if playername2 != ""
      pbDrawTextPositions(overlay.bitmap,textpos)

      pbSEPlay("Sword2")
      70.times do
        bar1.ox-=16
        bar2.ox+=16
        flash.opacity-=25.5 if flash.opacity>0
        vs.x+=val
        vs.y-=val
        val=2 if vs.x<=(Graphics.width/2)-2
        val=-2 if vs.x>=(Graphics.width/2)+2
        pbWait(1)
      end
      30.times do
        bar1.ox-=16
        bar2.ox+=16
        vs.zoom_x+=0.2
        vs.zoom_y+=0.2
        pbWait(1)
      end
      flash.tone=Tone.new(-255,-255,-255)
      10.times do
        bar1.ox-=16
        bar2.ox+=16
        flash.opacity+=25.5
        pbWait(1)
      end
      # End
      player.dispose
      partner.dispose if partner
      trainer.dispose
      flash.dispose
      vs.dispose
      bar1.dispose
      bar2.dispose
      overlay.dispose
      fade.dispose
      viewvs.dispose
      viewopp.dispose
      viewplayer.dispose
      viewport.color=Color.new(0,0,0,255)
      handled=true
    end
  end
  # End of VS. sequence script
  if !handled
    if Sprite.method_defined?(:wave_amp) && rand(15)==0
      viewport.color=Color.new(0,0,0,255)
      sprite = Sprite.new
      bitmap=Graphics.snap_to_bitmap
      bm=bitmap.clone
      sprite.z=99999
      sprite.bitmap = bm
      sprite.wave_speed=500
      for i in 0..25
        sprite.opacity-=10
        sprite.wave_amp+=60
        sprite.update
        sprite.wave_speed+=30
        2.times do
          Graphics.update
        end
      end
      bitmap.dispose
      bm.dispose
      sprite.dispose
    elsif Bitmap.method_defined?(:radial_blur) && rand(15)==0
      viewport.color=Color.new(0,0,0,255)
      sprite = Sprite.new
      bitmap=Graphics.snap_to_bitmap
      bm=bitmap.clone
      sprite.z=99999
      sprite.bitmap = bm
      for i in 0..15
        bm.radial_blur(i,2)
        sprite.opacity-=15
        2.times do
          Graphics.update
        end
      end
      bitmap.dispose
      bm.dispose
      sprite.dispose
    else
      transitions=["021-Normal01","022-Normal02",
         "Battle","battle1","battle2","battle3","battle4",
         "computertr","computertrclose",
         "hexatr","hexatrc","hexatzr",
      ]

      rnd=rand(transitions.length)
      Graphics.freeze
      viewport.color=Color.new(0,0,0,255)
      Graphics.transition(40,sprintf("Graphics/Transitions/%s",transitions[rnd]))
    end
    5.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  pbPushFade
  yield if block_given?
  pbPopFade
  if $game_system && $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM, playingBGMposition)
    $game_system.bgs_resume(playingBGS)
  end
  $PokemonGlobal.nextBattleBGM=nil
  $PokemonGlobal.nextBattleME=nil
  $PokemonGlobal.nextBattleBack=nil
  $PokemonEncounters.clearStepCount
  for j in 0..17
    viewport.color=Color.new(0,0,0,(17-j)*15)
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
  viewport.dispose
end

def pbPrepareBattle(battle)
  case $game_screen.weather_type
  when 1, 2, 7
    battle.weather=PBWeather::RAINDANCE
    battle.weatherduration=-1
  when 3, 8
    battle.weather=PBWeather::HAIL
    battle.weatherduration=-1
  when 4
    battle.weather=PBWeather::SANDSTORM
    battle.weatherduration=-1
  when 5
    battle.weather=PBWeather::SUNNYDAY
    battle.weatherduration=-1
  when 6
    battle.weather=PBWeather::STRONGWINDS
    battle.weatherduration=-1
  end
  battle.shiftStyle=($idk[:settings].battlestyle==0)
  battle.battlescene=($idk[:settings].battlescene==0 && $idk[:settings].photosensitive==0)
  battle.environment=pbGetEnvironment
end

def pbGetEnvironment
  return PBEnvironment::None if !$game_map
  if $PokemonGlobal && $PokemonGlobal.diving
    return PBEnvironment::Underwater
  elsif $PokemonEncounters && $PokemonEncounters.isCave?
    return PBEnvironment::Cave
  elsif !pbGetMetadata($game_map.map_id,MetadataOutdoor)
    return PBEnvironment::None
  else
    terrain=$game_player.terrain_tag
    if terrain==PBTerrain::Grass # Normal grass
      return PBEnvironment::Grass
    elsif terrain==PBTerrain::TallGrass # Tall grass
      return PBEnvironment::TallGrass
    elsif terrain==PBTerrain::DeepWater || terrain==PBTerrain::Water
      return PBEnvironment::MovingWater
    elsif terrain==PBTerrain::StillWater
      return PBEnvironment::StillWater
    elsif terrain==PBTerrain::Rock
      return PBEnvironment::Rock
    elsif terrain==PBTerrain::Sand
      return PBEnvironment::Sand
    end
    return PBEnvironment::None
  end
end

def pbGenerateWildPokemon(species,level)
  genwildpoke=PokeBattle_Pokemon.new(species,level,$Trainer)
  items=genwildpoke.wildHoldItems
  chances=[50,5,1]
  chances=[60,20,5] if !$Trainer.party[0].isEgg? &&
     ($Trainer.party[0].ability == PBAbilities::COMPOUNDEYES)
  itemrnd=rand(100)
  if itemrnd<chances[0] || (items[0]==items[1] && items[1]==items[2])
    genwildpoke.setItem(items[0])
  elsif itemrnd<(chances[0]+chances[1])
    genwildpoke.setItem(items[1])
  elsif itemrnd<(chances[0]+chances[1]+chances[2])
    genwildpoke.setItem(items[2])
  end
  if hasConst?(PBItems,:SHINYCHARM) && $PokemonBag.pbQuantity(PBItems::SHINYCHARM)>0
    for i in 0...2   # 3 times as likely
      break if genwildpoke.isShiny?
      genwildpoke.personalID=rand(65536)|(rand(65536)<<16)
    end
  end
  if rand(65536)<POKERUSCHANCE
    genwildpoke.givePokerus
  end
  Events.onWildPokemonCreate.trigger(nil,genwildpoke)
  return genwildpoke
end

def pbWildBattle(species,level,variable=nil,canescape=true,canlose=false)
  $game_switches[:In_Battle] = true
  if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
    if $Trainer.pokemonCount>0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable,1)
    $PokemonGlobal.nextBattleBGM=nil
    $PokemonGlobal.nextBattleME=nil
    $PokemonGlobal.nextBattleBack=nil
    $game_switches[:In_Battle] = false
    return true
  end
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  handled=[nil]
  Events.onWildBattleOverride.trigger(nil,species,level,handled)
  if handled[0]!=nil
    $game_switches[:In_Battle] = false
    return handled[0]
  end
  currentlevels=[]
  for i in $Trainer.party
    currentlevels.push([i.personalID,i.level])
  end
  genwildpoke=pbGenerateWildPokemon(species,level)
  Events.onStartBattle.trigger(nil,genwildpoke)
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke],$Trainer,nil)
  battle.internalbattle=true
  battle.cantescape=!canescape
  pbPrepareBattle(battle)
  decision=0
  pbBattleAnimation(pbGetWildBattleBGM(species)) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }    
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
        i.heal
      end
     end
     if decision==2 || decision==5 # if loss or draw
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  pbSet(variable,decision)
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  $game_switches[:In_Battle] = false
  return (decision!=2)
end

def pbDoubleWildBattle(species1,level1,species2,level2,variable=nil,canescape=true,canlose=false)
  if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
    if $Trainer.pokemonCount>0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable,1)
    $PokemonGlobal.nextBattleBGM=nil
    $PokemonGlobal.nextBattleME=nil
    $PokemonGlobal.nextBattleBack=nil
    return true
  end
  if species1.is_a?(String) || species1.is_a?(Symbol)
    species1=getID(PBSpecies,species1)
  end
  if species2.is_a?(String) || species2.is_a?(Symbol)
    species2=getID(PBSpecies,species2)
  end
  currentlevels=[]
  for i in $Trainer.party
    currentlevels.push([i.personalID,i.level])
  end
  genwildpoke=pbGenerateWildPokemon(species1,level1)
  genwildpoke2=pbGenerateWildPokemon(species2,level2)
  Events.onStartBattle.trigger(nil,genwildpoke)
  scene=pbNewBattleScene
  if $PokemonGlobal.partner
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    combinedParty=[]
    for i in 0...$Trainer.party.length
      combinedParty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      combinedParty[6+i]=othertrainer.party[i]
    end
    battle=PokeBattle_Battle.new(scene,combinedParty,[genwildpoke,genwildpoke2],
       [$Trainer,othertrainer],nil)
    battle.fullparty1=true
  else
    battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke,genwildpoke2],
       $Trainer,nil)
  end
  battle.internalbattle=true
  battle.doublebattle=battle.pbDoubleBattleAllowed?()
  battle.cantescape=!canescape
  pbPrepareBattle(battle)
  decision=0
  pbBattleAnimation(pbGetWildBattleBGM(species1)) { 
    pbSceneStandby {
      decision=battle.pbStartBattle(canlose)
    }
    if $PokemonGlobal.partner
      pbHealAll
      for i in $PokemonGlobal.partner[3]
        i.heal
      end
    end
    if decision==2 || decision==5
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
      else
        $game_system.bgm_unpause
        $game_system.bgs_unpause
        Kernel.pbStartOver
      end
    end
    Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  pbSet(variable,decision)
  return (decision!=2 && decision!=5)
end

def pbCheckAllFainted()
  if pbAllFainted
    Kernel.pbMessage(_INTL("{1} has no usable Pokémon!\1",$Trainer.name))
    Kernel.pbMessage(_INTL("{1} blacked out!",$Trainer.name))
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn(99999){
       Kernel.pbStartOver
    }
  end
end

def pbDynamicItemList(*args)
  ret=[]
  for i in 0...args.length
    if hasConst?(PBItems,args[i])
      ret.push(getConst(PBItems,args[i].to_sym))
    end
  end
  return ret
end

# Runs the Pickup event after a battle if a Pokemon has the ability Pickup.
def Kernel.pbPickup(pokemon)
  return if !(pokemon.ability == PBAbilities::PICKUP) || pokemon.isEgg?
  return if pokemon.item!=0
  return if rand(10)!=0
  pickupList=pbDynamicItemList(
     :ORANBERRY,
     :GREATBALL,
     :SUPERREPEL,
     :POKESNAX,
     :CHOCOLATEIC,
     :BLASTPOWDER,
     :DUSKBALL,
     :ULTRAPOTION,
     :MAXREPEL,
     :FULLRESTORE,
     :REVIVE,
     :ETHER,
     :PPUP,
     :HEARTSCALE,
     :ABILITYCAPSULE,
     :HEARTSCALE,
     :BIGNUGGET,
     :SACREDASH
  )

  pickupListRare=pbDynamicItemList(
     :NUGGET,
     :STRAWBIC,
     :NUGGET,
     :RARECANDY,
     :BLUEMIC,
     :RARECANDY,
     :BLUEMIC,
     :BIGNUGGET,
     :LEFTOVERS,
     :LUCKYEGG,
     :LEFTOVERS
  )
  return if pickupList.length!=18
  return if pickupListRare.length!=11
  randlist=[30,10,10,10,10,10,10,4,4,1,1]
  items=[]
  plevel=[100,pokemon.level].min
  rnd=rand(100)
  itemstart=(plevel-1)/10
  itemstart=0 if itemstart<0
  for i in 0...9
    items.push(pickupList[i+itemstart])
  end
  items.push(pickupListRare[itemstart])
  items.push(pickupListRare[itemstart+1])
  cumnumber=0
  for i in 0...11
    cumnumber+=randlist[i]
    if rnd<cumnumber
      if $PokemonBag.pbCanStore?(items[i])
        $PokemonBag.pbStoreItem(items[i])
      else
        pokemon.setItem(items[i])
      end
      itemname = PBItems.getName(items[i])
      if itemname =~ /\A[aeiou]/
        Kernel.pbMessage(_INTL("{1} picked up an {2}!", pokemon.name, itemname))
      else
        Kernel.pbMessage(_INTL("{1} picked up a {2}!", pokemon.name, itemname))
      end
      break
    end
  end
end

class PokemonTemp
  attr_accessor :encounterType 
  attr_accessor :evolutionLevels
end

def pbEncounter(enctype)
  if $PokemonGlobal.partner
    encounter1=$PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter1
    encounter2=$PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter2
    $PokemonTemp.encounterType=enctype
    pbDoubleWildBattle(encounter1[0],encounter1[1],encounter2[0],encounter2[1])
    $PokemonTemp.encounterType=-1
    return true
  else
    encounter=$PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter
    $PokemonTemp.encounterType=enctype
    pbWildBattle(encounter[0],encounter[1])
    $PokemonTemp.encounterType=-1
    return true
  end
end

Events.onStartBattle+=proc {|sender,e|
  $PokemonTemp.evolutionLevels=[]
  for i in 0...$Trainer.party.length
    $PokemonTemp.evolutionLevels[i]=[$Trainer.party[i].personalID,$Trainer.party[i].level]
  end
}

Events.onEndBattle+=proc {|sender,e|
  decision=e[0]
  if decision==1
    for pkmn in $Trainer.party
      Kernel.pbPickup(pkmn)
      if (pkmn.ability == PBAbilities::HONEYGATHER) && !pkmn.isEgg? && !pkmn.hasItem?
        chance = 5 + ((pkmn.level-1)/10)*5
        if rand(100)<chance
          $PokemonBag.pbStoreItem(PBItems::HONEY)
          Kernel.pbMessage(_INTL("{1} gathered some Honey.", pkmn.name))
        end
      end
    end
  end
}

################################################################################
# Scene_Map and Spriteset_Map
################################################################################
class Spriteset_Map
  def getAnimations
    return @usersprites
  end

  def restoreAnimations(anims)
    @usersprites=anims
  end
end

Events.onSpritesetCreate+=proc{|sender,e|
  spriteset=e[0] # Spriteset being created
  viewport=e[1] # Viewport used for tilemap and characters
  map=spriteset.map # Map associated with the spriteset (not necessarily the current map).
  for i in map.events.keys
    if map.events[i].name[/^OutdoorLight\((\w+)\)$/]
      filename=$~[1].to_s
      spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i],viewport,map,filename))
    elsif map.events[i].name=="OutdoorLight"
      spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i],viewport,map))
    elsif map.events[i].name[/^Light\((\w+)\)$/]
      filename=$~[1].to_s
      spriteset.addUserSprite(LightEffect_Basic.new(map.events[i],viewport,map,filename))
    elsif map.events[i].name=="Light"
      spriteset.addUserSprite(LightEffect_Basic.new(map.events[i],viewport,map))
    end
  end
}

def Kernel.pbOnSpritesetCreate(spriteset,viewport)
  Events.onSpritesetCreate.trigger(nil,spriteset,viewport)
end

################################################################################
# Field movement
################################################################################
def pbLedge(xOffset,yOffset)
  if Kernel.pbFacingTerrainTag==PBTerrain::Ledge
    if Kernel.pbJumpToward(2,true)
      $scene.spriteset.addUserAnimation(DUST_ANIMATION_ID,$game_player.x,$game_player.y,true)
      $game_player.increase_steps
      $game_player.check_event_trigger_here([1,2])
    end
    return true
  end
  return false
end

def Kernel.pbSlideOnIce(event=nil)
  event=$game_player if !event
  return if !event
  return if pbGetTerrainTag(event)!=PBTerrain::Ice
  $PokemonGlobal.sliding=true
  direction=event.direction
  oldwalkanime=event.walk_anime
  event.straighten
  event.pattern=1
  event.walk_anime=false
  loop do
    break if !event.passable?(event.x,event.y,direction)
    break if pbGetTerrainTag(event)!=PBTerrain::Ice
    event.move_forward
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  event.center(event.x,event.y) if event==$game_player 
  event.straighten
  event.walk_anime=oldwalkanime
  $PokemonGlobal.sliding=false
end

def Kernel.pbConveyorMove(event=nil)
  event=$game_player if !event
  current_tag = pbGetTerrainTag(event)
  return if !event
  return if (current_tag > PBTerrain::UpConveyor || current_tag < PBTerrain::DownConveyor)
  $PokemonGlobal.sliding=true
  oldwalkanime=event.walk_anime
  event.straighten
  event.pattern=0
  event.walk_anime=false
  loop do
    current_tag = pbGetTerrainTag(event)
    case current_tag
    when PBTerrain::DownConveyor then direction=2
    when PBTerrain::LeftConveyor then direction=4
    when PBTerrain::RightConveyor then direction=6
    when PBTerrain::UpConveyor then direction=8
  end        
  break if (current_tag > PBTerrain::UpConveyor || current_tag < PBTerrain::DownConveyor)
  break if !event.passable?(event.x,event.y,direction)
  case current_tag
    when PBTerrain::DownConveyor then event.move_down(false)
    when PBTerrain::LeftConveyor then event.move_left(false)
    when PBTerrain::RightConveyor then event.move_right(false)
    when PBTerrain::UpConveyor then event.move_up(false)
  end        
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  event.center(event.x,event.y) if event==$game_player 
  event.straighten
  event.walk_anime=oldwalkanime
  $PokemonGlobal.sliding=false
end

def pbFieldDamage
  flashed=false
  for i in $Trainer.party
    if i.hp>0 && !i.isEgg? && !(i.ability == PBAbilities::MAGICGUARD) && 
        !($game_switches[:Devon_Panel_Puzzle] && (i.ability == PBAbilities::VOLTABSORB ||
        i.ability == PBAbilities::MOTORDRIVE || i.ability == PBAbilities::LIGHTNINGROD ||
        isConst?(i.type1,PBTypes,:GROUND) ||  isConst?(i.type2,PBTypes,:GROUND)))
      if !flashed
        $game_screen.start_flash(Color.new(255,0,0,128), 4)
        flashed=true
      end
      next if i.hp==1
      i.hp-=(i.totalhp/8.0).floor
      i.hp=1 if i.hp==0
      pbCheckAllFainted()
    elsif i.ability == PBAbilities::VOLTABSORB 
      i.hp+=(i.totalhp/16.0).floor
      i.hp = i.totalhp if i.hp > i.totalhp 
    end
  end
end
  
# Poison event on each step taken
Events.onStepTakenTransferPossible+=proc {|sender,e|
  handled=e[0]
  next if handled[0]
  if $PokemonGlobal.stepcount % 4 == 0 && POISONINFIELD && $game_switches[:Overworld_Poison_Password] != true
    flashed=false
    for i in $Trainer.party
      if i.status==PBStatuses::POISON && i.hp>0 && !i.isEgg? &&
         !(i.ability == PBAbilities::POISONHEAL) &&
         !(i.ability == PBAbilities::MAGICGUARD)
        if !flashed
          #$scene.spriteset.addUserAnimation(20,$game_player.x,$game_player.y,true) if $scene.is_a?(Scene_Map)
          $game_player.animation_id = 20
          flashed=true
        end
        if i.hp==1 && !POISONFAINTINFIELD
          i.status=0
          Kernel.pbMessage(_INTL("{1} survived the poisoning.\\nThe poison faded away!\\1",i.name))
          next
        end
        i.hp-=1
        if i.hp==1 && !POISONFAINTINFIELD
          i.status=0
          Kernel.pbMessage(_INTL("{1} survived the poisoning.\\nThe poison faded away!\\1",i.name))
          next
        end
        handled[0]=true if pbAllFainted
        pbCheckAllFainted()
      end
    end
  end
}

Events.onStepTaken+=proc{
  $PokemonGlobal.happinessSteps=0 if !$PokemonGlobal.happinessSteps
  $PokemonGlobal.happinessSteps+=1

  if $PokemonBag.pbQuantity(PBItems::POKESNAX)>0
    $game_switches[:Has_PokeSnax] = true
  else
    $game_switches[:Has_PokeSnax] = false  
  end

  if $PokemonGlobal.happinessSteps==128
    for pkmn in $Trainer.party
      if pkmn.hp>0 && !pkmn.egg?
        pkmn.changeHappiness("walking") if rand(2)==0
      end
    end
    $PokemonGlobal.happinessSteps=0
  end
}

Events.onStepTakenFieldMovement+=proc{|sender,e|
  event=e[0] # Get the event affected by field movement
  currentTag=pbGetTerrainTag(event)
  if currentTag==PBTerrain::Grass  # Won't show if under bridge
    if event==$game_player
      $scene.spriteset.addUserAnimation(GRASS_ANIMATION_ID,event.x,event.y,true) if $scene.is_a?(Scene_Map)
    end
  elsif event==$game_player && currentTag==PBTerrain::WaterfallCrest
     # Descend waterfall, but only if this event is the player
    Kernel.pbDescendWaterfall(event)
  elsif (currentTag <= 23 && currentTag >= 20) && !$PokemonGlobal.sliding
    Kernel.pbConveyorMove(event)    
  elsif currentTag==PBTerrain::Ice && !$PokemonGlobal.sliding
    Kernel.pbSlideOnIce(event)
  end
}

def pbBattleOnStepTaken(repel=false)
  return if $Trainer.ablePokemonCount==0
  encounterType = $PokemonEncounters.pbEncounterType
  return if encounterType<0
  return if !$PokemonEncounters.isEncounterPossibleHere?()
  encounter=$PokemonEncounters.pbGenerateEncounter(encounterType)
  encounter=EncounterModifier.trigger(encounter)
  if $PokemonEncounters.pbCanEncounter?(encounter)
    if $PokemonGlobal.partner
      encounter2=$PokemonEncounters.pbEncounteredPokemon(encounterType)
      pbDoubleWildBattle(encounter[0],encounter[1],encounter2[0],encounter2[1])
    else
      pbWildBattle(encounter[0],encounter[1])
    end
  end
  EncounterModifier.triggerEncounterEnd()
end

def Kernel.pbOnStepTaken(eventTriggered)
  if $game_player.move_route_forcing || pbMapInterpreterRunning? || !$Trainer
    # if forced movement or if no trainer was created yet
    Events.onStepTakenFieldMovement.trigger(nil,$game_player)
    return
  end
  $PokemonGlobal.stepcount=0 if !$PokemonGlobal.stepcount
  $PokemonGlobal.stepcount+=1
  $PokemonGlobal.stepcount&=0x7FFFFFFF
  Events.onStepTaken.trigger(nil)
#  Events.onStepTakenFieldMovement.trigger(nil,$game_player)
  handled=[nil]
  Events.onStepTakenTransferPossible.trigger(nil,handled)
  return if handled[0]
  if !eventTriggered
    pbBattleOnStepTaken()
  end
end

# This method causes a lot of lag when the game is encrypted
def pbGetPlayerCharset(meta,charset,trainer=nil)
  trainer=$Trainer if !trainer
  outfit=trainer ? trainer.outfit : 0
  ret=meta[charset]
  ret=meta[1] if !ret || ret==""
#  if FileTest.image_exist?("Graphics/Characters/"+ret+"_"+outfit.to_s)
  if pbResolveBitmap("Graphics/Characters/"+ret+"_"+outfit.to_s)
    ret=ret+"_"+outfit.to_s
  end
  return ret
end

def Kernel.pbUpdateVehicle
  meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
  if meta
    if $PokemonGlobal.diving
      $game_player.character_name=pbGetPlayerCharset(meta,5) # Diving graphic
    elsif $PokemonGlobal.surfing
      $game_player.character_name=pbGetPlayerCharset(meta,3) # Surfing graphic
    elsif $PokemonGlobal.bicycle
      $game_player.character_name=pbGetPlayerCharset(meta,2) # Bicycle graphic
    else
      $game_player.character_name=pbGetPlayerCharset(meta,1) # Regular graphic
    end
  end
end

def Kernel.pbCancelVehicles(destination=nil)
  $PokemonGlobal.surfing=false
  $game_switches[:Faux_Surf]=false
  $PokemonGlobal.diving=false
  if !destination || !pbCanUseBike?(destination)
    $PokemonGlobal.bicycle=false
  end
  Kernel.pbUpdateVehicle
end

def pbCanUseBike?(mapid)
  return true if pbGetMetadata(mapid,MetadataBicycleAlways)
  val=pbGetMetadata(mapid,MetadataBicycle)
  val=pbGetMetadata(mapid,MetadataOutdoor) if val==nil
  return val ? true : false 
end

def Kernel.pbMountBike
  return if $PokemonGlobal.bicycle
  if $game_switches[:Riding_Tauros]
       Kernel.pbMessage(_INTL("You can't bike while riding on a Pokémon!"))
  else
  $PokemonGlobal.bicycle=true
  Kernel.pbUpdateVehicle
  bikebgm=pbGetMetadata(0,MetadataBicycleBGM)
  pbSEPlay("Bike Bell")
  if bikebgm && $idk[:settings].bike_and_surf_music == 1
    pbCueBGM(bikebgm, 0.5)
    end
  end
end

def Kernel.pbDismountBike
  return if !$PokemonGlobal.bicycle
  $PokemonGlobal.bicycle=false
  Kernel.pbUpdateVehicle
  $game_map.autoplayAsCue
end

def Kernel.pbDismountTauros
  return if !$game_switches[:Riding_Tauros]
  pbCommonEvent(53)
end

def Kernel.pbSetPokemonCenter
  $PokemonGlobal.pokecenterMapId=$game_map.map_id
  $PokemonGlobal.pokecenterX=$game_player.x
  $PokemonGlobal.pokecenterY=$game_player.y
  $PokemonGlobal.pokecenterDirection=$game_player.direction
end

################################################################################
# Fishing
################################################################################
def pbFishingBegin
  $PokemonGlobal.fishing=true
  if !pbCommonEvent(FISHINGBEGINCOMMONEVENT)
    patternb = 2*$game_player.direction - 1
    playertrainer=pbGetPlayerTrainerType
    meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
    num=($PokemonGlobal.surfing) ? 7 : 6
    if meta && meta[num] && meta[num]!=""
      charset=pbGetPlayerCharset(meta,num)
      4.times do |pattern|
        $game_player.setDefaultCharName(charset,patternb-pattern)
        2.times do
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
    end
  end
end

def pbFishingEnd
  if !pbCommonEvent(FISHINGENDCOMMONEVENT)
    patternb = 2*($game_player.direction - 2)
    playertrainer=pbGetPlayerTrainerType
    meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
    num=($PokemonGlobal.surfing) ? 7 : 6
    if meta && meta[num] && meta[num]!=""
      charset=pbGetPlayerCharset(meta,num)
      4.times do |pattern|
        $game_player.setDefaultCharName(charset,patternb+pattern)
        2.times do
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
    end
  end
  $PokemonGlobal.fishing=false
end

def pbFishing(hasencounter,rodtype=1)
  bitechance=50+(15*rodtype)   # 65, 80, 95
  if $Trainer.party.length>0 && !$Trainer.party[0].isEgg?
    bitechance*=2 if ($Trainer.party[0].ability == PBAbilities::STICKYHOLD)
    bitechance*=2 if ($Trainer.party[0].ability == PBAbilities::SUCTIONCUPS)
  end
  hookchance=100
  oldpattern=$game_player.fullPattern
  pbFishingBegin
  msgwindow=Kernel.pbCreateMessageWindow
  loop do
    time=2+rand(10)
    message=""
    time.times do 
      message+=".  "
    end
    if pbWaitMessage(msgwindow,time)
      pbFishingEnd
      $game_player.setDefaultCharName(nil,oldpattern)
      Kernel.pbMessageDisplay(msgwindow,_INTL("Not even a nibble..."))
      Kernel.pbDisposeMessageWindow(msgwindow)
      return false
    end
    if rand(100)<bitechance && hasencounter
      frames=rand(21)+25
      if !pbWaitForInput(msgwindow,message+_INTL("\r\nOh!  A bite!"),frames)
        pbFishingEnd
        $game_player.setDefaultCharName(nil,oldpattern)
        Kernel.pbMessageDisplay(msgwindow,_INTL("The Pokémon got away..."))
        Kernel.pbDisposeMessageWindow(msgwindow)
        return false
      end
      if rand(100)<hookchance || FISHINGAUTOHOOK
        Kernel.pbMessageDisplay(msgwindow,_INTL("Landed a Pokémon!"))
        Kernel.pbDisposeMessageWindow(msgwindow)
        pbFishingEnd
        $game_player.setDefaultCharName(nil,oldpattern)
        return true
      end
    else
      pbFishingEnd
      $game_player.setDefaultCharName(nil,oldpattern)
      Kernel.pbMessageDisplay(msgwindow,_INTL("Not even a nibble..."))
      Kernel.pbDisposeMessageWindow(msgwindow)
      return false
    end
  end
  Kernel.pbDisposeMessageWindow(msgwindow)
  return false
end

def pbWaitForInput(msgwindow,message,frames)
  return true if FISHINGAUTOHOOK
  Kernel.pbMessageDisplay(msgwindow,message,false)
  frames *= 3 if $speed_up
  frames.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    if Input.trigger?(Input::C) || Input.trigger?(Input::B)
      return true
    end
  end
  return false
end

def pbWaitMessage(msgwindow,time)
  message=""
  (time+1).times do |i|
    message+=".  " if i>0
    Kernel.pbMessageDisplay(msgwindow,message,false)
    20.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        return true
      end
    end
  end
  return false
end



################################################################################
# Moving between maps
################################################################################
Events.onMapChange+=proc {|sender,e|
  oldid=e[0] # previous map ID, 0 if no map ID
  healing=pbGetMetadata($game_map.map_id,MetadataHealingSpot)
  $PokemonGlobal.healingSpot=healing if healing
  $PokemonMap.clear if $PokemonMap
  $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  $PokemonGlobal.visitedMaps[$game_map.map_id]=true
}

Events.onMapSceneChange+=proc{|sender,e|
  scene=e[0]
  mapChanged=e[1]
  return if !scene || !scene.spriteset
  if $game_map
    lastmapdetails=$PokemonGlobal.mapTrail[0] ?
       pbGetMetadata($PokemonGlobal.mapTrail[0],MetadataMapPosition) : [-1,0,0]
    lastmapdetails=[-1,0,0] if !lastmapdetails
    newmapdetails=$game_map.map_id ?
       pbGetMetadata($game_map.map_id,MetadataMapPosition) : [-1,0,0]
    newmapdetails=[-1,0,0] if !newmapdetails
    $PokemonGlobal.mapTrail=[] if !$PokemonGlobal.mapTrail
    if $PokemonGlobal.mapTrail[0]!=$game_map.map_id
      $PokemonGlobal.mapTrail[3]=$PokemonGlobal.mapTrail[2] if $PokemonGlobal.mapTrail[2]
      $PokemonGlobal.mapTrail[2]=$PokemonGlobal.mapTrail[1] if $PokemonGlobal.mapTrail[1]
      $PokemonGlobal.mapTrail[1]=$PokemonGlobal.mapTrail[0] if $PokemonGlobal.mapTrail[0]
    end
    $PokemonGlobal.mapTrail[0]=$game_map.map_id   # Update map trail
  end
  darkmap=pbGetMetadata($game_map.map_id,MetadataDarkMap)
  if darkmap
    if $PokemonGlobal.flashUsed || ($game_switches[:EasyHMs_Password] && $PokemonBag.pbQuantity(PBItems::TM70)>0 && $Trainer.numbadges>=BADGEFORFLASH)
      $PokemonTemp.darknessSprite=DarknessSprite.new
      scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
      darkness=$PokemonTemp.darknessSprite
      darkness.radius=192
    else
      $PokemonTemp.darknessSprite=DarknessSprite.new
      scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
    end
  elsif !darkmap
    $PokemonGlobal.flashUsed=false
    if $PokemonTemp.darknessSprite
      $PokemonTemp.darknessSprite.dispose
      $PokemonTemp.darknessSprite=nil
    end
  end
  if mapChanged
    if $game_switches[:Disable_Signposts_Music] == false # for ending scenes
      if pbGetMetadata($game_map.map_id,MetadataShowArea)
        nosignpost=false
        if $PokemonGlobal.mapTrail[1]
          for i in 0...NOSIGNPOSTS.length/2
            nosignpost=true if NOSIGNPOSTS[2*i]==$PokemonGlobal.mapTrail[1] && NOSIGNPOSTS[2*i+1]==$game_map.map_id
            nosignpost=true if NOSIGNPOSTS[2*i+1]==$PokemonGlobal.mapTrail[1] && NOSIGNPOSTS[2*i]==$game_map.map_id
            break if nosignpost
          end
          oldmapname=$cache.mapinfos[$PokemonGlobal.mapTrail[1]].name
          nosignpost=true if $game_map.name==oldmapname
        end
        scene.spriteset.addUserSprite(LocationWindow.new($game_map.name)) if !nosignpost
      end
    end
  end
  if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
    Kernel.pbMountBike
  else
    if !pbCanUseBike?($game_map.map_id)
      Kernel.pbDismountBike
    end
  end
}

def Kernel.pbStartOver(gameover=false)
  pbHealAll()
  if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId>=0
    if gameover
      Kernel.pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, {1} scurried to a Pokémon Center.",$Trainer.name))
    else
      Kernel.pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]{1} scurried to a Pokémon Center, protecting the exhausted and fainted Pokémon from further harm.",$Trainer.name))
    end
    Kernel.pbCancelVehicles
    pbRemoveDependencies()
    $game_switches[:Starting_Over]=true
    $game_temp.player_new_map_id=$PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x=$PokemonGlobal.pokecenterX
    $game_temp.player_new_y=$PokemonGlobal.pokecenterY
    $game_temp.player_new_direction=$PokemonGlobal.pokecenterDirection
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    $game_map.refresh
  else
    homedata=pbGetMetadata(0,MetadataHome)
    if (homedata && !pbRxdataExists?(sprintf("Data/Map%03d",homedata[0])) )
      if $DEBUG
        Kernel.pbMessage(_ISPRINTF("Can't find the map 'Map{1:03d}' in the Data folder.  The game will resume at the player's position.",homedata[0]))
      end
      pbHealAll()
      return
    end
    if gameover
      Kernel.pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, {1} scurried home.",$Trainer.name))
    else
      Kernel.pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]{1} scurried home, protecting the exhausted and fainted Pokémon from further harm.",$Trainer.name))
    end
    if homedata
      Kernel.pbCancelVehicles
      pbRemoveDependencies()
      $game_switches[:Starting_Over]=true
      $game_temp.player_new_map_id=homedata[0]
      $game_temp.player_new_x=homedata[1]
      $game_temp.player_new_y=homedata[2]
      $game_temp.player_new_direction=homedata[3]
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
    else
      pbHealAll()
    end
  end
  pbEraseEscapePoint
end

def pbCaveEntranceEx(exiting)
  sprite=BitmapSprite.new(Graphics.width,Graphics.height)
  sprite.z=100000
  totalBands=15
  totalFrames=15
  bandheight=((Graphics.height/2)-10).to_f/totalBands
  bandwidth=((Graphics.width/2)-12).to_f/totalBands
  grays=[]
  tbm1=totalBands-1
  for i in 0...totalBands
    grays.push(exiting ? 0 : 255)
  end
  totalFrames.times do |j|
    x=0
    y=0
    rectwidth=Graphics.width
    rectheight=Graphics.height
    for k in 0...j
      t=(255.0)/totalFrames
      if exiting
        t=1.0-t
        t*=1.0+((k)/totalFrames.to_f)
      else
        t*=1.0+0.3*(((totalFrames-k)/totalFrames.to_f)**0.7)
      end
      grays[k]-=t
      grays[k]=0 if grays[k]<0
    end
    for i in 0...totalBands
      currentGray=grays[i]
      sprite.bitmap.fill_rect(Rect.new(x,y,rectwidth,rectheight),
         Color.new(currentGray,currentGray,currentGray))
      x+=bandwidth
      y+=bandheight
      rectwidth-=bandwidth*2
      rectheight-=bandheight*2
    end
    Graphics.update
    Input.update
  end
  if exiting
    pbToneChangeAll(Tone.new(255,255,255),0)
  else
    pbToneChangeAll(Tone.new(-255,-255,-255),0)
  end
  for j in 0..15
    if exiting
      sprite.color=Color.new(255,255,255,j*255/15)
    else
      sprite.color=Color.new(0,0,0,j*255/15) 
    end
    Graphics.update
    Input.update
  end
  pbToneChangeAll(Tone.new(0,0,0),8)
  for j in 0..5
    Graphics.update
    Input.update
  end
  sprite.dispose
end

def pbCaveEntrance
  pbSetEscapePoint
  pbCaveEntranceEx(false)
end

def pbCaveExit
  pbEraseEscapePoint
  pbCaveEntranceEx(true)
end

def pbSetEscapePoint
  $PokemonGlobal.escapePoint=[] if !$PokemonGlobal.escapePoint
  xco=$game_player.x
  yco=$game_player.y
  case $game_player.direction
  when 2; yco-=1; dir=8   # Down
  when 4; xco+=1; dir=6   # Left
  when 6; xco-=1; dir=4   # Right
  when 8; yco+=1; dir=2   # Up
  end
  $PokemonGlobal.escapePoint=[$game_map.map_id,xco,yco,dir]
end

def pbEraseEscapePoint
  $PokemonGlobal.escapePoint=[]
end

################################################################################
# Partner trainer
################################################################################
def pbRegisterPartner(trainerid,trainername,partyid=0)
  Kernel.pbCancelVehicles
  trainer=pbLoadTrainer(trainerid,trainername,partyid)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  trainerobject=PokeBattle_Trainer.new(_INTL(trainer[0].name),trainerid)
  trainerobject.setForeignID($Trainer)
  for i in trainer[2]
    i.trainerID=trainerobject.id
    i.ot=trainerobject.name
    i.calcStats
  end
  $PokemonGlobal.partner=[trainerid,trainerobject.name,trainerobject.id,trainer[2]]
end

def pbDeregisterPartner
  $PokemonGlobal.partner=nil
end

################################################################################
# Constant checks
################################################################################
Events.onMapUpdate+=proc {|sender,e|   # Pokérus check
  last=$PokemonGlobal.pokerusTime
  now=pbGetTimeNow
  if !last || last.year!=now.year || last.month!=now.month || last.day!=now.day
    if $Trainer && $Trainer.party
      for i in $Trainer.pokemonParty
        i.lowerPokerusCount
      end
      $PokemonGlobal.pokerusTime=now
    end
  end
}
Events.onMapUpdate+=proc {|sender,e|
 if $game_switches[:Riding_Tauros] && !($game_temp.menu_calling)
   if Input.trigger?(Input::X)
   pbFadeOutIn(99999) { 
     Kernel.pbDismountTauros
     pbWait(25)
     $scene.miniupdate
     }
    Kernel.pbMessage(_INTL("Tauros hurried away!"))
   end
 elsif $game_switches[:Devon_Panel_Puzzle] == true
   if Input.trigger?(Input::X)
     $game_switches[:Devon_Panel_Switch] = true
   end
 end
}

# Returns whether the Poké Center should explain Pokérus to the player, if a
# healed Pokémon has it.
def Kernel.pbPokerus?
  return false if $game_switches[:Seen_Pokerus]
  for i in $Trainer.party
    return true if i.pokerusStage==1
  end
  return false
end

class PokemonTemp
  attr_accessor :cueBGM
  attr_accessor :cueFrames
end

Events.onMapUpdate+=proc {|sender,e|
  if $PokemonTemp.cueFrames
    $PokemonTemp.cueFrames-=1
    if $PokemonTemp.cueFrames<=0
      $PokemonTemp.cueFrames=nil
      if $game_system.getPlayingBGM==nil
        pbBGMPlay($PokemonTemp.cueBGM)
      end
    end
  end
}

################################################################################
# Audio playing
################################################################################
def pbCueBGM(bgm,seconds,volume=nil,pitch=nil)
  return if !bgm
  if bgm == $game_map.map.bgm
    # do not alter the volume because it is already altered
  elsif volume && $idk[:settings].volume
    volume = volume * ($idk[:settings].volume/100.00)
  elsif !volume && $idk[:settings].volume
    volume = $idk[:settings].volume 
  end
  bgm=pbResolveAudioFile(bgm,volume,pitch)
  playingBGM=$game_system.playing_bgm
  if !playingBGM || playingBGM.name!=bgm.name || playingBGM.pitch!=bgm.pitch
    pbBGMFade(seconds)
    if !$PokemonTemp.cueFrames
      $PokemonTemp.cueFrames=(seconds*Graphics.frame_rate)*3/5
    end
    $PokemonTemp.cueBGM=bgm
  elsif playingBGM
    pbBGMPlay(bgm)
  end
end

def pbAutoplayOnTransition
  surfbgm=pbGetMetadata(0,MetadataSurfBGM)
  if $PokemonGlobal.surfing && surfbgm && $idk[:settings].bike_and_surf_music==1
    pbBGMPlay(surfbgm)
  else
    $game_map.autoplayAsCue
  end
end

def pbAutoplayOnSave
  surfbgm=pbGetMetadata(0,MetadataSurfBGM)
  if $PokemonGlobal.surfing && surfbgm && $idk[:settings].bike_and_surf_music==1
    pbBGMPlay(surfbgm)
  else
    $game_map.autoplay(true)
  end
end

def Kernel.pbRxdataExists?(file)
  return pbRgssExists?(file+".rxdata") 
end

################################################################################
# Gaining items
################################################################################
def Kernel.pbItemBall(item,quantity=1,plural=nil)
  if item.is_a?(String) || item.is_a?(Symbol)
    item=getID(PBItems,item)
  end
  return false if !item || item<=0 || quantity<1
  itemname=PBItems.getName(item)
  pocket=pbGetPocket(item)
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be picked up
    if $cache.items[item][ITEMUSE]==3 || $cache.items[item][ITEMUSE]==4
      Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found \\c[1]{2}\\c[0]!\\nIt contained \\c[1]{3}\\c[0].\\wtnp[30]",
         $Trainer.name,itemname,PBMoves.getName($cache.items[item][ITEMMACHINE])))
      Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
         $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
    elsif (item == PBItems::LEFTOVERS)
      Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found some \\c[1]{2}\\c[0]!\\wtnp[30]",
         $Trainer.name,itemname))
      Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
         $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
    else
      if quantity>1
        if plural
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2} \\c[1]{3}\\c[0]!\\wtnp[30]",
             $Trainer.name,quantity,plural))
          Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
             $Trainer.name,plural,PokemonBag.pocketNames()[pocket]))
        else
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2} \\c[1]{3}s\\c[0]!\\wtnp[30]",
             $Trainer.name,quantity,itemname))
          Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}s\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
             $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
        end
      else
        Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found one \\c[1]{2}\\c[0]!\\wtnp[30]",
           $Trainer.name,itemname))
        Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
           $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
      end
    end
    return true
  else   # Can't add the item
    if $cache.items[item][ITEMUSE]==3 || $cache.items[item][ITEMUSE]==4
      Kernel.pbMessage(_INTL("{1} found \\c[1]{2}\\c[0]!\\wtnp[20]",
         $Trainer.name,itemname))
    elsif (item == PBItems::LEFTOVERS)
      Kernel.pbMessage(_INTL("{1} found some \\c[1]{2}\\c[0]!\\wtnp[20]",
         $Trainer.name,itemname))
    else
      if quantity>1
        if plural
          Kernel.pbMessage(_INTL("{1} found {2} \\c[1]{3}\\c[0]!\\wtnp[20]",
             $Trainer.name,quantity,plural))
        else
          Kernel.pbMessage(_INTL("{1} found {2} \\c[1]{3}s\\c[0]!\\wtnp[20]",
             $Trainer.name,quantity,itemname))
        end
      else
        Kernel.pbMessage(_INTL("{1} found one \\c[1]{2}\\c[0]!\\wtnp[20]",
           $Trainer.name,itemname))
      end
    end
    Kernel.pbMessage(_INTL("Too bad... The Bag is full..."))
    return false
  end
end

def Kernel.pbReceiveItem(item,quantity=1,plural=nil)
  if item.is_a?(String) || item.is_a?(Symbol)
    item=getID(PBItems,item)
  end
  return false if !item || item<=0 || quantity<1
  itemname=PBItems.getName(item)
  pocket=pbGetPocket(item)
  if $cache.items[item][ITEMUSE]==3 || $cache.items[item][ITEMUSE]==4
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained \\c[1]{1}\\c[0]!\\nIt contained \\c[1]{2}\\c[0].\\wtnp[30]",
       itemname,PBMoves.getName($cache.items[item][ITEMMACHINE])))
  elsif (item == PBItems::LEFTOVERS)
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained some \\c[1]{1}\\c[0]!\\wtnp[30]",
       itemname))
  elsif quantity>1
    if plural
      Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained {2} \\c[1]{1}\\c[0]!\\wtnp[30]",
         plural,quantity))
    else
      Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained {2} \\c[1]{1}s\\c[0]!\\wtnp[30]",
         itemname,quantity))
    end
  else
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained \\c[1]{1}\\c[0]!\\wtnp[30]",
       itemname))
  end
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be added
    if quantity>1
      if plural
        Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
           $Trainer.name,plural,PokemonBag.pocketNames()[pocket]))
      else
        Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}s\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
           $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
      end
    else
      Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
         $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
    end
    return true
  else   # Can't add the item
    return false
  end
end

################################################################################
# Event locations, terrain tags
################################################################################
def pbEventFacesPlayer?(event,player,distance)
  return false if distance<=0
  # Event can't reach player if no coordinates coincide
  return false if event.x!=player.x && event.y!=player.y
  deltaX = (event.direction == 6 ? 1 : event.direction == 4 ? -1 : 0)
  deltaY =  (event.direction == 2 ? 1 : event.direction == 8 ? -1 : 0)
  # Check for existence of player
  curx=event.x
  cury=event.y
  found=false
  for i in 0...distance
    curx+=deltaX
    cury+=deltaY
    if player.x==curx && player.y==cury
      found=true
      break
    end
  end
  return found
end

def pbEventCanReachPlayer?(event,player,distance)
  return false if distance<=0
  # Event can't reach player if no coordinates coincide
  return false if event.x!=player.x && event.y!=player.y
  deltaX = (event.direction == 6 ? 1 : event.direction == 4 ? -1 : 0)
  deltaY =  (event.direction == 2 ? 1 : event.direction == 8 ? -1 : 0)
  # Check for existence of player
  curx=event.x
  cury=event.y
  found=false
  realdist=0
  for i in 0...distance
    curx+=deltaX
    cury+=deltaY
    if player.x==curx && player.y==cury
      found=true
      break
    end
    realdist+=1
  end
  return false if !found
  # Check passibility
  curx=event.x
  cury=event.y
  for i in 0...realdist
    if !event.passable?(curx,cury,event.direction)
      return false
    end
    curx+=deltaX
    cury+=deltaY
  end
  return true
end

def pbFacingTileRegular(direction=nil,event=nil)
  event=$game_player if !event
  return [0,0,0] if !event
  x=event.x
  y=event.y
  direction=event.direction if !direction
  case direction
    when 1; y+=1; x-=1
    when 2; y+=1
    when 3; y+=1; x+=1
    when 4; x-=1
    when 6; x+=1
    when 7; y-=1; x-=1
    when 8; y-=1
    when 9; y-=1; x+=1
  end
  return [$game_map ? $game_map.map_id : 0,x,y]
end

def pbFacingTile(direction=nil,event=nil)
  if $MapFactory
    return $MapFactory.getFacingTile(direction,event)
  else
    return pbFacingTileRegular(direction,event)
  end
end

def pbFacingEachOther(event1,event2)
  return false if !event1 || !event2
  if $MapFactory
    tile1=$MapFactory.getFacingTile(nil,event1)
    tile2=$MapFactory.getFacingTile(nil,event2)
    return false if !tile1 || !tile2
    if tile1[0]==event2.map.map_id &&
       tile1[1]==event2.x && tile1[2]==event2.y &&
       tile2[0]==event1.map.map_id &&
       tile2[1]==event1.x && tile2[2]==event1.y
      return true
    else
      return false
    end
  else
    tile1=Kernel.pbFacingTile(nil,event1)
    tile2=Kernel.pbFacingTile(nil,event2)
    return false if !tile1 || !tile2
    if tile1[1]==event2.x && tile1[2]==event2.y &&
       tile2[1]==event1.x && tile2[2]==event1.y
      return true
    else
      return false
    end
  end
end

def pbGetTerrainTag(event=nil)
  event=$game_player if !event
  return 0 if !event
  if $MapFactory
    return $MapFactory.getTerrainTag(event.map.map_id,event.x,event.y)
  else
    $game_map.terrain_tag(event.x,event.y)
  end
end

def Kernel.pbFacingTerrainTag(event=nil,dir=nil)
  if $MapFactory
    return $MapFactory.getFacingTerrainTag(dir,event)
  else
    event=$game_player if !event
    return 0 if !event
    facing=pbFacingTile(dir,event)
   return $game_map.terrain_tag(facing[1],facing[2])
  end
end

################################################################################
# Event movement
################################################################################
def pbTurnTowardEvent(event,otherEvent)
  sx=0
  sy=0
  if $MapFactory
    relativePos=$MapFactory.getThisAndOtherEventRelativePos(otherEvent,event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  if sx == 0 && sy == 0
    return
  end 
  if sx.abs == sy.abs
    sx > 0 ? event.turn_left : event.turn_right
    return
  end
  if sx.abs > sy.abs
    sx > 0 ? event.turn_left : event.turn_right
  else
    sy > 0 ? event.turn_up : event.turn_down
  end
end

def Kernel.pbMoveTowardPlayer(event)
  maxsize=[$game_map.width,$game_map.height].max
  return if !pbEventCanReachPlayer?(event,$game_player,maxsize)
  loop do
    x=event.x
    y=event.y
    event.move_toward_player
    break if event.x==x && event.y==y
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  $PokemonMap.addMovedEvent(event.id) if $PokemonMap
end

def Kernel.pbJumpToward(dist=1,playSound=false,cancelSurf=false)
  x=$game_player.x
  y=$game_player.y
  case $game_player.direction
  when 2; $game_player.jump(0,dist) # down
  when 4; $game_player.jump(-dist,0)# left
  when 6; $game_player.jump(dist,0) # right
  when 8; $game_player.jump(0,-dist)# up
  end
  if $game_player.x!=x || $game_player.y!=y
    pbSEPlay("jump") if playSound
    Kernel.pbCancelVehicles if cancelSurf
    while $game_player.jumping?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    return true
  end
  return false
end

def pbWait(numframes)
  numframes.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

module PBMoveRoute
  Down               = 1
  Left               = 2
  Right              = 3
  Up                 = 4
  LowerLeft          = 5
  LowerRight         = 6
  UpperLeft          = 7
  UpperRight         = 8
  Random             = 9
  TowardPlayer       = 10
  AwayFromPlayer     = 11
  Forward            = 12
  Backward           = 13
  Jump               = 14 # xoffset, yoffset
  Wait               = 15 # frames
  TurnDown           = 16
  TurnLeft           = 17
  TurnRight          = 18
  TurnUp             = 19
  TurnRight90        = 20
  TurnLeft90         = 21
  Turn180            = 22
  TurnRightOrLeft90  = 23
  TurnRandom         = 24
  TurnTowardPlayer   = 25
  TurnAwayFromPlayer = 26
  SwitchOn           = 27 # 1 param
  SwitchOff          = 28 # 1 param
  ChangeSpeed        = 29 # 1 param
  ChangeFreq         = 30 # 1 param
  WalkAnimeOn        = 31
  WalkAnimeOff       = 32
  StepAnimeOn        = 33
  StepAnimeOff       = 34
  DirectionFixOn     = 35
  DirectionFixOff    = 36
  ThroughOn          = 37
  ThroughOff         = 38
  AlwaysOnTopOn      = 39
  AlwaysOnTopOff     = 40
  Graphic            = 41 # Name, hue, direction, pattern
  Opacity            = 42 # 1 param
  Blending           = 43 # 1 param
  PlaySE             = 44 # 1 param
  Script             = 45 # 1 param
  ScriptAsync        = 101 # 1 param
end

class Game_Character
  def jumpForward
    case self.direction
      when 2 then jump(0,1)
      when 4 then jump(-1,0)
      when 6 then jump(1,0)
      when 8 then jump(0,-1)
    end
  end

  def jumpBackward
    case self.direction
      when 2 then jump(0,-1)
      when 4 then jump(1,0)
      when 6 then jump(-1,0)
      when 8 then jump(0,1)
    end
  end

  def moveLeft90
    case self.direction
      when 2 then move_right
      when 4 then move_down
      when 6 then move_up
      when 8 then move_left
    end
  end

  def moveRight90
    case self.direction
      when 2 then move_left
      when 4 then move_up
      when 6 then move_down
      when 8 then move_right
    end
  end

  def minilock
    @prelock_direction=@direction
    @locked=true
  end
end

def pbMoveRoute(event,commands,waitComplete=false)
  route=RPG::MoveRoute.new
  route.repeat=false
  route.skippable=true
  route.list.clear
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOn))
  i=0;while i<commands.length
    case commands[i]
      when PBMoveRoute::Wait, PBMoveRoute::SwitchOn,
         PBMoveRoute::SwitchOff, PBMoveRoute::ChangeSpeed,
         PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
         PBMoveRoute::Blending, PBMoveRoute::PlaySE,
         PBMoveRoute::Script
        route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1]]))
        i+=1
      when PBMoveRoute::ScriptAsync
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,[commands[i+1]]))
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[0]))
        i+=1
      when PBMoveRoute::Jump
        route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2]]))
        i+=2
      when PBMoveRoute::Graphic
        route.list.push(RPG::MoveCommand.new(commands[i],
           [commands[i+1],commands[i+2],commands[i+3],commands[i+4]]))
        i+=4
      else
        route.list.push(RPG::MoveCommand.new(commands[i]))
    end
    i+=1
  end
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOff))
  route.list.push(RPG::MoveCommand.new(0))
  if event
    event.force_move_route(route)
  end
  return route
end

################################################################################
# Screen effects
################################################################################
def pbToneChangeAll(tone, duration)
  $game_screen.start_tone_change(tone,duration * 2)
  for picture in $game_screen.pictures
    picture.start_tone_change(tone,duration * 2) if picture
  end
end

def pbShake(power,speed,frames)
  $game_screen.start_shake(power,speed,frames * 2)
end

def pbFlash(color,frames)
  $game_screen.start_flash(color,frames * 2)
end

def pbScrollMap(direction, distance, speed)
  return if !$game_map
  if speed==0
    case direction
    when 2 then $game_map.scroll_down(distance * 128)
    when 4 then $game_map.scroll_left(distance * 128)
    when 6 then $game_map.scroll_right(distance * 128)
    when 8 then $game_map.scroll_up(distance * 128)
  end
  else
    $game_map.start_scroll(direction, distance, speed);
    oldx=$game_map.display_x
    oldy=$game_map.display_y
    loop do
      Graphics.update
      Input.update
      if !$game_map.scrolling?
        break
      end
      pbUpdateSceneMap
      if $game_map.display_x==oldx && $game_map.display_y==oldy
        break
      end
      oldx=$game_map.display_x
      oldy=$game_map.display_y 
    end
  end
end

################################################################################
# Events
################################################################################
class Game_Event
  def cooledDown?(seconds)
    if !(expired?(seconds) && tsOff?("A"))
      self.need_refresh=true
      return false
    else
      return true
    end
  end

  def cooledDownDays?(days)
    if !(expiredDays?(days) && tsOff?("A"))
      self.need_refresh=true
      return false
    else
      return true
    end
  end
end

module InterpreterFieldMixin
  # Used in boulder events.  Allows an event to be pushed.  To be used in
  # a script event command.
  def pbPushThisEvent
    event=get_character(0)
    oldx=event.x
    oldy=event.y
    # Apply strict version of passable, which makes impassable
    # tiles that are passable only from certain directions
  #  if !event.passableStrict?(event.x,event.y,$game_player.direction)
   #   return
    #end
    case $game_player.direction
    when 2 then event.move_down
    when 4 then event.move_left
    when 6 then event.move_right
    when 8 then event.move_up
    end

    $PokemonMap.addMovedEvent(@event_id) if $PokemonMap
    return false if oldx==event.x && oldy==event.y
#    $game_player.lock
    begin
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end until !event.moving?
#    $game_player.unlock
    return true
  end

  def pbPushThisBoulder
    if $PokemonMap.strengthUsed
      if pbPushThisEvent
        pbSEPlay("strengthpush")
      end
    end
    return true
  end

  def pbHeadbutt
    Kernel.pbHeadbutt(get_character(0))
    return true
  end
 
  def pbHeadbutt2
    Kernel.pbHeadbutt2(get_character(0))
    return true
  end

  def pbTrainerIntro(symbol)
    trtype=PBTrainers.const_get(symbol)
    pbGlobalLock
    Kernel.pbPlayTrainerIntroME(trtype)
    return true
  end

  def pbTrainerEnd
    pbGlobalUnlock
    e=get_character(0)
    e.erase_route if e
  end

  def pbParams
    @parameters ? @parameters : @params
  end

  def pbGetPokemon(id)
    return $Trainer.party[pbGet(id)]
  end

  def pbSetEventTime(*arg)
    $PokemonGlobal.eventvars={} if !$PokemonGlobal.eventvars
    time=pbGetTimeNow
    time=time.to_i
    pbSetSelfSwitch(@event_id,"A",true)
    $PokemonGlobal.eventvars[[@map_id,@event_id]]=time
    for otherevt in arg
      pbSetSelfSwitch(otherevt,"A",true)
      $PokemonGlobal.eventvars[[@map_id,otherevt]]=time
    end
  end

  def getVariable(*arg)
    if arg.length==0
      return nil if !$PokemonGlobal.eventvars
      return $PokemonGlobal.eventvars[[@map_id,@event_id]]
    else
      return $game_variables[arg[0]]
    end
  end

  def setVariable(*arg)
    if arg.length==1
      $PokemonGlobal.eventvars={} if !$PokemonGlobal.eventvars
      $PokemonGlobal.eventvars[[@map_id,@event_id]]=arg[0]
    else
      $game_variables[arg[0]]=arg[1]
      $game_map.need_refresh=true
    end
  end

  def tsOff?(c)
    get_character(0).tsOff?(c)
  end

  def tsOn?(c)
    get_character(0).tsOn?(c)
  end

  alias isTempSwitchOn? tsOn?
  alias isTempSwitchOff? tsOff?

  def setTempSwitchOn(c)
    get_character(0).setTempSwitchOn(c)
  end

  def setTempSwitchOff(c)
    get_character(0).setTempSwitchOff(c)
  end

# Must use this approach to share the methods because the methods already
# defined in a class override those defined in an included module
  CustomEventCommands=<<_END_

  def command_352
    scene=PokemonSaveScene.new
    screen=PokemonSave.new(scene)
    screen.pbSaveScreen
    return true
  end

  def command_125
    value = operate_value(pbParams[0], pbParams[1], pbParams[2])
    $Trainer.money+=value
    return true
  end

  def command_132
    $PokemonGlobal.nextBattleBGM=(pbParams[0]) ? pbParams[0].clone : nil
    return true
  end

  def command_133
    $PokemonGlobal.nextBattleME=(pbParams[0]) ? pbParams[0].clone : nil
    return true
  end

  def command_353
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn(99999){ Kernel.pbStartOver(true) }
  end

  def command_314
    if pbParams[0] == 0 && $Trainer && $Trainer.party
      pbHealAll()
    end
    return true
  end

_END_
end

class Interpreter
  include InterpreterFieldMixin
  eval(InterpreterFieldMixin::CustomEventCommands)
end