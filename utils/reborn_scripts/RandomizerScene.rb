module Graphics
  def self.width=(value)
    @@width = value
  end

  def self.height=(value)
    @@height = value
  end
end

# RandomizerSettings.new
class RandomizerScene
  attr_accessor :settings
  attr_accessor :mainwin
  attr_accessor :pages
  attr_accessor :breakflag


  PAGENAMES = {
    :species => 0,
    :moves => 1,
    :abilities => 2,
    :types => 3,
    :items => 4,
    :other => 5,
    :folder => 6
  }

  def initialize(settings)
    # Start by resizing the screen properly so it fits
    oldborder = $idk[:settings].border
    $idk[:settings].border = 0
    setScreenBorder
    $ResizeBorder.dispose
    resizeSpritesAndViewports
    Graphics.width = 800
    Graphics.height = 512
    Graphics.resize_screen(Graphics.width,Graphics.height)
    GC.start

    # Setting attributes
    @settings = settings
    @breakflag= false
    @confirmflag = false
    @settingsChanged = false
    @otherfileflag = false
    viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z=99999
    
    # Right hand menu
    sidewinlength = 240
    sidewin=ControlWindow.new(0,0,sidewinlength,Graphics.height)
    sidewin.addButton(_INTL("Species Options"))
    sidewin.addButton(_INTL("Move Options"))
    sidewin.addButton(_INTL("Abilities Options"))
    sidewin.addButton(_INTL("Type Options"))
    sidewin.addButton(_INTL("Item Options"))
    sidewin.addButton(_INTL("Other Options"))
    sidewin.addButton(_INTL("Folder Options"))
    5.times do 
      sidewin.addSpace
    end
    sidewin.addButton(_INTL("Use Existing Data"))
    sidewin.addButton(_INTL("Cancel"))
    sidewin.addButton(_INTL("Done"))
    sidewin.viewport=viewport
    #create the 5 main windows
    #have a function that sets @mainwin to a specific ControlWindow
    @pages = makePages(viewport,sidewinlength)
    @mainwin = @pages[0]
    @mainwin.visible = true
    finished = nil
    loop do
      Graphics.update
      Input.update
      sidewinLoop(sidewin)
      mainwinloop()
      if @otherfileflag 
        $game_switches[:Randomized_Challenge] = true
        finished = true
        break
      end
      if Input.trigger?(Input::B) || @breakflag
        @breakflag = false
        if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to exit without randomizing?"))
          finished = false
          break
        end
      end
      if @confirmflag
        @confirmflag = false
        if !@settingsChanged
          if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to exit without randomizing?"))
            finished = true
            break
          end
        else
          Dir.mkdir("RandData") unless Dir.exists?("RandData")
          if Dir.exists?("RandData/#{@settings.name}")
            if Kernel.pbConfirmMessageSerious("Are you sure you wish to overwrite the data in \\bRandData\\\\#{@settings.name}\\c[0]?\nThe data will be lost forever \\r(a long time!) \\c[0]and may \\raffect other saves!")
              Dir.each_child("RandData/#{@settings.name}") {|file| File.delete("RandData/#{@settings.name}/#{file}")}
              $RandomizedChallenge = RandomizedChallenge.new(@settings)
              $game_switches[:Randomized_Challenge] = true
              finished = true
              break
            end
          else
            $RandomizedChallenge = RandomizedChallenge.new(@settings)
            $game_switches[:Randomized_Challenge] = true
            finished = true
            break
          end

        end
      end
    end
    sidewin.dispose
    @pages.each {|win| win.dispose}
    viewport.dispose

    # Return screen to normal size
    $idk[:settings].border = oldborder
    setScreenBorder
    setScreenBorderName("border")
    resizeSpritesAndViewports
    Graphics.resize_screen(DEFAULTSCREENWIDTH + 2*$ResizeOffsetX,DEFAULTSCREENHEIGHT+2*$ResizeOffsetY)
    Graphics.width = DEFAULTSCREENWIDTH
    Graphics.height = DEFAULTSCREENHEIGHT
    GC.start
    return finished
  end 

  def sidewinLoop(sidewin)
    
    sidewin.update
    
    # Going to a specific menu option
    for i in 0..6
      pbUpdateSidebar(i) if sidewin.changed?(i)
    end
    if sidewin.changed?(12)
      Input.text_input = true
      foldername = Kernel.pbMessageFreeText(_INTL("Enter the name of the folder where you want to get randomizer data from. Hit Escape to cancel."),"#{$Trainer.name}",false,999,800) 
      Input.text_input = false
      if foldername != ""
        @otherfileflag = setRandomizerData(foldername)
        $game_variables[:Randomized_File_Loc] = foldername if @otherfileflag
      end
    end
    # Returning 
    @confirmflag = true       if sidewin.changed?(14)
    @breakflag = true         if sidewin.changed?(13)
  end

  def mainwinloop
    @mainwin.update
    for i in 0...@mainwin.controls.length
      option = @mainwin.controls[i]
      if @mainwin.changed?(i)
        if option.is_a?(Button) && @mainwin == @pages[PAGENAMES[:folder]]
          begin
            Input.text_input = true
            foldername = Kernel.pbMessageFreeText(_INTL("What would you like to call the folder?"),"#{@settings.name}",false,999,800)
            while foldername == ""
              Kernel.pbMessage("Please enter a valid folder name.")
              foldername = Kernel.pbMessageFreeText(_INTL("What would you like to call the folder?"),"#{@settings.name}",false,999,800)
            end
            @settings.name = foldername
            Input.text_input = false
            option.label = foldername
            option.refresh
          rescue
            pbPrintException($!)
            Input.text_input = false
          end
        else
          option.setvalue
          @settingsChanged = true
        end
      end
    end

  end

  def makePages(viewport,sidewinlength)
    # Making Move page
    pokepage = ControlWindow.new(240,0,800-sidewinlength,512)
    pokepage.visible = false
    pokepage.viewport = viewport
    pokepage.addLabel("Move Options:")

    randGenHash = {
      0 => 'shuffle',
      1 => 'dist',
      2 => 'chaos'
    }
    randGenText = ["Shuffle", "Distributed", "Chaos"]

    movepage = ControlWindow.new(240,0,800-sidewinlength,512)
    movepage.visible = false
    movepage.viewport = viewport
    movepage.addLabel("Move Options:")
    #movepage.addCheckbox("Have Pokémon Movesets randomize.",proc {|value| @settings.selfmove = value})
    movepage.addCheckbox("Have player's Movesets randomize",proc {|value| @settings.selfmove = value})
    movepage.addCheckbox("Have opponents's Movesets randomize",proc {|value| @settings.oppmove = value})
    movepage.addCheckbox("Have Movesets random instead of shuffled",proc {|value| @settings.movechaos = value})
    movepage.addCheckbox("Have Move Typings randomize",proc {|value| @settings.movetype = value})
    movepage.addCheckbox("Have Move Base Powers randomize", proc {|value| @settings.movepow = value})
    movepage.addTextSlider(" Set Move Base Power generation    ",
      randGenText, 0, proc {|value| @settings.movepowgen = randGenHash[value]})
    movepage.addCheckbox("Have Move Accuracy randomize", proc {|value| @settings.moveacc = value})
    movepage.addTextSlider(" Set Move Accuracy generation       ",
      randGenText, 0, proc {|value| @settings.moveaccgen = randGenHash[value]})
    movepage.addLabel("Shuffle - Values are changed around maintaing the original")
    movepage.addLabel("amount of values.")
    movepage.addLabel("Distributed - Values are changed based on the ratios of")
    movepage.addLabel("original values.")
    movepage.addLabel("Chaos - Values are randomly generated with no regard to the")
    movepage.addLabel("original values.")

    # Making Ability page
    abilpage = ControlWindow.new(240,0,800-sidewinlength,512)
    abilpage.visible = false
    abilpage.viewport = viewport
    abilpage.addLabel("Ability Options:")
    #abilpage.addCheckbox("Have Pokémon Abilities randomize", proc {|value| @settings.selfabil = value})
    abilpage.addCheckbox("Have player's Abilities randomize", proc {|value| @settings.selfabil = value})
    abilpage.addCheckbox("Have opponent's Abilities randomize", proc {|value| @settings.oppabil = value})
    abilpage.addCheckbox("Have Abilities random instead of shuffled",proc {|value| @settings.abilchaos = value})
    

    # Making Species page
    specpage = ControlWindow.new(240,0,800-sidewinlength,512)
    specpage.visible = false
    specpage.viewport = viewport
    specpage.addLabel("Species Options:")
    #specpage.addCheckbox("Have all Pokémon randomize",proc {|value| @settings.selfmon = value})
    specpage.addCheckbox("Have player's Pokémon randomize",proc {|value| @settings.selfmon = value})
    specpage.addCheckbox("Have opponents's Pokémon randomize",proc {|value| @settings.oppmon = value})
    specpage.addCheckbox("Have Pokémon random instead of shuffled",proc {|value| @settings.monchaos = value})
    #specpage.addCheckbox("Have player's forms randomize",proc {|value| @settings.selfform = value})
    #specpage.addCheckbox("Have opponents's forms randomize",proc {|value| @settings.oppform = value})

    # Making Type page
    typepage = ControlWindow.new(240,0,800-sidewinlength,512)
    typepage.visible = false
    typepage.viewport = viewport
    typepage.addLabel("Type Options:")
    #typepage.addCheckbox("Have all Pokémon Typings randomize",proc {|value| @settings.selftype = value})
    typepage.addCheckbox("Have player's Typings randomize",proc {|value| @settings.selftype = value})
    typepage.addCheckbox("Have opponent's Typings randomize",proc {|value| @settings.opptype = value})
    typepage.addCheckbox("Have Typings random instead of shuffled",proc {|value| @settings.typechaos = value})
    typepage.addCheckbox("Have Type Effectiveness Chart randomize",proc {|value| @settings.typeeff = value})
    typepage.addTextSlider(" Set Type Chart generation             ",
      randGenText, 0, proc {|value| @settings.typeeffgen = randGenHash[value]})
    typepage.addLabel("Shuffle - Values are changed around maintaing the original")
    typepage.addLabel("amount of values.")
    typepage.addLabel("Distributed - Values are changed based on the ratios of")
    typepage.addLabel("original values.")
    typepage.addLabel("Chaos - Values are randomly generated with no regard to the")
    typepage.addLabel("original values.")

    # Making Items page
    itempage = ControlWindow.new(240,0,800-sidewinlength,512)
    itempage.visible = false
    itempage.viewport = viewport
    itempage.addLabel("Item Options:")
    itempage.addCheckbox("Have player's Field Items randomize",proc {|value| @settings.selfitem = value})
    #itempage.addCheckbox("Have opponents's Held Items randomize",proc {|value| @settings.oppitem = value})
    itempage.addCheckbox("Have Items random instead of shuffled",proc {|value| @settings.itemchaos = value})

    folderpage = ControlWindow.new(240,0,800-sidewinlength,512)
    folderpage.visible = false
    folderpage.viewport = viewport
    folderpage.addLabel("Folder Name:")
    folderpage.addButton("#{@settings.name}")

    altpage = ControlWindow.new(240,0,800-sidewinlength,512)
    altpage.visible = false
    altpage.viewport = viewport
    altpage.addLabel("Additional Options:")
    altpage.addCheckbox("Have Abilities be added to an Evolution's Ability list", proc {|value| @settings.abilstore = value})
    altpage.addCheckbox("Have Pokemon retain typing upon Evolution", proc {|value| @settings.typestore = value})
    altpage.addCheckbox("Have movesets be added to Relearner after Evolution", proc {|value| @settings.movestore = value})
    altpage.addLabel("These options have no effect if the respective")
    altpage.addLabel("randomizer options are not enabled")

    return [specpage,movepage,abilpage,typepage,itempage,altpage,folderpage]
  end
# RandomizerSettings.new


  def pbUpdateSidebar(page)
    return if @mainwin == @pages[page]
    #set the old window to invisible, vhange it and set the new one to visible
    @mainwin.visible = false
    @mainwin = @pages[page]
    @mainwin.visible = true
  end
end
