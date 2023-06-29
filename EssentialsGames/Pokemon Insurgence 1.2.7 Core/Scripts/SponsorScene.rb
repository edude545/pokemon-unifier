################################################################################
# Scene class for handling appearance of the screen
################################################################################
class SponsorScene
# Processes the scene
  def pbChooseMove
    @sprites["msgwindow"].letterbyletter=false
    @sprites["msgwindow"].text=_INTL("Which company do you want to be sponsored by?")
    pbActivateWindow(@sprites,"list"){
       loop do
         Graphics.update
         Input.update
         oldIndex=@sprites["list"].index
         pbUpdate
         if oldIndex!=@sprites["list"].index
           pbRefreshInfo(@company[@sprites["list"].index])
         end
         if Input.trigger?(Input::B)
           # Process the B button here
           return nil
         end
         if Input.trigger?(Input::C)
           return @company[@sprites["list"].index]
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

  def pbRefreshInfo(company)
    text="<c2=318c675a><ac>"+_INTL("SPONSORSHIPS")+"</ac>\n\n"
    cName=company[0]
    cMinimum=company[1]
    cRatio=company[2]
    cOutput=company[3]
    if company!=0
      text+=_ISPRINTF(" "+cName+"\n\n Min. Races: "+cMinimum.to_s+"\n Min. Sponsorship Value: "+cRatio.to_s+"\n Money Multiplier: "+cOutput.to_s+"x")
       #  PBTypes.getName(movedata.type),
      #   movedata.basedamage<=1 ? movedata.basedamage==1 ? "???" : "---" : _ISPRINTF("{1:d}",movedata.basedamage),
     #    movedata.totalpp,
    #     movedata.accuracy==0 ? "---" : _ISPRINTF("{1:d}",movedata.accuracy));
     # text+="Yo"#\n<fn="+pbNarrowFontName()+">"+pbGetMessage(
         #MessageTypes::MoveDescriptions,move)+"</fs>"
    end
    @sprites["info"].text=text
  end

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { pbUpdate }
  end

  def pbStartScene(company)
    # Create sprite hash
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    moveCommands=[]
    company.each{|i| moveCommands.push(i[0]) }

    @company=company.clone
    moveCommands.push(_INTL("CANCEL"))
    @company.push(0)
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
    @sprites["msgwindow"].text=_INTL("Which company do you want to be sponsored by?")
    @sprites["msgwindow"].x=0
    @sprites["msgwindow"].y=Graphics.height-96
    @sprites["msgwindow"].width=Graphics.width
    @sprites["msgwindow"].height=96
    addBackgroundPlane(@sprites,"bg","relearnbg",@viewport)
    pbRefreshInfo(company[0])
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end



# Screen class for handling game logic
class SponsorScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    company=Kernel.getSortedLegalSponsorInfo
    if company.length==0
        Kernel.pbMessage("You have no willing sponsors...")
        return false
    end
    
 #   raise company.length.to_s
    @scene.pbStartScene(company)
    loop do
      move=@scene.pbChooseMove
      if move==nil || move[0]==0
        if @scene.pbConfirm(
          _INTL("Cancel receiving a sponsorship?"))
          @scene.pbEndScene
          return false
        end
      else
        if @scene.pbConfirm(_INTL("Get sponsored by "+move[0].to_s))
          $game_switches[376]=true
          $game_variables[129]=move
          $game_variables[130]=$game_variables[65]
            @scene.pbEndScene
            return true

          end
      end
    end
  end
end



def pbSponsorScreen
  retval=true
  pbFadeOutIn(99999){
     scene=SponsorScene.new
     screen=SponsorScreen.new(scene)
     retval=screen.pbStartScreen
  }
  return retval
end