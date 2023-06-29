#============================================================================
# Add-on for H-Mode7 Engine
# V.1.1 - 10/01/2011
# Author : MGC
#
# This add-on reorients the direction controls when the map is rotated.
# This is a request from Kristovki.
#============================================================================
module Input
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  class << self
    unless @already_aliased_hm7
      alias dir4_hm7_input dir4
      alias dir8_hm7_input dir8
      @already_aliased_hm7 = true
    end
  end
  #--------------------------------------------------------------------------
  # * Dir4
  #--------------------------------------------------------------------------
  Left = [6, 2, 8, 4]
  def self.dir4
    unless $game_system.hm7
      return dir4_hm7_input
    end
    input_value = dir4_hm7_input
    unless input_value == 0
      case $game_system.hm7_theta
      when 45...135
        camera_direction = 4
      when 135...225
        camera_direction = 2
      when 225...315
        camera_direction = 6
      else
        camera_direction = 8
      end
      case camera_direction
      when 2
        input_value = 10 - input_value
      when 4
        input_value = 10 - Left[(input_value >> 1) - 1]
      when 6
        input_value = Left[(input_value >> 1) - 1]
      when 8
        input_value = input_value
      end
    end
    return input_value
  end
  #--------------------------------------------------------------------------
  # * Dir8 - V.1.1
  #--------------------------------------------------------------------------
  Dir8_Index = [0, 5, 4, 3, 6, 0, 2, 7, 0, 1]
  Dir8_Left = [8, 9, 6, 3, 2, 1, 4, 7]
  def self.dir8
    unless $game_system.hm7
      return dir8_hm7_input
    end
    input_value = dir8_hm7_input
    unless input_value == 0
      offset = (($game_system.hm7_theta + 23) / 45) % 8
      input_value = Dir8_Left[(Dir8_Index[input_value] + offset) % 8]
    end
    return input_value
  end
end