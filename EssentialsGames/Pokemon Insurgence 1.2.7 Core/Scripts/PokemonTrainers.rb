def changeForPurism(pkmn)
  if $PokemonSystem.purism != nil && $PokemonSystem.purism>0
    changedName=false
    case pkmn.item
      when PBItems::STUNFISKITE
        pkmn.species=PBSpecies::AUDINO
        pkmn.item=PBItems::AUDINITE
        pkmn.resetMoves
      when PBItems::FLYGONITE
        if pkmn.level>70 && pkmn.level<81
          pkmn.item=0
        else
          pkmn.species=PBSpecies::AMPHAROS
          pkmn.item=PBItems::AMPHAROSITE
          pkmn.resetMoves
        end
      when PBItems::DELTACHARIZARDITE
        pkmn.item=PBItems::CHARIZARDITEY
      when PBItems::DELTABLASTOISINITE
        pkmn.item=PBItems::BLASTOISITE
      when PBItems::DELTAVENUSAURITE
        pkmn.item=PBItems::VENUSAURITE
      when PBItems::EEVITE
        pkmn.item=0
      when PBItems::CRAWDITE #(edit audrey's post btl dialogue)
        pkmn.species=PBSpecies::SHARPEDO
        pkmn.item=PBItems::SHARPEDONITE
        pkmn.resetMoves
      when PBItems::MILTANKITE
        pkmn.species==PBSpecies::KANGASKHAN
        pkmn.item=PBItems::KANGASKHANITE
        pkmn.moves[0]=PBMove.new(PBMoves::FAKEOUT)
        pkmn.moves[1]=PBMove.new(PBMoves::EARTHQUAKE)
        pkmn.moves[2]=PBMove.new(PBMoves::SUCKERPUNCH)
        pkmn.moves[3]=PBMove.new(PBMoves::RETURN)
        pkmn.happiness=255
      when PBItems::MAGCARGONITE
        pkmn.species=PBSpecies::CAMERUPT
        pkmn.item=PBItems::CAMERUPTITE
      when PBItems::ZORONITE
        pkmn.item=0
      when PBItems::GOTHITITE
        pkmn.species=PBSpecies::GARDEVOIR
        pkmn.item=PBItems::GARDEVOIRITE
      when PBItems::TYPHLOSIONITE
        pkmn.species=PBSpecies::SALAMENCE
        pkmn.item=PBItems::SALAMENCITE
        pkmn.moves[0]=PBMove.new(PBMoves::OUTRAGE)
        pkmn.moves[1]=PBMove.new(PBMoves::EARTHQUAKE)
        pkmn.moves[2]=PBMove.new(PBMoves::DRAGONDANCE)
        pkmn.moves[3]=PBMove.new(PBMoves::RETURN)
        pkmn.happiness=255
      end
    case pkmn.species
      when PBSpecies::DELTACHARMANDER
        pkmn.species=PBSpecies::CHARMANDER
        pkmn.resetMoves
        changedName=true
      when PBSpecies::DELTACHARMELEON
        pkmn.species=PBSpecies::CHARMELEON
        pkmn.resetMoves
        changedName=true
      when PBSpecies::DELTACHARIZARD
        pkmn.species=PBSpecies::CHARIZARD
        pkmn.resetMoves
        changedName=true
      when PBSpecies::DELTASQUIRTLE
        pkmn.species=PBSpecies::SQUIRTLE
        pkmn.resetMoves
        changedName=true
      when PBSpecies::DELTAWARTORTLE
        pkmn.species=PBSpecies::WARTORTLE
        pkmn.resetMoves
        changedName=true
      when PBSpecies::DELTABLASTOISE
        pkmn.species=PBSpecies::BLASTOISE
        pkmn.resetMoves
        changedName=true
      when PBSpecies::DELTABULBASAUR
        pkmn.species=PBSpecies::BULBASAUR
        pkmn.resetMoves
        changedName=true
      when PBSpecies::DELTAIVYSAUR
        pkmn.species=PBSpecies::IVYSAUR
        pkmn.resetMoves
        changedName=true
      when PBSpecies::DELTAVENUSAUR
        pkmn.species=PBSpecies::VENUSAUR
        pkmn.resetMoves
        changedName=true
      end
    end

    pkmn.calcStats
    if changedName
      pkmn.name=PBSpecies.getName(pkmn.species)
    end
    return pkmn
end


def pbLoadPokegearTrainer(trainerid,trainername,partyid=0)
  success=false
  items=[]
  party=[]
  opponent=nil
  trainers=load_data("Data/trainers2.dat")
  for trainer in trainers
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
    items=trainer[2].clone
    name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVALNAMES
      if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
        name=$game_variables[i[1]]
      end
    end
    opponent=PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer) if $Trainer
    for poke in trainer[3]
      species=poke[0]
      level=poke[1]
      pokemon=PokeBattle_Pokemon.new(species,level,opponent)
      if !$game_switches[321]
        pokemon.form=poke[9]
      else
        pokemon.form=0
      end
      pokemon.resetMoves
      pokemon.item=poke[2]
      if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
        for k in 0...4
          pokemon.moves[k]=PBMove.new(poke[3+k])
        end
        pokemon.moves.compact!
      end
      pokemon.setAbility(poke[7])
      pokemon.setGender(poke[8])
      if poke[10]   # if this is a shiny Pokémon
        pokemon.makeShiny
      else
        pokemon.makeNotShiny
      end
      pokemon.setNature(poke[11])
      iv=poke[12]
      for i in 0...6
        pokemon.iv[i]=iv&0x1F
        pokemon.ev[i]=[85,level*3/2].min
      end
      pokemon.calcStats
      pokemon.happiness=poke[13]
      pokemon.name=poke[14] if poke[14] && poke[14]!=""
      if poke[15] && (!$Trainer.shadowcaught[pokemon.species] || isConst?(pokemon.species,PBSpecies,:SHAYMIN)) # if this is a Shadow Pokémon
        pokemon.form=1 if isConst?(pokemon.species,PBSpecies,:SHAYMIN)
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves rescue nil
        pokemon.makeNotShiny
      end
      if poke[16] && poke[16] != ""
        setEVs(pokemon,poke[16].to_i)
      end

      party.push(pokemon)
    end
    success=true
    break
  end
  #  Kernel.pbMessage("speed2 "+pokemon[0].name) if pokemon.ev[3]==255
  #  Kernel.pbMessage("speed3 "+pokemon[1].name) if pokemon.ev[3]==255
  #  Kernel.pbMessage("speed4 "+pokemon[2].name) if pokemon.ev[3]==255

  return success ? [opponent,items,party] : nil
end
def pbLoadTrainer(trainerid,trainername,partyid=0,e4scale=false)
  highestlevel=0
    for playerpoke in $Trainer.party
      if playerpoke.level > highestlevel
        highestlevel = playerpoke.level
      end
  end
  if !e4scale
    highestlevel=0
  end
  
  success=false
  items=[]
  party=[]
  opponent=nil
  generateFromNormal=true
  random=$game_switches[321] && $game_map.map_id!=759 && $game_map.map_id!=799
  if $PokemonSystem.chooseDifficulty==0
    trainers=load_data("Data/trainers_easy.dat")
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      generateFromNormal=false
      items=trainer[2].clone
      name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
      opponent=PokeBattle_Trainer.new(name,thistrainerid)
      opponent.setForeignID($Trainer) if $Trainer
      for poke in trainer[3]
        item=poke[2]
        species=poke[0]
        if random
          if Kernel.pbGetMegaStoneList.include?(poke[2])
            species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
            item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
            #cowctus
          else
            if !poke[15]
              #  species=rand(649) 
              #species = rand(721)+1
              #species = 1 if species == 0
              deltaAry=[]
              for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
                deltaAry.push(i)
              end
              for i in deltaAry
                klj = i + 1
              end
              species=rand(721+deltaAry.length+1)
              species=1 if species==0
              if species>PBSpecies::VOLCANION
                species=deltaAry[species-722]
              end
            end
          end                      
        end
        level=poke[1]>highestlevel ? poke[1] : highestlevel
        pokemon=PokeBattle_Pokemon.new(species,level,opponent)
        if !random
          pokemon.form=poke[9]
        else
          pokemon.form=0
        end
        pokemon.resetMoves
        pokemon.item=item
        if !random
          if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
            for k in 0...4
              pokemon.moves[k]=PBMove.new(poke[3+k])
            end
            pokemon.moves.compact!
          end
        elsif item==PBItems::RAYQUAZITE
          pokemon.moves[0]=PBMove.new(PBMoves::DRAGONSASCENT)
          pokemon.item=0
        end
        pokemon.setAbility(poke[7])
        if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
          pokemon.form=rand(7)+1
        end
        #if species==PBSpecies::MEOWSTIC
        #  pokemon.setGender(0)
        #else
          pokemon.setGender(poke[8])
        #end
        if poke[10]   # if this is a shiny Pokémon
          pokemon.makeShiny
        else
          pokemon.makeNotShiny
        end
        pokemon.setNature(poke[11])
        iv=poke[12]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
        pokemon.calcStats
        pokemon.happiness=poke[13]
        if !random
          pokemon.name=poke[14] if poke[14] && poke[14]!=""
        end
        if poke[15] && (!$Trainer.shadowcaught[pokemon.species] || isConst?(pokemon.species,PBSpecies,:SHAYMIN)) # if this is a Shadow Pokémon
          pokemon.form=1 if isConst?(pokemon.species,PBSpecies,:SHAYMIN)
          pokemon.makeShadow rescue nil
          pokemon.pbUpdateShadowMoves rescue nil
          pokemon.makeNotShiny
        end
        if poke[16] && poke[16] != ""
          setEVs(pokemon,poke[16].to_i)
        end
        pokemon=changeForPurism(pokemon)
        party.push(pokemon)
      end
      success=true
      break
    end
  elsif $PokemonSystem.chooseDifficulty==2
    trainers=load_data("Data/trainers_hard.dat")
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      generateFromNormal=false
      items=trainer[2].clone
      name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
      opponent=PokeBattle_Trainer.new(name,thistrainerid)
      opponent.setForeignID($Trainer) if $Trainer
      for poke in trainer[3]
        item=poke[2]
        species=poke[0]            
        if random
          if Kernel.pbGetMegaStoneList.include?(poke[2])
            species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
            item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
            #cowctus
          else
            if !poke[15]
              #  species=rand(649) 
              #species = rand(721)+1
              #species = 1 if species == 0
              deltaAry=[]
              for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
                deltaAry.push(i)
              end
              for i in deltaAry
                klj = i + 1
              end
              species=rand(721+deltaAry.length+1)
              species = 1 if species == 0
              if species>PBSpecies::VOLCANION
                species=deltaAry[species-722]
              end
            end
          end
        end
        level=poke[1]>highestlevel ? poke[1] : highestlevel
        pokemon=PokeBattle_Pokemon.new(species,level,opponent)
        if !random
          pokemon.form=poke[9]
        else
          pokemon.form=0
        end
        pokemon.resetMoves
        pokemon.item=item
        if !random
          if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
            for k in 0...4
              pokemon.moves[k]=PBMove.new(poke[3+k])
            end
            pokemon.moves.compact!
          end
        elsif item==PBItems::RAYQUAZITE
          pokemon.moves[0]=PBMove.new(PBMoves::DRAGONSASCENT)
          pokemon.item=0
        end
        pokemon.setAbility(poke[7])
        if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
          pokemon.form=rand(7)+1
        end
        #if species==PBSpecies::MEOWSTIC
        #  pokemon.setGender(0)
        #else
          pokemon.setGender(poke[8])
        #end
        if poke[10]   # if this is a shiny Pokémon
          pokemon.makeShiny
        else
          pokemon.makeNotShiny
        end
        pokemon.setNature(poke[11])
        iv=poke[12]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
        pokemon.calcStats
        pokemon.happiness=poke[13]
        if !random
          pokemon.name=poke[14] if poke[14] && poke[14]!=""
        end
        if poke[15] && (!$Trainer.shadowcaught[pokemon.species] || isConst?(pokemon.species,PBSpecies,:SHAYMIN)) # if this is a Shadow Pokémon
          pokemon.form=1 if isConst?(pokemon.species,PBSpecies,:SHAYMIN)
          pokemon.makeShadow rescue nil
          pokemon.pbUpdateShadowMoves rescue nil
          pokemon.makeNotShiny
        end                   
        if poke[16] && poke[16] != ""
          setEVs(pokemon,poke[16].to_i)
        end
        pokemon=changeForPurism(pokemon)
        party.push(pokemon)               
      end
      success=true
      break
    end
  else
  end
  if generateFromNormal || $PokemonSystem.chooseDifficulty==1
    trainers=load_data("Data/trainers.dat")      
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      items=trainer[2].clone
      name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
      for i in RIVALNAMES
        if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
          name=$game_variables[i[1]]
        end
      end
      opponent=PokeBattle_Trainer.new(name,thistrainerid)
      opponent.setForeignID($Trainer) if $Trainer
      for poke in trainer[3]
        item=poke[2]

        species=poke[0]
        if random
          if Kernel.pbGetMegaStoneList.include?(poke[2])
            species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
            item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
            #cowctus
          else
            if !poke[15]
              #  species=rand(649) 
              #species = rand(721)+1
              #species = 1 if species == 0
              deltaAry=[]
              for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
                deltaAry.push(i)
              end
              for i in deltaAry
                klj = i + 1
              end
              species=rand(721+deltaAry.length+1)
              species = 1 if species == 0
              if species>PBSpecies::VOLCANION
                species=deltaAry[species-722]
              end
            end
          end
        end
        #Kernel.pbMessage(_INTL("Gender: {1}",poke[8]))
        #Kernel.pbMessage(_INTL("Ability: {1}",poke[7]))
        level=poke[1]>highestlevel ? poke[1] : highestlevel
        pokemon=PokeBattle_Pokemon.new(species,level,opponent)
        #     Kernel.pbMessage(species.to_s)
        #     Kernel.pbMessage(pokemon.moves[0].id.to_s)
        #     Kernel.pbMessage(pokemon.moves[1].id.to_s)
        #   Kernel.pbMessage(pokemon.moves[2].id.to_s)
        #    Kernel.pbMessage(pokemon.moves[3].id.to_s)
        if !random
          pokemon.form=poke[9]
        else
          pokemon.form=0
        end
        pokemon.resetMoves
        pokemon.item=item
        if !random
          if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
            for k in 0...4
              pokemon.moves[k]=PBMove.new(poke[3+k])
            end
            pokemon.moves.compact!
          end
        elsif item==PBItems::RAYQUAZITE
          pokemon.moves[0]=PBMove.new(PBMoves::DRAGONSASCENT)
          pokemon.item=0
        end
        pokemon.setAbility(poke[7])
        if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
          pokemon.form=rand(7)+1
        end
        #if species==PBSpecies::MEOWSTIC
        #  pokemon.setGender(0)
        #else
          pokemon.setGender(poke[8])
        #end
        #Kernel.pbMessage(_INTL("Gender 1: {1}",pokemon.gender))
        #Kernel.pbMessage(_INTL("Ability 2: {1}",pokemon.ability))
        if poke[10]   # if this is a shiny Pokémon
          pokemon.makeShiny
        else
          pokemon.makeNotShiny
        end
        pokemon.setNature(poke[11])
        iv=poke[12]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
        pokemon.calcStats
        pokemon.happiness=poke[13]
        if !random
          pokemon.name=poke[14] if poke[14] && poke[14]!=""
        end
        if poke[15] && (!$Trainer.shadowcaught[pokemon.species] || isConst?(pokemon.species,PBSpecies,:SHAYMIN)) # if this is a Shadow Pokémon
          pokemon.form=1 if isConst?(pokemon.species,PBSpecies,:SHAYMIN)
          pokemon.makeShadow rescue nil
          pokemon.pbUpdateShadowMoves rescue nil
          pokemon.makeNotShiny
        end
        if poke[16] && poke[16] != ""
          #Kernel.pbMessage("1")
          #for i in 0...6
          #setEVs(pokemon,poke[16][i],i)
          setEVs(pokemon,poke[16].to_i)
          #end
        end
        #for i in 0...6
        #  Kernel.pbMessage(_INTL("{1}",pokemon.ev[i]))
        #end
        pokemon=changeForPurism(pokemon)
        party.push(pokemon)
      end
      success=true
      break
    end
  end
    
  #  Kernel.pbMessage("speed2 "+pokemon[0].name) if pokemon.ev[3]==255
  #  Kernel.pbMessage("speed3 "+pokemon[1].name) if pokemon.ev[3]==255
  #  Kernel.pbMessage("speed4 "+pokemon[2].name) if pokemon.ev[3]==255

  return success ? [opponent,items,party] : nil
end
### BEANS ###
#def setEVs(pokemon,id,idx)
def setEVs(pokemon,id)
    #Kernel.pbMessage("2")
    #if id==nil
    #  id=0
    #end
    #case idx
    #when 0
    #  pokemon.ev[0]=id #HP
    #when 1
    #  pokemon.ev[1]=id #Attack
    #when 2
    #  pokemon.ev[2]=id #Defense
    #when 3
    #  pokemon.ev[4]=id #Special Attack
    #when 4
    #  pokemon.ev[5]=id #Special Defense
    #when 5
    #  pokemon.ev[3]=id #Speed
    #end
    #Kernel.pbMessage("3")
    #for i in 0...6
    #  if pokemon.ev[i]==nil
    #    pokemon.ev[i]=0
    #  end
    #end
    #Kernel.pbMessage("4")
    pokemon.ev[0]=252 if id > 0 && id < 6 #HP
    pokemon.ev[1]=252 if id==1 || id==6 || id==7 || id==8 || id==9 #attack
    pokemon.ev[2]=252 if id==2 || id==6 || id==10 || id==11 || id==12 #defense
    pokemon.ev[3]=252 if id==3 || id==7 || id==10 || id==13 || id==14 #speed
  #  Kernel.pbMessage("speed "+pokemon.name) if id==3 || id==7 || id==10 || id==13 || id==14
    pokemon.ev[4]=252 if id==4 || id==8 || id==11 || id==13 || id==15 #spatk
    pokemon.ev[5]=252 if id==5 || id==9 || id==12 || id==14 || id==15#spdef
end


def pbLoadTrainerRandomized(trainerid,trainername,partyid=0)
  success=false
  items=[]
  party=[]
  opponent=nil
  generateFromNormal=true
  random=$game_switches[321] && $game_map.map_id!=759 && $game_map.map_id!=799
  if $PokemonSystem.chooseDifficulty==0
    trainers=load_data("Data/trainers_easy.dat")
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      generateFromNormal=false
      items=trainer[2].clone
      name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
      for i in RIVALNAMES
        if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
          name=$game_variables[i[1]]
        end
      end
      opponent=PokeBattle_Trainer.new(name,thistrainerid)
      opponent.setForeignID($Trainer) if $Trainer
      for poke in trainer[3]
        item=poke[2]
        
        if Kernel.pbGetMegaStoneList.include?(poke[2])
          species=poke[0]
          species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
          item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
        #cowctus
        else
          species=poke[0]
          if !poke[15]
          #  species=rand(649) 
            #species = rand(721)+1
            #species = 1 if species == 0
            deltaAry=[]
            for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
              deltaAry.push(i)
            end
            for i in deltaAry
              klj = i + 1
            end
            species=rand(721+deltaAry.length+1)
            species = 1 if species == 0
            if species>PBSpecies::VOLCANION
              species=deltaAry[species-722]
            end
          end
        end
        level=poke[1]
        pokemon=PokeBattle_Pokemon.new(species,level,opponent)
        if !random
          pokemon.form=poke[9] if !poke[15]
        else
          pokemon.form=0
        end
        pokemon.item=item
        pokemon.resetMoves
     #   if !poke[15] && poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
     #     for k in 0...4
     #       pokemon.moves[k]=PBMove.new(poke[3+k])
     #     end
     #     pokemon.moves.compact!
     #   end
        pokemon.setAbility(poke[7]) if !poke[15]
        if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
          pokemon.form=rand(7)+1
        end
        #if species==PBSpecies::MEOWSTIC
        #  pokemon.setGender(0)
        #else
          pokemon.setGender(poke[8]) if !poke[15]
        #end
        if poke[10] && !poke[15]  # if this is a shiny Pokémon
          pokemon.makeShiny
        else
          pokemon.makeNotShiny
        end
        pokemon.setNature(poke[11])
        iv=poke[12]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
        pokemon.calcStats
        pokemon.happiness=poke[13]
    #    pokemon.name=poke[14] if poke[14] && poke[14]!="" && !poke[15]
        if poke[15] && !$Trainer.shadowcaught[pokemon.species]   # if this is a Shadow Pokémon
          pokemon.makeShadow rescue nil
          pokemon.pbUpdateShadowMoves rescue nil
          pokemon.makeNotShiny
        end
        if poke[16] && poke[16] != ""
            setEVs(pokemon,poke[16].to_i)
        end
        
        party.push(pokemon)
      end
      success=true
      break
    end
  elsif $PokemonSystem.chooseDifficulty==2
    trainers=load_data("Data/trainers_hard.dat")
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      generateFromNormal=false
      items=trainer[2].clone
      name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
      for i in RIVALNAMES
        if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
          name=$game_variables[i[1]]
        end
      end
      opponent=PokeBattle_Trainer.new(name,thistrainerid)
      opponent.setForeignID($Trainer) if $Trainer
      for poke in trainer[3]
        item=poke[2]
        
        if Kernel.pbGetMegaStoneList.include?(poke[2])
          species=poke[0]
          species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
          item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
        #cowctus
        else
          species=poke[0]
          if !poke[15]
          #  species=rand(649) 
            #species = rand(721)+1
            #species = 1 if species == 0
            deltaAry=[]
            for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
              deltaAry.push(i)
            end
            for i in deltaAry
              klj = i + 1
            end
            species=rand(721+deltaAry.length+1)
            species = 1 if species == 0
            if species>PBSpecies::VOLCANION
              species=deltaAry[species-722]
            end
          end
        end
        level=poke[1]
        pokemon=PokeBattle_Pokemon.new(species,level,opponent)
        if !random
          pokemon.form=poke[9] if !poke[15]
        else
          pokemon.form=0
        end
        pokemon.item=item
        pokemon.resetMoves
     #   if !poke[15] && poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
     #     for k in 0...4
     #       pokemon.moves[k]=PBMove.new(poke[3+k])
     #     end
     #     pokemon.moves.compact!
     #   end
        pokemon.setAbility(poke[7]) if !poke[15]
        if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
          pokemon.form=rand(7)+1
        end
        #if species==PBSpecies::MEOWSTIC
        #  pokemon.setGender(0)
        #else
          pokemon.setGender(poke[8]) if !poke[15]
        #end
        if poke[10] && !poke[15]  # if this is a shiny Pokémon
          pokemon.makeShiny
        else
          pokemon.makeNotShiny
        end
        pokemon.setNature(poke[11])
        iv=poke[12]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
        pokemon.calcStats
        pokemon.happiness=poke[13]
    #    pokemon.name=poke[14] if poke[14] && poke[14]!="" && !poke[15]
        if poke[15] && !$Trainer.shadowcaught[pokemon.species]   # if this is a Shadow Pokémon
          pokemon.makeShadow rescue nil
          pokemon.pbUpdateShadowMoves rescue nil
          pokemon.makeNotShiny
        end
        if poke[16] && poke[16] != ""
            setEVs(pokemon,poke[16].to_i)
        end
        
        party.push(pokemon)
      end
      success=true
      break
    end
  end
  if generateFromNormal || $PokemonSystem.chooseDifficulty==1
    trainers=load_data("Data/trainers.dat")
    random=$game_switches[321] && $game_map.map_id!=759 && $game_map.map_id!=799
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      items=trainer[2].clone
      name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
      for i in RIVALNAMES
        if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
          name=$game_variables[i[1]]
        end
      end
      opponent=PokeBattle_Trainer.new(name,thistrainerid)
      opponent.setForeignID($Trainer) if $Trainer
      for poke in trainer[3]
        item=poke[2]
        
        if Kernel.pbGetMegaStoneList.include?(poke[2])
          species=poke[0]
          species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
          item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
        #cowctus
        else
          species=poke[0]
          if !poke[15]
          #  species=rand(649) 
            #species = rand(721)+1
            #species = 1 if species == 0
            deltaAry=[]
            for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
              deltaAry.push(i)
            end
            for i in deltaAry
              klj = i + 1
            end
            species=rand(721+deltaAry.length+1)
            species = 1 if species == 0
            if species>PBSpecies::VOLCANION
              species=deltaAry[species-722]
            end
          end
        end
        level=poke[1]
        pokemon=PokeBattle_Pokemon.new(species,level,opponent)
        if !random
          pokemon.form=poke[9] if !poke[15]
        else
          pokemon.form=0
        end
        pokemon.item=item
        pokemon.resetMoves
        
     #   if !poke[15] && poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
     #     for k in 0...4
     #       pokemon.moves[k]=PBMove.new(poke[3+k])
     #     end
     #     pokemon.moves.compact!
     #   end
        pokemon.setAbility(poke[7]) if !poke[15]
        if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
          pokemon.form=rand(7)+1
        end
        #if species==PBSpecies::MEOWSTIC
        #  pokemon.setGender(0)
        #else
          pokemon.setGender(poke[8]) if !poke[15]
        #end
        if poke[10] && !poke[15]  # if this is a shiny Pokémon
          pokemon.makeShiny
        else
          pokemon.makeNotShiny
        end
        pokemon.setNature(poke[11])
        iv=poke[12]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
        pokemon.calcStats
        pokemon.happiness=poke[13]
    #    pokemon.name=poke[14] if poke[14] && poke[14]!="" && !poke[15]
        if poke[15] && !$Trainer.shadowcaught[pokemon.species]   # if this is a Shadow Pokémon
          pokemon.makeShadow rescue nil
          pokemon.pbUpdateShadowMoves rescue nil
          pokemon.makeNotShiny
        end
        if poke[16] && poke[16] != ""
            setEVs(pokemon,poke[16].to_i)
        end
        
        party.push(pokemon)
      end
      success=true
      break
    end
  end
  return success ? [opponent,items,party] : nil
end


def pbLoadTrainerScaled(trainerid,trainername,partyid=0,isE4=false)
  success=false
  highestlevel=0
  for playerpoke in $Trainer.party
      if playerpoke.level > highestlevel
        highestlevel = playerpoke.level
      end
  end
  #Kernel.pbMessage(highestlevel.to_s)
  items=[]
  party=[]
  opponent=nil
  generateFromNormal=true
  if $PokemonSystem.chooseDifficulty==2
    trainers=load_data("Data/trainers_hard.dat")
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      generateFromNormal=false
      break
    end
  elsif $PokemonSystem.chooseDifficulty==0
    trainers=load_data("Data/trainers_easy.dat")
    for trainer in trainers
      #next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      #generateFromNormal=false
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      generateFromNormal=false
      break
    end
  end

  if generateFromNormal
    trainers=load_data("Data/trainers.dat")
  end
  for trainer in trainers
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
    items=trainer[2].clone
    name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVALNAMES
      if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
        name=$game_variables[i[1]]
      end
    end
    opponent=PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer) if $Trainer
    for poke in trainer[3]
      item=poke[2]
      
      species=poke[0]
      if $game_switches[321]
        if Kernel.pbGetMegaStoneList.include?(poke[2])
          species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
          item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
        #cowctus
        else
          if !poke[15]
          #  species=rand(649) 
            #species = rand(721)+1
            #species = 1 if species == 0
            deltaAry=[]
            for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
              deltaAry.push(i)
            end
            for i in deltaAry
              klj = i + 1
            end
            species=rand(721+deltaAry.length+1)
            species = 1 if species == 0
            if species>PBSpecies::VOLCANION
              species=deltaAry[species-722]
            end
          end
        end
      end
      level=poke[1]
      if (highestlevel>level || !isE4) && species != PBSpecies::ARON
        level=highestlevel
      end
      pokemon=PokeBattle_Pokemon.new(species,level,opponent)
      if !$game_switches[321]
        pokemon.form=poke[9]
      else
        pokemon.form=0
      end
      pokemon.resetMoves
      pokemon.item=item
      if !$game_switches[321]
        if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
          for k in 0...4
            pokemon.moves[k]=PBMove.new(poke[3+k])
          end
          pokemon.moves.compact!
        end
      elsif item==PBItems::RAYQUAZITE
        pokemon.moves[0]=PBMove.new(PBMoves::DRAGONSASCENT)
        pokemon.item=0
      end
      pokemon.setAbility(poke[7])
      if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
        pokemon.form=rand(7)+1
      end
      #if species==PBSpecies::MEOWSTIC
      #  pokemon.setGender(0)
      #else
        pokemon.setGender(poke[8])
      #end
      if poke[10]   # if this is a shiny Pokémon
        pokemon.makeShiny
      else
        pokemon.makeNotShiny
      end
      pokemon.setNature(poke[11])
      iv=poke[12]
      for i in 0...6
        pokemon.iv[i]=iv&0x1F
        pokemon.ev[i]=[85,level*3/2].min
      end
      pokemon.calcStats
      pokemon.happiness=poke[13]
      if !$game_switches[321]
        pokemon.name=poke[14] if poke[14] && poke[14]!=""
      end
      if poke[15] && !$Trainer.shadowcaught[pokemon.species]   # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves rescue nil
        pokemon.makeNotShiny
      end
      if poke[16] && poke[16] != ""
        setEVs(pokemon,poke[16].to_i)
      end
      party.push(pokemon)
    end
    success=true
    break
  end
  return success ? [opponent,items,party] : nil
end

def pbDoubleTrainerScaled(trainerid1, trainername1, trainerparty1, endspeech1,
                                trainerid2, trainername2, trainerparty2, endspeech2,
                                canlose=false,isE4=false)
  trainer1=pbLoadTrainerScaled(trainerid1, trainername1, trainerparty1,isE4)
  if !trainer1
    pbMissingTrainer(trainerid1,trainername1,trainerparty1)
  end
  trainer2=pbLoadTrainerScaled(trainerid2,trainername2,trainerparty2,isE4)
  if !trainer2
    pbMissingTrainer(trainerid2,trainername2,trainerparty2)
  end
  if $PokemonGlobal.partner
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],
       $PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      playerparty[6+i]=othertrainer.party[i]
    end
    fullparty1=true
    playertrainer=[$Trainer,othertrainer]
    doublebattle=true
  else
    playerparty=$Trainer.party
    playertrainer=$Trainer
    fullparty1=false
  end
  combinedParty=[]
  for i in 0...trainer1[2].length
    combinedParty[i]=trainer1[2][i]
  end
  for i in 0...trainer2[2].length
    combinedParty[6+i]=trainer2[2][i]
  end
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,
     playerparty,combinedParty,playertrainer,[trainer1[0],trainer2[0]])
  trainerbgm=pbGetTrainerBattleBGM([trainer1[0],trainer2[0]])
  battle.fullparty1=fullparty1
  battle.fullparty2=true
  battle.doublebattle=battle.pbDoubleBattleAllowed?()
  battle.endspeech=(endspeech1)
  battle.endspeech2=(endspeech2)
  battle.items=[trainer1[1],trainer2[1]]
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2 && battle.endspeech2!=""
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  pbBattleAnimation(trainerbgm) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     if $PokemonGlobal.partner
       pbHealAll if !$game_switches[329]
       for i in $PokemonGlobal.partner[3]; i.heal; end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  return (decision==1)
end

=begin
def pbDoubleTrainerBattle(trainerid1, trainername1, trainerparty1, endspeech1,
                          trainerid2, trainername2, trainerparty2, endspeech2, 
                          canlose=false)
  trainer1=pbLoadTrainer(trainerid1,trainername1,trainerparty1)
  if !trainer1
    pbMissingTrainer(trainerid1,trainername1,trainerparty1)
  end
  trainer2=pbLoadTrainer(trainerid2,trainername2,trainerparty2)
  if !trainer2
    pbMissingTrainer(trainerid2,trainername2,trainerparty2)
  end
  if !trainer1 || !trainer2
    return false
  end
  if $PokemonGlobal.partner
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],
       $PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      playerparty[6+i]=othertrainer.party[i]
    end
    fullparty1=true
    playertrainer=[$Trainer,othertrainer]
    doublebattle=true
  else
    playerparty=$Trainer.party
    playertrainer=$Trainer
    fullparty1=false
  end
  combinedParty=[]
  for i in 0...trainer1[2].length
    combinedParty[i]=trainer1[2][i]
  end
  for i in 0...trainer2[2].length
    combinedParty[6+i]=trainer2[2][i]
  end
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,
     playerparty,combinedParty,playertrainer,[trainer1[0],trainer2[0]])
  trainerbgm=pbGetTrainerBattleBGM([trainer1[0],trainer2[0]])
  battle.fullparty1=fullparty1
  battle.fullparty2=true
  battle.doublebattle=battle.pbDoubleBattleAllowed?()
  battle.endspeech=(endspeech1)
  battle.endspeech2=(endspeech2)
  battle.items=[trainer1[1],trainer2[1]]
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2 && battle.endspeech2!=""
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  pbBattleAnimation(trainerbgm) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     if $PokemonGlobal.partner
       pbHealAll if !$game_switches[329]
       for i in $PokemonGlobal.partner[3]; i.heal; end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  return (decision==1)
end
=end





def pbLoadTrainerRandom(trainerid,trainername,partyid=0)
  success=false
    highestlevel=0
  for playerpoke in $Trainer.party
      if playerpoke.level > highestlevel
        highestlevel = playerpoke.level
      end
  end

  items=[]
  party=[]
  opponent=nil
  generateFromNormal=true
  if $PokemonSystem.chooseDifficulty==0
    trainers=load_data("Data/trainers_easy.dat")
    generateFromNormal=false
  elsif $PokemonSystem.chooseDifficulty==2
    trainers=load_data("Data/trainers_hard.dat")
    generateFromNormal=false
  end
  if generateFromNormal || $PokemonSystem.chooseDifficulty==1
    trainers=load_data("Data/trainers.dat")
  end
  for trainer in trainers
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
    items=trainer[2].clone
    name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVALNAMES
      if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
        name=$game_variables[i[1]]
      end
    end
    opponent=PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer) if $Trainer
    for poke in trainer[3]
      species=(ChallengeChampionship.new).generatePokemon($game_variables[90])
      level=highestlevel
      pokemon=PokeBattle_Pokemon.new(species,level,opponent)
      if !$game_switches[321]
        pokemon.form=poke[9]
      else
        pokemon.form=0
      end
      pokemon.resetMoves
      pokemon.item=poke[2]
      if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
        for k in 0...4
          pokemon.moves[k]=PBMove.new(poke[3+k])
        end
        pokemon.moves.compact!
      end
      pokemon.setAbility(poke[7])
      pokemon.setGender(poke[8])
      if poke[10]   # if this is a shiny Pokémon
        pokemon.makeShiny
      else
        pokemon.makeNotShiny
      end
      pokemon.setNature(poke[11])
      iv=poke[12]
      for i in 0...6
        pokemon.iv[i]=iv&0x1F
        pokemon.ev[i]=[85,level*3/2].min
      end
      pokemon.calcStats
      pokemon.happiness=poke[13]
      pokemon.name=poke[14] if poke[14] && poke[14]!=""
      if poke[15]  && !$Trainer.shadowcaught[pokemon.species] # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves rescue nil
        pokemon.makeNotShiny
      end      
      if poke[16] && poke[16] != ""
          setEVs(pokemon,poke[16].to_i)
      end

      party.push(pokemon)
    end
    success=true
    break
  end
  return success ? [opponent,items,party] : nil
end
=begin
Eevee             YES
Electrike         FORCED
Geodude           FORCED
Vulpix            YES
Swablu            YES
Growlithe
Porygon           YES
Voltorb           YES
Riolu             FORCED
Mawile            FORCED
Excadrill         YES
Wailmer
Dodrio            
Absol             
Golem             FORCED
Rapidash          FORCED
Pidgeot
Toxicroak         YES
Reuniclus         FORCED
Sigilyph      
Politoed          YES
Medicham          YES
Flygon            FORCED
===
Gigalith          YES
Scizor            YES
Cryogonal         YES
Magnezone         YES
Rayquaza          YES
===
Donphan           YES
Breloom           YES
===
Keldeo            YES
Chesnaught        YES
Delphox             YES
Greninja          YES
Shaymin           YES
Groudon/Kyogre    YES

Ho-Oh/Lugia       Zeta/Omicron
Dragonite         Zeta/Omicron
Gardevoir         Zeta/Omicron
Metagross         Zeta/Omicron
Eelektross        Zeta/Omicron

=========================================
=========================================



=========================================
=========================================

=end

def getFinalShadowAvailable
    yes = [PBSpecies::EEVEE,PBSpecies::VULPIX,PBSpecies::SWABLU,PBSpecies::PORYGON,
    PBSpecies::VOLTORB,PBSpecies::EXCADRILL,PBSpecies::TOXICROAK,PBSpecies::POLITOED,
    PBSpecies::MEDICHAM,PBSpecies::GIGALITH,PBSpecies::SCIZOR,PBSpecies::CRYOGONAL,
    PBSpecies::MAGNEZONE,PBSpecies::RAYQUAZA,PBSpecies::DONPHAN,PBSpecies::BRELOOM,
    PBSpecies::KELDEO,PBSpecies::CHESNAUGHT,PBSpecies::DELPHOX,PBSpecies::GRENINJA,
    PBSpecies::SHAYMIN,PBSpecies::GROUDON]
    
    forced = [PBSpecies::ELECTRIKE,PBSpecies::GEODUDE,PBSpecies::RIOLU,PBSpecies::MAWILE,
    PBSpecies::GOLEM,PBSpecies::RAPIDASH,PBSpecies::REUNICLUS,PBSpecies::FLYGON]
    
    noLuck = [PBSpecies::GROWLITHE,PBSpecies::WAILMER,PBSpecies::DODRIO,PBSpecies::ABSOL,
    PBSpecies::PIDGEOT,PBSpecies::SIGILYPH]
  
    choiceList = []
    for poke in yes
        if $game_variables[62][poke] && !$Trainer.shadowcaught[poke]
          choiceList.push(poke)
        end
      end
      
    for poke in forced
      choiceList.push(poke) if !$Trainer.shadowcaught[poke]
    end
    
    for poke in noLuck
      choiceList.push(poke) if !$Trainer.shadowcaught[poke]
    end
    
    if choiceList.length > 0
        return choiceList[0]
      else
        return 0
      end
end

def getAllShadow
    yes = [PBSpecies::EEVEE,PBSpecies::VULPIX,PBSpecies::SWABLU,PBSpecies::PORYGON,
    PBSpecies::VOLTORB,PBSpecies::EXCADRILL,PBSpecies::TOXICROAK,PBSpecies::POLITOED,
    PBSpecies::MEDICHAM,PBSpecies::GIGALITH,PBSpecies::SCIZOR,PBSpecies::CRYOGONAL,
    PBSpecies::MAGNEZONE,PBSpecies::RAYQUAZA,PBSpecies::DONPHAN,PBSpecies::BRELOOM,
    PBSpecies::KELDEO,PBSpecies::CHESNAUGHT,PBSpecies::DELPHOX,PBSpecies::GRENINJA,
    PBSpecies::SHAYMIN,PBSpecies::GROUDON,PBSpecies::ELECTRIKE,PBSpecies::GEODUDE,PBSpecies::RIOLU,PBSpecies::MAWILE,
    PBSpecies::GOLEM,PBSpecies::RAPIDASH,PBSpecies::REUNICLUS,PBSpecies::FLYGON,PBSpecies::GROWLITHE,PBSpecies::WAILMER,PBSpecies::DODRIO,PBSpecies::ABSOL,
    PBSpecies::PIDGEOT,PBSpecies::SIGILYPH]
  
    choiceList = []
    for poke in yes
        if !$Trainer.shadowcaught[poke]
          choiceList.push(poke)
        end
      end
    if choiceList.length > 0
        return choiceList[0]
      else
        return 0
      end
end

def getShadowAvailable
  avaliable = [PBSpecies::EEVEE, PBSpecies::ELECTRIKE, PBSpecies::GEODUDE,
  PBSpecies::VULPIX,PBSpecies::GROWLITHE,PBSpecies::VOLTORB,PBSpecies::PORYGON,
  PBSpecies::LARVITAR,PBSpecies::WAILMER,PBSpecies::MAWILE,PBSpecies::CACNEA,
  PBSpecies::SWABLU,PBSpecies::ABSOL,PBSpecies::RIOLU,PBSpecies::DRILBUR,
  PBSpecies::DUOSION,PBSpecies::VANILLITE,PBSpecies::PIDGEOT,PBSpecies::GOLEM,
  PBSpecies::RAPIDASH,PBSpecies::DODRIO,PBSpecies::ELECTRODE,PBSpecies::DRAGONITE,
  PBSpecies::POLITOED,PBSpecies::SCIZOR,PBSpecies::DONPHAN,PBSpecies::LUGIA,
  PBSpecies::GARDEVOIR,PBSpecies::BRELOOM,PBSpecies::HOOH,PBSpecies::MEDICHAM,
  PBSpecies::FLYGON,PBSpecies::ALTARIA,PBSpecies::METANG,PBSpecies::METAGROSS,
  PBSpecies::RAYQUAZA,PBSpecies::TOXICROAK, PBSpecies::MAGNEZONE,PBSpecies::GIGALITH,
  PBSpecies::EXCADRILL,PBSpecies::SIGILYPH,PBSpecies::REUNICLUS,PBSpecies::EELEKTROSS,
  PBSpecies::CRYOGONAL,PBSpecies::GRENINJA,PBSpecies::DELPHOX,PBSpecies::CHESNAUGHT]
  
  for poke in avaliable
  if $game_variables[62][poke] && !$Trainer.shadowcaught[poke]
      return poke
  end
  end
  return PBSpecies::PORYGON
end

def pbLoadMiror(trainerid,trainername,partyid=0)
  highestlevel=0
  for playerpoke in $Trainer.party
      if playerpoke.level > highestlevel
        highestlevel = playerpoke.level
      end
  end
 # Kernel.pbMessage("Miror Loaded!")
  success=false
  items=[]
  party=[]
  opponent=nil
  loadcount = 0
  trainers=load_data("Data/trainers.dat")
  for trainer in trainers
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
    items=trainer[2].clone
    name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVALNAMES
      if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
        name=$game_variables[i[1]]
      end
    end
    opponent=PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer) if $Trainer
  #  if trainer && trainer.is_a?(Array) && trainer[3] && trainer[3].is_a?(Array)
  #  Kernel.pbMessage("hi") 
  #else
  #  Kernel.pbMessage("bye")
  #end
  
    for poke in trainer[3]
      #loadcount++

    if !isConst?(poke[0],PBSpecies,:LUDICOLO)
      species=getShadowAvailable if !$game_switches[238]
      species=getFinalShadowAvailable if $game_switches[238]
    else
      species=poke[0]
    end
    
      level=highestlevel
      pokemon=PokeBattle_Pokemon.new(species,level,opponent)
      pokemon.form=poke[9]
      pokemon.resetMoves
      pokemon.item=poke[2]
      if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
        for k in 0...4
          pokemon.moves[k]=PBMove.new(poke[3+k])
        end
        pokemon.moves.compact!
      end
      pokemon.setAbility(poke[7])
      pokemon.setGender(poke[8])
      if poke[10]   # if this is a shiny Pokémon
        pokemon.makeShiny
      else
        pokemon.makeNotShiny
      end
      pokemon.setNature(poke[11])
      iv=poke[12]
      for i in 0...6
        pokemon.iv[i]=iv&0x1F
        pokemon.ev[i]=[85,level*3/2].min
      end
      pokemon.calcStats
      pokemon.happiness=poke[13]
      pokemon.name=poke[14] if poke[14] && poke[14]!=""
      if !isConst?(poke[0],PBSpecies,:LUDICOLO)  # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves rescue nil
        pokemon.makeNotShiny
      end
      if poke[16] && poke[16] != ""
        setEVs(pokemon,poke[16].to_i)
      end

      party.push(pokemon)
    end
    success=true
    break
  end
  return success ? [opponent,items,party] : nil
end



def pbLoadClone(trainerid,trainername,partyid=0)
  highestlevel=0
  #for playerpoke in $Trainer.party
  #    if playerpoke.level > highestlevel
  #      highestlevel = playerpoke.level
  #    end
  #end
 # Kernel.pbMessage("Miror Loaded!")
  success=false
  items=[]
 # party=[]
  opponent=nil
  loadcount = 0
  trainers=load_data("Data/trainers.dat")
 # for trainer in trainers
 #   name=trainer[1]
 #   thistrainerid=trainer[0]
 #   thispartyid=trainer[4]
    party=$game_variables[82].dup
    #for poke in party
    #  if poke.eggsteps > 0
    #    poke.eggsteps = 0
    #    end
    #  end
    for i in 0..5
        party[i]=nil if party[i] != nil && (party[i].eggsteps > 0 || party[i].hp < 1 || party[i].isShadow?)
      
      end
    party.compact!
    #next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
  #  items=trainer[2].clone
  #  name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    #for i in RIVALNAMES
    ##  if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
     #   name=$game_variables[i[1]]
     # end
    #end
    opponent=PokeBattle_Trainer.new("Clone",PBTrainers::POKEMONTRAINER_Red)
    #opponent.setForeignID($Trainer) if $Trainer
  #  success=true
  #  break
  #end
  return [opponent,nil,party]
end


def pbLoadGymBattle(trainerid,trainername,partyid=0)
  success=false
  items=[]
  party=[]
  opponent=nil
  loadcount = 0
  trainers=load_data("Data/trainers.dat")
  for trainer in trainers
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    name=ChallengeChampionship.new.randomName($game_variables[71][4])
    thistrainerid=ChallengeChampionship.new.getTrainerType($game_variables[71][3],false)
    party=$game_variables[71][2]
    #next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
    items=trainer[2].clone
    #name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    #for i in RIVALNAMES
    #  if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
    #    name=$game_variables[i[1]]
    #  end
    #end
    opponent=PokeBattle_Trainer.new(name,thistrainerid)
    opponent.money=100 if $game_switches[263]
    opponent.money=50 if !$game_switches[263]
#    Kernel.pbMessage("hay") if $game_switches[263]
#    party[0].hp = party[0].hp-rand(party[0].totalhp) if $game_switches[263]
        #opponent=PokeBattle_Trainer.new(name,thistrainerid)

    opponent.setForeignID($Trainer) if $Trainer
    success=true
    break
  end
  return success ? [opponent,$game_variables[106],party] : nil
end






def pbConvertTrainerData
  data=load_data("Data/trainertypes.dat")
  trainertypes=[]
  for i in 0...data.length
    record=data[i]
    if record
      trainertypes[record[0]]=record[2]
    end
  end
  MessageTypes.setMessages(MessageTypes::TrainerTypes,trainertypes)
  pbSaveTrainerTypes()
  pbSaveTrainerBattles()
end

def pbNewTrainer(trainerid,trainername,trainerparty)
  pokemon=[]
  level=10
  for i in 1..6
    if i==1
      Kernel.pbMessage(_INTL("Please enter the first Pokémon.",i))
    else
      if !Kernel.pbConfirmMessage(_INTL("Add another Pokémon?"))
        break
      end
    end
    loop do
      species=pbChooseSpeciesOrdered(1)
      if species<=0
        if i==1
          Kernel.pbMessage(_INTL("This trainer must have at least 1 Pokémon!"))
        else
          break
        end
      else
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setDefaultValue(level)
        level=Kernel.pbMessageChooseNumber(_INTL("Set the level for {1}.",
           PBSpecies.getName(species)),params)
        tempPoke=PokeBattle_Pokemon.new(species,level)
        pokemon.push([species,level,0,
           tempPoke.moves[0].id,
           tempPoke.moves[1].id,
           tempPoke.moves[2].id,
           tempPoke.moves[3].id
        ])
        break
      end
    end
  end
  trainer=[trainerid,trainername,[],pokemon,trainerparty]
  data=load_data("Data/trainers.dat")
  data.push(trainer)
  data=save_data(data,"Data/trainers.dat")
  pbConvertTrainerData
  Kernel.pbMessage(_INTL("The Trainer's data was added to the list of battles and at PBS/trainers.txt."))
  return trainer
end

def pbTrainerTypeCheck(symbol)
  ret=true
  if $DEBUG
    if !hasConst?(PBTrainers,symbol)
      ret=false
    else
      trtype=PBTrainers.const_get(symbol)
      data=load_data("Data/trainertypes.dat")
      if !data || !data[trtype]
        ret=false
      end
    end
    if !ret
      if Kernel.pbConfirmMessage(_INTL("Add new trainer type {1}?",symbol))
        pbTrainerTypeEditorNew(symbol.to_s)
      end
      if pbMapInterpreter
        pbMapInterpreter.command_end
      end
    end
  end
  return ret
end

def pbGetFreeTrainerParty(trainerid,trainername)
  for i in 0...256
    trainer=pbLoadTrainer(trainerid,trainername,i)
    if !trainer
      return i
    end
  end
  return -1
end

def pbTrainerCheck(trainerid,trainername,maxbattles,startBattleId=0)
  if $DEBUG
    if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
      pbTrainerTypeCheck(trainerid)
      return false if !hasConst?(PBTrainers,trainerid)
      trainerid=PBTrainers.const_get(trainerid)
    end
    for i in 0...maxbattles
      trainer=pbLoadTrainer(trainerid,trainername,i+startBattleId)
      if !trainer
        traineridstring="#{trainerid}"
        traineridstring=getConstantName(PBTrainers,trainerid) rescue "-"
        if Kernel.pbConfirmMessage(_INTL("Add new battle {1} (of {2}) for ({3}, {4})?",
          i+1,maxbattles,traineridstring,trainername))
          pbNewTrainer(trainerid,trainername,i)
        end
      end
    end
  end
  return true
end

def pbMissingTrainer(trainerid, trainername, trainerparty)
  return 2
  traineridstring="#{trainerid}"
  traineridstring=getConstantName(PBTrainers,trainerid) rescue "-"
  if $DEBUG
	  message=""
    if trainerparty!=0
      message=(_INTL("Add new trainer ({1}, {2}, ID {3})?",traineridstring,trainername,trainerparty))
    else
      message=(_INTL("Add new trainer ({1}, {2})?",traineridstring,trainername))
    end
    cmd=Kernel.pbMessage(message,[_INTL("YES"),_INTL("NO"),_INTL("NO TO ALL")],2)
    if cmd==0
      pbNewTrainer(trainerid,trainername,trainerparty)
    end
    return cmd
  else
    raise _INTL("Can't find trainer ({1}, {2}, ID {3})",traineridstring,trainername,trainerparty)
  end
end

def pbDoubleTrainerBattle(trainerid1, trainername1, trainerparty1, endspeech1,
                          trainerid2, trainername2, trainerparty2, endspeech2, 
                          canlose=false)
  trainer1=pbLoadTrainer(trainerid1,trainername1,trainerparty1)
  if !trainer1
    pbMissingTrainer(trainerid1,trainername1,trainerparty1)
  end
  trainer2=pbLoadTrainer(trainerid2,trainername2,trainerparty2)
  if !trainer2
    pbMissingTrainer(trainerid2,trainername2,trainerparty2)
  end
  if !trainer1 || !trainer2
    return false
  end
  if $PokemonGlobal.partner
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],
       $PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      playerparty[6+i]=othertrainer.party[i]
    end
    fullparty1=true
    playertrainer=[$Trainer,othertrainer]
    doublebattle=true
  else
    playerparty=$Trainer.party
    playertrainer=$Trainer
    fullparty1=false
  end
  combinedParty=[]
  for i in 0...trainer1[2].length
    combinedParty[i]=trainer1[2][i]
  end
  for i in 0...trainer2[2].length
    combinedParty[6+i]=trainer2[2][i]
  end
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,
     playerparty,combinedParty,playertrainer,[trainer1[0],trainer2[0]])
  trainerbgm=pbGetTrainerBattleBGM([trainer1[0],trainer2[0]])
  battle.fullparty1=fullparty1
  battle.fullparty2=true
  battle.doublebattle=battle.pbDoubleBattleAllowed?()
  battle.endspeech=endspeech1
  battle.endspeech2=endspeech2
  battle.items=[trainer1[1],trainer2[1]]
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2 && battle.endspeech2!=""
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  pbBattleAnimation(trainerbgm) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     if $PokemonGlobal.partner
       pbHealAll if !$game_switches[329]
       for i in $PokemonGlobal.partner[3]; i.heal; end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  return (decision==1)
end



def pbSBTrainerBattle(trainer,endspeech,doulebattle=false,canlose=false)
    if $Trainer.pokemonCount==0 || trainer.pokemonCount==0
    Kernel.pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    return false
  end
 

    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,$Trainer.party,trainer.party,$Trainer,trainer)
   # battle.fullparty1=fullparty1
#    battle.doublebattle=doublebattle ? battle.pbDoubleBattleAllowed?() : false
    battle.endspeech=endspeech
   # battle.items=trainer[1]
    trainerbgm=pbGetTrainerBattleBGM(trainer)

  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
#        Kernel.pbMessage($Trainer.clothes[5].to_s)

  pbBattleAnimation(trainerbgm,trainer.trainertype,trainer.name) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     else
       Events.onEndBattle.trigger(nil,decision)
       if decision==1
         if $PokemonTemp.waitingTrainer
           pbMapInterpreter.pbSetSelfSwitch(
              $PokemonTemp.waitingTrainer[1],"A",true
           )
         end
       end
     end
  }
  Input.update
  $PokemonTemp.waitingTrainer=nil
  return (decision==1)
end


def pbTrainerBattle(trainerid,trainername,endspeech,
                    doublebattle=false,trainerparty=0,canlose=false,doPokegear=false)
  
  if !$game_switches[693]
    #    Kernel.pbMessage($Trainer.clothes[5].to_s) if $Trainer && $Trainer.clothes && $Trainer.clothes[5]
    if $Trainer.pokemonCount==0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
      return false
    end
    if !$PokemonTemp.waitingTrainer && $Trainer.ablePokemonCount>1 &&
       pbMapInterpreterRunning?
      thisEvent=pbMapInterpreter.get_character(0)
      triggeredEvents=$game_player.pbTriggeredTrainerEvents([2],false)
      otherEvent=[]
      for i in triggeredEvents
        if i.id!=thisEvent.id && !$game_self_switches[[$game_map.map_id,i.id,"A"]]
          otherEvent.push(i)
        end
      end
      if otherEvent.length==1
        e4maps=[770,771,772,773,491,774,431,430,428,429]
        e4scale=e4maps.include?($game_map.map_id)
        e4scale = e4scale && !$game_switches[346] && !$game_switches[347]
      
        if !doPokegear && !$game_switches[234] && 
           ((!$game_switches[321] || ($game_switches[321] && e4scale)) || 
           $game_switches[369] || $game_map.map_id==759 || $game_map.map_id==799) && !$game_switches[90] && 
           !$game_switches[267] && !$game_switches[293] && !$game_switches[285]
          trainer=pbLoadTrainer(trainerid,trainername,trainerparty,e4scale)
        end
        trainer=pbLoadMiror(trainerid,trainername,trainerparty) if $game_switches[234]
        trainer=pbLoadClone(trainerid,trainername,trainerparty) if $game_switches[120]
        trainer=pbLoadGymBattle(trainerid,trainername,trainerparty) if $game_switches[267]
        trainer=pbLoadTrainerScaled(trainerid,trainername,trainerparty) if $game_switches[293]
        #trainer=pbLoadTrainerScaled(trainerid,trainername,trainerparty,true)
        trainer=pbLoadTrainerRandom(trainerid,trainername,trainerparty) if $game_switches[285]
        trainer=pbLoadTrainerRandomized(trainerid,trainername,trainerparty) if $game_switches[321] && $game_map.map_id!=759 && !e4scale && $game_map.map_id!=799
        trainer=pbLoadPokegearTrainer(trainerid,trainername,trainerparty) if doPokegear
        if !trainer
          pbMissingTrainer(trainerid,trainername,trainerparty)
          return false
        end
        if trainer[2].length<=3
          $PokemonTemp.waitingTrainer=[trainer,thisEvent.id,endspeech,doublebattle]
          return false
        end
      end
    end
  
    e4maps=[770,771,772,773,491,774,431,430,428,429]
    e4scale=e4maps.include?($game_map.map_id)

    trainer=pbLoadTrainer(trainerid,trainername,trainerparty,e4scale) if !doPokegear && !$game_switches[234] && ((!$game_switches[321] || ($game_switches[321] && e4scale)) || $game_switches[369] || $game_map.map_id==759 || $game_map.map_id==799) && !$game_switches[90] && !$game_switches[267] && !$game_switches[293] && !$game_switches[285]
    trainer=pbLoadMiror(trainerid,trainername,trainerparty) if $game_switches[234]
    trainer=pbLoadClone(trainerid,trainername,trainerparty) if $game_switches[120]
    trainer=pbLoadGymBattle(trainerid,trainername,trainerparty) if $game_switches[267]
    trainer=pbLoadTrainerScaled(trainerid,trainername,trainerparty) if $game_switches[293]
    trainer=pbLoadTrainerRandom(trainerid,trainername,trainerparty) if $game_switches[285]
    #  trainer=pbLoadTrainerScaled(trainerid,trainername,trainerparty,true) if e4scale
    trainer=pbLoadTrainerRandomized(trainerid,trainername,trainerparty) if $game_switches[321] && $game_map.map_id!=759 && !e4scale && $game_map.map_id!=799
    trainer=pbLoadPokegearTrainer(trainerid,trainername,trainerparty) if doPokegear
    if !trainer
      pbMissingTrainer(trainerid,trainername,trainerparty)
      return false
    end
    if $PokemonGlobal.partner && ($PokemonTemp.waitingTrainer || doublebattle)
      othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
      othertrainer.id=$PokemonGlobal.partner[2]
      othertrainer.party=$PokemonGlobal.partner[3]
      playerparty=[]
      for i in 0...$Trainer.party.length
        playerparty[i]=$Trainer.party[i]
      end
      for i in 0...othertrainer.party.length
        playerparty[6+i]=othertrainer.party[i]
      end
      fullparty1=true
      playertrainer=[$Trainer,othertrainer]
      doublebattle=true
    else
      playerparty=$Trainer.party
      playertrainer=$Trainer
      fullparty1=false
    end
    if $PokemonTemp.waitingTrainer
      combinedParty=[]
      fullparty2=false
      if false
        if $PokemonTemp.waitingTrainer[0][2].length>3
          raise _INTL("Opponent 1's party has more than three Pokémon, which is not allowed")
        end
        if trainer[2].length>3
          raise _INTL("Opponent 2's party has more than three Pokémon, which is not allowed")
        end
      elsif $PokemonTemp.waitingTrainer[0][2].length>3 || trainer[2].length>3
        for i in 0...$PokemonTemp.waitingTrainer[0][2].length
          combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
        end
        for i in 0...trainer[2].length
          combinedParty[6+i]=trainer[2][i]
        end
        fullparty2=true
      else
        for i in 0...$PokemonTemp.waitingTrainer[0][2].length
          combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
        end
        for i in 0...trainer[2].length
          combinedParty[3+i]=trainer[2][i]
        end
        fullparty2=false
      end
      scene=pbNewBattleScene
      battle=PokeBattle_Battle.new(scene,playerparty,combinedParty,playertrainer,
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
      trainerbgm=pbGetTrainerBattleBGM(
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
      battle.fullparty1=fullparty1
      battle.fullparty2=fullparty2
      battle.doublebattle=battle.pbDoubleBattleAllowed?()
      battle.endspeech=$PokemonTemp.waitingTrainer[2]
      battle.endspeech2=endspeech
      battle.items=[$PokemonTemp.waitingTrainer[0][1],trainer[1]]
    else
      scene=pbNewBattleScene
      battle=PokeBattle_Battle.new(scene,playerparty,trainer[2],playertrainer,trainer[0])
      battle.fullparty1=fullparty1
      battle.doublebattle=doublebattle ? battle.pbDoubleBattleAllowed?() : false
      battle.endspeech=endspeech
      battle.items=trainer[1]
      trainerbgm=pbGetTrainerBattleBGM(trainer[0])
    end
    if Input.press?(Input::CTRL) && $DEBUG
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
      Kernel.pbMessage(_INTL("AFTER LOSING..."))
      Kernel.pbMessage(battle.endspeech)
      Kernel.pbMessage(battle.endspeech2) if battle.endspeech2
      if $PokemonTemp.waitingTrainer
        pbMapInterpreter.pbSetSelfSwitch(
           $PokemonTemp.waitingTrainer[1],"A",true
        )
        $PokemonTemp.waitingTrainer=nil
      end
      return true
    end

    Events.onStartBattle.trigger(nil,nil)
    battle.internalbattle=true
    pbPrepareBattle(battle)
    restorebgm=true
    decision=0
    #        Kernel.pbMessage($Trainer.clothes[5].to_s)

    pbBattleAnimation(trainerbgm,trainer[0].trainertype,trainer[0].name) { 
       pbSceneStandby {
          decision=battle.pbStartBattle(canlose,false)
       }
       if $PokemonGlobal.partner
         pbHealAll if !$game_switches[329]
         for i in $PokemonGlobal.partner[3]; i.heal; end
       end
       if decision==2 || decision==5
         if canlose
           for i in $Trainer.party; i.heal; end
           for i in 0...10
             Graphics.update
           end
         else
           $game_system.bgm_unpause
           $game_system.bgs_unpause
           
           Kernel.pbStartOver
         end
       else
         Events.onEndBattle.trigger(nil,decision)
         if decision==1
           if $PokemonTemp.waitingTrainer
             pbMapInterpreter.pbSetSelfSwitch(
                $PokemonTemp.waitingTrainer[1],"A",true
             )
           end
         end
       end
    }
    Input.update
    $PokemonTemp.waitingTrainer=nil
    return (decision==1)
  end
end