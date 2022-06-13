# Field Catalogue class. Based on xLed's Jukebox Scene class. 
class Scene_FieldNotes
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #-----------------------------------------------------------------------------
  # * Main Processing
  #-----------------------------------------------------------------------------
  def main
    fadein = true
    # Makes the text window
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["background"] = IconSprite.new(0,0)
    @sprites["background"].setBitmap("Graphics/Pictures/navbg")
    @sprites["background"].z=255
    @choices= pbFieldsSeen
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Field Notes"),
       2,-18,256,64,@viewport)
    @sprites["header"].baseColor=Color.new(248,248,248)
    @sprites["header"].shadowColor=Color.new(0,0,0)
    @sprites["header"].windowskin=nil
    @sprites["command_window"] = Window_CommandPokemonWhiteArrow.new(@choices,324)
    @sprites["command_window"].windowskin=nil
    @sprites["command_window"].baseColor=Color.new(248,248,248)
    @sprites["command_window"].shadowColor=Color.new(0,0,0)
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].height = 282
    @sprites["command_window"].width = 324
    @sprites["command_window"].x = 94
    @sprites["command_window"].y = 46
    @sprites["command_window"].z = 256    
#   @button=AnimatedBitmap.new("Graphics/Pictures/pokegearButton")
#   for i in 0...@choices.length
#     x=94
#     y=92 - (@choices.length*24) + (i*48)
#     @sprites["button#{i}"]=PokegearButton.new(x,y,@choices[i],i,@viewport)
#     @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
#     @sprites["button#{i}"].update
#   end
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepares for transition
    Graphics.freeze
    # Disposes the windows
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------  #-----------------------------------------------------------------------------
  def update
#    for i in 0...@sprites["command_window"].commands.length
#      sprite=@sprites["button#{i}"]
#      sprite.selected=(i==@sprites["command_window"].index) ? true : false
#    end
    pbUpdateSpriteHash(@sprites)
    #update command window and the info if it's active
    if @sprites["command_window"].active
      update_command
      return
    end
  end
    
  #-----------------------------------------------------------------------------
  # * Command controls
  #-----------------------------------------------------------------------------
  def update_command
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Switch to map screen
      $scene = Scene_Pokegear.new
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Branch by command window cursor position
      case @sprites["command_window"].index
        when 0
          if $game_switches[600]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg1a",@sprites["command_window"].index,8)
          end
        when 1
          if $game_switches[601]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg2a",@sprites["command_window"].index,8)
          end
        when 2
          if $game_switches[602]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg3a",@sprites["command_window"].index,8)
          end
        when 3
          if $game_switches[603]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg4a",@sprites["command_window"].index,8)
          end
        when 4
          if $game_switches[604]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg5a",@sprites["command_window"].index,8)
          end
        when 5
          if $game_switches[605]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg6a",@sprites["command_window"].index,8)
          end
        when 6
          if $game_switches[606]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg7a",@sprites["command_window"].index,8)
          end
        when 7
          if $game_switches[607]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg8a",@sprites["command_window"].index,8)
          end
        when 8
          if $game_switches[608]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg9a",@sprites["command_window"].index,8)
          end
        when 9
          if $game_switches[609]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg10a",@sprites["command_window"].index,8)
          end
        when 10
          if $game_switches[610]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg11a",@sprites["command_window"].index,8)
          end
        when 11
          if $game_switches[611]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg12a",@sprites["command_window"].index,8)
          end
        when 12
          if $game_switches[612]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg13a",@sprites["command_window"].index,8)
          end
        when 13
          if $game_switches[613]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg14a",@sprites["command_window"].index,8)
          end
        when 14
          if $game_switches[614]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg15a",@sprites["command_window"].index,8)
          end
        when 15
          if $game_switches[615]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg16a",@sprites["command_window"].index,8)
          end
        when 16
          if $game_switches[616]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg17a",@sprites["command_window"].index,8)
          end
        when 17
          if $game_switches[617]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg18a",@sprites["command_window"].index,8)
          end
        when 18
          if $game_switches[618]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg19a",@sprites["command_window"].index,8)
          end
        when 19
          if $game_switches[619]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg20a",@sprites["command_window"].index,8)
          end
        when 20
          if $game_switches[620]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg21a",@sprites["command_window"].index,8)
          end
        when 21
          if $game_switches[621]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg22a",@sprites["command_window"].index,8)
          end
        when 22
          if $game_switches[622]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg23a",@sprites["command_window"].index,8)
          end
        when 23
          if $game_switches[623]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg24a",@sprites["command_window"].index,8)
          end
        when 24
          if $game_switches[624]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg25a",@sprites["command_window"].index,8)
          end
        when 25
          if $game_switches[625]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg26a",@sprites["command_window"].index,8)
          end
        when 26
          if $game_switches[626]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg27a",@sprites["command_window"].index,8)
          end
        when 27
          if $game_switches[627]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg28a",@sprites["command_window"].index,8)
          end
        when 28
          if $game_switches[628]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg29a",@sprites["command_window"].index,8)
          end
        when 29
          if $game_switches[629]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg30a",@sprites["command_window"].index,8)
          end
        when 30
          if $game_switches[630]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg31a",@sprites["command_window"].index,8)
          end
        when 31
          if $game_switches[631]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg32a",@sprites["command_window"].index,8)
          end
        when 32
          if $game_switches[632]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg33a",@sprites["command_window"].index,8)
          end
        when 33
          if $game_switches[633]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg34a",@sprites["command_window"].index,8)
          end
        when 34
          if $game_switches[634]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg35a",@sprites["command_window"].index,8)
          end
        when 35
          if $game_switches[635]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg36a",@sprites["command_window"].index,8)
          end
        when 36
          if $game_switches[636]
            $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg37a",@sprites["command_window"].index,8)
          end
        when 37
          # Switch to map screen
          $scene = Scene_Pokegear.new
          return
      end
      return
    end
  end

  #-----------------------------------------------------------------------------
  # * Determines which Pulses the trainer has data for
  #-----------------------------------------------------------------------------
  def pbFieldsSeen        
    fieldSeen = []
    if ($game_switches[600]) 
      fieldSeen.push("1. Electric Terrain")      
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[601]) 
      fieldSeen.push("2. Grassy Terrain")        
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[602]) 
      fieldSeen.push("3. Misty Terrain")            
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[603]) 
      fieldSeen.push("4. Dark Crystal Cavern")  
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[604]) 
      fieldSeen.push("5. Chess Board")           
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[605])
      fieldSeen.push("6. Big Top Arena")         
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[606])
      fieldSeen.push("7. Burning Field")         
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[607]) 
      fieldSeen.push("8. Swamp Field")           
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[608])
      fieldSeen.push("9. Rainbow Field")         
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[609])
      fieldSeen.push("10. Corrosive Field")      
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[610])
      fieldSeen.push("11. Corrosive Mist Field") 
    else 
      fieldSeen.push("???") 
    end 
    if ($game_switches[611]) 
      fieldSeen.push("12. Desert Field")         
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[612])
      fieldSeen.push("13. Icy Field")            
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[613])
      fieldSeen.push("14. Rocky Field")          
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[614]) 
      fieldSeen.push("15. Forest Field")         
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[615]) 
      fieldSeen.push("16. Super-heated Field")   
    else 
      fieldSeen.push("???") 
    end
    if ($game_switches[616])
  fieldSeen.push("17. Factory Field")        
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[617])
  fieldSeen.push("18. Short-Circuit Field")  
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[618])
  fieldSeen.push("19. Wasteland")            
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[619]) 
  fieldSeen.push("20. Ashen Beach")          
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[620])
  fieldSeen.push("21. Water Surface")        
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[621])
  fieldSeen.push("22. Underwater")           
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[622]) 
  fieldSeen.push("23. Cave")                 
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[623]) 
  fieldSeen.push("24. Glitch Field")         
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[624]) 
  fieldSeen.push("25. Crystal Cavern")       
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[625]) 
  fieldSeen.push("26. Murkwater Surface")    
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[626]) 
  fieldSeen.push("27. Mountain")             
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[627]) 
  fieldSeen.push("28. Snowy Mountain")       
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[628]) 
  fieldSeen.push("29. Holy Field")           
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[629]) 
  fieldSeen.push("30. Mirror Arena")         
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[630]) 
  fieldSeen.push("31. Fairy Tale Field")     
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[631]) 
  fieldSeen.push("32. Dragon's Den")         
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[632]) 
  fieldSeen.push("33. Flower Garden Field")  
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[633]) 
  fieldSeen.push("34. Starlight Arena")      
  else 
  fieldSeen.push("???") 
  end
    if ($game_switches[634]) 
  fieldSeen.push("35. New World")            
  else 
  fieldSeen.push("???")
  end
    if ($game_switches[635]) 
  fieldSeen.push("36. Inverse Field")            
  else 
  fieldSeen.push("???")
  end
    if ($game_switches[636]) 
  fieldSeen.push("37. Psychic Terrain")            
  else 
  fieldSeen.push("???")
  end

    fieldSeen.push("Back")                                                                         
  end                                                           
  
end


# Class for information screen

class Scene_FieldNotes_Info
  
  attr_accessor :background
  attr_accessor :index
  attr_accessor :lines
  attr_accessor :menu_index
  attr_accessor :screen

  def initialize(background, index, lines, menu_index = 0, screen = 0)
    @background = background
    @index      = index
    @lines      = lines
    @menu_index = menu_index
    @screen     = screen
    if @menu_index >= @lines
      @menu_index = @lines - 1
    end
  end
  
  def main
    text = []
    for i in 0...lines
      text.push("")
    end
    fadein = true
    # Makes the text window
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["background"] = IconSprite.new(0,0)
    @sprites["background"].setBitmap(background)
    @sprites["background"].z=255
    @sprites["command_window"] = Window_CommandPokemonWhiteArrow.new(text,324)
    @sprites["command_window"].windowskin=nil
    @sprites["command_window"].baseColor=Color.new(248,248,248)
    @sprites["command_window"].shadowColor=Color.new(0,0,0)
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].height = 300
    @sprites["command_window"].width = 324
    @sprites["command_window"].x = 4
    @sprites["command_window"].y = 46
    @sprites["command_window"].z = 256        
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepares for transition
    Graphics.freeze
    # Disposes the windows
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
  def update
    pbUpdateSpriteHash(@sprites)
    update_command
  end  

  def update_command
    case @index
      when 0
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg1b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg1a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg1c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg1b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 1
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg2b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg2a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg2c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg2b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 2
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg3b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg3a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg3c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg3b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 3
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg4b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg4a",@index,8,@sprites["command_window"].index,0)
            end
        end
      when 4
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg5b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg5a",@index,8,@sprites["command_window"].index,0)
            end
        end
      when 5
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg6b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg6a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg6c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg6b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 6
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg7b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg7a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg7c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg7b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 7
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg8b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg8a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg8c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg8b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 8
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg9b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg9a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg9c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg9b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 9
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg10b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg10a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg10c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg10b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 10
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg11b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg11a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg11c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg11b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 11
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg12b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg12a",@index,8,@sprites["command_window"].index,0)
            end
        end
      when 12
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg13b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg13a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg13c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg13b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 13
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg14b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg14a",@index,8,@sprites["command_window"].index,0)
            end
        end
      when 14
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg15b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg15a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg15c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg15b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 15
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg16b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg16a",@index,8,@sprites["command_window"].index,0)
            end
        end
      when 16
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg17b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg17a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg17c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg17b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 17
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg18b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg18a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg18c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg18b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 18
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg19b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg19a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg19c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg19b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 19
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg20b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg20a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg20c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg20b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 20
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg21b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg21a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg21c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg21b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 21
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg22b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg22a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg22c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg22b",@index,8,@sprites["command_window"].index,1)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg22d",@index,8,@sprites["command_window"].index,3)
            end
          when 3
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg22c",@index,8,@sprites["command_window"].index,2)
            end
        end
      when 22
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg23b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg23a",@index,8,@sprites["command_window"].index,0)
            end
        end
      when 23
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg24b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg24a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg24c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg24b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 24
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg25b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg25a",@index,8,@sprites["command_window"].index,0)
            end
        end
      when 25
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg26b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg26a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg26c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg26b",@index,8,@sprites["command_window"].index,1)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg26d",@index,8,@sprites["command_window"].index,3)
            end
          when 3
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg26c",@index,8,@sprites["command_window"].index,2)
            end
        end
      when 26
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg27b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg27a",@index,8,@sprites["command_window"].index,0)
            end
        end
      when 27
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg28b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg28a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg28c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg28b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 28
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg29b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg29a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg29c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg29b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 29
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg30b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg30a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg30c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg30b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 30
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg31b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg31a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg31c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg31b",@index,8,@sprites["command_window"].index,1)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg31d",@index,8,@sprites["command_window"].index,3)
            end
          when 3
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg31c",@index,8,@sprites["command_window"].index,2)
            end
        end
      when 31
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg32b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg32a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg32c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg32b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 32
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg33b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg33a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg33c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg33b",@index,8,@sprites["command_window"].index,1)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg33d",@index,8,@sprites["command_window"].index,3)
            end
          when 3
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg33c",@index,8,@sprites["command_window"].index,2)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg33e",@index,8,@sprites["command_window"].index,4)
            end
          when 4
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg33d",@index,8,@sprites["command_window"].index,3)
            end
        end
      when 33
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg34b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg34a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg34c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg34b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 34
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg35b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg35a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg35c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg35b",@index,8,@sprites["command_window"].index,1)
            end
        end
      when 35
        case @screen
          when 0
            # No other screens
        end
      when 36 
        case @screen
          when 0
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg37b",@index,8,@sprites["command_window"].index,1)
            end
          when 1
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg37a",@index,8,@sprites["command_window"].index,0)
            end
            if Input.trigger?(Input::RIGHT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg37c",@index,8,@sprites["command_window"].index,2)
            end
          when 2
            if Input.trigger?(Input::LEFT)
              $scene = Scene_FieldNotes_Info.new("Graphics/Pictures/Fields/fieldbg37b",@index,8,@sprites["command_window"].index,1)
            end
        end
    end
            
# If B button was pressed
    if Input.trigger?(Input::B)
      # Switch to map screen
      $scene = Scene_FieldNotes.new(@index)
      return
    end  
    if Input.trigger?(Input::C) || Input.trigger?(Input::A)
      case @index # Which field it is
        when 0 # Electric Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Electric Surge, Electric Terrain (5 turns), Stoked Sparksurfer, Ion Deluge (3 turns), when the attacker does not hold an Everstone."))
                when 3
                  Kernel.pbMessage(_INTL("...when attacker is grounded."))
                when 4
                  Kernel.pbMessage(_INTL("Explosion, Hurricane, Hydro Vortex, Muddy Water, Selfdestruct, Smack Down, Surf, Thousand Arrows"))
                when 6
                  Kernel.pbMessage(_INTL("Charge, Eerie Impulse"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Explosion, Hurricane, Muddy Water, Selfdestruct, Smack Down, Surf, Thousand Arrows"))
                when 1
                  Kernel.pbMessage(_INTL("Magnet Bomb"))
                when 5
                  Kernel.pbMessage(_INTL("Mud Sport, Tectonic Rage"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Boosts Defense and applies Charge to the user."))
              end
          end
        when 1 # Grassy Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...when grounded."))
                when 2
                  Kernel.pbMessage(_INTL("Grassy Surge, Grassy Terrain (5 turns), Bloom Doom when not in Forest or Flower Garden fields (3 turns)"))
                when 3
                  Kernel.pbMessage(_INTL("...when attacker is grounded."))
                when 4
                  Kernel.pbMessage(_INTL("...when target is grounded."))
                when 6
                  Kernel.pbMessage(_INTL("Fairy Wind, Silver Wind"))
                when 7
                   Kernel.pbMessage(_INTL("Earthquake, Magnitude, Bulldoze, Muddy Water, Surf"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Coil, Growth"))
                when 4
                  Kernel.pbMessage(_INTL("...when Eruption, Flame Burst, Fire Pledge, Heat Wave, Inferno Overdrive, Lava Plume, or Searing Shot is used in the absence of Rain or Water Sport."))
                when 5
                  Kernel.pbMessage(_INTL("...when Sludge Wave or Acid Downpour is used."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Boosts Defense and applies Ingrain to the user."))
              end
          end
        when 2 # Misty Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Misty Surge, Misty Terrain (5 turns), Mist (3 turns), when the attacker does not hold an Everstone."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Aura Sphere, Clear Smog, Dazzling Gleam, Doom Desire, Fairy Wind, Icy Wind, Magical Leaf, Moonblast, Mist Ball, Moongeist Beam, Mystical Fire, Silver Wind, Smog, Steam Eruption"))
                when 1
                  Kernel.pbMessage(_INTL("Dark Pulse, Night Daze, Shadow Ball"))
                when 3
                  Kernel.pbMessage(_INTL("Aromatic Mist, Cosmic Power"))
                when 7
                  Kernel.pbMessage(_INTL("Defog, Gust, Hurricane, Razor Wind, Supersonic Skystrike, Tailwind, Twister, Whirlwind"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("...when Acid Downpour is used, or when one of these moves is used twice: Clear Smog, Poison Gas, Smog"))
                when 1
                  Kernel.pbMessage(_INTL("Explosion, Selfdestruct"))
                when 3
                  Kernel.pbMessage(_INTL("...when Pokemon is sent out."))
                when 7
                  Kernel.pbMessage(_INTL("Boosts Sp.Def and applies Healing Wish to the user."))
              end
          end
        when 3 # Dark Crystal Cavern
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Aurora Beam, Dark Pulse, Dazzling Gream, Doom Desire, Flash Cannon, Luster Purge, Mirror Shot,  Moongeist Beam, Night Daze, Night Slash, Power Gem, Shadow Ball, Shadow Bone, Shadow Claw, Shadow Force, Shadow Punch, Shadow Sneak, Signal Beam, Technoblast"))
                when 2
                  Kernel.pbMessage(_INTL("Flash"))
                when 6
                  Kernel.pbMessage(_INTL("Solar Beam, Solar Blade"))
                when 7
                  Kernel.pbMessage(_INTL("...when the weather is Sunny, for as long as the sun lasts."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("...when Bulldoze, Earthquake, Magnitude or Tectonic Rage is used."))
                when 1
                  Kernel.pbMessage(_INTL("Black Hole Eclipse, Prismatic Laser"))
                when 3
                  Kernel.pbMessage(_INTL("Prism Armor and Shadow Shield reduce incoming damage by x0.5"))
                when 7
                  Kernel.pbMessage(_INTL("Boosts Sp.Def and applies Magic Coat to the user."))
              end
          end
        when 4 # Chess Arena
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Ancient Power, Psychic, Strength, Continental Crush"))
                when 4
                  Kernel.pbMessage(_INTL("...when the target is confused, or has one of these abilities: Klutz, Oblivious, Simple, Unaware"))
                when 5
                  Kernel.pbMessage(_INTL("...when the target has one of these abilities: Adaptability, Anticipation, Telepathy, Synchronize"))
                when 6
                  Kernel.pbMessage(_INTL("Calm Mind, Nasty Plot"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Fake Out, Feint, Feint Attack"))
                when 2
                  Kernel.pbMessage(_INTL("Stomping Tantrum, Tectonic Rage"))
                when 6
                  Kernel.pbMessage(_INTL("Boosts Sp.Atk and applies Magic Coat to the user."))
              end
          end
        when 5 # Big Top Arena
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("All physical fighting moves, Body Slam, Bounce, Brutal Swing, Bulldoze, Continental Crush, Crabhammer, Dragon Hammer, Dragon Rush, Dual Chop, Earthquake, Giga Impact, Heat Crash, Heavy Slam, High Horse Power, Ice Hammer, Icicle Crash, Iron Tail, Magnitude, Meteor Mash, Pound, Sky Drop, Slam, Smack Down, Stomp, Stomping Tantrum, Strength, Wood Hammer"))
                when 2
                  Kernel.pbMessage(_INTL("Damage rolls set multipliers between x0.5 and x3"))
                when 3
                  Kernel.pbMessage(_INTL("...when the attacker has one of these abilities: Sheer Force, Guts, Huge Power, Pure Power"))
                when 4
                  Kernel.pbMessage(_INTL("Boosted attack increases the chance of high rolls."))
                  Kernel.pbMessage(_INTL("Lowered attack decreases the chance of high rolls, regardless of ability."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Acrobatics, Fiery Dance, Fire Lash, First Impression, Fly, Petal Dance, Power Whip, Revelation Dance, Vine Whip"))
                when 2
                  Kernel.pbMessage(_INTL("Dragon Dance, Quiver Dance, Swords Dance"))
                when 6
                  Kernel.pbMessage(_INTL("...of both the target and user."))
                when 7
                  Kernel.pbMessage(_INTL("...when a Dance move is used on its own turn."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 3
                  Kernel.pbMessage(_INTL("Boosts Attack and applies Helping Hand to the user."))
        end
          end
        when 6 # Burning Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...when grounded and not Fire type."))
                when 2
                  Kernel.pbMessage(_INTL("...when one of these abilities is active: Flame Body, Flare Boost, Flash Fire, Heatproof, Magma Armor, Water Bubble, Water Veil."))
                when 3
                  Kernel.pbMessage(_INTL("...when one of these abilities is active: Fluffy, Grass Pelt, Ice Body, Leaf Guard"))
                when 5
                  Kernel.pbMessage(_INTL("...when attacker is grounded."))
                when 6
                  Kernel.pbMessage(_INTL("...when target is grounded."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Continental Crush, Defog, Fust, Hurricane, Hydro Vortex, Muddy Water, Oceanic Operetta, Razor Wind, Sand Tomb, Sludge Wave, Sparkling Aria, Surf, Tailwind, Water Pledge, Water Sport, Water Spout, Whirlwind"))
                when 2
                  Kernel.pbMessage(_INTL("Blaze, Flare Boost, Flash Fire"))
                when 6
                  Kernel.pbMessage(_INTL("Clear Smog, Smack Down, Smog, Thousand Arrows"))
                when 7
                  Kernel.pbMessage(_INTL("Smack Down, Thousand Arrows"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Clear Smog, Smog"))
                when 5
                  Kernel.pbMessage(_INTL("Boosts Attack, Special Attack and Speed, but applies Fire Spin to the user."))
              end
          end
        when 7 # Swamp
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("...when airborne."))
                when 4
                  Kernel.pbMessage(_INTL("...unless user has Poison or Steel type."))
                when 7
                  Kernel.pbMessage(_INTL("...when target is grounded."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Brine, Gunk Shot, Hydro Vortex, Mud Bomb, Mud Shot, Mud Slap, Muddy Water, Sludge Wave, Smack Down, Surf, Thousand Arrows"))
                when 1
                  Kernel.pbMessage(_INTL("Explosion, Selfdestruct"))
                when 5
                  Kernel.pbMessage(_INTL("...each turn."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Boosts Defense and Sp. Def and applies Ingrain to the user."))
              end
          end
        when 8 # Rainbow Field
          case @screen # Which screen it's at
            when 0
              # No details
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Aurora Beam, Dragon Pulse, Fire Pledge, Fleur Cannon, Grass Pledge, Heart Stamp, Hidden Power, Judgment, Mist Ball, Moonblast, Mystical Fire, Prismatic Laser, Relic Song, Sacred Fire, Secret Power, Silver Wind, Sparkling Aria, Tri Attack, Twinkle Tackle, Water Pledge, Weather Ball, Zen Headbutt"))
                when 2
                  Kernel.pbMessage(_INTL("Dark Pulse, Never-ending Nightmare, Night Daze, Shadow Ball"))
                when 3
                  Kernel.pbMessage(_INTL("Cosmic Power, Meditate"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 7
                  Kernel.pbMessage(_INTL("Boosts Sp.Atka and applies Healing Wish to the user."))
        end
          end
        when 9 # Corrosive Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...when grounded and not Poison or Steel type."))
                when 2
                  Kernel.pbMessage(_INTL("...when one of these abilities is active: Immunity, Poison Heal, Toxic Boost, Wonder Guard"))
                when 3
                  Kernel.pbMessage(_INTL("...unless Poison or Steel type."))
                when 4
                  Kernel.pbMessage(_INTL("...unless Poison or Steel type."))
                when 5
                  Kernel.pbMessage(_INTL("...when grounded, activates Poison Heal and Toxic Boost."))
                when 7
                  Kernel.pbMessage(_INTL("Mud Bomb, Mud Shot, Mud Slap, Muddy Water, Smack Down, Thousand Arrows, Whirlpool"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Mud Bomb, Mud Shot, Mud Slap, Muddy Water, Smack Down, Thousand Arrows, Whirlpool"))
                when 1
                  Kernel.pbMessage(_INTL("Acid, Acid Spray, Grass Knot"))
                when 2
                  Kernel.pbMessage(_INTL("Acid Armor"))
                when 6
                  Kernel.pbMessage(_INTL("...unless Poison or Steel Type, or has Wonder Guard."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("...when Seed Flare is used."))
                when 7
                  Kernel.pbMessage(_INTL("Boosts Attack and applies Baneful Bunker to the user."))
              end
          end
        when 10 # Corrosive Mist
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Corrosive Mist settles on the field!"))
                when 2
                  Kernel.pbMessage(_INTL("...unless Poison or Steel type."))
                when 3
                  Kernel.pbMessage(_INTL("...unless Poison or Steel type."))
                when 4
                  Kernel.pbMessage(_INTL("All special flying attacks, Bubble, Bubblebeam, Energy Ball"))
                when 5
                  Kernel.pbMessage(_INTL("Acid Spray, Bubble, Bubblebeam, Clear Smog, Smog, Sparkling Aria"))
                when 6
                  Kernel.pbMessage(_INTL("Acid Armor"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 7
                  Kernel.pbMessage(_INTL("...each turn."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Defog, Eruption, Explosion, Fire Pledge, Flame Burst, Gust, Heat Wave, Hurricane, Lava Plume, Razor Wind, Searing Shot, Selfdestruct, Supersonic Skystrike, Tailwind, Twister, Whirlwind"))
                when 1
                  Kernel.pbMessage(_INTL("...when one of these moves is used: Eruption, Explosion, Fire Pledge, Flame Burst, Heat Wave, Inferno Overdrive, Lava Plume, Searing Shot, Selfdestruct."))
                  Kernel.pbMessage(_INTL("Pokemon may survive from full health with 1 HP if Endure or Sturdy is active."))
                  Kernel.pbMessage(_INTL("Pokemon with Flash Fire, or that are behind Protect moves including Wide Guard will not take damage."))
                when 2
                  Kernel.pbMessage(_INTL("...when Gravity is used."))
                when 6
                  Kernel.pbMessage(_INTL("Boosts Attack and Sp.Atk and badly poisons the user."))
        end
          end
        when 11 # Desert Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Sand Force, Sand Rush, Sand Veil"))
                when 4
                  Kernel.pbMessage(_INTL("Burn Up, Dig, Heat Wave, Needle Arm, Pin Missile, Sand Tomb, Thousand Waves"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("...when attacker is grounded."))
                when 1
                  Kernel.pbMessage(_INTL("...when target is grounded."))
                when 6
                  Kernel.pbMessage(_INTL("Boosts Defense, Sp.Def and Speed but applies Sand Tomb to the user."))
              end
          end
        when 12 # Icy Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...when attacker is grounded, these moves boost priority: All attacking physical-contact priority moves, Defense Curl, Feint, Lunge, Rollout, Steamroller"))
                when 5
                  Kernel.pbMessage(_INTL("Scald, Steam Eruption"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("...when Eruption, Fire Pledge, Flame Burst, Heat Wave, Inferno Overdrive, Lava Plume, or Searing Shot is used."))
                when 1
                  Kernel.pbMessage(_INTL("...when Bulldoze, Earthquake, or Magnitude is used."))
                when 3
                  Kernel.pbMessage(_INTL("Ice Body, Snow Cloak"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 3
                  Kernel.pbMessage(_INTL("Boosts Speed two stages."))
              end
          end
        when 13 # Rocky Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...when evasion is increased or substitute is up, attacks that can be blocked by Bulletproof can be dodged behind rocks."))
                when 2
                  Kernel.pbMessage(_INTL("...unless user has Rock Head."))
                when 4
                  Kernel.pbMessage(_INTL("...unless target has Steadfast or Sturdy."))
                when 5
                  Kernel.pbMessage(_INTL("Bulldoze, Earthquake, Magnitude, Rock Climb, Strength"))
                when 6
                  Kernel.pbMessage(_INTL("Accelerock, Bulldoze, Earthquake, Magnitude, Rock Climb, Strength"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 6
                  Kernel.pbMessage(_INTL("Boosts Defense and Sp.Def, but damages the user with Stealth Rocks."))
        end
          end
        when 14 # Forest
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Grass Pelt, Leaf Guard, Overgrow, Swarm"))
                when 4
                  Kernel.pbMessage(_INTL("Attack Order"))
                when 6
                  Kernel.pbMessage(_INTL("Muddy Water, Surf"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Defend Order, Growth"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("...when Eruption, Fire Pledge, Flame Burst, Heat Wave, Inferno Overdrive, Lava Plume, or Searing Shot is used in the absence of Rain or Water Sport."))
                when 4
                  Kernel.pbMessage(_INTL("Boosts Attack and applies Spiky Shield to the user."))
        end
          end
        when 15 # Superheated Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 4
                  Kernel.pbMessage(_INTL("Muddy Water, Surf, Water Pledge, Water Spout"))
                when 5
                  Kernel.pbMessage(_INTL("Hydro Vortex, Muddy Water, Oceanic Operetta, Sparkling Aria, Surf, Water Pledge, Water Sport, and Water Spout generate steam, lowering all active Pokemon's Accuracy."))
                when 6
                  Kernel.pbMessage(_INTL("Scald, Steam Eruption"))
                when 7
                  Kernel.pbMessage(_INTL("...when Eruption, Fire Pledge, Flame Burst, Heat Wave, Lava Plume, or Searing Shot is used in the absence of Rain or Water Sport."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Blizzard, Glaciate, Subzero Slammer"))
                when 2
                  Kernel.pbMessage(_INTL("Applies to Outrage, Petal Dance, and Thrash"))
                when 6
                  Kernel.pbMessage(_INTL("Boosts Defense and applies Shell Trap to the user."))
              end
          end
        when 16 # Factory Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 5
                  Kernel.pbMessage(_INTL("Steamroller, Technoblast"))
                when 6
                  Kernel.pbMessage(_INTL("Flash Cannon, Gear Grind, Gyro Ball, Magnet Bomb"))
                when 7
                  Kernel.pbMessage(_INTL("Autotomize, Iron Defense, Metal Sound, Shift Gear"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...when Bulldoze, Discharge, Earthquake, Explosion, Fissure, Gigavolt Havoc, Ion Deluge, Magnitude, Selfdestruct or Tectonic Rage is used."))
                  Kernel.pbMessage(_INTL("Discharge additionally can alternate between the Short-circuit and Factory Fields for each instance of damage in double battles."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Boosts Sp.Atk and applies Laser Focus to the user."))
              end
          end
        when 17 # Shortcircuit Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 4
                  Kernel.pbMessage(_INTL("Damage rolls set multipliers between x0.5 and x2"))
                when 6
                  Kernel.pbMessage(_INTL("Dark Pulse, Night Daze, Night Slash, Shadow Ball, Shadow Bone, Shadow Claw, Shadow Force, Shadow Punch, Shadow Sneak"))
                when 7
                  Kernel.pbMessage(_INTL("Flash Cannon, Gear Grind, Gyro Ball, Hydro Vortex, Magnet Bomb, Muddy Water, Surf"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Flash Cannon, Gear Grind, Gyro Ball, Magnet Bomb, Muddy Water, Surf"))
                when 1
                  Kernel.pbMessage(_INTL("...when Charge Beam, Discharge, Gigavolt Havoc, Ion Deluge, Parabolic Charge, or Wild Charge is used."))
                  Kernel.pbMessage(_INTL("Discharge additionally can alternate between the Short-circuit and Factory Fields for each instance of damage in double battles."))
                when 2
                  Kernel.pbMessage(_INTL("Flash, Metal Sound"))
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 3
                  Kernel.pbMessage(_INTL("Boosts Sp.Def and applies Magnet Rise to the user."))
              end
          end
        when 18 # Wasteland
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Consumed hazards return at the end of the turn, returning a special effect to the side they were on:"))
                  Kernel.pbMessage(_INTL("Stealth Rocks deal type-scaling Rock damage double the normal effect to Pokemon."))
                  Kernel.pbMessage(_INTL("Spikes deal 33% max HP to grounded Pokemon."))
                  Kernel.pbMessage(_INTL("Toxic Spikes deal 12.5% max HP to grounded non-Poison/Steel types, and inflicts poison."))
                  Kernel.pbMessage(_INTL("Sticky Web severely lowers Pokemon's speed."))
                when 2
                  Kernel.pbMessage(_INTL("Gunk Shot, Sludge, Sludge Bomb, Sludge Wave"))
                when 3
                  Kernel.pbMessage(_INTL("Acid Downpour, Gunk Shot, Sludge, Sludge Bomb, Sludge Wave inflict a random status unless target has Poison or Steel type, or one of these abilities: Immunity, Poison Heal, Toxic Boost"))
                when 4
                  Kernel.pbMessage(_INTL("Effect Spore, Poison Point, Stench"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 5
                  Kernel.pbMessage(_INTL("Mud Bomb, Mud Shot, Mud Slap, Power Whip, Vine Whip"))
                when 6
                  Kernel.pbMessage(_INTL("Mud Bomb, Mud Slap, Mud Shot"))
                when 7
                  Kernel.pbMessage(_INTL("Bulldoze, Earthquake, Magnitude"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 5
                  Kernel.pbMessage(_INTL("Boosts Attack and Sp.Atk and applies a random status to the user."))
        end
          end
        when 19 # Ashen Beach
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("All Special Flying attacks, Fire Spin, Leaf Tornado, Razor Wind, Twister, and Whirlpool stir up ash, lowering all active Pokemon's Accuracy."))
                when 3
                  Kernel.pbMessage(_INTL("...when the target does not have Unnerve, and one of these abilities is active: Own Tempo, Pure Power, Sand Veil, Steadfast"))
                when 4
                  Kernel.pbMessage(_INTL("Sand Force, Sand Rush, Sand Veil"))
                when 5
                  Kernel.pbMessage(_INTL("Calm Mind, Kinesis, Meditate, Sand Attack"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Mud Bomb, Mud Shot, Mud Slap"))
                when 2
                  Kernel.pbMessage(_INTL("Hidden Power, Land's Wrath, Muddy Water, Sand Tomb, Strength, Surf, Thousand Waves"))
                when 3
                  Kernel.pbMessage(_INTL("Aura Sphere, Focus Blast, Stored Power, Zen Headbutt"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Boosts Critical Hit rate and applies Laser Focus to the user."))
        end
          end
        when 20 # Water Surface
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...unless Water type, airborne, or the ability Swift Swim is active."))
                when 6
                  Kernel.pbMessage(_INTL("Hydration, Schooling, Surge Sufer, Swift Swim, Torrent, and Water Compaction each turn."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Dry Skin, Water Absorb"))
                when 7
                  Kernel.pbMessage(_INTL("...when target is grounded."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Dive, Hydro Vortex, Muddy Water, Sludge Wave, Surf, Whirlpool"))
                when 1
                  Kernel.pbMessage(_INTL("...when Dive or Gravity is used."))
                when 2
                  Kernel.pbMessage(_INTL("...when Acid Downpour is used, or Sludge Wave is used twice."))
                when 3
                  Kernel.pbMessage(_INTL("...when Blizzard, Glaciate or Subzero Slammer is used."))
                when 7
                  Kernel.pbMessage(_INTL("Boosts Sp.Def and applies Aqua Ring to the user."))
              end
          end
        when 21 # Underwater
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...unless Water type or Swift Swim is active."))
                when 5
                  Kernel.pbMessage(_INTL("...unless attack is Water type."))
                when 6
                  Kernel.pbMessage(_INTL("...when Pokemon is weak to Water."))
                when 7
                  Kernel.pbMessage(_INTL("...when the abilities Magic Guard or Swift Swim are active."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("...when the abilities Magma Armor or Flame Body are active."))
                when 3
                  Kernel.pbMessage(_INTL("Hydration, Schooling, Surge Surfer, Swift Swim, Torrent and Water Compaction each turn"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 4
                  Kernel.pbMessage(_INTL("Sludge Wave, Water Pulse"))
                when 5
                  Kernel.pbMessage(_INTL("...when Bounce, Dive, Fly, or Sky Drop is used."))
                when 6
                  Kernel.pbMessage(_INTL("...when Acid Downpour is used, or Sludge Wave is used twice."))
              end
            when 3
              case @sprites["command_window"].index #Which line was selected
                when 3
                  Kernel.pbMessage(_INTL("Boosts Speed and applies Soak to the user."))
              end
          end
        when 22 # Cave
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("...when Continental Crush, Bulldoze, Earthquake, Magnitude or Tectonic Rage are used twice. "))
                  Kernel.pbMessage(_INTL("Pokemon using Endure, or having Sturdy may survive with 1 HP from full health."))
                  Kernel.pbMessage(_INTL("Pokemon with Battle Armor and Shell Armor take 50% damage."))
                  Kernel.pbMessage(_INTL("Pokemon with Prism Armor or Solid Rock take 33% damage."))
                  Kernel.pbMessage(_INTL("Pokemon behind protect moves including Wide Guard, or having Bulletproof or Rock Head are immune to the damage."))
                when 7
                  Kernel.pbMessage(_INTL("...when non-contact."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("...when Diamond Storm or Power Gem is used."))
                when 6
                  Kernel.pbMessage(_INTL("Boosts Defense and damages the user with Stealth Rocks."))
              end
          end
        when 23 # Glitch Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Attacks base their physical-status on the pre-4th generation type determination."))
                when 2
                  Kernel.pbMessage(_INTL("Special Attacks, for both the attacker and defender, calculate off of the higher stat between SpAtk and SpDef."))
                when 4
                  Kernel.pbMessage(_INTL("Dragon always deals neutral damage."))
                  Kernel.pbMessage(_INTL("Bug now hits Poison types super-effectively."))
                  Kernel.pbMessage(_INTL("Ice now hits Fire types neutrally."))
                  Kernel.pbMessage(_INTL("Ghost now cannot hit psychic types."))
                  Kernel.pbMessage(_INTL("Poison now hits Bug types super-effectively."))
                when 5
                  Kernel.pbMessage(_INTL("Critical hit rate increases by one stage if attacker is faster than the target."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...selects moves of 70 base power or higher only."))
                when 4
                  Kernel.pbMessage(_INTL("Created for 5 turns when Conversion and Conversion2 are used in succession."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Boosts Defense and Sp.Def and makes user ??? type."))
              end
          end
        when 24 # Crystal Cavern
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("The cave is littered with crystals."))
                when 2
                  Kernel.pbMessage(_INTL("Ancient Power, Diamond Storm, Judgment, Multi Attack, Power Gem, Prismatic Laser, Rock Climb, Rock Smash, Rock Tomb, Strength"))
                when 3
                  Kernel.pbMessage(_INTL("Rock type attacks, as well as Judgment, Rock Climb, and Strength gain a random typing between Fire, Water, Grass and Psychic."))
                when 5
                  Kernel.pbMessage(_INTL("Aurora Beam, Dazzling Gleam, Doom Desire, Flash Cannon, Luster Purge, Mirror Shot, Moongeist Beam, Multi Attack, Prismatic Laser, Signal Beam, Technoblast"))
                when 6
                  Kernel.pbMessage(_INTL("...when Dark Void, Dark Pulse, or Night Daze is used."))
                when 7
                  Kernel.pbMessage(_INTL("...when Bulldoze, Earthquakeor Magnitude or Tectonic Rage is used."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Stealth Rocks randomly applies either Fire, Water, Grass or Psychic type damage."))
                when 5
                  Kernel.pbMessage(_INTL("Camouflage may choose one of Fire, Water, Grass or Psychic typings."))
                when 6
                  Kernel.pbMessage(_INTL("Secret Power may choose a random status between Burn, Freeze, Sleep or Confusion."))
                when 7
                  Kernel.pbMessage(_INTL("Boosts Sp.Atk and applies Magic Coat to the user."))
              end
          end
        when 25 # Murkwater Surface
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...unless Water type, airborne, or the ability Swift Swim is active."))
                when 2
                  Kernel.pbMessage(_INTL("...when grounded, and not Poison or Steel type. "))
                when 3
                  Kernel.pbMessage(_INTL("...when one of the following abilities is active: Immunity, Magic Guard, Poison Heal, Toxic Boost, Wonder Guard"))
                when 4
                  Kernel.pbMessage(_INTL("...when Pokemon is underwater (x4) or has one of the following abilities (x2): Dry Skin, Flame Body, Magma Armor, Water Absorb"))
                when 5
                  Kernel.pbMessage(_INTL("...when grounded and Poison type."))
                when 6
                  Kernel.pbMessage(_INTL("...when grounded and Poison type."))
                when 7
                  Kernel.pbMessage(_INTL("...when grounded, activates Merciless, Poison Heal, Schooling, Surge Surfer, Swift Swim, Toxic Boost and Water Compaction each turn."))
              end
            when 1
              # No Details
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Mud Bomb, Mud Shot, Mud Slap, Thousand Waves"))
                when 1
                  Kernel.pbMessage(_INTL("Smack Down"))
                when 2
                  Kernel.pbMessage(_INTL("Acid, Acid Spray, Brine, Mud Bomb, Mud Shot, Mud Slap, Smack Down, Thousand Waves"))
              end
            when 3
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...when Whirlpool is used."))
                when 2
                  Kernel.pbMessage(_INTL("...when Blizzard, Glaciate or Subzero Slammer is used."))
                when 6
                  Kernel.pbMessage(_INTL("Applies Soak and Aqua Ring, and poisons the user."))
              end
          end
        when 26 # Mountain
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Adieu to disappointment and spleen."))
                when 3
                  Kernel.pbMessage(_INTL("Avalanche, Circle Throw, Eruption, Fairy Wind, Icy Wind, Ominous Wind, Razor Wind, Silver Wind, Storm Throw, Thunder, Twister, Vital Throw"))
                when 4
                  Kernel.pbMessage(_INTL("...when Strong Winds are active, further boosts all Special Flying attacks, as well as Fairy Wind, Gust, Icy Wind, Ominous Wind, Razor Wind, Silver Wind, Twister"))
                when 7
                  Kernel.pbMessage(_INTL("...when Blizzard or Subzero Slammer is used, or after three consecutive turns of Hail weather."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 7
                  Kernel.pbMessage(_INTL("Boosts Attack, but lowers Accuracy."))
              end
          end
        when 27 # Snowy Mountain
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("The snow glows white on the mountain..."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("...when Strong Winds are active, further boosts all Special Flying attacks, as well as Fairy Wind, Gust, Icy Wind, Ominous Wind, Razor Wind, Silver Wind, Twister"))
                when 3
                  Kernel.pbMessage(_INTL("Scald, Steam Eruption"))
                when 6
                  Kernel.pbMessage(_INTL("Ice Body, Slush rush, Snow Cloak"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("...when Eruption, Fire Pledge, Flame Burst, Heat Wave, Inferno Overdrive, Lava Plume, or Searing Shot is used."))
                when 7
                  Kernel.pbMessage(_INTL("Boosts Sp.Atk, but lowers Accuracy."))
              end
          end
        when 28 # Holy Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Normal type attacks hit Ghost and Dark type Pokemon for super-effective damage."))
                when 3
                  Kernel.pbMessage(_INTL("All Special Dark attacks"))
                when 5
                  Kernel.pbMessage(_INTL("All Special Normal attacks, as well as Ancient Power, Judgment, Magical Leaf, Mystical Fire, and Sacred Fire"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Aeroblast, Crush Grip, Doom Desire, Dragon Ascent, Fleur Canon, Genesis Supernova, Hyperspace Hole, Land's Wrath, Luster Purge, Mist Ball, Moongeist Beam, Origin Pulse, Precipice Blades, Prismatiic Laser, Psycho Boost, Psystrike, Relic Song, Roar of Time, Secret Sword, Sunsteel Strike, Spacial Rend"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 4
                  Kernel.pbMessage(_INTL("Boosts Sp.Atk and applies Magic Coat to the user."))
              end
          end
        when 29 # Mirror Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Mirror, Mirror, on the field, who shalt this fractured power wield?"))
                when 1
                  Kernel.pbMessage(_INTL("The critical hit rate is increased by one stage for each of the attacker's Evasion/Accuracy buffs, and the target's Evasion/Accuracy de-buffs."))
                when 3
                  Kernel.pbMessage(_INTL("Single-targeted, special, non-contact attacks that would miss will sometimes be reflected, hitting the target anyway."))
                when 4
                  Kernel.pbMessage(_INTL("Bubblebeam, Charge Beam, Fleur Cannon, Hyper Beam, Ice Beam, Origin Pulse, Moongeist Beam, Psybeam, Solar Beam, Tri-Attack"))
                when 5
                  Kernel.pbMessage(_INTL("Missing a physical contact attack causes 1/4 Max HP recoil damage."))
                when 6
                  Kernel.pbMessage(_INTL("Color Change, Illusion, Magic Bounce, Sand Veil, Snow Cloak, and Tangled Feet boost evasion which switched in."))
                when 7
                  Kernel.pbMessage(_INTL("Brightpowder and Lax Incense boost Evasion when switched in."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Illuminate lowers opponents' Accuracy on switch-in"))
                when 1
                  Kernel.pbMessage(_INTL("...when an attack is successfully bounced."))
                when 4
                  Kernel.pbMessage(_INTL("Mirror Coat increases Evasion, Defense and SpDef on successful use."))
                when 5
                  Kernel.pbMessage(_INTL("Mirror Move increases Accuracy, Attack and SpAtk on successful use."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...and never miss: Aurora Beam, Dazzling Gleam, Doom Desire, Flash Cannon, Luster Purge, Prismatic Laser, Signal Beam, Technoblast"))
                when 2
                  Kernel.pbMessage(_INTL("Double Team, Flash"))
                when 3
                  Kernel.pbMessage(_INTL("...and damages all active Pokemon for 1/2 their max HP: Boomburst, Bulldoze, Earthquake, Hyper Voice, Magnitude, Tectonic Rage."))
                  Kernel.pbMessage(_INTL("Pokemon behind protect moves including Wide Guard, or having Shell Armor or Battle Armor are immune to the shatter damage."))
                when 7
                  Kernel.pbMessage(_INTL("Boosts Evasion two stages."))
              end
          end
        when 30 # Fairy Tale Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 6
                  Kernel.pbMessage(_INTL("Battle Armor, Power of Alchemy and Shell Armor boost Defense upon switching in."))
                when 7
                  Kernel.pbMessage(_INTL("Magic Guard, Magic Bounce and Power of Alchemy boost Sp. Def upon switching in."))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Magician boosts Sp. Atk upon switching in."))
                when 2
                  Kernel.pbMessage(_INTL("Cut, Sacred Sword, Secret Sword, Slash"))
                when 3
                  Kernel.pbMessage(_INTL("Pokemon with Stance Change boost and lower Attack and Defense one stage when switching between respective forms."))
                when 4
                  Kernel.pbMessage(_INTL("Ancient Power, Fleur Cannon, Leaf Blade, Psycho Cut, Magical Leaf, Moongeist Beam, Mystical Fire, Nigh Slash, Relic Song, Smart Strike, Sparkling Aria, Solar Blade"))
                when 6
                  Kernel.pbMessage(_INTL("Crafty Shield and Flower Shield additionally boost the user's Defense and Sp. Def one stage."))
                when 7
                  Kernel.pbMessage(_INTL("King's Shield and Spiky Shield additionally protect from non-damaging moves."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("Acid Armor, Noble Roar, Swords Dance"))
                when 2
                  Kernel.pbMessage(_INTL("Draining Kiss, Sweet Kiss"))
                when 4
                  Kernel.pbMessage(_INTL("Healing Wish boosts recipient's Attack and Special Attack"))
                when 5
                  Kernel.pbMessage(_INTL("Miracle Eye boosts user's Sp. Atk on use."))
              end
            when 3
                when 5
                  Kernel.pbMessage(_INTL("Boosts Attack and applies King's Shield to the user."))
              end
          end
        when 31 # Dragons Den
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 6
                  Kernel.pbMessage(_INTL("Multiscale additionally annulls user's Dragon type's weaknesses at all times"))
                when 7
                  Kernel.pbMessage(_INTL("Continental Crush, Smack Down, Tectonic Rage, Thousand Arrows"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Dragon Ascent, Pay Day, Smack Down, Thousand Arrows"))
                when 1
                  Kernel.pbMessage(_INTL("Lava Plume, Magma Storm, Mega Kick"))
                when 3
                  Kernel.pbMessage(_INTL("Magician boosts Defense and Sp. Def upon switching in."))
                when 5
                  Kernel.pbMessage(_INTL("Dragon Dance, Noble Roar"))
                when 6
                  Kernel.pbMessage(_INTL("...when Glaciate, Hydro Vortex, or Subzero Slammer is used, or when Muddy Water, Oceanic Operetta, Sparkling Aria, or Surf is used twice."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Boosts Sp.Atk and applies Flash Fire to the user."))
              end
          end
        when 32 # This field deserves to burn
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Bloom Doom, Growth, Rain Dance, Rototiller, Sunny Day, Water Sport"))
                  Kernel.pbMessage(_INTL("Additionally, these abilities Grow the field one stage on switch-in: Drizzle, Drought, Flower Gift, Flower Veil"))
                when 4
                  Kernel.pbMessage(_INTL("Flower Gift, Swarm"))
                when 6
                  Kernel.pbMessage(_INTL("Rototiller additionally boosts user's Attack and Sp. Atk."))
                when 7
                  Kernel.pbMessage(_INTL("Increases (x2,x3) at Stages (1,3)"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Harvest, Leaf Guard"))
                when 3
                  Kernel.pbMessage(_INTL("Flower Shield additionally boosts Sp. Def and the user's Defense and Sp. Def."))
                when 4
                  Kernel.pbMessage(_INTL("Poison Powder, Sleep Powder, Stun Spore"))
                when 5
                  Kernel.pbMessage(_INTL("Flower Veil passively reduces damage x0.5 to its user and allied Grass types."))
                when 6
                  Kernel.pbMessage(_INTL("...when Eruption, Fire Pledge, Flame Burst, Heat Wave, Inferno Overdrive, Lava Plume, or Searing Shot is used in the absence of Rain or Water Sport."))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 4
                  Kernel.pbMessage(_INTL("Grass type attacks increase in base power (x1.2,x1.5,x2,x3) at Stages (2,3,4,5)."))
                when 5
                  Kernel.pbMessage(_INTL("Grass type Pokemon take damage reduced to (x0.75,x0.67,x0.5) at Stages (3,4,5)."))
                when 6
                  Kernel.pbMessage(_INTL("Bug type attacks increase in base power (x1.5,x2) at Stages (2,4)."))
                when 7
                  Kernel.pbMessage(_INTL("Swarm increases Bug type attacks' power by (x2,x3) at Stages (3,5)."))
              end
            when 3
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Overgrow activates at (66% HP, Any HP amount) at Stages (2,3)."))
                when 1
                  Kernel.pbMessage(_INTL("Overgrow increases Grass type attacks' power by (x2,x3) at Stages (4,5)."))
                when 2
                  Kernel.pbMessage(_INTL("At Stage 3 and later, Sweet Scent additionally lowers Defense and Sp. Def. Sweet Scent's effect increases (x2,x3) at Stages (4,5)."))
                when 3
                  Kernel.pbMessage(_INTL("Ingrain's effect increases (x2,x4) at Stages (2,4)."))
                when 4
                  Kernel.pbMessage(_INTL("Fleur Cannon, Petal Blizzard and Petal Dance increase (x1.2,x1.5) at Stages (3,4)."))
                when 5
                  Kernel.pbMessage(_INTL("Infestation deals (1/6,1/4,1/3) Max HP Damage per turn at Stages (3,4,5)."))
              end
            when 4
              case @sprites["command_window"].index #Which line was selected
                when 3
                  Kernel.pbMessage(_INTL("Secret Power may lower Evasion."))
                  Kernel.pbMessage(_INTL("At Stage 3 and later additionally lowers Defense and Sp. Def."))
                  Kernel.pbMessage(_INTL("At Stage 5 this effect increases x2.)"))
                when 4
                  Kernel.pbMessage(_INTL("Boosts Sp.Def and applies Ingrain to the user."))
              end
          end
        when 33 # Starlight Arena
          case @screen # Which screen it's at
            when 0
              # No Details
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Illuminate boosts Sp. Atk upon switching in."))
                when 1
                  Kernel.pbMessage(_INTL("Aurora Beam, Dazzling Gleam, Flash Cannon, Luster Pure, Mirror Shot, Moonblast, Signal Beam, Solar Beam, Technoblast"))
                when 2
                  Kernel.pbMessage(_INTL("Black Hole Eclipse, Comet Punch, Draco Meteor, Hyperspace Fury, Hyperspace Hole, Meteor Mash, Moongeist Beam, Spacial Rend, Sunsteel Strike, Swift"))
                when 4
                  Kernel.pbMessage(_INTL("Solar Beam, Solar Blade"))
                when 5
                  Kernel.pbMessage(_INTL("Cosmic Power, Flash"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("Healing Wish and Lunar Dance boost recipient's Attack and Special Attack"))
                when 7
                  Kernel.pbMessage(_INTL("Boosts Sp.Atk and applies Lunar Dance to the user."))
              end
          end
        when 34 # New World
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("From darkness, from stardust, from memories of eons past and visions yet to come..."))
                when 1
                  Kernel.pbMessage(_INTL("Multitype and RKS System randomly select a new type each turn."))
                when 2
                  Kernel.pbMessage(_INTL("...when grounded."))
                when 6
                  Kernel.pbMessage(_INTL("Aeroblast, Aurora Beam, Blue Flare, Bolt Strike, Crush Grip, Continental Crush, Core Enforcer, Dazzling Gleam, Diamond Storm, Dragon Ascent, Earth Power, Eruption, Flash Cannon, Fleur Cannon, Freeze Shock, Fusion Bolt, Fusion Flare, Genesis Supernova, Glaciate, Ice Burn, Judgment, Land's Wrath, Luster Purge, Magma Storm, Mirror Shot, Moongeist Beam, Multi Attack, Oblivion Wing, Origin Pulse, Power Gem, Precipice Blades, Prismatic Laser, Psycho Boost, Psystrike, Relic Song, Roar of Time, Sacred Fire, Sacred Sword, Searing Shot, Secret Sword, Seed Flare, Shadow Force, Signal Beam, Soul-Stealing 7-Star Strike, Spectral Thief, Steam Eruption, Sunsteel Strike, Technoblast, Thousand Arrows, Thousand Waves, V-Create"))
                when 7
                  Kernel.pbMessage(_INTL("Ancient Power, Comet Punch, Draco Meteor, Future Sight, Hyperspace Fury, Hyperspace Hole, Meteor Mash, Moonblast, Spacial Rend, Swift, Vacuum Wave"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 5
                  Kernel.pbMessage(_INTL("Trick Room, Magic Room, Wonder Room"))
                when 6
                  Kernel.pbMessage(_INTL("Cosmic Power, Flash"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 0
                  Kernel.pbMessage(_INTL("...when Geomancy is used, or when Gravity is used for as long as Gravity lasts."))
                when 7
                  Kernel.pbMessage(_INTL("Boosts all stats, but makes the user recharge."))
              end
          end
        when 35 # Inverse Field
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("...Created (3 turns) when the attacker does not hold an Everstone."))
                when 6
                  Kernel.pbMessage(_INTL("Boosts all stats, but makes the user recharge."))
              end
          end
        when 36 # Psychic Terrain
          case @screen # Which screen it's at
            when 0
              case @sprites["command_window"].index #Which line was selected
                when 1
                  Kernel.pbMessage(_INTL("...when used on grounded targets."))
                when 2
                  Kernel.pbMessage(_INTL("when one of these effects is activated: Psychic Surge, Psychic Terrain, Genesis Supernova (5 turns)"))
                when 3
                  Kernel.pbMessage(_INTL("...when attacker is grounded."))
                when 4
                  Kernel.pbMessage(_INTL("Aura Sphere, Hex, Magical Leaf, Moonblast, Mystic Fire"))
              end
            when 1
              case @sprites["command_window"].index #Which line was selected
                when 5
                  Kernel.pbMessage(_INTL("Calm Mind, Cosmic Power, Kinesis, Meditate, Nasty Plot"))
                when 6
                  Kernel.pbMessage(_INTL("Mind Reader, Miracle Eye, Psych Up boost Sp.Atk two stages"))
                when 5
                  Kernel.pbMessage(_INTL("Gravity, Magic Room, Trick Room, Wonder Room"))
              end
            when 2
              case @sprites["command_window"].index #Which line was selected
                when 2
                  Kernel.pbMessage(_INTL("Boosts Sp.Atk and Sp.Def, but confuses the user."))
              end
          end
      end
    end
  end
end