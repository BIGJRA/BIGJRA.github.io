Events.onStepTaken+=proc {|sender,e|
  next if !$Trainer
  rnd=rand(100)
  if rnd<10 && $game_switches[750]
    leader=$game_player
    offset = [[0,-1],[1,0],[-1,0],[0,1]][leader.direction/2 - 1]
    mapTile1 = leader.x + offset[0]
    mapTile2 = leader.y + offset[1]
    rpgEvent=RPG::Event.new(mapTile1,mapTile2)
    newEvent=Game_Event.new($game_map.map_id,rpgEvent,$MapFactory.getMap($game_map.map_id))
    case leader.direction  # direction
    when 2 then newEvent.turn_down
    when 4 then newEvent.turn_left
    when 6 then newEvent.turn_right
    when 8 then newEvent.turn_up
    end
    newEvent.character_name="491"
    newEvent.character_hue=0
    pbAddDependency(newEvent)
    Kernel.pbMessage("\\ff[21]DARKRAI: No.")
    if pbTrainerBattle(PBTrainers::MASTERMIND,"Darkrai",_I("So... That is your answer."),false,0,false,nil,recorded:true)
      for i in 0..$Trainer.party.length-1
         if $Trainer.party[i]==$umbreon
            $Trainer.party[i]=$game_variables[800]
          end
      end
      for i in $Trainer.party
        i.heal
      end
      $Trainer.badges[7]=true
      Kernel.pbMessage("\\ff[21]DARKRAI: Gnnh... I can't believe you manage to elude me even now.")
      Kernel.pbMessage("\\ff[21]DARKRAI: I will retreat... for now. Next time, you won't be so lucky.")
    end
    $game_switches[750]=0
    pbRemoveDependency(newEvent)
  end
}

