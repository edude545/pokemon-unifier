class PokemonSaveScene
  def pbStartScreen
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    mapname=$game_map.name
    textColor=["0070F8,78B8E8","E82010,F8A8B8","0070F8,78B8E8"][$Trainer.gender]
    loctext=_INTL("<ac><c2=06644bd2>{1}</c2></ac>",mapname)
    loctext+=_INTL("Player<r><c3={1}>{2}</c3><br>",textColor,$Trainer.name)
    loctext+=_ISPRINTF("Time<r><c3={1:s}>{2:02d}:{3:02d}</c3><br>",textColor,hour,min)
    loctext+=_INTL("Badges<r><c3={1}>{2}</c3><br>",textColor,$Trainer.numbadges)
    if $Trainer.pokedex
      loctext+=_INTL("Pokédex<r><c3={1}>{2}/{3}</c3>",textColor,$Trainer.pokedexOwned,$Trainer.pokedexSeen)
    end
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=0
    @sprites["locwindow"].width=228 if @sprites["locwindow"].width<228
    @sprites["locwindow"].visible=true
  end

  def pbEndScreen
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



def pbEmergencySave
  oldscene=$scene
  $scene=nil
  if !$startmetricget
    Kernel.pbMessage(_INTL("The script is taking too long.  The game will restart."))
    Kernel.pbMessage(_INTL("If this crash occurred during a battle and you are using animated sprites, consider reverting them to static versions."))
    Kernel.pbMessage(_INTL("If this crash occurred while going online or looking for M. Gifts, the server may be down."))
    Kernel.pbMessage(_INTL("Remember that as of patch 1.2.5, this script no longer saves the game in order to prevent players from getting stuck in events or corrupting saves."))
    Kernel.pbMessage(_INTL("We apologize for any inconvenience this crash may have caused, but remember to Quick Save often!"))
  else
    Kernel.pbMessage(_INTL("The game cannot connect to the internet for metrics."))
    Kernel.pbMessage(_INTL("Either you are not connected or  this game doesn't have permission."))
    Kernel.pbMessage(_INTL("Please assure you are properly connected before getting Gym metrics again."))
    Kernel.pbMessage(_INTL("The game will restart."))
  end
=begin
  if $game_variables[96] == 0 && safeExists?(RTP.getSaveFileName("Game.rxdata"))
    File.open(RTP.getSaveFileName("Game.rxdata"),  'rb') {|r|
       File.open(RTP.getSaveFileName("Game.rxdata.bak"), 'wb') {|w|
          while s = r.read(4096)
            w.write s
          end
       }
    }
    end
      if $game_variables[96] != 0 && safeExists?(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata"))
    File.open(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata"),  'rb') {|r|
       File.open(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata.bak"), 'wb') {|w|
          while s = r.read(4096)
            w.write s
          end
       }
    }
  end
=end
=begin
  if pbSave
    Kernel.pbMessage(_INTL("\\se[]The game was saved.\\se[save]\\wtnp[30]")) 
  else
    Kernel.pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]")) if !$game_switches[136]
  end
=end
  $scene=oldscene
end


=begin


File.rename(RTP.getSaveFileName("Autosave_Temporary.rxdata"), RTP.getSaveFileName("Game.rxdata")) if $game_variables[96]==0
  File.rename(RTP.getSaveFileName("Autosave_Temporary.rxdata"), RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata")) if $game_variables[96]!=0

=end

def pbSave(safesave=false)
  if $game_switches[136]
    return false
  end
  
  if $game_variables[96] == 0
      File.delete(RTP.getSaveFileName("Save_0_Backup_3.rxdata")) if File.exist?(RTP.getSaveFileName("Save_0_Backup_3.rxdata"))
  File.rename(RTP.getSaveFileName("Save_0_Backup_2.rxdata"), RTP.getSaveFileName("Save_0_Backup_3.rxdata")) if File.exist?(RTP.getSaveFileName("Save_0_Backup_2.rxdata"))
  File.rename(RTP.getSaveFileName("Save_0_Backup_1.rxdata"), RTP.getSaveFileName("Save_0_Backup_2.rxdata")) if File.exist?(RTP.getSaveFileName("Save_0_Backup_1.rxdata"))
  File.rename(RTP.getSaveFileName("Game.rxdata"), RTP.getSaveFileName("Save_0_Backup_1.rxdata")) if File.exist?(RTP.getSaveFileName("Game.rxdata"))
  begin
    File.open(RTP.getSaveFileName("Game.rxdata"),"wb"){|f|
       Marshal.dump($Trainer,f)
       Marshal.dump(Graphics.frame_count,f)
       if $data_system.respond_to?("magic_number")
         $game_system.magic_number = $data_system.magic_number
       else
         $game_system.magic_number = $data_system.version_id
       end
       $game_system.save_count+=1
       Marshal.dump($game_system,f)
       Marshal.dump($PokemonSystem,f)
       Marshal.dump($game_map.map_id,f)
       Marshal.dump($game_switches,f)
       Marshal.dump($game_variables,f)
       Marshal.dump($game_self_switches,f)
       Marshal.dump($game_screen,f)
       Marshal.dump($MapFactory,f)
       Marshal.dump($game_player,f)
       $PokemonGlobal.safesave=safesave
       Marshal.dump($PokemonGlobal,f)
       Marshal.dump($PokemonMap,f)
       Marshal.dump($PokemonBag,f)
       Marshal.dump($PokemonStorage,f)
    }
    Graphics.frame_reset
    rescue
    return false
  end
#        if safeExists?(savefile)
#      begin
#        trainer, framecount, $game_system, $PokemonSystem, mapid=pbTryLoadFile(savefile)
#        showContinue=true
#      rescue

else
  File.delete(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_3.rxdata")) if File.exist?(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_3.rxdata"))
  File.rename(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_2.rxdata"), RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_3.rxdata")) if File.exist?(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_2.rxdata"))
  File.rename(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_1.rxdata"), RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_2.rxdata")) if File.exist?(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_1.rxdata"))
  File.rename(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata"), RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_1.rxdata")) if File.exist?(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata"))
  begin
    File.open(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata"),"wb"){|f|
       Marshal.dump($Trainer,f)
       Marshal.dump(Graphics.frame_count,f)
       if $data_system.respond_to?("magic_number")
         $game_system.magic_number = $data_system.magic_number
       else
         $game_system.magic_number = $data_system.version_id
       end
       $game_system.save_count+=1
       Marshal.dump($game_system,f)
       Marshal.dump($PokemonSystem,f)
       Marshal.dump($game_map.map_id,f)
       Marshal.dump($game_switches,f)
       Marshal.dump($game_variables,f)
       Marshal.dump($game_self_switches,f)
       Marshal.dump($game_screen,f)
       Marshal.dump($MapFactory,f)
       Marshal.dump($game_player,f)
       $PokemonGlobal.safesave=safesave
       Marshal.dump($PokemonGlobal,f)
       Marshal.dump($PokemonMap,f)
       Marshal.dump($PokemonBag,f)
       Marshal.dump($PokemonStorage,f)
    }
    Graphics.frame_reset
    rescue
    return false
  end
end

  return true
  end
def pbAutosave(safesave=false)
  if $game_switches[136]
    return false
  end
  begin
    File.open(RTP.getSaveFileName("Autosave_Temporary.rxdata"),"wb"){|f|
       Marshal.dump($Trainer,f)
       Marshal.dump(Graphics.frame_count,f)
       if $data_system.respond_to?("magic_number")
         $game_system.magic_number = $data_system.magic_number
       else
         $game_system.magic_number = $data_system.version_id
       end
       $game_system.save_count+=1
       Marshal.dump($game_system,f)
       Marshal.dump($PokemonSystem,f)
       Marshal.dump($game_map.map_id,f)
       Marshal.dump($game_switches,f)
       Marshal.dump($game_variables,f)
       Marshal.dump($game_self_switches,f)
       Marshal.dump($game_screen,f)
       Marshal.dump($MapFactory,f)
       Marshal.dump($game_player,f)
       $PokemonGlobal.safesave=safesave
       Marshal.dump($PokemonGlobal,f)
       Marshal.dump($PokemonMap,f)
       Marshal.dump($PokemonBag,f)
       Marshal.dump($PokemonStorage,f)
    }
    Graphics.frame_reset
    rescue
    return false
  end
 # Kernel.pbMessage("hey")
  File.delete(RTP.getSaveFileName("Game.rxdata")) if $game_variables[96]==0
  File.delete(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata")) if $game_variables[96]!=0
  File.rename(RTP.getSaveFileName("Autosave_Temporary.rxdata"), RTP.getSaveFileName("Game.rxdata")) if $game_variables[96]==0
  File.rename(RTP.getSaveFileName("Autosave_Temporary.rxdata"), RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata")) if $game_variables[96]!=0
  return true
end

class PokemonSave
  def initialize(scene)
    @scene=scene
  end

  def pbDisplay(text,brief=false)
    @scene.pbDisplay(text,brief)
  end

  def pbDisplayPaused(text)
    @scene.pbDisplayPaused(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  def pbSaveScreen
    ret=false
 
      
    if $game_switches[163]
        Kernel.pbMessage(_INTL("Autosave is on! Turn it off before manually saving."))
        return false
    end
    
    if $game_switches[675]
      if !$game_switches[676]
        Kernel.pbMessage(_INTL("You exited the game in the middle of a challenge."))
        Kernel.pbMessage(_INTL("Sorry but your challenge has been cancelled."))
        Kernel.dropRank
        $game_switches[675]=false
        return false
      else
        $game_switches[676]=false
      end
    end
    
    @scene.pbStartScreen
    if Kernel.pbConfirmMessage(_INTL("Would you like to save the game?"))
      if ($game_variables[96]==0 && safeExists?(RTP.getSaveFileName("Game.rxdata"))) || ($game_variables[96]!=0 && safeExists?(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata")))
        confirm=""
        if $PokemonTemp.begunNewGame
          Kernel.pbMessage(_INTL("WARNING!"))
          Kernel.pbMessage(_INTL("There is a different game file that is already saved."))
          Kernel.pbMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost."))
          if !Kernel.pbConfirmMessageSerious(
             _INTL("Are you sure you want to save now and overwrite the other save file?"))
            @scene.pbEndScreen
            return false
          end
        else
          if !Kernel.pbConfirmMessage(
             _INTL("There is already a saved file.  Is it OK to overwrite it?"))
            @scene.pbEndScreen
            return false
          end
        end
      end
      $PokemonTemp.begunNewGame=false
      if pbSave
        Kernel.pbMessage(_INTL("\\se[]{1} saved the game. Don't forget, you can press V to Quicksave!\\se[save]\\wtnp[30]",$Trainer.name))
        ret=true
      else
        Kernel.pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]")) if !$game_switches[136]
        ret=false
      end
    end
    @scene.pbEndScreen
    return ret
  end
end