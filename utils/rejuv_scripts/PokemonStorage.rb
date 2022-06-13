class PokemonBox
  attr_reader :pokemon
  attr_accessor :name
  attr_accessor :background

  def initialize(name,maxPokemon=30)
    @pokemon = []
    @name = name
    @background = nil
    for i in 0...maxPokemon
      @pokemon[i] = nil
    end
  end

  def length
    return @pokemon.length
  end

  def nitems
    return @pokemon.nitems
  end

  def full?
    return (@pokemon.nitems==self.length)
  end

  def [](i)
    return @pokemon[i]
  end

  def []=(i,value)
    @pokemon[i] = value
  end

  def each
    @pokemon.each{|item| yield item}
  end
end



class PokemonStorage
  attr_reader :boxes
  attr_reader :party
  attr_accessor :currentBox

  def initialize(maxBoxes=STORAGEBOXES,maxPokemon=30)
    @boxes = []
    for i in 0...maxBoxes
      @boxes[i] = PokemonBox.new(_INTL("Box {1}",i+1),maxPokemon)
      backid=i%24
      @boxes[i].background="box#{backid}"
    end
    @currentBox = 0
    @boxmode = -1
  end

  MARKINGCHARS=["●","■","▲","♥"]

  def party
    $Trainer.party
  end

  def party=(value)
    raise ArgumentError.new("Not supported")
  end

  def maxBoxes
    return @boxes.length
  end

  def maxPokemon(box)
    return 0 if box>=self.maxBoxes
    return (box<0) ? 6 : self[box].length
  end

  def full?
    for i in 0...self.maxBoxes
      return false if !@boxes[i].full?
    end
    return true
  end

  def pbFirstFreePos(box)
    if box==-1
      ret = self.party.nitems
      return (ret==6) ? -1 : ret
    else
      for i in 0...maxPokemon(box)
        return i if !self[box,i]
      end
      return -1
    end
  end

  def [](x,y=nil)
    if y==nil
      return (x==-1) ? self.party : @boxes[x]
    else
      for i in @boxes
        raise "Box is a Pokémon, not a box" if i.is_a?(PokeBattle_Pokemon)
      end
      return (x==-1) ? self.party[y] : @boxes[x][y]
    end
  end

  def []=(x,y,value)
    if x==-1
      self.party[y] = value
    else
      @boxes[x][y] = value
    end
  end

  def pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    if indexDst<0 && boxDst<self.maxBoxes
      found = false
      for i in 0...maxPokemon(boxDst)
        if !self[boxDst,i]
          found = true
          indexDst = i
          break
        end
      end
      return false if !found
    end
    if boxDst==-1
      return false if self.party.nitems>=6
      self.party[self.party.length] = self[boxSrc,indexSrc]
      self.party.compact!
    else
      pkmn = self[boxSrc,indexSrc]
      if !pkmn
        raise "Trying to copy nil to storage" # not localized
      end
      #pkmn.heal
      self[boxDst,indexDst] = pkmn
    end
    return true
  end

  def pbMove(boxDst,indexDst,boxSrc,indexSrc)
    return false if !pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    pbDelete(boxSrc,indexSrc)
    return true
  end

  def pbMoveCaughtToParty(pkmn)
    return false if self.party.nitems>=6
    self.party[self.party.length] = pkmn
  end

  def pbMoveCaughtToBox(pkmn,box)
    for i in 0...maxPokemon(box)
      if self[box,i]==nil
        #if box>=0
        #  pkmn.heal
        #end
        self[box,i] = pkmn
        return true
      end
    end
    return false
  end

  def pbStoreCaught(pkmn)
    for i in 0...maxPokemon(@currentBox)
      if self[@currentBox,i]==nil
        self[@currentBox,i] = pkmn
        return @currentBox
      end
    end
    for j in 0...self.maxBoxes
      for i in 0...maxPokemon(j)
        if self[j,i]==nil
          self[j,i] = pkmn
          @currentBox = j
          return @currentBox
        end
      end
    end
    return -1
  end

  def pbDelete(box,index)
    if self[box,index]
      self[box,index] = nil
      self.party.compact! if box==-1
    end
  end
end



class PokemonStorageWithParty < PokemonStorage
  def party
    return @party
  end

  def party=(value)
    @party=party
  end

  def initialize(maxBoxes=24,maxPokemon=30,party=nil)
    super(maxBoxes,maxPokemon)
    if party
      @party=party
    else
      @party=[]
    end
  end
end



class PokemonStorageScreen
  attr_reader :scene
  attr_reader :storage

  def initialize(scene,storage)
    @scene=scene
    @storage=storage
    @pbHeldPokemon=nil
  end

  def pbConfirm(str)
    return (pbShowCommands(str,[_INTL("Yes"),_INTL("No")])==0)
  end

  def pbRelease(selected,heldpoke)
    box=selected[0]
    index=selected[1]
    pokemon=(heldpoke)?heldpoke:@storage[box,index]
    return if !pokemon
    if pokemon.isEgg?
      pbDisplay(_INTL("You can't release an Egg."))
      return false
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    if box==-1 && pbAbleCount<=1 && pbAble?(pokemon) && !heldpoke
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command=pbShowCommands(_INTL("Release this Pokémon?"),[_INTL("No"),_INTL("Yes")])
    if command==1
      pkmnname=pokemon.name
      @scene.pbRelease(selected,heldpoke)
      if heldpoke
        @heldpkmn=nil
      else
        @storage.pbDelete(box,index)
      end
      @scene.pbRefresh
      pbDisplay(_INTL("{1} was released.",pkmnname))
      pbDisplay(_INTL("Bye-bye, {1}!",pkmnname))
      @scene.pbRefresh
    end
    return
  end

  def pbMark(selected,heldpoke)
    @scene.pbMark(selected,heldpoke)
  end

  def pbAble?(pokemon)
    pokemon && !pokemon.isEgg? && pokemon.hp>0
  end

  def pbAbleCount
    count=0
    for p in @storage.party
      count+=1 if pbAble?(p)
    end
    return count
  end

  def pbStore(selected,heldpoke)
    box=selected[0]
    index=selected[1]
    if box!=-1
      raise _INTL("Can't deposit from box...")
    end   
    if pbAbleCount<=1 && pbAble?(@storage[box,index]) && !heldpoke
      pbDisplay(_INTL("That's your last Pokémon!"))
    elsif !heldpoke && @storage[box,index].mail
      pbDisplay(_INTL("Please remove the Mail."))
    elsif !@storage[box,index] && heldpoke.mail
      pbDisplay(_INTL("Please remove the Mail."))
    else
      loop do
        destbox=@scene.pbChooseBox(_INTL("Deposit in which Box?"))
        if destbox>=0
          success=false
          firstfree=@storage.pbFirstFreePos(destbox)
          if firstfree<0
            pbDisplay(_INTL("The Box is full."))
            next
          end
          @scene.pbStore(selected,heldpoke,destbox,firstfree)
          if heldpoke
            @storage.pbMoveCaughtToBox(heldpoke,destbox)
            @heldpkmn=nil
          else
            @storage.pbMove(destbox,-1,-1,index)
          end
        end
        break
      end
      @scene.pbRefresh
    end
  end

  def pbWithdraw(selected,heldpoke)
    box=selected[0]
    index=selected[1]
    if box==-1
      raise _INTL("Can't withdraw from party...");
    end
    if @storage.party.nitems>=6
      pbDisplay(_INTL("Your party's full!"))
      return false
    end
    @scene.pbWithdraw(selected,heldpoke,@storage.party.length)
    if heldpoke
      @storage.pbMoveCaughtToParty(heldpoke)
      @heldpkmn=nil
    else
      @storage.pbMove(-1,-1,box,index)
    end
    @scene.pbRefresh
    return true
  end

  def pbDisplay(message)
    @scene.pbDisplay(message)
  end

  def pbSummary(selected,heldpoke)
    @scene.pbSummary(selected,heldpoke)
  end

  def pbHold(selected)
    box=selected[0]
    index=selected[1]
    if box==-1 && pbAble?(@storage[box,index]) && pbAbleCount<=1
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    @scene.pbHold(selected)
    @heldpkmn=@storage[box,index]
    @storage.pbDelete(box,index) 
    @scene.pbRefresh
  end

  def pbSwap(selected)
    box=selected[0]
    index=selected[1]
    if !@storage[box,index]
      raise _INTL("Position {1},{2} is empty...",box,index)
    end
    if box==-1 && pbAble?(@storage[box,index]) && pbAbleCount<=1 && !pbAble?(@heldpkmn)
      pbDisplay(_INTL("That's your last Pokémon!"))
      return false
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return false
    end
    @scene.pbSwap(selected,@heldpkmn)
    #@heldpkmn.heal if box>=0
    tmp=@storage[box,index]
    @storage[box,index]=@heldpkmn
    @heldpkmn=tmp
    @scene.pbRefresh
    return true
  end

  def pbPlace(selected)
    box=selected[0]
    index=selected[1]
    if @storage[box,index]
      raise _INTL("Position {1},{2} is not empty...",box,index)
    end
    if box!=-1 && index>=@storage.maxPokemon(box)
      pbDisplay("Can't place that there.")
      return
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return
    end
    #@heldpkmn.heal if box>=0
    @scene.pbPlace(selected,@heldpkmn)
    @storage[box,index]=@heldpkmn
    if box==-1
      @storage.party.compact!
    end
    @scene.pbRefresh
    @heldpkmn=nil
  end

  def pbItem(selected,heldpoke)
    box=selected[0]
    index=selected[1]
    pokemon=(heldpoke) ? heldpoke : @storage[box,index]
    if pokemon.isEgg?
      pbDisplay(_INTL("Eggs can't hold items."))
      return
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return
    end
    if pokemon.item>0
      itemname=PBItems.getName(pokemon.item)
      if pbConfirm(_INTL("Take this {1}?",itemname))
        if !$PokemonBag.pbStoreItem(pokemon.item)
          pbDisplay(_INTL("Can't store the {1}.",itemname))
        else
          pbDisplay(_INTL("Took the {1}.",itemname))
          pokemon.setItem(0)
          @scene.pbHardRefresh
        end
      end
    else
      item=scene.pbChooseItem($PokemonBag)
      if item>0
        itemname=PBItems.getName(item)
        pokemon.setItem(item)
        $PokemonBag.pbDeleteItem(item)
        pbDisplay(_INTL("{1} is now being held.",itemname))
        @scene.pbHardRefresh
      end
    end
  end

  def pbHeldPokemon
    return @heldpkmn
  end

=begin
  commands=[
     _INTL("WITHDRAW POKéMON"),
     _INTL("DEPOSIT POKéMON"),
     _INTL("MOVE POKéMON"),
     _INTL("MOVE ITEMS"),
     _INTL("SEE YA!")
  ]
  helptext=[
     _INTL("Move Pokémon stored in boxes to your party."),
     _INTL("Store Pokémon in your party in Boxes."),
     _INTL("Organize the Pokémon in Boxes and in your party."),
     _INTL("Move items held by any Pokémon in a Box and your party."),
     _INTL("Return to the previous menu."),
  ]
  command=pbShowCommandsAndHelp(commands,helptext)
=end

  def pbShowCommands(msg,commands)
    return @scene.pbShowCommands(msg,commands)
  end

  def pbBoxCommands
    commands=[
       _INTL("Jump"),
       _INTL("Wallpaper"),
       _INTL("Name"),
       _INTL("Cancel"),
    ]
    command=pbShowCommands(
       _INTL("What do you want to do?"),commands)
    case command
      when 0
        destbox=@scene.pbChooseBox(_INTL("Jump to which Box?"))
        if destbox>=0
          @scene.pbJumpToBox(destbox)
        end
      when 1
        commands=[
           _INTL("Forest"),
           _INTL("City"),
           _INTL("Desert"),
           _INTL("Savanna"),
           _INTL("Crag"),
           _INTL("Volcano"),
           _INTL("Snow"),
           _INTL("Cave"),
           _INTL("Beach"),
           _INTL("Seafloor"),
           _INTL("River"),
           _INTL("Sky"),
           _INTL("Poké Center"),
           _INTL("Machine"),
           _INTL("Checks"),
           _INTL("Simple"),
           _INTL("Heart"),
           _INTL("Soul"),
           _INTL("Retro"),
           _INTL("Compete"),
           _INTL("Trio"),
           _INTL("Pika"),
           _INTL("Kimono Girl"),
           _INTL("Rocket")
        ]
        wpaper=pbShowCommands(_INTL("Pick the wallpaper."),commands)
        if wpaper>=0
          @scene.pbChangeBackground(wpaper)
        end
      when 2
        @scene.pbBoxName(_INTL("Box name?"),0,12)
    end
  end

  def pbChoosePokemon(party=nil)
    @heldpkmn=nil
    @scene.pbStartBox(self,2)
    retval=nil
    loop do
      selected=@scene.pbSelectBox(@storage.party)
      if selected && selected[0]==-3 # Close box
        if pbConfirm(_INTL("Exit from the Box?"))
          break
        else
          next
        end
      end
      if selected==nil
        if pbConfirm(_INTL("Continue Box operations?"))
          next
        else
          break
        end
      elsif selected[0]==-4 # Box name
        pbBoxCommands
      else
        pokemon=@storage[selected[0],selected[1]]
        next if !pokemon
        commands=[
           _INTL("Select"),
           _INTL("Summary"),
           _INTL("Withdraw"),
           _INTL("Item"),
           _INTL("Mark")
        ]
        commands.push(_INTL("Cancel"))
        if selected[0]==-1
          commands[2]=_INTL("Store")
        else
          commands[2]=_INTL("Withdraw")
        end
        helptext=_INTL("{1} is selected.",pokemon.name)
        command=pbShowCommands(helptext,commands)
        case command
          when 0 # Move/Shift/Place
            if pokemon
              retval=selected
              break
            end
          when 1 # Summary
            pbSummary(selected,nil)
          when 2 # Withdraw
            if selected[0]==-1
              pbStore(selected,nil)
            else
              pbWithdraw(selected,nil)
            end
          when 3 # Item
            pbItem(selected,nil)
          when 4 # Mark
            pbMark(selected,nil)
        end
      end
    end
    @scene.pbCloseBox
    return retval
  end

  def pbStartScreen(command)
    @heldpkmn=nil
    if command==2
### WITHDRAW ###################################################################
      @scene.pbStartBox(self,command)
      loop do
        selected=@scene.pbSelectBox(@storage.party)
        if selected && selected[0]==-3 # Close box
          if pbConfirm(_INTL("Exit from the Box?"))
            break
          else
            next
          end
        end
        if selected && selected[0]==-2 # Party Pokémon
          pbDisplay(_INTL("Which one will you take?"))
          next
        end
        if selected && selected[0]==-4 # Box name
          pbBoxCommands
          next
        end
        if selected==nil
          if pbConfirm(_INTL("Continue Box operations?"))
            next
          else
            break
          end
        else
          pokemon=@storage[selected[0],selected[1]]
          next if !pokemon
          command=pbShowCommands(
             _INTL("{1} is selected.",pokemon.name),[_INTL("Withdraw"),
             _INTL("Summary"),_INTL("Mark"),_INTL("Release"),_INTL("Cancel")])
          case command
            when 0 # Withdraw
              pbWithdraw(selected,nil)
            when 1 # Summary
              pbSummary(selected,nil)
            when 2 # Mark
              pbMark(selected,nil)
            when 3 # Release
              pbRelease(selected,nil)
          end
        end
      end
      @scene.pbCloseBox
    elsif command==1
### DEPOSIT ####################################################################
      @scene.pbStartBox(self,command)
      loop do
        selected=@scene.pbSelectParty(@storage.party)
        if selected==-3 # Close box
          if pbConfirm(_INTL("Exit from the Box?"))
            break
          else
            next
          end
        end
        if selected<0
          if pbConfirm(_INTL("Continue Box operations?"))
            next
          else
            break
          end
        else
          pokemon=@storage[-1,selected]
          next if !pokemon
          command=pbShowCommands(
             _INTL("{1} is selected.",pokemon.name),[_INTL("Store"),
             _INTL("Summary"),_INTL("Mark"),_INTL("Release"),_INTL("Cancel")])
          case command
            when 0 # Store
              pbStore([-1,selected],nil)
            when 1 # Summary
              pbSummary([-1,selected],nil)
            when 2 # Mark
              pbMark([-1,selected],nil)
            when 3 # Release
              pbRelease([-1,selected],nil)
          end
        end
      end
      @scene.pbCloseBox
    elsif command==0
### MOVE #######################################################################
      @scene.pbStartBox(self,command)
      loop do
        selected=@scene.pbSelectBox(@storage.party)
        if selected && selected[0]==-3 # Close box
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          if pbConfirm(_INTL("Exit from the Box?"))
            break
          else
            next
          end
        end
        if selected==nil
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          if pbConfirm(_INTL("Continue Box operations?"))
            next
          else
            break
          end
        elsif selected[0]==-4 # Box name
          pbBoxCommands
        else
          pokemon=@storage[selected[0],selected[1]]
#### SARDINES - v17 - START
          heldpoke = pbHeldPokemon
          next if !pokemon && !heldpoke
          if @scene.quickswap
            if @heldpkmn
              (pokemon) ? pbSwap(selected) : pbPlace(selected)
            else
              pbHold(selected)
            end
          else
#### SARDINES - v17 - END
          commands=[
             _INTL("Move"),
             _INTL("Summary"),
             _INTL("Withdraw"),
             _INTL("Item"),
             _INTL("Mark"),
             _INTL("Release"),
             _INTL("Cancel")
          ]
          commands.push(_INTL("Debug")) if $DEBUG
          heldpoke=pbHeldPokemon
          if heldpoke
            helptext=_INTL("{1} is selected.",heldpoke.name)
            commands[0]=pokemon ? _INTL("Shift") : _INTL("Place")
          elsif pokemon
            helptext=_INTL("{1} is selected.",pokemon.name)
            commands[0]=_INTL("Move")
          else
            next
          end
          if selected[0]==-1
            commands[2]=_INTL("Store")
          else
            commands[2]=_INTL("Withdraw")
          end
          command=pbShowCommands(helptext,commands)
          case command
            when 0 # Move/Shift/Place
              if @heldpkmn && pokemon
                pbSwap(selected)
              elsif @heldpkmn
                pbPlace(selected)
              else
                pbHold(selected)
              end
            when 1 # Summary
              pbSummary(selected,@heldpkmn)
            when 2 # Withdraw
              if selected[0]==-1
                pbStore(selected,@heldpkmn)
              else
                pbWithdraw(selected,@heldpkmn)
              end
            when 3 # Item
              pbItem(selected,@heldpkmn)
            when 4 # Mark
              pbMark(selected,@heldpkmn)
            when 5 # Release
              pbRelease(selected,@heldpkmn)
            when 6
            when 7  
              if $DEBUG
                pkmn=@heldpkmn ? @heldpkmn : pokemon
                debugMenu(selected,pkmn,heldpoke)
              else
                break
              end
          end
          end
        end
      end
      @scene.pbCloseBox
    elsif command==3
      @scene.pbStartBox(self,command)
      @scene.pbCloseBox
    end
  end

  def debugMenu(selected,pkmn,heldpoke)
    command=0
    loop do
      command=@scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),[
         _INTL("Level"),
         _INTL("Species"),
         _INTL("Moves"),
         _INTL("Gender"),
         _INTL("Ability"),
         _INTL("Nature"),
         _INTL("Shininess"),
         _INTL("Form"),
         _INTL("Happiness"),
         _INTL("EV/IV/pID"),
         _INTL("Pokérus"),
         _INTL("Ownership"),
         _INTL("Nickname"),
         _INTL("Poké Ball"),
         _INTL("Ribbons"),
         _INTL("Egg"),
         _INTL("Shadow Pokémon"),
         _INTL("Make Mystery Gift"),
         _INTL("Duplicate"),
         _INTL("Delete"),
         _INTL("Cancel")
      ],command)
      case command
        ### Cancel ###
        when -1, 20
          break
        ### Level ###
        when 0
          params=ChooseNumberParams.new
          params.setRange(1,PBExperience::MAXLEVEL)
          params.setDefaultValue(pkmn.level)
          level=Kernel.pbMessageChooseNumber(
             _INTL("Set the Pokémon's level (max. {1}).",PBExperience::MAXLEVEL),params)
          if level!=pkmn.level
            pkmn.level=level
            pkmn.calcStats
            pbDisplay(_INTL("{1}'s level was set to {2}.",pkmn.name,pkmn.level))
            @scene.pbHardRefresh
          end
        ### Species ###
        when 1
          species=pbChooseSpecies(pkmn.species)
          if species!=0
            oldspeciesname=PBSpecies.getName(pkmn.species)
            pkmn.species=species
            pkmn.calcStats
            pkmn.poklevel = level
            oldname=pkmn.name
            pkmn.name=PBSpecies.getName(pkmn.species) if pkmn.name==oldspeciesname
            pbDisplay(_INTL("{1}'s species was changed to {2}.",oldname,PBSpecies.getName(pkmn.species)))
            pbSeenForm(pkmn)
            @scene.pbHardRefresh
          end
        ### Moves ###
        when 2
          cmd=0
          loop do
            cmd=@scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),[
               _INTL("Teach move"),
               _INTL("Forget move"),
               _INTL("Reset movelist"),
               _INTL("Reset initial moves")],cmd)
            # Break
            if cmd==-1
              break
            # Teach move
            elsif cmd==0
              move=pbChooseMoveList
              if move!=0
                pbLearnMove(pkmn,move)
                @scene.pbHardRefresh
              end
            # Forget Move
            elsif cmd==1
              pbChooseMove(pkmn,1,2)
              if pbGet(1)>=0
                pbDeleteMove(pkmn,pbGet(1))
                pbDisplay(_INTL("{1} forgot {2}.",pkmn.name,pbGet(2)))
                @scene.pbHardRefresh
              end
            # Reset Movelist
            elsif cmd==2
              pkmn.resetMoves
              pbDisplay(_INTL("{1}'s moves were reset.",pkmn.name))
              @scene.pbHardRefresh
            # Reset initial moves
            elsif cmd==3
              pkmn.pbRecordFirstMoves
              pbDisplay(_INTL("{1}'s moves were set as its first-known moves.",pkmn.name))
              @scene.pbHardRefresh
            end
          end
        ### Gender ###
        when 3
          if pkmn.gender==2
            pbDisplay(_INTL("{1} is genderless.",pkmn.name))
          else
            cmd=0
            loop do
              oldgender=(pkmn.isMale?) ? _INTL("male") : _INTL("female")
              msg=[_INTL("Gender {1} is natural.",oldgender),
                   _INTL("Gender {1} is being forced.",oldgender)][pkmn.genderflag ? 1 : 0]
              cmd=@scene.pbShowCommands(msg,[
                 _INTL("Make male"),
                 _INTL("Make female"),
                 _INTL("Remove override")],cmd)
              # Break
              if cmd==-1
                break
              # Make male
              elsif cmd==0
                pkmn.setGender(0)
                if pkmn.isMale?
                  pbDisplay(_INTL("{1} is now male.",pkmn.name))
                else
                  pbDisplay(_INTL("{1}'s gender couldn't be changed.",pkmn.name))
                end
              # Make female
              elsif cmd==1
                pkmn.setGender(1)
                if pkmn.isFemale?
                  pbDisplay(_INTL("{1} is now female.",pkmn.name))
                else
                  pbDisplay(_INTL("{1}'s gender couldn't be changed.",pkmn.name))
                end
              # Remove override
              elsif cmd==2
                pkmn.genderflag=nil
                pbDisplay(_INTL("Gender override removed."))
              end
              pbSeenForm(pkmn)
              @scene.pbHardRefresh
            end
          end
        ### Ability ###
        when 4
          cmd=0
          loop do
            abils=pkmn.getAbilityList
            oldabil=PBAbilities.getName(pkmn.ability)
            commands=[]
            for i in 0...abils[0].length
              commands.push((abils[1][i]<2 ? "" : "(H) ")+PBAbilities.getName(abils[0][i]))
            end
            commands.push(_INTL("Remove override"))
            msg=[_INTL("Ability {1} is natural.",oldabil),
                 _INTL("Ability {1} is being forced.",oldabil)][pkmn.abilityflag ? 1 : 0]
            cmd=@scene.pbShowCommands(msg,commands,cmd)
            # Break
            if cmd==-1
              break
            # Set ability override
            elsif cmd>=0 && cmd<abils[0].length
              pkmn.setAbility(abils[1][cmd])
            # Remove override
            elsif cmd==abils[0].length
              pkmn.abilityflag=nil
            end
            @scene.pbHardRefresh
          end
        ### Nature ###
        when 5
          cmd=0
          loop do
            oldnature=PBNatures.getName(pkmn.nature)
            commands=[]
            (PBNatures.getCount).times do |i|
              commands.push(PBNatures.getName(i))
            end
            commands.push(_INTL("Remove override"))
            msg=[_INTL("Nature {1} is natural.",oldnature),
                 _INTL("Nature {1} is being forced.",oldnature)][pkmn.natureflag ? 1 : 0]
            cmd=@scene.pbShowCommands(msg,commands,cmd)
            # Break
            if cmd==-1
              break
            # Set nature override
            elsif cmd>=0 && cmd<PBNatures.getCount
              pkmn.setNature(cmd)
              pkmn.calcStats
            # Remove override
            elsif cmd==PBNatures.getCount
              pkmn.natureflag=nil
            end
            @scene.pbHardRefresh
          end
        ### Shininess ###
        when 6
          cmd=0
          loop do
            oldshiny=(pkmn.isShiny?) ? _INTL("shiny") : _INTL("normal")
            msg=[_INTL("Shininess ({1}) is natural.",oldshiny),
                 _INTL("Shininess ({1}) is being forced.",oldshiny)][pkmn.shinyflag!=nil ? 1 : 0]
            cmd=@scene.pbShowCommands(msg,[
                 _INTL("Make shiny"),
                 _INTL("Make normal"),
                 _INTL("Remove override")],cmd)
            # Break
            if cmd==-1
              break
            # Make shiny
            elsif cmd==0
              pkmn.makeShiny
            # Make normal
            elsif cmd==1
              pkmn.makeNotShiny
            # Remove override
            elsif cmd==2
              pkmn.shinyflag=nil
            end
            @scene.pbHardRefresh
          end
        ### Form ###
        when 7
          params=ChooseNumberParams.new
          params.setRange(0,100)
          params.setDefaultValue(pkmn.form)
          f=Kernel.pbMessageChooseNumber(
             _INTL("Set the Pokémon's form."),params)
          if f!=pkmn.form
            pkmn.form=f
            pbDisplay(_INTL("{1}'s form was set to {2}.",pkmn.name,pkmn.form))
            pbSeenForm(pkmn)
            @scene.pbHardRefresh
          end
        ### Happiness ###
        when 8
          params=ChooseNumberParams.new
          params.setRange(0,255)
          params.setDefaultValue(pkmn.happiness)
          h=Kernel.pbMessageChooseNumber(
             _INTL("Set the Pokémon's happiness (max. 255)."),params)
          if h!=pkmn.happiness
            pkmn.happiness=h
            pbDisplay(_INTL("{1}'s happiness was set to {2}.",pkmn.name,pkmn.happiness))
            @scene.pbHardRefresh
          end
        ### EV/IV/pID ###
        when 9
          stats=[_INTL("HP"),_INTL("Attack"),_INTL("Defense"),
                 _INTL("Speed"),_INTL("Sp. Attack"),_INTL("Sp. Defense")]
          cmd=0
          loop do
            persid=sprintf("0x%08X",pkmn.personalID)
            cmd=@scene.pbShowCommands(_INTL("Personal ID is {1}.",persid),[
               _INTL("Set EVs"),
               _INTL("Set IVs"),
               _INTL("Randomise pID")],cmd)
            case cmd
              # Break
              when -1
                break
              # Set EVs
              when 0
                cmd2=0
                loop do
                  evcommands=[]
                  for i in 0...stats.length
                    evcommands.push(stats[i]+" (#{pkmn.ev[i]})")
                  end
                  cmd2=@scene.pbShowCommands(_INTL("Change which EV?"),evcommands,cmd2)
                  if cmd2==-1
                    break
                  elsif cmd2>=0 && cmd2<stats.length
                    params=ChooseNumberParams.new
                    params.setRange(0,255)
                    params.setDefaultValue(pkmn.ev[cmd2])
                    params.setCancelValue(pkmn.ev[cmd2])
                    f=Kernel.pbMessageChooseNumber(
                       _INTL("Set the EV for {1} (max. 255).",stats[cmd2]),params)
                    pkmn.ev[cmd2]=f
                    pkmn.calcStats
                    @scene.pbHardRefresh
                  end
                end
              # Set IVs
              when 1
                cmd2=0
                loop do
                  hiddenpower=pbHiddenPower(pkmn.iv)
                  msg=_INTL("Hidden Power:\n{1}, power {2}.",PBTypes.getName(hiddenpower[0]),hiddenpower[1])
                  ivcommands=[]
                  for i in 0...stats.length
                    ivcommands.push(stats[i]+" (#{pkmn.iv[i]})")
                  end
                  ivcommands.push(_INTL("Randomise all"))
                  cmd2=@scene.pbShowCommands(msg,ivcommands,cmd2)
                  if cmd2==-1
                    break
                  elsif cmd2>=0 && cmd2<stats.length
                    params=ChooseNumberParams.new
                    params.setRange(0,31)
                    params.setDefaultValue(pkmn.iv[cmd2])
                    params.setCancelValue(pkmn.iv[cmd2])
                    f=Kernel.pbMessageChooseNumber(
                       _INTL("Set the IV for {1} (max. 31).",stats[cmd2]),params)
                    pkmn.iv[cmd2]=f
                    pkmn.calcStats
                    @scene.pbHardRefresh
                  elsif cmd2==ivcommands.length-1
                    pkmn.iv[0]=rand(32)
                    pkmn.iv[1]=rand(32)
                    pkmn.iv[2]=rand(32)
                    pkmn.iv[3]=rand(32)
                    pkmn.iv[4]=rand(32)
                    pkmn.iv[5]=rand(32)
                    pkmn.calcStats
                    @scene.pbHardRefresh
                  end
                end
              # Randomise pID
              when 2
                pkmn.personalID=rand(256)
                pkmn.personalID|=rand(256)<<8
                pkmn.personalID|=rand(256)<<16
                pkmn.personalID|=rand(256)<<24
                pkmn.calcStats
                @scene.pbHardRefresh
            end
          end
        ### Pokérus ###
        when 10
          cmd=0
          loop do
            pokerus=(pkmn.pokerus) ? pkmn.pokerus : 0
            msg=[_INTL("{1} doesn't have Pokérus.",pkmn.name),
                 _INTL("Has strain {1}, infectious for {2} more days.",pokerus/16,pokerus%16),
                 _INTL("Has strain {1}, not infectious.",pokerus/16)][pkmn.pokerusStage]
            cmd=@scene.pbShowCommands(msg,[
                 _INTL("Give random strain"),
                 _INTL("Make not infectious"),
                 _INTL("Clear Pokérus")],cmd)
            # Break
            if cmd==-1
              break
            # Give random strain
            elsif cmd==0
              pkmn.givePokerus
            # Make not infectious
            elsif cmd==1
              strain=pokerus/16
              p=strain<<4
              pkmn.pokerus=p
            # Clear Pokérus
            elsif cmd==2
              pkmn.pokerus=0
            end
          end
        ### Ownership ###
        when 11
          cmd=0
          loop do
            gender=[_INTL("Male"),_INTL("Female"),_INTL("Unknown")][pkmn.otgender]
            msg=[_INTL("Player's Pokémon\n{1}\n{2}\n{3} ({4})",pkmn.ot,gender,pkmn.publicID,pkmn.trainerID),
                 _INTL("Foreign Pokémon\n{1}\n{2}\n{3} ({4})",pkmn.ot,gender,pkmn.publicID,pkmn.trainerID)
                ][pkmn.isForeign?($Trainer) ? 1 : 0]
            cmd=@scene.pbShowCommands(msg,[
                 _INTL("Make player's"),
                 _INTL("Set OT's name"),
                 _INTL("Set OT's gender"),
                 _INTL("Random foreign ID"),
                 _INTL("Set foreign ID")],cmd)
            # Break
            if cmd==-1
              break
            # Make player's
            elsif cmd==0
              pkmn.trainerID=$Trainer.id
              pkmn.ot=$Trainer.name
              pkmn.otgender=$Trainer.gender
            # Set OT's name
            elsif cmd==1
              newot=pbEnterPlayerName(_INTL("{1}'s OT's name?",pkmn.name),1,12)
              pkmn.ot=newot
            # Set OT's gender
            elsif cmd==2
              cmd2=@scene.pbShowCommands(_INTL("Set OT's gender."),
                 [_INTL("Male"),_INTL("Female"),_INTL("Unknown")])
              pkmn.otgender=cmd2 if cmd2>=0
            # Random foreign ID
            elsif cmd==3
              pkmn.trainerID=$Trainer.getForeignID
            # Set foreign ID
            elsif cmd==4
              params=ChooseNumberParams.new
              params.setRange(0,65535)
              params.setDefaultValue(pkmn.publicID)
              val=Kernel.pbMessageChooseNumber(
                 _INTL("Set the new ID (max. 65535)."),params)
              pkmn.trainerID=val
              pkmn.trainerID|=val<<16
            end
          end
        ### Nickname ###
        when 12
          cmd=0
          loop do
            speciesname=PBSpecies.getName(pkmn.species)
            msg=[_INTL("{1} has the nickname {2}.",speciesname,pkmn.name),
                 _INTL("{1} has no nickname.",speciesname)][pkmn.name==speciesname ? 1 : 0]
            cmd=@scene.pbShowCommands(msg,[
                 _INTL("Rename"),
                 _INTL("Erase name")],cmd)
            # Break
            if cmd==-1
              break
            # Rename
            elsif cmd==0
              newname=pbEnterPokemonName(_INTL("{1}'s nickname?",speciesname),0,12,"",pkmn)
              pkmn.name=(newname=="") ? speciesname : newname
              @scene.pbHardRefresh
            # Erase name
            elsif cmd==1
              pkmn.name=speciesname
            end
          end
        ### Poké Ball ###
        when 13
          cmd=0
          loop do
            oldball=PBItems.getName(pbBallTypeToBall(pkmn.ballused))
            commands=[]; balls=[]
            for key in $BallTypes.keys
              item=getID(PBItems,$BallTypes[key])
              balls.push([key,PBItems.getName(item)]) if item && item>0
            end
            balls.sort! {|a,b| a[1]<=>b[1]}
            for i in 0...commands.length
              cmd=i if pkmn.ballused==balls[i][0]
            end
            for i in balls
              commands.push(i[1])
            end
            cmd=@scene.pbShowCommands(_INTL("{1} used.",oldball),commands,cmd)
            if cmd==-1
              break
            else
              pkmn.ballused=balls[cmd][0]
            end
          end
        ### Ribbons ###
        when 14
          cmd=0
          loop do
            commands=[]
            for i in 1..PBRibbons.maxValue
              commands.push(_INTL("{1} {2}",
                 pkmn.hasRibbon?(i) ? "[X]" : "[  ]",PBRibbons.getName(i)))
            end
            cmd=@scene.pbShowCommands(_INTL("{1} ribbons.",pkmn.ribbonCount),commands,cmd)
            if cmd==-1
              break
            elsif cmd>=0 && cmd<commands.length
              if pkmn.hasRibbon?(cmd+1)
                pkmn.takeRibbon(cmd+1)
              else
                pkmn.giveRibbon(cmd+1)
              end
            end
          end
        ### Egg ###
        when 15
          cmd=0
          loop do
            msg=[_INTL("Not an egg"),
                 _INTL("Egg with eggsteps: {1}.",pkmn.eggsteps)][pkmn.isEgg? ? 1 : 0]
            cmd=@scene.pbShowCommands(msg,[
                 _INTL("Make egg"),
                 _INTL("Make Pokémon"),
                 _INTL("Set eggsteps to 1")],cmd)
            # Break
            if cmd==-1
              break
            # Make egg
            elsif cmd==0
              if pbHasEgg?(pkmn.species) ||
                 pbConfirm(_INTL("{1} cannot be an egg. Make egg anyway?",PBSpecies.getName(pkmn.species)))
                pkmn.level=EGGINITIALLEVEL
                pkmn.calcStats
                pkmn.name=_INTL("Egg")
                pkmn.eggsteps=$pkmn_dex[pkmn.species][10]
                pkmn.hatchedMap=0
                pkmn.obtainMode=1
                @scene.pbHardRefresh
              end
            # Make Pokémon
            elsif cmd==1
              pkmn.name=PBSpecies.getName(pkmn.species)
              pkmn.eggsteps=0
              pkmn.hatchedMap=0
              pkmn.obtainMode=0
              @scene.pbHardRefresh
            # Set eggsteps to 1
            elsif cmd==2
              pkmn.eggsteps=1 if pkmn.eggsteps>0
            end
          end
        ### Shadow Pokémon ###
        when 16
          cmd=0
          loop do
            msg=[_INTL("Not a Shadow Pokémon."),
                 _INTL("Heart gauge is {1}.",pkmn.heartgauge)][(pkmn.isShadow? rescue false) ? 1 : 0]
            cmd=@scene.pbShowCommands(msg,[
               _INTL("Make Shadow"),
               _INTL("Lower heart gauge")],cmd)
            # Break
            if cmd==-1
              break
            # Make Shadow
            elsif cmd==0
              if !(pkmn.isShadow? rescue false) && pkmn.respond_to?("makeShadow")
                pkmn.makeShadow
                pbDisplay(_INTL("{1} is now a Shadow Pokémon.",pkmn.name))
                @scene.pbHardRefresh
              else
                pbDisplay(_INTL("{1} is already a Shadow Pokémon.",pkmn.name))
              end
            # Lower heart gauge
            elsif cmd==1
              if (pkmn.isShadow? rescue false)
                prev=pkmn.heartgauge
                pkmn.adjustHeart(-700)
                Kernel.pbMessage(_INTL("{1}'s heart gauge was lowered from {2} to {3} (now stage {4}).",
                   pkmn.name,prev,pkmn.heartgauge,pkmn.heartStage))
                pbReadyToPurify(pkmn)
              else
                Kernel.pbMessage(_INTL("{1} is not a Shadow Pokémon.",pkmn.name))
              end
            end
          end
        ### Make Mystery Gift ###
        when 17
          pbCreateMysteryGift(0,pkmn)
        ### Duplicate ###
        when 18
          if pbConfirm(_INTL("Are you sure you want to copy this Pokémon?"))
            clonedpkmn=pkmn.clone
            clonedpkmn.iv=pkmn.iv.clone
            clonedpkmn.ev=pkmn.ev.clone
            if @storage.pbMoveCaughtToParty(clonedpkmn)
              if selected[0]!=-1
                pbDisplay(_INTL("The duplicated Pokémon was moved to your party."))
              end
            else
              oldbox=@storage.currentBox
              newbox=@storage.pbStoreCaught(clonedpkmn)
              if newbox<0
                pbDisplay(_INTL("All boxes are full."))
              elsif newbox!=oldbox
                pbDisplay(_INTL("The duplicated Pokémon was moved to box \"{1}.\"",@storage[newbox].name))
                @storage.currentBox=oldbox
              end
            end
            @scene.pbHardRefresh
            break
          end
        ### Delete ###
        when 19
          if pbConfirm(_INTL("Are you sure you want to delete this Pokémon?"))
            @scene.pbRelease(selected,heldpoke)
            if heldpoke
              @heldpkmn=nil
            else
              @storage.pbDelete(selected[0],selected[1])
            end
            @scene.pbRefresh
            pbDisplay(_INTL("The Pokémon was deleted."))
            break
          end
      end
    end
  end

  def selectPokemon(index)
    pokemon=@storage[@currentbox,index]
    if !pokemon
      return nil
    end
  end
end



class Interpolator
  ZOOM_X=1
  ZOOM_Y=2
  X=3
  Y=4
  OPACITY=5
  COLOR=6
  WAIT=7

  def initialize
    @tweening=false
    @tweensteps=[]
    @sprite=nil
    @frames=0
    @step=0
  end

  def tweening?
    return @tweening
  end

  def tween(sprite,items,frames)
    @tweensteps=[]
    if sprite && !sprite.disposed? && frames>0
      @frames=frames
      @step=0
      @sprite=sprite
      for item in items
        case item[0]
          when ZOOM_X
            @tweensteps[item[0]]=[sprite.zoom_x,item[1]-sprite.zoom_x]
          when ZOOM_Y
            @tweensteps[item[0]]=[sprite.zoom_y,item[1]-sprite.zoom_y]
          when X
            @tweensteps[item[0]]=[sprite.x,item[1]-sprite.x]
          when Y
            @tweensteps[item[0]]=[sprite.y,item[1]-sprite.y]
          when OPACITY
            @tweensteps[item[0]]=[sprite.opacity,item[1]-sprite.opacity]
          when COLOR
            @tweensteps[item[0]]=[sprite.color.clone,Color.new(
               item[1].red-sprite.color.red,
               item[1].green-sprite.color.green,
               item[1].blue-sprite.color.blue,
               item[1].alpha-sprite.color.alpha
            )]
        end
      end
      @tweening=true
    end
  end

  def update
    if @tweening
      t=(@step*1.0)/@frames
      for i in 0...@tweensteps.length
        item=@tweensteps[i]
        next if !item
        case i
          when ZOOM_X
            @sprite.zoom_x=item[0]+item[1]*t
          when ZOOM_Y
            @sprite.zoom_y=item[0]+item[1]*t
          when X
            @sprite.x=item[0]+item[1]*t
          when Y
            @sprite.y=item[0]+item[1]*t
          when OPACITY
            @sprite.opacity=item[0]+item[1]*t
          when COLOR
            @sprite.color=Color.new(
               item[0].red+item[1].red*t,
               item[0].green+item[1].green*t,
               item[0].blue+item[1].blue*t,
               item[0].alpha+item[1].alpha*t
            )
        end
      end
      @step+=1
      if @step==@frames
        @step=0
        @frames=0
        @tweening=false
      end
    end
  end
end



class PokemonBoxIcon < IconSprite
  def initialize(pokemon,viewport=nil)
    super(0,0,viewport)
    @release=Interpolator.new
    @startRelease=false
    @pokemon=pokemon
    if pokemon
      self.setBitmap(pbPokemonIconFile(pokemon))
    end
    self.src_rect=Rect.new(0,0,64,64)
  end

  def release
    self.ox=32
    self.oy=32
    self.x+=32
    self.y+=32
    @release.tween(self,[
       [Interpolator::ZOOM_X,0],
       [Interpolator::ZOOM_Y,0],
       [Interpolator::OPACITY,0]
    ],100)
    @startRelease=true
  end

  def releasing?
    return @release.tweening?
  end

  def update
    super
    @release.update
    self.color=Color.new(0,0,0,0)
    dispose if @startRelease && !releasing?
  end
end



class PokemonBoxArrow < SpriteWrapper
  attr_accessor :quickswap
  
  def initialize(viewport=nil)
    super(viewport)
    @frame=0
    @holding=false
    @updating=false
    @quickswap = false
    @grabbingState=0
    @placingState=0
    @heldpkmn=nil
    @swapsprite=nil
    @fist=AnimatedBitmap.new("Graphics/Pictures/Storage/boxfist")
    @point1=AnimatedBitmap.new("Graphics/Pictures/Storage/boxpoint1")
    @point2=AnimatedBitmap.new("Graphics/Pictures/Storage/boxpoint2")
    @grab=AnimatedBitmap.new("Graphics/Pictures/Storage/boxgrab")
#### SARDINES - v17 - START
    @fistq=AnimatedBitmap.new("Graphics/Pictures/Storage/boxfist_q")
    @point1q=AnimatedBitmap.new("Graphics/Pictures/Storage/boxpoint1_q")
    @point2q=AnimatedBitmap.new("Graphics/Pictures/Storage/boxpoint2_q")
    @grabq=AnimatedBitmap.new("Graphics/Pictures/Storage/boxgrab_q")
#### SARDINES - v17 - END
    @currentBitmap=@fist
    @spriteX=self.x
    @spriteY=self.y
    self.bitmap=@currentBitmap.bitmap
  end

  def heldPokemon
    @heldpkmn=nil if @heldpkmn && @heldpkmn.disposed?
    @holding=false if !@heldpkmn
    return @heldpkmn
  end

  def visible=(value)
    super
    sprite=heldPokemon
    sprite.visible=value if sprite
  end

  def color=(value)
    super
    sprite=heldPokemon
    sprite.color=value if sprite
  end

  def dispose
    @fist.dispose
    @point1.dispose
    @point2.dispose
    @grab.dispose
    @heldpkmn.dispose if @heldpkmn
    super
  end

  def holding?
    return self.heldPokemon && @holding
  end

  def grabbing?
    return @grabbingState>0
  end

  def placing?
    return @placingState>0
  end

  def x=(value)
    super
    @spriteX=x if !@updating
    heldPokemon.x=self.x if holding?
  end

  def y=(value)
    super
    @spriteY=y if !@updating
    heldPokemon.y=self.y+16 if holding?
  end

  def setSprite(sprite)
    if holding?
      @heldpkmn=sprite
      @heldpkmn.viewport=self.viewport if @heldpkmn
      @heldpkmn.z=1 if @heldpkmn
      @holding=false if !@heldpkmn
      self.z=2
    end
  end

  def deleteSprite
    @holding=false
    if @heldpkmn
      @heldpkmn.dispose
      @heldpkmn=nil
    end
  end

  def grab(sprite)
    @grabbingState=1
    @heldpkmn=sprite
    @heldpkmn.viewport=self.viewport
    @heldpkmn.z=1
    self.z=2
  end

  def place
    @placingState=1
  end

  def release
    if @heldpkmn
      @heldpkmn.release
    end
  end

  def update
    @updating=true
    super
    heldpkmn=heldPokemon
    heldpkmn.update if heldpkmn
    @fist.update
    @point2.update
    @point1.update
    @grab.update
    self.bitmap=@currentBitmap.bitmap
    @holding=false if !heldpkmn
    if @grabbingState>0
      if @grabbingState<=8
        @currentBitmap=@grab
        if @quickswap
          @currentBitmap=@grabq
        end
        self.bitmap=@currentBitmap.bitmap
        self.y=@spriteY+(@grabbingState)*2
        @grabbingState+=1
      elsif @grabbingState<=16
        @holding=true
        @currentBitmap=@fist
        if @quickswap
          @currentBitmap=@fistq
        end
        self.bitmap=@currentBitmap.bitmap
        self.y=@spriteY+(16-@grabbingState)*2
        @grabbingState+=1
      else
        @grabbingState=0
      end
    elsif @placingState>0
      if @placingState<=8
        @currentBitmap=@fist
        if @quickswap
          @currentBitmap=@fistq
        end
        self.bitmap=@currentBitmap.bitmap
        self.y=@spriteY+(@placingState)*2
        @placingState+=1
      elsif @placingState<=16
        @holding=false
        @heldpkmn=nil
        @currentBitmap=@grab
        if @quickswap
          @currentBitmap=@grabq
        end
        self.bitmap=@currentBitmap.bitmap
        self.y=@spriteY+(16-@placingState)*2
        @placingState+=1
      else
        @placingState=0
      end
    elsif holding?
      @currentBitmap=@fist
      if @quickswap
        @currentBitmap=@fistq
      end
      self.bitmap=@currentBitmap.bitmap
    else
      self.x=@spriteX
      self.y=@spriteY
      if (@frame/20)==1
        @currentBitmap=@point2
        if @quickswap
          @currentBitmap=@point2q
        end
        self.bitmap=@currentBitmap.bitmap
      else
        @currentBitmap=@point1
        if @quickswap
          @currentBitmap=@point1q
        end
        self.bitmap=@currentBitmap.bitmap
      end
    end
    @frame+=1
    @frame=0 if @frame==40
    @updating=false
  end
end



class PokemonBoxPartySprite < SpriteWrapper
  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index]=nil
    @pokemonsprites.compact!
    refresh
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index,sprite)
    @pokemonsprites[index]=sprite
    @pokemonsprites.compact!
    refresh
  end

  def grabPokemon(index,arrow)
    sprite=@pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index]=nil
      @pokemonsprites.compact!
      refresh
    end
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].color=pbSrcOver(@pokemonsprites[i].color,value)
      end
    end
    refresh
  end

  def visible=(value)
    super
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible=value
      end
    end
    refresh
  end

  def initialize(party,viewport=nil)
    super(viewport)
    @boxbitmap=AnimatedBitmap.new("Graphics/Pictures/Storage/boxpartytab")
    @pokemonsprites=[]
    @party=party
    for i in 0...6
      @pokemonsprites[i]=nil
      pokemon=@party[i]
      if pokemon
        @pokemonsprites[i]=PokemonBoxIcon.new(pokemon,viewport)
      end
    end
    @contents=BitmapWrapper.new(172,352)
    self.bitmap=@contents
    self.x=182
    self.y=Graphics.height-352
    refresh
  end

  def dispose
    for i in 0...6
      @pokemonsprites[i].dispose if @pokemonsprites[i]
    end
    @contents.dispose
    @boxbitmap.dispose
    super
  end

  def refresh
    @contents.blt(0,0,@boxbitmap.bitmap,Rect.new(0,0,172,352))
    xvalues=[16,92,16,92,16,92]
    yvalues=[0,16,64,80,128,144]
    for j in 0...6
      @pokemonsprites[j]=nil if @pokemonsprites[j] && @pokemonsprites[j].disposed?
    end
    @pokemonsprites.compact!
    for j in 0...6
      sprite=@pokemonsprites[j]
      if sprite && !sprite.disposed?
        sprite.viewport=self.viewport
        sprite.z=0
        sprite.x=self.x+xvalues[j]
        sprite.y=self.y+yvalues[j]
      end
    end
  end

  def update
    super
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].update
      end
    end
  end
end



class MosaicPokemonSprite < PokemonSprite
  def initialize(*args)
    super(*args)
    @mosaic=0
    @inrefresh=false
    @mosaicbitmap=nil
    @mosaicbitmap2=nil
    @oldbitmap=self.bitmap
  end

  attr_reader :mosaic

  def mosaic=(value)
    @mosaic=value
    @mosaic=0 if @mosaic<0
    mosaicRefresh(@oldbitmap)
  end

  def dispose
    super
    @mosaicbitmap.dispose if @mosaicbitmap
    @mosaicbitmap=nil
    @mosaicbitmap2.dispose if @mosaicbitmap2
    @mosaicbitmap2=nil
  end

  def bitmap=(value)
    super
    mosaicRefresh(value)
  end

  def mosaicRefresh(bitmap)
    return if @inrefresh
    @inrefresh=true
    @oldbitmap=bitmap
    if @mosaic<=0 || !@oldbitmap
      @mosaicbitmap.dispose if @mosaicbitmap
      @mosaicbitmap=nil
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap2=nil
      self.bitmap=@oldbitmap
    else
      newWidth=[(@oldbitmap.width/@mosaic),1].max
      newHeight=[(@oldbitmap.height/@mosaic),1].max
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap=pbDoEnsureBitmap(@mosaicbitmap,newWidth,newHeight)
      @mosaicbitmap.clear
      @mosaicbitmap2=pbDoEnsureBitmap(@mosaicbitmap2,
         @oldbitmap.width,@oldbitmap.height)
      @mosaicbitmap2.clear
      @mosaicbitmap.stretch_blt(Rect.new(0,0,newWidth,newHeight),
         @oldbitmap,@oldbitmap.rect)
      @mosaicbitmap2.stretch_blt(
         Rect.new(-@mosaic/2+1,-@mosaic/2+1,
         @mosaicbitmap2.width,@mosaicbitmap2.height),
         @mosaicbitmap,Rect.new(0,0,newWidth,newHeight))
      self.bitmap=@mosaicbitmap2
    end
    @inrefresh=false
  end
end



class AutoMosaicPokemonSprite < MosaicPokemonSprite
  def update
    super
    self.mosaic-=1
  end
end



class PokemonBoxSprite < SpriteWrapper
  attr_accessor :refreshBox
  attr_accessor :refreshSprites
  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index]=nil
    refresh
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index,sprite)
    @pokemonsprites[index]=sprite
    refresh
  end

  def grabPokemon(index,arrow)
    sprite=@pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index]=nil
      refresh
    end
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    if @refreshSprites
      for i in 0...30
        if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
          @pokemonsprites[i].color=value
        end
      end
    end
    refresh
  end

  def visible=(value)
    super
    for i in 0...30
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible=value
      end
    end
    refresh
  end

  def getBoxBitmap
    if !@bg || @bg!=@storage[@boxnumber].background
      curbg=@storage[@boxnumber].background
      if !curbg || curbg.length==0
        boxid=@boxnumber%24
        @bg="box#{boxid}"
      else
        @bg="#{curbg}"
      end
      @boxbitmap.dispose if @boxbitmap
      @boxbitmap=AnimatedBitmap.new("Graphics/Pictures/Storage/#{@bg}")
    end
  end

  def initialize(storage,boxnumber,viewport=nil)
    super(viewport)
    @storage=storage
    @boxnumber=boxnumber
    @refreshBox=true
    @refreshSprites=true
    @bg=nil
    @boxbitmap=nil
    getBoxBitmap
    @pokemonsprites=[]
    for i in 0...30
      @pokemonsprites[i]=nil
      pokemon=@storage[boxnumber,i]
      if pokemon
        @pokemonsprites[i]=PokemonBoxIcon.new(pokemon,viewport)
      else
        @pokemonsprites[i]=PokemonBoxIcon.new(nil,viewport)
      end
    end
    @contents=BitmapWrapper.new(324,296)
    self.bitmap=@contents
    self.x=184
    self.y=18
    refresh
  end

  def dispose
    if !disposed?
      for i in 0...30
        @pokemonsprites[i].dispose if @pokemonsprites[i]
        @pokemonsprites[i]=nil
      end
      @contents.dispose
      @boxbitmap.dispose
      super
    end
  end

  def refresh
    if @refreshBox
      boxname=@storage[@boxnumber].name
      getBoxBitmap
      @contents.blt(0,0,@boxbitmap.bitmap,Rect.new(0,0,324,296))
      pbSetSystemFont(@contents)
      widthval=@contents.text_size(boxname).width
      xval=162-(widthval/2)
      pbDrawShadowText(@contents,xval,8,widthval,32,boxname,
         Color.new(248,248,248),Color.new(40,48,48))
      @refreshBox=false
    end
    yval=self.y+30
    for j in 0...5
      xval=self.x+10
      for k in 0...6
        sprite=@pokemonsprites[j*6+k]
        if sprite && !sprite.disposed?
          sprite.viewport=self.viewport
          sprite.z=0
          sprite.x=xval
          sprite.y=yval
        end
        xval+=48
      end
      yval+=48
    end
  end

  def update
    super
    for i in 0...30
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].update
      end
    end
  end
end



class PokemonStorageScene
  attr_reader :quickswap
  
  def initialize
    @command=0
  end

  def pbStartBox(screen,command)
    @screen=screen
    @storage=screen.storage
    @bgviewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @bgviewport.z=99999
    @boxviewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @boxviewport.z=99999
    @boxsidesviewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @boxsidesviewport.z=99999
    @arrowviewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @arrowviewport.z=99999
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @selection=0
    @quickswap=false
    @sprites={}
    @choseFromParty=false
    @command=command
    addBackgroundPlane(@sprites,"background","Storage/boxbg",@bgviewport)
    @sprites["box"]=PokemonBoxSprite.new(@storage,@storage.currentBox,@boxviewport)
    @sprites["boxsides"]=IconSprite.new(0,0,@boxsidesviewport)
    @sprites["boxsides"].setBitmap("Graphics/Pictures/Storage/boxsides")
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@boxsidesviewport)
    @sprites["pokemon"]=AutoMosaicPokemonSprite.new(@boxsidesviewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["boxparty"]=PokemonBoxPartySprite.new(@storage.party,@boxsidesviewport)
    if command!=1 # Drop down tab only on Deposit
      @sprites["boxparty"].x=182
      @sprites["boxparty"].y=Graphics.height
    end
    @sprites["arrow"]=PokemonBoxArrow.new(@arrowviewport)
    @sprites["arrow"].z+=1
    if command!=1
      pbSetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection)
      pbSetMosaic(@selection)
    else
      pbPartySetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection,@storage.party)
      pbSetMosaic(@selection)
    end
    pbFadeInAndShow(@sprites)
  end

  def pbCloseBox
    pbFadeOutAndHide(@sprites)  
    pbDisposeSpriteHash(@sprites)
    @boxviewport.dispose
    @boxsidesviewport.dispose
    @arrowviewport.dispose
  end

  def pbSetArrow(arrow,selection)
    case selection
      when -1, -4, -5 # Box name, move left, move right
        arrow.y=-16
        arrow.x=157*2
      when -2 # Party Pokémon
        arrow.y=143*2
        arrow.x=119*2
      when -3 # Close Box
        arrow.y=143*2
        arrow.x=207*2
      else
        arrow.x = (97+24*(selection%6) ) * 2
        arrow.y = (8+24*(selection/6) ) * 2
    end
  end

  def pbChangeSelection(key,selection)
    case key
      when Input::UP
        if selection==-1 # Box name
          selection=-2
        elsif selection==-2 # Party
          selection=25
        elsif selection==-3 # Close Box
          selection=28
        else
          selection-=6
          selection=-1 if selection<0
        end
      when Input::DOWN
        if selection==-1 # Box name
          selection=2
        elsif selection==-2 # Party
          selection=-1
        elsif selection==-3 # Close Box
          selection=-1
        else
          selection+=6
          selection=-2 if selection==30||selection==31||selection==32
          selection=-3 if selection==33||selection==34||selection==35
        end
      when Input::RIGHT
        if selection==-1 # Box name
          selection=-5 # Move to next box
        elsif selection==-2
          selection=-3
        elsif selection==-3
          selection=-2
        else
          selection+=1
          selection-=6 if selection%6==0
        end
      when Input::LEFT
        if selection==-1 # Box name
          selection=-4 # Move to previous box
        elsif selection==-2
          selection=-3
        elsif selection==-3
          selection=-2
        else
          selection-=1
          selection+=6 if selection==-1||selection%6==5
        end
    end
    return selection
  end

  def pbPartySetArrow(arrow,selection)
    if selection>=0
      xvalues=[99,137,99,137,99,137,118]
      yvalues=[0,8,32,40,64,72,114]
      arrow.angle=0
      arrow.mirror=false
      arrow.ox=0
      arrow.oy=0
      arrow.x=xvalues[selection]*2
      arrow.y=yvalues[selection]*2
    end
  end

  def pbPartyChangeSelection(key,selection)
    case key
      when Input::LEFT
        selection-=1
        selection=6 if selection<0
      when Input::RIGHT
        selection+=1
        selection=0 if selection>6
      when Input::UP
        if selection==6
          selection=5
        else
          selection-=2
          selection=6 if selection<0
        end
      when Input::DOWN
        if selection==6
          selection=0
        else
          selection+=2
          selection=6 if selection>6
        end
    end
    return selection
  end

  def pbSelectPartyInternal(party,depositing)
    selection=@selection
    pbPartySetArrow(@sprites["arrow"],selection)
    pbUpdateOverlay(selection,party)
    pbSetMosaic(selection)
    lastsel=1
    loop do
      Graphics.update
      Input.update
      key=-1
      key=Input::DOWN if Input.repeat?(Input::DOWN)
      key=Input::RIGHT if Input.repeat?(Input::RIGHT)
      key=Input::LEFT if Input.repeat?(Input::LEFT)
      key=Input::UP if Input.repeat?(Input::UP)
      if key>=0
        pbPlayCursorSE()
        newselection=pbPartyChangeSelection(key,selection)
        if newselection==-1
          return -1 if !depositing
        elsif newselection==-2
          selection=lastsel
        else
          selection=newselection
        end
        pbPartySetArrow(@sprites["arrow"],selection)
        lastsel=selection if selection>0
        pbUpdateOverlay(selection,party)
        pbSetMosaic(selection)
      end
      pbUpdateSpriteHash(@sprites)
#### SARDINES - v17 - START
      if Input.trigger?(Input::X) && @command==0
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      end
#### SARDINES - v17 - END
      if Input.trigger?(Input::C)
        if selection>=0 && selection<6
          @selection=selection
          return selection
        elsif selection==6 # Close Box 
          @selection=selection
          return (depositing) ? -3 : -1
        end
      end
      if Input.trigger?(Input::B)
        @selection=selection
        return -1
      end
    end
  end

  def pbSelectParty(party)
    return pbSelectPartyInternal(party,true)
  end

  def pbChangeBackground(wp)
    @sprites["box"].refreshSprites=false
    alpha=0
    Graphics.update
    pbUpdateSpriteHash(@sprites)
    16.times do
      alpha+=16
      Graphics.update
      Input.update
      @sprites["box"].color=Color.new(248,248,248,alpha)
      pbUpdateSpriteHash(@sprites)
    end
    @sprites["box"].refreshBox=true
    @storage[@storage.currentBox].background="box#{wp}"
    4.times do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
    end
    16.times do
      alpha-=16
      Graphics.update
      Input.update
      @sprites["box"].color=Color.new(248,248,248,alpha)
      pbUpdateSpriteHash(@sprites)
    end
    @sprites["box"].refreshSprites=true
  end

  def pbSwitchBoxToRight(newbox)
    newbox=PokemonBoxSprite.new(@storage,newbox,@boxviewport)
    newbox.x=520
    Graphics.frame_reset
    begin
      Graphics.update
      Input.update
      @sprites["box"].x-=32
      newbox.x-=32
      pbUpdateSpriteHash(@sprites)
    end until newbox.x<=184
    diff=newbox.x-184
    newbox.x=184; @sprites["box"].x-=diff
    @sprites["box"].dispose
    @sprites["box"]=newbox
  end

  def pbSwitchBoxToLeft(newbox)
    newbox=PokemonBoxSprite.new(@storage,newbox,@boxviewport)
    newbox.x=-152
    Graphics.frame_reset
    begin
      Graphics.update
      Input.update
      @sprites["box"].x+=32
      newbox.x+=32
      pbUpdateSpriteHash(@sprites)
    end until newbox.x>=184
    diff=newbox.x-184
    newbox.x=184; @sprites["box"].x-=diff
    @sprites["box"].dispose
    @sprites["box"]=newbox
  end

  def pbJumpToBox(newbox)
    if @storage.currentBox!=newbox
      if newbox>@storage.currentBox
        pbSwitchBoxToRight(newbox)
      else
        pbSwitchBoxToLeft(newbox)
      end
      @storage.currentBox=newbox
    end
  end

#### SARDINES - v17 - START
  def pbSetQuickSwap(value)
    @quickswap = value
    @sprites["arrow"].quickswap = value
  end
#### SARDINES - v17 - END

  
  
  def pbBoxName(helptext,minchars,maxchars)
    oldsprites=pbFadeOutAndHide(@sprites)
    ret=pbEnterBoxName(helptext,minchars,maxchars)
    if ret.length>0
      @storage[@storage.currentBox].name=ret
    end
    @sprites["box"].refreshBox=true
    pbRefresh
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbUpdateOverlay(selection,party=nil)
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    pokemon=nil
    if @screen.pbHeldPokemon
      pokemon=@screen.pbHeldPokemon
    elsif selection>=0
      pokemon=(party) ? party[selection] : @storage[@storage.currentBox,selection]
    end
    if !pokemon
      @sprites["pokemon"].visible=false
      return
    end
    @sprites["pokemon"].visible=true
    speciesname=PBSpecies.getName(pokemon.species)
    itemname="No item"
    if pokemon.item>0
      itemname=PBItems.getName(pokemon.item)
    end
    abilityname="No ability"
    if pokemon.ability>0
      abilityname=PBAbilities.getName(pokemon.ability)
    end
    base=Color.new(88,88,80)
    shadow=Color.new(168,184,184)
    pokename=pokemon.name
    textstrings=[
       [pokename,10,8,false,base,shadow]
    ]
    if !pokemon.isEgg?
      if pokemon.isMale?
        textstrings.push([_INTL("♂"),148,8,false,Color.new(24,112,216),Color.new(136,168,208)])
      elsif pokemon.isFemale?
        textstrings.push([_INTL("♀"),148,8,false,Color.new(248,56,32),Color.new(224,152,144)])
      end
      textstrings.push([_INTL("{1}",pokemon.level),36,234,false,base,shadow])
      textstrings.push([_INTL("{1}",abilityname),85,306,2,base,shadow])
      textstrings.push([_INTL("{1}",itemname),85,342,2,base,shadow])
    end
    pbSetSystemFont(overlay)
    pbDrawTextPositions(overlay,textstrings)
    textstrings.clear
    if !$MKXP
      if !pokemon.isEgg?
        textstrings.push([_INTL("Lv."),10,238,false,base,shadow])
      end
    else
      if !pokemon.isEgg?
        textstrings.push([_INTL("Lv."),10,242,false,base,shadow])
      end
    end
    pbSetSmallFont(overlay)
    pbDrawTextPositions(overlay,textstrings)
    if !pokemon.isEgg?
      if pokemon.isShiny?
        imagepos=[(["Graphics/Pictures/shiny",156,198,0,0,-1,-1])]
        pbDrawImagePositions(overlay,imagepos)
      end
      typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      type1rect=Rect.new(0,pokemon.type1*28,64,28)
      type2rect=Rect.new(0,pokemon.type2*28,64,28)
      if pokemon.type1==pokemon.type2
        overlay.blt(52,272,typebitmap.bitmap,type1rect)
      else
        overlay.blt(18,272,typebitmap.bitmap,type1rect)
        overlay.blt(88,272,typebitmap.bitmap,type2rect)
      end
    end
    drawMarkings(overlay,66,240,128,20,pokemon.markings)
    @sprites["pokemon"].setPokemonBitmap(pokemon)
    pbPositionPokemonSprite(@sprites["pokemon"],26,70)
  end

  def pbDropDownPartyTab
    begin
      Graphics.update
      Input.update
      @sprites["boxparty"].y-=16
      pbUpdateSpriteHash(@sprites)
    end until @sprites["boxparty"].y<=Graphics.height-352
  end

  def pbHidePartyTab
    begin
      Graphics.update
      Input.update
      @sprites["boxparty"].y+=16
      pbUpdateSpriteHash(@sprites)
    end until @sprites["boxparty"].y>=Graphics.height
  end

  def pbSetMosaic(selection)
    if !@screen.pbHeldPokemon
      if @boxForMosaic!=@storage.currentBox || @selectionForMosaic!=selection
        @sprites["pokemon"].mosaic=10
        @boxForMosaic=@storage.currentBox
        @selectionForMosaic=selection
      end
    end
  end

  def pbSelectBoxInternal(party)
    selection=@selection
    pbSetArrow(@sprites["arrow"],selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    loop do
      Graphics.update
      Input.update
      key=-1
      key=Input::DOWN if Input.repeat?(Input::DOWN)
      key=Input::RIGHT if Input.repeat?(Input::RIGHT)
      key=Input::LEFT if Input.repeat?(Input::LEFT)
      key=Input::UP if Input.repeat?(Input::UP)
      if key>=0
        pbPlayCursorSE()
        selection=pbChangeSelection(key,selection)
        pbSetArrow(@sprites["arrow"],selection)
        nextbox=-1
        if selection==-4
          nextbox=(@storage.currentBox==0) ? @storage.maxBoxes-1 : @storage.currentBox-1
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox=nextbox
          selection=-1
        elsif selection==-5
          nextbox=(@storage.currentBox==@storage.maxBoxes-1) ? 0 : @storage.currentBox+1
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox=nextbox
          selection=-1
        end
        selection=-1 if selection==-4 || selection==-5
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      end
      pbUpdateSpriteHash(@sprites)
#### SARDINES - v17 - START
      if Input.trigger?(Input::F5)        # Jump to box name
        if selection!=-1
          pbPlayCursorSE
          selection=-1
          pbSetArrow(@sprites["arrow"],selection)
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        end
      end
      if Input.trigger?(Input::X) && @command==0  # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      end
#### SARDINES - v17 - END
      if Input.trigger?(Input::C)
        if selection>=0
          @selection=selection
          return [@storage.currentBox,selection]
        elsif selection==-1 # Box name 
          @selection=selection
          return [-4,-1]
        elsif selection==-2 # Party Pokémon 
          @selection=selection
          return [-2,-1]
        elsif selection==-3 # Close Box 
          @selection=selection
          return [-3,-1]
        end
      end
      if Input.trigger?(Input::B)
        @selection=selection
        return nil
      end
    end
  end

  def pbSelectBox(party)
    if @command==2 # Withdraw
      return pbSelectBoxInternal(party)
    else
      ret=nil
      loop do
        if !@choseFromParty
          ret=pbSelectBoxInternal(party)
        end
        if @choseFromParty || (ret && ret[0]==-2) # Party Pokémon
          if !@choseFromParty
            pbDropDownPartyTab
            @selection=0
          end
          ret=pbSelectPartyInternal(party,false)
          if ret<0
            pbHidePartyTab
            @selection=0
            @choseFromParty=false
          else
            @choseFromParty=true
            return [-1,ret]
          end
        else
          @choseFromParty=false
          return ret
        end
      end
    end
  end

  def pbHold(selected)
    if selected[0]==-1
      @sprites["boxparty"].grabPokemon(selected[1],@sprites["arrow"])
    else
      @sprites["box"].grabPokemon(selected[1],@sprites["arrow"])
    end
    while @sprites["arrow"].grabbing?
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
    end
  end

  def pbSwap(selected,heldpoke)
    heldpokesprite=@sprites["arrow"].heldPokemon
    boxpokesprite=nil
    if selected[0]==-1
      boxpokesprite=@sprites["boxparty"].getPokemon(selected[1])
    else
      boxpokesprite=@sprites["box"].getPokemon(selected[1])
    end
    if selected[0]==-1
      @sprites["boxparty"].setPokemon(selected[1],heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1],heldpokesprite)
    end
    @sprites["arrow"].setSprite(boxpokesprite)
    @sprites["pokemon"].mosaic=10
    @boxForMosaic=@storage.currentBox
    @selectionForMosaic=selected[1]
  end

  def pbPlace(selected,heldpoke)
    heldpokesprite=@sprites["arrow"].heldPokemon
    @sprites["arrow"].place
    while @sprites["arrow"].placing?
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
    end
    if selected[0]==-1
      @sprites["boxparty"].setPokemon(selected[1],heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1],heldpokesprite)
    end
    @boxForMosaic=@storage.currentBox
    @selectionForMosaic=selected[1]
  end

  def pbChooseItem(bag)
    oldsprites=pbFadeOutAndHide(@sprites)
    scene=PokemonBag_Scene.new
    screen=PokemonBagScreen.new(scene,bag)
    ret=screen.pbGiveItemScreen
    pbFadeInAndShow(@sprites,oldsprites)
    return ret
  end

  def pbWithdraw(selected,heldpoke,partyindex)
    if !heldpoke
      pbHold(selected)
    end
    pbDropDownPartyTab
    pbPartySetArrow(@sprites["arrow"],partyindex)
    pbPlace([-1,partyindex],heldpoke)
    pbHidePartyTab
  end

  def pbSummary(selected,heldpoke)
    oldsprites=pbFadeOutAndHide(@sprites)
    scene=PokemonSummaryScene.new
    screen=PokemonSummary.new(scene)
    if heldpoke
      screen.pbStartScreen([heldpoke],0)
    elsif selected[0]==-1
      @selection=screen.pbStartScreen(@storage.party,selected[1])
      pbPartySetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection,@storage.party)
    else
      @selection=screen.pbStartScreen(@storage.boxes[selected[0]],selected[1])
      pbSetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection)
    end
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbStore(selected,heldpoke,destbox,firstfree)
    if heldpoke
      if destbox==@storage.currentBox
        heldpokesprite=@sprites["arrow"].heldPokemon
        @sprites["box"].setPokemon(firstfree,heldpokesprite)
        @sprites["arrow"].setSprite(nil)
      else
        @sprites["arrow"].deleteSprite
      end
    else
      sprite=@sprites["boxparty"].getPokemon(selected[1])
      if destbox==@storage.currentBox
        @sprites["box"].setPokemon(firstfree,sprite)
        @sprites["boxparty"].setPokemon(selected[1],nil)
      else
        @sprites["boxparty"].deletePokemon(selected[1])
      end
    end
  end

  def drawMarkings(bitmap,x,y,width,height,markings)
    totaltext=""
    oldfontname=bitmap.font.name
    oldfontsize=bitmap.font.size
    oldfontcolor=bitmap.font.color
    bitmap.font.size=24
    bitmap.font.name="Arial"
    PokemonStorage::MARKINGCHARS.each{|item| totaltext+=item }
    totalsize=bitmap.text_size(totaltext)
    realX=x+(width/2)-(totalsize.width/2)
    realY=y+(height/2)-(totalsize.height/2)
    i=0
    PokemonStorage::MARKINGCHARS.each{|item|
       marked=(markings&(1<<i))!=0
       bitmap.font.color=(marked) ? Color.new(80,80,80) : Color.new(208,200,184)
       itemwidth=bitmap.text_size(item).width
       bitmap.draw_text(realX,realY,itemwidth+2,totalsize.height,item)
       realX+=itemwidth
       i+=1
    }
    bitmap.font.name=oldfontname
    bitmap.font.size=oldfontsize
    bitmap.font.color=oldfontcolor
  end

  def getMarkingCommands(markings)
    selectedtag="<c=505050>"
    deselectedtag="<c=D0C8B8>"
    commands=[]
    for i in 0...PokemonStorage::MARKINGCHARS.length
      commands.push( ((markings&(1<<i))==0 ? deselectedtag : selectedtag)+"<ac><fn=Arial>"+PokemonStorage::MARKINGCHARS[i])
    end
    commands.push(_INTL("OK"))
    commands.push(_INTL("Cancel"))   
    return commands
  end

  def pbMark(selected,heldpoke)
    ret=0
    msgwindow=Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
    msgwindow.viewport=@viewport
    msgwindow.visible=true
    msgwindow.letterbyletter=false
    msgwindow.resizeHeightToFit(_INTL("Mark your Pokemon."),Graphics.width-180)
    msgwindow.text=_INTL("Mark your Pokemon.")
    pokemon=heldpoke
    if heldpoke
      pokemon=heldpoke
    elsif selected[0]==-1
      pokemon=@storage.party[selected[1]]
    else
      pokemon=@storage.boxes[selected[0]][selected[1]]
    end
    pbBottomRight(msgwindow)
    selectedtag="<c=505050>"
    deselectedtag="<c=D0C8B8>"
    commands=getMarkingCommands(pokemon.markings)
    cmdwindow=Window_AdvancedCommandPokemon.new(commands)
    cmdwindow.viewport=@viewport
    cmdwindow.visible=true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.width=132
    cmdwindow.height=Graphics.height-msgwindow.height if cmdwindow.height>Graphics.height-msgwindow.height
    cmdwindow.update
    pbBottomRight(cmdwindow)
    markings=pokemon.markings
    cmdwindow.y-=msgwindow.height
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        break # cancel
      end
      if Input.trigger?(Input::C)
        if cmdwindow.index==commands.length-1
          break # cancel
        elsif cmdwindow.index==commands.length-2
          pokemon.markings=markings # OK
          break
        elsif cmdwindow.index>=0
          mask=(1<<cmdwindow.index)
          if (markings&mask)==0
            markings|=mask
          else
            markings&=~mask
          end
          commands=getMarkingCommands(markings)
          cmdwindow.commands=commands
        end
      end
      pbUpdateSpriteHash(@sprites)
      msgwindow.update
      cmdwindow.update
    end
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
  end

  def pbRefresh
    @sprites["box"].refresh
    @sprites["boxparty"].refresh
  end

  def pbHardRefresh
    oldPartyY=@sprites["boxparty"].y
    @sprites["box"].dispose
    @sprites["boxparty"].dispose
    @sprites["box"]=PokemonBoxSprite.new(@storage,@storage.currentBox,@boxviewport)
    @sprites["boxparty"]=PokemonBoxPartySprite.new(@storage.party,@boxsidesviewport)
    @sprites["boxparty"].y=oldPartyY
  end

  def pbRelease(selected,heldpoke)
    box=selected[0]
    index=selected[1]
    if heldpoke
      sprite=@sprites["arrow"].heldPokemon
    elsif box==-1
      sprite=@sprites["boxparty"].getPokemon(index)
    else
      sprite=@sprites["box"].getPokemon(index)
    end
    if sprite
      sprite.release
      while sprite.releasing?
        Graphics.update
        sprite.update
        pbUpdateSpriteHash(@sprites)
      end
    end
  end

  def pbChooseBox(msg)
    commands=[]
    for i in 0...@storage.maxBoxes
      box=@storage[i]
      if box
        commands.push(_ISPRINTF("{1:s} ({2:d}/{3:d})",box.name,box.nitems,box.length))
      end
    end
    return pbShowCommands(msg,commands,@storage.currentBox)
  end

  def pbShowCommands(message,commands,index=0)
    ret=0
    msgwindow=Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
    msgwindow.viewport=@viewport
    msgwindow.visible=true
    msgwindow.letterbyletter=false
    msgwindow.resizeHeightToFit(message,Graphics.width-180)
    msgwindow.text=message
    pbBottomRight(msgwindow)
    cmdwindow=Window_CommandPokemon.new(commands)
    cmdwindow.viewport=@viewport
    cmdwindow.visible=true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height=Graphics.height-msgwindow.height if cmdwindow.height>Graphics.height-msgwindow.height
    cmdwindow.update
    cmdwindow.index=index
    pbBottomRight(cmdwindow)
    cmdwindow.y-=msgwindow.height
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        ret=-1
        break
      end
      if Input.trigger?(Input::C)
        ret=cmdwindow.index
        break
      end
      pbUpdateSpriteHash(@sprites)
      msgwindow.update
      cmdwindow.update
    end
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
    return ret
  end

  def pbDisplay(message)
    msgwindow=Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
    msgwindow.viewport=@viewport
    msgwindow.visible=true
    msgwindow.letterbyletter=false
    msgwindow.resizeHeightToFit(message,Graphics.width-180)
    msgwindow.text=message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        break
      end
      if Input.trigger?(Input::C)
        break
      end
      msgwindow.update
      pbUpdateSpriteHash(@sprites)
    end
    msgwindow.dispose
    Input.update
  end
end



################################################################################
# Regional Storage scripts
################################################################################
class RegionalStorage
  def initialize
    @storages=[]
    @lastmap=-1
    @rgnmap=-1
  end

  def getCurrentStorage
    if !$game_map
      raise _INTL("The player is not on a map, so the region could not be determined.")
    end
    if @lastmap!=$game_map.map_id
      @rgnmap=pbGetCurrentRegion # may access file IO, so caching result
      @lastmap=$game_map.map_id
    end
    if @rgnmap<0
      raise _INTL("The current map has no region set.  Please set the MapPosition metadata setting for this map.")
    end
    if !@storages[@rgnmap]
      @storages[@rgnmap]=PokemonStorage.new
    end
    return @storages[@rgnmap]
  end

  def boxes
    return getCurrentStorage.boxes
  end

  def party
    return getCurrentStorage.party
  end

  def currentBox
    return getCurrentStorage.currentBox
  end

  def currentBox=(value)
    getCurrentStorage.currentBox=value
  end

  def maxBoxes
    return getCurrentStorage.maxBoxes
  end

  def maxPokemon(box)
    return getCurrentStorage.maxPokemon(box)
  end

  def [](x,y=nil)
    getCurrentStorage[x,y]
  end

  def []=(x,y,value)
    getCurrentStorage[x,y]=value
  end

  def full?
    getCurrentStorage.full?
  end

  def pbFirstFreePos(box)
    getCurrentStorage.pbFirstFreePos(box)
  end

  def pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    getCurrentStorage.pbCopy(boxDst,indexDst,boxSrc,indexSrc)
  end

  def pbMove(boxDst,indexDst,boxSrc,indexSrc)
    getCurrentStorage.pbCopy(boxDst,indexDst,boxSrc,indexSrc)
  end

  def pbMoveCaughtToParty(pkmn)
    getCurrentStorage.pbMoveCaughtToParty(pkmn) 
  end

  def pbMoveCaughtToBox(pkmn,box)
    getCurrentStorage.pbMoveCaughtToBox(pkmn,box)
  end

  def pbStoreCaught(pkmn)
    getCurrentStorage.pbStoreCaught(pkmn) 
  end

  def pbDelete(box,index)
    getCurrentStorage.pbDelete(pkmn)
  end
end



################################################################################
# PC menus
################################################################################
def Kernel.pbGetStorageCreator
  creator=pbStorageCreator
  creator=_INTL("Bill") if !creator || creator==""
  return creator
end

def pbPCItemStorage
  loop do
    command=Kernel.pbShowCommandsWithHelp(nil,
       [_INTL("Withdraw Item"),
       _INTL("Deposit Item"),
       _INTL("Toss Item"),
       _INTL("Exit")],
       [_INTL("Take out items from the PC."),
       _INTL("Store items in the PC."),
       _INTL("Throw away items stored in the PC."),
       _INTL("Go back to the previous menu.")],-1
    )
    if command==0 # Withdraw Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage=PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        Kernel.pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn(99999){
           scene=WithdrawItemScene.new
           screen=PokemonBagScreen.new(scene,$PokemonBag)
           ret=screen.pbWithdrawItemScreen
        }
      end
    elsif command==1 # Deposit Item
      pbFadeOutIn(99999){
         scene=PokemonBag_Scene.new
         screen=PokemonBagScreen.new(scene,$PokemonBag)         
         ret=screen.pbDepositItemScreen
      }
    elsif command==2 # Toss Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage=PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        Kernel.pbMessage(_INTL("There are no items."))
      else
        pbFadeOutIn(99999){
           scene=TossItemScene.new
           screen=PokemonBagScreen.new(scene,$PokemonBag)
           ret=screen.pbTossItemScreen
        }
      end
    else
      break
    end
  end
end

def pbPCMailbox
  if !$PokemonGlobal.mailbox || $PokemonGlobal.mailbox.length==0
    Kernel.pbMessage(_INTL("There's no Mail here."))
  else
    loop do
      commands=[]
      for mail in $PokemonGlobal.mailbox
        commands.push(mail.sender)
      end
      commands.push(_INTL("Cancel"))
      command=Kernel.pbShowCommands(nil,commands,-1)
      if command>=0 && command<$PokemonGlobal.mailbox.length
        mailIndex=command
        command=Kernel.pbMessage(_INTL("What do you want to do with {1}'s Mail?",
           $PokemonGlobal.mailbox[mailIndex].sender),[
           _INTL("Read"),
           _INTL("Move to Bag"),
           _INTL("Give"),
           _INTL("Cancel")
           ],-1)
        if command==0 # Read
          pbFadeOutIn(99999){
             pbDisplayMail($PokemonGlobal.mailbox[mailIndex])
          }
        elsif command==1 # Move to Bag
          if Kernel.pbConfirmMessage(_INTL("The message will be lost.  Is that OK?"))
            if $PokemonBag.pbStoreItem($PokemonGlobal.mailbox[mailIndex].item)
              Kernel.pbMessage(_INTL("The Mail was returned to the Bag with its message erased."))
              $PokemonGlobal.mailbox.delete_at(mailIndex)
            else
              Kernel.pbMessage(_INTL("The Bag is full."))
            end
          end
        elsif command==2 # Give
          pbFadeOutIn(99999){
             sscene=PokemonScreen_Scene.new
             sscreen=PokemonScreen.new(sscene,$Trainer.party)
             sscreen.pbPokemonGiveMailScreen(mailIndex)
          }
        end
      else
        break
      end
    end
  end
end

def pbTrainerPCMenu
#  loop do
#    command=Kernel.pbMessage(_INTL("What do you want to do?"),[
#       _INTL("Item Storage"),
#       _INTL("Mailbox"),
#       _INTL("Turn Off")
#       ],-1)
#    if command==0
      pbPCItemStorage
#    elsif command==1
#      pbPCMailbox
#    else
#      break
#    end
#  end
end



module PokemonPCList
  @@pclist=[]

  def self.registerPC(pc)
    @@pclist.push(pc)
  end

  def self.getCommandList()
    commands=[]
    for pc in @@pclist
      if pc.shouldShow?
        commands.push(pc.name)
      end
    end
    commands.push(_INTL("Log Off"))
    return commands
  end

  def self.callCommand(cmd)
    if cmd<0 || cmd>=@@pclist.length
      return false
    end
    i=0
    for pc in @@pclist
      if pc.shouldShow?
        if i==cmd
           pc.access()
           return true
        end
        i+=1
      end
    end
    return false
  end
end



def pbTrainerPC
  Kernel.pbMessage(_INTL("\\se[computeropen]{1} booted up the PC.",$Trainer.name))
  pbTrainerPCMenu
  pbSEPlay("computerclose")
end



class TrainerPC
  def shouldShow?
    return true
  end

  def name
    return _INTL("{1}'s PC",$Trainer.name)
  end

  def access
    Kernel.pbMessage(_INTL("\\se[accesspc]Accessed {1}'s PC.",$Trainer.name))
    pbTrainerPCMenu
  end
end



class StorageSystemPC
  def shouldShow?
    return true
  end

  def name
    if $PokemonGlobal.seenStorageCreator
      return _INTL("{1}'s PC",Kernel.pbGetStorageCreator)
    else
      return _INTL("Someone's PC")
    end
  end

  def access
    Kernel.pbMessage(_INTL("\\se[accesspc]The Pokémon Storage System was opened."))
    loop do
      command=Kernel.pbShowCommandsWithHelp(nil,
         [_INTL("Move Pokémon"),
         _INTL("Deposit Pokémon"),
         _INTL("Withdraw Pokémon"),
         _INTL("See ya!")],
         [_INTL("Move Pokémon stored in Boxes to your party."),
         _INTL("Store Pokémon in your party in Boxes."),
         _INTL("Organize the Pokémon in Boxes and in your party."),
         _INTL("Return to the previous menu.")],-1
      )
      if command>=0 && command<3
        if command==2 && $PokemonStorage.party.length>=6
          Kernel.pbMessage(_INTL("Your party is full!"))
          next
        end
        count=0
        for p in $PokemonStorage.party
          count+=1 if p && !p.isEgg? && p.hp>0
        end
        if command==1 && count<=1
          Kernel.pbMessage(_INTL("Can't deposit the last Pokémon!"))
          next
        end
        pbFadeOutIn(99999){
           scene=PokemonStorageScene.new
           screen=PokemonStorageScreen.new(scene,$PokemonStorage)
           screen.pbStartScreen(command)
        }
      else
        break
      end
    end
  end
end



def pbPokeCenterPC
  Kernel.pbMessage(_INTL("\\se[computeropen]{1} booted up the PC.",$Trainer.name))
  loop do
    commands=PokemonPCList.getCommandList()
    command=Kernel.pbMessage(_INTL("Which PC should be accessed?"),
       commands,commands.length)
    if !PokemonPCList.callCommand(command)
      break
    end
  end
  pbSEPlay("computerclose")
end

PokemonPCList.registerPC(StorageSystemPC.new)
PokemonPCList.registerPC(TrainerPC.new)