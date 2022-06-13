class AI_MonData
	attr_accessor	:index		#To help ensure we keep the right data with the right battler
	attr_accessor	:roles		#This is for roles that belong to the current battler
	attr_accessor	:trainer
	attr_accessor	:partyroles  #This is for roles that belong to the entire party
	attr_accessor	:skill
	attr_accessor	:party
	attr_accessor	:scorearray
	attr_accessor	:roughdamagearray
	attr_accessor	:itemscore
	attr_accessor	:shouldswitchscore
	attr_accessor	:switchscore
	attr_accessor	:shouldMegaOrUltraBurst
	attr_accessor	:zmove
	attr_accessor	:attitemworks
	attr_accessor	:oppitemworks


	def initialize(trainer, index,battle)
		@trainer	= trainer
		@index 		= index
		@skill 		= trainer.nil? ? 0 : trainer.skill
		@party 		= trainer.nil? ? [] : battle.pbPartySingleOwner(index)
		@roles 		= []
		#fuckin double battles
		#there are four move arrays, but one of them doesn't get used depending on the index of the aimon
		@scorearray = [[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]
		@roughdamagearray = [[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]	#again, for doubles...
		@itemscore = {}
		@switchscore = []
		@shouldswitchscore = -10000
		@shouldMegaOrUltraBurst = false
		@zmove = nil
		@attitemworks = true
		@oppitemworks = true
	end
end

class PokeBattle_AI
	attr_accessor		:battle					#Current battle the AI is pulling from 			(PokeBattle_Battle)
	attr_accessor		:move					#Current move being scored						(PokeBattle_Move)
	attr_accessor		:attacker				#User of the current move being scored			(PokeBattle_Battler)
	attr_accessor		:opponent				#Opposing pokemon that the move will be used on	(PokeBattle_Battler)
	attr_accessor		:aimondata				#Array of all trainers in the battle			(AI_PokemonData)
	attr_accessor		:mondata				#Current trainer being processed				(AI_PokemonData)
	attr_accessor		:miniscore				#holder for the miniscore						#Number
	attr_accessor		:score					#holder for the score-score						#Number
	attr_accessor		:index					#index of the battler being evaluated			#Number
	attr_accessor		:aiMoveMemory			#Moves the AI knows about						#Array of move numbers
	attr_accessor		:initial_scores			#scores of all moves for a target				#Array of scores
	attr_accessor		:score_index			#index of current move being evaluated

	#We can adjust the thresholds as we work on things
	MINIMUMSKILL = 1
	LOWSKILL = 10
	MEDIUMSKILL = 30
	HIGHSKILL = 60
	BESTSKILL = 100

	#Function codes you might want to use on your partner.
	PARTNERFUNCTIONS = [0x40,0x41,0x55,0x63,0x66,0x67,0xA0,0xC1,
		0xDF,0x142,0x162,0x164,0x167,0x169,0x170,0x11d]
	#Swagger, Flatter, Psych Up, Simple Beam, Entrainment, Skill Swap, Frost Breath, Beat Up,
	#Heal Pulse, Topsy-Turvy, Floral Healing, Instruct, Pollen Puff, Purify, Spotlight, After You

	######################################################
	# Core functions
	######################################################
	#Do what we can to setup at the start of the battle

	def initialize(battle)
		@battle 			= battle
		@aimondata 		= [nil,nil,nil,nil]
		@aiMoveMemory = {}
		player = @battle.player
		opponent = @battle.opponent
		if @battle.doublebattle
			if player.is_a?(Array)
				@aimondata[0] = AI_MonData.new(player[0],0,@battle)
				@aimondata[2] = AI_MonData.new(player[1],2,@battle)
				@aiMoveMemory[player[0]] = {}
				@aiMoveMemory[player[1]] = {}
			else
				@aimondata[0] = AI_MonData.new(player,0,@battle)
				@aimondata[2] = AI_MonData.new(player,2,@battle)
				@aiMoveMemory[player] = {}
			end
			if opponent && opponent.is_a?(Array)
				@aimondata[1] = AI_MonData.new(opponent[0],1,@battle)
				@aimondata[3] = AI_MonData.new(opponent[1],3,@battle)
				@aiMoveMemory[opponent[0]] = {}
				@aiMoveMemory[opponent[1]] = {}
			elsif opponent
				@aimondata[1] = AI_MonData.new(opponent,1,@battle)
				@aimondata[3] = AI_MonData.new(opponent,3,@battle)
				@aiMoveMemory[opponent] = {}
			else
				@aimondata[1] = AI_MonData.new(nil,1,@battle)
				@aimondata[3] = AI_MonData.new(nil,3,@battle)
			end
		else
			@aimondata[0] = AI_MonData.new(player,0,@battle)
			@aiMoveMemory[player] = {}
			if @battle.opponent
				@aimondata[1] = AI_MonData.new(opponent,1,@battle)
				@aiMoveMemory[opponent] = {}
			else
				@aimondata[1] = AI_MonData.new(nil,1,@battle)
			end
		end
		#Having set up the data objects, get their roles (if applicable)
		for data in @aimondata
			next if data.nil?
			@mondata = data
			@mondata.partyroles = (@mondata.skill >= HIGHSKILL) ? pbGetMonRoles : Array.new(@mondata.party.length) {Array.new()}
		end
	end

	def processAIturn
		#Get the scores for each mon in battle
		for index in 0...@aimondata.length
			next if @aimondata[index].nil?
			next if @battle.pbOwnedByPlayer?(index) && !@battle.controlPlayer
			next if !@battle.pbCanShowCommands?(index) || @battle.battlers[index].hp == 0
			@mondata = @aimondata[index]
			clearMonDataTurn(@mondata)
			#load up the class variables
			@index = index
			@attacker = pbCloneBattler(@index)
			$ai_log_data[index].reset(@attacker) #AI data collection
			@opponent = @attacker.pbOppositeOpposing
			@mondata.roles = pbGetMonRoles(@attacker)
			#Check for conditions where the attacker object is not the one we want to score
			checkMega()
			checkUltraBurst()
			#Actually get the scores
			checkZMoves()
			buildMoveScores()
			#we set @opponent for Itemscore and Switchingscore
			@opponent = firstOpponent()
			getItemScore()
			getSwitchingScore()
		end
		#Coordination if there are two mons on the same side
		coordinateActions() if @battle.doublebattle
		#At this point, the processing is done and the AI should register its decisions
		#but i don't know how to do that, and i think we can do it from the battle side anyway
		#so as far as the ai code is concerned, we're done now.
		#We have the scores, now we decide what we want to do with them
		chooseAction()
	end

	def pbCloneBattler(index)
		original = @battle.battlers[index]
		battler = original.clone
		battler.form = original.form.clone
		battler.pokemon = original.pokemon.clone
		battler.pokemon.hp = original.pokemon.hp.clone
		battler.moves = original.moves.clone
		for i in 0...original.moves.length; battler.moves[i] = original.moves[i].clone; end
		battler.stages = original.stages.clone
		for i in 0...original.stages.length; battler.stages[i] = original.stages[i].clone; end
		return battler
	end

	def clearMonDataTurn(mondata)
		mondata.shouldMegaOrUltraBurst = false
		mondata.scorearray = [[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]
		mondata.roughdamagearray = [[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]
		mondata.itemscore = {}
		mondata.switchscore = []
		mondata.shouldswitchscore = -10000
		mondata.zmove = nil
	end

	def checkMega
		return if !@battle.pbCanMegaEvolve?(@index)
		want_to_mega=true
		#Run through conditions to see if you don't want to mega
		return if !want_to_mega
		#and if you want to mega, change the attacker
		@attacker.pokemon.makeMega
		@attacker.form=@attacker.pokemon.form
		@attacker.pbUpdate(true)
		@mondata.shouldMegaOrUltraBurst = true
	end

	def checkUltraBurst
		return if !@battle.pbCanUltraBurst?(@index)
		#change the attacker to be itself but ultra bursted
		@attacker.pokemon.makeUltra
		@attacker.form=@attacker.pokemon.form
		@attacker.pbUpdate(true)
		@mondata.shouldMegaOrUltraBurst = true
	end

	def checkZMoves
		return if !@battle.pbCanZMove?(@index)
		#Special case processing- there are specific moves that should intentionally be made z-moves
		#if both the move and the z-crystal are present
		bestbase = 0
		for move in @attacker.moves
			next if move.nil?
			next if move.pp == 0
			if (move.id == PBMoves::CONVERSION || move.id == PBMoves::SPLASH || move.id == PBMoves::CELEBRATE) && @attacker.item == PBItems::NORMALIUMZ2
				zmove = PokeBattle_ZMoves2.new(move, @attacker.item, @battle, @attacker)
				break 
			end
			if (move.id == PBMoves::NATUREPOWER && @attacker.item == PBItems::NORMALIUMZ2)
				newmove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@battle.field.naturePower),@attacker)
				if newmove.basedamage > 0
					zmove = PokeBattle_ZMoves2.new(newmove, @attacker.item, @battle, @attacker, true)
					break 
				end
			end
			if (move.id == PBMoves::NATURESMADNESS && @attacker.item == PBItems::TAPUNIUMZ2)
				zmove = PokeBattle_ZMoves2.new(move, @attacker.item, @battle, @attacker)
				break 
			end
			next if $cache.pkmn_move[move.id][PBMoveData::CATEGORY] == 2	#Skip all other status moves
			if @attacker.pbCompatibleZMoveFromMove?(move)
				testzmove = PokeBattle_ZMoves2.new(move, @attacker.item,@battle, @attacker)
				thisbase = testzmove.pbZMoveBaseDamage(move,@attacker.item)
				if bestbase < thisbase
					bestbase = thisbase
					zmove = PokeBattle_ZMoves2.new(move, @attacker.item, @battle, @attacker)
				end
			end
		end
		#if there's a zmove, put it on the moves list and run it with the rest
		if zmove
			@attacker.moves.push(zmove)
			@mondata.zmove = zmove
			@mondata.scorearray.each {|array| array.push(-1)}
			@mondata.roughdamagearray.each {|array| array.push(-1)}
		end
	end

	def buildMoveScores
		#this is the framework for getting the move scores. minimal calculation should be done here
		if !@battle.opponent && @battle.pbIsOpposing?(@index) #First check if this is a wild battle
			preference = @attacker.personalID % 4
			for j in [0,2]
				next if j==2 && !@battle.doublebattle
				for i in 0...4
					if @battle.pbCanChooseMove?(index,i,false)
						@mondata.scorearray[j][i]=100
						@mondata.scorearray[j][i]+=5 if preference == i # for personality
					end
				end
			end
			return
		end
		#real code time.
		if @battle.doublebattle	#this JUST gets the numbers. other things can be computed later.
			for monindex in 0...@battle.battlers.length
				next if monindex == @index 	#This is you! We don't want to hit ourselves.
				next if @battle.battlers[monindex].isFainted? #Can't hit 'em if they're dead
				@opponent = pbCloneBattler(monindex)
				# Save the amount of damage the AI think opp can do
				$ai_log_data[@index].expected_damage.push((checkAIdamage()*100.0/@attacker.totalhp).round(1)) unless monindex==@attacker.pbPartner.index || !$INTERNAL
				$ai_log_data[@index].expected_damage_name.push(PBSpecies.getName(@opponent.species)) unless monindex==@attacker.pbPartner.index || !$INTERNAL
				#get the moves the pokemon can choose, in case of choice item/encore/taunt/torment
				for moveindex in 0...@attacker.moves.length
					next if !@battle.pbCanChooseMove?(@index,moveindex,false)
					@move = pbChangeMove(@attacker.moves[moveindex],@attacker)
					#if you can't/shouldn't hit your partner with the move, skip it
					next if @attacker.pbPartner.index == monindex && (@attacker.pbTarget(@move) != PBTargets::AllNonUsers && !PARTNERFUNCTIONS.include?(@move.function))
					if @move.basedamage != 0
						@mondata.roughdamagearray[monindex][moveindex] = [(pbRoughDamage*100)/(@opponent.hp),110].min
						#The old function makes some adjustments for two-turn moves here. I'm leaving that for later.
					else
						@mondata.roughdamagearray[monindex][moveindex] = getStatusDamage
					end
				end

				
				for moveindex in 0...@attacker.moves.length
					next if !@battle.pbCanChooseMove?(@index,moveindex,false)
					@move = pbChangeMove(@attacker.moves[moveindex],@attacker)
					next if @attacker.pbPartner.index == monindex && (@attacker.pbTarget(@move) != PBTargets::AllNonUsers && !PARTNERFUNCTIONS.include?(@move.function))
					@mondata.scorearray[monindex][moveindex] = getMoveScore(@mondata.roughdamagearray[monindex],moveindex)
					#at this point we have legally acquired the move scores and thus should be done.
				end
				#add z-move if relevant
				if @mondata.zmove && @attacker.pbPartner.index != monindex
					@move = @mondata.zmove
					if @move.basedamage != 0 && @opponent.hp > 0
						@mondata.roughdamagearray[monindex][-1] = [(pbRoughDamage*100)/(@opponent.hp),110].min
					else
						@mondata.roughdamagearray[monindex][-1] = getStatusDamage
					end
					@mondata.scorearray[monindex][-1] = getMoveScore(@mondata.roughdamagearray[monindex],@mondata.roughdamagearray[monindex].length-1)
				end
				
				# Add struggle
				has_to_struggle = true
				@attacker.moves.each_with_index {|move, moveindex| has_to_struggle = false if @battle.pbCanChooseMove?(@index,moveindex,false) }
				if has_to_struggle
					next if @attacker.pbPartner.index == monindex
					@move = @battle.struggle
					@mondata.roughdamagearray[monindex][0] = [(pbRoughDamage*100)/(@opponent.hp),110].min
					@mondata.scorearray[monindex][0] = getMoveScore(@mondata.roughdamagearray[monindex],0)
				end
			end
		else
			@opponent = pbCloneBattler(0)	#Copy the player's mon cuz it's the only one there!
			$ai_log_data[@index].expected_damage.push((checkAIdamage()*100.0/@attacker.totalhp).round(1)) if $INTERNAL
			$ai_log_data[@index].expected_damage_name.push(PBSpecies.getName(@opponent.species)) if $INTERNAL
			#get the moves the pokemon can choose, in case of choice item/encore/taunt/torment
			for moveindex in 0...@attacker.moves.length
				next if !@battle.pbCanChooseMove?(@index,moveindex,false)
				@move = pbChangeMove(@attacker.moves[moveindex],@attacker)
				if @move.basedamage != 0	
					@mondata.roughdamagearray[0][moveindex] = [(pbRoughDamage*100)/(@opponent.hp),110].min
					#The old function makes some adjustments for two-turn moves here. I'm leaving that for later.
				else
					@mondata.roughdamagearray[0][moveindex] = getStatusDamage
				end
			end
			for moveindex in 0...@attacker.moves.length
				next if !@battle.pbCanChooseMove?(@index,moveindex,false)
				@move = @attacker.moves[moveindex]
				@mondata.scorearray[0][moveindex] = getMoveScore(@mondata.roughdamagearray[0],moveindex)
				#at this point we have legally acquired the move scores and thus should be done.
			end
			#add z-move if relevant
			if @mondata.zmove
				@move = @mondata.zmove
				if @move.basedamage != 0
					@mondata.roughdamagearray[0][-1] = [(pbRoughDamage*100)/(@opponent.hp),110].min
				else
					@mondata.roughdamagearray[0][-1] = getStatusDamage
				end
				@mondata.scorearray[0][-1] = getMoveScore(@mondata.roughdamagearray[0],@mondata.scorearray[0].length-1)
			end

			# Add struggle
			has_to_struggle = true
			@attacker.moves.each_with_index {|move, moveindex| has_to_struggle = false if @battle.pbCanChooseMove?(@index,moveindex,false) }
			if has_to_struggle
				@move = @battle.struggle
				@mondata.roughdamagearray[0][0] = [(pbRoughDamage*100)/(@opponent.hp),110].min
				@mondata.scorearray[0][0] = getMoveScore(@mondata.roughdamagearray[0],0)
			end
		end
	end

	def chooseAction
		for index in 0...@aimondata.length #for every battler
			next if @aimondata[index].nil?
			next if @battle.pbOwnedByPlayer?(index) && !@battle.controlPlayer
			battler = @battle.battlers[index]
			next if battler.hp == 0 || !@battle.pbCanShowCommands?(index)
			next if @battle.choices[battler.index][0] != 0
			@mondata = @aimondata[index]
			#make move-targets coupled list bc that works way easier ?
			@mondata.scorearray.map! {|scorelist| scorelist.map! {|score| score < 0 ? -1 : score}} 
			#make list of moves, targets, and scores, # structured [moveindex, [target(s)], score, isZmove?]
			chooseablemoves = findChoosableMoves(battler,@mondata) 
			
			
			chooseablemoves = chooseablemoves.find_all {|arrays| arrays[:score] >= 0}
			#dealing with mon that can't even choose fight menu
			if !@battle.pbCanShowCommands?(battler.index)
				@battle.pbAutoChooseMove(battler.index)
				next
			end
			
			if chooseablemoves.length !=0
				maxmovescore = chooseablemoves.max {|a1,a2| a1[:score]<=>a2[:score]}[:score] rescue 0
			else
				maxmovescore = 0
			end
			#chooses the action that the AI pokemon will perform
			#SWITCH
			if @mondata.shouldswitchscore > maxmovescore && @mondata.switchscore.max > 100 #arbitrary
				if battler.index==3 && @battle.choices[1][0]==2 && @battle.choices[1][1] == @mondata.switchscore.index(@mondata.switchscore.max)
					if @mondata.switchscore.max(2)[1] > 100 && shouldHardSwitch?(battler,@mondata.switchscore.index(@mondata.switchscore.max(2)[1]))
						indexhighestscore = @mondata.switchscore.index(@mondata.switchscore.max(2)[1])
						PBDebug.log(sprintf("Switching to %s",PBSpecies.getName(@battle.pbParty(battler.index)[indexhighestscore].species))) if $INTERNAL
						$ai_log_data[battler.index].chosen_action = sprintf("Switching to %s",PBSpecies.getName(@battle.pbParty(battler.index)[indexhighestscore].species))
						@battle.pbRegisterSwitch(battler.index,indexhighestscore)
						next
					end
				elsif shouldHardSwitch?(battler,@mondata.switchscore.index(@mondata.switchscore.max))
					indexhighestscore = @mondata.switchscore.index(@mondata.switchscore.max)
					PBDebug.log(sprintf("Switching to %s",PBSpecies.getName(@battle.pbParty(battler.index)[indexhighestscore].species))) if $INTERNAL
					$ai_log_data[battler.index].chosen_action = sprintf("Switching to %s",PBSpecies.getName(@battle.pbParty(battler.index)[indexhighestscore].species))
					@battle.pbRegisterSwitch(battler.index,indexhighestscore)
					next
				end
			end

			#USE ITEM
			if !@mondata.itemscore.empty? && @mondata.itemscore.values.max > maxmovescore
				item = @mondata.itemscore.key(@mondata.itemscore.values.max)
				#check if quantity of item the battler has is 1 and if previous battler hasn't also tried to use this item
				if battler.index==3 && @battle.choices[1][0]==3 && @battle.choices[1][1]==item
					items=@battle.pbGetOwnerItems(battler.index)
					if items.count {|element| element==item} > 1
						@battle.pbRegisterItem(battler.index,item)
						$ai_log_data[battler.index].chosen_action = sprintf("Using Item %s", PBItems.getName(item))
						next
					end
				else
					@battle.pbRegisterItem(battler.index,item)
					$ai_log_data[battler.index].chosen_action = sprintf("Using Item %s", PBItems.getName(item))
					next
				end
			end

			if !@battle.pbCanShowCommands?(battler.index) || (0..3).none? {|number| @battle.pbCanChooseMove?(battler.index,number,false)}
				@battle.pbAutoChooseMove(battler.index)
				next
			end

			#MEGA+BURST
			if @aimondata[index].shouldMegaOrUltraBurst
				@battle.pbRegisterMegaEvolution(index) if @battle.pbCanMegaEvolve?(index)
				@battle.pbRegisterUltraBurst(index) if @battle.pbCanUltraBurst?(index)
			end

			#MOVE
			canusemovelist = []
			for moveindex in 0...battler.moves.length
				canusemovelist.push(moveindex) if @battle.pbCanChooseMove?(battler.index,moveindex,false)
			end
			if chooseablemoves.length==0 && canusemovelist.length > 0
				@battle.pbRegisterMove(battler.index,canusemovelist[rand(canusemovelist.length)],false)
				@battle.pbRegisterTarget(battler.index,battler.pbOppositeOpposing.index) if @battle.doublebattle
				$ai_log_data[battler.index].chosen_action = "Random Move bc only bad decisions"
				next
			elsif chooseablemoves.length==0
				@battle.pbAutoChooseMove(battler.index)
			end

			# Minmax choices depending on AI
			if  @mondata.skill>=MEDIUMSKILL
				threshold=(@mondata.skill>=BESTSKILL) ? 1.5 : (@mondata.skill>=HIGHSKILL) ? 2 : 3
				newscore=(@mondata.skill>=BESTSKILL) ? 5 : (@mondata.skill>=HIGHSKILL) ? 10 : 15
				for scoreindex in 0...chooseablemoves.length
					chooseablemoves[scoreindex][:score] = chooseablemoves[scoreindex][:score] > newscore && chooseablemoves[scoreindex][:score]*threshold<maxmovescore ? newscore : chooseablemoves[scoreindex][:score]
				end
			end

			#Log the move scores in debuglog
			if $INTERNAL
				x="[#{battler.pbThis}: "
				j=0
				for i in 0...4
					next if battler.moves[i].nil?
					if battler.moves[i].id!=0
						x+=", " if j>0
						movelistscore = [@mondata.scorearray[0][i], @mondata.scorearray[1][i], @mondata.scorearray[2][i], @mondata.scorearray[3][i]]
						x+=battler.moves[i].name+"="+movelistscore.to_s
						j+=1
					end
				end
				x+="]"
				PBDebug.log(x)
				$stdout.print(x); $stdout.print("\n")
			end
			
			preferredMoves = []
			for i in chooseablemoves
				if  (i[:score] >= (maxmovescore* 0.95))
					preferredMoves.push(i)
					preferredMoves.push(i) if i[:score]==maxmovescore # Doubly prefer the best move
				end
			end
			
			chosen=preferredMoves[rand(preferredMoves.length)]
			if chosen[:zmove]
				PBDebug.log("[Prefer "+battler.moves[-1].name+"]") if $INTERNAL
				$ai_log_data[battler.index].chosen_action = "[Prefer "+battler.moves[-1].name+"]"
			else
				PBDebug.log("[Prefer "+battler.moves[chosen[:moveindex]].name+"]") if $INTERNAL
				$ai_log_data[battler.index].chosen_action = "[Prefer "+battler.moves[chosen[:moveindex]].name+"]"
			end
			@battle.pbRegisterMove(battler.index,chosen[:moveindex],false)
			@battle.pbRegisterTarget(battler.index,chosen[:target][0]) if @battle.doublebattle
			@battle.pbRegisterZMove(battler.index) if chosen[:zmove]==true #if chosen move is a z-move
		end
	end

	def findChoosableMoves(battler,mondata)
		chooseablemoves = []
		for moveindex in 0...battler.moves.length
			next if !@battle.pbCanChooseMove?(battler.index,moveindex,false)
			if !@battle.opponent && @battle.pbIsOpposing?(battler.index)
				chooseablemoves.push({moveindex: moveindex,target: [0,2].sample,score: mondata.scorearray[0][moveindex],zmove: false})
				next
			end

			move = pbChangeMove(battler.moves[moveindex],battler)
			if @battle.doublebattle
				pi = battler.pbPartner.index # partner
				oi = battler.pbOppositeOpposing.index #opposite opponent
				ci = battler.pbCrossOpposing.index
				case battler.pbTarget(move)
				when PBTargets::SingleNonUser, PBTargets::SingleOpposing
					[oi,pi,ci].each {|targetindex| chooseablemoves.push({moveindex: moveindex,target: [targetindex],score: mondata.scorearray[targetindex][moveindex],zmove: false}) }
				when PBTargets::RandomOpposing, PBTargets::User, PBTargets::NoTarget, PBTargets::UserSide
					if @battle.battlers[oi].hp > 0 && @battle.battlers[ci].hp > 0
						chooseablemoves.push({moveindex: moveindex,target: [oi],score: (mondata.scorearray[ci][moveindex]+mondata.scorearray[oi][moveindex])/2,zmove: false})
					elsif @battle.battlers[oi].hp > 0
						chooseablemoves.push({moveindex: moveindex,target: [oi],score: mondata.scorearray[oi][moveindex],zmove: false})
					else
						chooseablemoves.push({moveindex: moveindex,target: [ci],score: mondata.scorearray[ci][moveindex],zmove: false})
					end
				when PBTargets::AllOpposing, PBTargets::OpposingSide
					chooseablemoves.push({moveindex: moveindex,target: [oi,ci],score: (mondata.scorearray[ci][moveindex]+mondata.scorearray[oi][moveindex]),zmove: false})
				when PBTargets::AllNonUsers
					scoremult=1.0
					if mondata.trainer && (mondata.trainer.trainertype == PBTrainers::UMBTITANIA || mondata.trainer.trainertype == PBTrainers::UMBAMARIA) && @battle.doublebattle
						scoremult*= (1+2*mondata.scorearray[pi][moveindex]/100.0)
					elsif (move.pbType(battler) == PBTypes::FIRE && battler.pbPartner.ability == PBAbilities::FLASHFIRE) ||
							(move.pbType(battler) == PBTypes::WATER && (battler.pbPartner.ability == PBAbilities::WATERABSORB || battler.pbPartner.ability == PBAbilities::STORMDRAIN || battler.pbPartner.ability == PBAbilities::DRYSKIN)) ||
							(move.pbType(battler) == PBTypes::GRASS && battler.pbPartner.ability == PBAbilities::SAPSIPPER) ||
							(move.pbType(battler) == PBTypes::ELECTRIC) && (battler.pbPartner.ability == PBAbilities::VOLTABSORB || battler.pbPartner.ability == PBAbilities::LIGHTNINGROD || battler.pbPartner.ability == PBAbilities::MOTORDRIVE)
						scoremult*=2
					elsif battler.pbPartner.hp > 0 && (battler.pbPartner.hp.to_f > 0.1* battler.pbPartner.totalhp || pbAIfaster?(move,nil,battler,battler.pbPartner))
						scoremult = [(1-2*mondata.scorearray[pi][moveindex]/100.0), 0].max # multiplier to control how much to arbitrarily care about hitting partner; lower cares more
						scoremult*= 0.5 if pbAIfaster?(move,nil,battler,battler.pbPartner) && mondata.scorearray[pi][moveindex] > 50 # care more if we're faster and would knock it out before it attacks
					end
					chooseablemoves.push({moveindex: moveindex,target: [oi,ci,pi],score: scoremult*(mondata.scorearray[ci][moveindex]+mondata.scorearray[oi][moveindex]),zmove: false})
				when PBTargets::BothSides #actually targets only user side
					chooseablemoves.push({moveindex: moveindex,target: [oi,ci],score: Math.sqrt(mondata.scorearray[ci][moveindex]**2+mondata.scorearray[oi][moveindex]**2).round,zmove: false})
				when PBTargets::Partner
					chooseablemoves.push({moveindex: moveindex,target: [pi],score: [mondata.scorearray[ci][moveindex], mondata.scorearray[oi][moveindex] ].max,zmove: false})
					[oi,ci].each {|targetindex| chooseablemoves.push({moveindex: moveindex,target:[targetindex],score: mondata.scorearray[targetindex][moveindex],zmove: false}) }
				when PBTargets::OppositeOpposing
					if @battle.battlers[oi].hp > 0
						chooseablemoves.push({moveindex: moveindex,target: [oi],score: mondata.scorearray[oi][moveindex],zmove: false})
					else
						chooseablemoves.push({moveindex: moveindex,target: [ci],score: mondata.scorearray[ci][moveindex],zmove: false})
					end
				when PBTargets::UserOrPartner
					if @battle.battlers[oi].hp > 0 && @battle.battlers[ci].hp > 0
						chooseablemoves.push({moveindex: moveindex,target: [battler.index],score: (mondata.scorearray[ci][moveindex]+mondata.scorearray[oi][moveindex])/2,zmove: false})
					elsif @battle.battlers[oi].hp > 0
						chooseablemoves.push({moveindex: moveindex,target: [battler.index],score: mondata.scorearray[oi][moveindex],zmove: false})
					else
						chooseablemoves.push({moveindex: moveindex,target: [battler.index],score: mondata.scorearray[ci][moveindex],zmove: false})
					end
				when PBTargets::DragonDarts
					#Thank god this move doesn't exist yet
				end
			else
				unless battler.pbTarget(move) == PBTargets::UserOrPartner
					chooseablemoves.push({moveindex: moveindex,target: [0],score: mondata.scorearray[0][moveindex],zmove: false})
				else
					chooseablemoves.push({moveindex: moveindex,target: [battler.index],score: mondata.scorearray[0][moveindex],zmove: false})
				end
			end
		end
		#Add a possible z-move to the choosable moves. Only if the scores for non-z move are all lower than 100
		if mondata.zmove && (chooseablemoves.all? {|array| array[:score] < 100} || [PBMoves::CONVERSION,PBMoves::CELEBRATE,PBMoves::SPLASH,PBMoves::CLANGOROUSSOULBLAZE].include?(mondata.zmove.id))
			#find which move has been turned into z-move
			originalmoveid = mondata.zmove.fromothermove ? PBMoves::NATUREPOWER : mondata.zmove.oldmove.id
			originalmoveindex = battler.moves.find_index {|moveloop| moveloop!=nil && moveloop.id==originalmoveid}

			if @battle.doublebattle
				oi = battler.pbOppositeOpposing.index #opposite opponent
				ci = battler.pbCrossOpposing.index
				if  [PBMoves::CONVERSION,PBMoves::CELEBRATE,PBMoves::SPLASH,PBMoves::CLANGOROUSSOULBLAZE].include?(mondata.zmove.id)
					chooseablemoves.push({moveindex: originalmoveindex,target: [oi,ci],score: mondata.scorearray[oi][-1] + mondata.scorearray[ci][-1],zmove: true})
				else
					[oi,ci].each {|targetindex| chooseablemoves.push({moveindex: originalmoveindex,target: [targetindex],score: mondata.scorearray[targetindex][-1],zmove: true}) }
				end
			else
				chooseablemoves.push({moveindex: originalmoveindex,target: [0],score: mondata.scorearray[0][4],zmove: true})
			end
		end
		return chooseablemoves
	end

	def coordinateActions #changes some scores doesn't choose
		return if @battle.battlers[1].hp == 0 || @battle.battlers[3].hp == 0 || @battle.pbIsWild?
		#Threat Assesment
		threatscore = threatAssesment()
		biggest_threat = threatscore.index(threatscore.max)
		aimon1 = @battle.battlers[1]
		aimon2 = @battle.battlers[3]

		# indexing
		op_l = 0
		op_r = 2
		ai_l = 1
		ai_r = 3
		
		#find targets of all killing moves
		killing_moves = [[],[],[],[]]
		for i in [ai_l, ai_r]
			@aimondata[i].roughdamagearray.each_with_index {|array,monindex|
				next if monindex == ai_l || monindex == ai_r
				array.each_with_index { |obj, moveindex|
				if obj>=100 && @aimondata[i].scorearray[monindex][moveindex] > 80 # killing move + not awful score
					killing_moves[i].push(monindex)
				end
				}
			}
		end
		# shape the array in something more usable
		killing_moves.map! {|arr| arr.uniq}
		killing_moves.map!.with_index {|arr, index|
			if arr.length == 2
				:both
			elsif arr[0] == 0
				:left
			elsif arr[0] == 2
				:right
			elsif index == 0 || index == 2
				:_
			else
				:none
			end
		}
		#if only one of them has a killing move, make it so the other one doesn't target the same mon
		if (killing_moves[ai_l] != :none && killing_moves[ai_r] == :none) || (killing_moves[ai_r] != :none && killing_moves[ai_l] == :none)
			#battlerindexes
			ai_leader = killing_moves[ai_l] != :none ? ai_l : ai_r
			ai_follow = ai_leader ^ 2
			

			leader_mon = @battle.battlers[ai_leader]
			follow_mon = @battle.battlers[ai_follow]
			opp_left_mon = @battle.battlers[op_l]
			opp_righ_mon = @battle.battlers[op_r]

			#get the move it will choose
			leader_moves = findChoosableMoves(leader_mon, @aimondata[ai_leader])
			leader_moves.sort! {|a, b| b[:score] <=> a[:score]}
			bestmove = leader_moves[0][:zmove] ? @aimondata[ai_leader].zmove : leader_mon.moves[leader_moves[0][:moveindex]]

			if bestmove.category != 2 && bestmove.priority==0
				decrease_by = 1.0
				speedorder = pbMoveOrderAI()
				case speedorder
				# leader fastest and no specific way to save follower before follower attacks
				when [ai_leader, ai_follow, op_l, op_r] then decrease_by = 0.4
				when [ai_leader, op_l, op_r, ai_follow] then decrease_by = 0.4
				when [ai_leader, op_r, op_l, ai_follow] then decrease_by = 0.4
				when [ai_follow, ai_leader, op_l, op_r] then decrease_by = 0.4
				when [ai_follow, ai_leader, op_r, op_l] then decrease_by = 0.4
				when [ai_leader, ai_follow, op_r, op_l] then decrease_by = 0.4
					
				# leader slowest, but survives both hits of the opponent
				when [op_l, op_r, ai_follow, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp	
				when [op_r, op_l, ai_follow, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
				when [op_l, ai_follow, op_r, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
				when [op_r, ai_follow, op_l, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
				when [ai_follow, op_l, op_r, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
				when [ai_follow, op_r, op_l, ai_leader] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
				when [op_r, op_l, ai_leader, ai_follow] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) + checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
				when [op_l, op_r, ai_leader, ai_follow] then decrease_by = 0.7 if checkAIdamage(leader_mon,opp_left_mon) + checkAIdamage(leader_mon,opp_righ_mon) < leader_mon.hp
					
				# leader survives a hit from the left opp before targetting their mon, and can't save follower
				when [op_l, ai_leader, ai_follow, op_r] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) < leader_mon.hp
				when [ai_follow, op_l, ai_leader, op_r] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_left_mon) < leader_mon.hp
				when [op_l, ai_follow, ai_leader, op_r] then decrease_by = 0.7 if checkAIdamage(leader_mon,opp_left_mon) < leader_mon.hp
					
						
				# leader survives a hit from the right opp before targetting their mon, and can't save follower
				when [op_r, ai_leader, ai_follow, op_l] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
				when [ai_follow, op_r, ai_leader, op_l] then decrease_by = 0.7 if checkAIdamage(leader_mon, opp_righ_mon) < leader_mon.hp
				when [op_r, ai_follow, ai_leader, op_l] then decrease_by = 0.7 if checkAIdamage(leader_mon,opp_righ_mon) < leader_mon.hp
					
				# leader can save follower from taking a hit before moving follower moves, so target that slot unless that slot is unimportant
				when [ai_leader, op_l, ai_follow, op_r] then decrease_by = 0.7
				when [ai_leader, op_r, ai_follow, op_l] then decrease_by = 0.7
				when [op_l, ai_leader, op_r, ai_follow] then decrease_by = 0.7
				when [op_r, ai_leader, op_l, ai_follow] then decrease_by = 0.7

				end

				#change the targetting of the biggest target if it stops the follower from getting hit
				case speedorder
				# leader moves first, then the mon that can be killed then the follower, then the last 
				when [ai_leader, op_l, ai_follow, op_r],  [ai_leader, op_r, ai_follow, op_l]
					if killing_moves[ai_leader] == :both && checkAIdamage(follow_mon,@battle.battlers[speedorder[1]]) >= follow_mon.hp
						biggest_threat = speedorder[1] if threatscore[speedorder[3]] <= 2* threatscore[speedorder[1]]
					end
				# if the leader is gonna survive a hit from the mon moving before it, but the follower isn't from the mon after it, kill the mon that moves aftere the follower
				when [op_l, ai_leader, op_r, ai_follow]
					if killing_moves[ai_leader] == :both && checkAIdamage(leader_mon, @battle.battlers[speedorder[0]]) < leader_mon.hp && checkAIdamage(follow_mon,@battle.battlers[speedorder[2]]) >= follow_mon.hp
						biggest_threat = threatscore[speedorder[0]] >= 2* threatscore[speedorder[2]] ? speedorder[0] : speedorder[2]
					end
				end


				scoreDecrease(biggest_threat, killing_moves, decrease_by, ai_leader)
			elsif bestmove.priority > 0
				#priority moves fuck up jsut about everything
				biggest_threat_index = biggest_threat
				scoreDecrease(biggest_threat, killing_moves, 0.4, ai_leader)
			elsif bestmove.target == PBTargets::AllOpposing || bestmove.target == PBTargets::AllNonUsers
				#fuck it if i know
			end
		end

		#if both of them have killing move determine who should target who, mostly just don't target both the same
		if killing_moves[1] != :none && killing_moves[3] != :none
			
			bestchoice1 = getMaxScoreIndex(@aimondata[1].scorearray)
			bestchoice2 = getMaxScoreIndex(@aimondata[3].scorearray)
			bestmove1 = bestchoice1[1]==4 ? @aimondata[1].zmove : aimon1.moves[bestchoice1[1]]
			bestmove2 = bestchoice2[1]==4 ? @aimondata[3].zmove : aimon2.moves[bestchoice2[1]]
			#make sure the best move isn't a status move or switching/item

			if bestmove2.category != 2 && bestmove1.category != 2
				speedorder = pbMoveOrderAI()
				targetting_done=false
				case speedorder
					when [1,3,2,0], [3,1,2,0], [1,3,0,2], [3,1,0,2] # ai,ai,player,player
						
					when [1,0,3,2], [1,2,3,0], [3,0,1,2], [3,2,1,0] # ai,player,ai,player
						if killing_moves == [:_,:both,:_,:both]
							@aimondata[speedorder[0]].scorearray[speedorder[3]].map! {|score| score*0.4}
							@aimondata[speedorder[2]].scorearray[speedorder[1]].map! {|score| score*0.4}
							#speedorder[0] targets speedorder[1]
							#speedorder[2] targets speedorder[3]
							targetting_done=true
						elsif speedorder==[1,0,3,2] && killing_moves==[:_,:both,:_,:left] ||
							  speedorder==[1,2,3,0] && killing_moves==[:_,:both,:_,:right] ||
							  speedorder==[3,0,1,2] && killing_moves==[:_,:left,:_,:both] ||
							  speedorder==[3,2,1,0] && killing_moves==[:_,:right,:_,:both]
							if checkAIdamage(@battle.battlers[speedorder[2]],@battle.battlers[speedorder[1]]) >= @battle.battlers[speedorder[2]].hp
								@aimondata[speedorder[0]].scorearray[speedorder[3]].map! {|score| score*0.4}
								@aimondata[speedorder[2]].scorearray[speedorder[1]].map! {|score| score*0.7}
								#speedorder[0] targets speedorder[1]
								#speedorder[2] gets score decreased for speedorder[1]
								targetting_done=true
							end
						end
					when [1,0,2,3], [1,2,0,3], [3,0,2,1], [3,2,0,1] # ai,player,player,ai
						case killing_moves
						when [:_,:both,:_,:both]
							@aimondata[speedorder[0]].scorearray[biggest_threat].map! {|score| score*0.7}
							@aimondata[speedorder[3]].scorearray[biggest_threat].map! {|score| score*0.7}
							#speedorder[0] targets biggest threat
							#speedorder[3] targets other
							targetting_done=true
						when [:_,:left,:_,:left]
							@aimondata[speedorder[0]].scorearray[2].map! {|score| score*0.7}
							@aimondata[speedorder[3]].scorearray[0].map! {|score| score*0.7}
							#speedorder[0] targets the one they can kill
							#speedorder[3] targets other
							targetting_done=true
						when [:_,:right,:_,:rigth]
							@aimondata[speedorder[0]].scorearray[2].map! {|score| score*0.7}
							@aimondata[speedorder[3]].scorearray[0].map! {|score| score*0.7}
							#speedorder[0] targets the one they can kill
							#speedorder[3] targets other
							targetting_done=true
							
						end
					when [0,1,3,2], [0,3,1,2], [2,1,3,0], [2,3,1,0] # player,ai,ai,player
						case killing_moves
						when [:_,:both,:_,:both], [:_,:left,:_,:left], [:_,:right,:_,:rigth]
							#don't edit the scores, who knows which mon will live
							targetting_done=true
						end
					when [0,1,2,3], [0,3,2,1], [2,1,0,3], [2,3,0,1] # player,ai,player,ai
						case killing_moves
						when [:_,:both,:_,:both]
							@aimondata[speedorder[1]].scorearray[speedorder[0]].map! {|score| score*0.7}
							@aimondata[speedorder[3]].scorearray[speedorder[2]].map! {|score| score*0.7}
							#speedorder[1] targets speedorder[2]
							#speedorder[3] targets speedorder[0]
							targetting_done=true
						when [:_,:left,:_,:left], [:_,:right,:_,:rigth]
							if checkAIdamage(@battle.battlers[speedorder[1]], @battle.battlers[speedorder[0]]) >= @battle.battlers[speedorder[1]].hp
								chosen_index = killing_moves == [:_,:left,:_,:left] ? 0 : 2
								@aimondata[speedorder[3]].scorearray[chosen_index].map! {|score| score*0.7}
								targetting_done=true
							else
								#don't edit the scores, who knows which mon will live
								targetting_done=true
							end
						end
					when [0,2,1,3], [2,0,1,3], [0,2,3,1], [2,0,3,1] # player,player,ai,ai
						case killing_moves
						when [:_,:both,:_,:both]
							#don't edit the scores, who knows which mon will live
							targetting_done=true
						when [:_,:left,:_,:left], [:_,:right,:_,:rigth]
							#don't edit the scores, who knows which mon will live
							targetting_done=true
						end
				end
				if !targetting_done
					case killing_moves
					when [:_,:both,:_,:both]
						#just target differently
						if rand(2)==0
							@aimondata[1].scorearray[0].map! {|score| score*0.7}
							@aimondata[3].scorearray[2].map! {|score| score*0.7}
						else
							@aimondata[1].scorearray[0].map! {|score| score*0.7}
							@aimondata[3].scorearray[2].map! {|score| score*0.7}
						end
					when [:_,:left,:_,:both]
						#only need to change 3 to target 2
						@aimondata[3].scorearray[0].map! {|score| score*0.7}
					when [:_,:right,:_,:both]
						#only need to change 3 to target 0
						@aimondata[3].scorearray[2].map! {|score| score*0.7}
					when [:_,:both,:_,:left]
						#only need to change 1 to target 2
						@aimondata[1].scorearray[0].map! {|score| score*0.7}
					when [:_,:both,:_,:right]
						#only need to change 1 to target 0
						@aimondata[3].scorearray[2].map! {|score| score*0.7}
					when [:_,:left,:_,:left]
						#check which has highest score move not targetting 0
						if @aimondata[1].scorearray[0].max > @aimondata[3].scorearray[0].max
							@aimondata[1].scorearray[2].map! {|score| score*0.7}
							@aimondata[3].scorearray[0].map! {|score| score*0.7}
						else
							@aimondata[1].scorearray[0].map! {|score| score*0.7}
							@aimondata[3].scorearray[2].map! {|score| score*0.7}
						end
						
					when [:_,:left,:_,:right]
						#nothing to do here
					when [:_,:right,:_,:left]
						#nothing to do here
					when [:_,:right,:_,:rigth]
						#check which has highest score move not targetting 2
						if @aimondata[1].scorearray[2].max > @aimondata[3].scorearray[2].max
							@aimondata[1].scorearray[0].map! {|score| score*0.7}
							@aimondata[3].scorearray[2].map! {|score| score*0.7}
						else
							@aimondata[1].scorearray[2].map! {|score| score*0.7}
							@aimondata[3].scorearray[0].map! {|score| score*0.7}
						end
					end
				end
			end
		end

		# Finding the best moves for both AI
		moves_1 = findChoosableMoves(aimon1,@aimondata[1])
		moves_2 = findChoosableMoves(aimon2,@aimondata[3])
		return if moves_1.length==0 || moves_2.length==0
		return if !@battle.pbCanShowCommands?(ai_l) || !@battle.pbCanShowCommands?(ai_r)
		moves_1.sort! {|a,b| b[:score] <=> a[:score]}
		moves_2.sort! {|a,b| b[:score] <=> a[:score]}
		bestindex1 = moves_1[0][:moveindex]
		bestindex2 = moves_2[0][:moveindex]
		bestmove1 = aimon1.moves[bestindex1]
		bestmove2 = aimon2.moves[bestindex2]
		nextbest1 = moves_1.find {|scores| scores[:moveindex]!=moves_1[0][:moveindex]}
		nextbest2 = moves_2.find {|scores| scores[:moveindex]!=moves_2[0][:moveindex]}
		bestmoves_id = [bestmove1.id, bestmove2.id]

		# both want to use a attention-grabbing move
		if bestmoves_id.all? { |bestmove| [PBMoves::FOLLOWME, PBMoves::RAGEPOWDER].include?(bestmove) }
			if !nextbest1.nil? || !nextbest2.nil?
				if nextbest1.nil? || !nextbest2.nil? && nextbest1[:score] > nextbest2[:score]
					@aimondata[1].scorearray.map! {|a| a.map!.with_index {|b,i| i==bestindex1 ? 0 : b }}
				else
					@aimondata[3].scorearray.map! {|a| a.map!.with_index {|b,i| i==bestindex2 ? 0 : b }}
				end
			end
		end

		# one wants to use helping hand
		if PBMoves::HELPINGHAND == bestmove1.id || PBMoves::HELPINGHAND == bestmove2.id
			if PBMoves::HELPINGHAND == bestmove1.id && bestmove2.basedamage == 0
				@aimondata[1].scorearray.map! {|a| a.map!.with_index {|b,i| i==bestindex1 ? 0 : b }}
			elsif PBMoves::HELPINGHAND == bestmove2.id && bestmove1.basedamage == 0
				@aimondata[3].scorearray.map! {|a| a.map!.with_index {|b,i| i==bestindex2 ? 0 : b }}
			end
		end

		#both want to use the same move that affects the battlefield
		if bestmove1.id == bestmove2.id && [PBMoves::STEALTHROCK, PBMoves::STICKYWEB, PBMoves::TAILWIND, PBMoves::GRAVITY, PBMoves::LIGHTSCREEN, PBMoves::REFLECT, PBMoves::AURORAVEIL,
			 PBMoves::TRICKROOM, PBMoves::WONDERROOM, PBMoves::MAGICROOM, PBMoves::SUNNYDAY, PBMoves::RAINDANCE, PBMoves::HAIL, PBMoves::SANDSTORM,  PBMoves::SAFEGUARD].include?(bestmove1.id)
			if !nextbest1.nil? && !nextbest2.nil?
				if nextbest1[:score] > nextbest2[:score]
					@aimondata[1].scorearray.map! {|a| a.map!.with_index {|b,i| i==bestindex1 ? 0 : b }}
				else
					@aimondata[3].scorearray.map! {|a| a.map!.with_index {|b,i| i==bestindex2 ? 0 : b }}
				end
			end
		end

		#both want to use a status move against an opponent
		if PBStuff::STATUSCONDITIONMOVE.include?(bestmove1.id) && PBStuff::STATUSCONDITIONMOVE.include?(bestmove2.id) && moves_1[0][:target].intersection(moves_2[0][:target])!=[]
			nextbest1 = moves_1.find {|scores| scores[:moveindex]!=moves_1[0][:moveindex] || scores[:target].intersection(moves_2[0][:target])==[]}
			nextbest2 = moves_2.find {|scores| scores[:moveindex]!=moves_2[0][:moveindex] || scores[:target].intersection(moves_1[0][:target])==[]}
			if !nextbest1.nil? && !nextbest2.nil?
				if nextbest1[:score] > nextbest2[:score]
					@aimondata[1].scorearray.map!.with_index {|a,moveindex| a.map!.with_index {|b,i| i==bestindex1 && nextbest1[:target].include?(moveindex) ? 0 : b }}
				else
					@aimondata[3].scorearray.map!.with_index {|a,moveindex| a.map!.with_index {|b,i| i==bestindex2 && nextbest2[:target].include?(moveindex) ? 0 : b }}
				end
			end
		end

		#both want to use a confusion causing move agains an opponent
		if bestmoves_id.all? { |bestmove| PBStuff::CONFUMOVE.include?(bestmove) && ![PBMoves::CHATTER,PBMoves::DYNAMICPUNCH].include?(bestmove) }  && moves_1[0][:target].intersection(moves_2[0][:target])!=[]
			nextbest1 = moves_1.find {|scores| scores[:moveindex]!=moves_1[0][:moveindex] || scores[:target].intersection(moves_2[0][:target])==[]}
			nextbest2 = moves_2.find {|scores| scores[:moveindex]!=moves_2[0][:moveindex] || scores[:target].intersection(moves_1[0][:target])==[]}
			if !nextbest1.nil? && !nextbest2.nil?
				if nextbest1[:score] > nextbest2[:score]
					@aimondata[1].scorearray.map!.with_index {|a,moveindex| a.map!.with_index {|b,i| i==bestindex1 && nextbest1[:target].include?(moveindex) ? 0 : b }}
				else
					@aimondata[3].scorearray.map!.with_index {|a,moveindex| a.map!.with_index {|b,i| i==bestindex2 && nextbest2[:target].include?(moveindex) ? 0 : b }}
				end
			end
		end

		# both want to use other move that interferes with eachother on same mon
		if bestmoves_id.all? { |bestmove| [PBMoves::ENCORE].include?(bestmove) } && moves_1[0][:target].intersection(moves_2[0][:target])!=[]
			nextbest1 = moves_1.find {|scores| scores[:moveindex]!=moves_1[0][:moveindex] || scores[:target].intersection(moves_2[0][:target])==[]}
			nextbest2 = moves_2.find {|scores| scores[:moveindex]!=moves_2[0][:moveindex] || scores[:target].intersection(moves_1[0][:target])==[]}
			if !nextbest1.nil? && !nextbest2.nil?
				if nextbest1[:score] > nextbest2[:score]
					@aimondata[1].scorearray.map!.with_index {|a,moveindex| a.map!.with_index {|b,i| i==bestindex1 && nextbest1[:target].include?(moveindex) ? 0 : b }}
				else
					@aimondata[3].scorearray.map!.with_index {|a,moveindex| a.map!.with_index {|b,i| i==bestindex2 && nextbest2[:target].include?(moveindex) ? 0 : b }}
				end
			end
		end

		# one is using eq and other wants to roost
		if bestmoves_id.include?(PBMoves::EARTHQUAKE) && bestmoves_id.include?(PBMoves::ROOST)
			if PBMoves::EARTHQUAKE == bestmove1.id
				if !pbAIfaster?(bestmove1, bestmove2, aimon1, aimon2)
					@aimondata[3].scorearray.map! {|a| a.map!.with_index {|b,i| i==bestindex2 ? 0 : b }}
				end
			elsif PBMoves::EARTHQUAKE == bestmove2.id
				if !pbAIfaster?(bestmove2, bestmove1, aimon2, aimon1)
					@aimondata[1].scorearray.map! {|a| a.map!.with_index {|b,i| i==bestindex1 ? 0 : b }}
				end
			end
		end
	end

	def threatAssesment
		# Dont care about it if one of the player mons is dead
		return [1, -1, 1, -1] if @battle.battlers[0].hp <= 0 && @battle.battlers[2].hp <= 0
		return [0, -1, 1, -1] if @battle.battlers[0].hp <= 0
		return [1, -1, 0, -1] if @battle.battlers[2].hp <= 0
		threatscore = [-1, 1.0, -1, 1.0]

		# find out which of the AI mons are still Alive
		aimons = [@battle.battlers[1], @battle.battlers[3]].find_all {|mon| mon && mon.hp>0}

		@battle.battlers.each_with_index {|opp,i|
			next if i == 1 || i == 3 # only player needs assesed
			# Base stat total
			threatscore[i]*= pbBaseStatTotal(opp.species)/200.0
			# Level
			threatscore[i]*= (opp.level / ((aimons.sum {|mon| mon.level}) / aimons.length))**2
			# Mega
			threatscore[i]*= 1.1 if opp.isMega?
			# Boosts
			threatscore[i]*= 1+0.2*opp.stages[PBStats::ATTACK] 		if opp.attack > opp.spatk
			threatscore[i]*= 1+0.2*opp.stages[PBStats::SPATK] 		if opp.spatk > opp.attack
			threatscore[i]*= 1+0.05*opp.stages[PBStats::DEFENSE] 	if aimons.any? {|mon| mon.attack > mon.spatk}
			threatscore[i]*= 1+0.05*opp.stages[PBStats::SPDEF] 		if aimons.any? {|mon| mon.spatk > mon.attack}
			threatscore[i]*= 1+0.10*opp.stages[PBStats::SPEED] 		if (opp.stages[PBStats::SPEED] > 0) ^ @battle.trickroom!=0
			threatscore[i]*= [1+0.20*opp.stages[PBStats::ACCURACY],0.3].max	if opp.stages[PBStats::ACCURACY] < 0
			threatscore[i]*= 1+0.20*opp.stages[PBStats::EVASION]	if opp.stages[PBStats::EVASION] >0
			# Opp has revealed spread move
			threatscore[i]*= 1.2 if getAIMemory(opp).any? {|moveloop| moveloop!=nil && moveloop.target & 12 != 0}
			# Opp has killing move
			threatscore[i]*=1.5 if aimons.any? {|mon| checkAIdamage(opp,mon) >= mon.hp }
			# Abilities
			threatscore[i]*= aimons.sum {|mon| getAbilityDisruptScore(mon,opp) / aimons.length }
			# Speed
			threatscore[i]*=1.5 if aimons.any? {|aimon| pbAIfaster?(nil,nil,opp,aimon) }
			threatscore[i]*=1.1 if aimons.all? {|aimon| pbAIfaster?(nil,nil,opp,aimon) }
			# Status
			threatscore[i]*=0.6 if opp.status==PBStatuses::SLEEP || opp.status==PBStatuses::FROZEN
			threatscore[i]*=0.8 if opp.status==PBStatuses::PARALYSIS && ![PBAbilities::GUTS,PBAbilities::MARVELSCALE,PBAbilities::QUICKFEET].include?(opp.ability) 
		}
		PBDebug.log(sprintf("Opposing threat scores : %s",threatscore.join(", "))) if $INTERNAL
		return threatscore
	end

	def getMoveScore(initialscores=[],scoreindex=-1)
		@move = pbChangeMove(@move,@attacker)
		#################### Setup ####################
		score=initialscores[scoreindex]
		@initial_scores=initialscores
		@score_index=scoreindex
		if $ai_log_data[@attacker.index].move_names.length - $ai_log_data[@attacker.index].final_score_moves.length > 0
			$ai_log_data[@attacker.index].move_names.pop()
			$ai_log_data[@attacker.index].init_score_moves.pop()
			$ai_log_data[@attacker.index].opponent_name.pop()
		end
		$ai_log_data[@attacker.index].move_names.push(sprintf("%s - %d", @move.name, @opponent.index))
		$ai_log_data[@attacker.index].init_score_moves.push(score)
		$ai_log_data[@attacker.index].opponent_name.push(@opponent.name)
		@mondata.oppitemworks = @opponent.itemWorks?
		@mondata.attitemworks = @attacker.itemWorks?
		#################### Misc. Scoring ####################
		# Type-nulling abilities
		if @move.basedamage>0
			typemod=pbTypeModNoMessages(@move.pbType(@attacker))
			$ai_log_data[@attacker.index].final_score_moves.push(typemod) if typemod<=0
			return typemod if typemod<=0
			wondercheck = typemod<=4 && @opponent.ability == PBAbilities::WONDERGUARD
		end
		#Hell check: Can you hit this pokemon that has an ability that nullifies your move?
		if @mondata.skill>=MEDIUMSKILL && !moldBreakerCheck(@attacker) &&
				((@attacker.pbTarget(@move)==PBTargets::SingleNonUser || @attacker.pbTarget(@move) & 0x486 != 0 || (@attacker.pbTarget(@move)==PBTargets::OppositeOpposing && @attacker.pbHasType?(:GHOST))) && @move.basedamage == 0) #RandomOpposing, AllOpposing, OpposingSide, SingleOpposing
			if wondercheck || (@move.pbType(@attacker) == PBTypes::GROUND && @opponent.ability == PBAbilities::LEVITATE && @battle.FE != PBFields::CAVE)
				$ai_log_data[@attacker.index].final_score_moves.push(0)
				return 0
			end
			if 	(@move.pbType(@attacker) == PBTypes::FIRE && @opponent.nullsFire?) || (@move.pbType(@attacker) == PBTypes::GRASS && @opponent.nullsGrass?) ||
				(@move.pbType(@attacker) == PBTypes::WATER && @opponent.nullsWater?) || (@move.pbType(@attacker) == PBTypes::ELECTRIC && @opponent.nullsElec?)
				$ai_log_data[@attacker.index].final_score_moves.push(-1)
				return -1
			end
			$ai_log_data[@attacker.index].final_score_moves.push(0) if (@opponent.ability == PBAbilities::MAGICBOUNCE || @opponent.pbPartner.ability == PBAbilities::MAGICBOUNCE) && @move.basedamage == 0 #there is not a good way to do this section
			$ai_log_data[@attacker.index].final_score_moves.push(0) if (@opponent.effects[PBEffects::MagicCoat]==true || @opponent.pbPartner.effects[PBEffects::MagicCoat]==true) && @move.basedamage == 0 #there is not a good way to do this section
			return -1 if (@opponent.ability == PBAbilities::MAGICBOUNCE || @opponent.pbPartner.ability == PBAbilities::MAGICBOUNCE) && @move.basedamage == 0 #there is not a good way to do this section
			return -1 if (@opponent.effects[PBEffects::MagicCoat]==true || @opponent.pbPartner.effects[PBEffects::MagicCoat]==true) && @move.basedamage == 0 #there is not a good way to do this section
		end
		if @move.pbType(@attacker) == PBTypes::GROUND && !canGroundMoveHit?(@opponent) && @battle.FE !=PBFields::CAVE && @move.basedamage != 0
			$ai_log_data[@attacker.index].final_score_moves.push(0)
			return 0
		end
		if @move.pbType(@attacker) == PBTypes::FIRE  && @battle.FE == PBFields::UNDERWATER && @mondata.skill>=HIGHSKILL && @attacker.pbTarget(@move) != PBTargets::User
			$ai_log_data[@attacker.index].final_score_moves.push(0)
			return 0
		end
		if @move.pbType(@attacker) == PBTypes::GROUND && (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS) && @mondata.skill>=HIGHSKILL
			$ai_log_data[@attacker.index].final_score_moves.push(0)
			return 0
		end
		#fuck
		#Priority checks
		if @move.pbIsPriorityMoveAI(@attacker) && @attacker != @opponent.pbPartner
			aifaster=pbAIfaster?()
			aifaster_partner = pbAIfaster?(nil,nil,@attacker,@opponent.pbPartner) if @battle.doublebattle && @opponent.pbPartner.hp > 0
			#if move.basedamage>0
			PBDebug.log(sprintf("Priority Check Begin")) if $INTERNAL
			aifaster ? PBDebug.log(sprintf("AI Pokemon is faster.")) : PBDebug.log(sprintf("Player Pokemon is faster.")) if $INTERNAL
			if (@battle.doublebattle || (@opponent.status!=PBStatuses::SLEEP && @opponent.status!=PBStatuses::FROZEN && !@opponent.effects[PBEffects::Truant] && @opponent.effects[PBEffects::HyperBeam] == 0)) && !seedProtection?(@attacker) # This line might be in the wrong place, but we're trying our best here-- skip priority if opponent is incapacitated
				if score>100
					score*= @battle.doublebattle ? 1.3 : (aifaster ? 1.3 : 2)
				elsif @attacker.ability == PBAbilities::STANCECHANGE && !aifaster && @attacker.form == 0 && @attacker.pokemon.species == PBSpecies::AEGISLASH
					score*=0.7
				end
				movedamage = -1
				opppri = false
				pridam = -1
				movedamage2 = -1
				opppri2 = false
				pridam2 = -1
				if !aifaster || aifaster_partner===false || getAIMemory().any? {|moveloop| moveloop!=nil && moveloop.basedamage > 0 && moveloop.pbIsPriorityMoveAI(@opponent)} || getAIMemory(@opponent.pbPartner).any? {|moveloop| moveloop!=nil && moveloop.basedamage > 0 && moveloop.pbIsPriorityMoveAI(@opponent.pbPartner)} && @battle.doublebattle
					for i in getAIMemory() + [PokeBattle_Move_FFF.new(@battle,@opponent, @opponent.type1), PokeBattle_Move_FFF.new(@battle,opponent, opponent.type2)]
						tempdam = pbRoughDamage(i,@opponent,@attacker)
						movedamage = tempdam if tempdam>movedamage
						if i.pbIsPriorityMoveAI(@opponent) && i.basedamage > 0
							opppri=true
							pridam = tempdam if tempdam>pridam
						end
					end
					for i in getAIMemory(@opponent.pbPartner) + [PokeBattle_Move_FFF.new(@battle,@opponent.pbPartner, @opponent.pbPartner.type1), PokeBattle_Move_FFF.new(@battle,opponent.pbPartner, opponent.pbPartner.type2)]
						tempdam = pbRoughDamage(i,@opponent.pbPartner,@attacker)
						movedamage2 = tempdam if tempdam>movedamage2
						if i.pbIsPriorityMoveAI(@opponent.pbPartner) && i.basedamage > 0
							opppri2=true
							pridam2 = tempdam if tempdam>pridam2
						end
					end
				end
				movedamage = @attacker.hp - 1 if notOHKO?(@attacker, @opponent, true)
				movedamage2 = @attacker.hp - 1 if notOHKO?(@attacker, @opponent.pbPartner, true)
				PBDebug.log(sprintf("pre-check: %d",score)) if $INTERNAL
				PBDebug.log(sprintf("Expected damage taken: %d",[movedamage,movedamage2].max)) if $INTERNAL
				scoreboost = @battle.doublebattle ? 40 : 150
				scoreboost = 30 if PBStuff::PROTECTMOVE.include?(@move.id)
				scoreboost *= 0.5 if @opponent.moves.any? {|moveloop| moveloop!=nil && (PBStuff::SETUPMOVE).include?(moveloop.id)} && (score < 100)
				if (@attacker.pbPartner.pbHasMove?(PBMoves::FOLLOWME) || @attacker.pbPartner.pbHasMove?(PBMoves::RAGEPOWDER))
					scoreboost = 0 
				end
				score+= scoreboost if !aifaster && (movedamage > @attacker.hp || !aifaster_partner && movedamage2 > @attacker.hp) && score > 1
				PBDebug.log(sprintf("post-check: %d",score)) if $INTERNAL
				if opppri
					score*=1.1
					score*= aifaster ? 3 : 0.5 if pridam>attacker.hp
				elsif opppri2
					score*=1.1
					score*= aifaster_partner ? 3 : 0.5 if pridam2>attacker.hp
				end
			end
			score*=0 if !aifaster && @opponent.effects[PBEffects::TwoTurnAttack]>0
			score*=0 if @battle.FE == PBFields::PSYCHICT && !@opponent.isAirborne?
			score*=0 if @opponent.ability == PBAbilities::DAZZLING || @opponent.ability == PBAbilities::QUEENLYMAJESTY || @opponent.pbPartner.ability == PBAbilities::DAZZLING || @opponent.pbPartner.ability == PBAbilities::QUEENLYMAJESTY
			score*=0.2 if (checkAImoves([PBMoves::QUICKGUARD]) || checkAImoves([PBMoves::QUICKGUARD],getAIMemory(@opponent.pbPartner))) && move.target!=PBTargets::User
			PBDebug.log(sprintf("Priority Check End")) if $INTERNAL
		elsif @move.priority<0 && pbAIfaster?()
			score*=0.9
			score*=0.6 if initialscores[scoreindex] >=100 && initialscores.count {|iniscore| iniscore >= 100} > 1
			score*=2 if @move.basedamage>0 && @opponent.effects[PBEffects::TwoTurnAttack]>0
		end
		#Sound move checks
		if @move.isSoundBased?
			$ai_log_data[@attacker.index].final_score_moves.push(0) if (@opponent.ability == PBAbilities::SOUNDPROOF && !moldBreakerCheck(@attacker)) || @attacker.effects[PBEffects::ThroatChop]!=0
			return 0 if (@opponent.ability == PBAbilities::SOUNDPROOF && !moldBreakerCheck(@attacker)) || @attacker.effects[PBEffects::ThroatChop]!=0
			score *= 0.6 if checkAImoves([PBMoves::THROATCHOP])
		end
		if @opponent.ability == PBAbilities::DANCER
			if (PBStuff::DANCEMOVE).include?(@move.id)
				score*=0.5
				score*=0.1 if @battle.FE == PBFields::BIGTOPA
			end
		end
		if @mondata.skill>=HIGHSKILL && @opponent.index!=@attacker.index
			for j in getAIMemory(@opponent)
				ioncheck = true if j.id==PBMoves::IONDELUGE || j.id==PBMoves::PLASMAFISTS
				destinycheck = true if j.id==PBMoves::DESTINYBOND
				widecheck = true if j.id==PBMoves::WIDEGUARD
				powdercheck = true if j.id==PBMoves::POWDER
				shieldcheck = true if j.id==PBMoves::SPIKYSHIELD || j.id==PBMoves::KINGSSHIELD ||  j.id==PBMoves::BANEFULBUNKER
			end
			if @battle.doublebattle
				for j in getAIMemory(@opponent.pbPartner)
					widecheck = true if j.id==PBMoves::WIDEGUARD
					powdercheck = true if j.id==PBMoves::POWDER
					ioncheck = true if j.id==PBMoves::IONDELUGE || j.id==PBMoves::PLASMAFISTS
				end
			end
			if @move.basedamage > 0
				if @opponent.effects[PBEffects::DestinyBond]
					score*=0.2
				else
					score*=0.7 if !pbAIfaster?(@move) && destinycheck
				end
			end
			if ioncheck && @move.type == PBTypes::NORMAL
				score*=0.3 if [PBAbilities::LIGHTNINGROD,PBAbilities::VOLTABSORB,PBAbilities::MOTORDRIVE].include?(@opponent.ability) || @opponent.pbPartner.ability == PBAbilities::LIGHTNINGROD
			end
			score*=0.2 if widecheck && (@move.target & 0x00C != 0) #AllOpposing, AllNonUsers
			score*=0.2 if powdercheck && @move.pbType(@attacker)==PBTypes::FIRE
		end
		# If opponent about to use a recover move before being killed, check damage vs them again
		if checkAIhealing && !pbAIfaster?(@move) && @mondata.skill >= BESTSKILL && move.basedamage > 0
			newhp = [((@opponent.totalhp+1)/2) + @opponent.hp, @opponent.totalhp].min
			score*= [pbRoughDamage/newhp.to_f, 1.1].min
		end
		# Check for moves that can be nullified by any mon in doubles
		if @battle.doublebattle && (@move.target & 0xC02 != 0 || @move.target==PBTargets::SingleNonUser) #RandomOpposing, SingleOpposing, OppositeOpposing
			if @move.pbType(@attacker)==PBTypes::ELECTRIC || (ioncheck && @move.type == PBTypes::NORMAL)
				$ai_log_data[@attacker.index].final_score_moves.push(0) if @opponent.pbPartner.ability == PBAbilities::LIGHTNINGROD
				return -1 if @opponent.pbPartner.ability == PBAbilities::LIGHTNINGROD
				score*=0.3 if @attacker.pbPartner.ability == PBAbilities::LIGHTNINGROD
			elsif @move.pbType(@attacker)==PBTypes::WATER
				$ai_log_data[@attacker.index].final_score_moves.push(0) if @opponent.pbPartner.ability == PBAbilities::STORMDRAIN
				return -1 if @opponent.pbPartner.ability == PBAbilities::STORMDRAIN
				score*=0.3 if @attacker.pbPartner.ability == PBAbilities::STORMDRAIN
			end
		end
		if @move.flags&0x80!=0 # Boosted crit moves
			if !(@opponent.ability == PBAbilities::SHELLARMOR || @opponent.ability == PBAbilities::BATTLEARMOR || @attacker.effects[PBEffects::LaserFocus]>0)
				boostercount = 0
				if @move.pbIsPhysical?()
					boostercount += @opponent.stages[PBStats::DEFENSE] if @opponent.stages[PBStats::DEFENSE]>0
					boostercount -= @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK]<0
				elsif @move.pbIsSpecial?()
					boostercount += @opponent.stages[PBStats::SPDEF] if @opponent.stages[PBStats::SPDEF]>0
					boostercount -= @attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK]<0
				end
				score*=(1.05**boostercount) if hasgreatmoves()
			end
		end
		# If you have two moves that kill, use one that doesn't consume your item (gems only rn)
		if hasgreatmoves()
			case @move.type
				when PBTypes::NORMAL
					case @attacker.item
					when PBItems::NORMALGEM then score*=0.9
					end
				when PBTypes::FIGHTING
					case @attacker.item
					when PBItems::FIGHTINGGEM then score*=0.9
					end
				when PBTypes::FLYING
					case @attacker.item
					when PBItems::FLYINGGEM then score*=0.9
					end
				when PBTypes::POISON
					case @attacker.item
					when PBItems::FLYINGGEM then score*=0.9
					end
				when PBTypes::GROUND
					case @attacker.item
					when PBItems::GROUNDGEM then score*=0.9
					end
				when PBTypes::ROCK
					case @attacker.item
					when PBItems::ROCKGEM then score*=0.9
					end
				when PBTypes::BUG
					case @attacker.item
					when PBItems::BUGGEM then score*=0.9
					end
				when PBTypes::GHOST
					case @attacker.item
					when PBItems::GHOSTGEM then score*=0.9
					end
				when PBTypes::STEEL
					case @attacker.item
					when PBItems::STEELGEM then score*=0.9
					end
				when PBTypes::FIRE
					case @attacker.item
					when PBItems::FIREGEM then score*=0.9
					end
				when PBTypes::WATER
					case @attacker.item
					when PBItems::WATERGEM then score*=0.9
					end
				when PBTypes::GRASS
					case @attacker.item
					when PBItems::FLYINGGEM then score*=0.9
					end
				when PBTypes::ELECTRIC
					case @attacker.item
					when PBItems::ELECTRICGEM then score*=0.9
					end
				when PBTypes::PSYCHIC
					case @attacker.item
					when PBItems::PSYCHICGEM then score*=0.9
					end
				when PBTypes::ICE
					case @attacker.item
					when PBItems::ICEGEM then score*=0.9
					end
				when PBTypes::DRAGON
					case @attacker.item
					when PBItems::DRAGONGEM then score*=0.9
					end
				when PBTypes::DARK
					case @attacker.item
					when PBItems::DARKGEM then score*=0.9
					end
				when PBTypes::FAIRY
					case @attacker.item
					when PBItems::FAIRYGEM then score*=0.9
					end
			end
			score*=0.9 if @attacker.item == PBItems::POWERHERB && (PBStuff::TWOTURNMOVE + PBStuff::CHARGEMOVE).include?(@move.id)
		end
		#Contact move checks
		if @move.isContactMove? && !(@attacker.item == PBItems::PROTECTIVEPADS) && @attacker.ability != PBAbilities::LONGREACH
			contactscore=1.0
			contactscore*= @attacker.hp < 0.2*@attacker.totalhp ? 0.5 : 0.85 if (@mondata.oppitemworks && @opponent.item == PBItems::ROCKYHELMET) || shieldcheck
			case @opponent.ability
			when PBAbilities::EFFECTSPORE 	then contactscore*=0.75
			when PBAbilities::FLAMEBODY 	then contactscore*=0.75 if @attacker.pbCanBurn?(false)
			when PBAbilities::STATIC 		then contactscore*=0.75 if @attacker.pbCanParalyze?(false)
			when PBAbilities::POISONPOINT	then contactscore*=0.75 if @attacker.pbCanPoison?(false)
			when PBAbilities::CUTECHARM 	then contactscore*=0.8 if  @attacker.effects[PBEffects::Attract]<0 && initialscores.length>0 && initialscores[scoreindex] < 110
			when PBAbilities::ROUGHSKIN, PBAbilities::IRONBARBS then contactscore*= @attacker.hp < 0.2*@attacker.totalhp ? 0.5 : 0.85
			when PBAbilities::GOOEY, PBAbilities::TANGLINGHAIR
				if @attacker.pbCanReduceStatStage?(PBStats::SPEED)
					contactscore*=0.9
					contactscore*=0.8 if pbAIfaster?()
				end
			when PBAbilities::MUMMY
				if !((PBStuff::FIXEDABILITIES).include?(@attacker.ability)) && !(@attacker.ability == PBAbilities::MUMMY || @attacker.ability == PBAbilities::SHIELDDUST)
					mummyscore = getAbilityDisruptScore(@opponent,@attacker)
					mummyscore = mummyscore < 2 ? 2 - mummyscore : 0
					contactscore*=mummyscore
				end
			end
			contactscore*=0.8 if @opponent.species == PBSpecies::AEGISLASH && !checkAImoves([PBMoves::KINGSSHIELD]) && (@move.pbIsPhysical?() || @battle.FE == PBFields::FAIRYTALEF)
			contactscore*=0.5 if checkAImoves([PBMoves::KINGSSHIELD]) && !PBStuff::RATESHARERS.include?(@opponent.lastMoveUsed) && (@move.pbIsPhysical?() || @battle.FE == PBFields::FAIRYTALEF)
			contactscore*=0.7 if checkAImoves([PBMoves::BANEFULBUNKER]) && !PBStuff::RATESHARERS.include?(@opponent.lastMoveUsed) && @attacker.pbCanPoison?(false)
			contactscore*=0.6 if checkAImoves([PBMoves::SPIKYSHIELD]) && !PBStuff::RATESHARERS.include?(@opponent.lastMoveUsed) && @attacker.hp < 0.3 * @attacker.totalhp
			contactscore*=1.1 if @attacker.ability == PBAbilities::POISONTOUCH && @opponent.pbCanPoison?(false)
			contactscore*=1.1 if @attacker.ability == PBAbilities::PICKPOCKET && @opponent.item!=0 && !@battle.pbIsUnlosableItem(@opponent,@opponent.item) && @attacker.item==0
			contactscore*=0.1 if seedProtection?(@opponent) && !PBStuff::PROTECTIGNORINGMOVE.include?(@move.id)
			#this could be increased for moves that hit more than twice, but this should be sufficiently strong enough to deter move usage regardless
			contactscore = contactscore**2 if @move.pbIsMultiHit
			score*=contactscore
		end
		#This is for seeds that activated at the start of the turn
		if @move.basedamage > 0 && seedProtection?(@opponent) && !PBStuff::PROTECTIGNORINGMOVE.include?(@move.id)
			score*=0.1
		end
		#If you have a move that kills, use it.
		if @move.basedamage==0 && hasgreatmoves()
			maxdam=checkAIdamage()
			if maxdam>0 && maxdam<(@attacker.hp*0.3)
				score*=0.6
			else
				score*=0.2 ### highly controversial, revert to 0.1 if shit sucks
			end
		end
		#Don't use powder moves if they don't do anything
		if PBStuff::POWDERMOVES.include?(@move.id) && (@opponent.pbHasType?(PBTypes::GRASS) || @opponent.ability == PBAbilities::OVERCOAT || (@mondata.oppitemworks && @opponent.item == PBItems::SAFETYGOGGLES))
			$ai_log_data[@attacker.index].final_score_moves.push(0)
			return 0
		end
		# Prefer damaging moves if AI has no more Pokémon
		if @attacker.pbNonActivePokemonCount==0
			if @mondata.skill>=MEDIUMSKILL && !(@mondata.skill>=HIGHSKILL && @opponent.pbNonActivePokemonCount>0)
				if @move.basedamage==0
					PBDebug.log("[Not preferring status move]") if $INTERNAL
					score*=0.9
				elsif @opponent.hp<=@opponent.totalhp/2.0
					PBDebug.log("[Preferring damaging move]") if $INTERNAL
					score*=1.1
				end
			end
		end
		# Don't prefer attacking the opponent if they'd be semi-invulnerable
		if @opponent.effects[PBEffects::TwoTurnAttack]>0 && @mondata.skill>=HIGHSKILL
			invulmove=@opponent.effects[PBEffects::TwoTurnAttack]
			if (@move.accuracy>0 || @move.function==0xA5 || @move.zmove && @move.basedamage > 0 || @move.id == PBMoves::WHIRLWIND) && (PBStuff::TWOTURNMOVE.include?(invulmove) || @opponent.effects[PBEffects::SkyDrop]) &&
					pbAIfaster?(@move,nil,@attacker,@opponent) && @attacker.ability != PBAbilities::NOGUARD && @opponent.ability != PBAbilities::NOGUARD && !(@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
				miss = true
				if @mondata.skill>=BESTSKILL
					case invulmove
						when PBMoves::FLY, PBMoves::BOUNCE then miss = false if PBStuff::AIRHITMOVES.include?(@move.id) || @move.id == PBMoves::WHIRLWIND
						when PBMoves::DIG then miss = false if @move.id == PBMoves::EARTHQUAKE || @move.id == PBMoves::MAGNITUDE || @move.id == PBMoves::FISSURE
						when PBMoves::DIVE then miss = false if @move.id == PBMoves::SURF || @move.id == PBMoves::WHIRLPOOL
						when PBMoves::SKYDROP then miss = false if PBStuff::AIRHITMOVES.include?(@move.id)
						end
					if @opponent.effects[PBEffects::SkyDrop]
						miss = false if PBStuff::AIRHITMOVES.include?(@move.id)
					end
					$ai_log_data[@attacker.index].final_score_moves.push(0) if miss
					return 0 if miss
				else
					$ai_log_data[@attacker.index].final_score_moves.push(0)
					return 0
				end
			end
		end
		# Don't prefer an attack if the opponent has revealed a mon that would be immume to it
		switchableparty = @battle.pbParty(@opponent.index).find_all.with_index {|mon,monindex| @battle.pbCanSwitch?(@opponent.index,monindex,false,true)}
		oppparty = getAIKnownParty(@opponent)
		oppparty = switchableparty.intersection(oppparty)
		if oppparty.any? { |oppmon,moves| @move.pbTypeModifierNonBattler(@move.pbType(@attacker),@attacker,oppmon) <= 1 }
			score *= 0.9
		end
		# Pick a good move for the Choice items
		if @mondata.attitemworks && (@attacker.item == PBItems::CHOICEBAND || @attacker.item == PBItems::CHOICESPECS || @attacker.item == PBItems::CHOICESCARF)
			if @move.basedamage==0 && @move.function!=0xF2 && @move.function!=0x13d && @move.function!=0xb4 # Trick, parting shot and sleep talk 
				score*=0.1
			else
				score *= 0.8 if oppparty.any? { |oppmon,moves| @move.pbTypeModifierNonBattler(@move.pbType(@attacker),@attacker,oppmon) == 0 }
			end
			score *= (@move.accuracy/100.0) if @move.accuracy > 0
			score *= 0.9 if @move.pp <= 5
			score *= 0.1 if [PBMoves::FIRSTIMPRESSION, PBMoves::FAKEOUT].include?(@move.id) && (@opponent.pbNonActivePokemonCount > 0 || @initial_scores[@score_index] < 100)
		end
		# If user is frozen, prefer a move that can thaw the user
    	if @attacker.status==PBStatuses::FROZEN && @mondata.skill>=MEDIUMSKILL
			if PBStuff::UNFREEZEMOVE.include?(@move.id)
				score+=30
			else
				$ai_log_data[@attacker.index].final_score_moves.push(0) if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::UNFREEZEMOVE).include?(moveloop.id)}
				return 0 if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::UNFREEZEMOVE).include?(moveloop.id)}
			end
		end
		# If target is frozen, don't prefer moves that could thaw them
		if @opponent.status==PBStatuses::FROZEN
			score *= 0.1 if @move.pbType(@attacker) == PBTypes::FIRE
		end
		# If opponent is dark type and attacker has prankster, son't use status moves on them 
		if @mondata.skill>=MEDIUMSKILL && @attacker.ability == PBAbilities::PRANKSTER && @opponent.pbHasType?(:DARK)
			if @move.basedamage==0 && @move.priority>-1 && (@attacker.pbTarget(@move)==PBTargets::SingleNonUser || @attacker.pbTarget(@move) & 0x486 != 0)
				$ai_log_data[@attacker.index].final_score_moves.push(0)
				return 0
			end
		end
		# If move changes field consider value of changing it
		if @mondata.skill>=BESTSKILL
			fieldmove = @battle.field.moveData(@move.id)
			if fieldmove && fieldmove[:fieldchange]
				change_conditions = @battle.field.fieldChangeData
				if change_conditions[fieldmove[:fieldchange]]
					handled = eval(change_conditions[fieldmove[:fieldchange]])
				else
					handled = true
				end
				if handled  #don't continue if conditions to change are not met
					currentfieldscore = getFieldDisruptScore(@attacker,@opponent,@battle.FE) # the higher the better for opp
					newfieldscore = getFieldDisruptScore(@attacker,@opponent,fieldmove[:fieldchange])
					score*= Math.sqrt(currentfieldscore/newfieldscore)
				end
			end
		end
		#Weigh scores against accuracy
		accuracy=pbRoughAccuracy(@move,@attacker,@opponent)
		moddedacc = (accuracy + 100)/2.0
    	score*=moddedacc/100.0
		# Avoid shiny wild pokemon if you're an AI partner
		if @battle.pbIsWild?
			score *= 0.1 if @attacker.index == 2 && @opponent.pokemon.isShiny?
		end
		#################### Function Code Scoring ####################
		miniscore=1.0
		case @move.function
			when 0x00 # No effect
				if @mondata.skill >= BESTSKILL && @battle.FE != PBFields::NONE
					case @battle.FE
					when PBFields::ICYF
						if @move.id == PBMoves::TECTONICRAGE
							if @battle.field.backup== 21 # Water Surface
								currentfieldscore = getFieldDisruptScore(@attacker,@opponent,@battle.FE) # the higher the better for opp
								newfieldscore = getFieldDisruptScore(@attacker,@opponent,21)
								miniscore = currentfieldscore/newfieldscore
							else
								miniscore*=1.2 if @opponent.pbNonActivePokemonCount>2
								miniscore*=0.8 if @attacker.pbNonActivePokemonCount>2
							end
						end
					when PBFields::MIRRORA
						miniscore*=2 if @move.id == PBMoves::DAZZLINGGLEAM && mirrorNeverMiss
						miniscore*=0.3 if @move.id == PBMoves::BOOMBURST || @move.id == PBMoves::HYPERVOICE
					when PBFields::FLOWERGARDENF
						if (@move.id == PBMoves::CUT || @move.id == PBMoves::XSCISSOR) && @battle.field.counter > 0
							miniscore*= pbPartyHasType?(PBTypes::GRASS) || pbPartyHasType?(PBTypes::BUG) ? 0.3 : 2.0
						end
						if @move.id==PBMoves::PETALBLIZZARD && @battle.field.counter==4
							miniscore*=1.5 if @battle.doublebattle
						end
					end
				end
			when 0x01 # Splash
				if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::WATERS
					miniscore = antistatcode([0,0,0,0,0,1,0],initialscores[scoreindex])
				end
			when 0x02 # Struggle
				miniscore*=0.2
			when 0x03 # Sleep, Dark Void, Grass Whistle, Sleep Powder, Spore, Relic Song, Lovely Kiss, Sing, Hypnosis
				miniscore = sleepcode()
				miniscore *= 1.3 if pbAIfaster?(@move)
				if @mondata.skill >= BESTSKILL
					miniscore*= 2 if @move.id==PBMoves::SLEEPPOWDER && @battle.FE == PBFields::FLOWERGARDENF && @battle.doublebattle
				end
			when 0x04 # Yawn
				miniscore = sleepcode()
			when 0x05 # Poison, Gunk Shot, Sludge Wave, Sludge Bomb, Poison Jab, Sludge, Poison Tail, Smog, Poison Sting, Poison Gas, Poison Powder
				miniscore = poisoncode()
				if @mondata.skill >= BESTSKILL
					if @battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER # Water Surface/Underwater
						if @move.id==PBMoves::SLUDGEWAVE
					   		miniscore*=1.75 if pbPartyHasType?(PBTypes::POISON) && !pbPartyHasType?(PBTypes::WATER)
							miniscore*=0 if !@attacker.pbHasType?(PBTypes::POISON) && !@attacker.pbHasType?(PBTypes::STEEL) && @battle.pbPokemonCount(@battle.pbParty(@opponent.index))==1 && @battle.field.counter==1
					  	end
					end
					if @battle.FE == PBFields::MISTYT # Misty Terrain
						if @move.id==PBMoves::SMOG || @move.id==PBMoves::POISONGAS
							miniscore*=1.75 if pbPartyHasType?(PBTypes::POISON) && !pbPartyHasType?(PBTypes::FAIRY)
						end
						if @move.id==PBMoves::POISONGAS
							if pbPartyHasType?(PBTypes::POISON) && !pbPartyHasType?(PBTypes::FAIRY)
								score = 15
								miniscore = 1.0
							end
						end
				  	end
				end
			when 0x06 # Toxic, Poison Fang
				miniscore = poisoncode()
				if @move.id==PBMoves::TOXIC
					miniscore*=1.1 if @attacker.pbHasType?(:POISON)
				end
			when 0x07 # Paralysis, Dragon breath, Bolt Strike, Zap Cannon, Thunderbolt, Discharge, Thunder Punch, Spark, Thunder Shock, Thunder Wave, Force Palm, Lick, Stun Spore, Body Slam, Glare, Nuzzle
				miniscore = paracode()
			when 0x08 # Thunder
				miniscore = paracode()
				miniscore *= thunderboostcode()
				miniscore *= nevermisscode(initialscores[scoreindex]) if @battle.pbWeather==PBWeather::RAINDANCE
			when 0x09 # Paralysis + Flinch, Thunder Fang
				miniscore = paracode()
				miniscore *= flinchcode()
			when 0x0A # Burn Blue Flare, Fire Blast, Heat Wave, Inferno, Sacred Fire, Searing Shot, Flamethrower, Blae kick, Lava Plume, Fire Punch, Flame Wheel, Ember, Will-O-Wist, Scald, Steam Eruption
				miniscore = burncode()
				if @mondata.skill >= BESTSKILL
					if move.id==PBMoves::SCALD || move.id==PBMoves::STEAMERUPTION
						if @battle.FE == PBFields::ICYF # Icy Field
							currentfieldscore = getFieldDisruptScore(@attacker,@opponent,@battle.FE) # the higher the better for opp
							newfieldscore = getFieldDisruptScore(@attacker,@opponent,21)
							miniscore*= Math.sqrt(currentfieldscore/newfieldscore)
						end
					end
				end
			when 0x0B # Burn + Flinch, Fire Fang
				miniscore = burncode()
				miniscore *= flinchcode()
			when 0x0C # Freeze, Ice Beam, Ice Punch, Powder Snow, Freeze-Dry
				miniscore = freezecode()
			when 0x0D # Blizzard Freeze
				miniscore = freezecode()
				miniscore *= nevermisscode(initialscores[scoreindex]) if @battle.pbWeather==PBWeather::HAIL
			when 0x0E # Freeze + Flinch, Ice Fang
				miniscore = freezecode()
				miniscore *= flinchcode()
				if @mondata.skill >= BESTSKILL
					if @battle.FE == PBFields::GLITCHF # Glitch
						miniscore*=1.2
					end
				end
			when 0x0F # Flinch, Dark Pulse, Bite, Rolling Kick, Air Slash, Astonish, Needle Arm, Hyper Fang, Headbutt, Extrasensory, Zen Headbutt, Heart Stamp, Rock Slide, Iron Head, Waterfall, Zing Zap
				miniscore = flinchcode()
			when 0x10 # Stomp, Steamroller, Dragon Rush
				miniscore = flinchcode()
			when 0x11 # Snore
				miniscore = flinchcode() if @attacker.status==PBStatuses::SLEEP
				score = 0 if @attacker.status!=PBStatuses::SLEEP
			when 0x12 # Fake Out
				if @attacker.turncount==0 && !(@opponent.effects[PBEffects::Substitute] > 0 || @opponent.ability == PBAbilities::INNERFOCUS || secondaryEffectNegated?())
					#usually this would be saved as miniscore, but we directly add to the score
					score *= flinchcode()
					score+=115 if score>1
					score*=0.7 if @battle.doublebattle
					score*=1.1 if (@attacker.itemWorks? && @attacker.item == PBItems::NORMALGEM)
					score*=1.5 if @attacker.ability == PBAbilities::UNBURDEN
					score*=0.3 if checkAImoves([PBMoves::ENCORE])
				elsif @attacker.turncount!=0
					score=0
				end
			when 0x13 # Confusion, Signal Beam, Dynamic Punch, Chatter, Confuse Ray, Rock Climb, Dizzy Punch, Supersonic, Sweet Kiss, Teeter Dance, Psybeam, Water Pulse
				miniscore = confucode()
				if @mondata.skill >= BESTSKILL
					if move.id==PBMoves::SIGNALBEAM
						miniscore*=2 if @battle.FE == PBFields::MIRRORA && mirrorNeverMiss  # Mirror Arena
					end
					if move.id==PBMoves::SWEETKISS
						miniscore*=0.2 if @battle.FE == PBFields::FAIRYTALEF && @opponent.status==PBStatuses::SLEEP # Fairy Tale
					end
				end
			when 0x14 # Chatter
			when 0x15 # Hurricane
				miniscore = confucode()
				miniscore *= thunderboostcode()
				miniscore *= nevermisscode(initialscores[scoreindex]) if @battle.pbWeather==PBWeather::RAINDANCE
			when 0x16 # Attract
				miniscore = attractcode()
			when 0x17 # Tri Attack
				miniscore = (burncode() + paracode() + freezecode()) / 3
			when 0x18 # Refresh
				miniscore = refreshcode()
			when 0x19 # Aromatherapy, Heal Bell
				miniscore = partyrefreshcode()
			when 0x1a # Safeguard
				#dont use safeguard.
				if @attacker.pbOwnSide.effects[PBEffects::Safeguard]<=0 
					if pbAIfaster?(@move) && @attacker.status==0 && !@mondata.roles.include?(PBMonRoles::STATUSABSORBER)
						score+=50 if checkAImoves([PBMoves::SPORE])
					end
					#uggggh fine, i guess you are my little guardchamp
					if !@battle.opponent.is_a?(Array)
						if (@battle.opponent.trainertype==PBTrainers::CAMERUPT)
							score+=150
						end
					end
				end
			when 0x1b # Psycho Shift
				miniscore = psychocode()
			when 0x1c # Howl, Sharpen, Meditate, Meteor Mash, Metal Claw, Power-Up Punch
				statarray = [1,0,0,0,0,0,0]
				statarray = [3,0,0,0,0,0,0] if @mondata.skill >= BESTSKILL && @move.id==PBMoves::MEDITATE && @battle.FE == PBFields::RAINBOWF || @battle.FE == PBFields::ASHENB
				statarray = [2,0,0,2,0,0,0] if @mondata.skill >= BESTSKILL && @move.id==PBMoves::MEDITATE && @battle.FE == PBFields::PSYCHICT
				miniscore = selfstatboost(statarray)
			when 0x1d # Harden, Steel Wing, Withdraw
				miniscore = selfstatboost([0,1,0,0,0,0,0])
			when 0x1e # Defense Curl
				miniscore = selfstatboost([0,1,0,0,0,0,0])
				score*=1.3 if @attacker.pbHasMove?(PBMoves::ROLLOUT) && @attacker.effects[PBEffects::DefenseCurl]==false
			when 0x1f # Flame Charge
				miniscore = selfstatboost([0,0,1,0,0,0,0])
			when 0x20 # Charge Beam, Fiery Dance
				miniscore = selfstatboost([0,0,0,1,0,0,0])
			when 0x21 # Charge
				miniscore = selfstatboost([0,0,0,0,1,0,0])
				miniscore*=1.5 if @attacker.moves.any?{|moveloop| moveloop!=nil && moveloop.pbType(@attacker)==PBTypes::ELECTRIC} && @attacker.effects[PBEffects::Charge]==0
			when 0x22 # Double Team
				statarray = [0,0,0,0,0,0,1]
				statarray = [0,0,0,0,0,0,2] if @mondata.skill >= BESTSKILL && @move.id==PBMoves::DOUBLETEAM && @battle.FE == PBFields::MIRRORA
				miniscore = selfstatboost(statarray)
			when 0x23 # Focus Energy
				miniscore = focusenergycode()
				miniscore*= 1.5 if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::ASHENB # Ashen Beach
			when 0x24 # Bulk Up
				miniscore = selfstatboost([1,1,0,0,0,0,0])
			when 0x25 # Coil
				statarray = [1,1,0,0,0,1,0]
				statarray = [2,2,0,0,0,2,0] if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::GRASSYT
				miniscore = selfstatboost(statarray)
			when 0x26 # Dragon Dance
				statarray = [1,0,1,0,0,0,0]
				statarray = [2,0,2,0,0,0,0] if @mondata.skill >= BESTSKILL && (@battle.FE == PBFields::BIGTOPA || @battle.FE == PBFields::DRAGONSD)
				miniscore = selfstatboost(statarray)
			when 0x27 # Work Up
				miniscore = selfstatboost([1,0,0,1,0,0,0])
			when 0x28 # Growth
				statarray = [1,0,0,1,0,0,0]
				if @mondata.skill >= BESTSKILL
					statarray = [2,0,0,2,0,0,0] if @battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FORESTF || @battle.pbWeather==PBWeather::SUNNYDAY || (@battle.field.counter<=2 && @battle.FE == PBFields::FLOWERGARDENF)
					statarray = [3,0,0,3,0,0,0] if @battle.field.counter>2 && @battle.FE == PBFields::FLOWERGARDENF # Flower Garden
				end
				miniscore = selfstatboost(statarray)
			when 0x29 # Hone Claws
				miniscore = selfstatboost([1,0,0,0,0,1,0])
			when 0x2a # Cosmic Power, Defend Order
				statarray = [0,1,0,0,1,0,0]
				statarray = [0,2,0,0,2,0,0] if @mondata.skill >= BESTSKILL && @move.id==PBMoves::COSMICPOWER && [3,9,29,34,35,37].include?(@battle.FE)
				statarray = [0,2,0,0,2,0,0] if @mondata.skill >= BESTSKILL && @move.id==PBMoves::DEFENDORDER && @battle.FE == PBFields::FORESTF
				miniscore = selfstatboost(statarray)
			when 0x2b # Quiver Dance
				statarray = [0,0,1,1,1,0,0]
				statarray = [0,0,2,2,2,0,0] if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::BIGTOPA
				miniscore = selfstatboost(statarray)
			when 0x2c # Calm Mind
				statarray = [0,0,0,1,1,0,0]
				statarray = [0,0,0,2,2,0,0] if @mondata.skill >= BESTSKILL && (@battle.FE == PBFields::CHESSB || @battle.FE == PBFields::ASHENB || @battle.FE == PBFields::PSYCHICT)
				miniscore = selfstatboost(statarray)
			when 0x2d # Ancient Power, Silver Wind, Ominous Wind
				miniscore = selfstatboost([1,1,1,1,1,0,0])
			when 0x2e # Swords Dance
				statarray = [2,0,0,0,0,0,0]
				statarray = [3,0,0,0,0,0,0] if @mondata.skill >= BESTSKILL && @move.id==PBMoves::SWORDSDANCE && (@battle.FE == PBFields::BIGTOPA || @battle.FE == PBFields::FAIRYTALEF)
				miniscore = selfstatboost(statarray)
			when 0x2f # Iron Defense, Acid Armor, Barrier, Diamon Storm
				statarray = [0,2,0,0,0,0,0]
				statarray = [0,3,0,0,0,0,0] if @mondata.skill >= BESTSKILL && (@move.id==PBMoves::IRONDEFENSE && @battle.FE == PBFields::FACTORYF) || (@move.id==PBMoves::ACIDARMOR && [10,11,26,31].include?(@battle.FE))
				miniscore = selfstatboost(statarray)
			when 0x30 # Agility, Rock Polish
				statarray = [0,0,2,0,0,0,0]
				statarray = [0,0,3,0,0,0,0] if @mondata.skill >= BESTSKILL && @move.id==PBMoves::ROCKPOLISH && @battle.FE == PBFields::ROCKYF
				statarray = [1,0,2,1,0,0,0] if @mondata.skill >= BESTSKILL && @move.id==PBMoves::ROCKPOLISH && @battle.FE == PBFields::CRYSTALC
				miniscore = selfstatboost(statarray)
			when 0x31 # Autotomize
				statarray = [0,0,2,0,0,0,0]
				statarray = [0,0,3,0,0,0,0]  if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::FACTORYF
				miniscore = selfstatboost(statarray)
				miniscore*=1.5 if checkAImoves([PBMoves::LOWKICK,PBMoves::GRASSKNOT])
				miniscore*=0.5 if checkAImoves([PBMoves::HEATCRASH,PBMoves::HEAVYSLAM])
				miniscore*=0.7 if @attacker.pbHasMove?(PBMoves::HEATCRASH) || @attacker.pbHasMove?(PBMoves::HEAVYSLAM)
			when 0x32 # Nasty Plot
				statarray = [0,0,0,2,0,0,0]
				statarray = [0,0,0,3,0,0,0] if @mondata.skill >= BESTSKILL && (@battle.FE == PBFields::CHESSB || @battle.FE == PBFields::PSYCHICT)
				miniscore = selfstatboost(statarray)
			when 0x33 # Amnesia
				statarray = [0,0,0,0,2,0,0]
				miniscore = selfstatboost(statarray)
				miniscore *= 2 if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::GLITCHF
			when 0x34 # Minimize
				miniscore = selfstatboost([0,0,0,0,0,0,2])
			when 0x35 # Shell Smash
				miniscore = selfstatboost([2,0,2,2,0,0,0])
				miniscore*= selfstatdrop([0,1,0,0,1,0,0],score) if (@mondata.attitemworks && @attacker.item != PBItems::WHITEHERB)
				if (@mondata.attitemworks && @attacker.item == PBItems::WHITEHERB)
					miniscore*=1.3 
				else
					miniscore*=0.8 
				end
			when 0x36 # Shift Gear
				statarray = [1,0,2,0,0,0,0]
				statarray = [2,0,2,0,0,0,0] if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::FACTORYF
				miniscore = selfstatboost(statarray)
			when 0x37 # Acupressure
				miniscore = selfstatboost([2,0,0,0,0,0,0]) +selfstatboost([0,2,0,0,0,0,0]) + selfstatboost([0,0,2,0,0,0,0]) +selfstatboost([0,0,0,2,0,0,0]) +selfstatboost([0,0,0,0,2,0,0]) +selfstatboost([0,0,0,0,0,2,0])+ selfstatboost([0,0,0,0,0,0,2])
				miniscore/=7
			when 0x38 # Cotton Guard
				miniscore = selfstatboost([0,3,0,0,0,0,0])
			when 0x39 # Tail Glow
				miniscore = selfstatboost([0,0,3,0,0,0,0])
			when 0x3a # Belly Drum
				statarray = [6,0,0,0,0,0,0]
				statarray = [6,1,0,0,1,0,0] if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::BIGTOPA
				miniscore = selfstatboost(statarray) ** 1.4 #More extreme scoring
				miniscore *= 0.3 if !@attacker.moves.any?{|moveloop| moveloop!=nil && moveloop.basedamage > 0 && moveloop.pbIsPriorityMoveAI(@attacker)} && !pbAIfaster?()
				miniscore *= 1.2 if @attacker.turncount<1
				miniscore = 1 if (@attacker.hp.to_f)/@attacker.totalhp <= 0.5
			when 0x3b # Superpower
				statarray = [1,1,0,0,0,0,0]
				if @attacker.ability == PBAbilities::CONTRARY
					miniscore = selfstatboost(statarray)
				else
					miniscore = selfstatdrop(statarray,score)
					miniscore*=1.5 if @attacker.ability == PBAbilities::MOXIE
				end
			when 0x3c # Close Combat, Dragon Ascent
				statarray = [0,1,0,0,1,0,0]
				if @attacker.ability == PBAbilities::CONTRARY
					miniscore = selfstatboost(statarray)
				else
					miniscore = selfstatdrop(statarray,score)
				end
			when 0x3d # V-Create
				statarray = [0,1,1,0,1,0,0]
				if @attacker.ability == PBAbilities::CONTRARY
					miniscore = selfstatboost(statarray)
				else
					miniscore = selfstatdrop(statarray,score)
				end
			when 0x3e # Hammer Arm, Ice Hammer
				statarray = [0,0,1,0,0,0,0]
				if @attacker.ability == PBAbilities::CONTRARY || @battle.trickroom > 2
					miniscore = selfstatboost(statarray)
				else
					miniscore = selfstatdrop(statarray,score)
				end
			when 0x3f # Overheat, Draco Meteor, Leaf Storm, Psycho Boost, Flear Cannon
				statarray = [0,0,0,2,0,0,0]
				if @attacker.ability == PBAbilities::CONTRARY
					miniscore = selfstatboost(statarray)
				else
					miniscore = selfstatdrop(statarray,score)
					miniscore *=1.3 if @attacker.ability == PBAbilities::SOULHEART
				end
			when 0x40 # Flatter
				miniscore = oppstatboost([0,0,0,1,0])
			when 0x41 # Swagger
				miniscore = oppstatboost([1,0,0,0,0])
			when 0x42 # Growl, Aurora Beam, Baby-Doll Eyes, Play Nice, Play Rough, Lunge, Trop Kick
				miniscore=oppstatdrop([1,0,0,0,0,0,0])
				if @mondata.skill >= BESTSKILL
					miniscore*=selfstatboost([0,0,1,0,0,0,0]) if @move.id==PBMoves::LUNGE && @battle.FE == PBFields::ICYF
					miniscore*=2 if @move.id==PBMoves::AURORABEAM && mirrorNeverMiss && @battle.FE == PBFields::MIRRORA
				end
			when 0x43 # Tail Whip, Crunch, Rock Smash, Crush Claw, Leer, Iron Tail, Razor Shell, Fire Lash, Liquidation, Shadow Bone
				miniscore=oppstatdrop([0,1,0,0,0,0,0])
			when 0x44 # Rock Tomb, Electroweb, Low Sweep, Bulldoze, Mud Shot, Glaciate, Icy Wind, Constrict, Bubble Beam, Bubble
				miniscore=oppstatdrop([0,0,1,0,0,0,0])
				if @move.id == PBMoves::BULLDOZE
					if @mondata.skill >= BESTSKILL
						if @battle.FE == PBFields::ICYF # Icy Field
							if @battle.field.backup== 21 # Water Surface
								currentfieldscore = getFieldDisruptScore(@attacker,@opponent,@battle.FE) # the higher the better for opp
								newfieldscore = getFieldDisruptScore(@attacker,@opponent,21)
								miniscore = currentfieldscore/newfieldscore
							else
								miniscore*=1.2 if @opponent.pbNonActivePokemonCount>2
								miniscore*=0.8 if @attacker.pbNonActivePokemonCount>2
							end
						end
						if @battle.FE == PBFields::CAVE
							if @attacker.ability != PBAbilities::ROCKHEAD && @attacker.ability != PBAbilities::BULLETPROOF
								miniscore*=0.7
								miniscore *= 0.3 if @battle.field.counter >=1
							end
						end
					end
				end
			when 0x45 # Snarl, Struggle Bug, Mist Ball, Confide, Moonblast, Mystical Fire
				miniscore=oppstatdrop([0,0,0,1,0,0,0])
			when 0x46 # Psychic, Bug Buzz, Focus Blast, Shadow Ball, Energy Ball, Earth Power, Acid, Luster Purge, Flash Cannon
				miniscore=oppstatdrop([0,0,0,0,1,0,0])
				if @mondata.skill >= BESTSKILL
					miniscore*=2 if (@move.id==PBMoves::FLASHCANNON || @move.id==PBMoves::LUSTERPURGE) && mirrorNeverMiss && @battle.FE == PBFields::MIRRORA
				end
			when 0x47 # Sand Attack, Night Daze, Leaf Tornado, Mod Bomb, Mud-Slap, Flash, Smokescreen, Kinesis, Mirror Shot, Muddy Water, Octazooka
				statarray = [0,0,0,0,0,1,0]
				if @mondata.skill >= BESTSKILL
					statarray = [0,0,0,0,0,2,0] if (@move.id==PBMoves::KINESIS && @battle.FE == PBFields::ASHENB) || (@move.id==PBMoves::SANDATTACK && (@battle.FE == PBFields::ASHENB || @battle.FE == PBFields::DESERTF))
					statarray = [0,0,0,0,0,2,0] if @move.id==PBMoves::FLASH && (@battle.FE == PBFields::DARKCRYSTALC || @battle.FE == PBFields::SHORTCIRCUITF || @battle.FE == PBFields::MIRRORA || @battle.FE == PBFields::STARLIGHTA || @battle.FE == PBFields::NEWW)
					statarray = [0,0,0,0,0,2,0] if @move.id==PBMoves::SMOKESCREEN && (@battle.FE == PBFields::BURNINGF || @battle.FE == PBFields::CORROSIVEMISTF)
					statarray = [0,0,0,0,0,2,0] if (@move.id==PBMoves::KINESIS && @battle.FE == PBFields::PSYCHICT)
				end
				miniscore=oppstatdrop(statarray)
				if @mondata.skill >= BESTSKILL
					miniscore*=selfstatboost([2,0,0,2,0,0,0]) if @move.id==PBMoves::KINESIS && @battle.FE == PBFields::PSYCHICT
					miniscore*=2 if @move.id==PBMoves::MIRRORSHOT && mirrorNeverMiss && @battle.FE == PBFields::MIRRORA
					miniscore*=0.7 if @move.id==PBMoves::LEAFTORNADO && @battle.FE == PBFields::ASHENB
				end
				if move.id==PBMoves::MUDDYWATER
					miniscore*=0.7 if @battle.FE == PBFields::SUPERHEATEDF # Superheated
					if @battle.FE == PBFields::DRAGONSD # Dragon's Den
						miniscore*= pbPartyHasType?(PBTypes::FIRE) || pbPartyHasType?(PBTypes::DRAGON) ? 0 : 1.5
					end
				end
			when 0x48 # Sweet Scent
				statarray = [0,0,0,0,0,0,1]
				if @mondata.skill >= BESTSKILL
					statarray = [0,1,0,0,1,0,1] if @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter==2
					statarray = [0,2,0,0,2,0,2] if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter==3
					statarray = [0,3,0,0,3,0,3] if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter==4
				end
				miniscore*=oppstatdrop([1,1,0,0,0,0,0])
			when 0x49 # Defog
				miniscore = defogcode()
			when 0x4a # Tickle
				miniscore = oppstatdrop([1,1,0,0,0,0,0])
			when 0x4b # Feather Dance, Charm
				statarray = [2,0,0,0,0,0,0]
				statarray = [3,0,0,0,0,0,0] if @mondata.skill >= BESTSKILL && @move.id == PBMoves::FEATHERDANCE && @battle.FE == PBFields::BIGTOPA
				miniscore = oppstatdrop(statarray)
			when 0x4c # Screech
				miniscore = oppstatdrop([0,2,0,0,0,0,0])
			when 0x4d # Scary Face, String Shot, Cotton Spore
				miniscore = oppstatdrop([0,0,2,0,0,0,0])
			when 0x4e # Captivate
				agender=@attacker.gender
				ogender=@opponent.gender
				if (agender==2 || ogender==2 || agender==ogender || @opponent.effects[PBEffects::Attract]>=0 || @opponent.ability == PBAbilities::OBLIVIOUS || @battle.pbCheckSideAbility(:AROMAVEIL,@opponent)!=nil && !moldBreakerCheck(@attacker))
					miniscore = 0
				else
					miniscore = oppstatdrop([0,0,0,2,0,0,0])
				end
			when 0x4f # Acid Spray, Seed Flare, Metal Sound, Fake Tears
				statarray = [0,0,0,0,2,0,0]
				statarray = [0,0,0,0,3,0,0] if @mondata.skill >= BESTSKILL && @move.id==PBMoves::METALSOUND && (@battle.FE == PBFields::FACTORYF || @battle.FE == PBFields::SHORTCIRCUITF)
				miniscore = oppstatdrop(statarray)
			when 0x50 # Clear Smog
				miniscore = oppstatrestorecode()
				miniscore *= nevermisscode(initialscores[scoreindex])
			when 0x51 # Haze
				miniscore = hazecode()
			when 0x52 # Power Swap
				miniscore = statswapcode(PBStats::ATTACK,PBStats::SPATK)
			when 0x53 # Guard Swap
				miniscore = statswapcode(PBStats::DEFENSE,PBStats::SPDEF)
			when 0x54 # Heart Swap
				boostarray,droparray = psychupcode()
				buffscore = selfstatboost(boostarray.clone) - selfstatdrop(droparray.clone,score)
				dropscore = oppstatdrop(boostarray.clone) - selfstatboost(droparray.clone)
				miniscore = buffscore + dropscore
				miniscore = 25 if miniscore == 0 && @battle.FE == PBFields::NEWW
				miniscore *= splitcode(PBStats::HP) if @battle.FE == PBFields::NEWW
			when 0x55 # Psych Up
				boostarray,droparray = psychupcode()
				boostarray[3] += 2 if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::PSYCHICT
				actualopp = @opponent
				@opponent = firstOpponent() if @opponent.index == @attacker.pbPartner.index
				miniscore = selfstatboost(boostarray) - selfstatdrop(droparray.clone,score)
				stagecounter=boostarray.sum - droparray.sum
				miniscore*= 1.3 if stagecounter>=3
				miniscore*= [1,refreshcode()].max if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::ASHENB
				@opponent = actualopp
			when 0x56 # Mist
				miniscore = mistcode()
				fieldscore = 1
				if @attacker.item!=PBItems::EVERSTONE && @battle.canChangeFE?(PBFields::MISTYT)
					fieldscore=getFieldDisruptScore(@attacker,@opponent)
					fieldscore*=1.3 if pbPartyHasType?(PBTypes::FAIRY)
					fieldscore*=1.3 if @opponent.pbHasType?(:DRAGON) && !@attacker.pbHasType?(:FAIRY)
					fieldscore*=0.5 if @attacker.pbHasType?(:DRAGON)
					fieldscore*=0.5 if @opponent.pbHasType?(:FAIRY)
					fieldscore*=1.5 if @attacker.pbHasType?(:FAIRY) && @opponent.spatk>@opponent.attack
					fieldscore*=2   if @mondata.attitemworks && @attacker.item == PBItems::AMPLIFIELDROCK
				end
				score*=0 if miniscore<=1 && fieldscore<=1
				miniscore*= fieldscore
			when 0x57 # Power Trick
				miniscore = powertrickcode()
			when 0x58 # Power Split
				miniscore = splitcode(PBStats::ATTACK)
			when 0x59 # Guard Split
				miniscore = splitcode(PBStats::DEFENSE)
			when 0x5a # Pain Split
				miniscore = splitcode(PBStats::HP)
			when 0x5b # Tailwind
				miniscore = tailwindcode()
				if @mondata.skill>=BESTSKILL
					if @battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM # Mountain/Snowy Mountain
						miniscore*=1.5
						miniscore*=1.5**@battle.pbParty(@attacker.index).count {|mon| mon && mon.hp>0 && mon.hasType?(:FLYING)}
					end
				end
			when 0x5c # Mimic
				miniscore = mimicsketchcode([0x02, 0x14, 0x5C, 0x5D, 0xB6],false) # Struggle, Chatter, Mimic, Sketch, Metronome
			when 0x5d # Sketch
				miniscore = mimicsketchcode([0x02, 0x14, 0x5D],true) #Struggle, Chatter, Sketch
			when 0x5e # Conversion
				miniscore = typechangecode(@attacker.moves[0].type)
				miniscore*=0.3 if @battle.field.conversion==1
				if @attacker.item!=PBItems::EVERSTONE && @battle.canChangeFE?(PBFields::GLITCHF)
					minimini = getFieldDisruptScore(@attacker,@opponent)
					minimini = 1 + (minimini - 1) / 2 if @battle.field.conversion!=2
					miniscore*=minimini
				end
			when 0x5f # Conversion2
				for i in @opponent.moves
					next if i.nil?
					atype=i.pbType(@attacker) if i.id==@opponent.lastMoveUsed
				end
				miniscore = 0
				if atype
					resistedtypes = PBTypes.getTypesThatResist(atype)
					for type in resistedtypes
						miniscore += (typechangecode(type) / resistedtypes.length)
					end
				end
				miniscore*=0.3 if @battle.field.conversion==2
				if @battle.canChangeFE?(PBFields::GLITCHF)
					minimini = getFieldDisruptScore(@attacker,@opponent)
					minimini = 1 + (minimini - 1) / 2 if @battle.field.conversion!=1
					miniscore*=minimini
				end
			when 0x60 # Camouflage
				type = PBTypes::NORMAL
				type = @battle.field.mimicry
				miniscore = typechangecode(type)
			when 0x61 # Soak
				miniscore = opptypechangecode(PBTypes::WATER)
			when 0x62 # Reflect Type
				miniscore1 = typechangecode(@opponent.type1)
				miniscore2 = typechangecode(@opponent.type2)
				miniscore = [miniscore1,miniscore2].max
			when 0x63 # Simple Beam
				miniscore = abilitychangecode(PBAbilities::SIMPLE)
			when 0x64 # Worry Seed
				miniscore = abilitychangecode(PBAbilities::INSOMNIA)
			when 0x65 # Role Play
				minisore = roleplaycode()
			when 0x66 # Entrainment
				score = entraincode(score)
			when 0x67 # Skill Swap
				minisore = skillswapcode()
			when 0x68 #Gastro Acid
				miniscore = gastrocode()
			when 0x69 # Transform
				minisore = transformcode()
			#when 0x6A # Sonicboom
			#when 0x6B # Dragon Rage
			#when 0x6C # Super Fang, Nature Madness
			#when 0x6D # Seismic Toss, Night Shade
			when 0x6e # Endeavor
				miniscore = endeavorcode()
			when 0x70 # Fissure, Sheer Cold, Guillotine, Horn Drill
				miniscore = ohkode()
				if @mondata.skill >= BESTSKILL
					if @move.id == PBMoves::FISSURE
						if @battle.FE == PBFields::ICYF # Icy Field
							if @battle.field.backup== 21 # Water Surface
								currentfieldscore = getFieldDisruptScore(@attacker,@opponent,@battle.FE) # the higher the better for opp
								newfieldscore = getFieldDisruptScore(@attacker,@opponent,21)
								miniscore = currentfieldscore/newfieldscore
							else
								miniscore*=1.2 if @opponent.pbNonActivePokemonCount>2
								miniscore*=0.8 if @attacker.pbNonActivePokemonCount>2
							end
						end
					end
				end
			when 0x71..0x73 # Counter, Mirror Coat, Metal Burst
				miniscore = counterattackcode()
				miniscore*= Math.sqrt(selfstatboost([0,1,0,0,1,0,1])) if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::MIRRORA && @move.id==PBMoves::MIRRORCOAT
			when 0x74 # Flame Burst
				miniscore *= 1.1 if @battle.doublebattle
			when 0x75 # Surf
				if @mondata.skill >= BESTSKILL
					miniscore*=0.7 if @battle.FE == PBFields::SUPERHEATEDF
					miniscore*= (pbPartyHasType?(PBTypes::DRAGON) || pbPartyHasType?(PBTypes::FIRE)) ? 0 : 1.5  if @battle.FE == PBFields::DRAGONSD
				end
			when 0x76 # Earthquake
				if @mondata.skill >= BESTSKILL
					if @battle.FE == PBFields::ICYF # Icy Field
						if @battle.field.backup== 21 # Water Surface
							currentfieldscore = getFieldDisruptScore(@attacker,@opponent,@battle.FE) # the higher the better for opp
							newfieldscore = getFieldDisruptScore(@attacker,@opponent,21)
							miniscore = currentfieldscore/newfieldscore
						else
							miniscore*=1.2 if @opponent.pbNonActivePokemonCount>2
							miniscore*=0.8 if @attacker.pbNonActivePokemonCount>2
						end
					end
					if @battle.FE == PBFields::CAVE && @move.id==PBMoves::EARTHQUAKE
						if @attacker.ability != PBAbilities::ROCKHEAD && @attacker.ability != PBAbilities::BULLETPROOF
							miniscore*=0.7
							miniscore *= 0.3 if @battle.field.counter >=1
						end
					end
				end
			when 0x77 # Gust
			when 0x78 # Twister
				miniscore = flinchcode()
				miniscore*=0.7 if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::ASHENB
			#when 0x79 # Fusion Bolt, Fusion Flare, Venoshock
			when 0x7c # Smelling Salts
				if @opponent.status==PBStatuses::PARALYSIS  && @opponent.effects[PBEffects::Substitute]<=0
					score*=0.8
					score*=0.5 if @opponent.speed>@attacker.speed && @opponent.speed/2.0<@attacker.speed
				end
			when 0x7d # Wake-up Slap
				if @opponent.status==PBStatuses::SLEEP && @opponent.effects[PBEffects::Substitute]<=0
					score*=0.8
					score*=0.3 if @attacker.ability == PBAbilities::BADDREAMS || @attacker.pbHasMove?(PBMoves::DREAMEATER) || @attacker.pbHasMove?(PBMoves::NIGHTMARE)
					score*=1.3 if checkAImoves([PBMoves::SLEEPTALK, PBMoves::SNORE])
				end
			#when 0x7E..0x80 # Facade, Hex, Brine
			when 0x81 # Revenge, Avalanche
				miniscore = revengecode()
			when 0x82 # Assurance
				score*=1.5 if !pbAIfaster?(@move)
			when 0x83 # Round
				score*=1.5 if @battle.doublebattle && @attacker.pbPartner.pbHasMove?(PBMoves::ROUND)
			when 0x84 # Payback
				score*=2 if !pbAIfaster?(@move)
			#when 0x85..0x87 # Retaliate, Acrobatics, Weather Ball
			when 0x88 # Pursuit
				miniscore = pursuitcode()
			#when 0x89..0x8a # Return, Frustration
			when 0x8B # Water Spout, Eruption
				if !pbAIfaster?(@move)
					original_power = [(150*(attacker.hp.to_f)/attacker.totalhp),1.0].max
					actual_power = [(150*(attacker.hp.to_f - checkAIdamage())/attacker.totalhp),1.0].max
					score*= actual_power / original_power
				end
				if @mondata.skill >= BESTSKILL
					if @move.id==PBMoves::WATERSPOUT
						score*=0.7 if @battle.FE == PBFields::SUPERHEATEDF # Superheated
					end
				end
			#when 0x8C..0x90 # Crush Grip, Wring Out, Gyro Ball, Stored Power, Pwer Trip, Punishment, Hidden Power
			when 0x91 # Fury Cutter
				miniscore = echocode()
				miniscore *= (1 + 0.15 * @attacker.stages[PBStats::ACCURACY])
				miniscore *= (1 - 0.08 * @opponent.stages[PBStats::EVASION])
				miniscore*=0.8 if checkAImoves(PBStuff::PROTECTMOVE)
			when 0x92 # Echoed Voice
				miniscore = echocode()
			when 0x93 # Rage
				score*=1.2 if @attacker.attack>@attacker.spatk
				score*=1.3 if @attacker.hp==@attacker.totalhp
				score*=1.3 if checkAIdamage()<(@attacker.hp/4.0)
			when 0x94 # Present
				score*=1.2 if @opponent.hp==@opponent.totalhp
			when 0x95 # Magnitude
				if @mondata.skill >= BESTSKILL
					if @battle.FE == PBFields::ICYF # Icy Field
						if @battle.field.backup== 21 # Water Surface
							currentfieldscore = getFieldDisruptScore(@attacker,@opponent,@battle.FE) # the higher the better for opp
							newfieldscore = getFieldDisruptScore(@attacker,@opponent,21)
							miniscore = currentfieldscore/newfieldscore
						else
							miniscore*=1.2 if @opponent.pbNonActivePokemonCount>2
							miniscore*=0.8 if @attacker.pbNonActivePokemonCount>2
						end
					end
					if @battle.FE == PBFields::CAVE
						if @attacker.ability != PBAbilities::ROCKHEAD && @attacker.ability != PBAbilities::BULLETPROOF
							miniscore*=0.7
							miniscore *= 0.3 if @battle.field.counter >=1
						end
					end
				end
			when 0x96 # Natural Gift
				score*=0 if !pbIsBerry?(@attacker.item) || @attacker.ability == PBAbilities::KLUTZ || @battle.state.effects[PBEffects::MagicRoom]>0 || @attacker.effects[PBEffects::Embargo]>0 || @opponent.ability == PBAbilities::UNNERVE
			when 0x97 # Trump Card
				score*=1.2 if @attacker.hp==@attacker.totalhp
				score*=1.3 if checkAIdamage()<(@attacker.hp/3.0)
			when 0x98 # Reversal, Flail
				if !pbAIfaster?(@move)
					score*=1.1
					score*=1.3 if @attacker.hp<@attacker.totalhp
				end
			#when 0x99..0x9b # Electro Ball, Low Kick, Grass Knot, Heat Crash, Heavy Slam
			when 0x9c # Helping Hand
				miniscore = helpinghandcode()
			when 0x9d # Mud Sport
				miniscore = mudsportcode()
				miniscore*= !pbPartyHasType?(PBTypes::ELECTRIC) ? 2 : 0.3 if @battle.FE == PBFields::ELECTRICT
			when 0x9e # Water Sport
				miniscore = watersportcode()
				miniscore*= !pbPartyHasType?(PBTypes::FIRE) ? 2 : 0 if @battle.FE == PBFields::BURNINGF
				if @battle.FE == PBFields::SUPERHEATEDF
					miniscore*=0.7
					miniscore*= !pbPartyHasType?(PBTypes::FIRE) ? 1.8 : 0
				elsif @battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FORESTF || @battle.FE == PBFields::FLOWERGARDENF
					miniscore*=3 if !@attacker.hasType?(:FIRE) && @opponent.hasType?(:FIRE)
					miniscore*=0.5 if pbPartyHasType?(PBTypes::FIRE)
					if pbPartyHasType?(PBTypes::GRASS) || pbPartyHasType?(PBTypes::BUG)
						miniscore*=2
						miniscore*=3 if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter<4
					end
				end
			#when 0x9f # Judgement, Techno Blast, Multi-Attack
			when 0xa0 # Frost Breath, Storm Throw
				miniscore = permacritcode(initialscores[scoreindex])
			when 0xa1 # Lucky Chant
				score+=20 if @attacker.pbOwnSide.effects[PBEffects::LuckyChant]==0  && @attacker.ability != PBAbilities::BATTLEARMOR || @attacker.ability != PBAbilities::SHELLARMOR && (@opponent.effects[PBEffects::FocusEnergy]>1 || @opponent.effects[PBEffects::LaserFocus]>0)
			when 0xa2 # Reflect
				miniscore = screencode()
				miniscore+= [0,selfstatboost([0,0,0,0,0,0,1])-1].max if  @mondata.skill >=BESTSKILL && @battle.FE == PBFields::MIRRORA
			when 0xa3 # Light Screen
				miniscore = screencode()
				miniscore+= [0,selfstatboost([0,0,0,0,0,0,1])-1].max if  @mondata.skill >=BESTSKILL && @battle.FE == PBFields::MIRRORA
			when 0xa4 # Secret Power
				miniscore = secretcode()
			when 0xa5 # Shock Wave, Feint Attack, Aura Sphere, Vital Throw, Aerial Ace, Shadow Punch, Swift, Magnet Bomb, Disarming Voice, Smart Strike
				miniscore = nevermisscode(initialscores[scoreindex])
			when 0xa6 # Lock On, Mind Reader
				miniscore = lockoncode()
				if @battle.FE == PBFields::PSYCHICT && @move.id == PBMoves::MINDREADER
					miniscore*=selfstatboost([0,0,2,0,0,0,0])
					score+=10 if attacker.stages[PBStats::SPATK]<6
				end
			when 0xa7 # Foresight, Odor Sleuth
				miniscore = forecode5me()
			when 0xa8 # Miracle Eye
				miniscore = miracode()
				if @battle.FE == PBFields::PSYCHICT || @battle.FE == PBFields::HOLYF || @battle.FE == PBFields::FAIRYTALEF
					score+=10 if attacker.stages[PBStats::SPATK]<6
					miniscore*=selfstatboost([0,0,2,0,0,0,0])
				end
			when 0xa9 # Chip Away, Sacred Sword, Darkest Lariat
				miniscore = chipcode()
			when 0xaa # Protect, Detect
				miniscore = protectcode()
			when 0xab # Quick Guard
				if (@opponent.ability == PBAbilities::GALEWINGS && @opponent.hp == @opponent.totalhp) || (@opponent.ability == PBAbilities::PRANKSTER && @attacker.pbHasType?(:DARK)) || checkAIpriority()
					miniscore = specialprotectcode()
				else
					miniscore = 0
				end
			when 0xac # Wide Guard
				if getAIMemory().any? {|moveloop| moveloop!=nil && (moveloop.target == PBTargets::AllOpposing || moveloop.target == PBTargets::AllNonUsers)}
					miniscore = specialprotectcode()
					if @battle.FE == PBFields::CORROSIVEMISTF
						miniscore*=2 if checkAImoves([PBMoves::HEATWAVE,PBMoves::LAVAPLUME,PBMoves::ERUPTION,PBMoves::MINDBLOWN])
					end
					if @battle.FE == PBFields::CAVE
						miniscore*=2 if checkAImoves(PBFields::QUAKEMOVES)
					end
					if @battle.FE == PBFields::MIRRORA
						miniscore*=2 if (checkAImoves([PBMoves::MAGNITUDE,PBMoves::EARTHQUAKE,PBMoves::BULLDOZE]) || checkAImoves([PBMoves::HYPERVOICE,PBMoves::BOOMBURST]))
					end
				else
					miniscore=0
				end
			when 0xad # Feint
				miniscore = feintcode()
			when 0xae # Mirror Move
				score = mirrorcode(false) #changes actual score so no miniscore
				score+= 10*selfstatboost([1,0,0,1,0,0,1]) if @mondata.skill >=BESTSKILL && @battle.FE == PBFields::MIRRORA
			when 0xaf # Copycat
				if @opponent.effects[PBEffects::Substitute]<=0
					score = mirrorcode(true) #changes actual score so no miniscore
				else
					score=0
				end
			when 0xb0 # Me First
				miniscore = yousecondcode()
			when 0xb1 # Magic Coat
				miniscore = coatcode()
			when 0xb2 # Snatch
				miniscore = snatchcode()
			when 0xb3 # Nature Power
				#we should never need this- nature power should be changed in advance
			when 0xb4 # Sleep Talk
				miniscore = sleeptalkcode()
			when 0xb5 # Assist
				miniscore = metronomecode(25)
			when 0xb6 # Metronome
				miniscore = metronomecode(20)
				miniscore = metronomecode(40) if @battle.FE == PBFields::GLITCHF
			when 0xb7 # Torment
				miniscore = tormentcode()
			when 0xb8 # Imprison
				miniscore = imprisoncode()
			when 0xb9 # Disable
				miniscore = disablecode()
			when 0xba # Taunt
				miniscore = tauntcode()
			when 0xbb # Heal Block
				miniscore = healblockcode()
			when 0xbc # Encore
				miniscore = encorecode()
			when 0xbd # Double Kick, Dual Chop, Bonemerang, Double Hit, Gear Grind
				miniscore = multihitcode()
			when 0xbe # Twinneedle
				miniscore = poisoncode ** 1.2
				miniscore *= multihitcode()
			when 0xbf # Triple Kick
				miniscore = multihitcode()
			when 0xc0 # Bullet Seed, Pin Missile, Arm Thrust, Bone Rush, Icicle Spear, Tail Slap, Spike Cannon, Comet Punch, Furey Swipes, Barrage, Double Slap, Fury Attacj, Rock Blast, Water Shuriken
				miniscore = multihitcode()
			when 0xc1 # Beat Up
				if @opponent.index == @attacker.pbPartner.index
					score = beatupcode(initialscores[scoreindex])
				else
					miniscore = multihitcode() if @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))>0
				end
			when 0xc2 # Hyper Beam, Roar of Time, Blast Burn, Frenzy Plant, Giga Impact, Rock Wrecker, Hydro Cannon, Prismatic Laser
				miniscore = hypercode()
			when 0xc3 # Weasel Slash
				miniscore = weaselslashcode()
			when 0xc4 # Solar Beam, Solar Blade
				#if we first want to use sunny day for instant move later
				if @battle.pbWeather!=PBWeather::SUNNYDAY && @attacker.pbHasMove?(PBMoves::SUNNYDAY) && !(@battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE) || @battle.pbCheckGlobalAbility(:DELTASTREAM) ||
					@battle.pbCheckGlobalAbility(:DESOLATELAND) || @battle.pbCheckGlobalAbility(:PRIMORDIALSEA) || @attacker.item == PBItems::POWERHERB || @battle.FE == PBFields::UNDERWATER || @battle.FE == PBFields::NEWW || @battle.FE == PBFields::RAINBOWF)
					miniscore = 0.3
				else
					miniscore = weaselslashcode() if @battle.pbWeather!=PBWeather::SUNNYDAY || @battle.FE != PBFields::RAINBOWF
				end
				miniscore = 0 if @battle.FE == PBFields::DARKCRYSTALC
			when 0xc5 # Freeze Shock
				miniscore = paracode()
				miniscore *= weaselslashcode()
			when 0xc6 # Ice Burn
				miniscore = burncode()
				miniscore *= weaselslashcode()
			when 0xc7 # Sky Attack
				miniscore = flinchcode()
				miniscore *= weaselslashcode()
			when 0xc8 # Skull Bash
				miniscore = selfstatboost([0,1,0,0,0,0,0])
				miniscore *= weaselslashcode()
			when 0xc9 # Fly
				if @attacker.ability == PBAbilities::NOGUARD || @opponent.ability == PBAbilities::NOGUARD || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
					miniscore = weaselslashcode()
				else
					miniscore = twoturncode()
					miniscore*=0.3 if checkAImoves([PBMoves::THUNDER,PBMoves::HURRICANE])
				end
				miniscore=0 if @battle.state.effects[PBEffects::Gravity]>0
			when 0xca # Dig
				if @attacker.ability == PBAbilities::NOGUARD || @opponent.ability == PBAbilities::NOGUARD || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
					miniscore = weaselslashcode()
				else
					miniscore = twoturncode()
					miniscore*=0.3 if checkAImoves([PBMoves::EARTHQUAKE])
				end
			when 0xcb # Dive
				if @attacker.ability == PBAbilities::NOGUARD || @opponent.ability == PBAbilities::NOGUARD || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
					miniscore = weaselslashcode()
				else
					miniscore = twoturncode()
					miniscore*=0.3 if checkAImoves([PBMoves::SURF])
				end
				if @battle.FE == PBFields::MURKWATERS # Murkwater Surface
					miniscore*=0.3 if !@attacker.pbHasType?(PBTypes::POISON) && !@attacker.pbHasType?(PBTypes::STEEL)
				end
			when 0xcc # Bounce
				if @attacker.ability == PBAbilities::NOGUARD || @opponent.ability == PBAbilities::NOGUARD || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
					miniscore = weaselslashcode()
				else
					miniscore = twoturncode()
					miniscore*= 0.3 if checkAImoves([PBMoves::THUNDER,PBMoves::HURRICANE])
				end
				miniscore*= paracode()
				miniscore = 0 if @battle.state.effects[PBEffects::Gravity]>0
			when 0xcd # Phantom Force, Phantom Force
				if @attacker.ability == PBAbilities::NOGUARD || @opponent.ability == PBAbilities::NOGUARD || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
					miniscore = weaselslashcode()
				else
					miniscore = twoturncode()
				end
				miniscore*=1.1 if checkAImoves(PBStuff::PROTECTMOVE)
			when 0xce # Sky Drop
				if @attacker.ability == PBAbilities::NOGUARD || @opponent.ability == PBAbilities::NOGUARD || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
					miniscore = weaselslashcode()
				else
					miniscore = twoturncode()
				end
				miniscore=0 if @battle.state.effects[PBEffects::Gravity]>0
			when 0xcf # Fire Spin, Magma Storm, Sand Tomb, Bind, Clamp, Wrap, Infestation
				miniscore = firespincode()
				case @move.id
				when PBMoves::FIRESPIN
					miniscore*=0.7 if @battle.FE == PBFields::ASHENB
					miniscore*=1.3 if @battle.FE == PBFields::BURNINGF
				when PBMoves::SANDTOMB
					miniscore*=1.3 if @battle.FE == PBFields::DESERTF
					score+=10*oppstatdrop([0,0,0,0,0,1,0]) unless opponent.stages[PBStats::ACCURACY]<(-2) if @battle.FE == PBFields::ASHENB
				when PBMoves::INFESTATION
					miniscore*=1.3 if @battle.FE == PBFields::FORESTF
					if @battle.FE == PBFields::FLOWERGARDENF
						miniscore*=1.3
						miniscore*=1.3 if @battle.field.counter == 3
						miniscore*=1.5 if @battle.field.counter == 4
					end
				end
			when 0xd0 # Whirlpool
				miniscore = firespincode()
				miniscore*=1.3 if $cache.pkmn_move[@opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCB
				miniscore*=0.7 if @battle.FE == PBFields::ASHENB
				if @battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER
					miniscore*=1.3
					miniscore*=confucode() if opponent.effects[PBEffects::Confusion]<=0
				end
				if @battle.FE == PBFields::MURKWATERS
					miniscore+=10 if miniscore==0
					miniscore*=1.5 if !(attacker.pbHasType?(:POISON) || attacker.pbHasType?(:STEEL))
					miniscore*=2 if !pbPartyHasType?(PBTypes::POISON)
					miniscore*=2 if pbPartyHasType?(PBTypes::WATER)
				end

			when 0xd1 # Uproar
				miniscore = uproarcode()
			when 0xd2 # Outrage, Petal Dance, Thrash
				miniscore*=outragecode(score)
				if @mondata.skill>=BESTSKILL
					if @battle.FE == PBFields::SUPERHEATEDF && @attacker.ability != PBAbilities::OWNTEMPO # Superheated Field
						miniscore*=0.5
					end
					if @move.id==PBMoves::PETALDANCE
						miniscore*=1.5 if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>1
					end
					if @move.id==PBMoves::OUTRAGE
						miniscore*=0.8 if @battle.FE != PBFields::INVERSEF && pbPartyHasType?(PBTypes::FAIRY,@opponent.index)
					end
					if @move.id==PBMoves::THRASH
						miniscore*=0.8 if @battle.FE != PBFields::INVERSEF && pbPartyHasType?(PBTypes::GHOST,@opponent.index)
					end
				end
			when 0xd3 # Rollout, Ice Ball
				miniscore = rolloutcode()
				score+=10*selfstatboost([0,0,1,0,0,0,0]) if @mondata.skill>=BESTSKILL && @battle.FE == PBFields::ICYF && @move.id==PBMoves::ROLLOUT
			when 0xd4 # Bide
				miniscore = bidecode()
			when 0xd5 # Recover, Heal Order, Milk Drink, Slack Off, Soft-Boiled
				recoveramount = @attacker.totalhp/2.0
				recoveramount = @attacker.totalhp*0.66 if @mondata.skill>=BESTSKILL && @move.id==PBMoves::HEALORDER && @battle.FE == PBFields::FORESTF # Forest
				miniscore = recovercode(recoveramount)
			when 0xd6 # Roost
				miniscore = recovercode()
				bestmove=checkAIbestMove()
				if pbAIfaster?(@move) && @attacker.pbHasType?(:FLYING)
					if [PBTypes::ROCK,PBTypes::ICE,PBTypes::ELECTRIC].include?(bestmove.pbType(@opponent))
						score*=1.5
					elsif [PBTypes::GRASS,PBTypes::BUG,PBTypes::FIGHTING,PBTypes::GROUND].include?(bestmove.pbType(@opponent))
						score*=0.5
					end
				end
			when 0xd7 # Wish
				miniscore = wishcode()		
				miniscore*=1.2 if @mondata.skill>=BESTSKILL && (@battle.FE == PBFields::MISTYT || @battle.FE == PBFields::RAINBOWF || @battle.FE == PBFields::HOLYF || @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::STARLIGHTA) # Misty/Rainbow/Holy/Fairytale/Starlight
			when 0xd8 # Synthesis, Moonlight, Morning Sun
				recoveramount = @attacker.totalhp/2.0
				recoveramount = @attacker.totalhp*0.25 if @battle.pbWeather != 0 || (@mondata.skill>=BESTSKILL && @battle.FE == PBFields::DARKCRYSTALC && (@move.id==PBMoves::SYNTHESIS || @move.id==PBMoves::MORNINGSUN))
				recoveramount = @attacker.totalhp*0.75 if @mondata.skill>=BESTSKILL && (@battle.FE == PBFields::DARKCRYSTALC || @battle.FE == PBFields::STARLIGHTA || @battle.FE == PBFields::NEWW) && @move.id==PBMoves::MOONLIGHT
				recoveramount = @attacker.totalhp*0.66 if @battle.pbWeather == PBWeather::SUNNYDAY

				miniscore = recovercode(recoveramount)

				if @mondata.skill>=BESTSKILL
					if @move.id==PBMoves::SYNTHESIS || @move.id==PBMoves::MORNINGSUN
						miniscore*=0.5 if @battle.FE == PBFields::DARKCRYSTALC
					end
				end
			when 0xd9 # Rest
				miniscore = restcode()
			when 0xda # Aqua Ring
				miniscore = aquaringcode()
				if @mondata.skill>=BESTSKILL
					miniscore*=1.3 if @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::SWAMPF || @battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER
					miniscore*=1.3 if @battle.FE == PBFields::BURNINGF
					miniscore*=0.3 if @battle.FE == PBFields::CORROSIVEMISTF
				end
			when 0xdb # Ingrain
				miniscore = aquaringcode()
				if @mondata.skill>=BESTSKILL
					if @battle.FE == PBFields::FORESTF || @battle.FE == PBFields::FLOWERGARDENF
						miniscore*=1.3
						miniscore*=1.3 if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>3
					end
					if @battle.FE == PBFields::SWAMPF
						miniscore*=0.1 unless (@attacker.pbHasType?(:POISON) || @attacker.pbHasType?(:STEEL))
					end
					miniscore*=0.1 if @battle.FE == PBFields::CORROSIVEF
				end
			when 0xdc # Leech Seed
				miniscore = leechcode()
			when 0xdd # Absorb. Leech Life, Drain Punch, Giga Drain, Horn Leech, Mega Drain, Parabolic Charge
				miniscore = absorbcode(initialscores[scoreindex])
			when 0xde # Dream Eater
				miniscore = absorbcode(initialscores[scoreindex]) if @opponent.status==PBStatuses::SLEEP
				miniscore = 0 if @opponent.status!=PBStatuses::SLEEP
			when 0xdf # Heal Pulse
				miniscore = healpulsecode()
				miniscore*=1.5 if @attacker.ability == PBAbilities::MEGALAUNCHER
			when 0xe0 # Explosion, Self-Destruct
				miniscore = deathcode()
				score*=1.5 if @battle.FE == PBFields::GLITCHF
				score*=0 if @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::SWAMPF || @battle.pbCheckGlobalAbility(:DAMP)
			when 0xe1 # Final Gambit
				miniscore = gambitcode()
			when 0xe2 # Memento
				score = mementcode(score)
			when 0xe3 # Healing Wish
				miniscore = healwishcode()
				miniscore*=1.4 if @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::STARLIGHTA
			when 0xe4 # Lunar Dance
				miniscore = healwishcode()
				if @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::STARLIGHTA
					miniscore*=1.4
				elsif @battle.FE == PBFields::NEWW
					miniscore*=2
				end
			when 0xe5 # Perish Song
				miniscore = perishcode()
			when 0xe6 # Grudge
				miniscore = deathcode()
				miniscore*= grudgecode()
			when 0xe7 # Destiny Bond
				miniscore = destinycode()
			when 0xe8 # Endure
				miniscore*=endurecode()
				miniscore*=0 if @battle.FE == PBFields::BURNINGF || @battle.FE == PBFields::MURKWATERS
			when 0xe9 # False Swipe
				miniscore = 0.1 if score>=100
			when 0xea # Teleport
				score=0
			when 0xeb # Roar, Whirlwind
				miniscore = phasecode()
			when 0xec # Dragon Tail, Circle Throw
				miniscore = phasecode() if @opponent.effects[PBEffects::Substitute]<=0 && !(@opponent.effects[PBEffects::Ingrain] || @opponent.ability == PBAbilities::SUCTIONCUPS || @opponent.pbNonActivePokemonCount==0 || @opponent.effects[PBEffects::PerishSong]>0 || @opponent.effects[PBEffects::Yawn]>0)
			when 0xed # Baton Pass
				miniscore = pivotcode()
			when 0xee # U-turn, Volt Switch
				miniscore = pivotcode()
			when 0xef # Mean Look, Block, Spider Web
				miniscore = meanlookcode()
			when 0xf0 # Knock Off
				miniscore = knockcode()
			when 0xf1 # Covet, Thief
				miniscore = covetcode()
			when 0xf2 # Trick, Switcheroo
				miniscore = covetcode()
				miniscore *= bestowcode()
			when 0xf3 # Bestow
				miniscore = bestowcode()
			when 0xf4 # Bug Bite, Pluck
				miniscore = nomcode()
			when 0xf5 # Incinerate
				miniscore = roastcode()
			when 0xf6 # Recycle
				miniscore = recyclecode()
			when 0xf7 # Fling
				miniscore = flingcode()
			when 0xf8 # Embargo
				miniscore = embarcode()
			when 0xf9 # Magic Room
				attitemscore=[embarcode(@attacker), 1].max
				miniscore = (embarcode() / attitemscore)
				miniscore*=0 if @battle.state.effects[PBEffects::MagicRoom]>0
			when 0xfa..0xfc # Take Down, Head Charge, Submission, Wild Charge, Wood Hammer, Brave Bird, Double-Edge, Head Smash
				recoilamount = {0xfa => 0.25, 0xfb => 0.3333, 0xfc => 0.5}
				miniscore = recoilcode(recoilamount[@move.function])
			when 0xfd # Volt Tackle
				miniscore = recoilcode(0.3333)
				miniscore *= paracode()
			when 0xfe # Flare Blitz
				miniscore = recoilcode(0.3333)
				miniscore *= burncode()
			when 0xff # Sunny Day
				miniscore=weathercode()
				miniscore*=suncode()
				if @battle.pbWeather==PBWeather::RAINDANCE #Making Rainbow Field
					miniscore*= getFieldDisruptScore(@attacker,@opponent)
					miniscore*=1.2 if @attacker.pbHasType?(:NORMAL)
				end
				if @mondata.skill>=BESTSKILL
					miniscore*=1.3 if @battle.FE == PBFields::DESERTF || @battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM # Desert/Mountian/Snowy Mountain
					miniscore*=2   if @battle.FE == PBFields::FLOWERGARDENF # Flower Garden
					miniscore*=2   if @battle.FE == PBFields::STARLIGHTA && !pbPartyHasType?(PBTypes::DARK) && !pbPartyHasType?(PBTypes::FAIRY) && !pbPartyHasType?(PBTypes::PSYCHIC)  # Starlight
					miniscore*=0   if @battle.FE == PBFields::UNDERWATER || @battle.FE == PBFields::NEWW # Underwater or New World
				end
			when 0x100 # Rain Dance
				miniscore=weathercode()
				miniscore*=raincode()
				if @battle.pbWeather==PBWeather::SUNNYDAY #Making Rainbow Field
					miniscore*= getFieldDisruptScore(@attacker,@opponent)
					miniscore*=1.2 if @attacker.pbHasType?(:NORMAL)
				end
				if !@battle.opponent.is_a?(Array)
					if Reborn && (@battle.opponent.trainertype==PBTrainers::SHELLY) && (@battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FORESTF || @battle.FE == PBFields::FLOWERGARDENF) # Shelly
						miniscore *= 4
						#experimental -- cancels out drop if killing moves
						miniscore*=6 if initialscores.length>0 && hasgreatmoves()
						#end experimental
					end
				end
				if @mondata.skill>=BESTSKILL
					miniscore*=1.2 if @battle.FE == PBFields::BIGTOPA # Big Top
					miniscore*=1.5 if @battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FORESTF || @battle.FE == PBFields::SUPERHEATEDF # Grassy/Forest/Superheated
					miniscore*=2   if @battle.FE == PBFields::BURNINGF || @battle.FE == PBFields::FLOWERGARDENF # Burning/Flower Garden
					miniscore*=2   if @battle.FE == PBFields::STARLIGHTA && !pbPartyHasType?(PBTypes::DARK) && !pbPartyHasType?(PBTypes::FAIRY) && !pbPartyHasType?(PBTypes::PSYCHIC)  # Starlight
					miniscore*=0   if @battle.FE == PBFields::UNDERWATER || @battle.FE == PBFields::NEWW # Underwater or New World
				end
			when 0x101 # Sandstorm
				miniscore = weathercode()
				miniscore*=sandcode()
				if @mondata.skill>=BESTSKILL
					miniscore*=1.3 if @battle.FE == PBFields::ASHENB || @battle.FE == PBFields::DESERTF # Ashen Beach/Desert
					miniscore*=1.5 if @battle.FE == PBFields::RAINBOWF # Rainbow
					miniscore*=3   if @battle.FE == PBFields::BURNINGF # Burning
					miniscore*=2   if @battle.FE == PBFields::STARLIGHTA && !pbPartyHasType?(PBTypes::DARK) && !pbPartyHasType?(PBTypes::FAIRY) && !pbPartyHasType?(PBTypes::PSYCHIC)  # Starlight
					miniscore*=0   if @battle.FE == PBFields::UNDERWATER || @battle.FE == PBFields::NEWW # Underwater or New World
				end
			when 0x102 # Hail
				miniscore = weathercode()
				miniscore*=hailcode()
				if @mondata.skill>=BESTSKILL
					miniscore*=1.2 if @battle.FE == PBFields::ICYF || @battle.FE == PBFields::SNOWYM # Icy/Snowy Mountain
					miniscore*=1.5 if @battle.FE == PBFields::RAINBOWF || @battle.FE == PBFields::MOUNTAIN # Rainbow/Mountian
					miniscore*=0   if @battle.FE == PBFields::SUPERHEATEDF # Superheated
					miniscore*=2   if @battle.FE == PBFields::STARLIGHTA && !pbPartyHasType?(PBTypes::DARK) && !pbPartyHasType?(PBTypes::FAIRY) && !pbPartyHasType?(PBTypes::PSYCHIC)  # Starlight
					miniscore*=0   if @battle.FE == PBFields::UNDERWATER || @battle.FE == PBFields::NEWW # Underwater or New World
				end
			when 0x103 # Spikes
				if @attacker.pbOpposingSide.effects[PBEffects::Spikes] < 3
					miniscore = hazardcode()
					miniscore*=0.9 if @attacker.pbOpposingSide.effects[PBEffects::Spikes]>0
					if @mondata.skill>=BESTSKILL
						miniscore*=0 if @battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS # (Murk)Water Surface
					end
				else
					miniscore*=0
				end
				if @mondata.skill>=BESTSKILL
					if @battle.FE == PBFields::WASTELAND # Wasteland
						miniscore = 1
						score = ((@opponent.totalhp/3.0)/@opponent.hp)*100
						score*=1.5 if @battle.doublebattle
					end
				end
			when 0x104 # Toxic Spikes
				if @attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes] < 2
					miniscore = hazardcode()
					miniscore*=0.9 if @attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
					if @mondata.skill>=BESTSKILL
					  miniscore*=0 if @battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS # (Murk)Water Surface
					  miniscore*=1.2 if @battle.FE == PBFields::CORROSIVEF # Corrosive
					end
				else
					miniscore*=0
				end
				if @mondata.skill>=BESTSKILL
					if @battle.FE == PBFields::WASTELAND && !@opponent.isAirborne? # Wasteland
						miniscore = 1
						score = [((@opponent.totalhp*0.13)/@opponent.hp)*100, 110].min
						score*= @opponent.pbCanPoison?(false) ? 1.5 : 0
						score*= 0.6 if hasgreatmoves()
						score*=1.5 if @battle.doublebattle
						score*=0 if @opponent.hasType?(:POISON)
					elsif @battle.FE == PBFields::WASTELAND && @opponent.isAirborne?
						score=0
					end
				end
			when 0x105 # Stealth Rocks
				if !@attacker.pbOpposingSide.effects[PBEffects::StealthRock]
					miniscore = hazardcode()
					miniscore*=1.05 if @attacker.moves.any? {|moveloop| moveloop!=nil && (moveloop.id==PBMoves::SPIKES || moveloop.id==PBMoves::TOXICSPIKES)}
					if @mondata.skill>=BESTSKILL
					  miniscore*=2 if @battle.FE == PBFields::CAVE || @battle.FE == PBFields::ROCKYF # Cave/Rocky
					  miniscore*=1.3 if @battle.FE == PBFields::CRYSTALC # Crystal Cavern
					end
				else
					miniscore=0
				end
				if @mondata.skill>=BESTSKILL
					if @battle.FE == PBFields::WASTELAND && !(@opponent.ability==PBAbilities::MAGICBOUNCE || @opponent.pbPartner.ability==PBAbilities::MAGICBOUNCE) &&
						(@opponent.effects[PBEffects::MagicCoat]==true || @opponent.pbPartner.effects[PBEffects::MagicCoat]==true) # Wasteland
						miniscore=1.0
						score = ((@opponent.totalhp/4.0)/@opponent.hp)*100
						score*=2 if pbTypeModNoMessages(PBTypes::ROCK,@attacker,@opponent,@move,@mondata.skill)>4
						score*=1.5 if @battle.doublebattle
					end
				end
			when 0x106 # Grass Pledge
				miniscore*= 1.5 if @attacker.pbPartner.pbHasMove?(PBMoves::FIREPLEDGE) || @attacker.pbPartner.pbHasMove?(PBMoves::WATERPLEDGE)
				if @battle.field.checkPledge(PBMoves::GRASSPLEDGE)
					miniscore = getFieldDisruptScore(@attacker,@opponent)
					case @battle.field.pledge
						when PBMoves::WATERPLEDGE then miniscore/= getFieldDisruptScore(@attacker,@opponent,PBFields::SWAMPF)
						when PBMoves::FIREPLEDGE then miniscore/=getFieldDisruptScore(@attacker,@opponent,PBFields::BURNINGF)
					end
				end
			when 0x107 # Fire Pledge
				miniscore*= 1.5 if @attacker.pbPartner.pbHasMove?(PBMoves::GRASSPLEDGE) || @attacker.pbPartner.pbHasMove?(PBMoves::WATERPLEDGE)
				if @battle.field.checkPledge(PBMoves::FIREPLEDGE)
					miniscore = getFieldDisruptScore(@attacker,@opponent)
					case @battle.field.pledge
						when PBMoves::WATERPLEDGE then miniscore/= getFieldDisruptScore(@attacker,@opponent,PBFields::RAINBOWF)
						when PBMoves::GRASSPLEDGE then miniscore/=getFieldDisruptScore(@attacker,@opponent,PBFields::BURNINGF)
					end
				end
			when 0x108 # Water Pledge
				miniscore*= 1.5 if @attacker.pbPartner.pbHasMove?(PBMoves::FIREPLEDGE) || @attacker.pbPartner.pbHasMove?(PBMoves::GRASSPLEDGE)
				if @battle.field.checkPledge(PBMoves::WATERPLEDGE)
					miniscore = getFieldDisruptScore(@attacker,@opponent)
					case @battle.field.pledge
						when PBMoves::GRASSPLEDGE then miniscore/= getFieldDisruptScore(@attacker,@opponent,PBFields::SWAMPF)
						when PBMoves::FIREPLEDGE then miniscore/=getFieldDisruptScore(@attacker,@opponent,PBFields::RAINBOWF)
					end
				end
			when 0x10a # Brick Break, Psychic Fangs
				miniscore = brickbreakcode()
			when 0x10b # Hi Jump Kick, Jump Kick
				miniscore = jumpcode(score)
				if @attacker.index != 2 && @mondata.skill>=BESTSKILL
					miniscore*= 0.5 if @battle.FE != PBFields::INVERSEF && pbPartyHasType?(PBTypes::GHOST, @opponent.index)
				end
			when 0x10c # Substitute
				miniscore=subcode()
			when 0x10d # Curse
				if @attacker.pbHasType?(:GHOST)
					miniscore = spoopycode()
					miniscore = 0 if @battle.FE == PBFields::HOLYF
				else
					miniscore = selfstatboost([1,1,0,0,0,0,0])
					miniscore *= selfstatdrop([0,0,1,0,0,0,0],score)
				end
			when 0x10e # Spite
				score=spitecode(score)
			when 0x10f # Nightmare
				miniscore = nightmarecode()
				miniscore*=0 if @battle.FE == PBFields::RAINBOWF
			when 0x110 # Rapid Spin
				score+=20 if @attacker.effects[PBEffects::LeechSeed]>=0
				score+=10 if @attacker.effects[PBEffects::MultiTurn]>0
				if @attacker.pbNonActivePokemonCount>0
					score+=25 if @attacker.pbOwnSide.effects[PBEffects::StealthRock]
					score+=25 if @attacker.pbOwnSide.effects[PBEffects::StickyWeb]
					score+= (10*@attacker.pbOwnSide.effects[PBEffects::Spikes])
					score+= (15*@attacker.pbOwnSide.effects[PBEffects::ToxicSpikes])
				end
			when 0x111 # Future Sight, Doom Desire
				miniscore = futurecode()
			when 0x112 # Stockpile
				if @attacker.effects[PBEffects::Stockpile]<3
					miniscore = selfstatboost([1,1,0,0,0,0,0])
				else
					miniscore = 0
				end
			when 0x113 # Spit Up
				if @attacker.effects[PBEffects::Stockpile]==0
					miniscore=0
				else
					miniscore=antistatcode([0,@attacker.effects[PBEffects::Stockpile],0,0,@attacker.effects[PBEffects::Stockpile],0,0],score)
					if @attacker.pbHasMove?(PBMoves::SWALLOW) && @attacker.hp/(@attacker.totalhp.to_f) < 0.66
						miniscore*=0.8
						miniscore*=0.5 if @attacker.hp < 0.4*@attacker.totalhp
					end
				end
			when 0x114 # Swallow
				if @attacker.effects[PBEffects::Stockpile]==0
					miniscore=0
				else
					miniscore = recovercode()
					miniscore*=selfstatdrop([0,@attacker.effects[PBEffects::Stockpile],0,0,@attacker.effects[PBEffects::Stockpile],0,0],score)
				end
			when 0x115 # Focus Punch
				miniscore = focuscode()
			when 0x116 # Sucker Punch
				miniscore = suckercode()
			when 0x117 # Follow Me, Rage Powder
				miniscore = followcode()
			when 0x118 # Gravity
				miniscore = gravicode()
				if @battle.state.effects[PBEffects::Gravity]==0 && @mondata.skill>=BESTSKILL
					if @battle.FE == PBFields::NEWW
						score*=2 if !@attacker.pbHasType?(:FLYING) && @attacker.ability != PBAbilities::LEVITATE
						score*=2 if @opponent.pbHasType?(:FLYING) || @opponent.ability == PBAbilities::LEVITATE
						if pbPartyHasType?(PBTypes::PSYCHIC) || pbPartyHasType?(PBTypes::FAIRY) || pbPartyHasType?(PBTypes::DARK)
							score*=2
							score*=2 if @attacker.pbHasType?(:PSYCHIC) || @attacker.pbHasType?(:FAIRY) || @attacker.pbHasType?(:DARK)
						end
					end
				end
			when 0x119 # Magnet Rise
				miniscore = magnocode()
				miniscore*=1.3 if @mondata.skill>=BESTSKILL && (@battle.FE == PBFields::ELECTRICT || @battle.FE == PBFields::FACTORYF || @battle.FE == PBFields::SHORTCIRCUITF)
			when 0x11a # Telekineis
				score = telecode()
			#when 0x11b # Sky Uppercut
			when 0x11c # Smack Down, Thousand Arrows
				miniscore = smackcode()
			when 0x11d # After You
				miniscore = afteryoucode()
				if @battle.opponent.is_a?(Array) && @battle.opponent.any? {|opp| opp.trainertype == PBTrainers::UMBNOEL } &&
					@battle.turncount == 1 && @opponent.index == @attacker.pbPartner.index
					score += 150
				end
			when 0x11e # Quash
				#we could technically have _some_ code for this
			when 0x11f # Trick Room
				miniscore = trcode()
				if @mondata.skill>=BESTSKILL
					miniscore*=1.5 if @battle.FE == PBFields::CHESSB || @battle.FE == PBFields::NEWW || @battle.FE == PBFields::PSYCHICT # Chess/New World/Psychic Terrain
				end
			when 0x120 # Ally Switch
				miniscore = dinglenugget()
			#when 0x121 # Foul Play
			#when 0x122 # Secret Sword, Psystrike, Psyshock
			when 0x123 # Synchronoise
				score=0 if !@opponent.pbHasType?(@attacker.type1) && !@opponent.pbHasType?(@attacker.type2)
			when 0x124 # Wonder Room
				miniscore = wondercode()
			when 0x125 # Last Resort
				miniscore = lastcode()
			when 0x126 # Shadow moves (basic)
				score*=1.2
			when 0x127 # Shadow Bolt
				miniscore = 1.2*paracode()
			when 0x128 # Shadow Fire
				miniscore = 1.2*burncode()
			when 0x129 # Shadow Chill
				miniscore = 1.2*freezecode()
			when 0x12a # Shadow Panic
				miniscore = 1.2*confucode()
			when 0x132 # Shadow Shed (like a hut or a tool shed, i presume.)
				miniscore = brickbreakcode() / brickbreakcode(@opponent)
			when 0x133 # King's Shield
				miniscore = protecteffectcode()
				if !pbAIfaster?() && attacker.species == PBSpecies::AEGISLASH && attacker.form==1
					score*=4
					#experimental -- cancels out drop if killing moves
					score*=6 if initialscores.length>0 && hasgreatmoves()
				end
			when 0x134 # Electric Terrain
				miniscore = electricterraincode()
			when 0x135 # Grassy Terrain
				miniscore = grassyterraincode()
			when 0x136 # Misty Terrain
				miniscore = mistyterraincode()
			when 0x137 # Flying Press
				#score*=2 if opponent.effects[PBEffects::Minimize] #handled in pbRoughDamage from now on
				miniscore = 0 if @battle.state.effects[PBEffects::Gravity]>0
			when 0x138 # Noble Roar, Tearful Look
				statarray = [1,0,0,1,0,0,0]
				statarray = [2,0,0,2,0,0,0] if @move.id==PBMoves::NOBLEROAR && @mondata.skill >=BESTSKILL && (@battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::DRAGONSD)
				miniscore=oppstatdrop(statarray)
			when 0x139 # Draining Kiss, Oblivion Wing
				miniscore=absorbcode(initialscores[scoreindex])
			when 0x13a # Aromatic Mist
				miniscore=arocode(PBStats::SPDEF)
			when 0x13b # Eerie Impulse
				statarray = [0,0,0,2,0,0,0]
				statarray = [0,0,0,3,0,0,0] if @mondata.skill >=BESTSKILL && @battle.FE == PBFields::ELECTRICT
				miniscore = oppstatdrop(statarray)
			when 0x13c # Belch
				miniscore=0 if !@attacker.pokemon.belch
			when 0x13d # Parting Shot
				if (!@opponent.pbCanReduceStatStage?(PBStats::ATTACK) && !@opponent.pbCanReduceStatStage?(PBStats::SPATK)) || (@opponent.stages[PBStats::ATTACK]==-6 && @opponent.stages[PBStats::SPATK]==-6) || (@opponent.stages[PBStats::ATTACK]>1 && @opponent.stages[PBStats::SPATK]>1)
					miniscore = 0
				else
					miniscore = pivotcode()
					miniscore*=oppstatdrop([1,0,0,1,0,0,0])
				end
			when 0x13e # Geomancy
				miniscore = weaselslashcode() if !(@mondata.skill>=BESTSKILL && @battle.FE == PBFields::STARLIGHTA)
				miniscore *= selfstatboost([0,0,2,2,2,0,0])
				if @battle.FE == PBFields::NEWW
					miniscore*=2 if !@attacker.isAirborne?
					miniscore*=2 if @opponent.isAirborne?
					if pbPartyHasType?(PBTypes::PSYCHIC) || pbPartyHasType?(PBTypes::FAIRY) || pbPartyHasType?(PBTypes::DARK)
						miniscore*=2
						miniscore*=2 if @attacker.pbHasType?(:PSYCHIC) || @attacker.pbHasType?(:FAIRY) || @attacker.pbHasType?(:DARK)
					end
				end
			when 0x13f # Venom Drench
				if @opponent.status==PBStatuses::POISON || @battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF || @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS
					miniscore = oppstatdrop([1,0,1,1,0,0,0]) 
				else
					miniscore = 0
				end
			when 0x140 # Spiky Shield
				miniscore = protecteffectcode()
			when 0x141 # Sticky Web
				if @battle.FE != PBFields::WASTELAND # Wasteland
					if !@attacker.pbOpposingSide.effects[PBEffects::StickyWeb]
						miniscore = hazardcode
						miniscore*= 2 if @battle.FE == PBFields::FORESTF && @mondata.skill>=BESTSKILL
					else
						miniscore = 0
					end
				else
					miniscore=oppstatdrop([0,0,1,0,0,0,0])
				end
			when 0x142 # Topsy Turvy
				miniscore = turvycode()
				if @battle.canChangeFE?(PBFields::INVERSEF)
					for type in [@opponent.type1,@opponent.type2]
					  effcheck = PBTypes.getCombinedEffectiveness(type,@attacker.type1,@attacker.type2)
					  score*=2 if effcheck>4
					  score*=0.5 if effcheck!=0 && effcheck<4
					  score*=0.1 if effcheck==0
				  end
				  for type in [@attacker.type1, @attacker.type2]
					  effcheck = PBTypes.getCombinedEffectiveness(type,@opponent.type1,@opponent.type2)
					  score*=0.5 if effcheck>4
					  score*=2 if effcheck!=0 && effcheck<4
					  score*=3 if effcheck==0
				  end
			  end
			when 0x143 # Forest's Curse
				miniscore = opptypechangecode(PBTypes::GRASS)
				miniscore *= spoopycode() if @battle.FE == PBFields::FORESTF || @battle.FE == PBFields::FAIRYTALEF
			when 0x144 # Trick or Treat
				miniscore = opptypechangecode(PBTypes::GHOST)
			when 0x145 # Fairy Lock
				miniscore = fairylockcode()
			when 0x146 # Magnetic Flux
				if !(@attacker.ability == PBAbilities::PLUS || @attacker.ability == PBAbilities::MINUS || @attacker.pbPartner.ability == PBAbilities::PLUS || @attacker.pbPartner.ability == PBAbilities::MINUS)
					miniscore=0
				elsif @attacker.ability == PBAbilities::PLUS || @attacker.ability == PBAbilities::MINUS
					miniscore = selfstatboost([0,1,0,0,1,0,0])
				elsif @attacker.pbPartner.stages[PBStats::SPDEF]!=6 && @attacker.pbPartner.stages[PBStats::DEFENSE]!=6
					miniscore=0.7
					miniscore*=1.3 if initialscores.length>0 && hasbadmoves(20)
					miniscore*=1.1 if @attacker.pbPartner.hp>attacker.pbPartner.totalhp*0.75
					miniscore*=0.3 if @attacker.pbPartner.effects[PBEffects::Yawn]>0 || @attacker.pbPartner.effects[PBEffects::LeechSeed]>=0 || @attacker.pbPartner.effects[PBEffects::Attract]>=0 || @attacker.pbPartner.status!=0
					miniscore*=0.3 if checkAImoves(PBStuff::PHASEMOVE)
					miniscore*=0.5 if @opponent.ability == PBAbilities::UNAWARE
					miniscore*=1.2 if hpGainPerTurn(@attacker.pbPartner)>1
				end
			when 0x147 # Fell Stinger
				if @attacker.stages[PBStats::ATTACK]!=6 && score>=100
					miniscore = 2.0
					miniscore*=2 if pbAIfaster?(@move)
				end
			when 0x148 # Ion Deluge
				miniscore = electricterraincode()
				miniscore*= moveturnselectriccode(false,false)

			when 0x149 # Crafty Shield
				score = craftyshieldcode(score)

			when 0x150 # Flower Shield
				miniscore = arocode(PBStats::DEFENSE)
				score = flowershieldcode(score)

			when 0x151 # Rototiller
				miniscore = arocode(PBStats::ATTACK)
				score = rotocode(score)
			when 0x152 # Powder
				miniscore = powdercode()
			when 0x153 # Electrify
				miniscore = moveturnselectriccode(true,false)
			when 0x154 # Mat Block
				if @attacker.turncount==0 && (pbAIfaster?() || pbAIfaster?(nil,nil,@attacker,@opponent.pbPartner))
					miniscore = protectcode()
					miniscore *= 1.3 if @battle.doublebattle
				else
					miniscore = 0
				end
			when 0x155 # Thousand Waves, Anchor Shot, Spirit Shackle
				miniscore = meanlookcode()
			when 0x157 # Hyperspace Hole
				miniscore = nevermisscode(initialscores[scoreindex])
				miniscore*=feintcode()
			when 0x159 # Hyperspace Fury
				if @attacker.species==PBSpecies::HOOPA && @attacker.form==1 # Hoopa-U
					miniscore = nevermisscode(initialscores[scoreindex])
					miniscore*=feintcode()
					if @attacker.ability == PBAbilities::CONTRARY
						miniscore *= selfstatboost([0,1,0,0,0,0,0])
					else
						miniscore*=selfstatdrop([0,1,0,0,0],score)
					end
				else
					score = 0
				end
			when 0x15b # Aurora Veil
				miniscore = screencode()
				miniscore*=1.5 if @mondata.skill>=BESTSKILL && @battle.FE == PBFields::MIRRORA # Mirror
			when 0x15c # Baneful Bunker
				miniscore = protecteffectcode()
				if @opponent.status!=0
					miniscore*=0.8
				elsif @opponent.pbCanPoison?(false)
					miniscore*=1.3
					miniscore*=1.3 if @attacker.ability == PBAbilities::MERCILESS
					miniscore*=0.3 if @opponent.ability == PBAbilities::POISONHEAL
					miniscore*=0.7 if @opponent.ability == PBAbilities::TOXICBOOST
				end
			when 0x15d # Beak Blast
				miniscore = beakcode()
			when 0x15e # Burn Up
				miniscore = burnupcode()
			when 0x15f # Clanging Scales
				if @attacker.ability == PBAbilities::CONTRARY
					miniscore = selfstatboost([0,1,0,0,0,0,0])
				else
					miniscore = antistatcode([0,1,0,0,0],initialscores[scoreindex])
				end
			when 0x160 # Core Enforcer
				if !(PBStuff::FIXEDABILITIES).include?(@opponent.ability) && !@opponent.effects[PBEffects::GastroAcid] && @opponent.effects[PBEffects::Substitute]<=0
					miniscore = getAbilityDisruptScore(@attacker,@opponent)
					miniscore*=1.3 if !pbAIfaster?(@move)
					miniscore*=1.3 if checkAIpriority()
					score*=miniscore if !pbAIfaster?(@move) || checkAIpriority()
				  end
			when 0x161 # First Impression
				score=0 if @attacker.turncount!=0
				miniscore = (score>=110) ? 1.1 : 1.0
			when 0x162 # Floral Healing
				miniscore = healpulsecode()
				miniscore*=1.5 if @battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FAIRYTALEF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>1)
				miniscore*=0.2 if @attacker.status!=PBStatuses::POISON && (@battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF)
			when 0x163 # Gear Up
				if !(attacker.ability == PBAbilities::PLUS || attacker.ability == PBAbilities::MINUS || attacker.pbPartner.ability == PBAbilities::PLUS || attacker.pbPartner.ability == PBAbilities::MINUS)
					miniscore=0
				elsif @attacker.ability == PBAbilities::PLUS || @attacker.ability == PBAbilities::MINUS
					miniscore = selfstatboost([1,0,0,1,0,0,0])
				else
					miniscore=1.0
					miniscore*=1.3 if initialscores.length>0 && hasbadmoves(20)
					miniscore*=1.1 if @attacker.pbPartner.hp>attacker.pbPartner.totalhp*0.75
					miniscore*=0.3 if @attacker.pbPartner.effects[PBEffects::Yawn]>0 || @attacker.pbPartner.effects[PBEffects::LeechSeed]>=0 || @attacker.pbPartner.effects[PBEffects::Attract]>=0 || @attacker.pbPartner.status!=0
					miniscore*=0.3 if checkAImoves(PBStuff::PHASEMOVE)
					miniscore*=0.5 if @opponent.ability == PBAbilities::UNAWARE
				end
			when 0x164 # Instruct
				if !@battle.doublebattle || @opponent.index!=@attacker.pbPartner.index || @opponent.lastMoveUsedSketch<=0
					score=1
				else
					score*=instructcode()
					score=1 if @attacker.pbPartner.hp==0
				end
			when 0x165 # Laser Focus
				miniscore = permacritcode(initialscores[scoreindex])
			when 0x166 # Moongeist Beam, Sun Steel Strike
				miniscore = moldbreakeronalaser()
			when 0x167 # Pollen Puff
				if @opponent.index==@attacker.pbPartner.index
					score=15*healpulsecode()
					score=0 if @opponent.ability == PBAbilities::BULLETPROOF
				end
			when 0x168 # Psychic Terrain
				miniscore = psychicterraincode()
			when 0x169 # Purify
				miniscore = almostuselessmovecode()
			when 0x16b # Shell Trap
				miniscore = shelltrapcode()
			when 0x16c # Shore Up
				recoveramount = @attacker.totalhp/2.0
				recoveramount = @attacker.totalhp if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::ASHENB
				recoveramount = @attacker.totalhp*0.66 if @battle.pbWeather==PBWeather::SANDSTORM || @mondata.skill >= BESTSKILL && @battle.FE == PBFields::DESERTF
				miniscore = recovercode(recoveramount)
				miniscore*= selfstatboost([0,2,0,0,0,0,0]) if @attacker.ability ==PBAbilities::WATERCOMPACTION && @mondata.skill >= BESTSKILL && (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS)
			when 0x16d # Sparkling Aria
				miniscore = (@opponent.status==PBStatuses::BURN) ? 0.6 : 1.0
			when 0x16e # Spectral Thief
				miniscore = spectralthiefcode()
			when 0x16f # Speed Swap
				miniscore=stupidmovecode()
			when 0x170 # Spotlight
				miniscore = spotlightcode()
			when 0x171 # Stomping Tantrum
				miniscore = 1.0

			when 0x172 # Strength Sap
				miniscore = recovercode()
				miniscore*=oppstatdrop([1,0,0,0,0,0,0])
			when 0x173 # Throat Chop
				miniscore = chopcode()
			when 0x174 # Toxic Thread
				miniscore = poisoncode()
				miniscore*=oppstatdrop([0,0,1,0,0,0,0])
			when 0x175 # Mind Blown
				miniscore = pussydeathcode(initialscores[scoreindex])
				if @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::SWAMPF
					miniscore*=0
				end
			when 0x176 # Photon Geyser
				miniscore = moldbreakeronalaser()
			when 0x177 # Plasma Fists
				miniscore = electricterraincode()
				miniscore*= moveturnselectriccode(false,true)
			when 0xffe # Z-Conversion / splash
				miniscore*= selfstatboost([1,1,1,1,1,0,0]) if move.id == PBMoves::CONVERSION || move.id == PBMoves::CELEBRATE
				miniscore*= selfstatboost([3,0,0,0,0,0,0]) if move.id == PBMoves::SPLASH

		end
		score*=miniscore
		score=score.to_i
		score=0 if score<0
		$ai_log_data[@attacker.index].final_score_moves.push(score)
		return score
	end
######################################################
# Function (code) subfunctions
######################################################
#All functions here return a modifier to the original score, similar to miniscore
	def sleepcode
		return @move.basedamage > 0 ? 1 : 0 if !(@opponent.pbCanSleep?(false) && @opponent.effects[PBEffects::Yawn]==0)
		return @move.basedamage > 0 ? 1 : 0 if secondaryEffectNegated?()
		return @move.basedamage > 0 ? 1 : 0 if hydrationCheck(@opponent)
		return @move.basedamage > 0 ? 1 : 0 if @move.id == PBMoves::DARKVOID && !(attacker.species == PBSpecies::DARKRAI || (attacker.species == PBSpecies::HYPNO && attacker.form == 1))
		miniscore = 1.2
		if @attacker.pbHasMove?(PBMoves::DREAMEATER) || @attacker.pbHasMove?(PBMoves::NIGHTMARE) || @attacker.ability == PBAbilities::BADDREAMS
			miniscore *= 1.5
		end
		miniscore*=(1.2*hpGainPerTurn)
		miniscore*=2 if (attacker.species == PBSpecies::HYPNO && attacker.form == 1)
		miniscore*=1.3 if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::SETUPMOVE).include?(moveloop.id)}
		miniscore*=1.3 if @attacker.pbHasMove?(PBMoves::LEECHSEED)
		miniscore*=1.3 if @attacker.pbHasMove?(PBMoves::SUBSTITUTE)
		miniscore*=1.2 if @opponent.hp==@opponent.totalhp
		miniscore*=0.1 if checkAImoves([PBMoves::SLEEPTALK,PBMoves::SNORE])
		miniscore*=0.1 if @opponent.ability == PBAbilities::NATURALCURE
		miniscore*=0.8 if @opponent.ability == PBAbilities::MARVELSCALE
		miniscore*=0.5 if @opponent.ability == PBAbilities::SYNCHRONIZE && @attacker.pbCanSleep?(false)
		miniscore*=0.4 if @opponent.effects[PBEffects::Confusion]>0
		miniscore*=0.5 if @opponent.effects[PBEffects::Attract]>=0
		ministat = statchangecounter(@opponent,1,7)
		miniscore*= 1 + 0.1*ministat if ministat>0
		if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL) || @mondata.roles.include?(PBMonRoles::CLERIC) || @mondata.roles.include?(PBMonRoles::PIVOT)
			miniscore*=1.2
		end
		if @initial_scores.length>0
			miniscore*=1.3 if hasbadmoves(40)
			miniscore*=1.5 if hasbadmoves(20)
		end
		miniscore = pbSereneGraceCheck(miniscore) if @move.basedamage>0
		miniscore = pbReduceWhenKills(miniscore)
		return miniscore
	end

	def poisoncode
		return @move.basedamage > 0 ? 1 : 0 if !@opponent.pbCanPoison?(false,false,@move.id==PBMoves::TOXIC && @attacker.ability==PBAbilities::CORROSION)
		return @move.basedamage > 0 ? 1 : 0 if hydrationCheck(@opponent)
		return @move.basedamage > 0 ? 1 : 0 if secondaryEffectNegated?()
		miniscore=1.2
		ministat=0
		ministat+=@opponent.stages[PBStats::DEFENSE]
		ministat+=@opponent.stages[PBStats::SPDEF]
		ministat+=@opponent.stages[PBStats::EVASION]
		miniscore*=1+0.05*ministat if ministat>0
		miniscore*=2 if @move.function == 0x06 && checkAIhealing()
		miniscore*=0.3 if @opponent.ability == PBAbilities::NATURALCURE
		miniscore*=0.7 if @opponent.ability == PBAbilities::MARVELSCALE
		miniscore*=0.2 if @opponent.ability == PBAbilities::TOXICBOOST || @opponent.ability == PBAbilities::GUTS || @opponent.ability == PBAbilities::QUICKFEET
		miniscore*=0.1 if @opponent.ability == PBAbilities::POISONHEAL || @opponent.ability == PBAbilities::MAGICGUARD
		miniscore*=0.7 if @opponent.ability == PBAbilities::SHEDSKIN
		miniscore*=1.1 if (@opponent.ability == PBAbilities::STURDY || (@battle.FE == PBFields::CHESSB && @opponent.pokemon.piece==:PAWN)) && @move.basedamage>0
		miniscore*=0.5 if @opponent.ability == PBAbilities::SYNCHRONIZE && @attacker.status==0 && !@attacker.pbHasType?(:POISON) && !@attacker.pbHasType?(:STEEL)
		miniscore*=0.2 if checkAImoves([PBMoves::FACADE])
		miniscore*=0.1 if checkAImoves([PBMoves::REST])
		miniscore*=1.5 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		if @initial_scores.length>0
			miniscore*=1.2 if hasbadmoves(30)
		end
		if @attacker.pbHasMove?(PBMoves::VENOSHOCK) || @attacker.pbHasMove?(PBMoves::VENOMDRENCH) || @attacker.ability == PBAbilities::MERCILESS
			miniscore*=1.6
		end
		miniscore*=0.4 if @opponent.effects[PBEffects::Yawn]>0
		miniscore = pbSereneGraceCheck(miniscore) if @move.basedamage>0
		miniscore = pbReduceWhenKills(miniscore)
		return miniscore
	end

	def paracode
		return @move.basedamage > 0 ? 1 : 0 if !@opponent.pbCanParalyze?(false)
		return @move.basedamage > 0 ? 1 : 0 if hydrationCheck(@opponent)
		return @move.basedamage > 0 ? 1 : 0 if secondaryEffectNegated?()
		return @move.basedamage > 0 ? 1 : 0 if @move.id==PBMoves::THUNDERWAVE && @move.pbTypeModifier(@move.pbType(@attacker),@attacker,@opponent)==0
		miniscore=1.0
		miniscore*=1.1 if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::SETUPMOVE).include?(moveloop.id)}
		miniscore*=1.2 if @opponent.hp==@opponent.totalhp
		ministat= @opponent.stages[PBStats::ATTACK] + @opponent.stages[PBStats::SPATK] + @opponent.stages[PBStats::SPEED]
		miniscore*=1+0.05*ministat if ministat>0
		miniscore*=0.3 if @opponent.ability == PBAbilities::NATURALCURE
		miniscore*=0.5 if @opponent.ability == PBAbilities::MARVELSCALE
		miniscore*=0.2 if @opponent.ability == PBAbilities::GUTS || @opponent.ability == PBAbilities::QUICKFEET
		miniscore*=0.7 if @opponent.ability == PBAbilities::SHEDSKIN
		miniscore*=0.5 if @opponent.ability == PBAbilities::SYNCHRONIZE && @attacker.pbCanParalyze?(false)
		miniscore*=1.2 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL) || @mondata.roles.include?(PBMonRoles::PIVOT)
		miniscore*=1.3 if @mondata.roles.include?(PBMonRoles::TANK)
		if !pbAIfaster?() && (pbRoughStat(@opponent,PBStats::SPEED)/2.0)<@attacker.pbSpeed && @battle.trickroom==0
			miniscore*=1.2
		elsif pbAIfaster?() && (pbRoughStat(@opponent,PBStats::SPEED)/2.0)<@attacker.pbSpeed && @battle.trickroom>1
			miniscore*=0.7
		end
		if pbRoughStat(@opponent,PBStats::SPATK)>pbRoughStat(@opponent,PBStats::ATTACK)
			miniscore*=1.1
		end
		miniscore*=1.1 if @mondata.partyroles.any? {|roles| roles.include?(PBMonRoles::SWEEPER)}
		miniscore*=1.1 if @opponent.effects[PBEffects::Confusion]>0
		miniscore*=1.1 if @opponent.effects[PBEffects::Attract]>=0
		miniscore*=0.4 if @opponent.effects[PBEffects::Yawn]>0
		miniscore = pbSereneGraceCheck(miniscore) if @move.basedamage>0
		miniscore = pbReduceWhenKills(miniscore)
		if !pbAIfaster?() && (pbRoughStat(@opponent,PBStats::SPEED)/2.0)<@attacker.pbSpeed && @battle.trickroom==0
			if hasbadmoves(40)
				miniscore+=25 if @move.addlEffect == 100 # help nuzzle
			end
		end
		return miniscore
	end

	def burncode
		return @move.basedamage > 0 ? 1 : 0 if !@opponent.pbCanBurn?(false)
		return @move.basedamage > 0 ? 1 : 0 if hydrationCheck(@opponent)
		return @move.basedamage > 0 ? 1 : 0 if secondaryEffectNegated?()
		miniscore=1.2
		ministat=0
		ministat+=@opponent.stages[PBStats::ATTACK]
		ministat+=@opponent.stages[PBStats::SPATK]
		ministat+=@opponent.stages[PBStats::SPEED]
		miniscore*=1+0.05*ministat if ministat>0
		miniscore*=0.3 if @opponent.ability == PBAbilities::NATURALCURE
		miniscore*=0.7 if @opponent.ability == PBAbilities::MARVELSCALE
		miniscore*=0.1 if @opponent.ability == PBAbilities::GUTS || @opponent.ability == PBAbilities::FLAREBOOST
		miniscore*=0.7 if @opponent.ability == PBAbilities::SHEDSKIN
		miniscore*=0.5 if @opponent.ability == PBAbilities::SYNCHRONIZE && @attacker.pbCanBurn?(false)
		miniscore*=0.5 if @opponent.ability == PBAbilities::MAGICGUARD
		miniscore*=0.3 if @opponent.ability == PBAbilities::QUICKFEET
		miniscore*=1.1 if @opponent.ability == PBAbilities::STURDY && @move.basedamage>0
		miniscore*=0.1 if checkAImoves([PBMoves::REST])
		miniscore*=0.3 if checkAImoves([PBMoves::FACADE])
		if pbRoughStat(@opponent,PBStats::ATTACK)>pbRoughStat(@opponent,PBStats::SPATK)
			miniscore*=1.4
		end
		miniscore*=0.4 if @opponent.effects[PBEffects::Yawn]>0
		miniscore = pbSereneGraceCheck(miniscore) if @move.basedamage>0
		miniscore = pbReduceWhenKills(miniscore)
		return miniscore
	end

	def freezecode
		return @move.basedamage > 0 ? 1 : 0 if !@opponent.pbCanFreeze?(false)
		return @move.basedamage > 0 ? 1 : 0 if hydrationCheck(@opponent)
		return @move.basedamage > 0 ? 1 : 0 if secondaryEffectNegated?()
		miniscore=1.2
		miniscore*=0 if checkAImoves(PBStuff::UNFREEZEMOVE)
		miniscore*=1.2 if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::SETUPMOVE).include?(moveloop.id)}
		miniscore*=1.2 if checkAIhealing()
		ministat = statchangecounter(@opponent,1,7)
		miniscore*=1+0.05*ministat if ministat>0
		miniscore*=0.3 if @opponent.ability == PBAbilities::NATURALCURE
		miniscore*=0.8 if @opponent.ability == PBAbilities::MARVELSCALE
		miniscore*=0.5 if @opponent.ability == PBAbilities::SYNCHRONIZE && @attacker.pbCanFreeze?(false)
		miniscore = pbSereneGraceCheck(miniscore) if @move.basedamage>0
		miniscore = pbReduceWhenKills(miniscore)
		return miniscore
	end

	def flinchcode
		return @move.basedamage > 0 ? 1 : 0 if @opponent.effects[PBEffects::Substitute] > 0 || @opponent.ability == PBAbilities::INNERFOCUS || secondaryEffectNegated?()
		return @move.basedamage > 0 ? 1 : 0 if !pbAIfaster?(@move)
		miniscore = 1.0
		miniscore*= 1.3 if !hasgreatmoves()
		miniscore*= 1.3 if @battle.trickroom > 0 && @attacker.pbSpeed > pbRoughStat(@opponent,PBStats::SPEED)
		miniscore*= 1.3 if @battle.field.duration > 0 && getFieldDisruptScore(@attacker,@opponent) > 1.0
		miniscore*= 1.3 if @attacker.pbOpposingSide.effects[PBEffects::LightScreen] || @attacker.pbOpposingSide.effects[PBEffects::Reflect] || @attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]
		miniscore*= 1.2 if @attacker.pbOpposingSide.effects[PBEffects::Tailwind]
		if @opponent.status==PBStatuses::POISON || @opponent.status==PBStatuses::BURN || (@battle.pbWeather == PBWeather::HAIL && !@opponent.pbHasType?(:ICE)) || (@battle.pbWeather == PBWeather::SANDSTORM && !@opponent.pbHasType?(:ROCK) && !@opponent.pbHasType?(:GROUND) && !@opponent.pbHasType?(:STEEL)) || @opponent.effects[PBEffects::LeechSeed]>-1 || @opponent.effects[PBEffects::Curse]
			miniscore*=1.1
			miniscore*=1.2 if @opponent.effects[PBEffects::Toxic]>0
		end
		miniscore*=0.3 if @opponent.ability == PBAbilities::STEADFAST
		if @mondata.skill >= BESTSKILL
			miniscore*=1.1 if @battle.FE == PBFields::ROCKYF # Rocky
		end
		miniscore = pbSereneGraceCheck(miniscore) if @move.basedamage>0
		miniscore = pbReduceWhenKills(miniscore)
		return miniscore
	end

	def thunderboostcode
		miniscore = 1.0
		invulmove=$cache.pkmn_move[@opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]
		if invulmove==0xC9 || invulmove==0xCC || invulmove==0xCE
			miniscore*=2 if pbAIfaster?()
		end
		if !pbAIfaster?()
			miniscore*=1.2 if checkAImoves(PBStuff::TWOTURNAIRMOVE)
		end
		return miniscore
	end

	def confucode
		return @move.basedamage > 0 ? 1 : 0 if !@opponent.pbCanConfuse?(false)
		return @move.basedamage > 0 ? 1 : 0 if secondaryEffectNegated?()
		miniscore=1.0
		miniscore*=1.2 if !hasgreatmoves()
		miniscore*=1+0.1*@opponent.stages[PBStats::ATTACK] if @opponent.stages[PBStats::ATTACK] > 0
		if pbRoughStat(@opponent,PBStats::ATTACK)>pbRoughStat(@opponent,PBStats::SPATK)
			miniscore*=1.2
		end
		miniscore*=1.3 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		miniscore*=1.1 if @opponent.effects[PBEffects::Attract]>=0
		miniscore*=1.1 if @opponent.status==PBStatuses::PARALYSIS
		miniscore*=0.7 if @opponent.ability == PBAbilities::TANGLEDFEET
		if @attacker.pbHasMove?(PBMoves::SUBSTITUTE)
			miniscore*=1.2
			miniscore*=1.3 if @attacker.effects[PBEffects::Substitute]>0
		end
		if @initial_scores.length>0
			miniscore*=1.4 if hasbadmoves(40)
		end
		miniscore = pbSereneGraceCheck(miniscore) if @move.basedamage>0
		miniscore = pbReduceWhenKills(miniscore)
		return miniscore
	end

	def attractcode
		agender=@attacker.gender
		ogender=@opponent.gender
		return 0 if (agender==2 || ogender==2 || agender==ogender || @opponent.effects[PBEffects::Attract]>=0 || @opponent.ability == PBAbilities::OBLIVIOUS || @battle.pbCheckSideAbility(:AROMAVEIL,@opponent)!=nil && !moldBreakerCheck(@attacker))
		miniscore=1.2
		miniscore*=0.7 if @attacker.ability == PBAbilities::CUTECHARM
		miniscore*=1.3 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		miniscore*=1.1 if @opponent.effects[PBEffects::Confusion]>0
		miniscore*=1.1 if @opponent.status==PBStatuses::PARALYSIS
		miniscore*=0.5 if @opponent.effects[PBEffects::Yawn]>0 || @opponent.status==PBStatuses::SLEEP
		miniscore*=0.1 if (@mondata.oppitemworks && @opponent.item == PBItems::DESTINYKNOT)
		if @attacker.pbHasMove?(PBMoves::SUBSTITUTE)
			miniscore*=1.2
			miniscore*=1.3 if @attacker.effects[PBEffects::Substitute]>0
		end
		return miniscore
	end

	def refreshcode
		miniscore = 1.0
		if @attacker.status==PBStatuses::BURN || @attacker.status==PBStatuses::POISON || @attacker.status==PBStatuses::PARALYSIS
			miniscore*=3
		else
			return 0
		end
		miniscore*=((@attacker.hp.to_f)/@attacker.totalhp > 0.5) ? 1.5 : 0.3
		miniscore*=0.1 if @opponent.effects[PBEffects::Yawn] > 0
		miniscore*=0.1 if checkAIdamage() > @attacker.hp
		miniscore*=1.3 if @opponent.effects[PBEffects::Toxic] > 2
		miniscore*=1.3 if checkAImoves([PBMoves::HEX])
		return miniscore
	end

	def partyrefreshcode
		return 0 if !@battle.pbPartySingleOwner(@attacker.index).any? {|mon| mon && mon.status!=0}
		miniscore=1.2
		for mon in @battle.pbPartySingleOwner(@attacker.index)
			next if mon.nil? || mon.hp <= 0 || mon.status==0
			miniscore*=0.5 if mon.status==PBStatuses::POISON && mon.ability == PBAbilities::POISONHEAL
			miniscore*=0.8 if mon.ability == PBAbilities::GUTS || mon.ability == PBAbilities::QUICKFEET || mon.knowsMove?(:FACADE)
			miniscore*=1.1 if mon.status==PBStatuses::SLEEP || mon.status==PBStatuses::FROZEN
			monroles=pbGetMonRoles(mon)
			miniscore*=1.2 if (monroles.include?(PBMonRoles::PHYSICALWALL) || monroles.include?(PBMonRoles::SPECIALWALL)) && mon.status==PBStatuses::POISON
			miniscore*=1.2 if monroles.include?(PBMonRoles::SWEEPER) && mon.status==PBStatuses::PARALYSIS
			miniscore*=1.2 if mon.attack>mon.spatk && mon.status==PBStatuses::BURN
		end
		miniscore*=1.3 if @attacker.status!=0
		miniscore*=1.3 if @attacker.effects[PBEffects::Toxic]>2
		miniscore*=1.1 if checkAIhealing()
		return miniscore
	end

	def psychocode
		return 0 if @attacker.status==0 || @opponent.status!=0 || @opponent.effects[PBEffects::Substitute]>0 || @opponent.effects[PBEffects::Yawn]!=0
		return 0 if @attacker.status==PBStatuses::BURN && !@opponent.pbCanBurn?(false) || @attacker.status==PBStatuses::PARALYSIS && !@opponent.pbCanParalyze?(false) || @attacker.status==PBStatuses::POISON && !@opponent.pbCanPoison?(false)
		miniscore=1.3*1.3
		if @attacker.status==PBStatuses::BURN && @opponent.pbCanBurn?(false)
			miniscore*=1.2 if pbRoughStat(@opponent,PBStats::ATTACK)>pbRoughStat(@opponent,PBStats::SPATK)
			miniscore*=0.7 if @opponent.ability == PBAbilities::FLAREBOOST
		end
		if @attacker.status==PBStatuses::PARALYSIS && @opponent.pbCanParalyze?(false)
			miniscore*=1.1 if pbRoughStat(@opponent,PBStats::ATTACK)<pbRoughStat(@opponent,PBStats::SPATK)
			miniscore*=1.2 if pbAIfaster?(@move)
		end
		if @attacker.status==PBStatuses::POISON && @opponent.pbCanPoison?(false)
			miniscore*=1.1 if checkAIhealing()
			miniscore*=1.4 if @attacker.effects[PBEffects::Toxic]>0
			miniscore*=0.3 if @opponent.ability == PBAbilities::POISONHEAL
			miniscore*=0.7 if @opponent.ability == PBAbilities::TOXICBOOST
		end
		miniscore*=0.7 if @opponent.ability == PBAbilities::SHEDSKIN || @opponent.ability == PBAbilities::NATURALCURE || @opponent.ability == PBAbilities::GUTS || @opponent.ability == PBAbilities::QUICKFEET || @opponent.ability == PBAbilities::MARVELSCALE
		miniscore*=0.7 if checkAImoves([PBMoves::FACADE])
		miniscore*=1.3 if checkAImoves([PBMoves::HEX])
		miniscore*=1.3 if @attacker.pbHasMove?(PBMoves::HEX)
		return miniscore
	end

	def selfstatboost(stats)
		#stats should be an array of the stat boosts like so: [ATK,DEF,SPE,SPA,SPD,ACC,EVA] with nils in unaffected stats
		#coil, for example, would be [1,1,0,0,0,1,0]
		stats.unshift(0) #this is required to make the next line work correctly
		for i in 1...stats.length
			next if stats[i] == 0
			stats[i]*= 2 if @attacker.ability == PBAbilities::SIMPLE
			#cap boost to the max it can be inscreased
			stats[i] = [6-@attacker.stages[i], stats[i]].min
		end
		if stats[PBStats::ATTACK] != 0 || stats[PBStats::SPATK] != 0
			for j in @attacker.moves
				next if j.nil?
				specmove=true if j.pbIsSpecial?()
				physmove=true if j.pbIsPhysical?()
			end
			stats[PBStats::ATTACK] = 0 if !physmove && @battle.FE != PBFields::PSYCHICT
			stats[PBStats::SPATK] = 0 if !specmove
		end
		if stats.all? {|a| a.nil? || a==0 } && move.function != 0x37
			return @move.basedamage > 0 ? 1 : 0
		end
		#Function is split into 3 sections- individual stat sections, group stat sections, and collective stat sections.
		#Individual is self explanatory; group stats splits stats into offensive/defensive (sweep/tank) and processese separately
		#Collective checks run on all of the stats.
		miniscore=1.0
		if @move.basedamage == 0
			statsboosted = 0
			for i in 1...stats.length				
				statsboosted += stats[i] if stats[i] != nil				
			end
			miniscore = statsboosted
			# weight categories based on combinations of boosted stats
			if (stats[PBStats::ATTACK] > 0 || stats[PBStats::SPATK] > 0) && (stats[PBStats::SPEED] > 0) # Speed and offense i.e dragon dance
				miniscore *= 1.8 
			elsif (stats[PBStats::ATTACK] > 1 || stats[PBStats::SPATK] > 1) # Double offense i.e swords dance, nasty plot
				miniscore *= 1.5 
			elsif (stats[PBStats::ATTACK] > 0 || stats[PBStats::SPATK] > 0) && (stats[PBStats::DEFENSE] > 0 || stats[PBStats::SPDEF] > 0) # Defense and offense i.e bulk up
				miniscore *= 1.5 
			elsif (stats[PBStats::DEFENSE] > 0 && stats[PBStats::SPDEF] > 0) # Both defenses i.e cosmic power
				miniscore *= 1.5 
			end	
		end
		for i in 1...stats.length
			next if stats[i].nil? || stats[i]==0
			case i
				when PBStats::ATTACK
					next if !physmove
					sweep = true
					miniscore*=1.3 if checkAIhealing()
					miniscore*=1.5 if pbAIfaster?() || @attacker.moves.any? {|moveloop| moveloop.priority > 0 && moveloop.pbIsPhysical?(moveloop.pbType(@attacker))}
					miniscore*=0.5 if @attacker.status==PBStatuses::BURN && @attacker.ability != PBAbilities::GUTS
					miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY])
					miniscore*=1.4 if notOHKO?(@attacker,@opponent)
					miniscore*=0.6 if checkAIpriority()
					miniscore*=0.6 if (@opponent.ability == PBAbilities::SPEEDBOOST || (@opponent.ability == PBAbilities::MOTORDRIVE && @battle.FE == PBFields::ELECTRICT))
				when PBStats::DEFENSE
					tank = true
					if pbRoughStat(@opponent,PBStats::SPATK)<pbRoughStat(@opponent,PBStats::ATTACK)
						if !(@mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL))
							if pbAIfaster?(@move) && (@attacker.hp.to_f)/@attacker.totalhp>0.75
								miniscore*=1.3
							elsif !pbAIfaster?(@move)
								miniscore*=0.7
							end
						end
						miniscore*=1.3
					end
				when PBStats::SPATK
					sweep = true
					miniscore*=1.3 if checkAIhealing()
					miniscore*=1.5 if pbAIfaster?() || @attacker.moves.any? {|moveloop| moveloop.priority > 0 && moveloop.pbIsSpecial?(moveloop.pbType(@attacker))}
					miniscore*=0.5 if @attacker.status==PBStatuses::PARALYSIS
					if notOHKO?(@attacker,@opponent)
						miniscore*=1.4
					end
					miniscore*=0.6 if checkAIpriority()
				when PBStats::SPDEF
					tank = true
					miniscore*=1.1 if @opponent.status==PBStatuses::BURN
					if pbRoughStat(@opponent,PBStats::SPATK)>pbRoughStat(@opponent,PBStats::ATTACK)
						if !(@mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL))
							if pbAIfaster?(@move) && (@attacker.hp.to_f)/@attacker.totalhp>0.75
								miniscore*=1.3
							elsif !pbAIfaster?(@move)
								miniscore*=0.7
							end
						end
						miniscore*=1.3
					end
				when PBStats::SPEED
					sweep = true
					if pbAIfaster?()
						miniscore*=0.8
						miniscore*=0.2 if statsboosted == stats[PBStats::SPEED]
					end
					#Additional check if you're the last mon alive?
					miniscore*=0.2 if @battle.trickroom > 1 || checkAImoves([PBMoves::TRICKROOM])
					#Skip speed checks if we only have priority damaging moves anyway
					if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.basedamage > 0 && moveloop.priority < 1 && @mondata.roughdamagearray.transpose[@attacker.moves.find_index(moveloop)].max > 10 } # thank u perry 4 saving me									
						#Moxie/Soul Heart	
						miniscore*=1.5 if (physmove && @attacker.ability == PBAbilities::MOXIE) || (specmove && @attacker.ability == PBAbilities::SOULHEART)
						if @attacker.attack<@attacker.spatk
							miniscore*=(1+0.05*@attacker.stages[PBStats::SPATK]) if @attacker.stages[PBStats::SPATK]<0
						else
							miniscore*=(1+0.05*@attacker.stages[PBStats::SPATK]) if @attacker.stages[PBStats::ATTACK]<0
						end
						ministat=0
						ministat+=@opponent.stages[PBStats::DEFENSE]
						ministat+=@opponent.stages[PBStats::SPDEF]
						miniscore*= 1 - 0.05*ministat if ministat>0
					end
				when PBStats::ACCURACY
					for j in @attacker.moves
						next if j.nil?
						miniscore*=1.1 if j.basedamage<95
					end
					miniscore*=(1+0.05*@opponent.stages[PBStats::EVASION]) if @opponent.stages[PBStats::EVASION]>0
					if (@mondata.oppitemworks && @opponent.item == PBItems::BRIGHTPOWDER) || (@mondata.oppitemworks && @opponent.item == PBItems::LAXINCENSE) || accuracyWeatherAbilityActive?(@opponent)
						miniscore*=1.1
					end
				when PBStats::EVASION
					tank = true
					miniscore*=0.2 if @opponent.ability == PBAbilities::NOGUARD || @attacker.ability == PBAbilities::NOGUARD || checkAIaccuracy() || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
					if (@mondata.attitemworks && @attacker.item == PBItems::BRIGHTPOWDER) || (@mondata.attitemworks && @attacker.item == PBItems::LAXINCENSE) || accuracyWeatherAbilityActive?(@attacker)
						miniscore*=1.3
					end
			end
		end
		if seedProtection?(@attacker) || ((@attacker.effects[PBEffects::Substitute]>0 || @attacker.effects[PBEffects::Disguise]) && !@battle.doublebattle)
			miniscore*=1.3
		end
		miniscore*=0.5 if ((@opponent.effects[PBEffects::Substitute]>0 || @attacker.effects[PBEffects::Disguise]))
		miniscore*=1.3 if @opponent.status==PBStatuses::SLEEP || @opponent.status==PBStatuses::FROZEN
		miniscore*=1.3 if hasbadmoves(20)
		attackerHPpercent = (@attacker.hp.to_f)/@attacker.totalhp
		if attackerHPpercent > 0.5 && attackerHPpercent < 0.75 && (@attacker.ability == PBAbilities::EMERGENCYEXIT || @attacker.ability == PBAbilities::WIMPOUT || (@attacker.itemWorks? && @attacker.item == PBItems::EJECTBUTTON))
			miniscore*=0.3
		elsif attackerHPpercent < 0.33 && move.basedamage==0
			miniscore*=0.3
		end
		if @mondata.skill>=MEDIUMSKILL
			bestmove, maxdam = checkAIMovePlusDamage()
			if maxdam < (@attacker.hp/4.0) && sweep
				miniscore*=1.2
			elsif maxdam < (@attacker.hp/3.0) && tank
				miniscore*=1.1
			elsif maxdam < (@attacker.hp/4.0) && (stats[PBStats::DEFENSE] != 0 && stats[PBStats::SPDEF] != 0) #cosmic power
				miniscore*=1.5
			elsif maxdam < (@attacker.hp/2.0) 
				miniscore*=1.1
			elsif move.basedamage == 0
				miniscore*=0.8
				miniscore*=0.3 if !@attacker.moves.any? { |moveloop| moveloop.basedamage > 0 && pbAIfaster?(moveloop,bestmove) }
				#Don't set up if you're gonna die this turn for sure
				miniscore*=0.1 if maxdam > @attacker.hp && !(@attacker.effects[PBEffects::Substitute]>0 || @attacker.effects[PBEffects::Disguise] || seedProtection?(@attacker))
			end

			if maxdam * 2 > @attacker.hp + (hpGainPerTurn(@attacker)-1)*@attacker.totalhp && (stats[PBStats::ATTACK]==1 || stats[PBStats::SPATK]==1) && 
				((bestmove.pbIsPhysical?(bestmove.type) && stats[PBStats::DEFENSE] == 0) || (bestmove.pbIsSpecial?(bestmove.type) && stats[PBStats::SPDEF] == 0)) && move.basedamage == 0
				miniscore*=0.4
			end
		end
		#Don't set up if you're just going to get run over
		if (@opponent.level-10)>@attacker.level
			miniscore*=0.6
			if (@opponent.level-15)>@attacker.level
				miniscore*=0.2
			end
		end
		#Some stats run similar checks		
		miniscore*=0.3 if checkAImoves([PBMoves::SNATCH])
		if sweep
			ministat=@opponent.stages[PBStats::ATTACK]+@opponent.stages[PBStats::SPATK]+@opponent.stages[PBStats::SPEED]
			miniscore*=(1+0.05*ministat)
			if @attacker.stages[PBStats::SPEED]<0 && stats[PBStats::SPEED]==0
				miniscore*=(1+0.05*@attacker.stages[PBStats::SPEED])
			end
			miniscore*=1.2 if attackerHPpercent > 0.75
			miniscore*=1.2 if @attacker.turncount<2
			miniscore*=1.2 if @opponent.status!=0
			if @opponent.effects[PBEffects::Encore]>0
				miniscore*=1.5 if @opponent.moves[(@opponent.effects[PBEffects::EncoreIndex])].basedamage==0
			end
			miniscore*=0.6 if @attacker.effects[PBEffects::LeechSeed]>=0 || @attacker.effects[PBEffects::Attract]>=0
			miniscore*=0.5 if checkAImoves(PBStuff::PHASEMOVE)
			miniscore*=1.3 if @mondata.roles.include?(PBMonRoles::SWEEPER)
			if @attacker.status==PBStatuses::PARALYSIS
				miniscore*=0.5
				miniscore*=0.5 if stats[PBStats::SPEED] != 0 #stacks
			end
			miniscore*=0.5 if @attacker.pbCanParalyze?(false) && checkAImoves(PBStuff::PARAMOVE) && @move.basedamage == 0
			miniscore*=0.7 if @attacker.status==PBStatuses::POISON && @attacker.ability!=PBAbilities::POISONHEAL
			miniscore*=0.6 if @attacker.effects[PBEffects::Toxic]>0 && @attacker.ability!=PBAbilities::POISONHEAL
			miniscore*=0.6 if checkAIpriority()
			miniscore*=0.6 if (@opponent.ability == PBAbilities::SPEEDBOOST || ((@opponent.ability == PBAbilities::MOTORDRIVE && @battle.FE == PBFields::ELECTRICT) && (stats[PBStats::SPEED] < 2)))
			miniscore*=1.4 if notOHKO?(@attacker,@opponent)
		else
			miniscore*=1.1 if attackerHPpercent > 0.75
			miniscore*=1.1 if @attacker.turncount<2
			miniscore*=1.1 if @opponent.status!=0
			if @opponent.effects[PBEffects::Encore]>0
				if @opponent.moves[(@opponent.effects[PBEffects::EncoreIndex])].basedamage==0
					miniscore*=1.3
					miniscore*=1.2 if (stats[PBStats::DEFENSE] != 0 && stats[PBStats::SPDEF] != 0)
				end
			end
			miniscore*=0.2 if checkAImoves(PBStuff::PHASEMOVE)
			miniscore*=0.7 if @attacker.status==PBStatuses::POISON && @attacker.ability!=PBAbilities::POISONHEAL
			miniscore*=0.2 if @attacker.effects[PBEffects::Toxic]>0 && @attacker.ability!=PBAbilities::POISONHEAL
			miniscore*=0.3 if @attacker.effects[PBEffects::LeechSeed]>=0 || @attacker.effects[PBEffects::Attract]>=0
		end
		if tank
			if @attacker.stages[PBStats::SPDEF]>0 || @attacker.stages[PBStats::DEFENSE]>0
				ministat=0
				ministat+=@attacker.stages[PBStats::SPDEF] if stats[PBStats::SPDEF] != 0
				ministat+=@attacker.stages[PBStats::DEFENSE] if stats[PBStats::DEFENSE] != 0
				miniscore*=(1-0.05*ministat)
			end
			miniscore*=1.3 if @attacker.moves.any?{|moveloop| moveloop!=nil && moveloop.isHealingMove?}
			miniscore*=1.3 if @attacker.pbHasMove?(PBMoves::LEECHSEED)
			miniscore*=1.2 if @attacker.pbHasMove?(PBMoves::PAINSPLIT)
			miniscore*=1.2 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
			miniscore*=(1.2*hpGainPerTurn)
			if @mondata.skill>=MEDIUMSKILL
				miniscore*=0.3 if checkAIdamage() < 0.12*@attacker.hp && (getAIMemory().length > 0)
			end
		end
		if @attacker.effects[PBEffects::Confusion]>0
			if stats[PBStats::ATTACK] != 0 #if move boosts attack
				miniscore*=0.2
				miniscore*=0.5 if stats[PBStats::ATTACK] > 1 #using swords dance or shell smash while confused is Extra Bad
				miniscore*=1.5 if stats[PBStats::DEFENSE] != 0#adds a correction for moves that boost attack and defense
			else
				miniscore*=0.5
			end
		end
		if @battle.doublebattle
			if !(@attacker.pbPartner.pbHasMove?(PBMoves::PSYCHUP))
				miniscore*=0.7 
			else
				miniscore*=1.1 
			end
			miniscore*=0.5 if !sweep  #drop is doubled
			miniscore*=1.8 if (@attacker.pbPartner.pbHasMove?(PBMoves::FOLLOWME) || @attacker.pbPartner.pbHasMove?(PBMoves::RAGEPOWDER))
		end
		miniscore*=0.2 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE,PBMoves::TOPSYTURVY])
		miniscore*=1.3 if @opponent.effects[PBEffects::HyperBeam]>0
		miniscore*=1.7 if @opponent.effects[PBEffects::Yawn]>0
		miniscore*=2 if @attacker.pbHasMove?(PBMoves::STOREDPOWER)
		miniscore*=1.2 if @attacker.pbPartner.pbHasMove?(PBMoves::PSYCHUP) || @attacker.pbHasMove?(PBMoves::BATONPASS)
		
		if move.basedamage>0
			if @initial_scores[@score_index]>=100
				miniscore *= 1.2
			elsif @initial_scores.length>0
				miniscore*= 0.5 if hasgreatmoves()
			end
			miniscore=1 if @opponent.ability == PBAbilities::UNAWARE || miniscore < 1
			miniscore=pbSereneGraceCheck(miniscore)
		else
			miniscore*=0 if @attacker.ability == PBAbilities::CONTRARY 
			miniscore*=0.01 if @opponent.ability == PBAbilities::UNAWARE
		end
    	return miniscore
	end


	def selfstatdrop(stats,score)
		stats.map!.with_index {|a,ind| @attacker.pbTooLow?(ind+1) ? 0 : a}
		return 1.0 if stats.all? {|a| a==0}
		#Only uses a 5 stat array
		miniscore=1.0
		stats.unshift(0)

		if stats[PBStats::ATTACK] != 0 #Basically just to catch superpower
			if score<100
				miniscore*=0.9
				if !pbAIfaster?()
					miniscore*=1.1
				else
					miniscore*=0.5 if checkAIhealing()
				end
			end
		elsif stats[PBStats::DEFENSE] != 0 || stats[PBStats::SPDEF] != 0
			if score<100
				miniscore*=0.9
				miniscore*=0.9 if stats[PBStats::SPEED] != 0
				if !pbAIfaster?()
					miniscore*=1.1
				else
					miniscore*=0.6 if checkAIhealing()
				end
				miniscore*=0.7 if checkAIpriority()
			end
		elsif stats[PBStats::SPEED] != 0
			miniscore*=0.9 if score<100
			miniscore*=1.1 if @mondata.roles.include?(PBMonRoles::TANK)
			if pbAIfaster?()
				miniscore*=0.8
				if @battle.pbPokemonCount(@battle.pbParty(@opponent.index))>1 && @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))==1
					miniscore*=0.8
				end
			else
				#miniscore*=1.1
			end
		elsif stats[PBStats::SPATK] != 0
			if @mondata.skill>=BESTSKILL && @battle.FE == PBFields::GLITCHF && @attacker.getSpecialStat(which_is_higher: true) == PBStats::SPDEF
				miniscore*=1.4
			elsif score<100
				miniscore*=0.9
				miniscore*=0.5 if checkAIhealing()
			end
		end
		if @initial_scores.length>0
			miniscore*=0.6 if hasgreatmoves()
		end
		minimini=100
		livecount=@battle.pbPokemonCount(@battle.pbParty(@opponent.index))
		miniscore*=1 - 0.05 * (livecount-3) if livecount>1
		
		party=@battle.pbParty(@attacker.index)
		pivotvar=false
		for i in 0...party.length
			next if party[i].nil?
			temproles = pbGetMonRoles(party[i])
			if temproles.include?(PBMonRoles::PIVOT)
				pivotvar=true
			end
		end
		miniscore*=1.2 if pivotvar && !@battle.doublebattle
		livecount2=@battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
		if livecount>1 && livecount2==1
			miniscore*=0.8
		end
		miniscore = 1 if miniscore < 1 && livecount==1 && score>=100
		return miniscore
	end

	def oppstatboost(stats)
		stats.map!.with_index {|a,ind| @opponent.pbTooHigh?(ind+1) ? 0 : a}
		#This still uses the 5-array of stats in case other games want to expand on it
		stats.unshift(0)
		miniscore=1.0
		if @opponent.index != @attacker.pbPartner.index
			if @opponent.pbCanConfuse?(false)
				if stats[PBStats::SPATK] != 0 
					miniscore*=1 + 0.1*@opponent.stages[PBStats::ATTACK] if @opponent.stages[PBStats::ATTACK] > 0
					if @opponent.attack>@opponent.spatk
						miniscore*=1.5
					else
						miniscore*=0.3
					end
				elsif stats[PBStats::ATTACK] != 0
					if @opponent.attack<@opponent.spatk
						miniscore*=1.5
					else
						miniscore*=0.7
					end
				end
				miniscore*=confucode
			else
				miniscore=0
			end
		else
			return 0 if @battle.pbOwnedByPlayer?(@attacker.pbPartner.index)
			miniscore *= @opponent.pbCanConfuse?(false) ? 0.5 : 1.5
			miniscore*=1.5 if (@opponent.attack<@opponent.spatk && stats[PBStats::ATTACK] != 0) || (@opponent.attack>@opponent.spatk && stats[PBStats::SPATK] != 0)
			miniscore*=0.3 if (1.0/@opponent.totalhp)*@opponent.hp < 0.6
			if @opponent.effects[PBEffects::Attract]>=0 || @opponent.status==PBStatuses::PARALYSIS || @opponent.effects[PBEffects::Yawn]>0 || @opponent.status==PBStatuses::SLEEP
				miniscore*=0.3
			end
			miniscore*=1.2 if @mondata.oppitemworks && (@opponent.item == PBItems::PERSIMBERRY || @opponent.item == PBItems::LUMBERRY)
			miniscore*=0 if @opponent.ability == PBAbilities::CONTRARY
			miniscore*=0 if @opponent.effects[PBEffects::Substitute]>0
			opp1 = @attacker.pbOppositeOpposing
			opp2 = opp1.pbPartner
			if @opponent.pbSpeed > opp1.pbSpeed && @opponent.pbSpeed > opp2.pbSpeed
				miniscore*=1.3
			else
				miniscore*=0.7
			end
		end
		return miniscore
	end

	def oppstatdrop(stats)
		return 1 if @move.basedamage > 0 && @initial_scores[@score_index]>=100
		return @move.basedamage > 0 ? 1 : 0 if @opponent.ability == PBAbilities::CLEARBODY || @opponent.ability == PBAbilities::WHITESMOKE
		#stats should be an array of the stat boosts like so: [ATK,DEF,SPE,SPA,SPD,ACC,EVA] with nils in unaffected stats
		#coil, for example, would be [1,1,0,0,0,1,0]
		stats.unshift(0) #this is required to make the next line work correctly
		#Start by eliminating pointless stats
		for i in 1...stats.length
			next if stats[i] == 0
			stats[i] = 0 if !@opponent.pbCanReduceStatStage?(i)
			#Don't get into counter-setup wars you can't win
			stats[i] = 0 if @move.basedamage == 0 && stats[i] && @opponent.stages[i]>stats[i]
		end
		if stats[PBStats::DEFENSE]>0 || stats[PBStats::SPDEF]>0
			for j in @attacker.moves
				next if j.nil?
				specmove=true if j.pbIsSpecial?()
				physmove=true if j.pbIsPhysical?()
			end
			stats[PBStats::DEFENSE] = 0 if !physmove
			stats[PBStats::SPDEF] = 0 if !specmove
		end
		if stats[PBStats::ATTACK]>0 || stats[PBStats::SPATK]>0
			bestmove = checkAIbestMove()
			stats[PBStats::SPATK] = 0 if (pbRoughStat(@opponent,PBStats::ATTACK)*0.9>pbRoughStat(@opponent,PBStats::SPATK)) && bestmove.pbIsPhysical?()
			stats[PBStats::ATTACK] = 0 if (pbRoughStat(@opponent,PBStats::SPATK)*0.9>pbRoughStat(@opponent,PBStats::ATTACK)) && bestmove.pbIsSpecial?()
		end
		if stats[PBStats::SPEED] > 0 
			stats[PBStats::SPEED] = 0 if pbAIfaster?() && @battle.trickroom == 0
			stats[PBStats::SPEED] = 0 if @battle.trickroom > 1
		end
		if stats.all? {|a| a.nil? || a==0 }
			return @move.basedamage > 0 ? 1 : 0
		end
		#This section is split up a little weird to avoid duplicating checks
		miniscore = 1.0	
		if @move.basedamage == 0
			statsboosted = 0
			for i in 1...stats.length
				statsboosted += stats[i]
			end
			miniscore = statsboosted
		end
		if stats[PBStats::DEFENSE]>0 || stats[PBStats::SPDEF]>0    #defense stuff
			miniscore*=1.1
			miniscore*=1.2 if checkAIdamage() < @opponent.hp
			miniscore*=1.5 if @move.function == 0x4C
		else			#non-defense stuff
			if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
				miniscore*=1.3 if stats[PBStats::ATTACK]>0 || stats[PBStats::SPATK]>0 || stats[PBStats::ACCURACY]>0
				miniscore*=1.1 if stats[PBStats::SPEED]>0
			end
		end
		if stats[PBStats::SPEED]>0  #speed stuff
			if (pbRoughStat(@opponent,PBStats::SPEED)*0.66) > @attacker.pbSpeed
				miniscore*= hasgreatmoves() ? 1 : 1.5
			end
			miniscore*=1+0.05*@opponent.stages[PBStats::SPEED] if @opponent.stages[PBStats::SPEED]<0 && !secondaryEffectNegated?()
			miniscore*=0.1 if @opponent.itemWorks? && (@opponent.item == PBItems::LAGGINGTAIL || @opponent.item == PBItems::IRONBALL)
			miniscore*=0.2 if @opponent.ability == PBAbilities::COMPETITIVE || @opponent.ability == PBAbilities::DEFIANT || @opponent.ability == PBAbilities::CONTRARY
		else    #non-speed stuff
			miniscore*=0.1 if @opponent.ability == PBAbilities::COMPETITIVE || @opponent.ability == PBAbilities::DEFIANT || @opponent.ability == PBAbilities::CONTRARY
			miniscore*=1.1 if @mondata.partyroles.any? {|roles| roles.include?(PBMonRoles::SWEEPER)}
		end
		#status & moves section
		if stats[PBStats::DEFENSE]>0 || stats[PBStats::SPATK]>0 || stats[PBStats::SPDEF]>0
			miniscore*=1.2 if @opponent.status==PBStatuses::POISON || @opponent.status==PBStatuses::BURN
		end
		if stats[PBStats::ATTACK]>0
			miniscore*=1.2 if @opponent.status==PBStatuses::POISON
			miniscore*=0.5 if @opponent.status==PBStatuses::BURN
			miniscore*=0.5 if @attacker.pbHasMove?(PBMoves::FOULPLAY)
		end
		if stats[PBStats::SPEED]>0
			miniscore*=0.5 if @attacker.pbHasMove?(PBMoves::GYROBALL)
			miniscore*=1.5 if @attacker.pbHasMove?(PBMoves::ELECTROBALL)
			miniscore*=1.3 if checkAImoves([PBMoves::ELECTROBALL])
			miniscore*=0.5 if checkAImoves([PBMoves::GYROBALL])
			miniscore*=0.1 if  @battle.trickroom!=0 || checkAImoves([PBMoves::TRICKROOM])
		end
		if @battle.pbPokemonCount(@battle.pbParty(@opponent.index))==1 || @attacker.ability == PBAbilities::SHADOWTAG || @opponent.effects[PBEffects::MeanLook]>0
			miniscore*=1.2
		end
		miniscore *= 0.5 if @mondata.roles.include?(PBMonRoles::PHAZER)
		miniscore *= 0.8 if hasgreatmoves() #hoping this doesn't self sabotage
		if move.basedamage>0
			miniscore=pbSereneGraceCheck(miniscore)
		else
			miniscore*=0.5 if @battle.pbPokemonCount(@battle.pbParty(@attacker.index))==1
			miniscore*=0.7 if @attacker.status!=0
		end
		return miniscore
	end

	def focusenergycode
		return 0 if @attacker.effects[PBEffects::FocusEnergy]!=2
		miniscore = 1.0
		attackerHPpercent = (@attacker.hp.to_f)/@attacker.totalhp
		if attackerHPpercent>0.75
			miniscore*=1.2
		elsif attackerHPpercent > 0.5 && attackerHPpercent < 0.75 && (@attacker.ability == PBAbilities::EMERGENCYEXIT || @attacker.ability == PBAbilities::WIMPOUT || (@attacker.itemWorks? && @attacker.item == PBItems::EJECTBUTTON))
			miniscore*=0.3
		elsif attackerHPpercent < 0.33
			miniscore*=0.3
		end
		miniscore*=1.3 if @opponent.effects[PBEffects::HyperBeam]>0
		miniscore*=1.7 if @opponent.effects[PBEffects::Yawn]>0
		miniscore*=0.6 if @attacker.effects[PBEffects::LeechSeed]>=0 || @attacker.effects[PBEffects::Attract]>=0
		miniscore*=0.5 if checkAImoves(PBStuff::PHASEMOVE)
		miniscore*=0.2 if @attacker.effects[PBEffects::Confusion]>0
		miniscore*=0.3 if @attacker.pbOpposingSide.effects[PBEffects::Retaliate]
		miniscore*=1.2 if (@attacker.hp/4.0)>checkAIdamage()
		miniscore*=1.2 if @attacker.turncount<2
		miniscore*=1.2 if @opponent.status!=0
		miniscore*=1.3 if @opponent.status==PBStatuses::SLEEP || @opponent.status==PBStatuses::FROZEN
		miniscore*=1.5 if @opponent.effects[PBEffects::Encore]>0 && @opponent.moves[(@opponent.effects[PBEffects::EncoreIndex])].basedamage==0
		miniscore*=0.5 if @battle.doublebattle
		miniscore*=2 if @attacker.ability == PBAbilities::SUPERLUCK || @attacker.ability == PBAbilities::SNIPER
		miniscore*=1.2 if @mondata.attitemworks && (@attacker.item == PBItems::SCOPELENS || @attacker.item == PBItems::RAZORCLAW || (@attacker.item == PBItems::STICK && @attacker.pokemon.species==PBSpecies::FARFETCHD) || (@attacker.item == PBItems::LUCKYPUNCH && @attacker.pokemon.species==PBSpecies::CHANSEY))
		miniscore*=1.3 if (@mondata.attitemworks && @attacker.item == PBItems::LANSATBERRY)
		miniscore*=0.2 if @opponent.ability == PBAbilities::ANGERPOINT || @opponent.ability == PBAbilities::SHELLARMOR || @opponent.ability == PBAbilities::BATTLEARMOR
		miniscore*=0.5 if @attacker.pbHasMove?(PBMoves::LASERFOCUS) || @attacker.pbHasMove?(PBMoves::FROSTBREATH) || @attacker.pbHasMove?(PBMoves::STORMTHROW)
		miniscore*= 2**(@attacker.moves.count{|moveloop| moveloop!=nil && moveloop.hasHighCriticalRate?})
		return miniscore
	end

	def defogcode
		miniscore = 1.0
		yourpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
		theirpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@opponent.index))
		if yourpartycount>1
			miniscore*=2 if @attacker.pbOwnSide.effects[PBEffects::StealthRock]
			miniscore*=3 if @attacker.pbOwnSide.effects[PBEffects::StickyWeb]
			miniscore*=(1.5**@attacker.pbOwnSide.effects[PBEffects::Spikes])
			miniscore*=(1.7**@attacker.pbOwnSide.effects[PBEffects::ToxicSpikes])
		end
		miniscore -= 1.0
		miniscore*=(yourpartycount-1) if yourpartycount>1
		minimini = 1.0
		if theirpartycount>1
			minimini*=0.5 if @opponent.pbOwnSide.effects[PBEffects::StealthRock]
			minimini*=0.3 if @opponent.pbOwnSide.effects[PBEffects::StickyWeb]
			minimini*=(0.7**@opponent.pbOwnSide.effects[PBEffects::Spikes])
			minimini*=(0.6**@opponent.pbOwnSide.effects[PBEffects::ToxicSpikes])
		end
		minimini -= 1.0
		minimini*=(theirpartycount-1) if theirpartycount>1
		miniscore+=minimini
		miniscore+=1.0
		if miniscore<0
			miniscore=0
		end
		miniscore*=2 if @opponent.pbOwnSide.effects[PBEffects::Reflect]>0
		miniscore*=2 if @opponent.pbOwnSide.effects[PBEffects::LightScreen]>0
		miniscore*=1.3 if @opponent.pbOwnSide.effects[PBEffects::Safeguard]>0
		miniscore*=3 if @opponent.pbOwnSide.effects[PBEffects::AuroraVeil]>0
		miniscore*=1.3 if @opponent.pbOwnSide.effects[PBEffects::Mist]>0
		return miniscore
	end

	def oppstatrestorecode
		return 1 if @opponent.effects[PBEffects::Substitute] > 0
		miniscore = 1 + 0.05*statchangecounter(@opponent,1,7)
		miniscore *=1.1 if (@opponent.ability == PBAbilities::SPEEDBOOST || (@opponent.ability == PBAbilities::MOTORDRIVE && @battle.FE == PBFields::ELECTRICT))
		return miniscore
	end

	def hazecode
		oppscore = 1.1 * statchangecounter(@opponent,1,7)
		attscore = -1.1 * statchangecounter(@attacker,1,7)
		if @battle.doublebattle
			oppscore += 1.1 * statchangecounter(@opponent.pbPartner,1,7) if @opponent.pbPartner.hp>0
			attscore += -1.1 * statchangecounter(@attacker.pbPartner,1,7) if @attacker.pbPartner.hp>0
		end
		miniscore = oppscore + attscore
		miniscore*=0.8 if ((@opponent.ability == PBAbilities::SPEEDBOOST || (@opponent.ability == PBAbilities::MOTORDRIVE && @battle.FE == PBFields::ELECTRICT)) || checkAImoves(PBStuff::SETUPMOVE))
		return miniscore
	end

	def statswapcode(stat1,stat2)
		attstages = @attacker.stages[stat1] + @attacker.stages[stat2]
		miniscore = -1.1 * attstages
		if (pbRoughStat(@attacker,stat1)>pbRoughStat(@attacker,stat2))
			miniscore*=2 if @attacker.stages[stat1]<0
		else
			miniscore*=2 if @attacker.stages[stat2]<0
		end
		oppstages = @opponent.stages[stat1] + @opponent.stages[stat2]
		minimini = -1.1 * attstages
		if (pbRoughStat(@opponent,stat1)>pbRoughStat(@opponent,stat2))
			minimini*=2 if @opponent.stages[stat1]>0
		else
			minimini*=2 if @opponent.stages[stat2]>0
		end
		miniscore+=minimini
		miniscore*=0.8 if @battle.doublebattle
		return miniscore
	end

	def psychupcode
		statarray = [0,0,0,0,0,0,0]
		boostarray = [0,0,0,0,0,0,0]
		droparray = [0,0,0,0,0,0,0]
		statarray[0] = (@opponent.stages[PBStats::ATTACK]-@attacker.stages[PBStats::ATTACK])
		statarray[1] = (@opponent.stages[PBStats::DEFENSE]-@attacker.stages[PBStats::DEFENSE])
		statarray[2] = (@opponent.stages[PBStats::SPEED]-@attacker.stages[PBStats::SPEED])
		statarray[3] = (@opponent.stages[PBStats::SPATK]-@attacker.stages[PBStats::SPATK])
		statarray[4] = (@opponent.stages[PBStats::SPDEF]-@attacker.stages[PBStats::SPDEF])
		statarray[5] = (@opponent.stages[PBStats::ACCURACY]-@attacker.stages[PBStats::ACCURACY])
		statarray[6] = (@opponent.stages[PBStats::EVASION]-@attacker.stages[PBStats::EVASION])
		for i in 0..6
			boostarray[i] = statarray[i] if i > 0
			droparray[i] = statarray[i]*-1 if i < 0
		end
		return boostarray,droparray
	end

	def mistcode
		miniscore = 1.0
		if @attacker.pbOwnSide.effects[PBEffects::Mist]==0
			miniscore*=1.1
			# check opponent for stat decreasing moves
			miniscore*=1.3 if getAIMemory().any? {|j| j.function==0x42 || j.function==0x43 || j.function==0x44 || j.function==0x45 || j.function==0x46 || j.function==0x47 || j.function==0x48 || j.function==0x49 || j.function==0x4A || j.function==0x4B || j.function==0x4C || j.function==0x4D || j.function==0x4E || j.function==0x4F || j.function==0xE2 || j.function==0x138 || j.function==0x13B || j.function==0x13F}
		end
		return miniscore
	end

	def powertrickcode
		miniscore=1.0
		if @attacker.attack - @attacker.defense >= 100
			miniscore*=1.5 if pbAIfaster?(@move)
			miniscore*=2 if pbRoughStat(@opponent,PBStats::ATTACK)>pbRoughStat(@opponent,PBStats::SPATK)
			miniscore*=2 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.isHealingMove?}
		elsif @attacker.defense - @attacker.attack >= 100
			if pbAIfaster?(@move)
				miniscore*=1.5
				miniscore*=2 if notOHKO?(@attacker, @opponent)
			else
				miniscore*=0
			end
		else
			miniscore*=0.1
		end
		miniscore*=0.1 if @attacker.effects[PBEffects::PowerTrick]
		return miniscore
	end

	def splitcode(stat)
		return 0 if @opponent.effects[PBEffects::Substitute] > 0
		miniscore=1.0
		case stat
			when PBStats::ATTACK
				if @opponent.attack > @opponent.spatk
					return 0 if @attacker.attack > @opponent.attack
					miniscore = @opponent.attack - @attacker.attack
					miniscore *= @attacker.attack > @attacker.spatk ? 2 : 0.5
				else
					return 0 if @attacker.spatk > @opponent.spatk
					miniscore = @opponent.spatk - @attacker.spatk
					miniscore *= @attacker.spatk > @attacker.attack ? 2 : 0.5
				end
			when PBStats::DEFENSE
				if @opponent.attack > @opponent.spatk
					return 0 if @attacker.defense > @opponent.defense
					miniscore = @opponent.defense - @attacker.defense
					miniscore *= @attacker.attack > @attacker.spatk ? 2 : 0.5
				else
					return 0 if @attacker.spdef > @opponent.spdef
					miniscore = @opponent.spdef - @attacker.spdef
					miniscore *= @attacker.spatk > @attacker.attack ? 2 : 0.5
				end
			when PBStats::HP
				return 0 if @opponent.effects[PBEffects::Substitute]>0
				ministat = [(@opponent.hp + @attacker.hp) / 2.0, @attacker.totalhp].min
				maxdam = checkAIdamage()
				return 0 if maxdam > ministat
				if maxdam > @attacker.hp
					return pbAIfaster?(@move) ? 2 : 0
				else
					miniscore*=0.3 if checkAImoves(PBStuff::SETUPMOVE)
					miniscore*= @opponent.hp/(@attacker.hp).to_f
					return miniscore
				end
		end
		miniscore = 1 + miniscore/100.0
		return miniscore
	end

	def tailwindcode
		return 0 if @attacker.pbOwnSide.effects[PBEffects::Tailwind]>0
		miniscore=1.5
		if pbAIfaster?() && !@mondata.roles.include?(PBMonRoles::LEAD)
			miniscore*=0.9
			miniscore*=0.4 if @attacker.pbNonActivePokemonCount==0
		end
		miniscore*=0.5 if (@opponent.ability == PBAbilities::SPEEDBOOST || (@opponent.ability == PBAbilities::MOTORDRIVE && @battle.FE == PBFields::ELECTRICT))
		miniscore*=0.1 if @battle.trickroom!=0 || checkAImoves([PBMoves::TRICKROOM])
		miniscore*=1.4 if @mondata.roles.include?(PBMonRoles::LEAD)
		miniscore*=2.5 if !@battle.opponent.is_a?(Array) && @battle.opponent.trainertype==PBTrainers::ADRIENN
		return miniscore
	end

	def mimicsketchcode(blacklist,sketch)
		lastmove = (sketch) ? @opponent.lastMoveUsedSketch : @opponent.lastMoveUsed
		return 0 if @opponent.effects[PBEffects::Substitute] > 0
		return 0 if pbAIfaster?(@move) && (blacklist.include?($cache.pkmn_move[lastmove][PBMoveData::FUNCTION]) || lastmove<0)
		miniscore = ($cache.pkmn_move[lastmove][PBMoveData::BASEDAMAGE] > 0) ? $cache.pkmn_move[lastmove][PBMoveData::BASEDAMAGE] : 40
		miniscore=1 + miniscore/100.0
		miniscore*=0.5 if miniscore<=1.5
		miniscore*=0.5 if !pbAIfaster?(@move)
		return miniscore
	end

	def typechangecode(type)
		return 0 if type == @attacker.type1 && type == @attacker.type2
		return 0 if @attacker.ability == PBAbilities::MULTITYPE || @attacker.ability == PBAbilities::RKSSYSTEM || @attacker.ability == PBAbilities::PROTEAN || @attacker.ability == PBAbilities::COLORCHANGE
		miniscore = [PBTypes.getCombinedEffectiveness(@opponent.type1,@attacker.type1,@attacker.type2),PBTypes.getCombinedEffectiveness(@opponent.type2,@attacker.type1,@attacker.type2)].max
		minimini = [PBTypes.getEffectiveness(@opponent.type1,type),PBTypes.getEffectiveness(@opponent.type2,type)].max
		return 0 if minimini > miniscore
		miniscore*=2
		miniscore*=pbAIfaster?(@move) ? 1.2 : 0.7
		stabvar = false
		newstabvar = false
		for i in @attacker.moves
			next if i.nil?
			stabvar = true if (i.pbType(@attacker)==@attacker.type1 || i.pbType(@attacker)==@attacker.type2) && i.basedamage != 0
			newstabvar = true if i.pbType(@attacker)==type && i.basedamage != 0
		end
		if stabvar && !newstabvar
			miniscore*=1.2
		else
			miniscore*=0.6
		end
		return miniscore
	end

	def opptypechangecode(type)
		return 0 if type == @opponent.type1 && type == @opponent.type2
		return 0 if @opponent.ability == PBAbilities::MULTITYPE || @opponent.ability == PBAbilities::RKSSYSTEM || @opponent.ability == PBAbilities::PROTEAN || @opponent.ability == PBAbilities::COLORCHANGE
		miniscore = [PBTypes.getCombinedEffectiveness(@attacker.type1,@opponent.type1,@opponent.type2),PBTypes.getCombinedEffectiveness(@attacker.type2,@opponent.type1,@opponent.type2)].max
		minimini = [PBTypes.getEffectiveness(@attacker.type1,type),PBTypes.getEffectiveness(@attacker.type2,type)].max
		return 0 if minimini < miniscore
		minimini *= 0.5 if getAIMemory(@opponent).any?{|moveloop|moveloop!=nil && moveloop.pbType(@opponent) == type}
		minimini *= 1.5 if @attacker.moves.any?{|moveloop| moveloop!=nil && PBTypes.getEffectiveness(moveloop.pbType(@attacker),type) > 2}
		return minimini
	end

	def abilitychangecode(ability)
		return 0 if @opponent.ability == ability || (PBStuff::FIXEDABILITIES).include?(@opponent.ability)
		miniscore = getAbilityDisruptScore(@attacker,@opponent)
		if @opponent.index == @attacker.pbPartner.index
			if miniscore < 2
			  	miniscore = 2 - miniscore
			else
			  	miniscore = 0
			end
		end
		if ability == PBAbilities::SIMPLE
			miniscore*=1.3 if @opponent.index==@attacker.pbPartner.index && @opponent.moves.any?{|moveloop| moveloop!=nil && (PBStuff::SETUPMOVE).include?(moveloop)}
			miniscore*=0.5 if checkAImoves(PBStuff::SETUPMOVE)
		elsif ability == PBAbilities::INSOMNIA
			miniscore*=1.3 if checkAImoves([PBMoves::SNORE,PBMoves::SLEEPTALK])
			miniscore*=2 if checkAImoves([PBMoves::REST])
			miniscore*=0.3 if @attacker.moves.any?{|moveloop| moveloop!=nil && (PBStuff::SLEEPMOVE).include?(moveloop)}
		end
		return miniscore
	end

	def roleplaycode # Role Play
		return 0 if (PBStuff::ABILITYBLACKLIST).include?(@opponent.ability)
		return 0 if (PBStuff::FIXEDABILITIES).include?(@attacker.ability)
		return 0 if @opponent.ability == 0 || @attacker.ability == @opponent.ability
		miniscore = getAbilityDisruptScore(@opponent,@attacker)
		minimini = getAbilityDisruptScore(@attacker,@opponent)
		return (1 + (minimini-miniscore))
	end

	def entraincode(score)
		return 0 if (PBStuff::FIXEDABILITIES).include?(@opponent.ability)
		return 0 if @opponent.ability == PBAbilities::TRUANT
		return 0 if (PBStuff::ABILITYBLACKLIST).include?(@attacker.ability) && @attacker.ability != PBAbilities::WONDERGUARD
		return 0 if @opponent.ability == 0 || @attacker.ability == @opponent.ability
		miniscore = getAbilityDisruptScore(@opponent,@attacker)
		minimini = getAbilityDisruptScore(@attacker,@opponent)
		if @opponent.index != @attacker.pbPartner.index
			score*= (1 + (minimini-miniscore))
			if (@attacker.ability == PBAbilities::TRUANT)
				score*=3
			elsif (@attacker.ability == PBAbilities::WONDERGUARD)
				score=0
			end
		else
			score *= (1 + (miniscore-minimini))
			case @attacker.ability
				when PBAbilities::WONDERGUARD then score +=85
				when PBAbilities::SPEEDBOOST  then score +=25
			end
			case @opponent.ability
				when PBAbilities::DEFEATIST  then score +=30
				when PBAbilities::SLOWSTART  then score +=50
			end
		end
		return score
	end

	def skillswapcode
		return 0 if (PBStuff::FIXEDABILITIES).include?(@attacker.ability) && @attacker.ability != PBAbilities::ZENMODE
		return 0 if (PBStuff::FIXEDABILITIES).include?(@opponent.ability) && @opponent.ability != PBAbilities::ZENMODE
		return 0 if @opponent.ability == PBAbilities::ILLUSION || @attacker.ability == PBAbilities::ILLUSION
		return 0 if @opponent.ability == 0 || @attacker.ability == @opponent.ability
		miniscore = getAbilityDisruptScore(@opponent,@attacker)
		minimini = getAbilityDisruptScore(@attacker,@opponent)
		miniscore = [2-miniscore,0].max if @opponent.index == @attacker.pbPartner.index
		miniscore *= (1 + (minimini-miniscore)*2)
		miniscore*=2 if (@attacker.ability == PBAbilities::TRUANT && @opponent.index!=@attacker.pbPartner.index) || (@opponent.ability == PBAbilities::TRUANT && @opponent.index==@attacker.pbPartner.index)
		return miniscore
	end

	def gastrocode
		return 0 if @opponent.effects[PBEffects::GastroAcid] || @opponent.effects[PBEffects::Substitute]>0 || (PBStuff::FIXEDABILITIES).include?(@opponent.ability)
		return getAbilityDisruptScore(@attacker,@opponent)
	end

	def transformcode
		return 0 if @opponent.effects[PBEffects::Transform] || @opponent.effects[PBEffects::Illusion] || @opponent.effects[PBEffects::Substitute]>0 || @attacker.effects[PBEffects::Transform]
		miniscore = 1 + (@opponent.level - @attacker.level) / 20
		miniscore *= 1.1 * (statchangecounter(@opponent,1,5) - statchangecounter(@attacker,1,5))
		return miniscore
	end

	def endeavorcode
		return 0 if @attacker.hp > @opponent.hp
		miniscore = 1.0
		miniscore*=1.5 if @attacker.moves.any?{|moveloop| moveloop!=nil && moveloop.pbIsPriorityMoveAI(@attacker)}
		miniscore*=1.5 if notOHKO?(@attacker, @opponent, true)
		miniscore*=2 if @opponent.level - @attacker.level > 9
		return miniscore
	end

	def ohkode
		return 0 if (@opponent.level>@attacker.level) || notOHKO?(@opponent, @attacker, true)
		return 3.5 if @opponent.effects[PBEffects::LockOn]>0 || @opponent.ability==PBAbilities::NOGUARD || @attacker.ability==PBAbilities::NOGUARD || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
		return 0.7
	end

	def counterattackcode
		miniscore = 1.0
		maxdam = checkAIdamage()
		miniscore*=0.5 if pbAIfaster?()
		if notOHKO?(@attacker, @opponent, true)
			miniscore*=1.2
		else
			miniscore*=0.8
			miniscore*=0.8 if maxdam>@attacker.hp
		end
		miniscore*=0.7 if $cache.pkmn_move[@attacker.lastMoveUsed][PBMoveData::FUNCTION] == @move.function
		miniscore*=0.6 if checkAImoves(PBStuff::SETUPMOVE)
		miniscore*=(@attacker.hp/@attacker.totalhp)
		bestmove = checkAIbestMove()
		if @move.function == 0x71 # Counter
			if pbRoughStat(@opponent,PBStats::ATTACK) > (pbRoughStat(@opponent,PBStats::SPATK) * 1.1) # attack is at least 10% higher than sp.atk
				miniscore*=1.1
			elsif pbRoughStat(@opponent,PBStats::ATTACK)<(pbRoughStat(@opponent,PBStats::SPATK) * 0.6)
				miniscore*=0.3
			else 
				miniscore*=0.6
			end
			miniscore*=0.05 if bestmove.pbIsSpecial?()
			miniscore*=1.1 if $cache.pkmn_move[@attacker.lastMoveUsed][PBMoveData::FUNCTION]==0x72
		elsif @move.function == 0x72 # Mirror Coat
			if (pbRoughStat(@opponent,PBStats::ATTACK) * 1.1)<pbRoughStat(@opponent,PBStats::SPATK) # attack is at least 10% higher than sp.atk
				miniscore*=1.1
			elsif (pbRoughStat(@opponent,PBStats::ATTACK) * 0.6)>pbRoughStat(@opponent,PBStats::SPATK)
				miniscore*=0.3
			else 
				miniscore*=0.6
			end
			miniscore*=0.3 if @opponent.spatk<@opponent.attack
			miniscore*=0.05 if bestmove.pbIsPhysical?()
			miniscore*=1.1 if $cache.pkmn_move[@attacker.lastMoveUsed][PBMoveData::FUNCTION]==0x71
		end
		return miniscore
	end

	def revengecode
		miniscore = 1.0
		miniscore*= pbAIfaster?() ? 0.5 : 1.5
		if @attacker.hp==@attacker.totalhp
			miniscore*=1.2
			miniscore*=1.1 if notOHKO?(@attacker, @opponent, true)
		else
			miniscore*=0.3 if checkAIdamage()>@attacker.hp
		end
		miniscore*=0.8 if checkAImoves(PBStuff::SETUPMOVE)
		return miniscore
	end

	def pursuitcode
		miniscore=1-0.1*statchangecounter(@opponent,1,7,-1)
		miniscore*=1.2 if @opponent.effects[PBEffects::Confusion]>0
		miniscore*=1.5 if @opponent.effects[PBEffects::LeechSeed]>=0
		miniscore*=1.3 if @opponent.effects[PBEffects::Attract]>=0
		miniscore*=0.7 if @opponent.effects[PBEffects::Substitute]>0
		miniscore*=1.5 if @opponent.effects[PBEffects::Yawn]>0
		miniscore*=1.5 if pbTypeModNoMessages>4
		return miniscore
	end

	def echocode
		miniscore = 1.0
		miniscore*=0.7 if @attacker.status==PBStatuses::PARALYSIS
		miniscore*=0.7 if @attacker.effects[PBEffects::Confusion]>0
		miniscore*=0.7 if @attacker.effects[PBEffects::Attract]>=0
		miniscore*=1.3 if @attacker.hp==@attacker.totalhp
		miniscore*=1.5 if checkAIdamage()<(@attacker.hp/3.0)
		return miniscore
	end

	def helpinghandcode
		return 0 if !@battle.doublebattle || @attacker.pbPartner.hp==0
		miniscore = 1.0
		miniscore*=2 if !@attacker.moves.any?{|moveloop| moveloop!=nil && pbTypeModNoMessages(moveloop.pbType(@attacker),@attacker,@opponent,moveloop,@mondata.skill)>=4}
		if !pbAIfaster?() && !pbAIfaster?(nil,nil,@attacker,@opponent.pbPartner)
			miniscore*=1.2
			miniscore*=1.5 if @attacker.hp/@attacker.totalhp < 0.33
			miniscore*=1.5 if !pbAIfaster?(nil,nil,@attacker.pbPartner,@opponent) && !pbAIfaster?(nil,nil,@attacker.pbPartner,@opponent.pbPartner)
		end
		miniscore *= 1+(([@attacker.pbPartner.attack,@attacker.pbPartner.spatk].max - [@attacker.attack,@attacker.spatk].max) / 100)
		return miniscore
	end

	def mudsportcode
		return 0 if @battle.state.effects[PBEffects::MudSport] != 0
		miniscore = 1.0
		eff1 = PBTypes.getCombinedEffectiveness(PBTypes::ELECTRIC,@attacker.type1,@attacker.type2)
		eff2 = PBTypes.getCombinedEffectiveness(PBTypes::ELECTRIC,@attacker.pbPartner.type1,@attacker.pbPartner.type2)
		miniscore*=1.5 if eff1>4 || eff2>4 && @opponent.hasType?(:ELECTRIC)
		miniscore*=0.7 if pbPartyHasType?(PBTypes::ELECTRIC)
		return miniscore
	end

	def watersportcode
		return 0 if @battle.state.effects[PBEffects::WaterSport] != 0
		miniscore = 1.0
		eff1 = PBTypes.getCombinedEffectiveness(PBTypes::FIRE,@attacker.type1,@attacker.type2)
		eff2 = PBTypes.getCombinedEffectiveness(PBTypes::FIRE,@attacker.pbPartner.type1,@attacker.pbPartner.type2)
		miniscore*=1.5 if eff1>4 || eff2>4 && @opponent.hasType?(:FIRE)
		miniscore*=0.7 if pbPartyHasType?(PBTypes::FIRE)
		return miniscore
	end

	def permacritcode(initialscore)
		return 0 if @opponent.index == @attacker.pbPartner.index && (@opponent.ability != PBAbilities::ANGERPOINT || @opponent.stages[PBStats::ATTACK]==6)
		return 0 if @attacker.effects[PBEffects::LaserFocus]!=0 && @move.function==0x165
		return 0.7 if @opponent.ability == PBAbilities::BATTLEARMOR || @opponent.ability == PBAbilities::SHELLARMOR
		miniscore = 1.0
		miniscore += 0.1 * @opponent.stages[PBStats::DEFENSE] if @opponent.stages[PBStats::DEFENSE]>0
		miniscore += 0.1 * @opponent.stages[PBStats::SPDEF] if @opponent.stages[PBStats::SPDEF]>0
		miniscore -= 0.1 * @attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK]<0
		miniscore -= 0.1 * @attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK]<0
		miniscore -= 0.1 * @attacker.effects[PBEffects::FocusEnergy] if @attacker.effects[PBEffects::FocusEnergy]>0
		return miniscore if !(@opponent.ability == PBAbilities::ANGERPOINT && @opponent.stages[PBStats::ATTACK]!=6)
		if @attacker.pbPartner.index == @opponent.index && @move.function != 0x165
			return 0 if @opponent.attack>@opponent.spatk || initialscore>80
			miniscore = (100-initialscore)
			if pbAIfaster?(nil,nil,@opponent,@attacker.pbOpposing2) && pbAIfaster?(nil,nil,@opponent,@attacker.pbOpposing1)
				miniscore*=1.3
			else
			    miniscore*=0.7
			end
		else
			if initialscore<100
			    miniscore*=0.7
			    miniscore*=0.2 if @opponent.attack>@opponent.spatk
			end
		end
		return miniscore
	end

	def screencode
		return 0 if (@attacker.pbOwnSide.effects[PBEffects::Reflect]>0 && @move.function == 0xA2) || (@attacker.pbOwnSide.effects[PBEffects::LightScreen]>0 && @move.function == 0xA3)
		return 0 if @move.function == 0x15b && !(@battle.pbWeather==PBWeather::HAIL || (@mondata.skill >= BESTSKILL && (@battle.FE == PBFields::SNOWYM || @battle.FE == PBFields::MIRRORA || @battle.FE == PBFields::STARLIGHTA || @battle.FE == PBFields::DARKCRYSTALC || @battle.FE == PBFields::RAINBOWF || @battle.FE == PBFields::ICYF || @battle.FE == PBFields::CRYSTALC)))	
		return 0 if @attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>0 && @move.function == 0x15b
		return 0 if @attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>3
		miniscore=1.2
		miniscore*=0.2 if @attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>0
		if @move.function == 0xA2 # Reflect
			if pbRoughStat(@opponent,PBStats::ATTACK) > (pbRoughStat(@opponent,PBStats::SPATK) * 1.1) # attack is at least 10% higher than sp.atk
				miniscore*=1.3
			elsif pbRoughStat(@opponent,PBStats::ATTACK)<(pbRoughStat(@opponent,PBStats::SPATK) * 0.6)
				miniscore*=0.5
			else 
				miniscore*=0.9
			end
		elsif @move.function == 0xA3 # Light Screen
			if (pbRoughStat(@opponent,PBStats::ATTACK) * 1.1)<pbRoughStat(@opponent,PBStats::SPATK) # attack is at least 10% higher than sp.atk
				miniscore*=1.3
			elsif (pbRoughStat(@opponent,PBStats::ATTACK) * 0.6)>pbRoughStat(@opponent,PBStats::SPATK)
				miniscore*=0.5
			else 
				miniscore*=0.9
			end
		end
		miniscore*=1.1 if (@mondata.attitemworks && @attacker.item == PBItems::LIGHTCLAY) || @mondata.skill >=BESTSKILL && @battle.FE == PBFields::MIRRORA
		if pbAIfaster?(@move)
			miniscore*=1.1
			if @mondata.skill>=MEDIUMSKILL
				if getAIMemory().length > 0
					#patch this to check for physical or special based on function code
					maxdam=0
					for j in getAIMemory()
						next if @move.function == 0xA2 && !j.pbIsPhysical?()
						next if @move.function == 0xA3 && !j.pbIsSpecial?()
						tempdam = pbRoughDamage(j,@opponent,@attacker)
						maxdam=tempdam if maxdam<tempdam
					end
					miniscore*=2 if maxdam>@attacker.hp && (maxdam/2.0)<@attacker.hp
				end
			end
		end
		livecount = @battle.pbPokemonCount(@battle.pbParty(@opponent.index))
		if livecount<=2
			miniscore*=0.7
			miniscore*=0.5 if livecount==1
		else
			miniscore*=1.4 if (@mondata.attitemworks && @attacker.item == PBItems::LIGHTCLAY)
		end
		miniscore*=1.3 if notOHKO?(@attacker, @opponent)
		if @attacker.index == 2 # for partners to guess if the player will use aurora veil
			miniscore *= 0.3 if @attacker.pbPartner.pbHasMove?(PBMoves::AURORAVEIL)
			if @move.function == 0xA2 # Reflect
				miniscore *= 0.3 if @attacker.pbPartner.pbHasMove?(PBMoves::REFLECT)
			elsif @move.function == 0xA3 # Light Screen
				miniscore *= 0.3 if @attacker.pbPartner.pbHasMove?(PBMoves::LIGHTSCREEN)
			end
		end
		miniscore*=0.1 if checkAImoves(PBStuff::SCREENBREAKERMOVE)
		return miniscore
	end

	def secretcode
		case @battle.FE
			when 1,18 		then return paracode()
			when 2,15,31 	then return sleepcode()
			when 3,29 		then return oppstatdrop([0,0,0,1,0,0,0])
			when 4,12,20 	then return oppstatdrop([0,0,0,0,0,1,0])
			when 5 			then return oppstatdrop([0,1,0,0,0,0,0])
			when 6,34 		then return oppstatdrop([0,0,0,0,1,0,0])
			when 7,16,32 	then return burncode()
			when 8,21,24 	then return oppstatdrop([0,0,1,0,0,0,0])
			when 9 			then return (paracode() + poisoncode() + burncode() + poisoncode() + sleepcode) / 5
			when 10,11,26 	then return poisoncode()
			when 13,28 		then return freezecode()
			when 14,23,27 	then return flinchcode()
			when 17,22 		then return oppstatdrop([1,0,0,0,0,0,0])
			when 19 		then return (paracode() + poisoncode() + burncode() + poisoncode()) / 4
			when 25 		then return (confucode() + poisoncode() + burncode() + sleepcode()) / 4
			when 30 		then return oppstatdrop([0,0,0,0,0,0,1])
			when 35 		then return oppstatdrop([1,1,1,1,1,1,1])
			when 36, 37 	then return confucode()
			else 			return paracode()
		end
	end

	def nevermisscode(score)
		miniscore=1.0
		miniscore*=1.05 if score>=110
		return miniscore if @attacker.ability == PBAbilities::NOGUARD || @opponent.ability == PBAbilities::NOGUARD || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
		miniscore*= (1 - 0.05*@attacker.stages[PBStats::ACCURACY]) if @attacker.stages[PBStats::ACCURACY]<0
		miniscore*= (1 + 0.05*@opponent.stages[PBStats::EVASION]) if @opponent.stages[PBStats::EVASION]>0
		miniscore*=1.2 if (@mondata.oppitemworks && @opponent.item == PBItems::LAXINCENSE) || (@mondata.oppitemworks && @opponent.item == PBItems::BRIGHTPOWDER)
		miniscore*=1.3 if accuracyWeatherAbilityActive?(@opponent)
		#miniscore*=3 if opponent.vanished && pbAIfaster?()
		return miniscore
	end

	def lockoncode
		return 0 if @opponent.effects[PBEffects::LockOn]>0 || @opponent.effects[PBEffects::Substitute]>0 || @attacker.ability == PBAbilities::NOGUARD && @opponent.ability == PBAbilities::NOGUARD || (@attacker.ability==PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
		miniscore=1.0
		miniscore*=3 if @attacker.pbHasMove?(PBMoves::INFERNO) || @attacker.pbHasMove?(PBMoves::ZAPCANNON) || @attacker.pbHasMove?(PBMoves::DYNAMICPUNCH)
		miniscore*=10 if @attacker.pbHasMove?(PBMoves::GUILLOTINE) || @attacker.pbHasMove?(PBMoves::SHEERCOLD) || @attacker.pbHasMove?(PBMoves::GUILLOTINE) || @attacker.pbHasMove?(PBMoves::FISSURE) || @attacker.pbHasMove?(PBMoves::HORNDRILL)
		ministat = (@attacker.stages[PBStats::ACCURACY]<0) ? @attacker.stages[PBStats::ACCURACY] : 0
		miniscore*=1 + 0.1*ministat
		miniscore*=1 + 0.1*@opponent.stages[PBStats::EVASION]
		return miniscore
	end

	def forecode5me #after doing hundreds of these this is how i survive
		return 0 if @opponent.effects[PBEffects::Foresight]
		ministat = (@opponent.stages[PBStats::EVASION]>0) ? @opponent.stages[PBStats::EVASION] : 0
		miniscore=1+0.10*ministat
		if @opponent.pbHasType?(:GHOST)
			miniscore*=1.5
			miniscore*=5 if @attacker.ability != PBAbilities::SCRAPPY && !@attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.basedamage > 0 && moveloop.pbType(@attacker) != PBTypes::NORMAL && moveloop.pbType(@attacker) != PBTypes::FIGHTING}
		end
		return miniscore
	end

	def miracode
		return 0 if @opponent.effects[PBEffects::MiracleEye]
		ministat = (@opponent.stages[PBStats::EVASION]>0) ? @opponent.stages[PBStats::EVASION] : 0
		miniscore=1+0.10*ministat
		if @opponent.pbHasType?(:DARK)
			miniscore*=1.1
			miniscore*=2 if !@attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.basedamage > 0 && moveloop.pbType(@attacker) != PBTypes::PSYCHIC}
		end
		return miniscore
	end

	def chipcode
		ministat = 0
		ministat+=@opponent.stages[PBStats::EVASION] if @opponent.stages[PBStats::EVASION]>0
		ministat+=@opponent.stages[PBStats::DEFENSE] if @opponent.stages[PBStats::DEFENSE]>0
		ministat+=@opponent.stages[PBStats::SPDEF]   if @opponent.stages[PBStats::SPDEF]>0
		miniscore=1 + 0.05*ministat
		return miniscore
	end

	def protectcode
		miniscore = 1.0
		miniscore*=0.6
		miniscore*= 1.3 if @battle.trickroom > 0 && !pbAIfaster?()
		miniscore*= 1.3 if @battle.field.duration > 0 && getFieldDisruptScore(@attacker,@opponent) > 1.0
		miniscore*= 1.3 if @attacker.pbOpposingSide.effects[PBEffects::LightScreen] || @attacker.pbOpposingSide.effects[PBEffects::Reflect] || @attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]
		miniscore*= 1.2 if @attacker.pbOpposingSide.effects[PBEffects::Tailwind]
		miniscore*= 0.3 if @opponent.moves.any? {|moveloop| moveloop!=nil && (PBStuff::SETUPMOVE).include?(moveloop.id)}
		if @attacker.ability == PBAbilities::SPEEDBOOST && !pbAIfaster?() && @battle.trickroom==0
			miniscore*=8
			#experimental -- cancels out drop if killing moves
			if @initial_scores.length>0
				miniscore*=6 if hasgreatmoves()
			end
			#end experimental
		end
		
		miniscore*=4 if @attacker.ability == PBAbilities::SLOWSTART && @attacker.turncount<5
		miniscore*=(1.2*hpGainPerTurn) if hpGainPerTurn > 1
		miniscore*=0.1 if (hpGainPerTurn-1) * @attacker.totalhp - @attacker.hp < 0 && (hpGainPerTurn(@opponent)-1) * @opponent.totalhp - @opponent.hp > 0
		if @opponent.status==PBStatuses::POISON || @opponent.status==PBStatuses::BURN
			miniscore*=1.2
			miniscore*=1.3 if @opponent.effects[PBEffects::Toxic]>0
		end
		if @attacker.status==PBStatuses::POISON || @attacker.status==PBStatuses::BURN
			miniscore*=0.7
			miniscore*=0.3 if @attacker.effects[PBEffects::Toxic]>1
		end
		miniscore*=1.3 if @opponent.effects[PBEffects::LeechSeed]>=0
		miniscore*=4 if @opponent.effects[PBEffects::PerishSong]!=0
		miniscore*=0.3 if @opponent.status==PBStatuses::SLEEP || @opponent.status==PBStatuses::FROZEN
		if @opponent.vanished
			miniscore*=12
			miniscore*=1.5 if !pbAIfaster?()
		end
		miniscore*=0.2 if checkAImoves(PBStuff::PROTECTIGNORINGMOVE)
		if @attacker.effects[PBEffects::Wish]>0
			miniscore*= checkAIdamage()>=@attacker.hp ? 15 : 2
		end
		miniscore/=(@attacker.effects[PBEffects::ProtectRate]*2.0) if PBStuff::RATESHARERS.include?(@attacker.lastMoveUsed)
		miniscore*=0.7 if PBStuff::RATESHARERS.include?(@attacker.lastMoveUsed) && @battle.doublebattle
		if @move.function == 0x133 #and obstruct, eventually
			miniscore*=0.1 if checkAImoves([PBMoves::WILLOWISP,PBMoves::THUNDERWAVE,PBMoves::TOXIC])
		end
		return miniscore
	end

	def protecteffectcode
		return 0 if seedProtection?(@attacker)
		miniscore = protectcode
		miniscore*=1.5 if @opponent.turncount==0
		miniscore*=1.3 if getAIMemory().any?{|moveloop| moveloop!=nil && moveloop.isContactMove?}
		return miniscore
	end

	def feintcode
		return 1 if !checkAImoves(PBStuff::PROTECTMOVE)
		miniscore = 1.1
		miniscore*=1.2 if !PBStuff::RATESHARERS.include?(@opponent.lastMoveUsed)
		return miniscore
	end

	def mirrorcode(copycat=false)
		return 0 if @opponent.lastMoveUsed<=0
		if copycat == true
			mirrmove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@battle.previousMove),@attacker)
		else
			mirrmove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@opponent.lastMoveUsed),@attacker)
		end
		return 0 if mirrmove.flags&0x10==0
		miniscore = [pbRoughDamage(mirrmove) / @opponent.hp.to_f, 100].min
		#score = pbGetMoveScore(mirrmove,@attacker,@opponent,@mondata.skill,rough)
		miniscore*=0.5 if !pbAIfaster?() && @attacker.ability != PBAbilities::PRANKSTER
		return miniscore
	end

	def yousecondcode
		return 0 if !pbAIfaster?(@move)
		miniscore = 1.0
		miniscore*= (checkAImoves(PBStuff::SETUPMOVE)) ? 0.8 : 1.5
		if checkAIpriority()
			miniscore*=0.6
		else
			miniscore*=1.5
		end
		miniscore*= (checkAIdamage()/(1.0*@opponent.hp)>@initial_scores.max) ? 2 : 0.5 if @opponent.hp>0 && @initial_scores.length>0
		return miniscore
	end

	
	
	def coatcode
		miniscore=1.0
		if @attacker.lastMoveUsed==PBMoves::MAGICCOAT
			miniscore*=0.5
		else
			miniscore*=1.5 if @attacker.hp==@attacker.totalhp
			miniscore*=3 if !@opponent.moves.any? {|moveloop| moveloop!=nil && moveloop.basedamage>0}
		end
		return miniscore
	end

	def snatchcode
		miniscore=1.0
		if @attacker.lastMoveUsed==PBMoves::SNATCH
			miniscore*=0.5
		else
			miniscore*=1.5 if @opponent.hp==@opponent.totalhp
			miniscore*=2 if checkAImoves(PBStuff::SETUPMOVE)
			if @opponent.attack>@opponent.spatk
				miniscore*= (@attacker.attack>@attacker.spatk) ? 1.5 : 0.7
			else
				miniscore*= (@attacker.spatk>@attacker.attack) ? 1.5 : 0.7
			end
		end
		return miniscore
	end

	def specialprotectcode
		miniscore = 1.0
		miniscore/=(@attacker.effects[PBEffects::ProtectRate]*2.0) if PBStuff::RATESHARERS.include?(@attacker.lastMoveUsed)
		miniscore*=2 if @battle.doublebattle
		miniscore*=0.3 if checkAIdamage() || checkAImoves(PBStuff::SETUPMOVE)
		miniscore*=0.1 if checkAImoves(PBStuff::PROTECTIGNORINGMOVE)
		if @attacker.effects[PBEffects::Wish]>0
			miniscore*=2 if checkAIdamage()>@attacker.hp || (@attacker.pbPartner.hp*(1.0/@attacker.pbPartner.totalhp))<0.25
		end
		return miniscore
	end

	def sleeptalkcode(initialscores=[])
		return 5 if @attacker.ability=PBAbilities::COMATOSE && @attacker.item == PBItems::CHOICEBAND
		if @attacker.ability!=PBAbilities::COMATOSE
			return 0 if @attacker.status!=PBStatuses::SLEEP || @attacker.statusCount<=1
		end
		return 5 if !@attacker.pbHasMove?(PBMoves::SNORE)
		otherscores = 0
		for i in 0..3
			currentid = @attacker.moves[i].id || nil
			next if currentid.nil? || currentid == PBMoves::SLEEPTALK
			snorescore = initialscores[i] if currentid == PBMoves::SNORE
			otherscores += initialscores[i] if currentid != PBMoves::SNORE
		end
		otherscores *= 0.5
		return 0.1 if otherscores<snorescore
		return 5
	end

	def metronomecode(scorethreshold)
		return 0 if @attacker.pbNonActivePokemonCount > 0
		return @initial_scores.any?{|scores| scores > scorethreshold} ? 0.5 : 1.5
	end

	def tormentcode
		return 0 if @opponent.effects[PBEffects::Torment] || (@battle.pbCheckSideAbility(:AROMAVEIL,@opponent)!=nil && !moldBreakerCheck(@attacker))
		oldmoveid = @opponent.lastMoveUsed
		miniscore = 1.0
		miniscore*= pbAIfaster?(@move) ? 1.2 : 0.7
		if $cache.pkmn_move[oldmoveid][PBMoveData::BASEDAMAGE] > 0
			miniscore*=1.5
			bestmove, maxdam = checkAIMovePlusDamage()
			if bestmove.id == oldmoveid
				miniscore*=1.3
				miniscore*=1.5 if maxdam*3<@attacker.totalhp
			end
			miniscore*=1.5 if @attacker.pbHasMove?(PBMoves::PROTECT)
			miniscore*=1.3 if hpGainPerTurn>1
		else
			miniscore*=0.5
		end
		return miniscore
	end

	def imprisoncode
		return 0 if @opponent.effects[PBEffects::Imprison]
		miniscore = 1.0
		subscore = 1
		ourmoves = Array.new(@attacker.moves.length)
		for i in 0..3
			ourmoves[i] = @attacker.moves[i].id
		end
		miniscore*=1.3 if ourmoves.include?(@opponent.lastMoveUsed)
		for j in getAIMemory()
			if ourmoves.include?(j.id)
				subscore+=1
				miniscore*=1.5 if j.isHealingMove?
			else
				miniscore*=0.7
			end
		end
		miniscore*=subscore
		return miniscore
	end

	def disablecode
		return 0 if @opponent.effects[PBEffects::Disable]>0 || (@battle.pbCheckSideAbility(:AROMAVEIL,@opponent)!=nil && !moldBreakerCheck(@attacker))
		oldmove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@opponent.lastMoveUsed),@opponent)
		return 0 if oldmove.id == -1 && pbAIfaster?(@move,oldmove)
		miniscore=1.0
		miniscore*= pbAIfaster?(@move,oldmove) ? 1.2 : 0.7
		if oldmove.basedamage>0 || oldmove.isHealingMove?
			miniscore*=1.5
			bestmove, maxdam = checkAIMovePlusDamage()
			if bestmove.id == oldmove.id
				miniscore*=1.3
				miniscore*=1.5 if maxdam*3 < @attacker.totalhp && opponent.pbPartner.hp <= 0
				miniscore*=1.5 if maxdam*3 > @attacker.totalhp && opponent.pbPartner.hp > 0
			end
		else
			miniscore*=0.5
		end
		return miniscore
	end

	def tauntcode
		return 0 if @opponent.effects[PBEffects::Taunt]>0 || (@battle.pbCheckSideAbility(:AROMAVEIL,@opponent)!=nil && !moldBreakerCheck(@attacker))
		oldmove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@opponent.lastMoveUsed),@opponent)
		miniscore = 0.8
		miniscore*= pbAIfaster?(@move,oldmove) ? 1.5 : 0.7
		if pbGetMonRoles(@opponent).include?(PBMonRoles::LEAD)
			miniscore*=1.2
		else
			miniscore*=0.8
		end
		miniscore*= @opponent.turncount<=1 ? 1.1 : 0.9
		miniscore*=1.3 if oldmove.isHealingMove?
		miniscore *= 0.6 if @battle.doublebattle
		return miniscore
	end

	def healblockcode
		return 0 if @opponent.effects[PBEffects::HealBlock]==0
		miniscore = 1.0
		miniscore*=1.5 if pbAIfaster?(@move)
		miniscore*=2.5 if checkAIhealing()
		miniscore*=((hpGainPerTurn(@opponent))*4)
		return miniscore
	end

	def encorecode
		return 0 if @opponent.effects[PBEffects::Encore]>0 || (@battle.pbCheckSideAbility(:AROMAVEIL,@opponent)!=nil && !moldBreakerCheck(@attacker))
		return 0.2 if @opponent.lastMoveUsed<=0
		oldmove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@opponent.lastMoveUsed),@opponent)
		miniscore = 1.0
		miniscore*=1.5 if @battle.FE == PBFields::BIGTOPA
		miniscore*= pbAIfaster?(@move,oldmove) || oldmove.basedamage==0 ? 2.0 : 0.2
		miniscore*=0.3 if pbRoughDamage(oldmove,@opponent,@attacker) > @attacker.hp
		if pbRoughDamage(oldmove,@opponent,@attacker) * 4 > @attacker.hp
			miniscore*=0.3 
		elsif @opponent.stages[PBStats::SPEED]>0
			if (@opponent.pbHasType?(:DARK) || @attacker.ability != PBAbilities::PRANKSTER || @opponent.ability == PBAbilities::SPEEDBOOST)
				miniscore*=0.5
			else
				miniscore*=2
			end
		else
			miniscore*=2
		end
		return miniscore
	end

	def multihitcode
		miniscore = 1.0
		miniscore*=0.7 if @move.isContactMove? && ((@mondata.oppitemworks && @opponent.item == PBItems::ROCKYHELMET) || @opponent.ability == PBAbilities::IRONBARBS || @opponent.ability == PBAbilities::ROUGHSKIN)
		miniscore*=1.3 if notOHKO?(@opponent, @attacker, true)
		miniscore*=1.3 if @opponent.effects[PBEffects::Substitute]>0
		miniscore*=1.3 if @attacker.itemWorks? && (@attacker.item == PBItems::RAZORFANG || @attacker.item == PBItems::KINGSROCK)
		return miniscore
	end

	def beatupcode(score) # only partner else multihit is used
		return 0 if @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))<1
		return 0 if @opponent.ability != PBAbilities::JUSTIFIED || @opponent.stages[PBStats::ATTACK]>3 || !@opponent.moves.any? {|moveloop| !moveloop.nil? && moveloop.pbIsPhysical?()} || pbRoughDamage > @opponent.hp
		score = 100-score
		if pbAIfaster?(nil, nil, @opponent, @attacker.pbOpposing1) && pbAIfaster?(nil, nil, @opponent, @attacker.pbOpposing2)
			score*=1.3
		else
			score*=0.7
		end
		return score
	end

	def hypercode()
		return 2 if !@battle.doublebattle && @battle.opponent.trainertype==PBTrainers::ZEL
		miniscore = 1.0
		miniscore*=1.3 if @initial_scores[@score_index] >=110 && @battle.FE == PBFields::GLITCHF
		if @initial_scores[@score_index] < 100
			miniscore*=0.5
			miniscore*=0.5 if checkAIhealing()
		end
		return miniscore if @battle.FE == PBFields::GLITCHF # Glitch Field

		if @initial_scores.length>0
			miniscore*=0.3 if hasgreatmoves()
		end
		yourpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
		theirpartycount = @battle.pbPokemonCount(@battle.pbParty(@opponent.index))
		if theirpartycount > 1
			miniscore*=(theirpartycount-1)*0.1
			miniscore=(1-miniscore)
		else
			miniscore*=1.1
		end
		miniscore*=0.5 if @battle.doublebattle
		miniscore*=0.7 if theirpartycount>1 && yourpartycount==1
		return miniscore
	end

	def weaselslashcode
		miniscore = 1.0
		if @attacker.item == PBItems::POWERHERB
			miniscore=1.2 if !hasgreatmoves() && @move.id != PBMoves::GEOMANCY
			miniscore=1.8 if @attacker.ability == PBAbilities::UNBURDEN
			return miniscore
		end
		if checkAIdamage()>@attacker.hp
			miniscore*=0.1 
		elsif (checkAIdamage()*2)>@attacker.hp
			if !pbAIfaster?(@move) 
				miniscore*=0.1 
			else
				miniscore*=0.7 
			end
		end
		miniscore*=0.6 if @attacker.hp/@attacker.totalhp.to_f<0.5
		if @opponent.effects[PBEffects::TwoTurnAttack]!=0
			miniscore*= pbAIfaster?(@move) ? 2 : 0.5
		end
		miniscore*=0.1 if @initial_scores.any? {|score| score > 100}
		miniscore*=0.5 if @battle.doublebattle
		if @move.basedamage > 0
			miniscore*=0.1 if checkAImoves(PBStuff::PROTECTMOVE)
			miniscore*=0.7 if @initial_scores[@score_index] < 100
		elsif # probably geomancy
			miniscore*=0.4
		end
		return miniscore
	end

	def twoturncode
		miniscore=1.0
		if @attacker.item == PBItems::POWERHERB
			miniscore=1.2
			miniscore=1.8 if @attacker.ability == PBAbilities::UNBURDEN
			return miniscore
		end
		if @opponent.status==PBStatuses::POISON || @opponent.status==PBStatuses::BURN || @opponent.effects[PBEffects::LeechSeed]>=0 || @opponent.effects[PBEffects::MultiTurn]>0 || @opponent.effects[PBEffects::Curse]
			miniscore*=1.2
		else
			miniscore*=0.8 if @battle.pbPokemonCount(@battle.pbPartySingleOwner(@opponent.index))>1
		end
		miniscore*=0.5 if @attacker.status!=0 || @attacker.effects[PBEffects::Curse] || @attacker.effects[PBEffects::Attract]>-1 || @attacker.effects[PBEffects::Confusion]>0
		miniscore*=hpGainPerTurn()
		miniscore*=0.7 if @attacker.pbOwnSide.effects[PBEffects::Tailwind]>0 || @attacker.pbOwnSide.effects[PBEffects::Reflect]>0 || @attacker.pbOwnSide.effects[PBEffects::LightScreen]>0 || @attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>0
		miniscore*=1.3 if @opponent.effects[PBEffects::PerishSong]!=0 && @attacker.effects[PBEffects::PerishSong]==0
		if pbAIfaster?()
			miniscore*=3 if @opponent.vanished
			miniscore*=1.1
		else
			miniscore*=0.8
			miniscore*=0.5 if checkAIhealing()
			miniscore*=0.7 if checkAIaccuracy()
		end
		return miniscore
	end

	def firespincode()
		return @move.basedamage > 0 ? 1 : 0 if @initial_scores[@score_index] >= 110 || @opponent.effects[PBEffects::MultiTurn]!=0 || @opponent.effects[PBEffects::Substitute]>0
		miniscore=1.0
		miniscore*=1.2
		if @initial_scores.length>0
			miniscore*=1.2 if hasbadmoves(30)
		end
		if @opponent.totalhp == @opponent.hp
			miniscore*=1.2
		elsif @opponent.hp*2 < @opponent.totalhp
			miniscore*=0.8
		end
		miniscore*=1-0.05*statchangecounter(@opponent,1,7,1)
		if checkAIdamage()>@attacker.hp
			miniscore*=0.7
		elsif @attacker.hp*3<@attacker.totalhp
			miniscore*=0.7
		end
		miniscore*=1.5 if @opponent.effects[PBEffects::LeechSeed]>=0
		miniscore*=1.3 if @opponent.effects[PBEffects::Attract]>-1
		miniscore*=1.3 if @opponent.effects[PBEffects::Confusion]>0
		miniscore*=1.2 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		miniscore*=1.1 if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::PROTECTMOVE).include?(moveloop.id)}
		miniscore*=1.3 if (@mondata.attitemworks && @attacker.item == PBItems::BINDINGBAND)
		miniscore*=1.1 if (@mondata.attitemworks && @attacker.item == PBItems::GRIPCLAW)
		return miniscore
	end

	def uproarcode
		miniscore = 1.0
		miniscore*=0.7 if @opponent.status==PBStatuses::SLEEP
		miniscore*=1.8 if checkAImoves([PBMoves::REST])
		miniscore*=1.1 if @opponent.pbNonActivePokemonCount==0 || @attacker.ability == PBAbilities::SHADOWTAG || @opponent.effects[PBEffects::MeanLook]>0
		miniscore*=0.7 if @move.pbTypeModifier(@move.pbType(@attacker),@attacker,@opponent)<4
		miniscore*=0.75 if @attacker.hp/@attacker.totalhp<0.75
		miniscore*=1+0.05*@attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK]<0
		return miniscore
	end

	def recovercode(amount=@attacker.totalhp/2.0)
		return 0 if @attacker.effects[PBEffects::HealBlock]>0
		return 0 if @attacker.effects[PBEffects::Wish]>0
		miniscore = 1.0
		recoverhp = [@attacker.hp + amount,@attacker.totalhp].min # the amount of hp we expect to have after recover
		if @mondata.skill>=BESTSKILL
			bestmove, maxdam = checkAIMovePlusDamage()
			miniscore *= 0.2 if maxdam > amount # we take more damage than we heal
			miniscore *= 0.6 if maxdam > 1.4 * amount && [0x1C, 0x20].include?(bestmove.function)
			if maxdam>@attacker.hp 		
				if maxdam > recoverhp #if we expect to die after healing, don't bother
					return 0
				else # if we're not going to die, we really want to recover
					miniscore*=5
					if @initial_scores.length>0 && amount > maxdam
						miniscore*=6 if hasgreatmoves() # offset killing moves
					end
				end
			else # if we're not going to die
				miniscore*=2 if maxdam*1.5>@attacker.hp # if a second attack would kill us next turn,
				if !pbAIfaster?(@move) # and we're slower,  then heal pre-emptively
					if maxdam*2>@attacker.hp
						miniscore*=5
						if @initial_scores.length>0 && amount > maxdam
							miniscore*=6 if hasgreatmoves() # offset killing moves
						end
					end
				end
			end
		elsif @mondata.skill>=MEDIUMSKILL
			miniscore*=3 if checkAIdamage()>@attacker.hp
		end
		yourpartycount = @battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))
		theirpartycount = @battle.pbPokemonCount(@battle.pbParty(@opponent.index))
		miniscore*=1.1 if yourpartycount == 1
		miniscore*=0.3 if theirpartycount == 1 && hasgreatmoves()
		miniscore*=0.7 if @opponent.moves.any? {|moveloop| moveloop!=nil && (PBStuff::SETUPMOVE).include?(moveloop.id)}
		if (@attacker.hp.to_f)/@attacker.totalhp<0.5
			miniscore*=1.5
			miniscore*=2 if @attacker.effects[PBEffects::Curse]
			if @attacker.hp*4<@attacker.totalhp
				miniscore*=1.5 if @attacker.status==PBStatuses::POISON
				miniscore*=2 if @attacker.effects[PBEffects::LeechSeed]>=0
				if @attacker.hp<@attacker.totalhp*0.13
					miniscore*=2 if @attacker.status==PBStatuses::BURN
					miniscore*=2 if (@battle.pbWeather==PBWeather::HAIL && !@attacker.pbHasType?(:ICE)) || (@battle.pbWeather==PBWeather::SANDSTORM && !@attacker.pbHasType?(:ROCK) && !@attacker.pbHasType?(:GROUND) && !@attacker.pbHasType?(:STEEL))
				end
			end
		else
			miniscore*=0.9
		end
		if @attacker.effects[PBEffects::Toxic]>0
			miniscore*=0.5
			miniscore*=0.5 if @attacker.effects[PBEffects::Toxic]>3
		end
		miniscore*=1.1 if @attacker.status==PBStatuses::PARALYSIS || @attacker.effects[PBEffects::Attract]>=0 || @attacker.effects[PBEffects::Confusion]>0
		if @opponent.status==PBStatuses::POISON || @opponent.status==PBStatuses::BURN || @opponent.effects[PBEffects::LeechSeed]>=0 || @opponent.effects[PBEffects::Curse]
			miniscore*=1.3
			miniscore*=1.3 if @opponent.effects[PBEffects::Toxic]>0
		end
		miniscore*=1.3 if checkAImoves(PBStuff::CONTRARYBAITMOVE)
		miniscore*=1.2 if @opponent.vanished || @opponent.effects[PBEffects::HyperBeam]>0
		return miniscore if move.function == 0xD7 #Wish doesn't do any of the remaining checks
		if ((@attacker.hp.to_f)/@attacker.totalhp)>0.8
			miniscore=0
		elsif ((@attacker.hp.to_f)/@attacker.totalhp)>0.6
			miniscore*=0.6
		elsif ((@attacker.hp.to_f)/@attacker.totalhp)<0.25
			miniscore*=2
		end
		return miniscore
	end

	def wishcode
		miniscore = recovercode
		maxdam = checkAIdamage()
		recoverhp = [@attacker.hp + @attacker.totalhp/2.0,@attacker.totalhp].min # the amount of hp we expect to have after recover
		if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::PROTECTMOVE).include?(moveloop.id)} # if we have protect
			if (maxdam > @attacker.hp) && (maxdam < recoverhp) && !hasgreatmoves() # and we expect to die, and can't kill the opponent, and we can save ourselves
				miniscore*=4
			else
				miniscore*=0.6
			end
		else # if we don't have protect, we want to be using wish earlier
			miniscore*=2 if (maxdam*2 > @attacker.hp) && maxdam < @attacker.hp && (maxdam * 2 < recoverhp) 
		end
		if @mondata.roles.include?(PBMonRoles::CLERIC)
			miniscore*=1.1 if @battle.pbPartySingleOwner(@attacker.index).any?{|i| i.hp.to_f<0.6*i.totalhp && i.hp.to_f>0.3*i.totalhp}
		end
		return miniscore
	end

	def restcode
		return 0 if !@attacker.pbCanSleep?(false,true,true)
		return 0 if @attacker.hp*(1.0/@attacker.totalhp)>=0.8
		miniscore=1.0
		maxdam = checkAIdamage()
		if maxdam>@attacker.hp && maxdam * 2 < @attacker.totalhp * hpGainPerTurn
			miniscore*=3
		elsif @mondata.skill >= BESTSKILL && maxdam*2 < @attacker.totalhp * hpGainPerTurn
			miniscore*=1.5 if maxdam*1.5>@attacker.hp 
			miniscore*=2 if  maxdam*2>@attacker.hp && !pbAIfaster?()
		end
     	miniscore*=@attacker.hp < 0.5 * @attacker.totalhp ? 1.5 : 0.5
		miniscore*=1.2 if (@mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL))
		if @opponent.status==PBStatuses::POISON || @opponent.status==PBStatuses::BURN || @opponent.effects[PBEffects::LeechSeed]>=0 || @opponent.effects[PBEffects::Curse]
			miniscore*=1.3
			miniscore*=1.3 if @opponent.effects[PBEffects::Toxic]>0
		end
		if @attacker.status==PBStatuses::POISON
			miniscore*=1.3
			miniscore*=1.3 if @opponent.effects[PBEffects::Toxic]>0
		end
		if @attacker.status==PBStatuses::BURN
			miniscore*=1.3
			miniscore*=1.5 if @attacker.spatk<@attacker.attack
		end
		miniscore*=1.3 if @attacker.status==PBStatuses::PARALYSIS
		miniscore*=1.3 if checkAImoves(PBStuff::CONTRARYBAITMOVE)
		if !(@attacker.item == PBItems::LUMBERRY || @attacker.item == PBItems::CHESTOBERRY || hydrationCheck(@attacker))
			miniscore*=0.8
			if maxdam*2 > @attacker.totalhp
			  	miniscore*=0.4
			elsif maxdam*3 < @attacker.totalhp
				miniscore*=1.3
				if @initial_scores.length>0
					miniscore*=6 if hasgreatmoves()
				end
			end
			miniscore*=0.7 if checkAImoves([PBMoves::WAKEUPSLAP,PBMoves::NIGHTMARE,PBMoves::DREAMEATER]) || @opponent.ability == PBAbilities::BADDREAMS
			miniscore*=1.3 if @attacker.pbHasMove?(PBMoves::SLEEPTALK)
			miniscore*=1.2 if @attacker.pbHasMove?(PBMoves::SNORE)
			miniscore*=1.1 if @attacker.ability == PBAbilities::SHEDSKIN || @attacker.ability == PBAbilities::EARLYBIRD
			miniscore*=0.8 if @battle.doublebattle
		else
			if @attacker.item == PBItems::LUMBERRY || @attacker.item == PBItems::CHESTOBERRY
				miniscore*= @attacker.ability == PBAbilities::HARVEST ? 1.2 : 0.8
			end
		end
		if @attacker.status!=0
			miniscore*=1.4
			miniscore*=1.2 if @attacker.effects[PBEffects::Toxic]>0
		end
		return miniscore
	end

	def aquaringcode
		return 0 if (@move.function == 0xda && @attacker.effects[PBEffects::AquaRing]) || (@move.function == 0xdb && @attacker.effects[PBEffects::Ingrain])
		miniscore = 1.0
		attackerHPpercent = @attacker.hp/@attacker.totalhp
		miniscore*=1.2 if attackerHPpercent>0.75
		if attackerHPpercent<0.50
			miniscore*=0.7
			miniscore*=0.5 if attackerHPpercent<0.33
		end
		miniscore*=1.2 if checkAIhealing()
		miniscore*=1.2 if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::PROTECTMOVE).include?(moveloop.id)}
		miniscore*=0.8 if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::PIVOTMOVE).include?(moveloop.id)}
		if checkAIdamage()*5 < @attacker.totalhp && (getAIMemory().length > 0)
			miniscore*=1.2
		elsif checkAIdamage() > @attacker.totalhp*0.4
			miniscore*=0.3
		end
		miniscore*=1.2 if (@mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL) || @mondata.roles.include?(PBMonRoles::TANK))
		miniscore*=0.3 if checkAImoves(PBStuff::PHASEMOVE)
		miniscore*=0.5 if @battle.doublebattle
		return miniscore
	end

	def absorbcode(score)
		return @move.basedamage > 0 ? 1 : 0 if (@attacker.hp==@attacker.totalhp && pbAIfaster?(@move) || @opponent.effects[PBEffects::Substitute]>0)
		hpdrained = ([score,100].min)*@opponent.hp*0.01/2.0
		hpdrained*= 1.5 if @move.function == 0x139 #Draining Kiss
		hpdrained*= 1.3 if (@mondata.attitemworks && @attacker.item == PBItems::BIGROOT)
		if pbAIfaster?(@move)
			hpdrained = (@attacker.totalhp-@attacker.hp) if hpdrained > (@attacker.totalhp-@attacker.hp)
		else
			maxdam = checkAIdamage()
			hpdrained = (@attacker.totalhp-(@attacker.hp-maxdam)) if hpdrained > (@attacker.totalhp-(@attacker.hp-maxdam))
		end
		miniscore = hpdrained/@opponent.totalhp.to_f
		return (1-miniscore) if @opponent.ability == PBAbilities::LIQUIDOOZE
		miniscore*=0.5 #arbitrary multiplier to make it value the HP less
		miniscore+=1
		return miniscore
	end

	def healpulsecode
		return 0 if @opponent.index != @attacker.pbPartner.index || @attacker.effects[PBEffects::HealBlock]>0 || @opponent.effects[PBEffects::HealBlock]>0
		miniscore=1.0
		if @opponent.hp > 0.8*@opponent.totalhp
			if !pbAIfaster?(nil, nil, @attacker, @attacker.pbOpposing1) && !pbAIfaster?(nil, nil, @attacker, @attacker.pbOpposing2)
				miniscore*=0.5
			else
				return 0
			end
		elsif @opponent.hp < 0.7*@opponent.totalhp && @opponent.hp > 0.3*@opponent.totalhp
			miniscore*=3
		elsif @opponent.hp < 0.3*@opponent.totalhp
			miniscore*=1.7
		end
		if @opponent.status==PBStatuses::POISON || @opponent.status==PBStatuses::BURN || @opponent.effects[PBEffects::LeechSeed]>=0 || @opponent.effects[PBEffects::Curse]
			miniscore*=0.8
			miniscore*=0.7 if @opponent.effects[PBEffects::Toxic]>0
		end
		return miniscore
	end

	def deathcode
		miniscore = 1.0
		miniscore*=0.7
		miniscore*=0.3 if @opponent.ability == PBAbilities::DISGUISE || @opponent.effects[PBEffects::Substitute]>0
		miniscore*=0.3 if checkAImoves(PBStuff::PROTECTMOVE)
		return miniscore if @move.function == 0xe1 #Final gambit can go home
		if @attacker.hp==@attacker.totalhp
			miniscore*=0.2
		else
			miniscore*=1-(@attacker.hp.to_f/@attacker.totalhp)
			if @attacker.hp*4<@attacker.totalhp
				miniscore*=1.3
				miniscore*=1.4 if (@mondata.attitemworks && @attacker.item == PBItems::CUSTAPBERRY)
			end
		end
		miniscore*=1.2 if @mondata.roles.include?(PBMonRoles::LEAD)
		return miniscore
	end

	def gambitcode
		miniscore = 0.7
		miniscore*= pbAIfaster?() ? 1.1 : 0.5
		miniscore*= @attacker.hp > @opponent.hp ? 1.1 : 0.5
		miniscore*=0.2 if notOHKO?(@opponent, @attacker, true)
		return miniscore
	end

	def mementcode(score)
		miniscore=1.0
		score = 15 if @initial_scores.length>0 && hasbadmoves(10)
		if @attacker.hp==@attacker.totalhp
			miniscore*=0.2
		else
			miniscore = 1-@attacker.hp*(1.0/@attacker.totalhp)
			miniscore*=1.3 if @attacker.hp*4<@attacker.totalhp
		end
		miniscore*=oppstatdrop([0,0,0,2,2,0,0])
		return miniscore*score
	end

	def grudgecode
		miniscore = 1.0
		damcount = getAIMemory().count {|moveloop| moveloop!=nil && moveloop.basedamage > 0}
		miniscore*=3 if getAIMemory().length >= 4 && damcount==1
		if @attacker.hp==@attacker.totalhp
			miniscore*=0.2
		else
			miniscore*=1-(@attacker.hp/@attacker.totalhp)
			if @attacker.hp*4<@attacker.totalhp
				miniscore*=1.3
				miniscore*=1.4 if (@mondata.attitemworks && @attacker.item == PBItems::CUSTAPBERRY)
			end
		end
		miniscore*= pbAIfaster?(@move) ? 1.3 :0.5
		return miniscore
	end

	def healwishcode
		miniscore=1.0
		count=0
		for mon in @battle.pbPartySingleOwner(@opponent.index)
			next if mon.nil?
			count+=1 if mon.hp!=mon.totalhp
		end
		count-=1 if @attacker.hp!=@attacker.totalhp
		return 0 if count==0
		maxscore = 0
		for mon in @battle.pbPartySingleOwner(@opponent.index)
			next if mon.nil?
			if mon.hp!=mon.totalhp
				miniscore = 1 - mon.hp*(1.0/mon.totalhp)
				miniscore*=2 if mon.status!=0
				maxscore=miniscore if miniscore>maxscore
			end
		end
		miniscore*=maxscore
		if @attacker.hp==@attacker.totalhp
			miniscore*=0.2
		else
			miniscore*=1-(@attacker.hp/@attacker.totalhp)
			if @attacker.hp*4<@attacker.totalhp
				miniscore*=1.3
				miniscore*=1.4 if (@mondata.attitemworks && @attacker.item == PBItems::CUSTAPBERRY)
			end
		end
		miniscore*= pbAIfaster?(@move) ? 1.1 : 0.5
		return miniscore
	end

	def endurecode
		return 0 if @attacker.hp==1
		return 0 if notOHKO?(@attacker, @opponent, true)
		return 0 if (@battle.pbWeather==PBWeather::HAIL && !@attacker.pbHasType?(:ICE)) || (@battle.pbWeather==PBWeather::SANDSTORM && !(@attacker.pbHasType?(:ROCK) || @attacker.pbHasType?(:GROUND) || @attacker.pbHasType?(:STEEL)))
		return 0 if @attacker.status==PBStatuses::POISON || @attacker.status==PBStatuses::BURN || @attacker.effects[PBEffects::LeechSeed]>=0 || @attacker.effects[PBEffects::Curse]
		return 0 if checkAIdamage()<@attacker.hp
		miniscore=1.0
		miniscore*= (pbAIfaster?(nil, nil, @attacker, @opponent.pbPartner)) ? 1.3 : 0.5
		if pbAIfaster?(nil, nil, @attacker, @opponent.pbPartner)
			miniscore*=3 if (@attacker.pbHasMove?(PBMoves::PAINSPLIT) || @attacker.pbHasMove?(PBMoves::FLAIL) || @attacker.pbHasMove?(PBMoves::REVERSAL))
			miniscore*=5 if @attacker.pbHasMove?(PBMoves::ENDEAVOR)
			miniscore*=5 if @opponent.effects[PBEffects::TwoTurnAttack]!=0 
		end
		miniscore*=1.5 if @opponent.status==PBStatuses::POISON || @opponent.status==PBStatuses::BURN || @opponent.effects[PBEffects::LeechSeed]>=0 || @opponent.effects[PBEffects::Curse]
		miniscore/=(@attacker.effects[PBEffects::ProtectRate]*2.0) if PBStuff::RATESHARERS.include?(@attacker.lastMoveUsed)
		return miniscore
	end

	def destinycode
		return 0 if @attacker.effects[PBEffects::DestinyRate]
		miniscore=1.0
		miniscore*=3 if getAIMemory().length>=4 && getAIMemory().all?{|moveloop| moveloop!=nil && moveloop.basedamage>0}
		miniscore*=0.1 if @initial_scores.length>0 && hasgreatmoves()
		miniscore*= (pbAIfaster?(@move)) ? 1.5 : 0.5
		if @attacker.hp==@attacker.totalhp
			miniscore*=0.2
		else
			miniscore*=1-@attacker.hp*(1.0/@attacker.totalhp)
			if @attacker.hp*4<@attacker.totalhp
				miniscore*=1.3
				miniscore*=1.5 if (@mondata.attitemworks && @attacker.item == PBItems::CUSTAPBERRY)
			end
		end
		return miniscore
	end

	def phasecode
		return 0 if @opponent.effects[PBEffects::Ingrain] || @opponent.ability == PBAbilities::SUCTIONCUPS || @opponent.pbNonActivePokemonCount==0
		return 0 if @opponent.effects[PBEffects::PerishSong]>0 || @opponent.effects[PBEffects::Yawn]>0
		miniscore=1.0
		miniscore*=0.8 if pbAIfaster?()
		miniscore*= (1+ 0.1*statchangecounter(@opponent,1,7))
		miniscore*=1.3 if @opponent.status==PBStatuses::SLEEP
		miniscore*=1.3 if @opponent.ability == PBAbilities::SLOWSTART
		miniscore*=1.5 if @opponent.item ==0 && @opponent.ability == PBAbilities::UNBURDEN
		miniscore*=0.7 if @opponent.ability == PBAbilities::INTIMIDATE
		miniscore*=0.5 if @opponent.ability == PBAbilities::REGENERATOR || @opponent.ability == PBAbilities::NATURALCURE
		miniscore*=1.1 if @opponent.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
		miniscore*=1.4 if @opponent.effects[PBEffects::Substitute]>0
		miniscore*=(@opponent.pbOwnSide.effects[PBEffects::StealthRock]) ? 1.3 : 0.8
		miniscore*=(@opponent.pbOwnSide.effects[PBEffects::Spikes]>0) ? (1.2**@opponent.pbOwnSide.effects[PBEffects::Spikes]) : 0.8
		return miniscore
	end

	def pivotcode
		return 0 if @attacker.pbNonActivePokemonCount==1 && $game_switches[:Last_Ace_Switch]
		return @move.basedamage > 0 ? 1 : 0 if @attacker.pbNonActivePokemonCount==0
		miniscore=1.0
		miniscore*=0.7 if @attacker.pbOwnSide.effects[PBEffects::StealthRock]
		miniscore*=0.6 if @attacker.pbOwnSide.effects[PBEffects::StickyWeb]
		miniscore*=0.9**@attacker.pbOwnSide.effects[PBEffects::Spikes] if @attacker.pbOwnSide.effects[PBEffects::Spikes]>0
		miniscore*=0.9**@attacker.pbOwnSide.effects[PBEffects::ToxicSpikes] if @attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
		miniscore*=1.1 if @attacker.ability == PBAbilities::INTIMIDATE
		if @attacker.ability == PBAbilities::REGENERATOR && ((@attacker.hp.to_f)/@attacker.totalhp)<0.75
			miniscore*=1.2
			miniscore*=1.2 if @attacker.ability == PBAbilities::REGENERATOR && ((@attacker.hp.to_f)/@attacker.totalhp)<0.5
		end
		miniscore*=1.5 if @mondata.partyroles.any? {|role| role.include?(PBMonRoles::SWEEPER)} && @move.id == PBMoves::PARTINGSHOT
		miniscore*=1.2 if @mondata.partyroles.any? {|role| role.include?(PBMonRoles::SWEEPER)} && (@move.id == PBMoves::UTURN || @move.id == PBMoves::VOLTSWITCH) && !pbAIfaster?()
		
		movebackup = @move ; attackerbackup = @attacker ; oppbackup = @opponent
		miniscore*=0.2 if getSwitchInScoresParty(pbAIfaster?(@move)).max < 50
		@move = movebackup ; @attacker = attackerbackup ; @opponent = oppbackup

		if @move.id == PBMoves::BATONPASS #Baton Pass
			miniscore*=1+0.3*statchangecounter(@attacker,1,7)
			miniscore*=0 if @attacker.effects[PBEffects::PerishSong]>0
			miniscore*=1.4 if @attacker.effects[PBEffects::Substitute]>0
			miniscore*=0.5 if @attacker.effects[PBEffects::Confusion]>0
			miniscore*=0.5 if @attacker.effects[PBEffects::LeechSeed]>=0
			miniscore*=0.5 if @attacker.effects[PBEffects::Curse]
			miniscore*=0.5 if @attacker.effects[PBEffects::Yawn]>0
			miniscore*=0.5 if @attacker.turncount<1
			miniscore*=1.3 if !@attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.basedamage>0}
			miniscore*=1.2 if @attacker.effects[PBEffects::Ingrain] || @attacker.effects[PBEffects::AquaRing]
			if pbAIfaster?(@move)
				miniscore*=1.8 if checkAIdamage() > @attacker.hp && (getAIMemory().length > 0)
			else
				miniscore*=2 if (checkAIdamage()*2) > @attacker.hp && (getAIMemory().length > 0)
			end
		else		#U-turn / Volt Switch / Parting Shot
			miniscore*= 1-0.15*statchangecounter(@attacker,1,7,-1)
			miniscore*=1-0.25*statchangecounter(@attacker,1,7,1)
			miniscore*=1.1 if @mondata.roles.include?(PBMonRoles::LEAD)
			miniscore*=1.1 if @mondata.roles.include?(PBMonRoles::PIVOT)
			miniscore*=1.2 if pbAIfaster?(@move)
			miniscore*=1.3 if @attacker.effects[PBEffects::Toxic]>0 || @attacker.effects[PBEffects::Attract]>-1 || @attacker.effects[PBEffects::Confusion]>0 || @attacker.effects[PBEffects::Yawn]>0
			miniscore*=1.5 if @attacker.effects[PBEffects::LeechSeed]>-1
			miniscore*=0.5 if @attacker.effects[PBEffects::Substitute]>0
			miniscore*=1.5 if @attacker.effects[PBEffects::PerishSong]>0 || @attacker.effects[PBEffects::Curse]
			if pbAIfaster?(@move)
				@opponent.hp -= pbRoughDamage()
				can_hard_switch = false
				@battle.pbParty(@attacker.index).each_with_index  {|mon, monindex|
					next if mon.nil? || mon.hp <= 0
					next if !@battle.pbIsOwner?(@attacker.index,monindex)

					can_hard_switch = true if shouldHardSwitch?(@attacker, monindex)
				}
				miniscore *= 0.2 if !can_hard_switch && @opponent.hp > 0
			end
		end
		miniscore*=0.5 if hasgreatmoves()
		if hasbadmoves(25)
			miniscore*=2
		elsif hasbadmoves(40)
			miniscore*=1.2
		end
		return miniscore
	end

	def meanlookcode
		miniscore=1.0
		if @opponent.effects[PBEffects::MeanLook]>=0 || @opponent.effects[PBEffects::Ingrain] ||
			(@opponent.pbHasType?(:GHOST) && @move.id == PBMoves::THOUSANDWAVES) ||
			secondaryEffectNegated?() || @opponent.effects[PBEffects::Substitute]>0
			return (@move.basedamage > 0) ? miniscore : 0
		end
		miniscore*=0.1 if checkAImoves(PBStuff::PIVOTMOVE)
		miniscore*=0.1 if @opponent.ability == PBAbilities::RUNAWAY
		miniscore*=1.5 if @attacker.pbHasMove?(PBMoves::PERISHSONG)
		miniscore*=4   if @opponent.effects[PBEffects::PerishSong]>0
		miniscore*=0   if @attacker.ability == PBAbilities::ARENATRAP || @attacker.ability == PBAbilities::SHADOWTAG
		miniscore*=1.3 if @opponent.effects[PBEffects::Attract]>=0
		miniscore*=1.3 if @opponent.effects[PBEffects::LeechSeed]>=0
		miniscore*=1.5 if @opponent.effects[PBEffects::Curse]
		miniscore*=1.1 if @opponent.effects[PBEffects::Confusion]>0
		miniscore*=0.7 if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::PHASEMOVE).include?(moveloop.id)}
		miniscore*=1-0.05*statchangecounter(@opponent,1,7)
		miniscore=1.0 if miniscore < 1.0 && @move.basedamage > 0
		return miniscore
	end

	def knockcode
		return 1 if @opponent.effects[PBEffects::Substitute]>0
		return 1 unless (@opponent.ability != PBAbilities::STICKYHOLD || moldBreakerCheck(@attacker)) && @opponent.item!=0 && !@battle.pbIsUnlosableItem(@opponent,@opponent.item)
		if @opponent.item == PBItems::LEFTOVERS || (@opponent.item == PBItems::BLACKSLUDGE) && @opponent.pbHasType?(:POISON)
			return 1.3
		elsif @opponent.item == PBItems::LIFEORB || @opponent.item == PBItems::CHOICESCARF || @opponent.item == PBItems::CHOICEBAND || @opponent.item == PBItems::CHOICESPECS || @opponent.item == PBItems::ASSAULTVEST
			return 1.2
		end
		return 1
	end

	def covetcode
		return 1 if !((@opponent.ability != PBAbilities::STICKYHOLD || moldBreakerCheck(@attacker)) && @opponent.item!=0 && !@battle.pbIsUnlosableItem(@opponent,@opponent.item) && @attacker.item ==0 && @opponent.effects[PBEffects::Substitute]<=0)
		miniscore = 1.2
		case @opponent.item
			when PBItems::LEFTOVERS, PBItems::LIFEORB, PBItems::LUMBERRY, PBItems::SITRUSBERRY
				miniscore*=1.5
			when PBItems::ASSAULTVEST, PBItems::ROCKYHELMET, PBItems::MAGICALSEED, PBItems::SYNTHETICSEED, PBItems::TELLURICSEED, PBItems::ELEMENTALSEED
				miniscore*=1.3
			when PBItems::FOCUSSASH, PBItems::MUSCLEBAND, PBItems::WISEGLASSES, PBItems::EXPERTBELT, PBItems::WIDELENS
				miniscore*=1.2
			when PBItems::CHOICESCARF
				miniscore*=1.1 if !pbAIfaster?()
			when PBItems::CHOICEBAND
				miniscore*=1.1 if @attacker.attack>@attacker.spatk
			when PBItems::CHOICESPECS
				miniscore*=1.1 if @attacker.spatk>@attacker.attack
			when PBItems::BLACKSLUDGE
				miniscore*= @attacker.pbHasType?(:POISON) ? 1.5 : 0.5
			when PBItems::TOXICORB, PBItems::FLAMEORB, PBItems::LAGGINGTAIL, PBItems::IRONBALL, PBItems::STICKYBARB
				miniscore*=0.5
		end
		return miniscore
	end

	def bestowcode
		return 1 if (@opponent.ability == PBAbilities::STICKYHOLD || !moldBreakerCheck(@attacker))
		return 1 if @attacker.item == 0 || @battle.pbIsUnlosableItem(@attacker,@attacker.item) || (@opponent.item != 0 && @move.id != PBMoves::TRICK)
		return 1 if opponent.effects[PBEffects::Substitute] > 0
		miniscore = 1.0
		case @attacker.item
			when PBItems::LEFTOVERS, PBItems::LIFEORB, PBItems::LUMBERRY, PBItems::SITRUSBERRY
				miniscore*=0.5
			when PBItems::FOCUSSASH, PBItems::MUSCLEBAND, PBItems::WISEGLASSES, PBItems::EXPERTBELT, PBItems::WIDELENS
				miniscore*=0.8
			when PBItems::ASSAULTVEST, PBItems::ROCKYHELMET, PBItems::MAGICALSEED, PBItems::SYNTHETICSEED, PBItems::TELLURICSEED, PBItems::ELEMENTALSEED
				miniscore*=0.7
			when PBItems::CHOICESPECS
				miniscore*=1.7 if @opponent.attack>@opponent.spatk
				miniscore*=0.8 if @attacker.attack<@attacker.spatk
			when PBItems::CHOICESCARF
				miniscore*= pbAIfaster?() ? 0.9 : 1.5
			when PBItems::CHOICEBAND
				miniscore*=1.7 if @opponent.attack<@opponent.spatk
				miniscore*=0.8 if @attacker.attack>@attacker.spatk
			when PBItems::BLACKSLUDGE
				miniscore*= @attacker.pbHasType?(:POISON) ? 0.5 : 1.5
				miniscore*=1.3 if !@opponent.pbHasType?(:POISON)
			when PBItems::TOXICORB, PBItems::FLAMEORB, PBItems::LAGGINGTAIL, PBItems::IRONBALL, PBItems::STICKYBARB
				miniscore*=1.5
		end
		if [PBItems::CHOICESCARF,PBItems::CHOICEBAND,PBItems::CHOICESPECS].include?(@attacker.item) #choice locking
			miniscore*=3 if @opponent.lastMoveUsed != -1 && pbAIfaster?(@move) && $cache.pkmn_move[@opponent.lastMoveUsed][PBMoveData::CATEGORY] == 2
			miniscore*=1.5 if hasbadmoves(40)
			miniscore*=1.5 if @battle.turncount == 1
			maxdam = checkAIdamage()
			miniscore*=0.3 if maxdam > 0.5 * @attacker.hp
			miniscore*=1.3 if maxdam < 0.33 * @attacker.hp
		end
		return miniscore
	end

	def recoilcode(recoilamount)
		return @move.basedamage > 0 ? 1 : 0 if @attacker.ability == PBAbilities::ROCKHEAD || @attacker.ability == PBAbilities::MAGICGUARD
		return @move.basedamage > 0 ? 1 : 0 if @move.id == PBMoves::WILDCHARGE && @battle.FE == PBFields::ELECTRICT
		miniscore=0.9
		miniscore*=0.7 if notOHKO?(@attacker, @opponent, true)
		miniscore*=0.8 if @attacker.hp > 0.1 * @attacker.totalhp && @attacker.hp < 0.4 * @attacker.totalhp
		miniscore*=0.4 if @initial_scores[@score_index] * recoilamount > @attacker.hp && (@opponent.status == PBStatuses::SLEEP || @opponent.status == PBStatuses::FROZEN)
		return miniscore
	end

	def weathercode
		if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE) || @battle.pbCheckGlobalAbility(:DELTASTREAM) ||
			@battle.pbCheckGlobalAbility(:DESOLATELAND) || @battle.pbCheckGlobalAbility(:PRIMORDIALSEA) || @battle.pbWeather==PBWeather::SUNNYDAY
			return @move.basedamage > 0 ? 1 : 0
		end
		miniscore=1.0
		miniscore*=1.3 if notOHKO?(@attacker, @opponent, true)
		miniscore*=1.2 if @mondata.roles.include?(PBMonRoles::LEAD)
		miniscore*=1.4 if @attacker.pbHasMove?(PBMoves::WEATHERBALL) 
		miniscore*=1.5 if @attacker.ability == PBAbilities::FORECAST
		return miniscore
	end

	def suncode
		return 0 if @battle.pbWeather==PBWeather::SUNNYDAY
		miniscore=1.0
		miniscore*=0.2 if @attacker.ability == PBAbilities::FORECAST && (@opponent.pbHasType?(PBTypes::GROUND) || @opponent.pbHasType?(PBTypes::ROCK))
		miniscore*=1.3 if (@mondata.attitemworks && @attacker.item == PBItems::HEATROCK)
		miniscore*=1.5 if @battle.pbWeather!=0 && @battle.pbWeather!=PBWeather::SUNNYDAY
		miniscore*=1.5 if @attacker.pbHasMove?(PBMoves::MOONLIGHT) || @attacker.pbHasMove?(PBMoves::SYNTHESIS) || @attacker.pbHasMove?(PBMoves::MORNINGSUN) || @attacker.pbHasMove?(PBMoves::GROWTH) || @attacker.pbHasMove?(PBMoves::SOLARBEAM) || @attacker.pbHasMove?(PBMoves::SOLARBLADE)
		miniscore*=0.7 if checkAImoves([PBMoves::SYNTHESIS, PBMoves::MOONLIGHT, PBMoves::MORNINGSUN])
		miniscore*=1.5 if @attacker.pbHasType?(:FIRE)
		if @attacker.ability == PBAbilities::CHLOROPHYLL || @attacker.ability == PBAbilities::FLOWERGIFT
			miniscore*=2
			miniscore*=2 if notOHKO?(@attacker, @opponent, true)
			miniscore*=3 if seedProtection?(@attacker)
		end
		miniscore*=1.3 if @attacker.ability == PBAbilities::SOLARPOWER || @attacker.ability == PBAbilities::LEAFGUARD
		miniscore*=0.5 if pbPartyHasType?(PBTypes::WATER)
		miniscore*=0.7 if @attacker.pbHasMove?(PBMoves::THUNDER) || @attacker.pbHasMove?(PBMoves::HURRICANE)
		miniscore*=0.5 if @attacker.ability == PBAbilities::DRYSKIN
		miniscore*=1.5 if @attacker.ability == PBAbilities::HARVEST
		return miniscore
	end

	def raincode
		return 0 if @battle.pbWeather==PBWeather::RAINDANCE
		miniscore=1.0
		miniscore*=0.2 if @attacker.ability == PBAbilities::FORECAST && (@opponent.pbHasType?(PBTypes::GRASS) || @opponent.pbHasType?(PBTypes::ELECTRIC))
		miniscore*=1.3 if (@mondata.attitemworks && @attacker.item == PBItems::DAMPROCK)
		miniscore*=1.3 if @battle.pbWeather!=0 && @battle.pbWeather!=PBWeather::RAINDANCE
		miniscore*=1.5 if @attacker.pbHasMove?(PBMoves::THUNDER) || @attacker.pbHasMove?(PBMoves::HURRICANE)
		miniscore*=1.5 if @attacker.pbHasType?(:WATER)
		if @attacker.ability == PBAbilities::SWIFTSWIM
			miniscore*=2
			miniscore*=2 if notOHKO?(@attacker, @opponent, true)
			miniscore*=3 if seedProtection?(@attacker)
		end
		miniscore*=1.5 if @attacker.ability == PBAbilities::DRYSKIN || @battle.pbWeather==PBWeather::RAINDANCE
		miniscore*=0.5 if pbPartyHasType?(PBTypes::FIRE)
		miniscore*=0.5 if @attacker.pbHasMove?(PBMoves::MOONLIGHT) || @attacker.pbHasMove?(PBMoves::SYNTHESIS) || @attacker.pbHasMove?(PBMoves::MORNINGSUN) || @attacker.pbHasMove?(PBMoves::GROWTH) || @attacker.pbHasMove?(PBMoves::SOLARBEAM) || @attacker.pbHasMove?(PBMoves::SOLARBLADE)
		miniscore*=1.5 if @attacker.ability == PBAbilities::HYDRATION
		return miniscore
	end

	def sandcode
		return 0 if @battle.pbWeather==PBWeather::SANDSTORM
		miniscore = 1.0
		miniscore*=1.3 if (@mondata.attitemworks && @attacker.item == PBItems::SMOOTHROCK)
		miniscore*=2 if @battle.pbWeather!=0 && @battle.pbWeather!=PBWeather::SANDSTORM
		miniscore*= (@attacker.pbHasType?(:ROCK) || @attacker.pbHasType?(:GROUND) || @attacker.pbHasType?(:STEEL)) ? 1.3 : 0.7
		miniscore*=1.5 if @attacker.pbHasType?(:ROCK)
		if @attacker.ability == PBAbilities::SANDRUSH
			miniscore*=2
			miniscore*=2 if notOHKO?(@attacker, @opponent, true)
			miniscore*=3 if seedProtection?(@attacker)
		end
		miniscore*=1.3 if @attacker.ability == PBAbilities::SANDVEIL
		miniscore*=0.5 if @attacker.pbHasMove?(PBMoves::MOONLIGHT) || @attacker.pbHasMove?(PBMoves::SYNTHESIS) || @attacker.pbHasMove?(PBMoves::MORNINGSUN) || @attacker.pbHasMove?(PBMoves::GROWTH) || @attacker.pbHasMove?(PBMoves::SOLARBEAM) || @attacker.pbHasMove?(PBMoves::SOLARBLADE)
		miniscore*=1.5 if @attacker.pbHasMove?(PBMoves::SHOREUP)
		miniscore*=1.5 if @attacker.ability == PBAbilities::SANDFORCE
		return miniscore
	end

	def hailcode
		return 0 if @battle.pbWeather==PBWeather::HAIL
		miniscore=1.0
		miniscore*=0.2 if @attacker.ability == PBAbilities::FORECAST && [:ROCK,:FIRE,:STEEL,:FIGHTING].any? {|type| @opponent.pbHasType?(type) }
		miniscore*=1.3 if (@mondata.attitemworks && @attacker.item == PBItems::ICYROCK)
		miniscore*=1.3 if @battle.pbWeather!=0 && @battle.pbWeather!=PBWeather::HAIL
		miniscore*= (@attacker.pbHasType?(:ICE)) ? 5 : 0.7
		if @attacker.ability == PBAbilities::SLUSHRUSH
			miniscore*=2
			miniscore*=2 if notOHKO?(@attacker, @opponent, true)
			miniscore*=3 if seedProtection?(@attacker)
		end
		miniscore*=1.3 if @attacker.ability == PBAbilities::SNOWCLOAK || @attacker.ability == PBAbilities::ICEBODY
		miniscore*=0.5 if @attacker.pbHasMove?(PBMoves::MOONLIGHT) || @attacker.pbHasMove?(PBMoves::SYNTHESIS) || @attacker.pbHasMove?(PBMoves::MORNINGSUN) || @attacker.pbHasMove?(PBMoves::GROWTH) || @attacker.pbHasMove?(PBMoves::SOLARBEAM) || @attacker.pbHasMove?(PBMoves::SOLARBLADE)
		miniscore*=2 if @attacker.pbHasMove?(PBMoves::AURORAVEIL)
		miniscore*=1.3 if @attacker.pbHasMove?(PBMoves::BLIZZARD)
		return miniscore
	end

	def subcode
		return 0 if @attacker.hp*4<=@attacker.totalhp
		return 0 if @attacker.effects[PBEffects::Substitute]>0 && pbAIfaster?(@move) || @opponent.effects[PBEffects::LeechSeed]<0
		miniscore = 1.0
		miniscore*= (@attacker.hp==@attacker.totalhp) ? 1.1 : (@attacker.hp*(1.0/@attacker.totalhp))
		miniscore*=1.2 if @opponent.effects[PBEffects::LeechSeed]>=0
		miniscore*=1.2 if hpGainPerTurn>1
		miniscore*=1.2 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.isHealingMove?}
		miniscore*=1.2 if checkAImoves([PBMoves::SPORE, PBMoves::SLEEPPOWDER])
		miniscore*=1.5 if @attacker.pbHasMove?(PBMoves::FOCUSPUNCH)
		miniscore*=1.5 if @opponent.status==PBStatuses::SLEEP
		miniscore*=0.3 if @opponent.ability == PBAbilities::INFILTRATOR
		miniscore*=0.3 if checkAImoves([PBMoves::UPROAR, PBMoves::HYPERVOICE, PBMoves::ECHOEDVOICE, PBMoves::SNARL, PBMoves::BUGBUZZ, PBMoves::BOOMBURST, PBMoves::SPARKLINGARIA])
		miniscore*=2   if checkAIdamage()*4 < @attacker.totalhp && (getAIMemory().length > 0)
		miniscore*=1.3 if @opponent.effects[PBEffects::Confusion]>0
		miniscore*=1.3 if @opponent.status==PBStatuses::PARALYSIS
		miniscore*=1.3 if @opponent.effects[PBEffects::Attract]>=0
		miniscore*=1.2 if @attacker.pbHasMove?(PBMoves::BATONPASS)
		miniscore*=1.1 if @attacker.ability == PBAbilities::SPEEDBOOST
		miniscore*=0.5 if @battle.doublebattle
		return miniscore
	end

	def futurecode
		return 0 if @opponent.effects[PBEffects::FutureSight]>0
		miniscore=0.6
		miniscore*=0.7 if @battle.doublebattle
		miniscore*=0.7 if @attacker.pbNonActivePokemonCount==0
		miniscore*=1.2 if @attacker.effects[PBEffects::Substitute]>0
		miniscore*=1.2 if @attacker.moves.any? {|moveloop| moveloop!=nil && [PBMoves::PROTECT,PBMoves::DETECT,PBMoves::BANEFULBUNKER,PBMoves::SPIKYSHIELD].include?(moveloop.id) }
		miniscore*=1.1 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		miniscore*=1.2 if @attacker.ability == PBAbilities::MOODY || @attacker.pbHasMove?(PBMoves::QUIVERDANCE) || @attacker.pbHasMove?(PBMoves::NASTYPLOT) || @attacker.pbHasMove?(PBMoves::TAILGLOW)
		return miniscore
	end

	def focuscode
		return 0 if @mondata.skill >= BESTSKILL && @battle.FE == PBFields::ELECTRICT
		miniscore=1.0
		soundcheck=getAIMemory().any? {|moveloop| moveloop!=nil && moveloop.isSoundBased? && moveloop.basedamage>0}
		multicheck=getAIMemory().any? {|moveloop| moveloop!=nil && moveloop.pbNumHits(@opponent)>1}
		if @attacker.effects[PBEffects::Substitute]>0
			if multicheck || soundcheck || @opponent.ability == PBAbilities::INFILTRATOR
				miniscore*=0.9
			else
				miniscore*=1.3
			end
		else
			miniscore *= 0.8
		end
		miniscore*=1.2 if @opponent.status==PBStatuses::SLEEP && @opponent.ability != PBAbilities::EARLYBIRD && @opponent.ability != PBAbilities::SHEDSKIN
		miniscore*=0.5 if @battle.doublebattle
		miniscore*=1.5 if @opponent.effects[PBEffects::HyperBeam]>0
		miniscore*=0.3 if miniscore<=1.0
		return miniscore
	end

	def suckercode
		miniscore=1.0
		return miniscore*1.3 if getAIMemory().length>=4 && getAIMemory().all? {|moveloop| moveloop!=nil && moveloop.basedamage>0}
		miniscore*=0.6 if checkAIhealing()
		miniscore*=0.8 if checkAImoves(PBStuff::SETUPMOVE)
		if @attacker.lastMoveUsed==PBMoves::SUCKERPUNCH # Sucker Punch last turn
			miniscore*=0.3 if rand(3) != 1
			miniscore*=0.5 if checkAImoves(PBStuff::SETUPMOVE)
		end
		if pbAIfaster?()
			miniscore*=0.8
			miniscore*=0.6 if @initial_scores.length>0 && @initial_scores.max!=@initial_scores[@score_index]
		else
			miniscore*= checkAIpriority() ? 0.5 : 1.3
		end
		return miniscore
	end

	def followcode
		return 0 if !@battle.doublebattle || @attacker.pbPartner.hp==0
		miniscore=1.0
		miniscore*=1.2 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		miniscore*=1.3 if @attacker.pbPartner.ability == PBAbilities::MOODY
		miniscore*= (@attacker.pbPartner.turncount<1) ? 1.2 : 0.8
		miniscore*= 1.3 if @attacker.pbPartner.moves.any? {|moveloop| moveloop!=nil && (PBStuff::SETUPMOVE).include?(moveloop.id)}
		bestmove1,maxdam1 = checkAIMovePlusDamage(@attacker.pbOpposing1,@attacker.pbPartner)
		bestmove2,maxdam2 = checkAIMovePlusDamage(@attacker.pbOpposing2,@attacker.pbPartner)
		miniscore*=1.5 if notOHKO?(@attacker, @opponent, true)
		if maxdam1 >= @attacker.pbPartner.hp && pbRoughDamage(bestmove1,@attacker.pbOpposing1,@attacker) < 0.7*@attacker.hp || 
		   maxdam2 >= @attacker.pbPartner.hp && pbRoughDamage(bestmove2,@attacker.pbOpposing2,@attacker) < 0.7*@attacker.hp
		   miniscore*= 1.3
		end
		if @attacker.hp==@attacker.totalhp
			miniscore*=1.2
		else
			miniscore*=0.8
			miniscore*=0.5 if @attacker.hp*2 < @attacker.totalhp
		end
		miniscore*=1.2 if !pbAIfaster?() || !pbAIfaster?(nil,nil,@attacker,@opponent.pbPartner)
		return miniscore
	end

	def gravicode
		return 0 if @battle.state.effects[PBEffects::Gravity]>0
		return 0 if @attacker.moves.any? {|moveloop| moveloop!=nil && [PBMoves::SKYDROP,PBMoves::BOUNCE,PBMoves::FLY,PBMoves::JUMPKICK,PBMoves::FLYINGPRESS,PBMoves::HIJUMPKICK].include?(moveloop.id)}
		miniscore=1.0
		miniscore*=2 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.accuracy<=70}
		miniscore*=3 if @attacker.pbHasMove?(PBMoves::ZAPCANNON) || @attacker.pbHasMove?(PBMoves::INFERNO)
		miniscore*=2 if [PBMoves::SKYDROP,PBMoves::BOUNCE,PBMoves::FLY,PBMoves::JUMPKICK,PBMoves::FLYINGPRESS,PBMoves::HIJUMPKICK].include?(checkAIbestMove().id)
		miniscore*=2 if @attacker.pbHasType?(:GROUND) && (@opponent.pbHasType?(:FLYING) || @opponent.ability == PBAbilities::LEVITATE || (@mondata.oppitemworks && @opponent.item == PBItems::AIRBALLOON))
		return miniscore
	end

	def magnocode
		return 0 if @attacker.effects[PBEffects::MagnetRise]>0 || @attacker.effects[PBEffects::Ingrain] || @attacker.effects[PBEffects::SmackDown]
		miniscore=1.0
		miniscore*=3 if checkAIbestMove().pbType(@opponent)==PBTypes::GROUND# Highest expected dam from a ground move
		miniscore*=3 if @opponent.pbHasType?(:GROUND)
		return miniscore
	end

	def telecode
		return 0 if @opponent.effects[PBEffects::Telekinesis]>0 || @opponent.effects[PBEffects::Ingrain] || @opponent.effects[PBEffects::SmackDown] || @battle.state.effects[PBEffects::Gravity]>0
		return 0 if @opponent.species==PBSpecies::DIGLETT || @opponent.species==PBSpecies::DUGTRIO || @opponent.species==PBSpecies::SANDYGAST || @opponent.species==PBSpecies::PALOSSAND
		return 0 if (@opponent.species==PBSpecies::GENGAR && @opponent.form==1) || @opponent.item == PBItems::IRONBALL
		score = @initial_scores[@score_index]
		score+=10 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.accuracy<=70}
		score*=2 if @attacker.pbHasMove?(PBMoves::ZAPCANNON) || @attacker.pbHasMove?(PBMoves::INFERNO)
		score*=0.5 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(@attacker)==PBTypes::GROUND && moveloop.basedamage>0}
		miniscore = oppstatdrop([0,2,0,0,2,0,0]) if @battle.FE == PBFields::PSYCHICT
		score *= miniscore if miniscore && miniscore > 0
		return score
	end

	def afteryoucode
		return 1
	end

	def trcode
		return 0 if pbAIfaster?() && !(@mondata.attitemworks && @attacker.item == PBItems::IRONBALL)
		return 0 if opponent.hp > 0 && opponent.pokemon.piece == :KING
		miniscore=1.0
		miniscore*=1.3 if @mondata.partyroles.any? {|role| role.include?(PBMonRoles::SWEEPER) }
		miniscore*=1.3 if @mondata.roles.include?(PBMonRoles::TANK) || @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		miniscore*=1.5 if @mondata.roles.include?(PBMonRoles::LEAD)
		miniscore*=1.3 if @battle.doublebattle
		miniscore*=1.5 if notOHKO?(@attacker, @opponent, true)
		if @opponent.pbPartner.hp > 0
			miniscore*=0.3 if @attacker.pbSpeed<pbRoughStat(@opponent,PBStats::SPEED) && @attacker.pbSpeed>pbRoughStat(@opponent.pbPartner,PBStats::SPEED)
			miniscore*=0.3 if @attacker.pbSpeed>pbRoughStat(@opponent,PBStats::SPEED) && @attacker.pbSpeed<pbRoughStat(@opponent.pbPartner,PBStats::SPEED)
		end
		if @battle.trickroom <= 0
			miniscore*=2
			miniscore*=6 if @initial_scores.length>0 && hasgreatmoves() #experimental -- cancels out drop if killing moves
		else
			miniscore*=1.3
		end
    	return miniscore
	end

	def dinglenugget
		return 0 if checkAIdamage()>=@attacker.hp || @attacker.pbNonActivePokemonCount==0
		miniscore=1.3
		miniscore*=2 if @mondata.partyroles.any? {|role| role.include?(PBMonRoles::SWEEPER) }
		miniscore*=2 if @attacker.pbNonActivePokemonCount<3
		miniscore*=0.5 if @attacker.pbOwnSide.effects[PBEffects::StealthRock] || @attacker.pbOwnSide.effects[PBEffects::Spikes]>0
		return miniscore
	end

	def wondercode
		return 0 if @battle.state.effects[PBEffects::WonderRoom]!=0
		miniscore=1.0
		miniscore*=1.3 if (@mondata.attitemworks && @attacker.item == PBItems::AMPLIFIELDROCK) || @battle.FE == PBFields::NEWW || @battle.FE == PBFields::PSYCHICT
		if pbRoughStat(@opponent,PBStats::ATTACK)>pbRoughStat(@opponent,PBStats::SPATK)
			miniscore*= (@attacker.defense>@attacker.spdef) ? 0.5 : 2
		else
			miniscore*= (@attacker.defense>@attacker.spdef) ? 2 : 0.5
		end
		if @attacker.attack>@attacker.spatk
			miniscore*= (pbRoughStat(@opponent,PBStats::DEFENSE)>pbRoughStat(@opponent,PBStats::SPDEF)) ? 2 : 0.5
		else
			miniscore*= (pbRoughStat(@opponent,PBStats::DEFENSE)>pbRoughStat(@opponent,PBStats::SPDEF)) ? 0.5 : 2
		end
		return miniscore
	end

	def lastcode
		return 0 unless @attacker.moves.all? {|moveloop| moveloop!=nil && (moveloop.function == 0x125 || moveloop.id == 0 || @attacker.movesUsed.include?(moveloop.id)) }
		return 1
	end

	def powdercode
		return 0 if @opponent.pbHasType?(:GRASS) || @opponent.ability == PBAbilities::OVERCOAT || (@mondata.oppitemworks && @opponent.item == PBItems::SAFETYGOGGLES)
		return 0 if getAIMemory().length >= 4 && !getAIMemory().any? {|moveloop| moveloop!=nil && moveloop.pbType(@opponent)==PBTypes::FIRE}
		miniscore=1.0
		miniscore*=1.2 if !pbAIfaster?()
		if checkAIbestMove().pbType(@opponent) == PBTypes::FIRE
			miniscore*=3
		else
			miniscore*= @opponent.pbHasType?(:FIRE) ? 2 : 0.2
		end
		effcheck = PBTypes.getCombinedEffectiveness((PBTypes::FIRE),@attacker.type1,@attacker.type2)
		miniscore*=2 if effcheck>4
		miniscore*=2 if effcheck>8
		miniscore*=0.6 if @attacker.lastMoveUsed==PBMoves::POWDER
		miniscore*=0.5 if @opponent.ability == PBAbilities::MAGICGUARD
		return miniscore
	end

	def burnupcode
		return 0 if !@attacker.pbHasType?(:FIRE)
		miniscore= (1-@opponent.pbNonActivePokemonCount*0.05)
		if @initial_scores[@score_index]<100
			miniscore*=0.9
			miniscore*=0.5 if getAIMemory().any? {|moveloop| moveloop!=nil && moveloop.isHealingMove?}
		end
		miniscore*=0.5 if @initial_scores.length>0 && hasgreatmoves()
		miniscore*=0.7 if @attacker.pbNonActivePokemonCount==0 && @opponent.pbNonActivePokemonCount!=0
		effcheck = PBTypes.getCombinedEffectiveness(@opponent.type1,(PBTypes::FIRE),(PBTypes::FIRE))
		miniscore*=1.5 if effcheck > 4
		miniscore*=0.5 if effcheck < 4
    	effcheck = PBTypes.getCombinedEffectiveness(@opponent.type2,(PBTypes::FIRE),(PBTypes::FIRE))
		miniscore*=1.5 if effcheck > 4
		miniscore*=0.5 if effcheck < 4
		effcheck = PBTypes.getCombinedEffectiveness(checkAIbestMove().pbType(@opponent),(PBTypes::FIRE),(PBTypes::FIRE))
		miniscore*=1.5 if effcheck > 4
		miniscore*=0.5 if effcheck < 4
		return miniscore
	end

	def beakcode
		miniscore = burncode
		miniscore*=0.7 if pbAIfaster?()
		if getAIMemory().any?{|moveloop| moveloop!=nil && moveloop.isContactMove?}
			miniscore*=1.5
		elsif @opponent.attack>@opponent.spatk
			miniscore*=1.3
		else
			miniscore*=0.3
		end
		return miniscore
	end

	def moldbreakeronalaser
		return 1 if moldBreakerCheck(@attacker)
		damcount = @attacker.moves.count {|moveloop| moveloop!=nil && moveloop.basedamage>0}
		miniscore = 1.0
		case @opponent.ability
			when PBAbilities::SANDVEIL
				miniscore*=1.1 if @battle.pbWeather!=PBWeather::SANDSTORM
			when PBAbilities::VOLTABSORB, PBAbilities::LIGHTNINGROD
				miniscore*=3 if @move.pbType(@attacker)==PBTypes::ELECTRIC && damcount==1
				miniscore*=2 if @move.pbType(@attacker)==PBTypes::ELECTRIC && PBTypes.getCombinedEffectiveness((PBTypes::ELECTRIC),@opponent.type1,@opponent.type2)>4
			when PBAbilities::WATERABSORB, PBAbilities::STORMDRAIN, PBAbilities::DRYSKIN
				miniscore*=3 if @move.pbType(@attacker)==PBTypes::WATER && damcount==1
				miniscore*=2 if @move.pbType(@attacker)==PBTypes::WATER && PBTypes.getCombinedEffectiveness((PBTypes::WATER),@opponent.type1,@opponent.type2)>4
				miniscore*=0.5 if @opponent.ability == PBAbilities::DRYSKIN && @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(@attacker)==PBTypes::FIRE}
			when PBAbilities::FLASHFIRE
				miniscore*=3 if @move.pbType(@attacker)==PBTypes::FIRE && damcount==1
				miniscore*=2 if @move.pbType(@attacker)==PBTypes::FIRE && PBTypes.getCombinedEffectiveness((PBTypes::FIRE),@opponent.type1,@opponent.type2)>4
			when PBAbilities::LEVITATE
				miniscore*=3 if @move.pbType(@attacker)==PBTypes::GROUND && damcount==1
				miniscore*=2 if @move.pbType(@attacker)==PBTypes::GROUND && PBTypes.getCombinedEffectiveness((PBTypes::GROUND),@opponent.type1,@opponent.type2)>4
			when PBAbilities::WONDERGUARD
				miniscore*=5
			when PBAbilities::SOUNDPROOF
				miniscore*=3 if @move.isSoundBased?
			when PBAbilities::THICKFAT
				miniscore*=1.5 if @move.pbType(@attacker)==PBTypes::FIRE || move.pbType(@attacker)==PBTypes::ICE
			when PBAbilities::MOLDBREAKER, PBAbilities::TURBOBLAZE, PBAbilities::TERAVOLT
				miniscore*=1.1
			when PBAbilities::UNAWARE
				miniscore*=1.7
			when PBAbilities::MULTISCALE
				miniscore*=1.5 if @attacker.hp==@attacker.totalhp
			when PBAbilities::SAPSIPPER
				miniscore*=3 if @move.pbType(@attacker)==PBTypes::GRASS && damcount==1
				miniscore*=2 if @move.pbType(@attacker)==PBTypes::GRASS && PBTypes.getCombinedEffectiveness((PBTypes::GRASS),@opponent.type1,@opponent.type2)>4
			when PBAbilities::SNOWCLOAK
				miniscore*=1.1 if @battle.pbWeather!=PBWeather::HAIL
			when PBAbilities::FURCOAT
				miniscore*=1.5 if @attacker.attack>@attacker.spatk
			when PBAbilities::FLUFFY
				miniscore*=1.5
				miniscore*=0.5 if @move.pbType(@attacker)==PBTypes::FIRE
			when PBAbilities::WATERBUBBLE
				miniscore*=1.5
				miniscore*=1.3 if @move.pbType(@attacker)==PBTypes::FIRE
		end
		return miniscore
	end

	def pussydeathcode(initialscore)
		return 0 if @attacker.ability != PBAbilities::MAGICGUARD && @attacker.hp<@attacker.totalhp*0.5 || (@attacker.hp<@attacker.totalhp*0.75 && !pbAIfaster?()) || @battle.pbCheckGlobalAbility(:DAMP)
		miniscore=1.0
		if @attacker.ability != PBAbilities::MAGICGUARD
			miniscore*=0.7
			miniscore*=0.7 if initialscore < 100
			miniscore*=0.5 if !pbAIfaster?()
			miniscore*=1.3 if checkAIdamage() < @attacker.totalhp*0.2
			miniscore*=1.2 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.isHealingMove?}
			miniscore*=1.3 if @initial_scores.length>0 && hasbadmoves(25)
			miniscore*=0.5 if checkAImoves(PBStuff::PROTECTMOVE)
			miniscore*=(1-0.1*@opponent.stages[PBStats::EVASION])
			miniscore*=(1+0.1*@opponent.stages[PBStats::ACCURACY])
			miniscore*=0.7 if @mondata.oppitemworks && (@opponent.item == PBItems::LAXINCENSE || @opponent.item == PBItems::BRIGHTPOWDER)
			miniscore*=0.7 if accuracyWeatherAbilityActive?(@opponent)
		else
			miniscore*=1.1
		end
		return miniscore
	end

	def chopcode
		return 1 if secondaryEffectNegated?()
		miniscore=1.0
		if checkAIbestMove().isSoundBased?
			miniscore*=1.5
		elsif getAIMemory().any? {|moveloop| moveloop!=nil && moveloop.isSoundBased?}
			miniscore*=1.3
		end
		return miniscore
	end

	def shelltrapcode
		miniscore=1.0
		miniscore*=0.5 if pbAIfaster?()
		bestmove, maxdam = checkAIMovePlusDamage()
		if notOHKO?(@attacker, @opponent, true)
			miniscore*=1.2
		else
			miniscore*=0.8
			miniscore*=0.8 if maxdam>@attacker.hp
		end
		miniscore*=0.7 if @attacker.lastMoveUsed==PBMoves::SHELLTRAP
		miniscore*=0.6 if checkAImoves(PBStuff::SETUPMOVE)
		miniscore*=@attacker.hp*(1.0/@attacker.totalhp)
		miniscore*=0.3 if @opponent.spatk > @opponent.attack
		miniscore*=0.05 if bestmove.pbIsSpecial?()
		return miniscore
	end

	def almostuselessmovecode
		return 0 if @opponent.index!=@attacker.pbPartner.index || @opponent.status==0
		miniscore=1.5
		if @opponent.hp>@opponent.totalhp*0.8
			miniscore*=0.8
		elsif @opponent.hp>@opponent.totalhp*0.3
			miniscore*=2
		end
		miniscore*=1.3 if @opponent.effects[PBEffects::Toxic]>3
		miniscore*=1.3 if checkAImoves([PBMoves::HEX])
		return miniscore
	end

	def psychicterraincode
		return 0 if @battle.FE == PBFields::UNDERWATER || @battle.FE == PBFields::NEWW || @battle.FE == PBFields::PSYCHICT
		miniscore = getFieldDisruptScore(@attacker,@opponent)
		miniscore*=1.5 if @attacker.ability == PBAbilities::TELEPATHY
		miniscore*=1.5 if @attacker.pbHasType?(:PSYCHIC)
		miniscore*=2 if pbPartyHasType?(PBTypes::PSYCHIC)
		miniscore*=0.5 if @opponent.pbHasType?(:PSYCHIC)
		miniscore*=0.7  if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbIsPriorityMoveAI(@attacker)} && @attacker.isAirborne?
		miniscore*=1.3 if checkAIpriority() && !@opponent.isAirborne?
		miniscore*=2  if (@mondata.attitemworks && @attacker.item == PBItems::AMPLIFIELDROCK)
		return miniscore
	end

	def instructcode # function is only evaluated for the partner, never the opponent
		miniscore=3.0
		if @opponent.hp < 0.5*@opponent.totalhp
			miniscore*=0.5
		elsif @opponent.hp==@opponent.totalhp
			miniscore*=1.2
		end
		miniscore*=1.2 if @initial_scores.length>0 && hasbadmoves(20)
		lastmove = @attacker.pbPartner.lastMoveUsed
		lastmove = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(lastmove),@attacker.pbPartner)
		lastmovetarget = @attacker.pbPartner.lastMoveChoice[3]
		lastmovetarget = firstOpponent() if lastmovetarget == -1
		movescore = pbRoughDamage(lastmove, @attacker.pbPartner, @battle.battlers[lastmovetarget])
		if movescore == 0
			miniscore*=0
		elsif movescore > @battle.battlers[lastmovetarget].hp
			miniscore*=1.5
		end

		miniscore*=1.4 if !pbAIfaster?(nil, nil, @attacker.pbPartner, @attacker.pbOpposing1) && !pbAIfaster?(nil, nil, @attacker.pbPartner, @attacker.pbOpposing2)
		miniscore*= (1 + ([@opponent.attack,@opponent.spatk].max - [@attacker.attack,@attacker.spatk].max)/100.0)
		return miniscore
	end

	def antistatcode(stats,beginscore)
		miniscore=1.0
		miniscore*=(1-0.05*(@opponent.pbNonActivePokemonCount-2)) if @opponent.pbNonActivePokemonCount > 0
		miniscore*=1.2 if !@battle.doublebattle && @mondata.partyroles.any? {|role| role.include?(PBMonRoles::PIVOT) }
		miniscore*=0.7 if @initial_scores.length>0 && hasgreatmoves()
		miniscore*=0.9 if beginscore < 100
		stats.unshift(0)
		for i in 0...stats.length
			next if stats[i].nil? || stats[i]==0
			case i
				when PBStats::ATTACK
					miniscore*=0.5 if beginscore < 100 && checkAIhealing()
					miniscore*=0.8 if @opponent.pbNonActivePokemonCount > 0 && @attacker.pbNonActivePokemonCount==0
				when PBStats::DEFENSE
					miniscore/=0.9 if beginscore < 100 && !pbAIfaster?() || checkAIpriority()
					miniscore/=0.9 if beginscore < 100 && @opponent.attack < @opponent.spatk
					miniscore*=0.8 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL)
				when PBStats::SPEED
					miniscore*=1.1 if @mondata.roles.include?(PBMonRoles::TANK)
					miniscore*=0.8 if @attacker.pbSpeed>pbRoughStat(@opponent,PBStats::SPEED)
				when PBStats::SPATK
					miniscore*=0.5 if beginscore < 100 && checkAIhealing()
					miniscore*=0.8 if @opponent.pbNonActivePokemonCount > 0 && @attacker.pbNonActivePokemonCount==0
				when PBStats::SPDEF
					miniscore/=0.9 if !pbAIfaster?() || checkAIpriority()
					miniscore/=0.9 if beginscore < 100 && @opponent.attack > @opponent.spatk
					miniscore*=0.9 if @mondata.roles.include?(PBMonRoles::SPECIALWALL)
			end
		end
		return miniscore
	end

	def smackcode
		return 1 if @opponent.effects[PBEffects::Ingrain] || @opponent.effects[PBEffects::SmackDown] || @battle.state.effects[PBEffects::Gravity]>0 || (@mondata.oppitemworks && @opponent.item == PBItems::IRONBALL) || @opponent.effects[PBEffects::Substitute]>0
		miniscore=1.0
		if !pbAIfaster?()
			if checkAImoves([PBMoves::BOUNCE, PBMoves::FLY, PBMoves::SKYDROP])
				miniscore*=1.3
			else
				miniscore*=2 if @opponent.effects[PBEffects::TwoTurnAttack]!=0
			end
		end
		if (@opponent.pbHasType?(:FLYING) || @opponent.ability == PBAbilities::LEVITATE)
			miniscore*= (@attacker.moves.any?{|moveloop| moveloop!=nil && moveloop.pbType(@attacker)==PBTypes::GROUND && moveloop.basedamage>0}) ? 2 : 1.2
		end
		return miniscore
	end

	def nightmarecode
		return 0 if @opponent.effects[PBEffects::Nightmare] || @opponent.status!=PBStatuses::SLEEP || @opponent.effects[PBEffects::Substitute]>0
		miniscore=1.0
		miniscore*=4 if @opponent.statusCount>2
		miniscore*=6 if @opponent.ability == PBAbilities::COMATOSE
		miniscore*=6 if @initial_scores.length>0 && hasbadmoves(25)
		miniscore*=0.5 if @opponent.ability == PBAbilities::SHEDSKIN || @opponent.ability == PBAbilities::EARLYBIRD
		if @attacker.ability == PBAbilities::SHADOWTAG || @attacker.ability == PBAbilities::ARENATRAP || @opponent.effects[PBEffects::MeanLook]>=0 || @opponent.pbNonActivePokemonCount==0
			miniscore*=1.3
		else
			miniscore*=0.8
		end
		miniscore*=0.5 if @battle.doublebattle
		return miniscore
	end

	def spitecode(score)
		score+=10 if $cache.pkmn_move[@opponent.lastMoveUsed][PBMoveData::BASEDAMAGE]>0 && (@opponent.moves.count {|moveloop| moveloop!=nil && moveloop.basedamage>0}) ==1
		score*=0.5 if !pbAIfaster?(@move)
		if $cache.pkmn_move[@opponent.lastMoveUsed][PBMoveData::TOTALPP]==5
			score*=1.5
		elsif $cache.pkmn_move[@opponent.lastMoveUsed][PBMoveData::TOTALPP]==10
			score*=1.2
		else
			score*=0.7
		end
		return score
	end

	def spoopycode
		return 0 if @opponent.effects[PBEffects::Curse] || @attacker.hp*2<@attacker.totalhp
		miniscore=0.7
		miniscore*=0.5 if !pbAIfaster?(@move)
		miniscore*=1.3 if (getAIMemory().length > 0) && checkAIdamage()*5 < @attacker.hp
		miniscore*=1.2 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.isHealingMove?}
		miniscore*=(1+0.05*statchangecounter(@opponent,1,7))
		if @attacker.ability == PBAbilities::SHADOWTAG || @attacker.ability == PBAbilities::ARENATRAP || @opponent.effects[PBEffects::MeanLook]>=0 || @opponent.pbNonActivePokemonCount==0
			miniscore*=1.3
		else
			miniscore*=0.8
		end
		miniscore*=0.5 if @battle.doublebattle
		miniscore*=1.3 if @initial_scores.length>0 && hasbadmoves(25)
		return miniscore
	end

	def brickbreakcode(attacker=@attacker)
		miniscore = 1.0
		miniscore*=1.8 if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
		miniscore*=1.3 if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
		miniscore*=2.0 if attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
		return miniscore
	end

	def jumpcode(score)
		miniscore=1.0
		miniscore*= 0.8 if score < 100
		miniscore*=0.5 if checkAImoves(PBStuff::PROTECTMOVE)
		miniscore*=(1-0.1*@opponent.stages[PBStats::EVASION])
		miniscore*=(1+0.1*@attacker.stages[PBStats::ACCURACY])
		miniscore*=0.7 if accuracyWeatherAbilityActive?(@opponent)
		miniscore*=0.7 if (@mondata.oppitemworks && @opponent.item == PBItems::LAXINCENSE) || (@mondata.oppitemworks && @opponent.item == PBItems::BRIGHTPOWDER)
		return miniscore
	end

	def hazardcode
		miniscore=1.0
		miniscore*=1.1 if @mondata.roles.include?(PBMonRoles::LEAD)
		miniscore*=1.3 if notOHKO?(@attacker, @opponent)
		miniscore*=1.2 if @attacker.turncount<2
		miniscore*=0.9 if @attacker.stages[PBStats::ATTACK] > 0 || @attacker.stages[PBStats::SPATK] > 0
		if @opponent.pbNonActivePokemonCount>2
			miniscore*=0.2*(@opponent.pbNonActivePokemonCount)
		else
			miniscore*=0.2
		end
		if @mondata.skill>=BESTSKILL
			if !@battle.pbIsWild?
				oppparty = @aiMoveMemory[@battle.pbGetOwner(@opponent.index)]
				movecheck = false
				for key in oppparty.keys
					movecheck = true if oppparty[key].any? {|moveloop|moveloop!=nil && (moveloop.id==PBMoves::DEFOG || move.id ==PBMoves::RAPIDSPIN)}
				end
				miniscore*=0.3 if movecheck
			end
		elsif @mondata.skill>=MEDIUMSKILL
			miniscore*=0.3 if checkAImoves([PBMoves::DEFOG,PBMoves::RAPIDSPIN])
		end
		return miniscore
	end

	def electricterraincode
		return @move.basedamage > 0 ? 1 : 0 if @battle.FE == PBFields::ELECTRICT || @battle.FE == PBFields::UNDERWATER || @battle.FE == PBFields::NEWW
		miniscore=1.0
		miniscore*= getFieldDisruptScore(@attacker,@opponent)
		miniscore*=1.5 if @attacker.ability == PBAbilities::SURGESURFER
		miniscore*=1.3 if @attacker.pbHasType?(:ELECTRIC)
		miniscore*=1.5 if pbPartyHasType?(PBTypes::ELECTRIC)
		miniscore*=0.5 if @opponent.pbHasType?(:ELECTRIC)
		miniscore*=0.5 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.function==0x03}
		miniscore*=1.6 if checkAImoves(PBStuff::SLEEPMOVE)
		miniscore*=2 if @mondata.attitemworks && @attacker.item == PBItems::AMPLIFIELDROCK
		return miniscore
	end

	def grassyterraincode
		return 0 if @battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::UNDERWATER || @battle.FE == PBFields::NEWW
		miniscore=1.0
		miniscore*= getFieldDisruptScore(@attacker,@opponent)
		miniscore*=1.5 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		miniscore*=1.5 if @attacker.pbHasType?(:FIRE)
		miniscore*=1.5 if pbPartyHasType?(PBTypes::FIRE)
		if opponent.pbHasType?(:FIRE)
			miniscore*=0.5
			miniscore*=0.5 if @battle.pbWeather!=PBWeather::RAINDANCE
			miniscore*=0.5 if @attacker.pbHasType?(:GRASS)
		elsif @attacker.pbHasType?(:GRASS)
			miniscore*=1.5
		end
		miniscore*=2 if pbPartyHasType?(PBTypes::GRASS)
		miniscore*=0.5 if checkAIhealing()
		miniscore*=0.5 if checkAImoves([PBMoves::SLUDGEWAVE])
		miniscore*=1.5 if @attacker.ability == PBAbilities::GRASSPELT
		miniscore*=2 if @mondata.attitemworks && @attacker.item == PBItems::AMPLIFIELDROCK
		return miniscore
	end

	def mistyterraincode
		return 0 if @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::UNDERWATER || @battle.FE == PBFields::NEWW
		miniscore=1.0
		miniscore*= getFieldDisruptScore(@attacker,@opponent)
		miniscore*=2 if pbPartyHasType?(PBTypes::FAIRY)
		miniscore*=2 if !@attacker.pbHasType?(:FAIRY) && @opponent.pbHasType?(:DRAGON)
		miniscore*=0.5 if @attacker.pbHasType?(:DRAGON)
		miniscore*=0.5 if @opponent.pbHasType?(:FAIRY)
		miniscore*=2 if @attacker.pbHasType?(:FAIRY) && @opponent.spatk>@opponent.attack
		miniscore*=2 if @mondata.attitemworks && @attacker.item == PBItems::AMPLIFIELDROCK
		return miniscore
	end

	def arocode(stat)
		return 0 if !(@battle.doublebattle && @opponent.index==@attacker.pbPartner.index && @opponent.stages[stat]!=6)
		miniscore=1.0
		newopp = @attacker.pbOppositeOpposing
		miniscore*= newopp.spatk > newopp.attack ? 2 : 0.5
		miniscore*=1.3 if @initial_scores.length>0 && hasbadmoves(20)
		miniscore*=1.1 if @opponent.hp*(1.0/@opponent.totalhp)>0.75
		miniscore*=0.3 if @opponent.effects[PBEffects::Yawn]>0 || @opponent.effects[PBEffects::LeechSeed]>=0 || @opponent.effects[PBEffects::Attract]>=0 || @opponent.status!=0
		if !@battle.pbIsWild?
			oppparty = @aiMoveMemory[@battle.pbGetOwner(newopp.index)]
			movecheck = false
			for key in oppparty.keys
				movecheck = true if oppparty[key].any? {|moveloop| moveloop!=nil && PBStuff::PHASEMOVE.include?(moveloop.id)}
			end
		end
		miniscore*=0.2 if movecheck
		miniscore*=2  if @opponent.ability == PBAbilities::SIMPLE
		miniscore*=0.5 if newopp.ability == PBAbilities::UNAWARE
		miniscore*=1.2 if hpGainPerTurn>1
		miniscore*=0 if @opponent.ability == PBAbilities::CONTRARY
		miniscore*=2 if @battle.FE == PBFields::MISTYT && stat==PBStats::SPDEF
	end

	def flowershieldcode(score)
		return 0 unless @battle.doublebattle && @opponent.pbHasType?(:GRASS) && @opponent.index==@attacker.pbPartner.index && @opponent.stages[PBStats::DEFENSE]!=6
		opp1 = @attacker.pbOppositeOpposing
		opp2 = opp1.pbPartner
		if @battle.FE != PBFields::FLOWERGARDENF || @battle.field.counter==0
			score*= opp1.attack>opp1.spatk ? 2 : 0.5
			score*= opp2.attack>opp2.spatk ? 2 : 0.5
		else
			score*=2
		end
		score+=30 if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter!=4
		if (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter>0) || @battle.FE == PBFields::FAIRYTALEF
			score+=20
			miniscore=100
			miniscore*=1.3 if @attacker.effects[PBEffects::Substitute]>0 || @attacker.effects[PBEffects::Disguise]
			miniscore*=1.3 if @initial_scores.length>0 && hasbadmoves(20)
			miniscore*=1.1 if (@opponent.hp.to_f)/@opponent.totalhp>0.75
			miniscore*=1.2 if opp1.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3 if opp1.effects[PBEffects::Yawn]>0
			miniscore*=1.1 if checkAIdamage() < @opponent.hp*0.3
			miniscore*=1.1 if @opponent.turncount<2
			miniscore*=1.1 if opp1.status!=0
			miniscore*=1.3 if opp1.status==PBStatuses::SLEEP || opp1.status==PBStatuses::FROZEN
			miniscore*=1.5 if opp1.effects[PBEffects::Encore]>0 && opp1.moves[(opp1.effects[PBEffects::EncoreIndex])].basedamage==0
			miniscore*=0.5 if @opponent.effects[PBEffects::Confusion]>0
			miniscore*=0.3 if @opponent.effects[PBEffects::LeechSeed]>=0 || @attacker.effects[PBEffects::Attract]>=0
			miniscore*=0.2 if @opponent.effects[PBEffects::Toxic]>0
			miniscore*=0.2 if checkAImoves(PBStuff::PHASEMOVE)
			miniscore*=2 if @opponent.ability == PBAbilities::SIMPLE
			miniscore*=0.5 if opp1.ability == PBAbilities::UNAWARE
			miniscore*=0.3 if @battle.doublebattle
			miniscore/=100.0
			score*=miniscore
			miniscore=100
			miniscore*=1.5 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
			miniscore*=1.2 if (@mondata.attitemworks && @attacker.item == PBItems::LEFTOVERS) || ((@mondata.attitemworks && @attacker.item == PBItems::BLACKSLUDGE) && @attacker.pbHasType?(:POISON))
			miniscore*=1.7 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.isHealingMove?}
			miniscore*=1.3 if @attacker.pbHasMove?(PBMoves::LEECHSEED)
			miniscore*=1.2 if @attacker.pbHasMove?(PBMoves::PAINSPLIT)
			score*=miniscore if @attacker.stages[PBStats::SPDEF]!=6 && @attacker.stages[PBStats::DEFENSE]!=6
			score=0 if @attacker.ability == PBAbilities::CONTRARY
		end
		return score
	end

	def rotocode(score)
		return 0 unless @battle.doublebattle && @opponent.index == @attacker.pbPartner.index
		return 0 if !(@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter > 0) && (!@opponent.pbHasType?(:GRASS) || @opponent.isAirborne?)
		miniscore = 1.0
		if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter > 0 && @attacker.pbHasType?(:GRASS) && !@attacker.isAirborne?
			score+=30
			miniscore*= selfstatboost([2,0,0,2,0,0,0])
		end
		if @battle.FE == PBFields::FLOWERGARDENF
			score+=20
			miniscore*=1.3 if @attacker.effects[PBEffects::Substitute]>0 || @attacker.effects[PBEffects::Disguise]
			miniscore*=1.3 if @initial_scores.length>0 && hasbadmoves(20)
			miniscore*=1.1 if (@opponent.hp.to_f)/@opponent.totalhp>0.75
			miniscore*=1.2 if opp1.effects[PBEffects::HyperBeam]>0
			miniscore*=1.3 if opp1.effects[PBEffects::Yawn]>0
			miniscore*=1.1 if checkAIdamage() < @opponent.hp*0.25
			miniscore*=1.1 if @opponent.turncount<2
			miniscore*=1.1 if opp1.status!=0
			miniscore*=1.3 if opp1.status==PBStatuses::SLEEP || opp1.status==PBStatuses::FROZEN
			miniscore*=1.5 if opp1.effects[PBEffects::Encore]>0 && opp1.moves[(opp1.effects[PBEffects::EncoreIndex])].basedamage==0
			miniscore*=0.2 if @opponent.effects[PBEffects::Confusion]>0
			miniscore*=0.6 if @opponent.effects[PBEffects::LeechSeed]>=0 || @attacker.effects[PBEffects::Attract]>=0
			miniscore*=0.5 if checkAImoves(PBStuff::PHASEMOVE)
			miniscore*=2   if @opponent.ability == PBAbilities::SIMPLE
			miniscore*=0.5 if opp1.ability == PBAbilities::UNAWARE
			miniscore*=0.3 if @battle.doublebattle
			miniscore*=1+0.05*@opponent.stages[PBStats::SPEED] if @opponent.stages[PBStats::SPEED]<0
			ministat=@opponent.stages[PBStats::ATTACK] + @opponent.stages[PBStats::SPEED] + @opponent.stages[PBStats::SPATK]
			miniscore*=1 -0.05*ministat if ministat > 0
			miniscore*=1.3 if checkAIhealing()
			miniscore*=1.5 if @attacker.pbSpeed>pbRoughStat(@opponent,PBStats::SPEED,@mondata.skill) && @battle.trickroom==0
			miniscore*=1.3 if @mondata.roles.include?(PBMonRoles::SWEEPER)
			miniscore*=0.5 if @attacker.status==PBStatuses::PARALYSIS
			miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY])
			miniscore*=1.4 if @attacker.hp==@attacker.totalhp && (@mondata.attitemworks && @attacker.item == PBItems::FOCUSSASH)
			miniscore*=0.4 if checkAIpriority()
			score*=miniscore
		end
		return score
	end

	def craftyshieldcode(score)
		if attacker.lastMoveUsed==PBMoves::CRAFTYSHIELD
			score*=0.5
		else
			score+=10 if opponent.moves.all? {|moveloop| moveloop!=nil && moveloop.basedamage>0}
			score*=1.5 if attacker.hp==attacker.totalhp
		end
		if @battle.FE == PBFields::FAIRYTALEF
			score+=25
			score*=selfstatboost([0,1,0,0,1,0,0])
		end
		return score
	end

	def turvycode
		miniscore = [(1 + 0.10*statchangecounter(@opponent,1,7)),0].max
		miniscore = 2-miniscore if @opponent.index == @attacker.pbPartner.index
		return miniscore
	end

	def fairylockcode
		return 0 if @attacker.effects[PBEffects::PerishSong]==1 || @attacker.effects[PBEffects::PerishSong]==2
	 	miniscore=1.0
		miniscore*=10 if @opponent.effects[PBEffects::PerishSong]==2
		miniscore*=20 if @opponent.effects[PBEffects::PerishSong]==1
		miniscore*=0.8 if @attacker.effects[PBEffects::LeechSeed]>=0
		miniscore*=1.2 if @opponent.effects[PBEffects::LeechSeed]>=0
		miniscore*=1.3 if @opponent.effects[PBEffects::Curse]
		miniscore*=0.7 if @attacker.effects[PBEffects::Curse]
		miniscore*=1.1 if @opponent.effects[PBEffects::Confusion]>0
		miniscore*=1.1 if @attacker.effects[PBEffects::Confusion]>0
		return miniscore
	end

	def flingcode
		return 0 if @attacker.item ==0 || @battle.pbIsUnlosableItem(@attacker,@attacker.item) || @attacker.ability == PBAbilities::KLUTZ || (pbIsBerry?(@attacker.item) && @opponent.ability == PBAbilities::UNNERVE) || @attacker.effects[PBEffects::Embargo]>0 || @battle.state.effects[PBEffects::MagicRoom]>0
		miniscore=1.0
		case @attacker.item
			when PBItems::POISONBARB then miniscore*=1.2 if @opponent.pbCanPoison?(false) && @opponent.ability != PBAbilities::POISONHEAL
			when PBItems::TOXICORB
				if @opponent.pbCanPoison?(false) && @opponent.ability != PBAbilities::POISONHEAL
					miniscore*=1.2
					miniscore*=2 if @attacker.pbCanPoison?(false) && @attacker.ability != PBAbilities::POISONHEAL
				end
			when PBItems::FLAMEORB
				if @opponent.pbCanBurn?(false) && @opponent.ability != PBAbilities::GUTS
					miniscore*=1.3
					miniscore*=2 if @attacker.pbCanBurn?(false) && @attacker.ability != PBAbilities::GUTS
				end
			when PBItems::LIGHTBALL then miniscore*=1.3 if @opponent.pbCanParalyze?(false) && @opponent.ability != PBAbilities::QUICKFEET
			when PBItems::KINGSROCK, PBItems::RAZORCLAW then miniscore*=1.3 if @opponent.ability != PBAbilities::INNERFOCUS && pbAIfaster?(@move)
			when PBItems::LAXINCENSE, PBItems::CHOICESCARF, PBItems::CHOICEBAND, PBItems::CHOICESPECS, PBItems::SYNTHETICSEED, PBItems::TELLURICSEED, PBItems::ELEMENTALSEED, PBItems::MAGICALSEED, PBItems::EXPERTBELT, PBItems::FOCUSSASH, PBItems::LEFTOVERS, PBItems::MUSCLEBAND, PBItems::WISEGLASSES, PBItems::LIFEORB, PBItems::EVIOLITE, PBItems::ASSAULTVEST, PBItems::BLACKSLUDGE, PBItems::POWERHERB, PBItems::MENTALHERB
				miniscore*=0
			when PBItems::STICKYBARB then miniscore*=1.2
			when PBItems::LAGGINGTAIL then miniscore*=3
			when PBItems::IRONBALL then miniscore*=1.5
		end
		if pbIsBerry?(@attacker.item)
			if @attacker.item ==PBItems::FIGYBERRY || @attacker.item ==PBItems::WIKIBERRY || @attacker.item ==PBItems::MAGOBERRY || @attacker.item ==PBItems::AGUAVBERRY || @attacker.item ==PBItems::IAPAPABERRY
				miniscore*=1.3 if @opponent.pbCanConfuse?(false)
			else
				miniscore*=0
			end
		end
		return miniscore
	end

	def recyclecode
		return 0 if @attacker.pokemon.itemRecycle==0
		return 0 if (@opponent.ability == PBAbilities::MAGICIAN && @opponent.item==0) || checkAImoves([PBMoves::KNOCKOFF,PBMoves::THIEF,PBMoves::COVET])
		return 0 if @attacker.ability == PBAbilities::UNBURDEN || @attacker.ability == PBAbilities::HARVEST || @attacker.pbHasMove?(PBMoves::ACROBATICS)
		miniscore=2.0
		miniscore*=2 if @attacker.pbHasMove?(PBMoves::NATURALGIFT)
		case @attacker.pokemon.itemRecycle
			when PBItems::LUMBERRY
				miniscore*=2 if @attacker.status!=0
			when PBItems::SITRUSBERRY, PBItems::FIGYBERRY, PBItems::WIKIBERRY, PBItems::MAGOBERRY, PBItems::AGUAVBERRY, PBItems::IAPAPABERRY
				miniscore*=1.6 if @attacker.hp<0.66*@attacker.totalhp
				miniscore*=1.5 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		end

		if pbIsBerry?(@attacker.pokemon.itemRecycle)
			miniscore*=0 if @opponent.ability == PBAbilities::UNNERVE
			miniscore*=0 if checkAImoves([PBMoves::INCINERATE,PBMoves::PLUCK,PBMoves::BUGBITE])
		end
		return miniscore
	end



	def embarcode(opponent=@opponent)
		return 0 if opponent.effects[PBEffects::Embargo]>0  && opponent.effects[PBEffects::Substitute]>0 || opponent.item==0
		miniscore = 1.1
		miniscore*=1.1 if pbIsBerry?(opponent.item)
		case opponent.item
			when PBItems::LAXINCENSE, PBItems::SYNTHETICSEED, PBItems::TELLURICSEED, PBItems::ELEMENTALSEED, PBItems::MAGICALSEED, PBItems::EXPERTBELT, PBItems::MUSCLEBAND, PBItems::WISEGLASSES, PBItems::LIFEORB, PBItems::EVIOLITE, PBItems::ASSAULTVEST
				miniscore*=1.2
			when PBItems::LEFTOVERS, PBItems::BLACKSLUDGE
				miniscore*=1.3
		end
		miniscore*=1.4 if opponent.hp*2<opponent.totalhp
		return miniscore
	end

	def roastcode
		return 1 if !pbIsBerry?(@opponent.item) && !pbIsTypeGem?(@opponent.item) || @opponent.ability == PBAbilities::STICKYHOLD || @opponent.effects[PBEffects::Substitute] > 0
		miniscore=1.0
		miniscore*=1.2 if pbIsBerry?(@opponent.item) && @opponent.item!=PBItems::OCCABERRY
		miniscore*=1.3 if @opponent.item ==PBItems::LUMBERRY || @opponent.item ==PBItems::SITRUSBERRY || @opponent.item ==PBItems::PETAYABERRY || @opponent.item ==PBItems::LIECHIBERRY || @opponent.item ==PBItems::SALACBERRY || @opponent.item ==PBItems::CUSTAPBERRY
		miniscore*=1.4 if pbIsTypeGem?(@opponent.item)
		return miniscore
	end

	def nomcode
		return 1 if @opponent.effects[PBEffects::Substitute] > 0 || !pbIsBerry?(@opponent.item)
		miniscore=1.0
		case @opponent.item
			when PBItems::LUMBERRY then miniscore*=2 if @attacker.status!=0
			when PBItems::SITRUSBERRY, PBItems::FIGYBERRY, PBItems::WIKIBERRY, PBItems::MAGOBERRY, PBItems::AGUAVBERRY, PBItems::IAPAPABERRY then miniscore*=1.6 if @attacker.hp*(1.0/@attacker.totalhp)<0.66
			when PBItems::LIECHIBERRY then miniscore*=1.5 if @attacker.attack>@attacker.spatk
			when PBItems::PETAYABERRY then miniscore*=1.5 if @attacker.spatk>@attacker.attack
			when PBItems::CUSTAPBERRY, PBItems::SALACBERRY then miniscore*= pbAIfaster? ? 1.1 : 1.5
			else
				miniscore*=1.1
		end
		return miniscore
	end

	def perishcode
		return 0 if @opponent.effects[PBEffects::PerishSong]>0
		return 4 if @opponent.pbNonActivePokemonCount==0
		return 0 if @attacker.pbNonActivePokemonCount==0
		miniscore=1.0
		miniscore*=1.5 if @attacker.pbHasMove?(PBMoves::UTURN) || @attacker.pbHasMove?(PBMoves::VOLTSWITCH) || @attacker.pbHasMove?(PBMoves::PARTINGSHOT)
		miniscore*=3 if @attacker.ability == PBAbilities::SHADOWTAG || @opponent.effects[PBEffects::MeanLook]>0
		miniscore*=1.2 if @mondata.partyroles.any? {|role| role.include?(PBMonRoles::SWEEPER)}
		miniscore*=1.2 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.isHealingMove?}
		miniscore*=1-0.05*statchangecounter(@attacker,1,7)
		miniscore*=1+0.05*statchangecounter(@opponent,1,7)
		miniscore*=0.5 if checkAImoves(PBStuff::PIVOTMOVE)
		miniscore*=0.1 if (@opponent.ability == PBAbilities::SHADOWTAG || @attacker.effects[PBEffects::MeanLook]>0) && !(@attacker.pbHasMove?(PBMoves::UTURN) || @attacker.pbHasMove?(PBMoves::VOLTSWITCH) || @attacker.pbHasMove?(PBMoves::PARTINGSHOT))
		miniscore*=1.5 if @mondata.partyroles.any? {|role| role.include?(PBMonRoles::PIVOT)}
		return miniscore
    end

	def noLeechSeed(leechTarget)
		return true if leechTarget.effects[PBEffects::LeechSeed] > -1
		return true if leechTarget.pbHasType?(:GRASS)
		return true if leechTarget.effects[PBEffects::Substitute] > 0 
		return true if leechTarget.ability == PBAbilities::LIQUIDOOZE
		return true if leechTarget.ability == PBAbilities::MAGICBOUNCE
		return true if leechTarget.effects[PBEffects::MagicCoat]==true
		return true if leechTarget.hp == 0
		return false
	end

	def leechcode
		return 0 if noLeechSeed(@opponent) == true
		miniscore=1.0
		miniscore*=1.2 if (@mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL) || @mondata.roles.include?(PBMonRoles::TANK))
		miniscore*=1.3 if @attacker.effects[PBEffects::Substitute]>0
		miniscore*=1.2 if hpGainPerTurn(@opponent)>1 || (@mondata.attitemworks && @attacker.item == PBItems::BIGROOT)
		miniscore*=1.2 if @opponent.status==PBStatuses::PARALYSIS || @opponent.status==PBStatuses::SLEEP
		miniscore*=1.2 if @opponent.effects[PBEffects::Confusion]>0
		miniscore*=1.2 if @opponent.effects[PBEffects::Attract]>=0
		miniscore*=1.1 if @opponent.status==PBStatuses::POISON || @opponent.status==PBStatuses::BURN
		miniscore*=0.2 if checkAImoves(([PBMoves::RAPIDSPIN] | PBStuff::PIVOTMOVE))
		if @opponent.hp==@opponent.totalhp
			miniscore*=1.1
		else
			miniscore*=(@opponent.hp*(1.0/@opponent.totalhp))
		end
		miniscore*=0.8 if @opponent.hp*2<@opponent.totalhp
		miniscore*=0.2 if @opponent.hp*4<@opponent.totalhp
		miniscore*=1.2 if @attacker.moves.any? {|moveloop| moveloop!=nil && (PBStuff::PROTECTMOVE).include?(moveloop.id)}
		miniscore*=1 + 0.05*statchangecounter(@opponent,1,7,1)
		return miniscore
	end

	def moveturnselectriccode(alltypes,damagemove)
		miniscore=1.0
		maxnormal= alltypes ? checkAIbestMove().type==PBTypes::NORMAL : true
		if pbAIfaster?(@move)
			miniscore*=0.9
		elsif @attacker.ability == PBAbilities::MOTORDRIVE && maxnormal
			miniscore*=1.5
		end
		miniscore*=1.5 if (@attacker.ability == PBAbilities::LIGHTNINGROD || @attacker.ability == PBAbilities::VOLTABSORB) && @attacker.hp.to_f < 0.6*@attacker.totalhp && maxnormal
		miniscore*=1.1 if @attacker.pbHasType?(:GROUND)
		if @battle.doublebattle
			miniscore*=1.2 if [PBAbilities::MOTORDRIVE, PBAbilities::LIGHTNINGROD, PBAbilities::VOLTABSORB].include?(@attacker.pbPartner.ability)
			miniscore*=1.1 if @attacker.pbPartner.pbHasType?(:GROUND)
		end
		miniscore*=0.5 if !maxnormal
		return miniscore
	end

	def bidecode
		miniscore=@attacker.hp*(1.0/@attacker.totalhp)
		miniscore*=0.5 if hasgreatmoves()
		miniscore*=1.2 if notOHKO?(@attacker, @opponent, true)
		miniscore*=0.2 if checkAIdamage()*2 > @attacker.hp
		miniscore*=0.7 if @attacker.hp*3<@attacker.totalhp
		miniscore*=1.1 if (@mondata.attitemworks && @attacker.item == PBItems::LEFTOVERS) || ((@mondata.attitemworks && @attacker.item == PBItems::BLACKSLUDGE) && @attacker.pbHasType?(:POISON))
		miniscore*=1.3 if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
		miniscore*=1.3 if !pbAIfaster?()
		miniscore*=0.5 if checkAImoves(PBStuff::SETUPMOVE)
		
		if getAIMemory().any? {|moveloop| moveloop!=nil && moveloop.basedamage==0}
			miniscore*=0.8
		elsif getAIMemory().length==4
			miniscore*=1.3
		end
		return miniscore
	end

	def rolloutcode
		miniscore=1.0
		miniscore*=1.1 if @opponent.pbNonActivePokemonCount==0 || @attacker.ability == PBAbilities::SHADOWTAG || @opponent.effects[PBEffects::MeanLook]>0
		miniscore*=0.75 if @attacker.hp*(1.0/@attacker.totalhp)<0.75
		miniscore*=1+0.05*@attacker.stages[PBStats::ACCURACY] if @attacker.stages[PBStats::ACCURACY]<0
		miniscore*=1+0.05*@attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK]<0
		miniscore*=1-0.05*@opponent.stages[PBStats::EVASION] if @opponent.stages[PBStats::EVASION]>0
		miniscore*=0.8 if (@mondata.oppitemworks && @opponent.item == PBItems::LAXINCENSE) || (@mondata.oppitemworks && @opponent.item == PBItems::BRIGHTPOWDER)
		miniscore*=0.8 if accuracyWeatherAbilityActive?(@opponent)
		miniscore*=0.5 if @attacker.status==PBStatuses::PARALYSIS
		miniscore*=0.5 if @attacker.effects[PBEffects::Confusion]>0
		miniscore*=0.5 if @attacker.effects[PBEffects::Attract]>=0
		miniscore*= 1 - (@opponent.pbNonActivePokemonCount*0.05) if @opponent.pbNonActivePokemonCount>1
		miniscore*=1.2 if @attacker.effects[PBEffects::DefenseCurl]
		miniscore*=1.5 if checkAIdamage()*3<@attacker.hp && (getAIMemory().length > 0)
		miniscore+=4 if hasbadmoves(15)
		miniscore*=0.8 if checkAImoves(PBStuff::PROTECTMOVE)
		return miniscore
	end

	def outragecode(score)
		return 1.3 if @attacker.ability == PBAbilities::OWNTEMPO
		miniscore=1.0
		miniscore*=0.85 if score<100
		miniscore*=1.3 if (@mondata.attitemworks && @attacker.item == PBItems::LUMBERRY) || (@mondata.attitemworks && @attacker.item == PBItems::PERSIMBERRY)
		miniscore*=1-0.05*@attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK]>0
		miniscore*=1-0.025*(@battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))) if (@battle.pbPokemonCount(@battle.pbPartySingleOwner(@attacker.index))) > 2
		miniscore*=0.7 if checkAImoves(PBStuff::PROTECTMOVE)
		miniscore*=0.7 if checkAIhealing()
		return miniscore
    end

	def spectralthiefcode
		miniscore= 0.10*statchangecounter(@opponent,1,7)
		miniscore*=(-1) if @attacker.ability == PBAbilities::CONTRARY
		miniscore*=2 if @attacker.ability == PBAbilities::SIMPLE
		miniscore+=1
		miniscore*=1.2 if @opponent.effects[PBEffects::Substitute]>0
		return miniscore
	end

	def stupidmovecode
		return 0 if pbAIfaster?()
		return 0 if @opponent.stages[PBStats::SPEED]==0 && @attacker.stages[PBStats::SPEED]==0
		miniscore = 1 + 0.1*@opponent.stages[PBStats::SPEED] - 0.1*@attacker.stages[PBStats::SPEED]
		miniscore*=0.8 if @battle.doublebattle
		return miniscore
	end

	def spotlightcode
		return 0 if !@battle.doublebattle || @opponent.index!=@attacker.pbPartner.index
		miniscore=1.0
		bestmove1 = checkAIbestMove(@attacker.pbOpposing1) #grab moves opposing mons are going to use
		bestmove2 = checkAIbestMove(@attacker.pbOpposing2)
		if @opponent.ability == PBAbilities::FLASHFIRE
			miniscore*=3 if bestmove1.pbType(@attacker.pbOpposing1) ==PBTypes::FIRE || bestmove2.pbType(@attacker.pbOpposing2) ==PBTypes::FIRE
		elsif @opponent.ability == PBAbilities::STORMDRAIN || @opponent.ability == PBAbilities::DRYSKIN || @opponent.ability == PBAbilities::WATERABSORB
			miniscore*=3 if bestmove1.pbType(@attacker.pbOpposing1) ==PBTypes::WATER || bestmove2.pbType(@attacker.pbOpposing2) ==PBTypes::WATER
		elsif @opponent.ability == PBAbilities::MOTORDRIVE || @opponent.ability == PBAbilities::LIGHTNINGROD || @opponent.ability == PBAbilities::VOLTABSORB
			miniscore*=3 if bestmove1.pbType(@attacker.pbOpposing1) ==PBTypes::ELECTRIC ||bestmove2.pbType(@attacker.pbOpposing2) ==PBTypes::ELECTRIC
		elsif @opponent.ability == PBAbilities::SAPSIPPER
			miniscore*=3 if bestmove1.pbType(@attacker.pbOpposing1) ==PBTypes::GRASS || bestmove2.pbType(@attacker.pbOpposing2) ==PBTypes::GRASS
		end
		miniscore*=2 if (bestmove1.isContactMove? || bestmove2.isContactMove?) && checkAImoves([PBMoves::KINGSSHIELD, PBMoves::BANEFULBUNKER, PBMoves::SPIKYSHIELD])
		miniscore*=2 if checkAImoves([PBMoves::COUNTER, PBMoves::METALBURST, PBMoves::MIRRORCOAT])
		miniscore*=1.5 if !pbAIfaster?(nil,nil,@attacker,@attacker.pbOpposing1)
		miniscore*=1.5 if !pbAIfaster?(nil,nil,@attacker,@attacker.pbOpposing2)
		return miniscore
	end

######################################################
# Utility functions
######################################################

	def pbGetMonRoles(targetmon=nil)
		partyRoles = []
		party = targetmon ? [targetmon] : @mondata.party
		for mon in party
			monRoles=[]
			movelist = []
			if targetmon && targetmon.class==PokeBattle_Pokemon || !targetmon
				for i in mon.moves
					next if i.nil?
					movedummy = PokeBattle_Move.new(@battle,i,mon)
					movelist.push(movedummy)
				end
			elsif targetmon && targetmon.class==PokeBattle_Battler
				movelist = targetmon.moves
			end
			monRoles.push(PBMonRoles::LEAD) if @mondata.party.index(mon)==0 || (@mondata.party.index(mon)==1 && @battle.doublebattle && @battle.pbParty(@mondata.index)==@battle.pbPartySingleOwner(@mondata.index))
			monRoles.push(PBMonRoles::ACE) if @mondata.party.index(mon)==(@mondata.party.length-1)
			secondhighest=true
			if party.length>2
				for i in 0..(party.length-2)
					next if party[i].nil?
					secondhighest=false if mon.level<party[i].level
				end
			end
			for i in movelist
				next if i.nil?
				next if i.id == 0
				healingmove=true if i.isHealingMove?
				curemove=true if (i.id == PBMoves::HEALBELL || i.id == PBMoves::AROMATHERAPY)
				wishmove=true if i.id == PBMoves::WISH
				phasemove=true if PBStuff::PHASEMOVE.include?(i.id)
				pivotmove=true if PBStuff::PIVOTMOVE.include?(i.id)
				spinmove=true if i.id == PBMoves::RAPIDSPIN
				batonmove=true if i.id == PBMoves::BATONPASS
				screenmove=true if PBStuff::SCREENMOVE.include?(i.id)
				tauntmove=true if i.id == PBMoves::TAUNT
				restmove=true if i.id == PBMoves::REST
				weathermove=true if (i.id == PBMoves::SUNNYDAY || i.id == PBMoves::RAINDANCE || i.id == PBMoves::HAIL || i.id == PBMoves::SANDSTORM)
				fieldmove=true if (i.id == PBMoves::GRASSYTERRAIN || i.id == PBMoves::ELECTRICTERRAIN || i.id == PBMoves::MISTYTERRAIN || i.id == PBMoves::PSYCHICTERRAIN || i.id == PBMoves::MIST || i.id == PBMoves::IONDELUGE || i.id == PBMoves::TOPSYTURVY)
			end
			monRoles.push(PBMonRoles::SWEEPER) 		if mon.ev[3]>251 && (mon.nature==PBNatures::MODEST || mon.nature==PBNatures::JOLLY || mon.nature==PBNatures::TIMID || mon.nature==PBNatures::ADAMANT) || (mon.item==(PBItems::CHOICEBAND) || mon.item==(PBItems::CHOICESPECS) || mon.item==(PBItems::CHOICESCARF))
			monRoles.push(PBMonRoles::PHYSICALWALL) if healingmove && (mon.ev[2]>251 && (mon.nature==PBNatures::BOLD || mon.nature==PBNatures::RELAXED || mon.nature==PBNatures::IMPISH || mon.nature==PBNatures::LAX))
			monRoles.push(PBMonRoles::SPECIALWALL)	if healingmove && (mon.ev[5]>251 && (mon.nature==PBNatures::CALM || mon.nature==PBNatures::GENTLE || mon.nature==PBNatures::SASSY || mon.nature==PBNatures::CAREFUL))
			monRoles.push(PBMonRoles::CLERIC) 		if curemove || (wishmove && mon.ev[0]>251)
			monRoles.push(PBMonRoles::PHAZER) 		if phasemove
			monRoles.push(PBMonRoles::SCREENER) 	if mon.item==(PBItems::LIGHTCLAY) && screenmove
			monRoles.push(PBMonRoles::PIVOT) 		if (pivotmove && healingmove) || (mon.ability == PBAbilities::REGENERATOR)
			monRoles.push(PBMonRoles::SPINNER) 		if spinmove
			monRoles.push(PBMonRoles::TANK) 		if (mon.ev[0]>251 && !healingmove) || mon.item==(PBItems::ASSAULTVEST)
			monRoles.push(PBMonRoles::BATONPASSER) 	if batonmove
			monRoles.push(PBMonRoles::STALLBREAKER) if tauntmove || mon.item==(PBItems::CHOICEBAND) || mon.item==(PBItems::CHOICESPECS)
			monRoles.push(PBMonRoles::STATUSABSORBER) if restmove || (mon.ability == PBAbilities::COMATOSE) || mon.item==(PBItems::TOXICORB) || mon.item==(PBItems::FLAMEORB) || (mon.ability == PBAbilities::GUTS) || (mon.ability == PBAbilities::QUICKFEET)|| (mon.ability == PBAbilities::FLAREBOOST) || (mon.ability == PBAbilities::TOXICBOOST) || (mon.ability == PBAbilities::NATURALCURE) || (mon.ability == PBAbilities::MAGICGUARD) || (mon.ability == PBAbilities::MAGICBOUNCE) || hydrationCheck(mon)
			monRoles.push(PBMonRoles::TRAPPER) 		if (mon.ability == PBAbilities::SHADOWTAG) || (mon.ability == PBAbilities::ARENATRAP) || (mon.ability == PBAbilities::MAGNETPULL)
			monRoles.push(PBMonRoles::WEATHERSETTER)if weathermove || (mon.ability == PBAbilities::DROUGHT) || (mon.ability == PBAbilities::SANDSTREAM) || (mon.ability == PBAbilities::DRIZZLE) || (mon.ability == PBAbilities::SNOWWARNING) || (mon.ability == PBAbilities::PRIMORDIALSEA) || (mon.ability == PBAbilities::DESOLATELAND) || (mon.ability == PBAbilities::DELTASTREAM)
			monRoles.push(PBMonRoles::FIELDSETTER) 	if fieldmove || (mon.ability == PBAbilities::GRASSYSURGE) || (mon.ability == PBAbilities::ELECTRICSURGE) || (mon.ability == PBAbilities::MISTYSURGE) || (mon.ability == PBAbilities::PSYCHICSURGE) || mon.item==(PBItems::AMPLIFIELDROCK)
			monRoles.push(PBMonRoles::SECOND) 		if secondhighest
			partyRoles.push(monRoles)
		end
		return partyRoles[0] if targetmon
		return partyRoles
	end

	def pbMakeFakeBattler(pokemon,batonpass=false)
		return nil if pokemon.nil?
		pokemon = pokemon.clone
		battler = PokeBattle_Battler.new(@battle,@index,true)
		battler.pbInitPokemon(pokemon,@index)
		battler.pbInitEffects(batonpass, true)
		return battler
	end

	def pbSereneGraceCheck(miniscore)
		miniscore-=1
		if @move.addlEffect != 100
			addedeffect = @move.addlEffect.to_f
			addedeffect*=2 if @attacker.ability == PBAbilities::SERENEGRACE || @battle.FE == PBFields::RAINBOWF
			addedeffect=100 if addedeffect>100
			miniscore*=addedeffect/100.0
		end
		miniscore+=1
		return miniscore
	end

	def pbReduceWhenKills(miniscore)
		return miniscore if @initial_scores[@score_index] < 100
		return Math.sqrt(miniscore)
	end

	def statchangecounter(mon,initial,final,limiter=0)
		count = 0
		case limiter
		  when 0 #all stats
			for i in initial..final
			  count += mon.stages[i]
			end
		  when 1 #increases only
			for i in initial..final
			  count += mon.stages[i] if mon.stages[i]>0
			end
		  when -1 #decreases only
			for i in initial..final
			  count += mon.stages[i] if mon.stages[i]<0
			end
		end
		return count
	end

	def hasgreatmoves()
		#slight variance in precision based on trainer skill
		threshold = 100
		#threshold = 105 if @mondata.skill>=HIGHSKILL
		#threshold = 110 if @mondata.skill>=BESTSKILL
		for i in 0...@initial_scores.length
			next if i==@score_index
			if @initial_scores[i]>=threshold
				return true
			end
		end
		return false
	end
	
	def hasbadmoves(threshold,initialscores=@initial_scores,scoreindex=@score_index)
		for i in 0...initialscores.length
			next if i==scoreindex
			return false if initialscores[i]>threshold
		end
		return true
	end

	def getStatusDamage(move=@move)
		return 20 if move.zmove && (move.id == PBMoves::CONVERSION || move.id == PBMoves::SPLASH || move.id == PBMoves::CELEBRATE)
		return PBStuff::STATUSDAMAGE[move.id] if PBStuff::STATUSDAMAGE[move.id]
		return 0
	end

	def pbRoughStat(battler,stat)
		return battler.pbSpeed if @mondata.skill>=HIGHSKILL && stat==PBStats::SPEED
		stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
		stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
		stage=battler.stages[stat]+6
		value=0
		value=battler.attack if stat==PBStats::ATTACK
		value=battler.defense if stat==PBStats::DEFENSE
		value=battler.speed if stat==PBStats::SPEED
		value=battler.spatk if stat==PBStats::SPATK
		value=battler.spdef if stat==PBStats::SPDEF
		return (value*1.0*stagemul[stage]/stagediv[stage]).floor
	end

	def pbRoughAccuracy(move,attacker,opponent)
		# start with stuff that has set accuracy
		# Override accuracy
		return 100 if attacker.ability == PBAbilities::NOGUARD || opponent.ability == PBAbilities::NOGUARD || (attacker.ability == PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF) && @mondata.skill>=MEDIUMSKILL
		return 100 if move.accuracy==0   # Doesn't do accuracy check (always hits)
		return 100 if move.function==0xA5 # Swift
		if @mondata.skill>=MEDIUMSKILL
			return 100 if opponent.effects[PBEffects::LockOn]>0 && opponent.effects[PBEffects::LockOnPos]==attacker.index			
			if move.function==0x70 # OHKO moves
				return 0 if opponent.ability == PBAbilities::STURDY || opponent.level>attacker.level || (@battle.FE == PBFields::CHESSB && opponent.pokemon.piece==:PAWN)
				return move.accuracy+attacker.level-opponent.level
			end
			return 100 if opponent.effects[PBEffects::Telekinesis]>0
			return 100 if move.function==0x0D && @battle.pbWeather == PBWeather::HAIL # Blizzard
			return 100 if (move.function==0x08 || move.function==0x15) && @battle.pbWeather == PBWeather::RAINDANCE# Thunder, Hurricane
			return 100 if move.function==0x08 && (@battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM) # Thunder
			return 100 if move.type == PBTypes::ELECTRIC && @battle.FE == PBFields::UNDERWATER
			return 100 if attacker.pbHasType?(:POISON) && move.id == PBMoves::TOXIC
			if @mondata.skill>=HIGHSKILL
				return 100 if (move.function==0x10 || move.id == PBMoves::BODYSLAM || move.function==0x137 || move.function==0x9B) && opponent.effects[PBEffects::Minimize] # Flying Press, Stomp, DRush
				return 100 if @battle.FE == PBFields::MIRRORA && (PBFields::BLINDINGMOVES + [PBMoves::MIRRORSHOT]).include?(move.id)
				return 100 if @battle.FE == PBFields::MIRRORA && move.basedamage>0 && move.target==PBTargets::SingleNonUser && (move.flags&0x01)==0 && move.pbIsSpecial?(move.type) && opponent.stages[PBStats::EVASION]>0
			end
		end
		# Get base accuracy
		baseaccuracy=move.accuracy
=begin
		if @mondata.skill>=BESTSKILL
			fieldmove = @battle.field.moveData(move.id)
			baseaccuracy = fieldmove[:accmod] if fieldmove && fieldmove[:accmod]
			if @battle.FE == PBFields::FLOWERGARDENF # Flower Garden
				baseaccuracy=85 if @battle.field.counter > 1 && (move.id == PBMoves::SLEEPPOWDER || move.id == PBMoves::STUNSPORE || move.id == PBMoves::POISONPOWDER)
			end
		end
=end
		if @mondata.skill>=MEDIUMSKILL
			baseaccuracy=50 if @battle.pbWeather==PBWeather::SUNNYDAY && (move.function==0x08 || move.function==0x15) # Thunder, Hurricane
	  	end
		# Accuracy stages
		accstage=attacker.stages[PBStats::ACCURACY]
		accstage=0 if opponent.ability == PBAbilities::UNAWARE && !moldBreakerCheck(attacker)
		accuracy=(accstage>=0) ? (accstage+3)*100.0/3 : 300.0/(3-accstage)
		evastage=opponent.stages[PBStats::EVASION]
		evastage-=2 if @battle.state.effects[PBEffects::Gravity]>0
		evastage=-6 if evastage<-6
		evastage=0 if opponent.effects[PBEffects::Foresight] || opponent.effects[PBEffects::MiracleEye] || move.function==0xA9 || attacker.ability == PBAbilities::UNAWARE && !moldBreakerCheck(opponent)
		evasion=(evastage>=0) ? (evastage+3)*100.0/3 : 300.0/(3-evastage)
		# Accuracy modifiers
		if @mondata.skill>=MEDIUMSKILL
			accuracy*=1.3 if attacker.ability == PBAbilities::COMPOUNDEYES
			accuracy*=1.1 if attacker.ability == PBAbilities::VICTORYSTAR
			if @mondata.skill>=HIGHSKILL
				accuracy*=1.1 if attacker.pbPartner.ability == PBAbilities::VICTORYSTAR
				accuracy*=0.8 if attacker.ability == PBAbilities::HUSTLE && move.basedamage>0 && move.pbIsPhysical?(move.pbType(attacker)) && !moldBreakerCheck(opponent)
			end
			if @mondata.skill>=BESTSKILL
				accuracy*=0.9 if attacker.ability == PBAbilities::LONGREACH && (@battle.FE == PBFields::ROCKYF || @battle.FE == PBFields::FORESTF) # Rocky Field # Forest Field
				accuracy*= @battle.FE == PBFields::RAINBOWF ? 0 : 0.5 if opponent.ability == PBAbilities::WONDERSKIN && @basedamage==0 && attacker.pbIsOpposing?(opponent.index) && !moldBreakerCheck(attacker)
				evasion*=1.2 if opponent.ability == PBAbilities::TANGLEDFEET && opponent.effects[PBEffects::Confusion]>0 && !moldBreakerCheck(attacker)
				evasion*=1.2 if (@battle.pbWeather==PBWeather::SANDSTORM || @battle.FE == PBFields::DESERTF || @battle.FE == PBFields::ASHENB) && opponent.ability == PBAbilities::SANDVEIL && !moldBreakerCheck(attacker)
				evasion*=1.2 if (@battle.pbWeather==PBWeather::HAIL || @battle.FE == PBFields::ICYF || @battle.FE == PBFields::SNOWYM) && opponent.ability == PBAbilities::SNOWCLOAK && !moldBreakerCheck(attacker)
			end
			if attacker.itemWorks?
				accuracy*=1.1 if attacker.item == PBItems::WIDELENS
				accuracy*=1.2 if attacker.item == PBItems::ZOOMLENS && attacker.pbSpeed<opponent.pbSpeed
				if attacker.item == PBItems::MICLEBERRY
					accuracy*=1.2 if (attacker.ability == PBAbilities::GLUTTONY && attacker.hp<=(attacker.totalhp/2.0).floor) || attacker.hp<=(attacker.totalhp/4.0).floor
				end
				if @mondata.skill>=HIGHSKILL
					evasion*=1.1 if opponent.item == PBItems::BRIGHTPOWDER
					evasion*=1.1 if opponent.item == PBItems::LAXINCENSE
				end
			end
		end
		evasion = 100 if attacker.ability == PBAbilities::KEENEYE
    	evasion = 100 if @mondata.skill>=BESTSKILL && @battle.FE == PBFields::ASHENB && [PBAbilities::OWNTEMPO,PBAbilities::INNERFOCUS,PBAbilities::PUREPOWER,PBAbilities::SANDVEIL,PBAbilities::STEADFAST].include?(attacker.ability) && opponent.ability != PBAbilities::UNNERVE
		accuracy*=baseaccuracy/evasion.to_f
		accuracy=100 if accuracy>100
		return accuracy
	end

	def pbAIfaster?(attackermove=nil, opponentmove=nil, attacker=@attacker, opponent=@opponent)
		return true if !opponent || opponent.hp == 0
		return false if !attacker || attacker.hp == 0
		return (pbRoughStat(opponent,PBStats::SPEED) < attacker.pbSpeed) ^ (@battle.trickroom!=0) if @mondata.skill < HIGHSKILL
		priorityarray =[[0,0,0,attacker],[0,0,0,opponent]]
		index = -1
		for battler in [attacker, opponent]
			index += 1
			battlermove = (battler==attacker) ? attackermove : opponentmove
			priorityarray[index][1] = -1 if battler.ability == PBAbilities::STALL
			priorityarray[index][1] = 1 if battler.hasWorkingItem(:CUSTAPBERRY) && ((battler.ability == PBAbilities::GLUTTONY && battler.hp<=(battler.totalhp/2.0).floor) || battler.hp<=(battler.totalhp/4.0).floor)
			priorityarray[index][1] = -2 if (battler.itemWorks? && (battler.item == PBItems::LAGGINGTAIL || battler.item == PBItems::FULLINCENSE))
			#speed priority
			priorityarray[index][2] = battler.pbSpeed if @battle.trickroom==0
			priorityarray[index][2] = -battler.pbSpeed if @battle.trickroom>0
			next if !battlermove
			pri = 0
			pri = battlermove.priority if !battlermove.zmove
			pri += 1 if battler.ability == PBAbilities::PRANKSTER && battlermove.basedamage==0 # Is status move
			pri += 1 if battler.ability == PBAbilities::GALEWINGS && battlermove.type==PBTypes::FLYING && ((battler.hp == battler.totalhp) || ((@battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM) && @battle.pbWeather == PBWeather::STRONGWINDS))
			pri += 1 if @battle.FE == PBFields::CHESSB && battler.pokemon && battler.pokemon.piece == :KING
			pri += 3 if battler.ability == PBAbilities::TRIAGE && (PBStuff::HEALFUNCTIONS).include?(battlermove.function)
			priorityarray[index][0] = pri
		end
		priorityarray.sort_by! {|a|[a[0],a[1],a[2]]}
		priorityarray.reverse!
		return false if priorityarray[0][0]==priorityarray[1][0] && priorityarray[0][1]==priorityarray[1][1] && priorityarray[0][2]==priorityarray[1][2]
		return priorityarray[0][3] == attacker
	end

	def pbMoveOrderAI #lol it's just pbPriority
		priorityarray = []
		for i in 0..3
			battler = @battle.battlers[i]
			priorityarray[i] =[0,0,0,i]
			if battler.hp == 0
				priorityarray[i] =[-1,0,0,i]
				next 
			end
			priorityarray[i][0] = 1 if battler.pokemon && battler.pokemon.piece == :KING && @battle.FE == PBFields::CHESSB
			priorityarray[i][1] = -1 if battler.ability == PBAbilities::STALL
			priorityarray[i][1] = 1 if battler.hasWorkingItem(:CUSTAPBERRY) && ((battler.ability == PBAbilities::GLUTTONY && battler.hp<=(battler.totalhp/2.0).floor) || battler.hp<=(battler.totalhp/4.0).floor)
			priorityarray[i][1] = -2 if (battler.itemWorks? && (battler.item == PBItems::LAGGINGTAIL || battler.item == PBItems::FULLINCENSE))
			#speed priority
			priorityarray[i][2] = pbRoughStat(battler,PBStats::SPEED) if @battle.trickroom==0
			priorityarray[i][2] = -pbRoughStat(battler,PBStats::SPEED) if @battle.trickroom>0
		end
		priorityarray.sort!
		priorityarray.reverse!
		moveorderarray = []
		for i in 0..3
			moveorderarray[i] = priorityarray[i][3]
		end
		return moveorderarray
	end

	def hpGainPerTurn(attacker=@attacker)
		healing = 1
		# Negative healing effects
		if @battle.FE == PBFields::BURNINGF && !attacker.isAirborne? && attacker.burningFieldPassiveDamage?
			subscore = 0
			subscore += PBTypes.getCombinedEffectiveness(PBTypes::FIRE,attacker.type1,attacker.type2)/32.0
			subscore*=2.0 if (attacker.ability == PBAbilities::LEAFGUARD) || (attacker.ability == PBAbilities::ICEBODY) || (attacker.ability == PBAbilities::FLUFFY) || (attacker.ability == PBAbilities::GRASSPELT)
			healing -= subscore
		end
		if @battle.FE == PBFields::UNDERWATER && attacker.underwaterFieldPassiveDamamge?
			subscore = 0
			subscore += PBTypes.getCombinedEffectiveness(PBTypes::WATER,attacker.type1,attacker.type2)/32.0
			subscore*=2.0 if (attacker.ability == PBAbilities::FLAMEBODY) || (attacker.ability == PBAbilities::MAGMAARMOR)
			healing -= subscore
		end
		if @battle.FE == PBFields::MURKWATERS && attacker.murkyWaterSurfacePassiveDamage?
			subscore = 0
			subscore += PBTypes.getCombinedEffectiveness(PBTypes::POISON,attacker.type1,attacker.type2)/32.0
			subscore*=2.0 if (attacker.ability == PBAbilities::FLAMEBODY) || (attacker.ability == PBAbilities::MAGMAARMOR) || attacker.ability == PBAbilities::DRYSKIN || attacker.ability == PBAbilities::WATERABSORB
			healing -= subscore
		end
		# Field effect induced
		healing -= 0.125 if @battle.FE == PBFields::CORROSIVEF && (attacker.ability == PBAbilities::GRASSPELT || attacker.ability == PBAbilities::DRYSKIN)
		healing -= 0.125 if @battle.FE == PBFields::DESERTF &&  attacker.ability == PBAbilities::DRYSKIN
		healing -= 0.0625 if attacker.effects[PBEffects::AquaRing] && @battle.FE == PBFields::CORROSIVEMISTF && !attacker.pbHasType?(:STEEL) && !attacker.pbHasType?(:POISON)
		healing -= 0.0625 if attacker.effects[PBEffects::Ingrain] && (@battle.FE == PBFields::SWAMPF || @battle.FE == PBFields::CORROSIVEF) && !(attacker.pbHasType?(:STEEL) || attacker.pbHasType?(:POISON))

		# weather induced
		healing -= 0.125 if @battle.pbWeather == PBWeather::SUNNYDAY && (attacker.ability == PBAbilities::SOLARPOWER || attacker.ability == PBAbilities::DRYSKIN)
		healing -= 0.0625 if @battle.pbWeather == PBWeather::SANDSTORM && !(attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:STEEL))
		healing -= 0.0625 if @battle.pbWeather == PBWeather::HAIL && !attacker.pbHasType?(:ICE)
		
		# Status induced
		healing -= 0.125 if attacker.status == PBStatuses::POISON && attacker.ability != PBAbilities::MAGICGUARD && attacker.ability != PBAbilities::POISONHEAL && attacker.statusCount==0
		healing -= [15,attacker.effects[PBEffects::Toxic]].min / 16.0 if attacker.status == PBStatuses::POISON && attacker.ability != PBAbilities::MAGICGUARD && attacker.ability != PBAbilities::POISONHEAL && attacker.statusCount > 0
		healing -= 0.0625 if attacker.status == PBStatuses::BURN && attacker.ability != PBAbilities::MAGICGUARD

		# Other
		healing -= 0.125 if attacker.effects[PBEffects::LeechSeed]>=0 && attacker.ability != PBAbilities::LIQUIDOOZE
		healing -= 0.125 if @battle.FE == PBFields::WASTELAND && @attacker.effects[PBEffects::LeechSeed]>=0 && attacker.ability != PBAbilities::LIQUIDOOZE
		healing -= 0.25 if attacker.effects[PBEffects::Nightmare] && attacker.ability != PBAbilities::MAGICGUARD && @battle.FE != PBFields::RAINBOWF && attacker.status==PBStatuses::SLEEP
		healing -= 0.25 if attacker.effects[PBEffects::Curse] && attacker.ability != PBAbilities::MAGICGUARD && @battle.FE == PBFields::HOLYF
		healing -= 0.125 if attacker.effects[PBEffects::MultiTurn] > 0
		healing -= 0.125 if attacker.item == PBItems::STICKYBARB && attacker.ability != PBAbilities::MAGICGUARD
		healing -= 0.125 if (attacker.item == PBItems::BLACKSLUDGE && !attacker.pbHasType?(:POISON)) && attacker.ability != PBAbilities::MAGICGUARD

		healing = 0 if healing < 0

		# Positive healing effects
		return healing if attacker.effects[PBEffects::HealBlock]==0
		if attacker.effects[PBEffects::AquaRing]
			subscore = 0
			subscore = 0.0625 if !(@battle.FE == PBFields::CORROSIVEMISTF && !attacker.pbHasType?(:STEEL) && !attacker.pbHasType?(:POISON))
			subscore *= 1.3 if attacker.itemWorks? && attacker.item == PBItems::BIGROOT
			subscore *= 2.0 if @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::SWAMPF || @battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER
			healing += subscore
		end
		if attacker.effects[PBEffects::Ingrain]
			subscore = 0
			subscore = 0.0625 if @battle.FE != 8 && @battle.FE != 10
			subscore = 0.0625 if (@battle.FE == PBFields::SWAMPF || @battle.FE == PBFields::CORROSIVEF) && (attacker.pbHasType?(:STEEL) && attacker.pbHasType?(:POISON))
			subscore *= 1.3 if attacker.itemWorks? && attacker.item == PBItems::BIGROOT
			subscore *= 2.0 if (@battle.FE == PBFields::FORESTF || @battle.FE == PBFields::FLOWERGARDENF)
			subscore *= 2.0 if (@battle.field.counter > 2 && @battle.FE == PBFields::FLOWERGARDENF)
			healing += subscore
		end
		if attacker.ability == PBAbilities::DRYSKIN
			healing += 0.0625 if (@battle.FE == PBFields::CORROSIVEF && (attacker.pbHasType?(:STEEL) || attacker.pbHasType?(:POISON))) || @battle.pbWeather==PBWeather::RAINDANCE || @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::SWAMPF || @battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER
		end
		healing += 0.0625 if attacker.itemWorks? && (attacker.item == PBItems::LEFTOVERS || (attacker.item == PBItems::BLACKSLUDGE && attacker.pbHasType?(:POISON)))
		healing += 0.0625 if attacker.ability == PBAbilities::RAINDISH && @battle.pbWeather==PBWeather::RAINDANCE
		healing += 0.0625 if attacker.ability == PBAbilities::ICEBODY && (@battle.pbWeather==PBWeather::HAIL || @battle.FE == PBFields::ICYF || @battle.FE == PBFields::SNOWYM)
		healing += 0.125 if (attacker.status == PBStatuses::POISON || @battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::WASTELAND) && attacker.ability == PBAbilities::POISONHEAL
		if @battle.FE != 0
			healing += 0.0625 if @battle.FE == PBFields::GRASSYT && !attacker.isAirborne?
			healing += 0.0625 if @battle.FE == PBFields::RAINBOWF && attacker.status == PBStatuses::SLEEP
			healing += 0.0625 if @battle.FE == PBFields::SHORTCIRCUITF && attacker.ability == PBAbilities::VOLTABSORB
			healing += 0.0625 if (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER) && attacker.ability == PBAbilities::WATERABSORB
		end
		return healing
	end

	def pbPartyHasType?(type,index=@index)
		typevar=false
		for mon in @battle.pbParty(index)
			next if mon.nil? || mon.isEgg?
			typevar=true if mon.hp > 0 && mon.hasType?(type)
		end
		return typevar
	end

	def pbTypeModNoMessages(type=@move.type,attacker=@attacker,opponent=@opponent,move=@move,skill=@mondata.skill)
		return 4 if type < 0
		id = move.id
		secondtype = move.fieldTypeChange(attacker,opponent,1,true)
		if !moldBreakerCheck(attacker)
			case opponent.ability
				when PBAbilities::SAPSIPPER 	then return -1 if type == PBTypes::GRASS || secondtype==PBTypes::GRASS
				when PBAbilities::LEVITATE 		then return 0 if type == (PBTypes::GROUND || secondtype==PBTypes::GROUND) && @battle.FE != PBFields::CAVE
				when PBAbilities::STORMDRAIN 	then return -1 if type == PBTypes::WATER || secondtype==PBTypes::WATER
				when PBAbilities::LIGHTNINGROD 	then return -1 if type == PBTypes::ELECTRIC || secondtype==PBTypes::ELECTRIC
				when PBAbilities::MOTORDRIVE 	then return -1 if type == PBTypes::ELECTRIC || secondtype==PBTypes::ELECTRIC
				when PBAbilities::DRYSKIN 		then return -1 if type == PBTypes::WATER || secondtype==PBTypes::WATER && opponent.effects[PBEffects::HealBlock]==0
				when PBAbilities::VOLTABSORB 	then return -1 if type == PBTypes::ELECTRIC || secondtype==PBTypes::ELECTRIC && opponent.effects[PBEffects::HealBlock]==0
				when PBAbilities::WATERABSORB 	then return -1 if type == PBTypes::WATER || secondtype==PBTypes::WATER && opponent.effects[PBEffects::HealBlock]==0
				when PBAbilities::BULLETPROOF 	then return 0 if (PBStuff::BULLETMOVE).include?(id)
				when PBAbilities::FLASHFIRE 	then return -1 if type == PBTypes::FIRE || secondtype==PBTypes::FIRE
				when PBAbilities::MAGMAARMOR 	then return 0 if (type == PBTypes::FIRE || secondtype==PBTypes::FIRE) && @battle.FE == PBFields::DRAGONSD
				when PBAbilities::TELEPATHY 	then return 0 if  move.basedamage>0 && opponent.index == attacker.pbPartner.index
			end
		end
		if @battle.FE == PBFields::ROCKYF && (opponent.effects[PBEffects::Substitute]>0 || opponent.stages[PBStats::EVASION] > 0)
		  	return 0 if (PBStuff::BULLETMOVE).include?(id)
		end
		if (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::MURKWATERS) && (type == PBTypes::GROUND || secondtype==PBTypes::GROUND)
		  	return 0
		end
		if @battle.FE == PBFields::UNDERWATER && (type == PBTypes::FIRE || secondtype==PBTypes::FIRE)
		  	return 0
		end
		if @battle.FE == PBFields::HOLYF && move.basedamage>0 && opponent.index == attacker.pbPartner.index
			return 0
		end
		# UPDATE Implementing Flying Press + Freeze Dry
		faintedcount=0
		for i in @battle.pbPartySingleOwner(opponent.index)
			next if i.nil?
			faintedcount+=1 if (i.hp==0 && i.hp!=0)
		end
		if opponent.effects[PBEffects::Illusion]
			if skill>=BESTSKILL
				zorovar = !(opponent.turncount>1 || faintedcount>2)
				moveinfo = $cache.pkmn_move[attacker.lastMoveUsed]
				zorovar = false if opponent.turncount > 0 && moveinfo[PBMoveData::BASEDAMAGE]>0 && moveinfo[PBMoveData::TYPE] == PBTypes::PSYCHIC
			elsif skill>= MEDIUMSKILL
				zorovar = !(faintedcount>4)
			else
				zorovar = true
			end
		else
		  	zorovar=false
		end
		typemod=move.pbTypeModifier(type,attacker,opponent,zorovar)
		typemod*= 2 if type == PBTypes::WATER && (opponent.pbHasType?(PBTypes::WATER)) && @battle.FE == PBFields::UNDERWATER
		if @battle.FE == PBFields::GLITCHF
			typemod = 4 if type == PBTypes::DRAGON
			typemod = 0 if type == PBTypes::GHOST && (opponent.pbHasType?(PBTypes::PSYCHIC))
			typemod*= 4 if type == PBTypes::BUG && (opponent.pbHasType?(PBTypes::POISON))
			typemod*= 2 if type == PBTypes::ICE && (opponent.pbHasType?(PBTypes::FIRE))
			typemod*= 2 if type == PBTypes::POISON && (opponent.pbHasType?(PBTypes::BUG))
		end
		typemod*= 4 if id == PBMoves::FREEZEDRY && (opponent.pbHasType?(PBTypes::WATER))
		typemod*= 2 if id == PBMoves::CUT && (opponent.pbHasType?(PBTypes::GRASS)) && (@battle.FE == PBFields::FORESTF || (@battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter > 0))
		if id == PBMoves::FLYINGPRESS
			typemod2=move.pbTypeModifier(PBTypes::FLYING,attacker,opponent,zorovar)
			typemod3= ((typemod*typemod2)/4.0)
			typemod=typemod3
		end
		typemod=0 if opponent.ability==PBAbilities::WONDERGUARD && !moldBreakerCheck(attacker) && typemod <= 4
		
		# Field Effect type changes go here
		typemod=move.fieldTypeChange(attacker,opponent,typemod,false)

		# Cutting super effectiveness in half
		if @battle.pbWeather==PBWeather::STRONGWINDS && ((opponent.pbHasType?(PBTypes::FLYING)) && !opponent.effects[PBEffects::Roost]) &&
			(PBTypes.getEffectiveness(type, PBTypes::FLYING) > 2) ^ (PBTypes.getEffectiveness(type, PBTypes::FLYING) < 2 && ($game_switches[:Inversemode] ^ (@battle.FE == PBFields::INVERSEF)))
		  	typemod /= 2
		end
		if @battle.FE == PBFields::DRAGONSD && opponent.ability == PBAbilities::MULTISCALE && # Dragons Den Multiscale
		 (type == PBTypes::FAIRY || type == PBTypes::ICE || type == PBTypes::DRAGON) && !moldBreakerCheck(attacker)
		  	typemod /= 2
		end
		if @battle.FE == PBFields::FLOWERGARDENF && opponent.pbHasType?(PBTypes::GRASS) && @battle.field.counter >= 3 &&
			[PBTypes::FIRE, PBTypes::FLYING, PBTypes::BUG, PBTypes::POISON, PBTypes::ICE].include?(type)
			typemod /= 2
		end
		return 1 if typemod==0 && move.function==0x111
		return typemod
	end

	#@scorearray = [[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]
	def getMaxScoreIndex(scores)
		maxscore=scores.max {|a,b| a.max <=> b.max}
		maxscoreindex = scores.find_index {|score| score == maxscore}
		return [maxscoreindex,scores[maxscoreindex].find_index {|score| score == scores[maxscoreindex].max}]
	end

	def pbChangeMove(move,attacker)
		return move unless [PBMoves::WEATHERBALL, PBMoves::HIDDENPOWER, PBMoves::NATUREPOWER].include?(move.id)
		attacker = @opponent if caller_locations.any? {|call| call.label=="buildMoveScores"} && attacker.nil?
		#make new instance of move
		move = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(move.id),attacker)
		case move.id
			when PBMoves::WEATHERBALL
				weather=@battle.pbWeather
				move.type=(PBTypes::NORMAL)
				move.type=PBTypes::FIRE if (weather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
				move.type=PBTypes::WATER if (weather==PBWeather::RAINDANCE && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
				move.type=PBTypes::ROCK if weather==PBWeather::SANDSTORM
				move.type=PBTypes::ICE if weather==PBWeather::HAIL
				move.basedamage*=2 if @battle.pbWeather !=0 || @battle.FE == PBFields::RAINBOWF && move.basedamage == 50
		
			when PBMoves::HIDDENPOWER
				move.type = move.pbType(attacker) if attacker
		
			when PBMoves::NATUREPOWER
				move = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@battle.field.naturePower),attacker)
				move.priority = 1 if attacker.ability == PBAbilities::PRANKSTER
		end
		return move
	end

	def scoreDecrease(threat_index, killable, decreased_by, ai_leader)
		if killable[ai_leader] == :both
			# changing scoring for leader on mon that the leader doesn't kill
			@aimondata[ai_leader].scorearray[threat_index^2].map! {|score| score>80 ? 80 : score }
			# decreasing score for follower on mon that the leader kills
			@aimondata[ai_leader^2].scorearray[threat_index].map! {|score| score * decreased_by} 
		elsif killable[ai_leader] == :left
			@aimondata[ai_leader^2].scorearray[0].map! {|score| score * decreased_by}
		elsif killable[ai_leader] == :right
			@aimondata[ai_leader^2].scorearray[2].map! {|score| score * decreased_by}
		end
	end

	def totalHazardDamage(pkmn)
		percentdamage = 0
		if pkmn.pbOwnSide.effects[PBEffects::Spikes]>0 && !pkmn.isAirborne? && !pkmn.ability == PBAbilities::MAGICGUARD && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
			spikesdiv=[8,8,6,4][pkmn.pbOwnSide.effects[PBEffects::Spikes]]
			percentdamage += (100.0/spikesdiv).floor
		end
		if pkmn.pbOwnSide.effects[PBEffects::StealthRock] && !pkmn.ability == PBAbilities::MAGICGUARD && !pkmn.hasWorkingItem(:HEAVYDUTYBOOTS)
			eff=PBTypes.getCombinedEffectiveness(PBTypes::ROCK,pkmn.type1,pkmn.type2)
			if @mondata.skill>BESTSKILL && @battle.FE == PBFields::CRYSTALC
				eff1=PBTypes.getCombinedEffectiveness(PBTypes::WATER,pkmn.type1,pkmn.type2)
				eff2=PBTypes.getCombinedEffectiveness(PBTypes::GRASS,pkmn.type1,pkmn.type2)
				eff3=PBTypes.getCombinedEffectiveness(PBTypes::FIRE,pkmn.type1,pkmn.type2)
				eff4=PBTypes.getCombinedEffectiveness(PBTypes::PSYCHIC,pkmn.type1,pkmn.type2)
				eff = [eff1,eff2,eff3,eff4].max
			end
			if eff>0
				eff*=2 if @mondata.skill>BESTSKILL && (@battle.FE == PBFields::ROCKYF || @battle.FE == PBFields::CAVE)
				percentdamage += 100*(eff/32.0)
			end
		end
		if @mondata.skill>=BESTSKILL
			# Corrosive Field Entry
			if @battle.FE == PBFields::CORROSIVEF
				if ![PBAbilities::MAGICGUARD, PBAbilities::POISONHEAL, PBAbilities::IMMUNITY, PBAbilities::WONDERGUARD, PBAbilities::TOXICBOOST].include?(pkmn.ability)
					if !pkmn.isAirborne? && !pkmn.pbHasType?(:POISON) && !pkmn.pbHasType?(:STEEL)
						eff=PBTypes.getCombinedEffectiveness(PBTypes::POISON,pkmn.type1,pkmn.type2)
						eff*=2
						percentdamage += 100*(eff/32.0)
					end
				end
			# Icy field + Seed activation spike damage
			elsif @battle.FE == PBFields::ICYF
				if pkmn.item == PBItems::ELEMENTALSEED && pkmn.ability != PBAbilities::KLUTZ && !pkmn.isAirborne? && pkmn.ability != PBAbilities::MAGICGUARD
					spikesdiv=[8,8,6,4][pkmn.pbOwnSide.effects[PBEffects::Spikes]]
					percentdamage += (100.0/spikesdiv).floor
				end
			# Cave field + Seed activation stealth rock damage
			elsif @battle.FE == PBFields::CAVE
				if pkmn.item == PBItems::TELLURICSEED && pkmn.ability != PBAbilities::KLUTZ && pkmn.ability != PBAbilities::MAGICGUARD
					eff=PBTypes.getCombinedEffectiveness(PBTypes::ROCK,pkmn.type1,pkmn.type2)
					if eff>0
						eff = eff*2
						percentdamage += 100*(eff/32.0)
					end
				end
			end
		end
		return percentdamage
	end

	def getAbilityDisruptScore(attacker,opponent)
		abilityscore=100.0
		return (abilityscore/100) if opponent.ability == 0 #if the ability doesn't work, then nothing here matters
		case opponent.ability
			when PBAbilities::SPEEDBOOST
				abilityscore*=1.1
				abilityscore*=1.3 if opponent.stages[PBStats::SPEED]<2
			when PBAbilities::SANDVEIL
				abilityscore*=1.3 if @battle.pbWeather==PBWeather::SANDSTORM
			when PBAbilities::VOLTABSORB, PBAbilities::LIGHTNINGROD, PBAbilities::MOTORDRIVE
				for i in attacker.moves
					next if i.nil?
					elecmove=i if i.pbType(attacker)==PBTypes::ELECTRIC
				end
				if attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::ELECTRIC}
					abilityscore*=3 if attacker.moves.all? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::ELECTRIC}
					abilityscore*=2 if pbTypeModNoMessages(elecmove.pbType(attacker),attacker,opponent,elecmove)>4
				end
			when PBAbilities::WATERABSORB, PBAbilities::STORMDRAIN, PBAbilities::DRYSKIN
				for i in attacker.moves
					next if i.nil?
					watermove=i if i.pbType(attacker)==PBTypes::WATER
				end
				if attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::WATER}
					abilityscore*=3 if attacker.moves.all? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::WATER}
					abilityscore*=2 if pbTypeModNoMessages(watermove.pbType(attacker),attacker,opponent,watermove)>4
				end
				abilityscore*=0.5 if opponent.ability == PBAbilities::DRYSKIN && attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::FIRE}
			when PBAbilities::SAPSIPPER
				for i in attacker.moves
					next if i.nil?
					grassmove=i if i.pbType(attacker) == PBTypes::GRASS
				end
				if attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::GRASS}
					abilityscore*=3 if attacker.moves.all? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::GRASS}
					abilityscore*=2 if pbTypeModNoMessages(grassmove.pbType(attacker),attacker,opponent,grassmove)>4
				end
			when PBAbilities::FLASHFIRE
				for i in attacker.moves
					next if i.nil?
					firemove=i if i.pbType(attacker) == PBTypes::FIRE
				end
				if attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::FIRE}
					abilityscore*=3 if attacker.moves.all? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::FIRE}
					abilityscore*=2 if pbTypeModNoMessages(firemove.pbType(attacker),attacker,opponent,firemove)>4
				end
			when PBAbilities::LEVITATE
				for i in attacker.moves
					next if i.nil?
					groundmove=i if i.pbType(attacker) == PBTypes::GROUND
				end
				if attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::GROUND}
					abilityscore*=3 if attacker.moves.all? {|moveloop| moveloop!=nil && moveloop.pbType(attacker) == PBTypes::GROUND}
					abilityscore*=2 if pbTypeModNoMessages(groundmove.pbType(attacker),attacker,opponent,groundmove)>4
				end
			when PBAbilities::SHADOWTAG
				abilityscore*=1.5 if !attacker.hasType?(PBTypes::GHOST)
			when PBAbilities::ARENATRAP
				abilityscore*=1.5 if attacker.isAirborne?
			when PBAbilities::WONDERGUARD
				abilityscore*=5 if !attacker.moves.any? {|moveloop| moveloop!=nil && pbTypeModNoMessages(moveloop.pbType(attacker),attacker,opponent,moveloop)>4}
			when PBAbilities::SERENEGRACE
				abilityscore*=1.3
			when PBAbilities::PUREPOWER, PBAbilities::HUGEPOWER
				abilityscore*=2
			when PBAbilities::SOUNDPROOF
				abilityscore*=3 if attacker.moves.all? {|moveloop| moveloop!=nil && (moveloop.isSoundBased? || moveloop.basedamage==0)}
			when PBAbilities::THICKFAT
				abilityscore*=1.5 if attacker.moves.all? {|moveloop| moveloop!=nil && (moveloop.pbType(attacker) == PBTypes::FIRE || moveloop.pbType(attacker) == PBTypes::ICE) }
			when PBAbilities::TRUANT
				abilityscore*=0.1
			when PBAbilities::GUTS, PBAbilities::QUICKFEET, PBAbilities::MARVELSCALE
				abilityscore*=1.5 if opponent.status!=0
			when PBAbilities::LIQUIDOOZE
				abilityscore*=2 if opponent.effects[PBEffects::LeechSeed]>=0 || attacker.pbHasMove?(PBMoves::LEECHSEED)
			when PBAbilities::AIRLOCK, PBAbilities::CLOUDNINE
				abilityscore*=1.1
			when PBAbilities::HYDRATION
				abilityscore*=1.3 if hydrationCheck(attacker)
			when PBAbilities::ADAPTABILITY
				abilityscore*=1.3
			when PBAbilities::SKILLLINK
				abilityscore*=1.5
			when PBAbilities::POISONHEAL
				abilityscore*=2 if opponent.status==PBStatuses::POISON
			when PBAbilities::NORMALIZE
				abilityscore*=0.6
			when PBAbilities::MAGICGUARD
				abilityscore*=1.4
			when PBAbilities::STALL
				abilityscore*=0.5
			when PBAbilities::TECHNICIAN
				abilityscore*=1.3
			when PBAbilities::MOLDBREAKER, PBAbilities::TERAVOLT, PBAbilities::TURBOBLAZE
				abilityscore*=1.1
			when PBAbilities::UNAWARE
				abilityscore*=1.7
			when PBAbilities::SLOWSTART
				abilityscore*=0.3
			when PBAbilities::MULTITYPE, PBAbilities::STANCECHANGE, PBAbilities::SCHOOLING, PBAbilities::SHIELDSDOWN, PBAbilities::DISGUISE, PBAbilities::RKSSYSTEM, PBAbilities::POWERCONSTRUCT
				abilityscore*=0
			when PBAbilities::SHEERFORCE
				abilityscore*=1.2
			when PBAbilities::CONTRARY
				abilityscore*=1.4
				abilityscore*=2 if opponent.stages[PBStats::ATTACK]>0 || opponent.stages[PBStats::SPATK]>0 || opponent.stages[PBStats::DEFENSE]>0 || opponent.stages[PBStats::SPDEF]>0 || opponent.stages[PBStats::SPEED]>0
			when PBAbilities::DEFEATIST
				abilityscore*=0.5
			when PBAbilities::MULTISCALE
				abilityscore*=1.5 if opponent.hp==opponent.totalhp
			when PBAbilities::HARVEST
				abilityscore*=1.2
			when PBAbilities::MOODY
				abilityscore*=1.8
			when PBAbilities::PRANKSTER
				abilityscore*=1.5 if pbAIfaster?(nil,nil,attacker,opponent)
			when PBAbilities::SNOWCLOAK
				abilityscore*=1.1 if @battle.pbWeather==PBWeather::HAIL
			when PBAbilities::FURCOAT
				abilityscore*=1.5 if attacker.attack>attacker.spatk
			when PBAbilities::PARENTALBOND
				abilityscore*=3
			when PBAbilities::PROTEAN
				abilityscore*=3
			when PBAbilities::TOUGHCLAWS
				abilityscore*=1.2
			when PBAbilities::BEASTBOOST
				abilityscore*=1.1
			when PBAbilities::COMATOSE
				abilityscore*=1.3
			when PBAbilities::FLUFFY
				abilityscore*=1.5
				abilityscore*=0.5 if attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(attacker)==PBTypes::FIRE}
			when PBAbilities::MERCILESS
				abilityscore*=1.3
			when PBAbilities::WATERBUBBLE
				abilityscore*=1.5
				abilityscore*=1.3 if attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.pbType(attacker)==PBTypes::FIRE}
			else
				if attacker.pbPartner==opponent && abilityscore!=0
					abilityscore=200 if abilityscore>200
					tempscore = abilityscore
					abilityscore = 200 - tempscore
				end
		end
		abilityscore*=0.01
		return abilityscore
	end

	def getFieldDisruptScore(attacker=@attacker,opponent=@opponent,fieldeffect=@battle.FE, violent=false)
		fieldscore=100.0
		aroles = pbGetMonRoles(attacker)
		oroles = pbGetMonRoles(opponent)
		aimem = getAIMemory(opponent)
		case fieldeffect
			when PBFields::NONE # No field
			when PBFields::ELECTRICT # Electric Terrain
				fieldscore*=1.5 if opponent.pbHasType?(:ELECTRIC) || opponent.pbPartner.pbHasType?(:ELECTRIC)
				fieldscore*=0.5 if attacker.pbHasType?(:ELECTRIC)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::ELECTRIC)
				fieldscore*=1.3 if opponent.ability == PBAbilities::SURGESURFER
				fieldscore*=0.7 if attacker.ability == PBAbilities::SURGESURFER
			when PBFields::GRASSYT # Grassy Terrain
				fieldscore*=1.5 if opponent.pbHasType?(:GRASS) || opponent.pbPartner.pbHasType?(:GRASS)
				fieldscore*=0.5 if attacker.pbHasType?(:GRASS)
				fieldscore*=1.8 if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
				fieldscore*=0.2 if attacker.pbHasType?(:FIRE)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::GRASS)
				fieldscore*=0.2 if pbPartyHasType?(PBTypes::FIRE)
				fieldscore*=0.8 if aroles.include?(PBMonRoles::SPECIALWALL) || aroles.include?(PBMonRoles::PHYSICALWALL)
				fieldscore*=1.2 if oroles.include?(PBMonRoles::SPECIALWALL) || oroles.include?(PBMonRoles::PHYSICALWALL)
			when PBFields::MISTYT # Misty Terrain
				fieldscore*=1.3 if attacker.spatk>attacker.attack && (opponent.pbHasType?(:FAIRY) || opponent.pbPartner.pbHasType?(:FAIRY))
				fieldscore*=0.7 if attacker.pbHasType?(:FAIRY) && opponent.spatk>opponent.attack
				fieldscore*=0.5 if opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON)
				fieldscore*=1.5 if attacker.pbHasType?(:DRAGON)
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::FAIRY)
				fieldscore*=1.5 if pbPartyHasType?(PBTypes::DRAGON)
				fieldscore*=1.8 if @battle.field.counter==1 && (!(attacker.pbHasType?(:POISON) || attacker.pbHasType?(:STEEL)))
			when PBFields::DARKCRYSTALC # Dark Crystal Cavern
				fieldscore*=1.3 if opponent.pbHasType?(:DARK) || opponent.pbPartner.pbHasType?(:DARK) || opponent.pbHasType?(:GHOST) || opponent.pbPartner.pbHasType?(:GHOST)
				fieldscore*=0.7 if attacker.pbHasType?(:DARK) || attacker.pbHasType?(:GHOST)
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::DARK) || pbPartyHasType?(PBTypes::GHOST)
			when PBFields::CHESSB # Chess field
				fieldscore*=1.3 if opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
				fieldscore*=0.7 if attacker.pbHasType?(:PSYCHIC)
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::PSYCHIC)
				fieldscore*= attacker.pbSpeed>opponent.pbSpeed ? 1.3 : 0.7
			when PBFields::BIGTOPA # Big Top field
				fieldscore*=1.5 if opponent.pbHasType?(:FIGHTING) || opponent.pbPartner.pbHasType?(:FIGHTING)
				fieldscore*=0.5 if attacker.pbHasType?(:FIGHTING)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::FIGHTING)
				fieldscore*=1.5 if opponent.ability == PBAbilities::DANCER
				fieldscore*=0.5 if attacker.ability == PBAbilities::DANCER
				fieldscore*=0.5 if attacker.pbHasMove?(PBMoves::SING) || attacker.pbHasMove?(PBMoves::DRAGONDANCE) || attacker.pbHasMove?(PBMoves::QUIVERDANCE)
				fieldscore*=1.5 if checkAImoves([PBMoves::SING,PBMoves::DRAGONDANCE,PBMoves::QUIVERDANCE],aimem)
			when PBFields::BURNINGF # Burning Field
				fieldscore*=1.8 if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
				if attacker.pbHasType?(:FIRE)
					fieldscore*=0.2
				else
					fieldscore*=1.5
					fieldscore*=1.8 if attacker.pbHasType?(:GRASS) || attacker.pbHasType?(:ICE) || attacker.pbHasType?(:BUG) || attacker.pbHasType?(:STEEL)
				end
				fieldscore*=0.2 if pbPartyHasType?(PBTypes::FIRE)
				fieldscore*=1.5 if pbPartyHasType?(PBTypes::GRASS) || pbPartyHasType?(PBTypes::ICE) || pbPartyHasType?(PBTypes::BUG) || pbPartyHasType?(PBTypes::STEEL)
			when PBFields::SWAMPF # Swamp field
				fieldscore*=0.7 if attacker.pbHasMove?(PBMoves::SLEEPPOWDER)
				fieldscore*=1.3 if checkAImoves([PBMoves::SLEEPPOWDER],aimem)
			when PBFields::RAINBOWF # Rainbow field
				fieldscore*=1.5 if opponent.pbHasType?(:NORMAL) || opponent.pbPartner.pbHasType?(:NORMAL)
				fieldscore*=0.5 if attacker.pbHasType?(:NORMAL)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::NORMAL)
				fieldscore*=1.4 if opponent.ability == PBAbilities::CLOUDNINE
				fieldscore*=0.6 if attacker.ability == PBAbilities::CLOUDNINE
				fieldscore*=0.8 if attacker.pbHasMove?(PBMoves::SONICBOOM)
				fieldscore*=1.2 if checkAImoves([PBMoves::SONICBOOM],aimem)
			when PBFields::CORROSIVEF # Corrosive field
				fieldscore*=1.3 if opponent.pbHasType?(:POISON) || opponent.pbPartner.pbHasType?(:POISON)
				fieldscore*=0.7 if attacker.pbHasType?(:POISON)
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::POISON)
				fieldscore*=1.5 if opponent.ability == PBAbilities::CORROSION
				fieldscore*=0.5 if attacker.ability == PBAbilities::CORROSION
				fieldscore*=0.7 if attacker.pbHasMove?(PBMoves::SLEEPPOWDER)
				fieldscore*=1.3 if checkAImoves([PBMoves::SLEEPPOWDER],aimem)
			when PBFields::CORROSIVEMISTF # Corromist field
				if violent
					if !PBStuff::INVULEFFECTS.any? {|eff| opponent.effects[eff] == true } && !(PBStuff::TWOTURNMOVE.include?(opponent.effects[PBEffects::TwoTurnAttack]) && pbAIfaster?(nil,nil,attacker,opponent)) && opponent.ability != PBAbilities::FLASHFIRE 
						fieldscore*=2 if (attacker.hp.to_f)/attacker.totalhp<0.2
						fieldscore*=5 if opponent.pbNonActivePokemonCount==0
					end
				end
				fieldscore*=1.3 if opponent.pbHasType?(:POISON) || opponent.pbPartner.pbHasType?(:POISON)
				if attacker.pbHasType?(:POISON)
					fieldscore*=0.7
				elsif !attacker.pbHasType?(:STEEL)
					fieldscore*=1.4
				end
				fieldscore*=1.4 if !pbPartyHasType?(PBTypes::POISON)
				fieldscore*=1.5 if opponent.ability == PBAbilities::CORROSION
				fieldscore*=0.5 if attacker.ability == PBAbilities::CORROSION
				fieldscore*=1.5 if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
				fieldscore*=0.8  if attacker.pbHasType?(:FIRE)
				fieldscore*=0.8  if pbPartyHasType?(PBTypes::FIRE)
			when PBFields::DESERTF # Desert field
				fieldscore*=1.3 if attacker.spatk > attacker.attack && (opponent.pbHasType?(:GROUND) || opponent.pbPartner.pbHasType?(:GROUND))
				fieldscore*=0.7 if opponent.spatk > opponent.attack && (attacker.pbHasType?(:GROUND))
				fieldscore*=1.5 if attacker.pbHasType?(:ELECTRIC) || attacker.pbHasType?(:WATER)
				fieldscore*=0.5 if opponent.pbHasType?(:ELECTRIC) || opponent.pbPartner.pbHasType?(:WATER)
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::GROUND)
				fieldscore*=1.5 if pbPartyHasType?(PBTypes::WATER) || pbPartyHasType?(PBTypes::ELECTRIC)
				fieldscore*=1.3 if opponent.ability == PBAbilities::SANDRUSH && @battle.pbWeather!=PBWeather::SANDSTORM
				fieldscore*=0.7 if attacker.ability == PBAbilities::SANDRUSH && @battle.pbWeather!=PBWeather::SANDSTORM
			when PBFields::ICYF # Icy field
				fieldscore*=1.3 if opponent.pbHasType?(:ICE) || opponent.pbPartner.pbHasType?(:ICE)
				fieldscore*=0.5 if attacker.pbHasType?(:ICE)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::ICE)
				fieldscore*=0.5 if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
				fieldscore*=1.1 if attacker.pbHasType?(:FIRE)
				fieldscore*=1.1 if pbPartyHasType?(PBTypes::FIRE)
				fieldscore*=1.3 if opponent.ability == PBAbilities::SLUSHRUSH && @battle.pbWeather!=PBWeather::HAIL
				fieldscore*=0.7 if attacker.ability == PBAbilities::SLUSHRUSH && @battle.pbWeather!=PBWeather::HAIL
			when PBFields::ROCKYF # Rocky field
				fieldscore*=1.5 if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK)
				fieldscore*=0.5 if attacker.pbHasType?(:ROCK)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::ROCK)
			when PBFields::FORESTF # Forest field
				fieldscore*=1.5 if opponent.pbHasType?(:GRASS) || opponent.pbHasType?(:BUG) || opponent.pbPartner.pbHasType?(:GRASS) || opponent.pbPartner.pbHasType?(:BUG)
				fieldscore*=0.5 if attacker.pbHasType?(:GRASS) || attacker.pbHasType?(:BUG)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::GRASS) || pbPartyHasType?(PBTypes::BUG)
				fieldscore*=1.8 if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
				fieldscore*=0.2 if attacker.pbHasType?(:FIRE)
				fieldscore*=0.2 if pbPartyHasType?(PBTypes::FIRE)
			when PBFields::SUPERHEATEDF # Superheated field
				fieldscore*=1.8 if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
				fieldscore*=0.2 if attacker.pbHasType?(:FIRE)
				fieldscore*=0.2 if pbPartyHasType?(PBTypes::FIRE)
				fieldscore*=0.7 if opponent.pbHasType?(:ICE) || opponent.pbPartner.pbHasType?(:ICE)
				fieldscore*=1.5 if attacker.pbHasType?(:ICE)
				fieldscore*=1.5 if pbPartyHasType?(PBTypes::ICE)
				fieldscore*=0.8 if opponent.pbHasType?(:WATER) || opponent.pbPartner.pbHasType?(:WATER)
				fieldscore*=1.2 if attacker.pbHasType?(:WATER)
				fieldscore*=1.2 if pbPartyHasType?(PBTypes::WATER)
			when PBFields::FACTORYF # Factory field
				fieldscore*=1.2 if opponent.pbHasType?(:ELECTRIC) || opponent.pbPartner.pbHasType?(:ELECTRIC)
				fieldscore*=0.8 if attacker.pbHasType?(:ELECTRIC)
				fieldscore*=0.8 if pbPartyHasType?(PBTypes::ELECTRIC)
			when PBFields::SHORTCIRCUITF # Short-Circuit field
				fieldscore*=1.4 if opponent.pbHasType?(:ELECTRIC) || opponent.pbPartner.pbHasType?(:ELECTRIC)
				fieldscore*=0.6 if attacker.pbHasType?(:ELECTRIC)
				fieldscore*=0.6 if pbPartyHasType?(PBTypes::ELECTRIC)
				fieldscore*=1.3 if opponent.ability == PBAbilities::SURGESURFER
				fieldscore*=0.7 if attacker.ability == PBAbilities::SURGESURFER
				fieldscore*=1.3 if opponent.pbHasType?(:DARK) || opponent.pbPartner.pbHasType?(:DARK) || opponent.pbHasType?(:GHOST) || opponent.pbPartner.pbHasType?(:GHOST)
				fieldscore*=0.7 if attacker.pbHasType?(:DARK) || attacker.pbHasType?(:GHOST)
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::DARK) || pbPartyHasType?(PBTypes::GHOST)
			when PBFields::WASTELAND # Wasteland field
				fieldscore*=1.3 if opponent.pbHasType?(:POISON) || opponent.pbPartner.pbHasType?(:POISON)
				fieldscore*=0.7 if attacker.pbHasType?(:POISON)
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::POISON)
			when PBFields::ASHENB # Ashen Beach field
				fieldscore*=1.3 if opponent.pbHasType?(:FIGHTING) || opponent.pbPartner.pbHasType?(:FIGHTING) || opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
				fieldscore*=0.7 if attacker.pbHasType?(:FIGHTING) || attacker.pbHasType?(:PSYCHIC)
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::FIGHTING) || pbPartyHasType?(PBTypes::PSYCHIC)
				fieldscore*=1.3 if opponent.ability == PBAbilities::SANDRUSH && @battle.pbWeather!=PBWeather::SANDSTORM
				fieldscore*=0.7 if attacker.ability == PBAbilities::SANDRUSH && @battle.pbWeather!=PBWeather::SANDSTORM
			when PBFields::WATERS # Water Surface field
				fieldscore*=1.6 if opponent.pbHasType?(:WATER) || opponent.pbPartner.pbHasType?(:WATER)
				if attacker.pbHasType?(:WATER)
					fieldscore*=0.4
				elsif !attacker.isAirborne?
					fieldscore*=1.3
				end
				fieldscore*=0.4 if pbPartyHasType?(PBTypes::WATER)
				fieldscore*=1.3 if opponent.ability == PBAbilities::SWIFTSWIM && @battle.pbWeather!=PBWeather::RAINDANCE
				fieldscore*=0.7 if attacker.ability == PBAbilities::SWIFTSWIM && @battle.pbWeather!=PBWeather::RAINDANCE
				fieldscore*=1.3 if opponent.ability == PBAbilities::SURGESURFER
				fieldscore*=0.7 if attacker.ability == PBAbilities::SURGESURFER
				fieldscore*=1.3 if !attacker.pbHasType?(:POISON) && @battle.field.counter==1
			when PBFields::UNDERWATER # Underwater field
				fieldscore*=2.0 if opponent.pbHasType?(:WATER) || opponent.pbPartner.pbHasType?(:WATER)
				if attacker.pbHasType?(:WATER)
					fieldscore*=0.1
				else
					fieldscore*=1.5
					fieldscore*=2 if attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND)
				end
				fieldscore*=1.2 if attacker.attack > attacker.spatk
				fieldscore*=0.8 if opponent.attack > opponent.spatk
				fieldscore*=0.1 if pbPartyHasType?(PBTypes::WATER)
				fieldscore*=0.9 if opponent.ability == PBAbilities::SWIFTSWIM
				fieldscore*=1.1 if attacker.ability == PBAbilities::SWIFTSWIM
				fieldscore*=1.1 if opponent.ability == PBAbilities::SURGESURFER
				fieldscore*=0.9 if attacker.ability == PBAbilities::SURGESURFER
				fieldscore*=1.3 if !attacker.pbHasType?(:POISON) && @battle.field.counter==1
			when PBFields::CAVE # Cave field
				fieldscore*=1.5 if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK)
				fieldscore*=0.5 if attacker.pbHasType?(:ROCK)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::ROCK)
				fieldscore*=1.2 if opponent.pbHasType?(:GROUND) || opponent.pbPartner.pbHasType?(:GROUND)
				fieldscore*=0.8 if attacker.pbHasType?(:GROUND)
				fieldscore*=0.8 if pbPartyHasType?(PBTypes::GROUND)
				fieldscore*=0.7 if opponent.pbHasType?(:FLYING) || opponent.pbPartner.pbHasType?(:FLYING)
				fieldscore*=1.3 if attacker.pbHasType?(:FLYING)
				fieldscore*=1.3 if pbPartyHasType?(PBTypes::FLYING)
			when PBFields::GLITCHF # Glitch field
				fieldscore*=1.3 if attacker.pbHasType?(:DARK) || attacker.pbHasType?(:STEEL) || attacker.pbHasType?(:FAIRY)
				fieldscore*=1.3 if pbPartyHasType?(PBTypes::DARK) || pbPartyHasType?(PBTypes::STEEL) || pbPartyHasType?(PBTypes::FAIRY)
				ratio1 = attacker.spatk/attacker.spdef.to_f
				ratio2 = attacker.spdef/attacker.spatk.to_f
				if ratio1 < 1
					fieldscore*=ratio1
				elsif ratio2 < 1
					fieldscore*=ratio2
				end
				oratio1 = opponent.spatk/attacker.spdef.to_f
				oratio2 = opponent.spdef/attacker.spatk.to_f
				if oratio1 > 1
					fieldscore*=oratio1
				elsif oratio2 > 1
					fieldscore*=oratio2
				end
			when PBFields::CRYSTALC # Crystal Cavern field
				fieldscore*=1.5 if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK) || opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON)
				fieldscore*=0.5 if attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:DRAGON)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::ROCK) || pbPartyHasType?(PBTypes::DRAGON)
			when PBFields::MURKWATERS # Murkwater Surface field
				fieldscore*=1.6 if opponent.pbHasType?(:WATER) || opponent.pbPartner.pbHasType?(:WATER)
				if attacker.pbHasType?(:WATER)
					fieldscore*=0.4 
				elsif !attacker.isAirborne?
					fieldscore*=1.3
				end
				fieldscore*=0.4 if pbPartyHasType?(PBTypes::WATER)
				fieldscore*=1.3 if opponent.ability == PBAbilities::SWIFTSWIM && @battle.pbWeather!=PBWeather::RAINDANCE
				fieldscore*=0.7 if attacker.ability == PBAbilities::SWIFTSWIM && @battle.pbWeather!=PBWeather::RAINDANCE
				fieldscore*=1.3 if opponent.ability == PBAbilities::SURGESURFER
				fieldscore*=0.7 if attacker.ability == PBAbilities::SURGESURFER
				fieldscore*=1.3 if opponent.pbHasType?(:STEEL) || opponent.pbPartner.pbHasType?(:STEEL) || opponent.pbHasType?(:POISON) || opponent.pbPartner.pbHasType?(:POISON)
				if attacker.pbHasType?(:POISON)
					fieldscore*=0.7
				elsif !attacker.pbHasType?(:STEEL)
					fieldscore*=1.8
				end
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::POISON)
			when PBFields::MOUNTAIN # Mountain field
				fieldscore*=1.5 if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK) || opponent.pbHasType?(:FLYING) || opponent.pbPartner.pbHasType?(:FLYING)
				fieldscore*=0.5 if attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:FLYING)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::ROCK) || pbPartyHasType?(PBTypes::FLYING)
			when PBFields::SNOWYM # Snowy Mountain field
				fieldscore*=1.5 if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK) || opponent.pbHasType?(:FLYING) || opponent.pbPartner.pbHasType?(:FLYING) || opponent.pbHasType?(:ICE) || opponent.pbPartner.pbHasType?(:ICE)
				fieldscore*=0.5 if attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:FLYING) || attacker.pbHasType?(:ICE)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::ROCK) || pbPartyHasType?(PBTypes::FLYING) || pbPartyHasType?(PBTypes::ICE)
				fieldscore*=0.5 if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
				fieldscore*=1.5 if attacker.pbHasType?(:FIRE)
				fieldscore*=1.5 if pbPartyHasType?(PBTypes::FIRE)
				fieldscore*=1.3 if opponent.ability == PBAbilities::SLUSHRUSH && @battle.pbWeather!=PBWeather::HAIL
				fieldscore*=0.7 if attacker.ability == PBAbilities::SLUSHRUSH && @battle.pbWeather!=PBWeather::HAIL
			when PBFields::HOLYF # Holy field
				fieldscore*=1.4 if opponent.pbHasType?(:NORMAL) || opponent.pbPartner.pbHasType?(:NORMAL) || opponent.pbHasType?(:FAIRY) || opponent.pbPartner.pbHasType?(:FAIRY)
				fieldscore*=0.6 if attacker.pbHasType?(:NORMAL) || attacker.pbHasType?(:FAIRY)
				fieldscore*=0.6 if pbPartyHasType?(PBTypes::NORMAL) || pbPartyHasType?(PBTypes::FAIRY)
				fieldscore*=0.5 if opponent.pbHasType?(:DARK) || opponent.pbPartner.pbHasType?(:DARK) || opponent.pbHasType?(:GHOST) || opponent.pbPartner.pbHasType?(:GHOST)
				fieldscore*=1.5 if attacker.pbHasType?(:DARK) || attacker.pbHasType?(:GHOST)
				fieldscore*=1.5 if pbPartyHasType?(PBTypes::DARK) || pbPartyHasType?(PBTypes::GHOST)
				fieldscore*=1.2 if opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON) || opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
				fieldscore*=0.8 if attacker.pbHasType?(:DRAGON) || attacker.pbHasType?(:PSYCHIC)
				fieldscore*=0.8 if pbPartyHasType?(PBTypes::DRAGON) || pbPartyHasType?(PBTypes::PSYCHIC)
			when PBFields::MIRRORA # Mirror field
				if violent
					if opponent.stages[PBStats::EVASION] > 0 || (@mondata.oppitemworks && opponent.item == PBItems::BRIGHTPOWDER) || 
						(@mondata.oppitemworks && opponent.item == PBItems::LAXINCENSE) || accuracyWeatherAbilityActive?(opponent)
						fieldscore*=1.3
					else
						fieldscore*=0.5
					end
				end
				fieldscore*=1+0.1*opponent.stages[PBStats::ACCURACY]
				fieldscore*=1+0.1*opponent.stages[PBStats::EVASION]
				fieldscore*=1-0.1*attacker.stages[PBStats::ACCURACY]
				fieldscore*=1-0.1*attacker.stages[PBStats::EVASION]
			when PBFields::FAIRYTALEF # Fairytale field
				fieldscore*=1.5 if opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON) || opponent.pbHasType?(:STEEL) || opponent.pbPartner.pbHasType?(:STEEL) || opponent.pbHasType?(:FAIRY) || opponent.pbPartner.pbHasType?(:FAIRY)
				fieldscore*=0.5 if attacker.pbHasType?(:DRAGON) || attacker.pbHasType?(:STEEL) || attacker.pbHasType?(:FAIRY)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::DRAGON) || pbPartyHasType?(PBTypes::STEEL) || pbPartyHasType?(PBTypes::FAIRY)
				fieldscore*=1.3 if opponent.ability == PBAbilities::STANCECHANGE
				fieldscore*=0.7 if attacker.ability == PBAbilities::STANCECHANGE
			when PBFields::DRAGONSD # Dragon's Den field
				fieldscore*=1.7 if opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON)
				fieldscore*=0.3 if attacker.pbHasType?(:DRAGON)
				fieldscore*=0.3 if pbPartyHasType?(PBTypes::DRAGON)
				fieldscore*=1.5 if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
				fieldscore*=0.5 if attacker.pbHasType?(:FIRE)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::FIRE)
				fieldscore*=1.3 if opponent.ability == PBAbilities::MULTISCALE
				fieldscore*=0.7 if attacker.ability == PBAbilities::MULTISCALE
			when PBFields::FLOWERGARDENF # Flower Garden field
				if @battle.field.counter>2
					fieldscore*= (0.5*@battle.field.counter) if opponent.pbHasType?(:BUG) || opponent.pbPartner.pbHasType?(:BUG) || opponent.pbHasType?(:GRASS) || opponent.pbPartner.pbHasType?(:GRASS)
					fieldscore*= (1.0/@battle.field.counter) if attacker.pbHasType?(:GRASS) || attacker.pbHasType?(:BUG)
					fieldscore*= (1.0/@battle.field.counter) if pbPartyHasType?(PBTypes::BUG) || pbPartyHasType?(PBTypes::GRASS)
					fieldscore*= (0.4*@battle.field.counter) if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
					fieldscore*= (1.0/@battle.field.counter) if attacker.pbHasType?(:FIRE)
					fieldscore*= (1.0/@battle.field.counter) if pbPartyHasType?(PBTypes::FIRE)
				end
			when PBFields::STARLIGHTA # Starlight Arena field
				fieldscore*=1.5 if opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
				fieldscore*=0.5 if attacker.pbHasType?(:PSYCHIC)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::PSYCHIC)
				fieldscore*=1.3 if opponent.pbHasType?(:FAIRY) || opponent.pbPartner.pbHasType?(:FAIRY) || opponent.pbHasType?(:DARK) || opponent.pbPartner.pbHasType?(:DARK)
				fieldscore*=0.7 if attacker.pbHasType?(:FAIRY) || attacker.pbHasType?(:DARK)
				fieldscore*=0.7 if pbPartyHasType?(PBTypes::FAIRY) || pbPartyHasType?(PBTypes::DARK)
			when PBFields::NEWW # New World field
				#fieldscore = 0
			when PBFields::INVERSEF # Inverse field
				fieldscore*=1.7 if opponent.pbHasType?(:NORMAL) || opponent.pbPartner.pbHasType?(:NORMAL)
				fieldscore*=0.3 if attacker.pbHasType?(:NORMAL)
				fieldscore*=0.3 if pbPartyHasType?(PBTypes::NORMAL)
				fieldscore*=1.5 if opponent.pbHasType?(:ICE) || opponent.pbPartner.pbHasType?(:ICE)
				fieldscore*=0.5 if attacker.pbHasType?(:ICE)
				fieldscore*=0.5 if pbPartyHasType?(PBTypes::ICE)
			when PBFields::PSYCHICT # Psychic Terrain
				fieldscore*=1.7 if opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
				fieldscore*=0.3 if attacker.pbHasType?(:PSYCHIC)
				fieldscore*=0.3 if pbPartyHasType?(PBTypes::PSYCHIC)
				fieldscore*=1.3 if opponent.ability == PBAbilities::TELEPATHY
				fieldscore*=0.7 if attacker.ability == PBAbilities::TELEPATHY
		end
		fieldscore*=0.01
		return fieldscore
	end

################################################################################
# Item score functions
################################################################################

	def getItemScore
		#check if we have items
		@mondata.itemscore = {}
		return if !@battle.internalbattle
		return if @attacker.effects[PBEffects::Embargo]>0
		items = @battle.pbGetOwnerItems(@index)
		return if !items || items.length==0
		party = @battle.pbPartySingleOwner(@attacker.index)
		opponent1 = @attacker.pbOppositeOpposing
		return if @attacker.isFainted?
		movecount = -1
		maxplaypri = -1
		partynumber = 0
		aimem = getAIMemory(opponent1)
		for i in party
			next if i.nil?
			next if i.hp == 0
			partynumber+=1
		end
		#highest score
		for i in 0...@attacker.moves.length
			next if @attacker.moves[i].nil?
			if @mondata.roughdamagearray.transpose[i].max >= 100 && @attacker.moves[i] && @attacker.moves[i].priority>maxplaypri
				maxplaypri = @attacker.moves[i].priority
			end
		end
		highscore = @mondata.roughdamagearray.max {|a,b| a.max <=> b.max}.max
		highdamage = -1
		maxopppri = -1
		pridam = -1
		bestid = -1
		#expected damage
		for i in aimem
			tempdam = pbRoughDamage(i,opponent1,@attacker)
			if tempdam>highdamage
				highdamage = tempdam
				bestid = i.id
			end
			if i.priority > maxopppri
				maxopppri = i.priority
				pridam = tempdam
			end
		end
		highdamage = checkAIdamage()
		highratio = -1
		#expected damage percentage
		highratio = highdamage*(1.0/@attacker.hp) if @attacker.hp!=0
		PBDebug.log(sprintf("Beginning AI Item use check.\n")) if $INTERNAL
		for i in items
			next if @mondata.itemscore.key?(i)
			itemscore=100
			if PBStuff::HPITEMS.include?(i)
				PBDebug.log(sprintf("This is a HP-healing item.")) if $INTERNAL
				restoreamount=0
				case i
					when  PBItems::POTION 		then restoreamount=20
					when  PBItems::ULTRAPOTION 	then restoreamount=200
					when  PBItems::SUPERPOTION 	then restoreamount=60
					when  PBItems::HYPERPOTION 	then restoreamount=120
					when  PBItems::MAXPOTION, PBItems::FULLRESTORE then restoreamount=@attacker.totalhp
					when  PBItems::FRESHWATER 	then restoreamount=30
					when  PBItems::SODAPOP 		then restoreamount=50
					when  PBItems::LEMONADE 	then restoreamount=70
					when  PBItems::MOOMOOMILK 	then restoreamount=100
					when  PBItems::BUBBLETEA 	then restoreamount=180
					when  PBItems::MEMEONADE 	then restoreamount=103
					when  PBItems::STRAWBIC 	then restoreamount=90
					when  PBItems::CHOCOLATEIC 	then restoreamount=70
					when  PBItems::BLUEMIC 		then restoreamount=200
				end
				resratio=restoreamount*(1.0/@attacker.totalhp)
				itemscore*= (2 - (2.0*@attacker.hp/@attacker.totalhp))
				if highdamage > (@attacker.totalhp - @attacker.hp) # if we take more damage from full than we currently have, don't bother
					itemscore*= 0  
				elsif ([@attacker.hp+restoreamount,@attacker.totalhp].min - highdamage) < ((@attacker.totalhp / 4.0) + attacker.hp) # and if we're not gaining at least 25% hp, don't bother
					itemscore*= 0.3
				end
				if highdamage>=@attacker.hp
					if highdamage > [@attacker.hp+restoreamount,@attacker.totalhp].min
						itemscore*=0
					else
						itemscore*=1.2
					end
					if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.isHealingMove? && moveloop.id != PBMoves::WISH}
						if !pbAIfaster?(nil,nil,@attacker, opponent1)
							if highdamage>=@attacker.hp
								itemscore*=1.1
							else
								itemscore*=0.6
								itemscore*=0.2 if resratio<0.55
							end
						end
					end
				else
					itemscore*=0.4
				end
				if highdamage > restoreamount
					itemscore*=0
				elsif restoreamount-highdamage < 15
					itemscore*=0.5
				end
				if pbAIfaster?(nil,nil,@attacker, opponent1)
					itemscore*=0.8
					if highscore >=110
						if maxopppri > maxplaypri
							itemscore*=1.3
							if pridam>@attacker.hp
								itemscore*= pridam>(@attacker.hp/2.0) ? 0 : 2
							end
						elsif !notOHKO?(@attacker, opponent1, true) && hpGainPerTurn >= 1
							itemscore*=0
						end
					end
					itemscore*=1.1 if @mondata.roles.include?(PBMonRoles::SWEEPER)
				else
					if highdamage*2 > [@attacker.hp+restoreamount,@attacker.totalhp].min
						itemscore*=0
					else
						itemscore*=1.5
						itemscore*=1.5 if highscore >=110
					end
				end
				if @attacker.hp == @attacker.totalhp
					itemscore*=0
				elsif @attacker.hp >= (@attacker.totalhp*0.8)
					itemscore*=0.2
				elsif @attacker.hp >= (@attacker.totalhp*0.6)
					itemscore*=0.3
				elsif @attacker.hp >= (@attacker.totalhp*0.5)
					itemscore*=0.5
				end
				minipot = (partynumber-1)
				minimini = -1
				for j in items
					next if !PBStuff::HPITEMS.include?(j)
					minimini+=1
				end
				if minipot>minimini
					itemscore*=(0.9**(minipot-minimini))
					minipot=minimini
				elsif minimini>minipot
					itemscore*=(1.1**(minimini-minipot))
					minimini=minipot
				end
				itemscore*=0.6 if @mondata.roles.include?(PBMonRoles::LEAD) || @mondata.roles.include?(PBMonRoles::SCREENER)
				itemscore*=1.1 if @mondata.roles.include?(PBMonRoles::TANK)
				itemscore*=1.1 if @mondata.roles.include?(PBMonRoles::SECOND)
				itemscore*=0.9 if hpGainPerTurn>1
				itemscore*=1.3 if hpGainPerTurn<1
				if @attacker.status!=0 && i != PBItems::FULLRESTORE
					itemscore*=0.7
					itemscore*=0.2 if @attacker.effects[PBEffects::Toxic]>0 && partynumber>1
				end
				eff1 = PBTypes.getCombinedEffectiveness(opponent1.type1,@attacker.type1,@attacker.type2)
				itemscore*=0.7 if eff1>4
				itemscore*=1.1 if eff1<4
				itemscore*=1.2 if eff1==0
				eff2 = PBTypes.getCombinedEffectiveness(opponent1.type2,@attacker.type1,@attacker.type2)
				itemscore*=0.7 if eff2>4
				itemscore*=1.1 if eff2<4
				itemscore*=1.2 if eff2==0
				itemscore*=0.7 if @attacker.ability == PBAbilities::REGENERATOR && partynumber>1
			end
			if PBStuff::STATUSITEMS.include?(i)
				PBDebug.log(sprintf("This is a status-curing item.")) if $INTERNAL
				if !(i== PBItems::FULLRESTORE)
					itemscore*=2 if highdamage < @attacker.hp / 2
					itemscore*=0 if @attacker.status==0
					if highdamage>@attacker.hp
						if (bestid==PBMoves::WAKEUPSLAP && @attacker.status==PBStatuses::SLEEP) || (bestid==PBMoves::SMELLINGSALTS && @attacker.status==PBStatuses::PARALYSIS) || bestid==PBMoves::HEX
							itemscore*= highdamage*0.5 > @attacker.hp ? 0 : 1.4
						else
							itemscore*=0
						end
					end
					if @attacker.status==PBStatuses::SLEEP
						itemscore*=0.6 if @attacker.pbHasMove?(PBMoves::SLEEPTALK) || @attacker.pbHasMove?(PBMoves::SNORE) || @attacker.pbHasMove?(PBMoves::REST) || @attacker.ability == PBAbilities::COMATOSE
						itemscore*=1.3 if checkAImoves([PBMoves::DREAMEATER,PBMoves::NIGHTMARE],aimem) || opponent1.ability == PBAbilities::BADDREAMS
						itemscore*= highdamage > 0.2 * @attacker.hp ? 1.3 : 0.7
					end
					if @attacker.status==PBStatuses::PARALYSIS
						itemscore*=0.5 if @attacker.ability == PBAbilities::QUICKFEET || @attacker.ability == PBAbilities::GUTS
						itemscore*=1.3 if @attacker.pbSpeed>opponent1.pbSpeed && (@attacker.pbSpeed*0.5)<opponent1.pbSpeed
						itemscore*=1.1
					end
					if @attacker.status==PBStatuses::BURN
						itemscore*=1.1
						itemscore*= @attacker.attack>@attacker.spatk ? 1.2 : 0.8
						itemscore*=0.6 if @attacker.ability == PBAbilities::GUTS
						itemscore*=0.7 if @attacker.ability == PBAbilities::MAGICGUARD
						itemscore*=0.8 if @attacker.ability == PBAbilities::FLAREBOOST
					end
					if @attacker.status==PBStatuses::POISON
						itemscore*=1.1
						itemscore*=0.5 if @attacker.ability == PBAbilities::GUTS
						itemscore*=0.5 if @attacker.ability == PBAbilities::MAGICGUARD
						itemscore*=0.5 if @attacker.ability == PBAbilities::TOXICBOOST
						itemscore*=0.2 if @attacker.ability == PBAbilities::POISONHEAL
						itemscore*=1.1 if @attacker.effects[PBEffects::Toxic]>0
						itemscore*=1.5 if @attacker.effects[PBEffects::Toxic]>3
					end
					if @attacker.status==PBStatuses::FROZEN
						itemscore*=1.3
						itemscore*=0.5 if @attacker.moves.any? {|moveloop| moveloop!=nil && moveloop.canThawUser?}
						itemscore*=  highdamage > 0.15 * @attacker.hp ? 1.1 : 0.9
					end
				end
				itemscore*=0.5 if @attacker.pbHasMove?(PBMoves::REFRESH) || @attacker.pbHasMove?(PBMoves::REST) || @attacker.pbHasMove?(PBMoves::PURIFY)
				itemscore*=0.2 if @attacker.ability == PBAbilities::NATURALCURE && partynumber>1
				itemscore*=0.3 if @attacker.ability == PBAbilities::SHEDSKIN
				
			end
			# General "Is it a good idea to use an item at all right now" checks
			if partynumber==1 || @mondata.roles.include?(PBMonRoles::ACE)
				itemscore*=1.2
			else
				itemscore*=0.8
				itemscore*=0.6 if @attacker.itemUsed2
			end
			itemscore*=2 if @attacker.effects[PBEffects::Toxic]>3 && i == PBItems::FULLRESTORE
			itemscore*=0.9 if @attacker.effects[PBEffects::Confusion]>0
			itemscore*=0.6 if @attacker.effects[PBEffects::Attract]>=0
			itemscore*=1.1 if @attacker.effects[PBEffects::Substitute]>0
			itemscore*=0.5 if @attacker.effects[PBEffects::LeechSeed]>=0
			itemscore*=0.5 if @attacker.effects[PBEffects::Curse]
			itemscore*=0.2 if @attacker.effects[PBEffects::PerishSong]>0
			minipot=0
			for s in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED, PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
				minipot+=@attacker.stages[s]
			end
			if @mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL)
				for s in [PBStats::DEFENSE,PBStats::SPDEF]
					minipot+=@attacker.stages[s]
				end
			end
			if @mondata.roles.include?(PBMonRoles::SWEEPER)
				minipot+=@attacker.stages[PBStats::SPEED]
				minipot+= @attacker.attack>@attacker.spatk ? @attacker.stages[PBStats::ATTACK] : @attacker.stages[PBStats::SPATK]
			end
			
			
			itemscore*=0.05*minipot + 1
			itemscore*=1.2 if opponent1.effects[PBEffects::TwoTurnAttack]>0 || opponent1.effects[PBEffects::HyperBeam]>0
			itemscore*= highscore>70 ? 1.1 : 0.9

			fielddisrupt = getFieldDisruptScore(@attacker,opponent1)
			fielddisrupt=0.6 if fielddisrupt <= 0
			itemscore*= (1.0/fielddisrupt)

			itemscore*=0.9 if @battle.trickroom > 0
			itemscore*=0.6 if @attacker.pbOwnSide.effects[PBEffects::Tailwind]>0
			itemscore*=0.9 if @attacker.pbOwnSide.effects[PBEffects::Reflect]>0
			itemscore*=0.9 if @attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
			itemscore*=0.8 if @attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>0
			itemscore*=0.8 if @battle.doublebattle
			itemscore*=0.3 if @attacker.effects[PBEffects::Rollout] > 0
			itemscore-=100
			PBDebug.log(sprintf("Score for %s: %d",PBItems.getName(i),itemscore)) if $INTERNAL
			$ai_log_data[@attacker.index].items.push(PBItems.getName(i))
			$ai_log_data[@attacker.index].items_scores.push(itemscore)
			@mondata.itemscore[i] = itemscore
			@mondata.itemscore[i] = -8000 if $game_switches[:Stop_Items_Password] == true || $game_switches[:No_Items_Password] == true
		end
		#somehow register that this would be the item that should be used
		PBDebug.log(sprintf("Highest item score: %d",(@mondata.itemscore.values.max))) if $INTERNAL
		#score the item if we have it
	end


################################################################################
# Switching functions
################################################################################
	#function for getting the new switch-in when sending new mon out cuz fainted
	def pbDefaultChooseNewEnemy(index,party)
		#index is index of battler
		@mondata = @aimondata[index]
		@attacker = @battle.battlers[index]
		@index = index
		@opponent = firstOpponent()
		switchscores = getSwitchInScoresParty(false)
		return switchscores.index(switchscores.max)
	end

	def getSwitchingScore
		#Set up some basic checks to prompt the remainder of the switch code
		#upon passing said checks:
		@mondata.shouldswitchscore = shouldSwitch?()
		$ai_log_data[@attacker.index].should_switch_score = @mondata.shouldswitchscore
		PBDebug.log(sprintf("ShouldSwitchScore: %d \n",@mondata.shouldswitchscore)) if $INTERNAL

		if @mondata.shouldswitchscore > 0
			@mondata.switchscore = getSwitchInScoresParty(true)
		end
	end

	def getSwitchInScoresParty(hard_switch)
		party = @battle.pbParty(@attacker.index)
		if @mondata.skill < MEDIUMSKILL
			#Bad trainers likely don't know what a pikachu is, and just swap in random mons
			
			partyScores = Array.new(party.length,-10000000)
			#if there are no switchins at all
			return partyScores if hard_switch || !party.any? {|pkmn| @battle.pbCanSwitchLax?(@attacker.index,party.index(pkmn),false)}
			ranvar=0
			1000.times do
				ranvar = rand(party.length)
				break if @battle.pbCanSwitchLax?(@attacker.index,ranvar,false)
			end
			partyScores[ranvar] = 100
			return partyScores
		end
		partyScores = []
		aimem = getAIMemory(@opponent)
		aimem2 = @opponent.pbPartner.hp > 0 ? getAIMemory(@opponent.pbPartner) : []
		for partyindex in 0...party.length
			monscore = 0
			i = pbMakeFakeBattler(party[partyindex]) rescue nil
			nonmegaform = pbMakeFakeBattler(party[partyindex]) rescue nil
			if i.nil?
				partyScores.push(-10000000)
				PBDebug.log(sprintf("Score: -10000000\n")) if $INTERNAL
				$ai_log_data[@attacker.index].switch_scores.push(-10000000)
				$ai_log_data[@attacker.index].switch_name.push("")
				next
			end
			PBDebug.log(sprintf("Scoring for %s switching to: %s",PBSpecies.getName(@attacker.species),PBSpecies.getName(i.species))) if $INTERNAL
			if hard_switch
				if !@battle.pbCanSwitch?(@attacker.index,partyindex,false)
					partyScores.push(-10000000)
					PBDebug.log(sprintf("Score: -10000000\n")) if $INTERNAL
					$ai_log_data[@attacker.index].switch_scores.push(-10000000)
					$ai_log_data[@attacker.index].switch_name.push(PBSpecies.getName(i.pokemon.species))
					next
				end
			else #not hard switch ergo dead mon
				if !@battle.pbCanSwitchLax?(@attacker.index,partyindex,false)
					partyScores.push(-10000000)
					PBDebug.log(sprintf("Score: -10000000\n")) if $INTERNAL
					$ai_log_data[@attacker.index].switch_scores.push(-10000000)
					$ai_log_data[@attacker.index].switch_name.push(PBSpecies.getName(i.pokemon.species))
					next
				end
			end
			if !i.moves.any? {|moveloop| moveloop != nil && moveloop.id != 0 && moveloop.id != PBMoves::LUNARDANCE}
				partyScores.push(-1000)
				PBDebug.log(sprintf("Lunar mon sacrifice- Score: -1000\n")) if $INTERNAL
				$ai_log_data[@attacker.index].switch_scores.push(-1000)
				$ai_log_data[@attacker.index].switch_name.push(PBSpecies.getName(i.pokemon.species))
				next
			end
			if partyindex == party.length-1 && $game_switches[:Last_Ace_Switch]
				partyScores.push(-10000)
				PBDebug.log(sprintf("Ace Switch Prevention- Score: -10000\n")) if $INTERNAL
				$ai_log_data[@attacker.index].switch_scores.push(-10000)
				$ai_log_data[@attacker.index].switch_name.push(PBSpecies.getName(i.pokemon.species))
				next
			end
			theseRoles = @mondata.partyroles[partyindex%6] if @mondata.partyroles[partyindex%6]
			theseRoles = pbGetMonRoles(i) if !theseRoles
			if @battle.pbCanMegaEvolveAI?(i,@attacker.index)
				i.pokemon.makeMega
			end
			#speed changing
			pbStatChangingSwitch(i)
			pbStatChangingSwitch(nonmegaform)
			if (i.ability == PBAbilities::IMPOSTER)
				transformed = true
				i = pbMakeFakeBattler(@opponent.pokemon)
				i.hp = nonmegaform.hp
				i.item = nonmegaform.item

				monscore += 20*@opponent.stages[PBStats::ATTACK]
				monscore += 20*@opponent.stages[PBStats::SPATK]
				monscore += 20*@opponent.stages[PBStats::SPEED]
			end


			# Information gathering
			opp_best_move, incomingdamage = checkAIMovePlusDamage(@opponent, i)

			roughdamagearray = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]] #Order: First Opp, Second Opp, Partner, Sum if multi-target
			for moveindex in 0...i.moves.length
				@move = i.moves[moveindex]
				next if @move.nil?
				roughdamagearray[0][moveindex] = [(pbRoughDamage(@move,i,@opponent)*100)/(@opponent.hp.to_f),100].min if @opponent.hp > 0
				if @battle.doublebattle
					roughdamagearray[1][moveindex] = [(pbRoughDamage(@move,i,@opponent.pbPartner)*100)/(@opponent.pbPartner.hp.to_f),100].min if @opponent.pbPartner.hp > 0
					next if @move.target != PBTargets::AllNonUsers && !PARTNERFUNCTIONS.include?(@move.function)
					roughdamagearray[2][moveindex] = [(pbRoughDamage(@move,i,@attacker.pbPartner)*100)/(@attacker.pbPartner.hp.to_f),100].min if @attacker.pbPartner.hp > 0
				end
				if i.pbTarget(@move)==PBTargets::AllOpposing
					roughdamagearray[3][moveindex] = roughdamagearray[0][moveindex] + roughdamagearray[1][moveindex]
				elsif i.pbTarget(@move)==PBTargets::AllNonUsers
					roughdamagearray[3][moveindex] = roughdamagearray[0][moveindex] + roughdamagearray[1][moveindex] - 2*roughdamagearray[2][moveindex]
				elsif i.pbTarget(@move)==PBTargets::RandomOpposing && @battle.doublebattle
					roughdamagearray[3][moveindex] = (roughdamagearray[3][moveindex] + roughdamagearray[3][moveindex])/2
				end
			end
			bestmoveindex = (roughdamagearray[0]+roughdamagearray[1]).index((roughdamagearray[0]+roughdamagearray[1]).max) % 4
			bestmove = i.moves[bestmoveindex]

			#Defensive
			defscore = 0
			incomingdamage = checkAIdamage(i,@opponent)
			incomingdamage2 = 0
			incomingdamage2 += checkAIdamage(i,@opponent.pbPartner) if @battle.doublebattle
			incomingpercentage = (incomingdamage + incomingdamage2) / i.hp.to_f
			maxsingulardamage = [incomingdamage2, incomingdamage].max / i.hp.to_f
			PBDebug.log(sprintf("incomingpercentage: %f",incomingpercentage)) if $INTERNAL
			defscore -= 150 if incomingpercentage > 1.0 && !canKillBeforeOpponentKills?(i,@opponent)
			defscore += 25 if incomingpercentage < 0.5
			defscore += 10 if maxsingulardamage < 0.45
			defscore += 10 if maxsingulardamage < 0.4
			defscore += 10 if maxsingulardamage < 0.35
			defscore += 20 if maxsingulardamage < 0.3
			defscore += 50 if 2*incomingpercentage + hpGainPerTurn-1 < 0.5
			defscore += 20 if maxsingulardamage < 0.2
			defscore += 30 if maxsingulardamage < 0.1
			defscore += 50 if 3*incomingpercentage + 2*(hpGainPerTurn-1) < 0.3

			#check if hard switch_in lives assumed move
			if hard_switch && !@battle.doublebattle && (maxsingulardamage < 1.0 || pbAIfaster?(nil,nil,@opponent,i))
				assumed_move = checkAIbestMove()
				assumed_damage = pbRoughDamage(assumed_move,@opponent,nonmegaform)
				assumed_percentage = assumed_damage / nonmegaform.hp
				defscore += 30 if assumed_damage < 0.5
				defscore += 50 if assumed_damage < 0.3
				defscore += 90 if assumed_damage < 0.1
			end
			defscore *= 2 if @opponent.effects[PBEffects::Substitute] > 0

			monscore += defscore
			PBDebug.log(sprintf("Defensive: %d",defscore)) if $INTERNAL

			#Offensive
			offscore=0
			
			#check damage
			offscore += 30 if roughdamagearray[3].max > 180
			offscore += 50 if roughdamagearray[0].max >= 100 || roughdamagearray[1].max >= 100
			offscore += 10 if [roughdamagearray[0].max, roughdamagearray[1].max].max > 90
			offscore += 10 if [roughdamagearray[0].max, roughdamagearray[1].max].max > 80
			offscore += 10 if [roughdamagearray[0].max, roughdamagearray[1].max].max > 70
			offscore += 10 if [roughdamagearray[0].max, roughdamagearray[1].max].max > 60
			offscore += 50 if roughdamagearray[0].max >= 50 || roughdamagearray[1].max >= 50
			offscore += 50 if roughdamagearray[0].max >= 100 && roughdamagearray[1].max >= 100

			bestmoveindex = (roughdamagearray[0]+roughdamagearray[1]).index((roughdamagearray[0]+roughdamagearray[1]).max) % 4
			offscore *= pbAIfaster?(i.moves[bestmoveindex],opp_best_move,i,@opponent) ? 1.25 : 0.75


			monscore += offscore
			PBDebug.log(sprintf("Offensive: %d",offscore)) if $INTERNAL
			# Roles
			rolescore=0
			if @mondata.skill >= HIGHSKILL
				if theseRoles.include?(PBMonRoles::SWEEPER)
					rolescore+= @attacker.pbNonActivePokemonCount<2 ? 60 : -50
					rolescore+=30 if i.attack >= i.spatk && (@opponent.defense<@opponent.spdef || @opponent.pbPartner.defense<@opponent.pbPartner.spdef)
					rolescore+=30 if i.spatk >= i.attack && (@opponent.spdef<@opponent.defense || @opponent.pbPartner.spdef<@opponent.pbPartner.defense)
					rolescore+= (-10)* statchangecounter(@opponent,1,7,-1)
					rolescore+= (-10)* statchangecounter(@opponent.pbPartner,1,7,-1)
					rolescore+=10 if pbAIfaster?(nil,nil,i,@opponent) && rolescore > 0 
					rolescore*= pbAIfaster?(nil,nil,i,@opponent) && rolescore > 0 ? 1.5 : 0.5 
					rolescore+=50 if @opponent.status==PBStatuses::SLEEP || @opponent.status==PBStatuses::FROZEN
					rolescore+=50 if @opponent.pbPartner.status==PBStatuses::SLEEP || @opponent.pbPartner.status==PBStatuses::FROZEN
				end
				if theseRoles.include?(PBMonRoles::PHYSICALWALL) || theseRoles.include?(PBMonRoles::SPECIALWALL)
					rolescore+=30 if theseRoles.include?(PBMonRoles::PHYSICALWALL) && (@opponent.spatk>@opponent.attack || @opponent.pbPartner.spatk>@opponent.pbPartner.attack)
					rolescore+=30 if theseRoles.include?(PBMonRoles::SPECIALWALL) && (@opponent.spatk<@opponent.attack || @opponent.pbPartner.spatk<@opponent.pbPartner.attack)
					rolescore+=30 if @opponent.status==PBStatuses::BURN || @opponent.status==PBStatuses::POISON || @opponent.effects[PBEffects::LeechSeed]>0
					rolescore+=30 if @opponent.pbPartner.status==PBStatuses::BURN || @opponent.pbPartner.status==PBStatuses::POISON || @opponent.pbPartner.effects[PBEffects::LeechSeed]>0
				end
				if theseRoles.include?(PBMonRoles::TANK)
					rolescore+=40 if @opponent.status==PBStatuses::PARALYSIS || @opponent.effects[PBEffects::LeechSeed]>0
					rolescore+=40 if @opponent.pbPartner.status==PBStatuses::PARALYSIS || @opponent.pbPartner.effects[PBEffects::LeechSeed]>0
					rolescore+=30 if @attacker.pbOwnSide.effects[PBEffects::Tailwind]>0
				end
				if theseRoles.include?(PBMonRoles::LEAD)
					rolescore+=10
					rolescore+=20 if (party.length - @attacker.pbNonActivePokemonCount) <= (party.length / 2).ceil
				end
				if @attacker.effects[PBEffects::LunarDance] && @battle.FE == PBFields::NEWW
					rolescore -= 100 if @attacker.pbNonActivePokemonCount > 2 # this might still need to be adjusted
					rolescore += 200 if @attacker.pbNonActivePokemonCount == 1
				end
				if theseRoles.include?(PBMonRoles::CLERIC)
					partymidhp = false
					for k in party
						next if k.nil? || k==i || k.totalhp==0
						rolescore+=50 if k.status!=0
						partymidhp = true if 0.3<((k.hp.to_f)/k.totalhp) && ((k.hp.to_f)/k.totalhp)<0.6
					end
					rolescore+=50 if partymidhp
				end
				#now only does for lowered stats, but would also be very good for raised stats right?
				#evasion / accuracy doesn't make sense to me
				if theseRoles.include?(PBMonRoles::PHAZER)
					for opp in [@opponent, @opponent.pbPartner]
						next if opp.hp <=0
						rolescore+= (10)*opp.stages[PBStats::ATTACK]	if opp.stages[PBStats::ATTACK]<0
						rolescore+= (20)*opp.stages[PBStats::DEFENSE]	if opp.stages[PBStats::DEFENSE]<0
						rolescore+= (10)*opp.stages[PBStats::SPATK]		if opp.stages[PBStats::SPATK]<0
						rolescore+= (20)*opp.stages[PBStats::SPDEF]		if opp.stages[PBStats::SPDEF]<0
						rolescore+= (10)*opp.stages[PBStats::SPEED]		if opp.stages[PBStats::SPEED]<0
						rolescore+= (20)*opp.stages[PBStats::EVASION]	if opp.stages[PBStats::ACCURACY]<0
					end
				end
				rolescore+=60 if theseRoles.include?(PBMonRoles::SCREENER)
				#This is role related because it's the replacement for revenge killer
				for moveindex in 0...i.moves.length
					next if i.moves[moveindex].nil?
					if pbAIfaster?(i.moves[moveindex],nil,i,@opponent)
						if roughdamagearray[0][moveindex] >= 100 || roughdamagearray[1][moveindex] >= 100
							rolescore+=110
							break
						end
					end
				end
				if theseRoles.include?(PBMonRoles::SPINNER)
					if !@opponent.pbHasType?(:GHOST) && (@opponent.pbPartner.hp==0 || !@opponent.pbPartner.pbHasType?(:GHOST))
						rolescore+=20*@attacker.pbOwnSide.effects[PBEffects::Spikes]
						rolescore+=20*@attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]
						rolescore+=30 if @attacker.pbOwnSide.effects[PBEffects::StickyWeb]
						rolescore+=30 if @attacker.pbOwnSide.effects[PBEffects::StealthRock]
					end
				end
				if theseRoles.include?(PBMonRoles::PIVOT)
					rolescore+=40
				end
				if theseRoles.include?(PBMonRoles::BATONPASSER)
					rolescore+=50
				end
				if theseRoles.include?(PBMonRoles::STALLBREAKER)
					rolescore+=80 if checkAIhealing(aimem) || checkAIhealing(aimem2)
				end
				if theseRoles.include?(PBMonRoles::STATUSABSORBER)
					for specificmemory in [aimem, aimem2]
						next if specificmemory.length == 0
						for j in specificmemory
							statusmove = PBStuff::BURNMOVE.include?(j.id) || PBStuff::PARAMOVE.include?(j.id) || PBStuff::SLEEPMOVE.include?(j.id) || PBStuff::SCREENMOVE.include?(j.id)
						end
					end
					rolescore+=70 if statusmove
				end
				if theseRoles.include?(PBMonRoles::TRAPPER)
					rolescore+=30 if pbAIfaster?(nil,nil,i,@opponent) && @opponent.totalhp!=0 && (@opponent.hp.to_f)/@opponent.totalhp<0.6
				end
				if theseRoles.include?(PBMonRoles::WEATHERSETTER)
					rolescore+=30
					if (i.ability == PBAbilities::DROUGHT) || (nonmegaform.ability == PBAbilities::DROUGHT) || i.pbHasMove?(PBMoves::SUNNYDAY)
						rolescore+=60 if @battle.weather!=PBWeather::SUNNYDAY
					elsif (i.ability == PBAbilities::DRIZZLE) || (nonmegaform.ability == PBAbilities::DRIZZLE) || i.pbHasMove?(PBMoves::RAINDANCE)
						rolescore+=60 if @battle.weather!=PBWeather::RAINDANCE
					elsif (i.ability == PBAbilities::SANDSTREAM) || (nonmegaform.ability == PBAbilities::SANDSTREAM) || i.pbHasMove?(PBMoves::SANDSTORM)
						rolescore+=60 if @battle.weather!=PBWeather::SANDSTORM
					elsif (i.ability == PBAbilities::SNOWWARNING) || (nonmegaform.ability == PBAbilities::SNOWWARNING) || i.pbHasMove?(PBMoves::HAIL)
						rolescore+=60 if @battle.weather!=PBWeather::HAIL
					elsif (i.ability == PBAbilities::PRIMORDIALSEA) || (i.ability == PBAbilities::DESOLATELAND) || (i.ability == PBAbilities::DELTASTREAM) ||
						(nonmegaform.ability == PBAbilities::PRIMORDIALSEA) || (nonmegaform.ability == PBAbilities::DESOLATELAND) || (nonmegaform.ability == PBAbilities::DELTASTREAM)
						rolescore+=60
					end
				end
			end
			monscore += rolescore
			PBDebug.log(sprintf("Roles: %d",rolescore)) if $INTERNAL
			# Weather
			weatherscore=0
			case @battle.weather
				when PBWeather::HAIL
					weatherscore+=25 if (i.ability == PBAbilities::MAGICGUARD) || (i.ability == PBAbilities::OVERCOAT) || i.hasType?(:ICE)
					weatherscore+=50 if (i.ability == PBAbilities::SNOWCLOAK) || (i.ability == PBAbilities::ICEBODY)
					weatherscore+=80 if (i.ability == PBAbilities::SLUSHRUSH)
				when PBWeather::RAINDANCE
					weatherscore+=50 if (i.ability == PBAbilities::DRYSKIN) || (i.ability == PBAbilities::HYDRATION) || (i.ability == PBAbilities::RAINDISH)
					weatherscore+=80 if (i.ability == PBAbilities::SWIFTSWIM)
				when PBWeather::SUNNYDAY
					weatherscore-=40 if (i.ability == PBAbilities::DRYSKIN)
					weatherscore+=50 if (i.ability == PBAbilities::SOLARPOWER)
					weatherscore+=80 if (i.ability == PBAbilities::CHLOROPHYLL)
				when PBWeather::SANDSTORM
					weatherscore+=25 if (i.ability == PBAbilities::MAGICGUARD) || (i.ability == PBAbilities::OVERCOAT) || i.hasType?(:ROCK) || i.hasType?(:GROUND) || i.hasType?(:STEEL)
					weatherscore+=50 if (i.ability == PBAbilities::SANDVEIL) || (i.ability == PBAbilities::SANDFORCE)
					weatherscore+=80 if (i.ability == PBAbilities::SANDRUSH)
			end
			if @battle.trickroom>0
				weatherscore+= i.pbSpeed<@opponent.pbSpeed ? 50 : -50
				weatherscore+= i.pbSpeed<@opponent.pbPartner.pbSpeed ? 50 : -50 if @opponent.pbPartner.hp > 0
			end
			monscore += weatherscore
			PBDebug.log(sprintf("Weather: %d",weatherscore)) if $INTERNAL
			#Moves
			movesscore=0
			if @mondata.skill>=HIGHSKILL
				if @attacker.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
					movesscore+=80 if nonmegaform.hasType?(:POISON) && !nonmegaform.hasType?(:FLYING) && !(nonmegaform.ability == PBAbilities::LEVITATE)
					movesscore+=30 if nonmegaform.hasType?(:FLYING) || nonmegaform.hasType?(:STEEL) || (nonmegaform.ability == PBAbilities::LEVITATE)
				end
				if i.pbHasMove?(PBMoves::CLEARSMOG) || i.pbHasMove?(PBMoves::HAZE)
					movesscore+= (10)* statchangecounter(@opponent,1,7,1)
					movesscore+= (10)* statchangecounter(@opponent.pbPartner,1,7,1)
				end
				movesscore+=25 if i.pbHasMove?(PBMoves::FAKEOUT) || i.pbHasMove?(PBMoves::FIRSTIMPRESSION)
				if @attacker.pbPartner.totalhp != 0
					movesscore+=70 if i.pbHasMove?(PBMoves::FUSIONBOLT) && @attacker.pbPartner.pbHasMove?(PBMoves::FUSIONFLARE)
					movesscore+=70 if i.pbHasMove?(PBMoves::FUSIONFLARE) && @attacker.pbPartner.pbHasMove?(PBMoves::FUSIONBOLT)
				end
				movesscore+=30 if i.pbHasMove?(PBMoves::RETALIATE) && @attacker.pbOwnSide.effects[PBEffects::Retaliate]
				if i.pbHasMove?(PBMoves::FELLSTINGER) 
					movesscore+=50 if pbAIfaster?(nil,nil,i,@opponent) && (@opponent.hp.to_f)/@opponent.totalhp<0.2
					movesscore+=50 if pbAIfaster?(nil,nil,i,@opponent.pbPartner) && (@opponent.pbPartner.hp.to_f)/@opponent.pbPartner.totalhp<0.2
				end
				if i.pbHasMove?(PBMoves::TAILWIND)
					movesscore+= @attacker.pbOwnSide.effects[PBEffects::Tailwind]>0 ? -60 : 30
				end
				if i.pbHasMove?(PBMoves::PURSUIT) || (i.pbHasMove?(PBMoves::SANDSTORM) || i.pbHasMove?(PBMoves::HAIL)) && @opponent.item != PBItems::SAFETYGOGGLES ||
					 i.pbHasMove?(PBMoves::TOXIC) || i.pbHasMove?(PBMoves::LEECHSEED)
					movesscore+=150 if (@opponent.ability == PBAbilities::WONDERGUARD)
					movesscore+=150 if (@opponent.pbPartner.ability == PBAbilities::WONDERGUARD)
				end
			end
			monscore+=movesscore
			PBDebug.log(sprintf("Moves: %d",movesscore)) if $INTERNAL
			#Abilities
			abilityscore=0
			if @mondata.skill >= HIGHSKILL
				case i.ability
					when PBAbilities::DISGUISE
						if i.effects[PBEffects::Disguise]
							abilityscore+= (10)* statchangecounter(@opponent,1,7,1)
							abilityscore+= (10)* statchangecounter(@opponent.pbPartner,1,7,1)
							abilityscore+= 50 if roughdamagearray[0].max >= 100 || roughdamagearray[1].max >= 100
						end
					when PBAbilities::UNAWARE
						abilityscore+= (10)* statchangecounter(@opponent,1,7,1)
						abilityscore+= (10)* statchangecounter(@opponent.pbPartner,1,7,1)
					when PBAbilities::DROUGHT,PBAbilities::DESOLATELAND
						abilityscore+=40 if @opponent.pbHasType?(:WATER)
						abilityscore+=40 if @opponent.pbPartner.pbHasType?(:WATER)
						for specificmemory in [aimem,aimem2]
							abilityscore+=15 if specificmemory.any? {|moveloop| moveloop!=nil && moveloop.pbType(specificmemory==aimem ? @opponent : @opponent.pbPartner) == PBTypes::WATER}
						end
					when PBAbilities::DRIZZLE,PBAbilities::PRIMORDIALSEA
						abilityscore+=40 if @opponent.pbHasType?(:FIRE)
						abilityscore+=40 if @opponent.pbPartner.pbHasType?(:FIRE)
						for specificmemory in [aimem,aimem2]
							abilityscore+=15 if specificmemory.any? {|moveloop| moveloop!=nil && moveloop.pbType(specificmemory==aimem ? @opponent : @opponent.pbPartner) == PBTypes::FIRE}
						end
					when PBAbilities::LIMBER
						abilityscore+=15 if checkAImoves(PBStuff::PARAMOVE,aimem)
						abilityscore+=15 if checkAImoves(PBStuff::PARAMOVE,aimem2)
					when PBAbilities::OBLIVIOUS
						abilityscore+=20 if (@opponent.ability == PBAbilities::CUTECHARM) || (@opponent.pbPartner.ability == PBAbilities::CUTECHARM)
						abilityscore+=20 if checkAImoves([PBMoves::ATTRACT],aimem)
						abilityscore+=20 if checkAImoves([PBMoves::ATTRACT],aimem2)
					when PBAbilities::COMPOUNDEYES
						abilityscore+=25 if (@opponent.item == PBItems::LAXINCENSE) || (@opponent.item == PBItems::BRIGHTPOWDER) || @opponent.stages[PBStats::EVASION]>0 || accuracyWeatherAbilityActive?(@opponent)
						abilityscore+=25 if (@opponent.pbPartner.item == PBItems::LAXINCENSE) || (@opponent.pbPartner.item == PBItems::BRIGHTPOWDER) || @opponent.pbPartner.stages[PBStats::EVASION]>0 || accuracyWeatherAbilityActive?(@opponent.pbPartner)
					when PBAbilities::COMATOSE
						abilityscore+=20 if checkAImoves(PBStuff::BURNMOVE,aimem)
						abilityscore+=20 if checkAImoves(PBStuff::PARAMOVE,aimem)
						abilityscore+=20 if checkAImoves(PBStuff::SLEEPMOVE,aimem)
						abilityscore+=20 if checkAImoves(PBStuff::POISONMOVE,aimem)
					when PBAbilities::INSOMNIA,PBAbilities::VITALSPIRIT
						abilityscore+=20 if checkAImoves(PBStuff::SLEEPMOVE,aimem)
					when PBAbilities::POISONHEAL,PBAbilities::TOXICBOOST,PBAbilities::IMMUNITY
						abilityscore+=20 if checkAImoves(PBStuff::POISONMOVE,aimem)
					when PBAbilities::MAGICGUARD
						abilityscore+=20 if checkAImoves([PBMoves::LEECHSEED],aimem)
						abilityscore+=20 if checkAImoves([PBMoves::WILLOWISP],aimem)
						abilityscore+=20 if checkAImoves(PBStuff::POISONMOVE,aimem)
					when PBAbilities::WATERBUBBLE,PBAbilities::WATERVEIL,PBAbilities::FLAREBOOST
						if checkAImoves(PBStuff::BURNMOVE,aimem)
							abilityscore+=10
							abilityscore+=10 if (i.ability == PBAbilities::FLAREBOOST)
						end
					when PBAbilities::OWNTEMPO
						abilityscore+=20 if checkAImoves(PBStuff::CONFUMOVE,aimem)
					when PBAbilities::INTIMIDATE,PBAbilities::FURCOAT,PBAbilities::STAMINA
						abilityscore+=40 if @opponent.attack> @opponent.spatk
						abilityscore+=40 if @opponent.pbPartner.attack> @opponent.pbPartner.spatk
					when PBAbilities::WONDERGUARD
						dievar = false
						instantdievar=false
						for j in aimem
							dievar=true if [PBTypes::FIRE, PBTypes::GHOST, PBTypes::DARK, PBTypes::ROCK, PBTypes::FLYING].include?(j.pbType(@opponent))
						end
						if @mondata.skill>=BESTSKILL
							for j in aimem2
								dievar=true if [PBTypes::FIRE, PBTypes::GHOST, PBTypes::DARK, PBTypes::ROCK, PBTypes::FLYING].include?(j.pbType(@opponent.pbPartner))
							end
						end
						if @battle.weather==PBWeather::HAIL || PBWeather::SANDSTORM
							dievar=true
							instantdievar=true
						end
						if i.status==PBStatuses::BURN || i.status==PBStatuses::POISON
							dievar=true
							instantdievar=true
						end
						if @attacker.pbOwnSide.effects[PBEffects::StealthRock] || @attacker.pbOwnSide.effects[PBEffects::Spikes]>0 || @attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
							dievar=true
							instantdievar=true
						end
						dievar=true if moldBreakerCheck(@opponent)
						dievar=true if moldBreakerCheck(@opponent.pbPartner)
						abilityscore+=90 if !dievar
						abilityscore-=90 if instantdievar
					when PBAbilities::EFFECTSPORE,PBAbilities::STATIC,PBAbilities::POISONPOINT,PBAbilities::ROUGHSKIN,PBAbilities::IRONBARBS,PBAbilities::FLAMEBODY,PBAbilities::CUTECHARM,PBAbilities::MUMMY,PBAbilities::AFTERMATH,PBAbilities::GOOEY,PBAbilities::FLUFFY
						if checkAIbestMove(@opponent).isContactMove? || checkAIbestMove(@opponent.pbPartner).isContactMove?
							abilityscore+=30 unless i.ability == PBAbilities::FLUFFY && (@opponent.pbHasType?(PBTypes::FIRE) || @opponent.pbPartner.pbHasType?(PBTypes::FIRE))
						end
					when PBAbilities::TRACE 
						if [PBAbilities::WATERABSORB,PBAbilities::VOLTABSORB,PBAbilities::STORMDRAIN,PBAbilities::MOTORDRIVE,PBAbilities::FLASHFIRE,PBAbilities::LEVITATE,PBAbilities::LIGHTNINGROD,
							PBAbilities::SAPSIPPER,PBAbilities::DRYSKIN,PBAbilities::SLUSHRUSH,PBAbilities::SANDRUSH,PBAbilities::SWIFTSWIM,PBAbilities::CHLOROPHYLL,PBAbilities::SPEEDBOOST,
							PBAbilities::WONDERGUARD,PBAbilities::PRANKSTER].include?(@opponent.ability) || 
							(pbAIfaster?() && ((@opponent.ability == PBAbilities::ADAPTABILITY) || (@opponent.ability == PBAbilities::DOWNLOAD) || (@opponent.ability == PBAbilities::PROTEAN))) || 
							(@opponent.attack>@opponent.spatk && (@opponent.ability == PBAbilities::INTIMIDATE)) || (@opponent.ability == PBAbilities::UNAWARE) || (i.hp==i.totalhp && ((@opponent.ability == PBAbilities::MULTISCALE) || (@opponent.ability == PBAbilities::SHADOWSHIELD)))
							abilityscore+=60
						end
					when PBAbilities::MAGMAARMOR
						abilityscore+=20 if aimem.any? {|moveloop| moveloop!=nil && moveloop.pbType(@opponent) == PBTypes::ICE}
						abilityscore+=20 if aimem2.any? {|moveloop| moveloop!=nil && moveloop.pbType(@opponent.pbPartner) == PBTypes::ICE}
					when PBAbilities::SOUNDPROOF
						abilityscore+=60 if checkAIbestMove(@opponent).isSoundBased? || checkAIbestMove(@opponent.pbPartner).isSoundBased?
					when PBAbilities::THICKFAT
						abilityscore+=30 if [PBTypes::ICE,PBTypes::FIRE].include?(checkAIbestMove().pbType(@opponent)) || [PBTypes::ICE,PBTypes::FIRE].include?(checkAIbestMove(@opponent.pbPartner).pbType(@opponent.pbPartner))
					when PBAbilities::WATERBUBBLE
						abilityscore+=30 if PBTypes::FIRE ==checkAIbestMove().pbType(@opponent) || PBTypes::FIRE == checkAIbestMove(@opponent.pbPartner).pbType(@opponent.pbPartner)
					when PBAbilities::LIQUIDOOZE
						for j in aimem
							abilityscore+=40 if j.id==PBMoves::LEECHSEED || j.function==0xDD || j.function==0x139 || j.function==0x158
						end
					when PBAbilities::RIVALRY
						abilityscore+=30 if i.gender==@opponent.gender && i.gender != 2 #nb
						abilityscore+=30 if i.gender==@opponent.pbPartner.gender && i.gender != 2
					when PBAbilities::SCRAPPY
						abilityscore+=30 if @opponent.pbHasType?(PBTypes::GHOST)
						abilityscore+=30 if @opponent.pbPartner.pbHasType?(PBTypes::GHOST)
					when PBAbilities::LIGHTMETAL
						abilityscore+=10 if checkAImoves([PBMoves::GRASSKNOT,PBMoves::LOWKICK],aimem)
						abilityscore+=10 if checkAImoves([PBMoves::GRASSKNOT,PBMoves::LOWKICK],aimem2) && @mondata.skill>=BESTSKILL
					when PBAbilities::ANALYTIC
						abilityscore+=30 if pbAIfaster?(nil,nil,i,@opponent)
						abilityscore+=30 if pbAIfaster?(nil,nil,i,@opponent.pbPartner)
					when PBAbilities::ILLUSION
						abilityscore+=40
					when PBAbilities::MOXIE,PBAbilities::BEASTBOOST,PBAbilities::SOULHEART
						abilityscore+=40 if pbAIfaster?(nil,nil,i,@opponent) && ((@opponent.hp.to_f)/@opponent.totalhp<0.5)
						abilityscore+=40 if pbAIfaster?(nil,nil,i,@opponent.pbPartner) && ((@opponent.pbPartner.hp.to_f)/@opponent.pbPartner.totalhp<0.5)
					when PBAbilities::SPEEDBOOST
						abilityscore+=25 if pbAIfaster?(nil,nil,i,@opponent) && ((@opponent.hp.to_f)/@opponent.totalhp<0.3)
						abilityscore+=25 if pbAIfaster?(nil,nil,i,@opponent.pbPartner) && ((@opponent.pbPartner.hp.to_f)/@opponent.pbPartner.totalhp<0.3)
					when PBAbilities::JUSTIFIED
						abilityscore+=30 if PBTypes::DARK == checkAIbestMove().pbType(@opponent) || PBTypes::DARK == checkAIbestMove(@opponent.pbPartner).pbType(@opponent.pbPartner)
					when PBAbilities::RATTLED
						abilityscore+=15 if [PBTypes::DARK,PBTypes::GHOST, PBTypes::BUG].include?(checkAIbestMove().pbType(@opponent)) || [PBTypes::DARK,PBTypes::GHOST, PBTypes::BUG].include?(checkAIbestMove(@opponent.pbPartner).pbType(@opponent.pbPartner))
					when PBAbilities::IRONBARBS,PBAbilities::ROUGHSKIN
						abilityscore+=30 if (@opponent.ability == PBAbilities::SKILLLINK)
						abilityscore+=30 if (@opponent.pbPartner.ability == PBAbilities::SKILLLINK)
					when PBAbilities::PRANKSTER
						abilityscore+=50 if pbAIfaster?(nil,nil,i,@opponent) && !@opponent.pbHasType?(PBTypes::DARK)
						abilityscore+=50 if pbAIfaster?(nil,nil,i,@opponent.pbPartner) && !@opponent.pbPartner.pbHasType?(PBTypes::DARK)
					when PBAbilities::GALEWINGS
						abilityscore+=50 if pbAIfaster?(nil,nil,i,@opponent) && i.hp==i.totalhp && !@attacker.pbOwnSide.effects[PBEffects::StealthRock]
						abilityscore+=50 if pbAIfaster?(nil,nil,i,@opponent.pbPartner) && i.hp==i.totalhp && !@attacker.pbOwnSide.effects[PBEffects::StealthRock]
					when PBAbilities::BULLETPROOF
						abilityscore+=60 if (PBStuff::BULLETMOVE).include?(checkAIbestMove().id) || (PBStuff::BULLETMOVE).include?(checkAIbestMove(@opponent.pbPartner).id)
					when PBAbilities::AURABREAK
						abilityscore+=50 if (@opponent.ability == PBAbilities::FAIRYAURA) || (@opponent.ability == PBAbilities::DARKAURA)
						abilityscore+=50 if (@opponent.pbPartner.ability == PBAbilities::FAIRYAURA) || (@opponent.pbPartner.ability == PBAbilities::DARKAURA)
					when PBAbilities::PROTEAN
						abilityscore+=40 if pbAIfaster?(nil,nil,i,@opponent) || pbAIfaster?(nil,nil,i,@opponent.pbPartner)
					when PBAbilities::DANCER
						abilityscore+=30 if checkAImoves(PBStuff::DANCEMOVE,aimem)
						abilityscore+=30 if checkAImoves(PBStuff::DANCEMOVE,aimem2) && @mondata.skill>=BESTSKILL
					when PBAbilities::MERCILESS
						abilityscore+=50 if @opponent.status==PBStatuses::POISON || @opponent.pbPartner.status==PBStatuses::POISON
					when PBAbilities::DAZZLING,PBAbilities::QUEENLYMAJESTY
						abilityscore+=20 if checkAIpriority(aimem)
						abilityscore+=20 if checkAIpriority(aimem2) && @mondata.skill>=BESTSKILL
					when PBAbilities::SANDSTREAM,PBAbilities::SNOWWARNING,PBAbilities::SANDSTREAM,PBAbilities::SNOWWARNING
						abilityscore+=70 if (@opponent.ability == PBAbilities::WONDERGUARD)
						abilityscore+=70 if (@opponent.pbPartner.ability == PBAbilities::WONDERGUARD)
					when PBAbilities::DEFEATIST
						abilityscore -= 80 if @attacker.hp != 0 # hard switch
					when PBAbilities::STURDY
						abilityscore -= 80 if @attacker.hp != 0 && i.hp == i.totalhp # hard switch
				end
			end
			if transformed  #pokemon has imposter ability. because we copy pokemon, we can use i to see ability opponent
				abilityscore+=50 if (i.ability == PBAbilities::PUREPOWER) || (i.ability == PBAbilities::HUGEPOWER) || (i.ability == PBAbilities::MOXIE) || (i.ability == PBAbilities::SPEEDBOOST) || (i.ability == PBAbilities::BEASTBOOST) || (i.ability == PBAbilities::SOULHEART) || (i.ability == PBAbilities::WONDERGUARD) || (i.ability == PBAbilities::PROTEAN)
				abilityscore+=30 if (i.level>nonmegaform.level) || pbGetMonRoles(@opponent).include?(PBMonRoles::SWEEPER)
				abilityscore = -200 if i.effects[PBEffects::Substitute] > 0
				abilityscore = -500 if i.species == PBSpecies::DITTO
			end
			monscore+=abilityscore
			PBDebug.log(sprintf("Abilities: %d",abilityscore)) if $INTERNAL
			#Items
			itemscore = 0
			if @mondata.skill>=HIGHSKILL
				if (i.item == PBItems::ROCKYHELMET)
					itemscore+=30 if (@opponent.ability == PBAbilities::SKILLLINK)
					itemscore+=30 if (@opponent.pbPartner.ability == PBAbilities::SKILLLINK)
					itemscore+=30 if checkAIbestMove(@opponent).isContactMove? || checkAIbestMove(@opponent.pbPartner).isContactMove?
				end
				if (i.item == PBItems::AIRBALLOON)
				  allground=true
				  for j in aimem
					  allground=false if !(j.pbType(@opponent) == PBTypes::GROUND)
				  end
				  if @mondata.skill>=BESTSKILL
					for j in aimem2
						allground=false if !(j.pbType(@opponent.pbPartner) == PBTypes::GROUND)
					end
				  end
				  itemscore+=60 if PBTypes::GROUND == checkAIbestMove().pbType(@opponent) || PBTypes::GROUND == checkAIbestMove(@opponent.pbPartner).pbType(@opponent.pbPartner)
				  itemscore+=100 if allground
				end
				if (i.item == PBItems::FLOATSTONE)
				  itemscore+=10 if checkAImoves([PBMoves::LOWKICK,PBMoves::GRASSKNOT],aimem)
				end
				if (i.item == PBItems::DESTINYKNOT)
				  itemscore+=20 if (@opponent.ability == PBAbilities::CUTECHARM)
				  itemscore+=20 if checkAImoves([PBMoves::ATTRACT],aimem)
				end
				if (i.item == PBItems::ABSORBBULB)
				  itemscore+=25 if PBTypes::WATER == checkAIbestMove().pbType(@opponent) || PBTypes::WATER == checkAIbestMove(@opponent.pbPartner).pbType(@opponent.pbPartner)
				end
				if (i.item == PBItems::CELLBATTERY)
				  itemscore+=25 if PBTypes::ELECTRIC == checkAIbestMove().pbType(@opponent) || PBTypes::ELECTRIC == checkAIbestMove(@opponent.pbPartner).pbType(@opponent.pbPartner)
				end
				if (((i.item == PBItems::FOCUSSASH) || (@battle.FE == PBFields::CHESSB && i.pokemon.piece==:PAWN) || ((i.ability == PBAbilities::STURDY)))) && i.hp == i.totalhp
					if 	(((@battle.weather==PBWeather::SANDSTORM && !(i.hasType?(:ROCK) || i.hasType?(:GROUND) || i.hasType?(:STEEL)))  || (@battle.weather==PBWeather::HAIL && !(i.hasType?(:ICE)))) && !((i.ability == PBAbilities::OVERCOAT)))  || @attacker.pbOwnSide.effects[PBEffects::StealthRock] ||
						@attacker.pbOwnSide.effects[PBEffects::Spikes]>0 || @attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
						if !(i.ability == PBAbilities::MAGICGUARD)
							itemscore-=40
						end
					end
					if hard_switch # hard switch
						itemscore -= 80
					end
					itemscore+= (30)*@opponent.stages[PBStats::ATTACK]
					itemscore+= (30)*@opponent.stages[PBStats::SPATK]
					itemscore+= (30)*@opponent.stages[PBStats::SPEED]
				end
				if (i.item == PBItems::SNOWBALL)
				  	itemscore+=25 if PBTypes::ICE == checkAIbestMove().pbType(@opponent) || PBTypes::ICE == checkAIbestMove(@opponent.pbPartner).pbType(@opponent.pbPartner)
				end
				if (i.item == PBItems::PROTECTIVEPADS)
					itemscore+=25 if (i.ability == PBAbilities::EFFECTSPORE) || (i.ability == PBAbilities::STATIC) || (i.ability == PBAbilities::POISONPOINT) || (i.ability == PBAbilities::ROUGHSKIN) || (i.ability == PBAbilities::IRONBARBS) || (i.ability == PBAbilities::FLAMEBODY) || (i.ability == PBAbilities::CUTECHARM) || (i.ability == PBAbilities::MUMMY) || (i.ability == PBAbilities::AFTERMATH) || (i.ability == PBAbilities::GOOEY) || ((i.ability == PBAbilities::FLUFFY) && (!@opponent.pbHasType?(PBTypes::FIRE) && !@opponent.pbPartner.pbHasType?(PBTypes::FIRE))) || (@opponent.item == PBItems::ROCKYHELMET)
				end
				if i.item == PBItems::MAGICALSEED
					itemscore+=75 if (@battle.FE == PBFields::NEWW || @battle.FE == PBFields::INVERSEF) && @attacker.hp != 0 #New World or Inverse Field, hard switch
				end
			end
			monscore+=itemscore
			PBDebug.log(sprintf("Items: %d",itemscore)) if $INTERNAL
			#Fields
			fieldscore=0
			if @mondata.skill>=BESTSKILL
			  case @battle.FE
				when PBFields::ELECTRICT
				  fieldscore+=50 if (i.ability == PBAbilities::SURGESURFER)
				  fieldscore+=25 if (i.ability == PBAbilities::GALVANIZE)
				  fieldscore+=25 if i.hasType?(:ELECTRIC)
				when PBFields::GRASSYT
				  fieldscore+=30 if (i.ability == PBAbilities::GRASSPELT)
				  fieldscore+=25 if i.hasType?(:GRASS) || i.hasType?(:FIRE)
				when PBFields::MISTYT
				  fieldscore+=20 if i.hasType?(:FAIRY)
				  fieldscore+=20 if (i.ability == PBAbilities::MARVELSCALE)
				  fieldscore+=20 if (i.ability == PBAbilities::DRYSKIN)
				  fieldscore+=20 if (i.ability == PBAbilities::WATERCOMPACTION)
				  fieldscore+=25 if (i.ability == PBAbilities::PIXILATE)
				  fieldscore+=25 if (i.ability == PBAbilities::SOULHEART)
				when PBFields::DARKCRYSTALC
				  fieldscore+=30 if (i.ability == PBAbilities::PRISMARMOR)
				  fieldscore+=30 if (i.ability == PBAbilities::SHADOWSHIELD)
				when PBFields::CHESSB
				  fieldscore+=10 if (i.ability == PBAbilities::ADAPTABILITY)
				  fieldscore+=10 if (i.ability == PBAbilities::SYNCHRONIZE)
				  fieldscore+=10 if (i.ability == PBAbilities::ANTICIPATION)
				  fieldscore+=10 if (i.ability == PBAbilities::TELEPATHY)
				when PBFields::BIGTOPA
				  fieldscore+=30 if (i.ability == PBAbilities::SHEERFORCE)
				  fieldscore+=30 if (i.ability == PBAbilities::PUREPOWER)
				  fieldscore+=30 if (i.ability == PBAbilities::HUGEPOWER)
				  fieldscore+=30 if (i.ability == PBAbilities::GUTS)
				  fieldscore+=10 if (i.ability == PBAbilities::DANCER)
				  fieldscore+=20 if i.hasType?(:FIGHTING)
				when PBFields::BURNINGF
				  fieldscore+=25 if i.hasType?(:FIRE)
				  fieldscore+=15 if (i.ability == PBAbilities::WATERVEIL)
				  fieldscore+=15 if (i.ability == PBAbilities::WATERBUBBLE)
				  fieldscore+=30 if (i.ability == PBAbilities::FLASHFIRE)
				  fieldscore+=30 if (i.ability == PBAbilities::FLAREBOOST)
				  fieldscore+=30 if (i.ability == PBAbilities::BLAZE)
				  fieldscore-=30 if (i.ability == PBAbilities::ICEBODY)
				  fieldscore-=30 if (i.ability == PBAbilities::LEAFGUARD)
				  fieldscore-=30 if (i.ability == PBAbilities::GRASSPELT)
				  fieldscore-=30 if (i.ability == PBAbilities::FLUFFY)
				when PBFields::SWAMPF
				  fieldscore+=15 if (i.ability == PBAbilities::GOOEY)
				  fieldscore+=20 if (i.ability == PBAbilities::WATERCOMPACTION)
				when PBFields::RAINBOWF
				  fieldscore+=10 if (i.ability == PBAbilities::WONDERSKIN)
				  fieldscore+=20 if (i.ability == PBAbilities::MARVELSCALE)
				  fieldscore+=25 if (i.ability == PBAbilities::SOULHEART)
				  fieldscore+=30 if (i.ability == PBAbilities::CLOUDNINE)
				  fieldscore+=30 if (i.ability == PBAbilities::PRISMARMOR)
				when PBFields::CORROSIVEF
				  fieldscore+=20 if (i.ability == PBAbilities::POISONHEAL)
				  fieldscore+=25 if (i.ability == PBAbilities::TOXICBOOST)
				  fieldscore+=30 if (i.ability == PBAbilities::MERCILESS)
				  fieldscore+=30 if (i.ability == PBAbilities::CORROSION)
				  fieldscore+=15 if i.hasType?(:POISON)
				when PBFields::CORROSIVEMISTF
				  fieldscore+=10 if (i.ability == PBAbilities::WATERCOMPACTION)
				  fieldscore+=20 if (i.ability == PBAbilities::POISONHEAL)
				  fieldscore+=25 if (i.ability == PBAbilities::TOXICBOOST)
				  fieldscore+=30 if (i.ability == PBAbilities::MERCILESS)
				  fieldscore+=30 if (i.ability == PBAbilities::CORROSION)
				  fieldscore+=15 if i.hasType?(:POISON)
				when PBFields::DESERTF
				  fieldscore+=20 if ((i.ability == PBAbilities::SANDSTREAM) || (nonmegaform.ability == PBAbilities::SANDSTREAM))
				  fieldscore+=25 if (i.ability == PBAbilities::SANDVEIL)
				  fieldscore+=30 if (i.ability == PBAbilities::SANDFORCE)
				  fieldscore+=50 if (i.ability == PBAbilities::SANDRUSH)
				  fieldscore+=20 if i.hasType?(:GROUND)
				  fieldscore-=25 if i.hasType?(:ELECTRIC)
				when PBFields::ICYF
				  fieldscore+=25 if i.hasType?(:ICE)
				  fieldscore+=25 if (i.ability == PBAbilities::ICEBODY)
				  fieldscore+=25 if (i.ability == PBAbilities::SNOWCLOAK)
				  fieldscore+=25 if (i.ability == PBAbilities::REFRIGERATE)
				  fieldscore+=50 if (i.ability == PBAbilities::SLUSHRUSH)
				when PBFields::ROCKYF
				when PBFields::FORESTF
				  fieldscore+=20 if (i.ability == PBAbilities::SAPSIPPER)
				  fieldscore+=25 if i.hasType?(:GRASS) || i.hasType?(:BUG)
				  fieldscore+=30 if (i.ability == PBAbilities::GRASSPELT)
				  fieldscore+=30 if (i.ability == PBAbilities::OVERGROW)
				  fieldscore+=30 if (i.ability == PBAbilities::SWARM)
				when PBFields::SUPERHEATEDF
				  fieldscore+=15 if i.hasType?(:FIRE)
				when PBFields::FACTORYF
				  fieldscore+=25 if i.hasType?(:ELECTRIC)
				  fieldscore+=20 if (i.ability == PBAbilities::MOTORDRIVE)
				  fieldscore+=20 if (i.ability == PBAbilities::STEELWORKER)
				  fieldscore+=25 if (i.ability == PBAbilities::DOWNLOAD)
				  fieldscore+=25 if (i.ability == PBAbilities::TECHNICIAN)
				  fieldscore+=25 if (i.ability == PBAbilities::GALVANIZE)
				when PBFields::SHORTCIRCUITF
				  fieldscore+=20 if (i.ability == PBAbilities::VOLTABSORB)
				  fieldscore+=20 if (i.ability == PBAbilities::STATIC)
				  fieldscore+=25 if (i.ability == PBAbilities::GALVANIZE)
				  fieldscore+=50 if (i.ability == PBAbilities::SURGESURFER)
				  fieldscore+=25 if i.hasType?(:ELECTRIC)
				when PBFields::WASTELAND
				  fieldscore+=10 if i.hasType?(:POISON)
				  fieldscore+=10 if (i.ability == PBAbilities::CORROSION)
				  fieldscore+=20 if (i.ability == PBAbilities::POISONHEAL)
				  fieldscore+=20 if (i.ability == PBAbilities::EFFECTSPORE)
				  fieldscore+=20 if (i.ability == PBAbilities::POISONPOINT)
				  fieldscore+=20 if (i.ability == PBAbilities::STENCH)
				  fieldscore+=20 if (i.ability == PBAbilities::GOOEY)
				  fieldscore+=25 if (i.ability == PBAbilities::TOXICBOOST)
				  fieldscore+=30 if (i.ability == PBAbilities::MERCILESS)
				when PBFields::ASHENB
				  fieldscore+=10 if i.hasType?(:FIGHTING)
				  fieldscore+=15 if (i.ability == PBAbilities::INNERFOCUS)
				  fieldscore+=15 if (i.ability == PBAbilities::OWNTEMPO)
				  fieldscore+=15 if (i.ability == PBAbilities::PUREPOWER)
				  fieldscore+=15 if (i.ability == PBAbilities::STEADFAST)
				  fieldscore+=20 if ((i.ability == PBAbilities::SANDSTREAM) || (nonmegaform.ability == PBAbilities::SANDSTREAM))
				  fieldscore+=20 if (i.ability == PBAbilities::WATERCOMPACTION)
				  fieldscore+=30 if (i.ability == PBAbilities::SANDFORCE)
				  fieldscore+=35 if (i.ability == PBAbilities::SANDVEIL)
				  fieldscore+=50 if (i.ability == PBAbilities::SANDRUSH)
				when PBFields::WATERS
				  fieldscore+=25 if i.hasType?(:WATER)
				  fieldscore+=25 if i.hasType?(:ELECTRIC)
				  fieldscore+=25 if (i.ability == PBAbilities::WATERVEIL)
				  fieldscore+=25 if (i.ability == PBAbilities::HYDRATION)
				  fieldscore+=25 if (i.ability == PBAbilities::TORRENT)
				  fieldscore+=25 if (i.ability == PBAbilities::SCHOOLING)
				  fieldscore+=25 if (i.ability == PBAbilities::WATERCOMPACTION)
				  fieldscore+=50 if (i.ability == PBAbilities::SWIFTSWIM)
				  fieldscore+=50 if (i.ability == PBAbilities::SURGESURFER)
				  mod1=PBTypes.getEffectiveness(PBTypes::WATER,i.type1)
				  mod2=(i.type1==i.type2) ? 2 : PBTypes.getEffectiveness(PBTypes::WATER,i.type2)
				  fieldscore-=50 if mod1*mod2>4
				when PBFields::UNDERWATER
				  fieldscore+=25 if i.hasType?(:WATER)
				  fieldscore+=25 if i.hasType?(:ELECTRIC)
				  fieldscore+=25 if (i.ability == PBAbilities::WATERVEIL)
				  fieldscore+=25 if (i.ability == PBAbilities::HYDRATION)
				  fieldscore+=25 if (i.ability == PBAbilities::TORRENT)
				  fieldscore+=25 if (i.ability == PBAbilities::SCHOOLING)
				  fieldscore+=25 if (i.ability == PBAbilities::WATERCOMPACTION)
				  fieldscore+=50 if (i.ability == PBAbilities::SWIFTSWIM)
				  fieldscore+=50 if (i.ability == PBAbilities::SURGESURFER)
				  mod1=PBTypes.getEffectiveness(PBTypes::WATER,i.type1)
				  mod2=(i.type1==i.type2) ? 2 : PBTypes.getEffectiveness(PBTypes::WATER,i.type2)
				  fieldscore-=50 if mod1*mod2>4
				when PBFields::CAVE
				  fieldscore+=15 if i.hasType?(:GROUND)
				when PBFields::GLITCHF
				when PBFields::CRYSTALC
				  fieldscore+=25 if i.hasType?(:DRAGON)
				  fieldscore+=30 if (i.ability == PBAbilities::PRISMARMOR)
				when PBFields::MURKWATERS
				  fieldscore+=25 if i.hasType?(:WATER)
				  fieldscore+=25 if i.hasType?(:POISON)
				  fieldscore+=25 if i.hasType?(:ELECTRIC)
				  fieldscore+=25 if (i.ability == PBAbilities::SCHOOLING)
				  fieldscore+=25 if (i.ability == PBAbilities::WATERCOMPACTION)
				  fieldscore+=25 if (i.ability == PBAbilities::TOXICBOOST)
				  fieldscore+=25 if (i.ability == PBAbilities::POISONHEAL)
				  fieldscore+=25 if (i.ability == PBAbilities::MERCILESS)
				  fieldscore+=50 if (i.ability == PBAbilities::SWIFTSWIM)
				  fieldscore+=50 if (i.ability == PBAbilities::SURGESURFER)
				  fieldscore+=20 if (i.ability == PBAbilities::GOOEY)
				  fieldscore+=20 if (i.ability == PBAbilities::STENCH)
				when PBFields::MOUNTAIN
				  fieldscore+=25 if i.hasType?(:ROCK)
				  fieldscore+=25 if i.hasType?(:FLYING)
				  fieldscore+=20 if ((i.ability == PBAbilities::SNOWWARNING) || (nonmegaform.ability == PBAbilities::SNOWWARNING))
				  fieldscore+=20 if ((i.ability == PBAbilities::DROUGHT) || (nonmegaform.ability == PBAbilities::DROUGHT))
				  fieldscore+=25 if (i.ability == PBAbilities::LONGREACH)
				  fieldscore+=30 if (i.ability == PBAbilities::GALEWINGS) && @battle.weather==PBWeather::STRONGWINDS
				when PBFields::SNOWYM
				  fieldscore+=25 if i.hasType?(:ROCK)
				  fieldscore+=25 if i.hasType?(:FLYING)
				  fieldscore+=25 if i.hasType?(:ICE)
				  fieldscore+=20 if ((i.ability == PBAbilities::SNOWWARNING) || (nonmegaform.ability == PBAbilities::DROUGHT))
				  fieldscore+=20 if ((i.ability == PBAbilities::DROUGHT) || (nonmegaform.ability == PBAbilities::DROUGHT))
				  fieldscore+=20 if (i.ability == PBAbilities::ICEBODY)
				  fieldscore+=20 if (i.ability == PBAbilities::SNOWCLOAK)
				  fieldscore+=25 if (i.ability == PBAbilities::LONGREACH)
				  fieldscore+=25 if (i.ability == PBAbilities::REFRIGERATE)
				  fieldscore+=30 if (i.ability == PBAbilities::GALEWINGS) && @battle.weather==PBWeather::STRONGWINDS
				  fieldscore+=50 if (i.ability == PBAbilities::SLUSHRUSH)
				when PBFields::HOLYF
				  fieldscore+=20 if i.hasType?(:NORMAL)
				  fieldscore+=20 if (i.ability == PBAbilities::JUSTIFIED)
				when PBFields::MIRRORA
				  fieldscore+=25 if (i.ability == PBAbilities::SANDVEIL)
				  fieldscore+=25 if (i.ability == PBAbilities::SNOWCLOAK)
				  fieldscore+=25 if (i.ability == PBAbilities::ILLUSION)
				  fieldscore+=25 if (i.ability == PBAbilities::TANGLEDFEET)
				  fieldscore+=25 if (i.ability == PBAbilities::MAGICBOUNCE)
				  fieldscore+=25 if (i.ability == PBAbilities::COLORCHANGE)
				when PBFields::FAIRYTALEF
				  fieldscore+=25 if i.hasType?(:FAIRY)
				  fieldscore+=25 if i.hasType?(:STEEL)
				  fieldscore+=40 if i.hasType?(:DRAGON)
				  fieldscore+=25 if (i.ability == PBAbilities::POWEROFALCHEMY)
				  fieldscore+=25 if ((i.ability == PBAbilities::MAGICGUARD) || (nonmegaform.ability == PBAbilities::MAGICGUARD))
				  fieldscore+=25 if (i.ability == PBAbilities::MAGICBOUNCE)
				  fieldscore+=25 if (i.ability == PBAbilities::FAIRYAURA)
				  fieldscore+=25 if (i.ability == PBAbilities::BATTLEARMOR)
				  fieldscore+=25 if (i.ability == PBAbilities::SHELLARMOR)
				  fieldscore+=25 if (i.ability == PBAbilities::MAGICIAN)
				  fieldscore+=25 if (i.ability == PBAbilities::MARVELSCALE)
				  fieldscore+=30 if (i.ability == PBAbilities::STANCECHANGE)
				when PBFields::DRAGONSD
				  fieldscore+=25 if i.hasType?(:FIRE)
				  fieldscore+=50 if i.hasType?(:DRAGON)
				  fieldscore+=20 if (i.ability == PBAbilities::MARVELSCALE)
				  fieldscore+=20 if (i.ability == PBAbilities::MULTISCALE)
				  fieldscore+=20 if ((i.ability == PBAbilities::MAGMAARMOR) || (nonmegaform.ability == PBAbilities::MAGMAARMOR))
				when PBFields::FLOWERGARDENF
				  fieldscore+=25 if i.hasType?(:GRASS)
				  fieldscore+=25 if i.hasType?(:BUG)
				  fieldscore+=20 if (i.ability == PBAbilities::FLOWERGIFT)
				  fieldscore+=20 if (i.ability == PBAbilities::FLOWERVEIL)
				  fieldscore+=20 if ((i.ability == PBAbilities::DROUGHT) || (nonmegaform.ability == PBAbilities::DROUGHT))
				  fieldscore+=20 if ((i.ability == PBAbilities::DRIZZLE) || (nonmegaform.ability == PBAbilities::DRIZZLE))
				when PBFields::STARLIGHTA
				  fieldscore+=25 if i.hasType?(:PSYCHIC)
				  fieldscore+=25 if i.hasType?(:FAIRY)
				  fieldscore+=25 if i.hasType?(:DARK)
				  fieldscore+=20 if (i.ability == PBAbilities::MARVELSCALE)
				  fieldscore+=20 if (i.ability == PBAbilities::VICTORYSTAR)
				  fieldscore+=25 if ((i.ability == PBAbilities::ILLUMINATE) || (nonmegaform.ability == PBAbilities::ILLUMINATE))
				  fieldscore+=30 if (i.ability == PBAbilities::SHADOWSHIELD)
				when PBFields::NEWW
				  fieldscore+=25 if i.hasType?(:FLYING)
				  fieldscore+=25 if i.hasType?(:DARK)
				  fieldscore+=20 if (i.ability == PBAbilities::VICTORYSTAR)
				  fieldscore+=25 if (i.ability == PBAbilities::LEVITATE)
				  fieldscore+=30 if (i.ability == PBAbilities::SHADOWSHIELD)
				when PBFields::INVERSEF
				  fieldscore+=10 if i.hasType?(:NORMAL)
				  fieldscore+=10 if i.hasType?(:ICE)
				  fieldscore-=10 if i.hasType?(:FIRE)
				  fieldscore-=30 if i.hasType?(:STEEL)
				when PBFields::PSYCHICT
				  fieldscore+=25 if i.hasType?(:PSYCHIC)
				  fieldscore+=20 if (i.ability == PBAbilities::PUREPOWER)
				  fieldscore+=20 if ((i.ability == PBAbilities::ANTICIPATION) || (nonmegaform.ability == PBAbilities::ANTICIPATION))
				  fieldscore+=50 if (i.ability == PBAbilities::TELEPATHY)
			  end
			end
			monscore += fieldscore
			PBDebug.log(sprintf("Fields: %d",fieldscore)) if $INTERNAL
			#Other
			otherscore = 0
			otherscore -= 70 if hard_switch && @attacker.species == i.species
			otherscore -= 100 if @opponent.ability == PBAbilities::WONDERGUARD && roughdamagearray[0].max == 0
			if @attacker.effects[PBEffects::FutureSight] >= 1
				move, moveuser = @attacker.pbFutureSightUserPlusMove
				damage = hard_switch ? pbRoughDamage(move,moveuser,nonmegaform) : pbRoughDamage(move,moveuser,i)
				otherscore += 50 if damage == 0
				otherscore += 50 if damage < i.hp
				otherscore += 50 if 2*damage < i.hp
				otherscore -= 100 if damage > i.hp
			end
			
			monscore += otherscore
			PBDebug.log(sprintf("Other Score: %d",otherscore)) if $INTERNAL

			if @attacker.pbOwnSide.effects[PBEffects::StealthRock] || @attacker.pbOwnSide.effects[PBEffects::Spikes]>0
			  monscore= (monscore*(i.hp.to_f/i.totalhp.to_f)).floor
			end
			hazpercent = totalHazardDamage(nonmegaform)
			monscore=1 if hazpercent>(i.hp.to_f/i.totalhp)*100
			# more likely to send out ace the fewer party members are alive
			partyacedrop = 0.9 - 0.1 * party.count {|mon| mon && mon.hp > 0}

			monscore*= partyacedrop if theseRoles.include?(PBMonRoles::ACE) && @mondata.skill>=BESTSKILL
			#Final score
			monscore.floor
			PBDebug.log(sprintf("Final Pokemon Score: %d \n",monscore)) if $INTERNAL
			$ai_log_data[@attacker.index].switch_scores.push(monscore)
			$ai_log_data[@attacker.index].switch_name.push(PBSpecies.getName(i.pokemon.species))
			partyScores.push(monscore)
		end
		return partyScores
	end

	#should the current @attacker switch out?
	def shouldSwitch?
		return -1000 if !@battle.opponent && @battle.pbIsOpposing?(@attacker.index)
		return -1000 if @battle.pbPokemonCount(@mondata.party) == 1
		return -1000 if $game_switches[:Last_Ace_Switch] && @battle.pbPokemonCount(@mondata.party) == 2
		count = 0
		for i in 0..(@mondata.party.length-1)
			next if !@battle.pbCanSwitch?(@attacker.index,i,false)
			count+=1
		end
		return -1000 if count==0
		aimem = getAIMemory(@opponent)
		aimem2 = getAIMemory(@opponent.pbPartner)
		statusscore = 0
		statscore = 0
		healscore = 0
		forcedscore = 0
		typescore = 0
		specialscore = 0
		#Statuses
		statusscore+=80 if @attacker.effects[PBEffects::Curse]
		statusscore+=60 if @attacker.effects[PBEffects::LeechSeed]>=0
		statusscore+=60 if @attacker.effects[PBEffects::Attract]>=0
		statusscore+=80 if @attacker.effects[PBEffects::Confusion]>0
		if @attacker.effects[PBEffects::PerishSong]==2
			statusscore+=40
		elsif @attacker.effects[PBEffects::PerishSong]==1
			statusscore+=200
		end
		statusscore+= (@attacker.effects[PBEffects::Toxic]*15) if @attacker.effects[PBEffects::Toxic]>0
		statusscore+=50 if @attacker.ability == PBAbilities::NATURALCURE && @attacker.status!=0
		statusscore+=60 if @mondata.partyroles.any? {|roles| roles.include?(PBMonRoles::CLERIC)} && @attacker.status!=0
		if @attacker.status==PBStatuses::SLEEP
			statusscore+=170 if checkAImoves([PBMoves::DREAMEATER,PBMoves::NIGHTMARE],aimem)
		end
		statusscore+=95 if @attacker.effects[PBEffects::Yawn]>0 && @attacker.status!=PBStatuses::SLEEP
		PBDebug.log(sprintf("Initial switchscore building: Statuses (%d)",statusscore)) if $INTERNAL
		#Stat changes
		specialmove = false
		physmove = false
		for i in @attacker.moves
			next if i.nil?
			specialmove = true if i.pbIsSpecial?()
			physmove = true if i.pbIsPhysical?()
		end
		if @mondata.roles.include?(PBMonRoles::SWEEPER)
			statscore+= (-30)*@attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK]<0 && physmove
			statscore+= (-30)*@attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK]<0 && specialmove
			statscore+= (-30)*@attacker.stages[PBStats::SPEED] if @attacker.stages[PBStats::SPEED]<0
			statscore+= (-30)*@attacker.stages[PBStats::ACCURACY] if @attacker.stages[PBStats::ACCURACY]<0
		else
			statscore+= (-15)*@attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK]<0 && physmove
			statscore+= (-15)*@attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK]<0 && specialmove
			statscore+= (-15)*@attacker.stages[PBStats::SPEED] if @attacker.stages[PBStats::SPEED]<0
			statscore+= (-15)*@attacker.stages[PBStats::ACCURACY] if @attacker.stages[PBStats::ACCURACY]<0
		end
		if @mondata.roles.include?(PBMonRoles::PHYSICALWALL)
			statscore+= (-30)*@attacker.stages[PBStats::DEFENSE] if @attacker.stages[PBStats::DEFENSE]<0
		else
			statscore+= (-15)*@attacker.stages[PBStats::DEFENSE] if @attacker.stages[PBStats::DEFENSE]<0
		end
		if @mondata.roles.include?(PBMonRoles::SPECIALWALL)
			statscore+= (-30)*@attacker.stages[PBStats::SPDEF] if @attacker.stages[PBStats::SPDEF]<0
		else
			statscore+= (-15)*@attacker.stages[PBStats::SPDEF] if @attacker.stages[PBStats::SPDEF]<0
		end
		PBDebug.log(sprintf("Initial switchscore building: Stat Stages (%d)",statscore)) if $INTERNAL
		#Healing potential
		healscore+=30 if (@attacker.hp.to_f)/@attacker.totalhp<(2/3) && @attacker.ability == PBAbilities::REGENERATOR
		if @attacker.effects[PBEffects::Wish]>0
			for i in @mondata.party
				next if i.nil? || i.hp == 0 || @mondata.party.index(i) == @attacker.pokemonIndex
				if i.hp > 0.3*i.totalhp && i.hp < 0.6*i.totalhp
					healscore+=40
					break
				end
			end
		end
		PBDebug.log(sprintf("Initial switchscore building: Healing (%d)",healscore)) if $INTERNAL
		#Force-out conditions
		bothimmune = true
		bothimmune = false if @attacker.species==PBSpecies::COSMOEM && Reborn # for postgame only
		for i in @attacker.moves
			next if i.nil?
			tricktreat = true if i.id==PBMoves::TRICKORTREAT
			forestcurse = true if i.id==PBMoves::FORESTSCURSE
			notnorm = true if i.type != (PBTypes::NORMAL)
			bothimmune = false if i.id==PBMoves::DESTINYBOND

			for oppmon in [@opponent, @opponent.pbPartner]
				next if oppmon.hp <= 0
				bothimmune = false if [0x05,0x06,0x017].include?(i.function) && i.basedamage==0 && (oppmon.pbCanPoison?(false,false,i.id==PBMoves::TOXIC && @attacker.ability==PBAbilities::CORROSION) && !hydrationCheck(oppmon)) || oppmon.status == PBStatuses::POISON
				bothimmune = false if i.id==PBMoves::PERISHSONG && !(oppmon.ability == PBAbilities::SOUNDPROOF && !moldBreakerCheck(@attacker))
				bothimmune = false if i.function == 0xdc && (noLeechSeed(oppmon) == false || oppmon.effects[PBEffects::LeechSeed] > -1)
				if i.basedamage > 0
					typemod = pbTypeModNoMessages(i.pbType(@attacker),@attacker,oppmon,i)
					typemod = 0 if oppmon.ability == PBAbilities::WONDERGUARD && typemod<=4
					bothimmune = false if typemod != 0
				end
			end
		end
		if bothimmune
			bothimmune = false if (tricktreat && notnorm) || forestcurse
			forcedscore+=140 if bothimmune
		end
		for i in 0...@attacker.moves.length
			next if @attacker.moves[i].nil? || !@battle.pbCanChooseMove?(@attacker.index,i,false)
			haspp = true if @attacker.moves[i].pp != 0
		end
		forcedscore+=200 if !haspp
		forcedscore+=30 if @attacker.effects[PBEffects::Torment]== true
		if @attacker.effects[PBEffects::Encore]>0
			if @opponent.hp>0
				encoreScore = @mondata.scorearray[@opponent.index][@attacker.effects[PBEffects::EncoreIndex]]
			elsif @opponent.pbPartner.hp>0
				encoreScore = @mondata.scorearray[@opponent.pbPartner.index][@attacker.effects[PBEffects::EncoreIndex]]
			else
				encoreScore = 100
			end
			forcedscore+=200 if encoreScore <= 30
			forcedscore+=110 if @attacker.effects[PBEffects::Torment]== true
		end
		if (@attacker.item == PBItems::CHOICEBAND || @attacker.item == PBItems::CHOICESPECS || @attacker.item == PBItems::CHOICESCARF) && @attacker.effects[PBEffects::ChoiceBand]>=0
			for i in 0...4
				if @attacker.moves[i].id==@attacker.effects[PBEffects::ChoiceBand]
					choiceindex = i
					break
				end
			end
			if choiceindex
				if @opponent.hp>0
					choiceScore = @mondata.scorearray[@opponent.index][choiceindex]
				elsif @opponent.pbPartner.hp>0
					choiceScore = @mondata.scorearray[@opponent.pbPartner.index][choiceindex]
				end
			else
				choiceScore = 0
			end
			forcedscore+=50 if choiceScore <= 50
			forcedscore+=130 if choiceScore <= 30
			forcedscore+=150 if choiceScore <= 10
		end
		PBDebug.log(sprintf("Initial switchscore building: fsteak (%d)",forcedscore)) if $INTERNAL
		#Type effectiveness
		effcheck = PBTypes.getCombinedEffectiveness(@opponent.type1,@attacker.type1,@attacker.type2)
		if effcheck > 4
			typescore+=20
		elsif effcheck < 4
			typescore-=20
		end
		effcheck2 = PBTypes.getCombinedEffectiveness(@opponent.type2,@attacker.type1,@attacker.type2)
		if effcheck2 > 4
			typescore+=20
		elsif effcheck2 < 4
			typescore-=20
		end
		if @opponent.pbPartner.totalhp !=0
			typescore *= 0.5
			effcheck = PBTypes.getCombinedEffectiveness(@opponent.pbPartner.type1,@attacker.type1,@attacker.type2)
			if effcheck > 4
				typescore+=10
			elsif effcheck < 4
				typescore-=10
			end
			effcheck2 = PBTypes.getCombinedEffectiveness(@opponent.pbPartner.type2,@attacker.type1,@attacker.type2)
			if effcheck2 > 4
				typescore+=10
			elsif effcheck2 < 4
				typescore-=10
			end
		end
		PBDebug.log(sprintf("Initial switchscore building: Typing (%d)",typescore)) if $INTERNAL
		#Special cases
		# If the opponent just switched in to counter you
		if !@battle.doublebattle && @opponent.turncount == 0 && checkAIdamage() > @attacker.hp &&
			 @attacker.hp > 0.6 * @attacker.totalhp && !notOHKO?(@attacker,@opponent,true)
			specialscore += 100
		end
		# If future sight is about to trigger
		if @attacker.effects[PBEffects::FutureSight] == 1
			move, moveuser = @attacker.pbFutureSightUserPlusMove
			damage = pbRoughDamage(move,moveuser,@attacker)
			specialscore += 50 if damage > @attacker.hp
			specialscore += 50 if 2*damage > @attacker.hp
		end
		#If opponent is in a two turn attack
		if !@battle.doublebattle && @opponent.effects[PBEffects::TwoTurnAttack]>0 #this section really doesn't work in doubles.
			twoturntype = $cache.pkmn_move[@opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::TYPE]
			for i in @mondata.party
				next if i.nil? || i.hp == 0 || @mondata.party.index(i) == @attacker.pokemonIndex
				if @attacker.moves[0].pbTypeModifierNonBattler(twoturntype,@opponent,i) < 4
					specialscore += 80
					break
				end
			end
		end
		# If trainer has unburned activated
		specialscore -= 30 if @attacker.unburdened
		
		for oppmon in [@opponent,@opponent.pbPartner]
			next if oppmon.hp <= 0
			#Good Switch for two-turn attack
			if !pbAIfaster?(nil,nil,@attacker,oppmon) && oppmon.effects[PBEffects::TwoTurnAttack]>0
				twoturntype = $cache.pkmn_move[@opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::TYPE]
				bestmove = checkAIbestMove(oppmon)
				for i in @mondata.party
					next if i.nil? || i.hp == 0 || @mondata.party.index(i) == @attacker.pokemonIndex
					if bestmove.pbTypeModifierNonBattler(twoturntype,oppmon,i) < 4
						specialscore += 80 
						specialscore += 80 if bestmove.pbTypeModifierNonBattler(twoturntype,oppmon,i) < 4
						break
					end
				end
			end
			#Getting around fake out
			if checkAImoves([PBMoves::FAKEOUT],getAIMemory(oppmon)) && oppmon.turncount == 1
				for i in @mondata.party
					count+=1
					next if i.nil? || i.hp == 0 || @mondata.party.index(i) == @attacker.pokemonIndex
					if (i.ability == PBAbilities::STEADFAST)
						specialscore+=90
						break
					end
				end
			end
			#punishing skill-link multi-hit contact moves
			if oppmon.ability == PBAbilities::SKILLLINK
				if getAIMemory(oppmon).any? {|moveloop| moveloop!=nil && moveloop.function==0xC0 && moveloop.isContactMove?}
					for i in @mondata.party
						next if i.nil? || i.hp == 0 || @mondata.party.index(i) == @attacker.pokemonIndex
						if (i.item == PBItems::ROCKYHELMET) || (i.ability == PBAbilities::ROUGHSKIN) || (i.ability == PBAbilities::IRONBARBS)
							specialscore+=70
							break
						end
					end
				end
			end
			#Justified switch vs dark attack moves
			bestmove=checkAIbestMove()
			if bestmove.pbType(@opponent) == PBTypes::DARK && @attacker.ability != PBAbilities::JUSTIFIED
				for i in @mondata.party
					next if i.nil? || i.hp == 0 || @mondata.party.index(i) == @attacker.pokemonIndex
					if i.ability==PBAbilities::JUSTIFIED
						specialscore+=70
						break
					end
				end
			end
		end
		PBDebug.log(sprintf("Initial switchscore building: Specific Switches (%d)",specialscore)) if $INTERNAL
		switchscore = statusscore + statscore + healscore + forcedscore + typescore + specialscore
		PBDebug.log(sprintf("%s: initial switchscore: %d" ,PBSpecies.getName(@attacker.species),switchscore)) if $INTERNAL
		statantiscore = 0
		specialmove = false
		physmove = false
		for i in @attacker.moves
			next if i.nil?
			specialmove = true if i.pbIsSpecial?()
			physmove = true if i.pbIsPhysical?()
		end
		if @mondata.roles.include?(PBMonRoles::SWEEPER)
			statantiscore += (30)*@attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK]>0 && physmove
			statantiscore += (30)*@attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK]>0 && specialmove
			statantiscore += (30)*@attacker.stages[PBStats::SPEED] if @attacker.stages[PBStats::SPEED]>0 unless (@mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL) || @mondata.roles.include?(PBMonRoles::TANK))
			statantiscore += (30)*@attacker.effects[PBEffects::FocusEnergy]
		else
			statantiscore += (15)*@attacker.stages[PBStats::ATTACK] if @attacker.stages[PBStats::ATTACK]>0 && physmove
			statantiscore += (15)*@attacker.stages[PBStats::SPATK] if @attacker.stages[PBStats::SPATK]>0 && specialmove
			statantiscore += (15)*@attacker.stages[PBStats::SPEED] if @attacker.stages[PBStats::SPEED]>0 unless (@mondata.roles.include?(PBMonRoles::PHYSICALWALL) || @mondata.roles.include?(PBMonRoles::SPECIALWALL) || @mondata.roles.include?(PBMonRoles::TANK))
			statantiscore += (30)*@attacker.effects[PBEffects::FocusEnergy]
		end
		if @mondata.roles.include?(PBMonRoles::PHYSICALWALL)
			statantiscore += (30)*@attacker.stages[PBStats::DEFENSE] if @attacker.stages[PBStats::DEFENSE]>0
		else
			statantiscore += (15)*@attacker.stages[PBStats::DEFENSE] if @attacker.stages[PBStats::DEFENSE]>0
		end
		if @mondata.roles.include?(PBMonRoles::SPECIALWALL)
			statantiscore += (30)*@attacker.stages[PBStats::SPDEF] if @attacker.stages[PBStats::SPDEF]>0
		else
			statantiscore += (15)*@attacker.stages[PBStats::SPDEF] if @attacker.stages[PBStats::SPDEF]>0
		end
		statantiscore += (20)*@attacker.stages[PBStats::EVASION] if @attacker.stages[PBStats::EVASION]>0 && !(checkAIaccuracy(aimem) || checkAIaccuracy(aimem2))
		statantiscore += 100 if @attacker.effects[PBEffects::Substitute] > 0
		PBDebug.log(sprintf("Initial noswitchscore building: Stat Stages (%d)",statantiscore)) if $INTERNAL
		hazardantiscore = 0
		hazardantiscore+= (15)*@attacker.pbOwnSide.effects[PBEffects::Spikes]
		hazardantiscore+= (15)*@attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]
		hazardantiscore+= (15) if @attacker.pbOwnSide.effects[PBEffects::StealthRock]
		hazardantiscore+= (15) if @attacker.pbOwnSide.effects[PBEffects::StickyWeb]
		hazardantiscore+= (15) if (@attacker.pbOwnSide.effects[PBEffects::StickyWeb] && @mondata.roles.include?(PBMonRoles::SWEEPER))
		airmon = @attacker.isAirborne?
		hazarddam = totalHazardDamage(@attacker)
		if ((@attacker.hp.to_f)/@attacker.totalhp)*100 < hazarddam
		  	hazardantiscore+= 100
		end
		temppartyko = true
		for i in @mondata.party
			next if i.nil?
			next if @mondata.party.index(i) == @attacker.pokemonIndex
			next if @mondata.partyroles[@mondata.party.find_index(i)].include?(PBMonRoles::ACE) && hazardantiscore > 0
			i = pbMakeFakeBattler(i)
			temppartyko = false if ((i.hp.to_f)/i.totalhp)*100 > totalHazardDamage(i)
		end
		hazardantiscore+= 200 if temppartyko
		PBDebug.log(sprintf("Initial noswitchscore building: Entry Hazards (%d)",hazardantiscore)) if $INTERNAL
		# Better Switching Options
		betterswitchscore = 0
		if pbAIfaster?(nil,nil,@attacker,@opponent) && pbAIfaster?(nil,nil,@attacker,@opponent.pbPartner)
			betterswitchscore+=90 if @attacker.pbHasMove?(PBMoves::VOLTSWITCH) || @attacker.pbHasMove?(PBMoves::UTURN)
		end
		betterswitchscore+=100 if @attacker.turncount==0
		betterswitchscore+=90 if @attacker.effects[PBEffects::PerishSong]==0 && @attacker.pbHasMove?(PBMoves::BATONPASS)
		betterswitchscore+=60 if @attacker.ability == PBAbilities::WIMPOUT || @attacker.ability == PBAbilities::EMERGENCYEXIT
		PBDebug.log(sprintf("Initial noswitchscore building: Alternate Switching Options (%d)",betterswitchscore)) if $INTERNAL
		secondwindscore = 0
		#Can you kill them before they kill you?
		for oppmon in [@opponent,@opponent.pbPartner]
			next if oppmon.hp <=0
			if !checkAIpriority()
				if pbAIfaster?(nil,nil,@attacker,oppmon)
					secondwindscore +=130 if @mondata.roughdamagearray[oppmon.index].any? {|movescore| movescore > 100}
				end
			else
				for i in 0...@attacker.moves.length
					next if @attacker.moves[i].nil?
					next if !@attacker.moves[i].pbIsPriorityMoveAI(@attacker)
					secondwindscore +=130 if @mondata.roughdamagearray[oppmon.index][i] > 100 && pbAIfaster?(nil,nil,@attacker,oppmon)
				end
			end
		end
		monturn = (50 - (@attacker.turncount*25))
		monturn /= 1.5 if @mondata.roles.include?(PBMonRoles::LEAD)
		secondwindscore += monturn if monturn > 0
		PBDebug.log(sprintf("Initial noswitchscore building: Second Wind Situations (%d)",secondwindscore)) if $INTERNAL
		noswitchscore = statantiscore + hazardantiscore + betterswitchscore + secondwindscore
		noswitchscore += 999 if Reborn == true && !@battle.doublebattle && @battle.opponent.name=="Priscilla"
		PBDebug.log(sprintf("%s: initial noswitchscore: %d",PBSpecies.getName(@attacker.species),noswitchscore)) if $INTERNAL
		finalscore = switchscore - noswitchscore
		finalscore/=2.0 if @mondata.skill<HIGHSKILL
		finalscore-=100 if @mondata.skill<MEDIUMSKILL
		return finalscore
	end

	def pbStatChangingSwitch(mon)
		# Sticky Web
		if mon.pbOwnSide.effects[PBEffects::StickyWeb] && !mon.isAirborne?
			drop = @battle.FE == PBFields::FORESTF ? 2 : 1
			mon.stages[PBStats::SPEED]-= drop unless mon.item == PBItems::WHITEHERB || mon.ability == PBAbilities::WHITESMOKE || mon.ability == PBAbilities::CLEARBODY
			mon.unburdened = true 			  if mon.ability == PBAbilities::UNBURDEN && mon.item == PBItems::WHITEHERB
		end

		# Seed Stat boosts
		if mon.item == @battle.field.seeds[:seedtype]
			mon.unburdened = true if mon.ability == PBAbilities::UNBURDEN
			@battle.field.seeds[:stats].each_pair {|stat,statval| mon.stages[stat]+=statval}
		end
	
		#Contrary
		if mon.ability==PBAbilities::CONTRARY
			for stage in 0...mon.stages.length
				next if mon.stages[stage].nil?
				mon.stages[stage] = -1*mon.stages[stage]
			end
		end
	end

	def shouldHardSwitch?(attacker,switch_in_index)
		for i in 0...attacker.moves.length
			return true if !@battle.pbCanChooseMove?(attacker.index,i,false) 
		end
		return true if attacker.effects[PBEffects::PerishSong]>0
		switch_in = pbMakeFakeBattler(@battle.pbParty(attacker.index)[switch_in_index])
		opponent = firstOpponent()
		return true if $cache.pkmn_move[opponent.lastMoveUsed][PBMoveData::CATEGORY] == 2
		#check if the switch_in would just straight up die from assumed move used
		assumed_damage = 0
		assumed_damage += totalHazardDamage(switch_in)*switch_in.totalhp / 100
		assumed_move = checkAIbestMove(opponent,attacker)
		assumed_damage = pbRoughDamage(assumed_move,@opponent,switch_in)

		return false if assumed_damage > switch_in.hp
		switch_in.hp -= assumed_damage
		return false if !canKillBeforeOpponentKills?(switch_in,opponent)
		return true
	end

	def canKillBeforeOpponentKills?(attacker,opponent)
		#first check what move is fastest for attacker and opponent
		attmovearray, attdamagearray = checkAIMovePlusDamage(attacker,opponent,wholearray: true)
		oppmovearray, oppdamagearray = checkAIMovePlusDamage(opponent,attacker,wholearray: true)
		attdamagearray.map! {|score| score > 0 && notOHKO?(attacker,opponent,true) ? score-1 : score }
		oppdamagearray.map! {|score| score > 0 && notOHKO?(opponent,attacker,true) ? score-1 : score }
		
		#filter out all moves that actually kill
		attmovearray.filter!.with_index {|move, index| attdamagearray[index] >= opponent.hp }
		oppmovearray.filter!.with_index {|move, index| oppdamagearray[index] >= attacker.hp }
		attdamagearray.filter! {|score| score >= opponent.hp }
		oppdamagearray.filter! {|score| score >= attacker.hp }
		return true if oppmovearray.length==0
		return false if attmovearray.length==0

		#check if there are any moves the attacker has that would move before all moves of opponent
		return attmovearray.any? {|attmove| oppmovearray.all? {|oppmove| pbAIfaster?(attmove,oppmove,attacker,opponent) } }
	end


################################################################################
# AI Memory utility functions
################################################################################

	def addMoveToMemory(battler,move)
		return if move.nil? || move==-1 || move.id==0
		trainer = @battle.pbGetOwner(battler.index)
		return if !trainer #wild battle
		#check if pokemon is added to trainer array, add if isn't the case
		@aiMoveMemory[trainer][battler.pokemon.personalID] = [] if !@aiMoveMemory[trainer].key?(battler.pokemon.personalID)
		knownmoves = @aiMoveMemory[trainer][battler.pokemon.personalID]
		return if knownmoves.any? {|moveloop| moveloop!=nil && moveloop.id == move.id} #move is already added to memory
		#update the move memory by taking current known move array and add new move in array form to it
		@aiMoveMemory[trainer][battler.pokemon.personalID] = knownmoves.push(move)
	end

	def addMonToMemory(pkmn,index)
		trainer = @battle.pbGetOwner(index)
		return if !trainer #wild battle
		@aiMoveMemory[trainer][pkmn.personalID] = [] if !@aiMoveMemory[trainer].key?(pkmn.personalID)
	end

	def getAIMemory(battler=@opponent)
		return [] if battler.hp == 0
		trainer = @battle.pbGetOwner(battler.index)
		return [] if !trainer
		if (@mondata.index==battler.index || @mondata.index==battler.pbPartner.index) && battler.is_a?(PokeBattle_Battler)
			#we're checking out own moves stupid
			ret= @mondata.index==battler.index ? battler.moves : battler.pbPartner.moves
			return ret.find_all {|moveloop| moveloop && moveloop.id > 0}
		elsif battler.is_a?(PokeBattle_Battler)
			#we're dealing with enemy battler
			if @aiMoveMemory[trainer][battler.pokemon.personalID]
				return @aiMoveMemory[trainer][battler.pokemon.personalID]
			else
				return []
			end
		elsif battler.is_a?(PokeBattle_Pokemon)
			#we're dealing with mon not on field
			for key in @aiMoveMemory.keys
				return @aiMoveMemory[key][battler.personalID] if @aiMoveMemory[key].key?(battler.personalID)
			end
			return []
		end
	end

	def getAIKnownParty(battler)
		trainer = @battle.pbGetOwner(battler.index)
		return [] if !trainer
		party = @battle.pbPartySingleOwner(battler.index)
		knownparty = party.find_all {|mon| mon.hp > 0 && @aiMoveMemory[trainer].keys.include?(mon.personalID) }
		return knownparty
	end

	def checkAImoves(moveID,memory=nil)
		memory=getAIMemory(@opponent) if memory.nil?
		#basic "does the other mon have x"
		for i in moveID
			for j in memory
				move = pbChangeMove(j,@opponent)
				return true if i == move.id #i should already be an ID here
			end
		end
		return false
	end

	def checkAIhealing(memory=nil)
		memory=getAIMemory(@opponent) if memory.nil?
		#less basic "can the other mon heal"
		for j in memory
			return true if j.isHealingMove?
		end
		return false
	end

	def checkAIpriority(memory=nil)
		opp = memory.nil? ? @opponent : nil
		memory=getAIMemory(@opponent) if memory.nil?
		#"does the other mon have priority"
		for j in memory
			if opp
				return true if j.pbIsPriorityMoveAI(opp)
			else
				return true if j.priority > 0
			end
		end
		return false
	end

	def checkAIaccuracy(memory=nil)
		memory=getAIMemory(@opponent) if memory.nil?
		#"does the other mon have moves that don't miss"
		for j in memory
			move = pbChangeMove(j,@opponent)
			return true if move.accuracy==0
		end
		return false
	end

	def checkAIMovePlusDamage(opponent=@opponent, attacker=@attacker, memory=nil, wholearray: false)
		# Opponent is the one attacking, bit confusing i know
		return [[],[]] if wholearray && (!opponent || opponent.hp == 0)
		return [PokeBattle_Struggle.new(@battle,nil,nil),0] if !opponent || opponent.hp == 0
		memory=getAIMemory(opponent) if memory.nil?
		damagearray = []
		movearray = []
		if @mondata.skill >= HIGHSKILL && memory.length < opponent.moves.count {|move| !move.nil? && move.id > 0}
			unless memory.any? {|moveloop| moveloop!=nil && moveloop.pbType(opponent)==opponent.type1 && moveloop.category != 2}
				stabmove1 = PokeBattle_Move_FFF.new(@battle,opponent, opponent.type1)
				damagearray.push(pbRoughDamage(stabmove1,opponent,attacker))
				movearray.push(stabmove1)
			end
			unless memory.any? {|moveloop| moveloop!=nil && moveloop.pbType(opponent)==opponent.type2 && moveloop.category != 2} || opponent.type1 == opponent.type2
				stabmove2 = PokeBattle_Move_FFF.new(@battle,opponent, opponent.type2)
				damagearray.push(pbRoughDamage(stabmove2,opponent,attacker))
				movearray.push(stabmove2)
			end
		end
		for j in memory
			damagearray.push(pbRoughDamage(j,opponent,attacker))
			movearray.push(j)
		end
		return [movearray, damagearray] if wholearray
		return [PokeBattle_Struggle.new(@battle,nil,nil),0] if damagearray.empty?
		return [movearray[damagearray.index(damagearray.max)],damagearray.max]
	end

	def checkAIdamage(attacker=@attacker,opponent=@opponent,memory=nil)
		bestmove, damage = checkAIMovePlusDamage(opponent, attacker, memory)
		return damage
	end 

	def checkAIbestMove(opponent=@opponent, attacker=@attacker, memory=nil)
		bestmove, damage = checkAIMovePlusDamage(opponent, attacker, memory)
		return bestmove
	end

	

######################################################
# AI Damage Calc
######################################################
	def pbRoughDamage(move=@move,attacker=@attacker,opponent=@opponent)
		return 0 if opponent.species==0 || attacker.species==0
		return 0 if opponent.hp==0 || attacker.hp==0
		return 0 if move.pp==0
		oldmove = move
		move = pbChangeMove(move,attacker)
		basedamage = move.basedamage
		return 0 if move.basedamage==0
		typemod=pbTypeModNoMessages(move.type,attacker,opponent,move)
		typemod=pbTypeModNoMessages(move.pbType(attacker),attacker,opponent,move) if @mondata.skill >= HIGHSKILL
		return typemod if typemod<=0
		return 0 if !moveSuccesful?(oldmove,attacker,opponent)
		return 0 if opponent.totalhp == 1 && opponent.ability == PBAbilities::STURDY && move.pbNumHits(attacker)==1 && !attacker.effects[PBEffects::ParentalBond] && !move.pbIsMultiHit && !moldBreakerCheck(attacker)
		if @mondata.skill>=MEDIUMSKILL
		  basedamage = pbBetterBaseDamage(move,attacker,opponent)
		end
		return 0 if move.zmove && opponent.effects[PBEffects::Disguise]
		return basedamage if (0x6A..0x73).include?(move.function) || [0xD4,0xE1].include?(move.function) #fixed damage function codes (sonicboom, etc)
		basedamage*=1.25 if attacker.effects[PBEffects::ParentalBond] && move.pbNumHits(attacker)==1
		fielddata = @battle.field.moveData(move.id)
		type=move.type

		# Determine if an AI mon is attacking a player mon
		ai_mon_attacking = false
		if attacker.index == 2 && !@battle.pbOwnedByPlayer?(attacker.index)
			ai_mon_attacking = true if opponent.index==1 || opponent.index==3
		elsif opponent.index==0 || opponent.index==2
			ai_mon_attacking = true
		end

		# More accurate move type (includes Normalize, most type-changing moves, etc.)
		if @mondata.skill>=MINIMUMSKILL
			type=move.pbType(attacker,type)
		end
		stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
		stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
		oppitemworks = opponent.itemWorks?
		attitemworks = attacker.itemWorks?

		# ATTACKING/BASE DAMAGE SECTION
		atk=attacker.attack
		atkstage=attacker.stages[PBStats::ATTACK]+6
		if attacker.species==PBSpecies::AEGISLASH
			originalform = attacker.form
			dummymon = pbAegislashStats(attacker)
			dummymon.pbUpdate
			atk=dummymon.attack
			atkstage=dummymon.stages[PBStats::ATTACK]+6
			dummymon.form = originalform
			dummymon.pbUpdate
		end
		if move.function==0x121 # Foul Play
			atk=opponent.attack
			atkstage=opponent.stages[PBStats::ATTACK]+6
		end
		if type>=0 && move.pbIsSpecial?(type)
			atk=attacker.spatk
			atkstage=attacker.stages[PBStats::SPATK]+6
			if attacker.species==PBSpecies::AEGISLASH
				originalform = attacker.form
				dummymon = pbAegislashStats(attacker)
				dummymon.pbUpdate
				atk=dummymon.spatk
				atkstage=dummymon.stages[PBStats::SPATK]+6
				dummymon.form = originalform
				dummymon.pbUpdate
			end
			if move.function==0x121 # Foul Play
				atk=opponent.spatk
				atkstage=opponent.stages[PBStats::SPATK]+6
			end
			if @battle.FE == PBFields::GLITCHF
				atk = attacker.getSpecialStat(opponent.ability == PBAbilities::UNAWARE)
				atkstage = 6 #getspecialstat handles unaware
			end
		end
		if opponent.ability != PBAbilities::UNAWARE || moldBreakerCheck(attacker)
			atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
		end
		if @mondata.skill>=BESTSKILL && @battle.FE != 0
			basedamage=(basedamage*move.moveFieldBoost).round
			case @battle.FE
			when PBFields::CHESSB
				# Chess Move boost
				if (PBFields::CHESSMOVES).include?(move.id)
					if (opponent.ability == PBAbilities::ADAPTABILITY) || (opponent.ability == PBAbilities::ANTICIPATION) || (opponent.ability == PBAbilities::SYNCHRONIZE) || (opponent.ability == PBAbilities::TELEPATHY)
						basedamage=(basedamage*0.5).round
					end
					if (opponent.ability == PBAbilities::OBLIVIOUS) || (opponent.ability == PBAbilities::KLUTZ) || (opponent.ability == PBAbilities::UNAWARE) || (opponent.ability == PBAbilities::SIMPLE) || opponent.effects[PBEffects::Confusion]>0
						basedamage=(basedamage*2).round
					end
				end
				# Queen piece boost
				if attacker.pokemon.piece==:QUEEN && attacker.ability != PBAbilities::QUEENLYMAJESTY
					basedamage=(basedamage*1.5).round
				end
			
				#Knight piece boost
				if attacker.pokemon.piece==:KNIGHT && opponent.pokemon.piece==:QUEEN
					basedamage=(basedamage*3.0).round
				end
			when PBFields::BIGTOPA
				if ((type == PBTypes::FIGHTING && move.pbIsPhysical?(type)) ||
						(PBFields::STRIKERMOVES).include?(move.id))
					if attacker.ability == PBAbilities::HUGEPOWER || attacker.ability == PBAbilities::GUTS ||
						attacker.ability == PBAbilities::PUREPOWER || attacker.ability == PBAbilities::SHEERFORCE
						basedamage=(basedamage*2.2).round
					else
						basedamage=(basedamage*1.2).round
					end
				end
				if move.isSoundBased?
					basedamage=(basedamage*1.5).round
				end
			when PBFields::SHORTCIRCUITF
				damageroll = @battle.field.getRoll(update_roll: false)
				basedamage=(basedamage*damageroll).round
			when PBFields::CAVE
				if move.isSoundBased?
					basedamage=(basedamage*1.5).round
				end
			when PBFields::MOUNTAIN
				if (PBFields::WINDMOVES).include?(move.id) && @battle.pbWeather==PBWeather::STRONGWINDS
					basedamage=(basedamage*1.5).round
				end
			when PBFields::SNOWYM
				if (PBFields::WINDMOVES).include?(move.id) && @battle.pbWeather==PBWeather::STRONGWINDS
					basedamage=(basedamage*1.5).round
				end
			when PBFields::MIRRORA
				if (PBFields::MIRRORMOVES).include?(move.id) && opponent.stages[PBStats::EVASION]>0
					basedamage=(basedamage*2).round
				end
			when PBFields::FLOWERGARDENF
				if (move.id == PBMoves::CUT) && @battle.field.counter > 0
					basedamage=(basedamage*1.5).round
				end
				if (move.id == PBMoves::PETALBLIZZARD || move.id == PBMoves::PETALDANCE || move.id == PBMoves::FLEURCANNON) && @battle.field.counter == 2
					basedamage=(basedamage*1.2).round
				end
				if (move.id == PBMoves::PETALBLIZZARD || move.id == PBMoves::PETALDANCE || move.id == PBMoves::FLEURCANNON) && @battle.field.counter > 2
					basedamage=(basedamage*1.5).round
				end
			end
		end

		if @mondata.skill>=MEDIUMSKILL
		  ############ ATTACKER ABILITY CHECKS ############
			#Technician
			if attacker.ability == PBAbilities::TECHNICIAN
				basedamage=(basedamage*1.5).round if (basedamage<=60) || (@battle.FE == PBFields::FACTORYF && basedamage<=80)
			# Iron Fist
			elsif attacker.ability == PBAbilities::IRONFIST
				basedamage=(basedamage*1.2).round if move.isPunchingMove?
			# Strong Jaw
			elsif attacker.ability == PBAbilities::STRONGJAW
				basedamage=(basedamage*1.5).round if (PBStuff::BITEMOVE).include?(move.id)
			#Tough Claws
			elsif attacker.ability == PBAbilities::TOUGHCLAWS
				basedamage=(basedamage*1.3).round if move.isContactMove?
			# Reckless
			elsif attacker.ability == PBAbilities::RECKLESS
				if move.function==0xFA ||  # Take Down, etc.
					move.function==0xFB ||  # Double-Edge, etc.
					move.function==0xFC ||  # Head Smash
					move.function==0xFD ||  # Volt Tackle
					move.function==0xFE ||  # Flare Blitz
					move.function==0x10B || # Jump Kick, Hi Jump Kick
					move.function==0x130    # Shadow End
					basedamage=(basedamage*1.2).round
				end
			# Flare Boost
			elsif attacker.ability == PBAbilities::FLAREBOOST
				if (attacker.status==PBStatuses::BURN || @battle.FE == PBFields::BURNINGF) && move.pbIsSpecial?(type)
					basedamage=(basedamage*1.5).round
				end
			# Toxic Boost
			elsif attacker.ability == PBAbilities::TOXICBOOST
				if (attacker.status==PBStatuses::POISON || @battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF || @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS) && move.pbIsPhysical?(type)
					basedamage=(basedamage*1.5).round
				end
			# Rivalry
			elsif attacker.ability == PBAbilities::RIVALRY
				if attacker.gender!=2 && opponent.gender!=2
					if attacker.gender==opponent.gender
						basedamage=(basedamage*1.25).round
					else
						basedamage=(basedamage*0.75).round
					end
				end
			# Mega Launcher
			elsif (attacker.ability == PBAbilities::MEGALAUNCHER)
				if move.id == PBMoves::AURASPHERE || move.id == PBMoves::DRAGONPULSE || move.id == PBMoves::DARKPULSE || move.id == PBMoves::WATERPULSE || move.id == PBMoves::ORIGINPULSE
					basedamage=(basedamage*1.5).round
				end
			# Sand Force
			elsif attacker.ability == PBAbilities::SANDFORCE
				if @battle.pbWeather==PBWeather::SANDSTORM && (type == PBTypes::ROCK || type == PBTypes::GROUND || type == PBTypes::STEEL)
					basedamage=(basedamage*1.3).round
				elsif @mondata.skill>=BESTSKILL && (@battle.FE == PBFields::DESERTF || @battle.FE == PBFields::ASHENB) &&
					(type == PBTypes::ROCK || type == PBTypes::GROUND || type == PBTypes::STEEL)
					basedamage=(basedamage*1.3).round
				end
			# Analytic
			elsif attacker.ability == PBAbilities::ANALYTIC
				if pbAIfaster?(move,nil,attacker,opponent)
					basedamage = (basedamage*1.3).round
				end
			# Sheer Force
			elsif attacker.ability == PBAbilities::SHEERFORCE
				basedamage=(basedamage*1.3).round if move.addlEffect>0
			# Normalize
			elsif attacker.ability == PBAbilities::NORMALIZE
				basedamage=(basedamage*1.2).round
			# Hustle
			elsif attacker.ability == PBAbilities::HUSTLE
				atk=(atk*1.5).round if move.pbIsPhysical?(type)
			# Guts
			elsif attacker.ability == PBAbilities::GUTS
				atk=(atk*1.5).round if attacker.status!=0 && move.pbIsPhysical?(type)
			#Plus/Minus
			elsif attacker.ability == PBAbilities::PLUS ||  attacker.ability == PBAbilities::MINUS
				if move.pbIsSpecial?(type)
					partner=attacker.pbPartner
					if partner.ability == PBAbilities::PLUS || partner.ability == PBAbilities::MINUS
						atk=(atk*1.5).round
					elsif @battle.FE == PBFields::SHORTCIRCUITF && @mondata.skill>=BESTSKILL
						atk=(atk*1.5).round
					end
				end
			#Defeatist
			elsif attacker.ability == PBAbilities::DEFEATIST
				atk=(atk*0.5).round if attacker.hp<=(attacker.totalhp/2.0).floor
			#Pure/Huge Power
			elsif attacker.ability == PBAbilities::PUREPOWER || attacker.ability == PBAbilities::HUGEPOWER
				if @mondata.skill>=BESTSKILL
					if attacker.ability == PBAbilities::PUREPOWER && @battle.FE == PBFields::PSYCHICT
						atk=(atk*2.0).round if move.pbIsSpecial?(type)
					else
						atk=(atk*2.0).round if move.pbIsPhysical?(type)
					end
				elsif move.pbIsPhysical?(type)
					atk=(atk*2.0).round
				end
			#Solar Power
			elsif attacker.ability == PBAbilities::SOLARPOWER
				if @battle.pbWeather==PBWeather::SUNNYDAY && move.pbIsSpecial?(type)
					atk=(atk*1.5).round
				end
			#Flash Fire
			elsif attacker.ability == PBAbilities::FLASHFIRE
				if attacker.effects[PBEffects::FlashFire] && type == PBTypes::FIRE
					atk=(atk*1.5).round
				end
			#Slow Start
			elsif attacker.ability == PBAbilities::SLOWSTART
				if attacker.turncount<5 && move.pbIsPhysical?(type)
					atk=(atk*0.5).round
				end
			# Type Changing Abilities
			elsif move.type == PBTypes::NORMAL && attacker.ability != PBAbilities::NORMALIZE
				# Aerilate
				if attacker.ability == PBAbilities::AERILATE
					if @battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM # Snowy Mountain && Mountain
						basedamage=(basedamage*1.5).round
					  else
						basedamage=(basedamage*1.2).round
					  end
				# Galvanize
				elsif attacker.ability == PBAbilities::GALVANIZE
					if @mondata.skill>=BESTSKILL
						if @battle.FE == PBFields::ELECTRICT || @battle.FE == PBFields::FACTORYF # Electric or Factory Fields
							basedamage=(basedamage*1.5).round
						elsif @battle.FE == PBFields::SHORTCIRCUITF # Short-Circuit Field
							basedamage=(basedamage*2).round
						else
							basedamage=(basedamage*1.2).round
						end
					else
						basedamage=(basedamage*1.2).round
					end
				# Pixilate
				elsif attacker.ability == PBAbilities::PIXILATE
					if @mondata.skill>=BESTSKILL
						basedamage= @battle.FE == PBFields::MISTYT ? (basedamage*1.5).round : (basedamage*1.2).round # Misty Field
					else
						basedamage=(basedamage*1.2).round
					end
				# Refrigerate
				elsif attacker.ability == PBAbilities::REFRIGERATE
					if @mondata.skill>=BESTSKILL
						if @battle.FE == PBFields::ICYF || @battle.FE == PBFields::SNOWYM # Icy Fields
							basedamage=(basedamage*1.5).round
						else
							basedamage=(basedamage*1.2).round
						end
					else
						basedamage=(basedamage*1.2).round
					end
				end
		  	end

		  ############ OPPONENT ABILITY CHECKS ############
			if !moldBreakerCheck(attacker)
				# Heatproof
				if opponent.ability == PBAbilities::HEATPROOF
					if type == PBTypes::FIRE
						basedamage=(basedamage*0.5).round
					end
				# Dry Skin
				elsif opponent.ability == PBAbilities::DRYSKIN
					if type == PBTypes::FIRE
						basedamage=(basedamage*1.25).round
					end
				elsif opponent.ability == PBAbilities::THICKFAT
					if type == PBTypes::ICE || type == PBTypes::FIRE
						atk=(atk*0.5).round
					end
				end
			end

			############ ATTACKER ITEM CHECKS ############
			if attitemworks #don't bother with this if it doesn't work
				#Type-boosting items
				case type
					when PBTypes::NORMAL
						case attacker.item
							when PBItems::SILKSCARF then basedamage=(basedamage*1.2).round
							when PBItems::NORMALGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::FIGHTING
						case attacker.item
							when PBItems::BLACKBELT,PBItems::FISTPLATE then basedamage=(basedamage*1.2).round
							when PBItems::FIGHTINGGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::FLYING
						case attacker.item
							when PBItems::SHARPBEAK,PBItems::SKYPLATE then basedamage=(basedamage*1.2).round
							when PBItems::FLYINGGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::POISON
						case attacker.item
							when PBItems::POISONBARB,PBItems::TOXICPLATE then basedamage=(basedamage*1.2).round
							when PBItems::FLYINGGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::GROUND
						case attacker.item
							when PBItems::SOFTSAND,PBItems::EARTHPLATE then basedamage=(basedamage*1.2).round
							when PBItems::GROUNDGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::ROCK
						case attacker.item
							when PBItems::HARDSTONE,PBItems::STONEPLATE,PBItems::ROCKINCENSE then basedamage=(basedamage*1.2).round
							when PBItems::ROCKGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::BUG
						case attacker.item
							when PBItems::SILVERPOWDER,PBItems::INSECTPLATE then basedamage=(basedamage*1.2).round
							when PBItems::BUGGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::GHOST
						case attacker.item
							when PBItems::SPELLTAG,PBItems::SPOOKYPLATE then basedamage=(basedamage*1.2).round
							when PBItems::GHOSTGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::STEEL
						case attacker.item
							when PBItems::METALCOAT,PBItems::IRONPLATE then basedamage=(basedamage*1.2).round
							when PBItems::STEELGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::FIRE
						case attacker.item
							when PBItems::CHARCOAL,PBItems::FLAMEPLATE then basedamage=(basedamage*1.2).round
							when PBItems::FIREGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::WATER
						case attacker.item
							when PBItems::MYSTICWATER,PBItems::SPLASHPLATE,PBItems::SEAINCENSE,PBItems::WAVEINCENSE then basedamage=(basedamage*1.2).round
							when PBItems::WATERGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::GRASS
						case attacker.item
							when PBItems::MIRACLESEED,PBItems::MEADOWPLATE,PBItems::ROSEINCENSE then basedamage=(basedamage*1.2).round
							when PBItems::FLYINGGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::ELECTRIC
						case attacker.item
							when PBItems::MAGNET,PBItems::ZAPPLATE then basedamage=(basedamage*1.2).round
							when PBItems::ELECTRICGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::PSYCHIC
						case attacker.item
							when PBItems::TWISTEDSPOON,PBItems::MINDPLATE,PBItems::ODDINCENSE then basedamage=(basedamage*1.2).round
							when PBItems::PSYCHICGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::ICE
						case attacker.item
							when PBItems::NEVERMELTICE,PBItems::ICICLEPLATE then basedamage=(basedamage*1.2).round
							when PBItems::ICEGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::DRAGON
						case attacker.item
							when PBItems::DRAGONFANG,PBItems::DRACOPLATE then basedamage=(basedamage*1.2).round
							when PBItems::DRAGONGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::DARK
						case attacker.item
							when PBItems::BLACKGLASSES,PBItems::DREADPLATE then basedamage=(basedamage*1.2).round
							when PBItems::DARKGEM then basedamage=(basedamage*1.3).round
						end
					when PBTypes::FAIRY
						case attacker.item
							when PBItems::PIXIEPLATE then basedamage=(basedamage*1.2).round
							when PBItems::FAIRYGEM then basedamage=(basedamage*1.3).round
						end
				end
				# Muscle Band
				if attacker.item == PBItems::MUSCLEBAND && move.pbIsPhysical?(type)
					basedamage=(basedamage*1.1).round
				# Wise Glasses
				elsif attacker.item == PBItems::WISEGLASSES && move.pbIsSpecial?(type)
					basedamage=(basedamage*1.1).round
				# Legendary Orbs
				elsif attacker.item == PBItems::LUSTROUSORB
					if (attacker.pokemon.species == PBSpecies::PALKIA) && (type == PBTypes::DRAGON || type == PBTypes::WATER)
						basedamage=(basedamage*1.2).round
					end
				elsif attacker.item == PBItems::ADAMANTORB
					if (attacker.pokemon.species == PBSpecies::DIALGA) && (type == PBTypes::DRAGON || type == PBTypes::STEEL)
						basedamage=(basedamage*1.2).round
					end
				elsif attacker.item == PBItems::GRISEOUSORB
					if (attacker.pokemon.species == PBSpecies::GIRATINA) && (type == PBTypes::DRAGON || type == PBTypes::GHOST)
						basedamage=(basedamage*1.2).round
					end
				elsif attacker.item == PBItems::SOULDEW
					if (attacker.pokemon.species == PBSpecies::LATIAS || attacker.pokemon.species == PBSpecies::LATIOS) &&
						(type == PBTypes::DRAGON || type == PBTypes::PSYCHIC)
						basedamage=(basedamage*1.2).round
					end
				end
			end
			#pbBaseDamageMultiplier

			############ MISC CHECKS ############
			# Charge
			if attacker.effects[PBEffects::Charge]>0 && type == PBTypes::ELECTRIC
				basedamage=(basedamage*2.0).round
			end
			# Helping Hand
			if attacker.effects[PBEffects::HelpingHand]
				basedamage=(basedamage*1.5).round
			end
			# Water/Mud Sport
			if type == PBTypes::FIRE
				if @battle.state.effects[PBEffects::WaterSport]>0
					basedamage=(basedamage*0.33).round
				end
			elsif type == PBTypes::ELECTRIC
				if @battle.state.effects[PBEffects::MudSport]>0
					basedamage=(basedamage*0.33).round
				end
			# Dark Aura/Aurabreak
			elsif type == PBTypes::DARK
				if @battle.battlers.any? {|battler| battler.ability == PBAbilities::DARKAURA}
					basedamage*= @battle.battlers.any? {|battler| battler.ability == PBAbilities::AURABREAK} ? (2.0/3) : (4.0/3)
				end
			# Fairy Aura/Aurabreak
			elsif type == PBTypes::FAIRY
				if @battle.battlers.any? {|battler| battler.ability == PBAbilities::FAIRYAURA}
					basedamage*= @battle.battlers.any? {|battler| battler.ability == PBAbilities::AURABREAK} ? (2.0/3) : (4.0/3)
				end
			end
			#Battery
			if attacker.pbPartner.ability == PBAbilities::BATTERY && move.pbIsSpecial?(type)
				atk=(atk*1.3).round
			end
			#Flower Gift
			if @battle.pbWeather==PBWeather::SUNNYDAY && move.pbIsPhysical?(type)
				if attacker.ability == PBAbilities::FLOWERGIFT && attacker.species == PBSpecies::CHERRIM
					atk=(atk*1.5).round
				end
				if attacker.pbPartner.ability == PBAbilities::FLOWERGIFT && attacker.pbPartner.species == PBSpecies::CHERRIM
					atk=(atk*1.5).round
				end
			end
		end

		# Pinch Abilities
		if @mondata.skill>=BESTSKILL
			if @battle.FE == PBFields::BURNINGF && attacker.ability == PBAbilities::BLAZE && type == PBTypes::FIRE
				atk=(atk*1.5).round
			elsif @battle.FE == PBFields::FORESTF && attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS
				atk=(atk*1.5).round
			elsif @battle.FE == PBFields::FORESTF && attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG
				atk=(atk*1.5).round
			elsif (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER) && attacker.ability == PBAbilities::TORRENT && type == PBTypes::WATER
				atk=(atk*1.5).round
			elsif @battle.FE == PBFields::FLOWERGARDENF && attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG
				atk=(atk*1.5).round if @battle.field.counter == 0 || @battle.field.counter == 1
				atk=(atk*1.8).round if @battle.field.counter == 2 || @battle.field.counter == 3
				atk=(atk*2).round if @battle.field.counter == 4
			elsif @battle.FE == PBFields::FLOWERGARDENF && attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS
				atk=(atk*1.5).round if @battle.field.counter == 0 || @battle.field.counter == 1
				atk=(atk*1.8).round if @battle.field.counter == 2 || @battle.field.counter == 3
				atk=(atk*2).round if @battle.field.counter == 4
			elsif attacker.hp<=(attacker.totalhp/3.0).floor
				if (attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS) || (attacker.ability == PBAbilities::BLAZE && type == PBTypes::FIRE) ||
					(attacker.ability == PBAbilities::TORRENT && type == PBTypes::WATER) || (attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG)
					atk=(atk*1.5).round
				end
			end
		elsif @mondata.skill>=MEDIUMSKILL && attacker.hp<=(attacker.totalhp/3.0).floor
			if (attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS) || (attacker.ability == PBAbilities::BLAZE && type == PBTypes::FIRE) ||
				(attacker.ability == PBAbilities::TORRENT && type == PBTypes::WATER) || (attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG)
				atk=(atk*1.5).round
			end
		end

		# Attack-boosting items
		if @mondata.skill>=HIGHSKILL
			if (attitemworks && attacker.item == PBItems::THICKCLUB)
				if ((attacker.pokemon.species == PBSpecies::CUBONE) || (attacker.pokemon.species == PBSpecies::MAROWAK)) && move.pbIsPhysical?(type)
					atk=(atk*2.0).round
				end
			elsif (attitemworks && attacker.item == PBItems::DEEPSEATOOTH)
				if (attacker.pokemon.species == PBSpecies::CLAMPERL) && move.pbIsSpecial?(type)
					atk=(atk*2.0).round
				end
			elsif (attitemworks && attacker.item == PBItems::LIGHTBALL)
				if (attacker.pokemon.species == PBSpecies::PIKACHU)
					atk=(atk*2.0).round
				end
			elsif (attitemworks && attacker.item == PBItems::CHOICEBAND) && move.pbIsPhysical?(type)
				atk=(atk*1.5).round
			elsif (attitemworks && attacker.item == PBItems::CHOICESPECS) && move.pbIsSpecial?(type)
				atk=(atk*1.5).round
			end
		end

		#Specific ability field boosts
		if @mondata.skill>=BESTSKILL
			if @battle.FE == PBFields::STARLIGHTA || @battle.FE == PBFields::NEWW
				atk=(atk*1.5).round if attacker.ability == PBAbilities::VICTORYSTAR
				partner=attacker.pbPartner
				atk=(atk*1.5).round if partner && partner.ability == PBAbilities::VICTORYSTAR
			end
			atk=(atk*1.5).round if attacker.ability == PBAbilities::QUEENLYMAJESTY && (@battle.FE == PBFields::CHESSB || @battle.FE == PBFields::FAIRYTALEF)
			atk=(atk*1.5).round if attacker.ability == PBAbilities::LONGREACH && (@battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM)
			atk=(atk*1.5).round if attacker.ability == PBAbilities::CORROSION && (@battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF)
			atk=(atk*2.0).round if @battle.FE == PBFields::UNDERWATER && move.pbIsPhysical?(type) && type != PBTypes::WATER && attacker.ability!=PBAbilities::STEELWORKER
		end

		# Get base defense stat
		defense=opponent.defense
		defstage=opponent.stages[PBStats::DEFENSE]+6
		applysandstorm=false
		if type>=0 && move.pbIsSpecial?(type)
			if move.function!=0x122 # Psyshock
				defense=opponent.spdef
				defstage=opponent.stages[PBStats::SPDEF]+6
				if @battle.FE == PBFields::GLITCHF
					defense = opponent.getSpecialStat(attacker.ability == PBAbilities::UNAWARE)
					defstage = 6 #getspecialstat handles unaware
				end
				applysandstorm=true
			end
		end
		defstage=6 if move.function==0xA9 # Chip Away (ignore stat stages)
		defstage=6 if attacker.ability == PBAbilities::UNAWARE
		defense=(defense*1.0*stagemul[defstage]/stagediv[defstage]).floor
		defense = 1 if (defense == 0 || !defense)

		#Glitch Item and Ability Checks
		if @mondata.skill>=HIGHSKILL && @battle.FE == PBFields::GLITCHF
			if move.function==0xE0 #Explosion
				defense=(defense*0.5).round
			end
		end

		if @mondata.skill>=MEDIUMSKILL
			# Sandstorm weather
			if @battle.pbWeather==PBWeather::SANDSTORM
				defense=(defense*1.5).round if opponent.pbHasType?(:ROCK) && applysandstorm
			end
			# Defensive Abilities
			if opponent.ability == PBAbilities::MARVELSCALE
				if move.pbIsPhysical?(type)
					if opponent.status>0
						defense=(defense*1.5).round
					elsif [3,9,31,32,34].include?(@battle.FE) && @mondata.skill>=BESTSKILL
						defense=(defense*1.5).round
					end
				end
			elsif opponent.ability == PBAbilities::GRASSPELT
				defense=(defense*1.5).round if move.pbIsPhysical?(type) && (@battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FORESTF) # Grassy Field
			elsif opponent.ability == PBAbilities::FLUFFY && !moldBreakerCheck(attacker)
				defense=(defense*2).round if move.isContactMove? && attacker.ability != PBAbilities::LONGREACH
				defense=(defense*0.5).round if type == PBTypes::FIRE
			elsif opponent.ability == PBAbilities::FURCOAT
				defense=(defense*2).round if move.pbIsPhysical?(type) && !moldBreakerCheck(attacker)
			end
			if (@battle.pbWeather==PBWeather::SUNNYDAY || @battle.FE == PBFields::FLOWERGARDENF) && move.pbIsSpecial?(type) && @battle.FE != 24
				defense=(defense*1.5).round if opponent.ability == PBAbilities::FLOWERGIFT && (opponent.species == PBSpecies::CHERRIM)
				defense=(defense*1.5).round if opponent.pbPartner.ability == PBAbilities::FLOWERGIFT && opponent.pbPartner.species == PBSpecies::CHERRIM
			end
		end

		# Field Effect defense boost
		if @mondata.skill>=BESTSKILL
			defense= (defense*move.fieldDefenseBoost(type,opponent)).round
		end

		# Defense-boosting items
		if @mondata.skill>=HIGHSKILL && @battle.FE != 24 && oppitemworks
			case opponent.item
			when PBItems::EVIOLITE
				evos=pbGetEvolvedFormData(opponent.pokemon.species)
				defense=(defense*1.5).round if evos && evos.length>0
			when PBItems::ASSAULTVEST
				defense=(defense*1.5).round if move.pbIsSpecial?(type)
			when PBItems::DEEPSEASCALE
				defense=(defense*2.0).round if (opponent.pokemon.species == PBSpecies::CLAMPERL) && move.pbIsSpecial?(type)
			when PBItems::METALPOWDER
				defense=(defense*2.0).round if (opponent.pokemon.species == PBSpecies::DITTO) && !opponent.effects[PBEffects::Transform] && move.pbIsPhysical?(type)
			when PBItems::EEVIUMZ2
				defense=(defense*1.5).round if opponent.pokemon.species == PBSpecies::EEVEE
			when PBItems::PIKANIUMZ2
				defense=(defense*1.5).round if opponent.pokemon.species == PBSpecies::PIKACHU
			when PBItems::LIGHTBALL
				defense=(defense*1.5).round if opponent.pokemon.species == PBSpecies::PIKACHU
			end
		end		

		# Main damage calculation
		damage=(((2.0*attacker.level/5+2).floor*basedamage*atk/defense).floor/50).floor+2 if basedamage >= 0
		
		# Multi-targeting attacks
		if @mondata.skill>=MEDIUMSKILL
			if move.pbTargetsAll?(attacker)
				damage=(damage*0.75).round
			end
		end
		# Field Boosts
		if @mondata.skill>=BESTSKILL
			#Type-based field boosts
			damage=(damage*move.typeFieldBoost(type,attacker,opponent)).floor
			case @battle.FE
			when 27 # Mountain
				if type == PBTypes::FLYING && !move.pbIsPhysical?(type) && @battle.pbWeather==PBWeather::STRONGWINDS
					damage=(damage*1.5).floor
				end
			when 28 # Snowy Mountain
				if type == PBTypes::FLYING && !move.pbIsPhysical?(type) && @battle.pbWeather==PBWeather::STRONGWINDS
					damage=(damage*1.5).floor
				end
			when 33 # Flower Field
				if type == PBTypes::GRASS
					case @battle.field.counter
						when 1 then damage=(damage*1.2).floor
						when 2 then damage=(damage*1.5).floor
						when 3 then damage=(damage*2).floor
						when 4 then damage=(damage*3).floor
					end
				end
				if @battle.field.counter > 1
					damage=(damage*1.5).floor if type == PBTypes::FIRE
				end
				if @battle.field.counter > 3
					damage=(damage*2).floor if type == PBTypes::BUG
				elsif @battle.field.counter > 1
					damage=(damage*1.5).floor if type == PBTypes::BUG
				end
			end
			#Boosts caused by transformations
			fieldmove = @battle.field.moveData(move.id)
			if fieldmove && fieldmove[:fieldchange]
				handled = fieldmove[:condition] ? eval(fieldmove[:condition]): true
				if handled  #don't continue if conditions to change are not met
					damage=(damage*1.3).floor if damage >= 0
				end
			end
		end
		# Weather
		if @mondata.skill>=MEDIUMSKILL
			case @battle.pbWeather
				when PBWeather::SUNNYDAY
					if @battle.state.effects[PBEffects::HarshSunlight] && type == PBTypes::WATER
						damage=0
					end
					if type == PBTypes::FIRE
						damage=(damage*1.5).round
					elsif type == PBTypes::WATER
						damage=(damage*0.5).round
					end
				when PBWeather::RAINDANCE
					if @battle.state.effects[PBEffects::HeavyRain] && type == PBTypes::FIRE
						damage=0
					end
					if type == PBTypes::FIRE
						damage=(damage*0.5).round
					elsif type == PBTypes::WATER
						damage=(damage*1.5).round
					end
			end
		end
		if ai_mon_attacking 
			random=100
			random=93 if @mondata.skill >=HIGHSKILL 
			random=85 if @mondata.skill >=BESTSKILL		#This is something that could be tweaked based on skill
			random=93 if $game_switches[:No_Damage_Rolls] #damage rolls
			damage=(damage*random/100.0).floor
		end
		# STAB
		if @mondata.skill>=MEDIUMSKILL
			# Water Bubble
			if attacker.ability == PBAbilities::WATERBUBBLE && type == PBTypes::WATER
				damage=(damage*=2).round
			end
			if attacker.pbHasType?(type) || attacker.ability == PBAbilities::PROTEAN
				if attacker.ability == PBAbilities::ADAPTABILITY
					damage=(damage*2).round
				else
					damage=(damage*1.5).round
				end
			elsif attacker.ability == PBAbilities::STEELWORKER && type == PBTypes::STEEL
				if @battle.FE == PBFields::FACTORYF # Factory Field
					damage=(damage*2).round
				else
					damage=(damage*1.5).round
				end
			end
		end
		# Type effectiveness
		# typemod calc has been moved to the beginning
		if @mondata.skill>=MINIMUMSKILL
		  	damage=(damage*typemod/4.0).round
		end
		# Water Bubble
		if @mondata.skill>=MEDIUMSKILL
			if opponent.ability == PBAbilities::WATERBUBBLE && type == PBTypes::FIRE
				damage=(damage*=0.5).round
			end
			# Burn
			if attacker.status==PBStatuses::BURN && move.pbIsPhysical?(type) &&
				attacker.ability != PBAbilities::GUTS && move.id != PBMoves::FACADE
				damage=(damage*0.5).round
			end
		end
		# Screens
		if @mondata.skill>=HIGHSKILL
			if move.pbIsPhysical?(type)
				if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 || opponent.pbOwnSide.effects[PBEffects::AuroraVeil]>0
					if !opponent.pbPartner.isFainted?
						damage=(damage*0.66).round
					else
						damage=(damage*0.5).round
					end
				end
			elsif move.pbIsSpecial?(type)
				if opponent.pbOwnSide.effects[PBEffects::LightScreen]>0 || opponent.pbOwnSide.effects[PBEffects::AuroraVeil]>0
					if !opponent.pbPartner.isFainted?
						damage=(damage*0.66).round
					else
						damage=(damage*0.5).round
					end
				end
			end
		end

		if @mondata.skill>=MEDIUMSKILL
			if opponent.ability == PBAbilities::MULTISCALE && !moldBreakerCheck(attacker) || opponent.ability == PBAbilities::SHADOWSHIELD
				damage=(damage*0.5).round if opponent.hp==opponent.totalhp
			end
			if opponent.ability == PBAbilities::SOLIDROCK || opponent.ability == PBAbilities::FILTER || opponent.ability == PBAbilities::PRISMARMOR
				damage=(damage*0.75).round if typemod>4
			end
			if opponent.ability == PBAbilities::SHADOWSHIELD && [PBFields::STARLIGHTA, PBFields::NEWW, PBFields::DARKCRYSTALC].include?(@battle.FE)
				damage=(damage*0.75).round if typemod>4
			end
			damage=(damage*0.75).round if opponent.pbPartner.ability == PBAbilities::FRIENDGUARD
			damage=(damage*2.0).round if attacker.ability == PBAbilities::STAKEOUT && @battle.switchedOut[opponent.index]
		end

		if @mondata.skill>=MEDIUMSKILL
			# Tinted Lens
			damage=(damage*2.0).round if attacker.ability == PBAbilities::TINTEDLENS && typemod<4
			# Neuroforce
			damage=(damage*1.25).round if attacker.ability == PBAbilities::NEUROFORCE && typemod>4
		end

		# Flower Veil + Flower Garden Shenanigans
		if @mondata.skill>=BESTSKILL
			if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter >1
				if (opponent.pbPartner.ability == PBAbilities::FLOWERVEIL &&
				opponent.pbHasType?(:GRASS)) || opponent.ability == PBAbilities::FLOWERVEIL
					damage=(damage*0.75).round
				end
			#	case @battle.field.counter
			#		when 2 then damage=(damage*0.75).round if opponent.pbHasType?(:GRASS)
			#		when 3 then damage=(damage*0.67).round if opponent.pbHasType?(:GRASS)
			#		when 4 then damage=(damage*0.5).round if opponent.pbHasType?(:GRASS)
			#	end
			end
		end
		# Final damage-altering items
		if @mondata.skill>=HIGHSKILL
			if (attitemworks && attacker.item == PBItems::METRONOME)
				if attacker.effects[PBEffects::Metronome]>4
					damage=(damage*2.0).round
				else
					met=1.0+attacker.effects[PBEffects::Metronome]*0.2
					damage=(damage*met).round
				end
			elsif (attitemworks && attacker.item == PBItems::EXPERTBELT) && typemod>4
				damage=(damage*1.2).round
			elsif (attitemworks && attacker.item == PBItems::LIFEORB)
				damage=(damage*1.3).round
			end
			if typemod>4 && oppitemworks && !ai_mon_attacking
				berrymod = opponent.ability == PBAbilities::RIPEN ? 0.25 : 0.5
				case opponent.item
					when PBItems::CHOPLEBERRY	then damage=(damage*berrymod).round if type == PBTypes::FIGHTING
					when PBItems::COBABERRY		then damage=(damage*berrymod).round if type == PBTypes::FLYING
					when PBItems::KEBIABERRY	then damage=(damage*berrymod).round if type == PBTypes::POISON
					when PBItems::SHUCABERRY	then damage=(damage*berrymod).round if type == PBTypes::GROUND
					when PBItems::CHARTIBERRY   then damage=(damage*berrymod).round if type == PBTypes::ROCK
					when PBItems::TANGABERRY	then damage=(damage*berrymod).round if type == PBTypes::BUG
					when PBItems::KASIBBERRY	then damage=(damage*berrymod).round if type == PBTypes::GHOST
					when PBItems::BABIRIBERRY 	then damage=(damage*berrymod).round if type == PBTypes::STEEL
					when PBItems::OCCABERRY 	then damage=(damage*berrymod).round if type == PBTypes::FIRE
					when PBItems::PASSHOBERRY 	then damage=(damage*berrymod).round if type == PBTypes::WATER
					when PBItems::RINDOBERRY 	then damage=(damage*berrymod).round if type == PBTypes::GRASS
					when PBItems::WACANBERRY 	then damage=(damage*berrymod).round if type == PBTypes::ELECTRIC
					when PBItems::PAYAPABERRY 	then damage=(damage*berrymod).round if type == PBTypes::PSYCHIC
					when PBItems::YACHEBERRY 	then damage=(damage*berrymod).round if type == PBTypes::ICE
					when PBItems::HABANBERRY 	then damage=(damage*berrymod).round if type == PBTypes::DRAGON
					when PBItems::COLBURBERRY 	then damage=(damage*berrymod).round if type == PBTypes::DARK
					when PBItems::ROSELIBERRY 	then damage=(damage*berrymod).round if type == PBTypes::FAIRY
				end
			end
		end
		# pbModifyDamage - TODO
		if opponent.effects[PBEffects::Minimize] && (move.id == PBMoves::BODYSLAM || move.function==0x10 ||
			move.function==0x9B || move.function==0x137 || move.id == 10021)
			damage=(damage*2.0).round
		end
		# "AI-specific calculations below"
		# Increased critical hit rates
		if @mondata.skill>=MEDIUMSKILL
			critrate = move.pbCritRate?(attacker,opponent)
			if critrate==2
				damage=(damage*1.25).round
			elsif critrate>2
				damage=(damage*1.5).round
			end
		end
		#Substitute damage
		if opponent.effects[PBEffects::Substitute] > 0 && attacker.ability != PBAbilities::INFILTRATOR && !move.isSoundBased? && 
			move.id!=PBMoves::SPECTRALTHIEF && move.id!=PBMoves::HYPERSPACEHOLE && move.id!=PBMoves::HYPERSPACEFURY && damage > opponent.hp/2
			damage=(opponent.hp/2.0).round
		end
		# Make sure damage is at least 1
		damage=1 if damage<1
		return damage
	end

	def pbBetterBaseDamage(move=@move,attacker=@attacker,opponent=@opponent)
		# Covers all function codes which have their own def pbBaseDamage
		aimem = getAIMemory(opponent)
		basedamage = move.basedamage
		case move.function
			when 0x12 # Fake Out
				return move.basedamage if attacker.turncount<=1
				return 0
			when 0x6A # SonicBoom
				return 140 if @battle.FE == PBFields::RAINBOWF
				return 20
			when 0x6B # Dragon Rage
				return 40
			when 0x6C # Super Fang
				if (move.id == PBMoves::NATURESMADNESS) && (@battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FORESTF || @battle.FE == PBFields::NEWW)
					return (opponent.hp*0.75).floor
				elsif (move.id == PBMoves::NATURESMADNESS) && @battle.FE == PBFields::HOLYF
					return (opponent.hp*0.66).floor
				end
				return (opponent.hp/2.0).floor
			when 0x6D # Night Shade
				return attacker.level
			when 0x6E # Endeavor
				return 0 if pbAIfaster?() && attacker.hp >= opponent.hp
				return opponent.hp-attacker.hp if pbAIfaster?()
				if !aimem.any? {|moveloop| moveloop!=nil && [PBMoves::ENDEAVOR,PBMoves::METALBURST,PBMoves::COUNTER,PBMoves::MIRRORCOAT,PBMoves::BIDE].include?(moveloop.id)}
					return opponent.hp - [attacker.hp-checkAIdamage(attacker,opponent,aimem), 1].max
				end
				return 20
			when 0x6F # Psywave
				return attacker.level
			when 0x70 # OHKO
				return 0 if move.id == PBMoves::FISSURE && @battle.FE == PBFields::NEWW
				return opponent.totalhp
			when 0x71 # Counter
				maxdam=60
				for j in aimem
					next if j.pbIsSpecial?() || j.basedamage<=1 || [PBMoves::ENDEAVOR,PBMoves::METALBURST,PBMoves::COUNTER,PBMoves::MIRRORCOAT,PBMoves::BIDE].include?(j.id)
					tempdam = pbRoughDamage(j,opponent,attacker)*2
					maxdam=tempdam if tempdam>maxdam
				end
				return maxdam
			when 0x72 # Mirror Coat
				maxdam=60
				for j in aimem
					next if j.pbIsPhysical?() || j.basedamage<=1 || [PBMoves::ENDEAVOR,PBMoves::METALBURST,PBMoves::COUNTER,PBMoves::MIRRORCOAT,PBMoves::BIDE].include?(j.id)
					tempdam = pbRoughDamage(j,opponent,attacker)*2
					maxdam=tempdam if tempdam>maxdam
				end
				return maxdam
			when 0x73 # Metal Burst
				return (1.5 * checkAIdamage(attacker,opponent,aimem)).floor unless aimem.any? {|moveloop| moveloop!=nil && [PBMoves::ENDEAVOR,PBMoves::METALBURST,PBMoves::COUNTER,PBMoves::MIRRORCOAT,PBMoves::BIDE].include?(moveloop.id)}
			when 0x75, 0x12D # Surf, Shadow Storm
				return move.basedamage*2 if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION] == 0xCB # Dive
			when 0x76 # Earthquake
				return move.basedamage*2 if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION] == 0xCA # Dig
			when 0x77, 0x78 # Gust, Twister
				return move.basedamage*2 if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION] == 0xC9 # Fly
								$cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION] == 0xCC # Bounce
								$cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION] == 0xCE # Sky Drop
			when 0x79 # Fusion Bolt
				return move.basedamage*2 if @battle.previousMove == PBMoves::FUSIONFLARE
			when 0x7A # Fusion Flare
				return move.basedamage*2 if @battle.previousMove == PBMoves::FUSIONBOLT
			when 0x7B # Venoshock
				if opponent.status==PBStatuses::POISON
					return move.basedamage*2
				elsif @mondata.skill>=BESTSKILL
					if @battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF || @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS # Corrosive/Corromist/Wasteland/Murkwater
						return move.basedamage*2
					end
				end
			when 0x7C # SmellingSalt
				return move.basedamage*2 if opponent.status==PBStatuses::PARALYSIS  && opponent.effects[PBEffects::Substitute]<=0
			when 0x7D # Wake-Up Slap
				return move.basedamage*2 if opponent.status==PBStatuses::SLEEP && opponent.effects[PBEffects::Substitute]<=0
			when 0x7E # Facade
				return move.basedamage*2 if attacker.status==PBStatuses::POISON || attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::PARALYSIS
			when 0x7F # Hex
				return move.basedamage*2 if opponent.status!=0
			when 0x80 # Brine
				return move.basedamage*2 if opponent.hp<=(opponent.totalhp/2.0).floor
			when 0x85 # Retaliate
				return move.basedamage*2 if attacker.pbOwnSide.effects[PBEffects::Retaliate]
			when 0x86 # Acrobatics
				return move.basedamage*2 if attacker.item ==0 || attacker.hasWorkingItem(:FLYINGGEM) || @battle.FE == PBFields::BIGTOPA
			when 0x87 # Weather Ball
				return move.basedamage*2 if (@battle.pbWeather!=0 || @battle.FE == PBFields::RAINBOWF)
			when 0x89 # Return
				return [(attacker.happiness*2/5).floor,1].max
			when 0x8A # Frustration
				return [((255-attacker.happiness)*2/5).floor,1].max
			when 0x8B # Eruption
				return [(150*(attacker.hp.to_f)/attacker.totalhp).floor,1].max
			when 0x8C # Crush Grip
				return [(120*(opponent.hp.to_f)/opponent.totalhp).floor,1].max
			when 0x8D # Gyro Ball
				ospeed=pbRoughStat(opponent,PBStats::SPEED)
				aspeed=pbRoughStat(attacker,PBStats::SPEED)
				return [[(25*ospeed/aspeed).floor,150].min,1].max
			when 0x8E # Stored Power
				mult=0
				for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
						PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
				mult+=attacker.stages[i] if attacker.stages[i]>0
				end
				return 20*(mult+1)
			when 0x8F # Punishment
				mult=0
				for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
						PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
				mult+=opponent.stages[i] if opponent.stages[i]>0
				end
				return [20*(mult+3),200].min
			when 0x91 # Fury Cutter
				return basedamage * 2**(attacker.effects[PBEffects::FuryCutter])
			when 0x92 # Echoed Voice
				return basedamage*attacker.effects[PBEffects::EchoedVoice]
			when 0x94 # Present
				return 50
			when 0x95 # Magnitude
				return basedamage*2 if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCA # Dig
				return 71
			when 0x96 # Natural Gift
				return !PBStuff::NATURALGIFTDAMAGE[attacker.item].nil? ? PBStuff::NATURALGIFTDAMAGE[attacker.item] : 1
			when 0x97 # Trump Card
				dmgs=[200,80,60,50,40]
				ppleft=[move.pp-1,4].min   # PP is reduced before the move is used
				return dmgs[ppleft]
			when 0x98 # Flail
				n=(48*(attacker.hp.to_f)/attacker.totalhp).floor
				return 200 if n<2
				return 150 if n<5
				return 100 if n<10
				return 80 if n<17
				return 40 if n<33
				return 20			
			when 0x99 # Electro Ball
				n=(attacker.pbSpeed/opponent.pbSpeed).floor
				return 150 if n>=4
				return 120 if n>=3
				return 80 if n>=2
				return 60 if n>=1
				return 40				
			when 0x9A # Low Kick
				weight=opponent.weight
				return 120 if weight>2000
				return 100 if weight>1000
				return 80 if weight>500
				return 60 if weight>250
				return 40 if weight>100
				return 20
			when 0x9B # Heavy Slam
				n=(attacker.weight/opponent.weight).floor
				return 120 if n>=5
				return 100 if n>=4
				return 80 if n>=3
				return 60 if n>=2
				return 40
			when 0xA0 # Frost Breath
				return move.basedamage*1.5
			when 0xBD, 0xBE # Double Kick, Twineedle
				return move.basedamage*2
			when 0xBF # Triple Kick
				return move.basedamage*6
			when 0xC0 # Fury Attack
				if attacker.ability == PBAbilities::SKILLLINK
					return move.basedamage*5
				else
					return (move.basedamage*19/6).floor
				end
			when 0xC1 # Beat Up
				party=@battle.pbPartySingleOwner(attacker.index)
				party=party.filter {|mon| !mon.nil? && !mon.isEgg? && mon.hp>0 && mon.status==0}
				basedamage=0
				party.each {|mon| basedamage+= 5+(mon.baseStats[1]/10)}
				return basedamage
			when 0xC4 # SolarBeam
				return (move.basedamage*0.5).floor if @battle.pbWeather!=0 && @battle.pbWeather!=PBWeather::SUNNYDAY
			when 0xD0 # Whirlpool
				if @mondata.skill>=MEDIUMSKILL
					return move.basedamage*2 if $cache.pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCB # Dive
				end
			when 0xD3 # Rollout
				if @mondata.skill>=MEDIUMSKILL
					return move.basedamage*2 if attacker.effects[PBEffects::DefenseCurl]
				end
			when 0xD4 # Bide
				return checkAIdamage(attacker,opponent,aimem) unless aimem.any? {|moveloop| moveloop!=nil && [PBMoves::ENDEAVOR,PBMoves::METALBURST,PBMoves::COUNTER,PBMoves::MIRRORCOAT,PBMoves::BIDE].include?(moveloop.id)}
			when 0xE1 # Final Gambit
				return attacker.hp
			when 0xF0 # Knock Off
				return move.basedamage*1.5 if opponent.item!=0 && !@battle.pbIsUnlosableItem(opponent,opponent.item)
			when 0xF7 # Fling
				if attacker.item ==0
					return 0
				else
					return 10 if pbIsBerry?(attacker.item)
					return PBStuff::FLINGDAMAGE[attacker.item] if PBStuff::FLINGDAMAGE[attacker.item]
					return 1
				end
			when 0x113 # Spit Up
				return 100*attacker.effects[PBEffects::Stockpile]
			when 0x161 # First Impression
				return move.basedamage if attacker.turncount<=1
				return 0
			when 0x171 # Stomping Tantrum
				return move.basedamage*2 if attacker.effects[PBEffects::Tantrum]		
		end
		return move.basedamage
	end

	def pbStatusDamage(move)
		return PBStuff::STATUSDAMAGE[move.id] if PBStuff::STATUSDAMAGE[move.id]
		return 0
	end

	def pbRoughDamageAfterBoosts(move=@move,attacker=@attacker,opponent=@opponent,oppboosts: {},attboosts:{})
		# Set the Default value of the hashes, not really necessary
		oppboosts.default = 0
		attboosts.default = 0

		# Clone the stages arrays
		oppstages = opponent.stages.clone
		attstages = attacker.stages.clone

		# Apply stat changes to pokemons
		for stat in oppboosts.keys
			opponent.stages[stat] += oppboosts[stat]
			opponent.stages[stat].clamp(-6,6)
		end
		for stat in attboosts.keys
			attacker.stages[stat] += attboosts[stat]
			attacker.stages[stat].clamp(-6,6)
		end

		# Recalculate the damge
		damage = pbRoughDamage(move,attacker,opponent)

		# Revert the stat changes
		opponent.stages = oppstages
		attacker.stages = attstages

		return damage
	end


	def mirrorShatter
    	return true
	end

	def caveCollapse
		return false
	end

	def mirrorNeverMiss
		return (@attacker.stages[PBStats::ACCURACY] < 0 || @opponent.stages[PBStats::EVASION] > 0 || @opponent.item == PBItems::BRIGHTPOWDER || 
			@opponent.item == PBItems::LAXINCENSE || accuracyWeatherAbilityActive?(@opponent) || @opponent.vanished) &&
			 @opponent.ability != PBAbilities::NOGUARD && @attacker.ability != PBAbilities::NOGUARD && !(@attacker.ability == PBAbilities::FAIRYAURA && @battle.FE == PBFields::FAIRYTALEF)
	end

	def mistExplosion
		return !@battle.pbCheckGlobalAbility(:DAMP)
	end

	def ignitecheck
		return @battle.state.effects[PBEffects::WaterSport] <= 0 && @battle.pbWeather != PBWeather::RAINDANCE
	end

	def suncheck;	end

	def pbAegislashStats(aegi)
		if aegi.form==1
		  	return aegi
		else
			bladecheck = aegi.clone
			bladecheck.stages = aegi.stages.map(&:clone)
			bladecheck.form = 1
			bladecheck.stages[PBStats::ATTACK] += 1 if @battle.FE == PBFields::FAIRYTALEF && bladecheck.stages[PBStats::ATTACK]<6
			return bladecheck
		end
	end

	def moveSuccesful?(move,attacker,opponent)
		if move.pbIsPriorityMoveAI(attacker)
			return false if @battle.FE == PBFields::PSYCHICT && !attacker.isAirborne?
			return false if opponent.ability == PBAbilities::DAZZLING || opponent.ability == PBAbilities::QUEENLYMAJESTY
			return false if opponent.pbPartner.ability == PBAbilities::DAZZLING || opponent.pbPartner.ability == PBAbilities::QUEENLYMAJESTY
			return false if opponent.ability == PBAbilities::PRANKSTER && move.pbIsStatus?
		end
		return true
	end

#####################################################
## Utility functions							    #
#####################################################

	def moldBreakerCheck(battler)
		return battler.ability==PBAbilities::MOLDBREAKER || battler.ability==PBAbilities::TERAVOLT || battler.ability==PBAbilities::TURBOBLAZE
	end

	def hydrationCheck(battler)
		return battler.ability == PBAbilities::HYDRATION && (@battle.pbWeather==PBWeather::RAINDANCE || @battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER)
	end

	def notOHKO?(attacker,opponent, immediate = false)
		return false if @battle.pbWeather == PBWeather::HAIL && !attacker.pbHasType?(:ICE) && !immediate
		return false if @battle.pbWeather == PBWeather::SANDSTORM && !(attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)) && !immediate
		return false if attacker.hp != attacker.totalhp
		return false if attacker.ability == PBAbilities::PARENTALBOND || attacker.ability == PBAbilities::SKILLLINK
		bestmove, damage = checkAIMovePlusDamage(opponent, attacker)
		return false if bestmove.pbIsMultiHit && damage >= attacker.hp
		return true  if attacker.hasWorkingItem(:FOCUSSASH)
		return true  if @battle.FE == PBFields::CHESSB && attacker.pokemon.piece==:PAWN && !attacker.damagestate.pawnsturdyused && @mondata.skill >= HIGHSKILL
		return true	 if attacker.ability == PBAbilities::STURDY && !moldBreakerCheck(opponent)
		return false
	end

	def canGroundMoveHit?(battler)
		return true if battler.item == PBItems::IRONBALL
		return true if battler.effects[PBEffects::Ingrain]
		return true if battler.effects[PBEffects::SmackDown]
		return true if @battle.state.effects[PBEffects::Gravity]>0
		return true if @battle.FE == PBFields::CAVE
		return false if battler.pbHasType?(:FLYING) && battler.effects[PBEffects::Roost]==false && @battle.FE != PBFields::INVERSEF
		return false if battler.ability == PBAbilities::LEVITATE
		return false if battler.item == PBItems::AIRBALLOON && battler.itemWorks?
		return false if battler.effects[PBEffects::MagnetRise]>0
		return false if battler.effects[PBEffects::Telekinesis]>0
		return true
	  end

	def secondaryEffectNegated?(move = @move, attacker = @attacker, opponent = @opponent)
		return move.basedamage > 0 && (opponent.ability == PBAbilities::SHIELDDUST || attacker.ability == PBAbilities::SHEERFORCE)
	end

	def seedProtection?(battler = @attacker)
		return battler.effects[PBEffects::KingsShield] || battler.effects[PBEffects::BanefulBunker] || battler.effects[PBEffects::SpikyShield]
	end

	def accuracyWeatherAbilityActive?(battler)
		return (battler.ability == PBAbilities::SANDVEIL && (@battle.pbWeather==PBWeather::SANDSTORM || @mondata.skill >=BESTSKILL && (@battle.FE == PBFields::DESERTF || @battle.FE == PBFields::ASHENB))) ||
		(battler.ability == PBAbilities::SNOWCLOAK && (@battle.pbWeather==PBWeather::HAIL || @mondata.skill >=BESTSKILL && (@battle.FE == PBFields::ICYF || @battle.FE == PBFields::SNOWYM)))
	end

	def firstOpponent
		return	@battle.doublebattle ? (@attacker.pbOppositeOpposing.hp > 0 ? @attacker.pbOppositeOpposing : @attacker.pbCrossOpposing) : @attacker.pbOppositeOpposing
	end

end

#####################################################
## Other Classes								    #
#####################################################

class PokeBattle_Move_FFF < PokeBattle_Move	#Fake move used by AI to determine damage if no damaging AI memory move
	def initialize(battle,user,type)
		@id = 9999
		@battle = battle
		@name = "Fake Move"
		@function    = 0xFFF
		@basedamage  = user.level >= 40 ? 80 : [2*user.level,40].max
		@type        = type
		@category    = (user.attack>user.spatk) ? 0 : 1
		@accuracy    = 100
		@addlEffect  = 0
		@target      = PBTargets::SingleNonUser
		@priority    = 0
		@flags       = 40 #bef (affected by protect, mirror move copyable, kings rock works)
	#	@thismove    = move
		@pp          = 15
		@zmove       = false
		@user        = user
	end
end


class PokeBattle_ZMoves2 < PokeBattle_ZMoves
	attr_accessor	:fromothermove

	def initialize(move,crystal,battle,user,fromothermove=false) #Creates a z-move and doesn't use it.
		@battle		= battle
		@status     = !(move.pbIsPhysical?() || move.pbIsSpecial?())
		@oldmove    = move
		@oldname    = move.name
		@id         = pbZMoveId(move,crystal)
		@battle     = battle
		@name       = pbZMoveName(move,@id)
		# Get data on the move
		@function   = pbZMoveFunction
		@basedamage = pbZMoveBaseDamage(move,crystal)
		@type       = move.type
		@accuracy   = pbZMoveAccuracy(move,crystal)
		@addlEffect = 100 #pbZMoveAddlEffectChance(move,crystal)
		@target     = move.target
		@priority   = @oldmove.priority
		@flags      = pbZMoveFlags(move,@id)
		@category   = move.category
		@pp         = 1
		@totalpp    = 1
		@thismove   = self #move
		@zmove      = true
		@fromothermove = fromothermove
		@user		= user
	end

	def pbZMoveFunction
		case @id
			when PBMoves::BLOOMDOOM then return 0x135
			when PBMoves::STOKEDSPARKSURFER then return 0x07
			when PBMoves::GENESISSUPERNOVA then return 0x168
			when PBMoves::EXTREMEEVOBOOST then return 0x2d
			#when PBMoves::SPLINTEREDSTORMSHARDS then return 0x168
			when PBMoves::GUARDIANOFALOLA then return 0x6C #Super fang- not making a new function code just for this
			when PBMoves::CLANGOROUSSOULBLAZE then return 0x2d
			when PBMoves::SPLINTEREDSTORMSHARDS then return 0x156
			when PBMoves::SEARINGSUNRAZESMASH then return 0x166
			when PBMoves::MENACINGMOONRAZEMAELSTROM then return 0x166
			when PBMoves::LIGHTTHATBURNSTHESKY then return 0x176
			when PBMoves::CONVERSION, PBMoves::CELEBRATE then return 0xFFE
			else
				return 0x00
		end
	end
end

class PokeBattle_AI_Info #info per battler for debuglogging
	attr_accessor :battler_name
	attr_accessor :battler_item
	attr_accessor :battler_ability
	attr_accessor :field_effect
	attr_accessor :items
	attr_accessor :items_scores
	attr_accessor :switch_scores
	attr_accessor :switch_name
	attr_accessor :should_switch_score
	attr_accessor :move_names
	attr_accessor :init_score_moves
	attr_accessor :final_score_moves
	attr_accessor :chosen_action
	attr_accessor :opponent_name
	attr_accessor :expected_damage
	attr_accessor :expected_damage_name
	attr_accessor :battler_hp_percentage

	def initialize
		@battler_name								= ""
		@battler_item								= ""
		@battler_ability							= ""
		@battler_hp_percentage						= 0
		@field_effect								= 0
		@items 										= []
		@items_scores 								= []
		@switch_scores 								= []
		@switch_name 								= []
		@should_switch_score						= 0
		@move_names									= []
		@opponent_name								= []
		@init_score_moves							= []
		@final_score_moves							= []
		@chosen_action								= ""
		@expected_damage							= []
		@expected_damage_name						= []
	end

	def reset(battler)
		@battler_name								= battler.nil? ? "" : battler.name
		@battler_item								= battler.nil? || battler.item==0 ? "" : PBItems.getName(battler.item)
		@battler_ability							= battler.nil? || battler.ability==0 ? "" : PBAbilities.getName(battler.ability)
		@battler_hp_percentage						= (battler.hp*100.0 / battler.totalhp).round(1)
		@field_effect								= battler.battle.FE
		@items 										= []
		@items_scores 								= []
		@switch_scores 								= []
		@switch_name 								= []
		@should_switch_score						= 0
		@move_names 								= []
		@opponent_name								= []
		@init_score_moves							= []
		@final_score_moves							= []
		@chosen_action								= ""
		@expected_damage							= []
		@expected_damage_name						= []
	end

	def logAIScorings()
		return if !$INTERNAL
		to_be_printed = "\n ______________________________________________________________________________ \n"
		to_be_printed += "Scoring for battler: " + @battler_name + " , HP percentage: #{@battler_hp_percentage} %\n"
		to_be_printed += "Held Item: " + @battler_item + " , Ability: " + @battler_ability + " , Field: " + PokeBattle_Field.getFieldName(@field_effect).to_s + "\n"
		to_be_printed += " "*60 +  +"|AI Scores\n"
	
		#Add scores for current hp and the expected damage it will take
		@expected_damage.each_with_index {|_,i|
		to_be_printed += "Expected Damage taken from #{@expected_damage_name[i]}".ljust(60) + "|#{@expected_damage[i]} % \n"
		}
		to_be_printed += "\n"
	
		#Add scores for items and switching to string
		to_be_printed += "Scoring for Switching to other mon".ljust(60) + "|"  + "#{@should_switch_score} \n \n"
		to_be_printed += "Scoring for items".ljust(60) + "|".ljust(21) + "| \n"	if @items.length != 0
		@items.each_with_index {|item_name, index|
		to_be_printed += item_name.ljust(60) + "|" + @items_scores[index].to_s.ljust(20) + "\n"
		}
		
		# Sort the move order so moves are grouped together
		@opponent_name.sort_by!.with_index{|_,i|@move_names[i]}
		@init_score_moves.sort_by!.with_index{|_,i|@move_names[i]}
		@final_score_moves.sort_by!.with_index{|_,i|@move_names[i]}
		@move_names.sort!

		# Now add these badboys to the string
		@move_names.each_with_index {|movename,index|
		to_be_printed += "#{movename} vs #{@opponent_name[index]}, Init scoring move: ".ljust(60) + "|#{@init_score_moves[index]} \n"
		to_be_printed += "#{movename} vs #{@opponent_name[index]}, Final scoring move: ".ljust(60) +"|#{@final_score_moves[index]} \n"
		to_be_printed += "\n"
		}
		to_be_printed += "Final action chosen:".ljust(60) + "|#{@chosen_action}".ljust(20)
		to_be_printed += "\n ______________________________________________________________________________ \n"
	
		#put to console
		$stdout.print(to_be_printed)
		PBDebug.log(to_be_printed)
	end
	
	def logAISwitching()
		return if !$DEBUG
		to_be_printed = "Scoring for switching from: " + @battler_name + "\n"
		to_be_printed += " "*60 +"|New AI\n"
		@switch_name.each_with_index {|name, index|
			to_be_printed += "Score for switching to #{name}".ljust(60) + "|#{@switch_scores[index]} \n"
		}
		to_be_printed += "Switch chosen = ".ljust(60) + "|#{@switch_name[@switch_scores.index(@switch_scores.max)]} \n"
		to_be_printed += "\n ______________________________________________________________________________ \n"
		$stdout.print(to_be_printed)
		PBDebug.log(to_be_printed)
	end
end



