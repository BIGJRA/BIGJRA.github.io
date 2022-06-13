# Pulse Dex class. Based on xLed's Jukebox Scene class. 
class Scene_RiftNotes
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
    @choices= pbPulseSeen
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Rift Notes"),
       2,-18,128,64,@viewport)
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
          if $game_switches[1209]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift99_1",@sprites["command_window"].index)
          end
        when 1
          if $game_switches[1201]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift00_1",@sprites["command_window"].index)
          end
        when 2
          if $game_switches[1202]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift01_1",@sprites["command_window"].index)
          end
        when 3
          if $game_switches[1203]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift02_1",@sprites["command_window"].index)
          end
        when 4
          if $game_switches[1204]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift03_1",@sprites["command_window"].index)
          end
        when 5
          if $game_switches[1205]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift04_1",@sprites["command_window"].index)
          end
        when 6
          if $game_switches[1206]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift05_1",@sprites["command_window"].index)
          end
        when 7
          if $game_switches[1207]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift06_1",@sprites["command_window"].index)
          end
        when 8
          if $game_switches[1224]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift07_1",@sprites["command_window"].index)
          end
        when 9
          if $game_switches[1285]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift08_1",@sprites["command_window"].index)
          end
        when 10
          if $game_switches[1286]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift09_1",@sprites["command_window"].index)
          end
        when 11
          if $game_switches[9999]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift10_1",@sprites["command_window"].index)
          end
        when 12
          if $game_switches[9999]
            $scene = Scene_RiftNotes_Info.new("Graphics/Pictures/navrift11_1",@sprites["command_window"].index)
          end
        when 13  
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
  def pbPulseSeen
  
    pulseSeen = []
    
    if $game_switches[1209]
      pulseSeen.push(_INTL("Code: Drifio"))
    else
      pulseSeen.push("???")
    end
    if $game_switches[1201]
      pulseSeen.push(_INTL("Code: Feris"))
    else
      pulseSeen.push("???")
    end
    if $game_switches[1202]
      pulseSeen.push("Code: Evo")
    else
      pulseSeen.push("???")
    end
    if $game_switches[1203]
      pulseSeen.push("Code: Materna") 
    else
      pulseSeen.push("???")
    end
    if $game_switches[1204]
      pulseSeen.push("Code: Statia") 
    else
      pulseSeen.push("???")
    end
    if $game_switches[1205]
      pulseSeen.push("Code: Sarpa") 
    else
      pulseSeen.push("???")
    end
    if $game_switches[1206]
      pulseSeen.push("Code: Corroso")      
    else
       pulseSeen.push("???")
    end
    if $game_switches[1207]
      pulseSeen.push("Code: Bella") 
    else
       pulseSeen.push("???")
    end
    if $game_switches[1224]
      pulseSeen.push("Code: Angelus")  
    else
       pulseSeen.push("???")
    end
    if $game_switches[1285]
      pulseSeen.push("Code: Garna")      
    else
       pulseSeen.push("???")
    end
    if $game_switches[1286]
      pulseSeen.push("Code: Rembrence")      
    else
       pulseSeen.push("???")
    end
    if $game_switches[9999]
      pulseSeen.push("") 
    else
       pulseSeen.push("???")
    end
    if $game_switches[9999]
      pulseSeen.push("")
    else
       pulseSeen.push("???")
    end
    pulseSeen.push("Back")
  end
end


# Class for information screen

class Scene_RiftNotes_Info
  
  attr_accessor :background
  attr_accessor :index
  
  def initialize(background, index)
    @background = background
    @index      = index
  end
  
  def main
    fadein = true
    # Makes the text window
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["background"] = IconSprite.new(0,0)
    @sprites["background"].setBitmap(background)
    @sprites["background"].z=255
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
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Switch to map screen
      $scene = Scene_RiftNotes.new(@index)
      return
    end  
  end
  
end