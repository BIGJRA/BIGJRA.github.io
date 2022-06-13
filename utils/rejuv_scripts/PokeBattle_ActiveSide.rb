begin
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
      @effects[PBEffects::WideGuard]   = false # add this line
      @effects[PBEffects::QuickGuard]  = false # add this line
#### KUROTSUNE - 009 - START
      @effects[PBEffects::Retaliate]   = false
#### KUROTSUNE - 009 - END
#### KUROTSUNE - 016 - START
       @effects[PBEffects::CraftyShield] = false 
#### KUROTSUNE - 016 - END
#### KUROTSUNE - 025 - START
       @effects[PBEffects::MatBlock]     = false
#### KUROTSUNE - 025 - END
      @effects[PBEffects::StickyWeb]     = false
      @effects[PBEffects::AuroraVeil]    = 0
      @effects[PBEffects::AreniteWall]    = 0
      $belch=false
      $fepledgefield=0
      $feconversionuse=0      
    end
  end



  class PokeBattle_ActiveField
    attr_accessor :effects

    def initialize
      @effects = []
      # Azery - Overlay Terrains
      @effects[PBEffects::GrassyTerrain] = 0 
      @effects[PBEffects::MistyTerrain] = 0 
      @effects[PBEffects::ElectricTerrain] = 0
      @effects[PBEffects::PsychicTerrain] = 0
      @effects[PBEffects::Splintered] = 0 
      @effects[PBEffects::Rainbow] = 0
      ## Azery - end Overlay Terrains
      @effects[PBEffects::Gravity]     = 0
      @effects[PBEffects::MagicRoom]   = 0
      @effects[PBEffects::Terrain]     = 0
      @effects[PBEffects::FairyLock]   = 0
#### KUROTSUNE - 013 - START
      @effects[PBEffects::IonDeluge]   = 0
#### KUROTSUNE - 013 - END
      #@effects[PBEffects::TrickRoom]   = 0
      @effects[PBEffects::WonderRoom]   = 0
      @effects[PBEffects::MudSport]     = 0
      @effects[PBEffects::WaterSport]   = 0
#### KUROTSUNE - 001 - START
      @effects[PBEffects::HeavyRain]     = false
      @effects[PBEffects::HarshSunlight] = false
#### KUROTSUNE - 001 - END
    end
  end
rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  else
  end
end