# Results of battle:
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw
################################################################################
  class PokeBattle_Move
    def battle=(value)
      @battle=value
    end
  end

################################################################################
# Main battle class.
################################################################################
$OnlineBattle=nil
class PokeBattle_OnlineBattle < PokeBattle_Battle
  attr_accessor(:TIEVAR)          # Online stuff
  attr_accessor(:tiebreak)     #for speed ties
  include PokeBattle_BattleCommon
  
  ONLINEEXPGAIN = false
  ONLINEGAINMONEY = false
  MAXPARTYSIZE = 6

  class BattleAbortedException < Exception; end

  def pbRandom(x)
    return rand(x)
  end

  def pbAIRandom(x)
    return rand(x)
  end

  def isOnline?
    return true
  end
################################################################################
# Initialise battle class.
################################################################################
  def initialize(scene,p1,p2,player,opponent,tiebreak)
    @scene = scene
    @turncount = 0
    receive_seed
    super(scene,p1,p2,player,opponent)
    @field = PokeBattle_FieldOnline.new($feonline)
    @tiebreak        = tiebreak #for speed ties
    @TIEVAR=nil
  end

################################################################################
# Info about battle.
################################################################################
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
        pri = @choices[i][2].priority if !@choices[i][2].zmove  #Base move priority
        pri += 1 if @battle.FE == PBFields::CHESSB && @battlers[i].pokemon && @battlers[i].pokemon.piece == :KING
        pri += 1 if @battlers[i].ability == PBAbilities::PRANKSTER && @choices[i][2].basedamage==0 # Is status move
        pri += 1 if @battlers[i].ability == PBAbilities::GALEWINGS && @choices[i][2].type==2 && ((@battlers[i].hp == @battlers[i].totalhp) || ((@battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM) && @weather == PBWeather::STRONGWINDS))
        pri += 3 if @battlers[i].ability == PBAbilities::TRIAGE && (PBStuff::HEALFUNCTIONS).include?(@choices[i][2].function) 
      end
      priorityarray[i][0]=pri
      #Item/stall priority (all items overwrite stall priority)
      priorityarray[i][1] = -1 if @battlers[i].ability == PBAbilities::STALL
      if !ignorequickclaw
        priorityarray[i][1] = 1 if @battlers[i].custap || (@battlers[i].itemWorks? && @battlers[i].item == PBItems::QUICKCLAW && (pbRandom(100)<20))
      end
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
          if pbRandom(2)==@tiebreak 
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
################################################################################
# Switching Pokémon.
################################################################################
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
    switched=[]
    oneByYou=-1
    oneByOpponent=-1
    for index in 0...4
      next if !@doublebattle && pbIsDoubleBattler?(index)
      next if @battlers[index] && !@battlers[index].isFainted?
      next if !pbCanChooseNonActive?(index)
      oneByYou=index if pbOwnedByPlayer?(index)
      oneByOpponent=index if !pbOwnedByPlayer?(index)
    end
    if oneByYou!=-1 && oneByOpponent!=-1 #both trainers need to send in a mon
      meIsFaster=false
      if @battlers[oneByYou].speed>@battlers[oneByOpponent].speed
        meIsFaster=true
      elsif @battlers[oneByYou].speed==@battlers[oneByOpponent].speed
        if @battlers[oneByYou].pokemon.trainerID>@battlers[oneByOpponent].pokemon.trainerID
          meIsFaster=true
        end
      end
      indexAry=[0,1,2,3] if meIsFaster
      indexAry=[1,0,3,2] if !meIsFaster
    else
        indexAry=[0,1,2,3]
    end
    for index in indexAry
      next if !@doublebattle && pbIsDoubleBattler?(index)
      next if @battlers[index] && @battlers[index].hp>0
      next if !pbCanChooseNonActive?(index)
      if !pbOwnedByPlayer?(index)
        if @opponent
          newenemy = waitnewenemy
          pbRecallAndReplace(index,newenemy)
          switched.push(index)
        end
      elsif @opponent
        newpoke=pbSwitchInBetween(index,true,false)
        pbRecallAndReplace(index,newpoke)
        switched.push(index)
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
    pbSetSeen(pokemon)
    @peer.pbOnEnteringBattle(self,pokemon)
    if pbIsOpposing?(index)
      @scene.pbTrainerSendOut(index,pokemon)
    else
      @scene.pbSendOut(index,pokemon)
    end
    @scene.pbResetMoveIndex(index)
  end

  def pbSwitchInBetween(index,lax,cancancel,activatedata=false)
    if !pbOwnedByPlayer?(index)
      newenemy = waitnewenemy
      return newenemy
    else
      newpoke = pbSwitchPlayer(index,lax,cancancel)
      $network.send("<BAT new=#{newpoke}>")
      return newpoke
    end
  end

################################################################################
# Fleeing from battle.
################################################################################
  def pbRun(idxPokemon,duringBattle=false)
    thispkmn=@battlers[idxPokemon]
    if pbIsOpposing?(idxPokemon)
      if @opponent
        return 0
      else
        @choices[i][0]=5 # run
        @choices[i][1]=0
        @choices[i][2]=nil
        return -1
      end
    end
    if @opponent
      if pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
        pbDisplay(_INTL("{1} forfeited the match!",self.pbPlayer.name))
        $network.send("<BAT dead>")
        @decision=3
        return 1
      end
      return 0
    end
  end

################################################################################
# Gaining Experience.
################################################################################
  def pbGainEXP
    return if ONLINEEXPGAIN == false
    super
  end

################################################################################
# Battle core.
################################################################################
  def pbStartBattle(canlose=false)
    begin
      pbBGMPlay(pbGetOnlineBattleBGM($Trainer))
      pbStartBattleCore(canlose)
    rescue BattleAbortedException
     @decision=0
     @scene.pbEndBattle(@decision)
    end
    return @decision
  end

  def pbStartBattleCore(canlose)
    super
    loop do   # Now begin the battle loop
      PBDebug.log("***Round #{@turncount}***") if $INTERNAL
      if @debug && @turncount>=101
        @decision=pbDecisionOnTime()
        PBDebug.log("***[Undecided after 100 rounds]")
        pbAbort
        break
      end
      PBDebug.logonerr{
         pbCommandPhase
      }
      #need to quickly delete this or else it chashes bc of size
      for i in 0..3
        @battlers[0].moves[i].battle = nil
        @battlers[2].moves[i].battle = nil if @doublebattle
      end
      choices = ([Marshal.dump(@choices[0])].pack("m").delete("\n") rescue nil)
      choices2 = ""
      choices2 = ([Marshal.dump(@choices[2])].pack("m").delete("\n") rescue nil) if @doublebattle
      #restore them bishes
      for i in 0..3
        @battlers[0].moves[i].battle = self
        @battlers[2].moves[i].battle = self if @doublebattle
      end
      specarr = [@megaEvolution[0][0], @zMove[0][0], @ultraBurst[0][0]].join(",")
      $network.send("<BAT choices=#{choices} rseed=#{choices2} special=#{specarr}>")
      loop do
        pbDisplay("Waiting...")
        Graphics.update
        Input.update
        message = $network.listen
        case message
          when /<ACTI>/ then $network.send("<ACTI>")
          when /<BAT choices=(.*) rseed=(.*) special=(.*)>/ 
            @choices[1] = Marshal.load($1.unpack("m")[0])
            @choices[3] = Marshal.load($2.unpack("m")[0]) if @doublebattle
            for i in 0..3
              @battlers[1].moves[i].battle = self
              @battlers[3].moves[i].battle = self if @doublebattle
            end
            specials = $3
            newspec = specials.split(",").map { |s| (s.to_i) }
            @megaEvolution[1][0]        = newspec[0]
            @zMove[1][0]                = newspec[1]
            @ultraBurst[1][0]           = newspec[2]

            # Fixing the index registered
            @megaEvolution[1][0] +=1    if @megaEvolution[1][0] == 0 || @megaEvolution[1][0] == 2
            @zMove[1][0] +=1            if @zMove[1][0] == 0 || @zMove[1][0] == 2
            @ultraBurst[1][0] +=1       if @ultraBurst[1][0] == 0 || @ultraBurst[1][0] == 2
            PBDebug.log(@choices[1].join(", ") + "\n\n")
            PBDebug.log(@choices[3].join(", ") + "\n\n")
            PBDebug.log(newspec.join(", ") + "\n\n")
            break
          when /<BAT choices=(.*)>/
            raise "crash"
          when /<BAT dead>/
            @decision = 1
            Kernel.pbMessage("Other player disconnected.")
            return pbEndOfBattle  
          end
      end
      #register action of opponent correctly if necessary
      @choices[1][2]=@battlers[1].moves[@choices[1][1]] if @choices[1][0] == 1 # Need to reset move object
      @choices[1][3] = @choices[1][3]^1 if @doublebattle && @choices[1][0] == 1 && @choices[1][3] >= 0 #reset target
      @battlers[1].selectedMove=@battlers[1].moves[@choices[1][1]].id if @choices[1][0] == 1

      @choices[3][2]=@battlers[3].moves[@choices[3][1]] if @choices[3][0] == 1 # Need to reset move object
      @choices[3][3] = @choices[3][3]^1 if @doublebattle && @choices[3][0] == 1 && @choices[3][3] >= 0 #reset target
      @battlers[3].selectedMove=@battlers[3].moves[@choices[3][1]].id if @choices[3][0] == 1

      receive_seed
      break if @decision>0
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
# End of battle.
################################################################################
  def pbEndOfBattle(canlose=false)
    super
    $network.send("<DSC>")
  end

################################################################################
#Waits to receive a change in battler after fainting.
################################################################################
  def waitnewenemy
    timeout = Time.now.to_i
    loop do
      pbDisplay("Waiting...")
      @scene.pbGraphicsUpdate
      @scene.pbInputUpdate
      message = $network.listen
      case message
        when /<ACTI>/ then $network.send("<ACTI>")
        when /<BAT new=(.*)>/
          PBDebug.log("\n\nnewenemy: " + $1.to_s + "\n\n")
          return $1.to_i
          break
        end         
    end
  end

################################################################################
#Waits for the server to send a new seed.
################################################################################      
  
  def receive_seed
    $network.send("<BAT seed turn=#{@turncount-1}>")
    loop do
      @scene.pbGraphicsUpdate
      @scene.pbInputUpdate
      message = $network.listen
      case message
        when /<ACTI>/ then $network.send("<ACTI>")
        when /<BAT seed=(.*)>/
          seed = $1
          PBDebug.log("\n\nnewseed: " + $1.to_s + "\n\n")
          srand($1.to_i)
          @tiebreak = @tiebreak ^ pbRandom(2)
          break
        end
    end
  end
end
