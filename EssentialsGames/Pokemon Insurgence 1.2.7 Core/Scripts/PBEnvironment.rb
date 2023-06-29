#52687037
begin
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
    Forest      = 9
    Snow        = 10
    Volcano     = 11
    Sky         = 12
    Space       = 13
  end

  rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  else
  end
end