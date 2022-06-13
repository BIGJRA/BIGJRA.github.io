#===============================================================================
# ■ Map Connection Overlap fix by KleinStudio
# http://kleinstudio.deviantart.com
#===============================================================================
class Spriteset_Map
  alias klein_mapcon_initialize initialize
  def initialize(map=nil)
    klein_mapcon_initialize(map)
    if @map==$game_map
      @loadedby=0
    else
      @viewport1.z=80
      @loadedby=1
    end
  end
  
  alias klein_mapcon_update update
  def update
    updateConMaps
    klein_mapcon_update
  end
  
  def updateConMaps
    if self.map!=$game_map && @loadedby==0
      @viewport1.z=80
      @loadedby=1
    end
    if self.map==$game_map && @loadedby==1
      @viewport1.z=90
      @loadedby=0
    end
  end
end