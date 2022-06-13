class PBWeather
  SHADOWSKY = 5
end



def pbPurify(pokemon,scene)
  if pokemon.heartgauge==0 && pokemon.shadow
    return if !pokemon.savedev && !pokemon.savedexp
    pokemon.shadow=false
    pokemon.giveRibbon(PBRibbons::NATIONAL)
    scene.pbDisplay(_INTL("{1} opened the door to its heart!",pokemon.name))
    oldmoves=[]
    for i in 0...4; oldmoves.push(pokemon.moves[i].id); end
    pokemon.pbUpdateShadowMoves()
    for i in 0...4
      if pokemon.moves[i].id!=0 && pokemon.moves[i].id!=oldmoves[i]
        scene.pbDisplay(_INTL("{1} regained the move \n{2}!",
           pokemon.name,PBMoves.getName(pokemon.moves[i].id)))
      end
    end
    pokemon.pbRecordFirstMoves
    if pokemon.savedev
      for i in 0...6
        pbApplyEVGain(pokemon,i,pokemon.savedev[i])
      end
      pokemon.savedev=nil
    end
    newexp=PBExperience.pbAddExperience(pokemon.exp,pokemon.savedexp||0,pokemon.growthrate)
    pokemon.savedexp=nil
    newlevel=PBExperience.pbGetLevelFromExperience(newexp,pokemon.growthrate)
    curlevel=pokemon.level
    if newexp!=pokemon.exp
      scene.pbDisplay(_INTL("{1} regained {2} Exp. Points!",pokemon.name,newexp-pokemon.exp))
    end
    if newlevel==curlevel
      pokemon.exp=newexp
      pokemon.calcStats
    else
      pbChangeLevel(pokemon,newlevel,scene) # for convenience
      pokemon.exp=newexp
    end
    speciesname=PBSpecies.getName(pokemon.species)
    if scene.pbConfirm(_INTL("Would you like to give a nickname to {1}?",speciesname))
      helptext=_INTL("{1}'s nickname?",speciesname)
      newname=pbEnterPokemonName(helptext,0,12,"",pokemon)
      pokemon.name=newname if newname!=""
    end
  end
end



class PokemonTemp
  attr_accessor :heartgauges
end



Events.onStartBattle+=proc {|sender,e|
   $PokemonTemp.heartgauges=[]
   for i in 0...$Trainer.party.length
     $PokemonTemp.heartgauges[i]=$Trainer.party[i].heartgauge
   end
}

Events.onEndBattle+=proc {|sender,e|
   decision = e[0]
   for i in 0...$PokemonTemp.heartgauges.length
     pokemon = $Trainer.party[i]
     if pokemon && ($PokemonTemp.heartgauges[i] &&
        $PokemonTemp.heartgauges[i]!=0 && pokemon.heartgauge==0)
       pbReadyToPurify(pokemon)
     end
   end
}



# Scene class for handling appearance of the screen
class RelicStoneScene
# Processes the scene
  def pbPurify()
  end

# Update the scene here, this is called once each frame
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

# End the scene here
  def pbEndScene
    # Fade out all sprites
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Dispose all sprites
    pbDisposeSpriteHash(@sprites)
    # Dispose the viewport
    @viewport.dispose
  end

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(
       @sprites["msgwindow"],msg,brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(
       @sprites["msgwindow"],msg) { pbUpdate }
  end

  def pbStartScene(pokemon)
    # Create sprite hash
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @pokemon=pokemon
    addBackgroundPlane(@sprites,"bg","relicstonebg",@viewport)
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=true
    @sprites["msgwindow"].viewport=@viewport
    @sprites["msgwindow"].text=""
    @sprites["msgwindow"].x=0
    @sprites["msgwindow"].y=Graphics.height-96
    @sprites["msgwindow"].width=Graphics.width
    @sprites["msgwindow"].height=96
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end



# Screen class for handling game logic
class RelicStoneScreen
  def initialize(scene)
    @scene = scene
  end

  def pbDisplay(x)
    @scene.pbDisplay(x)
  end

  def pbConfirm(x)
    @scene.pbConfirm(x)
  end

  def pbRefresh
  end

  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    @scene.pbPurify()
    pbPurify(pokemon,self)
    @scene.pbEndScene()
  end
end



def pbRelicStoneScreen(pokemon)
  retval = true
  pbFadeOutIn(99999){
     scene = RelicStoneScene.new
     screen = RelicStoneScreen.new(scene)
     retval = screen.pbStartScreen(pokemon)
  }
  return retval
end

def pbIsPurifiable?(pkmn)
  return false if !pkmn
  if pkmn.isShadow? && pkmn.heartgauge==0 &&
     !isConst?(pkmn.species,PBSpecies,:BELDUM)
    return true
  end
  return false
end

def pbIsPurifiable?(pkmn)
  return false if !pkmn
  if pkmn.isShadow? && pkmn.heartgauge==0 &&
     !isConst?(pkmn.species,PBSpecies,:RALTS)
    return true
  end
  return false
end

def pbHasPurifiableInParty()
  return $Trainer.party.any? {|item| pbIsPurifiable?(item) }
end

def pbRelicStone()
  if pbHasPurifiableInParty()
    Kernel.pbMessage(_INTL("There's a Pokémon that may open the door to its heart!"))
    # Choose a purifiable Pokemon
    pbChoosePokemon(1,2,proc {|poke|
       !poke.isEgg? && poke.hp>0 && poke.isShadow? && poke.heartgauge==0
    })
    if $game_variables[1]>=0
      pbRelicStoneScreen($Trainer.party[$game_variables[1]])
    end
  else
    Kernel.pbMessage(_INTL("You have no Pokémon that can be purified."))
  end
end

def pbRaiseHappinessAndReduceHeart(pokemon,scene,amount)
  if !pokemon.isShadow?
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if pokemon.happiness==255 && pokemon.heartgauge==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  elsif pokemon.happiness==255
    pokemon.adjustHeart(-amount)
    scene.pbDisplay(_INTL("{1} adores you!\nThe door to its heart opened a little.",pokemon.name))
    pbReadyToPurify(pokemon)
    return true
  elsif pokemon.heartgauge==0
    pokemon.changeHappiness("vitamin")
    scene.pbDisplay(_INTL("{1} turned friendly.",pokemon.name))
    return true
  else
    pokemon.changeHappiness("vitamin")
    pokemon.adjustHeart(-amount)
    scene.pbDisplay(_INTL("{1} turned friendly.\nThe door to its heart opened a little.",pokemon.name))
    pbReadyToPurify(pokemon)
    return true
  end
end

ItemHandlers::UseOnPokemon.add(:JOYSCENT,proc{|item,pokemon,scene|
   pbRaiseHappinessAndReduceHeart(pokemon,scene,500)
})

ItemHandlers::UseOnPokemon.add(:EXCITESCENT,proc{|item,pokemon,scene|
   pbRaiseHappinessAndReduceHeart(pokemon,scene,1000)
})

ItemHandlers::UseOnPokemon.add(:VIVIDSCENT,proc{|item,pokemon,scene|
   pbRaiseHappinessAndReduceHeart(pokemon,scene,2000)
})

ItemHandlers::UseOnPokemon.add(:TIMEFLUTE,proc{|item,pokemon,scene|
   if !pokemon.isShadow?
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
   pokemon.heartgauge=0
   pbReadyToPurify(pokemon)
   next true
})

ItemHandlers::BattleUseOnBattler.add(:JOYSCENT,proc{|item,battler,scene|
   if !battler.isShadow?
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false
   end
   if battler.inHyperMode?
     battler.pokemon.hypermode=false
     battler.pokemon.adjustHeart(-300)
     scene.pbDisplay(_INTL("{1} came to its senses from the {2}!",battler.pbThis,PBItems.getName(item)))
#     if battler.happiness!=255 || battler.pokemon.heartgauge!=0
#       pbRaiseHappinessAndReduceHeart(battler.pokemon,scene,500)
#     end
     return true
   end
#   return pbRaiseHappinessAndReduceHeart(battler.pokemon,scene,500)
   scene.pbDisplay(_INTL("It won't have any effect."))
   return false
})

ItemHandlers::BattleUseOnBattler.add(:EXCITESCENT,proc{|item,battler,scene|
   if !battler.isShadow?
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false
   end
   if battler.inHyperMode?
     battler.pokemon.hypermode=false
     battler.pokemon.adjustHeart(-300)
     scene.pbDisplay(_INTL("{1} came to its senses from the {2}!",battler.pbThis,PBItems.getName(item)))
#     if battler.happiness!=255 || battler.pokemon.heartgauge!=0
#       pbRaiseHappinessAndReduceHeart(battler.pokemon,scene,1000)
#     end
     return true
   end
#   return pbRaiseHappinessAndReduceHeart(battler.pokemon,scene,1000)
   scene.pbDisplay(_INTL("It won't have any effect."))
   return false
})

ItemHandlers::BattleUseOnBattler.add(:VIVIDSCENT,proc{|item,battler,scene|
   if !battler.isShadow?
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false
   end
   if battler.inHyperMode?
     battler.pokemon.hypermode=false
     battler.pokemon.adjustHeart(-300)
     scene.pbDisplay(_INTL("{1} came to its senses from the {2}!",battler.pbThis,PBItems.getName(item)))
 #    if battler.happiness!=255 || battler.pokemon.heartgauge!=0
#       pbRaiseHappinessAndReduceHeart(battler.pokemon,scene,2000)
#     end
     return true
   end
#   return pbRaiseHappinessAndReduceHeart(battler.pokemon,scene,2000)
   scene.pbDisplay(_INTL("It won't have any effect."))
   return false
})

def pbApplyEVGain(pokemon,ev,evgain)
  totalev=0
  for i in 0...6
    totalev+=pokemon.ev[i]
  end
  if totalev+evgain>510 # Can't exceed overall limit
    evgain-=totalev+evgain-510
  end
  if pokemon.ev[ev]+evgain>252
    evgain-=totalev+evgain-252
  end
  if evgain>0
    pokemon.ev[ev]+=evgain
  end
end

def pbReplaceMoves(pokemon,move1,move2=0,move3=0,move4=0)
  return if !pokemon
  [move1,move2,move3,move4].each{|move|
     moveIndex=-1
     if move!=0
       # Look for given move
       for i in 0...4
         moveIndex=i if pokemon.moves[i].id==move
       end
     end
     if moveIndex==-1
       # Look for slot to replace move
       for i in 0...4
         if (pokemon.moves[i].id==0 && move!=0) || (
             pokemon.moves[i].id!=move1 &&
             pokemon.moves[i].id!=move2 &&
             pokemon.moves[i].id!=move3 &&
             pokemon.moves[i].id!=move4)
           # Replace move
           pokemon.moves[i]=PBMove.new(move)
           break
         end
       end
     end
  }
end



class PokeBattle_Pokemon
  attr_accessor :heartgauge
  attr_accessor :shadow
  attr_accessor :hypermode
  attr_accessor :savedev
  attr_accessor :savedexp
  attr_accessor :shadowmoves
  attr_accessor :shadowmovenum
  HEARTGAUGESIZE = 3840

  def hypermode
    return (self.heartgauge==0 || self.hp==0) ? false : @hypermode
  end

  def heartgauge
    @heartgauge=0 if !@heartgauge
    return @heartgauge
  end

  def heartStage()
    return 0 if !@shadow
    hg=HEARTGAUGESIZE/5.0
    return ([self.heartgauge,HEARTGAUGESIZE].min/hg).ceil
  end

  def adjustHeart(value)
    if @shadow
      @heartgauge=0 if !@heartgauge
      @heartgauge+=value
      @heartgauge=HEARTGAUGESIZE if @heartgauge>HEARTGAUGESIZE
      @heartgauge=0 if @heartgauge<0
    end
  end

  def isShadow?
    return @heartgauge && @heartgauge>=0 && @shadow
  end

  def makeShadow
    self.shadow=true
    self.heartgauge=HEARTGAUGESIZE
    self.savedexp=0
    self.savedev=[0,0,0,0,0,0]
    self.shadowmoves=[0,0,0,0,0,0,0,0]
    # Retrieve shadow moves
    moves=load_data("Data/shadowmoves.dat") rescue []
    if moves[self.species] && moves[self.species].length>0
      for i in 0...[4,moves[self.species].length].min
        self.shadowmoves[i]=moves[self.species][i]
      end
      self.shadowmovenum=moves[self.species].length
    else
      # No special shadow moves
      self.shadowmoves[0]=getConst(PBMoves,:SHADOWRUSH)||0
      self.shadowmovenum=1
    end
    for i in 0...4 # Save old moves
      self.shadowmoves[4+i]=self.moves[i].id
    end
    pbUpdateShadowMoves
  end

  def pbUpdateShadowMoves(allmoves=false)
    if @shadowmoves
      m=@shadowmoves
      if !@shadow
        # No shadow moves
        pbReplaceMoves(self,m[4],m[5],m[6],m[7])
        @shadowmoves=nil
      else
        moves=[]
        relearning=[3,3,2,1,1,0][heartStage]
        relearning=3 if allmoves
        relearned=0
        # Add all Shadow moves
        for i in 0...4; moves.push(m[i]) if m[i]!=0; end
        # Add X regular moves
        for i in 0...4
          next if i<@shadowmovenum
          if m[i+4]!=0 && relearned<relearning
            moves.push(m[i+4]); relearned+=1
          end
        end
        pbReplaceMoves(self,moves[0]||0,moves[1]||0,moves[2]||0,moves[3]||0)
      end
    end
  end

  alias :__shadow_expeq :exp=

  def exp=(value)
    if self.isShadow?
      @savedexp+=value-self.exp
    else
      __shadow_expeq(value)
    end
  end

  alias :__shadow_hpeq :hp=

  def hp=(value)
     __shadow_hpeq(value)
     @hypermode=false if value<=0
  end
end



def pbReadyToPurify(pokemon)
  return if !pokemon || !pokemon.isShadow?
  pokemon.pbUpdateShadowMoves() 
  if pokemon.heartgauge==0
    Kernel.pbMessage(_INTL("{1} can now be purified!",pokemon.name))
  end
end

Events.onStepTaken+=proc{
   for pkmn in $Trainer.party
     if pkmn.hp>0 && !pkmn.isEgg? && pkmn.heartgauge>0
       pkmn.adjustHeart(-1)
       pbReadyToPurify(pkmn) if pkmn.heartgauge==0
     end
   end
   if ($PokemonGlobal.purifyChamber rescue nil)
     $PokemonGlobal.purifyChamber.update
   end
   for i in 0...2
     pkmn=$PokemonGlobal.daycare[i][0]
     next if !pkmn
     pkmn.adjustHeart(-1)
     pkmn.pbUpdateShadowMoves()
   end
}


=begin
All types except Shadow have Shadow as a weakness
Shadow has Shadow as a resistance.
On a side note, the Shadow moves in Colosseum will not be affected by Weaknesses or Resistances while in XD, the Shadow Type is Super Effective against all other types.
2/5 - display nature

XD - Shadow Rush -- 55, 100 - Deals damage. 
Colosseum - Shadow Rush -- 90, 100
If this attack is successful, user loses half of HP lost by opponent due to this attack (recoil).
 If user is in Hyper Mode, this attack has a good chance for a critical hit.
=end


class PokeBattle_Battle
  alias __shadow_pbUseItemOnPokemon pbUseItemOnPokemon

  def pbUseItemOnPokemon(item,pkmnIndex,userPkmn,scene,*arg)
    pokemon=self.party1[pkmnIndex]
    if pokemon.hypermode &&
       !isConst?(item,PBItems,:JOYSCENT) &&
       !isConst?(item,PBItems,:EXCITESCENT) &&
       !isConst?(item,PBItems,:VIVIDSCENT)
      scene.pbDisplay(_INTL("This item can't be used on that Pokémon."))
      return false
    end
    return __shadow_pbUseItemOnPokemon(item,pkmnIndex,userPkmn,scene,*arg)
  end
end



class PokeBattle_Battler
  alias __shadow_pbInitPokemon pbInitPokemon

  def pbInitPokemon(*arg)
    if self.pokemonIndex>0 && self.inHyperMode? && !isFainted?
      # Called out of hypermode
      self.pokemon.hypermode=false
      self.pokemon.adjustHeart(-50)
    end
    __shadow_pbInitPokemon(*arg)
    # Called into battle
    if self.isShadow?
      if hasConst?(PBTypes,:SHADOW)
        self.type1=getID(PBTypes,:SHADOW)
        self.type2=getID(PBTypes,:SHADOW)
      end
      self.pokemon.adjustHeart(-30) if @battle.pbOwnedByPlayer?(@index)
    end
  end

  alias __shadow_pbEndTurn pbEndTurn

  def pbEndTurn(*arg)
    __shadow_pbEndTurn(*arg)
    if self.inHyperMode? && !self.battle.pbAllFainted?(self.battle.party1) && 
       !self.battle.pbAllFainted?(self.battle.party2)
      self.battle.pbDisplay(_INTL("Its hyper mode attack hurt {1}!",self.pbThis(true))) 
      pbConfusionDamage
    end
  end

  def isShadow?
    p=self.pokemon
    if p && p.respond_to?("heartgauge") && p.heartgauge>0
      return true
    end
    return false
  end

  def inHyperMode?
    return false if isFainted?
    p=self.pokemon
    if p && p.respond_to?("hypermode") && p.hypermode
      return true
    end
    return false
  end

  def pbHyperMode
    p=self.pokemon
    if p.isShadow? && !p.hypermode && ((@battle.pbOwnedByPlayer?(@index)) || (!@battle.pbOwnedByPlayer?(@index) && $game_variables[646]<1))
      if @battle.pbRandom(p.heartgauge)<=PokeBattle_Pokemon::HEARTGAUGESIZE/4
        p.hypermode=true
        @battle.pbDisplay(_INTL("{1}'s emotions rose to a fever pitch!\nIt entered Hyper Mode!",self.pbThis))
      end
    end
  end

  def pbHyperModeObedience(move)
    return true if !move
    if self.inHyperMode? && !isConst?(move.type,PBTypes,:SHADOW)
      return rand(10)<8 ? false : true
    end
    return true
  end
end



################################################################################
# No additional effect. (Shadow Blast, Shadow Blitz, Shadow Break, Shadow Rave,
# Shadow Rush, Shadow Wave)
################################################################################
class PokeBattle_Move_126 < PokeBattle_Move_000
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbHyperMode if ret>=0
    return ret
  end
end



################################################################################
# Paralyzes the target. (Shadow Bolt)
################################################################################
class PokeBattle_Move_127 < PokeBattle_Move_007
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbHyperMode if ret>=0
    return ret
  end
end



################################################################################
# Burns the target. (Shadow Fire)
################################################################################
class PokeBattle_Move_128 < PokeBattle_Move_00A
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbHyperMode if ret>=0
    return ret
  end
end



################################################################################
# Freezes the target. (Shadow Chill)
################################################################################
class PokeBattle_Move_129 < PokeBattle_Move_00C
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbHyperMode if ret>=0
    return ret
  end
end



################################################################################
# Confuses the target. (Shadow Panic)
################################################################################
class PokeBattle_Move_12A < PokeBattle_Move_013
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbHyperMode if ret>=0
    return ret
  end
end



################################################################################
# Decreases the target's Defense by 2 stages. (Shadow Down)
################################################################################
class PokeBattle_Move_12B < PokeBattle_Move_04C
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbHyperMode if ret>=0
    return ret
  end
end



################################################################################
# Decreases the target's evasion by 2 stages. (Shadow Mist)
################################################################################
class PokeBattle_Move_12C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::EVASION,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::EVASION,2,false)
    attacker.pbHyperMode if ret
    return ret ? 0 : -1
  end
end



################################################################################
# Power is doubled if the target is using Dive. (Shadow Storm)
################################################################################
class PokeBattle_Move_12D < PokeBattle_Move_075
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbHyperMode if ret>=0
    return ret
  end
end



################################################################################
# Two turn attack.  On first turn, halves the HP of all active Pokémon.
# Skips second turn (if successful). (Shadow Half)
################################################################################
class PokeBattle_Move_12E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    affected=[]
    for i in 0...4
      affected.push(i) if @battle.battlers[i].hp>1
    end
    if affected.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in affected
      @battle.battlers[i].pbReduceHP((@battle.battlers[i].hp/2).floor)
    end
    @battle.pbDisplay(_INTL("Each Pokémon's HP was halved!"))
    attacker.effects[PBEffects::HyperBeam]=2
    attacker.currentMove=@id
    return 0
  end
end



################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
# (Shadow Hold)
################################################################################
class PokeBattle_Move_12F < PokeBattle_Move_0EF
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbHyperMode if ret>=0
    return ret
  end
end



################################################################################
# User takes recoil damage equal to 1/2 of its current HP. (Shadow End)
################################################################################
class PokeBattle_Move_130 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !(attacker.hasWorkingAbility(:ROCKHEAD) || attacker.hasWorkingAbility(:MAGICGUARD))
      attacker.pbReduceHP([1,((attacker.hp+1)/2).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    attacker.pbHyperMode if ret>=0
    return ret
  end
end



################################################################################
# Starts shadow weather. (Shadow Sky)
################################################################################
class PokeBattle_Move_131 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.weather==PBWeather::SHADOWSKY
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.weather=PBWeather::SHADOWSKY
    @battle.weatherduration=5
    @battle.weatherduration=8 if $fefieldeffect==43
    @battle.pbCommonAnimation("ShadowSky",nil,nil)
    @battle.pbDisplay(_INTL("A shadow sky appeared!"))
    return 0
  end
end



################################################################################
# Ends the effects of Light Screen, Reflect and Safeguard on both sides.
# (Shadow Shed)
################################################################################
class PokeBattle_Move_132 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.sides[0].effects[PBEffects::Reflect]>0 ||
       @battle.sides[1].effects[PBEffects::Reflect]>0 ||
       @battle.sides[0].effects[PBEffects::LightScreen]>0 ||
       @battle.sides[1].effects[PBEffects::LightScreen]>0 ||
       @battle.sides[0].effects[PBEffects::Safeguard]>0 ||
       @battle.sides[1].effects[PBEffects::Safeguard]>0
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      @battle.sides[0].effects[PBEffects::Reflect]=0
      @battle.sides[1].effects[PBEffects::Reflect]=0
      @battle.sides[0].effects[PBEffects::LightScreen]=0
      @battle.sides[1].effects[PBEffects::LightScreen]=0
      @battle.sides[0].effects[PBEffects::Safeguard]=0
      @battle.sides[1].effects[PBEffects::Safeguard]=0
      @battle.pbDisplay(_INTL("It broke all barriers!"))
      attacker.pbHyperMode
      return 0
    else
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end