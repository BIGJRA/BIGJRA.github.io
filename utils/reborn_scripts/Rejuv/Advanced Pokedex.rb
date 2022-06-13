#===============================================================================
# * Advanced Pokédex - by FL (Credits will be apreciated)
#===============================================================================
#
 # This script is for Pokémon Essentials. When a switch is ON, it displays at 
# pokédex the pokémon PBS data for a caught pokémon like: base exp, egg steps
# to hatch, abilities, wild hold item, evolution, the moves that pokémon can 
# learn by level/breeding/machines/tutors, among others.
#
 #===============================================================================
#
 # To this script works, put it above main, put a 512x384 background for this
# screen in "Graphics/Pictures/advancedPokedex" location and three 512x384 for
# the top pokédex selection bar at "Graphics/Pictures/advancedPokedexEntryBar",
# "Graphics/Pictures/advancedPokedexNestBar" and
# "Graphics/Pictures/advancedPokedexFormBar".
#
 # -In PokemonPokedex script section, after line (use Ctrl+F to find it)
# '@sprites["searchlist"].visible=false' add:
#
 # @sprites["dexbar"]=IconSprite.new(0,0,@viewport)
# @sprites["dexbar"].setBitmap(_INTL("Graphics/Pictures/advancedPokedexEntryBar"))
# @sprites["dexbar"].visible=false
#
 # -After line '@sprites["dexentry"].visible=true' add:
#
 # if @sprites["dexbar"] && $game_switches[AdvancedPokedexScene::SWITCH]
#   @sprites["dexbar"].visible=true 
# end 
 #
 # -Change line 'newpage=page+1 if page<3' to 
# 'newpage=page+1 if page<($game_switches[AdvancedPokedexScene::SWITCH] ? 4 : 3)'.
# -After line 'ret=screen.pbStartScreen(@dexlist[curindex][0],listlimits)' add:
#
# when 4 # Advanced Data
#   scene=AdvancedPokedexScene.new
#   screen=AdvancedPokedex.new(scene)
#   ret=screen.pbStartScreen(@dexlist[curindex][0],listlimits)
#
# -In PokemonNestAndForm script section, before line 
# '@sprites["map"]=IconSprite.new(0,0,@viewport)' add:
#
# if $game_switches[AdvancedPokedexScene::SWITCH]
#   @sprites["dexbar"]=IconSprite.new(0,0,@viewport)
#   @sprites["dexbar"].setBitmap(_INTL("Graphics/Pictures/advancedPokedexNestBar"))
# end
#
# -Before line 
# '@sprites["info"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)'
# add:
#
# if $game_switches[AdvancedPokedexScene::SWITCH]
#   @sprites["dexbar"]=IconSprite.new(0,0,@viewport)
#   @sprites["dexbar"].setBitmap(_INTL("Graphics/Pictures/advancedPokedexFormBar"))
# end
#
# -After line 'pbChooseForm' add:
#
# elsif Input.trigger?(Input::RIGHT)
#   if $game_switches[AdvancedPokedexScene::SWITCH]
#     ret=6
#     break
#   end
#
#===============================================================================

class AdvancedPokedexScene
  # Switch number that toggle this script ON/OFF
  SWITCH=704
  
  # When true always shows the egg moves of the first evolution stage
  EGGMOVESFISTSTAGE = true
  
  # When false shows different messages for each of custom evolutions,
  # change the messages to ones that fills to your method
  HIDECUSTOMEVOLUTION = true
  
  # When true displays TMs/HMs/Tutors moves
  SHOWMACHINETUTORMOVES = true
  
  # When true picks the number for TMs and the first digit after a H for 
  # HMs (like H8) when showing machine moves.
  FORMATMACHINEMOVES = true
  
  # When false doesn't displays moves in tm.txt PBS that aren't in
  # any TM/HM item
  SHOWTUTORMOVES = true
  
  # The division between tutor and machine (TM/HMs) moves is made by 
  # the TM data in items.txt PBS 
  
  def pbStartScene(species)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @species=species
    @sprites={}
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/advancedPokedex"))
    @sprites["overlay"]=BitmapSprite.new(
        Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["overlay"].x=0
    @sprites["overlay"].y=0
    @sprites["info"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["icon"]=PokemonSpeciesIconSprite.new(@species,@viewport)
    @sprites["icon"].x=52
    @sprites["icon"].y=290
    @type1=nil
    @type2=nil
    @page=1
    @totalPages=0
    if $Trainer.owned[@species]
      @infoPages=3
      @infoArray=getInfo
      @levelMovesArray=getLevelMoves
      @eggMovesArray=getEggMoves
      @machineMovesArray=getMachineMoves if SHOWMACHINETUTORMOVES
      @levelMovesPages = (@levelMovesArray.size+9)/10
      @eggMovesPages = (@eggMovesArray.size+9)/10
      @machineMovesPages=(@machineMovesArray.size+9)/10 if SHOWMACHINETUTORMOVES
      @totalPages = @infoPages+@levelMovesPages+@eggMovesPages
      @totalPages+=@machineMovesPages if SHOWMACHINETUTORMOVES
      displayPage
    end
    pbUpdate
    return true
  end
  
  BASECOLOR = Color.new(88,88,80)
  SHADOWCOLOR = Color.new(168,184,184)
  BASE_X = 32
  EXTRA_X = 224
  BASE_Y = 64
  EXTRA_Y = 32
  
  def getInfo
    ret = []
    for i in 0...2*4
      ret[i]=[]
      for j in 0...6
        ret[i][j]=nil
      end
    end
    # Type
    @type1=$cache.pkmn_dex[@species][3]
    @type2=$cache.pkmn_dex[@species][4]
    # Base Exp
    ret[0][0]=_INTL("BASE EXP: {1}",$cache.pkmn_dex[@species][16])
    # Catch Rate
    ret[1][0]=_INTL("CATCH RARENESS: {1}",$cache.pkmn_dex[@species][6])
    # Happiness base
    ret[0][1]=_INTL("HAPPINESS BASE: {1}",$cache.pkmn_dex[@species][8])
    # Color
    colorName=[
        _INTL("Red"),_INTL("Blue"),_INTL("Yellow"),
        _INTL("Green"),_INTL("Black"),_INTL("Brown"),
        _INTL("Purple"),_INTL("Gray"),_INTL("White"),_INTL("Pink")
    ][$cache.pkmn_dex[@species][1]]
    ret[1][1]=_INTL("COLOR: {1}",colorName)
    # Egg Steps to Hatch
    stepsToHatch = $cache.pkmn_dex[@species][10]
    ret[0][2]=_INTL("EGG STEPS TO HATCH: {1} ({2} cycles)",
        stepsToHatch,stepsToHatch/255)
    # Growth Rate
    growthRate=$cache.pkmn_dex[@species][9]
    growthRateString = [_INTL("Medium"),_INTL("Erratic"),_INTL("Fluctuating"),
        _INTL("Parabolic"),_INTL("Fast"),_INTL("Slow")][growthRate]
    ret[0][3]=_INTL("GROWTH RATE: {1} ({2})",
        growthRateString,PBExperience.pbGetMaxExperience(growthRate))
    # Gender Rate
    genderbyte=$cache.pkmn_dex[@species][7]
    genderPercent= 100-((genderbyte+1)*100/256.0)
    genderString = case genderbyte
      when 0;   _INTL("Always male")
      when 254; _INTL("Always female")
      when 255; _INTL("Genderless")
      else;     _INTL("Male {1}%",genderPercent)
    end
    ret[0][4]=_INTL("GENDER RATE: {1}",genderString)
    # Breed Group
    compat10=$cache.pkmn_dex[@species][13][0]
    compat11=$cache.pkmn_dex[@species][13][1]
    eggGroupArray=[
        nil,_INTL("Monster"),_INTL("Water1"),_INTL("Bug"),_INTL("Flying"),
        _INTL("Ground"),_INTL("Fairy"),_INTL("Plant"),_INTL("Humanshape"),
        _INTL("Water3"),_INTL("Mineral"),_INTL("Indeterminate"),
        _INTL("Water2"),_INTL("Ditto"),_INTL("Dragon"),_INTL("No Eggs")
    ]
    eggGroups = compat10==compat11 ? eggGroupArray[compat10] : 
        _INTL("{1}, {2}",eggGroupArray[compat10],eggGroupArray[compat11])
    ret[0][5]=_INTL("BREED GROUP: {1}",eggGroups)
    # Base Stats
    baseStats=[
      $cache.pkmn_dex[@species][5][0], # HP
      $cache.pkmn_dex[@species][5][1], # Attack
      $cache.pkmn_dex[@species][5][2], # Defense
      $cache.pkmn_dex[@species][5][3], # Speed
      $cache.pkmn_dex[@species][5][4], # Special Attack
      $cache.pkmn_dex[@species][5][5]  # Special Defense
    ]
    baseStatsTot=0
    for i in 0...baseStats.size
      baseStatsTot+=baseStats[i]
    end
    baseStats.push(baseStatsTot)
    ret[2][0]=_ISPRINTF(
        "                             HP ATK DEF SPD SATK SDEF")
    ret[2][1]=_ISPRINTF(
        "BASE STATS:       {1:03d} {2:03d} {3:03d} {4:03d} {5:03d} {6:03d} {7:03d}",
        baseStats[0],baseStats[1],baseStats[2],
        baseStats[3],baseStats[4],baseStats[5],baseStats[6])
    # Effort Points
    effortPoints=[
      $cache.pkmn_dex[@species][11][0], # HP
      $cache.pkmn_dex[@species][11][1], # Attack
      $cache.pkmn_dex[@species][11][2], # Defense
      $cache.pkmn_dex[@species][11][3], # Speed
      $cache.pkmn_dex[@species][11][4], # Special Attack
      $cache.pkmn_dex[@species][11][5]  # Special Defense
    ]
    effortPointsTot=0
    for i in 0...effortPoints.size
      effortPoints[i]=0 if  !effortPoints[i]
      effortPointsTot+=effortPoints[i]
    end
    effortPoints.push(effortPointsTot)
    ret[2][2]=_ISPRINTF(
        "EFFORT POINTS: {1:03d} {2:03d} {3:03d} {4:03d} {5:03d} {6:03d} {7:03d}",
        effortPoints[0],effortPoints[1],effortPoints[2],
        effortPoints[3],effortPoints[4],effortPoints[5],effortPoints[6])
    # Abilities
    ability1=$cache.pkmn_dex[@species][12][0]
    ability2=$cache.pkmn_dex[@species][12][1]
    abilityString=(ability1==ability2 || ability2==0) ? 
        PBAbilities.getName(ability1) : _INTL("{1}, {2}",
        PBAbilities.getName(ability1), PBAbilities.getName(ability2))
    ret[2][3]=_INTL("ABILITIES: {1}",abilityString)
    # Hidden Abilities
    hiddenAbility1=$cache.pkmn_dex[@species][17][0]
    if hiddenAbility1!=0
      abilityString = PBAbilities.getName(hiddenAbility1)
      ret[2][4]=_INTL("HIDDEN ABILITIES: {1}",abilityString)
    end
    # Wild hold item 
    holdItems=[$cache.pkmn_dex[@species][18],$cache.pkmn_dex[@species][19],$cache.pkmn_dex[@species][20]]
    holdItemsStrings=[]
    if(holdItems[0]!=0 && holdItems[0]==holdItems[1] && 
        holdItems[0]==holdItems[2])
      holdItemsStrings.push(_INTL("{1} (always)",
          PBItems.getName(holdItems[0])))
    else
      holdItemsStrings.push(_INTL("{1} (common)", 
          PBItems.getName(holdItems[0]))) if holdItems[0]>0
      holdItemsStrings.push(_INTL("{1} (uncommon)",
          PBItems.getName(holdItems[1]))) if holdItems[1]>0
      holdItemsStrings.push(_INTL("{1} (rare)", 
          PBItems.getName(holdItems[2]))) if holdItems[2]>0
    end
    ret[4][0] = _INTL("HOLD ITEMS: {1}",holdItemsStrings.empty? ? 
        "" : holdItemsStrings[0])
    ret[4][1] = holdItemsStrings[1] if holdItemsStrings.size>1
    ret[4][2] = holdItemsStrings[2] if holdItemsStrings.size>2
    # Evolutions
    evolutionsStrings = []
    lastEvolutionSpecies = -1
    for evolution in pbGetEvolvedFormData(@species)
      # The below "if" it's to won't list the same evolution species more than
      # one time. Only the last is displayed.
      evolutionsStrings.pop if lastEvolutionSpecies==evolution[2]
      evolutionsStrings.push(getEvolutionMessage(evolution))
      lastEvolutionSpecies=evolution[2]
    end
    line=3
    column=4
    ret[column][line] = _INTL("EVO: {1}",evolutionsStrings.empty? ? 
        "" : evolutionsStrings[0])
    evolutionsStrings.shift
    line+=1
     for string in evolutionsStrings
      if(line>5) # For when the pokémon has more than 3 evolutions (AKA Eevee) 
        line=0
         column+=2
        @infoPages+=1 # Creates a new page
      end
       ret[column][line] = string
      line+=1
     end
     # End
    return ret
   end  
   
   # Gets the evolution array and return evolution message
  def getEvolutionMessage(evolution)
    evoPokemon = PBSpecies.getName(evolution[2])
    evoMethod = evolution[0]
    evoItem = evolution[1] # Sometimes it's level
    ret = case evoMethod
      when 1; _INTL("{1} when happy",evoPokemon)
      when 2; _INTL("{1} when happy at day",evoPokemon)
      when 3; _INTL("{1} when happy at night",evoPokemon)
      when 4, 13;_INTL("{1} at level {2}",
          evoPokemon,evoItem) # Pokémon that evolve by level AND Ninjask
      when 5; _INTL("{1} trading",evoPokemon)
      when 6; _INTL("{1} trading holding {2}",
          evoPokemon,PBItems.getName(evoItem))
      when 7; _INTL("{1} using {2}",evoPokemon,PBItems.getName(evoItem))
      when 8; _INTL("{1} at level {2} and ATK > DEF",
          evoPokemon,evoItem) # Hitmonlee
      when 9; _INTL("{1} at level {2} and ATK = DEF",
          evoPokemon,evoItem) # Hitmontop
      when 10;_INTL("{1} at level {2} and DEF < ATK",
          evoPokemon,evoItem) # Hitmonchan 
      when 11,12; _INTL("{1} at level {2} with personalID",
          evoPokemon,evoItem) # Silcoon/Cascoon
      when 14;_INTL("{1} at level {2} with empty space",
          evoPokemon,evoItem) # Shedinja
      when 15;_INTL("{1} when beauty is greater than {2}",
          evoPokemon,evoItem) # Milotic 
      when 16;_INTL("{1} using {2} and it's male",
          evoPokemon,PBItems.getName(evoItem))
      when 17;_INTL("{1} using {2} and it's female",
          evoPokemon,PBItems.getName(evoItem))
      when 18;_INTL("{1} holding {2} at day",
          evoPokemon,PBItems.getName(evoItem))
      when 19;_INTL("{1} holding {2} at night",
          evoPokemon,PBItems.getName(evoItem))
      when 20;_INTL("{1} when has move {2}",
          evoPokemon,PBMoves.getName(evoItem))
      when 21;_INTL("{1} when has {2} at party",
          evoPokemon,PBSpecies.getName(evoItem))
      when 22;_INTL("{1} at level {2} and it's male",
          evoPokemon,evoItem)
      when 23;_INTL("{1} at level {2} and it's female",
          evoPokemon,evoItem)
      when 24;_INTL("{1} at {2}",
          evoPokemon, pbGetMapNameFromId(evoItem)) # Evolves on a certain map
      when 25;_INTL("{1} trading by {2}",
          evoPokemon,PBSpecies.getName(evoItem)) # Escavalier/Accelgor
      # When HIDECUSTOMEVOLUTION = false the below 7 messages will be displayed
      when 26;_INTL("{1} custom1 with {2}", evoPokemon,evoItem) 
      when 27;_INTL("{1} custom2 with {2}", evoPokemon,evoItem) 
      when 28;_INTL("{1} LevelRain with {2}", evoPokemon,evoItem) 
      when 29;_INTL("{1} LevelDay with {2}", evoPokemon,evoItem) 
      when 30;_INTL("{1} LevelNight with {2}", evoPokemon,evoItem) 
      when 31;_INTL("{1} custom6 with {2}", evoPokemon,evoItem)
      when 32;_INTL("{1} custom7 with {2}", evoPokemon,evoItem)
      when 33;_INTL("{1} custom8 with {2}", evoPokemon,evoItem)  
      else; ""  
    end  
     ret = _INTL("{1} by an unknown way", evoPokemon) if(ret.empty? ||
        (evoMethod>=32 && HIDECUSTOMEVOLUTION))
    return ret    
  end
   
   def getLevelMoves
    ret=[]
    $cache.pkmn_moves = load_data("Data/attacksRS.rxdata") if !$cache.pkmn_moves
    for k in 0...$cache.pkmn_moves[@species].length
      level=$cache.pkmn_moves[@species][k][0]
      move=PBMoves.getName($cache.pkmn_moves[@species][k][1])
      ret.push(_ISPRINTF("{1:02d} {2:s}",level,move))
    end
    return ret
   end  
   
   def getEggMoves
    movelist=[]
    ret=[]
    eggMoveSpecies = @species
    eggMoveSpecies = pbGetBabySpecies(eggMoveSpecies) if EGGMOVESFISTSTAGE
    $cache.pkmn_egg = load_data("Data/eggEmerald.rxdata") if !$cache.pkmn_egg
    for moves in [$cache.pkmn_egg[pbGetBabySpecies(@species)],$cache.pkmn_egg[pbGetLessBabySpecies(@species)],moves = $cache.pkmn_egg[@species]]
      if moves
        for i in moves
          movelist.push(i)
        end
      end
    end
    i=0; loop do break unless i<movelist.length
      move=PBMoves.getName(movelist[i])
      ret.push(_ISPRINTF("     {1:s}",move))
      i+=1
      end
      ret.sort!
    return ret
   end  
   
   def getMachineMoves
    ret=[]
     movesArray=[]
    machineMoves=[]
    tmData=load_data("Data/tm.dat")
    for move in 1...tmData.size
      next if !tmData[move]
      movesArray.push(move) if tmData[move].any?{ |item| item==@species }
    end
     for item in 1..PBItems.maxValue
      if pbIsMachine?(item)
        move = $cache.items[item][ITEMMACHINE]
        if movesArray.include?(move)
          if FORMATMACHINEMOVES
            machineLabel = PBItems.getName(item)
            machineLabel = machineLabel[2,machineLabel.size-2] 
            machineLabel = "H"+machineLabel[1,1] if pbIsHiddenMachine?(item)
            ret.push(_ISPRINTF("{1:s} {2:s}",
                machineLabel,PBMoves.getName(move)))
            movesArray.delete(move)
          else
             machineMoves.push(move)
          end  
         end
       end  
     end
     # The above line removes the tutors moves. The movesArray will be 
    # empty if the machines are already in the ret array.
    movesArray = machineMoves if !SHOWTUTORMOVES
    unnumeredMoves=[]
    for move in movesArray # Show the moves unnumered
      unnumeredMoves.push(_ISPRINTF("     {1:s}",PBMoves.getName(move)))
    end  
     ret = ret.sort + unnumeredMoves.sort
    return ret
   end  
   
   def displayPage
    return if !$Trainer.owned[@species]
    if(@page<=@infoPages)
      pageInfo(@page)
    elsif(@page<=@infoPages+@levelMovesPages)
      pageMoves(@levelMovesArray,_INTL("LEVEL UP MOVES:"),@page-@infoPages)
    elsif(@page<=@infoPages+@levelMovesPages+@eggMovesPages)
      pageMoves(@eggMovesArray,_INTL("EGG MOVES:"),
          @page-@infoPages-@levelMovesPages)
    elsif(SHOWMACHINETUTORMOVES && 
        @page <= @infoPages+@levelMovesPages+@eggMovesPages+@machineMovesPages)
      pageMoves(@machineMovesArray,_INTL("MACHINE MOVES:"),
          @page-@infoPages-@levelMovesPages-@eggMovesPages)
    end
   end  
   
   def pageInfo(page)
    @sprites["overlay"].bitmap.clear
    textpos = []
    for i in (12*(page-1))...(12*page)
      line = i%6
      column = i/6
      next if !@infoArray[column][line]
      x = BASE_X+EXTRA_X*(column%2)
      y = BASE_Y+EXTRA_Y*line
      textpos.push([@infoArray[column][line],x,y,false,BASECOLOR,SHADOWCOLOR])
    end
     pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
  end  
   
   def pageMoves(movesArray,label,page)
    @sprites["overlay"].bitmap.clear
    textpos = [[label,BASE_X,BASE_Y,false,BASECOLOR,SHADOWCOLOR]]
     for i in (10*(page-1))...(10*page)
      break if i>=movesArray.size
      line = i%5
      column = i/5
      x = BASE_X+EXTRA_X*(column%2)
      y = BASE_Y+EXTRA_Y*(line+1)
      textpos.push([movesArray[i],x,y,false,BASECOLOR,SHADOWCOLOR])
    end
     pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
  end  
   
   def pbUpdate
     @sprites["info"].bitmap.clear
    pbSetSystemFont(@sprites["info"].bitmap)
    height = Graphics.height-54
    text=[[PBSpecies.getName(@species),(Graphics.width+72)/2,height-32,
         2,BASECOLOR,SHADOWCOLOR]]
    text.push([_INTL("{1}/{2}",@page,@totalPages),Graphics.width-52,height,
         1,BASECOLOR,SHADOWCOLOR]) if $Trainer.owned[@species]
    pbDrawTextPositions(@sprites["info"].bitmap,text)
    typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/pokedexTypes"))
    if !@type1 # This "if" only occurs when the getInfo isn't called
      @type1=$cache.pkmn_dex[@species][3]
      @type2=$cache.pkmn_dex[@species][4]
    end
    type1rect=Rect.new(0,@type1*32,96,32)
    type2rect=Rect.new(0,@type2*32,96,32)
    if(@type1==@type2)
      @sprites["info"].bitmap.blt((Graphics.width+16-36)/2,height,
          typebitmap.bitmap,type1rect)
    else  
       @sprites["info"].bitmap.blt((Graphics.width+16-144)/2,height,
          typebitmap.bitmap,type1rect)
      @sprites["info"].bitmap.blt((Graphics.width+16+72)/2,height,
          typebitmap.bitmap,type2rect) if @type1!=@type2
    end
     @sprites["icon"].update
  end
 
   def pbControls(listlimits)
    Graphics.transition
    ret=0
     loop do
       Graphics.update
      Input.update
      pbUpdate
       if Input.trigger?(Input::C)
        @page+=1
        @page=1 if @page>@totalPages
        displayPage
      elsif Input.trigger?(Input::A)
        @page-=1
        @page=@totalPages if @page<1
        displayPage
      elsif Input.trigger?(Input::LEFT)
        ret=4
         break
       # If not at top of list  
      elsif Input.trigger?(Input::UP) && listlimits&1==0 
        ret=8
         break
       # If not at end of list  
      elsif Input.trigger?(Input::DOWN) && listlimits&2==0 
        ret=2
         break
       elsif Input.trigger?(Input::B)
        ret=1
         pbPlayCancelSE()
        pbFadeOutAndHide(@sprites)
        break
       end
     end
     return ret
   end
 
   def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
 end
 
 
 class AdvancedPokedex
   def initialize(scene)
    @scene=scene
  end
 
   def pbStartScreen(species,listlimits)
    @scene.pbStartScene(species)
    ret=@scene.pbControls(listlimits)
    @scene.pbEndScene
    return ret
   end
 end