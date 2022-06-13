# Combined multiple PB[etc] scripts into one.
# Ordered as follows:
# PBStatuses
# PBStats
# PBWeather
# PBEnvironment
# PBEffects
# PBNatures

class PBStatuses
  SLEEP     = 1
  POISON    = 2
  BURN      = 3
  PARALYSIS = 4
  FROZEN    = 5
end

class PBStats
  HP       = 0
  ATTACK   = 1
  DEFENSE  = 2
  SPEED    = 3
  SPATK    = 4
  SPDEF    = 5
  ACCURACY = 6
  EVASION  = 7
end

class PBWeather
  SUNNYDAY      = 1
  RAINDANCE     = 2
  SANDSTORM     = 3
  HAIL          = 4
  SHADOWSKY     = 5
  STRONGWINDS   = 6
end

class PBEnvironment
  None        = 0
  Grass       = 1
  TallGrass   = 2
  MovingWater = 3
  StillWater  = 4
  Underwater  = 5
  Rock        = 6
  Cave        = 7
  Sand        = 8
end

class PBEffects
  # These effects apply to a battler
  AquaRing          = 0
  Attract           = 1
  Bide              = 2
  BideDamage        = 3
  BideTarget        = 4
  Charge            = 5
  ChoiceBand        = 6
  Confusion         = 7
  Counter           = 8
  CounterTarget     = 9
  Curse             = 10
  DefenseCurl       = 11
  Disable           = 13
  DisableMove       = 14
  EchoedVoice       = 15
  Embargo           = 16
  Encore            = 17
  EncoreIndex       = 18
  EncoreMove        = 19
  Endure            = 20
  FlashFire         = 21
  Flinch            = 22
  FocusEnergy       = 23
  FollowMe          = 24
  Foresight         = 25
  FuryCutter        = 26
  FutureSight       = 27
  FutureSightPokemonIndex = 28
  FutureSightMove   = 29
  FutureSightUser   = 30
  GastroAcid        = 31
  Grudge            = 32
  HealBlock         = 33
  HealingWish       = 34
  HelpingHand       = 35
  HyperBeam         = 36
  Imprison          = 37
  Ingrain           = 38
  LeechSeed         = 39
  LockOn            = 40
  LockOnPos         = 41
  LunarDance        = 42
  MagicCoat         = 43
  MagnetRise        = 44
  MeanLook          = 45
  Metronome         = 46
  Minimize          = 47
  MiracleEye        = 48
  MirrorCoat        = 49
  MirrorCoatTarget  = 50
#    MudSport          = 51
  MultiTurn         = 52 # Trapping move
  MultiTurnAttack   = 53
  MultiTurnUser     = 54
  Nightmare         = 55
  Outrage           = 56
  PerishSong        = 57
  PerishSongUser    = 58
  Pinch             = 59 # Battle Palace only
  PowerTrick        = 60
  Protect           = 61
  ProtectNegation   = 62
  ProtectRate       = 63
  Pursuit           = 64
  Rage              = 65
  Revenge           = 66
  Rollout           = 67
  Roost             = 68
  SkyDrop           = 69
  SmackDown         = 70
  Snatch            = 71
  Stockpile         = 72
  StockpileDef      = 73
  StockpileSpDef    = 74
  Substitute        = 75
  Taunt             = 76
  Telekinesis       = 77
  Torment           = 78
  Toxic             = 79
  Trace             = 80
  Transform         = 81
  Truant            = 82
  TwoTurnAttack     = 83
  Uproar            = 84
#    WaterSport        = 85
  WeightMultiplier  = 86
  Wish              = 87
  WishAmount        = 88
  WishMaker         = 89
  Yawn              = 90  
  Illusion          = 91 #Illusion
  StickyWeb         = 101
  KingsShield       = 102
  SpikyShield       = 103
  FairyLockRate     = 107
  ParentalBond      = 108
  Round             = 109
  Powder            = 110
  Electrify         = 111
  MeFirst           = 112
  WideGuardCheck    = 113
  WideGuardUser     = 114  
  RagePowder        = 115
  MagicBounced      = 116
  TracedAbility     = 117
  UsingSubstituteRightNow = 118
  SkyDroppee         = 119
  DestinyRate        = 120
  BanefulBunker      = 121
  BeakBlast          = 122
  BurnUp             = 123
  ClangedScales      = 124
  LaserFocus         = 125
  ShellTrap          = 126
  SpeedSwap          = 127
  Tantrum            = 128
  ThroatChop         = 129
  Disguise           = 130
  ZHeal              = 131
  DestinyBond        = 132
  ShellTrapTarget    = 133
  Belch              = 134
  BouncedMove        = 135
  TrickedItem        = 136
  NoRetreat          = 137
  TarShot            = 138
  Octolock           = 139
  Obstruct           = 140
  BallFetch          = 141
  IceFace            = 142
  
  # These effects apply to a side
  LightScreen  = 200
  LuckyChant   = 201
  Mist         = 202
  Reflect      = 203
  Safeguard    = 204
  Spikes       = 205
  StealthRock  = 206
  Tailwind     = 207
  ToxicSpikes  = 208
  WideGuard    = 209
  QuickGuard   = 210
  Retaliate    = 211
  CraftyShield = 212
  MatBlock     = 213
  AuroraVeil   = 214
  
  # These effects apply to the battle (i.e. both sides) 
  Gravity           = 300
  MagicRoom         = 301
  WonderRoom        = 303
  #Terrain           = 304 retired.
  FairyLock         = 305
  IonDeluge         = 306
  # Additional weather effects
  HarshSunlight     = 307
  HeavyRain         = 308
  MudSport          = 309
  WaterSport        = 310
end

module PBNatures
  HARDY   = 0
  LONELY  = 1
  BRAVE   = 2
  ADAMANT = 3
  NAUGHTY = 4
  BOLD    = 5
  DOCILE  = 6
  RELAXED = 7
  IMPISH  = 8
  LAX     = 9
  TIMID   = 10
  HASTY   = 11
  SERIOUS = 12
  JOLLY   = 13
  NAIVE   = 14
  MODEST  = 15
  MILD    = 16
  QUIET   = 17
  BASHFUL = 18
  RASH    = 19
  CALM    = 20
  GENTLE  = 21
  SASSY   = 22
  CAREFUL = 23
  QUIRKY  = 24

  def PBNatures.maxValue; 24; end
  def PBNatures.getCount; 25; end

  def PBNatures.getName(id)
    names=[
       _INTL("Hardy"),
       _INTL("Lonely"),
       _INTL("Brave"),
       _INTL("Adamant"),
       _INTL("Naughty"),
       _INTL("Bold"),
       _INTL("Docile"),
       _INTL("Relaxed"),
       _INTL("Impish"),
       _INTL("Lax"),
       _INTL("Timid"),
       _INTL("Hasty"),
       _INTL("Serious"),
       _INTL("Jolly"),
       _INTL("Naive"),
       _INTL("Modest"),
       _INTL("Mild"),
       _INTL("Quiet"),
       _INTL("Bashful"),
       _INTL("Rash"),
       _INTL("Calm"),
       _INTL("Gentle"),
       _INTL("Sassy"),
       _INTL("Careful"),
       _INTL("Quirky")
    ]
    return names[id]
  end
end

class PBMonRoles
  SWEEPER         = 0
  PHYSICALWALL    = 1
  SPECIALWALL     = 2
  LEAD            = 3
  CLERIC          = 4
  PHAZER          = 5
  SCREENER        = 6
  REVENGEKILLER   = 7
  PIVOT           = 8
  SPINNER         = 9
  TANK            = 10
  BATONPASSER     = 11
  STALLBREAKER    = 12
  STATUSABSORBER  = 13
  TRAPPER         = 14
  WEATHERSETTER   = 15
  FIELDSETTER     = 16
  ACE             = 17
  SECOND          = 18
end
