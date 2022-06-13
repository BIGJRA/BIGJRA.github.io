class PokemonDataCopy
  attr_accessor :dataOldHash
  attr_accessor :dataNewHash
  attr_accessor :dataTime
  attr_accessor :data

  def crc32(x)
    return Zlib::crc32(x)
  end

  def readfile(filename)
    File.open(filename, "rb"){|f|
       f.read
    }
  end

  def writefile(str,filename)
    File.open(filename, "wb"){|f|
       f.write(str)
    }
  end

  def filetime(filename)
    File.open(filename, "r"){|f|
       f.mtime
    }
  end

  def initialize(data,datasave)
    @datafile=data
    @datasave=datasave
    @data=readfile(@datafile)
    @dataOldHash=crc32(@data)
    @dataTime=filetime(@datafile)
  end

  def changed?
    ts=readfile(@datafile)
    tsDate=filetime(@datafile)
    tsHash=crc32(ts)
    return tsHash!=@dataNewHash && tsHash!=@dataOldHash && tsDate > @dataTime
  end

  def save(newtilesets)
    newdata=Marshal.dump(newtilesets)
    if !changed?
      @data=newdata
      @dataNewHash=crc32(newdata)
      writefile(newdata,@datafile)
    else
      @dataOldHash=crc32(@data)
      @dataNewHash=crc32(newdata)
      @dataTime=filetime(@datafile)
      @data=newdata
      writefile(newdata,@datafile)
    end
    save_data(self,@datasave)
  end
end



class PokemonDataWrapper
  attr_reader :data

  def initialize(file,savefile,prompt)
    @savefile=savefile
    @file=file
    if pbRgssExists?(@savefile)
      @ts=load_data(@savefile)
      if !@ts.changed? || prompt.call==true
        @data=Marshal.load(@ts.data)
      else
        @ts=PokemonDataCopy.new(@file,@savefile)
        @data=load_data(@file)
      end
    else
      @ts=PokemonDataCopy.new(@file,@savefile)
      @data=load_data(@file)
    end
  end

  def save
    @ts.save(@data)
  end
end



def pbMapTree
  maplevels=[]
  retarray=[]
  for i in $cache.mapinfos.keys
    info=$cache.mapinfos[i]
    level=-1
    while info
      info=$cache.mapinfos[info.parent_id]
      level+=1
    end
    if level>=0
      info=$cache.mapinfos[i]
      maplevels.push([i,level,info.parent_id,info.order])
    end
  end
  maplevels.sort!{|a,b|
     next a[1]<=>b[1] if a[1]!=b[1] # level
     next a[2]<=>b[2] if a[2]!=b[2] # parent ID
     next a[3]<=>b[3] # order
  }
  stack=[]
  stack.push(0,0)
  while stack.length>0
    parent = stack[stack.length-1]
    index = stack[stack.length-2]
    if index>=maplevels.length
      stack.pop
      stack.pop
      next
    end
    maplevel=maplevels[index]
    stack[stack.length-2]+=1
    if maplevel[2]!=parent
      stack.pop
      stack.pop
      next
    end
    retarray.push([maplevel[0],$cache.mapinfos[maplevel[0]].name,maplevel[1]])
    for i in index+1...maplevels.length
      if maplevels[i][2]==maplevel[0]
        stack.push(i)
        stack.push(maplevel[0])
        break
      end
    end
  end
  return retarray
end

def pbExtractText
  msgwindow=Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
  MessageTypes.extract("intl.txt")
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("All text in the game was extracted and saved to intl.txt.\1"))
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("To localize the text for a particular language, translate every second line in the file.\1"))
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("After translating, choose \"Compile Text.\""))
  Kernel.pbDisposeMessageWindow(msgwindow)
end

def pbCompileTextUI
  msgwindow=Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
  begin
    pbCompileText
    Kernel.pbMessageDisplay(msgwindow,
       _INTL("Successfully compiled text and saved it to intl.dat."))
    Kernel.pbMessageDisplay(msgwindow,
       _INTL("To use the file in a game, place the file in the Data folder under a different name, and edit the LANGUAGES array in the Settings script."))
    rescue RuntimeError
    Kernel.pbMessageDisplay(msgwindow,
       _INTL("Failed to compile text:  {1}",$!.message))
  end
  Kernel.pbDisposeMessageWindow(msgwindow)
end



class CommandList
  def initialize
    @commandHash={}
    @commands=[]
  end

  def getCommand(index)
    for key in @commandHash.keys
      return key if @commandHash[key]==index
    end
    return nil
  end

  def add(key,value)
    @commandHash[key]=@commands.length
    @commands.push(value)
  end

  def list
    @commands.clone
  end
end



def pbDefaultMap()
  return $game_map.map_id if $game_map
  return $cache.RXsystem.edit_map_id if $cache.RXsystem
  return 0
end

def pbWarpToMap()
  if Input.pressex?(:A)
    params=ChooseNumberParams.new
    params.setRange(1,999)
    params.setInitialValue(0)
    params.setCancelValue(0)
    mapid=Kernel.pbMessageChooseNumber('To which map id do you want to warp to?',params)
  else 
    mapid=pbListScreen(_INTL("WARP TO MAP"),MapLister.new(pbDefaultMap()))
  end
  if mapid>0
    map=Game_Map.new
    map.setup(mapid)
    success=false
    x=0
    y=0
    100.times do
      x=rand(map.width)
      y=rand(map.height)
      next if !map.passableStrict?(x,y,$game_player)
      blocked=false
      for event in map.events.values
        if event.x == x && event.y == y && !event.through
          blocked=true if self != $game_player || event.character_name != ""
        end
      end
      next if blocked
      success=true
      break
    end
    if !success
      x=rand(map.width)
      y=rand(map.height)
    end
    return [mapid,x,y]
  end
  return nil
end

def pbDebugMenu
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
  commands=CommandList.new
  commands.add("switches",_INTL("Switches"))
  commands.add("variables",_INTL("Variables"))
  commands.add("refreshmap",_INTL("Refresh Map"))
  commands.add("warp",_INTL("Warp to Map (press A for map id)"))
  commands.add("healparty",_INTL("Heal Party"))
  commands.add("additem",_INTL("Add Item"))
  commands.add("clearbag",_INTL("Empty Bag"))
  commands.add("addpokemon",_INTL("Add Pokémon"))
  commands.add("teamyeet",_INTL("Export team to text"))
  commands.add("setplayer",_INTL("Set Player Character"))
  commands.add("renameplayer",_INTL("Rename Player"))
  commands.add("usepc",_INTL("Use PC"))
  commands.add("randomid",_INTL("Randomise Player's ID"))
  commands.add("changeoutfit",_INTL("Change Player Outfit"))
  commands.add("setmoney",_INTL("Set Money"))
  commands.add("setcoins",_INTL("Set Coins"))
  commands.add("setbadges",_INTL("Set Badges"))
  commands.add("toggleshoes",_INTL("Toggle Running Shoes Ownership"))
  commands.add("togglepokegear",_INTL("Toggle Pokégear Ownership"))
  commands.add("togglepokedex",_INTL("Toggle Pokédex Ownership"))
  commands.add("dexlists",_INTL("Dex List Accessibility"))
  commands.add("daycare",_INTL("Day Care Options..."))
  commands.add("quickhatch",_INTL("Quick Hatch"))
  commands.add("roamerstatus",_INTL("Roaming Pokémon Status"))
  commands.add("roam",_INTL("Advance Roaming"))
  commands.add("terraintags",_INTL("Set Terrain Tags"))
  commands.add("testwildbattle",_INTL("Test Wild Battle"))
  commands.add("testdoublewildbattle",_INTL("Test Double Wild Battle"))
  commands.add("testtrainerbattle",_INTL("Test Trainer Battle"))
  commands.add("testdoubletrainerbattle",_INTL("Test Double Trainer Battle"))
  commands.add("relicstone",_INTL("Relic Stone"))
  commands.add("purifychamber",_INTL("Purify Chamber"))
  commands.add("extracttext",_INTL("Extract Text"))
  commands.add("compiletext",_INTL("Compile Text"))
  commands.add("compiletrainers", _INTL("Compile Trainers"))
  commands.add("compiledata",_INTL("Compile All Data"))
  commands.add("mapconnections",_INTL("Map Connections"))
  commands.add("animeditor",_INTL("Animation Editor"))
  commands.add("togglelogging",_INTL("Toggle Battle Logging"))
  commands.add("debugbattle",_INTL("Battle The Debug Trainer"))
  sprites["cmdwindow"]=Window_CommandPokemon.new(commands.list)
  cmdwindow=sprites["cmdwindow"]
  cmdwindow.viewport=viewport
  cmdwindow.resizeToFit(cmdwindow.commands)
  cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.x=0
  cmdwindow.y=0
  cmdwindow.visible=true
  pbFadeInAndShow(sprites)
  ret=-1
  loop do
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        ret=-1
        break
      end
      if Input.trigger?(Input::C)
        ret=cmdwindow.index
        break
      end
    end
    break if ret==-1
    cmd=commands.getCommand(ret)
    if cmd=="switches"
      pbFadeOutIn(99999) { pbDebugScreen(0) }
    elsif cmd=="variables"
      pbFadeOutIn(99999) { pbDebugScreen(1) }
    elsif cmd=="refreshmap"
      $game_map.need_refresh = true
      Kernel.pbMessage(_INTL("The map will refresh."))
    elsif cmd=="warp"
      map=pbWarpToMap()
      if map
        pbFadeOutAndHide(sprites)
        pbDisposeSpriteHash(sprites)
        viewport.dispose
        if $scene.is_a?(Scene_Map)
          $game_temp.player_new_map_id=map[0]
          $game_temp.player_new_x=map[1]
          $game_temp.player_new_y=map[2]
          $game_temp.player_new_direction=2
          $scene.transfer_player
          $game_map.refresh
        else
          Kernel.pbCancelVehicles
          $MapFactory.setup(map[0])
          $game_player.moveto(map[1],map[2])
          $game_player.turn_down
          $game_map.update
          $game_map.autoplay
          $game_map.refresh
        end
        return
      end
    elsif cmd=="healparty"
      for i in $Trainer.party
        i.heal
      end
      Kernel.pbMessage(_INTL("Your Pokémon were healed."))
    elsif cmd=="additem"
      item=pbListScreen(_INTL("ADD ITEM"),ItemLister.new(0))
      if item && item>0
        params=ChooseNumberParams.new
        params.setRange(1,BAGMAXPERSLOT)
        params.setInitialValue(1)
        params.setCancelValue(0)
        qty=Kernel.pbMessageChooseNumber(
           _INTL("Choose the number of items."),params
        )
        if qty>0
          if qty==1
            Kernel.pbReceiveItem(item)
          else
            Kernel.pbMessage(_INTL("The item was added."))
            $PokemonBag.pbStoreItem(item,qty)
          end
        end
      end
    elsif cmd=="clearbag"
      $PokemonBag.clear
      Kernel.pbMessage(_INTL("The Bag was cleared."))
    elsif cmd=="addpokemon"
      species=pbChooseSpeciesOrdered(1)
      if species!=0
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level=Kernel.pbMessageChooseNumber(
           _INTL("Set the Pokémon's level."),params)
        if level>0
          pbAddPokemon(species,level)
        end
      end
    elsif cmd=="usepc"
      pbPokeCenterPC
    elsif cmd=="teamyeet"
      teamtotext
    elsif cmd=="setplayer"
      limit=0
      for i in 0...8
        meta=pbGetMetadata(0,MetadataPlayerA+i)
        if !meta
          limit=i
          break
        end
      end
      if limit<=1
        Kernel.pbMessage(_INTL("There is only one player defined."))
      else
        params=ChooseNumberParams.new
        params.setRange(0,23)
        params.setDefaultValue($PokemonGlobal.playerID)
        newid=Kernel.pbMessageChooseNumber(
           _INTL("Choose the new player character."),params)
        if newid!=$PokemonGlobal.playerID
          pbChangePlayer(newid)
          Kernel.pbMessage(_INTL("The player character was changed."))
        end
      end
    elsif cmd=="renameplayer"
      trname=pbEnterPlayerName("Your name?",0,12,$Trainer.name)
      if trname==""
        trainertype=pbGetPlayerTrainerType
        gender=pbGetTrainerTypeGender(trainertype) 
        trname=pbSuggestTrainerName(gender)
      end
      $Trainer.name=trname
      Kernel.pbMessage(_INTL("The player's name was changed to {1}.",$Trainer.name))
    elsif cmd=="randomid"
      $Trainer.id=rand(256)
      $Trainer.id|=rand(256)<<8
      $Trainer.id|=rand(256)<<16
      $Trainer.id|=rand(256)<<24
      Kernel.pbMessage(_INTL("The player's ID was changed to {1} (2).",$Trainer.publicID,$Trainer.id))
    elsif cmd=="changeoutfit"
      oldoutfit=$Trainer.outfit
      params=ChooseNumberParams.new
      params.setRange(0,99)
      params.setDefaultValue(oldoutfit)
      $Trainer.outfit=Kernel.pbMessageChooseNumber(_INTL("Set the player's outfit."),params)
      Kernel.pbMessage(_INTL("Player's outfit was changed.")) if $Trainer.outfit!=oldoutfit
    elsif cmd=="setmoney"
      params=ChooseNumberParams.new
      params.setMaxDigits(6)
      params.setDefaultValue($Trainer.money)
      $Trainer.money=Kernel.pbMessageChooseNumber(
         _INTL("Set the player's money."),params)
      Kernel.pbMessage(_INTL("You now have ${1}.",$Trainer.money))
    elsif cmd=="setcoins"
      params=ChooseNumberParams.new
      params.setRange(0,MAXCOINS)
      params.setDefaultValue($PokemonGlobal.coins)
      $PokemonGlobal.coins=Kernel.pbMessageChooseNumber(
         _INTL("Set the player's Coin amount."),params)
      Kernel.pbMessage(_INTL("You now have {1} Coins.",$PokemonGlobal.coins))
    elsif cmd=="setbadges"
      badgecmd=0
      loop do
        badgecmds=[]
        for i in 0...32
          badgecmds.push(_INTL("{1} Badge {2}",$Trainer.badges[i] ? "[Y]" : "[  ]",i+1))
        end
        badgecmd=Kernel.pbShowCommands(nil,badgecmds,-1,badgecmd)
        break if badgecmd<0
        $Trainer.badges[badgecmd]=!$Trainer.badges[badgecmd]
      end
    elsif cmd=="toggleshoes"
      $PokemonGlobal.runningShoes=!$PokemonGlobal.runningShoes
      Kernel.pbMessage(_INTL("Gave Running Shoes.")) if $PokemonGlobal.runningShoes
      Kernel.pbMessage(_INTL("Lost Running Shoes.")) if !$PokemonGlobal.runningShoes
    elsif cmd=="togglepokegear"
      $Trainer.pokegear=!$Trainer.pokegear
      Kernel.pbMessage(_INTL("Gave Pokégear.")) if $Trainer.pokegear
      Kernel.pbMessage(_INTL("Lost Pokégear.")) if !$Trainer.pokegear
    elsif cmd=="togglepokedex"
      $Trainer.pokedex=!$Trainer.pokedex
      Kernel.pbMessage(_INTL("Gave Pokédex.")) if $Trainer.pokedex
      Kernel.pbMessage(_INTL("Lost Pokédex.")) if !$Trainer.pokedex
    elsif cmd=="dexlists"
      dexescmd=0
      loop do
        dexescmds=[]
        d=pbDexNames
        for i in 0...d.length
          name=d[i]
          name=name[0] if name.is_a?(Array)
          dexindex=i
          unlocked=$PokemonGlobal.pokedexUnlocked[dexindex]
          dexescmds.push(_INTL("{1} {2}",unlocked ? "[Y]" : "[  ]",name))
        end
        dexescmd=Kernel.pbShowCommands(nil,dexescmds,-1,dexescmd)
        break if dexescmd<0
        dexindex=dexescmd
        if $PokemonGlobal.pokedexUnlocked[dexindex]
          pbLockDex(dexindex)
        else
          pbUnlockDex(dexindex)
        end
      end
    elsif cmd=="daycare"
      daycarecmd=0
      loop do
        daycarecmds=[
           _INTL("Summary"),
           _INTL("Deposit Pokémon"),
           _INTL("Withdraw Pokémon"),
           _INTL("Generate egg"),
           _INTL("Collect egg"),
           _INTL("Dispose egg")
        ]
        daycarecmd=Kernel.pbShowCommands(nil,daycarecmds,-1,daycarecmd)
        break if daycarecmd<0
        case daycarecmd
          when 0 # Summary
            if $PokemonGlobal.daycare
              num=pbDayCareDeposited
              Kernel.pbMessage(_INTL("{1} Pokémon are in the Day Care.",num))
              if num>0
                txt=""
                for i in 0...num
                  next if !$PokemonGlobal.daycare[i][0]
                  pkmn=$PokemonGlobal.daycare[i][0]
                  initlevel=$PokemonGlobal.daycare[i][1]
                  gender=[_INTL("♂"),_INTL("♀"),_INTL("genderless")][pkmn.gender]
                  txt+=_INTL("{1}) {2} ({3}), Lv.{4} (deposited at Lv.{5})",
                     i,pkmn.name,gender,pkmn.level,initlevel)
                  txt+="\n" if i<num-1
                end
                Kernel.pbMessage(txt)
              end
              if $PokemonGlobal.daycareEgg==1
                Kernel.pbMessage(_INTL("An egg is waiting to be picked up."))
              elsif pbDayCareDeposited==2
                if pbDayCareGetCompat==0
                  Kernel.pbMessage(_INTL("The deposited Pokémon can't breed."))
                else
                  Kernel.pbMessage(_INTL("The deposited Pokémon can breed."))
                end
              end
            end
          when 1 # Deposit Pokémon
            if pbEggGenerated?
              Kernel.pbMessage(_INTL("Egg is available, can't deposit Pokémon."))
            elsif pbDayCareDeposited==2
              Kernel.pbMessage(_INTL("Two Pokémon are deposited already."))
            elsif $Trainer.party.length==0
              Kernel.pbMessage(_INTL("Party is empty, can't desposit Pokémon."))
            else
              pbChooseNonEggPokemon(1,3)
              if pbGet(1)>=0
                pbDayCareDeposit(pbGet(1))
                Kernel.pbMessage(_INTL("Deposited {1}.",pbGet(3)))
              end
            end
          when 2 # Withdraw Pokémon
            if pbEggGenerated?
              Kernel.pbMessage(_INTL("Egg is available, can't withdraw Pokémon."))
            elsif pbDayCareDeposited==0
              Kernel.pbMessage(_INTL("No Pokémon are in the Day Care."))
            elsif $Trainer.party.length>=6
              Kernel.pbMessage(_INTL("Party is full, can't withdraw Pokémon."))
            else
              pbDayCareChoose(_INTL("Which one do you want back?"),1)
              if pbGet(1)>=0
                pbDayCareGetDeposited(pbGet(1),3,4)
                pbDayCareWithdraw(pbGet(1))
                Kernel.pbMessage(_INTL("Withdrew {1}.",pbGet(3)))
              end
            end
          when 3 # Generate egg
            if $PokemonGlobal.daycareEgg==1
              Kernel.pbMessage(_INTL("An egg is already waiting."))
            elsif pbDayCareDeposited!=2
              Kernel.pbMessage(_INTL("There aren't 2 Pokémon in the Day Care."))
            elsif pbDayCareGetCompat==0
              Kernel.pbMessage(_INTL("The Pokémon in the Day Care can't breed."))
            else
              $PokemonGlobal.daycareEgg=1
              Kernel.pbMessage(_INTL("An egg is now waiting in the Day Care."))
            end
          when 4 # Collect egg
            if $PokemonGlobal.daycareEgg!=1
              Kernel.pbMessage(_INTL("There is no egg available."))
            elsif $Trainer.party.length>=6
              Kernel.pbMessage(_INTL("Party is full, can't collect the egg."))
            else
              pbDayCareGenerateEgg
              $PokemonGlobal.daycareEgg=0
              $PokemonGlobal.daycareEggSteps=0
              Kernel.pbMessage(_INTL("Collected the {1} egg.",
                 PBSpecies.getName($Trainer.party[$Trainer.party.length-1].species)))
            end
          when 5 # Dispose egg
            if $PokemonGlobal.daycareEgg!=1
              Kernel.pbMessage(_INTL("There is no egg available."))
            else
              $PokemonGlobal.daycareEgg=0
              $PokemonGlobal.daycareEggSteps=0
              Kernel.pbMessage(_INTL("Disposed of the egg."))
            end
        end
      end
    elsif cmd=="quickhatch"
      for pokemon in $Trainer.party
        pokemon.eggsteps=1 if pokemon.isEgg?
      end
      Kernel.pbMessage(_INTL("All eggs on your party now require one step to hatch."))
    elsif cmd=="roamerstatus"
      if RoamingSpecies.length==0
        Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
      else
        text="\\l[8]"
        for i in 0...RoamingSpecies.length
          poke=RoamingSpecies[i]
          if $game_switches[poke[:switch]]
            status=$PokemonGlobal.roamPokemon[i]
            if status==true
              if $PokemonGlobal.roamPokemonCaught[i]
                text+=_INTL("{1} (Lv.{2}) caught.",
                   PBSpecies.getName(getID(PBSpecies,poke[:species])),poke[:level])
              else
                text+=_INTL("{1} (Lv.{2}) defeated.",
                   PBSpecies.getName(getID(PBSpecies,poke[:species])),poke[:level])
              end
            else
              curmap=$PokemonGlobal.roamPosition[i]
              if curmap
                $cache.mapinfos
                text+=_INTL("{1} (Lv.{2}) roaming on map {3} ({4}){5}",
                   PBSpecies.getName(getID(PBSpecies,poke[:species])),poke[:level],curmap,
                   $cache.mapinfos[curmap].name,(curmap==$game_map.map_id) ? _INTL("(this map)") : "")
              else
                text+=_INTL("{1} (Lv.{2}) roaming (map not set).",
                   PBSpecies.getName(getID(PBSpecies,poke[:species])),poke[:level])
              end
            end
          else
            text+=_INTL("{1} (Lv.{2}) not roaming (switch {3} is off).",
               PBSpecies.getName(getID(PBSpecies,poke[:species])),poke[:level],poke[:switch])
          end
          text+="\n" if i<RoamingSpecies.length-1
        end
        Kernel.pbMessage(text)
      end
    elsif cmd=="roam"
      if RoamingSpecies.length==0
        Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
      else
        pbRoamPokemon(true)
        #$PokemonGlobal.roamedAlready=false
        Kernel.pbMessage(_INTL("Pokémon have roamed."))
      end
    elsif cmd=="terraintags"
      pbFadeOutIn(99999) { pbTilesetScreen }
    elsif cmd=="testwildbattle"
      species=pbChooseSpeciesOrdered(1)
      if species!=0
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level=Kernel.pbMessageChooseNumber(
           _INTL("Set the Pokémon's level."),params)
        if level>0
          pbWildBattle(species,level)
        end
      end
    elsif cmd=="testdoublewildbattle"
      Kernel.pbMessage(_INTL("Choose the first Pokémon."))
      species1=pbChooseSpeciesOrdered(1)
      if species1!=0
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level1=Kernel.pbMessageChooseNumber(
           _INTL("Set the first Pokémon's level."),params)
        if level1>0
          Kernel.pbMessage(_INTL("Choose the second Pokémon."))
          species2=pbChooseSpeciesOrdered(1)
          if species2!=0
            params=ChooseNumberParams.new
            params.setRange(1,PBExperience::MAXLEVEL)
            params.setInitialValue(5)
            params.setCancelValue(0)
            level2=Kernel.pbMessageChooseNumber(
               _INTL("Set the second Pokémon's level."),params)
            if level2>0
              pbDoubleWildBattle(species1,level1,species2,level2)
            end
          end
        end
      end
    elsif cmd=="testtrainerbattle"
      battle=pbListScreen(_INTL("SINGLE TRAINER"),TrainerBattleLister.new(0,false))
      if battle
        trainerdata=battle[1]
        pbTrainerBattle(trainerdata[0],trainerdata[1],"...",false,trainerdata[4],true)
      end
    elsif cmd=="testdoubletrainerbattle"
      battle1=pbListScreen(_INTL("DOUBLE TRAINER 1"),TrainerBattleLister.new(0,false))
      if battle1
        battle2=pbListScreen(_INTL("DOUBLE TRAINER 2"),TrainerBattleLister.new(0,false))
        if battle2
          trainerdata1=battle1[1]
          trainerdata2=battle2[1]
          pbDoubleTrainerBattle(trainerdata1[0],trainerdata1[1],trainerdata1[4],"...",
                                trainerdata2[0],trainerdata2[1],trainerdata2[4],"...",
                                true)
        end
      end
    elsif cmd=="relicstone"
      pbRelicStone()
    elsif cmd=="purifychamber"
      pbPurifyChamber()
    elsif cmd=="extracttext"
      pbExtractText
    elsif cmd=="compiletext"
      pbCompileTextUI
    elsif cmd=="compiletrainers"
      begin
        pbCompileTrainers
        $cache.trainers=load_data("Data/trainers.dat")
        Kernel.pbMessage(_INTL("Trainers have been compiled."))
      rescue
        pbPrintException($!)
      end
    elsif cmd=="compiledata"
      msgwindow=Kernel.pbCreateMessageWindow;pbCompileAllData(true) {|msg| Kernel.pbMessageDisplay(msgwindow,msg,false) }
      Kernel.pbMessageDisplay(msgwindow,_INTL("All game data was compiled."))
      Kernel.pbDisposeMessageWindow(msgwindow)
    elsif cmd=="mapconnections"
      pbFadeOutIn(99999) { pbEditorScreen }
    elsif cmd=="animeditor"
      pbFadeOutIn(99999) { pbAnimationEditor }
    elsif cmd=="togglelogging"
      $INTERNAL=!$INTERNAL
      Kernel.pbMessage(_INTL("Debug logs for battles will be made in the Data folder.")) if $INTERNAL
      Kernel.pbMessage(_INTL("Debug logs for battles will not be made.")) if !$INTERNAL
    elsif cmd=="debugbattle"
      begin
        pbDebugTestBattle
      rescue
        pbPrintException($!)
      end
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end



class SpriteWindow_DebugRight < Window_DrawableCommand
  attr_reader :mode

  def initialize
    super(0, 0, Graphics.width, Graphics.height)
  end

  def shadowtext(x,y,w,h,t,align=0)
    width=self.contents.text_size(t).width
    if align==2
      x+=(w-width)
    elsif align==1
      x+=(w/2)-(width/2)
    end
    pbDrawShadowText(self.contents,x,y,[width,w].max,h,t,
       Color.new(12*8,12*8,12*8),Color.new(26*8,26*8,25*8))
  end

  def drawItem(index,count,rect)
    pbSetNarrowFont(self.contents)
    if @mode == 0
      name = $cache.RXsystem.switches[index+1]
      status = $game_switches[index+1] ? "[ON]" : "[OFF]"
    else
      name = $cache.RXsystem.variables[index+1]
      if !$game_variables[index+1].is_a?(Array)
        status = $game_variables[index+1].to_s
      else
        status = "(Can't display contents)"
      end
    end
    if name == nil
      name = ''
    end
    id_text = sprintf("%04d:", index+1)
    width = self.contents.text_size(id_text).width
    rect=drawCursor(index,rect)
    totalWidth=rect.width
    idWidth=totalWidth*15/100
    nameWidth=totalWidth*65/100
    statusWidth=totalWidth*20/100
    self.shadowtext(rect.x, rect.y, idWidth, rect.height, id_text)
    self.shadowtext(rect.x+idWidth, rect.y, nameWidth, rect.height, name)
    self.shadowtext(rect.x+idWidth+nameWidth, rect.y, statusWidth, rect.height, status, 2)
  end

  def itemCount
    return (@mode==0) ? $cache.RXsystem.switches.size-1 : $cache.RXsystem.variables.size-1
  end

  def mode=(mode)
    @mode = mode
    refresh
  end
end

def pbDebugSetVariable(id,diff)
  pbPlayCursorSE()
  $game_variables[id]=0 if $game_variables[id]==nil
  if $game_variables[id].is_a?(Numeric) && !$game_variables[id].is_a?(Array)
    $game_variables[id]=[$game_variables[id]+diff,99999999].min
    $game_variables[id]=[$game_variables[id],-99999999].max
  end
end

def pbDebugVariableScreen(id)
  value=0
  if $game_variables[id].is_a?(Numeric) && !$game_variables[id].is_a?(Array)
    value=$game_variables[id]
  end
  params=ChooseNumberParams.new
  params.setDefaultValue(value)
  params.setMaxDigits(8)
  params.setNegativesAllowed(true)
  value=Kernel.pbMessageChooseNumber(_INTL("Set variable {1}.",id),params)
  $game_variables[id]=[value,99999999].min
  $game_variables[id]=[$game_variables[id],-99999999].max
end

def pbDebugScreen(mode)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
  sprites["right_window"] = SpriteWindow_DebugRight.new  
  right_window=sprites["right_window"]
  right_window.mode=mode
  right_window.viewport=viewport
  right_window.active=true
  right_window.index=0
  pbFadeInAndShow(sprites)
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      break
    elsif Input.trigger?(Input::X)
      Input.text_input = true
      puts right_window.inspect
      switch = Kernel.pbMessageFreeText(_INTL("Jump to switch?"),"",false,999,500)
      if switch.to_i.to_s == switch
        switch = switch.to_i
        right_window.index = switch - 1
      else
        results = []
        if mode == 0
          for i in 1...$cache.RXsystem.switches.length
            results.push(right_window(i)) if $cache.RXsystem.switches[i].include?(switch)
          end
        elsif mode == 1
          for i in 1...$cache.RXsystem.variables.length
            results.push(right_window(i)) if $cache.RXsystem.variables[i].include?(switch)
          end
        end
        puts results
      end
      Input.text_input = false
    end
    current_id = right_window.index+1
    if mode == 0
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        $game_switches[current_id] = (!$game_switches[current_id])
        right_window.refresh
      end
    elsif mode == 1
      if Input.repeat?(Input::RIGHT)
        pbDebugSetVariable(current_id,1)
        right_window.refresh
      elsif Input.repeat?(Input::LEFT)
        pbDebugSetVariable(current_id,-1)
        right_window.refresh
      elsif Input.trigger?(Input::C)
        pbDebugVariableScreen(current_id)
        right_window.refresh
      end
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end

def pbDebugTestBattle
  #first compile the first trainer in trainers.txt
  lines=[]
  linenos=[]
  lineno=1
  #grab all relevant lines
  File.open("PBS/trainers.txt","rb"){|f|
    FileLineData.file="PBS/trainers.txt"
    f.each_line {|line|
       line=prepline(line)
       break if line=="MeteorAceM"
       if line!=""
         lines.push(line)
         linenos.push(lineno)
       end
       lineno+=1
    }
  }
  #loop through pokemon
  i=0
  FileLineData.setLine(lines[i],linenos[i])
  trainername=parseTrainer(lines[i])
  FileLineData.setLine(lines[i+1],linenos[i+1])
  nameline=strsplit(lines[i+1],/\s*,\s*/)
  name=nameline[0]
  raise _INTL("Trainer name too long\n{1}",FileLineData.linereport) if name.length>=0x10000
  partyid=0
  if nameline[1] && nameline[1]!=""
    raise _INTL("Expected a number for the trainer battle ID\n{1}",FileLineData.linereport) if !nameline[1][/^\d+$/]
    partyid=nameline[1].to_i
  end

  FileLineData.setLine(lines[i+2],linenos[i+2])
  items=strsplit(lines[i+2],/\s*,\s*/)
  items[0].gsub!(/^\s+/,"")   # Number of Pokémon
  raise _INTL("Expected a number for the number of Pokémon\n{1}",FileLineData.linereport) if !items[0][/^\d+$/]
  numpoke=items[0].to_i
  realitems=[]

  for j in 1...items.length   # Items held by Trainer
    realitems.push(parseItem(items[j])) if items[j] && items[j]!=""
  end

  opponent=PokeBattle_Trainer.new(name,trainername)
  opponent.setForeignID($Trainer) if $Trainer
  pkmn_team=[]
  for j in 0...numpoke
    FileLineData.setLine(lines[i+j+3],linenos[i+j+3])
    poke=strsplit(lines[i+j+3],/\s*,\s*/)
    # Species
    begin
      poke[TPSPECIES]=parseSpecies(poke[TPSPECIES]) 
    rescue
      raise _INTL("Expected a species name: {1}\n{2}",poke[0],FileLineData.linereport)
    end
    # Level
    poke[TPLEVEL]=poke[TPLEVEL].to_i
    raise _INTL("Bad level: {1} (must be from 1-{2})\n{3}",poke[TPLEVEL],PBExperience::MAXLEVEL,FileLineData.linereport) if poke[TPLEVEL]<=0 || poke[TPLEVEL]>PBExperience::MAXLEVEL

    # Create Pokemon
    pokemon=PokeBattle_Pokemon.new(poke[TPSPECIES],poke[TPLEVEL],opponent)
    
    # Held item
    poke[TPITEM]= (!poke[TPITEM] || poke[TPITEM]=="") ? TPDEFAULTS[TPITEM] : parseItem(poke[TPITEM])
    pokemon.setItem(poke[TPITEM])

    # Moves
    moves=[]
    for jj in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
      moves.push(parseMove(poke[jj])) if poke[jj] && poke[jj]!=""
    end
    for jj in 0...4
      index=[TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4][jj]
      poke[index]= (moves[jj] && moves[jj]!=0) ? moves[jj] : TPDEFAULTS[index]
    end
    if poke[TPMOVE1]>0 || poke[TPMOVE2]>0 || poke[TPMOVE3]>0 || poke[TPMOVE4]>0
      k=0
      for move in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
        pokemon.moves[k]=PBMove.new(poke[move])
        k+=1
      end
      pokemon.moves.compact!
    end

    # Ability
    if !poke[TPABILITY] || poke[TPABILITY]==""
      poke[TPABILITY]=TPDEFAULTS[TPABILITY]
    else
      poke[TPABILITY]=poke[TPABILITY].to_i
      raise _INTL("Bad abilityflag: {1} (must be 0 or 1 or 2-5)\n{2}",poke[TPABILITY],FileLineData.linereport) if poke[TPABILITY]<0 || poke[TPABILITY]>5
    end
    pokemon.setAbility(poke[TPABILITY])
    # Gender
    if !poke[TPGENDER] || poke[TPGENDER]==""
      poke[TPGENDER]=TPDEFAULTS[TPGENDER]
    else
      if poke[TPGENDER]=="M"
        poke[TPGENDER]=0
      elsif poke[TPGENDER]=="F"
        poke[TPGENDER]=1
      elsif poke[TPGENDER]=="U"
        poke[TPGENDER]=2
      else
        poke[TPGENDER]=poke[TPGENDER].to_i
        raise _INTL("Bad genderflag: {1} (must be M or F or U, or 0 or 1 or U)\n{2}",poke[TPGENDER],FileLineData.linereport) if poke[TPGENDER]<0 || poke[TPGENDER]>2
      end
    end
    pokemon.setGender(poke[TPGENDER])

    # Form
    if !poke[TPFORM] || poke[TPFORM]==""
      poke[TPFORM]=TPDEFAULTS[TPFORM]
    else
      poke[TPFORM]=poke[TPFORM].to_i
      raise _INTL("Bad form: {1} (must be 0 or greater)\n{2}",poke[TPFORM],FileLineData.linereport) if poke[TPFORM]<0
    end
    pokemon.form=poke[TPFORM]

    # Shiny
    if !poke[TPSHINY] || poke[TPSHINY]==""
      poke[TPSHINY]=TPDEFAULTS[TPSHINY]
    elsif poke[TPSHINY]=="shiny"
      poke[TPSHINY]=true
    else
      poke[TPSHINY]=csvBoolean!(poke[TPSHINY].clone)
    end
    if poke[TPSHINY]   # if this is a shiny Pokémon
      pokemon.makeShiny
    else
      pokemon.makeNotShiny
    end

    # Nature
    if !poke[TPNATURE] || poke[TPNATURE]==""
      poke[TPNATURE]=TPDEFAULTS[TPNATURE]
    else
      poke[TPNATURE]=parseNature(poke[TPNATURE])
    end
    pokemon.setNature(poke[TPNATURE])

    # IVs
    if !poke[TPIV] || poke[TPIV]==""
      poke[TPIV]=TPDEFAULTS[TPIV]
    else
      poke[TPIV]=poke[TPIV].to_i
      raise _INTL("Bad IV: {1} (must be from 0-31 (32 special case))\n{2}",poke[TPIV],FileLineData.linereport) if poke[TPIV]<0 || poke[TPIV]>32
    end
    iv=poke[TPIV]
    if iv==32
      for ii in 0...6
        pokemon.iv[ii]=31
      end
      pokemon.iv[3]=0
    else
      for ii in 0...6
        pokemon.iv[ii]=iv&0x1F
      end
    end

    # Happiness
    if !poke[TPHAPPINESS] || poke[TPHAPPINESS]==""
      poke[TPHAPPINESS]=TPDEFAULTS[TPHAPPINESS]
    else
      poke[TPHAPPINESS]=poke[TPHAPPINESS].to_i
      raise _INTL("Bad happiness: {1} (must be from 0-255)\n{2}",poke[TPHAPPINESS],FileLineData.linereport) if poke[TPHAPPINESS]<0 || poke[TPHAPPINESS]>255
    end
    pokemon.happiness=poke[TPHAPPINESS]

    # Nickname
    if !poke[TPNAME] || poke[TPNAME]==""
      poke[TPNAME]=TPDEFAULTS[TPNAME]
    else
      poke[TPNAME]=poke[TPNAME].to_s
      raise _INTL("Bad nickname: {1} (must be 1-20 characters)\n{2}",poke[TPNAME],FileLineData.linereport) if (poke[TPNAME].to_s).length>20
    end
    pokemon.name=poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""

    # Shadow
    if !poke[TPSHADOW] || poke[TPSHADOW]==""
      poke[TPSHADOW]=TPDEFAULTS[TPSHADOW]
    else
      poke[TPSHADOW]=csvBoolean!(poke[TPSHADOW].clone)
    end
    if poke[TPSHADOW]   # if this is a Shadow Pokémon
      pokemon.makeShadow rescue nil
      pokemon.pbUpdateShadowMoves(true) rescue nil
      pokemon.makeNotShiny
    end

    # Ball
    if !poke[TPBALL] || poke[TPBALL]==""
      poke[TPBALL]=TPDEFAULTS[TPBALL]
    else
      poke[TPBALL]=poke[TPBALL].to_i
      raise _INTL("Bad form: {1} (must be 0 or greater)\n{2}",poke[TPBALL],FileLineData.linereport) if poke[TPBALL]<0
    end
    pokemon.ballused=poke[TPBALL]
    pokemon.calcStats
    

    evsum = poke[TPHPEV].to_i+poke[TPATKEV].to_i+poke[TPDEFEV].to_i+poke[TPSPEEV].to_i+poke[TPSPAEV].to_i+poke[TPSPDEV].to_i
    #if evsum<=510 && evsum>0
    if evsum>0 # What is an EV cap? PULSE2 away tbh
            pokemon.ev=[poke[TPHPEV].to_i,
                        poke[TPATKEV].to_i,
                        poke[TPDEFEV].to_i,
                        poke[TPSPEEV].to_i,
                        poke[TPSPAEV].to_i,
                        poke[TPSPDEV].to_i]
    elsif evsum == 0
      for ii in 0...6
        pokemon.ev[ii]=[85,poke[TPLEVEL]*3/2].min
      end
    end
    pkmn_team.push(pokemon)
  end
  double_battle=!Kernel.pbConfirmMessage("Singles battle?")
  pbTrainerBattle(trainername,name,"Happy to help!",double_battle,0,true,opponent_team: pkmn_team, items_overwrite: realitems)
  #then pass that team to pbTrainerBattle with argument team lets goooooo
end


class Scene_Debug
  def main
    Graphics.transition(0)
    pbDebugMenu
    $scene=Scene_Map.new
    $game_map.refresh
    Graphics.freeze
  end
end