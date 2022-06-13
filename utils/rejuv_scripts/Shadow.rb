#===============================================================================
# Sprite_Shadow (Sprite_Ombre )
# Based on Genzai Kawakami's shadows, dynamisme & features by Rataime, extra
# features Boushy
# Modified by Peter O. to be compatible with Pokémon Essentials
#===============================================================================
CATERPILLAR_COMPATIBLE = true
SHADOW_WARN = true

class Sprite_Shadow < RPG::Sprite
  attr_accessor :character
 
  def initialize(viewport, character = nil,params=[])
    super(viewport)
    @source=params[0]
    @anglemin=0
    @anglemin=params[1] if params.size>1
    @anglemax=0
    @anglemax=params[2] if params.size>2
    @self_opacity=100
    @self_opacity=params[4] if params.size>4
    @distancemax=350
    @distancemax=params[3] if params.size>3
    @character = character
    update
  end

  def dispose
    @chbitmap.dispose if @chbitmap
    super
  end

  def update
    if !in_range?(@character, @source, @distancemax)
      self.opacity=0
      return
    end
    super
    if @tile_id != @character.tile_id ||
       @character_name != @character.character_name ||
       @character_hue != @character.character_hue
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      if @tile_id >= 384
        @chbitmap.dispose if @chbitmap
        @chbitmap = pbGetTileBitmap(@character.map.tileset_name,
           @tile_id, @character.character_hue)
        self.src_rect.set(0, 0, 32, 32)
        @ch=32
        @cw=32
        self.ox = 16
        self.oy = 32
      else
        @chbitmap.dispose if @chbitmap
        @chbitmap=AnimatedBitmap.new(
           "Graphics/Characters/"+@character.character_name,
           @character.character_hue)
        @cw = @chbitmap.width / 4
        @ch = @chbitmap.height / 4
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
    if @chbitmap.is_a?(AnimatedBitmap)
      @chbitmap.update;
      self.bitmap=@chbitmap.bitmap
    else
      self.bitmap=@chbitmap
    end
    self.visible = (not @character.transparent)
    if @tile_id == 0
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      if self.angle>90 or angle<-90
        case @character.direction
        when 2; sy = (8- 2) / 2 * @ch
        when 4; sy = (6- 2) / 2 * @ch
        when 6; sy = (4- 2) / 2 * @ch
        when 8; sy = (2- 2) / 2 * @ch
        end
      end
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    self.x = ScreenPosHelper.pbScreenX(@character)
    self.y = ScreenPosHelper.pbScreenY(@character)-5
    self.z = ScreenPosHelper.pbScreenZ(@character,@ch)-1
    self.zoom_x = ScreenPosHelper.pbScreenZoomX(@character)
    self.zoom_y = ScreenPosHelper.pbScreenZoomY(@character)
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
    @deltax=ScreenPosHelper.pbScreenX(@source)-self.x
    @deltay=ScreenPosHelper.pbScreenY(@source)-self.y
    self.color = Color.new(0, 0, 0)
    @distance = ((@deltax ** 2) + (@deltay ** 2))
    self.opacity = @self_opacity*13000/((@distance*370/@distancemax)+6000)
    self.angle = 57.3 * Math.atan2(@deltax, @deltay)
    @angle_trigo=self.angle+90
    if @angle_trigo<0
      @angle_trigo=360+@angle_trigo
    end
    if @anglemin!=0 or @anglemax!=0
      if (@angle_trigo<@anglemin or @angle_trigo>@anglemax) and @anglemin<@anglemax
        self.opacity=0
        return
      end
      if (@angle_trigo<@anglemin and @angle_trigo>@anglemax) and @anglemin>@anglemax
        self.opacity=0
        return
      end     
    end
  end

  def in_range?(element, object, range)# From Near's Anti Lag Script, edited
    elemScreenX=ScreenPosHelper.pbScreenX(element)
    objScreenX=ScreenPosHelper.pbScreenX(object)
    elemScreenY=ScreenPosHelper.pbScreenY(element)
    objScreenY=ScreenPosHelper.pbScreenY(object)
    x = (elemScreenX - objScreenX) * (elemScreenX - objScreenX)
    y = (elemScreenY - objScreenY) * (elemScreenY - objScreenY)
    r = x + y
    return (r <= (range * range))
  end
end



#===================================================
# ? CLASS Sprite_Character edit
#===================================================
class Sprite_Character < RPG::Sprite
  alias :shadow_initialize :initialize

  def initialize(viewport, character = nil)
    @ombrelist=[]
    @character = character
    shadow_initialize(viewport, @character)
  end

  def setShadows(map,shadows)
    if character.is_a?(Game_Event) and shadows.length>0
      params = XPML_read(map,"Shadow",@character,4)
      if params!=nil
        for i in 0...shadows.size
          @ombrelist.push(Sprite_Shadow.new(
             viewport, @character,shadows[i]
          ))
        end
      end
    end
    if character.is_a?(Game_Player) and shadows.length>0
      for i in 0...shadows.size
        @ombrelist.push(Sprite_Shadow.new(
           viewport, $game_player,shadows[i]
        ))
      end
    end
    update
  end

  alias shadow_update update

  def update
    shadow_update
    if @ombrelist.length>0
      for i in 0...@ombrelist.size
        @ombrelist[i].update
      end
    end
  end
end



#===================================================
# ? CLASS Game_Event edit
#===================================================
class Game_Event
  attr_accessor :id
end



#===================================================
# ? CLASS Spriteset_Map edit
#===================================================
class Spriteset_Map
  attr_accessor :shadows
  alias shadow_initialize initialize
  
  def initialize(map=nil)
    @shadows=[]
    warn=false
    map=$game_map if !map
    for k in map.events.keys.sort
      warn=true if (map.events[k].list!=nil and
         map.events[k].list[0].code == 108 and
         (map.events[k].list[0].parameters == ["s"] or
         map.events[k].list[0].parameters == ["o"]))
      params = XPML_read(map,"Shadow Source",map.events[k],4)
      @shadows.push([map.events[k]]+params) if params!=nil
    end
    if warn == true and SHADOW_WARN
      p "Warning : At least one event on this map uses the obsolete way to add shadows"
    end
    shadow_initialize(map)
    for sprite in @character_sprites
      sprite.setShadows(map,@shadows)
    end
  end  
end



#===================================================
# ? XPML Definition, by Rataime, using ideas from Near Fantastica
#
#   Returns nil if the markup wasn't present at all,
#   returns [] if there wasn't any parameters, else
#   returns a parameters list with "int" converted as int
#   eg :
#   begin first
#   begin second
#   param1 1
#   param2 two
#   begin third
#   anything 3
#
#   p XPML_read("first", event_id) -> []
#   p XPML_read("second", event_id) -> [1,"two"]
#   p XPML_read("third", event_id) -> [3]
#   p XPML_read("forth", event_id) -> nil
#===================================================
def XPML_read(map,markup,event,max_param_number=0)
  parameter_list = nil
  return nil if !event || event.list==nil
    for i in 0...event.list.size
      if event.list[i].code == 108 and
         event.list[i].parameters[0].downcase == "begin "+markup.downcase
        parameter_list = [] if parameter_list == nil
        for j in i+1...event.list.size
          if event.list[j].code == 108
            parts = event.list[j].parameters[0].split
            if parts.size!=1 and parts[0].downcase!="begin"
              if parts[1].to_i!=0 or parts[1]=="0"
                parameter_list.push(parts[1].to_i)
              else
                parameter_list.push(parts[1])
              end
            else
              return parameter_list
            end
          else
            return parameter_list
          end
          return parameter_list if max_param_number!=0 and j==i+max_param_number
        end
      end
    end
  return parameter_list
end