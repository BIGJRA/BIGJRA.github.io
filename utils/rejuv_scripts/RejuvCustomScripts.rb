########## Raid battles - START ##########
# key => [level, form, shininess, [moveset], ability, [IV set], [EV set]]

# shininess: < 0 forced non-shiny, >= 1 forced shiny, 0 default, 0.01 to 0.99 chance-based
# empty move list means: use default move list
# ability value of -1 means: use default alloted ability
# non-6 element IV list means: use default/automatic IVs
# non-6 element EV list means: use default/automatic EVs
def GetRaidInfo(key) #Den 1 Common
  info = {"0_GRAVELER"    =>  [35, 0, 0, [], -1, [], []],
          "0_GRAVELER"    =>  [37, 0, 0, [], -1, [], []],
          "0_NUZLEAF"     =>  [35, 0, 0, [], -1, [], []],
          "0_NUZLEAF"     =>  [36, 0, 0, [], -1, [], []],
          "0_SOLOSIS"     =>  [30, 0, 0, [], -1, [], []],
          "0_TROPIUS"     =>  [35, 0, 0, [], -1, [], []],
 # Amber Upgrade
          "1_GRAVELER"   =>  [48, 0, 0, [], -1, [], []],
          "1_GRAVELER"    =>  [50, 0, 0, [], -1, [], []],
          "1_NUZLEAF"     =>  [51, 0, 0, [], -1, [], []],
          "1_DUOSION"     =>  [52, 0, 0, [], -1, [], []],
          "1_SOLOSIS"     =>  [45, 0, 0, [], -1, [], []],
          "1_TROPIUS"     =>  [50, 0, 0, [], -1, [], []],
          "1_SIGILYPH"    =>  [52, 0, 0, [], -1, [], []],
          "1_DHELMISE"    =>  [50, 0, 0, [], -1, [], []],
 # Souta Update
          "2_ROCKRUFF"    =>  [74, 0, 0, [], -1, [], []],
          "2_ROCKRUFF"    =>  [76, 0, 0, [], -1, [], []],
          "2_SHIFTRY"     =>  [75, 0, 0, [], -1, [], []],
          "2_REUNICLUS"   =>  [75, 0, 0, [], -1, [], []],
          "2_SOLOSIS"     =>  [45, 0, 0, [], -1, [], []],
          "2_TROPIUS"     =>  [50, 0, 0, [], -1, [], []],
          "2_SIGILYPH"    =>  [52, 0, 0, [], -1, [], []],
          "2_DHELMISE"    =>  [50, 0, 0, [], -1, [], []],
 # Alice/Allen Update
          "3_ROCKRUFF"    =>  [74, 0, 0, [], -1, [], []],
          "3_ROCKRUFF"    =>  [76, 0, 0, [], -1, [], []],
          "3_SHIFTRY"     =>  [75, 0, 0, [], -1, [], []],
          "3_REUNICLUS"   =>  [75, 0, 0, [], -1, [], []],
          "3_SOLOSIS"     =>  [45, 0, 0, [], -1, [], []],
          "3_TROPIUS"     =>  [50, 0, 0, [], -1, [], []],
          "3_SIGILYPH"    =>  [52, 0, 0, [], -1, [], []],
          "3_DHELMISE"    =>  [50, 0, 0, [], -1, [], []],
 # Post Game
          "4_ROCKRUFF"    =>  [74, 0, 0, [], -1, [], []],
          "4_ROCKRUFF"    =>  [76, 0, 0, [], -1, [], []],
          "4_SHIFTRY"     =>  [75, 0, 0, [], -1, [], []],
          "4_REUNICLUS"   =>  [75, 0, 0, [], -1, [], []],
          "4_SOLOSIS"     =>  [45, 0, 0, [], -1, [], []],
          "4_TROPIUS"     =>  [50, 0, 0, [], -1, [], []],
          "4_SIGILYPH"    =>  [52, 0, 0, [], -1, [], []],
          "4_DHELMISE"    =>  [50, 0, 0, [], -1, [], []],
# Rare Den 1=================================================================================
          "5_FINNEON"     =>  [35, 0,  0.15, [:TAILGLOW,:WATERPULSE,:AQUARING,:CHARM], 2, [], []],
          "5_BONSLY"      =>  [30, 0,  0.15, [:SHIFTGEAR,:ROCKSLIDE,:MIMIC,:SELFDESTRUCT], 2, [], []],
          "5_MEOWTH"      =>  [37, 0,  0.15, [:GLARE,:FOULPLAY,:PAYDAY,:FLATTER], 2, [], []],
# Amber Upgrade
          "6_RELICANTH"   =>  [52, 0, 0.15, [:WILDCHARGE,:SURF,:HEADSMASH,:ROCKPOLISH], 2, [], []],
          "6_PERSIAN"     =>  [54, 0, 0.15, [:GLARE,:FURYSWIPES,:PAYDAY,:GROWL], 2, [], []],
          "6_LUMINEON"    =>  [55, 0, 0.15, [:TAILGLOW,:SURF,:AQUARING,:CHARM], 2, [], []],
          "6_BONSLY"      =>  [30, 0, 0.15, [:SHIFTGEAR,:ROCKSLIDE,:MIMIC,:SELFDESTRUCT], 2, [], []],
# Souta Upgrade
          "7_RELICANTH"   =>  [74, 0, 0.15, [:WILDCHARGE,:SURF,:HEADSMASH,:ROCKPOLISH], 2, [], []],
          "7_PERSIAN"     =>  [75, 0, 0.15, [:GLARE,:FURYSWIPES,:PAYDAY,:GROWL], 2, [], []],
          "7_LUMINEON"    =>  [75, 0, 0.15, [:TAILGLOW,:SURF,:AQUARING,:CHARM], 2, [], []],
          "7_SUDOWOODO"   =>  [76, 0, 0.15, [:SHIFTGEAR,:ROCKSLIDE,:MIMIC,:SELFDESTRUCT], 2, [], []],
          "7_LANTURN"     =>  [74, 0, 0.15, [:COSMICPOWER,:THUNDER,:SCALD,:THUNDERWAVE], 2, [], []],
# Alice/Allen Upgrade
          "8_RELICANTH"   =>  [74, 0, 0.15, [], 2, [], []],
          "8_PERSIAN"     =>  [75, 0, 0.15, [], 2, [], []],
          "8_LUMINEON"    =>  [75, 0, 0.15, [], 2, [], []],
          "8_SUDOWOODO"   =>  [76, 0, 0.15, [], 2, [], []],
          "8_LANTURN"     =>  [74, 0, 0.15, [], 2, [], []],
# Post Game upgrade
          "9_RELICANTH"   =>  [74, 0, 0.15, [], 2, [], []],
          "9_PERSIAN"     =>  [75, 0, 0.15, [], 2, [], []],
          "9_LUMINEON"    =>  [75, 0, 0.15, [], 2, [], []],
          "9_SUDOWOODO"   =>  [76, 0, 0.15, [], 2, [], []],
          "9_CHINCHOU"    =>  [74, 0, 0.15, [], 2, [], []],
  # DEN 2 COMMON DEN
          "10_TRANQUILL"   =>  [35, 0, 0, [], -1, [], []],
          "10_TRANQUILL"   =>  [37, 0, 0, [], -1, [], []],
          "10_WAILMER"     =>  [35, 0, 0, [], -1, [], []],
          "10_DUNSPARCE"   =>  [36, 0, 0, [], -1, [], []],
          "10_VULLABY"     =>  [30, 0, 0, [], -1, [], []],
# Amber Upgrade
          "11_UNFEZANT"    =>  [48, 0, 0, [], -1, [], []],
          "11_UNFEZANT"    =>  [52, 0, 0, [], -1, [], []],
          "11_WAILMER"     =>  [53, 0, 0, [], -1, [], []],
          "11_DUNSPARCE"   =>  [55, 0, 0, [], -1, [], []],
          "11_VULLABY"     =>  [52, 0, 0, [], -1, [], []],
          "11_MASQUERAIN"  =>  [53, 0, 0, [:DISCHARGE,:SHADOWBALL,:QUIVERDANCE,:WHIRLWIND], -1, [], []],
          "11_QUAGSIRE"    =>  [35, 0, 0, [:FLAMEBURST,:RECOVER,:POWERUPPUNCH,:ACIDSPRAY], -1, [], []],
# Souta Upgrade
          "12_UNFEZANT"    =>  [71, 0, 0, [], -1, [], []],
          "12_UNFEZANT"    =>  [72, 0, 0, [], -1, [], []],
          "12_WAILORD"     =>  [74, 0, 0, [], -1, [], []],
          "12_DUNSPARCE"   =>  [73, 0, 0, [], -1, [], []],
          "12_MANDIBUZZ"   =>  [73, 0, 0, [], -1, [], []],
          "12_MASQUERAIN"  =>  [74, 0, 0, [:DISCHARGE,:SHADOWBALL,:QUIVERDANCE,:WHIRLWIND], -1, [], []],
          "12_QUAGSIRE"    =>  [75, 0, 0, [:FLAMEBURST,:RECOVER,:POWERUPPUNCH,:ACIDSPRAY], -1, [], []],
          "12_TOGEDEMARU"  =>  [75, 0, 0, [], -1, [], []],
# Alice/Allen Upgrade
          "13_UNFEZANT"    =>  [71, 0, 0, [], -1, [], []],
          "13_UNFEZANT"    =>  [72, 0, 0, [], -1, [], []],
          "13_WAILORD"     =>  [74, 0, 0, [], -1, [], []],
          "13_DUNSPARCE"   =>  [73, 0, 0, [], -1, [], []],
          "13_MANDIBUZZ"   =>  [73, 0, 0, [], -1, [], []],
          "13_MASQUERAIN"  =>  [74, 0, 0, [:DISCHARGE,:SHADOWBALL,:QUIVERDANCE,:WHIRLWIND], -1, [], []],
          "13_QUAGSIRE"    =>  [75, 0, 0, [:FLAMEBURST,:RECOVER,:POWERUPPUNCH,:ACIDSPRAY], -1, [], []],
          "13_TOGEDEMARU"  =>  [75, 0, 0, [], -1, [], []],
# Post Game Upgrade
          "14_UNFEZANT"    =>  [71, 0, 0, [], -1, [], []],
          "14_UNFEZANT"    =>  [72, 0, 0, [], -1, [], []],
          "14_WAILORD"     =>  [74, 0, 0, [], -1, [], []],
          "14_DUNSPARCE"   =>  [73, 0, 0, [], -1, [], []],
          "14_MANDIBUZZ"   =>  [73, 0, 0, [], -1, [], []],
          "14_MASQUERAIN"  =>  [74, 0, 0, [:DISCHARGE,:SHADOWBALL,:QUIVERDANCE,:WHIRLWIND], -1, [], []],
          "14_QUAGSIRE"    =>  [75, 0, 0, [:FLAMEBURST,:RECOVER,:POWERUPPUNCH,:ACIDSPRAY], -1, [], []],
          "14_TOGEDEMARU"  =>  [75, 0, 0, [], -1, [], []],
# DEN 2 RARE DENS
          "15_CHATOT"      =>  [34, 0, 0.15, [], -1, [], []],
          "15_SNORUNT"     =>  [35, 0, 0.15, [:SHADOWSNEAK,:ICEBEAM,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "15_SNORUNT"     =>  [33, 0, 0.15, [:SHADOWSNEAK,:ICYWIND,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "15_CACNEA"      =>  [35, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:FELLSTINGER,:POWERUPPUNCH], -1, [], []],
          "15_CACNEA"      =>  [31, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:MAGICALLEAF,:POWERUPPUNCH], -1, [], []],
# Amber Upgrade
          "16_CHATOT"      =>  [54, 0, 0.15, [], -1, [], []],
          "16_CHATOT"      =>  [52, 0, 0.15, [], -1, [], []],
          "16_SNORUNT"     =>  [55, 0, 0.15, [:SHADOWSNEAK,:ICEBEAM,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "16_GLALIE"      =>  [55, 0, 0.15, [:SHADOWSNEAK,:ICYWIND,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "16_CACNEA"      =>  [55, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:FELLSTINGER,:POWERUPPUNCH], -1, [], []],
          "16_CACTURNE"    =>  [51, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:MAGICALLEAF,:POWERUPPUNCH], -1, [], []],
          "16_CLAYDOL"     =>  [54, 0, 0.15, [:FLAMETHROWER,:DAZZLINGGLEAM,:DRILLRUN,:PSYCHIC], -1, [], []],
# Souta Upgrade
          "17_CHATOT"      =>  [74, 0, 0.15, [], -1, [], []],
          "17_SNORUNT"     =>  [75, 0, 0.15, [:SHADOWSNEAK,:ICEBEAM,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "17_GLALIE"      =>  [75, 0, 0.15, [:SHADOWSNEAK,:ICYWIND,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "17_CACNEA"      =>  [75, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:FELLSTINGER,:POWERUPPUNCH], -1, [], []],
          "17_CACTURNE"    =>  [71, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:MAGICALLEAF,:POWERUPPUNCH], -1, [], []],
          "17_CLAYDOL"     =>  [74, 0, 0.15, [:FLAMETHROWER,:DAZZLINGGLEAM,:DRILLRUN,:PSYCHIC], -1, [], []],
          "17_KLEFKI"      =>  [74, 0, 0.15, [], -1, [], []],
          "17_KLEFKI"      =>  [72, 0, 0.15, [], -1, [], []],         
# Alice/Allen Upgrade
          "18_CHATOT"      =>  [74, 0, 0.15, [], -1, [], []],
          "18_SNORUNT"     =>  [75, 0, 0.15, [:SHADOWSNEAK,:ICEBEAM,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "18_GLALIE"      =>  [75, 0, 0.15, [:SHADOWSNEAK,:ICYWIND,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "18_CACNEA"      =>  [75, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:FELLSTINGER,:POWERUPPUNCH], -1, [], []],
          "18_CACTURNE"    =>  [71, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:MAGICALLEAF,:POWERUPPUNCH], -1, [], []],
          "18_CLAYDOL"     =>  [74, 0, 0.15, [:FLAMETHROWER,:DAZZLINGGLEAM,:DRILLRUN,:PSYCHIC], -1, [], []],
          "18_KLEFKI"      =>  [74, 0, 0.15, [], -1, [], []],
          "18_KLEFKI"      =>  [72, 0, 0.15, [], -1, [], []],
# Post Game Upgrade
          "19_CHATOT"      =>  [74, 0, 0.15, [], -1, [], []],
          "19_SNORUNT"     =>  [75, 0, 0.15, [:SHADOWSNEAK,:ICEBEAM,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "19_GLALIE"      =>  [75, 0, 0.15, [:SHADOWSNEAK,:ICYWIND,:ROLLOUT,:NATUREPOWER], -1, [], []],
          "19_CACNEA"      =>  [75, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:FELLSTINGER,:POWERUPPUNCH], -1, [], []],
          "19_CACTURNE"    =>  [71, 0, 0.15, [:TOXCISPIKES,:GRASSWHISTLE,:MAGICALLEAF,:POWERUPPUNCH], -1, [], []],
          "19_CLAYDOL"     =>  [74, 0, 0.15, [:FLAMETHROWER,:DAZZLINGGLEAM,:DRILLRUN,:PSYCHIC], -1, [], []],
          "19_KLEFKI"      =>  [74, 0, 0.15, [], -1, [], []],
          "19_KLEFKI"      =>  [72, 0, 0.15, [], -1, [], []],
  # DEN 3 ADVENTURER'S CLIFFSIDE=========================================================================================================================
          "20_HERDIER"     =>  [34, 0, 0, [], -1, [], []],
          "20_HERDIER"     =>  [32, 0, 0, [], -1, [], []],
          "20_CRABRAWLER"  =>  [34, 0, 0, [], -1, [], []],
          "20_PACHIRISU"   =>  [34, 0, 0, [], -1, [], []],
          "20_CHIMECHO"     => [36, 0, 0, [], -1, [], []],
# Amber Upgrade
          "21_STOUTLAND"   =>  [54, 0, 0, [], -1, [], []],
          "21_STOUTLAND"   =>  [52, 0, 0, [], -1, [], []],
          "21_CRABRAWLER"  =>  [54, 0, 0, [], -1, [], []],
          "21_PACHIRISU"   =>  [54, 0, 0, [], -1, [], []],
          "21_CHIMECHO"    =>  [56, 0, 0, [], -1, [], []],
          "21_STUNFISK"    =>  [52, 1, 0, [:YAWN,:SNAPTRAP,:THUNDERWAVE,:COUNTER], -1, [], []],
          "21_ABRA"        =>  [20, 0, 0, [:ENCORE,:PSYCHICTERRAIN,:BARRIER,:PSYCHOSHIFT], -1, [], []],
# Souta Upgrade
          "22_STOUTLAND"   =>  [74, 0, 0, [], -1, [], []],
          "22_STOUTLAND"   =>  [72, 0, 0, [], -1, [], []],
          "22_CRABRAWLER"  =>  [74, 0, 0, [], -1, [], []],
          "22_PACHIRISU"   =>  [74, 0, 0, [], -1, [], []],
          "22_CHIMECHO"    =>  [76, 0, 0, [], -1, [], []],
          "22_STUNFISK"    =>  [72, 1, 0, [:YAWN,:SNAPTRAP,:THUNDERWAVE,:COUNTER], -1, [], []],
          "22_KADABRA"     =>  [50, 0, 0, [], -1, [], []],
          "22_KADABRA"     =>  [50, 0, 0, [], -1, [], []],
          "22_MANKEY"     =>   [50, 0, 0, [:EXPLOSION,:BRICKBREAK,:CLOSECOMBAT,:PROTECT], -1, [], []],
          "22_MANKEY"     =>   [50, 0, 0, [:EXPLOSION,:BRICKBREAK,:CLOSECOMBAT,:PROTECT], -1, [], []],
# Alice/allen Upgrade
          "23_STOUTLAND"   =>  [74, 0, 0, [], -1, [], []],
          "23_STOUTLAND"   =>  [72, 0, 0, [], -1, [], []],
          "23_CRABRAWLER"  =>  [74, 0, 0, [], -1, [], []],
          "22_PACHIRISU"   =>  [74, 0, 0, [], -1, [], []],
          "23_CHIMECHO"    =>  [76, 0, 0, [], -1, [], []],
          "23_STUNFISK"    =>  [72, 1, 0, [:YAWN,:SNAPTRAP,:THUNDERWAVE,:COUNTER], -1, [], []],
          "23_KADABRA"     =>  [50, 0, 0, [], -1, [], []],
# Post Game Upgrade
          "24_STOUTLAND"   =>  [74, 0, 0, [], -1, [], []],
          "24_STOUTLAND"   =>  [72, 0, 0, [], -1, [], []],
          "24_CRABRAWLER"  =>  [74, 0, 0, [], -1, [], []],
          "24_PACHIRISU"   =>  [74, 0, 0, [], -1, [], []],
          "24_CHIMECHO"    =>  [76, 0, 0, [], -1, [], []],
          "24_STUNFISK"    =>  [72, 1, 0, [:YAWN,:SNAPTRAP,:THUNDERWAVE,:COUNTER], 2, [], []],
          "24_KADABRA"     =>  [50, 0, 0, [], -1, [], []],
# Rare Den 3
          "25_RHYHORN"     =>  [34, 0, 0.15, [], 2, [], []],
          "25_VANILLITE"   =>  [32, 0, 0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "25_VANILLITE"   =>  [34, 0, 0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "25_PURUGLY"     =>  [34, 0, 0.15, [:THRASH,:SWAGGER,:REST,:BULLDOZE], 2, [], []],
# Amber Upgrade
          "26_RHYDON"      =>  [54, 0,  0.15, [], -1, [], []],
          "26_VANILLUXE"   =>  [52, 0,  0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "26_VANILLISH"   =>  [53, 0,  0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "26_PURUGLY"     =>  [54, 0, 0.15, [:THRASH,:SWAGGER,:REST,:BULLDOZE], 2, [], []],
          "26_DITTO"       =>  [54, 0, 0.50, [], -1, [], []],
          "26_TEDDIURSA"   =>  [53, 0, 0.15, [:PARTINGSHOT,:ROCKTOMB,:STRENGTH,:CROSSCHOP], -1, [], []],
# Souta Upgrade
          "27_RHYDON"      =>  [74, 0, 0.15, [], -1, [], []],
          "27_VANILLUXE"   =>  [72, 0, 0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "27_VANILLISH"   =>  [73, 0, 0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "27_PURUGLY"     =>  [74, 0, 0.15, [:THRASH,:SWAGGER,:REST,:BULLDOZE], 2, [], []],
          "27_DITTO"       =>  [74, 0, 0.50, [], -1, [], []],
          "27_DITTO"       =>  [74, 0, 0.50, [], -1, [], []],
          "27_URSARING"   =>  [73, 0, 0.15, [:PARTINGSHOT,:ROCKTOMB,:STRENGTH,:CROSSCHOP], 2, [], []],
# Alice/Allen Upgrade
          "28_RHYDON"      =>  [74, 0, 0.15, [], -1, [], []],
          "28_VANILLUXE"   =>  [72, 0, 0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "28_VANILLISH"   =>  [73, 0, 0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "28_PURUGLY"     =>  [74, 0, 0.15, [:THRASH,:SWAGGER,:REST,:BULLDOZE], 2, [], []],
          "28_DITTO"       =>  [74, 0, 0.50, [], -1, [], []],
          "28_DITTO"       =>  [74, 0, 0.50, [], -1, [], []],
          "28_URSARING"   =>  [73, 0, 0.15, [:PARTINGSHOT,:ROCKTOMB,:STRENGTH,:CROSSCHOP], 2, [], []],
# Post Game Upgrade
          "29_RHYDON"      =>  [74, 0, 0.15, [], -1, [], []],
          "29_VANILLUXE"   =>  [72, 0, 0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "29_VANILLISH"   =>  [73, 0, 0.15, [:WILLOWISP,:ICEBEAM,:ICESHARD,:EXPLOSION], 2, [], []],
          "29_PURUGLY"     =>  [74, 0, 0.15, [:THRASH,:SWAGGER,:REST,:BULLDOZE], 2, [], []],
          "29_DITTO"       =>  [74, 0, 0.50, [], -1, [], []],
          "29_DITTO"       =>  [74, 0, 0.50, [], -1, [], []],
          "29_URSARING"   =>  [73, 0, 0.15, [:PARTINGSHOT,:SWORDSDANCE,:STRENGTH,:CROSSCHOP], 2, [], []],
  # DEN 4=================================================================================================================================
          "30_LOTAD"       =>  [34, 0, 0, [], -1, [], []],
          "30_LOTAD"       =>  [31, 0, 0, [], -1, [], []],
          "30_GASTRODON"   =>  [35, 0, 0, [], -1, [], []],
          "30_GASTRODON"   =>  [35, 0, 0, [], -1, [], []],
          "30_PALPITOAD"   =>  [32, 0, 0, [], -1, [], []], 
# Amber Upgrade
          "31_LOMBRE"      =>  [54, 0, 0, [], -1, [], []],
          "31_LOMBRE"      =>  [51, 0, 0, [], -1, [], []],
          "31_GASTRODON"   =>  [55, 0, 0, [], -1, [], []],
          "31_GASTRODON"   =>  [52, 1, 0, [], -1, [], []],
          "31_SEISMITOAD"  =>  [53, 0, 0, [], -1, [], []], 
# Souta Upgrade
          "32_LOMBRE"      =>  [74, 0, 0, [], -1, [], []],
          "32_LOMBRE"      =>  [71, 0, 0, [], -1, [], []],
          "32_GASTRODON"   =>  [75, 0, 0, [], -1, [], []],
          "32_GASTRODON"   =>  [72, 0, 0, [], -1, [], []],
          "32_SWANNA"      =>  [72, 0, 0, [], -1, [], []],
          "32_SWANNA"      =>  [74, 0, 0, [], -1, [], []],
          "32_SEISMITOAD"  =>  [73, 0, 0, [], -1, [], []], 
# Alice/Allen Upgrade
          "33_LOMBRE"      =>  [74, 0, 0, [], -1, [], []],
          "33_LOMBRE"      =>  [71, 0, 0, [], -1, [], []],
          "33_GASTRODON"   =>  [75, 0, 0, [], -1, [], []],
          "33_GASTRODON"   =>  [72, 0, 0, [], -1, [], []],
          "33_SWANNA"      =>  [72, 0, 0, [], -1, [], []],
          "33_SWANNA"      =>  [74, 0, 0, [], -1, [], []],
          "33_SEISMITOAD"  =>  [73, 0, 0, [], -1, [], []], 
# Post Game
          "34_LOMBRE"      =>  [74, 0, 0, [], -1, [], []],
          "34_LOMBRE"      =>  [71, 0, 0, [], -1, [], []],
          "34_GASTRODON"   =>  [75, 0, 0, [], -1, [], []],
          "34_GASTRODON"   =>  [72, 0, 0, [], -1, [], []],
          "34_SWANNA"      =>  [72, 0, 0, [], -1, [], []],
          "34_SWANNA"      =>  [74, 0, 0, [], -1, [], []],
          "34_SEISMITOAD"  =>  [73, 0, 0, [], -1, [], []], 
# Den 4 Rare Den
          "35_MANTYKE"     =>  [32, 0, 0.15, [], 2, [], []],
          "35_MANTYKE"     =>  [35, 0, 0.15, [], 2, [], []],
          "35_FRILLISH"    =>  [34, 0, 0.15, [:WILLOWISP,:WATERPULSE,:SHADOWBALL,:ATTRACT], 2, [], []],
          "35_FRILLISH"    =>  [34, 1, 0.15, [:WILLOWISP,:WATERPULSE,:SHADOWBALL,:ATTRACT], 2, [], []],
# Amber Upgrade
          "36_MANTYKE"     =>  [52, 0, 0.15, [], -1, [], []],
          "36_MANTINE"     =>  [55, 0, 0.15, [], -1, [], []],
          "36_JELLICENT"   =>  [54, 0, 0.15, [:WILLOWISP,:SURF,:SHADOWBALL,:ATTRACT], 2, [], []],
          "36_JELLICENT"   =>  [74, 0, 0.15, [:WILLOWISP,:SURF,:SHADOWBALL,:ATTRACT], 2, [], []],
          "36_MARILL"      =>  [74, 1, 0.15, [], -1, [], []],
# Souta Upgrade
          "37_MANTINE"     =>  [72, 0, 0.15, [], -1, [], []],
          "37_MANTINE"     =>  [75, 0, 0.15, [], -1, [], []],
          "37_JELLICENT"   =>  [74, 0, 0.15, [:WILLOWISP,:SURF,:SHADOWBALL,:ATTRACT], 2, [], []],
          "37_JELLICENT"   =>  [74, 0, 0.15, [:WILLOWISP,:SURF,:SHADOWBALL,:ATTRACT], 2, [], []],
          "37_TIMBURR"     =>  [74, 0, 0.15, [:MACHPUNCH,:DETECT,:DRAINPUNCH,:ICEPUNCH], 2, [], []],
# Alice/Allen Upgrade
          "38_MANTINE"     =>  [72, 0, 0.15, [], -1, [], []],
          "38_MANTINE"     =>  [75, 0, 0.15, [], -1, [], []],
          "38_JELLICENT"   =>  [74, 0, 0.15, [:WILLOWISP,:SCALD,:SHADOWBALL,:ATTRACT], 2, [], []],
          "38_TIMBURR"     =>  [74, 0, 0.15, [:MACHPUNCH,:DETECT,:DRAINPUNCH,:ICEPUNCH], 2, [], []],
          "38_MARILL"      =>  [74, 1, 0.15, [:IRONHEAD,:PLAYROUGH,:SUPERPOWER,:WATERFALL], 2, [], []],
# Post Game
          "39_MANTINE"     =>  [72, 0, 0.15, [], -1, [], []],
          "39_MANTINE"     =>  [75, 0, 0.15, [], -1, [], []],
          "39_JELLICENT"   =>  [74, 0, 0.15, [:WILLOWISP,:SCALD,:SHADOWBALL,:ATTRACT], 2, [], []],
          "39_JELLICENT"   =>  [74, 0, 0.15, [:WILLOWISP,:SCALD,:SHADOWBALL,:ATTRACT], 2, [], []],
          "39_MARILL"      =>  [74, 0, 0.15, [:IRONHEAD,:PLAYROUGH,:SUPERPOWER,:WATERFALL], 2, [], []],
          "40_BELDUM"      =>  [20, 0, 0, [:GRAVITY,:ZAPCANNON,:IRONHEAD,:LIFEDEW], -1, [], []]
  }
  return info[key]
end
  
def RaidDen(num)  
  # 2-ary array of [mon_name, mon_star]
  raids_mons = [[["GRAVELER",1], ["GRAVELER",1], ["NUZLEAF",1], ["NUZLEAF",1], ["SOLOSIS",1], ["TROPIUS",1]], #0
                [["GRAVELER",2], ["GRAVELER",2], ["NUZLEAF",2], ["DUOSION",2], ["SOLOSIS",1], ["TROPIUS",2],["SIGILYPH",2],["DHELMISE",2]], #1
                [["ROCKRUFF",2], ["ROCKRUFF",2], ["SHIFTRY",3], ["REUNICLUS",3], ["SOLOSIS",2], ["TROPIUS",3],["SIGILYPH",3],["DHELMISE",3]], #2
                [["ROCKRUFF",3], ["ROCKRUFF",3], ["SHIFTRY",4], ["REUNICLUS",4], ["SOLOSIS",4], ["TROPIUS",4],["SIGILYPH",4],["DHELMISE",4]], #3
                [["ROCKRUFF",4], ["ROCKRUFF",4], ["SHIFTRY",4], ["REUNICLUS",5], ["SOLOSIS",4], ["TROPIUS",4],["SIGILYPH",4],["DHELMISE",4]], #4
# Rare Den 1
                [["MEOWTH",2], ["BONSLY",2], ["FINNEON",3]], #5
                [["RELICANTH",3], ["PERSIAN",3], ["LUMINEON",3],["BONSLY",3]], #6
                [["PERSIAN",3], ["PERSIAN",3], ["LUMINEON",3],["SUDOWOODO",3],["LANTURN",3]], #7
                [["PERSIAN",4], ["PERSIAN",4], ["LUMINEON",4],["SUDOWOODO",3],["LANTURN",3]], #8
                [["PERSIAN",5], ["PERSIAN",5], ["LUMINEON",5],["SUDOWOODO",5],["LANTURN",5]], #9
# Den 2 ================================================================================================================================================
                [["TRANQUILL",1], ["TRANQUILL",1], ["WAILMER",1],["DUNSPARCE",1],["VULLABY",2]], #10
                [["UNFEZANT",2], ["UNFEZANT",2], ["WAILMER",2],["DUNSPARCE",2],["VULLABY",2],["MASQUERAIN",2],["QUAGSIRE",2]], #11
                [["UNFEZANT",3], ["UNFEZANT",3], ["WAILORD",3],["DUNSPARCE",3],["MANDIBUZZ",3],["MASQUERAIN",3],["QUAGSIRE",3],["TOGEDEMARU",3]], #12
                [["UNFEZANT",3], ["UNFEZANT",3], ["WAILORD",3],["DUNSPARCE",3],["MANDIBUZZ",3],["MASQUERAIN",3],["QUAGSIRE",3],["TOGEDEMARU",3]], #13
                [["UNFEZANT",3], ["UNFEZANT",3], ["WAILORD",3],["DUNSPARCE",3],["MANDIBUZZ",3],["MASQUERAIN",3],["QUAGSIRE",3],["TOGEDEMARU",3]], #14
# Rare Den 2
                [["CHATOT",1], ["SNORUNT",1], ["SNORUNT",1],["CACNEA",1],["CACNEA",2]], #15
                [["CHATOT",2], ["CHATOT",2], ["SNORUNT",2], ["GLALIE",2],["CACNEA",1],["CACTURNE",2],["CLAYDOL",2]],
                [["CHATOT",3], ["CHATOT",3], ["SNORUNT",2], ["GLALIE",2],["CACNEA",1],["CACTURNE",2],["CLAYDOL",2],["KLEFKI",2],["KLEFKI",2]],
                [["CHATOT",2], ["CHATOT",3], ["SNORUNT",3], ["GLALIE",3],["CACNEA",2],["CACTURNE",3],["CLAYDOL",3],["KLEFKI",3],["KLEFKI",3]],
                [["CHATOT",2], ["CHATOT",3], ["SNORUNT",3], ["GLALIE",3],["CACNEA",2],["CACTURNE",3],["CLAYDOL",3],["KLEFKI",3],["KLEFKI",3]],
# Den 3 ================================================================================================================================================
                [["HERDIER",1], ["HERDIER",1], ["CRABRAWLER",1],["PACHIRISU",1],["CHIMECHO",2]], #20
                [["STOUTLAND",2], ["STOUTLAND",2], ["CRABRAWLER",2],["PACHIRISU",2],["CHIMECHO",2],["STUNFISK",2],["ABRA",2]], #21
                [["STOUTLAND",3], ["STOUTLAND",3], ["CRABRAWLER",3],["PACHIRISU",3],["CHIMECHO",3],["STUNFISK",3],["KADABRA",3],["KADABRA",3],["MANKEY",3],["MANKEY",3]], #22
                [["STOUTLAND",3], ["STOUTLAND",3], ["CRABRAWLER",3],["PACHIRISU",3],["CHIMECHO",3],["STUNFISK",3],["KADABRA",3]], #23
                [["STOUTLAND",3], ["STOUTLAND",3], ["CRABRAWLER",3],["PACHIRISU",3],["CHIMECHO",3],["STUNFISK",3],["KADABRA",3]], #24
# Rare Den 3
                [["RHYHORN",1], ["VANILLITE",1], ["VANILLITE",1],["PURUGLY",1]], #25
                [["RHYDON",2], ["VANILLUXE",2], ["VANILLISH",2],["PURUGLY",2],["DITTO",2],["TEDDIURSA",2]], #26
                [["RHYDON",2], ["VANILLUXE",2], ["VANILLISH",2],["PURUGLY",2],["DITTO",2],["DITTO",2],["URSARING",2]],
                [["RHYDON",2], ["VANILLUXE",2], ["VANILLISH",2],["PURUGLY",2],["DITTO",2],["DITTO",2],["URSARING",2]],
                [["RHYDON",2], ["VANILLUXE",2], ["VANILLISH",2],["PURUGLY",2],["DITTO",2],["DITTO",2],["URSARING",2]],
# Den 4 ================================================================================================================================================
                [["LOTAD",1],  ["LOTAD",1], ["GASTRODON",1],["GASTRODON",1],["PALPITOAD",2]],
                [["LOMBRE",2], ["LOMBRE",2],["GASTRODON",2],["GASTRODON",2],["SEISMITOAD",3]],
                [["LOMBRE",3], ["LOMBRE",3],["GASTRODON",3],["GASTRODON",2],["SWANNA",2],["SWANNA",3],["SEISMITOAD",3]],
                [["LOMBRE",3], ["LOMBRE",3],["GASTRODON",3],["GASTRODON",2],["SWANNA",2],["SWANNA",3],["SEISMITOAD",3]],
                [["LOMBRE",3], ["LOMBRE",3],["GASTRODON",3],["GASTRODON",2],["SWANNA",2],["SWANNA",3],["SEISMITOAD",3]],
# Rare Den 4
                [["MANTYKE",1], ["MANTYKE",1], ["FRILLISH",3],["FRILLISH",1]],
                [["MANTYKE",2], ["MANTINE",3], ["JELLICENT",2],["JELLICENT",2],["MARILL",3]], #36
                [["MANTINE",3], ["MANTINE",3], ["JELLICENT",3],["JELLICENT",3],["TIMBURR",3]], #37
                [["MANTINE",3], ["MANTINE",3], ["JELLICENT",3],["TIMBURR",3],["MARILL",3]],
                [["MANTINE",3], ["MANTINE",3], ["JELLICENT",3],["JELLICENT",3],["MARILL",3]],
                [["BELDUM",5]]]
                
  raid = raids_mons[num]
  mon = raid[rand(raid.length)]
  name = mon[0]
  species = getID(PBSpecies, name)
  key = num.to_s + "_" + name
  star = mon[1]
  info = GetRaidInfo(key)
  level = info[0]
  form = info[1]
  shininess = info[2]
  moves = info[3]
  ability = info[4]
  ivs = info[5]
  evs = info[6]
  if name != "BELDUM"
    if form == 1
      if name == "MEOWTH" || name == "GEODUDE"
        name = "ALOLAN " + name
      else
        name = "GALARIAN " + name
      end
    elsif form == 2
      if name == "MEOWTH"
        name = "GALARIAN " + name
      end
    end
    name += " (" + star.to_s + "-star)"
  end
  Kernel.pbMessage(_INTL("The den contains {1}.",name))

  $game_switches[1305] = true
  variable=$game_variables[100]
  canescape=true
  canlose=false
  askmessage=_INTL("Would you like to fight it?")
  if Kernel.pbConfirmMessage(askmessage)
    handled=[nil]
    Events.onWildBattleOverride.trigger(nil,species,level,handled)
    if handled[0]!=nil
      return handled[0]
    end
    currentlevels=[]
    for i in $Trainer.party
      currentlevels.push([i.personalID,i.level])
    end
    genwildpoke=pbGenerateWildPokemon(species,level)
    if shininess == -1
      genwildpoke.makeNotShiny
    elsif shininess == 1
      genwildpoke.makeShiny
    elsif shininess > 0.0 && shininess < 1.0
      threshold = (shininess * 100).round
      output = rand(100)
      if output >= threshold
        genwildpoke.makeNotShiny
      else
        genwildpoke.makeShiny
      end
    end
    shinyMon = genwildpoke.isShiny?
    genwildpoke.form = form
    if moves.length > 0
      genwildpoke.pbDeleteAllMoves
      for move in moves
        genwildpoke.pbLearnMove(move)
      end
    end
    if ability!=-1
      genwildpoke.setAbility(ability)
    end
    if ivs.length==6
      genwildpoke.iv = ivs
    end
    if evs.length==6
      genwildpoke.ev = evs
    end
    items=genwildpoke.wildHoldItems
    chances=[50,5,1]
    chances=[60,20,5] if !$Trainer.party[0].isEgg? &&
      isConst?($Trainer.party[0].ability,PBAbilities,:COMPOUNDEYES)
    chances=[50,50,50] if !$Trainer.party[0].isEgg? &&
      isConst?($Trainer.party[0].ability,PBAbilities,:SUPERLUCK)
    itemrnd=rand(100)
    if itemrnd<chances[0] || (items[0]==items[1] && items[1]==items[2])
      genwildpoke.setItem(items[0])
    elsif itemrnd<(chances[0]+chances[1])
      genwildpoke.setItem(items[1])
    elsif itemrnd<(chances[0]+chances[1]+chances[2])
      genwildpoke.setItem(items[2])
    end
    Events.onStartBattle.trigger(nil,genwildpoke)
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke],$Trainer,nil)
    battle.internalbattle=true
    battle.cantescape=!canescape
    pbPrepareBattle(battle)
    decision=0
    pbBattleAnimation(0,pbGetWildBattleBGM(mon[0])) { 
      pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
      }
      Achievements.incrementProgress("WILD_ENCOUNTERS",1)
      Achievements.incrementProgress("MOVES_USED",$game_variables[530])
      Achievements.incrementProgress("ITEMS_USED",$game_variables[536])
      Achievements.incrementProgress("ITEMS_USED_IN_BATTLE",$game_variables[536])
      Achievements.incrementProgress("MAX_FRIENDSHIP",$game_variables[541])
      for i in $Trainer.party; (i.makeUnmega rescue nil); end
      for i in $Trainer.party
        if isConst?(i.species,PBSpecies,:MIMIKYU)
          i.form=0
        end
        if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
          if i.form==2
            i.form=1
          end
        end
      end
      if $PokemonGlobal.partner
        pbHealAll
        for i in $PokemonGlobal.partner[3]
          i.heal
          i.makeUnmega rescue nil
          if isConst?(i.species,PBSpecies,:MIMIKYU)
            i.form=0
          end
          if isConst?(i.species,PBSpecies,:CRAMORANT)
            i.form=0
          end
          if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
            if i.form==2
              i.form=1
            end
          end
        end
      end
      if decision==2 || decision==5 # if loss or draw
        if canlose
          for i in $Trainer.party; i.heal; end
          for i in 0...10
            Graphics.update
          end
        else
          $game_system.bgm_unpause
          $game_system.bgs_unpause
          Kernel.pbStartOver
        end
      end
      Events.onEndBattle.trigger(nil,decision)
    }
    Input.update
    pbSet($game_variables[100],decision)
    $game_variables[100]=decision
    Events.onWildBattleEnd.trigger(nil,species,level,decision)
    if decision==4
      Achievements.incrementProgress("POKEMON_CAUGHT",1)
      if shinyMon
        Achievements.incrementProgress("SHINY_POKEMON_CAUGHT",1)
      end
    end
    genwildpoke.makeShadow
    $game_switches[1305] = false
    return (decision!=2)  
    return mon
  else
    askmessage=_INTL("Would you like to clear the den?")
    if Kernel.pbConfirmMessage(askmessage)
      $game_variables[100]=1
      $PokemonGlobal.nextBattleBGM=nil
      $PokemonGlobal.nextBattleME=nil
      $PokemonGlobal.nextBattleBack=nil
      return true
    end
  end
  if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
    if $Trainer.pokemonCount>0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    $game_variables[100]=1
    $PokemonGlobal.nextBattleBGM=nil
    $PokemonGlobal.nextBattleME=nil
    $PokemonGlobal.nextBattleBack=nil
    return true
  end

end
# event mentions mon[0] is the mon

#def raidDen(mon)
  #save_game()
  #start_raid_battle() # create custom battle type, entry?
#end
########## Raid battles - END ##########

########## Rental Code - START ##########

# Rental Pokemon for Single (3 Pokemon)
def pbRentalSingle
  $game_variables[543] = $Trainer.party
  $Trainer.party = []
  while $Trainer.party.length<3
    species = pbChooseSpeciesOrdered(1)
    level = 100
    pbAddPokemonSilent(species,level)
  end
end

# Rental Pokemon for Double (4 Pokemon)
def pbRentalDouble
  $game_variables[543] = $Trainer.party
  $Trainer.party = []
  while $Trainer.party.length<4
    species = pbChooseSpeciesOrdered(1)
    level = 100
    pbAddPokemonSilent(species,level)
  end
end

# Returns Party that was stored in variable
def pbRentReturn
  $Trainer.party = $game_variables[543]
  if $game_variables[12] != 0
    $Trainer.name = $game_variables[12]
  end
  $game_switches[1075]=false
#  Kernel.pbMessage(_INTL("Gave back rental pokemon."))
end

# Rental Pokemon for Battle Factory (6 Pokemon)
def pbRentalBF
  $game_variables[543] = $Trainer.party
  $Trainer.party = []
  while $Trainer.party.length<6
    species = rand(PBSpecies.maxValue)+1
    level = 100
    pbAddPokemonSilent(species,level)
  end
end

def pbRentalParty(mons, levels, newname=0)
  if mons.length != levels.length
    print "Please set mon and levels arrays to same length"
    return
  end
  $game_variables[543] = $Trainer.party
  if newname!=0
    $game_variables[12] = $Trainer.name
    $Trainer.name = newname
  else
    $game_variables[12] = 0
  end
  $Trainer.party = []
  mons.zip(levels).each do |species,level|
    pbAddRentalPokemonSilent(species,level)
  end
  $game_switches[1075]=true
end

def pbRentalMoves(index, moves=[])
  mon = $Trainer.party[index]
  mon.pbDeleteAllMoves
  if moves.length == 0
    mon.resetMoves
  else
    for move in moves
      mon.pbLearnMove(move)
    end
  end
end

def pbRentalIVs(index, ivs=[])
  mon = $Trainer.party[index]
  if ivs.length==6
    mon.iv = ivs
  end
end

def pbRentalItems(num, items=[])
  return if num == 0 || items.length == 0
  for i in 0...num
    if items[i] != -1
      mon = $Trainer.party[i]
      mon.setItem(items[i])
    end
  end
end

def pbRentalAbilities(num, abilities=[])
  return if num == 0 || abilities.length == 0
  for i in 0...num
    if abilities[i] != -1
      mon = $Trainer.party[i]
      index = pbGetAbilityIndex(mon, abilities[i])
      if index > -1
        mon.setAbility(index)
      end
    end
  end
end

def pbGetAbilityIndex(mon, ability)
  aname = getConst(PBAbilities,ability)
  name = PBAbilities.getName(aname)
  abils = mon.getAbilityList
  for i in 0...abils[0].length
    abil = PBAbilities.getName(abils[0][i])
    if name == abil
      return i
    end    
  end
  return -1
end
########## Rental Code - END ##########

# Level up box mons up to levelup value
def LevelUpNowRage(levelup)
  for i in -1...$PokemonStorage.maxBoxes
    for j in 0...$PokemonStorage.maxPokemon(i)
      if $PokemonStorage[i][j]
        $PokemonStorage[i][j].level=levelup
      end
    end
  end
end

# add a pokemon with tons of custom data
def pbAddSilent(pokemon,level=nil,seeform=true,ivs=[],ability=-1,moves=[],female=false,obtainText="",name="",ot="",shiny=-1,evs=[],nature=-1,holditem=-1,form=-1,happiness=-1)
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  if ivs.length==6
    pokemon.iv = ivs
  end
  if ability!=-1
    pokemon.setAbility(ability)
  end
  if moves.length > 0
    pokemon.pbDeleteAllMoves
    for move in moves
      pokemon.pbLearnMove(move)
    end
  end
  if female
    pokemon.makeFemale
  end
  if obtainText!=""
    pokemon.obtainText = _INTL(obtainText)
  end
  if name!=""
    pokemon.name = name
  end
  if ot!=""
    pokemon.ot = ot
  end
  if shiny<0
    pokemon.makeNotShiny
  elsif shiny==1
    pokemon.makeShiny
  end
  if evs.length==6
    pokemon.ev = evs
  end
  if nature!=-1
    pokemon.setNature(nature)
  end
  if holditem!=-1
    pokemon.setItem(holditem)
  end
  if form!=-1
    pokemon.form = form
  end
  if happiness!=-1
    pokemon.happiness = happiness
  end
  pokemon.calcStats
  
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length]=pokemon
  return true
end

Events.onStepTaken+=proc{
  if $game_variables[595] > 0
    $game_variables[595]-=1
  end
}

def pbGameVariable?(num)
  return $game_variables[num]
end

########## Change time - START ##########
def turnToDay
  $game_switches[1312] = true
  $game_switches[1289] = true
  $game_switches[1290] = false
  $game_switches[1291] = false
end

def turnToEvening
  $game_switches[1312] = true
  $game_switches[1289] = false
  $game_switches[1290] = true
  $game_switches[1291] = false
end

def turnToNight
  $game_switches[1312] = true
  $game_switches[1289] = false
  $game_switches[1290] = false
  $game_switches[1291] = true
end

def turnToNormal
  $game_switches[1312] = false
  $game_switches[1289] = false
  $game_switches[1290] = false
  $game_switches[1291] = false
end
########## Change time - END ##########


########## Record Utils - START ##########
def readFile(filename)
  fin = File.open(filename)
  data = fin.read
  fin.close
  return data
end

# maybe I'm stupid, maybe this shit just doesn't have ord()
# or at least something to convert char to int/ascii equivalent...sort of
def char_to_int(char)
  letter_to_index = {"a"=>0,"b"=> 1,"c"=> 2,"d"=> 3,"e"=> 4,"f"=> 5,"g"=> 6,
                     "h"=> 7,"i"=> 8,"j"=> 9, "k"=>10, "l"=>11, "m"=>12, "n"=>13, 
                     "o"=>14, "p"=>15, "q"=>16, "r"=>17, "s"=>18, "t"=>19, 
                     "u"=>20, "v"=>21, "w"=>22, "x"=>23, "y"=>24, "z"=>25}
  if char == char.capitalize
    char.downcase!
  end
  return letter_to_index[char]
end

def int_to_char(int)
  index_to_letter = {0=>"a", 1=>"b", 2=>"c", 3=>"d", 4=>"e", 5=>"f", 6=>"g", 
                     7=>"h", 8=>"i", 9=>"j", 10=>"k", 11=>"l", 12=>"m", 13=>"n", 
                     14=>"o", 15=>"p", 16=>"q", 17=>"r", 18=>"s", 19=>"t", 
                     20=>"u", 21=>"v", 22=>"w", 23=>"x", 24=>"y", 25=>"z"}
  return index_to_letter[int]
end

def int_to_charC(int)
  index_to_letter = {0=>"A", 1=>"B", 2=>"C", 3=>"D", 4=>"E", 5=>"F", 6=>"G", 
                     7=>"H", 8=>"I", 9=>"J", 10=>"K", 11=>"L", 12=>"M", 13=>"N", 
                     14=>"O", 15=>"P", 16=>"Q", 17=>"R", 18=>"S", 19=>"T", 
                     20=>"U", 21=>"V", 22=>"W", 23=>"X", 24=>"Y", 25=>"Z"}
  return index_to_letter[int]
end

def decipherText(cipher_text, key)
  a_off = 65
  key = key.split('')

  plain_text = cipher_text.split('').collect do |cipher_letter|
    if ('A'..'Z').include?(cipher_letter) || ('a'..'z').include?(cipher_letter)
      key_offset = char_to_int(key.first)
      if ('A'..'Z').include?(cipher_letter)
        letter = ( (char_to_int(cipher_letter) - (key_offset + a_off)) + 26) % 26
        letter = int_to_charC(letter)
      else
        letter = ( (char_to_int(cipher_letter) - (key_offset + 32 + a_off)) + 26) % 26
        letter = int_to_char(letter)
      end      
    else
      letter = cipher_letter
    end
    key << key.shift
    letter
  end

  return plain_text.join
end

def loadText(data, type)
  lines = data.split("\n")

  num = lines.length
  start = true
  i = 0

  if type == "chapters"
    chap = 0
    while i < num
      if lines[i][0..6] == "Chapter"
        value = lines[i][7..9]
        chap = value.strip.to_i
        if chap > $game_variables[651]
          break
        end
        $chap_names.push(lines[i])
      else
        if chap < $game_variables[651]
          j = 1
          while lines[i+j][0..6] != "Chapter"
            j += 1
          end
          i += (j-1)
          $chap_desc.push(lines[i])
        else
          i += $game_variables[652]
          $chap_desc.push(lines[i])
          break
        end
      end
      i += 1
    end
  elsif type == "characters"
    while i < num
      if i % 2 == 0
        $char_names.push(lines[i])
      else
        $char_desc.push(lines[i])
      end
      i += 1
    end
  end
end
########## Record Utils - END ##########

# Exp to level limit (get full exp if doesn't touch level limit)
def LevelLimitExpGain(pokemon, exp)
  levelLimits = [18, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 85, 90]
  leadersDefeated = $Trainer.numbadges
    
  if pokemon.level>=levelLimits[leadersDefeated]
    return -1
  elsif pokemon.level<levelLimits[leadersDefeated]
    totalExpNeeded = PBExperience.pbGetStartExperience(levelLimits[leadersDefeated], pokemon.growthrate)
    currExpNeeded = totalExpNeeded - pokemon.exp
    if exp > currExpNeeded
      return currExpNeeded
    end
  end
  return exp
end
#Checks for Different forms
def pbFormSeen?(species,form)
  return $Trainer.formseen[species][0][form] || $Trainer.formseen[species][1][form]
end
# Cause why not
def fuckyou
  savedir = RTP.getSaveFileName("Game.rxdata")
  savefolder = savedir[0..savedir.size-12]
  files = Dir.entries(savefolder)

  for file in files
    if file[file.size-7..file.size-1] == ".rxdata"
      savefile = savefolder+file
      begin; File.delete(savefile); rescue; end
    end
  end
end


####### Cass shit #########
def inPast?
  mapid = $game_map.map_id
  while mapid != 0
    mapid = $mapinfos[mapid].parent_id
    return true if mapid == 235
  end
  return false
end

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
          if list[index].code == 401
            text = list[index].parameters[0]
            if text.include? "©"
              puts "found"
              savemap = true
              map.events[i].pages[j].list[index].parameters[0].gsub! '©', '™'
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

def eventfilereplace
  original = edited = []
  currentmap = 0
  original = File.readlines('copy-intl.txt')
  edited = File.readlines('intl.txt')
  for line in original
    line.strip!
  end
  for line in edited
    line.strip!
  end
  for line in 0...edited.length
    next if original[line] == edited[line]
    puts original[line]
    map = 0
    savemap = false
    n = 0
    for n in currentmap..608
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
            if list[index].code == 101
              text = list[index].parameters[0]
              begin
                text += " " + list[index+1].parameters[0] if list[index+1] && list[index+1].code == 401
                text += " " + list[index+2].parameters[0] if list[index+2] && list[index+2].code == 401
              rescue
              end
              if text == original[line]
                puts "map found"
                savemap = true
                replacetext = edited[line].scan(/.{0,39}[a-z.!?,;](?:\s|$)/mi)
                puts replacetext.inspect
                for text in replacetext
                  text.lstrip!
                end
                indent = 0
                map.events[i].pages[j].list[index].parameters[0] = replacetext[0]
                indent = map.events[i].pages[j].list[index].indent
                if replacetext[1]
                  if map.events[i].pages[j].list[index+1].code == 401
                    map.events[i].pages[j].list[index+1].parameters[0] = replacetext[1]
                  else
                    newcommand = RPG::EventCommand.new(401,indent,[text])
                    map.events[i].pages[j].list.insert(index+1,newcommand)
                    list = map.events[i].pages[j].list
                  end
                  if replacetext[2]
                    if map.events[i].pages[j].list[index+2].code == 401
                      map.events[i].pages[j].list[index+2].parameters[0] = replacetext[2]
                    else
                      newcommand = RPG::EventCommand.new(401,indent,[text])
                      map.events[i].pages[j].list.insert(index+2,newcommand)
                      list = map.events[i].pages[j].list
                    end
                  end
                end
                index +=1
              end
            end
            index += 1
          end
        end
      end
      if savemap
        save_data(map,sprintf("Data/Map%03d.rxdata", n))
        puts "saved map " + n.to_s
        currentmap = n
        break
      end
      n += 1
    end
  end
end

def eventindent
  #screams
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
        code101found = false
        currentindent = 0
        while index < list.length - 1
          if list[index].code == 101
            code101found = true
          end
          if list[index].code == 401
            if list[index].indent != currentindent
              map.events[i].pages[j].list[index].indent = currentindent
              if code101found
                puts sprintf("%03d ; %03d",n,i)
                puts sprintf("%03d ; %03d",event.x,event.y)
                puts $mapinfos[n].name
                puts "amending code"
                map.events[i].pages[j].list[index].code = 101
                code101found = false
              end
              puts list[index].inspect
              savemap = true
            end
          else
            currentindent = list[index].indent
          end
          index += 1
        end
      end
    end
    save_data(map,sprintf("Data/Map%03d.rxdata", n)) if savemap
  end
end

def eventcolon
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
          if list[index].code == 401
            text = list[index].parameters[0]
            if text.include? ":"
              puts sprintf("%03d ; %03d",n,i)
              puts sprintf("%03d ; %03d",event.x,event.y)
              puts $mapinfos[n].name
              puts "Target text:"
              puts list[index].parameters[0]
              puts "In lines:"
              puts list[index-1].parameters[0] rescue nil
              puts list[index].parameters[0]
              puts list[index+1].parameters[0]
              if Kernel.pbConfirmMessageSerious("Do you want to amend the code?")
                savemap = true
                map.events[i].pages[j].list[index].code = 101
              end
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

#Variable 726 holds trainer information
def characterSwitch(character)
  #Backup the player trainer's information
  $game_variables[726] = []
  playerDataBackup
  playerItemBackup
  playerTeamBackup
  $game_switches[1235] = true #NOTPLAYER switch
  bagChange  if $game_switches[1408]==false #Interceptor wish keeps the bag intact
  #Load in the new trainer's information
  if character.is_a?(String)
    case character
    when "Adam"
      pbChangePlayer(24)
      $Trainer.name = "Adam"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 56474
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::LEADER_ADAM,"Adam",1)
      $Trainer.party = trainerinfo[2]
      $PokemonBag.pbStoreItem(PBItems::MEGARING,1)

    when "Aelita Axis"
      pbChangePlayer(15)
      $Trainer.name = "Aelita"
      $Trainer.outfit = 0
      $PokemonBag=$game_variables[726][5]
      $Trainer.id = 86105 
    when "Aelita"
      pbChangePlayer(15)
      $Trainer.name = "Aelita"
      $Trainer.outfit = 0
      $Trainer.id = 86105 
    when "Aelita Nightmare"
      pbChangePlayer(15)
      $Trainer.name = "Aelita"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 86105 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::STUDENT_3,"Aelita",5)
      $Trainer.party = trainerinfo[2]
      $PokemonBag.pbStoreItem(PBItems::MEGARING,1)
      $PokemonBag.pbStoreItem(PBItems::FIGHTINIUMZ,1)

    when "Aelita ANGY"
      pbChangePlayer(18)
      $Trainer.name = "Aelita"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 86105 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::STUDENT_2,"Aelita")
      $Trainer.party = trainerinfo[2]
      $game_switches[145] = true #we don't have graphics for her

    when "Aelita - Airship"
      pbChangePlayer(15)
      $Trainer.name = "Aelita"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 86105 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::STUDENT_3,"Aelita",6)
      $Trainer.party = trainerinfo[2]

    when "Aelita - Pyramid"
      pbChangePlayer(15)
      $Trainer.name = "Aelita"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 86105 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::STUDENT_3,"Aelita")
      $Trainer.party = trainerinfo[2]

    when "Alexandra"
      pbChangePlayer(16)
      $Trainer.name = "Alexandra"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 2 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::ELITE_ALEXANDRA,"Alexandra")
      $Trainer.party = trainerinfo[2]
      $PokemonBag.pbStoreItem(PBItems::MEGARING,1)

    when "Amber"
      pbChangePlayer(19)
      $Trainer.name = "Amber"
      $Trainer.outfit = 0
      $Trainer.id = 57893 
      $game_switches[145] = true #we don't have graphics for her

    when "Amber Realm"
      pbChangePlayer(19)
      $Trainer.name = "Amber"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 57893 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::LEADER_AMBER2,"Amber")
      $Trainer.party = trainerinfo[2]
      $game_switches[145] = true #we don't have graphics for her
    when "Erin"
      pbChangePlayer(17)
      $Trainer.name = "Erin"
      $Trainer.outfit = 0
      $Trainer.id = 80062 

    when "Erin - Diamond"
      pbChangePlayer(17)
      $Trainer.name = "Erin"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 80062 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::CANDIDGIRL,"Erin",5)
      $Trainer.party = trainerinfo[2]
      $PokemonBag.pbStoreItem(PBItems::MEGARING,1)

    when "Huey Realm"
      pbChangePlayer(21)
      $Trainer.name = "Huey"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 34605 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::OPTKID,"Huey",2)
      $Trainer.party = trainerinfo[2]

    when "Huey"
      pbChangePlayer(21)
      $Trainer.name = "Huey"
      $Trainer.outfit = 0
      $Trainer.id = 34605 

    when "Lavender HOH"
      pbChangePlayer(11)
      $Trainer.name = "Lavender"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 30638 

    when "Lavender SPACE"
      pbChangePlayer(22)
      $Trainer.name = "Lavender"
      $Trainer.outfit = 15
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 30638 
      $PokemonBag.pbStoreItem(PBItems::MEGARING,1)
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::LEADER_LAVENDER,"Lavender",2)
      $Trainer.party = trainerinfo[2]

    when "Lavender"
      pbChangePlayer(22)
      $Trainer.name = "Lavender"
      $Trainer.outfit = 15
      $Trainer.id = 30638 

    when "Marianette"
      pbChangePlayer(2)
      $Trainer.name = "Marianette"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 500
      $Trainer.id = 56941 

    when "Melia"
      pbChangePlayer(12)
      $Trainer.name = "Melia"
      $Trainer.outfit = 0
      $Trainer.id = 93509

    when "Melia - Lab"
      pbChangePlayer(9)
      $Trainer.name = "Melia"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 93509 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::TRAINER_MELIA1,"Melia",1)
      $Trainer.party = trainerinfo[2]

    when "Emma"
      pbChangePlayer(10)
      $Trainer.name = "Emma"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 93509 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::HOOD,"Emma",1)
      $Trainer.party = trainerinfo[2]

    when "Melia Zeight"
      pbChangePlayer(23)
      $Trainer.name = "Melia"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 93509 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::ENIGMA_1,"Melia",4)
      $Trainer.party = trainerinfo[2]

    when "Melia - GDB"
      pbChangePlayer(14)
      $Trainer.name = "Melia"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 93509 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::ENIGMA_1,"Melia",5)
      $Trainer.party = trainerinfo[2]

    when "Melia Library"
      pbChangePlayer(12)
      $Trainer.name = "Melia"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 93509 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::ENIGMA_1,"Melia",5)
      $Trainer.party = trainerinfo[2]

    when "Melia 1v1"
      pbChangePlayer(12)
      $Trainer.name = "Melia"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 93509 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::ENIGMA_2,"Melia",4)
      $Trainer.party = trainerinfo[2]
      $PokemonBag.pbStoreItem(PBItems::MEGARING,1)

    when "Melia - Pearl"
      pbChangePlayer(12)
      $Trainer.name = "Melia"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 93509 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::ENIGMA_2,"Melia",3)
      $Trainer.party = trainerinfo[2]
      $PokemonBag.pbStoreItem(PBItems::MEGARING,1)

    when "Melia - Inside"
      pbChangePlayer(14)
      $Trainer.name = "Melia"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 93509 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::ENIGMA_2,"Melia",2)
      $Trainer.party = trainerinfo[2]

    when "Ren - Past"
      pbChangePlayer(13)
      $Trainer.name = "Ren"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 27412 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::OUTCAST,"Ren",1)
      $Trainer.party = trainerinfo[2]

    when "Ren - Pyramid"
      pbChangePlayer(13)
      $Trainer.name = "Ren"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 0
      $Trainer.id = 27412 
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::OUTCAST,"Ren",3)
      $Trainer.party = trainerinfo[2]
      $PokemonBag.pbStoreItem(PBItems::SILVCREST,1)

    when "Saki Realm", "Saki Axis"
      pbChangePlayer(20)
      $Trainer.name = "Saki"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 1000000000
      $Trainer.id = 11566 

    end
  end
=begin
with the changes to the nightmare academy, i'm not sure this is necessary
  badgearray = []
  maxlevel = 0
  for mon in $Trainer.party
    maxlevel = mon.level if maxlevel < mon.level
  end
  badgelevels = [15, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 85, 90]
  for i in 0...badgelevels.length
    badgearray[i]= maxlevel > badgelevels[i] ? true : nil
  end
  $Trainer.badges = badgearray
=end
end

def characterRestore(resetbag=true)
  playerSpriteRestore
  playerDataRestore
  teamRestore if $game_switches[1408] == false
  if resetbag==true # prevents bag/money from being reset
    playerItemRestore if $game_switches[1408] == false
  end
  $game_switches[1235] = false #you're now the player!
  $game_switches[145] = false #reset vs graphics to on
  $game_switches[1408] = false #interceptor's wish is off
end

def playerItemBackup
  $game_variables[726][1] = $Trainer.money
  $game_variables[726][5] = $PokemonBag
  $game_variables[726][6] = false
  #if the bag gets swapped, this is flipped to true
  #that way if it isn't swapped, we skip restoring it
end

def playerDataBackup
  $game_variables[12] = $Trainer.name
  $game_variables[726][2] = $Trainer.badges
  $game_variables[726][3] = $Trainer.id
  $game_variables[726][4] = $Trainer.outfit
end

def playerTeamBackup
  $game_variables[726][0] = $Trainer.party
end

def playerSpriteRestore
  pbChangePlayer(0) if $game_switches[96] == true
  pbChangePlayer(1) if $game_switches[95] == true
  pbChangePlayer(5) if $game_switches[250] == true
  pbChangePlayer(4) if $game_switches[249] == true
  pbChangePlayer(6) if $game_switches[586] == true
  pbChangePlayer(7) if $game_switches[587] == true
  pbChangePlayer(8) if $game_switches[991] == true
end

def playerDataRestore
  $Trainer.name = $game_variables[12]
  $Trainer.badges = $game_variables[726][2]
  $Trainer.id = $game_variables[726][3]
  $Trainer.outfit = $game_variables[726][4]
end

def playerItemRestore
  $Trainer.money = $game_variables[726][1]
  $PokemonBag = $game_variables[726][5]
  $game_variables[726][6] = false
end

def bagChange
  $PokemonBag = PokemonBag.new
  $game_variables[726][6] = true #indicates that the bag was replaced
  $PokemonBag.pbStoreItem(PBItems::FULLHEAL,4)
  $PokemonBag.pbStoreItem(PBItems::MAXPOTION,6)
  $PokemonBag.pbStoreItem(PBItems::REVIVE,4)
  $PokemonBag.pbStoreItem(PBItems::MAXREVIVE,1)
end

def teamSwap(trainertype,trainername,partyid=nil)
  playerTeamBackup
  trainerinfo = pbLoadTrainerDifficult(trainertype,trainername,partyid)
  $Trainer.party = trainerinfo[2]
end

def teamRestore
  $Trainer.party = $game_variables[726][0]
end

def pyramidSetup
  $game_variables[73] = []
  trainerinfo = pbLoadTrainerDifficult(PBTrainers::STUDENT_3,"Aelita")
  $game_variables[73][0] = trainerinfo[2]
  trainerinfo = pbLoadTrainerDifficult(PBTrainers::OUTCAST,"Ren",3)
  $game_variables[73][1] = trainerinfo[2]
end

def pyramidSwitch(character)
  #if i was better at coding, i wouldn't need this function.
  #save the current party
  case $Trainer.name  
  when "Aelita"
    $game_variables[73][0] = $Trainer.party
  when "Ren"
    $game_variables[73][1] = $Trainer.party
  else
    $game_variables[73][2] = $Trainer.party
  end
  #swap characters
  case character
  when "Player"
    playerSpriteRestore
    playerDataRestore
    $Trainer.party = $game_variables[73][2]
    $game_switches[1235] = false
  when "Aelita"
    pbChangePlayer(15)
    $Trainer.name = "Aelita"
    $Trainer.outfit = 0
    $Trainer.party = []
    $Trainer.party = $game_variables[73][0]
    $game_switches[1235] = true #non-player
  when "Ren"
    pbChangePlayer(13)
    $Trainer.name = "Ren"
    $Trainer.outfit = 0
    $Trainer.party = []
    $Trainer.party = $game_variables[73][1]
    $game_switches[1235] = true #non-player
  end
end

def bagyeet
  File.open("bag.dat","w"){|file|
    Marshal.dump($PokemonBag,file)
  }
end

def bagyoink
  File.open("bag.dat","r"){|file|
    $PokemonBag =Marshal.load(file)
  }
end

def teamyeet
  File.open("team.dat","w"){|file|
    Marshal.dump($Trainer.party,file)
  }
end

def teamyoink
  File.open("team.dat","r"){|file|
    $Trainer.party =Marshal.load(file)
  }
end

