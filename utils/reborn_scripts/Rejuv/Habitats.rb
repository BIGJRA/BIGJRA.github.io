# ========================================================================
# Boonzeet's Habitat List
# v1.0
# ========================================================================
# Extension for the Pokedex and Town Map to display a Habitat List -
# a list of all the available Pokémon in the area, like in B2W2.
# ========================================================================
# Credit is required to use this script.
# ========================================================================]

# Functions
# ---------
# Habitats.checkMapHabitat(mapID, type) e.g. Habitats.checkMapHabitat(5,:grass)                                     
#    This checks the encounter type (from HabitatConfig::Types below) to see if
#    the player has seen or caught all the Pokémon for the type, returning 2 for
#    caught, 1 for seen, 0 for none. Used for NPCs that give items on completion.
#
# Habitats.updateHabitatsForSpecies(species)
#    Forces an update of all habitats associated with a species
#
# Habitats.setup
#    Run this to force a refresh or add Habitat data to an existing save. This 
#    will reset the status of 'viewed' Habitats back to 'alert', so a player 
#    will need to view completed habitats again to earn the badges.
#
# Habitats.update
#    Updates Pokémon data for all areas without clearing progress, unless new 
#    Pokémon appear. Use this to update if you have changed Pokémon in areas. 
#    !!! DO NOT USE if you have changed the order of the Habitats list 
#    in the config. Use Habitats.setup instead if so
#
# Notes
# ------
# If marking a Pokémon as seen for the player, use pbSetSeen. Directly
# manipulating the $Trainer.seen and $Trainer.owned arrays will not update
# Habitat data.
# For scripts that might directly edit these variables, add 
# Habitats.updateHabitatsForSpecies(species) underneath the seen/caught set.


# ========================================================================
# Config
# ========================================================================
# If using my Phenomenon script, uncomment the encounters below.

module HabitatConfig
  Types = {
    :grass => [
      EncounterTypes::Land,
      EncounterTypes::LandMorning,
      EncounterTypes::LandDay,
      EncounterTypes::LandNight,
      #EncounterTypes::PhenomenonGrass
    ],
    :surf => [
      EncounterTypes::Water,
    #EncounterTypes::PhenomenonWater
    ],
    :fish => [
      EncounterTypes::OldRod,
      EncounterTypes::GoodRod,
      EncounterTypes::SuperRod,
    ],
    :place => [
      EncounterTypes::Cave,
    #EncounterTypes::PhenomenonCave,
    #EncounterTypes::PhenomenonBird
    ],
  }
  TypeOrder = [:grass, :place, :surf, :fish] # order shown in screens
  
  # Note: It's not recommend to use Place and Grass at the same time
  # 1. Array of map IDs for the same Habitat area
  # 2. Array of the Habitat Encounter Types for this Habitat (don't mix :grass and :place)
  # This order must be kept the same if Habitat.update is intended to be used
  # Remember the commas!
  Habitats = [
    [[58], [:grass]], # East Gearen City
    [[59], [:grass]], # East Gearen City
    [[228], [:grass]], # Chrisola Hotel Rooftop
    [[24], [:grass]], # Gearen Park
    [[418], [:place]], # Hidden Library
    [[293], [:grass]], # Unown Dimension
    [[55], [:place, :fish]], # Abandoned Sewers
    [[390], [:grass, :surf, :fish]], # Chrysalis Courtyard
    [[391], [:grass, :surf, :fish]], # Chrysalis Courtyard
  [[5], [:grass, :surf, :fish]], # Route 1
    [[25], [:grass, :surf, :fish]], # Goldenwood Forest
    [[8], [:place, :surf, :fish]], # Goldenwood Cave
    [[199], [:grass, :surf, :fish]], # Route 2
    [[474], [:grass, :surf, :fish]], # Route 2 Alt
    [[159], [:place, :surf, :fish]], # Amethyst Cave
    [[161], [:place, :surf, :fish]], # Amethyst Cave
    [[4], [:place, :surf, :fish]], # Amethyst Cave
    [[184], [:place, :surf, :fish]], # Amethyst Cave
    [[77], [:place, :surf, :fish]], # Amethyst Depths
    [[109], [:place, :surf, :fish]], # Amethyst Depths
    [[162], [:place, :surf, :fish]], # Amethyst Mines
    [[488], [:grass]], # Amethyst Grotto
    [[405], [:grass]], # Pom-Pom Meadow
    [[423], [:grass, :surf, :fish]], # Sheridan Village
    [[424], [:grass, :surf, :fish]], # Sheridan Arena
    [[206], [:grass, :fish]], # Spring of Purification
    [[119], [:place, :fish]], # Carotos Mountain
    [[319], [:place, :surf, :fish]], # Carotos Mountain
    [[64], [:grass]], # Corrupted Cave
    [[22], [:surf, :fish]], # Garufa Ruins
    [[138], [:grass]], # Chamber of Awakening
    [[245], [:grass]], # Secret Shore
    [[221], [:grass, :surf, :fish]], # Sheridan Wetlands
    [[222], [:surf, :fish]], # Wetlands Laboratory
    [[67], [:grass, :surf, :fish]], # Route 3
    [[69], [:grass, :surf, :fish]], # Route 3
    [[71], [:grass, :surf, :fish]], # Route 3
    [[149], [:grass, :surf, :fish]], # Mirage Woods
    [[97], [:place, :surf, :fish]], # Phasial Cave
    [[116], [:place, :surf, :fish]], # Phasial Cave
    [[142], [:grass, :surf, :fish]], # Moon Field
    [[432], [:grass, :surf, :fish]], # River's End
    [[82], [:grass, :surf, :fish]], # Goldenleaf Town
    [[91], [:grass, :surf, :fish]], # Forgotten Path
    [[95], [:grass, :surf, :fish]], # Wispy Path
    [[102], [:grass]], # Wispy Tower
    [[403], [:grass]], # Forsaken Laboratory
    [[321], [:grass, :surf, :fish]], # Goldenwood Forest
    [[489], [:place]], # Wispy Ruins
    [[508], [:place, :surf, :fish]], # Wispy Chasm
    [[13], [:grass, :surf, :fish]], # Akuwa Town
  [[3], [:surf, :fish]], # Route 11
    [[100], [:surf, :fish]], # Route 11
    [[473], [:surf, :fish]], # Route 11
    [[479], [:place, :surf, :fish]], # Seabound Cave
    [[480], [:place, :surf, :fish]], # Seabound Cave
    [[75], [:surf, :fish]], # Evergreen Island
    [[470], [:grass, :surf, :fish]], # Evergreen Forest
    [[481], [:place, :surf, :fish]], # Evergreen Cave [South]
    [[482], [:place, :surf, :fish]], # Evergreen Cave [South]
    [[483], [:place, :surf, :fish]], # Evergreen Cave [South]
    [[269], [:place, :surf, :fish]], # Evergreen Cave [North]
    [[485], [:place, :surf, :fish]], # Evergreen Cave [North]
    [[486], [:place, :surf, :fish]], # Evergreen Cave [North]
    [[490], [:place]], # Evergreen Cave [North]
    [[491], [:place, :surf, :fish]], # Evergreen Cave [North]
    [[594], [:grass]], # Evergreen Trench
    [[595], [:grass]], # Evergreen Trench
    [[596], [:grass]], # Evergreen Trench
    [[597], [:grass]], # Evergreen Trench
    [[435], [:grass]], # Blacksteeple Castle
    [[436], [:grass]], # Blacksteeple Quarry
    [[191], [:grass, :surf, :fish]], # Terajuma Island
    [[207], [:grass, :surf, :fish]], # Terajuma Pier
    [[278], [:grass]], # Terajuma Coral Reef
    [[210], [:grass, :surf, :fish]], # Terajuma Jungle
    [[208], [:grass, :surf, :fish]], # Deep Terajuma Jungle
    [[268], [:grass, :surf, :fish]], # Deep Terajuma Jungle
    [[295], [:grass, :surf, :fish]], # Deep Terajuma Jungle
    [[406], [:grass]], # Hula Meadow
    [[298], [:surf, :fish]], # Kakori Village
    [[561], [:grass]], # Jeminra Woods
    [[562], [:grass]], # Jeminra Woods
    [[564], [:grass]], # Jeminra Woods
    [[547], [:grass]], # Jeminra Cave
    [[563], [:place]], # Jeminra Cave
    [[565], [:grass, :surf, :fish]], # Jeminra Woods
    [[566], [:grass, :surf, :fish]], # Jeminra Woods
    [[567], [:grass, :surf, :fish]], # Jeminra Woods
    [[569], [:grass, :surf, :fish]], # Jeminra Woods
    [[299], [:grass]], # Route 5
    [[300], [:grass, :surf, :fish]], # Valor Shore
    [[139], [:place, :surf, :fish]], # Valor Mountain
    [[140], [:place]], # Valor Mountain
    [[146], [:place]], # Valor Mountain
    [[175], [:grass]], # Valor Cliffside
    [[118], [:grass]], # Forest of Time
    [[301], [:grass, :surf, :fish]], # Route 6
    [[302], [:place, :surf, :fish]], # Aquamarine Cave
    [[309], [:place, :surf, :fish]], # Aquamarine Cave
    [[323], [:place, :surf, :fish]], # Aquamarine Depths
    [[324], [:surf, :fish]], # Aquamarine Chamber
    [[325], [:grass, :surf, :fish]], # Secluded Shore
    [[326], [:place, :surf, :fish]], # Aquamarine Shrine
    [[329], [:grass]], # Kristiline Town
    [[540], [:grass, :surf, :fish]], # Isle of Angels
    [[340], [:place]], # Tower of Theolia F2
    [[341], [:place]], # Tower of Theolia F3
    [[238], [:grass]], # West Gearen City
    [[239], [:grass]], # West Gearen City
    [[415], [:grass]], # WG Sewage Management
    [[350], [:grass]], # Route 7
    [[351], [:grass]], # Route 7
    [[352], [:grass]], # Route 7
    [[354], [:grass]], # Route 7 | Yui's Ranch
    [[355], [:grass]], # Route 7 | GDC Gate
    [[357], [:grass, :surf, :fish]], # Darchlight Woods
    [[358], [:grass, :surf, :fish]], # Darchlight Woods 
    [[359], [:grass, :surf, :fish]], # Darchlight Woods
    [[360], [:grass, :surf, :fish]], # Darchlight Woods
    [[368], [:grass, :surf, :fish]], # Darchlight Woods
    [[371], [:surf, :fish]], # Azure Shore
    [[408], [:grass, :surf, :fish]], # Sensu Meadow
    [[112], [:place]], # Darchlight Manor
    [[113], [:place]], # Darchlight Manor
    [[155], [:grass]], # Darchlight Manor Outside
    [[90], [:place]], # Darchlight Caves
  [[137], [:place]], # Darchlight Caves
    [[494], [:place]], # Darchlight Caves
    [[495], [:place]], # Darchlight Caves
    [[496], [:place]], # Darchlight Caves
    [[227], [:place]], # Darchlight Caves
    [[498], [:place]], # Darchlight Caves
    [[501], [:place]], # Darchlight Caves
    [[503], [:place]], # Darchlight Caves
    [[504], [:place]], # Darchlight Caves
    [[505], [:place]], # Darchlight Caves
    [[363], [:place]], # Darchlight Caves
    [[497], [:place, :surf, :fish]], # Darchlight Caves
    [[502], [:place, :surf, :fish]], # Darchlight Caves
    [[356], [:grass, :surf, :fish]], # Honec Woods
    [[369], [:grass, :surf, :fish]], # Honec Woods
    [[370], [:grass, :surf, :fish]], # Honec Woods
    [[599], [:grass]], # Swamp Pit
    [[600], [:grass]], # Kingdom of Goomidra
    [[602], [:grass]], # Castle of Goomidra
    [[361], [:grass, :surf, :fish]], # Route 8
    [[9], [:grass, :surf, :fish]], # Dream District
    [[218], [:grass, :surf, :fish]], # Dream District
    [[197], [:grass]], # Dream District
    [[192], [:grass]], # Main Street
    [[194], [:grass]], # Central Square
    [[195], [:grass, :surf, :fish]], # Residential District
    [[209], [:grass]], # Shopping District
    [[257], [:grass]], # Scholar District
    [[317], [:grass]], # Judicial District
    [[28], [:grass, :surf, :fish]], # Axis High University
    [[86], [:grass]], # Nightmare Casino
    [[254], [:grass, :surf, :fish]], # Route 9
    [[419], [:grass, :surf, :fish]], # Forlorned Cavern
    [[401], [:place]], # Backstage Theatre
    [[87], [:grass, :surf, :fish]], # Route 10
    [[373], [:grass]], # Zorrialyn Desert
    [[478], [:grass]], # Zorrialyn Desert
    [[510], [:grass, :surf, :fish]], # Zorrialyn Desert
    [[525], [:grass]], # Zorrialyn Desert
    [[515], [:grass]], # Zorrialyn Coast
    [[519], [:place]], # Voidal Chasm B3
    [[520], [:place]], # Voidal Chasm B2
    [[521], [:place]], # Voidal Chasm B2
    [[522], [:place]], # Voidal Chasm B1
    [[511], [:place]], # Sand Stream Cave
    [[512], [:place]], # Sand Stream Cave
    [[513], [:place]], # Sand Stream Cave
    [[514], [:place]], # Sand Stream Depths
    [[523], [:grass]], # Ruined City
    [[518], [:place]], # Alamissa Urben
    [[573], [:grass]], # Zone Zero
    [[576], [:grass]], # Zone Zero
    [[578], [:grass]], # Zone Zero
    [[19], [:grass]], # East Gearen City - Neo
    [[44], [:grass]], # East Gearen City - Neo
    [[571], [:grass]], # Neo Gearen Park
    [[217], [:grass, :surf, :fish]], # Goldenwood Park
    [[236], [:grass, :surf, :fish]], # Route 3 Past
    [[106], [:grass]], # Route 4 Past
    [[322], [:grass]], # Route 5 Past
    [[127], [:grass]], # Sheridan Village Past
    [[129], [:grass]], # Sheridan Village Past
    [[244], [:grass]], # Heracross Woods
    [[240], [:grass, :surf, :fish]], # Kugearen Woods
    [[330], [:grass]], # Hiyoshi City
    [[374], [:grass, :surf, :fish]] # Hiyoshi Pass
  ]
  
  # In some cases the automatic selector will choose another map on the same tile
  # e.g. a route instead of a cave. Supply the region,regionMapX,regionMapY here
  # and the mapID you want to load instead. Only one mapID for the Habitat is required.
  # Press CTRL+F on a map tile while in Debug to get the R,X,Y value quickly.
  # Remember the commas!
  RegionOverride = {
    [0,15,6] => 34,    # Ice Cave
    [0,16,10] => 49    # Rock Cave
  }
end

# ========================================================================
# Existing Class Extensions
# ========================================================================

# Adds the necessary save data to $Trainer and piggybacks on the setOwned command
class PokeBattle_Trainer
  attr_accessor(:habitatData)
  attr_accessor(:habitatPokeIndexes)
  attr_accessor(:habitatMapIndexes)

  alias setOwned_habitat setOwned
  def setOwned(species)
    setOwned_habitat(species)
    Habitats.updateHabitatsForSpecies(species)
  end
end

# Sets up Habitats automatically when a new Trainer is created
alias pbTrainerName_habitat pbTrainerName
def pbTrainerName(*args)
  pbTrainerName_habitat(*args)
  Habitats.setup # setup habitat data for a new trainer
end
  
# Modifies catch event to update Habitats list
class PokeBattle_Battle
  alias pbSetSeen_habitat pbSetSeen
  def pbSetSeen(pokemon)
    prevseen = $Trainer.seen[pokemon.species]
    pbSetSeen_habitat(pokemon)
    Habitats.updateHabitatsForSpecies(pokemon.species) if !prevseen
  end
end

# Allows Habitats code to access encounter types
class PokemonEncounters
  attr_accessor :enctypes
end

# Create a temp store of the Habitats encounters setup
class PokemonTemp
  attr_accessor :habitatEncounters
end

# Update habitats after Pokemon added
alias pbNicknameAndStore_habitat pbNicknameAndStore
def pbNicknameAndStore(pokemon)
  pbNicknameAndStore_habitat(pokemon)
  Habitats.updateHabitatsForSpecies(pokemon.species)
end

# Update habitats after Pokemon added silently
alias pbAddPokemonSilent_habitat pbAddPokemonSilent
def pbAddPokemonSilent(pokemon, level = nil, seeform = true)
  pbAddPokemonSilent_habitat(pokemon, level, seeform)
  Habitats.updateHabitatsForSpecies(pokemon.species)
end

# ========================================================================
# Habitats Classes
# ========================================================================
class Habitats
  
  # Shared for two functions. Indexes a sp
  def self.processEncounterPokemon(n, encounter, sysindex)
    # If we've not seen this 'mon, add a quick index to look up the Habitat data
    $Trainer.habitatPokeIndexes[n] = [] if !$Trainer.habitatPokeIndexes.key?(n)

    $Trainer.habitatPokeIndexes[n].push(sysindex)
    # As soon as we encounter an unowned/unseen Pokémon, we can say that the
    # player hasn't completed that part of the Habitat
    if !$Trainer.owned[n]
      encounter[:owned] = false
      if !$Trainer.seen[n]
        encounter[:seen] = false
        encounter[:alert] = false
      end
    end
  end
  
  # Loads a list of all available Pokémon across the encounter types
  # for a given Habitat Type
  def self.loadEncountersForType(index, habitatEncounter, enctypes, types, sysindex)
    pokes = []
    # Iterate over each encounter type in the Habitat type and add unique pokemon
    types.each do |t|
      if $PokemonTemp.habitatEncounters.hasEncounter?(t)
        enc = enctypes[t]
        for i in 0...enc.length
          pokes.push(enc[i][0])
        end
        pokes.uniq!
      end
    end
    if pokes.length
      pokes.each do|n|
       self.processEncounterPokemon(n,habitatEncounter,sysindex)
      end
    end
    habitatEncounter[:list].push(*pokes).uniq!
  end

  # Adds the data for a Habitat Config Item to the $Trainer.habitatData object
  def self.addHabitat(habitat, index)
    newHabitat = {
      :mapIDs => habitat[0],
      :completed => false, # gets marked as true on view
      :encounters => Hash.new,
    }
    # Add indexing for each mapID
    habitat[0].each do |n|
      $Trainer.habitatMapIndexes[n] = index
    end

    for type in habitat[1]
      newHabitat[:encounters][type] = {
        :alert => true,
        :seen => true,
        :owned => true,
        :list => [],
      }
    end
    for i in 0...habitat[0].length
      $PokemonTemp.habitatEncounters.setup(habitat[0][i])
      for type in habitat[1]
        self.loadEncountersForType(i, newHabitat[:encounters][type], 
          $PokemonTemp.habitatEncounters.enctypes, HabitatConfig::Types[type], index)
      end
    end
    return newHabitat
  end
  
  # Updates an existing habitat
  def self.updateHabitat(habitat, index)
    existingHabitat = $Trainer.habitatData[index]
    if existingHabitat == nil
      print "#{index} failed at Habitat check"
    end
    # Add or update indexing for each mapID
    habitat[0].each do |n|
      $Trainer.habitatMapIndexes[n] = index
    end
    for type in habitat[1]
      if !existingHabitat[:encounters].key?(type)
        !existingHabitat[:encounters][type] = {
          :alert => true,
          :seen => true,
          :owned => true,
          :list => [],
        }
      end
    end
    for i in 0...habitat[0].length
      $PokemonTemp.habitatEncounters.setup(habitat[0][i])
      for type in habitat[1]
        self.loadEncountersForType(i, existingHabitat[:encounters][type], 
          $PokemonTemp.habitatEncounters.enctypes, HabitatConfig::Types[type], index)
        if !existingHabitat[:encounters][type][:owned]
          existingHabitat[:completed] = false
        end
      end
    end
  end

  
  # Clears any existing habitats - avoid using as will wipe progress
  def self.clear
    $Trainer.habitatData = []
    $Trainer.habitatPokeIndexes = Hash.new
    $Trainer.habitatMapIndexes = Hash.new
  end
  
  # First-run setup of the Habitats, from the Habitat config
  def self.setup
    self.clear
    $PokemonTemp.habitatEncounters = PokemonEncounters.new
    for i in 0...HabitatConfig::Habitats.length
      habitat = addHabitat(HabitatConfig::Habitats[i], i)
      $Trainer.habitatData.push(habitat)
    end
  end
  
  # Updates the Habitats without deleting data
  def self.update
    $PokemonTemp.habitatEncounters = PokemonEncounters.new
    for i in 0...HabitatConfig::Habitats.length
      if i < $Trainer.habitatData.size
        updateHabitat(HabitatConfig::Habitats[i], i)
      else
        habitat = addHabitat(HabitatConfig::Habitats[i], i)
        $Trainer.habitatData.push(habitat)
      end
    end
  end

  # Updates the status for a habitat type. 
  # Checks if all owned/seen and sets status to alert if something's changed
  def self.updateHabitatTypeStatus(habitatType)
    seen = true
    owned = true
    habitatType[:list].each do |n|
      if !$Trainer.owned[n]
        owned = false
        if !$Trainer.seen[n]
          seen = false
          break
        end
      end
    end
    if seen != habitatType[:seen] || owned != habitatType[:owned]
      habitatType[:alert] = true
    end
    habitatType[:seen] = seen
    habitatType[:owned] = owned
  end

  # Fetches data for a Habitat
  def self.getIndexByMapID(mapID)
    return $Trainer.habitatMapIndexes.key?(mapID) ? $Trainer.habitatMapIndexes[mapID] : -1
  end

  # Updates a Habitat by its Index
  def self.updateHabitatStatus(index)
    if index > -1
      encounters = $Trainer.habitatData[index][:encounters]
      for type in encounters.keys
        self.updateHabitatTypeStatus(encounters[type])
      end
    end
  end
  
  # Updates all the Habitat records for a given species
  def self.updateHabitatsForSpecies(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species = getID(PBSpecies,species)
    end
    if $Trainer.habitatPokeIndexes && $Trainer.habitatPokeIndexes.key?(species)
      ids = $Trainer.habitatPokeIndexes[species]
      for i in 0...ids.length
        self.updateHabitatStatus(ids[i])
      end
    end
  end
  
  # Check if the player has been to the habitat
  def self.visited?(index)
    if index > $Trainer.habitatData.size
      return false
    end
    h = $Trainer.habitatData[index]
    for i in 0...h[:mapIDs].size
      if $PokemonGlobal.visitedMaps[h[:mapIDs][i]]
         return true
        break
      end
    end
    return false
  end
    

  # Checks the status of a Habitat by Map ID
  # Returns 2 if all owned, 1 if all seen, 0 if not
  def self.checkMapHabitat(mapID, type)
    index = self.getIndexByMapID(mapID)
    if index == -1
      Kernel.pbMessage("The Habitat List for map ##{mapID} isn't set up.")
      return
    end
    encounters = $Trainer.habitatData[index][:encounters]
    if encounters[type][:owned]
      return 2
    elsif encounters[type][:seen]
      return 1
    else
      return 0
    end
  end

  # Gets a list of all Habitats formatted for UI elements
  def self.getHabitatList
    commandlist = []
    if $Trainer && defined?($Trainer.habitatData)
      $Trainer.habitatData.each_with_index do |h, i|
        if self.visited?(i)
          command = [i, h[:mapIDs][0], h[:encounters], h[:completed]]
          commandlist.push(command)
        end
      end
    end
    #commandlist.sort! { |a, b| a[0] <=> b[0] }
    return commandlist
  end
  
  # finds habitat index by region map coords
  def self.getIndexByRegionCoords(x,y, region, mapdata)
    meta = pbLoadMetadata
    find = nil
    meta.each_with_index do |n,index|
      next if !n || n.size < MetadataMapPosition || !n[MetadataMapPosition]
      mappos = n[MetadataMapPosition]
      next if !mappos || mappos[0] != region
      
      # We can just return the mapID if the coords match
      if mappos[1] == x && mappos[2] == y
        sysindex = self.getIndexByMapID(index)
        return self.visited?(sysindex) ? sysindex : -1
      end
      
      # If we've still not got the map ID match, look at map shapes
      points = []
      showpoint = true
      for loc in mapdata[region][2]
        showpoint = false if loc[0] == mappos[1] && loc[1] == mappos[2] &&
                 loc[7] && !$game_switches[loc[7]]
      end
      if showpoint
        mapsize = n[MetadataMapSize]
        if mapsize && mapsize[0] && mapsize[0] > 0
          sqwidth = mapsize[0]
          sqheight = (mapsize[1].length * 1.0 / mapsize[0]).ceil
          for i in 0...sqwidth
            for j in 0...sqheight
              if mapsize[1][i + j * sqwidth, 1].to_i > 0
                points.push([mappos[1] + i,(mappos[2] + j)])
              end
            end
          end
        else
          points.push([mappos[1],mappos[2]])
        end
      end
      if points.size > 0
        points.each do |p|
          if p[0] == x && p[1] == y
            sysindex = self.getIndexByMapID(index)
            return self.visited?(sysindex) ? sysindex : -1
          end
        end
      end
    end
    return -1
  end

# -------
# Debug functions
# -------
  # Check status for all types across a Habitat
  def self.debugHabitat(index)
    if index == nil || index > $Trainer.habitatData.size
      return
    end
    habitat = $Trainer.habitatData[index]
    encounters = habitat[:encounters]
    output = "MapIDs: #{habitat[:mapIDs].join(",")}\n"
    for type in encounters.keys
      output += "#{type}: Seen #{encounters[type][:seen]},"
      output += "Owned #{encounters[type][:owned]},"
      output += "Alert #{encounters[type][:alert]}\n"
    end
    Kernel.pbMessage(output)
  end

  # Test if a species has a record in Habitats
  def self.debugSpecies(species)
    Kernel.pbMessage($Trainer.habitatPokeIndexes.keys.join(", "))
    if $Trainer.habitatPokeIndexes && $Trainer.habitatPokeIndexes.key?(species)
      Kernel.pbMessage("Species #{species} logged")
    else
      Kernel.pbMessage("Species #{species} not logged")
    end
  end
end

#===============================================================================
# Habitats Menu List UI
#===============================================================================

class Window_HabitatList < Window_DrawableCommand
  
  attr_accessor(:region)
  def initialize(x, y, width, height, viewport)
    @commands = []
    super(x, y, width, height, viewport)
    @habitatbg = Bitmap.new(32, 32)
    @habitatoverlay = Bitmap.new(32, 32)
    @habitatoverlay.fill_rect(0, 0, 32, 32, Color.new(0, 0, 0, 100))
    @habitatoverlay.fill_rect(2, 2, 28, 14, Color.new(0, 0, 0, 0))
    @habitatoverlay.fill_rect(2, 16, 28, 14, Color.new(0, 0, 0, 20))
    @selarrow = AnimatedBitmap.new("Graphics/Pictures/Habitats/cursor_list")
    @pokeballOwn = AnimatedBitmap.new("Graphics/Pictures/Habitats/icon_list_owned")
    @pokeballSeen = AnimatedBitmap.new("Graphics/Pictures/Habitats/icon_list_seen")
    @pokeballAlert = AnimatedBitmap.new("Graphics/Pictures/Habitats/icon_list_alert")

    @completed = Bitmap.new(84, height)
    bmp = BitmapCache.load_bitmap("Graphics/Pictures/Habitats/stamp_seen")
    @completed.blt(0, 0, bmp, Rect.new(0, 14, 84, 38))

    self.baseColor = Color.new(88, 88, 80)
    self.shadowColor = Color.new(168, 184, 184)
    self.windowskin = nil
  end

  def commands=(value)
    @commands = value
    refresh
  end

  def dispose
    @pokeballOwn.dispose
    @pokeballSeen.dispose
    super
  end

  def itemCount
    return @commands.length
  end

  def drawEncounterIcon(i, type, encounter, rect)
    if type == :place || type == :grass
      color = Color.new(86, 168, 0)
    elsif type == :surf
      color = Color.new(24, 206, 239)
    elsif type == :fish
      color = Color.new(24, 111, 214)
    end
    @habitatbg.fill_rect(0, 0, 32, 32, color)
    @habitatbg.stretch_blt(@habitatbg.rect, @habitatoverlay, @habitatoverlay.rect)

    baseX = rect.x + 104 - (32 * i)
    pbCopyBitmap(self.contents, @habitatbg, baseX, rect.y + 6)
    if encounter[:alert]
      pbCopyBitmap(self.contents, @pokeballAlert.bitmap, baseX + 2, rect.y + 8)
    elsif encounter[:owned]
      pbCopyBitmap(self.contents, @pokeballOwn.bitmap, baseX + 2, rect.y + 8)
    elsif encounter[:seen]
      pbCopyBitmap(self.contents, @pokeballSeen.bitmap, baseX + 2, rect.y + 8)
    end
    i += 1
  end

  def drawItem(index, count, rect)
    return if index >= self.top_row + self.page_item_max
    rect = Rect.new(rect.x, rect.y, rect.width - 16, rect.height)
    encounters = @commands[index][2]
    if @commands[index][3]
      pbCopyBitmap(self.contents, @completed, rect.x + 244, rect.y + 2)
    end

    i = 1
    HabitatConfig::TypeOrder.each do |n|
      if encounters.key?(n)
        drawEncounterIcon(i, n, encounters[n], rect)
        i += 1
      end
    end

    text = sprintf("%s", pbGetMessage(MessageTypes::MapNames, @commands[index][1]))
    pbDrawShadowText(self.contents, rect.x + 128, rect.y + 6, rect.width, rect.height,
                     text, self.baseColor, self.shadowColor)
  end

  def refresh
    @item_max = itemCount
    dwidth = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    for i in 0...@item_max
      next if i < self.top_item || i > self.top_item + self.page_item_max
      drawItem(i, @item_max, itemRect(i))
    end
    mappos = (@commands.length == 0) ? nil : pbGetMetadata(@commands[index][1], MetadataMapPosition)
    @region = (mappos) ? mappos[0] : 0                      # Region 0 default
    drawCursor(self.index, itemRect(self.index))
  end

  def update
    super
    @uparrow.visible = false
    @downarrow.visible = false
  end
end

class PokemonGlobalMetadata
  attr_accessor :habitatIndex
end

class PokemonHabitatList_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites, "background", "Habitats/bg_list", @viewport)
    @sprites["habitatlist"] = Window_HabitatList.new(100, 34, 380, 364, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["mapthumb"] = IconSprite.new(8, 68, @viewport)
    @sprites["mapthumb"].setBitmap("Graphics/Pictures/Habitats/mapthumbRegion0")
    pbSetSystemFont(@sprites["overlay"].bitmap)
    if ($PokemonGlobal.habitatIndex)
      pbRefreshHabitatList($PokemonGlobal.habitatIndex)
    else
      pbRefreshHabitatList(0)
    end

    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefreshHabitatList(index = 0)
    @habitatlist = Habitats.getHabitatList
    @sprites["habitatlist"].commands = @habitatlist
    @sprites["habitatlist"].index = index > @habitatlist.size ? 0 : index
    @sprites["habitatlist"].refresh
    pbRefresh
  end

  def pbRefresh
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    # Write various bits of text
    dexname = _INTL("Habitat List")
    textpos = [
      [dexname, Graphics.width / 2, 2, 2, Color.new(248, 248, 248), Color.new(0, 0, 0)],
    ]
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
  end

  def pbProcessEntry
    pbActivateWindow(@sprites, "habitatlist") {
      loop do
        Graphics.update
        Input.update
        oldindex = @sprites["habitatlist"].index
        pbUpdate
        if oldindex != @sprites["habitatlist"].index
          $PokemonGlobal.habitatIndex = @sprites["habitatlist"].index
          region = @sprites["habitatlist"].region
          if FileTest.image_exist?("Graphics/Pictures/Habitats/mapthumbRegion#{region}")
            @sprites["mapthumb"].setBitmap("Graphics/Pictures/Habitats/mapthumbRegion#{region}")
          end
          pbRefresh
        end
        if Input.trigger?(Input::C)
          pbPlayDecisionSE
          pbHabitatDetail(@sprites["habitatlist"].index)
        elsif Input.trigger?(Input::B)
          pbPlayCancelSE
          break
        end
      end
    }
  end

  def pbHabitatDetail(index)
    oldsprites = pbFadeOutAndHide(@sprites)
    ret = -1
    scene = HabitatDetailScene.new
    screen = HabitatDetailScreen.new(scene)
    ret = screen.pbStartScreen(index, @habitatlist, @sprites["habitatlist"].region)
    $PokemonGlobal.habitatIndex = ret
    @sprites["habitatlist"].index = ret
    @sprites["habitatlist"].refresh
    pbRefresh
    pbFadeInAndShow(@sprites, oldsprites)
  end
end

class PokemonHabitatListScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbProcessEntry
    @scene.pbEndScene
  end
end

def pbLoadHabitatList
  pbFadeOutIn(99999) {
    scene = PokemonHabitatList_Scene.new
    screen = PokemonHabitatListScreen.new(scene)
    screen.pbStartScreen
  }
end


#===============================================================================
# Habitats Menu Detail Screen UI
#===============================================================================

#============================
# Habitat View Screen
#============================
class HabitatDetailScene
  def setup(index)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @index = index
    @page = 0
    @encounter = nil
    @animateStamp = false
    @loaded = false
    @order = []
    
    @labels = {
      :grass => "Pokémon found in tall grass",
      :place => "Pokémon found in this place",
      :surf => "Pokémon found by surfing",
      :fish => "Pokémon caught with a rod",
    }
    
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::Center)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @sprites["leftarrow"] = IconSprite.new(20, 10, @viewport)
    @sprites["rightarrow"] = IconSprite.new(Graphics.width - 38, 10, @viewport)
    @sprites["leftarrow"].setBitmap("Graphics/Pictures/Habitats/selarrows")
    @sprites["rightarrow"].setBitmap("Graphics/Pictures/Habitats/selarrows")
    @sprites["leftarrow"].src_rect.set(0, 0, 18, 26)
    @sprites["rightarrow"].src_rect.set(18, 0, 18, 26)

    @sprites["habitat_icon_grass"] = IconSprite.new(0, 6, @viewport)
    @sprites["habitat_icon_surf"] = IconSprite.new(0, 6, @viewport)
    @sprites["habitat_icon_fish"] = IconSprite.new(0, 6, @viewport)
    @sprites["habitat_icon_map"] = IconSprite.new(0, 14, @viewport)
    @sprites["habitat_cursor"] = IconSprite.new(0, 2, @viewport)

    @sprites["habitat_pokemon"] = BitmapSprite.new(62, 62, @viewport)
    @sprites["habitat_pokemonbg"] = IconSprite.new(62, 48, @viewport)
    @sprites["habitat_pokemonsprite"] = IconSprite.new(62, 62, @viewport)

    @sprites["stamp"] = ChangelingSprite.new(400, 296, @viewport)
    @sprites["stamp"].addBitmap("s_owned", "Graphics/Pictures/Habitats/stamp_owned")
    @sprites["stamp"].addBitmap("s_seen", "Graphics/Pictures/Habitats/stamp_seen")
    @sprites["stamp"].visible = false
    
    @sprites["habitat_icon_grass"].setBitmap("Graphics/Pictures/Habitats/habitat_grass")
    @sprites["habitat_icon_surf"].setBitmap("Graphics/Pictures/Habitats/habitat_surf")
    @sprites["habitat_icon_fish"].setBitmap("Graphics/Pictures/Habitats/habitat_fish")
    @sprites["habitat_icon_map"].setBitmap("Graphics/Pictures/Habitats/habitat_map")
    @sprites["habitat_cursor"].setBitmap("Graphics/Pictures/Habitats/habitat_cursor")
  
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
      
  end
  
  # Start scene from Pokédex view
  def pbStartScene(index, habitatlist, region)
    setup(index)
    @single = false
    @habitatlist = habitatlist
    @habitat = $Trainer.habitatData[@habitatlist[@index][0]]
    @encpages = @habitat[:encounters].keys.size - 1
    HabitatConfig::TypeOrder.each do |n|
      if @habitat[:encounters].key?(n)
        @order.push(n)
      end
    end
    setEncounter

    pbRgssOpen("Data/townmap.dat", "rb") { |f|
      @mapdata = Marshal.load(f)
    }
    @region = region
    @sprites["areamap"] = IconSprite.new(0, 0, @viewport)
    @sprites["areamap"].setBitmap("Graphics/Pictures/#{@mapdata[@region][1]}")
    @sprites["areamap"].x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
    @sprites["areamap"].y += (Graphics.height + 46 - @sprites["areamap"].bitmap.height) / 2
    for hidden in REGIONMAPEXTRAS
      if hidden[0] == @region && hidden[1] > 0 && $game_switches[hidden[1]]
        pbDrawImagePositions(@sprites["areamap"].bitmap, [
          ["Graphics/Pictures/#{hidden[4]}",
           hidden[2] * PokemonRegionMap_Scene::SQUAREWIDTH,
           hidden[3] * PokemonRegionMap_Scene::SQUAREHEIGHT, 0, 0, -1, -1],
        ])
      end
    end
    @sprites["areahighlight"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
    @loaded = true
    updateStamp
  end
  
  # Start scene from Region Map view
  def pbStartSceneSingle(index)
    setup(index)
    @single = true
    @sprites["habitat_icon_map"].visible = false
    @habitat = $Trainer.habitatData[index]
    @encpages = @habitat[:encounters].keys.size - 1
    HabitatConfig::TypeOrder.each do |n|
      if @habitat[:encounters].key?(n)
        @order.push(n)
      end
    end
    setEncounter
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
    @loaded = true
    updateStamp
  end

  def pbUpdateHabitat
    for i in 0...@encounter[:list].size
      if defined?(@sprites["pokemon#{i}"])
        @sprites["pokemon#{i}"].dispose
      end
    end
    @habitat = $Trainer.habitatData[@habitatlist[@index][0]]
    @order = []
  
    HabitatConfig::TypeOrder.each do |n|
      if @habitat[:encounters].key?(n)
        @order.push(n)
      end
    end

    oldsize = @encpages
    @encpages = @order.size - 1
    if @page == oldsize
      @page = @encpages
    elsif @page >= @encpages
      @page = @encpages
    end
  end

  def setEncounter
    key = @order[@page]
    @encounter = @habitat[:encounters][key]
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbUpdate
    if @single == false && @page == -1 
      intensity = (Graphics.frame_count % 40) * 12
      intensity = 480 - intensity if intensity > 240
      @sprites["areahighlight"].opacity = intensity
    end
    pbUpdateSpriteHash(@sprites)
  end

  def drawPage(page)
    setEncounter
    
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    if @single == false 
      @sprites["areamap"].visible = (@page == -1) if @sprites["areamap"]
      @sprites["areahighlight"].visible = (@page == -1) if @sprites["areahighlight"]
    end
    
    @sprites["habitat_icon_grass"].visible = false
    @sprites["habitat_icon_surf"].visible = false
    @sprites["habitat_icon_fish"].visible = false
    @sprites["habitat_cursor"].visible = true
    @sprites["stamp"].visible = false

    # uses the TypeOrder to print keys in order
    x = 0
    @order.each_with_index do |key, i|
      x = 52 + ((i + (@single == false ? 1 : 0)) * 70)
      sprite = ""
      case key
      when :grass
        sprite = "habitat_icon_grass"
      when :place
        sprite = "habitat_icon_grass"
      when :surf
        sprite = "habitat_icon_surf"
      when :fish
        sprite = "habitat_icon_fish"
      end
      @sprites[sprite].x = x
      @sprites[sprite].visible = true

      if i == page
        @sprites["habitat_cursor"].x = x - 4
      end
    end
    if @single == false
      @sprites["habitat_icon_map"].x = 60
    end

    # control visuals depending on page
    @sprites["leftarrow"].opacity = 255
    @sprites["rightarrow"].opacity = 255
    if page == @encpages
      @sprites["rightarrow"].opacity = 125
    end
    if @single == false
      if page == -1
        @sprites["habitat_icon_map"].opacity = 255
        @sprites["habitat_cursor"].x = 48
        @sprites["leftarrow"].opacity = 125
      else
        @sprites["habitat_icon_map"].opacity = 125
      end
    else
      if @page == 0
        @sprites["leftarrow"].opacity = 125
      end
    end
        
    # Draw page-specific information
    if @single || page > -1
      key = @order[page]
      drawPageInfo(key)
    else
      drawPageArea
    end
  end

  def updateStamp
    if @page > -1 && @encounter != nil
      # if alert flag is set, play the stamp animation
      if @encounter[:alert]
        return if !@loaded # wait until load to play anim
        animateStamp(@encounter[:owned]) if @encounter != nil
        @encounter[:alert] = false
        completed = true
        for type in @habitat[:encounters].keys
          if @habitat[:encounters][type][:alert] || !@habitat[:encounters][type][:owned]
            completed = false
          end
        end
        @habitat[:completed] = completed

        # otherwise just draw the appropriate stamp
      elsif @encounter[:owned] || @encounter[:seen]
        drawStamp(@encounter[:owned])
      end
    end
  end

  # Draws a stamp animation. Takes owned true/false to determine owned/seen stamp
  def animateStamp(owned)
    @sprites["stamp"].changeBitmap(owned ? "s_owned" : "s_seen")
    @sprites["stamp"].opacity = 0
    @sprites["stamp"].x -= 34
    @sprites["stamp"].y -= 34
    @sprites["stamp"].zoom_x = 1.51
    @sprites["stamp"].zoom_y = 1.51
    @sprites["stamp"].visible = true

    for i in 0..17
      @sprites["stamp"].opacity += 15
      if @sprites["stamp"].zoom_x > 1.0
        @sprites["stamp"].zoom_x -= 0.03
        @sprites["stamp"].zoom_y -= 0.03
      end
      if @sprites["stamp"].x < 400
        @sprites["stamp"].x += 2
        @sprites["stamp"].y += 2
      end
      if @sprites["stamp"].opacity > 255
        @sprites["stamp"].opacity = 255
      end
      pbWait(1)
      Graphics.update
    end
  end

  # Draws a stamp without animation
  def drawStamp(owned)
    @sprites["stamp"].changeBitmap(owned ? "s_owned" : "s_seen")
    @sprites["stamp"].visible = true
  end

  def drawPageInfo(type)
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Habitats/bg_info"))

    @encounter[:list].each_with_index do |n, i|
      x = (i % 6) * 72 + 36
      y = ((i.to_f / 6).floor * 64) + 80
      status = "none"
      if $Trainer.owned[i]
        status = "owned"
      elsif $Trainer.seen[i]
        status = "seen"
      end
      @sprites["pokemon#{i}"] = HabitatPokemonPanel.new(n, status, x, y, @viewport)
    end
    
    typelabel = @labels.key?(type) ? @labels[type] : @labels[:place]
    
    overlay = @sprites["overlay"].bitmap
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    textpos = [
      [pbGetMessage(MessageTypes::MapNames, @habitat[:mapIDs][0]), 24, 298, 0, base, shadow],
      [typelabel, 24, 338, 0, base, shadow],
    ]
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)

    @sprites["stamp"].visible = false
    updateStamp
  end

  def drawPageArea
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Habitats/bg_info"))
    overlay = @sprites["overlay"].bitmap
    base = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    @sprites["areahighlight"].bitmap.clear
    # Fill the array "points" with all squares of the region map in which the
    # species can be found
    points = []
    mapwidth = 1 + PokemonRegionMap_Scene::RIGHT - PokemonRegionMap_Scene::LEFT
    @habitat[:mapIDs].each do |map|
      mappos = pbGetMetadata(map, MetadataMapPosition)
      if mappos && mappos[0] == @region
        showpoint = true
        for loc in @mapdata[@region][2]
          showpoint = false if loc[0] == mappos[1] && loc[1] == mappos[2] &&
                               loc[7] && !$game_switches[loc[7]]
        end
        if showpoint
          mapsize = pbGetMetadata(map, MetadataMapSize)
          if mapsize && mapsize[0] && mapsize[0] > 0
            sqwidth = mapsize[0]
            sqheight = (mapsize[1].length * 1.0 / mapsize[0]).ceil
            for i in 0...sqwidth
              for j in 0...sqheight
                if mapsize[1][i + j * sqwidth, 1].to_i > 0
                  points[mappos[1] + i + (mappos[2] + j) * mapwidth] = true
                end
              end
            end
          else
            points[mappos[1] + mappos[2] * mapwidth] = true
          end
        end
      end
    end
    # Draw coloured squares on each square of the region map with a nest
    pointcolor = Color.new(0, 248, 248)
    pointcolorhl = Color.new(192, 248, 248)
    sqwidth = PokemonRegionMap_Scene::SQUAREWIDTH
    sqheight = PokemonRegionMap_Scene::SQUAREHEIGHT
    for j in 0...points.length
      if points[j]
        x = (j % mapwidth) * sqwidth
        x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
        y = (j / mapwidth) * sqheight
        y += (Graphics.height + 46 - @sprites["areamap"].bitmap.height) / 2
        @sprites["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
        if j - mapwidth < 0 || !points[j - mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
        end
        if j + mapwidth >= points.length || !points[j + mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
        end
        if j % mapwidth == 0 || !points[j - 1]
          @sprites["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
        end
        if (j + 1) % mapwidth == 0 || !points[j + 1]
          @sprites["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
        end
      end
    end
    # Set the text
    textpos = []
    if points.length == 0
      pbDrawImagePositions(overlay, [
        [sprintf("Graphics/Pictures/Pokedex/overlay_areanone"), 108, 188, 0, 0, -1, -1],
      ])
      textpos.push([_INTL("Area unknown"), Graphics.width / 2, Graphics.height / 2, 2, base, shadow])
    end
    pbDrawTextPositions(overlay, textpos)
  end

  def pbGoToPrevious
    newindex = @index
    if newindex > 0
      newindex -= 1
    end
    @index = newindex
  end

  def pbGoToNext
    newindex = @index
    if newindex < @habitatlist.length - 1
      newindex += 1
    end
    @index = newindex
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      #elsif Input.trigger?(Input::C)
        #
      elsif Input.trigger?(Input::UP) && @single == false
        oldindex = @index
        pbGoToPrevious
        if @index != oldindex
          pbPlayDecisionSE
          pbUpdateHabitat
          pbSEStop
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && @single == false
        oldindex = @index
        pbGoToNext
        if @index != oldindex
          pbPlayDecisionSE
          pbUpdateHabitat
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        if @single
          @page = 0 if @page < 0
        else
          @page = -1 if @page < -1
        end
        @page = @encpages if @page > @encpages
        if @page != oldpage
          pbPlayCursorSE
          for i in 0...@encounter[:list].size
            if @sprites["pokemon#{i}"] && !@sprites["pokemon#{i}"].disposed?
              @sprites["pokemon#{i}"].dispose
            end
          end
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        if @single
          @page = 0 if @page < 0
        else
          @page = -1 if @page < -1
        end
        @page = @encpages if @page > @encpages
        if @page != oldpage
          pbPlayCursorSE
          for i in 0...@encounter[:list].size
            if defined?(@sprites["pokemon#{i}"]) &&
               @sprites["pokemon#{i}"] != nil && !@sprites["pokemon#{i}"].disposed?
              @sprites["pokemon#{i}"].dispose
            end
          end
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end
end

class HabitatDetailScreen
  def initialize(scene)
    @scene = scene
  end
  
  def pbStartScreenSingle(index)
    @scene.pbStartSceneSingle(index)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartScreen(index, habitat, region)
    @scene.pbStartScene(index, habitat, region)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret   # Index of last habitat viewed in list
  end
end

class HabitatPokemonPanel < SpriteWrapper
  attr_reader :pokemon
  attr_accessor :icon

  def initialize(pokemonID, status, x, y, viewport = nil)
    super(viewport)
    self.x = x
    self.y = y
    @id = pokemonID
    @status = status
    @refreshing = true
    @panelbgsprite = IconSprite.new(64, 48, viewport)
    @panelbgsprite.z = self.z + 1
    @panelbgsprite.setBitmap("Graphics/Pictures/Habitats/ListPokemonBg")

    @pkmnsprite = IconSprite.new(0, 0, viewport)
    @pkmnsprite.setBitmap(pbCheckPokemonIconFiles([pokemonID, false, false, 0, false], false))
    @pkmnsprite.z = self.z + 2
    @pkmnsprite.src_rect.set(0, 0, 64, 64)

    @caughticonsprite = ChangelingSprite.new(48, 0, viewport)
    @caughticonsprite.addBitmap("owned", "Graphics/Pictures/Habitats/iconowned")
    @caughticonsprite.addBitmap("seen", "Graphics/Pictures/Habitats/iconseen")
    @caughticonsprite.z = self.z + 3

    @overlaysprite = BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    @overlaysprite.z = self.z + 4
    @refreshing = false
    refresh
  end

  def dispose
    @pkmnsprite.dispose
    @panelbgsprite.dispose
    @caughticonsprite.dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    super
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
    refresh
  end

  def refresh
    return if disposed?
    return if @refreshing
    @refreshing = true
    if @panelbgsprite && !@panelbgsprite.disposed?
      @panelbgsprite.x = self.x
      @panelbgsprite.y = self.y
      @panelbgsprite.color = self.color
    end
    if @caughticonsprite && !@caughticonsprite.disposed?
      if $Trainer.owned[@id]
        @caughticonsprite.changeBitmap("owned")
        @caughticonsprite.visible = true
      elsif $Trainer.seen[@id]
        @caughticonsprite.changeBitmap("seen")
        @caughticonsprite.visible = true
      else
        @caughticonsprite.visible = false
      end
      @caughticonsprite.x = self.x + 46
      @caughticonsprite.y = self.y + 2
      @caughticonsprite.color = self.color
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x = self.x
      @pkmnsprite.y = self.y - 16
      @pkmnsprite.color = self.color
      @pkmnsprite.visible = @caughticonsprite.visible
    end
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x = self.x
      @overlaysprite.y = self.y
      @overlaysprite.color = self.color
    end
    @refreshing = false
  end

  def update
    super
    @caughticonsprite.update if @caughticonsprite && !@caughticonsprite.disposed?
    @pkmnsprite.update if @pkmnsprite && !@pkmnsprite.disposed?
  end
end
