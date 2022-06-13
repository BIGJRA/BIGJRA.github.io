class Thread
  def Thread.exclusive
    _old = Thread.critical
    begin
      Thread.critical = true
      return yield
    ensure
      Thread.critical = _old
    end
  end
end

#####################################
# Needed because RGSS doesn't call at_exit procs on exit
# Exit is not called when game is reset (using F12)
$AtExitProcs=[] if !$AtExitProcs

def exit(code=0)
  for p in $AtExitProcs
    p.call
  end
  raise SystemExit.new(code)
end

def at_exit(&block)
  $AtExitProcs.push(Proc.new(&block))
end

#####################################
# Works around a problem with FileTest.exist
# if directory contains accent marks
def safeExists?(f)
  ret=false
  File.open(f,"rb") { ret=true } rescue nil
  return ret
end

def Audio_bgm_playing?
  AudioState.channel!=nil
end

def Audio_bgm_name
  AudioState.name
end

def Audio_bgm_pitch
  AudioState.pitch
end

def Audio_bgm_play(name, volume, pitch, position = 0)
  volume=0 if !getPlayMusic()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    if AudioState.meActive?
      AudioState.setWaitingBGM(filename,volume,pitch,position)
      return
    end
    AudioState::AudioContextPlay.call(AudioState.context,filename,volume,pitch,position,1)
    AudioState.name=filename
    AudioState.volume=volume
    AudioState.pitch=pitch
  rescue Hangup
  rescue
    p $!.message,$!.backtrace
  end
end

def Audio_me_play(name, volume, pitch, position = 0)
  volume=0 if !getPlayMusic()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    if AudioState.bgmActive?
      bgmPosition=Kernel.Audio_bgm_get_position
      AudioState.setWaitingBGM(
        AudioState.name,
        AudioState.volume,
        AudioState.pitch,
        bgmPosition
      )
      AudioState::AudioContextStop.call(AudioState.context)
    end
    AudioState::AudioContextPlay.call(AudioState.meContext,filename,
       volume,pitch,position,0)
    rescue
    p $!.message,$!.backtrace
  end
end

def Audio_me_fade(ms)
  AudioState::AudioContextFadeOut.call(AudioState.meContext,ms)
end

def Audio_me_stop()
  AudioState::AudioContextStop.call(AudioState.meContext) 
end

def Audio_bgm_stop()
  begin
    AudioState::AudioContextStop.call(AudioState.context)
    AudioState.waitingBGM=nil
    AudioState.name = ""
    rescue
    p $!.message,$!.backtrace
  end
end

def Audio_bgm_get_position
  return AudioState::AudioContextGetPosition.call(AudioState.context)
end

def Audio_bgm_fade(ms)
  AudioState::AudioContextFadeOut.call(AudioState.context,ms.to_i)
end

def Audio_bgm_fadein(ms)
  AudioState::AudioContextFadeIn.call(AudioState.context,ms.to_i)
end

def Audio_bgm_get_volume
  return 0 if !AudioState.bgmActive?
  return AudioState.volume
end

def Audio_bgm_set_volume(volume)
  return if !AudioState.bgmActive?
  AudioState.volume = volume * 1.0
  AudioState::AudioContextSetVolume.call(AudioState.context,volume.to_i)
end

def Audio_bgs_play(name, volume, pitch, position = 0)
  volume=0 if !getPlaySound()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    AudioState::AudioContextPlay.call(AudioState.bgsContext,filename,
       volume,pitch,position,0)
    rescue
    p $!.message,$!.backtrace
  end
end

def Audio_bgs_fade(ms)
  AudioState::AudioContextFadeOut.call(AudioState.bgsContext,ms)
end

def Audio_bgs_stop()
  AudioState::AudioContextStop.call(AudioState.bgsContext) 
end


def Audio_se_play(name, volume, pitch, position = 0)
  volume=0 if !getPlaySound()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    AudioState::AudioContextSEPlay.call(AudioState.seContext,filename,
       volume,pitch,position)
    rescue
    p $!.message,$!.backtrace
  end
end

def Audio_se_stop()
  AudioState::AudioContextStop.call(AudioState.seContext) 
end


def pbStringToAudioFile(str)
  if str[/^(.*)\:\s*(\d+)\s*\:\s*(\d+)\s*$/]
    file=$1
    volume=$2.to_i
    pitch=$3.to_i
    return RPG::AudioFile.new(file,volume,pitch)
  elsif str[/^(.*)\:\s*(\d+)\s*$/]
    file=$1
    volume=$2.to_i
    return RPG::AudioFile.new(file,volume,100)
  else
    return RPG::AudioFile.new(str,100,100)
  end
end

# Converts an object to an audio file. 
# str -- Either a string showing the filename or an RPG::AudioFile object.
# Possible formats for _str_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbResolveAudioFile(str,volume=nil,pitch=nil)
  if str.is_a?(String)
    str=pbStringToAudioFile(str)
    str.volume=100
    #str.volume=volume if volume
    str.pitch=100
    #str.pitch=pitch if pitch
  end
  str.volume=volume if volume
  str.pitch=pitch if pitch
  if str.is_a?(RPG::AudioFile)
    return RPG::AudioFile.new(str.name, str.volume, str.pitch)
  end
  return str
end

# Plays a BGM file.
# param -- Either a string showing the filename 
# (relative to Audio/BGM/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGMPlay(param,volume=nil,pitch=nil, reset_volume: false)
  return if !param 
  if !reset_volume && $idk[:settings].volume
    if volume && $idk[:settings].volume
      volume = volume * ($idk[:settings].volume/100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $idk[:settings].volume
      volume = param.volume * ($idk[:settings].volume/100.00)
    elsif !volume && $idk[:settings].volume
      volume = $idk[:settings].volume 
    elsif !reset_volume
      volume=100
    end
  end
  param=pbResolveAudioFile(param.clone,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("bgm_play")
      $game_system.bgm_play(param)
      return
    elsif (RPG.const_defined?(:BGM) rescue false)
      b=RPG::BGM.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.bgm_play(canonicalize("Audio/BGM/"+param.name),param.volume,param.pitch)
  end
end

# Plays an ME file.
# param -- Either a string showing the filename 
# (relative to Audio/ME/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbMEPlay(param,volume=nil,pitch=nil)
  return if !param
  if $idk[:settings].volume
    if volume && $idk[:settings].volume
      volume = volume * ($idk[:settings].volume/100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $idk[:settings].volume
      volume = param.volume * ($idk[:settings].volume/100.00)
    elsif !volume && $idk[:settings].volume
      volume = $idk[:settings].volume 
    end
  else
    volume=100
  end
  param=pbResolveAudioFile(param.clone,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("me_play")
      $game_system.me_play(param)
      return
    elsif (RPG.const_defined?(:ME) rescue false)
      b=RPG::ME.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.me_play(canonicalize("Audio/ME/"+param.name),param.volume,param.pitch)
  end
end

# Plays a BGS file.
# param -- Either a string showing the filename 
# (relative to Audio/BGS/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGSPlay(param,volume=nil,pitch=nil)
  return if !param
  if $idk[:settings].volume
    if volume && $idk[:settings].volume
      volume = volume * ($idk[:settings].volume/100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $idk[:settings].volume
      volume = param.volume * ($idk[:settings].volume/100.00)
    elsif !volume && $idk[:settings].volume
      volume = $idk[:settings].volume 
    end
  else
    volume=100
  end
  param=pbResolveAudioFile(param.clone,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("bgs_play")
      $game_system.bgs_play(param)
      return
    elsif (RPG.const_defined?(:BGS) rescue false)
      b=RPG::BGS.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.bgs_play(canonicalize("Audio/BGS/"+param.name),param.volume,param.pitch)
  end
end

class WaveData
  def initialize(samplesPerSec,samples)
    return
  end

  def self._load(string)
    
    return 
  end

end

# Plays an SE file.
# param -- Either a string showing the filename 
# (relative to Audio/SE/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbSEPlay(param,volume=nil,pitch=nil)
  return if !param
  if $idk[:settings].sevolume
    if volume && $idk[:settings].sevolume
      volume = volume * ($idk[:settings].sevolume/100.00) #($idk[:settings].volume/100.00)
    elsif !volume && param.is_a?(RPG::AudioFile) && $idk[:settings].sevolume
      volume = param.volume * ($idk[:settings].sevolume/100.00)
    elsif !volume && $idk[:settings].sevolume
      volume = $idk[:settings].sevolume
    end
  else
    volume=100
  end
  param=pbResolveAudioFile(param.clone,volume,pitch)
  if param.name && param.name!=""
    if $game_system && $game_system.respond_to?("se_play")
      $game_system.se_play(param)
      return
    elsif (RPG.const_defined?(:SE) rescue false)
      b=RPG::SE.new(param.name,param.volume,param.pitch)
      if b && b.respond_to?("play")
        b.play; return
      end
    end
    Audio.se_play(canonicalize("Audio/SE/"+param.name),param.volume,param.pitch)
  end
end

# Stops SE playback.
def pbSEFade(x=0.0); pbSEStop(x);end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEFade(x=0.0); pbMEStop(x);end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMFade(x=0.0); pbBGMStop(x);end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSFade(x=0.0); pbBGSStop(x);end

# Stops SE playback.
def pbSEStop(timeInSeconds=0.0)
  if $game_system
    $game_system.se_stop
  elsif (RPG.const_defined?(:SE) rescue false)
    RPG::SE.stop rescue nil
  else
    Audio.se_stop
  end
end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEStop(timeInSeconds=0.0)
  if $game_system && timeInSeconds>0.0 && $game_system.respond_to?("me_fade")
    $game_system.me_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("me_stop")
    $game_system.me_stop(nil)
    return
  elsif (RPG.const_defined?(:ME) rescue false)
    begin
      (timeInSeconds>0.0) ? RPG::ME.fade((timeInSeconds*1000).floor) : RPG::ME.stop
      return
      rescue
    end
  end
  (timeInSeconds>0.0) ? Audio.me_fade((timeInSeconds*1000).floor) : Audio.me_stop
end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMStop(timeInSeconds=0.0)
  if $game_system && timeInSeconds>0.0 && $game_system.respond_to?("bgm_fade")
    $game_system.bgm_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("bgm_stop")
    $game_system.bgm_stop
    return
  elsif (RPG.const_defined?(:BGM) rescue false)
    begin
      (timeInSeconds>0.0) ? RPG::BGM.fade((timeInSeconds*1000).floor) : RPG::BGM.stop
      return
      rescue
    end
  end
  (timeInSeconds>0.0) ? Audio.bgm_fade((timeInSeconds*1000).floor) : Audio.bgm_stop
end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSStop(timeInSeconds=0.0)
  if $game_system && timeInSeconds>0.0 && $game_system.respond_to?("bgs_fade")
    $game_system.bgs_fade(timeInSeconds)
    return
  elsif $game_system && $game_system.respond_to?("bgs_play")
    $game_system.bgs_play(nil)
    return
  elsif (RPG.const_defined?(:BGS) rescue false)
    begin
      (timeInSeconds>0.0) ? RPG::BGS.fade((timeInSeconds*1000).floor) : RPG::BGS.stop
      return
      rescue
    end
  end
  (timeInSeconds>0.0) ? Audio.bgs_fade((timeInSeconds*1000).floor) : Audio.bgs_stop
end

# Plays a sound effect that plays when a decision is confirmed or a choice is made.
def pbPlayDecisionSE()
  if $cache.RXsystem && $cache.RXsystem.respond_to?("decision_se") &&
     $cache.RXsystem.decision_se && $cache.RXsystem.decision_se.name!=""
    pbSEPlay($cache.RXsystem.decision_se)
  elsif $cache.RXsystem && $cache.RXsystem.respond_to?("sounds") &&
     $cache.RXsystem.sounds && $cache.RXsystem.sounds[1] && $cache.RXsystem.sounds[1].name!=""
    pbSEPlay($cache.RXsystem.sounds[1])
  elsif FileTest.audio_exist?("Audio/SE/Choose")
    pbSEPlay("Choose",80)
  end
end

# Plays a sound effect that plays when the player moves the cursor.
def pbPlayCursorSE()
  if $cache.RXsystem && $cache.RXsystem.respond_to?("cursor_se") &&
     $cache.RXsystem.cursor_se && $cache.RXsystem.cursor_se.name!=""
    pbSEPlay($cache.RXsystem.cursor_se)
  elsif $cache.RXsystem && $cache.RXsystem.respond_to?("sounds") &&
     $cache.RXsystem.sounds && $cache.RXsystem.sounds[0] && $cache.RXsystem.sounds[0].name!=""
    pbSEPlay($cache.RXsystem.sounds[0])
  elsif FileTest.audio_exist?("Audio/SE/Choose")
    pbSEPlay("Choose",80)
  end
end

# Plays a sound effect that plays when a choice is canceled.
def pbPlayCancelSE()
  if $cache.RXsystem && $cache.RXsystem.respond_to?("cancel_se") &&
     $cache.RXsystem.cancel_se && $cache.RXsystem.cancel_se.name!=""
    pbSEPlay($cache.RXsystem.cancel_se)
  elsif $cache.RXsystem && $cache.RXsystem.respond_to?("sounds") &&
     $cache.RXsystem.sounds && $cache.RXsystem.sounds[2] && $cache.RXsystem.sounds[2].name!=""
    pbSEPlay($cache.RXsystem.sounds[2])
  elsif FileTest.audio_exist?("Audio/SE/Choose")
    pbSEPlay("Choose",80)
  end
end

# Plays a buzzer sound effect.
def pbPlayBuzzerSE()
  if $cache.RXsystem && $cache.RXsystem.respond_to?("buzzer_se") &&
     $cache.RXsystem.buzzer_se && $cache.RXsystem.buzzer_se.name!=""
    pbSEPlay($cache.RXsystem.buzzer_se)
  elsif $cache.RXsystem && $cache.RXsystem.respond_to?("sounds") &&
     $cache.RXsystem.sounds && $cache.RXsystem.sounds[3] && $cache.RXsystem.sounds[3].name!=""
    pbSEPlay($cache.RXsystem.sounds[3])
  elsif FileTest.audio_exist?("Audio/SE/buzzer")
    pbSEPlay("buzzer",80)
  end
end

