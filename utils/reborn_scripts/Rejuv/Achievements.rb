module Achievements
  # IDs determine the order that achievements appear in the menu.
  @achievementList={
    "STEPS"=>{
      "id"=>1,
      "name"=>"Tired Feet",
      "description"=>"Walk around the world.",
      "goals"=>[1000,5000,10000,50000,100000,150000,200000,250000,350000,500000],
      "reward"=>2
    },
    "POKEMON_CAUGHT"=>{
      "id"=>2,
      "name"=>"Gotta Catch 'Em All",
      "description"=>"Catch Pokémon.",
      "goals"=>[100,250,500],
      "reward"=>2
    },
    "WILD_ENCOUNTERS"=>{
      "id"=>3,
      "name"=>"Running in the Tall Grass",
      "description"=>"Encounter Pokémon.",
      "goals"=>[75,150,225],
      "reward"=>2
    },
    "TRAINER_BATTLES"=>{
      "id"=>4,
      "name"=>"Battlin' Every Day",
      "description"=>"Go into Trainer battles.",
      "goals"=>[50,100,150],
      "reward"=>2
    },
    "ITEMS_USED"=>{
      "id"=>5,
      "name"=>"Items Are Handy",
      "description"=>"Use items.",
      "goals"=>[50,100,150],
      "reward"=>2
    },
    "ITEMS_BOUGHT"=>{
      "id"=>6,
      "name"=>"Buying Supplies",
      "description"=>"Buy items.",
      "goals"=>[250,500,1000],
      "reward"=>2
    },
    "ITEMS_SOLD"=>{
      "id"=>7,
      "name"=>"Seller",
      "description"=>"Sell items.",
      "goals"=>[50,100,150],
      "reward"=>2
    },
    "ITEM_BALL_ITEMS"=>{
      "id"=>8,
      "name"=>"Finding Treasure",
      "description"=>"Find items in item balls.",
      "goals"=>[75,150,225],
      "reward"=>2
    },
    "MOVES_USED"=>{
      "id"=>9,
      "name"=>"Ferocious Fighting",
      "description"=>"Use moves in battle.",
      "goals"=>[200,500,800],
      "reward"=>2
    },
    "ITEMS_USED_IN_BATTLE"=>{
      "id"=>10,
      "name"=>"Mid-Battle Maintenance",
      "description"=>"Use items in battle.",
      "goals"=>[50,100,150],
      "reward"=>2
    },
    "SHINY_POKEMON_CAUGHT"=>{
      "id"=>11,
      "name"=>"A Drive to Hunt",
      "description"=>"Catch shiny Pokémon.",
      "goals"=>[1,10,30],
      "reward"=>2
    },
    "EGGS_HATCHED"=>{
      "id"=>12,
      "name"=>"Baby Boomer",
      "description"=>"Hatch eggs.",
      "goals"=>[5,50,100],
      "reward"=>2
    },
    "EVOLVE_POKEMON"=>{
      "id"=>13,
      "name"=>"Fruitful Efforts",
      "description"=>"Evolve Pokémon.",
      "goals"=>[15,60,120],
      "reward"=>2
    },
    "STONE_EVOLVE_POKEMON"=>{
      "id"=>14,
      "name"=>"That's a stone, Luigi",
      "description"=>"Evolve Pokémon with an evolution stone.",
      "goals"=>[5,10,20],
      "reward"=>2
    },
    "PICKUP"=>{
      "id"=>15,
      "name"=>"Trashman",
      "description"=>"Gather items through Pickup.",
      "goals"=>[10,50,100],
      "reward"=>2
    },
    "MAX_FRIENDSHIP"=>{
      "id"=>16,
      "name"=>"Friendship is Magic",
      "description"=>"Reach Max(255) Friendship with Pokémon.",
      "goals"=>[1,5,15],
      "reward"=>2
    }
  }
  def self.list
    return @achievementList
  end

  def self.fixAchievements
    if !$achievements.is_a?(Hash)
      $achievements={}
    end
    @achievementList.keys.each{|a|
      if $achievements[a].nil?
        $achievements[a]={}
      end
      if $achievements[a]["progress"].nil?
        $achievements[a]["progress"]=0
      end
      if $achievements[a]["level"].nil?
        $achievements[a]["level"]=0
      end
    }
    $achievements.keys.each{|k|
      if !@achievementList.keys.include? k
        $achievements.delete(k)
      end
    }
  end

  def self.resetAchievements
    $achievements={}
    @achievementList.keys.each{|a|
      $achievements[a]={}
      $achievements[a]["progress"]=0
      $achievements[a]["level"]=0
    }
#    $achievements.keys.each{|k|
#      if !@achievementList.keys.include? k
#        $achievements.delete(k)
#      end
#    }
  end
  
  def self.incrementProgress(name, amount)
    if @achievementList.keys.include? name
      if !$achievements[name].nil? && !$achievements[name]["progress"].nil?
        $achievements[name]["progress"]+=amount
        self.checkIfLevelUp(name)
        return true
      else
        return false
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  
  def self.decrementProgress(name, amount)
    if @achievementList.keys.include? name
      if !$achievements[name].nil? && !$achievements[name]["progress"].nil?
        $achievements[name]["progress"]-=amount
        if $achievements[name]["progress"]<0
          $achievements[name]["progress"]=0
        end
        return true
      else
        return false
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  
  def self.setProgress(name, amount)
    if @achievementList.keys.include? name
      if !$achievements[name].nil? && !$achievements[name]["progress"].nil?
        $achievements[name]["progress"]=amount
        if $achievements[name]["progress"]<0
          $achievements[name]["progress"]=0
        end
        self.checkIfLevelUp(name)
        return true
      else
        return false
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  
  def self.checkIfLevelUp(name)
    if @achievementList.keys.include? name
      if !$achievements[name].nil? && !$achievements[name]["progress"].nil?
        level=@achievementList[name]["goals"].length
        @achievementList[name]["goals"].each_with_index{|g,i|
          if $achievements[name]["progress"] < g
            level=i
            break
          end
        }
        if level>$achievements[name]["level"]
          initial = $achievements[name]["level"]+1
          final = level
          $achievements[name]["level"]=level
          total_ap = 0
          (initial..final).each do |i|
            increment = ($game_variables[535]/5).floor
            reward = 1 + increment
            $game_variables[526] += reward
            $game_variables[535] += 1
            total_ap += reward
          end
          id = @achievementList[name]["id"]
          $scene.spriteset.addUserSprite(LocationWindow.new(_INTL("Achievement Reached!\n{1} (Level {2})\nAP earned: {3}",@achievementList[name]["name"],level.to_s,total_ap)))
          return true
        else
          return false
        end
      else
        return false
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  
  def self.getCurrentGoal(name)
    if @achievementList.keys.include? name
      if !$achievements[name].nil? && !$achievements[name]["progress"].nil?
        @achievementList[name]["goals"].each_with_index{|g,i|
          if $achievements[name]["progress"] < g
            return g
          end
        }
        len = @achievementList[name]["goals"].length
        return @achievementList[name]["goals"][len-1]
      else
        return 0
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  
  def self.queueMessage(msg)
    if $achievementmessagequeue.nil?
      $achievementmessagequeue=[]
    end
    $achievementmessagequeue.push(msg)
  end
end