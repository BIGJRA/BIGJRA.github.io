################################################################################
# Species Check                                                                                                                                                              By Marcello & Kurotsune
################################################################################

def isLegalMons?(trainer)
  #return false if trainer.noOnlineBattle
=begin #mons not in player party  
  for i in 0..1
    pokemon = $PokemonGlobal.daycare[i][0]
    next if !pokemon
    if unavailableMonList(pokemon)
      print "An unreleased pokemon has been detected. You will be unable to battle online on this file."
      trainer.noOnlineBattle = true
      return false
    end   
  end
  for i in 0..34
    for pokemon in $PokemonStorage[i]
      next if !pokemon
      if unavailableMonList(pokemon)
        print "An unreleased pokemon has been detected. You will be unable to battle online on this file."
        trainer.noOnlineBattle=true
        return false
      end   
    end
  end   
=end  
  for pokemon in trainer.party
    next if !pokemon
    if unavailableMonList(pokemon)
      print "An unreleased pokemon has been detected in your party. You will be unable to access certain online functionality until you remove it."
      trainer.noOnlineBattle=true
      return false
    end
  end
  trainer.noOnlineBattle=false
  return true
end

################################################################################
# Move Check                                                                                                                                                              This is by Marcello & Kurotsune too
################################################################################
def getMoveListForSpecies(species)
  movelist=[]
  for k in 0...$cache.pkmn_moves[species].length
    movelist.push([$cache.pkmn_moves[species][k][0],$cache.pkmn_moves[species][k][1]])
  end
  return movelist
end

def preEvoLearnsetCheck(pokemon,move)
  preEvo1=PokeBattle_Pokemon.new(pbGetPreviousForm(pokemon.species),5)
  preEvo1.form = pokemon.form
  preEvo2=PokeBattle_Pokemon.new(pbGetPreviousForm(preEvo1.species),5)
  preEvo2.form = pokemon.form
  for i in 0...preEvo1.getMoveList.length
    learnable = preEvo1.getMoveList[i][1] 
    if move == learnable
      ret=true
      break
    else
      ret=false
    end
  end
  if ret==false
    for j in 0...preEvo2.getMoveList.length
      learnable = preEvo2.getMoveList[j][1]
      if move==learnable
        ret=true
        break
      else
        ret=false
      end
    end
  end 
  return ret
end

  
def isRotomMove?(move,pkmn)
  if !(pkmn.species == PBSpecies::ROTOM)
    return false
  end
  if pkmn.form==1 && move==PBMoves::OVERHEAT
    return true
  elsif pkmn.form==2 && move==PBMoves::HYDROPUMP
    return true
  elsif pkmn.form==3 && move==PBMoves::BLIZZARD
    return true
  elsif pkmn.form==4 && move==PBMoves::AIRSLASH
    return true
  elsif pkmn.form==5 && move==PBMoves::LEAFSTORM  
    return true
  else
    return false
  end
end  

def isSmeargleMove?(move,pkmn)
  if !(pkmn.species == PBSpecies::SMEARGLE)
    return false
  end
  if move==PBMoves::CHATTER
    return false
  else
    return true
  end
end    
  


def isLegalMove?(trainer)
  #return false if trainer.noOnlineBattle
  ret=true
  for pokemon in trainer.party  
    if ret==false
      print "A pokemon with an illegal move has been detected in your party. You will be unable to access certain online functionality until you remove it."
      trainer.noOnlineBattle=true
      return false
    end     
    next if !pokemon
    for i in 0...pokemon.moves.length
      counter1=0
      counter2=0
      if ret==false
        print "A pokemon with an illegal move has been detected in your party. You will be unable to access certain online functionality until you remove it."
        trainer.noOnlineBattle=true
        return false
      end      
      next if pokemon.moves[i].id == 0
      move = pokemon.moves[i].id
      for j in 0...pokemon.getMoveList.length
        if counter1==pokemon.getMoveList.length
          if counter2==pokemon.getEggMoveList.length
            counter1=0
          else
            break
          end 
        end        
        counter2=0
        learnable = pokemon.getMoveList[j][1]  
        if (move == learnable) || isRotomMove?(move,pokemon) || isSmeargleMove?(move,pokemon)
          ret=true
          counter1=0
          break
        else
          ret=false
          counter1+=1
        end 
        if counter1==pokemon.getMoveList.length
          if preEvoLearnsetCheck(pokemon,move)
            ret=true
            next
          else
            ret=false
          end           
          for k in 0...pokemon.getEggMoveList.length
            eggmove = pokemon.getEggMoveList[k]
            if move==eggmove
              ret=true
              counter2=0
              break
            else
              ret=false
              counter2+=1            
            end
          end          
          if counter2==pokemon.getEggMoveList.length 
            if pbSpeciesCompatible?(pokemon.species,move,pokemon)
              if unavailableMoveList(move)
                print "A pokemon with an unreleased move has been detected in your party. You will be unable to access certain online functionality until you remove it."
                trainer.noOnlineBattle=true
                return false
              else                  
                ret=true
                break
              end                
            end
          end                                    
        end        
      end      
    end
  end
  if ret==true
   # trainer.noOnlineBattle=false
    return true
  else
    print "A pokemon with an illegal or unreleased move has been detected in your party. You will be unable to access certain online functionality until you remove it."
    trainer.noOnlineBattle=true
    return false
  end    
=begin  #mons not in player party
  for i in 0..1
      pokemon = $PokemonGlobal.daycare[i][0]
      if ret==false
        print "A pokemon with an illegal move has been detected. You will be unable to battle online on this file."
        trainer.noOnlineBattle=true
        return false
      end     
      next if !pokemon 
      for i in 0...pokemon.moves.length
        counter1=0
        counter2=0
        if ret==false
          print "A pokemon with an illegal move has been detected. You will be unable to battle online on this file."
          trainer.noOnlineBattle=true
          return false
        end      
        next if pokemon.moves[i].id == 0
        move = pokemon.moves[i].id
        for j in 0...pokemon.getMoveList.length
          if counter1==pokemon.getMoveList.length
            if counter2==pokemon.getEggMoveList.length
              counter1=0
            else
              break
            end 
          end        
          counter2=0
          learnable = pokemon.getMoveList[j][1]       
          if move == learnable
            ret=true
            counter1=0
            break
          else
            ret=false
            counter1+=1
          end 
          if counter1==pokemon.getMoveList.length
            if preEvoLearnsetCheck(pokemon,move)
              ret=true
              next
            else
              ret=false
            end            
            for k in 0...pokemon.getEggMoveList.length
              eggmove = pokemon.getEggMoveList[k]
              if move==eggmove
                ret=true
                counter2=0
                break
              else
                ret=false
                counter2+=1
              end
              if counter2==pokemon.getEggMoveList.length              
                if pbSpeciesCompatible?(pokemon.species,move)
                  if unavailableMoveList(move)
                    print "A pokemon with an unreleased move has been detected. You will be unable to battle online on this file."
                    trainer.noOnlineBattle=true
                    return false
                  else                  
                    ret=true
                    break
                  end                
                end
              end                          
            end
          end        
        end      
      end
    end
  for i in 0..34
    for pokemon in $PokemonStorage[i] 
      if ret==false
        print "A pokemon with an illegal move has been detected. You will be unable to battle online on this file."
        trainer.noOnlineBattle=true
        return false
      end     
      next if !pokemon
      for i in 0...pokemon.moves.length
        counter1=0
        counter2=0
        if ret==false
          print "A pokemon with an illegal move has been detected. You will be unable to battle online on this file."
          trainer.noOnlineBattle=true
          return false
        end      
        next if pokemon.moves[i].id == 0
        move = pokemon.moves[i].id
        for j in 0...pokemon.getMoveList.length
          if counter1==pokemon.getMoveList.length
            if counter2==pokemon.getEggMoveList.length
              counter1=0
            else
              break
            end 
          end        
          counter2=0
          learnable = pokemon.getMoveList[j][1]       
          if move == learnable
            ret=true
            counter1=0
            break
          else
            ret=false
            counter1+=1
          end 
          if counter1==pokemon.getMoveList.length
            if preEvoLearnsetCheck(pokemon,move)
              ret=true
              next
            else
              ret=false
            end            
            for k in 0...pokemon.getEggMoveList.length
              eggmove = pokemon.getEggMoveList[k]
              if move==eggmove
                ret=true
                counter2=0
                break
              else
                ret=false
                counter2+=1
              end
              if counter2==pokemon.getEggMoveList.length              
                if pbSpeciesCompatible?(pokemon.species,move)
                  if unavailableMoveList(move)
                    print "A pokemon with an unreleased move has been detected. You will be unable to battle online on this file."
                    trainer.noOnlineBattle=true
                    return false
                  else                  
                    ret=true
                    break
                  end                
                end
              end                          
            end
          end        
        end      
      end
    end
    if ret==true
      return true
    else
      print "A pokemon with an illegal move has been detected. You will be unable to battle online on this file."
      trainer.noOnlineBattle=true
      return false
    end  
  end 
=end   
end

################################################################################
# Nickname & etc Check
################################################################################
def nicknameFilterCheck(trainer)
  for pokemon in trainer.party
    name2 = pokemon.name
    name = (pokemon.name).downcase
    illegalname = ["bitch","cock","cumshot", "cunt", "fuck", "masturbation", "nigga", "nigger", "penis", "pussy", "slut", 
      "twat", "vulva", "wank", "dick", "creampie", "morningwood", "piss", "pussies",  "vagina", "cunny", "whore",
      "chink" , "hitler" , "nazi", "cum", "ballsack", "peniis", "thot", "dildo"]
    if illegalname.any? {|word| name.include?(word)}
      print "An inappropriate nickname has been detected in your party. Please remove or rename #{name2} if you want to access online."
      return false
    end
    if (name.include? "fag") && !(name=="cofagrigus") || name.include?('kum') && name != "pyukumuku" || name == "spic" || name == "kike"
      print "An inappropriate nickname has been detected in your party. Please remove or rename #{name2} if you want to access online."
      return false
    end
  end
  return true
end

def usernameFilterCheck(username)
    name = username.downcase
    illegalname = ["bitch","cock","cumshot", "cunt", "fuck", "masturbation", "nigga", "nigger", "penis", "pussy", "slut", 
      "twat", "vulva", "wank", "dick", "creampie", "morningwood", "piss", "pussies",  "vagina", "cunny", "whore",
      "chink" , "hitler" , "nazi", "cum", "ballsack", "peniis", "thot", "dildo"]
    if illegalname.any? {|word| name.include?(word)}
      print "This username has been deemed inappropriate, please use another one."
      return false
    end
    if (name.include? "fag") && !(name=="cofagrigus") || name.include?('kum') && name != "pyukumuku" || name == "spic" || name == "kike"
      print "This username has been deemed inappropriate, please use another one."
      return false
    end
  return true
end

def trainerNameFilterCheck(tname)
    name = tname.downcase
    illegalname = ["bitch","cock","cumshot", "cunt", "fuck", "masturbation", "nigga", "nigger", "penis", "pussy", "slut", 
      "twat", "vulva", "wank", "dick", "creampie", "morningwood", "piss", "pussies",  "vagina", "cunny", "whore",
      "chink" , "hitler" , "nazi", "cum", "ballsack", "peniis", "thot", "dildo"]
    if illegalname.any? {|word| name.include?(word)}
      print "This username has been deemed inappropriate, please use another one."
      return false
    end
    if (name.include? "fag") && !(name=="cofagrigus") || name.include?('kum') && name != "pyukumuku" || name == "spic" || name == "kike"
      print "This username has been deemed inappropriate, please use another one."
      return false
    end
  return true
end

def onlineNameChange
  oldname = $Trainer.name
  trname=pbEnterPlayerName("Your new name?",0,12,$Trainer.name)
  loop do
    if trname==""
      Kernel.pbMessage(_INTL("Your name cannot be blank.")) 
      trname=pbEnterPlayerName("Your new name?",0,12,$Trainer.name)
    else
      break
    end
  end  
  $Trainer.name=trname
  Kernel.pbMessage(_INTL("The player's name was changed to {1}.",$Trainer.name))
  for pokemon in $Trainer.party
    if pokemon.ot == oldname
      pokemon.ot = $Trainer.name
    end
  end
  for i in 0..34
    for pokemon in $PokemonStorage[i]
      next if !pokemon
      if pokemon.ot == oldname
        pokemon.ot = $Trainer.name
      end
    end
  end
  for i in 0..1    
    pokemon = $PokemonGlobal.daycare[i][0] 
    next if !pokemon
    if pokemon.ot == oldname
      pokemon.ot = $Trainer.name
    end
  end
end
