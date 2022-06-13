################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_switches[:Force_Wild_Shiny]
     pokemon.makeShiny
   end
   if $game_switches[:No_Catching]
    pokemon.makeNotShiny
   end
}

Events.onTrainerPartyLoad+=proc {|sender,e|
  if e[0] # Trainer data should exist to be loaded, but may not exist somehow
    trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
    items=e[0][1]   # An array of the trainer's items they can use
    party=e[0][2]   # An array of the trainer's Pokémon
    if Reborn && (trainer.trainertype==PBTrainers::SHELLY || trainer.trainertype==PBTrainers::FUTURESHELLY) && trainer.name=="Shelly"
      if party[5].species==PBSpecies::LEAVANNY # [0] is the Pokemon's place in the trainer party, with 0 being slot 1 and so forth (must be changed in all following lines) & where species is the species to change
        party[5].name=$Trainer.name
        case $game_variables[:Player_Gender]
          when 0 # Male player
            party[5].makeMale
          when 1 # Female player
            party[5].makeFemale
          when 2 # Nonbinary player - added in PokeBattle_Pokemon
            party[5].makeGenderless
        end
      end
    end
    if Reborn && (trainer.trainertype==PBTrainers::DARKRAI) && trainer.name=="Darkrai"
      if party[3].species==PBSpecies::DARKRAI # [0] is the Pokemon's place in the trainer party, with 0 being slot 1 and so forth (must be changed in all following lines) & where species is the species to change
        party[3].name = $game_variables[782] if $game_variables[782].is_a?(String) && $game_variables[782] != ""
        party[3].makeShiny if $game_switches[2200]==true
      end
    end
    if $game_switches[:Offset_Trainer_Levels] == true
      for i in 0...party.length
        if $game_variables[764] < 0 
          party[i].level = [(party[i].level+$game_variables[764]),1].max
        else
          party[i].level = (party[i].level+$game_variables[764])
        end
        party[i].calcStats
      end
    end
    if $game_switches[:Percent_Trainer_Levels] == true
      for i in 0...party.length
        if $game_variables[771] < 100 
          party[i].level = [(party[i].level*($game_variables[771]*0.01)).round,1].max
        else
          party[i].level = (party[i].level*($game_variables[771]*0.01))
        end
        party[i].calcStats
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
    if isConst?(ours.ability, PBAbilities, :SYNCHRONIZE) && rand(2) == 0
      pokemon.setNature(ours.nature)
    end
  end
}
#Regional Variants + Other things with multiple movesets (Wormadam, Meowstic, etc)
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  name = pokemon.getFormName
	v = PokemonForms.dig(pokemon.species,name,:Movelist)
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
  movelist.reverse!
  movelist.uniq!
  # Use the first 4 items in the move list
  movelist = movelist[0,4]
  movelist.reverse!
  for i in 0...4
    moveid=(i>=movelist.length) ? 0 : movelist[i]
    pokemon.moves[i]=PBMove.new(moveid)
  end
}
# Egg moves for wild events
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  case $game_variables[232]
    when 1 # Type:Null
      pokemon.pbLearnMove(:IRONHEAD)
      pokemon.pbLearnMove(:METALSOUND)
      pokemon.pbLearnMove(:XSCISSOR)
      pokemon.pbLearnMove(:CRUSHCLAW)
    when 2 # Deino
      pokemon.pbLearnMove(:HEADBUTT)
      pokemon.pbLearnMove(:DRAGONBREATH)
      pokemon.pbLearnMove(:CRUNCH)
      pokemon.pbLearnMove(:SLAM)
    when 3 # Stantler
      pokemon.pbLearnMove(:CONFUSERAY)
      pokemon.pbLearnMove(:STOMP)
      pokemon.pbLearnMove(:DISABLE)
      pokemon.pbLearnMove(:MEGAHORN)
    when 4 # Zangoose
      pokemon.pbLearnMove(:NIGHTSLASH)
    when 5 # Hoppip
      pokemon.pbLearnMove(:GRASSYTERRAIN)
    when 6
      pokemon.pbLearnMove(:ENCORE)
    when 7 
      pokemon.pbLearnMove(:AROMATHERAPY)
    when 8 # Pichu
      pokemon.pbLearnMove(:ENCORE)
    when 9 
      pokemon.pbLearnMove(:FAKEOUT)
    when 10
      pokemon.pbLearnMove(:WISH)
    when 11
      pokemon.pbLearnMove(:VOLTTACKLE)
    when 12 # Zorua
      pokemon.pbLearnMove(:EXTRASENSORY)
    when 13 # Emolga
      pokemon.pbLearnMove(:IONDELUGE)
    when 14
      pokemon.pbLearnMove(:AIRSLASH)
    when 15
      pokemon.pbLearnMove(:ROOST)
    when 16 # Murkrow
      pokemon.pbLearnMove(:BRAVEBIRD)
    when 17
      pokemon.pbLearnMove(:PERISHSONG)
    when 18 # Tropius
      pokemon.pbLearnMove(:LEECHSEED)
    when 19
      pokemon.pbLearnMove(:DRAGONDANCE)
    when 20
      pokemon.pbLearnMove(:LEAFBLADE)
    when 21 # Malamar
      loop do 
        break if pokemon.personalID % 4 == 3 # force topsy turvy preference
        pokemon.personalID=rand(256)
        pokemon.personalID|=rand(256)<<8
        pokemon.personalID|=rand(256)<<16
        pokemon.personalID|=rand(256)<<24
        pokemon.calcStats
      end
      pokemon.pbLearnMove(:PSYCHOCUT) 
      pokemon.pbLearnMove(:TOPSYTURVY) 
    when 22 # Heatran
      pokemon.pbLearnMove(:EARTHPOWER) 
      pokemon.pbLearnMove(:IRONHEAD) 
      pokemon.pbLearnMove(:FIRESPIN) 
      pokemon.pbLearnMove(:SCARYFACE) 
    when 23 # Elgyem
      pokemon.pbLearnMove(:COSMICPOWER)
    when 24
      pokemon.pbLearnMove(:NASTYPLOT)
    when 25 # Pumpkaboo
      pokemon.pbLearnMove(:DESTINYBOND)
    when 26 # Shuppet
      pokemon.pbLearnMove(:CONFUSERAY)
    when 27
      pokemon.pbLearnMove(:GUNKSHOT)
    when 28
      pokemon.pbLearnMove(:PURSUIT)
    when 29 # Drifloon
      pokemon.pbLearnMove(:DESTINYBOND)
    when 30
      pokemon.pbLearnMove(:TAILWIND)
    when 31
      pokemon.pbLearnMove(:WEATHERBALL)
    when 32 # Joltik
      pokemon.pbLearnMove(:CROSSPOISON)
    when 33 # Torkoal
      pokemon.pbLearnMove(:SUPERPOWER)
    when 34
      pokemon.pbLearnMove(:YAWN)
    when 35
      pokemon.pbLearnMove(:ERUPTION)
    when 36 # Heatmor
      pokemon.pbLearnMove(:SUCKERPUNCH)
    when 37
      pokemon.pbLearnMove(:HEATWAVE)
    when 38
      pokemon.pbLearnMove(:NIGHTSLASH)
    when 39 # Tepig
      pokemon.pbLearnMove(:HEAVYSLAM)
    when 40
      pokemon.pbLearnMove(:BODYSLAM)
    when 41
      pokemon.pbLearnMove(:SUCKERPUNCH)
    when 42
      pokemon.pbLearnMove(:SUPERPOWER)
    when 43
      pokemon.pbLearnMove(:MAGNITUDE)
    when 44 # Squirtle
      pokemon.pbLearnMove(:MIRRORCOAT)
    when 45
      pokemon.pbLearnMove(:DRAGONPULSE)
    when 46
      pokemon.pbLearnMove(:AURASPHERE)
    when 47
      pokemon.pbLearnMove(:WATERSPOUT)
    when 48 # Spiritomb
      pokemon.pbLearnMove(:FOULPLAY)
    when 49
      pokemon.pbLearnMove(:SHADOWSNEAK)
    when 50
      pokemon.pbLearnMove(:DESTINYBOND)
    when 51
      pokemon.pbLearnMove(:PAINSPLIT)
    when 52 # Seviper
      pokemon.pbLearnMove(:STOCKPILE)
    when 53 # A. Misdreavus
      pokemon.form=1
    when 54 # UNUSED
    when 55 # Lapras
      pokemon.pbLearnMove(:CURSE)
    when 56
      pokemon.pbLearnMove(:DRAGONDANCE)
    when 57
      pokemon.pbLearnMove(:FREEZEDRY)
    when 58 # Sneasel
      pokemon.pbLearnMove(:PURSUIT)
      pokemon.pbLearnMove(:ICESHARD)
    when 59
      pokemon.pbLearnMove(:ICICLECRASH)
      pokemon.pbLearnMove(:ICESHARD)
    when 60
      pokemon.pbLearnMove(:FAKEOUT)
      pokemon.pbLearnMove(:ICESHARD)
    when 61 # Totodile
      pokemon.pbLearnMove(:AQUAJET)
    when 62
      pokemon.pbLearnMove(:DRAGONDANCE)
    when 63
      pokemon.pbLearnMove(:ICEPUNCH)
    when 64 # Skuntank
      pokemon.pbLearnMove(:FLAMETHROWER)
      pokemon.pbLearnMove(:ACIDSPRAY)
      pokemon.pbLearnMove(:PLAYROUGH)
      pokemon.pbLearnMove(:NIGHTSLASH)
      pokemon.ot="Corey"
      pokemon.trainerID=32574
    when 65
      pokemon.pbLearnMove(:FLAMEBURST)
      pokemon.pbLearnMove(:ACIDSPRAY)
      pokemon.pbLearnMove(:PURSUIT)
      pokemon.pbLearnMove(:NIGHTSLASH)
      pokemon.ot="Corey"
      pokemon.trainerID=32574
    when 66
      pokemon.pbLearnMove(:FLAMETHROWER)
      pokemon.pbLearnMove(:ACIDSPRAY)
      pokemon.pbLearnMove(:PURSUIT)
      pokemon.pbLearnMove(:FOULPLAY)
      pokemon.ot="Corey"
      pokemon.trainerID=32574
    when 67 # Rotom
      pokemon.ot="Shade"
      pokemon.trainerID=$Trainer.getForeignID
    when 68 # Larvitar
      pokemon.pbLearnMove(:DRAGONDANCE)
    when 69
      pokemon.pbLearnMove(:CURSE)
    when 70 
      pokemon.pbLearnMove(:IRONHEAD)
    when 71 
      pokemon.pbLearnMove(:OUTRAGE)
    when 72 
      pokemon.pbLearnMove(:STEALTHROCK)
    when 73 # Absol
      pokemon.pbLearnMove(:PLAYROUGH)
      pokemon.pbLearnMove(:MEGAHORN)
      pokemon.pbLearnMove(:SUCKERPUNCH)
      pokemon.pbLearnMove(:SWORDSDANCE)
      pokemon.ot="Ame"
      pokemon.trainerID=$Trainer.getForeignID
    when 74 # A-Exegg
      pokemon.pbLearnMove(:DRAGONHAMMER)
      pokemon.form=1
    when 75 # Mimikyu
      pokemon.pbLearnMove(:DESTINYBOND)
      pokemon.pbLearnMove(:SHADOWCLAW)
    when 76 # Gible
      pokemon.pbLearnMove(:IRONHEAD)
      pokemon.pbLearnMove(:OUTRAGE) 
    when 77 # Gastly
      pokemon.pbLearnMove(:DISABLE)
      pokemon.pbLearnMove(:SHADOWBALL)   
    when 78 # Larvesta
      pokemon.pbLearnMove(:MORNINGSUN)   
    when 79 # Saphira- Mandibuzz
      pokemon.pbLearnMove(:FOULPLAY)  
      pokemon.pbLearnMove(:ROOST)  
      pokemon.pbLearnMove(:TOXIC)  
      pokemon.pbLearnMove(:MIRRORMOVE)  
    when 80 # Saphira- Ambipom
      pokemon.pbLearnMove(:DUALCHOP)  
      pokemon.pbLearnMove(:BOUNCE)  
      pokemon.pbLearnMove(:KNOCKOFF)  
      pokemon.pbLearnMove(:LOWKICK)  
    when 81 # Saphira- Blaziken
      pokemon.pbLearnMove(:BLAZEKICK)  
      pokemon.pbLearnMove(:HIJUMPKICK)  
      pokemon.pbLearnMove(:EARTHQUAKE)  
      pokemon.pbLearnMove(:DUALCHOP) 
      pokemon.abilityflag = 1
    when 82 # Saphira- Charizard
      pokemon.pbLearnMove(:FLAREBLITZ)  
      pokemon.pbLearnMove(:DRAGONDANCE)  
      pokemon.pbLearnMove(:DRAGONRUSH)  
      pokemon.pbLearnMove(:FLY) 
    when 83 # Saphira- Tyrantrum
      pokemon.pbLearnMove(:FIREFANG)  
      pokemon.pbLearnMove(:ROCKSLIDE)  
      pokemon.pbLearnMove(:DRAGONDANCE)  
      pokemon.pbLearnMove(:DRAGONCLAW) 
    when 84 # Saphira- Zoroark
      pokemon.pbLearnMove(:FOULPLAY)  
      pokemon.pbLearnMove(:FLAMETHROWER)  
      pokemon.pbLearnMove(:SUCKERPUNCH)  
      pokemon.pbLearnMove(:EXTRASENSORY) 
    when 85 # Saphira- Magneton
      pokemon.pbLearnMove(:THUNDERWAVE)  
      pokemon.pbLearnMove(:DISCHARGE)  
      pokemon.pbLearnMove(:FLASHCANNON)  
      pokemon.pbLearnMove(:SIGNALBEAM) 
    when 86 # Saphira- Druddigon
      pokemon.pbLearnMove(:OUTRAGE)  
      pokemon.pbLearnMove(:FIREPUNCH)  
      pokemon.pbLearnMove(:GUNKSHOT)  
      pokemon.pbLearnMove(:IRONHEAD) 
    when 87 # Saphira- Aerodactyl
      pokemon.pbLearnMove(:FIREFANG)  
      pokemon.pbLearnMove(:ROCKSLIDE)  
      pokemon.pbLearnMove(:DRAGONCLAW)  
      pokemon.pbLearnMove(:IRONHEAD) 
    when 88 # Saphira- Garchomp
      pokemon.pbLearnMove(:FIREFANG)  
      pokemon.pbLearnMove(:DRAGONRUSH)  
      pokemon.pbLearnMove(:CRUNCH)  
      pokemon.pbLearnMove(:EARTHQUAKE) 
    when 89 # Saphira- Flygon
      pokemon.pbLearnMove(:DRAGONCLAW)  
      pokemon.pbLearnMove(:DRAGONDANCE)  
      pokemon.pbLearnMove(:FIREPUNCH)  
      pokemon.pbLearnMove(:EARTHQUAKE) 
    when 90 # Articuno
      pokemon.pbLearnMove(:ROOST)  
      pokemon.pbLearnMove(:BLIZZARD)  
      pokemon.pbLearnMove(:HURRICANE)  
      pokemon.pbLearnMove(:ICEBEAM)
    when 91 # Moltres
      pokemon.pbLearnMove(:HEATWAVE)  
      pokemon.pbLearnMove(:SKYATTACK)  
      pokemon.pbLearnMove(:ROOST)  
      pokemon.pbLearnMove(:HURRICANE)
    when 92 # Zapdos
      pokemon.pbLearnMove(:DRILLPECK)  
      pokemon.pbLearnMove(:ZAPCANNON)  
      pokemon.pbLearnMove(:ROOST)  
      pokemon.pbLearnMove(:THUNDER)    
    when 93 # Azelf
      pokemon.pbLearnMove(:NASTYPLOT)  
      pokemon.pbLearnMove(:EXTRASENSORY)  
      pokemon.pbLearnMove(:LASTRESORT)  
      pokemon.pbLearnMove(:SWIFT)
    when 94 # Mesprit
      pokemon.pbLearnMove(:CHARM)  
      pokemon.pbLearnMove(:EXTRASENSORY)  
      pokemon.pbLearnMove(:COPYCAT)  
      pokemon.pbLearnMove(:SWIFT)
    when 95 # Uxie
      pokemon.pbLearnMove(:AMNESIA)  
      pokemon.pbLearnMove(:EXTRASENSORY)  
      pokemon.pbLearnMove(:FLAIL)  
      pokemon.pbLearnMove(:SWIFT)
    when 96 # Regirock
      pokemon.pbLearnMove(:CURSE)  
      pokemon.pbLearnMove(:STONEEDGE)  
      pokemon.pbLearnMove(:HAMMERARM)  
      pokemon.pbLearnMove(:IRONDEFENSE)
    when 97 # Regice
      pokemon.pbLearnMove(:ICEBEAM)  
      pokemon.pbLearnMove(:HYPERBEAM)  
      pokemon.pbLearnMove(:ANCIENTPOWER)  
      pokemon.pbLearnMove(:CHARGEBEAM)
    when 98 # Registeel
      pokemon.pbLearnMove(:FLASHCANNON)  
      pokemon.pbLearnMove(:LOCKON)  
      pokemon.pbLearnMove(:ZAPCANNON)  
      pokemon.pbLearnMove(:SUPERPOWER)
    when 99 # Cobalion
      pokemon.pbLearnMove(:SACREDSWORD)  
      pokemon.pbLearnMove(:IRONHEAD)  
      pokemon.pbLearnMove(:WORKUP)  
      pokemon.pbLearnMove(:CLOSECOMBAT)  
    when 100 # Terrakion
      pokemon.pbLearnMove(:ROCKSLIDE)  
      pokemon.pbLearnMove(:SACREDSWORD)  
      pokemon.pbLearnMove(:STONEEDGE)  
      pokemon.pbLearnMove(:WORKUP)  
    when 101 # Virizion
      pokemon.pbLearnMove(:GIGADRAIN)  
      pokemon.pbLearnMove(:SACREDSWORD)  
      pokemon.pbLearnMove(:LEAFBLADE)  
      pokemon.pbLearnMove(:WORKUP) 
    when 102 # Keldeo
      pokemon.pbLearnMove(:SECRETSWORD)  
    when 103 # Volcanion
      pokemon.pbLearnMove(:STEAMERUPTION)  
      pokemon.pbLearnMove(:BODYSLAM)  
      pokemon.pbLearnMove(:OVERHEAT)  
      pokemon.pbLearnMove(:HYDROPUMP) 
    when 104 # Victini
      pokemon.pbLearnMove(:OVERHEAT)  
      pokemon.pbLearnMove(:STOREDPOWER)  
      pokemon.pbLearnMove(:INFERNO)  
      pokemon.pbLearnMove(:ZENHEADBUTT) 
    when 105 # Kyogre
      pokemon.item = PBItems::BLUEORB
      pokemon.pbLearnMove(:HYDROPUMP) 
      pokemon.pbLearnMove(:WATERSPOUT) 
      pokemon.pbLearnMove(:SHEERCOLD) 
      pokemon.pbLearnMove(:MUDDYWATER)
    when 106 # Groudon
      pokemon.item = PBItems::REDORB
      pokemon.pbLearnMove(:SOLARBEAM) 
      pokemon.pbLearnMove(:FIREBLAST) 
      pokemon.pbLearnMove(:HAMMERARM) 
      pokemon.pbLearnMove(:ERUPTION)
    when 107 # Thundurus
      pokemon.pbLearnMove(:NASTYPLOT) 
      pokemon.pbLearnMove(:THUNDER) 
      pokemon.pbLearnMove(:DARKPULSE) 
      pokemon.pbLearnMove(:HAMMERARM) 
    when 108 # Tornadus
      pokemon.pbLearnMove(:RAINDANCE) 
      pokemon.pbLearnMove(:HURRICANE) 
      pokemon.pbLearnMove(:DARKPULSE) 
      pokemon.pbLearnMove(:HAMMERARM) 
    when 109 # Landorus
      pokemon.pbLearnMove(:SANDSTORM) 
      pokemon.pbLearnMove(:FISSURE) 
      pokemon.pbLearnMove(:STONEEDGE) 
      pokemon.pbLearnMove(:HAMMERARM) 
    when 110 # Meloetta
      pokemon.pbLearnMove(:PSYCHIC) 
      pokemon.pbLearnMove(:ROLEPLAY) 
      pokemon.pbLearnMove(:HYPERVOICE) 
      pokemon.pbLearnMove(:CLOSECOMBAT) 
    when 111 # Genesect
      pokemon.pbLearnMove(:HYPERBEAM) 
      pokemon.pbLearnMove(:SIMPLEBEAM) 
      pokemon.pbLearnMove(:ZAPCANNON) 
      pokemon.pbLearnMove(:BUGBUZZ) 
    when 112 # Reshiram
      pokemon.pbLearnMove(:BLUEFLARE) 
      pokemon.pbLearnMove(:CRUNCH) 
      pokemon.pbLearnMove(:FIREBLAST) 
      pokemon.pbLearnMove(:HYPERVOICE) 
    when 113 # Zekrom
      pokemon.pbLearnMove(:BOLTSTRIKE) 
      pokemon.pbLearnMove(:HYPERVOICE) 
      pokemon.pbLearnMove(:THUNDER) 
      pokemon.pbLearnMove(:CRUNCH) 
    when 114 # Kyurem
      pokemon.pbLearnMove(:HYPERVOICE) 
      pokemon.pbLearnMove(:BLIZZARD) 
      pokemon.pbLearnMove(:DRAGONPULSE) 
      pokemon.pbLearnMove(:ENDEAVOR) 
    when 115 # Arceus
      pokemon.pbLearnMove(:FUTURESIGHT) 
      pokemon.pbLearnMove(:RECOVER) 
      pokemon.pbLearnMove(:HYPERBEAM) 
      pokemon.pbLearnMove(:JUDGMENT) 
    when 120..145 
      val = ($game_variables[232] - 120)
      # Create hash contains alphabetical table
      alpha_table = {}
      (('A'..'Z').zip(1..26)).each { |x| alpha_table[x[0]] = x[1] }
      s = "ELECTRICGRASSYMISTYPSYCHIC" # String to convert
      result = s.split('').collect { |x| alpha_table[x] }
      pokemon.form = (result[val] - 1)  # Unown for Tapus
    end
  }