#===============================================================================
# Modern Questing System + UI
# If you like quests, this is the resource for you!
#===============================================================================
# Original implemenation by mej71
# Updated for v17.2 and v18/18.1 by derFischae
# Heavily edited for v19/19.1 by ThatWelshOne_
# Some UI components borrowed (with permission) from Marin's Easy Questing Interface
# 
#===============================================================================
# Things you can currently customise without editing the scripts themselves
#===============================================================================

# If true, includes a page of failed quests on the UI
# Set this to false if you don't want to have quests that can be failed
SHOW_FAILED_QUESTS = true

# Name of file in Audio/SE that plays when a quest is activated/advanced to new stage/completed
QUEST_JINGLE = "Mining found all.ogg"

# Name of file in Audio/SE that plays when a quest is failed
QUEST_FAIL = "GUI sel buzzer.ogg"

# Future plans are to add different backgrounds that can be chosen by you

#===============================================================================
# Utility method for setting colors
#===============================================================================

# Useful Hex to 15-bit color converter: http://www.budmelvin.com/dev/15bitconverter.html
# Add in your own colors here!
def colorQuest(color)
  color = color.downcase if color
  return "6EA020A0" if color == "blue"
  return "215E042D" if color == "red"
  return "378025E0" if color == "green"
  return "7FC03D80" if color == "cyan"
  return "401E140D" if color == "magenta"
  return "0F3D0193" if color == "yellow"
  return "7FDE1CE7" if color == "gray"
  return "7FDE39CE" if color == "white"
  return "7D792868" if color == "purple"
  return "01FF0111" if color == "orange"
  return "7FDE1CE7" # Returns the default dark gray color if all other options are exhausted
end
