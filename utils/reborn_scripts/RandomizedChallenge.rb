class RandomizerSettings
  attr_accessor :name

  attr_accessor :selfmon
  attr_accessor :oppmon
  attr_accessor :monexclusions
  attr_accessor :monchaos
  
  attr_accessor :selfabil
  attr_accessor :oppabil
  attr_accessor :abilexclusions
  attr_accessor :abilchaos
  
  attr_accessor :selfmove
  attr_accessor :oppmove
  attr_accessor :moveexclusions
  attr_accessor :movechaos
  
  attr_accessor :selfitem
  attr_accessor :oppitem
  attr_accessor :itemexclusions
  attr_accessor :itemchaos
  
  attr_accessor :selfform
  attr_accessor :oppform
  attr_accessor :formexclusions
  attr_accessor :formchaos
  
  attr_accessor :selftype
  attr_accessor :opptype
  attr_accessor :typeexclusions
  attr_accessor :typechaos
  
  attr_accessor :typeeff
  attr_accessor :typeeffgen

  attr_accessor :movepow
  attr_accessor :movepowgen
  attr_accessor :moveacc
  attr_accessor :moveaccgen
  attr_accessor :movetype

  attr_accessor :typestore
  attr_accessor :abilstore
  attr_accessor :movestore

  def initialize
    @name = $Trainer.name 

    @selfmon = false
    @oppmon = false
    @monexclusions = [PBSpecies::ARCEUS] + [0] + (808..PBSpecies.maxValue).to_a
    #Giratina needs a special exclusion in Rejuv as all wild Giratina are forced as Raid/Boss battles
    @monexclusions.sort!
    @monchaos = false

    @selfabil = false
    @oppabil = false
    @abilexclusions = PBStuff::FIXEDABILITIES - [PBAbilities::COMATOSE] + [PBAbilities::FORECAST] + [0] + (234..304).to_a
    @abilexclusions.sort!
    #Add in exclusions for empty slots
    @abilchaos = false

    @selfmove = false
    @oppmove = false
    @moveexclusions = DummyMoves + PBStuff::OHKOMOVE + [0]
    @moveexclusions.sort!
    @movechaos = false

    @selfitem = false
    @oppitem = false
    @itemexclusions = [0]
    @itemexclusions.sort!
    @itemchaos = false

    @selfform = false
    @oppform = false
    @formexclusions = []
    @formchaos = false

    @selftype = false
    @opptype = false
    @typeexclusions = [PBTypes::QMARKS]
    @typechaos = false

    @typeeff = false
    @typeeffgen = 'dist'

    @movepow = false
    @movepowgen = 'dist' #exclude OHKO and variable damage moves
    @moveacc = false
    @moveaccgen = 'dist'
    @movetype = false
    @movecategory = false #only applies to non-status moves anyway
  end
end
  
DummyMoves = [
    PBMoves::FUTUREDUMMY,PBMoves::DOOMDUMMY,#PBMoves::HEXDUMMY,
    PBMoves::WEATHERBALLSUN,PBMoves::WEATHERBALLRAIN,PBMoves::WEATHERBALLHAIL,PBMoves::WEATHERBALLSAND,
    PBMoves::HIDDENPOWERNOR,PBMoves::HIDDENPOWERFIR,PBMoves::HIDDENPOWERFIG,PBMoves::HIDDENPOWERWAT,PBMoves::HIDDENPOWERFLY,
    PBMoves::HIDDENPOWERGRA,PBMoves::HIDDENPOWERPOI,PBMoves::HIDDENPOWERELE,PBMoves::HIDDENPOWERGRO,PBMoves::HIDDENPOWERPSY,
    PBMoves::HIDDENPOWERROC,PBMoves::HIDDENPOWERICE,PBMoves::HIDDENPOWERBUG,PBMoves::HIDDENPOWERDRA,PBMoves::HIDDENPOWERGHO,
    PBMoves::HIDDENPOWERDAR,PBMoves::HIDDENPOWERSTE,PBMoves::HIDDENPOWERFAI,
    PBMoves::TECHNOBLASTELECTRIC,PBMoves::TECHNOBLASTFIRE,PBMoves::TECHNOBLASTICE,PBMoves::TECHNOBLASTWATER,
    PBMoves::MULTIATTACKBUG,PBMoves::MULTIATTACKDARK,PBMoves::MULTIATTACKDRAGON,PBMoves::MULTIATTACKELECTRIC,PBMoves::MULTIATTACKFAIRY,
    PBMoves::MULTIATTACKFIGHTING,PBMoves::MULTIATTACKFIRE,PBMoves::MULTIATTACKFLYING,PBMoves::MULTIATTACKGHOST,PBMoves::MULTIATTACKGLITCH,
    PBMoves::MULTIATTACKGRASS,PBMoves::MULTIATTACKGROUND,PBMoves::MULTIATTACKICE,PBMoves::MULTIATTACKPOISON,PBMoves::MULTIATTACKPSYCHIC,
    PBMoves::MULTIATTACKROCK,PBMoves::MULTIATTACKSTEEL,PBMoves::MULTIATTACKWATER,
    PBMoves::JUDGMENTBUG,PBMoves::JUDGMENTDARK,PBMoves::JUDGMENTDRAGON,PBMoves::JUDGMENTELECTRIC,PBMoves::JUDGMENTFAIRY,
    PBMoves::JUDGMENTFIGHTING,PBMoves::JUDGMENTFIRE,PBMoves::JUDGMENTFLYING,PBMoves::JUDGMENTGHOST,PBMoves::JUDGMENTQMARKS,
    PBMoves::JUDGMENTGRASS,PBMoves::JUDGMENTGROUND,PBMoves::JUDGMENTICE,PBMoves::JUDGMENTPOISON,PBMoves::JUDGMENTPSYCHIC,
    PBMoves::JUDGMENTROCK,PBMoves::JUDGMENTSTEEL,PBMoves::JUDGMENTWATER
]

RandOtherVars = {
  :typestorage => 0,
  :abilstorage => 1,
  :movestorage => 2
}

def checkMoveBP(var)
  hash = Hash.new
  for move in 1..PBMoves.maxValue
    next if var[move] == nil
    moveBP = var[move][PBMoveData::BASEDAMAGE]
    if !hash.keys.include?(moveBP) && moveBP > 1
      hash.store(moveBP, 1)
    else
      hash[moveBP] += 1 if !DummyMoves.include?(move) && moveBP > 1
    end
  end
  return hash
end

def checkMoveAcc(var)
  hash = Hash.new
  for move in 1..PBMoves.maxValue
    next if var[move] == nil
    moveAcc = var[move][PBMoveData::ACCURACY]
    if !hash.keys.include?(moveAcc) && !DummyMoves.include?(move) && !PBStuff::OHKOMOVE.include?(move)
      hash.store(moveAcc, 1)
    else
      hash[moveAcc] += 1 if !DummyMoves.include?(move) && !PBStuff::OHKOMOVE.include?(move)
    end
  end
  return hash
end


class RandomizedChallenge  

  TypeEffectivenessDist = [8,60,51] #[No effect,Not Very Effective,SuperEffective]
=begin
  BasePowers = { #Base Power => Amount of Moves with Base Power
    #0=>1, 
    250=>1,
    200=>1,
    180=>1,
    160=>2,
    150=>14,
    140=>9,
    130=>9,
    125=>1,
    120=>29,
    110=>10,
    100=>33,
    95=>5,
    90=>35, 
    85=>14,
    80=>52, 
    75=>16, 
    70=>24, 
    65=>24, 
    60=>57, 
    55=>7,
    50=>25,
    45=>1,
    40=>34,
    35=>7,
    30=>7,
    25=>7,
    20=>8,
    18=>2,
    15=>8,
    10=>2,
    #1=>38
    }
  Accuracies = { #Accuracy => Amount of Moves with Accuracy
    0=>18, 
    100=>328,
    95=>32,
    90=>52,
    85=>29,
    80=>7,
    75=>6,
    70=>5,
    50=>3,        
    #30=>4
  }
=end 



  
  HiddenPower = [
    PBMoves::HIDDENPOWERNOR,PBMoves::HIDDENPOWERFIR,PBMoves::HIDDENPOWERFIG,PBMoves::HIDDENPOWERWAT,PBMoves::HIDDENPOWERFLY,
    PBMoves::HIDDENPOWERGRA,PBMoves::HIDDENPOWERPOI,PBMoves::HIDDENPOWERELE,PBMoves::HIDDENPOWERGRO,PBMoves::HIDDENPOWERPSY,
    PBMoves::HIDDENPOWERROC,PBMoves::HIDDENPOWERICE,PBMoves::HIDDENPOWERBUG,PBMoves::HIDDENPOWERDRA,PBMoves::HIDDENPOWERGHO,
    PBMoves::HIDDENPOWERDAR,PBMoves::HIDDENPOWERSTE,PBMoves::HIDDENPOWERFAI
  ]

  WeatherBall = [
    PBMoves::WEATHERBALLSUN,PBMoves::WEATHERBALLRAIN,PBMoves::WEATHERBALLHAIL,PBMoves::WEATHERBALLSAND
  ]

  TechnoBlast = [
    PBMoves::TECHNOBLASTELECTRIC,PBMoves::TECHNOBLASTFIRE,PBMoves::TECHNOBLASTICE,PBMoves::TECHNOBLASTWATER
  ]

  MultiAttack = [
    PBMoves::MULTIATTACKBUG,PBMoves::MULTIATTACKDARK,PBMoves::MULTIATTACKDRAGON,PBMoves::MULTIATTACKELECTRIC,PBMoves::MULTIATTACKFAIRY,
    PBMoves::MULTIATTACKFIGHTING,PBMoves::MULTIATTACKFIRE,PBMoves::MULTIATTACKFLYING,PBMoves::MULTIATTACKGHOST,PBMoves::MULTIATTACKGLITCH,
    PBMoves::MULTIATTACKGRASS,PBMoves::MULTIATTACKGROUND,PBMoves::MULTIATTACKICE,PBMoves::MULTIATTACKPOISON,PBMoves::MULTIATTACKPSYCHIC,
    PBMoves::MULTIATTACKROCK,PBMoves::MULTIATTACKSTEEL,PBMoves::MULTIATTACKWATER
  ]

  JUDGMENT = [
    PBMoves::JUDGMENTBUG,PBMoves::JUDGMENTDARK,PBMoves::JUDGMENTDRAGON,PBMoves::JUDGMENTELECTRIC,PBMoves::JUDGMENTFAIRY,
    PBMoves::JUDGMENTFIGHTING,PBMoves::JUDGMENTFIRE,PBMoves::JUDGMENTFLYING,PBMoves::JUDGMENTGHOST,PBMoves::JUDGMENTQMARKS,
    PBMoves::JUDGMENTGRASS,PBMoves::JUDGMENTGROUND,PBMoves::JUDGMENTICE,PBMoves::JUDGMENTPOISON,PBMoves::JUDGMENTPSYCHIC,
    PBMoves::JUDGMENTROCK,PBMoves::JUDGMENTSTEEL,PBMoves::JUDGMENTWATER
  ]

  attr_accessor(:abilities)
  attr_accessor(:moves)
  attr_accessor(:pokemon)
  attr_accessor(:forms)
  attr_accessor(:items)
  attr_accessor(:types)
  attr_accessor(:typechart)
  attr_accessor(:settings)
  
  attr_accessor :BasePowers
  attr_accessor :Accuracies

  attr_accessor :moveTypes
  attr_accessor :moveBP
  attr_accessor :moveAcc

  attr_accessor :random_dex
  attr_accessor :pkmn_moves

  def initialize(settings)
    @BasePowers = checkMoveBP($cache.pkmn_move)
    @Accuracies = checkMoveAcc($cache.pkmn_move)
    @settings = settings
    $game_variables[:Randomized_File_Loc] = @settings.name
    randomizeAbilities if @settings.selfabil || @settings.oppabil
    randomizeMoves if @settings.selfmove || @settings.oppmove
    randomizeItems if @settings.selfitem || @settings.oppitem
    randomizeTypes if @settings.selftype || @settings.opptype
    randomizeTypeChart if @settings.typeeff
    if @settings.selfmon || @settings.oppmon
      randomizeMons
    else
      @pokemon = (0..PBSpecies.maxValue).to_a
    end
    randomizeMoveAcc if @settings.moveacc
    randomizeMoveBP if @settings.movepow

    buildRandomizer
    setRandomizerData(@settings.name)
  end

  def getSettings
    @settings = RandomizerSettings.new
  end

  def randomizeMoveAcc(exclusions = @settings.moveexclusions)
    @moveAcc = Hash.new
    case @settings.moveaccgen
      when "shuffle"
        for move in 0..PBMoves.maxValue
          if !exclusions.include?(move)
            sample = @Accuracies.keys.sample
            @moveAcc.store(move, sample)
            @Accuracies[sample] -= 1
            @Accuracies.delete(sample) if @Accuracies[sample] == 0
          else  
            if move == PBMoves::FUTUREDUMMY
              @moveAcc.store(move, @moveAcc[PBMoves::FUTURESIGHT])
            elsif move == PBMoves::DOOMDUMMY
              @moveAcc.store(move, @moveAcc[PBMoves::DOOMDESIRE])
            #elsif move == PBMoves::HEXDUMMY
            #  @moveAcc.store(move, @moveAcc[PBMoves::HEX])
            elsif HiddenPower.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::HIDDENPOWER])
            elsif WeatherBall.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::WEATHERBALL])
            elsif TechnoBlast.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::TECHNOBLAST])
            elsif MultiAttack.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::MULTIATTACK])
            elsif JUDGMENT.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::JUDGMENT])
            else
              @moveAcc.store(move, -1)
            end
          end
        end
      when "dist"
        accValueAry = Array.new
        for key in @Accuracies.keys
          accValueAry.push(@Accuracies[key])
        end
        accValueAry.sort!
        accValueSums = Array.new
        accValueSums[0] = deep_copy(accValueAry[0])
        for i in 1...accValueAry.length
          accValueSums.push(accValueAry[i] + accValueSums[i - 1])
        end
        invertedAcc = @Accuracies.invert
        for move in 0..PBMoves.maxValue
          if !exclusions.include?(move)
            temp = rand(accValueAry.sum)
            for value in 0...accValueSums.length
              if temp <= accValueSums[value]
                @moveAcc.store(move, invertedAcc[accValueAry[value]])
                break
              end
            end
          else
            if move == PBMoves::FUTUREDUMMY
              @moveAcc.store(move, @moveAcc[PBMoves::FUTURESIGHT])
            elsif move == PBMoves::DOOMDUMMY
              @moveAcc.store(move, @moveAcc[PBMoves::DOOMDESIRE])
            #elsif move == PBMoves::HEXDUMMY
            #  @moveAcc.store(move, @moveAcc[PBMoves::HEX])
            elsif HiddenPower.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::HIDDENPOWER])
            elsif WeatherBall.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::WEATHERBALL])
            elsif TechnoBlast.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::TECHNOBLAST])
            elsif MultiAttack.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::MULTIATTACK])
            elsif JUDGMENT.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::JUDGMENT])
            else
              @moveAcc.store(move, -1)
            end
          end
        end
      when "chaos"
        accKeys = @Accuracies.keys
        for move in 0..PBMoves.maxValue
          if !exclusions.include?(move)
            @moveAcc.store(move, accKeys.sample)
          else
            if move == PBMoves::FUTUREDUMMY
              @moveAcc.store(move, @moveAcc[PBMoves::FUTURESIGHT])
            elsif move == PBMoves::DOOMDUMMY
              @moveAcc.store(move, @moveAcc[PBMoves::DOOMDESIRE])
            #elsif move == PBMoves::HEXDUMMY
            #  @moveAcc.store(move, @moveAcc[PBMoves::HEX])
            elsif HiddenPower.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::HIDDENPOWER])
            elsif WeatherBall.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::WEATHERBALL])
            elsif TechnoBlast.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::TECHNOBLAST])
            elsif MultiAttack.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::MULTIATTACK])
            elsif JUDGMENT.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::JUDGMENT])
            else
              @moveAcc.store(move, -1)
            end
          end
        end
    end
  end

  def randomizeMoveBP(exclusions = @settings.moveexclusions)
    @moveBP = Hash.new
    case @settings.movepowgen
      when "shuffle"
        for move in 0..PBMoves.maxValue
          if !exclusions.include?(move) && $cache.pkmn_move[move][PBMoveData::BASEDAMAGE] > 1
            sample = @BasePowers.keys.sample
            @moveBP.store(move, sample)
            @BasePowers[sample] -= 1
            @BasePowers.delete(sample) if @BasePowers[sample] == 0
          else  
            if move == PBMoves::FUTUREDUMMY
              @moveBP.store(move, @moveBP[PBMoves::FUTURESIGHT])
            elsif move == PBMoves::DOOMDUMMY
              @moveBP.store(move, @moveBP[PBMoves::DOOMDESIRE])
            #elsif move == PBMoves::HEXDUMMY
            #  @moveBP.store(move, @moveBP[PBMoves::HEX])
            elsif HiddenPower.include?(move)
              @moveBP.store(move, @moveBP[PBMoves::HIDDENPOWER])
            elsif WeatherBall.include?(move)
              @moveBP.store(move, @moveBP[PBMoves::WEATHERBALL])
            elsif TechnoBlast.include?(move)
              @moveBP.store(move, @moveBP[PBMoves::TECHNOBLAST])
            elsif MultiAttack.include?(move)
              @moveBP.store(move, @moveBP[PBMoves::MULTIATTACK])
            elsif JUDGMENT.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::JUDGMENT])
            else
              @moveBP.store(move, -1)
            end
          end
        end
      when "dist"
        bpValueAry = Array.new
        for key in @BasePowers.keys
          bpValueAry.push(@BasePowers[key])
        end
        bpValueAry.sort!
        bpValueSums = Array.new
        bpValueSums[0] = deep_copy(bpValueAry[0])
        for i in 1...bpValueAry.length
          bpValueSums.push(bpValueAry[i] + bpValueSums[i - 1])
        end
        invertedBP = @BasePowers.invert
        for move in 0..PBMoves.maxValue
          if !exclusions.include?(move) && $cache.pkmn_move[move][PBMoveData::BASEDAMAGE] > 1
            temp = rand(bpValueAry.sum)
            for value in 0...bpValueSums.length
              if temp <= bpValueSums[value]
                @moveBP.store(move, invertedBP[bpValueAry[value]])
                break
              end
            end
          else
            if move == PBMoves::FUTUREDUMMY
              @moveBP.store(move, @moveBP[PBMoves::FUTURESIGHT])
            elsif move == PBMoves::DOOMDUMMY
              @moveBP.store(move, @moveBP[PBMoves::DOOMDESIRE])
            #elsif move == PBMoves::HEXDUMMY
            #  @moveBP.store(move, @moveBP[PBMoves::HEX])
            elsif HiddenPower.include?(move)
              @moveBP.store(move, @moveBP[PBMoves::HIDDENPOWER])
            elsif WeatherBall.include?(move)
              @moveBP.store(move, @moveBP[PBMoves::WEATHERBALL])
            elsif TechnoBlast.include?(move)
              @moveBP.store(move, @moveBP[PBMoves::TECHNOBLAST])
            elsif MultiAttack.include?(move)
              @moveBP.store(move, @moveBP[PBMoves::MULTIATTACK])
            elsif JUDGMENT.include?(move)
              @moveAcc.store(move, @moveAcc[PBMoves::JUDGMENT])
            else
              @moveBP.store(move, -1)
            end
          end
        end

      when "chaos"
        bpKeys = @BasePowers.keys
        for move in 0..PBMoves.maxValue
          if !exclusions.include?(move) && $cache.pkmn_move[move][PBMoveData::BASEDAMAGE] > 1
            @moveBP.store(move, bpKeys.sample)
          else
            @moveBP.store(move, -1)
          end
        end
    end
  end

  #gotta hardcode to avoid gen 8
  def randomizeMons(exclusions=@settings.monexclusions)
    #If gen 8 dex is in Reborn, change below to 807 rather than .maxValue
    @pokemon = shuffleArray(PBSpecies.maxValue,exclusions)
  end

  def randomizeAbilities(exclusions=@settings.abilexclusions)
    @abilities = shuffleArray(PBAbilities.maxValue,exclusions)
  end

  def randomizeMoves(exclusions=@settings.moveexclusions)
    @moves = shuffleArray(PBMoves.maxValue,exclusions)
  end

  def randomizeItems(exclusions=@settings.itemexclusions)
    @items = shuffleArray(PBItems.maxValue,exclusions)
  end

  def randomizeForms(exclusions=@settings.formexclusions)
    @forms = shuffleArray(length,exclusions)
  end

  def randomizeTypes(exclusions=@settings.typeexclusions)
    @types = shuffleArray(PBTypes.maxValue,exclusions)
  end

  #Randomizes the typechart based on an effectiveness distribution.
  #Not one-to-one by default
  def randomizeTypeChart(exclusions=[])
    chart = Array.new(19) {|index| Array.new(19)}
    nEffective = TypeEffectivenessDist[0]
    nvEffective = nEffective + TypeEffectivenessDist[1]
    sEffective = nvEffective + TypeEffectivenessDist[2]
    case @settings.typeeffgen
    when 'shuffle'
      values = []
      for i in 0...324
        if i < nEffective
          values[i] = 0
        elsif i < nvEffective
          values[i] = 1
        elsif i < sEffective
          values[i] = 4
        else 
          values[i] = 2
        end
      end
      for i in 0..18
        for j in 0..18
          if exclusions.include?(i) || exclusions.include?(j)
            chart[i][j] = 2
          else
            number = rand(values.length)
            chart[i][j] = values[number]
            values.delete(number)
          end
        end
      end
    when 'dist'
      for i in 0..18
        for j in 0..18
          random = rand(324)
          if random < nEffective
            chart[i][j] = 0
          elsif random < nvEffective
            chart[i][j] = 1
          elsif random < sEffective
            chart[i][j] = 4
          else  #normal effectiveness
            chart[i][j] = 2
          end
          chart[i][j] = 2 if exclusions.include?(i) || exclusions.include?(j)
        end
      end
    when 'chaos'
      eff = [0,1,2,4]
      for i in 0..18
        for j in 0..18
          random = rand(3)
          chart[i][j] = eff[random]
          chart[i][j] = 2 if exclusions.include?(i) || exclusions.include?(j)
        end
      end
    end
    @typechart = chart
  end

  def shuffleArray(length,exclusions=[])
    values = (0..length).to_a
    values -= exclusions
    values.shuffle!
    exclusions.each {|i| values.insert(i,i)} if !exclusions.empty?
    return values
  end

  def expandArray(array) #take a 1D array and make it 2D for math purposes
    bigarray = Array.new(array.length){Array.new(array.length)}
    for i in 0...array.length
      bigarray[i][array[i]] = 1
    end
    return bigarray
  end

  def buildRandomizer
    #$cache.pkmn_dex is 807 length arr of \/
    #[0,0,0,0,0,[0,0,0,0,0,0],0,0,0,0,0,[0,0,0,0,0,0],[0,0],[0,0],0,0,0,0,0,0,0,0]
    #[0,1,2,3,4,5[5],6,7,8,9,10,11[5],12[2],13[2],14,15,16,17[0-4],18,19,20,21]
    #[ID,Color,Habitat,Type1,Type2,BST,CatchRate,GenderFormula,BaseHappiness,EXPCurve,Eggsteps,EVYield,Abilities,BreedingType,Height,Weight,BaseEXPYield,HiddenAbilities,ItemCommon,ItemUncommon,ItemRare,???]

    Dir.mkdir("RandData") unless Dir.exists?("RandData")
    Dir.mkdir("RandData/#{@settings.name}") unless Dir.exists?("RandData/#{@settings.name}")

    @random_dex = deep_copy($cache.pkmn_dex)
    @random_movedata = deep_copy($cache.pkmn_move)


    if @settings.selfabil || @settings.oppabil
      #randomize the abilities in place if abilities are randomized
      if !@settings.abilchaos
        for mon in 1..807 #hard coded to avoid gen 8
          @random_dex[mon][:Abilities][0] = @abilities[@random_dex[mon][:Abilities][0]] if @random_dex[mon][:Abilities][0] != nil
          @random_dex[mon][:Abilities][1] = @abilities[@random_dex[mon][:Abilities][1]] if @random_dex[mon][:Abilities][1] != nil
          @random_dex[mon][:HiddenAbilities] = @abilities[@random_dex[mon][:HiddenAbilities]] if @random_dex[mon][:HiddenAbilities] != nil
        end
      else #chaos. just put in a random number. ignore exclusions.
        for mon in 1..807
          abilityholder = randExclusions(3,@abilities,@settings.abilexclusions)
          @random_dex[mon][:Abilities][0] = abilityholder[0]
          @random_dex[mon][:Abilities][1] = abilityholder[1]
          @random_dex[mon][:HiddenAbilities] = abilityholder[2]
        end
      end
      save_data(@random_dex, "RandData/#{@settings.name}/dexdata.dat")
    end

    if @settings.selftype || @settings.opptype
      if !settings.typechaos
        for mon in 1..807
          @random_dex[mon][:Type1] = @types[@random_dex[mon][:Type1]]
          @random_dex[mon][:Type2] = @types[@random_dex[mon][:Type2]]
        end
      else
        for mon in 1..807
          typeholder = randExclusions(2,@types,@settings.typeexclusions)
          @random_dex[mon][:Type1] = typeholder[0]
          @random_dex[mon][:Type2] = typeholder[1]
        end
      end
      save_data(@random_dex, "RandData/#{@settings.name}/dexdata.dat")
    end


    if @settings.movetype || @settings.moveacc || @settings.movepow
      for move in 0...$cache.pkmn_move.length
        if @settings.movetype
          randType = rand(0...18)
          randType+=1 if randType >= 9 #QMARKS
          @random_movedata[move][PBMoveData::TYPE] = randType
        end
        if @settings.moveacc
          @random_movedata[move][PBMoveData::ACCURACY] = @moveAcc[move] if @moveAcc[move] != -1
        end
        if @settings.movepow
          @random_movedata[move][PBMoveData::BASEDAMAGE] = @moveBP[move] if @moveBP[move] != -1
        end
      end
      save_data(@random_movedata, "RandData/#{@settings.name}/moves.dat")
    end


    if @settings.selfmove || @settings.oppmove
      if !settings.movechaos
        @pkmn_moves = Array.new
        @pkmn_moves.push(nil)
        for poke in 1..PBSpecies.maxValue
          @pkmn_moves.push(Array.new)
          for move in 0...$cache.pkmn_moves[poke].length
            @pkmn_moves[poke].push([$cache.pkmn_moves[poke][move][0], @moves[$cache.pkmn_moves[poke][move][1]]])
          end
        end
      else
        @pkmn_moves = Array.new
        @pkmn_moves.push(nil)
        for poke in 1..PBSpecies.maxValue
          @pkmn_moves.push(Array.new)
          for move in 0...$cache.pkmn_moves[poke].length
            randommove = rand(1..PBMoves.maxValue)
            while @settings.moveexclusions.include?(randommove)
              randommove = rand(1..PBMoves.maxValue)
            end
            @pkmn_moves[poke].push([$cache.pkmn_moves[poke][move][0], randommove])
          end
        end
      end
      save_data(@pkmn_moves,"RandData/#{@settings.name}/attacksRS.dat")

    end

    moncode = "class RandPokemon"
    moncode += "\ndef self.selfmon\nreturn #{@settings.selfmon}\nend"
    moncode += "\ndef self.selfmove\nreturn #{@settings.selfmove}\nend"
    moncode += "\ndef self.selfabil\nreturn #{@settings.selfabil}\nend"
    moncode += "\ndef self.selftype\nreturn #{@settings.selftype}\nend"

    if @settings.selfmon || @settings.oppmon
      moncode += "\ndef self.chaos\nreturn #{@settings.monchaos}\nend"
      moncode += "\ndef self.form\nreturn #{@settings.selfform}\nend"
      moncode += "\ndef self.data"
      moncode += "\nreturn {"
      for poke in 0..PBSpecies.maxValue
        moncode += "\n#{poke} => #{@pokemon[poke]},"
      end
      moncode += "\n}\nend"
    end
    moncode += "\nend"
    eval(moncode)
    File.open("RandData/#{@settings.name}/pokemon.rb","w") {|f| f.write(moncode) }

    
    if @settings.selfitem
      itemcode = "class RandItems"
      itemcode += "\ndef self.chaos\nreturn #{@settings.itemchaos}\nend"
      itemcode += "\ndef self.data"
      itemcode += "\nreturn {"
      for item in 0..PBItems.maxValue
        if !pbIsImportantItem?(item)
          itemcode += "\n#{item} => #{@items[item]},"
        else
          itemcode += "\n#{item} => #{item},"
        end
      end
      itemcode += "\n}\nend\nend"
      eval(itemcode)
      File.open("RandData/#{@settings.name}/items.rb","w") {|f| f.write(itemcode) }
    end


    splitTrainercode = "class SplitTrainers"
    splitTrainercode += "\ndef self.species\nreturn #{@settings.oppmon}\nend"
    splitTrainercode += "\ndef self.moves\nreturn #{@settings.oppmove}\nend"
    splitTrainercode += "\ndef self.abilities\nreturn #{@settings.oppabil}\nend"
    splitTrainercode += "\ndef self.types\nreturn #{@settings.opptype}\nend"
    #splitTrainercode += "def self.forms\nreturn #{@settings.oppform}\nend"
    #splitTrainercode += "def self.items\nreturn #{@settings.oppitem}\nend"
    splitTrainercode += "\nend"
    eval(splitTrainercode)
    File.open("RandData/#{@settings.name}/SplitTrainers.rb","w") {|f| f.write(splitTrainercode) }


    #move and item generation could be done at any time; abilities, types, and mons MUST be done in this order
    #itemchaos activates when the item is pulled.
=begin   
    if !@settings.itemchaos
      #organize data for whose items get randomized
      randommons = [@settings.selfitem,@settings.oppitem]
      case randommons
      when true,true #everyone is randomized, this is easy
        for i in 0...$cache.items.length
          random_items[i] = $cache.items[@items[i]]
        end
        save_data(random_items,"RandData/#{@settings.name}/items.dat")
      when true,false #opp not randomized; de-randomize trainers
        for i in 0...$cache.items.length
          random_items[i] = $cache.items[@items[i]]
        end
        save_data(random_items,"RandData/#{@settings.name}/items.dat")
        bigarray = expandArray(@items)
        derand = @items*bigarray.transpose
        for trainer in derandom_trainers
          for mon in trainer[0]
            mon[TPITEM] = derand[mon[TPITEM]]
          end
        end
        savetrainers = true
      when false,true #randomize trainers only
        for trainer in derandom_trainers
          for mon in trainer[0]
            mon[TPITEM] = @items[mon[TPITEM]]
          end
          for item in trainer[1]
            item = @items[item]
          end
        end
        savetrainers = true
      end
    end
=end
    #I know the 0,0 in front is dumb but essentials does it and i have no power over that
    save_data(@typechart,"RandData/#{@settings.name}/types.dat") if @settings.typeeff
    $game_variables[:Randomized_Other] = Array.new()
    $game_variables[:Randomized_Other][RandOtherVars[:typestorage]] = true if @settings.typestore
    $game_variables[:Randomized_Other][RandOtherVars[:abilstorage]] = true if @settings.abilstore
    $game_variables[:Randomized_Other][RandOtherVars[:movestorage]] = true if @settings.movestore
    
    #if trainers are randomized, save them
    #save_data(derandom_trainers,"RandData/#{@settings.name}/trainers.dat") if savetrainers
  end
  
  def randExclusions(elements,source,exclusions=[])
    randarray = []
    for i in 0...elements
      randval = -1
      while randval == -1 || exclusions.include?(randval)
        randval = source[rand(source.length)]
      end
      randarray.push(randval)
    end
    return randarray
  end
end

def setRandomizerData(foldername)
  path = "RandData/#{foldername}/"
  filesFound = false
  if !Dir.exists?(path)
    Kernel.pbMessage("This folder does not exist. Ensure you spelled the folder name correctly.")
    return false
  else
    Dir.each_child(path) {|file|
      if File.file?(path + file)
        filesFound = true
        break
      end
    } 
    if !filesFound
      Kernel.pbMessage("There are no files in this folder. Ensure you spelled the folder name correctly.")
      return false
    else
      Dir.each_child(path) {|file|
        case file
          when "dexdata.dat"
            $random_dex = load_data(path + file)
          when "pokemon.rb"
            $game_variables[:Randomized_Pokemon] = 1
            File.open(path + file){|f|
              eval(f.read())
              if !defined?(RandPokemon.selfmon)
                moncode = "class RandPokemon"
                moncode += "\ndef self.selfmon\nreturn true\nend"
                moncode += "\ndef self.selfmove\nreturn true\nend"
                moncode += "\ndef self.selfabil\nreturn true\nend"
                moncode += "\ndef self.selftype\nreturn true\nend"
                moncode += "\nend"
                eval(moncode)
              end
            }
          when "items.rb"
            File.open(path + file){|f|
              eval(f.read())
            }
          when "types.dat"
            $random_typeChart = load_data(path + file)
          when "attacksRS.dat"
            $random_moveset = load_data(path + file)
          when "moves.dat"
            $random_movedata = load_data(path + file)
          when "SplitTrainers.rb"
            file.open(path + file){|f| eval(f.read()) }
        end
      }
    end
  end
  return true

end



class PokeBattle_Pokemon
  attr_accessor :randomizePokemonData
  PokemonFlagHash = {
    :fromTrainer => 0,
    :species => 1,
    :abilities => 2,
    :types => 3,
    :moves => 4,
    :form => 5
  }

  attr_accessor :typeStorage
  attr_accessor :abilityStorage
  attr_accessor :moveStorage

  alias __rc_ability ability
  alias __rc_type1 type1
  alias __rc_type2 type2
  alias __rc_initialize initialize
  alias __rc_getAbilityList getAbilityList
  alias __rc_getMoveList getMoveList

  def ability
    if $random_dex != nil
      if @randomizePokemonData == nil
        @randomizePokemonData = Array.new
      end
      if @randomizePokemonData[PokemonFlagHash[:fromTrainer]] && !@randomizePokemonData[PokemonFlagHash[:abilities]]
        return self.__rc_ability 
      end
      if defined?(RandPokemon.selfabil) && !@randomizePokemonData[PokemonFlagHash[:fromTrainer]]
        return self.__rc_ability if !RandPokemon.selfabil
      end
      abil=abilityIndex
      ret1=$random_dex[@species][:Abilities][0]
      ret2=$random_dex[@species][:Abilities][1]
      h1=$random_dex[@species][:HiddenAbilities]
      if @abilityStorage != nil
        abilarr = [ret1,ret2,h1]
        for i in 0...self.abilityStorage[1].length
          abilarr.push(self.abilityStorage[1][i])
        end
        chosenabil = abilarr[abil]
      else
        chosenabil = [ret1,ret2,h1][abil]
      end
      return chosenabil if chosenabil && chosenabil > 0
      return ret1
    end
    return self.__rc_ability
  end
  
  def getAbilityList
    if $random_dex != nil
      if @randomizePokemonData[PokemonFlagHash[:fromTrainer]] && !@randomizePokemonData[PokemonFlagHash[:abilities]]
        return self.__rc_getAbilityList 
      end
      if defined?(RandPokemon.selfabil)  && !@randomizePokemonData[PokemonFlagHash[:fromTrainer]]
        return self.__rc_getAbilityList if !RandPokemon.selfabil
      end
      abils=[]
      ret = {}

      abils.push($random_dex[@species][:Abilities][0])
      abils.push($random_dex[@species][:Abilities][1])
      abils.push($random_dex[@species][:HiddenAbilities])
      
      if @form != 0
        v = PokemonForms.dig(@species,getFormName,:Ability)
        v = [v] if abils!=nil && !abils.is_a?(Array)
        abils = v if v.is_a?(Array)
      end
      if @abilityStorage != nil
        if @abilityStorage[0] && @abilityStorage[1] != nil
          for abil in 0...@abilityStorage[1].length
            abils.push(@abilityStorage[1][abil])
          end
        end
      end
      
      for i in 0...abils.length
        next if !abils[i] || abils[i]<=0
        ret[i] = abils[i]
      end
      return ret 
    end
    return self.__rc_getAbilityList
  end

  def type1
    if $random_dex != nil
      if @randomizePokemonData == nil
        @randomizePokemonData = Array.new
      end
      if @randomizePokemonData[PokemonFlagHash[:fromTrainer]] && !@randomizePokemonData[PokemonFlagHash[:types]]
        return self.__rc_type1 
      end
      if defined?(RandPokemon.selftype) && !@randomizePokemonData[PokemonFlagHash[:fromTrainer]]
        return self.__rc_type1 if !RandPokemon.selftype
      end
      if @species == PBSpecies::SILVALLY || @species == PBSpecies::ARCEUS
        ret = @form%19 
      else
        ret = $random_dex[@species][:Type1]
      end
      if @typeStorage != nil
        ret = @typeStorage[1][0] if @typeStorage[0] && @typeStorage[1][0] != nil
      end
      return ret
    end
    return self.__rc_type1
  end

  def type2
    if $random_dex != nil
      if @randomizePokemonData == nil
        @randomizePokemonData = Array.new
      end
      if @randomizePokemonData[PokemonFlagHash[:fromTrainer]] && !@randomizePokemonData[PokemonFlagHash[:types]]
        return self.__rc_type2 
      end
      if defined?(RandPokemon.selftype) && !@randomizePokemonData[PokemonFlagHash[:fromTrainer]]
        return self.__rc_type2 if !RandPokemon.selftype
      end
      if @species == PBSpecies::SILVALLY || @species == PBSpecies::ARCEUS
        ret = @form%19
      else 
        ret = $random_dex[@species][:Type2]
      end
      if @typeStorage != nil
        ret = @typeStorage[1][1] if @typeStorage[0] && @typeStorage[1][1] != nil
      end
      return ret
    end
    return self.__rc_type2
  end

  def initialize(species, level, player = nil, withMoves = true, fromTrainer = false)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    @randomizePokemonData = Array.new
    
    if fromTrainer
      if defined?(SplitTrainers)
        @randomizePokemonData[PokemonFlagHash[:fromTrainer]] = true
        @randomizePokemonData[PokemonFlagHash[:species]] = SplitTrainers.species
        @randomizePokemonData[PokemonFlagHash[:moves]] = SplitTrainers.moves
        @randomizePokemonData[PokemonFlagHash[:abilities]] = SplitTrainers.abilities
        @randomizePokemonData[PokemonFlagHash[:types]] = SplitTrainers.types
        #@randomizePokemonData[PokemonFlagHash[:form]] = SplitTrainers.form
      end
      if @randomizePokemonData[PokemonFlagHash[:species]] 
        if defined?(RandPokemon) 
          if RandPokemon.chaos
            species = rand(1..807)
          else
            if RandPokemon.data != nil
              species = RandPokemon.data[species]
            end
          end
        end
      end
      self.__rc_initialize(species, level, player, withMoves)
      if withMoves && $random_moveset != nil && @randomizePokemonData[PokemonFlagHash[:moves]]
        # Generating move list
        movelist=[]
        for k in 0...$random_moveset[species].length
          alevel=$random_moveset[species][k][0]
          move=$random_moveset[species][k][1]
          if alevel<=level
            movelist[k]=move
          end
        end
        movelist.reverse!
        movelist.uniq!
        movelist = movelist[0,4]
        movelist.reverse!
        # Use the first 4 items in the move list
        for i in 0...4
          moveid=(i>=movelist.length) ? 0 : movelist[i]
          @moves[i]=PBMove.new(moveid)
        end
      end
      #if @randomizePokemonData[PokemonFlagHash[:form]]
        #@form = 
        #self.resetMoves
      #end
      return
    end


    if $game_switches[:Randomized_Challenge] && defined?(RandPokemon)
      if RandPokemon.selfmon
        if RandPokemon.chaos
          species = rand(1..807)
        else
          if RandPokemon.data != nil
            species = RandPokemon.data[species]
          end
        end
      end
    end
    self.__rc_initialize(species, level, player, withMoves)

    if withMoves && $random_moveset != nil
      if defined?(RandPokemon.selfmove)
        if RandPokemon.selfmove
      # Generating move list
          movelist=[]
          for k in 0...$random_moveset[species].length
            alevel=$random_moveset[species][k][0]
            move=$random_moveset[species][k][1]
            if alevel<=level
              movelist[k]=move
            end
          end
          movelist.reverse!
          movelist.uniq!
          movelist = movelist[0,4]
          movelist.reverse!
          # Use the first 4 items in the move list
          for i in 0...4
            moveid=(i>=movelist.length) ? 0 : movelist[i]
            @moves[i]=PBMove.new(moveid)
          end
        end
      end
    end
    #if @randomizePokemonData[PokemonFlagHash[:form]]
      #@form = 
      #self.resetMoves
    #end
    if $game_variables[:Randomized_Other][RandOtherVars[:typestorage]]
      @typeStorage = Array.new()
      @typeStorage[0] = true
      @typeStorage[1] = Array.new()
    end
    if $game_variables[:Randomized_Other][RandOtherVars[:abilstorage]]
      @abilityStorage = Array.new()
      @abilityStorage[0] = true 
      @abilityStorage[1] = Array.new()
    end
    if $game_variables[:Randomized_Other][RandOtherVars[:movestorage]]
      @moveStorage = Array.new()
      @moveStorage[0] = true 
      @moveStorage[1] = Array.new()
    end
  end
  
  def getMoveList
    if $random_moveset != nil
      if @randomizePokemonData == nil
        @randomizePokemonData = Array.new
      end
      if @randomizePokemonData[PokemonFlagHash[:fromTrainer]] && !@randomizePokemonData[PokemonFlagHash[:moves]]
        return self.__rc_getMoveList 
      end
      if defined?(RandPokemon.selfmon) && !@randomizePokemonData[PokemonFlagHash[:fromTrainer]]
        return self.__rc_getMoveList if !RandPokemon.selfmove
      end
      movelist=[]
      for k in 0...$random_moveset[@species].length
        movelist.push([$random_moveset[@species][k][0],$random_moveset[@species][k][1]])
      end
      ret = movelist
      if @moveStorage != nil
        if @moveStorage[0] && @moveStorage[1] != nil
          for move in 0...@moveStorage[1].length
            ret.push([1, @moveStorage[1][move]])
          end
        end
      end
      return ret
    end
    return self.__rc_getMoveList
  end
end

def pbLoadTrainer(trainerid,trainername,partyid=0)
  begin
    if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
      if !hasConst?(PBTrainers,trainerid)
        raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
      end
      trainerid=getID(PBTrainers,trainerid)
    end
    success=false
    items=[]
    party=[]
    opponent=nil
    trainerarray = $cache.trainers[trainerid]
    trainer = trainerarray.dig(trainername,partyid)
    items=trainer[1]
    name=pbGetMessageFromHash(MessageTypes::TrainerNames,trainername)
    opponent=PokeBattle_Trainer.new(name,trainerid)
    opponent.setForeignID($Trainer) if $Trainer
    for poke in trainer[0]
      species=poke[TPSPECIES]
      level=poke[TPLEVEL]
      pokemon=PokeBattle_Pokemon.new(species,level,opponent,true,true) #added a flag to specify from a trainer'
      pokemon.form=poke[TPFORM]
      pokemon.resetMoves 
      pokemon.setItem(poke[TPITEM])
      if poke[TPMOVE1]>0 || poke[TPMOVE2]>0 || poke[TPMOVE3]>0 || poke[TPMOVE4]>0
        k=0
        for move in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
          pokemon.moves[k]=PBMove.new(poke[move]) if !pokemon.randomizePokemonData[4] #moves
          if level >=100 && opponent.skill>=PokeBattle_AI::BESTSKILL
            pokemon.moves[k].ppup=3
            pokemon.moves[k].pp=pokemon.moves[k].totalpp
          end
          k+=1
        end
        pokemon.moves.compact!
      end
      
      pokemon.setAbility(poke[TPABILITY]) if !pokemon.randomizePokemonData[2]
      pokemon.setGender(poke[TPGENDER])
      if poke[TPSHINY]   # if this is a shiny Pokémon
        pokemon.makeShiny
      else
        pokemon.makeNotShiny
      end
      pokemon.setNature(poke[TPNATURE])
      iv=poke[TPIV]
      if iv==32 # Trick room IVS
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
      evsum = poke[TPHPEV]+poke[TPATKEV]+poke[TPDEFEV]+poke[TPSPEEV]+poke[TPSPAEV]+poke[TPSPDEV]
      #if evsum<=510 && evsum>0
      if evsum>0 # What is an EV cap? PULSE2 away tbh
        pokemon.ev=[poke[TPHPEV], poke[TPATKEV], poke[TPDEFEV], poke[TPSPEEV], poke[TPSPAEV], poke[TPSPDEV]]
      elsif evsum == 0
        for i in 0...6
          pokemon.ev[i]=[85,level*3/2].min
        end
      end
      if $game_switches[:Only_Pulse_2] == true && ($game_switches[:Grinding_Trainer_Money_Cut] == false || $game_switches[:Penniless_Mode] == true) # pulse 2 mode
        for i in 0...6
          pokemon.ev[i]=252 if pokemon.ev[i] < 252
        end
        pokemon.ev[3] = 0 if iv == 32 # speed, right...?
        for i in 0...6
          pokemon.iv[i]=31 if iv != 32
        end
      end
      
      if $game_switches[:Empty_IVs_And_EVs_Password] == true
        for i in 0...6
          pokemon.ev[i]=0
          pokemon.iv[i]=0
        end
      end
      pokemon.ev=[85,85,85,85,85,85] if $game_switches[:Flat_EV_Password]
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
    success=true
  rescue
    print "Team could not be loaded, please report this: #{trainerid}, #{trainername}, #{partyid} \n ty <3"
  end
  return success ? [opponent,items,party] : nil
end

def pbCheckEvolutionEx(pokemon)
  return -1 if pokemon.species<=0 || pokemon.isEgg?
  return -1 if pokemon.item == PBItems::EVERSTONE
  return -1 if pokemon.item == PBItems::EVIOLITE
  return -1 if pokemon.item == PBItems::EEVIUMZ2
  ret=-1
  for form in pbGetEvolvedFormData(pokemon.species,pokemon)
    ret=yield pokemon,form[1],form[2],form[0]
    break if ret>0
  end
  if ret >= 0 && $game_switches[:Randomized_Challenge]
    if $game_variables[:Randomized_Other][RandOtherVars[:typestorage]]
      pokemon.typeStorage[1] = [pokemon.type1, pokemon.type2]
    end
    if $game_variables[:Randomized_Other][RandOtherVars[:abilstorage]]
      abilarr = pokemon.getAbilityList.values
      for i in 0..2
        pokemon.abilityStorage[1].push(abilarr[i])
      end
      if pokemon.abilityflag.is_a?(Integer) 
        pokemon.setAbility((pokemon.personalID % 3) + pokemon.abilityStorage[1].length) if pokemon.abilityflag < 3
      else
        pokemon.setAbility((pokemon.personalID % 3) + pokemon.abilityStorage[1].length)
      end

    end
    if $game_variables[:Randomized_Other][RandOtherVars[:movestorage]]
      movearr = pokemon.getMoveList
      for i in 0...movearr.length
        pokemon.moveStorage[1].push(movearr[i][1])
      end
    end
  end
  return ret
end

class PokeBattle_Move
  alias __rc_initialize initialize
  def initialize(*args)
    self.__rc_initialize(*args)
    if $random_movedata != nil
      return if args[0] == 0
      #if args[2].fromTrainer
      #  return if @randomizePokemonData[PokemonFlagHash[:moves]]
      #else
      #  if defined?(RandPokemon.selfmove)
      #    return if RandPokemon.selfmove 
      #  end
      #end
      @basedamage  = $random_movedata[@id][PBMoveData::BASEDAMAGE]
      @type        = $random_movedata[@id][PBMoveData::TYPE]
      @accuracy    = $random_movedata[@id][PBMoveData::ACCURACY]
    end
  end
end

class PBMove
  alias __rc_type type
  alias __rc_basedamage basedamage

  def type
    if $random_movedata != nil
      return $random_movedata[@id][PBMoveData::TYPE]
    end
    return self.__rc_type
  end

  def basedamage
    if $random_movedata != nil
      return $random_movedata[@id][PBMoveData::BASEDAMAGE]
    end
    return self.__rc_basedamage
  end
end

class PBMoveData
  alias __rc_initialize initialize
  
  def initialize(*args)
    __rc_initialize(*args)
    if $random_movedata != nil
      return if args[0] == 0
      #if args[2].fromTrainer
      #  return if @randomizePokemonData[PokemonFlagHash[:moves]]
      #else
      #  if defined?(RandPokemon.selfmove)
      #    return if RandPokemon.selfmove 
      #  end
      #end
      @basedamage  = $random_movedata[args[0]][PBMoveData::BASEDAMAGE]
      @type        = $random_movedata[args[0]][PBMoveData::TYPE]
      @accuracy    = $random_movedata[args[0]][PBMoveData::ACCURACY]
    end
  end
end


class PBTypes
  @@TypesRandomized = false
  def PBTypes.loadTypeData # internal
    if !@@TypeData
      @@TypeData=load_data("Data/types.dat")
      @@TypeData[0].freeze
      @@TypeData[1].freeze
      @@TypeData[2].freeze
      @@TypeData.freeze
    end
    if !@@TypesRandomized
      if $random_typeChart != nil
        @@TypeData=load_data("Data/types.dat")
        @@TypeData[0].freeze
        @@TypeData[1].freeze
        @@TypeData[2] = $random_typeChart
        @@TypeData[2].freeze
        @@TypeData.freeze
        @@TypesRandomized = true
      end
    end
    return @@TypeData
  end
end

def printRandomizedStarter(species)
  if RandPokemon.selfmon
    name = PBSpecies.getName(RandPokemon.data[species])
    kind = pbGetMessage(MessageTypes::Kinds, RandPokemon.data[species])
  else
    name = PBSpecies.getName(species)
    kind = pbGetMessage(MessageTypes::Kinds, species)
  end
  Kernel.pbMessage("AME: So, you want #{name}, the #{kind} Pokémon?")
end

def Kernel.pbItemBall(item,quantity=1,plural=nil)
  if item.is_a?(String) || item.is_a?(Symbol)
    item=getID(PBItems,item)
  end
  if $game_switches[:Randomized_Challenge] && !pbIsImportantItem?(item) && defined?(RandItems)
    if RandItems.chaos
      item = rand(1...PBItems.maxValue)
      while $cache.items[item] == nil
        item = rand(1...PBItems.maxValue)
      end
    else
      if RandItems.data != nil
        item = RandItems.data[item]
      end
    end
  end
  return false if !item || item<=0 || quantity<1
  itemname=PBItems.getName(item)
  pocket=pbGetPocket(item)
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be picked up
    if $cache.items[item][ITEMUSE]==3 || $cache.items[item][ITEMUSE]==4
      Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found \\c[1]{2}\\c[0]!\\nIt contained \\c[1]{3}\\c[0].\\wtnp[30]",
         $Trainer.name,itemname,PBMoves.getName($cache.items[item][ITEMMACHINE])))
      Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
         $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
    elsif (item == PBItems::LEFTOVERS)
      Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found some \\c[1]{2}\\c[0]!\\wtnp[30]",
         $Trainer.name,itemname))
      Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
         $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
    else
      if quantity>1
        if plural
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2} \\c[1]{3}\\c[0]!\\wtnp[30]",
             $Trainer.name,quantity,plural))
          Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
             $Trainer.name,plural,PokemonBag.pocketNames()[pocket]))
        else
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2} \\c[1]{3}s\\c[0]!\\wtnp[30]",
             $Trainer.name,quantity,itemname))
          Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}s\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
             $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
        end
      else
        Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found one \\c[1]{2}\\c[0]!\\wtnp[30]",
           $Trainer.name,itemname))
        Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
           $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
      end
    end
    return true
  else   # Can't add the item
    if $cache.items[item][ITEMUSE]==3 || $cache.items[item][ITEMUSE]==4
      Kernel.pbMessage(_INTL("{1} found \\c[1]{2}\\c[0]!\\wtnp[20]",
         $Trainer.name,itemname))
    elsif (item == PBItems::LEFTOVERS)
      Kernel.pbMessage(_INTL("{1} found some \\c[1]{2}\\c[0]!\\wtnp[20]",
         $Trainer.name,itemname))
    else
      if quantity>1
        if plural
          Kernel.pbMessage(_INTL("{1} found {2} \\c[1]{3}\\c[0]!\\wtnp[20]",
             $Trainer.name,quantity,plural))
        else
          Kernel.pbMessage(_INTL("{1} found {2} \\c[1]{3}s\\c[0]!\\wtnp[20]",
             $Trainer.name,quantity,itemname))
        end
      else
        Kernel.pbMessage(_INTL("{1} found one \\c[1]{2}\\c[0]!\\wtnp[20]",
           $Trainer.name,itemname))
      end
    end
    Kernel.pbMessage(_INTL("Too bad... The Bag is full..."))
    return false
  end
end

def Kernel.pbReceiveItem(item,quantity=1,plural=nil)
  if item.is_a?(String) || item.is_a?(Symbol)
    item=getID(PBItems,item)
  end
  if $game_switches[:Randomized_Challenge] && !pbIsImportantItem?(item) && defined?(RandItems)
    if RandItems.chaos
      item = rand(1...PBItems.maxValue)
      while $cache.items[item] == nil
        item = rand(1...PBItems.maxValue)
      end
    else
      if RandItems.data != nil
        item = RandItems.data[item]
      end
    end
  end
  return false if !item || item<=0 || quantity<1
  itemname=PBItems.getName(item)
  pocket=pbGetPocket(item)
  if $cache.items[item][ITEMUSE]==3 || $cache.items[item][ITEMUSE]==4
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained \\c[1]{1}\\c[0]!\\nIt contained \\c[1]{2}\\c[0].\\wtnp[30]",
       itemname,PBMoves.getName($cache.items[item][ITEMMACHINE])))
  elsif (item == PBItems::LEFTOVERS)
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained some \\c[1]{1}\\c[0]!\\wtnp[30]",
       itemname))
  elsif quantity>1
    if plural
      Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained {2} \\c[1]{1}\\c[0]!\\wtnp[30]",
         plural,quantity))
    else
      Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained {2} \\c[1]{1}s\\c[0]!\\wtnp[30]",
         itemname,quantity))
    end
  else
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained \\c[1]{1}\\c[0]!\\wtnp[30]",
       itemname))
  end
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be added
    if quantity>1
      if plural
        Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
           $Trainer.name,plural,PokemonBag.pocketNames()[pocket]))
      else
        Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}s\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
           $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
      end
    else
      Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
         $Trainer.name,itemname,PokemonBag.pocketNames()[pocket]))
    end
    return true
  else   # Can't add the item
    return false
  end
end