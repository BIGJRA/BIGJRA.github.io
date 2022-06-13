class PBEvolution
  Unknown        = 0 # Do not use
  Happiness      = 1
  HappinessDay   = 2
  HappinessNight = 3
  Level          = 4
  Trade          = 5
  TradeItem      = 6
  Item           = 7
  AttackGreater  = 8
  AtkDefEqual    = 9
  DefenseGreater = 10
  Silcoon        = 11
  Cascoon        = 12
  Ninjask        = 13
  Shedinja       = 14
  Beauty         = 15
  ItemMale       = 16
  ItemFemale     = 17
  DayHoldItem    = 18
  NightHoldItem  = 19
  HasMove        = 20
  HasInParty     = 21
  LevelMale      = 22
  LevelFemale    = 23
  Location       = 24
  TradeSpecies   = 25
  BadInfluence   = 26
  Affection      = 27
  LevelRain      = 28
  LevelDay       = 29
  LevelNight     = 30
  Custom6        = 31 # Will be for Farfetch'd/Sirfetch'd
  Custom7        = 32 # Will be for Yamask/Runerigas

  EVONAMES=["Unknown",
     "Happiness","HappinessDay","HappinessNight","Level","Trade",
     "TradeItem","Item","AttackGreater","AtkDefEqual","DefenseGreater",
     "Silcoon","Cascoon","Ninjask","Shedinja","Beauty",
     "ItemMale","ItemFemale","DayHoldItem","NightHoldItem","HasMove",
     "HasInParty","LevelMale","LevelFemale","Location","TradeSpecies",
     "BadInfluence","Affection","LevelRain","LevelDay","LevelNight","Custom6","Custom7"
  ]

  # 0 = no parameter
  # 1 = Positive integer
  # 2 = Item internal name
  # 3 = Move internal name
  # 4 = Species internal name
  # 5 = Type internal name
  EVOPARAM=[0,     # Unknown (do not use)
     0,0,0,1,0,    # Happiness, HappinessDay, HappinessNight, Level, Trade
     2,2,1,1,1,    # TradeItem, Item, AttackGreater, AtkDefEqual, DefenseGreater
     1,1,1,1,1,    # Silcoon, Cascoon, Ninjask, Shedinja, Beauty
     2,2,2,2,3,    # ItemMale, ItemFemale, DayHoldItem, NightHoldItem, HasMove
     4,1,1,1,4,    # HasInParty, LevelMale, LevelFemale, Location, TradeSpecies
     1,1,1,1,1,1,1 # Custom 1-7
  ]
end

class SpriteMetafile
  VIEWPORT      = 0
  TONE          = 1
  SRC_RECT      = 2
  VISIBLE       = 3
  X             = 4
  Y             = 5
  Z             = 6
  OX            = 7
  OY            = 8
  ZOOM_X        = 9
  ZOOM_Y        = 10
  ANGLE         = 11
  MIRROR        = 12
  BUSH_DEPTH    = 13
  OPACITY       = 14
  BLEND_TYPE    = 15
  COLOR         = 16
  FLASHCOLOR    = 17
  FLASHDURATION = 18
  BITMAP        = 19

  def length
    return @metafile.length
  end

  def [](i)
    return @metafile[i]
  end

  def initialize(viewport=nil)
    @metafile=[]
    @values=[
       viewport,
       Tone.new(0,0,0,0),Rect.new(0,0,0,0),
       true,
       0,0,0,0,0,100,100,
       0,false,0,255,0,
       Color.new(0,0,0,0),Color.new(0,0,0,0),
       0
    ]
  end

  def disposed?
    return false
  end

  def dispose
  end

  def flash(color,duration)
    if duration>0
      @values[FLASHCOLOR]=color.clone
      @values[FLASHDURATION]=duration
      @metafile.push([FLASHCOLOR,color])
      @metafile.push([FLASHDURATION,duration])
    end
  end

  def x
    return @values[X]
  end

  def x=(value)
    @values[X]=value
    @metafile.push([X,value])
  end

  def y
    return @values[Y]
  end

  def y=(value)
    @values[Y]=value
    @metafile.push([Y,value])
  end

  def bitmap
    return nil
  end

  def bitmap=(value)
    if value && !value.disposed?
      @values[SRC_RECT].set(0,0,value.width,value.height)
      @metafile.push([SRC_RECT,@values[SRC_RECT].clone])
    end
  end

  def src_rect
    return @values[SRC_RECT]
  end

  def src_rect=(value)
    @values[SRC_RECT]=value
   @metafile.push([SRC_RECT,value])
 end

  def visible
    return @values[VISIBLE]
  end

  def visible=(value)
    @values[VISIBLE]=value
    @metafile.push([VISIBLE,value])
  end

  def z
    return @values[Z]
  end

  def z=(value)
    @values[Z]=value
    @metafile.push([Z,value])
  end

  def ox
    return @values[OX]
  end

  def ox=(value)
    @values[OX]=value
    @metafile.push([OX,value])
  end

  def oy
    return @values[OY]
  end

  def oy=(value)
    @values[OY]=value
    @metafile.push([OY,value])
  end

  def zoom_x
    return @values[ZOOM_X]
  end

  def zoom_x=(value)
    @values[ZOOM_X]=value
    @metafile.push([ZOOM_X,value])
  end

  def zoom_y
    return @values[ZOOM_Y]
  end

  def zoom_y=(value)
    @values[ZOOM_Y]=value
    @metafile.push([ZOOM_Y,value])
  end

  def angle
    return @values[ANGLE]
  end

  def zoom=(value)
    @values[ZOOM_X]=value
    @metafile.push([ZOOM_X,value])
    @values[ZOOM_Y]=value
    @metafile.push([ZOOM_Y,value])
  end   
  
  def angle=(value)
    @values[ANGLE]=value
    @metafile.push([ANGLE,value])
  end

  def mirror
    return @values[MIRROR]
  end

  def mirror=(value)
    @values[MIRROR]=value
    @metafile.push([MIRROR,value])
  end

  def bush_depth
    return @values[BUSH_DEPTH]
  end

  def bush_depth=(value)
    @values[BUSH_DEPTH]=value
    @metafile.push([BUSH_DEPTH,value])
  end

  def opacity
    return @values[OPACITY]
  end

  def opacity=(value)
    @values[OPACITY]=value
    @metafile.push([OPACITY,value])
  end

  def blend_type
    return @values[BLEND_TYPE]
  end

  def blend_type=(value)
    @values[BLEND_TYPE]=value
    @metafile.push([BLEND_TYPE,value])
  end

  def color
    return @values[COLOR]
  end

  def color=(value)
    @values[COLOR]=value.clone
    @metafile.push([COLOR,@values[COLOR]])
  end

  def tone
    return @values[TONE]
  end

  def tone=(value)
    @values[TONE]=value.clone
    @metafile.push([TONE,@values[TONE]])
  end

  def update
    @metafile.push([-1,nil])
  end
end

class SpriteMetafilePlayer
  def initialize(metafile,sprite=nil)
    @metafile=metafile
    @sprites=[]
    @playing=false
    @index=0
    @sprites.push(sprite) if sprite
  end

  def add(sprite)
    @sprites.push(sprite)
  end

  def playing?
    return @playing
  end

  def play
    @playing=true
    @index=0
  end

  def update
    if @playing
      for j in @index...@metafile.length
        @index=j+1
        break if @metafile[j][0]<0
        code=@metafile[j][0]
        value=@metafile[j][1]
        for sprite in @sprites
          case code
            when SpriteMetafile::X
              sprite.x=value
            when SpriteMetafile::Y
              sprite.y=value
            when SpriteMetafile::OX
              sprite.ox=value
            when SpriteMetafile::OY
              sprite.oy=value
            when SpriteMetafile::ZOOM_X
              sprite.zoom_x=value
            when SpriteMetafile::ZOOM_Y
              sprite.zoom_y=value
            when SpriteMetafile::SRC_RECT
              sprite.src_rect=value
            when SpriteMetafile::VISIBLE
              sprite.visible=value
            when SpriteMetafile::Z
              sprite.z=value
            # prevent crashes
            when SpriteMetafile::ANGLE
              sprite.angle=(value==180) ? 179.9 : value
            when SpriteMetafile::MIRROR
              sprite.mirror=value
            when SpriteMetafile::BUSH_DEPTH
              sprite.bush_depth=value
            when SpriteMetafile::OPACITY
              sprite.opacity=value
            when SpriteMetafile::BLEND_TYPE
              sprite.blend_type=value
            when SpriteMetafile::COLOR
              sprite.color=value
            when SpriteMetafile::TONE
              sprite.tone=value
          end
        end
      end
      @playing=false if @index==@metafile.length
    end
  end
end

#####################

class PokemonEvolutionScene
  def pbGenerateMetafiles(s1x,s1y,s2x,s2y)
    sprite=SpriteMetafile.new
    sprite2=SpriteMetafile.new
    sprite.opacity=255
    sprite2.opacity=255
    sprite2.zoom=0.0
    sprite.ox=s1x
    sprite.oy=s1y
    sprite2.ox=s2x
    sprite2.oy=s2y
    alpha=0
    for j in 0...26
      sprite.color.red=255
      sprite.color.green=255 
      sprite.color.blue=255
      sprite.color.alpha=alpha
      sprite.color=sprite.color
      sprite2.color=sprite.color
      sprite2.color.alpha=255
      sprite.update
      sprite2.update
      alpha+=5
    end
    totaltempo=0
    currenttempo=25
    maxtempo=280
    while totaltempo<maxtempo
      for j in 0...currenttempo
        if alpha<255
          sprite.color.red=255
          sprite.color.green=255 
          sprite.color.blue=255
          sprite.color.alpha=alpha
          sprite.color=sprite.color
          alpha+=10
        end
        sprite.zoom=[1.1*(currenttempo-j-1)/currenttempo,1.0].min
        sprite2.zoom=[1.1*(j+1)/currenttempo,1.0].min
        sprite.update
        sprite2.update
      end
      totaltempo+=currenttempo
      if totaltempo+currenttempo<maxtempo
        for j in 0...currenttempo
          sprite.zoom=[1.1*(j+1)/currenttempo,1.0].min
          sprite2.zoom=[1.1*(currenttempo-j-1)/currenttempo,1.0].min
          sprite.update
          sprite2.update
        end
      end
      totaltempo+=currenttempo
      currenttempo=[(currenttempo/1.5).floor,5].max
    end
    @metafile1=sprite
    @metafile2=sprite2
  end

  def pbSaveSpriteState(sprite)
    state=[]
    return state if !sprite || sprite.disposed?
    state[SpriteMetafile::BITMAP]     = sprite.x
    state[SpriteMetafile::X]          = sprite.x
    state[SpriteMetafile::Y]          = sprite.y
    state[SpriteMetafile::SRC_RECT]   = sprite.src_rect.clone
    state[SpriteMetafile::VISIBLE]    = sprite.visible
    state[SpriteMetafile::Z]          = sprite.z
    state[SpriteMetafile::OX]         = sprite.ox
    state[SpriteMetafile::OY]         = sprite.oy
    state[SpriteMetafile::ZOOM_X]     = sprite.zoom_x
    state[SpriteMetafile::ZOOM_Y]     = sprite.zoom_y
    state[SpriteMetafile::ANGLE]      = sprite.angle
    state[SpriteMetafile::MIRROR]     = sprite.mirror
    state[SpriteMetafile::BUSH_DEPTH] = sprite.bush_depth
    state[SpriteMetafile::OPACITY]    = sprite.opacity
    state[SpriteMetafile::BLEND_TYPE] = sprite.blend_type
    state[SpriteMetafile::COLOR]      = sprite.color.clone
    state[SpriteMetafile::TONE]       = sprite.tone.clone
    return state
  end
  
  def pbRestoreSpriteState(sprite,state)
    return if !state || !sprite || sprite.disposed?
    sprite.x          = state[SpriteMetafile::X]
    sprite.y          = state[SpriteMetafile::Y]
    sprite.src_rect   = state[SpriteMetafile::SRC_RECT]
    sprite.visible    = state[SpriteMetafile::VISIBLE]
    sprite.z          = state[SpriteMetafile::Z]
    sprite.ox         = state[SpriteMetafile::OX]
    sprite.oy         = state[SpriteMetafile::OY]
    sprite.zoom_x     = state[SpriteMetafile::ZOOM_X]
    sprite.zoom_y     = state[SpriteMetafile::ZOOM_Y]
    sprite.angle      = state[SpriteMetafile::ANGLE]
    sprite.mirror     = state[SpriteMetafile::MIRROR]
    sprite.bush_depth = state[SpriteMetafile::BUSH_DEPTH]
    sprite.opacity    = state[SpriteMetafile::OPACITY]
    sprite.blend_type = state[SpriteMetafile::BLEND_TYPE]
    sprite.color      = state[SpriteMetafile::COLOR]
    sprite.tone       = state[SpriteMetafile::TONE]
  end
  
  def pbSaveSpriteStateAndBitmap(sprite)
    return [] if !sprite || sprite.disposed?
    state=pbSaveSpriteState(sprite)
    state[SpriteMetafile::BITMAP]=sprite.bitmap
    return state
  end
  
  def pbRestoreSpriteStateAndBitmap(sprite,state)
    return if !state || !sprite || sprite.disposed?
    sprite.bitmap=state[SpriteMetafile::BITMAP]
    pbRestoreSpriteState(sprite,state)
    return state
  end

  # Starts the evolution screen with the given Pokemon and new Pokemon species.

  def pbUpdate(animating=false)
    if animating      # Pokémon shouldn't animate during the evolution animation
      @sprites["background"].update
    else
      pbUpdateSpriteHash(@sprites)
    end
  end

  def pbUpdateNarrowScreen
    if @bgviewport.rect.y<20*4
      @bgviewport.rect.height-=2*4
      if @bgviewport.rect.height<Graphics.height-64
        @bgviewport.rect.y+=4
        @sprites["background"].oy=@bgviewport.rect.y
      end
    end
  end

  def pbUpdateExpandScreen
    if @bgviewport.rect.y>0
      @bgviewport.rect.y-=4
      @sprites["background"].oy=@bgviewport.rect.y
    end
    if @bgviewport.rect.height<Graphics.height
      @bgviewport.rect.height+=2*4
    end
  end

  def pbFlashInOut(canceled,oldstate,oldstate2)
    tone=0
    loop do
      Graphics.update
      pbUpdate(true)
      pbUpdateExpandScreen
      tone+=10
      @viewport.tone.set(tone,tone,tone,0)
      break if tone>=255
    end
    @bgviewport.rect.y=0
    @bgviewport.rect.height=Graphics.height
    @sprites["background"].oy=0
    if canceled
      pbRestoreSpriteState(@sprites["rsprite1"],oldstate)
      pbRestoreSpriteState(@sprites["rsprite2"],oldstate2)
      @sprites["rsprite1"].visible=true
      @sprites["rsprite1"].zoom_x=1.0
      @sprites["rsprite1"].zoom_y=1.0
      @sprites["rsprite1"].color.alpha=0
      @sprites["rsprite2"].visible=false
    else
      @sprites["rsprite1"].visible=false
      @sprites["rsprite2"].visible=true
      @sprites["rsprite2"].zoom_x=1.0
      @sprites["rsprite2"].zoom_y=1.0
      @sprites["rsprite2"].color.alpha=0
    end
    10.times do
      Graphics.update
      pbUpdate(true)
    end
    tone=255
    loop do
      Graphics.update
      pbUpdate
      tone=[tone-20,0].max
      @viewport.tone.set(tone,tone,tone,0)
      break if tone<=0
    end
  end  
  
  def pbStartScreen(pokemon,newspecies)
    @sprites={}
    @bgviewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @bgviewport.z=99999    
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @pokemon=pokemon
    @newspecies=newspecies
    addBackgroundOrColoredPlane(@sprites,"background","evolutionbg",
       Color.new(248,248,248),@bgviewport)
    rsprite1=PokemonSprite.new(@viewport)
    rsprite2=PokemonSprite.new(@viewport)
    rsprite1.setPokemonBitmap(@pokemon,false)
    rsprite2.setPokemonBitmapSpecies(@pokemon,@newspecies,false)
    rsprite1.ox=rsprite1.bitmap.width/2
    rsprite1.oy=rsprite1.bitmap.height/2
    rsprite2.ox=rsprite2.bitmap.width/2
    rsprite2.oy=rsprite2.bitmap.height/2
    rsprite1.x=Graphics.width/2
    rsprite1.y=(Graphics.height-64)/2
    rsprite2.x=rsprite1.x
    rsprite2.y=rsprite1.y
    rsprite2.opacity=0
    @sprites["rsprite1"]=rsprite1
    @sprites["rsprite2"]=rsprite2
    pbGenerateMetafiles(rsprite1.ox,rsprite1.oy,rsprite2.ox,rsprite2.oy)
    @sprites["msgwindow"]=Kernel.pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)
  end

  # Closes the evolution screen.
  def pbEndScreen
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"])
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  # Opens the evolution screen
  def pbEvolution(cancancel=true)
    pbBGMStop()
    pbBGMPlay("Evolution")
    metaplayer1=SpriteMetafilePlayer.new(@metafile1,@sprites["rsprite1"])
    metaplayer2=SpriteMetafilePlayer.new(@metafile2,@sprites["rsprite2"])
    metaplayer1.play
    metaplayer2.play
    
    pbPlayCry(@pokemon)
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
       _INTL("\\se[]What?\r\n{1} is evolving!\\^",@pokemon.name))
    Kernel.pbMessageWaitForInput(@sprites["msgwindow"],100,true)
    pbPlayDecisionSE()
    oldstate=pbSaveSpriteState(@sprites["rsprite1"])
    oldstate2=pbSaveSpriteState(@sprites["rsprite2"])
    
    if isConst?(@pokemon.species, PBSpecies, :INKAY)
      canceled=true
    else  
      canceled=false
    end
    begin
      pbUpdateNarrowScreen      
      metaplayer1.update
      metaplayer2.update
      Graphics.update
      Input.update
      pbUpdate(true)
      if Input.trigger?(Input::B) && cancancel
        if isConst?(@pokemon.species, PBSpecies, :INKAY)
          canceled=false
        else  
          canceled=true
          pbRestoreSpriteState(@sprites["rsprite1"],oldstate)
          pbRestoreSpriteState(@sprites["rsprite2"],oldstate2)
          Graphics.update
          break
        end
      end
    end while metaplayer1.playing? && metaplayer2.playing?
    pbFlashInOut(canceled,oldstate,oldstate2)    
    if canceled
      if isConst?(@pokemon.species, PBSpecies, :INKAY)
        pbRestoreSpriteState(@sprites["rsprite1"],oldstate)
        pbRestoreSpriteState(@sprites["rsprite2"],oldstate2)
        Graphics.update
      end
      pbPlayCancelSE()
      Kernel.pbMessageDisplay(@sprites["msgwindow"],
         _INTL("Huh?\r\n{1} stopped evolving!",@pokemon.name))
      pbBGMStop()
      
    else
      removeItem=false
      createSpecies=pbCheckEvolutionEx(@pokemon){|pokemon,evonib,level,poke|
        if evonib==14 # Shedinja
          if $PokemonBag.pbQuantity(PBItems::POKEBALL)>0
            next poke
          end
          next -1
        elsif evonib==6 || evonib==18 || evonib==19 # Evolves if traded with item/holding item
          if poke==@newspecies
            removeItem=true  # Item is now consumed
          end
          next -1
        else
          next -1
        end
      }
      newspeciesname=PBSpecies.getName(@newspecies)
      oldspeciesname=PBSpecies.getName(@pokemon.species)
      @pokemon.species=@newspecies
      frames=pbCryFrameLength(@pokemon)
       
      pbPlayCry(@pokemon)
      frames.times do
        Graphics.update
      end
      Kernel.pbMessageDisplay(@sprites["msgwindow"],
         _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]",@pokemon.name,newspeciesname))
      @sprites["msgwindow"].text=""
      @pokemon.item=0 if removeItem
      $Trainer.seen[@newspecies]=true
      $Trainer.owned[@newspecies]=true
      pbSeenForm(@pokemon)
      @pokemon.name=newspeciesname if @pokemon.name==oldspeciesname
      @pokemon.calcStats
      # Check moves for new species
      movelist=@pokemon.getMoveList
      shedinjamoves=@pokemon.moves.clone      
      for i in movelist
        if i[0]==0 || i[0]==@pokemon.level          # Learned a new move
          pbLearnMove(@pokemon,i[1],true)
        end
      end
      if createSpecies>0 && $Trainer.party.length<6
        newpokemon=@pokemon.clone
        newpokemon.moves=shedinjamoves
        newpokemon.iv=@pokemon.iv.clone
        newpokemon.ev=@pokemon.ev.clone
        newpokemon.species=createSpecies
        newpokemon.name=PBSpecies.getName(createSpecies)
        newpokemon.setItem(0)
        newpokemon.itemInitial=0
        #newpokemon.clearAllRibbons
        newpokemon.markings=0
        newpokemon.ballused=0
        newpokemon.calcStats
        newpokemon.heal
        $Trainer.party.push(newpokemon)
        $Trainer.seen[createSpecies]=true
        $Trainer.owned[createSpecies]=true
        pbSeenForm(newpokemon)
        $PokemonBag.pbDeleteItem(PBItems::POKEBALL)
      end
    end
  end
end

def pbMiniCheckEvolution(pokemon,evonib,level,poke)  
  marowakMaps=[152,552]
  crabominableMaps=[364,366,373,374,375,376,377,378,379,380,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,401,402,403,430,431,432,433,434,435,436,439,440,441,442,457,458,459,460,461,462,463,464]
  magneticMaps=[197,198,281]
  koffingMaps=[]
  mrmimeMaps=[]
  case evonib
    when PBEvolution::Happiness
      return poke if pokemon.happiness>=220
    when PBEvolution::HappinessDay
      return poke if pokemon.happiness>=220 && PBDayNight.isDay?(pbGetTimeNow)
    when PBEvolution::HappinessNight
      return poke if pokemon.happiness>=220 && PBDayNight.isNight?(pbGetTimeNow)
    when PBEvolution::Level  
      case pokemon.species
        when 104            # Cubone -> Marowak forms
          if PBDayNight.isNight?(pbGetTimeNow) || marowakMaps.include?($game_map.map_id)
            pokemon.form=1
          elsif PBDayNight.isDay?(pbGetTimeNow)
            pokemon.form=0
          end  
        when 109            # Koffing -> Weezing forms
          if koffingMaps.include?($game_map.map_id)
            pokemon.form=1
          else
            pokemon.form=0
          end 
        when 744            # Rockruff -> Lycanroc forms
          if PBDayNight.isDusk?(pbGetTimeNow)
            pokemon.form=2
          elsif PBDayNight.isNight?(pbGetTimeNow)
            pokemon.form=1
          elsif PBDayNight.isDay?(pbGetTimeNow)
            pokemon.form=0
          end
      end            
      return poke if pokemon.level>=level
    when PBEvolution::Trade, PBEvolution::TradeItem
      return -1
    when PBEvolution::AttackGreater # Hitmonlee
      return poke if pokemon.level>=level && pokemon.attack>pokemon.defense
    when PBEvolution::AtkDefEqual # Hitmontop
      return poke if pokemon.level>=level && pokemon.attack==pokemon.defense
    when PBEvolution::DefenseGreater # Hitmonchan
      return poke if pokemon.level>=level && pokemon.attack<pokemon.defense
    when PBEvolution::Silcoon
      return poke if pokemon.level>=level && (((pokemon.personalID>>16)&0xFFFF)%10)<5
    when PBEvolution::Cascoon
      return poke if pokemon.level>=level && (((pokemon.personalID>>16)&0xFFFF)%10)>=5
    when PBEvolution::Ninjask
      return poke if pokemon.level>=level
    when PBEvolution::Shedinja
      return -1
    when PBEvolution::Beauty # Feebas
      # as of e19a, this method doesn't work and has been removed from our PBS
      #return poke if pokemon.beauty>=level 
    when PBEvolution::DayHoldItem
      return poke if pokemon.item==level && PBDayNight.isDay?(pbGetTimeNow)
    when PBEvolution::NightHoldItem
      return poke if pokemon.item==level && PBDayNight.isNight?(pbGetTimeNow)
    when PBEvolution::HasMove
      case pokemon.species
        when 439            # Mime Jr -> Mr Mime forms
          if mrmimeMaps.include?($game_map.map_id)
            pokemon.form=1
          else
            pokemon.form=0
          end 
      end
      for i in 0...4
        return poke if pokemon.moves[i].id==level
      end
    when PBEvolution::HasInParty
      for i in $Trainer.party
        return poke if !i.isEgg? && i.species==level
      end
    when PBEvolution::LevelMale
      return poke if pokemon.level>=level && pokemon.isMale?
    when PBEvolution::LevelFemale
      return poke if pokemon.level>=level && pokemon.isFemale?
    when PBEvolution::Location
      if pokemon.species==PBSpecies::CRABRAWLER
        if crabominableMaps.include?($game_map.map_id)
          return poke
        end
      end   
      if pokemon.species==PBSpecies::MAGNETON || pokemon.species==PBSpecies::NOSEPASS || pokemon.species==PBSpecies::CHARJABUG
        if magneticMaps.include?($game_map.map_id)
          return poke
        end
      end     
      return poke if $game_map.map_id==level
    when PBEvolution::TradeSpecies
      return -1
    when PBEvolution::BadInfluence
       for i in $Trainer.party
        return poke if !i.egg? && (i.type1==17 || i.type2==17) && pokemon.level>=level
      end
    when PBEvolution::Affection
       for i in 0...4
        return poke if pokemon.happiness>=220 && pokemon.moves[i].type==level
      end
    when PBEvolution::LevelRain
   return poke if pokemon.level>=level && ($game_screen.weather_type==1 ||
     $game_screen.weather_type== 2 || $game_screen.weather_type== 6)    
    when PBEvolution::LevelDay
      return poke if pokemon.level>=level && PBDayNight.isDay?(pbGetTimeNow)
    when PBEvolution::LevelNight
      return poke if pokemon.level>=level && PBDayNight.isNight?(pbGetTimeNow)
    when PBEvolution::Custom6
      # Add code for custom evolution type 6
    when PBEvolution::Custom7
      # Add code for custom evolution type 7
  end
  return -1
end

def pbMiniCheckEvolutionItem(pokemon,evonib,level,poke,item)
  # Checks for when an item is used on the Pokémon (e.g. an evolution stone)
  exeggutorMaps=[15,16,17,18,19,20,21,22,23,25,26,27,30,31,32,33,34,35,199,200,201,202,203,204,205,562,563,564,565,566,567,568]
  raichuMaps=[15,16,17,18,19,20,21,22,23,25,26,27,30,31,32,33,34,35,199,200,201,202,203,204,205,206,207,208,536,538,547,553,556,558,562,563,564,565,566,567,568,569,574,575,576,577,578,579,586,601,603,604,605]
  case evonib
    when PBEvolution::Item  
      case pokemon.species
        when 25             # Pikachu -> Raichu forms
          if raichuMaps.include?($game_map.map_id)
            pokemon.form=1
          else
            pokemon.form=0
          end             
        when 102            # Exeggcute -> Exeggutor forms
          if exeggutorMaps.include?($game_map.map_id)
            pokemon.form=1
          else
            pokemon.form=0
          end   
      end            
      return poke if level==item
    when PBEvolution::ItemMale
      return poke if level==item && pokemon.isMale?
    when PBEvolution::ItemFemale
      return poke if level==item && pokemon.isFemale?
    when PBEvolution::TradeItem || PBEvolution::Trade
      return poke if level==item
  end
  return -1
end

# Checks whether a Pokemon can evolve now. If a block is given, calls the block
# with the following parameters:
#  Pokemon to check; evolution type; level or other parameter; ID of the new Pokemon species
def pbCheckEvolutionEx(pokemon)
  return -1 if pokemon.species<=0 || pokemon.isEgg?
  return -1 if pokemon.item == PBItems::EVERSTONE
  return -1 if pokemon.item == PBItems::EVIOLITE
  return -1 if pokemon.item == PBItems::EEVIUMZ2
  ret=-1
  for form in pbGetEvolvedFormData(pokemon.species,pokemon)
    ret=yield pokemon,form[1],form[2],form[0]
    break if ret>0
  end
  return ret
end

# Checks whether a Pokemon can evolve now. If an item is used on the Pokémon,
# checks whether the Pokemon can evolve with the given item.
def pbCheckEvolution(pokemon,item=0)
  if item==0
    return pbCheckEvolutionEx(pokemon){|pokemon,evonib,level,poke|
       next pbMiniCheckEvolution(pokemon,evonib,level,poke)
    }
  else
    return pbCheckEvolutionEx(pokemon){|pokemon,evonib,level,poke|
       next pbMiniCheckEvolutionItem(pokemon,evonib,level,poke,item)
    }
  end
end

def pbGetEvolvedFormData(species,pokemon=nil)
  ret=[]
  # Alternate evo methods for forms 
  if pokemon!=nil
    name = pokemon.getFormName
	  formcheck = PokemonForms.dig(pokemon.species,name,:GetEvo)
    if formcheck!=nil
      return formcheck
    end
  end
  return $cache.pkmn_evo[species]
end

def pbGetPreviousForm(species)
  if !$cache.pkmn_evo[species-1].empty? #quick check for most common case
    return species-1 if $cache.pkmn_evo[species-1][0][0] == species
  end
  for mon in 1...$cache.pkmn_evo.length # Yeah we're checking every pokemon, and you know what? You can't stop me.
    next if $cache.pkmn_evo[mon].empty?
    for method in 0...$cache.pkmn_evo[mon].length
      return mon if $cache.pkmn_evo[mon][method][0] == species
    end
  end
  return species
end

def pbGetBabySpecies(species)
  return species if species==1
  ret=species
  if !$cache.pkmn_evo[species-1].empty? #quick check for most common case
    ret = species-1 if $cache.pkmn_evo[species-1][0][0] == species
  end
  if ret==species
    for mon in 1...$cache.pkmn_evo.length # Yeah we're checking every pokemon, and you know what? You can't stop me.
      next if $cache.pkmn_evo[mon].empty?
      for method in 0...$cache.pkmn_evo[mon].length
        ret = mon if $cache.pkmn_evo[mon][method][0] == species
      end
    end
  end
  if ret!=species
    ret=pbGetBabySpecies(ret)
  end
  return ret
end

def pbGetLessBabySpecies(species)
  if !$cache.pkmn_evo[species-1].empty? #quick check for most common case
    return species-1 if $cache.pkmn_evo[species-1][0][0] == species
  end
  for mon in 1...$cache.pkmn_evo.length # Yeah we're checking every pokemon, and you know what? You can't stop me.
    next if $cache.pkmn_evo[mon].empty?
    for method in 0...$cache.pkmn_evo[mon].length
      return mon if $cache.pkmn_evo[mon][method][0] == species
    end
  end
  return species
end