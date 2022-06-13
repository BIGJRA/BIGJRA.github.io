# Pulse Dex class. Based on xLed's Jukebox Scene class. 
class Scene_PulseDex
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
    @switch_picture_links = [
      [$game_switches[587],"navpulse00","0. Garbodor"],
      [$game_switches[588],"navpulse01","1. Magnezone"],
      [$game_switches[589],"navpulse02","2. Avalugg"],
      [$game_switches[590],"navpulse03","3. Swalot"],
      [$game_switches[591],"navpulse04","4. Muk"],
      [$game_switches[1778],"navpulse05c","5A. Tangrowth"],
      [$game_switches[1777],"navpulse05b","5B. Tangrowth"],
      [$game_switches[592],"navpulse05","5C. Tangrowth"],
      [$game_switches[593],"navpulse06","6. Camerupt"],
      [$game_switches[594],"navpulse07","7. Abra"],
      [$game_switches[595],"navpulse08","8. Hypno"],
      [$game_switches[596],"navpulse09","9. Mr. Mime"],
      [$game_switches[597],"navpulse10","10. Clawitzer"],
      [$game_switches[598],"navpulse11","11. Arceus"]
    ]
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
    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Pulse Dex"),
       2,-18,128,64,@viewport)
    @sprites["header"].baseColor=Color.new(248,248,248)
    @sprites["header"].shadowColor=Color.new(0,0,0)
    @sprites["header"].windowskin=nil
    @sprites["command_window"] = Window_CommandPokemonWhiteArrow.new(@choices,324)
    @sprites["command_window"].windowskin=nil
    @sprites["command_window"].baseColor=Color.new(248,248,248)
    @sprites["command_window"].shadowColor=Color.new(0,0,0)
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].setHW_XYZ(282,324,94,46,256)
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
    index = @sprites["command_window"].index
    # If B button was pressed
    if Input.trigger?(Input::B) || (Input.trigger?(Input::C) && index == @choices.length - 1)
      # Switch to map screen
      $scene = Scene_Pokegear.new
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C) && @switch_picture_links[index][0] == true
      $scene = Scene_PulseDex_Info.new("Graphics/Pictures/#{@switch_picture_links[index][1]}",index)
      return
    end
  end

  #-----------------------------------------------------------------------------
  # * Determines which Pulses the trainer has data for
  #-----------------------------------------------------------------------------
  def pbPulseSeen
    pulseSeen = []
    for i in @switch_picture_links
      pulseSeen.push(i[0] ? i[2] : "???")
    end
    pulseSeen.push("Back")
    return pulseSeen
  end
end


# Class for information screen

class Scene_PulseDex_Info
  
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
      $scene = Scene_PulseDex.new(@index)
      return
    end  
  end
  
end