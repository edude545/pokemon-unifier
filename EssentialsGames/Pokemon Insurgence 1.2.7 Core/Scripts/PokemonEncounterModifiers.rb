# Make all wild Pokémon shiny while Switch 30 is ON.
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  hasAll=true
  for i in PBSpecies::DELTABULBASAUR..PBSpecies::DELTAGOODRA
    hasAll=false if !$Trainer.seen[i]
  end
  if pokemon.species==PBSpecies::DELTADITTO
    pokemon.form=PBTypes::WATER
  end
  if $game_map.map_id == 455 && $game_player.y >= 17 && $game_player.y <= 27 && 
     $game_player.x >= 60 && $game_player.x <= 71 && $game_switches[521] && !$game_switches[522]
    pokemon.species=PBSpecies::DELTASEEDOT
    pokemon.resetMoves
    pokemon.name=PBSpecies.getName(pokemon.species)
    pokemon.calcStats
    $game_switches[522]=true
  end
  if $game_map.map_id == 455 && $game_player.y >= 17 && $game_player.y <= 27 && 
     $game_player.x >= 60 && $game_player.x <= 71 && $game_switches[521] && !$game_switches[522]
    pokemon.species=PBSpecies::DELTASEEDOT
    pokemon.resetMoves
    pokemon.name=PBSpecies.getName(pokemon.species)
    pokemon.calcStats
    $game_switches[522]=true
  end
  if ($game_map.map_id==463 && pokemon.species==PBSpecies::GIRATINA) || ($game_map.map_id ==541 && pokemon.species==PBSpecies::ARCEUS) || ($game_map.map_id==784  && pokemon.species==PBSpecies::GIRATINA)
    pokemon.item=PBItems::CRYSTALPIECE
  elsif $game_map.map_id ==450 && (pokemon.species==PBSpecies::REGIGIGAS)
    pokemon.item=PBItems::CRYSTALPIECE
  elsif ($game_map.map_id ==463 || $game_map.map_id ==450 || $game_map.map_id ==506 || 
    $game_map.map_id ==541 || $game_map.map_id ==522) && $game_switches[321]
    primalAry=[PBSpecies::ARCEUS,PBSpecies::GIRATINA,PBSpecies::REGIGIGAS,
               PBSpecies::KYOGRE,PBSpecies::GROUDON]
    orbAry=[PBItems::CRYSTALPIECE,PBItems::CRYSTALPIECE,PBItems::CRYSTALPIECE,
            PBItems::BLUEORB,PBItems::REDORB]
    var=rand(primalAry.length)
    pokemon.species=primalAry[var]
    pokemon.item=orbAry[var]
    pokemon.resetMoves
    pokemon.name=PBSpecies.getName(pokemon.species)
    pokemon.calcStats
  end
  #roamingMaps=[661]
  
  roamingMaps=[48,80,126,151,176,177,229,233,236,239,246,288,393,397,409,528]
  
  aryOfSBFS=[113,116,119,165,190,354,390,731,729,727]
  if $game_switches[509] && pokemon.species<PBSpecies::DELTABULBASAUR && Kernel.checkIsIDNonLegend(pokemon.species) &&
    roamingMaps.include?($game_map.map_id) && !aryOfSBFS.include?($game_map.map_id)
    randraikou=60
    randsuicune=60
    randentei=60
    abilityVolt=false
    abilityLightning=false
    abilityWater=false
    abilityStorm=false
    abilityFlash=false
    abilityBlaze=false
    for poke in $Trainer.party
      if poke.ability==PBAbilities::VOLTABSORB && !abilityVolt
        abilityVolt=true
      end
      if poke.ability==PBAbilities::LIGHTNINGROD && !abilityLightning
        abilityLightning=true
      end
      
      if poke.ability==PBAbilities::WATERABSORB && !abilityWater
        abilityWater=true
      end
      if poke.ability==PBAbilities::STORMDRAIN && !abilityStorm
        abilityStorm=true
      end
      
      if poke.ability==PBAbilities::FLASHFIRE && !abilityFlash
        abilityFlash=true
      end
      if poke.ability==PBAbilities::BLAZEBOOST && !abilityBlaze
        abilityBlaze=true
      end
    end
    
    if abilityVolt
      randraikou -= 25
    end
    if abilityLightning
      randraikou -= 25
    end
    if abilityWater
      randsuicune -= 25
    end
    if abilityStorm
      randsuicune -= 25
    end
    if abilityFlash
      randentei -= 25
    end
    if abilityBlaze
      randentei -= 25
    end
    
    randraikou=randraikou.ceil
    randsuicune=randsuicune.ceil
    randentei=randentei.ceil
    
    xval=rand(randraikou)
    if !$Trainer.owned[PBSpecies::RAIKOU] && xval==0
      pokemon.species=PBSpecies::RAIKOU
      pokemon.level=80
      pokemon.resetMoves
      pokemon.name=PBSpecies.getName(pokemon.species)
      pokemon.calcStats
    end
    if !$Trainer.owned[PBSpecies::SUICUNE] && rand(randsuicune)==0
      pokemon.species=PBSpecies::SUICUNE
      pokemon.level=80
      pokemon.resetMoves
      pokemon.name=PBSpecies.getName(pokemon.species)
      pokemon.calcStats
    end
    if !$Trainer.owned[PBSpecies::ENTEI] && rand(randentei)==0
      pokemon.species=PBSpecies::ENTEI
      pokemon.level=80
      pokemon.resetMoves
      pokemon.name=PBSpecies.getName(pokemon.species)
      pokemon.calcStats
    end
  end
  #GOTHITELLE HOLDING GOTHITELLITE
  #CRESSELIA
  #GENGAR
  #SABLEYE
  #GARDEOIR
  #CHANDELURE
  #ONLY IN MAPS 246,247,288,393,391,397,244,245
  #when switch 536 is on
  #should only appear once
  aryMaps=[246,288,393,391,397,244,245]
  if aryMaps.include?($game_map.map_id) && rand(15)==0 && !$game_switches[563] && $game_switches[536]
    pokemon.species=PBSpecies::CRESSELIA
    pokemon.level=102
    $game_switches[562]=true
    pokemon.resetMoves
    pokemon.name=PBSpecies.getName(pokemon.species)
    pokemon.calcStats
  end
  aryMaps2=[393]
  if aryMaps2.include?($game_map.map_id) && rand(15)==0 && !$game_switches[587] && $game_switches[538]
    pokemon.species=PBSpecies::HYPNO
    pokemon.level=25
    pokemon.obtainLevel=25
    # $game_switches[562]=true
    pokemon.resetMoves
    pokemon.name=PBSpecies.getName(pokemon.species)
    pokemon.calcStats
  end
  if $game_map.map_id == 553 && !$game_switches[526] && pokemon.species != PBSpecies::DELTAREGISTEEL
    pokemon.species=PBSpecies::DELTAREMORAID
    pokemon.resetMoves
    pokemon.name=PBSpecies.getName(pokemon.species)
    pokemon.calcStats
    $game_switches[526]=true
  end
  if pokemon.species==PBSpecies::ZYGARDE  
    if $game_map.map_id==287 || $game_map.map_id==289
      pokemon.form=2
    elsif $game_map.map_id==827
      pokemon.form=0
    else
      pokemon.form=rand(3)
    end
  end
  if aryOfSBFS.include?($game_map.map_id) && checkIsFSLegal
    aryOfPokemon=[$game_variables[79][1]]
    #       $game_variables[79]
    if $game_switches[9]
      aryOfPokemon.push($game_variables[79][2])
    end
    if $game_switches[11]
      aryOfPokemon.push($game_variables[79][3])
    end
    pokemon.species=aryOfPokemon[rand(aryOfPokemon.length)]
    pokeNum=pokemon.species.to_i
    validNum=(pokeNum>0 && pokeNum<722)
    if !validNum
      pokemon.species=PBSpecies::WEEDLE
    end
    #    Kernel.pbMessage("1 and "+pokemon.species.to_s)
    pokemon.resetMoves
    pokemon.name=PBSpecies.getName(pokemon.species)
    pokemon.calcStats
    if rand(5)==1
      pokemon.setAbility(2)
    end
    pokemon.makeNotShiny
    #if rand(1)==0
    if rand(4096)<3
      pokemon.makeShiny
    end
    if pokemon.species==PBSpecies::UNOWN
      pokemon.form=rand(28)
    end
  end
  if $game_map.map_id==123 && $game_switches[59] && rand(5)==1
    pokemon.species=PBSpecies::RIOLU
    pokemon.resetMoves
    pokemon.name=PBSpecies.getName(pokemon.species)
    pokemon.calcStats
  end
  if $game_switches[31]
    pokemon.makeShiny
  end
  if $game_switches[160]
    pokemon.givePokerus
  end
  if isConst?($Trainer.party[0].ability,PBAbilities,:SYNCHRONIZE) && rand(2)# == 1
    pokemon.setNature($Trainer.party[0].nature)
  end
  if isConst?($Trainer.party[0].ability,PBAbilities,:CUTECHARM)
    if $Trainer.party[0].gender==0
      pokemon.setGender(1) if $Trainer.party[0].gender<2 && rand(100) < 67
    elsif $Trainer.party[0].gender==1
      pokemon.setGender(0) if $Trainer.party[0].gender<2 && rand(100) < 67
    end
  end
    
  if (pokemon.species==PBSpecies::MUNNA || pokemon.species==PBSpecies::MUSHARNA) &&
     [473,475,685,483,484,485,523,524].include?($game_map.map_id) && rand(20)==0
    pokemon.item=PBItems::DREAMMIST
  end
  #if [473,475,685,483,484,485,523,524].include?($game_map.map_id) && rand(50)==0
  #    pokemon.item=PBItems::DREAMMIST
  #end
    
  if $game_switches[321]
    if (pokemon.species==PBSpecies::MEWTWO && rand(3)==0)
      pokemon.form=4
    end
  end
  if $game_map.map_id==709 && pokemon.species==PBSpecies::MEWTWO
    pokemon.form=4
  end
  if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
    pokemon.form=pokemon.personalID%6 + 1
  end
=begin
    if $game_map.map_id == 83
        pokemon.form=2
        pokemon.moves[0]=PBMove.new(PBMoves::DARKSONATA)
        pokemon.moves[1]=PBMove.new(PBMoves::CLOSECOMBAT)
        pokemon.moves[2]=PBMove.new(PBMoves::HYPERVOICE)
        pokemon.moves[3]=PBMove.new(PBMoves::SING)
      end
=end
}

# Used in the random dungeon map.  The levels of all wild Pokémon in that map
# depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_map.map_id==51
     pokemon.level=pbBalancedLevel($Trainer.party) - 4 + rand(5)   # For variety
     pokemon.calcStats
     pokemon.resetMoves
   end
}