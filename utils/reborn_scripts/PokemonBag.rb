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
    if index!=@bag.pockets[self.pocket].length
      if @bag.pbIsRegistered?(item)
        pbDrawImagePositions(self.contents,[
           ["Graphics/Pictures/Bag/bagReg",rect.x+rect.width-58,ypos+4,0,0,-1,-1]
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
    @sprites["partybg"].setBitmap(sprintf("Graphics/Pictures/Bag/tmPartyBackground")) rescue nil
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
        @sprites["pokemon#{i}"].bitmap = pbPokemonIconBitmap($Trainer.party[i],$Trainer.party[i].isEgg?)
        @sprites["pokemon#{i}"].src_rect=Rect.new(0,0,64,64)
        @sprites["pokemon#{i}"].x=xvalues[i]
        @sprites["pokemon#{i}"].y=yvalues[i]
        @sprites["pokemon#{i}"].visible=false
      else
        @sprites["pokemon#{i}"].bitmap = pbPokemonIconBitmap($Trainer.party[i],$Trainer.party[i].isEgg?)
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

  def pbDetermineTMmenu(itemwindow)
    if $cache.items[itemwindow.item][ITEMUSE]==3 || $cache.items[itemwindow.item][ITEMUSE]==4 || itemwindow.pocket==4
      machine=$cache.items[itemwindow.item][ITEMMACHINE]
      canlearnmove=PokemonBag.pbPartyCanLearnThisMove?(machine)
      @sprites["partybg"].visible=true
      for i in 0...$Trainer.party.length 
        @sprites["pokemon#{i}"].visible=true
        @sprites["possiblelearn#{i}"].visible=true
        case canlearnmove[i]
          when 0 #unable
            @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/Bag/tmnope")) rescue nil
          when 1 #able
            @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/Bag/tmcheck")) rescue nil
          when 2 #learned
            @sprites["possiblelearn#{i}"].setBitmap(sprintf("Graphics/Pictures/Bag/tmdash")) rescue nil
          else
            @sprites["possiblelearn#{i}"].setBitmap(nil)
        end
      end
    else
      @sprites["partybg"].visible=false 
      for i in 0...$Trainer.party.length
        @sprites["pokemon#{i}"].visible=false
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
    @sprites["bag"].setBitmap("Graphics/Pictures/Bag/bag")
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
    # Refresh the item window
    itemwindow.refresh
  end

# Called when the item screen wants an item to be chosen from the screen
  def pbChooseItem
    pbRefresh
    pbTMSprites
    @sprites["helpwindow"].visible=false
    itemwindow=@sprites["itemwindow"]
    itemwindow.refresh
    sorting=false
    sortindex=-1
    pbDetermineTMmenu(itemwindow)
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
           pbDetermineTMmenu(itemwindow)
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
             pbDetermineTMmenu(itemwindow)
           end
         elsif Input.trigger?(Input::RIGHT)
           if !sorting
             itemwindow.pocket=(itemwindow.pocket==numpockets) ? 1 : itemwindow.pocket+1
             @bag.lastpocket=itemwindow.pocket
             pbRefresh
             pbDetermineTMmenu(itemwindow)
           end
         end
         if Input.trigger?(Input::X)
           if pbHandleSortByType(itemwindow.pocket) # Returns true if the default sorting should be used
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
           end
           pbRefresh
         end
# Select item for switching if A is pressed
         if Input.trigger?(Input::Y)
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

  def pbHandleSortByType(pocket)
    # Returns true if the default sorting should be used
    return true if !pbShouldSortByType?
    items=@bag.pockets[pocket]
    if pocket == 4
      pbSortByMoveName(items)
    else
      pbSortByItemType(items)
    end
    return false
  end

  def pbShouldSortByType?
    return $idk[:settings].bagsorttype==1
  end

  def pbSortByMoveName(items)
    result=items.sort { |a,b| pbGetMachineMoveName(a) <=> pbGetMachineMoveName(b) }
    pbApplySortingResult(items, result)
  end

  def pbGetMachineMoveName(machine)
    itemId=machine[ITEMID]
    return PBMoves.getName($cache.items[itemId][ITEMMACHINE])
  end

  def pbSortByItemType(items)
    result=items.sort { |a,b| pbGetItemTypeIndex(a) <=> pbGetItemTypeIndex(b) }
    pbApplySortingResult(items, result)
  end

  def pbGetItemTypeIndex(item)
    mapping=pbGetSortOrderByTypeMapping
    itemId=item[ITEMID]
    result=mapping[itemId]
    return result if result
    # Not in the custom order => sort by name instead
    return PBItems.getName(itemId)
  end

  def pbApplySortingResult(items, result)
    # Makes use of the fact that a pointer is passed for arrays rather
    # than the content of the variable itself
    for i in 0...items.length
      items[i]=result[i]
    end
  end

  def pbGetSortOrderByTypeMapping
    # The cost of keeping the mapping in memory in case the user sorts the bag may outweigh
    # the CPU cost of re-parsing the sort order every time, so the cache hasn't been applied
    # here for the moment
    # Use the cached mapping if possible
    return @sortOrderMapping if defined?(@sortOrderMapping)

    # First, get all items in the same array
    # ...yeah, categories don't matter, they are just to make it easier to edit the order
    order=pbGetSortOrderByType
    categories=[]
    for cat in order
      categories.push(*cat[:items])
    end
    # Now transform the array into an hash, where the values are the array's indexes
    # as a padded string - this way we can later use the item name as a fallback
    # when the item is not mapped, and still have this work correctly for the others
    maxLen="#{categories.length}".length
    result={}
    for i in 0...categories.length
      itemId=categories[i]
      result[itemId]="#{i}".rjust(maxLen, '0')
    end
    @sortOrderMapping=result
    return @sortOrderMapping
    return result
  end

  def pbGetSortOrderByType
    # Item ids
    return [
      {
        'name': 'Overworld items',
        'items': [
          1, # Repel
          2, # Super Repel
          3, # Max Repel
          4, # Black Flute
          5, # White Flute
          6, # Honey
          7, # Escape Rope
          8, # Red Shard
          9, # Purple Shard
          10, # Blue Shard
          11, # Green Shard
          49, # Heart Scale
          690, # Adrenaline Orb
        ]
      },
      {
        'name': 'Evolution items',
        'items': [
          202, # Everstone
          12, # Fire Stone
          13, # Thunder Stone
          14, # Water Stone
          15, # Leaf Stone
          16, # Moon Stone
          17, # Sun Stone
          18, # Dusk Stone
          19, # Dawn Stone
          20, # Shiny Stone
          692, # Ice Stone
          520, # Link Stone
          203, # Dragon Scale
          204, # Up-Grade
          205, # Dubious Disc
          206, # Protector
          207, # Electirizer
          208, # Magmarizer
          209, # Reaper Cloth
          210, # Prism Scale
          211, # Oval Stone
          580, # Whipped Dream
          572, # Sachet
          193, # DeepSeaTooth
          194, # DeepSeaScale
          109, # King's Rock
          110, # Razor Fang
          105, # Razor Claw
          808, # Tart Apple
          809, # Sweet Apple
          810, # Chipped Pot
          811, # Cracked Pot
        ]
      },
      {
        'name': 'Held items - utility',
        'items': [
          76, # Lucky Egg
          77, # Exp. Share
          78, # Amulet Coin
          873, # Magnetic Lure
          75, # Smoke Ball
          70, # Destiny Knot
          79, # Soothe Bell
          120, # Macho Brace
          121, # Power Weight
          122, # Power Bracer
          123, # Power Belt
          124, # Power Lens
          125, # Power Band
          126, # Power Anklet
        ]
      },
      {
        'name': 'Held items - battle',
        'items': [
          68, # Eviolite
          71, # Rocky Helmet
          93, # Leftovers
          94, # Shell Bell
          92, # Black Sludge
          100, # Life Orb
          115, # Flame Orb
          116, # Toxic Orb
          543, # Assault Vest
          573, # Safety Goggles
          693, # Protective Pads
          81, # Choice Band
          82, # Choice Specs
          83, # Choice Scarf
          84, # Heat Rock
          85, # Damp Rock
          86, # Smooth Rock
          87, # Icy Rock
          648, # Amplifield Rock
          112, # Quick Claw
          106, # Scope Lens
          107, # Wide Lens
          108, # Zoom Lens
          101, # Expert Belt
          102, # Metronome
          103, # Muscle Band
          104, # Wise Glasses
          88, # Light Clay
          74, # Shed Shell
          89, # Grip Claw
          90, # Binding Band
          91, # Big Root
          67, # Bright Powder
          69, # Float Stone
          80, # Cleanse Tag
          111, # Lagging Tail
          117, # Sticky Barb
          118, # Iron Ball
          119, # Ring Target
          113, # Focus Band
          849, # Heavy Duty Boots
          852, # Utility Umbrella
        ]
      },
      {
        'name': 'Held items - consumable',
        'items': [
          114, # Focus Sash
          579, # Weakness Policy
          850, # Blunder Policy
          66, # Air Balloon
          72, # Eject Button
          73, # Red Card
          95, # Mental Herb
          96, # White Herb
          97, # Power Herb
          98, # Absorb Bulb
          99, # Cell Battery
          560, # Luminous Moss
          576, # Snowball
          818, # Throat Spray
          819, # Eject Pack
          851, # Room Service
          774, # Elemental Seed
          775, # Magical Seed
          776, # Telluric Seed
          777, # Synthetic Seed

        ]
      },
      {
        'name': 'Incenses',
        'items': [
          127, # Lax Incense
          128, # Full Incense
          129, # Luck Incense
          130, # Pure Incense
          131, # Sea Incense
          132, # Wave Incense
          133, # Rose Incense
          134, # Odd Incense
          135, # Rock Incense
        ]
      },
      {
        'name': 'Type boosters',
        'items': [
          136, # Charcoal
          137, # Mystic Water
          138, # Magnet
          139, # Miracle Seed
          140, # Never-Melt Ice
          141, # Black Belt
          142, # Poison Barb
          143, # Soft Sand
          144, # Sharp Beak
          145, # Twisted Spoon
          146, # Silver Powder
          147, # Hard Stone
          148, # Spell Tag
          149, # Dragon Fang
          150, # Black Glasses
          151, # Metal Coat
          152, # Silk Scarf
        ]
      },
      {
        'name': 'Plates',
        'items': [
          153, # Flame Plate
          154, # Splash Plate
          155, # Zap Plate
          156, # Meadow Plate
          157, # Icicle Plate
          158, # Fist Plate
          159, # Toxic Plate
          160, # Earth Plate
          161, # Sky Plate
          162, # Mind Plate
          163, # Insect Plate
          164, # Stone Plate
          165, # Spooky Plate
          166, # Draco Plate
          167, # Dread Plate
          168, # Iron Plate
          570, # Pixie Plate
        ]
      },
      {
        'name': 'Memories',
        'items': [
          694, # Fire Memory
          695, # Water Memory
          696, # Electric Memory
          697, # Grass Memory
          698, # Ice Memory
          699, # Fighting Memory
          700, # Poison Memory
          701, # Ground Memory
          702, # Flying Memory
          703, # Psychic Memory
          704, # Bug Memory
          705, # Rock Memory
          706, # Ghost Memory
          707, # Dragon Memory
          708, # Dark Memory
          709, # Steel Memory
          710, # Fairy Memory
        ]
      },
      {
        'name': 'Gems',
        'items': [
          169, # Fire Gem
          170, # Water Gem
          171, # Electric Gem
          172, # Grass Gem
          173, # Ice Gem
          174, # Fighting Gem
          175, # Poison Gem
          176, # Ground Gem
          177, # Flying Gem
          178, # Psychic Gem
          179, # Bug Gem
          180, # Rock Gem
          181, # Ghost Gem
          182, # Dragon Gem
          183, # Dark Gem
          184, # Steel Gem
          185, # Normal Gem
          660, # Fairy Gem
        ]
      },
      {
        'name': 'Quest items',
        'items': [
          40, # Balm Mushroom
          50, # Slowpoketail
          59, # Growth Mulch
          60, # Damp Mulch
          61, # Stable Mulch
          62, # Gooey Mulch
          65, # Odd Keystone
          592, # Magnet Powder
          594, # Data Chip
          595, # Soul Candle
          597, # Floral Charm
          598, # Blast Powder
          604, # Oddishweed
          607, # Dark Material
          611, # Tech Glasses
          614, # Ill-Fated Doll
        ]
      },
      {
        'name': 'Applications',
        'items': [
          669, # Spyce Application
          670, # Library Application
          671, # Sweet Application
          672, # Critical Application
          673, # Medicine Application
          674, # Salon Application
          675, # Glamazonia App
          676, # Nightclub Application
          677, # Cycle Application
          678, # Silph Application
          679, # Circus Application
          680, # SOLICE Application
          681, # Construction App
          682, # Apophyll Application
        ]
      },
      {
        'name': 'Fossils',
        'items': [
          28, # Helix Fossil
          29, # Dome Fossil
          30, # Old Amber
          31, # Root Fossil
          32, # Claw Fossil
          33, # Skull Fossil
          34, # Armor Fossil
          35, # Cover Fossil
          36, # Plume Fossil
          556, # Jaw Fossil
          574, # Sail Fossil
          814, # Fossilized Bird
          815, # Fossilized Dino
          816, # Fossilized Drake
          817, # Fossilized Fish
        ]
      },
      {
        'name': 'Nectars',
        'items': [
          713, # Red Nectar
          714, # Yellow Nectar
          715, # Pink Nectar
          716, # Purple Nectar
        ]
      },
      {
        'name': 'Apricorns',
        'items': [
          21, # Red Apricorn
          22, # Ylw Apricorn
          23, # Blu Apricorn
          24, # Grn Apricorn
          25, # Pnk Apricorn
          26, # Wht Apricorn
          27, # Blk Apricorn
        ]
      },
      {
        'name': 'Sell/useless items',
        'items': [
          47, # Nugget
          48, # Big Nugget
          41, # Pearl
          42, # Big Pearl
          43, # Pearl String
          44, # Stardust
          45, # Star Piece
          46, # Comet Shard
          37, # Pretty Wing
          38, # Tiny Mushroom
          39, # Big Mushroom
          51, # Rare Bone
          52, # Relic Copper
          53, # Relic Silver
          54, # Relic Gold
          55, # Relic Vase
          56, # Relic Band
          57, # Relic Statue
          58, # Relic Crown
          63, # Shoal Salt
          64, # Shoal Shell
          212, # Red Scarf
          213, # Blue Scarf
          214, # Pink Scarf
          215, # Green Scarf
          216, # Yellow Scarf
          846, # Wishing Piece
        ]
      },
      {
        'name': 'Pokemon-specific',
        'items': [
          186, # Light Ball
          187, # Lucky Punch
          188, # Metal Powder
          189, # Quick Powder
          190, # Thick Club
          191, # Stick
        ]
      },
      {
        'name': 'Legendary Items',
        'items': [
          192, # Soul Dew
          195, # Adamant Orb
          196, # Lustrous Orb
          197, # Griseous Orb
          198, # Douse Drive
          199, # Shock Drive
          200, # Burn Drive
          201, # Chill Drive
          812, # Rusted Sword
          813, # Rusted Shield
        ]
      },
      {
        'name': 'Healing items',
        'items': [
          217, # Potion
          218, # Super Potion
          219, # Hyper Potion
          612, # Ultra Potion
          220, # Max Potion
          221, # Full Restore
          234, # Berry Juice
          237, # Fresh Water
          238, # Soda Pop
          239, # Lemonade
          711, # Blue Moon Lemonade
          240, # Moomoo Milk
          857, # Bubble Tea
          241, # Energy Powder
          242, # Energy Root
          533, # Vanilla Ice Cream
          523, # Choc Ice Cream
          524, # Berry Ice Cream
          605, # BlueMoon Ice Cream
          236, # Sweet Heart (quest item)
          593, # PokeSnax
        ]
      },
      {
        'name': 'Revival items',
        'items': [
          532, # Cotton Candy
          232, # Revive
          233, # Max Revive
          244, # Revival Herb
          222, # Sacred Ash
        ]
      },
      {
        'name': 'Status items',
        'items': [
          228, # Full Heal
          243, # Heal Powder
          235, # RageCandyBar
          229, # Lava Cookie
          230, # Old Gateau
          231, # Casteliacone
          561, # Lumiose Galette
          691, # Big Malasada
          223, # Awakening
          224, # Antidote
          225, # Burn Heal
          226, # Paralyze Heal
          227, # Ice Heal
          527, # Pop Rocks
          528, # Peppermint
          529, # Salt-Water Taffy
          530, # Chewing Gum
          531, # Red-Hots
        ]
      },
      {
        'name': 'PP items',
        'items': [
          245, # Ether
          246, # Max Ether
          247, # Elixir
          248, # Max Elixir
        ]
      },
      {
        'name': 'Level consumables',
        'items': [
          526, # Common Candy
          820, # Exp. Candy XS
          821, # Exp. Candy S
          822, # Exp. Candy M
          823, # Exp. Candy L
          824, # Exp. Candy XL
          263, # Rare Candy
          581, # Ability Capsule
        ]
      },
      {
        'name': 'EV consumables',
        'items': [
          249, # PP Up
          250, # PP Max
          861, # PP All
          251, # HP Up
          252, # Protein
          253, # Iron
          254, # Calcium
          255, # Zinc
          256, # Carbos
          257, # Health Wing
          258, # Muscle Wing
          259, # Resist Wing
          260, # Genius Wing
          261, # Clever Wing
          262, # Swift Wing
          865, # EV Booster
          863, # EV Tuner
          642, # HP Reset Disc
          643, # Attack Reset Disc
          644, # Defense Reset Disc
          645, # Sp.Atk Reset Disc
          646, # Sp.Def Reset Disc
          647, # Speed Reset Disc
          806, # Reset All Disc
          848, # Cell Imprint
          872, # Negative Imprint
        ]
      },
      { 'name': 'Mints',
        'items': [
          825, # Adamant Mint
          826, # Lonely Mint
          827, # Naughty Mint
          828, # Brave Mint
          829, # Bold Mint
          830, # Impish Mint
          831, # Lax Mint
          832, # Relaxed Mint
          833, # Modest Mint
          834, # Mild Mint
          835, # Rash Mint
          836, # Quiet Mint
          837, # Calm Mint
          838, # Gentle Mint
          839, # Careful Mint
          840, # Sassy Mint
          841, # Timid Mint
          842, # Hasty Mint
          843, # Jolly Mint
          844, # Naive Mint
          845, # Serious Mint


        ]
      },
      {
        'name': 'Poké Balls',
        'items': [
          #sorted roughly by catchrate
          610, # Corrupted Poké Ball 
          267, # Poké Ball 
          266, # Great Ball 
          265, # Ultra Ball 
          279, # Quick Ball
          283, # Lure Ball
          272, # Nest Ball 
          282, # Level Ball
          274, # Timer Ball
          277, # Dusk Ball
          270, # Net Ball
          271, # Dive Ball
          273, # Repeat Ball
          281, # Fast Ball
          284, # Heavy Ball
          287, # Moon Ball 
          867, # Dream Ball
          285, # Love Ball
          268, # Safari Ball 
          269, # Sport Ball 
          275, # Luxury Ball 
          286, # Friend Ball 
          278, # Heal Ball 
          276, # Premier Ball 
          280, # Cherish Ball 
          712, # Beast Ball 
          864, # Glitter Ball
          264, # Reborn Ball 255, at bottom to reduce accidental use
        ]
      },
      {
        'name': 'TMs & HMs',
        'items': [
          383, # TMX1 Cut
          384, # TMX2 Fly
          385, # TMX3 Surf
          386, # TMX4 Strength
          387, # TMX5 Waterfall
          388, # TMX6 Dive
          381, # TMX7 Rock Smash
          357, # TMX8 Flash
          793, # TMX9 Rock Climb
          288, # TM01 Work Up
          289, # TM02 Dragon Claw
          290, # TM03 Psyshock
          291, # TM04 Calm Mind
          292, # TM05 Roar
          293, # TM06 Toxic
          294, # TM07 Hail
          295, # TM08 Bulk Up
          296, # TM09 Venoshock
          297, # TM10 Hidden Power
          298, # TM11 Sunny Day
          299, # TM12 Taunt
          300, # TM13 Ice Beam
          301, # TM14 Blizzard
          302, # TM15 Hyper Beam
          303, # TM16 Light Screen
          304, # TM17 Protect
          305, # TM18 Rain Dance
          306, # TM19 Roost
          307, # TM20 Safeguard
          308, # TM21 Frustration
          309, # TM22 Solar Beam
          310, # TM23 Smack Down
          311, # TM24 Thunderbolt
          312, # TM25 Thunder
          313, # TM26 Earthquake
          314, # TM27 Return
          315, # TM28 Leech Life
          316, # TM29 Psychic
          317, # TM30 Shadow Ball
          318, # TM31 Brick Break
          319, # TM32 Double Team
          320, # TM33 Reflect
          321, # TM34 Sludge Wave
          322, # TM35 Flamethrower
          323, # TM36 Sludge Bomb
          324, # TM37 Sandstorm
          325, # TM38 Fire Blast
          326, # TM39 Rock Tomb
          327, # TM40 Aerial Ace
          328, # TM41 Torment
          329, # TM42 Facade
          330, # TM43 Flame Charge
          331, # TM44 Rest
          332, # TM45 Attract
          333, # TM46 Thief
          334, # TM47 Low Sweep
          335, # TM48 Round
          336, # TM49 Echoed Voice
          337, # TM50 Overheat
          338, # TM51 Steel Wing
          339, # TM52 Focus Blast
          340, # TM53 Energy Ball
          341, # TM54 False Swipe
          342, # TM55 Scald
          343, # TM56 Fling
          344, # TM57 Charge Beam
          345, # TM58 Sky Drop
          346, # TM59 Brutal Swing
          347, # TM60 Quash
          348, # TM61 Will-O-Wisp
          349, # TM62 Acrobatics
          350, # TM63 Embargo
          351, # TM64 Explosion
          352, # TM65 Shadow Claw
          353, # TM66 Payback
          354, # TM67 Smart Strike
          355, # TM68 Giga Impact
          356, # TM69 Rock Polish
          717, # TM70 Aurora Veil
          358, # TM71 Stone Edge
          359, # TM72 Volt Switch
          360, # TM73 Thunder Wave
          361, # TM74 Gyro Ball
          362, # TM75 Swords Dance
          363, # TM76 Struggle Bug
          364, # TM77 Psych Up
          365, # TM78 Bulldoze
          366, # TM79 Frost Breath
          367, # TM80 Rock Slide
          368, # TM81 X-Scissor
          369, # TM82 Dragon Tail
          370, # TM83 Infestation
          371, # TM84 Poison Jab
          372, # TM85 Dream Eater
          373, # TM86 Grass Knot
          374, # TM87 Swagger
          375, # TM88 Sleep Talk
          376, # TM89 U-turn
          377, # TM90 Substitute
          378, # TM91 Flash Cannon
          379, # TM92 Trick Room
          380, # TM93 Wild Charge
          639, # TM94 Secret Power
          382, # TM95 Snarl
          582, # TM96 Nature Power
          583, # TM97 Dark Pulse
          584, # TM98 Power-Up Punch
          585, # TM99 Dazzling Gleam
          586, # TM100 Confide
        ]
      },
      {
        'name': 'Berries',
        'items': [
          389, # Cheri Berry
          390, # Chesto Berry
          391, # Pecha Berry
          392, # Rawst Berry
          393, # Aspear Berry
          394, # Leppa Berry
          395, # Oran Berry
          396, # Persim Berry
          397, # Lum Berry
          398, # Sitrus Berry
          399, # Figy Berry
          400, # Wiki Berry
          401, # Mago Berry
          402, # Aguav Berry
          403, # Iapapa Berry
          404, # Razz Berry
          405, # Bluk Berry
          406, # Nanab Berry
          407, # Wepear Berry
          408, # Pinap Berry
          409, # Pomeg Berry
          410, # Kelpsy Berry
          411, # Qualot Berry
          412, # Hondew Berry
          413, # Grepa Berry
          414, # Tamato Berry
          415, # Cornn Berry
          416, # Magost Berry
          417, # Rabuta Berry
          418, # Nomel Berry
          419, # Spelon Berry
          420, # Pamtre Berry
          421, # Watmel Berry
          422, # Durin Berry
          423, # Belue Berry
          424, # Occa Berry
          425, # Passho Berry
          426, # Wacan Berry
          427, # Rindo Berry
          428, # Yache Berry
          429, # Chople Berry
          430, # Kebia Berry
          431, # Shuca Berry
          432, # Coba Berry
          433, # Payapa Berry
          434, # Tanga Berry
          435, # Charti Berry
          436, # Kasib Berry
          437, # Haban Berry
          438, # Colbur Berry
          439, # Babiri Berry
          440, # Chilan Berry
          441, # Liechi Berry
          442, # Ganlon Berry
          443, # Salac Berry
          444, # Petaya Berry
          445, # Apicot Berry
          446, # Lansat Berry
          447, # Starf Berry
          448, # Enigma Berry
          449, # Micle Berry
          450, # Custap Berry
          451, # Jaboca Berry
          452, # Rowap Berry
          558, # Kee Berry
          563, # Maranga Berry
          571, # Roseli Berry
        ]
      },
      {
        'name': 'Z crystals - type',
        'items': [
          742, 743, # Normalium-Z
          730, 731, # Firium-Z
          752, 753, # Waterium-Z
          736, 737, # Grassium-Z
          724, 725, # Electrium-Z
          718, 719, # Buginium-Z
          732, 733, # Flyinium-Z
          738, 739, # Groundium-Z
          748, 749, # Rockium-Z
          728, 729, # Fightinium-Z
          746, 747, # Psychium-Z
          734, 735, # Ghostium-Z
          720, 721, # Darkinium-Z
          726, 727, # Fairium-Z
          744, 745, # Poisonium-Z
          750, 751, # Steelium-Z
          722, 723, # Dragonium-Z
          740, 741, # Icium-Z
        ]
      },
      {
        'name': 'Z crytals - pokemon',
        'items': [
          762, 763, # Eevium-Z
          764, 765, # Pikanium-Z
          754, 755, # Aloraichium-Z
          766, 767, # Snorlium-Z
          756, 757, # Decidium-Z
          758, 759, # Incinium-Z
          760, 761, # Primarium-Z
          781, 782, # Kommonium-Z
          783, 784, # Lycanium-Z
          785, 786, # Mimikium-Z
          768, 769, # Mewnium-Z
          770, 771, # Tapunium-Z
          772, 773, # Marshadium-Z
          787, 788, # Solganium-Z
          789, 790, # Lunalium-Z
          791, 792, # Ultranecrozium-Z
        ]
      },
      {
        'name': 'Mega stones',
        'items': [
          537, # Abomasite
          538, # Absolite
          539, # Aerodactylite
          540, # Aggronite
          541, # Alakazite
          623, # Altarianite
          542, # Ampharosite
          622, # Audinite
          544, # Banettite
          621, # Beedrillite
          545, # Blastoisinite
          546, # Blazikenite
          626, # Cameruptite
          547, # Charizardite X
          548, # Charizardite Y
          624, # Diancite
          617, # Galladite
          549, # Garchompite
          550, # Gardevoirite
          551, # Gengarite
          618, # Glalitite
          552, # Gyaradosite
          553, # Heracronite
          554, # Houndoominite
          557, # Kangaskhanite
          634, # Latiasite
          635, # Latiosite
          629, # Lopunnite
          559, # Lucarionite
          562, # Manectite
          564, # Mawilite
          565, # Medichamite
          630, # Metagrossite
          567, # Mewtwonite X
          568, # Mewtwonite Y
          627, # Pidgeotite
          569, # Pinsirite
          632, # Sablenite
          628, # Salamencite
          620, # Sceptilite
          575, # Scizorite
          619, # Sharpedonite
          631, # Slowbronite
          625, # Steelixite
          633, # Swampertite
          577, # Tyranitarite
          578, # Venusaurite
        ]
      },
      {
        'name': 'Mails',
        'items': [
          636, # Red Orb
          637, # Blue Orb
          853, # Blue Orb 2 (Unused?)
          453, # Grass Mail
          454, # Flame Mail
          455, # Bubble Mail
          456, # Bloom Mail
          457, # Tunnel Mail
          458, # Steel Mail
          459, # Heart Mail
          460, # Snow Mail
          461, # Space Mail
          462, # Air Mail
          463, # Mosaic Mail
          464, # Brick Mail
        ]
      },
      {
        'name': 'Battle Items',
        'items': [
          500, # Poké Doll
          501, # Fluffy Tail
          502, # Poké Toy
          497, # Blue Flute
          498, # Yellow Flute
          499, # Red Flute
          465, # X Attack
          466, # X Attack 2
          467, # X Attack 3
          468, # X Attack 6
          469, # X Defend
          470, # X Defend 2
          471, # X Defend 3
          472, # X Defend 6
          473, # X Special
          474, # X Special 2
          475, # X Special 3
          476, # X Special 6
          477, # X Sp. Def
          478, # X Sp. Def 2
          479, # X Sp. Def 3
          480, # X Sp. Def 6
          481, # X Speed
          482, # X Speed 2
          483, # X Speed 3
          484, # X Speed 6
          485, # X Accuracy
          486, # X Accuracy 2
          487, # X Accuracy 3
          488, # X Accuracy 6
          489, # Dire Hit
          490, # Dire Hit 2
          491, # Dire Hit 3
          492, # Guard Spec.
          493, # Reset Urge
          494, # Ability Urge
          495, # Item Urge
          496, # Item Drop
        ]
      },
      {
        'name': 'General use',
        'items': [
          606, # PULSE
          566, # Mega-Z Ring
          516, # Bike Voucher #to remind people, and be directly replaced with the bike when swapped
          503, # Bicycle
          507, # Itemfinder
          508, # Dowsing MCHN
          509, # Poké Radar
          510, # Town Map
          517, # Mining Kit
          518, # Wailmer Pail
          504, # Old Rod
          505, # Good Rod
          506, # Super Rod
          799, # EXP All
          866, # Remote PC
        ]
      },
      {
        'name': 'Misc important',
        'items': [
          514, # Membership Card
          512, # Coin Case
          804, # Spirit Tracker
          807, # Gather Cube
          589, # Oval Charm
          590, # Shiny Charm
          847, # Catching Charm: Ruby
          869, # Catching Charm: Sapphire
          870, # Catching Charm: Emerald
          871, # Catching Charm: Amethyst
        ]
      },
      {
        'name': 'Niche items',
        'items': [
          511, # Poké Flute
          513, # Soot Sack
          608, # Powder Vial
          687, # Devon Scope Model
          688, # Silvon Scope
          689, # Radio Transceiver
        ]
      },
      {
        'name': 'Story based items',
        'items': [
          525, # Medicine
          535, # Ruby Ring
          778, # Sapphire Bracelets
          805, # Emerald Brooch
          534, # Amethyst Pendant
          609, # Battle Pass- Fury
          616, # Battle Pass- Gravity
          641, # Battle Pass- Suspension
          800, # Ruby Star
          801, # Sapphire Star
          802, # Emerald Star
          803, # Amethyst Star
          856, # Gift Box
          868, # Ebony Stonepiece
        ]
      },
      {
        'name': 'Sidequest items',
        'items': [
          555, # Intriguing Stone
          596, # Silver Ring
          613, # Silver Card
          599, # 'Rare Candy'
          661, # Diamond Ring
          683, # Classified Information
          684, # Pink Pearl
          685, # Crystal Ball
          665, # ID Tag
          666, # DJ Arc Autograph
          667, # McKrezzy Autograph
          668, # Headphones
          795, # Meteor Card
          796, # Belrose Picture
          798, # Ribbon Collar
        ]
      },
      {
        'name': 'Keys',
        'items': [
          515, # Warehouse Key
          521, # Harbor Key
          522, # Railnet Key
          536, # Yureyu Key
          591, # Dull Key
          600, # Crystal Key
          601, # Crystal Key
          602, # Crystal Key
          603, # Crystal Key
          615, # House Key
          640, # Beryl Grid Key
          686, # 'R' Key
          662, # Sanctum Key
          663, # GUM Key
          664, # Coral Key
          794, # Cage Key
          797, # Orphanage Key
          862, # Archive Key
          858, # Gold Key
          859, # Ivory Key
          860, # Ebony Key
          649, # K2 Key
          650, # K5 Key
          651, # K22 Key
          652, # K33 Key
          653, # S4 Key
          654, # S9 Key
          655, # S12 Key
          656, # F1 Key
          657, # F10 Key
          658, # F14 Key
          659, # F34 Key
        ]
      },
      {
        'name': 'Legendary things',
        'items': [
          854, # Blue Orb 3 (Unused?)
          855, # Manaphy Gem
          519, # Gracidea
          587, # DNA Splicers
          588, # Reveal Glass
          638, # Prison Bottle
          779, # N-Solarizer
          780, # N-Lunarizer
          
        ]
      }
    ]  
  end
end



class PokemonBag
  attr_reader :registeredItem
  attr_accessor :lastpocket
  attr_reader :pockets
  attr_accessor :registeredItems
  attr_accessor :itemtracker

  TRACKTM = 0
  TRACKMEGA = 1
  TRACKCRYSTAL = 2
  TRACKMEM = 3

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
    @registeredItems = []
    @registeredIndex = [0,0,1]
    initTrackerData
  end

  def pockets
    rearrange()
    return @pockets
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
      if move.nil?
        trutharray.push(3) #no symbol
      elsif learned
        trutharray.push(2) #learned
      elsif i.isEgg? || (i.isShadow? rescue false) || !pbSpeciesCompatible?(i.species,move,i)
        trutharray.push(0) #unable
      else 
        trutharray.push(1) #able
      end
    end
    return trutharray
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

  def registeredItems
    @registeredItems = [] if !@registeredItems
    if @registeredItem.is_a?(Array)
      @registeredItems = @registeredItem
      @registeredItem = 0
    end
    if @registeredItem && @registeredItem>0 && !@registeredItems.include?(@registeredItem)
      @registeredItems.push(@registeredItem)
      @registeredItem = nil
    end
    return @registeredItems
  end

  def pbIsRegistered?(item)
    registeredlist = self.registeredItems
    return registeredlist.include?(item)
  end

  # Registers the item as a key item.  Can be retrieved with $PokemonBag.registeredItem
  def pbRegisterKeyItem(item)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("The item number is invalid.",item))
      return
    end
    if item!=@registeredItem
      @registeredItem=item
    else
      @registeredItem=0
    end
  end

  # Registers the item in the Ready Menu.
  def pbRegisterItem(item)
    if item.is_a?(String) || item.is_a?(Symbol)
      item = getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("Item number {1} is invalid.",item))
      return
    end
    registeredlist = self.registeredItems
    registeredlist.push(item) if !registeredlist.include?(item)
  end

  # Unregisters the item from the Ready Menu.
  def pbUnregisterItem(item)
    if item.is_a?(String) || item.is_a?(Symbol)
      item = getID(PBItems,item)
    end
    if !item || item<1
      raise ArgumentError.new(_INTL("Item number {1} is invalid.",item))
      return
    end
    self.registeredItems.delete(item)
  end

  def registeredIndex
    @registeredIndex = [0,0,1] if !@registeredIndex
    return @registeredIndex
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

  def pbHasItem?(item)
    return pbQuantity(item)>0
  end
    
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
    if ret && @registeredItems != nil 
      @registeredItems.delete(item) if pbQuantity(item)<=0
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
    trackItem(item)
    if pbIsZCrystal?(item)
      return true
    end 
    pocket=pbGetPocket(item)
    maxsize=maxPocketSize(pocket)
    maxsize=@pockets[pocket].length+1 if maxsize<0
    return ItemStorageHelper.pbStoreItem(
       @pockets[pocket],maxsize,BAGMAXPERSLOT,item,qty,true)
  end

  #hot new itemtracker functionality!
  def initTrackerData
    @itemtracker = []
    hashTM = {} #tms
    hashMEGA = {} #stones
    hashCRYSTAL = {} #crystals
    hashMEM = {} #memories
    #scan the item data so we don't have to write this all out manually!
    for item in 0...$cache.items.length
      next if !$cache.items[item]
      hashTM[item] = false if pbIsMachine?(item)
      if pbGetPocket(item) == 6 #stones and crystals
        if pbIsZCrystal?(item) || pbIsZCrystal?(item)
          hashCRYSTAL[item] = false 
        else
          hashMEGA[item] = false
        end
      end
      hashMEM[item] = false if ([694..710]).include?(item)
    end
    @itemtracker[TRACKTM] = hashTM
    @itemtracker[TRACKMEGA] = hashMEGA
    @itemtracker[TRACKCRYSTAL] = hashCRYSTAL
    @itemtracker[TRACKMEM] = hashMEM
  end

  def itemscan
    #scan the bag first
    initTrackerData
    for key in @itemtracker[TRACKTM].keys
      @itemtracker[TRACKTM][key] = true if pbHasItem?(key)
    end
    for key in @itemtracker[TRACKMEGA].keys
      @itemtracker[TRACKMEGA][key] = true if pbHasItem?(key)
    end
    for key in @itemtracker[TRACKMEGA].keys
      @itemtracker[TRACKMEGA][key] = true if pbHasItem?(key)
    end
    for key in @itemtracker[TRACKMEM].keys
      @itemtracker[TRACKMEM][key] = true if pbHasItem?(key)
    end
    #scan the pc???? who uses this
    if $PokemonGlobal.pcItemStorage
      for item in $PokemonGlobal.pcItemStorage.items
        next if pbQuantity(item[0]) == 0
        trackItem(item[0])
      end
    end
    #now scan mons. all of them. everywhere.
    for mon in $Trainer.party
      trackItem(mon.item) if mon.item
    end
    for box in 0...$PokemonStorage.maxBoxes
      for index in 0...$PokemonStorage[box].length
        mon = $PokemonStorage[box, index]
        next if !mon || mon.item == 0
        trackItem(mon.item)
      end
    end
  end

  def trackItem(item)
    @itemtracker[TRACKTM][item] = true if pbIsMachine?(item)
    if pbGetPocket(item) == 6 #stones and crystals
      @itemtracker[TRACKMEGA][item] = true if pbIsZCrystal?(item)
      @itemtracker[TRACKCRYSTAL][item] = true if !pbIsZCrystal?(item)
    end
    @itemtracker[TRACKMEM][item] = true if ([694..710]).include?(item)
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
  def pbGiveItemScreen(from_bag)
    @scene.pbStartScene(@bag)
    item=0
    loop do
      item=@scene.pbChooseItem
      break if item==0
      itemname=PBItems.getName(item)
      # Key items and hidden machines can't be held
      if pbIsImportantItem?(item) && (!pbIsZCrystal2?(item) || !from_bag)
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
      if pbIsImportantItem?(item)
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
      elsif command==1 # Give
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
      commands=[]
      # Generate command list
      commands[cmdRead=commands.length]=_INTL("Read") if pbIsMail?(item)
      commands[cmdUse=commands.length]=_INTL("Use") if ItemHandlers.hasOutHandler(item) || (pbIsMachine?(item) && $Trainer.party.length>0)
      commands[cmdGive=commands.length]=_INTL("Give") if $Trainer.party.length>0 && !pbIsImportantItem?(item)
      commands[cmdToss=commands.length]=_INTL("Toss") if !pbIsImportantItem?(item) || $DEBUG
      if @bag.registeredItems.include?(item)
        commands[cmdRegister=commands.length]=_INTL("Deselect")
      elsif ItemHandlers.hasKeyItemHandler(item) && pbIsKeyItem?(item)
        commands[cmdRegister=commands.length]=_INTL("Register")
      end
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
        if @bag.pbIsRegistered?(item)
          @bag.pbUnregisterItem(item)
        else
          @bag.pbRegisterItem(item)
        end
        @scene.pbRefresh
      elsif cmdGive>=0 && command==cmdGive # Give item to Pokémon
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
    @sprites["background"].setBitmap("Graphics/Pictures/Bag/pcItembg")
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
  MAXSIZE=500
  MAXPERSLOT=999

  def initialize
    @items=[]
    # Start storage with a Potion
    if hasConst?(PBItems,:POTION)
      ItemStorageHelper.pbStoreItem(
         @items,MAXSIZE,MAXPERSLOT,PBItems::POTION,1)
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
    using_block(numwindow=Window_UnformattedTextPokemon.new("x000")){
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
    }
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