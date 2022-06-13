#===============================================================================
# * The maximum level Pokémon can reach.
# * The level of newly hatched Pokémon.
# * The odds of a newly generated Pokémon being shiny (out of 65536).
# * The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
#===============================================================================
MAXIMUMLEVEL       = 100
EGGINITIALLEVEL    = 1
SHINYPOKEMONCHANCE = 700 # = 1.07% #65535
POKERUSCHANCE      = 3
OVERWORLD_ENCOUNTER_SWITCH = 1299

#===============================================================================
# * The default screen width (at a zoom of 1.0; size is half this at zoom 0.5).
# * The default screen height (at a zoom of 1.0).
# * The default screen zoom. (1.0 means each tile is 32x32 pixels, 0.5 means
#      each tile is 16x16 pixels, 2.0 means each tile is 64x64 pixels.)
# * M2ap view mode (0=original, 1=custom, 2=perspective).
#===============================================================================
DEFAULTSCREENWIDTH  = 512
DEFAULTSCREENHEIGHT = 384
DEFAULTSCREENZOOM   = 1.0
FULLSCREENBORDERCROP = false
BORDERWIDTH          = 80
BORDERHEIGHT         = 80
MAPVIEWMODE         = 1
# To forbid the player from changing the screen size themselves, quote out or
# delete the relevant bit of code in the PokemonOptions script section.hanging the screen size themselves, quote out or
# delete the relevant bit of code in the PokemonOptions script section.

#===============================================================================
# * Whether poisoned Pokémon will lose HP while walking around in the field.
# * Whether poisoned Pokémon will faint while walking around in the field
#      (true), or survive the poisoning with 1HP (false).
# * Whether fishing automatically hooks the Pokémon (if false, there is a
#      reaction test first).
# * Whether TMs can be used infinitely as in Gen 5 (true), or are one-use-only
#      as in older Gens (false).
# * Whether the player can surface from anywhere while diving (true), or only in
#      spots where they could dive down from above (false).
# * Whether a move's physical/special category depends on the move itself as in
#      newer Gens (true), or on its type as in older Gens (false).
# * Whether the Exp gained from beating a Pokémon should be scaled depending on
#      the gainer's level as in Gen 5 (true), or not as in older Gens (false).
# * Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3
#      mechanics (false).
# * Whether the Exp gained from beating a Pokémon should be divided equally
#      between each participant (false), or whether each participant should gain
#      that much Exp. This also applies to Exp gained via the Exp Share (held
#      item version) being distributed to all Exp Share holders. This is true in
#      Gen 6 and false otherwise.
#===============================================================================
POISONINFIELD         = false
POISONFAINTINFIELD    = false
FISHINGAUTOHOOK       = false
INFINITETMS           = true
DIVINGSURFACEANYWHERE = false
USEMOVECATEGORY       = true
USENEWEXPFORMULA      = true
NEWBERRYPLANTS        = true
NOSPLITEXP            = false

#===============================================================================
# * Pairs of map IDs, where the location signpost isn't shown when moving from
#      one of the maps in a pair to the other (and vice versa).  Useful for
#      single long routes/towns that are spread over multiple maps.
# e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
#   Moving between two maps that have the exact same name won't show the
#      location signpost anyway, so you don't need to list those maps here.
#===============================================================================
 NOSIGNPOSTS =  [] 

#===============================================================================
# * Whether outdoor maps should be shaded according to the time of day.
#===============================================================================
ENABLESHADING = true

#===============================================================================
# * The minimum number of badges required to boost each stat of a player's
#      Pokémon by 1.1x, while using moves in battle only.
# * Whether the badge restriction on using certain hidden moves is either owning
#      at least a certain number of badges (true), or owning a particular badge
#      (false).
# * Depending on HIDDENMOVESCOUNTBADGES, either the number of badges required to
#      use each hidden move, or the specific badge number required to use each
#      move.  Remember that badge 0 is the first badge, badge 1 is the second
#      badge, etc.
# e.g. To require the second badge, put false and 1.
#      To require at least 2 badges, put true and 2.
#===============================================================================
BADGESBOOSTATTACK      = 999
BADGESBOOSTDEFENSE     = 999
BADGESBOOSTSPEED       = 999
BADGESBOOSTSPATK       = 999
BADGESBOOSTSPDEF       = 999
HIDDENMOVESCOUNTBADGES = true
BADGEFORCUT            = 2
BADGEFORFLASH          = 2
BADGEFORROCKCLIMB      = 7
BADGEFORROCKSMASH      = 0
BADGEFORSURF           = 5
BADGEFORFLY            = 12
BADGEFORSTRENGTH       = 9
BADGEFORDIVE           = 13
BADGEFORWATERFALL      = 18
BADGEFORLAVASURF       = 6 

#===============================================================================
# * The names of each pocket of the Bag.  Leave the first entry blank.
# * The maximum number of slots per pocket (-1 means infinite number).  Ignore
#      the first number (0).
# * The maximum number of items each slot in the Bag can hold.
# * Whether each pocket in turn auto-sorts itself by item ID number.  Ignore
#      the first entry (the 0).
# * The pocket number containing all berries.  Is opened when choosing one to
#      plant, and cannot view a different pocket while doing so.
#===============================================================================
def pbPocketNames; return ["",
   _INTL("Items"),
   _INTL("Medicine"),
   _INTL("Poké Balls"),
   _INTL("TMs & HMs"),
   _INTL("Berries"),
   _INTL("Enhancements"),
   _INTL("Battle Items"),
   _INTL("Key Items")
]; end
MAXPOCKETSIZE  = [0,-1,-1,-1,-1,-1,-1,-1,-1]
BAGMAXPERSLOT  = 999
POCKETAUTOSORT = [0,false,false,false,true,true,false,false,false]
BERRYPOCKET    = 5

#===============================================================================
# * The name of the person who created the Pokémon storage system.
# * The number of boxes in Pokémon storage.
#===============================================================================
def pbStorageCreator
  return _INTL("Dean")
end
STORAGEBOXES = 35

#===============================================================================
# * Whether the Pokédex list shown is the one for the player's current region
#      (true), or whether a menu pops up for the player to manually choose which
#      Dex list to view when appropriate (false).
# * The names of each Dex list in the game, in order and with National Dex at
#      the end.  This is also the order that $PokemonGlobal.pokedexUnlocked is
#      in, which records which Dexes have been unlocked (first is unlocked by
#      default).
#      You can define which region a particular Dex list is linked to.  This
#      means the area map shown while viewing that Dex list will ALWAYS be that
#      of the defined region, rather than whichever region the player is
#      currently in.  To define this, put the Dex name and the region number in
#      an array, like the Kanto and Johto Dexes are.  The National Dex isn't in
#      an array with a region number, therefore its area map is whichever region
#      the player is currently in.
# * Whether all forms of a given species will be immediately available to view
#      in the Pokédex so long as that species has been seen at all (true), or
#      whether each form needs to be seen specifically before that form appears
#      in the Pokédex (false).
# * An array of numbers, where each number is that of a Dex list (National Dex
#      is -1).  All Dex lists included here have the species numbers in them
#      reduced by 1, thus making the first listed species have a species number
#      of 0 (e.g. Victini).
#===============================================================================
DEXDEPENDSONLOCATION = false
def pbDexNames; return [
   [_INTL("Aevium Pokédex"),0],
   _INTL("National Pokédex")
]; end
ALWAYSSHOWALLFORMS = false
DEXINDEXOFFSETS    = []
#===============================================================================
# * The amount of money the player starts the game with.
# * The maximum amount of money the player can have.
# * The maximum number of Game Corner coins the player can have.
#===============================================================================
INITIALMONEY = 1500
MAXMONEY     = 9999999
MAXCOINS     = 99999

#===============================================================================
# * A set of arrays each containing a trainer type followed by a Global Variable
#      number.  If the variable isn't set to 0, then all trainers with the
#      associated trainer type will be named as whatever is in that variable.
#===============================================================================
RIVALNAMES = [
   [:RIVAL1,12],
   [:RIVAL2,12],
   [:CHAMPION,12]
]

#===============================================================================
# * A list of maps used by roaming Pokémon.  Each map has an array of other maps
#      it can lead to.
# * A set of arrays each containing the details of a roaming Pokémon.  The
#      information within is as follows:
#      - Species.
#      - Level.
#      - Global Switch; the Pokémon roams while this is ON.
#      - Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
#           4=surfing/fishing).  See bottom of PokemonRoaming for lists.
#      - Name of BGM to play for that encounter (optional).
#      - Roaming areas specifically for this Pokémon (optional).
#===============================================================================
RoamingAreas = {
   5  => [21,28,31,39,41,44,47,66,69],
   21 => [5,28,31,39,41,44,47,66,69],
   28 => [5,21,31,39,41,44,47,66,69],
   31 => [5,21,28,39,41,44,47,66,69],
   39 => [5,21,28,31,41,44,47,66,69],
   41 => [5,21,28,31,39,44,47,66,69],
   44 => [5,21,28,31,39,41,47,66,69],
   47 => [5,21,28,31,39,41,44,66,69],
   66 => [5,21,28,31,39,41,44,47,69],
   69 => [5,21,28,31,39,41,44,47,66]
}
RoamingSpecies = [
]

#===============================================================================
# * A set of arrays each containing details of a wild encounter that can only
#      occur via using the Poké Radar.  The information within is as follows:
#      - Map ID on which this encounter can occur.
#      - Probability that this encounter will occur (as a percentage).
#      - Species.
#      - Minimum possible level.
#      - Maximum possible level (optional).
#===============================================================================
POKERADAREXCLUSIVES=[
   [5,  20, :STARLY,     12, 15],
   [21, 10, :STANTLER,   14],
   [28, 20, :BUTTERFREE, 15, 18],
   [28, 20, :BEEDRILL,   15, 18]
]

#===============================================================================
# * A set of arrays each containing details of a graphic to be shown on the
#      region map if appropriate.  The values for each array are as follows:
#      - Region number.
#      - Global Switch; the graphic is shown if this is ON (non-wall maps only).
#      - X coordinate of the graphic on the map, in squares.
#      - Y coordinate of the graphic on the map, in squares.
#      - Name of the graphic, found in the Graphics/Pictures folder.
#      - The graphic will always (true) or never (false) be shown on a wall map.
# * Number of regional maps (needed for Town Map and Fly)
#===============================================================================
REGIONMAPEXTRAS = [
]
NUMREGIONMAPS = 3

#===============================================================================
# * The number of steps allowed before a Safari Zone game is over (0=infinite).
# * The number of seconds a Bug Catching Contest lasts for (0=infinite).
#===============================================================================
SAFARISTEPS    = 800
BUGCONTESTTIME = 1200

#===============================================================================
# * The Global Switch that is set to ON when the player whites out.
# * The Global Switch that is set to ON when the player has seen Pokérus in the
#      Poké Center, and doesn't need to be told about it again.
# * The Global Switch which, while ON, makes all wild Pokémon created be
#      shiny.
# * The Global Switch which, while ON, makes all Pokémon created considered to
#      be met via a fateful encounter.
# * The Global Switch which determines whether the player will lose money if
#      they lose a battle (they can still gain money from trainers for winning).
# * The Global Switch which, while ON, prevents all Pokémon in battle from Mega
#      Evolving even if they otherwise could.
# * The ID of the common event that runs when the player starts fishing (runs
#      instead of showing the casting animation).
# * The ID of the common event that runs when the player stops fishing (runs
#      instead of showing the reeling in animation).
#===============================================================================
STARTING_OVER_SWITCH      = 1
SEEN_POKERUS_SWITCH       = 2
SHINY_WILD_POKEMON_SWITCH = 31
FATEFUL_ENCOUNTER_SWITCH  = 32
NO_MONEY_LOSS             = 33
NO_MEGA_EVOLUTION         = 34
NO_Z_MOVE                 = 1174
FISHINGBEGINCOMMONEVENT   = -1
FISHINGENDCOMMONEVENT     = -1

#===============================================================================
# * The ID of the animation played when the player steps on grass (shows grass
#      rustling).
# * The ID of the animation played when a trainer notices the player (an
#      exclamation bubble).
# * The ID of the animation played when a patch of grass rustles due to using
#      the Poké Radar.
# * The ID of the animation played when a patch of grass rustles vigorously due
#      to using the Poké Radar. (Rarer species)
# * The ID of the animation played when a patch of grass rustles and shines due
#      to using the Poké Radar. (Shiny encounter)
# * The ID of the animation played when a berry tree grows a stage while the
#      player is on the map (for new plant growth mechanics only).
#===============================================================================
GRASS_ANIMATION_ID           = 1
DUST_ANIMATION_ID            = 2
EXCLAMATION_ANIMATION_ID     = 35
RUSTLE_NORMAL_ANIMATION_ID   = 1
RUSTLE_VIGOROUS_ANIMATION_ID = 11
RUSTLE_SHINY_ANIMATION_ID    = 12
PLANT_SPARKLE_ANIMATION_ID   = 13
POKEMON_APPEAR_ANIMATION_ID  = 69

#===============================================================================
# * An array of available languages in the game, and their corresponding
#      message file in the Data folder.  Edit only if you have 2 or more
#      languages to choose from.
#===============================================================================
LANGUAGES = [  
#  ["English","english.dat"],
#  ["Deutsch","deutsch.dat"]
]

#===============================================================================
# * Whether names can be typed using the keyboard (true) or chosen letter by
#      letter as in the official games (false).
#===============================================================================
USEKEYBOARDTEXTENTRY = true
#### SARDINES - debuglog - START
$INTERNAL=false
#### SARDINES - debuglog - END
$VERBOSE=nil
$DEBUG=true