class AromaSwitch
end

    def switchToAroma
      if $game_switches[228]
          return
      end
      
      if $game_switches[227]
          Kernel.pbMessage("You are already in the Aroma Region!")
          return
      end
      if $game_variables[61]==0
      pbRemoveDependencies
    end
   #   Kernel.pbMessage("\pn arrived at the Aroma Region.")
      $game_variables[57] = $Trainer.party
      $Trainer.party = Array.new
      $Trainer.party = $game_variables[58] if $game_variables[58] != 0 && $game_variables[58] != nil
      
      $game_variables[59] = $PokemonStorage
      $PokemonStorage = PokemonStorage.new
      $PokemonStorage = $game_variables[60] if $game_variables[60] != 0 && $game_variables[60] != nil
      $game_switches[227]=true
      
    end
    
    def switchToVesryn
      if $game_switches[228]
          return
      end
      if !$game_switches[227]
          Kernel.pbMessage("You are already in the Vesryn Region!")
          return
        end
        if $game_variables[61]==0
      pbRemoveDependencies
    end
    
 #     Kernel.pbMessage("\pn arrived at the Vesryn Region.")
      $game_variables[58] = $Trainer.party
      $Trainer.party = Array.new
      $Trainer.party = $game_variables[57] 
      
      $game_variables[60] = $PokemonStorage
      $PokemonStorage = PokemonStorage.new
      $PokemonStorage = $game_variables[59]
            $game_switches[227]=false
          

    end
