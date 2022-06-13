class Window_CharacterEntry < Window_DrawableCommand
  XSIZE=13
  YSIZE=4

  def initialize(charset,viewport=nil)
    @viewport=viewport
    @charset=charset
    @othercharset=""
    super(0,96,480,192)
    colors=getDefaultTextColors(self.windowskin)
    self.baseColor=colors[0]
    self.shadowColor=colors[1]
    self.columns=XSIZE
    refresh
  end

  def setOtherCharset(value)
    @othercharset=value.clone
    refresh
  end

  def setCharset(value)
    @charset=value.clone
    refresh
  end

  def character
    if self.index<0 || self.index>=@charset.length
      return "";
    else
      return @charset[self.index]
    end
  end

  def command
    return -1 if self.index==@charset.length
    return -2 if self.index==@charset.length+1
    return -3 if self.index==@charset.length+2
    return self.index
  end

  def itemCount
    return @charset.length+3
  end

  def drawItem(index,count,rect)
    rect=drawCursor(index,rect)
    if index==@charset.length # -1
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,"[ ]",
         self.baseColor,self.shadowColor)
    elsif index==@charset.length+1 # -2
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,@othercharset,
         self.baseColor,self.shadowColor)
    elsif index==@charset.length+2 # -3
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,_INTL("OK"),
         self.baseColor,self.shadowColor)
    else
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,@charset[index],
         self.baseColor,self.shadowColor)
    end
  end
end



class CharacterEntryHelper
  attr_reader :text
  attr_reader :maxlength
  attr_reader :passwordChar 
  attr_accessor :cursor

  def text=(value)
    @text=value
    ensure
  end

  def textChars
    chars=text.scan(/./m)
    if @passwordChar!=""
      chars.length.times {|i|
         chars[i]=@passwordChar
      }
    end
   return chars
 end

  def initialize(text)
    @maxlength=-1
    @text=text
    @passwordChar=""
    @cursor=text.scan(/./m).length
    ensure
  end

  def passwordChar=(value)
    @passwordChar=value ? value : ""
  end

  def maxlength=(value)
    @maxlength=value
    ensure
  end

  def length
    return self.text.scan(/./m).length
  end

  def canInsert?
    chars=self.text.scan(/./m)
    return false if @maxlength>=0 && chars.length>=@maxlength
    return true
  end

  def insert(ch)
    chars=self.text.scan(/./m)
    return false if @maxlength>=0 && chars.length>=@maxlength
    chars.insert(@cursor,ch)
    @text=""
    for ch in chars
      @text+=ch if ch
    end
    @cursor+=1
    return true
  end

  def canDelete?
    chars=self.text.scan(/./m)
    return false if chars.length<=0 || @cursor<=0
    return true
  end

  def delete
    chars=self.text.scan(/./m)
    return false if chars.length<=0 || @cursor<=0
    chars.delete_at(@cursor-1)
    @text=""
    for ch in chars
      @text+=ch if ch
    end
    @cursor-=1
    return true
  end

  private

  def ensure
    return if @maxlength<0
    chars=self.text.scan(/./m)
    if chars.length>@maxlength && @maxlength>=0
      chars=chars[0,@maxlength]
    end
    @text=""
    for ch in chars
      @text+=ch if ch
    end
  end
end



class Window_TextEntry < SpriteWindow_Base
  def initialize(text,x,y,width,height,heading=nil,usedarkercolor=false)
    super(x,y,width,height)
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    if usedarkercolor
      @baseColor=Color.new(16,24,32)
      @shadowColor=Color.new(168,184,184)
    end
    @helper=CharacterEntryHelper.new(text)
    @heading=heading
    self.active=true
    @frame=0
    refresh
  end

  def text
    @helper.text
  end

  def maxlength
    @helper.maxlength
  end

  def passwordChar
    @helper.passwordChar
  end

  def text=(value)
    @helper.text=value
    self.refresh
  end

  def passwordChar=(value)
    @helper.passwordChar=value
    refresh
  end

  def maxlength=(value)
    @helper.maxlength=value 
    self.refresh
  end

  def insert(ch)
    if @helper.insert(ch)
      @frame=0
      self.refresh
      return true
    end
    return false
  end

  def delete
    if @helper.delete
      @frame=0
      self.refresh
      return true
    end
    return false
  end

  def update
    @frame+=1
    @frame%=20
    self.refresh if ((@frame%10)==0)
    return if !self.active
    # Moving cursor
    if Input.repeat?(Input::LEFT) && Input.press?(Input::A)
      if @helper.cursor > 0
        @helper.cursor-=1
        @frame=0
        self.refresh
      end
      return
    end
    if Input.repeat?(Input::RIGHT) && Input.press?(Input::A)
      if @helper.cursor < self.text.scan(/./m).length
        @helper.cursor+=1
        @frame=0
        self.refresh
      end
      return
    end
    # Backspace
    if Input.repeat?(Input::B)
      self.delete if @helper.cursor > 0
      return
    end
  end

  def refresh
    self.contents=pbDoEnsureBitmap(self.contents,self.width-self.borderX,
       self.height-self.borderY)
    bitmap=self.contents
    bitmap.clear
    x=0
    y=0
    if @heading
      textwidth=bitmap.text_size(@heading).width
      pbDrawShadowText(bitmap,x,y, textwidth+4, 32, @heading,@baseColor,@shadowColor)
      y+=32
    end
    x+=4
    width=self.width-self.borderX
    height=self.height-self.borderY
    cursorcolor=Color.new(16,24,32)
    textscan=self.text.scan(/./m)
    scanlength=textscan.length
    @helper.cursor=scanlength if @helper.cursor>scanlength
    @helper.cursor=0 if @helper.cursor<0
    startpos=@helper.cursor
    fromcursor=0
    while (startpos>0)
      c=(@helper.passwordChar!="") ? @helper.passwordChar : textscan[startpos-1]
      fromcursor+=bitmap.text_size(c).width
      break if fromcursor>width-4
      startpos-=1
    end
    for i in startpos...scanlength
      c=(@helper.passwordChar!="") ? @helper.passwordChar : textscan[i]
      textwidth=bitmap.text_size(c).width
      next if c=="\n"  
      # Draw text
      pbDrawShadowText(bitmap,x,y, textwidth+4, 32, c,@baseColor,@shadowColor)
      # Draw cursor if necessary
      if ((@frame/10)&1) == 0 && i==@helper.cursor
        bitmap.fill_rect(x,y+4,2,24,cursorcolor)
      end
      # Add x to drawn text width
      x += textwidth
    end
    if ((@frame/10)&1) == 0 && textscan.length==@helper.cursor
      bitmap.fill_rect(x,y+4,2,24,cursorcolor)
    end
  end
end



def getLineBrokenText(bitmap,value,width,dims)
  x=0
  y=0
  textheight=0
  ret=[]
  if dims
    dims[0]=0
    dims[1]=0
  end
  line=0
  position=0
  column=0
  return ret if !bitmap || bitmap.disposed? || width<=0
  textmsg=value.clone
  lines=0
  color=Font.default_color
  ret.push(["",0,0,0,bitmap.text_size("X").height,0,0,0,0])
  while ((c = textmsg.slice!(/\n|(\S*([ \r\t\f]?))/)) != nil)
    break if c==""
    length=c.scan(/./m).length
    ccheck=c
    if ccheck=="\n"
      ret.push(["\n",x,y,0,textheight,line,position,column,0])
      x=0
      y+=(textheight==0) ? bitmap.text_size("X").height : textheight
      line+=1
      textheight=0
      column=0
      position+=length
      ret.push(["",x,y,0,textheight,line,position,column,0])
      next
    end
    textcols=[]
    words=[ccheck]
    for i in 0...words.length
      word=words[i]
      if word && word!=""
        textSize=bitmap.text_size(word)
        textwidth=textSize.width
        if x>0 && x+textwidth>=width-2
          # Zero-length word break
          ret.push(["",x,y,0,textheight,line,position,column,0])
          x=0
          column=0
          y+=(textheight==0) ? bitmap.text_size("X").height : textheight
          line+=1
          textheight=0
        end
        textheight=[textheight,textSize.height].max
        ret.push([word,x,y,textwidth,textheight,line,position,column,length])
        x+=textwidth
        dims[0]=x if dims && dims[0]<x
      end
      if textcols[i]
        color=textcols[i]
      end
    end
    position+=length
    column+=length
  end
  dims[1]=y+textheight if dims
  return ret
end



class Window_MultilineTextEntry < SpriteWindow_Base
  def initialize(text,x,y,width,height)
    super(x,y,width,height)
    colors=getDefaultTextColors(self.windowskin)
    @baseColor=colors[0]
    @shadowColor=colors[1]
    @helper=CharacterEntryHelper.new(text)
    @firstline=0
    @cursorLine=0
    @cursorColumn=0
    @frame=0
    self.active=true
    refresh
  end

  attr_reader :baseColor
  attr_reader :shadowColor

  def baseColor=(value)
    @baseColor=value
    refresh
  end

  def shadowColor=(value)
    @shadowColor=value
    refresh
  end

  def text
    @helper.text
  end

  def maxlength
    @helper.maxlength
  end

  def text=(value)
    @helper.text=value
    @textchars=nil
    self.refresh
  end

  def maxlength=(value)
    @helper.maxlength=value 
    @textchars=nil
    self.refresh
  end

  def insert(ch)
    @helper.cursor=getPosFromLineAndColumn(@cursorLine,@cursorColumn)
    if @helper.insert(ch)
      @frame=0
      @textchars=nil
      moveCursor(0,1)
      self.refresh
      return true
    end
    return false
  end

  def delete
    @helper.cursor=getPosFromLineAndColumn(@cursorLine,@cursorColumn)
    if @helper.delete
      @frame=0
      moveCursor(0,-1) # use old textchars
      @textchars=nil
      self.refresh
      return true
    end
    return false
  end

  def getTextChars
    if !@textchars
      @textchars=getLineBrokenText(self.contents,@helper.text,
         self.contents.width,nil)
    end
    return @textchars
  end

  def getTotalLines
    textchars=getTextChars
    if textchars.length==0
      return 1
    else
      tchar=textchars[textchars.length-1]
      return tchar[5]+1
    end
  end

  def getLineY(line)
    textchars=getTextChars
    if textchars.length==0
      return 0
    else
      totallines=getTotalLines()
      line=0 if line<0
      line=totallines-1 if line>=totallines
      maximumY=0
      for i in 0...textchars.length
        thisline=textchars[i][5]
        y=textchars[i][2]
        return y if thisline==line
        maximumY=y if maximumY<y
      end
      return maximumY
    end
  end

  def getColumnsInLine(line)
    textchars=getTextChars
    if textchars.length==0
      return 0
    else
      totallines=getTotalLines()
      line=0 if line<0
      line=totallines-1 if line>=totallines
      endpos=0
      for i in 0...textchars.length
        thisline=textchars[i][5]
        thispos=textchars[i][6]
        thislength=textchars[i][8]
        if thisline==line
          endpos+=thislength
        end
      end
      return endpos
    end
  end

  def getPosFromLineAndColumn(line,column)
    textchars=getTextChars
    if textchars.length==0
      return 0
    else
      totallines=getTotalLines()
      line=0 if line<0
      line=totallines-1 if line>=totallines
      endpos=0
      for i in 0...textchars.length
        thisline=textchars[i][5]
        thispos=textchars[i][6]
        thiscolumn=textchars[i][7]
        thislength=textchars[i][8]
        if thisline==line
          endpos=thispos+thislength
#         echoln [endpos,thispos+(column-thiscolumn),textchars[i]]
          if column>=thiscolumn && column<=thiscolumn+thislength && thislength>0
            return thispos+(column-thiscolumn)
          end
        end
      end
      if endpos==0
#       echoln [totallines,line,column]
#       echoln textchars
      end
#     echoln "endpos=#{endpos}"
      return endpos
    end
  end

  def getLastVisibleLine
    textchars=getTextChars()
    textheight=[1,self.contents.text_size("X").height].max
    lastVisible=@firstline+((self.height-self.borderY)/textheight)-1
    return lastVisible
  end

  def updateCursorPos(doRefresh)
    # Calculate new cursor position
    @helper.cursor=getPosFromLineAndColumn(@cursorLine,@cursorColumn)
    if doRefresh
      @frame=0
      self.refresh
    end
    if @cursorLine<@firstline
      @firstline=@cursorLine
    end
    lastVisible=getLastVisibleLine()
    if @cursorLine>lastVisible
      @firstline+=(@cursorLine-lastVisible)
    end
  end

  def moveCursor(lineOffset, columnOffset)
    # Move column offset first, then lines (since column offset
    # can affect line offset)
#   echoln ["beforemoving",@cursorLine,@cursorColumn]
    totalColumns=getColumnsInLine(@cursorLine) # check current line
    totalLines=getTotalLines()
    oldCursorLine=@cursorLine
    oldCursorColumn=@cursorColumn
    @cursorColumn+=columnOffset
    if @cursorColumn<0 && @cursorLine>0
      # Will happen if cursor is moved left from the beginning of a line
      @cursorLine-=1
      @cursorColumn=getColumnsInLine(@cursorLine)
    elsif @cursorColumn>totalColumns && @cursorLine<totalLines-1
      # Will happen if cursor is moved right from the end of a line
      @cursorLine+=1
      @cursorColumn=0
      updateColumns=true
    end
    # Ensure column bounds
    totalColumns=getColumnsInLine(@cursorLine)
    @cursorColumn=totalColumns if @cursorColumn>totalColumns
    @cursorColumn=0 if @cursorColumn<0 # totalColumns can be 0
    # Move line offset
    @cursorLine+=lineOffset
    @cursorLine=0 if @cursorLine<0
    @cursorLine=totalLines-1 if @cursorLine>=totalLines
    # Ensure column bounds again
    totalColumns=getColumnsInLine(@cursorLine)
    @cursorColumn=totalColumns if @cursorColumn>totalColumns
    @cursorColumn=0 if @cursorColumn<0 # totalColumns can be 0
    updateCursorPos(
       oldCursorLine!=@cursorLine ||
       oldCursorColumn!=@cursorColumn
    )
#   echoln ["aftermoving",@cursorLine,@cursorColumn]
  end

  def update
    @frame+=1
    @frame%=20
    self.refresh if ((@frame%10)==0)
    return if !self.active
    # Moving cursor
    if Input.triggerex?(:UP) || Input.repeatex?(:UP)
      moveCursor(-1,0)
      return
    elsif Input.triggerex?(:DOWN) || Input.repeatex?(:DOWN)
      moveCursor(1,0)
      return
    elsif Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      moveCursor(0,-1)
      return
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      moveCursor(0,1)
      return
    end
    if Input.press?(Input::CTRL) && Input.triggerex?(:HOME)
      # Move cursor to beginning
      @cursorLine=0
      @cursorColumn=0
      updateCursorPos(true)
      return
    elsif Input.press?(Input::CTRL) && Input.triggerex?(:END)
      # Move cursor to end
      @cursorLine=getTotalLines()-1
      @cursorColumn=getColumnsInLine(@cursorLine)
      updateCursorPos(true)
      return
    elsif Input.triggerex?(:RETURN) || Input.repeatex?(:RETURN)
      self.insert("\n")
      return
    elsif Input.triggerex?(:BACKSPACE) || Input.repeatex?(:BACKSPACE)   # Backspace
      self.delete
      return
    end
    Input.gets.each_char{|c|insert(c)}
  end

  def refresh
    newContents=pbDoEnsureBitmap(self.contents,self.width-self.borderX,
       self.height-self.borderY)
    @textchars=nil if self.contents!=newContents
    self.contents=newContents
    bitmap=self.contents
    bitmap.clear
    getTextChars
    height=self.height-self.borderY
    cursorcolor=Color.new(0,0,0)
    textchars=getTextChars()
    startY=getLineY(@firstline)
    for i in 0...textchars.length
      thisline=textchars[i][5]
      thiscolumn=textchars[i][7]
      thislength=textchars[i][8]
      textY=textchars[i][2]-startY
      # Don't draw lines before the first or zero-length segments
      next if thisline<@firstline || thislength==0
      # Don't draw lines beyond the window's height
      break if textY >= height
      c=textchars[i][0]
      # Don't draw spaces
      next if c==" "
      textwidth=textchars[i][3]+4   # add 4 to prevent draw_text from stretching text
      textheight=textchars[i][4]
      # Draw text
      pbDrawShadowText(bitmap, textchars[i][1], textY, textwidth, textheight, c, @baseColor, @shadowColor)
    end
    # Draw cursor
    if ((@frame/10)&1) == 0
      textheight=bitmap.text_size("X").height
      cursorY=(textheight*@cursorLine)-startY
      cursorX=0
      for i in 0...textchars.length
        thisline=textchars[i][5]
        thiscolumn=textchars[i][7]
        thislength=textchars[i][8]
        if thisline==@cursorLine && @cursorColumn>=thiscolumn &&
           @cursorColumn<=thiscolumn+thislength
          cursorY=textchars[i][2]-startY
          cursorX=textchars[i][1]
          textheight=textchars[i][4]
          posToCursor=@cursorColumn-thiscolumn
          if posToCursor>=0
            partialString=textchars[i][0].scan(/./m)[0,posToCursor].join("")
            cursorX+=bitmap.text_size(partialString).width
          end
          break
        end
      end
      cursorY+=4
      cursorHeight=[4,textheight-4,bitmap.text_size("X").height-4].max
      bitmap.fill_rect(cursorX,cursorY,2,cursorHeight,cursorcolor)
    end
  end
end



class Window_TextEntry_Keyboard < Window_TextEntry
  def update
    @frame+=1
    @frame%=20
    self.refresh if ((@frame%10)==0)
    return if !self.active
    # Moving cursor
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      if @helper.cursor > 0
        @helper.cursor-=1
        @frame=0
        self.refresh
      end
      return
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      if @helper.cursor < self.text.scan(/./m).length
        @helper.cursor+=1
        @frame=0
        self.refresh
      end
      return
    elsif Input.triggerex?(:BACKSPACE) || Input.repeatex?(:BACKSPACE)
      self.delete if @helper.cursor>0
      return
    elsif Input.triggerex?(:RETURN) || Input.triggerex?(:ESCAPE)
      return
    end
    Input.gets.each_char { |c| insert(c) }
  end
end



def Kernel.pbFreeText(msgwindow,currenttext,passwordbox,maxlength,width=240)
  window=Window_TextEntry_Keyboard.new(currenttext,0,0,width,64)
  Input.text_input = true
  ret=""
  window.maxlength=maxlength
  window.visible=true
  window.z=99999
  pbPositionNearMsgWindow(window,msgwindow,:right)
  window.text=currenttext
  window.passwordChar="*" if passwordbox
  loop do
    Graphics.update
    Input.update
    if Input.triggerex?(0x1B)
      ret=currenttext
      break
    end
    if Input.triggerex?(13)
      ret=window.text
      break
    end
    window.update
    msgwindow.update if msgwindow
    yield if block_given?
  end
  window.dispose
  Input.update
  Input.text_input = false
  return ret
end

def Kernel.pbMessageFreeText(message,currenttext,passwordbox,maxlength,width=240,&block)
  msgwindow=Kernel.pbCreateMessageWindow
  retval=Kernel.pbMessageDisplay(msgwindow,message,true,
     proc{|msgwindow|
        next Kernel.pbFreeText(msgwindow,currenttext,passwordbox,maxlength,width,&block)
     },&block)
  Kernel.pbDisposeMessageWindow(msgwindow)
  return retval
end



#===============================================================================
# Text entry screen - free typing.
#===============================================================================
class PokemonEntryScene
  @@Characters=[
     [("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").scan(/./),"[*]"],
     [("0123456789   !@\#$%^&*()   ~`-_+={}[]   :;'\"<>,.?/   ").scan(/./),"[A]"],
  ]
  USEKEYBOARD=true

  def pbStartScene(helptext,minlength,maxlength,initialText,subject=0,pokemon=nil)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    if USEKEYBOARD
      @sprites["entry"]=Window_TextEntry_Keyboard.new(initialText,
         0,0,400-112,96,helptext,true)
      Input.text_input = true
    else
      @sprites["entry"]=Window_TextEntry.new(initialText,0,0,400,96,helptext,true)
    end
    @sprites["entry"].x=(Graphics.width/2)-(@sprites["entry"].width/2)+32
    @sprites["entry"].viewport=@viewport
    @sprites["entry"].visible=true
    @minlength=minlength
    @maxlength=maxlength
    @symtype=0
    @sprites["entry"].maxlength=maxlength
    if !USEKEYBOARD
      @sprites["entry2"]=Window_CharacterEntry.new(@@Characters[@symtype][0])
      @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
      @sprites["entry2"].viewport=@viewport
      @sprites["entry2"].visible=true
      @sprites["entry2"].x=(Graphics.width/2)-(@sprites["entry2"].width/2)
    end
    if minlength==0
      @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize(
         _INTL("Enter text using the keyboard. Press\nEnter to confirm, or Esc to cancel."),
         32,Graphics.height-96,Graphics.width-64,96,@viewport
      )
    else
      @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize(
         _INTL("Enter text using the keyboard.\nPress Enter to confirm."),
         32,Graphics.height-96,Graphics.width-64,96,@viewport
      )
    end
    @sprites["helpwindow"].letterbyletter=false
    @sprites["helpwindow"].viewport=@viewport
    @sprites["helpwindow"].visible=USEKEYBOARD
    @sprites["helpwindow"].baseColor=Color.new(16,24,32)
    @sprites["helpwindow"].shadowColor=Color.new(168,184,184)
    addBackgroundPlane(@sprites,"background","Naming/naming2bg",@viewport)
    case subject
    when 1   # Player
      meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
      if meta
        @sprites["shadow"]=IconSprite.new(0,0,@viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x=33*2
        @sprites["shadow"].y=32*2
        filename=pbGetPlayerCharset(meta,1)
        @sprites["subject"]=TrainerWalkingCharSprite.new(filename,@viewport)
        charwidth=@sprites["subject"].bitmap.width
        charheight=@sprites["subject"].bitmap.height
        @sprites["subject"].x = 44*2 - charwidth/8
        @sprites["subject"].y = 38*2 - charheight/4
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"]=IconSprite.new(0,0,@viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x=66
        @sprites["shadow"].y=64
        @sprites["subject"]=PokemonIconSprite.new(pokemon,@viewport)
        @sprites["subject"].x=56
        @sprites["subject"].y=14
        @sprites["gender"]=BitmapSprite.new(32,32,@viewport)
        @sprites["gender"].x=430
        @sprites["gender"].y=54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos=[]
        if pokemon.isMale?
          textpos.push([_INTL("♂"),0,0,false,Color.new(0,128,248),Color.new(168,184,184)])
        elsif pokemon.isFemale?
          textpos.push([_INTL("♀"),0,0,false,Color.new(248,24,24),Color.new(168,184,184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap,textpos)
      end
    when 3   # NPC
      @sprites["shadow"]=IconSprite.new(0,0,@viewport)
      @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
      @sprites["shadow"].x=33*2
      @sprites["shadow"].y=32*2
      @sprites["subject"]=BitmapSprite.new(32,32,@viewport)
      charwidth=@sprites["subject"].bitmap.width
      charheight=@sprites["subject"].bitmap.height
      @sprites["subject"].x = 44*2 - charwidth/8
      @sprites["subject"].y = 38*2 - charheight/4
    when 4   # Storage box
      @sprites["subject"]=TrainerWalkingCharSprite.new(nil,@viewport)
      @sprites["subject"].altcharset="Graphics/Pictures/Naming/icon_storage"
      @sprites["subject"].animspeed=4
      charwidth=@sprites["subject"].bitmap.width
      charheight=@sprites["subject"].bitmap.height
      @sprites["subject"].x = 44*2 - charwidth/8
      @sprites["subject"].y = 26*2 - charheight/2
    end
    pbFadeInAndShow(@sprites)
  end

  def pbEntry1
    ret=""
    loop do
      Graphics.update
      Input.update
      if Input.triggerex?(:ESCAPE) && @minlength==0
        ret=""
        break
      elsif Input.triggerex?(:RETURN) && @sprites["entry"].text.length>=@minlength
        ret=@sprites["entry"].text
        break
      end
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["subject"].update if @sprites["subject"]
    end
    Input.update
    return ret
  end

  def pbEntry2
    ret=""
    loop do
      Graphics.update
      Input.update
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["entry2"].update
      @sprites["subject"].update if @sprites["subject"]
      if Input.trigger?(Input::USE)
        index=@sprites["entry2"].command
        if index==-3 # Confirm text
          ret=@sprites["entry"].text
          if ret.length<@minlength || ret.length>@maxlength
            pbPlayBuzzerSE()
          else
            pbPlayDecisionSE()
            break
          end
        elsif index==-1 # Insert a space
          if @sprites["entry"].insert(" ")
            pbPlayDecisionSE()
          else
            pbPlayBuzzerSE()
          end
        elsif index==-2 # Change character set
          pbPlayDecisionSE()
          @symtype+=1
          @symtype=0 if @symtype>=@@Characters.length
          @sprites["entry2"].setCharset(@@Characters[@symtype][0])
          @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
        else # Insert given character
          if @sprites["entry"].insert(@sprites["entry2"].character)
            pbPlayDecisionSE()
          else
            pbPlayBuzzerSE()
          end
        end
        next
      end
    end
    Input.update
    return ret
  end

  def pbEntry
    return USEKEYBOARD ? pbEntry1 : pbEntry2
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    Input.text_input = false if USEKEYBOARD
  end
end



#===============================================================================
# Text entry screen - arrows to select letter.
#===============================================================================
class PokemonEntryScene2
  @@Characters=[
     [("ABCDEFGHIJ ,."+"KLMNOPQRST '-"+"UVWXYZ     ♂♀"+"             "+"0123456789   ").scan(/./),_INTL("UPPER")],
     [("abcdefghij ,."+"klmnopqrst '-"+"uvwxyz     ♂♀"+"             "+"0123456789   ").scan(/./),_INTL("lower")],
     [(",.:;!?   ♂♀  "+"\"'()<>[]     "+"~@#%*&$      "+"+-=^_/\\|     "+"             ").scan(/./),_INTL("other")],
  ]
  ROWS=13
  COLUMNS=5
  MODE1=-5
  MODE2=-4
  MODE3=-3
  BACK=-2
  OK=-1

  class NameEntryCursor
    def initialize(viewport)
      @sprite=SpriteWrapper.new(viewport)
      @cursortype=0
      @cursor1=AnimatedBitmap.new("Graphics/Pictures/Naming/NamingCursor1")
      @cursor2=AnimatedBitmap.new("Graphics/Pictures/Naming/NamingCursor2")
      @cursor3=AnimatedBitmap.new("Graphics/Pictures/Naming/NamingCursor3")
      @cursorPos=0
      updateInternal
    end

    def setCursorPos(value)
      @cursorPos=value
    end

    def updateCursorPos
      value=@cursorPos
      if value==PokemonEntryScene2::MODE1 # Upper case
        @sprite.x=48
        @sprite.y=120
        @cursortype=1
      elsif value==PokemonEntryScene2::MODE2 # Lower case
        @sprite.x=112
        @sprite.y=120
        @cursortype=1
      elsif value==PokemonEntryScene2::MODE3 # Other symbols
        @sprite.x=176
        @sprite.y=120
        @cursortype=1
      elsif value==PokemonEntryScene2::BACK # Back
        @sprite.x=312
        @sprite.y=120
        @cursortype=2
      elsif value==PokemonEntryScene2::OK # OK
        @sprite.x=392
        @sprite.y=120
        @cursortype=2
      elsif value>=0
        @sprite.x=52+32*(value%PokemonEntryScene2::ROWS)
        @sprite.y=180+38*(value/PokemonEntryScene2::ROWS)
        @cursortype=0
      end
    end

    def visible=(value)
      @sprite.visible=value
    end

    def visible
      @sprite.visible
    end

    def color=(value)
      @sprite.color=value
    end

    def color
      @sprite.color
    end

    def disposed?
      @sprite.disposed?
    end

    def updateInternal
      @cursor1.update
      @cursor2.update
      @cursor3.update
      updateCursorPos
      case @cursortype
        when 0
          @sprite.bitmap=@cursor1.bitmap
        when 1
          @sprite.bitmap=@cursor2.bitmap
        when 2
          @sprite.bitmap=@cursor3.bitmap
      end
    end

    def update
      updateInternal    
    end

    def dispose
      @cursor1.dispose
      @cursor2.dispose
      @cursor3.dispose
      @sprite.dispose
    end
  end



  def pbStartScene(helptext,minlength,maxlength,initialText,subject=0,pokemon=nil)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @helptext=helptext
    @helper=CharacterEntryHelper.new(initialText)
    @bitmaps=[
       AnimatedBitmap.new("Graphics/Pictures/Naming/namingTab1"),
       AnimatedBitmap.new("Graphics/Pictures/Naming/namingTab2"),
       AnimatedBitmap.new("Graphics/Pictures/Naming/namingTab3")
    ]
    @bitmaps[3]=@bitmaps[0].bitmap.clone
    @bitmaps[4]=@bitmaps[1].bitmap.clone
    @bitmaps[5]=@bitmaps[2].bitmap.clone
    for i in 0...3
      pos=0
      pbSetSystemFont(@bitmaps[i+3])
      textPos=[]
      for y in 0...COLUMNS
        for x in 0...ROWS
          textPos.push([@@Characters[i][0][pos],44+x*32,18+y*38,2,
             Color.new(16,24,32), Color.new(160,160,160)])
          pos+=1
        end
      end
      pbDrawTextPositions(@bitmaps[i+3],textPos)
    end
    @bitmaps[6]=BitmapWrapper.new(24,6)
    @bitmaps[6].fill_rect(2,2,22,4,Color.new(168,184,184))
    @bitmaps[6].fill_rect(0,0,22,4,Color.new(16,24,32))
    @sprites["bg"]=IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Naming/namingbg")
    case subject
      when 1   # Player
        if $PokemonGlobal
          meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
          if meta
            @sprites["shadow"]=IconSprite.new(0,0,@viewport)
            @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/namingShadow")
            @sprites["shadow"].x=33*2
            @sprites["shadow"].y=32*2
            filename=pbGetPlayerCharset(meta,1)
            @sprites["subject"]=TrainerWalkingCharSprite.new(filename,@viewport)
            charwidth=@sprites["subject"].bitmap.width
            charheight=@sprites["subject"].bitmap.height
            @sprites["subject"].x = 44*2 - charwidth/8
            @sprites["subject"].y = 38*2 - charheight/4
          end
        end
      when 2   # Pokémon
        if pokemon
          @sprites["shadow"]=IconSprite.new(0,0,@viewport)
          @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/namingShadow")
          @sprites["shadow"].x=33*2
          @sprites["shadow"].y=32*2
          @sprites["subject"]=PokemonIconSprite.new(pokemon,@viewport)
          @sprites["subject"].x=56
          @sprites["subject"].y=14
          @sprites["gender"]=BitmapSprite.new(32,32,@viewport)
          @sprites["gender"].x=430
          @sprites["gender"].y=54
          @sprites["gender"].bitmap.clear
          pbSetSystemFont(@sprites["gender"].bitmap)
          textpos=[]
          if pokemon.isMale?
            textpos.push([_INTL("♂"),0,0,false,Color.new(0,128,248),Color.new(168,184,184)])
          elsif pokemon.isFemale?
            textpos.push([_INTL("♀"),0,0,false,Color.new(248,24,24),Color.new(168,184,184)])
          end
          pbDrawTextPositions(@sprites["gender"].bitmap,textpos)
        end
      when 3   # Storage box
        @sprites["subject"]=TrainerWalkingCharSprite.new(nil,@viewport)
        @sprites["subject"].altcharset="Graphics/Pictures/Naming/namingStorage"
        @sprites["subject"].animspeed=4
        charwidth=@sprites["subject"].bitmap.width
        charheight=@sprites["subject"].bitmap.height
        @sprites["subject"].x = 44*2 - charwidth/8
        @sprites["subject"].y = 26*2 - charheight/2
      when 4   # NPC
        @sprites["shadow"]=IconSprite.new(0,0,@viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/namingShadow")
        @sprites["shadow"].x=33*2
        @sprites["shadow"].y=32*2
        @sprites["subject"]=TrainerWalkingCharSprite.new(pokemon.to_s,@viewport)
        charwidth=@sprites["subject"].bitmap.width
        charheight=@sprites["subject"].bitmap.height
        @sprites["subject"].x = 44*2 - charwidth/8
        @sprites["subject"].y = 38*2 - charheight/4
    end
    @sprites["bgoverlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbDoUpdateOverlay
    @blanks=[]
    @mode=0
    @minlength=minlength
    @maxlength=maxlength
    @maxlength.times {|i|
       @sprites["blank#{i}"]=SpriteWrapper.new(@viewport)
       @sprites["blank#{i}"].bitmap=@bitmaps[6]
       @sprites["blank#{i}"].x=160+24*i
       @blanks[i]=0
    }
    @sprites["bottomtab"]=SpriteWrapper.new(@viewport) # Current tab
    @sprites["bottomtab"].x=22
    @sprites["bottomtab"].y=162
    @sprites["bottomtab"].bitmap=@bitmaps[0+3]
    @sprites["toptab"]=SpriteWrapper.new(@viewport) # Next tab
    @sprites["toptab"].x=22-504
    @sprites["toptab"].y=162
    @sprites["toptab"].bitmap=@bitmaps[1+3]
    @sprites["controls"]=IconSprite.new(0,0,@viewport)
    @sprites["controls"].setBitmap("Graphics/Pictures/Naming/namingControls")
    @sprites["controls"].x=16
    @sprites["controls"].y=96
    @init=true
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbDoUpdateOverlay2
    @sprites["cursor"]=NameEntryCursor.new(@viewport)
    @cursorpos=0
    @refreshOverlay=true
    @sprites["cursor"].setCursorPos(@cursorpos)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdateOverlay
    @refreshOverlay=true
  end

  def pbDoUpdateOverlay2
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    modeIcon=[["Graphics/Pictures/Naming/namingMode",48+@mode*64,120,@mode*60,0,60,44]]
    pbDrawImagePositions(overlay,modeIcon)
  end

  def pbDoUpdateOverlay
    return if !@refreshOverlay
    @refreshOverlay=false
    bgoverlay=@sprites["bgoverlay"].bitmap
    bgoverlay.clear
    pbSetSystemFont(bgoverlay)
    textPositions=[
       [@helptext,160,12,false,Color.new(16,24,32),Color.new(168,184,184)]
    ]
    chars=@helper.textChars
    x=166
    for ch in chars
      textPositions.push([ch,x,48,false,Color.new(16,24,32),Color.new(168,184,184)])
      x+=24
    end
    pbDrawTextPositions(bgoverlay,textPositions)
  end

  def pbChangeTab(newtab=@mode+1)
    @sprites["cursor"].visible=false
    @sprites["toptab"].bitmap=@bitmaps[(newtab%3)+3]
    21.times do
      @sprites["toptab"].x+=24
      @sprites["bottomtab"].y+=12
      Graphics.update
      Input.update
      pbUpdate
    end
    tempx=@sprites["toptab"].x
    @sprites["toptab"].x=@sprites["bottomtab"].x
    @sprites["bottomtab"].x=tempx
    tempy=@sprites["toptab"].y
    @sprites["toptab"].y=@sprites["bottomtab"].y
    @sprites["bottomtab"].y=tempy
    tempbitmap=@sprites["toptab"].bitmap
    @sprites["toptab"].bitmap=@sprites["bottomtab"].bitmap
    @sprites["bottomtab"].bitmap=tempbitmap
    Graphics.update
    Input.update
    pbUpdate
    @mode=(newtab)%3
    newtab=@bitmaps[((@mode+1)%3)+3]
    @sprites["cursor"].visible=true
    @sprites["toptab"].bitmap=newtab
    @sprites["toptab"].x=22-504
    @sprites["toptab"].y=162
    pbDoUpdateOverlay2
  end

  def pbUpdate
    for i in 0...3
      @bitmaps[i].update
    end
    if @init || Graphics.frame_count%5==0
      @init=false
      cursorpos=@helper.cursor
      cursorpos=@maxlength-1 if cursorpos>=@maxlength
      cursorpos=0 if cursorpos<0
      @maxlength.times {|i|
         if i==cursorpos
           @blanks[i]=1
         else
           @blanks[i]=0
         end
         @sprites["blank#{i}"].y=[78,82][@blanks[i]]
      }
    end
    pbDoUpdateOverlay
    pbUpdateSpriteHash(@sprites)
  end

  def pbColumnEmpty?(m)
    return false if m>=ROWS-1
    chset=@@Characters[@mode][0]
    return (
       chset[m]==" " &&
       chset[m+((ROWS-1))]==" " &&
       chset[m+((ROWS-1)*2)]==" " &&
       chset[m+((ROWS-1)*3)]==" "
    )
  end

  def wrapmod(x,y)
    result=x%y
    result+=y if result<0
    return result
  end

  def pbMoveCursor
    oldcursor=@cursorpos
    cursordiv=@cursorpos/ROWS
    cursormod=@cursorpos%ROWS
    cursororigin=@cursorpos-cursormod
    if Input.repeat?(Input::LEFT)
      if @cursorpos<0 # Controls
        @cursorpos-=1
        @cursorpos=OK if @cursorpos<MODE1
      else
        begin
          cursormod=wrapmod((cursormod-1),ROWS)
          @cursorpos=cursororigin+cursormod
        end while pbColumnEmpty?(cursormod)
      end
    elsif Input.repeat?(Input::RIGHT)
      if @cursorpos<0 # Controls
        @cursorpos+=1
        @cursorpos=MODE1 if @cursorpos>OK
      else
        begin
          cursormod=wrapmod((cursormod+1),ROWS)
          @cursorpos=cursororigin+cursormod
        end while pbColumnEmpty?(cursormod)
      end
    elsif Input.repeat?(Input::UP)
      if @cursorpos<0 # Controls
        case @cursorpos
          when MODE1
            @cursorpos=ROWS*(COLUMNS-1)
          when MODE2
            @cursorpos=ROWS*(COLUMNS-1)+2
          when MODE3
            @cursorpos=ROWS*(COLUMNS-1)+4
          when BACK
            @cursorpos=ROWS*(COLUMNS-1)+8
          when OK
            @cursorpos=ROWS*(COLUMNS-1)+11
        end
      elsif @cursorpos<ROWS # Top row of letters
        case @cursorpos
          when 0,1
            @cursorpos=MODE1
          when 2,3
            @cursorpos=MODE2
          when 4,5,6
            @cursorpos=MODE3
          when 7,8,9,10
            @cursorpos=BACK
          when 11,12
            @cursorpos=OK
        end
      else
        cursordiv=wrapmod((cursordiv-1),COLUMNS)
        @cursorpos=(cursordiv*ROWS)+cursormod
      end
    elsif Input.repeat?(Input::DOWN)
      if @cursorpos<0 # Controls
        case @cursorpos
          when MODE1
            @cursorpos=0
          when MODE2
            @cursorpos=2
          when MODE3
            @cursorpos=4
          when BACK
            @cursorpos=8
          when OK
            @cursorpos=11
        end
      elsif @cursorpos>=ROWS*(COLUMNS-1) # Bottom row of letters
        case @cursorpos
          when ROWS*(COLUMNS-1),ROWS*(COLUMNS-1)+1
            @cursorpos=MODE1
          when ROWS*(COLUMNS-1)+2,ROWS*(COLUMNS-1)+3
            @cursorpos=MODE2
          when ROWS*(COLUMNS-1)+4,ROWS*(COLUMNS-1)+5,ROWS*(COLUMNS-1)+6
            @cursorpos=MODE3
          when ROWS*(COLUMNS-1)+7,ROWS*(COLUMNS-1)+8,ROWS*(COLUMNS-1)+9,ROWS*(COLUMNS-1)+10
            @cursorpos=BACK
          when ROWS*(COLUMNS-1)+11,ROWS*(COLUMNS-1)+12
            @cursorpos=OK
        end
      else
        cursordiv=wrapmod((cursordiv+1),COLUMNS)
        @cursorpos=(cursordiv*ROWS)+cursormod
      end
    end
    if @cursorpos!=oldcursor # Cursor position changed
      @sprites["cursor"].setCursorPos(@cursorpos)
      pbPlayCursorSE()
      return true
    else
      return false
    end
  end

  def pbEntry
    ret=""
    loop do
      Graphics.update
      Input.update
      pbUpdate
      next if pbMoveCursor
      if Input.trigger?(B)
        @helper.delete
        pbPlayCancelSE()
        pbUpdateOverlay
      elsif Input.trigger?(C)
        if @cursorpos==BACK # Backspace
          @helper.delete
          pbPlayCancelSE()
          pbUpdateOverlay
        elsif @cursorpos==OK # Done
          pbPlayDecisionSE()
          if @helper.length>=@minlength
            ret=@helper.text
            break
          end
        elsif @cursorpos==MODE1
          pbChangeTab(0) if @mode!=0
        elsif @cursorpos==MODE2
          pbChangeTab(1) if @mode!=1
        elsif @cursorpos==MODE3
          pbChangeTab(2) if @mode!=2
        else
          cursormod=@cursorpos%ROWS
          cursordiv=@cursorpos/ROWS
          charpos=cursordiv*(ROWS)+cursormod
          chset=@@Characters[@mode][0]
          if @helper.length>=@maxlength
            @helper.delete
          end
          @helper.insert(chset[charpos])
          pbPlayCursorSE()
          if @helper.length>=@maxlength
            @cursorpos=OK
            @sprites["cursor"].setCursorPos(@cursorpos)
          end
          pbUpdateOverlay
        end
      elsif Input.trigger?(Input::A)
        @cursorpos=OK
        @sprites["cursor"].setCursorPos(@cursorpos)
      elsif Input.trigger?(Input::F5)
        pbChangeTab
      end
    end
    Input.update
    return ret
 end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    for bitmap in @bitmaps
      bitmap.dispose if bitmap
    end
    @bitmaps.clear
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonEntry
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(helptext,minlength,maxlength,initialText,mode=-1,pokemon=nil)
    @scene.pbStartScene(helptext,minlength,maxlength,initialText,mode,pokemon)
    ret=@scene.pbEntry
    @scene.pbEndScene
    return ret
  end
end



def pbEnterText(helptext,minlength,maxlength,initialText="",mode=0,pokemon=nil)
  ret=""
  if USEKEYBOARDTEXTENTRY
    pbFadeOutIn(99999){
       sscene=PokemonEntryScene.new
       sscreen=PokemonEntry.new(sscene)
       ret=sscreen.pbStartScreen(helptext,minlength,maxlength,initialText,mode,pokemon)
    }
  else
    pbFadeOutIn(99999){
       sscene=PokemonEntryScene2.new
       sscreen=PokemonEntry.new(sscene)
       ret=sscreen.pbStartScreen(helptext,minlength,maxlength,initialText,mode,pokemon)
    }
  end
  return ret
end

def pbEnterPlayerName(helptext,minlength,maxlength,initialText="")
  return pbEnterText(helptext,minlength,maxlength,initialText,1)
end

def pbEnterPokemonName(helptext,minlength,maxlength,initialText="",pokemon=nil)
  return pbEnterText(helptext,minlength,maxlength,initialText,2,pokemon)
end

def pbEnterBoxName(helptext,minlength,maxlength,initialText="")
  return pbEnterText(helptext,minlength,maxlength,initialText,3)
end

def pbEnterNPCName(helptext,minlength,maxlength,initialText="",id=0)
  return pbEnterText(helptext,minlength,maxlength,initialText,4,id)
end



class Interpreter
  def command_303
    if $Trainer
       $Trainer.name=pbEnterPlayerName(_INTL("Your name?"),1,
          @parameters[1],$Trainer.name)
      return true
    end
    if $game_actors && $data_actors && $data_actors[@parameters[0]] != nil
      # Set battle abort flag
      $game_temp.battle_abort = true
      ret=""
      pbFadeOutIn(99999){
         sscene=PokemonEntryScene.new
         sscreen=PokemonEntry.new(sscene)
         $game_actors[@parameters[0]].name=sscreen.pbStartScreen(
            _INTL("Enter {1}'s name.",$game_actors[@parameters[0]].name),
            1,@parameters[1],$game_actors[@parameters[0]].name)
      }
    end
    return true
  end
end



class Game_Interpreter
  def command_303
    if $Trainer
       $Trainer.name=pbEnterPlayerName(_INTL("Your name?"),1,
          @params[1],$Trainer.name)
      return true
    end
    if $game_actors && $data_actors && $data_actors[@params[0]] != nil
      # Set battle abort flag
      ret=""
      pbFadeOutIn(99999){
         sscene=PokemonEntryScene.new
         sscreen=PokemonEntry.new(sscene)
         $game_actors[@params[0]].name=sscreen.pbStartScreen(
            _INTL("Enter {1}'s name.",$game_actors[@params[0]].name),
            1,@params[1],$game_actors[@params[0]].name)
      }
    end
    return true
  end
end