ITEMID        = 0
ITEMNAME      = 1
ITEMPOCKET    = 2
ITEMPRICE     = 3
ITEMDESC      = 4
ITEMUSE       = 5
ITEMBATTLEUSE = 6
ITEMTYPE      = 7
ITEMMACHINE   = 8
CLOTHINGTYPE  = 10

def pbIsHiddenMove?(move)
  return false if !$ItemData
  for i in 0...$ItemData.length
    next if !pbIsHiddenMachine?(i)
    atk=$ItemData[i][ITEMMACHINE]
    return true if move==atk
  end
  return false
end

def pbGetPrice(item)
  return $ItemData[item][ITEMPRICE]
end

def pbGetPocket(item)
  return $ItemData[item][ITEMPOCKET]
end

# Important items can't be sold, given to hold, or tossed.
def pbIsImportantItem?(item)
  return $ItemData[item] && ($ItemData[item][ITEMPOCKET]==7 || pbIsMegaStone?(item) || pbIsKeyItem?(item) || pbIsHiddenMachine?(item) ||
                             (INFINITETMS && pbIsTechnicalMachine?(item))
                            )
end

def pbIsMachine?(item)
  return $ItemData[item] && (pbIsTechnicalMachine?(item) || pbIsHiddenMachine?(item))
end

def pbIsTechnicalMachine?(item)
  return $ItemData[item] && ($ItemData[item][ITEMUSE]==3)
end

def pbIsHiddenMachine?(item)
  return $ItemData[item] && ($ItemData[item][ITEMUSE]==4)
end

def pbIsMail?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==1 || $ItemData[item][ITEMTYPE]==2)
end

def pbIsMegaStone?(item)
  return $ItemData[item] && $ItemData[item][ITEMPOCKET]==6
end

def pbIsSnagBall?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==3 ||
                            ($ItemData[item][ITEMTYPE]==4 && $PokemonGlobal.snagMachine))
end

def pbIsPokeBall?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==3 || $ItemData[item][ITEMTYPE]==4)
end

def pbIsBerry?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==5)
end

def pbIsKeyItem?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==6)
end

def pbIsBattleEndingItem?(item)
  return false
end

def pbTopRightWindow(text)
  window=Window_AdvancedTextPokemon.new(text)
  window.z=99999
  window.width=198
  window.y=0
  window.x=Graphics.width-window.width
  pbPlayDecisionSE()
  loop do
    Graphics.update
    Input.update
    window.update
    if Input.trigger?(Input::C)
      break
    end
  end
  window.dispose
end



class ItemHandlerHash < HandlerHash
  def initialize
    super(:PBItems)
  end
end



module ItemHandlers
  UseFromBag=ItemHandlerHash.new
  UseInField=ItemHandlerHash.new
  UseOnPokemon=ItemHandlerHash.new
  BattleUseOnBattler=ItemHandlerHash.new
  BattleUseOnPokemon=ItemHandlerHash.new
  UseInBattle=ItemHandlerHash.new

  def self.addUseFromBag(item,proc)
    UseFromBag.add(item,proc)
  end

  def self.addUseInField(item,proc)
    UseInField.add(item,proc)
  end

  def self.addUseOnPokemon(item,proc)
    UseOnPokemon.add(item,proc)
  end

  def self.addBattleUseOnBattler(item,proc)
    BattleUseOnBattler.add(item,proc)
  end

  def self.addBattleUseOnPokemon(item,proc)
    BattleUseOnPokemon.add(item,proc)
  end

  def self.hasOutHandler(item)                       # Shows "Use" option in Bag
    return UseFromBag[item]!=nil || UseOnPokemon[item]!=nil
  end

  def self.hasKeyItemHandler(item)              # Shows "Register" option in Bag
    return UseInField[item]!=nil
  end

  def self.triggerUseFromBag(item)
    # Return value:
    # 0 - Item not used
    # 1 - Item used, don't end screen
    # 2 - Item used, end screen
    # 3 - Item used, consume item
    # 4 - Item used, end screen, consume item
    if !UseFromBag[item]
      # Check the UseInField handler if present
      if UseInField[item]
        UseInField.trigger(item)
        return 1 # item was used
      end
      return 0 # item was not used
    else
      UseFromBag.trigger(item)
    end
  end

  def self.triggerUseInField(item)
    # No return value
    if !UseInField[item]
      return false
    else
      UseInField.trigger(item)
      return true
    end
  end

  def self.triggerUseOnPokemon(item,pokemon,scene)
    # Returns whether item was used
    if !UseOnPokemon[item]
      return false
    else
      return UseOnPokemon.trigger(item,pokemon,scene)
    end
  end

  def self.triggerBattleUseOnBattler(item,battler,scene)
    # Returns whether item was used
    if !BattleUseOnBattler[item]
      return false
    else
      return BattleUseOnBattler.trigger(item,battler,scene)
    end
  end

  def self.triggerBattleUseOnPokemon(item,pokemon,battler,scene)
    # Returns whether item was used
    if !BattleUseOnPokemon[item]
      return false
    else
      return BattleUseOnPokemon.trigger(item,pokemon,battler,scene)
    end
  end

  def self.triggerUseInBattle(item,battler,battle)
    # Returns whether item was used
    if !UseInBattle[item]
      return
    else
      UseInBattle.trigger(item,battler,battle)
    end
  end
end



def pbItemRestoreHP(pokemon,restorehp)
  newhp=pokemon.hp+restorehp
  newhp=pokemon.totalhp if newhp>pokemon.totalhp
  hpgain=newhp-pokemon.hp
  pokemon.hp=newhp
  return hpgain
end

def pbSpeciesCompatible?(species,move,form=-1)
  ret=false
  return false if species<=0
  data=load_data("Data/tm.dat")
  aryOfAlways=[PBMoves::CAPTIVATE,PBMoves::CUSTOMMOVE,PBMoves::ACHILLESHEEL,
  PBMoves::HIDDENPOWER,PBMoves::SWAGGER,PBMoves::BIDE,PBMoves::POUND,
  PBMoves::REST,PBMoves::PROTECT,PBMoves::CURSE,PBMoves::ENDURE,PBMoves::MIMIC,
  PBMoves::NATURALGIFT,PBMoves::RAGE,PBMoves::SNORE,PBMoves::SECRETPOWER]
  
  blacklistAry=[PBSpecies::CATERPIE,PBSpecies::METAPOD,PBSpecies::WEEDLE,
  PBSpecies::KAKUNA,PBSpecies::MAGIKARP,PBSpecies::DITTO,PBSpecies::SMEARGLE,
  PBSpecies::WURMPLE,PBSpecies::SILCOON,PBSpecies::CASCOON,PBSpecies::BELDUM,
  PBSpecies::COMBEE,PBSpecies::SCATTERBUG,PBSpecies::DELTACOMBEE,
  PBSpecies::DELTADITTO,PBSpecies::DELTABELDUM1,PBSpecies::DELTABELDUM2,
  PBSpecies::UNOWN,PBSpecies::WYNAUT,PBSpecies::WOBBUFFET,PBSpecies::KRICKETOT,
  PBSpecies::BURMY,PBSpecies::SPEWPA]
  
  captivateAry=[PBSpecies::MAGNEMITE,PBSpecies::MAGNETON,PBSpecies::VOLTORB,
  PBSpecies::ELECTRODE,PBSpecies::STARYU,PBSpecies::STARMIE,PBSpecies::PORYGON,
  PBSpecies::ARTICUNO,PBSpecies::ZAPDOS,PBSpecies::MOLTRES,PBSpecies::MEWTWO,
  PBSpecies::RAIKOU,PBSpecies::ENTEI,PBSpecies::SUICUNE,PBSpecies::LUGIA,
  PBSpecies::HOOH,PBSpecies::CELEBI,PBSpecies::PORYGON2,PBSpecies::NINCADA,
  PBSpecies::SHEDINJA,PBSpecies::LUNATONE,PBSpecies::SOLROCK,PBSpecies::BALTOY,
  PBSpecies::CLAYDOL,PBSpecies::METANG,PBSpecies::METAGROSS,PBSpecies::REGIROCK,
  PBSpecies::REGICE,PBSpecies::REGISTEEL,PBSpecies::KYOGRE,PBSpecies::GROUDON,
  PBSpecies::RAYQUAZA,PBSpecies::DEOXYS,PBSpecies::JIRACHI,PBSpecies::BRONZOR,
  PBSpecies::BRONZONG,PBSpecies::MAGNEZONE,PBSpecies::PORYGONZ,PBSpecies::ROTOM,
  PBSpecies::UXIE,PBSpecies::MESPRIT,PBSpecies::AZELF,PBSpecies::DIALGA,
  PBSpecies::PALKIA,PBSpecies::REGIGIGAS,PBSpecies::GIRATINA,PBSpecies::PHIONE,
  PBSpecies::MANAPHY,PBSpecies::DARKRAI,PBSpecies::SHAYMIN,PBSpecies::ARCEUS,
  PBSpecies::VICTINI,PBSpecies::KLINK,PBSpecies::KLANG,PBSpecies::KLINKLANG,
  PBSpecies::CRYOGONAL,PBSpecies::GOLETT,PBSpecies::GOLURK,PBSpecies::COBALION,
  PBSpecies::TERRAKION,PBSpecies::VIRIZION,PBSpecies::RESHIRAM,PBSpecies::ZEKROM,
  PBSpecies::KYUREM,PBSpecies::MELOETTA,PBSpecies::GENESECT,PBSpecies::CARBINK,
  PBSpecies::XERNEAS,PBSpecies::YVELTAL,PBSpecies::ZYGARDE,PBSpecies::DIANCIE,
  PBSpecies::HOOPA,PBSpecies::VOLCANION,PBSpecies::MISSINGNO,PBSpecies::DELTAMETANG1,
  PBSpecies::DELTAMETAGROSS1,PBSpecies::DELTAMETANG2,PBSpecies::DELTAMETAGROSS2,
  PBSpecies::DELTAGOLETT,PBSpecies::DELTAGOLURK,PBSpecies::DELTAREGIROCK,
  PBSpecies::DELTAREGICE,PBSpecies::DELTAREGISTEEL,PBSpecies::DELTAMELOETTA,
  PBSpecies::DELTAHOOPA,PBSpecies::UFI]
  
  return true if move==PBMoves::HIDDENPOWER && (species==PBSpecies::UNOWN ||
                                                species==PBSpecies::BURMY)
  return true if move==PBMoves::SNORE && (species==PBSpecies::KRICKETOT || 
                                          species==PBSpecies::BURMY)
  return true if move==PBMoves::PROTECT && (species==PBSpecies::BURMY || 
                                            species==PBSpecies::SPEWPA)
  return false if move==PBMoves::CAPTIVATE && captivateAry.include?(species)
  return false if move==PBMoves::CUSTOMMOVE && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::ACHILLESHEEL && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::HIDDENPOWER && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::SWAGGER && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::POUND && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::PROTECT && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::CURSE && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::ENDURE && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::NATURALGIFT && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::SNORE && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::SECRETPOWER && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::BIDE && species==PBSpecies::MISSINGNO
  return false if move==PBMoves::MIMIC && species==PBSpecies::MISSINGNO
  
  return false if move==PBMoves::PROTECT && species==PBSpecies::REGIGIGAS
  return false if move==PBMoves::REST && species==PBSpecies::REGIGIGAS
  return false if move==PBMoves::ROUND && (species==PBSpecies::HONEDGE || 
                                           species==PBSpecies::DOUBLADE)
                                           
  return false if move==PBMoves::EXTREMESPEED && species==PBSpecies::ZYGARDE &&
                                                 !$game_switches[692]
  
  return true if aryOfAlways.include?(move) && !blacklistAry.include?(species)
  #return true if isConst?()
  return false if !data[move]
  if isConst?(species,PBSpecies,:WORMADAM)
    case form
    when 0
      return true if isConst?(move,PBMoves,:SOLARBEAM)
      return true if isConst?(move,PBMoves,:ENERGYBALL)
      return true if isConst?(move,PBMoves,:GRASSKNOT)
      return false if isConst?(move,PBMoves,:EARTHQUAKE)
      return false if isConst?(move,PBMoves,:DIG)
      return false if isConst?(move,PBMoves,:SANDSTORM)
      return false if isConst?(move,PBMoves,:ROCKTOMB)
      return false if isConst?(move,PBMoves,:BULLDOZE)
      return false if isConst?(move,PBMoves,:GYROBALL)
      return false if isConst?(move,PBMoves,:FLASHCANNON)
      return true if isConst?(move,PBMoves,:BUGBITE)
      return false if isConst?(move,PBMoves,:EARTHPOWER)
      return true if isConst?(move,PBMoves,:ELECTROWEB)
      return true if isConst?(move,PBMoves,:ENDEAVOR)
      return true if isConst?(move,PBMoves,:GIGADRAIN)
      return false if isConst?(move,PBMoves,:GUNKSHOT)
      return false if isConst?(move,PBMoves,:IRONDEFENSE)
      return false if isConst?(move,PBMoves,:IRONHEAD)
      return false if isConst?(move,PBMoves,:MAGNETRISE)
      return false if isConst?(move,PBMoves,:MUDSLAP)
      return true if isConst?(move,PBMoves,:SEEDBOMB)
      return true if isConst?(move,PBMoves,:SIGNALBEAM)
      return true if isConst?(move,PBMoves,:SKILLSWAP)
      return true if isConst?(move,PBMoves,:SNORE)
      return false if isConst?(move,PBMoves,:STEALTHROCK)
      return true if isConst?(move,PBMoves,:STRINGSHOT)
      return true if isConst?(move,PBMoves,:SUCKERPUNCH)
      return true if isConst?(move,PBMoves,:SYNTHESIS)
      return true if isConst?(move,PBMoves,:UPROAR)
      return true if isConst?(move,PBMoves,:WORRYSEED)
      return true if isConst?(move,PBMoves,:BULLETSEED)
    when 1
      return false if isConst?(move,PBMoves,:SOLARBEAM)
      return false if isConst?(move,PBMoves,:ENERGYBALL)
      return false if isConst?(move,PBMoves,:GRASSKNOT)
      return true if isConst?(move,PBMoves,:EARTHQUAKE)
      return true if isConst?(move,PBMoves,:DIG)
      return true if isConst?(move,PBMoves,:SANDSTORM)
      return true if isConst?(move,PBMoves,:ROCKTOMB)
      return true if isConst?(move,PBMoves,:BULLDOZE)
      return false if isConst?(move,PBMoves,:GYROBALL)
      return false if isConst?(move,PBMoves,:FLASHCANNON)
      return true if isConst?(move,PBMoves,:BUGBITE)
      return true if isConst?(move,PBMoves,:EARTHPOWER)
      return true if isConst?(move,PBMoves,:ELECTROWEB)
      return true if isConst?(move,PBMoves,:ENDEAVOR)
      return false if isConst?(move,PBMoves,:GIGADRAIN)
      return false if isConst?(move,PBMoves,:GUNKSHOT)
      return false if isConst?(move,PBMoves,:IRONDEFENSE)
      return false if isConst?(move,PBMoves,:IRONHEAD)
      return false if isConst?(move,PBMoves,:MAGNETRISE)
      return true if isConst?(move,PBMoves,:MUDSLAP)
      return false if isConst?(move,PBMoves,:SEEDBOMB)
      return true if isConst?(move,PBMoves,:SIGNALBEAM)
      return true if isConst?(move,PBMoves,:SKILLSWAP)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:STEALTHROCK)
      return true if isConst?(move,PBMoves,:STRINGSHOT)
      return true if isConst?(move,PBMoves,:SUCKERPUNCH)
      return false if isConst?(move,PBMoves,:SYNTHESIS)
      return true if isConst?(move,PBMoves,:UPROAR)
      return false if isConst?(move,PBMoves,:WORRYSEED)
      return false if isConst?(move,PBMoves,:BULLETSEED)
    when 2
      return false if isConst?(move,PBMoves,:SOLARBEAM)
      return false if isConst?(move,PBMoves,:ENERGYBALL)
      return false if isConst?(move,PBMoves,:GRASSKNOT)
      return false if isConst?(move,PBMoves,:EARTHQUAKE)
      return false if isConst?(move,PBMoves,:DIG)
      return false if isConst?(move,PBMoves,:SANDSTORM)
      return false if isConst?(move,PBMoves,:ROCKTOMB)
      return false if isConst?(move,PBMoves,:BULLDOZE)
      return true if isConst?(move,PBMoves,:GYROBALL)
      return true if isConst?(move,PBMoves,:FLASHCANNON)
      return true if isConst?(move,PBMoves,:BUGBITE)
      return false if isConst?(move,PBMoves,:EARTHPOWER)
      return true if isConst?(move,PBMoves,:ELECTROWEB)
      return true if isConst?(move,PBMoves,:ENDEAVOR)
      return false if isConst?(move,PBMoves,:GIGADRAIN)
      return true if isConst?(move,PBMoves,:GUNKSHOT)
      return true if isConst?(move,PBMoves,:IRONDEFENSE)
      return true if isConst?(move,PBMoves,:IRONHEAD)
      return true if isConst?(move,PBMoves,:MAGNETRISE)
      return false if isConst?(move,PBMoves,:MUDSLAP)
      return false if isConst?(move,PBMoves,:SEEDBOMB)
      return true if isConst?(move,PBMoves,:SIGNALBEAM)
      return true if isConst?(move,PBMoves,:SKILLSWAP)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:STEALTHROCK)
      return true if isConst?(move,PBMoves,:STRINGSHOT)
      return true if isConst?(move,PBMoves,:SUCKERPUNCH)
      return false if isConst?(move,PBMoves,:SYNTHESIS)
      return true if isConst?(move,PBMoves,:UPROAR)
      return false if isConst?(move,PBMoves,:WORRYSEED)
      return false if isConst?(move,PBMoves,:BULLETSEED)
    else
      return true if isConst?(move,PBMoves,:SOLARBEAM)
      return true if isConst?(move,PBMoves,:ENERGYBALL)
      return true if isConst?(move,PBMoves,:GRASSKNOT)
      return true if isConst?(move,PBMoves,:EARTHQUAKE)
      return true if isConst?(move,PBMoves,:DIG)
      return true if isConst?(move,PBMoves,:SANDSTORM)
      return true if isConst?(move,PBMoves,:ROCKTOMB)
      return true if isConst?(move,PBMoves,:BULLDOZE)
      return true if isConst?(move,PBMoves,:GYROBALL)
      return true if isConst?(move,PBMoves,:FLASHCANNON)
      return true if isConst?(move,PBMoves,:BUGBITE)
      return true if isConst?(move,PBMoves,:EARTHPOWER)
      return true if isConst?(move,PBMoves,:ELECTROWEB)
      return true if isConst?(move,PBMoves,:ENDEAVOR)
      return true if isConst?(move,PBMoves,:GIGADRAIN)
      return true if isConst?(move,PBMoves,:GUNKSHOT)
      return true if isConst?(move,PBMoves,:IRONDEFENSE)
      return true if isConst?(move,PBMoves,:IRONHEAD)
      return true if isConst?(move,PBMoves,:MAGNETRISE)
      return false if isConst?(move,PBMoves,:MUDSLAP)
      return true if isConst?(move,PBMoves,:SEEDBOMB)
      return true if isConst?(move,PBMoves,:SIGNALBEAM)
      return true if isConst?(move,PBMoves,:SKILLSWAP)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:STEALTHROCK)
      return true if isConst?(move,PBMoves,:STRINGSHOT)
      return true if isConst?(move,PBMoves,:SUCKERPUNCH)
      return true if isConst?(move,PBMoves,:SYNTHESIS)
      return true if isConst?(move,PBMoves,:UPROAR)
      return true if isConst?(move,PBMoves,:WORRYSEED)
      return true if isConst?(move,PBMoves,:BULLETSEED)
    end
  end
  if isConst?(species,PBSpecies,:DEOXYS)
    case form
    when 0 # Normal
      return true if isConst?(move,PBMoves,:BIND)
      return true if isConst?(move,PBMoves,:BODYSLAM)
      return false if isConst?(move,PBMoves,:COUNTER)
      return true if isConst?(move,PBMoves,:DOUBLEEDGE)
      return true if isConst?(move,PBMoves,:DRAINPUNCH)
      return false if isConst?(move,PBMoves,:DYNAMICPUNCH)
      return false if isConst?(move,PBMoves,:ENDURE)
      return true if isConst?(move,PBMoves,:EXTREMESPEED)
      return true if isConst?(move,PBMoves,:FIREPUNCH)
      return true if isConst?(move,PBMoves,:FOCUSPUNCH)
      return true if isConst?(move,PBMoves,:GRAVITY)
      return true if isConst?(move,PBMoves,:HEADBUTT)
      return true if isConst?(move,PBMoves,:ICEPUNCH)
      return true if isConst?(move,PBMoves,:ICYWIND)
      return true if isConst?(move,PBMoves,:IRONDEFENSE)
      return true if isConst?(move,PBMoves,:KNOCKOFF)
      return true if isConst?(move,PBMoves,:LOWKICK)
      return true if isConst?(move,PBMoves,:MAGICCOAT)
      return false if isConst?(move,PBMoves,:MEGAKICK)
      return false if isConst?(move,PBMoves,:MEGAPUNCH)
      return false if isConst?(move,PBMoves,:METEORMASH)
      return true if isConst?(move,PBMoves,:MIMIC)
      return true if isConst?(move,PBMoves,:MUDSLAP)
      return true if isConst?(move,PBMoves,:NASTYPLOT)
      return true if isConst?(move,PBMoves,:NIGHTMARE)
      return true if isConst?(move,PBMoves,:NIGHTSHADE)
      return true if isConst?(move,PBMoves,:PSYCHOBOOST)
      return true if isConst?(move,PBMoves,:RECYCLE)
      return true if isConst?(move,PBMoves,:ROLEPLAY)
      return true if isConst?(move,PBMoves,:SEISMICTOSS)
      return true if isConst?(move,PBMoves,:SHOCKWAVE)
      return true if isConst?(move,PBMoves,:SIGNALBEAM)
      return true if isConst?(move,PBMoves,:SKILLSWAP)
      return true if isConst?(move,PBMoves,:SNATCH)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:STEALTHROCK)
      return false if isConst?(move,PBMoves,:SUPERPOWER)
      return true if isConst?(move,PBMoves,:SWIFT)
      return true if isConst?(move,PBMoves,:THUNDERPUNCH)
      return true if isConst?(move,PBMoves,:TRICK)
      return true if isConst?(move,PBMoves,:WATERPULSE)
      return true if isConst?(move,PBMoves,:WONDERROOM)
      return true if isConst?(move,PBMoves,:ZAPCANNON)
      return true if isConst?(move,PBMoves,:ZENHEADBUTT)
    when 1 # Attack
      return true if isConst?(move,PBMoves,:BIND)
      return true if isConst?(move,PBMoves,:BODYSLAM)
      return true if isConst?(move,PBMoves,:COUNTER)
      return true if isConst?(move,PBMoves,:DOUBLEEDGE)
      return true if isConst?(move,PBMoves,:DRAINPUNCH)
      return false if isConst?(move,PBMoves,:DYNAMICPUNCH)
      return false if isConst?(move,PBMoves,:ENDURE)
      return false if isConst?(move,PBMoves,:EXTREMESPEED)
      return false if isConst?(move,PBMoves,:FIREPUNCH)
      return true if isConst?(move,PBMoves,:FOCUSPUNCH)
      return true if isConst?(move,PBMoves,:GRAVITY)
      return true if isConst?(move,PBMoves,:HEADBUTT)
      return false if isConst?(move,PBMoves,:ICEPUNCH)
      return false if isConst?(move,PBMoves,:ICYWIND)
      return false if isConst?(move,PBMoves,:IRONDEFENSE)
      return false if isConst?(move,PBMoves,:KNOCKOFF)
      return true if isConst?(move,PBMoves,:LOWKICK)
      return true if isConst?(move,PBMoves,:MAGICCOAT)
      return true if isConst?(move,PBMoves,:MEGAKICK)
      return true if isConst?(move,PBMoves,:MEGAPUNCH)
      return true if isConst?(move,PBMoves,:METEORMASH)
      return true if isConst?(move,PBMoves,:MIMIC)
      return true if isConst?(move,PBMoves,:MUDSLAP)
      return false if isConst?(move,PBMoves,:NASTYPLOT)
      return false if isConst?(move,PBMoves,:NIGHTMARE)
      return true if isConst?(move,PBMoves,:NIGHTSHADE)
      return true if isConst?(move,PBMoves,:PSYCHOBOOST)
      return true if isConst?(move,PBMoves,:RECYCLE)
      return true if isConst?(move,PBMoves,:ROLEPLAY)
      return true if isConst?(move,PBMoves,:SEISMICTOSS)
      return true if isConst?(move,PBMoves,:SHOCKWAVE)
      return true if isConst?(move,PBMoves,:SIGNALBEAM)
      return true if isConst?(move,PBMoves,:SKILLSWAP)
      return true if isConst?(move,PBMoves,:SNATCH)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:STEALTHROCK)
      return true if isConst?(move,PBMoves,:SUPERPOWER)
      return false if isConst?(move,PBMoves,:SWIFT)
      return false if isConst?(move,PBMoves,:THUNDERPUNCH)
      return true if isConst?(move,PBMoves,:TRICK)
      return true if isConst?(move,PBMoves,:WATERPULSE)
      return true if isConst?(move,PBMoves,:WONDERROOM)
      return false if isConst?(move,PBMoves,:ZAPCANNON)
      return true if isConst?(move,PBMoves,:ZENHEADBUTT)
    when 2 # Defense
      return true if isConst?(move,PBMoves,:BIND)
      return true if isConst?(move,PBMoves,:BODYSLAM)
      return true if isConst?(move,PBMoves,:COUNTER)
      return true if isConst?(move,PBMoves,:DOUBLEEDGE)
      return true if isConst?(move,PBMoves,:DRAINPUNCH)
      return false if isConst?(move,PBMoves,:DYNAMICPUNCH)
      return false if isConst?(move,PBMoves,:ENDURE)
      return false if isConst?(move,PBMoves,:EXTREMESPEED)
      return false if isConst?(move,PBMoves,:FIREPUNCH)
      return true if isConst?(move,PBMoves,:FOCUSPUNCH)
      return true if isConst?(move,PBMoves,:GRAVITY)
      return true if isConst?(move,PBMoves,:HEADBUTT)
      return false if isConst?(move,PBMoves,:ICEPUNCH)
      return false if isConst?(move,PBMoves,:ICYWIND)
      return true if isConst?(move,PBMoves,:IRONDEFENSE)
      return true if isConst?(move,PBMoves,:KNOCKOFF)
      return true if isConst?(move,PBMoves,:LOWKICK)
      return true if isConst?(move,PBMoves,:MAGICCOAT)
      return true if isConst?(move,PBMoves,:MEGAKICK)
      return true if isConst?(move,PBMoves,:MEGAPUNCH)
      return false if isConst?(move,PBMoves,:METEORMASH)
      return true if isConst?(move,PBMoves,:MIMIC)
      return true if isConst?(move,PBMoves,:MUDSLAP)
      return false if isConst?(move,PBMoves,:NASTYPLOT)
      return false if isConst?(move,PBMoves,:NIGHTMARE)
      return true if isConst?(move,PBMoves,:NIGHTSHADE)
      return true if isConst?(move,PBMoves,:PSYCHOBOOST)
      return true if isConst?(move,PBMoves,:RECYCLE)
      return true if isConst?(move,PBMoves,:ROLEPLAY)
      return true if isConst?(move,PBMoves,:SEISMICTOSS)
      return true if isConst?(move,PBMoves,:SHOCKWAVE)
      return true if isConst?(move,PBMoves,:SIGNALBEAM)
      return true if isConst?(move,PBMoves,:SKILLSWAP)
      return true if isConst?(move,PBMoves,:SNATCH)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:STEALTHROCK)
      return false if isConst?(move,PBMoves,:SUPERPOWER)
      return false if isConst?(move,PBMoves,:SWIFT)
      return false if isConst?(move,PBMoves,:THUNDERPUNCH)
      return true if isConst?(move,PBMoves,:TRICK)
      return true if isConst?(move,PBMoves,:WATERPULSE)
      return true if isConst?(move,PBMoves,:WONDERROOM)
      return false if isConst?(move,PBMoves,:ZAPCANNON)
      return true if isConst?(move,PBMoves,:ZENHEADBUTT)
    when 3 # Speed
      return true if isConst?(move,PBMoves,:BIND)
      return true if isConst?(move,PBMoves,:BODYSLAM)
      return true if isConst?(move,PBMoves,:COUNTER)
      return true if isConst?(move,PBMoves,:DOUBLEEDGE)
      return true if isConst?(move,PBMoves,:DRAINPUNCH)
      return true if isConst?(move,PBMoves,:DYNAMICPUNCH)
      return true if isConst?(move,PBMoves,:ENDURE)
      return true if isConst?(move,PBMoves,:EXTREMESPEED)
      return true if isConst?(move,PBMoves,:FIREPUNCH)
      return true if isConst?(move,PBMoves,:FOCUSPUNCH)
      return true if isConst?(move,PBMoves,:GRAVITY)
      return true if isConst?(move,PBMoves,:HEADBUTT)
      return true if isConst?(move,PBMoves,:ICEPUNCH)
      return true if isConst?(move,PBMoves,:ICYWIND)
      return false if isConst?(move,PBMoves,:IRONDEFENSE)
      return true if isConst?(move,PBMoves,:KNOCKOFF)
      return true if isConst?(move,PBMoves,:LOWKICK)
      return true if isConst?(move,PBMoves,:MAGICCOAT)
      return false if isConst?(move,PBMoves,:MEGAKICK)
      return false if isConst?(move,PBMoves,:MEGAPUNCH)
      return false if isConst?(move,PBMoves,:METEORMASH)
      return true if isConst?(move,PBMoves,:MIMIC)
      return true if isConst?(move,PBMoves,:MUDSLAP)
      return false if isConst?(move,PBMoves,:NASTYPLOT)
      return false if isConst?(move,PBMoves,:NIGHTMARE)
      return true if isConst?(move,PBMoves,:NIGHTSHADE)
      return true if isConst?(move,PBMoves,:PSYCHOBOOST)
      return true if isConst?(move,PBMoves,:RECYCLE)
      return true if isConst?(move,PBMoves,:ROLEPLAY)
      return true if isConst?(move,PBMoves,:SEISMICTOSS)
      return true if isConst?(move,PBMoves,:SHOCKWAVE)
      return true if isConst?(move,PBMoves,:SIGNALBEAM)
      return true if isConst?(move,PBMoves,:SKILLSWAP)
      return true if isConst?(move,PBMoves,:SNATCH)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:STEALTHROCK)
      return true if isConst?(move,PBMoves,:SWIFT)
      return false if isConst?(move,PBMoves,:SUPERPOWER)
      return true if isConst?(move,PBMoves,:THUNDERPUNCH)
      return true if isConst?(move,PBMoves,:TRICK)
      return true if isConst?(move,PBMoves,:WATERPULSE)
      return true if isConst?(move,PBMoves,:WONDERROOM)
      return false if isConst?(move,PBMoves,:ZAPCANNON)
      return true if isConst?(move,PBMoves,:ZENHEADBUTT)
    else
      return true if isConst?(move,PBMoves,:BIND)
      return true if isConst?(move,PBMoves,:COUNTER)
      return true if isConst?(move,PBMoves,:BODYSLAM)
      return true if isConst?(move,PBMoves,:DOUBLEEDGE)
      return true if isConst?(move,PBMoves,:DRAINPUNCH)
      return true if isConst?(move,PBMoves,:DYNAMICPUNCH)
      return true if isConst?(move,PBMoves,:ENDURE)
      return true if isConst?(move,PBMoves,:FIREPUNCH)
      return true if isConst?(move,PBMoves,:FOCUSPUNCH)
      return true if isConst?(move,PBMoves,:GRAVITY)
      return true if isConst?(move,PBMoves,:HEADBUTT)
      return true if isConst?(move,PBMoves,:ICEPUNCH)
      return true if isConst?(move,PBMoves,:ICYWIND)
      return true if isConst?(move,PBMoves,:IRONDEFENSE)
      return true if isConst?(move,PBMoves,:KNOCKOFF)
      return true if isConst?(move,PBMoves,:LOWKICK)
      return true if isConst?(move,PBMoves,:MAGICCOAT)
      return true if isConst?(move,PBMoves,:MEGAKICK)
      return true if isConst?(move,PBMoves,:MEGAPUNCH)
      return true if isConst?(move,PBMoves,:METEORMASH)
      return true if isConst?(move,PBMoves,:MIMIC)
      return true if isConst?(move,PBMoves,:MUDSLAP)
      return true if isConst?(move,PBMoves,:NASTYPLOT)
      return true if isConst?(move,PBMoves,:NIGHTMARE)
      return true if isConst?(move,PBMoves,:NIGHTSHADE)
      return true if isConst?(move,PBMoves,:PSYCHOBOOST)
      return true if isConst?(move,PBMoves,:RECYCLE)
      return true if isConst?(move,PBMoves,:ROLEPLAY)
      return true if isConst?(move,PBMoves,:SEISMICTOSS)
      return true if isConst?(move,PBMoves,:SHOCKWAVE)
      return true if isConst?(move,PBMoves,:SIGNALBEAM)
      return true if isConst?(move,PBMoves,:SKILLSWAP)
      return true if isConst?(move,PBMoves,:SNATCH)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:STEALTHROCK)
      return true if isConst?(move,PBMoves,:SUPERPOWER)
      return true if isConst?(move,PBMoves,:SWIFT)
      return true if isConst?(move,PBMoves,:THUNDERPUNCH)
      return true if isConst?(move,PBMoves,:TRICK)
      return true if isConst?(move,PBMoves,:WATERPULSE)
      return true if isConst?(move,PBMoves,:WONDERROOM)
      return true if isConst?(move,PBMoves,:ZAPCANNON)
      return true if isConst?(move,PBMoves,:ZENHEADBUTT)
    end
  end
  if isConst?(species,PBSpecies,:SHAYMIN)
    case form
    when 0 # Land
      return false if isConst?(move,PBMoves,:AIRCUTTER)
      return true if isConst?(move,PBMoves,:COVET)
      return true if isConst?(move,PBMoves,:EARTHPOWER)
      return true if isConst?(move,PBMoves,:ENDEAVOR)
      return true if isConst?(move,PBMoves,:GIGADRAIN)
      return true if isConst?(move,PBMoves,:GROWTH)
      return true if isConst?(move,PBMoves,:HEADBUTT)
      return true if isConst?(move,PBMoves,:LASTRESORT)
      return true if isConst?(move,PBMoves,:MUDSLAP)
      return false if isConst?(move,PBMoves,:OMINOUSWIND)
      return true if isConst?(move,PBMoves,:SEEDBOMB)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:SWIFT)
      return true if isConst?(move,PBMoves,:SYNTHESIS)
      return false if isConst?(move,PBMoves,:TAILWIND)
      return true if isConst?(move,PBMoves,:WORRYSEED)
      return true if isConst?(move,PBMoves,:ZENHEADBUTT)
    when 1 # Sky
      return true if isConst?(move,PBMoves,:AIRCUTTER)
      return true if isConst?(move,PBMoves,:COVET)
      return false if isConst?(move,PBMoves,:EARTHPOWER)
      return false if isConst?(move,PBMoves,:ENDEAVOR)
      return true if isConst?(move,PBMoves,:GIGADRAIN)
      return true if isConst?(move,PBMoves,:GROWTH)
      return true if isConst?(move,PBMoves,:HEADBUTT)
      return true if isConst?(move,PBMoves,:LASTRESORT)
      return true if isConst?(move,PBMoves,:MUDSLAP)
      return true if isConst?(move,PBMoves,:OMINOUSWIND)
      return true if isConst?(move,PBMoves,:SEEDBOMB)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:SWIFT)
      return true if isConst?(move,PBMoves,:SYNTHESIS)
      return true if isConst?(move,PBMoves,:TAILWIND)
      return true if isConst?(move,PBMoves,:WORRYSEED)
      return true if isConst?(move,PBMoves,:ZENHEADBUTT)
    else
      return true if isConst?(move,PBMoves,:COVET)
      return true if isConst?(move,PBMoves,:EARTHPOWER)
      return true if isConst?(move,PBMoves,:ENDEAVOR)
      return true if isConst?(move,PBMoves,:GIGADRAIN)
      return true if isConst?(move,PBMoves,:GROWTH)
      return true if isConst?(move,PBMoves,:HEADBUTT)
      return true if isConst?(move,PBMoves,:LASTRESORT)
      return true if isConst?(move,PBMoves,:MUDSLAP)
      return true if isConst?(move,PBMoves,:SEEDBOMB)
      return true if isConst?(move,PBMoves,:SNORE)
      return true if isConst?(move,PBMoves,:SWIFT)
      return true if isConst?(move,PBMoves,:SYNTHESIS)
      return true if isConst?(move,PBMoves,:TAILWIND)
      return true if isConst?(move,PBMoves,:WORRYSEED)
      return true if isConst?(move,PBMoves,:ZENHEADBUTT)
    end
  end
  return data[move].any? {|item| item==species }
end

def pbForgetMove(pokemon,moveToLearn)
  ret=-1
  pbFadeOutIn(99999){
     scene=PokemonSummaryScene.new
     screen=PokemonSummary.new(scene)
     ret=screen.pbStartForgetScreen([pokemon],0,moveToLearn)
  }
  return ret
end

def pbJustRaiseEffortValues(pokemon,ev,evgain)
  totalev=0
  for i in 0...6
    totalev+=pokemon.ev[i]
  end
  if totalev+evgain>510
    # Bug Fix: must use "-=" instead of "="
    evgain-=totalev+evgain-510
  end
  if pokemon.ev[ev]+evgain>252
    # Bug Fix: must use "-=" instead of "="
    evgain-=pokemon.ev[ev]+evgain-252
  end
  if evgain>0
    pokemon.ev[ev]+=evgain
    pokemon.calcStats
  end
  return evgain
end

def pbRaiseEffortValues(pokemon,ev,evgain=10,evlimit=true)
  if pokemon.ev[ev]>=100 && evlimit
    return 0
  end
  totalev=0
  for i in 0...6
    totalev+=pokemon.ev[i]
  end
  if totalev+evgain>510
    evgain=510-totalev
  end
  if pokemon.ev[ev]+evgain>252
    evgain=252-pokemon.ev[ev]
  end
  if evlimit && pokemon.ev[ev]+evgain>100
    evgain=100-pokemon.ev[ev]
  end
  if evgain>0
    pokemon.ev[ev]+=evgain
    pokemon.calcStats
  end
  return evgain
end

def pbRestorePP(pokemon,move,pp)
  return 0 if pokemon.moves[move].id==0
  return 0 if pokemon.moves[move].totalpp==0
  newpp=pokemon.moves[move].pp+pp
  if newpp>pokemon.moves[move].totalpp
    newpp=pokemon.moves[move].totalpp
  end
  oldpp=pokemon.moves[move].pp
  pokemon.moves[move].pp=newpp
  return newpp-oldpp
end

def pbHPItem(pokemon, restorehp,scene)
  if pokemon.hp<=0 || pokemon.hp==pokemon.totalhp || pokemon.egg?
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  else
    hpgain=pbItemRestoreHP(pokemon,restorehp)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pokemon.name,hpgain.to_i))
    return true
  end
end

def pbBattleHPItem(pokemon,battler,restorehp,scene)
  if pbHPItem(pokemon,restorehp,scene)
    battler.hp=pokemon.hp if battler
    return true
  end
  return false
end

def pbBattleRestorePP(pokemon,battler,move,pp)
  ret=pbRestorePP(pokemon,move,pp)
  if ret>0
    battler.pbSetPP(battler.moves[move],pokemon.moves[move].pp) if battler
  end
  return ret
end

def pbBikeCheck
  if $PokemonGlobal.surfing ||
     (!$PokemonGlobal.bicycle && pbGetTerrainTag==PBTerrain::TallGrass)
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
  end
  if $PokemonGlobal.bicycle
    if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
      Kernel.pbMessage(_INTL("You can't dismount your Bike here."))
      return false
    end
    return true
  else
    val=pbGetMetadata($game_map.map_id,MetadataBicycle)
    val=pbGetMetadata($game_map.map_id,MetadataOutdoor) if val==nil
    if !val
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
    return true
  end
end

def pbClosestHiddenItem
  result = []
  playerX=$game_player.x
  playerY=$game_player.y
  for event in $game_map.events.values
    next if event.name!="HiddenItem"
    next if (playerX-event.x).abs>=8
    next if (playerY-event.y).abs>=8
    next if $game_self_switches[[$game_map.map_id,event.id,"A"]]
    result.push(event)
  end
  return nil if result.length==0
  ret=nil
  retmin=0
  for event in result
    dist=(playerX-event.x).abs+(playerY-event.y).abs
    if !ret || retmin>dist
      ret=event
      retmin=dist
    end
  end
  return ret
end

def Kernel.pbUseKeyItemInField(item)
  if !ItemHandlers.triggerUseInField(item)
    if item != 656 && !$tempbooleanfortalk
      Kernel.pbMessage(_INTL("Can't use that here.")) 
      $tempbooleanfortalk=nil
    end
    
  end
  $tempbooleanfortalk=nil
end

def pbLearnMove(pokemon,move,ignoreifknown=false,bymachine=false)
  return false if !pokemon
  if bymachine && $game_switches[355]
      Kernel.pbMessage("You cannot use TMs in a Non-Technical Challenge.")
      return false
  end
  
  movename=PBMoves.getName(move)
  if pokemon.egg? && !$DEBUG
    Kernel.pbMessage(_INTL("{1} can't be taught to an Egg.",movename))
    return false
  end
  if pokemon.isShadow?
    Kernel.pbMessage(_INTL("{1} can't be taught to this Pokémon.",movename))
    return false
  end
  pkmnname=pokemon.name
  for i in 0..3
    if pokemon.moves[i].id==move
      Kernel.pbMessage(_INTL("{1} already knows\r\n{2}.",pkmnname,movename)) if !ignoreifknown
      return false
    end
    if pokemon.moves[i].id==0
      pokemon.moves[i]=PBMove.new(move)
      Kernel.pbMessage(_INTL("{1} learned\r\n{2}!\\se[itemlevel]",pkmnname,movename))
      return true
    end
  end
  loop do
    Kernel.pbMessage(_INTL("{1} is trying to learn\r\n{2}.\1",pkmnname,movename))
    Kernel.pbMessage(_INTL("But {1} already knows four moves.\1",pkmnname))
    if Kernel.pbConfirmMessage(_INTL("Delete an older move to make\r\nroom for {1}?",movename))
      Kernel.pbMessage(_INTL("Which move should be forgotten?"))
      forgetmove=pbForgetMove(pokemon,move)
      if forgetmove >=0
        oldmovename=PBMoves.getName(pokemon.moves[forgetmove].id)
        oldmovepp=pokemon.moves[forgetmove].pp
        pokemon.moves[forgetmove]=PBMove.new(move) # Replaces current/total PP
          pokemon.moves[forgetmove].pp=[oldmovepp,pokemon.moves[forgetmove].totalpp].min if bymachine
        Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ... \\wt[8]Poof!\\se[balldrop]\1"))
        Kernel.pbMessage(_INTL("{1} forgot\r\n{2}.\1",pkmnname,oldmovename))
        Kernel.pbMessage(_INTL("And...\1"))
        Kernel.pbMessage(_INTL("\\se[]{1} learned\r\n{2}!\\se[itemlevel]",pkmnname,movename))
        return true
      elsif Kernel.pbConfirmMessage(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
        Kernel.pbMessage(_INTL("{1} did not learn {2}.",pkmnname,movename))
        return false
      end
    elsif Kernel.pbConfirmMessage(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
      Kernel.pbMessage(_INTL("{1} did not learn {2}.",pkmnname,movename))
      return false
    end
  end
end

def pbCheckUseOnPokemon(item,pokemon,screen)
  return pokemon && !pokemon.egg?
end

def pbConsumeItemInBattle(bag,item)
  if item!=0 && $ItemData[item][ITEMBATTLEUSE]!=3 &&
                $ItemData[item][ITEMBATTLEUSE]!=4 &&
                $ItemData[item][ITEMBATTLEUSE]!=0
    # Delete the item just used from stock
    if $idbox && $idbox != nil
      if $idbox == "Protect" || $idbox == "Sleep Powder" || $idbox == "Thunder Wave" || $idbox == "Toxic" || $idbox == "Confuse Ray" || $idbox == "Medusa Ray" || $idbox == "False Swipe"
      
        else
          $PokemonBag.pbDeleteItem(item) 
        end
        
      else
    $PokemonBag.pbDeleteItem(item) 
  end
  
  end
end

def pbUseItem(bag,item)
  found=false
  if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4    # TM or HM
    machine=$ItemData[item][ITEMMACHINE]
    ret=true
    return 0 if machine==nil
    if $Trainer.pokemonCount==0
      Kernel.pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    movename=PBMoves.getName(machine)
    if pbIsHiddenMachine?(item)
      Kernel.pbMessage(_INTL("\\se[accesspc]Booted up an HM."))
      Kernel.pbMessage(_INTL("It contained {1}.\1",movename))
    else
      Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TM."))
      Kernel.pbMessage(_INTL("It contained {1}.\1",movename))
    end
    if !Kernel.pbConfirmMessage(_INTL("Teach {1} to a Pokémon?",movename))
      return 1
    elsif pbMoveTutorChoose(machine,nil,true)
      bag.pbDeleteItem(item) if pbIsTechnicalMachine?(item) && !INFINITETMS && movename.to_s != "Dark Epitaph".to_s && movename.to_s != "Razor Storm".to_s && movename.to_s != "Titanic Force".to_s
      bag.pbDeleteItem(item) if pbIsTechnicalMachine?(item) && PBItems.getName(item) == "TM??"
      $PokemonTemp.dependentEvents.refresh_sprite
      return 1
    else
      return 0
    end
  elsif $ItemData[item][ITEMUSE]==1 || $ItemData[item][ITEMUSE]==5 # Item is usable on a Pokémon
    if $Trainer.pokemonCount==0
      Kernel.pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret=false
    pbFadeOutIn(99999){
       scene=PokemonScreen_Scene.new
       screen=PokemonScreen.new(scene,$Trainer.party)
       screen.pbStartScene(_INTL("Use on which Pokémon?"),false)
       loop do
         scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
         chosen=screen.pbChoosePokemon
         if chosen>=0
           pokemon=$Trainer.party[chosen]
           if !pbCheckUseOnPokemon(item,pokemon,screen)
             pbPlayBuzzerSE()
           else
             ret=ItemHandlers.triggerUseOnPokemon(item,pokemon,screen)
             if ret && $ItemData[item][ITEMUSE]==1 # Usable on Pokémon, consumed
               bag.pbDeleteItem(item)
             end
             if bag.pbQuantity(item)<=0
               Kernel.pbMessage(_INTL("You used your last {1}.",
                  PBItems.getName(item))) if bag.pbQuantity(item)<=0
               break
             end
           end
         else
           ret=false
           break
         end
       end
       screen.pbEndScene
    }
    return ret ? 1 : 0
  elsif $ItemData[item][ITEMUSE]==2 # Item is usable from bag
    intret=ItemHandlers.triggerUseFromBag(item)
    case intret
      when 0
        return 0
      when 1
        return 1
      when 2 # Item used, end screen
        return 2
      when 3 # Item used, consume item
        bag.pbDeleteItem(item) if item != 656
        return 1
      when 4 # Item used, end screen and consume item
        bag.pbDeleteItem(item) if item != 656
        return 2
      else
        Kernel.pbMessage(_INTL("Can't use that here."))
        return 0
    end    
  else
    Kernel.pbMessage(_INTL("Can't use that here."))
    return 0
  end
end

def Kernel.pbChooseItem(var=0)
  ret=0
  scene=PokemonBag_Scene.new
  screen=PokemonBagScreen.new(scene,$PokemonBag)
  pbFadeOutIn(99999) { 
    ret=screen.pbChooseItemScreen
  }
  $game_variables[var]=ret if var>0
  return ret
end

# Shows a list of items to choose from, with the chosen item's ID being stored
# in the given Global Variable. Only items which the player has are listed.
def pbChooseItemFromList(message,variable,*args)
  commands=[]
  itemid=[]
  for item in args
    if hasConst?(PBItems,item)
      id=getConst(PBItems,item)
      if $PokemonBag.pbQuantity(id)>0
        commands.push(PBItems.getName(id))
        itemid.push(id)
      end
    end
  end
  if commands.length==0
    $game_variables[variable]=0
    return -1
  end
  commands.push(_INTL("Cancel"))
  itemid.push(0)
  ret=Kernel.pbMessage(message,commands,-1)
  if ret<0 || ret>=commands.length-1
    $game_variables[variable]=-1
    return -1
  else
    $game_variables[variable]=itemid[ret]
    return itemid[ret]
  end
end