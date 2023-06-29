
class PokemonMenu_Scene
  def pbShowCommands(commands)
    ret=-1
    cmdwindow=@sprites["cmdwindow"]
    cmdwindow.viewport=@viewport
    cmdwindow.index=$PokemonTemp.menuLastChoice
    cmdwindow.resizeToFit(commands)
    cmdwindow.commands=commands
    cmdwindow.x=Graphics.width-cmdwindow.width
    cmdwindow.y=0
    cmdwindow.visible=true
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::B)
        ret=-1
        break
      end
      if Input.trigger?(Input::C)
        ret=cmdwindow.index
        $PokemonTemp.menuLastChoice=ret
        break
      end
    end
    return ret
  end

  def sprites
    return @sprites
  end
  
  def pbShowInfo(text)
    @sprites["infowindow"].resizeToFit(text,Graphics.height)
    @sprites["infowindow"].text=text
    @sprites["infowindow"].visible=true
    @infostate=true
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.height)
    @sprites["helpwindow"].text=text
    @sprites["helpwindow"].visible=true
    @helpstate=true
    pbBottomLeft(@sprites["helpwindow"])
  end

  def pbStartScene
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    @sprites["cmdwindow"]=Window_CommandPokemon.new([])
    @sprites["infowindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["infowindow"].visible=false
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["helpwindow"].visible=false
    @sprites["cmdwindow"].visible=false
    @infostate=false
    @helpstate=false
    pbSEPlay("menu")
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible=false
    @sprites["infowindow"].visible=false
    @sprites["helpwindow"].visible=false
  end

  def pbShowMenu
    @sprites["cmdwindow"].visible=true
    @sprites["infowindow"].visible=@infostate
    @sprites["helpwindow"].visible=@helpstate
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh
  end
end



class PokemonMenu
  def initialize(scene)
    @scene=scene
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartPokemonMenu
    @scene.pbStartScene
    endscene=true
    pbSetViableDexes
    commands=[]
    cmdPokedex=-1
    cmdPokemon=-1
    cmdBag=-1
    cmdTrainer=-1
    cmdSave=-1
    cmdOption=-1
    cmdForfeit=-1
    cmdPokegear=-1
#    cmdNotebook=-1
    cmdDebug=-1
    cmdQuit=-1
    if !$Trainer
      if $DEBUG
        Kernel.pbMessage(_INTL("The player trainer was not defined, so the menu can't be displayed."))
        Kernel.pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    commands[cmdPokedex=commands.length]=_INTL("Pokédex") if $Trainer.pokedex && $PokemonGlobal.pokedexViable.length>0
    commands[cmdPokemon=commands.length]=_INTL("Pokémon") if $Trainer.party.length>0
    commands[cmdBag=commands.length]=_INTL("Bag") if !pbInBugContest?
    commands[cmdPokegear=commands.length]=_INTL("Dexnav (d)") if $Trainer.pokegear
   # commands[cmdNotebook=commands.length]=_INTL("Notebook") #if $Trainer.notebook
    commands[cmdTrainer=commands.length]=$Trainer.name
    if pbInSafari?
      if SAFARISTEPS<=0
        @scene.pbShowInfo(_INTL("Balls: {1}",pbSafariState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}",pbSafariState.steps,SAFARISTEPS,pbSafariState.ballcount))
      end
      commands[cmdQuit=commands.length]=_INTL("Quit")
    elsif pbInBugContest?
      if pbBugContestState.lastPokemon
        @scene.pbShowInfo(_INTL("Caught: {1}\nLevel: {2}\nBalls: {3}",
           PBSpecies.getName(pbBugContestState.lastPokemon.species),
           pbBugContestState.lastPokemon.level,
           pbBugContestState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Caught: None\nBalls: {1}",pbBugContestState.ballcount))
      end
      commands[cmdQuit=commands.length]=_INTL("Quit")
    else
      commands[cmdSave=commands.length]=_INTL("Save") if (!$game_system || !$game_system.save_disabled)
    end
    commands[cmdOption=commands.length]=_INTL("Options")
    commands[cmdForfeit=commands.length]=_INTL("Forfeit") if $game_switches[345] || $game_switches[346] || $game_switches[354] || $game_switches[355] || $game_switches[357] || $game_switches[584]
    commands[cmdDebug=commands.length]=_INTL("Debug") if $DEBUG
    commands[commands.length]=_INTL("Exit")
    loop do
      command=@scene.pbShowCommands(commands)
      if cmdPokedex>=0 && command==cmdPokedex
        if DEXDEPENDSONLOCATION
          pbFadeOutIn(99999) {
             scene=PokemonPokedexScene.new
             screen=PokemonPokedex.new(scene)
             screen.pbStartScreen
             @scene.pbRefresh
          }
        else
          if $PokemonGlobal.pokedexViable.length==1
            $PokemonGlobal.pokedexDex=$PokemonGlobal.pokedexViable[0]
            $PokemonGlobal.pokedexDex=-1 if $PokemonGlobal.pokedexDex==$PokemonGlobal.pokedexUnlocked.length-1
            pbFadeOutIn(99999) {
               scene=PokemonPokedexScene.new
               screen=PokemonPokedex.new(scene)
               screen.pbStartScreen
               @scene.pbRefresh
            }
          else
            pbLoadRpgxpScene(Scene_PokedexMenu.new)
          end
        end
      elsif cmdPokegear>=0 && command==cmdPokegear
        if $game_map.map_id==428 || $game_map.map_id==429 || $game_map.map_id==430 ||
           $game_map.map_id==431 || $game_map.map_id==491 || $game_map.map_id==771 || 
           $game_map.map_id==772 || $game_map.map_id==773 || $game_map.map_id==774
          Kernel.pbMessage("An electromagnetic pulse prevents use of the DexNav!")
        else
         #   pbLoadRpgxpScene(Scene_Pokegear.new)
          cmdwindow=@scene.sprites["cmdwindow"]
          cmdwindow.visible=false
          cmdwindow.update
          Graphics.update
          pbLoadRpgxpScene(Scene_DexNav.new,false)
          cmdwindow.visible=true
          cmdwindow.update
          Graphics.update
          @scene.pbRefresh
        #    @scene.pbEndScene
        #   $scene=Scene_Dexnav.new
        #  $scene.main
        #  elsif cmdNotebook >=0 && command==cmdNotebook
        #    pbLoadRpgxpScene(Scene_Notebook.new)
        end
      elsif cmdPokemon>=0 && command==cmdPokemon
        sscene=PokemonScreen_Scene.new
        sscreen=PokemonScreen.new(sscene,$Trainer.party)
        hiddenmove=nil
        pbFadeOutIn(99999) { 
           hiddenmove=sscreen.pbPokemonScreen
           if hiddenmove
             @scene.pbEndScene
           else
             @scene.pbRefresh
           end
        }
        if hiddenmove
          Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return
        end
      elsif cmdBag>=0 && command==cmdBag
        item=0
        scene=PokemonBag_Scene.new
        screen=PokemonBagScreen.new(scene,$PokemonBag)
        pbFadeOutIn(99999) { 
           item=screen.pbStartScreen 
           if item>0
             @scene.pbEndScene
           else
             @scene.pbRefresh
           end
        }
        if item>0
          Kernel.pbUseKeyItemInField(item)
          return
        end
      elsif cmdTrainer>=0 && command==cmdTrainer
        PBDebug.logonerr {
           scene=PokemonTrainerCardScene.new
           screen=PokemonTrainerCard.new(scene)
           pbFadeOutIn(99999) { 
              screen.pbStartScreen
              @scene.pbRefresh
           }
        }
      elsif cmdQuit>=0 && command==cmdQuit
        @scene.pbHideMenu
        if pbInSafari?
          if Kernel.pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
            @scene.pbEndScene
            $game_switches[121]=true
            pbSafariState.decision=1
            pbSafariState.pbGoToStart
            return
          else
            pbShowMenu
          end
        else
          if Kernel.pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
            @scene.pbEndScene
            pbBugContestState.pbStartJudging
            return
          else
            pbShowMenu
          end
        end
      elsif cmdSave>=0 && command==cmdSave
        @scene.pbHideMenu
        scene=PokemonSaveScene.new
        screen=PokemonSave.new(scene)
        if screen.pbSaveScreen
          @scene.pbEndScene
          endscene=false
          break
        else
          pbShowMenu
        end
      elsif cmdDebug>=0 && command==cmdDebug
        pbFadeOutIn(99999) { 
#        if ($Trainer.name == "Elise") || (Keys.press?(Keys::N6)) || (Keys.press?(Keys::N8))
           pbDebugMenu
           @scene.pbRefresh
 #        else
#                      $game_switches[307]=true
#           $has_hacked=true

#           Kernel.pbMessage("Hey assweed, stop trying to hack the game.")
  #       end
         
        }
      elsif cmdOption>=0 && command==cmdOption
        scene=PokemonOptionScene.new
        screen=PokemonOption.new(scene)
        pbFadeOutIn(99999) {
           screen.pbStartScreen
           pbUpdateSceneMap
           @scene.pbRefresh
        }
      elsif cmdForfeit>=0 && command==cmdForfeit
        challenges=[]
        challenges.push("PP Challenge") if $game_switches[345]
        challenges.push("Solorun") if $game_switches[346]
        challenges.push("Mystery Challenge") if $game_switches[354]
        challenges.push("Wonder Challenge") if $game_switches[583]
        challenges.push("Non-Technical Challenge") if $game_switches[355]
      #  challenges.push("Anti-ante") if $game_switches[356]
        challenges.push("Bravery Challenge") if $game_switches[357]
        challenges.push("Ironman Challenge") if $game_switches[584]
        challenges.push("(Cancel)")
        i=Kernel.pbMessage("Which challenge would you like to forfeit?",challenges)
        if challenges[i]=="PP Challenge"
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the PP Challenge?")
            Kernel.pbForfeitPPChallenge
                break
              else
                break
              end
        end
                if challenges[i]=="Solorun"
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the Solorun?")
            Kernel.pbForfeitSolorun
                break
              else
                break
              end
        end
        if challenges[i]=="Mystery Challenge"
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the Mystery Challenge?")
            Kernel.pbForfeitMystery
                break
              else
                break
              end
            end
            if challenges[i]=="Non-Technical Challenge"
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the Non-Technical Challenge?")
            Kernel.pbForfeitNonTechnical
                break
              else
                break
              end
            end
             if challenges[i]=="Anti-ante Challenge"
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the Anti-ante Challenge?")
            Kernel.pbForfeitAntiAnte
                break
              else
                break
              end
        end
if challenges[i]=="Bravery Challenge"
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the Bravery Challenge?")
            Kernel.pbForfeitBravery
                break
              else
                break
              end
        end
if challenges[i]=="Wonder Challenge"
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the Wonder Challenge?")
            Kernel.pbForfeitWonder
                break
              else
                break
              end
        end

        if i == 0 && $game_switches[345]
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the PP Challenge?")
            Kernel.pbForfeitPPChallenge
            break
          else
            break
          end
        end
        if i == 0 && $game_switches[584]
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the Ironman Challenge?")
            Kernel.pbForfeitIronman
            break
          else
            break
          end
        end
        if (i == 0 && !$game_switches[345] && $game_switches[346]) || (i == 1 && $game_switches[345]  && $game_switches[346])
          if Kernel.pbConfirmMessage("Are you sure you wish to forfeit the Solorun?")
            Kernel.pbForfeitSolorun
            break
          else
            break
          end
        end   
        break
      else
        break
      end
    end
    @scene.pbEndScene if endscene
  end  
end

def endSafariGame
  if Kernel.pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
    #        @scene.pbEndScene
    pbSafariState.decision=0
    $game_switches[121]=true
    pbSafariState.pbGoToStart
            
    #            return
    #   else
    #    pbShowMenu
  end
end
        
