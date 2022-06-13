###Takes a pokemon object as parameter and use it's species to try and find the 
###sprits corresponding to it, using the most common names for the png file.
###if you're using a different file naming convention for your game, do edit
###the function to account for it.
def findBattlerSprite(pokemon)
  species = pokemon.species
  form = pokemon.form
  shiny = pokemon.shinyflag
  filepath = ""
  if species <10
    species = "00"+species.to_s
  elsif species >9 && species <100
    species = "0"+species.to_s
  end
  species = species.to_s
  species +="s" if shiny
  species +="_"+form.to_s if form !=0
  if !Dir.glob("Graphics/Characters/Followers/"+\
    species.to_s + \
    ".*").empty?
    filepath = "Followers/"+species.to_s + ".png"
  end
  ##You may want to disable the line below in case you're running custom shinies,
  ##since the overworld sprite uses the canon shiny colors. Or you can make 800+ 
  ##custom shiny sprites, I guess. Your call.
  return filepath
end