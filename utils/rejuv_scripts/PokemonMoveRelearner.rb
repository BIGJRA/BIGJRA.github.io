def pbEachNaturalMove(pokemon)
  movelist=pokemon.getMoveList
  for i in movelist
    yield i[1],i[0]
  end
end

def pbGetBabyMoves(pokemon, babyspecies)
  emoves = []

  egg=PokeBattle_Pokemon.new(babyspecies,EGGINITIALLEVEL,nil)
  egg.form = pokemon.form unless egg.species == 479 # New form inheriting

  formcheck = MultipleForms.call("getEggMoves",egg)
  if formcheck!=nil
    for move in formcheck
    atk = getID(PBMoves,move)
      emoves.push(atk) if !pokemon.knowsMove?(atk)
    end
  else
  pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
     f.pos=(babyspecies-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
       atk = f.fgetw
       emoves.push(atk) if !pokemon.knowsMove?(atk)

       i+=1
       end
     end
  }
  end
  # Volt Tackle
  if isConst?(pokemon.species,PBSpecies,:PICHU) || isConst?(pokemon.species,PBSpecies,:PIKACHU) || isConst?(pokemon.species,PBSpecies,:RAICHU)
    move = getConst(PBMoves,:VOLTTACKLE)
    emoves.push(move) if !pokemon.knowsMove?(move)
  end

  return emoves
end

#DemICE>>  all this for fucking strength sap
def pbGetBabyCompatibleMoves(pokemon, babyspecies)
  emoves = []

  egg=PokeBattle_Pokemon.new(babyspecies,EGGINITIALLEVEL,nil)
  egg.form = pokemon.form unless egg.species == 479 # New form inheriting

  formcheck = MultipleForms.call("getEggMoves",egg)
  if formcheck!=nil
    for move in formcheck
    atk = getID(PBMoves,move)
      emoves.push(atk) #if !pokemon.knowsMove?(atk)
    end
  else
  pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
     f.pos=(babyspecies-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
       atk = f.fgetw
       emoves.push(atk) #if !pokemon.knowsMove?(atk)

       i+=1
       end
     end
  }
  end
  # Volt Tackle
  if isConst?(pokemon.species,PBSpecies,:PICHU) || isConst?(pokemon.species,PBSpecies,:PIKACHU) || isConst?(pokemon.species,PBSpecies,:RAICHU)
    move = getConst(PBMoves,:VOLTTACKLE)
    emoves.push(move) #if !pokemon.knowsMove?(move)
  end

  return emoves
end
#>>DemICE

def pbHasRelearnableMove?(pokemon)
  return pbGetRelearnableMoves(pokemon).length>0
end

def pbGetRelearnableMoves(pokemon)
  return [] if !pokemon || pokemon.isEgg? || (pokemon.isShadow? rescue false)
  moves=[]

  pbEachNaturalMove(pokemon){|move,level|
     if level<=pokemon.level && !pokemon.knowsMove?(move)
       moves.push(move) if !moves.include?(move)
     end
  }
  tmoves=[]
  if pokemon.firstmoves
    for i in pokemon.firstmoves
      tmoves.push(i) if !pokemon.knowsMove?(i) && !moves.include?(i)
    end
  end
  # Egg moves
  baby = pbGetBabySpecies(pokemon.species)
  if isConst?(baby,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    baby=getConst(PBSpecies,:PHIONE)
  end
  emoves = pbGetBabyMoves(pokemon, baby)
  babyOld = baby
  baby = pbGetNonIncenseLowestSpecies(baby)
  if baby != babyOld
    emoves = emoves+pbGetBabyMoves(pokemon, baby)
  end
  baby = pbGetBabySpecies(pokemon.species)
  if isConst?(baby,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    baby=getConst(PBSpecies,:PHIONE)
  end
  emoves = pbGetBabyMoves(pokemon, baby)
  babyOld = baby
  baby = pbGetNonIncenseLowestSpecies(baby)
  if baby != babyOld
    emoves = emoves+pbGetBabyMoves(pokemon, baby)
  end
  moves=tmoves+moves
  if $game_switches[873] && $PokemonBag.pbHasItem?(:HM02)
    moves=tmoves+emoves+moves
  end
  return moves|[] # remove duplicates
end

#DemICE>> checking for if a mon is compatible with a move including learned ones  (for removing illegal moves like that Strength Sap)
def pbGetCompatibleMoves(pokemon)
  return [] if !pokemon || pokemon.isEgg? || (pokemon.isShadow? rescue false)
  moves=[]

  pbEachNaturalMove(pokemon){|move,level|
     if level<=pokemon.level #&& !pokemon.knowsMove?(move)
       moves.push(move) if !moves.include?(move)
     end
  }
  tmoves=[]
  if pokemon.firstmoves
    for i in pokemon.firstmoves
      tmoves.push(i) if !pokemon.knowsMove?(i) && !moves.include?(i)
    end
  end
  # Egg moves
  baby = pbGetBabySpecies(pokemon.species)
  if isConst?(baby,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    baby=getConst(PBSpecies,:PHIONE)
  end
  emoves = pbGetBabyCompatibleMoves(pokemon, baby)
  babyOld = baby
  baby = pbGetNonIncenseLowestSpecies(baby)
  if baby != babyOld
    emoves = emoves+pbGetBabyCompatibleMoves(pokemon, baby)
  end
  baby = pbGetBabySpecies(pokemon.species)
  if isConst?(baby,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    baby=getConst(PBSpecies,:PHIONE)
  end
  emoves = pbGetBabyCompatibleMoves(pokemon, baby)
  babyOld = baby
  baby = pbGetNonIncenseLowestSpecies(baby)
  if baby != babyOld
    emoves = emoves+pbGetBabyCompatibleMoves(pokemon, baby)
  end
  moves=tmoves+moves
  if $game_switches[873] && $PokemonBag.pbHasItem?(:HM02)
    moves=tmoves+emoves+moves
  end
  return moves|[] # remove duplicates
end
#>>DemICE

################################################################################
# Scene class for handling appearance of the screen
################################################################################
class MoveRelearnerScene
  VISIBLEMOVES = 4

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { pbUpdate }
  end

# Update the scene here, this is called once each frame
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(pokemon,moves)
    @pokemon=pokemon
    @moves=moves
    moveCommands=[]
    moves.each{|i| moveCommands.push(PBMoves.getName(i)) }
    # Create sprite hash
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    addBackgroundPlane(@sprites,"bg","reminderbg",@viewport)
    @sprites["pokeicon"]=PokemonIconSprite.new(@pokemon,@viewport)
    @sprites["pokeicon"].x=288
    @sprites["pokeicon"].y=44
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/reminderSel")
    @sprites["background"].y=78
    @sprites["background"].src_rect=Rect.new(0,72,258,72)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["commands"]=Window_CommandPokemon.new(moveCommands,32)
    @sprites["commands"].x=Graphics.width
    @sprites["commands"].height=32*(VISIBLEMOVES+1)
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=false
    @sprites["msgwindow"].viewport=@viewport
    @typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    pbDrawMoveList
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbDrawMoveList
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    textpos=[]
    imagepos=[]
    type1rect=Rect.new(0,@pokemon.type1*28,64,28)
    type2rect=Rect.new(0,@pokemon.type2*28,64,28)
    if @pokemon.type1==@pokemon.type2
      overlay.blt(400,70,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(366,70,@typebitmap.bitmap,type1rect)
      overlay.blt(436,70,@typebitmap.bitmap,type2rect)
    end
    textpos=[
       [_INTL("Teach which move?"),16,8,0,Color.new(88,88,80),Color.new(168,184,184)]
    ]
    yPos=82
    for i in 0...VISIBLEMOVES
      moveobject=@moves[@sprites["commands"].top_item+i]
      if moveobject
        movedata=PBMoveData.new(moveobject)
        if movedata
          imagepos.push(["Graphics/Pictures/types",12,yPos+2,0,
             movedata.type*28,64,28])
          textpos.push([PBMoves.getName(moveobject),80,yPos,0,
             Color.new(248,248,248),Color.new(0,0,0)])
          if movedata.totalpp>0
            textpos.push([_INTL("PP"),112,yPos+32,0,
               Color.new(64,64,64),Color.new(176,176,176)])
            textpos.push([_ISPRINTF("{1:d}/{2:d}",
               movedata.totalpp,movedata.totalpp),230,yPos+32,1,
               Color.new(64,64,64),Color.new(176,176,176)])
          end
        else
          textpos.push(["-",80,yPos,0,Color.new(64,64,64),Color.new(176,176,176)])
          textpos.push(["--",228,yPos+32,1,Color.new(64,64,64),Color.new(176,176,176)])
        end
      end
      yPos+=64
    end
    imagepos.push(["Graphics/Pictures/reminderSel",
       0,78+(@sprites["commands"].index-@sprites["commands"].top_item)*64,
       0,0,258,72])
    selmovedata=PBMoveData.new(@moves[@sprites["commands"].index])
    basedamage=selmovedata.basedamage
    category=selmovedata.category
    accuracy=selmovedata.accuracy
    textpos.push([_INTL("CATEGORY"),272,114,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([_INTL("POWER"),272,146,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([basedamage<=1 ? basedamage==1 ? "???" : "---" : sprintf("%d",basedamage),
          468,146,2,Color.new(64,64,64),Color.new(176,176,176)])
    textpos.push([_INTL("ACCURACY"),272,178,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([accuracy==0 ? "---" : sprintf("%d",accuracy),
          468,178,2,Color.new(64,64,64),Color.new(176,176,176)])
    pbDrawTextPositions(overlay,textpos)
    imagepos.push(["Graphics/Pictures/category",436,116,0,category*28,64,28])
    if @sprites["commands"].index<@moves.length-1
      imagepos.push(["Graphics/Pictures/reminderButtons",48,350,0,0,76,32])
    end
    if @sprites["commands"].index>0
      imagepos.push(["Graphics/Pictures/reminderButtons",134,350,76,0,76,32])
    end
    pbDrawImagePositions(overlay,imagepos)
    drawTextEx(overlay,272,210,238,5,
       pbGetMessage(MessageTypes::MoveDescriptions,@moves[@sprites["commands"].index]),
       Color.new(64,64,64),Color.new(176,176,176))
  end

# Processes the scene
  def pbChooseMove
    oldcmd=-1
    pbActivateWindow(@sprites,"commands"){
       loop do
         oldcmd=@sprites["commands"].index
         Graphics.update
         Input.update
         pbUpdate
         if @sprites["commands"].index!=oldcmd
           @sprites["background"].x=0
           @sprites["background"].y=78+(@sprites["commands"].index-@sprites["commands"].top_item)*64
           pbDrawMoveList
         end
         if Input.trigger?(Input::B)
           return 0
         end
         if Input.trigger?(Input::C)
           return @moves[@sprites["commands"].index]
         end
       end
    }
  end

# End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate } # Fade out all sprites
    pbDisposeSpriteHash(@sprites) # Dispose all sprites
    @typebitmap.dispose
    @viewport.dispose # Dispose the viewport
  end
end



# Screen class for handling game logic
class MoveRelearnerScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(pokemon)
    moves=pbGetRelearnableMoves(pokemon)
    @scene.pbStartScene(pokemon,moves)
    loop do
      move=@scene.pbChooseMove
      if move<=0
        if @scene.pbConfirm(
          _INTL("Give up trying to teach a new move to {1}?",pokemon.name))
          @scene.pbEndScene
          return false
        end
      else
        if @scene.pbConfirm(_INTL("Teach {1}?",PBMoves.getName(move)))
          if pbLearnMove(pokemon,move)
            @scene.pbEndScene
            return true
          end
        end
      end
    end
  end
end



def pbRelearnMoveScreen(pokemon)
  retval=true
  pbFadeOutIn(99999){
     scene=MoveRelearnerScene.new
     screen=MoveRelearnerScreen.new(scene)
     retval=screen.pbStartScreen(pokemon)
  }
  return retval
end
