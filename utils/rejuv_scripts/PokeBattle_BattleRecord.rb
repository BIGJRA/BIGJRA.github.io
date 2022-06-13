module PokeBattle_RecordedBattleModule
  attr_reader :randomnums
  attr_reader :rounds

  module Commands
    Fight=0
    Bag=1
    Pokemon=2
    Run=3
  end

  def initialize(*arg)
    @randomnumbers=[]
    @rounds=[]
    @switches=[]
    @roundindex=-1
    @properties={}
    super(*arg)
  end

  def pbGetBattleType
    return 0 # Battle Tower
  end

  def pbGetTrainerInfo(trainer)
    return nil if !trainer
    if trainer.is_a?(Array)
      return [
         [trainer[0].trainertype,trainer[0].name.clone,trainer[0].id,trainer[0].badges.clone],
         [trainer[1].trainertype,trainer[1].name.clone,trainer[1].id,trainer[0].badges.clone]
      ]
    else
      return [
         [trainer.trainertype,trainer.name.clone,trainer.id,trainer.badges.clone]
      ]
    end
  end

  def pbStartBattle(canlose=false)
    @properties={}
    @properties["internalbattle"]=@internalbattle
    @properties["player"]=pbGetTrainerInfo(@player)
    @properties["opponent"]=pbGetTrainerInfo(@opponent)
    @properties["party1"]=Marshal.dump(@party1)
    @properties["party2"]=Marshal.dump(@party2)
    @properties["endspeech"]=@endspeech ? @endspeech : ""
    @properties["endspeech2"]=@endspeech2 ? @endspeech2 : ""
    @properties["endspeechwin"]=@endspeechwin ? @endspeechwin : ""
    @properties["endspeechwin2"]=@endspeechwin2 ? @endspeechwin2 : ""
    @properties["doublebattle"]=@doublebattle
    @properties["weather"]=@weather
    @properties["weatherduration"]=@weatherduration
    @properties["cantescape"]=@cantescape
    @properties["shiftStyle"]=@shiftStyle
    @properties["battlescene"]=@battlescene
    @properties["items"]=Marshal.dump(@items)
    @properties["environment"]=@environment
    @properties["rules"]=Marshal.dump(@rules)
    super(canlose)
  end

  def pbDumpRecord
    return Marshal.dump([pbGetBattleType,@properties,@rounds,@randomnumbers,@switches])
  end

  def pbSwitchInBetween(i1,i2,i3)
    ret=super
    @switches.push(ret)
    return ret
  end

  def pbRegisterMove(i1,i2,showMessages=true)
    if super
      @rounds[@roundindex][i1]=[Commands::Fight,i2]
      return true
    end
    return false
  end

  def pbRun(i1,duringBattle=false)
    ret=super
    @rounds[@roundindex][i1]=[Commands::Run,@decision]
    return ret
  end

  def pbRegisterTarget(i1,i2)
    ret=super
    @rounds[@roundindex][i1][2]=i2
    return ret
  end

  def pbAutoChooseMove(i1,showMessages=true)
    ret=super(i1,showMessages)
    @rounds[@roundindex][i1]=[Commands::Fight,-1]
    return ret
  end

  def pbRegisterSwitch(i1,i2)
    if super
      @rounds[@roundindex][i1]=[Commands::Pokemon,i2]
      return true
    end
    return false
  end

  def pbRegisterItem(i1,i2)
    if super
      @rounds[@roundindex][i1]=[Commands::Item,i2]
      return true
    end
    return false
  end

  def pbCommandPhase
    @roundindex+=1
    @rounds[@roundindex]=[[],[],[],[]]
    super
  end

  def pbStorePokemon(pkmn)
  end

  def pbRandom(num)
    ret=super(num)
    @randomnumbers.push(ret)
    return ret
  end
end



module BattlePlayerHelper
  def self.pbGetOpponent(battle)
    return self.pbCreateTrainerInfo(battle[1]["opponent"])
  end

  def self.pbGetBattleBGM(battle)
    return self.pbGetTrainerBattleBGM(self.pbGetOpponent(battle))
  end

  def self.pbCreateTrainerInfo(trainer)
    return nil if !trainer
    if trainer.length>1
      ret=[]
      ret[0]=PokeBattle_Trainer.new(trainer[0][1],trainer[0][0])
      ret[0].id=trainer[0][2]
      ret[0].badges=trainer[0][3]
      ret[1]=PokeBattle_Trainer.new(trainer[1][1],trainer[1][0])
      ret[1].id=trainer[1][2]
      ret[1].badges=trainer[1][3]
      return ret
    else
      ret=PokeBattle_Trainer.new(trainer[0][1],trainer[0][0])
      ret.id=trainer[0][2]
      ret.badges=trainer[0][3]
      return ret
    end
  end
end



module PokeBattle_BattlePlayerModule
  module Commands
    Fight=0
    Bag=1
    Pokemon=2
    Run=3
  end

  def initialize(scene,battle)
    @battletype=battle[0]
    @properties=battle[1]
    @rounds=battle[2]
    @randomnums=battle[3]
    @switches=battle[4]
    @roundindex=-1
    @randomindex=0
    @switchindex=0
    super(scene,
       Marshal.restore(StringInput.new(@properties["party1"])),
       Marshal.restore(StringInput.new(@properties["party2"])),
       BattlePlayerHelper.pbCreateTrainerInfo(@properties["player"]),
       BattlePlayerHelper.pbCreateTrainerInfo(@properties["opponent"])
    )
  end

  def pbStartBattle(canlose=false)
    @internalbattle=@properties["internalbattle"]
    @endspeech=@properties["endspeech"]
    @endspeech2=@properties["endspeech2"]
    @endspeechwin=@properties["endspeechwin"]
    @endspeechwin2=@properties["endspeechwin2"]
    @doublebattle=@properties["doublebattle"]
    @weather=@properties["weather"]
    @weatherduration=@properties["weatherduration"]
    @cantescape=@properties["cantescape"]
    @shiftStyle=@properties["shiftStyle"]
    @battlescene=@properties["battlescene"]
    @items=Marshal.restore(StringInput.new(@properties["items"]))
    @rules=Marshal.restore(StringInput.new(@properties["rules"]))
    @environment=@properties["environment"]
    super(canlose)
  end

  def pbSwitchInBetween(i1,i2,i3)
    ret=@switches[@switchindex]
    @switchindex+=1
    return ret
  end

  def pbRandom(num)
    ret=@randomnums[@randomindex]
    @randomindex+=1
    return ret
  end

  def pbDisplayPaused(str)
    pbDisplay(str)
  end

  def pbCommandPhaseCore
    @roundindex+=1
    for i in 0...4
      next if @rounds[@roundindex][i].length==0
      @choices[i][0]=0
      @choices[i][1]=0
      @choices[i][2]=nil
      @choices[i][3]=-1
      case @rounds[@roundindex][i][0]
        when Commands::Fight
          if @rounds[@roundindex][i][1]==-1
            pbAutoChooseMove(i,false)
          else
            pbRegisterMove(i,@rounds[@roundindex][i][1])
          end
          if @rounds[@roundindex][i][2]
            pbRegisterTarget(i,@rounds[@roundindex][i][2])
          end
        when Commands::Pokemon
          pbRegisterSwitch(i,@rounds[@roundindex][i][1])
        when Commands::Bag
          pbRegisterItem(i,@rounds[@roundindex][i][1])
        when Commands::Run
          @decision=@rounds[@roundindex][i][1]
      end
    end
  end
end



class PokeBattle_RecordedBattle < PokeBattle_Battle
  def pbGetBattleType
    return 0
  end
  include PokeBattle_RecordedBattleModule
end



class PokeBattle_RecordedBattlePalace < PokeBattle_BattlePalace
  def pbGetBattleType
    return 1
  end
  include PokeBattle_RecordedBattleModule
end



class PokeBattle_RecordedBattleArena < PokeBattle_BattleArena
  def pbGetBattleType
    return 2
  end
  include PokeBattle_RecordedBattleModule
end



class PokeBattle_BattlePlayer < PokeBattle_Battle
  include PokeBattle_BattlePlayerModule
end



class PokeBattle_BattlePalacePlayer < PokeBattle_BattlePalace
  include PokeBattle_BattlePlayerModule
end



class PokeBattle_BattleArenaPlayer < PokeBattle_BattleArena
  include PokeBattle_BattlePlayerModule
end