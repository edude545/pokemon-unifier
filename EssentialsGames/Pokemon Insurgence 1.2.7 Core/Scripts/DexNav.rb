#DEXNAV STUFF

Events.onWildPokemonCreate+=proc {|sender,e|
    pokemon=e[0]
=begin
c    datum=DexNav.getThisPokemonData
    if datum[0] != 0 && pokemon.species == datum[0]
      pokemon.makeShiny if datum[1]
      pokemon.level += datum[3]
      pokemon.resetMoves
      pokemon.calcStats
      if pokemon.moves.length<4
        pokemon.moves.push(datum[2])
      else
        pokemon.moves[rand(4)]=datum[2]
      end
    else
        $dexNavData=nil
    end
=end

    if $currentDexSearch != nil && $currentDexSearch.is_a?(Array)
      #Kernel.pbMessage("Worked.")
        pokemon.species=$currentDexSearch[0]
      #  Kernel.pbMessage($currentDexSearch[0].to_s)
        pokemon.level=pokemon.level
 #       pokemon.species=$currentDexSearch[0]
       pokemon.name=PBSpecies.getName(pokemon.species)
        pokemon.resetMoves
        
        pokemon.moves[2]=PBMove.new($currentDexSearch[1]) if $currentDexSearch[1]
        if $currentDexSearch[1] != $currentDexSearch[2]
          pokemon.moves[3]=PBMove.new($currentDexSearch[2]) if $currentDexSearch[2]
        end
        tempInt = $PokemonBag.pbQuantity(PBItems::SHINYCHARM)>0 ? 256 : 768
        if rand(tempInt)==1
         pokemon.makeShiny
       end

        $currentDexSearch = nil
    end
    

}

  class DexNavButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_accessor :selected

  def initialize(x,y,index=0,spriteloc="",viewport=nil)
    super(viewport)
    @index=index
    @selected=false
    @button=AnimatedBitmap.new("Graphics/Pictures/dexnav_"+spriteloc)
    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    update
  end

  def setBitmapNew(spriteloc)
    @button=AnimatedBitmap.new("Graphics/Pictures/dexnav_"+spriteloc)
    @contents=BitmapWrapper.new(@button.width,@button.height)
    self.bitmap=@contents
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
  end

  def update
    if self.selected
      self.src_rect.set(0,self.bitmap.height/2,self.bitmap.width,self.bitmap.height/2)
    else
      self.src_rect.set(0,0,self.bitmap.width,self.bitmap.height)
    end
    refresh
    super
  end
end
=begin
module Input  
 D = 43
 class << self
   alias old_self_button_to_key_shiney :buttonToKey
 end
 
 def self.buttonToKey(button)
   case button    
   when Input::D
     return [0x44] # K
   end 
   self.old_self_button_to_key_shiney(button)
 end
end
=end

#===============================================================================
# - Scene_Pokegear
#-------------------------------------------------------------------------------
# Modified By Harshboy
# Modified by Peter O.
# Also Modified By OblivionMew
# Overhauled by Maruno
#===============================================================================
class Scene_DexNav
  #-----------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------
  def initialize
    @menu_index=0
  end
  #-----------------------------------------------------------------------------
  # main
  #-----------------------------------------------------------------------------
  def main
    commands=[]
# OPTIONS - If you change these, you should also change update_command below.
    @cmdOverworld=-1
    @cmdMap=-1
    @cmdOnline=-1
    @cmdMemoryChamber=-1
    @index=0
    commands[@cmdOverworld=commands.length]=_INTL("Overworld")
    commands[@cmdMap=commands.length]=_INTL("Map")
    commands[@cmdOnline=commands.length]=_INTL("Online Play") 
    commands[@cmdMemoryChamber=commands.length]=_INTL("Memory Chamber") if $game_switches[130]
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @button=AnimatedBitmap.new("Graphics/Pictures/pokegearButton")
    @sprites={}
    @sprites["background"] = IconSprite.new(Graphics.width+26,240)
    @sprites["background"].setBitmap("Graphics/Pictures/dexnav_base")
    @sprites["command_window"] = Window_CommandPokemon.new(commands,160)
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].x = Graphics.width
    @sprites["command_window"].y = 0
    finalx0=120
    finalx1=250+52*2
    finalx2=250+52*3
    finalx3=250+52*4
  
    
    @sprites["button0"]=DexNavButton.new(finalx0+Graphics.width,246,0,"map",@viewport)
    @sprites["button0"].selected=false
    @sprites["button0"].update
    @sprites["button1"]=DexNavButton.new(finalx1+Graphics.width.floor,246,0,"button1idle",@viewport)
    @sprites["button1"].selected=false
    @sprites["button1"].update
    @sprites["button2"]=DexNavButton.new(finalx2+Graphics.width,246,0,"button2idle",@viewport)
    @sprites["button2"].selected=false
    @sprites["button2"].update
    @sprites["button3"]=DexNavButton.new(finalx3+Graphics.width,246,0,"button3idle",@viewport)
    @sprites["button3"].selected=false
    @sprites["button3"].update
    
    for i in 0..((Graphics.width/32).floor-1)
      @sprites["background"].x -= 32
      @sprites["button0"].x -= 32
      @sprites["button1"].x -= 32
      @sprites["button2"].x -= 32
      @sprites["button3"].x -= 32
      Graphics.update
      Input.update
      update
    end
    @sprites["background"].x=26
    @sprites["button0"].x = finalx0
    @sprites["button1"].x = finalx1
    @sprites["button2"].x = finalx2
    @sprites["button3"].x = finalx3
   
    
    @shouldBreak=false
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self# && @shouldBreak
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
   # for i in 0...@sprites["command_window"].commands.length
   #   sprite=@sprites["button#{i}"]
   #   sprite.selected=(i==@sprites["command_window"].index) ? true : false
   # end
    #update command window and the info if it's active
   # if @sprites["command_window"].active
      update_command
   #   return
   # end
  end
  #-----------------------------------------------------------------------------
  # update the command window
  #-----------------------------------------------------------------------------
  def update_command
    mousepos=Mouse::getMousePos
    prefix="Graphics/Pictures/dexnav_"
    if mousepos
      #OverWorld
      rect0=Rect.new(120,246,222,88)
      if rect0.contains(mousepos[0],mousepos[1])
        if Input.releaseex?(Input::LeftMouseKey)
          if $currentDexSearch != nil
            Kernel.pbMessage("You're already searching for one. Try having a look around!")
          else
            ary=DexNav.getPokemonInArea($game_map.map_id)
            ary=ary.select { |a| $Trainer.owned[a] }
            ary2=DexNav.getPokemonInArea($game_map.map_id)
            ary2=ary.select { |a| $Trainer.owned[a] }

            ary=ary.map { |a| PBSpecies.getName(a) }
            if ary.length == 0
              Kernel.pbMessage("No Pokemon data was found for this area.")
              Kernel.pbMessage("Catch Pokemon to have them appear here!")
            else
            ary.unshift("(Cancel)")
            val=Kernel.pbMessage("Select a Pokemon to filter for.",ary,0)
              if val!=0
                Kernel.pbMessage("Searching...")
                if rand(2) == 0
                   Kernel.pbMessage("Oh! A Pokemon was found nearby!")
                   species=ary2[val-1]
                   $currentDexSearch=[species,DexNav.addRandomEggMove(species),DexNav.addRandomEggMove(species)]
                   Kernel.pbMessage("Try looking in wild Pokemon spots near you- it might appear!")
                else
                   Kernel.pbMessage("Nothing was found. Try looking somewhere else!")
                end
              end
            end
          end
                  
        elsif Input.pressex?(Input::LeftMouseKey)
          @sprites["button0"].setBitmapNew("map")
        else
          @sprites["button0"].setBitmapNew("map")
        end
      else
        @sprites["button0"].setBitmapNew("map")
      end
      
      #Map
      rect1=Rect.new(354,246,48,88)
      if rect1.contains(mousepos[0],mousepos[1])
        if Input.releaseex?(Input::LeftMouseKey)
        pbShowMap(-1,false)
        elsif Input.pressex?(Input::LeftMouseKey)
          @sprites["button1"].setBitmapNew("button1click")
        else
          @sprites["button1"].setBitmapNew("button1hover")
        end
      else
        @sprites["button1"].setBitmapNew("button1idle")
      end
      
      #Online
      rect2=Rect.new(354+52,246,48,88)
      if rect2.contains(mousepos[0],mousepos[1])
        if Input.releaseex?(Input::LeftMouseKey)
         Kernel.tryConnect
        elsif Input.pressex?(Input::LeftMouseKey)
          @sprites["button2"].setBitmapNew("button2click")
        else
          @sprites["button2"].setBitmapNew("button2hover")
        end
      else
        @sprites["button2"].setBitmapNew("button2idle")
      end
      
      #Memory Chamber
      rect3=Rect.new(354+52+52,246,48,88)
      if rect3.contains(mousepos[0],mousepos[1])
        if Input.releaseex?(Input::LeftMouseKey)
        #  $scene=Scene_Thing.new
        array=Kernel.pbGetPokegearTrainers
        ary=[]
        for trainer in array
          string = PBTrainers.getName(trainer[0])+" "+trainer[1]
          ary.push(string)
        end
        ary.sort!
        $game_variables[184]=ary
        sortedArray=[]
        for i in 0..array.length-1
          for j in 0..ary.length-1
            if PBTrainers.getName(array[i][0])+" "+array[i][1] == ary[j]
                sortedArray[j]=array[i]
                break
            end
          end
        end
        $game_variables[183]=sortedArray
        #$PleaseTrigger=true
        #$scene=Scene_Map.new
        
        #if $PleaseTrigger!=nil && $PleaseTrigger==true
        #  $PleaseTrigger=nil
          var=Kernel.pbMessage("Which trainer would you like to battle? (Q and W to skip through list).",$game_variables[184])
          if Kernel.pbConfirmMessage("Are you sure you wish to battle this trainer?")
            pbTrainerBattle($game_variables[183][var][0],$game_variables[183][var][1],"...",false,0,
            false,true)
          else
          end
        #end
        return
        elsif Input.pressex?(Input::LeftMouseKey)
          @sprites["button3"].setBitmapNew("button3click")
        else
          @sprites["button3"].setBitmapNew("button3hover")
        end
      else
        @sprites["button3"].setBitmapNew("button3idle")
      end
    end

      
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      $scene=Scene_Map.new
      return
    end
#   if Input.trigger?(Input::C)
#      if @cmdMap>=0 && @sprites["command_window"].index==@cmdMap
#        pbPlayDecisionSE()
#        pbShowMap(-1,false)
#      end
#    end
  end
end








class DexNav
  
  # This method triggers every time the dexnav is used (1 more to the chain)
  # It recalculates the odds for a shiny, adds egg moves and so on
  # It updates into $dexNavData which is retrieved with getThisPokemonData
  def self.addToChain
    $dexNavData=[0,0,0] if !$dexNavData
    $dexNavData += 1
    if rand(8192/DexNav.getShinyMultiplier($dexNavData).floor)==0
      $dexNavData[1]=true
    end
    $dexNavData[2]=DexNav.addRandomEggMove(pokemon)
    $dexNavData[3]=DexNav.getAppropriateLevel($dexNavData)
  end
  
  def self.getAppropriateLevel(datum)
      return ((datum[0]%100)/5).floor
  end
  
  
  #This method just returns the temporary data for the next pokemon to be encountered.
  def self.getThisPokemonData
    $dexNavData=[0,0,0] if !$dexNavData
    return $dexNavData 
  end
  
  
=begin

  def isGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight] ||
            @enctypes[EncounterTypes::BugContest]) ? true : false
  end

  def isWater?
    return false if @density==nil
    return @enctypes[EncounterTypes::Water] ? true : false
  end

  def isEncounterPossibleHere?
    if $PokemonGlobal && $PokemonGlobal.surfing
      return true
    elsif pbGetTerrainTag($game_player)==PBTerrain::Ice
      return false
    elsif self.isCave?
      return true
    elsif self.isGrass?
      return pbIsGrassTag?($game_map.terrain_tag($game_player.x,$game_player.y))
    else
      return false
    end



=end
  # Returns an array of available pokemon species in a map
  def self.getPokemonInArea(map_id)
    
          data=load_data("Data/encounters.dat")
      if data.is_a?(Hash) && data[map_id]
        #Pokemon were found.
        #raise("1")
        density=data[map_id][0]
        enctypes=data[map_id][1]
      else
        density=nil
        enctypes=[]
      end
    speciesAry=[]
    for i in 0..15
      
      if [EncounterTypes::Land,EncounterTypes::LandMorning,EncounterTypes::LandDay,
      EncounterTypes::LandNight].include?(i) && ($PokemonGlobal.surfing || $PokemonGlobal.fishing)
        next
      end
      if [EncounterTypes::Water].include?(i) && !$PokemonGlobal.surfing
        next
        end
      
      if enctypes[i] && enctypes[i].is_a?(Array) && enctypes[i][0]
        tempAry=[]
        for j in 0..99
          
          v=enctypes[i][j]
          
          tempAry.push(v[0]) if v && v[0] && !tempAry.include?(v[0])
        end
        speciesAry.push(tempAry)
      end
    end
    newAry=[] 
    for i in speciesAry
      for j in i
        newAry.push(j)
        #   Kernel.pbMessage(speciesAry.index(i).to_s+" "+j.to_s)
      end
    end
    
    return newAry
  end
  
  # This method gets the appropriate shiny rate multiplier for a certain chain value
  def self.getShinyMultiplier(datum)
    value=1
    if datum[0]<80
      return value*datum[0]
    else
      return 80
    end
  end
  
  # This method gets a random ID of a legal egg move and returns it as a move object.
  def self.addRandomEggMove(species)
    moves=[]
    pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
     f.pos=(species-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         atk=f.fgetw
         moves.push(atk)
         i+=1
       end
     end
  }
    moveid=moves[rand(moves.length)]
    
    return moveid
  end
end

  
  