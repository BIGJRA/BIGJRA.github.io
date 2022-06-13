############### Moveset Restorer ######################
  
  def pbRestoreMovesetScreen(pokemon)
    retval=true
    pbFadeOutIn(99999){
       scene=MoveRestorerScene.new
       screen=MoveRestorerScreen.new(scene)
       retval=screen.pbStartScreen(pokemon)
    }
    return retval
  end

  def getSetName()
    return $game_variables[6]
  end

  def duplicateMovesetChecker(pokemon)
    $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
    for moveset in $PokemonGlobal.storedMovesets
        if moveset[:id] == pokemon.species
            different = false
            for i in 0...pokemon.moves.length
                found = false
                for j in 0...moveset[:moves].length
                    if pokemon.moves[i].id == moveset[:moves][j].id
                        found = true
                    end
                end
                different = true if found == false
            end
            if different == false
                return moveset[:name]
            end
        end
    end
    return false
  end

  def duplicateNameChecker(pokemon)
    $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
    name = getSetName
    for moveset in $PokemonGlobal.storedMovesets
        if moveset[:id] == pokemon.species
            if moveset[:name] == name
                return true
            end
        end
    end
    return false
  end
  
  def updateMovesetName(pokemon)
    $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
    name = getSetName
    for moveset in $PokemonGlobal.storedMovesets
        if moveset[:id] == pokemon.species
            if moveset[:name] == name
                moveset[:moves] = pokemon.moves.clone
                return true
            end
        end
    end
    return false
  end

  def movesetRecorder(pokemon)
    name = getSetName
    $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
    $PokemonGlobal.storedMovesets.append({name: name, moves: pokemon.moves.clone, id: pokemon.species})
    return true
  end
  
  def getMovesets(mon_id)
    $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
    mon_sets = []
    for moveset in $PokemonGlobal.storedMovesets
      mon_sets.append(moveset) if moveset[:id] == mon_id
    end
    return mon_sets
  end
  
  def hasMovesets(mon_id)   
    return !getMovesets(mon_id).empty?
  end

  def deleteSet(pokemon,setname)
    $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
    $PokemonGlobal.storedMovesets.delete_if { |moveset| moveset[:id] == pokemon.species && moveset[:name] == setname } 
    if hasMovesets(pokemon.species) == false
        Kernel.pbMessage(_INTL("{1} has been deleted.",setname))
        return true
    else
        return pokemon.species
    end
  end
  
  def restoreSet(pokemon,setname)
    $PokemonGlobal.storedMovesets = [] if !$PokemonGlobal.storedMovesets
    for moveset in $PokemonGlobal.storedMovesets
        if moveset[:id] == pokemon.species
            if moveset[:name] == setname
                pokemon.moves = moveset[:moves].clone
                Kernel.pbMessage(_INTL("{1} has been restored.",setname))
                return true
            end
        end
    end
  end

  # Screen class for handling game logic
  class MoveRestorerScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen(pokemon)
      @scene.pbStartScene(pokemon)
      loop do
        setname=@scene.pbChoose
        if setname==""
          if @scene.pbConfirm(_INTL("Stop selecting movesets for {1}?",pokemon.name))
            @scene.pbEndScene
            return false
          end
        else
          ret = pbConfirmRelearnDeleteSets(pokemon,setname)
          if ret == true
            @scene.pbEndScene
            return ret
          end
        end
      end
    end

    def pbConfirmRelearnDeleteSets(pokemon,setname)
        cmdRestore=-1
        cmdDelete=-1
        cmdCancel=-1
        commands=[]
        commands[cmdRestore=commands.length]=_INTL("Restore")
        commands[cmdDelete=commands.length]=_INTL("Delete")
        commands[commands.length]=_INTL("Cancel")
        command=@scene.pbShowCommands(_INTL("Do what with {1}?",setname),commands)
        if cmdRestore>=0 && command==cmdRestore
            if restoreSet(pokemon,setname)
                @scene.pbEndScene
                return true
            end
        elsif cmdDelete>=0 && command==cmdDelete
          if @scene.pbConfirm(_INTL("Forget this moveset?"))
            ret = deleteSet(pokemon,setname)
            if ret == true
               return true
            elsif ret != nil
              @scene.pbUpdateList(pokemon)
            end
          else
            # Do nothing
          end
        elsif cmdCancel>=0 && command==cmdCancel
            # Do nothing
        end
     end 
  end


     

  class MoveRestorerScene
    def pbDisplay(msg,brief=false)
      UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
    end
  
    def pbConfirm(msg)
      UIHelper.pbConfirm(@sprites["msgwindow"],msg) { pbUpdate }
    end
  
    def pbUpdate
      pbUpdateSpriteHash(@sprites)
    end
  
    def pbStartScene(pokemon)
        @pokemon=pokemon
        @movesets=getMovesets(pokemon.species)
        movesetCommands=[]
        @movesets.each{|i| movesetCommands.push(i[:name]) }
        # Create sprite hash
        @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z=99999
        @sprites={}
        addBackgroundPlane(@sprites,"bg","restorerbg",@viewport)
        @sprites["pokeicon"]=PokemonIconSprite.new(@pokemon,@viewport)
        @sprites["pokeicon"].x=288
        @sprites["pokeicon"].y=44
        #@sprites["background"]=IconSprite.new(0,0,@viewport)
        #@sprites["background"].setBitmap("Graphics/Pictures/reminderSel")
        #@sprites["background"].y=78
        #@sprites["background"].src_rect=Rect.new(0,72,258,72)
        @sprites["rightarrow"]=AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
        @sprites["rightarrow"].play
        @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
        @sprites["moveOverlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        pbSetSystemFont(@sprites["moveOverlay"].bitmap)
        @sprites["commands"]=Window_CommandPokemon.new(movesetCommands,32)
        @sprites["commands"].x=Graphics.width
        #hardcoding this since we don't have the VISIBLEMOVES constants
        @sprites["commands"].height=32*(9)
        @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
        @sprites["msgwindow"].visible=false
        @sprites["msgwindow"].viewport=@viewport
        @typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
        pbSetList
        pbDrawSetMoves
        pbDeactivateWindows(@sprites)
        # Fade in all sprites
        pbFadeInAndShow(@sprites) { pbUpdate }
    end


    def pbUpdateList(pokemon)
        @movesets=getMovesets(pokemon.species)
        movesetCommands=[]
        @movesets.each{|i| movesetCommands.push(i[:name]) }     
        @sprites["commands"]=Window_CommandPokemon.new(movesetCommands,32)
        @sprites["commands"].x=Graphics.width
        @sprites["commands"].height=32*(9)
        pbSetList
        pbDrawSetMoves
    end


    def pbSetList
      overlay=@sprites["overlay"].bitmap
      overlay.clear
      textpos=[]
      imagepos=[]
      type1rect=Rect.new(0,@pokemon.type1*28,64,28)
      type2rect=Rect.new(0,@pokemon.type2*28,64,28)
      if @pokemon.type1==@pokemon.type2
        overlay.blt(400,70,@typebitmap.bitmap,type1rect)
      else
        overlay.blt(366,70,@typebitmap.bitmap,type1rect)
        overlay.blt(436,70,@typebitmap.bitmap,type2rect)
      end
      textpos=[ [_INTL("Restore which moveset?"),6,8,0,Color.new(88,88,80),Color.new(168,184,184)] ]
      yPos=114
      for i in 0...8
        storedset=@movesets[@sprites["commands"].top_item+i]
        if storedset
          textpos.push([storedset[:name],292,yPos,0, Color.new(64,64,64),Color.new(176,176,176)])
        end
        yPos+=32
      end
      #imagepos.push(["Graphics/Pictures/reminderSel", 0,78+(@sprites["commands"].index-@sprites["commands"].top_item)*64, 0,0,258,72])

      if @sprites["commands"].index<@movesets.length-1
        imagepos.push(["Graphics/Pictures/reminderButtons",48,350,0,0,76,32])
      end
      if @sprites["commands"].index>0
        imagepos.push(["Graphics/Pictures/reminderButtons",134,350,76,0,76,32])
      end


      pbDrawTextPositions(overlay,textpos)
      pbDrawImagePositions(overlay,imagepos)
      pbDrawSetMoves

      
      #drawTextEx(overlay,272,210,238,5, pbGetMessage(MessageTypes::MoveDescriptions,@moves[@sprites["commands"].index]), Color.new(64,64,64),Color.new(176,176,176))
    end
  
    def pbDrawSetMoves
        overlay=@sprites["moveOverlay"].bitmap
        overlay.clear
        textpos=[]
        imagepos=[]
        selmoveset=@movesets[@sprites["commands"].index][:moves]
        yPos = 82
        for move in selmoveset
            imagepos.push(["Graphics/Pictures/types",12,yPos+2,0, move.type*28,64,28])
            textpos.push([PBMoves.getName(move.id),80,yPos,0, Color.new(248,248,248),Color.new(0,0,0)])
            if move.totalpp>0
            textpos.push([_INTL("PP"),112,yPos+32,0, Color.new(64,64,64),Color.new(176,176,176)])
            textpos.push([_ISPRINTF("{1:d}/{2:d}", move.totalpp,move.totalpp),230,yPos+32,1, Color.new(64,64,64),Color.new(176,176,176)])
            end
            yPos+=64
        end
        @sprites["rightarrow"].x=254
        @sprites["rightarrow"].y=116+(@sprites["commands"].index-@sprites["commands"].top_item)*32
        pbDrawTextPositions(overlay,textpos)
        pbDrawImagePositions(overlay,imagepos)
    end
  
  # Processes the scene
    def pbChoose
      oldcmd=-1
      pbActivateWindow(@sprites,"commands"){
         loop do
           oldcmd=@sprites["commands"].index
           Graphics.update
           Input.update
           pbUpdate
           if @sprites["commands"].index!=oldcmd
           #  @sprites["background"].x=0
           #  @sprites["background"].y=78+(@sprites["commands"].index-@sprites["commands"].top_item)*64
             pbSetList
           end
           if Input.trigger?(Input::B)
             return ""
           end
           if Input.trigger?(Input::C)
             return @movesets[@sprites["commands"].index][:name]
           end
         end
      }
    end

    def pbShowCommands(message,commands,index=0)
      ret=0
      msgwindow=Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
      msgwindow.viewport=@viewport
      msgwindow.visible=true
      msgwindow.letterbyletter=false
      msgwindow.resizeHeightToFit(message,Graphics.width-180)
      msgwindow.text=message
      pbBottomRight(msgwindow)
      cmdwindow=Window_CommandPokemon.new(commands)
      cmdwindow.viewport=@viewport
      cmdwindow.visible=true
      cmdwindow.resizeToFit(cmdwindow.commands)
      cmdwindow.height=Graphics.height-msgwindow.height if cmdwindow.height>Graphics.height-msgwindow.height
      cmdwindow.update
      cmdwindow.index=index
      pbBottomRight(cmdwindow)
      cmdwindow.y-=msgwindow.height
      loop do
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
        pbUpdateSpriteHash(@sprites)
        msgwindow.update
        cmdwindow.update
      end
      msgwindow.dispose
      cmdwindow.dispose
      Input.update
      return ret
    end
  
  # End the scene here
    def pbEndScene
      pbFadeOutAndHide(@sprites) { pbUpdate } # Fade out all sprites
      pbDisposeSpriteHash(@sprites) # Dispose all sprites
      @typebitmap.dispose
      @viewport.dispose # Dispose the viewport
    end
  end