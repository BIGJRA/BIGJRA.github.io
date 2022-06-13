################################################################################
# * Day and night system
################################################################################
def pbGetTimeNow
  return Time.now
end



module PBDayNight
  HourlyTones = [
     Tone.new(-68, -63, -58, 80),   # Midnight
     Tone.new(-68, -63, -58, 80),
     Tone.new(-68, -63, -58, 80),
     Tone.new(-68, -63, -58, 70),
     Tone.new(-63, -59, -57, 50),
     Tone.new(-35, -52, -55, 30),
     Tone.new(-20, -48, -51, 20),      # 6AM
     Tone.new(7.2, -43, -44, 10),
     Tone.new(5.3, -34, -40,  0),
     Tone.new(8.5, -26, -36,  0),
     Tone.new(5.7, -17, -28,  0),
     Tone.new(2.8,  -8, -17,  0),
     Tone.new(  0,   0,   0,  0),      # Noon
     Tone.new(  0,   0,   0,  0),
     Tone.new(  0,   0,   0,  0),
     Tone.new(  0,   0,   0,  0),
     Tone.new( -3,  -7,  -2,  0),
     Tone.new(-10, -18,  -5,  0),
     Tone.new(-12, -20, -20,  0),      # 6PM
     Tone.new(-20, -40, -33,  3),
     Tone.new(-30, -52, -47, 13),
     Tone.new(-45, -55, -50, 28),
     Tone.new(-68, -62, -55, 38),
     Tone.new(-68, -63, -58, 60)
  ]
  @cachedTone = nil
  @dayNightToneLastUpdate = nil
  @oneOverSixty = 1/60.0

# Returns true if it's day.
  def self.isDay?(time=nil)
    if $game_switches[1289] || $game_switches[1290] || $game_switches[1291]
      if $game_switches[1289]
        return true
      else
        return false
      end
    end
    time = pbGetTimeNow if !time
    return (time.hour>=6 && time.hour<20)
  end

# Returns true if it's night.
  def self.isNight?(time=nil)
    if $game_switches[1289] || $game_switches[1290] || $game_switches[1291]
      if $game_switches[1291]
        return true
      else
        return false
      end
    end
    time = pbGetTimeNow if !time
    return (time.hour>=20 || time.hour<6)
  end

# Returns true if it's morning.
  def self.isMorning?(time=nil)
    if $game_switches[1289] || $game_switches[1290] || $game_switches[1291]
      if $game_switches[1289]
        return true
      else
        return false
      end
    end
    time = pbGetTimeNow if !time
    return (time.hour>=6 && time.hour<12)
  end

# Returns true if it's the afternoon.
  def self.isAfternoon?(time=nil)
    if $game_switches[1289] || $game_switches[1290] || $game_switches[1291]
      if $game_switches[1289]
        return true
      else
        return false
      end
    end
    time = pbGetTimeNow if !time
    return (time.hour>=12 && time.hour<20)
  end

# Returns true if it's the evening.
  def self.isEvening?(time=nil)
    if $game_switches[1289] || $game_switches[1290] || $game_switches[1291]
      if $game_switches[1290]
        return true
      else
        return false
      end
    end
    time = pbGetTimeNow if !time
    return (time.hour>=17 && time.hour<20)
  end
  
# Returns true if it's dusk
  def self.isDusk?(time=nil)
    if $game_switches[1289] || $game_switches[1290] || $game_switches[1291]
      if $game_switches[1290]
        return true
      else
        return false
      end
    end
    time = pbGetTimeNow if !time
    return (time.hour>=17 && time.hour<18)
  end

# Gets a number representing the amount of daylight (0=full night, 255=full day).
  def self.getShade
    time=pbGetDayNightMinutes
    time=(24*60)-time if time>(12*60)
    shade=255*time/(12*60)
  end

#### SARDINES - v17 - START
# Gets a Tone object representing a suggested shading
# tone for the current time of day.
  def self.getTone()
    @cachedTone = Tone.new(0,0,0) if !@cachedTone
    return @cachedTone if !ENABLESHADING
    if !@dayNightToneLastUpdate ||
       Graphics.frame_count-@dayNightToneLastUpdate>=Graphics.frame_rate*30
      getToneInternal
      @dayNightToneLastUpdate = Graphics.frame_count
    end
    return @cachedTone
  end
#### SARDINES - v17 - END
  
  def self.pbGetDayNightMinutes
    now = pbGetTimeNow   # Get the current in-game time
    return (now.hour*60)+now.min
  end

  private

# Internal function

  def self.getToneInternal()
    # Calculates the tone for the current frame, used for day/night effects
    realMinutes = pbGetDayNightMinutes
    hour   = realMinutes/60
    minute = realMinutes%60
    tone         = PBDayNight::HourlyTones[hour]
    nexthourtone = PBDayNight::HourlyTones[(hour+1)%24]
    # Calculate current tint according to current and next hour's tint and
    # depending on current minute
    @cachedTone.red   = ((nexthourtone.red-tone.red)*minute*@oneOverSixty)+tone.red
    @cachedTone.green = ((nexthourtone.red-tone.green)*minute*@oneOverSixty)+tone.green
    @cachedTone.blue  = ((nexthourtone.red-tone.blue)*minute*@oneOverSixty)+tone.blue
    @cachedTone.gray  = ((nexthourtone.red-tone.gray)*minute*@oneOverSixty)+tone.gray
  end
end



def pbDayNightTint(object)
  return if !$scene.is_a?(Scene_Map)
  noTime = [155,357,358,359,360,362,368,408,506]
  if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
    object.tone.set(0,0,0,0)
  else
    if $game_switches[1289]
      tone = PBDayNight::HourlyTones[12]
      object.tone.set(tone.red,tone.green,tone.blue,tone.gray)
    elsif $game_switches[1290]
      tone = PBDayNight::HourlyTones[19]
      object.tone.set(tone.red,tone.green,tone.blue,tone.gray)
    elsif $game_switches[1291]
      tone = PBDayNight::HourlyTones[0]
      object.tone.set(tone.red,tone.green,tone.blue,tone.gray)
    elsif ENABLESHADING && !noTime.include?($game_map.map_id)
      tone=PBDayNight.getTone
      object.tone.set(tone.red,tone.green,tone.blue,tone.gray)
    elsif ENABLESHADING && noTime.include?($game_map.map_id) && PBDayNight.isNight?(pbGetTimeNow)
      object.tone.set(-30,-30,-30)
    else
      object.tone.set(0,0,0,0)
    end
  end
end



################################################################################
# * Zodiac and day/month checks
################################################################################
# Calculates the phase of the moon.
# 0 - New Moon
# 1 - Waxing Crescent
# 2 - First Quarter
# 3 - Waxing Gibbous
# 4 - Full Moon
# 5 - Waning Gibbous
# 6 - Last Quarter
# 7 - Waning Crescent
def moonphase(time=nil) # in UTC
  time = pbGetTimeNow if !time
  transitions=[
     1.8456618033125,
     5.5369854099375,
     9.2283090165625,
     12.9196326231875,
     16.6109562298125,
     20.3022798364375,
     23.9936034430625,
     27.6849270496875]
  yy = time.year-((12-time.mon)/10.0).floor
  j = (365.25*(4712+yy)).floor + (((time.mon+9)%12)*30.6+0.5).floor + time.day+59
  j -= (((yy/100.0)+49).floor*0.75).floor-38 if j>2299160
  j += (((time.hour*60)+time.min*60)+time.sec)/86400.0
  v = (j-2451550.1)/29.530588853
  v = ((v-v.floor)+(v<0 ? 1 : 0))
  ag = v*29.53
  for i in 0...transitions.length
    return i if ag<=transitions[i]
  end
  return 0
end

# Calculates the zodiac sign based on the given month and day:
# 0 is Aries, 11 is Pisces. Month is 1 if January, and so on.
def zodiac(month,day)
  time = [
     3,21,4,19,   # Aries
     4,20,5,20,   # Taurus
     5,21,6,20,   # Gemini
     6,21,7,20,   # Cancer
     7,23,8,22,   # Leo
     8,23,9,22,   # Virgo 
     9,23,10,22,  # Libra
     10,23,11,21, # Scorpio
     11,22,12,21, # Sagittarius
     12,22,1,19,  # Capricorn
     1,20,2,18,   # Aquarius
     2,19,3,20    # Pisces
  ]
  for i in 0...12
    return i if month==time[i*4] && day>=time[i*4+1]
    return i if month==time[i*4+2] && day<=time[i*4+3]
  end
  return 0
end
 
# Returns the opposite of the given zodiac sign.
# 0 is Aries, 11 is Pisces.
def zodiacOpposite(sign)
  return (sign+6)%12
end

# 0 is Aries, 11 is Pisces.
def zodiacPartners(sign)
  return [(sign+4)%12,(sign+8)%12]
end

# 0 is Aries, 11 is Pisces.
def zodiacComplements(sign)
  return [(sign+1)%12,(sign+11)%12]
end

def pbIsWeekday(wdayVariable,*arg)
  timenow = pbGetTimeNow
  wday = timenow.wday
  ret = false
  for wd in arg
    ret = true if wd==wday
  end
  if wdayVariable>0
    $game_variables[wdayVariable] = [ 
       _INTL("Sunday"),
       _INTL("Monday"),
       _INTL("Tuesday"),
       _INTL("Wednesday"),
       _INTL("Thursday"),
       _INTL("Friday"),
       _INTL("Saturday")][wday]
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbIsMonth(monVariable,*arg)
  timenow = pbGetTimeNow
  thismon = timenow.mon
  ret = false
  for wd in arg
    ret = true if wd==thismon
  end
  if monVariable>0
    $game_variables[monVariable] = [ 
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
    ][thismon-1] 
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