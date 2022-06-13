def yaxisIntersect(x1,y1,x2,y2,px,py)
  dx=x2-x1
  dy=y2-y1
  x = (dx==0) ? 0.0 : (px-x1)*1.0/dx
  y = (dy==0) ? 0.0 : (py-y1)*1.0/dy
  return [x,y]
end

def repositionY(x1,y1,x2,y2,tx,ty)
  dx=x2-x1
  dy=y2-y1
  x=x1+tx*dx*1.0
  y=y1+ty*dy*1.0
  return [x,y]
end

def transformPoint(x1,y1,x2,y2,  # Source line
                   x3,y3,x4,y4,  # Destination line
                   px,py)        # Source point
  ret=yaxisIntersect(x1,y1,x2,y2,px,py)
  ret2=repositionY(x3,y3,x4,y4,ret[0],ret[1])
  return ret2
end

def getSpriteCenter(sprite)
  return [0,0] if !sprite || sprite.disposed?
  return [sprite.x,sprite.y] if !sprite.bitmap || sprite.bitmap.disposed?
  centerX=sprite.src_rect.width/2
  centerY=sprite.src_rect.height/2
  offsetX=(centerX-sprite.ox)*sprite.zoom_x
  offsetY=(centerY-sprite.oy)*sprite.zoom_y
  return [sprite.x+offsetX,sprite.y+offsetY]
end



class AnimFrame
  X          = 0
  Y          = 1
  ZOOMX      = 2
  ANGLE      = 3
  MIRROR     = 4 
  BLENDTYPE  = 5
  VISIBLE    = 6
  PATTERN    = 7
  OPACITY    = 8
  ZOOMY      = 11
  COLORRED   = 12
  COLORGREEN = 13
  COLORBLUE  = 14
  COLORALPHA = 15
  TONERED    = 16
  TONEGREEN  = 17
  TONEBLUE   = 18
  TONEGRAY   = 19
  LOCKED     = 20
  FLASHRED   = 21
  FLASHGREEN = 22
  FLASHBLUE  = 23
  FLASHALPHA = 24
  PRIORITY   = 25
  FOCUS      = 26
end



class RPG::Animation
  def self.fromOther(otherAnim,id)
    ret=RPG::Animation.new
    ret.id=id
    ret.name=otherAnim.name.clone
    ret.animation_name=otherAnim.animation_name.clone
    ret.animation_hue=otherAnim.animation_hue
    ret.position=otherAnim.position
    return ret
  end

  def addSound(frame,se)
    timing=RPG::Animation::Timing.new
    timing.frame=frame
    timing.se=RPG::AudioFile.new(se,100)
    self.timings.push(timing)
  end

  def addAnimation(otherAnim,frame,x,y) # frame is zero-based
    if frame+otherAnim.frames.length>=self.frames.length
      totalframes=frame+otherAnim.frames.length+1
      for i in self.frames.length...totalframes
        self.frames.push(RPG::Animation::Frame.new)
      end
    end
    self.frame_max=self.frames.length
    for i in 0...otherAnim.frame_max
      thisframe=self.frames[frame+i]
      otherframe=otherAnim.frames[i]
      cellStart=thisframe.cell_max
      thisframe.cell_max+=otherframe.cell_max
      thisframe.cell_data.resize(thisframe.cell_max,8)
      for j in 0...otherframe.cell_max
        thisframe.cell_data[cellStart+j,0]=otherframe.cell_data[j,0]
        thisframe.cell_data[cellStart+j,1]=otherframe.cell_data[j,1]+x
        thisframe.cell_data[cellStart+j,2]=otherframe.cell_data[j,2]+y
        thisframe.cell_data[cellStart+j,3]=otherframe.cell_data[j,3]
        thisframe.cell_data[cellStart+j,4]=otherframe.cell_data[j,4]
        thisframe.cell_data[cellStart+j,5]=otherframe.cell_data[j,5]
        thisframe.cell_data[cellStart+j,6]=otherframe.cell_data[j,6]
        thisframe.cell_data[cellStart+j,7]=otherframe.cell_data[j,7]
      end
    end
    for i in 0...otherAnim.timings.length
      timing=RPG::Animation::Timing.new
      othertiming=otherAnim.timings[i]
      timing.frame=frame+othertiming.frame
      timing.se=RPG::AudioFile.new(
         othertiming.se.name.clone,
         othertiming.se.volume,
         othertiming.se.pitch)
      timing.flash_scope=othertiming.flash_scope
      timing.flash_color=othertiming.flash_color.clone
      timing.flash_duration=othertiming.flash_duration
      timing.condition=othertiming.condition
      self.timings.push(timing)
    end
    self.timings.sort!{|a,b| a.frame<=>b.frame }
  end
end



def pbSpriteSetAnimFrame(sprite,frame,user=nil,target=nil,ineditor=false)
  return if !sprite
  if !frame
    sprite.visible=false
    sprite.src_rect=Rect.new(0,0,1,1)
    return
  end
  sprite.blend_type=frame[AnimFrame::BLENDTYPE]
  sprite.angle=frame[AnimFrame::ANGLE]
  sprite.mirror=(frame[AnimFrame::MIRROR]>0)
  sprite.opacity=frame[AnimFrame::OPACITY]
  sprite.visible=true
  if !frame[AnimFrame::VISIBLE]==1 && ineditor
    sprite.opacity/=2
  else
    sprite.visible=(frame[AnimFrame::VISIBLE]==1)
  end
  pattern=frame[AnimFrame::PATTERN]
  if pattern>=0
#    if sprite.bitmap && !sprite.bitmap.disposed?
#      animwidth=sprite.bitmap.width/5
#      #echo(animwidth.inspect+"\r\n")
#    else
#      animwidth=192
#    end
    animwidth=192
    sprite.src_rect.set((pattern%5)*animwidth,(pattern/5)*animwidth,
       animwidth,animwidth)
  else
    sprite.src_rect.set(0,0,
       sprite.bitmap ? sprite.bitmap.width : 128,
       sprite.bitmap ? sprite.bitmap.height : 128)
  end
  sprite.zoom_x=frame[AnimFrame::ZOOMX]/100.0
  sprite.zoom_y=frame[AnimFrame::ZOOMY]/100.0
  sprite.color.set(
     frame[AnimFrame::COLORRED],
     frame[AnimFrame::COLORGREEN],
     frame[AnimFrame::COLORBLUE],
     frame[AnimFrame::COLORALPHA]
  )
  sprite.tone.set(
     frame[AnimFrame::TONERED],
     frame[AnimFrame::TONEGREEN],
     frame[AnimFrame::TONEBLUE],
     frame[AnimFrame::TONEGRAY] 
  )
  sprite.ox=sprite.src_rect.width/2
  sprite.oy=sprite.src_rect.height/2
  sprite.x=frame[AnimFrame::X]
  sprite.y=frame[AnimFrame::Y]
  if sprite!=user && sprite!=target
    case frame[AnimFrame::PRIORITY]
      when 0   # Behind everything
        sprite.z=5
      when 1   # In front of everything
        sprite.z=35
      when 2   # Just behind focus
        if frame[AnimFrame::FOCUS]==1 # Focused on target
          sprite.z=(target) ? target.z-1 : 5
        elsif frame[AnimFrame::FOCUS]==2 # Focused on user
          sprite.z=(user) ? user.z-1 : 5
        else # Focused on user and target, or screen
          sprite.z=5
        end
      when 3   # Just in front of focus
        if frame[AnimFrame::FOCUS]==1 # Focused on target
          sprite.z=(target) ? target.z+1 : 35
        elsif frame[AnimFrame::FOCUS]==2 # Focused on user
          sprite.z=(user) ? user.z+1 : 35
        else # Focused on user and target, or screen
          sprite.z=35
        end
      else
        sprite.z=35
    end
  end
end

def pbResetCel(frame)
  return if !frame
  frame[AnimFrame::ZOOMX]=100
  frame[AnimFrame::ZOOMY]=100
  frame[AnimFrame::BLENDTYPE]=0
  frame[AnimFrame::VISIBLE]=1
  frame[AnimFrame::ANGLE]=0
  frame[AnimFrame::MIRROR]=0
  frame[AnimFrame::OPACITY]=255
  frame[AnimFrame::COLORRED]=0
  frame[AnimFrame::COLORGREEN]=0
  frame[AnimFrame::COLORBLUE]=0
  frame[AnimFrame::COLORALPHA]=0
  frame[AnimFrame::TONERED]=0
  frame[AnimFrame::TONEGREEN]=0
  frame[AnimFrame::TONEBLUE]=0
  frame[AnimFrame::TONEGRAY]=0
  frame[AnimFrame::FLASHRED]=0
  frame[AnimFrame::FLASHGREEN]=0
  frame[AnimFrame::FLASHBLUE]=0
  frame[AnimFrame::FLASHALPHA]=0
  frame[AnimFrame::PRIORITY]=1 # 0=back, 1=front, 2=behind focus, 3=before focus
end

def pbCreateCel(x,y,pattern,focus=4)
  frame=[]
  frame[AnimFrame::X]=x
  frame[AnimFrame::Y]=y
  frame[AnimFrame::PATTERN]=pattern
  frame[AnimFrame::FOCUS]=focus # 1=target, 2=user, 3=user and target, 4=screen
  frame[AnimFrame::LOCKED]=0
  pbResetCel(frame)
  return frame
end



class PBAnimTiming
  attr_accessor :frame
  attr_accessor :timingType   # 0=play SE, 1=set bg, 2=bg mod
  attr_accessor :name         # Name of SE file or BG file
  attr_accessor :volume
  attr_accessor :pitch
  attr_accessor :bgX          # x coordinate of bg (or to move bg to)
  attr_accessor :bgY          # y coordinate of bg (or to move bg to)
  attr_accessor :opacity      # Opacity of bg (or to change bg to)
  attr_accessor :colorRed     # Color of bg (or to change bg to)
  attr_accessor :colorGreen   # Color of bg (or to change bg to)
  attr_accessor :colorBlue    # Color of bg (or to change bg to)
  attr_accessor :colorAlpha   # Color of bg (or to change bg to)
  attr_accessor :duration     # How long to spend changing to the new bg coords/color
  attr_accessor :flashScope
  attr_accessor :flashColor
  attr_accessor :flashDuration

  def initialize(type=0)
    @frame=0
    @timingType=type
    @name=""
    @volume=80
    @pitch=100
    @bgX=nil
    @bgY=nil
    @opacity=nil
    @colorRed=nil
    @colorGreen=nil
    @colorBlue=nil
    @colorAlpha=nil
    @duration=5
    @flashScope=0
    @flashColor=Color.new(255,255,255,255)
    @flashDuration=5
  end

  def timingType
    @timingType=0 if !@timingType
    return @timingType
  end

  def duration
    @duration=5 if !@duration
    return @duration
  end

  def to_s
    if self.timingType==0
      return "[#{@frame+1}] Play SE: #{name} (volume #{@volume}, pitch #{@pitch})"
    elsif self.timingType==1
      text=sprintf("[%d] Set BG: \"%s\"",@frame+1,name)
      text+=sprintf(" (color=%s,%s,%s,%s)",
         @colorRed!=nil ? @colorRed.to_i : "-",
         @colorGreen!=nil ? @colorGreen.to_i : "-",
         @colorBlue!=nil ? @colorBlue.to_i : "-",
         @colorAlpha!=nil ? @colorAlpha.to_i : "-")
      text+=sprintf(" (opacity=%s)",@opacity.to_i)
      text+=sprintf(" (coords=%s,%s)",
         @bgX!=nil ? @bgX : "-",
         @bgY!=nil ? @bgY : "-")
      return text
    elsif self.timingType==2
      text=sprintf("[%d] Change BG: @%d",@frame+1,duration)
      if @colorRed!=nil || @colorGreen!=nil || @colorBlue!=nil || @colorAlpha!=nil
        text+=sprintf(" (color=%s,%s,%s,%s)",
           @colorRed!=nil ? @colorRed.to_i : "-",
           @colorGreen!=nil ? @colorGreen.to_i : "-",
           @colorBlue!=nil ? @colorBlue.to_i : "-",
           @colorAlpha!=nil ? @colorAlpha.to_i : "-")
      end
      if @opacity!=nil
        text+=sprintf(" (opacity=%s)",@opacity.to_i)
      end
      if @bgX!=nil || @bgY!=nil
        text+=sprintf(" (coords=%s,%s)",
           @bgX!=nil ? @bgX : "-",
           @bgY!=nil ? @bgY : "-")
         end
      return text
    elsif self.timingType==3
      text=sprintf("[%d] Set FG: \"%s\"",@frame+1,name)
      text+=sprintf(" (color=%s,%s,%s,%s)",
         @colorRed!=nil ? @colorRed.to_i : "-",
         @colorGreen!=nil ? @colorGreen.to_i : "-",
         @colorBlue!=nil ? @colorBlue.to_i : "-",
         @colorAlpha!=nil ? @colorAlpha.to_i : "-")
      text+=sprintf(" (opacity=%s)",@opacity.to_i)
      text+=sprintf(" (coords=%s,%s)",
         @bgX!=nil ? @bgX : "-",
         @bgY!=nil ? @bgY : "-")
      return text
    elsif self.timingType==4
      text=sprintf("[%d] Change FG: @%d",@frame+1,duration)
      if @colorRed!=nil || @colorGreen!=nil || @colorBlue!=nil || @colorAlpha!=nil
        text+=sprintf(" (color=%s,%s,%s,%s)",
           @colorRed!=nil ? @colorRed.to_i : "-",
           @colorGreen!=nil ? @colorGreen.to_i : "-",
           @colorBlue!=nil ? @colorBlue.to_i : "-",
           @colorAlpha!=nil ? @colorAlpha.to_i : "-")
      end
      if @opacity!=nil
        text+=sprintf(" (opacity=%s)",@opacity.to_i)
      end
      if @bgX!=nil || @bgY!=nil
        text+=sprintf(" (coords=%s,%s)",
           @bgX!=nil ? @bgX : "-",
           @bgY!=nil ? @bgY : "-")
      end
      return text
    end
    return ""
  end
end



class PBAnimations < Array
  include Enumerable
  attr_reader :array
  attr_accessor :selected

  def initialize(size=1)
    @array=[]
    @selected=0
    size=1 if size<1 # Always create at least one animation
    size.times do
      @array.push(PBAnimation.new)
    end
  end

  def length
    return @array.length
  end

  def each
    @array.each {|i| yield i }
  end

  def [](i)
    return @array[i]
  end

  def []=(i,value)
    @array[i]=value
  end

  def compact
    @array.compact!
  end

  def resize(len)
    startidx=@array.length
    endidx=len
    if startidx>endidx
      for i in endidx...startidx
        @array.pop
      end
    else
      for i in startidx...endidx
        @array.push(PBAnimation.new)
      end
    end
    self.selected=len if self.selected>=len
  end
end



def pbConvertRPGAnimation(animation)
  pbanim=PBAnimation.new
  pbanim.id=animation.id
  pbanim.name=animation.name.clone
  pbanim.graphic=animation.animation_name
  pbanim.hue=animation.animation_hue
  pbanim.array.clear
  yoffset=0
  pbanim.position=animation.position
  yoffset=-64 if animation.position==0
  yoffset=64 if animation.position==2
  for i in 0...animation.frames.length
    frame=pbanim.addFrame
    animframe=animation.frames[i]
    for j in 0...animframe.cell_max
      data=animframe.cell_data
      if data[j,0]!=-1
        if animation.position==3 # Screen
          point=transformPoint(
             -160,80,160,-80,
             PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
             PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
             data[j,1],data[j,2]
          )
          cel=pbCreateCel(point[0],point[1],data[j,0])
        else
          cel=pbCreateCel(data[j,1],data[j,2]+yoffset,data[j,0])
        end
        cel[AnimFrame::ZOOMX]=data[j,3]
        cel[AnimFrame::ZOOMY]=data[j,3]
        cel[AnimFrame::ANGLE]=data[j,4]
        cel[AnimFrame::MIRROR]=data[j,5]
        cel[AnimFrame::OPACITY]=data[j,6]
        cel[AnimFrame::BLENDTYPE]=0
        frame.push(cel)
      else
        frame.push(nil)
      end
    end
  end
  for i in 0...animation.timings.length
    timing=animation.timings[i]
    newtiming=PBAnimTiming.new
    newtiming.frame=timing.frame
    newtiming.name=timing.se.name
    newtiming.volume=timing.se.volume
    newtiming.pitch=timing.se.pitch
    newtiming.flashScope=timing.flash_scope
    newtiming.flashColor=timing.flash_color.clone
    newtiming.flashDuration=timing.flash_duration
    pbanim.timing.push(newtiming)
  end
  return pbanim
end



class PBAnimation < Array
  include Enumerable
  attr_accessor :graphic
  attr_accessor :hue 
  attr_accessor :name
  attr_accessor :position
  attr_accessor :speed
  attr_reader :array
  attr_reader :timing
  attr_accessor :id
  MAXSPRITES=30

  def speed
    @speed=20 if !@speed
    return @speed
  end

  def initialize(size=1)
    @array=[]
    @timing=[]
    @name=""
    @id=-1
    @graphic=""
    @hue=0
    @scope=0
    @position=4 # 1=target, 2=user, 3=user and target, 4=screen
    size=1 if size<1 # Always create at least one frame
    size.times do
      addFrame
    end
  end

  def length
    return @array.length
  end

  def each
    @array.each {|i| yield i }
  end

  def [](i)
    return @array[i]
  end

  def []=(i,value)
    @array[i]=value
  end

  def insert(*arg)
    return @array.insert(*arg)
  end

  def delete_at(*arg)
    return @array.delete_at(*arg)
  end

  def playTiming(frame,bgGraphic,bgColor,foGraphic,foColor,oldbg=[],oldfo=[],user=nil)
    for i in @timing
      if i.frame==frame
        case i.timingType
          when 0   # Play SE
            if i.name && i.name!=""
              pbSEPlay(i.name,i.volume,i.pitch)
            else
              poke=(user && user.pokemon) ? user.pokemon : 1
              name=(pbCryFile(poke) rescue "001Cry")
              pbSEPlay(name,i.volume,i.pitch)
            end
#            if sprite
#              sprite.flash(i.flashColor,i.flashDuration*2) if i.flashScope==1
#              sprite.flash(nil,i.flashDuration*2) if i.flashScope==3
#            end
          when 1   # Set background graphic (immediate)
            if i.name && i.name!=""
              bgGraphic.setBitmap("Graphics/Animations/"+i.name)
              bgGraphic.ox=-i.bgX || 0
              bgGraphic.oy=-i.bgY || 0
              bgGraphic.color=Color.new(i.colorRed || 0,i.colorGreen || 0,i.colorBlue || 0,i.colorAlpha || 0)
              bgGraphic.opacity=i.opacity || 0
              bgColor.opacity=0
            else
              bgGraphic.setBitmap(nil)
              bgGraphic.opacity=0
              bgColor.color=Color.new(i.colorRed || 0,i.colorGreen || 0,i.colorBlue || 0,i.colorAlpha || 0)
              bgColor.opacity=i.opacity || 0
            end
          when 2   # Move/recolour background graphic
            if bgGraphic.bitmap!=nil
              oldbg[0]=bgGraphic.ox || 0
              oldbg[1]=bgGraphic.oy || 0              
              oldbg[2]=bgGraphic.opacity || 0
              @@oldopacity=oldbg[2]
              oldbg[3]=bgGraphic.color.clone || Color.new(0,0,0,0)
              @@oldcolor=oldbg[3]
            else
              oldbg[0]=0
              oldbg[1]=0
              oldbg[2]=bgColor.opacity || 0
              @@oldopacity=oldbg[2]
              oldbg[3]=bgColor.color.clone || Color.new(0,0,0,0)
              @@oldcolor=oldbg[3]
            end
          when 3   # Set foreground graphic (immediate)
            if i.name && i.name!=""
              foGraphic.setBitmap("Graphics/Animations/"+i.name)
              foGraphic.ox=-i.bgX || 0
              foGraphic.oy=-i.bgY || 0
              foGraphic.color=Color.new(i.colorRed || 0,i.colorGreen || 0,i.colorBlue || 0,i.colorAlpha || 0)
              foGraphic.opacity=i.opacity || 0
              foColor.opacity=0
            else
              foGraphic.setBitmap(nil)
              foGraphic.opacity=0
              foColor.color=Color.new(i.colorRed || 0,i.colorGreen || 0,i.colorBlue || 0,i.colorAlpha || 0)
              foColor.opacity=i.opacity || 0
            end
          when 4   # Move/recolour foreground graphic
            if foGraphic.bitmap!=nil
              oldfo[0]=foGraphic.ox || 0
              oldfo[1]=foGraphic.oy || 0
              oldfo[2]=foGraphic.opacity || 0
              @@foldopacity=oldfo[2]
              oldfo[3]=foGraphic.color.clone || Color.new(0,0,0,0)
              @@foldcolor=oldfo[3]
            else
              oldfo[0]=0
              oldfo[1]=0
              oldfo[2]=foColor.opacity || 0
              @@foldopacity=oldfo[2]
              oldfo[3]=foColor.color.clone || Color.new(0,0,0,0)
              @@foldcolor=oldfo[3]
            end
        end
      end
    end
    for i in @timing
      case i.timingType
        when 2
          if i.duration && i.duration>0 && frame>=i.frame && frame<=(i.frame+i.duration)
            fraction=1.0/i.duration
            if bgGraphic.bitmap!=nil
              bgGraphic.ox=oldbg[0]-(i.bgX*fraction) if i.bgX!=nil
              oldbg[0]=bgGraphic.ox if i.bgX!=nil
              bgGraphic.oy=oldbg[1]-(i.bgY*fraction) if i.bgY!=nil            
              oldbg[1]=bgGraphic.oy if i.bgY!=nil            
              bgGraphic.opacity=oldbg[2]+(i.opacity-@@oldopacity)*fraction if i.opacity!=nil
              oldbg[2]=bgGraphic.opacity if i.opacity!=nil             
              cr=(i.colorRed!=nil) ? oldbg[3].red+(i.colorRed-@@oldcolor.red)*fraction : oldbg[3].red
              oldbg[3].red = cr
              cg=(i.colorGreen!=nil) ? oldbg[3].green+(i.colorGreen-@@oldcolor.green)*fraction : oldbg[3].green
              oldbg[3].green = cg
              cb=(i.colorBlue!=nil) ? oldbg[3].blue+(i.colorBlue-@@oldcolor.blue)*fraction : oldbg[3].blue
              oldbg[3].blue = cb
              ca=(i.colorAlpha!=nil) ? oldbg[3].alpha+(i.colorAlpha-@@oldcolor.alpha)*fraction : oldbg[3].alpha
              oldbg[3].alpha = ca
              bgGraphic.color=Color.new(cr,cg,cb,ca)
            else
              bgColor.opacity=oldbg[2]+(i.opacity-@@oldopacity)*fraction if i.opacity!=nil
              oldbg[2]=bgColor.opacity if i.opacity!=nil             
              cr=(i.colorRed!=nil) ? oldbg[3].red+(i.colorRed-@@oldcolor.red)*fraction : oldbg[3].red
              oldbg[3].red = cr
              cg=(i.colorGreen!=nil) ? oldbg[3].green+(i.colorGreen-@@oldcolor.green)*fraction : oldbg[3].green
              oldbg[3].green = cg
              cb=(i.colorBlue!=nil) ? oldbg[3].blue+(i.colorBlue-@@oldcolor.blue)*fraction : oldbg[3].blue
              oldbg[3].blue = cb
              ca=(i.colorAlpha!=nil) ? oldbg[3].alpha+(i.colorAlpha-@@oldcolor.alpha)*fraction : oldbg[3].alpha
              oldbg[3].alpha = ca
              bgColor.color=Color.new(cr,cg,cb,ca)
            end
          end
        when 4
          if i.duration && i.duration>0 && frame>=i.frame && frame<=(i.frame+i.duration)
            fraction=1.0/i.duration
            if foGraphic.bitmap!=nil
              foGraphic.ox=oldfo[0]-(i.bgX*fraction) if i.bgX!=nil
              oldfo[0]=foGraphic.ox if i.bgX!=nil
              foGraphic.oy=oldfo[1]-(i.bgY*fraction) if i.bgY!=nil
              oldfo[1]=foGraphic.oy if i.bgY!=nil
              foGraphic.opacity=oldfo[2]+(i.opacity-@@foldopacity)*fraction if i.opacity!=nil
              oldfo[2]=foGraphic.opacity if i.opacity!=nil
              cr=(i.colorRed!=nil) ? oldfo[3].red+(i.colorRed-@@foldcolor.red)*fraction : oldfo[3].red
              oldfo[3].red = cr
              cg=(i.colorGreen!=nil) ? oldfo[3].green+(i.colorGreen-@@foldcolor.green)*fraction : oldfo[3].green
              oldfo[3].green = cg
              cb=(i.colorBlue!=nil) ? oldfo[3].blue+(i.colorBlue-@@foldcolor.blue)*fraction : oldfo[3].blue
              oldfo[3].blue = cb
              ca=(i.colorAlpha!=nil) ? oldfo[3].alpha+(i.colorAlpha-@@foldcolor.alpha)*fraction : oldfo[3].alpha
              oldfo[3].alpha = ca
              foGraphic.color=Color.new(cr,cg,cb,ca)
            else
              foColor.opacity=oldfo[2]+(i.opacity-@@foldopacity)*fraction if i.opacity!=nil
              oldfo[2]=foColor.opacity if i.opacity!=nil
              cr=(i.colorRed!=nil) ? oldfo[3].red+(i.colorRed-@@foldcolor.red)*fraction : oldfo[3].red
              oldfo[3].red = cr
              cg=(i.colorGreen!=nil) ? oldfo[3].green+(i.colorGreen-@@foldcolor.green)*fraction : oldfo[3].green
              oldfo[3].green = cg
              cb=(i.colorBlue!=nil) ? oldfo[3].blue+(i.colorBlue-@@foldcolor.blue)*fraction : oldfo[3].blue
              oldfo[3].blue = cb
              ca=(i.colorAlpha!=nil) ? oldfo[3].alpha+(i.colorAlpha-@@foldcolor.alpha)*fraction : oldfo[3].alpha
              oldfo[3].alpha = ca
              foColor.color=Color.new(cr,cg,cb,ca)
            end
          end
      end
    end
  end
 
  def resize(len)
    if len<@array.length
      @array[len,@array.length-len]=[]
    elsif len>@array.length
      (len-@array.length).times do
        addFrame
      end
    end
  end

  def addFrame
    pos=@array.length
    @array[pos]=[]
    for i in 0...PBAnimation::MAXSPRITES # maximum sprites plus user and target
      if i==0
        @array[pos][i]=pbCreateCel(
           PokeBattle_SceneConstants::FOCUSUSER_X,
           PokeBattle_SceneConstants::FOCUSUSER_Y,-1) # Move's user
        @array[pos][i][AnimFrame::FOCUS]=2
        @array[pos][i][AnimFrame::LOCKED]=1
      elsif i==1
        @array[pos][i]=pbCreateCel(
           PokeBattle_SceneConstants::FOCUSTARGET_X,
           PokeBattle_SceneConstants::FOCUSTARGET_Y,-2) # Move's target
        @array[pos][i][AnimFrame::FOCUS]=1
        @array[pos][i][AnimFrame::LOCKED]=1
      end
    end
    return @array[pos]
  end
end



module PBAnimationPlayerModule
  def initialize(animation,target,viewport=nil); end
  def dispose; end
  def start; end
  def playing?; end
  def update; end
end



def isReversed(src0,src1,dst0,dst1)
  if src0==src1
    return false
  elsif src0<src1
    return (dst0>dst1)
  else
    return (dst0<dst1)
  end
end



################################################################################
# Animation player
################################################################################
class PBAnimationPlayerX
  attr_accessor :looping
  MAXSPRITES=30

  def initialize(animation,user,target,scene=nil,oppmove=false,ineditor=false)
    @animation=animation
    @user=(oppmove) ? target : user # Just used for playing user's cry
    #user might also be used for flickerglitches
    @usersprite=(user) ? scene.sprites["pokemon#{user.index}"] : nil
    @targetsprite=(target) ? scene.sprites["pokemon#{target.index}"] : nil
    @userbitmap=(@usersprite && @usersprite.bitmap) ? @usersprite.bitmap : nil # not to be disposed
    @targetbitmap=(@targetsprite && @targetsprite.bitmap) ? @targetsprite.bitmap : nil # not to be disposed
    @scene=scene
    @viewport=(scene) ? scene.viewport : nil
    @ineditor=ineditor
    @looping=false
    @animbitmap=nil # Animation sheet graphic
    @frame=-1
    @srcLine=nil
    @dstLine=nil
    @userOrig=getSpriteCenter(@usersprite)
    @targetOrig=getSpriteCenter(@targetsprite)
    @animsprites=[]
    @animsprites[0]=@usersprite
    @animsprites[1]=@targetsprite
    for i in 2...MAXSPRITES
      @animsprites[i]=Sprite.new(@viewport)
      @animsprites[i].bitmap=nil
      @animsprites[i].visible=false
    end
    @bgColor=ColoredPlane.new(Color.new(0,0,0),@viewport)
    @bgColor.borderX=64 if ineditor
    @bgColor.borderY=64 if ineditor
    @bgColor.z=2
    @bgColor.opacity=0
    @bgColor.refresh
    @bgGraphic=AnimatedPlane.new(@viewport)
    @bgGraphic.setBitmap(nil)
    @bgGraphic.borderX=64 if ineditor
    @bgGraphic.borderY=64 if ineditor
    @bgGraphic.z=2
    @bgGraphic.opacity=0
    @bgGraphic.refresh
    @oldbg=[]
    @foColor=ColoredPlane.new(Color.new(0,0,0),@viewport)
    @foColor.borderX=64 if ineditor
    @foColor.borderY=64 if ineditor
    @foColor.z=38
    @foColor.opacity=0
    @foColor.refresh
    @foGraphic=AnimatedPlane.new(@viewport)
    @foGraphic.setBitmap(nil)
    @foGraphic.borderX=64 if ineditor
    @foGraphic.borderY=64 if ineditor
    @foGraphic.z=38
    @foGraphic.opacity=0
    @foGraphic.refresh
    @oldfo=[]
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    for i in 2...MAXSPRITES
      @animsprites[i].dispose if @animsprites[i]
    end
    @bgGraphic.dispose
    @bgColor.dispose
    @foGraphic.dispose
    @foColor.dispose
  end

  def start
    @frame=0
  end

  def playing?
    return @frame>=0
  end

  def setLineTransform(x1,y1,x2,y2,x3,y3,x4,y4)
    @srcLine=[x1,y1,x2,y2]
    @dstLine=[x3,y3,x4,y4]
  end

  def update
    return if @frame<0
    if (@frame>>1) >= @animation.length
      @frame=(@looping) ? 0 : -1
      if @frame<0
        unless (@user).nil?
          unless defined?(@user.effects).nil?
            if @user.effects[PBEffects::UsingSubstituteRightNow]==true
              @scene.pbSubstituteSprite(@user,@user.pbIsOpposing?(1))
            end
          end        
        end        
        @animbitmap.dispose if @animbitmap
        @animbitmap=nil
        return
      end
    end
    if !@animbitmap || @animbitmap.disposed?
      @animbitmap=AnimatedBitmap.new("Graphics/Animations/"+@animation.graphic,
         @animation.hue).deanimate
      for i in 0...MAXSPRITES
        @animsprites[i].bitmap=@animbitmap if @animsprites[i]
      end
    end
    @bgGraphic.update
    @bgColor.update
    @foGraphic.update
    @foColor.update
    if (@frame&1)==0
      thisframe=@animation[@frame>>1]
      # Make all cel sprites invisible
      for i in 0...MAXSPRITES
        @animsprites[i].visible=false if @animsprites[i]
      end
      # Set each cel sprite acoordingly
      for i in 0...thisframe.length
        cel=thisframe[i]
        next if !cel
        sprite=@animsprites[i]
        next if !sprite
        # Set cel sprite's graphic
        if cel[AnimFrame::PATTERN]==-1
          sprite.bitmap=@userbitmap
        elsif cel[AnimFrame::PATTERN]==-2
          sprite.bitmap=@targetbitmap
        else
          sprite.bitmap=@animbitmap
        end
        # Apply settings to the cel sprite
        pbSpriteSetAnimFrame(sprite,cel,@usersprite,@targetsprite)
        case cel[AnimFrame::FOCUS]
          when 1   # Focused on target
            sprite.x=cel[AnimFrame::X]+@targetOrig[0]-PokeBattle_SceneConstants::FOCUSTARGET_X
            sprite.y=cel[AnimFrame::Y]+@targetOrig[1]-PokeBattle_SceneConstants::FOCUSTARGET_Y
          when 2   # Focused on user
            sprite.x=cel[AnimFrame::X]+@userOrig[0]-PokeBattle_SceneConstants::FOCUSUSER_X
            sprite.y=cel[AnimFrame::Y]+@userOrig[1]-PokeBattle_SceneConstants::FOCUSUSER_Y
          when 3   # Focused on user and target
            if @srcLine && @dstLine
              point=transformPoint(
                 @srcLine[0],@srcLine[1],@srcLine[2],@srcLine[3],
                 @dstLine[0],@dstLine[1],@dstLine[2],@dstLine[3],
                 sprite.x,sprite.y)
              sprite.x=point[0]
              sprite.y=point[1]
              if isReversed(@srcLine[0],@srcLine[2],@dstLine[0],@dstLine[2]) &&
                 cel[AnimFrame::PATTERN]>=0
                # Reverse direction
                sprite.mirror=!sprite.mirror
              end
            end
        end
        sprite.x+=64 if @ineditor
        sprite.y+=64 if @ineditor
      end
      # Play timings
      @animation.playTiming(@frame>>1,@bgGraphic,@bgColor,@foGraphic,@foColor,@oldbg,@oldfo,@user)
    end
    @frame+=1
  end
end