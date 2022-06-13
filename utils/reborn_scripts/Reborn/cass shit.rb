def eventfindreplace
    for n in 1..999
        savemap = false
        map_name = sprintf("Data/Map%03d.rxdata", n)
        next if !(File.open(map_name,"rb") { true } rescue false)
        map = load_data(map_name)
        for i in map.events.keys.sort
            event = map.events[i]
            for j in 0...event.pages.length
                page = event.pages[j]
                list = page.list
                index = 0 
                while index < list.length - 1
                    if list[index].code == 101 ||list[index].code == 401
                        text = list[index].parameters[0]
                        if text.include? "aïve"
                            puts "found"
                            savemap = true
                            map.events[i].pages[j].list[index].parameters[0].gsub! 'aïve', 'aive'
                        end
                    end
                    index += 1
                end
            end
        end
        if savemap
            save_data(map,sprintf("Data/Map%03d.rxdata", n))
        end
    end
end

def eventfixtransfer
  for n in 1..999
      savemap = false
      map_name = sprintf("Data/Map%03d.rxdata", n)
      next if !(File.open(map_name,"rb") { true } rescue false)
      map = load_data(map_name)
      for i in map.events.keys.sort
          event = map.events[i]
          for j in 0...event.pages.length
              page = event.pages[j]
              list = page.list
              index = 0 
              while index < list.length - 1
                  if list[index].code == 201
                    if list[index].parameters[5] != 1
                      map.events[i].pages[j].list[index].parameters[5] = 1 
                      savemap = true
                    end
                  end
                  index += 1
              end
          end
      end
      if savemap
          save_data(map,sprintf("Data/Map%03d.rxdata", n))
      end
  end
end

def eventscriptamender
	for n in 1..999
		savemap = false
		map_name = sprintf("Data/Map%03d.rxdata", n)
		next if !(File.open(map_name,"rb") { true } rescue false)
		map = load_data(map_name)
		for i in map.events.keys.sort
			event = map.events[i]
			for j in 0...event.pages.length
				page = event.pages[j]
				list = page.list
				index = 0 
				while index < list.length - 1
					if list[index].code == 355 || list[index].code == 655
						map.events[i].pages[j].list[index].parameters[0].gsub! '$fefieldeffect', '$game_variables[7]'
						savemap = true
					end
					index += 1
				end
			end
		end
		if savemap
			save_data(map,sprintf("Data/Map%03d.rxdata", n))
		end
	end
end

def typosCSVFix
	typoarray = File.read("typos.txt").split("\n").map(&:strip)
	for i in 0...typoarray.length
		typoarray[i] = typoarray[i].split("@")
		typoarray[i][2] = false
	end
	for n in 1..910
		savemap = false
		map_name = sprintf("Data/Map%03d.rxdata", n)
		next if !(File.open(map_name,"rb") { true } rescue false)
		map = load_data(map_name)
		for typo in typoarray
			for i in map.events.keys.sort
				event = map.events[i]
				for j in 0...event.pages.length
					page = event.pages[j]
					list = page.list
					index = 0 
					while index < list.length - 1
						if list[index].code == 101 ||list[index].code == 401
							text = list[index].parameters[0]
							if text.include? typo[0]
								puts "#========# found #{typo[0]}"
								puts "full line: #{text}"
								savemap = true
								typo[2] = true
								map.events[i].pages[j].list[index].parameters[0].gsub! typo[0], typo[1]
							end
						end
						index += 1
					end
				end
			end
		end
		if savemap
			puts "saving map #{n}"
			save_data(map,sprintf("Data/Map%03d.rxdata", n))
		end
	end
	for typo in typoarray
		puts "Failed to find: #{typo[0]}" if typo[2] == false 
	end

end

def eatShitAndDie
    levels = []
    for i in 0...$Trainer.party.length
        levels[i] = $Trainer.party[i].level
        $Trainer.party[i].level = 1
        $Trainer.party[i].calcStats
    end
    $game_variables[724] = levels
end

def putItBack
    for i in 0...$Trainer.party.length
        $Trainer.party[i].level = $game_variables[724][i]
        $Trainer.party[i].calcStats
    end
end

def teamtotext
    f = File.open("#{$Trainer.name} team.txt","w")
    for poke in $Trainer.party
        f.write(PBSpecies.getName(poke.species))
        f.write("\n")
        f.write(poke.poklevel)
        f.write("\n")
        f.write(PBItems.getName(poke.item))
        f.write("No item") if poke.item
        f.write("\n\n")
        for move in poke.moves
            f.write(PBMoves.getName(move.id))
            f.write("\n")
        end
        f.write("\n")
        f.write(PBAbilities.getName(poke.ability))
        f.write(",")
        f.write(PBNatures.getName(poke.nature))
        f.write(",")
        f.write(poke.form)
        f.write("\n")
        f.write("EVs: #{poke.ev}")
        f.write("\n")
        f.write("IVs: #{poke.iv}")
        f.write("\n\n\n")
    end
    f.close
end

def makeRockClimbList
	eventlist = []
	for n in 1..910
		puts n
		savemap = false
		map_name = sprintf("Data/Map%03d.rxdata", n)
		next if !(File.open(map_name,"rb") { true } rescue false)
		map = load_data(map_name)
		for i in map.events.keys.sort
			event = map.events[i]
			for j in 0...event.pages.length
				page = event.pages[j]
				list = page.list
				index = 0 
				while index < list.length - 5
					if list[index].code == 209 && list[index].parameters[1].list[0].code == 37 && list[index].parameters[1].list[1].code == 29 && list[index].parameters[1].list[2].code == 32
						puts "found rock climb"
						newlist = fixRCevent(list)
						if !newlist
							puts "false positive"
							index += 1
							next
						end
						savemap = true
						map.events[i].pages[j].list = newlist
					end
					index += 1
				end
			end
		end
		if savemap
			puts "saving map #{n}"
			save_data(map,sprintf("Data/Map%03d.rxdata", n))
		end
	end
end

def showEvent
	map = load_data("Data/Map024.rxdata")
	for index in map.events[16].pages[0].list
		array = [index.code,index.indent,index.parameters]
		puts array.inspect
	end
end

def fixRCevent(list)
	for i in 0...list.length
		#find the indices of the start and end of the relevant section
		start = i if list[i].code == 209
		stop = i if list[i].code == 115
	end
	return nil if !stop
	newlist = []
	newlist.push(RPG::EventCommand.new(111,0,[12,"Kernel.pbRockClimb"]))
	baseindent = list[start].indent
	for i in start..stop
		if list[i].indent == baseindent
			list[i].indent = 1 
		else 
			list[i].indent = 2
			puts "motherfucking piece of shit rat bastard"
		end
		newlist.push(list[i])
	end
	newlist.push(RPG::EventCommand.new(0,1,[]))
	newlist.push(RPG::EventCommand.new(412,0,[]))
	newlist.push(RPG::EventCommand.new(0,0,[]))
	return newlist
end

#put forms and shinies on the same icon file
def imageFuser
	for species in 1..807
		puts species
		forms = 0
		shiny = true
		fileexists = true
		currentform = 0
		oldfilename=pbCheckPokemonIconFiles([species, false, false, currentform,false],false)
		#check for multiple forms
		while oldfilename != fileexists
			currentform += 1
			fileexists=pbCheckPokemonIconFiles([species, false, false, currentform,false],false)
		end
		height = currentform*64
		width = 256
		combined_bitmap=Bitmap.new(width,height)
		rectangle = Rect.new(0,0,128,64)
		for i in 0...currentform
			unshiny = RPG::Cache.load_bitmap(pbCheckPokemonIconFiles([species, false, false, i,false],false))
			shiny = RPG::Cache.load_bitmap(pbCheckPokemonIconFiles([species, false, true, i,false],false))
			combined_bitmap.blt(0,i*64,unshiny,rectangle)
			combined_bitmap.blt(128,i*64,shiny,rectangle)
		end
		combined_bitmap.to_file(sprintf("icon%03d.png",species))
	end
end

#put forms and shinies on the same icon file
def imageFuserEgg
	for species in 1..807
		next if !pbResolveBitmap(sprintf("Graphics/Icons/icon%03degg",species))
		puts species
		forms = 0
		shiny = true
		fileexists = true
		currentform = 0
		oldfilename=pbCheckPokemonIconFiles([species, false, false, currentform,false],true)
		#check for multiple forms
		while oldfilename != fileexists
			currentform += 1
			fileexists=pbCheckPokemonIconFiles([species, false, false, currentform,false],true)
		end
		height = currentform*64
		width = 256
		combined_bitmap=Bitmap.new(width,height)
		rectangle = Rect.new(0,0,128,64)
		for i in 0...currentform
			unshiny = RPG::Cache.load_bitmap(pbCheckPokemonIconFiles([species, false, false, i,false],true))
			shiny = RPG::Cache.load_bitmap(pbCheckPokemonIconFiles([species, false, true, i,false],true))
			combined_bitmap.blt(0,i*64,unshiny,rectangle)
			combined_bitmap.blt(128,i*64,shiny,rectangle)
		end
		combined_bitmap.to_file(sprintf("icon%03degg.png",species))
	end
end

#put forms and shinies on the same icon file
def imageFuserGirl
	for species in 1..807
		next if !pbResolveBitmap(sprintf("Graphics/Icons/icon%03df",species))
		puts species
		forms = 0
		shiny = true
		fileexists = true
		currentform = 0
		oldfilename=pbCheckPokemonIconFiles([species, true, false, currentform,false],false)
		#check for multiple forms
		while oldfilename != fileexists
			currentform += 1
			fileexists=pbCheckPokemonIconFiles([species, true, false, currentform,false],false)
		end
		height = currentform*64
		width = 256
		combined_bitmap=Bitmap.new(width,height)
		rectangle = Rect.new(0,0,128,64)
		for i in 0...currentform
			unshiny = RPG::Cache.load_bitmap(pbCheckPokemonIconFiles([species, true, false, i,false],false))
			shiny = RPG::Cache.load_bitmap(pbCheckPokemonIconFiles([species, true, true, i,false],false))
			combined_bitmap.blt(0,i*64,unshiny,rectangle)
			combined_bitmap.blt(128,i*64,shiny,rectangle)
		end
		combined_bitmap.to_file(sprintf("icon%03df.png",species))
	end
end

#put forms and shinies on the same icon file
def imageFuserGirlEgg
	for species in 1..807
		next if !pbResolveBitmap(sprintf("Graphics/Icons/icon%03dfegg",species))
		puts species
		forms = 0
		shiny = true
		fileexists = true
		currentform = 0
		oldfilename=pbCheckPokemonIconFiles([species, true, false, currentform,false],true)
		#check for multiple forms
		while oldfilename != fileexists
			currentform += 1
			fileexists=pbCheckPokemonIconFiles([species, true, false, currentform,false],true)
		end
		height = currentform*64
		width = 256
		combined_bitmap=Bitmap.new(width,height)
		rectangle = Rect.new(0,0,128,64)
		for i in 0...currentform
			unshiny = RPG::Cache.load_bitmap(pbCheckPokemonIconFiles([species, true, false, i,false],true))
			shiny = RPG::Cache.load_bitmap(pbCheckPokemonIconFiles([species, true, true, i,false],true))
			combined_bitmap.blt(0,i*64,unshiny,rectangle)
			combined_bitmap.blt(128,i*64,shiny,rectangle)
		end
		combined_bitmap.to_file(sprintf("icon%03dfegg.png",species))
	end
end

#put forms and shinies on the same icon file
def battlerFuser
	for species in 1..807
		puts species
		currentform = 0
		if currentform!=0
			formnumber = "_"+currentform.to_s
		else
			formnumber=""
		end
		bitmapFileName=sprintf("Battlers/%03d%s",species,formnumber)
		#check for multiple forms
		while pbResolveBitmap(bitmapFileName)
			currentform += 1
			formnumber = "_"+currentform.to_s
			bitmapFileName=sprintf("Battlers/%03d%s",species,formnumber)
		end
		height = currentform*384
		width = 384
		combined_bitmap=Bitmap.new(width,height)
		rectangle = Rect.new(0,0,192,192)
		for i in 0...currentform
			if i!=0
				formnumber = "_"+i.to_s
			else
				formnumber=""
			end
			j = 0
			for file in ["%03d%s","%03ds%s","%03db%s","%03dsb%s"]
				filename = sprintf("Battlers/#{file}",species,formnumber)
				if !pbResolveBitmap(filename)
					j+=1
					next
				end
				bitmap = RPG::Cache.load_bitmap(filename)
				height = [192-bitmap.height,0].max
				width = [96-bitmap.width/2,0].max
				case j%4
				when 0 then combined_bitmap.blt(width,i*384+height,bitmap,rectangle)
				when 1 then combined_bitmap.blt(192+width,i*384+height,bitmap,rectangle)
				when 2 then combined_bitmap.blt(width,i*384+192+height,bitmap,rectangle)
				when 3 then combined_bitmap.blt(192+width,i*384+192+height,bitmap,rectangle)
				end
				j+=1
			end
		end
		combined_bitmap.to_file(sprintf("%03d.png",species))
	end
end

def eggFuser
	for species in 1..807
		bitmapFileName=sprintf("Battlers/%03dEgg",species)
		next if !pbResolveBitmap(bitmapFileName)
		puts species
		currentform = 0
		if currentform!=0
			formnumber = "_"+currentform.to_s
		else
			formnumber=""
		end
		bitmapFileName=sprintf("Battlers/%03dEgg%s",species,formnumber)
		bitmapFuckName=""
		#check for multiple forms
		while pbResolveBitmap(bitmapFileName) || pbResolveBitmap(bitmapFuckName)
			currentform += 1
			formnumber = "_"+currentform.to_s
			bitmapFileName=sprintf("Battlers/%03dEgg%s",species,formnumber)
			bitmapFuckName=sprintf("Battlers/%03d%sEgg",species,formnumber)
		end
		height = currentform*64
		width = 128
		combined_bitmap=Bitmap.new(width,height)
		rectangle = Rect.new(48,48,64,64)
		for i in 0...currentform
			if i!=0
				formnumber = "_"+i.to_s
			else
				formnumber=""
			end
			filename=sprintf("Battlers/%03dEgg%s",species,formnumber)
			filename=sprintf("Battlers/%03d%sEgg",species,formnumber) if !pbResolveBitmap(filename)
			unshiny = RPG::Cache.load_bitmap(filename)
			combined_bitmap.blt(0,i*64,unshiny,rectangle)
			filename=sprintf("Battlers/%03dsEgg%s",species,formnumber)
			if !pbResolveBitmap(filename)
				puts "OOOOOOOOOH SMEARGLE MISSED #{species}"
			else
				shiny = RPG::Cache.load_bitmap(filename)
				combined_bitmap.blt(64,i*64,shiny,rectangle)
			end
		end
		combined_bitmap.to_file(sprintf("%03dEgg.png",species))
	end
end

def battlerFuserGirl
	for species in 1..807
		puts species
		currentform = 0
		if currentform!=0
			formnumber = "_"+currentform.to_s
		else
			formnumber=""
		end
		bitmapFileName=sprintf("Battlers/%03df%s",species,formnumber)
		next if !pbResolveBitmap(bitmapFileName)
		#check for multiple forms
		while pbResolveBitmap(bitmapFileName)
			currentform += 1
			formnumber = "_"+currentform.to_s
			bitmapFileName=sprintf("Battlers/%03df%s",species,formnumber)
		end
		height = currentform*384
		width = 384
		combined_bitmap=Bitmap.new(width,height)
		rectangle = Rect.new(0,0,192,192)
		for i in 0...currentform
			if i!=0
				formnumber = "_"+i.to_s
			else
				formnumber=""
			end
			j = 0
			for file in ["%03df%s","%03dfs%s","%03dfb%s","%03dfsb%s"]
				filename = sprintf("Battlers/#{file}",species,formnumber)
				if !pbResolveBitmap(filename)
					j+=1
					next
				end
				bitmap = RPG::Cache.load_bitmap(filename)
				height = [96-bitmap.width/2,0].max
				width = [96-bitmap.width/2,0].max
				case j%4
				when 0 then combined_bitmap.blt(width,i*384+height,bitmap,rectangle)
				when 1 then combined_bitmap.blt(192+width,i*384+height,bitmap,rectangle)
				when 2 then combined_bitmap.blt(width,i*384+192+height,bitmap,rectangle)
				when 3 then combined_bitmap.blt(192+width,i*384+192+height,bitmap,rectangle)
				end
				j+=1
			end
		end
		combined_bitmap.to_file(sprintf("%03df.png",species))
	end
end

def eggFuserGirl
	for species in 1..807
		bitmapFileName=sprintf("Battlers/%03dfEgg",species)
		next if !pbResolveBitmap(bitmapFileName)
		puts species
		currentform = 0
		if currentform!=0
			formnumber = "_"+currentform.to_s
		else
			formnumber=""
		end
		bitmapFileName=sprintf("Battlers/%03dfEgg%s",species,formnumber)
		#check for multiple forms
		while pbResolveBitmap(bitmapFileName)
			currentform += 1
			formnumber = "_"+currentform.to_s
			bitmapFileName=sprintf("Battlers/%03dfEgg%s",species,formnumber)
		end
		height = currentform*64
		width = 128
		combined_bitmap=Bitmap.new(width,height)
		rectangle = Rect.new(48,48,64,64)
		for i in 0...currentform
			if i!=0
				formnumber = "_"+i.to_s
			else
				formnumber=""
			end
			filename=sprintf("Battlers/%03dfEgg%s",species,formnumber)
			next if !pbResolveBitmap(filename)
			unshiny = RPG::Cache.load_bitmap(filename)
			combined_bitmap.blt(0,i*64,unshiny,rectangle)
			filename=sprintf("Battlers/%03dfsEgg%s",species,formnumber)
			if !pbResolveBitmap(filename)
				puts "OOOOOOOOOH SMEARGLE MISSED #{species}"
			else
				shiny = RPG::Cache.load_bitmap(filename)
				combined_bitmap.blt(64,i*64,shiny,rectangle)
			end
		end
		combined_bitmap.to_file(sprintf("%03dfEgg.png",species))
	end
end

def makeicons
	imageFuser
	imageFuserEgg
	imageFuserGirl
	imageFuserGirlEgg
end

def makebattlers
	battlerFuser
	eggFuser
	battlerFuserGirl
	eggFuserGirl
end

def dumpDataHashes
	itemDump
	moveDump
	encDump
	abilDump
	metaDump
	trainTypesDump
	monDump
end

def abilDump
	exporttext = "ABILHASH = {\n"
	for i in 1...234
		exporttext += ":#{getConstantName(PBAbilities,i)} => {\n"
		exporttext += "\t:ID => #{i},\n"
		exporttext += "\t:name => \"#{pbGetMessage(MessageTypes::Abilities,i)}\",\n"
		exporttext += "\t:desc => \"#{pbGetMessage(MessageTypes::AbilityDescs,i)}\"\n"
		exporttext += "},\n\n"
	end
	exporttext += "}"
	File.open("Scripts/Reborn/abiltext.rb","w"){|f|
		f.write(exporttext)
	}
end

def metaDump
	metadata = $cache.metadata
	exporttext = "METAHASH = {\n"
	exporttext += ":home => #{metadata[0][1].inspect},\n"
	exporttext += ":TrainerVictory => \"#{metadata[0][5]}\",\n"
	exporttext += ":WildVictory => \"#{metadata[0][4]}\",\n"
	exporttext += ":TrainerBattle => \"#{metadata[0][3]}\",\n"
	exporttext += ":WildBattle => \"#{metadata[0][2]}\",\n"
	exporttext += ":Surf => \"#{metadata[0][6]}\",\n"
	exporttext += ":Bicycle => \"#{metadata[0][7]}\",\n\n"
	for i in 8...$cache.metadata[0].length
		exporttext += ":player#{i-7} => {\n"
		exporttext += "\t:tclass => :#{getConstantName(PBTrainers,metadata[0][i][0])},\n"
		exporttext += "\t#sprites,\n"
		exporttext += "\t:walk => \"#{metadata[0][i][1]}\",\n" if metadata[0][i][1] != ""
		exporttext += "\t:run => \"#{metadata[0][i][4]}\",\n" if metadata[0][i][4] != ""
		exporttext += "\t:bike => \"#{metadata[0][i][2]}\",\n" if metadata[0][i][2] != ""
		exporttext += "\t:surf => \"#{metadata[0][i][3]}\",\n" if metadata[0][i][3] != ""
		exporttext += "\t:dive => \"#{metadata[0][i][5]}\",\n" if metadata[0][i][5] != ""
		exporttext += "\t:fishing => \"#{metadata[0][i][6]}\",\n" if metadata[0][i][6] != ""
		exporttext += "\t:surffish => \"#{metadata[0][i][7]}\",\n" if metadata[0][i][7] != ""
		exporttext += "},\n\n"
	end
	for i in 1...$cache.metadata.length
		next if metadata[i].nil?
		exporttext += "\##{$cache.mapinfos[i].name}\n"
		exporttext += "#{i} => { \n"
		exporttext += "\t:Outdoor => #{metadata[i][MetadataOutdoor]},\n" if metadata[i][MetadataOutdoor]
		exporttext += "\t:ShowArea => #{metadata[i][MetadataShowArea]},\n" if metadata[i][MetadataShowArea]
		exporttext += "\t:Bicycle => #{metadata[i][MetadataBicycle]},\n" if metadata[i][MetadataBicycle]
		exporttext += "\t:BicycleAlways => #{metadata[i][MetadataBicycleAlways]},\n" if metadata[i][MetadataBicycleAlways]
		exporttext += "\t:HealingSpot => #{metadata[i][MetadataHealingSpot].inspect},\n" if metadata[i][MetadataHealingSpot]
		exporttext += "\t:Weather => #{metadata[i][MetadataWeather]},\n" if metadata[i][MetadataWeather]
		exporttext += "\t:MapPosition => #{metadata[i][MetadataMapPosition].inspect},\n" if metadata[i][MetadataMapPosition]
		exporttext += "\t:DiveMap => #{metadata[i][MetadataDiveMap]},\n" if metadata[i][MetadataDiveMap]
		exporttext += "\t:DarkMap => #{metadata[i][MetadataDarkMap]},\n" if metadata[i][MetadataDarkMap]
		exporttext += "\t:SafariMap => #{metadata[i][MetadataSafariMap]},\n" if metadata[i][MetadataSafariMap]
		exporttext += "\t:SnapEdges => #{metadata[i][MetadataSnapEdges]},\n" if metadata[i][MetadataSnapEdges]
		exporttext += "\t:Dungeon => #{metadata[i][MetadataDungeon]},\n" if metadata[i][MetadataDungeon]
		exporttext += "\t:BattleBack => \"#{metadata[i][MetadataBattleBack]}\",\n" if metadata[i][MetadataBattleBack]
		exporttext += "\t:WildBattleBGM => \"#{metadata[i][MetadataMapWildBattleBGM]}\",\n" if metadata[i][MetadataMapWildBattleBGM]
		exporttext += "\t:TrainerBattleBGM => \"#{metadata[i][MetadataMapTrainerBattleBGM]}\",\n" if metadata[i][MetadataMapTrainerBattleBGM]
		exporttext += "\t:WildVictoryME => \"#{metadata[i][MetadataMapWildVictoryME]}\",\n" if metadata[i][MetadataMapWildVictoryME]
		exporttext += "\t:TrainerVictoryME => \"#{metadata[i][MetadataMapTrainerVictoryME]}\",\n" if metadata[i][MetadataMapTrainerVictoryME]
		exporttext += "\t:MapSize => #{metadata[i][MetadataMapSize]},\n" if metadata[i][MetadataMapSize]
		exporttext += "},\n\n"
	end
	exporttext += "}"
	File.open("Scripts/Reborn/metatext.rb","w"){|f|
		f.write(exporttext)
	}
end

def trainTypesDump
	exporttext = "TTYPEHASH = {\n"
	for ttype in $cache.trainertypes
		next if ttype.empty?
		exporttext += ":#{getConstantName(PBTrainers,ttype[0])} => {\n"
		exporttext += "\t:ID => #{ttype[0]},\n"
		exporttext += "\t:title => \"#{ttype[2]}\",\n"
		exporttext += "\t:skill => #{ttype[8]},\n"
		exporttext += "\t:moneymult => #{ttype[3]},\n" if ttype[3] != 0
		exporttext += "\t:battleBGM => \"#{ttype[4]}\",\n" if ttype[4]
		exporttext += "\t:winBGM => \"#{ttype[5]}\",\n" if ttype[5]
		exporttext += "},\n\n"
	end
	exporttext += "}"
	File.open("Scripts/Reborn/ttypetext.rb","w"){|f|
		f.write(exporttext)
	}
end

def itemDump
	exporttext = "ITEMHASH = {\n"
	for item in $cache.items
		next if item.nil? || item.empty?
		exporttext += ":#{getConstantName(PBItems,item[ITEMID])} => {\n"
		exporttext += "\t:ID => #{item[ITEMID]},\n"
		exporttext += "\t:name => \"#{item[ITEMNAME]}\",\n"
		exporttext += "\t:pocket => #{item[ITEMPOCKET]},\n"
		exporttext += "\t:price => #{item[ITEMPRICE]},\n"
		exporttext += "\t:desc => \"#{item[ITEMDESC]}\",\n"
		exporttext += "\t:use => #{item[ITEMUSE]},\n"
		exporttext += "\t:battleuse => #{item[ITEMBATTLEUSE]},\n"
		exporttext += "\t:type => #{item[ITEMTYPE]},\n"
		exporttext += "\t:machine => #{item[ITEMMACHINE]}\n"
		exporttext += "},\n\n"
	end
	exporttext += "}"
	File.open("Scripts/Reborn/itemtext.rb","w"){|f|
		f.write(exporttext)
	}
end

def monDump
	exporttext = "MONHASH = {\n"
	for i in 1..807 
		mon = $cache.pkmn_dex[i]
		next if mon.empty?
		exporttext += ":#{getConstantName(PBSpecies,mon[:ID])} => {\n"
		exporttext += "\t:name => \"#{pbGetMessage(MessageTypes::Species,mon[:ID])}\",\n"
		exporttext += "\t:dexnum => #{mon[:ID]},\n"
		exporttext += "\t:Type1 => :#{getConstantName(PBTypes,mon[:Type1]).to_s},\n"
		exporttext += "\t:Type2 => :#{getConstantName(PBTypes,mon[:Type2]).to_s},\n" if mon[:Type1] != mon[:Type2]
		exporttext += "\t:BaseStats => #{mon[:BaseStats].inspect},\n"
		exporttext += "\t:EVs => #{mon[:EVs].inspect},\n"
		exporttext += "\t:Abilities => ["
		check = 1
		for abil in mon[:Abilities]
			exporttext += ":#{getConstantName(PBAbilities,abil).to_s}"
			exporttext += "," if check != mon[:Abilities].length
			check += 1
		end
		exporttext += "],\n"
		exporttext += "\t:HiddenAbilities => :#{getConstantName(PBAbilities,mon[:HiddenAbilities]).to_s},\n" if mon[:HiddenAbilities] != 0
		case mon[:GrowthRate]
			when 0 then exporttext += "\t:GrowthRate => \"MediumFast\",\n"
			when 1 then exporttext += "\t:GrowthRate => \"Erratic\",\n"
			when 2 then exporttext += "\t:GrowthRate => \"Fluctuating\",\n"
			when 3 then exporttext += "\t:GrowthRate => \"MediumSlow\",\n"
			when 4 then exporttext += "\t:GrowthRate => \"Fast\",\n"
			when 5 then exporttext += "\t:GrowthRate => \"Slow\",\n"
		end
		case mon[:GenderRatio]
			when 0 then exporttext += "\t:GenderRatio => \"FemZero\",\n"
			when 31 then exporttext += "\t:GenderRatio => \"FemEighth\",\n"
			when 63 then exporttext += "\t:GenderRatio => \"FemQuarter\",\n"
			when 127 then exporttext += "\t:GenderRatio => \"FemHalf\",\n"
			when 191 then exporttext += "\t:GenderRatio => \"MaleQuarter\",\n"
			when 223 then exporttext += "\t:GenderRatio => \"MaleEighth\",\n"
			when 254 then exporttext += "\t:GenderRatio => \"MaleNever\",\n"
			when 255 then exporttext += "\t:GenderRatio => \"Genderless\",\n"
		end
		exporttext += "\t:BaseEXP => #{mon[:BaseEXP]},\n"
		exporttext += "\t:CatchRate => #{mon[:CatchRate]},\n"
		exporttext += "\t:Happiness => #{mon[:Happiness]},\n"
		exporttext += "\t:EggSteps => #{mon[:EggSteps]},\n"
		if $cache.pkmn_egg[mon[:ID]]
			check = 1
			exporttext += "\t:EggMoves => ["
			for move in $cache.pkmn_egg[mon[:ID]]
				exporttext += ":#{getConstantName(PBMoves,move)}"
				exporttext += "," if check != $cache.pkmn_egg[mon[:ID]].length
				check += 1
			end
			exporttext += "],\n"
		end
		if $cache.pkmn_moves[mon[:ID]]
			check = 1
			exporttext += "\t:Moveset => [\n"
			for move in $cache.pkmn_moves[mon[:ID]]
				exporttext += "\t\t[#{move[0]},:#{getConstantName(PBMoves,move[1])}]"
				exporttext += ",\n" if check != $cache.pkmn_moves[mon[:ID]].length
				check += 1
			end
			exporttext += "],\n"
		end
		exporttext += "\t:tmlist => ["
		for j in 0...$cache.tm_data.length
			move = $cache.tm_data[j]
			next if move.nil?
			next if !move.include?(i)
			next if cassTMFormCheck(i,j) == false
			exporttext += ":#{getConstantName(PBMoves,j)},"
		end
		exporttext += "],\n"
		case mon[:Color]
			when 0 then exporttext += "\t:Color => \"Red\",\n"
			when 1 then exporttext += "\t:Color => \"Blue\",\n"
			when 2 then exporttext += "\t:Color => \"Yellow\",\n"
			when 3 then exporttext += "\t:Color => \"Green\",\n"
			when 4 then exporttext += "\t:Color => \"Black\",\n"
			when 5 then exporttext += "\t:Color => \"Brown\",\n"
			when 6 then exporttext += "\t:Color => \"Purple\",\n"
			when 7 then exporttext += "\t:Color => \"Gray\",\n"
			when 8 then exporttext += "\t:Color => \"White\",\n"
			when 9 then exporttext += "\t:Color => \"Pink\",\n"
		end
		case mon[:Habitat]
			when 1 then exporttext += "\t:Habitat => \"Grassland\",\n"
			when 2 then exporttext += "\t:Habitat => \"Forest\",\n"
			when 3 then exporttext += "\t:Habitat => \"WatersEdge\",\n"
			when 4 then exporttext += "\t:Habitat => \"Sea\",\n"
			when 5 then exporttext += "\t:Habitat => \"Cave\",\n"
			when 6 then exporttext += "\t:Habitat => \"Mountain\",\n"
			when 7 then exporttext += "\t:Habitat => \"RoughTerrain\",\n"
			when 8 then exporttext += "\t:Habitat => \"Urban\",\n"
			when 9 then exporttext += "\t:Habitat => \"Rare\",\n"
		end
		exporttext += "\t:EggGroups => ["
		check = 1
		for group in mon[:EggGroups]
			case group
				when 1 then exporttext += ":Monster"
				when 2 then exporttext += ":Water1"
				when 3 then exporttext += ":Bug"
				when 4 then exporttext += ":Flying"
				when 5 then exporttext += ":Field"
				when 6 then exporttext += ":Fairy"
				when 7 then exporttext += ":Grass"
				when 8 then exporttext += ":HumanLike"
				when 9 then exporttext += ":Water3"
				when 10 then exporttext += ":Mineral"
				when 11 then exporttext += ":Amorphous"
				when 12 then exporttext += ":Water2"
				when 14 then exporttext += ":Dragon"
				when 15 then exporttext += ":Undiscovered"
			end
			exporttext += "," if check != mon[:EggGroups].length
			check += 1
		end
		exporttext += "],\n"
		exporttext += "\t:Height => #{mon[:Height]},\n"
		exporttext += "\t:Weight => #{mon[:Weight]},\n"
		exporttext += "\t:WildItemCommon => :#{getConstantName(PBItems,mon[:WildItemCommon])},\n" if mon[:WildItemCommon] != 0
		exporttext += "\t:WildItemUncommon => :#{getConstantName(PBItems,mon[:WildItemUncommon])},\n" if mon[:WildItemUncommon] != 0
		exporttext += "\t:WildItemRare => :#{getConstantName(PBItems,mon[:WildItemRare])},\n" if mon[:WildItemRare] != 0
		exporttext += "\t:kind => \"#{pbGetMessage(MessageTypes::Kinds,mon[:ID])}\",\n"
		exporttext += "\t:dexentry => \"#{pbGetMessage(MessageTypes::Entries,mon[:ID])}\",\n"
		exporttext += "\t:BattlerPlayerY => #{$cache.pkmn_metrics[0][mon[:ID]]},\n"
		exporttext += "\t:BattlerEnemyY => #{$cache.pkmn_metrics[1][mon[:ID]]},\n"
		exporttext += "\t:BattlerAltitude => #{$cache.pkmn_metrics[2][mon[:ID]]},\n"
		if !$cache.pkmn_evo[mon[:ID]].empty?
			check = 1
			exporttext += "\t:evolutions => [\n"
			for evo in $cache.pkmn_evo[mon[:ID]]
				exporttext += "\t\t[:#{getConstantName(PBSpecies,evo[0]).to_s},:#{getConstantName(PBEvolution,evo[1]).to_s}"
				case evo[1]
				when PBEvolution::Item,PBEvolution::ItemMale,PBEvolution::ItemFemale,PBEvolution::TradeItem,PBEvolution::DayHoldItem,PBEvolution::NightHoldItem
					exporttext += ",:#{getConstantName(PBItems,evo[2]).to_s}"
				else
					exporttext += ",#{evo[2]}" if evo[2]
				end
				exporttext += "],\n" if check != $cache.pkmn_evo[mon[:ID]].length
				exporttext += "]\n" if check == $cache.pkmn_evo[mon[:ID]].length
				check += 1
			end
			exporttext += "\t]\n"
		end
		exporttext += "},\n\n"
		System.set_window_title("Line #{i}")
	end
	exporttext += "}"
	File.open("Scripts/Reborn/montext.rb","w"){|f|
		f.write(exporttext)
	}
end

def moveDump
	exporttext = "MOVEHASH = {\n"
	for i in 1...$cache.pkmn_move.length
		move = $cache.pkmn_move[i]
		exporttext += ":#{getConstantName(PBMoves,i)} => {\n"
		exporttext += "\t:ID => #{i},\n"
		exporttext += "\t:name => \"#{pbGetMessage(MessageTypes::Moves,i)}\",\n"
		exporttext += sprintf("\t:function => 0x%03X,\n",move[PBMoveData::FUNCTION])
		exporttext += "\t:type => :#{getConstantName(PBTypes,move[PBMoveData::TYPE]).to_s},\n"
		case move[PBMoveData::CATEGORY]
			when 0 then exporttext += "\t:category => :physical,\n"
			when 1 then exporttext += "\t:category => :special,\n"
			when 2 then exporttext += "\t:category => :status,\n"
		end
		exporttext += "\t:basedamage => #{move[PBMoveData::BASEDAMAGE]},\n"
		exporttext += "\t:accuracy => #{move[PBMoveData::ACCURACY]},\n"
		exporttext += "\t:maxpp => #{move[PBMoveData::TOTALPP]},\n"
		exporttext += "\t:effect => #{move[PBMoveData::ADDLEFFECT]},\n" if move[PBMoveData::ADDLEFFECT] != 0
		case move[PBMoveData::TARGET]
			when 0x00	then exporttext += "\t:target => :SingleNonUser,\n"
			when 0x01	then exporttext += "\t:target => :NoTarget,\n"
			when 0x02	then exporttext += "\t:target => :RandomOpposing,\n"
			when 0x04	then exporttext += "\t:target => :AllOpposing,\n"
			when 0x08	then exporttext += "\t:target => :AllNonUsers,\n"
			when 0x10	then exporttext += "\t:target => :User,\n"
			when 0x20	then exporttext += "\t:target => :UserSide,\n"
			when 0x40	then exporttext += "\t:target => :BothSides,\n"
			when 0x80	then exporttext += "\t:target => :OpposingSide,\n"
			when 0x100	then exporttext += "\t:target => :Partner,\n"
			when 0x200	then exporttext += "\t:target => :UserOrPartner,\n"
			when 0x400	then exporttext += "\t:target => :SingleOpposing,\n"
			when 0x800	then exporttext += "\t:target => :OppositeOpposing,\n"
			when 0x1000	then exporttext += "\t:target => :DragonDarts,\n"
		end
		exporttext += "\t:priority => #{move[PBMoveData::PRIORITY]},\n" if move[PBMoveData::PRIORITY] != 0
		exporttext += "\t:contact => true,\n" if move[PBMoveData::FLAGS] & 0x01 != 0
		exporttext += "\t:bypassprotect => true,\n" if move[PBMoveData::FLAGS] & 0x02 == 0 && move[PBMoveData::CATEGORY] != 2
		exporttext += "\t:magiccoat => true,\n" if move[PBMoveData::FLAGS] & 0x04 != 0
		exporttext += "\t:snatchable => true,\n" if move[PBMoveData::FLAGS] & 0x08 != 0
		exporttext += "\t:nonmirror => true,\n" if move[PBMoveData::FLAGS] & 0x10 == 0
		exporttext += "\t:kingrock => true,\n" if move[PBMoveData::FLAGS] & 0x20 != 0
		exporttext += "\t:defrost => true,\n" if move[PBMoveData::FLAGS] & 0x40 != 0
		exporttext += "\t:highcrit => true,\n" if move[PBMoveData::FLAGS] & 0x80 != 0
		exporttext += "\t:healingmove => true,\n" if move[PBMoveData::FLAGS] & 0x100 != 0
		exporttext += "\t:punchmove => true,\n" if move[PBMoveData::FLAGS] & 0x200 != 0
		exporttext += "\t:soundmove => true,\n" if move[PBMoveData::FLAGS] & 0x400 != 0
		exporttext += "\t:gravityblocked => true,\n" if move[PBMoveData::FLAGS] & 0x800 != 0
		exporttext += "\t:beammove => true,\n" if move[PBMoveData::FLAGS] & 0x2000 != 0
		exporttext += "\t:desc => \"#{pbGetMessage(MessageTypes::MoveDescriptions,i)}\"\n"
		exporttext += "},\n\n"
		puts "Protectable status move: #{pbGetMessage(MessageTypes::Moves,i)}" if move[PBMoveData::FLAGS] & 0x02 != 0 && move[PBMoveData::CATEGORY] == 2
	end
	exporttext += "}"
	File.open("Scripts/Reborn/movetext.rb","w"){|f|
		f.write(exporttext)
	}
end

def encDump
	enctypeChances=[
		[20,15,12,10,10,10,5,5,5,4,2,2],
		[20,15,12,10,10,10,5,5,5,4,2,2],
		[50,25,15,7,3],
		[50,25,15,7,3],
		[70,30],
		[60,20,20],
		[40,35,15,7,3],
		[30,25,20,10,5,5,4,1],
		[30,25,20,10,5,5,4,1],
		[20,15,12,10,10,10,5,5,5,4,2,2],
		[20,15,12,10,10,10,5,5,5,4,2,2],
		[20,15,12,10,10,10,5,5,5,4,2,2],
		[20,15,12,10,10,10,5,5,5,4,2,2]
	 ]
	exporttext = "ENCHASH = {\n"
	$cache.encounters.each{|id, map|
		exporttext += "#{id} => { \##{$cache.mapinfos[id].name}\n"
		exporttext += "\t:landrate => #{map[0][0]},\n" if map[0][0] != 0
		exporttext += "\t:caverate => #{map[0][1]},\n" if map[0][1] != 0
		exporttext += "\t:waterrate => #{map[0][2]},\n" if map[0][2] != 0
		encounterdata = map[1]
		for enc in 0...encounterdata.length
			sectiontext = ""
			next if !encounterdata[enc] 
			case enc
				when 0 then exporttext += "\t:Land => {\n"
				when 1 then exporttext += "\t:Cave => {\n"
				when 2 then exporttext += "\t:Water => {\n"
				when 3 then exporttext += "\t:RockSmash => {\n"
				when 4 then exporttext += "\t:OldRod => {\n"
				when 5 then exporttext += "\t:GoodRod => {\n"
				when 6 then exporttext += "\t:SuperRod => {\n"
				when 7 then exporttext += "\t:Headbutt => {\n"
				when 8 then next
			    when 9 then sectiontext = "\t:LandMorning => {\n"
			    when 10 then sectiontext = "\t:LandDay => {\n"
				when 11 then sectiontext = "\t:LandNight => {\n"
			end
			if [9,10,11].include?(enc) #skip this section if it's no different than the standard land encounters
				next if encounterdata[0] == encounterdata[enc]
				exporttext += sectiontext
			end
			#now get the mons with their weight, species, and level range
			for index in 0...encounterdata[enc].length
				monname = getConstantName(PBSpecies,encounterdata[enc][index][0])
				exporttext += "\t\t:#{monname} => [#{enctypeChances[enc][index]},#{encounterdata[enc][index][1]},#{encounterdata[enc][index][2]}]"
				if index != encounterdata[enc].length-1
					exporttext += ","
				end
				exporttext += "\n"
			end
			exporttext += "\t},\n"
		end
		exporttext += "},\n"
	}
	exporttext += "}"
	File.open("Scripts/Reborn/enctext.rb","w"){|f|
		f.write(exporttext)
	}
end

def mapPicture
	mapdisplay=Sprite.new
	mapdisplay.x=20
	mapdisplay.y=20
	mapdisplay.z=100000
	mapdisplay.bitmap=createMinimap3($game_map.map_id,$game_player.x,$game_player.y)
	mapdisplay.visible=true
end

def createMinimap3(mapid,eventx,eventy)
	map=load_data(sprintf("Data/Map%03d.rxdata",mapid)) rescue nil
	bitmap=BitmapWrapper.new(240,240)
	black=Color.new(0,0,0)
	tilesets=load_data("Data/Tilesets.rxdata")
	tileset=tilesets[map.tileset_id]
	return bitmap if !tileset
	helper=TileDrawingHelper.fromTileset(tileset)
	ymin = [0,eventy-15].max
	ymax = [map.height,eventy+15].min
	xmin = [0,eventx-15].max
	xmax = [map.width,eventx+15].min
	for y in ymin...ymax
	  for x in xmin...xmax
		for z in 0..2
		  id=map.data[x,y,z]
		  id=0 if !id
		  helper.bltSmallTile(bitmap,(x-xmin)*8,(y-ymin)*8,32,32,id)
		end
	  end
	end
	bitmap.fill_rect(0,0,bitmap.width,1,black)
	bitmap.fill_rect(0,bitmap.height-1,bitmap.width,1,black)
	bitmap.fill_rect(0,0,1,bitmap.height,black)
	bitmap.fill_rect(bitmap.width-1,0,1,bitmap.height,black)
	return bitmap
end

def relvarDump
	output = ""
	varnums = (279..289).to_a + [277,745,746] + (294..315).to_a
	for value in varnums
		output += "#{$cache.RXsystem.variables[value]},#{$game_variables[value]}\n"
	end
	File.open("relationships.csv","w"){|f|
		f.write(output)
	}
end

def cassTMFormCheck(species,move)  
	case species
	  when PBSpecies::RATTATA #Rattata
		if (move == PBMoves::SLUDGEBOMB) || (move == PBMoves::TORMENT) ||
			(move == PBMoves::QUASH) || (move == PBMoves::EMBARGO) ||
			(move == PBMoves::SHADOWCLAW) || (move == PBMoves::SNARL) ||
			(move == PBMoves::DARKPULSE) || (move == PBMoves::SNATCH)
			return false
		end
		if (move == PBMoves::WORKUP) || (move == PBMoves::THUNDERBOLT) ||
			(move == PBMoves::THUNDER) || (move == PBMoves::CHARGEBEAM) ||
			(move == PBMoves::THUNDERWAVE) || (move == PBMoves::WILDCHARGE)
			return true
		end 
	  when PBSpecies::RATICATE #Raticate
		  if (move == PBMoves::SLUDGEBOMB) || (move == PBMoves::TORMENT) ||
			(move == PBMoves::QUASH) || (move == PBMoves::EMBARGO) ||
			(move == PBMoves::SHADOWCLAW) || (move == PBMoves::SNARL) ||
			(move == PBMoves::DARKPULSE) || (move == PBMoves::BULKUP) ||
			(move == PBMoves::VENOSHOCK) || (move == PBMoves::SLUDGEWAVE) || 
			(move == PBMoves::SNATCH) || (move == PBMoves::KNOCKOFF)
			return false
		  end
		  if (move == PBMoves::WORKUP) || (move == PBMoves::THUNDERBOLT) ||
			(move == PBMoves::THUNDER) || (move == PBMoves::CHARGEBEAM) ||
			(move == PBMoves::THUNDERWAVE) || (move == PBMoves::WILDCHARGE)
			return true
		  end 
	  when PBSpecies::RAICHU #Raichu
		  if (move == PBMoves::PSYSHOCK) || (move == PBMoves::CALMMIND) ||
			(move == PBMoves::SAFEGUARD) || (move == PBMoves::PSYCHIC) ||
			(move == PBMoves::REFLECT) || (move == PBMoves::MAGICCOAT) ||
			(move == PBMoves::MAGICROOM) || (move == PBMoves::RECYCLE) ||
			(move == PBMoves::TELEKINESIS) || (move == PBMoves::ALLYSWITCH)
			return false
		  end
	  when PBSpecies::SANDSHREW #Sandshrew
		  if (move == PBMoves::WORKUP) || (move == PBMoves::HAIL) ||
			(move == PBMoves::BLIZZARD) || (move == PBMoves::LEECHLIFE) ||
			(move == PBMoves::FROSTBREATH) || (move == PBMoves::IRONHEAD) ||
			(move == PBMoves::ICEPUNCH) || (move == PBMoves::IRONDEFENSE) ||
			(move == PBMoves::ICYWIND) || (move == PBMoves::AQUATAIL) ||
			(move == PBMoves::THROATCHOP)
			return false
		  end
		  if (move == PBMoves::SANDSTORM) || (move == PBMoves::ROCKTOMB) ||
			(move == PBMoves::EARTHPOWER) || (move == PBMoves::STOMPINGTANTRUM)
			return true
		  end  
	  when PBSpecies::SANDSLASH #Sandslash
		  if (move == PBMoves::WORKUP) || (move == PBMoves::HAIL) ||
			(move == PBMoves::BLIZZARD) || (move == PBMoves::LEECHLIFE) ||
			(move == PBMoves::AURORAVEIL) || (move == PBMoves::FROSTBREATH) ||
			(move == PBMoves::IRONHEAD) || (move == PBMoves::THROATCHOP) ||
			(move == PBMoves::ICEPUNCH) || (move == PBMoves::IRONDEFENSE) ||
			(move == PBMoves::ICYWIND) || (move == PBMoves::AQUATAIL)          
			return false
		  end
		  if (move == PBMoves::SANDSTORM) || (move == PBMoves::ROCKTOMB) ||
			(move == PBMoves::STONEEDGE) ||
			(move == PBMoves::EARTHPOWER) || (move == PBMoves::STOMPINGTANTRUM)
			return true
		  end  
	  when PBSpecies::VULPIX #Vulpix
		  if (move == PBMoves::HAIL) || (move == PBMoves::ICEBEAM) ||
			(move == PBMoves::BLIZZARD) || (move == PBMoves::RAINDANCE) ||
			(move == PBMoves::AURORAVEIL) || (move == PBMoves::FROSTBREATH) ||
			(move == PBMoves::ICYWIND) || (move == PBMoves::AQUATAIL) || 
			(move == PBMoves::HEALBELL)
			return false
		  end
		  if (move == PBMoves::SUNNYDAY) || (move == PBMoves::FLAMETHROWER) ||
			(move == PBMoves::FIREBLAST) || (move == PBMoves::FLAMECHARGE) ||
			(move == PBMoves::OVERHEAT) || (move == PBMoves::ENERGYBALL) ||
			(move == PBMoves::WILLOWISP) ||
			(move == PBMoves::HEATWAVE) 
			return true
		  end  
	  when PBSpecies::NINETALES #Ninetales
		  if (move == PBMoves::HAIL) || (move == PBMoves::ICEBEAM) ||
			(move == PBMoves::BLIZZARD) || (move == PBMoves::RAINDANCE) ||
			(move == PBMoves::AURORAVEIL) || (move == PBMoves::FROSTBREATH) ||
			(move == PBMoves::DAZZLINGGLEAM) || (move == PBMoves::ICYWIND) || 
			(move == PBMoves::AQUATAIL) || (move == PBMoves::WONDERROOM) ||
			(move == PBMoves::HEALBELL)
			return false
		  end
		  if (move == PBMoves::SUNNYDAY) || (move == PBMoves::FLAMETHROWER) ||
			(move == PBMoves::FIREBLAST) || (move == PBMoves::FLAMECHARGE) ||
			(move == PBMoves::OVERHEAT) || (move == PBMoves::ENERGYBALL) ||
			(move == PBMoves::WILLOWISP) || (move == PBMoves::SOLARBEAM) ||
			(move == PBMoves::HEATWAVE) 
			return false
		  end  
	  when PBSpecies::DIGLETT #Diglett
		  if (move == PBMoves::WORKUP) || (move == PBMoves::FLASHCANNON) ||
			(move == PBMoves::IRONDEFENSE) || (move == PBMoves::IRONHEAD)
			return false
		  end
	  when PBSpecies::DUGTRIO #Dugtrio
		  if (move == PBMoves::WORKUP) || (move == PBMoves::FLASHCANNON) ||
			(move == PBMoves::IRONDEFENSE) || (move == PBMoves::IRONHEAD)
			return false
		  end
	  when PBSpecies::MEOWTH #Meowth
		  if (move == PBMoves::QUASH) || (move == PBMoves::EMBARGO) ||
			(move == PBMoves::SWORDSDANCE) || (move == PBMoves::CRUNCH) ||
			(move == PBMoves::IRONDEFENSE) || (move == PBMoves::GYROBALL) ||
			(move == PBMoves::IRONHEAD)
			return false
		  end
		  if (move == PBMoves::SWORDSDANCE) || (move == PBMoves::CRUNCH) ||
			(move == PBMoves::IRONDEFENSE) || (move == PBMoves::GYROBALL) ||
			(move == PBMoves::IRONHEAD)
			return true
		  end
		  if (move == PBMoves::ICYWIND) || (move == PBMoves::CHARM) ||
			(move == PBMoves::SWIFT)
			return true
		  end
	  when PBSpecies::PERSIAN #Persian
		  if (move == PBMoves::QUASH) || (move == PBMoves::SNARL)
			return false
		  end
	  when PBSpecies::GEODUDE #Geodude
		  if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER) ||
			(move == PBMoves::CHARGEBEAM) || (move == PBMoves::BRUTALSWING) ||
			(move == PBMoves::VOLTSWITCH) || (move == PBMoves::MAGNETRISE) ||
			(move == PBMoves::ELECTROWEB)
			return false
		  end
	  when PBSpecies::GRAVELER #Graveler
		  if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER) ||
			(move == PBMoves::CHARGEBEAM) || (move == PBMoves::BRUTALSWING) ||
			(move == PBMoves::VOLTSWITCH) || (move == PBMoves::MAGNETRISE) ||
			(move == PBMoves::ELECTROWEB) || (move == PBMoves::SHOCKWAVE) ||
			(move == PBMoves::ALLYSWITCH)
			return false
		  end
	  when PBSpecies::GOLEM #Golem
		  if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER) ||
			(move == PBMoves::CHARGEBEAM) || (move == PBMoves::BRUTALSWING) ||
			(move == PBMoves::VOLTSWITCH) || (move == PBMoves::ECHOEDVOICE) ||
			(move == PBMoves::WILDCHARGE) || (move == PBMoves::MAGNETRISE) ||
			(move == PBMoves::ELECTROWEB) || (move == PBMoves::SHOCKWAVE) ||
			(move == PBMoves::ALLYSWITCH)
			return false
		  end
	  when PBSpecies::GRIMER #Grimer
		  if (move == PBMoves::BRUTALSWING) || (move == PBMoves::QUASH) ||
			(move == PBMoves::EMBARGO) || (move == PBMoves::ROCKPOLISH) ||
			(move == PBMoves::STONEEDGE) || (move == PBMoves::SNARL) ||
			(move == PBMoves::KNOCKOFF) || (move == PBMoves::GASTROACID) ||
			(move == PBMoves::SPITE)
			return false
		  end
		  if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER)
			return true
		  end
	  when PBSpecies::MUK #Muk
		  if (move == PBMoves::BRUTALSWING) || (move == PBMoves::QUASH) ||
			(move == PBMoves::EMBARGO) || (move == PBMoves::ROCKPOLISH) ||
			(move == PBMoves::STONEEDGE) || (move == PBMoves::SNARL) ||
			(move == PBMoves::KNOCKOFF) || (move == PBMoves::GASTROACID) ||
			(move == PBMoves::SPITE) || (move == PBMoves::RECYCLE)
			return false
		  end
		  if (move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER)
			return true
		  end
	  when PBSpecies::EXEGGUTOR # Exeggutor
		  if (move == PBMoves::EARTHQUAKE) || (move == PBMoves::BRICKBREAK) ||
			(move == PBMoves::FLAMETHROWER) || (move == PBMoves::BRUTALSWING) ||
			(move == PBMoves::BULLDOZE) || (move == PBMoves::DRAGONTAIL) ||
			(move == PBMoves::IRONHEAD) || (move == PBMoves::SUPERPOWER) ||
			(move == PBMoves::DRAGONPULSE) || (move == PBMoves::IRONTAIL) ||
			(move == PBMoves::KNOCKOFF) || (move == PBMoves::OUTRAGE) ||
			(move == PBMoves::DRACOMETEOR)
			return false
		  end
	  when PBSpecies::MAROWAK # Marowak
		  if (move == PBMoves::RAINDANCE) || (move == PBMoves::THUNDERBOLT) ||
			(move == PBMoves::THUNDER) || (move == PBMoves::SHADOWBALL) ||
			(move == PBMoves::FLAMECHARGE) || (move == PBMoves::WILLOWISP) ||
			(move == PBMoves::DREAMEATER) || (move == PBMoves::DARKPULSE) ||
			(move == PBMoves::HEATWAVE) || (move == PBMoves::PAINSPLIT) ||
			(move == PBMoves::SPITE) || (move == PBMoves::ALLYSWITCH)
			return false
		  end
	  when PBSpecies::LYCANROC # Lycanroc
		  if (move == PBMoves::DUALCHOP) || (move == PBMoves::UPROAR) ||
			(move == PBMoves::THUNDERPUNCH) || (move == PBMoves::FIREPUNCH) ||
			(move == PBMoves::FOULPLAY) || (move == PBMoves::FOCUSPUNCH) ||
			(move == PBMoves::THROATCHOP) || (move == PBMoves::LASERFOCUS) ||
			(move == PBMoves::OUTRAGE)
			return false
		  end
		  if (move == PBMoves::DRILLRUN)
			return true
		  end
		  if (move == PBMoves::DUALCHOP) || (move == PBMoves::UPROAR) ||
			(move == PBMoves::THUNDERPUNCH) || (move == PBMoves::FIREPUNCH) ||
			(move == PBMoves::FOULPLAY) || (move == PBMoves::FOCUSPUNCH) ||
			(move == PBMoves::THROATCHOP) || (move == PBMoves::LASERFOCUS)
			return true
		  end
	  when PBSpecies::MISDREAVUS # Misdreavus -- Aevian
		  if (move == PBMoves::WORKUP) || (move == PBMoves::VENOSHOCK) ||
			(move == PBMoves::SOLARBEAM) || (move == PBMoves::SWORDSDANCE) ||
			(move == PBMoves::INFESTATION) || (move == PBMoves::GRASSKNOT) ||
			(move == PBMoves::NATUREPOWER) || (move == PBMoves::LEECHLIFE) ||
			(move == PBMoves::CUT) || (move == PBMoves::BIND) ||
			(move == PBMoves::WORRYSEED) || (move == PBMoves::GIGADRAIN) ||
			(move == PBMoves::SYNTHESIS) || (move == PBMoves::WATERPULSE) ||
			(move == PBMoves::SEEDBOMB) || (move == PBMoves::GASTROACID) ||
			(move == PBMoves::THROATCHOP) || (move == PBMoves::GUNKSHOT) ||
			(move == PBMoves::KNOCKOFF) 
			return false
		  end
		  if (move == PBMoves::CALMMIND) || (move == PBMoves::THUNDERBOLT) ||
			(move == PBMoves::THUNDER) || (move == PBMoves::PSYCHIC) ||
			(move == PBMoves::TORMENT) || (move == PBMoves::THIEF) ||
			(move == PBMoves::CHARGEBEAM) || (move == PBMoves::PAYBACK) ||
			(move == PBMoves::THUNDERWAVE) || (move == PBMoves::DREAMEATER) ||
			(move == PBMoves::TRICKROOM) || (move == PBMoves::DARKPULSE) ||
			(move == PBMoves::DAZZLINGGLEAM) || (move == PBMoves::FLASH) 
			(move == PBMoves::FOULPLAY) || (move == PBMoves::HEADBUTT) ||
			(move == PBMoves::ICYWIND) || (move == PBMoves::ROLEPLAY) ||
			(move == PBMoves::SHOCKWAVE) || (move == PBMoves::TELEKINESIS) 
			return false  
		  end
	  when PBSpecies::MISMAGIUS # Mismagius -- Aevian
		  if (move == PBMoves::HONECLAWS) || (move == PBMoves::WORKUP) ||
			(move == PBMoves::VENOSHOCK) || (move == PBMoves::SOLARBEAM) ||
			(move == PBMoves::SWORDSDANCE) || (move == PBMoves::INFESTATION) ||
			(move == PBMoves::GRASSKNOT) || (move == PBMoves::NATUREPOWER) ||
			(move == PBMoves::LEECHLIFE) ||  (move == PBMoves::CUT) ||
			(move == PBMoves::STRENGTH) || (move == PBMoves::BIND) ||
			(move == PBMoves::WORRYSEED) || (move == PBMoves::GIGADRAIN) ||
			(move == PBMoves::SYNTHESIS) || (move == PBMoves::WATERPULSE) ||
			(move == PBMoves::SEEDBOMB) || (move == PBMoves::GASTROACID) ||
			(move == PBMoves::THROATCHOP) || (move == PBMoves::GUNKSHOT) ||
			(move == PBMoves::KNOCKOFF)
			return false
		  end
		  if (move == PBMoves::CALMMIND) || (move == PBMoves::HYPERBEAM) ||
			(move == PBMoves::THUNDERBOLT) || (move == PBMoves::THUNDER) ||
			(move == PBMoves::PSYCHIC) || (move == PBMoves::TORMENT) ||
			(move == PBMoves::THIEF) || (move == PBMoves::CHARGEBEAM) ||
			(move == PBMoves::PAYBACK) || (move == PBMoves::GIGAIMPACT) ||
			(move == PBMoves::THUNDERWAVE) || (move == PBMoves::DREAMEATER) ||
			(move == PBMoves::TRICKROOM) || (move == PBMoves::DARKPULSE) ||
			(move == PBMoves::DAZZLINGGLEAM) || (move == PBMoves::FLASH) ||
			(move == PBMoves::FOULPLAY) || (move == PBMoves::HEADBUTT) ||
			(move == PBMoves::ICYWIND) || (move == PBMoves::ROLEPLAY) ||
			(move == PBMoves::SHOCKWAVE) || (move == PBMoves::TELEKINESIS) 
			return true
		  end
	  when PBSpecies::PONYTA # Ponyta
		  if (move == PBMoves::IMPRISON) || (move == PBMoves::PSYCHIC) ||
			(move == PBMoves::FUTURESIGHT) || (move == PBMoves::CALMMIND) ||
			(move == PBMoves::ZENHEADBUTT) || (move == PBMoves::STOREDPOWER) ||
			(move == PBMoves::DAZZLINGGLEAM)
			return false
		  end
		  if (move == PBMoves::SOLARBEAM) || (move == PBMoves::SOLARBLADE) ||
			(move == PBMoves::FIRESPIN) || (move == PBMoves::SUNNYDAY) || 
			(move == PBMoves::WILLOWISP) || (move == PBMoves::FLAMETHROWER) || 
			(move == PBMoves::FIREBLAST) || (move == PBMoves::HEATWAVE) ||
			(move == PBMoves::OVERHEAT) || (move == PBMoves::FLAREBLITZ)
			return true
		  end
	  when PBSpecies::RAPIDASH # Rapidash
		  if (move == PBMoves::IMPRISON) || (move == PBMoves::PSYCHOCUT) || 
			(move == PBMoves::TRICKROOM) || (move == PBMoves::WONDERROOM) || 
			(move == PBMoves::MAGICROOM) || (move == PBMoves::MISTYTERRAIN) || 
			(move == PBMoves::PSYCHICTERRAIN) || (move == PBMoves::PSYCHIC) ||
			(move == PBMoves::FUTURESIGHT) || (move == PBMoves::CALMMIND) ||
			(move == PBMoves::ZENHEADBUTT) || (move == PBMoves::STOREDPOWER) ||
			(move == PBMoves::DAZZLINGGLEAM)
			return false
		  end
		  if (move == PBMoves::SOLARBEAM) || (move == PBMoves::SOLARBLADE) ||
			(move == PBMoves::FIRESPIN) || (move == PBMoves::SUNNYDAY) || 
			(move == PBMoves::WILLOWISP) || (move == PBMoves::FLAMETHROWER) || 
			(move == PBMoves::FIREBLAST) || (move == PBMoves::HEATWAVE) ||
			(move == PBMoves::OVERHEAT) || (move == PBMoves::FLAREBLITZ) ||
			(move == PBMoves::POISONJAB)
			return true
		end
	  when PBSpecies::FARFETCHD # Farfetch'd
		  if (move == PBMoves::BRICKBREAK) || (move == PBMoves::ASSURANCE) || 
			(move == PBMoves::SUPERPOWER)
			return false
		  end
		  if (move == PBMoves::FLY) || (move == PBMoves::THIEF) || 
			(move == PBMoves::SWIFT) || (move == PBMoves::UTURN) || 
			(move == PBMoves::ACROBATICS) || (move == PBMoves::FALSESWIPE) || 
			(move == PBMoves::AIRSLASH) || (move == PBMoves::AGILITY) || 
			(move == PBMoves::BATONPASS) ||  (move == PBMoves::IRONTAIL) || 
			(move == PBMoves::UPROAR) || (move == PBMoves::HEATWAVE)
			return true
		end
	  when PBSpecies::WEEZING # Weezing
		  if (move == PBMoves::WONDERROOM) || (move == PBMoves::MISTYTERRAIN) ||
			(move == PBMoves::BRUTALSWING) || (move == PBMoves::OVERHEAT) ||
			(move == PBMoves::PLAYROUGH) || (move == PBMoves::DAZZLINGGLEAM)
			return false
		  end
	  when PBSpecies::MRMIME # Mr Mime
		  if (move == PBMoves::SCREECH) || (move == PBMoves::HAIL) || 
			(move == PBMoves::ICICLESPEAR) || (move == PBMoves::AVALANCHE) || 
			(move == PBMoves::STOMPINGTANTRUM) || (move == PBMoves::ICEBEAM) || 
			(move == PBMoves::BLIZZARD)
			return false
		  end
		  if (move == PBMoves::FIREPUNCH) || (move == PBMoves::THUNDERPUNCH) || 
			(move == PBMoves::MAGICALLEAF) || (move == PBMoves::MYSTICALFIRE)
			return true
		  end
	  when PBSpecies::CORSOLA # Corsola
		  if (move == PBMoves::GIGADRAIN) || (move == PBMoves::WILLOWISP) ||
			(move == PBMoves::HEX)
			return false
		  end
	  when PBSpecies::ZIGZAGOON # Zigzagoon
		  if (move == PBMoves::SCREECH) || (move == PBMoves::SCARYFACE) ||
			(move == PBMoves::FAKETEARS) || (move == PBMoves::PAYBACK) ||
			(move == PBMoves::ASSURANCE) || (move == PBMoves::SNARL) ||
			(move == PBMoves::TAUNT)
			return false
		  end
		  if (move == PBMoves::CHARM) || (move == PBMoves::TAILSLAP)
			return true
		end
	  when PBSpecies::LINOONE # Linoone
		  if (move == PBMoves::SCREECH) || (move == PBMoves::SCARYFACE) ||
			(move == PBMoves::FAKETEARS) || (move == PBMoves::PAYBACK) ||
			(move == PBMoves::ASSURANCE) || (move == PBMoves::SNARL) ||
			(move == PBMoves::TAUNT)
			return false
		  end
		  if (move == PBMoves::CHARM) || (move == PBMoves::TAILSLAP) ||
			(move == PBMoves::PLAYROUGH) || (move == PBMoves::BODYPRESS)
			return true
		  end
	  when PBSpecies::WORMADAM # Wormadam 
		  if (move == PBMoves::EARTHQUAKE) || (move == PBMoves::SANDSTORM) ||
			(move == PBMoves::ROCKTOMB) || (move == PBMoves::BULLDOZE) ||
			(move == PBMoves::EARTHPOWER) || (move == PBMoves::STEALTHROCK) || 
			(move == PBMoves::GYROBALL) || (move == PBMoves::FLASHCANNON) || 
			(move == PBMoves::GUNKSHOT) || (move == PBMoves::IRONDEFENSE) || 
			(move == PBMoves::IRONHEAD) || (move == PBMoves::MAGNETRISE)
			return false
		  end
		  if (move == PBMoves::SOLARBEAM) || (move == PBMoves::ENERGYBALL) || 
			(move == PBMoves::GRASSKNOT) || (move == PBMoves::GIGADRAIN) || 
			(move == PBMoves::SEEDBOMB) || (move == PBMoves::SYNTHESIS) ||
			(move == PBMoves::WORRYSEED) || (move == PBMoves::GYROBALL) || 
			(move == PBMoves::FLASHCANNON) || (move == PBMoves::GUNKSHOT) || 
			(move == PBMoves::IRONDEFENSE) || (move == PBMoves::IRONHEAD) || 
			(move == PBMoves::MAGNETRISE)
			return true
		  end
		  if (move == PBMoves::SOLARBEAM) || (move == PBMoves::ENERGYBALL) || 
			(move == PBMoves::GRASSKNOT) || (move == PBMoves::GIGADRAIN) || 
			(move == PBMoves::SEEDBOMB) || (move == PBMoves::SYNTHESIS) ||
			(move == PBMoves::WORRYSEED) || (move == PBMoves::EARTHQUAKE) || 
			(move == PBMoves::SANDSTORM) || (move == PBMoves::ROCKTOMB) || 
			(move == PBMoves::BULLDOZE) || (move == PBMoves::EARTHPOWER) 
			return true
		  end
	  when PBSpecies::DARUMAKA # Darumaka
		  if (move == PBMoves::ICEPUNCH) || (move == PBMoves::AVALANCHE) || 
			(move == PBMoves::ICEFANG) || (move == PBMoves::ICEBEAM) || 
			(move == PBMoves::BLIZZARD) 
			return false
		  end
	  when PBSpecies::DARMANITAN # Darmanitan
		  if (move == PBMoves::ICEPUNCH) || (move == PBMoves::AVALANCHE) || 
			(move == PBMoves::ICEFANG) || (move == PBMoves::ICEBEAM) || 
			(move == PBMoves::BLIZZARD) 
			return false
		  end
		  if (move == PBMoves::POWERSWAP) || (move == PBMoves::GUARDSWAP) || 
			(move == PBMoves::MYSTICALFIRE) || (move == PBMoves::FUTURESIGHT) || 
			(move == PBMoves::TRICK)
			return true
		  end
	  when PBSpecies::YAMASK # Yamask
		  if (move == PBMoves::ROCKSLIDE) || (move == PBMoves::SANDSTORM) ||
			(move == PBMoves::ROCKTOMB) || (move == PBMoves::BRUTALSWING) ||
			(move == PBMoves::EARTHQUAKE) || (move == PBMoves::EARTHPOWER)
			return false
		  end
	  when PBSpecies::STUNFISK # Stunfisk
		  if (move == PBMoves::SCREECH) || (move == PBMoves::ICEFANG) ||  
			(move == PBMoves::CRUNCH) ||  (move == PBMoves::IRONDEFENSE) ||  
			(move == PBMoves::FLASHCANNON) 
			return false
		  end
		  if (move == PBMoves::ELECTROWEB) || (move == PBMoves::ELECTRICTERRAIN) ||  
			(move == PBMoves::EERIEIMPULSE) ||  (move == PBMoves::THUNDERBOLT) ||  
			(move == PBMoves::THUNDER)
			return true
		  end
		end
		return nil
  end
