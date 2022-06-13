def pbPokemonString(pkmn)
  if pkmn.is_a?(PokeBattle_Battler) && !pkmn.pokemon
    return ""
  end
  status=""
  if pkmn.hp<=0
    status=" [FNT]"
  else
    case pkmn.status
      when PBStatuses::SLEEP
        status=" [SLP]"
      when PBStatuses::FROZEN
        status=" [FRZ]"
      when PBStatuses::BURN
        status=" [BRN]"
      when PBStatuses::PARALYSIS
        status=" [PAR]"
      when PBStatuses::POISON
        status=" [PSN]"
    end
  end
  return "#{pkmn.name} (Lv. #{pkmn.level})#{status} HP: #{pkmn.hp}/#{pkmn.totalhp}"
end



class Window_Pokemon < SpriteWindow_Base
  attr_reader :highlighted

  def highlighted=(value)
    @highlighted=value
    refresh
  end

  def initialize(battler)
    @battler=battler
    @highlighted=false
    @highlightOpacity=255
    @highlightIncr=-2
    super(0,0,480,64)
    self.contents=Bitmap.new(self.width-32,self.height-32)
    self.z=100000
    refresh
  end

  def update
    if @highlighted
      @highlightIncr=-5 if @highlightOpacity>=255
      @highlightIncr=5 if @highlightOpacity<=160
      self.opacity=@highlightOpacity
      self.contents_opacity=@highlightOpacity
      @highlightOpacity+=@highlightIncr
    elsif self.opacity!=255 || self.contents_opacity!=255
      self.opacity=255
      self.contents_opacity=255
    end
    super
  end

  def refresh
    self.contents.clear
    self.contents.font.color = Color.new(0,0,0)
    str=pbPokemonString(@battler)
    self.contents.draw_text(0, 0, self.width-32, 32, str, 0)  
  end
end



class Window_SimpleText < SpriteWindow_Base
  attr_reader :text
  attr_reader :lines

  def text=(value)
    @text=value
    refresh
  end

  def initialize(text,lines)
    @text=text
    @lines=lines
    @lines=1 if @lines<1
    super(0,0,480,32+(@lines*32))
    self.contents=Bitmap.new(self.width-32,self.height-32)
    self.z=100000
    refresh
  end

  def refresh
    self.contents.clear
    self.contents.font.color = Color.new(0,0,0)
    textmsg=@text.clone
    x=y=0
    while ((c = textmsg.slice!(/\S*\s?/m)) != nil)
      break if c==""
      textwidth=self.contents.text_size(c).width
      if c=="\n" 
        # Add 1 to y
        y += 1
        x = 0
        next
      end
      if x>0 && x+textwidth>=self.contents.width
        # Add 1 to y
        y += 1
        x = 0
      end
      # Draw text
      self.contents.draw_text(4 + x, 32 * y, textwidth, 32, c)
      # Add x to drawn text width
      x += textwidth
    end
  end
end



class PokeBattle_DebugScene
  def initialize
    @battle=nil
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @pkmnwindows=[nil,nil,nil,nil]
  end

  def pbDisplayMessage(msg,brief=false)
    pbRefresh
    cw = Window_SimpleText.new(msg,4)
    cw.y=256
    i=0
    loop do
      Graphics.update
      Input.update
      cw.update
      if i==80
        cw.dispose
        return
      end
      if Input.trigger?(Input::C)
        cw.dispose
        return
      end
      i+=1
    end
  end

  def pbDisplayPausedMessage(msg)
    cw = Window_SimpleText.new(msg,4)
    cw.y=256
    cw.pause=true
    loop do
      Graphics.update
      Input.update
      cw.update
      if Input.trigger?(Input::C)
        cw.dispose
        return
      end
    end
  end

  def pbDisplayConfirmMessage(msg)
    dw = Window_SimpleText.new(msg,4)
    dw.y=256
    commands=["YES","NO"]
    cw = Window_Command.new(96, commands)
    cw.x=384
    cw.y=160
    cw.index=0
    pbRefresh
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw)
      if Input.trigger?(Input::B)
        cw.dispose
        dw.dispose
        return false
      end
      if Input.trigger?(Input::C)
        cw.dispose
        dw.dispose
        return (cw.index==0)?true:false
      end
    end 
  end

  def pbFrameUpdate(cw)
    cw.update if cw
    for i in 0..3
      @pkmnwindows[i].update if @pkmnwindows[i]
    end 
#   @exceptwindow.text="Exceptions: #{$PBDebugExceptions}"
#   @exceptwindow.update
  end

  def pbRefresh
    for i in 0..3
      @pkmnwindows[i].refresh if @pkmnwindows[i]
    end 
#   @exceptwindow.refresh
  end

# Called whenever a new round begins.
  def pbBeginCommandPhase
  end

# Called whenever the battle begins
  def pbStartBattle(battle)
    @battle=battle
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    numwindows=battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      @pkmnwindows[i]=Window_Pokemon.new(@battle.battlers[i])
      @pkmnwindows[i].y=i*64
    end
#   @exceptwindow=Window_SimpleText.new("Exceptions: 0",1)
#   @exceptwindow.x=0
#   @exceptwindow.y=416
  end

  def pbEndBattle(result)
    for i in 0..3
      @pkmnwindows[i].dispose if @pkmnwindows[i]
    end
#   @exceptwindow.dispose
  end

  def pbTrainerSendOut(battle,pkmn)
    pbRefresh
  end

  def pbSendOut(battle,pkmn)
    pbRefresh
  end

  def pbTrainerWithdraw(battle,pkmn)
    pbRefresh
  end

  def pbWithdraw(battle,pkmn)
    pbRefresh
  end

# Called whenever a Pokémon should forget a move.  It should return -1 if the
# selection is canceled, or 0 to 3 to indicate the move to forget.
# The function should not allow HM moves to be forgotten.
  def pbForgetMove(pkmn,move)
    return 0
  end

  def pbBeginAttackPhase
  end

# Use this method to display the list of commands.
#  Return values:
#  0 - Fight
#  1 - Pokémon
#  2 - Bag
#  3 - Run
  def pbCommandMenu(index)
    commands=["FIGHT","POKéMON","BAG","RUN"]
    cw = Window_Command.new(192, commands)
    cw.x=0
    cw.y=256
    cw.index=@lastcmd[index]
    pbRefresh
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw)
      if Input.trigger?(Input::C)
        ret=cw.index
        cw.dispose
        @lastcmd[index]=ret
        return ret
      end
    end 
  end

  def pbPokemonString(pkmn)
    status=""
    if pkmn.hp<=0
      status=" [FNT]"
    else
      case pkmn.status
        when PBStatuses::SLEEP
          status=" [SLP]"
        when PBStatuses::FROZEN
          status=" [FRZ]"
        when PBStatuses::BURN
          status=" [BRN]"
        when PBStatuses::PARALYSIS
          status=" [PAR]"
        when PBStatuses::POISON
          status=" [PSN]"
      end
    end
    return "#{pkmn.name} (Lv. #{pkmn.level})#{status} HP: #{pkmn.hp}/#{pkmn.totalhp}"
  end

  def pbMoveString(move)
    ret="#{move.name}"
    typename=PBTypes.getName(move.type)
    if move.id>0
      ret+=" (#{typename}) PP: #{move.pp}/#{move.totalpp}"
    end
    return ret
  end

# Use this method to display the list of moves for a Pokémon
  def pbFightMenu(index)
    moves=@battle.battlers[index].moves
    commands=[
       pbMoveString(moves[0]),
       pbMoveString(moves[1]),
       pbMoveString(moves[2]),
       pbMoveString(moves[3])
    ]
    cw = Window_Command.new(480, commands)
    cw.x=0
    cw.y=256
    cw.index=@lastmove[index]
    pbRefresh
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw)
      if Input.trigger?(Input::B)
        @lastmove[index]=cw.index
        cw.dispose
        return -1
      end
      if Input.trigger?(Input::C)
        ret=cw.index
        @lastmove[index]=ret
        cw.dispose
        return ret
      end
    end
  end

# Use this method to display the inventory
# The return value is the item chosen, or 0 if the choice was canceled.
  def pbItemMenu(index)
    pbDisplayMessage("Items can't be used here.")
    return -1
  end

  def pbFirstTarget(index)
    for i in 0...4
      if i!=index && !@battle.battlers[i].isFainted?
        return i
      end  
    end
    return -1
  end

  def pbNextTarget(cur,index)
    return -1 if cur>=3
    for i in cur+1..3
      if i!=index && !@battle.battlers[i].isFainted?
        return i
      end  
    end
    return -1
  end

  def pbPrevTarget(cur,index)
    return -1 if cur<=0
    ret=-1
    for i in 0..cur-1
      if i!=index && !@battle.battlers[i].isFainted?
        ret=i
      end  
    end
    return ret
  end

# Use this method to make the player choose a target 
# for certain moves in double battles.
  def pbChooseTarget(index)
    curwindow=pbFirstTarget(index)
    if curwindow==-1
      raise RuntimeError.new("No targets somehow...")
    end
    numwindows=@battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      @pkmnwindows[i].highlighted=(i==curwindow)
    end
    pbRefresh
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(nil)
      if Input.trigger?(Input::DOWN)
        newwindow=pbNextTarget(curwindow,index)
        if newwindow>=0
          curwindow=newwindow
          for i in 0...numwindows
            @pkmnwindows[i].highlighted=(i==curwindow)
          end
        end
      end
      if Input.trigger?(Input::UP)
        newwindow=pbPrevTarget(curwindow,index)
        if newwindow>=0
          curwindow=newwindow
          for i in 0...numwindows
            @pkmnwindows[i].highlighted=(i==curwindow)
          end
        end
      end
      if Input.trigger?(Input::B)
        for i in 0...numwindows
          @pkmnwindows[i].highlighted=false
          @pkmnwindows[i].update
        end
        return -1
      end
      if Input.trigger?(Input::C)
        for i in 0...numwindows
          @pkmnwindows[i].highlighted=false
          @pkmnwindows[i].update
        end
        return curwindow
      end
    end
  end

  def pbSwitch(index,lax,cancancel)
    party=@battle.pbParty(index)
    commands=[]
    inactives=[1,1,1,1,1,1]
    partypos=[]
    activecmd=0
    numactive=(@doublebattle)?2:1
    battler=@battle.battlers[0]
    commands[commands.length]=pbPokemonString(party[battler.pokemonIndex])
    activecmd=0 if battler.index==index
    inactives[battler.pokemonIndex]=0
    partypos[partypos.length]=battler.pokemonIndex
    if @battle.doublebattle
      battler=@battle.battlers[2]
      commands[commands.length]=pbPokemonString(party[battler.pokemonIndex])
      activecmd=1 if battler.index==index
      inactives[battler.pokemonIndex]=0
      partypos[partypos.length]=battler.pokemonIndex
    end
    for i in 0..party.length-1
      if inactives[i]==1
        commands[commands.length]=pbPokemonString(party[i]) 
        partypos[partypos.length]=i
      end
    end
    for i in 0..3
      @pkmnwindows[i].visible=false if @pkmnwindows[i]
    end
    cw = Window_Command.new(480, commands)
    cw.x=0
    cw.y=0
    cw.index=activecmd
    pbRefresh
    ret=0
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw)
      if cancancel && Input.trigger?(Input::B)
        ret=-1
        cw.dispose
        break
      end
      if Input.trigger?(Input::C)
        pkmnindex=partypos[cw.index]
        canswitch=lax ? @battle.pbCanSwitchLax?(index,pkmnindex,true) :
           @battle.pbCanSwitch?(index,pkmnindex,true)
        if canswitch
          ret=pkmnindex
          cw.dispose
          break
        end
      end
    end
    for i in 0..3
      @pkmnwindows[i].visible=true if @pkmnwindows[i]
    end
    return ret
  end

# This method is called whenever a Pokémon's HP changes.
# Used to animate the HP bar.
  def pbHPChanged(pkmn,oldhp,anim=false)
    hpchange=pkmn.hp-oldhp
    if hpchange<0
      hpchange=-hpchange
      PBDebug.log("[#{pkmn.pbThis} lost #{hpchange} HP, now has #{pkmn.hp} HP]")
    else
      PBDebug.log("[#{pkmn.pbThis} gained #{hpchange} HP, now has #{pkmn.hp} HP]")
    end
    pbRefresh
  end

# This method is called whenever a Pokémon faints
  def pbFainted(pkmn)
  end

  def pbChooseEnemyCommand(index)
    @battle.pbDefaultChooseEnemyCommand(index)
  end

# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party)
    @battle.pbDefaultChooseNewEnemy(index,party)
  end

# This method is called when the player wins a wild Pokémon battle.
# This method can change the battle's music for example.
  def pbWildBattleSuccess
  end

# This method is called when the player wins a Trainer battle.
# This method can change the battle's music for example.
  def pbTrainerBattleSuccess
  end

  def pbEXPBar(battler,thispoke,startexp,endexp,tempexp1,tempexp2)
  end

  def pbLevelUp(battler,thispoke,oldtotalhp,oldattack,
                olddefense,oldspeed,oldspatk,oldspdef)
  end

  def pbShowOpponent(opp)
  end

  def pbHideOpponent
  end

  def pbRecall(battlerindex)
  end

  def pbDamageAnimation(pkmn,effectiveness)
  end

  def pbAnimation(moveid,attacker,opponent,hitnum=0)
    if attacker
      if opponent
        PBDebug.log("[pbAnimation (#{attacker.pbThis}, #{opponent.pbThis}]")
      else
        PBDebug.log("[pbAnimation (#{attacker.pbThis}]")
      end
    else
      PBDebug.log("[pbAnimation]")
    end
  end
end



class PokeBattle_SceneNonInteractive < PokeBattle_Scene
  def initialize
    super
    self.abortable=true
  end

  def pbCommandMenu(index)
    return 1 if rand(15)==0
    return 0
  end

  def pbFightMenu(index)
    battler=@battle.battlers[index]
    i=0
    begin
     i=rand(4)
    end while battler.moves[i].id==0
    PBDebug.log("i=#{i}, pp=#{battler.moves[i].pp}")
    return i
  end

  def pbItemMenu(index)
    return -1
  end

  def pbChooseTarget(index)
    targets=[]
    for i in 0...4
      if @battle.battlers[index].pbIsOpposing?(i) &&
         !@battle.battlers[i].isFainted?
        targets.push(i)
      end  
    end
    return -1 if targets.length==0
    return targets[rand(targets.length)]
  end

  def pbSwitch(index,lax,cancancel)
    for i in 0...@battle.pbParty(index).length
      if lax
        return i if @battle.pbCanSwitchLax?(index,i,false)
      else
        return i if @battle.pbCanSwitch?(index,i,false)
      end
    end
    return -1
  end

  def pbChooseEnemyCommand(index)
    @battle.pbDefaultChooseEnemyCommand(index)
  end

# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party)
    @battle.pbDefaultChooseNewEnemy(index,party)
  end
end



class PokeBattle_DebugSceneNoLogging
  def initialize
    @battle=nil
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
  end

  def pbDisplayMessage(msg,brief=false)
  end

  def pbDisplayPausedMessage(msg)
  end

  def pbDisplayConfirmMessage(msg)
    return true
  end

  def pbShowCommands(msg,commands,defaultValue)
    return 0
  end

# Called whenever a new round begins.
  def pbBeginCommandPhase
  end

# Called whenever the battle begins
  def pbStartBattle(battle)
    @battle=battle
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
  end

  def pbEndBattle(result)
  end

  def pbTrainerSendOut(battle,pkmn)
  end

  def pbSendOut(battle,pkmn)
  end

  def pbTrainerWithdraw(battle,pkmn)
  end

  def pbWithdraw(battle,pkmn)
  end

# Called whenever a Pokémon should forget a move.  It should return -1 if the
# selection is canceled, or 0 to 3 to indicate the move to forget.
# The function should not allow HM moves to be forgotten.
  def pbForgetMove(pkmn,move)
    return 0
  end

  def pbBeginAttackPhase
  end

  def pbCommandMenu(index)
    return 1 if rand(15)==0
    return 4 if rand(10)==0
    return 0
  end

  def pbFightMenu(index)
    battler=@battle.battlers[index]
    i=0
    begin
      i=rand(4)
    end while battler.moves[i].id==0
    return i
  end

  def pbItemMenu(index)
    return -1
  end

  def pbChooseTarget(index)
    targets=[]
    for i in 0...4
      if @battle.battlers[index].pbIsOpposing?(i) &&
         !@battle.battlers[i].isFainted?
        targets.push(i)
      end  
    end
    return -1 if targets.length==0
    return targets[rand(targets.length)]
  end

  def pbRefresh
  end

  def pbSwitch(index,lax,cancancel)
    for i in 0..@battle.pbParty(index).length-1
      if lax
        return i if @battle.pbCanSwitchLax?(index,i,false)
      else
        return i if @battle.pbCanSwitch?(index,i,false)
      end
    end
    return -1
  end

  def pbHPChanged(pkmn,oldhp,anim=false)
  end

  def pbFainted(pkmn)
  end

  def pbChooseEnemyCommand(index)
    @battle.pbDefaultChooseEnemyCommand(index)
  end

# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party)
    @battle.pbDefaultChooseNewEnemy(index,party)
  end

# This method is called when the player wins a wild Pokémon battle.
# This method can change the battle's music for example.
  def pbWildBattleSuccess
  end

# This method is called when the player wins a Trainer battle.
# This method can change the battle's music for example.
  def pbTrainerBattleSuccess
  end

  def pbEXPBar(battler,thispoke,startexp,endexp,tempexp1,tempexp2)
  end

  def pbLevelUp(battler,thispoke,oldtotalhp,oldattack,
                olddefense,oldspeed,oldspatk,oldspdef)
  end

  def pbBlitz(keys)
    return rand(30)
  end

  def pbChatter(attacker,opponent)
  end

  def pbShowOpponent(opp)
  end

  def pbHideOpponent
  end

  def pbRecall(battlerindex)
  end

  def pbDamageAnimation(pkmn,effectiveness)
  end

  def pbBattleArenaJudgment(b1,b2,r1,r2)
  end

  def pbBattleArenaBattlers(b1,b2)
  end

  def pbCommonAnimation(moveid,attacker,opponent,hitnum=0)
  end

  def pbAnimation(moveid,attacker,opponent,hitnum=0)
  end
end


class PokeBattle_DebugSceneNoGraphics
  def initialize
    @battle=nil
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
  end

  def pbDisplayMessage(msg,brief=false)
    PBDebug.log(msg)
    @messageCount+=1
  end

  def pbDisplayPausedMessage(msg)
    PBDebug.log(msg)
    @messageCount+=1
  end

  def pbDisplayConfirmMessage(msg)
    PBDebug.log(msg)
    @messageCount+=1
    return true
  end

  def pbShowCommands(msg,commands,defaultValue)
    PBDebug.log(msg)
    @messageCount+=1
    return 0
  end

# Called whenever a new round begins.
  def pbBeginCommandPhase
    if @messageCount>0
      PBDebug.log("[message count: #{@messageCount}]")
    end
    @messageCount=0
  end

# Called whenever the battle begins
  def pbStartBattle(battle)
    @battle=battle
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @messageCount=0
  end

  def pbEndBattle(result)
  end

  def pbTrainerSendOut(battle,pkmn)
  end

  def pbSendOut(battle,pkmn)
  end

  def pbTrainerWithdraw(battle,pkmn)
  end

  def pbWithdraw(battle,pkmn)
  end

# Called whenever a Pokémon should forget a move.  It should return -1 if the
# selection is canceled, or 0 to 3 to indicate the move to forget.
# The function should not allow HM moves to be forgotten.
  def pbForgetMove(pkmn,move)
    return 0
  end

  def pbBeginAttackPhase
  end

  def pbCommandMenu(index)
    return 1 if rand(15)==0
    return 0
  end

  def pbFightMenu(index)
    battler=@battle.battlers[index]
    i=0
    begin
      i=rand(4)
    end while battler.moves[i].id==0
    return i
  end

  def pbItemMenu(index)
    return -1
  end

  def pbChooseTarget(index)
    targets=[]
    for i in 0...4
      if @battle.battlers[index].pbIsOpposing?(i) &&
         !@battle.battlers[i].isFainted?
        targets.push(i)
      end  
    end
    return -1 if targets.length==0
    return targets[rand(targets.length)]
  end

  def pbRefresh
  end

  def pbSwitch(index,lax,cancancel)
    for i in 0..@battle.pbParty(index).length-1
      if lax
        return i if @battle.pbCanSwitchLax?(index,i,false)
      else
        return i if @battle.pbCanSwitch?(index,i,false)
      end
    end
    return -1
  end

# This method is called whenever a Pokémon's HP changes.
# Used to animate the HP bar.
  def pbHPChanged(pkmn,oldhp,anim=false)
    hpchange=pkmn.hp-oldhp
    if hpchange<0
      hpchange=-hpchange
      PBDebug.log("[#{pkmn.pbThis} lost #{hpchange} HP, now has #{pkmn.hp} HP]")
    else
      PBDebug.log("[#{pkmn.pbThis} gained #{hpchange} HP, now has #{pkmn.hp} HP]")
    end
     pbRefresh
  end

# This method is called whenever a Pokémon faints
  def pbFainted(pkmn)
  end

  def pbChooseEnemyCommand(index)
    @battle.pbDefaultChooseEnemyCommand(index)
  end

# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party)
    @battle.pbDefaultChooseNewEnemy(index,party)
  end

# This method is called when the player wins a wild Pokémon battle.
# This method can change the battle's music for example.
  def pbWildBattleSuccess
  end

# This method is called when the player wins a Trainer battle.
# This method can change the battle's music for example.
  def pbTrainerBattleSuccess
  end

  def pbEXPBar(battler,thispoke,startexp,endexp,tempexp1,tempexp2)
  end

  def pbLevelUp(battler,thispoke,oldtotalhp,oldattack,
                olddefense,oldspeed,oldspatk,oldspdef)
  end

  def pbBlitz(keys)
    return rand(30)
  end

  def pbChatter(attacker,opponent)
  end

  def pbShowOpponent(opp)
  end

  def pbHideOpponent
  end

  def pbRecall(battlerindex)
  end

  def pbDamageAnimation(pkmn,effectiveness)
  end

  def pbBattleArenaJudgment(b1,b2,r1,r2)
    PBDebug.log("[Judgment - #{b1.pbThis}:#{r1.inspect}, #{b2.pbThis}:#{r2.inspect}]")
  end

  def pbBattleArenaBattlers(b1,b2)
    PBDebug.log("[#{b1.pbThis} VS #{b2.pbThis}]")
  end

  def pbCommonAnimation(moveid,attacker,opponent,hitnum=0)
    if attacker
      if opponent
        PBDebug.log("[pbCommonAnimation #{moveid} (#{attacker.pbThis}, #{opponent.pbThis}]")
      else
        PBDebug.log("[pbCommonAnimation #{moveid} (#{attacker.pbThis}]")
      end
    else
      PBDebug.log("[pbCommonAnimation #{moveid}]")
    end
  end

  def pbAnimation(moveid,attacker,opponent,hitnum=0)
    if attacker
      if opponent
        PBDebug.log("[pbAnimation (#{attacker.pbThis}, #{opponent.pbThis}]")
      else
        PBDebug.log("[pbAnimation (#{attacker.pbThis}]")
      end
    else
      PBDebug.log("[pbAnimation]")
    end
  end
end