class PokeBattle_Trainer
  attr_accessor(:name)
  attr_accessor(:id)
  attr_accessor(:metaID)
  attr_accessor(:trainertype)
  attr_accessor(:outfit)
  attr_accessor(:badges)
  attr_accessor(:money)
  attr_accessor(:seen)
  attr_accessor(:owned)
  attr_accessor(:formseen)
  attr_accessor(:formlastseen)
  attr_accessor(:shadowcaught)
  attr_accessor(:party)
  attr_accessor(:pokedex)    # Whether the Pokédex was obtained
  attr_accessor(:pokegear)   # Whether the Pokégear was obtained
  attr_accessor(:language)
  attr_accessor(:lastSave)
  attr_accessor(:saveNumber)
  attr_accessor(:backupNames)
  attr_accessor(:noOnlineBattle)
  attr_accessor(:storedOnlineParty)  
  attr_accessor(:onlineMusic)
  attr_accessor(:onlineAllowNickNames)
  attr_accessor(:tempname)
  attr_accessor(:tempmoney)
  attr_accessor(:tempbadges)
  attr_accessor(:tempid)

  def trainerTypeName   # Name of this trainer type (localized)
    return PBTrainers.getName(@trainertype) rescue _INTL("PkMn Trainer")
  end

  def fullname
    return _INTL("{1} {2}",self.trainerTypeName,@name)
  end

  def publicID(id=nil)   # Portion of the ID which is visible on the Trainer Card
    return id ? id&0xFFFF : @id&0xFFFF
  end

  def secretID(id=nil)   # Other portion of the ID
    return id ? id>>16 : @id>>16
  end

  def getForeignID   # Random ID other than this Trainer's ID
    fid=0
    loop do
      fid=rand(256)
      fid|=rand(256)<<8
      fid|=rand(256)<<16
      fid|=rand(256)<<24
      break if fid!=@id
    end
    return fid 
  end

  def setForeignID(other)
    @id=other.getForeignID
  end

  def metaID
    @metaID=$PokemonGlobal.trainerID if !@metaID && $PokemonGlobal
    @metaID=0 if !@metaID
    return @metaID
  end

  def outfit
    @outfit=0 if !@outfit
    return @outfit
  end

  def language
    @language=pbGetLanguage() if !@language
    return @language
  end

  def money=(value)
    @money=[[value,MAXMONEY].min,0].max
  end

  def moneyEarned   # Money won when trainer is defeated
    ret=0
    return 30 if !$cache.trainertypes[@trainertype]
    ret=$cache.trainertypes[@trainertype][3]
    return ret
  end

  attr_accessor(:skill)

  def skill   # Skill level (for AI)
    if !defined?(@skill)
      ret=0
      return 30 if !$cache.trainertypes[@trainertype]
      ret=$cache.trainertypes[@trainertype][8]
      @skill = ret
      return ret
    else
      return @skill
    end
  end

  def skill=(value)
    @skill=value
  end

  def numbadges   # Number of badges
    ret=0
    for i in 0...@badges.length
      ret+=1 if @badges[i]
    end
    return ret
  end

  def gender
    ret=2   # 2 = gender unknown
    return 2 if !$cache.trainertypes[@trainertype]
    ret=$cache.trainertypes[@trainertype][7]
    return ret
  end

  def isMale?; return self.gender==0; end
  def isFemale?; return self.gender==1; end

  def pokemonParty
    return @party.find_all {|item| item && !item.isEgg? }
  end

  def ablePokemonParty
    return @party.find_all {|item| item && !item.isEgg? && item.hp>0 }
  end

  def partyCount
    return @party.length
  end

  def pokemonCount
    ret=0
    for i in 0...@party.length
      ret+=1 if @party[i] && !@party[i].isEgg?
    end
    return ret
  end

  def ablePokemonCount
    ret=0
    for i in 0...@party.length
      ret+=1 if @party[i] && !@party[i].isEgg? && @party[i].hp>0
    end
    return ret
  end

  def lastParty
    return nil if @party.length==0
    return @party[@party.length-1]
  end

  def lastPokemon
    p=self.pokemonParty
    return nil if p.length==0
    return p[p.length-1]
  end

  def lastAblePokemon
    p=self.ablePokemonParty
    return nil if p.length==0
    return p[p.length-1]
  end

  def pokedexSeen(region=-1)   # Number of Pokémon seen
    ret=0
    if region==-1
      for i in 0..PBSpecies.maxValue
        ret+=1 if @seen[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        ret+=1 if @seen[i]
      end
    end
    return ret
  end

  def pokedexOwned(region=-1)   # Number of Pokémon owned
    ret=0
    if region==-1
      for i in 0..PBSpecies.maxValue
        ret+=1 if @owned[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        ret+=1 if @owned[i]
      end
    end
    return ret
  end

  def numFormsSeen(species)
    ret=0
    array=@formseen[species]
    for i in 0...[array[0].length,array[1].length].max
      ret+=1 if array[0][i] || array[1][i]
    end
    return ret
  end

  def hasSeen?(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    return species>0 ? @seen[species] : false
  end

  def hasOwned?(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    return species>0 ? @owned[species] : false
  end

  def setSeen(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    @seen[species]=true if species>0
  end

  def setOwned(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    @owned[species]=true if species>0
  end

  def clearPokedex
    @seen=[]
    @owned=[]
    @formseen=[]
    @formlastseen=[]
    for i in 1..PBSpecies.maxValue
      @seen[i]=false
      @owned[i]=false
      @formlastseen[i]=[]
      @formseen[i]=[[],[]]
    end
  end

  def initialize(name,trainertype)
    playerTTypes = [0,1,24,25,52,53]
    @name=name
    @language=pbGetLanguage()
    @trainertype=trainertype
    @id=rand(256)
    @id|=rand(256)<<8
    @id|=rand(256)<<16
    @id|=rand(256)<<24
    @metaID=0
    @outfit=0
    @pokegear=false
    @pokedex=false
    if playerTTypes.include?(trainertype)
      clearPokedex
      @shadowcaught=[]
      for i in 1..PBSpecies.maxValue
        @shadowcaught[i]=false
      end
      @badges=[]
      for i in 0...8
        @badges[i]=false
      end
    end
    @money=INITIALMONEY
    @party=[]
    @lastSave=""
    @saveNumber = 0
    @backupNames = []
    @noOnlineBattle = false
    @storedOnlineParty=[]   
    @onlineMusic="Battle- Trainer.mp3"
    @onlineAllowNickNames = true
  end
end