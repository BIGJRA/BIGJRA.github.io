################################################################################
#-------------------------------------------------------------------------------
#Author: Alexandre
#Handles Connection, Registration and Login
#-------------------------------------------------------------------------------
################################################################################
class Connect
  
################################################################################
#-------------------------------------------------------------------------------
#Let's start the Scene
#-------------------------------------------------------------------------------
################################################################################
  def initialize(sbase=false)
 
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @overlay=SpriteWrapper.new(@viewport)
    @overlay.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @viewport.z = 99999
    @waitgraph=SpriteWrapper.new(@viewport)
    @waitgraph.visible = false
    @waitgraph.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/onlinewaiting.png")    
    @username = ""
    @password = ""
    @email = ""
    @base = sbase
    @idle = true
    @tiebreak = nil
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Opens a connection tests if it can and is allowed toconnect to the server
#-------------------------------------------------------------------------------
################################################################################
  def main
    Graphics.transition
    #isLegalMons?($Trainer) 
    #isLegalMove?($Trainer)
    if $game_switches && $game_switches[:Randomized_Challenge]
      Kernel.pbMessage(_INTL("Unfortunately, online features cannot be used in Randomizer playthroughs."))
      $scene = Scene_Map.new
      return
    end
    if $game_switches && $game_switches[:Full_IVs]
      Kernel.pbMessage(_INTL("Online play is disabled when using the Full IVs password."))
      $scene = Scene_Map.new
      return
    end
    if $game_switches && $game_switches[:No_Total_EV_Cap]
      Kernel.pbMessage(_INTL("Online play is disabled when using the No Total EV Cap password."))
      $scene = Scene_Map.new
      return
    end
    if !nicknameFilterCheck($Trainer)
      $scene = Scene_Map.new
      return
    end   
    if !nicknameFilterCheck($Trainer)
      $scene = Scene_Map.new
      return
    end   
    if !trainerNameFilterCheck($Trainer.name)
      commands=[_INTL("Yes"),_INTL("No")]
      choice=Kernel.pbMessage(_INTL("Would you like to change your trainer name to allow online access?"),commands)
      if choice==0
        Kernel.pbMessage(_INTL("Please note that any pokemon that have your old name as their OT will have it changed to reflect your new name."))
        onlineNameChange
        $scene = Scene_Map.new
        return
      elsif choice==1
        $scene = Scene_Map.new
        return
      end
    end          
    $Trainer.storedOnlineParty=[]
    Kernel.pbMessage("Connecting to server... (Press Z)")
#    $waitchallenge = false
    version = getversion()
    begin
      $network = Network.new
      $network.open
      $network.send("<CON version=#{version}>")
    rescue
      Kernel.pbMessage("Server is not online or your internet connection has a problem.")
      $scene = Scene_Map.new
      Graphics.freeze
      $network.close
      @viewport.dispose
    end
    loop do
      break if $scene != self
      update
      if Input.trigger?(Input::B)
        if @waitgraph.visible===false
          if $Trainer.storedOnlineParty!=[]
            $Trainer.party = $Trainer.storedOnlineParty
            $Trainer.storedOnlineParty=[]
          end        
          $network.send("<DSC>")
          $scene=Scene_Map.new
          break
        else
          @waitgraph.visible=false
          if $Trainer.storedOnlineParty!=[]
            $Trainer.party = $Trainer.storedOnlineParty
            $Trainer.storedOnlineParty=[]
          end  
          tradeorbattle
        end
      end
    end
    Graphics.freeze
    @viewport.dispose
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Loop to constantly check for messages from the server
#-------------------------------------------------------------------------------
################################################################################
  def update
    message = $network.listen
    handle(message)
    @viewport.update
    @overlay.update
    Graphics.update
    Input.update
  end
 
################################################################################
#-------------------------------------------------------------------------------
#Handles incoming messages from server. Aborts connection if unkown message is
#received
#-------------------------------------------------------------------------------
################################################################################
  def handle(message)
    if message.kind_of?(Array)
      message = message[0]
    end
    case message
      when /<CON result=(.*)>/ then check_connection($1.to_i)
      when /<DSC>/ then disconnect()
      when /<DSC reason=(.*)>/ then disconnect($1.to_s) 
      when /<REG result=(.*)>/ then check_registration($1.to_i)
      when /<LOG result=(.*)>/ then check_login($1.to_i)
      when /<TRAREQ user=(.*) result=(.*) name=(.*)>/ then check_trade($1.to_s,$2.to_i,$3.to_s)
      when /<TRARES user=(.*) player=(.*)>/ then initiate_trade($1.to_i,$2.to_s)        
      when /<TRAREJ user=(.*)>/ then rejectionT($1.to_s)  
      when /<BATCHAL user=(.*) result=(.*) trainer=(.*) name=(.*)>/ then choose_field($1.to_s,$2.to_i,$3,$4.to_s)
      when /<BATHOST opponent=(.*) result=(.*) field=(.*) name=(.*)>/ then offer_field($1,$2.to_i,$3.to_i,$4.to_s)
      when /<BATFIELD result=(.*) effect=(.*) user=(.*)>/ then initiate_battle($1.to_i,$2.to_i,$3.to_i)
      when /<BATREJ user=(.*)>/ then rejectionB($1.to_s)
      when /<RANBAT user=(.*) tie=(.*)>/ then rand_verify($1.to_s,$2.to_i)        
      when /<BAT trainer=(.*)>/ then get_randopp($1.to_s)
      when /<YESRAN>/ then initiate_battle(0,0,@tiebreak.to_i)
      when /<NORAN name=(.*)>/ then rand_reject($1.to_s)
      when /<WONTRA>/ then wonder_err
      when /<WONTRA species=(.*) level=(.*) iv=(.*) ev=(.*) exp=(.*) item=(.*) pid=(.*) tid=(.*) pokerus=(.*) nickname=(.*) ball=(.*) ot=(.*) otgender=(.*) ability=(.*) nature=(.*) move1=(.*) move2=(.*) move3=(.*) move4=(.*) user=(.*) form=(.*)>/ then wonder_trading($1.to_i,$2.to_i,$3.to_s,$4.to_s,$5.to_i,$6.to_s,$7.to_i,$8.to_i,$9.to_i,$10.to_s,$11.to_s,$12.to_s,$13.to_i,$14.to_s,$15.to_s,$16.to_i,$17.to_i,$18.to_i,$19.to_i,$20.to_s,$21.to_i)            
      when "" then nil        
            
      when /<GLOBAL message=(.*)>/ then Kernel.pbMessage("#{$1.to_s}")
 
      when /<ACTI>/ then $network.send("<ACTI>")
      when /<PNG>/ then nil
      end
    end
 
################################################################################
#-------------------------------------------------------------------------------
#Check's response from server to see if we are allowed to connect
#-------------------------------------------------------------------------------
################################################################################    
  def check_connection(result)
    if result == 0
      Kernel.pbMessage("Your version is outdated; please download the latest version.")
      $scene = Scene_Map.new
    elsif result == 1
      Kernel.pbMessage("The server is full; please try again later.")
      $scene = Scene_Map.new
    else
      Kernel.pbMessage("Connection successful.")
      registerorlogin
    end
  end
 
################################################################################
#-------------------------------------------------------------------------------
#Simply asks the user if he or she wants to register, login or abort.
#-------------------------------------------------------------------------------
################################################################################
  def registerorlogin
    commands=[_INTL("Login"),_INTL("Register"),_INTL("Options"),_INTL("Cancel")]
    choice=Kernel.pbMessage(_INTL("What do you want to do?"),commands)
    if choice==0
      attempt_login
    elsif choice==1
      attempt_register
    elsif choice==2
      commands=[_INTL("Online Battle Music"),_INTL("Wonder-Trade Nicknames"),_INTL("Cancel")]
      choose=Kernel.pbMessage(_INTL("What do you want to do?"),commands)
      case choose
      when 0 then selectOnlineBGM($Trainer)
      when 1 then selectAllowingNickNames($Trainer)
      when 2 then registerorlogin
      end     
    elsif choice==3
      $network.send("<DSC>")
      $scene=Scene_Map.new
    end
  end
  
  def selectOnlineBGM(trainer)
    commands=[_INTL("Trainer 1"),_INTL("Trainer 2"),_INTL("Trainer 3"),_INTL("Trainer Retro"),_INTL("Rival"),_INTL("Gym Leader"),_INTL("Gym Leader - Shade"),
    _INTL("Gym Leader - Terra"),_INTL("Meteor"),_INTL("Meteor Admin"),_INTL("Upbeat"),_INTL("Dramatic"),_INTL("Misc"),
    _INTL("Wild 1"),_INTL("Wild 2"),_INTL("Wild 3"),_INTL("Wild 4"),_INTL("Wild Retro"),_INTL("Legendary"),_INTL("Elite"),_INTL("Champion"),
    _INTL("Inner Peace"),_INTL("Inner Chaos"),_INTL("Postgame"),_INTL("Umbral"),_INTL("Back")]
    choice=Kernel.pbMessage(_INTL("What music would you like to play in online battles?"),commands,18)
    case choice
      when 0
        trainer.onlineMusic = "Battle- Trainer.ogg"
      when 1
        trainer.onlineMusic = "Battle- Trainer2.ogg"
      when 2
        trainer.onlineMusic = "Battle- Trainer3.ogg"
      when 3        
        trainer.onlineMusic = "RBY Battle- Trainer.ogg"
      when 4          
        trainer.onlineMusic = "Battle- Rival.ogg"
      when 5
        trainer.onlineMusic = "Battle- Gym.ogg"
      when 6
        trainer.onlineMusic = "Battle- ReverseGym.ogg"
      when 7
        trainer.onlineMusic = "RBY Battle- Champion.ogg"
      when 8
        trainer.onlineMusic = "Battle- Meteor.ogg"
      when 9
        trainer.onlineMusic = "Battle- Meteor Admin.ogg"
      when 10
        trainer.onlineMusic = "Battle- Upbeat.ogg"
      when 11        
        trainer.onlineMusic = "Battle- Dramatic.ogg"
      when 12
        trainer.onlineMusic = "Battle- Misc.ogg"
      when 13
        trainer.onlineMusic = "Battle- Wild.ogg"
      when 14
        trainer.onlineMusic = "Battle- Wild2.ogg"
      when 15
        trainer.onlineMusic = "Battle- Wild3.ogg"
      when 16
        trainer.onlineMusic = "Battle- Wild4.ogg"
      when 17
        trainer.onlineMusic = "RBY Battle- Wild.ogg"
      when 18
        trainer.onlineMusic = "Battle- Legendary.ogg"
      when 19
        trainer.onlineMusic = "Battle- Elite.ogg"
      when 20
        trainer.onlineMusic = "Battle- Champion.ogg"
      when 21
        trainer.onlineMusic = "Battle- Inner Peace.ogg"
      when 22
        trainer.onlineMusic = "Battle- Inner Chaos.ogg"
      when 23
        trainer.onlineMusic = "Battle- Postgame.ogg"
      when 24
        trainer.onlineMusic = "Battle- Umbral.ogg"
      when 25    
    end
    registerorlogin
  end          
              
  def selectAllowingNickNames(trainer)
    trainer.onlineAllowNickNames = Kernel.pbConfirmMessage("Do you allow wonder-traded Pokémon to hold their nicknames?")
    registerorlogin
  end

################################################################################
#-------------------------------------------------------------------------------
#Disconnects the user if the server requires it.
#-------------------------------------------------------------------------------
################################################################################
  def disconnect(reason)
    Kernel.pbMessage("You have been disconnected: #{reason}")
        if $Trainer.storedOnlineParty!=[]
          $Trainer.party = $Trainer.storedOnlineParty
          $Trainer.storedOnlineParty=[]
        end        
    $scene=Scene_Map.new
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Attempts to register the user.
#-------------------------------------------------------------------------------
################################################################################
  def attempt_register
    Kernel.pbMessage("Please enter a username.")
    loop do
      @username = Kernel.pbMessageFreeText(_INTL("Username?"),"",false,32)
      break if @username==""
      if @username != ""
        Kernel.pbMessage("Please re-enter your username.")
        
        username = Kernel.pbMessageFreeText(_INTL("Username?"),"",false,32)
        break if @username == username
        Kernel.pbMessage("The username you entered does not match, please try again.")
      end
    end
    return registerorlogin if @username==""
    return registerorlogin if !usernameFilterCheck(@username)
    Kernel.pbMessage("Please enter a password.")
    loop do
      @password = Kernel.pbMessageFreeText(_INTL("Password?"),"",true,32)
      if @password != ""
        Kernel.pbMessage("Please re-enter your password.")
        password = Kernel.pbMessageFreeText(_INTL("Password?"),"",true,32)
        break if @password == password
        Kernel.pbMessage("The password you entered does not match, please try again.")
      end
      break if @password == ""

    end
    if @password==""
      registerorlogin
    else
      $network.send("<REG user=#{@username} pass=#{encrypt_password(@password)}>")
    end
  end
  
  
################################################################################
#-------------------------------------------------------------------------------
#Encrypts a password.
#-------------------------------------------------------------------------------
################################################################################
  def encrypt_password(password)
    encrypted = password.crypt("XS")
    return encrypted[2, encrypted.size - 2]
  end
 
################################################################################
#-------------------------------------------------------------------------------
#Checks server's result for registration.
#-------------------------------------------------------------------------------
################################################################################
  def check_registration(result)
    if result == 0
      Kernel.pbMessage("The username is already taken, please try a different username.")
      attempt_register
    elsif result == 1
      Kernel.pbMessage("The email you entered has already been used to register an account, you can only have one acount per email.")
      attempt_register
    elsif result == 2
      Kernel.pbMessage("Registration was successful!")
      registerorlogin
    end
  end
 
################################################################################
#-------------------------------------------------------------------------------
#Attempts to log into the server.
#-------------------------------------------------------------------------------
################################################################################
  def attempt_login
    Kernel.pbMessage("Please enter your username.")
    tempuser=""
    @username = Kernel.pbMessageFreeText(_INTL("Username?"),tempuser,false,32)
    if @username==""
      registerorlogin 
    else
      temppass="" 
      Kernel.pbMessage("Please enter your password.")
      @password = Kernel.pbMessageFreeText(_INTL("Password?"),temppass,true,32)
      if @password==""
        registerorlogin 
      else
        Kernel.pbMessage("Logging in... (Press Z)")  
        $network.send("<LOG user=#{@username} pass=#{encrypt_password(@password)}>")
      end    
    end
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Check's login result from server
#-------------------------------------------------------------------------------
################################################################################
  def check_login(result)
    if result == 0
      Kernel.pbMessage("The username entered does not exist.")
      registerorlogin
    elsif result == 1
      Kernel.pbMessage("The password entered is incorrect.")
      registerorlogin
    elsif result == 2
      Kernel.pbMessage("This account has been banned.")
      registerorlogin
    elsif result == 3
      Kernel.pbMessage("Your IP has been banned.")
      $Scene=Scene_Map.new
    elsif result == 4
      Kernel.pbMessage("Login was successful!")
      $network.loggedin=true
      $network.username = @username
      tradeorbattle
    elsif result == 5
      Kernel.pbMessage("This account is already logged in.")
      registerorlogin
    end
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Simply asks the user if they want to trade or battle.
#-------------------------------------------------------------------------------
################################################################################ 
  def tradeorbattle    
    if $Trainer.storedOnlineParty!=[]
      $Trainer.party = $Trainer.storedOnlineParty
      $Trainer.storedOnlineParty=[]      
    end    
    commands=[_INTL("Trade")]
    commands.push(_INTL("Battle"))      
    commands.push(_INTL("Cancel"))
    choice=Kernel.pbMessage(_INTL("What do you want to do?"),commands)
      if choice==0
        tradecommands=[_INTL("Request Trade")]
        tradecommands.push(_INTL("Wait for Request"))    
        tradecommands.push(_INTL("Wonder Trade")) unless $Trainer.noOnlineBattle       
        tradecommands.push(_INTL("Back"))
        tradechoice=Kernel.pbMessage(_INTL("What do you want to do?"),tradecommands)
          if tradechoice==0
            traderequest
          elsif tradechoice==1
            tradehost
          elsif tradechoice==2 && !$Trainer.noOnlineBattle       
            wondertrade
          elsif (tradechoice==2 && $Trainer.noOnlineBattle) || tradechoice==3
            tradeorbattle
          end               
      elsif choice==1
        battlecommands=[_INTL("Challenge")]
        battlecommands.push(_INTL("Wait for Challenge"))
        battlecommands.push(_INTL("Random Matchup")) unless $Trainer.noOnlineBattle
        battlecommands.push(_INTL("Back"))
        battlechoice=Kernel.pbMessage(_INTL("What do you want to do?"),battlecommands)
          if battlechoice==0
            battlechallenge
          elsif battlechoice==1
            battlehost
          elsif battlechoice==2  && !$Trainer.noOnlineBattle       
            randbat       
          elsif (battlechoice==2  && $Trainer.noOnlineBattle) || battlechoice==3
            tradeorbattle
          end           
      elsif choice==2
        $network.send("<DSC>")
        if $Trainer.storedOnlineParty!=[]
          $Trainer.party = $Trainer.storedOnlineParty
          $Trainer.storedOnlineParty=[]            
        end              
        $scene=Scene_Map.new
      end
    end          
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Starts trade procedures
#-------------------------------------------------------------------------------
################################################################################  
  def quickRenderInt(int)
    return 0 if int == 0
    int += 1
    return int
  end

  def traderequest
    loop do
      @player = Kernel.pbMessageFreeText(_INTL("Who would you like to request to trade with?"),"",false,32)
      Kernel.pbMessage("You cannot trade with yourself.") if @player == $network.username
      return tradeorbattle if @player == "" || @player == $network.username
      break if @player !="" || @player !=$network.username
    end
    $network.send("<TRAREQ user=#{@player} name=#{$network.username}>")
    @waitgraph.visible = true
  end  
  
  def tradehost
    @waitgraph.visible = true
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Checks server's response for trade
#-------------------------------------------------------------------------------
################################################################################
  def rejectionT(user)
    @waitgraph.visible = false
    Kernel.pbMessage("#{user} has declined your request.")
    return tradeorbattle
  end  

  def check_trade(player,result,name)
    @waitgraph.visible = false
    if result == 0
      Kernel.pbMessage(_INTL("The user #{player} does not exist."))
      tradeorbattle
    elsif result == 1
      Kernel.pbMessage(_INTL("The user #{player} has been banned."))
      tradeorbattle
    elsif result == 2
      Kernel.pbMessage(_INTL("The user #{player} is not online."))
      tradeorbattle
    elsif result == 3
      Kernel.pbMessage(_INTL("The user #{player} has declined or did not respond your trade request."))
      tradeorbattle
    elsif result == 4
      commands=[_INTL("Yes")]
      commands.push(_INTL("No"))
      choice=Kernel.pbMessage(_INTL("The user #{name} has sent a trade request. Do you accept?"),commands)      
      if choice==0
       $network.send("<TRAHOST user=#{name} name=#{player}>")      
      elsif choice==1
        $network.send("<TRAREJ user=#{$network.username} name=#{name}>")        
        tradeorbattle
      end      
    end
  end
  
  def initiate_trade(user,player)
    if user==0
      Kernel.pbMessage(_INTL("Your trade will begin shortly."))
      $scene = Scene_Trade.new(player)
    elsif user==1
      Kernel.pbMessage(_INTL("Your request was accepted. The trade will begin shortly."))
      $scene = Scene_Trade.new(player)
    end
  end  
  
################################################################################
#-------------------------------------------------------------------------------
#Wonder Trade
#-------------------------------------------------------------------------------
################################################################################    
  def wondertrade
    pbChoosePokemon(344,345,
      proc{|poke| !poke.egg? && poke.ev.sum <= 510 && poke.ev.none? {|evvalue| evvalue > 255} &&
        poke.iv.none? {|ivvalue| ivvalue < 0 || ivvalue > 31}
      }
    )
    if $game_variables[344]>=0
      mon=$Trainer.party[pbGet(344)]
      monName=mon.name
      commands=[_INTL("Yes")]
      commands.push(_INTL("No"))
      choice=Kernel.pbMessage(_INTL("Are you sure you want to wonder trade #{monName}?"),commands)                
      if choice==1
        return wondertrade
      elsif choice==0        
        if mon.ot==""
          $Trainer.party[pbGet(344)].ot = $Trainer.name
          $Trainer.party[pbGet(344)].trainerID = $Trainer.id
          monOT=$Trainer.name
          monID=$Trainer.id
        else
          monOT=mon.ot
          monID=mon.trainerID
        end      
        info=[mon.species,mon.level,mon.iv.join(","),mon.ev.join(","),mon.exp,mon.item, 
        mon.personalID.to_s,monID.to_s,mon.pokerus,mon.name,mon.ballused,monOT,
        mon.otgender,mon.abilityIndex,mon.nature,mon.moves[0].id,mon.moves[1].id,
        mon.moves[2].id,mon.moves[3].id,mon.form]  
        $network.send("<WONTRA species=#{info[0]} level=#{info[1]} iv=#{info[2]} ev=#{info[3]} exp=#{info[4]} item=#{info[5]} pid=#{info[6]} tid=#{info[7]} pokerus=#{info[8]} nickname=#{info[9]} ball=#{info[10]} ot=#{info[11]} otgender=#{info[12]} ability=#{info[13]} nature=#{info[14]} move1=#{info[15]} move2=#{info[16]} move3=#{info[17]} move4=#{info[18]} form=#{info[19]}>")
      end
    else 
      tradeorbattle
    end    
  end  
  
  def wonder_err
    Kernel.pbMessage(_INTL("Unable to find a trade partner right now. Please try again later."))
    tradeorbattle
  end  
  
  def wonder_trading(species,level,ivs,evs,exp,item,pid,tid,pokerus,nickname,ball,ot,otgender,ability,nature,move1,move2,move3,move4,owner,form)
    Kernel.pbMessage(_INTL("You will be trading with #{owner}."))
    wondermon = PokeBattle_Pokemon.new(species,level)
    wondermon.iv = ivs.split(",").map { |s| s.to_i }
    wondermon.ev = evs.split(",").map { |s| s.to_i }
    wondermon.exp = exp
    wondermon.item = item.to_i
    wondermon.personalID = pid.to_i
    wondermon.pokerus = pokerus
    wondermon.ballused = ball.to_i
    wondermon.ot = ot
    wondermon.otgender = otgender
    wondermon.abilityflag = ability.to_i
    wondermon.natureflag = nature.to_i
    wondermon.personalID = pid.to_i
    wondermon.trainerID = tid.to_i    
    wondermon.form = form

    # Allowing nicknamed Pokemon
    if $Trainer.onlineAllowNickNames == false
      nickname = PBSpecies.getName(species)
    end
    wondermon.name = nickname
    pbStartTrade(pbGet(344),wondermon,nickname,ot,otgender,true)
    wondermon.pbLearnMove(move1)
    wondermon.pbLearnMove(move2)
    wondermon.pbLearnMove(move3)
    wondermon.pbLearnMove(move4)    
    wondermon.personalID = pid.to_i
    wondermon.trainerID = tid.to_i    
    wondermon.form = form
    wondermon.calcStats

    pbSave
    Kernel.pbMessage("Saved the game!")      
    tradeorbattle
  end  
    
      
################################################################################
#-------------------------------------------------------------------------------
#Starts battle procedures
#-------------------------------------------------------------------------------
################################################################################
  def battlechallenge
    if !$Trainer.party[0] || $Trainer.party[0].egg? || $Trainer.party[0].hp<1
      Kernel.pbMessage("You need to be able to use the first Pokemon in your party.")
      return tradeorbattle
    end
        
    $Trainer.storedOnlineParty=Array.new
    for i in 0..$Trainer.party.length-1
      $Trainer.storedOnlineParty[i]=$Trainer.party[i].clone
    end
    for i in 0..$Trainer.party.length-1
      $Trainer.party[i].moves = $Trainer.party[i].moves.clone
      $Trainer.party[i].moves.map! {|move| move.clone}
      $Trainer.party[i].heal
    end
    for i in $Trainer.party
      i.level=100
      i.calcStats
    end
    
    partyTemp=[]
    for poke in $Trainer.party
        partyTemp.push(Marshal.dump(poke))
    end
    
    pokemonArray=[]
    for poke in $Trainer.party
    #  poke.abilityflag="nil" if !poke.abilityflag
      if !poke.isShiny?
        shininess=0
      else
        shininess=1 
      end
        varArray=[poke.species,
        100,
        poke.iv[0],
        poke.iv[1],
        poke.iv[2],
        poke.iv[3],
        poke.iv[4],
        poke.iv[5],
        poke.ev[0],
        poke.ev[1],
        poke.ev[2],
        poke.ev[3],
        poke.ev[4],
        poke.ev[5],
        poke.personalID,
        poke.trainerID,
        poke.item,
        poke.name,
        poke.exp,
        poke.happiness,
        poke.moves[0].id,
        poke.moves[0].pp,
        poke.moves[1].id,
        poke.moves[1].pp,
        poke.moves[2].id,
        poke.moves[2].pp,
        poke.moves[3].id,
        poke.moves[3].pp,
        poke.form,
        poke.nature,
        poke.totalhp,
        poke.attack,
        poke.defense,
        poke.spatk,
        poke.spdef,
        poke.speed,
        poke.ballused,
        poke.ot,
        shininess,
        poke.abilityIndex]
        for var in pokemonArray
            var=var.to_s
        end
      pokemonArray.push(varArray.join("^%*"))
    end
    @doubles=Kernel.pbMessage(_INTL("Would you like a singles or doubles battle?"),["Singles","Doubles"])
    mons=pokemonArray.join("/u/")
    trainerAry=[$Trainer.name,
    $Trainer.id,
    $Trainer.trainertype,
    mons,
    @doubles]
    
    
    serialized=trainerAry.join("/g/")
    loop do
      @player = Kernel.pbMessageFreeText(_INTL("Who would you like to challenge?"),"",false,32)
      Kernel.pbMessage("You cannot battle with yourself.") if @player == $network.username
      if @player == "" || @player == $network.username
        $Trainer.party = $Trainer.storedOnlineParty
        $Trainer.storedOnlineParty=[]  
        return tradeorbattle
      end      
      break
    end
    $network.send("<BATCHAL user=#{@player} trainer=#{serialized} name=#{$network.username}>")
    @waitgraph.visible=true
  end
    
  def battlehost
    if !$Trainer.party[0] || $Trainer.party[0].egg? || $Trainer.party[0].hp<1
      Kernel.pbMessage("You need to be able to use the first Pokemon in your party.")
      return tradeorbattle
    end
    
    $Trainer.storedOnlineParty=Array.new
    for i in 0..$Trainer.party.length-1
      $Trainer.storedOnlineParty[i]=$Trainer.party[i].clone
    end 
    for i in 0..$Trainer.party.length-1
      $Trainer.party[i].moves = $Trainer.party[i].moves.clone
      $Trainer.party[i].moves.map! {|move| move.clone}
      $Trainer.party[i].heal
    end
    for i in $Trainer.party
      i.level=100
      i.calcStats
    end
      
   # $waitchallenge = true
    
    partyTemp=[]
    for poke in $Trainer.party
        partyTemp.push(Marshal.dump(poke))
    end
    
    pokemonArray=[]
    for poke in $Trainer.party
     # poke.abilityflag="nil" if !poke.abilityflag
      if !poke.isShiny?
        shininess=0
      else
        shininess=1 
      end
        varArray=[poke.species,
        100,
        poke.iv[0],
        poke.iv[1],
        poke.iv[2],
        poke.iv[3],
        poke.iv[4],
        poke.iv[5],
        poke.ev[0],
        poke.ev[1],
        poke.ev[2],
        poke.ev[3],
        poke.ev[4],
        poke.ev[5],
        poke.personalID,
        poke.trainerID,
        poke.item,
        poke.name,
        poke.exp,
        poke.happiness,
        poke.moves[0].id,
        poke.moves[0].pp,
        poke.moves[1].id,
        poke.moves[1].pp,
        poke.moves[2].id,
        poke.moves[2].pp,
        poke.moves[3].id,
        poke.moves[3].pp,
        poke.form,
        poke.nature,
        poke.totalhp,
        poke.attack,
        poke.defense,
        poke.spatk,
        poke.spdef,
        poke.speed,
        poke.ballused,
        poke.ot,
        shininess,
        poke.abilityIndex]
        for var in pokemonArray
            var=var.to_s
        end
      pokemonArray.push(varArray.join("^%*"))
    end
    mons=pokemonArray.join("/u/")
    trainerAry=[$Trainer.name, $Trainer.id, $Trainer.trainertype, mons,2]
    
    serialized=trainerAry.join("/g/")
    $onlineChallengee = serialized
    # Storing own trainer data to send later 
    @waitgraph.visible=true
  end    
################################################################################
#-------------------------------------------------------------------------------
#Checks server's response for battle
#-------------------------------------------------------------------------------
################################################################################
  def rejectionB(user)
    @waitgraph.visible=false
    Kernel.pbMessage("#{user} has declined your challenge.")
    $Trainer.party = $Trainer.storedOnlineParty
    $Trainer.storedOnlineParty=[]
    return tradeorbattle
  end  

  def choose_field(player,result,opponent,name)
    @waitgraph.visible=false
    if result == 0
      Kernel.pbMessage(_INTL("The user #{player} does not exist."))
      $Trainer.party = $Trainer.storedOnlineParty
      $Trainer.storedOnlineParty=[]
      tradeorbattle
    elsif result == 1
      Kernel.pbMessage(_INTL("The user #{player} has been banned."))
      $Trainer.party = $Trainer.storedOnlineParty
      $Trainer.storedOnlineParty=[]
      tradeorbattle
    elsif result == 2
      Kernel.pbMessage(_INTL("The user #{player} is not online."))
      $Trainer.party = $Trainer.storedOnlineParty
      $Trainer.storedOnlineParty=[]
      tradeorbattle
    elsif result == 3
      Kernel.pbMessage(_INTL("The user #{player} has declined or did not respond your battle request."))
      $Trainer.party = $Trainer.storedOnlineParty
      $Trainer.storedOnlineParty=[]
      tradeorbattle
    elsif result == 4
      commands=[_INTL("Yes")]
      commands.push(_INTL("No"))
      unpacked=opponent.split("/g/")
      @doubles = unpacked[4].to_i
      if @doubles==0 #Single battle
        choice=Kernel.pbMessage(_INTL("You have been challenged by #{name} for a singles battle. Do you accept?"),commands)
      else #Doubles battle
        choice=Kernel.pbMessage(_INTL("You have been challenged by #{name} for a doubles battle. Do you accept?"),commands)
      end
      if choice==0
        # Gather opponent's details into $onlineChallenger  
        unpacked[3]=unpacked[3].split("/u/")
        pokeAry=[]
        for prePoke in unpacked[3]
          longarray=prePoke.split("^%*")
          mon=PokeBattle_Pokemon.new(longarray[0].to_i,100)
          thing=0
          for v in 2..7
            mon.iv[thing]=longarray[v].to_i
            thing+=1
          end
          thing=0
          for v in 8..13
            mon.ev[thing]=longarray[v].to_i
            thing+=1
          end          
          mon.personalID=longarray[14].to_i
          mon.trainerID=longarray[15].to_i
          mon.item=longarray[16].to_i
          mon.name=longarray[17]
          mon.exp=longarray[18].to_i
          mon.happiness=longarray[19].to_i
          for i in 0..3
            mon.moves[i]=PBMove.new(longarray[20+(i*2)].to_i)
            mon.moves[i].pp=longarray[21+(i*2)].to_i
          end
          mon.form=longarray[28].to_i
          mon.setNature(longarray[29].to_i)
          mon.ballused=longarray[36].to_i     
          mon.ot=longarray[37]
          if longarray[38].to_i==0 && mon.isShiny?
            mon.makeNotShiny
          end
          mon.setAbility(longarray[39].to_i)
          pokeAry.push(mon)
        end            
        deserialized=PokeBattle_Trainer.new(unpacked[0],unpacked[2])
        deserialized.id=unpacked[1]
        deserialized.party=pokeAry
        $onlineChallenger = deserialized   
        # Opponent information gathered and stored
        fields=[_INTL("No Field")]
        fields.push(_INTL("Random"))
        for i in 1..37
          fields.push(FIELDEFFECTS[i][:FIELDNAME])
        end
        choose=Kernel.pbMessage(_INTL("What field would you like to battle on?"),fields)
        $network.send("<BATHOST user=#{name} trainer=#{$onlineChallengee} field=#{choose} name=#{player}>")      
      elsif choice==1
        $network.send("<BATREJ user=#{$network.username} name=#{name}>")
        $Trainer.party = $Trainer.storedOnlineParty
        $Trainer.storedOnlineParty=[]
        return tradeorbattle
      end
    end    
  end
  
  def offer_field(opponent,result,field,name)
    @waitgraph.visible=false
    # Gather opponent's details into $onlineChallenger
    begin
      unpacked=opponent.split("/g/")
      unpacked[3]=unpacked[3].split("/u/")
    rescue
      Kernel.pbMessage("Something has gone wrong. It might be possible that you've both challenged each other instead of one waiting for a challenge.")
      return tradeorbattle
    end
    pokeAry=[]
    for prePoke in unpacked[3]
        longarray=prePoke.split("^%*")
        mon=PokeBattle_Pokemon.new(longarray[0].to_i,100)
        thing=0
        for v in 2..7
          mon.iv[thing]=longarray[v].to_i
          thing+=1
        end
        thing=0
        for v in 8..13
          mon.ev[thing]=longarray[v].to_i
          thing+=1
        end          
      mon.personalID=longarray[14].to_i
      mon.trainerID=longarray[15].to_i
      mon.item=longarray[16].to_i
      mon.name=longarray[17]
      mon.exp=longarray[18].to_i
      mon.happiness=longarray[19].to_i
      for i in 0..3
        mon.moves[i]=PBMove.new(longarray[20+(i*2)].to_i)
        mon.moves[i].pp=longarray[21+(i*2)].to_i
      end
      mon.form=longarray[28].to_i
      mon.setNature(longarray[29].to_i)
      mon.ballused=longarray[36].to_i     
      mon.ot=longarray[37]
      if longarray[38].to_i==0 && mon.isShiny?
        mon.makeNotShiny
      end
     # if longarray[38]!="nil"
        mon.setAbility(longarray[39].to_i)
     # end
      pokeAry.push(mon)
    end            
    deserialized=PokeBattle_Trainer.new(unpacked[0],unpacked[2])
    deserialized.id=unpacked[1]
    deserialized.party=pokeAry
    $onlineChallenger = deserialized   
    # Opponent information gathered and stored
    commands=[_INTL("Yes")]
    commands.push(_INTL("No"))
    case result
    when 0 #No field
      Kernel.pbMessage("Your opponent has chosen to battle with no field.")
      $feonline = 0      
      $network.send("<BATFIELD result=0 effect=#{field} name=#{name}>")
      return
    when 1 #Random field
      mess = "Your opponent has chosen to battle in a random field. Do you accept?"              
    when 5, 24, 26 #Dark Crystal Cavern, Cave, Cystal Cavern
      mess = "Your opponent has chosen to battle in the " + FIELDEFFECTS[field][:FIELDNAME] + ". Do you accept?"
    when 23 #Underwater
      mess = "Your opponent has chosen to battle " + FIELDEFFECTS[field][:FIELDNAME] + ". Do you accept?"
    else
      mess = "Your opponent has chosen to battle on the " + FIELDEFFECTS[field][:FIELDNAME] + ". Do you accept?"
    end
    choice=Kernel.pbMessage(_INTL(mess),commands)                  
    if choice==0
      $feonline = field
      $network.send("<BATFIELD result=#{choice} effect=#{field} name=#{name}>")    
    elsif choice==1
      $feonline = 0
      $network.send("<BATFIELD result=#{choice} effect=0> name=#{name}")
    end  
  end  

  def initiate_battle(result,effect,user)
    if user==0
      if effect==0
        $feonline=38
      else        
        $feonline=effect
      end      
      Kernel.pbMessage(_INTL("Your battle will begin shortly."))
      #Kernel.pbMessage(_INTL("Do not click outside the window during the battle!"))      
      return start_battle($onlineChallenger,user)
    elsif user==1
      if result==0
        if effect==0
          $feonline=38
        else        
          $feonline=effect
        end      
        Kernel.pbMessage(_INTL("The opponent has accepted your field choice. Your battle will begin shortly."))
        #Kernel.pbMessage(_INTL("Do not click outside the window during the battle!"))          
        return start_battle($onlineChallenger,user)
      elsif result==1
        $feonline=0
        Kernel.pbMessage(_INTL("The opponent has declined your field choice. Your battle will begin shortly."))
        #Kernel.pbMessage(_INTL("Do not click outside the window during the battle!"))                
        return start_battle($onlineChallenger,user)
      end
    end
  end
  
  def check_battle(player,result,opponent)
    case result
    when 0
      Kernel.pbMessage(_INTL("The user #{player} does not exist."))
      tradeorbattle
    when 1
      Kernel.pbMessage(_INTL("The user #{player} has been banned."))
      tradeorbattle
    when 2
      Kernel.pbMessage(_INTL("The user #{player} is not online."))
      tradeorbattle
    when 3
      Kernel.pbMessage(_INTL("The user #{player} has declined or did not respond your battle request."))
      tradeorbattle
    when 4
      Kernel.pbMessage(_INTL("The user #{player} has accepted your battle request."))
      #Kernel.pbMessage(_INTL("Do not click outside the window during the battle!"))
 
      unpacked=opponent.split("/g/")
      unpacked[3]=unpacked[3].split("/u/")
      pokeAry=[]
      for prePoke in unpacked[3]
        longarray=prePoke.split("^%*")
        mon=PokeBattle_Pokemon.new(longarray[0].to_i,100)
        thing=0
        for v in 2..7
          mon.iv[thing]=longarray[v].to_i
          thing+=1
        end
        thing=0
        for v in 8..13
          mon.ev[thing]=longarray[v].to_i
          thing+=1
        end
        
        mon.personalID=longarray[14].to_i
        mon.trainerID=longarray[15].to_i
        mon.item=longarray[16].to_i
        mon.name=longarray[17]
        mon.exp=longarray[18].to_i
        mon.happiness[19].to_i
        for i in 0..3
          mon.moves[i]=PBMove.new(longarray[20+(i*2)].to_i)
          mon.moves[i].pp=longarray[21+(i*2)].to_i
        end
        mon.form=longarray[28].to_i
        mon.setNature(longarray[29].to_i)
        mon.ballused=longarray[36].to_i  
        mon.ot=longarray[37]
 
        if longarray[38].to_i==0 && mon.isShiny?
          mon.makeNotShiny
        elsif !mon.isShiny?
         # mon.makeShiny
        end
        
        mon.setAbility(longarray[39].to_i)
        pokeAry.push(mon)
      end
      
      
      
      deserialized=PokeBattle_Trainer.new(unpacked[0],unpacked[2])
      deserialized.id=unpacked[1]
      deserialized.party=pokeAry
 
      return start_battle(deserialized)
    end
  end
################################################################################
#-------------------------------------------------------------------------------
#Executes a battle
#-------------------------------------------------------------------------------
################################################################################
  def start_battle(opponent,tiebreak)
    scene=pbNewBattleScene
    battle=PokeBattle_OnlineBattle.new(scene,$Trainer.party,opponent.party,$Trainer,opponent,tiebreak)
    battle.doublebattle = @doubles==1
    $OnlineBattle = battle

    battle.fullparty1=$Trainer.party.length == 6
    battle.fullparty2=opponent.party.length == 6
    battle.endspeech=""
    battle.internalbattle=false
    restorebgm=true
    playingBGS=$game_system.getPlayingBGS
    playingBGM=$game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause  
    decision=0
    decision=battle.pbStartBattle(true)
  
    #After the battle is over
    $OnlineBattle = nil
    $Trainer.party=$Trainer.storedOnlineParty
    $Trainer.storedOnlineParty=[]
    if decision==1
      Kernel.pbMessage("You won the battle.")
    else
      Kernel.pbMessage("You lost the battle.")
    end
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
    tradeorbattle
 end
     
################################################################################
#-------------------------------------------------------------------------------
#Handles Random Battling
#-------------------------------------------------------------------------------
################################################################################
  def randbat    
    if !$Trainer.party[0] || $Trainer.party[0].egg? || $Trainer.party[0].hp<1
      Kernel.pbMessage("You need to be able to use the first Pokemon in your party.")
      return tradeorbattle
    end
    
    $Trainer.storedOnlineParty=Array.new
    for i in 0..$Trainer.party.length-1
      $Trainer.storedOnlineParty[i]=$Trainer.party[i].clone
    end
    for i in 0..$Trainer.party.length-1
      $Trainer.party[i].moves = $Trainer.party[i].moves.clone
      $Trainer.party[i].moves.map! {|move| move.clone}
      $Trainer.party[i].heal
    end
    for i in $Trainer.party
      i.level=100
      i.calcStats
    end
    
#    $waitchallenge = true
    
    partyTemp=[]
    for poke in $Trainer.party
        partyTemp.push(Marshal.dump(poke))
    end
    
    pokemonArray=[]
    for poke in $Trainer.party
    #  poke.abilityflag="nil" if !poke.abilityflag
      if !poke.isShiny?
        shininess=0
      else
        shininess=1 
      end
        varArray=[poke.species,
        100,
        poke.iv[0],
        poke.iv[1],
        poke.iv[2],
        poke.iv[3],
        poke.iv[4],
        poke.iv[5],
        poke.ev[0],
        poke.ev[1],
        poke.ev[2],
        poke.ev[3],
        poke.ev[4],
        poke.ev[5],
        poke.personalID,
        poke.trainerID,
        poke.item,
        poke.name,
        poke.exp,
        poke.happiness,
        poke.moves[0].id,
        poke.moves[0].pp,
        poke.moves[1].id,
        poke.moves[1].pp,
        poke.moves[2].id,
        poke.moves[2].pp,
        poke.moves[3].id,
        poke.moves[3].pp,
                poke.form,
                poke.nature,
                poke.totalhp,
                poke.attack,
                poke.defense,
                poke.spatk,
                poke.spdef,
                poke.speed,
        poke.ballused,
        poke.ot,
        shininess,
        poke.abilityIndex]
        for var in pokemonArray
            var=var.to_s
        end
      pokemonArray.push(varArray.join("^%*"))
    end
  mons=pokemonArray.join("/u/")
    trainerAry=[$Trainer.name,
    $Trainer.id,
    $Trainer.trainertype,
    mons]
    
    
    serialized=trainerAry.join("/g/")
    $onlineChallengee = serialized
    # Storing own trainer data to send later       
    $network.send("<RANBAT>") 
    @waitgraph.visible=true
  end
   
  def rand_verify(name,tie)
    @waitgraph.visible=false
    @tiebreak = tie
    commands=[_INTL("Yes")]
    commands.push(_INTL("No"))
    choice=Kernel.pbMessage(_INTL("Would you like to battle with #{name}?"),commands)                  
    if choice==0
      $network.send("<RANVER name=#{name} trainer=#{$onlineChallengee}>") 
    elsif choice==1
      $network.send("<NORAN name=#{name}>")
      randbat
    end
  end
  
  def rand_reject(name)
   # $waitchallenge = false
    Kernel.pbMessage("Your opponent either declined or did not respond.")
    $Trainer.party = $Trainer.storedOnlineParty
    $Trainer.storedOnlineParty=[]
    randbat
  end  
 
  def get_randopp(opponent)
    #$waitchallenge = false
    # Gather opponent's details into $onlineChallenger  
    unpacked=opponent.split("/g/")
    unpacked[3]=unpacked[3].split("/u/")   
    pokeAry=[]
    for prePoke in unpacked[3]
        longarray=prePoke.split("^%*")
        mon=PokeBattle_Pokemon.new(longarray[0].to_i,100)
        thing=0
        for v in 2..7
          mon.iv[thing]=longarray[v].to_i
          thing+=1
        end
        thing=0
        for v in 8..13
          mon.ev[thing]=longarray[v].to_i
          thing+=1
        end          
      mon.personalID=longarray[14].to_i
      mon.trainerID=longarray[15].to_i
      mon.item=longarray[16].to_i
      mon.name=longarray[17]
      mon.exp=longarray[18].to_i
      mon.happiness=longarray[19].to_i
      for i in 0..3
        mon.moves[i]=PBMove.new(longarray[20+(i*2)].to_i)
        mon.moves[i].pp=longarray[21+(i*2)].to_i
      end
      mon.form=longarray[28].to_i
      mon.setNature(longarray[29].to_i)
      mon.ballused=longarray[36].to_i     
      mon.ot=longarray[37]
      if longarray[38].to_i==0 && mon.isShiny?
        mon.makeNotShiny
      end
  #    if longarray[38]!="nil"
        mon.setAbility(longarray[39].to_i)
  #    end
      pokeAry.push(mon)
    end  
    deserialized=PokeBattle_Trainer.new(unpacked[0],unpacked[2])
    deserialized.id=unpacked[1]
    deserialized.party=pokeAry
    $onlineChallenger = deserialized 
    # Opponent information gathered and stored
    $network.send("<YESRAN>")
  end    
 
def getversion()
  _version = "19"
  return _version
end
