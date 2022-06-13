################################################################################
#-------------------------------------------------------------------------------
#Author: Alexandre
#Simple trade system.
#-------------------------------------------------------------------------------
################################################################################
class Scene_Trade
################################################################################
#-------------------------------------------------------------------------------
#Author: Alexandre
#Lets initialise the scene:
#@list is the main trade background
#@info is the background that appears when confirming the trade
#-------------------------------------------------------------------------------
################################################################################
  def initialize(user)
    @username = user
    @partysent = false
    @pokemonselected = false
    @theirparty = nil
    @theirpartylength = 0
    @theirchosen = nil
    @theirindex = -1
    @index = 1
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @overlay=SpriteWrapper.new(@viewport)
    @overlay.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @overlay.z = 1000005
    @overlay2=SpriteWrapper.new(@viewport)
    @overlay2.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @overlay2.z = 1000009
    @overlay3=SpriteWrapper.new(@viewport)
    @overlay3.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @overlay3.z = 1000009
    @list=SpriteWrapper.new(@viewport)
    @list.visible = true 
    @list.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/tradebackground.png")
    @list.z = 1000004
    @selector=SpriteWrapper.new(@viewport)
    @selector.visible = true 
    @selector.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Storage/boxpoint1.png")
    @selector.z = 1000006
    @waiting = Window_AdvancedTextPokemon.new("Waiting...")
    @waiting.visible = false
    @waiting.width = 120
    @waiting.x = Graphics.width/2 - 50
    @waiting.y = 160
    @sprite = []
    @spritehidden = []
    @spritex = []
    @spritexhidden = []
    @sprites = {}
    @info=SpriteWrapper.new(@viewport)
    @info.visible = true 
    @info.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/tradebottom.png")
    @info.z = 1000008
    @info.visible = false
    @accepted = false
    @received = false
    @listreceived = false
  end
################################################################################
#-------------------------------------------------------------------------------
#Main procedure of the Scene, contains the loop that keeps it alive. When B is
#pressed, the Trade dead message is sent to the server and the scene is disposed
#-------------------------------------------------------------------------------
################################################################################
  def main
    for pokemon in $Trainer.party
      if pokemon.ot == ""
        pokemon.ot = $Trainer.name
        pokemon.trainerID = $Trainer.id
      end
    end    
    mylist
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
      if Input.trigger?(Input::B)
        $scene=Scene_Map.new        
        $network.send("<TRA dead>")  
        $network.send("<DSC>")
      end
    end
    Graphics.freeze
    @waiting.dispose
    @viewport.dispose
    @list.dispose
    @overlay.dispose
    @overlay2.dispose
    @overlay3.dispose
    @sprite[0].dispose if @sprite[0] != nil
    @sprite[1].dispose if @sprite[1] != nil
    @sprite[2].dispose if @sprite[2] != nil
    @sprite[3].dispose if @sprite[3] != nil
    @sprite[4].dispose if @sprite[4] != nil
    @sprite[5].dispose if @sprite[5] != nil
    @spritex[0].dispose if @spritex[0] != nil
    @spritex[1].dispose if @spritex[1] != nil
    @spritex[2].dispose if @spritex[2] != nil
    @spritex[3].dispose if @spritex[3] != nil
    @spritex[4].dispose if @spritex[4] != nil
    @spritex[5].dispose if @spritex[5] != nil
    @sprites["mypokemon"].dispose if @sprites["mypokemon"] != nil
    @sprites["theirpokemon"].dispose if @sprites["theirpokemon"] != nil
  end
################################################################################
#-------------------------------------------------------------------------------
#Just a procedure to update the scene and check for any incoming messages
#-------------------------------------------------------------------------------
################################################################################
  def update
    their_info if @received == true && @pokemonselected == true
    their_list if @listreceived == true
    message = $network.listen
    handle(message)
    @sprite[0].update if @sprite[0] != nil
    @sprite[1].update if @sprite[1] != nil
    @sprite[2].update if @sprite[2] != nil
    @sprite[3].update if @sprite[3] != nil
    @sprite[4].update if @sprite[4] != nil
    @sprite[5].update if @sprite[5] != nil
    @spritehidden[0].update if @sprite[0] != nil
    @spritehidden[1].update if @sprite[1] != nil
    @spritehidden[2].update if @sprite[2] != nil
    @spritehidden[3].update if @sprite[3] != nil
    @spritehidden[4].update if @sprite[4] != nil
    @spritehidden[5].update if @sprite[5] != nil    
    @spritex[0].update if @spritex[0] != nil
    @spritex[1].update if @spritex[1] != nil
    @spritex[2].update if @spritex[2] != nil
    @spritex[3].update if @spritex[3] != nil
    @spritex[4].update if @spritex[4] != nil
    @spritex[5].update if @spritex[5] != nil
    @spritexhidden[0].update if @spritex[0] != nil
    @spritexhidden[1].update if @spritex[1] != nil
    @spritexhidden[2].update if @spritex[2] != nil
    @spritexhidden[3].update if @spritex[3] != nil
    @spritexhidden[4].update if @spritex[4] != nil
    @spritexhidden[5].update if @spritex[5] != nil    
    @viewport.update
    @overlay.update
    @overlay2.update
    @overlay3.update
    @selector.update
    check_input
    if @pokemonselected == false && @theirparty != nil
      update_selector_input
      update_selector
    end
    @waiting.update
    end
################################################################################
#-------------------------------------------------------------------------------
#Listens to incoming messages and determines what to do when trade messages are
#received.
#-------------------------------------------------------------------------------
################################################################################  
  def handle(message)
    case message
      when /<TRA party=(.*)>/ #$Trainer.party dump
        theirparty($1) if @theirparty == nil
      when /<TRA offer=(.*) index=(.*)>/ #Trainer.party[@index - 1] dump
        receiveoffer($1,$2.to_i) if @theirchosen == nil
      when /<TRA accepted>/
        execute_trade if @accepted == true
      when /<TRA declined>/ then trade_declined
      when /<TRA dead>/
        Kernel.pbMessage("The user exited the trade.")
        $network.send("<DSC>")
        $scene=Scene_Map.new  
      end
  end
################################################################################
#-------------------------------------------------------------------------------
#Checks for input from C to select a pokemon or show the summary.
#-------------------------------------------------------------------------------
################################################################################  
  def check_input
    #Player's pokemon
    if Input.trigger?(Input::C) && @pokemonselected == false
      if @index >= 1 && @index <= 6 
      commands=[_INTL("Offer"),_INTL("Summary"),_INTL("Cancel")] 
      choice=Kernel.pbMessage(_INTL("What do you want to do?"),commands) unless $Trainer.party[@index-1] == nil
      if choice==0 && (!pbIsGoodItem($Trainer.party[@index - 1].item) || Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to trade away your {1}?",PBItems.getName(($Trainer.party[@index - 1].item)))))
        serialized = [Marshal.dump($Trainer.party[@index - 1])].pack("m").delete("\n")
        $network.send("<TRA offer=" + serialized + " index=#{@index-1}>")
        show_information
        @waiting.visible = true
        @pokemonselected=true
      elsif choice==1
        scene=PokemonSummaryScene.new
        screen=PokemonSummary.new(scene)
        screen.pbStartScreen($Trainer.party,@index - 1)
      elsif choice==2
        #do nothing
      end
    else
      #Other user's pokemon
    commands=[_INTL("Summary"),_INTL("Cancel")] 
      choice=Kernel.pbMessage(_INTL("What do you want to do?"),commands) unless @theirparty[@index - 7] == nil
      if choice==0
        scene=PokemonSummaryScene.new
        screen=PokemonSummary.new(scene)        
        screen.pbStartScreen(@theirparty,@index - 7)
      elsif choice==1
        #do nothing
      end
      end
    end
  end
################################################################################
#-------------------------------------------------------------------------------
#Checks for left and right input to move selector.
#-------------------------------------------------------------------------------
################################################################################        
  def update_selector_input  
    if Input.trigger?(Input::RIGHT)
      case @index
        when 1, 3, 5, 7, 9, 11
          @index+=1
        when 2, 4, 6
          @index+=5
        when 8, 10, 12
          @index-=7
        end
      end                                  
    if Input.trigger?(Input::DOWN)
      case @index
        when 1, 2, 3, 4, 7, 8, 9, 10
          @index+=2
        when 5, 6, 11, 12
          @index-=4
        end
      end              
    if Input.trigger?(Input::LEFT)
      case @index
        when 2, 4, 6, 8, 10, 12
          @index-=1
        when 1, 3, 5
          @index+=7
        when 7, 9, 11
          @index-=5
      end
    end
    if Input.trigger?(Input::UP)
      case @index
        when 3, 4, 5, 6, 9, 10, 11, 12
          @index-=2
        when 1, 2, 7, 8
          @index+=4
      end
    end      
  end
################################################################################
#-------------------------------------------------------------------------------
#Updates the position of the selector.
#-------------------------------------------------------------------------------
################################################################################  
  def update_selector
    case @index
    when 1 then @selector.x = 54; @selector.y = 31
    when 2 then @selector.x = 149; @selector.y = 31
    when 3 then @selector.x = 54; @selector.y = 127
    when 4 then @selector.x = 149; @selector.y = 127
    when 5 then @selector.x = 54; @selector.y = 223
    when 6 then @selector.x = 149; @selector.y = 223
    when 7 then @selector.x = 307; @selector.y = 31
    when 8 then @selector.x = 406; @selector.y = 31
    when 9 then @selector.x = 307; @selector.y = 127
    when 10 then @selector.x = 406; @selector.y = 127
    when 11 then @selector.x = 307; @selector.y = 223
    when 12 then @selector.x = 406; @selector.y = 223
    end
  end
################################################################################
#-------------------------------------------------------------------------------
#Receives the other user's party.
#-------------------------------------------------------------------------------
################################################################################  
  def theirparty(data)
    @theirparty = Marshal.load(data.unpack("m")[0]) #load serialised party data
    @listreceived = true
  end
################################################################################
#-------------------------------------------------------------------------------
#Display the other uer's party.
#-------------------------------------------------------------------------------
################################################################################
  def their_list
    @listreceived = false    
    @theirpartylength = 1 if @theirparty[0] !=nil
    @theirpartylength = 2 if @theirparty[1] !=nil
    @theirpartylength = 3 if @theirparty[2] !=nil
    @theirpartylength = 4 if @theirparty[3] !=nil
    @theirpartylength = 5 if @theirparty[4] !=nil
    @theirpartylength = 6 if @theirparty[5] !=nil
    for i in 0..@theirpartylength-1
      @spritex[i]= PokemonTradeIcon.new(@theirparty[i],@theirparty[i].eggsteps,@theirparty[i].personalID,false,@viewport)
      @spritexhidden[i]= PokemonTradeIcon.new(@theirparty[i],@theirparty[i].eggsteps,@theirparty[i].personalID,false,@viewport)
      @spritexhidden[i].visible = false if @spritexhidden[i] !=nil
      @spritexhidden[i].x = 444 if @spritexhidden[i] !=nil
      @spritexhidden[i].y = 87 if @spritexhidden[i] !=nil
      @spritexhidden[i].z = 1000009 if @spritexhidden[i] !=nil
    end
    @spritex[0].x = 302 if @spritex[0] != nil
    @spritex[0].y = 71 if @spritex[0] != nil
    @spritex[1].x = 401 if @spritex[1] != nil
    @spritex[1].y = 71 if @spritex[1] != nil
    @spritex[2].x = 302 if @spritex[2] != nil
    @spritex[2].y = 167 if @spritex[2] != nil
    @spritex[3].x = 401 if @spritex[3] != nil
    @spritex[3].y = 167 if @spritex[3] != nil
    @spritex[4].x = 302 if @spritex[4] != nil
    @spritex[4].y = 263 if @spritex[4] != nil
    @spritex[5].x = 401 if @spritex[5]!= nil
    @spritex[5].y = 263 if @spritex[5] != nil
    @spritex[0].z = 1000005 if @spritex[0] != nil
    @spritex[1].z = 1000005 if @spritex[1] != nil
    @spritex[2].z = 1000005 if @spritex[2] != nil
    @spritex[3].z = 1000005 if @spritex[3] != nil
    @spritex[4].z = 1000005 if @spritex[4] != nil
    @spritex[5].z = 1000005 if @spritex[5] != nil
  end
################################################################################
#-------------------------------------------------------------------------------
#Show's information about your chosen pokemon.
#-------------------------------------------------------------------------------
################################################################################  
  def show_information
    @waiting.visible = false
    @info.visible = true
    pkmn = $Trainer.party[@index - 1]
    itemname=pkmn.item==0 ? _INTL("NO ITEM") : PBItems.getName(pkmn.item)
    imagepos = []
    @overlay2.bitmap.clear
    @typebitmap=RPG::Cache.load_bitmap(_INTL("Graphics/Pictures/types.png"))
    @spritehidden[@index-1].visible = true 
    @chosenpokemon = false
    move0 = pkmn.moves[0].id == 0 ? "--" : PBMoves.getName(pkmn.moves[0].id)
    move1 = pkmn.moves[1].id == 0 ? "--" : PBMoves.getName(pkmn.moves[1].id)
    move2 = pkmn.moves[2].id == 0 ? "--" : PBMoves.getName(pkmn.moves[2].id)
    move3 = pkmn.moves[3].id == 0 ? "--" : PBMoves.getName(pkmn.moves[3].id)
     textpositions = [
 [_INTL("#{pkmn.name}"),4,0,0,Color.new(255,255,255),Color.new(0,0,0)],
 [_INTL("Lv: #{pkmn.level}"),4,27,0,Color.new(255,255,255),Color.new(0,0,0)],
 [_INTL("#{PBAbilities.getName(pkmn.ability)}"),4,257,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("#{move0}"),4,149,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("#{move1}"),4,175,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("#{move2}"),4,201,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("#{move3}"),4,227,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("#{itemname}"),4,58,0,Color.new(255,255,255),Color.new(0,0,0)], 
 ]
    if pkmn.gender==0
      textpositions.push([_INTL("♂"),227,60,false,Color.new(120,184,248),Color.new(0,120,248)])
    elsif pkmn.gender==1
      textpositions.push([_INTL("♀"),227,60,false,Color.new(248,128,128),Color.new(168,24,24)])
    end
    pbSetExtraSmallFont(@overlay2.bitmap)
    if !pkmn.isEgg?
      pbDrawTextPositions(@overlay2.bitmap,textpositions)
      type1rect=Rect.new(0,pkmn.type1*28,64,28)
      type2rect=Rect.new(0,pkmn.type2*28,64,28)
      @overlay2.bitmap.blt(186,4,@typebitmap,type1rect)
      @overlay2.bitmap.blt(186,4 + 28,@typebitmap,type2rect) if pkmn.type1!=pkmn.type2
    end
  end
################################################################################
#-------------------------------------------------------------------------------
#Display's the user's party.
#-------------------------------------------------------------------------------
################################################################################  
def mylist
 textpos = [
 [_INTL("#{$network.username}'s list"),130,6,2,Color.new(255,255,255),Color.new(0,0,0)],
 [_INTL("#{@username}'s list"),385,6,2,Color.new(255,255,255),Color.new(0,0,0)],
 ]
  @overlay.bitmap.font.name="Power Green"
  @overlay.bitmap.font.size=32
  pbDrawTextPositions(@overlay.bitmap,textpos)
  if @partysent == false
    #we must serialie the data in order to send the whole class then encode
    #in base 64 (and delete the newline that the packing causes) in order for
    #server not to go beserk (serialised data is binary, server does not understand
    #how to receive this data as it is, encoding in base 64 avoids this)
    party = [Marshal.dump($Trainer.party)].pack("m").delete("\n")
    $network.send("<TRA party="+ party +">")
    @partysent = true
  end
  for i in 0..$Trainer.party.length-1
    @sprite[i] = PokemonTradeIcon.new($Trainer.party[i],$Trainer.party[i].eggsteps,$Trainer.party[i].personalID,false,@viewport)
    @spritehidden[i] = PokemonTradeIcon.new($Trainer.party[i],$Trainer.party[i].eggsteps,$Trainer.party[i].personalID,false,@viewport)
    @spritehidden[i].visible = false if @spritehidden[i] !=nil
    @spritehidden[i].x = 186 if @spritehidden[i] !=nil
    @spritehidden[i].y = 87 if @spritehidden[i] !=nil    
    @spritehidden[i].z = 1000009 if @spritehidden[i] !=nil    
  end
    @sprite[0].x = 49 if @sprite[0] != nil
    @sprite[0].y = 71 if @sprite[0] != nil
    @sprite[1].x = 144 if @sprite[1] != nil
    @sprite[1].y = 71 if @sprite[1] != nil
    @sprite[2].x = 49 if @sprite[2] != nil
    @sprite[2].y = 167 if @sprite[2] != nil
    @sprite[3].x = 144 if @sprite[3] != nil
    @sprite[3].y = 167 if @sprite[3] != nil
    @sprite[4].x = 49 if @sprite[4] != nil
    @sprite[4].y = 263 if @sprite[4] != nil
    @sprite[5].x = 144 if @sprite[5] != nil
    @sprite[5].y = 263 if @sprite[5] != nil
    @sprite[0].z = 1000005 if @sprite[0] != nil
    @sprite[1].z = 1000005 if @sprite[1] != nil
    @sprite[2].z = 1000005 if @sprite[2] != nil
    @sprite[3].z = 1000005 if @sprite[3] != nil
    @sprite[4].z = 1000005 if @sprite[4] != nil
    @sprite[5].z = 1000005 if @sprite[5] != nil
  end
 
################################################################################
#-------------------------------------------------------------------------------
#Receives the data for the other user's chosen pokemon.
#-------------------------------------------------------------------------------
################################################################################  
  def receiveoffer(data,index)
    @theirchosen = Marshal.load(data.unpack("m")[0]) #decode base 64 and load serialised data   
    @theirindex = index
    @received = true
  end
################################################################################
#-------------------------------------------------------------------------------
#Displays the information about the other user's chosen pokemon.
#-------------------------------------------------------------------------------
################################################################################
  def their_info
    @received = false
    @waiting.visible = false
    itemname=@theirchosen.item==0 ? _INTL("NO ITEM") : PBItems.getName(@theirchosen.item)
    @spritexhidden[@theirindex].visible = true 
    @overlay3.bitmap.clear
    imagepos2 = []    
    @typebitmap2=RPG::Cache.load_bitmap(_INTL("Graphics/Pictures/types.png"))
    move0x = @theirchosen.moves[0].id == 0 ? "--" : PBMoves.getName(@theirchosen.moves[0].id)
    move1x = @theirchosen.moves[1].id == 0 ? "--" : PBMoves.getName(@theirchosen.moves[1].id)
    move2x = @theirchosen.moves[2].id == 0 ? "--" : PBMoves.getName(@theirchosen.moves[2].id)
    move3x = @theirchosen.moves[3].id == 0 ? "--" : PBMoves.getName(@theirchosen.moves[3].id)
    textpositions2 = [
 [_INTL("{1}",@theirchosen.name),262,0,0,Color.new(255,255,255),Color.new(0,0,0)],
 [_INTL("Lv: {1}",@theirchosen.level),262,27,0,Color.new(255,255,255),Color.new(0,0,0)],
 [_INTL("{1}",PBAbilities.getName(@theirchosen.ability)),262,257,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("{1}",move0x),262,149,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("{1}",move1x),262,175,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("{1}",move2x),262,201,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("{1}",move3x),262,227,0,Color.new(255,255,255),Color.new(0,0,0)],   
 [_INTL("{1}",itemname),262,58,0,Color.new(255,255,255),Color.new(0,0,0)],
 ]
  if @theirchosen.gender == 0
    textpositions2.push([_INTL("♂"),485,60,false,Color.new(120,184,248),Color.new(0,120,248)])
  elsif @theirchosen.gender == 1
    textpositions2.push([_INTL("♀"),485,60,false,Color.new(248,128,128),Color.new(168,24,24)])
 end
  pbSetExtraSmallFont(@overlay3.bitmap)
  if !@theirchosen.isEgg?
    pbDrawTextPositions(@overlay3.bitmap,textpositions2)
   type1rect2=Rect.new(0,(@theirchosen.type1)*28,64,28)
   type2rect2=Rect.new(0,(@theirchosen.type2)*28,64,28)
   @overlay3.bitmap.blt(444,4,@typebitmap2,type1rect2)
   @overlay3.bitmap.blt(444,4 + 28,@typebitmap2,type2rect2) if @theirchosen.type1 != @theirchosen.type2
  end 
 yourName = PBSpecies.getName($Trainer.party[@index-1].species)
 theirName = PBSpecies.getName(@theirchosen.species)
 if Kernel.pbConfirmMessage(_INTL("Trade your #{yourName} for their #{theirName}?"))
   @waiting.visible = true
   $network.send("<TRA accepted>")
   @accepted = true
 else
  trade_declined
   $network.send("<TRA declined>")
  end
end
################################################################################
#-------------------------------------------------------------------------------
#Procedure that is called when the other player declines the trade.
#-------------------------------------------------------------------------------
################################################################################
def trade_declined
  @waiting.visible = false
  @info.visible=false
  for i in 0...$Trainer.party.length
    @spritehidden[i].visible = false
  end
  for i in 0...@theirpartylength
    @spritexhidden[i].visible = false
  end  
  @overlay2.bitmap.clear
  @overlay3.bitmap.clear
  @pokemonselected = false
  @theirchosen = nil
  @theirindex = -1
  @accepted = false
  @received = false
  @listreceived = false
end
################################################################################
#-------------------------------------------------------------------------------
#Excutes the trade, this is where the pokemon chosen is modified to the new one.
#-------------------------------------------------------------------------------
################################################################################
def execute_trade
  @waiting.visible = false
  old = $Trainer.party[@index - 1]
  $Trainer.party[@index - 1] = @theirchosen
  pbSave
  Kernel.pbMessage("Saved the game!")  
  pbFadeOutInWithMusic(99999){  
  evo=PokemonTradeScene.new
  evo.pbStartScreen(old,@theirchosen,$network.username,@username)  
  evo.pbTrade
  evo.pbEndScreen
  }
  $Trainer.seen[@theirchosen.species]=true
  $Trainer.owned[@theirchosen.species]=true
  pbSeenForm(@theirchosen)
  $scene=Scene_Trade.new(@username)
end
 
end
################################################################################
#-------------------------------------------------------------------------------
#Other Essentials based classes and methods needed for the scene to function
#-------------------------------------------------------------------------------
################################################################################
class PokemonTradeIcon < SpriteWrapper
 attr_accessor :selected
 attr_accessor :active
 attr_reader :pokemon

  def initialize(pokemon,eggsteps,personalID,active,viewport=nil)
    super(viewport)
    @eggsteps = eggsteps
    @personalID = personalID
    @animbitmap=nil
    @frames=[
    Rect.new(0,0,64,64),
    Rect.new(64,0,64,64)
    ]
    @active=active
    @selected=false
    @animframe=0
    self.pokemon=pokemon
    @frame=0
    @pokemon=pokemon
    @spriteX=self.x
    @spriteY=self.y
    @updating=false
  end

  def width
    return 300
  end

  def height
    return 300
  end

  def pokemon=(pokemon)
    @animbitmap.dispose if @animbitmap
    @animbitmap=pbPokemonIconBitmap(pokemon,pokemon.isEgg?)
    self.bitmap=@animbitmap
    self.src_rect=@frames[@animframe]
  end

  def dispose
    @animbitmap.dispose
    super
  end

  def update
    @updating=true
    super
    frameskip=5
    if frameskip==-1
      @animframe=0
      self.src_rect=@frames[@animframe]
    else
      @frame+=1
      @frame=0 if @frame>100
      if @frame>=frameskip
        @animframe=(@animframe==1) ? 0 : 1
        self.src_rect=@frames[@animframe]
        @frame=0
      end
    end
    if self.selected
      if !self.active
        self.x=@spriteX+8
        self.y=(@animframe==0) ? @spriteY-6 : @spriteY+2
      else
        self.x=@spriteX
        self.y=(@animframe==0) ? @spriteY+2 : @spriteY+10
      end
    end
  end

  def x=(value)
    super
    @spriteX=value if !@updating
  end

  def y=(value)
    super
    @spriteY=value if !@updating
  end
end
 
def pbLoadTradeIcon(pokemon,eggsteps,personalID)
  return RPG::Cache.load_bitmap(pbPokemonTradeFile(pokemon))
end

def pbPokemonTradeFile(pokemon) 
  return pbCheckPokemonIconFiles([pokemon.species,
                          (pokemon.isFemale?),
                          pokemon.isShiny?,
                          (pokemon.form rescue 0),
                          (pokemon.isShadow? rescue false)],
                          pokemon.isEgg?)
end

def pbLoadTradeBitmap(species,eggsteps,personalID,trainerID)
  return pbLoadTradeBitmapSpecies(species,eggsteps,personalID,trainerID)  
end

def pbLoadTradeBitmapSpecies(species,eggsteps,personalID,trainerID)
    return RPG::Cache.load_bitmap(
    sprintf("Graphics/Pictures/Battle/ball00.png"))
end
 
def pbSetExtraSmallFont(bitmap)
  bitmap.font.name=MessageConfig.pbGetSystemFontName
  bitmap.font.size=32
end
 
def pbcheckShiny(personalID,trainerID)
 a=personalID.to_i^trainerID.to_i
 b=a&0xFFFF
 c=(a>>16)&0xFFFF
 d=b^c
 return (d<8)
end
