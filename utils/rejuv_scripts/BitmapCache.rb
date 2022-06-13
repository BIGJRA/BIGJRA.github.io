class Hangup < Exception; end



def strsplit(str,re)
  ret=[]
  tstr=str
  while re=~tstr
    ret[ret.length]=$~.pre_match
    tstr=$~.post_match
  end
  ret[ret.length]=tstr if ret.length
  return ret
end

def canonicalize(c)
  return System.normalize(c)
end


# Cache from RPG Maker VX library
module Cache
  def self.system(x,hue=0)
    BitmapCache.load_bitmap("Graphics/System/"+x,hue, true)
  end

  def self.character(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Characters/"+x,hue, true)
  end

  def self.picture(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Pictures/"+x,hue, true)
  end

  def self.animation(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Animations/"+x,hue, true)
  end

  def self.battler(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Battlers/"+x,hue, true)
  end

  def self.face(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Faces/"+x,hue, true)
  end

  def self.parallax(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Parallaxes/"+x,hue, true)
  end

  def self.clear
    BitmapCache.clear()
  end

  def self.load_bitmap(dir,name,hue=0)
    BitmapCache.load_bitmap(dir+name,hue, true)
  end
end

# RPG::Cache from RPG Maker XP library
module RPG
  module Cache
    def self.load_bitmap(folder_name, filename, hue = 0)
      BitmapCache.load_bitmap(folder_name+filename.to_s,hue, true)
    end

    def self.animation(filename, hue)
      self.load_bitmap("Graphics/Animations/", filename, hue)
    end

    def self.autotile(filename)
      self.load_bitmap("Graphics/Autotiles/", filename)
    end

    def self.battleback(filename)
      self.load_bitmap("Graphics/Battlebacks/", filename)
    end

    def self.battler(filename, hue)
      self.load_bitmap("Graphics/Battlers/", filename, hue)
    end

    def self.character(filename, hue)
      self.load_bitmap("Graphics/Characters/", filename, hue)
    end

    def self.fog(filename, hue)
      self.load_bitmap("Graphics/Fogs/", filename, hue)
    end

    def self.gameover(filename)
      self.load_bitmap("Graphics/Gameovers/", filename)
    end

    def self.icon(filename)
      self.load_bitmap("Graphics/Icons/", filename)
    end

    def self.panorama(filename, hue)
      self.load_bitmap("Graphics/Panoramas/", filename, hue)
    end

    def self.picture(filename)
      self.load_bitmap("Graphics/Pictures/", filename)
    end

    def self.tileset(filename)
      self.load_bitmap("Graphics/Tilesets/", filename)
    end

    def self.title(filename)
      self.load_bitmap("Graphics/Titles/", filename)
    end

    def self.windowskin(filename)
      self.load_bitmap("Graphics/Windowskins/", filename)
    end

    def self.tile(filename, tile_id, hue)
      BitmapCache.tile(filename,tile_id,hue)
    end

    def self.clear
      BitmapCache.clear()
    end
  end
end

class BitmapWrapper < Bitmap
  attr_reader :refcount

  def dispose
    return if self.disposed?
    @refcount-=1
    if @refcount<=0
      super
    end
  end

  def initialize(*arg)
    super
    @refcount=1
  end

  def resetRef # internal
    @refcount=1
  end

  def copy
    bm=self.clone
    bm.resetRef
    return bm
  end

  def addRef
    @refcount+=1
  end
end



module BitmapCache
  @cache = ObjectSpace::WeakMap.new

  def self.fromCache(i)
    return nil if !@cache.include?(i)
    obj=@cache[i]
    return nil if obj && obj.disposed?
    return obj
  end

  def self.setKey(key,obj)
    @cache[key]=obj
  end

  def self.debug
    File.open("bitmapcache2.txt","wb"){|f|
       for i in @cache.keys
         k=fromCache(i)
         if !k
           f.write("#{i} (nil)\r\n")
         elsif k.disposed?
           f.write("#{i} (disposed)\r\n")
         else
           f.write("#{i} (#{k.refcount}, #{k.width}x#{k.height})\r\n")
         end
       end
    }
  end

  def self.load_bitmap(path, hue = 0, failsafe = false)
    cached = true
    path = -canonicalize(path)  # This creates a frozen string from the path, to ensure identical paths are treated as identical.
    objPath = fromCache(path)
    if !objPath
      begin
        bm = BitmapWrapper.new(path)
        rescue Hangup
        begin
          bm = BitmapWrapper.new(path)
          rescue
          raise _INTL("Failed to load the bitmap located at: {1}",path) if !failsafe
          bm = BitmapWrapper.new(32,32)
        end
        rescue
        raise _INTL("Failed to load the bitmap located at: {1}",path) if !failsafe
        bm = BitmapWrapper.new(32,32)
      end
      objPath=bm
      @cache[path]=objPath
      cached=false
    end
    if hue == 0
      objPath.addRef if cached
      return objPath
    else
      key = [path, hue]
      objKey=fromCache(key)
      if !objKey
        bitmap= objPath.copy
        bitmap.hue_change(hue) if hue!=0
        objKey=bitmap
        @cache[key]=objKey
      else
        objKey.addRef
      end
      return objKey
    end
  end

  def self.animation(filename, hue)
    self.load_bitmap("Graphics/Animations/"+filename, hue)
  end

  def self.autotile(filename)
    self.load_bitmap("Graphics/Autotiles/"+ filename)
  end

  def self.battleback(filename)
    self.load_bitmap("Graphics/Battlebacks/"+ filename)
  end

  def self.battler(filename, hue)
    self.load_bitmap("Graphics/Battlers/"+ filename, hue)
  end

  def self.character(filename, hue)
    self.load_bitmap("Graphics/Characters/"+ filename, hue)
  end

  def self.fog(filename, hue)
    self.load_bitmap("Graphics/Fogs/"+ filename, hue)
  end

  def self.gameover(filename)
    self.load_bitmap("Graphics/Gameovers/"+ filename)
  end

  def self.icon(filename)
    self.load_bitmap("Graphics/Icons/"+ filename)
  end

  def self.panorama(filename, hue)
    self.load_bitmap("Graphics/Panoramas/"+ filename, hue)
  end

  def self.picture(filename)
    self.load_bitmap("Graphics/Pictures/"+ filename)
  end

  def self.tileset(filename)
    self.load_bitmap("Graphics/Tilesets/"+ filename)
  end

  def self.title(filename)
    self.load_bitmap("Graphics/Titles/"+ filename)
  end

  def self.windowskin(filename)
    self.load_bitmap("Graphics/Windowskins/"+ filename)
  end

  def self.tileEx(filename, tile_id, hue)
    key = [filename, tile_id, hue]
    objKey=fromCache(key)
    if !objKey
      bitmap=BitmapWrapper.new(32, 32)
      x = (tile_id - 384) % 8 * 32
      y = (tile_id - 384) / 8 * 32
      rect = Rect.new(x, y, 32, 32)
      tileset = yield(filename)
      bitmap.blt(0, 0, tileset, rect)
      tileset.dispose
      bitmap.hue_change(hue) if hue!=0
      objKey=bitmap
      @cache[key]=objKey
    else
      objKey.addRef
    end
    objKey
  end

  def self.tile(filename, tile_id, hue)
    return self.tileEx(filename, tile_id,hue) {|f| self.tileset(f) }
  end

  def self.clear
    @cache = ObjectSpace::WeakMap.new
    GC.start
  end
end