module BallHandlers
  IsUnconditional=ItemHandlerHash.new
  ModifyCatchRate=ItemHandlerHash.new
  OnCatch=ItemHandlerHash.new

  def self.isUnconditional?(ball,battle,battler)
    if !IsUnconditional[ball]
      return false
    end
    return IsUnconditional.trigger(ball,battle,battler)
  end

  def self.modifyCatchRate(ball,catchRate,battle,battler)
    if !ModifyCatchRate[ball]
      return catchRate
    end
    return ModifyCatchRate.trigger(ball,catchRate,battle,battler)
  end

  def self.onCatch(ball,battle,pokemon)
    if OnCatch[ball]
      OnCatch.trigger(ball,battle,pokemon)
    end
  end
end



def pbBallTypeToBall(balltype)
  if $BallTypes[balltype]
    ret=getID(PBItems,$BallTypes[balltype])
    return ret if ret!=0
  end
  if $BallTypes[0]
    ret=getID(PBItems,$BallTypes[0])
    return ret if ret!=0
  end
  return getID(PBItems,:POKEBALL)
end

def pbGetBallType(ball)
  ball=getID(PBItems,ball)
  for key in $BallTypes.keys
    if isConst?(ball,PBItems,$BallTypes[key])
      return key
    end
  end
  return 0
end

################################

$BallTypes={
   0=>:POKEBALL,
   1=>:GREATBALL,
   2=>:SAFARIBALL,
   3=>:ULTRABALL,
   4=>:MASTERBALL,
   5=>:NETBALL,
   6=>:DIVEBALL,
   7=>:NESTBALL,
   8=>:REPEATBALL,
   9=>:TIMERBALL,
   10=>:LUXURYBALL,
   11=>:PREMIERBALL,
   12=>:DUSKBALL,
   13=>:HEALBALL,
   14=>:QUICKBALL,
   15=>:CHERISHBALL,
   16=>:FASTBALL,
   17=>:LEVELBALL,
   18=>:LUREBALL,
   19=>:HEAVYBALL,
   20=>:LOVEBALL,
   21=>:FRIENDBALL,
   22=>:MOONBALL,
   23=>:SPORTBALL,
   24=>:NUZLOCKEBALL,
   25=>:ANCIENTBALL,
   26=>:DELTABALL,
   27=>:SNOREBALL,
   28=>:SHINYBALL,
   29=>:SYNCBALL,
   30=>:MASTERBALL2,

}

BallHandlers::ModifyCatchRate.add(:ANCIENTBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=8 if !Kernel.checkIsIDNonLegend(battler.pokemon.species)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:DELTABALL,proc{|ball,catchRate,battle,battler|
   catchRate*=4 if Kernel.getAllDeltas.include?(battler.pokemon.species)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:SNOREBALL,proc{|ball,catchRate,battle,battler|
   #if Kernel.getAllDeltas.include?(battler.pokemon.species)
   if battler.pbCanSleep?(nil,true)
      battler.status=PBStatuses::SLEEP
    battler.statusCount=2
    battler.pbCancelMoves
   end
   next catchRate
})

BallHandlers::IsUnconditional.add(:SHINYBALL,proc{|ball,battle,battler|
  if battler.pokemon.isShiny?
   next true
 end
 next false
})
=begin
BallHandlers::ModifyCatchRate.add(:SYNCBALL,proc{|ball,catchRate,battle,battler|
   if battler.
   next catchRate
})
=end
BallHandlers::ModifyCatchRate.add(:GREATBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*3/2).floor
})

BallHandlers::ModifyCatchRate.add(:SAFARIBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*3/2).floor
})

BallHandlers::ModifyCatchRate.add(:ULTRABALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*2).floor
})

BallHandlers::ModifyCatchRate.add(:NUZLOCKEBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*2.5).floor
})
BallHandlers::OnCatch.add(:NUZLOCKEBALL,proc{|ball,battle,pokemon|
   pokemon.heal
})
BallHandlers::IsUnconditional.add(:MASTERBALL,proc{|ball,battle,battler|
   next true
})
BallHandlers::IsUnconditional.add(:MASTERBALL2,proc{|ball,battle,battler|
   next true
})

BallHandlers::ModifyCatchRate.add(:NETBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=3 if battler.pbHasType?(:BUG) || battler.pbHasType?(:WATER)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:DIVEBALL,proc{|ball,catchRate,battle,battler|
   catchRate=(catchRate*7/2).floor if battle.environment==PBEnvironment::Underwater ||
                                      battle.environment==PBEnvironment::MovingWater ||
                                      battle.environment==PBEnvironment::StillWater ||
                                      $PokemonTemp.encounterType==EncounterTypes::OldRod ||
                                      $PokemonTemp.encounterType==EncounterTypes::GoodRod ||
                                      $PokemonTemp.encounterType==EncounterTypes::SuperRod
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:NESTBALL,proc{|ball,catchRate,battle,battler|
   if battler.level<=30
     catchRate*=(41-battler.level)/10
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:REPEATBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=3 if battle.pbPlayer.owned[battler.species]
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:TIMERBALL,proc{|ball,catchRate,battle,battler|
   multiplier=[1+(0.3*battle.turncount),4].min
   catchRate*=multiplier
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:DUSKBALL,proc{|ball,catchRate,battle,battler|
   if PBDayNight.isNight?(pbGetTimeNow) || 
      $game_map.tileset_name == "tileset_cave" || 
      ($PokemonGlobal.nextBattleBack && $PokemonGlobal.nextBattleBack.include?("Cave")) ||
      battle.pbWeather==PBWeather::NEWMOON
     catchRate*=7/2
   end
   next catchRate
})

BallHandlers::OnCatch.add(:HEALBALL,proc{|ball,battle,pokemon|
   pokemon.heal
})

BallHandlers::ModifyCatchRate.add(:QUICKBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=5 if battle.turncount<=1
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:FASTBALL,proc{|ball,catchRate,battle,battler|
   dexdata=pbOpenDexData
   pbDexDataOffset(dexdata,battler.species,13)
   basespeed=dexdata.fgetb
   dexdata.close
   catchRate*=4 if basespeed>=100
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:LEVELBALL,proc{|ball,catchRate,battle,battler|
   pbattler=battle.battlers[0].level
   pbattler=battle.battlers[2].level if battle.battlers[2] &&
                                        battle.battlers[2].level>pbattler
   if pbattler>=battler.level*4
     catchRate*=8
   elsif pbattler>=battler.level*2
     catchRate*=4
   elsif pbattler>battler.level
     catchRate*=2
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:LUREBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=3 if $PokemonTemp.encounterType==EncounterTypes::OldRod ||
                   $PokemonTemp.encounterType==EncounterTypes::GoodRod ||
                   $PokemonTemp.encounterType==EncounterTypes::SuperRod
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:HEAVYBALL,proc{|ball,catchRate,battle,battler|
   weight=battler.weight
   if weight>4000
     catchRate+=40
   elsif weight>3000
     catchRate+=30
   elsif weight>=2050
     catchRate+=20
   else
     catchRate-=20
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:LOVEBALL,proc{|ball,catchRate,battle,battler|
   pbattler=battle.battlers[0]
   pbattler2=battle.battlers[2] if battle.battlers[2]
   if pbattler.species==battler.species &&
      ((battler.gender==0 && pbattler.gender==1) ||
      (battler.gender==1 && pbattler.gender==0))
     catchRate*=8
   elsif pbattler2 && pbattler2.species==battler.species &&
      ((battler.gender==0 && pbattler2.gender==1) ||
       (battler.gender==1 && pbattler2.gender==0))
     catchRate*=8
   end
   next catchRate
})

BallHandlers::OnCatch.add(:FRIENDBALL,proc{|ball,battle,pokemon|
   pokemon.happiness=200
})

BallHandlers::ModifyCatchRate.add(:MOONBALL,proc{|ball,catchRate,battle,battler|
   if isConst?(battler.species,PBSpecies,:NIDORANfE) ||
      isConst?(battler.species,PBSpecies,:NIDORINA) ||
      isConst?(battler.species,PBSpecies,:NIDOQUEEN) ||
      isConst?(battler.species,PBSpecies,:NIDORANmA) ||
      isConst?(battler.species,PBSpecies,:NIDORINO) ||
      isConst?(battler.species,PBSpecies,:NIDOKING) ||
      isConst?(battler.species,PBSpecies,:CLEFFA) ||
      isConst?(battler.species,PBSpecies,:CLEFAIRY) ||
      isConst?(battler.species,PBSpecies,:CLEFABLE) ||
      isConst?(battler.species,PBSpecies,:IGGLYBUFF) ||
      isConst?(battler.species,PBSpecies,:JIGGLYPUFF) ||
      isConst?(battler.species,PBSpecies,:WIGGLYTUFF) ||
      isConst?(battler.species,PBSpecies,:SKITTY) ||
      isConst?(battler.species,PBSpecies,:DELCATTY) ||
      isConst?(battler.species,PBSpecies,:MUNNA) ||
      isConst?(battler.species,PBSpecies,:MUSHARNA) ||
      isConst?(battler.species,PBSpecies,:DELTAPICHU) ||
      isConst?(battler.species,PBSpecies,:DELTAPIKACHU) ||
      isConst?(battler.species,PBSpecies,:DELTARAICHU)
     catchRate*=4
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:SPORTBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*3/2).floor
})