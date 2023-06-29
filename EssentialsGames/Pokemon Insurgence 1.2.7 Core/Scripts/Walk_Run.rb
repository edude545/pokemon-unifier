class Game_Player
  def fullPattern
    case self.direction
      when 2
        return self.pattern
      when 4
        return 4+self.pattern
      when 6
        return 8+self.pattern
      when 8
        return 12+self.pattern
      else
        return 0
    end
  end

  def setDefaultCharName(chname,pattern)
    return if pattern<0 || pattern>=16
    @defaultCharacterName=chname
    @direction=[2,4,6,8][pattern/4]
    @pattern=pattern%4
  end

  def pbCanRun?
return ($game_switches[86] && !Input.press?(Input::A) ||
       (!$game_switches[86] && Input.press?(Input::A))) &&
       $PokemonGlobal && $PokemonGlobal.runningShoes &&
       !pbMapInterpreterRunning? && !@move_route_forcing && 
       !$PokemonGlobal.diving && !$PokemonGlobal.surfing &&
       !$PokemonGlobal.bicycle
  end

  def pbIsRunning?
    return !moving? && !@move_route_forcing && $PokemonGlobal && pbCanRun?
  end

  def runClothesCheck
    return !moving? && !@move_route_forcing && $PokemonGlobal && pbCanRun? && Input.dir4!=0
  end
  
  def character_name
    if !@defaultCharacterName
      @defaultCharacterName=""
    end
    if @defaultCharacterName!=""
      return @defaultCharacterName
    end
    if !moving? && !@move_route_forcing && $PokemonGlobal
      meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
      
      if $PokemonGlobal.playerID>=0 && meta && !$PokemonTemp.miniupdate &&
         !$PokemonGlobal.bicycle && !$PokemonGlobal.diving && !$PokemonGlobal.surfing
         if $game_switches[136]
           #@character_name=sprintf("%03d",$game_variables[1].species)
         elsif meta[4] && meta[4]!="" && Input.dir4!=0 && pbCanRun?
          # Display running character sprite
          @character_name=meta[4]
        else
          # Display normal character sprite 
          @character_name=meta[1]
        end
      end
    end
    return @character_name
  end

  alias update_old update

  def update
    if !moving? && !@move_route_forcing && $PokemonGlobal
      if $PokemonGlobal.bicycle
        @move_speed = $RPGVX ? 8 : 5.8
     #   @move_speed = (@move_speed*1.5)
      elsif $PokemonGlobal.surfing
        @move_speed = 4.3
        
        elsif pbCanRun? && !$game_switches[136]
        @move_speed = $RPGVX ? 6.5 : 4.8
      elsif $game_switches[136]
        @move_speed = $RPGVX ? 5 : 4.2
      else
        @move_speed = $RPGVX ? 4.5 : 3.8
      end
    end
    if $game_map.map_id==397 && $PokemonGlobal.bicycle && $game_map.terrain_tag($game_player.x,$game_player.y)==PBTerrain::SuperFastBike
        @move_speed *= 1.75
    end
    if $game_map.map_id==676 || $game_map.map_id==749
        @move_speed *= 1.2
    end
    
    if $game_switches[136] && pbIsGrassTag?($game_map.terrain_tag($game_player.x,$game_player.y))
      @move_speed=3.3
    end
    if $game_switches[136] && $game_variables[63].is_a?(Array) && $game_variables[63][0]>0
      @move_speed*=1.25
    end
    
    if $game_map.map_id==272 && $game_player.y>36 && $game_player.y<50
      if $game_player.direction==2
        @move_speed *=1.25
      elsif $game_player.direction==8
        @move_speed *= 0.88
      end
      
    end
    
    if $game_map.map_id==272 && $game_player.y<62 && $game_player.y>51
      if $game_player.direction==2
       @move_speed *=0.88
        
      elsif $game_player.direction==8
        @move_speed *= 1.25
      end
    end
    
    @move_speed
    update_old
  end
end



class Game_Character
  alias update_old2 update

  def update
    if self.is_a?(Game_Event)
      if @dependentEvents
        for i in 0...@dependentEvents.length
          if @dependentEvents[i][0]==$game_map.map_id &&
             @dependentEvents[i][1]==self.id &&
             @move_speed=$game_player.move_speed
            break
          end
        end
      end
    end
    update_old2
  end
end