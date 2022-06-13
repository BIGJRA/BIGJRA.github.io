#===============================================================================
# Class that creates the scrolling list of quest names
#===============================================================================
class Window_Quest < Window_DrawableCommand

  def initialize(x,y,width,height,viewport)
    @quests = []
    super(x,y,width,height,viewport)
    self.windowskin = nil
    @selarrow = AnimatedBitmap.new("Graphics/Pictures/selarrow")
    RPG::Cache.retain("Graphics/Pictures/selarrow")
  end
  
  def quests=(value)
    @quests = value
    refresh
  end
  
  def itemCount
    return @quests.length
  end
  
  def drawItem(index,_count,rect)
    return if index>=self.top_row+self.page_item_max
    rect = Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
    name = $quest_data.getName(@quests[index].id)
    name = "<b>" + "#{name}" + "</b>" if @quests[index].story
    base = self.baseColor
    shadow = self.shadowColor
    col = @quests[index].color
    drawFormattedTextEx(self.contents,rect.x,rect.y+4, 436,"<c2=#{col}>#{name}</c2>",base,shadow)
    pbDrawImagePositions(self.contents,[[sprintf("Graphics/Pictures/QuestUI/new"),rect.width-16,rect.y+2]]) if @quests[index].new
  end

  def refresh
    @item_max = itemCount
    dwidth  = self.width-self.borderX
    dheight = self.height-self.borderY
    self.contents = pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...@item_max
      next if i<self.top_item || i>self.top_item+self.page_item_max
      drawItem(i,@item_max,itemRect(i))
    end
    drawCursor(self.index,itemRect(self.index)) if itemCount >0
  end
  
  def update
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end

#===============================================================================
# Class that controls the UI
#===============================================================================
class QuestList_Scene
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @base = Color.new(80,80,88)
    @shadow = Color.new(160,160,168)
    addBackgroundPlane(@sprites,"bg","QuestUI/bg_1",@viewport)
    @sprites["base"] = IconSprite.new(0,0,@viewport)
    @sprites["base"].setBitmap("Graphics/Pictures/QuestUI/bg_2")
    @sprites["page_icon1"] = IconSprite.new(0,4,@viewport)
    if SHOW_FAILED_QUESTS
      @sprites["page_icon1"].setBitmap("Graphics/Pictures/QuestUI/page_icon1a")
    else
      @sprites["page_icon1"].setBitmap("Graphics/Pictures/QuestUI/page_icon1b")
    end
    @sprites["page_icon1"].x = Graphics.width - @sprites["page_icon1"].bitmap.width - 10
    @sprites["page_icon2"] = IconSprite.new(0,4,@viewport)
    @sprites["page_icon2"].setBitmap("Graphics/Pictures/QuestUI/page_icon2")
    @sprites["page_icon2"].x = Graphics.width - @sprites["page_icon2"].bitmap.width - 10
    @sprites["page_icon2"].opacity = 0
    @sprites["pageIcon"] = IconSprite.new(@sprites["page_icon1"].x,4,@viewport)
    @sprites["pageIcon"].setBitmap("Graphics/Pictures/QuestUI/pageIcon")
    @quests = [
      $PokemonGlobal.quests.active_quests,
      $PokemonGlobal.quests.completed_quests
    ]
    @quests_text = ["Active", "Completed"]
    if SHOW_FAILED_QUESTS
      @quests.push($PokemonGlobal.quests.failed_quests)
      @quests_text.push("Failed")
    end
    @current_quest = 0
    @sprites["itemlist"] = Window_Quest.new(22,28,Graphics.width-22,Graphics.height-80,@viewport)
    @sprites["itemlist"].index = 0
    @sprites["itemlist"].baseColor = @base
    @sprites["itemlist"].shadowColor = @shadow
    @sprites["itemlist"].quests = @quests[@current_quest]
    @sprites["overlay1"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay1"].bitmap)
    @sprites["overlay2"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay2"].opacity = 0
    pbSetSystemFont(@sprites["overlay2"].bitmap)
    @sprites["overlay3"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay3"].opacity = 0
    pbSetSystemFont(@sprites["overlay3"].bitmap)
    @sprites["overlay_control"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay_control"].bitmap)
    pbDrawTextPositions(@sprites["overlay1"].bitmap,[
      [_INTL("{1} tasks", @quests_text[@current_quest]),6,-2,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    drawFormattedTextEx(@sprites["overlay_control"].bitmap,38,311,
      436,"<c2=#{colorQuest("red")}>ARROWS:</c2> <c2=7FDE39CE>Navigate</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay_control"].bitmap,38,343,
      436,"<c2=#{colorQuest("red")}>A/S:</c2> <c2=7FDE39CE>Jump Down/Up</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay_control"].bitmap,326,311,
      436,"<c2=#{colorQuest("red")}><c2=7FDE39CE>New Activity:</c2>",@base,@shadow)
    pbDrawImagePositions(@sprites["overlay_control"].bitmap,[ [sprintf("Graphics/Pictures/QuestUI/new"),464,314] ])
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    loop do
      selected = @sprites["itemlist"].index
      @sprites["itemlist"].active = true
      dorefresh = false
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::C)
        if @quests[@current_quest].length==0
          pbPlayBuzzerSE
        else
          pbPlayDecisionSE
          fadeContent
          @sprites["itemlist"].active = false
          pbQuest(@quests[@current_quest][selected])
          showContent
        end
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        @current_quest +=1; @current_quest = 0 if @current_quest > @quests.length-1
        dorefresh = true
      elsif Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        @current_quest -=1; @current_quest = @quests.length-1 if @current_quest < 0
        dorefresh = true
      end
      swapQuestType if dorefresh
    end
  end

  def swapQuestType
    @sprites["overlay1"].bitmap.clear
    @sprites["itemlist"].index = 0 # Resets cursor position
    @sprites["itemlist"].quests = @quests[@current_quest]
    @sprites["pageIcon"].x = @sprites["page_icon1"].x + 32*@current_quest
    pbDrawTextPositions(@sprites["overlay1"].bitmap,[
      [_INTL("{1} tasks", @quests_text[@current_quest]),6,-2,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
  end
  
  def fadeContent
    15.times do
      Graphics.update
      @sprites["itemlist"].contents_opacity -= 17
      @sprites["overlay1"].opacity -= 17; @sprites["overlay_control"].opacity -= 17
      @sprites["page_icon1"].opacity -= 17; @sprites["pageIcon"].opacity -= 17
    end
  end
  
  def showContent
    15.times do
      Graphics.update
      @sprites["itemlist"].contents_opacity += 17
      @sprites["overlay1"].opacity += 17; @sprites["overlay_control"].opacity += 17
      @sprites["page_icon1"].opacity += 17; @sprites["pageIcon"].opacity += 17
    end
  end
  
  def pbQuest(quest)
    quest.new = false
    drawQuestDesc(quest)
    15.times do
      Graphics.update
      @sprites["overlay2"].opacity += 17; @sprites["overlay3"].opacity += 17; @sprites["page_icon2"].opacity += 17
    end
    page = 1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      showOtherInfo = false
      if Input.trigger?(Input::RIGHT) && page==1
        pbPlayCursorSE
        page += 1
        @sprites["page_icon2"].mirror = true
        drawOtherInfo(quest)
      elsif Input.trigger?(Input::LEFT) && page==2
        pbPlayCursorSE
        page -= 1
        @sprites["page_icon2"].mirror = false
        drawQuestDesc(quest)
      elsif Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      end
    end
    15.times do
      Graphics.update
      @sprites["overlay2"].opacity -= 17; @sprites["overlay3"].opacity -= 17; @sprites["page_icon2"].opacity -= 17
    end
    @sprites["page_icon2"].mirror = false
    @sprites["itemlist"].refresh
  end
  
  def drawQuestDesc(quest)
    @sprites["overlay2"].bitmap.clear; @sprites["overlay3"].bitmap.clear
    # Quest name
    questName = $quest_data.getName(quest.id)
    pbDrawTextPositions(@sprites["overlay2"].bitmap,[
      ["#{questName}",6,-2,0,Color.new(248,248,248),Color.new(0,0,0),true]
    ])
    # Quest description
    questDesc = "<c2=#{colorQuest("blue")}>Overview:</c2> <c2=7FDE39CE>#{$quest_data.getQuestDescription(quest.id)}</c2>"
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,48,
      436,questDesc,@base,@shadow)
    # Stage description
    questStageDesc = $quest_data.getStageDescription(quest.id,quest.stage)
    # Stage location
    questStageLocation = $quest_data.getStageLocation(quest.id,quest.stage)
    # If 'nil' or missing, set to '???'
    if questStageLocation=="nil" || questStageLocation==""
      questStageLocation = "???"
    end
    drawFormattedTextEx(@sprites["overlay3"].bitmap,36,312,
      436,"<c2=#{colorQuest("orange")}>Task:</c2> <c2=7FDE39CE>#{questStageDesc}</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,341,
      436,"<c2=#{colorQuest("purple")}>Location:</c2> <c2=7FDE39CE>#{questStageLocation}</c2>",@base,@shadow)
  end

  def drawOtherInfo(quest)
    @sprites["overlay3"].bitmap.clear
    # Guest giver
    questGiver = $quest_data.getQuestGiver(quest.id)
    # If 'nil' or missing, set to '???'
    questGiver = "???" if questGiver=="nil" || questGiver==""
    # Total number of stages for quest
    questLength = $quest_data.getMaxStagesForQuest(quest.id)
    # Map quest was originally started
    originalMap = quest.location
    # Vary text according to map name
    loc = originalMap.include?("Route") ? "on" : "in"
    # Format time
    time = quest.time.strftime("%B %d %Y %H:%M")
    if getActiveQuests.include?(quest.id)
      time_text = "start"
    elsif getCompletedQuests.include?(quest.id)
      time_text = "completion"
    else
      time_text = "failure"
    end
    # Quest reward
    questReward = $quest_data.getQuestReward(quest.id)
    if questReward=="nil" || questReward==""
      questReward = "???"
    end
    queststage = sprintf("Stage %d/%d",quest.stage,questLength)
    expiration = $quest_data.getQuestTermination(quest.id)
    expiration = "Never!" if expiration=="nil" || expiration==""

    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,44,
      436,"<c2=#{colorQuest("green")}>#{queststage}</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,84,
      436,"<c2=#{colorQuest("cyan")}>Quest received from:</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,112,
      436,"<c2=#{colorQuest("green")}>#{questGiver}</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,152,
      436,"<c2=#{colorQuest("cyan")}>Quest discovered #{loc}:</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,180,
      436,"<c2=#{colorQuest("green")}>#{originalMap}</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,220,
      436,"<c2=#{colorQuest("cyan")}>Quest expiration point:</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,248,
      436,"<c2=#{colorQuest("green")}>#{expiration}</c2>",@base,@shadow)
    drawFormattedTextEx(@sprites["overlay3"].bitmap,38,Graphics.height-74,
      436,"<c2=#{colorQuest("orange")}>Reward: </c2><c2=#{colorQuest("red")}>#{questReward}</c2>",@base,@shadow)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Class to call UI
#===============================================================================
class QuestList_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbScene
    @scene.pbEndScene
  end
end

# Utility method for calling UI
def pbViewQuests
  scene = QuestList_Scene.new
  screen = QuestList_Screen.new(scene)
  screen.pbStartScreen
end
