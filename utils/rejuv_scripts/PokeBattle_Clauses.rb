#===============================================================================
# This script modifies the battle system to implement battle rules.
#===============================================================================

class PokeBattle_Battle
  unless @__clauses__aliased
    alias __clauses__pbDecisionOnDraw pbDecisionOnDraw
    alias __clauses__pbEndOfRoundPhase pbEndOfRoundPhase
    @__clauses__aliased=true
  end

  def pbDecisionOnDraw()
    if @rules["selfkoclause"]
      if self.lastMoveUser<0
        # in extreme cases there may be no last move user
        return 5 # game is a draw
      elsif pbIsOpposing?(self.lastMoveUser)
        return 2 # loss
      else
        return 1 # win
      end
    end
    return __clauses__pbDecisionOnDraw()
  end

  def pbJudgeCheckpoint(attacker,move=nil)
    if @rules["drawclause"] # Note: Also includes Life Orb (not implemented)
      if !(move && move.function==0xDD) # Not a draw if fainting occurred due to Liquid Ooze
        if pbAllFainted?(@party1) && pbAllFainted?(@party2)
          @decision=pbIsOpposing?(@attacker.index) ? 1 : 2
        end
      end
    elsif @rules["modifiedselfdestructclause"] && move && 
       move.function==0xE0 # Selfdestruct
      if pbAllFainted?(@party1) && pbAllFainted?(@party2)
        @decision=pbIsOpposing?(@attacker.index) ? 1 : 2
      end
    end
  end

  def pbEndOfRoundPhase()
    __clauses__pbEndOfRoundPhase()
    if @rules["suddendeath"] && @decision==0
      if pbPokemonCount(@party1)>pbPokemonCount(@party2)
        @decision=1 # loss
      elsif pbPokemonCount(@party1)<pbPokemonCount(@party2)
        @decision=2 # win
      end
    end
  end
end



class PokeBattle_Battler
  unless @__clauses__aliased
    alias __clauses__pbCanSleep? pbCanSleep?
    alias __clauses__pbCanSleepYawn? pbCanSleepYawn?
    alias __clauses__pbCanFreeze? pbCanFreeze?
    alias __clauses__pbUseMove pbUseMove
    @__clauses__aliased=true
  end

  def pbHasStatusPokemon?(status)
    count=0
    party=@battle.pbParty(self.index)
    for i in 0...party.length
      if party[i] && !party[i].isEgg? &&
         party[i].status==status
        count+=1
      end
    end
    return (count>0)
  end

  def pbCanSleepYawn?()
    if (@battle.rules["sleepclause"] || @battle.rules["modifiedsleepclause"]) && 
       pbHasStatusPokemon?(PBStatuses::SLEEP)
      return false
    end
    return __clauses__pbCanSleepYawn?()
  end

  def pbCanFreeze?(*arg)
    if @battle.rules["freezeclause"] && 
       pbHasStatusPokemon?(PBStatuses::FROZEN)
      return false
    end
    return __clauses__pbCanFreeze?(*arg)
  end

  def pbCanSleep?(showMessages,selfsleep=false,ignorestatus=false)
    if ((@battle.rules["modifiedsleepclause"]) || (!selfsleep && @battle.rules["sleepclause"])) && 
       pbHasStatusPokemon?(PBStatuses::SLEEP) 
      if showMessages
        @battle.pbDisplay(_INTL("But {1} couldn't sleep!",self.pbThis(true)))
      end
      return false
    end
    return __clauses__pbCanSleep?(showMessages,selfsleep,ignorestatus)
  end
end



class PokeBattle_Move_022 # Double Team
  def pbMoveFailed(attacker,opponent)
    return true if @battle.rules["evasionclause"]
    return false
  end
end



class PokeBattle_Move_034 # Minimize
  def pbMoveFailed(attacker,opponent)
    return true if @battle.rules["evasionclause"]
    return false
  end
end



class PokeBattle_Move_067 # Skill Swap
  def pbMoveFailed(attacker,opponent)
    return true if @battle.rules["skillswapclause"]
    return false
  end
end



class PokeBattle_Move_06A # Sonicboom
  def pbMoveFailed(attacker,opponent)
    return true if @battle.rules["sonicboomclause"]
    return false
  end
end



class PokeBattle_Move_06B # Dragon Rage
  def pbMoveFailed(attacker,opponent)
    return true if @battle.rules["sonicboomclause"]
    return false
  end
end



class PokeBattle_Move_070 # OHKO moves
  def pbMoveFailed(attacker,opponent)
    return true if @battle.rules["ohkoclause"]
    return false
  end
end



class PokeBattle_Move_0E0 # Selfdestruct
  unless @__clauses__aliased
    alias __clauses__pbOnStartUse pbOnStartUse
    @__clauses__aliased=true
  end

  def pbOnStartUse(attacker)
    if @battle.rules["selfkoclause"]
      # Check whether no unfainted Pokemon remain in either party
      count=attacker.pbNonActivePokemonCount()
      count+=attacker.pbOppositeOpposing.pbNonActivePokemonCount()
      if count==0
        @battle.pbDisplay("But it failed!")
        return false
      end
    end
    if @battle.rules["selfdestructclause"]
      # Check whether no unfainted Pokemon remain in either party
      count=attacker.pbNonActivePokemonCount()
      count+=attacker.pbOppositeOpposing.pbNonActivePokemonCount()
      if count==0
        @battle.pbDisplay(_INTL("{1}'s team was disqualified!",attacker.pbThis))
        @battle.decision=@battle.pbIsOpposing?(attacker.index) ? 1 : 2 
        return false
      end
    end
    __clauses__pbOnStartUse(attacker)
  end
end



class PokeBattle_Move_0E5 # Perish Song
  def pbMoveFailed(attacker,opponent)
    if @battle.rules["perishsongclause"] && attacker.pbNonActivePokemonCount()==0
      return true
    end
    return false
  end
end



class PokeBattle_Move_0E7 # Destiny Bond
  def pbMoveFailed(attacker,opponent)
    if @battle.rules["perishsongclause"] && attacker.pbNonActivePokemonCount()==0
      return true
    end
    return false
  end
end