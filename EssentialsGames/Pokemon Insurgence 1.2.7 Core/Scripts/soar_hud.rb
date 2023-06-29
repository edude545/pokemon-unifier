module Soar_Window
  # Window's horizontal position
  WINDOW_X = 0
  # Window's vertical position
  WINDOW_Y = 420
  # Window's width
  WINDOW_WIDTH = 160
  # Window's height
  WINDOW_HEIGHT = 64
  # Default hide status of the window (true = hidden, false = visible)
  DEFAULT_HIDE = false
  
  @hide = DEFAULT_HIDE
  def self.hidden?
    return @hide
  end
  def self.hide
    @hide = !@hide
  end
end
#==============================================================================
# ** Window_Gold_HUD
#------------------------------------------------------------------------------
#  This window displays amount of gold.
#==============================================================================
class Window_Soar_HUD < SpriteWindow_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
super(0, 0, 160, 64)
self.contents = Bitmap.new(width - 32, height - 32)
refresh
end
#--------------------------------------------------------------------------
# * Gold graphic 
#--------------------------------------------------------------------------
def draw_soar_pic(actor, x, y)
bitmap = RPG::Cache.picture("gold")
sw = bitmap.width
sh = bitmap.height
src_rect = Rect.new(0, 0, sw, sh)
self.contents.blt(x, y, bitmap, src_rect)
end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
      self.contents.clear
    if $game_map.map_id==676 || $game_map.map_id==749
        $tempMap="" if !$tempMap
              #if @old_soar != $tempMap || @old_hide != Soar_Window.hidden?
            self.opacity = Soar_Window.hidden? ? 0 : 150
            @text_opacity = Soar_Window.hidden? ? 0 : 255
          cx = contents.text_size("Doop").width
          draw_soar_pic(@actor, 112, 10) 
          
          self.contents.draw_text(4, 0, 120-cx-2+40, 32, $tempMap, 2)
          @old_soar = $tempMap
          @old_hide = Soar_Window.hidden?
    #    end
    
      else
          self.opacity=0
      end
      
  end
end
#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs map screen processing.
#==============================================================================
class Scene_Map
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  alias soar_hud_main main
  def main
    @soar_window = Window_Soar_HUD.new
    soar_hud_main
    @soar_window.dispose    
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias soar_hud_update update
  def update
    @soar_window.refresh
    soar_hud_update
  end
end