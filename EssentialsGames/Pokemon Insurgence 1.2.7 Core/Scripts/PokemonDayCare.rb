def pbEggGenerated?
  return false if pbDayCareDeposited!=2
  return $PokemonGlobal.daycareEgg==1
end

def pbDayCareDeposited
  ret=0
  for i in 0...2
    ret+=1 if $PokemonGlobal.daycare[i][0]
  end
  return ret
end

def pbDayCareDeposit(index)
  for i in 0...2
    if !$PokemonGlobal.daycare[i][0]
      $PokemonGlobal.daycare[i][0]=$Trainer.party[index]
      $PokemonGlobal.daycare[i][1]=$Trainer.party[index].level
      $PokemonGlobal.daycare[i][0].heal
      $Trainer.party[index]=nil 
      $Trainer.party.compact!
      $PokemonGlobal.daycareEgg=0
      $PokemonGlobal.daycareEggSteps=0
      return
    end
  end
  raise _INTL("No room to deposit a Pokémon") 
end

def pbDayCareGetLevelGain(index,nameVariable,levelVariable)
  pkmn=$PokemonGlobal.daycare[index][0]
  return false if !pkmn
  $game_variables[nameVariable]=pkmn.name
  $game_variables[levelVariable]=pkmn.level-$PokemonGlobal.daycare[index][1]
  return true
end

def pbDayCareGetDeposited(index,nameVariable,costVariable)
  for i in 0...2
    if (index<0||i==index) && $PokemonGlobal.daycare[i][0]
      cost=$PokemonGlobal.daycare[i][0].level-$PokemonGlobal.daycare[i][1]
      cost+=1
      cost*=100
      $game_variables[costVariable]=cost if costVariable>=0
      $game_variables[nameVariable]=$PokemonGlobal.daycare[i][0].name if nameVariable>=0
      return
    end
  end
  raise _INTL("Can't find deposited Pokémon")
end

def pbIsDitto?(pokemon)
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,pokemon.species,31)
  compat10=dexdata.fgetb
  compat11=dexdata.fgetb
  dexdata.close
  return (compat10==13 || compat11==13)
end

def pbDayCareCompatibleGender(pokemon1,pokemon2)
  if (pokemon1.gender==1 && pokemon2.gender==0) ||
     (pokemon1.gender==0 && pokemon2.gender==1)
    return true
  end
  ditto1=pbIsDitto?(pokemon1)
  ditto2=pbIsDitto?(pokemon2)
  if ((ditto1 && !ditto2) || (ditto2 && !ditto1))
    return true
  end
  return false
end

def pbDayCareGetCompat
  if pbDayCareDeposited==2
    pokemon1=$PokemonGlobal.daycare[0][0]
    pokemon2=$PokemonGlobal.daycare[1][0]
    return 0 if (pokemon1.isShadow? rescue false)
    return 0 if (pokemon2.isShadow? rescue false)
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,pokemon1.species,31)
    compat10=dexdata.fgetb
    compat11=dexdata.fgetb
    pbDexDataOffset(dexdata,pokemon2.species,31)
    compat20=dexdata.fgetb
    compat21=dexdata.fgetb
    dexdata.close
    aryBitch=[PBSpecies::DELTAREGIROCK,PBSpecies::DELTAREGICE,PBSpecies::DELTAREGISTEEL,
             PBSpecies::DELTAMELOETTA,PBSpecies::DELTAHOOPA,PBSpecies::DELTAMUNCHLAX,
             PBSpecies::DELTABUDEW,PBSpecies::DELTAPICHU,PBSpecies::DELTAELEKID,
             PBSpecies::DELTAMAGBY,PBSpecies::DELTARIOLU]
    deltaDittoOption=(!aryBitch.include?(pokemon1.species) && !aryBitch.include?(pokemon2.species)) &&
      (pokemon1.species == PBSpecies::DELTADITTO || pokemon2.species==PBSpecies::DELTADITTO) &&
      (Kernel.getAllDeltas.include?(pokemon1.species) && Kernel.getAllDeltas.include?(pokemon2.species))
    
    if (compat10==compat20 || compat11==compat20 ||
       compat10==compat21 || compat11==compat21 ||
       compat10==13 || compat11==13 || compat20==13 || compat21==13) &&
       ((compat10!=15 && compat11!=15 && compat20!=15 && compat21!=15) || deltaDittoOption)
      if pbDayCareCompatibleGender(pokemon1,pokemon2)
        if pokemon1.species==pokemon2.species
          return (pokemon1.trainerID==pokemon2.trainerID) ? 2 : 3
        else
          return (pokemon1.trainerID==pokemon2.trainerID) ? 1 : 2
        end
      end
    end
  end
  return 0
end

def pbDayCareGetCompatibility(variable)
  $game_variables[variable]=pbDayCareGetCompat
end

def pbDayCareWithdraw(index)
  if !$PokemonGlobal.daycare[index][0]
    raise _INTL("There's no Pokémon here...")
  elsif $Trainer.party.length>=6
    raise _INTL("Can't store the Pokémon...")
  else
    $Trainer.party[$Trainer.party.length]=$PokemonGlobal.daycare[index][0]
    $PokemonGlobal.daycare[index][0]=nil
    $PokemonGlobal.daycare[index][1]=0
    $PokemonGlobal.daycareEgg=0
  end  
end

def pbDayCareChoose(text,variable)
  count=pbDayCareDeposited
  if count==0
    raise _INTL("There's no Pokémon here...")
  elsif count==1
    $game_variables[variable]=$PokemonGlobal.daycare[0][0] ? 0 : 1
  else
    choices=[]
    for i in 0...2
      pokemon=$PokemonGlobal.daycare[i][0]
      if pokemon.gender==2
        choices.push(_ISPRINTF("{1:s} (Lv{2:d})",pokemon.name,pokemon.level))
      elsif pokemon.gender==1
        choices.push(_ISPRINTF("{1:s} (F, Lv{2:d})",pokemon.name,pokemon.level))
      elsif pokemon.gender==0
        choices.push(_ISPRINTF("{1:s} (M, Lv{2:d})",pokemon.name,pokemon.level))
      end
    end
    choices.push(_INTL("CANCEL"))
    command=Kernel.pbMessage(text,choices,choices.length)
    $game_variables[variable]=(command==2) ? -1 : command
  end
end

# Given a baby species, returns the lowest possible evolution of that species
# assuming no incense is involved.
def pbGetNonIncenseLowestSpecies(baby)
  if isConst?(baby,PBSpecies,:MUNCHLAX) && hasConst?(PBSpecies,:SNORLAX)
    return getConst(PBSpecies,:SNORLAX)
  elsif isConst?(baby,PBSpecies,:WYNAUT) && hasConst?(PBSpecies,:WOBBUFFET)
    return getConst(PBSpecies,:WOBBUFFET)
  elsif isConst?(baby,PBSpecies,:HAPPINY) && hasConst?(PBSpecies,:CHANSEY)
    return getConst(PBSpecies,:CHANSEY)
  elsif isConst?(baby,PBSpecies,:MIMEJR) && hasConst?(PBSpecies,:MRMIME)
    return getConst(PBSpecies,:MRMIME)
  elsif isConst?(baby,PBSpecies,:CHINGLING) && hasConst?(PBSpecies,:CHIMECHO)
    return getConst(PBSpecies,:CHIMECHO)
  elsif isConst?(baby,PBSpecies,:BONSLY) && hasConst?(PBSpecies,:SUDOWOODO)
    return getConst(PBSpecies,:SUDOWOODO)
  elsif isConst?(baby,PBSpecies,:BUDEW) && hasConst?(PBSpecies,:ROSELIA)
    return getConst(PBSpecies,:ROSELIA)
  elsif isConst?(baby,PBSpecies,:AZURILL) && hasConst?(PBSpecies,:MARILL)
    return getConst(PBSpecies,:MARILL)
  elsif isConst?(baby,PBSpecies,:MANTYKE) && hasConst?(PBSpecies,:MANTINE)
    return getConst(PBSpecies,:MANTINE)
  elsif isConst?(baby,PBSpecies,:DELTAMUNCHLAX) && hasConst?(PBSpecies,:DELTASNORLAX)
    return getConst(PBSpecies,:DELTASNORLAX)
  elsif isConst?(baby,PBSpecies,:DELTABUDEW) && hasConst?(PBSpecies,:DELTAROSELIA)
    return getConst(PBSpecies,:DELTAROSELIA)
  end
  return baby
end

def pbDayCareGenerateEgg
  if pbDayCareDeposited!=2
    return
  elsif $Trainer.party.length>=6
    raise _INTL("Can't store the egg")
  end
  pokemon0=$PokemonGlobal.daycare[0][0]
  pokemon1=$PokemonGlobal.daycare[1][0]
  mother=nil
  father=nil
  babyspecies=0
  ditto0=pbIsDitto?(pokemon0)
  ditto1=pbIsDitto?(pokemon1)
  if (pokemon0.gender==1 || ditto0)
    babyspecies=(ditto0) ? pokemon1.species : pokemon0.species
    mother=pokemon0
    father=pokemon1
  else
    babyspecies=(ditto1) ? pokemon0.species : pokemon1.species
    mother=pokemon1
    father=pokemon0
  end
  babyspecies=pbGetBabySpecies(babyspecies)
  if isConst?(babyspecies,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    babyspecies=getConst(PBSpecies,:PHIONE)
  end
  if isConst?(babyspecies,PBSpecies,:NIDORANfE) && hasConst?(PBSpecies,:NIDORANmA)
    babyspecies=[getConst(PBSpecies,:NIDORANmA),
                 getConst(PBSpecies,:NIDORANfE)][rand(2)]
  elsif isConst?(babyspecies,PBSpecies,:NIDORANmA) && hasConst?(PBSpecies,:NIDORANfE)
    babyspecies=[getConst(PBSpecies,:NIDORANmA),
                 getConst(PBSpecies,:NIDORANfE)][rand(2)]
  elsif isConst?(babyspecies,PBSpecies,:VOLBEAT) && hasConst?(PBSpecies,:ILLUMISE)
    babyspecies=[getConst(PBSpecies,:VOLBEAT),
                 getConst(PBSpecies,:ILLUMISE)][rand(2)]
  elsif isConst?(babyspecies,PBSpecies,:ILLUMISE) && hasConst?(PBSpecies,:VOLBEAT)
    babyspecies=[getConst(PBSpecies,:VOLBEAT),
                 getConst(PBSpecies,:ILLUMISE)][rand(2)]
  elsif isConst?(babyspecies,PBSpecies,:MUNCHLAX) &&
        !isConst?(mother.item,PBItems,:FULLINCENSE) &&
        !isConst?(father.item,PBItems,:FULLINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:WYNAUT) &&
        !isConst?(mother.item,PBItems,:LAXINCENSE) &&
        !isConst?(father.item,PBItems,:LAXINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:HAPPINY) &&
        !isConst?(mother.item,PBItems,:LUCKINCENSE) &&
        !isConst?(father.item,PBItems,:LUCKINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:MIMEJR) &&
        !isConst?(mother.item,PBItems,:ODDINCENSE) &&
        !isConst?(father.item,PBItems,:ODDINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:CHINGLING) &&
        !isConst?(mother.item,PBItems,:PUREINCENSE) &&
        !isConst?(father.item,PBItems,:PUREINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:BONSLY) &&
        !isConst?(mother.item,PBItems,:ROCKINCENSE) &&
        !isConst?(father.item,PBItems,:ROCKINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:BUDEW) &&
        !isConst?(mother.item,PBItems,:ROSEINCENSE) &&
        !isConst?(father.item,PBItems,:ROSEINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:AZURILL) &&
        !isConst?(mother.item,PBItems,:SEAINCENSE) &&
        !isConst?(father.item,PBItems,:SEAINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:MANTYKE) &&
        !isConst?(mother.item,PBItems,:WAVEINCENSE) &&
        !isConst?(father.item,PBItems,:WAVEINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:DELTAMUNCHLAX) &&
        !isConst?(mother.item,PBItems,:ROSEINCENSE) &&
        !isConst?(father.item,PBItems,:ROSEINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  elsif isConst?(babyspecies,PBSpecies,:DELTABUDEW) &&
        !isConst?(mother.item,PBItems,:NOCTURNEINCENSE) &&
        !isConst?(father.item,PBItems,:NOCTURNEINCENSE)
    babyspecies=pbGetNonIncenseLowestSpecies(babyspecies)
  end
  # Generate egg
  egg=PokeBattle_Pokemon.new(babyspecies,EGGINITIALLEVEL,$Trainer)
  # Inheriting form
  if isConst?(babyspecies,PBSpecies,:BURMY) || 
     isConst?(babyspecies,PBSpecies,:SHELLOS) || 
     isConst?(babyspecies,PBSpecies,:BASCULIN) || 
     isConst?(babyspecies,PBSpecies,:FLABEBE)
    egg.form=mother.form
  end
  # Inheriting Moves
  moves=[]
  othermoves=[] 
  # Initial Moves
  initialmoves=egg.getMoveList
  for k in initialmoves
    if k[0]<=EGGINITIALLEVEL
      moves.push(k[1])
    else
      othermoves.push(k[1]) if pbHasMove?(mother,k[1]) && pbHasMove?(father,k[1])
    end
  end
  # Inheriting Egg Moves
  pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
     f.pos=(babyspecies-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         atk=f.fgetw
         moves.push(atk) if pbHasMove?(father,atk) || pbHasMove?(mother,atk)
         i+=1
       end
     end
  }
  # Inheriting Machine Moves
  for i in 0...$ItemData.length
    next if !$ItemData[i]
    atk=$ItemData[i][ITEMMACHINE]
    next if !atk || atk==0
    if pbSpeciesCompatible?(babyspecies,atk)
      moves.push(atk) if pbHasMove?(father,atk)
    end
  end
  # Inheriting Natural Moves
  for move in othermoves
    moves.push(move)
  end
  # Volt Tackle
  lightball=false
if (isConst?(father.species,PBSpecies,:PIKACHU) || 
      isConst?(father.species,PBSpecies,:RAICHU) || 
      isConst?(father.species,PBSpecies,:DELTAPIKACHU)|| 
      isConst?(father.species,PBSpecies,:DELTARAICHU)) && 
      isConst?(father.item,PBItems,:LIGHTBALL)
    lightball=true
  end
  if (isConst?(mother.species,PBSpecies,:PIKACHU) || 
      isConst?(mother.species,PBSpecies,:RAICHU) || 
      isConst?(mother.species,PBSpecies,:DELTAPIKACHU) || 
      isConst?(mother.species,PBSpecies,:DELTARAICHU)) && 
      isConst?(mother.item,PBItems,:LIGHTBALL)
    lightball=true
  end
  if lightball && isConst?(babyspecies,PBSpecies,:PICHU) &&
     hasConst?(PBMoves,:VOLTTACKLE)
    moves.push(getConst(PBMoves,:VOLTTACKLE))
  end
  if lightball && isConst?(babyspecies,PBSpecies,:DELTAPICHU) &&
     hasConst?(PBMoves,:VOLTTACKLE)
    moves.push(getConst(PBMoves,:VOLTTACKLE))
  end
  moves|=[] # remove duplicates
  # Assembling move list
  finalmoves=[]
  listend=moves.length-4
  listend=0 if listend<0
  j=0
  for i in listend..listend+3
    moveid=(i>=moves.length) ? 0 : moves[i]
    finalmoves[j]=PBMove.new(moveid)
    j+=1
  end 
  # Inheriting Individual Values
  ivcombos=[
     [0,1,2],[0,1,3],[0,1,4],
     [0,1,5],[0,2,3],[0,2,4],
     [0,2,5],[0,3,4],[0,3,5],
     [0,4,5],[1,2,3],[1,2,4],
     [1,2,5],[1,3,4],[1,3,5],
     [1,4,5],[2,3,4],[2,3,5],
     [2,4,5],[3,4,5]
  ]
  ivs=[]
  ivs[0]=rand(32)
  ivs[1]=rand(32)
  ivs[2]=rand(32)
  ivs[3]=rand(32)
  ivs[4]=rand(32)
  ivs[5]=rand(32)
=begin
  ivcombo=ivcombos[rand(ivcombos.length)]
  for i in 0...3
    if rand(2)==0
      ivs[ivcombo[i]]=mother.iv[ivcombo[i]]
    else
      ivs[ivcombo[i]]=father.iv[ivcombo[i]]
    end
  end
=end
  numberOfIVs = 3
  numberOfIVs = 5 if isConst?(mother.item,PBItems,:DESTINYKNOT) || isConst?(father.item,PBItems,:DESTINYKNOT)

  # Kernel.pbMessage("begin")
  ivsPassedDown=0
  parentsIVs=[]
  for i in 0..mother.iv.length-1
    parentsIVs.push(mother.iv[i])
  end
  for i in 0..father.iv.length-1
    parentsIVs.push(father.iv[i])
  end
  stringTemp=""
  for i in parentsIVs
    stringTemp+=i.to_s
    stringTemp+=" "
  end
   #   Kernel.pbMessage(stringTemp)
  fiveIVs=[]
  amountOfIVs=0
  while 1==1
    nowVar=rand(12)
    if (nowVar <= numberOfIVs && fiveIVs[nowVar]==nil && fiveIVs[nowVar+6]==nil) || (nowVar >= 6 && (nowVar/2)-(nowVar/2).floor > 0) || (nowVar >= 6 && fiveIVs[nowVar-6]==nil)
      fiveIVs[nowVar]=true 
      amountOfIVs += 1
    end
    amountofivs=0
    for i in fiveIVs
      amountofivs+=1 if i
    end
    break if amountofivs >= numberOfIVs
  end
  amountofivs=0
  for i in fiveIVs
    amountofivs+=1 if i
  end
  #Kernel.pbMessage(amountofivs.to_s)
  for i in 0..11
    if fiveIVs[i]==true
      if i >= 6
        ivs[i-6]=parentsIVs[i]
        # Kernel.pbMessage(ivs[i-6].to_s+" "+i.to_s+" "+amountOfIVs.to_s)
        #         Kernel.pbMessage(amountOfIVs.to_s)
      else
        ivs[i]=parentsIVs[i]
        #    Kernel.pbMessage(ivs[i].to_s+" "+i.to_s+" "+amountOfIVs.to_s)
        #                  Kernel.pbMessage(amountOfIVs.to_s)
      end
    end
  end
  
  pid=rand(65536)
  pid|=(rand(65536)<<16)
  egg.personalID=pid
  # Inheriting nature
  inherit0=isConst?(mother.item,PBItems,:EVERSTONE)
  inherit1=isConst?(father.item,PBItems,:EVERSTONE)
  if inherit0 || inherit1
    newnature=(inherit0) ? mother.nature : father.nature
    newnature=father.nature if inherit1 && rand(2)==0
    egg.setNature(newnature)
  end

  if isConst?(mother.item,PBItems,:POWERBRACER)
    ivs[1]=mother.iv[1]
  end
    if isConst?(father.item,PBItems,:POWERBRACER)
    ivs[1]=father.iv[1]
  end
  if isConst?(mother.item,PBItems,:POWERWEIGHT)
    ivs[0]=mother.iv[0]
  end
  if isConst?(father.item,PBItems,:POWERWEIGHT)
    ivs[0]=father.iv[0]
  end
  if isConst?(mother.item,PBItems,:POWERBELT)
    ivs[2]=mother.iv[2]
  end
  if isConst?(father.item,PBItems,:POWERBELT)
    ivs[2]=father.iv[2]
  end
  if isConst?(mother.item,PBItems,:POWERLENS)
    ivs[4]=mother.iv[4]
  end
if isConst?(father.item,PBItems,:POWERLENS)
    ivs[4]=father.iv[4]
  end
  if isConst?(mother.item,PBItems,:POWERBAND)
    ivs[5]=mother.iv[5]
  end
  if isConst?(father.item,PBItems,:POWERBAND)
    ivs[5]=father.iv[5]
  end
  if isConst?(mother.item,PBItems,:POWERANKLET)
    ivs[3]=mother.iv[3]
  end
  if isConst?(father.item,PBItems,:POWERANKLET)
    ivs[3]=father.iv[3]
  end
  # Masuda method
  shinyretries=0
  shinyretries+=6 if father.language!=mother.language
  shinyretries+=2 if hasConst?(PBItems,:SHINYCHARM) &&
                     $PokemonBag.pbQuantity(PBItems::SHINYCHARM)>0
  if shinyretries>0
    for i in 0...shinyretries
      break if egg.isShiny?
      egg.personalID=rand(65536)|(rand(65536)<<16)
    end
  end
  
  #if getConst(PBItems,:SHINYCHARM) && $PokemonBag.pbQuantity(PBItems::SHINYCHARM)>0
  #    egg.makeNotShiny
  #    egg.makeShiny if rand(1024)==0
  #else
  #  for i in 0...2   # 3 times as likely
  #    egg.personalID=rand(65536)|(rand(65536)<<16) if !egg.isShiny?
  # end
  #if father.language!=mother.language
  #  if getConst(PBItems,:SHINYCHARM) && $PokemonBag.pbQuantity(PBItems::SHINYCHARM)>0
  #    egg.makeNotShiny
  #    egg.makeShiny if rand(1024)==0
  #  else
  #    for i in 0...11   # 12 times as likely
  #      if !egg.isShiny?
  #        egg.personalID=rand(65536)|(rand(65536)<<16)
  #      end
  #    end
  #  end
  #end
  # Inheriting ability from the mother
  if !ditto0 && !ditto1
    if mother.abilityflag && mother.abilityIndex==2
      egg.setAbility(2) if rand(10)<6
    else
      if rand(10)<8
        egg.setAbility(mother.abilityIndex.to_i)
      else
        egg.setAbility((mother.abilityIndex.to_i+1)%2)
      end
    end
  else
    if (isConst?(mother.species,PBSpecies,:DITTO) && !isConst?(father.species,PBSpecies,:DITTO)) ||
       (isConst?(mother.species,PBSpecies,:DELTADITTO) && !isConst?(father.species,PBSpecies,:DELTADITTO))
      if father.abilityflag && father.abilityIndex==2
        egg.setAbility(2) if rand(10)<6
      else
        if rand(10)<8
          egg.setAbility(father.abilityIndex.to_i)
        else
          egg.setAbility((father.abilityIndex.to_i+1)%2)
        end
      end
       #egg.setAbility(father.abilityIndex)
    elsif (!isConst?(mother.species,PBSpecies,:DITTO) && isConst?(father.species,PBSpecies,:DITTO)) ||
      (!isConst?(mother.species,PBSpecies,:DELTADITTO) && isConst?(father.species,PBSpecies,:DELTADITTO))
      if mother.abilityflag && mother.abilityIndex==2
        egg.setAbility(2) if rand(10)<6
      else
        num=rand(10)
        if num<8
          egg.setAbility(mother.abilityIndex.to_i)
        else
          egg.setAbility((mother.abilityIndex.to_i+1)%2)
        end
      end
      #egg.setAbility(mother.abilityIndex)
    end
  end
  
  egg.iv[0]=ivs[0]
  egg.iv[1]=ivs[1]
  egg.iv[2]=ivs[2]
  egg.iv[3]=ivs[3]
  egg.iv[4]=ivs[4]
  egg.iv[5]=ivs[5]
  egg.moves[0]=finalmoves[0]
  egg.moves[1]=finalmoves[1]
  egg.moves[2]=finalmoves[2]
  egg.moves[3]=finalmoves[3]
  egg.calcStats
  egg.obtainText=_INTL("Day-Care Couple")
  egg.name=_INTL("Egg")
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,babyspecies,21)
  eggsteps=dexdata.fgetw
  dexdata.close
  egg.eggsteps=eggsteps
  if rand(65536)<POKERUSCHANCE
    egg.givePokerus
  end
  $Trainer.party[$Trainer.party.length]=egg
end

def pbHatch(pokemon)
  if !pbHatchAnimation(pokemon)
    Kernel.pbMessage(_INTL("Huh?\1"))
    Kernel.pbMessage(_INTL("...\1"))
    Kernel.pbMessage(_INTL("... .... .....\1"))
    Kernel.pbMessage(_INTL("{1} hatched from the Egg!",speciesname))
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon)

end

    
end

def mc(string,color)
    if color=="blue" || color=="b"
      return "<c2=65467b14>"+string+"</c2>"
    end
    if color=="red" || color=="r"
      return "<c2=043c3aff>"+string+"</c2>"
    end
  end


Events.onStepTaken+=proc {|sender,e|
   next if !$Trainer
   if $game_variables[141] > 0
     $game_variables[141] = $game_variables[141]-1
     if $game_variables[141]==0
       $game_map.need_refresh=true
     end
   end
   
   if $currentDexSearch != nil && ($game_player.pbIsRunning? || $PokemonGlobal.bicycle)
            Kernel.pbMessage("Oh, the Pokemon ran away!")
            Kernel.pbMessage("Try moving a little slower!")
            $currentDexSearch = nil
   end
   
   
   if $game_variables[22]==1 && !$game_switches[404] && rand(1000)==0
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Hey, kid! It's me, the Director!")
       Kernel.pbMessage("Listen, you were a hit! People love ya on TV!")
       Kernel.pbMessage("Would you mind coming back to the Broadcast Tower?")
       Kernel.pbMessage("We need to start filming the next episode right away!")
      $game_switches[404]=true
    end
    
    if $game_variables[22]==2 && !$game_switches[404] && rand(2000)==0 &&
      $game_switches[7]
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Hey, kid! It's me, the Director!")
       Kernel.pbMessage("Listen, you were a hit! People love ya on TV!")
       Kernel.pbMessage("Would you mind coming back to the Broadcast Tower?")
       Kernel.pbMessage("We need to start filming the next episode right away!")
      $game_switches[404]=true
   end

   if $game_variables[22]==3 && !$game_switches[404] && rand(2000)==0 &&
      $game_switches[9]
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Hey, kid! It's me, the Director!")
       Kernel.pbMessage("Listen, you were a hit! People love ya on TV!")
       Kernel.pbMessage("Would you mind coming back to the Broadcast Tower?")
       Kernel.pbMessage("We need to start filming the next episode right away!")
      $game_switches[404]=true
    end
    if $game_variables[22]==4 && !$game_switches[404] && rand(2000)==0 && ($game_switches[152])
      $game_switches[11]
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Hey, kid! It's me, the Director!")
       Kernel.pbMessage("Listen, you were a hit! People love ya on TV!")
       Kernel.pbMessage("Would you mind coming back to the Broadcast Tower?")
       Kernel.pbMessage("We need to start filming the next episode right away!")
      $game_switches[404]=true
   end
    if $game_variables[22]==5 && !$game_switches[404] && rand(8000)==0 
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Hey, kid! It's me, the Director!")
       Kernel.pbMessage("Listen, you were a hit! People love ya on TV!")
       Kernel.pbMessage("Would you mind coming back to the Broadcast Tower?")
       Kernel.pbMessage("We need to start filming the next episode right away!")
      $game_switches[404]=true
    end
    if $game_variables[22]==6 && !$game_switches[404] && rand(5000)==0 && $game_switches[12]
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Hey, kid! It's me, the Director!")
       Kernel.pbMessage("Listen, you were a hit! People love ya on TV!")
       Kernel.pbMessage("Would you mind coming back to the Broadcast Tower?")
       Kernel.pbMessage("We need to start filming the next episode right away!")
      $game_switches[404]=true
    end
    if $game_variables[49]>=1 && !$game_switches[589] && 
#      (!$game_switches[495] || $game_switches[506]) &&
      $game_switches[467] && rand(100)==0 
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Hey, uh..."+$Trainer.name+", right?")
       Kernel.pbMessage("You might remember me. I'm Professor Pine.")
       Kernel.pbMessage("From the Scientist's Club? In Koril Town?")
       Kernel.pbMessage("You helped us out with a rogue Kabutops and several other fossils... do you remember?")
       Kernel.pbMessage("Well, I hope you do. You're awfully quiet.")
       Kernel.pbMessage("Listen- we have another mission for you, if you'll have it.")
       Kernel.pbMessage("It's a big one... but it's an amazing one.")
       Kernel.pbMessage("If you're interested, meet me in Suntouched City, on the south end.")
       Kernel.pbMessage("See you there!")
      $game_switches[589]=true
   end
    
    if $game_variables[486] && $game_switches[489] && 
           (!$game_switches[495] || $game_switches[506]) &&

           (!$game_switches[589] || $game_switches[459]) &&

     !$game_switches[488] && rand(300)==0
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Hey, it's... it's Damian.")
       Kernel.pbMessage("Listen... I'm still....")
       Kernel.pbMessage("I'm still sorting through all my memories from when I was weird.")
       Kernel.pbMessage("Trying to piece together what happened, y'know?")
       Kernel.pbMessage("And just today, well, I heard there was a nasty storm in Maelstrom 9.")
       Kernel.pbMessage("There are some... things I remember about that place.")
       Kernel.pbMessage("Nothing's super clear, but...")
       Kernel.pbMessage("I need to see for myself.")
       Kernel.pbMessage("It would mean the world to me if you'd come with.")
       Kernel.pbMessage("I might need help with whatever's causing the storms, too.")
      $game_switches[488]=true
    end
    
    if ($game_switches[490] || !$game_switches[488]) &&  #not currently doing 30000 leagues
      $game_switches[467] && !$game_switches[495]
      rand(600)== 0
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Bzzt! Bzzt!")
       Kernel.pbMessage("Hey, "+$Trainer.name+", it's Orion!!!")
       Kernel.pbMessage("Please tell me you're here. We need to talk.")
       Kernel.pbMessage("I need your help. It's about Reshiram.")
       Kernel.pbMessage("Please, please, please, come to my Gym.")
       Kernel.pbMessage("The one in Suntouched City. Hurry!!")

      
       $game_switches[495]=true

    end
=begin
    if $game_switches[598] && !$game_switches[604] && rand(400)
        Kernel.pbMessage("... ... ...")
        Kernel.pbMessage("The phone is ringing...")
        Kernel.pbMessage("... ... ...")
        Kernel.pbMessage("Hello?")
        Kernel.pbMessage("Is anyone there?")
        Kernel.pbMessage("We made a mistake.")
        Kernel.pbMessage("Pass this message onto "+pbGetUserName()+"...")
        Kernel.pbMessage("We've confined the portal the ancient spire in the sea.")
        Kernel.pbMessage("Please, help...")
        pbGetUserName()
        $game_switches[604]=true
      end
=end
   
   if $game_switches[266]
     generateTest=500
     if pbGet(97)==100
         generateTest=10
     end
     if pbGet(97)==90
         generateTest=18
       end
       if pbGet(97)==80
         generateTest=32
       end
       if pbGet(97)==70
         generateTest=48
       end
       if pbGet(97)==60
         generateTest=60
         end
       if pbGet(97)==50
         generateTest=80
       end
       if pbGet(97)==40
         generateTest=108
       end
       if pbGet(97)==30
         generateTest=148
       end
       if pbGet(97)==20
         generateTest=180
       end
       if pbGet(97)==10
         generateTest=250
       end
       if pbGet(97)==1
         generateTest=580
     end
     $game_variables
       if $game_variables[71] == 0 && rand(generateTest)==1 #generateTest
         ChallengeChampionship.new.generateTrainer
         Kernel.pbMessage("Huh? It seems there's a challenger at the Gym!")
       end
     end
    if $game_variables[23].is_a?(Array)
   for i in $game_variables[23]
       i -= 1 if i != 0 && i != nil
     end
     end
   deposited=pbDayCareDeposited
   if deposited==2 && $PokemonGlobal.daycareEgg==0
     $PokemonGlobal.daycareEggSteps=0 if !$PokemonGlobal.daycareEggSteps
     $PokemonGlobal.daycareEggSteps+=1
     if $PokemonGlobal.daycareEggSteps==256
       $PokemonGlobal.daycareEggSteps=0
       compatval=[0,20,50,70][pbDayCareGetCompat]
       if getConst(PBItems,:OVALCHARM) && $PokemonBag.pbQuantity(PBItems::OVALCHARM)>0
         compatval=[0,60,75,85][pbDayCareGetCompat]
       end
       rnd=rand(100)
       if rnd<compatval
         # Egg is generated
         $PokemonGlobal.daycareEgg=1
       end
     end
   end
   for i in 0...2
     pkmn=$PokemonGlobal.daycare[i][0]
     next if !pkmn
     maxexp=PBExperience.pbGetMaxExperience(pkmn.growthrate)
     if pkmn.exp<maxexp
       oldlevel=pkmn.level
       pkmn.exp+=1
       if pkmn.level!=oldlevel
         pkmn.calcStats
         movelist=pkmn.getMoveList
         for i in movelist
           if i[0]==pkmn.level          # Learned a new move
             pbAutoLearnMove(pkmn,i[1])
           end
         end
       end
     end
   end
   for egg in $Trainer.party
     if egg.eggsteps>0
       egg.eggsteps-=1 if !$game_switches[136]
       for i in $Trainer.party
         if !i.egg? && (isConst?(i.ability,PBAbilities,:FLAMEBODY) ||
                        isConst?(i.ability,PBAbilities,:MAGMAARMOR))
           egg.eggsteps-=1 if !$game_switches[136]
           break
         end
       end
       if egg.eggsteps<=0
         egg.eggsteps=0
         pbHatch(egg)
       end
     end
   end
}