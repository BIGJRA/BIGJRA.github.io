################################################################################
# "Tile Puzzle" mini-games
# By Maruno
# Graphics by the__end
#-------------------------------------------------------------------------------
# Run with:      pbTilePuzzle(game,board,width,height)
# game = 1 (Ruins of Alph puzzle),
#        2 (Ruins of Alph puzzle plus tile rotations),
#        3 (Mystic Square),
#        4 (swap two adjacent tiles),
#        5 (swap two adjacent tiles plus tile rotations),
#        6 (Rubik's square),
#        7 (rotate selected tile plus adjacent tiles at once).
# board = The name/number of the graphics to be used.
# width,height = Optional, the number of tiles wide/high the puzzle is (0 for
#                the default value of 4).
################################################################################
class TilePuzzleCursor < BitmapSprite
  attr_accessor :game
  attr_accessor :position
  attr_accessor :arrows
  attr_accessor :selected
  attr_accessor :holding

  def initialize(game,position,tilewidth,tileheight,boardwidth,boardheight)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    super(Graphics.width,Graphics.height,@viewport)
    @game=game
    @position=position
    @tilewidth=tilewidth
    @tileheight=tileheight
    @boardwidth=boardwidth
    @boardheight=boardheight
    @arrows=[]
    @selected=false
    @holding=false
    @cursorbitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/Tile Puzzle/cursor"))
    update
  end

  def update
    self.bitmap.clear
    x=(Graphics.width-(@tilewidth*@boardwidth))/2
    if @position>=@boardwidth*@boardheight
      x=(x-(@tilewidth*(@boardwidth/2).ceil))/2-10
      if (@position%@boardwidth)>=(@boardwidth/2).ceil
        x=Graphics.width-x-@tilewidth*@boardwidth
      end
    end
    x+=@tilewidth*(@position%@boardwidth)
    y=(Graphics.height-(@tileheight*@boardheight))/2-32
    y+=@tileheight*((@position%(@boardwidth*@boardheight))/@boardwidth)
    self.tone=Tone.new(0,(@holding ? 64 : 0),(@holding ? 64 : 0),0)
    # Cursor
    if @game!=3
      expand=(@holding) ? 0 : 4
      for i in 0...4
        self.bitmap.blt(x+(i%2)*(@tilewidth-@cursorbitmap.width/4)+expand*(((i%2)*2)-1),
           y+(i/2)*(@tileheight-@cursorbitmap.height/2)+expand*(((i/2)*2)-1),
           @cursorbitmap.bitmap,Rect.new(
           (i%2)*@cursorbitmap.width/4,(i/2)*@cursorbitmap.height/2,
           @cursorbitmap.width/4,@cursorbitmap.height/2))
      end
    end
    # Arrows
    if @selected || @game==3
      expand=(@game==3) ? 0 : 4
      xin=[(@tilewidth-@cursorbitmap.width/4)/2,-expand,
           @tilewidth-@cursorbitmap.width/4+expand,(@tilewidth-@cursorbitmap.width/4)/2]
      yin=[@tileheight-@cursorbitmap.height/2+expand,(@tileheight-@cursorbitmap.height/2)/2,
           (@tileheight-@cursorbitmap.height/2)/2,-expand]
      for i in 0...4
        if @arrows[i]
          self.bitmap.blt(x+xin[i],y+yin[i],@cursorbitmap.bitmap,Rect.new(
             @cursorbitmap.width/2+(i%2)*(@cursorbitmap.width/4),
             (i/2)*(@cursorbitmap.height/2),
             @cursorbitmap.width/4,@cursorbitmap.height/2))
        end
      end
    end
  end
end



class TilePuzzleScene
  def initialize(game,board,width,height)
    @game=game
    @board=board
    @boardwidth=(width>0) ? width : 4
    @boardheight=(height>0) ? height : 4
  end

  def update
    xtop=(Graphics.width-(@tilewidth*@boardwidth))/2
    ytop=(Graphics.height-(@tileheight*@boardheight))/2+@tileheight/2-32
    for i in 0...@boardwidth*@boardheight
      pos=-1
      for j in 0...@tiles.length
        pos=j if @tiles[j]==i
      end
      @sprites["tile#{i}"].z=0
      @sprites["tile#{i}"].tone=Tone.new(0,0,0,0)
      if @heldtile==i
        pos=@sprites["cursor"].position
        @sprites["tile#{i}"].z=1
        @sprites["tile#{i}"].tone=Tone.new(64,0,0,0) if @tiles[pos]>=0
      end
      thisx=xtop
      if pos>=0
        if pos>=@boardwidth*@boardheight
          thisx=(xtop-(@tilewidth*(@boardwidth/2).ceil))/2-10
          if (pos%@boardwidth)>=(@boardwidth/2).ceil
            thisx=Graphics.width-thisx-@tilewidth*@boardwidth
          end
        end
        @sprites["tile#{i}"].x=thisx+@tilewidth*(pos%@boardwidth)+@tilewidth/2
        @sprites["tile#{i}"].y=ytop+@tileheight*((pos%(@boardwidth*@boardheight))/@boardwidth)
        next if @game==3
        rotatebitmaps=[@tilebitmap,@tilebitmap1,@tilebitmap2,@tilebitmap3]
        @sprites["tile#{i}"].bitmap.clear
        if rotatebitmaps[@angles[i]]
          @sprites["tile#{i}"].bitmap.blt(0,0,rotatebitmaps[@angles[i]].bitmap,
             Rect.new(@tilewidth*(i%@boardwidth),@tileheight*(i/@boardwidth),@tilewidth,@tileheight))
          @sprites["tile#{i}"].angle=0
        else
          @sprites["tile#{i}"].bitmap.blt(0,0,@tilebitmap.bitmap,
             Rect.new(@tilewidth*(i%@boardwidth),@tileheight*(i/@boardwidth),@tilewidth,@tileheight))
          @sprites["tile#{i}"].angle=@angles[i]*90
        end
      end
    end
    updateCursor
    pbUpdateSpriteHash(@sprites)
  end

  def updateCursor
    arrows=[]
    for i in 0...4
      arrows.push(pbCanMoveInDir?(@sprites["cursor"].position,(i+1)*2,@game==6))
    end
    @sprites["cursor"].arrows=arrows
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    if pbResolveBitmap("Graphics/Pictures/Tile Puzzle/bg#{@board}")
      addBackgroundPlane(@sprites,"bg","Tile Puzzle/bg#{@board}",@viewport)
    else
      addBackgroundPlane(@sprites,"bg","Tile Puzzle/bg",@viewport)
    end
    @tilebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/Tile Puzzle/tiles#{@board}"))
    @tilebitmap1=nil; @tilebitmap2=nil; @tilebitmap3=nil
    if pbResolveBitmap("Graphics/Pictures/Tile Puzzle/tiles#{@board}_1")
      @tilebitmap1=AnimatedBitmap.new("Graphics/Pictures/Tile Puzzle/tiles#{@board}_1")
    end
    if pbResolveBitmap("Graphics/Pictures/Tile Puzzle/tiles#{@board}_2")
      @tilebitmap2=AnimatedBitmap.new("Graphics/Pictures/Tile Puzzle/tiles#{@board}_2")
    end
    if pbResolveBitmap("Graphics/Pictures/Tile Puzzle/tiles#{@board}_3")
      @tilebitmap3=AnimatedBitmap.new("Graphics/Pictures/Tile Puzzle/tiles#{@board}_3")
    end
    @tilewidth=@tilebitmap.width/@boardwidth
    @tileheight=@tilebitmap.height/@boardheight
    for i in 0...@boardwidth*@boardheight
      @sprites["tile#{i}"]=BitmapSprite.new(@tilewidth,@tileheight,@viewport)
      @sprites["tile#{i}"].ox=@tilewidth/2
      @sprites["tile#{i}"].oy=@tileheight/2
      break if @game==3 && i>=@boardwidth*@boardheight-1
      @sprites["tile#{i}"].bitmap.blt(0,0,@tilebitmap.bitmap,
         Rect.new(@tilewidth*(i%@boardwidth),@tileheight*(i/@boardwidth),@tilewidth,@tileheight))
    end
    @heldtile=-1
    @angles=[]
    @tiles=pbShuffleTiles
    @sprites["cursor"]=TilePuzzleCursor.new(@game,pbDefaultCursorPosition,
       @tilewidth,@tileheight,@boardwidth,@boardheight)
    update
    pbFadeInAndShow(@sprites)
  end

  def pbShuffleTiles
    ret=[]
    for i in 0...@boardwidth*@boardheight; ret.push(i); @angles.push(0); end
    if @game==6
      @tiles=ret
      5.times do
        pbShiftLine([2,4,6,8][rand(4)],rand(@boardwidth*@boardheight),false)
      end
      return @tiles
    elsif @game==7
      @tiles=ret
      5.times do
        pbRotateTile(rand(@boardwidth*@boardheight),false)
      end
    else
      ret.shuffle!
      if @game==3  # Make sure only solvable Mystic Squares are allowed.
        num=0; blank=-1
        for i in 0...ret.length-1
          blank=i if ret[i]==@boardwidth*@boardheight-1
          for j in i...ret.length
            num+=1 if ret[j]<ret[i] && ret[i]!=@boardwidth*@boardheight-1 &&
                      ret[j]!=@boardwidth*@boardheight-1
          end
        end
        if @boardwidth%2==1
          ret=pbShuffleTiles if num%2==1
        else
          ret=pbShuffleTiles if !((num%2==0 && (@boardheight-(blank/@boardwidth))%2==1) ||
                                  (num%2==1 && (@boardheight-(blank/@boardwidth))%2==0))
        end
      end
      if @game==1 || @game==2
        ret2=[]
        for i in 0...@boardwidth*@boardheight; ret2.push(-1); end
        ret=ret2+ret
      end
      if @game==2 || @game==5
        for i in 0...@angles.length; @angles[i]=rand(4); end
      end
    end
    return ret
  end

  def pbDefaultCursorPosition
    if @game==3
      for i in 0...@boardwidth*@boardheight
        return i if @tiles[i]==@boardwidth*@boardheight-1
      end
      return 0
    else
      return 0
    end
  end

  def pbMoveCursor(pos,dir)
    if dir==2
      pos+=@boardwidth
    elsif dir==4
      if pos>=@boardwidth*@boardheight
        if pos%@boardwidth==(@boardwidth/2).ceil
          pos=((pos%(@boardwidth*@boardheight))/@boardwidth)*@boardwidth+@boardwidth-1
        else
          pos-=1
        end
      else
        if (pos%@boardwidth)==0
          pos=(((pos/@boardwidth)+@boardheight)*@boardwidth)+(@boardwidth/2).ceil-1
        else
          pos-=1
        end
      end
    elsif dir==6
      if pos>=@boardwidth*@boardheight
        if pos%@boardwidth==(@boardwidth/2).ceil-1
          pos=((pos%(@boardwidth*@boardheight))/@boardwidth)*@boardwidth
        else
          pos+=1
        end
      else
        if pos%@boardwidth>=@boardwidth-1
          pos=(((pos/@boardwidth)+@boardheight)*@boardwidth)+(@boardwidth/2).ceil
        else
          pos+=1
        end
      end
    elsif dir==8
      pos-=@boardwidth
    end
    return pos
  end

  def pbCanMoveInDir?(pos,dir,swapping)
    return true if @game==6 && swapping
    if dir==2
      return false if (pos/@boardwidth)%@boardheight>=@boardheight-1
    elsif dir==4
      if @game==1 || @game==2
        return false if pos>=@boardwidth*@boardheight && pos%@boardwidth==0
      else
        return false if pos%@boardwidth==0
      end
    elsif dir==6
      if @game==1 || @game==2
        return false if pos>=@boardwidth*@boardheight && pos%@boardwidth>=@boardwidth-1
      else
        return false if pos%@boardwidth>=@boardwidth-1
      end
    elsif dir==8
      return false if (pos/@boardwidth)%@boardheight==0
    end
    return true
  end

  def pbRotateTile(pos,anim=true)
    if @heldtile>=0
      if anim
        @sprites["cursor"].visible=false
        @sprites["tile#{@heldtile}"].z=1
        9.times do
          @sprites["tile#{@heldtile}"].angle-=10
          pbUpdateSpriteHash(@sprites)
          Graphics.update
          Input.update
        end
        @sprites["tile#{@heldtile}"].z=0
        @sprites["cursor"].visible=true if !pbCheckWin
      end
      @angles[@heldtile]-=1
      @angles[@heldtile]+=4 if @angles[@heldtile]<0
    else
      return if @tiles[pos]<0
      group=pbGetNearTiles(pos)
      if anim
        @sprites["cursor"].visible=false
        for i in group; @sprites["tile#{@tiles[i]}"].z=1; end
        9.times do
          for i in group
            @sprites["tile#{@tiles[i]}"].angle-=10
          end
          pbUpdateSpriteHash(@sprites)
          Graphics.update
          Input.update
        end
        for i in group; @sprites["tile#{@tiles[i]}"].z=0; end
        @sprites["cursor"].visible=true if !pbCheckWin
      end
      for i in group
        tile=@tiles[i]
        @angles[tile]-=1
        @angles[tile]+=4 if @angles[tile]<0
      end
    end
  end

  def pbGetNearTiles(pos)
    ret=[pos]
    if @game==7
      for i in [2,4,6,8]
        ret.push(pbMoveCursor(pos,i)) if pbCanMoveInDir?(pos,i,true)
      end
    end
    return ret
  end

  def pbSwapTiles(dir)
    cursor=@sprites["cursor"].position
    return pbShiftLine(dir,cursor) if @game==6
    movetile=pbMoveCursor(cursor,dir)
    @sprites["cursor"].visible=false
    @sprites["tile#{@tiles[cursor]}"].z=1
    if dir==2 || dir==8
      dist=(dir/4).floor-1
      (@tileheight/4).times do
        @sprites["tile#{@tiles[movetile]}"].y+=(dist*4)
        @sprites["tile#{@tiles[cursor]}"].y-=(dist*4)
        pbUpdateSpriteHash(@sprites)
        Graphics.update
        Input.update
      end
    else
      dist=dir-5
      (@tilewidth/4).times do
        @sprites["tile#{@tiles[movetile]}"].x-=(dist*4)
        @sprites["tile#{@tiles[cursor]}"].x+=(dist*4)
        pbUpdateSpriteHash(@sprites)
        Graphics.update
        Input.update
      end
    end
    @tiles[cursor], @tiles[movetile]=@tiles[movetile], @tiles[cursor]
    @sprites["tile#{@tiles[cursor]}"].z=0
    @sprites["cursor"].position=movetile
    @sprites["cursor"].selected=false
    @sprites["cursor"].visible=true if !pbCheckWin
    return true
  end

  def pbShiftLine(dir,cursor,anim=true)
    # Get tiles involved
    tiles=[]; dist=0
    if dir==2 || dir==8
      dist=(dir/4).floor-1
      while (dist>0 && cursor<(@boardwidth-1)*@boardheight) ||
            (dist<0 && cursor>=@boardwidth)
        cursor+=(@boardwidth*dist)
      end
      for i in 0...@boardheight
        tiles.push(cursor-i*dist*@boardwidth)
      end
    else
      dist=dir-5
      while (dist>0 && cursor%@boardwidth>0) ||
            (dist<0 && cursor%@boardwidth<@boardwidth-1)
        cursor-=dist
      end
      for i in 0...@boardwidth
        tiles.push(cursor+i*dist)
      end
    end
    # Shift tiles
    if anim
      @sprites["cursor"].visible=false
      16.times do
        @sprites["tile#{@tiles[tiles[tiles.length-1]]}"].opacity-=16
        Graphics.update
        Input.update
      end
      if dir==2 || dir==8
        (@tileheight/4).times do
          for i in tiles
            @sprites["tile#{@tiles[i]}"].y-=(dist*4)
          end
          pbUpdateSpriteHash(@sprites)
          Graphics.update
          Input.update
        end
      else
        (@tilewidth/4).times do
          for i in tiles
            @sprites["tile#{@tiles[i]}"].x+=(dist*4)
          end
          pbUpdateSpriteHash(@sprites)
          Graphics.update
          Input.update
        end
      end
    end
    temp=[]
    for i in tiles; temp.push(@tiles[i]); end
    for i in 0...temp.length
      @tiles[tiles[(i+1)%(temp.length)]]=temp[i]
    end
    if anim
      update
      16.times do
        @sprites["tile#{@tiles[tiles[0]]}"].opacity+=16
        Graphics.update
        Input.update
      end
      @sprites["cursor"].selected=false
      @sprites["cursor"].visible=true if !pbCheckWin
    end
    return true
  end

  def pbGrabTile(pos)
    @heldtile, @tiles[pos] = @tiles[pos], @heldtile
    @sprites["cursor"].holding=(@heldtile>=0)
    @sprites["cursor"].visible=false if pbCheckWin
  end

  def pbCheckWin
    for i in 0...@boardwidth*@boardheight
      return false if @tiles[i]!=i
      return false if @angles[i]!=0
    end
    return true
  end

  def pbMain
    loop do
      update
      Graphics.update
      Input.update
      # Check end conditions
      if pbCheckWin
        @sprites["cursor"].visible=false
        if @game==3
          extratile=@sprites["tile#{@boardwidth*@boardheight-1}"]
          extratile.bitmap.clear
          extratile.bitmap.blt(0,0,@tilebitmap.bitmap,
             Rect.new(@tilewidth*(@boardwidth-1),@tileheight*(@boardheight-1),
             @tilewidth,@tileheight))
          extratile.opacity=0
          32.times do
            extratile.opacity+=8
            Graphics.update
            Input.update
          end
        else
          pbWait(5)
        end
        loop do
          Graphics.update
          Input.update
          break if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        end
        return true
      end
      # Input
      @sprites["cursor"].selected=(Input.press?(Input::C) && @game>=3 && @game<=6)
      dir=0
      dir=2 if Input.trigger?(Input::DOWN) || Input.repeat?(Input::DOWN)
      dir=4 if Input.trigger?(Input::LEFT) || Input.repeat?(Input::LEFT)
      dir=6 if Input.trigger?(Input::RIGHT) || Input.repeat?(Input::RIGHT)
      dir=8 if Input.trigger?(Input::UP) || Input.repeat?(Input::UP)
      if dir>0
        if @game==3 || (@game!=3 && @sprites["cursor"].selected)
          if pbCanMoveInDir?(@sprites["cursor"].position,dir,true)
            pbSEPlay("Choose")
            pbSwapTiles(dir)
          end
        else
          if pbCanMoveInDir?(@sprites["cursor"].position,dir,false)
            pbSEPlay("Choose")
            @sprites["cursor"].position=pbMoveCursor(@sprites["cursor"].position,dir)
          end
        end
      elsif (@game==1 || @game==2) && Input.trigger?(Input::C)
        pbGrabTile(@sprites["cursor"].position)
      elsif (@game==2 && Input.trigger?(Input::Y)) ||
            (@game==5 && Input.trigger?(Input::Y)) ||
            (@game==7 && Input.trigger?(Input::C))
        pbRotateTile(@sprites["cursor"].position)
      elsif Input.trigger?(Input::B)
        if Kernel.pbConfirmMessage("Are you sure you want to quit?")
          return false
        end
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class TilePuzzle
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    ret=@scene.pbMain
    @scene.pbEndScene
    return ret
  end
end



def pbTilePuzzle(game,board,width=0,height=0)
  ret=false
  scene=TilePuzzleScene.new(game,board,width,height)
  screen=TilePuzzle.new(scene)
  pbFadeOutIn(99999) {
     ret=screen.pbStartScreen
  }
  return ret
end