#===============================================================================
# ** Game_Screen
#-------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as change in color tone,
#  flashing, etc. Refer to "$game_screen" for the instance of this class.
#===============================================================================

class Game_Screen
  #-----------------------------------------------------------------------------
  # * Public Instance Variables
  #-----------------------------------------------------------------------------
  attr_reader     :brightness               # brightness
  attr_reader     :tone                     # color tone
  attr_reader     :flash_color              # flash color
  attr_reader     :shake                    # shake positioning
  attr_reader     :pictures                 # pictures
  attr_reader     :weather_type             # weather type
  attr_reader     :weather_max              # max number of weather sprites
  attr_reader     :previousDate             
  attr_accessor   :weatherVector   
  attr_reader     :vectorStarted
  attr_reader     :tone_duration
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @brightness = 255
    @fadeout_duration = 0
    @fadein_duration = 0
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = @tone
    @tone_duration = 0
    @flash_color = Color.new(0, 0, 0, 0)
    @flash_duration = 0
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
    @pictures = [nil]
    for i in 1..100
      @pictures.push(Game_Picture.new(i))
    end
    @weather_type = 0
    @weather_max = 0.0
    @weather_type_target = 0
    @weather_max_target = 0.0
    @weather_duration = 0
    @previousDate = nil
    @vectorStarted = false
  end
  
  def initialize_vector
    @weatherVector = Array.new(97)
    @vectorStarted = true
  end
  
  #-----------------------------------------------------------------------------
  # * Start Changing Color Tone
  #     tone : color tone
  #     duration : time
  #-----------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
  #-----------------------------------------------------------------------------
  # * Start Flashing
  #     color : color
  #     duration : time
  #-----------------------------------------------------------------------------
  def start_flash(color, duration)
    return if $idk[:settings].photosensitive==1
    @flash_color = color.clone
    @flash_duration = duration
  end
  #-----------------------------------------------------------------------------
  # * Start Shaking
  #     power : strength
  #     speed : speed
  #     duration : time
  #-----------------------------------------------------------------------------
  def start_shake(power, speed, duration)
    return if $idk[:settings].photosensitive==1
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #-----------------------------------------------------------------------------
  # * Set Weather
  #     type : type
  #     power : strength
  #     duration : time
  #-----------------------------------------------------------------------------
  def weather(type, power, duration)
    @weather_type_target = type
    if @weather_type_target != 0
      @weather_type = @weather_type_target
    end
    if @weather_type_target == 0
      @weather_max_target = 0.0
    else
      @weather_max_target = (power + 1) * 4.0
    end
    @weather_duration = duration
    if @weather_duration == 0
      @weather_type = @weather_type_target
      @weather_max = @weather_max_target
    end
  end
  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    if @fadeout_duration && @fadeout_duration >= 1
      d = @fadeout_duration
      @brightness = (@brightness * (d - 1)) / d
      @fadeout_duration -= 1
    end
    if @fadein_duration && @fadein_duration >= 1
      d = @fadein_duration
      @brightness = (@brightness * (d - 1) + 255) / d
      @fadein_duration -= 1
    end
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
    if @flash_duration >= 1
      d = @flash_duration
      @flash_color.alpha = @flash_color.alpha * (d - 1) / d
      @flash_duration -= 1
    end
    if @shake_duration >= 1 || @shake != 0
      delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
      if @shake_duration <= 1 && @shake * (@shake + delta) < 0
        @shake = 0
      else
        @shake += delta
      end
      if @shake > @shake_power * 2
        @shake_direction = -1
      end
      if @shake < - @shake_power * 2
        @shake_direction = 1
      end
      if @shake_duration >= 1
        @shake_duration -= 1
      end
    end
    if @weather_duration >= 1
      d = @weather_duration
      @weather_max = (@weather_max * (d - 1) + @weather_max_target) / d
      @weather_duration -= 1
      if @weather_duration == 0
        @weather_type = @weather_type_target
      end
    end
    if $game_temp.in_battle
      for i in 51..100
        @pictures[i].update
      end
    else
      for i in 1..50
        @pictures[i].update
      end
    end
  end

  def RerollWeather
    @previousDate = pbGetTimeNow.to_i - 432005
  end

  def ChangeWeatherPlan(aChoiceType)
    if (pbGetMetadata($game_map.map_id,MetadataOutdoor) )
      if ($game_switches[:Force_Weather])
        Kernel.pbMessage("The Plot forbids this right now.")
      else
        setWeather #Let the game update its internal calendar
        
        #Get current zone
        position = pbGetMetadata($game_map.map_id,MetadataMapPosition)
        posX = position[1]
        posY = position[2]
        if      posX < 6 and posY > 14
          region = 0 # Apophyll
        elsif ( posX < 10 and posY > 6 ) and !$game_switches[:Reborn_City_Restore]
          region = 1 # Reborn 
        elsif ( posX < 10 and posY > 6 ) and $game_switches[:Reborn_City_Restore]
          region = 2 # Reborn, Evolved
        elsif   posX < 8 and posY < 7
          region = 3 # Tourmaline
        elsif   posX > 7 and posY < 7
          region = 4 # Carnelia
        else
          region = 5 # Others
        end
        for i in 0..5
          regionOffset = 17 * i
          
          currentWeather = @weatherVector[101] + regionOffset
          
          #Change the planned weather here
          @weatherVector[currentWeather][0] = aChoiceType
          @weatherVector[currentWeather][1] = 1
        end
        
        setWeather #Give visual feedback of the change
        
        Kernel.pbMessage("The weather has been set.")
        Kernel.pbMessage("Go inside to update the events.")
      end
    else
      Kernel.pbMessage("Only works outside.")
    end
  end
  #-----------------------------------------------------------------------------
  # * Events
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  # * Set Weather Event (006)
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  # * Events
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  # * Set Weather Event (006)
  #-----------------------------------------------------------------------------
  def determineWeatherRegion
    position = pbGetMetadata($game_map.map_id,MetadataMapPosition)
    posX = position[1]
    posY = position[2]
    if posY == 7 && posX == 8
        return 2 # A specific section of Route 2 that was problematic, thank you gamefreak very cool #take 2: if this breaks again i quit
    elsif posY < 7
      if posX < 8
        return 3 # Tourmaline
      else
        return 4 # Carnelia
      end
    elsif posY > 14 && posX != 9 || posY==14 && posX==0 # x of 9 indicates south obsidia + coral
      if posX < 6
        return 0 # Apophyll
      else
        return 5 # Others
      end
    else #assumes 6 < posY < 14
      if posX < 10
        if $game_switches[:Reborn_City_Restore]
          return 2 # Reborn, Evolved
        else
          return 1 # Reborn 
        end
      else
        return 5 # Others
      end
    end
  end

  def setWeather
    if !@vectorStarted
      initialize_vector
    end    
    outdoor  = pbGetMetadata($game_map.map_id,MetadataOutdoor)  
    if !outdoor
      $game_screen.weather(0,0,20)
    else
      @weatherVector[101] = @weatherVector[96] if @weatherVector[101].nil?
      region = determineWeatherRegion
      regionOffset = 17 * region
      #unix time: 1 hr = 3600; 8hr = 28800; 5 days = 432000
      currentDate  = Time.now.to_i
      @weatherVector[16] = currentDate if @weatherVector[16] == nil
      prevTime = @weatherVector[16]
      timeDifference1 = currentDate - prevTime
      $game_variables[790] = Time.at(Time.now.to_i + 28800 - timeDifference1)
      timeDifference2 = 0
      timeDifference2 = currentDate - @previousDate.to_i if @previousDate
      if (!@previousDate || timeDifference2 > 432000 || @weatherVector[101] == -1) 
        createArchetype(regionOffset)
        regionArchetype(region, regionOffset)
        @previousDate = currentDate
        @weatherVector[101] = 0
        @weatherVector[16] = Time.now.to_i
        $game_variables[:Place_In_Weather_Pattern] = 0
      elsif timeDifference1 > 28800
        blockCount = (timeDifference1 / 28800).to_i
        @weatherVector[101] = @weatherVector[101] + blockCount
        @weatherVector[16] = Time.now.to_i
        $game_variables[:Place_In_Weather_Pattern] = blockCount
      end
      currentWeather = @weatherVector[101] + regionOffset
      # Deliberately mispredicts weather at the end of an archetype, check TV for archetype updates
      @weatherVector[101] % 14 != 0 ? nextBlock = 1 : nextBlock = 0   
      nextWeather = @weatherVector[101] + regionOffset + nextBlock
      $game_variables[789] = @weatherVector[nextWeather][0]
      if $game_switches[:Force_Weather] == true
        $game_screen.weather($game_variables[106],3,20)
      else
        current2 = Time.new
        if @weatherVector[currentWeather][0] != 5 || (current2.hour > 6 &&
         current2.hour < 19)
          $game_variables[:Current_Weather] = @weatherVector[currentWeather][0]
          $game_screen.weather(@weatherVector[currentWeather][0],@weatherVector[currentWeather][1],20)
        else
          $game_variables[:Current_Weather] = 0
          $game_screen.weather(0,0,20)
        end
        $game_map.need_refresh = true
      end
    end
  end  

  def createArchetype(regionOffset)
    if $game_variables[:Next_Weather_Archetype] == 0
      $game_variables[:Next_Weather_Archetype] = 1 + rand(6) 
    end
    $game_variables[:Weather_Randomizer] = $game_variables[:Next_Weather_Archetype]
    loop do
      @weatherVector[15] = 1 + rand(6) 
      if @weatherVector[15] != $game_variables[:Weather_Randomizer] 
        break
      end
    end
    $game_variables[:Next_Weather_Archetype] = @weatherVector[15]
    if $game_switches[:Stable_Weather_Password] == true
      @weatherVector[15] = 6
      $game_variables[:Next_Weather_Archetype] = 6
      $game_variables[:Weather_Randomizer] = 6
    end 
    archetype = $game_variables[:Weather_Randomizer]
    i = 0
    for i in 0..6
      tempOffset = 17 * i
      case archetype
        when 1 # dry spell
          @weatherVector[0 + tempOffset]  = [0,0]
          @weatherVector[1 + tempOffset]  = [0,0]
          @weatherVector[2 + tempOffset]  = [5,1]
          @weatherVector[3 + tempOffset]  = [5,3]
          @weatherVector[4 + tempOffset]  = [5,5]
          @weatherVector[5 + tempOffset]  = [5,4]
          @weatherVector[6 + tempOffset]  = [5,3]
          @weatherVector[7 + tempOffset]  = [5,1]
          @weatherVector[8 + tempOffset]  = [6,3]
          @weatherVector[9 + tempOffset]  = [6,4]
          @weatherVector[10 + tempOffset] = [6,5]
          @weatherVector[11 + tempOffset] = [6,2]
          @weatherVector[12 + tempOffset] = [0,0]
          @weatherVector[13 + tempOffset] = [6,1]
          @weatherVector[14 + tempOffset] = [6,3]                       
        when 2 # showers
          @weatherVector[0 + tempOffset]  = [1,2]
          @weatherVector[1 + tempOffset]  = [2,2]
          @weatherVector[2 + tempOffset]  = [2,3]
          @weatherVector[3 + tempOffset]  = [2,3]
          @weatherVector[4 + tempOffset]  = [2,1]
          @weatherVector[5 + tempOffset]  = [1,2]
          @weatherVector[6 + tempOffset]  = [6,4]
          @weatherVector[7 + tempOffset]  = [6,5]
          @weatherVector[8 + tempOffset]  = [6,3]
          @weatherVector[9 + tempOffset]  = [6,1]
          @weatherVector[10 + tempOffset] = [0,0]
          @weatherVector[11 + tempOffset] = [6,1]
          @weatherVector[12 + tempOffset] = [5,2]
          @weatherVector[13 + tempOffset] = [5,3]
          @weatherVector[14 + tempOffset] = [0,1]                           
        when 3 # chilly
          @weatherVector[0 + tempOffset]  = [0,0]
          @weatherVector[1 + tempOffset]  = [1,1]
          @weatherVector[2 + tempOffset]  = [1,2]
          @weatherVector[3 + tempOffset]  = [6,5]
          @weatherVector[4 + tempOffset]  = [6,3]
          @weatherVector[5 + tempOffset]  = [1,2]
          @weatherVector[6 + tempOffset]  = [6,1]
          @weatherVector[7 + tempOffset]  = [1,1]
          @weatherVector[8 + tempOffset]  = [1,2]
          @weatherVector[9 + tempOffset]  = [2,2]
          @weatherVector[10 + tempOffset] = [6,2]
          @weatherVector[11 + tempOffset] = [6,3]
          @weatherVector[12 + tempOffset] = [1,1]
          @weatherVector[13 + tempOffset] = [6,3]
          @weatherVector[14 + tempOffset] = [3,1]                         
        when 4 # wet
          @weatherVector[0 + tempOffset]  = [3,1]
          @weatherVector[1 + tempOffset]  = [3,2]
          @weatherVector[2 + tempOffset]  = [3,4]
          @weatherVector[3 + tempOffset]  = [3,2]
          @weatherVector[4 + tempOffset]  = [1,3]
          @weatherVector[5 + tempOffset]  = [1,4]
          @weatherVector[6 + tempOffset]  = [1,5]
          @weatherVector[7 + tempOffset]  = [2,2]
          @weatherVector[8 + tempOffset]  = [1,4]
          @weatherVector[9 + tempOffset]  = [1,1]
          @weatherVector[10 + tempOffset] = [2,2]
          @weatherVector[11 + tempOffset] = [2,2]
          @weatherVector[12 + tempOffset] = [1,2]
          @weatherVector[13 + tempOffset] = [6,3]
          @weatherVector[14 + tempOffset] = [0,0]
        when 5 # blizzard
          @weatherVector[0 + tempOffset]  = [3,1] 
          @weatherVector[1 + tempOffset]  = [3,2]
          @weatherVector[2 + tempOffset]  = [3,4]
          @weatherVector[3 + tempOffset]  = [3,5]
          @weatherVector[4 + tempOffset]  = [3,4]
          @weatherVector[5 + tempOffset]  = [3,2]
          @weatherVector[6 + tempOffset]  = [3,1]
          @weatherVector[7 + tempOffset]  = [3,1]
          @weatherVector[8 + tempOffset]  = [3,3]
          @weatherVector[9 + tempOffset]  = [3,4]
          @weatherVector[10 + tempOffset] = [3,5]
          @weatherVector[11 + tempOffset] = [3,3]
          @weatherVector[12 + tempOffset] = [0,0]
          @weatherVector[13 + tempOffset] = [6,1]
          @weatherVector[14 + tempOffset] = [6,2]                   
        when 6 # variety
          @weatherVector[0 + tempOffset]  = [3,1]
          @weatherVector[1 + tempOffset]  = [3,2]
          @weatherVector[2 + tempOffset]  = [3,3]
          @weatherVector[3 + tempOffset]  = [3,1]
          @weatherVector[4 + tempOffset]  = [6,4]
          @weatherVector[5 + tempOffset]  = [6,3]
          @weatherVector[6 + tempOffset]  = [6,2]
          @weatherVector[7 + tempOffset]  = [1,1]
          @weatherVector[8 + tempOffset]  = [2,1]
          @weatherVector[9 + tempOffset]  = [2,2]
          @weatherVector[10 + tempOffset] = [6,1]
          @weatherVector[11 + tempOffset] = [6,2]
          @weatherVector[12 + tempOffset] = [0,0]
          @weatherVector[13 + tempOffset] = [5,2]
          @weatherVector[14 + tempOffset] = [5,3]                 
        end
    end
    @weatherVector[101] = -1
    @weatherVector[15 + regionOffset] = [0,0]
  end

  def regionArchetype(region, regionOffset)
    j = 0
    for j in 0..6
      tempOffset = 17 * j
      startPosition = tempOffset
      endPosition = tempOffset + 14
      for i in startPosition .. endPosition
        case j
          when 0
            case @weatherVector[i][0]
              when 1
                 @weatherVector[i][1] =  @weatherVector[i][1] - 2
              when 2
                 @weatherVector[i][1] =  @weatherVector[i][1] - 3
              when 3
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
              when 4
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
            end
          when 1
            case  @weatherVector[i][0]
              when 1
                 @weatherVector[i][1] =  @weatherVector[i][1] - 1
              when 3
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
              when 4
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
              when 5
                 @weatherVector[i][1] =  @weatherVector[i][1] - 1
              when 6
                 @weatherVector[i][1] =  @weatherVector[i][1] - 1
            end
          when 2
            case  @weatherVector[i][0]
              when 2
                 @weatherVector[i][1] =  @weatherVector[i][1] - 1
              when 3
                 @weatherVector[i][1] =  @weatherVector[i][1] - 1
              when 4
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
              when 5
                 @weatherVector[i][1] =  @weatherVector[i][1] - 4
              when 6
                 @weatherVector[i][1] =  @weatherVector[i][1] - 1
            end
          when 3
            case  @weatherVector[i][0]
              when 1
                 @weatherVector[i][1] =  @weatherVector[i][1] - 4
              when 2
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
              when 3
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
              when 6
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
            end
          when 4
            case  @weatherVector[i][0]
              when 1
                 @weatherVector[i][1] =  @weatherVector[i][1] - 4
              when 2
                 @weatherVector[i][1] =  @weatherVector[i][1] - 4
              when 4
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
              when 5
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
              when 6
                 @weatherVector[i][1] =  @weatherVector[i][1] - 4
            end
          when 5
            case @weatherVector[i][0]
              when 1
                 @weatherVector[i][1] =  @weatherVector[i][1] - 1
              when 3
                 @weatherVector[i][1] =  @weatherVector[i][1] - 4
              when 4
                 @weatherVector[i][1] =  @weatherVector[i][1] - 5
              when 5
                 @weatherVector[i][1] =  @weatherVector[i][1] - 4
              when 6
                 @weatherVector[i][1] =  @weatherVector[i][1] - 1
            end
        end
        if  @weatherVector[i][1] == 0
          @weatherVector[i][0] = 0
        end
        if  @weatherVector[i][1] < 0
          case j
            when 0
               @weatherVector[i][0] = 0
            when 1
               @weatherVector[i][0] = 0
            when 2
               @weatherVector[i][0] = 0
            when 3
               @weatherVector[i][0] = 4
            when 4
               @weatherVector[i][0] = 3
            when 5
               @weatherVector[i][0] = 1
          end
          @weatherVector[i][1] =  @weatherVector[i][1]*(-1)  
        end
      end
    end
  end
  
end