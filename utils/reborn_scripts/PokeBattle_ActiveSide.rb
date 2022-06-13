class PokeBattle_ActiveSide
  attr_accessor :effects

  def initialize
    @effects = []
    @effects[PBEffects::LightScreen] = 0
    @effects[PBEffects::LuckyChant]  = 0
    @effects[PBEffects::Mist]        = 0
    @effects[PBEffects::Reflect]     = 0
    @effects[PBEffects::Safeguard]   = 0
    @effects[PBEffects::Spikes]      = 0
    @effects[PBEffects::StealthRock] = false
    @effects[PBEffects::Tailwind]    = 0
    @effects[PBEffects::ToxicSpikes] = 0
    @effects[PBEffects::WideGuard]   = false
    @effects[PBEffects::QuickGuard]  = false
    @effects[PBEffects::Retaliate]   = false
    @effects[PBEffects::CraftyShield]= false 
    @effects[PBEffects::MatBlock]    = false
    @effects[PBEffects::StickyWeb]   = false
    @effects[PBEffects::AuroraVeil]  = 0
  end
end

class PokeBattle_GlobalEffects
  attr_accessor :effects
  def initialize
    #Global effects
    @effects = []
    @effects[PBEffects::Gravity]            = 0
    @effects[PBEffects::MagicRoom]          = 0
    @effects[PBEffects::FairyLock]          = 0
    @effects[PBEffects::IonDeluge]          = 0
    @effects[PBEffects::WonderRoom]         = 0
    @effects[PBEffects::MudSport]           = 0
    @effects[PBEffects::WaterSport]         = 0
    @effects[PBEffects::HeavyRain]          = false
    @effects[PBEffects::HarshSunlight]      = false
  end
end
