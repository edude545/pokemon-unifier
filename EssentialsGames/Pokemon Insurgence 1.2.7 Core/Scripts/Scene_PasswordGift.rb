#============================================================================#
#                   !!EDIT ONLY IF YOU KNOW WHAT YOU DO!!                    #
#============================================================================#

#=============================================================================
# Scene_PasswordGift
#-----------------------------------------------------------------------------
# The core of the whole script
# minlength = minimum of letters or symbols to enter
# maxlength = maximum of letters or symbols to enter
#=============================================================================
class Scene_PasswordGift
  #---------------------------------------------------------------------------
  # initialize
  #---------------------------------------------------------------------------
  def initialize(minlength = 1, maxlength = 12)
    enterPassword(minlength, maxlength)
  end
  
  #---------------------------------------------------------------------------
  # getPassword
  #---------------------------------------------------------------------------
  def enterPassword(minlength, maxlength)
    password = pbEnterText(_INTL("Enter the password"),minlength,maxlength)
    if password.scan(/\r/) == ["\r"]
      slicing = password.size - 1
      password.slice!(slicing)
    end
    if Password::Gifts.include?(password)
      if $game_switches[Password::Gifts[password][1]] == true
        Kernel.pbMessage(_INTL("Password already used"))
      else
        Kernel.pbMessage(_INTL("Correct password!"))
        if Password::Gifts[password][2] == true
          Kernel.pbAddPokemon(Password::Gifts[password][0], Password::Gifts[password][3])
        else
          Kernel.pbReceiveItem(Password::Gifts[password][0])
        end
        if Password::Gifts[password][1] != nil
          $game_switches[Password::Gifts[password][1]] = true
        end
      end
    else
      Kernel.pbMessage(_INTL("Incorrect password."))
    end
  end
end