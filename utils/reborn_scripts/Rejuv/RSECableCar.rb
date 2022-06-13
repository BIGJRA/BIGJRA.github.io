#==============================================================================#
#                             RSE Cable Car Scene                              #
#                                  by Zaffre                                   #
#==============================================================================#
#                                Instructions                                  #
#                                                                              #
# To call the scene, just put                                                  #
# CableCarScene.new(going_up, map_id, map_x, map_y, direction, weather)        #
# in an event.                                                                 #
#                                                                              #
# The arguments are:                                                           #
# going_up - If true, the car will go up. If false, the car will go down.      #
# map_id - The ID of the map where the player will appear after the scene.     #
# map_x - The X coordinate on the map where the player will appear.            #
# map_y - The Y coordinate on the map where the player will appear.            #
# direction - The direction you want the player to be facing when the scene    #
# finishes. If this field is left empty, it will always assume 2 (down). The   #
# input received should be one of the following:                               #
# 2 - down                                                                     #
# 4 - left                                                                     #
# 6 - right                                                                    #
# 8 - up                                                                       #
# weather - If true, volcanic ash will appear, just like in RSE. If false, no  #
# volcanic ash will appear. If this field  is left empty, it will always       #
# assume true.                                                                 #
#                                                                              #
# An example: CableCarScene.new(false, 294, 22, 38, 8, true)                   #
# In this example, the car is going down, and the player will then appear in   #
# the map with ID 294, in the coordinates 22(X) 38(Y) and facing down. Weather #
# is set to true, so volcanic ash will appear during the ride.                 #
#==============================================================================#
#                               Configurations                                 #
#                                                                              #
# In this case, the random hiker/NPC has a 1/64 chance of appearing.           #
# Change it to however much you want the chance to be. (1 = always appears)    #
HIKER_PERCENTAGE = 64
#                                                                              #
# The file names of the NPCs that can appear. You can add as many as you want, #
# but they must be located in the folder Graphics/Pictures/CableCar, and have  #
# the same format as the example graphics.                                     #
HIKER_FILE_NAMES = [                                                           
  "hiker",                                                                     
  "hiker1"
]                                                                              
#                                                                              #
# Change this to what you want the background music to be when playing the     #
# scene. Must be located in the folder Audio/BGM.                              #
CABLE_CAR_BGM = "CableCar"                                                     
#                                                                              #
# If you want to change some of the graphics (background, male and female      #
# player, etc) you can do so in the folder Graphics/Pictures/CableCar but I    #
# advise to not change the size of the graphics, as that would require some    #
# repositioning. If you have any questions, message me on Discord: Zaffre#7901 #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

if defined?(PluginManager)
  PluginManager.register({
    :name => "RSE Cable Car Scene",
    :version => "1.0",
    :credits => "PurpleZaffre",
    :link => "https://reliccastle.com/resources/"
  })
end

class CableCarScene
  def initialize(going_up, map_id, map_x, map_y, direction=2, weather=true)
    pbBGMFade(10)
    @sprites = {}
    @sprites["Black"] = Sprite.new
    @sprites["Black"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/black")
    @sprites["Black"].z = 99999
    @sprites["Black"].opacity = 0
    for i in 0..14
      @sprites["Black"].opacity += 17
      pbWait(1)
    end
    hiker = false
    if(rand(HIKER_PERCENTAGE)==0)
      hiker = true
      hiker_name = HIKER_FILE_NAMES[rand(HIKER_FILE_NAMES.size)]
    end
    pbBGMPlay(CABLE_CAR_BGM)
    pbWait(10)
    @sprites["BG"] = Sprite.new
    @sprites["BG"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/bg")
    @sprites["BG"].z = 90000
    if going_up
      @sprites["Trees"] = Sprite.new
      @sprites["Trees"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/trees")
      @sprites["Trees"].x = -1024
      @sprites["Trees"].y = 190
      @sprites["Trees"].z = 92000
      if hiker
        hiker2="hiker1"
        @sprites["Hiker"] = Sprite.new
        @sprites["Hiker"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/"+hiker_name)
        @sprites["Hiker"].x = 200
        @sprites["Hiker"].y = 286
        @sprites["Hiker"].z = 93000
      end
      @sprites["Ground"] = Sprite.new
      @sprites["Ground"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/ground")
      @sprites["Ground"].x = -1792
      @sprites["Ground"].y = -160
      @sprites["Ground"].z = 94000
      @sprites["CC"] = Sprite.new
      @sprites["CC"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/cable_car")
      @sprites["CC"].x = 406
      @sprites["CC"].y = 98
      @sprites["CC"].z = 96000
      @sprites["Player"] = Sprite.new
      if !$Trainer.isFemale?
        @sprites["Player"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/player_male")
      else
        @sprites["Player"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/player_female")
      end
      @sprites["Player"].x = 438
      @sprites["Player"].y = 158
      @sprites["Player"].z = 96100
      @sprites["Door"] = Sprite.new
      @sprites["Door"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/door")
      @sprites["Door"].x = 454
      @sprites["Door"].y = 210
      @sprites["Door"].z = 96200
      @sprites["Poles"] = Sprite.new
      @sprites["Poles"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/pole")
      @sprites["Poles"].x = -1024
      @sprites["Poles"].y = -638
      @sprites["Poles"].z = 98000
      if weather
        @sprites["Ash"] = Sprite.new
        @sprites["Ash"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/ash")
        @sprites["Ash"].opacity = 0
        @sprites["Ash"].x = -1650
        @sprites["Ash"].y = -650
        @sprites["Ash"].z = 99000
      end
      for i in 0..50
        if i < 4
          @sprites["Black"].opacity -= 50
        elsif i == 4
          @sprites["Black"].opacity -= 55
        elsif i >= 46 && i < 50
          @sprites["Black"].opacity += 50
        elsif i == 50
          @sprites["Black"].opacity += 55
        end
        if i >= 26 && i <=30
          @sprites["Ash"].opacity += 50 if weather
        end
        @sprites["Ash"].y += 3 if weather
        @sprites["Ash"].x += 8 if weather
        @sprites["Ground"].y += 1
        @sprites["Ground"].x += 4
        @sprites["Hiker"].x += 2 if hiker
        @sprites["CC"].x -= 2
        @sprites["Door"].x -= 2
        @sprites["Player"].x -= 2
        @sprites["Poles"].x += 6
        @sprites["Poles"].y += 3
        pbWait(2)
        @sprites["Ash"].y += 3 if weather
        @sprites["Ash"].x += 8 if weather
        @sprites["Ground"].y += 1
        @sprites["Ground"].x += 4
        @sprites["Hiker"].y += 1 if hiker
        @sprites["Hiker"].x += 4 if hiker
        @sprites["Trees"].y += 1
        @sprites["Trees"].x += 1
        @sprites["Poles"].x += 6
        @sprites["Poles"].y += 3
        pbWait(2)
        @sprites["Ash"].y += 3 if weather
        @sprites["Ash"].x += 8 if weather
        @sprites["Ground"].y += 1
        @sprites["Ground"].x += 4
        @sprites["Hiker"].y += 1 if hiker
        @sprites["Hiker"].x += 4 if hiker
        @sprites["Poles"].x += 6
        @sprites["Poles"].y += 3
        pbWait(2)
        @sprites["Ash"].y += 3 if weather
        @sprites["Ash"].x += 8 if weather
        @sprites["Ground"].y += 1
        @sprites["Ground"].x += 4
        @sprites["Hiker"].y += 1 if hiker
        @sprites["Hiker"].x += 4 if hiker
        @sprites["Trees"].y += 1
        @sprites["Trees"].x += 1
        @sprites["CC"].y -= 2
        @sprites["CC"].x -= 2
        @sprites["Door"].y -= 2
        @sprites["Door"].x -= 2
        @sprites["Player"].y -= 2
        @sprites["Player"].x -= 2
        if i % 2 == 0
          @sprites["Player"].y -= 2
          @sprites["Hiker"].y -= 2 if hiker
        else
          @sprites["Player"].y += 2
          @sprites["Hiker"].y += 2 if hiker
        end
        @sprites["Poles"].x += 6
        @sprites["Poles"].y += 3
        pbWait(2)
      end
    else
      @sprites["Trees"] = Sprite.new
      @sprites["Trees"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/trees")
      @sprites["Trees"].x = -922
      @sprites["Trees"].y = 292
      @sprites["Trees"].z = 92000
      if hiker
        @sprites["Hiker"] = Sprite.new
        @sprites["Hiker"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/"+hiker_name)
        @sprites["Hiker"].x = 190
        @sprites["Hiker"].y = 276
        @sprites["Hiker"].z = 93000
      end
      @sprites["Ground"] = Sprite.new
      @sprites["Ground"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/ground")
      @sprites["Ground"].x = -976
      @sprites["Ground"].y = 44
      @sprites["Ground"].z = 94000
      @sprites["CC"] = Sprite.new
      @sprites["CC"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/cable_car")
      @sprites["CC"].x = 202
      @sprites["CC"].y = -4
      @sprites["CC"].z = 96000
      @sprites["Player"] = Sprite.new
      if !$Trainer.isFemale?
        @sprites["Player"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/player_male")
      else
        @sprites["Player"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/player_female")
      end
      @sprites["Player"].x = 234
      @sprites["Player"].y = 56
      @sprites["Player"].z = 96100
      @sprites["Door"] = Sprite.new
      @sprites["Door"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/door")
      @sprites["Door"].x = 250
      @sprites["Door"].y = 108
      @sprites["Door"].z = 96200
      @sprites["Poles"] = Sprite.new
      @sprites["Poles"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/pole")
      @sprites["Poles"].x = 200
      @sprites["Poles"].y = -26
      @sprites["Poles"].z = 98000
      if weather
        @sprites["Ash"] = Sprite.new
        @sprites["Ash"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/CableCar/ash")
        @sprites["Ash"].opacity = 250
        @sprites["Ash"].x = -18
        @sprites["Ash"].y = -38
        @sprites["Ash"].z = 99000
      end
      for i in 0..50
        if i < 4
          @sprites["Black"].opacity -= 50
        elsif i == 4
          @sprites["Black"].opacity -= 55
        elsif i >= 46 && i < 50
          @sprites["Black"].opacity += 50
        elsif i == 50
          @sprites["Black"].opacity += 55
        end
        if i >= 26 && i <=30
          @sprites["Ash"].opacity -= 50 if weather
        end
        @sprites["Ash"].y -= 3 if weather
        @sprites["Ash"].x -= 8 if weather
        @sprites["Ground"].y -= 1
        @sprites["Ground"].x -= 4
        @sprites["Hiker"].x -= 2 if hiker
        @sprites["CC"].x += 2
        @sprites["Door"].x += 2
        @sprites["Player"].x += 2
        @sprites["Poles"].x -= 6
        @sprites["Poles"].y -= 3
        pbWait(2)
        @sprites["Ash"].y -= 3 if weather
        @sprites["Ash"].x -= 8 if weather
        @sprites["Ground"].y -= 1
        @sprites["Ground"].x -= 4
        @sprites["Hiker"].y -= 1 if hiker
        @sprites["Hiker"].x -= 4 if hiker
        @sprites["Trees"].y -= 1
        @sprites["Trees"].x -= 1
        @sprites["Poles"].x -= 6
        @sprites["Poles"].y -= 3
        pbWait(2)
        @sprites["Ash"].y -= 3 if weather
        @sprites["Ash"].x -= 8 if weather
        @sprites["Ground"].y -= 1
        @sprites["Ground"].x -= 4
        @sprites["Hiker"].y -= 1 if hiker
        @sprites["Hiker"].x -= 4 if hiker
        @sprites["Poles"].x -= 6
        @sprites["Poles"].y -= 3
        pbWait(2)
        @sprites["Ash"].y -= 3 if weather
        @sprites["Ash"].x -= 8 if weather
        @sprites["Ground"].y -= 1
        @sprites["Ground"].x -= 4
        @sprites["Hiker"].y -= 1 if hiker
        @sprites["Hiker"].x -= 4 if hiker
        @sprites["Trees"].y -= 1
        @sprites["Trees"].x -= 1
        @sprites["CC"].y += 2
        @sprites["CC"].x += 2
        @sprites["Door"].y += 2
        @sprites["Door"].x += 2
        @sprites["Player"].y += 2
        @sprites["Player"].x += 2
        if i % 2 == 0
          @sprites["Player"].y -= 2
          @sprites["Hiker"].y -= 2 if hiker
        else
          @sprites["Player"].y += 2
          @sprites["Hiker"].y += 2 if hiker
        end
        @sprites["Poles"].x -= 6
        @sprites["Poles"].y -= 3
        pbWait(2)
      end
    end
    @sprites["BG"].dispose
    @sprites["Trees"].dispose
    @sprites["Hiker"].dispose if hiker
    @sprites["Ground"].dispose
    @sprites["Ash"].dispose if weather
    @sprites["CC"].dispose
    @sprites["Player"].dispose
    @sprites["Poles"].dispose
    @sprites["Door"].dispose
    pbBGMFade(3)
    pbWait(5)
    $game_temp.player_transferring = true
    $game_temp.player_new_map_id = map_id
    $game_temp.player_new_x = map_x
    $game_temp.player_new_y = map_y
    $game_temp.player_new_direction = direction
    pbBGMStop(0)
    pbWait(5)
    for i in 0..14
      @sprites["Black"].opacity -= 17
      pbWait(1)
    end
    pbDisposeSpriteHash(@sprites)
    $game_map.autoplay
  end
end