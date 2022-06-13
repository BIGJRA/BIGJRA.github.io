#===============================================================================
# Data box for boss battles (by Stochastic)
# - adapted by Sardines for Pokemon Rejuvenation
#===============================================================================

def isBossPokemon?(pokemon)
#                 mon_species             => initial form
  pokemon_form = {PBSpecies::GYARADOS     => (3),
                  PBSpecies::GALVANTULA   => 1,
                  PBSpecies::VOLCANION    => 0,
                  PBSpecies::CARNIVINE    => 0,
                  PBSpecies::FERROTHORN   => 1,
                  PBSpecies::GIRATINA     => 1,
                  PBSpecies::GARBODOR     => 0,
                  PBSpecies::XURKITREE    => 0,
                  PBSpecies::NAGANADEL    => 0,
                  PBSpecies::GROUDON      => (0 || 1),
                  PBSpecies::KYOGRE       => (0 || 1),
                  PBSpecies::KINGDRA      => (0),
                  PBSpecies::CHANDELURE   => 2,
                  PBSpecies::DEOXYS       => 4,
                  PBSpecies::PARASECT     => 1,
                  PBSpecies::SOLROCK     => 1,
                  PBSpecies::CROBAT       => 0,
                  PBSpecies::GARDEVOIR    => 0,
                  PBSpecies::WAILORD      => 1,
                  PBSpecies::FROSLASS     => 1,
                  PBSpecies::REGICE       => 0,
                  PBSpecies::REGISTEEL    => 0,
                  PBSpecies::REGIROCK     => (0),
                  PBSpecies::COFAGRIGUS   => (0),
                  PBSpecies::HIPPOWDON    => 1,
                  PBSpecies::DARKRAI      => 1,
                  PBSpecies::XERNEAS      => 1,
                  PBSpecies::YVELTAL      => 0,
                  PBSpecies::DUSKNOIR     => 1
  }
  
  return false if (!pokemon || !pokemon.isbossmon)
  if pokemon_form[pokemon.species] == pokemon.form && (pokemon.isbossmon)
    return true
  elsif pokemon_form[pokemon.species] == pokemon.form && (($game_switches[1500]==true))
    return true
  elsif pokemon.isbossmon
    return true
  end
  
  return false
end

def isBossPokemonInRiftForm?(pokemon)
#                 mon_species             => rift form
  pokemon_form = {PBSpecies::GYARADOS     => (2),
                  PBSpecies::GALVANTULA   => 1,
                  PBSpecies::VOLCANION    => 1,
                  PBSpecies::CARNIVINE    => 1,
                  PBSpecies::CHANDELURE   => 2,
                  PBSpecies::GIRATINA     => 1,
                  PBSpecies::KINGDRA      => (1),
                  PBSpecies::FERROTHORN   => 2,
                  PBSpecies::GARBODOR     => 2,
                  PBSpecies::GARDEVOIR    => 2,
                  PBSpecies::FROSLASS     => 2,
                  PBSpecies::REGIROCK     => 1,
                  PBSpecies::COFAGRIGUS   => 1,
                  PBSpecies::HIPPOWDON    => 1,
                  PBSpecies::DARKRAI      => 1,
                  PBSpecies::XERNEAS      => 1,
                  PBSpecies::DUSKNOIR    => 1
  }
  
  return false if !pokemon
  if (pokemon_form[pokemon.species] == pokemon.form) && (pokemon.isbossmon)
    return true
  end
  if (pokemon_form[pokemon.species] == pokemon.form) && (($game_switches[1500]==true))
    return true
  end
  if pokemon_form[pokemon.species] == pokemon.form
    return true
  end
  return false
end

class BossPokemonDataBox < SpriteWrapper
  HP_GAUGE_SIZE = 298
  HP_COLOR_WHITE = Color.new(255, 255, 255)
  HP_COLOR_RED = Color.new(248,88,40)
  TEXT_COLOR_GRAY = Color.new(225,225,225)
  
  attr_reader :battler
  attr_accessor :selected
  attr_reader :animatingHP
  attr_reader :animatingEXP
  attr_reader :appearing
  attr_accessor :shieldCount
  attr_reader :shieldX
  attr_reader :shieldY
  attr_reader :shieldGaugeX
  attr_reader :shieldGaugeY

  def initialize(battler, doublebattle, viewport=nil,battlerindex,battle)
    super(viewport)
    @battler = battler
    @battlerindex=battlerindex
    @battle = battle
    @frame = 0
    @showhp = true
    @animatingHP = false
    @starthp = 0
    @currenthp = 0
    @endhp = 0
    @appearing = false
    @appeared = true
    @shieldCount = -1
    
    if isBossPokemonInRiftForm?(battler) || $game_switches[1305] || $game_switches[1500] || battler.isbossmon
      if $game_variables[704]>0
        @shieldCount = $game_variables[704]
      else
        @shieldCount = 2
      end
#      @battle.shieldSetup = 1
#      @battle.shieldCount = 3
    end
    
    @statuses = AnimatedBitmap.new("Graphics/Pictures/Battle/battleStatuses")
    @hpbox = Bitmap.new("Graphics/Pictures/Battle/boss_bar")
    
    # @hpboxX = 0
    # @hpboxY = 10
    # @hpGaugeY = 36
    # @shieldX = 90
    # @shieldY = 31
    # @shieldGaugeX = 20
    # @shieldGaugeY = 10
    if battlerindex==1
      @hpboxX = 0
      @hpboxY = 10
      @hpGaugeY = 36
      @shieldX = 90
      @shieldY = 31
      @shieldGaugeX = 20
      @shieldGaugeY = 10
    else
      @hpboxX = 0
      @hpboxY = 62
      @hpGaugeY = 36
      @shieldX = 90
      @shieldY = 71
      @shieldGaugeX = 20
      @shieldGaugeY = 50
    end
    self.bitmap = BitmapWrapper.new(@hpbox.width + 100, @hpbox.height + 100)
    self.visible = false
    self.x = ((Graphics.width - @hpbox.width) / 6)-27
    if @doublebattle
      self.y = 10
    else
      self.y = 1
    end
    self.z = 99999
    pbSetSmallFont(self.bitmap)
    
#    if @battle.raidbattle
#      pbUpdateShield(@shieldCount, self)
#    end
    
    refresh
  end

  def dispose
    @statuses.dispose
    @hpbox.dispose
    @shields.dispose
    super
  end

  def exp
    return 0
  end

  def hp
    return @animatingHP ? @currenthp : @battler.hp
  end

  def animateHP(oldhp,newhp)
    @starthp=oldhp
    @currenthp=oldhp
    @endhp=newhp
    @animatingHP=true
  end

  def animateEXP(oldexp,newexp)
  end

  def appear
    refresh
    self.visible = true
    self.opacity = 255
    @appearing = true
    @appeared = false
    @framesToAppear = 45
  end

  def refresh
    self.bitmap.clear
    
    return if !@appeared
    @shieldlife=@battle.battlers[@battlerindex].effects[PBEffects::ShieldLife]
    hpgauge = @battler.totalhp==0 ? 0 : (self.hp*HP_GAUGE_SIZE/@battler.totalhp)
    hpgauge=2 if hpgauge==0 && self.hp>0
    hpzone=0
    hpzone=1 if self.hp<=(@battler.totalhp/2).floor
    hpzone=2 if self.hp<=(@battler.totalhp/4).floor
    hpcolors=[
       PokeBattle_SceneConstants::HPCOLORGREENDARK,
       PokeBattle_SceneConstants::HPCOLORGREEN,
       PokeBattle_SceneConstants::HPCOLORYELLOWDARK,
       PokeBattle_SceneConstants::HPCOLORYELLOW,
       PokeBattle_SceneConstants::HPCOLORREDDARK,
       PokeBattle_SceneConstants::HPCOLORRED
    ]
#    self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY,hpgauge,2,hpcolors[hpzone*2])
#    self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY+2,hpgauge,4,hpcolors[hpzone*2+1])
    
    self.bitmap.blt(@hpboxX, @hpboxY, @hpbox, Rect.new(0, 0, @hpbox.width, @hpbox.height))
    self.bitmap.fill_rect(@hpboxX + 4, @hpboxY + @hpGaugeY, HP_GAUGE_SIZE, 4, HP_COLOR_WHITE)
    self.bitmap.fill_rect(@hpboxX + 4, @hpboxY + @hpGaugeY, hpgauge, 1, hpcolors[hpzone*2])
    self.bitmap.fill_rect(@hpboxX + 4, @hpboxY + @hpGaugeY+1, hpgauge, 3, hpcolors[hpzone*2+1])

    base = PokeBattle_SceneConstants::BOXTEXTBASECOLOR
    shadow = PokeBattle_SceneConstants::BOXTEXTSHADOWCOLOR
    hpText = "#{self.hp} / #{@battler.totalhp}"
    battlerText = @battler.name
    textSize = self.bitmap.text_size(hpText)
    battlerTextSize = self.bitmap.text_size(battlerText)
    textpos = [
       ["#{@battler.name}", 11,
         @hpboxY+15, false, base, shadow]
#       [hpText, @hpboxX + @hpbox.width/2 - textSize.width/2,
#         @hpboxY + 32, false, base, shadow]
    ]
    @spritebaseX=0
    pbDrawTextPositions(self.bitmap, textpos)
    if @battler.status > 0
      self.bitmap.blt(10, 54, @statuses.bitmap, Rect.new(0,(@battler.status-1)*16,44,16))
    end
    pbDrawTextPositions(self.bitmap, textpos)
    shieldXPos = @shieldX
    shieldYPos = @shieldY
    shieldX=[252,236,214,198,182,166,150]
    if @shieldGaugeY == 10
      shieldY=[28,28,22,22,22,22,22]
    elsif @shieldGaugeY == 50
      shieldY=[80,80,74,74,74,74,74]
    end
    @shields = Bitmap.new("Graphics/Pictures/Battle/bossbarshield")
    @shieldsBroken = Bitmap.new("Graphics/Pictures/Battle/bossbarshieldcracked")
    if @shieldCount > 0
      #for i in 0...@shieldCount
        count=0
        loop do
          if count==@shieldCount-1 && (@shieldlife>0 && @shieldlife<(@battler.totalhp/4))
            self.bitmap.blt(shieldX[count],shieldY[count],@shieldsBroken,Rect.new(0,16,44,16))
          else
            self.bitmap.blt(shieldX[count],shieldY[count],@shields,Rect.new(0,16,44,16))
          end
          count+=1
          #shieldXPos += (@shieldGaugeX + 2)
        break if count==@shieldCount
        end
      #end
    end
    
  end

  def update
    super
    @frame += 1
    if @animatingHP
      if @currenthp < @endhp
        @currenthp += [1, (0.5 * @battler.totalhp / HP_GAUGE_SIZE).floor].max
        @currenthp = @endhp if @currenthp > @endhp
      elsif @currenthp > @endhp
        @currenthp -= [1, (0.5 * @battler.totalhp / HP_GAUGE_SIZE).floor].max
        @currenthp = @endhp if @currenthp<@endhp
      end
      @animatingHP = false if @currenthp==@endhp
      refresh
    end
    if @framesToAppear
      @framesToAppear -= 1 if @framesToAppear > 0
      if @framesToAppear <= 0
        @appearing = false
        @appeared = true
      end
    end
  end
end