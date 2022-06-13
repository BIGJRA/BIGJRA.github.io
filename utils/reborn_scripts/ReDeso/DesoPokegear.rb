class Scene_Pokegear
    #-----------------------------------------------------------------------------
    # initialize
    #-----------------------------------------------------------------------------
    def initialize(menu_index = 0)
      @menu_index = menu_index
    end
    #-----------------------------------------------------------------------------
    # main
    #-----------------------------------------------------------------------------
    def main
        commands=[]
    # OPTIONS - If you change these, you should also change update_command below.
        @cmdMap=-1
        @cmdPhone=-1
        @cmdJukebox=-1
        @cmdOnline=-1    
        @cmdPulse=-1
        ###Yumil - Quest Log - 32###
        @cmdQuest=1
        ###Yumil - Quest Log - 32###
        @cmdNotes=-1
        ###Yumil - Quest Log - 33###
        if $game_switches[713]
          commands[@cmdQuest=commands.length]=_INTL("Quest Log")
        end
        ###Yumil - Quest Log - 33###
        commands[@cmdMap=commands.length]=_INTL("Map")
        commands[@cmdPhone=commands.length]=_INTL("Phone") if $PokemonGlobal.phoneNumbers &&
                                                              $PokemonGlobal.phoneNumbers.length>0
        commands[@cmdJukebox=commands.length]=_INTL("Jukebox")
        if $game_switches[999]
        commands[@cmdOnline=commands.length]=_INTL("Online Play") 
        end
        if $game_switches[999]
          commands[@cmdPulse=commands.length]=_INTL("PULSE Dex")
        end
        if $game_switches[999]
          commands[@cmdNotes=commands.length]=_INTL("Field Notes")
        end
        @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z=99999
        @button=AnimatedBitmap.new("Graphics/Pictures/pokegearButton")
        @sprites={}
        @sprites["background"] = IconSprite.new(0,0)
        femback=pbResolveBitmap(sprintf("Graphics/Pictures/pokegearbgf"))
        if $Trainer.isFemale? && femback
          @sprites["background"].setBitmap("Graphics/Pictures/pokegearbgf")
        else
          @sprites["background"].setBitmap("Graphics/Pictures/pokegearbg")
        end
        @sprites["command_window"] = Window_CommandPokemon.new(commands,160)
        @sprites["command_window"].index = @menu_index
        @sprites["command_window"].x = Graphics.width
        @sprites["command_window"].y = -3000 #0
        for i in 0...commands.length
          x=118
          y=196 - (commands.length*24) + (i*48)
          @sprites["button#{i}"]=PokegearButton.new(x,y,commands[i],i,@viewport)
          @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
          @sprites["button#{i}"].update
        end
        Graphics.transition
        loop do
          Graphics.update
          Input.update
          update
          if $scene != self
            break
          end
        end
        Graphics.freeze
        pbDisposeSpriteHash(@sprites)
      end
      #-----------------------------------------------------------------------------
      # update the scene
      #-----------------------------------------------------------------------------
      def update
        for i in 0...@sprites["command_window"].commands.length
          sprite=@sprites["button#{i}"]
          sprite.selected=(i==@sprites["command_window"].index) ? true : false
        end
        pbUpdateSpriteHash(@sprites)
        #update command window and the info if it's active
        if @sprites["command_window"].active
          update_command
          return
        end
      end
      #-----------------------------------------------------------------------------
      # update the command window
      #-----------------------------------------------------------------------------
      def update_command
        if Input.trigger?(Input::B)
          pbPlayCancelSE()
          $scene = Scene_Map.new
          return
        end
        if Input.trigger?(Input::C)
          if @cmdMap>=0 && @sprites["command_window"].index==@cmdMap
            pbPlayDecisionSE()               
            pbShowMap(-1,false)
          end
          if @cmdPhone>=0 && @sprites["command_window"].index==@cmdPhone
            pbPlayDecisionSE()
            pbFadeOutIn(99999) {
               PokemonPhoneScene.new.start
            }
          end
          if @cmdJukebox>=0 && @sprites["command_window"].index==@cmdJukebox
            pbPlayDecisionSE()
            $scene = Scene_Jukebox.new
          end
          if @cmdOnline>=0 && @sprites["command_window"].index==@cmdOnline
            pbPlayDecisionSE()
            if Kernel.pbConfirmMessage(_INTL("Would you like to save the game?"))
              if pbSave
                Kernel.pbMessage("Saved the game!")
                tryConnect
              else
                Kernel.pbMessage("Save failed.")
              end
            end        
          end          
          if @cmdPulse>=0 && @sprites["command_window"].index==@cmdPulse
            pbPlayDecisionSE()
            $scene = Scene_PulseDex.new
          end
            if @cmdQuest>=0 && @sprites["command_window"].index==@cmdQuest
            pbPlayDecisionSE()
            $game_variables[199] ||= 0
            $game_variables[198] ||= 0
            ###Yumil -- 04 -- Quest Log
            if ($game_variables[200]!=true && $game_variables[200]!=false)
              $game_variables[200]=true
            end
            if $game_variables[200]
          pbFadeOutIn(99999) {
            scene = QuestLog_Scene.new($game_variables[199])
            screen = QuestLogScreen.new(scene)
            screen.pbStartScreen
          }
            else
          pbFadeOutIn(99999) {
            scene = QuestLog_Scene.new($game_variables[198])
            screen = QuestLogScreen.new(scene)
            screen.pbStartScreen
          }
            end
            ###Yumil -- 04 -- Quest Log
          end
          if @cmdNotes>=0 && @sprites["command_window"].index==@cmdNotes
            pbPlayDecisionSE()
            $scene = Scene_FieldNotes.new
          end
            
          return
        end
      end
      def tryConnect
        $scene=Connect.new
      end    
  end