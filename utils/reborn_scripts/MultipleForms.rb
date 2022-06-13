FormCopy = [
	[PBSpecies::FLABEBE,PBSpecies::FLOETTE],
	[PBSpecies::FLABEBE,PBSpecies::FLORGES],
	[PBSpecies::SHELLOS,PBSpecies::GASTRODON],
	[PBSpecies::DEERLING,PBSpecies::SAWSBUCK]
]
#this is the hash that will become the full multforms hash
PokemonForms = {

PBSpecies::UNOWN => {
	:OnCreation => proc{rand(28)}
},

PBSpecies::FLABEBE => {
	:OnCreation => proc{rand(5)}
},

PBSpecies::CASTFORM => {
	:FormName => {
		1 => "Sunny Form",
		2 => "Rainy Form",
		3 => "Snowy Form"
	},
	"Sunny Form" => {
		:Type1 => PBTypes::FIRE,
		:Type2 => PBTypes::FIRE
	},
	"Rainy Form" => {
		:Type1 => PBTypes::WATER,
		:Type2 => PBTypes::WATER
	},
	"Snowy Form" => {
		:Type1 => PBTypes::ICE,
		:Type2 => PBTypes::ICE
	}
},

PBSpecies::DEOXYS => {
	:FormName => {
		1 => "Attack Form",
		2 => "Defense Form",
		3 => "Speed Form"
	},

	"Attack Form" => {
		:BaseStats => [50,180,20,150,180,20],
		:EVs => [0,2,0,0,1,0],
		:Movelist => [[1,PBMoves::LEER],[1,PBMoves::WRAP],[7,PBMoves::NIGHTSHADE],[13,PBMoves::TELEPORT],
		[19,PBMoves::TAUNT],[25,PBMoves::PURSUIT],[31,PBMoves::PSYCHIC],[37,PBMoves::SUPERPOWER],
		[43,PBMoves::PSYCHOSHIFT],[49,PBMoves::ZENHEADBUTT],[55,PBMoves::COSMICPOWER],
		[61,PBMoves::ZAPCANNON],[67,PBMoves::PSYCHOBOOST],[73,PBMoves::HYPERBEAM]],
	},

	"Defense Form" => {
		:BaseStats => [50, 70,160, 90, 70,160],
		:EVs => [0,0,2,0,0,1],
		:Movelist => [[1,PBMoves::LEER],[1,PBMoves::WRAP],[7,PBMoves::NIGHTSHADE],[13,PBMoves::TELEPORT],
		[19,PBMoves::KNOCKOFF],[25,PBMoves::SPIKES],[31,PBMoves::PSYCHIC],[37,PBMoves::SNATCH],
		[43,PBMoves::PSYCHOSHIFT],[49,PBMoves::ZENHEADBUTT],[55,PBMoves::IRONDEFENSE],
		[55,PBMoves::AMNESIA],[61,PBMoves::RECOVER],[67,PBMoves::PSYCHOBOOST],
		[73,PBMoves::COUNTER],[73,PBMoves::MIRRORCOAT]],
	},

	"Speed Form" => {
		:BaseStats => [50, 95, 90,180, 95, 90],
		:EVs => [0,0,0,3,0,0],
		:Movelist => [[1,PBMoves::LEER],[1,PBMoves::WRAP],[7,PBMoves::NIGHTSHADE],[13,PBMoves::DOUBLETEAM],
		[19,PBMoves::KNOCKOFF],[25,PBMoves::PURSUIT],[31,PBMoves::PSYCHIC],[37,PBMoves::SWIFT],
		[43,PBMoves::PSYCHOSHIFT],[49,PBMoves::ZENHEADBUTT],[55,PBMoves::AGILITY],
		[61,PBMoves::RECOVER],[67,PBMoves::PSYCHOBOOST],[73,PBMoves::EXTREMESPEED]],
	}
},

PBSpecies::BURMY => {
	:FormName => {
		1 => "Sandy Cloak",
		2 => "Trash Cloak"
	},
	:OnCreation => proc{
		begin #horribly stupid section to make the battle stress test work
		case $fefieldeffect
			when 1,5,6,10,11,17,18,19,24,26,29,30,35,36,37
				next 2 # Trash Cloak
			when 2,3,7,8,9,15,21,22,31,33,34
				next 0 # Plant Cloak
			when 4,12,13,14,16,20,23,25,27,28,32
				next 1 # Sandy CloaK
		end
		env=pbGetEnvironment()
		if env==PBEnvironment::Sand || env==PBEnvironment::Rock || env==PBEnvironment::Cave
			next 1 # Sandy Cloak
		elsif !pbGetMetadata($game_map.map_id,MetadataOutdoor)
			next 2 # Trash Cloak
		else
			next 0 # Plant Cloak
		end
		rescue
			next 0
		end
	}
},

PBSpecies::WORMADAM => {
	:FormName => {
		0 => "Plant Cloak",
		1 => "Sandy Cloak",
		2 => "Trash Cloak"
	},
	:OnCreation => proc{
		begin #horribly stupid section to make the battle stress test work
		case $fefieldeffect
			when 1,5,6,10,11,17,18,19,24,26,29,30,35,36,37
				next 2 # Trash Cloak
			when 2,3,7,8,9,15,21,22,31,33,34
				next 0 # Plant Cloak
			when 4,12,13,14,16,20,23,25,27,28,32
				next 1 # Sandy CloaK
		end
		env=pbGetEnvironment()
		if env==PBEnvironment::Sand || env==PBEnvironment::Rock || env==PBEnvironment::Cave
			next 1 # Sandy Cloak
		elsif !pbGetMetadata($game_map.map_id,MetadataOutdoor)
			next 2 # Trash Cloak
		else
			next 0 # Plant Cloak
		end
		rescue
			next 0
		end
	},

	"Sandy Cloak" => {
		:BaseStats => [60,79,105,36,59,85],
		:EVs => [0,0,2,0,0,0],
		:Type2 => PBTypes::GROUND,
		:Movelist => [[0,PBMoves::QUIVERDANCE],[1,PBMoves::SUCKERPUNCH],
		[1,PBMoves::TACKLE],[1,PBMoves::PROTECT],[1,PBMoves::BUGBITE],
		[10,PBMoves::PROTECT],[15,PBMoves::BUGBITE],[20,PBMoves::HIDDENPOWER],
		[23,PBMoves::CONFUSION],[26,PBMoves::ROCKBLAST],[29,PBMoves::HARDEN],[32,PBMoves::PSYBEAM],
		[35,PBMoves::CAPTIVATE],[38,PBMoves::FLAIL],[41,PBMoves::ATTRACT],[44,PBMoves::PSYCHIC],
		[47,PBMoves::FISSURE],[50,PBMoves::BUGBUZZ]],
	},

	"Trash Cloak" => {
		:BaseStats => [60,69,95,36,69,95],
		:EVs => [0,0,1,0,0,1],
		:Type2 => PBTypes::STEEL,
		:Movelist => [[0,PBMoves::QUIVERDANCE],[1,PBMoves::METALBURST],[1,PBMoves::SUCKERPUNCH],
		[1,PBMoves::TACKLE],[1,PBMoves::PROTECT],[1,PBMoves::BUGBITE],[10,PBMoves::PROTECT],
		[15,PBMoves::BUGBITE],[20,PBMoves::HIDDENPOWER],[23,PBMoves::CONFUSION],[26,PBMoves::MIRRORSHOT],
		[29,PBMoves::METALSOUND],[32,PBMoves::PSYBEAM],[35,PBMoves::CAPTIVATE],[38,PBMoves::FLAIL],
		[41,PBMoves::ATTRACT],[44,PBMoves::PSYCHIC],[47,PBMoves::IRONHEAD],[50,PBMoves::BUGBUZZ]],
	}
},

PBSpecies::SHELLOS => {
	:OnCreation => proc{
		maps=[206,513,519,522,526,528,530,536,538,547,553,555,556,558,562,563,565,566,567,569,574,585,586,603,604,605,608,610]
		# Map IDs for second form
		if $game_map && maps.include?($game_map.map_id)
			next 1
		else
			next 0
		end
	}
},

PBSpecies::ROTOM => {
	:FormName => {
		1 => "Heat",
		2 => "Wash",
		3 => "Frost",
		4 => "Fan",
		5 => "Mow"
	},

	"Heat" => {
		:Type2 => PBTypes::FIRE,
		:BaseStats => [50,65,107,86,105,107]
	},
	"Wash" => {
		:Type2 => PBTypes::WATER,
		:BaseStats => [50,65,107,86,105,107]
	},
	"Frost" => {
		:Type2 => PBTypes::ICE,
		:BaseStats => [50,65,107,86,105,107]
	},
	"Fan" => {
		:Type2 => PBTypes::FLYING,
		:BaseStats => [50,65,107,86,105,107]
	},
	"Mow" => {
		:Type2 => PBTypes::GRASS,
		:BaseStats => [50,65,107,86,105,107]
	}
},

PBSpecies::GIRATINA => {
	:FormName => {
		0 => "Altered",
		1 => "Origin"
	},

	"Origin" => {
		:BaseStats => [150,120,100,90,120,100],
		:Ability => PBAbilities::LEVITATE,
		:Height => 69,
		:Weight => 6500
	}
},

PBSpecies::SHAYMIN => {
	:FormName => {1 => "Sky"},

	"Sky" => {
		:BaseStats => [100,103,75,127,120,75],
		:EVs => [0,0,0,3,0,0],
		:Type2 => PBTypes::FLYING,
		:Ability => PBAbilities::SERENEGRACE,
		:Movelist => [[1,PBMoves::GROWTH],[10,PBMoves::MAGICALLEAF],[19,PBMoves::LEECHSEED],[28,PBMoves::QUICKATTACK],
		[37,PBMoves::SWEETSCENT],[46,PBMoves::NATURALGIFT],[55,PBMoves::WORRYSEED],[64,PBMoves::AIRSLASH],
		[73,PBMoves::ENERGYBALL],[82,PBMoves::SWEETKISS],[91,PBMoves::LEAFSTORM],[100,PBMoves::SEEDFLARE]],
		:Height => 04,
		:Weight => 52
	}

},

PBSpecies::BASCULIN => {
	:OnCreation => proc{rand(2)},
	:FormName => {1 => "Blue-Striped"},

	"Blue-Striped" => {
		:Ability => [PBAbilities::ROCKHEAD,PBAbilities::ADAPTABILITY,PBAbilities::MOLDBREAKER],
		:WildHoldItems => [0,PBItems::DEEPSEASCALE,0]
	}

},

PBSpecies::DARMANITAN => {
	:FormName => {
		1 => "Zen",
		2 => "Galar",
		3 => "Galar Zen"
	},

	:OnCreation => proc{
		maps=[]
		# Map IDs for Galarian form
		if $game_map && maps.include?($game_map.map_id)
			next 2
		else
			next 0
		end
	},

	"Zen" => {
		:DexEntry => "When wounded, it stops moving. It goes as still as stone to meditate, sharpening its mind and spirit.",
		:BaseStats => [105,30,105,55,140,105],
		:EVs => [0,0,0,0,2,0],
		:Type2 => PBTypes::PSYCHIC
	},

	"Galar" => {
		:DexEntry => "Though it has a gentle disposition, it's also very strong. It will quickly freeze the snowball on its head before going for a headbutt.",
		:Type1 => PBTypes::ICE,
		:Type2 => PBTypes::ICE,
		:Ability => [PBAbilities::GORILLATACTICS,PBAbilities::GORILLATACTICS,PBAbilities::ZENMODE],
		:Movelist => [[0,PBMoves::ICICLECRASH],[1,PBMoves::ICICLECRASH],[1,PBMoves::POWDERSNOW],[1,PBMoves::TACKLE],[1,PBMoves::TAUNT],[1,PBMoves::BITE],
		[12,PBMoves::AVALANCHE],[16,PBMoves::WORKUP],[20,PBMoves::ICEFANG],[24,PBMoves::HEADBUTT],
		[28,PBMoves::ICEPUNCH],[32,PBMoves::UPROAR],[38,PBMoves::BELLYDRUM],
		[44,PBMoves::BLIZZARD],[50,PBMoves::THRASH],[56,PBMoves::SUPERPOWER]],
		:Height => 1.7,
		:Weight => 120
	},

	"Galar Zen" => {
		:DexEntry => "Darmanitan takes this form when enraged. It won't stop spewing flames until its rage has settled, even if its body starts to melt.",
		:BaseStats => [105,160,135,55,30,55],
		:EVs => [0,0,0,0,2,0],
		:Type1 => PBTypes::ICE,
		:Type2 => PBTypes::FIRE,
		:Ability => [PBAbilities::GORILLATACTICS,PBAbilities::GORILLATACTICS,PBAbilities::ZENMODE],
		:Movelist => [[0,PBMoves::ICICLECRASH],[1,PBMoves::ICICLECRASH],[1,PBMoves::POWDERSNOW],[1,PBMoves::TACKLE],[1,PBMoves::TAUNT],[1,PBMoves::BITE],
		[12,PBMoves::AVALANCHE],[16,PBMoves::WORKUP],[20,PBMoves::ICEFANG],[24,PBMoves::HEADBUTT],
		[28,PBMoves::ICEPUNCH],[32,PBMoves::UPROAR],[38,PBMoves::BELLYDRUM],
		[44,PBMoves::BLIZZARD],[50,PBMoves::THRASH],[56,PBMoves::SUPERPOWER]],
		:Height => 1.7,
		:Weight => 120
	}
},

PBSpecies::DEERLING => {
	:OnCreation => proc{
		maps=[710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,742]
		case rand(2)
			when 0 then next $game_map && maps.include?($game_map.map_id) ? 2 : 0
			when 1 then next $game_map && maps.include?($game_map.map_id) ? 3 : 1
		end
	}
},

PBSpecies::TORNADUS => {
	:FormName => {1 => "Therian"},

	"Therian" => {
		:BaseStats => [79,100,80,121,110,90],
		:EVs => [0,0,0,3,0,0],
		:Ability => PBAbilities::REGENERATOR,
		:Height => 14
	}
},

PBSpecies::THUNDURUS => {
	:FormName => {1 => "Therian"},

	"Therian" => {
		:BaseStats => [79,105,70,101,145,80],
		:EVs => [0,0,0,0,3,0],
		:Ability => PBAbilities::VOLTABSORB,
		:Height => 30
	}
},

PBSpecies::LANDORUS => {
	:FormName => {1 => "Therian"},

	"Therian" => {
		:BaseStats => [89,145,90,91,105,80],
		:EVs => [0,3,0,0,0,0],
		:Ability => PBAbilities::INTIMIDATE,
		:Height => 13
	}
},

PBSpecies::KYUREM => {
	:FormName => {
		1 => "White",
		2 => "Black"
	},

	"White" => {
		:BaseStats => [125,120,90,95,170,100],
		:EVs => [0,0,0,0,3,0],
		:Movelist => [[1,PBMoves::ICYWIND],[1,PBMoves::DRAGONRAGE],[8,PBMoves::IMPRISON],
		[15,PBMoves::ANCIENTPOWER],[22,PBMoves::ICEBEAM],[29,PBMoves::DRAGONBREATH],
		[36,PBMoves::SLASH],[43,PBMoves::FUSIONFLARE],[50,PBMoves::ICEBURN],
		[57,PBMoves::DRAGONPULSE],[64,PBMoves::NOBLEROAR],[71,PBMoves::ENDEAVOR],
		[78,PBMoves::BLIZZARD],[85,PBMoves::OUTRAGE],[92,PBMoves::HYPERVOICE]],
		:Ability => PBAbilities::TURBOBLAZE,
		:Height => 36
	},

	"Black" => {
		:BaseStats => [125,170,100,95,120,90],
		:EVs => [0,3,0,0,0,0],
		:Movelist => [[1,PBMoves::ICYWIND],[1,PBMoves::DRAGONRAGE],[8,PBMoves::IMPRISON],
		[15,PBMoves::ANCIENTPOWER],[22,PBMoves::ICEBEAM],[29,PBMoves::DRAGONBREATH],
		[36,PBMoves::SLASH],[43,PBMoves::FUSIONBOLT],[50,PBMoves::FREEZESHOCK],
		[57,PBMoves::DRAGONPULSE],[64,PBMoves::NOBLEROAR],[71,PBMoves::ENDEAVOR],
		[78,PBMoves::BLIZZARD],[85,PBMoves::OUTRAGE],[92,PBMoves::HYPERVOICE]],
		:Ability => PBAbilities::TERAVOLT,
		:Height => 33
	}
},

PBSpecies::MELOETTA => {
	:FormName => {1 => "Pirouette"},

	"Pirouette" => {
		:BaseStats => [100,128,90,128,77,77],
		:EVs => [0,1,1,1,0,0],
		:Type2 => PBTypes::FIGHTING,
	}
},

PBSpecies::MEOWSTIC => {
	:FormName => {1 => "Female"},

	"Female" => {
		:Movelist => [[1,PBMoves::STOREDPOWER],[1,PBMoves::MEFIRST],[1,PBMoves::MAGICALLEAF],[1,PBMoves::SCRATCH],
			[1,PBMoves::LEER],[1,PBMoves::COVET],[1,PBMoves::CONFUSION],[5,PBMoves::COVET],[9,PBMoves::CONFUSION],[13,PBMoves::LIGHTSCREEN],
			[17,PBMoves::PSYBEAM],[19,PBMoves::FAKEOUT],[22,PBMoves::DISARMINGVOICE],[25,PBMoves::PSYSHOCK],[28,PBMoves::CHARGEBEAM],
			[31,PBMoves::SHADOWBALL],[35,PBMoves::EXTRASENSORY],[40,PBMoves::PSYCHIC],
			[43,PBMoves::ROLEPLAY],[45,PBMoves::SIGNALBEAM],[48,PBMoves::SUCKERPUNCH],
			[50,PBMoves::FUTURESIGHT],[53,PBMoves::STOREDPOWER]],
		:Ability => [PBAbilities::KEENEYE, PBAbilities::INFILTRATOR, PBAbilities::COMPETITIVE]
	}
},

PBSpecies::PUMPKABOO => {
	:OnCreation => proc{rand(2)},
	:FormName => {1 => "Small"},

	"Small" => {
		:BaseStats => [44,66,70,56,44,55],
		:Height => 03,
		:Weight => 35
	}
},

PBSpecies::GOURGEIST => {
	:OnCreation => proc{rand(2)},
	:FormName => {1 => "Small"},

	"Small" => {
		:BaseStats => [55,85,122,99,58,75],
		:Height => 07,
		:Weight => 95
	}
},


PBSpecies::AEGISLASH => {
	:FormName => {
		1 => "Blade",
		2 => "Crystal"
	},

	"Blade" => {:BaseStats => [60,150,50,60,150,50]},

	"Crystal" => {
		:BaseStats => [200,150,150,70,150,150],
		:EVs => [0,2,0,0,2,0],
		:Type2 => PBTypes::FAIRY,
		:Ability => PBAbilities::FRIENDGUARD
	}
},

PBSpecies::ZYGARDE => {
	:FormName => {
		0 => "50%",
		1 => "10%",
		2 => "100%"
	},

	"10%" => {
		:DexEntry => "Its sharp fangs make short work of finishing off its enemies, but it's unable to maintain this body indefinitely. After a period of time, it falls apart.",
		:BaseStats => [54,100,71,115,61,85],
		:Height => 12,
		:Weight => 335
	},

	"100%" => {
		:DexEntry => "This is Zygarde's form at times when it uses its overwhelming power to suppress those who endanger the ecosystem.",
		:BaseStats => [216,100,121,85,91,95],
		:Height => 45,
		:Weight => 6100
	}
},

PBSpecies::HOOPA => {
	:FormName => {1 => "Unbound"},

	"Unbound" => {
		:BaseStats => [80,160,60,80,170,130],
		:Type2 => PBTypes::DARK,
		:Movelist => [[1,PBMoves::HYPERSPACEFURY],[1,PBMoves::TRICK],[1,PBMoves::DESTINYBOND],[1,PBMoves::ALLYSWITCH],
		[1,PBMoves::CONFUSION],[6,PBMoves::ASTONISH],[10,PBMoves::MAGICCOAT],[15,PBMoves::LIGHTSCREEN],
		[19,PBMoves::PSYBEAM],[25,PBMoves::SKILLSWAP],[29,PBMoves::POWERSPLIT],[29,PBMoves::GUARDSPLIT],
		[46,PBMoves::KNOCKOFF],[50,PBMoves::WONDERROOM],[50,PBMoves::TRICKROOM],[55,PBMoves::DARKPULSE],
		[75,PBMoves::PSYCHIC],[85,PBMoves::HYPERSPACEFURY]],
		:Height => 65,
		:Weight => 4900
	}
},

PBSpecies::ORICORIO => {
	:FormName => {
		1 => "Pom-Pom",
		2 => "Pa'u",
		3 => "Sensu"
	},

	"Pom-Pom" => {
		:DexEntry => "It creates an electric charge by rubbing its feathers together. It dances over to its enemies and delivers shocking electrical punches.",
		:Type1 => PBTypes::ELECTRIC
	},

	"Pa'u" => {
		:DexEntry => "This Oricorio relaxes by swaying gently. This increases its psychic energy, which it then fires at its enemies.",
		:Type1 => PBTypes::PSYCHIC
	},

	"Sensu" => {
		:DexEntry => "It summons the dead with its dreamy dancing. From their malice, it draws power with which to curse its enemies.",
		:Type1 => PBTypes::GHOST
	}
},

PBSpecies::LYCANROC => {
	:FormName => {
		1 => "Midnight",
		2 => "Dusk"
	},
	:OnCreation => proc{
		daytime = PBDayNight.isDay?(pbGetTimeNow)
		dusktime = PBDayNight.isDusk?(pbGetTimeNow)
		# Map IDs for second form
		if dusktime
			next 2
		elsif daytime
			next 0
		else
			next 1
		end
	},

	"Midnight" => {
		:DexEntry => "It goads its enemies into attacking, withstands the hits, and in return, delivers a headbutt, crushing their bones with its rocky mane.",
		:BaseStats => [85,115,75,82,55,75],
		:Ability => [PBAbilities::KEENEYE,PBAbilities::VITALSPIRIT,PBAbilities::NOGUARD],
		:Movelist => [[0,PBMoves::COUNTER],[1,PBMoves::REVERSAL],[1,PBMoves::TAUNT],
		[1,PBMoves::TACKLE],[1,PBMoves::LEER],[1,PBMoves::SANDATTACK],
		[1,PBMoves::BITE],[4,PBMoves::SANDATTACK],[7,PBMoves::BITE],[12,PBMoves::HOWL],
		[15,PBMoves::ROCKTHROW],[18,PBMoves::ODORSLEUTH],[23,PBMoves::ROCKTOMB],
		[26,PBMoves::ROAR],[29,PBMoves::STEALTHROCK],[34,PBMoves::ROCKSLIDE],
		[37,PBMoves::SCARYFACE],[40,PBMoves::CRUNCH],[45,PBMoves::ROCKCLIMB],
		[48,PBMoves::STONEEDGE]],
		:Height => 11,
	},

	"Dusk" => {
		:DexEntry => "Bathed in the setting sun of evening, Lycanroc has undergone a special kind of evolution. An intense fighting spirit underlies its calmness.",
		:BaseStats => [75,117,65,110,55,65],
		:Ability => [PBAbilities::TOUGHCLAWS,PBAbilities::TOUGHCLAWS,PBAbilities::TOUGHCLAWS],
		:Movelist => [[0,PBMoves::THRASH],[1,PBMoves::ACCELEROCK],[1,PBMoves::COUNTER],
		[1,PBMoves::TACKLE],[1,PBMoves::LEER],[1,PBMoves::SANDATTACK],
		[1,PBMoves::BITE],[4,PBMoves::SANDATTACK],[7,PBMoves::BITE],[12,PBMoves::HOWL],
		[15,PBMoves::ROCKTHROW],[18,PBMoves::ODORSLEUTH],[23,PBMoves::ROCKTOMB],
		[26,PBMoves::ROAR],[29,PBMoves::STEALTHROCK],[34,PBMoves::ROCKSLIDE],
		[37,PBMoves::SCARYFACE],[40,PBMoves::CRUNCH],[45,PBMoves::ROCKCLIMB],
		[48,PBMoves::STONEEDGE]],
	}
},

PBSpecies::WISHIWASHI => {
	:FormName => {1 => "School"},

	"School" => {
		:DexEntry => "At their appearance, even Gyarados will flee. When they team up to use Water Gun, its power exceeds that of Hydro Pump.",
		:BaseStats => [45,140,130,30,140,135],
		:Height => 82,
 		:Weight => 786,
	}
},

PBSpecies::MINIOR => {
	:OnCreation => proc{rand(7)},
	:FormName => {7 => "Core"},

	"Core" => {
		:BaseStats => [60,60,100,60,60,100],
		:EVs => [0,1,0,0,1,0],
 		:Weight => 400,
		:CatchRate => 30
	}
},

PBSpecies::NECROZMA => {
	:FormName => {
		1 => "Dusk Mane",
		2 => "Dawn Wings",
		3 => "Ultra"
	},
	:UltraForm => 3,

	"Dusk Mane" => {
		:DexEntry => "This is its form while it is devouring the light of Solgaleo. It pounces on foes and then slashes them with the claws on its four limbs and back.",
		:BaseStats => [97,157,127,77,113,109],
		:EVs => [0,3,0,0,0,0],
		:Type2 => PBTypes::STEEL,
		:Height => 38,
		:Weight => 4600
	},

	"Dawn Wings" => {
		:DexEntry => "This is its form while it's devouring the light of Lunala. It grasps foes in its giant claws and rips them apart with brute force.",
		:BaseStats => [97,113,109,77,157,127],
		:EVs => [0,0,0,0,3,0],
		:Type2 => PBTypes::GHOST,
		:Height => 42,
		:Weight => 3500
	},

	"Ultra" => {
		:DexEntry => "The light pouring out from all over its body affects living things and nature, impacting them in various ways.",
		:BaseStats => [97,167,97,129,167,97],
		:EVs => [0,1,0,1,1,0],
		:Type2 => PBTypes::DRAGON,
		:Ability => PBAbilities::NEUROFORCE,
		:Height => 75,
		:Weight => 2300
	}
},

PBSpecies::EISCUE => {
	:FormName => {1 => "Noice"},
	"Noice" => {:BaseStats => [75,80,70,130,65,50]},
},

###################### Regional Variants ######################

PBSpecies::RATTATA => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[170, 524]
		# Map IDs for alolan form
		next $game_map && maps.include?($game_map.map_id) ? 1 : 0
 	},

	"Alolan" => {
		:DexEntry => "With its incisors, it gnaws through doors and infiltrates people's homes. Then, with a twitch of its whiskers, it steals whatever food it finds.",
		:Type1 => PBTypes::DARK,
		:Type2 => PBTypes::NORMAL,
		:Weight => 38,
		:Ability => [PBAbilities::GLUTTONY,PBAbilities::HUSTLE,PBAbilities::THICKFAT],
		:Movelist => [[1,PBMoves::TACKLE],[1,PBMoves::TAILWHIP],[4,PBMoves::QUICKATTACK],
			[7,PBMoves::FOCUSENERGY],[10,PBMoves::BITE],[13,PBMoves::PURSUIT],
			[16,PBMoves::HYPERFANG],[19,PBMoves::ASSURANCE],[22,PBMoves::CRUNCH],
			[25,PBMoves::SUCKERPUNCH],[29,PBMoves::SUPERFANG],[31,PBMoves::DOUBLEEDGE],
			[34,PBMoves::ENDEAVOR]] ,
		:EggMoves => [PBMoves::COUNTER,PBMoves::FINALGAMBIT,PBMoves::FURYSWIPES,PBMoves::MEFIRST,
				PBMoves::REVENGE,PBMoves::REVERSAL,PBMoves::SNATCH,PBMoves::STOCKPILE,
				PBMoves::SWALLOW,PBMoves::SWITCHEROO,PBMoves::UPROAR],
		:WildHoldItems => [0,PBItems::PECHABERRY,0],
		:GetEvo => [[20,30,20]]
	}
},

PBSpecies::RATICATE => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[170, 524]
		# Map IDs for alolan form
		next $game_map && maps.include?($game_map.map_id) ? 1 : 0
 	},

	"Alolan" => {
		:DexEntry => "It forms a group of Rattata, which it assumes command of. Each group has its own territory, and disputes over food happen often.",
		:Type1 => PBTypes::DARK,
		:Type2 => PBTypes::NORMAL,
		:BaseStats => [75,71,70,77,40,80],
		:Weight => 255,
		:Ability => [PBAbilities::GLUTTONY,PBAbilities::HUSTLE,PBAbilities::THICKFAT],
		:Movelist => [[0,PBMoves::SCARYFACE],[1,PBMoves::SWORDSDANCE],[1,PBMoves::TACKLE],
			[1,PBMoves::TAILWHIP],[1,PBMoves::QUICKATTACK],[1,PBMoves::FOCUSENERGY],
			[4,PBMoves::QUICKATTACK],[7,PBMoves::FOCUSENERGY],[10,PBMoves::BITE],[13,PBMoves::PURSUIT],
			[16,PBMoves::HYPERFANG],[19,PBMoves::ASSURANCE],[24,PBMoves::CRUNCH],
			[29,PBMoves::SUCKERPUNCH],[34,PBMoves::SUPERFANG],[39,PBMoves::DOUBLEEDGE],
			[44,PBMoves::ENDEAVOR]],
		:WildHoldItems => [0,PBItems::PECHABERRY,0]
	}
},

PBSpecies::RAICHU => {
	:FormName => {1 => "Alolan"},
	"Alolan" => {
		:DexEntry => "It uses psychokinesis to control electricity. It hops aboard its own tail, using psychic power to lift the tail and move about while riding it.",
		:Type2 => PBTypes::PSYCHIC,
		:BaseStats => [60,85,50,110,95,85],
		:Height => 7,
		:Weight => 210,
		:Ability => [PBAbilities::SURGESURFER],
		:Movelist => [[0,PBMoves::PSYCHIC],[1,PBMoves::SPEEDSWAP],[1,PBMoves::THUNDERSHOCK],
			[1,PBMoves::TAILWHIP],[1,PBMoves::QUICKATTACK],[1,PBMoves::THUNDERBOLT]]
	}
},

PBSpecies::SANDSHREW => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[364, 366, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 390, 396, 430, 433, 434, 440, 441, 442]
		# Map IDs for alolan form
		next $game_map && maps.include?($game_map.map_id) ? 1 : 0
	},
	"Alolan" => {
		:DexEntry => "It lives on snowy mountains. Its steel shell is very hard—so much so, it can't roll its body up into a ball.",
		:Type1 => PBTypes::ICE,
		:Type2 => PBTypes::STEEL,
		:BaseStats => [50,75,90,40,10,35],
		:Height => 6,
		:Weight => 400,
		:Ability => [PBAbilities::SNOWCLOAK,PBAbilities::SLUSHRUSH],
		:Movelist => [[1,PBMoves::SCRATCH],[1,PBMoves::DEFENSECURL],[3,PBMoves::BIDE],
			[5,PBMoves::POWDERSNOW],[7,PBMoves::ICEBALL],[9,PBMoves::RAPIDSPIN],
			[11,PBMoves::FURYCUTTER],[14,PBMoves::METALCLAW],[17,PBMoves::SWIFT],
			[20,PBMoves::FURYSWIPES],[23,PBMoves::IRONDEFENSE],[26,PBMoves::SLASH],
			[30,PBMoves::IRONHEAD],[34,PBMoves::GYROBALL],[38,PBMoves::SWORDSDANCE],
			[42,PBMoves::HAIL],[46,PBMoves::BLIZZARD]],
		:EggMoves => [PBMoves::AMNESIA,PBMoves::CHIPAWAY,PBMoves::COUNTER,PBMoves::CRUSHCLAW,PBMoves::CURSE,
				PBMoves::ENDURE,PBMoves::FLAIL,PBMoves::HONECLAWS,PBMoves::ICICLECRASH,PBMoves::ICICLESPEAR,
				PBMoves::METALCLAW,PBMoves::NIGHTSLASH],
		:WildHoldItems => [0,PBItems::PECHABERRY,0],
		:GetEvo => [[28,7,692]]
	}
},

PBSpecies::SANDSLASH => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[364, 366, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 390, 396, 430, 433, 434, 440, 441, 442, 749, 750, 834, 882]
		# Map IDs for alolan form
		next $game_map && maps.include?($game_map.map_id) ? 1 : 0
	},
	"Alolan" => {
		:DexEntry => "This Pokémon's steel spikes are sheathed in ice. Stabs from these spikes cause deep wounds and severe frostbite as well.",
		:Type1 => PBTypes::ICE,
		:Type2 => PBTypes::STEEL,
		:BaseStats => [75,100,120,65,25,65],
		:Height => 12,
		:Weight => 550,
		:Ability => [PBAbilities::SNOWCLOAK,PBAbilities::SLUSHRUSH],
		:Movelist => [[0,PBMoves::ICICLESPEAR],[1,PBMoves::METALBURST],[1,PBMoves::ICICLECRASH],
			[1,PBMoves::SLASH],[1,PBMoves::DEFENSECURL],[1,PBMoves::ICEBALL],
			[1,PBMoves::METALCLAW]],
		:EggMoves => [PBMoves::AMNESIA,PBMoves::CHIPAWAY,PBMoves::COUNTER,PBMoves::CRUSHCLAW,PBMoves::CURSE,
				PBMoves::ENDURE,PBMoves::FLAIL,PBMoves::HONECLAWS,PBMoves::ICICLECRASH,PBMoves::ICICLESPEAR,
				PBMoves::METALCLAW,PBMoves::NIGHTSLASH],
		:WildHoldItems => [0,PBItems::PECHABERRY,0]
	}
},

PBSpecies::VULPIX => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[439,721,723,725,726,727,729,794]
		# Map IDs for alolan form
		next $game_map && maps.include?($game_map.map_id) ? 1 : 0
 	},
	"Alolan" => {
		:DexEntry => "In hot weather, this Pokémon makes ice shards with its six tails and sprays them around to cool itself off.",
		:Type1 => PBTypes::ICE,
		:Type2 => PBTypes::ICE,
		:Ability => [PBAbilities::SNOWCLOAK,PBAbilities::SNOWWARNING],
		:Movelist => [[1,PBMoves::POWDERSNOW],[4,PBMoves::TAILWHIP],[7,PBMoves::ROAR],
			[9,PBMoves::BABYDOLLEYES],[10,PBMoves::ICESHARD],[12,PBMoves::CONFUSERAY],
			[15,PBMoves::ICYWIND],[18,PBMoves::PAYBACK],[20,PBMoves::MIST],
			[23,PBMoves::FEINTATTACK],[26,PBMoves::HEX],[28,PBMoves::AURORABEAM],
			[31,PBMoves::EXTRASENSORY],[34,PBMoves::SAFEGUARD],[36,PBMoves::ICEBEAM],
			[39,PBMoves::IMPRISON],[42,PBMoves::BLIZZARD],[44,PBMoves::GRUDGE],
			[47,PBMoves::CAPTIVATE],[50,PBMoves::SHEERCOLD]],
		:EggMoves => [PBMoves::AGILITY,PBMoves::CHARM,PBMoves::DISABLE,PBMoves::ENCORE,
				PBMoves::EXTRASENSORY,PBMoves::FLAIL,PBMoves::FREEZEDRY,PBMoves::HOWL,
				PBMoves::HYPNOSIS,PBMoves::MOONBLAST,PBMoves::POWERSWAP,PBMoves::SPITE,
				PBMoves::SECRETPOWER,PBMoves::TAILSLAP],
		:WildHoldItems => [0,PBItems::SNOWBALL,0],
		:GetEvo => [[38,7,692]]
	}
},

PBSpecies::NINETALES => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[439,721,723,725,726,727,729,794]
		# Map IDs for alolan form
		next $game_map && maps.include?($game_map.map_id) ? 1 : 0
 	},

	"Alolan" => {
		:DexEntry => "Possessing a calm demeanor, this Pokémon was revered as a deity incarnate before it was identified as a regional variant of Ninetales.",
		:Type1 => PBTypes::ICE,
		:Type2 => PBTypes::FAIRY,
		:BaseStats => [73,67,75,109,81,100],
		:EVs => [0,0,0,2,0,0],
		:Ability => [PBAbilities::SNOWCLOAK,PBAbilities::SNOWWARNING],
		:Movelist => [[0,PBMoves::DAZZLINGGLEAM],[1,PBMoves::IMPRISON],[1,PBMoves::NASTYPLOT],
			[1,PBMoves::ICEBEAM],[1,PBMoves::ICESHARD],[1,PBMoves::CONFUSERAY],
			[1,PBMoves::SAFEGUARD]],
		:EggMoves => [PBMoves::AGILITY,PBMoves::CHARM,PBMoves::DISABLE,PBMoves::ENCORE,
				PBMoves::EXTRASENSORY,PBMoves::FLAIL,PBMoves::FREEZEDRY,PBMoves::HOWL,
				PBMoves::HYPNOSIS,PBMoves::MOONBLAST,PBMoves::POWERSWAP,PBMoves::SPITE,
				PBMoves::SECRETPOWER,PBMoves::TAILSLAP],
		:WildHoldItems => [0,PBItems::SNOWBALL,0]
	}
},

PBSpecies::DIGLETT => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[33, 34, 35, 199, 201, 202, 203, 204]
		# Map IDs for alolan form
		next $game_map && maps.include?($game_map.map_id) ? 1 : 0
 	},

	"Alolan" => {
		:DexEntry => "Its head sports an altered form of whiskers made of metal. When in communication with its comrades, its whiskers wobble to and fro.",
		:Type2 => PBTypes::STEEL,
		:BaseStats => [10,55,30,90,35,40],
		:Ability => [PBAbilities::SANDVEIL,PBAbilities::TANGLINGHAIR,PBAbilities::SANDFORCE],
		:Movelist => [[1,PBMoves::SANDATTACK],[1,PBMoves::METALCLAW],[4,PBMoves::GROWL],
			[7,PBMoves::ASTONISH],[10,PBMoves::MUDSLAP],[14,PBMoves::MAGNITUDE],
			[18,PBMoves::BULLDOZE],[22,PBMoves::SUCKERPUNCH],[25,PBMoves::MUDBOMB],
			[28,PBMoves::EARTHPOWER],[31,PBMoves::DIG],[35,PBMoves::IRONHEAD],
			[39,PBMoves::EARTHQUAKE],[43,PBMoves::FISSURE]],
		:EggMoves => [PBMoves::ANCIENTPOWER,PBMoves::BEATUP,PBMoves::ENDURE,PBMoves::FEINTATTACK,
				PBMoves::FINALGAMBIT,PBMoves::HEADBUTT,PBMoves::MEMENTO,PBMoves::METALSOUND,
				PBMoves::PURSUIT,PBMoves::REVERSAL,PBMoves::FLASH],
		:Weight => 10
	}
},

PBSpecies::DUGTRIO => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[33, 34, 35, 199, 201, 202, 203, 204]
		# Map IDs for alolan form
		next $game_map && maps.include?($game_map.map_id) ? 1 : 0
 	},

	"Alolan" => {
		:DexEntry => "Its shining gold hair provides it with protection. It's reputed that keeping any of its fallen hairs will bring bad luck.",
		:Type2 => PBTypes::STEEL,
		:BaseStats => [35,100,60,110,50,70],
		:EVs => [0,2,0,0,0,0],
		:Ability => [PBAbilities::SANDVEIL,PBAbilities::TANGLINGHAIR,PBAbilities::SANDFORCE],
		:Movelist => [[0,PBMoves::SANDTOMB],[1,PBMoves::ROTOTILLER],[1,PBMoves::NIGHTSLASH],
			[1,PBMoves::TRIATTACK],[1,PBMoves::SANDATTACK],[1,PBMoves::METALCLAW],[1,PBMoves::GROWL],
			[4,PBMoves::GROWL],[7,PBMoves::ASTONISH],[10,PBMoves::MUDSLAP],[14,PBMoves::MAGNITUDE],
			[18,PBMoves::BULLDOZE],[22,PBMoves::SUCKERPUNCH],[25,PBMoves::MUDBOMB],
			[30,PBMoves::EARTHPOWER],[35,PBMoves::DIG],[41,PBMoves::IRONHEAD],
			[47,PBMoves::EARTHQUAKE],[53,PBMoves::FISSURE]],
		:Weight => 666
	}
},

PBSpecies::MEOWTH => {
	:FormName => {
		1 => "Alolan",
		2 => "Galarian"
	},
	:OnCreation => proc{
		aMaps=[170, 524]
		gMaps=[]
		# Map IDs for alolan and galarian forms respectively
		if $game_map && aMaps.include?($game_map.map_id)
			next 1
		elsif $game_map && gMaps.include?($game_map.map_id)
			next 2
		else
			next 0
		end
	},

	"Alolan" => {
		:DexEntry => "When its delicate pride is wounded, or when the gold coin on its forehead is dirtied, it flies into a hysterical rage.",
		:Type1 => PBTypes::DARK,
		:Type2 => PBTypes::DARK,
		:BaseStats => [40,35,35,90,50,40],
		:EVs => [0,2,0,0,0,0],
		:Ability => [PBAbilities::PICKUP,PBAbilities::TECHNICIAN,PBAbilities::RATTLED],
		:Movelist => [[1,PBMoves::SCRATCH],[1,PBMoves::GROWL],[6,PBMoves::BITE],
			[9,PBMoves::FAKEOUT],[14,PBMoves::FURYSWIPES],[17,PBMoves::SCREECH],
			[22,PBMoves::FEINTATTACK],[25,PBMoves::TAUNT],[30,PBMoves::PAYDAY],
			[33,PBMoves::SLASH],[38,PBMoves::NASTYPLOT],[41,PBMoves::ASSURANCE],
			[46,PBMoves::CAPTIVATE],[49,PBMoves::NIGHTSLASH],[50,PBMoves::FEINT],
			[55,PBMoves::DARKPULSE]],
		:EggMoves => [PBMoves::AMNESIA,PBMoves::ASSIST,PBMoves::CHARM,PBMoves::COVET,PBMoves::FLAIL,PBMoves::FLATTER,
			PBMoves::FOULPLAY,PBMoves::HYPNOSIS,PBMoves::PARTINGSHOT,PBMoves::PUNISHMENT,
			PBMoves::SNATCH,PBMoves::SPITE],
		:GetEvo => [[53,1,0]]
	},

	"Galarian" => {
		:DexEntry => "These daring Pokémon have coins on their foreheads. Darker coins are harder, and harder coins garner more respect among Meowth.",
		:Type1 => PBTypes::STEEL,
		:Type2 => PBTypes::STEEL,
		:BaseStats => [40,35,35,90,50,40],
		:EVs => [0,2,0,0,0,0],
		:Ability => [PBAbilities::PICKUP,PBAbilities::TOUGHCLAWS,PBAbilities::UNNERVE],
		:Movelist => [[1,PBMoves::POWDERSNOW],[4,PBMoves::TAILWHIP],[7,PBMoves::ROAR],
			[9,PBMoves::BABYDOLLEYES],[10,PBMoves::ICESHARD],[12,PBMoves::CONFUSERAY],
			[15,PBMoves::ICYWIND],[18,PBMoves::PAYBACK],[20,PBMoves::MIST],
			[23,PBMoves::FEINTATTACK],[26,PBMoves::HEX],[28,PBMoves::AURORABEAM],
			[31,PBMoves::EXTRASENSORY],[34,PBMoves::SAFEGUARD],[36,PBMoves::ICEBEAM],
			[39,PBMoves::IMPRISON],[42,PBMoves::BLIZZARD],[44,PBMoves::GRUDGE],
			[47,PBMoves::CAPTIVATE],[50,PBMoves::SHEERCOLD]],
		:EggMoves => [PBMoves::COVET,PBMoves::FLAIL,PBMoves::SPITE,PBMoves::DOUBLEEDGE,PBMoves::CURSE,PBMoves::NIGHTSLASH],
		:GetEvo => [[4,28,863]]
	}
},

PBSpecies::PERSIAN => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[170, 524, 866]
		# Map IDs for alolan form
		if $game_map && maps.include?($game_map.map_id)
			next 1
		else
			next 0
		end
	},

	"Alolan" => {
		:DexEntry => "It looks down on everyone other than itself. Its preferred tactics are sucker punches and blindside attacks.",
		:Type1 => PBTypes::DARK,
		:Type2 => PBTypes::DARK,
		:BaseStats => [65,60,60,115,75,65],
		:EVs => [0,2,0,0,0,0],
		:Ability => [PBAbilities::FURCOAT,PBAbilities::TECHNICIAN,PBAbilities::RATTLED],
		:Movelist => [[0,PBMoves::SWIFT],[1,PBMoves::QUASH],[1,PBMoves::PLAYROUGH],[1,PBMoves::SWITCHEROO],
			[1,PBMoves::SCRATCH],[1,PBMoves::GROWL],[1,PBMoves::BITE],[1,PBMoves::FAKEOUT],[6,PBMoves::BITE],
			[9,PBMoves::FAKEOUT],[14,PBMoves::FURYSWIPES],[17,PBMoves::SCREECH],
			[22,PBMoves::FEINTATTACK],[25,PBMoves::TAUNT],[32,PBMoves::POWERGEM],
			[37,PBMoves::SLASH],[44,PBMoves::NASTYPLOT],[49,PBMoves::ASSURANCE],
			[56,PBMoves::CAPTIVATE],[61,PBMoves::NIGHTSLASH],[65,PBMoves::FEINT],
			[69,PBMoves::DARKPULSE]],
		:Height => 11,
		:Weight => 330
	}
},

PBSpecies::GEODUDE => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[231, 247, 251, 258, 259, 260, 261, 262, 263, 264, 340, 341, 342, 343, 344, 346, 347, 348, 349, 371, 614, 615, 616, 618, 847]
		# Map IDs for alolan form
		if $game_map && maps.include?($game_map.map_id)
			next 1
		else
			next 0
		end
	},

	"Alolan" => {
		:DexEntry => "If you accidentally step on a Geodude sleeping on the ground, you'll hear a crunching sound and feel a shock ripple through your entire body.",
		:Type2 => PBTypes::ELECTRIC,
		:Ability => [PBAbilities::MAGNETPULL,PBAbilities::STURDY,PBAbilities::GALVANIZE],
		:Movelist => [[1,PBMoves::TACKLE],[1,PBMoves::DEFENSECURL],[4,PBMoves::CHARGE],
			[6,PBMoves::ROCKPOLISH],[10,PBMoves::ROLLOUT],[12,PBMoves::SPARK],
			[16,PBMoves::ROCKTHROW],[18,PBMoves::SMACKDOWN],[22,PBMoves::THUNDERPUNCH],
			[24,PBMoves::SELFDESTRUCT],[28,PBMoves::STEALTHROCK],[30,PBMoves::ROCKBLAST],
			[34,PBMoves::DISCHARGE],[36,PBMoves::EXPLOSION],[40,PBMoves::DOUBLEEDGE],
			[42,PBMoves::STONEEDGE]],
		:EggMoves => [PBMoves::AUTOTOMIZE,PBMoves::BLOCK,PBMoves::COUNTER,PBMoves::CURSE,PBMoves::ENDURE,PBMoves::FLAIL,
			PBMoves::MAGNETRISE,PBMoves::ROCKCLIMB,PBMoves::SCREECH,PBMoves::WIDEGUARD],
		:Weight => 203,
		:WildHoldItems => [0,PBItems::CELLBATTERY,0]
	}
},

PBSpecies::GRAVELER => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[231, 247, 251, 258, 259, 260, 261, 262, 263, 264, 340, 341, 342, 343, 344, 346, 347, 348, 349, 371, 614, 615, 616, 618, 847]
		# Map IDs for alolan form
		if $game_map && maps.include?($game_map.map_id)
			next 1
		else
			next 0
		end
	},

	"Alolan" => {
		:DexEntry => "They eat rocks and often get into a scrap over them. The shock of Graveler smashing together causes a flash of light and a booming noise.",
		:Type2 => PBTypes::ELECTRIC,
		:Ability => [PBAbilities::MAGNETPULL,PBAbilities::STURDY,PBAbilities::GALVANIZE],
		:Movelist => [[1,PBMoves::TACKLE],[1,PBMoves::DEFENSECURL],[4,PBMoves::CHARGE],[1,PBMoves::ROCKPOLISH],
			[1,PBMoves::CHARGE],[6,PBMoves::ROCKPOLISH],[10,PBMoves::ROLLOUT],[12,PBMoves::SPARK],
			[16,PBMoves::ROCKTHROW],[18,PBMoves::SMACKDOWN],[22,PBMoves::THUNDERPUNCH],
			[24,PBMoves::SELFDESTRUCT],[30,PBMoves::STEALTHROCK],[34,PBMoves::ROCKBLAST],
			[40,PBMoves::DISCHARGE],[44,PBMoves::EXPLOSION],[50,PBMoves::DOUBLEEDGE],
			[54,PBMoves::STONEEDGE]],
		:Weight => 1100,
		:WildHoldItems => [0,PBItems::CELLBATTERY,0]
	}
},

PBSpecies::GOLEM => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[231, 247, 251, 258, 259, 260, 261, 262, 263, 264, 340, 341, 342, 343, 344, 346, 347, 348, 349, 371, 614, 615, 616, 618, 847]
		# Map IDs for alolan form
		if $game_map && maps.include?($game_map.map_id)
			next 1
		else
			next 0
		end
	},

	"Alolan" => {
		:DexEntry => "Because it can't fire boulders at a rapid pace, it's been known to seize nearby Geodude and fire them from its back.",
		:Type2 => PBTypes::ELECTRIC,
		:Ability => [PBAbilities::MAGNETPULL,PBAbilities::STURDY,PBAbilities::GALVANIZE],
		:Movelist => [[1,PBMoves::TACKLE],[1,PBMoves::DEFENSECURL],[4,PBMoves::CHARGE],[1,PBMoves::ROCKPOLISH],
			[1,PBMoves::CHARGE],[6,PBMoves::ROCKPOLISH],[10,PBMoves::ROLLOUT],[12,PBMoves::SPARK],
			[16,PBMoves::ROCKTHROW],[18,PBMoves::SMACKDOWN],[22,PBMoves::THUNDERPUNCH],
			[24,PBMoves::SELFDESTRUCT],[30,PBMoves::STEALTHROCK],[34,PBMoves::ROCKBLAST],
			[40,PBMoves::DISCHARGE],[44,PBMoves::EXPLOSION],[50,PBMoves::DOUBLEEDGE],
			[54,PBMoves::STONEEDGE]],
		:Height => 17,
		:Weight => 3160,
		:WildHoldItems => [0,PBItems::CELLBATTERY,0]
	}
},

PBSpecies::GRIMER => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		maps=[467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505]
		# Map IDs for alolan form
		if $game_map && maps.include?($game_map.map_id)
			next 1
		else
			next 0
		end
	},

	"Alolan" => {
		:DexEntry => "The crystals on Grimer's body are lumps of toxins. If one falls off, lethal poisons leak out.",
		:Type2 => PBTypes::DARK,
		:Ability => [PBAbilities::POISONTOUCH,PBAbilities::GLUTTONY,PBAbilities::POWEROFALCHEMY],
		:Movelist => [[1,PBMoves::POUND],[1,PBMoves::POISONGAS],[4,PBMoves::HARDEN],[7,PBMoves::BITE],
			[12,PBMoves::DISABLE],[15,PBMoves::ACIDSPRAY],[18,PBMoves::POISONFANG],
			[21,PBMoves::MINIMIZE],[26,PBMoves::FLING],[29,PBMoves::KNOCKOFF],[32,PBMoves::CRUNCH],
			[37,PBMoves::SCREECH],[40,PBMoves::GUNKSHOT],[43,PBMoves::ACIDARMOR],
			[46,PBMoves::BELCH],[48,PBMoves::MEMENTO]],
		:EggMoves => [PBMoves::ASSURANCE,PBMoves::CLEARSMOG,PBMoves::CURSE,PBMoves::IMPRISON,PBMoves::MEANLOOK,PBMoves::POWERUPPUNCH,
			PBMoves::PURSUIT,PBMoves::SCARYFACE,PBMoves::SHADOWSNEAK,PBMoves::SPITE,
			PBMoves::SPITUP,PBMoves::STOCKPILE,PBMoves::SWALLOW],
		:Height => 7,
		:Weight => 420
	}
},

PBSpecies::MUK => {
	:FormName => {
		1 => "Alolan",
		2 => "PULSE",
	},

	:PulseForm => 2,

	:OnCreation => proc{
		maps=[467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 879]
		# Map IDs for alolan form
		if $game_map && maps.include?($game_map.map_id)
			next 1
		else
			next 0
		end
	},

	"Alolan" => {
		:DexEntry => "While it's unexpectedly quiet and friendly, if it's not fed any trash for a while, it will smash its Trainer's furnishings and eat up the fragments.",
		:Type2 => PBTypes::DARK,
		:Ability => [PBAbilities::POISONTOUCH,PBAbilities::GLUTTONY,PBAbilities::POWEROFALCHEMY],
		:Movelist => [[0,PBMoves::VENOMDRENCH],[1,PBMoves::POUND],
			[1,PBMoves::POISONGAS],[1,PBMoves::HARDEN],
			[4,PBMoves::HARDEN],[7,PBMoves::BITE],
			[12,PBMoves::DISABLE],[15,PBMoves::ACIDSPRAY],[18,PBMoves::POISONFANG],
			[21,PBMoves::MINIMIZE],[26,PBMoves::FLING],[29,PBMoves::KNOCKOFF],[32,PBMoves::CRUNCH],
			[37,PBMoves::SCREECH],[40,PBMoves::GUNKSHOT],[46,PBMoves::ACIDARMOR],
			[52,PBMoves::BELCH],[57,PBMoves::MEMENTO]],
		:Height => 10,
		:Weight => 520
	},

	"PULSE" => {
		:BaseStats => [105,105,70,40,97,250],
		:Ability => PBAbilities::PROTEAN,
		:Weight => 1023
	}
},

PBSpecies::EXEGGUTOR => {
	:FormName => {1 => "Alolan"},

	"Alolan" => {
		:DexEntry => "As it grew taller and taller, it outgrew its reliance on psychic powers, while within it awakened the power of the sleeping dragon.",
		:Type2 => PBTypes::DRAGON,
		:BaseStats => [95,105,85,45,125,75],
		:Ability => [PBAbilities::FRISK,PBAbilities::FRISK,PBAbilities::HARVEST],
		:Movelist => [[0,PBMoves::DRAGONHAMMER],[1,PBMoves::SEEDBOMB],[1,PBMoves::BARRAGE],
			[1,PBMoves::HYPNOSIS],[1,PBMoves::CONFUSION],[17,PBMoves::PSYSHOCK],
			[27,PBMoves::EGGBOMB],[37,PBMoves::WOODHAMMER],[47,PBMoves::LEAFSTORM]],
		:Height => 109,
		:Weight => 4156
	}
},

PBSpecies::MAROWAK => {
	:FormName => {1 => "Alolan"},
	:OnCreation => proc{
		chancemaps=[669,880]
		# Map IDs for alolan form
		if $game_map && chancemaps.include?($game_map.map_id)
			randomnum = rand(2)
			if randomnum == 1
				next 1
			elsif randomnum == 0
				next 0
			end
		else
			next 0
		end
	},

	"Alolan" => {
		:DexEntry => "The bones it possesses were once its mother's. Its mother's regrets have become like a vengeful spirit protecting this Pokémon.",
		:Type1 => PBTypes::FIRE,
		:Type2 => PBTypes::GHOST,
		:BaseStats => [60,80,110,45,50,80],
		:Ability => [PBAbilities::CURSEDBODY,PBAbilities::LIGHTNINGROD,PBAbilities::ROCKHEAD],
		:Movelist => [[1,PBMoves::GROWL],[1,PBMoves::TAILWHIP],[1,PBMoves::BONECLUB],[1,PBMoves::FLAMEWHEEL],
			[3,PBMoves::TAILWHIP],[7,PBMoves::BONECLUB],[11,PBMoves::FLAMEWHEEL],[13,PBMoves::LEER],
			[17,PBMoves::HEX],[21,PBMoves::BONEMERANG],[23,PBMoves::WILLOWISP],
			[27,PBMoves::SHADOWBONE],[33,PBMoves::THRASH],[37,PBMoves::FLING],
			[43,PBMoves::STOMPINGTANTRUM],[49,PBMoves::ENDEAVOR],[53,PBMoves::FLAREBLITZ],
			[59,PBMoves::RETALIATE],[65,PBMoves::BONERUSH]],
		:Weight => 340
	}
},

PBSpecies::MISDREAVUS => {
	:FormName => {1 => "Aevian"},

	"Aevian" => {
		:DexEntry => "It knows the swamp it lives in like no other and blends in perfectly. It's more timid than its regular counterpart, and doesn't like showing itself to bypassers.",
		:Type1 => PBTypes::GRASS,
		:Type2 => PBTypes::GHOST,
		:BaseStats => [60,85,60,85,85,60],
		:Ability => [PBAbilities::MAGICBOUNCE,PBAbilities::POISONPOINT,PBAbilities::TANGLINGHAIR],
		:Movelist => [[1,PBMoves::GROWL],[1,PBMoves::VINEWHIP],[5,PBMoves::POISONPOWDER],[10,PBMoves::ASTONISH],
         [14,PBMoves::CONFUSERAY],[19,PBMoves::SNAPTRAP],[23,PBMoves::HEX],[28,PBMoves::GIGADRAIN],
         [32,PBMoves::INGRAIN],[37,PBMoves::GRUDGE],[41,PBMoves::SHADOWBALL],
         [46,PBMoves::PERISHSONG],[50,PBMoves::POWERWHIP],[55,PBMoves::POWERGEM]],
		:EggMoves => 
        [PBMoves::CURSE,PBMoves::DESTINYBOND,PBMoves::GROWTH,PBMoves::MEFIRST,PBMoves::MEMENTO,
         PBMoves::NASTYPLOT,PBMoves::CLEARSMOG,PBMoves::SCREECH,PBMoves::SHADOWSNEAK,PBMoves::LIFEDEW,
         PBMoves::TOXIC,PBMoves::SUCKERPUNCH,PBMoves::WONDERROOM],
		:Height => 7,
		:Weight => 420,
		:GetEvo => [[429,7,15]]
	}
},
        
PBSpecies::MISMAGIUS => {
	:FormName => {1 => "Aevian"},

	"Aevian" => {
		:DexEntry => "A gentle but misleadingly strong Pokémon, it helps those who got lost in the wetlands find their way out... At the cost of a little of their life force.",
		:Type1 => PBTypes::GRASS,
		:Type2 => PBTypes::GHOST,
		:BaseStats => [60,105,60,105,105,60],
		:Ability => [PBAbilities::MAGICBOUNCE,PBAbilities::POISONPOINT,PBAbilities::TANGLINGHAIR],
		:Movelist => [[1,PBMoves::POISONJAB],[1,PBMoves::POWERGEM],[1,PBMoves::PHANTOMFORCE],[1,PBMoves::LUCKYCHANT],[1,PBMoves::MAGICALLEAF],[1,PBMoves::GROWL],[1,PBMoves::VINEWHIP],[1,PBMoves::POISONPOWDER],[1,PBMoves::ASTONISH],[0,PBMoves::SHADOWCLAW]],
		:Weight => 10
	}
},
###################### Mega Evolutions ######################

PBSpecies::KYOGRE => {
	:FormName => {1 => "Primal"},

	"Primal" => {
		:BaseStats => [100,150,90,90,180,160],
		:Ability => PBAbilities::PRIMORDIALSEA,
		:Height => 98,
		:Weight => 4300
	}
},

PBSpecies::GROUDON => {
	:FormName => {1 => "Primal"},

	"Primal" => {
		:BaseStats => [100,180,160,90,150,90],
		:Ability => PBAbilities::DESOLATELAND,
		:Height => 50,
		:Weight => 9997,
		:Type2 => PBTypes::FIRE
	}
},

PBSpecies::VENUSAUR => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [80,100,123,80,122,120],
		:Ability => PBAbilities::THICKFAT,
		:Height => 24,
		:Weight => 1555
	}
},

PBSpecies::CHARIZARD => {
	:FormName => {
		2 => "Mega Y",
		1 => "Mega X"
	},
	:DefaultForm => 0,
  	:MegaForm => {
		PBItems::CHARIZARDITEY => 2,
		PBItems::CHARIZARDITEX => 1
	},

	"Mega Y" => {
		:BaseStats => [78,104,78,100,159,115],
		:Ability => PBAbilities::DROUGHT,
		:Weight => 1005
	},

	"Mega X" => {
		:BaseStats => [78,130,111,100,130,85],
		:Ability => PBAbilities::TOUGHCLAWS,
		:Weight => 1105,
		:Type2 => PBTypes::DRAGON
	}
},

PBSpecies::BLASTOISE => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [79,103,120,78,135,115],
		:Ability => PBAbilities::MEGALAUNCHER,
		:Weight => 1011
	}
},

PBSpecies::ALAKAZAM => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [55,50,65,150,175,105],
		:Ability => PBAbilities::TRACE,
		:Weight => 480
	}
},

PBSpecies::GENGAR => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [60,65,80,130,170,95],
		:Ability => PBAbilities::SHADOWTAG,
		:Weight => 405
	}
},

PBSpecies::KANGASKHAN => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [105,125,100,100,60,100],
		:Ability => PBAbilities::PARENTALBOND,
		:Weight => 1000
	}
},

PBSpecies::PINSIR => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [65,155,120,105,65,90],
		:Ability => PBAbilities::AERILATE,
		:Weight => 590,
		:Type2 => PBTypes::FLYING
	}
},

PBSpecies::GYARADOS => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [95,155,109,81,70,130],
		:Ability => PBAbilities::MOLDBREAKER,
		:Weight => 3050,
		:Type2 => PBTypes::DARK
	}
},

PBSpecies::AERODACTYL => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [80,135,85,150,70,95],
		:Ability => PBAbilities::TOUGHCLAWS,
		:Weight => 1270
	}
},

PBSpecies::MEWTWO => {
	:FormName => {
		1 => "Mega X",
		2 => "Mega Y"
	},
	:DefaultForm => 0,
  	:MegaForm => {
		PBItems::MEWTWONITEX => 1,
		PBItems::MEWTWONITEY => 2
	},

	"Mega X" => {
		:BaseStats => [106,190,100,130,154,100],
		:Ability => PBAbilities::STEADFAST,
		:Weight => 1105,
		:Type2 => PBTypes::FIGHTING
	},

	"Mega Y" => {
		:BaseStats => [106,150,70,140,194,120],
		:Ability => PBAbilities::INSOMNIA,
		:Weight => 330
	}
},

PBSpecies::AMPHAROS => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [90,95,105,45,165,110],
		:Ability => PBAbilities::MOLDBREAKER,
		:Weight => 615,
		:Type2 => PBTypes::DRAGON
	}
},

PBSpecies::SCIZOR => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [70,150,140,75,65,100],
		:Ability => PBAbilities::TECHNICIAN,
		:Weight => 1250
	}
},

PBSpecies::HERACROSS => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [80,185,115,75,40,105],
		:Ability => PBAbilities::SKILLLINK,
		:Weight => 625
	}
},

PBSpecies::HOUNDOOM => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [75,90,90,115,140,90],
		:Ability => PBAbilities::SOLARPOWER,
		:Weight => 495
	}
},

PBSpecies::TYRANITAR => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [100,164,150,71,95,120],
		:Ability => PBAbilities::SANDSTREAM,
		:Weight => 2550
	}
},

PBSpecies::BLAZIKEN => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [80,160,80,100,130,80],
		:Ability => PBAbilities::SPEEDBOOST,
		:Weight => 520
	}
},

PBSpecies::GARDEVOIR => {
	:FormName => {
		1 => "Mega",
		2 => "Rift"
	},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [68,85,65,100,165,135],
		:Ability => PBAbilities::PIXILATE,
		:Weight => 484
	},

	"Rift" => {
		:BaseStats => [100,130,90,110,175,145],
		#:Ability => PBAbilities::DUSKILATE,
		:Weight => 484,
		:Type1 => PBTypes::DARK
	}
},

PBSpecies::MAWILE => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [50,105,125,50,55,95],
		:Ability => PBAbilities::HUGEPOWER,
		:Weight => 235
	}
},

PBSpecies::AGGRON => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [70,140,230,50,60,80],
		:Ability => PBAbilities::FILTER,
		:Weight => 3950,
		:Type2 => PBTypes::STEEL
	}
},

PBSpecies::MEDICHAM => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [60,100,85,100,80,85],
		:Ability => PBAbilities::PUREPOWER,
		:Weight => 315
	}
},

PBSpecies::MANECTRIC => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [70,75,80,135,135,80],
		:Ability => PBAbilities::INTIMIDATE,
		:Weight => 440
	}
},

PBSpecies::BANETTE => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [64,165,75,75,93,83],
		:Ability => PBAbilities::PRANKSTER,
		:Weight => 130
	}
},

PBSpecies::ABSOL => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [65,150,60,115,115,60],
		:Ability => PBAbilities::MAGICBOUNCE,
		:Weight => 490
	}
},

PBSpecies::GARCHOMP => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [108,170,115,92,120,95],
		:Ability => PBAbilities::SANDFORCE,
		:Weight => 950
	}
},

PBSpecies::LUCARIO => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [70,145,88,112,140,70],
		:Ability => PBAbilities::ADAPTABILITY,
		:Weight => 575
	}
},

PBSpecies::ABOMASNOW => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [90,132,105,30,132,105],
		:Ability => PBAbilities::SNOWWARNING,
		:Weight => 1850
	}
},

PBSpecies::BEEDRILL => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [65,150,40,145,15,80],
		:Ability => PBAbilities::ADAPTABILITY,
		:Height => 14,
		:Weight => 405
	}
},

PBSpecies::PIDGEOT => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [83,80,80,121,135,80],
		:Ability => PBAbilities::NOGUARD,
		:Height => 22,
		:Weight => 505
	}
},

PBSpecies::SLOWBRO => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [95,75,180,30,130,80],
		:Ability => PBAbilities::SHELLARMOR,
		:Height => 20,
		:Weight => 1200
	}
},

PBSpecies::STEELIX => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [75,125,230,30,55,95],
		:Ability => PBAbilities::SANDFORCE,
		:Height => 105,
		:Weight => 7400
	}
},

PBSpecies::SWAMPERT => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [100,150,110,70,85,110],
		:Ability => PBAbilities::SWIFTSWIM,
		:Height => 19,
		:Weight => 1020
	}
},

PBSpecies::SCEPTILE => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [70,110,75,145,145,85],
		:Ability => PBAbilities::LIGHTNINGROD,
		:Height => 19,
		:Weight => 1020,
		:Type2 => PBTypes::DRAGON
	}
},

PBSpecies::SABLEYE => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [50,85,125,20,85,115],
		:Ability => PBAbilities::MAGICBOUNCE,
		:Height => 5,
		:Weight => 1610
	}
},

PBSpecies::SHARPEDO => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [70,140,70,105,110,65],
		:Ability => PBAbilities::STRONGJAW,
		:Height => 25,
		:Weight => 1303
	}
},

PBSpecies::CAMERUPT => {
	:FormName => {
		1 => "Mega",
		2 => "PULSE"
	},
	:DefaultForm => 0,
	:MegaForm => 1,
	:PulseForm => 2,

	"Mega" => {
		:BaseStats => [70,120,100,20,145,105],
		:Ability => PBAbilities::SHEERFORCE,
		:Height => 25,
		:Weight => 3205
	},

	"PULSE" => {
		:BaseStats => [1,10,10,10,170,10],
		:Ability => PBAbilities::STURDY,
		:Weight => 2707,
		:Type2 => PBTypes::GHOST
	}
},

PBSpecies::ALTARIA => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [75,110,110,80,110,105],
		:Ability => PBAbilities::PIXILATE,
		:Height => 15,
		:Weight => 2060,
		:Type2 => PBTypes::FAIRY
	}
},

PBSpecies::GLALIE => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [80,120,80,100,120,80],
		:Ability => PBAbilities::REFRIGERATE,
		:Height => 21,
		:Weight => 3502
	}
},

PBSpecies::SALAMENCE => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [95,145,130,120,120,90],
		:Ability => PBAbilities::AERILATE,
		:Height => 18,
		:Weight => 1125
	}
},

PBSpecies::METAGROSS => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [80,145,150,110,105,110],
		:Ability => PBAbilities::TOUGHCLAWS,
		:Height => 25,
		:Weight => 9429
	}
},

PBSpecies::LATIAS => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [80,100,120,110,140,150],
		:Height => 18,
		:Weight => 520
	}
},

PBSpecies::LATIOS => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [80,130,100,110,160,120],
		:Height => 23,
		:Weight => 700
	}
},

PBSpecies::RAYQUAZA => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [105,180,100,115,180,100],
		:Ability => PBAbilities::DELTASTREAM,
		:Height => 108,
		:Weight => 3920
	}
},

PBSpecies::LOPUNNY => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [65,136,94,135,54,96],
		:Ability => PBAbilities::SCRAPPY,
		:Height => 13,
		:Weight => 283,
		:Type2 => PBTypes::FIGHTING
	}
},

PBSpecies::GALLADE => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [68,165,95,110,65,115],
		:Ability => PBAbilities::INNERFOCUS,
		:Height => 16,
		:Weight => 564
	}
},

PBSpecies::AUDINO => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [103,60,126,50,80,126],
		:Ability => PBAbilities::HEALER,
		:Height => 16,
		:Weight => 564,
		:Type2 => PBTypes::FAIRY
	}
},

PBSpecies::DIANCIE => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [50,160,110,110,160,110],
		:Ability => PBAbilities::MAGICBOUNCE,
		:Height => 11,
		:Weight => 278
	}
},



###################### PULSE Forms ######################

PBSpecies::GARBODOR => {
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :PulseForm => 1,
  
	"Mega" => {
		:BaseStats => [80,135,107,85,60,107],
		:Ability => PBAbilities::GOOEY,
		:Height => 6033,
		:Weight => 2366
	}
},

PBSpecies::TANGROWTH => {
	:FormName => {
		1 => "PULSE C",
		2 => "PULSE B",
		3 => "PULSE A"
	},

  	:PulseForm => 1,

	"PULSE C" => {
		:BaseStats => [100,70,200,10,70,160],
		:Ability => PBAbilities::FILTER,
		:Weight => 2675,
		:Type2 => PBTypes::POISON
	},

	"PULSE B" => {
		:BaseStats => [100,70,200,10,70,160],
		:Ability => PBAbilities::ARENATRAP,
		:Weight => 2675,
		:Type2 => PBTypes::GROUND
	},

	"PULSE A" => {
		:BaseStats => [100,70,200,10,70,160],
		:Ability => PBAbilities::STAMINA,
		:Weight => 2675,
		:Type2 => PBTypes::ROCK
	}
},

PBSpecies::ABRA => {
	:FormName => {
		1 => "PULSE",
		2 => "PULSE"},
  :PulseForm => 1,

	"PULSE" => {
		:BaseStats => [25,20,115,140,195,155],
		:Ability => PBAbilities::MAGICGUARD,
		:Weight => 862,
		:Type2 => PBTypes::STEEL
	}
},

PBSpecies::AVALUGG => {
	:FormName => {1 => "PULSE"},
  :PulseForm => 1,

	"PULSE" => {
		:BaseStats => [105,160,255,10,97,255],
		:Ability => PBAbilities::SOLIDROCK,
		:Weight => 8780
	}
},

PBSpecies::SWALOT => {
	:FormName => {1 => "PULSE"},
  :PulseForm => 1,

	"PULSE" => {
		:BaseStats => [100,73,210,40,110,210],
		:Ability => PBAbilities::WATERABSORB,
		:Weight => 4621,
		:Type2 => PBTypes::WATER
	}
},

PBSpecies::MAGNEZONE => {
	:FormName => {1 => "PULSE"},
  :PulseForm => 1,

	"PULSE" => {
		:BaseStats => [70,70,160,70,230,140],
		:Ability => PBAbilities::LEVITATE,
		:Weight => 1673
	}
},

PBSpecies::HYPNO => {
	:FormName => {1 => "PULSE"},
  :PulseForm => 1,

	"PULSE" => {
		:BaseStats => [120,65,190,80,125,225],
		:Ability => PBAbilities::NOGUARD,
		:Weight => 208,
		:Type2 => PBTypes::DARK
	}
},

PBSpecies::CLAWITZER => {
	:FormName => {1 => "PULSE"},
  :PulseForm => 1,

	"PULSE" => {
		:BaseStats => [252,1,60,252,120,70],
		:Ability => PBAbilities::CONTRARY,
		:Weight => 573,
		:Type2 => PBTypes::DRAGON
	}
},

PBSpecies::MRMIME => {
	:FormName => {1 => "PULSE"},
  :PulseForm => 1,

	"PULSE" => {
		:BaseStats => [252,1,190,252,1,190],
		:Ability => PBAbilities::WONDERGUARD,
		:Weight => 483,
		:Type1 => PBTypes::DARK,
		:Type2 => PBTypes::GHOST
	}
},

PBSpecies::ARCEUS => {
	:FormName => {
		19 => "PULSE",
		20 => "PULSE",
		21 => "PULSE",
		22 => "PULSE",
		23 => "PULSE",
		24 => "PULSE",
		25 => "PULSE",
		26 => "PULSE",
		27 => "PULSE",
		28 => "PULSE",
		29 => "PULSE",
		30 => "PULSE",
		31 => "PULSE",
		32 => "PULSE",
		33 => "PULSE",
		34 => "PULSE",
		35 => "PULSE",
		36 => "PULSE",
		37 => "PULSE"},
  :PulseForm => 19,

	"PULSE" => {
		:BaseStats => [255,125,155,160,125,155],
		:Weight => 9084,
	}
},

###################### Misc Forms ######################


PBSpecies::KECLEON => {
	:FormName => {1 => "Purple"},

	"Purple" => {
		:BaseStats => [130,120,90,95,60,130]
	}
},

PBSpecies::BRELOOM => {
	:FormName => {1 => "Bot"},

	"Bot" => {
		:BaseStats => [210,160,140,100,60,100],
		:Weight => 5328,
		:Type1 => PBTypes::STEEL
	}
},

###################### Deso Megas ################################

PBSpecies::MIGHTYENA =>{
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [70,125,70,125,60,70],
		:Ability => PBAbilities::STRONGJAW,
		:Type2 => PBTypes::GHOST
	}
},

PBSpecies::DARKRAI =>{
	:FormName => {1 => "Perfection"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [70,90,95,170,165,100],
		:Ability => PBAbilities::BADDREAMS,
		:Type2 => PBTypes::GHOST,
		:Weight => 1011
	}
},

PBSpecies::TOXICROAK =>{
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [83,136,70,115,116,70],
		:Ability => PBAbilities::ADAPTABILITY
	}
},

PBSpecies::CINCCINO=>{
	:FormName => {1 => "Mega"},
	:DefaultForm => 0,
  	:MegaForm => 1,

	"Mega" => {
		:BaseStats => [75,125,110,135,40,80],
		:Type2 => PBTypes::FAIRY,
		:Ability => PBAbilities::SKILLLINK
	}
},

PBSpecies::UMBREON=>{
	:FormName => {1 => "Perfection"},
	:DefaultForm => 0,
  :MegaForm => 1,

	"Mega" => {
		:BaseStats => [95,75,130,75,120,130],
		:Type2 => PBTypes::PSYCHIC,
		:Ability => PBAbilities::MAGICBOUNCE
	}
},

###################### Developer Team Forms ######################


PBSpecies::GLACEON => {
	:FormName => {1 => "Mismageon"},

	"Mismageon" => {
		:BaseStats => [65,60,110,105,130,105],
		:Type2 => PBTypes::GHOST
	}
},

PBSpecies::CINCCINO => {
	:FormName => {1 => "Meech"},

	"Meech" => {
		:BaseStats => [75,125,110,135,40,80],
		:Type2 => PBTypes::FAIRY,
		:Ability => PBAbilities::SKILLLINK
	}
},


PBSpecies::LILLIGANT => {
	:FormName => {1 => "Dev"},

	"Dev" => {
		:Ability => PBAbilities::SIMPLE
	}
},


PBSpecies::DEDENNE => {
	:FormName => {1 => "Dev"},

	"Dev" => {
		:Ability => PBAbilities::SIMPLE
	}
},


PBSpecies::SMEARGLE => {
	:FormName => {1 => "Dev"},

	"Dev" => {
		:Ability => PBAbilities::PRANKSTER
	}
},


PBSpecies::MARSHADOW => {
	:FormName => {1 => "Dev"},

	"Dev" => {
		:Ability => PBAbilities::SIMPLE
	}
},

PBSpecies::SILVALLY => {
	:FormName => {19 => "Dev"},

	"Dev" => {
		:Type1 => PBTypes::STEEL,
		:Type2 => PBTypes::STEEL,
		:Ability => PBAbilities::INTIMIDATE
	}
}
}

for form in FormCopy
	PokemonForms[form[1]] = PokemonForms[form[0]].clone
end