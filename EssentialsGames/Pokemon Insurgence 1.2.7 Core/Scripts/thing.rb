=begin
#===============================================================================
# ** Essentials full screen
# by Luka S.J.
#-------------------------------------------------------------------------------
# Enters your game into a new full screen mode
# Size depends on your display's resolution, as the game will only resize
# itself if the resize factor is an integer. Screen is resized and then
# centered on the display
#===============================================================================
DISABLERMXPFULL = true # Disables the old Alt+Enter full screen
# If you're using the new full screen option, make sure to leave this
# constant as true, because RMXP's full screen will mess up this new method
if DISABLERMXPFULL
  regHotKey = Win32API.new('user32', 'RegisterHotKey', 'LIII', 'I')
  regHotKey.call(0, 1, 1, 0x0D)
end
#-------------------------------------------------------------------------------
#  Win32API functions that get rid of the window border, resize the window
#  to fit the screen, and reposition it
#-------------------------------------------------------------------------------
class Win32API
  def Win32API.focusWindow
    window = Win32API.new('user32', 'ShowWindow', 'LL' ,'L')
    hWnd = pbFindRgssWindow
    window.call(hWnd, 9)
  end
  
  def Win32API.fillScreen
    setWindowLong = Win32API.new('user32', 'SetWindowLong', 'LLL', 'L')
    setWindowPos = Win32API.new('user32', 'SetWindowPos', 'LLIIIII', 'I')
    metrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
    hWnd =  pbFindRgssWindow
    width = metrics.call(0)
    height = metrics.call(1)
    setWindowLong.call(hWnd, -16, 0x00000000)
    setWindowPos.call(hWnd, 0, 0, 0, width, height, 0)
    Win32API.focusWindow
    return [width,height]
  end
  
  def Win32API.restoreScreen    
    setWindowLong = Win32API.new('user32', 'SetWindowLong', 'LLL', 'L')
    setWindowPos = Win32API.new('user32', 'SetWindowPos', 'LLIIIII', 'I')
    metrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
    hWnd =  pbFindRgssWindow
    width = DEFAULTSCREENWIDTH*$ResizeFactor
    height = DEFAULTSCREENHEIGHT*$ResizeFactor
    x = (metrics.call(0)-width)/2
    y = (metrics.call(1)-height)/2
    setWindowLong.call(hWnd, -16, 0x14CA0000)
    setWindowPos.call(hWnd, 0, x, y, width+6, height+29, 0)
    Win32API.focusWindow
    return [width,height]
  end
  
  def Win32API.SetWindowPos(w,h); return; end
end
#-------------------------------------------------------------------------------
#  Viewport fix for the LocationWindow class
#-------------------------------------------------------------------------------
class LocationWindow
  alias initialize_org initialize
  def initialize(name)
    initialize_org(name)
    @window.viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  end
end
#-------------------------------------------------------------------------------
#  Pokegear fix
#-------------------------------------------------------------------------------
class Scene_Pokegear
  alias main_org main
  def main
    $trick = true
    main_org
    $trick = false
  end
end

class Window_CommandPokemon
  alias initialize_org initialize
  def initialize(*args)
    initialize_org(*args)
    self.visible = false if $trick
  end
end
#-------------------------------------------------------------------------------
#  Fixes default transitions capping at 640 x 480
#-------------------------------------------------------------------------------
module Graphics
  class << self
    alias transition_org transition
  end
  
  def self.transition(duration = 8, *args)
    if duration > 0
      transition_org(0)
      bmp = self.snap_to_bitmap
      viewport = Viewport.new(0, 0, self.width, self.height)
      sprite = Sprite.new(viewport)
      sprite.bitmap = bmp
      fade = 255 / duration
      duration.times { sprite.opacity -= fade ; update }
      [sprite, sprite.bitmap].each {|obj| obj.dispose }
    end
    transition_org(0)
end
end  
#-------------------------------------------------------------------------------
#  Additional options to the menu to enter full screen and quit game
#-------------------------------------------------------------------------------
class PokemonMenu_Scene
  alias pbShowCommands_org pbShowCommands
  def pbShowCommands(commands)
    commands.insert(commands.length-1,"Quit Game") if $PokemonSystem.screensize==3 && !commands.include?("Quit Game")
    ret=pbShowCommands_org(commands)
    if ret==(commands.index("Quit Game"))
      raise SystemExit.new
    end
    if ret==(commands.index("Fullscreen"))
      configureScreen
    end
    return ret
  end
end
#-------------------------------------------------------------------------------
#  Disables screen resizing in the options menu
#-------------------------------------------------------------------------------
class EnumOption
  alias initialize_org initialize
  def initialize(name,options,getProc,setProc)
    initialize_org(name,options,getProc,setProc)
    if name=="Screen Size"
      @values=[_INTL("Small"),_INTL("Med"),_INTL("Large"),_INTL("Full")]
      @getProc=proc { $PokemonSystem.screensize }
      @setProc=proc {|value|
        oldvalue=$PokemonSystem.screensize
        if value < 3
          configureDefaultScreen(value)
          if value!=oldvalue
            ObjectSpace.each_object(TilemapLoader){|o| next if o.disposed?; o.updateClass }
          end
        elsif value==3
          $PokemonSystem.screensize = value
          configureFullScreen
          if value!=oldvalue
            ObjectSpace.each_object(TilemapLoader){|o| next if o.disposed?; o.updateClass }
          end
        end
      }
    end
    
  end
end

alias pbSetResizeFactor_full pbSetResizeFactor
def pbSetResizeFactor(dummy=nil)
  value = $PokemonSystem.screensize
  if value < 3
    configureDefaultScreen(value)
  else
    configureFullScreen
  end
end
#-------------------------------------------------------------------------------
#  Method to call and enter full screen
#-------------------------------------------------------------------------------
def configureFullScreen
  params = Win32API.fillScreen
  factor_x = params[0]/DEFAULTSCREENWIDTH
  factor_y = params[1]/DEFAULTSCREENHEIGHT
  factor = [factor_x,factor_y].min
  remain = params[0]%DEFAULTSCREENWIDTH
  offset_x = (remain>0) ? (params[0]-DEFAULTSCREENWIDTH*factor)/factor*0.5 : 0
  offset_y = (remain>0) ? (params[1]-DEFAULTSCREENHEIGHT*factor)/factor*0.5 : 0
  $ResizeOffsetX = offset_x
  $ResizeOffsetY = offset_y
  ObjectSpace.each_object(Viewport){|o|
    begin
      next if o.rect.nil?
      ox = o.rect.x-$ResizeOffsetX
      oy = o.rect.y-$ResizeOffsetY
      o.rect.x = ox+offset_x
      o.rect.y = oy+offset_y
      rescue RGSSError
    end
  }
  pbSetResizeFactor_full(factor)
end

def configureDefaultScreen(value)
  $ResizeOffsetX=0
  $ResizeOffsetY=0
  if $PokemonSystem.screensize==3
    ObjectSpace.each_object(Viewport){|o|
      begin
        next if o.rect.nil?
        ox = o.rect.x-$ResizeOffsetX
        oy = o.rect.y-$ResizeOffsetY
        o.rect.x = ox
        o.rect.y = oy
        rescue RGSSError
      end
    }
  end
  $PokemonSystem.screensize=value
  pbSetResizeFactor_full([0.5,1.0,2.0][value])
  Win32API.restoreScreen
end
=end