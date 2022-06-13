class PokeBattle_DamageState
  attr_accessor :hplost          # HP lost by opponent, inc. HP lost by a substitute
  attr_accessor :critical        # Critical hit flag
  attr_accessor :calcdamage      # Calculated damage
  attr_accessor :typemod         # Type effectiveness
  attr_accessor :substitute      # A substitute took the damage
  attr_accessor :focusband       # Focus Band possible
  attr_accessor :focusbandused   # Focus Band actually used
  attr_accessor :focussash       # Focus Sash possible
  attr_accessor :focussashused   # Focus Sash used
  attr_accessor :sturdy          # Sturdy ability used
  attr_accessor :endured         # Damage was endured
  attr_accessor :pawnsturdy      # Focus Sash but for chess field
  attr_accessor :pawnsturdyused # pawn ability used

  def reset
    @hplost          = 0
    @critical        = false
    @calcdamage      = 0
    @typemod         = 0
    @substitute      = false
    @focusband       = false
    @focusbandused   = false
    @focussash       = false
    @focussashused   = false
    @pawnsturdy      = false
    @sturdy          = false
    @endured         = false
  end

  def initialize
    reset
    @pawnsturdyused  = false
  end
end