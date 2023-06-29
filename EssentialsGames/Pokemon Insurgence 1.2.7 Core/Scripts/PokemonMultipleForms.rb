class PokeBattle_Pokemon
  attr_accessor :primalBattle
  attr_accessor :normalMewtwo
  attr_accessor :normalMegaMewtwoX
  attr_accessor :normalMegaMewtwoY
  attr_accessor :shadowMewtwo
  attr_accessor :shadowMegaMewtwo
  attr_accessor :megaTyranitar
  attr_accessor :megaFlygon
  attr_accessor :zygardeForm
  
  def form
    v=MultipleForms.call("getForm",self)
    if v!=nil
      self.form=v if !@form || v!=@form
      return v
    end
    return @form || 0
  end

  def form=(value)
    @form=value
    self.calcStats
    MultipleForms.call("onSetForm",self,value)
  end

  alias __mf_baseStats baseStats
  alias __mf_ability ability
  alias __mf_type1 type1
  alias __mf_type2 type2
  alias __mf_weight weight
  alias __mf_getMoveList getMoveList
  alias __mf_wildHoldItems wildHoldItems
  alias __mf_baseExp baseExp
  alias __mf_evYield evYield
  alias __mf_initialize initialize

  def baseStats
    v=MultipleForms.call("getBaseStats",self)
    return v if v!=nil  
    return self.__mf_baseStats
  end
def weight
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,35)
    weight=dexdata.fgetw
    dexdata.close
    return weight
  end
  def ability
    v=MultipleForms.call("ability",self)
    return v if v!=nil  
    return self.__mf_ability
  end

  def type1
    v=MultipleForms.call("type1",self)
    return v if v!=nil  
    return self.__mf_type1
  end

  def type2
    v=MultipleForms.call("type2",self)
    return v if v!=nil  
    return self.__mf_type2
  end

  def weight
    v=MultipleForms.call("weight",self)
    return v if v!=nil  
    return self.__mf_weight
  end

  def getMoveList
    v=MultipleForms.call("getMoveList",self)
    return v if v!=nil  
    return self.__mf_getMoveList
  end

  def wildHoldItems
    v=MultipleForms.call("wildHoldItems",self)
    return v if v!=nil  
    return self.__mf_wildHoldItems
  end

  def baseExp
    v=MultipleForms.call("baseExp",self)
    return v if v!=nil  
    return self.__mf_baseExp
  end

  def evYield
    v=MultipleForms.call("evYield",self)
    return v if v!=nil  
    return self.__mf_evYield
  end

  def initialize(*args)
    __mf_initialize(*args)
    f=MultipleForms.call("getFormOnCreation",self)
    @primalBattle=false
    @normalMegaMewtwoX=false
    @normalMegaMewtwoY=false
    @megaTyranitar=false
    @megaFlygon=false
    @zygardeForm=0
    @armorHeld=false
    @normalMewtwo=true
    if f
      self.form=f
      self.resetMoves
    end
  end
  
  def primalBattle(primal)
    @primalBattle=primal
  end
  
  def isPrimalBattle?
    return @primalBattle
  end
  
  def shadowMewtwo(mewtwo)
    @shadowMewtwo=mewtwo
  end
  
  def isShadowMewtwo?
    return @shadowMewtwo
  end
  
  def normalMewtwo(mewtwo)
    @normalMewtwo=mewtwo
  end
  
  def isNormalMewtwo?
    return @normalMewtwo
  end
  
  def normalMegaMewtwoX(mewtwo)
    @normalMegaMewtwoX=mewtwo
  end
  
  def isNormalMegaMewtwoX?
    return @normalMegaMewtwoX
  end
  
  def normalMegaMewtwoY(mewtwo)
    @normalMegaMewtwoY=mewtwo
  end
  
  def isNormalMegaMewtwoY?
    return @normalMegaMewtwoY
  end
  
  def shadowMegaMewtwo(mewtwo)
    @shadowMegaMewtwo=mewtwo
  end
  
  def isShadowMegaMewtwo?
    return @shadowMegaMewtwo
  end
  
  def megaTyranitar(tyranitar)
    @megaTyranitar=tyranitar
  end
  
  def isMegaTyranitar?
    return @megaTyranitar
  end
  
  def megaFlygon(flygon)
    @megaFlygon=flygon
  end
  
  def isMegaFlygon?
    return @megaFlygon
  end
  
  def zygardeForm(form)
    @zygardeForm=form
  end
  
  def getZygardeForm
    return @zygardeForm
  end
end



class PokeBattle_RealBattlePeer
  def pbOnEnteringBattle(battle,pokemon)
    f=MultipleForms.call("getFormOnEnteringBattle",pokemon)
    if f
      pokemon.form=f
      pbSeenForm(pokemon)
    end
  end
end



module MultipleForms
  @@formSpecies=HandlerHash.new(:PBSpecies)

  def self.copy(sym,*syms)
    @@formSpecies.copy(sym,*syms)
  end

  def self.register(sym,hash)
    @@formSpecies.add(sym,hash)
  end

  def self.registerIf(cond,hash)
    @@formSpecies.addIf(cond,hash)
  end

  def self.hasFunction?(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return sp && sp[func]
  end

  def self.getFunction(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return (sp && sp[func]) ? sp[func] : nil
  end

  def self.call(func,pokemon,*args)
    sp=@@formSpecies[pokemon.species]
    return nil if !sp || !sp[func]
    return sp[func].call(pokemon,*args)
  end
end



def drawSpot(bitmap,spotpattern,x,y,red,green,blue)
  height=spotpattern.length
  width=spotpattern[0].length
  for yy in 0...height
    spot=spotpattern[yy]
    for xx in 0...width
      if spot[xx]==1
        xOrg=(x+xx)<<1
        yOrg=(y+yy)<<1
        color=bitmap.get_pixel(xOrg,yOrg)
        r=color.red+red
        g=color.green+green
        b=color.blue+blue
        color.red=[[r,0].max,255].min
        color.green=[[g,0].max,255].min
        color.blue=[[b,0].max,255].min
        bitmap.set_pixel(xOrg,yOrg,color)
        bitmap.set_pixel(xOrg+1,yOrg,color)
        bitmap.set_pixel(xOrg,yOrg+1,color)
        bitmap.set_pixel(xOrg+1,yOrg+1,color)
      end   
    end
  end
end

def pbSpindaSpots(pokemon,bitmap)
  spot1=[
     [0,0,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,0,0]
  ]
  spot2=[
     [0,0,1,1,1,0,0],
     [0,1,1,1,1,1,0],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [0,1,1,1,1,1,0],
     [0,0,1,1,1,0,0]
  ]
  spot3=[
     [0,0,0,0,0,1,1,1,1,0,0,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,0,0,0,1,1,1,0,0,0,0,0]
  ]
  spot4=[
     [0,0,0,0,1,1,1,0,0,0,0,0],
     [0,0,1,1,1,1,1,1,1,0,0,0],
     [0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,0,1,1,1,1,1,0,0,0]
  ]
  id=pokemon.personalID
  h=(id>>28)&15
  g=(id>>24)&15
  f=(id>>20)&15
  e=(id>>16)&15
  d=(id>>12)&15
  c=(id>>8)&15
  b=(id>>4)&15
  a=(id)&15
  if pokemon.isShiny?
    drawSpot(bitmap,spot1,b+33,a+25,-75,-10,-150)
    drawSpot(bitmap,spot2,d+21,c+24,-75,-10,-150)
    drawSpot(bitmap,spot3,f+39,e+7,-75,-10,-150)
    drawSpot(bitmap,spot4,h+15,g+6,-75,-10,-150)
  else
    drawSpot(bitmap,spot1,b+33,a+25,0,-115,-75)
    drawSpot(bitmap,spot2,d+21,c+24,0,-115,-75)
    drawSpot(bitmap,spot3,f+39,e+7,0,-115,-75)
    drawSpot(bitmap,spot4,h+15,g+6,0,-115,-75)
  end
end

MultipleForms.register(:UNOWN,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(28)
}
})

MultipleForms.register(:SPINDA,{
"alterBitmap"=>proc{|pokemon,bitmap|
   pbSpindaSpots(pokemon,bitmap)
}
})

MultipleForms.register(:CASTFORM,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0              # Normal Form
   case pokemon.form
     when 1; next getID(PBTypes,:FIRE)  # Sunny Form
     when 2; next getID(PBTypes,:WATER) # Rainy Form
     when 3; next getID(PBTypes,:ICE)   # Snowy Form
     when 4; next getID(PBTypes,:DARK)  # Cloudy Form
     when 5; next getID(PBTypes,:ROCK)  # Sandy Form
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0              # Normal Form
   case pokemon.form
     when 1; next getID(PBTypes,:FIRE)  # Sunny Form
     when 2; next getID(PBTypes,:WATER) # Rainy Form
     when 3; next getID(PBTypes,:ICE)   # Snowy Form
     when 4; next getID(PBTypes,:DARK)  # Cloudy Form
     when 5; next getID(PBTypes,:GROUND)# Sandy Form
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DEOXYS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0                 # Normal Forme
   case pokemon.form
     when 1; next [50,180, 20,150,180, 20] # Attack Forme
     when 2; next [50, 70,160, 90, 70,160] # Defense Forme
     when 3; next [50, 95, 90,180, 95, 90] # Speed Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0      # Normal Forme
   case pokemon.form
     when 1; next [0,2,0,0,1,0] # Attack Forme
     when 2; next [0,0,2,0,0,1] # Defense Forme
     when 3; next [0,0,0,3,0,0] # Speed Forme
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
                        [25,:TAUNT],[33,:PURSUIT],[41,:PSYCHIC],[49,:SUPERPOWER],
                        [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:COSMICPOWER],
                        [81,:ZAPCANNON],[89,:PSYCHOBOOST],[97,:HYPERBEAM]]
     when 2 ; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
                        [25,:KNOCKOFF],[33,:SPIKES],[41,:PSYCHIC],[49,:SNATCH],
                        [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:IRONDEFENSE],
                        [73,:AMNESIA],[81,:RECOVER],[89,:PSYCHOBOOST],
                        [97,:COUNTER],[97,:MIRRORCOAT]]
     when 3 ; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:DOUBLETEAM],
                        [25,:KNOCKOFF],[33,:PURSUIT],[41,:PSYCHIC],[49,:SWIFT],
                        [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:AGILITY],
                        [81,:RECOVER],[89,:PSYCHOBOOST],[97,:EXTREMESPEED]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ZYGARDE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0              # 50% Forme
   case pokemon.form
     when 1; next [54,100,71,115,61,85] # 10% Forme
     when 2; next [216,100,121,85,91,95]# Complete Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0      # 50% Forme
   case pokemon.form
     when 1; next [3,0,0,0,0,0] # 10% Forme
     when 2; next [3,0,0,0,0,0] # Complete Forme
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BURMY,{
#"getFormOnCreation"=>proc{|pokemon|
#   env=pbGetEnvironment()
#   mapary=[173,174,453,448,546,547,548,449,564]
#   if env==PBEnvironment::Sand || env==PBEnvironment::Rock ||
#      env==PBEnvironment::Cave || mapary.include?($game_map.map_id)
#      
#     next 1 # Sandy Cloak
#        elsif !pbGetMetadata($game_map.map_id,MetadataOutdoor)
#     next 2 # Trash Cloak#
#
#   else
#     next 0 # Plant Cloak
#   end
#},
"getFormOnEnteringBattle"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand || env==PBEnvironment::Rock ||
      env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
}
})

MultipleForms.register(:WORMADAM,{
#"getFormOnCreation"=>proc{|pokemon|
#   env=pbGetEnvironment()
#   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
#     next 2 # Trash Cloak
#   elsif env==PBEnvironment::Sand || env==PBEnvironment::Rock ||
#      env==PBEnvironment::Cave
#     next 1 # Sandy Cloak
#   else
#     next 0 # Plant Cloak
#   end
#},
"type2"=>proc{|pokemon|
   next if pokemon.form==0               # Plant Cloak
   case pokemon.form
     when 1; next getID(PBTypes,:GROUND) # Sandy Cloak
     when 2; next getID(PBTypes,:STEEL)  # Trash Cloak
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0              # Plant Cloak
   case pokemon.form
     when 1; next [60,79,105,36,59, 85] # Sandy Cloak
     when 2; next [60,69, 95,36,69, 95] # Trash Cloak
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0      # Plant Cloak
   case pokemon.form
     when 1; next [0,0,2,0,0,0] # Sandy Cloak
     when 2; next [0,0,1,0,0,1] # Trash Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
                        [23,:CONFUSION],[26,:ROCKBLAST],[29,:HARDEN],[32,:PSYBEAM],
                        [35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],[44,:PSYCHIC],
                        [47,:FISSURE]]
     when 2 ; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
                        [23,:CONFUSION],[26,:MIRRORSHOT],[29,:METALSOUND],
                        [32,:PSYBEAM],[35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],
                        [44,:PSYCHIC],[47,:IRONHEAD]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

MultipleForms.register(:SHELLOS,{
"getFormOnCreation"=>proc{|pokemon|
   maps=[2,5,39,41,44,69]   # Map IDs for second form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
}
})

MultipleForms.copy(:SHELLOS,:GASTRODON)

MultipleForms.register(:GROUDON,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0               # Altered Forme
   next getID(PBAbilities,:DESOLATELAND) # Origin Forme
},
"type2"=>proc{|pokemon|
   types=[:GROUND,:FIRE]
   next getID(PBTypes,types[pokemon.form])
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [100,180,160,90,150,90] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:FLOETTE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form!=5     # All normal forms
   next [74,65,67,92,125,128]  # Eternal Flower Forme
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:TACKLE],[1,:VINEWHIP],[6,:FAIRYWIND],
                        [10,:LUCKYCHANT],[15,:RAZORLEAF],[20,:WISH],
                        [22,:MAGICALLEAF],[24,:GRASSYTERRAIN],[28,:PETALBLIZZARD],
                        [33,:AROMATHERAPY],[37,:MISTYTERRAIN],[41,:MOONBLAST],
                        [45,:PETALDANCE],[48,:SOLARBEAM],[50,:LIGHTOFRUIN]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:HOOPA,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:MAGICIAN) # Origin Forme
},
"type2"=>proc{|pokemon|
   types=[:GHOST,:DARK]
   next getID(PBTypes,types[pokemon.form])
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [80,160,60,80,170,130] # Sky Forme
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:HYPERSPACEFURY],[1,:TRICK],[1,:DESTINYBOND],
                        [1,:ALLYSWITCH],[1,:CONFUSION],[6,:ASTONISH],
                        [10,:MAGICCOAT],[16,:LIGHTSCREEN],[19,:PSYBEAM],
                        [25,:SKILLSWAP],[29,:POWERSPLIT],[29,:GUARDSPLIT],
                        [46,:KNOCKOFF],[50,:WONDERROOM],[50,:TRICKROOM],
                        [55,:DARKPULSE],[75,:PSYCHIC],[85,:HYPERSPACEFURY]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves=[
      :HYPERSPACEFURY, # Unbound
   ]
    moves.each{|move|
      pbDeleteMoveByID(pokemon,getID(PBMoves,move))
   }
   if pokemon.moves.find_all{|i| i.id!=0}.length==0
     pbAutoLearnMove(pokemon,getID(PBMoves,:CONFUSION))
   end
}
})

MultipleForms.register(:DELTAHOOPA,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Confined Forme
   next getID(PBAbilities,:CLOUDNINE) # Unbound Forme
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0     # Confined Forme
   next getID(PBTypes,:FAIRY) # Unbound Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Confined Forme
   next [80,160,60,80,170,130] # Unbound Forme
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:SPIRITAWAY],[1,:TAILWIND],[1,:DEFOG],
                        [1,:MIST],[1,:GUST],[6,:FAIRYWIND],
                        [10,:ICYWIND],[16,:SAFEGUARD],[19,:AIRCUTTER],
                        [25,:RAZORWIND],[29,:AGILITY],[46,:DAZZLINGGLEAM],
                        [50,:MIRRORMOVE],[55,:PLAYROUGH],[75,:HURRICANE],
                        [85,:SPIRITAWAY]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves=[
      :SPIRITAWAY, # Unbound
   ]
   moves.each{|move|
      pbDeleteMoveByID(pokemon,getID(PBMoves,move))
   }
   if pokemon.moves.find_all{|i| i.id!=0}.length==0
     pbAutoLearnMove(pokemon,getID(PBMoves,:AEROBLAST))
   end
}
})


MultipleForms.register(:HYDREIGON,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:LERNEAN) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [92,130,105,98,170,105] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:POLIWRATH,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:NOGUARD) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [90,155,120,70,70,105] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:POLITOED,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:DRIZZLE) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [90,75,95,80,120,140] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BEEDRILL,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:ADAPTABILITY) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [65,150,40,145,15,80] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:PIDGEOT,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:NOGUARD) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [83,80,80,121,135,80] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:DELTAPIDGEOT,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:INTIMIDATE) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [83,80,80,121,135,80] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:KYOGRE,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:PRIMORDIALSEA) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [100,150,90,90,180,160] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:REGIGIGAS,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:UNAWARE) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [110,195,140,100,95,130] # Sky Forme
},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:GROUND]
   next getID(PBTypes,types[pokemon.form])
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:RAYQUAZA,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:DELTASTREAM) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [105,180,100,115,180,100] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LOPUNNY,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [65,136,94,134,54,96]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SCRAPPY) # Origin Forme

},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING]
   next getID(PBTypes,types[pokemon.form])
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTALOPUNNY,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [65,136,94,134,54,96]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:INFILTRATOR) # Origin Forme

},
"type2"=>proc{|pokemon|
   types=[:FIGHTING,:PSYCHIC]
   next getID(PBTypes,types[pokemon.form])
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:AUDINO,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [103,60,126,50,80,126]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:HEALER) # Origin Forme

},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:FAIRY]
   next getID(PBTypes,types[pokemon.form])
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:GALLADE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [68,165,95,110,65,115]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:INNERFOCUS) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:DIANCIE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [50,160,110,110,160,110]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MAGICBOUNCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GOTHITELLE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,55,125,65,125,150]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:ETHEREALSHROUD) # Origin Forme

},
"type2"=>proc{|pokemon|
   types=[:PSYCHIC,:DARK]
   next getID(PBTypes,types[pokemon.form])
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:MILTANK,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [95,125,145,70,40,115]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:PENDULUM) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:SPIRITOMB,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [50,142,128,20,133,112]
 
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:TOUGHCLAWS) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})



MultipleForms.register(:JIRACHI,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:PERIODICORBIT) # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [100,130,115,110,130,115] # Sky Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:ROTOM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Normal Form
   next [50,65,107,86,105,107] # All alternate forms
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0               # Normal Form
   case pokemon.form
     when 1; next getID(PBTypes,:FIRE)   # Heat, Microwave
     when 2; next getID(PBTypes,:WATER)  # Wash, Washing Machine
     when 3; next getID(PBTypes,:ICE)    # Frost, Refrigerator
     when 4; next getID(PBTypes,:FLYING) # Fan
     when 5; next getID(PBTypes,:GRASS)  # Mow, Lawnmower
     when 6; next getID(PBTypes,:FAIRY)  # Mow, Lawnmower
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves=[
      :OVERHEAT,  # Heat, Microwave
      :HYDROPUMP, # Wash, Washing Machine
      :BLIZZARD,  # Frost, Refrigerator
      :AIRSLASH,  # Fan
      :LEAFSTORM,  # Mow, Lawnmower
      :MOONBLAST  # Fax, Fax
   ]
   moves.each{|move|
      pbDeleteMoveByID(pokemon,getID(PBMoves,move))
   }
   if form>0
     pbAutoLearnMove(pokemon,getID(PBMoves,moves[form-1]))
   end
   if pokemon.moves.find_all{|i| i.id!=0}.length==0
     pbAutoLearnMove(pokemon,getID(PBMoves,:THUNDERSHOCK))
   end
}
})

MultipleForms.register(:GIRATINA,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:OMNITYPE) if pokemon.form==2 # Origin Forme
   next getID(PBAbilities,:LEVITATE) # Origin Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 6500               # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Altered Forme
   next [150,135,135,130,135,135] if pokemon.form==2 # primal Forme
   next [150,120,100,90,120,100] # Origin Forme
},
"getForm"=>proc{|pokemon|
   maps=[0]   # Map IDs for Origin Forme
   next 1 if isConst?(pokemon.item,PBItems,:GRISEOUSORB)
   next 2 if isConst?(pokemon.item,PBItems,:CRYSTALPIECE) && pokemon.isPrimalBattle?
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves=[
      :SHADOWFORCE,
      :SHADOWFORCE
   ]
   moves.each{|move|
      pbDeleteMoveByID(pokemon,getID(PBMoves,move))
   }
   if form==2
     pbAutoLearnMove(pokemon,getID(PBMoves,moves[form-1]))
   end
   if pokemon.moves.find_all{|i| i.id!=0}.length==0
     pbAutoLearnMove(pokemon,getID(PBMoves,:SHADOWFORCE))
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SHAYMIN,{
"type2"=>proc{|pokemon|
   next if pokemon.form==0     # Land Forme
   next getID(PBTypes,:FLYING) # Sky Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0              # Land Forme
   next getID(PBAbilities,:SERENEGRACE) # Sky Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next 52                 # Sky Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [100,103,75,127,120,75] # Sky Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next [0,0,0,3,0,0]      # Sky Forme
},
"getForm"=>proc{|pokemon|
   next 0 if PBDayNight.isNight?(pbGetTimeNow) ||
             pokemon.hp<=0 || pokemon.status==PBStatuses::FROZEN
   next nil
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:GROWTH],[10,:MAGICALLEAF],[19,:LEECHSEED],
                        [28,:QUICKATTACK],[37,:SWEETSCENT],[46,:NATURALGIFT],
                        [55,:WORRYSEED],[64,:AIRSLASH],[73,:ENERGYBALL],
                        [82,:SWEETKISS],[91,:LEAFSTORM],[100,:SEEDFLARE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:GRENINJA,{
"type1"=>proc{|pokemon|
   next getID(PBTypes,pokemon.form-1) if pokemon.form != 0
   next PBTypes::WATER 
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,pokemon.form-1) if pokemon.form != 0
   next PBTypes::DARK 
}
})

MultipleForms.register(:DELTADITTO,{
"type1"=>proc{|pokemon|

   next getID(PBTypes,pokemon.form) if pokemon.form != 0
   next PBTypes::NORMAL
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,pokemon.form) if pokemon.form != 0
   next PBTypes::NORMAL
}
})

MultipleForms.register(:KECLEON,{
"type1"=>proc{|pokemon|

   next getID(PBTypes,pokemon.form) if pokemon.form != 0
   next PBTypes::NORMAL
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,pokemon.form) if pokemon.form != 0
   next PBTypes::NORMAL
}
})

MultipleForms.register(:FROAKIE,{
"type1"=>proc{|pokemon|
   next getID(PBTypes,pokemon.form-1) if pokemon.form != 0
   next PBTypes::WATER
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,pokemon.form-1) if pokemon.form != 0
   next PBTypes::WATER
}
})
MultipleForms.register(:FROGADIER,{
"type1"=>proc{|pokemon|
   next getID(PBTypes,pokemon.form-1) if pokemon.form != 0
   next PBTypes::WATER
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,pokemon.form-1) if pokemon.form != 0
   next PBTypes::WATER 
}
})


MultipleForms.register(:ARCEUS,{
"type1"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK,:FAIRY,:NORMAL]
   next getID(PBTypes,types[pokemon.form])
},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK,:FAIRY,:DRAGON]
   next getID(PBTypes,types[pokemon.form])
},
"getForm"=>proc{|pokemon|
   #if isConst?(pokemon.ability,PBAbilities,:MULTITYPE)
   if pokemon.abilityflag!=2
     next 1  if isConst?(pokemon.item,PBItems,:FISTPLATE)
     next 2  if isConst?(pokemon.item,PBItems,:SKYPLATE)
     next 3  if isConst?(pokemon.item,PBItems,:TOXICPLATE)
     next 4  if isConst?(pokemon.item,PBItems,:EARTHPLATE)
     next 5  if isConst?(pokemon.item,PBItems,:STONEPLATE)
     next 6  if isConst?(pokemon.item,PBItems,:INSECTPLATE)
     next 7  if isConst?(pokemon.item,PBItems,:SPOOKYPLATE)
     next 8  if isConst?(pokemon.item,PBItems,:IRONPLATE)
     next 10 if isConst?(pokemon.item,PBItems,:FLAMEPLATE)
     next 11 if isConst?(pokemon.item,PBItems,:SPLASHPLATE)
     next 12 if isConst?(pokemon.item,PBItems,:MEADOWPLATE)
     next 13 if isConst?(pokemon.item,PBItems,:ZAPPLATE)
     next 14 if isConst?(pokemon.item,PBItems,:MINDPLATE)
     next 15 if isConst?(pokemon.item,PBItems,:ICICLEPLATE)
     next 16 if isConst?(pokemon.item,PBItems,:DRACOPLATE)
     next 17 if isConst?(pokemon.item,PBItems,:DREADPLATE)
     next 18 if isConst?(pokemon.item,PBItems,:PIXIEPLATE)
   end
   next 19 if isConst?(pokemon.item,PBItems,:CRYSTALPIECE) && pokemon.isPrimalBattle?
   if pokemon.abilityflag!=2
     next 0
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves=[
      :JUDGMENT,
      :JUDGMENT,
      :JUDGMENT, #3
      :JUDGMENT,
      :JUDGMENT,
      :JUDGMENT, #6
      :JUDGMENT,
      :JUDGMENT,
      :JUDGMENT, #9
      :JUDGMENT,
      :JUDGMENT,
      :JUDGMENT, #12
      :JUDGMENT,
      :JUDGMENT,
      :JUDGMENT, #15
      :JUDGMENT,
      :JUDGMENT,
      :JUDGMENT, #18
   ]
   moves.each{|move|
      pbDeleteMoveByID(pokemon,getID(PBMoves,move))
   }
   if form==2
     pbAutoLearnMove(pokemon,getID(PBMoves,moves[form-1]))
   end
   if pokemon.moves.find_all{|i| i.id!=0}.length==0
     pbAutoLearnMove(pokemon,getID(PBMoves,:JUDGMENT))
   end
},
"ability"=>proc{|pokemon|
  next getID(PBAbilities,:ANCIENTPRESENCE) if pokemon.form==19
  next
  },
  "getBaseStats"=>proc{|pokemon|
   next [120,150,130,140,150,130] if pokemon.form==19# Zen Mode
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
  }
})

MultipleForms.register(:MEWTWO,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:HUBRIS) if pokemon.form==1 # Armored Forme
   next getID(PBAbilities,:STEADFAST) if pokemon.form==2 # Mega Forme X
   next getID(PBAbilities,:INSOMNIA) if pokemon.form==3 # Mega Forme Y
   next getID(PBAbilities,:INTIMIDATE) if pokemon.form==4 # Shadow Forme
   next getID(PBAbilities,:SHADOWSYNERGY) if pokemon.form==5 # Mega Shadow Forme
},
"type2"=>proc{|pokemon|
   types=[:PSYCHIC,:PSYCHIC,:FIGHTING,:PSYCHIC,:DARK,:FIGHTING]
   next getID(PBTypes,types[pokemon.form])
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form<2  # Standard Mode
   next if pokemon.form==4
   next [106,150,70,140,194,120] if pokemon.form==3 # Zen Mode
   next [106,190,100,130,154,100] if pokemon.form==2
   next [106,190,100,130,154,100] if pokemon.form==5
   next
},
"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:MEWTWOMACHINE) && !pokemon.isShadowMewtwo?
   next 2  if isConst?(pokemon.item,PBItems,:MEWTWONITEX) && pokemon.isNormalMegaMewtwoX? &&
       pokemon.isNormalMewtwo?
   next 3  if isConst?(pokemon.item,PBItems,:MEWTWONITEY) && pokemon.isNormalMegaMewtwoY? &&
       pokemon.isNormalMewtwo?
   next 4  if pokemon.isShadowMewtwo? && !pokemon.isShadowMegaMewtwo?
   next 5  if pokemon.isShadowMewtwo? && pokemon.isShadowMegaMewtwo?
   next 0 #if pokemon.isNormalMewtwo? && !isConst?(pokemon.item,PBItems,:MEWTWOMACHINE) &&
     #!pokemon.isShadowMegaMewtwo?
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   next if pokemon.form==1
   next if pokemon.form==2
   next if pokemon.form==3
   movelist=[]
   case pokemon.form
     when 4; movelist=[[1,:CONFUSION],[1,:DISABLE],[1,:SAFEGUARD],[1,:NIGHTSLASH],
                       [8,:SWIFT],[15,:FUTURESIGHT],[22,:PSYCHUP],
                       [29,:MIRACLEEYE],[36,:PSYCHOCUT],[43,:POWERSWAP],
                       [43,:GUARDSWAP],[50,:RECOVER],[57,:PSYCHIC],[64,:BARRIER],
                       [70,:AURASPHERE],[79,:AMNESIA],[86,:MIST],[93,:MEFIRST],
                       [100,:PSYSTRIKE],[100,:DARKNOVA]]
     when 5; movelist=[[1,:CONFUSION],[1,:DISABLE],[1,:SAFEGUARD],[1,:NIGHTSLASH],
                       [8,:SWIFT],[15,:FUTURESIGHT],[22,:PSYCHUP],
                       [29,:MIRACLEEYE],[36,:PSYCHOCUT],[43,:POWERSWAP],
                       [43,:GUARDSWAP],[50,:RECOVER],[57,:PSYCHIC],[64,:BARRIER],
                       [70,:AURASPHERE],[79,:AMNESIA],[86,:MIST],[93,:MEFIRST],
                       [100,:PSYSTRIKE],[100,:DARKNOVA]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   if form==0
     pokemon.normalMewtwo(true)
     pokemon.shadowMewtwo(false)
     pokemon.shadowMegaMewtwo(false)
   end
   if form==1
     pokemon.normalMewtwo(true)
     pokemon.shadowMewtwo(false)
     pokemon.shadowMegaMewtwo(false)
   end
   if form==2
     pokemon.normalMewtwo(true)
     pokemon.shadowMewtwo(false)
     pokemon.shadowMegaMewtwo(false)
   end
   if form==3
     pokemon.normalMewtwo(true)
     pokemon.shadowMewtwo(false)
     pokemon.shadowMegaMewtwo(false)
   end
   if form==4
     pokemon.normalMewtwo(false)
     pokemon.shadowMewtwo(true)
     pokemon.shadowMegaMewtwo(false)
   end
   if form==5
     pokemon.normalMewtwo(false)
     pokemon.shadowMewtwo(true)
     pokemon.shadowMegaMewtwo(true)
   end
   pbSeenForm(pokemon)
}
})














MultipleForms.register(:BASCULIN,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(2)
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0               # Red-Striped
   next getID(PBAbilities,:ROCKHEAD) if pokemon.abilityflag==0 # Blue-Striped
   next getID(PBAbilities,:ADAPTABILITY) if pokemon.abilityflag==1 # Blue-Striped
   next getID(PBAbilities,:MOLDBREAKER) if pokemon.abilityflag==2 # Blue-Striped

},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Red-Striped
   next [0,getID(PBItems,:DEEPSEASCALE),0] # Blue-Striped
}
})

MultipleForms.register(:DARMANITAN,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Standard Mode
   next [105,30,105,55,140,105] # Zen Mode
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Standard Mode
   next getID(PBTypes,:PSYCHIC) # Zen Mode
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Standard Mode
   next [0,0,0,0,2,0]      # Zen Mode
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DEERLING,{
"getForm"=>proc{|pokemon|
   time=pbGetTimeNow
   next 3 if (time.month==1 || time.month==2)
   next ((time.month/3)-1).floor
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.copy(:DEERLING,:SAWSBUCK)

MultipleForms.register(:VIVILLON,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(20)   if $game_map.map_id==794
   next 0
}
})

MultipleForms.register(:FLABABE,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(5)  if $game_map.map_id==794
   next 0
}
})

MultipleForms.register(:FLOETTE,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(5)  if $game_map.map_id==151
   next 0
}
})

MultipleForms.register(:FLORGES,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(5) if $game_map.map_id==794
   next 0
}
})

MultipleForms.register(:TYPHLOSION,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [78,89,88,110,159,110]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:HUBRIS) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTATYPHLOSION,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [78,89,88,110,159,110]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SUPERCELL) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LATIOS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,130,100,110,160,120]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:LEVITATE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LATIAS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,100,120,110,140,150]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:LEVITATE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:MEGANIUM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,82,140,100,83,140]

},
"type2"=>proc{|pokemon|
   next if pokemon.form==0       # Aria Forme
   next getID(PBTypes,:FAIRY) # Pirouette Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MAGICBOUNCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:FERALIGATR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [85,140,110,103,89,103]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:TOUGHCLAWS) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})





MultipleForms.register(:CROBAT,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [85,135,110,145,70,90]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:BRUTEFORCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})



MultipleForms.register(:STUNFISK,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [109,76,104,57,91,134]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:ATHENIAN) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:TORNADUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,100,80,121,110,90] # Therian Forme
},
"ability"=>proc{|pokemon|
   case pokemon.form
   when 1; next getID(PBAbilities,:REGENERATOR) # Incarnate Forme
   else;   next                                # Therian Forme
   end

   #next if pokemon.form==0                # Incarnate Forme
   #if pokemon.abilityflag && pokemon.abilityflag!=2
   #  next getID(PBAbilities,:REGENERATOR) # Therian Forme
   #end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,3,0,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:THUNDURUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,105,70,101,145,80] # Therian Forme
},
"ability"=>proc{|pokemon|
   case pokemon.form
   when 1; next getID(PBAbilities,:VOLTABSORB) # Incarnate Forme
   else;   next                                # Therian Forme
   end

   #next if pokemon.form==0               # Incarnate Forme
   #if pokemon.abilityflag && pokemon.abilityflag!=2
   #  next getID(PBAbilities,:VOLTABSORB) # Therian Forme
   #end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,0,3,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LANDORUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0    # Incarnate Forme
   next [89,145,90,71,105,80] # Therian Forme
},
"ability"=>proc{|pokemon|
  case pokemon.form
  when 1; next getID(PBAbilities,:INTIMIDATE) # Incarnate Forme
  else;   next                                # Therian Forme
  end
     
   #next if pokemon.form==0               # Incarnate Forme
   #if pokemon.abilityflag && pokemon.abilityflag!=2
   # next getID(PBAbilities,:INTIMIDATE) # Therian Forme
   #end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,3,0,0,0,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:MEOWSTIC,{
#"getForm"=>proc{|pokemon|
#   next pokemon.gender
#   next 0
#},
"ability"=>proc{|pokemon|
   #next if pokemon.gender==0
   if pokemon.gender==1 && pokemon.abilityflag==2 #(pokemon.ability==2 || )
     next getID(PBAbilities,:COMPETITIVE) #if pokemon.ability==2
   else
     
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.gender==0
   movelist=[]
   case pokemon.gender
     #when 0; movelist=[[1,:QUICKGUARD],[1,:MEANLOOK],[1,:HELPINGHAND],
     #                  [1,:SCRATCH],[1,:LEER],[5,:COVET],
     #                  [9,:CONFUSION],[13,:LIGHTSCREEN],[17,:PSYBEAM],
     #                  [19,:FAKEOUT],[22,:DISARMINGVOICE],[25,:PSYSHOCK],
     #                  [28,:CHARM],[31,:MIRACLEEYE],[35,:REFLECT],
     #                  [40,:PSYCHIC],[43,:ROLEPLAY],[45,:IMPRISON],
     #                  [48,:SUCKERPUNCH],[50,:MISTYTERRAIN],[53,:QUICKGUARD]]
     when 1; movelist=[[1,:STOREDPOWER],[1,:MEFIRST],[1,:MAGICALLEAF],
                       [1,:SCRATCH],[1,:LEER],[5,:COVET],
                       [9,:CONFUSION],[13,:LIGHTSCREEN],[17,:PSYBEAM],
                       [19,:FAKEOUT],[22,:DISARMINGVOICE],[25,:PSYSHOCK],
                       [28,:CHARGEBEAM],[31,:SHADOWBALL],[35,:EXTRASENSORY],
                       [40,:PSYCHIC],[43,:ROLEPLAY],[45,:SIGNALBEAM],
                       [48,:SUCKERPUNCH],[50,:FUTURESIGHT],[53,:STOREDPOWER]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

MultipleForms.register(:KYUREM,{
"getBaseStats"=>proc{|pokemon|
   case pokemon.form
     when 1; next [125,120, 90,95,170,100] # White Kyurem
     when 2; next [125,170,100,95,120, 90] # Black Kyurem
     else;   next                          # Kyurem
   end
},
"ability"=>proc{|pokemon|
   case pokemon.form
     when 1; next getID(PBAbilities,:TURBOBLAZE) # White Kyurem
     when 2; next getID(PBAbilities,:TERAVOLT)   # Black Kyurem
     else;   next                                # Kyurem
   end
},
"evYield"=>proc{|pokemon|
   case pokemon.form
     when 1; next [0,0,0,0,3,0] # White Kyurem
     when 2; next [0,3,0,0,0,0] # Black Kyurem
     else;   next               # Kyurem
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
                       [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
                       [36,:SLASH],[43,:FUSIONFLARE],[50,:ICEBURN],
                       [57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
                       [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
     when 2; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
                       [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
                       [36,:SLASH],[43,:FUSIONBOLT],[50,:FREEZESHOCK],
                       [57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
                       [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   #moves=[
   #   :FUSIONFLARE,  # White
   #   :ICEBURN,  # White
   #   :FUSIONBOLT, # Black
   #   :FREEZESHOCK, # Black
   #]
   # moves.each{|move|
   #   pbDeleteMoveByID(pokemon,getID(PBMoves,move))
   #}
   #if pokemon.moves.find_all{|i| i.id!=0}.length==0
   #  pbAutoLearnMove(pokemon,getID(PBMoves,:ICYWIND))
   #end
}
})



MultipleForms.register(:KELDEO,{
"getForm"=>proc{|pokemon|
   next 1 if pbHasMove?(pokemon,:SECRETSWORD) # Resolute Form
   next 0                                     # Ordinary Form
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:MELOETTA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [100,128,90,128,77,77] # Pirouette Forme
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0       # Aria Forme
   next getID(PBTypes,:PSYCHIC) # Pirouette Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Aria Forme
   next [0,0,0,1,1,1]      # Pirouette Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTAMELOETTA,{
"getBaseStats"=>proc{|pokemon|
   next [100,128,90,128,77,77] if pokemon.form==0# Pirouette Forme
   next      # Aria Forme
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0       # Aria Forme
   next getID(PBTypes,:PSYCHIC) # Pirouette Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Aria Forme
   next [0,1,1,1,0,0]      # Pirouette Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:AEGISLASH,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0 # Pirouette Forme
   next [60,150,50,60,150,50] # Pirouette Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:VENUSAUR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,100,123,80,120,122] # Pirouette Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:THICKFAT) # Origin Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:CHARIZARD,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [78,130,111,100,130,85] if pokemon.form==1
   next [78,104,78,100,159,115]

},
"type2"=>proc{|pokemon|
   types=[:FLYING,:DRAGON,:FLYING]
   next getID(PBTypes,types[pokemon.form])
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:TOUGHCLAWS) if pokemon.form==1
      next getID(PBAbilities,:DROUGHT) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:VICTREEBEL,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,150,100,60,110,90] 

},
"type2"=>proc{|pokemon|
   types=[:POISON,:GHOST]
   next getID(PBTypes,types[pokemon.form])
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:ASTRALIZE) if pokemon.form==1
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GARDEVOIR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next if pokemon.form==2
   next [68,85,65,100,165,135]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   if pokemon.form==1 || pokemon.form==3
     getID(PBAbilities,:PIXILATE)
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   next if pokemon.form==1
   movelist=[]
   case pokemon.form
     when 2 ; movelist=[[1,:MOONBLAST],[1,:STOREDPOWER],[1,:MISTYTERRAIN],
                        [1,:HEALINGWISH],[1,:GROWL],[1,:CONFUSION],[1,:DOUBLETEAM],
                        [1,:TELEPORT],[4,:CONFUSION],[6,:DOUBLETEAM],[9,:TELEPORT],
                        [11,:DISARMINGVOICE],[14,:WISH],[17,:MAGICALLEAF],
                        [19,:HEALPULSE],[23,:DRAININGKISS],[26,:CALMMIND],
                        [31,:PSYCHIC],[35,:IMPRISON],[40,:FUTURESIGHT],
                        [44,:CAPTIVATE],[49,:HYPNOSIS],[53,:DREAMEATER],
                        [58,:STOREDPOWER],[62,:MOONBLAST],[100,:FAIRYTEMPEST]]
     when 3 ; movelist=[[1,:MOONBLAST],[1,:STOREDPOWER],[1,:MISTYTERRAIN],
                        [1,:HEALINGWISH],[1,:GROWL],[1,:CONFUSION],[1,:DOUBLETEAM],
                        [1,:TELEPORT],[4,:CONFUSION],[6,:DOUBLETEAM],[9,:TELEPORT],
                        [11,:DISARMINGVOICE],[14,:WISH],[17,:MAGICALLEAF],
                        [19,:HEALPULSE],[23,:DRAININGKISS],[26,:CALMMIND],
                        [31,:PSYCHIC],[35,:IMPRISON],[40,:FUTURESIGHT],
                        [44,:CAPTIVATE],[49,:HYPNOSIS],[53,:DREAMEATER],
                        [58,:STOREDPOWER],[62,:MOONBLAST],[100,:FAIRYTEMPEST]]
   end              
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:MACHAMP,{
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
     when 1 ; movelist=[[1,:WIDEGUARD],[1,:LOWKICK],[1,:LEER],[1,:FOCUSENERGY],
                        [1,:KARATECHOP],[3,:FOCUSENERGY],[7,:KARATECHOP],
                        [9,:FORESIGHT],[13,:LOWSWEEP],[15,:SEISMICTOSS],
                        [19,:REVENGE],[21,:KNOCKOFF],[25,:VITALTHROW],
                        [27,:WAKEUPSLAP],[33,:DUALCHOP],[37,:SUBMISSION],
                        [43,:BULKUP],[47,:CROSSCHOP],[53,:SCARYFACE],
                        [57,:DYNAMICPUNCH],[100,:DYNAMICFURY]]
   end              
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTAGALLADE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [68,165,95,110,65,115]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:VOLTABSORB) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:DELTAGARDEVOIR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [68,85,65,100,165,135]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:LIGHTNINGROD)
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTASCIZOR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,150,140,75,65,100]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:ADAPTABILITY)
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:KINGDRA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [75,95,115,105,135,115]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:SNIPER)
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BLASTOISE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [79,103,120,78,135,115]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MEGALAUNCHER) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ALAKAZAM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [55,50,65,150,175,95]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:TRACE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GENGAR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [60,65,80,130,170,95]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SHADOWTAG) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:PINSIR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [65,155,120,105,65,90]
},
"type2"=>proc{|pokemon|
   types=[:BUG,:FLYING]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:AERILATE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:MAGMORTAR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [75,125,67,113,130,120]
},
"type2"=>proc{|pokemon|
   types=[:FIRE,:PSYCHIC]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:LEVITATE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:AERODACTYL,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,135,85,150,70,95,]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:TOUGHCLAWS) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:STEELIX,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [75,135,225,55,65,55] if pokemon.form==1
   next [75,125,230,30,55,95] 

},
"type2"=>proc{|pokemon|
   types=[:GROUND,:FIRE,:GROUND]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:FOUNDRY) if pokemon.form==1 # Origin Forme
      next getID(PBAbilities,:SANDFORCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)

}})

MultipleForms.register(:CACTURNE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   #next [70,115,60,55,115,60]
   next [70,155,69,80,135,66]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SANDRUSH) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DONPHAN,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [90,150,150,50,60,100]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:IRRELEPHANT) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})



MultipleForms.register(:MAGCARGO,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [50,70,100,50,150,100] #if pokemon.form==1

},
"type2"=>proc{|pokemon|
   types=[:ROCK,:FIRE]
   next getID(PBTypes,types[pokemon.form])
},
"ability"=>proc{|pokemon|
   next if pokemon.form<1       # Altered Forme
      next getID(PBAbilities,:VAPORIZATION) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})





MultipleForms.register(:SLOWBRO,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [95,75,180,30,130,80]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SHELLARMOR) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:CRAWDAUNT,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [63,145,95,80,100,85]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:ADAPTABILITY) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:CRYOGONAL,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,50,65,135,115,150]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SLEET) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:FROSLASS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,80,85,120,120,105]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:FURCOAT) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTAFROSLASS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,80,85,120,120,105]

},
"type2"=>proc{|pokemon|
   types=[:FIRE,:GHOST]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MAGICGUARD) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SUNFLORA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [75,85,80,45,135,105] # Z mega
 #  next [75,75,95,50,105,125] # O mega

},
"type2"=>proc{|pokemon|
   types=[:GRASS,:FIRE,:GRASS,:FIRE,:GRASS]
   next getID(PBTypes,types[pokemon.form])
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:UNLEAFED) # z mega
#      next getID(PBAbilities,:ATHENIAN) # o mega

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:DELTASUNFLORA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [75,85,80,45,135,105] # Z mega
 #  next [75,75,95,50,105,125] # O mega

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:CHLOROFURY) # z mega
#      next getID(PBAbilities,:ATHENIAN) # o mega

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:CHATOT,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [76,65,50,114,142,64] # Z mega
 #  next [75,75,95,50,105,125] # O mega

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:AMPLIFIER) # z mega
#      next getID(PBAbilities,:ATHENIAN) # o mega

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GIRAFARIG,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,80,95,85,130,95] # Z mega

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SPECTRALJAWS) # z mega

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:DELTAGIRAFARIG,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,80,95,85,130,95] # Z mega

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:INTIMIDATE) # z mega

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:AGGRON,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,140,230,50,60,80]

},
"type2"=>proc{|pokemon|
   types=[:ROCK,:STEEL]
   next getID(PBTypes,types[pokemon.form])
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:FILTER) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:SHIFTRY,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [90,135,70,100,125,60]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SHADOWDANCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})




MultipleForms.register(:BISHARP,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
 #  next [65,165,100,130,70,60]
   next [65,145,130,105,60,85]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MOXIE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:DELTAVENUSAUR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,100,123,80,122,120]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:HUBRIS) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTACHARIZARD,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [78,104,78,100,159,119]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:NOCTEM) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTABLASTOISE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [79,103,120,78,135,115]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MEGALAUNCHER) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTABISHARP,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [65,145,130,105,60,85]
   
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:TECHNICIAN) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GOLURK,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [89,224,80,85,55,80]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SHEERFORCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:ZOROARK,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [60,130,60,125,145,90]

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:TRACE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})




MultipleForms.register(:REUNICLUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [110,85,65,80,160,90]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SPEEDSWAP) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:TYRANITAR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [100,164,150,71,95,120] if pokemon.form==1
   next [100,134,143,61,95,130]   if pokemon.form==2

},
"getForm"=>proc{|pokemon|
   next 1  if pokemon.isMegaTyranitar? && !isConst?(pokemon.item,PBItems,:TYRANITARMACHINE)
   next 2  if isConst?(pokemon.item,PBItems,:TYRANITARMACHINE)
   next 0
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next if pokemon.form==2
   next getID(PBAbilities,:SANDSTREAM)# if pokemon.form==1 # Origin Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:ZEKROM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [100,150,156,90,120,130] #if pokemon.form==1

},
"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:ZEKROMMACHINE)
   next 0
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTAVOLCARONA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   #next [75,103,80,92,70,70] #if pokemon.form==1
   next [85,60,85,100,135,137] #if pokemon.form==1

},
"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:DVOLCARONAARMOR)
   next 0
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LEAVANNY,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [75,103,104,92,70,104] #if pokemon.form==1

},
"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:LEAVANNYMACHINE)
   next 0
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:FLYGON,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,100,104,100,80,104] if pokemon.form==1 #if pokemon.form==1
   next [80,110,90,120,140,80] #if pokemon.form==1

},
"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:FLYGONMACHINE)
   next 2  if pokemon.isMegaFlygon? && !isConst?(pokemon.item,PBItems,:FLYGONMACHINE)
   next 0
},
"ability"=>proc{|pokemon|
   next if pokemon.form<2        # Altered Forme
   next getID(PBAbilities,:AMPLIFIER) # Origin Forme
},
"type1"=>proc{|pokemon|
   types=[:GROUND,:GROUND,:BUG]
   next getID(PBTypes,types[pokemon.form])
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DUGTRIO,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [35,180,50,120,50,70]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:DRYSKIN) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})



MultipleForms.register(:AMPHAROS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [90,95,105,45,165,110]

},
"type2"=>proc{|pokemon|
   types=[:ELECTRIC,:DRAGON]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MOLDBREAKER) # Origin Forme

},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}

})

MultipleForms.register(:ZEBSTRIKA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [75,100,63,141,135,83]

},
"type2"=>proc{|pokemon|
   types=[:ELECTRIC,:FAIRY]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:COMPETITIVE) # Origin Forme

},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}

})
MultipleForms.register(:MAROWAK,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [60,135,120,65,50,95]

},
"type2"=>proc{|pokemon|
   types=[:GROUND,:GHOST]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:PARENTALBOND) # Origin Forme

},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})





MultipleForms.register(:MILOTIC,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # normal
   next [95,70,109,81,130,155]

},
"type2"=>proc{|pokemon|
   types=[:WATER,:FAIRY]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:DIAMONDSKIN) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTAMILOTIC,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # normal
   next [95,70,109,81,130,155]

},
"type2"=>proc{|pokemon|
   types=[:GHOST]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:ABSOLUTION) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SCIZOR,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,150,140,75,65,100]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:TECHNICIAN) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:HERACROSS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,185,115,75,40,105]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SKILLLINK) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
MultipleForms.register(:BLAZIKEN,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,160,80,100,130,80]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SPEEDBOOST) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})
  MultipleForms.register(:SCEPTILE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,110,75,145,145,85]

},
"type2"=>proc{|pokemon|
   types=[:GRASS,:DRAGON]
   next getID(PBTypes,types[pokemon.form])
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:LIGHTNINGROD) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

  MultipleForms.register(:DELTASCEPTILE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,110,75,145,145,85]

},
"type2"=>proc{|pokemon|
   types=[:FIGHTING,:DRAGON]
   next getID(PBTypes,types[pokemon.form])
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:TECHNICIAN) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:SWAMPERT,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [100,150,110,70,95,110]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SWIFTSWIM) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SABLEYE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [50,85,125,20,85,115]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MAGICBOUNCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:DELTASABLEYE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [50,85,125,20,85,115]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:DRYSKIN) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SHARPEDO,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,140,70,105,110,65]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:STRONGJAW) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:CAMERUPT,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,120,110,20,145,105]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SHEERFORCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTACAMERUPT,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,120,110,20,145,105]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:VENOMOUS) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:ALTARIA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [75,110,110,80,110,105]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:PIXILATE) # Origin Forme

},
"type2"=>proc{|pokemon|
   types=[:FLYING,:FAIRY]
   next getID(PBTypes,types[pokemon.form])
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ABOMASNOW,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [90,132,105,30,132,105]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SNOWWARNING) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GLALIE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,120,80,100,120,80]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:REFRIGERATE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTAGLALIE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,120,80,100,120,80]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:RECKLESS) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:HAXORUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [76,182,130,82,80,90]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:WEAKARMOR) # Origin Forme

},
"type2"=>proc{|pokemon|
   types=[:DRAGON,:STEEL]
   next getID(PBTypes,types[pokemon.form])
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:CHATOT,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [76,65,55,116,147,52]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:AMPLIFIER) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SALAMENCE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [95,145,130,120,120,90]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:AERILATE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:METAGROSS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,145,150,110,105,110]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:TOUGHCLAWS) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTAMETAGROSS1,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,145,150,110,105,110]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MOLDBREAKER) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTAMETAGROSS2,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [80,145,150,110,105,110] if pokemon.form==1
   next [80,180,100,100,120,100] 
   #old stats: next [80,170,125,110,105,110] 

},
"type2"=>proc{|pokemon|
   types=[:ROCK,:ROCK,:CRYSTAL]
   next getID(PBTypes,types[pokemon.form])
},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:ROCKHEAD) if pokemon.form==1 # Origin Forme
      next getID(PBAbilities,:WEAKARMOR) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SUDOWOODO,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,140,145,20,40,95]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:ANALYTIC) # Origin Forme

},

"type2"=>proc{|pokemon|
   types=[:ROCK,:GRASS]
   next getID(PBTypes,types[pokemon.form])
},


"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ABOMASNOW,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [90,132,105,30,132,105]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SNOWWARNING) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GYARADOS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [95,155,109,81,70,130]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MOLDBREAKER) # Origin Forme

},
"type2"=>proc{|pokemon|
   types=[:FLYING,:DARK]
   next getID(PBTypes,types[pokemon.form])
},

"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})



MultipleForms.register(:HOUNDOOM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [75,90,90,115,140,90]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SOLARPOWER) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:MEDICHAM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [60,100,85,100,80,85]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:PUREPOWER) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:DELTAMEDICHAM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [60,100,85,100,80,85]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:ATHENIAN) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:MANECTRIC,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,75,80,135,135,80]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:INTIMIDATE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:KANGASKHAN,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [105,125,100,100,60,100]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:PARENTALBOND) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:MAWILE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [50,105,125,50,55,95]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:HUGEPOWER) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTAMAWILE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [50,105,125,50,55,95]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:ARENATRAP) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:BANETTE,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [64,165,75,75,93,83]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:PRANKSTER) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ABSOL,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [65,150,60,115,115,60]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:MAGICBOUNCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GARCHOMP,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [108,170,115,92,120,95]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:SANDFORCE) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LUCARIO,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next if pokemon.form==2
   next [70,145,88,112,140,70]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0    
   if pokemon.form==1 || pokemon.form==3           # Altered Forme
      next getID(PBAbilities,:ADAPTABILITY) # Origin Forme
   end

},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   next if pokemon.form==1
   movelist=[]
   case pokemon.form
     when 2 ; movelist=[[1,:EXTREMESPEED],[1,:DRAGONPULSE],[1,:CLOSECOMBAT],
                        [1,:AURASPHERE],[1,:FORESIGHT],[1,:QUICKATTACK],
                        [1,:DETECT],[1,:METALCLAW],[6,:COUNTER],[11,:FEINT],
                        [15,:POWERUPPUNCH],[19,:SWORDSDANCE],[24,:METALSOUND],
                        [29,:BONERUSH],[33,:QUICKGUARD],[37,:MEFIRST],
                        [42,:AURASPHERE],[47,:CALMMIND],[51,:HEALPULSE],
                        [55,:CLOSECOMBAT],[60,:DRAGONPULSE],[65,:EXTREMESPEED],
                        [100,:AURABLAST]]
     when 3 ; movelist=[[1,:EXTREMESPEED],[1,:DRAGONPULSE],[1,:CLOSECOMBAT],
                        [1,:AURASPHERE],[1,:FORESIGHT],[1,:QUICKATTACK],
                        [1,:DETECT],[1,:METALCLAW],[6,:COUNTER],[11,:FEINT],
                        [15,:POWERUPPUNCH],[19,:SWORDSDANCE],[24,:METALSOUND],
                        [29,:BONERUSH],[33,:QUICKGUARD],[37,:MEFIRST],
                        [42,:AURASPHERE],[47,:CALMMIND],[51,:HEALPULSE],
                        [55,:CLOSECOMBAT],[60,:DRAGONPULSE],[65,:EXTREMESPEED],
                        [100,:AURABLAST]]
   end              
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DELTALUCARIO,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [70,145,88,112,140,70]

},
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:DEFIANT) # Origin Forme

},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:EEVEE,{
"getBaseStats"=>proc{|pokemon| 
    # 130 -> 180 (50)
    # 110 -> 125 (15)
    # 95 -> 110 (15)
    # 65 -> 75 (10)
    # 65 -> 70 (5)
    # 60 -> 65 (5)
   next if pokemon.form==0     # Aria Forme
   next [87,87,87,87,87,87] if pokemon.form==1 # Mega Base
   next [130,65,60,65,110,95] if pokemon.form==2 # Vaporeon
   next [65,65,60,130,110,95] if pokemon.form==3 # Jolteon
   next [65,130,60,65,95,110] if pokemon.form==4 # Flareon
   next [65,65,60,110,130,95] if pokemon.form==5 # Espeon
   next [95,65,110,65,60,130] if pokemon.form==6 # Umbreon
   next [65,110,130,95,60,65] if pokemon.form==7 # Leafeon
   next [65,60,110,65,130,95] if pokemon.form==8 # Glaceon
   next [95,65,65,60,110,130] if pokemon.form==9 # Sylveon

},

"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:PROTEANMAXIMA) if pokemon.form==1 # Mega Base
      next getID(PBAbilities,:WATERABSORB) if pokemon.form==2 # Mega Base
      next getID(PBAbilities,:VOLTABSORB) if pokemon.form==3 # Mega Base
      next getID(PBAbilities,:FLASHFIRE) if pokemon.form==4 # Mega Base
      next getID(PBAbilities,:MAGICBOUNCE) if pokemon.form==5 # Mega Base
      next getID(PBAbilities,:SYNCHRONIZE) if pokemon.form==6 # Mega Base
      next getID(PBAbilities,:CHLOROPHYLL) if pokemon.form==7 # Mega Base
      next getID(PBAbilities,:ICEBODY) if pokemon.form==8 # Mega Base
      next getID(PBAbilities,:CUTECHARM) if pokemon.form==9 # Mega Base

},
"type1"=>proc{|pokemon|
   types=[:NORMAL,:NORMAL,:WATER,:ELECTRIC,:FIRE,:PSYCHIC,:DARK,:GRASS,:ICE,:FAIRY]
   next getID(PBTypes,types[pokemon.form])
},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:NORMAL,:WATER,:ELECTRIC,:FIRE,:PSYCHIC,:DARK,:GRASS,:ICE,:FAIRY]
   next getID(PBTypes,types[pokemon.form])
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})


MultipleForms.register(:GENESECT,{
"getForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SHOCKDRIVE)
   next 2 if isConst?(pokemon.item,PBItems,:BURNDRIVE)
   next 3 if isConst?(pokemon.item,PBItems,:CHILLDRIVE)
   next 4 if isConst?(pokemon.item,PBItems,:DOUSEDRIVE)
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})