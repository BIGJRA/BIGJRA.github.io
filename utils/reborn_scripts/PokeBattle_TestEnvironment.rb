
class PokeBattle_Battle
	attr_accessor(:items2)           # Items held by opponents
	attr_accessor(:sides)             # Effects common to each side of a battle
	def testAllMoves
		internalbefore = $INTERNAL ; $INTERNAL=false
		tester = @battlers[1]
		Kernel.echo("Initiating testing all moves, this will be painful \n")
		$cache.pkmn_moves = load_data("Data/attacksRS.dat") if !$cache.pkmn_moves
		startTime=Time.now
		1.step(694,4) { |i|
			tester.moves[0]= PokeBattle_Move.pbFromPBMove(self,PBMove.new(i),tester) unless i>694
			tester.moves[1]= PokeBattle_Move.pbFromPBMove(self,PBMove.new(i+1),tester) unless i+1>694
			tester.moves[2]= PokeBattle_Move.pbFromPBMove(self,PBMove.new(i+2),tester) unless i+2>694
			tester.moves[3]= PokeBattle_Move.pbFromPBMove(self,PBMove.new(i+3),tester) unless i+3>694
			begin
				for i in 0...4
					#AI CHANGES
					pbDefaultChooseEnemyCommand(i) if (!pbOwnedByPlayer?(i) || @controlPlayer) && !@battlers[i].isFainted? && pbCanShowCommands?(i)
				end
				@scene.pbChooseEnemyCommand
				#AI Data collection perry
				#for i in 0...4
				#	logAIScorings($ai_log_data[i]) if @battlers[i].hp > 0 && !pbOwnedByPlayer?(i)
				#end
			rescue
				PBDebug.log("**Exception: #{$!.message}")
				PBDebug.log("#{$!.backtrace.inspect}")
				pbPrintException($!)
			end
		}
		endTime=Time.now
		$stdout.print("It takes #{endTime-startTime} seconds for this one loop")
		$INTERNAL=internalbefore
	end

	def testAllBattlesSingles(canlose)
    #========================
		# Initialize AI in battle 
		#========================
		#AI CHANGES
		@ai = PokeBattle_AI.new(self)
		#AI data collection perry
		$ai_log_data = [PokeBattle_AI_Info.new,PokeBattle_AI_Info.new,PokeBattle_AI_Info.new,PokeBattle_AI_Info.new]

		sendout=pbFindNextUnfainted(@party2,0)
		trainerpoke=@party2[sendout]
		@scene.pbStartBattle(self)

		@battlers[1].pbInitialize(trainerpoke,sendout,false) 
		pbSendOut(1,trainerpoke)
		#====================================
		# Initialize player in single battles
		#====================================
		sendout=pbFindNextUnfainted(@party1,0)
		playerpoke=@party1[sendout]
		@battlers[0].pbInitialize(playerpoke,sendout,false) 
		pbSendOut(0,playerpoke)
		
		#==================
		# Initialize battle
		#==================
		pbOnActiveAll   # Abilities
		@turncount=0
		if !isOnline? #for subclassing- online processing continues separately
			loop do   # Now begin the battle loop
        break if @decision>0
				PBDebug.log("***Round #{@turncount+1}***") if $INTERNAL
				if $DEBUG && @turncount>=500
					@decision=pbDecisionOnTime()
					PBDebug.log("***[Undecided after 500 rounds]")
					break
				end
				#PBDebug.logonerr{
					pbCommandPhaseTEST
				#}
				break if @decision>0
				#PBDebug.logonerr{
					pbAttackPhaseTEST
				#}
				break if @decision>0
				#PBDebug.logonerr{
					pbEndOfRoundPhase
				#}
				break if @decision>0
				@turncount+=1
			end
			return pbEndOfBattle(canlose)
		end
	end

  def testAllBattlesDoubles(canlose)
    @ai = PokeBattle_AI.new(self)
    #AI data collection perry
    $ai_log_data = [PokeBattle_AI_Info.new,PokeBattle_AI_Info.new,PokeBattle_AI_Info.new,PokeBattle_AI_Info.new]
    @scene.pbStartBattle(self)
    pbDisplayBrief(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
    sendout1=pbFindNextUnfainted(@party2,0)
    sendout2=pbFindNextUnfainted(@party2,sendout1+1)
    @battlers[1].pbInitialize(@party2[sendout1],sendout1,false) 
    @battlers[3].pbInitialize(@party2[sendout2],sendout2,false) unless sendout2==-1
    pbDisplayBrief("Opponent sent out his Pokémon!") 
    pbSendOut(1,@party2[sendout1])
    pbSendOut(3,@party2[sendout2]) unless sendout2==-1
    #=====================================
    # Initialize players in double battles
    #=====================================
    sendout1=pbFindNextUnfainted(@party1,0)
    sendout2=pbFindNextUnfainted(@party1,sendout1+1)
    @battlers[0].pbInitialize(@party1[sendout1],sendout1,false) 
    @battlers[2].pbInitialize(@party1[sendout2],sendout2,false) unless sendout2==-1
    if sendout2>-1
      pbDisplayBrief(_INTL("Go! {1} and {2}!",@battlers[0].name,@battlers[2].name)) 
    else
      pbDisplayBrief(_INTL("Go! {1}!",@battlers[0].name)) 
    end
    pbSendOut(0,@party1[sendout1])
    pbSendOut(2,@party1[sendout2]) unless sendout2==-1
    #AI CHANGES
    
    pbOnActiveAll   # Abilities
    @turncount=0
    loop do   # Now begin the battle loop
      break if @decision>0
      PBDebug.log("***Round #{@turncount+1}***") if $INTERNAL
      if $DEBUG && @turncount>=500
        @decision=pbDecisionOnTime()
        PBDebug.log("***[Undecided after 500 rounds]")
        break
      end
      #PBDebug.logonerr{
        pbCommandPhaseTEST
      #}
      break if @decision>0
      #PBDebug.logonerr{
        pbAttackPhaseTEST
      #}
      break if @decision>0
      #PBDebug.logonerr{
        pbEndOfRoundPhase
      #}
      break if @decision>0
      @turncount+=1
    end
    return pbEndOfBattle(canlose)
  end

	def pbCommandPhaseTEST
		@scene.pbBeginCommandPhase
		@scene.pbResetCommandIndices
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
		@scene.pbChooseEnemyCommand
		switchTrainers
		@scene.pbChooseEnemyCommand
   
    for i in [1,3]
      next if !@doublebattle
      if @choices[i][0]==1
        @choices[i][3] = @choices[i][3]^1 if @choices[i][3] >= 0
      end
    end
		#for i in 0...4
		#	logAIScorings($ai_log_data[i]) if @battlers[i].hp > 0
		#end
		switchTrainers
    #for i in 0...4
		#	logAIScorings($ai_log_data[i]) if @battlers[i].hp > 0
		#end
	end

	def pbAttackPhaseTEST
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
            if j.status!=PBStatuses::SLEEP && j.status!=PBStatuses::FROZEN && (!j.hasWorkingAbility(:TRUANT) || !j.effects[PBEffects::Truant])
              #Try to Mega-evolve/Ultra-burst before using pursuit
              side=(pbIsOpposing?(j.index)) ? 1 : 0
              owner=pbGetOwnerIndex(j.index)
              if @megaEvolution[side][owner]==j.index
              pbMegaEvolve(j.index)
              end
              if @ultraBurst[side][owner]==i.index
              pbUltraBurst(i.index)
              end
              j.pbUseMove(@choices[j.index])
              j.effects[PBEffects::Pursuit]=true
              # UseMove calls pbGainEXP as appropriate
              @switching=false
              return if @decision>0
            end
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
		  if @choices[i.index][0]==3
			pbEnemyUseItem(@choices[i.index][1],i)
			i.itemUsed = true
			i.itemUsed2 = true
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
		# Use Attacks
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
		for i in priority
		  i.pbProcessTurn(@choices[i.index])
		  if i.effects[PBEffects::Round]
			  i.pbPartner.selectedMove = PBMoves::ROUND
		  end
		  return if @decision>0
		end
	end

	def switchTrainers
		#switch everything around so the ai can run again
		@player, @opponent = @opponent, @player
		@party1, @party2 = @party2, @party1
    @sides[0], @sides[1] = @sides[1], @sides[0]
    @items, @items2 = @items2, @items
    #Switching battlers 0 and 1 around
		@battlers[0], @battlers[1] = @battlers[1], @battlers[0]
		@battlers[0].index, @battlers[1].index = @battlers[1].index, @battlers[0].index
		@choices[0], @choices[1] = @choices[1], @choices[0]
		@megaEvolution[0], @megaEvolution[1] = @megaEvolution[1], @megaEvolution[0]
		@ultraBurst[0], @ultraBurst[1] = @ultraBurst[1], @ultraBurst[0]
		@zMove[0], @zMove[1] = @zMove[1], @zMove[0]
		@ai.aimondata[0], @ai.aimondata[1] = @ai.aimondata[1], @ai.aimondata[0]
    #switching 2 and 3 around
    @battlers[2], @battlers[3] = @battlers[3], @battlers[2]
    @battlers[2].index, @battlers[3].index = @battlers[3].index, @battlers[2].index
		@choices[2], @choices[3] = @choices[3], @choices[2]
		@ai.aimondata[2], @ai.aimondata[3] = @ai.aimondata[3], @ai.aimondata[2]
	end

	def pbSwitchInBetween(index,lax,cancancel)
		if !pbOwnedByPlayer?(index)
		  return @scene.pbChooseNewEnemy(index,pbParty(index))
		else
			switchTrainers
			ret=@scene.pbChooseNewEnemy(index^1,pbParty(index^1))
			switchTrainers
			return ret
		end
	end

	def pbGetOwnerItems(battlerIndex)
		if pbIsOpposing?(battlerIndex)
		  return [] if !@items
		  if @opponent.is_a?(Array)
			return (battlerIndex==1) ? @items[0] : @items[1]
		  else
			return @items
		  end
		else
			return [] if !@items2
			if @player.is_a?(Array)
				return (battlerIndex==1) ? @items2[0] : @items2[1]
			else
				return @items2
			end
		end
	end

  def pbAutoChooseMove(idxPokemon,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    if thispkmn.isFainted?
      @choices[idxPokemon][0]=0
      @choices[idxPokemon][1]=0
      @choices[idxPokemon][2]=nil
      return
    end
    if thispkmn.effects[PBEffects::Encore]>0 &&
       pbCanChooseMove?(idxPokemon,thispkmn.effects[PBEffects::EncoreIndex],false)
      PBDebug.log("[Auto choosing Encore move...]") if $INTERNAL
      @choices[idxPokemon][0]=1    # "Use move"
      @choices[idxPokemon][1]=thispkmn.effects[PBEffects::EncoreIndex] # Index of move
      @choices[idxPokemon][2]=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
      @choices[idxPokemon][3]=-1   # No target chosen yet
      if thispkmn.effects[PBEffects::EncoreMove] == PBMoves::ACUPRESSURE
        @choices[idxPokemon][3] = idxPokemon
      elsif @doublebattle
        thismove=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
        target=thispkmn.pbTarget(thismove)
        pbRegisterTarget(idxPokemon,target)
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

	def pbDisplay(msg)
		@scene.pbDisplayMessage(msg,true)
	end

	def pbDisplayPaused(msg)
		@scene.pbDisplayMessage(msg,true)
	end
	
	def pbDisplayBrief(msg)
		@scene.pbDisplayMessage(msg,true)
	end
	
	def pbDisplayConfirm(msg)
		@scene.pbDisplayMessage(msg,true)
	end

	def pbSetSeen(pokemon)
		return
	end
end

def pbTrainerBattleTEST(trainerid1,trainername1,trainerid2,trainername2,trainerparty1=0,trainerparty2=0,doublebattle=false,canlose=false)
	trainer=pbLoadTrainer(trainerid1,trainername1,trainerparty1)
	player=pbLoadTrainer(trainerid2,trainername2,trainerparty2)
	fullparty1=false
	scene=pbNewBattleScene
	battle=PokeBattle_Battle.new(scene,player[2],trainer[2],player[0],trainer[0])
	battle.party1.each {|pokemon| 
		pokemon.obedient=true
		pokemon.level = 100
		pokemon.calcStats
	}
	battle.party2.each {|pokemon| 
		pokemon.obedient=true
		pokemon.level = 100
		pokemon.calcStats
	}
	battle.fullparty1=fullparty1
	battle.doublebattle=doublebattle
	battle.endspeech=""
	battle.items=trainer[1]
	battle.items2=player[1]
	Events.onStartBattle.trigger(nil,nil)
	battle.internalbattle=true
	pbPrepareBattle(battle)
	decision=0
	pbBattleAnimation(nil,trainer[0].trainertype,trainer[0].name) { 
		pbSceneStandby {
      if !doublebattle
			  decision=battle.testAllBattlesSingles(canlose)
      else
        decision=battle.testAllBattlesDoubles(canlose)
      end
		}
		if decision==2 || decision==5
			for i in $Trainer.party; i.heal; end
		else
			Events.onEndBattle.trigger(nil,decision)
		end
	}
	Input.update
	return (decision==1)
end

def idontwanttobreakperryscode(trainer1,trainer2,doublebattle=false,canlose=false)
	trainer=trainershit(trainer1)
	player=trainershit(trainer2)
	fullparty1=false
	scene=pbNewBattleScene
	battle=PokeBattle_Battle.new(scene,player[2],trainer[2],player[0],trainer[0])
	battle.party1.each {|pokemon| 
		pokemon.obedient=true
		pokemon.level = 100
		pokemon.calcStats
	}
	battle.party2.each {|pokemon| 
		pokemon.obedient=true
		pokemon.level = 100
		pokemon.calcStats
	}
	battle.fullparty1=fullparty1
	battle.doublebattle=doublebattle
	battle.endspeech=""
	battle.items=trainer[1]
	battle.items2=player[1]
	Events.onStartBattle.trigger(nil,nil)
	battle.internalbattle=true
	pbPrepareBattle(battle)
	decision=0
	pbBattleAnimation(nil,trainer[0].trainertype,trainer[0].name) { 
		pbSceneStandby {
      if !doublebattle
			  decision=battle.testAllBattlesSingles(canlose)
      else
        decision=battle.testAllBattlesDoubles(canlose)
      end
		}
		if decision==2 || decision==5
			for i in $Trainer.party; i.heal; end
		else
			Events.onEndBattle.trigger(nil,decision)
		end
	}
	Input.update
	return (decision==1)
end

def trainershit(trainer)
  party=[]
  items=trainer[2].clone
  name=pbGetMessageFromHash(MessageTypes::TrainerNames,trainer[1])
  opponent=PokeBattle_Trainer.new(name,trainer[0])
  opponent.setForeignID($Trainer) if $Trainer
  for poke in trainer[3]
    species=poke[TPSPECIES]
    level=poke[TPLEVEL]
    pokemon=PokeBattle_Pokemon.new(species,level,opponent)
    pokemon.form=poke[TPFORM]
    pokemon.resetMoves
    pokemon.setItem(poke[TPITEM])
    if poke[TPMOVE1]>0 || poke[TPMOVE2]>0 || poke[TPMOVE3]>0 || poke[TPMOVE4]>0
      k=0
      for move in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
        pokemon.moves[k]=PBMove.new(poke[move])
        k+=1
      end
      pokemon.moves.compact!
    end
    pokemon.setAbility(poke[TPABILITY])
    pokemon.setGender(poke[TPGENDER])
    if poke[TPSHINY]   # if this is a shiny Pokémon
      pokemon.makeShiny
    else
      pokemon.makeNotShiny
    end
    pokemon.setNature(poke[TPNATURE])
    iv=poke[TPIV]
    if iv==32
      for i in 0...6
        pokemon.iv[i]=31
      end
      pokemon.iv[3]=0
    else
      for i in 0...6
        pokemon.iv[i]=iv&0x1F
      end
    end
    # New EV method
    evsum = poke[TPHPEV].to_i+poke[TPATKEV].to_i+poke[TPDEFEV].to_i+poke[TPSPEEV].to_i+poke[TPSPAEV].to_i+poke[TPSPDEV].to_i
    #if evsum<=510 && evsum>0
    if evsum>0 # What is an EV cap? PULSE2 away tbh
            pokemon.ev=[poke[TPHPEV].to_i,
                        poke[TPATKEV].to_i,
                        poke[TPDEFEV].to_i,
                        poke[TPSPEEV].to_i,
                        poke[TPSPAEV].to_i,
                        poke[TPSPDEV].to_i]
    elsif evsum == 0
      for i in 0...6
        pokemon.ev[i]=[85,level*3/2].min
      end
    end
    if $game_switches[:Only_Pulse_2] == true &&  ($game_switches[:Grinding_Trainer_Money_Cut] == false || $game_switches[:Penniless_Mode] == true) # pulse 2 mode
      for i in 0...6
        pokemon.ev[i]=252
      end
      for i in 0...6
        pokemon.iv[i]=31 if iv != 32
      end
    end
    pokemon.happiness=poke[TPHAPPINESS]
    pokemon.name=poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""
    if poke[TPSHADOW]   # if this is a Shadow Pokémon
      pokemon.makeShadow rescue nil
      pokemon.pbUpdateShadowMoves(true) rescue nil
      pokemon.makeNotShiny
    end
    pokemon.ballused=poke[TPBALL]
    pokemon.calcStats
    party.push(pokemon)
  end
  return [opponent,items,party]
end

def allTrainersBattle(startpoint=0,double_battle=false,filename="Everybody_battles.txt",field=0)
	$INTERNAL=false
	$game_variables[:Forced_Field_Effect] = field
	trainerlist = unhashTRlist
	current_iteration=-1
  output=[]
	begin
		for i in trainerlist
			for j in trainerlist
				current_iteration+=1
				next if current_iteration < startpoint
				trainer1 = i
				trainer2 = j
        #decision=pbTrainerBattleTEST(trainer1[0],trainer1[1],trainer2[0],trainer2[1],trainer1[4],trainer2[4],double_battle)
				decision=idontwanttobreakperryscode(trainer1,trainer2,double_battle)
				output.push([decision,trainer1[0],trainer1[1],trainer1[4],trainer2[0],trainer2[1],trainer2[4]])
        $stdout.print(output[-1].join(","),"   #{current_iteration}", "\n")
        #print "done #{current_iteration} iterations" if current_iteration % 1000 == 0 && current_iteration > startpoint
			end
		end
    File.open(filename,"w") {|f|
      for i in output
        f.write(i.join(','),"\n")
      end
    }
	rescue
		pbPrintException($!)
    File.open(filename,"w") {|f|
      for i in output
        f.write(i.join(','),"\n")
      end
    }
	end
  
	#$game_variables[:Forced_Field_Effect]=0
end

def bestTrainersBattle(startpoint=0,double_battle=false,filename="AIFights/Everybody_battles.txt",field=0,startingindex=0)
	$INTERNAL=false
	$game_variables[:Forced_Field_Effect] = field
  besttrainerlist = load_data("battle")
  if startingindex != 0
    for i in 0...startingindex
      besttrainerlist.delete_at(0)
    end
  end
	trainerlist = unhashTRlist
	current_iteration=startingindex*1100-1
  output=[]
	begin
		for i in besttrainerlist
			for j in trainerlist
				current_iteration+=1
				next if current_iteration < startpoint
				trainer1 = i[1]
				trainer2 = j
        #decision=pbTrainerBattleTEST(trainer1[0],trainer1[1],trainer2[0],trainer2[1],trainer1[4],trainer2[4],double_battle)
				decision=idontwanttobreakperryscode(trainer1,trainer2,double_battle)
				output.push([decision,trainer1[0],trainer1[1],trainer1[4],trainer2[0],trainer2[1],trainer2[4]])
        $stdout.print(output[-1].join(","),"   #{current_iteration}", "\n")
        #print "done #{current_iteration} iterations" if current_iteration % 1000 == 0 && current_iteration > startpoint
			end
      File.open(filename,"a+bz") {|f|
        for k in output
          f.write(k.join(','),"\n")
        end
      }
      output=[]
		end
	rescue
		pbPrintException($!)
    File.open(filename,"a+b") {|f|
      for k in output
        f.write(k.join(','),"\n")
      end
    }
	end
end

def idontwanttobreakperryscode2(party1, party2)
	fullparty1=false
	scene=pbNewBattleScene
  realparty1 = []
  realparty2 = []
  for mon in party1
    realparty1.push(mon.createPokemon(100,31,nil))
  end
  for mon in party2
    realparty2.push(mon.createPokemon(100,31,nil))
  end
	battle=PokeBattle_Battle.new(scene,realparty1,realparty2,PokeBattle_Trainer.new("deez nutz",5),PokeBattle_Trainer.new("deez other nutz",5))
	battle.party1.each {|pokemon| 
		pokemon.obedient=true
		pokemon.level = 100
		pokemon.calcStats
	}
	battle.party2.each {|pokemon| 
		pokemon.obedient=true
		pokemon.level = 100
		pokemon.calcStats
	}
	battle.fullparty1=fullparty1
	battle.endspeech=""
	battle.items=[]
	battle.items2=[]
	Events.onStartBattle.trigger(nil,nil)
	battle.internalbattle=true
	pbPrepareBattle(battle)
	decision=0
	pbBattleAnimation(nil,5,"deez nuts") { 
		pbSceneStandby {
      decision=battle.testAllBattlesSingles(false)
		}
		if decision==2 || decision==5
			for i in $Trainer.party; i.heal; end
		else
			Events.onEndBattle.trigger(nil,decision)
		end
	}
	Input.update
	return (decision==1)
end

def battleTowerRanking
  $INTERNAL=false
  Graphics.frame_rate=200
	$game_variables[:Forced_Field_Effect] = 0
  bttrainers = load_data("Data/trainerlists.dat")
  for tr in bttrainers
    if tr[5] # is default list
      btmons = tr[1]
    end
  end
  outputdata = []
  monscores = []
  for i in 0...btmons.length
    monscores.push([btmons[i],5000,0,0,0])
    #score,rounds,wins,losses
  end
  battlecount = 0
  numberarray = (0..btmons.length).to_a
  loop do
    
    #pick 6 mons
    choices = []
    while choices.length < 6
      choice = rand(btmons.length)
      choices.push(choice) if !choices.include?(choice)
    end
    team1 = []
    team2 = []
    for i in [0,1,2]
      choice = choices[i]
      team1.push(monscores[choice][0])
    end
    for i in [3,4,5]
      choice = choices[i]
      team2.push(monscores[choice][0])
    end
    decision = idontwanttobreakperryscode2(team1,team2)
    team1avg = ([monscores[choices[0]][1],monscores[choices[1]][1],monscores[choices[2]][1]].sum/3).round
    team2avg = ([monscores[choices[3]][1],monscores[choices[4]][1],monscores[choices[5]][1]].sum/3).round
    scorechanges = []
    team1best = team1avg > team2avg
    scoreoffset = ([((team1avg - team2avg).abs)*0.03,28].min).round
    #weight scores
=begin
    if !decision #team 2 wins
      for i in [0,1,2]
        diff = monscores[choices[i]][1] - team2avg
        if diff > 0 # lost to someone worse
          scorechanges.push([16+diff*0.04,30].min.round)
        else # lost to someone better
          scorechanges.push([16-diff*-0.04,2].max.round)
        end
      end
      for i in [3,4,5]
        diff = monscores[choices[i]][1] - team1avg
        if diff > 0 # beat someone worse
          scorechanges.push([16-diff*0.04,2].max.round)
        else # beat someone better
          scorechanges.push([16+diff*-0.04,30].min.round)
        end
      end
    else #team 1 wins
      for i in [0,1,2]
        diff = monscores[choices[i]][1] - team2avg
        if diff > 0 # beat someone worse
          scorechanges.push([16-diff*0.04,2].max.round)
        else # beat someone better
          scorechanges.push([16+diff*-0.04,30].min.round)
        end
      end
      for i in [3,4,5]
        diff = monscores[choices[i]][1] - team1avg
        if diff > 0 # lost to someone worse
          scorechanges.push([16+diff*0.04,30].min.round)
        else # lost to someone better
          scorechanges.push([16-diff*-0.04,2].max.round)
        end
      end
    end
=end
    #update scores
    if !decision #team 2 wins
      scoreoffset*= -1 if team1best
      for i in [0,1,2]
        monscores[choices[i]][1] -= (32+scoreoffset)
        monscores[choices[i]][2] += 1
        monscores[choices[i]][4] += 1
      end
      for i in [3,4,5]
        monscores[choices[i]][1] += (32-scoreoffset)
        monscores[choices[i]][2] += 1
        monscores[choices[i]][3] += 1
      end
    else #team 1 wins
      for i in [0,1,2]
        monscores[choices[i]][1] += (32+scoreoffset)
        monscores[choices[i]][2] += 1
        monscores[choices[i]][3] += 1
      end
      for i in [3,4,5]
        monscores[choices[i]][1] -= (32-scoreoffset)
        monscores[choices[i]][2] += 1
        monscores[choices[i]][4] += 1
      end
    end
    battlecount += 1
    puts battlecount if battlecount % 10 == 0
    if battlecount % 1000 == 0
      outputdata.push(monscores)
      for mon in monscores
        puts mon[0].species,mon[1]
      end
      save_data(outputdata,"btmon scores")
    end
  end
end

def dumpbtmons
  btmon = load_data("btmon scores")
  for k in btmon[-1]
    k[0] = PBSpecies.getName(k[0].species)
  end
  File.open("btmon scores.csv","w") {|f|
    for k in btmon[-1]
      f.write(k.join(','),"\n")
    end
  }
  print "done"
end

def pbAllFields
  double_battle=false #Kernel.pbConfirmMessage("Do you want it to be double battle?")
  for field in 0...38
    #CP_Profiler.begin
    filename = sprintf("AIFights/Everybody_battles %s.txt",FIELDEFFECTS[field][:FIELDNAME])
    next if File.exist?(filename)
    File.open(filename,"w"){}
    System.window_title="Field #{field}"
    Graphics.frame_rate=200
    bestTrainersBattle(0,double_battle,filename,field)
    #CP_Profiler.print
  end
  Input.text_input = true
  field = Kernel.pbMessageFreeText(_INTL("What field would you like to run?"),"",false,999,500)
  Input.text_input = false
  field = field.to_i
  filename = sprintf("AIFights/Everybody_battles %s.txt",FIELDEFFECTS[field][:FIELDNAME])
  count = 0
  System.window_title="Field #{field}"
  Graphics.frame_rate=200
  File.open(filename) {|f| count = f.read.count("\n")}
  System.window_title="Field #{field}"
  Graphics.frame_rate=200
  maintrainerindex = count / 1100
  bestTrainersBattle(0,double_battle,filename,field,maintrainerindex)
end

def specificTrainer(startpoint=0,filename="Specific_Battle.txt")
  battle=pbListScreen(_INTL("SINGLE TRAINER"),TrainerBattleLister.new(0,false))
  if battle
    trainerdata=battle[1]
  end
  #battle=pbListScreen(_INTL("SINGLE TRAINER"),TrainerBattleLister.new(0,false))
  #if battle
  #  trainerdata2=battle[1]
  #end
	$INTERNAL=false
  params=ChooseNumberParams.new
  params.setRange(0,37)
  params.setInitialValue(0)
  params.setCancelValue(0)
	$game_variables[:Forced_Field_Effect]=Kernel.pbMessageChooseNumber("Choose the field effect for the battles.",params)
  double_battle=Kernel.pbConfirmMessage("Do you want it to be double battle?")
  trainerlist = unhashTRlist
	begin
    current_iteration=-1
		for i in trainerlist
      current_iteration+=1
      next if current_iteration < startpoint
      trainer2 = i
      decision=pbTrainerBattleTEST(trainerdata[0],trainerdata[1],trainer2[0],trainer2[1],trainerdata[4],trainer2[4],double_battle)
      File.open(filename,"a+b") {|f|
        f.write(decision,',',trainerdata[0],',',trainerdata[1],',',trainerdata[4],',',trainer2[0],',',trainer2[1],',',trainer2[4])
        f.write("\n")
      }
      $stdout.print("#{decision}, #{trainerdata[0]}, #{trainerdata[1]}, #{trainerdata[4]}, #{trainer2[0]}, #{trainer2[1]}, #{trainer2[4]}     #{current_iteration} \n")
		end
    File.open(filename,"a+b") {|f|
      f.write("\n")
    }
	rescue
		pbPrintException($!)
	end
	$game_variables[:Forced_Field_Effect]=0
end

def random_battles
  #function for finding stack overflows
  #set_trace_func proc {
  #  |event, file, line, id, binding, classname| 
  #  if event == "call"  && caller_locations.length > 500
  #    print caller
  #    fail "stack level too deep"
  #  end
  #}
  # function for finding infinite loops
  #$counter=0
  #set_trace_func proc {
  #  |event, file, line, id, binding, classname| 
  #  $counter+=1
  #  if event == "call" && $counter % 100 == 0
  #    puts caller_locations[0,5]
  #  end
  #}
  $INTERNAL=false
  trainerlist = unhashTRlist
  trainer1 = pbLoadTrainer(trainerlist[-1][0],trainerlist[-1][1],trainerlist[-1][4])
  trainer2 = pbLoadTrainer(trainerlist[-1][0],trainerlist[-1][1],trainerlist[-1][4])
  choosablemoves = Array.new(PBMoves.maxValue+1) {|i| i}-[302,691,692,693,694]
  begin
    loop do
      #set randon variable for reproduce-ability
      randvar = rand(1e20)
      srand(randvar)
      $stdout.print("#{randvar} \n")
      #Make the pokemon random
      [trainer1[2],trainer2[2]].each {|trainer| trainer.each {|mon| 
          mon.species = 1 + rand(807)
          mon.item = 1 + rand(PBItems.maxValue)
          mon.ability = 1 + rand(PBAbilities.maxValue)
          #mon.moves.map!.with_index {|move,index| index!=0 ? PBMove.new(0) : PBMove.new(choosablemoves.sample)}
          mon.moves.map! {|move| PBMove.new(choosablemoves.sample)}
          mon.heal
          mon.calcStats
        }
      }
      #field random
      $game_variables[:Forced_Field_Effect]= 1 + rand(37)
      #trainer skill random
      trainer1[0].skill = 100#rand(1..100)
      trainer1[0].skill = 100#rand(1..100)
      #start battle
      fullparty1=false
      scene=pbNewBattleScene
      battle=PokeBattle_Battle.new(scene,trainer1[2],trainer2[2],trainer1[0],trainer2[0])
      battle.party1.each {|pokemon| 
        pokemon.obedient=true
        pokemon.level = 100#rand(1..100)
        pokemon.calcStats
      }
      battle.party2.each {|pokemon| 
        pokemon.obedient=true
        pokemon.level = 100#rand(1..100)
        pokemon.calcStats
      }
      battle.fullparty1=fullparty1
      battle.doublebattle=true
      battle.endspeech=""
      battle.items=trainer2[1]
      battle.items2=trainer1[1]
      Events.onStartBattle.trigger(nil,nil)
      battle.internalbattle=true
      pbPrepareBattle(battle)
      decision=0
      pbBattleAnimation(nil,trainer2[0].trainertype,trainer2[0].name) { 
        pbSceneStandby {
          if !battle.doublebattle
            decision=battle.testAllBattlesSingles(true)
          else
            decision=battle.testAllBattlesDoubles(true)
          end
        }
        Events.onEndBattle.trigger(nil,decision)
      }
      Input.update
    end
  rescue
    pbPrintException($!)
    retry
  end
end

class PokeBattle_Pokemon
  attr_accessor :ability
end
class PokeBattle_Battler
	attr_accessor :index
	def pbThis(lowercase=false) return "" ; end
end
#=begin
class PokeBattle_Battle
  def pbGainEXP
    return
  end
end

class PokeBattle_Scene
  attr_accessor :abortable
  attr_reader :viewport
  attr_reader :sprites
  BLANK      = 0
  MESSAGEBOX = 1
  COMMANDBOX = 2
  FIGHTBOX   = 3

  def initialize
    @battle=nil
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @pkmnwindows=[nil,nil,nil,nil]
    @sprites={}
    @battlestart=true
    @messagemode=false
    @abortable=false
    @aborted=false
  end

  def pbUpdate
  end

  def pbGraphicsUpdate(shift=false,oppside=true,playerside=true)
  end

  def pbInputUpdate
    Input.update
  end

  def pbApplyBGSprite(sprite,filename)
  end

  def pbShowWindow(windowtype)
  end

  def pbSetMessageMode(mode)
  end

  def pbWaitMessage
  end

  def pbDisplay(msg,brief=false)
  end

  def pbDisplayMessage(msg,brief=false)
  end

  def pbDisplayPausedMessage(msg)
  end

  def pbDisplayConfirmMessage(msg)
    return pbShowCommands(msg,[_INTL("Yes"),_INTL("No")],1)==0
  end

  def pbShowCommands(msg,commands,defaultValue)
    return 0
  end

  def pbFrameUpdate(cw, update_cw=true)
  end

  def pbRefresh
  end

  def pbAddSprite(id,x,y,filename,viewport)
    sprite=IconSprite.new(x,y,viewport)
    if filename
      sprite.setBitmap(filename) rescue nil
    end
    @sprites[id]=sprite
    return sprite
  end

  def pbAddPlane(id,filename,viewport)
    sprite=AnimatedPlane.new(viewport)
    if filename
      sprite.setBitmap(filename)
    end
    @sprites[id]=sprite
    return sprite
  end

  def pbDisposeSprites
    pbDisposeSpriteHash(@sprites)
  end

  def pbBeginCommandPhase
    # Called whenever a new round begins.
    @battlestart=false
  end

  def pbShowOpponent(index)
    if @battle.opponent
      if @battle.opponent.is_a?(Array)
        trainerfile=pbTrainerSpriteFile(@battle.opponent[index].trainertype)
      else
        trainerfile=pbTrainerSpriteFile(@battle.opponent.trainertype)
      end
    else
      trainerfile="Graphics/Characters/trfront"
    end
    pbAddSprite("trainer",Graphics.width,PokeBattle_SceneConstants::FOETRAINER_Y,
       trainerfile,@viewport)
    if @sprites["trainer"].bitmap
      @sprites["trainer"].y-=@sprites["trainer"].bitmap.height
      @sprites["trainer"].z=8
    end
  end

  def pbHideOpponent
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.width)
    @sprites["helpwindow"].y=0
    @sprites["helpwindow"].x=0
    @sprites["helpwindow"].text=text
    @sprites["helpwindow"].visible=true
  end

  def pbHideHelp
    @sprites["helpwindow"].visible=false
  end

  def pbBackdrop
  end

  # Returns whether the party line-ups are currently appearing on-screen
  def inPartyAnimation?
    return true
  end

  def partyBetweenKO1(oppside=true)
  end

  def partyBetweenKO2(oppside=true)
  end

  # Shows the party line-ups appearing on-screen
  def partyAnimationUpdate(shift=false,oppside=true,playerside=true)
    return 
  end

  def pbStartBattle(battle)
    # Called whenever the battle begins
    @battle=battle
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @showingplayer=true
    @showingenemy=true
    @sprites.clear
    @viewport=Viewport.new(0,Graphics.height/2,Graphics.width,0)
    @viewport.z=99999
    @traineryoffset=(Graphics.height-320) # Adjust player's side for screen size
    @foeyoffset=(@traineryoffset*3/4).floor  # Adjust foe's side for screen size
    pbBackdrop
    #################
  end

  def pbEndBattle(result)
    @abortable=false
    pbShowWindow(BLANK)
    # Fade out all sprites
    pbBGMFade(1.0)
    pbFadeOutAndHide(@sprites)
    pbDisposeSprites
  end
  
  def pbDisableShadowTemp(battler)
  end
  
  def pbReAbleShadow(battler)
  end


  def pbRecall(battlerindex)
  end

  def pbTrainerSendOut(battlerindex,pkmn)
  end

  def pbSendOut(battlerindex,pkmn) # Player sending out Pokémon
  end

  def pbTrainerWithdraw(battle,pkmn)
    pbRefresh
  end

  def pbWithdraw(battle,pkmn)
    pbRefresh
  end

  def pbMoveString(move)
    ret=_INTL("{1}",move.name)
    typename=PBTypes.getName(move.type)
    if move.id>0
      ret+=_INTL(" ({1}) PP: {2}/{3}",typename,move.pp,move.totalpp)
    end
    return ret
  end

  def pbBeginAttackPhase
    pbSelectBattler(-1)
    pbGraphicsUpdate
  end

  def pbSafariStart
    @briefmessage=false
    @sprites["battlebox0"]=SafariDataBox.new(@battle,@viewport)
    @sprites["battlebox0"].appear
    loop do
      @sprites["battlebox0"].update
      pbGraphicsUpdate
      pbInputUpdate
      break if !@sprites["battlebox0"].appearing
    end
    pbRefresh
  end

  def pbResetCommandIndices
    @lastcmd=[0,0,0,0]
  end

  def pbResetMoveIndex(index)
    @lastmove[index]=0
  end

  def pbSafariCommandMenu(index)
    pbCommandMenuEx(index,[
       _INTL("What will\n{1} throw?",@battle.pbPlayer.name),
       _INTL("Ball"),
       _INTL("Bait"),
       _INTL("Rock"),
       _INTL("Run")
    ],2)
  end


  def pbCommandMenu(index)
    shadowTrainer=(hasConst?(PBTypes,:SHADOW) && @battle.opponent)
    ret=pbCommandMenuEx(index,[
       _INTL("What will\n{1} do?",@battle.battlers[index].name),
       _INTL("Fight"),
       _INTL("Bag"),
       _INTL("Pokémon"),
       shadowTrainer ? _INTL("Call") : _INTL("Run")
    ],(shadowTrainer ? 1 : 0))
    ret=4 if ret==3 && shadowTrainer   # Convert "Run" to "Call"
    return ret
  end

  def pbCommandMenuEx(index,texts,mode=0)      # Mode: 0 - regular battle
    pbShowWindow(COMMANDBOX)                   #       1 - Shadow Pokémon battle
    cw=@sprites["commandwindow"]               #       2 - Safari Zone
    cw.setTexts(texts)                         #       3 - Bug Catching Contest
    cw.index=@lastcmd[index]
    cw.mode=mode
    pbSelectBattler(index)
    pbRefresh
    update_menu=true
    loop do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(cw,update_menu)
      update_menu=false
      # Update selected command
      if Input.trigger?(Input::LEFT) && (cw.index&1)==1
        pbPlayCursorSE()
        cw.index-=1
        update_menu=true
      end
      if Input.trigger?(Input::RIGHT) &&  (cw.index&1)==0
        pbPlayCursorSE()
        cw.index+=1
        update_menu=true
      end
      if Input.trigger?(Input::UP) &&  (cw.index&2)==2
        pbPlayCursorSE()
        cw.index-=2
        update_menu=true
      end
      if Input.trigger?(Input::DOWN) &&  (cw.index&2)==0
        pbPlayCursorSE()
        cw.index+=2
        update_menu=true
      end
      if Input.trigger?(Input::C)   # Confirm choice
        pbPlayDecisionSE()
        ret=cw.index
        @lastcmd[index]=ret
        return ret
      elsif Input.trigger?(Input::B) && index==2 #&& @lastcmd[0]!=2 # Cancel #Commented out for cancelling switches in doubles
        pbPlayDecisionSE()
        return -1
      end
    end
  end


  def pbFightMenu(index)
    pbShowWindow(FIGHTBOX)
    cw = @sprites["fightwindow"]
    battler=@battle.battlers[index]
    cw.battler=battler
    lastIndex=@lastmove[index]
    if battler.moves[lastIndex].id!=0
      cw.setIndex(lastIndex)
    else
      cw.setIndex(0)
    end
    cw.megaButton=0 unless @battle.megaEvolution[(@battle.pbIsOpposing?(index)) ? 1 : 0][@battle.pbGetOwnerIndex(index)] == index && @battle.battlers[index].hasMega?
    cw.megaButton=1 if (@battle.pbCanMegaEvolve?(index) && !@battle.pbCanZMove?(index))
    cw.ultraButton=0
    cw.ultraButton=1 if @battle.pbCanUltraBurst?(index)
    cw.zButton=0
    cw.zButton=1 if @battle.pbCanZMove?(index)
    pbSelectBattler(index)
    pbRefresh
    update_menu = true
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw,update_menu)
      update_menu = false
      # Update selected command
      if Input.trigger?(Input::LEFT) && (cw.index&1)==1
        pbPlayCursorSE() if cw.setIndex(cw.index-1)
        update_menu=true
      end
      if Input.trigger?(Input::RIGHT) &&  (cw.index&1)==0
        pbPlayCursorSE() if cw.setIndex(cw.index+1)
        update_menu=true
      end
      if Input.trigger?(Input::UP) &&  (cw.index&2)==2
        pbPlayCursorSE() if cw.setIndex(cw.index-2)
        update_menu=true
      end
      if Input.trigger?(Input::DOWN) &&  (cw.index&2)==0
        pbPlayCursorSE() if cw.setIndex(cw.index+2)
        update_menu=true
      end
      if Input.trigger?(Input::C)   # Confirm choice
        ret=cw.index
        if cw.zButton==2
          if battler.pbCompatibleZMoveFromMove?(ret,true)
            pbPlayDecisionSE()
            @lastmove[index]=ret
            return ret
          else
            @battle.pbDisplay(_INTL("{1} is not compatible with {2}!",PBMoves.getName(battler.moves[ret]),PBItems.getName(battler.item)))
            @lastmove[index]=cw.index
            return -1
          end
        else
          pbPlayDecisionSE()
          @lastmove[index]=ret
          return ret
        end
      elsif Input.trigger?(Input::X)   # Use Mega Evolution
        if @battle.pbCanMegaEvolve?(index) && !pbIsZCrystal?(battler.item)
          @battle.pbRegisterMegaEvolution(index)
          cw.megaButton=2
          pbPlayDecisionSE()
        end
        if @battle.pbCanUltraBurst?(index)
          @battle.pbRegisterUltraBurst(index)
          cw.ultraButton=2
          pbPlayDecisionSE()
        end
        if @battle.pbCanZMove?(index)  # Use Z Move
          @battle.pbRegisterZMove(index)
          cw.zButton=2
          pbPlayDecisionSE()
        end
        update_menu=true
      elsif Input.trigger?(Input::B)   # Cancel fight menu
        @lastmove[index]=cw.index
        pbPlayCancelSE()
        return -1
      end
    end
  end


  def pbItemMenu(index)
    ret=0
    retindex=-1
    pkmnid=-1
    endscene=true
    oldsprites=pbFadeOutAndHide(@sprites)
    itemscene=PokemonBag_Scene.new
    itemscene.pbStartScene($PokemonBag)
    loop do
      item=itemscene.pbChooseItem
      break if item==0
      usetype=$cache.items[item][ITEMBATTLEUSE]
      cmdUse=-1
      commands=[]
      if usetype==0
        commands[commands.length]=_INTL("Cancel")
      else
        commands[cmdUse=commands.length]=_INTL("Use")
        commands[commands.length]=_INTL("Cancel")
      end
      itemname=PBItems.getName(item)
      command=itemscene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
      if cmdUse>=0 && command==cmdUse
        if usetype==1 || usetype==3
          modparty=[]
          for i in 0...6
            modparty.push(@battle.party1[@battle.partyorder[i]])
          end
          pkmnlist=PokemonScreen_Scene.new
          pkmnscreen=PokemonScreen.new(pkmnlist,modparty)
          itemscene.pbEndScene
          pkmnscreen.pbStartScene(_INTL("Use on which Pokémon?"),@battle.doublebattle)
          activecmd=pkmnscreen.pbChoosePokemon
          pkmnid=@battle.partyorder[activecmd]
          if activecmd!=-1 && !pbCanUseBattleItem(pkmnid, item, pkmnscreen)
          else
            if activecmd>=0 && pkmnid>=0 && ItemHandlers.hasBattleUseOnPokemon(item)
              pkmnlist.pbEndScene
              ret=item
              retindex=pkmnid
              endscene=false
              break
            end
          end
          pkmnlist.pbEndScene
          itemscene.pbStartScene($PokemonBag)
        elsif usetype==2 || usetype==4
          if ItemHandlers.hasBattleUseOnBattler(item)
            ret=item
            retindex=index
            break
          end
        end
      end
    end
    if ret > 0
      pbConsumeItemInBattle($PokemonBag,ret)
    end
    itemscene.pbEndScene if endscene
    pbFadeInAndShow(@sprites,oldsprites)
    return [ret,retindex]
  end


  def pbCanUseBattleItem(pkmnid, item, pkmnscreen)
    pokemon = @battle.party1[pkmnid]
    battler = false
    for i in @battle.battlers
      moncheck = i.pokemon
      if pokemon == moncheck
        battler=i
      end
    end
    if battler && battler.effects[PBEffects::SkyDrop]
      return false
    end
    if battler && battler.effects[PBEffects::Embargo]>0
      return false
    end
    return true if pokemon.hp < pokemon.totalhp && pokemon.hp>0 && PBStuff::HPITEMS.include?(item)
    return true if pokemon.status == PBStatuses::POISON && PBStuff::POISONITEMS.include?(item)
    return true if pokemon.status == PBStatuses::PARALYSIS && PBStuff::PARAITEMS.include?(item)
    return true if pokemon.status == PBStatuses::BURN && PBStuff::BURNITEMS.include?(item)
    return true if pokemon.status == PBStatuses::SLEEP && PBStuff::SLEEPITEMS.include?(item)
    return true if pokemon.status == PBStatuses::FROZEN && PBStuff::FREEZEITEMS.include?(item)
    return true if battler && battler.effects[PBEffects::Confusion]>0 && PBStuff::CONFUITEMS.include?(item)
    return true if pokemon.hp<=0 && PBStuff::REVIVEITEMS.include?(item)
    if PBStuff::PPITEMS.include?(item)
      ppcheck = false
      movecheck=false
      for i in pokemon.moves
        next if i.pp == i.totalpp
        movecheck = true
        break
      end
      if movecheck
        if ((item == PBItems::ETHER) || (item == PBItems::LEPPABERRY))
          move=pbChooseMove(pokemon,_INTL("Restore which move?"))
          if move>=0
            if pbBattleRestorePP(pokemon,battler,move,10)==0
              ppcheck=false
              pkmnscreen.pbDisplay(_INTL("It won't have any effect."))
            else
              return true #ppcheck=true
            end
          else
            ppcheck=false
          end
        elsif (item == PBItems::MAXETHER)
          move=pbChooseMove(pokemon,_INTL("Restore which move?"))
          if move>=0
            if pbBattleRestorePP(pokemon,battler,move,pokemon.moves[move].totalpp-pokemon.moves[move].pp)==0
              ppcheck=false
              pkmnscreen.pbDisplay(_INTL("It won't have any effect."))
            else
              return true #ppcheck=true
            end
          else
            ppcheck=false
          end
        else
          ppcheck = true
        end
      else
        pkmnscreen.pbDisplay(_INTL("It won't have any effect."))
      end
      return ppcheck
    end
    pkmnscreen.pbDisplay(_INTL("It won't have any effect."))
    return false
  end


  def pbForgetMove(pokemon,moveToLearn)
    ret=-1
    pbFadeOutIn(99999){
       scene=PokemonSummaryScene.new
       screen=PokemonSummary.new(scene)
       ret=screen.pbStartForgetScreen([pokemon],0,moveToLearn)
    }
    return ret
  end


  def pbChooseMove(pokemon,message)
    ret=-1
    pbFadeOutIn(99999){
       scene=PokemonSummaryScene.new
       screen=PokemonSummary.new(scene)
       ret=screen.pbStartChooseMoveScreen([pokemon],0,message)
    }
    return ret
  end

  def pbNameEntry(helptext,pokemon)
    return pbEnterPokemonName(helptext,0,12,"",pokemon)
  end

  def pbSelectBattler(index,selectmode=1)
  end

  def pbFirstTarget(index)
    for i in 0...4
      if i!=index && !@battle.battlers[i].isFainted? &&
         @battle.battlers[index].pbIsOpposing?(i)
        return i
      end
    end
    return -1
  end

  def pbAcupressureTarget(index)
    for i in 0...4
      if (index&1)==(i&1) && !@battle.battlers[i].isFainted?
         !@battle.battlers[index].pbIsOpposing?(i)
        return i
      end
    end
    return -1
  end

  def pbUpdateSelected(index)
  end


  def pbChooseTarget(index)
  end

  def pbChooseTargetAcupressure(index)
    return pbAcupressureTarget(index)
  end

  def pbSwitch(index,lax,cancancel)
    party=@battle.pbParty(index)
    partypos=@battle.partyorder
    ret=-1
    # Fade out and hide all sprites

    pbShowWindow(BLANK)
    pbSetMessageMode(true)
    modparty=[]
    for i in 0...6
      modparty.push(party[partypos[i]])
    end
    visiblesprites=pbFadeOutAndHide(@sprites)
    scene=PokemonScreen_Scene.new
    @switchscreen=PokemonScreen.new(scene,modparty)
    @switchscreen.pbStartScene(_INTL("Choose a Pokémon."),
       @battle.doublebattle && !@battle.fullparty1)
    loop do
      scene.pbSetHelpText(_INTL("Choose a Pokémon."))
      activecmd=@switchscreen.pbChoosePokemon
      if cancancel && activecmd==-1
        ret=-1
        break
      end
      if activecmd>=0
        commands=[]
        cmdShift=-1
        cmdSummary=-1
        pkmnindex=partypos[activecmd]
        commands[cmdShift=commands.length]=_INTL("Switch In") if !party[pkmnindex].isEgg?
        commands[cmdSummary=commands.length]=_INTL("Summary")
        commands[commands.length]=_INTL("Cancel")
        command=scene.pbShowCommands(_INTL("Do what with {1}?",party[pkmnindex].name),commands)
        if cmdShift>=0 && command==cmdShift
          canswitch=lax ? @battle.pbCanSwitchLax?(index,pkmnindex,true) :
             @battle.pbCanSwitch?(index,pkmnindex,true)
          if canswitch
            ret=pkmnindex
            break
          end
        elsif cmdSummary>=0 && command==cmdSummary
          scene.pbSummary(activecmd)
        end
      end
    end
    @switchscreen.pbEndScene
    @switchscreen=nil
    pbShowWindow(BLANK)
    pbSetMessageMode(false)
    # back to main battle screen
    pbFadeInAndShow(@sprites,visiblesprites)
    return ret
  end

  def pbDamageAnimation(pkmn,effectiveness)
  end


  def pbHPChanged(pkmn,oldhp,anim=false)
  end


  def pbFainted(pkmn)
    pkmn.pbResetForm

  end

  def pbVanishSprite(pkmn)
  end
  
  def pbUnVanishSprite(pkmn,fade=true)
  end
  
  def pbSubstituteSprite(pkmn,back)
  end
  
  def pbUnSubstituteSprite(pkmn,back)
  end
  

  def pbChooseEnemyCommand
    @battle.ai.processAIturn
  end


  def pbChooseNewEnemy(index,party)
    return @battle.ai.pbDefaultChooseNewEnemy(index,party)
  end

  def pbWildBattleSuccess
    pbBGMPlay(pbGetWildVictoryME())
  end


  def pbTrainerBattleSuccess
    
  end

  def pbEXPBar(pokemon,battler,startexp,endexp,tempexp1,tempexp2)
  end

  def pbShowPokedex(species)
  end

  def pbChangeSpecies(attacker,species)
  end

  def pbChangePokemon(attacker,pokemon)

  end

  def pbSaveShadows
	yield
  end

  def pbFindAnimation(moveid,userIndex,hitnum)
	return nil
  end

  def pbCommonAnimation(animname,user,target,hitnum=0)

  end

  def pbAnimation(moveid,user,target,hitnum=0)
	return
  end

  def pbAnimationCore(animation,user,target,oppmove=false)
    return
  end

  def pbLevelUp(pokemon,battler,oldtotalhp,oldattack,olddefense,oldspeed,
                oldspatk,oldspdef)
  end

  def pbThrowAndDeflect(ball,targetBattler)
  end

  def pbThrow(ball,shakes,critical,critsuccess,targetBattler,showplayer=false)
  end

  def pbThrowSuccess
  end

  def pbHideCaptureBall
  end

  def pbThrowBait

  end

  def pbThrowRock
  end
end

class PokeBattle_Pokemon
	def initialize(species,level,player=nil,withMoves=true)
		if species.is_a?(String) || species.is_a?(Symbol)
		  species=getID(PBSpecies,species)
		end
		if $game_switches[:Just_Budew]
		  species = PBSpecies::BUDEW
		elsif $game_switches[:Just_Vulpix]
      species = PBSpecies::VULPIX
    end
		group1=$cache.pkmn_dex[species][:EggGroups][0]
		group2=$cache.pkmn_dex[species][:EggGroups][1]
		time=pbGetTimeNow
		@timeReceived=time.getgm.to_i # Use GMT
		@species=species
		# Individual Values
		@personalID=rand(256)
		@personalID|=rand(256)<<8
		@personalID|=rand(256)<<16
		@personalID|=rand(256)<<24
		@hp=1
		@totalhp=1
		@ev=[0,0,0,0,0,0]
		@iv=[]
		if !(group1==15 || group2==15) && (species != 490) #undiscovered group or manaphy
		  @iv[0]=rand(32)
		  @iv[1]=rand(32)
		  @iv[2]=rand(32)
		  @iv[3]=rand(32)
		  @iv[4]=rand(32)
		  @iv[5]=rand(32)
		else
		  stat1=rand(6)
		  stat2=rand(6)
		  stat3=rand(6)
		  while stat1==stat2 do stat2=rand(6)
		  end
		  while (stat1==stat3) || (stat2==stat3) do stat3=rand(6)
		  end
		  for i in 0..5
        if i==stat1
          @iv[i]=31
        elsif i==stat2
          @iv[i]=31
        elsif i==stat3
          @iv[i]=31
        else
          @iv[i]=rand(32)
        end
		  end
		end
		if player
		  @trainerID=player.id
		  @ot=player.name
		  @otgender=2
		  @language=player.language
		else
		  @trainerID=0
		  @ot=""
		  @otgender=2
		end
		@happiness=$cache.pkmn_dex[@species][:Happiness]
		@name=PBSpecies.getName(@species)
		@eggsteps=0
		@status=0
		@statusCount=0
		@item=0
		@mail=nil
		@fused=nil
		#@ribbons=[]
		@moves=[]
		self.ballused=0
		self.level=level
		@poklevel = level
		calcStats
		@hp=@totalhp
		if $game_map
		  @obtainMap=$game_map.map_id
		  @obtainText=nil
		  @obtainLevel=level
		else
		  @obtainMap=0
		  @obtainText=nil
		  @obtainLevel=level
		end
		@obtainMode=0   # Met
		@obtainMode=4 if $game_switches[:Fateful_Encounter]
		@hatchedMap=0
		if withMoves
		  $cache.pkmn_moves = load_data("Data/attacksRS.dat") if !$cache.pkmn_moves
		  # Generating move list
		  movelist=[]
		  for k in 0...$cache.pkmn_moves[species].length
			alevel=$cache.pkmn_moves[species][k][0]
			move=$cache.pkmn_moves[species][k][1]
			if alevel<=level
			  movelist[k]=move
			end
		  end
		  movelist|=[] # remove duplicates
		  # Use the last 4 items in the move list
		  listend=movelist.length-4
		  listend=0 if listend<0
		  j=0
		  for i in listend...listend+4
			moveid=(i>=movelist.length) ? 0 : movelist[i]
			@moves[j]=PBMove.new(moveid)
			j+=1
		  end
		end
	  end
end

class PokeBattle_Trainer
	def initialize(name,trainertype)
		@name=name
		@language=2
		@trainertype=trainertype
		@id=rand(256)
		@id|=rand(256)<<8
		@id|=rand(256)<<16
		@id|=rand(256)<<24
		@metaID=0
		@outfit=0
		@pokegear=false
		@pokedex=false
		@badges=[]
		for i in 0...8
		  @badges[i]=false
		end
		@money=INITIALMONEY
		@party=[]
		@lastSave=""
		@saveNumber = 0
		@noOnlineBattle = false
		@storedOnlineParty=[]   
		@onlineMusic="Battle- Trainer.mp3"
	  end
end

def pbBattleAnimation(bgm=nil,trainerid=-1,trainername="")
	yield if block_given?
end

def pbWait
end

def pbSceneStandby
	yield
  end

def _INTL(*arg)
	return ""
end

def pbGetMessage(type,id)
  return ""
end
#=end