#============================================================================
# ** HM7::Tilemap
#----------------------------------------------------------------------------
# This new Tilemap class handles the drawing of a HM7 map
#============================================================================
module HM7
  class Tilemap
    #--------------------------------------------------------------------------
    # * Aliased methods (F12 compatibility)
    #--------------------------------------------------------------------------
    unless @already_aliased_hm7_test
      alias update_hm7_test_tilemap update
      @already_aliased_hm7_test = true
    end
    #--------------------------------------------------------------------------
    # * Update
    #--------------------------------------------------------------------------
    def update
      if $game_variables[157]==100

               set_theta(90)
      $game_variables[157]=101
    end
    
=begin
    if $game_variables[157]==1
      to_alpha(50, 1)
      $game_variables[157]=2
    end
    if $game_variables[157]==3
      to_theta(0,1,4)
            $game_variables[157]=4

    end
    
      
      
=end
      
      if $game_variables[159]==1 && $game_variables[158]>0
          increase_theta(-3)
          $game_variables[158] -= 1
      end
      if $game_variables[159]==2 && $game_variables[158]>0
          increase_alpha(2)
          $game_variables[158] -= 1
      end
      if $game_variables[159]==3 && $game_variables[158]>0
          increase_zoom(3)
        
          $game_variables[158] -= 1
      end
      
      if $game_variables[159]==4 && $game_variables[158]>0
          increase_theta(-1)
          $game_variables[158] -= 1
      end
      
      
      
      if Input.press?(Input::F5)
        increase_alpha(1)
      elsif Input.press?(Input::F6)
        increase_alpha(-1)
      elsif Input.press?(Input::L)
        increase_theta(2)
      elsif Input.press?(Input::R)
        increase_theta(-2)
      elsif Input.press?(Input::T) #f7
        increase_zoom(-5)
      elsif Input.press?(Input::U) #f8
        increase_zoom(5)
      end
      update_hm7_test_tilemap
    end
  end
end