module EncounterTypes
  Land         = 0
  Cave         = 1
  Water        = 2
  RockSmash    = 3
  OldRod       = 4
  GoodRod      = 5
  SuperRod     = 6
  HeadbuttLow  = 7
  HeadbuttHigh = 8
  LandMorning  = 9
  LandDay      = 10
  LandNight    = 11
  BugContest   = 12

  Names=[
    "Land",
    "Cave",
    "Water",
    "RockSmash",
    "OldRod",
    "GoodRod",
    "SuperRod",
    "HeadbuttLow",
    "HeadbuttHigh",
    "LandMorning",
    "LandDay",
    "LandNight",
    "BugContest",
  ]
  EnctypeChances=[
    [20,20,10,10,10,10,5,5,4,4,1,1],
    [20,20,10,10,10,10,5,5,4,4,1,1],
    [60,30,5,4,1],
    [60,30,5,4,1],
    [70,30],
    [60,20,20],
    [40,40,15,4,1],
    [30,25,20,10,5,5,4,1],
    [30,25,20,10,5,5,4,1],
    [20,20,10,10,10,10,5,5,4,4,1,1],
    [20,20,10,10,10,10,5,5,4,4,1,1],
    [20,20,10,10,10,10,5,5,4,4,1,1],
    [20,20,10,10,10,10,5,5,4,4,1,1],
    [20,20,10,10,10,10,5,5,4,4,1,1]
  ]
end



class PokemonEncounters
  def initialize
    @enctypes=[]
    @density=nil
  end

  def stepcount
    return @stepcount
  end

  def clearStepCount
    @stepcount=0
  end

  def hasEncounter?(enc)
    return false if @density==nil || enc<0
    return @enctypes[enc] ? true : false  
  end

  def isCave?
    return false if @density==nil
    return @enctypes[EncounterTypes::Cave] ? true : false
  end

  def isGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight] ||
            @enctypes[EncounterTypes::BugContest]) ? true : false
  end

  def isWater?
    return false if @density==nil
    return @enctypes[EncounterTypes::Water] ? true : false
  end

  def isEncounterPossibleHere?
    if $PokemonGlobal && $PokemonGlobal.surfing
      return true
    elsif pbGetTerrainTag($game_player)==PBTerrain::Ice
      return false
    elsif self.isCave?
      return true
    elsif self.isGrass?
      return pbIsGrassTag?($game_map.terrain_tag($game_player.x,$game_player.y))
    else
      return false
    end
  end

  def pbEncounterType
    if $PokemonGlobal && $PokemonGlobal.surfing
      return EncounterTypes::Water
    elsif self.isCave?
      return EncounterTypes::Cave
    elsif self.isGrass?
      time=pbGetTimeNow
      enctype=EncounterTypes::Land
      enctype=EncounterTypes::LandNight if self.hasEncounter?(EncounterTypes::LandNight) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::LandDay if self.hasEncounter?(EncounterTypes::LandDay) && PBDayNight.isDay?(time)
      enctype=EncounterTypes::LandMorning if self.hasEncounter?(EncounterTypes::LandMorning) && PBDayNight.isMorning?(time)
      if pbInBugContest?
        if self.hasEncounter?(EncounterTypes::BugContest)
          enctype=EncounterTypes::BugContest
        end
      end
      return enctype
    else
      return -1
    end
  end

  def setup(mapID)
    @density=nil
    @stepcount=0
    @enctypes=[]
    begin
      data=load_data("Data/encounters.dat")
      if data.is_a?(Hash) && data[mapID]
        @density=data[mapID][0]
        @enctypes=data[mapID][1]
      else
        @density=nil
        @enctypes=[]
      end
      rescue
      @density=nil
      @enctypes=[]
    end
  end

  def pbMapHasEncounter?(mapID,enctype)
    data=load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[mapID]
      enctypes=data[mapID][1]
      density=data[mapID][0]
    else
      return false
    end
    return false if density==nil || enctype<0
    return enctypes[enctype] ? true : false  
  end

  def pbMapEncounter(mapID,enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    data=load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[mapID]
      enctypes=data[mapID][1]
    else
      return nil
    end
    return nil if enctypes[enctype]==nil
    chances=EncounterTypes::EnctypeChances[enctype]
    rnd=rand(100)
    chosenpkmn=0
    chance=0
    for i in 0...chances.length
      chance+=chances[i]
      if rnd<chance
        chosenpkmn=i
        break
      end
    end
    encounter=enctypes[enctype][chosenpkmn]
    level=encounter[1]+rand(1+encounter[2]-encounter[1])
    return [encounter[0],level]
  end

  def pbEncounteredPokemon(enctype,tries=1)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @enctypes[enctype]==nil
    encounters = @enctypes[enctype]
    chances    = EncounterTypes::EnctypeChances[enctype]
    #rnd=rand(100)
    if $Trainer.party[0] && rand(2)==0
      type = -1
      if isConst?($Trainer.party[0].ability,PBAbilities,:STATIC) && hasConst?(PBTypes,:ELECTRIC)
        
        type = getConst(PBTypes,:ELECTRIC)
      elsif isConst?($Trainer.party[0].ability,PBAbilities,:MAGNETPULL) && hasConst?(PBTypes,:STEEL)
        type = getConst(PBTypes,:STEEL)
      end
      if type>=0
        newencs = []; newchances = []
        dexdata = pbOpenDexData
        for i in 0...encounters.length
          pbDexDataOffset(dexdata,encounters[i][0],8)
          t1 = dexdata.fgetb
          t2 = dexdata.fgetb
          if t1==type || t2==type
            newencs.push(encounters[i])
            newchances.push(chances[i])
          end
        end
        dexdata.close
        if newencs.length>0
          encounters = newencs
          chances    = newchances
        end
      end
    end
    chancetotal = 0
    chances.each {|a| chancetotal += a }
    rnd = 0
    tries.times do
      r = rand(chancetotal)
      rnd = r if rnd<r
    end
    
    chosenpkmn=0
    chance=0
    for i in 0...chances.length
      chance+=chances[i]
      if rnd<chance
        chosenpkmn=i
        break
      end
    end
    encounter = encounters[chosenpkmn]
    #encounter=@enctypes[enctype][chosenpkmn]
    return nil if !encounter
    level=encounter[1]+rand(1+encounter[2]-encounter[1])
    if $Trainer.party[0] &&
       (isConst?($Trainer.party[0].ability,PBAbilities,:HUSTLE) ||
       isConst?($Trainer.party[0].ability,PBAbilities,:VITALSPIRIT) ||
       isConst?($Trainer.party[0].ability,PBAbilities,:PRESSURE)) &&
       rand(2)==0
      level2 = encounter[1]+rand(1+encounter[2]-encounter[1])
      level = [level,level2].max
    end
    return [encounter[0],level]
  end

  def pbCanEncounter?(encounter,repel)
    return false if !encounter || !$Trainer
    return false if ($PokemonGlobal.repel>0 || repel) &&
                      $Trainer.firstAblePokemon &&
                      encounter[1]<$Trainer.firstAblePokemon.level
    #if $PokemonGlobal.repel>0 && $Trainer.party.length>0 &&
    #   encounter[1]<$Trainer.party[0].level #&& $game_map.map_id != 566
    #  return false
    #end
    if $game_system.encounter_disabled || ($DEBUG && Input.press?(Input::CTRL))
      return false
    end
    return true
  end

  def pbGenerateEncounter(enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @density==nil
    return nil if @density[enctype]==0 || !@density[enctype]
    return nil if @enctypes[enctype]==nil
    @stepcount+=1
    return nil if @stepcount<=5 # Check three steps after battle ends
    encount=@density[enctype]*16
    if $PokemonGlobal.bicycle
      encount=(encount*4/5)
    end
    if $PokemonMap.blackFluteUsed
      encount/=2
    end
    if $PokemonMap.whiteFluteUsed
      encount=(encount*3/2)
    end
    if $Trainer.party.length>0 && !$Trainer.party[0].egg?
      encount=(encount/2)
      if isConst?($Trainer.party[0].item,PBItems,:CLEANSETAG)
        encount=(encount*2/3)
      elsif isConst?($Trainer.party[0].item,PBItems,:PUREINCENSE)
        encount=(encount*2/3)
      end
      if isConst?($Trainer.party[0].ability,PBAbilities,:STENCH)
        encount=(encount/2)
      elsif isConst?($Trainer.party[0].ability,PBAbilities,:WHITESMOKE)
        encount=(encount/2)
      elsif isConst?($Trainer.party[0].ability,PBAbilities,:QUICKFEET)
        encount=(encount/2)
      elsif isConst?($Trainer.party[0].ability,PBAbilities,:SNOWCLOAK) &&
         $game_screen.weather_type==3
        encount=(encount/2)
      elsif isConst?($Trainer.party[0].ability,PBAbilities,:SANDVEIL) &&
         $game_screen.weather_type==4
        encount=(encount/2)
      elsif isConst?($Trainer.party[0].ability,PBAbilities,:SWARM)
        encount=(encount*3/2)
      elsif isConst?($Trainer.party[0].ability,PBAbilities,:ILLUMINATE)
        encount=(encount*2)
      elsif isConst?($Trainer.party[0].ability,PBAbilities,:ARENATRAP)
        encount=(encount*2)
      elsif isConst?($Trainer.party[0].ability,PBAbilities,:NOGUARD)
        encount=(encount*1.5)
      end
    end
    return nil if rand(2874)>=encount
    encpoke=pbEncounteredPokemon(enctype)
    if $Trainer.party.length>0 && !$Trainer.party[0].egg?
      if encpoke && isConst?($Trainer.party[0].ability,PBAbilities,:INTIMIDATE) &&
         encpoke[1]<=$Trainer.party[0].level-5 && rand(2)==0
        encpoke=nil
      end
      if encpoke && isConst?($Trainer.party[0].ability,PBAbilities,:KEENEYE) &&
         encpoke[1]<=$Trainer.party[0].level-5 && rand(2)==0
        encpoke=nil
      end
    end
    return encpoke
  end
end