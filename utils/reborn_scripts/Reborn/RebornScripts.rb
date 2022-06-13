############################################################
# Reborn Specific Things Ame Doesn't Know Where Else To Put
############################################################
class PokemonGlobalMetadata
    attr_accessor :tutoredMoves
    attr_accessor :storedMovesets
  end

  def pbBridgeOn # so old saves don't crash
  end

  def pbBridgeOff # so old saves don't crash
  end
  
  def pbTicketViewport
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  end
  
  def pbTicketText(textno)
    @sprites={} if !@sprites
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height) if !@viewport
    @viewport.z=99999    
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport) if !@sprites["overlay"] || @sprites["overlay"].disposed?
    overlay=@sprites["overlay"].bitmap
    #overlay.clear 
    playerName=_INTL("{1}",$Trainer.name)
    case $game_variables[:Player_Gender]
    when 0
      playerGender=_INTL("Male")
    when 1
      playerGender=_INTL("Female")
    when 2
      playerGender=_INTL("Non-Binary")
    end    
    baseColor=Color.new(78,66,66)
    shadowColor=Color.new(159,150,144) 
    textPositions=[
        [playerName,(Graphics.width/2)-143,32+166,0,baseColor,shadowColor],       
        [playerGender,(Graphics.width/2)+26,32+166,0,baseColor,shadowColor],       
        ["8R750",(Graphics.width/2)-83,32+189,0,baseColor,shadowColor],       
        ["5D",(Graphics.width/2)+98,32+189,0,baseColor,shadowColor],       
        ["Grandview Station",(Graphics.width/2)-73,32+216,0,baseColor,shadowColor],       
        ["ONE",(Graphics.width/2)-60,32+241,0,baseColor,shadowColor],       
        ["SGL",(Graphics.width/2)+98,32+241,0,baseColor,shadowColor],       
    ]
    finalTextPositions=[textPositions[textno]]
    overlay.font.name="PokemonEmerald"
    overlay.font.size=36   
    pbDrawTextPositions(overlay,finalTextPositions)
  end
  
  def pbTicketClear
    @sprites.clear
    @viewport.dispose
  end
  
  
  def pbDexCert
    #@viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    totalsec = Graphics.frame_count / 40 #Graphics.frame_rate  #Because Turbo exists
    hour = ((totalsec / 60) / 60)
    min = ((totalsec / 60) % 60)
    time=_ISPRINTF("{1:02d}:{2:02d}",hour,min)
    @sprites={} if !@sprites
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height) if !@viewport
    @viewport.z=99999    
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport) if !@sprites["overlay"] || @sprites["overlay"].disposed?
    overlay=@sprites["overlay"].bitmap
    #overlay.clear 
    playerName=_INTL("{1}",$Trainer.name)
    
    baseColor=Color.new(210,215,220) # Updated
    shadowColor=Color.new(70,75,80) # Updated
    textPositions=[
        [playerName,(Graphics.width/2)+64,38,0,baseColor,shadowColor],       
        [time,(Graphics.width/2)+88,290,0,baseColor,shadowColor],            
    ]
    finalTextPositions=[textPositions[0],textPositions[1]]
    overlay.font.name="PokemonEmerald"
    overlay.font.size=36   
    pbDrawTextPositions(overlay,finalTextPositions)
  end
  
  def pbCalculateTypeQuiz
    typeNames=[   "Normal","Fire","Water","Electric","Grass","Ice","Fighting","Poison","Ground","Flying","Psychic","Bug","Rock","Ghost","Dragon","Dark","Steel","Fairy" ]
    scoreHash=[]
    for i in 0...18
      varIdx = 701+i
      typeArr = { id: i, name: typeNames[i], score: $game_variables[varIdx] }
      scoreHash.push(typeArr)
    end
    scoreHash.shuffle!
    scoreArr = scoreHash.sort {|b,a| a[:score] <=> b[:score]}
    finalType = scoreArr[0][:name]
    finalId = scoreArr[0][:id] + 1
    if ((scoreArr[0][:score] - scoreArr[1][:score]) < 2) || ((scoreArr[1][:score] - scoreArr[2][:score]) > 2) # difference between 1st and 2nd place of 0 or 1, or difference between 2nd and 3nd place of more than 2
      finalType += "/" + scoreArr[1][:name]
    end
    $game_variables[719] = finalType
    $game_variables[62] = finalId
  end
  
  
  def pbGuessPlayerName()
    userName=pbGetUserName()
    userName=userName.gsub(/\s+.*$/,"")
    if userName.length>0
      userName[0,1]=userName[0,1].upcase
      return userName
    end
    userName=userName.gsub(/\d+$/,"")
    if userName.length>0
      userName[0,1]=userName[0,1].upcase
      return userName
    end
    print("couldn't get username [ #{userName}] please report this message: ")
    #owner=MiniRegistry.get(MiniRegistry::HKEY_LOCAL_MACHINE,
    #   "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
    #   "RegisteredOwner","")
    #owner=owner.gsub(/\s+.*$/,"")
    #if owner.length>0 && owner.length<7
    #  owner[0,1]=owner[0,1].upcase
    #  return owner
    #end
    return 0
  end
  
  def pbFakeStorePokemon(pokemon)
    if pbBoxesFull?
      Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
      Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
      return
    end
    pokemon.pbRecordFirstMoves
    monsent=false
    while !monsent
      if Kernel.pbConfirmMessageSerious(_INTL("The party is full; do you want to send a party member to the PC?"))
        iMon = -2 
        unusablecount = 0
        for i in $Trainer.party
          next if i.isEgg?
          next if i.hp<1
          unusablecount += 1
        end
        pbFadeOutIn(99999){
          scene=PokemonScreen_Scene.new
          screen=PokemonScreen.new(scene,$Trainer.party)
          screen.pbStartScene(_INTL("Choose a Pokémon."),false)
          loop do
            iMon=screen.pbChoosePokemon
            if iMon>=0 && ($Trainer.party[iMon].knowsMove?(:CUT) || $Trainer.party[iMon].knowsMove?(:ROCKSMASH) || $Trainer.party[iMon].knowsMove?(:STRENGTH) || $Trainer.party[iMon].knowsMove?(:SURF) || $Trainer.party[iMon].knowsMove?(:WATERFALL) || $Trainer.party[iMon].knowsMove?(:DIVE) || $Trainer.party[iMon].knowsMove?(:ROCKCLIMB) || $Trainer.party[iMon].knowsMove?(:FLASH) || $Trainer.party[iMon].knowsMove?(:FLY))
              Kernel.pbMessage("You can't return a Pokémon that knows a TMX move to the PC.") 
              iMon=-2
            elsif unusablecount<=1 && !($Trainer.party[iMon].isEgg?) && $Trainer.party[iMon].hp>0 && pokemon.isEgg?
              Kernel.pbMessage("That's your last Pokémon!") 
            else
              screen.pbEndScene
              break
            end
          end
        }
        if !(iMon < 0)    
          iBox = 0
          if iBox >= 0
            monsent=true
            #$Trainer.party[iMon].heal
            Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
            #$Trainer.party[iMon] = nil
            #$Trainer.party.compact!
          else
            Kernel.pbMessage("No space left in the PC")
            return false
          end
        end      
      else
        monsent=true
        oldcurbox=$PokemonStorage.currentBox
        curboxname=$PokemonStorage[oldcurbox].name
        boxname=$PokemonStorage[oldcurbox].name
        creator=nil
        creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
        if creator
          Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
        else
          Kernel.pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
        end
        Kernel.pbMessage(_INTL("It was stored in box \"{1}\".",boxname))
      end   
    end
  end
  
  def copyTrainerTeam()
    copied_team = []
    $Trainer.party.each {|mon|
      next if mon.isEgg?
      copy=PokeBattle_Pokemon.new(mon.species, mon.level)
      #descriptive data
      copy.personalID=mon.personalID
      copy.trainerID = mon.trainerID
      copy.name = mon.name
      case mon.gender
        when 0 then copy.makeMale
        when 1 then copy.makeFemale
        else copy.makeGenderless
      end
      copy.shinyflag = mon.shinyflag
      copy.form = mon.form
      #EVs,IVs,Nature
      copy.iv.map! {|_| 31}
      copy.ev.map! {|_| 252}
      copy.natureflag=mon.natureflag
      #ability, item
      copy.abilityflag = mon.abilityflag
      copy.item = mon.item
      #Moves
      copy.moves = []
      mon.moves.each {|move|
        newmove = PBMove.new(move.id)
        copy.moves.push(newmove)
      }
      #other
      copy.happiness=mon.happiness
      copy.calcStats
      copy.heal
      copied_team.push(copy)
    }
    return copied_team
  end
  
  def necrozmaLightHandler() #all of these four functions are some of the worst code i've written and i'm so sorry, iw asn't ready for any of this i didnt want this i just wanted mirror puzzle i just--
    #if this puzzle starts breakign inconsistently, a first line of attack should be to refactor the below three methods (except lightkiller) into one. 
    #this one and the next run at the same time time, the third waits 1 frame, unsure if necessary
    for i in 0...4
      thisLight = 66 + i
      next if $game_switches[(thisLight + 1817)] == true
      if $game_map.events[thisLight].x == 17 && $game_map.events[thisLight].y == 61 #topleftmir 
        lightVar = 661 + thisLight
        $game_variables[lightVar] = 8
        $game_map.need_refresh = true
     # elsif $game_map.events[thisLight].x == 28 && $game_map.events[thisLight].y == 61 #topright
     #   lightVar = 661 + thisLight
     #   $game_variables[lightVar] = 6
     #   $game_map.need_refresh = true
      elsif $game_map.events[thisLight].x == 17 && $game_map.events[thisLight].y == 67 #botleftmir
        lightVar = 661 + thisLight
        $game_variables[lightVar] = 2
        $game_map.need_refresh = true
      elsif $game_map.events[thisLight].x == 28 && $game_map.events[thisLight].y == 67 #botrightmir
        lightVar = 661 + thisLight
        $game_variables[lightVar] = 4
        $game_map.need_refresh = true
      end
      if $game_map.events[thisLight].x == $game_map.events[72].x && #serra
        $game_map.events[thisLight].y == $game_map.events[72].y &&
        $game_switches[1899] == true
        case $game_map.events[72].direction
          when 2
            $game_map.events[thisLight].turn_down
          when 4
            $game_map.events[thisLight].turn_left
          when 6
            $game_map.events[thisLight].turn_right
          when 8
            $game_map.events[thisLight].turn_up
        end
        if $game_variables[725] == 6 # story trigger
          $game_variables[725] = 7
        end
      end
      for j in 0...3 # pushable mirrrors --- i typo'd this as 43 instead and it turned EVERYTHING INTO MIRRORS AAAAAAAAAAAA
        targetMir = 73 + j
        if $game_map.events[thisLight].x == $game_map.events[targetMir].x &&
          $game_map.events[thisLight].y == $game_map.events[targetMir].y
          switchLight = thisLight + 1817
          if $game_switches[switchLight] == false
            thisLight += 661
            $game_variables[thisLight] = $game_map.events[targetMir].direction
            $game_map.need_refresh = true
            break
          end
        end
      end
    end
  end
  
  def necrozmaLightKiller(thisLight)
    thisLight += 1817
    $game_switches[thisLight] = true
    $game_map.need_refresh = true
  end
  
  def necrozmaMirrorHandler()
    for i in 0...4
      thisLight = 66 + i
      next if $game_switches[(thisLight + 1817)] == true
      lightVar = 661 + thisLight
      case $game_variables[lightVar]
        when 0 
          next
        when 2
          if $game_map.events[thisLight].direction == 2
            $game_map.events[thisLight].move_right
          elsif $game_map.events[thisLight].direction == 4
            $game_map.events[thisLight].move_up
          else
            necrozmaLightKiller(thisLight)
          end
      when 6
          if $game_map.events[thisLight].direction == 8
            $game_map.events[thisLight].move_left
          elsif $game_map.events[thisLight].direction == 6
            $game_map.events[thisLight].move_down
          else
            necrozmaLightKiller(thisLight)
          end
      when 4
          if $game_map.events[thisLight].direction == 2
            $game_map.events[thisLight].move_left
          elsif $game_map.events[thisLight].direction == 6
            $game_map.events[thisLight].move_up
          else
            necrozmaLightKiller(thisLight)
          end
      when 8  
          if $game_map.events[thisLight].direction == 8
            $game_map.events[thisLight].move_right
          elsif $game_map.events[thisLight].direction == 4
            $game_map.events[thisLight].move_down
          else
            necrozmaLightKiller(thisLight)
          end
      end
      $game_variables[lightVar] = 0
    end
  end
  
  def necrozmaLightFinisher() 
    obstacleArray = [80,95,107,108,109,136]
    red1Array = [110,111,112,113] #help
    red2Array = [115,116,117,118,146]
    for i in 0...4 
      thisLight = 66 + i #ending crystals
      next if $game_switches[(thisLight + 1817)] == true
      if $game_map.events[thisLight].x == 18 && $game_map.events[thisLight].y == 60 #b
        $game_switches[1887] = true
        pbSEPlay("PRSFX- Acid Downpour5",100)
        necrozmaLightKiller(thisLight)
      elsif $game_map.events[thisLight].x == 27 && $game_map.events[thisLight].y == 60 #r
        $game_switches[1889] = true
        pbSEPlay("PRSFX- Acid Downpour5",100)
        necrozmaLightKiller(thisLight)
      elsif $game_map.events[thisLight].x == 18 && $game_map.events[thisLight].y == 68 #g
        $game_switches[1888] = true
        pbSEPlay("PRSFX- Acid Downpour5",100)
        necrozmaLightKiller(thisLight)
      elsif $game_map.events[thisLight].x == 27 && $game_map.events[thisLight].y == 68 #p
        $game_switches[1890] = true
        pbSEPlay("PRSFX- Acid Downpour5",100)
        necrozmaLightKiller(thisLight)
      end 
      if $game_map.events[thisLight].x < 17 || $game_map.events[thisLight].x > 28 ||    
        $game_map.events[thisLight].y < 60 || $game_map.events[thisLight].y > 68
        necrozmaLightKiller(thisLight)
      end
      for j in 0...obstacleArray.length # arbitrary obstacles 
        if $game_map.events[thisLight].x == $game_map.events[obstacleArray[j]].x &&
          $game_map.events[thisLight].y == $game_map.events[obstacleArray[j]].y
          necrozmaLightKiller(thisLight)
        end
      end
      for j in 0...red1Array.length # red rocks part 1
        if $game_map.events[thisLight].x == $game_map.events[red1Array[j]].x &&
          $game_map.events[thisLight].y == $game_map.events[red1Array[j]].y && 
          $game_switches[1893] == false
          necrozmaLightKiller(thisLight)
        end
      end
      for j in 0...red2Array.length # red rocks part 2 becuase everything is awful
        if $game_map.events[thisLight].x == $game_map.events[red2Array[j]].x &&
          $game_map.events[thisLight].y == $game_map.events[red2Array[j]].y && 
          $game_switches[1893] == true
          necrozmaLightKiller(thisLight)
        end
      end
      # i didnt intend to script any of this i just thought it would be easier and technically it might've been but aaaaaaaaaa
    end
    if $game_switches[1883] == true && $game_switches[1884] == true &&
     $game_switches[1885] == true && $game_switches[1886] == true
      $game_switches[1882] = false
      $game_map.need_refresh = true
    end
  end
  
  def checkTutorMove(moveid)
    $PokemonGlobal.tutoredMoves = [] if !$PokemonGlobal.tutoredMoves
    return $PokemonGlobal.tutoredMoves.include?(moveid)
  end
  
  def addTutorMove(moveid)
    $PokemonGlobal.tutoredMoves.push(moveid)
  end
  
  #########################################################################
  # Passwords                                                             #
  #########################################################################
  
  PASSWORD_HASH = {
    # Mono passwords
    "mononormal" => 1182  , "normal" => 1182,
    "monofire" => 1183    , "fire" => 1183,
    "monowater" => 1184   , "water" => 1184,
    "monograss"=> 1185    , "grass"=> 1185,
    "monoelectric"=> 1186 , "electric"=> 1186,
    "monoice"=> 1187      , "ice"=> 1187,
    "monopoison"=> 1190   , "poison"=> 1190,
    "monofighting"=> 1188 , "fighting"=> 1188,
    "monoground"=> 1189   , "ground"=> 1189,
    "monoflying"=> 1192   , "flying"=> 1192,
    "monobug"=> 1193      , "bug"=> 1193,
    "monopsychic"=> 1194  , "psychic"=> 1194,
    "monorock"=> 1191     , "rock"=> 1191,
    "monoghost"=> 1195    , "ghost"=> 1195,
    "monodragon"=> 1196   , "dragon"=> 1196,
    "monodark"=> 1197     , "dark"=> 1197,
    "monosteel"=> 1198    , "steel"=> 1198,
    "monofairy"=> 1199    , "fairy"=> 1199,
  
    # QoL
    "easyhms" => :EasyHMs_Password, "nohms" => :EasyHMs_Password, "hmitems" => :EasyHMs_Password, "notmxneeded" => :EasyHMs_Password,
    "hardcap" => :Hard_Level_Cap, "rejuvcap" => :Hard_Level_Cap, "rejuvenation" => :Hard_Level_Cap,
    "fieldapp" => 2055, "fieldnotes" => 2055, "fieldtexts" => 2055, "allfieldapp" => 2055,
    "earlyincu" => 2090,
    "stablweather" => :Stable_Weather_Password,
    "weathermod" => :Weather_password,
    "nopoisondam" => :Overworld_Poison_Password, "antidote" => :Overworld_Poison_Password,
    "nodamageroll" => 2070, "norolls" => 2070, "rolls" => 2070,
    "pinata" => 2181,
    "freemegaz" => 2166,
    "freeremotepc" => :Free_Remote_PC,
    "freeexpall" => 2183,
    "powerpack" => 2209,
    "shinycharm" => 2189, "earlyshiny" => 2189,
    "mintyfresh" => 2190, "agiftfromace" => 2190,
  
    # Difficulty passwords
    "litemode" => :Empty_IVs_And_EVs_Password, "noevs" => :Empty_IVs_And_EVs_Password, "emptyevs" => :Empty_IVs_And_EVs_Password,
    "nopenny" => :Penniless_Mode,
    "broke_trainer" => :Grinding_Trainer_Money_Cut,
    "fullevs" => :Only_Pulse_2, "pulse2" => :Only_Pulse_2, "pulse2evs" => :Only_Pulse_2,
    "noitems" => :No_Items_Password, "nobattleitems" => :No_Items_Password, "notraineritems" => :No_Items_Password,
    "nuzlocke" => :Nuzlocke_Mode, "locke" => :Nuzlocke_Mode, "permadeath" => :Nuzlocke_Mode,
    "moneybags" => :Moneybags, "richboy" => :Moneybags, "doublemoney" => :Moneybags,
    "fullivs" => :Full_IVs, "31ivs" => :Full_IVs, "allivs" => :Full_IVs, "mischievous" => :Full_IVs,
    "emptyivs" => :Empty_IVs_Password, "0ivs" => :Empty_IVs_Password, "noivs" => :Empty_IVs_Password,
    "leveloffset" => :Offset_Trainer_Levels, "setlevel" => :Offset_Trainer_Levels, "flatlevel" => :Offset_Trainer_Levels,
    "percentlevel" => :Percent_Trainer_Levels, "levelpercent" => :Percent_Trainer_Levels,
    "stopitems" => :Stop_Items_Password,
    "stopgains" => :Stop_Ev_Gain,
    "noexp" => :No_EXP_Gain, "zeroexp" => :No_EXP_Gain, "0EXP" => :No_EXP_Gain,
    "flatevs" => :Flat_EV_Password, "85evs" => :Flat_EV_Password,
    "noevcap" => :No_Total_EV_Cap, "gen2mode" => :No_Total_EV_Cap,
  
    # Shenanigans
    "budewit" => :Just_Budew, "budew" => :Just_Budew, "worstgamemode" => :Just_Budew, "deargodwhy" => :Just_Budew,
    "wtfisafont" => 2036,
    "eeveeplease" => 1366, "eevee" => 1366, "bestgamemode" => 1366,
    "vulpixpls" => 2147,
    "justvulpix" => :Just_Vulpix,
    "dratiniearly" => 2138,
    "aevianmissy" => 2175,
    "gen5weather" => :Gen_5_Weather,
    "unrealtime" => :Unreal_Time,
    "monowoke" => :NB_Pokemon_Only, "wokemono" => :NB_Pokemon_Only,
    "inversemode" => :Inversemode
  }
  
  BULK_PASSWORDS = {
    "penniless" => ["nopenny", "broke_trainer"],
    "casspack" => ["noitems", "fullivs", "hardcap", "easyhms", "norolls"], "goodtaste" => ["noitems", "fullivs", "hardcap", "easyhms", "norolls"],
    "easymode" => ["fullivs", "moneybags", "litemode", "stopitems"],
    "hardmode" => ["noitems", "nopenny", "broke_trainer", "fullevs", "emptyivs"],
    "freebies" => ["freeexpall", "freeremotepc", "powerpack", "mintyfresh", "shinycharm", "freemegaz"],
    "qol"      => ["hardcap", "easyhms", "fieldapp", "earlyincu", "stablweather", "nopoisondam", "weathermod", "unrealtime", "pinata", "freeexpall", "freeremotepc", "powerpack"],
    "speedrun" => ["hardcap", "monopsychic", "easyhms", "fullivs", "norolls", "stablweather", "weathermod", "freemegaz", "earlyincu", "pinata", "mintyfresh", "freeexpall", "powerpack"],
    "speedrunnotx" => ["hardcap", "monopsychic", "easyhms", "fullivs", "norolls", "stablweather", "weathermod", "freemegaz", "earlyincu", "wtfisafont", "pinata", "mintyfresh", "freeexpall", "powerpack"]
  }
  
  def addPassword(entrytext)
    #add stuff to password array if cass makes a thing for that
    entrytext.downcase!
  
    # Check if string is in hashes
    if PASSWORD_HASH[entrytext]
      $game_switches[PASSWORD_HASH[entrytext]] = !$game_switches[PASSWORD_HASH[entrytext]]
    end

    if BULK_PASSWORDS[entrytext]

      # Activate ones that are not on yet
      if BULK_PASSWORDS[entrytext].any? {|string| $game_switches[PASSWORD_HASH[string]] == true } && !BULK_PASSWORDS[entrytext].all? {|string| $game_switches[PASSWORD_HASH[string]] == true }
        Kernel.pbMessage("Some passwords included in this paswordpack are already applied, all will be applied now.")
        BULK_PASSWORDS[entrytext].each {|password_string| 
          password = PASSWORD_HASH[password_string]
          $game_switches[password] = true
        }
      
      # Disable if all of them are on
      elsif BULK_PASSWORDS[entrytext].all? {|string| $game_switches[PASSWORD_HASH[string]] == true }
        if Kernel.pbConfirmMessage("All passwords included in this passwordpack are already turned on. Do you want to turn all of them off?")
          BULK_PASSWORDS[entrytext].each {|password_string| 
            password = PASSWORD_HASH[password_string]
            $game_switches[password] = false
          }
        else
          $game_switches[2037] = true
          return
        end

      # Just turn them all on
      else
        BULK_PASSWORDS[entrytext].each {|password_string| 
          password = PASSWORD_HASH[password_string]
          $game_switches[password] = true
        }
      end
    end
  
    #check for level passwords to go to adjustment section in event
    if ((entrytext == "leveloffset") || (entrytext == "setlevel") || (entrytext == "flatlevel" ))
        $game_variables[47] = 1
    end
    if ((entrytext == "percentlevel")||(entrytext == "levelpercent"))
        $game_variables[47] = 2
    end
    case entrytext
      # shenanigans
      when "randomizer", "random", "randomized", "randomiser", "randomised"   
        pbFadeOutIn(99999){
          RandomizerScene.new(RandomizerSettings.new)
        }
      else # no password given
        if PASSWORD_HASH[entrytext].nil? && BULK_PASSWORDS[entrytext].nil? && !["leveloffset", "setlevel", "flatlevel", "percentlevel", "levelpercent"].include?(entrytext)
          $game_switches[2037] = true 
        end
    end
  
    # flip all the field app switches
    if $game_switches[2055] == true 
      $game_switches[599] = true
      $game_switches[600] = true
      $game_switches[601] = true
      $game_switches[602] = true
      $game_switches[603] = true
      $game_switches[604] = true
      $game_switches[605] = true
      $game_switches[606] = true
      $game_switches[607] = true
      $game_switches[608] = true
      $game_switches[609] = true
      $game_switches[610] = true
      $game_switches[611] = true
      $game_switches[612] = true
      $game_switches[613] = true
      $game_switches[614] = true
      $game_switches[615] = true
      $game_switches[616] = true
      $game_switches[617] = true
      $game_switches[618] = true
      $game_switches[619] = true
      $game_switches[620] = true
      $game_switches[621] = true
      $game_switches[622] = true
      $game_switches[623] = true
      $game_switches[624] = true
      $game_switches[625] = true
      $game_switches[626] = true
      $game_switches[627] = true
      $game_switches[628] = true
      $game_switches[629] = true
      $game_switches[630] = true
      $game_switches[631] = true
      $game_switches[632] = true
      $game_switches[633] = true
      $game_switches[634] = true
      $game_switches[635] = true
      $game_switches[636] = true
    end
  end
  
  def checkPasswordActivation(entrytext)
    if PASSWORD_HASH[entrytext]
      return $game_switches[PASSWORD_HASH[entrytext]]
    end
    if BULK_PASSWORDS[entrytext]
      return $game_switches[PASSWORD_HASH[BULK_PASSWORDS[entrytext][0]]]
    end
  end

  #########################################################################
  # Passwords menu                                                        #
  #########################################################################
  
  def pbPasswordsMenu(maxOperations=nil)
    # Passing nil is the same as passsing infinite as maxOperations
    operationCost=1
    operationsLeft=maxOperations
    passwords=pbGetKnownOrActivePasswords()
    continue=true
    while continue
      continue,password=pbSelectPasswordToBeToggled(passwords, operationsLeft)
      next if !password
      next if !continue
      doExecute=true
      if maxOperations
        if operationsLeft<operationCost
          Kernel.pbMessage(_INTL('No Data Chip available to boot up the system.'))
          doExecute=false
        else
          doExecute=Kernel.pbConfirmMessage('This will consume a Data Chip. Do you want to continue?')
        end
      end
      password=password.downcase
      ids=pbGetPasswordIds(password)
      if !ids
        Kernel.pbMessage('That is not a password.')
        next
      end
      success=doExecute ? pbTogglePassword(password) : false
      alreadyKnown=true
      for id,pw in ids
        alreadyKnown=alreadyKnown && passwords[id] ? true : false
        # Toggle the password
        active=$game_switches[id] ? true : false
        passwords[id]={
          'password': pw,
          'active': active
        }
      end
      # Update the saved list
      # pbSaveKnownPasswordsToFile(passwords) if !alreadyKnown
      pbUpdateKnownPasswords(passwords) if !alreadyKnown
      # Pay the price
      operationsLeft-=operationCost if success && maxOperations
    end
    return 0 if !maxOperations
    return maxOperations-operationsLeft
  end
  
  def pbGetPasswordIds(password)
    retval={}
    id=PASSWORD_HASH[password]
    if id
      retval[id]=password
      return retval
    end
    passwordBulk=BULK_PASSWORDS[password]
    return nil if !passwordBulk
    retval={}
    for pw in passwordBulk
      id=PASSWORD_HASH[pw]
      retval[id]=pw if id
    end
    return nil if retval.empty?()
    return retval
  end
  
  def pbSelectPasswordToBeToggled(passwords, operationsLeft)
    pwList,pwListIds=pbPasswordsToList(passwords)
    i=Kernel.pbMessage(
      operationsLeft ? _INTL('Known passwords\nAvailable data chips: {1}', operationsLeft) : _INTL('Known passwords'),
      pwList,
      1
    )
    return false,nil if i<1
    if i>1
      # Already known
      choice=pwList[i]
      id=pwListIds[choice]
      password=passwords[id][:password]
      return true,password
    end
    # New password
    password=Kernel.pbMessageFreeText(_INTL('Which password would you like to add?'),'',false,12,Graphics.width)
    return true,password
  end
  
  def pbPasswordsToList(passwords)
    pws=[]
    marks={}
    for id,val in passwords
      pw=val[:password]
      pws.push(pw)
      mark=val[:active] ? '> ' : '    '
      marks[pw]={
        'mark': mark,
        'id': id
      }
    end
    retval=[
      '[Exit]',
      '[Add password]'
    ]
    markedIds={}
    orderedPws=pws.sort { |a,b| a <=> b }
    for pw in orderedPws
      data=marks[pw]
      line="#{data[:mark]}#{pw}"
      retval.push(line)
      markedIds[line]=data[:id]
    end
    return retval,markedIds
  end
  
  def pbGetKnownOrActivePasswords
    # knownPasswords=pbLoadKnownPasswordsFromFile()
    knownPasswords=pbLoadKnownPasswords()
    retval={}
    for pw,id in PASSWORD_HASH
      next if retval[id] # Don't repeat the check
      active=$game_switches[id] ? true : false
      known=knownPasswords[id] ? true : false
      next if !active && !known # Undiscovered password?
      retval[id]={
        'password': knownPasswords[id] || pw,
        'active': active
      }
    end
    return retval
  end
  
  # def pbGetPasswordsFilename
  #   return RTP.getSaveFileName('KnownPasswords.txt')
  # end
  # def pbLoadKnownPasswordsFromFile
  #   filename=pbGetPasswordsFilename()
  #   retval={}
  #   return retval if !safeExists?(filename)
  #   File.open(filename).each do |line|
  #     pw=line.strip().downcase()
  #     id=PASSWORD_HASH[pw]
  #     retval[id]=pw if id
  #   end
  #   return retval
  # end
  # def pbSaveKnownPasswordsToFile(passwords)
  #   filename=pbGetPasswordsFilename()
  #   File.open(filename, 'wb') { |f|
  #     for _,val in passwords
  #       f << "#{val[:password]}\n"
  #     end
  #   }
  # end

  def pbLoadKnownPasswords
    retval={}
    return retval if !$idk[:knownPasswords]
    for pw in $idk[:knownPasswords]
      id=PASSWORD_HASH[pw]
      retval[id]=pw if id
    end
    return retval
  end
  def pbUpdateKnownPasswords(passwords)
    pws=[]
    for _,val in passwords
      pws.push(val[:password])
    end
    $idk[:knownPasswords]=pws
  end
  
  def pbTogglePassword(password, isGameStart=false)
    password_string=password.downcase()
    if !isGameStart && ['fullivs'].include?(password_string) && checkPasswordActivation(password_string)
      Kernel.pbMessage(_INTL('This password cannot be disabled anymore.'))
      return false
    end
    if !isGameStart && ['randomizer', 'eeveeplease', 'eevee', 'bestgamemode', 'random', 'randomized', 'randomiser', 'randomised'].include?(password_string)
      Kernel.pbMessage(_INTL('This password cannot be entered anymore.'))
      return false
    end
    $game_switches[2037] = false
    addPassword(password_string) # Toggles the password
    if $game_switches[2037]
      # It should never actually get to this section anymore...
      Kernel.pbMessage('That is not a password.')
      return false
    end
    if !checkPasswordActivation(password_string)
      Kernel.pbMessage('Password has been disabled.')
      return true
    end
    if ['leveloffset', 'setlevel', 'flatlevel'].include?(password_string)
      params=ChooseNumberParams.new
      params.setRange(-99,99)
      params.setInitialValue(0)
      params.setNegativesAllowed(true)
      $game_variables[764]=Kernel.pbMessageChooseNumber('Select the offset amount.',params)
    elsif ['percentlevel', 'levelpercent'].include?(password_string)
      params=ChooseNumberParams.new
      params.setRange(0,999)
      params.setInitialValue(100)
      $game_variables[771]=Kernel.pbMessageChooseNumber('Select the percentage adjustment.',params)
    end
    Kernel.pbMessage('Password has been enabled.')
    pbMonoRandEvents if GAMETITLE == 'Pokemon Reborn'
    return true
  end
  
  def aChangeNature(pkmn) #thanks waynolt
    aNatureChoices = [_INTL("Attack"),_INTL("Defense"),_INTL("Sp.Atk"),_INTL("Sp.Def"),_INTL("Speed"),_INTL("Cancel")] 
    aNatIDs = [0, 1, 3, 4, 2, -1]
    
    aNatImp = Kernel.pbMessage(_INTL("What could we improve on?"),aNatureChoices,6)
    if (aNatImp >= 0) && (aNatImp < 5)
        aNatRed = Kernel.pbMessage(_INTL("What can we let go of?"),aNatureChoices,6)
        
        if (aNatRed >= 0) && (aNatRed < 5)
            pkmn.setNature((aNatIDs[aNatImp]*5)+aNatIDs[aNatRed])
            pkmn.calcStats
            #$PokemonBag.pbDeleteItem(PBItems::HEARTSCALE,2)
            return true
        end
    end
    return false
  end
  
  def teamWhatPieces(doublebattle)
    party = $Trainer.party
    pkmnparty = party.find_all {|mon| !mon.nil? && !mon.isEgg? }
    pkmnparty.each {|pkmn| pkmn.piece = nil}
    # Queen
    pkmnparty.last.piece = :QUEEN
    # Pawn
    sendoutorder = pkmnparty.find_all {|mon| mon.hp > 0}
    sendoutorder[0].piece = :PAWN if sendoutorder[0].piece.nil?
    sendoutorder[1].piece = :PAWN if sendoutorder[1] && doublebattle &&  sendoutorder[1].piece.nil? 
    # King
    king_piece = pkmnparty.sort_by { |mon| [mon.piece.nil? ? 0 : 1, mon.item==PBItems::KINGSROCK ? 0 : 1, mon.totalhp] }.first
    king_piece.piece = :KING if king_piece && king_piece.piece.nil?
  
    pkmnparty.each do |pkmn|
      next if pkmn.piece != nil
      pkmn.piece = :KNIGHT if [pkmn.speed,pkmn.attack,pkmn.spatk,pkmn.defense,pkmn.spdef].max == pkmn.speed
      pkmn.piece = :BISHOP if [pkmn.speed,pkmn.attack,pkmn.spatk,pkmn.defense,pkmn.spdef].max == [pkmn.attack,pkmn.spatk].max
      pkmn.piece = :ROOK   if [pkmn.speed,pkmn.attack,pkmn.spatk,pkmn.defense,pkmn.spdef].max == [pkmn.defense,pkmn.spdef].max
    end
    namehash = {
      :QUEEN =>   "Queen",
      :PAWN =>    "Pawn",
      :KING =>    "King",
      :KNIGHT =>  "Knight",
      :BISHOP =>  "Bishop",
      :ROOK =>    "Rook"
    }
    pkmnparty.each do |pkmn|
      Kernel.pbMessage(_INTL("{1} will be a {2}.", pkmn.name, namehash[pkmn.piece]))
    end
  
  end
  
  def unhashTRlist(file="Data/trainers.dat")
    trainerlist = load_data(file)
    dehashedlist = []
    for tclass in 0...trainerlist.length
      classhash = trainerlist[tclass]
      for name in classhash.keys
        namehash = classhash[name]
        for partyid in namehash.keys
          partydata = namehash[partyid]
          dehashedlist.push([tclass,name,partydata[1],partydata[0],partyid])
        end
      end
    end
    return dehashedlist
  end
  
  def findArcEXE
    $game_switches[2121] = true
    for mon in $Trainer.party
      if mon.species == PBSpecies::ARCEUS
        $game_variables[62] = mon.name.downcase
        $game_switches[2121] = false
      end
    end
    for box in 0...$PokemonStorage.maxBoxes
      for index in 0...$PokemonStorage[box].length
        mon = $PokemonStorage[box, index]
        next if !mon
        if mon.species == PBSpecies::ARCEUS
          $game_variables[62] = mon.name.downcase
          $game_switches[2121] = false
        end
      end
    end
  end
  
  def HiddenPowerChanger(mon)
    pbHiddenPower(mon) if !mon.hptype
    oldtype=mon.hptype
    typechoices = [_INTL("Bug"),_INTL("Dark"),_INTL("Dragon"),_INTL("Electric"),_INTL("Fairy"),_INTL("Fighting"),_INTL("Fire"),_INTL("Flying"),_INTL("Ghost"),_INTL("Grass"),_INTL("Ground"),_INTL("Ice"),_INTL("Poison"),_INTL("Psychic"),_INTL("Rock"),_INTL("Steel"),_INTL("Water"),_INTL("Cancel")]
    choosetype = Kernel.pbMessage(_INTL("Which type should its move become?"),typechoices,18)
    case choosetype
      when 0 then newtype=PBTypes::BUG
      when 1 then newtype=PBTypes::DARK
      when 2 then newtype=PBTypes::DRAGON
      when 3 then newtype=PBTypes::ELECTRIC
      when 4 then newtype=PBTypes::FAIRY
      when 5 then newtype=PBTypes::FIGHTING
      when 6 then newtype=PBTypes::FIRE
      when 7 then newtype=PBTypes::FLYING
      when 8 then newtype=PBTypes::GHOST
      when 9 then newtype=PBTypes::GRASS
      when 10 then newtype=PBTypes::GROUND
      when 11 then newtype=PBTypes::ICE
      when 12 then newtype=PBTypes::POISON
      when 13 then newtype=PBTypes::PSYCHIC
      when 14 then newtype=PBTypes::ROCK
      when 15 then newtype=PBTypes::STEEL
      when 16 then newtype=PBTypes::WATER
      else newtype=-1  
    end
    if (newtype >= 0) && (newtype < 19) && newtype!=oldtype
      mon.hptype=newtype
      return true
    end
    if newtype==oldtype
      Kernel.pbMessage(_INTL("It's already that type!"))
    else
      Kernel.pbMessage(_INTL("Changed your mind?"))
    end
    return false
  end
  
  def pbMonoRandEvents
    eventarray=[] #just here to let me use a loop rather than writing the same stuff for every array
    mixpokemon=[]
    mixegg=[]
    mixonyx=[]
    dollevent=[]
    mixsnufful=[]
    mixturtmor=[]
    mixslums=[]
    mixmalchous=[]
    mixtrade=[]
    actuallypanpour=[]
    mixperidot=[]
    mixtrain=[]
    variablearray=[50,228,229,231,351,352,353,354,355,803,356,357] #Order of above, lists variable/switch to save to
    if $game_switches[1193] #Bug
      mixegg.push(17)
      mixmalchous.push(1)
    end
    if $game_switches[1197] #Dark
      mixegg.push(4,9)
      mixtrain.push(2)
    end
    if $game_switches[1196] #Dragon
      mixegg.push(7,11)
      mixturtmor.push(1)
    end
    if $game_switches[1186] #Electric
      mixpokemon.push(2)
      mixegg.push(14)
    end
    if $game_switches[1199] #Fairy
      mixegg.push(0,3,8,12)
      mixsnufful.push(0)
      mixtrade.push(1,4)
    end
    if $game_switches[1183] #Fire
      mixegg.push(10,13,17)
      actuallypanpour.push(0)
    end
    if $game_switches[1188] #Fighting
      mixegg.push(5)
      mixsnufful.push(1)
    end
    if $game_switches[1192] #Flying
      mixegg.push(3,15)
      mixslums.push(1)
      mixmalchous.push(1)
    end
    if $game_switches[1195] #Ghost
      mixegg.push(6,10)
      mixonyx.push(6)
      dollevent.push(2)
      mixmalchous.push(1)
    end
    if $game_switches[1185] #Grass
      mixegg.push(5,12)
      mixmalchous.push(2,3)
    end
    if $game_switches[1189] #Ground
      mixperidot.push(3)
      mixegg.push(11)
      dollevent.push(0,2)
    end
    if $game_switches[1187] #Ice
      mixperidot.push(3)
      mixegg.push(4,8)
      mixonyx.push(2,4)
      mixtrade.push(2)
      mixperidot.push(3)
    end
    if $game_switches[1182] #Normal
      mixpokemon.push(1)
      mixegg.push(15)
      mixsnufful.push(1)
      mixmalchous.push(2,4)
      mixtrade.push(3)
      mixperidot.push(2)
    end
    if $game_switches[1190] #Poison
      mixegg.push(1,6)
    end
    if $game_switches[1194] #Psychic
      mixperidot.push(1)
      mixegg.push(2)
      mixslums.push(2,3)
      dollevent.push(0)
      mixmalchous.push(4)
      mixtrade.push(1)
    end
    if $game_switches[1191] #Rock
      mixperidot.push(4)
      mixegg.push(16)
      mixtrade.push(4)
      mixperidot.push(4)
    end
    if $game_switches[1198] #Steel
      mixperidot.push(4)
      mixegg.push(9)
      mixslums.push(3)
    end
    if $game_switches[1184] #Water
      mixegg.push(0,1,2)
      mixslums.push(1)
      actuallypanpour.push(1)
    end
    if $game_switches[:NB_Pokemon_Only] == true #woke
      mixperidot.push(1)
      mixmalchous.push(1)
      dollevent.push(0,2)
      mixslums.push(3)
      mixtrade.push(2,4)
      mixegg.push(2)
    end
    eventarray.push(mixpokemon,mixegg,mixonyx,dollevent,mixsnufful,mixturtmor,mixslums,mixmalchous,mixtrade,actuallypanpour,mixperidot,mixtrain)
    for i in 0...eventarray.length
      j=eventarray[i]
      var=variablearray[i]
      next if j.length==0
      j.uniq! #Removing multiple copies of mons if multiple passwords add them
      if j.length>1
        randevent = rand(j.length-1)
      else
        randevent=0
      end
      if i==9 #For the panpour, the only one using a switch
        if j[randevent]==0
          $game_switches[var] = false
        else
          $game_switches[var] = true
        end
      else
        $game_variables[var] = j[randevent]
      end
    end
  end
  
  def startTimer
    $timer = Time.now
  end
  
  def stopTimer
    puts Time.now - $timer
  end
  
  def animExpander
    for i in 0...$cache.animations.length
      for j in 1...$cache.animations[i].length
        for k in 0...$cache.animations[i][j].length
          if $cache.animations[i][j][k] == 0
            $cache.animations[i][j][k] = $cache.animations[i][j-1][k].clone
          end
        end
      end
    end
  end
  
  #gotta put this here so saves don't crash
  class BugContestState
  end
  
  def pbChallengerDefense(event)
    potentialTrainers = [3,14,25,11,32,18,15,27,30,24,26,19]  # Shelly Adrienn Fern, Charlotte, Lumi, Saphira, Titania, Bennett, Cal, Cain, Victoria, Heather
    trainer = rand(0...potentialTrainers.length)
    $game_variables[29] = potentialTrainers[trainer]
    teams = themeTeamArray
    chosen_team = teams.sample
    $game_variables[600] = chosen_team[:teamnumber]
    $game_variables[601] = chosen_team[:trainer]
    case $game_variables[601]
      when "Fern"
        $game_variables[602] = 229
        $game_variables[604] = "Buck up and get your game face on! I've made it this far, so I don't want anything less than your best!"
        $game_variables[603] = "Hah! You did all right this time, but you better not get comfy!"
        $game_variables[608] = "I'll see you around. The top dog? Doesn't stay down long."
      when "Shelly"
        $game_variables[602] = 101
        $game_variables[604] = "I finally made it! You, and my brother, and everyone else... I'm gonna prove how strong I can be now!"
        $game_variables[603] = "Ahah... That's okay! Next time, your title is as good as mine!"
        $game_variables[608] = "Hey, take care of yourself, okay? I can't have you losing before I beat you!"
      when "Adrienn"
        $game_variables[602] = 111
        $game_variables[604] = "Okay, Champion! You're in your palace at the Hall of Champions! Show me the true spirit of Reborn's Champion!"
        $game_variables[603] = "There it is! The Champion keeps the throne another day!"
        $game_variables[608] = "It's good to see that the future is in good hands. I look forward to being a part of it alongside you~"
      when "Charlotte"
        $game_variables[602] = 48
        $game_variables[604] = "Hey, thought you could use help warming this place up. What do you say, wanna redecorate?"
        $game_variables[603] = "Boo."
        $game_variables[608] = "I guess you've got it handled. Maybe I'll come back around sometime."
      when "Lumi"
        $game_variables[602] = 138
        $game_variables[604] = "Hey, bet you never thought you'd see me here! I've got a lot of lost time to make up for, so I'm gonna do my best!"
        $game_variables[603] = "I'm so excited I could make it this far!"
        $game_variables[608] = "I can come back, right? You'd better be ready for me next time!"
      when "Saphira"
        $game_variables[602] = 140
        $game_variables[604] = "It was probably inevitable that we'd find ourselves here. Let's make sure you haven't gone soft."
        $game_variables[603] = "Good. That's a performance to be proud of."
        $game_variables[608] = "I'll be back next time I drop in on my sister. Stay sharp."
      when "Titania"
        $game_variables[602] = 119
        $game_variables[604] = "Surprise."
        $game_variables[603] = "Not bad. I can live with this."
        $game_variables[608] = "Well, that's enough of a distraction. I have work to get back to."
      when "Bennett"
        $game_variables[602] = 192
        $game_variables[604] = "Hello again, Champion. I know we just fought... but I've got something different I'd like to try."
        $game_variables[603] = "So that's how it meassures up then."
        $game_variables[608] = "It feels good to be keenly aware of my standing. Thank you for the extra time."
      when "Cal"
        $game_variables[602] = 54
        $game_variables[604] = "It's surreal to see you here. Surreal to be here. How about it, then?"
        $game_variables[603] = "Hah. Fair enough. Good show."
        $game_variables[608] = "Expect me back some day. Self improvement isn't something one can just stop working at."
      when "Cain"
        $game_variables[602] = 83
        $game_variables[604] = "Heyyyyy Champ, thought you might be bored!"
        $game_variables[603] = "Awwhhh, are you done with me already?"
        $game_variables[608] = "Okayyyy, maybe I'll drop in again sometime. Try not to miss me too much?"
      when "Victoria"
        $game_variables[602] = 125
        $game_variables[604] = "Hello, Champion! I'm here for a routine inspection for the sake of the League... And by that I mean, put 'em up!"
        $game_variables[603] = "It's good to do this on our own terms! Just like so long ago, right?"
        $game_variables[608] = "To be honest, I just wanted an excuse to get out of the office. You won't mind if I come back around, right?"
      when "Heather"
        $game_variables[602] = 145
        $game_variables[604] = "Hey! You already beat me once, but I got bored since then so you better be ready for take-off time 2!"
        $game_variables[603] = "Awwhh, after I already swept all of the other E4, too?"
        $game_variables[608] = "Seriously, they should just put me as the last one already. Anyway, good game! Next time you're mine though!!!"
    end
    pbChallengerDefenseGraphic(event,$game_variables[602])
  end
  
  def pbChallengerDefenseGraphic(event,trainerId)
    trchararray = [0, 0, 122, 19, 4, 56, 6, 7, 34, 0, 121, 0, 0, 0, 0, 0, 16, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 0, 110, 0, 0, 2, 0, 125, 0, 37, 119, 0, 126, 123, 124, 0, 0, 0, 131, 130, 0, 203, 0, 0, 0, 0, 0, 120, 44, 0, 0, 0, 0, 48, 181, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 140, 0, 141, 0, 143, 0, 0, 0, 0, 8, 39, 9, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 148, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 144, 0, 0, 0, 204, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "166b", "167b", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 185, 186, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    # i cant be arsed to count out these 0's so im just gonna update a few entries manually, i'm sorry to everyone for my crimes
      trchararray[229] = 29 #fern
      trchararray[101] = 68 #shelly
      trchararray[111] = 107 #adrienn
      trchararray[48] = 85 #charlotte
      trchararray[138] = 150 #lumi
      trchararray[140] = 76 #saphira
      trchararray[119] = 88 #titania
      trchararray[192] = "095b" #bennett
      trchararray[54] = "090b" #cal
      trchararray[83] = 23 #cain
      trchararray[125] = 18 #victoria
      trchararray[145] = 72 #heather
    filenum = trchararray[trainerId]
    filenum = 0 if filenum == nil
    filenum = filenum.to_s
    if filenum.length == 1
      filename = "trchar00" + filenum
    elsif filenum.length == 2
      filename = "trchar0" + filenum
    elsif filenum.length > 2
      filename = "trchar" + filenum
    end
    #case nextTrainer
     # when "Biggles" then filename = "pkmn_garbodor"
    #end
    begin
      bitmap=AnimatedBitmap.new("Graphics/Characters/"+filename)
      bitmap.dispose
      event.character_name=filename
    rescue
      event.character_name="Red"
    end
  end
  
  # pbVictoryRoadPuzzle(0)
  def pbVictoryRoadPuzzle(number)
    clues = [
      # 3
      [
        "1. No two crystals share any same quality.",
        "2. The Hardness of Ruby is 7.",
        "3. Ruby is larger than Amethyst, but it is not the",
        "    largest.",
        "4. Amethyst's Purity is 'Middling.",
        "5. The 'Pure' gem is Medium-sized.",
        "6. Emerald is less pure than Ruby, but more pure",
        "    than Sapphire.",
        "7. The smallest gem is also the softest.",
        "8. Sapphire's Hardness is less than Emerald's",
        "    Hardness.",
        "9. The largest gem is the least pure."
      ],
      # 4
      [
        "1. No two crystals share any same quality.",
        "2. The second hardest gem is 'Pure'.",
        "3. Ruby has more Foliation than, and is larger than",
        "    Sapphire.",
        "4. Sapphire is more pure than Amethyst.",
        "5. The third hardest gem is of 'Middling' Purity.",
        "6. Neither Emerald nor Amethyst is either the least",
        "    or most pure.",
        "7. The hardest gem has the most Foliation.",
        "8. Sapphire has less Foliation than the 'Pure' gem,",
        "    which has less Foliation than Amethyst.",
        "9. The softest gem is the smallest one.",
        "10. Emerald is smaller than Ruby, which is smaller", 
        "     than Amethyst."
      ],
      # 5
      [
        "1. No two crystals share any same quality.",
        "2. Ruby is bigger than Sapphire.",
        "3. Sapphire's Purity is less than Ruby's Purity,",
        "    which is less than Amethyst's Purity.",
        "4. Amethyst does not have 'Vitreous' Luster.",
        "5. Ruby is more lustrous than Amethyst, which is",
        "    more lustrous than Sapphire.",
        "6. Amethyst is not 'Miniscule'.",
        "7. Ruby has less Foliation than Sapphire.",
        "8. The largest gem is more lustrous than the",
        "    smallest gem.",
        "9. The gem with 'Difficult' Foliation is smaller than",
        "    Emerald.",
        "10. Amethyst has 'Eminent' Foliation.",
        "11. The gems are, in order of ascending hardness:",
        "     the 'Medium' gem, the 'Middling' Purity gem, the",
        "     gem with the least foliation, and the 'Pearly' gem.",
        "12. The 'Indistinct' gem is also the least pure."
      ],
      # First 6
      [
        "1. No two crystals share any same quality.",
        "2. The Habit of the second hardest gem is less than",
        "    the Habit of the 'Pure' gem, which is less than",
        "    the Habit of the Emerald.",
        "3. The Purity of the 'Vitreous' gem is less than the",
        "    Purity of Emerald, which is less than the Purity",
        "    of the 'Pearly' gem.",
        "4. The Luster of the 'Miniscule' gem is less than the",
        "    Luster of the 'Medium' gem, which is less than the",
        "    Luster of the 'Hexagonal' gem.",
        "5. The Hardness of the 'Small' gem is less than the",
        "    Hardness of the Amethyst, which is less than the",
        "    Hardness of the 'Pure' gem.",
        "6. The 'Middling' Purity gem's Luster is less than",
        "    the Luster of the 'Medium' gem.",
        "7. The Foliation of the 'Pearly' gem is less than the",
        "    Foliation of the 'Vitreous' gem, which is less",
        "    than the Foliation of the 'Silky' gem.",
        "8. The Habit of the 'Silky' gem is less than the Habit",
        "    of the most pure gem.",
        "9. The Size of the 'Impure' gem is less than the Size",
        "    of the 'Perfect' Foliation gem, which is less than",
        "    the Size of the Sapphire.",
        "10. The Foliation of Amethyst is less than the ",
        "     Foliation of the second hardest gem, which is",
        "     less than the Foliation of the Sapphire."
      ],
      # Second 6
      [
        "1. No two crystals share any same quality.",
        "2. The Purity of the 'Coxcomb' gem is less than",
        "the Purity of the 'Miniscule' gem, which is less",
        "than the Purity of the 'Vitreous' gem.",
        "3. The Hardness of the 'Eminent' gem is less than",
        "the Hardness of the 'Perfect' gem, which is less",
        "than the Hardness of the 'Cubic' gem.",
        "4. The Purity of the gem with a Hardness of 5 is less",
        "than the Purity of the gem with 'Perfect' Foliation,",
        "which is less than the Purity of the 'Pearly' gem.",
        "5. The Luster of the 'Tabular' gem is less than the",
        "Luster of the 'Cubic' gem, which is less than the",
        "Luster of the gem with 'Indistinct' Foliation.",
        "6. The Size of the 'Coxcomb' gem is less than the",
        "Size of the 'Indistinct' gem, which is less than",
        "the Size of the gem with a Hardness of 8.",
        "7. The Foliation of the 'Hexagonal' gem is less than",
        "the Foliation of the 'Large' gem, which is less than",
        "the Foliation of the gem with a Hardness of 7.",
        "8. The Habit of the 'Flawless' gem is less than the",
        "Habit of the 'Pearly' gem, which is less than the",
        "Habit of the 'Silky' gem."
      ]
    ]
    cmdwin=pbListWindow(clues[number],Graphics.width)
    cmdwin.rowHeight = 20
    cmdwin.refresh
    Graphics.update
    loop do
      Graphics.update
      Input.update
      cmdwin.update
      break if Input.trigger?(Input::C) || Input.trigger?(Input::B)
    end
    cmdwin.dispose
  end
  # pbVictoryRoadPuzzle(0)
  
  
  
  def rebornCheckRemoteVersion()
    begin
      host = 'www.rebornevo.com'     # The web server
      port = 80                           # Default HTTP port
      path = "/downloads/rebornremote/version"                 # The file we want 

      # This is the HTTP request we send to fetch a file
      request = "GET #{path} HTTP/1.0\r\n\r\n"

      Timeout::timeout(15) do
         socket = TCPSocket.open(host,port)  # Connect to server
         socket.print(request)               # Send request
         response = socket.read              # Read complete response
         # Split response at first blank line into headers and body
         headers,body = response.split("\r\n\r\n", 2) 
         remoteVer = body    
      end   
    rescue
      remoteVer = ""       
    end
    if remoteVer != ""
      remoteVer = remoteVer.to_f
      localVer = "0.1"
      f=File.open("version","rb")
      f.each_line {|line|
        localVer = line
      }
      f.close
      localVer = localVer.to_f
      if remoteVer > localVer     
        if System.platform[/Mac/]
          message = "A new update has been detected!\n\nCurrent version: #{localVer}\nNew version: #{remoteVer}\n\nPlease close the game and run the Reborn_Updater utility included with the download to fetch the new version."
        else
          message = "A new update has been detected!\n\nCurrent version: #{localVer}\nNew version: #{remoteVer}\n\nPlease close the game and run updater.exe to fetch the new version."
        end
        print message
      end
    end
  end




  ############# Export functions from Torre:

  

#Arbok @ Light Clay
#Level: 15
#Jolly Nature
#Ability: Aftermath
#EVs: 252 HP / 0 Atk / 0 Def / 0 SpA / 0 SpD / 252 Spe
#IVs: 20 HP / 20 Atk / 20 Def / 20 SpA / 20 SpD / 20 Spe
#- Reflect
#- Light Screen
#- Taunt
#- Explosion


def torselfteamtotext
  # Exports your team in a file in the game folder.
      f = File.open("Team Data - My Own Team.txt","w")
      for poke in $Trainer.party
      #If the form isn't the base form, gives a warning. Also mentions the typings to easily notice stuff like Kyurems and Necrozmas.
          if poke.form!=0
        f.write("WATCH OUT, THIS POKEMON IS NOT IN ITS BASE FORM. ITS TYPING IS #{PBTypes.getName(poke.type1)} #{PBTypes.getName(poke.type2)}\n")
      end
      f.write(PBSpecies.getName(poke.species))
          if poke.item!=0
        f.write(" @ ")
        f.write(PBItems.getName(poke.item))
          end
      f.write("\n")
      f.write("Level: ")
      f.write(poke.poklevel)
      f.write("\n")
          f.write(PBNatures.getName(poke.nature))
      f.write(" Nature\n")
      f.write("Ability: ")
          f.write(PBAbilities.getName(poke.ability))
          f.write("\n")
          f.write("EVs: #{poke.ev[0]} HP / #{poke.ev[1]} Atk / #{poke.ev[2]} Def / #{poke.ev[4]} SpA / #{poke.ev[5]} SpD / #{poke.ev[3]} Spe\n")
          f.write("IVs: #{poke.iv[0]} HP / #{poke.iv[1]} Atk / #{poke.iv[2]} Def / #{poke.iv[4]} SpA / #{poke.iv[5]} SpD / #{poke.iv[3]} Spe\n")
          for move in poke.moves
        if move.id>0
        f.write("- ")
        f.write(PBMoves.getName(move.id))
        f.write("\n")
        end
          end
          f.write("\n")
      f.write("-----------------")
          f.write("\n\n")
      end
      f.close
    
  end
  
  def torallopponentsteamtotext
  # Exports the entirety of the trainers in a trainer file
  # Opens the file
  f = File.open("Team Data - Opponents.txt","w")
  # Loops around for every single trainer in the game (1135).
    for i in 0..1135
    # Grab the trainer from the list and its data
    trainerchoice=torFakeListScreen(_INTL("SINGLE TRAINER"),TrainerBattleLister.new(0,false),i)
    trainerdata=trainerchoice[1]
    # Write down basic information about the trainer, such as the name and number of the trainer.
    f.write("Trainer Info : #{PBTrainers.getName(trainerdata[0])} -  #{trainerdata[1]} - Team #{trainerdata[4]}\n\n")
      for poke in trainerdata[3]
      # Create the actual pokemon to be exported
      opponent=PokeBattle_Trainer.new(trainerdata[1],trainerdata[0])
      species=poke[TPSPECIES]
      level=poke[TPLEVEL]
      pokegift=PokeBattle_Pokemon.new(species,level)
      pokemon=PokeBattle_Pokemon.new(species,level,opponent)
      pokemon=PokeBattle_Pokemon.new(species,level)
      pokemon.form=poke[TPFORM]
      pokemon.resetMoves
      pokemon.setItem(poke[TPITEM])
        if poke[TPMOVE1]>0 || poke[TPMOVE2]>0 || poke[TPMOVE3]>0 || poke[TPMOVE4]>0
        k=0
          for move in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
          pokemon.moves[k]=PBMove.new(poke[move])
          k+=1
          end
        end
      pokemon.setAbility(poke[TPABILITY])
      pokemon.setGender(poke[TPGENDER])
        if poke[TPSHINY]   # if this is a shiny Pokémon
        pokemon.makeShiny
        else
        pokemon.makeNotShiny
        end
      pokemon.setNature(poke[TPNATURE])
      iv=poke[TPIV]
        if iv==32
          for i in 0...6
          pokemon.iv[i]=31
          end
        pokemon.iv[3]=0
        else
          for i in 0...6
          pokemon.iv[i]=iv&0x1F
          end
        end
      evsum = poke[TPHPEV].to_i+poke[TPATKEV].to_i+poke[TPDEFEV].to_i+poke[TPSPEEV].to_i+poke[TPSPAEV].to_i+poke[TPSPDEV].to_i
        if evsum>0 
        pokemon.ev=[poke[TPHPEV].to_i,
        poke[TPATKEV].to_i,
        poke[TPDEFEV].to_i,
        poke[TPSPEEV].to_i,
        poke[TPSPAEV].to_i,
        poke[TPSPDEV].to_i]
        elsif evsum == 0
          for i in 0...6
          pokemon.ev[i]=[85,level*3/2].min
          end
        end
      pokemon.calcStats
      #Now the pokemon is created. We export it with the same method as the other one.
      #If the form isn't the base form, gives a warning. Also mentions the typings to easily notice stuff like Kyurems and Necrozmas.
        if pokemon.form!=0
        f.write("WATCH OUT, THIS POKEMON IS NOT IN ITS BASE FORM. ITS TYPING IS #{PBTypes.getName(pokemon.type1)} #{PBTypes.getName(pokemon.type2)}\n")
        end
      f.write(PBSpecies.getName(pokemon.species))
        if pokemon.item!=0
          f.write(" @ ")
          f.write(PBItems.getName(pokemon.item))
        end
      f.write("\n")
      f.write("Level: ")
      f.write(pokemon.poklevel)
      f.write("\n")
      f.write(PBNatures.getName(pokemon.nature))
      f.write(" Nature\n")
      f.write("Ability: ")
      f.write(PBAbilities.getName(pokemon.ability))
      f.write("\n")
      f.write("EVs: #{pokemon.ev[0]} HP / #{pokemon.ev[1]} Atk / #{pokemon.ev[2]} Def / #{pokemon.ev[4]} SpA / #{pokemon.ev[5]} SpD / #{pokemon.ev[3]} Spe\n")
      f.write("IVs: #{pokemon.iv[0]} HP / #{pokemon.iv[1]} Atk / #{pokemon.iv[2]} Def / #{pokemon.iv[4]} SpA / #{pokemon.iv[5]} SpD / #{pokemon.iv[3]} Spe\n")
        for move in pokemon.moves
          if move.id>0
          f.write("- ")
          f.write(PBMoves.getName(move.id))
          f.write("\n")
          end
        end
      f.write("\n")
      f.write("-----------------")
      f.write("\n\n")
      end
    end
  f.close
  end
  
  
  def torFakeListScreen(title,lister,i)
  # Code that "simulates" the opening of a debugging trainer list, and instead pre-picks the value according to i.
    viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z=99999
    list=pbListWindow([],256)
    list.viewport=viewport
    list.z=2
    title=Window_UnformattedTextPokemon.new(title)
    title.x=256
    title.y=0
    title.width=Graphics.width-256
    title.height=64
    title.viewport=viewport
    title.z=2
    lister.setViewport(viewport)
    selectedmap=-1
    commands=lister.commands
    selindex=lister.startIndex
    if commands.length==0
      value=lister.value(-1)
      lister.dispose
      return value
    end
    list.commands=commands
    list.index=selindex
    value=lister.value(i)
    lister.dispose
    title.dispose
    list.dispose
    Input.update
    return value
  end
