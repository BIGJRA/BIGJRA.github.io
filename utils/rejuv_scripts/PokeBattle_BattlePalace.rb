class PokeBattle_BattlePalace < PokeBattle_Battle
  @@BattlePalaceUsualTable=[
    61, 7,32,
    20,25,55,
    70,15,15,
    38,31,31,
    20,70,10,
    30,20,50,
    56,22,22,
    25,15,60,
    69, 6,25,
    35,10,55,
    62,10,28,
    58,37, 5,
    34,11,55,
    35, 5,60,
    56,22,22, 
    35,45,20,  
    44,50, 6, 
    56,22,22,  
    30,58,12,   
    30,13,57, 
    40,50,10,  
    18,70,12,  
    88, 6, 6, 
    42,50, 8,
    56,22,22
  ]
  @@BattlePalacePinchTable=[
    61, 7,32,
    84, 8, 8,
    32,60, 8,
    70,15,15,
    70,22, 8,  
    32,58,10,
    56,22,22,
    75,15,10,
    28,55,17,
    29, 6,65, 
    30,20,50,  
    88, 6, 6,  
    29,11,60,  
    35,60, 5,  
    56,22,22, 
    34,60, 6, 
    34, 6,60,
    56,22,22,  
    30,58,12,
    27, 6,67,
    25,62,13,
    90, 5, 5,  
    22,20,58,
    42, 5,53,
    56,22,22
  ]

  def initialize(*arg)
    super
    @justswitched=[false,false,false,false]
  end

  def pbMoveCategory(move)
    if move.target==0x10 || move.function==0xD4 # Bide
      return 1
    elsif move.basedamage==0 || move.function==0x71 || # Counter
       move.function==0x72 # Mirror Coat
      return 2
    else
      return 0
    end
  end

# Different implementation of pbCanChooseMove, ignores Imprison/Torment/Taunt/Disable/Encore
  def pbCanChooseMovePartial?(idxPokemon,idxMove)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    if !thismove||thismove.id==0
      return false
    end
    if thismove.pp<=0
      return false
    end
    if thispkmn.effects[PBEffects::ChoiceBand]>=0 && 
       thismove.id!=thispkmn.effects[PBEffects::ChoiceBand] &&
       thispkmn.hasWorkingItem(:CHOICEBAND)
      return false
    end
    # though incorrect, just for convenience (actually checks Torment later)
    if thispkmn.effects[PBEffects::Torment]
      if thismove.id==thispkmn.lastMoveUsed
        return false
      end
    end
    return true
  end

  def pbPinchChange(idxPokemon)
    thispkmn=@battlers[idxPokemon]
    if !thispkmn.effects[PBEffects::Pinch] && thispkmn.status!=PBStatuses::SLEEP && 
       thispkmn.hp<=(thispkmn.totalhp/2).floor
      nature=thispkmn.nature
      thispkmn.effects[PBEffects::Pinch]=true
      if nature==PBNatures::QUIET|| 
         nature==PBNatures::BASHFUL||
         nature==PBNatures::NAIVE||
         nature==PBNatures::QUIRKY||
         nature==PBNatures::HARDY||
         nature==PBNatures::DOCILE||
         nature==PBNatures::SERIOUS
        pbDisplay(_INTL("{1} is eager for more!",thispkmn.pbThis))
      end
      if nature==PBNatures::CAREFUL||
         nature==PBNatures::RASH||
         nature==PBNatures::LAX||
         nature==PBNatures::SASSY||
         nature==PBNatures::MILD||
         nature==PBNatures::TIMID
        pbDisplay(_INTL("{1} began growling deeply!",thispkmn.pbThis))
      end
      if nature==PBNatures::GENTLE||
         nature==PBNatures::ADAMANT||
         nature==PBNatures::HASTY||
         nature==PBNatures::LONELY||
         nature==PBNatures::RELAXED||
         nature==PBNatures::NAUGHTY
        pbDisplay(_INTL("A glint appears in {1}'s eyes!",thispkmn.pbThis(true)))
      end
      if nature==PBNatures::JOLLY||
         nature==PBNatures::BOLD||
         nature==PBNatures::BRAVE||
         nature==PBNatures::CALM||
         nature==PBNatures::IMPISH||
         nature==PBNatures::MODEST
        pbDisplay(_INTL("{1} is getting into position!",thispkmn.pbThis))
      end
    end
  end

  def pbEnemyShouldWithdraw?(index)
    shouldswitch=false
    if @battlers[index].effects[PBEffects::PerishSong]==1
      shouldswitch=true
    elsif !pbCanChooseMove?(index,0,false) &&
          !pbCanChooseMove?(index,1,false) &&
          !pbCanChooseMove?(index,2,false) &&
          !pbCanChooseMove?(index,3,false) &&
          @battlers[index].turncount &&
          @battlers[index].turncount>5
      shouldswitch=true
    else
      hppercent=@battlers[index].hp*100/@battlers[index].totalhp
      percents=[]
      maxindex=-1
      maxpercent=0
      factor=0
      party=pbParty(index)
      for i in 0...party.length
        if pbCanSwitch?(index,i,false)
          percents[i]=party[i].hp*100/party[i].totalhp
          if percents[i]>maxpercent
            maxindex=i
            maxpercent=percents[i]
          end
        else
          percents[i]=0
        end
      end
      if hppercent<50
        factor=(maxpercent<hppercent) ? 20 : 40
      end
      if hppercent<25
        factor=(maxpercent<hppercent) ? 30 : 50   
      end
      if @battlers[index].status==PBStatuses::BURN ||
         @battlers[index].status==PBStatuses::POISON
        factor+=10
      end
      if @battlers[index].status==PBStatuses::PARALYSIS
        factor+=15
      end
      if @battlers[index].status==PBStatuses::FROZEN ||
         @battlers[index].status==PBStatuses::SLEEP
        factor+=20
      end
      if @justswitched[index]
        factor-=60
        factor=0 if factor<0
      end
      shouldswitch=(pbAIRandom(100)<factor)
      if shouldswitch && maxindex>=0
        pbRegisterSwitch(index,maxindex)
        return true
      end
    end
    @justswitched[index]=shouldswitch
    if shouldswitch
      party=pbParty(index)
      for i in 0...party.length
        if pbCanSwitch?(index,i,false)
          pbRegisterSwitch(index,i)
          return true
        end
      end
    end
    return false
  end

  def pbRegisterMove(idxPokemon,idxMove,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    if idxMove==-2
      @choices[idxPokemon][0]=1 # Move
      @choices[idxPokemon][1]=-2 # "Incapable of using its power..."
      @choices[idxPokemon][2]=@struggle
      @choices[idxPokemon][3]=-1
    else
      @choices[idxPokemon][0]=1 # Move
      @choices[idxPokemon][1]=idxMove # Index of move
      @choices[idxPokemon][2]=thispkmn.moves[idxMove] # Move object
      @choices[idxPokemon][3]=-1 # No target chosen
    end
  end

  def pbAutoFightMenu(idxPokemon)
    thispkmn=@battlers[idxPokemon]
    nature=thispkmn.nature
    randnum=pbAIRandom(100)
    category=0
    atkpercent=0
    defpercent=0
    if !thispkmn.effects[PBEffects::Pinch]
      atkpercent=@@BattlePalaceUsualTable[nature*3]
      defpercent=atkpercent+@@BattlePalaceUsualTable[nature*3+1]
    else
      atkpercent=@@BattlePalacePinchTable[nature*3]
      defpercent=atkpercent+@@BattlePalacePinchTable[nature*3+1]
    end
    if randnum<atkpercent
      category=0
    elsif randnum<defpercent
      category=1
    else
      category=2
    end
    moves=[]
    for i in 0...thispkmn.moves.length
      next if !pbCanChooseMovePartial?(idxPokemon,i)
      if pbMoveCategory(thispkmn.moves[i])==category
        moves[moves.length]=i
      end
    end
    if moves.length==0
      # No moves of selected category
      pbRegisterMove(idxPokemon,-2)
    else
      chosenmove=moves[pbAIRandom(moves.length)]
      pbRegisterMove(idxPokemon,chosenmove)
    end
    return true
  end

  def pbEndOfRoundPhase
    super
    return if @decision!=0
    for i in 0...4
      if !@battlers[i].isFainted?
        pbPinchChange(i)
      end
    end
  end
end