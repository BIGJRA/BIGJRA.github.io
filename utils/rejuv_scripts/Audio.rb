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



def getPlayMusic
  return MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
     "SOFTWARE\\Enterbrain\\RGSS","PlayMusic",true)
end

def getPlaySound
  return MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
     "SOFTWARE\\Enterbrain\\RGSS","PlaySound",true)
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



####################################################
if safeExists?("audio.dll")

module Graphics
  if !defined?(audiomodule_update)
    class << self
      alias audiomodule_update update
    end
  end

  def self.update
    Audio.update
    audiomodule_update
  end
end



module Audio
  @@musicstate=nil
  @@soundstate=nil

  def self.update
    return if Graphics.frame_count%10!=0
    if AudioState.waitingBGM && !AudioState.meActive?
      waitbgm=AudioState.waitingBGM
      AudioState.waitingBGM=nil
      bgm_play(waitbgm[0],waitbgm[1],waitbgm[2],waitbgm[3])
    end
  end

  def self.bgm_play(name,volume=80,pitch=100,position=nil)
    begin
      if position==nil || position==0
        Kernel.Audio_bgm_play(name,volume,pitch,0)
      else
        Kernel.Audio_bgm_play(name,volume,pitch,position)
        Kernel.Audio_bgm_fadein(500)
      end
    rescue Hangup
      bgm_play(name,volume,pitch,position)
    end
  end

  def self.bgm_fade(ms)
    Kernel.Audio_bgm_fade(ms)
  end

  def self.bgm_stop
    Kernel.Audio_bgm_stop()
  end

  def self.bgm_position
    ret=Kernel.Audio_bgm_get_position
    return ret
  end

  def self.me_play(name,volume=80,pitch=100)
    Kernel.Audio_me_play(name,volume,pitch,0)
  end

  def self.me_fade(ms)
    Kernel.Audio_me_fade(ms)
  end

  def self.me_stop
    Kernel.Audio_me_stop()
  end

  def self.bgs_play(name,volume=80,pitch=100)
    Kernel.Audio_bgs_play(name,volume,pitch,0)
  end

  def self.bgs_fade(ms)
    Kernel.Audio_bgs_fade(ms)
  end

  def self.bgs_stop
    Kernel.Audio_bgs_stop()
  end

=begin
 def self.se_play(name,volume=80,pitch=100)
   Kernel.Audio_se_play(name,volume,pitch,0)
 end
 def self.se_stop
   Kernel.Audio_se_stop()
 end
=end
end


end # ends the "if" statement at line 287