################################################################################
# * Unreal time system
################################################################################
if defined?($gameTimeLastCheck)
  $gameTimeLastCheck=0
end
if defined?($gameTimeTextLast)
  $gameTimeTextLast=''
end

def getDrawnTextWOutline(outline, text, fontSize)
  height=(fontSize*4/3).round
  bitmap=Bitmap.new(Graphics.width, height)
  bitmap.font.name='Arial Black' # $VersionStyles[$idk[:settings].font]
  bitmap.font.size=fontSize
  bitmap.font.color.set(0, 0, 0)
  bitmap.draw_text(0, 0, bitmap.width, bitmap.height, text, 0)
  
  bitmap2=Bitmap.new(Graphics.width, height)
  for i in 0...(outline*2+1)
    bitmap2.blt(0, i, bitmap, bitmap.rect)
  end
  
  bitmap3 = Bitmap.new(Graphics.width, height)
  bitmap3.blt(0, 0, bitmap2, bitmap2.rect)
  
  for i in 0...(outline*2+1)
    bitmap2.blt(i, 0, bitmap3, bitmap3.rect)
  end
  
  bitmap.font.color.set(255, 255, 255)
  bitmap.draw_text(outline, outline, bitmap.width, bitmap.height, text, 0)
  bitmap2.blt(0, 0, bitmap, bitmap.rect)
  
  return bitmap2
end

def getMinutes(minutes)
  return 0 if minutes < 15
  return 15 if minutes < 30
  return 30 if minutes < 45
  return 45
end

def getWDay(wday)
  return _INTL('Sunday')    if wday == 0
  return _INTL('Monday')    if wday == 1
  return _INTL('Tuesday')   if wday == 2
  return _INTL('Wednesday') if wday == 3
  return _INTL('Thursday')  if wday == 4
  return _INTL('Friday')    if wday == 5
  return _INTL('Saturday')
end

def getTimeText(gameTime)
  hour=gameTime.hour
  hour="#{hour}".rjust(2, '0')
  min=getMinutes(gameTime.min)
  min="#{min}".rjust(2, '0')
  wday=getWDay(gameTime.wday)
  return _INTL(' {1}:{2} {3}', hour, min, wday)
end

def isPokegearScene?
  if $scene.is_a?(Scene_FieldNotes) || $scene.is_a?(Scene_Jukebox) || $scene.is_a?(Scene_Pokegear) || 
    $scene.is_a?(Scene_PulseDex) || $scene.is_a?(Scene_TimeWeather)
    return true
  end  
end

def shouldShowClock?
  # Compatibility with the Additional Options mod
  return false if $game_switches[:Unreal_Time] != true
  if defined?($idk[:settings].unrealTimeClock)
    setting=$idk[:settings].unrealTimeClock
    return $game_temp.menu_calling if setting == 1
    return false if setting == 2 || isPokegearScene?
  end
  return true
end

def ensureClock
  if !defined?($unrealClock) || $unrealClock.disposed?
    $unrealClock = Sprite.new(nil)
    $unrealClock.ox = 0
    $unrealClock.oy = 0
    $unrealClock.x = 0
    $unrealClock.y = 0
    $unrealClock.z = 254
  end
  $unrealClock.visible = shouldShowClock?
end

def shouldDivergeTime?
  # Compatibility with the Additional Options mod
  return false if $game_switches[:Unreal_Time] != true
  if defined?($idk[:settings].unrealTimeDiverge)
    return $idk[:settings].unrealTimeDiverge == 1
  end
  return true
end

def getTimeScale
  # Compatibility with the Additional Options mod
  return $idk[:settings].unrealTimeTimeScale if defined?($idk[:settings].unrealTimeTimeScale)
  return 30.0
end

class Time
  if !defined?(self.unrealTime_oldTimeNew)
    class <<self
      alias_method :unrealTime_oldTimeNew, :new
    end
  end

  def self.new(*args, **kwargs)
    return $game_screen.getTimeCurrent if defined?($game_screen)
    return self.unrealTime_oldTimeNew(*args, **kwargs)
  end

  def self.now
    return $game_screen.getTimeCurrent if defined?($game_screen)
    return self.unrealTime_oldTimeNew
  end
end

class Game_Screen
  
  attr_accessor   :gameTimeCurrent

  def updateClock(gameTime, isHeartBeat)
    return nil if isHeartBeat
    ensureClock
    return nil if !$unrealClock.visible
    timeCurrent=getTimeText(gameTime)
    return nil if defined?($gameTimeTextLast) && timeCurrent == $gameTimeTextLast
    $gameTimeTextLast=timeCurrent
    $unrealClock.bitmap=getDrawnTextWOutline(2, timeCurrent, 24)
  end

  def handleTime
    timeNow=Time.unrealTime_oldTimeNew
    if !defined?($gameTimeLastCheck) || $gameTimeLastCheck == 0
      # $gameTimeLastCheck=timeNow
      diff=0.0
      isHeartBeat=false
    else
      diff=timeNow-$gameTimeLastCheck
      # Proceed once every 5 seconds (so graphics update and online requests
      # can be kept approximately unaltered)
      isHeartBeat=diff >= 0 && diff <= 5
    end
    $gameTimeLastCheck=timeNow if !isHeartBeat
    return timeNow, isHeartBeat if !shouldDivergeTime?
    if !defined?(@gameTimeCurrent)
      @gameTimeCurrent=timeNow
    end
    @gameTimeCurrent+=diff*getTimeScale if !isHeartBeat
    return @gameTimeCurrent, isHeartBeat
  end

  def getTimeCurrent(menucall=false)
    timeNow, isHeartBeat=handleTime
    isHeartBeat=false if menucall==true
    updateClock(timeNow, isHeartBeat)
    return timeNow
  end
end

class Scene_Map
  if !defined?(unrealTime_oldCallMenu)
    alias :unrealTime_oldCallMenu :call_menu
  end
  
  def call_menu(*args, **kwargs)  
    $game_screen.getTimeCurrent
    result=unrealTime_oldCallMenu(*args, **kwargs)
    $game_screen.getTimeCurrent
    return result
  end
end

################################################################################
# * Day and night system
################################################################################
def pbGetTimeNow
  return Time.now
  return $game_screen.getTimeCurrent if defined?($game_screen)
  return Time.unrealTime_oldTimeNew
end

module Graphics
  @@time_passed=0 ; @@start_playing=0
  def self.time_passed ; return @@time_passed ; end
  def self.time_passed=(value) ; @@time_passed=value ; end
  def self.start_playing ; return @@start_playing ; end
  def self.start_playing=(value) ; @@start_playing=value ; end
end



module PBDayNight
HourlyTones=[
     Tone.new(-50, -50, -16,120),   # Midnight
     Tone.new(-50, -50, -16,120),
     Tone.new(-50, -50, -16,120),
     Tone.new(-50, -50, -16,100),
     Tone.new(-48, -42, -14,75),
     Tone.new(-25,   -39, -14,45),
     Tone.new(-15,    -36,   -13, 20),      # 6AM
     Tone.new(7.2,  -32, -11,  10),
     Tone.new(5.3,  -24,   -10,  0),
     Tone.new(8.5,   -13, -9,  0),
     Tone.new(5.7,   -9,   -8,  0),
     Tone.new(2.8,   -4,  -6,  0),
     Tone.new(0,     0,     0,    0),      # Noon
     Tone.new(0,     0,     0,    0),
     Tone.new(0,     0,     0,    0),
     Tone.new(0,     0,     0,    0),
     Tone.new(-3,    -7,    -2,   0),
     Tone.new(-5,   -9,   -5,   0),
     Tone.new(-10,   -15,   -6,  10),      # 6PM
     Tone.new(-15,   -30,  -8,  25),
     Tone.new(-23, -39,  -12,  40),
     Tone.new(-36, -42,  -13,  60),
     Tone.new(-50, -50, -14,90),
     Tone.new(-50, -50, -16,120)
  ] 
  @cachedTone=nil
  @dayNightToneLastUpdate=nil

# Returns true if it's day.
  def self.isDay?(time)
    return (time.hour>=6 && time.hour<20)
  end

# Returns true if it's night.
  def self.isNight?(time)
    return (time.hour>=20 || time.hour<6)
  end

# Returns true if it's morning.
  def self.isMorning?(time)
    return (time.hour>=6 && time.hour<12)
  end

# Returns true if it's the afternoon.
  def self.isAfternoon?(time)
    return (time.hour>=12 && time.hour<20)
  end

# Returns true if it's the evening.
  def self.isEvening?(time)
    return (time.hour>=17 && time.hour<20)
  end
  
# Returns true if it's dusk.
  def self.isDusk?(time)
    return (time.hour>=17 && time.hour<18)
  end  

# Returns true if it's dawn.
def self.isDawn?(time)
  return (time.hour>=6 && time.hour<7)
end   

# Gets a number representing the amount of daylight (0=full night, 255=full day).
  def self.getShade
    time=pbGetDayNightMinutes
    time=(24*60)-time if time>(12*60)
    return 255*time/(12*60)
  end

# Gets a Tone object representing a suggested shading
# tone for the current time of day.
  def self.getTone()
    return Tone.new(0,0,0) if !ENABLESHADING
    if !@cachedTone
      @cachedTone=Tone.new(0,0,0)
    end
    if !@dayNightToneLastUpdate || @dayNightToneLastUpdate!=Graphics.frame_count       
      @cachedTone=getToneInternal()
      @dayNightToneLastUpdate=Graphics.frame_count
    end
    return @cachedTone
  end

  def self.pbGetDayNightMinutes
    now=pbGetTimeNow   # Get the current in-game time
    return (now.hour*60)+now.min
  end

  private

# Internal function

  def self.getToneInternal()
    # Calculates the tone for the current frame, used for day/night effects
    realMinutes=pbGetDayNightMinutes
    hour=realMinutes/60
    minute=realMinutes%60
    tone=PBDayNight::HourlyTones[hour]
    nexthourtone=PBDayNight::HourlyTones[(hour+1)%24]
    # Calculate current tint according to current and next hour's tint and
    # depending on current minute
    return Tone.new(
       ((nexthourtone.red-tone.red)*minute/60.0)+tone.red,
       ((nexthourtone.green-tone.green)*minute/60.0)+tone.green,
       ((nexthourtone.blue-tone.blue)*minute/60.0)+tone.blue,
       ((nexthourtone.gray-tone.gray)*minute/60.0)+tone.gray
    )
  end
end

def pbDayNightTint(object)
  if !$scene.is_a?(Scene_Map)
    return
  else
    if ENABLESHADING && pbGetMetadata($game_map.map_id,MetadataOutdoor)
      tone=PBDayNight.getTone()
      object.tone.set(tone.red,tone.green,tone.blue,tone.gray)
    else
      object.tone.set(0,0,0,0)  
    end
  end  
end

def pbDayNightTint2(object,outdoor)
  if !$scene.is_a?(Scene_Map)
    return
  else
    if ENABLESHADING && outdoor
      tone=PBDayNight.getTone()
      object.tone.set(tone.red,tone.green,tone.blue,tone.gray)
    else
      object.tone.set(0,0,0,0)  
    end
  end  
end

def pbIsWeekday(wdayVariable,*arg)
  timenow=pbGetTimeNow
  wday=timenow.wday
  ret=false
  for wd in arg
    ret=true if wd==wday
  end
  if wdayVariable>0
    $game_variables[wdayVariable]=[ 
       _INTL("Sunday"),
       _INTL("Monday"),
       _INTL("Tuesday"),
       _INTL("Wednesday"),
       _INTL("Thursday"),
       _INTL("Friday"),
       _INTL("Saturday")
    ][wday] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbIsMonth(wdayVariable,*arg)
  timenow=pbGetTimeNow
  wday=timenow.mon
  ret=false
  for wd in arg
    ret=true if wd==wday
  end
  if wdayVariable>0
    $game_variables[wdayVariable]=[ 
       _INTL("January"),
       _INTL("February"),
       _INTL("March"),
       _INTL("April"),
       _INTL("May"),
       _INTL("June"),
       _INTL("July"),
       _INTL("August"),
       _INTL("September"),
       _INTL("October"),
       _INTL("November"),
       _INTL("December")
    ][wday-1] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbGetAbbrevMonthName(month)
  return [_INTL(""),
          _INTL("Jan."),
          _INTL("Feb."),
          _INTL("Mar."),
          _INTL("Apr."),
          _INTL("May"),
          _INTL("Jun."),
          _INTL("Jul."),
          _INTL("Aug."),
          _INTL("Sep."),
          _INTL("Oct."),
          _INTL("Nov."),
          _INTL("Dec.")][month]
end