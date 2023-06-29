#11045744
begin
  class PBWeather
    SUNNYDAY    = 1
    RAINDANCE   = 2
    SANDSTORM   = 3
    HAIL        = 4
    NEWMOON     = 5
    HARSHSUN    = 6
    HEAVYRAIN   = 7
    STRONGWINDS = 9

  end

  rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  else
  end
end