  class ThingButton < SpriteWrapper
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
class Scene_Thing
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

    commands[@cmdCult=commands.length]=_INTL("Battle a trainer.")
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
      @sprites["button#{i}"]=ThingButton.new(x,y,commands[i],i,@viewport)
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
                array=Kernel.pbGetPokegearTrainers
        ary=[]
        for trainer in array
          string = PBTrainers.getName(trainer[0])+" "+trainer[1]
          ary.push(string)
        end
        ary.sort!
        sortedArray=[]
        for i in 0..array.length-1
          for j in 0..ary.length-1
            if PBTrainers.getName(array[i][0])+" "+array[i][1] == ary[j]
                sortedArray[j]=array[i]
                break
            end
          end
        end
        
        var=Kernel.pbMessage("Which trainer would you like to battle? (Q and W to skip through list).",ary)
        if Kernel.pbConfirmMessage("Are you sure you wish to battle this trainer?")
          $scene=Scene_Map.new
          pbTrainerBattle(sortedArray[var][0],sortedArray[var][1],"...",false,0,
          false,true)
        else
        end

      end
      
    end
  end
end

def pbGetPokegearTrainers
  newAry=[]
  trainers=load_data("Data/trainers2.dat")
  for trainer in trainers
    trainerToPush=Array.new
    trainerToPush[0]=trainer[0]
    trainerToPush[1]=trainer[1]
    trainerToPush[2]=trainer[3]
    newAry.push(trainerToPush)
  end
  return newAry
end


def pbLoadPokegearTrainerData(trainerid,trainername,partyid=0)
  ret=nil
  trainers=load_data("Data/trainers2.dat")
  for trainer in trainers
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    if trainerid==thistrainerid && name==trainername# && partyid==thispartyid
      ret=trainer
      Kernel.pbMessage(trainer[3].to_s)
      break
    end
  end
  return ret
end
