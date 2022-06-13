#11045744
begin
  class PBWeather
    SUNNYDAY      = 1
    RAINDANCE     = 2
    SANDSTORM     = 3
    HAIL          = 4
#### AME - 002 - START
    SHADOWSKY     = 5
    STRONGWINDS   = 6
#### AME - 002 - END
  end

  rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  else
  end
end