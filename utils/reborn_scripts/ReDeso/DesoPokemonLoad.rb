class PokemonLoad
    def pbStartLoadScreen(savenum=0,auto=nil,savename="Save Slot 1")
      $PokemonTemp   = PokemonTemp.new
      $game_temp     = Game_Temp.new
      $game_system   = Game_System.new
      #$PokemonSystem = PokemonSystem.new if !$PokemonSystem
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
      
      if !(savenum==0 || savenum==1)
        savefile = auto != nil ? RTP.getSaveFileName("Game_"+savenum.to_s+"_autosave.rxdata") : RTP.getSaveFileName("Game_"+savenum.to_s+".rxdata")
      else
        savefile = auto != nil ? RTP.getSaveFileName("Game_autosave.rxdata") : RTP.getSaveFileName("Game.rxdata")
      end
      data_system = pbLoadRxData("Data/System")
      mapfile=sprintf("Data/Map%03d.rxdata",data_system.start_map_id)
      if data_system.start_map_id==0 || !pbRgssExists?(mapfile)
        Kernel.pbMessage(_INTL("No starting position was set in the map editor.\1"))
        Kernel.pbMessage(_INTL("The game cannot continue."))
        @scene.pbEndScene
        $scene=nil
        return
      end
      if safeExists?(savefile)
        trainer=nil
        framecount=0
        mapid=0
        showContinue=false
        haveBackup=false
        begin
          trainer, framecount, $game_system, $PokemonSystem, mapid=pbTryLoadFile(savefile)
          showContinue=true
        rescue
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
        commands[cmdOption=commands.length]=_INTL("Options")
        commands[cmdSaveDir=commands.length]=_INTL("Open Save Folder")
        commands[cmdControls=commands.length]=_INTL("Controls")
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
      @scene.pbStartScene(commands,showContinue,trainer,framecount,mapid)
      @scene.pbSetParty(trainer) if showContinue
      @scene.pbStartScene2
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
          loadtime = Time.now
          @scene.pbEndScene        
          metadata = nil
          File.open(savefile){|f|
            Marshal.load(f) # Trainer already loaded
            $Trainer             = trainer
            Graphics.frame_count = Marshal.load(f)
            $game_system         = Marshal.load(f)
            $PokemonSystem       = Marshal.load(f) # PokemonSystem already loaded
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
            $cache.animations     = load_data("Data/PkmnAnimations.rxdata") if !$cache.animations && $PokemonSystem.battlescene
            $PokemonBag          = Marshal.load(f)
            $PokemonStorage      = Marshal.load(f)
            ###Yumil - 35 - Quest Log - Begin
            if(!f.eof?)
            $QuestLog            = Marshal.load(f)
            else
            $QuestLog            =load_data("Data/quests.dat")
            end
            ###Yumil - 35 - Quest Log - Begin  
            ###Yumil - 11 - NPC Reaction - Begin
            if(!f.eof?)
                $battleDataArray     = Marshal.load(f)
            else
                $battleDataArray     = []
            end
            $NPCReactions = load_data("Data/npcreactions.dat") if (!$NPCReactions && File.exists?("Data/npcreactions.dat"))
            ###Yumil - 11 - NPC Reaction - Begin
            ###Yumil - XX - Undertale - Begin
            if File.exists?("Data/temp.dat")
              file = File.open("Data/temp.dat", "r") 
              $game_variables[1001] = file.read
            end
            ###Yumil - XX - Undertale - End
            Graphics.time_passed = Graphics.frame_count.clone
            Graphics.start_playing = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  
            $PokemonSystem.reload
            xsave = savefile[0..savefile.size-8]
            slot = xsave.split("_")[-1]
            $game_variables[27] =  slot.to_i.to_s == slot ? slot.to_i : 0
            
            $PokemonBag.initTrackerData if !$PokemonBag.itemtracker
  
            if $cache.RXsystem.respond_to?("magic_number")
              magicNumberMatches=($game_system.magic_number==$cache.RXsystem.magic_number)
            else
              magicNumberMatches=($game_system.magic_number==$cache.RXsystem.version_id)
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
          pbStoredLastPlayed($game_variables[27],auto)
          # some bullshit, don't worry about it
          if $game_variables[675] > 0
            $game_variables[675] += 1
            $game_map.need_refresh = true
          end
          # end bullshit
          puts Time.now - loadtime
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
          Graphics.start_playing = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          $game_system         = Game_System.new
          $game_switches       = Game_Switches.new
          $game_variables      = Game_Variables.new
          $game_self_switches  = Game_SelfSwitches.new
          $game_screen         = Game_Screen.new
          $game_player         = Game_Player.new
          $cache.items            = load_data("Data/Data/items.dat") if !$cache.items
          ###Yumil -- 42 -- Quest Log--- Begin
          $QuestLog            = load_data("Data/quests.dat")  if !$QuestLog
          ###Yumil -- 42 -- Quest Log--- End
          $cache.animations     = load_data("Data/PkmnAnimations.rxdata") if !$cache.animations && $PokemonSystem.battlescene
          $PokemonMap          = PokemonMapMetadata.new
          $PokemonGlobal       = PokemonGlobalMetadata.new
          $PokemonStorage      = PokemonStorage.new
          $PokemonEncounters   = PokemonEncounters.new
          $PokemonTemp.begunNewGame=true
          $cache.RXsystem         = load_data("Data/System.rxdata") if !$cache.RXsystem
          $MapFactory          = PokemonMapFactory.new($cache.RXsystem.start_map_id) # calls setMapChanged
          $game_player.moveto($cache.RXsystem.start_x, $cache.RXsystem.start_y)
          $game_player.refresh
          $game_map.autoplay
          $game_map.update
          
          #find next available slot
          checksave=RTP.getSaveFileName("Game.rxdata")
          if !safeExists?(checksave)
            $game_variables[27]=0
          else
            j=2
            loop do
              checksave=RTP.getSaveFileName("Game_"+j.to_s+".rxdata")
              if !safeExists?(checksave)
                $game_variables[27]=j
                break
              end
              j+=1
            end
          end
          auto=(auto==nil) ? false : auto
          pbStoredLastPlayed($game_variables[27],auto)
          $PokemonSystem = PokemonSystem.new
          return
        elsif cmdChooseSaveFile>=0 && command==cmdChooseSaveFile
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
          d = Dir.new(savefolder)
          begin
            d.children.each do |file|
              next if !/^Game_[0-9]+.rxdata$/.match(file)
              next if !safeExists?(d.path + file)
              t=File.mtime(d.path + file) rescue pbGetTimeNow
              savetime = t.strftime("%c")
              info = saveinfo(d.path + file)
              savenumber = file.scan(/\d+/)[0].to_i
              slotname = "Save Slot #{savenumber}" + info
              saveslots.push([savenumber,slotname,false,true,savetime,""])
            end
          rescue
            pbPrintException($!)
          ensure
            d.close
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
                auto=(autoindex==1) ? true : nil
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
            pathstr = "~\\Library\\Application Support\\#{GAMETITLE}\\"
            system("explorer #{pathstr}")
          elsif System.platform[/Linux/]
            pathstr = "~\\.local\\share\\#{GAMETITLE}\\"
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