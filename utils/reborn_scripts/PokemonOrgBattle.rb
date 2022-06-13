#===============================================================================
# General purpose utilities
#===============================================================================
class Array
  def shuffle
    dup.shuffle!
  end unless method_defined? :shuffle

  def ^(other) # xor of two arrays
    return (self|other)-(self&other)
  end

  def shuffle!
    size.times do |i|
      r = Kernel.rand(size)
      self[i], self[r] = self[r], self[i]
    end
    self
  end unless method_defined? :shuffle!
end



module Enumerable
  def transform
    ret=[]
    self.each(){|item| ret.push(yield(item)) }
    return ret
  end
end



#===============================================================================
# Pokémon Organized Battle
#===============================================================================
def pbHasEligible?(*arg)
  return pbBattleChallenge.rules.ruleset.hasValidTeam?($Trainer.party)
end



class PBPokemon
  attr_accessor :species
  attr_accessor :item
  attr_accessor :nature
  attr_accessor :move1
  attr_accessor :move2
  attr_accessor :move3
  attr_accessor :move4
  attr_accessor :ev
  attr_accessor :form
  attr_accessor :ability

  def initialize(species,item,nature,move1,move2,move3,move4,ev,form,ability)
    @species=species
    @item=item ? item : 0
    @nature=nature
    @move1=move1 ? move1 : 0
    @move2=move2 ? move2 : 0
    @move3=move3 ? move3 : 0
    @move4=move4 ? move4 : 0
    @ev=ev 
    @form=form
    @ability=ability
  end

  def self.fromInspected(str)
    insp=str.gsub(/^\s+/,"").gsub(/\s+$/,"")
    pieces=insp.split(/\s*;\s*/)
    species=1
    if (PBSpecies.const_defined?(pieces[0]) rescue false)
      species=PBSpecies.const_get(pieces[0])
    end
    item=0
    if (PBItems.const_defined?(pieces[1]) rescue false)
      item=PBItems.const_get(pieces[1])
    end
    nature=PBNatures.const_get(pieces[2])
    ev=pieces[3].split(/\s*,\s*/)
    evvalue=0
    for i in 0...6
      next if !ev[i]||ev[i]==""
      evupcase=ev[i].upcase
      evvalue|=0x01 if evupcase=="HP"
      evvalue|=0x02 if evupcase=="ATK"
      evvalue|=0x04 if evupcase=="DEF"
      evvalue|=0x08 if evupcase=="SPD"
      evvalue|=0x10 if evupcase=="SA"
      evvalue|=0x20 if evupcase=="SD"
    end
    moves=pieces[4].split(/\s*,\s*/)
    moveid=[]
    for i in 0...4
      if (PBMoves.const_defined?(moves[i]) rescue false)
        moveid.push(PBMoves.const_get(moves[i]))
      end
    end
    moveid=[1] if moveid.length==0
    form=pieces[5].to_i
    ability=pieces[6].to_i
    return self.new(species,item,nature,
       moveid[0],(moveid[1]||0),(moveid[2]||0),(moveid[3]||0),evvalue,form,ability)
  end

  def self.fromPokemon(pokemon)
    evvalue=0
    evvalue|=0x01 if pokemon.ev[0]>60
    evvalue|=0x02 if pokemon.ev[1]>60
    evvalue|=0x04 if pokemon.ev[2]>60
    evvalue|=0x08 if pokemon.ev[3]>60
    evvalue|=0x10 if pokemon.ev[4]>60
    evvalue|=0x20 if pokemon.ev[5]>60
    return self.new(pokemon.species,pokemon.item,pokemon.nature,
       pokemon.moves[0].id,pokemon.moves[1].id,pokemon.moves[2].id,
       pokemon.moves[3].id,evvalue,form,ability)
  end

  def inspect
    c1=getConstantName(PBSpecies,@species)
    c2=(@item==0) ? "" : getConstantName(PBItems,@item)
    c3=getConstantName(PBNatures,@nature)
    evlist=""
    for i in 0...@ev
      if ((@ev&(1<<i))!=0)
        evlist+="," if evlist.length>0
        evlist+=["HP","ATK","DEF","SPD","SA","SD"][i]
      end
    end
    c4=(@move1==0) ? "" : getConstantName(PBMoves,@move1)
    c5=(@move2==0) ? "" : getConstantName(PBMoves,@move2)
    c6=(@move3==0) ? "" : getConstantName(PBMoves,@move3)
    c7=(@move4==0) ? "" : getConstantName(PBMoves,@move4)
    c8=@form
    #c9=getConstantName(PBAbilities,@ability)
    return "#{c1};#{c2};#{c3};#{evlist};#{c4},#{c5},#{c6},#{c7},#{c8}"
  end

  def convertMove(move)
    if (move == PBMoves::RETURN) && hasConst?(PBMoves,:FRUSTRATION)
      move=PBMoves::FRUSTRATION
    end
    return move
  end

  def createPokemon(level,iv,trainer)
    pokemon=PokeBattle_Pokemon.new(@species,level,trainer,false)
    pokemon.setItem(@item)
    pokemon.personalID=rand(65536)
    pokemon.personalID|=rand(65536)<<8
    pokemon.personalID-=pokemon.personalID%25
    pokemon.personalID+=nature
    pokemon.personalID&=0xFFFFFFFF
    pokemon.happiness=0
    pokemon.moves[0]=PBMove.new(self.convertMove(@move1))
    pokemon.moves[1]=PBMove.new(self.convertMove(@move2))
    pokemon.moves[2]=PBMove.new(self.convertMove(@move3))
    pokemon.moves[3]=PBMove.new(self.convertMove(@move4))
    pokemon.form=@form #I hate necrozma and don't want to deal with it anymore in a clean way so this is what you get
    pokemon.moves[0]=PBMove.new(self.convertMove(@move1))
    pokemon.moves[1]=PBMove.new(self.convertMove(@move2))
    pokemon.moves[2]=PBMove.new(self.convertMove(@move3))
    pokemon.moves[3]=PBMove.new(self.convertMove(@move4))
    evcount=0
    for i in 0...6
      evcount+=1 if ((@ev&(1<<i))!=0)
    end
    evperstat=(evcount==0) ? 0 : 510/evcount
    for i in 0...6
      pokemon.iv[i]=iv
      pokemon.ev[i]=((@ev&(1<<i))!=0) ? evperstat : 0
    end
    pokemon.abilityflag=@ability
    pokemon.calcStats
    return pokemon
  end
end

def pbGetBTTrainers(challengeID)
  trlists=(load_data("Data/trainerlists.dat") rescue [])
  for i in 0...trlists.length
    tr=trlists[i]
    if !tr[5] && tr[2].include?(challengeID)
      return tr[0]
    end
  end
  for i in 0...trlists.length
    tr=trlists[i]
    if tr[5] # is default list
      return tr[0]
    end
  end
  return []
end

def pbGetBTPokemon(challengeID)
  trlists=(load_data("Data/trainerlists.dat") rescue [])
  for tr in trlists
    if !tr[5] && tr[2].include?(challengeID)
      return tr[1]
    end
  end
  for tr in trlists
    if tr[5] # is default list
      return tr[1]
    end
  end
  return []
end

class Game_Map
  attr_accessor :map_id
end

class Game_Player
  attr_accessor :direction

  def moveto2(x, y)
    @x = x
    @y = y
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
end



class BattleChallengeType
  attr_accessor :currentWins
  attr_accessor :previousWins
  attr_accessor :maxWins
  attr_accessor :currentSwaps
  attr_accessor :previousSwaps
  attr_accessor :maxSwaps
  attr_reader :doublebattle
  attr_reader :numPokemon
  attr_reader :battletype
  attr_reader :mode

  def initialize
    @previousWins=0
    @maxWins=0
    @currentWins=0
    @currentSwaps=0
    @previousSwaps=0
    @maxSwaps=0
  end

  def saveWins(challenge)
    if challenge.decision!=0 # if won or lost
      if challenge.decision==1 # if won
        @currentWins=challenge.wins
        @currentSwaps=challenge.swaps
      else
        @currentWins=0
        @currentSwaps=0
      end
      @maxWins=[@maxWins,challenge.wins].max
      @previousWins=challenge.wins
      @maxSwaps=[@maxSwaps,challenge.swaps].max
      @previousSwaps=challenge.swaps
    else # if undecided
      @currentWins=0
      @currentSwaps=0
    end
  end
end



class BattleChallengeData
  attr_reader :resting
  attr_reader :wins
  attr_reader :swaps
  attr_reader :inProgress
  attr_reader :battleNumber
  attr_reader :numRounds
  attr_accessor :decision
  attr_reader :party
  attr_reader :extraData
  attr_reader :stylechallenge               #added

  def setExtraData(value)
    @extraData=value
  end

  def pbAddWin
    if @inProgress
      @battleNumber+=1
      @wins+=1
    end
  end

  def pbAddSwap
    if @inProgress
      @swaps+=1
    end
  end

  def pbMatchOver?
    return true if !@inProgress
    return true if @decision!=0
    return (@battleNumber>@numRounds)
  end

  def initialize
    reset
  end

  def nextTrainer
    return @trainers[@battleNumber-1]
  end

  def pbGoToStart
    if $scene.is_a?(Scene_Map)
      $game_temp.player_transferring = true
      $game_temp.player_new_map_id = @start[0]
      $game_temp.player_new_x = @start[1]
      $game_temp.player_new_y = @start[2]
      $game_temp.player_new_direction = 8
      $scene.transfer_player
    end
  end

  def setParty(value)
    if @inProgress
      $Trainer.party=value
      @party=value
    else
      @party=value
    end
  end

  def pbStart(t,numRounds)
    @inProgress=true
    @resting=false
    @decision=0
    @stylechallenge=0
    @swaps=t.currentSwaps
    @wins=t.currentWins
    @battleNumber=1
    @trainers=[]
    raise _INTL("Number of rounds is 0 or less.") if numRounds<=0
    @numRounds=numRounds
    btTrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    while @trainers.length<@numRounds
      newtrainer=pbBattleChallengeTrainer(@wins+@trainers.length,btTrainers)
      found=false
      for tr in @trainers
        found=true if tr==newtrainer
      end
      @trainers.push(newtrainer) if !found
    end
    @start=[$game_map.map_id,$game_player.x,$game_player.y]
    @oldParty=$Trainer.party
    $Trainer.party=@party if @party
    pbSave(true)
  end
  
  def pbfieldeffect(styles,doubles)                   #added this for different type of challenges
    $game_variables[:doublebattlefact] = doubles
    @stylechallenge = styles
  end
  
  # style 0 = no field , style 1 = random every battle, style 2 is same for whole match(7 battles)
  def whatfieldeffect                           #gives information depending on round and style
    if (@stylechallenge == 1) || ((@stylechallenge == 2) && (@battleNumber ==1))
      if (@stylechallenge == 1) || ((@stylechallenge == 2) && (@battleNumber ==1))
        $game_variables[:Forced_Field_Effect] = rand(36) + 1          
      end
      case $game_variables[:Forced_Field_Effect]
      when 0
        "no field no life"
      when 4, 23, 25
        "The battle will take place in the " + FIELDEFFECTS[$game_variables[:Forced_Field_Effect]][:FIELDNAME]
      when 22
        "The battle will take place Underwater"
      else
        "The battle will take place on the " + FIELDEFFECTS[$game_variables[:Forced_Field_Effect]][:FIELDNAME]
      end
    elsif (@stylechallenge == 0)
      #"placeholder no field no life"
      if $game_variables[:doublebattlefact]
        case @battleNumber
        when 1
          #tell name all pokemon
          #this is ugly and long, but easy. feel free to change if you know a better way
          chosenspoilers = (0..3).to_a.shuffle[0..3]
          "The Pokémon you'll be battling are " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[0]].species).to_s + ", " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[1]].species).to_s + ", " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[2]].species).to_s + " and " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[3]].species).to_s
        when 2
          #tell 2 of the pokemon name, at random
          chosenspoilers = (0..3).to_a.shuffle[0..1]
          "Two of the four Pokémon you'll be facing are " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[0]].species).to_s + " and " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[1]].species).to_s
        when 3
          #tell name lead pokemon plus one of it's moves
          "One of the leading Pokémon is " + PBSpecies.getName($game_variables[:opponentnew].party[0].species).to_s
       # when 4
       #   #tell one of leading's pokemon move
       #   "One of the leading Pokémon's moves is " + PBMoves.getName($game_variables[:opponentnew].party[rand(1)].moves[rand(3)].id).to_s
       # when 5
       #   #supposedly, the most common type, did item instead
       #   "One of the leading Pokémon will be holding the " + PBItems.getName($game_variables[:opponentnew].party[rand(1)].item).to_s
        when 4
          #supposedly, the most common type, did random type instead
          chosenspoilers = (0..3).to_a.shuffle[0..3]
          "One of the Pokémon is a " + PBTypes.getName($game_variables[:opponentnew].party[0].type1).to_s + " type"
        when 5
          #supposedly, the most common type, did nothing instead
          "There is no information on your last opponent"
        end
      else
        case @battleNumber
        when 1
          #tell name all pokemon
          #this is ugly and long, but easy. feel free to change if you know a better way
          chosenspoilers = (0..2).to_a.shuffle[0..2]
          "The pokemon you'll be battling are " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[0]].species).to_s + ", " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[1]].species).to_s + " and " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[2]].species).to_s
        when 2  
          #tell 2 of the pokemon name, at random
          chosenspoilers = (0..2).to_a.shuffle[0..1]
          "Two of the three Pokémon you'll be facing are " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[0]].species).to_s + " and " + PBSpecies.getName($game_variables[:opponentnew].party[chosenspoilers[1]].species).to_s
        when 3
          #tell name lead Pokémon plus one of it's moves
          "The leading Pokémon is " + PBSpecies.getName($game_variables[:opponentnew].party[0].species).to_s
      #  when 4
      #    #tell one of leading's Pokémon move, not sure if Pokémons or Pokémon's is correct grammatical form
      #    "One of the leading Pokémons move is " + PBMoves.getName($game_variables[:opponentnew].party[0].moves[rand(3)].id).to_s
      #  when 5 
      #    #supposedly, the most common type, did item instead
      #    "The leading Pokémon will be holding the " + PBItems.getName($game_variables[:opponentnew].party[0].item).to_s
        when 4
          #supposedly, the most common type, did random type instead
          chosenspoilers = (0..2).to_a.shuffle[0..2]
          "One of the Pokémon is a " + PBTypes.getName($game_variables[:opponentnew].party[0].type1).to_s + " type"
        when 5
          #supposedly, the most common type, did nothing instead
          "There is no information on your last opponent"
        end
      end
    else
      "There is no information on your next opponent"
    end
  end

  def pbCancel
    $Trainer.party=@oldParty if @oldParty
    reset
  end

  def pbEnd
    $Trainer.party=@oldParty
    $game_variables[:Forced_Field_Effect] = 0              # resetting variables
    $game_variables[:oldopponent] = nil
    $rentalnew = nil
    return if !@inProgress
    save=(@decision!=0)
    reset
    $game_map.need_refresh=true
    if save
      pbSave(true)
    end               
  end

  def pbGoOn
    return if !@inProgress
    @resting=false
    pbSaveInProgress                            #dunno yet if I want the game to save everytime you win
  end

  def pbRest
    return if !@inProgress
    @resting=true
    pbSaveInProgress
  end

  private

  def reset
    @inProgress=false
    @resting=false
    @start=nil
    @decision=0
    @wins=0
    @swaps=0
    @battleNumber=0
    @trainers=[]
    @oldParty=nil
    @party=nil
    @extraData=nil
    @stylechallenge=0
  end

  def pbSaveInProgress
    oldmapid=$game_map.map_id
    oldx=$game_player.x
    oldy=$game_player.y
    olddirection=$game_player.direction
    $game_map.map_id=@start[0]
    $game_player.moveto2(@start[1],@start[2])
    $game_player.direction=8 # facing up
    pbSave(true)                                #dunno yet if I want the game to save everytime you win
    $game_map.map_id=oldmapid
    $game_player.moveto2(oldx,oldy)
    $game_player.direction=olddirection
  end
end



class BattleChallenge
  attr_reader :currentChallenge
  BattleTower   = 0
  BattlePalace  = 1
  BattleArena   = 2
  BattleFactory = 3

  def initialize
    @bc=BattleChallengeData.new
    @currentChallenge=-1
    @types={}
  end

  def rules
    if !@rules
      @rules=modeToRules(self.data.doublebattle,
      self.data.numPokémon,
      self.data.battletype,self.data.mode)
    end
    return @rules  
  end

  def modeToRules(doublebattle,numPokemon,battletype,mode)
    rules=PokemonChallengeRules.new
    if battletype==BattlePalace
      rules.setBattleType(BattlePalace.new)
    elsif battletype==BattleArena
      rules.setBattleType(BattleArena.new)
      doublebattle=false
    else
      rules.setBattleType(BattleTower.new)
    end
    if mode==1 # Open Level
      rules.setRuleset(StandardRules(numPokemon,PBExperience::MAXLEVEL))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(30))
    elsif mode==2 # Battle Tent
      rules.setRuleset(StandardRules(numPokemon,PBExperience::MAXLEVEL))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(60))
    else
      rules.setRuleset(StandardRules(numPokemon,50))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(50)) 
    end
    if doublebattle
      rules.addBattleRule(DoubleBattle.new)
    else
      rules.addBattleRule(SingleBattle.new)
    end
    return rules
  end

  def set(id,numrounds,rules)
    @rules=rules
    @id=id
    @numRounds=numrounds
    pbWriteCup(id,rules)
  end

  def start(*args)
    t=ensureType(@id)
    @currentChallenge=@id # must appear before pbStart
    @bc.pbStart(t,@numRounds)                       
  end

  def register(id,doublebattle,numrounds,numPokemon,battletype,mode=1) 
    t=ensureType(id)
    if battletype==BattleFactory
      @bc.setExtraData(BattleFactoryData.new(@bc))
      numPokemon=3
      battletype=BattleTower
    end
    t.numRounds=numrounds                                   
    @rules=modeToRules(doublebattle,numPokemon,battletype,mode)
  end

  def pbInChallenge?
    return pbInProgress?
  end

  def data
    return nil if !pbInProgress? || @currentChallenge<0
    return ensureType(@currentChallenge).clone
  end

  def getCurrentWins(challenge)
    return ensureType(challenge).currentWins
  end
#print pbBattleChallenge.getCurrentWins(pbBattleChallenge)
  def getPreviousWins(challenge)
    return ensureType(challenge).previousWins
  end

  def getMaxWins(challenge)
    return ensureType(challenge).maxWins
  end

  def getCurrentSwaps(challenge)
    return ensureType(challenge).currentSwaps
  end

  def getPreviousSwaps(challenge)
    return ensureType(challenge).previousSwaps
  end

  def getMaxSwaps(challenge)
    return ensureType(challenge).maxSwaps
  end

  def pbStart(challenge)
  end

  def pbEnd
    if @currentChallenge!=-1
      ensureType(@currentChallenge).saveWins(@bc)
      @currentChallenge=-1
    end
    @bc.pbEnd
  end

  def pbBattle
    #make opponent based on what challange the player chose
    if @currentChallenge=="factorysingleopen" || @currentChallenge=="factorydoubleopen"
      opponent = $game_variables[:opponentnew]
    else
      opponent=pbGenerateBattleTrainer(self.nextTrainer,self.rules)
    end
    bttrainers=pbGetBTTrainers(@id)
    trainerdata=bttrainers[self.nextTrainer]
    ret=pbOrganizedBattleEx(opponent,self.rules,
       pbGetMessageFromHash(MessageTypes::EndSpeechLose,trainerdata[4]),
       pbGetMessageFromHash(MessageTypes::EndSpeechWin,trainerdata[3]))
    return ret
  end

  def pbInProgress?
    return @bc.inProgress
  end

  def pbResting?
    return @bc.resting
  end
  
  def pbIsDoublesResting?                 #needed because otherwise wrong guy would walk when restarting
    return  $game_variables[:doublebattlefact]
  end

  def setDecision(value)
    @bc.decision=value
  end

  def setParty(value)
    @bc.setParty(value)
  end

  def extra
    @bc.setExtraData(BattleFactoryData.new(@bc))
  end
  def decision; @bc.decision; end
  def wins; @bc.wins; end
  def swaps; @bc.swaps; end
  def battleNumber; @bc.battleNumber; end
  def nextTrainer; @bc.nextTrainer; end
  def stylechallenge; @bc.stylechallenge; end             
  def pbGoOn; @bc.pbGoOn; end
  def pbAddWin; @bc.pbAddWin; end
  def pbCancel; @bc.pbCancel; end
  def pbRest; @bc.pbRest; end
  def pbMatchOver?; @bc.pbMatchOver?; end
  def pbGoToStart; @bc.pbGoToStart; end
  def pbfieldeffect(styles,doubles); @bc.pbfieldeffect(styles,doubles); end           
  def whatfieldeffect; @bc.whatfieldeffect; end                
  
    
  private

  def ensureType(id)
    if @types.is_a?(Array)
      oldtypes=@types
      @types={}
      for i in 0...oldtypes.length
        if oldtypes[i]
          @types[i]=oldtypes[i]
        end
      end
    end
    if !@types[id]
      @types[id]=BattleChallengeType.new
    end
    return @types[id]
  end
end



def pbRecordLastBattle
  $PokemonGlobal.lastbattle=$PokemonTemp.lastbattle
  $PokemonTemp.lastbattle=nil
end

def pbPlayBattle(battledata)
  if battledata
    scene=pbNewBattleScene
    scene.abortable=true
    lastbattle=Marshal.restore(StringInput.new(battledata))
    case lastbattle[0]
    when BattleChallenge::BattleTower
      battleplayer=PokeBattle_BattlePlayer.new(scene,lastbattle)
    when BattleChallenge::BattlePalace
      battleplayer=PokeBattle_BattlePalacePlayer.new(scene,lastbattle)
    when BattleChallenge::BattleArena
      battleplayer=PokeBattle_BattleArenaPlayer.new(scene,lastbattle)
    end
    bgm=BattlePlayerHelper.pbGetBattleBGM(lastbattle)
    pbBattleAnimation(bgm) { 
       pbSceneStandby {
          decision=battleplayer.pbStartBattle
       }
    }
  end
end

def pbDebugPlayBattle
  params=ChooseNumberParams.new
  params.setRange(0,500)
  params.setInitialValue(0)
  params.setCancelValue(-1)
  num=Kernel.pbMessageChooseNumber(_INTL("Choose a battle."),params)
  if num>=0
    pbPlayBattleFromFile(sprintf("Battles/Battle%03d.dat",num))
  end
end

def pbPlayLastBattle
  pbPlayBattle($PokemonGlobal.lastbattle)
end

def pbPlayBattleFromFile(filename)
  pbRgssOpen(filename,"rb"){|f|
     pbPlayBattle(f.read)
  }
end



class Game_Event
  def pbInChallenge?
    return pbBattleChallenge.pbInChallenge?
  end
end

def pbBattleChallenge
  if !$PokemonGlobal.challenge
    $PokemonGlobal.challenge=BattleChallenge.new
  end
  return $PokemonGlobal.challenge
end

def pbBattleChallengeTrainer(numwins,bttrainers)
  #don't prefer one trainer over another
  return rand(bttrainers.length)
end

def pbBattleChallengeGraphic(event)
  nextTrainer=pbBattleChallenge.nextTrainer
  bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  battlesprite = bttrainers[nextTrainer][0]
  print "hey, this trainer is missing a graphic. please report: ", nextTrainer," - " ,bttrainers[nextTrainer], " ty <3" if battlesprite.nil?
  trchararray = [0, 0, 122, 19, 4, 56, 6, 7, 34, 0, 121, 0, 0, 0, 0, 0, 16, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 0, 110, 0, 0, 2, 0, 125, 0, 37, 119, 0, 126, 123, 124, 0, 0, 0, 131, 130, 0, 203, 0, 0, 0, 0, 0, 120, 44, 0, 0, 0, 0, 48, 181, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 140, 0, 141, 0, 143, 0, 0, 0, 0, 8, 39, 9, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 148, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 144, 0, 0, 0, 204, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "166b", "167b", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 185, 186, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  filenum = trchararray[battlesprite]
  filenum = 0 if filenum == nil
  filenum = filenum.to_s
  if filenum.length == 1
    filename = "trchar00" + filenum
  elsif filenum.length == 2
    filename = "trchar0" + filenum
  elsif filenum.length > 2
    filename = "trchar" + filenum
  end
  #filename=pbTrainerCharNameFile((bttrainers[nextTrainer][0] rescue 0))
  if (pbBattleChallenge.battleNumber == 5) && pbBattleChallenge.currentChallenge == 'towersingle' # the last round
    towerboss = $game_variables[610]
    case towerboss
      when "Bee" then filename = "trchar177"
      when "Biggles" then filename = "pkmn_garbodor"
      when "Santiago" then filename = "trchar143"
      when "Danielle" then filename = "trchar169"
      when "Sandy" then filename = "trchar158"
      when "Aster" then filename = "trchar135"
      when "Seacrest" then filename = "trchar168"
      when "Meganium" then filename = "pkmn_meganium"
      when "CL:4R1-C3" then filename = "pkmn_breloom2"
      when "Corin-Rouge" then filename = "trchar127"
      when "Indra" then filename = "trchar172"
      when "Archer" then filename = "trchar111"
      when "Maxwell" then filename = "trchar112"
      when "Alistasia" then filename = "trchar117"
      when "Craudburry" then filename = "trchar171"
      when "Nyu" then filename = "trchar170"
      when "Smeargletail" then filename = "pkmn_smeargle2"
      when "Zero" then filename = "trchar070b"
      when "Cass" then filename = "trchar165"
      when "Eustace" then filename = "NPC 02"
      when "McKrezzy" then filename = "trchar173"
      when "Marcello" then filename = "trchar147"
      when "Kanaya" then filename = "trchar175"
      when "Bill" then filename = "trchar179"
      when "Direction" then filename = "NPC 28"
      when "Simon" then filename = "trchar156"
      when "Randall" then filename = "trchar146"
      when "Europa" then filename = "trchar178"
      when "Maelstrom" then filename = "trchar180"
      when "Murmina" then filename = "trchar176"
      when "John" then filename = "trchar138"
      when "Eastman" then filename = "trchar174"
      when "Breslin" then filename = "trchar187"
      when "Mewtwo" then filename = "pkmn_mewtwo2"
      when "Crim" then filename = "trchar206"
    end
  end
  begin
    bitmap=AnimatedBitmap.new("Graphics/Characters/"+filename)
    bitmap.dispose
    event.character_name=filename
  rescue
    event.character_name="Red"
  end
end

def pbBattleChallengeBeginSpeech
  if !pbBattleChallenge.pbInProgress?
    return "..."
  elsif (pbBattleChallenge.battleNumber == 5) && pbBattleChallenge.currentChallenge == 'towersingle' # the last round
      towerboss = $game_variables[610]
      case towerboss
        when "Bee" then return "Hey! I thought I'd come down here, see if there was anything new to see. It's pretty neat!"
        when "Biggles" then  return "IF AH WIN, CAN HAVE HUG?"
        when "Santiago" then  return "LET'S HAVE A FUCKIN' BAD-ASS BATTLE!"
        when "Danielle" then  return "Oh hey, if it isn't my favorite gofer!"
        when "Sandy" then  return "I haven't had a challenger for a while, this oughtta be fun!"
        when "Aster" then  return "Been a while, huh, boss? Let's make it a great battle, for old times' sake. And for her."
        when "Seacrest" then  return "It's so much nicer to battle now that the city's so beautiful again."
        when "Meganium" then  return "Madame Meganium stares at you levelly." 
        when "CL:4R1-C3" then  return "BREEEEEEEEE-"
        when "Corin-Rouge" then  return "Finally, our destined reunion!"
        when "Indra" then  return "Are YOU ready to take on Agate Circus' best clown?"
        when "Archer" then  return "Aqua Gang may be gone, but I'm going to make a splash here!"
        when "Maxwell" then  return "I may have disbanded the Magma Gang, but you bet you're gonna see I'm still hot stuff!"
        when "Alistasia" then  return "Let's put on a great show, maybe drum up some publicity for the Circus!"
        when "Craudburry" then  return "I'll send you packing, you MISERABLE SLIME!"
        when "Nyu" then  return "Oh, hiya~ Here to show me your Pikachu?"
        when "Smeargletail" then  return "Smeargle holds up a sign that says 'human not win this battle'."
        when "Zero" then  return "...Hey. Well, let's get to it, shall we?"
        when "Cass" then  return "hi. i'm cass. let's FITE."
        when "Eustace" then  return "Hmph. I wish they would stop sending incompetents out to face me."
        when "McKrezzy" then  return "All right, let's jazz this place up."
        when "Marcello" then  return "Hello! Fancy a lemonade?"
        when "Kanaya" then  return "All right. The faster we get this fight done, the faster I can get back to work."
        when "Bill" then  return "Oh, h'llo. Fancy a friendly match?"
        when "Direction" then  return "I don't need my crystal ball to see your loss here."
        when "Simon" then  return "...Hi. Good to see you again."
        when "Randall" then  return "Heya, partner! Well-- 'course we're not partners right now, but-- Let's just have fun, 'kay?"
        when "Europa" then  return "Now how's about I show you how we battle over in Train Town?"
        when "Maelstrom" then  return "Get ready for a stormy battle!"
        when "Murmina" then  return "Hey. We've got a clean slate now; let's just have a good battle."
        when "John" then  return "We are no longer enemies, but do not make the mistake of underestimating me."
        when "Eastman" then  return "Nice to get a break from official duty!"
        when "Breslin" then  return "'Ello. Told you I might stop by!"
        when "Mewtwo" then  return "Tu..."
        when "Crim" then  return "Oh hey! I'm Crim! I'm so excited to be here, let's have some fun!"
      end
  else
    bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    tr=bttrainers[pbBattleChallenge.nextTrainer]
    return tr ? pbGetMessageFromHash(MessageTypes::BeginSpeech,tr[2]) : "..."
  end
end

def pbEntryScreen(*arg)
  retval = false
  pbFadeOutIn(99999){
    scene = PokemonScreen_Scene.new
    screen = PokemonScreen.new(scene,$Trainer.party)
    ret = screen.pbPokemonMultipleEntryScreenEx(pbBattleChallenge.rules.ruleset)
    # Set party
    pbBattleChallenge.setParty(ret) if ret
    # Continue (return true) if Pokémon were chosen
    retval = (ret!=nil && ret.length>0)
  }
  return retval
end

def pbBattleChallengeBattle
  return pbBattleChallenge.pbBattle
end



class BattleFactoryData
  def initialize(bcdata)
    @bcdata=bcdata
  end

  def pbPrepareRentals
    @trainerid=@bcdata.nextTrainer                                           
    $game_variables[:rentalsnew]=pbBattleFactoryPokemon(@bcdata.wins,@bcdata.swaps,[])       
    bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)          
    trainerdata=bttrainers[@trainerid]
    $game_variables[:opponentnew] = pbGenerateBattleTrainer(@trainerid,pbBattleFactoryRules($game_variables[:doublebattlefact],true))
  end

  def pbChooseRentals
    pbFadeOutIn(99999){
      scene = BattleSwapScene.new
      screen = BattleSwapScreen.new(scene)
      $game_variables[:rentalsnew] = screen.pbStartRent($game_variables[:rentalsnew])
      @bcdata.pbAddSwap
      pbBattleChallenge.setParty($game_variables[:rentalsnew])
    }
  end

  def pbBattle(challenge)
    bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata=bttrainers[@trainerid]
    return pbOrganizedBattleEx(opponent,challenge.rules,                            
       pbGetMessageFromHash(MessageTypes::EndSpeechLose,trainerdata[4]),
       pbGetMessageFromHash(MessageTypes::EndSpeechWin,trainerdata[3]))
  end

  def pbPrepareSwaps    #opponent hat to be generated here, because info of opposing pokemon is given after this
    $game_variables[:oldopponent]=$game_variables[:opponentnew].party           
    @trainerid=@bcdata.nextTrainer
    bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata=bttrainers[@trainerid]
    $game_variables[:opponentnew] = pbGenerateBattleTrainer(@trainerid,pbBattleFactoryRules($game_variables[:doublebattlefact],true))
  end

  def pbChooseSwaps
    swapMade = true
    pbFadeOutIn(99999){
      scene = BattleSwapScene.new
      screen = BattleSwapScreen.new(scene)
      swapMade = screen.pbStartSwap($game_variables[:rentalsnew],$game_variables[:oldopponent])
      if swapMade
        @bcdata.pbAddSwap
      end
      @bcdata.setParty($game_variables[:rentalsnew])
    }
    return swapMade
  end
end



def pbBattleFactoryPokemon(numwins,numswaps,rentals)
  table=nil
  btpokemon=pbGetBTPokemon(pbBattleChallenge.currentChallenge)
  bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  ivtable=[
     0,6,3,6,
     7,13,6,9,
     14,20,9,12,
     21,27,12,15,
     28,34,15,21,
     35,41,21,31,
     42,-1,31,31
  ]
  groups=[
     1,14,6,0,
     15,21,5,1,
     22,28,4,2,
     29,35,3,3,
     36,42,2,4,
     43,-1,1,5
  ]
    table=[
       0,6,372,467,
       7,13,468,563,
       14,20,564,659,
       21,27,660,755,
       28,34,372,881,
       35,41,372,881,
       42,48,372,881,
       49,-1,372,881
    ]

  ivgroups=[6,0]
  for i in 0...ivtable.length/4
    if ivtable[i*4]<=numwins
      if (ivtable[i*4+1]<0 || ivtable[i*4+1]>=numwins)
        ivs=[ivtable[i*4+2],ivtable[i*4+3]]
      end
    end
  end
  for i in 0...groups.length/4
    if groups[i*4]<=numswaps
      if (groups[i*4+1]<0 || groups[i*4+1]>=numswaps)
        ivgroups=[groups[i*4+2],groups[i*4+3]]
      end
    end
  end
  party=[]
  while party.length < 6
    selected = btpokemon.sample(6)
    party = Array.new(6) {|i| selected[i].createPokemon(100,ivgroups[1],nil)}
    party.uniq! {|mon| mon.species }
    party.uniq! {|mon| mon.type1 }
  end
=begin
  begin
    party.clear
    resorted = (0...pokemonnumbers.length).to_a.shuffle[0..5] #uses different technique. instead of randomly generating numers
    while party.length<6                                      #it creates an array with all the numbers in it, then shuffles it.
      for n in (0...resorted.length)                          #Then the first 6 values are sliced. This all to avoid duplicates of same number
        rnd=pokemonnumbers[resorted[n]]                       #later found out other technique has method for duplicates anyway
        #### Optional code for if we rank species sets by difficulty
        #### Add a negative number at the start of bttrainers PokemonNos section for a given trainer to force them to use that index of the species set (or highest if there aren't that many). 
        #### i.e. if PokemonNos started with -1, the trainer would always use the first (likely weakest) set of each species, and if it was -100 they'd always go for the strongest. No negative will randomly decide a set
        #### All stuff relating to this feature will be double instead of single commented
        ## difficultySetting = false
        ##if pokemonnumbers[0]<0
        ##  difficultySetting = abs(pokemonnumbers[0])
        ##end
        ##loop do
        ##  break if rnd>0
        ##  rnd=pokemonnumbers[rand(pokemonnumbers.length)]
        ##end
        ### New Code for changing bttrainers to be based on species rather than id in btpokemon##
        monlist = []
        for mon in btpokemon
          if mon.species==rnd
            monlist.push(mon)
          else
            if monlist.length>0
              break
            end
          end
        end
        ##if !difficultySetting
        rndpoke = monlist[rand(monlist.length)]
        ##else
        ##  diffindex = difficultySetting - 1
        ##  if monlist.length < difficultySetting
        ##    rndpoke = monlist[-1]
        ##  else
        ##    rndpoke = monlist[diffindex]
        ##  end
        ##end
        ###Commented out code should replace next line
        #rndpoke=btpokemon[rnd]
        indvalue=(party.length<ivgroups[0]) ? ivs[0] : ivs[1]
        pkmn=rndpoke.createPokemon(100,indvalue,nil)
        party.push(pkmn)
      end
    end
  end until party.length ==6
=end
  return party
end

def pbGenerateBattleTowerBoss
  if pbBattleChallenge.currentChallenge == 'towersingle'  # only for battle tower singles right now
    # SYNTAX IS [ID, NAME, PARTY INDEX, FIELD]
    bosslist = [[PBTrainers::BEE,"Bee",1000,10],[PBTrainers::LAHVER,"Biggles",1000,19],       [PBTrainers::CUEBALL,"Santiago",1000,34],
  [PBTrainers::SEER,"Danielle",1000,30],      [PBTrainers::SANDY,"Sandy",1000,8],             [PBTrainers::ASTER,"Aster",1000,12],
  [PBTrainers::SEACREST,"Seacrest",1000,22],  [PBTrainers::MEGANIUM,"Meganium",1000,36],
  [PBTrainers::BRELOOM,"CL:4R1-C3",1000,17],  [PBTrainers::CORINROUGE,"Corin-Rouge",1000,31], [PBTrainers::INDRA,"Indra",1000,30],
  [PBTrainers::INDRA,"Indra",1001,9],         [PBTrainers::INDRA,"Indra",1002,9],             [PBTrainers::Archer,"Archer",1000,8],
  [PBTrainers::Maxwell,"Maxwell",1000,2],     [PBTrainers::RINGMASTER,"Alistasia",1000,6],    [PBTrainers::HARRIDAN,"Craudburry",1000,29],
  [PBTrainers::PIKANYU,"Nyu",1000,1],         [PBTrainers::SMEARGLE,"Smeargletail",1000,12],  [PBTrainers::ZEL3,"Zero",1000,35],
  [PBTrainers::ZEL3,"Zero",1000,35],          [PBTrainers::CASS,"Cass",1000,35],              [PBTrainers::CASS,"Cass",1001,29],
  [PBTrainers::MASTERMIND,"Eustace",1000,35], [PBTrainers::MCKREZZY,"McKrezzy",1000,23],      [PBTrainers::MARCELLO,"Marcello",1000,24],
  [PBTrainers::KANAYA,"Kanaya",1000,12],      [PBTrainers::BUFF,"Bill",1000,36],              [PBTrainers::MISSDIRECTION,"Direction",1000,24],
  [PBTrainers::MISSDIRECTION,"Direction",1001,37],[PBTrainers::SIMON,"Simon",1000,15],        [PBTrainers::RANDALL,"Randall",1000,rand(37)+1],
  [PBTrainers::EUROPA,"Europa",1000,11],      [PBTrainers::MAEL,"Maelstrom",1000,2],          [PBTrainers::MURMINA,"Murmina",1000,6],
  [PBTrainers::NWOrderly,"John",1000,34],     [PBTrainers::CHIEF,"Eastman",1000,34],          [PBTrainers::CRIM,"Crim",1000,31]]
    if $game_variables[616] > 18 #zeraora quest done
      bosslist.push([PBTrainers::POACHERB,"Breslin",1000,34])  
    end
    chosenboss = bosslist[rand(bosslist.length)]
    if $game_variables[726] == 1 # mewtwo quest started
      chosenboss = [PBTrainers::DEFNOT,"Mewtwo",1000,9]
    end
    tempboss = pbLoadTrainer(chosenboss[0],chosenboss[1],chosenboss[2])
    #return [boss,chosenboss[3]]
    #return $towerBoss
    boss = tempboss[0]
    for i in tempboss[2]
      boss.party.push(i)
    end
    $game_variables[575] = [boss,chosenboss[3]]
    $game_variables[610] = chosenboss[1]
  end
end

def pbGenerateBattleTrainer(trainerid,rule)
  if (pbBattleChallenge.battleNumber == 5) && pbBattleChallenge.currentChallenge == 'towersingle' # the last round
    #towerboss = pbGenerateBattleTowerBoss
    #towerboss = $towerBoss
    towerboss = $game_variables[575]
    if $game_switches[:Battle_Tower_FE_Enabled] == true
      $game_variables[:Forced_Field_Effect] = towerboss[1]
    end
    return towerboss[0]
  end
  
  bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  trainerdata=bttrainers[trainerid]
  opponent=PokeBattle_Trainer.new(
     pbGetMessageFromHash(MessageTypes::TrainerNames,trainerdata[1]),
     trainerdata[0])
  btpokemon=pbGetBTPokemon(pbBattleChallenge.currentChallenge)

  # Individual Values
  indvalues=0
  if (pbBattleChallenge.currentChallenge == "factorysingleopen") || (pbBattleChallenge.currentChallenge == "factorydoubleopen")
    #Iv's for Battle Factory
    indvalues= [3 + 3*pbBattleChallenge.battleNumber,31].min
  else
    indvalues= [5 * (pbBattleChallenge.wins / 7.0).floor,31].min
    #IV's for Battle Tower
  end

  # Trainerdata
  pokemonnumbers=trainerdata[5]
  if pokemonnumbers.length < rule.ruleset.suggestedNumber       
    for n in pokemonnumbers
      rndpoke=btpokemon[n]
      pkmn=rndpoke.createPokemon(rule.ruleset.suggestedLevel,indvalues,opponent) 
      opponent.party.push(pkmn)
    end
    return opponent
  end
  begin
    opponent.party.clear
    while opponent.party.length<rule.ruleset.suggestedNumber
      rnd=pokemonnumbers[rand(pokemonnumbers.length)]
      PBDebug.log(sprintf("trainerid = %s, rnd = %d",trainerid,rnd)) if $INTERNAL  #There's a trainer running amuck with an invalid pokemon number i think. It crashed my game twice but couln't reproduce it anyway. Problem shows it face at CreatePokemon a few lines down
      #### Optional code for if we rank species sets by difficulty
      #### Add a negative number at the start of bttrainers PokemonNos section for a given trainer to force them to use that index of the species set (or highest if there aren't that many). 
      #### i.e. if PokemonNos started with -1, the trainer would always use the first (likely weakest) set of each species, and if it was -100 they'd always go for the strongest. No negative will randomly decide a set
      #### All stuff relating to this feature will be double instead of single commented
      ## difficultySetting = false
      ##if pokemonnumbers[0]<0
      ##  difficultySetting = abs(pokemonnumbers[0])
      ##end
      ##loop do
      ##  break if rnd>0
      ##  rnd=pokemonnumbers[rand(pokemonnumbers.length)]
      ##end
      ### New Code for changing bttrainers to be based on species rather than id in btpokemon##
      monlist = []
      for mon in btpokemon
        if mon.species==rnd
          monlist.push(mon)
        else
          if monlist.length>0
            break
          end
        end
      end
      ##if !difficultySetting
      rndpoke = monlist[rand(monlist.length)]
      next if rndpoke==nil
      ##else
      ##  diffindex = difficultySetting - 1
      ##  if monlist.length < difficultySetting
      ##    rndpoke = monlist[-1]
      ##  else
      ##    rndpoke = monlist[diffindex]
      ##  end
      ##end
      ###Commented out code should replace next line
      #rndpoke=btpokemon[rnd]
      pkmn=rndpoke.createPokemon(
         rule.ruleset.suggestedLevel,indvalues,opponent)
      opponent.party.push(pkmn)
    end
  end until rule.ruleset.isValid?(opponent.party)
  return opponent
end

def pbOrganizedBattleEx(opponent,challengedata,endspeech,endspeechwin)
  if !challengedata
    challengedata=PokemonChallengeRules.new
  end
  scene=pbNewBattleScene
  for i in 0...$Trainer.party.length
    $Trainer.party[i].heal
  end
  olditems=$Trainer.party.transform{|p| p.item }
  olditems2=opponent.party.transform{|p| p.item }
  opponent.skill = PokeBattle_AI::BESTSKILL      #making sure every battle trainer is smort
  battle=challengedata.createBattle(scene,$Trainer,opponent)
  battle.internalbattle=false
  battle.endspeech=endspeech
  battle.endspeechwin=endspeechwin
  if (pbBattleChallenge.battleNumber == 5) && pbBattleChallenge.currentChallenge == 'towersingle' # the last round
    battle = pbMinibossDialogueOverwrite(battle)
  end
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    $PokemonTemp.lastbattle=nil
    return true
  end
  oldlevels=challengedata.adjustLevels($Trainer.party,opponent.party)
  pbPrepareBattle(battle)
  decision=0
  trainerbgm=pbGetTrainerBattleBGM(opponent)
  pbBattleAnimation(trainerbgm) { 
      pbSceneStandby {
         decision=battle.pbStartBattle
      }
  }
  challengedata.unadjustLevels($Trainer.party,opponent.party,oldlevels)
  for i in 0...$Trainer.party.length
    $Trainer.party[i].heal
    $Trainer.party[i].setItem(olditems[i])
  end
  for i in 0...opponent.party.length
    opponent.party[i].heal
    opponent.party[i].setItem(olditems2[i])
  end
  Input.update
  if decision==1||decision==2||decision==5
    $PokemonTemp.lastbattle=nil
  else
    $PokemonTemp.lastbattle=nil
  end
  return (decision==1)
end

def pbIsBanned?(pokemon)
  return StandardSpeciesRestriction.new.isValid?(pokemon)
end

def pbMinibossDialogueOverwrite(battle)
  towerboss = $game_variables[610]
  case towerboss
    when "Bee"
       battle.endspeech = "Eh, wasn't my best showing, but it was fun."
       battle.endspeechwin = "Huh... maybe this is the beginning of my new path?"
    when "Biggles"
      battle.endspeech = "NO HUG FOR BIGGLES..."
      battle.endspeechwin = "BIGGLES WIN! HUG NOW?"
    when "Santiago"
      battle.endspeech = "What the fuck? That's fucking bullshit, man!"
      battle.endspeechwin = "Did I fucking win? That's fucking awesome!"
    when "Danielle"
      battle.endspeech = "Of course you won, when you had the advantage. Next time try battling without being able to see, and then we'll see who's the better Trainer."
      battle.endspeechwin = "Wow! Beaten by a girl who can't see, hm? I bet that's going to give your ego a bruising. Well, good! Hee hee."
    when "Sandy"
      battle.endspeech = "All right, all right, you've put me back on solid ground now."
      battle.endspeechwin = "See what happens when you love the planet? It loves you back!"
    when "Aster"
      battle.endspeech = "Well fought. Thank you."
      battle.endspeechwin = "Maybe... I'm finally growing. Thank you."
    when "Seacrest"
      battle.endspeech = "Had a feeling this was how it'd go."
      battle.endspeechwin = "You've come a long way since we met, but this is the end of the line for today."
    when "Meganium"
      battle.endspeech = "Madame Meganium gives you a long, level look, and then gives a small nod of approval."
      battle.endspeechwin = "Madame Meganium tosses her head proudly."
    when "CL:4R1-C3"
      battle.endspeech = "-LOOOOOOOOM! Error! Error!"
      battle.endspeechwin = "-LOOM. Beep beep!"
    when "Corin-Rouge"
      battle.endspeech = "And once more, I face my defeat..."
      battle.endspeechwin = "The light of victory shines upon me..."
    when "Indra"
      battle.endspeech = "Aaaaaand we have a winner! The fabulous Champion!"
      battle.endspeechwin = "Aaaand once more the dashing clown Indra reigns victorious!"
    when "Archer"
      battle.endspeech = "Ah, well. It was entertaining enough."
      battle.endspeechwin = "What's the matter? Would you say you're a little washed up?"
    when "Maxwell"
      battle.endspeech = "Guess I didn't do so hot."
      battle.endspeechwin = "FOR GLORY, BABY!"
    when "Alistasia"
      battle.endspeech = "Pretty much what I figured, but it was fun!"
      battle.endspeechwin = "Hey, that was great! I wonder if anyone recorded it? Maybe we could use it as a promo video..."
    when "Craudburry"
      battle.endspeech = "How DARE YOU? You came here just to HUMILIATE a KIND OLD WOMAN! I'll sue you! I'LL SUE THIS WHOLE CLUB!"
      battle.endspeechwin = "See? SEE? I'VE STILL GOT IT!"
    when "Nyu"
      battle.endspeech = "No fair! I didn't get to play with your Pikachu!"
      battle.endspeechwin = "I guess my Pikachu were stronger. All Pikachu are good though."
    when "Smeargletail"
      battle.endspeech = "Smeargle holds out a notepad and hastily scribbles, 'guess human did win. good battle.'"
      battle.endspeechwin = "Smeargle holds out a notepad and flips a page to where he's written 'smeargle best trainer. human good battler too though."
    when "Zero"
      battle.endspeech = "Just like always."
      battle.endspeechwin = "...Huh. I won. How about that?"
    when "Cass"
      battle.endspeech = "is this done yet? good."
      battle.endspeechwin = "oh hey. that was kind of fun."
    when "Eustace"
      battle.endspeech = "Hmph. I suppose you weren't completely incompetent for a change."
      battle.endspeechwin = "Hmph. I've seen Magikarp with more skill at battling and more intellect."
    when "McKrezzy"
      battle.endspeech = "A smooth victory."
      battle.endspeechwin = "I guess you can't compete with a true master, in battle or in music."
    when "Marcello"
      battle.endspeech = "Well, that wasn't very nice!"
      battle.endspeechwin = "My Pokemon did great. Such good boys. And girls."
    when "Kanaya"
      battle.endspeech = "Well, back to work."
      battle.endspeechwin = "I won. Woohoo. Okay, back to work."
    when "Bill"
      battle.endspeech = "Didn't win, but that was a right good battle."
      battle.endspeechwin = "And that there's a lesson to ya."
    when "Direction"
      battle.endspeech = "B-but- How could I have been wrong?"
      battle.endspeechwin = "It's as I told you. My prophecies are never wrong."
    when "Simon"
      battle.endspeech = "Even with my defeat, it was pleasant to battle with you once more."
      battle.endspeechwin = "Man. No hard feelings, but I have to admit, it was nice to win against you for a change."
    when "Randall"
      battle.endspeech = "Eh. I always told ya I wasn't much of a battler."
      battle.endspeechwin = "I won? Really truly?"
    when "Europa"
      battle.endspeech = "Guess you didn't need to learn after all."
      battle.endspeechwin = "And that's how ya battle in Train Town!"
    when "Maelstrom"
      battle.endspeech = "Guess the winds of fate weren't blowing for me."
      battle.endspeechwin = "Sometimes one good move's all it takes to turn the tide."
    when "Murmina"
      battle.endspeech = "I did my best, okay? Good luck."
      battle.endspeechwin = "...That was a good battle. Thank you."
    when "John"
      battle.endspeech = "And yet it appears I was the one who underestimated you. My apologies."
      battle.endspeechwin = "Excellent... This is a step forward."
    when "Eastman"
      battle.endspeech = "Heh... you pulled off some arrestingly good moves there."
      battle.endspeechwin = "Nice. Now the boys owe me dinner!"
    when "Breslin"
      battle.endspeech = "I suppose I shouldn't have expected to win against the Champion on my first try."
      battle.endspeechwin = "Hm. Guess it was a good thing after all, coming here."
    when "Mewtwo"
      battle.endspeech = "..."
      battle.endspeechwin = "...!"
    when "Crim"
      battle.endspeech = "That was awesome! You're really something, you know that?"
      battle.endspeechwin = "I'll see you in the back alley!"
    end
  return battle
end
