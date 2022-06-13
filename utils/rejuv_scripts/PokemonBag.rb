################################################################################
# The Bag.
################################################################################
class Window_PokemonBag < Window_DrawableCommand
  attr_reader :pocket
  attr_reader :sortIndex

  def initialize(bag,pocket,x,y,width,height)
    @bag=bag
    @pocket=pocket
    @sortIndex=-1
    @adapter=PokemonMartAdapter.new
    super(x,y,width,height)
    @selarrow=AnimatedBitmap.new("Graphics/Pictures/Bag/bagSel")
    self.windowskin=nil
  end

  def pocket=(value)
    @pocket=value
    thispocket=@bag.pockets[@pocket]
    @item_max=thispocket.length+1
    self.index=@bag.getChoice(@pocket)
    refresh
  end

  def sortIndex=(value)
    @sortIndex=value
    refresh
  end

  def page_row_max; return PokemonBag_Scene::ITEMSVISIBLE; end
  def page_item_max; return PokemonBag_Scene::ITEMSVISIBLE; end

  def itemRect(item)
    if item<0 || item>=@item_max || item<self.top_item-1 ||
       item>self.top_item+self.page_item_max
      return Rect.new(0,0,0,0)
    else
      cursor_width = (self.width-self.borderX-(@column_max-1)*@column_spacing) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = item / @column_max * @row_height - @virtualOy
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def drawCursor(index,rect)
    if self.index==index
      pbCopyBitmap(self.contents,@selarrow.bitmap,rect.x,rect.y+14)
    end
    return Rect.new(rect.x+16,rect.y+16,rect.width-16,rect.height)
  end

  def item
    thispocket=@bag.pockets[self.pocket]
    item=thispocket[self.index]
    return item ? item[0] : 0
  end

  def itemCount
    return @bag.pockets[self.pocket].length+1
  end

  def drawItem(index,count,rect)
    textpos=[]
    rect=drawCursor(index,rect)
    ypos=rect.y+4
    if index==@bag.pockets[self.pocket].length
      textpos.push([_INTL("CLOSE BAG"),rect.x,ypos,false,
         self.baseColor,self.shadowColor])
    else
      item=@bag.pockets[self.pocket][index][0]
      itemname=@adapter.getDisplayName(item)
      qty=_ISPRINTF("x{1: 2d}",@bag.pockets[self.pocket][index][1])
      sizeQty=self.contents.text_size(qty).width
      xQty=rect.x+rect.width-sizeQty-16
      baseColor=(index==@sortIndex) ? Color.new(224,0,0) : self.baseColor
      shadowColor=(index==@sortIndex) ? Color.new(248,144,144) : self.shadowColor
      textpos.push([itemname,rect.x,ypos,false,baseColor,shadowColor])
      if !pbIsImportantItem?(item) # Not a Key item or HM (or infinite TM)
        textpos.push([qty,xQty,ypos,false,baseColor,shadowColor])
      end
    end
    pbDrawTextPositions(self.contents,textpos)
    #MULTIPLEREGISTRATION
    if index!=@bag.pockets[self.pocket].length
i = @bag.registeredItem.index(@bag.pockets[self.pocket][index][0]) 
if i
  pbDrawImagePositions(self.contents,[
     [sprintf("Graphics/Pictures/Bag/bagReg#{i}"),rect.x+rect.width-58,ypos+4,0,0,-1,-1]
  ])
end
    end
  end

  def refresh
    @item_max=itemCount()
    dwidth=self.width-self.borderX
    dheight=self.height-self.borderY
    self.contents=pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...@item_max
      if i<self.top_item-1 || i>self.top_item+self.page_item_max
        next
      end
      drawItem(i,@item_max,itemRect(i))
    end
  end
end



class PokemonBag_Scene
## Configuration
  ITEMLISTBASECOLOR     = Color.new(88,88,80)
  ITEMLISTSHADOWCOLOR   = Color.new(168,184,184)
  ITEMTEXTBASECOLOR     = Color.new(248,248,248)
  ITEMTEXTSHADOWCOLOR   = Color.new(0,0,0)
  POCKETNAMEBASECOLOR   = Color.new(88,88,80)
  POCKETNAMESHADOWCOLOR = Color.new(168,184,184)
  ITEMSVISIBLE          = 7

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @bag=bag
    @sprites={}
    lastpocket=@bag.lastpocket
    lastitem=@bag.getChoice(lastpocket)
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/Bag/bagbg#{lastpocket}"))
    @sprites["leftarrow"]=AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"]=AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].play
    @sprites["rightarrow"].play
    @sprites["bag"]=IconSprite.new(30,20,@viewport)
    @sprites["icon"]=IconSprite.new(24,Graphics.height-72,@viewport)
    @sprites["itemwindow"]=Window_PokemonBag.new(@bag,lastpocket,168,-8,314,40+32+ITEMSVISIBLE*32)
    @sprites["itemwindow"].viewport=@viewport
    @sprites["itemwindow"].pocket=lastpocket
    @sprites["itemwindow"].index=lastitem
    @sprites["itemwindow"].baseColor=ITEMLISTBASECOLOR
    @sprites["itemwindow"].shadowColor=ITEMLISTSHADOWCOLOR
    @sprites["itemwindow"].refresh
    @sprites["slider"]=IconSprite.new(Graphics.width-40,60,@viewport)
    @sprites["slider"].setBitmap(sprintf("Graphics/Pictures/Bag/bagSlider"))
    @sprites["pocketwindow"]=BitmapSprite.new(186,228,@viewport)
    pbSetSystemFont(@sprites["pocketwindow"].bitmap)
    @sprites["itemtextwindow"]=Window_UnformattedTextPokemon.new("")
    @sprites["itemtextwindow"].x=72
    @sprites["itemtextwindow"].y=270
    @sprites["itemtextwindow"].width=Graphics.width-72
    @sprites["itemtextwindow"].height=128
    @sprites["itemtextwindow"].baseColor=ITEMTEXTBASECOLOR
    @sprites["itemtextwindow"].shadowColor=ITEMTEXTSHADOWCOLOR
    @sprites["itemtextwindow"].visible=true
    @sprites["itemtextwindow"].viewport=@viewport
    @sprites["itemtextwindow"].windowskin=nil
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].viewport=@viewport
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=false
    @sprites["msgwindow"].viewport=@viewport
    @sprites["partybg"]=IconSprite.new(0,0,@viewport)
    @sprites["partybg"].setBitmap(sprintf("Graphics/Pictures/tmPartyBackground")) rescue nil
    @sprites["partybg"].visible=false
    pbTMSprites
    pbBottomLeftLines(@sprites["helpwindow"],1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbTMSprites
    xvalues=[16,106,16,106,16,106]
    yvalues=[0,16,64,80,128,144]
    for i in 0...$Trainer.party.length
      if !@sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"]=IconSprite.new(0,0,@viewport)
        @sprites["pokemon#{i}"].setBitmap(pbPokemonIconFile($Trainer.party[i]))
        @sprites["pokemon#{i}"].src_rect=Rect.new(0,0,64,64)
        @sprites["pokemon#{i}"].x=xvalues[i]
        @sprites["pokemon#{i}"].y=yvalues[i]
        @sprites["pokemon#{i}"].visible=false
      else
        @sprites["pokemon#{i}"].setBitmap(pbPokemonIconFile($Trainer.party[i]))
        @sprites["pokemon#{i}"].src_rect=Rect.new(0,0,64,64)
      end
      unless @sprites["possiblelearn#{i}"]
        @sprites["possiblelearn#{i}"]=IconSprite.new(0,0,@viewport)
        @sprites["possiblelearn#{i}"].x=xvalues[i]+32
        @sprites["possiblelearn#{i}"].y=yvalues[i]+32
        @sprites["possiblelearn#{i}"].visible=false
      end      
    end
  end

  def pbChooseNumber(helptext,maximum)
    return UIHelper.pbChooseNumber(
       @sprites["helpwindow"],helptext,maximum) { update }
  end

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { update }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { update }
  end

  def pbShowCommands(helptext,commands)
    return UIHelper.pbShowCommands(
       @sprites["helpwindow"],helptext,commands) { update }
  end

  def pbRefresh
    bm=@sprites["pocketwindow"].bitmap
    bm.clear
    # Set the background bitmap for the currently selected pocket
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/Bag/bagbg#{@bag.lastpocket}"))
    # Set the bag picture for the currently selected pocket
    fbagexists=pbResolveBitmap(sprintf("Graphics/Pictures/Bag/bag#{@bag.lastpocket}f"))
    if $Trainer.isFemale? && fbagexists
      @sprites["bag"].setBitmap("Graphics/Pictures/Bag/bag#{@bag.lastpocket}f")
    else
      @sprites["bag"].setBitmap("Graphics/Pictures/Bag/bag#{@bag.lastpocket}")
    end
    # Draw the pocket name
    name=PokemonBag.pocketNames()[@bag.lastpocket]
    base=POCKETNAMEBASECOLOR
    shadow=POCKETNAMESHADOWCOLOR
    pbDrawTextPositions(bm,[
       [name,bm.width/2,180,2,base,shadow]
    ])
    # Reset positions of left/right arrows around the bag
    @sprites["leftarrow"].x=-4
    @sprites["leftarrow"].y=76
    @sprites["rightarrow"].x=150
    @sprites["rightarrow"].y=76
    itemwindow=@sprites["itemwindow"]
    # Draw the slider
    ycoord=60
    if itemwindow.itemCount>1
      ycoord+=116.0 * itemwindow.index/(itemwindow.itemCount-1)
    end
    @sprites["slider"].y=ycoord
    # Set the icon for the currently selected item
    filename=pbItemIconFile(itemwindow.item)
    @sprites["icon"].setBitmap(filename)
    # Display the item's description
    @sprites["itemtextwindow"].text=(itemwindow.item==0) ? _INTL("Close bag.") : 
       pbGetMessage(MessageTypes::ItemDescriptions,itemwindow.item)
    pbTMSprites
    # Refresh the item window
    itemwindow.refresh
  end

# Called when the item screen wants an item to be chosen from the screen
  def pbChooseItem
    pbRefresh
    @sprites["helpwindow"].visible=false
    itemwindow=@sprites["itemwindow"]
    itemwindow.refresh
    sorting=false
    sortindex=-1
    if $ItemData[itemwindow.item][ITEMUSE]==3 || $ItemData[itemwindow.item][ITEMUSE]==4
      machine=$ItemData[itemwindow.item][ITEMMACHINE]
      canlearnmove=PokemonBag.pbPartyCanLearnThisMove?(machine)
      pbRefresh
      @sprites["partybg"].visible=true
      for i in 0...6
        next if $Trainer.party[i].nil?
        @sprites["pokemon#{i}"].visible=true
        @sprites["possiblelearn#{i}"].visible=true
        case canlearnmove[i]
          when 0 #unable
            @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmnope")) rescue nil
          when 1 #able
            @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmcheck")) rescue nil
          when 2 #learned
            @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmdash")) rescue nil
        end
      end
    else
      pbRefresh
      @sprites["partybg"].visible=false 
      for i in 0...6
        next if $Trainer.party[i].nil?
        @sprites["pokemon#{i}"].visible=false
        @sprites["possiblelearn#{i}"].visible=false
      end
    end
    pbActivateWindow(@sprites,"itemwindow"){
       loop do
         Graphics.update
         Input.update
         olditem=itemwindow.item
         oldindex=itemwindow.index
         self.update
         if itemwindow.item!=olditem
           # Update slider position
           ycoord=60
           if itemwindow.itemCount>1
             ycoord+=116.0 * itemwindow.index/(itemwindow.itemCount-1)
           end
           @sprites["slider"].y=ycoord
           # Update item icon and description
           filename=pbItemIconFile(itemwindow.item)
           @sprites["icon"].setBitmap(filename)
           @sprites["itemtextwindow"].text=(itemwindow.item==0) ? _INTL("Close bag.") :
              pbGetMessage(MessageTypes::ItemDescriptions,itemwindow.item)
            if $ItemData[itemwindow.item][ITEMUSE]==3 || $ItemData[itemwindow.item][ITEMUSE]==4
              pbRefresh
              machine=$ItemData[itemwindow.item][ITEMMACHINE]
              canlearnmove=PokemonBag.pbPartyCanLearnThisMove?(machine)
              for i in 0...6
                next if $Trainer.party[i].nil?
                @sprites["pokemon#{i}"].visible=true
                @sprites["possiblelearn#{i}"].visible=true
                case canlearnmove[i]
                  when 0 #unable
                    @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmnope")) rescue nil
                  when 1 #able
                    @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmcheck")) rescue nil
                  when 2 #learned
                    @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmdash")) rescue nil
                  end
              end
            else
              for i in 0...6
                next if $Trainer.party[i].nil?
                @sprites["possiblelearn#{i}"].visible=false
              end
            end
         end
         if itemwindow.index!=oldindex
           # Update selected item for current pocket
           @bag.setChoice(itemwindow.pocket,itemwindow.index)
         end
         # Change pockets if Left/Right pressed
         numpockets=PokemonBag.numPockets
         if Input.trigger?(Input::LEFT)
           if !sorting
             itemwindow.pocket=(itemwindow.pocket==1) ? numpockets : itemwindow.pocket-1
             @bag.lastpocket=itemwindow.pocket
             pbRefresh
             if $ItemData[itemwindow.item][ITEMUSE]==3 || $ItemData[itemwindow.item][ITEMUSE]==4
              machine=$ItemData[itemwindow.item][ITEMMACHINE]
              canlearnmove=PokemonBag.pbPartyCanLearnThisMove?(machine)
              @sprites["partybg"].visible=true
              for i in 0...6
                next if $Trainer.party[i].nil?
                @sprites["pokemon#{i}"].visible=true
                @sprites["possiblelearn#{i}"].visible=true
                case canlearnmove[i]
                  when 0 #unable
                    @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmnope")) rescue nil
                  when 1 #able
                    @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmcheck")) rescue nil
                  when 2 #learned
                    @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmdash")) rescue nil
                end
              end
            else
              @sprites["partybg"].visible=false
              for i in 0...6
                next if $Trainer.party[i].nil?
                @sprites["pokemon#{i}"].visible=false
                @sprites["possiblelearn#{i}"].visible=false
              end
            end
           end
         elsif Input.trigger?(Input::RIGHT)
           if !sorting
             itemwindow.pocket=(itemwindow.pocket==numpockets) ? 1 : itemwindow.pocket+1
             @bag.lastpocket=itemwindow.pocket
             pbRefresh
             if $ItemData[itemwindow.item][ITEMUSE]==3 || $ItemData[itemwindow.item][ITEMUSE]==4
              machine=$ItemData[itemwindow.item][ITEMMACHINE]
              canlearnmove=PokemonBag.pbPartyCanLearnThisMove?(machine)
              @sprites["partybg"].visible=true
              for i in 0...6
                next if $Trainer.party[i].nil?
                @sprites["pokemon#{i}"].visible=true
                @sprites["possiblelearn#{i}"].visible=true
                case canlearnmove[i]
                  when 0 #unable
                    @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmnope")) rescue nil
                  when 1 #able
                    @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmcheck")) rescue nil
                  when 2 #learned
                    @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/tmdash")) rescue nil
                end
              end
            else
              pbRefresh
              @sprites["partybg"].visible=false 
              for i in 0...6
                next if $Trainer.party[i].nil?
                @sprites["pokemon#{i}"].visible=false
                @sprites["possiblelearn#{i}"].visible=false
              end
            end
           end
         end
         if Input.trigger?(Input::X)
           pocket  = @bag.pockets[itemwindow.pocket]
           counter = 1
           while counter < pocket.length
             index     = counter
             while index > 0
               indexPrev = index - 1
               if itemwindow.pocket==4
                 firstName  = (((PBItems.getName(pocket[indexPrev][0])).sub("TM","00")).sub("X","100")).to_i
                 secondName = (((PBItems.getName(pocket[index][0])).sub("TM","00")).sub("X","100")).to_i                 
               else                 
                 firstName  = PBItems.getName(pocket[indexPrev][0])
                 secondName = PBItems.getName(pocket[index][0])               
               end               
               if firstName > secondName
                 aux               = pocket[index] 
                 pocket[index]     = pocket[indexPrev]
                 pocket[indexPrev] = aux
               end
               index -= 1
             end
             counter += 1
           end
           pbRefresh
         end
# Select item for switching if A is pressed
         if Input.trigger?(Input::F5)
           thispocket=@bag.pockets[itemwindow.pocket]
           if itemwindow.index<thispocket.length && thispocket.length>1 &&
              !POCKETAUTOSORT[itemwindow.pocket]
             sortindex=itemwindow.index
             sorting=true
             @sprites["itemwindow"].sortIndex=sortindex
           else
             next
           end
         end
         # Cancel switching or cancel the item screen
         if Input.trigger?(Input::B)
           if sorting
             sorting=false
             @sprites["itemwindow"].sortIndex=-1
           else
             return 0
           end
         end
         # Confirm selection or item switch
         if Input.trigger?(Input::C)
           thispocket=@bag.pockets[itemwindow.pocket]
           if itemwindow.index<thispocket.length
             if sorting
               sorting=false
               tmp=thispocket[itemwindow.index]
               thispocket[itemwindow.index]=thispocket[sortindex]
               thispocket[sortindex]=tmp
               @sprites["itemwindow"].sortIndex=-1
               pbRefresh
               next
             else
               pbRefresh
               return thispocket[itemwindow.index][0]
             end
           else
             return 0
           end
         end
       end
    }
  end
end



class PokemonBag
def registeredItem
  # The below line is to this change don't mess with existing saves
  @registeredItem = [@registeredItem] if !@registeredItem.is_a?(Array) 
  while @registeredItem.size<Input::ITEMKEYS.size
    @registeredItem.push(nil)
  end
  return @registeredItem
end
  attr_accessor :lastpocket
  attr_reader :pockets

  def self.pocketNames()
    return pbPocketNames
  end

  def self.numPockets()
    return self.pocketNames().length-1
  end

  def initialize
    @lastpocket=1
    @pockets=[]
    @choices=[]
    # Initialize each pocket of the array
    for i in 0..PokemonBag.numPockets
      @pockets[i]=[]
      @choices[i]=0
    end
    @registeredItem=[]
  end

  def pockets
    rearrange()
    return @pockets
  end
  
  def rearrange()
    if @pockets.length==6 && PokemonBag.numPockets==8
      newpockets=[]
      for i in 0..8
        newpockets[i]=[]
        @choices[i]=0 if !@choices[i]
      end
      for i in 0..5
        for item in @pockets[i]
          newpockets[pbGetPocket(item[0])].push(item)
        end
      end
      @pockets=newpockets
    end
  end

  def self.pbPartyCanLearnThisMove?(move)
    trutharray=[]
    for i in $Trainer.party
      learned=false
      unless i.isEgg?
        for j in 0..3
          learned=true if i.moves[j].id==move
        end
      end
      if learned
        trutharray.push(2) #learned
      elsif i.isEgg? || (i.isShadow? rescue false) || !pbSpeciesCompatible?(i.species,move,i)
        trutharray.push(0) #unable
      else 
        trutharray.push(1) #able
      end
    end
    return trutharray
  end 

# Gets the index of the current selected item in the pocket
  def getChoice(pocket)
    if pocket<=0 || pocket>PokemonBag.numPockets
      raise ArgumentError.new(_INTL("Invalid pocket: {1}",pocket.inspect))
    end
    rearrange()
    return [@choices[pocket],@pockets[pocket].length].min || 0
  end
   
# Clears the entire bag
  def clear
    for pocket in @pockets
      pocket.clear
    end
  end

# Sets the index of the current selected item in the pocket
  def setChoice(pocket,value)
    if pocket<=0 || pocket>PokemonBag.numPockets
      raise ArgumentError.new(_INTL("Invalid pocket: {1}",pocket.inspect))
    end
    rearrange()
    @choices[pocket]=value if value<=@pockets[pocket].length
  end

# Registers the item as a key item.  Can be retrieved with $PokemonBag.registeredItem
def pbRegisterKeyItem(item,itemKeyNumber)
  index = registeredItem.index(item)
  registeredItem[index]=nil if index # remove duplicates
  registeredItem[itemKeyNumber]=item if !index || index!=itemKeyNumber
end

  def maxPocketSize(pocket)
    maxsize=MAXPOCKETSIZE[pocket]
    return -1 if !maxsize
    return maxsize
  end

  def pbQuantity(item)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("The item number is invalid.",item))
      return 0
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length if maxsize<0
    return ItemStorageHelper.pbQuantity(@pockets[pocket],maxsize,item)
  end

#### SARDINES - v17 - START
  def pbHasItem?(item)
    return pbQuantity(item)>0
  end
#### SARDINES - v17 - END

  def pbDeleteItem(item,qty=1)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("The item number is invalid.",item))
      return false
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length if maxsize<0
    ret=ItemStorageHelper.pbDeleteItem(@pockets[pocket],maxsize,item,qty)
    if ret
      index = registeredItem.index(item)
      registeredItem[index]=nil if index && !pbHasItem?(item)
    end
    return ret
  end

  def pbCanStore?(item,qty=1)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("The item number is invalid.",item))
      return false
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length+1 if maxsize<0
    return ItemStorageHelper.pbCanStore?(
       @pockets[pocket],maxsize,BAGMAXPERSLOT,item,qty)
  end

  def pbStoreAllOrNone(item,qty=1)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("The item number is invalid.",item))
      return false
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length+1 if maxsize<0
    return ItemStorageHelper.pbStoreAllOrNone(
       @pockets[pocket],maxsize,BAGMAXPERSLOT,item,qty)
  end

  def pbStoreItem(item,qty=1)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("The item number is invalid.",item))
      return false
    end
    if item.pbIsZCrystal?(item)
      return true
    end
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length+1 if maxsize<0
    return ItemStorageHelper.pbStoreItem(
      @pockets[pocket],maxsize,BAGMAXPERSLOT,item,qty,true)
  end

  def pbChangeItem(olditem,newitem)
    if olditem.is_a?(String) || olditem.is_a?(Symbol)
      olditem = getID(PBItems,olditem)
    end
    if newitem.is_a?(String) || newitem.is_a?(Symbol)
      newitem = getID(PBItems,newitem)
    end
    if !olditem || olditem<1
      raise ArgumentError.new(_INTL("Item number {1} is invalid.",olditem))
      return false
    elsif !newitem || newitem<1
      raise ArgumentError.new(_INTL("Item number {1} is invalid.",newitem))
      return false
    end
    pocket = pbGetPocket(olditem)
    maxsize = maxPocketSize(pocket)
    maxsize = @pockets[pocket].length if maxsize<0
    ret = false
    for i in 0...maxsize
      itemslot = @pockets[pocket][i]
      if itemslot && itemslot[0]==olditem
        itemslot[0] = newitem
        ret = true
      end
    end
    return ret
  end

    
end



class PokemonBagScreen
  def initialize(scene,bag)
    @bag=bag
    @scene=scene
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

# UI logic for the item screen when an item is to be held by a Pokémon.
  def pbGiveItemScreen
    @scene.pbStartScene(@bag)
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      itemname=PBItems.getName(item)
      # Key items and hidden machines can't be held
      if pbIsImportantItem?(item)
        @scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
        next
      else
        break
      end
    end
    @scene.pbEndScene
    return item
  end

# UI logic for the item screen for choosing an item
  def pbChooseItemScreen
    oldlastpocket=@bag.lastpocket
    @scene.pbStartScene(@bag)
    item=@scene.pbChooseItem
    @scene.pbEndScene
    @bag.lastpocket=oldlastpocket
    return item
  end

# UI logic for the item screen for choosing a Berry
  def pbChooseBerryScreen
    oldlastpocket=@bag.lastpocket
    @bag.lastpocket=BERRYPOCKET
    @scene.pbStartScene(@bag)
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      itemname=PBItems.getName(item)
      if !pbIsBerry?(item)
        @scene.pbDisplay(_INTL("That's not a Berry.",itemname))
        next
      else
        break
      end
    end
    @scene.pbEndScene
    @bag.lastpocket=oldlastpocket
    return item
  end

# UI logic for tossing an item in the item screen.
  def pbTossItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage=PCItemStorage.new
    end
    storage=$PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage)
    loop do
      item=@scene.pbChooseItem
      break if item==0
      if pbIsImportantItem?(item) || pbIsCrest?(item)
        @scene.pbDisplay(_INTL("That's too important to toss out!"))
        next
      end
      qty=storage.pbQuantity(item)
      itemname=PBItems.getName(item)
      if qty>1
        qty=@scene.pbChooseNumber(_INTL("Toss out how many {1}(s)?",itemname),qty)
      end
      if qty>0
        if pbConfirm(_INTL("Is it OK to throw away {1} {2}(s)?",qty,itemname))
          if !storage.pbDeleteItem(item,qty)
            raise "Can't delete items from storage"
          end
          pbDisplay(_INTL("Threw away {1} {2}(s).",qty,itemname))
        end
      end
    end
    @scene.pbEndScene
  end

# UI logic for withdrawing an item in the item screen.
  def pbWithdrawItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage=PCItemStorage.new
    end
    storage=$PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage)
    loop do
      item=@scene.pbChooseItem
      break if item==0
      commands=[_INTL("Withdraw"),_INTL("Give"),_INTL("Cancel")]
      itemname=PBItems.getName(item)
      command=@scene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
      if command==0
        qty=storage.pbQuantity(item)
        if qty>1
          qty=@scene.pbChooseNumber(_INTL("How many do you want to withdraw?"),qty)
        end
        if qty>0
          if !@bag.pbCanStore?(item,qty)
            pbDisplay(_INTL("There's no more room in the Bag."))
          else
            pbDisplay(_INTL("Withdrew {1} {2}(s).",qty,itemname))
            if !storage.pbDeleteItem(item,qty)
              raise "Can't delete items from storage"
            end
            if !@bag.pbStoreItem(item,qty)
              raise "Can't withdraw items from storage"
            end
          end
        end
      elsif command==1 && !$game_switches[1235] # Give
        if $Trainer.pokemonCount==0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
          return 0
        elsif pbIsImportantItem?(item)
          @scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
        else
          pbFadeOutIn(99999){
             sscene=PokemonScreen_Scene.new
             sscreen=PokemonScreen.new(sscene,$Trainer.party)
             if sscreen.pbPokemonGiveScreen(item)
               # If the item was held, delete the item from storage
               if !storage.pbDeleteItem(item,1)
                 raise "Can't delete item from storage"
               end
             end
             @scene.pbRefresh
          }
        end
      elsif command==1 && ($game_switches[1235] && !($game_switches[1408])) || ($game_variables[646]>=38 &&  $game_variables[646]<41) # Give
        @scene.pbDisplay(_INTL("You cannot give an item."))
      end
    end
    @scene.pbEndScene
  end

# UI logic for depositing an item in the item screen.
  def pbDepositItemScreen
    @scene.pbStartScene(@bag)
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage=PCItemStorage.new
    end
    storage=$PokemonGlobal.pcItemStorage
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      qty=@bag.pbQuantity(item)    
      if qty>1
        qty=@scene.pbChooseNumber(_INTL("How many do you want to deposit?"),qty)
      end      
      if qty>0
        itemname=PBItems.getName(item)
        if !storage.pbCanStore?(item,qty)
          pbDisplay(_INTL("There's no room to store items."))
        elsif pbIsKeyItem?(item) || pbIsZCrystal?(item)
          pbDisplay(_INTL("You can't store a Key Item!"))
        else
          pbDisplay(_INTL("Deposited {1} {2}(s).",qty,itemname))
          if !@bag.pbDeleteItem(item,qty)
            raise "Can't delete items from bag"
          end
          if !storage.pbStoreItem(item,qty)
            raise "Can't deposit items to storage"
          end
        end
      end
    end
    @scene.pbEndScene
  end

  def pbStartScreen
    @scene.pbStartScene(@bag)
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      cmdUse=-1
      cmdRegister=-1
      cmdGive=-1
      cmdToss=-1
      cmdRead=-1
      cmdMysteryGift=-1
      commands=[]
      # Generate command list
      commands[cmdRead=commands.length]=_INTL("Read") if pbIsMail?(item)
      commands[cmdUse=commands.length]=_INTL("Use") if ItemHandlers.hasOutHandler(item) || (pbIsMachine?(item) && $Trainer.party.length>0)
      commands[cmdGive=commands.length]=_INTL("Give") if $Trainer.party.length>0 && !pbIsImportantItem?(item)
      commands[cmdToss=commands.length]=_INTL("Toss") if (!pbIsImportantItem?(item) && !pbIsCrest?(item)) || $DEBUG
      commands[cmdRegister=commands.length]=_INTL("Register") if pbIsKeyItem?(item) && ItemHandlers.hasKeyItemHandler(item)
      commands[cmdMysteryGift=commands.length]=_INTL("Make Mystery Gift") if $DEBUG
      commands[commands.length]=_INTL("Cancel")
      # Show commands generated above
      itemname=PBItems.getName(item) # Get item name
      command=@scene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
      if cmdUse>=0 && command==cmdUse # Use item
        ret=pbUseItem(@bag,item,@scene)
        # 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
        break if ret==2 # End screen
        @scene.pbRefresh
        next
      elsif cmdRead>=0 && command==cmdRead # Read mail
        pbFadeOutIn(99999){
           pbDisplayMail(PokemonMail.new(item,"",""))
        }
      elsif cmdRegister>=0 && command==cmdRegister # Register key item
      registerCommands = Input::ITEMKEYSNAMES + [_INTL("Back")]
      registerCommand = @scene.pbShowCommands(
          _INTL("Choose a key.",itemname),registerCommands)
      @bag.pbRegisterKeyItem(item,registerCommand) if registerCommand!=-1 && registerCommand!=registerCommands.size
        @scene.pbRefresh
      elsif cmdGive>=0 && command==cmdGive && !($game_switches[1235] && !($game_switches[1408])) # Give item to Pokémon
        if $Trainer.pokemonCount==0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
        elsif pbIsImportantItem?(item)
          @scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
        else
          # Give item to a Pokémon
          pbFadeOutIn(99999){
             sscene=PokemonScreen_Scene.new
             sscreen=PokemonScreen.new(sscene,$Trainer.party)
             sscreen.pbPokemonGiveScreen(item)
             @scene.pbRefresh
          }
        end
      elsif cmdGive>=0 && command==cmdGive && ($game_switches[1235] && !($game_switches[1408]))  || ($game_variables[646]>=38 &&  $game_variables[646]<41) # Give item to Pokémon
        @scene.pbDisplay(_INTL("You cannot give an item."))
      elsif cmdToss>=0 && command==cmdToss # Toss item
        qty=@bag.pbQuantity(item)
        helptext=_INTL("Toss out how many {1}(s)?",itemname)
        qty=@scene.pbChooseNumber(helptext,qty)
        if qty>0
          if pbConfirm(_INTL("Is it OK to throw away {1} {2}(s)?",qty,itemname))
            pbDisplay(_INTL("Threw away {1} {2}(s).",qty,itemname))
            qty.times { @bag.pbDeleteItem(item) }      
          end
        end   
      elsif cmdMysteryGift>=0 && command==cmdMysteryGift   # Export to Mystery Gift
        pbCreateMysteryGift(1,item)
      end
    end
    @scene.pbEndScene
    return item
  end
end



################################################################################
# PC item storage.
################################################################################
class Window_PokemonItemStorage < Window_DrawableCommand
  attr_reader :bag
  attr_reader :pocket
  attr_reader :sortIndex

  def sortIndex=(value)
    @sortIndex=value
    refresh
  end

  def initialize(bag,x,y,width,height)
    @bag=bag
    @sortIndex=-1
    @adapter=PokemonMartAdapter.new
    super(x,y,width,height)
    self.windowskin=nil
  end

  def item
    item=@bag[self.index]
    return item ? item[0] : 0
  end

  def itemCount
    return @bag.length+1
  end

  def drawItem(index,count,rect)
    textpos=[]
    rect=drawCursor(index,rect)
    ypos=rect.y
    if index==@bag.length
      textpos.push([_INTL("CANCEL"),rect.x,ypos,false,
         self.baseColor,self.shadowColor])
    else
      item=@bag[index][0]
      itemname=@adapter.getDisplayName(item)
      qty=_ISPRINTF("x{1: 2d}",@bag[index][1])
      sizeQty=self.contents.text_size(qty).width
      xQty=rect.x+rect.width-sizeQty-2
      baseColor=(index==@sortIndex) ? Color.new(248,24,24) : self.baseColor
      textpos.push([itemname,rect.x,ypos,false,self.baseColor,self.shadowColor])
      if !pbIsImportantItem?(item) # Not a Key item or HM (or infinite TM)
        textpos.push([qty,xQty,ypos,false,baseColor,self.shadowColor])
      end
    end
    pbDrawTextPositions(self.contents,textpos)
  end
end



class ItemStorageScene
## Configuration
  ITEMLISTBASECOLOR   = Color.new(88,88,80)
  ITEMLISTSHADOWCOLOR = Color.new(168,184,184)
  ITEMTEXTBASECOLOR   = Color.new(248,248,248)
  ITEMTEXTSHADOWCOLOR = Color.new(0,0,0)
  TITLEBASECOLOR      = Color.new(248,248,248)
  TITLESHADOWCOLOR    = Color.new(0,0,0)
  ITEMSVISIBLE        = 7

  def initialize(title)
    @title=title
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @bag=bag
    @sprites={}
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/pcItembg")
    @sprites["icon"]=IconSprite.new(26,310,@viewport)
    # Item list
    @sprites["itemwindow"]=Window_PokemonItemStorage.new(@bag,98,14,334,32+ITEMSVISIBLE*32)
    @sprites["itemwindow"].viewport=@viewport
    @sprites["itemwindow"].index=0
    @sprites["itemwindow"].baseColor=ITEMLISTBASECOLOR
    @sprites["itemwindow"].shadowColor=ITEMLISTSHADOWCOLOR
    @sprites["itemwindow"].refresh
    # Title
    @sprites["pocketwindow"]=BitmapSprite.new(88,64,@viewport)
    @sprites["pocketwindow"].x=14
    @sprites["pocketwindow"].y=16
    pbSetNarrowFont(@sprites["pocketwindow"].bitmap)
    # Item description  
    @sprites["itemtextwindow"]=Window_UnformattedTextPokemon.newWithSize("",84,270,Graphics.width-84,128,@viewport)
    @sprites["itemtextwindow"].baseColor=ITEMTEXTBASECOLOR
    @sprites["itemtextwindow"].shadowColor=ITEMTEXTSHADOWCOLOR
    @sprites["itemtextwindow"].windowskin=nil
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].viewport=@viewport
    # Letter-by-letter message window
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=false
    @sprites["msgwindow"].viewport=@viewport
    pbBottomLeftLines(@sprites["helpwindow"],1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh
    bm=@sprites["pocketwindow"].bitmap
    # Draw title at upper left corner ("Toss Item/Withdraw Item")
    drawTextEx(bm,0,0,bm.width,2,@title,TITLEBASECOLOR,TITLESHADOWCOLOR)
    itemwindow=@sprites["itemwindow"]
    # Draw item icon
    filename=pbItemIconFile(itemwindow.item)
    @sprites["icon"].setBitmap(filename)
    # Get item description
    @sprites["itemtextwindow"].text=(itemwindow.item==0) ? _INTL("Close storage.") : 
       pbGetMessage(MessageTypes::ItemDescriptions,itemwindow.item)
    itemwindow.refresh
  end

  def pbChooseItem
    pbRefresh
    @sprites["helpwindow"].visible=false
    itemwindow=@sprites["itemwindow"]
    itemwindow.refresh
    pbActivateWindow(@sprites,"itemwindow"){
       loop do
         Graphics.update
         Input.update
         olditem=itemwindow.item
         self.update
         if itemwindow.item!=olditem
           self.pbRefresh
         end
        if Input.trigger?(Input::X)          
           counter = 1
           while counter < @bag.items.length
             index     = counter
             while index > 0
               indexPrev = index - 1              
               firstName  = PBItems.getName(@bag.items[indexPrev][0])
               secondName = PBItems.getName(@bag.items[index][0])                           
               if firstName > secondName
                 aux               = @bag.items[index] 
                 @bag.items[index]     = @bag.items[indexPrev]
                 @bag.items[indexPrev] = aux
               end
               index -= 1
             end
             counter += 1
           end
           pbRefresh
        end         
         if Input.trigger?(Input::B)
           return 0
         end
         if Input.trigger?(Input::C)
           if itemwindow.index<@bag.length
             pbRefresh
             return @bag[itemwindow.index][0]
           else
             return 0
           end
         end
       end
    }
  end

  def pbChooseNumber(helptext,maximum)
    return UIHelper.pbChooseNumber(
       @sprites["helpwindow"],helptext,maximum) { update }
  end

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { update }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { update }
  end

  def pbShowCommands(helptext,commands)
    return UIHelper.pbShowCommands(
       @sprites["helpwindow"],helptext,commands) { update }
  end
end



class WithdrawItemScene < ItemStorageScene
  def initialize
    super(_INTL("Withdraw\nItem"))
  end
end



class TossItemScene < ItemStorageScene
  def initialize
    super(_INTL("Toss\nItem"))
  end
end



class PCItemStorage
  MAXSIZE=50
  MAXPERSLOT=999

  def initialize
    @items=[]
    # Start storage with a Potion
    if hasConst?(PBItems,:POTION)
      ItemStorageHelper.pbStoreItem(
         @items,MAXSIZE,MAXPERSLOT,getConst(PBItems,:POTION),1)
    end
  end

  def items
    return @items
  end  
  
  def empty?
    return @items.length==0
  end

  def length
    @items.length
  end

  def [](i)
    @items[i]
  end

  def getItem(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][0]
    end
  end

  def getCount(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][1]
    end
  end

  def pbQuantity(item)
    return ItemStorageHelper.pbQuantity(@items,MAXSIZE,item)
  end

  def pbDeleteItem(item,qty=1)
    return ItemStorageHelper.pbDeleteItem(@items,MAXSIZE,item,qty)
  end

  def pbCanStore?(item,qty=1)
    return ItemStorageHelper.pbCanStore?(@items,MAXSIZE,MAXPERSLOT,item,qty)
  end

  def pbStoreItem(item,qty=1)
    return ItemStorageHelper.pbStoreItem(@items,MAXSIZE,MAXPERSLOT,item,qty)
  end
end





################################################################################
# Common UI functions used in both the Bag and item storage screens.
# Allows the user to choose a number.  The window _helpwindow_ will
# display the _helptext_.
################################################################################
module UIHelper
  def self.pbChooseNumber(helpwindow,helptext,maximum)
    oldvisible=helpwindow.visible
    helpwindow.visible=true
    helpwindow.text=helptext
    helpwindow.letterbyletter=false
    curnumber=1
    ret=0
    (numwindow=Window_UnformattedTextPokemon.new("x000"))
       numwindow.viewport=helpwindow.viewport
       numwindow.letterbyletter=false
       numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
       numwindow.resizeToFit(numwindow.text,480)
       pbBottomRight(numwindow) # Move number window to the bottom right
       helpwindow.resizeHeightToFit(helpwindow.text,480-numwindow.width)
       pbBottomLeft(helpwindow) # Move help window to the bottom left
       loop do
         Graphics.update
         Input.update
         numwindow.update
         block_given? ? yield : helpwindow.update
         if Input.repeat?(Input::LEFT)
           curnumber-=10
           curnumber=1 if curnumber<1
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           pbPlayCursorSE()
         elsif Input.repeat?(Input::RIGHT)
           curnumber+=10
           curnumber=maximum if curnumber>maximum
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           pbPlayCursorSE()
         elsif Input.repeat?(Input::UP)
           curnumber+=1
           curnumber=1 if curnumber>maximum
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           pbPlayCursorSE()
         elsif Input.repeat?(Input::DOWN)
           curnumber-=1
           curnumber=maximum if curnumber<1
           numwindow.text=_ISPRINTF("x{1:03d}",curnumber)
           pbPlayCursorSE()
         elsif Input.trigger?(Input::C)
           ret=curnumber
           pbPlayDecisionSE()
           break
         elsif Input.trigger?(Input::B)
           ret=0
           pbPlayCancelSE()
           break
         end
       end
       numwindow.visible=false
    helpwindow.visible=oldvisible
    return ret
  end

  def self.pbDisplayStatic(msgwindow,message)
    oldvisible=msgwindow.visible
    msgwindow.visible=true
    msgwindow.letterbyletter=false
    msgwindow.width=Graphics.width
    msgwindow.resizeHeightToFit(message,Graphics.width)
    msgwindow.text=message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        break
      end
      if Input.trigger?(Input::C)
        break
      end
      block_given? ? yield : msgwindow.update
    end
    msgwindow.visible=oldvisible
    Input.update
  end

# Letter by letter display of the message _msg_ by the window _helpwindow_.
  def self.pbDisplay(helpwindow,msg,brief)
    cw=helpwindow
    cw.letterbyletter=true
    cw.text=msg+"\1"
    pbBottomLeftLines(cw,2)
    oldvisible=cw.visible
    cw.visible=true
    loop do
      Graphics.update
      Input.update
      block_given? ? yield : cw.update
      if brief && !cw.busy?
        cw.visible=oldvisible
        return
      end
      if Input.trigger?(Input::C) && cw.resume && !cw.busy?
        cw.visible=oldvisible
        return
      end
    end
  end

# Letter by letter display of the message _msg_ by the window _helpwindow_,
# used to ask questions.  Returns true if the user chose yes, false if no.
  def self.pbConfirm(helpwindow,msg)
    dw=helpwindow
    oldvisible=dw.visible
    dw.letterbyletter=true
    dw.text=msg
    dw.visible=true
    pbBottomLeftLines(dw,2)
    commands=[_INTL("Yes"),_INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport=helpwindow.viewport
    pbBottomRight(cw)
    cw.y-=dw.height
    cw.index=0
    loop do
      cw.visible=!dw.busy?
      Graphics.update
      Input.update
      cw.update
      block_given? ? yield : dw.update
      if Input.trigger?(Input::B) && dw.resume && !dw.busy?
        cw.dispose
        dw.visible=oldvisible
        pbPlayCancelSE()
        return false
      end
      if Input.trigger?(Input::C) && dw.resume && !dw.busy?
        cwIndex=cw.index
        cw.dispose
        dw.visible=oldvisible
        pbPlayDecisionSE()
        return (cwIndex==0)?true:false
      end
    end
  end

  def self.pbShowCommands(helpwindow,helptext,commands)
    ret=-1
    oldvisible=helpwindow.visible
    helpwindow.visible=helptext ? true : false
    helpwindow.letterbyletter=false
    helpwindow.text=helptext ? helptext : ""
    cmdwindow=Window_CommandPokemon.new(commands)
    begin
      cmdwindow.viewport=helpwindow.viewport
      pbBottomRight(cmdwindow)
      helpwindow.resizeHeightToFit(helpwindow.text,480-cmdwindow.width)
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        yield
        cmdwindow.update
        if Input.trigger?(Input::B)
          ret=-1
          pbPlayCancelSE()
          break
        end
        if Input.trigger?(Input::C)
          ret=cmdwindow.index
          pbPlayDecisionSE()
          break
        end
      end
      ensure
      cmdwindow.dispose if cmdwindow
    end
    helpwindow.visible=oldvisible
    return ret
  end
end