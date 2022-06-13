class PokemonLoadPanel < SpriteWrapper
  attr_reader :selected

  def initialize(index,title,isContinue,trainer,framecount,mapid,viewport=nil)
    super(viewport)
    @index=index
    @title=title
    @isContinue=isContinue
    @trainer=trainer
    @totalsec=(framecount || 0)/44 #Graphics.frame_rate #Because Turbo exists
    @mapid=mapid
    @selected=(index==0)
    @bgbitmap=AnimatedBitmap.new("Graphics/Pictures/loadPanels")
    @refreshBitmap=true
    @refreshing=false
    refresh
  end

  def dispose
    @bgbitmap.dispose
    self.bitmap.dispose
    super
  end

  def selected=(value)
    if @selected!=value
      @selected=value
      @refreshBitmap=true
      refresh
    end
  end

  def pbRefresh
    # Draw contents
    @refreshBitmap=true
    refresh
  end

  def refresh
    return if @refreshing
    return if disposed?
    @refreshing=true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap=BitmapWrapper.new(@bgbitmap.width,111*2)
      pbSetSystemFont(self.bitmap)
    end
    if @refreshBitmap
      @refreshBitmap=false
      self.bitmap.clear if self.bitmap
      if @isContinue
        self.bitmap.blt(0,0,@bgbitmap.bitmap,
           Rect.new(0,(@selected ? 111*2 : 0),@bgbitmap.width,111*2))
      else
        self.bitmap.blt(0,0,@bgbitmap.bitmap,
           Rect.new(0,111*2*2+(@selected ? 23*2 : 0),@bgbitmap.width,23*2))
      end
      textpos=[]
      if @isContinue
        textpos.push([@title,16*2,5*2,0,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([_INTL("Badges:"),16*2,56*2,0,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([@trainer.numbadges.to_s,103*2,56*2,1,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([_INTL("Pokédex:"),16*2,72*2,0,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([@trainer.pokedexSeen.to_s,103*2,72*2,1,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([_INTL("Time:"),16*2,88*2,0,Color.new(232,232,232),Color.new(136,136,136)])
        hour = @totalsec / 60 / 60
        min = @totalsec / 60 % 60
        if hour>0
          textpos.push([_INTL("{1}h {2}m",hour,min),103*2,88*2,1,Color.new(232,232,232),Color.new(136,136,136)])
        else
          textpos.push([_INTL("{1}m",min),103*2,88*2,1,Color.new(232,232,232),Color.new(136,136,136)])
        end
        if @trainer.isMale?
          textpos.push([@trainer.name,56*2,32*2,0,Color.new(56,160,248),Color.new(56,104,168)])
        else
          textpos.push([@trainer.name,56*2,32*2,0,Color.new(240,72,88),Color.new(160,64,64)])
        end
        mapname=pbGetMapNameFromId(@mapid)
        mapname.gsub!(/\\PN/,@trainer.name)
        textpos.push([mapname,193*2,5*2,1,Color.new(232,232,232),Color.new(136,136,136)])
      else
        textpos.push([@title,16*2,4*2,0,Color.new(232,232,232),Color.new(136,136,136)])
      end
      pbDrawTextPositions(self.bitmap,textpos)
    end
    @refreshing=false
  end
end



class PokemonLoadScene
  def pbUpdate
    oldi=@sprites["cmdwindow"].index rescue 0
    pbUpdateSpriteHash(@sprites)
    newi=@sprites["cmdwindow"].index rescue 0
    if oldi!=newi
      @sprites["panel#{oldi}"].selected=false
      @sprites["panel#{oldi}"].pbRefresh
      @sprites["panel#{newi}"].selected=true
      @sprites["panel#{newi}"].pbRefresh
      while @sprites["panel#{newi}"].y>Graphics.height-16*2-23*2-1*2
        for i in 0...@commands.length
          @sprites["panel#{i}"].y-=23*2+1*2
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y-=23*2+1*2
        end
        @sprites["player"].y-=23*2+1*2 if @sprites["player"]
      end
      while @sprites["panel#{newi}"].y<16*2
        for i in 0...@commands.length
          @sprites["panel#{i}"].y+=23*2+1*2
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y+=23*2+1*2
        end
        @sprites["player"].y+=23*2+1*2 if @sprites["player"]
      end
    end
  end

  def pbStartScene(commands,showContinue,trainer,framecount,mapid)
    @commands=commands
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99998
    @textviewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @textviewport.z=@viewport.z+1
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@textviewport)
    @sprites["overlay2"]=BitmapSprite.new(Graphics.width,Graphics.height,@textviewport)
    addBackgroundOrColoredPlane(@sprites,"background","loadbg",
       Color.new(248,248,248),@viewport)
    y=16*2
    for i in 0...commands.length
      @sprites["panel#{i}"]=PokemonLoadPanel.new(i,commands[i],
         (showContinue ? (i==0) : false),trainer,framecount,mapid,@viewport)
      @sprites["panel#{i}"].pbRefresh
      @sprites["panel#{i}"].x=24*2
      @sprites["panel#{i}"].y=y
      y+=(showContinue && i==0) ? 111*2+1*2 : 23*2+1*2
    end
    @sprites["cmdwindow"]=Window_CommandPokemon.new([])
    @sprites["cmdwindow"].x=Graphics.width
    @sprites["cmdwindow"].y=0
    @sprites["cmdwindow"].viewport=@viewport
    @sprites["cmdwindow"].visible=false
  end

  def pbStartScene2
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbMoveSprites(xoffset)
    @sprites["cmdwindow"].x-=xoffset
    @sprites["player"].x-=xoffset if @sprites["player"]
    for i in 0..5
      @sprites["party#{i}"].x-=xoffset if @sprites["party#{i}"]
    end
    for i in 0..5
      @sprites["panel#{i}"].x-=xoffset if @sprites["panel#{i}"]
    end
  end

  def pbDrawSaveCommands(savefiles)
    @savefiles=savefiles
      @sprites["overlay"].bitmap.clear
      textpos=[]
      if savefiles.length>=9
        numsavebuttons=9
      else
        numsavebuttons=savefiles.length
      end
      for i in 0...numsavebuttons
        @sprites["savefile#{i}"]=IconSprite.new(Graphics.width/2-384/2,i*45,@viewport)
        @sprites["savefile#{i}"].setBitmap("Graphics/Pictures/loadsavepanel")
        @sprites["savefile#{i}"].zoom_x=0.5
        @sprites["savefile#{i}"].zoom_y=0.5
        Graphics.update
        loop do
          @sprites["savefile#{i}"].zoom_x+=0.125
          @sprites["savefile#{i}"].zoom_y+=0.125
          Graphics.update
          break if @sprites["savefile#{i}"].zoom_x==1
        end
        if i<10
          textpos.push([savefiles[i][1],Graphics.width/2-savefiles[i][1].length*5,i*45+12,0,Color.new(255,255,255),Color.new(125,125,125)])
          pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
        end
      end
      @sprites["saveselect"]=IconSprite.new(Graphics.width/2-384/2,0,@viewport)
      @sprites["saveselect"].setBitmap("Graphics/Pictures/loadsavepanel_1")
      Graphics.update
      pbToggleSelecting
   end

   def pbRemoveSaveCommands
      @sprites["overlay"].bitmap.clear
      @index=0 if !@index
      Graphics.update

      pbDisposeSprite(@sprites,"saveselect")
      Graphics.update
      for i in 0...@savefiles.length
        pbDisposeSprite(@sprites,"savefile#{i}")
        Graphics.update
      end
   end

   def pbChooseAutoSubFile(index,arrayindex)
     if !@sprites["autosavefile"]
       @sprites["overlay"].bitmap.clear
       @sprites["newsavefile1"]=IconSprite.new(20,Graphics.height/3,@viewport)
       @sprites["newsavefile1"].setBitmap("Graphics/Pictures/loadsavepanel")
       @sprites["autosavefile"]=IconSprite.new(300,Graphics.height/3,@viewport)
       @sprites["autosavefile"].setBitmap("Graphics/Pictures/loadsavepanel")
       @sprites["saveselect"]=IconSprite.new(20,Graphics.height/3,@viewport)
       @sprites["saveselect"].setBitmap("Graphics/Pictures/loadsavepanel_1")
       @sprites["autosavefile"].zoom_x=0.5
       @sprites["newsavefile1"].zoom_x=0.5
       @sprites["newsavefile1"].zoom_y=1.5
       @sprites["autosavefile"].zoom_y=1.5
       @sprites["saveselect"].zoom_x=0.5
       @sprites["saveselect"].zoom_y=1.5
       @sprites["overlay2"].bitmap.font.size=22
       textpos=[]
       textpos.push([@savefiles[arrayindex][1],Graphics.width/2-@savefiles[arrayindex][1].length/2*10,30,0,Color.new(0,0,0),Color.new(125,125,125)])
       textpos.push(["Normal Save",55,Graphics.height/3+12,0,Color.new(255,255,255),Color.new(125,125,125)])
       textpos.push(["Autosave",350,Graphics.height/3+12,0,Color.new(255,255,255),Color.new(125,125,125)])
       textpos.push([@savefiles[arrayindex][4],30,Graphics.height/3+35,0,Color.new(255,255,255),Color.new(125,125,125)])
       textpos.push([@savefiles[arrayindex][5],315,Graphics.height/3+35,0,Color.new(255,255,255),Color.new(125,125,125)])
       pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
     end
     if index==0
       @sprites["saveselect"].x=20
     else
       @sprites["saveselect"].x=300
     end
   end

   def pbClearOverlay2
       @sprites["overlay2"].bitmap.clear
   end

   def pbDrawCurrentSaveFile(savename="",auto=nil)
       @sprites["overlay2"].bitmap.clear
       textpos=[]
       if auto==nil
         textpos.push([savename,0,0,0,Color.new(255,255,255),Color.new(125,125,125)])
       else
         textpos.push([savename+ " Auto Save",0,0,0,Color.new(255,255,255),Color.new(125,125,125)])
       end
       pbDrawTextPositions(@sprites["overlay2"].bitmap,textpos)
   end

   def pbDrawSaveText(savefiles,xoffset=0,yoffset=0)
     @sprites["overlay"].bitmap.clear
     textpos=[]
     #@savefiles=savefiles
     for i in 0...savefiles.length
       if !((i*45+12-yoffset)<0) && !((i*45+12-yoffset>9*45))
         textpos.push([savefiles[i][1],Graphics.width/2-savefiles[i][1].length*5+xoffset,i*45+12-yoffset,0,Color.new(255,255,255),Color.new(125,125,125)])
       end
     end
     pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
   end

  def pbToggleSelecting
    if @saveselecting
      @saveselecting=!@saveselecting
    else
      @saveselecting=true
    end
  end

  def pbMoveSaveSel(index)
    @index=index
    if index<=7 &&
      @sprites["saveselect"].y=index*45
      pbDrawSaveText(@savefiles)
    elsif index==@savefiles.length-1
      @sprites["saveselect"].y=7*45
      pbDrawSaveText(@savefiles,0,45*(index-7))
    else
      pbDrawSaveText(@savefiles,0,45*(index-7))
    end
    if index==(@savefiles.length-1) && @savefiles.length-1>=8
      @sprites["savefile8"].visible=false if @sprites["savefile8"]
    else
      @sprites["savefile8"].visible=true if @sprites["savefile8"]
    end
    Graphics.update
  end

  def pbStartDeleteScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99998
    addBackgroundOrColoredPlane(@sprites,"background","loadbg",
       Color.new(248,248,248),@viewport)
  end

  def pbSetParty(trainer)
    return if !trainer || !trainer.party
    meta=pbGetMetadata(0,MetadataPlayerA+trainer.metaID)
    if meta
      filename=pbGetPlayerCharset(meta,1,trainer)
      @sprites["player"]=TrainerWalkingCharSprite.new(filename,@viewport)
      charwidth=@sprites["player"].bitmap.width
      charheight=@sprites["player"].bitmap.height
      @sprites["player"].x = 56*2 - charwidth/8
      @sprites["player"].y = 56*2 - charheight/8
      @sprites["player"].src_rect = Rect.new(0,0,charwidth/4,charheight/4)
    end
    for i in 0...trainer.party.length
      @sprites["party#{i}"]=PokemonIconSprite.new(trainer.party[i],@viewport)
      @sprites["party#{i}"].z=99999
      @sprites["party#{i}"].x=151*2+33*2*(i&1)
      @sprites["party#{i}"].y=36*2+25*2*(i/2)
    end
  end

  def pbChoose(commands)
    @sprites["cmdwindow"].commands=commands
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::C) && (!@saveselecting || @saveselecting==false)
        return @sprites["cmdwindow"].index
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) #{ pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @commands=nil
    @textviewport.dispose
  end

  def pbCloseScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonLoad
  def initialize(scene)
    @scene=scene
  end

  def pbTryLoadFile(savefile)
    trainer=nil
    framecount=nil
    game_system=nil
    pokemonSystem=nil
    mapid=nil
    File.open(savefile){|f|
       trainer=Marshal.load(f)
       framecount=Marshal.load(f)
       game_system=Marshal.load(f)
       pokemonSystem=Marshal.load(f)
       mapid=Marshal.load(f)
    }
    raise "Corrupted file" if !trainer.is_a?(PokeBattle_Trainer)
    raise "Corrupted file" if !framecount.is_a?(Numeric)
    raise "Corrupted file" if !game_system.is_a?(Game_System)
    raise "Corrupted file" if !pokemonSystem.is_a?(PokemonSystem)
    raise "Corrupted file" if !mapid.is_a?(Numeric)
    return [trainer,framecount,game_system,pokemonSystem,mapid]
  end

  def pbStartDeleteScreen
    savefile=RTP.getSaveFileName("Game.rxdata")
    @scene.pbStartDeleteScene
    @scene.pbStartScene2
    if safeExists?(savefile)
      if Kernel.pbConfirmMessageSerious(_INTL("Delete all saved data?"))
        Kernel.pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
        if Kernel.pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
          Kernel.pbMessage(_INTL("Deleting all data.\r\nDon't turn off the power.\\wtnp[0]"))
          begin; File.delete(savefile); rescue; end
          begin; File.delete(savefile+".bak"); rescue; end
          Kernel.pbMessage(_INTL("The save file was deleted."))
        end
      end
    else
      Kernel.pbMessage(_INTL("No save file was found."))
    end
    @scene.pbEndScene
    $scene=pbCallTitle
  end


  def pbStartLoadScreen(savenum=0,auto=nil,savename="Save Slot 1")
    $pkmn_animations = load_data_anim("Data/PkmnAnimations.rxdata") if !$pkmn_animations
    $PokemonTemp   = PokemonTemp.new
    $game_temp     = Game_Temp.new
    $game_system   = Game_System.new
    $PokemonSystem = PokemonSystem.new if !$PokemonSystem
    cmdContinue    = -1
    cmdNewGame     = -1
    cmdSaveDir     = -1
    cmdChooseSaveFile = -1
    cmdOption      = -1
    cmdLanguage    = -1
    cmdMysteryGift = -1
    cmdQuit        = -1
    cmdDeleteSaveFile = -1
    commands       = []
    savedir = RTP.getSaveFileName("Game.rxdata")
    savefolder = savedir[0..savedir.size-12]
    latestsavefile = savefolder + "latest_save.txt"
    if safeExists?(latestsavefile)
      savefileName = File.open(latestsavefile) {|f| f.readline}
      savenum = savefileName.to_i
      if savenum >= 2
        savename = "Save Slot " + savenum.to_s
      end
    end

    if auto != nil
      if savenum==0 || savenum==1
        savefile=RTP.getSaveFileName("Game_autosave.rxdata")
      else
        savefile = RTP.getSaveFileName("Game_"+savenum.to_s+"_autosave.rxdata")
      end
    elsif savenum==0 || savenum==1
      savefile=RTP.getSaveFileName("Game.rxdata")
    else
      savefile = RTP.getSaveFileName("Game_"+savenum.to_s+".rxdata")
    end
    #savefile = RTP.getSaveFileName("Game.rxdata")
    FontInstaller.install if !$MKXP
    data_system = pbLoadRxData("Data/System")
    mapfile=$RPGVX ? sprintf("Data/Map%03d.rvdata",data_system.start_map_id) :
                     sprintf("Data/Map%03d.rxdata",data_system.start_map_id)
    if data_system.start_map_id==0 || !pbRgssExists?(mapfile)
      Kernel.pbMessage(_INTL("No starting position was set in the map editor.\1"))
      Kernel.pbMessage(_INTL("The game cannot continue."))
      @scene.pbEndScene
      $scene=nil
      return
    end
    if safeExists?(savefile)
      trainer=nil
      #success = false
      framecount=0
      mapid=0
      showContinue=false
      haveBackup=false
      begin
        trainer, framecount, $game_system, $PokemonSystem, mapid=pbTryLoadFile(savefile)
        showContinue=true
      rescue
#        while !success
        if safeExists?(RTP.getSaveFileName(trainer.lastSave))
          begin
            trainer, framecount, $game_system, $PokemonSystem, mapid=pbTryLoadFile(savefile+".bak")
            haveBackup  = true
            showContinue= true
          rescue
          end
        end
        if haveBackup
          Kernel.pbMessage(_INTL("The save file is corrupt.  The previous save file will be loaded."))
        else
          Kernel.pbMessage(_INTL("The save file is corrupt, or is incompatible with this game."))
          if !Kernel.pbConfirmMessageSerious(_INTL("Do you want to delete the save file and start anew?"))
            raise "scss error - Corrupted or incompatible save file."
          end
          begin; File.delete(savefile); rescue; end
          begin; File.delete(savefile+".bak"); rescue; end
          $game_system=Game_System.new
          $PokemonSystem=PokemonSystem.new if !$PokemonSystem
          Kernel.pbMessage(_INTL("The save file was deleted."))
        end
      end
      if showContinue
        if !haveBackup
          begin; File.delete(savefile+".bak"); rescue; end
        end
      end
      commands[cmdContinue=commands.length]=_INTL("Continue") if showContinue
      commands[cmdNewGame=commands.length]=_INTL("New Game")
      commands[cmdChooseSaveFile=commands.length]=_INTL("Other Save Files")
      commands[cmdDeleteSaveFile=commands.length]=_INTL("Delete This Save File")
      commands[cmdMysteryGift=commands.length]=_INTL("Mystery Gift") if (trainer.mysterygiftaccess rescue false)
      commands[cmdOption=commands.length]=_INTL("Options")
      commands[cmdSaveDir=commands.length]=_INTL("Open Save Folder")
    else
      commands[cmdNewGame=commands.length]=_INTL("New Game")
      commands[cmdChooseSaveFile=commands.length]=_INTL("Other Save Files")
      commands[cmdOption=commands.length]=_INTL("Options")
      commands[cmdSaveDir=commands.length]=_INTL("Open Save Folder")
    end
    if LANGUAGES.length>=2
      commands[cmdLanguage=commands.length]=_INTL("Language")
    end
    #commands[cmdQuit=commands.length]=_INTL("Quit Game")
    @scene.pbStartScene(commands,showContinue,trainer,framecount,mapid)
    @scene.pbSetParty(trainer) if showContinue
    @scene.pbStartScene2
    @scene.pbDrawCurrentSaveFile(savename,auto)
    loop do
      command=@scene.pbChoose(commands)
      deleting=false
      if cmdDeleteSaveFile>=0 && command==cmdDeleteSaveFile
        if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to delete this save file?"))
          if Kernel.pbConfirmMessageSerious(_INTL("All data will be lost.  Confirm once more to proceed."))
            begin; File.delete(savefile); rescue; end
            begin; File.delete(savefile+".bak"); rescue; end
            deleting=true
            @scene.pbClearOverlay2
            @scene.pbEndScene
            return
            pbSetUpSystem(0,nil)
            scene=PokemonLoadScene.new
            screen=PokemonLoad.new(scene)
            screen.pbStartLoadScreen(0,nil)
          end
        end
        redo if deleting==false
      elsif cmdContinue>=0 && command==cmdContinue
        unless safeExists?(savefile)
          pbPlayBuzzerSE()
          next
        end
        @scene.pbEndScene
        metadata = nil
        File.open(savefile){|f|
          Marshal.load(f) # Trainer already loaded
          $Trainer             = trainer
          Graphics.frame_count = Marshal.load(f)
          $game_system         = Marshal.load(f)
          Marshal.load(f) # PokemonSystem already loaded
          Marshal.load(f) # Current map id no longer needed
          $game_switches       = Marshal.load(f)
          $game_variables      = Marshal.load(f)
          $game_self_switches  = Marshal.load(f)
          $game_screen         = Marshal.load(f)
          $MapFactory          = Marshal.load(f)
          $game_map            = $MapFactory.map
          $game_player         = Marshal.load(f)
          $PokemonGlobal       = Marshal.load(f)
          metadata             = Marshal.load(f)
          $ItemData            = load_data("Data/pokmanitems.rxdata")
          $PokemonBag          = Marshal.load(f)
          $PokemonStorage      = Marshal.load(f)
          $achievements        = Marshal.load(f)
          #$initialquestion        = Marshal.load(f)
          $strengthUsed        = false
          Achievements.fixAchievements
          #Input.output_put
          xsave = savefile[0..savefile.size-8]
          slot = xsave.split("_")[-1]
          if slot.to_i.to_s == slot
            $game_variables[542] = slot.to_i
          else
            $game_variables[542] = 0
          end
          for i in $Trainer.party
            i.obhp=0
            i.obatk=0
            i.obdef=0
            i.obspe=0
            i.obspa=0
            i.obspd=0
            i.calcStats
            #DemICE>>
            moveslist=pbGetCompatibleMoves(i)
            for j in 0...4
              if i.moves[j].id==732  && !moveslist.include?(i.moves[j].id)
                pbDeleteMoveByID(i,i.moves[j].id)
              end
            end
            #>>DemICE
          end
          for x in 0...$PokemonStorage.maxBoxes
            for y in 0...$PokemonStorage.maxPokemon(x)
              if $PokemonStorage[x,y]
                i=$PokemonStorage[x,y]
                i.obhp=0
                i.obatk=0
                i.obdef=0
                i.obspe=0
                i.obspa=0
                i.obspd=0
                i.calcStats
                #DemICE>>
                moveslist=pbGetCompatibleMoves(i)
                for j in 0...4
                  if i.moves[j].id==732  && !moveslist.include?(i.moves[j].id)
                    pbDeleteMoveByID(i,i.moves[j].id)
                  end
                end
                #>>DemICE
              end
            end
          end
          if $Trainer.initialquestion.nil?
            if $game_switches[1409]==false
              if $game_variables[200]==2
                Kernel.pbMessage(_INTL("Some specific settings seem to be disabled on this savefile. These include Set Mode and Bag Item Ban for both sides, among others."))
                askmessage=_INTL("Would you like to enable them?")
                if Kernel.pbConfirmMessage(askmessage)
                  $game_switches[1409]=true
                  $PokemonSystem.battlestyle=1
                else
                  $game_switches[1409]=false
                  $PokemonSystem.battlestyle=0
                end
                $Trainer.initialquestion=true
              end
            end
          end
          magicNumberMatches=false
          if $data_system.respond_to?("magic_number")
            magicNumberMatches=($game_system.magic_number==$data_system.magic_number)
          else
            magicNumberMatches=($game_system.magic_number==$data_system.version_id)
          end
          if !magicNumberMatches || $PokemonGlobal.safesave
            if pbMapInterpreterRunning?
              pbMapInterpreter.setup(nil,0)
            end
            begin
              $MapFactory.setup($game_map.map_id) # calls setMapChanged
            rescue Errno::ENOENT
              if $DEBUG
                Kernel.pbMessage(_INTL("Map {1} was not found.",$game_map.map_id))
                map = pbWarpToMap()
                if map
                  $MapFactory.setup(map[0])
                  $game_player.moveto(map[1],map[2])
                else
                  $game_map=nil
                  $scene=nil
                  return
                end
              else
                $game_map=nil
                $scene=nil
                Kernel.pbMessage(_INTL("The map was not found. The game cannot continue."))
              end
            end
            $game_player.center($game_player.x, $game_player.y)
          else
            $MapFactory.setMapChanged($game_map.map_id)
          end
        }
        if !$game_map.events # Map wasn't set up
          $game_map=nil
          $scene=nil
          Kernel.pbMessage(_INTL("The map is corrupt. The game cannot continue."))
          return
        end
        $PokemonMap=metadata
        $PokemonEncounters=PokemonEncounters.new
        $PokemonEncounters.setup($game_map.map_id)
        pbAutoplayOnSave
        $game_map.update
        auto=(auto==nil)?false:auto
        pbStoredLastPlayed($game_variables[542],auto)
        $scene = Scene_Map.new
        return
      elsif cmdNewGame>=0 && command==cmdNewGame
        @scene.pbEndScene
        if $game_map && $game_map.events
          for event in $game_map.events.values
            event.clear_starting
          end
        end
        $game_temp.common_event_id=0 if $game_temp
        $scene               = Scene_Map.new
        Graphics.frame_count = 0
        $game_system         = Game_System.new
        $game_switches       = Game_Switches.new
        $game_variables      = Game_Variables.new
        $game_self_switches  = Game_SelfSwitches.new
        $game_screen         = Game_Screen.new
        $game_player         = Game_Player.new
        $ItemData            = load_data("Data/pokmanitems.rxdata")
        $PokemonMap          = PokemonMapMetadata.new
        $PokemonGlobal       = PokemonGlobalMetadata.new
        $PokemonStorage      = PokemonStorage.new
        $PokemonEncounters   = PokemonEncounters.new
        $strengthUsed        = false
        Achievements.resetAchievements
        $PokemonTemp.begunNewGame=true
        $data_system         = pbLoadRxData("Data/System")
        $MapFactory          = PokemonMapFactory.new($data_system.start_map_id) # calls setMapChanged
        $game_player.moveto($data_system.start_x, $data_system.start_y)
        $game_player.refresh
        $game_map.autoplay
        $game_map.update
        #Input.output_put
        #find next available slot
        checksave=RTP.getSaveFileName("Game.rxdata")
        if !safeExists?(checksave)
          $game_variables[542]=0
        else
          j=2
          loop do
            checksave=RTP.getSaveFileName("Game_"+j.to_s+".rxdata")
            if !safeExists?(checksave)
              $game_variables[542]=j
              break
            end
            j+=1
          end
        end
        auto=(auto==nil)?false:auto
        pbStoredLastPlayed($game_variables[542],auto)
        return
      elsif cmdMysteryGift>=0 && command==cmdMysteryGift
        pbFadeOutIn(99999){
           trainer=pbDownloadMysteryGift(trainer)
        }
      elsif cmdChooseSaveFile>=0 &&  command==cmdChooseSaveFile
        cancelled=false
        saveslots=[]
        newsavecheck=RTP.getSaveFileName("Game.rxdata")  #load first save file outside the loop, since a save number isn't involved
        newautosavecheck=RTP.getSaveFileName("Game_autosave.rxdata")
        if safeExists?(newsavecheck)
          hasauto=(safeExists?(newautosavecheck))?true:false
          if hasauto==true
              t=File.mtime(newautosavecheck) rescue pbGetTimeNow
              autosavetime=t.strftime("%c")
            else
              autosavetime=""
          end
          t=File.mtime(newsavecheck) rescue pbGetTimeNow
          savetime=t.strftime("%c")
          info = saveinfo(newsavecheck)
          slotname = "Save Slot 1 " + info
          saveslots.push([1,slotname,hasauto,true,savetime,autosavetime])
        elsif safeExists?(newautosavecheck)
          t=File.mtime(newautosavecheck) rescue pbGetTimeNow
          autosavetime=t.strftime("%c")
          savetime=""
          info = saveinfo(newsavecheck)
          slotname = "Save Slot 1" + info
          saveslots.push([1,slotname,true,false,savetime,autosavetime])
        end
        i=2
        loop do
          newsavecheck=RTP.getSaveFileName("Game_"+i.to_s+".rxdata")
          newautosavecheck=RTP.getSaveFileName("Game_"+i.to_s+"_autosave.rxdata")
          if safeExists?(newsavecheck)
            t=File.mtime(newsavecheck) rescue pbGetTimeNow
            savetime=t.strftime("%c")
            hasauto=(safeExists?(newautosavecheck))?true:false
            if hasauto==true
              t=File.mtime(newautosavecheck) rescue pbGetTimeNow
              autosavetime=t.strftime("%c")
            else
              autosavetime=""
            end
            info = saveinfo(newsavecheck)
            slotname = "Save Slot #{i}" + info
            saveslots.push([i,slotname,hasauto,true,savetime,autosavetime])
            #Kernel.pbMessage(_INTL("{1}",saveslots))
          elsif  safeExists?(newautosavecheck)
            t=File.mtime(newautosavecheck) rescue pbGetTimeNow
            savetime=""
            autosavetime=t.strftime("%c")
            info = saveinfo(newsavecheck)
            slotname = "Save Slot #{i}" + info
            saveslots.push([i,slotname,true,false,savetime,autosavetime])
          else  #don't break quite yet, in case save file in middle was removed
             newi=(i+1)
             newsavecheck=RTP.getSaveFileName("Game_"+newi.to_s+".rxdata")
             newautosavecheck=RTP.getSaveFileName("Game_"+newi.to_s+"_autosave.rxdata")
             if safeExists?(newsavecheck)
                i=newi
                t=File.mtime(newsavecheck) rescue pbGetTimeNow
                savetime=t.strftime("%c")
                hasauto=(safeExists?(newautosavecheck))?true:false
                if hasauto==true
                  t=File.mtime(newautosavecheck) rescue pbGetTimeNow
                  autosavetime=t.strftime("%c")
                else
                  autosavetime=""
                end
                info = saveinfo(newsavecheck)
                slotname = "Save Slot #{newi}" + info
                saveslots.push([newi,slotname,hasauto,true,savetime,autosavetime])
             elsif  safeExists?(newautosavecheck)
                i=newi
                t=File.mtime(newautosavecheck) rescue pbGetTimeNow
                autosavetime=t.strftime("%c")
                savetime=""
                info = saveinfo(newsavecheck)
                slotname = "Save Slot #{newi}" + info
                saveslots.push([newi,slotname,true,false,savetime,autosavetime])
             else  #give one extra slot space check
               newi+=1
               newsavecheck=RTP.getSaveFileName("Game_"+newi.to_s+".rxdata")
               newautosavecheck=RTP.getSaveFileName("Game_"+newi.to_s+"_autosave.rxdata")
               if safeExists?(newsavecheck)
                  i=newi
                  t=File.mtime(newsavecheck) rescue pbGetTimeNow
                  savetime=t.strftime("%c")
                  hasauto=(safeExists?(newautosavecheck))?true:false
                  if hasauto==true
                    t=File.mtime(newautosavecheck) rescue pbGetTimeNow
                    autosavetime=t.strftime("%c")
                  else
                    autosavetime=""
                  end
                  info = saveinfo(newsavecheck)
                  slotname = "Save Slot #{newi}" + info
                  saveslots.push([newi,slotname,hasauto,true,savetime,autosavetime])
               elsif  safeExists?(newautosavecheck)
                  i=newi
                  t=File.mtime(newautosavecheck) rescue pbGetTimeNow
                  autosavetime=t.strftime("%c")
                  savetime=""
                  info = saveinfo(newsavecheck)
                  slotname = "Save Slot #{newi}" + info
                  saveslots.push([newi,slotname,true,false,savetime,autosavetime])
               else
                 break
               end
             end
           end
           i+=1
         end
         if saveslots.length>=1
           for i in 1..21 #move the commands and other graphics
             @scene.pbMoveSprites(i*2)
             Graphics.update
           end
             @scene.pbDrawSaveCommands(saveslots)
             #@scene.pbDrawSaveText(saveslots)
             Graphics.update
             @selected=0
             loop do
               Input.update
               Graphics.update
               if Input.trigger?(Input::DOWN)
                 #@scene.pbToggleSelecting
                 if @selected==saveslots.length-1
                   @selected=0
                 else
                   @selected+=1
                 end
                 @scene.pbMoveSaveSel(@selected)
               elsif Input.trigger?(Input::UP)
                 if @selected==0
                   @selected=saveslots.length-1
                 else
                   @selected-=1
                 end
                 @scene.pbMoveSaveSel(@selected)
               elsif Input.trigger?(Input::PAGEUP)
                  if @selected==0
                    @selected=saveslots.length-10
                  else
                    @selected-=10
                  end
                  @scene.pbMoveSaveSel(@selected)
               elsif Input.trigger?(Input::PAGEDOWN) 
                  if @selected+10>saveslots.length-1
                    @selected=0
                  else
                    @selected+=10
                  end
                  @scene.pbMoveSaveSel(@selected)
               elsif Input.trigger?(Input::B)
                 @scene.pbRemoveSaveCommands
                 Graphics.update
                 for i in 1..21 #move the commands and other graphics
                   @scene.pbMoveSprites(i*-2)
                   Graphics.update
                 end
                 @scene.pbToggleSelecting
                 break
                elsif Input.trigger?(Input::C)
                  @scene.pbRemoveSaveCommands
                  if saveslots[@selected][2]==true && saveslots[@selected][3]==true
                     @scene.pbRemoveSaveCommands
                     Graphics.update
                     @scene.pbChooseAutoSubFile(0,@selected)
                     autoindex=0
                     loop do
                       Graphics.update
                       Input.update
                       if Input.trigger?(Input::LEFT)
                          if autoindex==0
                             autoindex=1
                             @scene.pbChooseAutoSubFile(1,@selected)
                          else
                             autoindex=0
                             @scene.pbChooseAutoSubFile(0,@selected)
                          end
                        elsif Input.trigger?(Input::RIGHT)
                          if autoindex==1
                             autoindex=0
                             @scene.pbChooseAutoSubFile(0,@selected)
                          else
                             autoindex=1
                             @scene.pbChooseAutoSubFile(1,@selected)
                          end
                        elsif Input.trigger?(Input::C)
                          break
                        end
                     end
                     auto=(autoindex==1)?true:nil
                     tempsave=saveslots[@selected][0]
                     @scene.pbEndScene
                     pbSetUpSystem(tempsave,auto)
                     scene=PokemonLoadScene.new
                     screen=PokemonLoad.new(scene)
                     screen.pbStartLoadScreen(tempsave,auto,saveslots[@selected][1])
                     return
                  elsif saveslots[@selected][2]==true
                    tempsave=saveslots[@selected][0]
                    @scene.pbEndScene
                    pbSetUpSystem(tempsave,true)
                    scene=PokemonLoadScene.new
                    screen=PokemonLoad.new(scene)
                    screen.pbStartLoadScreen(tempsave,true,saveslots[@selected][1])
                    return
                  else
                    tempsave=saveslots[@selected][0]

                    savedir = RTP.getSaveFileName("Game.rxdata")
                    savefolder = savedir[0..savedir.size-12]
                    latestsavefile = savefolder + "latest_save.txt"
                    File.open(latestsavefile, 'w') { |file| file.write(tempsave) }

                    @scene.pbEndScene
                    pbSetUpSystem(tempsave,nil)
                    scene=PokemonLoadScene.new
                    screen=PokemonLoad.new(scene)
                    screen.pbStartLoadScreen(tempsave,nil,saveslots[@selected][1])
                    return
                  end
               end
             end

          else
            Kernel.pbMessage(_INTL("You don't have any other save files"))
          end
      elsif cmdOption>=0 && command==cmdOption
        scene=PokemonOptionScene.new
        screen=PokemonOption.new(scene)
        pbFadeOutIn(99999) { screen.pbStartScreen }
      # Open save directory
      elsif cmdSaveDir>=0 && command==cmdSaveDir
        if System.platform[/Windows/]
          pathstr = ENV['USERPROFILE'] + "\\Saved Games\\Pokemon Rejuvenation\\"
          system("explorer #{pathstr}")
        elsif System.platform[/Mac/]
          pathstr = "~\\Library\\Application Support\\Pokemon Rejuvenation\\"
          system("explorer #{pathstr}")
        elsif System.platform[/Linux/]
          pathstr = "~\\.local\\share\\Pokemon Rejuvenation\\"
          system("explorer #{pathstr}")
        end
      elsif cmdLanguage>=0 && command==cmdLanguage
        @scene.pbEndScene
        $PokemonSystem.language=pbChooseLanguage
        pbLoadMessages("Data/"+LANGUAGES[$PokemonSystem.language][1])
        savedata=[]
        if safeExists?(savefile)
          File.open(savefile,"rb"){|f|
             15.times { savedata.push(Marshal.load(f)) }
          }
          savedata[3]=$PokemonSystem
          begin
            File.open(RTP.getSaveFileName("Game.rxdata"),"wb"){|f|
               15.times {|i| Marshal.dump(savedata[i],f) }
            }
          rescue; end
        end
        $scene=pbCallTitle
        return

      end
    end
    @scene.pbEndScene
    return
  end
end

def saveinfo(savefile)
  trainer, framecount, $game_system, $PokemonSystem, mapid=pbTryLoadFile(savefile)
  info = " - #{trainer.name} - #{trainer.numbadges} badges"
  return info
end

def pbGetLastPlayed
    info=[]
    counter=0
    lastsave_location = RTP.getSaveFileName("LastSave.dat")
    text=File.open(lastsave_location, 'rb')
    #text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
      line.chomp
      info.push(line) if counter<=1
      counter = counter + 1
    end
    info[0]=info[0].to_i
    info[0]+=1 if info[0]<1
    return [info[0],info[1]]
end

def pbStoredLastPlayed(savenum,auto)
  lastsave_location = RTP.getSaveFileName("LastSave.dat")
  File.open(lastsave_location, 'w'){ |file|  file.write("#{savenum}")
  file.write("\n")
  file.write("#{auto.to_s}")}
end
