class PokeBattle_BattleArena < PokeBattle_Battle
  def initialize(*arg)
    super
    @battlerschanged=true
    @mind=[0,0]
    @skill=[0,0]
    @starthp=[0,0]
    @count=0
    @partyindexes=[0,0]
  end

  def pbDoubleBattleAllowed?()
    return false
  end

  def pbEnemyShouldWithdraw?(index)
    return false
  end

  def pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
    if showMessages
      thispkmn=@battlers[idxPokemon]
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis))
    end
    return false
  end

  def pbSwitch(favorDraws=false)
    if !favorDraws
      return if @decision>0
      pbJudge()
      return if @decision>0
    else
      return if @decision==5
      pbJudge()
      return if @decision>0
    end
    switched=[]
    if @battlers[0].isFainted? && @partyindexes[0]+1<self.pbParty(0).length
      @partyindexes[0]+=1
      newpoke=@partyindexes[0]
      pbMessagesOnReplace(0,newpoke)
      pbReplace(0,newpoke,false)
      pbOnActiveOne(@battlers[0])
      switched.push(0)
    end
    if @battlers[1].isFainted? && @partyindexes[1]+1<self.pbParty(1).length
      @partyindexes[1]+=1  
      newenemy=@partyindexes[1]
      pbMessagesOnReplace(1,newenemy)
      pbReplace(1,newenemy,false)
      pbOnActiveOne(@battlers[1])
      switched.push(1)
    end
    if switched.length>0
      priority=pbPriority
      for i in priority
        i.pbAbilitiesOnSwitchIn(true) if switched.include?(i.index)
      end
    end
  end

  def pbOnActiveAll
    @battlerschanged=true
    @mind[0]=0
    @mind[1]=0
    @skill[0]=0
    @skill[1]=0
    @starthp[0]=battlers[0].hp
    @starthp[1]=battlers[1].hp
    @count=0
    return super 
  end

  def pbOnActiveOne(*arg)
    @battlerschanged=true
    @mind[0]=0
    @mind[1]=0
    @skill[0]=0
    @skill[1]=0
    @starthp[0]=battlers[0].hp
    @starthp[1]=battlers[1].hp
    @count=0
    return super 
  end

  def pbMindScore(move)
    if move.function==0xAA || # Detect/Protect
       move.function==0xE8 || # Endure
       move.function==0x12    # Fake Out
      return -1
    end
    if move.function==0x71 || # Counter
       move.function==0x72 || # Mirror Coat
       move.function==0xD4    # Bide
      return 0
    end
    if move.basedamage==0
      return 0
    else
      return 1
    end
  end

  def pbCommandPhase
    if @battlerschanged
      @scene.pbBattleArenaBattlers(@battlers[0],@battlers[1])
      @battlerschanged=false
      @count=0
    end
    super
    return if @decision!=0
    # Update mind rating (asserting that a move was chosen)
    # TODO: Actually done at Pokémon's turn
    for i in 0...2
      if @choices[i][2] && @choices[i][0]==1
        @mind[i]+=pbMindScore(@choices[i][2])
      end
    end
  end

  def pbEndOfRoundPhase
    super
    return if @decision!=0
    @count+=1
    # Update skill rating
    for i in 0...2
      @skill[i]+=self.successStates[i].skill
    end
    #PBDebug.log("[Mind: #{@mind.inspect}, Skill: #{@skill.inspect}]")
    if @count==3
      points=[0,0]
      @battlers[0].pbCancelMoves
      @battlers[1].pbCancelMoves
      ratings1=[0,0,0]
      ratings2=[0,0,0]
      if @mind[0]==@mind[1]
        ratings1[0]=1
        ratings2[0]=1
      elsif @mind[0]>@mind[1]
        ratings1[0]=2
      else
        ratings2[0]=2
      end
      if @skill[0]==@skill[1]
        ratings1[1]=1
        ratings2[1]=1
      elsif @skill[0]>@skill[1]
        ratings1[1]=2
      else
        ratings2[1]=2
      end
      body=[0,0]
      body[0]=((@battlers[0].hp*100)/[@starthp[0],1].max).floor
      body[1]=((@battlers[1].hp*100)/[@starthp[1],1].max).floor
      if body[0]==body[1]
        ratings1[2]=1
        ratings2[2]=1
      elsif body[0]>body[1]
        ratings1[2]=2
      else
        ratings2[2]=2
      end
      @scene.pbBattleArenaJudgment(@battlers[0],@battlers[1],ratings1.clone,ratings2.clone)
      points=[0,0]
      for i in 0...3
        points[0]+=ratings1[i]
        points[1]+=ratings2[i]
      end
      if points[0]==points[1]
        pbDisplay(_INTL("{1} tied the opponent\n{2} in a referee's decision!",
           @battlers[0].name,@battlers[1].name)) 
        @battlers[0].hp=0 # Note: Pokemon doesn't really lose HP, but the effect is mostly the same
        @battlers[0].pbFaint(false)
        @battlers[1].hp=0  
        @battlers[1].pbFaint(false)
      elsif points[0]>points[1]
        pbDisplay(_INTL("{1} defeated the opponent\n{2} in a referee's decision!",
           @battlers[0].name,@battlers[1].name))
        @battlers[1].hp=0  
        @battlers[1].pbFaint(false)
      else
        pbDisplay(_INTL("{1} lost to the opponent\n{2} in a referee's decision!",
           @battlers[0].name,@battlers[1].name))
        @battlers[0].hp=0  
        @battlers[0].pbFaint(false)
      end
      pbGainEXP
      pbSwitch
    end 
  end
end



class PokeBattle_Scene
  def updateJudgment(window,phase,battler1,battler2,ratings1,ratings2)
    total1=0
    total2=0
    for i in 0...phase
      total1+=ratings1[i]
      total2+=ratings2[i]
    end
    window.contents.clear
    pbSetSystemFont(window.contents)
    textpos=[
       [battler1.name,64,0,2,Color.new(248,0,0),Color.new(208,208,200)],
       [_INTL("VS"),144,0,2,Color.new(72,72,72),Color.new(208,208,200)],
       [battler2.name,224,0,2,Color.new(72,72,72),Color.new(208,208,200)],
       [_INTL("Mind"),144,48,2,Color.new(72,72,72),Color.new(208,208,200)],
       [_INTL("Skill"),144,80,2,Color.new(72,72,72),Color.new(208,208,200)],
       [_INTL("Body"),144,112,2,Color.new(72,72,72),Color.new(208,208,200)],
       [sprintf("%d",total1),64,160,2,Color.new(72,72,72),Color.new(208,208,200)],
       [_INTL("Judgment"),144,160,2,Color.new(72,72,72),Color.new(208,208,200)],
       [sprintf("%d",total2),224,160,2,Color.new(72,72,72),Color.new(208,208,200)]
    ]
    pbDrawTextPositions(window.contents,textpos)
    images=[]
    for i in 0...phase
      y=[48,80,112][i]
      x=(ratings1[i]==ratings2[i]) ? 64 : ((ratings1[i]>ratings2[i]) ? 0 : 32)
      images.push(["Graphics/Pictures/judgment",64-16,y,x,0,32,32])
      x=(ratings1[i]==ratings2[i]) ? 64 : ((ratings1[i]<ratings2[i]) ? 0 : 32)
      images.push(["Graphics/Pictures/judgment",224-16,y,x,0,32,32])
    end
    pbDrawImagePositions(window.contents,images)
    window.contents.fill_rect(16,150,256,4,Color.new(80,80,80))
  end

  def pbBattleArenaBattlers(battler1,battler2)
    Kernel.pbMessage(_INTL("REFEREE: {1} VS {2}!\nCommence battling!\\wtnp[20]",
       battler1.name,battler2.name)) { pbUpdate }
  end

  def pbBattleArenaJudgment(battler1,battler2,ratings1,ratings2)
    msgwindow=nil
    dimmingvp=nil
    infowindow=nil
    begin
      msgwindow=Kernel.pbCreateMessageWindow
      dimmingvp=Viewport.new(0,0,Graphics.width,Graphics.height-msgwindow.height)
      Kernel.pbMessageDisplay(msgwindow,
         _INTL("REFEREE: That's it! We will now go to judging to determine the winner!\\wtnp[20]")) {
         pbUpdate; dimmingvp.update }
      dimmingvp.z=99999
      infowindow=SpriteWindow_Base.new(80,0,320,224)
      infowindow.contents=Bitmap.new(
         infowindow.width-infowindow.borderX,
         infowindow.height-infowindow.borderY)
      infowindow.z=99999
      infowindow.visible=false
      for i in 0..10
        pbGraphicsUpdate
        pbInputUpdate
        msgwindow.update
        dimmingvp.update
        dimmingvp.color=Color.new(0,0,0,i*128/10)
      end
      updateJudgment(infowindow,0,battler1,battler2,ratings1,ratings2)
      infowindow.visible=true
      for i in 0..10
        pbGraphicsUpdate
        pbInputUpdate
        msgwindow.update
        dimmingvp.update
        infowindow.update
      end
      updateJudgment(infowindow,1,battler1,battler2,ratings1,ratings2)
      Kernel.pbMessageDisplay(msgwindow,
         _INTL("REFEREE: Judging category 1, Mind!\nThe Pokemon showing the most guts!\\wtnp[40]")) { 
         pbUpdate; dimmingvp.update; infowindow.update } 
      updateJudgment(infowindow,2,battler1,battler2,ratings1,ratings2)
      Kernel.pbMessageDisplay(msgwindow,
         _INTL("REFEREE: Judging category 2, Skill!\nThe Pokemon using moves the best!\\wtnp[40]")) { 
         pbUpdate; dimmingvp.update; infowindow.update } 
      updateJudgment(infowindow,3,battler1,battler2,ratings1,ratings2)
      Kernel.pbMessageDisplay(msgwindow,
         _INTL("REFEREE: Judging category 3, Body!\nThe Pokemon with the most vitality!\\wtnp[40]")) { 
         pbUpdate; dimmingvp.update; infowindow.update }
      total1=0
      total2=0
      for i in 0...3
        total1+=ratings1[i]
        total2+=ratings2[i]
      end
      if total1==total2
        Kernel.pbMessageDisplay(msgwindow,
           _INTL("REFEREE: Judgment: {1} to {2}!\nWe have a draw!\\wtnp[40]",total1,total2)) { 
          pbUpdate; dimmingvp.update; infowindow.update }
      elsif total1>total2
        Kernel.pbMessageDisplay(msgwindow,
           _INTL("REFEREE: Judgment: {1} to {2}!\nThe winner is {3}'s {4}!\\wtnp[40]",
           total1,total2,@battle.pbGetOwner(battler1.index).name,battler1.name)) { 
           pbUpdate; dimmingvp.update; infowindow.update }
      else
        Kernel.pbMessageDisplay(msgwindow,
           _INTL("REFEREE: Judgment: {1} to {2}!\nThe winner is {3}!\\wtnp[40]",
           total1,total2,battler2.name)) { 
           pbUpdate; dimmingvp.update; infowindow.update }
      end
      infowindow.visible=false
      msgwindow.visible=false
      for i in 0..10
        pbGraphicsUpdate
        pbInputUpdate
        msgwindow.update
        dimmingvp.update
        dimmingvp.color=Color.new(0,0,0,(10-i)*128/10)
      end
      ensure
      Kernel.pbDisposeMessageWindow(msgwindow)
      dimmingvp.dispose
      infowindow.contents.dispose
      infowindow.dispose
    end
  end
end