require 'json'
require 'yaml'
require 'nokogiri'
require 'date'

UTILS_DIR = File.dirname(File.expand_path(__FILE__))
ROOT_DIR = File.dirname(UTILS_DIR)
CONFIG = YAML.safe_load(File.open(File.join(ROOT_DIR, '_config.yml')))

VERSIONS = { 'reborn' => "19.5.18" , 'rejuv' => "13.5.6"}

LONGNAMES = { 'reborn' => 'reborn', 'rejuv' => 'rejuvenation'}

FIELDS = {
  RANDOM: 'Random Field',
  ELECTERRAIN: 'Electric Terrain',
  GRASSY: 'Grassy Terrain',
  MISTY: 'Misty Terrain',
  DARKCRYSTALCAVERN: 'Dark Crystal Cavern',
  CHESS: 'Chess Board',
  BIGTOP: 'Big Top Arena',
  BURNING: 'Burning Field',
  SWAMP: 'Swamp Field',
  RAINBOW: 'Rainbow Field',
  CORROSIVE: 'Corrosive Field',
  CORROSIVEMIST: 'Corrosive Mist Field',
  DESERT: 'Desert Field',
  ICY: 'Icy Field',
  ROCKY: 'Rocky Field',
  FOREST: 'Forest Field',
  SUPERHEATED: 'Super-Heated Field',
  FACTORY: 'Factory Field',
  SHORTCIRCUIT: 'Short-Circuit Field',
  WASTELAND: 'Wasteland',
  ASHENBEACH: 'Ashen Beach',
  WATERSURFACE: 'Water Surface',
  UNDERWATER: 'Underwater',
  CAVE: 'Cave',
  GLITCH: 'Glitch Field',
  CRYSTALCAVERN: 'Crystal Cavern',
  MURKWATERSURFACE: 'Murkwater Surface',
  MOUNTAIN: 'Mountain',
  SNOWYMOUNTAIN: 'Snowy Mountain',
  HOLY: 'Holy Field',
  MIRROR: 'Mirror Arena',
  FAIRYTALE: 'Fairy Tale Field',
  DRAGONSDEN: "Dragon's Den",
  FLOWERGARDEN1: 'Flower Garden Field',
  FLOWERGARDEN2: 'Flower Garden Field',
  FLOWERGARDEN3: 'Flower Garden Field',
  FLOWERGARDEN4: 'Flower Garden Field',
  FLOWERGARDEN5: 'Flower Garden Field',
  STARLIGHT: 'Starlight Arena',
  NEWWORLD: 'New World',
  INVERSE: 'Inverse Field',
  PSYTERRAIN: 'Psychic Terrain',
  VOLCANIC: 'Volcanic Field',
  VOLCANICTOP: 'Volcanic Top',
  DIMENSIONAL: 'Dimensional Field',
  FROZENDIMENSION: 'Frozen Dimensional Field',
  HAUNTED: 'Haunted Field',
  CORRUPTED: 'Corrupted Cave',
  BEWITCHED: 'Bewitched Woods',
  SKY: 'Sky Field',
  COLOSSEUM: 'Colosseum Field',
  INFERNAL: 'Infernal Field',
  CONCERT1: 'Concert Venue',
  CONCERT2: 'Concert Venue',
  CONCERT3: 'Concert Venue',
  CONCERT4: 'Concert Venue',
  DEEPEARTH: 'Deep Earth Field',
  BACKALLEY: 'Back Alley Field',
  CITY: 'City Field',
}

TYPE_IMGS = { LandMorning: 'morning', LandDay: 'day', LandNight: 'night', OldRod: 'oldrod',
              GoodRod: 'goodrod', SuperRod: 'superrod' }

EV_ARRAY = %w[HP Atk Def SpA SpD Spe]

ENCOUNTER_MAPS = {
  RATTATA: { 1 => 'Rattata' },
  RATICATE: { 1 => 'Rattata' },
  SANDSHREW: { 1 => 'Sandshrew' },
  SANDSLASH: { 1 => 'Sandshrew' },
  VULPIX: { 1 => 'Vulpix' },
  NINETALES: { 1 => 'Vulpix' },
  DIGLETT: { 1 => 'Diglett' },
  DUGTRIO: { 1 => 'Diglett' },
  MEOWTH: { 1 => 'Rattata', 2 => 'Meowth' },
  PERSIAN: { 1 => 'Rattata', 2 => 'Meowth' },
  GEODUDE: { 1 => 'Geodude' },
  GRAVELER: { 1 => 'Geodude' },
  GOLEM: { 1 => 'Geodude' },
  GRIMER: { 1 => 'Grimer' },
  MUK: { 1 => 'Grimer' },
  MAROWAK: { 1 => 'Cubone' },
  MRMIME: { 1 => 'MrMime' },
  DARUMAKA: { 1 => 'Darumaka' },
  PONYTA: { 1 => 'Ponyta' },
  RAPIDASH: { 1 => 'Ponyta' },
  SLOWPOKE: { 1 => 'Slowpoke' },
  SLOWBRO: { 1 => 'Slowpoke' },
  SLOWKING: { 1 => 'Slowpoke' },
  FARFETCHD: { 1 => 'Farfetchd' },
  WEEZING: {1 => 'Weezing' },
  EXEGGUTOR: {1 => 'Exeggutor' },
  ZIGZAGOON: { 1 => 'Zigzagoon' },
  LINOONE: { 1 => 'Zigzagoon' },
  YAMASK: { 1 => 'YamaskSpawn' },
  STUNFISK: { 1 => 'Stunfisk' },
  CORSOLA: { 1 => 'Corsola' },
  GROWLITHE: { 1 => 'Growlithe' },
  ARCANINE: { 1 => 'Growlithe' },
  VOLTORB: { 1 => 'Voltorb' },
  ELECTRODE: { 1 => 'Voltorb' },
  TYPHLOSION: { 1 => 'Typhlosion' },
  QWILFISH: { 1 => 'Qwilfish' },
  SNEASEL: { 1 => 'Sneasel' },
  SAMUROTT: { 1 => 'Samurott' },
  LILLIGANT: { 1 => 'Lilligant' },
  BASCULIN: { 2 => 'Basculin' },
  ZORUA: { 1 => 'Zorua' },
  ZOROARK: { 1 => 'Zorua' },
  BRAVIARY: { 1 => 'Braviary' },
  SLIGGOO: { 1 => 'Sliggoo' },
  GOODRA: { 1 => 'Sliggoo' },
  AVALUGG: { 1 => 'Avalugg' },
  DECIDUEYE: { 1 => 'Decidueye' },
  PARAS: { 1 => 'Paras' },
  PARASECT: { 1 => 'Paras' },
  MAGIKARP: { 1 => 'Magikarp' },
  GYARADOS: { 1 => 'Magikarp' },
  MISDREAVUS: { 1 => 'Misdreavus' },
  MISMAGIUS: { 1 => 'Misdreavus' },
  SHROOMISH: { 1 => 'Shroomish' },
  BRELOOM: { 1 => 'Shroomish' },
  FEEBAS: { 1 => 'Feebas' },
  MILOTIC: { 1 => 'Feebas' },
  SNORUNT: { 1 => 'Snorunt' },
  GLALIE: { 1 => 'Snorunt' },
  FROSLASS: { 1 => 'Snorunt' },
  MUNNA: { 1 => 'Munna' },
  MUSHARNA: { 1 => 'Munna' },
  SIGILYPH: { 1 => 'Sigilyph' },
  LITWICK: { 1 => 'Litwick' },
  LAMPENT: { 1 => 'Litwick' },
  CHANDELURE: { 1 => 'Litwick' },
  BUDEW: { 1 => 'Budew' },
  ROSELIA: { 1 => 'Budew' },
  ROSERADE: { 1 => 'Budew' },
  BRONZOR: { 1 => 'Bronzor' },
  BRONZONG: { 1 => 'Bronzor' },
  SHELLOS: { 2 => 'AevShellos', 3 => 'AevShellos' },
  GASTRODON: { 2 => 'AevShellos', 3 => 'AevShellos' },
  TOXTRICITY: { 1 => 'Toxtricity' },
  JANGMOO: { 1 => 'Jangmoo' },
  HAKAMOO: { 1 => 'Jangmoo' },
  KOMMOO: { 1 => 'Jangmoo' },
  WIMPOD: { 1 => 'Wimpod' },
  GOLISOPOD: { 1 => 'Wimpod' },
  LARVESTA: { 1 => 'Larvesta' },
  VOLCARONA: { 1 => 'Larvesta' },
  SEWADDLE: { 1 => 'Sewaddle' },
  SWADLOON: { 1 => 'Sewaddle' },
  LEAVANNY: { 1 => 'Sewaddle' },
  MAREEP: { 1 => 'Mareep' },
  FLAAFFY: { 1 => 'Mareep' },
  AMPHAROS: { 1 => 'Mareep' },
  LAPRAS: { 1 => 'Lapras' }
}

REBORN_THEME_TEAMS = [
  { number: 1, trainer: 'Julia', name: 'Boss Rush', teamnumber: 10, field: :ELECTERRAIN, doubles: false },
  { number: 1, trainer: 'Julia', name: 'Boss Rush 2', teamnumber: 11, field: :ELECTERRAIN, doubles: false },
  { number: 1, trainer: 'Julia', name: 'Deal With It', teamnumber: 12, field: :WATERSURFACE, doubles: true },
  { number: 1, trainer: 'Julia', name: "Julia's Kitchen", teamnumber: 13, field: :MURKWATERSURFACE, doubles: false },
  { number: 1, trainer: 'Julia', name: 'Responsible Workplace Practices', teamnumber: 14, field: :FACTORY,
    doubles: true },
  { number: 1, trainer: 'Julia', name: 'Kaboom!', teamnumber: 15, field: :GLITCH, doubles: false },
  { number: 2, trainer: 'Florinia', name: 'Boss Rush', teamnumber: 10, field: :FOREST, doubles: false },
  { number: 2, trainer: 'Florinia', name: 'Boss Rush 2', teamnumber: 11, field: :FOREST, doubles: false },
  { number: 2, trainer: 'Florinia', name: 'Reconsideration', teamnumber: 12, field: :INVERSE, doubles: false },
  { number: 2, trainer: 'Florinia', name: 'Standard Environment', teamnumber: 13, field: :GRASSY, doubles: false },
  { number: 2, trainer: 'Florinia', name: 'Alpine Rose', teamnumber: 14, field: :MOUNTAIN, doubles: true },
  { number: 2, trainer: 'Florinia', name: 'Wetland Rose', teamnumber: 15, field: :SWAMP, doubles: false },
  { number: 2, trainer: 'Florinia', name: 'Performative Science', teamnumber: 16, field: :BIGTOP, doubles: false },
  { number: 3, trainer: 'Shelly', name: 'Boss Rush', teamnumber: 10, field: :FOREST, doubles: false },
  { number: 3, trainer: 'Shelly', name: 'Boss Rush 2', teamnumber: 11, field: :FOREST, doubles: false },
  { number: 3, trainer: 'Shelly', name: 'Stage Fright', teamnumber: 12, field: :BIGTOP, doubles: false },
  { number: 3, trainer: 'Shelly', name: 'Buggie Paddle', teamnumber: 13, field: :WATERSURFACE, doubles: false },
  { number: 3, trainer: 'Shelly', name: 'Miscommunication', teamnumber: 14, field: :INVERSE, doubles: false },
  { number: 3, trainer: 'Shelly', name: "Computational Science Isn't So Hard!", teamnumber: 15, field: :GLITCH,
    doubles: false },
  { number: 4, trainer: 'Shade', name: 'Boss Rush', teamnumber: 10, field: :DARKCRYSTALCAVERN, doubles: false },
  { number: 4, trainer: 'Shade', name: 'Boss Rush 2', teamnumber: 11, field: :DARKCRYSTALCAVERN, doubles: false },
  { number: 4, trainer: 'Shade', name: 'Midnight Meadow', teamnumber: 12, field: :GRASSY, doubles: false },
  { number: 4, trainer: 'Shade', name: 'Hexes and Heroism', teamnumber: 13, field: :STARLIGHT, doubles: false },
  { number: 5, trainer: 'Aya', name: 'Boss Rush', teamnumber: 10, field: :SWAMP, doubles: false },
  { number: 5, trainer: 'Aya', name: 'Boss Rush 2', teamnumber: 11, field: :WASTELAND, doubles: false },
  { number: 5, trainer: 'Aya', name: 'Acridity', teamnumber: 12, field: :MURKWATERSURFACE, doubles: false },
  { number: 5, trainer: 'Aya', name: 'Toxicity', teamnumber: 13, field: :CORROSIVE, doubles: false },
  { number: 6, trainer: 'Serra', name: 'Boss Rush', teamnumber: 10, field: :ICY, doubles: false },
  { number: 6, trainer: 'Serra', name: 'Boss Rush 2', teamnumber: 11, field: :INVERSE, doubles: true },
  { number: 6, trainer: 'Serra', name: 'Noitcelfer', teamnumber: 12, field: :INVERSE, doubles: false },
  { number: 6, trainer: 'Serra', name: 'Digital Imaging', teamnumber: 13, field: :GLITCH, doubles: false },
  { number: 7, trainer: 'Noel', name: 'Boss Rush', teamnumber: 10, field: :HOLY, doubles: false },
  { number: 7, trainer: 'Noel', name: 'Boss Rush 2', teamnumber: 11, field: :HOLY, doubles: false },
  { number: 7, trainer: 'Noel', name: 'Abnormal', teamnumber: 12, field: :INVERSE, doubles: false },
  { number: 7, trainer: 'Noel', name: 'Defaulted', teamnumber: 13, field: :GLITCH, doubles: false },
  { number: 7, trainer: 'Noel', name: 'Entrainment', teamnumber: 14, field: :INVERSE, doubles: true },
  { number: 7, trainer: 'Noel', name: 'Illustrated', teamnumber: 15, field: :RAINBOW, doubles: false },
  { number: 8, trainer: 'Radomus', name: 'Boss Rush', teamnumber: 10, field: :STARLIGHT, doubles: false },
  { number: 8, trainer: 'Radomus', name: 'Boss Rush 2', teamnumber: 11, field: :STARLIGHT, doubles: false },
  { number: 8, trainer: 'Radomus', name: 'Telepathic Timetables', teamnumber: 12, field: :PSYTERRAIN, doubles: false },
  { number: 8, trainer: 'Radomus', name: 'Black on Purple', teamnumber: 13, field: :PSYTERRAIN, doubles: true },
  { number: 8, trainer: 'Radomus', name: 'Stockfish Malfunction', teamnumber: 14, field: :GLITCH, doubles: false },
  { number: 8, trainer: 'Radomus', name: 'Celestial Enlightenment', teamnumber: 15, field: :ASHENBEACH,
    doubles: false },
  { number: 8, trainer: 'Radomus', name: 'Agnosticism', teamnumber: 16, field: :HOLY, doubles: false },
  { number: 9, trainer: 'Luna', name: 'Boss Rush', teamnumber: 10, field: :NEWWORLD, doubles: false },
  { number: 9, trainer: 'Luna', name: 'Boss Rush 2', teamnumber: 11, field: :NEWWORLD, doubles: false },
  { number: 9, trainer: 'Luna', name: 'Mermaid in the Deep', teamnumber: 12, field: :WATERSURFACE, doubles: false },
  { number: 9, trainer: 'Luna', name: 'Gothic Lolita', teamnumber: 13, field: :FAIRYTALE, doubles: false },
  { number: 10, trainer: 'Samson', name: 'Boss Rush', teamnumber: 10, field: :BIGTOP, doubles: false },
  { number: 10, trainer: 'Samson', name: 'Boss Rush 2', teamnumber: 11, field: :BIGTOP, doubles: false },
  { number: 10, trainer: 'Samson', name: 'Endorphins', teamnumber: 12, field: :ASHENBEACH, doubles: false },
  { number: 10, trainer: 'Samson', name: 'Grow Strong', teamnumber: 13, field: :FOREST, doubles: false },
  { number: 11, trainer: 'Charlotte', name: 'Boss Rush', teamnumber: 10, field: :BURNING, doubles: true },
  { number: 11, trainer: 'Charlotte', name: 'Boss Rush 2', teamnumber: 11, field: :SUPERHEATED, doubles: true },
  { number: 11, trainer: 'Charlotte', name: 'Fried Circuits', teamnumber: 12, field: :GLITCH, doubles: false },
  { number: 11, trainer: 'Charlotte', name: 'Fire Hazard', teamnumber: 13, field: :GRASSY, doubles: false },
  { number: 11, trainer: 'Charlotte', name: 'Like Mom & Pop', teamnumber: 14, field: :DRAGONSDEN, doubles: false },
  { number: 12, trainer: 'Terra', name: 'Boss Rush', teamnumber: 10, field: :DESERT, doubles: true },
  { number: 12, trainer: 'Terra', name: 'Boss Rush 2', teamnumber: 11, field: :DESERT, doubles: true },
  { number: 12, trainer: 'Terra', name: 'SEEDZ NUTZ', teamnumber: 12, field: :CORROSIVEMIST, doubles: false },
  { number: 12, trainer: 'Terra', name: 'cOARSE anD ROUGH', teamnumber: 13, field: :ASHENBEACH, doubles: false },
  { number: 12, trainer: 'Terra', name: 'gettin wet ;)', teamnumber: 14, field: :UNDERWATER, doubles: false },
  { number: 12, trainer: 'Terra', name: 'THE ENTIRE CIRCUS!!!!11!!!!1!!!', teamnumber: 15, field: :BIGTOP,
    doubles: false },
  { number: 13, trainer: 'Ciel', name: 'Boss Rush', teamnumber: 10, field: :MOUNTAIN, doubles: true },
  { number: 13, trainer: 'Ciel', name: 'Boss Rush 2', teamnumber: 11, field: :MOUNTAIN, doubles: true },
  { number: 13, trainer: 'Ciel', name: 'Above the Rabble', teamnumber: 12, field: :MURKWATERSURFACE, doubles: false },
  { number: 13, trainer: 'Ciel', name: 'New Horizons', teamnumber: 13, field: :NEWWORLD, doubles: false },
  { number: 13, trainer: 'Ciel', name: 'Beauty in Brutality', teamnumber: 14, field: :DRAGONSDEN, doubles: true },
  { number: 13, trainer: 'Ciel', name: 'Suspension of Disbelief', teamnumber: 15, field: :PSYTERRAIN, doubles: false },
  { number: 13, trainer: 'Ciel', name: 'Are We Human?', teamnumber: 16, field: :BIGTOP, doubles: true },
  { number: 14, trainer: 'Adrienn', name: 'Boss Rush', teamnumber: 10, field: :MISTY, doubles: false },
  { number: 14, trainer: 'Adrienn', name: 'Boss Rush 2', teamnumber: 11, field: :FAIRYTALE, doubles: true },
  { number: 14, trainer: 'Adrienn', name: 'Chronomancy', teamnumber: 12, field: :PSYTERRAIN, doubles: false },
  { number: 14, trainer: 'Adrienn', name: 'Machine Dreams', teamnumber: 13, field: :FACTORY, doubles: false },
  { number: 14, trainer: 'Adrienn', name: 'Happily Ever After', teamnumber: 14, field: :FAIRYTALE, doubles: false },
  { number: 14, trainer: 'Adrienn', name: 'Atop Olympus', teamnumber: 15, field: :MOUNTAIN, doubles: true },
  { number: 14, trainer: 'Adrienn', name: 'Miraculous', teamnumber: 16, field: :HOLY, doubles: false },
  { number: 15, trainer: 'Titania', name: 'Boss Rush', teamnumber: 10, field: :FAIRYTALE, doubles: false },
  { number: 15, trainer: 'Titania', name: 'Boss Rush 2', teamnumber: 11, field: :FAIRYTALE, doubles: false },
  { number: 15, trainer: 'Titania', name: 'Desert Blindness', teamnumber: 12, field: :DESERT, doubles: false },
  { number: 15, trainer: 'Titania', name: 'Legless Sea', teamnumber: 13, field: :MURKWATERSURFACE, doubles: false },
  { number: 15, trainer: 'Titania', name: 'Forty Nights of Fire', teamnumber: 14, field: :CORROSIVEMIST,
    doubles: true },
  { number: 15, trainer: 'Titania', name: 'Psychic Spindle', teamnumber: 15, field: :PSYTERRAIN, doubles: false },
  { number: 15, trainer: 'Titania', name: "The Witch's Hut", teamnumber: 16, field: :SWAMP, doubles: false },
  { number: 16, trainer: 'Amaria', name: 'Boss Rush', teamnumber: 10, field: :WATERSURFACE, doubles: false },
  { number: 16, trainer: 'Amaria', name: 'Boss Rush 2', teamnumber: 11, field: :UNDERWATER, doubles: false },
  { number: 16, trainer: 'Amaria', name: 'Contradictory Impulses', teamnumber: 12, field: :GLITCH, doubles: false },
  { number: 16, trainer: 'Amaria', name: 'Shadowy Anguish', teamnumber: 13, field: :SWAMP, doubles: false },
  { number: 16, trainer: 'Amaria', name: 'Inward Contemplation', teamnumber: 14, field: :ASHENBEACH, doubles: false },
  { number: 16, trainer: 'Amaria', name: 'The Tumult', teamnumber: 15, field: :PSYTERRAIN, doubles: false },
  { number: 17, trainer: 'Hardy', name: 'Boss Rush', teamnumber: 10, field: :ROCKY, doubles: true },
  { number: 17, trainer: 'Hardy', name: 'Boss Rush 2', teamnumber: 11, field: :ROCKY, doubles: true },
  { number: 17, trainer: 'Hardy', name: 'The Ocean', teamnumber: 12, field: :WATERSURFACE, doubles: false },
  { number: 17, trainer: 'Hardy', name: 'Rocky Mountain Way', teamnumber: 13, field: :MOUNTAIN, doubles: true },
  { number: 17, trainer: 'Hardy', name: 'Lucy in the Sky', teamnumber: 14, field: :CRYSTALCAVERN, doubles: false },
  { number: 17, trainer: 'Hardy', name: 'Bites the Dust', teamnumber: 15, field: :DESERT, doubles: true },
  { number: 18, trainer: 'Saphira', name: 'Boss Rush', teamnumber: 10, field: :DRAGONSDEN, doubles: false },
  { number: 18, trainer: 'Saphira', name: 'Boss Rush 2', teamnumber: 11, field: :DRAGONSDEN, doubles: false },
  { number: 18, trainer: 'Saphira', name: 'Naga', teamnumber: 12, field: :PSYTERRAIN, doubles: false },
  { number: 18, trainer: 'Saphira', name: 'Hydra', teamnumber: 13, field: :WATERSURFACE, doubles: false },
  { number: 18, trainer: 'Saphira', name: 'Wyrm', teamnumber: 14, field: :FAIRYTALE, doubles: false },
  { number: 18, trainer: 'Saphira', name: 'King', teamnumber: 15, field: :HOLY, doubles: false },
  { number: 19, trainer: 'Heather', name: 'Polar Peak Princess', teamnumber: 10, field: :SNOWYMOUNTAIN,
    doubles: false },
  { number: 19, trainer: 'Heather', name: 'Purple Poison Power', teamnumber: 11, field: :CORROSIVE, doubles: false },
  { number: 19, trainer: 'Heather', name: 'Dancing Dragon Danger', teamnumber: 12, field: :DRAGONSDEN, doubles: false },
  { number: 19, trainer: 'Heather', name: 'In Memoriam', teamnumber: 13, field: :NEWWORLD, doubles: true },
  { number: 20, trainer: 'Laura', name: 'Wisteria', teamnumber: 10, field: :FLOWERGARDEN1, doubles: true },
  { number: 20, trainer: 'Laura', name: 'Sakura', teamnumber: 11, field: :FAIRYTALE, doubles: false },
  { number: 20, trainer: 'Laura', name: 'Octopetala', teamnumber: 12, field: :STARLIGHT, doubles: false },
  { number: 21, trainer: 'Elias', name: 'False God', teamnumber: 10, field: :HOLY, doubles: false },
  { number: 21, trainer: 'Elias', name: 'Natural Consequences', teamnumber: 11, field: :HOLY, doubles: false },
  { number: 21, trainer: 'Elias', name: 'Dabbling in Distortion', teamnumber: 12, field: :INVERSE, doubles: false },
  { number: 21, trainer: 'Elias', name: "Who's Grandmaster Now?", teamnumber: 13, field: :CHESS, doubles: true },
  { number: 22, trainer: 'Anna', name: 'Seeing Stars', teamnumber: 10, field: :STARLIGHT, doubles: true },
  { number: 22, trainer: 'Anna', name: 'Millennial Puzzles', teamnumber: 11, field: :CHESS, doubles: false },
  { number: 22, trainer: 'Anna', name: 'Unforeseen Futurity', teamnumber: 12, field: :NEWWORLD, doubles: false },
  { number: 23, trainer: 'Arclight', name: 'Make Some Noise', teamnumber: 10, field: :BIGTOP, doubles: true },
  { number: 23, trainer: 'Arclight', name: 'Sole Sight', teamnumber: 11, field: :DARKCRYSTALCAVERN, doubles: false },
  { number: 23, trainer: 'Arclight', name: 'The Conductor', teamnumber: 12, field: :WATERSURFACE, doubles: false },
  { number: 23, trainer: 'Arclight', name: 'Night Club', teamnumber: 13, field: :SHORTCIRCUIT, doubles: false },
  { number: 24, trainer: 'Cain', name: 'Pretty Boy', teamnumber: 10, field: :RAINBOW, doubles: false },
  { number: 24, trainer: 'Cain', name: 'Sing for Me!', teamnumber: 11, field: :BIGTOP, doubles: false },
  { number: 24, trainer: 'Cain', name: 'Subverted Expectations', teamnumber: 12, field: :INVERSE, doubles: false },
  { number: 25, trainer: 'Fern', name: 'Contrarian', teamnumber: 10, field: :SWAMP, doubles: false },
  { number: 25, trainer: 'Fern', name: "Hero's Journey", teamnumber: 11, field: :FAIRYTALE, doubles: false },
  { number: 25, trainer: 'Fern', name: 'Come on and Smile!', teamnumber: 12, field: :FOREST, doubles: false },
  { number: 26, trainer: 'Victoria', name: 'Fallacy of Justice', teamnumber: 10, field: :FAIRYTALE, doubles: false },
  { number: 26, trainer: 'Victoria', name: 'Black and White', teamnumber: 11, field: :CHESS, doubles: false },
  { number: 26, trainer: 'Victoria', name: 'A Change of Pace', teamnumber: 12, field: :BIGTOP, doubles: false },
  { number: 27, trainer: 'Bennett', name: 'A Game Of Intellect', teamnumber: 10, field: :CHESS, doubles: false },
  { number: 27, trainer: 'Bennett', name: 'Predisposition to Showmanship', teamnumber: 11, field: :BIGTOP,
    doubles: false },
  { number: 27, trainer: 'Bennett', name: 'Self-Reflection', teamnumber: 12, field: :MIRROR, doubles: false },
  { number: 28, trainer: 'Taka', name: "Stack o' Taka", teamnumber: 10, field: :SHORTCIRCUIT, doubles: true },
  { number: 28, trainer: 'Taka', name: 'Light My Fire', teamnumber: 11, field: :BURNING, doubles: true },
  { number: 28, trainer: 'Taka', name: 'The View From Up Here', teamnumber: 12, field: :MOUNTAIN, doubles: true },
  { number: 28, trainer: 'Taka', name: 'Legacy', teamnumber: 13, field: :DRAGONSDEN, doubles: true },
  { number: 29, trainer: 'Blake', name: 'Console Defrag', teamnumber: 10, field: :GLITCH, doubles: true },
  { number: 29, trainer: 'Blake', name: 'Nice Stall Bro', teamnumber: 11, field: :INVERSE, doubles: false },
  { number: 29, trainer: 'Blake', name: "Can't Touch This", teamnumber: 12, field: :MIRROR, doubles: false },
  { number: 30, trainer: 'Cal', name: 'Across Coals', teamnumber: 10, field: :ASHENBEACH, doubles: false },
  { number: 30, trainer: 'Cal', name: 'Boiling Blood', teamnumber: 11, field: :DRAGONSDEN, doubles: false },
  { number: 30, trainer: 'Cal', name: 'Burning Pride', teamnumber: 12, field: :RAINBOW, doubles: false },
  { number: 31, trainer: 'Eve', name: 'Technical Expertise', teamnumber: 10, field: :FACTORY, doubles: false },
  { number: 31, trainer: 'Eve', name: 'Ultra-Precise Analysis', teamnumber: 11, field: :GLITCH, doubles: false },
  { number: 31, trainer: 'Eve', name: 'Intermediation', teamnumber: 12, field: :CHESS, doubles: false },
  { number: 32, trainer: 'Lumi', name: 'Teamwork!', teamnumber: 10, field: :INVERSE, doubles: false },
  { number: 32, trainer: 'Lumi', name: 'Ametrine Blues', teamnumber: 11, field: :WATERSURFACE, doubles: false },
  { number: 32, trainer: 'Lumi', name: 'Bedtime Stories', teamnumber: 12, field: :FAIRYTALE, doubles: false },
  { number: 33, trainer: 'Zero', name: 'Zed', teamnumber: 10, field: :ELECTERRAIN, doubles: false },
  { number: 33, trainer: 'Zero', name: 'Zero Gravity', teamnumber: 11, field: :NEWWORLD, doubles: false },
  { number: 33, trainer: 'Zero', name: 'Reminiscence', teamnumber: 12, field: :INVERSE, doubles: false },
  { number: 34, trainer: 'Ace of All Suits', name: 'Myth and Mystery', teamnumber: 10, field: :FAIRYTALE,
    doubles: false },
  { number: 34, trainer: 'Ace of All Suits', name: 'Eyes of Fire', teamnumber: 11, field: :BURNING, doubles: false },
  { number: 34, trainer: 'Ace of All Suits', name: 'Half-Tossed Coin', teamnumber: 12, field: :DARKCRYSTALCAVERN,
    doubles: false },
  { number: 34, trainer: 'Ace of All Suits', name: 'Technological Trickster', teamnumber: 13, field: :GLITCH,
    doubles: false },
  { number: 34, trainer: 'Ace of All Suits', name: 'Fashion Forward', teamnumber: 14, field: :CHESS, doubles: true },
  { number: 34, trainer: 'Ace of All Suits', name: 'Family', teamnumber: 15, field: :HOLY, doubles: false },
  { number: 35, trainer: 'Lin', name: 'puppies!!!', teamnumber: 10, field: :HOLY, doubles: false },
  { number: 35, trainer: 'Lin', name: 'stop flinching urself', teamnumber: 11, field: :RAINBOW, doubles: true },
  { number: 35, trainer: 'Lin', name: 'old habits die hard', teamnumber: 12, field: :NEWWORLD, doubles: false }
]

REBORN_BT_SINGLES = [
  [:BEE, 'Bee', 1000, :CORROSIVE],
  [:LAHVER, 'Biggles', 1000, :WASTELAND],
  [:CUEBALL, 'Santiago', 1000, :STARLIGHT],
  [:SEER, 'Danielle', 1000, :MIRROR],
  [:SANDY, 'Sandy', 1000, :SWAMP],
  [:ASTER, 'Aster', 1000, :DESERT],
  [:SEACREST, 'Seacrest', 1000, :UNDERWATER],
  [:MEGANIUM, 'Meganium', 1000, :INVERSE],
  [:BRELOOM, 'CL:4R1-C3', 1000, :FACTORY],
  [:CORINROUGE, 'Corin-Rouge', 1000, :FAIRYTALE],
  [:INDRA, 'Indra', 1000, :MIRROR],
  [:INDRA, 'Indra', 1001, :RAINBOW],
  [:INDRA, 'Indra', 1002, :RAINBOW],
  [:Archer, 'Archer', 1000, :SWAMP],
  [:Maxwell, 'Maxwell', 1000, :GRASSY],
  [:RINGMASTER, 'Alistasia', 1000, :BIGTOP],
  [:HARRIDAN, 'Craudburry', 1000, :HOLY],
  [:PIKANYU, 'Nyu', 1000, :ELECTERRAIN],
  [:SMEARGLE, 'Smeargletail', 1000, :DESERT],
  [:ZEL3, 'Zero', 1000, :NEWWORLD],
  [:ZEL3, 'Zero', 1001, :NEWWORLD],
  [:CASS, 'Cass', 1000, :NEWWORLD],
  [:CASS, 'Cass', 1001, :HOLY],
  [:MASTERMIND, 'Eustace', 1000, :NEWWORLD],
  [:MCKREZZY, 'McKrezzy', 1000, :CAVE],
  [:MARCELLO, 'Marcello', 1000, :GLITCH],
  [:KANAYA, 'Kanaya', 1000, :DESERT],
  [:BUFF, 'Bill', 1000, :INVERSE],
  [:MISSDIRECTION, 'Direction', 1000, :GLITCH],
  [:MISSDIRECTION, 'Direction', 1001, :PSYTERRAIN],
  [:SIMON, 'Simon', 1000, :FOREST],
  [:RANDALL, 'Randall', 1000, :RANDOM],
  [:EUROPA, 'Europa', 1000, :CORROSIVEMIST],
  [:MAEL, 'Maelstrom', 1000, :GRASSY],
  [:MURMINA, 'Murmina', 1000, :BIGTOP],
  [:NWOrderly, 'John', 1000, :STARLIGHT],
  [:CHIEF, 'Eastman', 1000, :STARLIGHT],
  [:CRIM, 'Crim', 1000, :FAIRYTALE],
  [:POACHERB, 'Breslin', 1000, :STARLIGHT]
]

REBORN_BT_DOUBLES = [
  [:BEE, 'Bee', 2000, :CORROSIVE],
  [:LAHVER, 'Biggles', 2000, :WASTELAND],
  [:CUEBALL, 'Santiago', 2000, :STARLIGHT],
  [:SEER, 'Danielle', 2000, :MIRROR],
  [:SANDY, 'Sandy', 2000, :SWAMP],
  [:ASTER, 'Aster', 2000, :DESERT],
  [:SEACREST, 'Seacrest', 2000, :UNDERWATER],
  [:MEGANIUM, 'Meganium', 2000, :INVERSE],
  [:BRELOOM, 'CL:4R1-C3', 2000, :FACTORY],
  [:CORINROUGE, 'Corin-Rouge', 2000, :FAIRYTALE],
  [:INDRA, 'Indra', 2000, :MIRROR],
  [:INDRA, 'Indra', 2001, :RAINBOW],
  [:INDRA, 'Indra', 2002, :RAINBOW],
  [:Archer, 'Archer', 2000, :SWAMP],
  [:Maxwell, 'Maxwell', 2000, :GRASSY],
  [:RINGMASTER, 'Alistasia', 2000, :BIGTOP],
  [:HARRIDAN, 'Craudburry', 2000, :HOLY],
  [:PIKANYU, 'Nyu', 2000, :ELECTERRAIN],
  [:ZEL3, 'Zero', 2000, :NEWWORLD],
  [:ZEL3, 'Zero', 2001, :NEWWORLD],
  [:MASTERMIND, 'Eustace', 2000, :NEWWORLD],
  [:MCKREZZY, 'McKrezzy', 2000, :CAVE],
  [:KANAYA, 'Kanaya', 2000, :DESERT],
  [:BUFF, 'Bill', 2000, :INVERSE],
  [:MISSDIRECTION, 'Direction', 2000, :GLITCH],
  [:MISSDIRECTION, 'Direction', 2001, :PSYTERRAIN],
  [:SIMON, 'Simon', 2000, :FOREST],
  [:RANDALL, 'Randall', 2000, :RANDOM],
  [:EUROPA, 'Europa', 2000, :CORROSIVEMIST],
  [:MAEL, 'Maelstrom', 2000, :GRASSY],
  [:MURMINA, 'Murmina', 2000, :BIGTOP],
  [:NWOrderly, 'John', 2000, :STARLIGHT],
  [:CHIEF, 'Eastman', 2000, :STARLIGHT],
  [:POACHERB, 'Breslin', 2000, :STARLIGHT]
]

PICKUP_ODDS = [30, 10, 10, 10, 10, 10, 10, 4, 4, 1, 1]

module PBStats
  ATTACK = "Atk"
  DEFENSE = "Def"
  SPATK = "SpA"
  SPDEF = "SpD"
  SPEED = "Spe"
  EVASION = "Eva"
  ACCURACY = "Acc"
end

def get_game_contents_dir(game)
  File.join(ROOT_DIR, 'src', '_raw', game)
end

def load_chapter_md(game, chapter_type, chapter_num)
  game_contents_dir = get_game_contents_dir(game)
  path = case chapter_type
    when "appendices" then File.join(game_contents_dir, "#{chapter_type}.md")
    else File.join(game_contents_dir, "#{chapter_type}_ep_#{chapter_num.to_s.rjust(2, '0')}.md")
  end
  return File.read(path) if File.exist?(path)
end

def set_to_range_string(integers_set)
  ranges = []

  integers_set.sort.each do |num|
    if ranges.empty? || ranges.last.last != num - 1
      ranges << [num]
    else
      ranges.last << num
    end
  end

  ranges.map { |range| range.size > 1 ? "#{range.first}-#{range.last}" : range.first.to_s }.join(', ')
end

def load_item_hash(game, scripts_dir)
  data = File.read(File.join(scripts_dir, game.capitalize, 'itemtext.rb'))
  eval(data)
end

def load_enc_hash(game, scripts_dir)
  data = File.read(File.join(scripts_dir, game.capitalize, 'enctext.rb'))
  eval(data)
end

def load_trainer_hash(game, scripts_dir)
  data = File.read(File.join(scripts_dir, game.capitalize, 'trainertext.rb'))
  base_hash = eval(data)
  ret = {}
  base_hash.each do |trainer_hash|
    ret[trainer_hash[:teamid]] = trainer_hash
  end
  ret
end

def load_boss_hash(game, scripts_dir)
  return {} if game == "reborn"
  data = File.read(File.join(scripts_dir, game.capitalize, 'BossInfo.rb'))
  return eval(data)
end

def load_trainer_type_hash(game, scripts_dir)
  data = File.read(File.join(scripts_dir, game.capitalize, 'ttypetext.rb'))
  eval(data)
end

def load_type_hash(game, scripts_dir)
  data = File.read(File.join(scripts_dir, game.capitalize, 'typetext.rb'))
  eval(data)
end

def load_ability_hash(game, scripts_dir)
  data = File.read(File.join(scripts_dir, game.capitalize, 'abiltext.rb'))
  eval(data)
end

def load_move_hash(game, scripts_dir)
  data = File.read(File.join(scripts_dir, game.capitalize, 'movetext.rb'))
  eval(data)
end

def load_pokemon_hash(game, scripts_dir)
  data = File.read(File.join(scripts_dir, game.capitalize, 'montext.rb'))
  eval(data)
end

def load_field_hash(game, scripts_dir)
  data = File.read(File.join(scripts_dir, game.capitalize, 'fieldtext.rb'))
  eval(data)
end

def load_mining_hash(game = nil, scripts_dir)
  lines = if game && game.capitalize == 'Rejuv'
            File.read(File.join(scripts_dir, game.capitalize, 'RejuvCustomScripts.rb'))
          else
            File.read(File.join(scripts_dir, 'MinigameMining.rb'))
          end

  item_hash = Hash.new(0)

  lines.each_line do |line|
    next unless line.match(/\[:\w+,\s*\d+,\s*\d+,\s*\d+,\s*\d+,\s*\d+,\s*\[[01\s,]+\]/)

    item_symbol = line.match(/(\w+)/)[1].to_sym
    probability = line.match(/(\d+)/)[0].to_i

    item_hash[item_symbol] += probability
  end

  total_prob = item_hash.values.sum.to_f
  item_hash.transform_values! { |prob| (prob / total_prob * 100).round(2) }

  grouped_hash = item_hash.map do |sym, prob|
                   [sym, prob]
                 end.group_by(&:last).transform_values { |elements| elements.map(&:first) }

  grouped_hash.map { |prob, l| [prob, l] }.sort_by { |a| a[0].to_f }.reverse
end

def load_maps_hash(game, scripts_dir)
  ret = {}
  data = File.read(File.join(scripts_dir, game.capitalize, 'metatext.rb'))
  lines = data.split("\n")

  lines.each_with_index do |line, index|
    match = line.match(/^\s*(\d{1,3})\s*=>\s*{/)
    next unless match

    key = match[1].to_i
    comment_line = lines[index - 1]
    if comment_line.match(/#(.+)/) == nil
      ret[key] = "NAME MISSING"
    else
      name = comment_line.match(/#(.+)/)[1].strip
      ret[key] = name
    end
  end
  ret
end

def load_pickup_data(game, scripts_dir)
  file_contents = File.read(File.join(scripts_dir, game.capitalize, 'SystemConstants.rb'))

  normal_pickup_match = file_contents.match(/PickupNormal\s*=\s*\[(.*?)\]/m)
  rare_pickup_match = file_contents.match(/PickupRare\s*=\s*\[(.*?)\]/m)

  normal_pickup = normal_pickup_match[1].split(',').map { |item| item.strip.tr(':', '').to_sym }
  rare_pickup = rare_pickup_match[1].split(',').map { |item| item.strip.tr(':', '').to_sym }

  item_data = {}
  # Sample: :GREATBALL => {30 => [11, 20], 10 => [1, 10]}

  (0..9).each do |i|
    items = normal_pickup[i, 9] + rare_pickup[i, 2]

    min_level, max_level = i * 10 + 1, (i + 1) * 10

    items.each_with_index do |item, idx|
      odds = PICKUP_ODDS[idx]

      item_data[item] ||= {}

      if item_data[item][odds]
        existing_range = item_data[item][odds]
        item_data[item][odds] = [existing_range[0], max_level]  # Update to new max level
      else
        item_data[item][odds] = [min_level, max_level]
      end
    end
  end

  item_data.map { |item, odds| [item, odds.sort.reverse] }
end

def hp_str(move, hptype)
  return '' unless hptype
  return '' unless move == 'Hidden Power'

  " (#{hptype.to_s.capitalize!})"
end

def get_iv_str(ivs)
  return 'IVs: All 10' if !ivs
  return ivs == 32 ? 'IVs: All 31 (0 Spe)' : "IVs: All #{ivs}" if ivs.class == Integer
  return "IVs: All #{ivs[0]}" if (ivs && ivs.uniq.length == 1)
  return 'IVs: ' + ivs.zip(EV_ARRAY).reject do |iv, _|
    iv.zero?
  end.map { |iv, position| "#{iv} #{position}" }.join(', ')
end

def get_ev_str(evs, level=0)
  return "EVs: All #{[85, level * 3 / 2].min}" if !evs
  return "EVs: All #{evs[0]}" if (evs && evs.uniq.length == 1)
  return 'EVs: ' + evs.zip(EV_ARRAY).reject do |ev, _|
                ev.zero?
              end.map { |ev, position| "#{ev} #{position}" }.join(', ')
end

def is_custom_form(form_key)
  return false if !form_key
  form_frags = ["pulse", "rift", "aevian form", "bot", 
               "purple", "crystal", "mismageon", "meech",
               "dev", "crescent", "solrock", "lunatone", 
               "west aevian form", "east aevian form", "tuff puff",
               "angel of death", "dark gardevoir", "fallen angel",
               "amalgamation", "goomink", "kawopudunga", "coffee gregus",
               "hand of", "nightmare", "nanodrive", "guardian", "tazer",
               "karma beast"]
  form_frags.any? { |key| form_key.downcase.include?(key) }
end

def load_raid_den_hash(game, scripts_dir)
  return {} if game == "reborn"
  data = File.read(File.join(scripts_dir, game.capitalize, 'RaidDens.rb'))

  mon_info = {}
  dens = {}
  current_den = nil
  current_rarity = nil
  current_badge = nil
  current_pokemon = nil

  found_encounter_block = false

  badge_levels = {
    4 => 35,
    8 => 50,
    12 => 65,
    16 => 80,
    18 => 95
  }


  data.each_line do |line|
    # Check if we are in the encounterTable function
    if line.include?("encounterTable")
      found_encounter_block = true
      next
    end

    if !found_encounter_block
      # Processing denEncounters function

      # Match Pokémon definitions
      if line =~ /:\s*(?<pokemon>\w+)\s*=>\s*{/  # Ensure to match the opening brace
        current_pokemon = $~[:pokemon].to_sym
        mon_info[current_pokemon] ||= {}  # Initialize a new hash for this Pokémon

      elsif current_pokemon && line =~ /:(?<att>\w+)\s*=>\s*(?<values>.*?)(?:,\n|\n)/m # Only process attributes if a Pokémon has been defined
        att_name = $~[:att].to_sym
        values = eval($~[:values].strip)

        # Assign the attribute to the current Pokémon's hash
        mon_info[current_pokemon][att_name] = values
      end

    elsif found_encounter_block
      # Processing encounterTable function

      # Match den definitions
      break if line =~ /when "Beldum"/ 
      if line =~ /when\s+"(?<den>Den\d+)(Rare)?"/
        current_den = $~[:den]
        current_rarity = line.include?("Rare") ? :rare : :common
        dens[current_den] ||= { common: {}, rare: {} }
      end

      # Match game switch lines
      if line =~ /\$game_switches\[:Gym_(\d+)\]/
        current_badge = $1.to_i
        dens[current_den][current_rarity][current_badge] ||= {}
      end

      # Match encounter lines
      if line =~ /:(?<pokemon>\w+)\s*=>\s*{/
        current_pokemon = $~[:pokemon].to_sym
        dens[current_den][current_rarity][current_badge][current_pokemon] ||= mon_info[current_pokemon]
        dens[current_den][current_rarity][current_badge][current_pokemon][:level] = badge_levels[current_badge]
        if current_pokemon == :BELDUM
          dens[current_den][current_rarity][current_badge][current_pokemon][:level] = 20
        end
      end

      if line =~ /:weight => (?<weight>.*)\n/
        dens[current_den][current_rarity][current_badge][current_pokemon][:weight] = eval($~[:weight]) 
      end
    end
  end

  dens.each do |den, rarities|
    rarities.each do |rarity, badges|
      badges.each do |badge, pokemons|
        total_weight = pokemons.values.map { |p| p[:weight] || 0 }.sum

        pokemons.each do |pokemon, attributes|
          if total_weight > 0
            # Calculate odds as a percentage and format to 2 decimal places
            attributes[:odds] = ((attributes[:weight] / total_weight.to_f) * 100).round(2)
          else
            attributes[:odds] = 0.0  # Handle case where total_weight is zero
          end
        end
      end
    end
  end
  dens
end


class EncounterMapWrapper
  def initialize(game, scripts_dir)
    @data = {}
    parse_file(game, scripts_dir)

    @encounterMaps = ENCOUNTER_MAPS
  end

  def get_enc_maps(pokemon_symbol)
    return {} unless @encounterMaps
    form_data = @encounterMaps[pokemon_symbol]
    return {} unless form_data

    result = {}
    form_data.each do |form_number, mon_name|
      @data[mon_name].each { |num| result[num] = form_number } unless @data[mon_name] == nil
    end
    result
  end

  private

  def parse_file(game, scripts_dir)
    file_contents = File.read(File.join(scripts_dir, game.capitalize, 'SystemConstants.rb'))
    relevant_contents = file_contents.scan(/# Evos first(.*?)# \* Constants for maps to reflect sprites on/m)

    relevant_contents[0][0].scan(/(\w+)\s*=\s*\[([0-9\s,]*)\]/) do |pokemon_name, pokemon_numbers|
      process_assignment(pokemon_name.strip, pokemon_numbers)
    end
  end

  def process_assignment(pokemon_name, pokemon_numbers)
    numbers_array = pokemon_numbers.split(',').map(&:strip).map(&:to_i)
    @data[pokemon_name] = numbers_array
  end

  def parse_map_numbers(pokemon_numbers)
    pokemon_numbers.scan(/\d+/).map(&:to_i)
  end
end

main if __FILE__ == $PROGRAM_NAME
