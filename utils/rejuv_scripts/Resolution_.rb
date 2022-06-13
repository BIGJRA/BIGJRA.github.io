class Game_Map
  TILEWIDTH = 32
  TILEHEIGHT = 32
  XSUBPIXEL = $RPGVX ? 8 : 4
  YSUBPIXEL = $RPGVX ? 8 : 4

  def self.realResX
    return XSUBPIXEL * TILEWIDTH
  end

  def self.realResY
    return YSUBPIXEL * TILEHEIGHT
  end

  def display_x=(value)
    @display_x=value
    if pbGetMetadata(self.map_id,MetadataSnapEdges)
      max_x = (self.width - Graphics.width*1.0/Game_Map::TILEWIDTH) * Game_Map.realResX
      @display_x = [0, [@display_x, max_x].min].max
    end
    $MapFactory.setMapsInRange if $MapFactory
  end

  def display_y=(value)
    @display_y=value
    if pbGetMetadata(self.map_id,MetadataSnapEdges)
      max_y = (self.height - Graphics.height*1.0/Game_Map::TILEHEIGHT) * Game_Map.realResY
      @display_y = [0, [@display_y, max_y].min].max
    end
    $MapFactory.setMapsInRange if $MapFactory
  end

  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    if direction==2 || direction==8     
       @scroll_rest = distance * Game_Map.realResY
    else
       @scroll_rest = distance * Game_Map.realResX
    end
    @scroll_speed = speed
  end

  def scroll_down(distance)
    self.display_y+=distance
  end

  def scroll_left(distance)
   self.display_x-=distance
  end

  def scroll_right(distance)
    self.display_x+=distance
  end

  def scroll_up(distance)
   self.display_y-=distance
  endend