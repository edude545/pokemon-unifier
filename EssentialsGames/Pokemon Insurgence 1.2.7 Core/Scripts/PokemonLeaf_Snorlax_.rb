  class LeafButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,place,name="",index=0,viewport=nil)
    super(viewport)
    @index=index
    @name=name
    @selected=false
      @button=AnimatedBitmap.new(place)

    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    update
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def refresh
    self.bitmap.clear
      if $game_variables[5]==@index
  
        self.bitmap.blt(0,0,@button.bitmap,Rect.new(@button.width/3,0,@button.width/3,@button.height))
    else
            if $game_variables[171][@index]
      self.bitmap.blt(0,0,@button.bitmap,Rect.new(0,0,@button.width/3,@button.height))

      else
        self.bitmap.blt(0,0,@button.bitmap,Rect.new(2*@button.width/3,0,@button.width/3,@button.height))
        
      end
      
    end
    
    #    pbSetSystemFont(self.bitmap)
    
  #
 # pbDrawImagePositions(self.bitmap,imagepos)
  end

  def update
    if self.selected
      self.src_rect.set(0,self.bitmap.height/2,self.bitmap.width,self.bitmap.height/2)
    else
      self.src_rect.set(0,0,self.bitmap.width,self.bitmap.height/2)
    end
    
    refresh
    super
  end
end



#===============================================================================
# - Scene_Pokegear
#-------------------------------------------------------------------------------
# Modified By Harshboy
# Modified by Peter O.
# Also Modified By OblivionMew
# Overhauled by Maruno
#===============================================================================
class Scene_Leaf
  #-----------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #-----------------------------------------------------------------------------
  # main
  #-----------------------------------------------------------------------------
  def main
    commands=[]
# OPTIONS - If you change these, you should also change update_command below.
    @cmdSpring=-1
    @cmdSummer=-1
    @cmdFall=-1
    @cmdWinter=-1
    @cmdSakura=-1

    commands[@cmdSpring=commands.length]=_INTL("Cult Information")
    commands[@cmdSummer=commands.length]=_INTL("Character Information")
    commands[@cmdFall=commands.length]=_INTL("Character Information")
    commands[@cmdWinter=commands.length]=_INTL("Character Information")
    commands[@cmdSakura=commands.length]=_INTL("Character Information")
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @button0=AnimatedBitmap.new("Graphics/Pictures/springHover")
    @button1=AnimatedBitmap.new("Graphics/Pictures/summerHover")
    @button2=AnimatedBitmap.new("Graphics/Pictures/fallHover")
    @button3=AnimatedBitmap.new("Graphics/Pictures/winterHover")
    @button5=AnimatedBitmap.new("Graphics/Pictures/sakuraHover")

    @sprites={}
    @sprites["background"] = IconSprite.new(0,0)
#    femback=pbResolveBitmap(sprintf("Graphics/Pictures/pokegearbgf"))
      @sprites["background"].setBitmap("Graphics/Pictures/snorlaxBG")
    @sprites["command_window"] = Window_CommandPokemon.new(commands,160)
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].x = Graphics.width
    @sprites["command_window"].y = 0
    tempary=["Graphics/Pictures/springHover","Graphics/Pictures/summerHover",
    "Graphics/Pictures/fallHover","Graphics/Pictures/winterHover",
    "Graphics/Pictures/sakuraHover"]
    for i in 0...commands.length
      x=96
      y=192 - (commands.length*32) + (i*64)
      @sprites["button#{i}"]=LeafButton.new(x,y,tempary[i],commands[i],i,@viewport)
      @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
#          @sprites["button#{i}"].bitmap.blt(40,64,icon.bitmap,Rect.new(32,32*i,32,32))
      
      @sprites["button#{i}"].update
    end
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
  end
  #-----------------------------------------------------------------------------
  # update the scene
  #-----------------------------------------------------------------------------
  def update
    pbUpdateSpriteHash(@sprites)
    for i in 0...@sprites["command_window"].commands.length
      sprite=@sprites["button#{i}"]
      sprite.selected=(i==@sprites["command_window"].index) ? true : false
    end
    #update command window and the info if it's active
    if @sprites["command_window"].active
      update_command
      return
    end
  end
  #-----------------------------------------------------------------------------
  # update the command window
  #-----------------------------------------------------------------------------
  def update_command
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      $game_variables[5]=-1
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::C)
      if @cmdSpring>=0 && @sprites["command_window"].index==@cmdSpring
        if $game_variables[171][0]
          pbPlayDecisionSE()
          $game_variables[5]=0
                $scene = Scene_Map.new
              end
              
        
      end
      if @cmdSummer>=0 && @sprites["command_window"].index==@cmdSummer
if $game_variables[171][1]
          pbPlayDecisionSE()
          $game_variables[5]=1
                $scene = Scene_Map.new
              end        
      end
      if @cmdFall>=0 && @sprites["command_window"].index==@cmdFall
if $game_variables[171][2]
          pbPlayDecisionSE()
          $game_variables[5]=2
                $scene = Scene_Map.new
              end        
      end
      if @cmdWinter>=0 && @sprites["command_window"].index==@cmdWinter
if $game_variables[171][3]
          pbPlayDecisionSE()
          $game_variables[5]=3
                $scene = Scene_Map.new
              end        
      end
      if @cmdSakura>=0 && @sprites["command_window"].index==@cmdSakura
if $game_variables[171][4]
          pbPlayDecisionSE()
          $game_variables[5]=4
                $scene = Scene_Map.new
              end        
      end

      end
  end
end

