GAMETITLE = "Pokemon Desolation"
GAMEVERSION = "e6"

LEVELCAPS          = [20,30,40,50,60,65,70,75,100]
STARTINGMAP        = 1

Reborn = false
Desolation = true
Rejuv = false

#===============================================================================
# * Message/Speech Frame location arrays
#===============================================================================

###YUMIL-26- BRAVELY DEFAULT-STYLE ENCOUNTER RATE -BEGIN####
class NumberOption2
	include PropertyMixin
	attr_reader :name
	attr_reader :values
	attr_reader :description
  
	def initialize(name,options,getProc,setProc,description="")
	  @values=options
	  @name=name
	  @getProc=getProc
	  @setProc=setProc
	  @description=description
	end
	def next(current)
	  index=current+1
	  index=0 if index>@values.length-1
	  return index
	end
  
	def prev(current)
	  index=current-1
	  index=@values.length-1 if index<0
	  return index
	end
  end
  ###YUMIL-26 - END###
  #####################
  #
  #  Stores game options
  # Default options are at the top of script section SpriteWindow.
  #####################
  #
  #  Stores game options
  # Default options are at the top of script section SpriteWindow.
  
  ##27 - BRAVELY DEFAULT-STYLE ENCOUNTER RATE -Yumil
  $EncounterValues=[
  0,10,25,50,75,90,100,125,150,200,300,400,500,750,1000,2000,4000,8000,10000
  ]
  ##27 - BRAVELY DEFAULT-STYLE ENCOUNTER RATE -Yumil
  
SpeechFrames=[
	"PRWS- speech1", # Default: speech hgss 1
	"PRWS- speech2",
	"PRWS- speech3",
	"PRWS- speech4",
	"PRWS- speech5",
	"PRWS- speech6",
	"PRWS- speech7",
	"PRWS- speech8",
	"PRWS- speech9",
	"PRWS- speech10",
	"PRWS- speech11",
	"PRWS- speech12",
	"PRWS- speech13",
	"PRWS- speech14",
	"PRWS- speech15",
	"PRWS- speech16",
	"PRWS- speech17",
	"PRWS- speech18",
	"PRWS- speech19",
	"PRWS- speech20",
	"PRWS- speech21",
	"PRWS- speech22",
	"PRWS- speech23",
	"PRWS- speech24",
	"PRWS- speech25",
	"PRWS- speech26",
	"PRWS- speech27",
	"PRWS- speech28"
]

TextFrames=[
	"Graphics/Windowskins/PRWS- menu1", # Default: choice 1
	"Graphics/Windowskins/PRWS- menu2",
	"Graphics/Windowskins/PRWS- menu3",
	"Graphics/Windowskins/PRWS- menu4",
	"Graphics/Windowskins/PRWS- menu5",
	"Graphics/Windowskins/PRWS- menu6",
	"Graphics/Windowskins/PRWS- menu7",
	"Graphics/Windowskins/PRWS- menu8",
	"Graphics/Windowskins/PRWS- menu9",
	"Graphics/Windowskins/PRWS- menu10",
	"Graphics/Windowskins/PRWS- menu11",
	"Graphics/Windowskins/PRWS- menu12",
	"Graphics/Windowskins/PRWS- menu13",
	"Graphics/Windowskins/PRWS- menu14",
	"Graphics/Windowskins/PRWS- menu15",
	"Graphics/Windowskins/PRWS- menu16",
	"Graphics/Windowskins/PRWS- menu17",
	"Graphics/Windowskins/PRWS- menu18",
	"Graphics/Windowskins/PRWS- menu19",
	"Graphics/Windowskins/PRWS- menu20",
	"Graphics/Windowskins/PRWS- menu21",
	"Graphics/Windowskins/PRWS- menu22",
	"Graphics/Windowskins/PRWS- menu23",
	"Graphics/Windowskins/PRWS- menu24",
	"Graphics/Windowskins/PRWS- menu25",
	"Graphics/Windowskins/PRWS- menu26",
	"Graphics/Windowskins/PRWS- menu27",
	"Graphics/Windowskins/PRWS- menu28"
]

VersionStyles=[
	["PokemonEmerald"]#, # Default font style - Power Green/"Pokemon Emerald"
	#["Power Red and Blue"],
	#["Power Red and Green"],
	#s["Power Clear"]
]