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
    for i in 0...4
      if self.battlers[i].hasWorkingAbility(:BALLFETCH) && self.battlers[i].item==0
        self.battlers[i].effects[PBEffects::BallFetch]=pokeball
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
    if battler.isFainted?
      battler=battler.pbPartner
    end
    oldform=battler.form
    battler.form=battler.pokemon.getForm(battler.pokemon)
    pbDisplayBrief(_INTL("{1} threw one {2}!",self.pbPlayer.name,itemname))
    if battler.isFainted?
      pbDisplay(_INTL("But there was no target..."))
      pbBallFetch(ball)
      return
    end
    if @opponent && (!pbIsSnagBall?(ball) || !battler.isShadow?)
      @scene.pbThrowAndDeflect(ball,1)
      if $game_switches[:No_Catching]==false
        pbDisplay(_INTL("The Trainer blocked the Ball!\nDon't be a thief!"))
      else
        pbDisplay(_INTL("The Pokémon knocked the ball away!"))
      end
    else
      if $game_switches[:No_Catching]==true
        pbDisplay(_INTL("The Pokémon knocked the ball away!"))
        pbBallFetch(ball)
        return
      end
      pokemon=battler.pokemon
      species=pokemon.species
      if $DEBUG && Input.press?(Input::CTRL)
        shakes=4
      else
        if !rareness
          rareness = $cache.pkmn_dex[species][:CatchRate]
        end
        name = pokemon.getFormName
		    formrarity = PokemonForms.dig(species,name,:CatchRate)
        if formrarity!=nil
          rareness = formrarity
        end
        a=battler.totalhp
        b=battler.hp
        rareness=BallHandlers.modifyCatchRate(ball,rareness,self,battler)
        rareness +=1 if $PokemonBag.pbQuantity(PBItems::CATCHINGCHARM)>0
        rareness +=1 if Reborn && $PokemonBag.pbQuantity(PBItems::CATCHINGCHARM2)>0
        rareness +=1 if Reborn && $PokemonBag.pbQuantity(PBItems::CATCHINGCHARM3)>0
        rareness +=1 if Reborn && $PokemonBag.pbQuantity(PBItems::CATCHINGCHARM4)>0
        x=(((a*3-b*2)*rareness)/(a*3))
        if battler.status==PBStatuses::SLEEP || battler.status==PBStatuses::FROZEN
          x=(x*2.5)
        elsif battler.status!=0
          x=(x*3/2)
        end
        #Critical Capture chances based on caught species'
        c=0
        if $Trainer
          mod = -3
          mod +=0.5 if $Trainer.pokedexOwned>500
          mod +=0.5 if $Trainer.pokedexOwned>400
          mod +=0.5 if $Trainer.pokedexOwned>300
          mod +=0.5 if $Trainer.pokedexOwned>200
          mod +=0.5 if $Trainer.pokedexOwned>100
          mod +=0.5 if $Trainer.pokedexOwned>30
          c=(x*(2**mod).floor)
        end
        shakes=0; critical=false; critsuccess=false
        if x>255 || BallHandlers.isUnconditional?(ball,self,battler)
          shakes=4
        else
          x=1 if x==0
          y = (65536/((255.0/x)**0.1875)).floor
          puts "c = #{c}; x = #{x}"
          percentage = (1/((255.0/x)**0.1875))**4
          puts "Catch chance: #{percentage}%"
          percentage = c/256.0 * (1/((255.0/x)**0.1875))
          puts "Crit chance: #{percentage}%"
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
          pbBallFetch(ball)
          BallHandlers.onFailCatch(ball,self,pokemon)
          battler.form=oldform
        when 1
          pbDisplay(_INTL("Aww... It appeared to be caught!"))
          pbBallFetch(ball)
          BallHandlers.onFailCatch(ball,self,pokemon)
          battler.form=oldform
        when 2
          pbDisplay(_INTL("Aargh! Almost had it!"))
          pbBallFetch(ball)
          BallHandlers.onFailCatch(ball,self,pokemon)
          battler.form=oldform
        when 3
          pbDisplay(_INTL("Shoot! It was so close, too!"))
          pbBallFetch(ball)
          BallHandlers.onFailCatch(ball,self,pokemon)
          battler.form=oldform
        when 4
          @scene.pbWildBattleSuccess
          pbDisplayBrief(_INTL("Gotcha! {1} was caught!",pokemon.name))
          @scene.pbThrowSuccess
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
              if $dexForms == nil
                $dexForms = []
                802.times do
                  $dexForms.push(0)
                end
              end
              $dexForms[(species-1)] = pokemon.form
              @scene.pbShowPokedex(species)
            end
          end
          @scene.pbHideCaptureBall
          pbGainEXP
          pokemon.form=pokemon.getForm(pokemon)
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
  attr_reader(:priority)          # Move order of active Pokémon
  attr_accessor(:items)           # Items held by opponents
  attr_reader(:sides)             # Effects common to each side of a battle
  attr_accessor(:state)
  attr_accessor(:field)             # Effects common to the whole of a battle
  attr_accessor(:environment)     # Battle surroundings
  attr_accessor(:weather)         # Current weather, custom methods should use pbWeather instead
  attr_accessor(:weatherduration) # Duration of current weather, or -1 if indefinite
  attr_reader(:switching)         # True if during the switching phase of the round
  attr_accessor(:struggle)          # The Struggle move
  attr_accessor(:choices)         # Choices made by each Pokémon this round
  attr_reader(:successStates)     # Success states
  attr_accessor(:lastMoveUsed)    # Last move used
  attr_accessor(:lastMoveUser)    # Last move user
  attr_accessor(:synchronize)     # Synchronize state
  attr_accessor(:megaEvolution)   # Battle index of each trainer's Pokémon to Mega Evolve
  attr_accessor(:ultraBurst)      # Battle index of each trainer's Pokémon to Ultra Burst
  attr_accessor(:necrozmaVar)     # Store the form Necrozma was in initially if it bursts
  attr_accessor(:amuletcoin)      # Whether Amulet Coin's effect applies
  attr_accessor(:extramoney)      # Money gained in battle by using Pay Day
  attr_accessor(:endspeech)       # Speech by opponent when player wins
  attr_accessor(:endspeech2)      # Speech by opponent when player wins
  attr_accessor(:endspeechwin)    # Speech by opponent when opponent wins
  attr_accessor(:endspeechwin2)   # Speech by opponent when opponent wins
  attr_accessor(:trickroom)
  attr_accessor(:switchedOut)
  attr_accessor(:previousMove)    # Move used directly previously
  attr_accessor(:aiMoveMemory)
  attr_accessor(:ai)              #our baby who's gonna throw a lot of tantrums...
  attr_accessor(:midturn)
  attr_accessor(:rules)
  attr_reader(:turncount)
  attr_accessor :controlPlayer
  attr_accessor(:disableExpGain)  # True id no exp gain during this battle
  attr_accessor(:fainted_mons)    # Store which pokemon were fainted at the start of the battle
  attr_accessor(:ace_message)     # True if ace message should be displayed
  attr_accessor(:ace_message_handled) # True if ace message has been delivered
  attr_accessor(:commandphase)    # True if during the command phase of battle
  include PokeBattle_BattleCommon
  #### YUMIL - 3 - NPC REACTION MOD - START  
  attr_accessor(:recorded)
    
  #### YUMIL - 3 - NPC REACTION MOD - END  
  MAXPARTYSIZE = 6

  #### YUMIL - 4 - NPC REACTION MOD - START  
  def createNewBattleRecord
    if $battleDataArray.nil?
      $battleDataArray=[]
    end
    if @opponent.kind_of?(Array)
      $battleDataArray<<Battle_Data.new([@opponent[0].name,@opponent[1].name],@party1,@party2)
    else
      $battleDataArray<<Battle_Data.new(@opponent.name,@party1,@party2)
    end
  end
  #### YUMIL - 4 - NPC REACTION MOD - END 

  def pbAbort
    raise Exception.new("Battle aborted")
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
  #### YUMIL - 4.5 - NPC REACTION MOD - START  
  def initialize(scene,p1,p2,player,opponent,recorded=false)
    #### YUMIL - 4.5 - NPC REACTION MOD - START 
    @battle          = self
    @scene           = scene
    @decision        = 0
    @internalbattle  = true
    @doublebattle    = false
    @cantescape      = false
    @shiftStyle      = true
    @battlescene     = true
    @debug           = false
    @debugupdate     = 0
    #### YUMIL - 5 - NPC REACTION MOD - START
    @recorded        = recorded
    #### YUMIL - 5 - NPC REACTION MOD - END 
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
    @state           = PokeBattle_GlobalEffects.new    # Whole field (gravity/rooms)
    @field           = PokeBattle_Field.new
    @environment     = PBEnvironment::None   # e.g. Tall grass, cave, still water
    @weather         = 0
    @weatherduration = 0
    @switching       = false
    @choices         = [ [0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1] ]
    @successStates   = []
    for i in 0...4
      @successStates.push(PokeBattle_SuccessState.new)
    end
    @lastMoveUsed    = -1
    @lastMoveUser    = -1
    @aiMoveMemory    = [[],[],[[],[],[],[],[],[],[],[],[],[],[],[]]]
    @synchronize     = [-1,-1,0]
    @megaEvolution   = []
    @ultraBurst      = []
    @necrozmaVar     = [-1,-1]
    if @player.is_a?(Array)
      @megaEvolution[0]=[-1]*@player.length
      @ultraBurst[0]   =[-1]*@player.length
    else
      @megaEvolution[0]=[-1]
      @ultraBurst[0]   =[-1]
    end
    if @opponent.is_a?(Array)
      @megaEvolution[1]=[-1]*@opponent.length
      @ultraBurst[1]   =[-1]*@opponent.length
    else
      @megaEvolution[1]=[-1]
      @ultraBurst[1]   =[-1]
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
    @switchedOut     = []
    @extramoney      = 0
    @ace_message     = false
    @ace_message_handled = false
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
    @disableExpGain  = false
    @commandphase    = false
    if hasConst?(PBMoves,:STRUGGLE)
      @struggle = PokeBattle_Move.pbFromPBMove(self,PBMove.new(PBMoves::STRUGGLE),nil)
    else
      @struggle = PokeBattle_Struggle.new(self,nil,nil)
    end
    @struggle.pp     = -1
    for i in 0...4
      battlers[i] = PokeBattle_Battler.new(self,i)
    end
    if !isOnline?
      for i in @party1
        next if !i
        next if i.nil?
        i.obedient = i.level <= LEVELCAPS[pbPlayer.numbadges]
      end
    end
    for i in @party1
      next if !i
      i.itemRecycle = 0
      i.itemInitial = i.item
      i.itemReallyInitialHonestlyIMeanItThisTime = i.item
      i.belch       = false
      i.piece       = nil
    end
    for i in @party2
      next if !i
      i.itemRecycle = 0
      i.itemInitial = i.item
      i.belch       = false
      i.piece       = nil
    end
  #### YUMIL - 6 - NPC REACTION MOD - START  
  if @recorded == true
    createNewBattleRecord
  end
  #### YUMIL - 6 - NPC REACTION MOD - END   
  end

################################################################################
# Info about battle.
################################################################################
  def pbIsWild?
    return !@opponent ? true : false
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
      if @battlers[i].ability == PBAbilities::CLOUDNINE || @battlers[i].ability == PBAbilities::AIRLOCK || @field.effect == PBFields::UNDERWATER
        return 0
      end
    end
    return @weather
  end

  def seedCheck
    for battler in pbPriority
      next if battler.hp==0
      next if !battler.itemWorks?
      seeddata = @field.seeds
      next if battler.item != seeddata[:seedtype]
      boostlevel = ["","","sharply ", "drastically "]

      # Stat boost from seed
      statupanimplayed=false
      statdownanimplayed=false
      seeddata[:stats].each_pair {|stat,statval|
        statval *= -1 if battler.ability == PBAbilities::CONTRARY
        if statval > 0 && !battler.pbTooHigh?(stat)
          battler.pbIncreaseStatBasic(stat,statval)
          @battle.pbCommonAnimation("StatUp",battler) if !statupanimplayed
          statupanimplayed=true
          pbDisplay(_INTL("{1}'s {2} {3}boosted its {4}!", battler.pbThis,PBItems.getName(battler.item),boostlevel[statval.abs],battler.pbGetStatName(stat)))
        elsif statval < 0 && !battler.pbTooLow?(stat)
          battler.pbReduceStatBasic(stat,-statval)
          @battle.pbCommonAnimation("StatDown",battler) if !statdownanimplayed
          statdownanimplayed=true
          pbDisplay(_INTL("{1}'s {2} {3}lowered its {4}!", battler.pbThis,PBItems.getName(battler.item),boostlevel[statval.abs],battler.pbGetStatName(stat)))
        end
      }

      # Special effect from seed that need specific code
      case @field.effect
        when PBFields::MISTYT, PBFields::RAINBOWF,PBFields::STARLIGHTA
          if battler.effects[PBEffects::Wish]==0
            battler.effects[PBEffects::Wish]=2
            battler.effects[PBEffects::WishAmount]=((battler.totalhp+1)*0.75).floor
            battler.effects[PBEffects::WishMaker]=battler.pokemonIndex
            pbAnimation(seeddata[:animation],battler,nil)
            pbDisplay(_INTL(seeddata[:message],battler.pbThis(true)))
          end
          battler.pbDisposeItem(false)
          return

        when PBFields::BURNINGF, PBFields::DESERTF
          battler.effects[PBEffects::MultiTurn]=4
          battler.effects[PBEffects::MultiTurnUser]=battler.index

        when PBFields::CORROSIVEMISTF, PBFields::MURKWATERS
          if battler.pbCanPoison?(true)
            battler.pbPoison(battler,true)
            pbDisplay(_INTL("{1} was badly poisoned!",battler.pbThis))
          end
          battler.pbDisposeItem(false)
          return if @field.effect == PBFields::CORROSIVEMISTF

        when PBFields::ICYF
          if !battler.isAirborne? && battler.ability != PBAbilities::MAGICGUARD
            spikesdiv=[8,8,6,4][battler.pbOwnSide.effects[PBEffects::Spikes]]
            @scene.pbDamageAnimation(battler,0)
            battler.pbReduceHP([(battler.totalhp.to_f/spikesdiv).floor,1].max)
            pbDisplay(_INTL(seeddata[:message],battler.pbThis))
            battler.pbDisposeItem(false)
            battler.pbFaint if battler.isFainted?
          end
          battler.pbDisposeItem(false)
          return

        when PBFields::ROCKYF, PBFields::CAVE
          if battler.ability != PBAbilities::MAGICGUARD
            atype=(PBTypes::ROCK) || 0
            eff=PBTypes.getCombinedEffectiveness(atype,battler.type1,battler.type2)
            if eff>0
              eff = eff*2
              @scene.pbDamageAnimation(battler,0)
              battler.pbReduceHP([(battler.totalhp*eff/32).floor,1].max)
              pbDisplay(_INTL(seeddata[:message],battler.pbThis))
              battler.pbDisposeItem(false)
              battler.pbFaint if battler.isFainted?
            end
          end
          battler.pbDisposeItem(false)
          return

        when PBFields::WASTELAND
          battler.pbDisposeItem(false)
          battler.pbOwnSide.effects[PBEffects::StealthRock]=true
          battler.pbOpposingSide.effects[PBEffects::StealthRock]=true
          pbDisplay(_INTL("{1} laid Stealth Rocks everywhere!", battler.pbThis))
          return

        when PBFields::UNDERWATER
          if battler.ability == PBAbilities::MULTITYPE || battler.ability == PBAbilities::RKSSYSTEM
            battler.pbDisposeItem(false)
            return
          end
          battler.type1=(PBTypes::WATER)
          battler.type2=(PBTypes::WATER)
          pbDisplay(_INTL(seeddata[:message],battler.pbThis))
          battler.pbDisposeItem(false)
          return

        when PBFields::GLITCHF
          if battler.ability == PBAbilities::MULTITYPE || battler.ability == PBAbilities::RKSSYSTEM
            battler.pbDisposeItem(false)
            return
          end
          battler.type1=(PBTypes::QMARKS)
          battler.type2=(PBTypes::QMARKS)
          pbDisplay(_INTL(seeddata[:message],battler.pbThis))
          battler.pbDisposeItem(false)
          return

        when PBFields::MOUNTAIN,PBFields::SNOWYM,PBFields::MIRRORA
          battler.pbDisposeItem(false)
          return

        when PBFields::NEWW,PBFields::INVERSEF
          battler.currentMove=0

        when PBFields::PSYCHICT
          if battler.pbCanConfuse?(false)
            battler.effects[PBEffects::Confusion]=2+pbRandom(4)
            pbCommonAnimation("Confusion",battler,nil)
            pbDisplay(_INTL("{1} became confused!",battler.pbThis))
          end
          battler.pbDisposeItem(false)
          return
      end

      # Special effect from seed that doesn't need specific code
      battler.effects[seeddata[:effect]] = seeddata[:duration]
      pbAnimation(seeddata[:animation],battler,nil) unless @field.effect == PBFields::SUPERHEATEDF
      if seeddata[:message].start_with?("{1}")
        pbDisplay(_INTL(seeddata[:message],battler.pbThis))
      else
        pbDisplay(_INTL(seeddata[:message],battler.pbThis(true)))
      end
      battler.pbDisposeItem(false)
      if @field.effect == PBFields::FLOWERGARDENF 
        growField("The synthetic seed")
      end
      battler.pbCheckForm
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
      else
        return _INTL("The wild {1}",party[pokemonindex].name)
      end
    else
      return _INTL("{1}",party[pokemonindex].name)
    end
  end

  # Checks whether an item can be removed from a Pokémon.
  def pbIsUnlosableItem(pkmn,item)
    #return true if pbIsMail?(item)
    return true if pbIsZCrystal?(item)
    return false if pkmn.effects[PBEffects::Transform]
    if (pkmn.species == PBSpecies::ARCEUS)
      if [PBItems::FISTPLATE,   PBItems::SKYPLATE,    PBItems::TOXICPLATE,  PBItems::EARTHPLATE,  PBItems::STONEPLATE,
          PBItems::INSECTPLATE, PBItems::SPOOKYPLATE, PBItems::IRONPLATE,   PBItems::FLAMEPLATE,  PBItems::SPLASHPLATE, 
          PBItems::MEADOWPLATE, PBItems::ZAPPLATE,    PBItems::MINDPLATE,   PBItems::ICICLEPLATE, PBItems::DRACOPLATE,
          PBItems::PIXIEPLATE,  PBItems::DREADPLATE].include?(item)
        return true
      end
    end
    if (pkmn.species == PBSpecies::SILVALLY)
      if [PBItems::FIGHTINGMEMORY,  PBItems::FLYINGMEMORY,    PBItems::POISONMEMORY,  PBItems::GROUNDMEMORY,  PBItems::ROCKMEMORY,
          PBItems::BUGMEMORY,       PBItems::GHOSTMEMORY,     PBItems::STEELMEMORY,   PBItems::FIREMEMORY,    PBItems::WATERMEMORY, 
          PBItems::GRASSMEMORY,     PBItems::ELECTRICMEMORY,  PBItems::PSYCHICMEMORY, PBItems::ICEMEMORY,     PBItems::DRAGONMEMORY, 
          PBItems::FAIRYMEMORY,     PBItems::DARKMEMORY].include?(item)
        return true
      end
    end
    return true if PBStuff::POKEMONTOMEGASTONE[pkmn.species].include?(item)
    return true if (pkmn.species == PBSpecies::GENESECT) && ((item == PBItems::SHOCKDRIVE) || (item == PBItems::BURNDRIVE) || (item == PBItems::CHILLDRIVE) || (item == PBItems::DOUSEDRIVE)) 
    return true if (pkmn.species == PBSpecies::GROUDON) && (item == PBItems::REDORB)
    return true if (pkmn.species == PBSpecies::KYOGRE) && (item == PBItems::BLUEORB)
    return true if (pkmn.species == PBSpecies::GIRATINA) && (item == PBItems::GRISEOUSORB)
    return true if (item == PBItems::PULSEHOLD)
    return false
  end


  def pbCheckGlobalAbility(a)
    for i in 0...4 # in order from own first, opposing first, own second, opposing second
      if @battlers[i].ability == PBAbilities.const_get(a.to_sym)
        return @battlers[i] if @battlers[i].hasWorkingAbility(a)
      end
    end
    return nil
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

  def items=(items)
    @items = items.clone
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

  def pbPartySingleOwner(battlerIndex)
    party = pbParty(battlerIndex)
    ownerparty = []
    for i in 0...party.length
      ownerparty.push(party[i]) if pbIsOwner?(battlerIndex,i) && !party[i].nil?
    end
    return ownerparty
  end

  def pbPartySingleOwnerNonBattler(battler)
    party = pbPartySingleOwner(battler.index)
    party=party.find_all {|mon| !mon.nil? && battler.pokemon != mon}
    return party
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

  def pieceAssignment(party,trainer_array)
    return if party.length == 0
    pkmnparty = party.find_all {|mon| !mon.nil? && !mon.isEgg? }
    pkmnparty.each {|pkmn| pkmn.piece = nil}
    # Queen
    pkmnparty.last.piece = :QUEEN
    # Pawn
    sendoutorder = pkmnparty.find_all {|mon| mon.hp > 0}
    sendoutorder[0].piece = :PAWN if sendoutorder[0].piece.nil?
    sendoutorder[1].piece = :PAWN if sendoutorder[1] && @doublebattle && !trainer_array && sendoutorder[1].piece.nil? 
    # King
    king_piece = pkmnparty.sort_by { |mon| [mon.piece.nil? ? 0 : 1, mon.item==PBItems::KINGSROCK ? 0 : 1, mon.totalhp] }.first
    king_piece.piece = :KING if king_piece && king_piece.piece.nil?

    pkmnparty.each do |pkmn|
      next if pkmn.piece != nil
      pkmn.piece = :KNIGHT if [pkmn.speed,pkmn.attack,pkmn.spatk,pkmn.defense,pkmn.spdef].max == pkmn.speed
      pkmn.piece = :BISHOP if [pkmn.speed,pkmn.attack,pkmn.spatk,pkmn.defense,pkmn.spdef].max == [pkmn.attack,pkmn.spatk].max
      pkmn.piece = :ROOK   if [pkmn.speed,pkmn.attack,pkmn.spatk,pkmn.defense,pkmn.spdef].max == [pkmn.defense,pkmn.spdef].max
    end
  end

  def pbAceMessage
    trainer = @opponent
    # Define any trainers that you want to activate this script below
    # For each defined trainer, add the BELOW section for them
    ace_text = ""
    case trainer.trainertype
      when PBTrainers::Hotshot
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("You think you can get away with that?")
          when 1 then ace_text = _INTL("You don't actually think you're special, do you?")
          when 2 then ace_text = _INTL("You're really starting to grate on my nerves, and you don't wanna do that.")
          when 4 then ace_text = _INTL("Pfft, picking on you is way too easy.")
          when 5 then ace_text = _INTL("You're a real thorn in my side, you know?")
          when 7 then ace_text = _INTL("Why... WHY?!")
        end
      when PBTrainers::FERN2
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("It's hard not to be a little disappointed here, but I'm not gonna let that get me down!")
        end
      when PBTrainers::UMBFERN
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("I've beeN scaReD everY daY oF mT lIfE anD losT thE ploT foR iT. BuT I'm NoT abouT tO losE iT agaiN!")
        end
      when PBTrainers::JULIA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Don'tgoboom,don'tgoboom,don'tgoboom...")
        end
      when PBTrainers::Victoria
        case $game_variables[:Battle_Text_of_Opponent]
          when 1 then ace_text = _INTL("I'm not capitulating yet! One last push!")
          when 3 then ace_text = _INTL("Did you know? When one's back is against the wall, that's when they're at their strongest!")
          when 4 then ace_text = _INTL("You're gonna have to hit a lot harder than that if you expect to break through!")
        end
      when PBTrainers::Victoria2
        case $game_variables[:Battle_Text_of_Opponent]
          when 7 then ace_text = _INTL("To minimize the chaos within... Sensei, I'm so sorry.")
        end
      when PBTrainers::Cain
        case $game_variables[:Battle_Text_of_Opponent]
          when 1 then ace_text = _INTL("Aha, well this is a rough first battle for the little guy. But the first time is always rough, huh?")
          when 2 then ace_text = _INTL("I am sooo getting bent-over here.")
          when 3 then ace_text = _INTL("You know, I can't help but be feeling a little nervous here, haha...")
          when 5 then ace_text = _INTL("You always seem to overwhelm me...~")
        end
      when PBTrainers::UMBCAIN
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("DisGustIng, diSGustINg, DiSGUsTING!!!")
        end
      when PBTrainers::FLORINIA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Conclusion forthcoming...")
          when 3 then ace_text = _INTL("The present moment remains an inopportune time for emotional interference... Nevertheless...")
        end
      when PBTrainers::Taka
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("It's a shame it has to come to this, but...")
          when 1 then ace_text = _INTL("I guess that means it's time for this, right?")
          when 2 then ace_text = _INTL("Defeat was never such a relief.")
          when 3 then ace_text = _INTL("I know I can't win...")
        end
      when PBTrainers::UMBTAKA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("WhY shoUld I tuRn taiL and fLEe whEn I caN sImpLy brEak whAt's MiNe?")
        end
      when PBTrainers::ACECLUBS
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Please stay seated! The main act is yet to come!")
        end
      when PBTrainers::ACEDIAMONDS
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("And now might I give a thousand furlongs of sea for an acre of barren ground...")
        end
      when PBTrainers::ACEHEARTS
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Perhaps it is foolish to expect the third movement to sing a separate song from the first two.")
        end
      when PBTrainers::ACESPADES
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Ah, is it just me? Or does your heart not seem to really be in this? What are you hiding?")
        end
      when PBTrainers::UMBACE
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("IlLusIons Exist For the Comfort Of the wAtcher. Why eLse shouLd anyoNe belIeve In tHeM?")
        end
      when PBTrainers::Corey
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Disappointment is a two-way street.")
          when 1 then ace_text = _INTL("All things must end eventually. Some are overdue.")
        end
      when PBTrainers::SHELLY
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Hehe... Failing again...")
        end
      when PBTrainers::SHADE
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("...")
        end
      when PBTrainers::EUPHIE
        case $game_variables[:Battle_Text_of_Opponent]
          when 1 then ace_text = _INTL("...Mm.")
        end
      when PBTrainers::ZEL
        case $game_variables[:Battle_Text_of_Opponent]
          when 2 then ace_text = _INTL("Zel: Tch, no choice then!")
          when 4 then ace_text = _INTL("zeL: I'm sorry, Magnezone... If we're gonna get through this, we need your help!")
        end
      when PBTrainers::ZEL2
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Go down, go down, go down, go down, go down, go down, go down, go down, GO DOWN!!!")
        end
      when PBTrainers::Sensei
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("To minimize the chaos within... Perhaps it's too late.")
        end
      when PBTrainers::UMBKIKI
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("To minimize the chaos within... It's never too late for that.")
          end
      when PBTrainers::AYA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Just finish it already, why don't you.")
        end
      when PBTrainers::Sirius
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Perhaps we've left this threat unchecked for too long.")
          when 1 then ace_text = _INTL("I will blot out every inkling of your existence! None will remember you after I'm through!")
          when 2 then ace_text = _INTL("Do you know what it's like, to feel the meanders and chasms of history slip through your fingers?")
        end
      when PBTrainers::DOCTOR
        case $game_variables[:Battle_Text_of_Opponent]
          when 0,1 then ace_text = _INTL("Your silence does not eclipse your impertinence.")
          when 2 then ace_text = _INTL("Gentleness has a time and place. So does justice.")
        end
      when PBTrainers::BENNETT
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("I see, I see... You are at a highly advanced stage of metamorphosis already!")
          when 1 then ace_text = _INTL("Tch, she would never... No! I won't give up! I'll make her see!")
        end
      when PBTrainers::SERRA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Ice, like a mirror, will never be perfect again once it cracks.")
        end
      when PBTrainers::RADOMUS
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Well, well, I am impressed.")
        end
      when PBTrainers::NOEL
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("It's too bad. They can't always get what they want.")
        end
      when PBTrainers::LUNA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Oh? Perhaps I've lost my way after all. How wonderful!")
        end
      when PBTrainers::SAMSON
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("No sweat. I've been in worse positions.")
        end
      when PBTrainers::EclipseDame
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("ECLIPSE: Seriously, can we stop this already?")
        end
      when PBTrainers::UMBECLIPSE
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("You'rE stilL hERe?")
        end
      when PBTrainers::CHARLOTTE
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Ever seen a wildfire start from just a spark? ...D'you wanna?")
        end
      when PBTrainers::AsterAce
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Eclipse-- I'm sorry.")
        end
      when PBTrainers::TERRA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("FUCK!!! THE WHAT!!!!!!!")
          when 1 then ace_text = _INTL("Hey... Is this really what you want now?")
        end
      when PBTrainers::UMBTERRA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("arE wE donE yeT? can'T yoU KO mE anY fasteR?")
        end
      when PBTrainers::CIEL
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Hold your applause! You've yet to see the final act!")
        end
      when PBTrainers::ARCLIGHT
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("You've got a good showing. But don't think I'm going off the air just yet!")
        end
      when PBTrainers::ADRIENN
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("I haven't had a battle this exhilarating in ages-- even by my twisted timeline!")
        end
      when PBTrainers::OLDCAL
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("What's your FUCKING problem, huh?!")
        end
      when PBTrainers::Exleader
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("...This feels empty.")
        end
      when PBTrainers::REBORN
        case $game_variables[:Battle_Text_of_Opponent]
          when 2 then ace_text = _INTL("Can't say I didn't expect this. It's you after all.")
        end
      when PBTrainers::CORINROUGE
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("So it's come to this after all. Let us see what this so-called ultra powerful Pokemon can-- Wait, what?")
        end
      when PBTrainers::TITANIA1
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Not bad. But you really should learn when to quit.")
        end
      when PBTrainers::TITANIA2
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Don't get cocky. It's not like this means anything.")
        end
      when PBTrainers::AMARIA1
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("You're doing well! Just be ready for what comes after...")
        end
      when PBTrainers::AMARIA2
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Drown.")
        end
      when PBTrainers::Solaris
        case $game_variables[:Battle_Text_of_Opponent]
          when 2 then ace_text = _INTL("Children cry because they do not understand.")
        end
      when PBTrainers::QMARK
        case $game_variables[:Battle_Text_of_Opponent]
          when 1 then ace_text = _INTL("Th-se wh- h-ve -ost m-st -lway- -ind --ch -the-. B-t --ere ev-r -re -ou loo-ing?")
        end
      when PBTrainers::HARDY
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("What happens here is one thing... But don't think our spirit can ever be broken!")
        end
      when PBTrainers::BLAKE
        case $game_variables[:Battle_Text_of_Opponent]
          when 2 then ace_text = _INTL("Are you kidding me?")
        end
      when PBTrainers::SAPHIRA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("So what? I'm down, but never out.")
        end
      when PBTrainers::HEATHER
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("HEATHER: I have sky high power! I won't back down!")
          when 1 then ace_text = _INTL("HEATHER: Wow, high-schoolers really are the worst, huh?")
          when 2 then ace_text = _INTL("HEATHER: I won't give up that easily! Hit me with everything you've got!")
        end
      when PBTrainers::BENNETTLAURA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("LAURA: Everything is blossoming quite nicely for you, isn't it? I hope you cherish this moment.")
        end
      when PBTrainers::BENNETT2
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("You use... unconventional strategies... for a tag team. And yet, clearly I still have much to learn.")
          when 1 then ace_text = _INTL("...Ah. It appears that there is still yet much for me to discover on this journey.")
        end
      when PBTrainers::LAURA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("It's always a pleasure to see how others of my types choose to battle.")
          when 1 then ace_text = _INTL("The flowers are especially beautiful and bright today. Your shine is just as brilliant as theirs!")
        end
      when PBTrainers::ELIAS
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Even should His light fade for now, it will inevitably shine bright once more in time. This, too, is His will.")
          when 1 then ace_text = _INTL("Even in a loss, it is a pleasure to be graced with your talent, time and attention.")
          when 2 then ace_text = _INTL("Dominus illuminatio mea. As always, I strive to make the most of the lessons my Lord grants to me.")
        end
      when PBTrainers::ANNA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("ANNA: Nostra, it's time! Please, give us the last of your strength!")
        end
      when PBTrainers::ANNA2
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("hahahahaHAHA?! what do you MEAN this still isn't enough!?")
        end
      when PBTrainers::LIN
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("And now for the PULSE you've eagerly awaited... Oh, was this not it?")
          when 1 then ace_text = _INTL("Smile now. This means nothing. Little more than your ever-fleeting mirth will ever come to you.")
        end
      when PBTrainers::CHILDLIN
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("here, puppy! go get 'em!!")
          when 1 then ace_text = _INTL("oh noooo, what ever will i do now...")
        end
      when PBTrainers::UMBSAMSON
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("STOP gETtING in MY wAY! ThIS is HoW it HAS tO bE!")
        end
      when PBTrainers::UMBCIEL
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("WhY cAn'T yOU jUST lET mE gO...?")
        end
      when PBTrainers::FLORA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("...Okay, hold on. What's going on here? Am I losing?")
        end
      when PBTrainers::EVE
        case $game_variables[:Battle_Text_of_Opponent]
          when 1 then ace_text = _INTL("Are you really sure this is what you need to be doing?")
        end
      when PBTrainers::LUMI
        case $game_variables[:Battle_Text_of_Opponent]
          when 1 then ace_text = _INTL("I'm doing this for all of us! Please don't get in my way!")
        end
      when PBTrainers::SHANNON
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("Quit your grandstanding and bow down already!")
        end
      when PBTrainers::ZINA
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("All tucked in? It's time for lights out.")
        end
      when PBTrainers::SHIV
        case $game_variables[:Battle_Text_of_Opponent]
          when 0 then ace_text = _INTL("This is shaping up to be an interesting day, indeed.")
          when 1 then ace_text = _INTL("Hmph... This is pleasantly surprising.")
        end
    end
    if ace_text != ""
      @scene.pbShowOpponent(0) if trainer.trainertype != PBTrainers::HEATHER && trainer.trainertype != PBTrainers::ANNA
      pbDisplayPaused(ace_text)
      @scene.pbHideOpponent if trainer.trainertype != PBTrainers::HEATHER && trainer.trainertype != PBTrainers::ANNA
    end
    @ace_message_handled = true
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
    return false if thispkmn.effects[PBEffects::Rage]==true && @field.effect == PBFields::GLITCHF
    return false if thispkmn.effects[PBEffects::Uproar]>0
    return false if thispkmn.effects[PBEffects::Bide]>0
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
    if !pbCanChooseMove?(idxPokemon,0,false) && !pbCanChooseMove?(idxPokemon,1,false) && !pbCanChooseMove?(idxPokemon,2,false) && !pbCanChooseMove?(idxPokemon,3,false)
      return false
    end
    # Encore
    return false if thispkmn.effects[PBEffects::Encore]>0
    return true
  end

  def pbCanChooseMove?(idxPokemon,idxMove,showMessages,flags={sleeptalk: false, instructed: false})
    sleeptalk = flags.fetch(:sleeptalk, false)
    instructed = flags.fetch(:instructed, false)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    opp1=thispkmn.pbOpposing1
    opp2=thispkmn.pbOpposing2
    if !thismove||thismove.id==0
      return false
    end
    if thismove.pp<=0 && thismove.totalpp>0 && !sleeptalk
      if showMessages
        pbDisplayPaused(_INTL("There's no PP left for this move!"))
      end
      return false
    end
    if thispkmn.effects[PBEffects::ChoiceBand]>=0 && thispkmn.itemWorks? && (thispkmn.item == PBItems::CHOICEBAND || thispkmn.item == PBItems::CHOICESPECS || thispkmn.item == PBItems::CHOICESCARF) || thispkmn.ability == PBAbilities::GORILLATACTICS
      if thispkmn.moves.any? {|moveloop| moveloop.id==thispkmn.effects[PBEffects::ChoiceBand]} && (thismove.id!=thispkmn.effects[PBEffects::ChoiceBand] && sleeptalk == false)
        if showMessages
          pbDisplayPaused(_INTL("{1} allows the use of only {2}!",
             PBItems.getName(thispkmn.item),
             PBMoves.getName(thispkmn.effects[PBEffects::ChoiceBand])))
        end
        return false
      end
    end
    if (thispkmn.item == PBItems::ASSAULTVEST) && !instructed && thismove.category == 2
        if showMessages
          pbDisplayPaused(_INTL("{1} doesn't allow use of non-attacking moves!", PBItems.getName(thispkmn.item)))
        end
        return false
    end
    if opp1.effects[PBEffects::Imprison]
      if thismove.id==opp1.moves[0].id || thismove.id==opp1.moves[1].id || thismove.id==opp1.moves[2].id || thismove.id==opp1.moves[3].id
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the sealed {2}!",thispkmn.pbThis,thismove.name))
        end
       #PBDebug.log("[CanChoose][#{opp1.pbThis} has: #{opp1.moves[0].name}, #{opp1.moves[1].name},#{opp1.moves[2].name},#{opp1.moves[3].name}]") if $INTERNAL
        return false
      end
    end
    if opp2.effects[PBEffects::Imprison]
      if thismove.id==opp2.moves[0].id || thismove.id==opp2.moves[1].id || thismove.id==opp2.moves[2].id || thismove.id==opp2.moves[3].id
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
    if thispkmn.effects[PBEffects::Torment] && !instructed
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
      return true
    end
    if thispkmn.effects[PBEffects::Encore]>0 && pbCanChooseMove?(idxPokemon,thispkmn.effects[PBEffects::EncoreIndex],false)
      PBDebug.log("[Auto choosing Encore move...]") if $INTERNAL
      @choices[idxPokemon][0]=1    # "Use move"
      @choices[idxPokemon][1]=thispkmn.effects[PBEffects::EncoreIndex] # Index of move
      @choices[idxPokemon][2]=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
      @choices[idxPokemon][3]=-1   # No target chosen yet
      if thispkmn.effects[PBEffects::EncoreMove] == PBMoves::ACUPRESSURE
        @choices[idxPokemon][3] = idxPokemon
      elsif @doublebattle
        thismove=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
        if thismove.target==PBTargets::SingleNonUser
          @scene.pbFightMenuEncore(idxPokemon,thispkmn.effects[PBEffects::EncoreIndex])
          target=@scene.pbChooseTarget(idxPokemon)
          pbRegisterTarget(idxPokemon,target) if target>=0
          return false if target<0
        elsif thismove.target==PBTargets::UserOrPartner
          @scene.pbFightMenuEncore(idxPokemon,thispkmn.effects[PBEffects::EncoreIndex])
          target=@scene.pbChooseTarget(idxPokemon)
          pbRegisterTarget(idxPokemon,target) if target>=0 && (target&1)==(idxPokemon&1)
          return false if target<0
        else
          target=thispkmn.pbTarget(thismove)
          pbRegisterTarget(idxPokemon,target)
        end
     end
     return true
    else
      if !pbIsOpposing?(idxPokemon)
        pbDisplayPaused(_INTL("{1} has no moves left!",thispkmn.name)) if showMessages
      end
      @choices[idxPokemon][0]=1           # "Use move"
      @choices[idxPokemon][1]=-1          # Index of move to be used
      @choices[idxPokemon][2]=@struggle   # Use Struggle
      @choices[idxPokemon][3]=-1          # No target chosen yet
      return true
    end
  end

  def pbRegisterMove(idxPokemon,idxMove,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    thispkmn.selectedMove = thismove.id
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


  def pbPriority(ignorequickclaw = true,megacalc = false)
    return @priority if @usepriority && !megacalc # use stored priority if round isn't over yet (best ged rid of this in gen 8)
    @priority.clear
    priorityarray = []
    # -Move priority take precedence(stored as priorityarray[i][0])
    # -Then Items  (stored as priorityarray[i][1])
    # -Then speed (stored as priorityarray[i][2]) (trick room is applied by just making speed negative.)
    # -The last element is just the battler index (which is otherwise lost when sorting)
    for i in 0..3
      priorityarray[i] = [0,0,0,i] #initializes the array and stores the battler index

      # Move priority
      pri = 0
      if (@choices[i][0] == 2 || @battle.switchedOut[i]) # If switching or has switched
        pri = 12
      end
      if @choices[i][0] == 3 #Used item
        pri = 11
      end
      if @choices[i][0] == 1 # Is a move
        pri = @choices[i][2].priority if !@choices[i][2].zmove  #Base move priority
        pri += 1 if @field.effect == PBFields::CHESSB && @battlers[i].pokemon && @battlers[i].pokemon.piece == :KING
        pri += 1 if @battlers[i].ability == PBAbilities::PRANKSTER && @choices[i][2].basedamage==0 && @battlers[i].effects[PBEffects::TwoTurnAttack] == 0 # Is status move
        pri += 1 if @battlers[i].ability == PBAbilities::GALEWINGS && @choices[i][2].type==PBTypes::FLYING && ((@battlers[i].hp == @battlers[i].totalhp) || ((@field.effect == PBFields::MOUNTAIN || @field.effect == PBFields::SNOWYM) && @weather == PBWeather::STRONGWINDS))
        pri += 3 if @battlers[i].ability == PBAbilities::TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function)
      end
      priorityarray[i][0]=pri

      #Item/stall priority (all items overwrite stall priority)
      priorityarray[i][1] = -1 if @battlers[i].ability == PBAbilities::STALL 
      if !ignorequickclaw && @choices[i][0] == 1 # Is a move
        priorityarray[i][1] = 1 if @battlers[i].custap || (@battlers[i].itemWorks? && @battlers[i].item == PBItems::QUICKCLAW && (pbRandom(100)<20))
      end
      priorityarray[i][1] = -2 if (@battlers[i].itemWorks? && (@battlers[i].item == PBItems::LAGGINGTAIL || @battlers[i].item == PBItems::FULLINCENSE))

      #speed priority
      priorityarray[i][2] = @battlers[i].pbSpeed if @trickroom == 0
      priorityarray[i][2] = -@battlers[i].pbSpeed if @trickroom > 0
      
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
      if (@battlers[i].itemWorks? && @battlers[i].item == PBItems::QUICKCLAW)
        pbDisplayBrief(_INTL("{1}'s Quick Claw let it move first!",@priority[i].pbThis)) if priorityarray[i][1] == 1 && !ignorequickclaw
      end
    end
    @usepriority=true
    return @priority
  end

 # Makes target pokemon move last
  def pbMoveLast(target)
    priorityTarget = pbGetPriority(target)
    priority = @priority
    case priorityTarget
    when 0
      # Opponent has likely already moved
      return false
    when 1
      priority[1], priority[2], priority[3] = priority[2], priority[3], target
      @priority = priority
      return true
    when 2
      priority[2], priority[3] = priority[3], priority[2]
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
        priority[1], priority[2] = second, priority[1]
        @priority = priority
        return true
      elsif second == priority[3]
        priority[1],priority[2],priority[3] = second, priority[1], priority[2]
        @priority = priority
        return true
      end
    when 1
      if second == priority[0] || second == priority[2]
        # Nothing to do here
        return false
      elsif second == priority[3]
        priority[2], priority[3] = priority[3], priority[2]
        @priority = priority
        return true
      end
    when 2
      return false
    when 3
      return false
    end
  end


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
      if pkmnidxTo>=party.length
        return false
      end
      if !party[pkmnidxTo]
        return false
      end
      if party[pkmnidxTo].nil?
        return false
      end
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

  def pbCanSwitch?(idxPokemon,pkmnidxTo,showMessages,ai_phase=false,running: false)
    thispkmn=@battlers[idxPokemon]
    # Multi-Turn Attacks/Mean Look
    if !pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
      return false
    end
    # UPDATE 11/16/2013
    # Ghost type can now escape from anything
    isOpposing=pbIsOpposing?(idxPokemon)
    party=pbParty(idxPokemon)
    for i in 0...4
      next if isOpposing!=pbIsOpposing?(i)
      if choices[i][0]==2 && choices[i][1]==pkmnidxTo && !ai_phase
        pbDisplayPaused(_INTL("{1} has already been selected.",party[pkmnidxTo].name)) if showMessages
        return false
      end
    end
    if thispkmn.pbHasType?(:GHOST)
      return true
    end
    if thispkmn.effects[PBEffects::SkyDrop] #lía
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    if thispkmn.hasWorkingItem(:SHEDSHELL)
      return true
    end
    if thispkmn.effects[PBEffects::MultiTurn]>0 || thispkmn.effects[PBEffects::MeanLook]>=0 || @state.effects[PBEffects::FairyLock]==1
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
      opp=opp1 if opp1.ability == PBAbilities::MAGNETPULL
      opp=opp2 if opp2.ability == PBAbilities::MAGNETPULL
    end
    if !thispkmn.isAirborne?
      opp=opp1 if opp1.ability == PBAbilities::ARENATRAP
      opp=opp2 if opp2.ability == PBAbilities::ARENATRAP
    end
    unless thispkmn.ability == PBAbilities::SHADOWTAG
      opp=opp1 if opp1.ability == PBAbilities::SHADOWTAG
      opp=opp2 if opp2.ability == PBAbilities::SHADOWTAG
    end
    if opp
      abilityname=PBAbilities.getName(opp.ability)
      pbDisplayPaused(_INTL("{1}'s {2} prevents switching!",opp.pbThis,abilityname)) if showMessages
      pbDisplayPaused(_INTL("{1} prevents escaping with {2}!", opp.pbThis, abilityname)) if (showMessages || running) && pkmnidxTo == -1
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
    if @ultraBurst[side][owner]==idxPokemon
      @ultraBurst[side][owner]=-1
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
        if (!pbIsOpposing?(index) || (@opponent && pbIsOpposing?(index)))
          newenemy=pbSwitchInBetween(index,false,false)
          newname = pbSwitchInName(index,newenemy) #Illusion

          opponent=pbGetOwner(index)
          if !@doublebattle && firstbattlerhp>0 && @shiftStyle && @opponent && @internalbattle && pbCanChooseNonActive?(0) && pbIsOpposing?(index) && @battlers[0].effects[PBEffects::Outrage]==0
            pbDisplayPaused(_INTL("{1} is about to send in {2}.",opponent.fullname,newname)) 
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
      if newpoke != nil
        for j in 0..index
         if (@battlers[j].ability == PBAbilities::TRACE)
          @battlers[j].pbAbilitiesOnSwitchIn(true)
         end
        end
      end
    end
    if switched.length>0
      priority=pbPriority
      for i in priority
        i.pbAbilitiesOnSwitchIn(true) if switched.include?(i.index)
      end
      for i in priority
        seedCheck
      end
    end
  end

  def pbSendOut(index,pokemon)
    #AI CHANGES
    @aiMoveMemory[0].clear
    @aiMoveMemory[1].clear if !pbIsOpposing?(index)
    @ai.addMonToMemory(pokemon,index)
    pbSetSeen(pokemon)
    @peer.pbOnEnteringBattle(self,pokemon)
    if pbIsOpposing?(index)
      #  in-battle text
      @scene.pbTrainerSendOut(index,pokemon)
      # Last Pokemon script; credits to venom12 and HelioAU
      if !@opponent.is_a?(Array) && pbPokemonCount(@party2)==1 && !@ace_message_handled
        pbAceMessage()
      end
    else
      @scene.pbSendOut(index,pokemon)
    end
    @scene.pbResetMoveIndex(index)
  end

  def pbReplace(index,newpoke,batonpass=false)
    if @battlers[index].effects[PBEffects::Illusion]
      @battlers[index].effects[PBEffects::Illusion] = nil
    end
    party=pbParty(index)
    if pbOwnedByPlayer?(index)
      # Reorder the party for this battle
      bpo=-1; bpn=-1
      for i in 0...6
        bpo=i if @partyorder[i]==@battlers[index].pokemonIndex
        bpn=i if @partyorder[i]==newpoke
      end
      if bpo != -1
        poke1=@partyorder[bpo]
        @partyorder[bpo]=@partyorder[bpn]
        @partyorder[bpn]=poke1
      end
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
    @battlers[index].vanished = false if @battlers[index].vanished
    @switchedOut[index] = true
    pbClearChoices(index)
    @battlers[index].pbResetForm
    if !@battlers[index].isFainted?
      @scene.pbRecall(index)
    end
    pbMessagesOnReplace(index,newpoke)
    pbReplace(index,newpoke,batonpass)
    @scene.partyBetweenKO2(!pbOwnedByPlayer?(index)) unless @doublebattle
    return pbOnActiveOne(@battlers[index])
  end

  def pbMessagesOnReplace(index,newpoke)
    newname = pbSwitchInName(index,newpoke)
    if pbOwnedByPlayer?(index)
      opposing=@battlers[index].pbOppositeOpposing
      if opposing.hp<=0 || opposing.hp==opposing.totalhp
        pbDisplayBrief(_INTL("Go! {1}!",newname))
      elsif opposing.hp>=(opposing.totalhp/2.0)
        pbDisplayBrief(_INTL("Do it! {1}!",newname))
      elsif opposing.hp>=(opposing.totalhp/4.0)
        pbDisplayBrief(_INTL("Go for it, {1}!",newname))
      else
        pbDisplayBrief(_INTL("Your foe's weak!\nGet 'em, {1}!",newname))
      end
    else
      owner=pbGetOwner(index)
      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",owner.fullname,newname))
    end
  end

  def pbSwitchInBetween(index,lax,cancancel)
    if !pbOwnedByPlayer?(index)
      PBDebug.log("[AI made a switch]\n")
      return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      PBDebug.log("[Player made a switch]\n")
      return pbSwitchPlayer(index,lax,cancancel)
    end
  end

  def pbSwitchPlayer(index,lax,cancancel)
    if @debug || $testing
      return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      return @scene.pbSwitch(index,lax,cancancel)
    end
  end

  def pbSwitchInName(index,newpoke) #Illusion
    partynumber = pbParty(index)
    party=pbPartySingleOwner(index)
    newname=nil
    if (partynumber[newpoke].ability == PBAbilities::ILLUSION)
      party2=party.find_all {|item| item && !item.egg? && item.hp>0 }
      if party2[-1] != partynumber[newpoke] #last mon isn't the same illusion mon
        illusionpoke = party2[-1]
      end
    end
    if pbIsOpposing?(index)
      newname = illusionpoke != nil ? illusionpoke.name : PBSpecies.getName(partynumber[newpoke].species)
    else
      newname = illusionpoke != nil ? illusionpoke.name : partynumber[newpoke].name
    end
    return newname
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
      #### YUMIL - 7 - NPC REACTION MOD - START
      if @recorded == true
        $battleDataArray.last().playerUsedAnItem
      end
      #### YUMIL - 7 - NPC REACTION MOD - END 
    end
    if !ret && pbBelongsToPlayer?(userPkmn.index)
      if $PokemonBag.pbCanStore?(item)
        $PokemonBag.pbStoreItem(item)
      else
        raise _INTL("Couldn't return unused item to Bag somehow.")
      end
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
      #### YUMIL - 8 - NPC REACTION MOD - START  
      if @recorded == true
        $battleDataArray.last().playerUsedAnItem
      end
      #### YUMIL - 8 -NPC REACTION MOD - END 
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
    if @ultraBurst[side][owner]==idxPokemon
      @ultraBurst[side][owner]=-1
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
    #### YUMIL - 9 - NPC REACTION MOD - START
    if @recorded == true
      $battleDataArray.last().opponentUsedAnItem
    end
    #### YUMIL - 9 - NPC REACTION MOD - END
    itemname=PBItems.getName(item)
    if opponent && opponent.fullname
      if opponent.fullname.length < 30    #bennett and laura potion usage line break (their length = 35)
        pbDisplayBrief(_INTL("{1} used the\r\n{2}!",opponent.fullname,itemname))
      else
        pbDisplayBrief(_INTL("{1} used the\r{2}!",opponent.fullname,itemname))
      end
    end
    case item
    when PBItems::POTION
      battler.pbRecoverHP(20,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    when PBItems::SUPERPOTION
      battler.pbRecoverHP(60,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    when PBItems::HYPERPOTION
      battler.pbRecoverHP(120,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    when PBItems::ULTRAPOTION
      battler.pbRecoverHP(200,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    when PBItems::MOOMOOMILK
      battler.pbRecoverHP(100,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    when PBItems::STRAWBIC
      battler.pbRecoverHP(90,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    when PBItems::CHOCOLATEIC
      battler.pbRecoverHP(70,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    when PBItems::MAXPOTION
      battler.pbRecoverHP(battler.totalhp-battler.hp,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    when PBItems::FULLRESTORE
      fullhp=(battler.hp==battler.totalhp)
      battler.pbRecoverHP(battler.totalhp-battler.hp,true)
      battler.status=0; battler.statusCount=0
      battler.effects[PBEffects::Confusion]=0
      if fullhp
        pbDisplay(_INTL("{1} became healthy!",battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      end
    when PBItems::FULLHEAL
      battler.status=0; battler.statusCount=0
      battler.effects[PBEffects::Confusion]=0
      pbDisplay(_INTL("{1} became healthy!",battler.pbThis))
    when PBItems::MEDICINE
      battler.status=0; battler.statusCount=0
      battler.effects[PBEffects::Confusion]=0
      pbDisplay(_INTL("{1} became healthy!",battler.pbThis))
    when PBItems::XATTACK
      if battler.pbCanIncreaseStatStage?(PBStats::ATTACK)
        battler.pbIncreaseStat(PBStats::ATTACK,2)
      end
    when PBItems::XDEFEND
      if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE)
        battler.pbIncreaseStat(PBStats::DEFENSE,2)
      end
    when PBItems::XSPEED
      if battler.pbCanIncreaseStatStage?(PBStats::SPEED)
        battler.pbIncreaseStat(PBStats::SPEED,2)
      end
    when PBItems::XSPECIAL
      if battler.pbCanIncreaseStatStage?(PBStats::SPATK)
        battler.pbIncreaseStat(PBStats::SPATK,2)
      end
    when PBItems::XSPDEF
      if battler.pbCanIncreaseStatStage?(PBStats::SPDEF)
        battler.pbIncreaseStat(PBStats::SPDEF,2)
      end
    when PBItems::XACCURACY
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY)
        battler.pbIncreaseStat(PBStats::ACCURACY,2)
      end
    end
  end

################################################################################
# Fleeing from battle.
################################################################################
  def pbCanRun?(idxPokemon)
    return false if @opponent
    thispkmn=@battlers[idxPokemon]
    return true if thispkmn.hasWorkingItem(:SMOKEBALL)
    return true if thispkmn.hasWorkingItem(:MAGNETICLURE)
    return true if thispkmn.ability == PBAbilities::RUNAWAY
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
    if @opponent
      if $DEBUG && Input.press?(Input::CTRL)
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision=1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision=2
          return 1
        end
      elsif @internalbattle
        if pbDisplayConfirm(_INTL("Would you like to forfeit the battle?"))
          pbDisplay(_INTL("{1} forfeited the match!",self.pbPlayer.name))
          @decision=2
          return 1
        end
      elsif pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
        pbDisplay(_INTL("{1} forfeited the match!",self.pbPlayer.name))
        @decision=3
        return 1
      end
      return 0
    end
    if $DEBUG && Input.press?(Input::CTRL)
      pbSEPlay("escape",100)
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
      return 1
    end
    if @cantescape || $game_switches[:Never_Escape] == true
      pbDisplayPaused(_INTL("Can't escape!"))
      return 0
    end
    if thispkmn.pbHasType?(:GHOST)
      pbSEPlay("escape",100)
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
      return 1
    end
    if thispkmn.hasWorkingItem(:SMOKEBALL) || thispkmn.hasWorkingItem(:MAGNETICLURE) 
      if duringBattle
        pbSEPlay("escape",100)
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbSEPlay("escape",100)
        pbDisplayPaused(_INTL("{1} fled using its {2}!",thispkmn.pbThis,PBItems.getName(thispkmn.item)))
      end
      @decision=3
      return 1
    end
    if thispkmn.ability == PBAbilities::RUNAWAY
      if duringBattle
        pbSEPlay("escape",100)
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbSEPlay("escape",100)
        pbDisplayPaused(_INTL("{1} fled using Run Away!",thispkmn.pbThis))
      end
      @decision=3
      return 1
    end
    if !duringBattle && !pbCanSwitch?(idxPokemon,-1,false, running: true) # TODO: Use real messages
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
    if pbAIRandom(256)<rate
      pbSEPlay("escape",100)
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
    return false if $game_switches[:No_Mega_Evolution]
    return false if !@battlers[index].hasMega?
    return false if !pbHasMegaRing(index)
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    return false if @megaEvolution[side][owner]!=-1
    return true
  end

  def pbCanMegaEvolveAI?(i,index)
    return false if $game_switches[:No_Mega_Evolution]
    if i.class==PokeBattle_Battler
      return false if !i.pokemon.hasMegaForm?
    else
      return false if !i.hasMegaForm?
    end
    return false if !pbHasMegaRing(index)
    side=1
    owner=pbGetOwnerIndex(index)
    return false if @megaEvolution[side][owner]!=-1
    return true
  end


  def pbRegisterMegaEvolution(index)
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @megaEvolution[side][owner]=index
  end

  def pbMegaEvolve(index)
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasMega? rescue false)
    return if (@battlers[index].isMega? rescue true)
    ownername=pbGetOwner(index).fullname
    ownername=pbGetOwner(index).name if pbBelongsToPlayer?(index)
    if @battlers[index].item==PBItems::PULSEHOLD
      pbDisplay(_INTL("{1}'s {2} is reacting to the PULSE machine!", @battlers[index].pbThis, PBItems.getName(@battlers[index].item), ownername))
    elsif @battlers[index].species == PBSpecies::RAYQUAZA
      pbDisplay(_INTL("{1}'s fervent wish has reached {2}!", ownername, @battlers[index].pbThis))
    else
      pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!", @battlers[index].pbThis,PBItems.getName(@battlers[index].item), ownername,pbGetMegaRingName(index)))
    end
    if @battlers[index].item==PBItems::PULSEHOLD
      pbCommonAnimation("PulseEvolution",@battlers[index],nil)
    elsif @battlers[index].species == PBSpecies::RAYQUAZA
      pbCommonAnimation("MegaEvolutionRayquaza",@battlers[index],nil)
    else
      pbCommonAnimation("MegaEvolution",@battlers[index],nil)
    end
    @battlers[index].pokemon.makeMega
    @battlers[index].form=@battlers[index].pokemon.form
    @battlers[index].pbUpdate(true)
    @scene.pbChangePokemon(@battlers[index],@battlers[index].pokemon) if @battlers[index].effects[PBEffects::Substitute]==0
    meganame=@battlers[index].pokemon.megaName
    if !meganame || meganame==""
      meganame=_INTL("Mega {1}",PBSpecies.getName(@battlers[index].pokemon.species))
    end
    if @battlers[index].item==PBItems::PULSEHOLD
      pbDisplay(_INTL("{1} mutated into {2}!",@battlers[index].pbThis,meganame))
    else
      pbDisplay(_INTL("{1} Mega Evolved into {2}!",@battlers[index].pbThis,meganame))
    end
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @megaEvolution[side][owner]=-2

    @battlers[index].pbAbilitiesOnSwitchIn(true)
  end


################################################################################
# Ultra Burst battler.
################################################################################
  def pbCanUltraBurst?(index)
    return false if $game_switches[:No_Mega_Evolution]
    return false if !@battlers[index].hasUltra?
    return false if !pbHasZRing(index)
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    return false if @ultraBurst[side][owner]!=-1
    return true
  end

  def pbRegisterUltraBurst(index)
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @ultraBurst[side][owner]=index
  end

  def pbUltraBurst(index)
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasUltra? rescue false)
    return if (@battlers[index].isUltra? rescue true)
    @necrozmaVar = [@battlers[index].pokemonIndex,@battlers[index].form] if pbBelongsToPlayer?(index)
    ownername=pbGetOwner(index).fullname
    ownername=pbGetOwner(index).name if pbBelongsToPlayer?(index)
    pbDisplay(_INTL("Bright light is about to burst out of {1}!",
       @battlers[index].pbThis))
    pbCommonAnimation("UltraBurst",@battlers[index],nil)
    @battlers[index].pokemon.makeUltra
    @battlers[index].form=@battlers[index].pokemon.form
    @battlers[index].pbUpdate(true)
    @scene.pbChangePokemon(@battlers[index],@battlers[index].pokemon)
    ultraname=@battlers[index].pokemon.ultraName
    if !ultraname || ultraname==""
      ultraname=_INTL("Ultra {1}",PBSpecies.getName(@battlers[index].pokemon.species))
    end
    pbDisplay(_INTL("{1} regained its true power with Ultra Burst!",@battlers[index].pbThis))
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @ultraBurst[side][owner]=-2
    @battlers[index].pbAbilitiesOnSwitchIn(true)
  end


################################################################################
# Use Z-Move.
################################################################################
  def pbCanZMove?(index)
    return false if $game_switches[:No_Z_Move]
    return false if !@battlers[index].hasZMove?
    return false if !pbHasZRing(index)
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    return false if @zMove[side][owner]!=-1
    return true
  end

  def pbRegisterZMove(index)
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @zMove[side][owner]=index
  end

  def pbUseZMove(index,move,crystal)
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasZMove? rescue false)
    ownername=pbGetOwner(index).fullname
    ownername=pbGetOwner(index).name if pbBelongsToPlayer?(index)
    pbDisplay(_INTL("{1} surrounded itself with its Z-Power!",@battlers[index].pbThis))
    pbCommonAnimation("ZPower",@battlers[index],nil)
    PokeBattle_ZMoves.new(self,@battlers[index],move,crystal)
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
    elsif @battlers[index].status!=PBStatuses::SLEEP && @battlers[index].pbCanIncreaseStatStage?(PBStats::ACCURACY)
      @battlers[index].pbIncreaseStat(PBStats::ACCURACY,1)
    else
      pbDisplay(_INTL("But nothing happened!"))
    end
  end

################################################################################
# Gaining Experience.
################################################################################
  def pbGainEXP
    return if !@internalbattle || @disableExpGain
    #Find who died and get their base EXP & level
    for i in 0...4 # Not ordered by priority
      if !@doublebattle && pbIsDoubleBattler?(i)
        @battlers[i].participants=[]
        next
      end
      next unless (pbIsOpposing?(i) && @battlers[i].participants.length>0 && (@battlers[i].isFainted? || @decision == 4))
      battlerSpecies=@battlers[i].pokemon.species
      baseexp=@battlers[i].baseExp
      level=@battlers[i].level
      mon_order = [] #order that the mons should be given EXP in
      #find who fought
      partic=0
      for j in @battlers[i].participants
        next if !@party1[j] || !pbIsOwner?(0,j) || @party1[j].isEgg?
        next if @party1[j].hp<=0 && ($game_switches[:Exp_All_On] == false || $game_switches[:Exp_All_Upgrade] == false)
        partic+=1
        mon_order.push(j)
      end
      next if partic==0 && !($game_switches[:Exp_All_On] == false || $game_switches[:Exp_All_Upgrade] == false)

      #push the rest of the party on that array
      for j in 0...@party1.length
        next if !@party1[j] || !pbIsOwner?(0,j) || @party1[j].isEgg?
        next if @party1[j].hp<=0 && ($game_switches[:Exp_All_On] == false || $game_switches[:Exp_All_Upgrade] == false)
        mon_order.push(j) if !mon_order.include?(j)
      end

      #get the base participant EXP
      partic = 1 if partic==0
      partic_exp=(level*baseexp/partic).floor
      partic_exp=(partic_exp*3/2).floor if @opponent

      #distribute EXP to each mon in the party
      messageskip = false
      for j in mon_order
        thispoke=@party1[j]

        #pokemon information for messages
        hasEXPshare = (thispoke.item == PBItems::EXPSHARE || thispoke.itemInitial == PBItems::EXPSHARE)
        boostedEXP = ((thispoke.trainerID != self.pbPlayer.id && thispoke.trainerID != 0) || (thispoke.language!=0 && thispoke.language!=self.pbPlayer.language))
        mon_fought = @battlers[i].participants.include?(j)

        #did this mon fight?
        if mon_fought
          exp = partic_exp
        elsif hasEXPshare || $game_switches[:Exp_All_On] #didn't participate- has EXP Share or EXP All is on
          exp = (partic_exp/3).floor #reduced
          exp = (partic_exp/2).floor if $game_switches[:Exp_All_Upgrade] == true
        else #does not get EXP
          next
        end

        #Gain effort value points, using RS effort values
        pbGainEvs(thispoke,i) if mon_fought || hasEXPshare
        
        #reborn-added EXP booster: 8% per level over 100
        exp*=(1+((thispoke.poklevel-100)*0.08)) if thispoke.poklevel>100
        if USENEWEXPFORMULA   # Use new (Gen 5) Exp. formula
          leveladjust=((2*level+10.0)/(level+thispoke.level+10.0))**2.5
          exp=(exp*leveladjust/5).floor
        else                  # Use old (Gen 1-4) Exp. formula
          exp=(exp/7).floor
        end

        #Trade EXP; different language EXP
        if boostedEXP
          exp*= (thispoke.language!=0 && thispoke.language!=self.pbPlayer.language) ? 1.7 : 1.5
        end
        exp=(exp*3/2).floor if (thispoke.item == PBItems::LUCKYEGG) || (thispoke.itemInitial == PBItems::LUCKYEGG)
        exp=[1,exp.floor].max

        #We have the EXP that this mon can gain.
        growthrate=thispoke.growthrate
        if $game_switches[:Hard_Level_Cap] || $game_switches[:Exp_All_On] # Rejuv-style Level Cap
          badgenum = pbPlayer.numbadges
          if thispoke.level>=LEVELCAPS[badgenum]
            exp = 0
          elsif thispoke.level<LEVELCAPS[badgenum]
            totalExpNeeded = PBExperience.pbGetStartExperience(LEVELCAPS[badgenum], growthrate)
            currExpNeeded = totalExpNeeded - thispoke.exp
            exp = [currExpNeeded,exp].min
          end
        end
        newexp=PBExperience.pbAddExperience(thispoke.exp,exp,growthrate)
        exp=newexp-thispoke.exp
        exp = 0 if $game_switches[:No_EXP_Gain]
        next if exp <= 0
        if mon_fought || (hasEXPshare && !$game_switches[:Exp_All_On])
          #EXP All text is handled at the end
          if boostedEXP || thispoke.item == PBItems::LUCKYEGG
            pbDisplay(_INTL("{1} gained a boosted {2} Exp. Points!",thispoke.name,exp))
          else
            pbDisplay(_INTL("{1} gained {2} Exp. Points!",thispoke.name,exp))
          end
        elsif $game_switches[:Exp_All_On]
          pbDisplay(_INTL("The rest of your team gained Exp. Points thanks to the Exp. All!")) if !messageskip
          messageskip = true
        end
        
        #actually add the EXP
        newlevel=PBExperience.pbGetLevelFromExperience(newexp,growthrate)
        oldlevel=thispoke.level
        if thispoke.respond_to?("isShadow?") && thispoke.isShadow?
          thispoke.exp+=exp
          next
        end

        # Find battler
        battler=pbFindPlayerBattler(j)
        curlevel = oldlevel
        oldtotalhp=thispoke.totalhp
        oldattack=thispoke.attack
        olddefense=thispoke.defense
        oldspeed=thispoke.speed
        oldspatk=thispoke.spatk
        oldspdef=thispoke.spdef
        tempexp1=thispoke.exp
        loop do
          #EXP Bar animation
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
          if battler && battler.pokemon && @internalbattle
            battler.pokemon.changeHappiness("level up")
          elsif ((thispoke.item == PBItems::EXPSHARE) || $game_switches[:Exp_All_On])
            thispoke.changeHappiness("level up")
          end
        end
        next if newlevel<=oldlevel
        #leveled up!
        thispoke.calcStats
        battler.pbUpdate(false) if battler
        @scene.pbRefresh
        pbDisplayPaused(_INTL("{1} grew to Level {2}!",thispoke.name,newlevel))
        @scene.pbLevelUp(thispoke,battler,oldtotalhp,oldattack,olddefense,oldspeed,oldspatk,oldspdef)
        # Finding all moves learned at this level
        movelist=thispoke.getMoveList
        for lvl in oldlevel+1..newlevel
          for k in movelist
            if k[0]==lvl   # Learned a new move
              pbLearnMove(j,k[1])
            end
          end
        end
        #evolve if able to
        newspecies=pbCheckEvolution(thispoke)
        next if newspecies<=0
        pbFadeOutInWithMusic(99999){
          evo=PokemonEvolutionScene.new
          evo.pbStartScreen(thispoke,newspecies)
          evo.pbEvolution
          evo.pbEndScreen
          $game_map.autoplayAsCue
          if battler
            @scene.pbChangePokemon(@battlers[battler.index],@battlers[battler.index].pokemon)
            battler.pbUpdate(true)
            @scene.sprites["battlebox#{battler.index}"].refresh
            battler.name=thispoke.name
            for ii in 0...4
              battler.moves[ii]=PokeBattle_Move.pbFromPBMove(self,thispoke.moves[ii],battler)
            end
          end
        }
      end
      # Now clear the participants array
      @battlers[i].participants=[]
    end
  end

  def pbGainEvs(thispoke,i)
    #Gain effort value points, using RS effort values
    totalev=0
    for k in 0..5
      totalev+=thispoke.ev[k]
    end
    # Original species, not current species
    evyield=@battlers[i].evYield
    for k in 0..5
      evgain=evyield[k]
      evgain*=8 if (thispoke.item == PBItems::MACHOBRACE) || (thispoke.itemInitial == PBItems::MACHOBRACE)
      evgain=0 if [PBItems::POWERWEIGHT, PBItems::POWERBRACER,PBItems::POWERBELT,PBItems::POWERANKLET,PBItems::POWERLENS,PBItems::POWERBAND].include?(thispoke.item)
      case k
        when 0 then evgain+=32 if (thispoke.item == PBItems::POWERWEIGHT)
        when 1 then evgain+=32 if (thispoke.item == PBItems::POWERBRACER)
        when 2 then evgain+=32 if (thispoke.item == PBItems::POWERBELT)
        when 3 then evgain+=32 if (thispoke.item == PBItems::POWERANKLET)
        when 4 then evgain+=32 if (thispoke.item == PBItems::POWERLENS)
        when 5 then evgain+=32 if (thispoke.item == PBItems::POWERBAND)
      end
      evgain*=4 if thispoke.pokerusStage>=1 # Infected or cured
      evgain = 0 if $game_switches[:Stop_Ev_Gain] == true
      if evgain>0
        # Can't exceed overall limit
        evgain-=totalev+evgain-510 if totalev+evgain>510 && !$game_switches[:No_Total_EV_Cap]
        # Can't exceed stat limit
        evgain-=thispoke.ev[k]+evgain-252 if thispoke.ev[k]+evgain>252
        # Add EV gain
        thispoke.ev[k]+=evgain
        if thispoke.ev[k]>252
          print "Single-stat EV limit 252 exceeded.\r\nStat: #{k}  EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
          thispoke.ev[k]=252
        end
        totalev+=evgain
        if totalev>510 && !$game_switches[:No_Total_EV_Cap]
          print "EV limit 510 exceeded.\r\nTotal EVs: #{totalev} EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
        end
      end
    end
    battler = @battlers.find {|battler| battler.pokemon == thispoke}
    battler.pbUpdate if battler
    @scene.sprites["battlebox#{battler.index}"].refresh if battler
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
      checkdupe = pokemon.moves[i].id
      if checkdupe==move
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
      @amuletcoin=true if !pbIsOpposing?(i) && ((@battlers[i].item == PBItems::AMULETCOIN) || (@battlers[i].item == PBItems::LUCKINCENSE))
    end
    for i in 0...4
      if !@battlers[i].isFainted?
        if @battlers[i].isShadow? && pbIsOpposing?(i)
          pbCommonAnimation("Shadow",@battlers[i],nil)
          pbDisplay(_INTL("Oh!\nA Shadow Pokemon!"))
        end
      end
    end
    # Weather-inducing abilities, Trace, Imposter, etc.
    @usepriority=false
    priority=pbPriority
    for i in priority
      pbOnActiveOne(i)  # might cause weird ability behaviour on first turn
      i.pbAbilitiesOnSwitchIn(true)
    end
    # Check forms are correct
    for i in 0...4
      next if @battlers[i].isFainted?
      @battlers[i].pbCheckForm
    end
    pbJudge
  end

  def pbOnActiveOne(pkmn,onlyabilities=false)
    return false if pkmn.isFainted?
    if !onlyabilities
      for i in 0...4 # Currently unfainted participants will earn EXP even if they faint afterwards
        @battlers[i].pbUpdateParticipants if pbIsOpposing?(i)
        @amuletcoin=true if !pbIsOpposing?(i) && ((@battlers[i].item == PBItems::AMULETCOIN) || (@battlers[i].item == PBItems::LUCKINCENSE))
      end
      # Chess Field piece boosts
      if @field.effect == PBFields::CHESSB
        case pkmn.pokemon.piece
        when :PAWN
          pbDisplay(_INTL("{1} became a Pawn and stormed up the board!",pkmn.pbThis))
        when :KING
          pbDisplay(_INTL("{1} became a King and exposed itself!",pkmn.pbThis))
        when :KNIGHT
          pbDisplay(_INTL("{1} became a Knight and readied its position!",pkmn.pbThis)) #oo they shmovin' but i gotta change this im sry
        when :BISHOP
          pbDisplay(_INTL("{1} became a Bishop and took the diagonal!",pkmn.pbThis))
          if pkmn.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
            pkmn.pbIncreaseStat(PBStats::ATTACK,1)
          end
          if pkmn.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
            pkmn.pbIncreaseStat(PBStats::SPATK,1)
          end
        when :ROOK
          pbDisplay(_INTL("{1} became a Rook and took the open file!",pkmn.pbThis))
          if pkmn.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
            pkmn.pbIncreaseStat(PBStats::DEFENSE,1)
          end
          if pkmn.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
            pkmn.pbIncreaseStat(PBStats::SPDEF,1)
          end
        when :QUEEN
          pbDisplay(_INTL("{1} became a Queen and was placed on the center of the board!",pkmn.pbThis))
          if pkmn.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
            pkmn.pbIncreaseStat(PBStats::DEFENSE,1)
          end
          if pkmn.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
            pkmn.pbIncreaseStat(PBStats::SPDEF,1)
          end
          
        end
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
        if @field.effect == PBFields::FAIRYTALEF || @field.effect == PBFields::STARLIGHTA
          pkmn.pbIncreaseStat(PBStats::ATTACK, 1)
          pkmn.pbIncreaseStat(PBStats::SPATK, 1)
        end
        pbDisplay(_INTL("The healing wish came true for {1}!",pkmn.pbThis(true)))
        pkmn.effects[PBEffects::HealingWish]=false
      end
      # Lunar Dance
      if pkmn.effects[PBEffects::LunarDance]
        pkmn.pbRecoverHP(pkmn.totalhp,true)
        pkmn.status=0
        pkmn.statusCount=0
        if @field.effect == PBFields::STARLIGHTA || @field.effect == PBFields::NEWW
          stats = [PBStats::ATTACK,PBStats::SPATK] if @field.effect == PBFields::STARLIGHTA
          stats = *(1..5) if @field.effect == PBFields::NEWW
          for stat in stats
            pkmn.pbIncreaseStat(stat, 1)
          end
        end
        for i in 0...4
          pkmn.moves[i].pp=pkmn.moves[i].totalpp
        end
        pbDisplay(_INTL("{1} became cloaked in mystical moonlight!",pkmn.pbThis))
        pkmn.effects[PBEffects::LunarDance]=false
      end
      # Z-Memento/Parting Shot
      if pkmn.effects[PBEffects::ZHeal]
        pkmn.pbRecoverHP(pkmn.totalhp,false)
        pbDisplay(_INTL("The Z-Power healed {1}!",pkmn.pbThis(true)))
        pkmn.effects[PBEffects::ZHeal]=false
      end
      # Spikes
      pkmn.pbOwnSide.effects[PBEffects::Spikes]=0 if @field.effect == PBFields::WATERS || @field.effect == PBFields::MURKWATERS
      if pkmn.pbOwnSide.effects[PBEffects::Spikes]>0
        if !pkmn.isAirborne? && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
          if pkmn.ability != PBAbilities::MAGICGUARD
            spikesdiv=[8,8,6,4][pkmn.pbOwnSide.effects[PBEffects::Spikes]]
            @scene.pbDamageAnimation(pkmn,0)
            pkmn.pbReduceHP([(pkmn.totalhp.to_f/spikesdiv).floor,1].max)
            pbDisplay(_INTL("{1} was hurt by Spikes!",pkmn.pbThis))
          end
        end
      end
      if pkmn.isFainted?
        pkmn.pbFaint
        pkmn.pbOwnSide.effects[PBEffects::Retaliate] = true
        if !@midturn
          pbGainEXP
          10.times do
            pbSwitch(false)
          end
          return if @decision>0
          priority=pbPriority
          for i in priority
            next if i.isFainted?
            i.pbAbilitiesOnSwitchIn(false)
          end
        else
          pbJudge
          return if @decision>0
        end
        return
      end
      # Stealth Rock
      if pkmn.pbOwnSide.effects[PBEffects::StealthRock]
        if pkmn.ability != PBAbilities::MAGICGUARD && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
          atype = PBTypes::ROCK
          atype = @field.getRoll if @field.effect == PBFields::CRYSTALC
          eff=PBTypes.getCombinedEffectiveness(atype,pkmn.type1,pkmn.type2)
          if @field.effect == PBFields::INVERSEF
            switcheff = { 16 => 1, 8 => 2, 4 => 4, 2 => 8, 1 => 16, 0 => 16}
            eff = switcheff[eff]
          end
          if eff>0
            if @field.effect == PBFields::ROCKYF || @field.effect == PBFields::CAVE
              eff = eff*2
            end
            @scene.pbDamageAnimation(pkmn,0)
            pkmn.pbReduceHP([(pkmn.totalhp*eff/32).floor,1].max)
            if @field.effect == PBFields::CRYSTALC
              pbDisplay(_INTL("{1} was hurt by the crystalized stealth rocks!",pkmn.pbThis))
            else
              pbDisplay(_INTL("{1} was hurt by Stealth Rocks!",pkmn.pbThis))
            end
          end
        end
      end
      if pkmn.isFainted?
        pkmn.pbFaint
        pkmn.pbOwnSide.effects[PBEffects::Retaliate] = true
        if !@midturn
          pbGainEXP
          10.times do
            pbSwitch(false)
          end
          return if @decision>0
          priority=pbPriority
          for i in priority
            next if i.isFainted?
            i.pbAbilitiesOnSwitchIn(false)
          end
        else
          pbJudge
          return if @decision>0
        end
        return
      end
      # Corrosive Field Entry
      if @field.effect == PBFields::CORROSIVEF
        if !(pkmn.ability == PBAbilities::MAGICGUARD || pkmn.ability == PBAbilities::POISONHEAL || pkmn.ability == PBAbilities::IMMUNITY || pkmn.ability == PBAbilities::WONDERGUARD || 
            pkmn.ability == PBAbilities::TOXICBOOST) && !pkmn.isAirborne? && !pkmn.pbHasType?(:POISON) && !pkmn.pbHasType?(:STEEL)
          atype = PBTypes::POISON
          eff=PBTypes.getCombinedEffectiveness(atype,pkmn.type1,pkmn.type2)
          if eff>0
            eff=eff*2
            @scene.pbDamageAnimation(pkmn,0)
            pkmn.pbReduceHP([(pkmn.totalhp*eff/32).floor,1].max)
            pbDisplay(_INTL("{1} was seared by the corrosion!",pkmn.pbThis))
          end
        end
      end
      if pkmn.isFainted?
        pkmn.pbFaint
        pkmn.pbOwnSide.effects[PBEffects::Retaliate] = true
        if !@midturn
          pbGainEXP
          10.times do
            pbSwitch(false)
          end
          return if @decision>0
          priority=pbPriority
          for i in priority
            next if i.isFainted?
            i.pbAbilitiesOnSwitchIn(false)
          end
        else
          pbJudge
          return if @decision>0
        end
        return
      end
      # Sticky Web
      if pkmn.pbOwnSide.effects[PBEffects::StickyWeb]
        if !pkmn.isAirborne? && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
          stat = @field.effect == PBFields::FORESTF ? 2 : 1
          pbDisplay(_INTL("{1} was caught in a sticky web!",pkmn.pbThis))
          pkmn.pbReduceStat(PBStats::SPEED, stat)
        end
      end
      # Toxic Spikes
      pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]=0 if @field.effect == 21 || @field.effect == 26
      if pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 && !pkmn.isAirborne?
        if pkmn.pbHasType?(:POISON) && @field.effect != 10
          pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
          pbDisplay(_INTL("{1} absorbed the poison spikes!",pkmn.pbThis))
        elsif pkmn.pbCanPoisonSpikes?(true) && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
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
    pkmn.pbAbilityCureCheck
    if !onlyabilities
      pkmn.pbCheckForm
      pkmn.pbBerryCureCheck
    end
    #Emergency exit caused by taking damage
    if pkmn.userSwitch == true
      pkmn.userSwitch = false
      pbDisplay(_INTL("{1} went back to {2}!",pkmn.pbThis,pbGetOwner(pkmn.index).name))
      newpoke=0
      newpoke=pbSwitchInBetween(pkmn.index,true,false)
      pbMessagesOnReplace(pkmn.index,newpoke)
      pkmn.vanished=false
      pkmn.pbResetForm
      pbReplace(pkmn.index,newpoke,false)
      pbOnActiveOne(pkmn)
      pkmn.pbAbilitiesOnSwitchIn(true)
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

  def pbAnimation(moveid,attacker,opponent,hitnum=0)
    if @battlescene || moveid==PBMoves::SUBSTITUTE
      @scene.pbAnimation(moveid,attacker,opponent,hitnum)
    end
  end

  def pbCommonAnimation(name,attacker=nil,opponent=nil,hitnum=0)
    if @battlescene
      @scene.pbCommonAnimation(name,attacker,opponent,hitnum)
    end
  end

  def pbChangeBGSprite
    filename = @field.backdrop
    if @field.effect != PBFields::FLOWERGARDENF
      path = "Graphics/Battlebacks/battlebg" + filename + ".png"
      pbApplySceneBG("battlebg",path)
      path = "Graphics/Battlebacks/playerbase" + filename + ".png"
      pbApplySceneBG("playerbase",path)
      path = "Graphics/Battlebacks/enemybase" + filename + ".png"
      pbApplySceneBG("enemybase",path)
    else
      path = "Graphics/Battlebacks/battlebg" + "FlowerGarden" + @field.counter.to_s + ".png"
      pbApplySceneBG("battlebg",path)
      path = "Graphics/Battlebacks/playerbase" + "FlowerGarden" + @field.counter.to_s + ".png"
      pbApplySceneBG("playerbase",path)
      path = "Graphics/Battlebacks/enemybase" + "FlowerGarden" + @field.counter.to_s + ".png"
      pbApplySceneBG("enemybase",path)
    end
  end

################################################################################
# Battle core.
################################################################################
  def pbStartBattle(canlose=false)
    # THIS IS JUST FOR TESTING DEBUG LOGS
    # TURNING THE INTERNAL SWITCH ON
    # GET RID OF THIS LATER, IT MAY CAUSE LAG
    # turn back on for next wave of testing
    #begin
      pbStartBattleCore(canlose)
    #rescue Exception
    #  @decision=0
    #  @scene.pbEndBattle(@decision)
    #end
    return @decision
  end

  def pbStartBattleCore(canlose)
    $game_temp_battle = self
    if !@fullparty1 && @party1.length>MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 1 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@fullparty2 && @party2.length>MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 2 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    #========================
    # Initialize AI in battle 
    #========================
    if !isOnline?
      @ai = PokeBattle_AI.new(self) 
      $ai_log_data = [PokeBattle_AI_Info.new,PokeBattle_AI_Info.new,PokeBattle_AI_Info.new,PokeBattle_AI_Info.new]
    end
    if !@opponent
      #========================
      # Initialize wild Pokémon
      #========================
      if @party2.length==1
        wildpoke=@party2[0]
        @battlers[1].pbInitialize(wildpoke,0,false)
        @peer.pbOnEnteringBattle(self,wildpoke)
        pbSetSeen(wildpoke)
        @scene.pbStartBattle(self)
        pbDisplayPaused(_INTL("Wild {1} appeared!",wildpoke.name))
      elsif @party2.length==2
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
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[0].fullname,PBSpecies.getName(@battlers[1].species))) 
        pbSendOut(1,@party2[sendout1])
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[1].fullname,PBSpecies.getName(@battlers[3].species))) 
        pbSendOut(3,@party2[sendout2])
      else
        pbDisplayBrief(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        if sendout1<0 || sendout2<0
          raise _INTL("Opponent doesn't have two unfainted Pokémon")
        end
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false) 
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbDisplayBrief(_INTL("{1} sent\r\nout {2} and {3}!", @opponent.fullname,PBSpecies.getName(@battlers[1].species),PBSpecies.getName(@battlers[3].species))) 
        pbSendOut(1,@party2[sendout1])
        pbSendOut(3,@party2[sendout2])
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

      @battlers[1].pbInitialize(trainerpoke,sendout,false) 
      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent.fullname,PBSpecies.getName(@battlers[1].species)))

      pbSendOut(1,trainerpoke)
    end
    #=====================================
    # Initialize players in double battles
    #=====================================
    if @doublebattle
      if @player.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
        raise _INTL("Player 1 has no unfainted Pokémon") if sendout1<0
        sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
        raise _INTL("Player 2 has no unfainted Pokémon") if sendout2<0
        @battlers[0].pbInitialize(@party1[sendout1],sendout1,false) 
        @battlers[2].pbInitialize(@party1[sendout2],sendout2,false)
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}! Go! {3}!", @player[1].fullname,@battlers[2].name,@battlers[0].name))
        pbSetSeen(@party1[sendout1])
        pbSetSeen(@party1[sendout2])
      else
        sendout1=pbFindNextUnfainted(@party1,0)
        sendout2=pbFindNextUnfainted(@party1,sendout1+1)
        @battlers[0].pbInitialize(@party1[sendout1],sendout1,false) 
        @battlers[2].pbInitialize(@party1[sendout2],sendout2,false) unless sendout2==-1
        if sendout2>-1
          pbDisplayBrief(_INTL("Go! {1} and {2}!",@battlers[0].name,@battlers[2].name)) 
        else
          pbDisplayBrief(_INTL("Go! {1}!",@battlers[0].name)) 
        end
      end
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
      @battlers[0].pbInitialize(playerpoke,sendout,false) 
      pbDisplayBrief(_INTL("Go! {1}!",@battlers[0].name))
      pbSendOut(0,playerpoke)
    end
    #=======================================================
    # Keep track of who fainted in battle + piece assignment
    #=======================================================
    @fainted_mons = Array.new($Trainer.party.length) {|i| $Trainer.party[i].hp > 0 ? false : true}
    if @doublebattle
      if @player.is_a?(Array)
        pieceAssignment(pbPartySingleOwner(0),true)
        pieceAssignment(pbPartySingleOwner(2),true)
      else
        pieceAssignment(@party1,false)
      end
      if @opponent.is_a?(Array)
        pieceAssignment(pbPartySingleOwner(1),true)
        pieceAssignment(pbPartySingleOwner(3),true)
      else
        pieceAssignment(@party2,false)
      end
    else
      pieceAssignment(@party1,false)
      pieceAssignment(@party2,false)
    end
    
    #==================
    # Initialize battle
    #==================
    if @weather==PBWeather::SUNNYDAY
      pbCommonAnimation("Sunny")
      pbDisplay(_INTL("The sunlight is strong."))
    elsif @weather==PBWeather::RAINDANCE
      pbCommonAnimation("Rain")
      pbDisplay(_INTL("It is raining."))
    elsif @weather==PBWeather::SANDSTORM
      pbCommonAnimation("Sandstorm")
      pbDisplay(_INTL("A sandstorm is raging."))
    elsif @weather==PBWeather::HAIL
      pbCommonAnimation("Hail")
      pbDisplay(_INTL("Hail is falling."))
    elsif @weather==PBWeather::STRONGWINDS
      pbCommonAnimation("Wind")
      pbDisplay(_INTL("The wind is strong."))
    end
    # Field Effects BEGIN UPDATE
    if @field.introMessage
      fieldmessage = @field.introMessage
      if fieldmessage.kind_of?(Array)
        pbDisplay(_INTL(fieldmessage[0]))
        pbDisplay(_INTL(fieldmessage[1]))
      else
        pbDisplay(_INTL(fieldmessage))
      end
      $game_variables[:Cave_Collapse] = 0
    end
    # END OF UPDATE
    priority=pbPriority
    for i in priority # Pre-surge seed check
      seedCheck
    end
    pbOnActiveAll   # Abilities
    for i in priority # Post-surge seed check
      seedCheck
    end
    @turncount=1
    if !isOnline? #for subclassing- online processing continues separately
      loop do   # Now begin the battle loop
        break if @decision>0
        PBDebug.log("************************** Round #{@turncount} *******************************") if $INTERNAL
        if @debug && @turncount>=101
          @decision=pbDecisionOnTime()
          PBDebug.log("***[Undecided after 100 rounds]")
          pbAbort
          break
        end

        PBDebug.logonerr{
          pbCommandPhase
        }
        break if @decision>0

        PBDebug.logonerr{
          @midturn=true
          pbAttackPhase()
          @midturn=false
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
    pbAceMessage() if @ace_message && !@ace_message_handled && Reborn
    @scene.pbBeginCommandPhase
    @scene.pbResetCommandIndices if $idk[:settings].remember_commands==0 
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
    for i in 0..3
      @switchedOut[i] = false
    end
    # Reset choices to perform Mega Evolution/Z-Moves/Ultra Burst if it wasn't done somehow
    for i in 0...@megaEvolution[0].length
      @megaEvolution[0][i]=-1 if @megaEvolution[0][i]>=0
    end
    for i in 0...@megaEvolution[1].length
      @megaEvolution[1][i]=-1 if @megaEvolution[1][i]>=0
    end
    for i in 0...@ultraBurst[0].length
      @ultraBurst[0][i]=-1 if @ultraBurst[0][i]>=0
    end
    for i in 0...@ultraBurst[1].length
      @ultraBurst[1][i]=-1 if @ultraBurst[1][i]>=0
    end
    for i in 0...@zMove[0].length
      @zMove[0][i]=-1 if @zMove[0][i]>=0
    end
    for i in 0...@zMove[1].length
      @zMove[1][i]=-1 if @zMove[1][i]>=0
    end
    pbJudge #juuuust in case we don't want to be here
    return if @decision>0
    @commandphase=true
    for i in 0...4
      break if @decision!=0
      next if @choices[i][0]!=0
      #AI CHANGES
      if !pbOwnedByPlayer?(i) || @controlPlayer
        next
      end
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
                  if @ultraBurst[side][owner]==i
                    @ultraBurst[side][owner]=-1
                  end
                  if @zMove[side][owner]==i
                    @zMove[side][owner]=-1
                  end
                  break
                end
                if !pbRegisterMove(i,index)
                  @zMove[0][0]=-1 if @zMove[0][0]>=0
                  @zMove[1][0]=-1 if @zMove[1][0]>=0
                  next
                end
                if @doublebattle
                  thismove=@battlers[i].moves[index]
                  target=@battlers[i].pbTarget(thismove)
                  if target==PBTargets::SingleNonUser # single non-user
                    target=@scene.pbChooseTarget(i)
                    if target<0
                      @zMove[0][0]=-1 if @zMove[0][0]>=0
                      @zMove[1][0]=-1 if @zMove[1][0]>=0
                      next
                    end
                    pbRegisterTarget(i,target)
                  elsif target==PBTargets::UserOrPartner # Acupressure
                    target=@scene.pbChooseTargetAcupressure(i)
                    if target<0 || (target&1)!=(i&1)
                      @zMove[0][0]=-1 if @zMove[0][0]>=0
                      @zMove[1][0]=-1 if @zMove[1][0]>=0
                      next
                    end
                    pbRegisterTarget(i,target)
                  end
                end
                commandDone=true
              end
            else
              commandDone=pbAutoChooseMove(i)
            end
          elsif cmd==1 # Bag
            if !@internalbattle
              if pbOwnedByPlayer?(i)
                pbDisplay(_INTL("Items can't be used here."))
              end
            elsif @battlers[i].effects[PBEffects::SkyDrop]
              pbDisplay(_INTL("Sky Drop won't let {1} go!",@battlers[i].name))
            else
              item=pbItemMenu(i)
              if item[0]>0
                if pbRegisterItem(i,item[0],item[1])
                  commandDone=true
                end
              end
            end
          elsif cmd==2 # Pokémon
            pkmn=pbSwitchPlayer(i,false,true)
            if pkmn>=0
              commandDone=true if pbRegisterSwitch(i,pkmn)
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
              if @ultraBurst[side][owner]==i
                @ultraBurst[side][owner]=-1
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
            if @ultraBurst[side][owner]==i
              @ultraBurst[side][owner]=-1
            end
            if @zMove[side][owner]==i
              @zMove[side][owner]=-1
            end
            commandDone=true
          elsif cmd==-1   # Go back to first battler's choice
            @megaEvolution[0][0]=-1 if @megaEvolution[0][0]>=0
            @megaEvolution[1][0]=-1 if @megaEvolution[1][0]>=0
            @ultraBurst[0][0]=-1 if @ultraBurst[0][0]>=0
            @ultraBurst[1][0]=-1 if @ultraBurst[1][0]>=0
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
    @scene.pbChooseEnemyCommand if !isOnline?
    #AI Data collection perry
    for i in 0...4
      $ai_log_data[i].logAIScorings() if !isOnline? && @battlers[i].hp > 0 && !pbOwnedByPlayer?(i)
    end
    @commandphase=false
  end

################################################################################
# Attack phase.
################################################################################
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    for i in 0...4
      @successStates[i].clear
      if @choices[i][0]!=1 && @choices[i][0]!=2
        #@battlers[i].effects[PBEffects::DestinyBond]=false # Effect gets removed on move use, NOT move choice
        @battlers[i].effects[PBEffects::Grudge]=false
      end
      @battlers[i].turncount+=1 if !@battlers[i].isFainted?
      @battlers[i].turncount+=1 if !@battlers[i].isFainted? && @battlers[i].ability==PBAbilities::SLOWSTART && @field.effect==PBFields::ELECTRICT
      @battlers[i].effects[PBEffects::Rage]=false if !pbChoseMove?(i,:RAGE)
      #@battlers[i].pbCustapBerry # Moved to later, timing was incorrect here
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
        for j in priority
          next if !i.pbIsOpposing?(j.index)
          # if Pursuit and this target ("i") was chosen
          if pbChoseMoveFunctionCode?(j.index,0x88) && !j.effects[PBEffects::Pursuit] && (@choices[j.index][3]==-1 || @choices[j.index][3]==i.index)
            newpoke=pbPursuitInterrupt(j,i)
            return if @decision>0
          end
          break if i.isFainted?
        end
        if defined?(newpoke) && !newpoke.nil?
          index=newpoke
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
          usetype=$cache.items[item][ITEMBATTLEUSE]
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
    # Ultra Burst
    for i in priority
      next if @choices[i.index][0]!=1
      side=(pbIsOpposing?(i.index)) ? 1 : 0
      owner=pbGetOwnerIndex(i.index)
      if @ultraBurst[side][owner]==i.index
        pbUltraBurst(i.index)
      end
    end
    priority=pbPriority(false,true)    #Turn order recalc from Gen VII
    if @state.effects[PBEffects::WonderRoom] > 0
      for i in @battlers
        i.pbSwapDefenses if !i.wonderroom
      end
    end

    # move animations before main move processing
    for i in priority
      if pbChoseMoveFunctionCode?(i.index,0x115) # Focus Punch
        pbCommonAnimation("FocusPunch",i,nil)
        pbDisplay(_INTL("{1} is tightening its focus!",i.pbThis))
      elsif pbChoseMoveFunctionCode?(i.index,0x15D) # Beak Blast
        pbCommonAnimation("BeakBlast",i,nil)
        i.effects[PBEffects::BeakBlast]=true
        pbDisplay(_INTL("{1} is heating up!",i.pbThis))
      elsif pbChoseMoveFunctionCode?(i.index,0x16B) # Shell Trap
        pbCommonAnimation("ShellTrap",i,nil)
        i.effects[PBEffects::ShellTrap]=true
        pbDisplay(_INTL("{1} set a shell trap!",i.pbThis))
      end
    end

    # Use attacks
    for i in priority
      i.pbProcessTurn(@choices[i.index])
      if i.effects[PBEffects::Round] && @doublebattle
        pbMoveAfter(i, i.pbPartner)
      end

      # Shell Trap
      for ii in 0...4
        if !@battlers[ii].effects[PBEffects::ShellTrapTarget].nil? && @battlers[ii].effects[PBEffects::ShellTrapTarget] != -1 &&
           @battlers[ii].effects[PBEffects::ShellTrap]==false 
          if pbChoseMoveFunctionCode?(ii,0x16B)
            pbMoveAfter(i, @battlers[ii])
            @battlers[ii].effects[PBEffects::ShellTrapTarget]=-1
          else # Via seed
            target=@battlers[ii].effects[PBEffects::ShellTrapTarget]
            @battlers[ii].pbUseMoveSimple(PBMoves::SHELLTRAP,-1,target,false)
            @battlers[ii].effects[PBEffects::ShellTrapTarget]=-1
          end
        end
      end

      return if @decision>0
    end
  end

  def pbPursuitInterrupt(pursuiter,switcher)
    newpoke=nil
    if pursuiter.status != PBStatuses::SLEEP && pursuiter.status != PBStatuses::FROZEN && !pursuiter.effects[PBEffects::Truant]
      @switching=true
      #Try to Mega-evolve/Ultra-burst before using pursuit
      side=(pbIsOpposing?(pursuiter.index)) ? 1 : 0
      owner=pbGetOwnerIndex(pursuiter.index)
      if @megaEvolution[side][owner]==pursuiter.index
        pbMegaEvolve(pursuiter.index)
      end
      if @ultraBurst[side][owner]==pursuiter.index
        pbUltraBurst(pursuiter.index)
      end
      pursuiter.pbUseMove(@choices[pursuiter.index])
      pursuiter.effects[PBEffects::Pursuit]=true
      
      if pbOwnedByPlayer?(switcher.index) && switcher.isFainted?
        newpoke=pbSwitchPlayer(switcher.index,false,false)
      end
      @switching=false
    end
    return newpoke
  end


################################################################################
# End of round.
################################################################################
  def pbEndOfRoundPhase
    for i in 0...4
      if @battlers[i].effects[PBEffects::ShellTrap] && !pbChoseMoveFunctionCode?(i,0x16B)
        pbDisplay(_INTL("{1}'s Shell Trap didn't work.",@battlers[i].name))
      end
    end
    for i in 0...4
      @battlers[i].forcedSwitchEarlier                  =false
      next if @battlers[i].hp <= 0
      @battlers[i].damagestate.reset
      @battlers[i].midwayThroughMove                    =false
      @battlers[i].forcedSwitchEarlier                  =false
      @battlers[i].effects[PBEffects::Protect]          =false
      @battlers[i].effects[PBEffects::Obstruct]         =false
      @battlers[i].effects[PBEffects::KingsShield]      =false
      @battlers[i].effects[PBEffects::ProtectNegation]  =false
      @battlers[i].effects[PBEffects::Endure]           =false
      @battlers[i].effects[PBEffects::HyperBeam]-=1     if @battlers[i].effects[PBEffects::HyperBeam]>0
      @battlers[i].effects[PBEffects::SpikyShield]      =false
      @battlers[i].effects[PBEffects::BanefulBunker]    =false
      @battlers[i].effects[PBEffects::BeakBlast]        =false
      @battlers[i].effects[PBEffects::ClangedScales]    =false
      @battlers[i].effects[PBEffects::ShellTrap]        =false
      if @field.effect==PBFields::BURNINGF && @battlers[i].effects[PBEffects::BurnUp] # Burning Field
        @battlers[i].type1= @battlers[i].pokemon.type1
        @battlers[i].type2= @battlers[i].pokemon.type2
        @battlers[i].effects[PBEffects::BurnUp]         =false
      end
      @battlers[i].effects[PBEffects::Powder]           =false
      @battlers[i].effects[PBEffects::MeFirst]          =false
      if @battlers[i].effects[PBEffects::ThroatChop]>0
        @battlers[i].effects[PBEffects::ThroatChop]-=1
      end
      @battlers[i].itemUsed                    =false
    end
    @state.effects[PBEffects::IonDeluge]       =false
    for i in 0...2
      sides[i].effects[PBEffects::QuickGuard]=false
      sides[i].effects[PBEffects::CraftyShield]=false
      sides[i].effects[PBEffects::WideGuard]=false
      sides[i].effects[PBEffects::MatBlock]=false
    end
    @usepriority=false  # recalculate priority
    priority=pbPriority
    if @trickroom > 0
      @trickroom=@trickroom-1
      if @trickroom == 0
        pbDisplay("The twisted dimensions returned to normal!")
      end
    end
    if @state.effects[PBEffects::WonderRoom] > 0
      @state.effects[PBEffects::WonderRoom] -= 1
      if @state.effects[PBEffects::WonderRoom] == 0
        for i in @battlers
          if i.wonderroom
           i.pbSwapDefenses
          end
        end
        pbDisplay("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!")
      end
    end
    priority=pbPriority
    # Field Effects
    endmessage=false
    for i in priority
      next if i.isFainted?
      case @field.effect
        when PBFields::GRASSYT # Grassy Field
          next if i.hp<=0
          if !i.isAirborne? && i.effects[PBEffects::HealBlock]==0 && i.totalhp != i.hp
            pbDisplay(_INTL("The grassy terrain healed the Pokemon on the field.",i.pbThis)) if endmessage == false
            endmessage=true
            hpgain=(i.totalhp/16.0).floor
            hpgain=(hpgain*1.3).floor if (i.item == PBItems::BIGROOT)
            hpgain=i.pbRecoverHP(hpgain,true)
          end
        when PBFields::BURNINGF # Burning Field
          next if i.hp<=0
          if !i.isAirborne?
            if (i.ability == PBAbilities::FLASHFIRE)
              if !i.effects[PBEffects::FlashFire]
                i.effects[PBEffects::FlashFire]=true
                pbDisplay(_INTL("{1}'s {2} raised its Fire power!", i.pbThis,PBAbilities.getName(i.ability)))
              end
            end
            if i.burningFieldPassiveDamage?
              eff=PBTypes.getCombinedEffectiveness(PBTypes::FIRE,i.type1,i.type2)
              if eff>0
                @scene.pbDamageAnimation(i,0)
                if (i.ability == PBAbilities::LEAFGUARD) || (i.ability == PBAbilities::ICEBODY) || (i.ability == PBAbilities::FLUFFY) || (i.ability == PBAbilities::GRASSPELT)
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
        when PBFields::CORROSIVEF # Corrosive Field
          next if i.hp<=0
          if i.ability == PBAbilities::GRASSPELT
            @scene.pbDamageAnimation(i,0)
            i.pbReduceHP((i.totalhp/8.0).floor)
            pbDisplay(_INTL("{1}'s Pelt was corroded!",i.pbThis))
            if i.hp<=0
              return if !i.pbFaint
            end
          end
          if i.ability == PBAbilities::POISONHEAL && !i.isAirborne? && i.effects[PBEffects::HealBlock]==0 && i.hp<i.totalhp
            pbCommonAnimation("Poison",i,nil)
            i.pbRecoverHP((i.totalhp/8.0).floor,true)
            pbDisplay(_INTL("{1} was healed by poison!",i.pbThis))
          end
        when PBFields::CORROSIVEMISTF # Corrosive Mist Field
          if i.pbCanPoison?(false)
            pbDisplay(_INTL("The Pokemon were poisoned by the corrosive mist!",i.pbThis))   if endmessage == false
            endmessage=true
            i.pbPoison(i)
          end
          if i.ability == PBAbilities::POISONHEAL && i.effects[PBEffects::HealBlock]==0 && i.hp<i.totalhp
            pbCommonAnimation("Poison",i,nil)
            i.pbRecoverHP((i.totalhp/8.0).floor,true)
            pbDisplay(_INTL("{1} was healed by poison!",i.pbThis))
          end
        when PBFields::FORESTF # Forest Field
          next if i.hp<=0
          if i.ability == PBAbilities::SAPSIPPER && i.effects[PBEffects::HealBlock]==0
            hpgain=(i.totalhp/16.0).floor
            hpgain=i.pbRecoverHP(hpgain,true)
            pbDisplay(_INTL("{1} drank tree sap to recover!",i.pbThis)) if hpgain>0
          end
        when PBFields::SHORTCIRCUITF # Shortcircuit Field
          next if i.hp<=0
          if i.ability == PBAbilities::VOLTABSORB && i.effects[PBEffects::HealBlock]==0
            hpgain=(i.totalhp/16.0).floor
            hpgain=i.pbRecoverHP(hpgain,true)
            pbDisplay(_INTL("{1} absorbed stray electricity!",i.pbThis)) if hpgain>0
          end
        when PBFields::WASTELAND # Wasteland
          if i.ability == PBAbilities::POISONHEAL && !i.isAirborne? && i.effects[PBEffects::HealBlock]==0 && i.hp<i.totalhp
            pbCommonAnimation("Poison",i,nil)
            i.pbRecoverHP((i.totalhp/8.0).floor,true)
            pbDisplay(_INTL("{1} was healed by poison!",i.pbThis))
          end
        when PBFields::WATERS # Water Surface
          next if i.hp<=0
          if (i.ability == PBAbilities::WATERABSORB || i.ability == PBAbilities::DRYSKIN) && i.effects[PBEffects::HealBlock]==0 && !i.isAirborne?
            hpgain=(i.totalhp/16.0).floor
            hpgain=i.pbRecoverHP(hpgain,true)
            pbDisplay(_INTL("{1} absorbed some of the water!",i.pbThis)) if hpgain>0
          end
        when PBFields::UNDERWATER
          next if i.hp<=0
          if (i.ability == PBAbilities::WATERABSORB || i.ability == PBAbilities::DRYSKIN) && i.effects[PBEffects::HealBlock]==0
            hpgain=(i.totalhp/16.0).floor
            hpgain=i.pbRecoverHP(hpgain,true)
            pbDisplay(_INTL("{1} absorbed some of the water!",i.pbThis)) if hpgain>0
          end
          if i.underwaterFieldPassiveDamamge?
            eff=PBTypes.getCombinedEffectiveness(PBTypes::WATER,i.type1,i.type2)
            if eff>4
              @scene.pbDamageAnimation(i,0)
              if i.ability == PBAbilities::FLAMEBODY || i.ability == PBAbilities::MAGMAARMOR
                eff = eff*2
              end
              i.pbReduceHP([(i.totalhp*eff/32).floor,1].max)
              pbDisplay(_INTL("{1} struggled in the water!",i.pbThis))
              if i.hp<=0
                return if !i.pbFaint
              end
            end
          end
        when PBFields::MURKWATERS # Murkwater Surface
          if i.murkyWaterSurfacePassiveDamage?
            eff=PBTypes.getCombinedEffectiveness(PBTypes::POISON,i.type1,i.type2)
            if i.ability == PBAbilities::FLAMEBODY || i.ability == PBAbilities::MAGMAARMOR || i.ability == PBAbilities::DRYSKIN || i.ability == PBAbilities::WATERABSORB
              eff = eff*2
            end
            if $cache.pkmn_move[i.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCB # Dive
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP([(i.totalhp*eff/8).floor,1].max)
              pbDisplay(_INTL("{1} suffocated underneath the toxic water!",i.pbThis))
            elsif !i.isAirborne?
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP([(i.totalhp*eff/32).floor,1].max)
              pbDisplay(_INTL("{1} was hurt by the toxic water!",i.pbThis))
            end
          end
          if i.isFainted?
            return if !i.pbFaint
          end
          if i.pbHasType?(:POISON) && (i.ability == PBAbilities::DRYSKIN || i.ability == PBAbilities::WATERABSORB) || i.ability == PBAbilities::POISONHEAL  && !i.isAirborne? && i.effects[PBEffects::HealBlock]==0 && i.hp<i.totalhp
            pbCommonAnimation("Poison",i,nil)
            i.pbRecoverHP((i.totalhp/8.0).floor,true)
            pbDisplay(_INTL("{1} was healed by the poisoned water!",i.pbThis))
          end
      end
    end
    # End Field stuff
    # Weather
    # Unsure what this is really doing, cass thinks it's probably nothing. But just in case ?? ~a
    #if @field.effect != PBFields::UNDERWATER
    #  @field.counter = 0 if @weather != PBWeather::HAIL && @field.effect == PBFields::MOUNTAIN
    #end
    case @weather
      when PBWeather::SUNNYDAY
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sunlight faded."))
          pbDisplay(_INTL("The starry sky shone through!")) if @field.effect == PBFields::STARLIGHTA
          @weather=0
        else
          pbCommonAnimation("Sunny")
          if @field.effect == PBFields::DARKCRYSTALC #Dark Crystal Cavern
            setField(PBFields::CRYSTALC,true)
            @field.duration = @weatherduration + 1
            @field.duration_condition = proc {|battle| battle.weather == PBWeather::SUNNYDAY}
            @field.permanent_condition = proc {|battle| battle.FE != PBFields::CRYSTALC}
            pbDisplay(_INTL("The sun lit up the crystal cavern!"))
          end
          if pbWeather == PBWeather::SUNNYDAY
            for i in priority
              next if i.isFainted?
              if i.ability == PBAbilities::SOLARPOWER
                pbDisplay(_INTL("{1} was hurt by the sunlight!",i.pbThis))
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP((i.totalhp/8.0).floor)
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
          pbDisplay(_INTL("The starry sky shone through!")) if @field.effect == PBFields::STARLIGHTA
          @weather=0
        else
          pbCommonAnimation("Rain")
          if @field.effect == PBFields::BURNINGF
            breakField
            pbDisplay(_INTL("The rain snuffed out the flame!"));
          end
        end
      when PBWeather::SANDSTORM
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sandstorm subsided."))
          pbDisplay(_INTL("The starry sky shone through!")) if @field.effect == PBFields::STARLIGHTA
          @weather=0
        else
          pbCommonAnimation("Sandstorm")
          if @field.effect == PBFields::BURNINGF
            breakField
            pbDisplay(_INTL("The sand snuffed out the flame!"));
          end
          if @field.effect == PBFields::RAINBOWF
            breakField if @field.duration == 0
            endTempField if @field.duration > 0
            pbDisplay(_INTL("The weather blocked out the rainbow!"));
          end
          if pbWeather==PBWeather::SANDSTORM
            endmessage=false
            for i in priority
              next if i.isFainted?
              if !i.pbHasType?(:GROUND) && !i.pbHasType?(:ROCK) && !i.pbHasType?(:STEEL) && !(i.ability == PBAbilities::SANDVEIL  || i.ability == PBAbilities::SANDRUSH ||
                i.ability == PBAbilities::SANDFORCE || i.ability == PBAbilities::MAGICGUARD || i.ability == PBAbilities::OVERCOAT) &&
              !(i.item == PBItems::SAFETYGOGGLES) && ![0xCA,0xCB].include?($cache.pkmn_move[i.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]) # Dig, Dive
                pbDisplay(_INTL("The Pokemon were buffeted by the sandstorm!",i.pbThis)) if endmessage==false
                endmessage=true
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP((i.totalhp/16.0).floor)
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
          pbDisplay(_INTL("The starry sky shone through!")) if @field.effect == PBFields::STARLIGHTA
          @weather=0
        elsif @field.effect == PBFields::SUPERHEATEDF
          pbDisplay(_INTL("The hail melted away."))
          @weather=0
        else
          pbCommonAnimation("Hail")
          if @field.effect == PBFields::RAINBOWF
            breakField if @field.duration == 0
            endTempField if @field.duration > 0
            pbDisplay(_INTL("The weather blocked out the rainbow!"));
          end
          if pbWeather==PBWeather::HAIL
            endmessage=false
            for i in priority
              next if i.isFainted?
              if !i.pbHasType?(:ICE) && i.ability != PBAbilities::ICEBODY && i.ability != PBAbilities::SNOWCLOAK && i.ability != PBAbilities::MAGICGUARD &&
                !(i.item == PBItems::SAFETYGOGGLES) && i.ability != PBAbilities::OVERCOAT && ![0xCA,0xCB].include?($cache.pkmn_move[i.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]) # Dig, Dive
                pbDisplay(_INTL("The Pokemon were buffeted by the hail!",i.pbThis)) if endmessage==false
                endmessage=true
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP((i.totalhp/16.0).floor)
                if i.isFainted?
                  return if !i.pbFaint
                end
              end
            end
            if @field.effect  == PBFields::MOUNTAIN
              @field.counter+=1
              if @field.counter == 3
                setField(PBFields::SNOWYM)
                pbDisplay(_INTL("The mountain was covered in snow!"))
              end
            end
          end
        end
      when PBWeather::STRONGWINDS
        pbCommonAnimation("Wind")
    end
    # Shadow Sky weather
    if isConst?(@weather,PBWeather,:SHADOWSKY) #leaving this call alone
      @weatherduration=@weatherduration-1 if @weatherduration>0
      if @weatherduration==0
        pbDisplay(_INTL("The shadow sky faded."))
        @weather=0
      else
        pbCommonAnimation("ShadowSky")
        if isConst?(pbWeather,PBWeather,:SHADOWSKY)
          for i in priority
            next if i.isFainted?
            if !i.isShadow?
              pbDisplay(_INTL("{1} was hurt by the shadow sky!",i.pbThis))
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP((i.totalhp/16.0).floor)
              if i.isFainted?
                return if !i.pbFaint
              end
            end
          end
        end
      end
    end
    # Future Sight/Doom Desire
    for i in battlers   # not priority
      next if i.effects[PBEffects::FutureSight]<=0
      i.effects[PBEffects::FutureSight]-=1
      next if i.isFainted? || i.effects[PBEffects::FutureSight]!=0
      moveuser=nil
      #check if battler on the field
      move, moveuser, disabled_items = i.pbFutureSightUserPlusMove
      type = move.type
      pbDisplay(_INTL("{1} took the {2} attack!",i.pbThis,move.name))
      typemod = move.pbTypeModifier(type,moveuser,i)
      twoturninvul = PBStuff::TWOTURNMOVE.include?(i.effects[PBEffects::TwoTurnAttack])
      if (i.isFainted? || move.pbAccuracyCheck(moveuser,i) && !(i.ability == PBAbilities::WONDERGUARD && typemod<=4)) && !twoturninvul
        i.damagestate.reset
        damage = nil
        if i.effects[PBEffects::FutureSightMove] == PBMoves::FUTURESIGHT && !(i.pbHasType?(:DARK))
          moveuser.hp != 0 ? pbAnimation(PBMoves::FUTUREDUMMY,moveuser,i) : pbAnimation(PBMoves::FUTUREDUMMY,i,i)
        elsif i.effects[PBEffects::FutureSightMove] == PBMoves::DOOMDESIRE
          moveuser.hp != 0 ? pbAnimation(PBMoves::DOOMDUMMY,moveuser,i) : pbAnimation(PBMoves::DOOMDUMMY,i,i)
        end
        move.pbReduceHPDamage(damage,moveuser,i)
        move.pbEffectMessages(moveuser,i)
      elsif i.ability == PBAbilities::WONDERGUARD && typemod<=4 && !twoturninvul
        pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",i.pbThis))
      else
        pbDisplay(_INTL("But it failed!"))
      end
      i.effects[PBEffects::FutureSight]=0
      i.effects[PBEffects::FutureSightMove]=0
      i.effects[PBEffects::FutureSightUser]=-1
      if !disabled_items.empty?
        moveuser.item = disabled_items[:item]
        moveuser.ability = disabled_items[:ability]
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    for i in priority
      next if i.isFainted?
      # Rain Dish
      if i.ability == PBAbilities::RAINDISH && (pbWeather==PBWeather::RAINDANCE && !i.hasWorkingItem(:UTILITYUMBRELLA)) && i.effects[PBEffects::HealBlock]==0
        hpgain=i.pbRecoverHP((i.totalhp/16.0).floor,true)
        pbDisplay(_INTL("{1}'s Rain Dish restored its HP a little!",i.pbThis)) if hpgain>0
      end

      # Dry Skin
      if (i.ability == PBAbilities::DRYSKIN)
        if (pbWeather==PBWeather::RAINDANCE && !i.hasWorkingItem(:UTILITYUMBRELLA)) && i.effects[PBEffects::HealBlock]==0
          hpgain=i.pbRecoverHP((i.totalhp/8.0).floor,true)
          pbDisplay(_INTL("{1}'s Dry Skin was healed by the rain!",i.pbThis)) if hpgain>0
        elsif (pbWeather==PBWeather::SUNNYDAY && !i.hasWorkingItem(:UTILITYUMBRELLA))
          @scene.pbDamageAnimation(i,0)
          hploss=i.pbReduceHP((i.totalhp/8.0).floor)
          pbDisplay(_INTL("{1}'s Dry Skin was hurt by the sunlight!",i.pbThis)) if hploss>0
        elsif @field.effect == PBFields::CORROSIVEMISTF && !i.pbHasType?(:STEEL)
          if !i.pbHasType?(:POISON)
            @scene.pbDamageAnimation(i,0)
            hploss=i.pbReduceHP((i.totalhp/8.0).floor)
            pbDisplay(_INTL("{1}'s Dry Skin absorbed the poison!",i.pbThis)) if hploss>0
          elsif i.effects[PBEffects::HealBlock]==0
            hpgain=i.pbRecoverHP((i.totalhp/8.0).floor,true)
            pbDisplay(_INTL("{1}'s Dry Skin was healed by the poison!",i.pbThis)) if hpgain>0
          end
        elsif @field.effect == PBFields::DESERTF
          @scene.pbDamageAnimation(i,0)
          hploss=i.pbReduceHP((i.totalhp/8.0).floor)
          pbDisplay(_INTL("{1}'s Dry Skin was hurt by the desert air!",i.pbThis)) if hploss>0
        elsif @field.effect == PBFields::MISTYT
          hpgain=0
          if i.effects[PBEffects::HealBlock]==0
            hpgain=(i.totalhp/16.0).floor
            hpgain=i.pbRecoverHP(hpgain,true)
          end
          pbDisplay(_INTL("{1}'s Dry Skin was healed by the mist!",i.pbThis)) if hpgain>0
        elsif @field.effect == PBFields::SWAMPF  # Swamp Field
          hpgain=0
          if i.effects[PBEffects::HealBlock]==0
            hpgain=(i.totalhp/16.0).floor
            hpgain=i.pbRecoverHP(hpgain,true)
          end
          pbDisplay(_INTL("{1}'s Dry Skin was healed by the murk!",i.pbThis)) if hpgain>0
        end
      end
      # Ice Body
      if i.ability == PBAbilities::ICEBODY && (pbWeather==PBWeather::HAIL || @field.effect == PBFields::ICYF || @field.effect == PBFields::SNOWYM) && i.effects[PBEffects::HealBlock]==0
        hpgain=i.pbRecoverHP((i.totalhp/16.0).floor,true)
        pbDisplay(_INTL("{1}'s Ice Body restored its HP a little!",i.pbThis)) if hpgain>0
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Wish
    for i in priority
      if i.effects[PBEffects::Wish]>0
        i.effects[PBEffects::Wish]-=1
        if i.effects[PBEffects::Wish]==0
          next if i.isFainted?
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
      if i.ability == PBAbilities::SHEDSKIN
        if (pbRandom(10)<3 || @field.effect == PBFields::DRAGONSD) && i.status>0
          pbDisplay(_INTL("{1}'s Shed Skin cured its {2} problem!",i.pbThis,STATUSTEXTS[i.status]))
          i.status=0
          i.statusCount=0
          if @field.effect == PBFields::DRAGONSD
            pbDisplay(_INTL("{1}'s scaled sheen glimmers brightly!",i.pbThis))
            if i.effects[PBEffects::HealBlock]==0
              hpgain=(i.totalhp/4.0).floor
              hpgain=i.pbRecoverHP(hpgain,true)
            end
            animDDShedSkin = true 
            if !i.pbTooHigh?(PBStats::SPEED)
              i.pbIncreaseStatBasic(PBStats::SPEED,1)
              pbCommonAnimation("StatUp",i,nil)
              animDDShedSkin = false
            end
            if !i.pbTooHigh?(PBStats::SPATK)
              i.pbIncreaseStatBasic(PBStats::SPATK,1)
              pbCommonAnimation("StatUp",i,nil) if animDDShedSkin == true
            end
            animDDShedSkin = true 
            if !i.pbTooLow?(PBStats::DEFENSE)
              i.pbReduceStat(PBStats::DEFENSE,1)
              pbCommonAnimation("StatDown",i,nil)
              animDDShedSkin = false
            end
            if !i.pbTooLow?(PBStats::SPDEF)
              i.pbReduceStat(PBStats::SPDEF,1)
              pbCommonAnimation("StatDown",i,nil) if animDDShedSkin == true
            end
          end
        end
      end
      # Hydration
      if i.ability == PBAbilities::HYDRATION && ((pbWeather==PBWeather::RAINDANCE && !i.hasWorkingItem(:UTILITYUMBRELLA)) || @field.effect == PBFields::WATERS || @field.effect == PBFields::UNDERWATER)
        if i.status>0
          pbDisplay(_INTL("{1}'s Hydration cured its {2} problem!",i.pbThis,STATUSTEXTS[i.status]))
          i.status=0
          i.statusCount=0
        end
      end
      if i.ability == PBAbilities::WATERVEIL && (@field.effect == PBFields::WATERS || @field.effect == PBFields::UNDERWATER)
        if i.status>0
          pbDisplay(_INTL("{1}'s Water Veil cured its status problem!",i.pbThis))
          i.status=0
          i.statusCount=0
        end
      end
      # Healer
      if i.ability == PBAbilities::HEALER
        partner=i.pbPartner
        if partner
          if pbRandom(10)<3 && partner.status>0
            pbDisplay(_INTL("{1}'s Healer cured its partner's {2} problem!",i.pbThis,STATUSTEXTS[partner.status]))
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
        if @field.effect == PBFields::CORROSIVEMISTF && !i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON)
          @scene.pbDamageAnimation(i,0)
          i.pbReduceHP((i.totalhp/16.0).floor)
          pbDisplay(_INTL("{1}'s Aqua Ring absorbed poison!",i.pbThis))
          if i.hp<=0
            return if !i.pbFaint
          end
        elsif i.effects[PBEffects::HealBlock]==0
          hpgain=(i.totalhp/16.0).floor
          hpgain=(hpgain*1.3).floor if (i.item == PBItems::BIGROOT)
          hpgain=(hpgain*2).floor if [PBFields::MISTYT,PBFields::SWAMPF,PBFields::WATERS,PBFields::UNDERWATER].include?(@field.effect)
          hpgain=i.pbRecoverHP(hpgain,true)
          pbDisplay(_INTL("{1}'s Aqua Ring restored its HP a little!",i.pbThis)) if hpgain>0
        end
      end
    end
    # Ingrain
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Ingrain]
        if (@field.effect == PBFields::SWAMPF || @field.effect == PBFields::CORROSIVEF) && (!i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON))
          @scene.pbDamageAnimation(i,0)
          i.pbReduceHP((i.totalhp/16.0).floor)
          pbDisplay(_INTL("{1} absorbed foul nutrients with its roots!",i.pbThis))
          if i.hp<=0
            return if !i.pbFaint
          end
        else
          if (@field.effect == PBFields::FLOWERGARDENF && @field.counter >2)
            hpgain=(i.totalhp/4.0).floor
          elsif (@field.effect == PBFields::FORESTF || (@field.effect == PBFields::FLOWERGARDENF && @field.counter >0))
            hpgain=(i.totalhp/8.0).floor
          elsif i.effects[PBEffects::HealBlock]==0
            hpgain=(i.totalhp/16.0).floor
          end
          if i.effects[PBEffects::HealBlock]==0
            hpgain=(hpgain*1.3).floor if (i.item == PBItems::BIGROOT)
            hpgain=i.pbRecoverHP(hpgain,true)
            pbDisplay(_INTL("{1} absorbed nutrients with its roots!",i.pbThis)) if hpgain>0
          end
        end
      end
    end
    # Leech Seed
    for i in priority
      if !i.abilityWorks?(true) && i.ability == PBAbilities::LIQUIDOOZE && i.effects[PBEffects::LeechSeed]>=0
        recipient=@battlers[i.effects[PBEffects::LeechSeed]]
        if recipient && !recipient.isFainted?
          hploss=(i.totalhp/8.0).floor
          hploss= hploss * 2 if @field.effect == PBFields::WASTELAND 
          pbCommonAnimation("LeechSeed",recipient,i)
          i.pbReduceHP(hploss,true)
          hploss= hploss / 2 if @field.effect == PBFields::WASTELAND
          hploss= hploss * 2 if @field.effect == PBFields::MURKWATERS
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
      if i.effects[PBEffects::LeechSeed]>=0
        recipient=@battlers[i.effects[PBEffects::LeechSeed]]
        if recipient && !recipient.isFainted?  &&
          i.ability != PBAbilities::MAGICGUARD # if recipient exists
          pbCommonAnimation("LeechSeed",recipient,i)
          hploss=i.pbReduceHP((i.totalhp/8.0).floor,true)
          hploss= hploss * 2 if @field.effect == PBFields::WASTELAND
          if recipient.effects[PBEffects::HealBlock]==0
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
      # Poison/Bad poison
      if i.status==PBStatuses::POISON && i.ability != PBAbilities::MAGICGUARD
        if i.ability == PBAbilities::POISONHEAL
          if i.effects[PBEffects::HealBlock]==0
            if i.hp<i.totalhp
              pbCommonAnimation("Poison",i,nil)
              i.pbRecoverHP((i.totalhp/8.0).floor,true)
              pbDisplay(_INTL("{1} is healed by poison!",i.pbThis))
            end
            if i.statusCount>0
              i.effects[PBEffects::Toxic]+=1
              i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
            end
          end
        else
          i.pbContinueStatus
          if i.statusCount==0
            i.pbReduceHP((i.totalhp/8.0).floor)
          else
            i.effects[PBEffects::Toxic]+=1
            i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
            i.pbReduceHP((i.totalhp/16.0).floor*i.effects[PBEffects::Toxic])
          end
        end
      end
      # Burn
      if i.status==PBStatuses::BURN && i.ability != PBAbilities::MAGICGUARD
        i.pbContinueStatus
        if i.ability == PBAbilities::HEATPROOF || @field.effect == PBFields::ICYF
          i.pbReduceHP((i.totalhp/32.0).floor)
        else
          i.pbReduceHP((i.totalhp/16.0).floor)
        end
      end
      # Nightmare
      if i.effects[PBEffects::Nightmare] && i.ability != PBAbilities::MAGICGUARD && @field.effect != PBFields::RAINBOWF
        if i.status==PBStatuses::SLEEP
          pbCommonAnimation("Nightmare",i,nil)
          pbDisplay(_INTL("{1} is locked in a nightmare!",i.pbThis))
          i.pbReduceHP((i.totalhp/4.0).floor,true)
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
      next if !i.effects[PBEffects::Curse]
      if @field.effect == PBFields::HOLYF 
        i.effects[PBEffects::Curse] = false
        pbDisplay(_INTL("{1}'s curse was lifted!",i.pbThis))
      end
      if i.ability != PBAbilities::MAGICGUARD
        pbCommonAnimation("Curse",i,nil)
        pbDisplay(_INTL("{1} is afflicted by the curse!",i.pbThis))
        i.pbReduceHP((i.totalhp/4.0).floor,true)
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Multi-turn attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    for i in priority
      next if i.isFainted?
      i.pbBerryCureCheck
      if i.effects[PBEffects::MultiTurn]>0
        i.effects[PBEffects::MultiTurn]-=1
        movename=PBMoves.getName(i.effects[PBEffects::MultiTurnAttack])
        if i.effects[PBEffects::MultiTurn]==0
          pbDisplay(_INTL("{1} was freed from {2}!",i.pbThis,movename))
          $bindingband=0
        elsif !(i.ability == PBAbilities::MAGICGUARD)
          pbDisplay(_INTL("{1} is hurt by {2}!",i.pbThis,movename))
          if (i.effects[PBEffects::MultiTurnAttack] == PBMoves::BIND)
            pbCommonAnimation("Bind",i,nil)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::CLAMP)
            pbCommonAnimation("Clamp",i,nil)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::FIRESPIN)
            pbCommonAnimation("FireSpin",i,nil)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::MAGMASTORM)
            pbCommonAnimation("Magma Storm",i,nil)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::SANDTOMB)
            pbCommonAnimation("SandTomb",i,nil)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::WRAP)
            pbCommonAnimation("Wrap",i,nil)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::INFESTATION)
            pbCommonAnimation("Infestation",i,nil)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::WHIRLPOOL)
            pbCommonAnimation("Whirlpool",i,nil)
          else
            pbCommonAnimation("Wrap",i,nil)
          end
          @scene.pbDamageAnimation(i,0)
          if $bindingband==1
            i.pbReduceHP((i.totalhp/6.0).floor)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::MAGMASTORM) && @field.effect == PBFields::DRAGONSD
            i.pbReduceHP((i.totalhp/6.0).floor)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::SANDTOMB) && @field.effect == PBFields::DESERTF
            i.pbReduceHP((i.totalhp/6.0).floor)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::WHIRLPOOL) && (@field.effect == PBFields::WATERS || @field.effect == PBFields::UNDERWATER)
            i.pbReduceHP((i.totalhp/6.0).floor)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::INFESTATION) && @field.effect == PBFields::FORESTF
            i.pbReduceHP((i.totalhp/6.0).floor)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::FIRESPIN) && @field.effect == PBFields::BURNINGF
            i.pbReduceHP((i.totalhp/6.0).floor)
          elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::INFESTATION) && @field.effect == PBFields::FLOWERGARDENF && @field.counter > 1
            case @field.counter
              when 2 then i.pbReduceHP((i.totalhp/6.0).floor)
              when 3 then i.pbReduceHP((i.totalhp/4.0).floor)
              when 4 then i.pbReduceHP((i.totalhp/3.0).floor)
            end
          else
            i.pbReduceHP((i.totalhp/8.0).floor)
          end
          if (i.effects[PBEffects::MultiTurnAttack] == PBMoves::SANDTOMB) && @field.effect == PBFields::ASHENB
            i.pbReduceStat(PBStats::ACCURACY,1,abilitymessage:true)
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
      next if i.effects[PBEffects::Taunt] == 0
      i.effects[PBEffects::Taunt]-=1
      if i.effects[PBEffects::Taunt]==0
        pbDisplay(_INTL("{1} recovered from the taunting!",i.pbThis))
      end
    end
    # Encore
    for i in priority
      next if i.isFainted?
      next if i.effects[PBEffects::Encore] == 0
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
    # Disable/Cursed Body
    for i in priority
      next if i.isFainted?
      next if i.effects[PBEffects::Disable]==0
      i.effects[PBEffects::Disable]-=1
      if i.effects[PBEffects::Disable]==0
        i.effects[PBEffects::DisableMove]=0
        pbDisplay(_INTL("{1} is disabled no more!",i.pbThis))
      end
    end
    # Magnet Rise
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::MagnetRise]>0
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
          i.pbBerryCureCheck
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
    if @state.effects[PBEffects::MudSport]>0
      @state.effects[PBEffects::MudSport]-=1
      if @state.effects[PBEffects::MudSport]==0
        pbDisplay(_INTL("The effects of Mud Sport faded."))
      end
    end
    # Water Sport
    if @state.effects[PBEffects::WaterSport]>0
      @state.effects[PBEffects::WaterSport]-=1
      if @state.effects[PBEffects::WaterSport]==0
        pbDisplay(_INTL("The effects of Water Sport faded."))
      end
    end
    # Gravity
    if @state.effects[PBEffects::Gravity]>0
      @state.effects[PBEffects::Gravity]-=1
      if @state.effects[PBEffects::Gravity]==0
        if @field.backup == PBFields::NEWW && @field.effect != PBFields::NEWW
          breakField
          pbDisplay(_INTL("The world broke apart again!"))
          noWeather
        else
          pbDisplay(_INTL("Gravity returned to normal."))
        end
      end
    end

    # Terrain
    if @field.duration>0
      @field.checkPermCondition(self)
    end
    if @field.duration>0
      @field.duration-=1
      @field.duration = 0 if @field.duration_condition && !@field.duration_condition.call(self)
      if @field.duration==0
        endTempField
        pbDisplay(_INTL("The terrain returned to normal."))
        noWeather
      end
    end
    # Trick Room - should go here
    # Wonder Room - should go here
    # Magic Room
    if @state.effects[PBEffects::MagicRoom]>0
      @state.effects[PBEffects::MagicRoom]-=1
      if @state.effects[PBEffects::MagicRoom]==0
        pbDisplay(_INTL("The area returned to normal."))
      end
    end
    # Fairy Lock
    if @state.effects[PBEffects::FairyLock]>0
      @state.effects[PBEffects::FairyLock]-=1
      if @state.effects[PBEffects::FairyLock]==0
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

    # Slow Start's end message
    for i in priority
      next if i.isFainted?
      if i.ability==PBAbilities::SLOWSTART && i.turncount==4
        pbDisplay(_INTL("{1} finally got its act together!",i.pbThis))
      end
    end

    #Wasteland hazard interaction
    if @field.effect == PBFields::WASTELAND
      for i in priority
        is_fainted_before = i.isFainted?
        partner_fainted_before = @doublebattle && i.pbPartner.isFainted?
        # Stealth Rock
        if i.pbOwnSide.effects[PBEffects::StealthRock]==true
          pbDisplay(_INTL("The waste swallowed up the pointed stones!"))
          i.pbOwnSide.effects[PBEffects::StealthRock]=false
          pbDisplay(_INTL("...Rocks spewed out from the ground below!"))
          for mon in [i, i.pbPartner]
            next if mon.isFainted? || PBStuff::TWOTURNMOVE.include?(mon.effects[PBEffects::TwoTurnAttack])
            eff=PBTypes.getCombinedEffectiveness(PBTypes::ROCK,mon.type1,mon.type2)
            next if eff <=0
            @scene.pbDamageAnimation(mon,0)
            mon.pbReduceHP([(mon.totalhp*eff/16).floor,1].max)
          end
        end

        # Spikes
        if i.pbOwnSide.effects[PBEffects::Spikes]>0
          pbDisplay(_INTL("The waste swallowed up the spikes!"))
          i.pbOwnSide.effects[PBEffects::Spikes]=0
          pbDisplay(_INTL("...Stalagmites burst up from the ground!"))
          for mon in [i, i.pbPartner]
            if !mon.isFainted? && !mon.isAirborne? && !PBStuff::TWOTURNMOVE.include?(mon.effects[PBEffects::TwoTurnAttack]) # Dig, Dive, etc
              @scene.pbDamageAnimation(mon,0)
              mon.pbReduceHP([(mon.totalhp/3.0).floor,1].max)
            end
          end
        end

        # Toxic Spikes
        if i.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
          pbDisplay(_INTL("The waste swallowed up the toxic spikes!"))
          i.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
          pbDisplay(_INTL("...Poison needles shot up from the ground!"))
          for mon in [i, i.pbPartner]
            next if mon.isFainted? || mon.isAirborne? || mon.pbHasType?(:STEEL) || mon.pbHasType?(:POISON)
            next if PBStuff::TWOTURNMOVE.include?(mon.effects[PBEffects::TwoTurnAttack])
            @scene.pbDamageAnimation(mon,0)
            mon.pbReduceHP([(mon.totalhp/8.0).floor,1].max)
            if mon.status==0 && mon.pbCanPoison?(false)
              mon.status=PBStatuses::POISON
              mon.statusCount=1
              mon.effects[PBEffects::Toxic]=0
              pbCommonAnimation("Poison",mon,nil)
            end
          end
        end

        # Sticky Web
        if i.pbOwnSide.effects[PBEffects::StickyWeb]
          pbDisplay(_INTL("The waste swallowed up the sticky web!"))
          i.pbOwnSide.effects[PBEffects::StickyWeb]=false
          pbDisplay(_INTL("...Sticky string shot out of the ground!"))
          for mon in [i, i.pbPartner]
            next if mon.isFainted? && !PBStuff::TWOTURNMOVE.include?(mon.effects[PBEffects::TwoTurnAttack])
            if mon.ability == PBAbilities::CONTRARY && !mon.pbTooHigh?(PBStats::SPEED)
              mon.pbIncreaseStatBasic(PBStats::SPEED,4)
                pbCommonAnimation("StatUp",mon,nil)
                pbDisplay(_INTL("{1}'s Speed went way up!",mon.pbThis))
            elsif !mon.pbTooLow?(PBStats::SPEED)
              mon.pbReduceStatBasic(PBStats::SPEED,4)
              pbCommonAnimation("StatDown",mon,nil)
              pbDisplay(_INTL("{1}'s Speed was severely lowered!",mon.pbThis))
            end
          end
        end

        # Fainting
        if @doublebattle && !partner_fainted_before
          partner=i.pbPartner
          if partner && partner.hp<=0
            partner.pbFaint
          end
        end
        if i.hp<=0 && !is_fainted_before
          return if !i.pbFaint
          next
        end
      end
    end
    # End Wasteland hazards
    for i in priority
      next if i.isFainted?
      # Mimicry
      if i.ability == PBAbilities::MIMICRY
        protype = -1
        case @field.effect
          when PBFields::CRYSTALC
            protype = @field.getRoll
          when PBFields::NEWW
            rnd=pbRandom(18)
            protype = rnd
            protype = 18 if rnd == 9
          else
            protype = FIELDEFFECTS[@field.effect][:MIMICRY] if FIELDEFFECTS[@field.effect][:MIMICRY]
        end
        prot1 = i.type1
        prot2 = i.type2
        camotype = protype
        if camotype>0 && (!i.pbHasType?(camotype) || (defined?(prot2) && prot1 != prot2))
          i.type1=camotype
          i.type2=camotype
          typename=PBTypes.getName(camotype)
          pbDisplay(_INTL("{1} had its type changed to {2}!",i.pbThis,typename))
        end
      end
      # Speed Boost
      # A Pokémon's turncount is 0 if it became active after the beginning of a round
      if i.turncount>0 && (i.ability == PBAbilities::SPEEDBOOST || (@field.effect == PBFields::ELECTRICT && i.ability == PBAbilities::MOTORDRIVE))
        if !i.pbTooHigh?(PBStats::SPEED)
          i.pbIncreaseStatBasic(PBStats::SPEED,1)
          pbCommonAnimation("StatUp",i,nil)
          pbDisplay(_INTL("{1}'s {2} raised its Speed!",i.pbThis, PBAbilities.getName(i.ability)))
        end
      end
      if @field.effect == PBFields::SWAMPF && !(i.ability == PBAbilities::WHITESMOKE) && !(i.ability == PBAbilities::CLEARBODY) && !(i.ability == PBAbilities::QUICKFEET) && !(i.ability == PBAbilities::SWIFTSWIM)
        if !i.isAirborne?
          if !i.pbTooLow?(PBStats::SPEED)
            contcheck = i.ability == PBAbilities::CONTRARY
            candrop = i.pbCanReduceStatStage?(PBStats::SPEED)
            canraise = i.pbCanIncreaseStatStage?(PBStats::SPEED) if contcheck
            i.pbReduceStat(PBStats::SPEED,1, statmessage: false)
            pbDisplay(_INTL("{1}'s Speed sank...",i.pbThis)) if !contcheck && candrop
            pbDisplay(_INTL("{1}'s Speed rose!",i.pbThis)) if contcheck && canraise
          end
        end
      end
      #sleepyswamp
      if i.status==PBStatuses::SLEEP && !(i.ability == PBAbilities::MAGICGUARD)
        if @field.effect == PBFields::SWAMPF # Swamp Field
          hploss=i.pbReduceHP((i.totalhp/16.0).floor,true)
          pbDisplay(_INTL("{1}'s strength is sapped by the swamp!",i.pbThis)) if hploss>0
        end
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
      if i.effects[PBEffects::Octolock]
        locklowered = false
        if !i.pbTooLow?(PBStats::DEFENSE)
          contcheck = (i.ability == PBAbilities::CONTRARY)
          i.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false)
          locklowered = true if !contcheck
        end
        if !i.pbTooLow?(PBStats::SPDEF)
          contcheck = (i.ability == PBAbilities::CONTRARY)
          i.pbReduceStat(PBStats::SPDEF,1,abilitymessage:false)
          locklowered = true if !contcheck
        end
        if locklowered
          pbCommonAnimation("StatDown",i,nil)
          pbDisplay(_INTL("The Octolock lowered {1}'s defenses!",i.pbThis))
        end
      end
      #sleepyrainbow
      if i.status==PBStatuses::SLEEP
        if @field.effect == PBFields::RAINBOWF && i.effects[PBEffects::HealBlock]==0#Rainbow Field
        hpgain=(i.totalhp/16.0).floor
        hpgain=(hpgain*1.3).floor if (i.item == PBItems::BIGROOT)
        hpgain=i.pbRecoverHP(hpgain,true)
        pbDisplay(_INTL("{1} recovered health in its peaceful sleep!",i.pbThis))
        end
      end
      #sleepycorro
      if i.status==PBStatuses::SLEEP && i.ability != PBAbilities::MAGICGUARD && i.ability != PBAbilities::POISONHEAL && i.ability != PBAbilities::TOXICBOOST &&
      i.ability != PBAbilities::WONDERGUARD && !i.isAirborne? && !i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON) && @field.effect == PBFields::CORROSIVEF
        hploss=i.pbReduceHP((i.totalhp/16.0).floor,true)
        pbDisplay(_INTL("{1}'s is seared by the corrosion!",i.pbThis)) if hploss>0
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    # Water Compaction on Water-based Fields
    if i.ability == PBAbilities::WATERCOMPACTION
      if [PBFields::SWAMPF,PBFields::WATERS,PBFields::UNDERWATER,PBFields::MURKWATERS].include?(@field.effect)
        if !i.pbTooHigh?(PBStats::DEFENSE)
          i.pbIncreaseStatBasic(PBStats::DEFENSE,2)
          pbCommonAnimation("StatUp",i,nil)
          pbDisplay(_INTL("{1}'s Water Compaction sharply raised its defense!", i.pbThis))
         end
       end
     end
    # Bad Dreams
    if (i.status==PBStatuses::SLEEP || i.ability == PBAbilities::COMATOSE) && i.ability != PBAbilities::MAGICGUARD && @field.effect != PBFields::RAINBOWF
      if i.pbOpposing1.hasWorkingAbility(:BADDREAMS) || i.pbOpposing2.hasWorkingAbility(:BADDREAMS)
        hploss=i.pbReduceHP((i.totalhp/8.0).floor,true)
        pbDisplay(_INTL("{1} is having a bad dream!",i.pbThis)) if hploss>0
      end
    end
    if i.isFainted?
      return if !i.pbFaint
      next
    end
    # Harvest
    if i.ability == PBAbilities::HARVEST && i.item<=0 && i.pokemon.itemRecycle>0 #if an item was recycled, check
      if pbIsBerry?(i.pokemon.itemRecycle) && (pbRandom(100)>50 ||
       (pbWeather==PBWeather::SUNNYDAY && !i.hasWorkingItem(:UTILITYUMBRELLA)) || (@field.effect == PBFields::FLOWERGARDENF && @field.counter>0))
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
    # Ball Fetch
    if i.ability == PBAbilities::BALLFETCH && i.effects[PBEffects::BallFetch]!=0 && i.item<=0
      pokeball=i.effects[PBEffects::BallFetch]
      i.item=pokeball
      i.pokemon.itemInitial=pokeball
      PBDebug.log("[Ability triggered] #{i.pbThis}'s Ball Fetch found #{PBItems.getName(pokeball)}")
      pbDisplay(_INTL("{1} fetched a {2}!",i.pbThis,PBItems.getName(pokeball)))
    end
    # Moody
    if i.ability == PBAbilities::CLOUDNINE && @field.effect == PBFields::RAINBOWF
      failsafe=0
      randoms=[]
      loop do
        failsafe+=1
        break if failsafe==1000
        randomnumber=1+pbRandom(7)
        if !i.pbTooHigh?(randomnumber)
          randoms.push(randomnumber)
          break
        end
      end
      if failsafe!=1000
       i.stages[randoms[0]]+=1
       i.stages[randoms[0]]=6 if i.stages[randoms[0]]>6
       pbCommonAnimation("StatUp",i,nil)
       pbDisplay(_INTL("{1}'s Cloud Nine raised its {2}!",i.pbThis,i.pbGetStatName(randoms[0])))
      end
    end
    if i.ability == PBAbilities::MOODY
      randomup=[]
      randomdown=[]
      failsafe1=0
      failsafe2=0
      loop do
        failsafe1+=1
        break if failsafe1==1000
        randomnumber=1+pbRandom(7)
        if !i.pbTooHigh?(randomnumber)
          randomup.push(randomnumber)
          break
        end
      end
      loop do
        failsafe2+=1
        break if failsafe2==1000
        randomnumber=1+pbRandom(7)
        if !i.pbTooLow?(randomnumber) && randomnumber!=randomup[0]
          randomdown.push(randomnumber)
          break
        end
      end
       if failsafe1!=1000
         i.stages[randomup[0]]+=2
         i.stages[randomup[0]]=6 if i.stages[randomup[0]]>6
         pbCommonAnimation("StatUp",i,nil)
         pbDisplay(_INTL("{1}'s Moody sharply raised its {2}!",i.pbThis,i.pbGetStatName(randomup[0])))
       end
       if failsafe2!=1000
         i.stages[randomdown[0]]-=1
         pbCommonAnimation("StatDown",i,nil)
         pbDisplay(_INTL("{1}'s Moody lowered its {2}!",i.pbThis,i.pbGetStatName(randomdown[0])))
       end
     end
    end
    for i in priority
      next if i.isFainted?
      next if !i.itemWorks?
      # Toxic Orb
      if i.item == PBItems::TOXICORB && i.status==0 && i.pbCanPoison?(false,true)
        i.status=PBStatuses::POISON
        i.statusCount=1
        i.effects[PBEffects::Toxic]=0
        pbCommonAnimation("Poison",i,nil)
        pbDisplay(_INTL("{1} was poisoned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Flame Orb
      if i.item == PBItems::FLAMEORB && i.status==0 && i.pbCanBurn?(false,true)
        i.status=PBStatuses::BURN
        i.statusCount=0
        pbCommonAnimation("Burn",i,nil)
        pbDisplay(_INTL("{1} was burned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Sticky Barb
      if i.item == PBItems::STICKYBARB && i.ability != PBAbilities::MAGICGUARD
        pbDisplay(_INTL("{1} is hurt by its {2}!",i.pbThis,PBItems.getName(i.item)))
        @scene.pbDamageAnimation(i,0)
        i.pbReduceHP((i.totalhp/8.0).floor)
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    #Emergency exit caused by passive end of turn damage
    for i in priority
      if i.userSwitch == true
        i.userSwitch = false
        pbDisplay(_INTL("{1} went back to {2}!",i.pbThis,pbGetOwner(i.index).name))
        newpoke=0
        newpoke=pbSwitchInBetween(i.index,true,false)
        pbMessagesOnReplace(i.index,newpoke)
        i.vanished=false
        i.pbResetForm
        pbReplace(i.index,newpoke,false)
        pbOnActiveOne(i)
        i.pbAbilitiesOnSwitchIn(true)
      end
    end
    # Hunger Switch
    for i in priority
      next if i.isFainted?
      if i.ability == PBAbilities::HUNGERSWITCH && (i.species == PBSpecies::MORPEKO)
        i.form=(i.form==0) ? 1 : 0
        i.pbUpdate(true)
        scene.pbChangePokemon(i,i.pokemon)
        pbDisplay(_INTL("{1} transformed!",i.pbThis))
      end
    end
    # Form checks
    for i in 0...4
      next if @battlers[i].isFainted?
      @battlers[i].pbCheckForm
      @battlers[i].pbCheckFormRoundEnd
    end
    pbGainEXP

    # Checks if a pokemon on either side has fainted on this turn
    # for retaliate
    player   = priority[0]
    opponent = priority[1]
    if player.isFainted? || (@doublebattle && player.pbPartner.isFainted?)
      player.pbOwnSide.effects[PBEffects::Retaliate] = true
    else
      # No pokemon has fainted in this side this turn
      player.pbOwnSide.effects[PBEffects::Retaliate] = false
    end

    if opponent.isFainted? || (@doublebattle && opponent.pbPartner.isFainted?)
      opponent.pbOwnSide.effects[PBEffects::Retaliate] = true
    else
      opponent.pbOwnSide.effects[PBEffects::Retaliate] = false
    end

    pbSwitch
    pbSwitch
    return if @decision>0
    for i in priority
      next if i.isFainted?
      i.pbAbilitiesOnSwitchIn(false)
    end
    for i in 0...4
      if @battlers[i].turncount>0 && @battlers[i].ability == PBAbilities::TRUANT
        @battlers[i].effects[PBEffects::Truant]=!@battlers[i].effects[PBEffects::Truant]
      end
      if @battlers[i].effects[PBEffects::LockOn]>0   # Also Mind Reader
        @battlers[i].effects[PBEffects::LockOn]-=1
        @battlers[i].effects[PBEffects::LockOnPos]=-1 if @battlers[i].effects[PBEffects::LockOn]==0
      end
      @battlers[i].effects[PBEffects::Roost]=false
      @battlers[i].effects[PBEffects::Flinch]=false
      @battlers[i].effects[PBEffects::FollowMe]=false
      @battlers[i].effects[PBEffects::RagePowder]=false
      @battlers[i].effects[PBEffects::HelpingHand]=false
      @battlers[i].effects[PBEffects::MagicCoat]=false
      @battlers[i].effects[PBEffects::Snatch]=false
      @battlers[i].effects[PBEffects::Electrify]=false
      @battlers[i].effects[PBEffects::TarShot]=false
      @battlers[i].lastHPLost=0
      @battlers[i].lastAttacker=-1
      @battlers[i].effects[PBEffects::Counter]=-1
      @battlers[i].effects[PBEffects::CounterTarget]=-1
      @battlers[i].effects[PBEffects::MirrorCoat]=-1
      @battlers[i].effects[PBEffects::MirrorCoatTarget]=-1
    end
    # invalidate stored priority
    @usepriority=false
  end

################################################################################
# End of battle.
################################################################################
  def pbEndOfBattle(canlose=false)
    case @decision
    ##### WIN #####
      when 1
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
        if @internalbattle
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
            maxlevel1=[100,maxlevel1].min
            maxlevel2=[100,maxlevel2].min
            tmoney+=maxlevel1*@opponent[0].moneyEarned
            tmoney+=maxlevel2*@opponent[1].moneyEarned
          else
            maxlevel=0
            for i in @party2
              next if !i
              maxlevel=i.level if maxlevel<i.level
            end
            tmoney+=maxlevel*@opponent.moneyEarned
          end
          # If Amulet Coin/Luck Incense's effect applies, double money earned
         # badgemultiplier = [1,self.pbPlayer.numbadges].max
          badgemultiplier = (1+(self.pbPlayer.numbadges/3)).floor
          tmoney*=badgemultiplier
          tmoney*=2 if @amuletcoin
          tmoney*=2 if  $game_switches[:Moneybags]==true
          if $game_switches[:Grinding_Trainer_Money_Cut]==true || $game_switches[:Penniless_Mode] == true #grinding trainers
            tmoney*=0.33
            tmoney= tmoney.floor
          end
          oldmoney=self.pbPlayer.money
          self.pbPlayer.money+=tmoney
          moneygained=self.pbPlayer.money-oldmoney
          if moneygained>0
            pbDisplayPaused(_INTL("{1} got ${2}\r\nfor winning!",self.pbPlayer.name,tmoney))
          end
        end
      end
      if @internalbattle && @extramoney>0
        @extramoney*=2 if @amuletcoin
        oldmoney=self.pbPlayer.money
        self.pbPlayer.money+=@extramoney
        moneygained=self.pbPlayer.money-oldmoney
        if moneygained>0
          pbDisplayPaused(_INTL("{1} picked up ${2}!",self.pbPlayer.name,@extramoney))
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
          multiplier=[8,16,24,36,48,64,80,100,120,140,160,180,210,240,270,300,330,360,400,450] #Badge no. multiplier for money lost
          moneylost*=multiplier[[multiplier.length-1,self.pbPlayer.numbadges].min]
          moneylost=self.pbPlayer.money if moneylost>self.pbPlayer.money
          moneylost=0 if $game_switches[:No_Money_Loss]
          self.pbPlayer.money-=moneylost
          if @opponent
            if @opponent.is_a?(Array)
              pbDisplayPaused(_INTL("{1} lost against {2} and {3}!",self.pbPlayer.name,@opponent[0].fullname,@opponent[1].fullname))
            else
              pbDisplayPaused(_INTL("{1} lost against\r\n{2}!",self.pbPlayer.name,@opponent.fullname))
            end
            if moneylost>0
              pbDisplayPaused(_INTL("{1} paid ${2}\r\nas the prize money...",self.pbPlayer.name,moneylost))
              pbDisplayPaused(_INTL("...")) if !canlose
            end
          else
            if moneylost>0
              pbDisplayPaused(_INTL("{1} panicked and lost\r\n${2}...",self.pbPlayer.name,moneylost))
              pbDisplayPaused(_INTL("...")) if !canlose
            end
          end
          pbDisplayPaused(_INTL("{1} blacked out!",self.pbPlayer.name)) if !canlose
        elsif @decision==2
          @scene.pbShowOpponent(0)
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
    # Change bad poison to normal poison
    for i in $Trainer.party
      next if i.nil?
      if i.statusCount > 0 && i.status == PBStatuses::POISON
        i.statusCount = 0
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
          $Trainer.party[i-1].givePokerus(strain) if pbRandom(3)==0
        end
        if i<$Trainer.party.length-1 && $Trainer.party[i+1].pokerusStage==0
          $Trainer.party[i+1].givePokerus(strain) if pbRandom(3)==0
        end
      end
    end
    @scene.pbEndBattle(@decision)

    # Resetting all the temporary forms
    for i in @battlers
      i.pbResetForm
    end
    if @necrozmaVar[1]!=-1
      if $Trainer.party[@necrozmaVar[0]] != nil
        $Trainer.party[@necrozmaVar[0]].form = @necrozmaVar[1]
      end
    end
    for i in @party1
      next if i.nil?
      i.makeUnmega if i.isMega?
      i.form=0 if i.species == PBSpecies::MIMIKYU && i.form == 1
    end
    for i in $Trainer.party
      i.setItem(i.itemInitial)
      i.itemInitial=i.itemRecycle=0
      i.form=i.getForm(i)
    end

    #Set variables to field effect values
    $game_variables[:Field_Effect_End_Of_Battle] = @field.effect
    $game_variables[:Field_Counter_End_Of_Battle] = @field.counter
    $game_variables[:Weather_End_Of_Battle] = @weather

    return @decision
  end
end