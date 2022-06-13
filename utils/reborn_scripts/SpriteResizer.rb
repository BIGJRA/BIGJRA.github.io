#===============================================================================
#  Overriding Sprite, Viewport, and Plane to support resizing
#  By Peter O.
#  -- This is a stand-alone RGSS script. --
#===============================================================================
module Graphics
  ## Nominal screen size
  @@width=DEFAULTSCREENWIDTH
  @@height=DEFAULTSCREENHEIGHT

  def self.width
    return @@width
  end

  def self.height
    return @@height
  end

  @@fadeoutvp=Viewport.new(0,0,640,480)
  @@fadeoutvp.z=0x3FFFFFFF
  @@fadeoutvp.color=Color.new(0,0,0,0)

  def self.brightness
    return (255-@@fadeoutvp.color.alpha)
  end

  def self.brightness=(value)
    value=0 if value<0
    value=255 if value>255
    @@fadeoutvp.color.alpha=255-value
  end

  def self.fadein(frames)
    return if frames<=0
    curvalue=self.brightness
    count=(255-self.brightness)
    frames.times do |i|
      self.brightness=curvalue+(count*i/frames)
      self.update
    end
  end

  def self.wait(frames)
    return if frames<=0
    frames.times do |i|
      self.update
    end
  end

  def self.fadeout(frames)
    return if frames<=0
    curvalue=self.brightness
    count=self.brightness
    frames.times do |i|
      self.brightness=curvalue-(count*i/frames)
      self.update
    end
  end
  @@deletefailed=false
end


$ResizeFactor=1.0
$ResizeFactorMul=100
$ResizeOffsetX=0 if !defined?($ResizeOffsetX)
$ResizeOffsetY=0 if !defined?($ResizeOffsetY)
$ResizeFactorSet=false if !defined?($ResizeFactorSet)
$HaveResizeBorder = false if !defined?($HaveResizeBorder)

def pbSetResizeFactor(factor)
  begin
    if factor < 0 || factor == 4
      setScreenBorder
      Graphics.resize_screen(DEFAULTSCREENWIDTH + 2*$ResizeOffsetX,DEFAULTSCREENHEIGHT+2*$ResizeOffsetY)
      Graphics.fullscreen = true if !Graphics.fullscreen
      resizeSpritesAndViewports
    else
      setScreenBorder
      Graphics.resize_screen(DEFAULTSCREENWIDTH + 2*$ResizeOffsetX,DEFAULTSCREENHEIGHT+2*$ResizeOffsetY)
      Graphics.center
      setScreenBorderName("border")
      resizeSpritesAndViewports
      Graphics.fullscreen = false if Graphics.fullscreen
      Graphics.scale = [0.5,1,1.5,2.0][factor]
      Graphics.center
    end
  rescue
    factor = 2
    Graphics.fullscreen = false if Graphics.fullscreen
    Graphics.scale = [0.5,1,1.5,2.0][factor]
    Graphics.center
  end
end

def setScreenBorder
  $ResizeBorder=ScreenBorder.new
  $ResizeBorder.refresh
  border=$idk[:settings] ? $idk[:settings].border : 0
  $ResizeOffsetX=[0,BORDERWIDTH][border]
  $ResizeOffsetY=[0,BORDERHEIGHT][border]
end

def resizeSpritesAndViewports
  # Resize every sprite and viewport
  ObjectSpace.each_object(Sprite){|o|
    next if o.disposed?
    o.x=o.x
    o.y=o.y
    o.ox=o.ox
    o.oy=o.oy
    o.zoom_x=o.zoom_x
    o.zoom_y=o.zoom_y
  }
  ObjectSpace.each_object(Viewport){|o|
    next if o.disposed?
    begin
      o.rect=o.rect
      o.ox=o.ox
      o.oy=o.oy
    rescue RGSSError
    end
  }
end

def setScreenBorderName(border)
  $ResizeBorder=ScreenBorder.new
  $HaveResizeBorder=true
  $ResizeBorder.bordername=border
end

class Sprite
  unless @SpriteResizerMethodsAliased
    alias _initialize_SpriteResizer initialize
    alias _x_SpriteResizer x
    alias _y_SpriteResizer y
    alias _ox_SpriteResizer ox
    alias _oy_SpriteResizer oy
    alias _zoomx_SpriteResizer zoom_x
    alias _zoomy_SpriteResizer zoom_y
    alias _xeq_SpriteResizer x=
    alias _yeq_SpriteResizer y=
    alias _zoomxeq_SpriteResizer zoom_x=
    alias _zoomyeq_SpriteResizer zoom_y=
    alias _oxeq_SpriteResizer ox=
    alias _oyeq_SpriteResizer oy=
    alias _bushdeptheq_SpriteResizer bush_depth=
    @SpriteResizerMethodsAliased=true
  end

  def initialize(viewport=nil)
    _initialize_SpriteResizer(viewport)
    @resizedX=0
    @resizedY=0
    @resizedOx=0
    @resizedOy=0
    @resizedBushDepth=0
    @resizedZoomX=1.0
    @resizedZoomY=1.0
    if $ResizeOffsetX!=0 && $ResizeOffsetY!=0 && !viewport
      _xeq_SpriteResizer($ResizeOffsetX*$ResizeFactorMul/100)
      _yeq_SpriteResizer($ResizeOffsetY*$ResizeFactorMul/100)
    end
     _zoomxeq_SpriteResizer(@resizedZoomX*$ResizeFactorMul/100)
     _zoomyeq_SpriteResizer(@resizedZoomY*$ResizeFactorMul/100)
   end

  def zoom_x
    return @resizedZoomX
  end

  def zoom_x=(val)
    value=val
    if $ResizeFactorMul!=100
      value=(val.to_f*$ResizeFactorMul/100)
      if (value-2.00).abs<=0.001
        value=2.00
      elsif (value-1.50).abs<=0.001
        value=1.50
      elsif (value-1.00).abs<=0.001
        value=1.00
      else
        value=0.50
      end
    end
    _zoomxeq_SpriteResizer(value)
    @resizedZoomX=val
  end

  def zoom_y
    return @resizedZoomY
  end

  def zoom_y=(val)
    value=val
    if $ResizeFactorMul!=100
      value=(val.to_f*$ResizeFactorMul/100)
      if (value-2.00).abs<=0.001
        value=2.00
      elsif (value-1.50).abs<=0.001
        value=1.50
      elsif (value-1.00).abs<=0.001
        value=1.00
      else
        value=0.50
      end
    end
    _zoomyeq_SpriteResizer(value)
    @resizedZoomY=val
  end

  def x
    return @resizedX
  end

  def x=(val)
    if $ResizeFactorMul!=100
      offset=(self.viewport) ? 0 : $ResizeOffsetX
      value=((val.to_i+offset)*$ResizeFactorMul/100)
      _xeq_SpriteResizer(value.to_i)
      @resizedX=val.to_i
    elsif self.viewport
      _xeq_SpriteResizer(val)
      @resizedX=val
    else
      _xeq_SpriteResizer(val + $ResizeOffsetX)
      @resizedX=val
    end
  end

  def y
    return @resizedY
  end

  def bush_depth=(val)
    value=((val.to_i)*$ResizeFactorMul/100)
    _bushdeptheq_SpriteResizer(value.to_i)
    @resizedBushDepth=val.to_i
  end

  def bush_depth
    return @resizedBushDepth
  end

  def y=(val)
    if $ResizeFactorMul!=100
      offset=(self.viewport) ? 0 : $ResizeOffsetY
      value=((val.to_i+offset)*$ResizeFactorMul/100)
      _yeq_SpriteResizer(value.to_i)
      @resizedY=val.to_i
    elsif self.viewport
      _yeq_SpriteResizer(val)
      @resizedY=val
    else
      _yeq_SpriteResizer(val + $ResizeOffsetY)
      @resizedY=val
    end
  end

  def ox=(val)
    if $ResizeFactor!=1.0
      val=(val*$ResizeFactor).to_i
      val=(val/$ResizeFactor).to_i
    end
    @resizedOx=val
    _oxeq_SpriteResizer(val)
  end

  def oy=(val)
    if $ResizeFactor!=1.0
      val=(val*$ResizeFactor).to_i
      val=(val/$ResizeFactor).to_i
    end
    @resizedOy=val
    _oyeq_SpriteResizer(val)
  end

  def ox
    return @resizedOx
  end

  def oy
    return @resizedOy
  end
end



class NotifiableRect < Rect
  def setNotifyProc(proc)
    @notifyProc=proc
  end

  def set(x,y,width,height)
    super
    @notifyProc.call(self) if @notifyProc
  end

  def x=(value)
    super
    @notifyProc.call(self) if @notifyProc
  end

  def y=(value)
    super
    @notifyProc.call(self) if @notifyProc
  end

  def width=(value)
    super
    @notifyProc.call(self) if @notifyProc
  end

  def height=(value)
    super
    @notifyProc.call(self) if @notifyProc
  end
end



class Viewport
  unless @SpriteResizerMethodsAliased
    alias _initialize_SpriteResizer initialize
    alias _rect_ViewportResizer rect
    alias _recteq_SpriteResizer rect=
    alias _oxeq_SpriteResizer ox=
    alias _oyeq_SpriteResizer oy=
    @SpriteResizerMethodsAliased=true
  end

  def initialize(*arg)
    args=arg.clone
    @oldrect=Rect.new(0,0,100,100)
    _initialize_SpriteResizer(
       @oldrect
    )
    newRect=NotifiableRect.new(0,0,0,0)
    @resizedRectProc=Proc.new {|r|
       if $ResizeFactorMul==100
         @oldrect.set(
            r.x.to_i+$ResizeOffsetX,
            r.y.to_i+$ResizeOffsetY,
            r.width.to_i,
            r.height.to_i
         )
         self._recteq_SpriteResizer(@oldrect)
       else
         @oldrect.set(
            ((r.x+$ResizeOffsetX)*$ResizeFactorMul/100).to_i,
            ((r.y+$ResizeOffsetY)*$ResizeFactorMul/100).to_i,
            (r.width*$ResizeFactorMul/100).to_i,
            (r.height*$ResizeFactorMul/100).to_i
         )
         self._recteq_SpriteResizer(@oldrect)
       end
    }
    newRect.setNotifyProc(@resizedRectProc)
    if arg.length==1
      newRect.set(args[0].x,args[0].y,args[0].width,args[0].height)
    else
      newRect.set(args[0],args[1],args[2],args[3])
    end
    @resizedRect=newRect
    @resizedOx=0
    @resizedOy=0
  end
 
  def ox
    return @resizedOx
  end

  def ox=(val)
    return if !val
    _oxeq_SpriteResizer((val*$ResizeFactorMul/100).to_i.to_f)
    @resizedOx=val
  end

  def oy
    return @resizedOy
  end

  def oy=(val)
    return if !val
    _oyeq_SpriteResizer((val*$ResizeFactorMul/100).to_i.to_f)
    @resizedOy=val
  end

  def rect
    return @resizedRect
  end

  def rect=(val)
    if val
      newRect=NotifiableRect.new(0,0,100,100)
      newRect.setNotifyProc(@resizedRectProc)
      newRect.set(val.x.to_i,val.y.to_i,val.width.to_i,val.height.to_i)
      @resizedRect=newRect
    end
  end
end



class Plane
  unless @SpriteResizerMethodsAliased
    alias _initialize_SpriteResizer initialize
    alias _zoomxeq_SpriteResizer zoom_x=
    alias _zoomyeq_SpriteResizer zoom_y=
    alias _oxeq_SpriteResizer ox=
    alias _oyeq_SpriteResizer oy=
    @SpriteResizerMethodsAliased=true
  end

  def initialize(viewport=nil)
    _initialize_SpriteResizer(viewport)
    @resizedZoomX=1.0
    @resizedZoomY=1.0
    @resizedOx=0
    @resizedOy=0
    _zoomxeq_SpriteResizer(@resizedZoomX*$ResizeFactorMul/100)
    _zoomyeq_SpriteResizer(@resizedZoomY*$ResizeFactorMul/100)
  end

  def ox
    return @resizedOx
  end

  def ox=(val)
    return if !val
    _oxeq_SpriteResizer(val*$ResizeFactorMul/100)
    @resizedOx=val
  end

  def oy
    return @resizedOy
  end

  def oy=(val)
    return if !val
    _oyeq_SpriteResizer(val*$ResizeFactorMul/100)
    @resizedOy=val
  end

  def zoom_x
    return @resizedZoomX
  end

  def zoom_x=(val)
    return if !val
    _zoomxeq_SpriteResizer(val*$ResizeFactorMul/100)
    @resizedZoomX=val
  end

  def zoom_y
    return @resizedZoomY
  end

  def zoom_y=(val)
    return if !val
    _zoomyeq_SpriteResizer(val*$ResizeFactorMul/100)
    @resizedZoomY=val
  end
end



###################
class ScreenBorder
  attr_accessor :sprite
  def initialize
    initializeInternal
    refresh
  end

  def initializeInternal
    @maximumZ=500000
    @bordername=""
    @sprite=IconSprite.new(0,0) rescue Sprite.new
    @defaultwidth=640
    @defaultheight=480
    @defaultbitmap=Bitmap.new(@defaultwidth,@defaultheight)
  end

  def dispose
    @borderbitmap.dispose if @borderbitmap
    @defaultbitmap.dispose
    @sprite.dispose
  end

  def adjustZ(z)
    if z>=@maximumZ
      @maximumZ=z+1
      @sprite.z=@maximumZ
    end
  end

  def bordername=(value)
    @bordername=value
    refresh
  end

  def refresh
    @sprite.z=@maximumZ
    @sprite.x=-BORDERWIDTH
    @sprite.y=-BORDERHEIGHT
    @sprite.visible=($idk[:settings] && $idk[:settings].border==1)
    @sprite.bitmap=nil
    if @sprite.visible
      if @bordername!=nil && @bordername!=""
        setSpriteBitmap("Graphics/Pictures/"+@bordername)
      else
        setSpriteBitmap(nil)
        @sprite.bitmap=@defaultbitmap
      end
    end
    @defaultbitmap.clear
    @defaultbitmap.fill_rect(0,0,@defaultwidth,$ResizeOffsetY,Color.new(0,0,0))
    @defaultbitmap.fill_rect(0,$ResizeOffsetY,
       $ResizeOffsetX,@defaultheight-$ResizeOffsetY,Color.new(0,0,0))
    @defaultbitmap.fill_rect(@defaultwidth-$ResizeOffsetX,$ResizeOffsetY,
       $ResizeOffsetX,@defaultheight-$ResizeOffsetY,Color.new(0,0,0))
    @defaultbitmap.fill_rect($ResizeOffsetX,@defaultheight-$ResizeOffsetY,
       @defaultwidth-$ResizeOffsetX*2,$ResizeOffsetY,Color.new(0,0,0))
  end

  private

  def setSpriteBitmap(x)
    if (@sprite.is_a?(IconSprite) rescue false)
      @sprite.setBitmap(x)
    else
      @sprite.bitmap=x ? RPG::Cache.load_bitmap("",x) : nil
    end
  end
end
