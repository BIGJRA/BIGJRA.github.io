# Backgrounds to show in credits. Found in Graphics/Titles/ folder
CreditsBackgroundList = ["credits1","credits2","credits3","credits4","credits5"]
CreditsMusic          = "begin"
CreditsScrollSpeed    = 1             # At least 1; keep below 5 for legibility.
CreditsFrequency      = 8             # Number of seconds per credits slide.
CREDITS_OUTLINE       = Color.new(0,0,128, 255)
CREDITS_SHADOW        = Color.new(0,0,0, 100)
CREDITS_FILL          = Color.new(255,255,255, 255)

#==============================================================================
# * Scene_Credits
#------------------------------------------------------------------------------
# Scrolls the credits you make below. Original Author unknown.
#
## Edited by MiDas Mike so it doesn't play over the Title, but runs by calling
# the following:
#    $scene = Scene_Credits.new
#
## New Edit 3/6/2007 11:14 PM by AvatarMonkeyKirby.
# Ok, what I've done is changed the part of the script that was supposed to make
# the credits automatically end so that way they actually end! Yes, they will
# actually end when the credits are finished! So, that will make the people you
# should give credit to now is: Unknown, MiDas Mike, and AvatarMonkeyKirby.
#                                             -sincerly yours,
#                                               Your Beloved
# Oh yea, and I also added a line of code that fades out the BGM so it fades
# sooner and smoother.
#
## New Edit 24/1/2012 by Maruno.
# Added the ability to split a line into two halves with <s>, with each half
# aligned towards the centre.  Please also credit me if used.
#
## New Edit 22/2/2012 by Maruno.
# Credits now scroll properly when played with a zoom factor of 0.5.  Music can
# now be defined.  Credits can't be skipped during their first play.
#==============================================================================

class Scene_Credits

# This next piece of code is the credits.
#Start Editing
CREDIT=<<_END_

Your credits go here.

Your credits go here.

Your credits go here.

Your credits go here.

Your credits go here.



"Pokémon Essentials" was created by:
Flameguru
Poccil (Peter O.)
Maruno

With contributions from:
AvatarMonkeyKirby<s>MiDas Mike
Boushy<s>Near Fantastica
Brother1440<s>PinkMan
FL.<s>Popper
Genzai Kawakami<s>Rataime
Harshboy<s>SoundSpawn
help-14<s>the__end
IceGod64<s>Venom12
Jacob O. Wobbrock<s>Wachunga
KitsuneKouta<s>xLeD
Lisa Anthony<s>
and everyone else who helped out



"RPG Maker XP" by:
Enterbrain

_END_
#Stop Editing

  def main
#-------------------------------
# Animated Background Setup
#-------------------------------
    @sprite = IconSprite.new(0,0)
    @backgroundList = CreditsBackgroundList
    @backgroundGameFrameCount = 0
    # Number of game frames per background frame.
    @backgroundG_BFrameCount = CreditsFrequency * Graphics.frame_rate
    @sprite.setBitmap("Graphics/Titles/"+@backgroundList[0])
#------------------
# Credits text Setup
#------------------
    credit_lines = CREDIT.split(/\n/)
    credit_bitmap = Bitmap.new(Graphics.width,32 * credit_lines.size)
    credit_lines.each_index do |i|
      line = credit_lines[i]
      line = line.split("<s>")
      # LINE ADDED: If you use in your own game, you should remove this line
      pbSetSystemFont(credit_bitmap) # <--- This line was added
      x = 0
      xpos = 0
      align = 1 # Centre align
      linewidth = Graphics.width
      for j in 0...line.length
        if line.length>1
          xpos = (j==0) ? 0 : 20 + Graphics.width/2
          align = (j==0) ? 2 : 0 # Right align : left align
          linewidth = Graphics.width/2 - 20
        end
        credit_bitmap.font.color = CREDITS_SHADOW
        credit_bitmap.draw_text(xpos,i * 32 + 8,linewidth,32,line[j],align)
        credit_bitmap.font.color = CREDITS_OUTLINE
        credit_bitmap.draw_text(xpos + 2,i * 32 - 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos,i * 32 - 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos - 2,i * 32 - 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos + 2,i * 32,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos - 2,i * 32,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos + 2,i * 32 + 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos,i * 32 + 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos - 2,i * 32 + 2,linewidth,32,line[j],align)
        credit_bitmap.font.color = CREDITS_FILL
        credit_bitmap.draw_text(xpos,i * 32,linewidth,32,line[j],align)
      end
    end
    @trim=Graphics.height/10
    @credit_sprite = Sprite.new(Viewport.new(0,@trim,Graphics.width,Graphics.height-(@trim*2)))
    @credit_sprite.bitmap = credit_bitmap
    @credit_sprite.z = 9998
    @credit_sprite.oy = -(Graphics.height-@trim) #-430
    @frame_index = 0
    @bg_index = 0
    @pixels_banked = 0
    @zoom_adjustment = 1/$ResizeFactor
    @last_flag = false
#--------
# Setup
#--------
    #Stops all audio but background music.
    @PreviousBGM = $game_system.getPlayingBGM
    pbMEStop()
    pbBGSStop()
    pbSEStop()
    pbBGMFade(2.0)
    pbBGMPlay(CreditsMusic)
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @sprite.dispose
    @credit_sprite.dispose
    $PokemonGlobal.creditsPlayed=true
    pbBGMPlay(@PreviousBGM)
  end

##Checks if credits bitmap has reached it's ending point
  def last?
    if @frame_index > (@credit_sprite.bitmap.height + Graphics.height + (@trim/2))
      $scene = ($game_map) ? Scene_Map.new : nil
      pbBGMFade(2.0)
      return true
    end
    return false
  end

#Check if the credits should be cancelled
  def cancel?
    if Input.trigger?(Input::C) && $PokemonGlobal.creditsPlayed
      $scene = Scene_Map.new
      pbBGMFade(1.0)
      return true
    end
    return false
  end

  def update
    @backgroundGameFrameCount += 1
    if @backgroundGameFrameCount >= @backgroundG_BFrameCount        # Next slide
      @backgroundGameFrameCount = 0
      @bg_index += 1
      @bg_index = 0 if @bg_index >= @backgroundList.length
      @sprite.setBitmap("Graphics/Titles/"+@backgroundList[@bg_index])
    end
    return if cancel?
    return if last?
    @pixels_banked += CreditsScrollSpeed
    if @pixels_banked>=@zoom_adjustment
      @credit_sprite.oy += (@pixels_banked - @pixels_banked%@zoom_adjustment)
      @pixels_banked = @pixels_banked%@zoom_adjustment
    end
    @frame_index += CreditsScrollSpeed # This should fix the non-self-ending credits
  end
end