class PokeBattle_Pokemon
  attr_accessor :chatter
end



def pbChatter(pokemon)
  iconwindow=PictureWindow.new(pbLoadPokemonBitmap(pokemon))
  iconwindow.x=(Graphics.width/2)-(iconwindow.width/2)
  iconwindow.y=((Graphics.height-96)/2)-(iconwindow.height/2)
  if pokemon.chatter
    Kernel.pbMessage(_INTL("It will forget the song it knows."))
    if !Kernel.pbConfirmMessage(_INTL("Are you sure you want to change it?"))
      iconwindow.dispose
      return
    end
  end
  if Kernel.pbConfirmMessage(_INTL("Do you want to change its song now?"))
    wave=pbRecord(nil,5)
    if wave
      pokemon.chatter=wave
      Kernel.pbMessage(_INTL("{1} learned a new song!",pokemon.name))
    end
  end
  iconwindow.dispose
  return
end



#HiddenMoveHandlers.addCanUseMove(:CHATTER,proc {|item,pokemon|
#   return true
#});

#HiddenMoveHandlers.addUseMove(:CHATTER,proc {|item,pokemon|
#   pbChatter(pokemon)
#   return true
#});


class PokeBattle_Scene
  def pbChatter(attacker,opponent)
    if attacker.pokemon
      pbPlayCry(attacker.pokemon,90,100)
    end
    Graphics.frame_rate.times do
      Graphics.update
      Input.update
    end
  end
end