class PokemonReadyMenu_Scene
	attr_reader :sprites

	def pbStartScene(commands)
		@commands = commands
		@movecommands = []
		@itemcommands = []
		for i in 0...@commands[0].length
			@movecommands.push(@commands[0][i][1])
		end
		for i in 0...@commands[1].length
			@itemcommands.push(@commands[1][i][1])
		end
		@index = $PokemonBag.registeredIndex
		if @index[0]>=@movecommands.length && @movecommands.length>0
			@index[0] = @movecommands.length-1
		end
		if @index[1]>=@itemcommands.length && @itemcommands.length>0
			@index[1] = @itemcommands.length-1
		end
		if @index[2]==0 && @movecommands.length==0
			@index[2] = 1
		elsif @index[2]==1 && @itemcommands.length==0
			@index[2] = 0
		end
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@sprites["cmdwindow"] = Window_CommandPokemon.new((@index[2]==0) ? @movecommands : @itemcommands)
		#@sprites["cmdwindow"].height = @itemcommands.length*32
		@sprites["cmdwindow"].visible = false
		@sprites["cmdwindow"].viewport = @viewport
		#pbSEPlay("GUI menu open")
	end

	def pbHideMenu
		@sprites["cmdwindow"].visible = false
	end

	def pbShowCommands
		ret = -1
		cmdwindow = @sprites["cmdwindow"]
		cmdwindow.commands = @itemcommands
		cmdwindow.index    = @index[@index[2]]
		cmdwindow.visible  = true
		counter = 0
		counterlimit = $speed_up ? 20 : 8
		loop do
			pbUpdate
			if Input.trigger?(Input::B)
				ret = -1
				break
			elsif Input.trigger?(Input::C) || Input.trigger?(Input::Y) || Input.press?(Input::Y) && counter > counterlimit
				ret = [@index[2],cmdwindow.index]
				break
			elsif Input.press?(Input::Y)
				counter+=1
			end
		end
		return ret
	end

	def pbEndScene
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end

	def pbUpdate
		oldindex = @index[@index[2]]
		@index[@index[2]] = @sprites["cmdwindow"].index
		pbUpdateSpriteHash(@sprites)
		pbUpdateSceneMap
		Graphics.update
		Input.update
	end

	def pbRefresh; end
end



class PokemonReadyMenu
	def initialize(scene)
		@scene = scene
	end

	def pbHideMenu
		@scene.pbHideMenu
	end

	def pbShowMenu
		@scene.pbRefresh
	end

	def pbStartReadyMenu(moves,items)
		commands = [[],[]] # Moves, items
		for i in moves
			commands[0].push([i[0],PBMoves.getName(i[0]),true,i[1]])
		end
		commands[0].sort!{|a,b| a[1]<=>b[1]}
		for i in items
			commands[1].push([i,PBItems.getName(i),false])
		end
		commands[1].sort!{|a,b| a[1]<=>b[1]}
		
		@scene.pbStartScene(commands)
		loop do
			command = @scene.pbShowCommands
			if command==-1
				break
			else
				if command[0]==0 # Use a move
					move = commands[0][command[1]][0]
					user = $Trainer.party[commands[0][command[1]][3]]
					if isConst?(move,PBMoves,:FLY)
						ret = nil
						pbFadeOutInWithUpdate(99999,@scene.sprites){
							scene = PokemonRegionMap_Scene.new(-1,false)
							screen = PokemonRegionMapScreen.new(scene)
							ret = screen.pbStartFlyScreen
						}
						if ret
							$PokemonTemp.flydata = ret
							#$game_temp.in_menu = false
							Kernel.pbUseHiddenMove(user,move)
							break
						end
					else
						pbHideMenu
						if Kernel.pbConfirmUseHiddenMove(user,move)
							#$game_temp.in_menu = false
							Kernel.pbUseHiddenMove(user,move)
							break
						end
					end
				else # Use an item
					item = commands[1][command[1]][0]
					pbHideMenu
					Kernel.pbUseKeyItemInField(item)
					break
				end
				pbShowMenu
			end
		end
		@scene.pbEndScene
	end
end

#===============================================================================
# Using a registered item
#===============================================================================

def Kernel.pbUseKeyItem
	begin
		# TODO: Remember move order
		moves = [:CUT,:DEFOG,:DIG,:DIVE,:FLASH,:FLY,:HEADBUTT,:ROCKCLIMB,:ROCKSMASH,
						:SECRETPOWER,:STRENGTH,:SURF,:SWEETSCENT,:TELEPORT,:WATERFALL,
						:WHIRLPOOL]
		realmoves = []
=begin
		for i in moves
			move = getID(PBMoves,i)
			next if move==0
			for j in 0...$Trainer.party.length
				next if $Trainer.party[j].egg?
				if $Trainer.party[j].pbHasMove?(move)
					realmoves.push([move,j]) if Kernel.pbCanUseHiddenMove?($Trainer.party[j],move)
					break
				end
			end
		end
=end
		realitems = []
		for i in $PokemonBag.registeredItems
			realitems.push(i) if $PokemonBag.pbHasItem?(i)
		end
		if realitems.length==0 && realmoves.length==0
			Kernel.pbMessage(_INTL("An item in the Bag can be registered to this key for instant use."))
		elsif realitems.length == 1 && realmoves.length==0
			Kernel.pbUseKeyItemInField(realitems[0])
		else
			#$game_temp.in_menu = true
			$game_map.update
			sscene = PokemonReadyMenu_Scene.new
			sscreen = PokemonReadyMenu.new(sscene) 
			sscreen.pbStartReadyMenu(realmoves,realitems)
			#$game_temp.in_menu = false
		end
	rescue
		pbPrintException($!)
	end
end