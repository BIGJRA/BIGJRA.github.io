class PokegearButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,name="",index=0,viewport=nil)
    super(viewport)
    @index=index
    @name=name
    @selected=false
    fembutton=pbResolveBitmap(sprintf("Graphics/Pictures/Pokegear/pokegearButtonf"))
    if $Trainer.isFemale? && fembutton
      @button=AnimatedBitmap.new("Graphics/Pictures/Pokegear/pokegearButtonf")
    else
      @button=AnimatedBitmap.new("Graphics/Pictures/Pokegear/pokegearButton")
    end
    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    refresh
    update
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@button.bitmap,Rect.new(0,0,@button.width,@button.height))
    pbSetSystemFont(self.bitmap)
    textpos=[          # Name is written on both unselected and selected buttons
       [@name,self.bitmap.width/2,10,2,Color.new(248,248,248),Color.new(40,40,40)],
       [@name,self.bitmap.width/2,62,2,Color.new(248,248,248),Color.new(40,40,40)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
    icon=sprintf("Graphics/Pictures/pokegear"+@name)
    imagepos=[         # Icon is put on both unselected and selected buttons
       [icon,18,10,0,0,-1,-1],
       [icon,18,62,0,0,-1,-1]
    ]
    pbDrawImagePositions(self.bitmap,imagepos)
  end

  def update
    if self.selected
      self.src_rect.set(0,self.bitmap.height/2,self.bitmap.width,self.bitmap.height/2)
    else
      self.src_rect.set(0,0,self.bitmap.width,self.bitmap.height/2)
    end
    super
  end
end



#===============================================================================
# - Scene_Pokegear
#-------------------------------------------------------------------------------
# Modified By Harshboy
# Modified by Peter O.
# Also Modified By OblivionMew
# Overhauled by Maruno
#===============================================================================
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
    #@cmdPortablePC=-1
    @cmdPulse=-1
    @cmdRiftNotes=-1
    @cmdNotes=-1
    @cmdRecords=-1
#    @cmdNews=-1
    commands[@cmdMap=commands.length]=_INTL("Map")
    commands[@cmdPhone=commands.length]=_INTL("Phone") if $PokemonGlobal.phoneNumbers &&
                                                          $PokemonGlobal.phoneNumbers.length>0
    commands[@cmdJukebox=commands.length]=_INTL("Jukebox")
#    commands[@cmdNews=commands.length]=_INTL("Gearen News")
    if $game_switches[1176]
      commands[@cmdPulse=commands.length]=_INTL("Rift Dex")
    end
    if $game_switches[1210]
      commands[@cmdRiftNotes=commands.length]=_INTL("Rift Notes")
    end
    if $game_switches[1177]
      commands[@cmdNotes=commands.length]=_INTL("Field Notes")
    end
    # if !($game_switches[1235]==true)  && ($game_switches[1408]==true)
    #   if !($game_variables[456]>34 && $game_variables[456]<70) &&  !($game_map.map_id == 94 || $game_map.map_id == 99 || $game_map.map_id == 160 || $game_map.map_id == 164 || $game_map.map_id == 66 || $game_map.map_id == 144 || $game_map.map_id == 33 || $game_map.map_id == 153)
    #     commands[@cmdPortablePC=commands.length]=_INTL("PC")
    #   end
    # end
    if $game_switches[1296]
      commands[@cmdRecords=commands.length]=_INTL("Records")
    end
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @button=AnimatedBitmap.new("Graphics/Pictures/Pokegear/pokegearButton")
    @sprites={}
    @sprites["background"] = IconSprite.new(0,0)
    femback=pbResolveBitmap(sprintf("Graphics/Pictures/Pokegear/pokegearbgf"))
    if $Trainer.isFemale? && femback
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/pokegearbgf")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/pokegearbg")
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
      # if @cmdPortablePC>=0 && @sprites["command_window"].index==@cmdPortablePC
      #   pbPlayDecisionSE()
      #   pbPokeCenterPC
      # end
#      if @cmdNews>=0 && @sprites["command_window"].index==@cmdNews
#        pbPlayDecisionSE()
#        print "about to play news"
#        $game_switches[1450] = true
#        $scene = Scene_Map.new
#        #return pbCommonEvent(17)
        
#        print "done playing news"
#        return 1
#      end
      if @cmdPulse>=0 && @sprites["command_window"].index==@cmdPulse
        pbPlayDecisionSE()
        $scene = Scene_PulseDex.new
      end
      if @cmdRiftNotes>=0 && @sprites["command_window"].index==@cmdRiftNotes
        pbPlayDecisionSE()
        $scene = Scene_RiftNotes.new
      end
      if @cmdNotes>=0 && @sprites["command_window"].index==@cmdNotes
        pbPlayDecisionSE()
        $scene = Scene_FieldNotes.new
      end
      if @cmdRecords>=0 && @sprites["command_window"].index==@cmdRecords
        pbPlayDecisionSE()
        pbViewQuests
#        $scene = Scene_FieldNotes.new
      end

      return
    end
  end
  def tryConnect
    $scene=Connect.new
  end    
end