# Abstraction layer for Pokemon Essentials
class PokemonMartAdapter
  def getMoney
    return $Trainer.money
  end

  def setMoney(value)
    $Trainer.money=value
  end

  def getInventory()
    return $PokemonBag
  end

  def getPrice(item,selling=false)
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      if selling
        return $game_temp.mart_prices[item][1] if $game_temp.mart_prices[item][1]>=0
      else
        return $game_temp.mart_prices[item][0] if $game_temp.mart_prices[item][0]>0
      end
    end
    return $cache.items[item][ITEMPRICE]
  end

  def getItemIcon(item)
    return nil if !item
    return pbItemIconFile(item)
  end

  def getItemIconRect(item)
    return Rect.new(0,0,48,48)
  end

  def getDisplayName(item)
    itemname=PBItems.getName(item)
    if pbIsMachine?(item)
      machine=$cache.items[item][ITEMMACHINE]
      itemname=_INTL("{1} {2}",itemname,PBMoves.getName(machine))
    end
    return itemname
  end

  def getName(item)
    return PBItems.getName(item)
  end

  def getDisplayPrice(item,selling=false)
    price=getPrice(item,selling)
    return _ISPRINTF("$ {1:d}",price)
  end

  def getDescription(item)
    return pbGetMessage(MessageTypes::ItemDescriptions,item)
  end

  def addItem(item)
    return $PokemonBag.pbStoreItem(item)
  end

  def getQuantity(item)
    return $PokemonBag.pbQuantity(item)
  end

  def canSell?(item)
    return getPrice(item,true)>0 && !pbIsImportantItem?(item)
  end

  def showQuantity?(item)
    return !pbIsImportantItem?(item)
  end

  def removeItem(item)
    return $PokemonBag.pbDeleteItem(item)
  end
end

###################

class Window_PokemonMart < Window_DrawableCommand
  def initialize(stock,adapter,x,y,width,height,viewport=nil)
    @stock=stock
    @adapter=adapter
    super(x,y,width,height,viewport)
    @selarrow=AnimatedBitmap.new("Graphics/Pictures/martSel")
    @baseColor=Color.new(88,88,80)
    @shadowColor=Color.new(168,184,184)
    self.windowskin=nil
  end

  def itemCount
    return @stock.length+1
  end

  def item
    return self.index>=@stock.length ? 0 : @stock[self.index]
  end

  def drawItem(index,count,rect)
    textpos=[]
    rect=drawCursor(index,rect)
    ypos=rect.y
    if index==count-1
      textpos.push([_INTL("CANCEL"),rect.x,ypos+2,false,
         self.baseColor,self.shadowColor])
    else
      item=@stock[index]
      itemname=@adapter.getDisplayName(item)
      qty=@adapter.getDisplayPrice(item)
      sizeQty=self.contents.text_size(qty).width
      xQty=rect.x+rect.width-sizeQty-2-16
      textpos.push([itemname,rect.x,ypos+2,false,self.baseColor,self.shadowColor])
      textpos.push([qty,xQty,ypos+2,false,self.baseColor,self.shadowColor])
    end
    pbDrawTextPositions(self.contents,textpos)
  end
end

class BuyAdapter # :nodoc:
  def initialize(adapter)
    @adapter=adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
  end

  def getDisplayPrice(item)
    @adapter.getDisplayPrice(item,false)
  end

  def isSelling?
    return false
  end
end

class SellAdapter # :nodoc:
  def initialize(adapter)
    @adapter=adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
  end

  def getDisplayPrice(item)
    if @adapter.showQuantity?(item)
      return sprintf("x%d",@adapter.getQuantity(item))
    else
      return ""
    end
  end

  def isSelling?
    return true
  end
end

class PokemonMartScene
  def update
    pbUpdateSpriteHash(@sprites)
    @subscene.update if @subscene
  end

  def pbChooseNumber(helptext,item,maximum)
    curnumber=1
    ret=0
    helpwindow=@sprites["helpwindow"]
    itemprice=@adapter.getPrice(item,!@buying)
    itemprice/=2 if !@buying
    pbDisplay(helptext,true)
    using_block(numwindow=Window_AdvancedTextPokemon.new("")){ # Showing number of items
       qty=@adapter.getQuantity(item)
       using_block(inbagwindow=Window_AdvancedTextPokemon.new("")){ # Showing quantity in bag
          pbPrepareWindow(numwindow)
          pbPrepareWindow(inbagwindow)
          numwindow.viewport=@viewport
          numwindow.width=224
          numwindow.height=64
          numwindow.baseColor=Color.new(88,88,80)
          numwindow.shadowColor=Color.new(168,184,184)
          inbagwindow.visible=@buying
          inbagwindow.viewport=@viewport
          inbagwindow.width=190
          inbagwindow.height=64
          inbagwindow.baseColor=Color.new(88,88,80)
          inbagwindow.shadowColor=Color.new(168,184,184)
          inbagwindow.text=_ISPRINTF("In Bag:<r>{1:d}  ",qty)
          numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
          pbBottomRight(numwindow)
          numwindow.y-=helpwindow.height
          pbBottomLeft(inbagwindow)
          inbagwindow.y-=helpwindow.height
          loop do
            Graphics.update
            Input.update
            numwindow.update
            inbagwindow.update
            self.update
            if Input.repeat?(Input::LEFT)
              pbPlayCursorSE()
              curnumber-=10
              curnumber=1 if curnumber<1
              numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
            elsif Input.repeat?(Input::RIGHT)
              pbPlayCursorSE()
              curnumber+=10
              curnumber=maximum if curnumber>maximum
              numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
            elsif Input.repeat?(Input::UP)
              pbPlayCursorSE()
              curnumber+=1
              curnumber=1 if curnumber>maximum
              numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
            elsif Input.repeat?(Input::DOWN)
              pbPlayCursorSE()
              curnumber-=1
              curnumber=maximum if curnumber<1
              numwindow.text=_INTL("x{1}<r>$ {2}",curnumber,pbCommaNumber(curnumber*itemprice))
            elsif Input.trigger?(Input::C)
              pbPlayDecisionSE()
              ret=curnumber
              break
            elsif Input.trigger?(Input::B)
              pbPlayCancelSE()
              ret=0
              break
            end     
          end
       }
    }
    helpwindow.visible=false
    return ret
  end

  def pbPrepareWindow(window)
    window.visible=true
    window.letterbyletter=false
  end

  def pbStartBuyOrSellScene(buying,stock,adapter)
    # Scroll right before showing screen
    pbScrollMap(6,5,5)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @stock=stock
    @adapter=adapter
    @sprites={}
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/martScreen")
    @sprites["icon"]=IconSprite.new(12,Graphics.height-74,@viewport)
    winAdapter=buying ? BuyAdapter.new(adapter) : SellAdapter.new(adapter)
    @sprites["itemwindow"]=Window_PokemonMart.new(stock,winAdapter,
       Graphics.width-316-16,12,330+16,Graphics.height-126)
    @sprites["itemwindow"].viewport=@viewport
    @sprites["itemwindow"].index=0
    @sprites["itemwindow"].refresh
    @sprites["itemtextwindow"]=Window_UnformattedTextPokemon.new("")
    pbPrepareWindow(@sprites["itemtextwindow"])
    @sprites["itemtextwindow"].x=64
    @sprites["itemtextwindow"].y=Graphics.height-96-16
    @sprites["itemtextwindow"].width=Graphics.width-64
    @sprites["itemtextwindow"].height=128
    @sprites["itemtextwindow"].baseColor=Color.new(248,248,248)
    @sprites["itemtextwindow"].shadowColor=Color.new(0,0,0)
    @sprites["itemtextwindow"].visible=true
    @sprites["itemtextwindow"].viewport=@viewport
    @sprites["itemtextwindow"].windowskin=nil
    @sprites["helpwindow"]=Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].viewport=@viewport
    pbBottomLeftLines(@sprites["helpwindow"],1)
    @sprites["moneywindow"]=Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible=true
    @sprites["moneywindow"].viewport=@viewport
    @sprites["moneywindow"].x=0
    @sprites["moneywindow"].y=0
    @sprites["moneywindow"].width=190
    @sprites["moneywindow"].height=96
    @sprites["moneywindow"].baseColor=Color.new(88,88,80)
    @sprites["moneywindow"].shadowColor=Color.new(168,184,184)
    pbDeactivateWindows(@sprites)
    @buying=buying
    pbRefresh
    Graphics.frame_reset
  end

  def pbStartBuyScene(stock,adapter)
    pbStartBuyOrSellScene(true,stock,adapter)
  end
  
  def pbStartSellScene(bag,adapter)
    if $PokemonBag
      pbStartSellScene2(bag,adapter)
    else
      pbStartBuyOrSellScene(false,bag,adapter)
    end
  end

  def pbStartSellScene2(bag,adapter)
    @subscene=PokemonBag_Scene.new
    @adapter=adapter
    @viewport2=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport2.z=99999
    for j in 0..17
      col=Color.new(0,0,0,j*15)
      @viewport2.color=col
      Graphics.update
      Input.update
    end
    @subscene.pbStartScene(bag)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    @sprites["helpwindow"]=Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].viewport=@viewport
    pbBottomLeftLines(@sprites["helpwindow"],1)
    @sprites["moneywindow"]=Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible=false
    @sprites["moneywindow"].viewport=@viewport
    @sprites["moneywindow"].x=0
    @sprites["moneywindow"].y=0
    @sprites["moneywindow"].width=186
    @sprites["moneywindow"].height=96
    @sprites["moneywindow"].baseColor=Color.new(88,88,80)
    @sprites["moneywindow"].shadowColor=Color.new(168,184,184)
    pbDeactivateWindows(@sprites)
    @buying=false
    pbRefresh
  end

  def pbShowMoney
    pbRefresh
    @sprites["moneywindow"].visible=true
  end

  def pbHideMoney
    pbRefresh
    @sprites["moneywindow"].visible=false
  end

  def pbEndBuyScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    # Scroll left after showing screen
    pbScrollMap(4,5,5)
  end

  def pbEndSellScene
    if @subscene
      @subscene.pbEndScene
    end
    pbDisposeSpriteHash(@sprites)
    if @viewport2
      for j in 0..17
        col=Color.new(0,0,0,(17-j)*15)
        @viewport2.color=col
        Graphics.update
        Input.update
      end
      @viewport2.dispose
    end
    @viewport.dispose
    if !@subscene
      pbScrollMap(4,5,5)
    end
  end

  def pbDisplay(msg,brief=false)
    cw=@sprites["helpwindow"]
    cw.letterbyletter=true
    cw.text=msg
    pbBottomLeftLines(cw,2)
    cw.visible=true
    i=0
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      self.update
      if brief && !cw.busy?
        return
      end
      if i==0 && !cw.busy?
        pbRefresh
      end
      if Input.trigger?(Input::C) && cw.busy?
        cw.resume
      end
      if i==60
        return
      end
      i+=1 if !cw.busy?
    end
  end

  def pbDisplayPaused(msg)
    cw=@sprites["helpwindow"]
    cw.letterbyletter=true
    cw.text=msg
    pbBottomLeftLines(cw,2)
    cw.visible=true
    i=0
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      wasbusy=cw.busy?
      self.update
      if !cw.busy? && wasbusy
        pbRefresh
      end
      if Input.trigger?(Input::C) && cw.resume && !cw.busy?
        @sprites["helpwindow"].visible=false
        return
      end
    end
  end

  def pbConfirm(msg)
    dw=@sprites["helpwindow"]
    dw.letterbyletter=true
    dw.text=msg
    dw.visible=true
    pbBottomLeftLines(dw,2)
    commands=[_INTL("Yes"),_INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport=@viewport
    pbBottomRight(cw)
    cw.y-=dw.height
    cw.index=0
    pbPlayDecisionSE()
    loop do
      cw.visible=!dw.busy?
      Graphics.update
      Input.update
      cw.update
      self.update
      if Input.trigger?(Input::B) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible=false
        return false
      end
      if Input.trigger?(Input::C) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible=false
        return (cw.index==0)?true:false
      end
    end
  end

  def pbRefresh
    if !@subscene
      itemwindow=@sprites["itemwindow"]
      filename=@adapter.getItemIcon(itemwindow.item)
      @sprites["icon"].setBitmap(filename)
      @sprites["icon"].src_rect=@adapter.getItemIconRect(itemwindow.item)   
      @sprites["itemtextwindow"].text=(itemwindow.item==0) ? _INTL("Quit shopping.") :
         @adapter.getDescription(itemwindow.item)
      itemwindow.refresh
    end
    @sprites["moneywindow"].text=_INTL("Money:\n<r>${1}",@adapter.getMoney())
  end

  def pbChooseBuyItem
    itemwindow=@sprites["itemwindow"]
    @sprites["helpwindow"].visible=false
    pbActivateWindow(@sprites,"itemwindow"){
       pbRefresh
       loop do
         Graphics.update
         Input.update
         olditem=itemwindow.item
         self.update
         if itemwindow.item!=olditem
           filename=@adapter.getItemIcon(itemwindow.item)
           @sprites["icon"].setBitmap(filename)
           @sprites["icon"].src_rect=@adapter.getItemIconRect(itemwindow.item)   
           @sprites["itemtextwindow"].text=(itemwindow.item==0) ? _INTL("Quit shopping.") :
              @adapter.getDescription(itemwindow.item)
         end
         if Input.trigger?(Input::B)
           return 0
         end
         if Input.trigger?(Input::C)
           if itemwindow.index<@stock.length
             pbRefresh
             return @stock[itemwindow.index]
           else
             return 0
           end
         end
       end
    }
  end

  def pbChooseSellItem
    if @subscene
      return @subscene.pbChooseItem
    else
      return pbChooseBuyItem
    end
  end
end

#######################################################
class PokemonMartScreen
  def initialize(scene,stock)
    @scene=scene
    @stock=stock
    @adapter= PokemonMartAdapter.new
  end

  def pbConfirm(msg)
    return @scene.pbConfirm(msg)
  end

  def pbDisplay(msg)
    return @scene.pbDisplay(msg)
  end

  def pbDisplayPaused(msg)
    return @scene.pbDisplayPaused(msg)
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock,@adapter)
    item=0
    loop do
      item=@scene.pbChooseBuyItem
      quantity=0
      break if item==0
      itemname=@adapter.getDisplayName(item)
      price=@adapter.getPrice(item)
      if @adapter.getMoney()<price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      if pbIsImportantItem?(item)
        if !pbConfirm(_INTL("Certainly. You want {1}.\r\nThat will be ${2}. OK?",itemname,pbCommaNumber(price)))
          next
        end
        quantity=1
      else
        maxafford=(price<=0) ? BAGMAXPERSLOT : @adapter.getMoney()/price
        maxafford=BAGMAXPERSLOT if maxafford>BAGMAXPERSLOT
        quantity=@scene.pbChooseNumber(
           _INTL("{1}?  Certainly.\r\nHow many would you like?",itemname),item,maxafford)
        if quantity==0
          next
        end
        price*=quantity
        if !pbConfirm(_INTL("{1}, and you want {2}.\r\nThat will be ${3}. OK?",itemname,quantity,pbCommaNumber(price)))
          next
        end
      end
      if @adapter.getMoney()<price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      added=0
      quantity.times do
        if !@adapter.addItem(item)
          break
        end
        added+=1
      end
      if added!=quantity
        added.times do
          if !@adapter.removeItem(item)
            raise _INTL("Failed to delete stored items")
          end
        end
        pbDisplayPaused(_INTL("You have no more room in the Bag."))  
      else
        @adapter.setMoney(@adapter.getMoney()-price)
        for i in 0...@stock.length
          if pbIsImportantItem?(@stock[i]) && $PokemonBag.pbQuantity(@stock[i])>0
            @stock[i]=nil
          end
        end
        @stock.compact!
        pbDisplayPaused(_INTL("Here you are!\r\nThank you!"))
        if $PokemonBag && quantity>=10 && pbIsPokeBall?(item)
          if quantity < 20 && @adapter.addItem(PBItems::PREMIERBALL) 
            pbDisplayPaused(_INTL("I'll throw in a Premier Ball, too.")) 
          elsif quantity >=20 && $PokemonBag.pbStoreItem(PBItems::PREMIERBALL,(quantity/10).floor)
            pbDisplayPaused(_INTL("I'll throw in a few Premier Balls, too."))
          end
        end
      end
    end
    @scene.pbEndBuyScene
  end

  def pbSellScreen
    item=@scene.pbStartSellScene(@adapter.getInventory,@adapter)
    loop do
      item=@scene.pbChooseSellItem
      break if item==0
      itemname=@adapter.getDisplayName(item)
      price=@adapter.getPrice(item,true)
      if !@adapter.canSell?(item)
        pbDisplayPaused(_INTL("{1}?  Oh, no.\r\nI can't buy that.",itemname))
        next
      end
      qty=@adapter.getQuantity(item)
      next if qty==0
      @scene.pbShowMoney
      if qty>1
        qty=@scene.pbChooseNumber(
           _INTL("{1}?\r\nHow many would you like to sell?",itemname),item,qty)
      end
      if qty==0
        @scene.pbHideMoney
        next
      end
      price/=2
      price*=qty
      if pbConfirm(_INTL("I can pay ${1}.\r\nWould that be OK?",pbCommaNumber(price)))
        @adapter.setMoney(@adapter.getMoney()+price)
        for i in 0...qty
          @adapter.removeItem(item)
        end
        pbDisplayPaused(_INTL("Turned over the {1} and received ${2}.",itemname,pbCommaNumber(price)))
      end
      @scene.pbHideMoney
    end
    @scene.pbEndSellScene
  end
end

def pbPokemonMart(stock,speech=nil,cantsell=false)
  for i in 0...stock.length
    stock[i]=getID(PBItems,stock[i]) if !stock[i].is_a?(Integer)
    if !stock[i] || stock[i]==0 ||
      (pbIsImportantItem?(stock[i]) && $PokemonBag.pbQuantity(stock[i])>0)
      stock[i]=nil
    end
  end
  stock.compact!
  commands=[]
  cmdBuy=-1
  cmdSell=-1
  cmdQuit=-1
  commands[cmdBuy=commands.length]=_INTL("Buy")
  commands[cmdSell=commands.length]=_INTL("Sell") if !cantsell
  commands[cmdQuit=commands.length]=_INTL("Quit")
  cmd=Kernel.pbMessage(
     speech ? speech : _INTL("Welcome!\r\nHow may I serve you?"),
     commands,cmdQuit+1)
  loop do
    if cmdBuy>=0 && cmd==cmdBuy
      scene=PokemonMartScene.new
      screen=PokemonMartScreen.new(scene,stock)
      screen.pbBuyScreen
    elsif cmdSell>=0 && cmd==cmdSell
      scene=PokemonMartScene.new
      screen=PokemonMartScreen.new(scene,stock)
      screen.pbSellScreen
    else
      Kernel.pbMessage(_INTL("Please come again!"))
      break
    end
    cmd=Kernel.pbMessage(
       _INTL("Is there anything else I can help you with?"),commands,cmdQuit+1)
  end
  $game_temp.clear_mart_prices
end

def pbDefaultMart(speech=nil,cantsell=false)
  case $Trainer.numbadges
  when 0
    stock = [PBItems::POTION,PBItems::ANTIDOTE,PBItems::POKEBALL]
  when 1
    stock = [PBItems::POTION,PBItems::ANTIDOTE,PBItems::PARLYZHEAL,PBItems::BURNHEAL,PBItems::ESCAPEROPE,PBItems::REPEL,PBItems::POKEBALL]
  when 2..5
    stock = [PBItems::SUPERPOTION,PBItems::ANTIDOTE,PBItems::PARLYZHEAL,PBItems::BURNHEAL,PBItems::ESCAPEROPE,PBItems::SUPERREPEL,PBItems::POKEBALL]
  when 6..9
    stock = [PBItems::SUPERPOTION,PBItems::ANTIDOTE,PBItems::PARLYZHEAL,PBItems::BURNHEAL,PBItems::ESCAPEROPE,PBItems::SUPERREPEL,PBItems::POKEBALL,PBItems::GREATBALL]
  when 10..12
    stock = [PBItems::POKEBALL,PBItems::GREATBALL,PBItems::ULTRABALL,PBItems::SUPERREPEL,PBItems::MAXREPEL,PBItems::ESCAPEROPE,PBItems::FULLHEAL,PBItems::HYPERPOTION]
  when 13..16
    stock = [PBItems::POKEBALL,PBItems::GREATBALL,PBItems::ULTRABALL,PBItems::SUPERREPEL,PBItems::MAXREPEL,PBItems::ESCAPEROPE,PBItems::FULLHEAL,PBItems::ULTRAPOTION]
  when 17
    stock = [PBItems::POKEBALL,PBItems::GREATBALL,PBItems::ULTRABALL,PBItems::SUPERREPEL,PBItems::MAXREPEL,PBItems::ESCAPEROPE,PBItems::FULLHEAL,PBItems::ULTRAPOTION,PBItems::MAXPOTION]
  when 18
    stock = [PBItems::POKEBALL,PBItems::GREATBALL,PBItems::ULTRABALL,PBItems::SUPERREPEL,PBItems::MAXREPEL,PBItems::ESCAPEROPE,PBItems::FULLHEAL,PBItems::HYPERPOTION,
             PBItems::ULTRAPOTION,PBItems::MAXPOTION,PBItems::FULLRESTORE,PBItems::REVIVE]
  else
    stock = [PBItems::POTION,PBItems::ANTIDOTE,PBItems::POKEBALL]
  end
  for i in 0...stock.length
    stock[i]=getID(PBItems,stock[i]) if !stock[i].is_a?(Integer)
    if !stock[i] || stock[i]==0 ||
       (pbIsImportantItem?(stock[i]) && $PokemonBag.pbQuantity(stock[i])>0)
      stock[i]=nil
    end
  end
  stock.compact!
  commands=[]
  cmdBuy=-1
  cmdSell=-1
  cmdQuit=-1
  commands[cmdBuy=commands.length]=_INTL("Buy")
  commands[cmdSell=commands.length]=_INTL("Sell") if !cantsell
  commands[cmdQuit=commands.length]=_INTL("Quit")
  cmd=Kernel.pbMessage(
     speech ? speech : _INTL("Welcome!\r\nHow may I serve you?"),
     commands,cmdQuit+1)
  loop do
    if cmdBuy>=0 && cmd==cmdBuy
      scene=PokemonMartScene.new
      screen=PokemonMartScreen.new(scene,stock)
      screen.pbBuyScreen
    elsif cmdSell>=0 && cmd==cmdSell
      scene=PokemonMartScene.new
      screen=PokemonMartScreen.new(scene,stock)
      screen.pbSellScreen
    else
      Kernel.pbMessage(_INTL("Please come again!"))
      break
    end
    cmd=Kernel.pbMessage(
       _INTL("Is there anything else I can help you with?"),commands,cmdQuit+1)
  end
  $game_temp.clear_mart_prices
end

class Game_Temp
  attr_writer :mart_prices

  def mart_prices
    @mart_prices=[] if !@mart_prices
    return @mart_prices
  end

  def clear_mart_prices
    @mart_prices=[]
  end
end

class Interpreter
  def getItem(p)
    if p[0]==0
      return $data_items[p[1]]
    elsif p[0]==1
      return $data_weapons[p[1]]
    elsif p[0]==2
      return $data_armors[p[1]]
    end
    return nil
  end

  def command_302
    $game_temp.battle_abort = true
    shop_goods = [getItem(@parameters)]
    # Loop
    loop do
      # Advance index
      @index += 1
      # If next event command has shop on second line or after
      if @list[@index].code == 605
        # Add goods list to new item
        shop_goods.push(getItem(@list[@index].parameters))
      else
        # End
        pbPokemonMart(shop_goods.compact)
        return true
      end
    end
  end

  def setPrice(item,buyprice=-1,sellprice=-1)
    if item.is_a?(String) || item.is_a?(Symbol)
      item=getID(PBItems,item)
    end
    $game_temp.mart_prices[item]=[-1,-1] if !$game_temp.mart_prices[item]
    $game_temp.mart_prices[item][0]=buyprice if buyprice>0
    if sellprice>=0 # 0=can't sell
      $game_temp.mart_prices[item][1]=sellprice*2
    else
      $game_temp.mart_prices[item][1]=buyprice if buyprice>0
    end
  end

  def setSellPrice(item,sellprice)
    setPrice(item,-1,sellprice)
  end
end
