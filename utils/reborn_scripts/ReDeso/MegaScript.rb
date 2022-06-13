def megaStoneScript
##megastone list - you want to associate each mon name in all caps to an array of the
##stones it can interact with. Try keeping the fangame-exclusive one at the bottom
##so it's easier for everyone
  megaStonesList={
  "VENUSAUR"=> ["VENUSAURITE"], 
  'CHARIZARD'=> ["CHARIZARDITEX","CHARIZARDITEY"], 
  'BLASTOISE'=> ["BLASTOISINITE"],
  'ALAKAZAM'=> ["ALAKAZITE"],
  'GENGAR'=> ["GENGARITE"],
  'KANGASHKHAN'=> ["KANGASHKHANITE"],
  'PINSIR'=> ["PINSIRITE"],
  'GYARADOS'=> ["GYARADOSITE"],
  'AERODACTYL'=> ["AERODACTYLITE"],
  'MEWTWO'=> ["MEWTWONITEX","MEWTWONITEY"],
  'AMPHAROS'=> ["AMPHAROSITE"],
  'SCIZOR'=> ["SCIZORITE"],
  'HERACROSS'=> ["HERACRONITE"],
  'HOUNDOOM'=> ["HOUNDOOMINITE"],
  'TYRANITAR'=> ["TYRANITARITE"],
  'BLAZIKEN'=> ["BLAZIKENITE"],
  'GARDEVOIR'=> ["GARDEVOIRITE"],
  'MAWILE'=> ["MAWILITE"],
  'AGGRON'=> ["AGGRONITE"],
  'MEDICHAM'=> ["MEDICHAMITE"],
  'MANECTRIC'=> ["MANECTITE"],
  'BANETTE'=> ["BANETTITE"],
  'ABSOL'=> ["ABSOLITE"],
  'GARCHOMP'=> ["GARCHOMPITE"],
  'LUCARIO'=> ["LUCARIONITE"],
  'ABOMASNOW'=> ["ABOMASITE"],
  'BEEDRILL'=> ["BEEDRILLITE"],
  'PIDGEOT'=> ["PIDGEOTITE"],
  'SLOWBRO'=> ["SLOWBRONITE"],
  'STEELIX'=> ["STEELIXITE"],
  'SCEPTILE'=> ["SCEPTILITE"],
  'SWAPMPERT'=> ["SWAMPERTITE"],
  'SABLEYE'=> ["SABLENITE"],
  'SHARPEDO'=> ["SHARPEDONITE"],
  'CAMERUPT'=> ["CAMERUPTITE"],
  'ALTARIA'=> ["ALTARIANITE"],
  'GLALIE'=> ["GLALITITE"],
  'SALAMENCE'=> ["SALAMENCITE"],
  'METAGROSS'=> ["METAGROSSITE"],
  'LATIAS'=> ["LATIASITE"],
  'LATIOS'=> ["LATIOSITE"],
  'LOPUNNY'=> ["LOPUNNITE"],
  'GALLADE'=> ["GALLADITE"],
  'AUDINO'=> ["AUDINITE"],
  'DIANCIE'=> ["DIANCITE"],
  'MIGHTYENA'=> ["MIGHTYENITE"],
  'DARKRAI'=> ["DARKRITE"],
  'TOXICROAK'=> ["TOXICROAKITE"],
  'CINCCINO'=> ["CINCCINITE"],
  'UMBREON'=> ["DARKRITE"]
  }
  ##this is where we will store the stones we're gonna suggest
  possibleStones = []
  ##iterating through the player's team and comparing species to our array
  for i in 0..$Trainer.party.length-1
    speciesname=PBSpecies.getName($Trainer.party[i].species).upcase 
    if megaStonesList.key?(speciesname)
      possibleStones.concat megaStonesList[speciesname]
    end
  end
  ##now that we've got our preliminary list we're gonna check no one is holding a
  ##megastone. If it turns out one of our candidates stones is already held, we remove it.
  for i in 0..$Trainer.party.length-1
    if $Trainer.party[i].item !=0
      testString = remove_accents(PBItems.getName($Trainer.party[i].item)).upcase!.delete(" ").delete("-")
    end
    possibleStones.delete(testString) if possibleStones.include? testString
  end
  ##we remove any duplicates in case someone's running like two identical mons 
  possibleStones = possibleStones.uniq
  ##now we're gonna iterate through the stones we've got left
  stonesToRemove= []
  ##if we check our bag and find we already have one of them, we remove it.
  for i in 0..possibleStones.length-1
    stonesToRemove<< possibleStones[i] if $PokemonBag.pbQuantity(possibleStones[i])>0
  end
  possibleStones= possibleStones-stonesToRemove
  
  ##if after that we've still got at least one stone to offer, we present the player
  ##the choice to take it or decline
  if possibleStones.length>0
    stoneNames=[]
    for i in 0..possibleStones.length-1
      stoneNames<< PBItems.getName(PBItems.const_get(possibleStones[i]))
    end
    stoneNames << "None, thanks"
    command = Kernel.pbMessage("\\ff[11] Which stone do you want ?",stoneNames,stoneNames.length)
    ##if they accept, we store the id of the stone so we can replace it by our replacement
    ##items when the time comes to find it in the overworld.
    if command != possibleStones.length
      Kernel.pbReceiveItem(PBItems.const_get(possibleStones[command]))
      $game_variables[299]=PBItems.const_get(possibleStones[command])
    else
      ##you prolly wanna replace this with context-relevant dialogue.
      Kernel.pbMessage("\\ff[11b]Wait, Really ?")
      Kernel.pbMessage("\\ff[11]I guess you know what you're doing. Hit me up if you need something.")
    end
  else
    ##same here
    Kernel.pbMessage("\\ff[11b]Oh, looks like you have no candidates for Mega Evolution.")
  end
end

def remove_accents(str)
  ##just to be on the extra safe side
  accents = {
    ['á','à','â','ä','ã'] => 'a',
    ['Ã','Ä','Â','À'] => 'A',
    ['é','è','ê','ë'] => 'e',
    ['Ë','É','È','Ê'] => 'E',
    ['í','ì','î','ï'] => 'i',
    ['Î','Ì'] => 'I',
    ['ó','ò','ô','ö','õ'] => 'o',
    ['Õ','Ö','Ô','Ò','Ó'] => 'O',
    ['ú','ù','û','ü'] => 'u',
    ['Ú','Û','Ù','Ü'] => 'U',
    ['ç'] => 'c', ['Ç'] => 'C',
    ['ñ'] => 'n', ['Ñ'] => 'N'
  }
  accents.each do |ac,rep|
    ac.each do |s|
      str = str.gsub(s, rep)
    end
  end
  str = str.gsub(/[^a-zA-Z0-9\. ]/,"")
  str = str.gsub(/[ ]+/," ")
  str = str.gsub(/ /,"-")
  #str = str.downcase
end

def pbReceiveItemOrReplace(item)
  ##this is the thing you want to call when handing out mega stones or Z crystals now
  if PBItems.const_get(item)!=$game_variables[299]
     Kernel.pbReceiveItem(item)
  ##this is where you define your replacement stone, choose wisely.
  else
     Kernel.pbReceiveItem(:DARKRITE)
  end
end
def zMoveScript
   ## first we make an array of the type centric z-crystals
  typeCrystals=["NORMALIUMZ","FIGHTINIUMZ","FLYINIUMZ","POISONIUMZ",
  "GROUNDIUMZ","ROCKIUMZ","BUGINIUMZ","GHOSTIUMZ","STEELIUMZ",nil,
  "FIRIUMZ","WATERIUMZ","GRASSIUMZ","ELECTRIUMZ","PSYCHIUMZ","ICIUMZ",
  "DRAGONIUMZ","DARKINIUMZ","FAIRIUMZ"]
  ##then we do the species-centrics one
  monCrystals= {
  26=>["ALORAICHIUMZ"],
  724=>["DECIDIUMZ"],
  727=>["INCINIUMZ"],
  730=>["PRIMARIUMZ"],
  133=>["EEVIUMZ"],
  25=>["PIKANIUMZ"],
  143=>["SNORLIUMZ"],
  151=>["MEWNIUMZ"],
  785=>["TAPUNIUMZ"],
  786=>["TAPUNIUMZ"],
  787=>["TAPUNIUMZ"],
  788=>["TAPUNIUMZ"],
  802=>["MARSHADIUMZ"],
  784=>["KOMMONIUMZ"],
  745=>["LYCANIUMZ"],
  778=>["MIMIKIUMZ"],
  791=>["SOLGANIUMZ"],
  800=>["SOLGANIUMZ","LUNALIUMZ","ULTRANECROZIUMZ"],
  792=>["LUNALIUMZ"]
  }
  ##we set this variable to a value that unambiguously cannot correspond to anyone in the team.
  ##this is vital in case the player declines, so we can properly handle that case
  $game_variables[300]=-1
  pbChoosePokemon(300,301)
  if $game_variables[300]!=-1
    moves = $Trainer.party[$game_variables[300]].moves
    crystals=[]
    ##we iterate through the moves of a mon, find the type of the moves, add the corresponding
    ##crystal to the array
    for i in 0..$Trainer.party[$game_variables[300]].moves.length-1
      crystals << typeCrystals[$Trainer.party[$game_variables[300]].moves[i].type]
    end
    ##yeet the duplicates
    
    crystals = crystals.uniq
    ##find the relevant species-centric crystals and add them
    if monCrystals.key?($Trainer.party[$game_variables[300]].species)
        crystals.concat monCrystals[$Trainer.party[$game_variables[300]].species]
    end
    crystalsToRemove= []
    ##remove from the list those the player already posess
    for i in 0..crystals.length-1
      crystalsToRemove<< crystals[i] if $PokemonBag.pbQuantity(crystals[i])>0
    end
    crystals= crystals-crystalsToRemove
    ##build a choice menu from the options remaining. if you geniunely end with 
    ##no z-crystals available, then I'm out of ideas.
    if crystals.length>0
      crystalNames=[]
      for i in 0..crystals.length-1
        crystalNames<< PBItems.getName(PBItems.const_get(crystals[i]))
      end
      crystalNames << "None, thanks"
      command = Kernel.pbMessage("\\ff[11] Which Z-crystal do you want ?",crystalNames,crystalNames.length)
      if command != crystals.length
        Kernel.pbReceiveItem(PBItems.const_get(crystals[command]))
        $game_variables[299]=PBItems.const_get(crystals[command])
      else
        Kernel.pbMessage("\\ff[11b]Wait, AGAIN ?")
        Kernel.pbMessage("\\ff[11]Fine, fine, I'll get out of your hair. But let me know if you need something, for real.")
      end
    else
      Kernel.pbMessage("\\ff[11]\\Oh, looks like you already have all the crystals this pokémon could want.")
      Kernel.pbMessage("\\ff[11]\\You can try with another pokémon, if you want.")
    end
  else
    Kernel.pbMessage("\\ff[11b]Wait, AGAIN ?")
    Kernel.pbMessage("\\ff[11]Fine, fine, I'll get out of your hair. But let me know if you need something, for real.")
  end
end