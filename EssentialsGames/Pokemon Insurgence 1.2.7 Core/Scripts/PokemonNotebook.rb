  class NotebookButton < SpriteWrapper
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
class Scene_Notebook
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
    @cmdCult=-1
    @cmdChar=-1

    commands[@cmdCult=commands.length]=_INTL("Cult Information")
    commands[@cmdChar=commands.length]=_INTL("Character Information")
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
      @sprites["button#{i}"]=NotebookButton.new(x,y,commands[i],i,@viewport)
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
      if @cmdCult>=0 && @sprites["command_window"].index==@cmdCult
        pbPlayDecisionSE()
        array=[]
        array.push("(Cancel)")
        array.push("Cult of Darkrai")
        array.push("Perfection")
        array.push("Abyssal Cult")
        array.push("Sky Cult")
        array.push("Infernal Cult")
        int=Kernel.pbMessage("Which cult would you like to read about?",array)
        if array[int]=="(Cancel)"
          break
        elsif array[int]=="Cult of Darkrai"
          Kernel.pbMessage("I woke up in the lair of this cult. They seemed to know me, but I don't know them. They wanted to wipe my memories, but I escaped. They seem to be after Darkrai.")          
        elsif array[int]=="Perfection"
          Kernel.pbMessage("The leader of this cult offered me several different Pokemon to be used as a starter: and they were all \"Delta Pokemon\".")          
          Kernel.pbMessage("I also met one of their agents in the Suntouched City Gym, when they attacked Orion and tried to capture Reshiram.") if $game_switches[74]
          Kernel.pbMessage("I found them a third time, in one of their bases, underneath Helios City. I battled their admin, and their leader gave me a Mega Ring for them to research with.") if $game_switches[64]
          Kernel.pbMessage("They don't seem to be as bad as the other cults. As long as I don't cross them, I should be OK.")          
        elsif array[int]=="Abyssal Cult"
           Kernel.pbMessage("I haven't met this group yet.") if !$game_switches[53]        
           Kernel.pbMessage("A member from this group attacked the Augur in Telnor Town. They're dressed in blue and seem to have something to do with Kyogre.") if $game_switches[53]        
           Kernel.pbMessage("I also met them in the Ancient Ruins, near Midna Town, where they were looking for a Mega-Evolving Lucario.") if $game_switches[53]        
       elsif array[int]=="Sky Cult"
        elsif array[int]=="Infernal Cult"          
        end
        
        
        
      end
      if @cmdChar>=0 && @sprites["command_window"].index==@cmdChar
        pbPlayDecisionSE()
      end
    end
  end
end

