def getCubicPoint2(src,t)
  x0=src[0];
  y0=src[1];
  cx0=src[2];
  cy0=src[3];
  cx1=src[4];
  cy1=src[5];
  x1=src[6];
  y1=src[7];
  x1=cx1+(x1-cx1)*t;
  y1=cy1+(y1-cy1)*t;
  x0=x0+(cx0-x0)*t;
  y0=y0+(cy0-y0)*t;
  cx0=cx0+(cx1-cx0)*t;
  cy0=cy0+(cy1-cy0)*t;
  cx1=cx0+(x1-cx0)*t;
  cy1=cy0+(y1-cy0)*t;
  cx0=x0+(cx0-x0)*t;
  cy0=y0+(cy0-y0)*t;
  cx=cx0+(cx1-cx0)*t;
  cy=cy0+(cy1-cy0)*t;
  return [cx,cy]
end



class PictureEx
  attr_reader     :number                   # picture number
  attr_accessor   :name                     # file name
  attr_accessor   :src_x                    # source rect x
  attr_accessor   :src_y                    # source rect y
  attr_accessor   :origin                   # starting point
  attr_accessor   :x                        # x-coordinate
  attr_accessor   :y                        # y-coordinate
  attr_accessor   :zoom_x                   # x directional zoom rate
  attr_accessor   :zoom_y                   # y directional zoom rate
  attr_accessor   :opacity                  # opacity level
  attr_accessor   :blend_type               # blend method
  attr_reader     :tone                     # color tone
  attr_reader     :color     
  attr_accessor   :angle                    # rotation angle
  attr_accessor   :visible 
  attr_accessor   :hue                      # filename hue

  class Processes
    XY=0
    Zoom=1
    Opacity=2
    BlendType=3
    Tone=4
    Color=5
    Visible=6
    SE=7
    Angle=8
    Origin=9
    Name=10
    Curve=11
    Hue=12
    Src=13
  end

  def callback(cb)
    if cb.is_a?(Proc)
      proc.call(self)
    elsif cb.is_a?(Array)
      cb[0].method(cb[1]).call(self)
    elsif cb.is_a?(Method)
      cb.call(self)
    end
  end

  def initialize(number)
    @number = number
    @name = ""
    @src_x = 0
    @src_y = 0
    @origin = 0
    @x = 0.0
    @y = 0.0
    @hue = 0
    @zoom_x = 100.0
    @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 0
    @processes=[]
    @tone = Tone.new(0, 0, 0, 0)
    @color = Color.new(0, 0, 0, 0)
    @tone_duration = 0
    @angle = 0
    @rotate_speed = 0
    @bitmap=0
    @visible=true
  end

  def name=(value)
    @name=value
  end

  def running?
    return @processes.length>0
  end

  def totalDuration
    ret=0
    for process in @processes
      dur=process[1]+process[2]
      ret=dur if dur>ret
    end
    return ret
  end

  def adjustPosition(xOffset,yOffset)
    for process in @processes
      if process[0]==Processes::XY
        process[3]+=xOffset
        process[4]+=yOffset
        process[5]+=xOffset
        process[6]+=yOffset
      end
    end
  end

  def generateCurve(duration, delay, curve, cb=nil)
    duration=1 if duration<=0
    step=1.0/duration
    lastX=curve[0]
    lastY=curve[1]
    t=0.0
    for i in 0..duration
      point=getCubicPoint2(curve,t)
      cbref=(i==duration) ? cb : nil
      @processes.push([Processes::XY,1,delay+i,lastX,lastY,point[0],point[1],cbref])
      lastX=point[0]
      lastY=point[1]
      t+=step
    end
  end

  def moveCurve(duration, delay, x1, y1, x2, y2, x3, y3, cb=nil)
    delay=self.totalDuration if delay<0
    if duration==0 && delay==0
      @x=x3
      @y=y3
      callback(cb)
    elsif delay==0
      generateCurve(duration,delay,[@x,@y,x1,y1,x2,y2,x3,y3],cb)
    else
      @processes.push([Processes::Curve,duration,delay,[@x,@y,x1,y1,x2,y2,x3,y3],cb])    
    end
  end

  def move(duration, delay, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @duration = duration
    moveOrigin(duration,delay,origin)
    moveXY(duration,delay,x,y)
    moveZoomXY(duration,delay,zoom_x,zoom_y)
    moveOpacity(duration,delay,opacity)
    moveBlendType(duration,delay,blend_type)
  end

  def moveZoomXY(duration, delay, zoom_x,zoom_y,cb=nil)
    delay=self.totalDuration if delay<0
    if duration==0 && delay==0
      @zoom_x=zoom_x
      @zoom_y=zoom_y
      callback(cb)
    else
      @processes.push([Processes::Zoom,duration,delay,@zoom_x,@zoom_y,zoom_x,zoom_y,cb])      
    end
  end

  def moveName(delay,name,cb=nil)
    delay=self.totalDuration if delay<0
    @processes.push([Processes::Name,0,delay,name,cb])      
  end

  def moveSrc(delay,srcx,srcy,cb=nil)
    delay=self.totalDuration if delay<0
    @processes.push([Processes::Src,0,delay,srcx,srcy,cb])      
  end

  def moveSE(delay,sefile,cb=nil)
    delay=self.totalDuration if delay<0
    @processes.push([Processes::SE,0,delay,sefile,cb])      
  end

  def moveOrigin(delay,origin,cb=nil)
    delay=self.totalDuration if delay<0
    @processes.push([Processes::Origin,0,delay,origin,cb])      
  end

  def moveZoom(duration,delay,zoom,cb=nil)
    moveZoomXY(duration,delay,zoom,zoom,cb)
  end

  def moveOpacity(duration,delay,opacity,cb=nil)
    delay=self.totalDuration if delay<0
    if duration==0 && delay==0
      @opacity=opacity
      callback(cb)
    else
      @processes.push([Processes::Opacity,duration,delay,@opacity,opacity,cb])
    end
  end

  def moveDelta(duration,delay,x,y,cb=nil)
    delay=self.totalDuration if delay<0
    if duration==0 && delay==0
      @x+=x
      @y+=y
      callback(cb)
    else
      @processes.push([Processes::XY,duration,delay,@x,@y,@x+x,@y+y,cb])
    end
  end

  def moveXY(duration,delay,x,y,cb=nil)
    delay=self.totalDuration if delay<0
    if duration==0 && delay==0
      @x=x
      @y=y
      callback(cb)
    else
      @processes.push([Processes::XY,duration,delay,@x,@y,x,y,cb])
    end
  end

  def moveBlendType(duration,delay,blend,cb=nil)
    delay=self.totalDuration if delay<0
    if duration==0 && delay==0
      @blend_type=blend
      callback(cb)
    else
      @processes.push([Processes::BlendType,duration,delay,@blend_type,blend,cb])      
    end
  end

  def moveVisible(delay,visible,cb=nil)
    delay=self.totalDuration if delay<0
    @processes.push([Processes::Visible,0,delay,visible,cb])      
  end

  def rotate(speed)
    @rotate_speed = speed
  end

  def moveAngle(duration,delay,angle,cb=nil)
    delay=self.totalDuration if delay<0
    if duration==0 && delay==0
      @angle=angle
      callback(cb)
    else
      @processes.push([Processes::Angle,duration,delay,@angle,angle,cb])      
    end    
  end

  def moveHue(duration, delay,hue, cb=nil)
    delay=self.totalDuration if delay<0
    if duration==0 && delay==0
     @hue=hue
    else
     @processes.push([Processes::Hue,duration,delay,@hue,hue,cb])
    end
  end

  def moveTone(duration, delay,tone, cb=nil)
    delay=self.totalDuration if delay<0
    target = tone ? tone.clone : Tone.new(0,0,0,0)
    if duration==0 && delay==0
      @tone.set(target.red,target.green,target.blue,target.gray)
    else
      @processes.push([Processes::Tone,duration,delay,@tone.clone,target.clone,cb])
    end
  end

  def moveColor(duration, delay, tone, cb=nil)
    delay=self.totalDuration if delay<0
    target = tone ? tone.clone : Color.new(0,0,0,0)
    if duration==0 && delay==0
      @color.set(target.red,target.green,target.blue,target.alpha)
    else
      @processes.push([Processes::Color,duration,delay,@color.clone,target.clone,cb])
    end
  end

  def erase
    self.name = ""
  end

  def clearProcesses
    @processes = []
  end

  def update
    i=0; while i<@processes.length
      process=@processes[i]
      d=process[1]
      cb=nil
      # decrease delay
      if process[2]>0
        process[2]-=1
        if process[2]<=0
          # set initial values
          case process[0]
            when Processes::XY
              process[3]=@x
              process[4]=@y
            when Processes::Zoom
              process[3]=@zoom_x
              process[4]=@zoom_y
            when Processes::Opacity
              process[3]=@opacity
            when Processes::BlendType
              process[3]=@blend_type
            when Processes::Tone
              process[3]=@tone.clone
            when Processes::Hue
              process[3]=@hue
            when Processes::Color
              process[3]=@color.clone
            when Processes::Angle
              process[3]=@angle
            when Processes::Curve
              process[3][0]=@x
              process[3][1]=@y
              generateCurve(process[1],0,process[3],process[4])
              @processes[i]=nil
              i+=1
              next
          end
        else
          i+=1
          next
        end
      end
      if process[1]<1
        process[1]=1
        d=1
      end
      case process[0]
        when Processes::XY
          process[3] = (process[3] * (d - 1) + process[5]) / d
          process[4] = (process[4] * (d - 1) + process[6]) / d
          @x=process[3]
          @y=process[4]
          cb=process[7]
        when Processes::Zoom
          process[3] = (process[3] * (d - 1) + process[5]) / d
          process[4] = (process[4] * (d - 1) + process[6]) / d
          @zoom_x=process[3]
          @zoom_y=process[4]
          cb=process[7]
        when Processes::Opacity
          process[3] = (process[3] * (d - 1) + process[4]) / d
          @opacity=process[3]
          cb=process[5]
        when Processes::Hue
          process[3] = (process[3] * (d - 1) + process[4]) / d
          @hue=process[3]
          cb=process[5]
        when Processes::BlendType
          process[3] = (process[3] * (d - 1) + process[4]) / d
          @blend_type=process[3]
          cb=process[5]
        when Processes::Tone
          process[3].red = (process[3].red * (d - 1) + process[4].red) / d
          process[3].green = (process[3].green * (d - 1) + process[4].green) / d
          process[3].blue = (process[3].blue * (d - 1) + process[4].blue) / d
          process[3].gray = (process[3].gray * (d - 1) + process[4].gray) / d
          @tone.set(process[3].red,process[3].green,process[3].blue,process[3].gray)
          cb=process[5]
        when Processes::Color
          process[3].red = (process[3].red * (d - 1) + process[4].red) / d
          process[3].green = (process[3].green * (d - 1) + process[4].green) / d
          process[3].blue = (process[3].blue * (d - 1) + process[4].blue) / d
          process[3].alpha = (process[3].alpha * (d - 1) + process[4].alpha) / d
          @color.set(process[3].red,process[3].green,process[3].blue,process[3].alpha)
          cb=process[5]
        when Processes::Visible
          @visible=process[3] if process[1]==1
          cb=process[4]
        when Processes::SE
          pbSEPlay("../../"+process[3]) if process[1]==1
          cb=process[4]
        when Processes::Name
          @name=process[3] if process[1]==1
          cb=process[4]
        when Processes::Src
          @src_x=process[3] if process[1]==1
          @src_y=process[4] if process[1]==1
          cb=process[5]
        when Processes::Origin
          @origin=process[3] if process[1]==1
          cb=process[4]
        when Processes::Angle
          process[3] = (process[3] * (d - 1) + process[4]) / d
          @angle=process[3]
          cb=process[5]
      end
      # decrease duration
      process[1]-=1
      if process[1]<=0
        callback(cb) if cb
        @processes[i]=nil
      end
      i+=1
    end
    @processes.compact!
    if @rotate_speed != 0
      @angle += @rotate_speed / 2.0
      while @angle < 0
        @angle += 360
      end
      @angle %= 360
    end
  end
end



def setPictureIconSprite(sprite,picture)
  if sprite.name != picture.name
    sprite.name = picture.name
  end
  if sprite.src_rect
    if sprite.src_rect.x != picture.src_x
      sprite.src_rect.x = picture.src_x
    end
    if sprite.src_rect.y != picture.src_y
      sprite.src_rect.y = picture.src_y
    end
  end
  setPictureSprite(sprite,picture)
end

def setPictureSprite(sprite,picture)
  sprite.visible = picture.visible
  # Set transfer starting point
  case picture.origin
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      sprite.oy=0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      sprite.oy=(sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.bitmap.height/2 : 0
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      sprite.oy=(sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.bitmap.height : 0
  end
  case picture.origin
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      sprite.ox=0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      sprite.ox=(sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.bitmap.width/2 : 0
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      sprite.ox=(sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.bitmap.width : 0
  end
  # Set sprite coordinates
  sprite.x = picture.x
  sprite.y = picture.y
  sprite.z = picture.number
  # Set zoom rate, opacity level, and blend method
  sprite.zoom_x = picture.zoom_x / 100.0
  sprite.zoom_y = picture.zoom_y / 100.0
  sprite.opacity = picture.opacity
  sprite.blend_type = picture.blend_type
  # Set rotation angle and color tone
  angle = picture.angle
  sprite.tone = picture.tone
  sprite.color = picture.color
  while angle < 0
    angle += 360
  end
  angle %= 360
  sprite.angle=angle
end



class PictureOrigin
  TopLeft=0
  Center=1
  TopRight=2
  BottomLeft=3
  LowerLeft=3
  BottomRight=4
  LowerRight=4
  Top=5
  Bottom=6
  Left=7
  Right=8
end



def pbTextBitmap(text,maxwidth=Graphics.width)
  dims=[]
  tmp=Bitmap.new(maxwidth,Graphics.height)
  pbSetSystemFont(tmp)
  drawFormattedTextEx(tmp,0,0,maxwidth,text,Color.new(248,248,248),Color.new(168,184,184))
  return tmp
end



class PictureSprite < SpriteWrapper
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
    @pictureBitmap = nil
    @customBitmap = nil
    @customBitmapIsBitmap = true
    @hue=0
    update
  end

  # Doesn't free the bitmap
  def setCustomBitmap(bitmap)
    @customBitmap=bitmap
    @customBitmapIsBitmap = @customBitmap.is_a?(Bitmap)
  end

  def dispose
    @pictureBitmap.dispose if @pictureBitmap
    super
  end

  def update
    super
    @pictureBitmap.update if @pictureBitmap
    # If picture file name is different from current one
    if @customBitmap && @picture.name==""
      self.bitmap=@customBitmapIsBitmap ? @customBitmap : @customBitmap.bitmap
    elsif @picture_name != @picture.name ||  @picture.hue.to_i != @hue.to_i
      # Remember file name to instance variables
      @picture_name = @picture.name
      @hue = @picture.hue.to_i
      # If file name is not empty
      if @picture_name != ""
        # Get picture graphic
        @pictureBitmap.dispose if @pictureBitmap
        @pictureBitmap = AnimatedBitmap.new(@picture_name, @hue)
      else
        @pictureBitmap.dispose if @pictureBitmap
        @pictureBitmap=nil
        self.visible = false
        return
      end
      self.bitmap=@pictureBitmap ? @pictureBitmap.bitmap : nil
    elsif @picture_name == ""
      # Set sprite to invisible
      self.visible = false
      return
    end
    # Set sprite to visible
    self.visible = true
    # Set transfer starting point
    case @picture.origin
      when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
        self.oy=0
      when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
        self.oy=self.bitmap ? self.bitmap.height/2 : 0
      when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
        self.oy=self.bitmap ? self.bitmap.height : 0
    end
    case @picture.origin
      when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
        self.ox=0
      when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
        self.ox=self.bitmap ? self.bitmap.width/2 : 0
      when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
        self.ox=self.bitmap ? self.bitmap.width : 0
    end
    # Set sprite coordinates
    self.x = @picture.x
    self.y = @picture.y
    self.z = @picture.number
    # Set zoom rate, opacity level, and blend method
    self.zoom_x = @picture.zoom_x / 100.0
    self.zoom_y = @picture.zoom_y / 100.0
    self.opacity = @picture.opacity
    self.blend_type = @picture.blend_type
    # Set rotation angle and color tone
    angle = @picture.angle
    self.tone = @picture.tone
    while angle < 0
      angle += 360
    end
    angle %= 360
    #if @picture.angle!=0
    #  echo([angle,@picture.angle]+"\r\n")
    #end
    self.angle=angle
  end
end



class EventScene
  attr_accessor :onCTrigger,:onBTrigger,:onUpdate

  def initialize(viewport=nil)
    @viewport=viewport
    @onCTrigger=Event.new
    @onBTrigger=Event.new
    @onUpdate=Event.new
    @pictures=[]
    @picturesprites=[]
    @usersprites=[]
    @disposed=false
  end

  def main
    while !disposed?
      update
    end
  end

  def disposed?
    return @disposed
  end

  def dispose
    return if disposed?
    for sprite in @picturesprites
      sprite.dispose
    end
    for sprite in @usersprites
      sprite.dispose
    end
    @onCTrigger.clear
    @onBTrigger.clear
    @onUpdate.clear
    @pictures.clear
    @picturesprites.clear
    @usersprites.clear
    @disposed=true
  end

  def addBitmap(x,y,bitmap) 
    # _bitmap_ can be a Bitmap or an AnimatedBitmap
    # (update method isn't called if it's animated)
    # EventScene doesn't take ownership of the passed-in bitmap
    num=@pictures.length
    picture=PictureEx.new(num)
    picture.moveXY(0,0,x,y)
    @pictures[num]=picture
    @picturesprites[num]=PictureSprite.new(@viewport,picture)
    @picturesprites[num].setCustomBitmap(bitmap)
    return picture
  end

  def addLabel(x,y,width,text)
    addBitmap(x,y,pbTextBitmap(text,width))    
  end

  def addImage(x,y,name)
    num=@pictures.length
    picture=PictureEx.new(num)
    picture.name=name
    picture.moveXY(0,0,x,y)
    @pictures[num]=picture
    @picturesprites[num]=PictureSprite.new(@viewport,picture)
    return picture
  end

  def getPicture(num)
    return @pictures[num]
  end

  def wait(frames)
    frames.times { update }
  end

  def pictureWait(extraframes=0)
    loop do
      hasRunning=false
      for pic in @pictures
        hasRunning=true if pic.running?
      end
      if hasRunning
        update
      else
        break
      end
    end
    extraframes.times { update }
  end

  def addUserSprite(sprite)
    @usersprites.push(sprite)
  end

  def update
    return if disposed?
    Graphics.update
    Input.update
    for picture in @pictures
      picture.update
    end
    for sprite in @picturesprites
      sprite.update
    end
    for sprite in @usersprites
      if sprite && !sprite.disposed?
        sprite.update if sprite.is_a?(Sprite)
      end
    end
    @onUpdate.trigger(self)
    if Input.trigger?(Input::C)
      @onCTrigger.trigger(self)
    end
    if Input.trigger?(Input::B)
      @onBTrigger.trigger(self)
    end
  end
end



def pbEventScreen(cls)
  pbFadeOutIn(99999){
     viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
     viewport.z=99999
     PBDebug.logonerr {
        cls.new(viewport).main
     }
     viewport.dispose
  }
end