module RPG
  class Weather
    attr_reader :type
    attr_reader :max
    attr_reader :ox
    attr_reader :oy

    def prepareSandstormBitmaps
      if !@sandstormBitmap1
        bmwidth=200
        bmheight=200
        @sandstormBitmap1=Bitmap.new(bmwidth,bmheight)
        @sandstormBitmap2=Bitmap.new(bmwidth,bmheight)
        sandstormColors=[
           Color.new(31*8,28*8,17*8,30),
           Color.new(23*8,16*8,9*8,60),
           Color.new(29*8,24*8,15*8,80),
           Color.new(26*8,20*8,12*8,110),
           Color.new(20*8,13*8,6*8,95),
           Color.new(31*8,30*8,20*8,125),
           Color.new(27*8,25*8,20*8,45)
        ]
        for i in 0..540
          @sandstormBitmap1.fill_rect(rand(bmwidth/2)*2, rand(bmheight/2)*2, 2,2,sandstormColors[rand(7)])
          @sandstormBitmap2.fill_rect(rand(bmwidth/2)*2, rand(bmheight/2)*2, 2,2,sandstormColors[rand(7)])
        end
        @weatherTypes[4][0][0]=@sandstormBitmap1
        @weatherTypes[4][0][1]=@sandstormBitmap2
      end
    end

    def prepareSnowBitmaps
      if !@snowBitmap1
        bmwidth=10
        bmheight=10
        @snowBitmap1=Bitmap.new(bmwidth,bmheight)
        @snowBitmap2=Bitmap.new(bmwidth,bmheight)
        @snowBitmap3=Bitmap.new(bmwidth,bmheight)
        snowcolor = Color.new(224, 232, 240, 255)
        @snowBitmap1.fill_rect(4,2,2,2,snowcolor)
        @snowBitmap1.fill_rect(2,4,6,2,snowcolor)
        @snowBitmap1.fill_rect(4,6,2,2,snowcolor)
        @snowBitmap2.fill_rect(2,0,4,2,snowcolor)
        @snowBitmap2.fill_rect(0,2,8,4,snowcolor)
        @snowBitmap2.fill_rect(2,6,4,2,snowcolor)
        @snowBitmap3.fill_rect(4,0,2,2,snowcolor)
        @snowBitmap3.fill_rect(2,2,6,2,snowcolor)
        @snowBitmap3.fill_rect(0,4,10,2,snowcolor)
        @snowBitmap3.fill_rect(2,6,6,2,snowcolor)
        @snowBitmap3.fill_rect(4,8,2,2,snowcolor)
        @weatherTypes[3][0][0]=@snowBitmap1
        @weatherTypes[3][0][1]=@snowBitmap2
        @weatherTypes[3][0][2]=@snowBitmap3
      end
    end

    def prepareBlizzardBitmaps
      if !@blizzardBitmap1
        bmwidth=10; bmheight=10
        @blizzardBitmap1=Bitmap.new(bmwidth,bmheight)
        @blizzardBitmap2=Bitmap.new(bmwidth,bmheight)
        bmwidth=200; bmheight=200
        @blizzardBitmap3=Bitmap.new(bmwidth,bmheight)
        @blizzardBitmap4=Bitmap.new(bmwidth,bmheight)
        snowcolor = Color.new(224, 232, 240, 255)
        @blizzardBitmap1.fill_rect(2,0,4,2,snowcolor)
        @blizzardBitmap1.fill_rect(0,2,8,4,snowcolor)
        @blizzardBitmap1.fill_rect(2,6,4,2,snowcolor)
        @blizzardBitmap2.fill_rect(4,0,2,2,snowcolor)
        @blizzardBitmap2.fill_rect(2,2,6,2,snowcolor)
        @blizzardBitmap2.fill_rect(0,4,10,2,snowcolor)
        @blizzardBitmap2.fill_rect(2,6,6,2,snowcolor)
        @blizzardBitmap2.fill_rect(4,8,2,2,snowcolor)
        for i in 0..540
          @blizzardBitmap3.fill_rect(rand(bmwidth/2)*2, rand(bmheight/2)*2, 2,2,snowcolor)
          @blizzardBitmap4.fill_rect(rand(bmwidth/2)*2, rand(bmheight/2)*2, 2,2,snowcolor)
        end
        @weatherTypes[8][0][0]=@blizzardBitmap1
        @weatherTypes[8][0][1]=@blizzardBitmap2
        @weatherTypes[8][0][2]=@blizzardBitmap3 # Tripled to make them 3x as common
        @weatherTypes[8][0][3]=@blizzardBitmap3
        @weatherTypes[8][0][4]=@blizzardBitmap3
        @weatherTypes[8][0][5]=@blizzardBitmap4 # Tripled to make them 3x as common
        @weatherTypes[8][0][6]=@blizzardBitmap4
        @weatherTypes[8][0][7]=@blizzardBitmap4
      end
    end

    def initialize(viewport = nil)
      @type = 0
      @max = 0
      @ox = 0
      @oy = 0
      @sunvalue = 0
      @sun = 0
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = viewport.z+1
      @origviewport = viewport
      color = Color.new(255, 255, 255, 255)
      @rain_bitmap = Bitmap.new(32, 128)
      @storm_bitmap = Bitmap.new(192, 192)
      @wind_bitmap = Bitmap.new(192, 192)
      colorWind = Color.new(200, 200, 200, 50)
      #cass note: quirky optimization: run the for loops at the same time
      for i in 0...16
        i_two = i*2
        @rain_bitmap.fill_rect(30-i_two, i*8, 2, 8, color)
        @storm_bitmap.fill_rect(190-i_two, i_two, 2, 2, color)
        @wind_bitmap.fill_rect(190-i_two, (192-i)/10, 2, 6, colorWind)
      end
      for i in 17...96
        i_two = i*2
        @storm_bitmap.fill_rect(190-i_two, i_two, 2, 2, color)
        @wind_bitmap.fill_rect(190-i_two, (192-i)/10, 2, 6, colorWind)
      end
      for i in 97...192
        i_two = i*2
        @wind_bitmap.fill_rect(190-(i_two), (192-i)/10, 2, 6, colorWind)
      end
      @weatherTypes=[ # bitmap(s), x per frame, y per frame, opacity per frame
         nil,                                # 0: No weather
         [[@rain_bitmap],-6,24,-8],          # 1: Rain
         [[@storm_bitmap],-24,24,-4],        # 2: Storm
         [[],-4,8,0],                        # 3: Snow
         [[],-12,4,-2],                      # 4: Sandstorm
         nil,                                # 5: Sunny
         [[@wind_bitmap],4,1,0],             # 6: Winds
         [[@storm_bitmap],-24,24,-4],        # 7: Heavy rain
         [[],-16,16,-4],                     # 8: Blizzard         
      ]
      @sprites = []
    end

    def ensureSprites
      return if @sprites.length>=40
      for i in 1..40
        sprite = Sprite.new(@origviewport)
        sprite.z = 1000
        sprite.opacity = 0
        sprite.ox = @ox
        sprite.ox += 160 if @type==8
        sprite.oy = @oy
        sprite.visible = (i <= @max)
        @sprites.push(sprite)
      end
    end

    def dispose
      for sprite in @sprites
        sprite.dispose
      end
      @viewport.dispose
      for weather in @weatherTypes
        next if !weather
        for bm in weather[0]
          bm.dispose
        end
      end
    end

    def opacity(value)
      for i in 1..@max
        if @sprites[i] != nil
          @sprites[i].opacity = value
        end
      end
    end

    def type=(type)
      return if @type == type
      @type = type
      if @type==0
        bitmap = nil
        for sprite in @sprites
          sprite.dispose
        end
        @sprites.clear
        return
      end
      case @type
        when 1 # Rain
          bitmap = @rain_bitmap
        when 2, 7 # Storm, heavy rain
          bitmap = @storm_bitmap
        when 3 # Snow
          prepareSnowBitmaps
        when 4 # Sandstorm
          prepareSandstormBitmaps
        when 6 # Winds
          bitmap = @wind_bitmap          
        when 8 # Blizzard
          prepareBlizzardBitmaps
        else
          bitmap = nil
        end
      zero_five = @type==0 || @type==5
      four_eight = @type==4 || @type==8
      weatherbitmaps= zero_five ? nil : @weatherTypes[@type][0]
      ensureSprites
      for i in 1..40
        sprite = @sprites[i]
        if sprite != nil
          if four_eight
            sprite.mirror=(rand(2)==0) ? true : false
          else
            sprite.mirror=false
          end
          sprite.visible = (i <= @max)
          sprite.bitmap = zero_five ? nil : weatherbitmaps[i%weatherbitmaps.length]
        end
      end
    end

    def ox=(ox)
      return if @ox == ox;
      @ox = ox
      for sprite in @sprites
        sprite.ox = @ox
      end
    end

    def oy=(oy)
      return if @oy == oy;
      @oy = oy
      for sprite in @sprites
        sprite.oy = @oy
      end
    end

    def max=(max)
      return if @max == max;
      @max = [[max, 0].max, 40].min
      if @max==0
        for sprite in @sprites
          sprite.dispose
        end
        @sprites.clear
      else
        for i in 1..40
          sprite = @sprites[i]
          if sprite != nil
            sprite.visible = (i <= @max)
          end
        end
      end
    end

    def update
      # @max is (power+1)*4, where power is between 1 and 9
      case @type
        when 0 # No weather
          @viewport.tone.set(0,0,0,0)
        when 1 # Rain
          @viewport.tone.set(-@max*3/4,-@max*3/4,-@max*3/4,10)
        when 2, 7 # Storm, heavy rain
          @viewport.tone.set(-@max*6/4,-@max*6/4,-@max*6/4,20)
        when 3 # Snow
          @viewport.tone.set(@max/2,@max/2,@max/2,0)
        when 4 # Sandstorm
          @viewport.tone.set(@max/2,0,-@max/2,0)
        when 5 # Sunny
          if $game_screen.tone_duration == 0
            unless @sun==@max || @sun==-@max
              @sun=@max
            end
            @sun=-@sun if @sunvalue>@max || @sunvalue<0
            @sunvalue=@sunvalue+@sun/32
            @viewport.tone.set(@sunvalue+63,@sunvalue+63,@sunvalue/2+31,0)
          elsif pbGetMetadata($game_map.map_id,MetadataOutdoor)
            totaltone = (($game_screen.tone.red + $game_screen.tone.green + $game_screen.tone.blue) / 3.0)
            @viewport.tone.set((@sunvalue+63)*((255+totaltone)/255),(@sunvalue+63)*((255+totaltone)/255),(@sunvalue/2+31)*((255+totaltone)/255),0)
          end
        when 6 # Winds
          @viewport.tone.set(0,0,0,0)           
        when 8 # Blizzard
          @viewport.tone.set(@max*3/4,@max*3/4,@max*3/4,0)
      end
      if @type==2 && $idk[:settings].photosensitive==0 # Storm flashes
        rnd=rand(500)
        if rnd<2
          @viewport.flash(Color.new(255,255,255,230),rnd*20)
        end
      end
      @viewport.update
      return if @type == 0 || @type == 5
      ensureSprites
      for i in 1..@max
        sprite = @sprites[i]
        break if sprite == nil
        sprite.x += @weatherTypes[@type][1]
        sprite.y += @weatherTypes[@type][2]
        sprite.opacity += @weatherTypes[@type][3]
        sprite.x += [2,0,0,-2][rand(4)] if @type==3 || @type==7
        x =  sprite.x - @ox 
        y =  sprite.y - @oy 
        nomwidth=Graphics.width
        nomheight=Graphics.height
        if x < -50 || x > nomwidth+128 || y < -300 || y > nomheight+20
          sprite.x = rand(nomwidth+150)  -  50 + @ox
          sprite.y = rand(nomheight+150) - 200 + @oy
          sprite.opacity = 255
          if @type==4
            sprite.mirror=(rand(2)==0) ? true : false
          else
            sprite.mirror=false
          end
        end
        pbDayNightTint(sprite)
      end
      totaltone = (($game_screen.tone.red + $game_screen.tone.green + $game_screen.tone.blue) / 3.0)
      opacity(255 + totaltone) if totaltone < 0
    end
  end
end