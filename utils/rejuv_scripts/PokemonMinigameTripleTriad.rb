################################################################################
# "Triple Triad" mini-game
# By Unknown
################################################################################
class TriadCard
  attr_reader :north, :east, :south, :west, :type, :species

  def baseStatToValue(stat)
    return 10 if stat>=200
    return 9 if stat>=150
    return 8 if stat>=125
    return 7 if stat>=100
    return 6 if stat>=80
    return 5 if stat>=70
    return 4 if stat>=60
    return 3 if stat>=45
    return 2 if stat>=30
    return 1
  end

  def attack(panel)
    return [@west,@east,@north,@south][panel]
  end

  def defense(panel)
    return [@east,@west,@south,@north][panel]
  end

  def price
    maxvalue=[@west,@east,@north,@south].max
    return [
       100,100,100,250,500,1000,
       2000,5000,8000,12000,20000
    ][maxvalue]
  end

  def bonus(opponent)
    atype=@type
    otype=opponent.type
    mod=PBTypes.getEffectiveness(atype,otype)
    return -2 if mod==0
    return -1 if mod==1
    return 1 if mod==4
    return 0
  end

  def initialize(species)
    dexdata=pbOpenDexData
    @species=species
    pbDexDataOffset(dexdata,species,10)
    dexdata.fgetb # HP
    @west=baseStatToValue(dexdata.fgetb) # Attack
    @east=baseStatToValue(dexdata.fgetb) # Defense
    dexdata.fgetb # Speed
    @north=baseStatToValue(dexdata.fgetb) # Special Attack
    @south=baseStatToValue(dexdata.fgetb) # Special Defense
    pbDexDataOffset(dexdata,species,8)
    @type=dexdata.fgetb # Type
    if isConst?(@type,PBTypes,:NORMAL)
      type2=dexdata.fgetb
      @type=type2 if !isConst?(type2,PBTypes,:NORMAL)
    end
    dexdata.close
  end

  def self.createBack(type=-1,noback=false)
    bitmap=BitmapWrapper.new(84,84)
    if !noback
      bitmap.fill_rect(0,0,84,84,Color.new(255,64,64))
      bitmap.fill_rect(2,2,80,80,Color.new(255,160,160))
    end
    if type>=0
      typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      typerect=Rect.new(0,type*28,64,28)
      bitmap.blt(10,28,typebitmap.bitmap,typerect,192)
      typebitmap.dispose
    end
    return bitmap
  end

  def createBitmap(owner)
    if owner==0
      return TriadCard.createBack
    end
    bitmap=BitmapWrapper.new(84,84)
    iconfile=pbCheckPokemonIconFiles([@species,0,false,0,false])
    typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    icon=AnimatedBitmap.new(iconfile)
    typerect=Rect.new(0,@type*28,64,28)
    if owner==2
      # opponent
      bitmap.fill_rect(0,0,84,84,Color.new(255,64,64))
      bitmap.fill_rect(2,2,80,80,Color.new(255,160,160))
    else
      # player
      bitmap.fill_rect(0,0,84,84,Color.new(64,64,255))
      bitmap.fill_rect(2,2,80,80,Color.new(160,160,255))
    end
    bitmap.blt(10,28,typebitmap.bitmap,typerect,192)
    bitmap.blt(10,2,icon.bitmap,Rect.new(0,0,64,64))
    pbSetSmallFont(bitmap)
    pbDrawTextPositions(bitmap,[
       ["0123456789A"[@north,1],84/2,2,2,Color.new(248,248,248),Color.new(96,96,96)],
       ["0123456789A"[@south,1],84/2,82-25,2,Color.new(248,248,248),Color.new(96,96,96)],
       ["0123456789A"[@west,1],2,(84/2)-12,0,Color.new(248,248,248),Color.new(96,96,96)],
       ["0123456789A"[@east,1],82,(84/2)-12,1,Color.new(248,248,248),Color.new(96,96,96)]
    ])
    icon.dispose
    typebitmap.dispose
    return bitmap
  end
end



class TriadSquare
  attr_accessor :owner, :card, :type

  def initialize
    @owner=0
    @card=nil
    @type=-1
  end

  def attack(panel)
    return @card.attack(panel)
  end

  def bonus(square)
    return @card.bonus(square.card)
  end

  def defense(panel)
    return @card.defense(panel)
  end
end



# Scene class for handling appearance of the screen
class TriadScene
# Update the scene here, this is called once each frame
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

# End the scene here
  def pbEndScene
    pbBGMFade(1.0)
    # Fade out all sprites
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Dispose all sprites
    pbDisposeSpriteHash(@sprites)
    @bitmaps.each{|bm| bm.dispose }
    # Dispose the viewport
    @viewport.dispose
  end

  def pbStartScene(battle)
    # Create sprite hash
    @sprites={}
    @bitmaps=[]
    @battle=battle
    # Allocate viewport
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    addBackgroundPlane(@sprites,"background","triadbg",@viewport)
    @sprites["helpwindow"]=Window_AdvancedTextPokemon.newWithSize("",
       0,Graphics.height-64,Graphics.width,64,@viewport)
    for i in 0...@battle.width*@battle.height
      @sprites["sprite#{i}"]=SpriteWrapper.new(@viewport)
      cardX=Graphics.width/2 - 126 + (i%3)*84
      cardY=46 + (i/3)*84
      @sprites["sprite#{i}"].z=2
      @sprites["sprite#{i}"].x=cardX
      @sprites["sprite#{i}"].y=cardY
      bm=TriadCard.createBack(@battle.board[i].type,true)
      @bitmaps.push(bm)
      @sprites["sprite#{i}"].bitmap=bm
    end
    @cardBitmaps=[]
    @opponentCardBitmaps=[]
    @cardIndexes=[]
    @opponentCardIndexes=[]
    @boardSprites=[]
    @boardCards=[]
    for i in 0...@battle.maxCards
      @sprites["player#{i}"]=Sprite.new(@viewport)
      @sprites["player#{i}"].z=2
      @sprites["player#{i}"].x=Graphics.width-96
      @sprites["player#{i}"].y=40+16*i
      @cardIndexes.push(i)
    end
    @sprites["overlay"]=Sprite.new(@viewport)
    @sprites["overlay"].bitmap=BitmapWrapper.new(Graphics.width,Graphics.height)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap,[
       [@battle.opponentName,54,0,2,Color.new(248,248,248),Color.new(96,96,96)],
       [@battle.playerName,Graphics.width-54,0,2,Color.new(248,248,248),Color.new(96,96,96)]
    ])
    @sprites["score"]=Sprite.new(@viewport)
    @sprites["score"].bitmap=BitmapWrapper.new(Graphics.width,Graphics.height)
    pbSetSystemFont(@sprites["score"].bitmap)
    pbBGMPlay("021-Field04")
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdateScore
    bitmap=@sprites["score"].bitmap
    bitmap.clear
    playerscore=0
    oppscore=0
    for i in 0...@battle.width*@battle.height
      if @boardSprites[i]
        playerscore+=1 if @battle.board[i].owner==1
        oppscore+=1 if @battle.board[i].owner==2
      end
    end
    if @battle.countUnplayedCards
      playerscore+=@cardIndexes.length
      oppscore+=@opponentCardIndexes.length
    end
    pbDrawTextPositions(bitmap,[
       [_INTL("{1}-{2}",oppscore,playerscore),Graphics.width/2,0,2,Color.new(248,248,248),Color.new(96,96,96)]
    ])
  end

  def pbNotifyCards(playerCards,opponentCards)
    @playerCards=playerCards
    @opponentCards=opponentCards
  end

  def pbDisplay(text)
    @sprites["helpwindow"].text=text
    60.times do
      Graphics.update
      Input.update
      pbUpdate
    end
  end

  def pbDisplayPaused(text)
    @sprites["helpwindow"].letterbyletter=true
    @sprites["helpwindow"].text=text+"\1"
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::C)
        if @sprites["helpwindow"].busy?
          pbPlayDecisionSE() if @sprites["helpwindow"].pausing?
          @sprites["helpwindow"].resume
        else
          break
        end
      end
    end
    @sprites["helpwindow"].letterbyletter=false
    @sprites["helpwindow"].text=""
  end

  def pbShowPlayerCards(cards)
    for i in 0...@battle.maxCards
      @sprites["player#{i}"]=Sprite.new(@viewport)
      @sprites["player#{i}"].z=2
      @sprites["player#{i}"].x=Graphics.width-96
      @sprites["player#{i}"].y=34+48*i
      @sprites["player#{i}"].bitmap=TriadCard.new(cards[i]).createBitmap(1)
      @cardBitmaps.push(@sprites["player#{i}"].bitmap)
    end
  end

  def pbShowOpponentCards(cards)
    for i in 0...@battle.maxCards
      @sprites["opponent#{i}"]=Sprite.new(@viewport)
      @sprites["opponent#{i}"].z=2
      @sprites["opponent#{i}"].x=12
      @sprites["opponent#{i}"].y=34+48*i
      @sprites["opponent#{i}"].bitmap=@battle.openHand ? TriadCard.new(cards[i]).createBitmap(2) : TriadCard.createBack(-1)
      @opponentCardBitmaps.push(@sprites["opponent#{i}"].bitmap)
      @opponentCardIndexes.push(i)
    end
  end

  def pbViewOpponentCards(numCards)
    @sprites["helpwindow"].text=_INTL("Check opponent's cards.")
    choice=0
    lastChoice=-1
    loop do
      if lastChoice!=choice
        y=34
        for i in 0...@opponentCardIndexes.length
          @sprites["opponent#{@opponentCardIndexes[i]}"].bitmap=@opponentCardBitmaps[@opponentCardIndexes[i]]
          @sprites["opponent#{@opponentCardIndexes[i]}"].z=(i==choice) ? 4 : 2
          @sprites["opponent#{@opponentCardIndexes[i]}"].x=(i==choice) ? 34 : 12
          @sprites["opponent#{@opponentCardIndexes[i]}"].y=y
          y+=48
        end
        lastChoice=choice
      end
      if choice==-1
        break
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.repeat?(Input::DOWN)
        pbPlayCursorSE()
        choice+=1
        choice=0 if choice>=numCards
      elsif Input.repeat?(Input::UP)
        pbPlayCursorSE()
        choice-=1
        choice=numCards-1 if choice<0
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE()
        choice=-1
      end
    end
    return choice
  end

  def pbPlayerChooseCard(numCards)
    if @battle.openHand
      @sprites["helpwindow"].text=_INTL("Choose a card, or check opponent with Z.")
    else
      @sprites["helpwindow"].text=_INTL("Choose a card.")
    end
    choice=0
    lastChoice=-1
    loop do
      if lastChoice!=choice
        y=34
        for i in 0...@cardIndexes.length
          @sprites["player#{@cardIndexes[i]}"].bitmap=@cardBitmaps[@cardIndexes[i]]
          @sprites["player#{@cardIndexes[i]}"].z=(i==choice) ? 4 : 2
          @sprites["player#{@cardIndexes[i]}"].x=(i==choice) ? Graphics.width-118 : Graphics.width-96
          @sprites["player#{@cardIndexes[i]}"].y=y
          y+=48
        end
        lastChoice=choice
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.repeat?(Input::DOWN)
        pbPlayCursorSE()
        choice+=1
        choice=0 if choice>=numCards
      elsif Input.repeat?(Input::UP)
        pbPlayCursorSE()
        choice-=1
        choice=numCards-1 if choice<0
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE()
        break
      elsif Input.trigger?(Input::A) && @battle.openHand
        pbPlayDecisionSE()
        pbViewOpponentCards(numCards)
        @sprites["helpwindow"].text=_INTL("Choose a card, or check opponent with Z.")
        choice=0
        lastChoice=-1
      end
    end
    return choice
  end

  def pbRefresh
    for i in 0...@battle.width*@battle.height
      x=i%@battle.width
      y=i/@battle.width
      if @boardSprites[i]
        owner=@battle.getOwner(x,y)
        @boardSprites[i].bitmap.dispose if @boardSprites[i].bitmap
        @boardSprites[i].bitmap=@boardCards[i].createBitmap(owner)
      end
    end
  end

  def pbEndPlaceCard(position, cardIndex)
    spriteIndex=@cardIndexes[cardIndex]
    boardIndex=position[1]*@battle.width+position[0]
    @boardSprites[boardIndex]=@sprites["player#{spriteIndex}"]
    @boardCards[boardIndex]=TriadCard.new(@playerCards[spriteIndex])
    pbRefresh
    @cardIndexes.delete_at(cardIndex)
    pbUpdateScore
  end

  def pbEndOpponentPlaceCard(position, cardIndex)
    spriteIndex=@opponentCardIndexes[cardIndex]
    boardIndex=position[1]*@battle.width+position[0]
    @boardSprites[boardIndex]=@sprites["opponent#{spriteIndex}"]
    @boardCards[boardIndex]=TriadCard.new(@opponentCards[spriteIndex])
    pbRefresh
    @opponentCardIndexes.delete_at(cardIndex)
    pbUpdateScore
  end

  def pbOpponentPlaceCard(triadCard, position, cardIndex)
    y=34
    for i in 0...@opponentCardIndexes.length
      sprite=@sprites["opponent#{@opponentCardIndexes[i]}"]
      if i!=cardIndex
        sprite.z=2
        sprite.y=y
        sprite.x=12
        y+=48
      else
        @opponentCardBitmaps[@opponentCardIndexes[i]]=triadCard.createBitmap(2)
        sprite.bitmap.dispose if sprite.bitmap
        sprite.bitmap=@opponentCardBitmaps[@opponentCardIndexes[i]]
        sprite.z=2
        sprite.x=Graphics.width/2 - 126 + position[0]*84
        sprite.y=46 + position[1]*84
      end
    end
  end

  def pbPlayerPlaceCard(card, cardIndex)
    @sprites["helpwindow"].text=_INTL("Place the card.")
    choice=0
    boardX=0
    boardY=0
    doRefresh=true
    loop do
      if doRefresh
        y=34
        for i in 0...@cardIndexes.length
          if i!=cardIndex
            @sprites["player#{@cardIndexes[i]}"].z=2
            @sprites["player#{@cardIndexes[i]}"].y=y
            @sprites["player#{@cardIndexes[i]}"].x=Graphics.width-96
            y+=48
          else
            @sprites["player#{@cardIndexes[i]}"].z=4
            @sprites["player#{@cardIndexes[i]}"].x=Graphics.width/2 - 126 + boardX*84
            @sprites["player#{@cardIndexes[i]}"].y=46 + boardY*84
          end
        end
        doRefresh=false
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.repeat?(Input::DOWN)
        pbPlayCursorSE()
        boardY+=1
        boardY=0 if boardY>=@battle.height
        doRefresh=true
      elsif Input.repeat?(Input::UP)
        pbPlayCursorSE()
        boardY-=1
        boardY=@battle.height-1 if boardY<0
        doRefresh=true
      elsif Input.repeat?(Input::LEFT)
        pbPlayCursorSE()
        boardX-=1
        boardX=@battle.width-1 if boardX<0
        doRefresh=true
      elsif Input.repeat?(Input::RIGHT)
        pbPlayCursorSE()
        boardX+=1
        boardX=0 if boardX>=@battle.width
        doRefresh=true
      elsif Input.trigger?(Input::B)
        return nil
      elsif Input.trigger?(Input::C)
        if @battle.isOccupied?(boardX,boardY)
          pbPlayBuzzerSE()
        else
          pbPlayDecisionSE()
          @sprites["player#{@cardIndexes[cardIndex]}"].z=2
          break
        end
      end
    end
    return [boardX,boardY] 
  end

  def pbChooseTriadCard(cardStorage)
    commands=[]
    chosenCards=[]
    for item in cardStorage
      commands.push(_INTL("{1} x{2}",PBSpecies.getName(item[0]),item[1]))
    end
    command=Window_CommandPokemonEx.newWithSize(commands,0,0,256,Graphics.height-64,@viewport)
    @sprites["helpwindow"].text=_INTL("Choose {1} cards to use for this duel.",@battle.maxCards)
    preview=Sprite.new(@viewport)
    preview.z=4
    preview.x=276
    preview.y=60
    index=-1
    chosenSprites=[]
    for i in 0...@battle.maxCards
      @sprites["player#{i}"]=Sprite.new(@viewport)
      @sprites["player#{i}"].z=2
      @sprites["player#{i}"].x=Graphics.width-96
      @sprites["player#{i}"].y=34+48*i
    end
    loop do
      Graphics.update
      Input.update
      pbUpdate
      command.update
      if command.index!=index
        preview.bitmap.dispose if preview.bitmap
        if command.index<cardStorage.length
          item=cardStorage[command.index]
          preview.bitmap=TriadCard.new(item[0]).createBitmap(1)
        end
        index=command.index
      end
      if Input.trigger?(Input::B)
        if chosenCards.length>0
          item=chosenCards.pop
          @battle.pbAdd(cardStorage,item)
          commands=[]
          for item in cardStorage
            commands.push(_INTL("{1} x{2}",PBSpecies.getName(item[0]),item[1]))
          end
          command.commands=commands
          index=-1
        else
          pbPlayBuzzerSE()
        end
      elsif Input.trigger?(Input::C)
        if chosenCards.length==@battle.maxCards
          break
        end
        item=cardStorage[command.index]
        if !item || (@battle.pbQuantity(cardStorage,item[0])==0)
          pbPlayBuzzerSE()
        else
          pbPlayDecisionSE()
          sprite=@sprites["player#{chosenCards.length}"]
          sprite.bitmap.dispose if sprite.bitmap
          @cardBitmaps[chosenCards.length]=TriadCard.new(item[0]).createBitmap(1)
          sprite.bitmap=@cardBitmaps[chosenCards.length]
          chosenCards.push(item[0])
          @battle.pbSubtract(cardStorage,item[0])
          commands=[]
          for item in cardStorage
            commands.push(_INTL("{1} x{2}",PBSpecies.getName(item[0]),item[1]))
          end
          command.commands=commands
          command.index=commands.length-1 if command.index>=commands.length
          index=-1
        end
      end
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        for i in 0...@battle.maxCards
          @sprites["player#{i}"].visible=(i<chosenCards.length)
        end
        if chosenCards.length==@battle.maxCards
          @sprites["helpwindow"].text=_INTL("{1} cards have been chosen.",@battle.maxCards)
          command.visible=false
          command.active=false
          preview.visible=false
        else
          @sprites["helpwindow"].text=_INTL("Choose {1} cards to use for this duel.",@battle.maxCards)
          command.visible=true
          command.active=true
          preview.visible=true
        end
      end
    end
    command.dispose
    preview.bitmap.dispose if preview.bitmap
    preview.dispose
    return chosenCards
  end
end



# Screen class for handling game logic
class TriadScreen
  attr_accessor :openHand,:countUnplayedCards
  attr_reader :width,:height

  def initialize(scene)
    @scene=scene
    @width              = 3
    @height             = 3
    @sameWins           = false
    @openHand           = false
    @wrapAround         = false
    @elements           = false
    @randomHand         = false
    @countUnplayedCards = false
    @trade              = 0
  end

  def board
    @board
  end

  def playerName
    @playerName
  end

  def opponentName
    @opponentName
  end

  def maxCards
    numcards=@width*@height
    if numcards%2 == 1
      numcards=numcards/2+1
    else
      numcards=numcards/2
    end
    return numcards
  end

  def isOccupied?(x,y)
    return @board[y*@width+x].owner!=0
  end

  def getOwner(x,y)
    return @board[y*@width+x].owner
  end

  def getPanel(x,y)
    return @board[y*@width+x]
  end

  def pbQuantity(items,item)
    return ItemStorageHelper.pbQuantity(items,$PokemonGlobal.triads.maxSize,item)
  end

  def pbAdd(items,item)
    return ItemStorageHelper.pbStoreItem(items,$PokemonGlobal.triads.maxSize,
       $PokemonGlobal.triads.maxPerSlot,item,1)
  end

  def pbSubtract(items,item)
    return ItemStorageHelper.pbDeleteItem(items,$PokemonGlobal.triads.maxSize,
       item,1)
  end

  def flipBoard(x,y,attackerParam=nil,recurse=false)
    panels=[x-1,y,x+1,y,x,y-1,x,y+1]
    panels[0]=(@wrapAround ? @width-1 : 0) if panels[0]<0 # left
    panels[2]=(@wrapAround ? 0 : @width-1) if panels[2]>@width-1 # right
    panels[5]=(@wrapAround ? @height-1 : 0) if panels[5]<0 # top
    panels[7]=(@wrapAround ? 0 : @height-1) if panels[7]>@height-1 # bottom
    attacker=attackerParam!=nil ? attackerParam : @board[y*@width+x]
    flips=[]
    return nil if attackerParam!=nil && @board[y*@width+x].owner!=0
    return nil if !attacker.card || attacker.owner==0
    for i in 0...4
      defenderX=panels[i*2]
      defenderY=panels[i*2+1]
      defender=@board[defenderY*@width+defenderX]
      next if !defender.card
      if attacker.owner!=defender.owner
        attack=attacker.attack(i)
        defense=defender.defense(i)
        if @elements
          # If attacker's type matches the tile's element, add
          # a bonus of 1 (only for original attacker, not combos)
          attack+=1 if !recurse && attacker.type==attacker.card.type
        else
          # Modifier depends on opponent's Pokémon type:
          # +1 - Super effective
          # -1 - Not very effective
          # -2 - Immune
#         attack+=attacker.bonus(defender)
        end
#       p [attacker.card.north,attacker.card.west,
#          attacker.card.east,attacker.card.south],
#          [defender.card.north,defender.card.west,
#          defender.card.east,defender.card.south],
#          [attack,defense,attacker.bonus(defender)] if attackerParam==nil
        if attack>defense || (attack==defense && @sameWins)
          flips.push([defenderX,defenderY])
          if attackerParam==nil
            defender.owner=attacker.owner
            if @sameWins
              # Combo with the "sameWins" rule
              ret=flipBoard(defenderX,defenderY,nil,true)
              flips.concat(ret) if ret
            end
          else
            if @sameWins
              # Combo with the "sameWins" rule
              ret=flipBoard(defenderX,defenderY,attackerParam,true)
              flips.concat(ret) if ret
            end
          end
        end
      end
    end
    return flips
  end

# If pbStartScreen includes parameters, it should
# pass the parameters to pbStartScene.
  def pbStartScreen(opponentName,minLevel,maxLevel,rules=nil,oppdeck=nil,prize=nil)
    if minLevel<0 || minLevel>9
      raise _INTL("Minimum level must be 0 through 9.")
    end
    if maxLevel<0 || maxLevel>9
      raise _INTL("Maximum level must be 0 through 9.")
    end
    if maxLevel<minLevel
      raise _INTL("Maximum level shouldn't be less than the minimum level.")
    end
    if rules && rules.is_a?(Array) && rules.length>0
      for rule in rules
        @sameWins           = true if rule=="samewins"
        @openHand           = true if rule=="openhand"
        @wrapAround         = true if rule=="wrap"
        @elements           = true if rule=="elements"
        @randomHand         = true if rule=="randomhand"
        @countUnplayedCards = true if rule=="countunplayed"
        @trade              = 1    if rule=="direct"
        @trade              = 2    if rule=="winall"
      end
    end
    @triadCards=[]
    if !$PokemonGlobal
      $PokemonGlobal=PokemonGlobalMetadata.new
    end
    count=0
    for i in 0...$PokemonGlobal.triads.length
      item=$PokemonGlobal.triads[i]
      ItemStorageHelper.pbStoreItem(@triadCards,
         $PokemonGlobal.triads.maxSize,
         $PokemonGlobal.triads.maxPerSlot,
         item[0],item[1]
      )
      count+=item[1] # Add item count to total count
    end
    @board=[]
    @playerName=$Trainer ? $Trainer.name : "Trainer"
    @opponentName=opponentName
    for i in 0...@width*@height
      square=TriadSquare.new
      if @elements
        begin
          square.type=rand(PBTypes.maxValue+1)
        end until !PBTypes.isPseudoType?(square.type)
      end
      @board.push(square)
    end
    @scene.pbStartScene(self) # (param1, param2)
    # Check whether there are enough cards.
    if count<self.maxCards
      @scene.pbDisplayPaused(_INTL("You don't have enough cards."))
      @scene.pbEndScene
      return 0
    end
    # Set the player's cards.
    cards=[]
    if @randomHand   # Determine hand at random
      self.maxCards.times do
        randCard=@triadCards[rand(@triadCards.length)]
        pbSubtract(@triadCards,randCard[0])
        cards.push(randCard[0]) 
      end
      @scene.pbShowPlayerCards(cards)
    else
      cards=@scene.pbChooseTriadCard(@triadCards)
    end
    # Set the opponent's cards.
    if oppdeck && oppdeck.is_a?(Array) && oppdeck.length==self.maxCards # Preset
      opponentCards=[]
      for i in oppdeck
        card=getID(PBSpecies,i)
        if card<=0
          @scene.pbDisplayPaused(_INTL("Opponent has an illegal card, \"{1}\".",i))
          @scene.pbEndScene
          return 0
        end
        opponentCards.push(card)
      end
    else
      candidates=[]
      while candidates.length<200
        card=0
        loop do
          card=rand(PBSpecies.maxValue)+1
          cname=getConstantName(PBSpecies,card) rescue nil
          break if cname
        end
        triad=TriadCard.new(card)
        total=triad.north+triad.south+triad.east+triad.west
        # Add random species and its total point count
        candidates.push([card,total])
        if candidates.length<200 && $Trainer && $Trainer.owned[card]
          # Add again if Trainer owns the species
          candidates.push([card,total])
        end
      end
      # sort by total point count
      candidates.sort!{|a,b| a[1]<=>b[1] }
      minIndex=minLevel*20
      maxIndex=maxLevel*20+20
      opponentCards=[]
      for i in 0...self.maxCards
        # generate random card based on level
        index=minIndex+rand(maxIndex-minIndex)
        opponentCards.push(candidates[index][0])
      end
    end
    originalCards=cards.clone
    originalOpponentCards=opponentCards.clone
    @scene.pbNotifyCards(cards.clone,opponentCards.clone)
    @scene.pbShowOpponentCards(opponentCards)
    @scene.pbDisplay(_INTL("Choosing the starting player..."))
    @scene.pbUpdateScore
    playerTurn=false
    if rand(2)==0
      @scene.pbDisplay(_INTL("{1} will go first.",@playerName))
      playerTurn=true
    else
      @scene.pbDisplay(_INTL("{1} will go first.",@opponentName))
      playerTurn=false
    end
    for i in 0...@width*@height
      position=nil
      triadCard=nil
      cardIndex=0
      if playerTurn
        # Player's turn
        while !position
          cardIndex=@scene.pbPlayerChooseCard(cards.length)
          triadCard=TriadCard.new(cards[cardIndex])
          position=@scene.pbPlayerPlaceCard(triadCard,cardIndex)
        end
      else
        # Opponent's turn
        @scene.pbDisplay(_INTL("{1} is making a move...",@opponentName))    
        scores=[]
        for cardIndex in 0...opponentCards.length
          square=TriadSquare.new
          square.card=TriadCard.new(opponentCards[cardIndex])
          square.owner=2
          for i in 0...@width*@height
            x=i%@width
            y=i/@width
            square.type=@board[i].type
            flips=flipBoard(x,y,square)
            if flips!=nil
              scores.push([cardIndex,x,y,flips.length])
            end
          end
        end
        # Sort by number of flips
        scores.sort!{|a,b| 
           if b[3]==a[3]
             next [-1,1,0][rand(3)]
           else
             next b[3]<=>a[3]
           end
        } 
        scores=scores[0,opponentCards.length] # Get the best results
        if scores.length==0
          @scene.pbDisplay(_INTL("{1} can't move somehow...",@opponentName))
          playerTurn=!playerTurn
          continue
        end
        result=scores[rand(scores.length)]
        cardIndex=result[0]
        triadCard=TriadCard.new(opponentCards[cardIndex])
        position=[result[1],result[2]]
        @scene.pbOpponentPlaceCard(triadCard,position,cardIndex)
      end
      boardIndex=position[1]*@width+position[0]
      board[boardIndex].card=triadCard
      board[boardIndex].owner=playerTurn ? 1 : 2
      flipBoard(position[0],position[1])
      if playerTurn
        cards.delete_at(cardIndex)
        @scene.pbEndPlaceCard(position,cardIndex)
      else
        opponentCards.delete_at(cardIndex)
        @scene.pbEndOpponentPlaceCard(position,cardIndex)
      end
      playerTurn=!playerTurn
    end
    # Determine the winner
    playerCount=0
    opponentCount=0
    for i in 0...@width*@height
      playerCount+=1 if board[i].owner==1
      opponentCount+=1 if board[i].owner==2
    end
    if @countUnplayedCards
      playerCount+=cards.length
      opponentCount+=opponentCards.length
    end
    result=0
    if playerCount==opponentCount
      @scene.pbDisplayPaused(_INTL("The game is a draw."))
      result=3
      case @trade
        when 1
          # Keep only cards of your color
          for card in originalCards
            $PokemonGlobal.triads.pbDeleteItem(card)
          end
          for i in cards
            $PokemonGlobal.triads.pbStoreItem(i)
          end
          for i in 0...@width*@height
            if board[i].owner==1
              $PokemonGlobal.triads.pbStoreItem(board[i].card.species)
            end
          end
          @scene.pbDisplayPaused(_INTL("Kept all cards of your color."))
      end
    elsif playerCount>opponentCount
      @scene.pbDisplayPaused(_INTL("{1} won against {2}.",@playerName,@opponentName))
      result=1
      if prize
        card=getID(PBSpecies,prize)
        if card>0 && $PokemonGlobal.triads.pbStoreItem(card)
          cardname=PBSpecies.getName(card)
          @scene.pbDisplayPaused(_INTL("Got opponent's {1} card.",cardname))
        end
      else
        case @trade
          when 0
            # Gain 1 random card from opponent's deck
            card=originalOpponentCards[rand(originalOpponentCards.length)]
            if $PokemonGlobal.triads.pbStoreItem(card)
              cardname=PBSpecies.getName(card)
              @scene.pbDisplayPaused(_INTL("Got opponent's {1} card.",cardname))
            end
          when 1
            # Keep only cards of your color
            for card in originalCards
              $PokemonGlobal.triads.pbDeleteItem(card)
            end
            for i in cards
              $PokemonGlobal.triads.pbStoreItem(i)
            end
            for i in 0...@width*@height
              if board[i].owner==1
                $PokemonGlobal.triads.pbStoreItem(board[i].card.species)
              end
            end
            @scene.pbDisplayPaused(_INTL("Kept all cards of your color."))
          when 2
            # Gain all opponent's cards
            for card in originalOpponentCards
              $PokemonGlobal.triads.pbStoreItem(card)
            end
            @scene.pbDisplayPaused(_INTL("Got all opponent's cards."))
        end
      end
    else
      @scene.pbDisplayPaused(_INTL("{1} lost against {2}.",@playerName,@opponentName))
      result=2
      case @trade
        when 0
          # Lose 1 random card from your deck
          card=originalCards[rand(originalCards.length)]
          $PokemonGlobal.triads.pbDeleteItem(card)
          cardname=PBSpecies.getName(card)
          @scene.pbDisplayPaused(_INTL("Opponent won your {1} card.",cardname))
        when 1
          # Keep only cards of your color
          for card in originalCards
            $PokemonGlobal.triads.pbDeleteItem(card)
          end
          for i in cards
            $PokemonGlobal.triads.pbStoreItem(i)
          end
          for i in 0...@width*@height
            if board[i].owner==1
              $PokemonGlobal.triads.pbStoreItem(board[i].card.species)
            end
          end
          @scene.pbDisplayPaused(_INTL("Kept all cards of your color.",cardname))
        when 2
          # Lose all your cards
          for card in originalCards
            $PokemonGlobal.triads.pbDeleteItem(card)
          end
          @scene.pbDisplayPaused(_INTL("Opponent won all your cards."))
      end
    end
    @scene.pbEndScene
    return result
  end
end



class PokemonGlobalMetadata
  attr_accessor :triads

  def triads
    @triads=TriadStorage.new if !@triads
    return @triads
  end
end



class TriadStorage
  def maxSize
    return PBSpecies.getCount
  end

  def maxPerSlot
    return 99
  end

  def initialize
    @items=[]
  end

  def empty?
    return @items.length==0
  end

  def length
    @items.length
  end

  def [](i)
    @items[i]
  end

  def getItem(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][0]
    end
  end

  def getCount(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][1]
    end
  end

  def pbQuantity(item)
    return ItemStorageHelper.pbQuantity(@items,self.maxSize,item)
  end

  def pbDeleteItem(item,qty=1)
    return ItemStorageHelper.pbDeleteItem(@items,self.maxSize,item,qty)
  end

  def pbCanStore?(item,qty=1)
    return ItemStorageHelper.pbCanStore?(@items,self.maxSize,self.maxPerSlot,item,qty)
  end

  def pbStoreItem(item,qty=1)
    return ItemStorageHelper.pbStoreItem(@items,self.maxSize,self.maxPerSlot,item,qty)
  end
end



def pbBuyTriads
  commands=[]
  realcommands=[]
  for i in 1..PBSpecies.maxValue
    if $Trainer.owned[i]
      speciesname=PBSpecies.getName(i)
      next if !speciesname
      price=pbCommaNumber(TriadCard.new(i).price)
      commands.push([price,speciesname,_INTL("{1} ${2}",speciesname,price),i])
    end
  end
  if commands.length==0
    Kernel.pbMessage(_INTL("There are no cards that you can buy.")) 
    return
  end
  commands.sort!{|a,b| 
     if a[0]==b[0]
       a[1]<=>b[1] # sort by name
     else
       a[0]<=>b[0] # sort by price
     end
  }
  for command in commands
    realcommands.push(command[2])
  end
  # Scroll right before showing screen
  pbScrollMap(4,3,5)
  cmdwindow=Window_CommandPokemonEx.newWithSize(realcommands,0,0,256,Graphics.height)
  cmdwindow.z=99999
  moneyString=_INTL("${1}",pbCommaNumber($Trainer.money))
  goldwindow=Window_UnformattedTextPokemon.newWithSize(
     _INTL("Money:\n{1}",moneyString),0,0,32,32)
  goldwindow.resizeToFit(goldwindow.text,Graphics.width)
  goldwindow.y=0
  goldwindow.x=Graphics.width-goldwindow.width
  goldwindow.z=99999
  Graphics.frame_reset
  done=false
  while !done
    loop do
      Graphics.update
      Input.update
      cmdwindow.active=true
      cmdwindow.update
      goldwindow.update
      if Input.trigger?(Input::B)
        done=true
        break
      end
      if Input.trigger?(Input::C)
        price=commands[cmdwindow.index][0]
        item=commands[cmdwindow.index][3]
        itemname=commands[cmdwindow.index][1]
        cmdwindow.active=false
        cmdwindow.update
        if $Trainer.money<price
          Kernel.pbMessage(_INTL("You don't have enough money."))
          break
        end
        maxafford=(price<=0) ? 99 : $Trainer.money/price
        maxafford=99 if maxafford>99
        params=ChooseNumberParams.new
        params.setRange(1,maxafford)
        params.setInitialValue(1)
        params.setCancelValue(0)
        quantity=Kernel.pbMessageChooseNumber(
           _INTL("The {1} card?  Certainly.\r\nHow many would you like?",itemname),params)
        if quantity>0
          price*=quantity
          if !Kernel.pbConfirmMessage(_INTL("{1}, and you want {2}.\r\nThat will be ${3}.  OK?",itemname,quantity,pbCommaNumber(price)))
            break
          end
          if $Trainer.money<price
            Kernel.pbMessage(_INTL("You don't have enough money."))
            break
          end
          if !$PokemonGlobal.triads.pbCanStore?(item,quantity)
            Kernel.pbMessage(_INTL("You have no room for more cards."))
          else
            $PokemonGlobal.triads.pbStoreItem(item,quantity)
            $Trainer.money-=price
            moneyString=_INTL("${1}",pbCommaNumber($Trainer.money))
            goldwindow.text=_INTL("Money:\n{1}",moneyString)
            Kernel.pbMessage(_INTL("Here you are!\r\nThank you!"))
          end
        end
      end
    end
  end
  cmdwindow.dispose
  goldwindow.dispose
  Graphics.frame_reset
  # Scroll right before showing screen
  pbScrollMap(6,3,5)
end

def pbSellTriads
  commands=[]
  for i in 0...$PokemonGlobal.triads.length
    item=$PokemonGlobal.triads[i]
    speciesname=PBSpecies.getName(item[0])
    commands.push(_INTL("{1} x{2}",speciesname,item[1]))
  end
  commands.push(_INTL("CANCEL"))
  if commands.length==1
    Kernel.pbMessage(_INTL("You have no cards."))
    return
  end
  # Scroll right before showing screen
  pbScrollMap(4,3,5)
  cmdwindow=Window_CommandPokemonEx.newWithSize(commands,0,0,256,Graphics.height)
  cmdwindow.z=99999
  moneyString=_INTL("${1}",pbCommaNumber($Trainer.money))
  goldwindow=Window_UnformattedTextPokemon.newWithSize(
     _INTL("Money:\n{1}",moneyString),0,0,32,32)
  goldwindow.resizeToFit(goldwindow.text,Graphics.width)
  goldwindow.y=0
  goldwindow.x=Graphics.width-goldwindow.width
  goldwindow.z=99999
  done=false
  Graphics.frame_reset
  while !done
    loop do
      Graphics.update
      Input.update
      cmdwindow.active=true
      cmdwindow.update
      goldwindow.update
      if Input.trigger?(Input::B)
        done=true
        break
      end
      if Input.trigger?(Input::C)
        if cmdwindow.index>=$PokemonGlobal.triads.length
          done=true
          break
        end
        item=$PokemonGlobal.triads.getItem(cmdwindow.index)
        itemname=PBSpecies.getName(item)
        quantity=$PokemonGlobal.triads.pbQuantity(item)
        price=TriadCard.new(item).price
        if price==0
          pbDisplayPaused(_INTL("The {1} card?  Oh, no.\r\nI can't buy that.",itemname))
          break
        end
        cmdwindow.active=false
        cmdwindow.update
        if quantity>1
          params=ChooseNumberParams.new
          params.setRange(1,quantity)
          params.setInitialValue(1)
          params.setCancelValue(0)
          quantity=Kernel.pbMessageChooseNumber(
             _INTL("The {1} card?  How many would you like to sell?",itemname),params)
        end
        if quantity>0
          price/=4
          price*=quantity
          if Kernel.pbConfirmMessage(_INTL("I can pay ${1}.  Would that be OK?",pbCommaNumber(price)))
            $Trainer.money+=price
            moneyString=_INTL("${1}",$Trainer.money)
            goldwindow.text=_INTL("Money:\n{1}",moneyString)
            $PokemonGlobal.triads.pbDeleteItem(item,quantity)
            Kernel.pbMessage(_INTL("Turned over the {1} card and received ${2}.",itemname,pbCommaNumber(price)))
            commands=[]
            for i in 0...$PokemonGlobal.triads.length
              item=$PokemonGlobal.triads[i]
              speciesname=PBSpecies.getName(item[0])
              commands.push(_INTL("{1} x{2}",speciesname,item[1]))
            end
            commands.push(_INTL("CANCEL"))
            cmdwindow.commands=commands
            break
          end
        end
      end
    end
  end
  cmdwindow.dispose
  goldwindow.dispose
  Graphics.frame_reset
  # Scroll right before showing screen
  pbScrollMap(6,3,5)
end

def pbTriadList
  commands=[]
  for i in 0...$PokemonGlobal.triads.length
    item=$PokemonGlobal.triads[i]
    speciesname=PBSpecies.getName(item[0])
    commands.push(_INTL("{1} x{2}",speciesname,item[1]))
  end
  commands.push(_INTL("CANCEL"))
  if commands.length==1
    Kernel.pbMessage(_INTL("You have no cards."))
    return
  end
  cmdwindow=Window_CommandPokemonEx.newWithSize(commands,0,0,256,Graphics.height)
  cmdwindow.z=99999
  sprite=Sprite.new
  sprite.z=99999
  sprite.x=256+40
  sprite.y=48
  moneyString=_INTL("${1}",$Trainer.money)
  done=false
  lastIndex=-1
  while !done
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      if lastIndex!=cmdwindow.index
        sprite.bitmap.dispose if sprite.bitmap
        if cmdwindow.index<$PokemonGlobal.triads.length
          sprite.bitmap=TriadCard.new($PokemonGlobal.triads.getItem(cmdwindow.index)).createBitmap(1)
        end
        lastIndex=cmdwindow.index
      end
      if Input.trigger?(Input::B)
        done=true
        break
      end
      if Input.trigger?(Input::C)
        if cmdwindow.index>=$PokemonGlobal.triads.length
          done=true
          break
        end
      end
    end
  end
  cmdwindow.dispose
  sprite.dispose
end

def pbTriadDuel(name,minLevel,maxLevel,rules=nil,oppdeck=nil,prize=nil)
  ret=0
  pbFadeOutInWithMusic(99999){
     scene=TriadScene.new
     screen=TriadScreen.new(scene)
     ret=screen.pbStartScreen(name,minLevel,maxLevel,rules,oppdeck,prize)
  }
  return ret
end

def pbGiveTriadCard(species,quantity=1)
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  return false if !species || species<=0
  if $PokemonGlobal.triads.pbCanStore?(species,quantity)
    $PokemonGlobal.triads.pbStoreItem(species,quantity)
    return true
  end
  return false
end