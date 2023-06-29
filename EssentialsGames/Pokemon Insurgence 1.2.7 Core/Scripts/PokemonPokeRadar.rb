class PokemonGlobalMetadata
  attr_accessor :pokeradarBattery
end



class PokemonTemp
  attr_accessor :pokeradar   # [species, level, chain count, grasses]
end



EncounterModifier.register(proc {|encounter|
   if $PokemonTemp.pokeradar
     if !$PokemonEncounters.isGrass? || 
        !$PokemonEncounters.isEncounterPossibleHere?()
       pbPokeRadarCancel
       return encounter
     end
     grasses=$PokemonTemp.pokeradar[3]
     if $PokemonEncounters.stepcount<=3
       $PokemonTemp.pokeradar=nil if encounter
       return encounter
     end
     for grass in grasses
       if $game_player.x==grass[0] && $game_player.y==grass[1]
         enc=$PokemonEncounters.pbEncounteredPokemon($PokemonEncounters.pbEncounterType)
         if $PokemonTemp.pokeradar[2]>0
           v=rand(100)
           if v<95
             enc=[$PokemonTemp.pokeradar[0],$PokemonTemp.pokeradar[1]]
           else
             $PokemonTemp.pokeradar=nil
           end
         end
         return enc
       end
     end
   end
   $PokemonTemp.pokeradar=nil if encounter
   return encounter
})

def pbPokeRadarCancel
  if $PokemonTemp.pokeradar
    if $PokemonTemp.pokeradar[2] && $PokemonTemp.pokeradar[2]>0
      $PokemonTemp.pokeradar=nil
    end
  end
end

def pbPokeRadarHighlightGrass
  array=[]
  grasses=[]
  grassindexes=[]
  for y in 0...$game_map.height
    for x in 0...$game_map.width
      if pbIsGrassTag?($game_map.terrain_tag(x,y)) &&
         (x!=$game_player.x || y!=$game_player.y)
        array.push([x,y])
      end
    end
  end
  grasscount=[array.length/18,1].max
  for i in 0...grasscount
    grassindexes.push(rand(array.length))
  end
  grassindexes|=[]
  for index in grassindexes
    grasses.push(array[index])
  end
  for grass in grasses
    $scene.spriteset.addUserAnimation(GRASS_ANIMATION_ID,grass[0],grass[1])
  end
  $PokemonTemp.pokeradar[3]=grasses if $PokemonTemp.pokeradar
end

################################################################################
# Using the Poke Radar
################################################################################
def pbCanUsePokeRadar?
  if !$PokemonEncounters.isGrass?
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
  end
  if $PokemonGlobal.bicycle
    Kernel.pbMessage(_INTL("Can't use that while on a bicycle."))
    return false
  end
  if $PokemonGlobal.surfing
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
  end
  if $PokemonTemp.pokeradar
    Kernel.pbMessage(_INTL("The Poke Radar is already in use."))
    return false
  elsif $PokemonGlobal.pokeradarBattery && $PokemonGlobal.pokeradarBattery>0
    Kernel.pbMessage(_INTL("The battery is not charged.\1"))
    Kernel.pbMessage(_INTL("You must walk {1} more steps to fully charge the battery.",
       $PokemonGlobal.pokeradarBattery))
    return false
  else
    return true
  end
end

def pbUsePokeRadar
  if pbCanUsePokeRadar?
    Kernel.pbMessage(_INTL("Used the Poke Radar."))
    $PokemonTemp.pokeradar=[0,0,0,[]]
    $PokemonGlobal.pokeradarBattery=50
    pbPokeRadarHighlightGrass
    return true
  end
  return false
end

################################################################################
# Event handlers
################################################################################
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $PokemonTemp.pokeradar && !$PokemonGlobal.bicycle
     grasses=$PokemonTemp.pokeradar[3]
     return if !grasses
     for grass in grasses
       if $game_player.x==grass[0] && $game_player.y==grass[1]
         chain=$PokemonTemp.pokeradar[2]
         v=[8200-chain*200,200].max
         v=0xFFFF / v
         v=rand(65536) / v
         if v == 0
           pokemon.makeShiny
         end
         return
       end
     end
   end
}

Events.onWildBattleEnd+=proc {|sender,e|
   species=e[0]
   level=e[1]
   decision=e[2]
   if !$PokemonEncounters.isGrass?
     return
   end
   if !$PokemonGlobal.bicycle && $PokemonTemp.pokeradar &&
      (decision==1 || decision==4) 
     $PokemonTemp.pokeradar[0]=species
     $PokemonTemp.pokeradar[1]=level
     pbPokeRadarHighlightGrass
     $PokemonTemp.pokeradar[2]+=1
     if $PokemonTemp.pokeradar[2]>40
       $PokemonTemp.pokeradar[2]=40
     end
   else
     $PokemonTemp.pokeradar=nil
   end
}

Events.onMapUpdate+=proc {|sender,e|
  if $PokemonGlobal && $PokemonTemp && $PokemonGlobal.bicycle
    $PokemonTemp.pokeradar=nil
  end
}

Events.onStepTaken+=proc {|sender,e|
   if $PokemonGlobal.pokeradarBattery && $PokemonGlobal.pokeradarBattery > 0 &&
      !$PokemonTemp.pokeradar
     $PokemonGlobal.pokeradarBattery-=1
   end
   if !$PokemonEncounters.isGrass? ||
      !pbIsGrassTag?($game_map.terrain_tag($game_player.x,$game_player.y))
     pbPokeRadarCancel
   end
}

Events.onMapChange+=proc {|sender,e|
   $PokemonTemp.pokeradar=nil
}

################################################################################
# Item handlers
################################################################################
ItemHandlers.addUseInField(:POKERADAR, proc {
   next pbUsePokeRadar
})

ItemHandlers.addUseFromBag(:POKERADAR, proc {
   next pbCanUsePokeRadar? ? 2 : 0
})