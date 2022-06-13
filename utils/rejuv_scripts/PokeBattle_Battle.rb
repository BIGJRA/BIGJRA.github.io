# Results of battle:
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw
################################################################################
# Battle Peer.
################################################################################
class PokeBattle_NullBattlePeer
  def pbStorePokemon(player,pokemon)
    if player.party.length<6
      player.party[player.party.length]=pokemon
      return -1
    else
      return -1
    end
  end

  def pbOnEnteringBattle(battle,pokemon)
  end

  def pbGetStorageCreator()
    return nil
  end

  def pbCurrentBox()
    return -1
  end

  def pbBoxName(box)
    return ""
  end
end



class PokeBattle_BattlePeer
  def self.create
    return PokeBattle_NullBattlePeer.new()
  end
end



################################################################################
# Success State.
################################################################################
class PokeBattle_SuccessState
  attr_accessor :typemod
  attr_accessor :useState # 0 - not used, 1 - failed, 2 - succeeded
  attr_accessor :protected
  attr_accessor :skill # Used in Battle Arena

  def initialize
    clear
  end

  def clear
    @typemod=4
    @useState=0
    @protected=false
    @skill=0
  end

  def updateSkill
    if @useState==1 && !@protected
      @skill-=2
    elsif @useState==2
      if @typemod>4
        @skill+=2 # "Super effective"
      elsif @typemod>=1 && @typemod<4
        @skill-=1 # "Not very effective"
      elsif @typemod==0
        @skill-=2 # Ineffective
      else
        @skill+=1
      end
    end
    @typemod=4
    @useState=0
    @protected=false
  end
end



################################################################################
# Catching and storing Pokémon.
################################################################################
module PokeBattle_BattleCommon
  def pbStorePokemon(pokemon)
    if !(pokemon.isShadow? rescue false)
      if pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?",pokemon.name))
        species=PBSpecies.getName(pokemon.species)
        nickname=@scene.pbNameEntry(_INTL("{1}'s nickname?",species),pokemon)
        pokemon.name=nickname if nickname!=""
      end
    end
    oldcurbox=@peer.pbCurrentBox()
    storedbox=@peer.pbStorePokemon(self.pbPlayer,pokemon)
    creator=@peer.pbGetStorageCreator()
    return if storedbox<0
    curboxname=@peer.pbBoxName(oldcurbox)
    boxname=@peer.pbBoxName(storedbox)
    if storedbox!=oldcurbox
      if creator
        pbDisplayPaused(_INTL("Box \"{1}\" on {2}'s PC was full.",curboxname,creator))
      else
        pbDisplayPaused(_INTL("Box \"{1}\" on someone's PC was full.",curboxname))
      end
      pbDisplayPaused(_INTL("{1} was transferred to box \"{2}\".",pokemon.name,boxname))
    else
      if creator
        pbDisplayPaused(_INTL("{1} was transferred to {2}'s PC.",pokemon.name,creator))
      else
        pbDisplayPaused(_INTL("{1} was transferred to someone's PC.",pokemon.name))
      end
      pbDisplayPaused(_INTL("It was stored in box \"{1}\".",boxname))
    end
  end

  def pbBallFetch(pokeball)
    if !pbInSafari?
      for i in 0...4
        if self.battlers[i].ability==PBAbilities::BALLFETCH && !self.abilitynulled && self.battlers[i].item==0
          if $fefieldeffect == 28
            self.battlers[i].effects[PBEffects::BallFetch]=getID(PBItems,:SNOWBALL)
          else
            self.battlers[i].effects[PBEffects::BallFetch]=pokeball
          end
        end
      end
    end
  end
  
  def pbThrowPokeBall(idxPokemon,ball,rareness=nil,showplayer=false)
    itemname=PBItems.getName(ball)
    battler=nil
    if pbIsOpposing?(idxPokemon)
      battler=self.battlers[idxPokemon]
    else
      battler=self.battlers[idxPokemon].pbOppositeOpposing
    end
    aboveLimit = false
    if battler.hp > (battler.totalhp * 0.25)
      aboveLimit = true
    end
    if battler.isFainted?
      battler=battler.pbPartner
    end
    pbDisplayBrief(_INTL("{1} threw one {2}!",self.pbPlayer.name,itemname))
    $game_variables[536] += 1
    if battler.isFainted?
      pbDisplay(_INTL("But there was no target..."))
      pbBallFetch(ball)
      return
    end
    if @opponent && ((!pbIsSnagBall?(ball) || !battler.isShadow?) || ((pbIsSnagBall?(ball) || battler.isShadow?) && $game_switches[1235]==true))
      @scene.pbThrowAndDeflect(ball,1)
      if $game_switches[290]==false 
        pbDisplay(_INTL("The Trainer blocked the Ball!\nDon't be a thief!"))
      else
        pbDisplay(_INTL("The Pokémon knocked the ball away!"))
      end
      pbBallFetch(ball)
    elsif @raidbattle && (@shieldCount>0 || aboveLimit)
      pbDisplay(_INTL("The Pokémon knocked the ball away!"))
      pbBallFetch(ball)
    else
      if $game_switches[1500]==true
        pbDisplay(_INTL("The Ball didn't work!"))
        return
      end
      if $game_switches[290]==true
        pbDisplay(_INTL("The Pokémon knocked the ball away!"))
        return
      end
      pokemon=battler.pokemon
      species=pokemon.species
      if $DEBUG && Input.press?(Input::CTRL)
        shakes=4
      else
        if !rareness
          rareness = $pkmn_dex[species][6]
        end
        formrarity = MultipleForms.call("catchrate",pokemon)
        if formrarity!=nil
          rareness = formrarity
        end         
        a=battler.totalhp
        b=battler.hp
        rareness=BallHandlers.modifyCatchRate(ball,rareness,self,battler)
        x=(((a*3-b*2)*rareness)/(a*3)).floor
        if battler.status==PBStatuses::SLEEP || battler.status==PBStatuses::FROZEN ||
           battler.status==PBStatuses::PARALYSIS
          x=(x*2.5).floor
        elsif battler.status!=0
          x=(x*1.5).floor
        end
        #Critical Capture chances based on caught species'
        c=0
        if $Trainer
          if $Trainer.pokedexOwned>600
            c=(x*2.5/6).floor
          elsif $Trainer.pokedexOwned>450
            c=(x*2/6).floor
          elsif $Trainer.pokedexOwned>300
            c=(x*1.5/6).floor
          elsif $Trainer.pokedexOwned>150
            c=(x*1/6).floor
          elsif $Trainer.pokedexOwned>30
            c=(x*0.5/6).floor
          end
        end
        if $PokemonBag.pbHasItem?(:CATCHINGCHARM)
          c=(c*2.0).floor # 2.0 is a placeholder value, adjust later
        end
        shakes=0; critical=false; critsuccess=false
        if x>255 || BallHandlers.isUnconditional?(ball,self,battler)
          shakes=4
        else
          x=1 if x<1
          y = (65536/((255.0/x)**0.1875) ).floor
          if pbRandom(256)<c
            critical=true
            if pbRandom(65536)<y 
              critsuccess=true
              shakes=4 
            end            
          else          
            shakes+=1 if pbRandom(65536)<y
            shakes+=1 if pbRandom(65536)<y
            shakes+=1 if pbRandom(65536)<y
            shakes+=1 if pbRandom(65536)<y 
          end        
        end
      end
      @scene.pbThrow(ball,(critical) ? 1 : shakes,critical,critsuccess,battler.index,showplayer)
      
      case shakes
      when 0
        pbDisplay(_INTL("Oh no! The Pokémon broke free!"))
        BallHandlers.onFailCatch(ball,self,pokemon)
        pbBallFetch(ball)
      when 1
        pbDisplay(_INTL("Aww... It appeared to be caught!"))
        BallHandlers.onFailCatch(ball,self,pokemon)
        pbBallFetch(ball)
      when 2
        pbDisplay(_INTL("Aargh! Almost had it!"))
        BallHandlers.onFailCatch(ball,self,pokemon)
        pbBallFetch(ball)
      when 3
        pbDisplay(_INTL("Shoot! It was so close, too!"))
        BallHandlers.onFailCatch(ball,self,pokemon)
        pbBallFetch(ball)
      when 4
        pbDisplayBrief(_INTL("Gotcha! {1} was caught!",pokemon.name))
#        @scene.pbThrowSuccess
        if pbIsSnagBall?(ball) && @opponent
          pbRemoveFromParty(battler.index,battler.pokemonIndex)
          battler.pbReset
          battler.participants=[]
        else
          @decision=4
        end
        if pbIsSnagBall?(ball)
          pokemon.ot=self.pbPlayer.name
          pokemon.trainerID=self.pbPlayer.id
        end
        BallHandlers.onCatch(ball,self,pokemon)
        pokemon.ballused=pbGetBallType(ball)
        pokemon.pbRecordFirstMoves
        if !self.pbPlayer.owned[species]
          self.pbPlayer.owned[species]=true
          if $Trainer.pokedex
            pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.",pokemon.name))
            @scene.pbShowPokedex(species)
          end
        end
        @scene.pbHideCaptureBall
        if pbIsSnagBall?(ball) && @opponent
          pokemon.pbUpdateShadowMoves rescue nil
          @snaggedpokemon.push(pokemon)
        else
          pbStorePokemon(pokemon)
        end
      end
    end
  end
end



################################################################################
# Main battle class.
################################################################################
class PokeBattle_Battle
  attr_reader(:scene)             # Scene object for this battle
  attr_accessor(:decision)        # Decision: 0=undecided; 1=win; 2=loss; 3=escaped; 4=caught
  attr_accessor(:internalbattle)  # Internal battle flag
  attr_accessor(:doublebattle)    # Double battle flag
  attr_accessor(:cantescape)      # True if player can't escape
  attr_accessor(:shiftStyle)      # Shift/Set "battle style" option
  attr_accessor(:battlescene)     # "Battle scene" option
  attr_accessor(:debug)           # Debug flag
  attr_reader(:player)            # Player trainer
  attr_reader(:opponent)          # Opponent trainer
  attr_reader(:party1)            # Player's Pokémon party
  attr_reader(:party2)            # Foe's Pokémon party
  attr_reader(:partyorder)        # Order of Pokémon in the player's party
  attr_accessor(:fullparty1)      # True if player's party's max size is 6 instead of 3
  attr_accessor(:fullparty2)      # True if opponent's party's max size is 6 instead of 3
  attr_reader(:battlers)          # Currently active Pokémon
  attr_accessor(:items)           # Items held by opponents
  attr_reader(:sides)             # Effects common to each side of a battle
  attr_reader(:field)             # Effects common to the whole of a battle
  attr_accessor(:environment)     # Battle surroundings
  attr_accessor(:weather)         # Current weather, custom methods should use pbWeather instead
  attr_accessor(:weatherduration) # Duration of current weather, or -1 if indefinite
  attr_accessor(:weatherbackup)    # The original weather of the area, if it exists.  #### DemICE - persistentweather
  attr_accessor(:weatherbackupanim)# Easy loading for original weather's animation.  #### DemICE - persistentweather
  attr_reader(:switching)         # True if during the switching phase of the round
  attr_reader(:faintswitch)       # True if switching after a faint during endphase  
  attr_reader(:struggle)          # The Struggle move
  attr_accessor(:choices)         # Choices made by each Pokémon this round
  attr_reader(:successStates)     # Success states
  attr_accessor(:lastMoveUsed)    # Last move used
  attr_accessor(:lastMoveUser)    # Last move user
  attr_accessor(:synchronize)     # Synchronize state
  attr_accessor(:megaEvolution)   # Battle index of each trainer's Pokémon to Mega Evolve
  attr_accessor(:amuletcoin)      # Whether Amulet Coin's effect applies
  attr_accessor(:extramoney)      # Money gained in battle by using Pay Day
  attr_accessor(:endspeech)       # Speech by opponent when player wins
  attr_accessor(:endspeech2)      # Speech by opponent when player wins
  attr_accessor(:endspeechwin)    # Speech by opponent when opponent wins
  attr_accessor(:endspeechwin2)   # Speech by opponent when opponent wins 
  attr_accessor(:trickroom)
#### KUROTSUNE - 015 - START  
  attr_accessor(:switchedOut)
#### KUROTSUNE - 015 - END  
  attr_accessor(:previousMove)    # Move used directly previously
  attr_accessor(:aiMoveMemory)
  attr_accessor(:revealedMoves) # moves revealed by enemy pokemon
  attr_accessor(:aiAbilityMemory)
  attr_accessor(:rules)
  attr_reader(:turncount)
  attr_accessor :controlPlayer
#### SARDINES - Eruption - START
  attr_accessor(:eruption)        # Eruption variable for Volcano Top field
#### SARDINES - Eruption - END
#### SARDINES - Dragon's Den - START
  attr_accessor(:basefield)
#### SARDINES - Dragon's Den - END
  attr_accessor(:bossfight)       # Stores fight is boss battle or not
  attr_accessor(:shieldSetup)
  attr_accessor(:shieldCount)
  attr_accessor(:maybestatusing)
  attr_accessor(:statustarget)
  attr_accessor(:raidbattle)      # stores fight is raid den battle or not
  attr_accessor(:ultramegadeath)  # ussd for Ultra Mega Death

  include PokeBattle_BattleCommon
  
  MAXPARTYSIZE = 6

  class BattleAbortedException < Exception; end

  def pbAbort
    raise BattleAbortedException.new("Battle aborted")
  end

  def pbDebugUpdate
  end

  def pbRandom(x)
    return rand(x)
  end

  def pbAIRandom(x)
    return rand(x)
  end

  def isOnline?
    return false
  end  
################################################################################
# Initialise battle class.
################################################################################
  def initialize(scene,p1,p2,player,opponent)
    if p1.length==0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
      return
    end
    if p2.length==0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
      return
    end
    if p2.length>2 && !opponent
      raise ArgumentError.new(_INTL("Wild battles with more than two Pokémon are not allowed."))
      return
    end
    @scene           = scene
    @decision        = 0
    @internalbattle  = true
    @doublebattle    = false
    @cantescape      = false
    @shiftStyle      = true
    @battlescene     = true
    @debug           = false
    @debugupdate     = 0
    if opponent && player.is_a?(Array) && player.length==0
      player = player[0]
    end
    if opponent && opponent.is_a?(Array) && opponent.length==0
      opponent = opponent[0]
    end
    @player          = player                # PokeBattle_Trainer object
    @opponent        = opponent              # PokeBattle_Trainer object
    @party1          = p1
    @party2          = p2
    @partyorder      = []
    for i in 0...6; @partyorder.push(i); end
    @fullparty1      = false
    @fullparty2      = false
    @battlers        = []
    @items           = nil
    @sides           = [PokeBattle_ActiveSide.new,   # Player's side
                        PokeBattle_ActiveSide.new]   # Foe's side
    @field           = PokeBattle_ActiveField.new    # Whole field (gravity/rooms)
    @environment     = PBEnvironment::None   # e.g. Tall grass, cave, still water
    @weather         = 0
    @weatherduration = 0
    @weatherbackup    = 0      #### DemICE - persistentweather
    @weatherbackupanim = nil  #### DemICE  - persistentweather
    @switching       = false
    @faintswitch     = false
    @choices         = [ [0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1] ]
    @successStates   = []
    for i in 0...4
      @successStates.push(PokeBattle_SuccessState.new)
    end
    @lastMoveUsed    = -1
    @lastMoveUser    = -1
    @partnerswitch   = []
    @aiMoveMemory    = [[],[],[[],[],[],[],[],[],[],[],[],[],[],[]]]
    @revealedMoves   = [[[],[],[],[],[],[],[],[],[],[],[],[]]]
    @aiAbilityMemory = [[[],[],[],[],[],[],[],[],[],[],[],[]]]
    @synchronize     = [-1,-1,0]
    @megaEvolution   = []
    if @player.is_a?(Array)
      @megaEvolution[0]=[-1]*@player.length
    else
      @megaEvolution[0]=[-1]
    end
    if @opponent.is_a?(Array)
      @megaEvolution[1]=[-1]*@opponent.length
    else
      @megaEvolution[1]=[-1]
    end
    @zMove           = []
    if @player.is_a?(Array)
      @zMove[0]=[-1]*@player.length
    else
      @zMove[0]=[-1]
    end
    if @opponent.is_a?(Array)
      @zMove[1]=[-1]*@opponent.length
    else
      @zMove[1]=[-1]
    end    
    @amuletcoin      = false
#### KUROTSUNE - 015 - START
    @switchedOut     = []
#### KUROTSUNE - 015 - END    
    @extramoney      = 0
    @endspeech       = ""
    @endspeech2      = ""
    @endspeechwin    = ""
    @endspeechwin2   = ""
    @rules           = {}
    @turncount       = 0
    @peer            = PokeBattle_BattlePeer.create()
    @trickroom       = 0
    @priority        = []
    @usepriority     = false
    @snaggedpokemon  = []
    @runCommand      = 0
    if hasConst?(PBMoves,:STRUGGLE)
      @struggle = PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:STRUGGLE)),nil)
    else
      @struggle = PokeBattle_Struggle.new(self,nil,nil)
    end
    @struggle.pp     = -1
    for i in 0...4
      battlers[i] = PokeBattle_Battler.new(self,i)
    end
    for i in @party1
      next if !i
      i.itemRecycle = 0
      i.itemInitial = i.item
    end
    for i in @party2
      next if !i
      i.itemRecycle = 0
      i.itemInitial = i.item
    end
#### SARDINES - Eruption - START
    @eruption        = false
#### SARDINES - Eruption - END
    @basefield       = 0
    @bossfight       = false
    @shieldSetup     = -1
    @shieldCount     = -1
    @maybestatusing  = false
    @statustarget    = nil
    @raidbattle      = $game_switches[1305]
    $game_variables[530] = 0
    $game_variables[536] = 0
    $game_variables[541] = 0
    @ultramegadeath  = 0
  end
  
  
  def pbMakeFakeBattler(pokemon,batonpass=false,currentmon=nil,effectnegate=true)
    if @index.nil? || !currentmon.nil?
       @index=currentmon.index
    end
    wonderroom= @field.effects[PBEffects::WonderRoom]!=0
    battler = PokeBattle_Battler.new(self,@index)
    battler.pbInitPokemon(pokemon,@index,wonderroom)
    battler.pbInitEffects(batonpass,false,effectnegate)
    return battler
  end
################################################################################
# Info about battle.
################################################################################
  def pbIsWild?
    return !@opponent? true : false
  end
  
  def pbDoubleBattleAllowed?
    return true
  end
  
  def pbCheckSideAbility(a,pkmn) #checks to see if your side has a pokemon with a certain ability.
    for i in 0...4 # in order from own first, opposing first, own second, opposing second
      if @battlers[i].hasWorkingAbility(a)
        if @battlers[i]==pkmn || @battlers[i]==pkmn.pbPartner
          return @battlers[i]
        end
      end
    end
    return nil
  end
  
  def pbWeather
    for i in 0...4
      if @battlers[i].hasWorkingAbility(:CLOUDNINE) ||
         @battlers[i].hasWorkingAbility(:AIRLOCK) ||
         $fefieldeffect == 22
        return 0
      end
    end
    return @weather
  end
  
  def seedCheck
    for battler in @battlers
      next if battler.hp==0
      if isConst?(battler.item, PBItems, :ELEMENTALSEED)
        case $fefieldeffect
        when 1 #Electric Terrain
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Defense!",
              battler.pbThis))
          end
          battler.effects[PBEffects::Charge]=2
          pbAnimation(81,battler,nil) # Charge Animation
          pbDisplay(_INTL("{1} began charging power!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 2 #Grassy Terrain
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Defense!",
              battler.pbThis))
          end
          battler.effects[PBEffects::Ingrain]=true
          pbAnimation(216,battler,nil) # Ingrain Animation
          pbDisplay(_INTL("{1} planted its roots!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0 
        when 3 #Misty Terrain
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Special Defense!",
              battler.pbThis))
          end
          battler.pbRecoverHP(battler.totalhp,true)
          battler.status=0
          battler.statusCount=0            
          pbDisplayPaused(_INTL("The healing wish came true for {1}!",battler.pbThis(true)))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 7 #Burning Field
          boost=false
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::ATTACK)
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end          
          if !battler.pbTooHigh?(PBStats::SPEED)
            battler.pbIncreaseStatBasic(PBStats::SPEED,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end     
          if boost
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Special Attack, Attack, and Speed!",
              battler.pbThis))
          end
          battler.effects[PBEffects::MultiTurn]=4          
          battler.effects[PBEffects::MultiTurnAttack]=147
          battler.effects[PBEffects::MultiTurnUser]=battler.index 
          pbAnimation(147,battler,nil) # Fire Spin Animation
          pbDisplayPaused(_INTL("{1} was trapped in the vortex!",battler.pbThis(true)))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 11 #Corrosive Mist Field
          boost=false
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::ATTACK)
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end             
          if boost
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Attack and Special Attack!",
              battler.pbThis))
          end
          if battler.pbCanPoison?(true)  
            battler.pbPoison(battler,true)
            pbDisplayPaused(_INTL("{1} was badly poisoned!",battler.pbThis(true)))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 13 #Icy Field
          if !battler.pbTooHigh?(PBStats::SPEED)
            battler.pbIncreaseStatBasic(PBStats::SPEED,2)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Elemental Seed sharply boosted its Speed!",
              battler.pbThis))
            battler.pokemon.itemRecycle=battler.item
            battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
            battler.item=0
          end  
        when 21 #Water Surface
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Special Defense!",
              battler.pbThis))
          end
          battler.effects[PBEffects::AquaRing]=true
          pbAnimation(555,battler,nil) # Aqua Ring animation
          pbDisplay(_INTL("{1} surrounded itself with a veil of water!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0     
        when 22 #Underwater
          if !battler.pbTooHigh?(PBStats::SPEED)
            battler.pbIncreaseStatBasic(PBStats::SPEED,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Speed!",
              battler.pbThis))
          end
          if !(isConst?(battler.ability,PBAbilities,:MULTITYPE) ||
             isConst?(battler.ability,PBAbilities,:RKSSYSTEM))
            battler.type1=getConst(PBTypes,:WATER)
            battler.type2=getConst(PBTypes,:WATER)
            typename=PBTypes.getName(getConst(PBTypes,:WATER))    
            pbAnimation(557,battler,nil) # Soak animation
            pbDisplay(_INTL("{1} transformed into the {2} type!",battler.pbThis,typename))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0  
        when 26 #Murkwater Surface
          battler.effects[PBEffects::AquaRing]=true
          pbAnimation(555,battler,nil) # Aqua Ring animation
          pbDisplay(_INTL("{1} surrounded itself with a veil of water!",battler.pbThis))
          if !battler.pbTooHigh?(PBStats::SPEED)
            battler.pbIncreaseStatBasic(PBStats::SPEED,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Speed!",
              battler.pbThis))
          end
          if battler.pbCanPoison?(true)
            battler.pbPoison(battler,true)
            pbDisplayPaused(_INTL("{1} was badly poisoned!",battler.pbThis(true)))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0  
        when 32 #Dragon's Den
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Special Attack!",
              battler.pbThis))
          end
          battler.effects[PBEffects::FlashFire]=true
          #pbAnimation(555,battler,nil) # Aqua Ring animation
          pbDisplay(_INTL("{1} raised its Fire power!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 39 #Frozen Dimensional Field
          if !battler.pbTooHigh?(PBStats::SPEED)
            battler.pbIncreaseStatBasic(PBStats::SPEED,2)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its Speed!",
              battler.pbThis))
          end
          if !battler.effects[PBEffects::Torment]
            battler.effects[PBEffects::Torment]=true
            pbDisplay(_INTL("{1} was subjected to torment!",
              battler.pbThis))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 43 #Sky Field
          boost=false
          if !battler.pbTooLow?(PBStats::SPDEF)
            battler.pbReduceStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatDown",battler,nil)
            boost=true
          end
          if !battler.pbTooLow?(PBStats::DEFENSE)
            battler.pbReduceStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatDown",battler,nil)
            boost=true
          end
          if boost
            pbDisplay(_INTL("{1}'s Elemental Seed lowered its Defense and Special Defense!",
              battler.pbThis))
          end
          battler.pbOwnSide.effects[PBEffects::Tailwind]=8
          pbAnimation(173,battler,nil) # Tailwind Animation
          pbDisplay(_INTL("The tailwind blew from behind {1}'s team!",battler.pbThis))
          # if @weather!=PBWeather::STRONGWINDS
          #   @weather=PBWeather::STRONGWINDS
          #   @weatherduration=-1
          # end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 45 #Infernal Field  
          boost=false  
          if !battler.pbTooHigh?(PBStats::SPATK)  
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)  
            pbCommonAnimation("StatUp",battler,nil) if !boost  
            boost=true  
          end  
          if !battler.pbTooHigh?(PBStats::ATTACK)  
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)  
            pbCommonAnimation("StatUp",battler,nil) if !boost  
            boost=true  
          end            
          if boost  
            pbDisplay(_INTL("{1}'s Elemental Seed boosted its offenses!",  
              battler.pbThis))  
          end  
          battler.effects[PBEffects::MeanLook]=battler.index    
          pbAnimation(379,battler,nil) # Mean Look Animation  
          pbDisplayPaused(_INTL("{1} was trapped in the field!",battler.pbThis(true)))  
          battler.pokemon.itemRecycle=battler.item  
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item  
          battler.item=0
        end
      elsif isConst?(battler.item, PBItems, :MAGICALSEED)
        case $fefieldeffect
        when 4 #Dark Crystal Cavern
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Special Defense!",
              battler.pbThis))
          end
          battler.effects[PBEffects::MagicCoat]=true
          pbAnimation(484,battler,nil) # Magic Coat Animation
          pbDisplay(_INTL("{1} shrouded itself with Magic Coat!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 9 #Rainbow Field
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Special Attack!",
              battler.pbThis))
          end
          battler.pbRecoverHP(battler.totalhp,true)
          battler.status=0
          battler.statusCount=0            
          pbDisplayPaused(_INTL("The healing wish came true for {1}!",battler.pbThis(true)))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 25 #Crystal Cavern
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Special Attack!",
              battler.pbThis))
          end
          battler.effects[PBEffects::MagicCoat]=true
          pbAnimation(484,battler,nil) # Magic Coat Animation
          pbDisplay(_INTL("{1} shrouded itself with Magic Coat!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 29 #Holy Field
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Special Attack!",
              battler.pbThis))
          end
          battler.effects[PBEffects::MagicCoat]=true
          pbAnimation(484,battler,nil) # Magic Coat Animation
          pbDisplay(_INTL("{1} shrouded itself with Magic Coat!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 31 #Fairy Tale Field
          if !battler.pbTooHigh?(PBStats::ATTACK)
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Attack!",
              battler.pbThis))
          end
          battler.effects[PBEffects::KingsShield]=true
          pbAnimation(584,battler,nil) # King's Shield Animation
          pbDisplay(_INTL("{1} shielded itself against damage!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 34 #Starlight Arena 
          next if isConst?(battler.ability,PBAbilities,:WORLDOFNIGHTMARES)
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Special Attack!",
              battler.pbThis))
          end
          battler.pbRecoverHP(battler.totalhp,true)
          battler.status=0
          battler.statusCount=0            
          pbDisplayPaused(_INTL("{1} became cloaked in mystical moonlight!!",battler.pbThis(true)))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 35 #New World
          boost=false
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::SPEED)
            battler.pbIncreaseStatBasic(PBStats::SPEED,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::ATTACK)
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if boost
            pbDisplay(_INTL("{1}'s Magical Seed boosted all of its stats!",
              battler.pbThis))
          end
          battler.effects[PBEffects::HyperBeam]=1
          pbDisplay(_INTL("{1} must recharge!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 36 #Inverse Field
          if !battler.pbHasType?(:NORMAL)
            newtype=getConst(PBTypes,:NORMAL) || 0
            battler.type1=newtype
            battler.type2=newtype
            typename=PBTypes.getName(newtype)
            pbDisplay(_INTL("{1} transformed into the {2} type!",
              battler.pbThis,typename))
          end
          if !isConst?(battler.ability,PBAbilities,:NORMALIZE)
            battler.ability=getConst(PBAbilities,:NORMALIZE) || 0
            pbDisplay(_INTL("{1}'s Magical Seed Normalized it!",
              battler.pbThis))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 37 #Psychic Terrain
          boost=false
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if boost
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Special Attack and Special Defense!",
              battler.pbThis))
          end
          if battler.pbCanConfuse?(false)    
            battler.effects[PBEffects::Confusion]=2+pbRandom(4)
            pbCommonAnimation("Confusion",battler,nil)
            pbDisplay(_INTL("{1} became confused!",battler.pbThis))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 38 #Dimensional Field
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Defense!",
              battler.pbThis))
          end
          if @trickroom == 0
            @trickroom=5
            pbAnimation(499,battler,nil) # Trick Room Animation
            pbDisplay(_INTL("{1} twisted the dimensions!",battler.pbThis))
          else
            @trickroom=0
            pbAnimation(499,battler,nil) # Trick Room Animation
            pbDisplay(_INTL("The twisted dimensions returned to normal!",battler.pbThis))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 40 #Haunted Field
          boost=false
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if boost
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Defense and Special Defense!",
              battler.pbThis))
          end
          if battler.pbCanBurn?(true)
            battler.pbBurn(battler)
            pbDisplayPaused(_INTL("{1} was burned!",battler.pbThis(true)))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 42 #Bewitched Woods
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Magical Seed boosted its Special Defense!",
              battler.pbThis))
          end
          battler.effects[PBEffects::Ingrain]=true
          pbAnimation(216,battler,nil) # Ingrain Animation
          pbDisplay(_INTL("{1} planted its roots!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        end
      elsif isConst?(battler.item, PBItems, :SYNTHETICSEED)
        case $fefieldeffect
        when 5 #Chess Board
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Synthetic Seed boosted its Special Attack!",
              battler.pbThis))
          end
          battler.effects[PBEffects::MagicCoat]=true
          pbAnimation(484,battler,nil) # Magic Coat Animation
          pbDisplay(_INTL("{1} shrouded itself with Magic Coat!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 6 #Big Top
          if !battler.pbTooHigh?(PBStats::ATTACK)
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Synthetic Seed boosted its Attack!",
              battler.pbThis))
          end
          battler.effects[PBEffects::HelpingHand]=true
          # pbAnimation(372,battler,nil) # Helping Hand Animation
          pbDisplay(_INTL("{1} accepts the crowd's help!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 17 #Factory
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Synthetic Seed boosted its Special Attack!",
              battler.pbThis))
          end            
          battler.effects[PBEffects::LaserFocus]=2
          pbAnimation(658,battler,nil) # Laser Focus Animation
          pbDisplay(_INTL("{1} is focused!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 18 #Short-Circuit
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Synthetic Seed boosted its Special Defense!",
              battler.pbThis))
          end
          battler.effects[PBEffects::MagnetRise]=8
          pbAnimation(82,battler,nil) # Magnet Rise Animation
          pbDisplay(_INTL("{1} levitated with electromagnetism!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 24 #Glitch
          boost=false
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if boost
            pbDisplay(_INTL("{1}'s Synthetic Seed boosted its Defense and Special Defense!",
              battler.pbThis))
          end
          if !(isConst?(battler.ability,PBAbilities,:MULTITYPE) ||
             isConst?(battler.ability,PBAbilities,:RKSSYSTEM))
            battler.type1=getConst(PBTypes,:QMARKS)
            battler.type2=getConst(PBTypes,:QMARKS)
            typename=PBTypes.getName(getConst(PBTypes,:QMARKS))
           #No anim? pbAnimation(557,battler,nil) # Soak animation
            pbDisplay(_INTL("{1}.TYPE = GETCONST(PBTYPES,:QMARKS)",battler.pbThis.upcase,typename))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 30 #Mirror Arena
          if !battler.pbTooHigh?(PBStats::EVASION)
            battler.pbIncreaseStatBasic(PBStats::EVASION,2)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Synthetic Seed sharply boosted its Evasion!",
              battler.pbThis))
            battler.pokemon.itemRecycle=battler.item
            battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
            battler.item=0
          end
        when 33 #Flower Garden
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Synthetic Seed boosted its Special Defense!",
              battler.pbThis))
          end
          battler.effects[PBEffects::Ingrain]=true
          pbAnimation(216,battler,nil) # Ingrain Animation
          pbDisplay(_INTL("{1} planted its roots!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 41 #Corrupted Cave
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,2)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            pbDisplay(_INTL("{1}'s Synthetic Seed boosted its Defense!",
              battler.pbThis))
          end
          if battler.pbCanPoison?(true)
            battler.pbPoison(battler,true)
            pbDisplayPaused(_INTL("{1} was poisoned!",battler.pbThis(true)))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 44 #Colosseum Field  
          if !battler.pbTooHigh?(PBStats::ATTACK)  
            battler.pbIncreaseStatBasic(PBStats::ATTACK,2)  
            pbCommonAnimation("StatUp",battler,nil) if !boost  
            pbDisplay(_INTL("{1}'s Synthetic Seed boosted its Attack!",  
              battler.pbThis))  
          end  
          if battler.effects[PBEffects::Taunt]==0    
            pbAnimation(49,battler,nil) # Taunt Animation  
            battler.effects[PBEffects::Taunt]=4  
            pbDisplayPaused(_INTL("{1} feels taunted!",battler.pbThis(true)))  
          end  
          battler.pokemon.itemRecycle=battler.item  
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item  
          battler.item=0
        end        
      elsif isConst?(battler.item, PBItems, :TELLURICSEED)
        case $fefieldeffect
        when 8 #Swamp Field
          boost=false
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if boost
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Defense and Special Defense!",
              battler.pbThis))
          end
          battler.effects[PBEffects::Ingrain]=true
          pbAnimation(216,battler,nil) # Ingrain Animation
          pbDisplay(_INTL("{1} planted its roots!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 10 #Corrosive Field
          if !battler.pbTooHigh?(PBStats::ATTACK)
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Attack!",
              battler.pbThis))
          end
          battler.effects[PBEffects::BanefulBunker]=true
          pbAnimation(693,battler,nil) # Baneful Bunker Animation
          pbDisplay(_INTL("{1} shielded itself against damage!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 12 #Desert Field
          boost=false
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::SPEED)
            battler.pbIncreaseStatBasic(PBStats::SPEED,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if boost
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Special Defense, Defense, and Speed!",
              battler.pbThis))
          end
          battler.effects[PBEffects::MultiTurn]=4          
          battler.effects[PBEffects::MultiTurnAttack]=232
          battler.effects[PBEffects::MultiTurnUser]=battler.index 
          pbAnimation(232,battler,nil) # Sand Tomb Animation
          pbDisplayPaused(_INTL("{1} was trapped by Sand Tomb!",battler.pbThis(true)))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 14 #Rocky Field
          boost=false
          if !battler.pbTooHigh?(PBStats::SPDEF)
            battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if boost
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Defense and Special Defense!",
              battler.pbThis))
          end
          if !battler.hasWorkingAbility(:MAGICGUARD)
            atype=getConst(PBTypes,:ROCK) || 0         
            eff=PBTypes.getCombinedEffectiveness(atype,battler.type1,battler.type2)
            if eff>0
              eff = eff*2
              @scene.pbDamageAnimation(battler,0)
              battler.pbReduceHP([(battler.totalhp*eff/32).floor,1].max)
              pbDisplay(_INTL("{1} was hurt by stealth rocks!",battler.pbThis))
              battler.pbFaint if battler.isFainted?
            end
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0 
        when 15 #Forest Field
          if !battler.pbTooHigh?(PBStats::ATTACK)
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Attack!",
              battler.pbThis))
          end
          battler.effects[PBEffects::SpikyShield]=true
          pbAnimation(603,battler,nil) # Spiky Shield Animation
          pbDisplay(_INTL("{1} shielded itself against damage!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 16 #Superheated Field
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Defense!",
              battler.pbThis))
          end
          battler.effects[PBEffects::ShellTrap]=true
          pbCommonAnimation("ShellTrap",battler,nil) # Shell Trap Animation
          pbDisplay(_INTL("{1} primed a trap!",battler.pbThis))
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 19 #Wasteland
          boost=false
          if !battler.pbTooHigh?(PBStats::ATTACK)
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil) if !boost
            boost=true
          end
          if boost
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Attack and Special Attack!",
              battler.pbThis))
          end
          rnd=pbRandom(4)
          case rnd
          when 0
            break if !battler.pbCanBurn?(false)
            battler.pbBurn(battler)
            pbDisplay(_INTL("{1} was burned!",battler.pbThis))
          when 1
            break if !battler.pbCanFreeze?(false)
            battler.pbFreeze
            pbDisplay(_INTL("{1} was frozen solid!",battler.pbThis))
          when 2
            break if !battler.pbCanParalyze?(false)
            battler.pbParalyze(battler)
            pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",battler.pbThis))
          when 3
            break if !battler.pbCanPoison?(false)
            battler.pbPoison(battler)
            pbDisplay(_INTL("{1} was poisoned!",battler.pbThis))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 20 #Ashen Beach
          if !(battler.effects[PBEffects::FocusEnergy]>=2)
            battler.effects[PBEffects::FocusEnergy]=3
            pbAnimation(364,battler,nil) # Focus Energy Animation
            pbDisplay(_INTL("{1}'s Telluric Seed is getting it pumped!",
              battler.pbThis))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 23 #Cave Field
          if !battler.pbTooHigh?(PBStats::DEFENSE)
            battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Defense!",
              battler.pbThis)) 
          end
          if !battler.hasWorkingAbility(:MAGICGUARD)
            atype=getConst(PBTypes,:ROCK) || 0         
            eff=PBTypes.getCombinedEffectiveness(atype,battler.type1,battler.type2)
            if eff>0
              eff = eff*2
              @scene.pbDamageAnimation(battler,0)
              battler.pbReduceHP([(battler.totalhp*eff/32).floor,1].max)
              pbDisplay(_INTL("{1} was hurt by stealth rocks!",battler.pbThis))
              battler.pbFaint if battler.isFainted?
            end
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 27 #Mountain
          if !battler.pbTooHigh?(PBStats::ATTACK)
            battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Attack!",
              battler.pbThis))
          end
          if !battler.pbTooLow?(PBStats::ACCURACY)
            battler.pbReduceStatBasic(PBStats::ACCURACY,1)
            pbCommonAnimation("StatDown",battler,nil)
            pbDisplay(_INTL("{1}'s Telluric Seed lowered its Accuracy!",
              battler.pbThis))
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        when 28 #Snowy Mountain
          if !battler.pbTooHigh?(PBStats::SPATK)
            battler.pbIncreaseStatBasic(PBStats::SPATK,1)
            pbCommonAnimation("StatUp",battler,nil)
            pbDisplay(_INTL("{1}'s Telluric Seed boosted its Special Attack!",
              battler.pbThis)) 
          end                      
          if !battler.pbTooLow?(PBStats::ACCURACY)
            battler.pbIncreaseStatBasic(PBStats::ACCURACY,1)
            pbCommonAnimation("StatDown",battler,nil)
            pbDisplay(_INTL("{1}'s Telluric Seed lowered its Accuracy!",
              battler.pbThis)) 
          end
          battler.pokemon.itemRecycle=battler.item
          battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
          battler.item=0
        end
      elsif isConst?(battler.item, PBItems, :RIFTSEED)
        if $fefieldeffect==38 || $fefieldeffect==39 #Dimensional/Frozen Dim Field
          increment = 1
          increment = 2 if $fefieldeffect == 38
          aBoost = battler.attack
          dBoost = battler.defense
          saBoost = battler.spatk
          sdBoost = battler.spdef
          spdBoost = battler.speed
          boostStat = [aBoost,dBoost,saBoost,sdBoost,spdBoost].max
          case boostStat
          when aBoost            
            if !battler.pbTooHigh?(PBStats::ATTACK)
              pbCommonAnimation("StatUp",battler,nil)
              battler.pbIncreaseStatBasic(PBStats::ATTACK,increment)
              pbDisplay(_INTL("{1}'s Rift Seed boosted its Attack!",battler.pbThis))
            end
          when dBoost
            if !battler.pbTooHigh?(PBStats::DEFENSE)
              pbCommonAnimation("StatUp",battler,nil)
              battler.pbIncreaseStatBasic(PBStats::DEFENSE,increment)
              pbDisplay(_INTL("{1}'s Rift Seed boosted its Defense!",battler.pbThis))
            end
          when saBoost
            if !battler.pbTooHigh?(PBStats::SPATK)
              pbCommonAnimation("StatUp",battler,nil)
              battler.pbIncreaseStatBasic(PBStats::SPATK,increment)
              pbDisplay(_INTL("{1}'s Rift Seed boosted its Special Attack!",battler.pbThis))
            end
          when sdBoost
            if !battler.pbTooHigh?(PBStats::SPDEF)
              pbCommonAnimation("StatUp",battler,nil)
              battler.pbIncreaseStatBasic(PBStats::SPDEF,increment)
              pbDisplay(_INTL("{1}'s Rift Seed boosted its Special Defense!",battler.pbThis))
            end
          when spdBoost
            if !battler.pbTooHigh?(PBStats::SPEED)
              pbCommonAnimation("StatUp",battler,nil)
              battler.pbIncreaseStatBasic(PBStats::SPEED,increment)
              pbDisplay(_INTL("{1}'s Rift Seed boosted its Speed!",battler.pbThis))
            end
          end
        end
        battler.pokemon.itemRecycle=battler.item
        battler.pokemon.itemInitial=0 if battler.pokemon.itemInitial==battler.item
        battler.item=0
      end
    end
  end
 
################################################################################
# Get battler info.
################################################################################
  def pbIsOpposing?(index)
    return (index%2)==1
  end

  def pbOwnedByPlayer?(index)
    return false if pbIsOpposing?(index)
    return false if @player.is_a?(Array) && index==2
    return true
  end

  def pbIsDoubleBattler?(index)
    return (index>=2)
  end

  def pbThisEx(battlerindex,pokemonindex)
    party=pbParty(battlerindex)
    if pbIsOpposing?(battlerindex)
      if @opponent 
        return _INTL("The foe {1}",party[pokemonindex].name)
      elsif ($game_switches[1500]==true || $game_switches[290]==true)
        return _INTL("{1}",party[pokemonindex].name)
      else
        return _INTL("The wild {1}",party[pokemonindex].name)
      end
    else
      return _INTL("{1}",party[pokemonindex].name)
    end
  end

# Checks whether an item can be removed from a Pokémon.
  def pbIsUnlosableItem(pkmn,item)
    return true if pbIsMail?(item)
    return true if pbIsZCrystal?(item)
    return false if pkmn.effects[PBEffects::Transform]
    if isConst?(pkmn.ability,PBAbilities,:MULTITYPE) &&
       (isConst?(item,PBItems,:FISTPLATE) ||
        isConst?(item,PBItems,:SKYPLATE) ||
        isConst?(item,PBItems,:TOXICPLATE) ||
        isConst?(item,PBItems,:EARTHPLATE) ||
        isConst?(item,PBItems,:STONEPLATE) ||
        isConst?(item,PBItems,:INSECTPLATE) ||
        isConst?(item,PBItems,:SPOOKYPLATE) ||
        isConst?(item,PBItems,:IRONPLATE) ||
        isConst?(item,PBItems,:FLAMEPLATE) ||
        isConst?(item,PBItems,:SPLASHPLATE) ||
        isConst?(item,PBItems,:MEADOWPLATE) ||
        isConst?(item,PBItems,:ZAPPLATE) ||
        isConst?(item,PBItems,:MINDPLATE) ||
        isConst?(item,PBItems,:ICICLEPLATE) ||
        isConst?(item,PBItems,:DRACOPLATE) ||
        isConst?(item,PBItems,:PIXIEPLATE) || 
        isConst?(item,PBItems,:DREADPLATE))
      return true
    end
    if isConst?(pkmn.ability,PBAbilities,:RKSSYSTEM) &&
       (isConst?(item,PBItems,:FIGHTINGMEMORY) ||
        isConst?(item,PBItems,:FLYINGMEMORY) ||
        isConst?(item,PBItems,:POISONMEMORY) ||
        isConst?(item,PBItems,:GROUNDMEMORY) ||
        isConst?(item,PBItems,:ROCKMEMORY) ||
        isConst?(item,PBItems,:BUGMEMORY) ||
        isConst?(item,PBItems,:GHOSTMEMORY) ||
        isConst?(item,PBItems,:STEELMEMORY) ||
        isConst?(item,PBItems,:FIREMEMORY) ||
        isConst?(item,PBItems,:WATERMEMORY) ||
        isConst?(item,PBItems,:GRASSMEMORY) ||
        isConst?(item,PBItems,:ELECTRICMEMORY) ||
        isConst?(item,PBItems,:PSYCHICMEMORY) ||
        isConst?(item,PBItems,:ICEMEMORY) ||
        isConst?(item,PBItems,:DRAGONMEMORY) ||
        isConst?(item,PBItems,:FAIRYMEMORY) || 
        isConst?(item,PBItems,:DARKMEMORY))
      return true
    end    
    if isConst?(pkmn.species,PBSpecies,:GIRATINA) &&
       isConst?(item,PBItems,:GRISEOUSORB)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GENESECT) &&
       (isConst?(item,PBItems,:SHOCKDRIVE) ||
        isConst?(item,PBItems,:BURNDRIVE) ||
        isConst?(item,PBItems,:CHILLDRIVE) ||
        isConst?(item,PBItems,:DOUSEDRIVE))
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:VENUSAUR) &&
       isConst?(item,PBItems,:VENUSAURITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:CHARIZARD) &&
       (isConst?(item,PBItems,:CHARIZARDITEX) ||
        isConst?(item,PBItems,:CHARIZARDITEY))
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:BLASTOISE) &&
       isConst?(item,PBItems,:BLASTOISINITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:BANETTE) &&
      isConst?(item,PBItems,:BANETTITE)
     return true
   end
   if isConst?(pkmn.species,PBSpecies,:HERACROSS) &&
      isConst?(item,PBItems,:HERACRONITE)
    return true
    end
    if isConst?(pkmn.species,PBSpecies,:ABOMBASNOW) &&
       isConst?(item,PBItems,:ABOMASITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:ABSOL) &&
       isConst?(item,PBItems,:ABSOLITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:AERODACTYL) &&
       isConst?(item,PBItems,:AERODACTYLITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:AGGRON) &&
       isConst?(item,PBItems,:AGGRONITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:ALAKAZAM) &&
       isConst?(item,PBItems,:ALAKAZITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:AMPHAROS) &&
       isConst?(item,PBItems,:AMPHAROSITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:BANETTE) &&
       isConst?(item,PBItems,:BANETTITITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:BLAZIKEN) &&
       isConst?(item,PBItems,:BLAZIKENITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GARCHOMP) &&
       isConst?(item,PBItems,:GARCHOMPITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GARDEVOIR) &&
       isConst?(item,PBItems,:GARDEVOIRITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GENGAR) &&
       isConst?(item,PBItems,:GENGARITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GYARADOS) &&
       isConst?(item,PBItems,:GYARADOSITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:HERACROSS) &&
       isConst?(item,PBItems,:HERACROSSITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:HOUNDOOM) &&
       isConst?(item,PBItems,:HOUNDOOMINITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:KANGASKHAN) &&
       isConst?(item,PBItems,:KANGASKHANITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:LUCARIO) &&
       isConst?(item,PBItems,:LUCARIONITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:MANECTRIC) &&
       isConst?(item,PBItems,:MANECTITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:MAWILE) &&
       isConst?(item,PBItems,:MAWILITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:MEDICHAM) &&
       isConst?(item,PBItems,:MEDICHAMITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:MEWTWO) &&
       (isConst?(item,PBItems,:MEWTWONITEX) ||
        isConst?(item,PBItems,:MEWTWONITEY))
      return true
    end  
    if isConst?(pkmn.species,PBSpecies,:PINSIR) &&
       isConst?(item,PBItems,:PINSIRITE)
      return true
    end  
    if isConst?(pkmn.species,PBSpecies,:SCIZOR) &&
       isConst?(item,PBItems,:SCIZORITE)
      return true
    end  
    if isConst?(pkmn.species,PBSpecies,:TYRANITAR) &&
       isConst?(item,PBItems,:TYRANITARITE)
      return true
    end  
    if isConst?(pkmn.species,PBSpecies,:BEEDRILL) &&
       isConst?(item,PBItems,:BEEDRILLITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:PIDGEOT) &&
       isConst?(item,PBItems,:PIDGEOTITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:SLOWBRO) &&
       isConst?(item,PBItems,:SLOWBRONITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:STEELIX) &&
       isConst?(item,PBItems,:STEELIXITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:SCEPTILE) &&
       isConst?(item,PBItems,:SCEPTILITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:SWAMPERT) &&
       isConst?(item,PBItems,:SWAMPERTITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:SHARPEDO) &&
       isConst?(item,PBItems,:SHARPEDONITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:SABLEYE) &&
       isConst?(item,PBItems,:SABLENITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:CAMERUPT) &&
       isConst?(item,PBItems,:CAMERUPTITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:ALTARIA) &&
       isConst?(item,PBItems,:ALTARIANITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GLALIE) &&
       isConst?(item,PBItems,:GLALITITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:SALAMENCE) &&
       isConst?(item,PBItems,:SALAMENCITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:METAGROSS) &&
       isConst?(item,PBItems,:METAGROSSITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:LOPUNNY) &&
       isConst?(item,PBItems,:LOPUNNITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GALLADE) &&
       isConst?(item,PBItems,:GALLADITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:AUDINO) &&
       isConst?(item,PBItems,:AUDINITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:DIANCIE) &&
       isConst?(item,PBItems,:DIANCITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:SANDACONDA) &&
      isConst?(item,PBItems,:SANDACONDITE)
     return true
   end
    if isConst?(pkmn.species,PBSpecies,:GROUDON) &&
       isConst?(item,PBItems,:REDORB)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:KYOGRE) &&
       isConst?(item,PBItems,:BLUEORB)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:ZACIAN) &&
       isConst?(item,PBItems,:RUSTEDSWORD)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:ZAMAZENTA) &&
       isConst?(item,PBItems,:RUSTEDSHIELD)
      return true
    end
    if isConst?(item,PBItems,:DEMONSTONE)
      return true
    end
    if pkmn.hasCrest?
      return true
    end
    return false
  end


  def pbCheckGlobalAbility(a)
    for i in 0...4 # in order from own first, opposing first, own second, opposing second
      if @battlers[i].ability == getConst(PBAbilities,a)
        return @battlers[i] if @battlers[i].hasWorkingAbility(a)
      end
    end
    return nil
  end

  def SilvallyCheck(mon, type)
    if !isConst?(mon.species,PBSpecies,:SILVALLY)
      return false
    end  
    if mon.is_a? PokeBattle_Battler
      if pbOwnedByPlayer?(mon.index) && !$PokemonBag.pbHasItem?(:SILVCREST) 
        return false
      end
      if type == PBTypes::FIRE && mon.hasWorkingItem(:FIREMEMORY)
        return true
      elsif type == PBTypes::WATER && mon.hasWorkingItem(:WATERMEMORY)
        return true
      elsif type == PBTypes::GRASS && mon.hasWorkingItem(:GRASSMEMORY)
        return true
      elsif type == PBTypes::ELECTRIC && mon.hasWorkingItem(:ELECTRICMEMORY)
        return true
      elsif type == PBTypes::ICE && mon.hasWorkingItem(:ICEMEMORY)
        return true
      elsif type == PBTypes::DRAGON && mon.hasWorkingItem(:DRAGONMEMORY)
        return true
      elsif type == PBTypes::PSYCHIC && mon.hasWorkingItem(:PSYCHICMEMORY)
        return true
      elsif type == PBTypes::DARK && mon.hasWorkingItem(:DARKMEMORY)
        return true
      elsif type == PBTypes::POISON && mon.hasWorkingItem(:POISONMEMORY)
        return true
      elsif type == PBTypes::GHOST && mon.hasWorkingItem(:GHOSTMEMORY)
        return true
      elsif type == PBTypes::FIGHTING && mon.hasWorkingItem(:FIGHTINGMEMORY)
        return true
      elsif type == PBTypes::BUG && mon.hasWorkingItem(:BUGMEMORY)
        return true
      elsif type == PBTypes::FAIRY && mon.hasWorkingItem(:FAIRYMEMORY)
        return true
      elsif type == PBTypes::GROUND && mon.hasWorkingItem(:GROUNDMEMORY)
        return true
      elsif type == PBTypes::ROCK && mon.hasWorkingItem(:ROCKMEMORY)
        return true
      elsif type == PBTypes::STEEL && mon.hasWorkingItem(:STEELMEMORY)
        return true
      end
      # In case no memory
      if type == PBTypes::NORMAL && 
       !(mon.hasWorkingItem(:FIREMEMORY) || mon.hasWorkingItem(:WATERMEMORY) || 
       mon.hasWorkingItem(:GRASSMEMORY) || mon.hasWorkingItem(:ELECTRICMEMORY) || 
       mon.hasWorkingItem(:ICEMEMORY) || mon.hasWorkingItem(:DRAGONMEMORY) || 
       mon.hasWorkingItem(:PSYCHICMEMORY) || mon.hasWorkingItem(:DARKMEMORY) || 
       mon.hasWorkingItem(:POISONMEMORY) || mon.hasWorkingItem(:GHOSTMEMORY) || 
       mon.hasWorkingItem(:FIGHTINGMEMORY) || mon.hasWorkingItem(:BUGMEMORY) ||
       mon.hasWorkingItem(:FAIRYMEMORY) || mon.hasWorkingItem(:GROUNDMEMORY) || 
       mon.hasWorkingItem(:ROCKMEMORY) || mon.hasWorkingItem(:STEELMEMORY))
        return true
      end
    elsif mon.is_a? PokeBattle_Pokemon
      if @party1.include?(mon) && !$PokemonBag.pbHasItem?(:SILVCREST) 
        return false
      end
      if type == PBTypes::FIRE && mon.item == PBItems::FIREMEMORY
        return true
      elsif type == PBTypes::WATER && mon.item == PBItems::WATERMEMORY
        return true
      elsif type == PBTypes::GRASS && mon.item == PBItems::GRASSMEMORY
        return true
      elsif type == PBTypes::ELECTRIC && mon.item == PBItems::ELECTRICMEMORY
        return true
      elsif type == PBTypes::ICE && mon.item == PBItems::ICEMEMORY
        return true
      elsif type == PBTypes::DRAGON && mon.item == PBItems::DRAGONMEMORY
        return true
      elsif type == PBTypes::PSYCHIC && mon.item == PBItems::PSYCHICMEMORY
        return true
      elsif type == PBTypes::DARK && mon.item == PBItems::DARKMEMORY
        return true
      elsif type == PBTypes::POISON && mon.item == PBItems::POISONMEMORY
        return true
      elsif type == PBTypes::GHOST && mon.item == PBItems::GHOSTMEMORY
        return true
      elsif type == PBTypes::FIGHTING && mon.item == PBItems::POISONMEMORY
        return true
      elsif type == PBTypes::BUG && mon.item == PBItems::BUGMEMORY
        return true
      elsif type == PBTypes::FAIRY && mon.item == PBItems::FAIRYMEMORY
        return true
      elsif type == PBTypes::GROUND && mon.item == PBItems::GROUNDMEMORY
        return true
      elsif type == PBTypes::ROCK && mon.item == PBItems::ROCKMEMORY
        return true
      elsif type == PBTypes::STEEL && mon.item == PBItems::STEELMEMORY
        return true
      end
      # In case no memory
      if type == PBTypes::NORMAL && 
       !(mon.hasWorkingItem(:FIREMEMORY) || mon.hasWorkingItem(:WATERMEMORY) || 
       mon.hasWorkingItem(:GRASSMEMORY) || mon.hasWorkingItem(:ELECTRICMEMORY) || 
       mon.hasWorkingItem(:ICEMEMORY) || mon.hasWorkingItem(:DRAGONMEMORY) || 
       mon.hasWorkingItem(:PSYCHICMEMORY) || mon.hasWorkingItem(:DARKMEMORY) || 
       mon.hasWorkingItem(:POISONMEMORY) || mon.hasWorkingItem(:GHOSTMEMORY) || 
       mon.hasWorkingItem(:FIGHTINGMEMORY) || mon.hasWorkingItem(:BUGMEMORY) ||
       mon.hasWorkingItem(:FAIRYMEMORY) || mon.hasWorkingItem(:GROUNDMEMORY) || 
       mon.hasWorkingItem(:ROCKMEMORY) || mon.hasWorkingItem(:STEELMEMORY))
        return true
      end
    end

    return false
  end
  
################################################################################
# Player-related info.
################################################################################
  def pbPlayer
    if @player.is_a?(Array)
      return @player[0]
    else
      return @player
    end
  end

  def pbGetOwnerItems(battlerIndex)
    return [] if !@items
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @items[0] : @items[1]
      else
        return @items
      end
    else
      return []
    end
  end

  def pbSetSeen(pokemon)
    if pokemon && @internalbattle
      self.pbPlayer.seen[pokemon.species]=true
      pbSeenForm(pokemon)
    end
  end

   def pbGetMegaRingName(battlerIndex)
    if pbBelongsToPlayer?(battlerIndex)
      ringsA=[:MEGARING,:MEGABRACELET,:MEGACUFF,:MEGACHARM]
      ringsB=[566]                                          # 566 = Mega Ring.
      for i in ringsA
        next if !hasConst?(PBItems,i)
        for k in ringsB
          return PBItems.getName(k) if $PokemonBag.pbQuantity(k)>0
        end        
      end
    end
    # Add your own Mega objects for particular trainer types here
#    if isConst?(pbGetOwner(battlerIndex).trainertype,PBTrainers,:BUGCATCHER)
#      return _INTL("Mega Net")
#    end
    return _INTL("Mega Ring")
  end  
  
  def pbHasMegaRing(battlerIndex)
    return true if !pbBelongsToPlayer?(battlerIndex)
    rings=[:MEGARING,:MEGABRACELET,:MEGACUFF,:MEGACHARM]
    for i in rings
      next if !hasConst?(PBItems,i)
      return true if $PokemonBag.pbQuantity(i)>0
    end
    return false
  end   
  
  def pbHasZRing(battlerIndex)
    return true if !pbBelongsToPlayer?(battlerIndex)
    rings=[:MEGARING,:MEGABRACELET,:MEGACUFF,:MEGACHARM]
    for i in rings
      next if !hasConst?(PBItems,i)
      return true if $PokemonBag.pbQuantity(i)>0
    end
    return false
  end    
  
################################################################################
# Get party info, manipulate parties.
################################################################################
  def pbPokemonCount(party)
    count=0
    for i in party
      next if !i
      count+=1 if i.hp>0 && !i.isEgg?
    end
    return count
  end

  def pbAllFainted?(party)
    pbPokemonCount(party)==0
  end

  def pbMaxLevelFromIndex(index)
    party=pbParty(index)
    owner=(pbIsOpposing?(index)) ? @opponent : @player
    maxlevel=0
    if owner.is_a?(Array)
      start=0
      limit=pbSecondPartyBegin(index)
      start=limit if pbIsDoubleBattler?(index)
      for i in start...start+limit
        next if !party[i]
        maxlevel=party[i].level if maxlevel<party[i].level
      end
    else
      for i in party
        next if !i
        maxlevel=i.level if maxlevel<i.level
      end
    end
    return maxlevel
  end    
  
  def pbMaxLevel(party)
    lv=0
    for i in party
      next if !i
      lv=i.level if lv<i.level
    end
    return lv
  end

  def pbParty(index)
    return pbIsOpposing?(index) ? party2 : party1
  end

  def pbSecondPartyBegin(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return @fullparty2 ? 6 : 3
    else
      return @fullparty1 ? 6 : 3
    end
  end

  def pbFindNextUnfainted(party,start,finish=-1)
    finish=party.length if finish<0
    for i in start...finish
      next if !party[i]
      return i if party[i].hp>0 && !party[i].isEgg?
    end
    return -1
  end

  def pbFindPlayerBattler(pkmnIndex)
    battler=nil
    for k in 0...4
      if !pbIsOpposing?(k) && @battlers[k].pokemonIndex==pkmnIndex
        battler=@battlers[k]
        break
      end
    end
    return battler
  end

  def pbIsOwner?(battlerIndex,partyIndex)
    secondParty=pbSecondPartyBegin(battlerIndex)
    if !pbIsOpposing?(battlerIndex)
      return true if !@player || !@player.is_a?(Array)
      return (battlerIndex==0) ? partyIndex<secondParty : partyIndex>=secondParty
    else
      return true if !@opponent || !@opponent.is_a?(Array)
      return (battlerIndex==1) ? partyIndex<secondParty : partyIndex>=secondParty
    end
  end

  def pbGetOwner(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @opponent[0] : @opponent[1]
      else
        return @opponent
      end
    else
      if @player.is_a?(Array)
        return (battlerIndex==0) ? @player[0] : @player[1]
      else
        return @player
      end
    end
  end

  def pbGetOwnerPartner(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @opponent[1] : @opponent[0]
      else
        return @opponent
      end
    else
      if @player.is_a?(Array)
        return (battlerIndex==0) ? @player[1] : @player[0]
      else
        return @player
      end
    end
  end

  def pbGetOwnerIndex(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return (@opponent.is_a?(Array)) ? ((battlerIndex==1) ? 0 : 1) : 0
    else
      return (@player.is_a?(Array)) ? ((battlerIndex==0) ? 0 : 1) : 0
    end
  end

  def pbBelongsToPlayer?(battlerIndex)
    if @player.is_a?(Array) && @player.length>1
      return battlerIndex==0
    else
      return (battlerIndex%2)==0
    end
    return false
  end

  def pbPartyGetOwner(battlerIndex,partyIndex)
    secondParty=pbSecondPartyBegin(battlerIndex)
    if !pbIsOpposing?(battlerIndex)
      return @player if !@player || !@player.is_a?(Array)
      return (partyIndex<secondParty) ? @player[0] : @player[1]
    else
      return @opponent if !@opponent || !@opponent.is_a?(Array)
      return (partyIndex<secondParty) ? @opponent[0] : @opponent[1]
    end
  end

  def pbAddToPlayerParty(pokemon)
    party=pbParty(0)
    for i in 0...party.length
      party[i]=pokemon if pbIsOwner?(0,i) && !party[i]
    end
  end

  def pbRemoveFromParty(battlerIndex,partyIndex)
    party=pbParty(battlerIndex)
    side=(pbIsOpposing?(battlerIndex)) ? @opponent : @player
    party[partyIndex]=nil
    if !side || !side.is_a?(Array) # Wild or single opponent
      party.compact!
      for i in battlerIndex...party.length
        for j in 0..3
          next if !@battlers[j]
          if pbGetOwner(j)==side && @battlers[j].pokemonIndex==i
            @battlers[j].pokemonIndex-=1
            break
          end
        end
      end
    else
      if battlerIndex<pbSecondPartyBegin(battlerIndex)-1
        for i in battlerIndex...pbSecondPartyBegin(battlerIndex)
          if i>=pbSecondPartyBegin(battlerIndex)-1
            party[i]=nil
          else
            party[i]=party[i+1]
          end
        end
      else
        for i in battlerIndex...party.length
          if i>=party.length-1
            party[i]=nil
          else
            party[i]=party[i+1]
          end
        end
      end
    end
  end
  
################################################################################
# Check whether actions can be taken.
################################################################################
  def pbCanShowCommands?(idxPokemon)
    thispkmn=@battlers[idxPokemon]
    return false if thispkmn.isFainted?
    return false if thispkmn.effects[PBEffects::TwoTurnAttack]>0
    return false if thispkmn.effects[PBEffects::HyperBeam]>0
    return false if thispkmn.effects[PBEffects::Rollout]>0
    return false if thispkmn.effects[PBEffects::Outrage]>0
    return false if thispkmn.effects[PBEffects::Rage]==true && $fefieldeffect == 24
    return false if thispkmn.effects[PBEffects::Uproar]>0
    return false if thispkmn.effects[PBEffects::Bide]>0
#### KUROTSUNE - 022 - START    
    #return false if thispkmn.effects[PBEffects::SkyDrop]    
#### KUROTSUNE - 022 - END    
    return true
  end
  
  def zMove
    return @zMove
  end  

################################################################################
# Attacking.
################################################################################
  def pbCanShowFightMenu?(idxPokemon)
    thispkmn=@battlers[idxPokemon]
    if !pbCanShowCommands?(idxPokemon)
      return false
    end
    # No moves that can be chosen
    if !pbCanChooseMove?(idxPokemon,0,false) &&
       !pbCanChooseMove?(idxPokemon,1,false) &&
       !pbCanChooseMove?(idxPokemon,2,false) &&
       !pbCanChooseMove?(idxPokemon,3,false)
      return false
    end
    # Encore
    return false if thispkmn.effects[PBEffects::Encore]>0
    return true
  end

  def pbCanChooseMove?(idxPokemon,idxMove,showMessages,sleeptalk=false)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    opp1=thispkmn.pbOpposing1
    opp2=thispkmn.pbOpposing2
    if (thispkmn.hasWorkingAbility(:MOLDBREAKER) || thispkmn.hasWorkingAbility(:TERAVOLT) || thispkmn.hasWorkingAbility(:TURBOBLAZE))
      opp1.moldbroken=true
      opp2.moldbroken=true
    elsif thispkmn.hasWorkingAbility(:CORROSION)
      opp1.corroded=true
      opp2.corroded=true
    else
      opp1.moldbroken=false
      opp2.moldbroken=false  
      opp1.corroded=false
      opp2.corroded=false
    end  
    if !thismove||thismove.id==0
      return false
    end
    if thismove.pp<=0 && thismove.totalpp>0 && !sleeptalk
      if showMessages
        pbDisplayPaused(_INTL("There's no PP left for this move!"))
      end
      return false
    end
    if thispkmn.effects[PBEffects::ChoiceBand]>=0 &&
      (thispkmn.hasWorkingItem(:CHOICEBAND) ||
      thispkmn.hasWorkingItem(:CHOICESPECS) ||
      thispkmn.hasWorkingItem(:CHOICESCARF) ||
      thispkmn.hasWorkingAbility(:GORILLATACTICS))
      hasmove=false
      for i in 0...4
        if thispkmn.moves[i].id==thispkmn.effects[PBEffects::ChoiceBand]
          hasmove=true
          break
        end
      end
      if hasmove && thismove.id!=thispkmn.effects[PBEffects::ChoiceBand]
        if showMessages
          pbDisplayPaused(_INTL("{1} allows the use of only {2}!",
             PBItems.getName(thispkmn.item),
             PBMoves.getName(thispkmn.effects[PBEffects::ChoiceBand])))
        end
        return false
      end
    end
#### KUROTSUNE - 018 - START
    if isConst?(thispkmn.item,PBItems,:ASSAULTVEST) && !(thismove.pbIsPhysical?(thismove.type) || thismove.pbIsSpecial?(thismove.type))
        if showMessages
          pbDisplayPaused(_INTL("{1} doesn't allow use of non-attacking moves!",
             PBItems.getName(thispkmn.item)))
        end
        return false
    end
#### KUROTSUNE - 018 - END
    
    if opp1.effects[PBEffects::Imprison]
      if thismove.id==opp1.moves[0].id ||
         thismove.id==opp1.moves[1].id ||
         thismove.id==opp1.moves[2].id ||
         thismove.id==opp1.moves[3].id
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the sealed {2}!",thispkmn.pbThis,thismove.name))
        end
       #PBDebug.log("[CanChoose][#{opp1.pbThis} has: #{opp1.moves[0].name}, #{opp1.moves[1].name},#{opp1.moves[2].name},#{opp1.moves[3].name}]") if $INTERNAL
        return false
      end
    end
    if opp2.effects[PBEffects::Imprison]
      if thismove.id==opp2.moves[0].id ||
         thismove.id==opp2.moves[1].id ||
         thismove.id==opp2.moves[2].id ||
         thismove.id==opp2.moves[3].id
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the sealed {2}!",thispkmn.pbThis,thismove.name))
        end
        #PBDebug.log("[CanChoose][#{opp2.pbThis} has: #{opp2.moves[0].name}, #{opp2.moves[1].name},#{opp2.moves[2].name},#{opp2.moves[3].name}]") if $INTERNAL
        return false
      end
    end
    if thispkmn.effects[PBEffects::Taunt]>0 && thismove.basedamage==0
      if showMessages
        pbDisplayPaused(_INTL("{1} can't use {2} after the Taunt!",thispkmn.pbThis,thismove.name))
      end
      return false
    end
    if thispkmn.effects[PBEffects::Torment]
      if thismove.id==thispkmn.lastMoveUsed
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the same move in a row due to the torment!",thispkmn.pbThis))
        end
        return false
      end
    end
    if thismove.id==thispkmn.effects[PBEffects::DisableMove] && !sleeptalk
      if showMessages
        pbDisplayPaused(_INTL("{1}'s {2} is disabled!",thispkmn.pbThis,thismove.name))
      end
      return false
    end
    if thispkmn.effects[PBEffects::Encore]>0 && idxMove!=thispkmn.effects[PBEffects::EncoreIndex]
      return false
    end
    return true
  end

  def pbAutoChooseMove(idxPokemon,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    if thispkmn.isFainted?
      @choices[idxPokemon][0]=0
      @choices[idxPokemon][1]=0
      @choices[idxPokemon][2]=nil
      return
    end
    if thispkmn.effects[PBEffects::Encore]>0 && pbCanChooseMove?(idxPokemon,thispkmn.effects[PBEffects::EncoreIndex],false)
      PBDebug.log("[Auto choosing Encore move...]") if $INTERNAL
      @choices[idxPokemon][0]=1    # "Use move"
      @choices[idxPokemon][1]=thispkmn.effects[PBEffects::EncoreIndex] # Index of move
      @choices[idxPokemon][2]=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
      @choices[idxPokemon][3]=-1   # No target chosen yet
      if @doublebattle
        thismove=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
        target=thispkmn.pbTarget(thismove)
        if target==PBTargets::SingleNonUser 
          target=@scene.pbChooseTarget(idxPokemon)
          pbRegisterTarget(idxPokemon,target) if target>=0
        elsif target==PBTargets::UserOrPartner
          target=@scene.pbChooseTarget(idxPokemon)
          pbRegisterTarget(idxPokemon,target) if target>=0 && (target&1)==(idxPokemon&1)
        else 
          target=thispkmn.pbTarget(thismove)
          pbRegisterTarget(idxPokemon,target)
        end
      end
    else
      if !pbIsOpposing?(idxPokemon)
        pbDisplayPaused(_INTL("{1} has no moves left!",thispkmn.name)) if showMessages
      end
      @choices[idxPokemon][0]=1           # "Use move"
      @choices[idxPokemon][1]=-1          # Index of move to be used
      @choices[idxPokemon][2]=@struggle   # Use Struggle
      @choices[idxPokemon][3]=-1          # No target chosen yet
    end
  end

  def pbRegisterMove(idxPokemon,idxMove,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
#### KUROTSUNE - 010 - START
    thispkmn.selectedMove = thismove.id
#### KUROTSUNE - 010 - END
    return false if !pbCanChooseMove?(idxPokemon,idxMove,showMessages)
    @choices[idxPokemon][0]=1         # "Use move"
    @choices[idxPokemon][1]=idxMove   # Index of move to be used
    @choices[idxPokemon][2]=thismove  # PokeBattle_Move object of the move
    @choices[idxPokemon][3]=-1        # No target chosen yet
    return true
  end

  def pbChoseMove?(i,move)
    return false if @battlers[i].isFainted?
    if @choices[i][0]==1 && @choices[i][1]>=0
      choice=@choices[i][1]
      return isConst?(@battlers[i].moves[choice].id,PBMoves,move)
    end
    return false
  end

  def pbChoseMoveFunctionCode?(i,code)
    return false if @battlers[i].isFainted?
    if @choices[i][0]==1 && @choices[i][1]>=0
      choice=@choices[i][1]
      return @battlers[i].moves[choice].function==code
    end
    return false
  end

  def pbRegisterTarget(idxPokemon,idxTarget)
    @choices[idxPokemon][3]=idxTarget   # Set target of move
    return true
  end

# UPDATE 11/23/2013
  # implementing STALL
  def pbPriority(ignorequickclaw = false,megacalc = false)
    return @priority if @usepriority && !megacalc # use stored priority if round isn't over yet (best ged rid of this in gen 8)
    @priority.clear
    priorityarray = []
    # -Move priority take precedence(stored as priorityarray[i][0])
    # -Then Items  (stored as priorityarray[i][1])
    # -Then speed (stored as priorityarray[i][2]) (trick room is applied by just making speed negative.)
    # -The last element is just the battler index (which is otherwise lost when sorting)
    for i in 0..3
      priorityarray[i] =[0,0,0,i] #initializes the array and stores the battler index
      # Move priority
      pri=0
      if @choices[i][0]==1 # Is a move
        pri=@choices[i][2].priority if !@choices[i][2].zmove  #Base move priority
        pri+=1 if (!@battlers[i].abilitynulled && (@battlers[i].ability == PBAbilities::PRANKSTER)) && @choices[i][2].basedamage==0 # Is status move
        pri+=1 if (!@battlers[i].abilitynulled && (@battlers[i].ability == PBAbilities::GALEWINGS)) && @choices[i][2].type==2 && (((@battlers[i].hp == @battlers[i].totalhp) || (($fefieldeffect == 16  || $fefieldeffect == 27 || $fefieldeffect == 28) && @weather == PBWeather::STRONGWINDS)) || $fefieldeffect == 43)
        if (!@battlers[i].abilitynulled && (@battlers[i].ability == PBAbilities::TRIAGE))
          pri+=3 if (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)
        end
        if $fefieldeffect==38 && @choices[i][2].function==0x11E
          pri+=1
        end
        if isConst?(@battlers[i].species,PBSpecies,:FERALIGATR) && isConst?(@battlers[i].item, PBItems, :FERACREST) &&
          (@choices[i][2].pbIsPhysical?(@choices[i][2].type) || @choices[i][2].pbIsSpecial?(@choices[i][2].type)) && @battlers[i].turncount==1
           pri+=2
        end
      end
      priorityarray[i][0]=pri
      #Item/stall priority (all items overwrite stall priority)
      priorityarray[i][1] = -1 if !@battlers[i].abilitynulled && @battlers[i].ability == PBAbilities::STALL 
      priorityarray[i][1] = 1 if @battlers[i].custap || (@battlers[i].itemWorks? && @battlers[i].item == PBItems::QUICKCLAW && (pbRandom(100)<20))
      priorityarray[i][1] = -2 if (@battlers[i].itemWorks? && (@battlers[i].item == PBItems::LAGGINGTAIL || @battlers[i].item == PBItems::FULLINCENSE))
      #speed priority
      priorityarray[i][2]    = @battlers[i].pbSpeed if @trickroom==0
      priorityarray[i][2]    = -@battlers[i].pbSpeed if @trickroom>0
    end
    priorityarray.sort!
    #Speed ties. Only works correctly if two pokemon speed tie
    speedtie = []
    for i in 0..2
      for j in (i+1)..3
        if priorityarray[i][0]==priorityarray[j][0] && priorityarray[i][1]==priorityarray[j][1] && priorityarray[i][2]==priorityarray[j][2]
          if pbRandom(2)==1 
            priorityarray[i],priorityarray[j] = priorityarray[j],priorityarray[i]
          end
        end
      end
    end
    priorityarray.reverse!
    for i in 0..3
      @priority[i] = @battlers[priorityarray[i][3]]
    end
    @usepriority=true
    return @priority
  end
  
##### KUROTSUNE - 011 - START
 # Makes target pokemon move last
  def pbMoveLast(target)
    priorityTarget = pbGetPriority(target)
    priority = @priority
    case priorityTarget
    when 0
      # Opponent has likely already moved
      return false
    when 1
      aux = priority[3]
      priority[3] = target
      priority[1] = aux
      aux = priority[2]
      priority[2] = priority[1]
      priority[1] = aux
      @priority = priority
      return true
    when 2
      aux = priority[2]
      priority[2] = priority[3]
      priority[3] = aux
      @priority = priority
      return true
    when 3
      return false
    end
  end
  
    
  # Makes the second pokemon move after the first.
  def pbMoveAfter(first, second)
    priorityFirst = pbGetPriority(first)
    priority = @priority
    case priorityFirst
    when 0
      if second == priority[1] 
        # Nothing to do here
        return false
      elsif second == priority[2]
        aux = priority[1]
        priority[1] = second
        priority[2] = aux
        @priority = priority
        return true
      elsif second == priority[3]
        aux = priority[1]
        priority[1] = second
        priority[3] = aux
        aux = priority[2]
        priority[2] = priority[3]
        priority[3] = aux
        @priority = priority
        return true
      end
    when 1
      if second == priority[0] || second == priority[2]
        # Nothing to do here
        return false
      elsif second == priority[3]
        aux = priority[2]
        priority[2] = priority[3]
        priority[3] = aux
        @priority = priority
        return true
      end
    when 2
      return false
    when 3
      return false
    end
  end
##### KUROTSUNE - 011 - END

  def pbGetPriority(mon)
    for i in 0..3
      if @priority[i] == mon
        return i
      end
    end
    return -1
  end

  
   def pbClearChoices(index)
    choices[index][0] = -1
    choices[index][1] = -1
    choices[index][2] = -1
    choices[index][3] = -1
  end 
################################################################################
# Switching Pokémon.
################################################################################
  def pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
    if pkmnidxTo>=0
      party=pbParty(idxPokemon)
      return false if pkmnidxTo>=party.length
      return false if !party[pkmnidxTo]
      if party[pkmnidxTo].isEgg?
        pbDisplayPaused(_INTL("An Egg can't battle!")) if showMessages 
        return false
      end
      if !pbIsOwner?(idxPokemon,pkmnidxTo)
        owner=pbPartyGetOwner(idxPokemon,pkmnidxTo)
        pbDisplayPaused(_INTL("You can't switch {1}'s Pokémon with one of yours!",owner.name)) if showMessages 
        return false
      end
      if party[pkmnidxTo].hp<=0
        pbDisplayPaused(_INTL("{1} has no energy left to battle!",party[pkmnidxTo].name)) if showMessages 
        return false
      end   
      if @battlers[idxPokemon].pokemonIndex==pkmnidxTo
        pbDisplayPaused(_INTL("{1} is already in battle!",party[pkmnidxTo].name)) if showMessages 
        return false
      end
      if @battlers[idxPokemon].pbPartner.pokemonIndex==pkmnidxTo
        pbDisplayPaused(_INTL("{1} is already in battle!",party[pkmnidxTo].name)) if showMessages 
        return false
      end
    end
    return true
  end

  def pbCanSwitch?(idxPokemon,pkmnidxTo,showMessages)
    thispkmn=@battlers[idxPokemon]
    return false if !pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
    # UPDATE 11/16/2013
    # Ghost type can now escape from anything
    if thispkmn.pbHasType?(:GHOST) && ($fefieldeffect!=38 || !(thispkmn.pbOpposing1.hasWorkingAbility(:SHADOWTAG) || thispkmn.pbOpposing2.hasWorkingAbility(:SHADOWTAG)) )
      return true
    end
    isOpposing=pbIsOpposing?(idxPokemon)
    party=pbParty(idxPokemon)
    for i in 0...4
      next if isOpposing!=pbIsOpposing?(i)
      if choices[i][0]==2 && choices[i][1]==pkmnidxTo
        pbDisplayPaused(_INTL("{1} has already been selected.",party[pkmnidxTo].name)) if showMessages 
        return false
      end
    end
    return true if thispkmn.hasWorkingItem(:SHEDSHELL)
    # Colosseum Field  
    if $fefieldeffect == 44  
      pbDisplayPaused(_INTL("{1} can't be switched out while on Colosseum Field!",thispkmn.pbThis)) if showMessages  
      return false  
    end
    # Embargo
    if $fefieldeffect==38 && thispkmn.effects[PBEffects::Embargo]>0
      pbDisplayPaused(_INTL("{1} can't be switched out due to Embargo!",thispkmn.pbThis)) if showMessages
      return false
    end
    # Multi-Turn Attacks/Mean Look
    if thispkmn.effects[PBEffects::MultiTurn]>0 || 
       thispkmn.effects[PBEffects::MeanLook]>=0 || 
       (thispkmn.hasWorkingAbility(:MUMMY) && $fefieldeffect==40) || 
       field.effects[PBEffects::FairyLock]==1
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    # Ingrain
    if thispkmn.effects[PBEffects::Ingrain]
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    opp1=thispkmn.pbOpposing1
    opp2=thispkmn.pbOpposing2
    opp=nil
    if thispkmn.pbHasType?(:STEEL)
      opp=opp1 if opp1.hasWorkingAbility(:MAGNETPULL)
      opp=opp2 if opp2.hasWorkingAbility(:MAGNETPULL)
    end
    if !thispkmn.isAirborne?
      opp=opp1 if opp1.hasWorkingAbility(:ARENATRAP)
      opp=opp2 if opp2.hasWorkingAbility(:ARENATRAP)
    end
    if !thispkmn.hasWorkingAbility(:SHADOWTAG)
      opp=opp1 if opp1.hasWorkingAbility(:SHADOWTAG)
      opp=opp2 if opp2.hasWorkingAbility(:SHADOWTAG)
    end
    if opp
      abilityname=PBAbilities.getName(opp.ability)
      pbDisplayPaused(_INTL("{1}'s {2} prevents switching!",opp.pbThis,abilityname)) if showMessages
      # UPDATE 11/16
      # now displays the proper fleeing message iff you are attempting to flee
      # Note: not very elegant, but it should work.
      pbDisplayPaused(_INTL("{1} prevents escaping with {2}!", opp.pbThis, abilityname)) if !showMessages && pkmnidxTo == -1
      return false
    end
    return true
  end

  def pbRegisterSwitch(idxPokemon,idxOther)
    return false if !pbCanSwitch?(idxPokemon,idxOther,false)
    @choices[idxPokemon][0]=2          # "Switch Pokémon"
    @choices[idxPokemon][1]=idxOther   # Index of other Pokémon to switch with
    @choices[idxPokemon][2]=nil
    side=(pbIsOpposing?(idxPokemon)) ? 1 : 0
    owner=pbGetOwnerIndex(idxPokemon)
    if @megaEvolution[side][owner]==idxPokemon
      @megaEvolution[side][owner]=-1
    end
    if @zMove[side][owner]==idxPokemon
      @zMove[side][owner]=-1
    end    
    return true
  end

  def pbCanChooseNonActive?(index)
    party=pbParty(index)
    for i in 0..party.length-1
      return true if pbCanSwitchLax?(index,i,false)
    end
    return false
  end

 def pbJudgeSwitch(favorDraws=false)
    if !favorDraws
      return if @decision>0
      pbJudge()
      return if @decision>0
    else
      return if @decision==5
      pbJudge()
      return if @decision>0
    end
  end
  
  def pbSwitch(favorDraws=false)
    if !favorDraws
      return if @decision>0
      pbJudge()
      return if @decision>0
    else
      return if @decision==5
      pbJudge()
      return if @decision>0
    end
    firstbattlerhp=@battlers[0].hp
    switched=[]
    for index in 0...4
      next if !@doublebattle && pbIsDoubleBattler?(index)
      next if @battlers[index] && !@battlers[index].isFainted?
      next if !pbCanChooseNonActive?(index)
      if !pbOwnedByPlayer?(index)
        if !pbIsOpposing?(index) || (@opponent && pbIsOpposing?(index))
          newenemy=pbSwitchInBetween(index,false,false)
#### JERICHO - 001 - START
            if !pbIsOpposing?(index)
              if isConst?(@party1[newenemy].ability,PBAbilities,:ILLUSION) #ILLUSION
                party3=@party1.find_all {|item| item && !item.egg? && item.hp>0 }
                if party3[@party1.length-1] != @party1[newenemy]
                  illusionpoke = party3[party3.length-1]
                end
              end #ILLUSION
              newname = illusionpoke != nil ? illusionpoke.name : @party1[newenemy].name #ILLUSION
            else
              if isConst?(@party2[newenemy].ability,PBAbilities,:ILLUSION) #ILLUSION
                party3=@party1.find_all {|item| item && !item.egg? && item.hp>0 }
                if party3[@party1.length-1] != @party1[newenemy]
                  illusionpoke = party3[party3.length-1]
                end
              end #ILLUSION
              newname = illusionpoke != nil ? illusionpoke.name : PBSpecies.getName(@party2[newenemy].species) #ILLUSION
            end
#### JERICHO - 001 - END
          opponent=pbGetOwner(index)
          if !@doublebattle && firstbattlerhp>0 && @shiftStyle && @opponent &&
              @internalbattle && pbCanChooseNonActive?(0) && pbIsOpposing?(index) &&
              @battlers[0].effects[PBEffects::Outrage]==0 
#### JERICHO - 001 - START  
              pbDisplayPaused(_INTL("{1} is about to send in {2}.",opponent.fullname,newname)) #ILLUSION              
#### JERICHO - 001 - END                       
            if pbDisplayConfirm(_INTL("Will {1} change Pokémon?",self.pbPlayer.name))
              newpoke=pbSwitchPlayer(0,true,true)
              if newpoke>=0
                pbDisplayBrief(_INTL("{1}, that's enough!  Come back!",@battlers[0].name))
                pbRecallAndReplace(0,newpoke)
                switched.push(0)
              end
            end
          end
          pbRecallAndReplace(index,newenemy)
          switched.push(index)
        end
      elsif @opponent
        newpoke=pbSwitchInBetween(index,true,false)
        pbRecallAndReplace(index,newpoke)
        switched.push(index)
      elsif $game_switches[1500] || $game_switches[290]
        newpoke=pbSwitchInBetween(index,true,false)
        pbRecallAndReplace(index,newpoke)
        switched.push(index)
      else
        switch=false
        if !pbDisplayConfirm(_INTL("Use next Pokémon?")) 
          switch=(pbRun(index,true)<=0)
        else
          switch=true
        end
        if switch
          newpoke=pbSwitchInBetween(index,true,false)
          pbRecallAndReplace(index,newpoke)
          switched.push(index)
        end
      end
    end
    if switched.length>0
      priority=pbPriority
      for i in priority
        i.pbAbilitiesOnSwitchIn(true) if switched.include?(i.index)
      end
    end
  end

  def pbSendOut(index,pokemon)
    @aiMoveMemory[0].clear
    @aiMoveMemory[1].clear if !pbIsOpposing?(index)
    pbSetSeen(pokemon)
    @peer.pbOnEnteringBattle(self,pokemon)
    if !(@battlers[index]==@battlers[1] || @battlers[index]==@battlers[3])
      if @aiAbilityMemory[0][@battlers[index].pokemonIndex].length==0 
        @aiAbilityMemory[0][@battlers[index].pokemonIndex].push(@battlers[index].ability)
      end
    end
    if isConst?(@battlers[index].species,PBSpecies,:MAGCARGO) &&
       isConst?(@battlers[index].item,PBItems,:MAGCREST)
      temp = @battlers[index].defense
      @battlers[index].defense = @battlers[index].speed
      @battlers[index].speed = temp
      @battlers[index].spatk *= 1.1
    end
    if isConst?(@battlers[index].species,PBSpecies,:RELICANTH) &&
       isConst?(@battlers[index].item,PBItems,:RELICREST)
      @battlers[index].attack *= 1.2
      @battlers[index].spdef *= 1.3
    end
    if isConst?(@battlers[index].species,PBSpecies,:ORICORIO) &&
       isConst?(@battlers[index].item,PBItems,:ORICREST)
      @battlers[index].spatk *= 1.25
      @battlers[index].speed *= 1.25
    end
    if isConst?(@battlers[index].species,PBSpecies,:SEVIPER) &&
       isConst?(@battlers[index].item,PBItems,:SEVCREST)
      @battlers[index].speed *= 1.5
    end
    if isConst?(@battlers[index].species,PBSpecies,:COFAGRIGUS) &&
       isConst?(@battlers[index].item,PBItems,:COFCREST)
      @battlers[index].spatk *= 1.25
      @battlers[index].spdef *= 1.25
    end
    if isConst?(@battlers[index].species,PBSpecies,:SKUNKCREST) &&
      isConst?(@battlers[index].item,PBItems,:SKUNCREST)
     @battlers[index].atk *= 1.2
     @battlers[index].spatk *= 1.2
   end
    if isConst?(@battlers[index].species,PBSpecies,:DUSKNOIR) &&
       isConst?(@battlers[index].item,PBItems,:DUSKCREST)
      @battlers[index].attack *= 1.2
    end
#    if isConst?(@battlers[index].species,PBSpecies,:CLAYDOL) &&
#       isConst?(@battlers[index].item,PBItems,:CLAYCREST)
#      @battlers[index].spatk = @battlers[index].defense
#    end
#    if isConst?(@battlers[index].species,PBSpecies,:DEDENNE) &&
#       isConst?(@battlers[index].item,PBItems,:DEDECREST)
#      @battlers[index].attack = @battlers[index].speed
#    end
#    if isConst?(@battlers[index].species,PBSpecies,:TYPHLOSION) &&
#       isConst?(@battlers[index].item,PBItems,:TYPHCREST)
#      @battlers[index].attack = @battlers[index].spatk
#    end
    if isConst?(@battlers[index].species,PBSpecies,:ARIADOS) &&
       isConst?(@battlers[index].item,PBItems,:ARIACREST)
      @battlers[index].speed *= 1.5
    end
    if isConst?(@battlers[index].species,PBSpecies,:INFERNAPE) &&
       isConst?(@battlers[index].item,PBItems,:INFCREST)
      temp1 = @battlers[index].attack
      @battlers[index].attack = @battlers[index].defense
      @battlers[index].defense = temp1
      
      temp2 = @battlers[index].spatk
      @battlers[index].spatk = @battlers[index].spdef
      @battlers[index].spdef = temp2
    end
    if isConst?(@battlers[index].species,PBSpecies,:DELCATTY) &&
       isConst?(@battlers[index].item,PBItems,:DELCREST)
      party = pbParty(index)
      boost = false
      for mon in party
        if !mon || mon==@battlers[index] || mon.hp <= 0
          next
        end
        @battlers[index].attack += (0.1 * mon.attack)
        @battlers[index].defense += (0.1 * mon.defense)
        @battlers[index].speed += (0.1 * mon.speed)
        @battlers[index].spatk += (0.1 * mon.spatk)
        @battlers[index].spdef += (0.1 * mon.spdef)
        boost = true
      end
      if boost
        pbDisplay(_INTL("{1} gained strength from The Power of Friendship!",battlers[index].pbThis))
      end
    end
    if pbIsOpposing?(index)   
      #  in-battle text      
      @scene.pbTrainerSendOut(index,pokemon,@battlers[index])
      if isConst?(@battlers[index].species,PBSpecies,:PHIONE) &&
        isConst?(@battlers[index].item,PBItems,:PHIONECREST)
       @battlers[index].defense *= 1.5
       @battlers[index].spdef *= 1.5
       battlers[index].effects[PBEffects::AquaRing]=true
       pbAnimation(555,battlers[index],nil) # Aqua Ring animation
       pbDisplay(_INTL("{1} surrounded itself with a veil of water!",battlers[index].pbThis))
     end
     if isConst?(@battlers[index].species,PBSpecies,:PROBOPASS) &&
      isConst?(@battlers[index].item,PBItems,:PROBOCREST)
        @battlers[index].effects[PBEffects::MagnetRise]=8
        pbDisplay(_INTL("{1} levitated with the power of its crest!",@battlers[index].pbThis))
    end
    opposing=@battlers[index].pbOppositeOpposing
    if (opposing.hasWorkingAbility(:SHADOWTAG) && $fefieldeffect==40)
      itemname=PBItems.getName(@battlers[index].item)
      pbDisplay(_INTL("{1}'s shadow frisked {2} and found its {3}!",opposing.pbThis,@battlers[index].pbThis(true),itemname))
    end
     if isConst?(@battlers[index].species,PBSpecies,:THIEVUL) &&
      isConst?(@battlers[index].item,PBItems,:THIEVCREST)
        opposing=@battlers[index].pbOppositeOpposing
        if opposing.pbCanReduceStatStage?(PBStats::SPATK)
          opposing.pbReduceStat(PBStats::SPATK,1,true)
        end
        if @battlers[index].pbCanIncreaseStatStage?(PBStats::SPATK)
          @battlers[index].pbIncreaseStat(PBStats::SPATK,1,true)
        end
     end
      # Last Pokemon script; credits to venom12 and HelioAU
      if !@opponent.is_a?(Array)
        trainertext = @opponent
        if isConst?(trainertext.trainertype,PBTrainers,:POKEGANG6)
          if pokemon.name=="Cofagrigus"
            @battlers[1].pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battlers[1].pbIncreaseStatBasic(PBStats::DEFENSE,2)
            @battlers[1].pbIncreaseStatBasic(PBStats::SPDEF,2)
            pbCommonAnimation("StatUp",battlers[1],nil)
            pbDisplayPaused(_INTL("Cofagrigus' Attack, Defense and Sp. Def. rose!"))
          end
        end
        if pbPokemonCount(@party2)==1 || (@doublebattle && pbPokemonCount(@party2)==2)
        # Define any trainers that you want to activate this script below
        # For each defined trainer, add the BELOW section for them
          if isConst?(trainertext.trainertype,PBTrainers,:TRAINER_REN)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("Beginner's luck quickly runs out."))
              @scene.pbHideOpponent 
            elsif $game_variables[226] == 1
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("No... I'm getting pushed back even now?!"))
              @scene.pbHideOpponent
            elsif $game_variables[226] == 2
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("I'm getting beaten down to a pulp, but I'm not out yet! I won't give up!"))
              @scene.pbHideOpponent
            elsif $game_variables[226] == 3
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("I see now why Venam was pushed as far as she was... You're good."))
              @scene.pbHideOpponent
            elsif $game_variables[226] == 6
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("Whatever it takes."))
              @scene.pbHideOpponent   
            elsif $game_variables[226] == 15
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("Am I pushed this far up already?"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:OUTCAST)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("As per usual, you're not making this easy!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_VENAM)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("Who the hell said you could push me like this?"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:TRAINER_AMANDA)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("You know? While we're here let me teach you something neat. If you press the S key, you can inspect the Pokemon currently on the field! Try it out!"))
              @scene.pbHideOpponent 
            elsif $game_variables[226] == 1
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("Two badges don't mean nothin'! I'm not done yet!"))
              @scene.pbHideOpponent 
            elsif $game_variables[226] == 2
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("Wow... Wow! You're still pushing me to my limits?! I'm so impressed!"))
              @scene.pbHideOpponent 
            elsif $game_variables[226] == 3
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("..."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:STUDENT)
            if $game_variables[226] == 2
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("Huff n' puff! I'm not done yet! Check this out!"))
              @scene.pbHideOpponent 
            elsif $game_variables[226] == 4
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("Your stance is all over the place! Move more like this!"))
              @scene.pbHideOpponent          
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_KETA)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("I won't stop until the very end. You get no sympathy from me."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_KETA2)
            if $game_variables[226] == 0
              pbBGMPlay("Battle - Gyms",100,105)
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("This is what it feels like to be at the end? I can almost see her beautiful face..."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:TRAINER_MELIA1)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("Wait... I don't think this is how it was supposed to go."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:XENEXECUTIVE_1)
            if $game_variables[226] == 1
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("You can't be serious? I've only begun your torture! "))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:XENEXECUTIVE_3)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("You think you've won because I'm on my last leg? You're a fuckin' idiot."))
              @scene.pbHideOpponent 
          elsif $game_variables[226] == 1
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("I have the power of the legendary Pokemon Giratina! I will not fall here!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:XENEXECUTIVE_4)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("You're leaving me with no choice. No more holding back!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_NARCISSA)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("My life for the theatre ends at no point. Even when the curtains fall for the final time."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:APPRENTICE)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("Wait, holy crap..."))
              @scene.pbHideOpponent 
           elsif $game_variables[226] == 1
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("This is so frustrating! I want to win damnit!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:ENIGMA)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("You've grown so fast in such a small amount of time. It's remarkable! "))
              @scene.pbHideOpponent       
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_VALARIE)
            if $game_variables[226] == 0 || $game_variables[226] == 1
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("Like at the break of night. The waves grow calm. Does this signify the end?"))
              @scene.pbHideOpponent       
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_CRAWLI)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("Don't you know how hard it is to kill a bug?"))
              @scene.pbHideOpponent      
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_ANGIE)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Evil Gym",100,105)
              pbDisplayPaused(_INTL("You push me this far...? I can't... It's too hot... It's too hot..."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_TEXEN)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("What is your deal?! You almost hit me a few times!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_AMBER)
            if $game_variables[226] == 0 
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("I'm not breakin' a sweat!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_MARIANETTE)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("Everything is counting on this final stretch. Even if you win, he'll never let you go..."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_SPECTOR)
            if $game_variables[226] == 0
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("I use the Pokemon I prefer over what's technically the best. Have you noticed? Well, anyway, it's almost over now."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_FLORA)
            if $game_variables[226] == 0 
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("Are you kidding me? Who said you could turn this around?"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_FLORIN)
            if $game_variables[226] == 0 
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("It seems like I'm being placed in a corner. Funny how things turn south so quickly."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_ERICK)
            if $game_variables[226] == 0 
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("It seems we are starting to have technical difficulties. Please stand by!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_ADAM)
            if $game_variables[226] == 0 
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("THE Adam Might DOESN'T lose! I'm just waiting for my trap card! C'mon!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_SOUTA)
            if $game_variables[226] == 0 
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Gyms",100,105)
              pbDisplayPaused(_INTL("Battle heals an aching soul. Come now, fight 'till your very last breath!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:LEADER_RYLAND)
            if $game_variables[226] == 0 
              @scene.pbShowOpponent(0)
              pbBGMPlay("Battle - Flora",100,105)
              pbDisplayPaused(_INTL("I never would have imagined you'd be this annoying. So disappointing. I should of had you killed earlier."))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:DOCTOR)
            if $game_variables[226] == 0 
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("M-My research... My hard work... I won't let it end with this. I won't disappoint my father!"))
              @scene.pbHideOpponent 
            end
          elsif isConst?(trainertext.trainertype,PBTrainers,:CANDIDGIRL)
            if $game_variables[226] == 0 
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("I did say I wasn't a trainer, right? I'm losing, but... I'm having fun..."))
              @scene.pbHideOpponent 
            elsif $game_variables[226] == 1
              @scene.pbShowOpponent(0)
              pbDisplayPaused(_INTL("The rematch no one asked for. Who's going to win? You or I?"))
              @scene.pbHideOpponent 
            end
          end
        end
        # For each defined trainer, add the ABOVE section for them
      end
    else
      @scene.pbSendOut(index,pokemon)
      opposing=@battlers[index].pbOppositeOpposing
      if (opposing.hasWorkingAbility(:SHADOWTAG) && $fefieldeffect==40)
        itemname=PBItems.getName(@battlers[index].item)
        pbDisplay(_INTL("{1}'s shadow frisked {2} and found its {3}!",opposing.pbThis,@battlers[index].pbThis(true),itemname))
      end
      if isConst?(@battlers[index].species,PBSpecies,:PHIONE) &&
        isConst?(@battlers[index].item,PBItems,:PHIONECREST)
       @battlers[index].defense *= 1.5
       @battlers[index].spdef *= 1.5
       battlers[index].effects[PBEffects::AquaRing]=true
       pbAnimation(555,battlers[index],nil) # Aqua Ring animation
       pbDisplay(_INTL("{1} surrounded itself with a veil of water!",battlers[index].pbThis))
     end
    if isConst?(@battlers[index].species,PBSpecies,:PROBOPASS) &&
      isConst?(@battlers[index].item,PBItems,:PROBOCREST)
        @battlers[index].effects[PBEffects::MagnetRise]=8
        pbDisplay(_INTL("{1} levitated with the power of its crest!",@battlers[index].pbThis))
    end
     if isConst?(@battlers[index].species,PBSpecies,:THIEVUL) &&
      isConst?(@battlers[index].item,PBItems,:THIEVCREST)
        opposing=@battlers[index].pbOppositeOpposing
        if opposing.pbCanReduceStatStage?(PBStats::SPATK)
          opposing.pbReduceStat(PBStats::SPATK,1,true)
        end
        if @battlers[index].pbCanIncreaseStatStage?(PBStats::SPATK)
          @battlers[index].pbIncreaseStat(PBStats::SPATK,1,true)
        end
     end
    end

    @scene.pbResetMoveIndex(index)
  end

  def pbReplace(index,newpoke,batonpass=false)
    party=pbParty(index)
    if pbOwnedByPlayer?(index)
      # Reorder the party for this battle
      bpo=-1; bpn=-1
      for i in 0...6
        bpo=i if @partyorder[i]==@battlers[index].pokemonIndex
        bpn=i if @partyorder[i]==newpoke
      end
      poke1=@partyorder[bpo]
      @partyorder[bpo]=@partyorder[bpn]
      @partyorder[bpn]=poke1
      @battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      pbSendOut(index,party[newpoke])
    else
      @battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      pbSetSeen(party[newpoke])
      if pbIsOpposing?(index)
        pbSendOut(index,party[newpoke])
      else
        pbSendOut(index,party[newpoke])
      end
    end
  end

  def pbRecallAndReplace(index,newpoke,batonpass=false)
    if @battlers[index].effects[PBEffects::Illusion]
      @battlers[index].effects[PBEffects::Illusion] = nil
    end
    if @battlers[index].unburdened
      @battlers[index].unburdened=false
      @battlers[index].speed/=2
    end
    @switchedOut[index] = true
    pbClearChoices(index)
    @battlers[index].pbResetForm
    if !@battlers[index].isFainted?
      @scene.pbRecall(index)
    end
    pbMessagesOnReplace(index,newpoke)
    pbReplace(index,newpoke,batonpass)
    if  @field.effects[PBEffects::WonderRoom] > 0
      if !(@battlers[index].isFainted?)
        if @battlers[index].wonderroom==false
          @battlers[index].pbSwapDefenses
        end
      end
    end
    @scene.partyBetweenKO2(!pbOwnedByPlayer?(index)) unless @doublebattle
    return pbOnActiveOne(@battlers[index])
  end

  def pbMessagesOnReplace(index,newpoke)
    party=pbParty(index)
    if pbOwnedByPlayer?(index)
#     if !party[newpoke]
#       p [index,newpoke,party[newpoke],pbAllFainted?(party)]
#       PBDebug.log([index,newpoke,party[newpoke],"pbMOR"].inspect)
#       for i in 0...party.length
#         PBDebug.log([i,party[i].hp].inspect)
#       end
#       raise BattleAbortedException.new
#     end
#### JERICHO - 001 - start
      if isConst?(party[newpoke].ability,PBAbilities,:ILLUSION) #ILLUSION
        party2=party.find_all {|item| item && !item.egg? && item.hp>0 }
        if party2[party.length-1] != party[newpoke]
          illusionpoke = party[party.length-1]
        end
      end #ILLUSION
      newname = illusionpoke != nil ? illusionpoke.name : party[newpoke].name      
      opposing=@battlers[index].pbOppositeOpposing
      if opposing.hp<=0 || opposing.hp==opposing.totalhp
        pbDisplayBrief(_INTL("Go! {1}!",newname))
      elsif opposing.hp>=(opposing.totalhp/2)
        pbDisplayBrief(_INTL("Do it! {1}!",newname))
      elsif opposing.hp>=(opposing.totalhp/4)
        pbDisplayBrief(_INTL("Go for it, {1}!",newname))
      else
        pbDisplayBrief(_INTL("Your foe's weak!\nGet 'em, {1}!",newname))
      end
#### JERICHO - 001 - END      
    else
#     if !party[newpoke]
#       p [index,newpoke,party[newpoke],pbAllFainted?(party)]
#       PBDebug.log([index,newpoke,party[newpoke],"pbMOR"].inspect)
#       for i in 0...party.length
#         PBDebug.log([i,party[i].hp].inspect)
#       end
#       raise BattleAbortedException.new
#     end
#### JERICHO - 001 - START    
      if isConst?(party[newpoke].ability,PBAbilities,:ILLUSION) #ILLUSION
        party2=party.find_all {|item| item && !item.egg? && item.hp>0 }
        if party2[party.length-1] != party[newpoke]
          illusionpoke = party[party.length-1]
        end
      end #ILLUSION
      if pbIsOpposing?(index)
        newname = illusionpoke != nil ? illusionpoke.name : PBSpecies.getName(party[newpoke].species) #ILLUSION
      else
        newname = illusionpoke != nil ? illusionpoke.name : party[newpoke].name #ILLUSION
      end
      owner=pbGetOwner(index)      
      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",owner.fullname,newname)) #ILLUSION
#### JERICHO - 001 - END      
    end
  end

  def pbSwitchInBetween(index,lax,cancancel)
    if !pbOwnedByPlayer?(index)
      return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      return pbSwitchPlayer(index,lax,cancancel)
    end
  end

  def pbSwitchPlayer(index,lax,cancancel)
    if @debug
      return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      return @scene.pbSwitch(index,lax,cancancel)
    end
  end

################################################################################
# Using an item.
################################################################################
# Uses an item on a Pokémon in the player's party.
  def pbUseItemOnPokemon(item,pkmnIndex,userPkmn,scene)
    pokemon=@party1[pkmnIndex]
    battler=nil
    name=pbGetOwner(userPkmn.index).fullname
    name=pbGetOwner(userPkmn.index).name if pbBelongsToPlayer?(userPkmn.index)
    pbDisplayBrief(_INTL("{1} used the\r\n{2}.",name,PBItems.getName(item)))
    PBDebug.log("[Player used #{PBItems.getName(item)}]")
    ret=false
    if pokemon.isEgg?
      pbDisplay(_INTL("But it had no effect!"))
    else
      for i in 0...4
        if !pbIsOpposing?(i) && @battlers[i].pokemonIndex==pkmnIndex
          battler=@battlers[i]
        end
      end
      ret=ItemHandlers.triggerBattleUseOnPokemon(item,pokemon,battler,scene)
    end
    if !ret && pbBelongsToPlayer?(userPkmn.index)
      if $PokemonBag.pbCanStore?(item)
        $PokemonBag.pbStoreItem(item)
      else
        raise _INTL("Couldn't return unused item to Bag somehow.")
      end
    end
    if ret
      $game_variables[536] += 1
    end
    return ret
  end

# Uses an item on an active Pokémon.
  def pbUseItemOnBattler(item,index,userPkmn,scene)
    PBDebug.log("[Player used #{PBItems.getName(item)}]")
    ret=ItemHandlers.triggerBattleUseOnBattler(item,@battlers[index],scene)
    if !ret && pbBelongsToPlayer?(userPkmn.index)
      if $PokemonBag.pbCanStore?(item)
        $PokemonBag.pbStoreItem(item)
      else
        raise _INTL("Couldn't return unused item to Bag somehow.")
      end
    end
    if ret
      $game_variables[536] += 1
    end
    return ret
  end

  def pbRegisterItem(idxPokemon,idxItem,idxTarget=nil)
    if ItemHandlers.hasUseInBattle(idxItem)
      if idxPokemon==0
        if ItemHandlers.triggerBattleUseOnBattler(idxItem,@battlers[idxPokemon],self)
          ItemHandlers.triggerUseInBattle(idxItem,@battlers[idxPokemon],self)
          if @doublebattle
            @choices[idxPokemon+2][0]=3         # "Use an item"
            @choices[idxPokemon+2][1]=idxItem   # ID of item to be used
            @choices[idxPokemon+2][2]=idxTarget # Index of Pokémon to use item on
          end
        else
          return false
        end
      else
        if ItemHandlers.triggerBattleUseOnBattler(idxItem,@battlers[idxPokemon],self)
          pbDisplay(_INTL("It's impossible to aim without being focused!"))
        end
        return false
      end
    end
    @choices[idxPokemon][0]=3         # "Use an item"
    @choices[idxPokemon][1]=idxItem   # ID of item to be used
    @choices[idxPokemon][2]=idxTarget # Index of Pokémon to use item on
    side=(pbIsOpposing?(idxPokemon)) ? 1 : 0
    owner=pbGetOwnerIndex(idxPokemon)    
    if @megaEvolution[side][owner]==idxPokemon
      @megaEvolution[side][owner]=-1
    end
    if @zMove[side][owner]==idxPokemon
      @zMove[side][owner]=-1
    end    
    return true
  end

  def pbEnemyUseItem(item,battler)
    return 0 if !@internalbattle
    items=pbGetOwnerItems(battler.index)
    return if !items
    opponent=pbGetOwner(battler.index)
    for i in 0...items.length
      if items[i]==item
        items.delete_at(i)
        break
      end
    end
    itemname=PBItems.getName(item)
    pbDisplayBrief(_INTL("{1} used the\r\n{2}!",opponent.fullname,itemname))
    if isConst?(item,PBItems,:POTION)
      battler.pbRecoverHP(20,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:SUPERPOTION)
      battler.pbRecoverHP(60,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:HYPERPOTION)
      battler.pbRecoverHP(120,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:ULTRAPOTION)
      battler.pbRecoverHP(200,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:MOOMOOMILK)
      battler.pbRecoverHP(100,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:CHOCOLATEIC)
      battler.pbRecoverHP(70,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:STRAWBIC)
      battler.pbRecoverHP(90,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:STRAWCAKE)
      battler.pbRecoverHP(150,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:BLUEMIC)
      battler.pbRecoverHP(200,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:MAXPOTION)
      battler.pbRecoverHP(battler.totalhp-battler.hp,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:FRESHWATER)
      battler.pbRecoverHP(30,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:SODAPOP)
      battler.pbRecoverHP(50,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:LEMONADE)
      battler.pbRecoverHP(70,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:ENERGYPOWDER)
      battler.pbRecoverHP(50,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:ENERGYROOT)
      battler.pbRecoverHP(200,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:ORANBERRY)
      battler.pbRecoverHP(10,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:SITRUSBERRY)
      battler.pbRecoverHP(battler.totalhp/4,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:BERRYJUICE)
      battler.pbRecoverHP(20,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:FULLRESTORE)
      fullhp=(battler.hp==battler.totalhp)
      battler.pbRecoverHP(battler.totalhp-battler.hp,true)
      battler.status=0; battler.statusCount=0
      battler.effects[PBEffects::Confusion]=0
      if fullhp
        pbDisplay(_INTL("{1} became healthy!",battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:FULLHEAL)
      battler.status=0; battler.statusCount=0
      battler.effects[PBEffects::Confusion]=0
      pbDisplay(_INTL("{1} became healthy!",battler.pbThis))
    elsif isConst?(item,PBItems,:XATTACK)
      if battler.pbCanIncreaseStatStage?(PBStats::ATTACK)
        battler.pbIncreaseStat(PBStats::ATTACK,2,true)
      end
    elsif isConst?(item,PBItems,:XDEFEND)
      if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE)
        battler.pbIncreaseStat(PBStats::DEFENSE,2,true)
      end
    elsif isConst?(item,PBItems,:XSPEED)
      if battler.pbCanIncreaseStatStage?(PBStats::SPEED)
        battler.pbIncreaseStat(PBStats::SPEED,2,true)
      end
    elsif isConst?(item,PBItems,:XSPECIAL)
      if battler.pbCanIncreaseStatStage?(PBStats::SPATK)
        battler.pbIncreaseStat(PBStats::SPATK,2,true)
      end
    elsif isConst?(item,PBItems,:XSPDEF)
      if battler.pbCanIncreaseStatStage?(PBStats::SPDEF)
        battler.pbIncreaseStat(PBStats::SPDEF,2,true)
      end
    elsif isConst?(item,PBItems,:XACCURACY)
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY)
        battler.pbIncreaseStat(PBStats::ACCURACY,2,true)
      end
    elsif isConst?(item,PBItems,:REVIVE)
#      battler.hp=(battler.totalhp/2).floor
      pbDisplay(_INTL("{1} revived a fainted Pokémon!",opponent.fullname))
    elsif isConst?(item,PBItems,:MAXREVIVE) || isConst?(item,PBItems,:REVIVALHERB)
#      battler.hp=battler.totalhp
      pbDisplay(_INTL("{1} revived a fainted Pokémon!",opponent.fullname))
    elsif isConst?(item,PBItems,:SACREDASH)
#      party=pbParty(1)
#      for j in 0...party.length
#        party[j].hp=party[j].totalhp if party[j].isFainted?
#      end
      pbDisplay(_INTL("{1} revived all fainted Pokémon!",opponent.fullname))
    end
  end

################################################################################
# Fleeing from battle.
################################################################################
  def pbCanRun?(idxPokemon)
    return false if @opponent
    thispkmn=@battlers[idxPokemon]
    return true if thispkmn.hasWorkingItem(:SMOKEBALL)
    return true if thispkmn.hasWorkingAbility(:RUNAWAY)
    return pbCanSwitch?(idxPokemon,-1,false)
  end

  def pbRun(idxPokemon,duringBattle=false)
    thispkmn=@battlers[idxPokemon]
    if pbIsOpposing?(idxPokemon)
      return 0 if @opponent
      @choices[i][0]=5 # run
      @choices[i][1]=0 
      @choices[i][2]=nil
      return -1
    end
    if @opponent || $game_switches[1500]
      if $DEBUG && Input.press?(Input::CTRL)
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision=1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision=2
          return 1
        end
      elsif @internalbattle && $game_switches[1500]==false
        #        pbDisplayPaused(_INTL("No! There's no running from a Trainer battle!"))
        if pbDisplayConfirm(_INTL("Would you like to forfeit the battle?"))
          pbDisplay(_INTL("{1} forfeited the match!",self.pbPlayer.name))
          @decision=2
          return 1
        end
      elsif $game_switches[1500]
        pbDisplayPaused(_INTL("No!  There's no running from this battle!"))
      elsif pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
        pbSEPlay("Battle flee")
        pbDisplay(_INTL("{1} forfeited the match!",self.pbPlayer.name))
        @decision=3
        return 1
      end
      return 0
    end
    if $DEBUG && Input.press?(Input::CTRL)
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
      return 1
    end
    if @cantescape
      pbDisplayPaused(_INTL("Can't escape!"))
      return 0
    end
  if !$game_switches[1379] # Anti-running away switch.
    if thispkmn.pbHasType?(:GHOST) 
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
      return 1
    end
    if thispkmn.hasWorkingItem(:SMOKEBALL) 
      pbSEPlay("Battle flee")
      if duringBattle
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbDisplayPaused(_INTL("{1} fled using its {2}!",thispkmn.pbThis,PBItems.getName(thispkmn.item)))
      end
      @decision=3
      return 1
    end
    if thispkmn.hasWorkingAbility(:RUNAWAY)
      pbSEPlay("Battle flee")
      if duringBattle
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbDisplayPaused(_INTL("{1} fled using Run Away!",thispkmn.pbThis))
      end
      @decision=3
      return 1
    end
  end
    if !duringBattle && !pbCanSwitch?(idxPokemon,-1,false) # TODO: Use real messages
      pbDisplayPaused(_INTL("Can't escape!"))
      return 0
    end
    # Note: not pbSpeed, because using unmodified Speed
    speedPlayer=@battlers[idxPokemon].speed
    opposing=@battlers[idxPokemon].pbOppositeOpposing
    if opposing.isFainted?
      opposing=opposing.pbPartner
    end
    if !opposing.isFainted?
      speedEnemy=opposing.speed
      if speedPlayer>speedEnemy
        rate=256 
      else
        speedEnemy=1 if speedEnemy<=0
        rate=speedPlayer*128/speedEnemy
        rate+=@runCommand*30
        rate&=0xFF
      end
    else
      rate=256
    end
    ret=1
    if pbAIRandom(256)<rate && !$game_switches[1379] # Anti-running away switch.
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
    else
      pbDisplayPaused(_INTL("Can't escape!"))
      ret=-1
    end
    if !duringBattle
      @runCommand+=1
    end
    return ret
  end

################################################################################
# Mega Evolve battler.
################################################################################
  def pbCanMegaEvolve?(index)
    return false if $game_switches[NO_MEGA_EVOLUTION]
    if !(@battlers[index].isMega?)
      @battlers[index].hasmegad=false
    end
    return false if @battlers[index].hasmegad
    return false if (@battlers[index].isMega? && @battlers[index].hasmegad)
    return false if !@battlers[index].hasMega? 
    return false if !pbHasMegaRing(index)
    if !@battlers[index].premega 
     side=(pbIsOpposing?(index)) ? 1 : 0
     owner=pbGetOwnerIndex(index)
     return false if @megaEvolution[side][owner]!=-1
    end  
    return true
  end

  def pbRegisterMegaEvolution(index)
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @megaEvolution[side][owner]=index
    if !pbIsOpposing?(index)
      @battlers[index].effects[PBEffects::WillMega]=true
    end
  end
  
  def pbCanMegaEvolveAI?(i,index)
    return false if $game_switches[NO_MEGA_EVOLUTION]
    return false if !i.hasMegaForm? 
    #return false if i.hasmegad
    return false if !pbHasMegaRing(index)
    side=1
    owner=pbGetOwnerIndex(index)
    if !i.premega 
      return false if @megaEvolution[side][owner]!=-1
    end
    return true
  end

  #def pbCanMegaEvolveAI?(i,index)
  #  return false if !i.hasMega?
  #  side=1
  #  owner=pbGetOwnerIndex(index)
  #  return false if @megaEvolution[side][owner]!=-1
  #  return true
  #end
  
  def pbMegaEvolve(index)
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasMega? rescue false)
    return if (@battlers[index].hasmegad)
    return if (@battlers[index].isMega?)
    ownername=pbGetOwner(index).fullname
    ownername=pbGetOwner(index).name if pbBelongsToPlayer?(index)
    if $game_switches[987] && @battlers[index].item==531
      pbDisplay(_INTL("{1}'s {2} is reacting with its soul!",
       @battlers[index].pbThis,
       PBItems.getName(@battlers[index].item),
       ownername))
#### KUROTSUNE - 005 - START
    elsif isConst?(@battlers[index].species, PBSpecies, :RAYQUAZA)
      pbDisplay(_INTL("{1}'s fervent wish has reached {2}!",ownername,@battlers[index].pbThis))        
#### KUROTSUNE - 005 - END
    elsif ($Trainer.numbadges>=12 && $game_variables[200] == 2) && !pbBelongsToPlayer?(index) # Intense Mode only. Allows for enemy megas to hold an item and still Mega Evolve.
      pbDisplay(_INTL("{1} is reacting to {2}'s {3}!",@battlers[index].pbThis,ownername,pbGetMegaRingName(index)))        
    else
      pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!",@battlers[index].pbThis,PBItems.getName(@battlers[index].item),ownername,pbGetMegaRingName(index)))
    end    
    if $game_switches[987] && @battlers[index].item==531
      pbCommonAnimation("PulseEvolution",@battlers[index],nil)
    else
      pbCommonAnimation("MegaEvolution",@battlers[index],nil)
    end
    wonderroom= @field.effects[PBEffects::WonderRoom]!=0
    @battlers[index].pokemon.makeMega
    @battlers[index].form=@battlers[index].pokemon.form
    @battlers[index].pbUpdate(true,wonderroom)
    @scene.pbChangePokemon(@battlers[index],@battlers[index].pokemon)
    meganame=@battlers[index].pokemon.megaName
    if !meganame || meganame==""
      meganame=_INTL("Mega {1}",PBSpecies.getName(@battlers[index].pokemon.species))
    end
    if $game_switches[987] && @battlers[index].item==531
      pbDisplay(_INTL("{1} was corrupted into {2}!",@battlers[index].pbThis,meganame))
    else
      pbDisplay(_INTL("{1} Mega Evolved into {2}!",@battlers[index].pbThis,meganame))
    end     
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @megaEvolution[side][owner]=-2
#### KUROTSUNE - 006 - START
    @battlers[index].pbAbilitiesOnSwitchIn(true,true)
    @battlers[index].effects[PBEffects::WillMega]=false
    @battlers[index].hasmegad=true
    #@battlers[index].wonderroom=false
#### KUROTSUNE - 006 - END
    if !pbBelongsToPlayer?(index) && @bossfight &&
     isBossPokemonInRiftForm?(@battlers[index]) && 
     !(@shieldCount>=0 || @shieldSetup>=0)
      @battlers[index].isBoss = true
      @shieldSetup = 1
      @shieldCount = $game_variables[704]
      @scene.pbUpdateShield(@shieldCount, index)
    end
end


################################################################################
# Use Z-Move.
################################################################################
  def pbCanZMove?(index)
    return false if $game_switches[NO_Z_MOVE]
    return false if !@battlers[index].hasZMove? 
    return false if !pbHasZRing(index) 
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    if @zMove[side][owner]!=-1 
      if (@zMove[side][owner]>=0 && @zMove[side][owner]==index)
        return true
      else
        return false
      end
    end
    return true
  end

  def pbRegisterZMove(index,movessetup=false)
    if movessetup==true
      $backuparray=[]
      if pbBelongsToPlayer?(index)
        for i in 0...4
          $backuparray.push(@battlers[index].moves[i])
          if @battlers[index].pbCompatibleZMoveFromMove?(@battlers[index].moves[i])
            @battlers[index].moves[i]=PokeBattle_ZMoves.new(self,@battlers[index],@battlers[index].moves[i],@battlers[index].item,false,true,i)  
          end
        end
        return $backuparray
      end
    end
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @zMove[side][owner]=index
  end

  def pbUseZMove(index,move,crystal,moveindex)
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasZMove? rescue false)
    ownername=pbGetOwner(index).fullname
    ownername=pbGetOwner(index).name if pbBelongsToPlayer?(index)
    pbDisplay(_INTL("{1} surrounded itself with its Z-Power!",@battlers[index].pbThis))         
    pbCommonAnimation("ZPower",@battlers[index],nil)               
    PokeBattle_ZMoves.new(self,@battlers[index],move,crystal,false,false,moveindex)  
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)   
    @zMove[side][owner]=-2
end


################################################################################
# Call battler.
################################################################################
  def pbCall(index)
    owner=pbGetOwner(index)
    pbDisplay(_INTL("{1} called {2}!",owner.name,@battlers[index].name))
    pbDisplay(_INTL("{1}!",@battlers[index].name))
    if @battlers[index].isShadow?
      if @battlers[index].inHyperMode?
        @battlers[index].pokemon.hypermode=false
        @battlers[index].pokemon.adjustHeart(-300)
        pbDisplay(_INTL("{1} came to its senses from the Trainer's call!",@battlers[index].pbThis))
      else
        pbDisplay(_INTL("But nothing happened!"))
      end
    elsif @battlers[index].status!=PBStatuses::SLEEP &&
          @battlers[index].pbCanIncreaseStatStage?(PBStats::ACCURACY)
      @battlers[index].pbIncreaseStat(PBStats::ACCURACY,1,true)
    else
      pbDisplay(_INTL("But nothing happened!"))
    end
  end

################################################################################
# Gaining Experience.
################################################################################
  def pbGainEXP
    return if !@internalbattle
    return if $game_switches[1075]
    successbegin=true
    for i in 0...4 # Not ordered by priority
      if !@doublebattle && pbIsDoubleBattler?(i)
        @battlers[i].participants=[]
        next
      end
      if pbIsOpposing?(i) && @battlers[i].participants.length>0 &&
         @battlers[i].isFainted?
        haveexpall=(hasConst?(PBItems,:EXPALL) && $PokemonBag.pbHasItem?(:EXPALL))
        # First count the number of participants
        partic=0
        expshare=0
        for j in @battlers[i].participants
          next if !@party1[j] || !pbIsOwner?(0,j)
          partic+=1 if @party1[j].hp>0 && !@party1[j].isEgg?
        end
        if !haveexpall
          for j in 0...@party1.length
            next if !@party1[j] || !pbIsOwner?(0,j)
            expshare+=1 if @party1[j].hp>0 && !@party1[j].isEgg? && 
                           (isConst?(@party1[j].item,PBItems,:EXPSHARE) ||
                           isConst?(@party1[j].itemInitial,PBItems,:EXPSHARE))
          end
        end
        # Now calculate EXP for the participants
        if partic>0 || expshare>0 || haveexpall
          if !@opponent && successbegin && pbAllFainted?(@party2)
            @scene.pbWildBattleSuccess
            successbegin=false
          end
          for j in 0...@party1.length
            next if !@party1[j] || !pbIsOwner?(0,j)
            next if @party1[j].hp<=0 || @party1[j].isEgg?
            haveexpshare=(isConst?(@party1[j].item,PBItems,:EXPSHARE) ||
                          isConst?(@party1[j].itemInitial,PBItems,:EXPSHARE))
            next if !haveexpshare && !@battlers[i].participants.include?(j)
            pbGainExpOne(j,@battlers[i],partic,expshare,haveexpall)
          end
          if haveexpall
            showmessage=true
            for j in 0...@party1.length
              next if !@party1[j] || !pbIsOwner?(0,j)
              next if @party1[j].hp<=0 || @party1[j].isEgg?
              next if isConst?(@party1[j].item,PBItems,:EXPSHARE) ||
                      isConst?(@party1[j].itemInitial,PBItems,:EXPSHARE)
              next if @battlers[i].participants.include?(j)
              pbDisplay(_INTL("The rest of your team gained Exp. Points thanks to the Exp. All!")) if showmessage
              showmessage=false
              pbGainExpOne(j,@battlers[i],partic,expshare,haveexpall,false)
            end
          end
        end
        # Now clear the participants array
        @battlers[i].participants=[]
      end
    end
  end

  def pbGainExpOne(index,defeated,partic,expshare,haveexpall,showmessages=true)
    thispoke=@party1[index]
    # Original species, not current species
    level=defeated.level
    baseexp=defeated.pokemon.baseExp
    evyield=defeated.pokemon.evYield
    # Gain effort value points, using RS effort values
    totalev=0
    for k in 0...6
      totalev+=thispoke.ev[k]
    end
    for k in 0...6
      evgain=evyield[k]
      evgain*=2 if isConst?(thispoke.item,PBItems,:MACHOBRACE) ||
                   isConst?(thispoke.itemInitial,PBItems,:MACHOBRACE)
      case k
      when PBStats::HP
        evgain+=8 if isConst?(thispoke.item,PBItems,:POWERWEIGHT) ||
                     isConst?(thispoke.itemInitial,PBItems,:POWERWEIGHT)
      when PBStats::ATTACK
        evgain+=8 if isConst?(thispoke.item,PBItems,:POWERBRACER) ||
                     isConst?(thispoke.itemInitial,PBItems,:POWERBRACER)
      when PBStats::DEFENSE
        evgain+=8 if isConst?(thispoke.item,PBItems,:POWERBELT) ||
                     isConst?(thispoke.itemInitial,PBItems,:POWERBELT)
      when PBStats::SPATK
        evgain+=8 if isConst?(thispoke.item,PBItems,:POWERLENS) ||
                     isConst?(thispoke.itemInitial,PBItems,:POWERLENS)
      when PBStats::SPDEF
        evgain+=8 if isConst?(thispoke.item,PBItems,:POWERBAND) ||
                     isConst?(thispoke.itemInitial,PBItems,:POWERBAND)
      when PBStats::SPEED
        evgain+=8 if isConst?(thispoke.item,PBItems,:POWERANKLET) ||
                     isConst?(thispoke.itemInitial,PBItems,:POWERANKLET)
      end
      evgain*=2 if thispoke.pokerusStage>=1 # Infected or cured
      if evgain>0
        # Can't exceed overall limit
        evgain-=totalev+evgain-510 if totalev+evgain>510
        # Can't exceed stat limit
        evgain-=thispoke.ev[k]+evgain-252 if thispoke.ev[k]+evgain>252
        # Add EV gain
        thispoke.ev[k]+=evgain
        if thispoke.ev[k]>252
          "Single-stat EV limit 252 exceeded.\r\nStat: #{k}  EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
          thispoke.ev[k]=252
        end
        totalev+=evgain
        if totalev>510
          print "EV limit 510 exceeded.\r\nTotal EVs: #{totalev} EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
        end
      end
    end
    # Gain experience
    ispartic=0
    ispartic=1 if defeated.participants.include?(index)
    haveexpshare=(isConst?(thispoke.item,PBItems,:EXPSHARE) ||
                  isConst?(thispoke.itemInitial,PBItems,:EXPSHARE)) ? 1 : 0
    exp=0
    if expshare>0
      if partic==0 # No participants, all Exp goes to Exp Share holders
        exp=(level*baseexp).floor
        exp=(exp/(NOSPLITEXP ? 1 : expshare)).floor*haveexpshare
      else
        if NOSPLITEXP
          exp=(level*baseexp).floor*ispartic
          exp=(level*baseexp/2).floor*haveexpshare if ispartic==0
        else
          exp=(level*baseexp/2).floor
          exp=(exp/partic).floor*ispartic + (exp/expshare).floor*haveexpshare
        end
      end
    elsif ispartic==1
      if haveexpall
        exp=(level*baseexp/(NOSPLITEXP ? 1 : partic)).floor
      else
        exp=(level*baseexp/(NOSPLITEXP ? 1 : partic)).floor
      end
    elsif haveexpall
      exp=((level*baseexp)/3).floor
    end
    return if exp<=0
    exp=(exp*3/2).floor if @opponent
    if USENEWEXPFORMULA # Use new (Gen 5) Exp. formula
      exp=(exp/6).floor
      leveladjust=(2*level+10.0)/(level+thispoke.level+10.0)
      leveladjust=leveladjust**5
      leveladjust=Math.sqrt(leveladjust)
      exp=(exp*leveladjust).floor
      exp+=1 if ispartic>0 || haveexpshare>0 || haveexpall
    else                  # Use old (Gen 1-4) Exp. formula
      exp=(exp/7).floor
    end
    isOutsider=((thispoke.trainerID != self.pbPlayer.id && thispoke.trainerID != 0) ||
               (thispoke.language!=0 && thispoke.language!=self.pbPlayer.language))
    if isOutsider
      if thispoke.language!=0 && thispoke.language!=self.pbPlayer.language
        exp=(exp*1.5).floor
      else
        exp=(exp*1.2).floor
      end
    end
    exp=(exp*3/2).floor if isConst?(thispoke.item,PBItems,:LUCKYEGG) ||
                           isConst?(thispoke.itemInitial,PBItems,:LUCKYEGG)
    growthrate=thispoke.growthrate
#### SARDINES - LevelLimiter - START
    result = LevelLimitExpGain(thispoke, exp)
    if result == -1
      exp = 0
    else
      exp = result
    end
#### SARDINES - LevelLimiter - END
    newexp=PBExperience.pbAddExperience(thispoke.exp,exp,growthrate)
    exp=newexp-thispoke.exp
    if exp>0
#### KUROTSUNE - 020 - START
      if isOutsider || isConst?(thispoke.item,PBItems,:LUCKYEGG)
#### KUROTSUNE - 020 - END
        pbDisplay(_INTL("{1} gained a boosted {2} Exp. Points!",thispoke.name,exp))
      elsif !(ispartic==0 && haveexpall)
        pbDisplay(_INTL("{1} gained {2} Exp. Points!",thispoke.name,exp))
      end
      newlevel=PBExperience.pbGetLevelFromExperience(newexp,growthrate)
      tempexp=0
      curlevel=thispoke.level
      if newlevel<curlevel
        debuginfo="#{thispoke.name}: #{thispoke.level}/#{newlevel} | #{thispoke.exp}/#{newexp} | gain: #{exp}"
        raise RuntimeError.new(_INTL("The new level ({1}) is less than the Pokémon's\r\ncurrent level ({2}), which shouldn't happen.\r\n[Debug: {3}]",
                               newlevel,curlevel,debuginfo))
        return
      end
      if thispoke.respond_to?("isShadow?") && thispoke.isShadow?
        thispoke.exp+=exp
      else
        tempexp1=thispoke.exp
        tempexp2=0
        # Find battler
        battler=pbFindPlayerBattler(index)
        loop do
          # EXP Bar animation
          startexp=PBExperience.pbGetStartExperience(curlevel,growthrate)
          endexp=PBExperience.pbGetStartExperience(curlevel+1,growthrate)
          tempexp2=(endexp<newexp) ? endexp : newexp
          thispoke.exp=tempexp2
          @scene.pbEXPBar(thispoke,battler,startexp,endexp,tempexp1,tempexp2)
          tempexp1=tempexp2
          curlevel+=1
          if curlevel>newlevel
            thispoke.calcStats 
            battler.pbUpdate(false) if battler
            @scene.pbRefresh
            break
          end
          thispoke.poklevel = curlevel
          oldtotalhp=thispoke.totalhp
          oldattack=thispoke.attack
          olddefense=thispoke.defense
          oldspeed=thispoke.speed
          oldspatk=thispoke.spatk
          oldspdef=thispoke.spdef
          if battler && battler.pokemon && @internalbattle
            battler.pokemon.changeHappiness("level up",true)
          end
          thispoke.calcStats
          battler.pbUpdate(false) if battler
          @scene.pbRefresh
          pbDisplayPaused(_INTL("{1} grew to Level {2}!",thispoke.name,curlevel))
          @scene.pbLevelUp(thispoke,battler,oldtotalhp,oldattack,
                           olddefense,oldspeed,oldspatk,oldspdef)
          # Finding all moves learned at this level
          movelist=thispoke.getMoveList
          for k in movelist
            if k[0]==thispoke.level   # Learned a new move
              pbLearnMove(index,k[1])
            end
          end
        end
      end
    end
  end

################################################################################
# Learning a move.
################################################################################
  def pbLearnMove(pkmnIndex,move)
    pokemon=@party1[pkmnIndex]
    return if !pokemon
    pkmnname=pokemon.name
    battler=pbFindPlayerBattler(pkmnIndex)
    movename=PBMoves.getName(move)
    for i in 0...4
      if pokemon.moves[i].id==move
        return
      end
      if pokemon.moves[i].id==0
        pokemon.moves[i]=PBMove.new(move)
        battler.moves[i]=PokeBattle_Move.pbFromPBMove(self,pokemon.moves[i],battler) if battler
        pbDisplayPaused(_INTL("{1} learned {2}!",pkmnname,movename))
        return
      end
    end
    loop do
      pbDisplayPaused(_INTL("{1} is trying to learn {2}.",pkmnname,movename))
      pbDisplayPaused(_INTL("But {1} can't learn more than four moves.",pkmnname))
      if pbDisplayConfirm(_INTL("Delete a move to make room for {1}?",movename))
        pbDisplayPaused(_INTL("Which move should be forgotten?"))
        forgetmove=@scene.pbForgetMove(pokemon,move)
        if forgetmove >=0
          oldmovename=PBMoves.getName(pokemon.moves[forgetmove].id)
          pokemon.moves[forgetmove]=PBMove.new(move) # Replaces current/total PP
          battler.moves[forgetmove]=PokeBattle_Move.pbFromPBMove(self,pokemon.moves[forgetmove],battler) if battler
          pbDisplayPaused(_INTL("1,  2, and... ... ..."))
          pbDisplayPaused(_INTL("Poof!"))
          pbDisplayPaused(_INTL("{1} forgot {2}.",pkmnname,oldmovename))
          pbDisplayPaused(_INTL("And..."))
          pbDisplayPaused(_INTL("{1} learned {2}!",pkmnname,movename))
          return
        elsif pbDisplayConfirm(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
          pbDisplayPaused(_INTL("{1} did not learn {2}.",pkmnname,movename))
          return
        end
      elsif pbDisplayConfirm(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
        pbDisplayPaused(_INTL("{1} did not learn {2}.",pkmnname,movename))
        return
      end
    end
  end

################################################################################
# Abilities.
################################################################################
  def pbOnActiveAll
    for i in 0...4 # Currently unfainted participants will earn EXP even if they faint afterwards
      @battlers[i].pbUpdateParticipants if pbIsOpposing?(i)
      @amuletcoin=true if !pbIsOpposing?(i) &&
                          (isConst?(@battlers[i].item,PBItems,:AMULETCOIN) ||
                           isConst?(@battlers[i].item,PBItems,:LUCKINCENSE))
    end
    for i in 0...4
      if !@battlers[i].isFainted?
        if @battlers[i].isShadow? && pbIsOpposing?(i)
          pbCommonAnimation("Shadow",@battlers[i],nil)
          pbDisplay(_INTL("Oh!\nA Shadow Pokemon!"))
        end
      end
      if !@battlers[i].isFainted?
        @battlers[i].pbCheckFormRoundEnd   
      end
    end
    # Weather-inducing abilities, Trace, Imposter, etc.
    @usepriority=false
    priority=pbPriority
    for i in priority
      i.pbAbilitiesOnSwitchIn(true)
    end
    # Check forms are correct
    for i in 0...4
      next if @battlers[i].isFainted?
      @battlers[i].pbCheckForm
    end
  end

  def pbOnActiveOne(pkmn,onlyabilities=false)
    return false if pkmn.isFainted?
    if !onlyabilities
      for i in 0...4 # Currently unfainted participants will earn EXP even if they faint afterwards
        @battlers[i].pbUpdateParticipants if pbIsOpposing?(i)
        @amuletcoin=true if !pbIsOpposing?(i) &&
                            (isConst?(@battlers[i].item,PBItems,:AMULETCOIN) ||
                             isConst?(@battlers[i].item,PBItems,:LUCKINCENSE))
      end
      if pkmn.isShadow? && pbIsOpposing?(pkmn.index)
        pbCommonAnimation("Shadow",pkmn,nil)
        pbDisplay(_INTL("Oh!\nA Shadow Pokemon!"))
      end
      # Healing Wish
      if pkmn.effects[PBEffects::HealingWish]
        pkmn.pbRecoverHP(pkmn.totalhp,true)
        pkmn.status=0
        pkmn.statusCount=0
        pkmn.pbIncreaseStat(PBStats::ATTACK, 1, true) if $fefieldeffect == 31 || $fefieldeffect == 34
        pkmn.pbIncreaseStat(PBStats::SPATK, 1, true) if $fefieldeffect == 31 || $fefieldeffect == 34
        pbDisplayPaused(_INTL("The healing wish came true for {1}!",pkmn.pbThis(true)))
        pkmn.effects[PBEffects::HealingWish]=false
      end
      # Lunar Dance
      if pkmn.effects[PBEffects::LunarDance]
        pkmn.pbRecoverHP(pkmn.totalhp,true)
        pkmn.status=0
        pkmn.statusCount=0
        pkmn.pbIncreaseStat(PBStats::ATTACK, 1, true) if $fefieldeffect == 35 || $fefieldeffect == 34
        pkmn.pbIncreaseStat(PBStats::DEFENSE, 1, true) if $fefieldeffect == 35 
        pkmn.pbIncreaseStat(PBStats::SPATK, 1, true) if $fefieldeffect == 35 || $fefieldeffect == 34
        pkmn.pbIncreaseStat(PBStats::SPDEF, 1, true) if $fefieldeffect == 35 
        pkmn.pbIncreaseStat(PBStats::SPEED, 1, true) if $fefieldeffect == 35
        pkmn.pbIncreaseStat(PBStats::ACCURACY, 1, true) if $fefieldeffect == 35
        pkmn.pbIncreaseStat(PBStats::EVASION, 1, true) if $fefieldeffect == 35
        for i in 0...4
          pkmn.moves[i].pp=pkmn.moves[i].totalpp
        end
        pbDisplayPaused(_INTL("{1} became cloaked in mystical moonlight!",pkmn.pbThis))
        pkmn.effects[PBEffects::LunarDance]=false
      end
      # Z-Memento/Parting Shot
      if pkmn.effects[PBEffects::ZHeal]
        pkmn.pbRecoverHP(pkmn.totalhp,false)
        pbDisplayPaused(_INTL("The Z-Power healed {1}!",pkmn.pbThis(true)))
        pkmn.effects[PBEffects::ZHeal]=false
      end      
      # Spikes
      pkmn.pbOwnSide.effects[PBEffects::Spikes]=0 if $fefieldeffect == 21 ||
       $fefieldeffect == 26
      if pkmn.pbOwnSide.effects[PBEffects::Spikes]>0
        if !pkmn.isAirborne?
          if !pkmn.hasWorkingAbility(:MAGICGUARD) && !(pkmn.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44) && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
            spikesdiv=[8,8,6,4][pkmn.pbOwnSide.effects[PBEffects::Spikes]]
            @scene.pbDamageAnimation(pkmn,0)
            pkmn.pbReduceHP([(pkmn.totalhp/spikesdiv).floor,1].max)
            pbDisplay(_INTL("{1} was hurt by spikes!",pkmn.pbThis))
          end
        end
      end
      pkmn.pbFaint if pkmn.isFainted?
      # Stealth Rock
      if pkmn.pbOwnSide.effects[PBEffects::StealthRock]
        if !pkmn.hasWorkingAbility(:MAGICGUARD) && !(pkmn.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44) && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
          atype=getConst(PBTypes,:ROCK) || 0
          if $fefieldeffect == 25
              randtype = pbRandom(4)
              case randtype
                when 0
                  atype=getConst(PBTypes,:WATER) || 0
                when 1
                  atype=getConst(PBTypes,:GRASS) || 0
                when 2
                  atype=getConst(PBTypes,:FIRE) || 0
                when 3
                  atype=getConst(PBTypes,:PSYCHIC) || 0
              end
          elsif $fefieldeffect == 7 || $fefieldeffect == 16 || $fefieldeffect == 32 || $fefieldeffect == 45
            atype=getConst(PBTypes,:FIRE) || 0
          elsif $fefieldeffect == 41
            atype=getConst(PBTypes,:POISON) || 0
          end
          eff=PBTypes.getCombinedEffectiveness(atype,pkmn.type1,pkmn.type2)
          if $fefieldeffect == 36
            tempeff = 16 if eff == 0 
            tempeff = 16 if eff == 1
            tempeff = 8 if eff == 2
            tempeff = 4 if eff == 4
            tempeff = 2 if eff == 8
            tempeff= 1 if eff == 16
            eff = tempeff
          end
          if isConst?(pkmn.species,PBSpecies,:GLACEON) && pkmn.hasWorkingItem(:GLACCREST)
            eff = 2
          end
          if eff>0
            if $fefieldeffect == 14 || $fefieldeffect == 23 || 
             ($fefieldeffect == 32 && basefield == 23)
              eff = eff*2
            end
            @scene.pbDamageAnimation(pkmn,0)
            pkmn.pbReduceHP([(pkmn.totalhp*eff/32).floor,1].max)
            if $fefieldeffect == 25
              pbDisplay(_INTL("{1} was hurt by the crystalized stealth rocks!",pkmn.pbThis))
            else
              pbDisplay(_INTL("{1} was hurt by stealth rocks!",pkmn.pbThis))
            end
          end
        end
      end
      pkmn.pbFaint if pkmn.isFainted?
      # Corrosive Field Entry    
      if $fefieldeffect == 10       
        if !pkmn.hasWorkingAbility(:MAGICGUARD) &&        
         !pkmn.hasWorkingAbility(:POISONHEAL) &&      
         !pkmn.hasWorkingAbility(:IMMUNITY) &&
         !pkmn.hasWorkingAbility(:WONDERGUARD) &&
         !pkmn.hasWorkingAbility(:TOXICBOOST) &&
         !pkmn.hasWorkingAbility(:PASTELVEIL)
          if !pkmn.isAirborne?
            if !pkmn.pbHasType?(:POISON) && !pkmn.pbHasType?(:STEEL)
              atype=getConst(PBTypes,:POISON) || 0
              eff=PBTypes.getCombinedEffectiveness(atype,pkmn.type1,pkmn.type2)
              if eff>0
                eff=eff*2
                @scene.pbDamageAnimation(pkmn,0)
                pkmn.pbReduceHP([(pkmn.totalhp*eff/32).floor,1].max)
                pbDisplay(_INTL("{1} was seared by the corrosion!",pkmn.pbThis))
              end
            end
          end
        end
      end
      pkmn.pbFaint if pkmn.hp<=0
      # Sticky Web
      if pkmn.pbOwnSide.effects[PBEffects::StickyWeb]
        if !pkmn.isAirborne? && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
          if $fefieldeffect == 15
            #StickyWebMessage
            pbDisplay(_INTL("{1} was caught in a sticky web!",pkmn.pbThis))
            pkmn.pbReduceStat(PBStats::SPEED, 2, true)
          else
            pbDisplay(_INTL("{1} was caught in a sticky web!",pkmn.pbThis))
            pkmn.pbReduceStat(PBStats::SPEED, 1, true)
          end
        end
      end 
      # Toxic Spikes
      pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]=0 if $fefieldeffect == 21 ||
       $fefieldeffect == 26
      if pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        if !pkmn.isAirborne?
          if pkmn.pbHasType?(:POISON) && $fefieldeffect != 10
            pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
            pbDisplay(_INTL("{1} absorbed the poison spikes!",pkmn.pbThis))
          elsif pkmn.pbCanPoisonSpikes? && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
            if pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]==2
              pkmn.pbPoison(pkmn,true)
              pbDisplay(_INTL("{1} was badly poisoned!",pkmn.pbThis))
            else
              pkmn.pbPoison(pkmn)
              pbDisplay(_INTL("{1} was poisoned!",pkmn.pbThis))
            end
          end
        end
      end
    end
    pkmn.pbAbilityCureCheck
    if pkmn.isFainted?
      pbGainEXP
      pbSwitch if @faintswitch
      return false
    end
    #pkmn.pbAbilitiesOnSwitchIn(true)
    if !onlyabilities
      pkmn.pbCheckForm
      pkmn.pbCheckFormRoundEnd   
      pkmn.pbBerryCureCheck
    end
    return true
  end

################################################################################
# Judging.
################################################################################
  def pbJudgeCheckpoint(attacker,move=0)
  end

  def pbDecisionOnTime
    count1=0
    count2=0
    hptotal1=0
    hptotal2=0
    for i in @party1
      next if !i
      if i.hp>0 && !i.isEgg?
        count1+=1
        hptotal1+=i.hp
      end
    end
    for i in @party2
      next if !i
      if i.hp>0 && !i.isEgg?
        count2+=1
        hptotal2+=i.hp
      end
    end
    return 1 if count1>count2     # win
    return 2 if count1<count2     # loss
    return 1 if hptotal1>hptotal2 # win
    return 2 if hptotal1<hptotal2 # loss
    return 5                      # draw
  end

  def pbDecisionOnTime2
    count1=0
    count2=0
    hptotal1=0
    hptotal2=0
    for i in @party1
      next if !i
      if i.hp>0 && !i.isEgg?
        count1+=1
        hptotal1+=(i.hp*100/i.totalhp)
      end
    end
    hptotal1/=count1 if count1>0
    for i in @party2
      next if !i
      if i.hp>0 && !i.isEgg?
        count2+=1
        hptotal2+=(i.hp*100/i.totalhp)
      end
    end
    hptotal2/=count2 if count2>0
    return 1 if count1>count2     # win
    return 2 if count1<count2     # loss
    return 1 if hptotal1>hptotal2 # win
    return 2 if hptotal1<hptotal2 # loss
    return 5                      # draw
  end

  def pbDecisionOnDraw
    return 5 # draw
  end

  def pbJudge
#   PBDebug.log("[Counts: #{pbPokemonCount(@party1)}/#{pbPokemonCount(@party2)}]")
    if pbAllFainted?(@party1) && pbAllFainted?(@party2)
      @decision=pbDecisionOnDraw() # Draw
      return
    end
    if pbAllFainted?(@party1)
      @decision=2 # Loss
      return
    end
    if pbAllFainted?(@party2)
      @decision=1 # Win
      return
    end
  end

################################################################################
# Messages and animations.
################################################################################
  def pbApplySceneBG(sprite,filename)
    @scene.pbApplyBGSprite(sprite,filename)
  end

  def pbDisplay(msg)
    @scene.pbDisplayMessage(msg)
  end

  def pbDisplayPaused(msg)
    @scene.pbDisplayPausedMessage(msg)
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg,true)
  end

  def pbDisplayConfirm(msg)
    @scene.pbDisplayConfirmMessage(msg)
  end

  def pbShowCommands(msg,commands,cancancel=true)
    @scene.pbShowCommands(msg,commands,cancancel)
  end

  def pbAnimation(move,attacker,opponent,hitnum=0)
    if @battlescene
      @scene.pbAnimation(move,attacker,opponent,hitnum)
    end
  end

  def pbCommonAnimation(name,attacker,opponent,hitnum=0)
    if @battlescene
      @scene.pbCommonAnimation(name,attacker,opponent,hitnum)
    end
  end

  def pbRestoreFieldBack
    if !($febackgroundstore.is_a?(String)) && !($febackgroundstore.nil?)
        #    $fefieldeffect = $feoverride
      if $febackgroundstore == 1
        backdrop="Electric"
      elsif $febackgroundstore == 2
        backdrop="Grassy"
      elsif $febackgroundstore == 3
        backdrop="Misty"
      elsif $febackgroundstore == 4
        backdrop="DarkCrystalCavern"
      elsif $febackgroundstore == 5
        backdrop="Chess"
      elsif $febackgroundstore == 6
        backdrop="BigTop"
      elsif $febackgroundstore == 7
        backdrop="Burning"
      elsif $febackgroundstore == 8
        backdrop="Swamp"
      elsif $febackgroundstore == 9
        backdrop="Rainbow"
      elsif $febackgroundstore == 10
        backdrop="Corrosive"
      elsif $febackgroundstore == 11
        backdrop="CorrosiveMist"
      elsif $febackgroundstore == 12
        backdrop="Desert"
      elsif $febackgroundstore == 13
        backdrop="Icy"
      elsif $febackgroundstore == 14
        backdrop="Rocky"
      elsif $febackgroundstore == 15
        backdrop="Forest"
      elsif $febackgroundstore == 16
        backdrop="Superheated"
      elsif $febackgroundstore == 17
        backdrop="Factory"
      elsif $febackgroundstore == 18
        backdrop="Shortcircuit"
      elsif $febackgroundstore == 19
        backdrop="Wasteland"
      elsif $febackgroundstore == 20
        backdrop="AshenBeach"
      elsif $febackgroundstore == 21
        backdrop="Water"
      elsif $febackgroundstore == 22
        backdrop="Underwater"
      elsif $febackgroundstore == 23
        backdrop="Cave"
      elsif $febackgroundstore == 24
        backdrop="Glitch"
      elsif $febackgroundstore == 25
        backdrop="CrystalCavern"
      elsif $febackgroundstore == 26
        if $game_map.map_id==415
          backdrop="Water2"
        else 
          backdrop = "MurkwaterSurface"
        end
      elsif $febackgroundstore == 27
        backdrop="Mountain"
      elsif $febackgroundstore == 28
        backdrop="SnowyMountain"
      elsif $febackgroundstore == 29
        backdrop="Holy"
      elsif $febackgroundstore == 30
        backdrop="Mirror"
      elsif $febackgroundstore == 31
        backdrop="FairyTale"
      elsif $febackgroundstore == 32
        backdrop="DragonsDen"
      elsif $febackgroundstore == 33
        backdrop="FlowerGarden0"
      elsif $febackgroundstore == 34
        backdrop="Starlight1"
      elsif $febackgroundstore == 35
        backdrop="NewWorld"
      elsif $febackgroundstore == 36
        backdrop="Inverse"
      elsif $febackgroundstore == 37
        backdrop="Psychic" 
      elsif $febackgroundstore == 38
        backdrop="Dimensional"                 
      elsif $febackgroundstore == 39
        backdrop="Angie"
      elsif $febackgroundstore == 40
        backdrop="Haunted"
      elsif $febackgroundstore == 41
        backdrop="Corrupted"
      elsif $febackgroundstore == 42
        backdrop="Darchlight"
      elsif $febackgroundstore == 43
        backdrop="GoldenArena"
      elsif $febackgroundstore == 44
        backdrop="ColosseumFieldPlaceholder"
      elsif $febackgroundstore == 45
        backdrop="InfernalFieldPlaceholder"
      end  
      backdrop3 = backdrop
      $febackgroundstore = backdrop3
    else
      if !($febackgroundstore.nil?)
        backdrop=$febackgroundstore
      else
        backdrop=$febackup
        return pbChangeBGSprite
      end
    end
    base=""
    trialname=""
    environ=environment
    if environ==PBEnvironment::Grass || environ==PBEnvironment::TallGrass
      trialname="Grass"
    elsif environ==PBEnvironment::Sand
      trialname="Sand"
#    elsif $PokemonGlobal.surfing
#      trialname="Water"
    elsif $PokemonGlobal.lavasurfing
      trialname="Volcano"
    end
    if pbResolveBitmap(sprintf("Graphics/Battlebacks/playerbase"+backdrop+trialname))
      base=trialname
    end
    # Choose time of day
    time=""
    trialname=""
    timenow=pbGetTimeNow
    if PBDayNight.isNight?(timenow)
      trialname="Night"
    elsif PBDayNight.isEvening?(timenow)
      trialname="Eve"
    end
    if pbResolveBitmap(sprintf("Graphics/Battlebacks/battlebg"+backdrop+trialname))
      time=trialname
    end
    pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebg"+backdrop+time)
    pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybase"+backdrop+base+time)
    pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbase"+backdrop+base+time)
  end

  def pbChangeBGSprite
        case $fefieldeffect
          when 0 # indoor
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgIndoorA.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseIndoorA.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseIndoorA.png")
          when 1 # electric
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgElectric.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseElectric.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseElectric.png")
          when 2 # grassy
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgGrassy.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseGrassy.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseGrassy.png")
          when 3 # misty
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgMisty.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseMisty.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseMisty.png")
          when 4 # dark crystal cavern
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgDarkCrystalCavern.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseDarkCrystalCavern.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseDarkCrystalCavern.png")
          when 5 # chess
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgChess.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseChess.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseChess.png")
          when 6 # bigtop
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgBigtop.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseBigtop.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseBigtop.png")
          when 7 # burning
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgVolcano.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseVolcano.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseVolcano.png")
          when 8 # swamp
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgSwamp.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseSwamp.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseSwamp.png")
          when 9 # rainbow
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgRainbow.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseRainbow.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseRainbow.png")
          when 10 # corrosive
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgPoison.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbasePoison.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybasePoison.png")
          when 11 # corrosive mist
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgCorrosiveMist.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseCorrosiveMist.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseCorrosiveMist.png")
          when 12 # desert
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgDesert.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseDesert.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseDesert.png")
          when 13 # icy
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgIcy.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseIcy.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseIcy.png")
          when 14 # rocky
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgRocky.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseRocky.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseRocky.png")
          when 15 # forest
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgForest.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseForest.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseForest.png")
          when 16 # superheated
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgVoltop.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseVoltop.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseVoltop.png")
          when 17 # factory
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgFactory.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseFactory.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseFactory.png")
          when 18 # short-circuit
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgShortcircuit.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseShortcircuit.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseShortcircuit.png")
          when 19 # wasteland
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgWasteland.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseWasteland.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseWasteland.png")
          when 20 # ashen beach
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgAshenBeach.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseAshenBeach.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseAshenBeach.png")
          when 21 # water surface
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgWater.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseWater.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseWater.png")
          when 22 # underwater
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgUnderwater.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseUnderwater.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseUnderwater.png")
          when 23 # cave
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgCave.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseCave.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseCave.png")
          when 24 # glitch
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgGlitch.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseGlitch.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseGlitch.png")
          when 25 # crystal cavern
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgAmethystCave.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseAmethystCave.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseAmethystCave.png")
          when 26 # murkwater surface
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgWater2.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseWater2.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseWater2.png")
          when 27 # mountain
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgMountain.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseMountain.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseMountain.png")
          when 28 # snowymountain
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgSnowyMountain.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseSnowyMountain.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseSnowyMountain.png")
          when 29 # holy
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgRuin.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseRuin.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseRuin.png")
          when 30 # mirror
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgMirror.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseMirror.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseMirror.png")
          when 31 # fairy tale
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgFairyTale.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseFairyTale.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseFairyTale.png")
          when 32 # dragons den
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgDragonsDen.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseDragonsDen.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseDragonsDen.png")
          when 33 # flower garden
            case $fecounter
              when 0
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgFlowerGarden0.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseFlowerGarden0.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseFlowerGarden0.png")               
              when 1
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgFlowerGarden1.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseFlowerGarden1.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseFlowerGarden1.png")               
              when 2
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgFlowerGarden2.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseFlowerGarden2.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseFlowerGarden2.png")               
              when 3
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgFlowerGarden3.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseFlowerGarden3.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseFlowerGarden3.png")               
              when 4
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgFlowerGarden4.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseFlowerGarden4.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseFlowerGarden4.png")               
            end
          when 34 # starlight field
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgStarlight1.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseStarlight1.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseStarlight1.png")
          when 35 # new world
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgNewWorld.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseNewWorld.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseNewWorld.png")
          when 36 # inverse
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgInverse.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseInverse.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseInverse.png")
          when 37 # psychic
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgPsychic.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbasePsychic.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybasePsychic.png")                
          when 38 # indoorA
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgDimensional.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseIndoorB.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseIndoorB.png")
          when 39 # indoorB
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgAngie.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseAngie.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseAngie.png")
          when 40 # Haunted
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgHaunted.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseHaunted.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseHaunted.png")
          when 41 # Corrupted Cave
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgCorrupted.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseCorrupted.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseCorrupted.png")
          when 42 # Darchlight Woods
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgDarchlight.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseDarchlight.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseDarchlight.png")
          when 43 # sky field
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgGoldenArena.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseGoldenArena.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseGoldenArena.png")
          when 44 # colosseum field
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgGoldenArena.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseGoldenArena.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseGoldenArena.png")
          when 45 # infernal field
                pbApplySceneBG("battlebg","Graphics/Battlebacks/battlebgGoldenArena.png")
                pbApplySceneBG("playerbase","Graphics/Battlebacks/playerbaseGoldenArena.png")
                pbApplySceneBG("enemybase","Graphics/Battlebacks/enemybaseGoldenArena.png")
  end
 end
  
################################################################################
# Battle core.
################################################################################

def pbStartBattle(canlose=false)
    begin
      pbStartBattleCore(canlose)
    rescue BattleAbortedException
      @decision=0
      @scene.pbEndBattle(@decision)
    end
    return @decision
  end

  def pbStartBattleCore(canlose)
    if !@fullparty1 && @party1.length>MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 1 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@fullparty2 && @party2.length>MAXPARTYSIZE+10
      raise ArgumentError.new(_INTL("Party 2 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@opponent
#========================
# Initialize wild Pokémon
#========================
      if @party2.length==1 
        if @doublebattle && !$game_switches[1500]
          raise _INTL("Only two wild Pokémon are allowed in double battles")
        end
        wildpoke=@party2[0]
        @battlers[1].pbInitialize(wildpoke,0,false)
        @peer.pbOnEnteringBattle(self,wildpoke)
        pbSetSeen(wildpoke)
        @scene.pbStartBattle(self)
        pbDisplayPaused(_INTL("Wild {1} appeared!",wildpoke.name)) if ($game_switches[1500]==false) && ($game_switches[290] == false)
        if ($game_switches[1500] == true) || ($game_switches[290] == true)
           if wildpoke.name == "Kyogre"
              pbDisplayPaused(_INTL("Ancient Leviathan {1} attacked!",wildpoke.name)) 
           elsif wildpoke.name == "Giratina"
            pbDisplayPaused(_INTL("The Renegade {1} attacked!",wildpoke.name)) 
          elsif wildpoke.name == "Regirock"
            pbDisplayPaused(_INTL("Guardian Soldier {1} attacked!",wildpoke.name)) 
          elsif wildpoke.name == "Gardevoir"
            pbDisplayPaused(_INTL("Angel of Death {1} attacked!",wildpoke.name))
          elsif wildpoke.name == "Hippowdon"
            pbDisplayPaused(_INTL("{1} is waiting...",wildpoke.name))
          else
            pbDisplayPaused(_INTL("{1} attacked!",wildpoke.name))
          end
        end
      elsif @party2.length==2
        if !@doublebattle
          raise _INTL("Only one wild Pokémon is allowed in single battles")
        end
        @battlers[1].pbInitialize(@party2[0],0,false)
        @battlers[3].pbInitialize(@party2[1],0,false)
        @peer.pbOnEnteringBattle(self,@party2[0])
        @peer.pbOnEnteringBattle(self,@party2[1])
        pbSetSeen(@party2[0])
        pbSetSeen(@party2[1])
        @scene.pbStartBattle(self)
        pbDisplayPaused(_INTL("Wild {1} and\r\n{2} appeared!",
           @party2[0].name,@party2[1].name))
      else
        raise _INTL("Only one or two wild Pokémon are allowed")
      end
    elsif @doublebattle
#=======================================
# Initialize opponents in double battles
#=======================================
      if @opponent.is_a?(Array)
        if @opponent.length==1
          @opponent=@opponent[0]
        elsif @opponent.length!=2
          raise _INTL("Opponents with zero or more than two people are not allowed")
        end
      end
      if @player.is_a?(Array)
        if @player.length==1
          @player=@player[0]
        elsif @player.length!=2
          raise _INTL("Player trainers with zero or more than two people are not allowed")
        end
      end
      @scene.pbStartBattle(self)
      if @opponent.is_a?(Array)
        pbDisplayBrief(_INTL("{1} and {2} want to battle!",@opponent[0].fullname,@opponent[1].fullname))
        sendout1=pbFindNextUnfainted(@party2,0,pbSecondPartyBegin(1))
        raise _INTL("Opponent 1 has no unfainted Pokémon") if sendout1<0
        sendout2=pbFindNextUnfainted(@party2,pbSecondPartyBegin(1))
        raise _INTL("Opponent 2 has no unfainted Pokémon") if sendout2<0
 #       pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[0].fullname,@party2[sendout1].name))
#### JERICHO - 001 - START         
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[0].fullname,@battlers[1].name)) #ILLUSION
        pbSendOut(1,@party2[sendout1])
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[1].fullname,@battlers[3].name)) #ILLUSION
#### JERICHO - 001 - END
        pbSendOut(3,@party2[sendout2])
      else
        pbDisplayBrief(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        if sendout1<0 || sendout2<0
#          raise _INTL("Opponent doesn't have two unfainted Pokémon")
#        end
          sendout2 = nil
          pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent.fullname,@party2[sendout1].name))
          @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
          @battlers[3].pbInitBlank
          @battlers[3].fainted = true
          pbSendOut(1,@party2[sendout1])
        else
#### JERICHO - 001 - START         
          @battlers[1].pbInitialize(@party2[sendout1],sendout1,false) #ILLUSION
          @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
          pbDisplayBrief(_INTL("{1} sent\r\nout {2} and {3}!",
             @opponent.fullname,@battlers[1].name,@battlers[3].name)) #ILLUSION
#### JERICHO - 001 - END           
          pbSendOut(1,@party2[sendout1])
          pbSendOut(3,@party2[sendout2])
        end
      end
    else
#======================================
# Initialize opponent in single battles
#======================================
      sendout=pbFindNextUnfainted(@party2,0)
      raise _INTL("Trainer has no unfainted Pokémon") if sendout<0
      if @opponent.is_a?(Array)
        raise _INTL("Opponent trainer must be only one person in single battles") if @opponent.length!=1
        @opponent=@opponent[0]
      end
      if @player.is_a?(Array)
        raise _INTL("Player trainer must be only one person in single battles") if @player.length!=1
        @player=@player[0]
      end
      trainerpoke=@party2[sendout]
      @scene.pbStartBattle(self)
      pbDisplayBrief(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
#### JERICHO - 001 - START      
      @battlers[1].pbInitialize(trainerpoke,sendout,false) #ILLUSION 
      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent.fullname,PBSpecies.getName(@battlers[1].species)))
#### JERICHO - 001 - END    
      pbSendOut(1,trainerpoke)
    end
#=====================================
# Initialize players in double battles
#=====================================
    for i in @party1
      if i!=nil && isConst?(i.species,PBSpecies,:ZANGOOSE) && isConst?(i.item,PBItems,:ZANGCREST)
        if i.status==0
          i.status=PBStatuses::POISON
        end
      end
    end
    
    if @doublebattle
      if @player.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
        raise _INTL("Player 1 has no unfainted Pokémon") if sendout1<0
        sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
        raise _INTL("Player 2 has no unfainted Pokémon") if sendout2<0
#### JERICHO - 001 - START        
        @battlers[0].pbInitialize(@party1[sendout1],sendout1,false) #ILLUSION 
        @battlers[2].pbInitialize(@party1[sendout2],sendout2,false) 
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!  Go! {3}!", 
    @player[1].fullname,@battlers[2].name,@battlers[0].name))#ILLUSION
#### JERICHO - 001 - END    
        pbSetSeen(@party1[sendout1])
        pbSetSeen(@party1[sendout2])
      else
        sendout1=pbFindNextUnfainted(@party1,0)
        sendout2=pbFindNextUnfainted(@party1,sendout1+1)
#### JERICHO - 001 - START        
        @battlers[0].pbInitialize(@party1[sendout1],sendout1,false) #ILLUSION
        @battlers[2].pbInitialize(@party1[sendout2],sendout2,false) unless sendout2==-1
        if sendout2>-1
          pbDisplayBrief(_INTL("Go! {1} and {2}!",@battlers[0].name,@battlers[2].name)) #ILLUSION 
        else
          pbDisplayBrief(_INTL("Go! {1}!",@battlers[0].name)) #ILLUSION  
        end        
      end
#### JERICHO - 001 - END      
      pbSendOut(0,@party1[sendout1])
      pbSendOut(2,@party1[sendout2]) unless sendout2==-1
    else
#====================================
# Initialize player in single battles
#====================================
      sendout=pbFindNextUnfainted(@party1,0)
      if sendout<0
        raise _INTL("Player has no unfainted Pokémon")
      end
      playerpoke=@party1[sendout]
#### JERICHO - 001 - START      
      @battlers[0].pbInitialize(playerpoke,sendout,false) #Illusion 
      pbDisplayBrief(_INTL("Go! {1}!",@battlers[0].name))
#### JERICHO - 001 - END      
      pbSendOut(0,playerpoke)
    end
#==================
# Initialize battle
#==================
    case $fefieldeffect 
    when 43
      for i in 0...4
        if @battlers[i].hasWorkingAbility(:CLOUDNINE)
          @weather = 0
          pbDisplay(_INTL("All weathers effects are removed due to Cloud Nine!"))
          break
        end
      end
    end
      
    if @weather==PBWeather::SUNNYDAY
      pbCommonAnimation("Sunny",nil,nil)
      pbDisplay(_INTL("The sunlight is strong."))
      #### DemICE - persistentweather - START
      @weatherbackup=PBWeather::SUNNYDAY
      @weatherbackupanim="Sunny"
      #### DemICE
    elsif @weather==PBWeather::RAINDANCE
      pbCommonAnimation("Rain",nil,nil)
      pbDisplay(_INTL("It is raining."))
      #### DemICE - persistentweather - START
      @weatherbackup=PBWeather::RAINDANCE
      @weatherbackupanim="Rain"
      #### DemICE
    elsif @weather==PBWeather::SANDSTORM
      pbCommonAnimation("Sandstorm",nil,nil)
      pbDisplay(_INTL("A sandstorm is raging."))
      #### DemICE - persistentweather - START
      @weatherbackup=PBWeather::SANDSTORM
      @weatherbackupanim="Sandstorm"
      #### DemICE
    elsif @weather==PBWeather::HAIL
      pbCommonAnimation("Hail",nil,nil)
      pbDisplay(_INTL("Hail is falling."))
      #### DemICE - persistentweather - START
      @weatherbackup=PBWeather::HAIL
      @weatherbackupanim="Hail"
      #### DemICE
    elsif @weather==PBWeather::STRONGWINDS
      pbDisplay(_INTL("The wind is strong."))
      #### DemICE - persistentweather - START
      @weatherbackup=PBWeather::STRONGWINDS
      @weatherbackupanim="Wind"
      #### DemICE
    end
   # Field Effects BEGIN UPDATE
   case $fefieldeffect
     when 1
      pbDisplay(_INTL("The field is hyper-charged!"))
     when 2
      pbDisplay(_INTL("The field is in full bloom."))
     when 3
      pbDisplay(_INTL("Mist settles on the field."))
     when 4
      pbDisplay(_INTL("Darkness is gathering..."))
     when 5
      pbDisplay(_INTL("Opening variation set."))
     when 6
      pbDisplay(_INTL("Now presenting...!"))
     when 7
      pbDisplay(_INTL("The heat is intense!"))
     when 8
      pbDisplay(_INTL("The field is swamped."))
     when 9
      pbDisplay(_INTL("What does it mean?"))
     when 10
      pbDisplay(_INTL("The field is corrupted!"))
     when 11
      pbDisplay(_INTL("Corrosive mist settles on the field!"))
     when 12
      pbDisplay(_INTL("The field is rife with sand."))
     when 13
      pbDisplay(_INTL("The field is covered in ice."))
     when 14
      pbDisplay(_INTL("The field is littered with rocks."))
     when 15
      pbDisplay(_INTL("Trees fill the arena!"))
     when 16
      pbDisplay(_INTL("The volcanic field's heat is intense!"))
     when 17
      pbDisplay(_INTL("Machines whir in the background."))
     when 18
      pbDisplay(_INTL("Bzzt!"))
     when 19
      pbDisplay(_INTL("The field is poionous!"))
     when 20
      pbDisplay(_INTL("Ash and sand line the field."))
     when 21
      pbDisplay(_INTL("The water's surface is calm."))
     when 22
      pbDisplay(_INTL("Blub blub..."))
     when 23
      pbDisplay(_INTL("The cave echoes dully..."))
     when 24
      pbDisplay(_INTL("1n!taliz3 .b//////attl3"))
     when 25
      pbDisplay(_INTL("The cave is littered with crystals."))
     when 26
      pbDisplay(_INTL("The water is tainted..."))
     when 27
      pbDisplay(_INTL("High up!"))
     when 28
      pbDisplay(_INTL("The snow glows white on the mountain..."))
     when 29
      pbDisplay(_INTL("The field is blessed!"))
     when 30
      pbDisplay(_INTL("Mirrors are layed around the field!"))
     when 31
      pbDisplay(_INTL("Once upon a time..."))
     when 32
      pbDisplay(_INTL("If you wish to slay a dragon..."))
     when 33
      pbDisplay(_INTL("Seeds line the field."))
     when 34
      pbDisplay(_INTL("Starlight fills the battlefield."))
      for i in 0...4
        if @battlers[i].hasWorkingAbility(:WORLDOFNIGHTMARES)
          pbDisplay(_INTL("The dawn of a New World shines down upon the broken land."))
          break
        end
      end
     when 35
      pbDisplay(_INTL("From darkness, from stardust,"))
      pbDisplay(_INTL("From memories of eons past and visions yet to come..."))
     when 36
      pbDisplay(_INTL("!trats elttaB"))
     when 37
      pbDisplay(_INTL("The field became mysterious!"))
     when 38
      pbDisplay(_INTL("Darkness radiates."))
     when 39
      pbDisplay(_INTL("Hate and anger radiates."))
     when 40
      pbDisplay(_INTL("The field is haunted!"))
     when 41
      pbDisplay(_INTL("Corruption seeps from every crevice!"))
     when 42
      pbDisplay(_INTL("Everlasting glow and glamour!"))
     when 43
      pbDisplay(_INTL("The sky is filled with clouds."))
     when 44
      pbDisplay(_INTL("All eyes are on the combatants!"))
     when 45
      pbDisplay(_INTL("The souls of the damned burn on."))
    end
    if ($game_variables[702] == 1) || ($game_variables[702] == 4) ### Azery - Auto Perma TR switch.
      @trickroom=8
      for i in @battlers
        pbAnimation(499,i,nil)
        break
      end
      if $game_variables[646] == 87
         pbDisplay(_INTL("The Puppet Master's distortion has twisted the dimensions!"))
      else
         pbDisplay(_INTL("The dimensions have been twisted! Trick Room is active."))
      end
    elsif $game_variables[702] == 2 || ($game_variables[702] == 4) ### Azery - Auto Perma WR switch.
      @field.effects[PBEffects::WonderRoom]=8
      for i in @battlers
        pbAnimation(500,i,nil)
        pbDisplay(_INTL("The dimensions have been twisted! Wonder Room is active."))
        break
      end
    elsif $game_variables[702] == 3 || ($game_variables[702] == 5) ### Azery - Auto Perma WR switch.
      @field.effects[PBEffects::MagicRoom]=8
      for i in @battlers
        pbAnimation(485,i,nil)
        pbDisplay(_INTL("The dimensions have been twisted! Magic Room is active."))
        break
      end
    end
  # END OF UPDATE 
    pbOnActiveAll   # Abilities
    @turncount=0
    if !opponent
      PBDebug.log("==============================") if $INTERNAL
      PBDebug.log("Battle Start!") if $INTERNAL
      PBDebug.log("Wild Battle") if $INTERNAL
      PBDebug.log("==============================") if $INTERNAL
    else
      PBDebug.log("==============================") if $INTERNAL
      PBDebug.log("Battle Start!") if $INTERNAL
      if @opponent.is_a?(Array)
        PBDebug.log("#{@opponent[0].trainertype} - #{@opponent[0].name}") if $INTERNAL
        PBDebug.log("#{@opponent[1].trainertype} - #{@opponent[1].name}") if $INTERNAL
      else
        PBDebug.log("#{@opponent.trainertype} - #{@opponent.name}") if $INTERNAL
      end
      #PBDebug.log("#{@opponent.trainertype} - #{@opponent.name}") if $INTERNAL
      PBDebug.log("==============================") if $INTERNAL
    end
    
    loop do   # Now begin the battle loop
      PBDebug.log("***Round #{@turncount+1}***") if $INTERNAL
      if @debug && @turncount>=100
        @decision=pbDecisionOnTime()
        PBDebug.log("***[Undecided after 100 rounds]")
        pbAbort
        break
      end
      PBDebug.logonerr{
         pbCommandPhase
      }
      break if @decision>0
      #CP_Profiler.print
      #$aitime = Time.now - $aitime
      #print $aitime
      #$aitime = nil
      PBDebug.logonerr{
         pbAttackPhase
      }
      break if @decision>0
      PBDebug.logonerr{
         pbEndOfRoundPhase
      }
      break if @decision>0
      @turncount+=1
    end
    return pbEndOfBattle(canlose)
  end

################################################################################
# Command phase.
################################################################################
  def pbCommandMenu(i)
    return @scene.pbCommandMenu(i)
  end

  def pbItemMenu(i)
    return @scene.pbItemMenu(i)
  end

  def pbAutoFightMenu(i)
    return false
  end

  def pbCommandPhase
    @scene.pbBeginCommandPhase
#### SARDINES - v17 - START
#    @scene.pbResetCommandIndices
#### SARDINES - v17 - END
    for i in 0...4   # Reset choices if commands can be shown
      if pbCanShowCommands?(i) || @battlers[i].isFainted?
        @choices[i][0]=0
        @choices[i][1]=0
        @choices[i][2]=nil
        @choices[i][3]=-1
      else
        battler=@battlers[i]
        unless !@doublebattle && pbIsDoubleBattler?(i)
          PBDebug.log("[reusing commands for #{battler.pbThis(true)}]") if $INTERNAL
        end
      end
    end
#### KUROTSUNE - 015 - START
    $randtype=0
    for i in 0..3
      @switchedOut[i] = false
    end
#### KUROTSUNE - 015 - END
    # Reset choices to perform Mega Evolution/Z-Moves if it wasn't done somehow
    for i in 0...@megaEvolution[0].length
      @megaEvolution[0][i]=-1 if @megaEvolution[0][i]>=0
    end
    for i in 0...@megaEvolution[1].length
      @megaEvolution[1][i]=-1 if @megaEvolution[1][i]>=0
    end
    for i in 0...@zMove[0].length
      @zMove[0][i]=-1 if @zMove[0][i]>=0
    end
    for i in 0...@zMove[1].length
      @zMove[1][i]=-1 if @zMove[1][i]>=0
    end    
    for i in 0...4
      if i==1
        i=2
      elsif i==2
        i=1
      end
      if @field.effects[PBEffects::WonderRoom] > 0
        for m in @battlers
          if !m.wonderroom
            m.pbSwapDefenses
          end
        end
      end
      if pbCanShowCommands?(i)
        @battlers[i].effects[PBEffects::SomethingCrazy]=nil
        @battlers[i].effects[PBEffects::Attacking]=false
        @battlers[i].effects[PBEffects::UsingItem]=[]
        @battlers[i].effects[PBEffects::Switching]=false
      end
      break if @decision!=0
      next if @choices[i][0]!=0
      if !pbOwnedByPlayer?(i) || @controlPlayer
        #CP_Profiler.begin if !$aitime
        $aitime = Time.now if !$aitime
        if !@battlers[i].isFainted? && pbCanShowCommands?(i)
          @scene.pbChooseEnemyCommand(i)
        end
      else
        commandDone=false
        commandEnd=false
        if pbCanShowCommands?(i)
          loop do
            cmd=pbCommandMenu(i)
            if cmd==0 # Fight
              if pbCanShowFightMenu?(i)
                commandDone=true if pbAutoFightMenu(i)
                until commandDone
                  index=@scene.pbFightMenu(i)
                  if index<0
                    side=(pbIsOpposing?(i)) ? 1 : 0
                    owner=pbGetOwnerIndex(i)
                    if @megaEvolution[side][owner]==i
                      @megaEvolution[side][owner]=-1
                    end
                    if @zMove[side][owner]==i
                      @zMove[side][owner]=-1
                    end                          
                    break
                  end
                  if @battlers[i].moves[index].basedamage>0
                    @battlers[i].effects[PBEffects::Attacking]=true
                  end
                  @battlers[i].effects[PBEffects::SomethingCrazy]=@battlers[i].moves[index]
                  thismove=@battlers[i].moves[index]
                  target=@battlers[i].pbTarget(thismove)
                  if target==PBTargets::SingleNonUser # single non-user
                    @battlers[i].effects[PBEffects::AttackingTarget].push(@battlers[i].pbOppositeOpposing.index)
                  elsif target==PBTargets::SingleNonUser # single non-user
                    @battlers[i].effects[PBEffects::AttackingTarget].push(@battlers[i].pbOppositeOpposing.index)
                  elsif target==PBTargets::AllOpposing
                    @battlers[i].effects[PBEffects::AttackingTarget].push(@battlers[i].pbOppositeOpposing.index)
                  elsif target==PBTargets::AllNonUsers
                    @battlers[i].effects[PBEffects::AttackingTarget].push(@battlers[i].pbOppositeOpposing.index)
                  end
                  next if !pbRegisterMove(i,index)
                  if @doublebattle
                    thismove=@battlers[i].moves[index]
                    target=@battlers[i].pbTarget(thismove)
                    if target==PBTargets::SingleNonUser # single non-user
                      target=@scene.pbChooseTarget(i)
                      next if target<0
                      pbRegisterTarget(i,target)
                      @battlers[i].effects[PBEffects::AttackingTarget].push(target)
                    elsif target==PBTargets::UserOrPartner # Acupressure
                      target=@scene.pbChooseTargetAcupressure(i)
                      next if target<0 || (target&1)!=(i&1)
                      pbRegisterTarget(i,target)
                    elsif target==PBTargets::AllOpposing
                      @battlers[i].effects[PBEffects::AttackingTarget].push(@battlers[i].pbOppositeOpposing.index,@battlers[i].pbOppositeOpposing.pbPartner.index)
                    elsif target==PBTargets::AllNonUsers
                      @battlers[i].effects[PBEffects::AttackingTarget].push(@battlers[i].pbOppositeOpposing,@battlers[i].pbOppositeOpposing.pbPartner.index,@battlers[i].pbPartner.index)
                    end
                  end
                  commandDone=true
                end
              else
                pbAutoChooseMove(i)
                commandDone=true
              end
            elsif cmd==1 # Bag
              if (!@internalbattle || $game_variables[646]==65 && $game_variables[200]!=1)
                if pbOwnedByPlayer?(i)
                  pbDisplay(_INTL("Items can't be used here."))
                end
              else
                item=pbItemMenu(i)
                if item[0]>0
                  if pbRegisterItem(i,item[0],item[1])
                    if (item[1]==@battlers[0].pokemonIndex || @doublebattle && item[1]==@battlers[2].pokemonIndex)
                      @battlers[i].effects[PBEffects::UsingItem]=[item[0],item[1]]
                    end
                    commandDone=true
                  end
                end
              end
            elsif cmd==2 # Pokémon
              pkmn=pbSwitchPlayer(i,false,true)
              if pkmn>=0
                if pbRegisterSwitch(i,pkmn)
                  commandDone=true 
                  @battlers[i].effects[PBEffects::Switching]=true
                  @battlers[i].effects[PBEffects::SwitchingTo]=pkmn
                end
              end
            elsif cmd==3   # Run
              run=pbRun(i) 
              if run>0
                commandDone=true
                return
              elsif run<0
                commandDone=true
                side=(pbIsOpposing?(i)) ? 1 : 0
                owner=pbGetOwnerIndex(i)
                if @megaEvolution[side][owner]==i
                  @megaEvolution[side][owner]=-1
                end
                if @zMove[side][owner]==i
                  @zMove[side][owner]=-1
                end                
              end
            elsif cmd==4   # Call
              thispkmn=@battlers[i]
              @choices[i][0]=4   # "Call Pokémon"
              @choices[i][1]=0
              @choices[i][2]=nil
              side=(pbIsOpposing?(i)) ? 1 : 0
              owner=pbGetOwnerIndex(i)
              if @megaEvolution[side][owner]==i
                @megaEvolution[side][owner]=-1
              end
              @battlers[i].effects[PBEffects::UsingItem]=[]
              @battlers[i].effects[PBEffects::Attacking]=false
              @battlers[i].effects[PBEffects::Switching]=false
              if @zMove[side][owner]==i
                @zMove[side][owner]=-1
              end               
              commandDone=true
            elsif cmd==-1   # Go back to first battler's choice
              @battlers[i].effects[PBEffects::Attacking]=false
              @battlers[i].effects[PBEffects::UsingItem]=[]
              @battlers[i].effects[PBEffects::Switching]=false
              @battlers[i].effects[PBEffects::SomethingCrazy]=nil
              @battlers[i].effects[PBEffects::AttackingTarget].clear
              @megaEvolution[0][0]=-1 if @megaEvolution[0][0]>=0
              @megaEvolution[1][0]=-1 if @megaEvolution[1][0]>=0
              @zMove[0][0]=-1 if @zMove[0][0]>=0
              @zMove[1][0]=-1 if @zMove[1][0]>=0              
              # Restore the item the player's first Pokémon was due to use
              if @choices[0][0]==3 && $PokemonBag && $PokemonBag.pbCanStore?(@choices[0][1])
                $PokemonBag.pbStoreItem(@choices[0][1])
              end
              pbCommandPhase
              return
            end
            break if commandDone
          end
        end
      end
    end
  end

################################################################################
# Attack phase.
################################################################################
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    for i in 0...4
      @successStates[i].clear
      if @choices[i][0]!=1 && @choices[i][0]!=2
        @battlers[i].effects[PBEffects::DestinyBond]=false
        @battlers[i].effects[PBEffects::Grudge]=false
      end
      if @battlers[i].effects[PBEffects::ShieldLife]==0 && @shieldCount>0 && (!pbBelongsToPlayer?(i)) && pbIsOpposing?(i)
        shieldlife=[(@battlers[i].totalhp/4).floor,1].max
        @battlers[i].effects[PBEffects::ShieldLife]=shieldlife
      end
      @battlers[i].turncount+=1 if !@battlers[i].isFainted?
      @battlers[i].effects[PBEffects::Rage]=false if !pbChoseMove?(i,:RAGE)
      #@battlers[i].pbCustapBerry
      # If Rift/Boss mon and shieldCount == -1,
      # update @battle.shieldCount (when enters battle in rift form)
      if !pbBelongsToPlayer?(i) && @bossfight && isBossPokemonInRiftForm?(@battlers[i]) && @shieldCount==-1
        @battlers[i].isBoss = true

        @scene.pbUpdateBattleShield(i)
      end
    end
    # Prepare for Z Moves
    for i in 0..3
      next if @choices[i][0]!=1
      side=(pbIsOpposing?(i)) ? 1 : 0
      owner=pbGetOwnerIndex(i)
      if @zMove[side][owner]==i
        @choices[i][2].zmove=true
      end
    end    
    # Calculate priority at this time
    @usepriority=false
    priority=pbPriority
#    # Mega Evolution Moved to after switching + items
#    for i in priority
#      next if @choices[i.index][0]!=1
#      side=(pbIsOpposing?(i.index)) ? 1 : 0
#      owner=pbGetOwnerIndex(i.index)
#      if @megaEvolution[side][owner]==i.index
#        pbMegaEvolve(i.index)
#      end
#    end
#    priority=pbPriority(false,true)
    # Call at Pokémon
    for i in priority
      if @choices[i.index][0]==4
        pbCall(i.index)
      end
    end
    # Switch out Pokémon
    @switching=true
    switched=[]
    for i in priority
      if @choices[i.index][0]==2
        index=@choices[i.index][1] # party position of Pokémon to switch to
        self.lastMoveUser=i.index
        if !pbOwnedByPlayer?(i.index)
          owner=pbGetOwner(i.index)
          pbDisplayBrief(_INTL("{1} withdrew {2}!",owner.fullname,PBSpecies.getName(i.species)))
        else
          pbDisplayBrief(_INTL("{1}, that's enough!\r\nCome back!",i.name))
        end
        if i.ability==PBAbilities::NEUTRALIZINGGAS
					i.effects[PBEffects::GastroAcid]=true
					pbDisplayBrief(_INTL("The effects of the Neutralizing Gass wore off!"))					
					for j in @battlers
						j.pbAbilitiesOnSwitchIn(true)
					end	
				end
        if @field.effects[PBEffects::WonderRoom]!=0
          if i.wonderroom==true
            i.pbSwapDefenses
          end
        end
        for j in priority
          next if !i.pbIsOpposing?(j.index)
          # if Pursuit and this target ("i") was chosen
          if pbChoseMoveFunctionCode?(j.index,0x88) &&
             !j.effects[PBEffects::Pursuit] &&
             (@choices[j.index][3]==-1 || @choices[j.index][3]==i.index)
            if j.status!=PBStatuses::SLEEP &&
               j.status!=PBStatuses::FROZEN &&
               (!j.hasWorkingAbility(:TRUANT) || !j.effects[PBEffects::Truant])
              j.pbUseMove(@choices[j.index])
              j.effects[PBEffects::Pursuit]=true
              # UseMove calls pbGainEXP as appropriate
              @switching=false
              return if @decision>0
            end
          end
          break if i.isFainted?
        end
        if !pbRecallAndReplace(i.index,index)
          # If a forced switch somehow occurs here in single battles
          # the attack phase now ends
          if !@doublebattle
            @switching=false
            return
          end
        else
          switched.push(i.index)
        end
      end
    end
    if switched.length>0
      for i in priority
        i.pbAbilitiesOnSwitchIn(true) if switched.include?(i.index)
      end
    end
    @switching=false
    @partnerswitch.clear
    for i in 0...4
       if !switched.include?(i)
         @battlers[i].pbCustapBerry
       end
    end
    # Use items
    for i in priority
      if pbIsOpposing?(i.index) && @choices[i.index][0]==3
        pbEnemyUseItem(@choices[i.index][1],i)
        i.itemUsed = true
        i.itemUsed2 = true
      elsif @choices[i.index][0]==3
        # Player use item
        item=@choices[i.index][1]
        if item>0
          usetype=$ItemData[item][ITEMBATTLEUSE]
          if usetype==1 || usetype==3
            if @choices[i.index][2]>=0
              pbUseItemOnPokemon(item,@choices[i.index][2],i,@scene)
              i.itemUsed = true
              i.itemUsed2 = true
            end
          elsif usetype==2 || usetype==4
            if !ItemHandlers.hasUseInBattle(item) # Poké Ball/Poké Doll used already
              pbUseItemOnBattler(item,@choices[i.index][2],i,@scene)
               i.itemUsed = true 
               i.itemUsed2 = true 
            end
          end
        end
      end
    end
    # Mega Evolution
    for i in priority
      next if @choices[i.index][0]!=1
      side=(pbIsOpposing?(i.index)) ? 1 : 0
      owner=pbGetOwnerIndex(i.index)
      if @megaEvolution[side][owner]==i.index
        pbMegaEvolve(i.index)
      end
    end
    priority=pbPriority(false,true)    #Turn order recalc from Gen VII
#### KUROTSUNE - 014 - START
#### KUROTSUNE - 014 - END
    symbiosis = pbSymbiosisCheck(priority)
# Crest Stat Check
    for i in priority
      if (isConst?(i.species,PBSpecies,:CLAYDOL) && i.hasWorkingItem(:CLAYCREST))
        i.spatk = i.defense
      end
      if (isConst?(i.species,PBSpecies,:DEDENNE) && i.hasWorkingItem(:DEDECREST))
        i.attack = i.pbSpeed
      end
      if (isConst?(i.species,PBSpecies,:TYPHLOSION) && i.hasWorkingItem(:TYPHCREST))
        i.attack = i.spatk
      end
    end
# Use Attacks
    for i in priority
      if pbChoseMoveFunctionCode?(i.index,0x115) # Focus Punch
        pbCommonAnimation("FocusPunch",i,nil)
        pbDisplay(_INTL("{1} is tightening its focus!",i.pbThis))
      end
    end
    for i in priority
      if pbChoseMoveFunctionCode?(i.index,0x15D) # Beak Blast
        pbCommonAnimation("BeakBlast",i,nil)
        i.effects[PBEffects::BeakBlast]=true
        pbDisplay(_INTL("{1} is heating up!",i.pbThis))
      end
    end
    for i in priority
      if pbChoseMoveFunctionCode?(i.index,0x16B) # Shell Trap
        pbCommonAnimation("ShellTrap",i,nil)
        i.effects[PBEffects::ShellTrap]=true
        pbDisplay(_INTL("{1} set a shell trap!",i.pbThis))
      end
    end     
    for i in priority
      i.pbProcessTurn(@choices[i.index])
      if i.effects[PBEffects::Round]
        i.pbPartner.selectedMove = 297
      end
      
      if symbiosis
        for s in symbiosis
          if s.item == 0 && s.pbPartner.item
            pbDisplay(_INTL("{1} received {2}'s {3} from symbiosis! ",s.pbThis, s.pbPartner.pbThis, PBItems.getName(s.pbPartner.item)))
            s.item = s.pbPartner.item
            s.pokemon.itemInitial = s.pbPartner.item
            s.pbPartner.pokemon.itemInitial = 0
            s.pbPartner.item=0
          end
        end
      end
      return if @decision>0
    end
    pbWait(20)
  end
  
  # Checks if anyone is eligible to receive an item through symbiosis
  def pbSymbiosisCheck(battlers)
      result = Array.new
      count  = 0
      for i in battlers
        next if (i.pokemon.nil? || i.pbPartner.pokemon.nil?)
        if i.item != 0 && i.pokemon.itemInitial != 0 && 
          i.pbPartner.item != 0 && i.pbPartner.pokemon.itemInitial != 0 && 
          i.pbPartner.hasWorkingAbility(:SYMBIOSIS)
            result[count] = i
            count += 1
        end
      end
      if result.any?
        return result
      else
        return false
      end
    end
 
    def pbShieldDamage(battler,damage,move=nil)
      if battler.effects[PBEffects::ShieldLife]>0
        if !(move.nil?)
          if move.id == PBMoves::THEOLIASTRIKE
            battler.effects[PBEffects::ShieldLife]=0
            @shieldCount-=2
            scene.pbUpdateShield(@shieldCount,battler.index)
            scene.pbDamageAnimation(battler,0)
            if @shieldCount>0
              shieldlife=[(battler.totalhp/4).floor,1].max
              battler.effects[PBEffects::ShieldLife]=shieldlife
            elsif @shieldCount==0
              battler.pbReduceHP([(battler.totalhp/8).floor,1].max)
            end
            if battler.hasWorkingAbility(:SAVAGERY)
              pbDisplay(_INTL("Taking damage made {1} more savage!",battler.name))
              if !battler.pbTooHigh?(PBStats::ATTACK)
                battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
                pbCommonAnimation("StatUp",battler,nil)
                pbDisplay(_INTL("{1}'s Savagery raised its Attack!",battler.name))
              end
              if !battler.pbTooHigh?(PBStats::SPATK)
                battler.pbIncreaseStatBasic(PBStats::SPATK,1)
                pbCommonAnimation("StatUp",battler,nil)
                pbDisplay(_INTL("{1}'s Savagery raised its Special Attack!",battler.name))
              end
            end
          else
            damage=battler.effects[PBEffects::ShieldLife] if damage>battler.effects[PBEffects::ShieldLife]
            battler.effects[PBEffects::ShieldLife]-=damage
            if battler.effects[PBEffects::ShieldLife]>0 && @shieldCount>0
              scene.pbUpdateShield(@shieldCount,battler.index)
              scene.pbDamageAnimation(battler,0)
              pbDisplayPaused(_INTL("{1}'s shields took the damage!",battler.name))
            end
            if battler.effects[PBEffects::ShieldLife]<=0
              battler.effects[PBEffects::ShieldLife]=0
              @shieldCount-=1
              scene.pbUpdateShield(@shieldCount,battler.index)
              scene.pbDamageAnimation(battler,0)
              pbDisplayPaused(_INTL("{1}'s shield broke!",battler.name))
              if @shieldCount>0
                shieldlife=[(battler.totalhp/4).floor,1].max
                battler.effects[PBEffects::ShieldLife]=shieldlife
              elsif @shieldCount==0
                battler.pbReduceHP([(battler.totalhp/8).floor,1].max)
              end
              if battler.hasWorkingAbility(:SAVAGERY)
                pbDisplay(_INTL("Taking damage made {1} more savage!",battler.name))
                if !battler.pbTooHigh?(PBStats::ATTACK)
                  battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
                  pbCommonAnimation("StatUp",battler,nil)
                  pbDisplay(_INTL("{1}'s Savagery raised its Attack!",battler.name))
                end
                if !battler.pbTooHigh?(PBStats::SPATK)
                  battler.pbIncreaseStatBasic(PBStats::SPATK,1)
                  pbCommonAnimation("StatUp",battler,nil)
                  pbDisplay(_INTL("{1}'s Savagery raised its Special Attack!",battler.name))
                end
              end
            end
          end
        else
          damage=battler.effects[PBEffects::ShieldLife] if damage>battler.effects[PBEffects::ShieldLife]
          battler.effects[PBEffects::ShieldLife]-=damage
          if battler.effects[PBEffects::ShieldLife]>0 && @shieldCount>0
            scene.pbUpdateShield(@shieldCount,battler.index)
            scene.pbDamageAnimation(battler,0)
            pbDisplayPaused(_INTL("{1}'s shields took the damage!",battler.name))
          end
          if battler.effects[PBEffects::ShieldLife]<=0
            battler.effects[PBEffects::ShieldLife]=0
            @shieldCount-=1
            scene.pbUpdateShield(@shieldCount,battler.index)
            scene.pbDamageAnimation(battler,0)
            pbDisplayPaused(_INTL("{1}'s shield broke!",battler.name))
            if @shieldCount>0
              shieldlife=[(battler.totalhp/4).floor,1].max
              battler.effects[PBEffects::ShieldLife]=shieldlife
            elsif @shieldCount==0
              battler.pbReduceHP([(battler.totalhp/8).floor,1].max)
            end
            if battler.hasWorkingAbility(:SAVAGERY)
              pbDisplay(_INTL("Taking damage made {1} more savage!",battler.name))
              if !battler.pbTooHigh?(PBStats::ATTACK)
                battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
                pbCommonAnimation("StatUp",battler,nil)
                pbDisplay(_INTL("{1}'s Savagery raised its Attack!",battler.name))
              end
              if !battler.pbTooHigh?(PBStats::SPATK)
                battler.pbIncreaseStatBasic(PBStats::SPATK,1)
                pbCommonAnimation("StatUp",battler,nil)
                pbDisplay(_INTL("{1}'s Savagery raised its Special Attack!",battler.name))
              end
            end
          end
        end
      end
    end
################################################################################
# End of round.
################################################################################
  def pbEndOfRoundPhase
    for i in 0...4
      @battlers[i].forcedSwitchEarlier = false
      @battlers[i].effects[PBEffects::Roost]=false
      @battlers[i].effects[PBEffects::Protect]=false
      @battlers[i].effects[PBEffects::KingsShield]=false # add this line
      @battlers[i].effects[PBEffects::ProtectNegation]=false
      @battlers[i].effects[PBEffects::Endure]=false
      @battlers[i].effects[PBEffects::HyperBeam]-=1 if @battlers[i].effects[PBEffects::HyperBeam]>0
      @battlers[i].effects[PBEffects::SpikyShield]=false
      @battlers[i].effects[PBEffects::BanefulBunker]=false
      @battlers[i].effects[PBEffects::Obstruct]=false
      @battlers[i].effects[PBEffects::BeakBlast]=false
      @battlers[i].effects[PBEffects::ClangedScales]=false
      @battlers[i].effects[PBEffects::ShellTrap]=false
      @battlers[i].effects[PBEffects::AttackingTarget].clear
#### KUROTSUNE - 023 - START
      @battlers[i].effects[PBEffects::Powder]  = false
#### KUROTSUNE - 023 - END
#### KUROTSUNE - 032 - START
      @battlers[i].effects[PBEffects::MeFirst] = false
      if @battlers[i].effects[PBEffects::ThroatChop]>0
        @battlers[i].effects[PBEffects::ThroatChop]-=1
      end      
#### KUROTSUNE - 032 - END      
      @battlers[i].itemUsed                    = false
      @battlers[i].pbCheckFormRoundEnd  
    end
#### KUROTSUNE - 013 - START
    @field.effects[PBEffects::IonDeluge]       = false
#### KUROTSUNE - 013 - END
    for i in 0...2
      sides[i].effects[PBEffects::QuickGuard]=false
      sides[i].effects[PBEffects::WideGuard]=false
      sides[i].effects[PBEffects::MatBlock]=false
    end
    @usepriority=false  # recalculate priority
    priority=pbPriority(true) # Ignoring Quick Claw here
#### AME - 003 - START
    # Field Effects
    endmessage=false
    hazardsOnSide = false
    # Vespi Crest
    for i in priority
      next if i.isFainted?
      if isConst?(i.species,PBSpecies,:VESPIQUEN) && i.hasWorkingItem(:VESPICREST)
        mon = i
        if mon.effects[PBEffects::VespiCrest] == 0 
           if (mon.totalhp != mon.hp)
            pbDisplay(_INTL("Vespiquen's swarm patched up her injuries!",i.pbThis)) if endmessage == false
            endmessage=true
            hpgain=(mon.totalhp/16).floor
            hpgain=mon.pbRecoverHP(hpgain,true)
          end
      end
    end
  end
    for i in priority
      next if i.isFainted?
      case $fefieldeffect
        when 2 # Grassy Field
          next if i.hp<=0
          if !i.isAirborne? 
            if i.effects[PBEffects::HealBlock]==0 && i.totalhp != i.hp
              pbDisplay(_INTL("The grassy terrain healed the Pokemon on the field.",i.pbThis)) if endmessage == false
              endmessage=true
              hpgain=(i.totalhp/16).floor
              hpgain=(hpgain*1.3).floor if isConst?(i.item,PBItems,:BIGROOT)
              hpgain=i.pbRecoverHP(hpgain,true)
            end
          end
        when 7 # Volcanic Field
          next if i.hp<=0
          if !i.isAirborne?     
            if isConst?(i.ability,PBAbilities,:FLASHFIRE)
              if !i.effects[PBEffects::FlashFire]
                i.effects[PBEffects::FlashFire]=true
                pbDisplay(_INTL("{1}'s {2} raised its Fire power!",
                i.pbThis,PBAbilities.getName(i.ability)))
              end
            end
            if !i.pbHasType?(:FIRE) && !i.effects[PBEffects::AquaRing] &&
             !isConst?(i.ability,PBAbilities,:FLAREBOOST) &&
             !isConst?(i.ability,PBAbilities,:MAGICGUARD) &&
             !isConst?(i.ability,PBAbilities,:WATERVEIL) &&
             !isConst?(i.ability,PBAbilities,:FLASHFIRE) &&
             !isConst?(i.ability,PBAbilities,:HEATPROOF) &&
             !SilvallyCheck(i,PBTypes::STEEL) &&
             !i.isBoss &&
             !isConst?(i.ability,PBAbilities,:MAGMAARMOR) &&
             !isConst?(i.ability,PBAbilities,:FLAMEBODY) &&
             ![0xCA,0xCB].include?(PBMoveData.new(i.effects[PBEffects::TwoTurnAttack]).function) # Dig, Dive
              atype=getConst(PBTypes,:FIRE) || 0
              eff=PBTypes.getCombinedEffectiveness(atype,i.type1,i.type2)
              if isConst?(i.species,PBSpecies,:LEAFEON) && i.hasWorkingItem(:LEAFCREST)
                eff = 4
              end
              if i.effects[PBEffects::TarShot]==true
                eff *= 2
              end
              if eff>0
                @scene.pbDamageAnimation(i,0)
                if isConst?(i.ability,PBAbilities,:LEAFGUARD) ||
                 isConst?(i.ability,PBAbilities,:ICEBODY) ||
                 isConst?(i.ability,PBAbilities,:FLUFFY) ||
                 isConst?(i.ability,PBAbilities,:GRASSPELT)
                  eff = eff*2
                end
                pbDisplay(_INTL("The Pokemon were burned by the field!",i.pbThis)) if endmessage == false
                endmessage=true
                i.pbReduceHP([(i.totalhp*eff/32).floor,1].max)
                if i.hp<=0
                  return if !i.pbFaint
                end
              end
            end
          end
        when 10 # Corrosive Field
          next if i.hp<=0
          if i.hasWorkingAbility(:GRASSPELT)        
            @scene.pbDamageAnimation(i,0)
            i.pbReduceHP((i.totalhp/8).floor)
            pbDisplay(_INTL("{1}'s Pelt was corroded!",i.pbThis)) if hpgain>0
            if i.hp<=0
              return if !i.pbFaint
            end
          end 
          if i.hasWorkingAbility(:POISONHEAL)
            if !i.isAirborne?     
              if i.effects[PBEffects::HealBlock]==0
                if i.hp<i.totalhp
                  pbCommonAnimation("Poison",i,nil)
                  i.pbRecoverHP((i.totalhp/8).floor,true)
                  pbDisplay(_INTL("{1} was healed by poison!",i.pbThis))
                end
              end
            end
          end
        when 11 # Corrosive Mist Field
          if i.pbCanPoison?(false) && pbCheckGlobalAbility(:NEUTRALIZINGGAS)==nil
            pbDisplay(_INTL("The Pokemon were poisoned by the corroded mist!",i.pbThis))   if endmessage == false
            endmessage=true
            i.pbPoison(i)
          end
          if isConst?(i.ability,PBAbilities,:POISONHEAL)
            if i.effects[PBEffects::HealBlock]==0
              if i.hp<i.totalhp
                pbCommonAnimation("Poison",i,nil)
                i.pbRecoverHP((i.totalhp/8).floor,true)
                pbDisplay(_INTL("{1} was healed by poison!",i.pbThis))
              end
            end
          end
        when 15 # Forest Field      
          next if i.hp<=0
          if i.hasWorkingAbility(:SAPSIPPER) && i.effects[PBEffects::HealBlock]==0        
            hpgain=(i.totalhp/16).floor
            hpgain=i.pbRecoverHP(hpgain,true)
            pbDisplay(_INTL("{1} drank tree sap to recover!",i.pbThis)) if hpgain>0
          end
        when 16 # Volcano Top Field
# eruption check - insane, too much, but makes typh op, so i no question
          next if i.hp<=0
          if @eruption
            if i.pbHasType?(:FIRE) ||
               i.hasWorkingAbility(:MAGMAARMOR) || i.hasWorkingAbility(:FLASHFIRE) ||
               i.hasWorkingAbility(:FLAREBOOST) || i.hasWorkingAbility(:BLAZE) ||
               i.hasWorkingAbility(:FLAMEBODY) || i.hasWorkingAbility(:SOLIDROCK) ||
               i.hasWorkingAbility(:STURDY) || i.hasWorkingAbility(:BATTLEARMOR) ||
               isConst?(i.species,PBSpecies,:GIRATINA) || 
               i.hasWorkingAbility(:SHELLARMOR) || i.hasWorkingAbility(:WATERBUBBLE) ||
               i.hasWorkingAbility(:MAGICGUARD) || i.hasWorkingAbility(:WONDERGUARD) ||
               i.hasWorkingAbility(:PRISMARMOR) || i.effects[PBEffects::AquaRing] ||
               i.pbOwnSide.effects[PBEffects::WideGuard] || (i.pbOwnSide.effects[PBEffects::AreniteWall]>0) || 
               SilvallyCheck(i,PBTypes::ROCK)
              pbDisplay(_INTL("{1} is immune to the eruption!",i.pbThis))
            else
              atype=getConst(PBTypes,:FIRE) || 0
              denominator = 4.0
              denominator = 8.0 if PBTypes.isNormalEffective?(atype,i.type1,i.type2) 
              denominator = 16.0 if PBTypes.isNotVeryEffective?(atype,i.type1,i.type2)
              denominator *= 2 if (i.hasWorkingAbility(:THICKFAT) || SilvallyCheck(i,PBTypes::ICE))
              denominator /= 1.25 if (i.effects[PBEffects::TarShot])
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP([(i.totalhp/denominator).floor,1].max)
              pbDisplay(_INTL("{1} is hurt by the eruption!",i.pbThis))
              if i.hp<=0
                return if !i.pbFaint
              end
            end
            if i.hasWorkingAbility(:MAGMAARMOR)
              boost = false
              if !i.pbTooHigh?(PBStats::DEFENSE)
                i.pbIncreaseStatBasic(PBStats::DEFENSE,1)
                pbCommonAnimation("StatUp",i,nil)
                boost=true
              end
              if !i.pbTooHigh?(PBStats::SPDEF)
                i.pbIncreaseStatBasic(PBStats::SPDEF,1)
                pbCommonAnimation("StatUp",i,nil)
                boost=true
              end
              if boost
                pbDisplay(_INTL("{1}'s Magma Armor raised its defenses!",i.pbThis))
              end
            end
            if i.hasWorkingAbility(:FLAREBOOST)
              if !i.pbTooHigh?(PBStats::SPATK)
                i.pbIncreaseStatBasic(PBStats::SPATK,1)
                pbCommonAnimation("StatUp",i,nil)
                pbDisplay(_INTL("{1}'s Flare Boost raised its Sp. Attack!",i.pbThis))
              end
            end
            if isConst?(i.ability,PBAbilities,:FLASHFIRE)
              if !i.effects[PBEffects::FlashFire]
                i.effects[PBEffects::FlashFire]=true
                pbDisplay(_INTL("{1}'s {2} raised its Fire power!",
                i.pbThis,PBAbilities.getName(i.ability)))
              end
            end
            if isConst?(i.ability,PBAbilities,:BLAZE)
              if !i.effects[PBEffects::Blazed]
                i.effects[PBEffects::Blazed]=true
                pbDisplay(_INTL("{1}'s {2} raised its Fire power!",
                i.pbThis,PBAbilities.getName(i.ability)))
              end
            end
            if i.status==PBStatuses::SLEEP && !isConst?(i.ability,PBAbilities,:SOUNDPROOF)
              i.pbCureStatus
              pbDisplay(_INTL("{1} woke up due to the eruption!",i.pbThis))
            end
          end
# eruption check - insane, too much, but makes typh op, so i no question
        when 18 # Shortcircuit Field
          next if i.hp<=0
          if i.hasWorkingAbility(:VOLTABSORB) && i.effects[PBEffects::HealBlock]==0       
            hpgain=(i.totalhp/16).floor
            hpgain=i.pbRecoverHP(hpgain,true)
            pbDisplay(_INTL("{1} absorbed stray electricity!",i.pbThis)) if hpgain>0
          end
        when 19 # Wasteland
          if i.hasWorkingAbility(:POISONHEAL)
            if !i.isAirborne?     
              if i.effects[PBEffects::HealBlock]==0
                if i.hp<i.totalhp
                  pbCommonAnimation("Poison",i,nil)
                  i.pbRecoverHP((i.totalhp/8).floor,true)
                  pbDisplay(_INTL("{1} was healed by poison!",i.pbThis))
                end
              end
            end
          end
        when 21 # Water Surface
          next if i.hp<=0
          if i.hasWorkingAbility(:WATERABSORB) && i.effects[PBEffects::HealBlock]==0
            if !i.isAirborne?
              hpgain=(i.totalhp/16).floor
              hpgain=i.pbRecoverHP(hpgain,true)
              pbDisplay(_INTL("{1} absorbed some of the water!",i.pbThis)) if hpgain>0
            end
          end
          if i.effects[PBEffects::TarShot]==true
            pbCommonAnimation("StatUp",i,nil)
            pbDisplay(_INTL("{1} was cleansed of Tar Shot!",i.pbThis))
          end
        when 22 # Underwater
          next if i.hp<=0
          if !i.pbHasType?(:WATER) &&
           !i.hasWorkingAbility(:SWIFTSWIM) &&
           !i.hasWorkingAbility(:MAGICGUARD)
            atype=getConst(PBTypes,:WATER) || 0
            eff=PBTypes.getCombinedEffectiveness(atype,i.type1,i.type2)
            if eff>4
              @scene.pbDamageAnimation(i,0)
              if i.hasWorkingAbility(:FLAMEBODY) ||
               i.hasWorkingAbility(:MAGMAARMOR)
                eff = eff*2
              end
              i.pbReduceHP([(i.totalhp*eff/32).floor,1].max)
              pbDisplay(_INTL("{1} struggled in the water!",i.pbThis))
              if i.hp<=0
                return if !i.pbFaint
              end
            end
          end
        when 26 # Murkwater Surface
          if !i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON) &&
           !i.hasWorkingAbility(:POISONHEAL) &&
           !i.hasWorkingAbility(:MAGICGUARD) &&
           !i.hasWorkingAbility(:WONDERGUARD) &&
           !i.hasWorkingAbility(:SURGESURFER) &&
           !i.hasWorkingAbility(:TOXICBOOST) &&
           !i.hasWorkingAbility(:IMMUNITY) &&
           !i.hasWorkingAbility(:PASTELVEIL)
            atype=getConst(PBTypes,:POISON) || 0
            eff=PBTypes.getCombinedEffectiveness(atype,i.type1,i.type2)
            if i.hasWorkingAbility(:FLAMEBODY) ||
             i.hasWorkingAbility(:MAGMAARMOR) ||
             i.hasWorkingAbility(:DRYSKIN) ||
             i.hasWorkingAbility(:WATERABSORB)
              eff = eff*2
            end
            if PBMoveData.new(i.effects[PBEffects::TwoTurnAttack]).function==0xCB && !(i.pbHasType?(:STEEL) || i.pbHasType?(:POISON))# Dive
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP([(i.totalhp*eff/8).floor,1].max)
              pbDisplay(_INTL("{1} suffocated underneath the toxic water!",i.pbThis))
            else
              if !i.isAirborne?
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP([(i.totalhp*eff/32).floor,1].max)
                pbDisplay(_INTL("{1} was hurt by the toxic water!",i.pbThis))
              end
            end
          end
          if i.isFainted?
            return if !i.pbFaint
          end
          if i.hasWorkingAbility(:POISONHEAL)
            if !i.isAirborne?     
              if i.effects[PBEffects::HealBlock]==0
                if i.hp<i.totalhp
                  pbCommonAnimation("Poison",i,nil)
                  i.pbRecoverHP((i.totalhp/8).floor,true)
                  pbDisplay(_INTL("{1} was healed by poisoned water!",i.pbThis))
                end
              end
            end
          end
          if i.pbHasType?(:POISON) && (i.hasWorkingAbility(:WATERABSORB) || i.hasWorkingAbility(:DRYSKIN))
            if !i.isAirborne?     
              if i.effects[PBEffects::HealBlock]==0
                if i.hp<i.totalhp
                  pbCommonAnimation("Poison",i,nil)
                  i.pbRecoverHP((i.totalhp/8).floor,true)
                  pbDisplay(_INTL("{1} was healed by the poisoned water!",i.pbThis))
                end
              end
            end
          end
        when 35 # New World
          $fecounter = 1
        when 38 # Dimension Field
          if i.effects[PBEffects::HealBlock]!=0
            @scene.pbDamageAnimation(i,0)
            i.pbReduceHP((i.totalhp/16).floor)
            pbDisplay(_INTL("{1} was damaged by the Heal Block!",i.pbThis))
            if i.hp<=0
              return if !i.pbFaint
            end
          end
        when 41 # Corrupted Cave Field
          next if i.hp<=0
          if i.hasWorkingAbility(:GRASSPELT) || i.hasWorkingAbility(:LEAFGUARD) ||
           i.hasWorkingAbility(:FLOWERVEIL) || SilvallyCheck(i,PBTypes::GRASS)
            @scene.pbDamageAnimation(i,0)
            i.pbReduceHP((i.totalhp/8).floor)
            pbDisplay(_INTL("{1}'s foliage caused harm!",i.pbThis))
            if i.hp<=0
              return if !i.pbFaint
            end
          end 
          if i.hasWorkingAbility(:POISONHEAL)
            if !i.isAirborne?     
              if i.effects[PBEffects::HealBlock]==0
                if i.hp<i.totalhp
                  pbCommonAnimation("Poison",i,nil)
                  i.pbRecoverHP((i.totalhp/8).floor,true)
                  pbDisplay(_INTL("{1} was healed in the corruption!",i.pbThis))
                end
              end
            end
          end
          if !i.isAirborne? && !i.pbHasType?(:POISON) && !i.isBoss &&
           !i.hasWorkingAbility(:WONDERSKIN) && !i.hasWorkingAbility(:IMMUNITY) &&
           !i.hasWorkingAbility(:PASTELVEIL)
            if i.pbCanPoison?(false)
              pbDisplay(_INTL("{1} was poisoned!",i.pbThis)) if endmessage == false
              endmessage=true
              i.pbPoison(i)
            end
          end
        when 42 # Bewitched Woods
          next if i.hp<=0
          if !i.isAirborne? && i.pbHasType?(:GRASS)
            if i.effects[PBEffects::HealBlock]==0 && i.totalhp != i.hp
              pbDisplay(_INTL("The woods healed the grass Pokemon on the field.",i.pbThis)) if endmessage == false
              endmessage=true
              if !(@field.effects[PBEffects::GrassyTerrain]>0)
                hpgain=(i.totalhp/16).floor
              else
                hpgain=(i.totalhp/8).floor 
              end
              hpgain=(hpgain*1.3).floor if isConst?(i.item,PBItems,:BIGROOT)
              hpgain=i.pbRecoverHP(hpgain,true)
            end
          end
          if i.hasWorkingAbility(:NATURALCURE) || (i.hasWorkingAbility(:TRACE) &&
            i.effects[PBEffects::TracedAbility]==30)
            i.status=0
          end
        when 45 # Infernal Field  
          next if i.hp<=0  
          if !i.isAirborne?       
            if i.effects[PBEffects::Torment]  
              @scene.pbDamageAnimation(i,0)  
              i.pbReduceHP((i.totalhp/8).floor)  
              pbDisplay(_INTL("{1} was damaged by the torment!",i.pbThis))  
              if i.hp<=0  
                return if !i.pbFaint  
              end  
            end  
            if isConst?(i.ability,PBAbilities,:FLASHFIRE)  
              if !i.effects[PBEffects::FlashFire]  
                i.effects[PBEffects::FlashFire]=true  
                pbDisplay(_INTL("{1}'s {2} raised its Fire power!",  
                i.pbThis,PBAbilities.getName(i.ability)))  
              end  
            end  
          end
      end
    end
    if $fefieldeffect == 11 && pbCheckGlobalAbility(:NEUTRALIZINGGAS)
      pbDisplay(_INTL("Neutralizing Gas prevents poisoning."))
    end
    for i in priority
      if @field.effects[PBEffects::GrassyTerrain]>0 
        if  !($fefieldeffect==2 || $fefieldeffect==42) # Grassy Terrain - Terrain Overlay
          next if i.hp<=0   
          if !i.isAirborne? 
            if i.effects[PBEffects::HealBlock]==0 && i.totalhp != i.hp
              pbDisplay(_INTL("The grassy terrain healed the Pokemon on the field.",i.pbThis)) if endmessage == false
              endmessage=true
              hpgain=(i.totalhp/16).floor
              hpgain=i.pbRecoverHP(hpgain,true)
            end
          end
        end  
        if !($fefieldeffect==15)
          next if i.hp<=0   
          if !i.isAirborne? 
            if i.hasWorkingAbility(:SAPSIPPER) && i.effects[PBEffects::HealBlock]==0  && i.totalhp != i.hp
              endmessage=true  
              hpgain=(i.totalhp/16).floor
              hpgain=i.pbRecoverHP(hpgain,true)
              pbDisplay(_INTL("{1} ate away at some grass to recover!",i.pbThis)) if hpgain>0
            end
          end
        end
      end
    end
# eruption check
    if $fefieldeffect == 16
      if @eruption
        hazardsOnSide = false
        for i in priority
          if i.effects[PBEffects::LeechSeed]>=0
            i.effects[PBEffects::LeechSeed] = -1
            pbDisplay(_INTL("{1}'s Leech Seed burned away in the eruption!",i.pbThis))
          end
          if i.pbOwnSide.effects[PBEffects::Spikes]>0
            i.pbOwnSide.effects[PBEffects::Spikes]=0
            hazardsOnSide = true
          end
          if i.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
            i.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
            hazardsOnSide = true
          end
          if i.pbOwnSide.effects[PBEffects::StealthRock]
            i.pbOwnSide.effects[PBEffects::StealthRock]=false
            hazardsOnSide = true
          end
          if i.pbOwnSide.effects[PBEffects::StickyWeb]
            i.pbOwnSide.effects[PBEffects::StickyWeb]=false
            hazardsOnSide = true
          end
        end
        if hazardsOnSide
          pbDisplay(_INTL("The eruption removed all hazards from the field!"))
        end
      end
    end
# eruption check
  # End Field stuff
  if $fefieldeffect == 34
    for i in priority
      if i.hasWorkingAbility(:WORLDOFNIGHTMARES)
        $fecounter=i.turncount
        if $fecounter==8
          $fefieldeffect = 35
          pbChangeBGSprite
          pbDisplay(_INTL("The New World has taken shape!"))
          @weatherduration=0
          @field.effects[PBEffects::Terrain]=0
          seedCheck
        end
      end
    end
  end
#### AME - 003 - END # Weather    
    if $fefieldeffect != 22
      if @weather != PBWeather::HAIL && $fefieldeffect == 27
        $fecounter = 0 
      end
    # Tempest
  for i in priority
    if i.hasWorkingAbility(:TEMPEST)
      weathers=rand(5)
      case weathers
       when 0
          @weather=PBWeather::RAINDANCE
          @weatherduration=8
          pbCommonAnimation("Rain",nil,nil)
          pbDisplay(_INTL("Storm-9 created a downpour!"))
       when 1
          @weather=PBWeather::HAIL
          @weatherduration=8
          pbCommonAnimation("Hail",nil,nil)
          pbDisplay(_INTL("Storm-9 brought hailfall!"))
       when 2
          @weather=PBWeather::SANDSTORM
          @weatherduration=8
          pbCommonAnimation("Sandstorm",nil,nil)
          pbDisplay(_INTL("Storm-9 whipped up a duststorm!"))
       when 3
          @weather=PBWeather::STRONGWINDS
          @weatherduration=8
          pbCommonAnimation("Wind",nil,nil)
          pbDisplay(_INTL("Storm-9 whipped up terrible winds!"))
       when 4
          @weather=PBWeather::SHADOWSKY
          @weatherduration=8
          pbCommonAnimation("ShadowSky",nil,nil)
          pbDisplay(_INTL("Storm-9 shrouded the sky in a dark aura..."))
       end
     end
  end
    case @weather
      when PBWeather::SUNNYDAY
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sunlight faded."))
          @weather=0
          #### DemICE - persistentweather - START
          if @weatherbackup!=0  
            pbCommonAnimation(@weatherbackupanim,nil,nil)                    
            @weather=@weatherbackup
            @weatherduration=-1
            pbDisplay(_INTL("The initial weather took over again!"))
          end
          #### DemICE
          if $febackup == 34
            $febackup=$fefieldeffect
            $fefieldeffect = 34
            pbChangeBGSprite
            pbDisplay(_INTL("The starry sky shone through!"));
            seedCheck
          end
        else
          pbCommonAnimation("Sunny",nil,nil)
          if $fefieldeffect == 34 # Starlight Arena
            if $fefieldeffect == $febackup 
              $fefieldeffect = 0
            else
              $fefieldeffect = $febackup
              $febackup= 34
            end
            pbChangeBGSprite
            pbDisplay(_INTL("The sunlight eclipsed the starry sky!"));
            seedCheck
          end
#          pbDisplay(_INTL("The sunlight is strong."));
          for i in priority
            next if i.isFainted?
            if (i.hasWorkingAbility(:SOLARPOWER) || 
               (isConst?(i.species,PBSpecies,:CASTFORM) && isConst?(i.item,PBItems,:CASTCREST) && i.form==1))
              pbDisplay(_INTL("{1} was hurt by the sunlight!",i.pbThis))
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP((i.totalhp/8).floor)
              if i.isFainted?
                return if !i.pbFaint
              end
            end
            if $fefieldeffect == 12
              if i.pbHasType?(:WATER) || i.pbHasType?(:GRASS)
                pbDisplay(_INTL("{1} was hurt by the sunlight!",i.pbThis))
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP((i.totalhp/8).floor)
                if i.isFainted?
                  return if !i.pbFaint
                end
              end
            end
          end
        end
      when PBWeather::RAINDANCE
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The rain stopped."))
          @weather=0
          #### DemICE  - persistentweather - START
          if @weatherbackup!=0  
            pbCommonAnimation(@weatherbackupanim,nil,nil)                    
            @weather=@weatherbackup
            @weatherduration=-1
            pbDisplay(_INTL("The initial weather took over again!"))
          end  
          #### DemICE
          if $febackup == 34
            $febackup=$fefieldeffect
            $fefieldeffect = 34
            pbChangeBGSprite
            pbDisplay(_INTL("The starry sky shone through!"));
            seedCheck
          end
        elsif $fefieldeffect == 45  
          pbDisplay(_INTL("The rain evaporated away."))  
          @weather=0
        else
          pbCommonAnimation("Rain",nil,nil)
#         pbDisplay(_INTL("Rain continues to fall."));
          if $fefieldeffect == 7 # Burning Field
            if $fefieldeffect == $febackup 
              $fefieldeffect = 23
            else
              $febackup = 7
              $fefieldeffect = $febackup
            end
            pbChangeBGSprite
            pbDisplay(_INTL("The rain snuffed out the flame!"));
            seedCheck
          end
          if $fefieldeffect == 34 # Starlight Arena
            if $fefieldeffect == $febackup 
              $fefieldeffect = 0
            else
              $fefieldeffect = $febackup
              $febackup= 34
            end
            pbChangeBGSprite
            pbDisplay(_INTL("The weather blocked out the starry sky!"));
            seedCheck
          end
        end
      when PBWeather::SANDSTORM
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sandstorm subsided."))
          @weather=0
          #### DemICE  - persistentweather - START
          if @weatherbackup!=0  
            pbCommonAnimation(@weatherbackupanim,nil,nil)                    
            @weather=@weatherbackup
            @weatherduration=-1
            pbDisplay(_INTL("The initial weather took over again!"))
          end
          #### DemICE
          if $febackup == 34
            $febackup=$fefieldeffect
            $fefieldeffect = 34
            pbChangeBGSprite
            pbDisplay(_INTL("The starry sky shone through!"));
            seedCheck
          end
        else
          pbCommonAnimation("Sandstorm",nil,nil)
#         pbDisplay(_INTL("The sandstorm rages."))
          if $fefieldeffect == 7 # Burning Field
            if $fefieldeffect == $febackup 
              $fefieldeffect = 23
            else
              $febackup = 7
              $fefieldeffect = $febackup
            end
            pbChangeBGSprite
            pbDisplay(_INTL("The sand snuffed out the flame!"));
            seedCheck
          end
          if ($fefieldeffect == 9 && $febackup!=$fefieldeffect) || @field.effects[PBEffects::Rainbow]>0 # Rainbow Field ### Azery
            if $fefieldeffect == $febackup
              if @field.effects[PBEffects::Rainbow]>0
                $fefieldeffect = $febackup
              else
                $fefieldeffect = 0
              end
            else
              $fefieldeffect = $febackup
            end
            pbChangeBGSprite
            @field.effects[PBEffects::Rainbow]=0
            pbDisplay(_INTL("The weather blocked out the rainbow!"));
            seedCheck
          end
          if $fefieldeffect == 34 # Starlight Arena
            if $fefieldeffect == $febackup 
              $fefieldeffect = 0
            else
              $fefieldeffect = $febackup
              $febackup = 34
            end
            pbChangeBGSprite
            pbDisplay(_INTL("The weather blocked out the starry sky!"));
            seedCheck
          end
          if pbWeather==PBWeather::SANDSTORM
            endmessage=false
            for i in priority
              next if i.isFainted?
              if (!i.pbHasType?(:GROUND) && !i.pbHasType?(:ROCK) && !i.pbHasType?(:STEEL) &&
               !i.hasWorkingAbility(:SANDVEIL) &&
               !i.hasWorkingAbility(:SANDRUSH) &&
               !i.hasWorkingAbility(:SANDFORCE) &&
               !i.hasWorkingAbility(:TEMPEST) &&
               !i.hasWorkingAbility(:MAGICGUARD) &&
               !(i.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44) &&
               !isConst?(i.item,PBItems,:SAFETYGOGGLES) &&
               !i.hasWorkingAbility(:OVERCOAT) &&
               ![0xCA,0xCB].include?(PBMoveData.new(i.effects[PBEffects::TwoTurnAttack]).function)) || i.effects[PBEffects::DesertsMark]
                pbDisplay(_INTL("The Pokemon were buffeted by the sandstorm!",i.pbThis)) if endmessage==false
                endmessage=true
                @scene.pbDamageAnimation(i,0)
                if i.effects[PBEffects::ShieldLife]>0
                  sanddamage=i.totalhp/16
                  pbShieldDamage(i,sanddamage)
                else
                  if $fefieldeffect == 12
                    i.pbReduceHP((i.totalhp/8).floor)
                  else
                    i.pbReduceHP((i.totalhp/16).floor)
                  end
                end
                if i.isFainted?
                  return if !i.pbFaint
                end
              end
            end
          end
        end
      when PBWeather::HAIL
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The hail stopped."))
          @weather=0
          #### DemICE - persistentweather - START
          if @weatherbackup!=0  
            pbCommonAnimation(@weatherbackupanim,nil,nil)                    
            @weather=@weatherbackup
            @weatherduration=-1
            pbDisplay(_INTL("The initial weather took over again!"))
          end  
          #### DemICE
          if $febackup == 34
            $febackup=$fefieldeffect
            $fefieldeffect = 34
            pbChangeBGSprite
            pbDisplay(_INTL("The starry sky shone through!"));
            seedCheck
          end
        elsif $fefieldeffect == 16 || $fefieldeffect == 7
          pbDisplay(_INTL("The hail melted away."))
          @weather=0
          if @weatherbackup!=0  
            pbCommonAnimation(@weatherbackupanim,nil,nil)                    
            @weather=@weatherbackup
            @weatherduration=-1
            pbDisplay(_INTL("The initial weather took over again!"))
          end  
        elsif $fefieldeffect == 32
          pbDisplay(_INTL("The hail melted away."))  
          @weather=0
          if @weatherbackup!=0  
            pbCommonAnimation(@weatherbackupanim,nil,nil)                    
            @weather=@weatherbackup
            @weatherduration=-1
            pbDisplay(_INTL("The initial weather took over again!"))
          end  
        elsif $fefieldeffect == 45  
          pbDisplay(_INTL("The hail melted away."))  
          @weather=0
          if @weatherbackup!=0  
            pbCommonAnimation(@weatherbackupanim,nil,nil)                    
            @weather=@weatherbackup
            @weatherduration=-1
            pbDisplay(_INTL("The initial weather took over again!"))
          end  
        else
          pbCommonAnimation("Hail",nil,nil)
#         pbDisplay(_INTL("Hail continues to fall."))
          if ($fefieldeffect == 9 && $febackup!=$fefieldeffect) || @field.effects[PBEffects::Rainbow]>0 # Rainbow Field ### Azery
            if $fefieldeffect == $febackup
              if @field.effects[PBEffects::Rainbow]>0
                $fefieldeffect = $febackup
              else
                $fefieldeffect = 0
              end
            else
              $fefieldeffect = $febackup
            end
            pbChangeBGSprite
            @field.effects[PBEffects::Rainbow]=0
            pbDisplay(_INTL("The weather blocked out the rainbow!"));
            seedCheck
          end
          if $fefieldeffect == 34 # Starlight Arena
            if $fefieldeffect == $febackup 
              $fefieldeffect = 0
            else
              $fefieldeffect = $febackup
              $febackup = 34
            end
            pbChangeBGSprite
            pbDisplay(_INTL("The weather blocked out the starry sky!"));
            seedCheck
          end
          if pbWeather==PBWeather::HAIL
            endmessage=false
            for i in priority
              next if i.isFainted?
              if !i.pbHasType?(:ICE) &&
                 !i.hasWorkingAbility(:ICEBODY) &&
                 !i.hasWorkingAbility(:SNOWCLOAK) &&
                 !i.hasWorkingAbility(:TEMPEST) &&
                 !i.hasWorkingAbility(:MAGICGUARD) &&
                 !(i.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44) &&
                 !isConst?(i.item,PBItems,:SAFETYGOGGLES) &&
                 !i.hasWorkingAbility(:OVERCOAT) &&
                 !(isConst?(i.species,PBSpecies,:EMPOLEON) && i.hasWorkingItem(:EMPCREST)) &&
                 ![0xCA,0xCB].include?(PBMoveData.new(i.effects[PBEffects::TwoTurnAttack]).function) # Dig, Dive
                pbDisplay(_INTL("The Pokemon were buffeted by the hail!",i.pbThis)) if endmessage==false
                endmessage=true
                @scene.pbDamageAnimation(i,0)
                if i.effects[PBEffects::ShieldLife]>0
                  haildamage=i.totalhp/16
                  pbShieldDamage(i,haildamage)
                else
                  if $fefieldeffect == 39
                    i.pbReduceHP((i.totalhp/8).floor)
                  else
                    i.pbReduceHP((i.totalhp/16).floor)
                  end
                end
                if i.isFainted?
                  return if !i.pbFaint
                end
              end
            end
            if $fefieldeffect  == 27
              $fecounter+=1
              if $fecounter == 3
                $fecounter = 0
                $fefieldeffect = 28
                pbChangeBGSprite
                pbDisplay(_INTL("The mountain was covered in snow!"))
                seedCheck
              end
            end
          end
        end
      when PBWeather::STRONGWINDS
          pbCommonAnimation("Wind",nil,nil)
#         pbDisplay(_INTL("The wind is strong."));
      end
    end
    # Shadow Sky weather
    if isConst?(@weather,PBWeather,:SHADOWSKY)
      @weatherduration=@weatherduration-1 if @weatherduration>0
      if @weatherduration==0
        pbDisplay(_INTL("The shadow sky faded."))
        @weather=0
      else
        pbCommonAnimation("ShadowSky",nil,nil)
#        pbDisplay(_INTL("The shadow sky continues."));
        if isConst?(pbWeather,PBWeather,:SHADOWSKY)
          for i in priority
            next if i.isFainted?
            if !i.isShadow? && !i.hasWorkingAbility(:TEMPEST) 
              pbDisplay(_INTL("{1} was hurt by the shadow sky!",i.pbThis))
              @scene.pbDamageAnimation(i,0)
              if $fefieldeffect == 38 || $fefieldeffect == 39
                  i.pbReduceHP((i.totalhp/8).floor)
                else
                  i.pbReduceHP((i.totalhp/16).floor)
              end
              if i.isFainted?
                return if !i.pbFaint
              end
            end
          end
        end
      end
    end
    # Temporal Shift
    for i in priority
      next if i.isFainted?
      if i.hasWorkingAbility(:TEMPORALSHIFT)
        for j in priority
          next if j.isFainted?
          if !(i==j || i.pbPartner==j || j.pbHasType?(:NORMAL)) && 
           j.effects[PBEffects::FutureSight]==0
            j.effects[PBEffects::FutureSight]=3 
            j.effects[PBEffects::FutureSightMove]=179
            j.effects[PBEffects::FutureSightUser]=i.index
            pbDisplay(_INTL("{1} casts a hex!",i.pbThis))
            break
          end
        end
      end
    end
    
    # Future Sight/Doom Desire
    for i in battlers   # not priority
      if i.isFainted? && i.effects[PBEffects::FutureSight]>0
        i.effects[PBEffects::FutureSight]-=1
        if i.effects[PBEffects::FutureSight]==0
          i.effects[PBEffects::FutureSightMove]=0
          i.effects[PBEffects::FutureSightDamage]=0
          i.effects[PBEffects::FutureSightUser]=-1
        end
      end
      next if i.isFainted?
      if i.effects[PBEffects::FutureSight]>0
        i.effects[PBEffects::FutureSight]-=1
        if i.effects[PBEffects::FutureSight]==0
          moveuser=@battlers[i.effects[PBEffects::FutureSightUser]]
          if i.effects[PBEffects::FutureSightMove] == 516 #DoomDesire
            move=PokeBattle_Move.pbFromPBMove(self,PBMove.new(741),moveuser) #DoomDummy
            type=getConst(PBTypes,:STEEL)
          elsif i.effects[PBEffects::FutureSightMove] == 450 #FutureSight
            move=PokeBattle_Move.pbFromPBMove(self,PBMove.new(740),moveuser) #FutureDummy
            type=getConst(PBTypes,:PSYCHIC)
          elsif i.effects[PBEffects::FutureSightMove] == 179 #FutureSight
            move=PokeBattle_Move.pbFromPBMove(self,PBMove.new(754),moveuser) #HexDummy
            type=getConst(PBTypes,:GHOST)
          end
          pbDisplay(_INTL("{1} took the {2} attack!",i.pbThis,move.name))
          typemod = move.pbTypeModifierNonBattler(type,moveuser,i) # added
          if i.isFainted? || move.pbAccuracyCheck(moveuser,i) && 
           !(i.hasWorkingAbility(:WONDERGUARD) && typemod<=4)
            i.damagestate.reset
            damage = nil
            if i.effects[PBEffects::FutureSightMove] == 450 && !(i.pbHasType?(:DARK))
              pbAnimation(740,i,nil)
            elsif i.effects[PBEffects::FutureSightMove] == 516
              pbAnimation(741,i,nil)
            elsif i.effects[PBEffects::FutureSightMove] == 179
              pbAnimation(754,i,nil)
            end
            move.pbReduceHPDamage(damage,moveuser,i)
            move.pbEffectMessages(moveuser,i)
          elsif i.hasWorkingAbility(:WONDERGUARD) && typemod<=4 #added
            pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",i.pbThis)) #added
          else
            pbDisplay(_INTL("But it failed!"))
          end
          i.effects[PBEffects::FutureSight]=0
          i.effects[PBEffects::FutureSightMove]=0
          i.effects[PBEffects::FutureSightDamage]=0
          i.effects[PBEffects::FutureSightUser]=-1
          if i.isFainted?
            return if !i.pbFaint
            next
          end
        end
      end
    end
    for i in priority
      next if i.isFainted?
      # Meganium + Meganium Crest
      if (isConst?(i.species,PBSpecies,:MEGANIUM) && i.hasWorkingItem(:MEGCREST)) ||
       (isConst?(i.pbPartner.species,PBSpecies,:MEGANIUM) && i.pbPartner.hasWorkingItem(:MEGCREST))
        hpgain=i.pbRecoverHP((i.totalhp/16).floor,true)
        pbDisplay(_INTL("The Meganium Crest restored {1}'s HP a little!",i.pbThis(true))) if hpgain>0       
      end
      # Rain Dish
      if pbWeather==PBWeather::RAINDANCE && !i.hasWorkingItem(:UTILITYUMBRELLA) && (i.hasWorkingAbility(:RAINDISH) ||
       ( isConst?(i.species,PBSpecies,:CASTFORM) && isConst?(i.item,PBItems,:CASTCREST) && i.form==2) ) && i.effects[PBEffects::HealBlock]==0
        hpgain=i.pbRecoverHP((i.totalhp/16).floor,true)
        pbDisplay(_INTL("{1}'s Rain Dish restored its HP a little!",i.pbThis)) if hpgain>0
      end
      # Dry Skin
      if isConst?(i.ability,PBAbilities,:DRYSKIN)
        if pbWeather==PBWeather::RAINDANCE && !i.hasWorkingItem(:UTILITYUMBRELLA) && i.effects[PBEffects::HealBlock]==0 
          hpgain=i.pbRecoverHP((i.totalhp/8).floor,true)
          pbDisplay(_INTL("{1}'s Dry Skin was healed by the rain!",i.pbThis)) if hpgain>0
        elsif pbWeather==PBWeather::SUNNYDAY && !i.hasWorkingItem(:UTILITYUMBRELLA)
          @scene.pbDamageAnimation(i,0)
          hploss=i.pbReduceHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s Dry Skin was hurt by the sunlight!",i.pbThis)) if hploss>0
        elsif ($fefieldeffect == 11 || $fefieldeffect == 41) && !i.pbHasType?(:STEEL)
          if !i.pbHasType?(:POISON)
            @scene.pbDamageAnimation(i,0)
            hploss=i.pbReduceHP((i.totalhp/8).floor)
            pbDisplay(_INTL("{1}'s Dry Skin absorbed the poison!",i.pbThis)) if hploss>0
          elsif i.effects[PBEffects::HealBlock]==0
            hpgain=i.pbRecoverHP((i.totalhp/8).floor,true)
            pbDisplay(_INTL("{1}'s Dry Skin was healed by the poison!",i.pbThis)) if hpgain>0
          end
        elsif $fefieldeffect == 12
          @scene.pbDamageAnimation(i,0)
          hploss=i.pbReduceHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s Dry Skin was hurt by the desert air!",i.pbThis)) if hploss>0
        elsif ($fefieldeffect == 3 || $fefieldeffect == 8 || @field.effects[PBEffects::MistyTerrain]>0) && # Misty/Swamp Field 
          i.effects[PBEffects::HealBlock]==0     
          hpgain=(i.totalhp/16).floor
          hpgain=i.pbRecoverHP(hpgain,true)
          pbDisplay(_INTL("{1}'s Dry Skin was healed by the mist!",i.pbThis)) if hpgain>0
        elsif ($fefieldeffect == 21 || $fefieldeffect == 22) && #Water fields 
          i.effects[PBEffects::HealBlock]==0     
          hpgain=(i.totalhp/16).floor
          hpgain=i.pbRecoverHP(hpgain,true)
          pbDisplay(_INTL("{1}'s Dry Skin was healed by the water!",i.pbThis)) if hpgain>0
        end
      end
      # Druddigon Crest
      if isConst?(i.species,PBSpecies,:DRUDDIGON) && isConst?(i.item,PBItems,:DRUDDICREST)
        if pbWeather==PBWeather::SUNNYDAY && i.effects[PBEffects::HealBlock]==0 
          hpgain=i.pbRecoverHP((i.totalhp/8).floor,true)
          pbDisplay(_INTL("{1} was replenished by the sunlight!",i.pbThis)) if hpgain>0
        elsif $fefieldeffect == 7 || $fefieldeffect == 16 || $fefieldeffect == 32  # Volcanic/Volcano Top Field/Dragon's Den
          i.effects[PBEffects::HealBlock]==0     
          hpgain=(i.totalhp/16).floor
          hpgain=i.pbRecoverHP(hpgain,true)
          pbDisplay(_INTL("{1} was healed by the heat!",i.pbThis)) if hpgain>0
        end
      end
      # Ice Body
      if (pbWeather==PBWeather::HAIL || $fefieldeffect == 13 || $fefieldeffect == 39 ||
       $fefieldeffefct == 28) &&
       (i.hasWorkingAbility(:ICEBODY)) && 
       i.effects[PBEffects::HealBlock]==0
        hpgain=i.pbRecoverHP((i.totalhp/16).floor,true)
        pbDisplay(_INTL("{1}'s Ice Body restored its HP a little!",i.pbThis)) if hpgain>0
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Wish
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Wish]>0
        i.effects[PBEffects::Wish]-=1
        if i.effects[PBEffects::Wish]==0
          hpgain=i.pbRecoverHP(i.effects[PBEffects::WishAmount],true)
          if hpgain>0
            wishmaker=pbThisEx(i.index,i.effects[PBEffects::WishMaker])
            pbDisplay(_INTL("{1}'s wish came true!",wishmaker))
          end
        end
      end
    end
    # Fire Pledge + Grass Pledge combination damage - should go here
    for i in priority
      next if i.isFainted?
      # Shed Skin
      if i.hasWorkingAbility(:SHEDSKIN)
        if (pbRandom(10)<3 && i.status>0) || $fefieldeffect==32
          case i.status
            when PBStatuses::SLEEP
              pbDisplay(_INTL("{1}'s Shed Skin cured its sleep problem!",i.pbThis))
            when PBStatuses::FROZEN
              pbDisplay(_INTL("{1}'s Shed Skin cured its ice problem!",i.pbThis))
            when PBStatuses::BURN
              pbDisplay(_INTL("{1}'s Shed Skin cured its burn problem!",i.pbThis))
            when PBStatuses::POISON
              pbDisplay(_INTL("{1}'s Shed Skin cured its poison problem!",i.pbThis))
            when PBStatuses::PARALYSIS
              pbDisplay(_INTL("{1}'s Shed Skin cured its paralysis problem!",i.pbThis))
          end
          i.status=0
          i.statusCount=0
        end
      end
      # Hydration
      if i.hasWorkingAbility(:HYDRATION) && ((pbWeather==PBWeather::RAINDANCE && !i.hasWorkingItem(:UTILITYUMBRELLA)) ||
        $fefieldeffect == 21 || $fefieldeffect == 22)
        if i.status>0
          case i.status
            when PBStatuses::SLEEP
              pbDisplay(_INTL("{1}'s Hydration cured its sleep problem!",i.pbThis))
            when PBStatuses::FROZEN
              pbDisplay(_INTL("{1}'s Hydration cured its ice problem!",i.pbThis))
            when PBStatuses::BURN
              pbDisplay(_INTL("{1}'s Hydration cured its burn problem!",i.pbThis))
            when PBStatuses::POISON
              pbDisplay(_INTL("{1}'s Hydration cured its poison problem!",i.pbThis))
            when PBStatuses::PARALYSIS
              pbDisplay(_INTL("{1}'s Hydration cured its paralysis problem!",i.pbThis))
          end
          i.status=0
          i.statusCount=0
        end
      end
      # Steam Engine
      if i.hasWorkingAbility(:STEAMENGINE) && ($fefieldeffect == 7 || 
       $fefieldeffect == 16 || $fefieldeffect == 21 || $fefieldeffect == 22 ||  
       $fefieldeffect == 45)
        if !i.pbTooHigh?(PBStats::SPEED)
          i.pbIncreaseStatBasic(PBStats::SPEED,1)
          pbCommonAnimation("StatUp",i,nil)
          pbDisplay(_INTL("{1}'s Steam Engine raised its Speed!",i.pbThis))
        end
      end  
      # Wandering Spirit
      if i.hasWorkingAbility(:WANDERINGSPIRIT) && ($fefieldeffect == 12 ||
       $fefieldeffect == 40)
        if !i.pbTooLow?(PBStats::SPEED)
          i.pbReduceStatBasic(PBStats::SPEED,1)
          pbCommonAnimation("StatDown",i,nil)
          pbDisplay(_INTL("{1}'s Wandering Spirit lowered its Speed!",i.pbThis))
        end
      end
      if i.hasWorkingAbility(:WATERVEIL) && ($fefieldeffect == 21 || 
        $fefieldeffect == 22)
        if i.status>0
              pbDisplay(_INTL("{1}'s Water Veil cured its status problem!",i.pbThis))
          i.status=0
          i.statusCount=0
        end
      end
      # Healer
      if i.hasWorkingAbility(:HEALER)
        partner=i.pbPartner
        if partner
          if pbRandom(10)<3 && partner.status>0
            case partner.status
              when PBStatuses::SLEEP
                pbDisplay(_INTL("{1}'s Healer cured its partner's sleep problem!",i.pbThis))
              when PBStatuses::FROZEN
                pbDisplay(_INTL("{1}'s Healer cured its partner's ice problem!",i.pbThis))
              when PBStatuses::BURN
                pbDisplay(_INTL("{1}'s Healer cured its partner's burn problem!",i.pbThis))
              when PBStatuses::POISON
                pbDisplay(_INTL("{1}'s Healer cured its partner's poison problem!",i.pbThis))
              when PBStatuses::PARALYSIS
                pbDisplay(_INTL("{1}'s Healer cured its partner's paralysis problem!",i.pbThis))
            end
            partner.status=0
            partner.statusCount=0
          end
        end
      end
    end
    # Held berries/Leftovers/Black Sludge
    for i in priority
      next if i.isFainted?
      i.pbBerryCureCheck(true)
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Aqua Ring
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::AquaRing]
        if $fefieldeffect == 11 &&
         !i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON)
          @scene.pbDamageAnimation(i,0)
          i.pbReduceHP((i.totalhp/16).floor)
          pbDisplay(_INTL("{1}'s Aqua Ring absorbed poison!",i.pbThis)) if hpgain>0
          if i.hp<=0
            return if !i.pbFaint
          end
        elsif i.effects[PBEffects::HealBlock]==0
          hpgain=(i.totalhp/16).floor
          hpgain=(hpgain*1.3).floor if isConst?(i.item,PBItems,:BIGROOT)
          hpgain=(hpgain*2).floor if $fefieldeffect == 3 || 
           $fefieldeffect == 8 || $fefieldeffect == 21 || $fefieldeffect == 22
          hpgain=i.pbRecoverHP(hpgain,true)
          pbDisplay(_INTL("{1}'s Aqua Ring restored its HP a little!",i.pbThis)) if hpgain>0
        end
      end
    end
    # Ingrain
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Ingrain]
        if ($fefieldeffect == 8 || $fefieldeffect == 10 || $fefieldeffect == 41) &&
         (!i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON))
          @scene.pbDamageAnimation(i,0)
          i.pbReduceHP((i.totalhp/16).floor)
          pbDisplay(_INTL("{1} absorbed foul nutrients with its roots!",i.pbThis))
          if i.hp<=0
            return if !i.pbFaint
          end
        else
          if ($fefieldeffect == 33 && $fecounter >2)
            hpgain=(i.totalhp/4).floor            
          elsif ($fefieldeffect == 2 || @field.effects[PBEffects::GrassyTerrain]>0 || $fefieldeffect == 15 || ($fefieldeffect == 33 && $fecounter >0) || $fefieldeffect == 42)
            hpgain=(i.totalhp/8).floor
          elsif i.effects[PBEffects::HealBlock]==0
            hpgain=(i.totalhp/16).floor
          end
          if i.effects[PBEffects::HealBlock]==0
            hpgain=(hpgain*1.3).floor if isConst?(i.item,PBItems,:BIGROOT)
            hpgain=i.pbRecoverHP(hpgain,true)
            pbDisplay(_INTL("{1} absorbed nutrients with its roots!",i.pbThis)) if hpgain>0
          end
        end
      end
    end
    # Leech Seed
    for i in priority
      if i.hasWorkingAbility(:LIQUIDOOZE,true) && i.effects[PBEffects::LeechSeed]>=0
        recipient=@battlers[i.effects[PBEffects::LeechSeed]]
        if recipient && !recipient.isFainted? 
          hploss = (i.totalhp/8).floor
#          hploss = hploss * 2 if ($fefieldeffect == 19 || $fefieldeffect == 26 || $fefieldeffect == 41)
          pbCommonAnimation("LeechSeed",recipient,i)
          if i.effects[PBEffects::ShieldLife]>0
            leechdamage=i.totalhp/8
            pbShieldDamage(i,leechdamage)
          else
            i.pbReduceHP(hploss,true)
          end
          hploss = hploss * 2 if ($fefieldeffect == 19 || $fefieldeffect == 26 || $fefieldeffect == 41)
          recipient.pbReduceHP(hploss,true)
          pbDisplay(_INTL("{1} sucked up the liquid ooze!",recipient.pbThis))
          if i.isFainted?
            return if !i.pbFaint
          end
          if recipient.isFainted?
            return if !recipient.pbFaint
          end  
          next          
        end
      end
      next if i.isFainted?
      if (i.effects[PBEffects::LeechSeed]>=0) 
        recipient=@battlers[i.effects[PBEffects::LeechSeed]]
        if recipient && !recipient.isFainted?  && !i.hasWorkingAbility(:MAGICGUARD) &&  !(i.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44) # if recipient exists
          pbCommonAnimation("LeechSeed",recipient,i)
          if i.effects[PBEffects::ShieldLife]>0
            leechdamage=i.totalhp/8
            pbShieldDamage(i,leechdamage)
          else
            hploss=i.pbReduceHP((i.totalhp/8).floor,true)
          end
          hploss= hploss * 2 if $fefieldeffect == 19
          if i.hasWorkingAbility(:LIQUIDOOZE)
            recipient.pbReduceHP(hploss,true)
            pbDisplay(_INTL("{1} sucked up the liquid ooze!",recipient.pbThis))
            hploss= hploss / 2 if $fefieldeffect == 19 || $fefieldeffect == 26
          elsif recipient.effects[PBEffects::HealBlock]==0
            hploss=(hploss*1.3).floor if recipient.hasWorkingItem(:BIGROOT)
            recipient.pbRecoverHP(hploss,true)
            pbDisplay(_INTL("{1}'s health was sapped by Leech Seed!",i.pbThis))
          end
          if i.isFainted?          
            return if !i.pbFaint
          end
          if recipient.isFainted?
            return if !recipient.pbFaint
          end
        end
      end
    end
    for i in priority
      next if i.isFainted?
      if (i.effects[PBEffects::Petrification]>=0) 
        recipient=@battlers[i.effects[PBEffects::Petrification]]
        if recipient && !recipient.isFainted?  && !i.hasWorkingAbility(:MAGICGUARD) &&  !(i.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44) # if recipient exists
          pbCommonAnimation("Petrification",recipient,i)
          if i.effects[PBEffects::ShieldLife]>0
            petridamage=i.totalhp/8
            pbShieldDamage(i,petridamage)
          else
            hploss=i.pbReduceHP((i.totalhp/8).floor,true)
          end
          hploss= hploss * 2 if $fefieldeffect == 19
          recipient.effects[PBEffects::HealBlock]==0
          hploss=(hploss*1.3).floor if recipient.hasWorkingItem(:BIGROOT)
          recipient.pbRecoverHP(hploss,true)
          pbDisplay(_INTL("{1}'s health was drained by {2}!",i.pbThis,recipient.pbThis))
          if i.isFainted?          
            return if !i.pbFaint
          end
          if recipient.isFainted?
            return if !recipient.pbFaint
          end
        end
      end
    end
    for i in priority
      next if i.isFainted?
      # Poison/Bad poison
      if isConst?(i.species,PBSpecies,:ZANGOOSE) && isConst?(i.item,PBItems,:ZANGCREST)
        if i.pbCanPoison?(false)
          pbDisplay(_INTL("{1} was poisoned by the Zangoose Crest!",i.pbThis))
          i.pbPoison(i)
        end
      end
      if i.status==PBStatuses::POISON  && !i.hasWorkingAbility(:MAGICGUARD) &&  !(i.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
        if i.hasWorkingAbility(:POISONHEAL) || (isConst?(i.species,PBSpecies,:ZANGOOSE) &&
           isConst?(i.item,PBItems,:ZANGCREST))
          if i.effects[PBEffects::HealBlock]==0
            if i.hp<i.totalhp
              pbCommonAnimation("Poison",i,nil)
              i.pbRecoverHP((i.totalhp/8).floor,true)
              pbDisplay(_INTL("{1} is healed by poison!",i.pbThis))
            end
            if i.statusCount>0 && !i.isBoss
              i.effects[PBEffects::Toxic]+=1
              i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
            end
          end
        else
          i.pbContinueStatus
          if i.effects[PBEffects::ShieldLife]>0
            poisondamage=i.totalhp/8
            pbShieldDamage(i,poisondamage)
          elsif i.isBoss
            i.pbReduceHP((i.totalhp/16).floor)
          elsif (i.statusCount==0) 
            i.pbReduceHP((i.totalhp/8).floor)
          else            
            if !i.isBoss  
              i.effects[PBEffects::Toxic]+=1
              i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
              i.pbReduceHP((i.totalhp/16).floor*i.effects[PBEffects::Toxic])
            end
          end
        end
      end
      # Burn
      if i.status==PBStatuses::BURN &&!i.hasWorkingAbility(:MAGICGUARD) && !(i.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
        i.pbContinueStatus
        if i.effects[PBEffects::ShieldLife]>0
          burndamage=i.totalhp/16
          pbShieldDamage(i,burndamage)
        elsif i.hasWorkingAbility(:HEATPROOF) || SilvallyCheck(i,PBTypes::STEEL) || $fefieldeffect == 13 
          i.pbReduceHP((i.totalhp/32).floor)
        else
          i.pbReduceHP((i.totalhp/16).floor)
        end
      end
      # Nightmare
      if i.effects[PBEffects::Nightmare] && !i.hasWorkingAbility(:MAGICGUARD) &&  !(i.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44) &&
        $fefieldeffect != 9
        if i.status==PBStatuses::SLEEP || i.pbOpposing1.hasWorkingAbility(:WORLDOFNIGHTMARES) ||i.pbOpposing2.hasWorkingAbility(:WORLDOFNIGHTMARES)
          pbCommonAnimation("Nightmare",i,nil)
          pbDisplay(_INTL("{1} is locked in a nightmare!",i.pbThis))
          if i.effects[PBEffects::ShieldLife]>0
            nightmaredamage=i.totalhp/16
            pbShieldDamage(i,nightmaredamage)
          elsif i.isBoss
            nightmaredamage=i.totalhp/8
            pbShieldDamage(i,nightmaredamage)
          elsif $fefieldeffect == 40 
            i.pbReduceHP((i.totalhp/3).floor,true)
          else
            i.pbReduceHP((i.totalhp/4).floor,true)
          end
        else
          i.effects[PBEffects::Nightmare]=false
        end
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Curse
    for i in priority
      next if i.isFainted?
      if $fefieldeffect == 29 && i.effects[PBEffects::Curse]
        i.effects[PBEffects::Curse] = false
        pbDisplay(_INTL("{1}'s curse was lifted!",i.pbThis))
      end
      if i.effects[PBEffects::Curse] &&
          !i.hasWorkingAbility(:MAGICGUARD) &&
          !(i.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
          pbCommonAnimation("Curse",i,nil)
        pbDisplay(_INTL("{1} is afflicted by the curse!",i.pbThis))
        if i.effects[PBEffects::ShieldLife]>0 
          cursedamage=i.totalhp/8
          pbShieldDamage(i,cursedamage)
        else
          if !i.isBoss
            i.pbReduceHP((i.totalhp/4).floor,true)
          else
            i.pbReduceHP((i.totalhp/16).floor,true)
          end
        end
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Multi-turn attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::MultiTurn]>0 && !i.hasWorkingAbility(:MAGICGUARD)
        i.effects[PBEffects::MultiTurn]-=1
        movename=PBMoves.getName(i.effects[PBEffects::MultiTurnAttack])
        if i.effects[PBEffects::MultiTurn]==0
          pbDisplay(_INTL("{1} was freed from {2}!",i.pbThis,movename))
          $bindingband=0
        else
          pbDisplay(_INTL("{1} is hurt by {2}!",i.pbThis,movename))
          if isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:BIND)
            pbCommonAnimation("Bind",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:CLAMP)
            pbCommonAnimation("Clamp",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:FIRESPIN)
            pbCommonAnimation("FireSpin",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:MAGMASTORM)
            pbCommonAnimation("MagmaStorm",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:SANDTOMB)
            pbCommonAnimation("SandTomb",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:WRAP)
            pbCommonAnimation("Wrap",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:INFESTATION)
            pbCommonAnimation("Infestation",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:ATTACKORDER)
            pbCommonAnimation("AttackOrder",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:WHIRLPOOL)
            pbCommonAnimation("Whirlpool",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:QUICKSILVERSPEAR)
            pbCommonAnimation("QuicksilverSpear",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:DESERTSMARK)
            pbCommonAnimation("DesertsMark",i,nil)
          else
            pbCommonAnimation("Wrap",i,nil)
          end
          @scene.pbDamageAnimation(i,0)
        if !(i.effects[PBEffects::ShieldLife]>0)
          if $bindingband==1
            i.pbReduceHP((i.totalhp/6).floor)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:MAGMASTORM) &&
           $fefieldeffect == 32
            i.pbReduceHP((i.totalhp/6).floor)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:FIRESPIN) &&
           $fefieldeffect == 40
            i.pbReduceHP((i.totalhp/6).floor)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:SANDTOMB) &&
           $fefieldeffect == 12
            i.pbReduceHP((i.totalhp/6).floor)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:DESERTSMARK) &&
           $fefieldeffect == 12
            i.pbReduceHP((i.totalhp/6).floor)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:WHIRLPOOL) &&
           ($fefieldeffect == 21 || $fefieldeffect == 22)
            i.pbReduceHP((i.totalhp/6).floor)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:INFESTATION) &&
           $fefieldeffect == 15
            i.pbReduceHP((i.totalhp/6).floor)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:SNAPTRAP) &&
           $fefieldeffect == 2
            i.pbReduceHP((i.totalhp/6).floor)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:INFESTATION) &&
           $fefieldeffect == 33 && $fecounter > 1
              case $fecounter
                when 2
                  i.pbReduceHP((i.totalhp/6).floor)
                when 3
                  i.pbReduceHP((i.totalhp/4).floor)
                when 4
                  i.pbReduceHP((i.totalhp/3).floor)
              end 
          else
            i.pbReduceHP((i.totalhp/8).floor)
          end
        else
          if isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:QUICKSILVERSPEAR)
            multiturndamage=i.totalhp/4
            pbShieldDamage(i,multiturndamage)
          else
            multiturndamage=i.totalhp/8
            pbShieldDamage(i,multiturndamage)
          end
        end
          if isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:SANDTOMB) &&
           $fefieldeffect == 20
            i.pbCanReduceStatStage?(PBStats::ACCURACY)
            i.pbReduceStat(PBStats::ACCURACY,1,true)
          end
        end
      end  
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Taunt
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Taunt]>0
        i.effects[PBEffects::Taunt]-=1
        if i.effects[PBEffects::Taunt]==0
          pbDisplay(_INTL("{1} recovered from the taunting!",i.pbThis))
        end 
      end
    end
    # Encore
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Encore]>0
        if i.moves[i.effects[PBEffects::EncoreIndex]].id!=i.effects[PBEffects::EncoreMove]
          i.effects[PBEffects::Encore]=0
          i.effects[PBEffects::EncoreIndex]=0
          i.effects[PBEffects::EncoreMove]=0
        else
          i.effects[PBEffects::Encore]-=1
          if i.effects[PBEffects::Encore]==0 || i.moves[i.effects[PBEffects::EncoreIndex]].pp==0
            i.effects[PBEffects::Encore]=0
            pbDisplay(_INTL("{1}'s encore ended!",i.pbThis))
          end 
        end
      end
    end
    # Disable/Cursed Body
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Disable]>0
        i.effects[PBEffects::Disable]-=1
        if i.effects[PBEffects::Disable]==0
          i.effects[PBEffects::DisableMove]=0
          pbDisplay(_INTL("{1} is disabled no more!",i.pbThis))
        end
      end
    end
    # Magnet Rise
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::MagnetRise]>0 && !(isConst?(i.species,PBSpecies,:PROBOPASS) && isConst?(i.item,PBItems,:PROBOCREST))
        i.effects[PBEffects::MagnetRise]-=1
        if i.effects[PBEffects::MagnetRise]==0
          pbDisplay(_INTL("{1} stopped levitating.",i.pbThis))
        end
      end
    end
    # Telekinesis
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Telekinesis]>0
        i.effects[PBEffects::Telekinesis]-=1
        if i.effects[PBEffects::Telekinesis]==0
          pbDisplay(_INTL("{1} stopped levitating.",i.pbThis))
        end
      end
    end
    # Heal Block
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::HealBlock]>0
        i.effects[PBEffects::HealBlock]-=1
        if i.effects[PBEffects::HealBlock]==0
          pbDisplay(_INTL("The heal block on {1} ended.",i.pbThis))
        end
      end
    end
    # Embargo
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Embargo]>0
        i.effects[PBEffects::Embargo]-=1
        if i.effects[PBEffects::Embargo]==0
          pbDisplay(_INTL("The embargo on {1} was lifted.",i.pbThis(true)))
        end
      end
    end
    # Yawn
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Yawn]>0
        i.effects[PBEffects::Yawn]-=1
        if i.effects[PBEffects::Yawn]==0 && i.pbCanSleepYawn?
          i.pbSleep
          pbDisplay(_INTL("{1} fell asleep!",i.pbThis))
        end
      end
    end
    # Perish Song
    perishSongUsers=[]
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::PerishSong]>0
        i.effects[PBEffects::PerishSong]-=1
        pbDisplay(_INTL("{1}'s Perish count fell to {2}!",i.pbThis,i.effects[PBEffects::PerishSong]))
        if i.effects[PBEffects::PerishSong]==0
          perishSongUsers.push(i.effects[PBEffects::PerishSongUser])
          i.pbReduceHP(i.hp,true)
        end
      end
      if i.isFainted?
        return if !i.pbFaint
      end
    end
    if perishSongUsers.length>0
      # If all remaining Pokemon fainted by a Perish Song triggered by a single side
      if (perishSongUsers.find_all{|item| pbIsOpposing?(item) }.length==perishSongUsers.length) ||
         (perishSongUsers.find_all{|item| !pbIsOpposing?(item) }.length==perishSongUsers.length)
        pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
      end
    end
    if @decision>0
      pbGainEXP
      return
    end
    # Reflect
    for i in 0...2
      if sides[i].effects[PBEffects::Reflect]>0
        sides[i].effects[PBEffects::Reflect]-=1
        if sides[i].effects[PBEffects::Reflect]==0
          pbDisplay(_INTL("Your team's Reflect faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Reflect faded!")) if i==1
        end
      end
    end
    # Light Screen
    for i in 0...2
      if sides[i].effects[PBEffects::LightScreen]>0
        sides[i].effects[PBEffects::LightScreen]-=1
        if sides[i].effects[PBEffects::LightScreen]==0
          pbDisplay(_INTL("Your team's Light Screen faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Light Screen faded!")) if i==1
        end
      end
    end
    # Aurora Veil
    for i in 0...2
      if sides[i].effects[PBEffects::AuroraVeil]>0
        sides[i].effects[PBEffects::AuroraVeil]-=1
        if sides[i].effects[PBEffects::AuroraVeil]==0
          pbDisplay(_INTL("Your team's Aurora Veil faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Aurora Veil faded!")) if i==1
        end
      end
    end    
    # Arenite Veil
    for i in 0...2
      if sides[i].effects[PBEffects::AreniteWall]>0
        sides[i].effects[PBEffects::AreniteWall]-=1
        if sides[i].effects[PBEffects::AreniteWall]==0
          pbDisplay(_INTL("Your team's Arenite Wall faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Arenite Wall faded!")) if i==1
        end
      end
    end    
    # Safeguard
    for i in 0...2
      if sides[i].effects[PBEffects::Safeguard]>0
        sides[i].effects[PBEffects::Safeguard]-=1
        if sides[i].effects[PBEffects::Safeguard]==0
          pbDisplay(_INTL("Your team is no longer protected by Safeguard!")) if i==0
          pbDisplay(_INTL("The opposing team is no longer protected by Safeguard!")) if i==1
        end
      end
    end
    # Mist
    for i in 0...2
      if sides[i].effects[PBEffects::Mist]>0
        sides[i].effects[PBEffects::Mist]-=1
        if sides[i].effects[PBEffects::Mist]==0
          pbDisplay(_INTL("Your team's Mist faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Mist faded!")) if i==1
        end
      end
    end
    # Tailwind
    for i in 0...2
      if sides[i].effects[PBEffects::Tailwind]>0
        sides[i].effects[PBEffects::Tailwind]-=1
        if sides[i].effects[PBEffects::Tailwind]==0
          pbDisplay(_INTL("Your team's tailwind stopped blowing!")) if i==0
          pbDisplay(_INTL("The opposing team's tailwind stopped blowing!")) if i==1
        end
      end
    end
    # Lucky Chant
    for i in 0...2
      if sides[i].effects[PBEffects::LuckyChant]>0
        sides[i].effects[PBEffects::LuckyChant]-=1
        if sides[i].effects[PBEffects::LuckyChant]==0
          pbDisplay(_INTL("Your team's Lucky Chant faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Lucky Chant faded!")) if i==1
        end
      end
    end
    # Mud Sport
    if @field.effects[PBEffects::MudSport]>0
      @field.effects[PBEffects::MudSport]-=1
      if @field.effects[PBEffects::MudSport]==0
        pbDisplay(_INTL("The effects of Mud Sport faded."))
      end
    end
    # Water Sport
    if @field.effects[PBEffects::WaterSport]>0
      @field.effects[PBEffects::WaterSport]-=1
      if @field.effects[PBEffects::WaterSport]==0
        pbDisplay(_INTL("The effects of Water Sport faded."))
      end
    end
    # Gravity
    if @field.effects[PBEffects::Gravity]>0 && $fefieldeffect!=39
      @field.effects[PBEffects::Gravity]-=1
      if @field.effects[PBEffects::Gravity]==0
        pbDisplay(_INTL("Gravity returned to normal."))
        if $febackup == 35 && $fefieldeffect != 35
          $fefieldeffect = $febackup
          pbDisplay(_INTL("The world broke apart again!"))
          @weatherduration=0
          @field.effects[PBEffects::Terrain]=0
          pbChangeBGSprite
          seedCheck
        end
      end
    end
    # Terrain
    if @field.effects[PBEffects::Splintered]>0
      @field.effects[PBEffects::Splintered]-=1
      if @field.effects[PBEffects::Splintered]==0
        $fefieldeffect = $febackup
        pbChangeBGSprite        
        seedCheck
      end
    end    
    if @field.effects[PBEffects::Terrain]>0
      terrain=[@field.effects[PBEffects::Terrain]].max
      terrain-=1
      @field.effects[PBEffects::Terrain] = terrain
      if terrain==0
        if $game_variables[708]==$febackup && $game_variables[298]==40
          $fefieldeffect=$game_variables[298]
        else
          $fefieldeffect = $febackup
        end
        pbDisplay(_INTL("The terrain returned to normal."))
        pbChangeBGSprite
        #pbChangeBGSprite
        seedCheck
      end
    end
    # Trick Room
    if @trickroom > 0 && $fefieldeffect!=39 && !($game_variables[702]==1 || $game_variables[702]==4)
      @trickroom=@trickroom-1
      if @trickroom == 0
          Kernel.pbMessage("The twisted dimensions returned to normal!")
      end
    end
    # Wonder Room
#### KUROTSUNE - 014 - START
    if @field.effects[PBEffects::WonderRoom] > 0 && $fefieldeffect!=39 && !($game_variables[702]==2 || $game_variables[702]==4)
      @field.effects[PBEffects::WonderRoom] -= 1
      if @field.effects[PBEffects::WonderRoom] == 0
        for i in @battlers
          if i.wonderroom
            i.pbSwapDefenses
          end
        end
        Kernel.pbMessage("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!")
      end
    end
#### KUROTSUNE - 014 - END
    # Magic Room
    if @field.effects[PBEffects::MagicRoom]>0 && $fefieldeffect!=39 && !($game_variables[702]==3 || $game_variables[702]==5)
      @field.effects[PBEffects::MagicRoom]-=1
      if @field.effects[PBEffects::MagicRoom]==0
        pbDisplay(_INTL("The area returned to normal."))
      end
    end
    # Overlaying Terrain
    if @field.effects[PBEffects::ElectricTerrain]>0
      @field.effects[PBEffects::ElectricTerrain]-=1
      if @field.effects[PBEffects::ElectricTerrain]==0
        pbDisplay(_INTL("The surging electricity dissipated."))
      end
    end  
    if @field.effects[PBEffects::MistyTerrain]>0
      @field.effects[PBEffects::MistyTerrain]-=1
      if @field.effects[PBEffects::MistyTerrain]==0
        pbDisplay(_INTL("The surrounding mist dispersed."))
      end
    end  
    if @field.effects[PBEffects::GrassyTerrain]>0
      if $fefieldeffect==7 || $fefieldeffect==16 || $fefieldeffect==45  
        @field.effects[PBEffects::GrassyTerrain]=0
        pbDisplay(_INTL("The surrounding grass was burnt to a crisp!"))
      else  
        @field.effects[PBEffects::GrassyTerrain]-=1
        if @field.effects[PBEffects::GrassyTerrain]==0
          pbDisplay(_INTL("The surrounding grass withered."))
        end
      end  
    end  
    if @field.effects[PBEffects::PsychicTerrain]>0
      @field.effects[PBEffects::PsychicTerrain]-=1
      if @field.effects[PBEffects::PsychicTerrain]==0
        pbDisplay(_INTL("The psychic energy left as mysteriously as it came."))
      end
    end   
    if @field.effects[PBEffects::Rainbow]>0
      @field.effects[PBEffects::Rainbow]-=1
      if @field.effects[PBEffects::Rainbow]==0
        pbDisplay(_INTL("The rainbow disappeared."))
      end
    end  
    # Fairy Lock
    if @field.effects[PBEffects::FairyLock]>0
      @field.effects[PBEffects::FairyLock]-=1
      if @field.effects[PBEffects::FairyLock]==0
        # Fairy Lock seems to have no end-of-effect text so I've added some.
        pbDisplay(_INTL("The Fairy Lock was released."))
      end
    end
    # Uproar
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Uproar]>0
        for j in priority
          if !j.isFainted? && j.status==PBStatuses::SLEEP && !j.hasWorkingAbility(:SOUNDPROOF)
            j.effects[PBEffects::Nightmare]=false
            j.status=0
            j.statusCount=0
            pbDisplay(_INTL("{1} woke up in the uproar!",j.pbThis))
          end
        end
        i.effects[PBEffects::Uproar]-=1
        if i.effects[PBEffects::Uproar]==0
          pbDisplay(_INTL("{1} calmed down.",i.pbThis))
        else
          pbDisplay(_INTL("{1} is making an uproar!",i.pbThis)) 
        end
      end
    end
    # Fever Pitch
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::FeverPitch]==true
        for j in priority
          if !j.isFainted? && j.status==PBStatuses::SLEEP && !j.hasWorkingAbility(:SOUNDPROOF)
            j.effects[PBEffects::Nightmare]=false
            j.status=0
            j.statusCount=0
            pbDisplay(_INTL("{1} woke up in the uproar!",j.pbThis))
          end
        end
      end
    end
    #Wasteland hazard interaction
    if $fefieldeffect == 19
      for i in priority
        next if i.isFainted?
        # SR
        if i.pbOwnSide.effects[PBEffects::StealthRock]==true
          pbDisplay(_INTL("The waste swallowed up the pointed stones!"))
          i.pbOwnSide.effects[PBEffects::StealthRock]=false
          pbDisplay(_INTL("...Rocks spewed out from the ground below!"))
          atype=getConst(PBTypes,:ROCK) || 0
          if !i.isFainted?
            eff=PBTypes.getCombinedEffectiveness(atype,i.type1,i.type2)
            if eff>0
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP([(i.totalhp*eff/16).floor,1].max)
            end
          end
          partner=i.pbPartner
          if partner && !partner.isFainted?
            eff=PBTypes.getCombinedEffectiveness(atype,partner.type1,partner.type2)
            if eff>0
              @scene.pbDamageAnimation(partner,0)
              partner.pbReduceHP([(partner.totalhp*eff/16).floor,1].max)
            end
          end
        end
        # Spikes
        if i.pbOwnSide.effects[PBEffects::Spikes]>0
          pbDisplay(_INTL("The waste swallowed up the spikes!"))
          i.pbOwnSide.effects[PBEffects::Spikes]=0
          pbDisplay(_INTL("...Stalagmites burst up from the ground!"))
          if !i.isFainted? && !i.isAirborne?
            @scene.pbDamageAnimation(i,0)
            i.pbReduceHP([(i.totalhp/3).floor,1].max)
          end
          partner=i.pbPartner
          if partner && !partner.isFainted?
            if !partner.isAirborne?
              @scene.pbDamageAnimation(partner,0)
              partner.pbReduceHP([(partner.totalhp/3).floor,1].max)
            end
          end
        end
        # TSpikes
        if i.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
          pbDisplay(_INTL("The waste swallowed up the toxic spikes!"))
          i.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
          pbDisplay(_INTL("...Poison needles shot up from the ground!"))
          if !i.isFainted? && !i.isAirborne? &&
           !i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON)
            @scene.pbDamageAnimation(i,0)
            i.pbReduceHP([(i.totalhp/8).floor,1].max)
            if i.status==0 && i.pbCanPoison?(false)
              i.status=PBStatuses::POISON
              i.statusCount=1
              i.effects[PBEffects::Toxic]=0
              pbCommonAnimation("Poison",i,nil)  
            end     
          end
          partner=i.pbPartner
          if partner && !partner.isFainted?
            if !partner.isAirborne? &&
             !partner.pbHasType?(:STEEL) && !partner.pbHasType?(:POISON)
              @scene.pbDamageAnimation(partner,0)
              partner.pbReduceHP([(partner.totalhp/8).floor,1].max)   
              if partner.status==0 && partner.pbCanPoison?(false)
                partner.status=PBStatuses::POISON
                partner.statusCount=1
                partner.effects[PBEffects::Toxic]=0
                pbCommonAnimation("Poison",i,nil)
              end
            end
          end
        end
        # StickyWeb
        if i.pbOwnSide.effects[PBEffects::StickyWeb]
          pbDisplay(_INTL("The waste swallowed up the sticky web!"))
          i.pbOwnSide.effects[PBEffects::StickyWeb]=false
          pbDisplay(_INTL("...Sticky string shot out of the ground!"))
          if !i.isFainted?
            if !i.pbTooLow?(PBStats::SPEED)
              i.pbReduceStatBasic(PBStats::SPEED,4)
              pbCommonAnimation("StatDown",i,nil)
              pbDisplay(_INTL("{1}'s Speed was severely lowered!",i.pbThis))
            end 
          end
          partner=i.pbPartner
          if partner && !partner.isFainted?
            if !partner.pbTooLow?(PBStats::SPEED)
              partner.pbReduceStatBasic(PBStats::SPEED,4)
              pbCommonAnimation("StatDown",partner,nil)
              pbDisplay(_INTL("{1}'s Speed was severely lowered!",partner.pbThis))
            end 
          end        
        end
        if i.hp<=0
          return if !i.pbFaint
          next
        end
      end
    end
    # End Wasteland hazards
    for i in priority
      next if i.isFainted?
      # Mimicry
      if i.hasWorkingAbility(:MIMICRY)
        protype = -1
        case $fefieldeffect
        when 1
          protype = :ELECTRIC || 0
        when 2
          protype = :GRASS || 0
        when 3
          protype = :FAIRY || 0
        when 4
          protype = :DARK || 0
        when 5
          protype = :PSYCHIC || 0
        when 6
          protype = :NORMAL || 0
        when 7
          protype = :FIRE || 0
        when 8
          protype = :WATER || 0
        when 9
          protype = :DRAGON || 0
        when 10
          protype = :POISON || 0
        when 11
          protype = :POISON || 0
        when 12
          protype = :GROUND || 0
        when 13
          protype = :ICE || 0
        when 14
          protype = :ROCK || 0
        when 15
          protype = :BUG || 0
        when 16
          protype = :FIRE || 0
        when 17
          protype = :STEEL || 0
        when 18
          protype = :ELECTRIC || 0
        when 19
          protype = :POISON || 0
        when 20
          protype = :GROUND || 0
        when 21
          protype = :WATER || 0
        when 22
          protype = :WATER || 0
        when 23
          protype = :ROCK || 0
        when 24
          protype = :FLYING || 0
        when 25
          rnd=pbRandom(4)
          case rnd
          when 0
            protype = :GRASS || 0
          when 1
            protype = :WATER || 0
          when 2
            protype = :FIRE || 0
          when 3
            protype = :PSYCHIC || 0
          end
        when 26
          protype = :POISON || 0
        when 27
          protype = :ROCK || 0
        when 28
          protype = :ICE || 0
        when 29
          protype = :NORMAL || 0
        when 30
          protype = :STEEL || 0
        when 31
          protype = :FAIRY || 0
        when 32
          protype = :DRAGON || 0
        when 33
          protype = :GRASS || 0
        when 34
          protype = :DARK || 0
        when 35
          rnd=pbRandom(18)
          case rnd
          when 0
            protype = :NORMAL || 0
          when 1
            protype = :WATER || 0
          when 2
            protype = :FIRE || 0
          when 3
            protype = :ELECTRIC || 0
          when 4
            protype = :GRASS || 0
          when 5
            protype = :ICE || 0
          when 6
            protype = :FIGHTING || 0
          when 7
            protype = :POISON || 0
          when 8
            protype = :GROUND || 0
          when 9
            protype = :PSYCHIC || 0
          when 10
            protype = :ROCK || 0
          when 11
            protype = :FLYING || 0
          when 12
            protype = :BUG || 0
          when 13
            protype = :GHOST || 0
          when 14
            protype = :DRAGON || 0
          when 15
            protype = :DARK || 0
          when 16
            protype = :STEEL || 0
          when 17
            protype = :FAIRY || 0
          end
        when 36
          protype = :NORMAL || 0
        when 37
          protype = :PSYCHIC || 0 
        when 38
          protype = :DARK || 0   
        when 39
          protype = :ICE || 0  
        when 40
          protype = :GHOST || 0  
        when 41
          protype = :POISON || 0  
        when 42
          protype = :FAIRY || 0
        when 43
          protype = :FLYING || 0
        when 44
          protype = :STEEL || 0
        when 45
          protype = :FIRE || 0
        end
        prot1 = i.type1
        prot2 = i.type2 
        camotype = getConst(PBTypes,protype) || 0
        if camotype>0 && (!i.pbHasType?(camotype) || (defined?(prot2) && prot1 != prot2))
          i.type1=camotype
          i.type2=camotype
          typename=PBTypes.getName(camotype)
          pbDisplay(_INTL("{1} had its type changed to {2}!",i.pbThis,typename))
        end
      end
      # Speed Boost
      # A Pokémon's turncount is 0 if it became active after the beginning of a round
      if i.turncount>0 && i.hasWorkingAbility(:SPEEDBOOST)
        if !i.pbTooHigh?(PBStats::SPEED)
          i.pbIncreaseStatBasic(PBStats::SPEED,1)
          pbCommonAnimation("StatUp",i,nil)
          pbDisplay(_INTL("{1}'s Speed Boost raised its Speed!",i.pbThis))
        end
      end
      # Accumulation
      if i.hasWorkingAbility(:ACCUMULATION) && i.turncount>0 && i.lastMoveUsed!=395
        if i.effects[PBEffects::Stockpile] <3
          i.effects[PBEffects::Stockpile] +=1
          i.pbIncreaseStatBasic(PBStats::DEFENSE,1)
          i.effects[PBEffects::StockpileDef] +=1
          i.pbIncreaseStatBasic(PBStats::SPDEF,1)
          i.effects[PBEffects::StockpileSpDef] +=1
          pbDisplay(_INTL("{1} stockpiled with {2}!",i.pbThis,PBAbilities.getName(i.ability)))
        end
        if i.hp!=i.totalhp
          i.pbRecoverHP((i.totalhp/8).floor,true)
          pbDisplay(_INTL("{1} is healed by the stockpiles!",i.pbThis))
        end
      end
      if i.turncount>0 && $fefieldeffect == 8 && # Swamp Field
       !isConst?(i.ability,PBAbilities,:WHITESMOKE) &&
       !isConst?(i.ability,PBAbilities,:CLEARBODY) &&
       !isConst?(i.ability,PBAbilities,:QUICKFEET) &&
       !isConst?(i.ability,PBAbilities,:TEMPORALSHIFT) &&
       !isConst?(i.ability,PBAbilities,:SWIFTSWIM) &&
       !isConst?(i.ability,PBAbilities,:PROPELLERTAIL)
        if !i.isAirborne?
          boost = 1
          if i.effects[PBEffects::MultiTurn] > 0
            boost = 2
          end
          if i.hasWorkingAbility(:CONTRARY)
            i.pbIncreaseStat(PBStats::SPEED,boost,false,nil,nil,true,false,false)
            pbDisplay(_INTL("{1}'s {2} boosted its Speed!",i.pbThis,PBAbilities.getName(i.ability)))
          else
            i.pbReduceStat(PBStats::SPEED,boost,false,nil,nil,true,false,false)
            pbDisplay(_INTL("{1}'s Speed sank...!",i.pbThis))
          end
        end
      end
     #sleepyswamp
    if i.status==PBStatuses::SLEEP && !isConst?(i.ability,PBAbilities,:MAGICGUARD)
      if $fefieldeffect == 8 # Swamp Field
        if i.effects[PBEffects::ShieldLife]>0
          nightmaredamage=i.totalhp/16
          pbShieldDamage(i,nightmaredamage)
          hploss=nightmaredamage
        else
          if i.effects[PBEffects::MultiTurn] > 0
            hpdown = (i.totalhp/8).floor
            hploss=i.pbReduceHP(hpdown,true)
          else
            hpdown = (i.totalhp/16).floor
            hploss=i.pbReduceHP(hpdown,true)   
          end  
        end
        pbDisplay(_INTL("{1}'s strength is sapped by the swamp!",i.pbThis)) if hploss>0
      end
    end
    if i.hp<=0
      return if !i.pbFaint
      next
    end
    if i.effects[PBEffects::Octolock]==true
      locklowered = false
      if !i.pbTooLow?(PBStats::DEFENSE)
        contcheck = (i.ability == PBAbilities::CONTRARY)
        i.pbReduceStat(PBStats::DEFENSE,1,false,nil,nil,false,false,false,contcheck)
        locklowered = true if !contcheck
      end
      if !i.pbTooLow?(PBStats::SPDEF)
        contcheck = (i.ability == PBAbilities::CONTRARY)
        i.pbReduceStat(PBStats::SPDEF,1,false,nil,nil,false,false,false,contcheck)
        locklowered = true if !contcheck
      end
      if locklowered
        pbCommonAnimation("StatDown",i,nil)
        pbDisplay(_INTL("The Octolock lowered {1}'s defenses!",i.pbThis))
      end
    end
    #sleepyrainbow
    if i.status==PBStatuses::SLEEP
      if ($fefieldeffect == 9 || @field.effects[PBEffects::Rainbow]>0) && i.effects[PBEffects::HealBlock]==0#Rainbow Field
      hpgain=(i.totalhp/16).floor
      hpgain=(hpgain*1.3).floor if isConst?(i.item,PBItems,:BIGROOT)
      hpgain=i.pbRecoverHP(hpgain,true)
      pbDisplay(_INTL("{1} recovered health in its peaceful sleep!",i.pbThis))
      end
    end
    #DimenSleep
    if i.status==PBStatuses::SLEEP && $fefieldeffect == 38 && !i.isFainted? # Dimen
      if i.effects[PBEffects::ShieldLife]>0
        nightmaredamage=i.totalhp/16
        pbShieldDamage(i,nightmaredamage)
        hploss=nightmaredamage
      else
        hploss=i.pbReduceHP((i.totalhp/16).floor,true)
      end
      pbDisplay(_INTL("{1}'s dream is corrupted by the dimension!",i.pbThis)) if hploss>0
    end
    #MeliaHelps
    if $game_switches[755]==true &&
      $fefieldeffect == 31 &&
      isConst?(i.ability,PBAbilities,:INTIMIDATE2)
      hploss=i.pbReduceHP((i.totalhp/6).floor,true)
      pbDisplay(_INTL("Melia harmed Gyarados from outside the rift!",i.pbThis)) if hploss>0 
    end
    #HauntedSleep
    if i.status==PBStatuses::SLEEP && !i.pbHasType?(:GHOST) && $fefieldeffect == 40 # Haunted
      if i.pbOpposing1.hasWorkingAbility(:SHADOWTAG) || i.pbOpposing2.hasWorkingAbility(:SHADOWTAG)
        if i.effects[PBEffects::ShieldLife]>0
          nightmaredamage=i.totalhp/16
          pbShieldDamage(i,nightmaredamage)
          hploss=nightmaredamage
        else
          hploss=i.pbReduceHP((i.totalhp/8).floor,true)
        end
      else
        if i.effects[PBEffects::ShieldLife]>0
          nightmaredamage=i.totalhp/16
          pbShieldDamage(i,nightmaredamage)
        else
          hploss=i.pbReduceHP((i.totalhp/16).floor,true)
        end
      end
      pbDisplay(_INTL("{1}'s dream is corrupted by the evil spirits!",i.pbThis)) if hploss>0 
    end
    if i.hp<=0
      return if !i.pbFaint
      next
    end
    #FairyRingSleep
    if i.status==PBStatuses::SLEEP && 
     $fefieldeffect == 42 # Bewitched woods
      if i.effects[PBEffects::ShieldLife]>0
        nightmaredamage=i.totalhp/16
        pbShieldDamage(i,nightmaredamage)
        hploss=nightmaredamage
      else
        hploss=i.pbReduceHP((i.totalhp/8).floor,true)
      end
      pbDisplay(_INTL("{1}'s dream is corrupted by the evil in the woods!",i.pbThis)) if hploss>0
    end
    if i.hp<=0
      return if !i.pbFaint
      next
    end  
    #sleepycorro
    if i.status==PBStatuses::SLEEP && i.hasWorkingAbility(:MAGICGUARD) &&
     !i.hasWorkingAbility(:POISONHEAL) && !i.hasWorkingAbility(:TOXICBOOST) &&
     !i.hasWorkingAbility(:WONDERGUARD) &&
     !i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON) &&
     $fefieldeffect == 10 # Corrosive Field
     if i.effects[PBEffects::ShieldLife]>0
      nightmaredamage=i.totalhp/16
      pbShieldDamage(i,nightmaredamage)
      else
        hploss=i.pbReduceHP((i.totalhp/16).floor,true)
      end
      pbDisplay(_INTL("{1}'s is seared by the corrosion!",i.pbThis)) if hploss>0
    end
    if i.hp<=0
      return if !i.pbFaint
      next
    end
    # Water Compaction on Water-based Fields
    if i.hasWorkingAbility(:WATERCOMPACTION)
      if $fefieldeffect==8 || $fefieldeffect==21 || $fefieldeffect==22 || 
        $fefieldeffect==26 # Swamp, Water Surface, Underwater, Murkwater
        if !i.pbTooHigh?(PBStats::DEFENSE)
          i.pbIncreaseStatBasic(PBStats::DEFENSE,2)
          pbCommonAnimation("StatUp",i,nil)
          pbDisplay(_INTL("{1}'s Water Compaction sharply raised its defense!",
           i.pbThis))     
         end
       end
     end
    # World of Nightmares 
    if i.pbOpposing1.hasWorkingAbility(:WORLDOFNIGHTMARES) || i.pbOpposing2.hasWorkingAbility(:WORLDOFNIGHTMARES)
        i.effects[PBEffects::WorldOfNightmares]+=1
        nightmarechip=[64,i.effects[PBEffects::WorldOfNightmares]].min
        if $fefieldeffect==35 # new world
          nightmarechip*=2
        end
        hploss=i.pbReduceHP((i.totalhp/32).floor*nightmarechip,true)
        pbDisplay(_INTL("{1}'s nightmares are becoming a reality!",i.pbThis)) if hploss>0
    end
    # Bad Dreams
    if (i.status==PBStatuses::SLEEP || isConst?(i.ability,PBAbilities,:COMATOSE) && $fefieldeffect!=1) && 
       !isConst?(i.ability,PBAbilities,:MAGICGUARD) && !(isConst?(i.ability,PBAbilities,:WONDERGUARD) && $fefieldeffect == 44) &&
       $fefieldeffect != 9
      if i.pbOpposing1.hasWorkingAbility(:BADDREAMS) ||
         i.pbOpposing2.hasWorkingAbility(:BADDREAMS)
        hploss=i.pbReduceHP((i.totalhp/8).floor,true)
        hploss*=2 if $fefieldeffect==45
        pbDisplay(_INTL("{1} is having a bad dream!",i.pbThis)) if hploss>0
      end
    end
    if i.isFainted?
      return if !i.pbFaint
      next
    end
    # Harvest 
    if i.hasWorkingAbility(:HARVEST) && i.item<=0 && i.pokemon.itemRecycle>0 #if an item was recycled, check
      if pbIsBerry?(i.pokemon.itemRecycle) && (rand(100)>50 || 
       (pbWeather==PBWeather::SUNNYDAY && !i.hasWorkingItem(:UTILITYUMBRELLA)) || ($fefieldeffect == 33 && $fecounter>0))
        i.item=i.pokemon.itemRecycle
        i.pokemon.itemInitial=i.pokemon.itemRecycle
        i.pokemon.itemRecycle=0
        firstberryletter=PBItems.getName(i.item).split(//).first
        if firstberryletter=="A" || firstberryletter=="E" || firstberryletter=="I" ||
          firstberryletter=="O" || firstberryletter=="U"
              pbDisplay(_INTL("{1} harvested an {2}!",i.pbThis,PBItems.getName(i.item)))
        else      
          pbDisplay(_INTL("{1} harvested a {2}!",i.pbThis,PBItems.getName(i.item)))
        end
        i.pbBerryCureCheck(true)
      end
    end
    # Moody
    if i.hasWorkingAbility(:CLOUDNINE) && $fefieldeffect == 9
      failsafe=0
      randoms=[]
      loop do
        failsafe+=1
        break if failsafe==1000        
        rand=1+self.pbRandom(5)
        if !i.pbTooHigh?(rand)
          randoms.push(rand)
          break
        end
      end
      statnames=[_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),_INTL("Special Attack"),_INTL("Special Defense")]
      if failsafe!=1000           
        i.stages[randoms[0]]+=1
        i.stages[randoms[0]]=6 if i.stages[randoms[0]]>6
        pbCommonAnimation("StatUp",i,nil)
        pbDisplay(_INTL("{1}'s Cloud Nine raised its {2}!",i.pbThis,statnames[randoms[0]-1]))
      end     
    end
    if i.hasWorkingAbility(:MOODY)
      randomup=[]
      randomdown=[]
      failsafe1=0
      failsafe2=0
      loop do
        failsafe1+=1
        break if failsafe1==1000
        rand=1+self.pbRandom(5)
        if !i.pbTooHigh?(rand)
          randomup.push(rand)
          break
        end
      end
      loop do
        failsafe2+=1
        break if failsafe2==1000
        rand=1+self.pbRandom(5)
        if !i.pbTooLow?(rand) && rand!=randomup[0]
          randomdown.push(rand)
          break
        end
      end
      statnames=[_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),_INTL("Special Attack"),_INTL("Special Defense")]
      if failsafe1!=1000                 
        i.stages[randomup[0]]+=2
        i.stages[randomup[0]]=6 if i.stages[randomup[0]]>6
        pbCommonAnimation("StatUp",i,nil)
        pbDisplay(_INTL("{1}'s Moody sharply raised its {2}!",i.pbThis,statnames[randomup[0]-1]))
      end
      if failsafe2!=1000
        i.stages[randomdown[0]]-=1
        pbCommonAnimation("StatDown",i,nil)
        pbDisplay(_INTL("{1}'s Moody lowered its {2}!",i.pbThis,statnames[randomdown[0]-1]))
      end
    end
    if !i.hasWorkingItem(:LEFTOVERS) && !i.hasWorkingItem(:BLACKSLUDGE) && 
       !i.hasWorkingItem(:SPIRITCREST)  && !i.hasWorkingItem(:INFCREST)
      i.pbBerryCureCheck(true)
    end
    # Ball Fetch
    if i.hasWorkingAbility(:BALLFETCH) && i.effects[PBEffects::BallFetch]!=0 && i.item<=0
      pokeball=i.effects[PBEffects::BallFetch]
      i.item=pokeball
      i.pokemon.itemInitial=pokeball
      PBDebug.log("[Ability triggered] #{i.pbThis}'s Ball Fetch found #{PBItems.getName(ball)}")
      pbDisplay(_INTL("{1} fetched a {2}!",i.pbThis,PBItems.getName(ball)))
      i.pbPartner.effects[PBEffects::BallFetch]=0 if i.pbPartner.hasWorkingAbility(:BALLFETCH)
    end
  end
#    # Harvest 
#    if i.hasWorkingAbility(:HARVEST) && i.item<=0 && i.pokemon.itemRecycle>0 #if an item was recycled, check
#      if pbIsSeed?(i.pokemon.itemRecycle) || ($fefieldeffect == 33 && $fecounter>0)
#        i.item=i.pokemon.itemRecycle
#        i.pokemon.itemInitial=i.pokemon.itemRecycle
#        i.pokemon.itemRecycle=0
#        pbDisplay(_INTL("{1} harvested {2}!",i.pbThis,PBItems.getName(i.item)))
#        i.pbSeedCheck(true)
#      end
#    end
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::BurnUp]
        if $fefieldeffect==7 || $fefieldeffect==16 || $fefieldeffect==45
          itype1=i.type1
          itype2=i.type2
          if isConst?(itype1,PBTypes,:QMARKS)
            itype1=getConst(PBTypes,:FIRE) || 0
          end
          itype2=getConst(PBTypes,:FIRE) || 0
          i.effects[PBEffects::BurnUp] = false
          pbDisplay(_INTL("{1} reignited its flame!",i.pbThis))
        end
      end
    end   
    for i in priority
      next if i.isFainted?
      # Toxic Orb
      if i.hasWorkingItem(:TOXICORB) && i.status==0 && i.pbCanPoison?(false,true)
        i.status=PBStatuses::POISON
        i.statusCount=1
        i.effects[PBEffects::Toxic]=0
        pbCommonAnimation("Poison",i,nil)
        pbDisplay(_INTL("{1} was poisoned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Flame Orb
      if i.hasWorkingItem(:FLAMEORB) && i.status==0 && i.pbCanBurn?(false)
        i.status=PBStatuses::BURN
        i.statusCount=0
        pbCommonAnimation("Burn",i,nil)
        pbDisplay(_INTL("{1} was burned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Sticky Barb
      if i.hasWorkingItem(:STICKYBARB) && !i.hasWorkingAbility(:MAGICGUARD) &&  
         !(i.hasWorkingAbility(:WONDERGUARD) && $fefieldeffect == 44)
        pbDisplay(_INTL("{1} is hurt by its {2}!",i.pbThis,PBItems.getName(i.item)))
        @scene.pbDamageAnimation(i,0)
        i.pbReduceHP((i.totalhp/8).floor)
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
#### SARDINES - v17 - START
    # Slow Start's end message
    for i in 0...4
      if @battlers[i].hasWorkingAbility(:SLOWSTART) && @battlers[i].turncount==5
        pbDisplay(_INTL("{1} finally got its act together!", @battlers[i].name))
      end
    end
#### SARDINES - v17 - END
    # Hunger Switch
    for i in priority
      next if i.isFainted?
      if i.hasWorkingAbility(:HUNGERSWITCH) && isConst?(i.species,PBSpecies,:MORPEKO) && $fefieldeffect != 39
          i.form=(i.form==0) ? 1 : 0
          i.pbUpdate(true)
          scene.pbChangePokemon(i,i.pokemon)
          pbDisplay(_INTL("{1} transformed!",i.pbThis))
      end
    end
#### SAVAGERY - START
#### SAVAGERY - END
    # Form checks
    for i in 0...4
      next if @battlers[i].isFainted?
      @battlers[i].pbCheckForm
    end
    pbGainEXP
##### KUROTSUNE - 009 - START
    # Checks if a pokemon on either side has fainted on this turn
    # for retaliate
    player   = priority[0]
    opponent = priority[1]
    if player.isFainted? || 
      (@doublebattle && player.pbPartner.isFainted?)
      player.pbOwnSide.effects[PBEffects::Retaliate] = true
    else
      # No pokemon has fainted in this side this turn
      player.pbOwnSide.effects[PBEffects::Retaliate] = false
    end
    
    if opponent.isFainted? || 
      (@doublebattle && player.pbPartner.isFainted?)
      opponent.pbOwnSide.effects[PBEffects::Retaliate] = true
    else
      opponent.pbOwnSide.effects[PBEffects::Retaliate] = false
    end
##### KUROTSUNE - 009 - END
    @faintswitch = true
    pbSwitch
    @faintswitch = false
    return if @decision>0
    for i in priority
      next if i.isFainted?
      i.pbAbilitiesOnSwitchIn(false)
    end
    # Healing Wish/Lunar Dance - should go here
    # Spikes/Toxic Spikes/Stealth Rock - should go here (in order of their 1st use)
    for i in 0...4
      if @battlers[i].turncount>0 && @battlers[i].hasWorkingAbility(:TRUANT)
        @battlers[i].effects[PBEffects::Truant]=!@battlers[i].effects[PBEffects::Truant]
      end
      if @battlers[i].effects[PBEffects::LockOn]>0   # Also Mind Reader
        @battlers[i].effects[PBEffects::LockOn]-=1
        @battlers[i].effects[PBEffects::LockOnPos]=-1 if @battlers[i].effects[PBEffects::LockOn]==0
      end
      @battlers[i].effects[PBEffects::Flinch]=false
      if !(@battlers[i].hasWorkingAbility(:MIRRORARMOR) && $fefieldeffect==34)
        @battlers[i].effects[PBEffects::FollowMe]=false
      end
      @battlers[i].effects[PBEffects::RagePowder]=false
      @battlers[i].effects[PBEffects::HelpingHand]=false
      @battlers[i].effects[PBEffects::MagicCoat]=false
      @battlers[i].effects[PBEffects::Switched]=false
      @battlers[i].effects[PBEffects::Switching]=false
      @battlers[i].effects[PBEffects::SwitchingTo]=nil
      @battlers[i].effects[PBEffects::Snatch]=false
#### KUROTSUNE - 024 - START
      @battlers[i].effects[PBEffects::Electrify]=false
#### KUROTSUNE - 024 - END
      @battlers[i].effects[PBEffects::Charge]-=1 if @battlers[i].effects[PBEffects::Charge]>0
      @battlers[i].lastHPLost=0
      @battlers[i].lastAttacker=-1
      @battlers[i].effects[PBEffects::Counter]=-1
      @battlers[i].effects[PBEffects::CounterTarget]=-1
      @battlers[i].effects[PBEffects::MirrorCoat]=-1
      @battlers[i].effects[PBEffects::MirrorCoatTarget]=-1
    end
    # invalidate stored priority
    @usepriority=false
    @eruption=false
    # Boss Shield's Can Be Setup Again cause set to -1
    if @shieldCount == 0
      @shieldSetup = -1
      @shieldCount = -1
    end
  end

################################################################################
# End of battle.
################################################################################
  def pbEndOfBattle(canlose=false)
    case @decision
    ##### WIN #####
    when 1
      $febackgroundstore=0
      if @opponent
        @scene.pbTrainerBattleSuccess
        if @opponent.is_a?(Array)
          pbDisplayPaused(_INTL("{1} defeated {2} and {3}!",self.pbPlayer.name,@opponent[0].fullname,@opponent[1].fullname))
        else
          pbDisplayPaused(_INTL("{1} defeated\r\n{2}!",self.pbPlayer.name,@opponent.fullname))
        end
        @scene.pbShowOpponent(0)
        pbDisplayPaused(@endspeech.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
        if @opponent.is_a?(Array)
          @scene.pbHideOpponent
          @scene.pbShowOpponent(1)
          pbDisplayPaused(@endspeech2.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
        end
        # Calculate money gained for winning
#### JAN - EXPFIX - START
        if @internalbattle
          maxlevel=0
          tmoney=0
          if @opponent.is_a?(Array)   # Double battles
            maxlevel1=0; maxlevel2=0; limit=pbSecondPartyBegin(1)
            for i in 0...limit
              if @party2[i]
                maxlevel1=@party2[i].level if maxlevel1<@party2[i].level
              end
              if @party2[i+limit]
                maxlevel2=@party2[i+limit].level if maxlevel1<@party2[i+limit].level
              end
            end
            tmoney+=maxlevel1*@opponent[0].moneyEarned
            tmoney+=maxlevel2*@opponent[1].moneyEarned
          else
#            maxlevel=0
            for i in @party2
              next if !i
              maxlevel=i.level if maxlevel<i.level
            end
            tmoney+=maxlevel*@opponent.moneyEarned
          end
          # If Amulet Coin/Luck Incense's effect applies, double money earned
          if self.pbPlayer.numbadges<9
            badgemult=self.pbPlayer.numbadges
          else
            badgemult=12
          end
          badgemultiplier = [1,badgemult].max
          tmoney*=((badgemultiplier))
          tmoney*=2 if @amuletcoin
          maxlevel = DifficultModes.applyMoneyProcedure(maxlevel)
          oldmoney=self.pbPlayer.money
          self.pbPlayer.money+=tmoney
          moneygained=self.pbPlayer.money-oldmoney
          if moneygained>0
            pbDisplayPaused(_INTL("{1} got ${2}\r\nfor winning!",self.pbPlayer.name,pbCommaNumber(tmoney)))
          end
        end
#### JAN - EXPFIX - END
      end
      if @internalbattle && @extramoney>0
        @extramoney*=2 if @amuletcoin
        oldmoney=self.pbPlayer.money
        self.pbPlayer.money+=@extramoney
        moneygained=self.pbPlayer.money-oldmoney
        if moneygained>0
          pbDisplayPaused(_INTL("{1} picked up ${2}!",self.pbPlayer.name,pbCommaNumber(@extramoney)))
        end
      end
      for pkmn in @snaggedpokemon
        pbStorePokemon(pkmn)
        self.pbPlayer.shadowcaught=[] if !self.pbPlayer.shadowcaught
        self.pbPlayer.shadowcaught[pkmn.species]=true
      end
      @snaggedpokemon.clear
    ##### LOSE, DRAW #####
    when 2, 5
      if @internalbattle
        pbDisplayPaused(_INTL("{1} is out of usable Pokémon!",self.pbPlayer.name))
        moneylost=pbMaxLevelFromIndex(0)
        $game_switches[290]=false
        $febackgroundstore=0
        multiplier=[8,16,24,36,48,64,80,100,120,144,178,206,234,266,298,334,370,410,450,500] #Badge no. multiplier for money lost
        moneylost*=multiplier[[multiplier.length-1,self.pbPlayer.numbadges].min]
        moneylost=self.pbPlayer.money if moneylost>self.pbPlayer.money
        moneylost=0 if $game_switches[NO_MONEY_LOSS]
        self.pbPlayer.money-=moneylost
        if @opponent
          if @opponent.is_a?(Array)
            pbDisplayPaused(_INTL("{1} lost against {2} and {3}!",self.pbPlayer.name,@opponent[0].fullname,@opponent[1].fullname))
          else
            pbDisplayPaused(_INTL("{1} lost against\r\n{2}!",self.pbPlayer.name,@opponent.fullname))
          end
          if moneylost>0
            pbDisplayPaused(_INTL("{1} paid ${2}\r\nas the prize money...",self.pbPlayer.name,pbCommaNumber(moneylost)))
            pbDisplayPaused(_INTL("...")) if !canlose
          end
        else
          if moneylost>0
            pbDisplayPaused(_INTL("{1} panicked and lost\r\n${2}...",self.pbPlayer.name,pbCommaNumber(moneylost)))
            pbDisplayPaused(_INTL("...")) if !canlose
          end
        end
        pbDisplayPaused(_INTL("{1} blacked out!",self.pbPlayer.name)) if !canlose
      elsif @decision==2
        @scene.pbShowOpponent(0)
        $febackgroundstore=0
        pbDisplayPaused(@endspeechwin.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
        if @opponent.is_a?(Array)
          @scene.pbHideOpponent
          @scene.pbShowOpponent(1)
          pbDisplayPaused(@endspeechwin2.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
        end
      elsif @decision==5
        PBDebug.log("***[Draw game]") if $INTERNAL
      end
    end
    # Pass on Pokérus within the party
    infected=[]
    for i in 0...$Trainer.party.length
      if $Trainer.party[i].pokerusStage==1
        infected.push(i)
      end
    end
    if infected.length>=1
      for i in infected
        strain=$Trainer.party[i].pokerus/16
        if i>0 && $Trainer.party[i-1].pokerusStage==0
          $Trainer.party[i-1].givePokerus(strain) if rand(3)==0
        end
        if i<$Trainer.party.length-1 && $Trainer.party[i+1].pokerusStage==0
          $Trainer.party[i+1].givePokerus(strain) if rand(3)==0
        end
      end
    end
    @scene.pbEndBattle(@decision)
    for i in @battlers
      i.pbResetForm
    end
    for i in $Trainer.party
      i.setItem(i.itemInitial)
      i.itemInitial=i.itemRecycle=0
    end
    return @decision
  end
end