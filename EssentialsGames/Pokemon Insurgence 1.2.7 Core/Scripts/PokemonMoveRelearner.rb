def pbEachNaturalMove(pokemon)
  movelist=pokemon.getMoveList
  for i in movelist
    yield i[1],i[0]
  end
end

def pbHasRelearnableMove?(pokemon)
  return pbGetRelearnableMoves(pokemon).length>0
end

def pbGetRelearnableMoves(pokemon)
  return [] if !pokemon || pokemon.egg? || (pokemon.isShadow? rescue false)
  moves=[]
  pbEachNaturalMove(pokemon){|move,level|
    if level<=pokemon.level && !pbHasMove?(pokemon,move)
      moves.push(move)
    end
  }
  return moves|[] if pokemon.eggmovesarray == nil
  for i in pokemon.eggmovesarray
    if !pbHasMove?(pokemon,i.id)
      moves.push(i.id)
    end
  end
  
  return moves|[] # remove duplicates
end



################################################################################
# Scene class for handling appearance of the screen
################################################################################
class MoveRelearnerScene
# Processes the scene
  def pbChooseMove
    @sprites["msgwindow"].letterbyletter=false
    @sprites["msgwindow"].text=_INTL("Teach which move to {1}?",@pokemon.name)
    pbActivateWindow(@sprites,"list"){
       loop do
         Graphics.update
         Input.update
         oldIndex=@sprites["list"].index
         pbUpdate
         if oldIndex!=@sprites["list"].index
           pbRefreshInfo(@moves[@sprites["list"].index])
         end
         if Input.trigger?(Input::B)
           # Process the B button here
           return 0
         end
         if Input.trigger?(Input::C)
           return @moves[@sprites["list"].index]
         end
       end
    }
  end

# Update the scene here, this is called once each frame
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

# End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate } # Fade out all sprites
    pbDisposeSpriteHash(@sprites) # Dispose all sprites
    @viewport.dispose # Dispose the viewport
  end

  def pbRefreshInfo(move)
    text="<c2=318c675a><ac>"+_INTL("BATTLE MOVES")+"</ac>\n\n"
    movedata=PBMoveData.new(move)
    if move!=0
      text+=_ISPRINTF(" {1:s}<r>POWER/{2:s}\n PP/{3:d}<r>ACCURACY/{4:s}",
         PBTypes.getName(movedata.type),
         movedata.basedamage<=1 ? movedata.basedamage==1 ? "???" : "---" : _ISPRINTF("{1:d}",movedata.basedamage),
         movedata.totalpp,
         movedata.accuracy==0 ? "---" : _ISPRINTF("{1:d}",movedata.accuracy));
      text+="\n<fn="+pbNarrowFontName()+">"+pbGetMessage(
         MessageTypes::MoveDescriptions,move)+"</fs>"
    end
    @sprites["info"].text=text
  end

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { pbUpdate }
  end

  def pbStartScene(pokemon,moves)
    # Create sprite hash
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    moveCommands=[]
    moves.each{|i| moveCommands.push(PBMoves.getName(i)) }
    @moves=moves.clone
    moveCommands.push(_INTL("CANCEL"))
    @moves.push(0)
    @pokemon=pokemon
    @sprites["list"]=Window_CommandPokemonEx.new(moveCommands)
    @sprites["list"].x=Graphics.width-192
    @sprites["list"].y=0
    @sprites["list"].width=192
    @sprites["list"].height=Graphics.height-96
    @sprites["list"].viewport=@viewport
    @sprites["info"]=Window_AdvancedTextPokemon.new("")
    @sprites["info"].width=Graphics.width-192
    @sprites["info"].height=Graphics.height-96
    @sprites["info"].viewport=@viewport
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=true
    @sprites["msgwindow"].viewport=@viewport
    @sprites["msgwindow"].text=_INTL("Teach which move to {1}?",pokemon.name)
    @sprites["msgwindow"].x=0
    @sprites["msgwindow"].y=Graphics.height-96
    @sprites["msgwindow"].width=Graphics.width
    @sprites["msgwindow"].height=96
    addBackgroundPlane(@sprites,"bg","relearnbg",@viewport)
    pbRefreshInfo(moves[0])
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end



# Screen class for handling game logic
class MoveRelearnerScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(pokemon)
    moves=pbGetRelearnableMoves(pokemon)
    
    @scene.pbStartScene(pokemon,moves)
    loop do
      move=@scene.pbChooseMove
      if move<=0
        if @scene.pbConfirm(
          _INTL("Give up trying to teach a new move to {1}?",pokemon.name))
          @scene.pbEndScene
          return false
        end
      else
        if @scene.pbConfirm(_INTL("Teach {1}?",PBMoves.getName(move)))
          if pbLearnMove(pokemon,move)
            @scene.pbEndScene
            return true
          end
        end
      end
    end
  end
end



def pbRelearnMoveScreen(pokemon)
  retval=true
  pbFadeOutIn(99999){
     scene=MoveRelearnerScene.new
     screen=MoveRelearnerScreen.new(scene)
     retval=screen.pbStartScreen(pokemon)
  }
  return retval
end