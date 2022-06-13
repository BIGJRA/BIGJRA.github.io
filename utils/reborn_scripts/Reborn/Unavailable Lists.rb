def unavailableMoveList(move)
=begin   if move == PBMoves::EARTHQUAKE ||
      move == PBMoves::SWORDSDANCE ||
      move == PBMoves::FIREBLAST ||
      move == PBMoves::BLIZZARD ||
      move == PBMoves::THUNDER ||
      move == PBMoves::SLUDGEBOMB ||
      move == PBMoves::ENERGYBALL ||
      move == PBMoves::PSYSHOCK ||
      move == PBMoves::UTURN ||
      move == PBMoves::VOLTSWITCH ||
      move == PBMoves::ICEBEAM ||
      move == PBMoves::DRAGONCLAW ||
      move == PBMoves::SECRETSWORD ||
      move == PBMoves::RELICSONG ||
      move == PBMoves::DRAGONASCENT
      return true
=end    else
      return false
  #  end
end
  
def unavailableMonList(pokemon)
=begin  if pokemon.species==PBSpecies::ARTICUNO || 
     pokemon.species==PBSpecies::MOLTRES ||
     pokemon.species==PBSpecies::ZAPDOS || 
     pokemon.species==PBSpecies::MEWTWO || 
     pokemon.species==PBSpecies::MEW || 
     pokemon.species==PBSpecies::RAIKOU || 
     pokemon.species==PBSpecies::ENTEI || 
     pokemon.species==PBSpecies::SUICUNE ||
     pokemon.species==PBSpecies::LUGIA || 
     pokemon.species==PBSpecies::HOOH || 
     pokemon.species==PBSpecies::CELEBI ||
     pokemon.species==PBSpecies::REGIROCK || 
     pokemon.species==PBSpecies::REGICE || 
     pokemon.species==PBSpecies::REGISTEEL ||
     pokemon.species==PBSpecies::LATIAS || 
     pokemon.species==PBSpecies::LATIOS || 
     pokemon.species==PBSpecies::KYOGRE ||
     pokemon.species==PBSpecies::GROUDON || 
     pokemon.species==PBSpecies::RAYQUAZA || 
     pokemon.species==PBSpecies::JIRACHI ||
     pokemon.species==PBSpecies::DEOXYS ||    
     pokemon.species==PBSpecies::UXIE ||
     pokemon.species==PBSpecies::MESPRIT || 
     pokemon.species==PBSpecies::AZELF || 
     pokemon.species==PBSpecies::DIALGA ||
     pokemon.species==PBSpecies::PALKIA || 
     pokemon.species==PBSpecies::HEATRAN || 
     pokemon.species==PBSpecies::REGIGIGAS ||
     pokemon.species==PBSpecies::GIRATINA || 
     pokemon.species==PBSpecies::CRESSELIA || 
     pokemon.species==PBSpecies::MANAPHY || 
     pokemon.species==PBSpecies::DARKRAI || 
     pokemon.species==PBSpecies::SHAYMIN ||
     pokemon.species==PBSpecies::ARCEUS || 
     pokemon.species==PBSpecies::VICTINI ||  
     pokemon.species==PBSpecies::COBALION || 
     pokemon.species==PBSpecies::TERRAKION ||
     pokemon.species==PBSpecies::VIRIZION || 
     pokemon.species==PBSpecies::TORNADUS || 
     pokemon.species==PBSpecies::THUNDURUS ||
     pokemon.species==PBSpecies::RESHIRAM || 
     pokemon.species==PBSpecies::ZEKROM || 
     pokemon.species==PBSpecies::LANDORUS || 
     pokemon.species==PBSpecies::KYUREM || 
     pokemon.species==PBSpecies::KELDEO || 
     pokemon.species==PBSpecies::MELOETTA ||
     pokemon.species==PBSpecies::GENESECT || 
     pokemon.species==PBSpecies::XERNEAS ||
     pokemon.species==PBSpecies::YVELTAL || 
     pokemon.species==PBSpecies::ZYGARDE ||
     pokemon.species==PBSpecies::TAPUKOKO ||
     pokemon.species==PBSpecies::TAPULELE ||
     pokemon.species==PBSpecies::TAPUBULU ||
     pokemon.species==PBSpecies::TAPUFINI ||     
     pokemon.species==PBSpecies::COSMOG ||
     pokemon.species==PBSpecies::COSMOEM ||
     pokemon.species==PBSpecies::SOLGALEO ||
     pokemon.species==PBSpecies::LUNALA ||
     pokemon.species==PBSpecies::NIHILEGO ||
     pokemon.species==PBSpecies::BUZZWOLE ||
     pokemon.species==PBSpecies::PHEROMOSA ||
     pokemon.species==PBSpecies::XURKITREE ||
     pokemon.species==PBSpecies::CELESTEELA ||
     pokemon.species==PBSpecies::KARTANA ||
     pokemon.species==PBSpecies::GUZZLORD ||
     pokemon.species==PBSpecies::NECROZMA ||
     pokemon.species==PBSpecies::MAGEARNA ||
     pokemon.species==PBSpecies::MARSHADOW ||
     pokemon.species==PBSpecies::STAKATAKA ||
     pokemon.species==PBSpecies::BLACEPHALON ||
     pokemon.species==PBSpecies::ZERAORA
     return true
=end   else
     return false
#   end
end
  