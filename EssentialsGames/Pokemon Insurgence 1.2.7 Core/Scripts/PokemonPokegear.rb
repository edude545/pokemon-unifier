  class PokegearButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,name="",index=0,viewport=nil)
    super(viewport)
    @index=index
    @name=name
    @selected=false
    fembutton=pbResolveBitmap(sprintf("Graphics/Pictures/pokegearButtonf"))
    if $Trainer.gender==1 && fembutton
      @button=AnimatedBitmap.new("Graphics/Pictures/pokegearButtonf")
    else
      @button=AnimatedBitmap.new("Graphics/Pictures/pokegearButton")
    end
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
    self.bitmap.blt(0,0,@button.bitmap,Rect.new(0,0,@button.width,@button.height))
    pbSetSystemFont(self.bitmap)
    textpos=[          # Name is written on both unselected and selected buttons
       [@name,self.bitmap.width/2,10,2,Color.new(248,248,248),Color.new(40,40,40)],
       [@name,self.bitmap.width/2,62,2,Color.new(248,248,248),Color.new(40,40,40)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
    icon=sprintf("Graphics/Pictures/pokegear"+@name)
    imagepos=[         # Icon is put on both unselected and selected buttons
       [icon,18,10,0,0,-1,-1],
       [icon,18,62,0,0,-1,-1]
    ]
    pbDrawImagePositions(self.bitmap,imagepos)
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
class Scene_Pokegear
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
    @cmdMap=-1
    @cmdPhone=-1
    @cmdJukebox=-1
    @cmdOnline=-1
    @cmdDiploma=-1
    @cmdThing=-1

    commands[@cmdMap=commands.length]=_INTL("Map")
    commands[@cmdPhone=commands.length]=_INTL("Phone") if $PokemonGlobal.phoneNumbers &&
                                                          $PokemonGlobal.phoneNumbers.length>0
    commands[@cmdJukebox=commands.length]=_INTL("Jukebox") if $game_switches[130]
    commands[@cmdOnline=commands.length]=_INTL("Online Play") 
    commands[@cmdThing=commands.length]=_INTL("Memory Chamber") if $game_switches[130]
    commands[@cmdDiploma=commands.length]=_INTL("Diploma") if $game_switches[337]

    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @button=AnimatedBitmap.new("Graphics/Pictures/pokegearButton")
    @sprites={}
    @sprites["background"] = IconSprite.new(0,0)
    femback=pbResolveBitmap(sprintf("Graphics/Pictures/pokegearbgf"))
    if $Trainer.gender==1 && femback
      @sprites["background"].setBitmap("Graphics/Pictures/pokegearbgf")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/pokegearbg")
    end
    @sprites["command_window"] = Window_CommandPokemon.new(commands,160)
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].x = Graphics.width
    @sprites["command_window"].y = 0
    for i in 0...commands.length
      x=118
      y=196 - (commands.length*24) + (i*48)
      @sprites["button#{i}"]=PokegearButton.new(x,y,commands[i],i,@viewport)
      @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
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
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::C)
      if @cmdMap>=0 && @sprites["command_window"].index==@cmdMap
        pbPlayDecisionSE()
        pbShowMap(-1,false)
      end
      if @cmdPhone>=0 && @sprites["command_window"].index==@cmdPhone
        pbPlayDecisionSE()
        pbFadeOutIn(99999) {
           PokemonPhoneScene.new.start
        }
      end
      if @cmdJukebox>=0 && @sprites["command_window"].index==@cmdJukebox
        pbPlayDecisionSE()
        $scene = Scene_Jukebox.new
        end
      if @cmdOnline>=0 && @sprites["command_window"].index==@cmdOnline
        pbPlayDecisionSE()
        tryConnect
      end
 if @cmdThing>=0 && @sprites["command_window"].index==@cmdThing
        pbPlayDecisionSE()
        $scene = Scene_Thing.new
      end
      if @cmdDiploma>=0 && @sprites["command_window"].index==@cmdDiploma

        pbPlayDecisionSE()
        showDiploma
        end

      return
    end
  end
  def showDiploma

    $scene = Scene_Diploma.new
    end
    
  def tryConnect
     if $game_switches[321] || $game_switches[356] || $game_switches[346] || $game_switches[347]
      Kernel.pbMessage("The Challenge Mode you are on cannot go online.")
      $scene=Scene_Map.new      
    else

    $scene=Connect.new
end
  end
end


