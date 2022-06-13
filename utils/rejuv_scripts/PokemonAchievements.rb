class AchievementButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,name="",level="",index=0,viewport=nil)
    super(viewport)
    @index=index
    @name=name
    @level=level
    @selected=false
    @button=AnimatedBitmap.new("Graphics/Pictures/Achievements/achievementsButton")
    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    refresh
    update
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@button.bitmap,Rect.new(0,0,@button.width,@button.height))
    pbSetSystemFont(self.bitmap)
    textpos=[          # Name is written on both unselected and selected buttons
       [@name,14,10,0,Color.new(248,248,248),Color.new(40,40,40)],
       [@name,14,62,0,Color.new(248,248,248),Color.new(40,40,40)],
       [@level,482,10,1,Color.new(248,248,248),Color.new(40,40,40)],
       [@level,482,62,1,Color.new(248,248,248),Color.new(40,40,40)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
  end

  def update
    if self.selected
      self.src_rect.set(0,self.bitmap.height/2,self.bitmap.width,self.bitmap.height/2)
    else
      self.src_rect.set(0,0,self.bitmap.width,self.bitmap.height/2)
    end
    super
  end
end

class AchievementText < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,description="",progress="",viewport=nil)
    super(viewport)
    @description=description
    @progress=progress
    @button=AnimatedBitmap.new("Graphics/Pictures/Achievements/achievementsText")
    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    refresh
    update
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@button.bitmap,Rect.new(0,0,@button.width,@button.height))
    pbSetSystemFont(self.bitmap)
    textsize=self.bitmap.text_size(@description)
    description0=""
    description1=""
    firstLineFull=false
    @description.split(/\s+/).each do |word|
      if firstLineFull==false
        if self.bitmap.text_size(description0).width + self.bitmap.text_size(word).width >= 482
          firstLineFull=true
          if description1.empty?
            description1=word
          else
            description1 << " " << word
          end
        elsif description0.empty?
          description0=word
        else
          description0 << " " << word
        end
      else
        if description1.empty?
          description1=word
        else
          description1 << " " << word
        end
      end
    end
    textpos=[          # Name is written on both unselected and selected buttons
       [description0,14,10,0,Color.new(248,248,248),Color.new(40,40,40)],
       [description1,14,10+textsize.height,0,Color.new(248,248,248),Color.new(40,40,40)],
       [@progress,482,10+textsize.height,1,Color.new(248,248,248),Color.new(40,40,40)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
  end

  def change(description,progress)
    @description=description
    @progress=progress
    refresh
    self.src_rect.set(0,0,self.bitmap.width,self.bitmap.height)
  end
end

class PokemonAchievementsScene
  def initialize(menu_index = 0)
    @menu_index = menu_index
    @offset=0
    @buttons=[]
    @_buttons=[]
    @achievements=[]
    @achievementInternalNames=[]
  end
  #-----------------------------------------------------------------------------
  # start the scene
  #-----------------------------------------------------------------------------
  def pbStartScene
    buttonList={}
    al=Achievements.list.keys
    al=al.sort{|a,b|Achievements.list[a]["id"]<=>Achievements.list[b]["id"]}
    al.each{|k|
      @buttons.push(_INTL(Achievements.list[k]["name"]))
      @_buttons.push([k,_INTL(Achievements.list[k]["goals"])])
      @achievements.push(Achievements.list[k])
      @achievementInternalNames.push(k)
      buttonList[k.to_s]=-1
    }
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @button=AnimatedBitmap.new("Graphics/Pictures/Achievements/achievementsButton")
    @sprites={}
    addBackgroundPlane(@sprites,"background","Achievements/achievementsbg",@viewport)
    @sprites["command_window"] = Window_CommandPokemon.new(@buttons,160)
    @sprites["command_window"].visible = false
    @sprites["command_window"].index = @menu_index
    @sprites["achievementText"]=AchievementText.new(8,296,"Error.",_INTL("{1}/{2}","-1","-1"), @viewport)
    @sprites["achievementText"].change(_INTL(@achievements[0]["description"]),_INTL("{1}/{2}",$achievements[@_buttons[0][0]]["progress"],Achievements.getCurrentGoal(@achievementInternalNames[0])))
    @sprites["achievementText"].visible = true
    for i in 0...@buttons.length
      x=8
      y=46 + (i*50)
      @sprites["button#{i}"] = AchievementButton.new(x,y,@buttons[i],_INTL("{1}/{2}",$achievements[@_buttons[i][0]]["level"],@_buttons[i][1].length),i,@viewport)
      @sprites["button#{i}"].selected = (i==@sprites["command_window"].index)
      @sprites["button#{i}"].update
      @sprites["button#{i}"].visible = false
    end
    for i in @offset...@offset+5
      @sprites["button#{i}"].visible = true
    end
    pbFadeInAndShow(@sprites) { update }
  end
  #-----------------------------------------------------------------------------
  # play the scene
  #-----------------------------------------------------------------------------
  def pbAchievements
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::B)
        break
      end
    end
  end
  #-----------------------------------------------------------------------------
  # end the scene
  #-----------------------------------------------------------------------------
  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  #-----------------------------------------------------------------------------
  # update the scene
  #-----------------------------------------------------------------------------
  def update
    if @sprites["command_window"].nil?
      pbUpdateSpriteHash(@sprites)
      return true
    end
    for i in 0...@sprites["command_window"].commands.length
      sprite=@sprites["button#{i}"]
      sprite.selected=(i==@sprites["command_window"].index) ? true : false
      if sprite.selected
        desc = @achievements[i]["description"]
        prog = $achievements[@_buttons[i][0]]["progress"]
        goal = Achievements.getCurrentGoal(@achievementInternalNames[i])
# hidden achievements
#        if i==0 && !$game_switches[1499]
#          desc = "Cannot use yet"
#          prog = "XXXX"
#          goal = "XXXX"
#        end
        @sprites["achievementText"].change(_INTL(desc),_INTL("{1}/{2}",prog,goal))
      end
    end
    if @sprites["command_window"].index==0
      @offset=0
    end
    if @sprites["command_window"].index==@buttons.length-1
      @offset=@buttons.length-6
    end
    if @sprites["command_window"].index>@offset+4
      @offset+=1
    end
    if @sprites["command_window"].index<@offset
      @offset-=1
    end
    for i in 0...@buttons.length
      @sprites["button#{i}"].visible = false
      @sprites["button#{i}"].y=46 + ((i-@offset)*50)
    end
    for i in @offset...@offset+5
      @sprites["button#{i}"].visible = true
    end
    pbUpdateSpriteHash(@sprites)
  end
end

class PokemonAchievements
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbAchievements
    @scene.pbEndScene
  end
end