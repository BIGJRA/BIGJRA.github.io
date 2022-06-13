class BattleSwapScene
  # Processes the scene
  def pbChoosePokemon(canCancel)
    pbActivateWindow(@sprites,"list"){
       loop do
         Graphics.update
         Input.update
         pbUpdate
         if Input.trigger?(Input::B) && canCancel
           return -1
         end
         if Input.trigger?(Input::C)
           index=@sprites["list"].index
           if index==@sprites["list"].commands.length-1 && canCancel
             return -1
           elsif index==@sprites["list"].commands.length-2 && canCancel && @mode==2
             return -2
           else
             return index
           end
         end
      end
    }
  end
  
  def pbGetFieldName(rental)
    if $game_variables[:Forced_Field_Effect]==0
      if rental
        return "Rental Pokémon"
      else
        return "Swap Pokémon"
      end
    else
      return FIELDEFFECTS[$game_variables[:Forced_Field_Effect]][:FIELDNAME]
    end
  end


  def pbShowCommands(commands)
    UIHelper.pbShowCommands(@sprites["msgwindow"],nil,commands) { pbUpdate }
  end

  def pbConfirm(message)
    UIHelper.pbConfirm(@sprites["msgwindow"],message) { pbUpdate }
  end

  def pbGetCommands(list,choices)
    commands=[]
#    @sprites["help"].text=_INTL("length list" + list.length.to_s)    
    for i in 0...list.length
      pkmn=list[i]
      kind=pbGetMessage(MessageTypes::Kinds,pkmn.species)
      selected=shadowctagFromColor(Color.new(232,0,0))
      if choices.any?{|item| item==i}
        commands.push(selected+_INTL("{1} - {2} Pokémon",
           PBSpecies.getName(pkmn.species),kind))
      else
        commands.push(_INTL("{1} - {2} Pokémon",
           PBSpecies.getName(pkmn.species),kind))
      end
    end
    return commands
  end

  def pbUpdateChoices(choices)
    commands=pbGetCommands($game_variables[:rentalsnew],choices)
    @choices=choices
    if choices.length==0
      @sprites["help"].text=_INTL("Choose the first Pokémon.")
    elsif choices.length==1
      @sprites["help"].text=_INTL("Choose the second Pokémon.")
    elsif choices.length==2
      @sprites["help"].text=_INTL("Choose the third Pokémon.")
    elsif choices.length==3 && $game_variables[:doublebattlefact]
      @sprites["help"].text=_INTL("Choose the fourth Pokémon.")                 #added fourth option for doubles
    end
    @sprites["list"].commands=commands
  end

  def pbSwapChosen(pkmnindex)
    commands=pbGetCommands(@newPokemon,[])
    commands.push(_INTL("Pkmn for swap"))
    commands.push(_INTL("Cancel"))
    @sprites["help"].text=_INTL("Select Pokémon to accept.")
    @sprites["list"].commands=commands
    @sprites["list"].index=0
    @mode=2
  end

  def pbInitSwapScreen
    commands=pbGetCommands(@currentPokemon,[])
    commands.push(_INTL("Cancel"))
    @sprites["help"].text=_INTL("Select Pokémon to swap.")
    @sprites["list"].commands=commands
    @sprites["list"].index=0
    @mode=1  
  end

  def pbSwapCanceled
    pbInitSwapScreen
  end

  def pbSummary(list,index)
    visibleSprites=pbFadeOutAndHide(@sprites){ pbUpdate }
    scene=PokemonSummaryScene.new
    screen=PokemonSummary.new(scene)
    @sprites["list"].index=screen.pbStartScreen(list,index)
    pbFadeInAndShow(@sprites,visibleSprites){ pbUpdate }
  end

  # Update the scene here, this is called once each frame
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    # Add other things that should be updated
  end

  # End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate } # Fade out all sprites
    pbDisposeSpriteHash(@sprites) # Dispose all sprites
    @viewport.dispose # Dispose the viewport
  end

  def pbStartSwapScene(currentPokemon,newPokemon)
    # Create sprite hash
    @sprites={}
    @mode=1 # swap
    # Allocate viewport
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
       _INTL(pbGetFieldName(false)),0,0,Graphics.width,64,@viewport)
    @sprites["help"]=Window_UnformattedTextPokemon.newWithSize(
       "",0,Graphics.height-64,Graphics.width,64,@viewport)
    @sprites["list"]=Window_AdvancedCommandPokemon.newWithSize(
       [],0,64,Graphics.width,Graphics.height-128,@viewport)
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.newWithSize(
       "",0,Graphics.height-64,Graphics.width,64,@viewport)
    @sprites["msgwindow"].visible=false
    addBackgroundPlane(@sprites,"bg","swapbg",@viewport)
    @currentPokemon=currentPokemon
    @newPokemon=newPokemon
    pbInitSwapScreen()
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartRentScene(rentals)
    # Create sprite hash
    @sprites={}
    @mode=0 # rental
    # Allocate viewport
    $game_variables[:rentalsnew]=rentals
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
       _INTL(pbGetFieldName(true)),0,0,Graphics.width,64,@viewport)
    @sprites["help"]=Window_UnformattedTextPokemon.newWithSize("",
       0,Graphics.height-64,Graphics.width,64,@viewport)
    @sprites["list"]=Window_AdvancedCommandPokemon.newWithSize(
       [],0,64,Graphics.width,Graphics.height-128,@viewport)
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.newWithSize("",
       0,Graphics.height-64,Graphics.height,64,@viewport)
    @sprites["msgwindow"].visible=false
    addBackgroundPlane(@sprites,"bg","rentbg",@viewport)
    pbUpdateChoices([])
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end



class BattleSwapScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartRent(rentals)
    @scene.pbStartRentScene(rentals)
    chosen=[]
    loop do
      index=@scene.pbChoosePokemon(false)
      commands=[]
      commands.push(_INTL("Summary"))
      if chosen.any?{|item| item==index }
        commands.push(_INTL("Deselect"))
      else
        commands.push(_INTL("Rent"))
      end
      commands.push(_INTL("Cancel"))
      command=@scene.pbShowCommands(commands)
      if command==0
        @scene.pbSummary(rentals,index)
      elsif command==1
        if chosen.any?{|item| item==index }
          chosen.delete(index)
          @scene.pbUpdateChoices(chosen.clone)
        else
          chosen.push(index)
          @scene.pbUpdateChoices(chosen.clone)
          if chosen.length == 3 && !$game_variables[:doublebattlefact]
            if @scene.pbConfirm(_INTL("Are these three Pokémon OK?"))
              retval=[]
              chosen.each{|i| retval.push(rentals[i]) }
              @scene.pbEndScene
              return retval
            else
              chosen.delete(index)                                          
              @scene.pbUpdateChoices(chosen.clone)
            end
          end
          if chosen.length == 4
            if @scene.pbConfirm(_INTL("Are these four Pokémon OK?"))
              retval=[]
              chosen.each{|i| retval.push(rentals[i]) }
              @scene.pbEndScene
              return retval
            else
              chosen.delete(index)
              @scene.pbUpdateChoices(chosen.clone)
            end
          end
        end
      end
    end
  end

  def pbStartSwap(currentPokemon,newPokemon)
    @scene.pbStartSwapScene(currentPokemon,newPokemon)
    loop do
      pkmn=@scene.pbChoosePokemon(true)
      if pkmn>=0
        commands=[_INTL("Summary"),_INTL("Swap"),_INTL("Rechoose")]
        command=@scene.pbShowCommands(commands)
        if command==0
          @scene.pbSummary(currentPokemon,pkmn)
        elsif command==1
          @scene.pbSwapChosen(pkmn)
          yourPkmn=pkmn
          loop do
            pkmn=@scene.pbChoosePokemon(true)
            if pkmn>=0
              if @scene.pbConfirm(_INTL("Accept this Pokémon?"))
                @scene.pbEndScene
                currentPokemon[yourPkmn]=newPokemon[pkmn]
                return true
              end
            elsif pkmn==-2
              @scene.pbSwapCanceled
              break # Back to first screen
            elsif pkmn==-1
              if @scene.pbConfirm(_INTL("Quit swapping?"))
                @scene.pbEndScene
                return false
              end
            end
          end
        end
      else
        # Canceled
        if @scene.pbConfirm(_INTL("Quit swapping?"))
          @scene.pbEndScene
          return false
        end
      end
    end
  end
end