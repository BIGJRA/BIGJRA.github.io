################################################################################
# Mystery Gift system
# By Maruno
################################################################################
# This url is the location of an example Mystery Gift file.
# You should change it to your file's url once you upload it.
################################################################################
MYSTERYGIFTURL = "http://images1.wikia.nocookie.net/pokemonessentials/images/e/e7/MysteryGift.txt"



class PokeBattle_Trainer
  attr_accessor(:mysterygiftaccess)   # Whether MG can be used from load screen
  attr_accessor(:mysterygift)         # Variable that stores downloaded MG data

  def mysterygiftaccess
    @mysterygiftaccess=false if !@mysterygiftaccess
    return @mysterygiftaccess
  end

  def mysterygift
    @mysterygift=[] if !@mysterygift
    return @mysterygift
  end
end



################################################################################
# Creating a new Mystery Gift for the Master file, and editing an existing one.
################################################################################
# type: 0=Pokémon; 1 or higher=item (is the item's quantity).
# item: The thing being turned into a Mystery Gift (Pokémon object or item ID).
def pbEditMysteryGift(type,item,id=0,giftname="",plural="")
  begin
    if type==0   # Pokémon
      commands=[_INTL("Mystery Gift"),
                _INTL("Faraway place")]
      commands.push(item.obtainText) if item.obtainText && item.obtainText!=""
      commands.push(_INTL("[Custom]"))
      loop do
        command=Kernel.pbMessage(
           _INTL("Choose a phrase to be where the gift Pokémon was obtained from."),commands)
        if command>=0 && command<commands.length-1
          item.obtainText=commands[command]
          break
        elsif command==commands.length-1
          obtainname=Kernel.pbMessageFreeText(_INTL("Enter a phrase."),"",false,32)
          if obtainname!=""
            item.obtainText=obtainname
            break
          end
          return nil if Kernel.pbConfirmMessage(_INTL("Stop editng this gift?"))
        elsif command==-1
          return nil if Kernel.pbConfirmMessage(_INTL("Stop editng this gift?"))
        end
      end
    elsif type>0   # Item
      params=ChooseNumberParams.new
      params.setRange(1,99999)
      params.setDefaultValue(type)
      params.setCancelValue(0)
      loop do
        newtype=Kernel.pbMessageChooseNumber(_INTL("Choose a quantity."),params)
        if newtype==0
          return nil if Kernel.pbConfirmMessage(_INTL("Stop editng this gift?"))
        else
          type=newtype
          if type>1 && Kernel.pbConfirmMessage(_INTL("Does this gift need a plural form of its name?"))
            itemname=PBItems.getName(item)
            plural=itemname if plural==""
            newplural=Kernel.pbMessageFreeText(
               _INTL("Enter a plural form of {1}.",plural),plural,false,32)
            newplural="" if !newplural || newplural=="" || newplural==itemname
            plural=newplural
          end
          break
        end
      end
    end
    if id==0
      master=[]; idlist=[]
      if safeExists?("MysteryGiftMaster.txt")
        master=IO.read("MysteryGiftMaster.txt")
        master=pbMysteryGiftDecrypt(master)
      end
      for i in master; idlist.push(i[0]); end
      params=ChooseNumberParams.new
      params.setRange(0,99999)
      params.setDefaultValue(id)
      params.setCancelValue(0)
      loop do
        newid=Kernel.pbMessageChooseNumber(_INTL("Choose a unique ID for this gift."),params)
        if newid==0
          return nil if Kernel.pbConfirmMessage(_INTL("Stop editng this gift?"))
        else
          if idlist.include?(newid)
            Kernel.pbMessage(_INTL("That ID is already used by a Mystery Gift."))
          else
            id=newid
            break
          end
        end
      end
    end
    loop do
      newgiftname=Kernel.pbMessageFreeText(_INTL("Enter a name for the gift."),giftname,false,32)
      if newgiftname!=""
        giftname=newgiftname
        break
      end
      return nil if Kernel.pbConfirmMessage(_INTL("Stop editng this gift?"))
    end
    return [id,type,item,giftname,plural]
  rescue
    Kernel.pbMessage(_INTL("Couldn't edit the gift."))
    return nil
  end
end

def pbCreateMysteryGift(type,item)
  gift=pbEditMysteryGift(type,item)
  if !gift
    Kernel.pbMessage(_INTL("Didn't create a gift."))
  else
    begin
      if safeExists?("MysteryGiftMaster.txt")
        master=IO.read("MysteryGiftMaster.txt")
        master=pbMysteryGiftDecrypt(master)
        master.push(gift)
      else
        master=[gift]
      end
      string=pbMysteryGiftEncrypt(master)
      File.open("MysteryGiftMaster.txt","wb"){|f|
         f.write(string)
      }
      Kernel.pbMessage(_INTL("The gift was saved to MysteryGiftMaster.txt."))
    rescue
      Kernel.pbMessage(_INTL("Couldn't save the gift to MysteryGiftMaster.txt."))
    end
  end
end



################################################################################
# Debug option for managing gifts in the Master file and exporting them to a
# file to be uploaded.
################################################################################
def pbManageMysteryGifts
  if !safeExists?("MysteryGiftMaster.txt")
    Kernel.pbMessage(_INTL("There are no Mystery Gifts defined."))
    return
  end
  # Load all gifts from the Master file.
  master=IO.read("MysteryGiftMaster.txt")
  master=pbMysteryGiftDecrypt(master)
  if !master || !master.is_a?(Array) || master.length==0
    Kernel.pbMessage(_INTL("There are no Mystery Gifts defined."))
    return
  end
  # Download all gifts from online
  msgwindow=Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow,_INTL("Searching for online gifts...\\wtnp[0]"))
  online=pbDownloadToString(MYSTERYGIFTURL)  
  Kernel.pbDisposeMessageWindow(msgwindow)
  if online==""
    Kernel.pbMessage(_INTL("No online Mystery Gifts found.\\wtnp[20]"))
    online=[]
  else
    Kernel.pbMessage(_INTL("Online Mystery Gifts found.\\wtnp[20]"))
    online=pbMysteryGiftDecrypt(online)
    t=[]
    for gift in online; t.push(gift[0]); end
    online=t
  end
  # Show list of all gifts.
  command=0
  loop do
    commands=pbRefreshMGCommands(master,online)
    command=Kernel.pbMessage(_INTL("\\ts[]Manage Mystery Gifts (X=online)."),commands,-1,nil,command)
    # Gift chosen
    if command==-1 || command==commands.length-1
      break
    elsif command==commands.length-2
      begin
        newfile=[]
        for gift in master
          newfile.push(gift) if online.include?(gift[0])
        end
        string=pbMysteryGiftEncrypt(newfile)
        File.open("MysteryGift.txt","wb"){|f|
           f.write(string)
        }
        Kernel.pbMessage(_INTL("The gifts were saved to MysteryGift.txt."))
        Kernel.pbMessage(_INTL("Upload MysteryGift.txt to the Internet."))
      rescue
        Kernel.pbMessage(_INTL("Couldn't save the gifts to MysteryGift.txt."))
      end
    elsif command>=0 && command<commands.length-2
      cmd=0
      loop do
        commands=pbRefreshMGCommands(master,online)
        gift=master[command]
        cmds=[_INTL("Toggle on/offline"),
              _INTL("Edit"),
              _INTL("Receive"),
              _INTL("Delete"),
              _INTL("Cancel")]
        cmd=Kernel.pbMessage("\\ts[]"+commands[command],cmds,-1,nil,cmd)
        if cmd==-1 || cmd==cmds.length-1
          break
        elsif cmd==0   # Toggle on/offline
          if online.include?(gift[0])
            for i in 0...online.length
              online[i]=nil if online[i]==gift[0]
            end
            online.compact!
          else
            online.push(gift[0])
          end
        elsif cmd==1   # Edit
          newgift=pbEditMysteryGift(gift[1],gift[2],gift[0],gift[3],gift[4])
          master[command]=newgift if newgift
        elsif cmd==2   # Receive
          replaced=false
          for i in 0...$Trainer.mysterygift.length
            if $Trainer.mysterygift[i][0]==gift[0]
              $Trainer.mysterygift[i]=gift; replaced=true
            end
          end
          $Trainer.mysterygift.push(gift) if !replaced
          pbReceiveMysteryGift(gift[0])
        elsif cmd==3   # Delete
          if Kernel.pbConfirmMessage(_INTL("Are you sure you want to delete this gift?"))
            master[command]=nil
            master.compact!
          end
          break
        end
      end
    end
  end
end

def pbRefreshMGCommands(master,online)
  commands=[]
  for gift in master
    itemname="BLANK"
    if gift[1]==0
      itemname=PBSpecies.getName(gift[2].species)
    elsif gift[1]>0
      itemname=PBItems.getName(gift[2])+sprintf(" x%d",gift[1])
    end
    ontext=["[  ]","[X]"][(online.include?(gift[0])) ? 1 : 0]
    commands.push(_ISPRINTF("{1:s} {2:d}: {3:s} ({4:s})",ontext,gift[0],gift[3],itemname))
  end
  commands.push(_INTL("Export selected to file"))
  commands.push(_INTL("Cancel"))
  return commands
end



################################################################################
# Downloads all available Mystery Gifts that haven't been downloaded yet.
################################################################################
# Called from the Continue/New Game screen.
def pbDownloadMysteryGift(trainer)
  sprites={}
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  addBackgroundPlane(sprites,"background","mysteryGiftbg",viewport)
  pbFadeInAndShow(sprites)
  sprites["msgwindow"]=Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(sprites["msgwindow"],_INTL("Searching for a gift.\nPlease wait...\\wtnp[0]"))
  string=pbDownloadToString(MYSTERYGIFTURL)  
  if string==""
    Kernel.pbMessageDisplay(sprites["msgwindow"],_INTL("No new gifts are available."))
  else
    online=pbMysteryGiftDecrypt(string)
    pending=[]
    for gift in online
      notgot=true
      for j in trainer.mysterygift
        notgot=false if j[0]==gift[0]
      end
      pending.push(gift) if notgot
    end
    if pending.length==0
      Kernel.pbMessageDisplay(sprites["msgwindow"],_INTL("No new gifts are available."))
    else
      loop do
        commands=[]
        for gift in pending; commands.push(gift[3]); end
        commands.push(_INTL("Cancel"))
        Kernel.pbMessageDisplay(sprites["msgwindow"],_INTL("Choose the gift you want to receive.\\wtnp[0]"))
        command=Kernel.pbShowCommands(sprites["msgwindow"],commands,-1)
        if command==-1 || command==commands.length-1
          break
        else
          gift=pending[command]
          sprites["msgwindow"].visible=false
          if gift[1]==0
            sprite=PokemonSprite.new(viewport)
            sprite.setPokemonBitmap(gift[2])
          else
            sprite=IconSprite.new(0,0,viewport)
            sprite.setBitmap(pbItemIconFile(gift[2]))
          end
          sprite.ox=sprite.bitmap.width/2
          sprite.oy=sprite.bitmap.height/2
          sprite.x=Graphics.width/2
          sprite.y=-sprite.bitmap.height/2
          begin
            Graphics.update
            Input.update
            sprite.y+=4
          end while sprite.y<Graphics.height/2
          pbMEPlay("Jingle - HMTM")
          pbWait(3*Graphics.frame_rate)
          sprites["msgwindow"].visible=true
          Kernel.pbMessageDisplay(sprites["msgwindow"],_INTL("The gift has been received!"))
          Kernel.pbMessageDisplay(sprites["msgwindow"],_INTL("Please pick up your gift from the deliveryman in any Poké Mart."))
          trainer.mysterygift.push(gift)
          pending[command]=nil; pending.compact!
          begin
            Graphics.update
            Input.update
            sprite.opacity-=8
          end while sprite.opacity>0
          sprite.dispose
        end
        if pending.length==0
          Kernel.pbMessageDisplay(sprites["msgwindow"],_INTL("No new gifts are available."))
          break
        end
      end
    end
  end
  pbFadeOutAndHide(sprites)
  Kernel.pbDisposeMessageWindow(sprites["msgwindow"])
  pbDisposeSpriteHash(sprites)
  viewport.dispose
  return trainer
end



################################################################################
# Converts an array of gifts into a string and back.
################################################################################
def pbMysteryGiftEncrypt(gift)
  ret=[Zlib::Deflate.deflate(Marshal.dump(gift))].pack("m")
  return ret
end

def pbMysteryGiftDecrypt(gift)
  return [] if gift==""
  ret=Marshal.restore(Zlib::Inflate.inflate(gift.unpack("m")[0]))
  return ret
end



################################################################################
# Collecting a Mystery Gift from the deliveryman.
################################################################################
def pbNextMysteryGiftID
  for i in $Trainer.mysterygift
    return i[0] if i.length>1
  end
  return 0
end

def pbReceiveMysteryGift(id)
  index=-1
  for i in 0...$Trainer.mysterygift.length
    if $Trainer.mysterygift[i][0]==id && $Trainer.mysterygift[i].length>1
      index=i
      break
    end
  end
  if index==-1
    Kernel.pbMessage(_INTL("Couldn't find an unclaimed Mystery Gift with ID {1}.",id))
    return false
  end
  gift=$Trainer.mysterygift[index]
  if gift[1]==0
    pID=rand(256)
    pID|=rand(256)<<8
    pID|=rand(256)<<16
    pID|=rand(256)<<24
    gift[2].personalID=pID
    gift[2].calcStats
    time=pbGetTimeNow
    gift[2].timeReceived=time.getgm.to_i
    gift[2].obtainMode=4   # Fateful encounter
    gift[2].pbRecordFirstMoves
    if $game_map
      gift[2].obtainMap=$game_map.map_id
      gift[2].obtainLevel=gift[2].level
    else
      gift[2].obtainMap=0
      gift[2].obtainLevel=gift[2].level
    end
    if pbAddPokemonSilent(gift[2])
      Kernel.pbMessage(_INTL("{1} received {2}!\\se[itemlevel]\1",$Trainer.name,gift[2].name))
      $Trainer.mysterygift[index]=[id]
      return true
    end
  elsif gift[1]>0
    if $PokemonBag.pbCanStore?(gift[2],gift[1])
      $PokemonBag.pbStoreItem(gift[2],gift[1])
      item=gift[2]; qty=gift[1]; itemname=PBItems.getName(item)
      if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4
        machine=PBMoves.getName($ItemData[item][ITEMMACHINE])
        Kernel.pbMessage(_INTL("\\se[itemlevel]{1} received \\c[1]{2}\\c[0]!\\nIt contained \\c[1]{3}\\c[0].\\wtnp[30]",
           $Trainer.name,itemname,machine))
      elsif isConst?(item,PBItems,:LEFTOVERS)
        Kernel.pbMessage(_INTL("\\se[itemlevel]{1} received some \\c[1]{2}\\c[0]!\\wtnp[30]",$Trainer.name,itemname))
      elsif qty>1
        if gift[4] && gift[4]!=""
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} received {2} \\c[1]{3}\\c[0]!\\wtnp[30]",$Trainer.name,qty,gift[4]))
        else
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} received {2} \\c[1]{3}s\\c[0]!\\wtnp[30]",$Trainer.name,qty,itemname))
        end
      else
        if "AEIOUaeiou".include?(itemname[0])
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} received an \\c[1]{2}\\c[0]!\\wtnp[30]",$Trainer.name,itemname))
        else
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} received a \\c[1]{2}\\c[0]!\\wtnp[30]",$Trainer.name,itemname))
        end
      end
      $Trainer.mysterygift[index]=[id]
      return true
    end
  end
  return false
end