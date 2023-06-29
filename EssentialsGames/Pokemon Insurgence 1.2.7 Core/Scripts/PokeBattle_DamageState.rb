class PokeBattle_DamageState
  attr_accessor :hplost # HP lost by opponent, including HP lost by Substitute
  attr_accessor :critical # Critical hit flag
  attr_accessor :calcdamage # Calculated damage
  attr_accessor :typemod # Type effectiveness
  attr_accessor :substitute # A Substitute took the damage
  attr_accessor :focusband # Focus Band possible
  attr_accessor :focusbandused # Focus Band actually used
  attr_accessor :focussash # Focus Sash possible
  attr_accessor :focussashused # Focus Sash used
  attr_accessor :sturdy # Sturdy ability used
  attr_accessor :endured # Damage was endured
  attr_accessor :berryweakened # A type-resisting berry was used
  attr_accessor :gemused # A gem was used

  def reset
    @hplost        = 0
    @critical      = false
    @calcdamage    = 0
    @typemod       = 0
    @substitute    = false
    @focusband     = false
    @focusbandused = false
    @focussash     = false
    @focussashused = false
    @sturdy        = false
    @endured       = false
    @berryweakened = false
    @gemused       = false
  end

  def initialize
    reset
  end
end