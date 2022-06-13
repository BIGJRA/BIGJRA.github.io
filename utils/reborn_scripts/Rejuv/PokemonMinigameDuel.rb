################################################################################
# "Duel" mini-game
# Based on the Duel minigame by Alael
################################################################################
begin

class DuelWindow < Window_AdvancedTextPokemon # :nodoc:
  attr_accessor :hp
  attr_accessor :name
  attr_accessor :enemy

  def duelRefresh
    color= @isenemy ? "<ar><c2=043c3aff>" : "<c2=65467b14>"
    self.text=_INTL("{1}{2}<c2=06644bd2>\r\nHP: {3}",color,fmtescape(@name),@hp)
  end

  def initialize(name,isenemy)
    @hp=10
    @name=name
    @isenemy=isenemy
    super("")
    self.width=160
    self.height=96
    duelRefresh
  end

  def hp=(value)
    @hp=value
    duelRefresh
  end

  def name=(value)
    @name=value
    duelRefresh
  end

  def isenemy=(value)
    @isenemy=value
    duelRefresh
  end
end



class PokemonDuel
  def pbStartDuel(opponent,event)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    @event=event
    @sprites["player"]=IconSprite.new(-128-32,96,@viewport)
    @sprites["opponent"]=IconSprite.new(Graphics.width+32,96,@viewport)
    @sprites["playerwindow"]=DuelWindow.new($Trainer.name,false)
    @sprites["opponentwindow"]=DuelWindow.new(opponent.name,true)
    @sprites["playerwindow"].x=-@sprites["playerwindow"].width
    @sprites["opponentwindow"].x=Graphics.width
    @sprites["playerwindow"].viewport=@viewport
    @sprites["opponentwindow"].viewport=@viewport
    @sprites["player"].setBitmap(pbTrainerSpriteFile($Trainer.trainertype))
    @sprites["opponent"].setBitmap(pbTrainerSpriteFile(opponent.trainertype))
    pbWait(5)
    while @sprites["player"].x<0
      @sprites["player"].x+=4
      @sprites["playerwindow"].x+=4
      @sprites["opponent"].x-=4
      @sprites["opponentwindow"].x-=4
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    @oldmovespeed=$game_player.move_speed
    @oldeventspeed=event.move_speed
    pbMoveRoute($game_player,[
       PBMoveRoute::ChangeSpeed,2,
       PBMoveRoute::DirectionFixOn
    ])
    pbMoveRoute(event,[
       PBMoveRoute::ChangeSpeed,2,
       PBMoveRoute::DirectionFixOn
    ])
    pbWait(6)
  end

  def pbRefresh
    @sprites["playerwindow"].hp=@hp[0]
    @sprites["opponentwindow"].hp=@hp[1]
    pbWait(3)
  end

  def pbFlashScreens(player,opponent)
    i=0
    8.times do
      i+=1
      if player
        @sprites["player"].color=Color.new(255,255,255,i*64)
        @sprites["playerwindow"].color=Color.new(255,255,255,i*64)
      end
      if opponent
        @sprites["opponent"].color=Color.new(255,255,255,i*64)
        @sprites["opponentwindow"].color=Color.new(255,255,255,i*64)
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    8.times do
      i-=1
      if player
        @sprites["player"].color=Color.new(255,255,255,i*64)
        @sprites["playerwindow"].color=Color.new(255,255,255,i*64)
      end
      if opponent
        @sprites["opponent"].color=Color.new(255,255,255,i*64)
        @sprites["opponentwindow"].color=Color.new(255,255,255,i*64)
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    pbWait(4) if !player || !opponent
  end

  def pbEndDuel
    pbWait(6)
    pbMoveRoute($game_player,[
       PBMoveRoute::DirectionFixOff, 
       PBMoveRoute::ChangeSpeed,@oldmovespeed
    ])
    pbMoveRoute(@event,[
       PBMoveRoute::DirectionFixOff, 
       PBMoveRoute::ChangeSpeed,@oldeventspeed
    ])
    16.times do
      @sprites["player"].opacity-=16
      @sprites["opponent"].opacity-=16
      @sprites["playerwindow"].contents_opacity-=16
      @sprites["opponentwindow"].contents_opacity-=16
      @sprites["playerwindow"].opacity-=16
      @sprites["opponentwindow"].opacity-=16
      Graphics.update
      Input.update
      pbUpdateSceneMap  
    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbDuel(opponent,event,speeches)
    pbStartDuel(opponent,event)
    @hp=[10,10]
    @special=[false,false]
    decision=nil
    loop do
      @hp[0]=[@hp[0],0].max
      @hp[1]=[@hp[1],0].max
      pbRefresh
      if @hp[0]<=0
        decision=false
        break
      end
      if @hp[1]<=0
        decision=true
        break
      end
      action=0
      scores=[3,4,4,2]
      choices=(@special[1]) ? 3 : 4
      scores[3]=0 if @special[1]
      total=scores[0]+scores[1]+scores[2]+scores[3]
      if total<=0
        action=rand(choices)
      else
        num=rand(total)
        cumtotal=0
        for i in 0...4
          cumtotal+=scores[i]
          if num<cumtotal
            action=i
            break
          end
        end
      end
      @special[1]=true if action==3
      Kernel.pbMessage(_INTL("{1}: {2}",opponent.name,speeches[action*3+rand(3)]))
      command=rand(4)
      list=[
         _INTL("DEFEND"),
         _INTL("PRECISE ATTACK"),
         _INTL("FIERCE ATTACK")
      ]
      if !@special[0]
        list.push(_INTL("SPECIAL ATTACK"))
      end
      command=Kernel.pbMessage(_INTL("Choose a command."),list,0)
      if command==3
        @special[0]=true
      end
      if action==0 && command==0
        pbMoveRoute($game_player,[
           PBMoveRoute::ScriptAsync,"moveRight90",
           PBMoveRoute::ScriptAsync,"moveLeft90",
           PBMoveRoute::ScriptAsync,"moveLeft90",
           PBMoveRoute::ScriptAsync,"moveRight90"
        ])
        pbMoveRoute(event,[
           PBMoveRoute::ScriptAsync,"moveLeft90",
           PBMoveRoute::ScriptAsync,"moveRight90",
           PBMoveRoute::ScriptAsync,"moveRight90",
           PBMoveRoute::ScriptAsync,"moveLeft90"
        ])
        pbWait(3)
        Kernel.pbMessage(_INTL("You study each other's movements..."))
      elsif action==0 && command==1
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,4, 
           PBMoveRoute::Forward
        ])
        pbWait(2)
        pbShake(9,9,8)
        pbFlashScreens(false,true)
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Backward
        ])
        @hp[1]-=1
        Kernel.pbMessage(_INTL("Your attack was not blocked!"))
      elsif action==0 && command==2
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,4, 
           PBMoveRoute::ScriptAsync,"jumpForward"])
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,4, 
           PBMoveRoute::Backward])
        pbWait(5)
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Backward])
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Forward])   
        Kernel.pbMessage(_INTL("Your attack was evaded!"))
      elsif (action==0 || action==1 || action==2) && command==3
        pbMoveRoute($game_player,[
        PBMoveRoute::ChangeSpeed,4, 
        PBMoveRoute::ScriptAsync,"jumpForward"])
        pbWait(2)
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,5,
           PBMoveRoute::Backward,
           PBMoveRoute::ChangeSpeed,2])
        pbWait(3)
        pbShake(9,9,8)
        pbFlashScreens(false,true)
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Backward])
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Forward])
        @hp[1]-=3
        Kernel.pbMessage(_INTL("You pierce through the opponent's defenses!"))
      elsif action==1 && command==0
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,4, 
           PBMoveRoute::Forward
        ])
        pbWait(2)
        pbShake(9,9,8)
        pbFlashScreens(true,false)
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Backward
        ])
        @hp[0]-=1
        Kernel.pbMessage(_INTL("You fail to block the opponent's attack!"))
      elsif action==1 && command==1
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,4, 
           PBMoveRoute::Forward])
        pbWait(3)
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Backward])
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Forward])
        pbWait(3)
        pbMoveRoute(event,[PBMoveRoute::Backward])
        pbMoveRoute($game_player,[PBMoveRoute::Forward])
        pbWait(3)
        pbMoveRoute($game_player,[PBMoveRoute::Backward])
        Kernel.pbMessage(_INTL("You cross blades with the opponent!"))
      elsif (action==1 && command==2) ||
            (action==2 && command==1) ||
            (action==2 && command==2)
        pbMoveRoute($game_player,[
           PBMoveRoute::Backward,
           PBMoveRoute::ChangeSpeed,4, 
           PBMoveRoute::ScriptAsync,"jumpForward"])
        pbWait(4)
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,4,
           PBMoveRoute::Forward])
        pbWait(2)
        pbWait(3)
        pbShake(9,9,8)
        pbFlashScreens(true,true)
        pbMoveRoute($game_player,[
           PBMoveRoute::Backward,
           PBMoveRoute::ChangeSpeed,2])    
        pbMoveRoute(event,[
           PBMoveRoute::Backward,
           PBMoveRoute::Backward,
           PBMoveRoute::ChangeSpeed,2]) 
        pbWait(5)
        pbMoveRoute(event,[PBMoveRoute::Forward])
        pbMoveRoute($game_player,[PBMoveRoute::Forward])
        @hp[0]-=action # Enemy action
        @hp[1]-=command # Player command
        Kernel.pbMessage(_INTL("You hit each other!"))
      elsif action==2 && command==0
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,4, 
           PBMoveRoute::Forward])
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,4, 
           PBMoveRoute::ScriptAsync,"jumpBackward"])
        pbWait(5)
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Forward])
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Backward])   
        Kernel.pbMessage(_INTL("You evade the opponent's attack!"))
      elsif action==3 && (command==0 || command==1 || command==2)
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,4, 
           PBMoveRoute::ScriptAsync,"jumpForward"])
        pbWait(2)
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,5,
           PBMoveRoute::Backward,
           PBMoveRoute::ChangeSpeed,2])
        pbWait(3)
        pbShake(9,9,8)
        pbFlashScreens(true,false)
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Forward])
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,2, 
           PBMoveRoute::Backward])
        @hp[0]-=3
        Kernel.pbMessage(_INTL("The opponent pierces through your defenses!"))
      elsif action==3 && command==3
        pbMoveRoute($game_player,[PBMoveRoute::Backward])
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,4,
           PBMoveRoute::ScriptAsync,"jumpForward"
        ])
        pbMoveRoute(event,[
           PBMoveRoute::Wait,15,
           PBMoveRoute::ChangeSpeed,4,
           PBMoveRoute::ScriptAsync,"jumpForward"
        ])
        pbWait(5)
        pbMoveRoute(event,[
           PBMoveRoute::ChangeSpeed,5,
           PBMoveRoute::Backward,
           PBMoveRoute::ChangeSpeed,2
        ])
        pbMoveRoute($game_player,[
           PBMoveRoute::ChangeSpeed,5,
           PBMoveRoute::Backward,
           PBMoveRoute::ChangeSpeed,2
        ])
        pbShake(9,9,8)
        pbFlash(Color.new(255,255,255,255),20)
        pbFlashScreens(true,true)
        pbMoveRoute($game_player,[PBMoveRoute::Forward])
        @hp[0]-=4
        @hp[1]-=4
        Kernel.pbMessage(_INTL("Your special attacks collide!"))
      end
    end
    pbEndDuel
    return decision
  end
end



# Starts a duel.
# trainerid - ID of the opponent's trainer type.
# trainername - Name of the opponent
# event - Game_Event object for the character's event
# speeches - Array of 12 speeches
def pbDuel(trainerid,trainername,event,speeches)
  duel=PokemonDuel.new
  opponent=PokeBattle_Trainer.new(
     pbGetMessageFromHash(MessageTypes::TrainerNames,trainername),
     trainerid)
  speechtexts=[]
  for i in 0...12
    speechtexts.push(_I(speeches[i]))
  end
  duel.pbDuel(opponent,event,speechtexts)
end



rescue Exception
if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
  raise $!
else
end

end