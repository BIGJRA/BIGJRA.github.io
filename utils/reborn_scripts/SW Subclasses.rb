module UpDownArrowMixin
  def initUpDownArrow
    @uparrow=AnimatedSprite.create("Graphics/Pictures/uparrow",8,2,self.viewport)
    @downarrow=AnimatedSprite.create("Graphics/Pictures/downarrow",8,2,self.viewport)
    RPG::Cache.retain("Graphics/Pictures/uparrow")
    RPG::Cache.retain("Graphics/Pictures/downarrow")
    @uparrow.z=99998
    @downarrow.z=99998
    @uparrow.visible=false
    @downarrow.visible=false
    @uparrow.play
    @downarrow.play
  end

  def dispose
    @uparrow.dispose
    @downarrow.dispose
    super
  end

  def viewport=(value)
    super
    @uparrow.viewport=self.viewport
    @downarrow.viewport=self.viewport
  end

  def color=(value)
    super
    @uparrow.color=value
    @downarrow.color=value
  end
  
  def adjustForZoom(sprite)
    sprite.zoom_x=self.zoom_x
    sprite.zoom_y=self.zoom_y
    sprite.x=(sprite.x*self.zoom_x+self.offset_x/self.zoom_x)
    sprite.y=(sprite.y*self.zoom_y+self.offset_y/self.zoom_y)
  end

  def update
    super
    @uparrow.x=self.x+(self.width/2)-(@uparrow.framewidth/2)
    @downarrow.x=self.x+(self.width/2)-(@downarrow.framewidth/2)
    @uparrow.y=self.y
    @downarrow.y=self.y+self.height-@downarrow.frameheight
    @uparrow.visible=self.visible && self.active && (self.top_item!=0 &&
       @item_max > self.page_item_max)
    @downarrow.visible=self.visible && self.active &&
       (self.top_item+self.page_item_max<@item_max && @item_max > self.page_item_max)
    @uparrow.z=self.z+1
    @downarrow.z=self.z+1
    adjustForZoom(@uparrow)
    adjustForZoom(@downarrow)
    @uparrow.viewport=self.viewport
    @downarrow.viewport=self.viewport
    @uparrow.update
    @downarrow.update
  end
end

class SpriteWindow_Selectable < SpriteWindow_Base
  include UpDownArrowMixin
  attr_reader :index

  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @virtualOy=0
    @index = -1
    @row_height = 32
    @column_spacing = 32
    @ignore_input = false
    initUpDownArrow
  end

  def itemCount
    return @item_max || 0
  end

  def index=(index)
    if @index!=index
      @index = index
      priv_update_cursor_rect(true)
    end
  end

  def rowHeight
    return @row_height || 32
  end

  def rowHeight=(value)
    if @row_height!=value
      oldTopRow=self.top_row
      @row_height=[1,value].max
      self.top_row=oldTopRow
      update_cursor_rect
    end
  end

  def columns
    return @column_max || 1
  end

  def columns=(value)
    if @column_max!=value
      @column_max=[1,value].max
      update_cursor_rect
    end
  end

  def columnSpacing
    return @column_spacing || 32
  end

  def columnSpacing=(value)
    if @column_spacing!=value
      @column_spacing=[0,value].max
      update_cursor_rect
    end
  end

  def ignore_input=(value)
    @ignore_input=value
  end

  def count
    return @item_max
  end

  def row_max
    return ((@item_max + @column_max - 1) / @column_max).to_i
  end

  def top_row
    return (@virtualOy / (@row_height || 32)).to_i
  end

  def top_item
    return top_row * @column_max
  end

  def update_cursor_rect
    priv_update_cursor_rect
  end

  def top_row=(row)
    if row>row_max-1
      row=row_max-1
    end
    if row<0 # NOTE: The two comparison checks must be reversed since row_max can be 0
      row=0
    end
    @virtualOy=row*@row_height
  end

  def page_row_max
    return priv_page_row_max.to_i
  end

  def page_item_max
    return priv_page_item_max.to_i
  end

  def itemRect(item)
    if item<0 || item>=@item_max || item<self.top_item ||
       item>self.top_item+self.page_item_max
      return Rect.new(0,0,0,0)
    else
      cursor_width = (self.width-self.borderX-(@column_max-1)*@column_spacing) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = item / @column_max * @row_height - @virtualOy
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def update
    super
    if self.active && @item_max > 0 && @index >= 0 && !@ignore_input
      if Input.repeat?(Input::DOWN)
        if (Input.trigger?(Input::DOWN) && (@item_max % @column_max)==0) || @index < @item_max - @column_max
          oldindex=@index
          @index = (@index + @column_max) % @item_max
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::UP)
        if (Input.trigger?(Input::UP) && (@item_max % @column_max)==0) || @index >= @column_max
          oldindex=@index
          @index = (@index - @column_max + @item_max) % @item_max
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::RIGHT)
        if @column_max >= 2 && @index < @item_max - 1
          oldindex=@index
          @index += 1
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::LEFT)
        if @column_max >= 2 && @index > 0
          oldindex=@index
          @index -= 1
          if @index!=oldindex
            pbPlayCursorSE()
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::R)
        if self.index < @item_max-1
          oldindex=@index
          @index = [self.index+self.page_item_max, @item_max-1].min
          if @index!=oldindex
            pbPlayCursorSE()
            self.top_row += self.page_row_max
            update_cursor_rect
          end
        end
      end
      if Input.repeat?(Input::L)
        if self.index > 0
          oldindex=@index
          @index = [self.index-self.page_item_max, 0].max
          if @index!=oldindex
            pbPlayCursorSE()
            self.top_row -= self.page_row_max
            update_cursor_rect
          end
        end
      end
    end
  end

  def refresh; ;end

  private

  def priv_page_row_max
    return (self.height - self.borderY) / @row_height
  end

  def priv_page_item_max
    return (self.height - self.borderY) / @row_height * @column_max
  end

  def priv_update_cursor_rect(force=false)
    if @index < 0
      self.cursor_rect.empty
      self.refresh
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
      dorefresh=true
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
      dorefresh=true
    end
    self.top_row = [self.top_row, self.row_max - self.page_row_max].min  # ADDED
    cursor_width = (self.width-self.borderX) / @column_max
    x = self.index % @column_max * (cursor_width + @column_spacing)
    y = self.index / @column_max * @row_height - @virtualOy
    self.cursor_rect.set(x, y, cursor_width, @row_height)
    self.refresh if dorefresh || force
  end
end

class Window_DrawableCommand < SpriteWindow_Selectable
  attr_reader :baseColor
  attr_reader :shadowColor

  def textWidth(bitmap,text)
    return tmpbitmap.text_size(i).width
  end

  def getAutoDims(commands,dims,width=nil)
    rowMax=((commands.length + self.columns - 1) / self.columns).to_i
    windowheight=(rowMax*self.rowHeight)
    windowheight+=self.borderY
    if !width || width<0
      width=0
      tmpbitmap=BitmapWrapper.new(1,1)
      pbSetSystemFont(tmpbitmap)
      for i in commands
        width=[width,tmpbitmap.text_size(i).width].max
      end
      # one 16 to allow cursor
      width+=16+16+SpriteWindow_Base::TEXTPADDING
      tmpbitmap.dispose
    end
    # Store suggested width and height of window
    dims[0]=[self.borderX+1,(width*self.columns)+self.borderX+
       (self.columns-1)*self.columnSpacing].max
    dims[1]=[self.borderY+1,windowheight].max
    dims[1]=[dims[1],Graphics.height].min
  end

  def initialize(x,y,width,height,viewport=nil)
    super(x,y,width,height)
    self.viewport=viewport if viewport
    @selarrow=AnimatedBitmap.new("Graphics/Pictures/selarrow")
    RPG::Cache.retain("Graphics/Pictures/selarrow")
    @index=0
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    refresh
  end

  def drawCursor(index,rect)
    if self.index==index
      pbCopyBitmap(self.contents,@selarrow.bitmap,rect.x,rect.y)
    end
    return Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
  end

  def dispose
    @selarrow.dispose
    super
  end

  def baseColor=(value)
    @baseColor=value
    refresh
  end

  def shadowColor=(value)
    @shadowColor=value
    refresh
  end

  def itemCount # to be implemented by derived classes
    return 0
  end

  def drawItem(index,count,rect) # to be implemented by derived classes
  end

  def refresh
    @item_max=itemCount()
    dwidth=self.width-self.borderX
    dheight=self.height-self.borderY
    self.contents=pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...@item_max
      if i<self.top_item || i>self.top_item+self.page_item_max
        next
      end
      drawItem(i,@item_max,itemRect(i))
    end
  end

  def update
    oldindex=self.index
    super
    refresh if self.index!=oldindex
  end
end



class Window_CommandPokemon < Window_DrawableCommand
  attr_reader :commands

  def initialize(commands,width=nil)
    @starting=true
    @commands=[]
    dims=[]
    super(0,0,32,32)
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
    @commands=commands
    self.active=true
    colors=getDefaultTextColors(self.windowskin)
    self.baseColor=colors[0]
    self.shadowColor=colors[1]
    refresh
    @starting=false
  end

  def self.newWithSize(commands,x,y,width,height,viewport=nil)
    ret=self.new(commands,width)
    ret.setHW_XYZ(height,width,x,y)
    ret.viewport=viewport
    return ret
  end

  def self.newEmpty(x,y,width,height,viewport=nil)
    ret=self.new([],width)
    ret.setHW_XYZ(height,width,x,y)
    ret.viewport=viewport
    return ret
  end

  def index=(value)
    super
    refresh if !@starting
  end

  def commands=(value)
    @commands=value
    @item_max=commands.length  
    self.update_cursor_rect
    self.refresh
  end

  def setHW_XYZ(hi,wi,ecks,why,zee=nil)
    super
    if !@starting
      self.index=self.index
      self.update_cursor_rect
    end
  end
  
  def width=(value)
    super
    if !@starting
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def height=(value)
    super
    if !@starting
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def resizeToFit(commands,width=nil)
    dims=[]
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
  end

  def itemCount
    return @commands ? @commands.length : 0
  end

  def drawItem(index,count,rect)
    pbSetSystemFont(self.contents) if @starting
    rect=drawCursor(index,rect)
    pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,
       @commands[index],self.baseColor,self.shadowColor)
  end
end



class Window_AdvancedCommandPokemon < Window_DrawableCommand
  attr_reader :commands

  def textWidth(bitmap,text)
    dims=[nil,0]
    chars=getFormattedText(bitmap,0,0,
       Graphics.width-self.borderX-SpriteWindow_Base::TEXTPADDING-16,
       -1,text,self.rowHeight,true,true)
    for ch in chars
      dims[0]=dims[0] ? [dims[0],ch[1]].min : ch[1]
      dims[1]=[dims[1],ch[1]+ch[3]].max
    end
    dims[0]=0 if !dims[0]
    return dims[1]-dims[0]
  end

  def initialize(commands,width=nil)
    @starting=true
    @commands=[]
    dims=[]
    super(0,0,32,32)
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
    @commands=commands
    self.active=true
    colors=getDefaultTextColors(self.windowskin)
    self.baseColor=colors[0]
    self.shadowColor=colors[1]
    refresh
    @starting=false
  end

  def self.newWithSize(commands,x,y,width,height,viewport=nil)
    ret=self.new(commands,width)
    ret.setHW_XYZ(height,width,x,y)
    ret.viewport=viewport
    return ret
  end

  def self.newEmpty(x,y,width,height,viewport=nil)
    #no size. window empty.
    ret=self.new([],width)
    ret.setHW_XYZ(height,width,x,y)
    ret.viewport=viewport
    return ret
  end

  def index=(value)
    super
    refresh if !@starting
  end

  def commands=(value)
    @commands=value
    @item_max=commands.length
    self.update_cursor_rect
    self.refresh
  end

  def setHW_XYZ(hi,wi,ecks,why,zee=nil)
    oldWvalue=self.width
    oldHvalue=self.height
    super
    if !@starting 
      if oldHvalue!=hi || oldWvalue!=wi
        self.index=self.index
        self.update_cursor_rect
      end
    end
  end
    
  def width=(value)
    oldvalue=self.width
    super
    if !@starting && oldvalue!=value
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def height=(value)
    oldvalue=self.height
    super
    if !@starting && oldvalue!=value
      self.index=self.index
      self.update_cursor_rect
    end
  end

  def resizeToFit(commands,width=nil)
    dims=[]
    getAutoDims(commands,dims,width)
    self.width=dims[0]
    self.height=dims[1]
  end

  def itemCount
    return @commands ? @commands.length : 0
  end

  def drawItem(index,count,rect)
    pbSetSystemFont(self.contents)
    rect=drawCursor(index,rect)
    if toUnformattedText(@commands[index]).gsub(/\n/,"")==@commands[index]
      # Use faster alternative for unformatted text without line breaks
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,
         @commands[index],self.baseColor,self.shadowColor)
    else
      chars=getFormattedText(
         self.contents,rect.x,rect.y,rect.width,rect.height,
         @commands[index],rect.height,true,true)
      drawFormattedChars(self.contents,chars)
    end
  end
end



# Represents a window with no formatting capabilities.  Its text color can be set,
# though, and line breaks are supported, but the text is generally unformatted.
class Window_UnformattedTextPokemon < SpriteWindow_Base
  attr_reader :text
  attr_reader :baseColor
  attr_reader :shadowColor
  # Letter-by-letter mode.  This mode is not supported in this class.
  attr_accessor :letterbyletter

  def text=(value)
    @text=value
    refresh
  end

  def baseColor=(value)
    @baseColor=value
    refresh
  end

  def shadowColor=(value)
    @shadowColor=value
    refresh
  end

  def initialize(text="")
    super(0,0,33,33)
    self.contents=Bitmap.new(1,1)
    pbSetSystemFont(self.contents)
    @text=text
    @letterbyletter=false # Not supported in this class
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    resizeToFit(text)
  end

  def self.newWithSize(text,x,y,width,height,viewport=nil)
    ret=self.new(text)
    ret.setHW_XYZ(height,width,x,y)
    ret.viewport=viewport
    ret.refresh
    return ret
  end

  def resizeToFitInternal(text,maxwidth) # maxwidth is maximum acceptable window width
    dims=[0,0]
    cwidth=maxwidth<0 ? Graphics.width : maxwidth
    getLineBrokenChunks(self.contents,text,
       cwidth-self.borderX-SpriteWindow_Base::TEXTPADDING,dims,true)
    return dims
  end

  def setTextToFit(text,maxwidth=-1)
    resizeToFit(text,maxwidth)
    self.text=text
  end

  def resizeToFit(text,maxwidth=-1) # maxwidth is maximum acceptable window width
    dims=resizeToFitInternal(text,maxwidth)
    self.width=dims[0]+self.borderX+SpriteWindow_Base::TEXTPADDING
    self.height=dims[1]+self.borderY
    refresh
  end

  def resizeHeightToFit(text,width=-1) # width is current window width
    dims=resizeToFitInternal(text,width)
    self.width=width<0 ? Graphics.width : width
    self.height=dims[1]+self.borderY
    refresh
  end

  def refresh
    self.contents=pbDoEnsureBitmap(self.contents,self.width-self.borderX,
       self.height-self.borderY)
    self.contents.clear
    drawTextEx(self.contents,0,0,self.contents.width,0,
       @text.gsub(/\r/,""),@baseColor,@shadowColor)
  end
end



class Window_AdvancedTextPokemon < SpriteWindow_Base
  attr_reader :text
  attr_reader :baseColor
  attr_reader :shadowColor
  attr_accessor :letterbyletter
  attr_reader :lineHeight

  def lineHeight(value)
    @lineHeight=value
    self.text=self.text
  end

  def text=(value)
    setText(value)
  end

  def textspeed
    @frameskip
  end

  def textspeed=(value)
    @frameskip=value
    @frameskipChanged=true
  end

  def waitcount
    @waitcount
  end

  def waitcount=(value)
    @waitcount=(value<=0) ? 0 : value
  end

  def setText(value)
    @waitcount=0
    @curchar=0
    @drawncurchar=-1
    @lastDrawnChar=-1
    oldtext=@text
    @text=value
    @textlength=unformattedTextLength(value)
    @scrollstate=0
    @scrollY=0
    @linesdrawn=0
    @realframes=0
    @textchars=[]
    width=1
    height=1
    numlines=0
    visiblelines=(self.height-self.borderY)/32
    if value.length==0
      @fmtchars=[]
      @bitmapwidth=width
      @bitmapheight=height
      @numtextchars=0
    else
      if !@letterbyletter
        @fmtchars=getFormattedText(self.contents,0,0,
           self.width-self.borderX-SpriteWindow_Base::TEXTPADDING,-1,
           shadowctag(@baseColor,@shadowColor)+value,32,true)
        @oldfont=self.contents.font.clone
        for ch in @fmtchars
          chx=ch[1]+ch[3]
          chy=ch[2]+ch[4]
          width=chx if width<chx
          height=chy if height<chy
          @textchars.push(ch[5] ? "" : ch[0])
        end
      else
        @fmtchars=[]
        fmt=getFormattedText(self.contents,0,0,
           self.width-self.borderX-SpriteWindow_Base::TEXTPADDING,-1,
           shadowctag(@baseColor,@shadowColor)+value,32,true)
        @oldfont=self.contents.font.clone
        for ch in fmt
          chx=ch[1]+ch[3]
          chy=ch[2]+ch[4]
          width=chx if width<chx
          height=chy if height<chy
          if !ch[5] && ch[0]=="\n" && @letterbyletter
            numlines+=1
            if numlines>=visiblelines
              fclone=ch.clone
              fclone[0]="\1"
              @fmtchars.push(fclone)
              @textchars.push("\1")
            end
          end
          # Don't add newline characters, since they
          # can slow down letter-by-letter display
          if ch[5] || (ch[0]!="\r")
            @fmtchars.push(ch)
            @textchars.push(ch[5] ? "" : ch[0])
          end
        end
        fmt.clear
      end
      @bitmapwidth=width
      @bitmapheight=height
      @numtextchars=@textchars.length
    end
    stopPause
    @displaying=@letterbyletter
    @needclear=true
    @nodraw=@letterbyletter
    refresh
  end

  def baseColor=(value)
    @baseColor=value
    refresh
  end

  def shadowColor=(value)
    @shadowColor=value
    refresh
  end

  def busy?
    return @displaying
  end

  def pausing?
    return @pausing && @displaying
  end

  def resume
    if !busy?
      self.stopPause
      return true
    end
    if @pausing
      @pausing=false
      self.stopPause
      return false
    else
      return true
    end
  end

  def dispose
    return if disposed?
    @pausesprite.dispose if @pausesprite
    @pausesprite=nil
    super
  end

  attr_reader :cursorMode

  def cursorMode=(value)
    @cursorMode=value
    moveCursor
  end

  def moveCursor
    if @pausesprite
      cursor=@cursorMode
      cursor=2 if cursor==0 && !@endOfText
      case cursor
        when 0 # End of text
          @pausesprite.x=self.x+self.startX+@endOfText.x+@endOfText.width-2
          @pausesprite.y=self.y+self.startY+@endOfText.y-@scrollY
        when 1 # Lower right
          pauseWidth=@pausesprite.bitmap ? @pausesprite.framewidth : 16
          pauseHeight=@pausesprite.bitmap ? @pausesprite.frameheight : 16
          @pausesprite.x=self.x+self.width-(20*2)+(pauseWidth/2)
          @pausesprite.y=self.y+self.height-(30*2)+(pauseHeight/2)
        when 2 # Lower middle
          pauseWidth=@pausesprite.bitmap ? @pausesprite.framewidth : 16
          pauseHeight=@pausesprite.bitmap ? @pausesprite.frameheight : 16
          @pausesprite.x=self.x+(self.width/2)-(pauseWidth/2)
          @pausesprite.y=self.y+self.height-(18*2)+(pauseHeight/2)
      end
    end
  end

  def initialize(text="")
    @cursorMode=MessageConfig::CURSORMODE
    @endOfText=nil
    @scrollstate=0
    @realframes=0
    @scrollY=0
    @nodraw=false
    @lineHeight=32
    @linesdrawn=0
    @bufferbitmap=nil
    @letterbyletter=false
    @starting=true
    @displaying=false
    @lastDrawnChar=-1
    @fmtchars=[]
    @frameskipChanged=false
    @frameskip=MessageConfig.pbGetTextSpeed()
    super(0,0,33,33)
    @pausesprite=nil
    @text=""
    self.contents=Bitmap.new(1,1)
    pbSetSystemFont(self.contents)
    self.resizeToFit(text,Graphics.width)
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    self.text=text
    @starting=false
  end

  def self.newWithSize(text,x,y,width,height,viewport=nil)
    ret=self.new(text)
    ret.setHW_XYZ(height,width,x,y)
    ret.viewport=viewport
    return ret
  end
  
  def setHW_XYZ(hi,wi,ecks,why,zee=nil)
    super
    if !@starting
      self.text=self.text
    end
  end
  
  def width=(value)
    super
    if !@starting
      self.text=self.text
    end
  end

  def height=(value)
    super
    if !@starting
      self.text=self.text
    end
  end

  def resizeToFitInternal(text,maxwidth)
    dims=[0,0]
    cwidth=maxwidth<0 ? Graphics.width : maxwidth
    chars=getFormattedTextForDims(self.contents,0,0,
       cwidth-self.borderX-2-6,-1,text,@lineHeight,true)
    for ch in chars
      dims[0]=[dims[0],ch[1]+ch[3]].max
      dims[1]=[dims[1],ch[2]+ch[4]].max
    end
    return dims
  end

  def resizeToFit2(text,maxwidth,maxheight)
    dims=resizeToFitInternal(text,maxwidth)
    oldstarting=@starting
    @starting=true
    setwidth = [dims[0]+self.borderX+SpriteWindow_Base::TEXTPADDING,maxwidth].min
    setheight = [dims[1]+self.borderY,maxheight].min
    self.height_width(setheight, setwidth)
    @starting=oldstarting
    redrawText
  end

  def setTextToFit(text,maxwidth=-1)
    resizeToFit(text,maxwidth)
    self.text=text
  end

  def resizeToFit(text,maxwidth=-1)
    dims=resizeToFitInternal(text,maxwidth)
    oldstarting=@starting
    @starting=true
    setwidth = dims[0]+self.borderX+SpriteWindow_Base::TEXTPADDING
    setheight = dims[1]+self.borderY
    self.height_width(setheight, setwidth)
    @starting=oldstarting
    redrawText
  end

  def resizeHeightToFit(text,width=-1)
    dims=resizeToFitInternal(text,width)
    oldstarting=@starting
    @starting=true
    self.width=width<0 ? Graphics.width : width
    self.height=dims[1]+self.borderY
    @starting=oldstarting
    redrawText
  end

  def refresh
    oldcontents=self.contents
    self.contents=pbDoEnsureBitmap(oldcontents,@bitmapwidth,@bitmapheight)
    self.oy=@scrollY
    numchars=@numtextchars
    startchar=0
    numchars=[@curchar,@numtextchars].min if self.letterbyletter
    if busy? && @drawncurchar==@curchar && @scrollstate==0
      return
    end
    if !self.letterbyletter || !oldcontents.equal?(self.contents)
      @drawncurchar=-1
      @needclear=true
    end
    if @needclear
      self.contents.font=@oldfont if @oldfont
      self.contents.clear
      @needclear=false
    end
    if @nodraw
      @nodraw=false
      return
    end
    maxX=self.width-self.borderX
    maxY=self.height-self.borderY
    for i in @drawncurchar+1..numchars
      next if i>=@fmtchars.length
      if !self.letterbyletter
        next if @fmtchars[i][1]>=maxX
        next if @fmtchars[i][2]>=maxY
      end
      drawSingleFormattedChar(self.contents,@fmtchars[i])
      @lastDrawnChar=i
    end
    if !self.letterbyletter
      # all characters were drawn, reset old font
      self.contents.font=@oldfont if @oldfont
    end
    if numchars>0 && numchars!=@numtextchars
      fch=@fmtchars[numchars-1]
      if fch
        rcdst=Rect.new(fch[1],fch[2],fch[3],fch[4])
        if @textchars[numchars]=="\1"
          @endOfText=rcdst
          allocPause
          moveCursor()
        else
          @endOfText=Rect.new(rcdst.x+rcdst.width,rcdst.y,8,1)
        end
      end
    end
    @drawncurchar=@curchar
  end

  def maxPosition
    pos=0
    for ch in @fmtchars
      # index after the last character's index
      pos=ch[14]+1 if pos<ch[14]+1
    end
    return pos
  end

  def position
    if @lastDrawnChar<0
      return 0
    elsif @lastDrawnChar>=@fmtchars.length
      return @numtextchars
    else
      # index after the last character's index
      return @fmtchars[@lastDrawnChar][14]+1 
    end
  end

  def redrawText
    if !@letterbyletter
      self.text=self.text
    else
      oldPosition=self.position
      self.text=self.text
      oldPosition=@numtextchars if oldPosition>@numtextchars
      while self.position!=oldPosition
        refresh
        updateInternal
      end
    end
  end

  def updateInternal
    curcharskip=@frameskip<0 ? @frameskip.abs : 1
    visiblelines=(self.height-self.borderY)/@lineHeight
    if @textchars[@curchar]=="\1"
      if !@pausing
        @realframes+=1
        if @realframes>=@frameskip || @frameskip<0
          curcharSkip(curcharskip)
          @realframes=0
        end
      end
    elsif @textchars[@curchar]=="\n"
      if @linesdrawn>=visiblelines-1
        if @scrollstate<@lineHeight
          @scrollstate+=[(@lineHeight/4),1].max
          @scrollY+=[(@lineHeight/4),1].max
        end
        if @scrollstate>=@lineHeight
          @realframes+=1
          if @realframes>=@frameskip || @frameskip<0
            curcharSkip(curcharskip)
            @linesdrawn+=1
            @scrollstate=0
            @realframes=0
          end
        end
      else
        @realframes+=1
        if @realframes>=@frameskip || @frameskip<0
          curcharSkip(curcharskip)
          @linesdrawn+=1
          @realframes=0
        end
      end
    elsif @curchar<=@numtextchars
      @realframes+=1
      if @realframes>=@frameskip || @frameskip<0
        curcharSkip(curcharskip)
        @realframes=0
      end
      if @textchars[@curchar]=="\1"
        @pausing=true if @curchar<@numtextchars-1
        self.startPause
        refresh
      end
    else
      @displaying=false
      @scrollstate=0
      @scrollY=0
      @linesdrawn=0
    end
  end

  def update
    super
    if @pausesprite && @pausesprite.visible
      @pausesprite.update
    end
    if @waitcount>0
      @waitcount-=1
      return
    end
    if busy?
      refresh if !@frameskipChanged
      updateInternal
      # following line needed to allow "textspeed=-999" to work seamlessly
      refresh if @frameskipChanged 
    end
    @frameskipChanged=false
  end

  def allocPause
    if !@pausesprite
      @pausesprite=AnimatedSprite.create("Graphics/Pictures/pause",4,3)
      @pausesprite.z=100000
      @pausesprite.visible=false
    end
  end

  def startPause
    allocPause
    @pausesprite.visible=true
    @pausesprite.frame=0
    @pausesprite.start
    moveCursor
  end

  def stopPause
    if @pausesprite
      @pausesprite.stop
      @pausesprite.visible=false
    end
  end

  private

  def curcharSkip(skip)
    skip.times do
      @curchar+=1
      break if @textchars[@curchar]=="\n" || # newline
               @textchars[@curchar]=="\1" || # pause
               @textchars[@curchar]=="\2" || # letter-by-letter break
               @textchars[@curchar]==nil
    end
  end
end



class Window_InputNumberPokemon < SpriteWindow_Base
  attr_reader :number
  attr_reader :sign

  def initialize(digits_max)
    @digits_max=digits_max
    @number=0
    @frame=0
    @sign=false
    @negative=false
    super(0,0,32,32)
    self.width=digits_max*24+8+self.borderX
    self.height=32+self.borderY
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    @index=digits_max-1
    self.active=true
    refresh
  end

  def active=(value)
    super
    refresh
  end

  def number
    @number*(@sign && @negative ? -1 : 1)
  end

  def sign=(value)
    @sign=value
    self.width=@digits_max*24+8+self.borderX+(@sign ? 24 : 0)
    @index=(@digits_max-1)+(@sign ? 1 : 0)
    refresh
  end

  def number=(value)
    value=0 if !value.is_a?(Numeric)
    if @sign
      @negative=(value<0)
      @number = [value.abs, 10 ** @digits_max - 1].min
    else
      @number = [[value, 0].max, 10 ** @digits_max - 1].min
    end
    refresh
  end

  def refresh
    self.contents=pbDoEnsureBitmap(self.contents,
       self.width-self.borderX,self.height-self.borderY)
    pbSetSystemFont(self.contents)
    self.contents.clear
    s=sprintf("%0*d",@digits_max,@number.abs)
    x=0
    if @sign
      textHelper(0,0,@negative ? "-" : "+",0)
    end
    for i in 0...@digits_max
      index=i+(@sign ? 1 : 0)
      textHelper(index*24,0,s[i,1],index)
    end
  end

  def update
    super
    digits=@digits_max+(@sign ? 1 : 0)
    refresh if @frame%15==0
    if self.active
      if Input.repeat?(Input::UP) || Input.repeat?(Input::DOWN)
        pbPlayCursorSE()
        if @index==0 && @sign
          @negative=!@negative
        else
          place = 10 ** (digits - 1 - @index)
          n = @number / place % 10
          @number -= n*place
          if Input.repeat?(Input::UP)
            n = (n + 1) % 10
          elsif Input.repeat?(Input::DOWN)
            n = (n + 9) % 10
          end
          @number += n*place
        end
        refresh
      elsif Input.repeat?(Input::RIGHT)
        if digits >= 2
          pbPlayCursorSE()
          @index = (@index + 1) % digits
          @frame=0
          refresh
        end
      elsif Input.repeat?(Input::LEFT)
        if digits >= 2
          pbPlayCursorSE()
          @index = (@index + digits - 1) % digits
          @frame=0
          refresh
        end
      end
    end
    @frame=(@frame+1)%30
  end

  private

  def textHelper(x,y,text,i)
    textwidth=self.contents.text_size(text).width
    self.contents.font.color=@shadowColor
    pbDrawShadow(self.contents,x+(12-textwidth/2),y, textwidth+4, 32, text)
    self.contents.font.color=@baseColor
    self.contents.draw_text(x+(12-textwidth/2),y, textwidth+4, 32, text)    
    if @index==i && @active && @frame/15==0
      colors=getDefaultTextColors(self.windowskin)
      self.contents.fill_rect(x+(12-textwidth/2),y+30,textwidth,2,colors[0])
    end
  end
end



class AnimatedSprite < SpriteWrapper
  attr_reader :frame
  attr_reader :framewidth
  attr_reader :frameheight
  attr_reader :framecount
  attr_reader :animname

  def initializeLong(animname,framecount,framewidth,frameheight,frameskip)
    @animname=pbBitmapName(animname)
    @realframes=0
    @frameskip=[1,frameskip].max
    raise _INTL("Frame width is 0") if framewidth==0
    raise _INTL("Frame height is 0") if frameheight==0
    begin
      @animbitmap=AnimatedBitmap.new(animname).deanimate
      rescue
      @animbitmap=Bitmap.new(framewidth,frameheight)
    end
    if @animbitmap.width%framewidth!=0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame width ({2}) [Bitmap={3}]",
         @animbitmap.width,framewidth,animname)
    end
    if @animbitmap.height%frameheight!=0
      raise _INTL("Bitmap's height ({1}) is not a multiple of frame height ({2}) [Bitmap={3}]",
         @animbitmap.height,frameheight,animname)
    end
    @framecount=framecount
    @framewidth=framewidth
    @frameheight=frameheight
    @framesperrow=@animbitmap.width/@framewidth
    @playing=false
    self.bitmap=@animbitmap
    self.src_rect.width=@framewidth
    self.src_rect.height=@frameheight
    self.frame=0
  end

  # Shorter version of AnimationSprite.  All frames are placed on a single row
  # of the bitmap, so that the width and height need not be defined beforehand
  def initializeShort(animname,framecount,frameskip)
    @animname=pbBitmapName(animname)
    @realframes=0
    @frameskip=[1,frameskip].max
    begin
      @animbitmap=AnimatedBitmap.new(animname).deanimate
      rescue
      @animbitmap=Bitmap.new(framecount*4,32)
    end
    if @animbitmap.width%framecount!=0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame count ({2}) [Bitmap={3}]",
         @animbitmap.width,framewidth,animname)
    end
    @framecount=framecount
    @framewidth=@animbitmap.width/@framecount
    @frameheight=@animbitmap.height
    @framesperrow=framecount
    @playing=false
    self.bitmap=@animbitmap
    self.src_rect.width=@framewidth
    self.src_rect.height=@frameheight
    self.frame=0
  end

  def initialize(*args)
    if args.length==1
      super(args[0][3])
      initializeShort(args[0][0],args[0][1],args[0][2])
    else
      super(args[5])
      initializeLong(args[0],args[1],args[2],args[3],args[4])
    end
  end

  def self.create(animname,framecount,frameskip,viewport=nil)
    return self.new([animname,framecount,frameskip,viewport])
  end

  def dispose
    return if disposed?
    @animbitmap.dispose
    @animbitmap=nil
    super
  end

  def playing?
    return @playing
  end

  def frame=(value)
    @frame=value
    @realframes=0
    self.src_rect.x=@frame%@framesperrow*@framewidth
    self.src_rect.y=@frame/@framesperrow*@frameheight
  end

  def start
    @playing=true
    @realframes=0
  end

  alias play start

  def stop
    @playing=false
  end

  def update
    super
    if @playing
      @realframes+=1
      if @realframes==@frameskip
        @realframes=0 
        self.frame+=1
        self.frame%=self.framecount
      end
    end
  end
end



# Displays an icon bitmap in a sprite. Supports animated images.
class IconSprite < SpriteWrapper
  attr_reader :name

  def initialize(*args)
    if args.length==0
      super(nil)
      self.bitmap=nil
    elsif args.length==1
      super(args[0])
      self.bitmap=nil
    elsif args.length==2
      super(nil)
      self.x=args[0]
      self.y=args[1]
    else
      super(args[2])
      self.x=args[0]
      self.y=args[1]
    end
    @name=""
    @_iconbitmap=nil
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      if self.bitmap!=@_iconbitmap.bitmap
        oldrc=self.src_rect
        self.bitmap=@_iconbitmap.bitmap
        self.src_rect=oldrc
      end
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.bitmap=nil if !self.disposed?
  end

  # Sets the icon's filename.  Alias for setBitmap.
  def name=(value)
    setBitmap(value)
  end

  # Sets the icon's filename.
  def setBitmap(file,hue=0)
    oldrc=self.src_rect
    clearBitmaps()
    @name=file
    return if file==nil
    if file!=""
      @_iconbitmap=AnimatedBitmap.new(file,hue)
      # for compatibility
      self.bitmap=@_iconbitmap ? @_iconbitmap.bitmap : nil
      self.src_rect=oldrc
    else
      @_iconbitmap=nil
    end
  end
end



# Old GifSprite class, retained for compatibility
class GifSprite < IconSprite
  def initialize(path)
    super(0,0)
    setBitmap(path)
  end
end



# Sprite class that maintains a bitmap of its own.
# This bitmap can't be changed to a different one.
class BitmapSprite < SpriteWrapper
  def initialize(width,height,viewport=nil)
    super(viewport)
    self.bitmap=Bitmap.new(width,height)
    @initialized=true
  end

  def bitmap=(value)
    super(value) if !@initialized
  end

  def dispose
    self.bitmap.dispose if !self.disposed?
    super
  end
end

# Displays an icon bitmap in a window. Supports animated images.
class IconWindow < SpriteWindow_Base
  attr_reader :name

  def initialize(x,y,width,height,viewport=nil)
    super(x,y,width,height)
    self.viewport=viewport
    self.contents=nil
    @name=""
    @_iconbitmap=nil
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.contents=@_iconbitmap.bitmap
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.contents=nil if !self.disposed?
  end

  # Sets the icon's filename.  Alias for setBitmap.
  def name=(value)
    setBitmap(value)
  end

  # Sets the icon's filename.
  def setBitmap(file,hue=0)
    clearBitmaps()
    @name=file
    return if file==nil
    if file!=""
      @_iconbitmap=AnimatedBitmap.new(file,hue)
      # for compatibility
      self.contents=@_iconbitmap ? @_iconbitmap.bitmap : nil
    else
      @_iconbitmap=nil
    end
  end
end



# Displays an icon bitmap in a window. Supports animated images.
# Accepts bitmaps and paths to bitmap files in its constructor
class PictureWindow < SpriteWindow_Base
  def initialize(pathOrBitmap)
    super(0,0,32,32)
    self.viewport=viewport
    self.contents=nil
    @_iconbitmap=nil
    setBitmap(pathOrBitmap)
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @_iconbitmap
      if @_iconbitmap.is_a?(Bitmap)
        self.contents=@_iconbitmap
      else
        @_iconbitmap.update
        self.contents=@_iconbitmap.bitmap
      end
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.contents=nil if !self.disposed?
  end

  # Sets the icon's bitmap or filename. (hue parameter
  # is ignored unless pathOrBitmap is a filename)
  def setBitmap(pathOrBitmap,hue=0)
    clearBitmaps()
    if pathOrBitmap!=nil && pathOrBitmap!=""
      if pathOrBitmap.is_a?(Bitmap)
        @_iconbitmap=pathOrBitmap
        self.contents=@_iconbitmap
        self.width=@_iconbitmap.width+self.borderX
        self.height=@_iconbitmap.height+self.borderY
      elsif pathOrBitmap.is_a?(AnimatedBitmap)
        @_iconbitmap=pathOrBitmap
        self.contents=@_iconbitmap.bitmap
        self.width=@_iconbitmap.bitmap.width+self.borderX
        self.height=@_iconbitmap.bitmap.height+self.borderY
      else
        @_iconbitmap=AnimatedBitmap.new(pathOrBitmap,hue)
        self.contents=@_iconbitmap ? @_iconbitmap.bitmap : nil
        self.width=@_iconbitmap ? @_iconbitmap.bitmap.width+self.borderX : 
           32+self.borderX
        self.height=@_iconbitmap ? @_iconbitmap.bitmap.height+self.borderY :
           32+self.borderY
      end
    else
      @_iconbitmap=nil
      self.width=32+self.borderX
      self.height=32+self.borderY
    end
  end
end

#===============================================================================
# SpriteWrapper that stores multiple bitmaps, and displays only one at once.
#===============================================================================
class ChangelingSprite < SpriteWrapper
  def initialize(x=0,y=0,viewport=nil)
    super(viewport)
    self.x = x
    self.y = y
    @bitmaps = {}
    @currentBitmap = nil
  end

  def addBitmap(key,path)
    @bitmaps[key].dispose if @bitmaps[key]
    @bitmaps[key] = AnimatedBitmap.new(path)
  end

  def changeBitmap(key)
    @currentBitmap = @bitmaps[key]
    self.bitmap = (@currentBitmap) ? @currentBitmap.bitmap : nil
  end

  def dispose
    return if disposed?
    for bm in @bitmaps.values; bm.dispose; end
    @bitmaps.clear
    super
  end

  def update
    return if disposed?
    for bm in @bitmaps.values; bm.update; end
    self.bitmap = (@currentBitmap) ? @currentBitmap.bitmap : nil
  end
end
