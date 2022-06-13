################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_switches[SHINY_WILD_POKEMON_SWITCH]
     pokemon.makeShiny
   end
}

# Used in the random dungeon map.  Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_map.map_id==51
     pokemon.level=pbBalancedLevel($Trainer.party) - 4 + rand(5)   # For variety
     pokemon.calcStats
     pokemon.resetMoves
   end
}

Events.onTrainerPartyLoad+=proc {|sender,e|
  if e[0] # Trainer data should exist to be loaded, but may not exist somehow
    trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
    items=e[0][1]   # An array of the trainer's items they can use
    party=e[0][2]   # An array of the trainer's Pokémon
    if $Trainer.numbadges>=6 || ($game_variables[200] == 2 && $Trainer.numbadges>=3)
      if ($game_variables[200] == 2 && $Trainer.numbadges>=10)
        for i in party
          for j in 0...4
            i.moves[j].pp = (i.moves[j].pp * 2).floor
            i.moves[j].ppup=4
          end
        end
      else
        for i in party
          for j in 0...4
            i.moves[j].pp = (i.moves[j].pp * 1.6).floor
            i.moves[j].ppup=4
          end
        end
      end
    end
    if ($game_variables[665] == 9 && $game_variables[181] == 56)
      for i in party
        i.hp=1
      end
    end
    for i in party
      if (i.species==PBSpecies::ZANGOOSE && i.item==PBItems::ZANGCREST)
        i.status=PBStatuses::POISON 
      end  
    end
    if trainer.trainertype==PBTrainers::LEADER_SOUTA && trainer.name=="Souta"
      for i in party
        if (i.species==PBSpecies::GLISCOR)
          i.status=PBStatuses::POISON if $game_variables[200]==2
        end  
      end
    end
    if trainer.trainertype==PBTrainers::LEADER_RYLAND && trainer.name=="Flora"
      for i in party
        if (i.species==PBSpecies::GLISCOR && i.item==PBItems::TELLURICSEED)
          i.status=PBStatuses::POISON if $game_variables[200]==2
        end  
      end
    end
    if trainer.trainertype==PBTrainers::MASKEDMAN && trainer.name=="???"
      for i in party
        if (i.species==PBSpecies::SWELLOW)
          i.status=PBStatuses::BURN if $game_variables[200]==2
        end  
      end
    end
    if trainer.trainertype==PBTrainers::STUDENT && trainer.name=="Aelita"
      for i in party
        if (i.species==PBSpecies::GLISCOR && i.item==PBItems::FLYINGGEM)
          i.status=PBStatuses::POISON if $game_variables[200]==2
        end  
      end
    end
    if trainer.trainertype==PBTrainers::KIMONOGIRL2 && trainer.name=="Beatrice"
      for i in party
        if (i.species==PBSpecies::FLAREON)
          i.status=PBStatuses::POISON if $game_variables[200]==2
        end  
      end
    end
    if trainer.trainertype==PBTrainers::MISFORTUNATEDUO && trainer.name=="Eli and Sharon"
      for i in party
        if (i.species==PBSpecies::URSARING)
          i.status=PBStatuses::PARALYSIS if $game_variables[200]==2
        end  
      end
    end
    if trainer.trainertype==PBTrainers::LITTLEDEMON && trainer.name=="Melanie"
      for i in party
        if (i.species==PBSpecies::OBSTAGOON && i.ability==PBAbilities::GUTS)
          i.status=PBStatuses::BURN if $game_variables[200]==2
        end  
      end
    end
    if trainer.trainertype==PBTrainers::DOCTOR && trainer.name=="Isha"
      for i in party
        if (i.species==PBSpecies::GIRATINA)
          case $game_variables[200]
          when 0
            $game_variables[704]=2
          when 1
            $game_variables[704]=1
          when 2
            $game_variables[704]=3
          end
        end  
      end
    end
    if trainer.trainertype==PBTrainers::LEADER_TEXEN && trainer.name=="Texen"
      for i in party
        if (i.species==PBSpecies::MACHAMP)
          i.status=PBStatuses::BURN if $game_variables[200]==2
        end  
      end
    end
  end
}

# UPDATE 11/19/2013
# Cute Charm now gives a 2/3 chance of being opposite gender
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  if !$Trainer.party[0].egg?
    ourpkmn = $Trainer.party[0]
    abl = ourpkmn.ability
    if isConst?(abl, PBAbilities, :CUTECHARM) && rand(3) < 2
      pokemon.setGender(ourpkmn.gender == 0 ? 1 : 0)
    end
  end
}
# UPDATE 11/19/2013
# sync will now give a 50% chance of encountered pokemon having
# the same nature as the party leader
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  if !$Trainer.party[0].egg?
    ours = $Trainer.party[0]
    if isConst?(ours.ability, PBAbilities, :SYNCHRONIZE)
      pokemon.setNature(ours.nature)
    end
  end
}
#Regional Variants + Other things with multiple movesets (Wormadam, Meowstic, etc)
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
    v=MultipleForms.call("getMoveList",pokemon)
    if v!=nil
      moves = v
    else      
      moves = pokemon.getMoveList
    end
    movelist=[]
    for i in moves
      if i[0]<=pokemon.level
        movelist[movelist.length]=i[1]
      end
    end
    movelist|=[] # Remove duplicates
    listend=movelist.length-4
    listend=0 if listend<0
    j=0
    for i in listend...listend+4
      moveid=(i>=movelist.length) ? 0 : movelist[i]
      pokemon.moves[j]=PBMove.new(moveid)
      j+=1
    end    
}

Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  case pokemon.species
  when PBSpecies::GYARADOS
    if $game_map.map_id == 84
      $game_switches[290]=true
      $game_switches[1500]=true
      pokemon.form=2
      pokemon.isbossmon=true
      $game_variables[704]=1
      if $game_variables[200] == 0
      pokemon.level=20
      elsif $game_variables[200] == 1
      pokemon.level=15 
      elsif $game_variables[200] == 2
      pokemon.level=22 
      end
      pokemon.pbLearnMove(:THUNDERFANG)
      pokemon.pbLearnMove(:ICEFANG)
      pokemon.pbLearnMove(:SHADOWSNEAK)
      pokemon.pbLearnMove(:BITE)
      pokemon.setNature(PBNatures::BRAVE)    
      for i in 0...6
        pokemon.ev[i]=(20)
      end
    elsif $game_map.map_id == 321
      $game_switches[290]=true
      $game_switches[1500]=true
      pokemon.form=2
      pokemon.isbossmon=true
      $game_variables[704]=2
      pokemon.pbLearnMove(:WATERFALL)
      pokemon.pbLearnMove(:CRUNCH)
      pokemon.pbLearnMove(:SHADOWSNEAK)
      pokemon.pbLearnMove(:PHANTOMFORCE)
      pokemon.setNature(PBNatures::JOLLY)  
      if $game_variables[200] == 0  
       pokemon.level=40
       for i in 0...6
         pokemon.ev[i]=(60) 
       end
      elsif  $game_variables[200] == 1
        pokemon.level=35 
        pokemon.ev[i]=(40) 
      elsif $game_variables[200] == 2
        pokemon.level=43
        pokemon.ev[0]=152 
        pokemon.ev[1]=152 
        pokemon.ev[2]=60
        pokemon.ev[3]=152
        pokemon.ev[4]=60
        pokemon.ev[5]=60
      end 
      for i in 0...6
        pokemon.iv[i]=31
      end
    elsif $game_map.map_id == 395
      $game_switches[290]=true
      $game_switches[1500]=true
      pokemon.form=3
      case $game_variables[200]
      when 0
        $game_variables[699]=2
        $game_variables[704]=3
        pokemon.level=90
        pokemon.pbLearnMove(:FLASHCANNON)
        pokemon.pbLearnMove(:HYPERBEAM)
        pokemon.pbLearnMove(:SCALD)
        pokemon.pbLearnMove(:SIGNALBEAM)
        pokemon.item = PBItems::SITRUSBERRY
        pokemon.ev[0]=252
        pokemon.ev[3]=252
        pokemon.ev[4]=252
      when 1
        $game_variables[699]=1
        $game_variables[704]=1
        for i in 0...6
          pokemon.ev[i]=(90) 
        end  
        pokemon.level=85
        pokemon.pbLearnMove(:FLASHCANNON)
        pokemon.pbLearnMove(:HYPERBEAM)
        pokemon.pbLearnMove(:SIGNALBEAM)
        pokemon.pbLearnMove(:THUNDERBOLT)
      when 2
        $game_variables[699]=2
        $game_variables[704]=4
        for i in 0...6
          pokemon.ev[i]=252
        end      
        pokemon.level=100
        pokemon.pbLearnMove(:FLASHCANNON)
        pokemon.pbLearnMove(:HYPERVOICE)
        rnd=rand(3)
        if rnd<1
          pokemon.pbLearnMove(:THUNDERBOLT)
          pokemon.pbLearnMove(:AIRSLASH)
          pokemon.item = PBItems::SITRUSBERRY
        elsif rnd<2
          pokemon.pbLearnMove(:SIGNALBEAM)
          pokemon.pbLearnMove(:THUNDERBOLT)
          pokemon.item = PBItems::EXPERTBELT
        else
          pokemon.pbLearnMove(:EARTHPOWER)
          pokemon.pbLearnMove(:AURORABEAM)
          pokemon.item = PBItems::METRONOME  
        end
      end
      for i in 0...6
        pokemon.iv[i]=31
      end
    end
    pokemon.calcStats    
  when PBSpecies::KINGDRA
    if $game_map.map_id == 149
      $game_switches[290]=true
      $game_switches[1500]=true
      $game_variables[704]=2
      pokemon.form=1
      pokemon.isbossmon=true
      pokemon.level=38
      pokemon.level=35 if $game_variables[200] == 1
      pokemon.level=40 if $game_variables[200] == 2
      pokemon.pbLearnMove(:RAINDANCE)
      pokemon.pbLearnMove(:SNIPESHOT)
      pokemon.pbLearnMove(:THUNDER)
      pokemon.pbLearnMove(:DRAGONPULSE)
      pokemon.setAbility(0)
      for i in 0...6
        pokemon.ev[i]=(67)
      end
      for i in 0...6
        pokemon.iv[i]=31
      end
      pokemon.calcStats  
    elsif ($game_map.map_id == 107 || $game_map.map_id == 143) 
      $game_switches[290]=true
      $game_switches[1500]=true
      $game_variables[704]=1
      pokemon.form=1
      pokemon.isbossmon=true
      pokemon.level=55
      pokemon.level=50 if $game_variables[200] == 1
      pokemon.level=60 if $game_variables[200] == 2
      pokemon.setNature(PBNatures::MODEST)    
      pokemon.item = PBItems::DRAGONFANG
      pokemon.pbLearnMove(:DRAGONPULSE)
      pokemon.pbLearnMove(:LUSTERPURGE)
      pokemon.pbLearnMove(:ORIGINPULSE)
      rnd=rand(3)
      case rnd
      when 1
        pokemon.pbLearnMove(:ICEBEAM)
      when 2
        pokemon.pbLearnMove(:AURASPHERE)
      when 3
        pokemon.pbLearnMove(:MYSTICALFIRE)
      end
      pokemon.setAbility(0)
      for i in 0...6
        pokemon.ev[i]=(120)
      end
      for i in 0...6
        pokemon.iv[i]=31
      end
      pokemon.calcStats  
    end
    when PBSpecies::KYOGRE
      if $game_map.map_id == 413
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.isbossmon
        case $game_variables[200]
        when 0
          pokemon.level=60
          $game_variables[704]=3
          pokemon.pbLearnMove(:MUDDYWATER)
          pokemon.pbLearnMove(:THUNDERBOLT)
          pokemon.pbLearnMove(:ICEBEAM)
          pokemon.pbLearnMove(:ROCKSLIDE)
          pokemon.ev[0]=252
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          for i in 0...5
            pokemon.iv[i]=(31)
          end
        when 1
          pokemon.level=55
          $game_variables[704]=2
          pokemon.pbLearnMove(:WATERPULSE)
          pokemon.pbLearnMove(:SHOCKWAVE)
          pokemon.pbLearnMove(:ICEBEAM)
          pokemon.pbLearnMove(:WHIRLPOOL)
          for i in 0...5
            pokemon.iv[i]=(31)
          end
        when 2
          pokemon.level=63
          $game_variables[704]=4
          pokemon.pbLearnMove(:SURF)
          pokemon.pbLearnMove(:ICEBEAM)
          pokemon.pbLearnMove(:THUNDERBOLT)
          pokemon.pbLearnMove(:ROCKSLIDE)
          pokemon.item = PBItems::ELEMENTALSEED
          pokemon.ev[0]=252
          pokemon.ev[1]=100
          pokemon.ev[2]=100
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.ev[5]=100
          for i in 0...5
            pokemon.iv[i]=(31)
          end
        end
        pokemon.setNature(PBNatures::MODEST)
      end
    when PBSpecies::REGIROCK
      if $game_map.map_id == 467
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.makeShiny
        pokemon.isbossmon=true
        if $game_variables[200] == 0
          $game_variables[704]=3
          pokemon.level=75
          pokemon.ev[0]=252
          pokemon.ev[1]=252
          pokemon.ev[5]=252
          pokemon.pbLearnMove(:BULKUP)
          pokemon.pbLearnMove(:STONEEDGE)
          pokemon.pbLearnMove(:EARTHQUAKE)
          pokemon.pbLearnMove(:DRAINPUNCH)
        elsif $game_variables[200] == 1
          $game_variables[704]=2
          pokemon.level=65
          pokemon.pbLearnMove(:BULKUP)
          pokemon.pbLearnMove(:STONEEDGE)
          pokemon.pbLearnMove(:EARTHQUAKE)
          pokemon.pbLearnMove(:DRAINPUNCH)
        elsif $game_variables[200] == 2
          $game_variables[704]=4
          pokemon.level=85
          for i in 0...6
            pokemon.ev[i]=(252)
          end
          pokemon.pbLearnMove(:BULKUP)
          pokemon.pbLearnMove(:STONEEDGE)
          pokemon.pbLearnMove(:EARTHQUAKE)
          pokemon.pbLearnMove(:REST)
        end
        pokemon.item = PBItems::LUMBERRY
        pokemon.setNature(PBNatures::BRAVE)    
      elsif $game_map.map_id == 475
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.isbossmon=true
        pokemon.form=1
        pokemon.name="Aelita"
        if $game_variables[200] == 0
          $game_variables[704]=3
          pokemon.level=80
          pokemon.ev[0]=252
          pokemon.ev[1]=252
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.pbLearnMove(:ROCKSLIDE)
          pokemon.pbLearnMove(:DARKPULSE)
          pokemon.pbLearnMove(:EARTHQUAKE)
          pokemon.pbLearnMove(:AURASPHERE)
        elsif $game_variables[200] == 1
          $game_variables[704]=1
          pokemon.level=75
          pokemon.pbLearnMove(:BULKUP)
          pokemon.pbLearnMove(:STONEEDGE)
          pokemon.pbLearnMove(:EARTHQUAKE)
          pokemon.pbLearnMove(:DARKPULSE)
        elsif $game_variables[200] == 2
          $game_variables[704]=4
          pokemon.level=85
          for i in 0...6
            pokemon.ev[i]=(252)
          end
          pokemon.pbLearnMove(:ROCKSLIDE)
          pokemon.pbLearnMove(:DARKPULSE)
          pokemon.pbLearnMove(:GUNKSHOT)
          pokemon.pbLearnMove(:AURASPHERE)
        end
        pokemon.item = PBItems::LEFTOVERS
        pokemon.setNature(PBNatures::JOLLY)   
      end
    when PBSpecies::GOTHITELLE
      if $game_map.map_id == 425
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.makeShiny
        pokemon.form=0
        pokemon.setAbility(0)
        pokemon.isbossmon=true
        pokemon.pbLearnMove(:PSYCHIC)
        pokemon.pbLearnMove(:CALMMIND)
        pokemon.pbLearnMove(:SHOCKWAVE)
        pokemon.pbLearnMove(:SIGNALBEAM)
        pokemon.setNature(PBNatures::MODEST)    
        pokemon.item = PBItems::TWISTEDSPOON
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=1
          pokemon.level=32
          pokemon.ev[0]=252
          pokemon.ev[1]=0
          pokemon.ev[2]=48
          pokemon.ev[3]=96
          pokemon.ev[4]=48
          pokemon.ev[5]=48
        when 1
          $game_variables[704]=0
          pokemon.level=28
        when 2
          $game_variables[704]=2
          pokemon.level=36
          pokemon.ev[0]=252
          pokemon.ev[1]=0
          pokemon.ev[2]=96
          pokemon.ev[3]=192
          pokemon.ev[4]=96
          pokemon.ev[5]=96
        end
        pokemon.calcStats    
      end
    when PBSpecies::GIRATINA 
      $game_switches[290]=true
      $game_switches[1500]=true
      pokemon.isbossmon
      case $Trainer.numbadges
      when 3
        $game_variables[704]=2
        if $game_variables[200] == 1
          pokemon.level=32
          pokemon.pbLearnMove(:HEX)
          pokemon.pbLearnMove(:BREAKINGSWIPE)
          pokemon.pbLearnMove(:ANCIENTPOWER)
          pokemon.pbLearnMove(:SLASH)
        elsif $game_variables[200] == 2
          pokemon.level=40 
          pokemon.pbLearnMove(:SHADOWCLAW)
          pokemon.pbLearnMove(:DRAGONCLAW)
          pokemon.pbLearnMove(:SHADOWSNEAK)
          pokemon.pbLearnMove(:THUNDERBOLT)
          pokemon.ev[0]=252
          pokemon.ev[1]=60
          pokemon.ev[2]=60
          pokemon.ev[3]=104
          pokemon.ev[4]=152
          pokemon.ev[2]=60
        else
          pokemon.level=37
          pokemon.pbLearnMove(:SHADOWCLAW)
          pokemon.pbLearnMove(:DRAGONBREATH)
          pokemon.pbLearnMove(:SLASH)
          pokemon.pbLearnMove(:THUNDERBOLT)
          pokemon.ev[0]=252
          for i in 1...5
            pokemon.ev[i]=(65)
          end
        end
        pokemon.setNature(PBNatures::QUIET)
      when 7
        case $game_variables[200]
        when 0
          $game_variables[704]=3
          pokemon.pbLearnMove(:SHADOWFORCE)
          pokemon.pbLearnMove(:LAVASURF)
          pokemon.pbLearnMove(:DRAGONPULSE)
          pokemon.pbLearnMove(:EARTHPOWER)
          pokemon.level=60
          pokemon.ev[0]=4
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.setNature(PBNatures::MODEST)
        when 1
          pokemon.level=55
          $game_variables[704]=1
          pokemon.pbLearnMove(:SHADOWFORCE)
          pokemon.pbLearnMove(:LAVASURF)
          pokemon.pbLearnMove(:DRAGONPULSE)
          pokemon.pbLearnMove(:EARTHPOWER)
          for i in 0...6
            pokemon.ev[i]=85
          end
          pokemon.setNature(PBNatures::MODEST)
        when 2
          pokemon.level=66
          $game_variables[704]=4
          pokemon.pbLearnMove(:SHADOWFORCE)
          pokemon.pbLearnMove(:LAVASURF)
          pokemon.pbLearnMove(:DRAGONPULSE)
          pokemon.pbLearnMove(:THUNDER) 
          pokemon.ev[0]=252
          pokemon.ev[1]=252
          pokemon.ev[2]=85
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.ev[5]=85
          pokemon.setNature(PBNatures::MODEST)
        end
      end
      pokemon.item = PBItems::GRISEOUSORB
      pokemon.form=1
      for i in 0...5
        pokemon.iv[i]=31
      end
      pokemon.calcStats    
    when PBSpecies::DARKRAI 
      if $game_map.map_id == 57
      $game_switches[290]=true
      $game_switches[1500]=true
      pokemon.isbossmon
      pokemon.pbLearnMove(:NIGHTMARE)
      pokemon.pbLearnMove(:SPIRITBREAK)
      pokemon.pbLearnMove(:BUNRAKUBEATDOWN)
      pokemon.pbLearnMove(:DREAMEATER)
      pokemon.name="Puppet Master"
      pokemon.setNature(PBNatures::MODEST)
      if $game_switches[1368]==false
       pokemon.form=1
       case $game_variables[200]
       when 0
         $game_variables[704]=4
         $game_variables[699]=2
         pokemon.level=90
         pokemon.ev[1]=252
         pokemon.ev[4]=252
       when 1
         $game_variables[704]=2
         pokemon.level=85
       when 2 
         $game_variables[704]=5
         $game_variables[699]=3
         pokemon.level=95
         for i in 0...6
          pokemon.ev[i]=252
         end
         pokemon.obspa=20
       end
       for i in 0...6
         pokemon.iv[i]=31
       end
      else
        case $game_variables[200]
        when 0
          pokemon.level=90
        when 1
          pokemon.level=85
        when 2 
          pokemon.level=95
        end
        pokemon.form=2
        for i in 0...6
          pokemon.iv[i]=0
        end
        $game_variables[704]=0
        pokemon.ev[0]=0
        pokemon.ev[1]=0
        pokemon.ev[4]=0
      end
      pokemon.item = PBItems::LEFTOVERS
      pokemon.calcStats  
      end
    when PBSpecies::FERROTHORN
      if $game_map.map_id == 447
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.form=1
        pokemon.isbossmon=true
        pokemon.pbLearnMove(:FIRELASH)
        pokemon.pbLearnMove(:STEAMROLLER)
        pokemon.pbLearnMove(:EARTHQUAKE)
        pokemon.pbLearnMove(:IRONHEAD)
        pokemon.setNature(PBNatures::ADAMANT)    
        pokemon.item = PBItems::METRONOME
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=3
          pokemon.level=75
          pokemon.ev[0]=4
          pokemon.ev[1]=252
          pokemon.ev[3]=252
        when 1
          $game_variables[704]=2
          pokemon.level=70
        when 2
          $game_variables[704]=4
          pokemon.level=80
          pokemon.ev[0]=252
          pokemon.ev[1]=252
          pokemon.ev[2]=85
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.ev[5]=85
        end
        pokemon.calcStats    
      end
    when PBSpecies::FROSLASS
      if $game_map.map_id == 155
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.form=1
        pokemon.isbossmon=true
        pokemon.pbLearnMove(:DISCHARGE)
        pokemon.pbLearnMove(:POISONGAS)
        pokemon.pbLearnMove(:ICEBEAM)
        pokemon.pbLearnMove(:MOONBLAST)
        pokemon.setNature(PBNatures::ADAMANT)    
        pokemon.item = PBItems::METRONOME
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=4
          pokemon.level=90
          pokemon.ev[3]=252
          pokemon.ev[4]=252
        when 1
          $game_variables[704]=3
          pokemon.level=85
        when 2
          $game_variables[704]=5
          pokemon.level=95
          pokemon.ev[0]=252
          pokemon.ev[1]=252
          pokemon.ev[2]=85
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.ev[5]=85
        end
        pokemon.calcStats    
        pokemon.name="Dufaux" 
      end
    when PBSpecies::GARDEVOIR
      if $game_map.map_id == 240
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.form=4
        pokemon.isbossmon=true
        pokemon.pbLearnMove(:HYPERVOICE)
        pokemon.pbLearnMove(:PSYSHOCK)
        pokemon.pbLearnMove(:DARKPULSE)
        pokemon.pbLearnMove(:FOCUSBLAST)
        pokemon.setNature(PBNatures::MODEST)    
        pokemon.item = PBItems::LUMBERRY
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=3
          pokemon.level=60
          for i in 0...6
            pokemon.ev[i]=85
          end
          pokemon.obhp=20
          pokemon.obspa=30
        when 1
          $game_variables[704]=2
          pokemon.level=55
        when 2
          $game_variables[704]=4
          pokemon.level=65
          pokemon.ev[0]=252
          pokemon.ev[1]=252
          pokemon.ev[2]=85
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.ev[5]=85
          pokemon.obhp=50
          pokemon.obspa=30
        end
        pokemon.calcStats  
      elsif $game_map.map_id == 552 && $game_variables[298]==0
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.form=3
        pokemon.isbossmon=true
        pokemon.pbLearnMove(:DARKPULSE)
        pokemon.pbLearnMove(:LOVELYKISS)
        pokemon.pbLearnMove(:SECRETSWORD)
        pokemon.pbLearnMove(:HYPERSPACEHOLE)
        pokemon.setNature(PBNatures::NAIVE)    
        pokemon.item = PBItems::LUMBERRY
        for i in 0...6
          pokemon.iv[i]=31
        end
        pokemon.level=80
        pokemon.ev[0]=252
        pokemon.ev[1]=252
        pokemon.ev[2]=85
        pokemon.ev[3]=252
        pokemon.ev[4]=252
        pokemon.ev[5]=85
        pokemon.calcStats    
      elsif $game_map.map_id == 552
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.form=2
        pokemon.isbossmon=true
        pokemon.pbLearnMove(:DARKPULSE)
        pokemon.pbLearnMove(:LOVELYKISS)
        pokemon.pbLearnMove(:SACREDSWORD)
        pokemon.pbLearnMove(:HYPERSPACEHOLE)
        pokemon.setNature(PBNatures::NAIVE)    
        pokemon.item = PBItems::LUMBERRY
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=4
          pokemon.level=80
          pokemon.ev[1]=52
          pokemon.ev[3]=252
          pokemon.ev[4]=200
        when 1
          $game_variables[704]=3
          pokemon.level=80
        when 2
          $game_variables[704]=5
          pokemon.level=85
          for i in 0...6
            pokemon.ev[i]=252
          end
        end
        pokemon.calcStats    
      end
    when PBSpecies::GARBODOR
      if $game_map.map_id == 415
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.makeShiny
        pokemon.form=1
        pokemon.isbossmon=true
        pokemon.setNature(PBNatures::MODEST)    
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=3
          pokemon.level=60
          for i in 0...6
            pokemon.ev[i]=85
          end
          pokemon.pbLearnMove(:SLUDGEWAVE)
          pokemon.pbLearnMove(:GIGADRAIN)
          pokemon.pbLearnMove(:DARKPULSE)
          pokemon.pbLearnMove(:RECOVER)
          pokemon.item = PBItems::BLACKSLUDGE
        when 1
          $game_variables[704]=2
          pokemon.level=55
          pokemon.pbLearnMove(:SLUDGEWAVE)
          pokemon.pbLearnMove(:GIGADRAIN)
          pokemon.pbLearnMove(:DARKPULSE)
        when 2
          $game_variables[704]=4
          pokemon.level=65
          pokemon.ev[0]=252
          pokemon.ev[1]=252
          pokemon.ev[2]=85
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.ev[5]=85
          pokemon.pbLearnMove(:SLUDGEWAVE)
          pokemon.pbLearnMove(:GIGADRAIN)
          pokemon.pbLearnMove(:DARKPULSE)
          pokemon.pbLearnMove(:RECOVER)
          pokemon.item = PBItems::BLACKSLUDGE
        end
        pokemon.calcStats    
      end
    when PBSpecies::CARNIVINE
      if $game_map.map_id == 224
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.form=1
        pokemon.isbossmon=true
        pokemon.pbLearnMove(:COIL)
        pokemon.pbLearnMove(:DRAGONRUSH)
        pokemon.pbLearnMove(:POWERWHIP)
        pokemon.pbLearnMove(:GUNKSHOT)
        pokemon.setNature(PBNatures::JOLLY)    
        pokemon.item = PBItems::YACHEBERRY
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=2
          pokemon.level=45
          for i in 0...6
            pokemon.ev[i]=100
          end
        when 1
          $game_variables[704]=1
          pokemon.level=40
        when 2
          $game_variables[704]=2
          pokemon.level=48
          pokemon.ev[0]=152
          pokemon.ev[1]=252
          pokemon.ev[2]=85
          pokemon.ev[3]=252
          pokemon.ev[4]=152
          pokemon.ev[5]=85
        end
        pokemon.calcStats    
      end
    when PBSpecies::WAILORD
      if $game_map.map_id == 278 && $game_variables[617]==20
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.makeShiny
        pokemon.form=1
        pokemon.setAbility(0)
        pokemon.isbossmon=true
        pokemon.name="Kawopudunga" 
        pokemon.pbLearnMove(:DIVE)
        pokemon.pbLearnMove(:FRUSTRATION)
        pokemon.pbLearnMove(:DARKESTLARIAT)
        pokemon.pbLearnMove(:ICEBEAM)
        pokemon.setNature(PBNatures::MODEST)    
        pokemon.item = PBItems::LEFTOVERS
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=3
          pokemon.level=90
          pokemon.ev[3]=252
          pokemon.ev[4]=252
        when 1
          $game_variables[704]=2
          pokemon.level=80
        when 2
          $game_variables[704]=4
          pokemon.level=100
          pokemon.ev[0]=252
          pokemon.ev[1]=252
          pokemon.ev[2]=252
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.ev[5]=252
        end
        pokemon.calcStats    
      end
    when PBSpecies::HIPPOWDON
      if $game_map.map_id == 577
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.form=1
        pokemon.isbossmon=true
        pokemon.setNature(PBNatures::QUIET)    
        pokemon.item = PBItems::BLACKSLUDGE
        pokemon.genderflag=1
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=4
          pokemon.level=90
          pokemon.ev[0]=252
          pokemon.ev[4]=252
          pokemon.pbLearnMove(:SPITUP)
          pokemon.pbLearnMove(:EARTHPOWER)
          pokemon.pbLearnMove(:ROCKTOMB)
          pokemon.pbLearnMove(:HEATWAVE)
        when 1
          $game_variables[704]=2
          pokemon.level=80
          pokemon.ev[0]=252
          pokemon.ev[1]=4
          pokemon.ev[4]=252
          pokemon.pbLearnMove(:DOUBLEEDGE)
          pokemon.pbLearnMove(:ROCKTOMB)
          pokemon.pbLearnMove(:EARTHPOWER)
          pokemon.pbLearnMove(:SLUDGEWAVE)
        when 2
          $game_variables[704]=5
          pokemon.level=95
          for i in 0...6
            pokemon.ev[i]=252
          end
          pokemon.obatk=30
          pokemon.obspa=30
          pokemon.pbLearnMove(:SPITUP)
          pokemon.pbLearnMove(:THOUSANDARROWS)
          pokemon.pbLearnMove(:SLUDGEBOMB)
          pokemon.pbLearnMove(:HEATWAVE)
        end
        pokemon.calcStats    
      end
    when PBSpecies::CHANDELURE
      if $game_map.map_id == 152
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.form=2
        pokemon.isbossmon=true
        pokemon.pbLearnMove(:POWERGEM)
        pokemon.pbLearnMove(:OMINOUSWIND)
        pokemon.pbLearnMove(:ICYWIND)
        pokemon.pbLearnMove(:HEATWAVE)
        pokemon.setNature(PBNatures::MODEST)    
        pokemon.item = PBItems::SPELLTAG
        for i in 0...6
          pokemon.iv[i]=31
        end
        case $game_variables[200]
        when 0
          $game_variables[704]=1
          pokemon.level=58
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.ev[0]=4
        when 1
          $game_variables[704]=1
          pokemon.level=55
        when 2
          $game_variables[704]=2
          pokemon.level=62
          pokemon.ev[3]=252
          pokemon.ev[4]=252
          pokemon.ev[0]=252
        end
        pokemon.calcStats    
      end
    when PBSpecies::VOLCANION
      if $game_map.map_id == 32
        $game_switches[290]=true
        $game_switches[1500]=true
        $game_variables[704]=2
        pokemon.form=1
        pokemon.isbossmon=true
        pokemon.level=23
        pokemon.level=20 if $game_variables[200] == 1
        pokemon.level=27 if $game_variables[200] == 2
        pokemon.pbLearnMove(:FLAMETHROWER)
        pokemon.pbLearnMove(:WATERPULSE) if $game_variables[200] != 2
        pokemon.pbLearnMove(:STEAMERUPTION) if $game_variables[200] == 2
        pokemon.pbLearnMove(:BULLDOZE)
        pokemon.pbLearnMove(:ROCKTOMB)
        pokemon.setNature(PBNatures::MODEST)       
        for i in 0...6
          pokemon.iv[i]=20
        end
        pokemon.ev[0]=252
        pokemon.ev[4]=252
        pokemon.ev[1]=4
        pokemon.calcStats    
      end  
    when PBSpecies::XERNEAS
      if $game_map.map_id == 517
        $game_switches[290]=true
        $game_switches[1500]=true
        case $game_variables[200]
        when 0
          $game_variables[704]=4
          #game_variables[699]=2
        when 1
          $game_variables[704]=3
        when 2
          $game_variables[704]=5
          pokemon.obhp=20
          pokemon.obdef=10
          pokemon.obspd=10
          #$game_variables[699]=2
        end
        pokemon.form=1
        pokemon.isbossmon=true
        pokemon.name="STORM | Wind" 
        pokemon.level=85
        pokemon.pbLearnMove(:WEATHERBALL)
        pokemon.pbLearnMove(:THUNDER) 
        pokemon.pbLearnMove(:HURRICANE)
        pokemon.pbLearnMove(:PSYSHOCK)
        pokemon.setNature(PBNatures::MODEST)       
        for i in 0...6
          pokemon.iv[i]=31
        end
        for i in 0...6
          pokemon.ev[i]=252
        end
        pokemon.calcStats    
      end 
    end
  # Egg moves for wild events
  case $game_variables[545]
    when 1 # A-Exegg
      pokemon.pbLearnMove(:DRAGONHAMMER)
      pokemon.form=1
    when 2
      pokemon.pbLearnMove(:NASTYPLOT)
    when 3 # Darmanitan
      pokemon.pbLearnMove(:EXTRASENSORY)
      pokemon.setAbility(2)
    when 4 #Mandibuzz
      pokemon.pbLearnMove(:FOULPLAY)
    when 5 # Trapinch, Pinsir
      pokemon.pbLearnMove(:SUPERPOWER)
    when 6
      pokemon.pbLearnMove(:SUPERPOWER)     
    when 7 #Hoppip
      pokemon.pbLearnMove(:STRENGTHSAP)
    when 8 #Fletchling
      pokemon.pbLearnMove(:QUICKGUARD)
    when 9 #Voltorb
      pokemon.pbLearnMove(:SIGNALBEAM)
    when 10 #Pachirisu
      pokemon.pbLearnMove(:ELECTROWEB)  
    when 11 #Electrike
      pokemon.pbLearnMove(:FLAMEBURST)  
    when 12 #Pichu
      pokemon.pbLearnMove(:PRESENT) 
    when 13 #Litleo
      pokemon.pbLearnMove(:FIRESPIN) 
    when 14 #Lillipup
      pokemon.pbLearnMove(:PSYCHICFANGS) 
    when 15 #Misdreavus
      pokemon.pbLearnMove(:PAINSPLIT) 
    when 16 #Munna
      pokemon.pbLearnMove(:SWIFT)
    when 17 #Seviper
      pokemon.pbLearnMove(:BODYSLAM)
    when 18 # Just extrasensory, Whismur
      pokemon.pbLearnMove(:EXTRASENSORY)
    when 19 # Spoink
      pokemon.pbLearnMove(:FUTURESIGHT)
    when 20 # Solrock
      pokemon.pbLearnMove(:STOMPINGTANTRUM)
    when 21 # Sewaddle
      pokemon.pbLearnMove(:BATONPASS)
    when 22 # Growlithe, Pinsir
      pokemon.pbLearnMove(:CLOSECOMBAT)
    when 23 # Rowlet
      pokemon.pbLearnMove(:DEFOG)
    when 24 # Decidueye
      pokemon.pbLearnMove(:DEFOG)
      pokemon.pbLearnMove(:BATONPASS)
    when 26 # Tropius
      pokemon.pbLearnMove(:DRAGONDANCE)
    when 27 # Yanma
      pokemon.pbLearnMove(:SILVERWIND)
    when 28 # Krabby
      pokemon.pbLearnMove(:KNOCKOFF)
    when 29 # Kingler
      pokemon.pbLearnMove(:KNOCKOFF)
      pokemon.pbLearnMove(:LIQUIDATION)
    when 30 # Clamperl
      pokemon.pbLearnMove(:CONFUSERAY)
    when 31 # Squirtle
      pokemon.pbLearnMove(:MIRRORCOAT)
    when 32 # Gastrodon
      pokemon.pbLearnMove(:EARTHPOWER)
    when 33 # Ralts
      pokemon.pbLearnMove(:SHADOWSNEAK)
    when 34 # Mudkip
      pokemon.pbLearnMove(:CURSE)
    when 35 # Elekid, Magby 
      pokemon.pbLearnMove(:CROSSCHOP)
    when 36 # Piplup
      pokemon.pbLearnMove(:ICYWIND)
    when 37 # Empoleon
      pokemon.pbLearnMove(:LIQUIDATION)
      pokemon.pbLearnMove(:STEALTHROCK)
      pokemon.pbLearnMove(:ICEBEAM)
    when 38 # Piplup
      pokemon.pbLearnMove(:ICYWIND)
    when 39 # Octillery
      pokemon.pbLearnMove(:GUNKSHOT)
    when 40 # Buneary
      pokemon.pbLearnMove(:COSMICPOWER)
    when 41 # Sneasel
      pokemon.pbLearnMove(:ICICLECRASH)
    when 42 # Mareep
      pokemon.pbLearnMove(:MAGNETRISE)
    when 43 # Inkay
      pokemon.pbLearnMove(:DESTINYBOND)
    when 44 # Heatmor
      pokemon.pbLearnMove(:SUCKERPUNCH)
    when 45 # Abra
      pokemon.pbLearnMove(:PSYCHICTERRAIN)
    when 46 # Litten
      pokemon.pbLearnMove(:FAKEOUT)
    when 47 # TURTWIG
      pokemon.pbLearnMove(:HEAVYSLAM)
    when 48 # Stantler
      pokemon.pbLearnMove(:MEGAHORN)
    when 49 # Sawsbuck
      pokemon.pbLearnMove(:HEADBUTT)
    when 50 # Dodrio
      pokemon.pbLearnMove(:BRAVEBIRD)
    when 51 # Parasect
      pokemon.pbLearnMove(:WIDEGUARD)
    when 52 # Oshawott
      pokemon.pbLearnMove(:SACREDSWORD)
    when 53 # Butterfree
      pokemon.pbLearnMove(:TAILWIND)
    when 54 # Beedrill
      pokemon.pbLearnMove(:DRILLRUN)
    when 55 # Petilil
      pokemon.pbLearnMove(:HEALINGWISH)
    when 56 # Stufful
      pokemon.pbLearnMove(:ICEPUNCH)
    when 57 # Chatot
      pokemon.pbLearnMove(:BOOMBURST)
    when 58 # Darumaka
      pokemon.pbLearnMove(:YAWN)
    when 59 # Wishiwashi
      pokemon.pbLearnMove(:WHIRLPOOL)
    when 60 # Sableye
      pokemon.pbLearnMove(:RECOVER)
    when 61 # Komala
      pokemon.pbLearnMove(:PLAYROUGH)
    when 62 # Sandygast
      pokemon.pbLearnMove(:GRAVITY)
    when 63 # Pallosand
      pokemon.pbLearnMove(:GRAVITY)
      pokemon.pbLearnMove(:STEALTHROCK)
    when 64 # Buizel
      pokemon.pbLearnMove(:TAILSLAP)
    when 65 # Clefairy
      pokemon.pbLearnMove(:MISTYTERRAIN)
    when 66 # Jynx
      pokemon.pbLearnMove(:PSYCHIC)
      pokemon.pbLearnMove(:NASTYPLOT)
    when 67 # Nidoran F
      pokemon.pbLearnMove(:CHARM)
    when 68 # Blitzle
      pokemon.pbLearnMove(:DOUBLEKICK)
    when 69 # Inkay
      pokemon.pbLearnMove(:DESTINYBOND)
    when 70 # Snorlax
      pokemon.pbLearnMove(:POWERUPPUNCH)
    when 71 # 
      pokemon.pbLearnMove(:SPIKES)
    when 72 # 
      pokemon.pbLearnMove(:NIGHTSLASH)
    when 73 # Flabebe
      pokemon.pbLearnMove(:NATUREPOWER)
    when 74 # Ambipom
      pokemon.pbLearnMove(:FAKEOUT)
      pokemon.pbLearnMove(:TAILSLAP)
    when 75 # Lunatone
      pokemon.pbLearnMove(:STEALTHROCK)
    when 76 # 
      pokemon.pbLearnMove(:MAGNETRISE)  
    when 77 # Swablu
      pokemon.pbLearnMove(:HEALBELL) 
    when 78 # 
      pokemon.pbLearnMove(:REFRESH)
    when 79 # 
      pokemon.pbLearnMove(:TRICK)
    when 80 # Gastly
      pokemon.pbLearnMove(:REFLECTTYPE)
      pokemon.pbLearnMove(:FRUSTRATION) 
      pokemon.makeFemale
      pokemon.happiness=0
    when 81 # Lombre
      pokemon.pbLearnMove(:LEECHSEED)
    when 82 # Corsola
      pokemon.pbLearnMove(:THROATCHOP)
    when 83 # Pyukumuku
      pokemon.pbLearnMove(:BLOCK)
    when 84 # Slowpoke
      pokemon.pbLearnMove(:BELLYDRUM)
    when 85 # Pinsir
      pokemon.pbLearnMove(:QUICKATTACK)
    when 86 # Lapras
      pokemon.pbLearnMove(:FREEZEDRY)
    when 87 # Gible
      pokemon.pbLearnMove(:OUTRAGE) 
      pokemon.pbLearnMove(:IRONHEAD)
    when 88 # Clawitzer
      pokemon.pbLearnMove(:DRAGONPULSE)
      pokemon.pbLearnMove(:ICYWIND)
    when 89 # Larvesta
      pokemon.pbLearnMove(:GIGADRAIN)
      pokemon.pbLearnMove(:MORNINGSUN)
    when 90 # Vulpix
      pokemon.pbLearnMove(:HEATWAVE)
      pokemon.pbLearnMove(:TAILSLAP)
    when 91 # Dewpider
      pokemon.pbLearnMove(:STICKYWEB)
      pokemon.pbLearnMove(:GIGADRAIN)
    when 92 # Horsea
      pokemon.pbLearnMove(:DRAGONPULSE)
      pokemon.pbLearnMove(:SNIPESHOT)
    when 93 # Pelipper
      pokemon.pbLearnMove(:SHOCKWAVE)
      pokemon.pbLearnMove(:SEEDBOMB)
    when 94 # Tepig
      pokemon.pbLearnMove(:SUPERPOWER)
      pokemon.pbLearnMove(:BURNUP)
      pokemon.pbLearnMove(:SUCKERPUNCH)
    when 95 # Mech  
      pokemon.pbLearnMove(:JAWLOCK)  
      pokemon.pbLearnMove(:THUNDERFANG)  
      pokemon.pbLearnMove(:HIGHHORSEPOWER)  
      pokemon.pbLearnMove(:HEAVYSLAM)  
      pokemon.name="LAIR-????" 
      pokemon.setNature(PBNatures::ADAMANT)
      pokemon.form=1
      for i in 0...5
       pokemon.iv[i]=31
      end
      case $game_variables[200]
      when 0
      pokemon.ev[1]=252
      pokemon.ev[3]=252
      pokemon.ev[4]=4
      when 1
      for i in 0...5
          pokemon.ev[i]=(pokemon.level*1.5)
      end
      when 2
        for i in 0...5
            pokemon.ev[i]=252
        end  
        rnd=rand(3)
        if rnd<1
          pokemon.item = PBItems::ASSAULTVEST
        elsif rnd<2
          pokemon.item = PBItems::REDCARD
        else 
          pokemon.item = PBItems::LIECHIBERRY
        end
      end
      pokemon.calcStats  
    when 96 # Lapras
      pokemon.pbLearnMove(:ROCKSLIDE)
      pokemon.pbLearnMove(:PSYCHIC)
      pokemon.pbLearnMove(:CONFUSERAY)
      pokemon.pbLearnMove(:SING)
      pokemon.form=2
    when 98 # Mech
      pokemon.pbLearnMove(:LIGHTSCREEN)
      pokemon.pbLearnMove(:REFLECT)
      pokemon.name="CLAY-????"
      pokemon.setNature(PBNatures::MODEST)
      pokemon.form=1
      pokemon.item = PBItems::CLAYCREST
      case $game_variables[200]
      when 0
      pokemon.ev[0]=252
      pokemon.ev[2]=252
      pokemon.ev[4]=4
      pokemon.pbLearnMove(:FLASHCANNON)
      pokemon.pbLearnMove(:HYPERBEAM)
      when 1
      for i in 0...5
          pokemon.ev[i]=(pokemon.level*1.5)
      end
      pokemon.pbLearnMove(:FLASHCANNON)
      pokemon.pbLearnMove(:HYPERBEAM)
      when 2
        for i in 0...5
            pokemon.ev[i]=252
        end  
        rnd=rand(3)
        if rnd<1
          pokemon.pbLearnMove(:EARTHPOWER)
          pokemon.pbLearnMove(:HYPERBEAM)
        elsif rnd<2
          pokemon.pbLearnMove(:ICEBEAM)
          pokemon.pbLearnMove(:PSYBEAM)
        else
          pokemon.pbLearnMove(:SOLARBEAM)
          pokemon.pbLearnMove(:HYPERBEAM)
        end
      end
      pokemon.calcStats    
    when 99 # Treecko
      pokemon.pbLearnMove(:LEECHSEED)
    when 100 # Regice
      pokemon.pbLearnMove(:COLDTRUTH)
      pokemon.pbLearnMove(:REFLECT)
      pokemon.pbLearnMove(:THUNDERBOLT)
      pokemon.pbLearnMove(:SHEERCOLD)
      pokemon.name="REGICE"
      pokemon.setNature(PBNatures::MODEST)
      pokemon.form=1
      case $game_variables[200]
      when 0
      pokemon.ev[0]=252
      pokemon.ev[2]=252
      pokemon.ev[4]=4
      when 1
      for i in 0...5
          pokemon.ev[i]=(pokemon.level*1.5)
      end
      when 2
        for i in 0...5
            pokemon.ev[i]=252
        end  
      end
      pokemon.calcStats    
    when 101 # Aevian Paras
      pokemon.form=1
    when 101 # Pidove
      pokemon.pbLearnMove(:MORNINGSUN)
    when 102 # Hoothoot
      pokemon.pbLearnMove(:SLEEPTALK)
      pokemon.pbLearnMove(:NIGHTSHADE)
      pokemon.status=PBStatuses::SLEEP
      pokemon.statusCount=3
      pokemon.setAbility(2)
    when 103 # Cubone
      pokemon.pbLearnMove(:ANCIENTPOWER)
      pokemon.pbLearnMove(:PERISHSONG)
    when 104 # Duskull
      pokemon.pbLearnMove(:MEMENTO)
      pokemon.pbLearnMove(:CHARGEBEAM)
    when 105 # A-Grimer
      pokemon.form=1
    when 106 # G-Corsola
      pokemon.form=1
    when 107 # A-Munna
      pokemon.form=1
    end
}
