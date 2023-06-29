def generateFriendSafari
  var=Array.new  
  var[0]=Kernel.fsGetType
  var[1]=Kernel.randFSPokemonFrom(1,var[0])
  var[2]=Kernel.randFSPokemonFrom(2,var[0])
  var[3]=Kernel.randFSPokemonFrom(3,var[0])

  return var
  
end


def checkIsFSLegal
  
  # Actual hack check/legality check moved to server
  
  return true
  
  
  if !Kernel.checkFSLegalPokemon($game_variables[79][1],$game_variables[79][0],1)
#    Kernel.pbMessage("no legalera"+$game_variables[79][1].to_s)
    return false
  end
  if !Kernel.checkFSLegalPokemon($game_variables[79][2],$game_variables[79][0],2)
 #   Kernel.pbMessage("no legalero"+$game_variables[79][2].to_s)
    return false
  end
  if !Kernel.checkFSLegalPokemon($game_variables[79][3],$game_variables[79][0],3)
  #  Kernel.pbMessage("no legalere"+$game_variables[79][3].to_s)
    return false
  end
  return true
  end
       




def checkFSLegalPokemon(species,type,number)
  if number==1
    if Kernel.fsGetPokemon1(type).include?(species)
      return true
    end
  end
  if number==2
    if Kernel.fsGetPokemon2(type).include?(species)
      return true
    end
  end
  if number==3
    if Kernel.fsGetPokemon3(type).include?(species)
      return true
    end
  end
  return false
  end



def fsGetType
    ary=[PBTypes::FIRE,PBTypes::WATER,PBTypes::GRASS,PBTypes::NORMAL,PBTypes::FIGHTING,
    PBTypes::ELECTRIC,PBTypes::GHOST,PBTypes::ICE,PBTypes::PSYCHIC,PBTypes::DARK,
    PBTypes::FAIRY,PBTypes::BUG,PBTypes::POISON,PBTypes::STEEL,PBTypes::FLYING,
    PBTypes::GROUND,PBTypes::ROCK,PBTypes::DRAGON]
    return ary[rand(ary.length)]
end

def randFSPokemonFrom(number,type)
    if number==1
      ret = Kernel.fsGetPokemon1(type)[rand(Kernel.fsGetPokemon1(type).length-1)]
    end
    if number==2
      ret = Kernel.fsGetPokemon2(type)[rand(Kernel.fsGetPokemon2(type).length-1)]
    end
    if number==3
      ret = Kernel.fsGetPokemon3(type)[rand(Kernel.fsGetPokemon3(type).length-1)]
    end
    return ret
end


def fsGetPokemon1(type)
  ary=[PBSpecies::ARCEUS,PBSpecies::DIALGA]
  case type
    when PBTypes::FIRE
      ary=[PBSpecies::PONYTA,PBSpecies::MAGMAR,PBSpecies::SLUGMA,PBSpecies::TORKOAL,
      PBSpecies::PANSEAR,PBSpecies::HEATMOR,PBSpecies::NUMEL,PBSpecies::LITLEO,
      PBSpecies::HOUNDOUR]
    when PBTypes::WATER
      ary=[PBSpecies::PSYDUCK,PBSpecies::SEEL,PBSpecies::KRABBY,
      PBSpecies::GOLDEEN,PBSpecies::MAGIKARP,PBSpecies::REMORAID,PBSpecies::WAILMER,
      PBSpecies::CLAMPERL,PBSpecies::LUVDISC,PBSpecies::BUIZEL,
      PBSpecies::PANPOUR,PBSpecies::TYMPOLE,PBSpecies::BASCULIN,
      PBSpecies::ALOMOMOLA,PBSpecies::LAPRAS,PBSpecies::CHINCHOU,PBSpecies::WOOPER,
      PBSpecies::SLOWPOKE,PBSpecies::QWILFISH,PBSpecies::CORSOLA,
      PBSpecies::MANTYKE,PBSpecies::LOTAD,PBSpecies::WINGULL,PBSpecies::PALPITOAD,
      PBSpecies::TIRTOUGA,PBSpecies::BIDOOF]
    when PBTypes::GRASS
      ary=[PBSpecies::NUZLEAF,PBSpecies::SUNKERN,
      PBSpecies::CHERUBI,PBSpecies::CARNIVINE,PBSpecies::PETILIL,
      PBSpecies::MARACTUS,PBSpecies::ODDISH,PBSpecies::EXEGGCUTE,
      PBSpecies::HOPPIP,PBSpecies::SNOVER,PBSpecies::FOONGUS,PBSpecies::PARAS,
      PBSpecies::LOTAD,PBSpecies::SEWADDLE,PBSpecies::PUMPKABOO,PBSpecies::PANSAGE]
    when PBTypes::ELECTRIC
      ary=[PBSpecies::PLUSLE,PBSpecies::MINUN,PBSpecies::PACHIRISU,
      PBSpecies::MAGNEMITE,PBSpecies::EMOLGA,PBSpecies::HELIOPTILE,
      PBSpecies::DEDENNE,PBSpecies::STUNFISK]
    when PBTypes::PSYCHIC
      ary=[PBSpecies::DROWZEE,PBSpecies::UNOWN,PBSpecies::SPOINK,PBSpecies::ELGYEM,
      PBSpecies::ESPURR,PBSpecies::MRMIME,PBSpecies::EXEGGCUTE,PBSpecies::LUNATONE,
      PBSpecies::SOLROCK]
    when PBTypes::ICE
      ary=[PBSpecies::VANILLISH,PBSpecies::CUBCHOO,PBSpecies::SNOVER,
      PBSpecies::AMAURA,PBSpecies::SEEL]
    when PBTypes::DRAGON
      ary=[PBSpecies::TYRUNT,PBSpecies::SWABLU,PBSpecies::SEADRA,
      PBSpecies::SKRELP]
    when PBTypes::DARK
      ary=[PBSpecies::POOCHYENA,PBSpecies::PURRLOIN,PBSpecies::INKAY,
      PBSpecies::NUZLEAF,PBSpecies::STUNKY,PBSpecies::PANCHAM]
    when PBTypes::FAIRY
      ary=[PBSpecies::CLEFAIRY,PBSpecies::SNUBBULL,PBSpecies::SPRITZEE,
      PBSpecies::JIGGLYPUFF,PBSpecies::CARBINK,PBSpecies::DEDENNE]
    when PBTypes::STEEL
      ary=[PBSpecies::NOSEPASS,PBSpecies::KARRABLAST,PBSpecies::SHIELDON,
      PBSpecies::BRONZOR,PBSpecies::ONIX,PBSpecies::KLANG]
    when PBTypes::GHOST
      ary=[PBSpecies::MISDREAVUS,PBSpecies::DRIFLOON,PBSpecies::PUMPKABOO,
      PBSpecies::SHEDINJA]
    when PBTypes::BUG
      ary=[PBSpecies::CATERPIE,PBSpecies::WURMPLE,PBSpecies::WEEDLE,
      PBSpecies::VOLBEAT,PBSpecies::ILLUMISE,PBSpecies::BURMY,
      PBSpecies::SCATTERBUG,PBSpecies::PARAS,PBSpecies::VENONAT,
      PBSpecies::LEDYBA,PBSpecies::SPINARAK,PBSpecies::SURSKIT]
    when PBTypes::ROCK
      ary=[PBSpecies::NOSEPASS,PBSpecies::BOLDORE,PBSpecies::GRAVELER,
      PBSpecies::SUDOWOODO,PBSpecies::CORSOLA,PBSpecies::LUNATONE,PBSpecies::SOLROCK]
    when PBTypes::GROUND
      ary=[PBSpecies::SANDSHREW,PBSpecies::BALTOY,PBSpecies::STUNFISK,
      PBSpecies::GRAVELER,PBSpecies::NUMEL,PBSpecies::PALPITOAD,PBSpecies::BUNNELBY]
    when PBTypes::POISON
      ary=[PBSpecies::EKANS,PBSpecies::GULPIN,PBSpecies::TRUBBISH,
      PBSpecies::WEEDLE,PBSpecies::GLOOM,PBSpecies::WEEPINBELL,PBSpecies::SPINARAK,
      PBSpecies::QWILFISH]
    when PBTypes::FIGHTING
      ary=[PBSpecies::MANKEY,PBSpecies::TYROGUE,PBSpecies::THROH,PBSpecies::SAWK,
      PBSpecies::PANCHAM]
    when PBTypes::FLYING
      ary=[PBSpecies::PIDGEY,PBSpecies::SPEAROW,PBSpecies::FARFETCHD,
      PBSpecies::LEDYBA,PBSpecies::HOPPIP,PBSpecies::TAILLOW,PBSpecies::WINGULL,
      PBSpecies::STARLY,PBSpecies::COMBEE,PBSpecies::CHATOT,PBSpecies::PIDOVE,
      PBSpecies::DUCKLETT]
    when PBTypes::NORMAL
      ary=[PBSpecies::RATTATA,PBSpecies::MEOWTH,PBSpecies::LICKITUNG,
      PBSpecies::SENTRET,PBSpecies::TEDDIURSA,PBSpecies::DUNSPARCE,PBSpecies::STANTLER,
      PBSpecies::ZIGZAGOON,PBSpecies::PATRAT,PBSpecies::SKITTY,PBSpecies::GLAMEOW,PBSpecies::MEOWTH,PBSpecies::HERDIER,
      PBSpecies::BUNNELBY]
  end
  return ary
end

def fsGetPokemon2(type)
  case type
    when PBTypes::FIRE
      ary=[PBSpecies::CHARMELEON,PBSpecies::QUILAVA,PBSpecies::COMBUSKEN,
      PBSpecies::MONFERNO,PBSpecies::PIGNITE,PBSpecies::BRAIXEN]
    when PBTypes::WATER
      ary=[PBSpecies::WARTORTLE,PBSpecies::CROCONAW,PBSpecies::MARSHTOMP,
      PBSpecies::PRINPLUP,PBSpecies::DEWOTT,PBSpecies::FROGADIER]
    when PBTypes::GRASS
      ary=[PBSpecies::IVYSAUR,PBSpecies::BAYLEEF,PBSpecies::GROVYLE,
      PBSpecies::GROTLE,PBSpecies::SERVINE,PBSpecies::QUILLADIN]
    when PBTypes::ELECTRIC
      ary=[PBSpecies::PIKACHU,PBSpecies::VOLTORB,PBSpecies::ELECTRIKE,
      PBSpecies::LUXIO,PBSpecies::ROTOM,PBSpecies::CHINCHOU,PBSpecies::JOLTIK]
    when PBTypes::PSYCHIC
      ary=[PBSpecies::WYNAUT,PBSpecies::CHIMECHO,PBSpecies::MUNNA,
      PBSpecies::GOTHORITA,PBSpecies::WOOBAT,PBSpecies::SLOWPOKE,PBSpecies::JYNX,
      PBSpecies::GIRAFARIG,PBSpecies::BALTOY,PBSpecies::BRONZOR]
    when PBTypes::ICE
      ary=[PBSpecies::SNORUNT,PBSpecies::CRYOGONAL,PBSpecies::BERGMITE,PBSpecies::JYNX,
      PBSpecies::DELIBIRD,PBSpecies::LAPRAS]
    when PBTypes::DRAGON
      ary=[PBSpecies::DRUDDIGON,PBSpecies::VIBRAVA,PBSpecies::SLIGGOO,PBSpecies::NOIBAT,
      PBSpecies::FRAXURE]
    when PBTypes::DARK
      ary=[PBSpecies::ZORUA,PBSpecies::MURKROW,PBSpecies::HOUNDOUR,PBSpecies::SCRAGGY,
      PBSpecies::CACNEA,PBSpecies::CORPHISH,PBSpecies::SPIRITOMB,
      PBSpecies::KROKOROK]
    when PBTypes::FAIRY
      ary=[PBSpecies::TOGETIC,PBSpecies::SWIRLIX,PBSpecies::MRMIME,
      PBSpecies::KIRLIA,PBSpecies::COTTONEE,PBSpecies::SYLVEON]
    when PBTypes::STEEL
      ary=[PBSpecies::MAGNETON,PBSpecies::SKARMORY,PBSpecies::PINECO,
      PBSpecies::PRINPLUP,PBSpecies::PAWNIARD,PBSpecies::FERROSEED,PBSpecies::DURANT]
    when PBTypes::GHOST
      ary=[PBSpecies::ROTOM,PBSpecies::SABLEYE,PBSpecies::GOLETT,
      PBSpecies::YAMASK,PBSpecies::SHUPPET,PBSpecies::SPIRITOMB,
      PBSpecies::PHANTUMP]
    when PBTypes::BUG
      ary=[PBSpecies::DURANT,PBSpecies::DWEBBLE,PBSpecies::SWADLOON,
      PBSpecies::COMBEE,PBSpecies::SHUCKLE,PBSpecies::PINECO,PBSpecies::YANMA,
      PBSpecies::SHELMET,PBSpecies::KARRABLAST]
    when PBTypes::ROCK
      ary=[PBSpecies::CRANIDOS,PBSpecies::ONIX,PBSpecies::OMANYTE,PBSpecies::KABUTO,
      PBSpecies::ONIX,PBSpecies::SHUCKLE,PBSpecies::SHIELDON,PBSpecies::AMAURA,
      PBSpecies::TYRUNT,PBSpecies::LILEEP,PBSpecies::BINACLE,PBSpecies::ANORITH]
    when PBTypes::GROUND
      ary=[PBSpecies::DIGLETT,PBSpecies::CUBONE,PBSpecies::PHANPY,PBSpecies::HIPPOPOTAS,
      PBSpecies::RHYDON,PBSpecies::BARBOACH,PBSpecies::KROKOROK,PBSpecies::GOLETT,PBSpecies::WOOPER,
      PBSpecies::MARSHTOMP]
    when PBTypes::POISON
      ary=[PBSpecies::NIDORINO,PBSpecies::NIDORINA,PBSpecies::SEVIPER,
      PBSpecies::GOLBAT,PBSpecies::STUNKY,PBSpecies::VENONAT,
      PBSpecies::ROSELIA,PBSpecies::WHIRLIPEDE,PBSpecies::FOONGUS]
    when PBTypes::FIGHTING
      ary=[PBSpecies::MACHOKE,PBSpecies::MAKUHITA,PBSpecies::MIENFOO,
      PBSpecies::HAWLUCHA,PBSpecies::POLIWHIRL,PBSpecies::COMBUSKEN,
      PBSpecies::PIGNITE,PBSpecies::HERACROSS,PBSpecies::MAKUHITA,PBSpecies::SCRAGGY]
    when PBTypes::FLYING
      ary=[PBSpecies::EMOLGA,PBSpecies::WOOBAT,PBSpecies::MANTYKE,PBSpecies::TOGETIC,
      PBSpecies::DRIFLOON,PBSpecies::SWABLU,PBSpecies::TROPIUS,PBSpecies::DELIBIRD,
      PBSpecies::YANMA,PBSpecies::NATU,PBSpecies::GOLBAT,PBSpecies::HOOTHOOT,
      PBSpecies::DODUO]
    when PBTypes::NORMAL
      ary=[PBSpecies::PORYGON,PBSpecies::EEVEE,PBSpecies::AIPOM,PBSpecies::SMEARGLE,
      PBSpecies::MILTANK,PBSpecies::CHANSEY,PBSpecies::VIGOROTH,PBSpecies::LOUDRED,
      PBSpecies::BUNEARY,PBSpecies::AUDINO,PBSpecies::MINCCINO,PBSpecies::BOUFFALANT,
      PBSpecies::FURFROU]
  end
  return ary
end

def fsGetPokemon3(type)
  case type
    when PBTypes::FIRE
      ary=[PBSpecies::LARVESTA,PBSpecies::LAMPENT,PBSpecies::NINETALES,PBSpecies::FLETCHINDER,
      PBSpecies::DARUMAKA,PBSpecies::GROWLITHE]
    when PBTypes::WATER
      ary=[PBSpecies::SEADRA,PBSpecies::FEEBAS,PBSpecies::MARILL,PBSpecies::CARVANHA,PBSpecies::CORPHISH,
      PBSpecies::SHELLOS,PBSpecies::TENTACOOL,PBSpecies::DUCKLETT,
      PBSpecies::CLAUNCHER,PBSpecies::BINACLE,PBSpecies::FRILLISH,PBSpecies::SEALEO,PBSpecies::STARYU,PBSpecies::KABUTO,PBSpecies::OMANYTE,PBSpecies::POLIWHIRL]
    when PBTypes::GRASS
      ary=[PBSpecies::TANGELA,PBSpecies::SHROOMISH,PBSpecies::LEAFEON,PBSpecies::GOGOAT,
      PBSpecies::WEEPINBELL,PBSpecies::ROSELIA,PBSpecies::TROPIUS,
      PBSpecies::COTTONEE,PBSpecies::FERROSEED,PBSpecies::LILEEP,
      PBSpecies::SWADLOON,PBSpecies::DEERLING,PBSpecies::PHANTUMP]
    when PBTypes::ELECTRIC
      ary=[PBSpecies::ELECTABUZZ,PBSpecies::FLAAFFY,PBSpecies::BLITZLE,
      PBSpecies::EELEKTRIK,PBSpecies::JOLTEON]
    when PBTypes::PSYCHIC
      ary=[PBSpecies::ABRA,PBSpecies::DUOSION,PBSpecies::NATU,PBSpecies::KIRLIA,
      PBSpecies::SIGILYPH,PBSpecies::STARYU,PBSpecies::MEDITITE,PBSpecies::METANG]
    when PBTypes::ICE
      ary=[PBSpecies::PILOSWINE,PBSpecies::SEALEO,PBSpecies::SHELLDER,
      PBSpecies::SNEASEL]
    when PBTypes::DRAGON
      ary=[PBSpecies::DRAGONAIR,PBSpecies::SHELGON,PBSpecies::ZWEILOUS,PBSpecies::GABITE]
    when PBTypes::DARK
      ary=[PBSpecies::SKORUPI,PBSpecies::PUPITAR,PBSpecies::VULLABY,PBSpecies::PAWNIARD,
      PBSpecies::SNEASEL,PBSpecies::SABLEYE,PBSpecies::ABSOL]
    when PBTypes::FAIRY
      ary=[PBSpecies::MARILL,PBSpecies::MAWILE,PBSpecies::FLOETTE,PBSpecies::KLEFKI,
      PBSpecies::SWABLU]
    when PBTypes::STEEL
      ary=[PBSpecies::MAWILE,PBSpecies::LAIRON,PBSpecies::METANG,
      PBSpecies::DOUBLADE,PBSpecies::SCIZOR,PBSpecies::DRILBUR,PBSpecies::RIOLU]
    when PBTypes::GHOST
      ary=[PBSpecies::DOUBLADE,PBSpecies::HAUNTER,PBSpecies::LAMPENT,
      PBSpecies::DUSCLOPS,PBSpecies::FRILLISH]
    when PBTypes::BUG
      ary=[PBSpecies::PINSIR,PBSpecies::SCYTHER,PBSpecies::SCIZOR,
      PBSpecies::LARVESTA,PBSpecies::WHIRLIPEDE,PBSpecies::HERACROSS,PBSpecies::NINCADA,
      PBSpecies::JOLTIK]
    when PBTypes::ROCK
      ary=[PBSpecies::AERODACTYL,PBSpecies::PUPITAR,PBSpecies::ARCHEN,PBSpecies::LAIRON,
      PBSpecies::RHYDON]
    when PBTypes::GROUND
      ary=[PBSpecies::DRILBUR,PBSpecies::VIBRAVA,PBSpecies::GLIGAR,PBSpecies::GABITE,
      PBSpecies::PILOSWINE,PBSpecies::NIDOKING,PBSpecies::NIDOQUEEN]
    when PBTypes::POISON
      ary=[PBSpecies::MUK,PBSpecies::KOFFING,PBSpecies::SKORUPI,PBSpecies::CROAGUNK,
      PBSpecies::SKRELP,PBSpecies::IVYSAUR,PBSpecies::TENTACOOL,
      PBSpecies::HAUNTER]
    when PBTypes::FIGHTING
      ary=[PBSpecies::GURDURR,PBSpecies::RIOLU,PBSpecies::MEDITITE,PBSpecies::HAWLUCHA,
      PBSpecies::CROAGUNK]
    when PBTypes::FLYING
      ary=[PBSpecies::CHARMELEON,PBSpecies::DRAGONAIR,PBSpecies::SHELGON,
      PBSpecies::SIGILYPH,PBSpecies::GLIGAR,PBSpecies::RUFFLET,PBSpecies::HAWLUCHA,
      PBSpecies::FLETCHINDER]
    when PBTypes::NORMAL
      ary=[PBSpecies::DITTO,PBSpecies::ZANGOOSE,PBSpecies::SPINDA,PBSpecies::CASTFORM,
      PBSpecies::KANGASKHAN,PBSpecies::TAUROS]
  end
  return ary
end