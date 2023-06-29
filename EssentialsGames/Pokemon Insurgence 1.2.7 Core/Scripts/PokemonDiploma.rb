#===============================================================================
# ** Scene_iPod
# ** Created by xLeD (Scene_Jukebox)
# ** Modified by Harshboy
#-------------------------------------------------------------------------------
#  This class performs menu screen processing.
#===============================================================================
class Scene_Diploma
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #-----------------------------------------------------------------------------
  # * Main Processing
  #-----------------------------------------------------------------------------
  def main

    # Make song command window
    fadein = true
    # Makes the text window
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["background"] = IconSprite.new(0,0)
    @sprites["background"].setBitmap("Graphics/Pictures/diploma.png")
    @sprites["background"].z=255
    @sprites["background"].zoom_x*=[1.0,1.5,2.0,2.5][$PokemonSystem.screensize]
    @sprites["background"].zoom_y*=[1.0,1.5,2.0,2.5][$PokemonSystem.screensize]

    @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Diploma"),
       2,-18,128,64,@viewport)
    @sprites["header"].baseColor=Color.new(248,248,248)
    @sprites["header"].shadowColor=Color.new(0,0,0)
    @sprites["header"].windowskin=nil

    @custom=false
    # Execute transition
    Graphics.transition
    # Main loop

    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    
    # Prepares for transition
    Graphics.freeze
    # Disposes the windows
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    # Update windows
    pbUpdateSpriteHash(@sprites)
      update_command
    return
  end
  #-----------------------------------------------------------------------------
  # * Frame Update (when command window is active)
  #-----------------------------------------------------------------------------

  def update_command

    # If B button was pressed
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      # Switch to map screen
      $scene = Scene_Pokegear.new
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Branch by command window cursor position
          pbPlayDecisionSE()
          $scene = Scene_Pokegear.new
      return
    end
  end
end