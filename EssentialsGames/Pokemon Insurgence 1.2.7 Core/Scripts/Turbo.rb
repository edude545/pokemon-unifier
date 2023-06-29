=begin
#########################################
# Turbo Speed Script by Pia Carrot      #
# Released March 19th, 2012             #  
#########################################
# Instructions:                         #
# Though it's rather self explanatory,  # 
# this little snippet:                  #
#          if $game_switches[42]        #
# Can be changed to whatever you please,#
# even something other than a switch.   #
#                                       #
# Credits: Maruno, Pia Carrot           #
# Why Maruno? Shiny Pokémon Reference,  #
# current Pokémon Essentials Owner      # 
#########################################

class Game_System
  alias upd_old_speedup update
  def update
    turboboost = Input.trigger?(Input::I)
  #  $game_switches[40] = turboboost
   if $game_switches[40]
      Graphics.frame_rate = 160
    else
     Graphics.frame_rate = 40
    end
    upd_old_speedup
    end
end



 MoveSelectionSprite < SpriteWrapper

  def update
   # turboboost = Input.trigger?(Input::I)
  #  $game_switches[40] = turboboost
    if $game_switches[40]
      Graphics.frame_rate = 40
    else
      Graphics.frame_rate = 40
    end
    upd_old_speedup
  end
=begin
class PokeBattle_Battler
  
  def update
         turboboost = Input.trigger?(Input::I)
    $game_switches[40] = turboboost
    if $game_switches[40]
      Graphics.frame_rate = 160
    else
      Graphics.frame_rate = 40
    end
    upd_old_speedup
  end

end

class PokeBattle_ActiveSide
  
  def update
        turboboost = Input.trigger?(Input::I)
    $game_switches[40] = turboboost
    if $game_switches[40]
      Graphics.frame_rate = 160
    else
      Graphics.frame_rate = 40
    end
    upd_old_speedup
  end
end
=end
