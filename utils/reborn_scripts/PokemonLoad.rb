class PokemonLoadPanel < SpriteWrapper
  attr_reader :selected
 
  def initialize(index,title,isContinue,trainer,framecount,mapid,viewport=nil)
    super(viewport)
    @index=index
    @title=title
    @isContinue=isContinue
    @trainer=trainer
    @totalsec=(framecount || 0)/40 #Graphics.frame_rate #Because Turbo exists
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
        textpos.push([@title,16*2,4*2,0,Color.new(232,232,232),Color.new(136,136,136)])
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
       # if @trainer.isMale?
       #   textpos.push([@trainer.name,56*2,32*2,0,Color.new(56,160,248),Color.new(56,104,168)])
       # else
        textpos.push([@trainer.name,56*2,32*2,0,Color.new(240,72,88),Color.new(160,64,64)])
       # end
        mapname=pbGetMapNameFromId(@mapid)
        mapname.gsub!(/\\PN/,@trainer.name)
        mapname2 = ""
        if mapname.length > 23
          splits = mapname.split(/ /,mapname[0,23].split(/ /).length)
          mapname2 = splits.delete_at(-1)
          mapname = splits.join(" ")
        end
        textpos.push([mapname,193*2,4*2,1,Color.new(232,232,232),Color.new(136,136,136)])
        textpos.push([mapname2,193*2,14*2,1,Color.new(232,232,232),Color.new(136,136,136)]) if mapname2 != ""
      elsif @title=="Other Save Files" && $game_switches != nil && $game_switches[:A_Fervent_Wish]
        textpos.push([@title,16*2,4*2,0,Color.new(219,203,236),Color.new(142,126,159)])
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
      while @sprites["panel#{newi}"].y>Graphics.height-80
        for i in 0...@commands.length
          @sprites["panel#{i}"].y-=48
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y-=48
        end
        @sprites["player"].y-=48 if @sprites["player"]
      end
      while @sprites["panel#{newi}"].y<32
        for i in 0...@commands.length
          @sprites["panel#{i}"].y+=48
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y+=48
        end
        @sprites["player"].y+=48 if @sprites["player"]
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
      @sprites["panel#{i}"].x=48
      @sprites["panel#{i}"].y=y
      y+=(showContinue && i==0) ? 224 : 48
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
    for i in 0..6
      @sprites["party#{i}"].x-=xoffset if @sprites["party#{i}"]
    end
    for i in 0..6
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
          if savefiles[i][1].start_with?("Anna's Wish")
            textpos.push([savefiles[i][1],Graphics.width/2-savefiles[i][1].length*5,i*45+12,0,Color.new(218,182,214),Color.new(139,131,148)])
          else
            textpos.push([savefiles[i][1],Graphics.width/2-savefiles[i][1].length*5,i*45+12,0,Color.new(255,255,255),Color.new(125,125,125)])
          end
          pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
        end  
      end
      pbDrawSaveText(savefiles)
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
      if !((i*45+12-yoffset) < 0) && !(i*45+12-yoffset > 9*45)
        if savefiles[i][1].start_with?("Anna's Wish")
          textpos.push([savefiles[i][1],Graphics.width/2-savefiles[i][1].length*5+xoffset,i*45+12-yoffset,0,Color.new(218,182,214),Color.new(139,131,148)])
        else
          textpos.push([savefiles[i][1],Graphics.width/2-savefiles[i][1].length*5+xoffset,i*45+12-yoffset,0,Color.new(255,255,255),Color.new(125,125,125)])
        end
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
      @sprites["party#{i}"].x=300+66*(i&1)
      @sprites["party#{i}"].y=72+50*(i/2)
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
 
  def pbTryLoadFile(savefile, traineronly = true)
    begin
      File.open(savefile){|f|
        trainer=Marshal.load(f)
        framecount=Marshal.load(f)
        game_system=Marshal.load(f)
        Marshal.load(f)
        mapid=Marshal.load(f)
        if traineronly == false
          return [trainer, framecount, game_system, mapid]
        else
          return trainer
        end
      }
    rescue
      raise "If you're seeing this message, your save file is corrupted."
      raise savefile
    end
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
 
  def pbStartLoadScreen
    $PokemonTemp   = PokemonTemp.new
    $game_temp     = Game_Temp.new
    $game_map=nil
    Input.text_input = false
    cmdContinue    = -1
    cmdNewGame     = -1
    cmdControls    = -1
    cmdSaveDir     = -1
    cmdChooseSaveFile = -1
    cmdOption      = -1
    cmdLanguage    = -1
    cmdQuit        = -1
    cmdDeleteSaveFile = -1
    commands       = []
    trainer        = nil
    savefile = RTP.getSaveSlotPath($idk[:saveslot])
    if safeExists?(savefile)
      commands[cmdContinue=commands.length]=_INTL("Continue")
      commands[cmdNewGame=commands.length]=_INTL("New Game")
      commands[cmdChooseSaveFile=commands.length]=_INTL("Other Save Files")
      commands[cmdDeleteSaveFile=commands.length]=_INTL("Delete This Save File")
      commands[cmdOption=commands.length]=_INTL("Options")
      commands[cmdSaveDir=commands.length]=_INTL("Open Save Folder")
      commands[cmdControls=commands.length]=_INTL("Controls")
      trainer, framecount, $game_system, mapid = pbTryLoadFile(savefile,false)
    else
      commands[cmdNewGame=commands.length]=_INTL("New Game")
      commands[cmdChooseSaveFile=commands.length]=_INTL("Other Save Files")
      commands[cmdOption=commands.length]=_INTL("Options")
      commands[cmdSaveDir=commands.length]=_INTL("Open Save Folder")
      commands[cmdControls=commands.length]=_INTL("Controls")
    end
    if LANGUAGES.length>=2
      commands[cmdLanguage=commands.length]=_INTL("Language")
    end
    #commands[cmdQuit=commands.length]=_INTL("Quit Game")
    @scene.pbStartScene(commands,safeExists?(savefile),trainer,framecount,mapid)
    @scene.pbSetParty(trainer)
    @scene.pbStartScene2
    loop do
      command=@scene.pbChoose(commands)
      deleting=false
      if cmdDeleteSaveFile>=0 && command==cmdDeleteSaveFile
        if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to delete this save file?"))
          if Kernel.pbConfirmMessageSerious(_INTL("All data will be lost.  Confirm once more to proceed."))
            begin; File.delete(savefile); rescue; end
            deleting=true
            @scene.pbClearOverlay2
            @scene.pbEndScene
            return
            pbSetUpSystem(0,nil)
            scene=PokemonLoadScene.new
            screen=PokemonLoad.new(scene)
            screen.pbStartLoadScreen
          end
        end
        redo if deleting==false
      elsif cmdContinue>=0 && command==cmdContinue
        next if !startPlayingSaveFile(savefile)
        return
      elsif cmdNewGame>=0 && command==cmdNewGame
        $cache.cacheAnims
        @scene.pbEndScene
        if $game_map && $game_map.events
          for event in $game_map.events.values
            event.clear_starting
          end
        end
        $game_temp.common_event_id=0 if $game_temp
        $scene               = Scene_Map.new
        Graphics.frame_count = 0
        Graphics.start_playing = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        $game_system         = Game_System.new
        $game_switches       = Game_Switches.new
        $game_variables      = Game_Variables.new
        $game_self_switches  = Game_SelfSwitches.new
        $game_screen         = Game_Screen.new
        $game_player         = Game_Player.new
        $PokemonMap          = PokemonMapMetadata.new
        $PokemonGlobal       = PokemonGlobalMetadata.new
        $PokemonStorage      = PokemonStorage.new
        $PokemonEncounters   = PokemonEncounters.new
        $PokemonTemp.begunNewGame=true
        $MapFactory          = PokemonMapFactory.new($cache.RXsystem.start_map_id) # calls setMapChanged
        $game_player.moveto($cache.RXsystem.start_x, $cache.RXsystem.start_y)
        $game_player.refresh
        $game_map.autoplay
        $game_map.update
        
        #find next available slot
        j = 0
        loop do
          j+=1
          checksave=RTP.getSaveSlotPath(j)
          if !safeExists?(checksave)
            $idk[:saveslot]=j
            saveClientData
            break
          end
        end
        return
      elsif cmdChooseSaveFile>=0 && command==cmdChooseSaveFile
        cancelled=false
        saveslots=[]
        savefolder = RTP.getSaveFolder
        # Finding Other Save Files
        d = Dir.new(RTP.getSaveFolder)
        begin
          d.children.each do |file|
            next if !/^Game_[0-9]+.rxdata$/.match(file) && !/^Game.rxdata$/.match(file)
            next if !safeExists?(d.path + "/" + file)
            t=File.mtime(d.path + "/" + file) rescue pbGetTimeNow
            savetime = t.strftime("%c")
            info = saveinfo(d.path + "/" + file)
            savenumber = file.scan(/\d+/)[0].to_i
            savenumber = 1 if savenumber == 0
            slotname = "Save Slot #{savenumber}" + info
            saveslots.push([savenumber,slotname,false,true,savetime,file])
          end
        rescue
          pbPrintException($!)
        ensure
          d.close
        end

        # Specific Anna Smiles code
        anna_saves = []
        if Reborn
          d = Dir.new(RTP.getSaveFolder)
          begin
            d.children.each do |file|
              next if !file.start_with?("Anna's Wish")
              next if !safeExists?(d.path + "/" + file)
              trainer=pbTryLoadFile(d.path + "/" + file)
              info = " - #{trainer.name}"
              savenumber = file.scan(/\d+/)[0].to_i
              slotname = "Anna's Wish" + info
              anna_saves.push([savenumber,slotname,false,true,nil,file])
            end
          rescue
            pbPrintException($!)
          ensure
            d.close
          end
          anna_saves.sort_by! {|arr| arr[0] }
          saveslots += anna_saves
        end
        if saveslots.length==0
          Kernel.pbMessage(_INTL("You don't have any other save files"))
          next
        end
        saveslots.sort_by! {|arr| arr[0] }
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
            @selected = (@selected + 1) % saveslots.length
            @scene.pbMoveSaveSel(@selected)
          elsif Input.trigger?(Input::UP)
            @selected = (@selected - 1) % saveslots.length
            @scene.pbMoveSaveSel(@selected)
          elsif Input.trigger?(Input::PAGEUP)
            @selected = [@selected - 7, 0].max
            @scene.pbMoveSaveSel(@selected)
          elsif Input.trigger?(Input::PAGEDOWN)
            @selected = [@selected + 7, saveslots.length-1].min
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
            tempsave=saveslots[@selected][0]
            savefile = saveslots[@selected][5]
            if savefile.start_with?("Anna's Wish")
              return startPlayingSaveFile(RTP.getSaveFileName(savefile))
            end
            $idk[:saveslot] = tempsave     
            @scene.pbEndScene
            pbSetUpSystem(tempsave,nil)
            scene=PokemonLoadScene.new
            screen=PokemonLoad.new(scene)
            screen.pbStartLoadScreen
            return
          end
        end
      elsif cmdOption>=0 && command==cmdOption
        scene=PokemonOptionScene.new
        screen=PokemonOption.new(scene)
        pbFadeOutIn(99999) { screen.pbStartScreen }

      elsif cmdControls>=0 && command==cmdControls    
        System.show_settings
      elsif cmdSaveDir>=0 && command==cmdSaveDir
        if System.platform[/Windows/]
          pathstr = ENV['USERPROFILE'] + "\\Saved Games\\#{GAMETITLE}\\"
          system("explorer #{pathstr}")
        elsif System.platform[/Mac/]
          #pathstr = "~\\Library\\Application Support\\#{GAMETITLE}\\"
          folderpath = RTP.getSaveFolder
          System.open(folderpath)
        elsif System.platform[/Linux/]
          folderpath = RTP.getSaveFolder
          #System.open(folderpath)
          # Nautilus -s navigates to the parent folder, so...
          errorLogFile = "#{folderpath}/errorlog.txt"
          system("touch '#{errorLogFile}' && nautilus -s '#{errorLogFile}'")
        end
      elsif cmdLanguage>=0 && command==cmdLanguage
        @scene.pbEndScene
        $idk[:settings].language=pbChooseLanguage
        pbLoadMessages("Data/"+LANGUAGES[$idk[:settings].language][1])
        $scene=pbCallTitle
        return    
      end
    end
    @scene.pbEndScene
    return
  end

  def startPlayingSaveFile(savefile)
    unless safeExists?(savefile)
      pbPlayBuzzerSE()
      return false
    end
    startTimer
    @scene.pbEndScene        
    metadata = nil
    File.open(savefile){|f|
      $Trainer             = Marshal.load(f)
      Graphics.frame_count = Marshal.load(f)
      $game_system         = Marshal.load(f)
      Marshal.load(f) # PokemonSystem already loaded
      Marshal.load(f) # Current map id no longer needed
      $game_switches       = Marshal.load(f) # Why does removing these break shit
      $game_variables      = Marshal.load(f)
      $game_self_switches  = Marshal.load(f)
      $game_screen         = Marshal.load(f)
      $MapFactory          = Marshal.load(f)
      $game_map            = $MapFactory.map
      $game_player         = Marshal.load(f)
      $PokemonGlobal       = Marshal.load(f)
      metadata             = Marshal.load(f)
      $PokemonBag          = Marshal.load(f)
      $PokemonStorage      = Marshal.load(f)

      Graphics.time_passed = Graphics.frame_count.clone
      Graphics.start_playing = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      
      $cache.cacheAnims
      
      $game_system.game_version=GAMEVERSION if !$game_system.game_version
      
      if $game_variables[:Randomized_File_Loc].is_a?(String) || $game_switches[:Randomized_Challenge]
        setRandomizerData($game_variables[:Randomized_File_Loc])
      end
      getNGPData
      $PokemonBag.initTrackerData if !$PokemonBag.itemtracker

      if $PokemonGlobal.safesave
        if pbMapInterpreterRunning?
          pbMapInterpreter.setup(nil,0)
        end
        $MapFactory.setup($game_map.map_id) # calls setMapChanged
        $game_player.center($game_player.x, $game_player.y)
      else
        $MapFactory.setMapChanged($game_map.map_id)
      end
    }
    if !$game_map.events # Map wasn't set up
      $game_map=nil
      $scene=nil
      Kernel.pbMessage(_INTL("The map is corrupt. The game cannot continue."))
      return true
    end
    $PokemonMap=metadata
    $PokemonEncounters=PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    pbAutoplayOnSave
    $game_map.update
    auto=(auto==nil) ? false : auto
    # some bullshit, don't worry about it
    if $game_variables[675] > 0
      $game_variables[675] += 1
      $game_map.need_refresh = true
    end
    # end bullshit
    for event in $game_map.events.values
      event.unlock
    end
    $game_switches[:Mid_quicksave]=false
    $game_switches[:Stop_Icycle_Falling]=false
    stopTimer
    $scene = Scene_Map.new
    return true
  end
end

def saveinfo(savefile)
  begin
    trainer=pbTryLoadFile(savefile)
    info = " - #{trainer.name} - #{trainer.numbadges} badges"
  rescue
    info = "save corrupted"
  end
  return info
end

def pbStoredLastPlayed(savenum)
  $idk[:saveslot] = savenum
  saveClientData
end