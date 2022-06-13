################################################################################
# RMXP Event Exporter v1.3
# by NettoHikari
# 
# October 29, 2020
# 
# This script exports all map events, common events, and battle events (not used
# in Essentials) to a single text file. This is most useful when you need to
# search through all events for some line of text, like a piece of code in
# Script boxes, without having to manually look through each event yourself.
# 
# Credits to NettoHikari would be appreciated, but NOT necessary.
# You should also credit the authors of Pokemon Essentials if you're using that.
# 
#-------------------------------------------------------------------------------
# INSTALLATION
#-------------------------------------------------------------------------------
# Place this script somewhere between "Compiler" and "Main" (preferably just
# directly before Main), and name it "Event Export".
# 
#-------------------------------------------------------------------------------
# SCRIPT USAGE
#-------------------------------------------------------------------------------
# The main switch EXPORTEVENTS determines if this script should run the next
# time you launch the game from Debug mode, and is set to "true" by default.
# However, the Game.exe will ignore this switch and never export events - this
# is a failsafe in case you distribute the game with this script still enabled,
# since you wouldn't want your players getting full event text dumps every time
# they run the game.
# 
# The script saves the text files to a folder called "EventExporter" by default.
# You can choose two formats for the file name: either let it use the current
# timestamp by setting USEDATEANDTIME = true, or set it to false and set
# EXPORTFILENAME to whatever file name you want.
# 
#-------------------------------------------------------------------------------
# TROUBLESHOOTING
#-------------------------------------------------------------------------------
# - If you get an error while running this script, first try going to the
#   very last line of the file this script was trying to write to. If you
#   see that it stopped in the middle of trying to write map data or event
#   data or something else, then make sure that the data isn't corrupted on your
#   end. Of course, if you're sure your data is valid, then feel free to report
#   the error wherever you found this script (like Relic Castle or
#   Pokecommunity).
# 
#-------------------------------------------------------------------------------
# 
# I hope this script is useful!
# - NettoHikari
################################################################################

if defined?(PluginManager)
  PluginManager.register({
    :name => "RMXP Event Exporter",
    :version => "v1.3",
    :credits => ["NettoHikari"],
    :link => "https://reliccastle.com/resources/394/"
  })
end

# Folder to export event text file to
# If more than one level deep, must create folders yourself
EXPORTDIRNAME = "EventExporter"

# Main switch to export events or not upon running game in Debug mode
EXPORTEVENTS = true

# Names files according to timestamp: Year-Month-Date-HoursMinutesSeconds
# Ex. 2020-07-01-163851.txt is 4:38pm on July 1, 2020.
USEDATEANDTIME = false

# Custom file name if not using timestamp
EXPORTFILENAME = "EventTextDump"

module EventExport
  def self.export
    Dir.mkdir(EXPORTDIRNAME) if !(Dir.chdir(EXPORTDIRNAME){true} rescue false)
    if USEDATEANDTIME
      timeformat = Time.now.strftime("%Y-%m-%d-%H%M%S")
      filename = EXPORTDIRNAME + "/" + timeformat + ".txt"
    else
      filename = EXPORTDIRNAME + "/" + EXPORTFILENAME + ".txt"
    end
    f = File.open(filename, "w"){|f|
      @@f = f
      @@system = load_data("Data/System.rxdata")
      @@actors = load_data("Data/Actors.rxdata")
      @@skills = load_data("Data/Skills.rxdata")
      @@weapons = load_data("Data/Weapons.rxdata")
      @@armors = load_data("Data/Armors.rxdata")
      @@states = load_data("Data/States.rxdata")
      @@enemies = load_data("Data/Enemies.rxdata")
      @@troops = load_data("Data/Troops.rxdata")
      @@items = load_data("Data/Items.rxdata")
      @@common_events = load_data("Data/CommonEvents.rxdata")
      @@mapinfos = load_data("Data/MapInfos.rxdata")
      @@animations = load_data("Data/Animations.rxdata")
      @@classes = load_data("Data/Classes.rxdata")
      @@tilesets = load_data("Data/Tilesets.rxdata")
      @@update_timer = 0
      @@events = []
      @@troop_id = 0
      f.write("###############################################################################\n")
      f.write("# MAP EVENTS\n")
      f.write("###############################################################################\n\n")
      f.write("#==============================================================================\n")
      for n in 1..999
        map_name = sprintf("Data/Map%03d.rxdata", n)
        next if !(File.open(map_name,"rb") { true } rescue false)
        map = load_data(map_name)
        f.write(sprintf("Map ID: %03d\n", n))
        f.write("Map Name: " + @@mapinfos[n].name + "\n")
        f.write(sprintf("Tileset: %03d: %s\n", map.tileset_id, @@tilesets[map.tileset_id].name))
        f.write("Width: #{map.width}, Height: #{map.height}\n")
        if map.autoplay_bgm
          f.write("Auto-Change BGM: " + map.bgm.name + "\n")
        end
        if map.autoplay_bgs
          f.write("Auto-Change BGS: " + map.bgs.name + "\n")
        end
        if map.encounter_list.length > 0
          f.write("Encounter Troops:\n")
          for troop_id in map.encounter_list
            f.write(sprintf("%03d: %s\n", troop_id, @@troops[troop_id].name))
          end
          f.write("Steps Average: #{map.encounter_step}\n")
        end
        f.write("\n#------------------------------------------------------------------------------\n") if map.events.keys.length > 0
        @@events = map.events
        for i in map.events.keys.sort
          Win32API.SetWindowText("Exporting map #{n} event #{i}") if defined?(Win32API.SetWindowText)
          event = map.events[i]
          f.write(sprintf("Map %03d - ",n)+ @@mapinfos[n].name + sprintf("; Event ID: %03d\n", event.id))
          f.write("Event Name: " + event.name + "\n")
          f.write(sprintf("(X,Y): (%03d,%03d)\n\n", event.x, event.y))
          for i in 0...event.pages.length
            f.write("Page ##{i+1}\n")
            begin
              writeEventPage(event.pages[i])
            rescue
              errmsg = "INVALID EVENT COMMAND DATA\n\n"
              errmsg += sprintf("Map ID: %03d\n", n)
              errmsg += "Map Name: " + @@mapinfos[n].name + "\n"
              errmsg += sprintf("Event ID: %03d\n", event.id)
              errmsg += "Event Name: " + event.name + "\n"
              errmsg += sprintf("(X,Y): (%03d,%03d)\n\n", event.x, event.y)
              errmsg += "Line Number: #{@@index + 1}\n\n"
              errmsg += "Check the end of the event text file that was generated before the script crashed to see which event command has invalid data."
              raise errmsg
            end
          end
          f.write("#------------------------------------------------------------------------------\n")
        end
        f.write("\n#==============================================================================\n")
      end
      @@events = []
      f.write("\n")
      f.write("###############################################################################\n")
      f.write("# COMMON EVENTS\n")
      f.write("###############################################################################\n\n")
      f.write("#==============================================================================\n")
      for i in 0...@@common_events.length
        next if @@common_events[i+1].nil?
        f.write(sprintf("Common Event ID: %03d\n", i+1))
        f.write("Common Event Name: " + @@common_events[i+1].name + "\n\n")
        f.write("Trigger: " + ["None", "Autorun", "Parallel"][@@common_events[i+1].trigger] + "\n")
        begin
          if @@common_events[i+1].trigger != 0
            switch_id = @@common_events[i+1].switch_id
            f.write(sprintf("Condition switch: %04d: ", switch_id) + @@system.variables[switch_id] + "\n")
          end
        rescue
          f.write("Crash on trigger read; continuing...")
        end
        f.write("\n")
        @@index = 0
        @@list = @@common_events[i+1].list
        begin
          writeEventCommands
        rescue
          errmsg = "INVALID EVENT COMMAND DATA\n\n"
          errmsg += sprintf("Common Event ID: %03d\n", i+1)
          errmsg += "Common Event Name: " + @@common_events[i+1].name + "\n"
          errmsg += "Line Number: #{@@index + 1}\n\n"
          errmsg += "Check the end of the event text file that was generated before the script crashed to see which event command has invalid data."
          raise errmsg
        end
        f.write("#==============================================================================\n")
      end
      f.write("\n")
      f.write("###############################################################################\n")
      f.write("# BATTLE EVENTS\n")
      f.write("###############################################################################\n\n")
      f.write("#==============================================================================\n")
      for i in 0...@@troops.length
        next if @@troops[i + 1].nil?
        @@troop_id = i + 1
        f.write(sprintf("Troop ID: %03d\n", @@troop_id))
        f.write("Troop Name: " + @@troops[@@troop_id].name + "\n\n")
        f.write("#------------------------------------------------------------------------------\n")
        for i in 0...@@troops[@@troop_id].pages.length
          f.write("Page ##{@@troop_id}\n\n")
          page = @@troops[@@troop_id].pages[i]
          f.write("Conditions\n")
          conditions = ""
          if page.condition.turn_valid
            conditions += "Turn "
            if page.condition.turn_a == 0 && page.condition.turn_b != 0
              conditions += "#{page.condition.turn_b}X"
            else
              conditions += "#{page.condition.turn_a}"
              conditions += "+#{page.condition.turn_b}X" if page.condition.turn_b != 0
            end
            conditions += "\n"
          end
          if page.condition.enemy_valid
            conditions += "Enemy [#{page.condition.enemy_index + 1}. "
            conditions += getEnemyName(page.condition.enemy_index)
            conditions += "]'s HP #{page.condition.enemy_hp}% or below\n"
          end
          if page.condition.actor_valid
            conditions += "Actor [" + @@actors[page.condition.actor_id].name
            conditions += "]'s HP #{page.condition.actor_hp}% or below\n"
          end
          if page.condition.switch_valid
            conditions += "Switch " + getSwitchIDName(page.condition.switch_id)
            conditions += " is ON\n"
          end
          if conditions.length == 0
            conditions += "Don't Run\n"
          end
          conditions += "\n"
          f.write(conditions)
          f.write("Span: " + ["Battle", "Turn", "Moment"][page.span] + "\n\n")
          @@index = 0
          @@list = page.list
          begin
            writeEventCommands
          rescue
            errmsg = "INVALID EVENT COMMAND DATA\n\n"
            errmsg += sprintf("Troop ID: %03d\n", @@troop_id)
            errmsg += "Troop Name: " + @@troops[@@troop_id].name + "\n"
            errmsg += "Line Number: #{@@index + 1}\n\n"
            errmsg += "Check the end of the event text file that was generated before the script crashed to see which event command has invalid data."
            raise errmsg
          end
          f.write("#------------------------------------------------------------------------------\n")
        end
        f.write("\n#==============================================================================\n")
      end
    }
  end
  
  def self.writeEventPage(page)
    @@index = 0
    @@list = page.list
    c = page.condition
    conditions = ""
    if c.switch1_valid
      conditions += sprintf("Switch %04d: %s is ON\n", c.switch1_id, @@system.switches[c.switch1_id])
    end
    if c.switch2_valid
      conditions += sprintf("Switch %04d: %s is ON\n", c.switch2_id, @@system.switches[c.switch2_id])
    end
    if c.variable_valid
      conditions += sprintf("Variable %04d: %s is %d or above\n", c.variable_id, @@system.variables[c.variable_id], c.variable_value)
    end
    if c.self_switch_valid
      conditions += "Self Switch #{c.self_switch_ch} is ON\n"
    end
    if conditions.length == 0
      conditions += "None\n"
    end
    @@f.write("Conditions\n" + conditions + "\n")
    if page.graphic.character_name.length > 0
      @@f.write("Graphic: " + page.graphic.character_name + "\n\n")
    end
    @@f.write("Autonomous Movement\n")
    movetypes = ["Fixed", "Random", "Approach", "Custom"]
    @@f.write("Type: " + movetypes[page.move_type] + "\n")
    if page.move_type == 3 # Custom
      self.command_209(RPG::EventCommand.new(209, 0, [nil, page.move_route]), true)
      @@f.write("\n")
    end
    movespeeds = ["Slowest", "Slower", "Slow", "Fast", "Faster", "Fastest"]
    @@f.write("Speed: #{page.move_speed}: " + movespeeds[page.move_speed-1] + "\n")
    movefreqs = ["Lowest", "Lower", "Low", "High", "Higher", "Highest"]
    @@f.write("Freq: #{page.move_frequency}: " + movefreqs[page.move_frequency-1] + "\n")
    @@f.write("Options Enabled\n")
    @@f.write("Move Animation\n") if page.walk_anime
    @@f.write("Stop Animation\n") if page.step_anime
    @@f.write("Direction Fix\n") if page.direction_fix
    @@f.write("Through\n") if page.through
    @@f.write("Always on Top\n") if page.always_on_top
    triggers = ["Action Button", "Player Touch", "Event Touch", "Autorun", "Parallel Process"]
    @@f.write("Trigger: " + triggers[page.trigger] + "\n\n")
    writeEventCommands
  end
  
  def self.writeEventCommands
    @@f.write("List of Event Commands:\n")
    while @@index < @@list.length - 1
      command = @@list[@@index]
      @@params = @@list[@@index].parameters
      case command.code
      when 101  # Show Text
        self.command_101
      when 102  # Show Choices
        self.command_102
      when 402  # When [**]
        self.command_402
      when 403  # When Cancel
        self.command_403
      when 404  # Branch End (Show Choices)
        self.command_404
      when 103  # Input Number
        self.command_103
      when 104  # Change Text Options [not in VX]
        self.command_104
      when 105  # Button Input Processing [not in VX]
        self.command_105
      when 106  # Wait [in VX: 230]
        self.command_106
      when 108  # Comment
        self.command_108
      when 111  # Conditional Branch
        self.command_111
      when 411  # Else
        self.command_411
      when 412  # Branch End (Conditional Branch)
        self.command_412
      when 112  # Loop
        self.command_112
      when 413  # Repeat Above
        self.command_413
      when 113  # Break Loop
        self.command_113
      when 115  # Exit Event Processing
        self.command_115
      when 116  # Erase Event [in VX: 214]
        self.command_116
      when 117  # Call Common Event
        self.command_117
      when 118  # Label
        self.command_118
      when 119  # Jump to Label
        self.command_119
      when 121  # Control Switches
        self.command_121
      when 122  # Control Variables
        self.command_122
      when 123  # Control Self Switch
        self.command_123
      when 124  # Control Timer
        self.command_124
      when 125  # Change Gold
        self.command_125
      when 126  # Change Items
        self.command_126
      when 127  # Change Weapons
        self.command_127
      when 128  # Change Armor
        self.command_128
      when 129  # Change Party Member
        self.command_129
      when 131  # Change Windowskin [not in VX]
        self.command_131
      when 132  # Change Battle BGM
        self.command_132
      when 133  # Change Battle End ME
        self.command_133
      when 134  # Change Save Access
        self.command_134
      when 135  # Change Menu Access
        self.command_135
      when 136  # Change Encounter
        self.command_136
      when 201  # Transfer Player
        self.command_201
      when 202  # Set Event Location
        self.command_202
      when 203  # Scroll Map
        self.command_203
      when 204  # Change Map Settings
        self.command_204
      when 205  # Change Fog Color Tone [in VX: Set Move Route]
        self.command_205
      when 206  # Change Fog Opacity [in VX: Get on/off Vehicle]
        self.command_206
      when 207  # Show Animation [in VX: 212]
        self.command_207
      when 208  # Change Transparent Flag [in VX: 211]
        self.command_208
      when 209  # Set Move Route [in VX: 205]
        self.command_209(command)
      when 210  # Wait for Move's Completion
        self.command_210
      when 221  # Prepare for Transition [Not in VX, now called Fadeout Screen]
        self.command_221
      when 222  # Execute Transition [Not in VX, now called Fadein Screen]
        self.command_222
      when 223  # Change Screen Color Tone
        self.command_223
      when 224  # Screen Flash
        self.command_224
      when 225  # Screen Shake
        self.command_225
      when 231  # Show Picture
        self.command_231
      when 232  # Move Picture
        self.command_232
      when 233  # Rotate Picture
        self.command_233
      when 234  # Change Picture Color Tone
        self.command_234
      when 235  # Erase Picture
        self.command_235
      when 236  # Set Weather Effects
        self.command_236
      when 241  # Play BGM
        self.command_241
      when 242  # Fade Out BGM
        self.command_242
      when 245  # Play BGS
        self.command_245
      when 246  # Fade Out BGS
        self.command_246
      when 247  # Memorize BGM/BGS [not in VX]
        self.command_247
      when 248  # Restore BGM/BGS [not in VX]
        self.command_248
      when 249  # Play ME
        self.command_249
      when 250  # Play SE
        self.command_250
      when 251  # Stop SE
        self.command_251
      when 301  # Battle Processing
        self.command_301
      when 601  # If Win
        self.command_601
      when 602  # If Escape
        self.command_602
      when 603  # If Lose
        self.command_603
      when 604  # Branch End (Battle Processing)
        self.command_604
      when 302  # Shop Processing
        self.command_302
      when 303  # Name Input Processing
        self.command_303
      when 311  # Change HP
        self.command_311
      when 312  # Change SP
        self.command_312
      when 313  # Change State
        self.command_313
      when 314  # Recover All
        self.command_314
      when 315  # Change EXP
        self.command_315
      when 316  # Change Level
        self.command_316
      when 317  # Change Parameters
        self.command_317
      when 318  # Change Skills
        self.command_318
      when 319  # Change Equipment
        self.command_319
      when 320  # Change Actor Name
        self.command_320
      when 321  # Change Actor Class
        self.command_321
      when 322  # Change Actor Graphic
        self.command_322
      when 331  # Change Enemy HP
        self.command_331
      when 332  # Change Enemy SP
        self.command_332
      when 333  # Change Enemy State
        self.command_333
      when 334  # Enemy Recover All
        self.command_334
      when 335  # Enemy Appearance
        self.command_335
      when 336  # Enemy Transform
        self.command_336
      when 337  # Show Battle Animation
        self.command_337
      when 338  # Deal Damage
        self.command_338
      when 339  # Force Action
        self.command_339
      when 340  # Abort Battle
        self.command_340
      when 351  # Call Menu Screen
        self.command_351
      when 352  # Call Save Screen
        self.command_352
      when 353  # Game Over
        self.command_353
      when 354  # Return to Title Screen
        self.command_354
      when 355  # Script
        self.command_355
      else
        @@f.write(getIndent + "@>\n")
      end
      @@index += 1
      @@update_timer += 1
      if @@update_timer == 500
        Graphics.update
        @@update_timer = 0
      end
    end
    @@f.write("@>\n\n")
  end
  
  def self.convertToSpaces(str)
    return " " * str.length
  end
  
  def self.getIndent
    return " " * @@list[@@index].indent
  end
  
  def self.getSwitchIDName(id)
    return "" if @@system.switches[id].nil?
    text = sprintf("[%04d", id)
    if @@system.switches[id].length > 0
      text += ": " + @@system.switches[id]
    end
    return text + "]"
  end
  
  def self.getVarIDName(id)
    return "" if @@system.variables[id].nil?
    text = sprintf("[%04d", id)
    if @@system.variables[id].length > 0
      text += ": " + @@system.variables[id]
    end
    return text + "]"
  end
  
  def self.getDirectionName(num)
    case num
    when 2
      return "Down"
    when 4
      return "Left"
    when 6
      return "Right"
    when 8
      return "Up"
    end
    return ""
  end
  
  def self.getEventName(id)
    return "" if @@events[id].nil?
    return @@events[id].name
  end
  
  def self.getEnemyName(enemy_index)
    return "" if @@troop_id == 0
    member = @@troops[@@troop_id].members[enemy_index]
    return "" if member.nil?
    return @@enemies[member.enemy_id].name
  end
  
  # Show Text
  def self.command_101
    text = getIndent + "@>Text: " + @@params[0] + "\n"
    indent = getIndent + " :" + convertToSpaces("Text") + ": "
    loop do
      if @@list[@@index + 1].code == 401 # More lines of Show Text
        text += indent + @@list[@@index + 1].parameters[0] + "\n"
      else
        break
      end
      @@index += 1
    end
    @@f.write(text)
  end
  
  # Show Choices
  def self.command_102
    indent = getIndent
    text = indent + "@>Show Choices: "
    choices = @@params[0]
    if choices.length == 0
      @@f.write(text + "\n")
      return
    end
    for i in 0...choices.length - 1
      text += choices[i] + ", "
    end
    text += choices[choices.length - 1] + "\n"
    canceltypes = ["Disallow", "Choice 1", "Choice 2", "Choice 3", "Choice 4", "Branch"]
    text += indent + "(When Cancel: #{canceltypes[@@params[1]]})\n"
    @@f.write(text)
  end
  
  # When [**]
  def self.command_402
    @@f.write(getIndent + ": When [" + @@params[1] + "]\n")
  end
  
  # When Cancel
  def self.command_403
    @@f.write(getIndent + ": When Cancel\n")
  end
  
  # Branch End (Show Choices)
  def self.command_404
    @@f.write(getIndent + ": Branch End\n")
  end
  
  # Input Number
  def self.command_103
    text = getIndent + "@>Input Number: " + getVarIDName(@@params[0])
    text += ", #{@@params[1]} digit(s)\n"
    @@f.write(text)
  end
  
  # Change Text Options
  def self.command_104
    positions = ["Top", "Middle", "Bottom"]
    windows = ["Show", "Hide"]
    text = getIndent + "@>Change Text Options: "
    text += positions[@@params[0]] + ", " + windows[@@params[1]] + "\n"
    @@f.write(text)
  end
  
  # Button Input Processing
  def self.command_105
    @@f.write(getIndent + "@>Button Input Processing: " + getVarIDName(@@params[0]) + "\n")
  end
  
  # Wait
  def self.command_106
    @@f.write(getIndent + "@>Wait: #{@@params[0]} frame(s)\n")
  end
  
  # Comment
  def self.command_108
    indent = getIndent
    text = indent + "@>Comment: " + @@params[0] + "\n"
    indent += " :" + convertToSpaces("Comment") + ": "
    loop do
      if @@list[@@index + 1].code == 408 # More lines of Comment
        text += indent + @@list[@@index + 1].parameters[0] + "\n"
      else
        break
      end
      @@index += 1
    end
    @@f.write(text)
  end
  
  # Conditional Branch
  def self.command_111
    text = getIndent + "@>Conditional Branch: "
    case @@params[0]
    when 0  # switch
      text += "Switch " + getSwitchIDName(@@params[1])
      text += " == " + ["ON", "OFF"][@@params[2]]
    when 1  # variable
      text += "Variable " + getVarIDName(@@params[1]) + " "
      case @@params[4]
      when 0  # value1 is equal to value2
        text += "=="
      when 1  # value1 is greater than or equal to value2
        text += ">="
      when 2  # value1 is less than or equal to value2
        text += "<="
      when 3  # value1 is greater than value2
        text += ">"
      when 4  # value1 is less than value2
        text += "<"
      when 5  # value1 is not equal to value2
        text += "!="
      end
      text += " "
      if @@params[2] == 0 # constant
        text += "#{@@params[3]}"
      else # variable
        text += "Variable " + getVarIDName(@@params[3])
      end
    when 2  # self switch
      text += "Self Switch " + @@params[1] + " == " + (["ON", "OFF"][@@params[2]])
    when 3  # timer
      minutes = @@params[1] / 60
      seconds = @@params[1] % 60
      text += "Timer #{minutes} min #{seconds} sec or " + ["more", "less"][@@params[2]]
    when 4 # actor
      actor = @@actors[@@params[1]]
      text += "[" + actor.name + "] is "
      case @@params[2]
      when 0  # in party
        text += "in the party"
      when 1  # name
        text += "name '" + @@params[3] + "' applied"
      when 2  # skill
        text += "[" + @@skills[@@params[3]].name + "] learned"
      when 3  # weapon
        text += "[" + @@weapons[@@params[3]].name + "] equipped"
      when 4  # armor
        text += "[" + @@armors[@@params[3]].name + "] equipped"
      when 5  # state
        text += "[" + @@states[@@params[3]].name + "] inflicted"
      end
    when 5 # enemy
      text += "[#{@@params[1] + 1}. " + getEnemyName(@@params[1]) + "] is "
      case @@params[2]
      when 0  # appear
        text += "appeared"
      when 1  # state
        text += "[" + @@states[@@params[3]].name + "] inflicted"
      end
    when 6  # character
      case @@params[1]
      when -1  # player
        text += "Player"
      when 0  # this event
        text += "This event"
      else  # specific event
        text += "[" + getEventName(@@params[1]) + "]"
      end
      text += " is facing " + getDirectionName(@@params[2])
    when 7  # gold
      text += "Gold #{@@params[1]} or " + ["more", "less"][@@params[2]]
    when 8  # item
      text += "[" + @@items[@@params[1]].name + "] in inventory"
    when 9  # weapon
      text += "[" + @@weapons[@@params[1]].name + "] in inventory"
    when 10  # armor
      text += "[" + @@armors[@@params[1]].name + "] in inventory"
    when 11  # button
      text += "The "
      case @@params[1]
      when Input::DOWN
        text += "Down"
      when Input::LEFT
        text += "Left"
      when Input::RIGHT
        text += "RIGHT"
      when Input::UP
        text += "Up"
      when Input::A
        text += "A"
      when Input::B
        text += "B"
      when Input::C
        text += "C"
      when Input::X
        text += "X"
      when Input::Y
        text += "Y"
      when Input::Z
        text += "Z"
      when Input::L
        text += "L"
      when Input::R
        text += "R"
      end
      text += " button is being pressed"
    when 12  # script
      text += "Script: " + @@params[1]
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Else
  def self.command_411
    @@f.write(getIndent + ": Else\n")
  end
  
  # Branch End (Conditional Branch)
  def self.command_412
    @@f.write(getIndent + ": Branch End\n")
  end
  
  # Loop
  def self.command_112
    @@f.write(getIndent + "@>Loop\n")
  end
  
  # Repeat Above
  def self.command_413
    @@f.write(getIndent + ": Repeat Above\n")
  end
  
  # Break Loop
  def self.command_113
    @@f.write(getIndent + "@>Break Loop\n")
  end
  
  # Exit Event Processing
  def self.command_115
    @@f.write(getIndent + "@>Exit Event Processing\n")
  end
  
  # Erase Event [in VX: 214]
  def self.command_116
    @@f.write(getIndent + "@>Erase Event\n")
  end
  
  # Call Common Event
  def self.command_117
    @@f.write(getIndent + "@>Call Common Event: " + @@common_events[@@params[0]].name + "\n")
  end
  
  # Label
  def self.command_118
    @@f.write(getIndent + "@>Label: " + @@params[0] + "\n")
  end
  
  # Jump to Label
  def self.command_119
    @@f.write(getIndent + "@>Jump to Label: " + @@params[0] + "\n")
  end
  
  # Control Switches
  def self.command_121
    text = getIndent + sprintf("@>Control Switches: [%04d", @@params[0])
    if @@params[1] > @@params[0]
      text += sprintf("..%04d", @@params[1])
    elsif @@system.switches[@@params[0]].length > 0
      text += ": " + @@system.switches[@@params[0]]
    end
    text += "] = " + ["ON", "OFF"][@@params[2]] + "\n"
    @@f.write(text)
  end
  
  # Control Variables
  def self.command_122
    text = getIndent + sprintf("@>Control Variables: [%04d", @@params[0])
    if @@params[1] > @@params[0]
      text += sprintf("..%04d", @@params[1])
    elsif @@system.variables[@@params[0]].length > 0
      text += ": " + @@system.variables[@@params[0]]
    end
    text += "] "
    case @@params[2]
    when 0  # substitute
    when 1  # add
      text += "+"
    when 2  # subtract
      text += "-"
    when 3  # multiply
      text += "*"
    when 4  # divide
      text += "/"
    when 5  # remainder
      text += "%"
    end
    text += "= "
    case @@params[3]
    when 0  # invariable
      text += "#{@@params[4]}"
    when 1  # variable
      text += "Variable " + getVarIDName(@@params[4])
    when 2  # random number
      text += "Random No. (#{@@params[4]}...#{@@params[5]})"
    when 3  # item
      text += "[" + @@items[@@params[4]].name + "] In Inventory"
    when 4  # actor
      text += "[" + @@actors[@@params[4]].name + "]'s "
      case @@params[5]
      when 0  # level
        text += "Level"
      when 1  # EXP
        text += "EXP"
      when 2  # HP
        text += "HP"
      when 3  # SP
        text += "SP"
      when 4  # MaxHP
        text += "MaxHP"
      when 5  # MaxSP
        text += "MaxSP"
      when 6  # strength
        text += "STR"
      when 7  # dexterity
        text += "DEX"
      when 8  # agility
        text += "AGI"
      when 9  # intelligence
        text += "INT"
      when 10  # attack power
        text += "ATK"
      when 11  # physical defense
        text += "PDEF"
      when 12  # magic defense
        text += "MDEF"
      when 13  # evasion
        text += "EVA"
      end
    when 5  # enemy
      text += "[#{@@params[4] + 1}. " + getEnemyName(@@params[4]) + "]'s "
      case @@params[5]
      when 0  # HP
        text += "HP"
      when 1  # SP
        text += "SP"
      when 2  # MaxHP
        text += "MaxHP"
      when 3  # MaxSP
        text += "MaxSP"
      when 4  # strength
        text += "STR"
      when 5  # dexterity
        text += "DEX"
      when 6  # agility
        text += "AGI"
      when 7  # intelligence
        text += "INT"
      when 8  # attack power
        text += "ATK"
      when 9  # physical defense
        text += "PDEF"
      when 10  # magic defense
        text += "MDEF"
      when 11  # evasion correction
        text += "EVA"
      end
    when 6  # character
      case @@params[4]
      when -1  # player
        text += "Player"
      when 0  # this event
        text += "This event"
      else  # specific event
        text += "[" + getEventName(@@params[4]) + "]"
      end
      text += "'s "
      case @@params[5]
      when 0  # x-coordinate
        text += "Map X"
      when 1  # y-coordinate
        text += "Map Y"
      when 2  # direction
        text += "Direction"
      when 3  # screen x-coordinate
        text += "Screen X"
      when 4  # screen y-coordinate
        text += "Screen Y"
      when 5  # terrain tag
        text += "Terrain Tag"
      end
    when 7  # other
      case @@params[4]
      when 0  # map ID
        text += "Map ID"
      when 1  # number of party members
        text += "Party Members"
      when 2  # gold
        text += "Gold"
      when 3  # steps
        text += "Steps"
      when 4  # play time
        text += "Play Time"
      when 5  # timer
        text += "Timer"
      when 6  # save count
        text += "Save Count"
      end
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Control Self Switch
  def self.command_123
    text = getIndent + "@>Control Self Switch: " + @@params[0] + " ="
    text += ["ON", "OFF"][@@params[1]] + "\n"
    @@f.write(text)
  end
  
  # Control Timer
  def self.command_124
    text = getIndent + "@>Control Timer: "
    if @@params[0] == 0
      minutes = @@params[1] / 60
      seconds = @@params[1] % 60
      text += "Startup (#{minutes} min. #{seconds} sec.)"
    else
      text += "Stop"
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Gold
  def self.command_125
    text = getIndent + "@>Change Gold: " + ["+", "-"][@@params[0]] + " "
    if @@params[1] == 0 # constant
      text += "#{@@params[2]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[2])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Items
  def self.command_126
    text = getIndent + "@>Change Items: [" + @@items[@@params[0]].name + "], "
    text += ["+", "-"][@@params[1]] + " "
    if @@params[2] == 0 # constant
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Weapons
  def self.command_127
    text = getIndent + "@>Change Weapons: [" + @@weapons[@@params[0]].name + "] "
    text += ["+", "-"][@@params[1]] + " "
    if @@params[2] == 0 # constant
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Armor
  def self.command_128
    text = getIndent + "@>Change Armor: [" + @@armors[@@params[0]].name + "] "
    text += ["+", "-"][@@params[1]] + " "
    if @@params[2] == 0 # constant
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Party Member
  def self.command_129
    text = getIndent + "@>Change Party Member: " + ["Add", "Remove"][@@params[1]]
    text += " [" + @@actors[@@params[0]].name + "]"
    text += ", Initialize" if @@params[1] == 0 && @@params[2] == 1
    text += "\n"
    @@f.write(text)
  end
  
  # Change Windowskin [not in VX]
  def self.command_131
    @@f.write(getIndent + "@>Change Windowskin: '" + @@params[0] + "'\n")
  end
  
  # Change Battle BGM
  def self.command_132
    text = getIndent + "@>Change Battle BGM: '" + @@params[0].name + "', "
    text += "#{@@params[0].volume}, #{@@params[0].pitch}\n"
    @@f.write(text)
  end
  
  # Change Battle End ME
  def self.command_133
    text = getIndent + "@>Change Battle End ME: '" + @@params[0].name + "', "
    text += "#{@@params[0].volume}, #{@@params[0].pitch}\n"
    @@f.write(text)
  end
  
  # Change Save Access
  def self.command_134
    @@f.write(getIndent + "@>Change Save Access: " + ["Disable", "Enable"][@@params[0]] + "\n")
  end
  
  # Change Menu Access
  def self.command_135
    @@f.write(getIndent + "@>Change Menu Access: " + ["Disable", "Enable"][@@params[0]] + "\n")
  end
  
  # Change Encounter
  def self.command_136
    @@f.write(getIndent + "@>Change Encounter: " + ["Disable", "Enable"][@@params[0]] + "\n")
  end
  
  # Transfer Player
  def self.command_201
    begin
      text = getIndent + "@>Transfer Player:"
      # If appointment method is [direct appointment]
      if @@params[0] == 0
        text += sprintf("[%03d: %s], ", @@params[1], @@mapinfos[@@params[1]].name)
        text += sprintf("(%03d,%03d)", @@params[2], @@params[3])
      # If appointment method is [appoint with variables]
      else
        text += sprintf("Variable [%04d][%04d][%04d]", @@params[1], @@params[2], @@params[3])
      end
      text += ", " + getDirectionName(@@params[4]) if @@params[4] != 0
      text += ", No Fade" if @@params[5] == 1
      text += "\n"
      @@f.write(text)
    rescue
      text = "Broken Teleport\n"
      @@f.write(text)
      end
  end
  
  # Set Event Location
  def self.command_202
    text = getIndent + "@>Set Event Location: "
    if @@params[0] == 0 # this event
      text += "This event"
    else
      text += "[" + getEventName(@@params[0]) + "]"
    end
    text += ","
    # If appointment method is [direct appointment]
    if @@params[1] == 0
      text += sprintf("(%03d,%03d)", @@params[2], @@params[3])
    # If appointment method is [appoint with variables]
    elsif @@params[1] == 1
      text += sprintf("Variable [%04d][%05d]", @@params[2], @@params[3])
    # If appointment method is [exchange with another event]
    else
      text += "Switch with [" + getEventName(@@params[2]) + "]"
    end
    text += ", " + getDirectionName(@@params[4]) if @@params[4] != 0
    text += "\n"
    @@f.write(text)
  end
  
  # Scroll Map
  def self.command_203
    text = getIndent + "@>Scroll Map: " + getDirectionName(@@params[0])
    text += ", #{@@params[1]}, #{@@params[2]}\n"
    @@f.write(text)
  end
  
  # Change Map Settings
  def self.command_204
    text = getIndent + "@>Change Map Settings:"
    case @@params[0]
    when 0  # panorama
      text += "Panorama = '" + @@params[1] + "', #{@@params[2]}"
    when 1  # fog
      text += "Fog = '" + @@params[1] + "', #{@@params[2]}, #{@@params[3]}, "
      text += ["Normal", "Add", "Sub"][@@params[4]] + ", #{@@params[5]}, "
      text += "#{@@params[6]}, #{@@params[7]}"
    when 2  # battleback
      text += "Battleback = '" + @@params[1] + "'"
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Fog Color Tone [in VX: Set Move Route]
  def self.command_205
    text = getIndent + "@>Change Fog Color Tone: "
    tone = @@params[0]
    text += sprintf("(%d,%d,%d,%d)", tone.red, tone.green, tone.blue, tone.gray)
    text += ", @#{@@params[1]}\n"
    @@f.write(text)
  end
  
  # Change Fog Opacity [in VX: Get on/off Vehicle]
  def self.command_206
    @@f.write(getIndent + "@>Change Fog Opacity: #{@@params[0]}, @#{@@params[1]}\n")
  end
  
  # Show Animation [in VX: 212]
  def self.command_207
    text = getIndent + "@>Show Animation: "
    case @@params[0]
    when -1  # player
      text += "Player"
    when 0  # this event
      text += "This event"
    else  # specific event
      text += "[" + getEventName(@@params[0]) + "]"
    end
    text += ", [" + @@animations[@@params[1]].name + "]\n"
    @@f.write(text)
  end
  
  # Change Transparent Flag [in VX: 211]
  def self.command_208
    text = getIndent + "@>Change Transparent Flag: "
    text += ["Transparency", "Normal"][@@params[0]] + "\n"
    @@f.write(text)
  end
  
  # Set Move Route
  def self.command_209(command, isCustom=false)
    indent = " " * command.indent
    if !isCustom
      @@f.write(indent + "@>Set Move Route: ")
      case command.parameters[0]
      when -1  # player
        @@f.write("Player")
      when 0  # this event
        @@f.write("This event")
      else  # specific event
        @@f.write("[" + getEventName(command.parameters[0]) + "]")
      end
      @@f.write("\n")
      indent += " :" + self.convertToSpaces("Set Move Route") + ": "
    else
      @@f.write("Custom Move Route:\n")
    end
    if command.parameters[1].repeat || command.parameters[1].skippable
      actions = ""
      actions += "(Repeat Action)" if command.parameters[1].repeat
      actions += " " if command.parameters[1].repeat && command.parameters[1].skippable
      actions += "(Ignore If Can't Move)" if command.parameters[1].skippable
      @@f.write(convertToSpaces(indent) + actions + "\n")
    end
    for i in command.parameters[1].list
      text = ""
      case i.code
      when 1
        text = "Move Down"
      when 2
        text = "Move Left"
      when 3
        text = "Move Right"
      when 4
        text = "Move Up"
      when 5
        text = "Move Lower Left"
      when 6
        text = "Move Lower Right"
      when 7
        text = "Move Upper Left"
      when 8
        text = "Move Upper Right"
      when 9
        text = "Move at Random"
      when 10
        text = "Move toward Player"
      when 11
        text = "Move away from Player"
      when 12
        text = "1 Step Forward"
      when 13
        text = "1 Step Backward"
      when 14
        jump_x = "#{i.parameters[0]}"
        jump_x = "+" + jump_x if i.parameters[0] >= 0
        jump_y = "#{i.parameters[1]}"
        jump_y = "+" + jump_y if i.parameters[1] >= 0
        text = "Jump: " + jump_x + "," + jump_y
      when 15
        text = "Wait: #{i.parameters[0]} frame(s)"
      when 16
        text = "Turn Down"
      when 17
        text = "Turn Left"
      when 18
        text = "Turn Right"
      when 19
        text = "Turn Up"
      when 20
        text = "Turn 90 Right"
      when 21
        text = "Turn 90 Left"
      when 22
        text = "Turn 180"
      when 23
        text = "Turn 90 Right or Left"
      when 24
        text = "Turn at Random"
      when 25
        text = "Turn toward Player"
      when 26
        text = "Turn away from Player"
      when 27
        text = sprintf("Switch ON: %04d", i.parameters[0])
      when 28
        text = sprintf("Switch OFF: %04d", i.parameters[0])
      when 29
        text = "Change Speed: #{i.parameters[0]}"
      when 30
        text = "Change Freq: #{i.parameters[0]}"
      when 31
        text = "Move Animation ON"
      when 32
        text = "Move Animation OFF"
      when 33
        text = "Stop Animation ON"
      when 34
        text = "Stop Animation OFF"
      when 35
        text = "Direction Fix ON"
      when 36
        text = "Direction Fix OFF"
      when 37
        text = "Through ON"
      when 38
        text = "Through OFF"
      when 39
        text = "Always on Top ON"
      when 40
        text = "Always on Top OFF"
      when 41
        if i.parameters[0].nil? || i.parameters[0].length == 0
          text = "Graphic: (None)"
        else
          text = "Graphic: \"" + i.parameters[0] + "', #{i.parameters[1]}, #{i.parameters[2]}, #{i.parameters[3]}"
        end
      when 42
        text = "Change Opacity: #{i.parameters[0]}"
      when 43
        blending = ["Normal", "Add", "Sub"]
        text = "Change Blending: " + blending[i.parameters[0]]
      when 44
        se = i.parameters[0]
        text = "SE: '" + se.name + "', #{se.volume}, #{se.pitch}"
      when 45
        text = "Script: " + i.parameters[0]
      else
        next
      end
      @@f.write(indent + "$>" + text + "\n")
    end
    if !isCustom
      loop do
        if @@list[@@index + 1].code == 509 # Subsequent lines of Set Move Route
          @@index += 1
        else
          break
        end
      end
    end
  end
  
  # Wait for Move's Completion
  def self.command_210
    @@f.write(getIndent + "@>Wait for Move's Completion\n")
  end
  
  # Prepare for Transition [Not in VX, now called Fadeout Screen]
  def self.command_221
    @@f.write(getIndent + "@>Prepare for Transition\n")
  end
  
  # Execute Transition [Not in VX, now called Fadein Screen]
  def self.command_222
    text = getIndent + "@>Execute Transition"
    text += ": '" + @@params[0] + "'" if @@params[0].length > 0
    text += "\n"
    @@f.write(text)
  end
  
  # Change Screen Color Tone
  def self.command_223
    text = getIndent + "@>Change Screen Color Tone: "
    tone = @@params[0]
    text += sprintf("(%d,%d,%d,%d)", tone.red, tone.green, tone.blue, tone.gray)
    text += ", @#{@@params[1]}\n"
    @@f.write(text)
  end
  
  # Screen Flash
  def self.command_224
    text = getIndent + "@>Screen Flash: "
    color = @@params[0]
    text += sprintf("(%d,%d,%d,%d)", color.red, color.green, color.blue, color.alpha)
    text += ", @#{@@params[1]}\n"
    @@f.write(text)
  end
  
  # Screen Shake
  def self.command_225
    @@f.write(getIndent + "@>Screen Shake: #{@@params[0]}, #{@@params[1]}, @#{@@params[2]}\n")
  end
  
  # Show Picture
  def self.command_231
    text = getIndent + "@>Show Picture: #{@@params[0]}, '" + @@params[1] + "'"
    text += ", " + ["Upper Left", "Center"][@@params[2]] + " ("
    # If appointment method is [direct appointment]
    if @@params[3] == 0
      text += "#{@@params[4]},#{@@params[5]}"
    # If appointment method is [appoint with variables]
    else
      text += sprintf("Variable [%04d][%04d]", @@params[4], @@params[5])
    end
    text += "), (#{@@params[6]}%,#{@@params[7]}%), #{@@params[8]}, "
    text += ["Normal", "Add", "Sub"][@@params[9]] + "\n"
    @@f.write(text)
  end
  
  # Move Picture
  def self.command_232
    text = getIndent + "@>Move Picture: #{@@params[0]}, @#{@@params[1]}"
    text += ", " + ["Upper Left", "Center"][@@params[2]] + " ("
    # If appointment method is [direct appointment]
    if @@params[3] == 0
      text += "#{@@params[4]},#{@@params[5]}"
    # If appointment method is [appoint with variables]
    else
      text += sprintf("Variable [%04d][%05d]", @@params[4], @@params[5])
    end
    text += "), (#{@@params[6]}%,#{@@params[7]}%), #{@@params[8]}, "
    text += ["Normal", "Add", "Sub"][@@params[9]] + "\n"
    @@f.write(text)
  end
  
  # Rotate Picture
  def self.command_233
    text = getIndent + "@>Rotate Picture: #{@@params[0]}, "
    text += "+" if @@params[1] >= 0
    text += "#{@@params[1]}\n"
    @@f.write(text)
  end
  
  # Change Picture Color Tone
  def self.command_234
    text = getIndent + "@>Change Picture Color Tone: #{@@params[0]}, "
    tone = @@params[1]
    text += sprintf("(%d,%d,%d,%d), ", tone.red, tone.green, tone.blue, tone.gray)
    text += "@#{@@params[2]}\n"
    @@f.write(text)
  end
  
  # Erase Picture
  def self.command_235
    @@f.write(getIndent + "@>Erase Picture: #{@@params[0]}\n")
  end
  
  # Set Weather Effects
  def self.command_236
    text = getIndent + "@>Set Weather Effects: "
    text += ["None", "Rain", "Storm", "Snow"][@@params[0]] + ", "
    text += "#{@@params[1]}, " if @@params[0] != 0
    text += "@#{@@params[2]}\n"
    @@f.write(text)
  end
  
  # Play BGM
  def self.command_241
    text = getIndent + "@>Play BGM: '" + @@params[0].name + "', "
    text += "#{@@params[0].volume}, #{@@params[0].pitch}\n"
    @@f.write(text)
  end
  
  # Fade Out BGM
  def self.command_242
    @@f.write(getIndent + "@>Fade Out BGM: #{@@params[0]} sec.\n")
  end
  
  # Play BGS
  def self.command_245
    text = getIndent + "@>Play BGS: '" + @@params[0].name + "', "
    text += "#{@@params[0].volume}, #{@@params[0].pitch}\n"
    @@f.write(text)
  end
  
  # Fade Out BGS
  def self.command_246
    @@f.write(getIndent + "@>Fade Out BGS: #{@@params[0]} sec.\n")
  end
  
  # Memorize BGM/BGS [not in VX]
  def self.command_247
    @@f.write(getIndent + "@>Memorize BGM/BGS\n")
  end
  
  # Restore BGM/BGS [not in VX]
  def self.command_248
    @@f.write(getIndent + "@>Restore BGM/BGS\n")
  end
  
  # Play ME
  def self.command_249
    text = getIndent + "@>Play ME: '" + @@params[0].name + "', "
    text += "#{@@params[0].volume}, #{@@params[0].pitch}\n"
    @@f.write(text)
  end
  
  # Play SE
  def self.command_250
    text = getIndent + "@>Play SE: '" + @@params[0].name + "', "
    text += "#{@@params[0].volume}, #{@@params[0].pitch}\n"
    @@f.write(text)
  end
  
  # Stop SE
  def self.command_251
    @@f.write(getIndent + "@>Stop SE\n")
  end
  
  # Battle Processing
  def self.command_301
    @@f.write(getIndent + "@>Battle Processing: " + @@troops[@@params[0]].name + "\n")
  end
  
  # If Win
  def self.command_601
    @@f.write(getIndent + ": If Win\n")
  end
  
  # If Escape
  def self.command_602
    @@f.write(getIndent + ": If Escape\n")
  end
  
  # If Lose
  def self.command_603
    @@f.write(getIndent + ": If Lose\n")
  end
  
  # Branch End (Battle Processing)
  def self.command_604
    @@f.write(getIndent + ": Branch End\n")
  end
  
  # Shop Processing
  def self.command_302
    text = getIndent + "@>Shop Processing: ["
    case @@params[0]
    when 0  # item
      text += @@items[@@params[1]].name
    when 1  # weapon
      text += @@weapons[@@params[1]].name
    when 2  # armor
      text += @@armors[@@params[1]].name
    end
    text += "]\n"
    loop do
      if @@list[@@index + 1].code == 605 # Subsequent lines of Shop Processing
        text += ": " + convertToSpaces("Shop Processing") + ": ["
        case @@list[@@index + 1].parameters[0]
        when 0  # item
          text += @@items[@@list[@@index + 1].parameters[1]].name
        when 1  # weapon
          text += @@weapons[@@list[@@index + 1].parameters[1]].name
        when 2  # armor
          text += @@armors[@@list[@@index + 1].parameters[1]].name
        end
        text += "]\n"
      else
        break
      end
      @@index += 1
    end
    @@f.write(text)
  end
  
  # Name Input Processing
  def self.command_303
    text = getIndent + "@>Name Input Processing: " + @@actors[@@params[0]].name
    text += ", #{@@params[1]} characters\n"
    @@f.write(text)
  end
  
  # Change HP
  def self.command_311
    text = getIndent + "@>Change HP: "
    if @@params[0] == 0 # entire party
      text += "Entire Party"
    else # specific actor
      text += "[" + @@actors[@@params[0]].name + "]"
    end
    text += ", " + ["+", "-"][@@params[1]] + " "
    if @@params[2] == 0 # invariable
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    if @@params[4]
      text += getIndent + "(Allow Knockout in Battle)\n"
    end
    @@f.write(text)
  end
  
  # Change SP
  def self.command_312
    text = getIndent + "@>Change SP: "
    if @@params[0] == 0 # entire party
      text += "Entire Party"
    else # specific actor
      text += "[" + @@actors[@@params[0]].name + "]"
    end
    text += ", " + ["+", "-"][@@params[1]] + " "
    if @@params[2] == 0 # invariable
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change State
  def self.command_313
    text = getIndent + "@>Change State: "
    if @@params[0] == 0 # entire party
      text += "Entire Party"
    else # specific actor
      text += "[" + @@actors[@@params[0]].name + "]"
    end
    text += ", " + ["+", "-"][@@params[1]] + " "
    text += "[" + @@states[@@params[2]].name + "]\n"
    @@f.write(text)
  end
  
  # Recover All
  def self.command_314
    text = getIndent + "@>Recover All: "
    if @@params[0] == 0 # entire party
      text += "Entire Party"
    else # specific actor
      text += "[" + @@actors[@@params[0]].name + "]"
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change EXP
  def self.command_315
    text = getIndent + "@>Change EXP: "
    if @@params[0] == 0 # entire party
      text += "Entire Party"
    else # specific actor
      text += "[" + @@actors[@@params[0]].name + "]"
    end
    text += ", " + ["+", "-"][@@params[1]] + " "
    if @@params[2] == 0 # invariable
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Level
  def self.command_316
    text = getIndent + "@>Change Level: "
    if @@params[0] == 0 # entire party
      text += "Entire Party"
    else # specific actor
      text += "[" + @@actors[@@params[0]].name + "]"
    end
    text += ", " + ["+", "-"][@@params[1]] + " "
    if @@params[2] == 0 # invariable
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Parameters
  def self.command_317
    text = getIndent + "@>Change Parameters: [" + @@actors[@@params[0]].name
    text += "], " + ["MaxHP", "MaxSP", "STR", "DEX", "AGI", "INT"][@@params[1]]
    text += " " + ["+", "-"][@@params[2]] + " "
    if @@params[3] == 0 # invariable
      text += "#{@@params[4]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[4])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Skills
  def self.command_318
    text = getIndent + "@>Change Skills: [" + @@actors[@@params[0]].name
    text += "], " + ["+", "-"][@@params[1]] + " "
    text += "[" + @@skills[@@params[2]].name + "]\n"
    @@f.write(text)
  end
  
  # Change Equipment
  def self.command_319
    text = getIndent + "@>Change Equipment: [" + @@actors[@@params[0]].name + "], "
    text += ["Weapon", "Shield", "Helmet", "Body Armor", "Accessory"][@@params[1]]
    text += " = "
    if @@params[2] == 0
      text += "(None)"
    else
      text += "["
      if @@params[1] == 0 # weapon
        text += @@weapons[@@params[2]].name
      else # shield, helmet, body armor, accessory
        text += @@armors[@@params[2]].name
      end
      text += "]"
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Actor Name
  def self.command_320
    text = getIndent + "@>Change Actor Name: [" + @@actors[@@params[0]].name
    text += "], '" + @@params[1] + "'\n"
    @@f.write(text)
  end
  
  # Change Actor Class
  def self.command_321
    text = getIndent + "@>Change Actor Class: [" + @@actors[@@params[0]].name
    text += "], [" + @@classes[@@params[1]].name + "]\n"
    @@f.write(text)
  end
  
  # Change Actor Graphic
  def self.command_322
    text = getIndent + "@>Change Actor Graphic: [" + @@actors[@@params[0]].name
    text += "], " + @@params[1] + ", #{@@params[2]}, "
    text += @@params[3] + ", #{@@params[4]}\n"
    @@f.write(text)
  end
  
  # Change Enemy HP
  def self.command_331
    text = getIndent + "@>Change Enemy HP: "
    if @@params[0] == -1 # entire troop
      text += "Entire Troop"
    else # specific enemy
      text += "[#{@@params[0] + 1}. " + getEnemyName(@@params[0]) + "]"
    end
    text += ", " + ["+", "-"][@@params[1]] + " "
    if @@params[2] == 0 # invariable
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    if @@params[4]
      text += getIndent + "(Allow Knockout in Battle)\n"
    end
    @@f.write(text)
  end
  
  # Change Enemy SP
  def self.command_332
    text = getIndent + "@>Change Enemy SP: "
    if @@params[0] == -1 # entire troop
      text += "Entire Troop"
    else # specific enemy
      text += "[#{@@params[0] + 1}. " + getEnemyName(@@params[0]) + "]"
    end
    text += ", " + ["+", "-"][@@params[1]] + " "
    if @@params[2] == 0 # invariable
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Change Enemy State
  def self.command_333
    text = getIndent + "@>Change Enemy State: "
    if @@params[0] == -1 # entire troop
      text += "Entire Troop"
    else # specific enemy
      text += "[#{@@params[0] + 1}. " + getEnemyName(@@params[0]) + "]"
    end
    text += ", " + ["+", "-"][@@params[1]] + " [" + @@states[@@params[2]].name + "]\n"
    @@f.write(text)
  end
  
  # Enemy Recover All
  def self.command_334
    text = getIndent + "@>Enemy Recover All: "
    if @@params[0] == -1 # entire troop
      text += "Entire Troop"
    else # specific enemy
      text += "[#{@@params[0] + 1}. " + getEnemyName(@@params[0]) + "]"
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Enemy Appearance
  def self.command_335
    text = getIndent + "@>Enemy Appearance: "
    text += "[#{@@params[0] + 1}. " + getEnemyName(@@params[0]) + "]\n"
    @@f.write(text)
  end
  
  # Enemy Transform
  def self.command_336
    text = getIndent + "@>Enemy Transform: "
    text += "[#{@@params[0] + 1}. " + getEnemyName(@@params[0])
    text += "], [" + @@enemies[@@params[1]].name + "]\n"
    @@f.write(text)
  end
  
  # Show Battle Animation
  def self.command_337
    text = getIndent + "@>Show Battle Animation: "
    if @@params[0] == 0 # enemy
      if @@params[1] == -1 # entire troop
        text += "Entire Troop"
      else # specific enemy
        text += "[#{@@params[1] + 1}. " + getEnemyName(@@params[1]) + "]"
      end
    else # actor
      if @@params[1] == -1 # entire party
        text += "Entire Party"
      else # specific actor
        text += "Actor No.#{@@params[1] + 1}"
      end
    end
    text += ", [" + @@animations[@@params[2]].name + "]\n"
    @@f.write(text)
  end
  
  # Deal Damage
  def self.command_338
    text = getIndent + "@>Deal Damage: "
    if @@params[0] == 0 # enemy
      if @@params[1] == -1 # entire troop
        text += "Entire Troop"
      else # specific enemy
        text += "[#{@@params[1] + 1}. " + getEnemyName(@@params[1]) + "]"
      end
    else # actor
      if @@params[1] == -1 # entire party
        text += "Entire Party"
      else # specific actor
        text += "Actor No.#{@@params[1] + 1}"
      end
    end
    text += ", "
    if @@params[2] == 0 # invariable
      text += "#{@@params[3]}"
    else # variable
      text += "Variable " + getVarIDName(@@params[3])
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Force Action
  def self.command_339
    text = getIndent + "@>Force Action: "
    if @@params[0] == 0 # enemy
      text += "[#{@@params[1] + 1}. " + getEnemyName(@@params[1]) + "]"
    else # actor
      text += "Actor No.#{@@params[1] + 1}"
    end
    text += ", "
    if @@params[2] == 0 # basic
      text += ["Attack", "Defend", "Escape", "Do Nothing"][@@params[3]]
    else # skill
      text += "[" + @@skills[@@params[3]].name + "]"
    end
    text += ", "
    if @@params[4] == -2  # last target
      text += "Last Target"
    elsif @@params[4] == -1  # random target
      text += "Random"
    else  # specific target
      text += "Index #{@@params[4] + 1}"
    end
    if @@params[5] == 1
      text += ", Execute Now"
    end
    text += "\n"
    @@f.write(text)
  end
  
  # Abort Battle
  def self.command_340
    @@f.write(getIndent + "@>Abort Battle\n")
  end
  
  # Call Menu Screen
  def self.command_351
    @@f.write(getIndent + "@>Call Menu Screen\n")
  end
  
  # Call Save Screen
  def self.command_352
    @@f.write(getIndent + "@>Call Save Screen\n")
  end
  
  # Game Over
  def self.command_353
    @@f.write(getIndent + "@>Game Over\n")
  end
  
  # Return to Title Screen
  def self.command_354
    @@f.write(getIndent + "@>Return to Title Screen\n")
  end
  
  # Script
  def self.command_355
    text = getIndent + "@>Script: " + @@params[0] + "\n"
    indent = getIndent + ": " + convertToSpaces("Script") + ": "
    loop do
      if @@list[@@index + 1].code == 655 # Subsequent lines of Script
        text += indent + @@list[@@index + 1].parameters[0] + "\n"
      else
        break
      end
      @@index += 1
    end
    @@f.write(text)
  end
end
EventExport.export if false