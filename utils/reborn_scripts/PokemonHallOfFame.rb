#===============================================================================
# * Hall of Fame - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It makes a recordable Hall of Fame
# like the Gen 3 games.
#
#===============================================================================
#
# To this scripts works, put it above main, put a 512x384 picture in 
# hallfamebars and a 8x24 background picture in hallfamebg. To call this script,
# use 'pbHallOfFameEntry'. After you recorder the first entry, you can access
# the hall teams using a PC. You can also check the player Hall of Fame last
# number using '$PokemonGlobal.hallOfFameLastNumber'.
# 
#===============================================================================
class HallOfFameScene
  # When true, all pokémon will be in one line
  # When false, all pokémon will be in two lines
  SINGLEROW = false
  # Make the pokémon movement ON in hall entry
  ANIMATION = true
  # Speed in pokémon movement in hall entry. Don't use less than 2!
  ANIMATIONSPEED = 32
  # Entry wait time between each pokémon (and trainer) is show
  ENTRYWAITTIME = 128
  # Maximum number limit of simultaneous hall entries saved. 
  # 0 = Doesn't save any hall. -1 = no limit
  # Prefer to use larger numbers (like 500 and 1000) than don't put a limit
  # If a player exceed this limit, the first one will be removed
  HALLLIMIT = 50
  # The entry music name. Put "" to doesn't play anything
  ENTRYMUSIC = "Atmosphere- Credits"
  # Allow eggs to be show and saved in hall
  ALLOWEGGS = true
  # Remove the hallbars when the trainer sprite appears
  REMOVEBARS = true
  # The final fade speed on entry
  FINALFADESPEED = 16
  # Sprites opacity value when them aren't selected
  OPACITY = 64

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdateAnimation
    if @battlerIndex<=@hallEntry.size
      if @xmovement[@battlerIndex]!=0 || @ymovement[@battlerIndex]!=0
        spriteIndex=(@battlerIndex<@hallEntry.size) ? @battlerIndex : -1
        moveSprite(spriteIndex)
      else
        @battlerIndex+=1
        if @battlerIndex<=@hallEntry.size
          # If it is a pokémon, write the pokémon text, wait the 
          # ENTRYWAITTIME and goes to the next battler
          pbPlayCry(@hallEntry[@battlerIndex-1])
          writePokemonData(@hallEntry[@battlerIndex-1])
          pbWait(ENTRYWAITTIME)
          if @battlerIndex<@hallEntry.size   # Preparates the next battler
            setPokemonSpritesOpacity(@battlerIndex,OPACITY)
            @sprites["overlay"].bitmap.clear
          else # Show the welcome message and preparates the trainer
            setPokemonSpritesOpacity(-1)
            writeWelcome
            pbWait(ENTRYWAITTIME*2)
            setPokemonSpritesOpacity(-1,OPACITY) if !SINGLEROW
            createTrainerBattler
          end
        end
      end  
    elsif @battlerIndex>@hallEntry.size
      # Write the trainer data and fade
      writeTrainerData
      pbWait(ENTRYWAITTIME)      
      fadeSpeed=((Math.log(2**12)-Math.log(FINALFADESPEED))/Math.log(2)).floor
      pbBGMFade((2**fadeSpeed).to_f/20) if @useMusic
      slowFadeOut(@sprites,fadeSpeed){ pbUpdate } 
      @alreadyFadedInEnd=true
      @battlerIndex+=1
    end
  end

  def pbUpdatePC
    # Change the team
    if @battlerIndex>=@hallEntry.size
      @hallIndex-=1
      return false if @hallIndex==-1
      @hallEntry=$PokemonGlobal.hallOfFame[@hallIndex]
      @battlerIndex=0
      createBattlers(false)
    elsif @battlerIndex<0
      @hallIndex+=1
      return false if @hallIndex>=$PokemonGlobal.hallOfFame.size
      @hallEntry=$PokemonGlobal.hallOfFame[@hallIndex]
      @battlerIndex=@hallEntry.size-1
      createBattlers(false)
    end
    # Change the pokemon
    pbPlayCry(@hallEntry[@battlerIndex])
    setPokemonSpritesOpacity(@battlerIndex,OPACITY)
    hallNumber=$PokemonGlobal.hallOfFameLastNumber + @hallIndex -
               $PokemonGlobal.hallOfFame.size + 1
    writePokemonData(@hallEntry[@battlerIndex],hallNumber)
    return true
  end

  def slowFadeOut(sprites,exponent)   # 2 exponent
    # To handle values above 8
    extraWaitExponent=exponent-9 
    exponent=8 if 8<exponent
    max=2**exponent
    speed=(2**8)/max
    for j in 0..max
      pbWait(2**extraWaitExponent) if extraWaitExponent>-1
      pbSetSpritesToColor(sprites,Color.new(0,0,0,j*speed))
      block_given? ? yield : pbUpdateSpriteHash(sprites)
    end
  end

  # Dispose the sprite if the sprite exists and make it null
  def restartSpritePosition(sprites,spritename)
    sprites[spritename].dispose if sprites.include?(spritename) && sprites[spritename]
    sprites[spritename]=nil  
  end

  # Change the pokémon sprites opacity except the index one
  def setPokemonSpritesOpacity(index,opacity=255)
    for n in 0...@hallEntry.size
      @sprites["pokemon#{n}"].opacity=(n==index) ? 255 : opacity if @sprites["pokemon#{n}"]
    end  
  end  

  # Placement for pokemon icons
  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width, Graphics.height)
    @viewport.z=99999
    # Comment the below line to doesn't use a background
    addBackgroundPlane(@sprites,"bg","hallfamebg",@viewport)
    @sprites["hallbars"]=IconSprite.new(@viewport)
    @sprites["hallbars"].setBitmap("Graphics/Pictures/hallfamebars")
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=10
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @alreadyFadedInEnd=false
    @useMusic=false
    @battlerIndex=0
    @hallEntry=[]
  end

  def pbStartSceneEntry
    pbStartScene
    @useMusic=(ENTRYMUSIC && ENTRYMUSIC!="")
    pbBGMPlay(ENTRYMUSIC) if @useMusic
    saveHallEntry
    @xmovement=[]
    @ymovement=[]
    createBattlers
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartScenePC
    pbStartScene
    @hallIndex=$PokemonGlobal.hallOfFame.size-1
    @hallEntry=$PokemonGlobal.hallOfFame[-1]
    createBattlers(false)
    pbFadeInAndShow(@sprites) { pbUpdate }
    pbUpdatePC
  end

  def saveHallEntry
    for i in 0...$Trainer.party.length
      # Clones every pokémon object
      @hallEntry.push($Trainer.party[i].clone) if (
        !$Trainer.party[i].isEgg? || ALLOWEGGS)
    end
    # Update the global variables
    $PokemonGlobal.hallOfFame.push(@hallEntry)
    $PokemonGlobal.hallOfFameLastNumber+=1
    $PokemonGlobal.hallOfFame.delete_at(0) if HALLLIMIT>-1 && 
                                        $PokemonGlobal.hallOfFame.size>HALLLIMIT
  end

  # Return the x/y point position in screen for battler index number
  # Don't use odd numbers!
  def xpointformula(battlernumber)
    ret=0
    if !SINGLEROW
      ret=32+160*xpositionformula(battlernumber)
    else
      ret=(60*(battlernumber/2)+48)*(xpositionformula(battlernumber)-1)
      ret+=Graphics.width/2-56
    end  
    return ret
  end

  def ypointformula(battlernumber)
    ret=0
    if !SINGLEROW
      ret=32+128*ypositionformula(battlernumber)/2
    else
      ret=96-8*(battlernumber/2)
    end  
    return ret
  end

  # Returns 0, 1 or 2 as the x/y column value
  def xpositionformula(battlernumber)
    ret=0
    if !SINGLEROW
      ret=(battlernumber/3%2==0) ? (19-battlernumber)%3 : (19+battlernumber)%3
    else
      ret=battlernumber%2*2
    end  
    return ret
  end

  def ypositionformula(battlernumber)
    ret=0
    if !SINGLEROW
      ret=(battlernumber/3)%2*2
    else
      ret=1
    end  
    return ret
  end 

  def createBattlers(hide=true)
    # Movement in animation
    for i in 0...6
      # Clear all 6 pokémon sprites and dispose the ones that exists every time
      # that this method is call
      restartSpritePosition(@sprites,"pokemon#{i}") 
      next if i>=@hallEntry.size
      xpoint=xpointformula(i)
      ypoint=ypointformula(i)
      pok=@hallEntry[i]
      @sprites["pokemon#{i}"]=PokemonSprite.new(@viewport)
      @sprites["pokemon#{i}"].setPokemonBitmap(pok)
      # This method doesn't put the exact coordinates
      pbPositionPokemonSprite(@sprites["pokemon#{i}"],xpoint,ypoint)
      @sprites["pokemon#{i}"].z=7-i if SINGLEROW
      next if !hide
      # Animation distance calculation
      horizontal=1-xpositionformula(i)
      vertical=1-ypositionformula(i)
      xdistance=(horizontal==-1) ? -@sprites["pokemon#{i}"].bitmap.width : Graphics.width
      ydistance=(vertical==-1) ? -@sprites["pokemon#{i}"].bitmap.height : Graphics.height
      xdistance=((xdistance-@sprites["pokemon#{i}"].x)/ANIMATIONSPEED).abs+1
      ydistance=((ydistance-@sprites["pokemon#{i}"].y)/ANIMATIONSPEED).abs+1
      biggerdistance=(xdistance>ydistance) ? xdistance : ydistance
      @xmovement[i]=biggerdistance
      @xmovement[i]*=-1 if horizontal==-1
      @xmovement[i]=0   if horizontal== 0
      @ymovement[i]=biggerdistance
      @ymovement[i]*=-1 if vertical==-1
      @ymovement[i]=0   if vertical== 0
      # Hide the battlers
      @sprites["pokemon#{i}"].x+=@xmovement[i]*ANIMATIONSPEED
      @sprites["pokemon#{i}"].y+=@ymovement[i]*ANIMATIONSPEED
    end
  end

  def moveSprite(i)
    spritename=(i>-1) ? "pokemon#{i}" : "trainer"
    speed = (i>-1) ? ANIMATIONSPEED : 2
    if(!ANIMATION) # Skips animation
      @sprites[spritename].x-=speed*@xmovement[i]
      @xmovement[i]=0
      @sprites[spritename].y-=speed*@ymovement[i]
      @ymovement[i]=0
    end
    if(@xmovement[i]!=0)
      direction = (@xmovement[i]>0) ? -1 : 1
      @sprites[spritename].x+=speed*direction
      @xmovement[i]+=direction
    end
    if(@ymovement[i]!=0)
      direction = (@ymovement[i]>0) ? -1 : 1
      @sprites[spritename].y+=speed*direction
      @ymovement[i]+=direction
    end
  end

  def createTrainerBattler
    @sprites["trainer"]=IconSprite.new(@viewport)
    @sprites["trainer"].setBitmap(pbTrainerSpriteFile($Trainer.trainertype))
    if !SINGLEROW
      @sprites["trainer"].x=Graphics.width-96
      @sprites["trainer"].y=160
    else
      @sprites["trainer"].x=Graphics.width/2
      @sprites["trainer"].y=178
    end
    @sprites["trainer"].z=9
    @sprites["trainer"].ox=@sprites["trainer"].bitmap.width/2
    @sprites["trainer"].oy=@sprites["trainer"].bitmap.height/2
    if REMOVEBARS
      @sprites["overlay"].bitmap.clear
      @sprites["hallbars"].visible=false
    end
    @xmovement[@battlerIndex]=0
    @ymovement[@battlerIndex]=0
    if(ANIMATION && !SINGLEROW) # Trainer Animation
      startpoint=Graphics.width/2
      # 2 is the trainer speed
      @xmovement[@battlerIndex]=(startpoint-@sprites["trainer"].x)/2
      @sprites["trainer"].x=startpoint
    else
      pbWait(ENTRYWAITTIME)
    end
  end

  def writeTrainerData
    totalsec = Graphics.frame_count / 40 #Graphics.frame_rate #Turbo
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    pubid=sprintf("%05d",$Trainer.publicID($Trainer.id))
    lefttext= _INTL("Name<r>{1}<br>",$Trainer.name)
    lefttext+=_INTL("IDNo.<r>{1}<br>",pubid)
    lefttext+=_ISPRINTF("Time<r>{1:02d}:{2:02d}<br>",hour,min)
    lefttext+=_INTL("Pokédex<r>{1}/{2}<br>",
        $Trainer.pokedexOwned,$Trainer.pokedexSeen)
    @sprites["messagebox"]=Window_AdvancedTextPokemon.new(lefttext)
    @sprites["messagebox"].viewport=@viewport
    @sprites["messagebox"].width=192 if @sprites["messagebox"].width<192
    @sprites["msgwindow"]=Kernel.pbCreateMessageWindow(@viewport)
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
        _INTL("Congratulations, Champion!\\^"))
  end  

  BASECOLOR   = Color.new(248,248,248)
  SHADOWCOLOR = Color.new(0,0,0)

  def writePokemonData(pokemon,hallNumber=-1)
    overlay=@sprites["overlay"].bitmap
    overlay.clear 
    pokename=pokemon.name
    speciesname=PBSpecies.getName(pokemon.species)
    if pokemon.isMale?
      speciesname+="♂"
    elsif pokemon.isFemale?
      speciesname+="♀"
    end
    pokename+="/"+speciesname
    pokename=_INTL("Egg")+"/"+_INTL("Egg") if pokemon.isEgg?
    idno=(pokemon.ot=="" || pokemon.isEgg?) ? "?????" : 
       sprintf("%05d",pokemon.publicID)
    dexnumber=pokemon.isEgg? ? _INTL("No. ???") : _ISPRINTF("No. {1:03d}",pokemon.species)
    textPositions=[
       [dexnumber,32,Graphics.height-80,0,BASECOLOR,SHADOWCOLOR],
       [pokename,Graphics.width-192,Graphics.height-80,2,BASECOLOR,SHADOWCOLOR],
       [_INTL("Lv. {1}",pokemon.isEgg? ? "?" : pokemon.level),
           64,Graphics.height-48,0,BASECOLOR,SHADOWCOLOR],
       [_INTL("IDNo.{1}",pokemon.isEgg? ? "?????" : idno),
           Graphics.width-192,Graphics.height-48,2,BASECOLOR,SHADOWCOLOR]
    ]
    if (hallNumber>-1)
      textPositions.push([_INTL("Hall of Fame No."),Graphics.width/2-104,0,0,BASECOLOR,SHADOWCOLOR])
      textPositions.push([hallNumber.to_s,Graphics.width/2+104,0,1,BASECOLOR,SHADOWCOLOR])
    end       
    pbDrawTextPositions(overlay,textPositions)
  end

  def writeWelcome
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    pbDrawTextPositions(overlay,[[_INTL("Welcome to the Hall of Fame!"),
        Graphics.width/2,Graphics.height-80,2,BASECOLOR,SHADOWCOLOR]])
  end

  def pbEndScene
    $game_map.autoplay if @useMusic
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites.include?("msgwindow")
    pbFadeOutAndHide(@sprites) { pbUpdate } if !@alreadyFadedInEnd
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbPCSelection
    loop do
      Graphics.update
      Input.update
      pbUpdate
      continueScene=true
      break if Input.trigger?(Input::B) # Exits
      if Input.trigger?(Input::C) # Moves the selection one entry backward
        @battlerIndex+=10
        continueScene=pbUpdatePC
      end
      if Input.trigger?(Input::LEFT) # Moves the selection one pokémon forward
        @battlerIndex-=1
        continueScene=pbUpdatePC
      end
      if Input.trigger?(Input::RIGHT) # Moves the selection one pokémon backward
        @battlerIndex+=1
        continueScene=pbUpdatePC
      end
      break if !continueScene
    end
  end

  def pbAnimationLoop
    loop do
      Graphics.update
      Input.update
      pbUpdate
      pbUpdateAnimation
      break if @battlerIndex==@hallEntry.size+2
    end
  end
end



class HallOfFameScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreenEntry
    @scene.pbStartSceneEntry
    @scene.pbAnimationLoop
    @scene.pbEndScene
  end

  def pbStartScreenPC
    @scene.pbStartScenePC
    @scene.pbPCSelection
    @scene.pbEndScene
  end
end



class HallOfFamePC
  def shouldShow?
    return $PokemonGlobal.hallOfFameLastNumber>0
  end

  def name
    return _INTL("Hall of Fame")
  end

  def access
    Kernel.pbMessage(_INTL("\\se[accesspc]Accessed the Hall of Fame."))
    pbHallOfFamePC
  end
end



PokemonPCList.registerPC(HallOfFamePC.new)



class PokemonGlobalMetadata
  attr_accessor :hallOfFame
  # Number necessary if hallOfFame array reach in its size limit
  attr_accessor :hallOfFameLastNumber

  def hallOfFame
    @hallOfFame=[] if !@hallOfFame
    return @hallOfFame
  end

  def hallOfFameLastNumber
    @hallOfFameLastNumber=0 if !@hallOfFameLastNumber
    return @hallOfFameLastNumber
  end
end



def pbHallOfFameEntry
  scene=HallOfFameScene.new
  screen=HallOfFameScreen.new(scene)
  screen.pbStartScreenEntry
end

def pbSilentHallEntry # Reborn addition
  hallEntry = []
  alloweggs = true
  halllimit = 50
  for i in 0...$Trainer.party.length
    # Clones every pokémon object
    hallEntry.push($Trainer.party[i].clone) if (
      !$Trainer.party[i].isEgg? || alloweggs)
  end
  # Update the global variables
  $PokemonGlobal.hallOfFame.push(hallEntry)
  $PokemonGlobal.hallOfFameLastNumber+=1
  $PokemonGlobal.hallOfFame.delete_at(0) if halllimit>-1 && 
                                      $PokemonGlobal.hallOfFame.size>halllimit
end

def pbHallOfFamePC
  scene=HallOfFameScene.new
  screen=HallOfFameScreen.new(scene)
  screen.pbStartScreenPC
end