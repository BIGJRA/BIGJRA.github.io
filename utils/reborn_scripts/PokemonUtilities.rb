################################################################################
# General purpose utilities
################################################################################
def _pbNextComb(comb,length)
  i=comb.length-1
  begin
    valid=true
    for j in i...comb.length
      if j==i
        comb[j]+=1
      else
        comb[j]=comb[i]+(j-i)
      end
      if comb[j]>=length
        valid=false
        break
      end
    end
    return true if valid
    i-=1
  end while i>=0
  return false
end

# Returns the number of moves the given Pokémon knows.
def pbNumMoves(pokemon)
  ret=0
  for i in 0...4
    ret+=1 if pokemon.moves[i].id!=0
  end
  return ret
end

# Iterates through the array and yields each combination of _num_ elements in
# the array.
def pbEachCombination(array,num)
  return if array.length<num || num<=0
  if array.length==num
    yield array
    return
  elsif num==1
    for x in array
      yield [x]
    end
    return
  end
  currentComb=[]
  arr=[]
  for i in 0...num
    currentComb[i]=i
  end
  begin
    for i in 0...num
      arr[i]=array[currentComb[i]]
    end
    yield arr
  end while _pbNextComb(currentComb,array.length)
end

def gameGoByeByeNow
  $scene = nil
  return
end

# Returns a country ID
# http://msdn.microsoft.com/en-us/library/dd374073%28VS.85%29.aspx?
def pbGetCountry()
  getUserGeoID=Win32API.new("kernel32","GetUserGeoID","l","i") rescue nil
  if getUserGeoID
    return getUserGeoID.call(16)
  end
  return 0
end

# Returns a language ID
def pbGetLanguage()
  return System.user_language
end

################################################################################
# Player-related utilities, random name generator
################################################################################
def pbChangePlayer(id)
  return false if id<0
  meta=pbGetMetadata(0,MetadataPlayerA+id)
  return false if !meta
  $Trainer.trainertype=meta[0] if $Trainer
  $game_player.character_name=meta[1]
  $game_player.character_hue=0
  $PokemonGlobal.playerID=id
  $Trainer.metaID=id if $Trainer
end
 
def pbGetPlayerGraphic
  id=$PokemonGlobal.playerID
  return "" if id<0
  meta=pbGetMetadata(0,MetadataPlayerA+id)
  return "" if !meta
  return pbPlayerSpriteFile(meta[0])
end
 
def pbGetPlayerID(variableNumber)
  ret=$PokemonGlobal.playerID
  pbSet(variableNumber,ret)
  return nil
end
 
def pbGetPlayerTrainerType
  id=$PokemonGlobal.playerID
  return 0 if id<0
  meta=pbGetMetadata(0,MetadataPlayerA+id)
  return 0 if !meta
  return meta[0]
end 

def pbGetTrainerTypeGender(trainertype)
  ret=2 # 2 = gender unknown
  if !$cache.trainertypes[trainertype]
    ret=2
  else
    ret=$cache.trainertypes[trainertype][7]
    ret=2 if !ret
  end
  return ret
end

def pbTrainerName(name=nil)
  if $PokemonGlobal.playerID<0
    pbChangePlayer(0)
  end
  trainertype=pbGetPlayerTrainerType
  trname=name
  if trname==nil
 trname=pbEnterText(_INTL("Your name?"),0,12)
 gender=pbGetTrainerTypeGender(trainertype) 
    if trname==""
      trname=pbSuggestTrainerName(gender)
    end
  end
  $Trainer=PokeBattle_Trainer.new(trname,trainertype)
  $PokemonBag=PokemonBag.new
  $PokemonTemp.begunNewGame=true
end

def pbSuggestTrainerName(gender)
  userName=pbGetUserName()
  userName=userName.gsub(/\s+.*$/,"")
  if userName.length>0 && userName.length<12
    userName[0,1]=userName[0,1].upcase
    return userName
  end
  userName=userName.gsub(/\d+$/,"")
  if userName.length>0 && userName.length<12
    userName[0,1]=userName[0,1].upcase
    return userName
  end
  return getRandomNameEx(gender,nil,1,7)
end

def pbGetUserName()
  return "Frank" if $idk[:settings].streamermode && $idk[:settings].streamermode==1
  return System.user_name
end

def getRandomNameEx(type,variable,upper,maxLength=100)
  return "" if maxLength<=0
  name=""
  50.times {
    name=""
    formats=[]
    case type
      when 0 # Names for males
        formats=%w( F5 BvE FE FE5 FEvE )
      when 1 # Names for females
        formats=%w( vE6 vEvE6 BvE6 B4 v3 vEv3 Bv3 )
      when 2 # Neutral gender names
        formats=%w( WE WEU WEvE BvE BvEU BvEvE )
      else
        return ""
    end
    format=formats[rand(formats.length)]
    format.scan(/./) {|c|
       case c
         when "c" # consonant
           set=%w( b c d f g h j k l m n p r s t v w x z )
           name+=set[rand(set.length)]
         when "v" # vowel
           set=%w( a a a e e e i i i o o o u u u )
           name+=set[rand(set.length)]
         when "W" # beginning vowel
           set=%w( a a a e e e i i i o o o u u u au au ay ay 
              ea ea ee ee oo oo ou ou )
           name+=set[rand(set.length)]
         when "U" # ending vowel
           set=%w( a a a a a e e e i i i o o o o o u u ay ay ie ie ee ue oo )
           name+=set[rand(set.length)]
         when "B" # beginning consonant
           set1=%w( b c d f g h j k l l m n n p r r s s t t v w y z )
           set2=%w(
              bl br ch cl cr dr fr fl gl gr kh kl kr ph pl pr sc sk sl
              sm sn sp st sw th tr tw vl zh )
           name+=rand(3)>0 ? set1[rand(set1.length)] : set2[rand(set2.length)]
         when "E" # ending consonant
           set1=%w( b c d f g h j k k l l m n n p r r s s t t v z )
           set2=%w( bb bs ch cs ds fs ft gs gg ld ls
              nd ng nk rn kt ks
              ms ns ph pt ps sk sh sp ss st rd
              rn rp rm rt rk ns th zh)
           name+=rand(3)>0 ? set1[rand(set1.length)] : set2[rand(set2.length)]
         when "f" # consonant and vowel
           set=%w( iz us or )
           name+=set[rand(set.length)]
         when "F" # consonant and vowel
           set=%w( bo ba be bu re ro si mi zho se nya gru gruu glee gra glo ra do zo ri
              di ze go ga pree pro po pa ka ki ku de da ma mo le la li )
           name+=set[rand(set.length)]
         when "2"
           set=%w( c f g k l p r s t )
           name+=set[rand(set.length)]
         when "3"
           set=%w( nka nda la li ndra sta cha chie )
           name+=set[rand(set.length)]
         when "4"
           set=%w( una ona ina ita ila ala ana ia iana )
           name+=set[rand(set.length)]
         when "5"
           set=%w( e e o o ius io u u ito io ius us )
           name+=set[rand(set.length)]
         when "6"
           set=%w( a a a elle ine ika ina ita ila ala ana )
           name+=set[rand(set.length)]
       end
    }
    break if name.length<=maxLength
  }
  name=name[0,maxLength]
  case upper
    when 0
      name=name.upcase
    when 1
      name[0,1]=name[0,1].upcase
  end
  if $game_variables && variable
    $game_variables[variable]=name
    $game_map.need_refresh = true if $game_map
  end
  return name
end

def getRandomName(maxLength=100)
  return getRandomNameEx(2,nil,nil,maxLength)
end

def loadTrainerCard(trainername,trainermoney=0,trainerbadges=0,trainerid=$Trainer.id)
  $Trainer.tempname = $Trainer.name
  $Trainer.tempmoney = $Trainer.money
  $Trainer.tempbadges = $Trainer.badges
  $Trainer.tempid = $Trainer.id
  $Trainer.name = trainername
  $Trainer.money = trainermoney
  badgearray = []
  for i in 0...17
    badgearray[i]=  i < trainerbadges ? true : nil
  end
  $Trainer.badges = badgearray
  $Trainer.id = trainerid
end

def restoreTrainerCard
  $Trainer.name = $Trainer.tempname
  $Trainer.money = $Trainer.tempmoney
  $Trainer.badges = $Trainer.tempbadges
  $Trainer.id = $Trainer.tempid
end

################################################################################
# Event timing utilities
################################################################################
def pbTimeEvent(variableNumber,secs=86400)
  if variableNumber && variableNumber>=0
    if $game_variables
      secs=0 if secs<0
      timenow=pbGetTimeNow
      $game_variables[variableNumber]=[timenow.to_f,secs]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventDays(variableNumber,days=0)
  if variableNumber && variableNumber>=0
    if $game_variables
      days=0 if days<0
      timenow=pbGetTimeNow
      time=timenow.to_f
      expiry=(time%86400.0)+(days*86400.0)
      $game_variables[variableNumber]=[time,expiry-time]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventValid(variableNumber)
  retval=false
  if variableNumber && variableNumber>=0 && $game_variables
    value=$game_variables[variableNumber]
    if value.is_a?(Array)
      timenow=pbGetTimeNow
      retval=(timenow.to_f - value[0] > value[1]) # value[1] is age in seconds
      retval=false if value[1]<=0 # zero age
    end
    if !retval
      $game_variables[variableNumber]=0
      $game_map.refresh if $game_map
    end
  end
  return retval
end



################################################################################
# Constants utilities
################################################################################
def isConst?(val,mod,constant)
  begin
    return (val==mod.const_get(constant.to_sym))
  rescue
    print("broken constant #{constant}")
    print caller
    return false
  end
end

def hasConst?(mod,constant)
  return false if !mod || !constant || constant==""
  begin
    return mod.const_defined?(constant.to_sym) 
  rescue 
    print("broken constant #{constant}")
    print caller
    return false
  end
end

def getConst(mod,constant)
  return nil if !mod || !constant
  begin
    return mod.const_get(constant.to_sym)
  rescue 
    return nil
  end
end

def getID(mod,constant)
  return nil if !mod || !constant || constant==""
  if constant.is_a?(Symbol) || constant.is_a?(String)
    begin
      return mod.const_get(constant.to_sym)
    rescue
      print("broken constant #{constant}")
      print caller
      return 0
    end
  else
    return constant
  end
end



################################################################################
# Implements methods that act on arrays of items.  Each element in an item
# array is itself an array of [itemID, itemCount].
# Used by the Bag, PC item storage, and Triple Triad.
################################################################################
module ItemStorageHelper
  # Returns the quantity of the given item in the items array, maximum size per slot, and item ID
  def self.pbQuantity(items,maxsize,item)
    ret=0
    for i in 0...maxsize
      itemslot=items[i]
      if itemslot && itemslot[0]==item
        ret+=itemslot[1]
      end
    end
    return ret
  end

  # Deletes an item from items array, maximum size per slot, item, and number of items to delete
  def self.pbDeleteItem(items,maxsize,item,qty)
    raise "Invalid value for qty: #{qty}" if qty<0
    return true if qty==0
    ret=false
    for i in 0...maxsize
      itemslot=items[i]
      if itemslot && itemslot[0]==item
        amount=[qty,itemslot[1]].min
        itemslot[1]-=amount
        qty-=amount
        items[i]=nil if itemslot[1]==0
        if qty==0
          ret=true
          break
        end
      end
    end
    items.compact!
    return ret
  end

  def self.pbCanStore?(items,maxsize,maxPerSlot,item,qty)
    raise "Invalid value for qty: #{qty}" if qty<0
    return true if qty==0
    for i in 0...maxsize
      itemslot=items[i]
      if !itemslot
        qty-=[qty,maxPerSlot].min
        return true if qty==0
      elsif itemslot[0]==item && itemslot[1]<maxPerSlot
        newamt=itemslot[1]
        newamt=[newamt+qty,maxPerSlot].min
        qty-=(newamt-itemslot[1])
        return true if qty==0
      end
    end
    return false
  end

  def self.pbStoreItem(items,maxsize,maxPerSlot,item,qty,sorting=false)
    raise "Invalid value for qty: #{qty}" if qty<0
    return true if qty==0
    for i in 0...maxsize 
      itemslot=items[i]
      if !itemslot     
        items[i]=[item,[qty,maxPerSlot].min]
        qty-=items[i][1]
        if sorting && POCKETAUTOSORT[$cache.items[item][ITEMPOCKET]]
          if $cache.items[item][ITEMPOCKET]==4
           pocket  = items
           counter = 1
           while counter < pocket.length
             index     = counter
             while index > 0
               indexPrev = index - 1
               firstName  = (((PBItems.getName(pocket[indexPrev][0])).sub("TM","00")).sub("X","100")).to_i
               secondName = (((PBItems.getName(pocket[index][0])).sub("TM","00")).sub("X","100")).to_i 
               if firstName > secondName
                 aux               = pocket[index] 
                 pocket[index]     = pocket[indexPrev]
                 pocket[indexPrev] = aux
               end
               index -= 1
             end
             counter += 1
           end
          elsif $cache.items[item][ITEMPOCKET]==5
           items.sort!
          end         
        end
        return true if qty==0
      elsif itemslot[0]==item && itemslot[1]<maxPerSlot
        newamt=itemslot[1]
        newamt=[newamt+qty,maxPerSlot].min
        qty-=(newamt-itemslot[1])
        itemslot[1]=newamt
        return true if qty==0
      end
    end
    return false
  end
end

################################################################################
# General-purpose utilities with dependencies
################################################################################
# Similar to pbFadeOutIn, but pauses the music as it fades out.
# Requires scripts "Audio" (for bgm_pause) and "SpriteWindow" (for pbFadeOutIn).
def pbFadeOutInWithMusic(zViewport)
  playingBGS=$game_system.getPlayingBGS
  playingBGM=$game_system.getPlayingBGM
  $game_system.bgm_pause(1.0)
  $game_system.bgs_pause(1.0)
  pos=$game_system.bgm_position
  pbFadeOutIn(zViewport) {
     yield
     $game_system.bgm_position=pos
     $game_system.bgm_resume(playingBGM)
     $game_system.bgs_resume(playingBGS)
  }
end

def pbHideVisibleObjects
  begin
    visibleObjects=[]
    ObjectSpace.each_object(Viewport){|o|
      if !o.disposed? && o.visible
        visibleObjects.push(o)
        o.visible=false
      end
    }
    ObjectSpace.each_object(Tilemap){|o|
      if !o.disposed? && o.visible
        visibleObjects.push(o)
        o.visible=false
      end
    }
    # ObjectSpace.each_object(Window){|o|
    #   if !o.disposed? && o.visible
    #     visibleObjects.push(o)
    #     o.visible=false
    #   end
    # }
  rescue
    visibleObjects=[]
  end
    return visibleObjects
end

def pbShowObjects(visibleObjects)
  for o in visibleObjects
    if !pbDisposed?(o)
      o.visible=true
    end
  end
end

def pbLoadRpgxpScene(scene)
  return if !$scene.is_a?(Scene_Map)
  oldscene=$scene
  $scene=scene
  Graphics.freeze
  oldscene.disposeSpritesets
  visibleObjects=pbHideVisibleObjects
  
  Graphics.transition(15)
  Graphics.freeze
  Graphics.update
  
  while $scene && !$scene.is_a?(Scene_Map)
    $scene.main
  end
  Graphics.transition(15)
  Graphics.freeze
  oldscene.createSpritesets
  pbShowObjects(visibleObjects)
  Graphics.transition(20)
  $scene=oldscene
end

# Runs a common event and waits until the common event is finished.
# Requires the script "PokemonMessages"
def pbCommonEvent(id)
  return false if id<0
  ce=$cache.RXevents[id]
  return false if !ce
  celist=ce.list
  interp=Interpreter.new
  interp.setup(celist,0)
  begin
    Graphics.update
    Input.update
    interp.update
    pbUpdateSceneMap
  end while interp.running?
  return true
end

def pbExclaim(event,id=EXCLAMATION_ANIMATION_ID,tinting=false)
  if event.is_a?(Array)
    sprite=nil
    done=[]
    for i in event
      if !done.include?(i.id)
        sprite=$scene.spriteset.addUserAnimation(id,i.x,i.y,tinting)
        done.push(i.id)
      end
    end
  else
    sprite=$scene.spriteset.addUserAnimation(id,event.x,event.y,tinting)
  end
  while !sprite.disposed?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

def pbNoticePlayer(event)
#  if !pbFacingEachOther(event,$game_player)
    pbExclaim(event)
 # end
  pbTurnTowardEvent($game_player,event)
  Kernel.pbMoveTowardPlayer(event)
end
  

################################################################################
# Loads Pokémon/item/trainer graphics
################################################################################
def pbPokemonBitmap(species, shiny=false, back=false, gender=nil)   # Used by the Pokédex
  if $dexForms == nil
    $dexForms = Array.new(807) {|i| 0}
  end
  gender = $Trainer.formlastseen[species][0] if gender == nil && species != 0
  if $dexForms[species-1] == 0
    gendermod = gender == 1 ? "f" : ""
  end
  bitmapFileName=sprintf("Graphics/Battlers/%03d%s",species,gendermod)
  bitmapFileName=sprintf("Graphics/Battlers/%03d",species) if !pbResolveBitmap(bitmapFileName)
  return nil if !pbResolveBitmap(bitmapFileName)
  monbitmap = RPG::Cache.load_bitmap(bitmapFileName)
  bitmap=Bitmap.new(192,192)
  x = shiny ? 192 : 0
  y = $dexForms[species-1] ? $dexForms[species-1]*384 : 0
  y += back ? 192 : 0
  y = 0 if monbitmap.height <= y
	rectangle = Rect.new(x,y,192,192)
  bitmap.blt(0,0,monbitmap,rectangle)
  return bitmap
end

def pbLoadPokemonBitmap(pokemon, back=false)
  return pbLoadPokemonBitmapSpecies(pokemon,nil,back) if pokemon == "substitute"
  return pbLoadPokemonBitmapSpecies(pokemon,pokemon.species,back)
end

ShitList = [PBSpecies::EXEGGUTOR,PBSpecies::KYUREM,PBSpecies::TANGROWTH,PBSpecies::STEELIX,PBSpecies::AVALUGG,PBSpecies::CLAWITZER,PBSpecies::SWALOT]
# This is a lie now; leaving it in case we care later: Note: Returns an AnimatedBitmap, not a Bitmap
def pbLoadPokemonBitmapSpecies(pokemon, species, back=false)
  #load dummy bitmap
  #ret=AnimatedBitmap.new(pbResolveBitmap("Graphics/pixel"))
  if pokemon=="substitute"
    if !back
      bitmapFileName=sprintf("Graphics/Battlers/substitute")
    else
      bitmapFileName=sprintf("Graphics/Battlers/substitute_b")
    end    
    bitmapFileName=pbResolveBitmap(bitmapFileName)
    ret=Bitmap.new(bitmapFileName)
    return ret
  end
  if pokemon.form !=0 && ShitList.include?(species)
    if !(species == PBSpecies::STEELIX && pokemon.form == 1) #mega steelix is excused.
			formnumber = "_"+pokemon.form.to_s
      shinytag = pokemon.isShiny? ? "s" : ""
      backtag = back ? "b" : ""
      if pbResolveBitmap(sprintf("Graphics/Battlers/%03d%s%s%s",species,shinytag,backtag,formnumber))
        return RPG::Cache.load_bitmap(sprintf("Graphics/Battlers/%03d%s%s%s",species,shinytag,backtag,formnumber))
      end
    end
  end
  x = pokemon.isShiny? ? 192 : 0
  x = 0 if pokemon.isPulse?
  y = pokemon.form*384
  y = 8*384 if (species == PBSpecies::SILVALLY && pokemon.form == 19) #Vulpes abusing her dev priviledges
  y = pokemon.form*192 if pokemon.isEgg?
  y += back ? 192 : 0
  if pokemon.form == 0
    gendermod = pokemon.gender == 1 ? "f" : ""
  end
  height = 192
  if pokemon.isEgg?
    #eggs are 64*64 instead of 192*192
    x/=3
    y/=3
    height/=3
    bitmapFileName=sprintf("Graphics/Battlers/%03d%sEgg",species,gendermod) if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Battlers/%03dEgg",species) if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Battlers/Egg") if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName=pbCheckPokemonBitmapFiles(species,pokemon.isFemale?)
    # Alter bitmap if supported
  end
  spritesheet = RPG::Cache.load_bitmap(bitmapFileName)
  bitmap=Bitmap.new(height,height)
  if spritesheet.height <= y && pokemon.isFemale? && !pokemon.isEgg?
    bitmapFileName=pbCheckPokemonBitmapFiles(species)
    spritesheet = RPG::Cache.load_bitmap(bitmapFileName)
    bitmap=Bitmap.new(height,height)
  end
  if spritesheet.height <= y
    y = 0
    y += back ? 192 : 0
  end
	rectangle = Rect.new(x,y,height,height)
  bitmap.blt(0,0,spritesheet,rectangle)
  if pokemon.species == PBSpecies::SPINDA && !pokemon.isEgg?
    #bitmap.each {|bitmap|
    pbSpindaSpots(pokemon,bitmap)
    #}
  end
  return bitmap
end

def pbCheckPokemonBitmapFiles(species,girl=false)
  gendermod = girl == true ? "f" : ""
  species = species[0] if species.kind_of?(Array)
  bitmapFileName=sprintf("Graphics/Battlers/%03d%s",species,gendermod)
  ret=pbResolveBitmap(bitmapFileName)
  return ret if ret
  bitmapFileName=sprintf("Graphics/Battlers/%03d",species)
  ret=pbResolveBitmap(bitmapFileName)
  return ret if ret
  return pbResolveBitmap(sprintf("Graphics/Battlers/000")) 
end

def pbLoadPokemonIcon(pokemon)
  return pbPokemonIconBitmap(pokemon)
end

def pbPokemonIconBitmap(pokemon,egg=false)   # pbpokemonbitmap, but for icons
  shiny = pokemon.isShiny?
  girl = pokemon.isFemale? ? "f" : ""
  form = pokemon.form
  egg = egg ? "egg" : ""
  species = pokemon.species
  filename=sprintf("Graphics/Icons/icon%03d%s%s",species,girl,egg) if form == 0
  filename=sprintf("Graphics/Icons/icon%03d%s",species,egg) if !pbResolveBitmap(filename)
  filename=sprintf("Graphics/Icons/iconEgg") if !pbResolveBitmap(filename)
  filename=sprintf("Graphics/Icons/icon000") if !pbResolveBitmap(filename)
  iconbitmap = RPG::Cache.load_bitmap(filename)
  bitmap=Bitmap.new(128,64)
  x = shiny ? 128 : 0
  y = form*64
  y = 0 if iconbitmap.height <= y
	rectangle = Rect.new(x,y,128,64)
  bitmap.blt(0,0,iconbitmap,rectangle)
  return bitmap
end

def pbIconBitmap(species,form:0,shiny:false,girl:false,egg:false)   # pbpokemonbitmap, but for icons
  egg = egg ? "Egg" : ""
  filename=sprintf("Graphics/Icons/icon%s%03d%s",girl,species,egg) if form == 0
  filename=sprintf("Graphics/Icons/icon%03d%s",species,egg) if !pbResolveBitmap(filename)
  filename=sprintf("Graphics/Icons/iconEgg") if !pbResolveBitmap(filename)
  filename=sprintf("Graphics/Icons/icon000") if !pbResolveBitmap(filename)
  iconbitmap = RPG::Cache.load_bitmap(filename)
  bitmap=Bitmap.new(128,64)
  x = shiny ? 128 : 0
  y = form*64
  y = 0 if iconbitmap.height <= y
	rectangle = Rect.new(x,y,128,64)
  return bitmap
end

def pbPokemonIconFile(pokemon)
  bitmapFileName=pbResolveBitmap(sprintf("Graphics/Icons/icon000"))
  bitmapFileName=pbCheckPokemonIconFiles([pokemon.species, (pokemon.isFemale?), pokemon.isShiny?, (pokemon.form rescue 0), (pokemon.isShadow? rescue false)], pokemon.isEgg?)
  return bitmapFileName
end

def pbCheckPokemonIconFiles(params,egg=false)
  species=params[0]
  if egg
    formnumber = params[3].to_s rescue 0
    formmodifier = formnumber != 0 && formnumber != "0" ? "_"+formnumber.to_s : ""
    shiny = params[2] ? "s" : ""
    gendermod = params[1] == true ? "f" : ""
    bitmapFileName=sprintf("Graphics/Icons/icon%03d%s%s%segg",species,gendermod,shiny,formmodifier) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Icons/icon%segg",getConstantName(PBSpecies,species)) rescue nil
      if !pbResolveBitmap(bitmapFileName) 
        bitmapFileName=sprintf("Graphics/Icons/icon%03d%segg",species,formmodifier)
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName=sprintf("Graphics/Icons/icon%03degg",species) 
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName=sprintf("Graphics/Icons/iconEgg")
          end
        end
      end
    end
    return pbResolveBitmap(bitmapFileName)
  else
    factors=[]
    factors.push([4,params[4],false]) if params[4] && params[4]!=false     # shadow
    factors.push([1,params[1],false]) if params[1] && params[1]!=false     # gender
    factors.push([2,params[2],false]) if params[2] && params[2]!=false     # shiny
    factors.push([3,params[3].to_s,""]) if params[3] && params[3].to_s!="" &&
                                                        params[3].to_s!="0" # form
    tshadow=false
    tgender=false
    tshiny=false
    tform=""
    for i in 0...2**factors.length
      for j in 0...factors.length
        case factors[j][0]
          when 1   # gender
            tgender=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
          when 2   # shiny
            tshiny=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
          when 3   # form
            tform=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
          when 4   # shadow
            tshadow=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
        end
      end
      bitmapFileName=sprintf("Graphics/Icons/icon%s%s%s%s%s",
         getConstantName(PBSpecies,species),
         tgender ? "f" : "",
         tshiny ? "s" : "",
         (tform!="" ? "_"+tform : ""),
         tshadow ? "_shadow" : "") rescue nil
      ret=pbResolveBitmap(bitmapFileName)
      return ret if ret
      bitmapFileName=sprintf("Graphics/Icons/icon%03d%s%s%s%s", species, tgender ? "f" : "", tshiny ? "s" : "", (tform!="" ? "_"+tform : ""), tshadow ? "_shadow" : "")
      ret=pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return pbResolveBitmap(sprintf("Graphics/Icons/icon000"))
end

def pbPokemonFootprintFile(species)   # Used by the Pokédex
  return nil if !species
  bitmapFileName=sprintf("Graphics/Icons/Footprints/footprint%s",getConstantName(PBSpecies,species)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Icons/Footprints/footprint%03d",species)
  end
  return pbResolveBitmap(bitmapFileName)
end

def pbItemIconFile(item)
  return nil if !item
  bitmapFileName=nil
  if item==0
    bitmapFileName=sprintf("Graphics/Icons/itemBack")
  else
    moveid = $cache.items[item][ITEMMACHINE]
    if moveid != 0 #This is 0 if it's not a TM.
      type = $cache.pkmn_move[moveid][2]
      typename = PBTypes.getName(type)
      bitmapFileName=sprintf("Graphics/Icons/TM - %s",typename)
    else
      bitmapFileName=sprintf("Graphics/Icons/item%s",getConstantName(PBItems,item)) rescue nil
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName=sprintf("Graphics/Icons/item%03d",item)
      end
    end
  end
  return bitmapFileName
end

def pbMailBackFile(item)
  return nil if !item
  bitmapFileName=sprintf("Graphics/Pictures/mail%s",getConstantName(PBItems,item)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Pictures/mail%03d",item)
  end
  return bitmapFileName
end

def pbTrainerCharFile(type)
  return nil if !type
  bitmapFileName=sprintf("Graphics/Characters/trchar%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Characters/trchar%03d",type)
  end
  return bitmapFileName
end

def pbTrainerCharNameFile(type)
  return nil if !type
  bitmapFileName=sprintf("trchar%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(sprintf("Graphics/Characters/"+bitmapFileName))
    bitmapFileName=sprintf("trchar%03d",type)
  end
  return bitmapFileName
end

def pbTrainerHeadFile(type)
  return nil if !type
  bitmapFileName=sprintf("Graphics/Pictures/mapPlayer%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Pictures/mapPlayer%03d",type)
  end
  return bitmapFileName
end

def pbPlayerHeadFile(type)
  return nil if !type
  outfit=$Trainer ? $Trainer.outfit : 0
  bitmapFileName=sprintf("Graphics/Pictures/mapPlayer%s_%d",
     getConstantName(PBTrainers,type),outfit) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Pictures/mapPlayer%03d_%d",type,outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=pbTrainerHeadFile(type)
    end
  end
  return bitmapFileName
end

def pbTrainerSpriteFile(type)
  return nil if !type
  bitmapFileName=sprintf("Graphics/Characters/trainer%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Characters/trainer%03d",type)
  end
  return bitmapFileName
end

def pbTrainerSpriteBackFile(type)
  return nil if !type
  bitmapFileName=sprintf("Graphics/Characters/trback%s",getConstantName(PBTrainers,type)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Characters/trback%03d",type)
  end
  return bitmapFileName
end

def pbPlayerSpriteFile(type)
  return nil if !type
  outfit=$Trainer ? $Trainer.outfit : 0
  bitmapFileName=sprintf("Graphics/Characters/trainer%s_%d",
     getConstantName(PBTrainers,type),outfit) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Characters/trainer%03d_%d",type,outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=pbTrainerSpriteFile(type)
    end
  end
  return bitmapFileName
end

def pbPlayerSpriteBackFile(type)
  return nil if !type
  outfit=$Trainer ? $Trainer.outfit : 0
  bitmapFileName=sprintf("Graphics/Characters/trback%s_%d",
     getConstantName(PBTrainers,type),outfit) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    bitmapFileName=sprintf("Graphics/Characters/trback%03d_%d",type,outfit)
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=pbTrainerSpriteBackFile(type)
    end
  end
  return bitmapFileName
end



################################################################################
# Loads music and sound effects
################################################################################
def pbResolveAudioSE(file)
  return nil if !file
  if RTP.exists?("Audio/SE/"+file,["",".wav",".mp3",".ogg"])
    return RTP.getPath("Audio/SE/"+file,["",".wav",".mp3",".ogg"])
  end
  return nil
end

def getPlayTime(filename)
  if safeExists?(filename)
    return [getPlayTime2(filename),0].max
  elsif safeExists?(filename+".wav")
    return [getPlayTime2(filename+".wav"),0].max
  elsif safeExists?(filename+".mp3")
    return [getPlayTime2(filename+".mp3"),0].max
  elsif safeExists?(filename+".ogg")
    return [getPlayTime2(filename+".ogg"),0].max
  else
    return 0
  end
end

def getPlayTime2(filename)
  time=-1
  return -1 if !safeExists?(filename)
  fgetdw=proc{|file|
     (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  fgetw=proc{|file|
     (file.eof? ? 0 : (file.read(2).unpack("v")[0] || 0))
  }
  File.open(filename,"rb"){|file|
     file.pos=0
     fdw=fgetdw.call(file)
     if fdw==0x46464952 # "RIFF"
       filesize=fgetdw.call(file)
       wave=fgetdw.call(file)
       if wave!=0x45564157 # "WAVE"
         return -1
       end
       fmt=fgetdw.call(file)
       if fmt!=0x20746d66 # "fmt "
         return -1
       end
       fmtsize=fgetdw.call(file)
       format=fgetw.call(file)
       channels=fgetw.call(file)
       rate=fgetdw.call(file)
       bytessec=fgetdw.call(file)
       if bytessec==0
         return -1
       end
       bytessample=fgetw.call(file)
       bitssample=fgetw.call(file)
       data=fgetdw.call(file)
       if data!=0x61746164 # "data"
         return -1
       end
       datasize=fgetdw.call(file)
       time=(datasize*1.0)/bytessec
       return time
     elsif fdw==0x5367674F # "OggS"
       file.pos=0
       time=oggfiletime(file)
       return time
     end
     file.pos=0
     # Find the length of an MP3 file
     while true
       rstr=""
       ateof=false
       while !file.eof?
         if (file.read(1)[0] rescue 0)==0xFF
           begin; rstr=file.read(3); break; rescue; ateof=true; break; end
         end
       end
       break if ateof || !rstr || rstr.length!=3
       if rstr[0]==0xFB
         t=rstr[1]>>4
         next if t==0 || t==15
         freqs=[44100,22050,11025,48000]
         bitrates=[32,40,48,56,64,80,96,112,128,160,192,224,256,320]
         bitrate=bitrates[t]
         t=(rstr[1]>>2)&3
         freq=freqs[t]
         t=(rstr[1]>>1)&1
         filesize=FileTest.size(filename)
         frameLength=((144000*bitrate)/freq)+t
         numFrames=filesize/(frameLength+4)
         time=(numFrames*1152.0/freq)
         break
       end
     end
  }
  return time
end

# internal function
def oggfiletime(file)
  fgetdw = proc { |file|
    (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  pages = []
  page = nil
  loop do
    page = getOggPage(file)
    break if !page
    pages.push(page)
    file.pos = page[3]
  end
  return -1 if pages.length == 0
  curserial = nil
  i = -1
  pcmlengths = []
  rates = []
  for page in pages
    header = page[0]
    serial = header[10, 4].unpack("V")
    frame = header[2, 8].unpack("C*")
    frameno = frame[7]
    frameno = (frameno << 8) | frame[6]
    frameno = (frameno << 8) | frame[5]
    frameno = (frameno << 8) | frame[4]
    frameno = (frameno << 8) | frame[3]
    frameno = (frameno << 8) | frame[2]
    frameno = (frameno << 8) | frame[1]
    frameno = (frameno << 8) | frame[0]
    if serial != curserial
      curserial = serial
      file.pos = page[1]
      packtype = (file.read(1)[0].ord rescue 0)
      string = file.read(6)
      return -1 if string != "vorbis"
      return -1 if packtype != 1
      i += 1
      version = fgetdw.call(file)
      return -1 if version != 0
      rates[i] = fgetdw.call(file)
    end
    pcmlengths[i] = frameno
  end
  ret = 0.0
  for i in 0...pcmlengths.length
    ret += pcmlengths[i].to_f / rates[i].to_f
  end
  return ret * 256.0
end

def getOggPage(file)
  fgetdw = proc { |file|
    (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  dw = fgetdw.call(file)
  return nil if dw != 0x5367674F
  header = file.read(22)
  bodysize = 0
  hdrbodysize = (file.read(1)[0].ord rescue 0)
  hdrbodysize.times do
    bodysize += (file.read(1)[0].ord rescue 0)
  end
  ret = [header, file.pos, bodysize, file.pos + bodysize]
  return ret
end

def pbCryFrameLength(pokemon,pitch=nil)
  return 0 if !pokemon
  pitch=100 if !pitch
  pitch=pitch.to_f/100
  return 0 if pitch<=0
  playtime=0.0
  if pokemon.is_a?(Numeric)
    pkmnwav=pbResolveAudioSE(pbCryFile(pokemon))
    playtime=getPlayTime(pkmnwav) if pkmnwav
  elsif !pokemon.isEgg?
    if pokemon.respond_to?("chatter") && pokemon.chatter
      playtime=pokemon.chatter.time
      pitch=1.0
    else
      pkmnwav=pbResolveAudioSE(pbCryFile(pokemon))
      playtime=getPlayTime(pkmnwav) if pkmnwav
    end 
  end
  playtime/=pitch # sound is lengthened the lower the pitch
  # 4 is added to provide a buffer between sounds
  return (playtime*Graphics.frame_rate).ceil+4
end

def pbPlayCry(pokemon,volume=90,pitch=nil)
  return if !pokemon
  if pokemon.is_a?(Numeric)
    pkmnwav=pbCryFile(pokemon)
    if pkmnwav
      pbSEPlay(RPG::AudioFile.new(pkmnwav,volume,pitch ? pitch : 100)) rescue nil
    end
  elsif !pokemon.isEgg?
    if pokemon.respond_to?("chatter") && pokemon.chatter
      pokemon.chatter.play
    else
      pkmnwav=pbCryFile(pokemon)
      if pkmnwav
        pbSEPlay(RPG::AudioFile.new(pkmnwav,volume,
           pitch ? pitch : (pokemon.hp*25/pokemon.totalhp)+75)) rescue nil
      end
    end
  end
end

def pbCryFile(pokemon)
  return nil if !pokemon
  if pokemon.is_a?(Numeric)
    filename=sprintf("%sCry",getConstantName(PBSpecies,pokemon)) rescue nil
    filename=sprintf("%03dCry",pokemon) if !pbResolveAudioSE(filename)
    return filename if pbResolveAudioSE(filename)
  elsif !pokemon.isEgg?
    filename=sprintf("%sCry_%d",getConstantName(PBSpecies,pokemon.species),(pokemon.form rescue 0)) rescue nil
    filename=sprintf("%03dCry_%d",pokemon.species,(pokemon.form rescue 0)) if !pbResolveAudioSE(filename)
    if !pbResolveAudioSE(filename)
      filename=sprintf("%sCry",getConstantName(PBSpecies,pokemon.species)) rescue nil
    end
    filename=sprintf("%03dCry",pokemon.species) if !pbResolveAudioSE(filename)
    return filename if pbResolveAudioSE(filename)
  end
  return nil
end

def pbGetWildBattleBGM(species)
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  ret=nil
  if PBStuff::LEGENDARYLIST.include?(species)
    ret=pbStringToAudioFile("Battle- Legendary") if !ret
  end
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapWildBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataWildBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  ret=pbStringToAudioFile("Battle- Wild") if !ret
  return ret
end

def pbGetWildVictoryME
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  ret=nil
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapWildVictoryME)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataWildVictoryME)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  ret=pbStringToAudioFile("001-Victory01") if !ret
  ret.name="../../Audio/ME/"+ret.name
  return ret
end

def pbPlayTrainerIntroME(trainertype)
  if $cache.trainertypes[trainertype]
    bgm=$cache.trainertypes[trainertype][6]
    if bgm && bgm!=""
      bgm=pbStringToAudioFile(bgm)
      pbMEPlay(bgm)
      return
    end
  end
end

def pbGetTrainerBattleBGM(trainer) # can be a PokeBattle_Trainer or an array of PokeBattle_Trainer  
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  music=nil
  if !trainer.is_a?(Array)
    trainerarray=[trainer]
  else
    trainerarray=trainer
  end
  for i in 0...trainerarray.length
    trainertype=trainerarray[i].trainertype
    if $cache.trainertypes[trainertype]
      music=$cache.trainertypes[trainertype][4]
    end
  end
  ret=nil
  if music && music!=""
    ret=pbStringToAudioFile(music)
  end
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapTrainerBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataTrainerBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  return ret
end

def pbGetTrainerBattleBGMFromType(trainertype)
  if $PokemonGlobal.nextBattleBGM
    return $PokemonGlobal.nextBattleBGM.clone
  end
  music=nil
  if $cache.trainertypes[trainertype]
    music=$cache.trainertypes[trainertype][4]
  end
  ret=nil
  if music && music!=""
    ret=pbStringToAudioFile(music)
  end
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapTrainerBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataTrainerBattleBGM)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  return ret
end

def pbGetOnlineBattleBGM(trainer) # can be a PokeBattle_Trainer or an array of PokeBattle_Trainer  
  if trainer.onlineMusic == nil
    trainer.onlineMusic = "Battle- Trainer.mp3"
  end  
  music = trainer.onlineMusic
  ret=nil
  if music && music!=""
    ret=pbStringToAudioFile(music)
  end
  return ret
end

def pbGetTrainerVictoryME(trainer) # can be a PokeBattle_Trainer or an array of PokeBattle_Trainer
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  music=nil
  if !trainer.is_a?(Array)
    trainerarray=[trainer]
  else
    trainerarray=trainer
  end
  for i in 0...trainerarray.length
    trainertype=(trainerarray[i].trainertype).to_i
    if $cache.trainertypes[trainertype]
      music=$cache.trainertypes[trainertype][5]
    end
  end
  ret=nil
  if music && music!=""
    ret=pbStringToAudioFile(music)
  end
  if !ret && $game_map
    # Check map-specific metadata
    music=pbGetMetadata($game_map.map_id,MetadataMapTrainerVictoryME)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music=pbGetMetadata(0,MetadataTrainerVictoryME)
    if music && music!=""
      ret=pbStringToAudioFile(music)
    end
  end
  ret.name="../../Audio/ME/"+ret.name
  return ret
end



################################################################################
# Creating and storing Pokémon
################################################################################
def pbBoxesFull?
  return !$Trainer || ($Trainer.party.length==6 && $PokemonStorage.full?)
end

def pbNickname(pokemon)
  speciesname=PBSpecies.getName(pokemon.species)
  return "" if !Kernel.pbConfirmMessage(_INTL("Would you like to give a nickname to {1}?",speciesname))
  
  helptext=_INTL("{1}'s nickname?",speciesname)
  newname=pbEnterText(helptext,0,12,"",2,pokemon)
  pokemon.name=newname if newname!=""
  return newname
end

def pbStorePokemon(pokemon)
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    monsent=false
    while !monsent
      if Kernel.pbConfirmMessageSerious(_INTL("The party is full; do you want to send a party member to the PC?"))
        iMon = -2 
        unusablecount = 0
        for i in $Trainer.party
          next if i.isEgg?
          next if i.hp<1
          unusablecount += 1
        end
        pbFadeOutIn(99999){
          scene=PokemonScreen_Scene.new
          screen=PokemonScreen.new(scene,$Trainer.party)
          screen.pbStartScene(_INTL("Choose a Pokémon."),false)
          loop do
            iMon=screen.pbChoosePokemon
            if iMon>=0 && ($Trainer.party[iMon].knowsMove?(:CUT) || $Trainer.party[iMon].knowsMove?(:ROCKSMASH) || $Trainer.party[iMon].knowsMove?(:STRENGTH) || $Trainer.party[iMon].knowsMove?(:SURF) || $Trainer.party[iMon].knowsMove?(:WATERFALL) || $Trainer.party[iMon].knowsMove?(:DIVE) || $Trainer.party[iMon].knowsMove?(:ROCKCLIMB) || $Trainer.party[iMon].knowsMove?(:FLASH) || $Trainer.party[iMon].knowsMove?(:FLY))
              Kernel.pbMessage("You can't return a Pokémon that knows a TMX move to the PC.") 
              iMon=-2
            elsif unusablecount<=1 && !($Trainer.party[iMon].isEgg?) && $Trainer.party[iMon].hp>0 && pokemon.isEgg?
              Kernel.pbMessage("That's your last Pokémon!") 
            else
              screen.pbEndScene
              break
            end
          end
        }
        if !(iMon < 0)    
          iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
          if iBox >= 0
            monsent=true
            $Trainer.party[iMon].heal
            Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
            $Trainer.party[iMon] = nil
            $Trainer.party.compact!
            $Trainer.party[$Trainer.party.length]=pokemon
          else
            Kernel.pbMessage("No space left in the PC")
            return false
          end
        end      
      else
        monsent=true
        oldcurbox=$PokemonStorage.currentBox
        storedbox=$PokemonStorage.pbStoreCaught(pokemon)
        curboxname=$PokemonStorage[oldcurbox].name
        boxname=$PokemonStorage[storedbox].name
        creator=nil
        creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
        if storedbox!=oldcurbox
          if creator
            Kernel.pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
          else
            Kernel.pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
          end
          Kernel.pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
        else
          if creator
            Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
          else
            Kernel.pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
          end
          Kernel.pbMessage(_INTL("It was stored in box \"{1}\".",boxname))
        end
      end    
    end
  end
end

def pbNicknameAndStore(pokemon)
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbNickname(pokemon)
  #pbEnterPokemonName(helptext,0,12,"",pokemon)
  pbStorePokemon(pokemon)
end

def pbAddPokemon(pokemon,level=nil,seeform=true)
  return if !pokemon || !$Trainer 
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  speciesname=PBSpecies.getName(pokemon.species)
  pokemon.timeReceived=Time.new
  if pokemon.ot == ""
    pokemon.ot = $Trainer.name 
    pokemon.trainerID = $Trainer.id
  end  
  
  if hasConst?(PBItems,:SHINYCHARM) && $PokemonBag.pbQuantity(PBItems::SHINYCHARM)>0
    for i in 0...2   # 3 times as likely (should be 0...2)
      break if pokemon.isShiny?
      pokemon.personalID=rand(65536)|(rand(65536)<<16)
    end
  end 
  
  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[itemlevel]\1",$Trainer.name,speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end

def pbAddPokemonSilent(pokemon,level=nil,seeform=true)
  return false if !pokemon || pbBoxesFull? || !$Trainer
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  if pokemon.ot == ""
    pokemon.ot = $Trainer.name 
    pokemon.trainerID = $Trainer.id
  end  
  if pokemon.eggsteps<=0
    $Trainer.seen[pokemon.species]=true
    $Trainer.owned[pokemon.species]=true
    pbSeenForm(pokemon) if seeform
  end
  pokemon.timeReceived=Time.new
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    monsent=false
    while !monsent
      if Kernel.pbConfirmMessageSerious(_INTL("The party is full; do you want to send a party member to the PC?"))
        iMon = -2 
        unusablecount = 0
        for i in $Trainer.party
          next if i.isEgg?
          next if i.hp<1
          unusablecount += 1
        end
        pbFadeOutIn(99999){
          scene=PokemonScreen_Scene.new
          screen=PokemonScreen.new(scene,$Trainer.party)
          screen.pbStartScene(_INTL("Choose a Pokémon."),false)
          loop do
            iMon=screen.pbChoosePokemon
            if iMon>=0 && ($Trainer.party[iMon].knowsMove?(:CUT) || $Trainer.party[iMon].knowsMove?(:ROCKSMASH) || $Trainer.party[iMon].knowsMove?(:STRENGTH) || $Trainer.party[iMon].knowsMove?(:SURF) || $Trainer.party[iMon].knowsMove?(:WATERFALL) || $Trainer.party[iMon].knowsMove?(:DIVE) || $Trainer.party[iMon].knowsMove?(:ROCKCLIMB) || $Trainer.party[iMon].knowsMove?(:FLASH) || $Trainer.party[iMon].knowsMove?(:FLY))
              Kernel.pbMessage("You can't return a Pokémon that knows a TMX move to the PC.") 
              iMon=-2
            elsif unusablecount<=1 && !($Trainer.party[iMon].isEgg?) && $Trainer.party[iMon].hp>0 && pokemon.isEgg?
              Kernel.pbMessage("That's your last Pokémon!") 
            else
              screen.pbEndScene
              break
            end
          end
        }
        if !(iMon < 0)
          iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
          if iBox >= 0
            monsent=true
            Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
            $Trainer.party[iMon] = nil
            $Trainer.party.compact!
            $Trainer.party[$Trainer.party.length]=pokemon
          else
            Kernel.pbMessage("No space left in the PC.")
            return false
          end
        end      
      else
        monsent=true
        storedbox = $PokemonStorage.pbStoreCaught(pokemon)
        if pokemon.isEgg?
         oldcurbox=$PokemonStorage.currentBox
         #storedbox=$PokemonStorage.pbStoreCaught(pokemon)
         curboxname=$PokemonStorage[oldcurbox].name
         boxname=$PokemonStorage[storedbox].name
         creator=nil
         creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
          if storedbox!=oldcurbox
            if creator
              Kernel.pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
            else
              Kernel.pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
            end
            Kernel.pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
          else
            if creator
              Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
            else
              Kernel.pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
            end
            Kernel.pbMessage(_INTL("It was stored in box \"{1}\".",boxname))
          end
        end
      end
    end    
  end
  return true
end

def pbAddRentalPokemonSilent(pokemon,level=nil)
  return false if !pokemon || pbBoxesFull? || !$Trainer
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  if pokemon.ot == ""
    pokemon.ot = $Trainer.name 
    pokemon.trainerID = $Trainer.id
  end
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
  end
  return true
end

def pbAddToParty(pokemon,level=nil,seeform=true)
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  speciesname=PBSpecies.getName(pokemon.species)
  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[itemlevel]\1",$Trainer.name,speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end

def pbAddToPartySilent(pokemon,level=nil,seeform=true)
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length]=pokemon
  return true
end

def pbAddForeignPokemon(pokemon,level=nil,ownerName=nil,nickname=nil,ownerGender=0,seeform=true)
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  # Set original trainer to a foreign one (if ID isn't already foreign)
  if pokemon.trainerID==$Trainer.id
    pokemon.trainerID=$Trainer.getForeignID
    pokemon.ot=ownerName if ownerName && ownerName!=""
    pokemon.otgender=ownerGender
  end
  # Set nickname
  pokemon.name=nickname[0,12] if nickname && nickname!=""
  # Recalculate stats
  pokemon.calcStats
  if ownerName
    Kernel.pbMessage(_INTL("{1} received a Pokémon from {2}.\1",$Trainer.name,ownerName))
  else
    Kernel.pbMessage(_INTL("{1} received a Pokémon.\1",$Trainer.name))
  end
  pbStorePokemon(pokemon)
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  return true
end

def pbGenerateEgg(pokemon,text="")
  return false if !pokemon || !$Trainer #|| $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,EGGINITIALLEVEL,$Trainer)
  end
  # Set egg's details
  pokemon.name=_INTL("Egg")
  pokemon.eggsteps=$cache.pkmn_dex[pokemon.species][:EggSteps]
  pokemon.obtainText=text
  pokemon.calcStats
  # Add egg to party
  #$Trainer.party[$Trainer.party.length]=pokemon
  return pokemon
  #return true
end

def pbRemovePokemonAt(index)
  return false if index<0 || !$Trainer || index>=$Trainer.party.length
  haveAble=false
  for i in 0...$Trainer.party.length
    next if i==index
    haveAble=true if $Trainer.party[i].hp>0 && !$Trainer.party[i].isEgg?
  end
  return false if !haveAble
  $Trainer.party.delete_at(index)
  return true
end

def pbSeenForm(poke,gender=0,form=0)
  $Trainer.formseen=[] if !$Trainer.formseen
  $Trainer.formlastseen=[] if !$Trainer.formlastseen
  if poke.is_a?(String) || poke.is_a?(Symbol)
    poke=getID(PBSpecies,poke)
  end
  if poke.is_a?(PokeBattle_Pokemon)
    gender=poke.gender
    form=(poke.form rescue 0)
    species=poke.species
  else
    species=poke
  end
  return if !species || species<=0
  gender=0 if gender>1
  formnames=pbGetMessage(MessageTypes::FormNames,species)
  form=0 if !formnames || formnames==""
  $Trainer.formseen[species]=[[],[]] if !$Trainer.formseen[species]
  $Trainer.formseen[species][gender][form]=true
  $Trainer.formlastseen[species]=[] if !$Trainer.formlastseen[species]
  $Trainer.formlastseen[species]=[gender,form] if $Trainer.formlastseen[species]==[]
end


def LevelLimitExpGain(pokemon, exp) # For exp candies
  leadersDefeated = $Trainer.numbadges
  if pokemon.level>=LEVELCAPS[leadersDefeated] || pokemon.level>=100 + $game_variables[:Extended_Max_Level] || $game_switches[:No_EXP_Gain]
    return -1
  elsif pokemon.level<LEVELCAPS[leadersDefeated]
    levelcap = [LEVELCAPS[leadersDefeated], 100 + $game_variables[:Extended_Max_Level]].min
    totalExpNeeded = PBExperience.pbGetStartExperience(levelcap, pokemon.growthrate)
    currExpNeeded = totalExpNeeded - pokemon.exp
    if exp > currExpNeeded
      return currExpNeeded
    end
  end
  return exp
end

################################################################################
# Analysing Pokémon
################################################################################
# Heals all Pokémon in the party.
def pbHealAll
  return if !$Trainer
  for i in $Trainer.party
    if $game_switches[:Nuzlocke_Mode] == false || i.hp>0
      i.heal
    end
  end
end

# Heals all Pokémon in the party of Status.
def pbHealAllStatus
  return if !$Trainer
  for i in $Trainer.party
    i.healStatus
    i.healStatus
  end
end

# Heals all surviving Pokemon in party.
def pbPartialHeal
  return if !$Trainer
  for i in $Trainer.party
    if i&& !i.isEgg? && i.hp>0
      i.healStatus
      i.healHP
    end
  end
end

# Heals all surviving Pokemon in party.
def pbReviveHeal
  return if !$Trainer
  for i in $Trainer.party
    if i&& !i.isEgg? && i.hp==0
      i.status=0
      i.hp=1+(i.totalhp/2.0).floor
    end
  end
end


# Returns the first unfainted, non-egg Pokémon in the player's party.
def pbFirstAblePokemon(variableNumber)
  for i in 0...$Trainer.party.length
    p=$Trainer.party[i]
    if p && !p.isEgg? && p.hp>0
      pbSet(variableNumber,i)
      return $Trainer.party[i]
    end
  end
  pbSet(variableNumber,-1)
  return nil
end

# Checks whether the player would still have an unfainted Pokémon if the
# Pokémon given by _pokemonIndex_ were removed from the party.
def pbCheckAble(pokemonIndex)
  for i in 0...$Trainer.party.length
    p=$Trainer.party[i]
    next if i==pokemonIndex
    return true if p && !p.isEgg? && p.hp>0
  end
  return false
end

# Returns true if there are no usable Pokémon in the player's party.
def pbAllFainted
  for i in $Trainer.party
    return false if !i.isEgg? && i.hp>0
  end
  return true
end

# Returns true if the given species can be legitimately obtained as an egg.
def pbHasEgg?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  evospecies=pbGetEvolvedFormData(species)
  compatspecies=(evospecies && evospecies[0]) ? evospecies[0][2] : species
  compat1=$cache.pkmn_dex[species][:EggGroups]   # Get egg group of this species
  return false if compat1==13 || compat1==15   # Ditto or can't breed
  baby=pbGetBabySpecies(species)
  return true if species==baby   # Is a basic species
  baby=pbGetNonIncenseLowestSpecies(baby)
  return true if species==baby   # Is an egg species without incense
  return false
end



################################################################################
# Look through Pokémon in storage, choose a Pokémon in the party
################################################################################
# Yields every Pokémon/egg in storage in turn.
def pbEachPokemon
  for i in -1...$PokemonStorage.maxBoxes
    for j in 0...$PokemonStorage.maxPokemon(i)
      poke=$PokemonStorage[i][j]
      yield(poke,i) if poke
    end
  end
end

# Yields every Pokémon in storage in turn.
def pbEachNonEggPokemon
  pbEachPokemon{|pokemon,box|
     yield(pokemon,box) if !pokemon.isEgg?
  }
end

# Choose a Pokémon/egg from the party.
# Stores result in variable _variableNumber_ and the chosen Pokémon's name in
# variable _nameVarNumber_; result is -1 if no Pokémon was chosen
def pbChoosePokemon(variableNumber,nameVarNumber,ableProc=nil, allowIneligible=false)
  chosen=0
  pbFadeOutIn(99999){
     scene=PokemonScreen_Scene.new
     screen=PokemonScreen.new(scene,$Trainer.party)
     if ableProc
       chosen=screen.pbChooseAblePokemon(ableProc,allowIneligible)      
     else
       screen.pbStartScene(_INTL("Choose a Pokémon."),false)
       chosen=screen.pbChoosePokemon
       screen.pbEndScene
     end
  }
  pbSet(variableNumber,chosen)
  if chosen>=0
    pbSet(nameVarNumber,$Trainer.party[chosen].name)
  else
    pbSet(nameVarNumber,"")
  end
end

def pbChooseNonEggPokemon(variableNumber,nameVarNumber)
  pbChoosePokemon(variableNumber,nameVarNumber,proc {|poke|
     !poke.isEgg?
  })
end

def pbChooseAblePokemon(variableNumber,nameVarNumber)
  pbChoosePokemon(variableNumber,nameVarNumber,proc {|poke|
    !poke.isEgg? && poke.hp>0
  })
end

def pbHasSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.species==species
  end
  return false
end

def pbHasFatefulSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    species=getID(PBSpecies,species)
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.species==species && pokemon.obtainMode==4
  end
  return false
end

# Deletes the move at the given index from the given Pokémon.
def pbDeleteMove(pokemon,index)
  newmoves=[]
  for i in 0...4
    newmoves.push(pokemon.moves[i]) if i!=index
  end
  newmoves.push(PBMove.new(0))
  for i in 0...4
    pokemon.moves[i]=newmoves[i]
  end
end

# Deletes the given move from the given Pokémon.
def pbDeleteMoveByID(pokemon,id)
  return if !id || id==0 || !pokemon
  newmoves=[]
  for i in 0...4
    newmoves.push(pokemon.moves[i]) if pokemon.moves[i].id!=id
  end
  newmoves.push(PBMove.new(0))
  for i in 0...4
    pokemon.moves[i]=newmoves[i]
  end
end

# Checks whether any Pokémon in the party knows the given move, and returns
# the index of that Pokémon, or nil if no Pokémon has that move.
def pbCheckMove(move)
  move=getID(PBMoves,move)
  return nil if !move || move<=0
  if $game_switches[:EasyHMs_Password]
    if $cache.items
      for aItem in 0...$cache.items.length
        next if !$cache.items[aItem]
        if pbIsTechnicalMachine?(aItem)
          if $cache.items[aItem][8] == move # ITEMMACHINE   = 8
            if $PokemonBag.pbQuantity(aItem) > 0
              aIDs = []
              for i in 0...$Trainer.party.length
                aPoke = $Trainer.party[i]
                if !aPoke.isEgg? && aPoke.hp>0
                  aIDs.push(i)
                end
              end
              
              aID = aIDs[rand(aIDs.length)]
              
              return $Trainer.party[aID]
            end
          end
        end
      end
    end
    if move == (PBMoves::HEADBUTT)
      aIDs = []
      for i in 0...$Trainer.party.length
        aPoke = $Trainer.party[i]
        if !aPoke.isEgg? && aPoke.hp>0
          aIDs.push(i)
        end
      end
      
      aID = aIDs[rand(aIDs.length)]
      
      return $Trainer.party[aID]
    end
  end
  
  for i in $Trainer.party
    next if i.isEgg?
    for j in i.moves
      return i if j.id==move
    end
  end
  return nil
end



################################################################################
# Regional and National Pokédexes
################################################################################
# Gets the Regional Pokédex number of the national species for the specified
# Regional Dex.  The parameter "region" is zero-based.  For example, if two
# regions are defined, they would each be specified as 0 and 1.
def pbGetRegionalNumber(region, nationalSpecies)
  if nationalSpecies<=0 || nationalSpecies>PBSpecies.maxValue
    # Return 0 if national species is outside range
    return 0
  end
  if $cache.regions[region][nationalSpecies]
    return $cache.regions[region][nationalSpecies]
  else
    return 0
  end
end

# Gets the National Pokédex number of the specified species and region.  The
# parameter "region" is zero-based.  For example, if two regions are defined,
# they would each be specified as 0 and 1.
def pbGetNationalNumber(region, regionalSpecies)
  for i in 1...$cache.regions[region].length
    next if $cache.regions[region][i].nil?
    return i if $cache.regions[region][i] == regionalSpecies
  end
  return 0
end

# Gets an array of all national species within the given Regional Dex, sorted by
# Regional Dex number.  The number of items in the array should be the
# number of species in the Regional Dex plus 1, since index 0 is considered
# to be empty.  The parameter "region" is zero-based.  For example, if two
# regions are defined, they would each be specified as 0 and 1.
def pbAllRegionalSpecies(region)
  ret=[0]
  if region>=0
    for i in 1...$cache.regions[region].length
      next if $cache.regions[region][i].nil?
      regionalNum = $cache.regions[region][i]
      ret[regionalNum] = i if regionalNum!=0
    end
    for i in 0...ret.length
      ret[i]=0 if !ret[i]
    end
  end
  return ret
end

# Gets the ID number for the current region based on the player's current
# position.  Returns the value of "defaultRegion" (optional, default is -1) if
# no region was defined in the game's metadata.  The ID numbers returned by
# this function depend on the current map's position metadata.
def pbGetCurrentRegion(defaultRegion=-1)
  mappos=!$game_map ? nil : pbGetMetadata($game_map.map_id,MetadataMapPosition)
  if !mappos
    return defaultRegion # No region defined
  else
    return mappos[0]
  end
end

# Decides which Dex lists are able to be viewed (i.e. they are unlocked and have
# at least 1 seen species in them), and saves all viable dex region numbers
# (National Dex comes after regional dexes).
# If the Dex list shown depends on the player's location, this just decides if
# a species in the current region has been seen - doesn't look at other regions.
# Here, just used to decide whether to show the Pokédex in the Pause menu.
def pbSetViableDexes
  $PokemonGlobal.pokedexViable=[]
  if DEXDEPENDSONLOCATION
    region=pbGetCurrentRegion
    region=-1 if region>=$PokemonGlobal.pokedexUnlocked.length-1
    if $Trainer.pokedexSeen(region)>0
      $PokemonGlobal.pokedexViable[0]=region
    end
  else
    numDexes=$PokemonGlobal.pokedexUnlocked.length
    case numDexes
      when 1          # National Dex only
        if $PokemonGlobal.pokedexUnlocked[0]
          if $Trainer.pokedexSeen>0
            $PokemonGlobal.pokedexViable.push(0)
          end
        end
      else            # Regional dexes + National Dex
        for i in 0...numDexes
          regionToCheck=(i==numDexes-1) ? -1 : i
          if $PokemonGlobal.pokedexUnlocked[i]
            if $Trainer.pokedexSeen(regionToCheck)>0
              $PokemonGlobal.pokedexViable.push(i)
            end
          end
        end
    end
  end
end

# Unlocks a Dex list.  The National Dex is -1 here (or nil argument).
def pbUnlockDex(dex=-1)
  index=dex
  index=$PokemonGlobal.pokedexUnlocked.length-1 if index<0
  index=$PokemonGlobal.pokedexUnlocked.length-1 if index>$PokemonGlobal.pokedexUnlocked.length-1
  $PokemonGlobal.pokedexUnlocked[index]=true
end

# Locks a Dex list.  The National Dex is -1 here (or nil argument).
def pbLockDex(dex=-1)
  index=dex
  index=$PokemonGlobal.pokedexUnlocked.length-1 if index<0
  index=$PokemonGlobal.pokedexUnlocked.length-1 if index>$PokemonGlobal.pokedexUnlocked.length-1
  $PokemonGlobal.pokedexUnlocked[index]=false
end



################################################################################
# Other utilities
################################################################################
def pbTextEntry(helptext,minlength,maxlength,variableNumber)
  $game_variables[variableNumber]=pbEnterText(helptext,minlength,maxlength)
  $game_map.need_refresh = true if $game_map
end

def pbMoveTutorAnnotations(move,movelist=nil)
  ret=[]
  for i in 0...6
    ret[i]=nil
    next if i>=$Trainer.party.length
    found=false
    for j in 0...4
      if !$Trainer.party[i].isEgg? && $Trainer.party[i].moves[j].id==move
        ret[i]=_INTL("LEARNED")
        found=true
      end
    end
    next if found
    species=$Trainer.party[i].species
    if !$Trainer.party[i].isEgg? && movelist && movelist.any?{|j| j==species }
      # Checked data from movelist
      ret[i]=_INTL("ABLE")
    elsif !$Trainer.party[i].isEgg? && pbSpeciesCompatible?(species,move,$Trainer.party[i])
      # Checked data from PBS/tm.txt
      ret[i]=_INTL("ABLE")
    else
      ret[i]=_INTL("NOT ABLE")
    end
  end
  return ret
end

def pbMoveTutorChoose(move,movelist=nil,bymachine=false)
  ret=false
  pbFadeOutIn(99999){
     scene=PokemonScreen_Scene.new
     movename=PBMoves.getName(move)
     screen=PokemonScreen.new(scene,$Trainer.party)
     annot=pbMoveTutorAnnotations(move,movelist)
     screen.pbStartScene(_INTL("Teach which Pokémon?"),false,annot)
     loop do
       chosen=screen.pbChoosePokemon
       if chosen>=0
         pokemon=$Trainer.party[chosen]
         if pokemon.isEgg?
           Kernel.pbMessage(_INTL("{1} can't be taught to an Egg.",movename))
         elsif (pokemon.isShadow? rescue false)
           Kernel.pbMessage(_INTL("Shadow Pokémon can't be taught any moves."))
         elsif movelist && !movelist.any?{|j| j==pokemon.species }
           Kernel.pbMessage(_INTL("{1} is not compatible with {2}.",pokemon.name,movename))
           Kernel.pbMessage(_INTL("{1} can't be learned.",movename))
         elsif !pbSpeciesCompatible?(pokemon.species,move,pokemon)
           Kernel.pbMessage(_INTL("{1} is not compatible with {2}.",pokemon.name,movename))
           Kernel.pbMessage(_INTL("{1} can't be learned.",movename))
         else
           if pbLearnMove(pokemon,move,false,bymachine)
             ret=true
             break
           end
         end
       else
         break
       end  
     end
     screen.pbEndScene
  }
  return ret # Returns whether the move was learned by a Pokemon
end

def pbChooseMove(pokemon,variableNumber,nameVarNumber)
  return if !pokemon
  ret=-1
  pbFadeOutIn(99999){
     scene=PokemonSummaryScene.new
     screen=PokemonSummary.new(scene)
     ret=screen.pbStartForgetScreen([pokemon],0,0)
  }
  $game_variables[variableNumber]=ret
  if ret>=0
    $game_variables[nameVarNumber]=PBMoves.getName(pokemon.moves[ret].id)
  else
    $game_variables[nameVarNumber]=""
  end
  $game_map.need_refresh = true if $game_map
end

# Opens the Pokémon screen
def pbPokemonScreen
  return if !$Trainer
  sscene=PokemonScreen_Scene.new
  sscreen=PokemonScreen.new(sscene,$Trainer.party)
  pbFadeOutIn(99999) { sscreen.pbPokemonScreen }
end

def pbSaveScreen
  ret=false
  scene=PokemonSaveScene.new
  screen=PokemonSave.new(scene)
  ret=screen.pbSaveScreen
  return ret
end

def pbConvertItemToItem(variable,array)
  item=pbGet(variable)
  pbSet(variable,0)
  for i in 0...(array.length/2)
    if isConst?(item,PBItems,array[2*i])
      pbSet(variable,getID(PBItems,array[2*i+1]))
      return
    end
  end
end

def pbConvertItemToPokemon(variable,array)
  item=pbGet(variable)
  pbSet(variable,0)
  for i in 0...(array.length/2)
    if isConst?(item,PBItems,array[2*i])
      pbSet(variable,getID(PBSpecies,array[2*i+1]))
      return
    end
  end
end

def pbCommaNumber(number)
  return number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
end

# Ruby 2.7
if ! Array.method_defined?(:nitems)
  class Array
    def nitems
      count{|x| !x.nil?}
    end
  end
end

module Input
  LeftMouseKey  = 1
  RightMouseKey = 2
  F3    = 23
  F4    = 24
  F5    = 25
  PAGEUP = L
  PAGEDOWN = R
  ITEMKEYS      = [Input::F5,Input::F4,Input::F3]
  ITEMKEYSNAMES = [_INTL("F5"),_INTL("F4"),_INTL("F3")]

  def self.getstate(button)
    self.pressex?(button)
  end
end

module Mouse
  module_function

  # Returns the position of the mouse relative to the game window.
  def getMousePos(catch_anywhere = false)
    return nil unless System.mouse_in_window || catch_anywhere
    return Input.mouse_x, Input.mouse_y
  end
end
