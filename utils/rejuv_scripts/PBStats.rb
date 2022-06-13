begin
  class PBStats
    HP       = 0
    ATTACK   = 1
    DEFENSE  = 2
    SPEED    = 3
    SPATK    = 4
    SPDEF    = 5
    ACCURACY = 6
    EVASION  = 7  end
rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  else
  end
end