# This class stores data on each Pokemon.  Refer to $Trainer.party for an array
# of each Pokemon in the Trainer's current party.
class PokeBattle_Pokemon
  

  attr_reader(:totalhp)       # Current Total HP
  attr_reader(:attack)        # Current Attack stat
  attr_reader(:defense)       # Current Defense stat
  attr_reader(:speed)         # Current Speed stat
  attr_reader(:spatk)         # Current Special Attack stat
  attr_reader(:spdef)         # Current Special Defense stat
  attr_accessor(:iv)          # Array of 6 Individual Values for HP, Atk, Def,
                              #    Speed, Sp Atk, and Sp Def
  attr_accessor(:ev)          # Effort Values
  attr_accessor(:species)     # Species (National Pokedex number)
  attr_accessor(:personalID)  # Personal ID
  attr_accessor(:trainerID)   # 32-bit Trainer ID (the secret ID is in the upper
                              #    16 bits)
  attr_accessor(:hp)          # Current HP
  attr_accessor(:pokerus)     # Three states: Not infected, infected, cured
  attr_accessor(:pokerusTime) # Time infected by Pokerus
  attr_accessor(:item)        # Held item
  attr_accessor(:mail)        # Mail
  attr_accessor(:name)        # Nickname
  attr_accessor(:exp)         # Current experience points
  attr_accessor(:happiness)   # Current happiness
  attr_accessor(:status)      # Status problem (PBStatuses) 
  attr_accessor(:statusCount) # Sleep count/Toxic flag
  attr_accessor(:eggsteps)    # Steps to hatch egg, 0 if Pokémon is not an egg
  attr_accessor(:moves)       # Moves (PBMove)
  attr_accessor(:ballused)    # Ball used
  attr_accessor(:markings)    # Markings
  attr_accessor(:obtainMode)  # Manner obtained: 1 - egg, 4 - fateful encounter
  attr_accessor(:obtainMap)   # Map where obtained
  attr_accessor(:obtainLevel) # Level obtained
  attr_accessor(:language)    # Language
  attr_accessor(:ot)          # Original Trainer's name 
  attr_accessor(:otgender)    # Original Trainer's gender:
                              #    0 - male, 1 - female, 2 - mixed, 3 - unknown
                              #    For information only, not used to verify
                              #    ownership of the Pokemon
  attr_accessor(:abilityflag) # Forces the first (0) or second (1) ability
  attr_accessor(:ballcapsule0) #fire
  attr_accessor(:ballcapsule1) # hearts
  attr_accessor(:ballcapsule2) # ele
  attr_accessor(:ballcapsule3) # QUES
  attr_accessor(:ballcapsule4) # star
  attr_accessor(:ballcapsule5)
  attr_accessor(:ballcapsule6)
  attr_accessor(:ballcapsule7)
  attr_accessor(:eggswitchlvl)
  attr_accessor(:eggmovesarray)
  attr_accessor(:ribbonsAllowed)

  attr_accessor :cool,:beauty,:cute,:smart,:tough,:sheen # Contest stats
# Time object specifying the time egg hatched.
  def timeEggHatched
    if obtainMode==1
      return @timeEggHatched ? Time.at(@timeEggHatched) : Time.gm(2000)
    else
      return Time.gm(2000)
    end
  end

# Sets a Time object specifying the time egg hatched.
  def timeEggHatched=(value)
    # Seconds since Unix epoch
    if value.is_a?(Time)
      @timeEggHatched=value.to_i
    else
      @timeEggHatched=value
    end
  end

# Sets a Time object specifying the time the Pokemon was received.
  def timeReceived=(value)
    # Seconds since Unix epoch
    if value.is_a?(Time)
      @timeReceived=value.to_i
    else
      @timeReceived=value
    end
  end

#Time object specifying the time the Pokemon was received.
  def timeReceived
    return @timeReceived ? Time.at(@timeReceived) : Time.gm(2000)
  end

# Pokemon Contest attribute
  def cool; @cool ? @cool : 0; end
  def beauty; @beauty ? @beauty : 0; end
  def cute; @cute ? @cute : 0; end
  def smart; @smart ? @smart : 0; end
  def tough; @tough ? @tough : 0; end
  def sheen; @sheen ? @sheen : 0; end

  def language; @language ? @language : 0; end

# Number of ribbons this Pokemon has
  def ribbonCount
    count=0
    for i in 0..self.maxRibbon
      count+=1 if getRibbon(i)
    end
    return count
  end

# Maximum ribbon, for iterating through a Pokemon's ribbons
  def maxRibbon
    return @ribbons ? @ribbons.length*32-1 : 31
  end

# Specifies whether the Pokemon has the ribbon of the specified number
  def getRibbon(ribbon)
    return false if !@ribbons || !@ribbons[ribbon>>5]
    return ((@ribbons[ribbon>>5]) & (1<<(ribbon&31)))!=0
  end

# Sets whether the Pokemon has the ribbon of the specified number
  def setRibbon(ribbon, value=true)
    @ribbons=[] if !@ribbons
    @ribbons[ribbon>>5]=0 if !@ribbons[ribbon>>5]
    if value
      (@ribbons[ribbon>>5] |= (1<<(ribbon&31)))
    else
      (@ribbons[ribbon>>5] &=~ (1<<(ribbon&31)))
    end
  end

# Clears the ribbon of the specified number
  def clearRibbon(ribbon)
    setRibbon(ribbon,false)
  end

  def jsonarr
    return [method(:level), method(:nature), method(:isShiny?), method(:gender), 
           method(:ability), method(:abilityIndex)]
  end
  
  
# Clears all ribbons of this Pokemon
  def clearAllRibbons
    @ribbons=[]
  end

# Determines whether the Pokemon has the specified type.
# Type is either a number or the internal name of the type.
  def hasType?(type)
    if type.is_a?(String) || type.is_a?(Symbol)
      return isConst?(self.type1,PBTypes,type)||isConst?(self.type2,PBTypes,type)
    else
      return self.type1==type || self.type2==type
    end
  end

# Gets this Pokemon's mail.
  def mail
    return nil if !@mail
    if @mail.item==0 || self.item==0 || @mail.item!=self.item
      @mail=nil
      return nil
    end
    return @mail
  end

  def obtainLevel
    @obtainLevel=0 if !@obtainLevel
    return @obtainLevel
  end

  def otgender
    @otgender=3 if !@otgender
    return @otgender
  end

  def markings
    @markings=0 if !@markings
    @markings=0 if @markings=="nil"
    return @markings
  end

  def nature
    return @personalID%25
  end

# Gets a string stating the Unown form of this Pokemon.
  def unownShape
    d=@personalID&3
    d|=((@personalID>>8)&3)<<2
    d|=((@personalID>>16)&3)<<4
    d|=((@personalID>>24)&3)<<6
    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?"[d%28,1]
  end

  def abilityflag
    return @abilityflag if @abilityflag
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,29)
    ret1=dexdata.fgetb
    ret2=dexdata.fgetb
    dexdata.close
    if ret1==ret2 || ret2==0
      return 0
    end
    return (@personalID&1)
  end

# Gets the ID of this Pokemon's ability
  def ability
    abil=@abilityflag ? @abilityflag : (@personalID&1)
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,29)
    ret1=dexdata.fgetb
    ret2=dexdata.fgetb
    pbDexDataOffset(dexdata,@species,37)
    ret3=dexdata.fgetb
    dexdata.close
    ret=ret1
    if abil==2
      if ret3>0
        return ret3
      else
        abil=(@personalID&1)
      end
    end
    if abil==1
      ret=ret2
      if ret2==0
        ret=ret1
      end
    end
    return ret
  end

  def self.isFemale(b,genderRate)
    return (b<=30) if genderRate==0x1F # FemaleOneEighth
    return (b<=63) if genderRate==0x3F # Female25Percent
    return (b<=126) if genderRate==0x7F # Female50Percent
    return (b<=190) if genderRate==0xBF # Female75Percent
    return true if genderRate==0xFE
    return false if genderRate==0 || genderRate==0xFF
    return (b<genderRate)
  end

# Gets this Pokemon's gender. 0=male, 1=female, 2=genderless
  def gender
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,18)
    genderbyte=dexdata.fgetb
    dexdata.close
    case genderbyte
      when 255
        return 2 # genderless
      when 254
        return 1 # always female
      else
        lowbyte=@personalID&0xFF
        return PokeBattle_Pokemon.isFemale(lowbyte,genderbyte) ? 1 : 0
    end
  end

  def setGenderAndNature(female,nature)
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,18)
    genderbyte=dexdata.fgetb
    dexdata.close
    case genderbyte
      when 255
        setNature(nature)
        return false # genderless
      when 254
        setNature(nature)
        return female # always female
      when 0
        setNature(nature)
        return !female # always male
      else
        lowbyte=@personalID&0xFF
        if PokeBattle_Pokemon.isFemale(lowbyte,genderbyte)==female && self.nature==nature
          return true
        end
        loop do
          value=rand(256)
          if female==PokeBattle_Pokemon.isFemale(value,genderbyte)
            @personalID&=~0xFF
            @personalID|=value
            done=false
            if female
              while (@personalID&0xFF)>0
                if self.nature==nature
                  done=true; break
                end
                @personalID-=1
              end
            else
              while (@personalID&0xFF)<0xFF
                if self.nature==nature
                  done=true; break
                end
                @personalID+=1
              end     
            end
            if done
              calcStats
              return true
            else
              @personalID=rand(256)<<8
              @personalID|=rand(256)<<16
              @personalID|=rand(256)<<24
            end
          end
        end
    end
  end

  def setNature(nature)
    changed=false
    while self.nature!=nature
      @personalID=rand(256)
      @personalID|=rand(256)<<8
      @personalID|=rand(256)<<16
      @personalID|=rand(256)<<24
      changed=true
    end
    self.calcStats if changed
  end

  def setGender(female)
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,18)
    genderbyte=dexdata.fgetb
    dexdata.close
    case genderbyte
      when 255
        return false # genderless
      when 254
        return female # always female
      when 0
        return !female # always male
      else
        lowbyte=@personalID&0xFF
        return true if PokeBattle_Pokemon.isFemale(lowbyte,genderbyte)==female
        loop do
          value=rand(256)
          if female==PokeBattle_Pokemon.isFemale(value,genderbyte)
            @personalID&=~0xFF
            @personalID|=value
            calcStats
            return true
          end
        end
    end
  end
  # returns the capsules used
  def ballcapsule0
    return @ballcapsule0
  end
  def ballcapsule1
    return @ballcapsule1
  end
  def ballcapsule2
    return @ballcapsule2
  end
  def ballcapsule3
    return @ballcapsule3
  end
  def ballcapsule4
    return @ballcapsule4
  end
  def ballcapsule5
    return @ballcapsule5
  end
  def ballcapsule6
    return @ballcapsule6
  end
  def ballcapsule7
    return @ballcapsule7
  end
  def eggswitchlvl
    return @eggswitchlvl
  end
  def eggmovesarray
    return @eggmovesarray
  end
  
# Sets this Pokemon's level by changing its Exp. Points.
  def level=(value)
    if value<1 || value>PBExperience::MAXLEVEL
      raise ArgumentError.new(_INTL("The level number ({1}) is invalid.",value))
    end
    self.exp=PBExperience.pbGetStartExperience(value,self.growthrate) 
  end
  
def ConvertToString
  ivnum=0
  for i in 0...6
    ivnum+=@iv[i]<<i*5
  end
  movearray=[]
  for i in 0...4
    movearray.push(@moves[i].id)
  end
  movearray.push(@moves[0].ppup|(@moves[1].ppup<<2)|(@moves[2].ppup<<4)|(@moves[3].ppup<<6))
  array=[ivnum,@species,@personalID,@trainerID,@pokerus,@pokerusTime.to_i,
    @item,@ot.unpack("C7"),@name.unpack("C10"),@exp,@happiness,@eggsteps,
    movearray,@ballused,@form,@ballcapsule0,@ballcapsule1,@ballcapsule2,@ballcapsule3,@ballcapsule4,@ballcapsule5,@ballcapsule6,@ballcapsule7]
  array.flatten!
  return array.pack("VCVVvVCv7v10VCvv4vvv6C3")
end
  
def iv(i)
    return @iv[i]
  end
def ev(i)
  return @ev[i]
  end

  
  
def self.ConvertFromString(string)
  array=string.unpack("VCVVvVCv7v10VCvv4vvv6C3")
  pkmn=self.new(1,1)
  for i in 0...6
    pkmn.iv[i]=(array[0]>>(i*5))&0x1F
  end
  pkmn.species=array[1]
  pkmn.personalID=array[2]
  pkmn.trainerID=array[3]
  pkmn.pokerus=array[4]
  pkmn.pokerusTime=Time.at(array[5])
  pkmn.item=array[6]
  pkmn.ot=array[7,7].pack("C7").gsub("\000","")
  pkmn.name=array[14,10].pack("C10").gsub("\000","")
  pkmn.exp=array[24]
  pkmn.happiness=array[25]
  pkmn.eggsteps=array[26]
  for i in 0...4
    pbAutoLearnMove(pkmn,array[27+i])
    pkmn.moves[i].ppup=(array[31]>>(i*2))&0x03
  end
  pkmn.ballused=array[32]
  pkmn.form=array[33]
  pkmn.ballcapsule0=array[34]
  pkmn.ballcapsule1=array[35]
  pkmn.ballcapsule2=array[36]
  pkmn.ballcapsule3=array[37]
  pkmn.ballcapsule4=array[38]
  pkmn.ballcapsule5=array[39]
  pkmn.ballcapsule6=array[40]
  pkmn.ballcapsule7=array[41]

  pkmn.calcStats
  return pkmn
end

# Gets this Pokemon's level.
  def level
    return PBExperience.pbGetLevelFromExperience(@exp,self.growthrate)
  end

# Returns whether this Pokemon is an egg.
  def egg?
    return @eggsteps>0
  end

# Gets whether the specified Trainer is not this Pokemon's original trainer.
  def isForeign?(trainer)
    return @trainerID!=trainer.id || @ot!=trainer.name
  end
  
# Gets whether this Pokemon is a Delta Species
  def isDelta?
    deltaArray=Kernel.getAllDeltas
    return deltaArray.include?(@species)
  end
  
# Gets whether this Pokemon is a Mega Evolution
  def isMega?
    if @species==PBSpecies::EEVEE && @form>0
      return true
    end
    case @form
    when 0
      return false
    when 1
      if Kernel.pbGetMegaSpeciesList.include?(@species) && @species != PBSpecies::MEWTWO && 
         @species != PBSpecies::FLYGON
        return true
      elsif @species==PBSpecies::KYOGRE || @species==PBSpecies::GROUDON || @species==PBSpecies::REGIGIGAS
        return true
      end
    when 2
      if @species==PBSpecies::FLYGON || @species==PBSpecies::GIRATINA || @species==PBSpecies::MEWTWO || 
         @species==PBSpecies::SUNFLORA || @species==PBSpecies::DELTATYPHLOSION || 
         @species==PBSpecies::CHARIZARD || @species==PBSpecies::STEELIX || @species==PBSpecies::HYDREIGON
        return true
      end
    when 3
      if @species==PBSpecies::GARDEVOIR || @species==PBSpecies::LUCARIO || @species==PBSpecies::MEWTWO ||
         @species==PBSpecies::SUNFLORA || @species==PBSpecies::HYDREIGON
        return true
      end
    when 4
      if @species==PBSpecies::SUNFLORA || @species==PBSpecies::HYDREIGON
        return true
      end
    when 5
      if @species==PBSpecies::MEWTWO || @species==PBSpecies::HYDREIGON
        return true
      end
    when 19
      if @species==PBSpecies::ARCEUS
        return true
      end
    else
      return false
    end
    return false
  end
  
# Gets whether this Pokemon is wearing Armor
  def isArmored?
    case @form
    when 0
      return false
    when 1
      if @species==PBSpecies::FLYGON || @species==PBSpecies::LEAVANNY || @species==PBSpecies::ZEKROM || 
         @species==PBSpecies::DELTAVOLCARONA || @species==PBSpecies::MEWTWO
        return true
      end
    when 2
      if @species==PBSpecies::TYRANITAR
        return true
      end
    else
      return false
    end
    return false
  end

# Gets whether this Pokemon is shiny (different colored).
  def isShiny?
    a=@personalID^@trainerID
    b=a&0xFFFF
    c=(a>>16)&0xFFFF
    d=b^c
    return (d<SHINYPOKEMONCHANCE)
  end

# Makes this Pokemon shiny.
  def makeShiny
    if !isShiny?
      rnd=rand(65536)
      rnd|=(rnd<<16)
      rnd&=0xFFFFFFF8
      rnd|=rand(8)
      self.personalID=rnd^@trainerID
      calcStats
    end
  end
  
  def makeNotShiny #mod
    while isShiny?
      rnd=rand(65536)
      rnd|=(rnd<<15)
      rnd&=0xFFFFFFF8
      rnd|=rand(8)
      self.personalID=rnd^@trainerID
      calcStats
    end
  end

  def calcHP(base,level,iv,ev) # :nodoc:
    return 1 if base==1
    return ((base*2+iv+(ev>>2))*level/100).floor+level+10
  end

  def calcStat(base,level,iv,ev,pv)# :nodoc:
    return ((((base*2+iv+(ev>>2))*level/100).floor+5)*pv/100).floor
  end

# Returns this Pokemon's growth rate.
  def growthrate
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,20)
    ret=dexdata.fgetb
    dexdata.close
    return ret
  end

# Returns the list of moves this Pokémon can learn by levelling up.
  def getMoveList
    movelist=[]
    atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
    offset=atkdata.getOffset(@species-1)
    length=atkdata.getLength(@species-1)>>1
    atkdata.pos=offset
    for k in 0..length-1
      level=atkdata.fgetw
      move=atkdata.fgetw
      movelist.push([level,move])
    end
    atkdata.close
    return movelist
  end                                                        

# Returns this Pokemon's first type.
  def type1
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,8)
    ret=dexdata.fgetb
    dexdata.close
    return ret
  end

# Returns this Pokemon's second type.
  def type2
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,9)
    ret=dexdata.fgetb
    dexdata.close
    return ret
  end

# Heals all HP, PP, and status problems of this Pokemon.
  def heal
    return if egg?
    @hp=@totalhp
    @status=0
    @statusCount=0
    for i in 0..3
      @moves[i].pp=@moves[i].totalpp if !$game_switches[345]
    end 
  end

# Gets the public portion of the trainer ID.
  def publicID
    return @trainerID&0xFFFF
  end

# Sets this Pokemon's HP.
  def hp=(value)
    value=0 if value<0
    @hp=value
    if @hp==0
      @status=0
      @statusCount=0
    end
  end

# Gets this Pokemon's base stats. An array of six values
# for HP, Attack, Defense, Speed, Sp. Atk, and Sp. Def.
  def baseStats
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,10)
    ret=[
       dexdata.fgetb, # HP
       dexdata.fgetb, # Attack
       dexdata.fgetb, # Defense
       dexdata.fgetb, # Speed
       dexdata.fgetb, # Special Attack
       dexdata.fgetb  # Special Defense
    ]
    dexdata.close
    return ret
  end

# Recalculates this Pokemon's stats.
  def calcStats
    nature=self.nature
    stats=[]
    pvalues=[100,100,100,100,100]
    nd5=(nature/5).floor
    nm5=(nature%5).floor
    if nd5!=nm5
      pvalues[nd5]=110
      pvalues[nm5]=90
    end
    level=self.level
    bs=self.baseStats
    for i in 0..5
      base=bs[i]
      if i==0
        stats[i]=calcHP(base,level,@iv[i],@ev[i])
      else
        stats[i]=calcStat(base,level,@iv[i],@ev[i],pvalues[i-1])
      end
    end
    diff=@totalhp-@hp
    @totalhp=stats[0]
    if @hp>0
      @hp=@totalhp-diff
      @hp=1 if @hp<=0
      @hp=@totalhp if @hp>@totalhp
    end
    @attack=stats[1]
    @defense=stats[2]
    @speed=stats[3]
    @spatk=stats[4]
    @spdef=stats[5]
  end

  def totalhp=(value)
    @totalhp=value
    @hp=value
  end
  def attack=(value)
    @attack=value
  end
  def defense=(value)
    @defense=value
  end
  def speed=(value)
    @speed=value
  end
  def spatk=(value)
    @spatk=value
  end
  def spdef=(value)
    @spdef=value
  end
  
  
# Creates a new Pokemon object.
#  species - Pokemon species. level - Pokemon level.
#  player - PokeBattle_Trainer object for the original trainer.
#  withMoves - if false, this Pokemon has no moves.
  def initialize(species,level,player=nil,withMoves=true)
    @ev=[0,0,0,0,0,0]
    if species<1||species>PBSpecies.maxValue
      raise ArgumentError.new(_INTL("The species number (no. {1} of {2}) is invalid.",
         species,PBSpecies.maxValue))
      return nil
    end
    @timeReceived=Time.now.getgm.to_i # Use GMT
    @species=species
    # Individual Values
    @hp=1
    @totalhp=1
    @iv=[]
    @iv[0]=rand(32)
    @iv[1]=rand(32)
    @iv[2]=rand(32)
    @iv[3]=rand(32)
    @iv[4]=rand(32)
    @iv[5]=rand(32)
    @personalID=rand(256)
    @personalID|=rand(256)<<8
    @personalID|=rand(256)<<16
    @personalID|=rand(256)<<24
    if player
      @trainerID=player.id
      @ot=player.name
      @otgender=player.gender
      @language=player.language
    else
      @trainerID=0
      @ot=""
      @otgender=3
    end
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,19)
    @happiness=dexdata.fgetb
    pbDexDataOffset(dexdata,@species,29)
    ability1=dexdata.fgetb
    ability2=dexdata.fgetb
    dexdata.close
    @name=PBSpecies.getName(@species)
    @eggsteps=0
    @status=0
    @statusCount=0
    @item=0
    @mail=nil
    @moves=[]
    @ballused=0
    @ballcapsule0=false
    @ballcapsule1=false
    @ballcapsule2=false
    @ballcapsule3=false
    @ballcapsule4=false
    @ballcapsule5=false
    @ballcapsule6=false
    @ballcapsule7=false
    self.level=level
    calcStats
    @hp=@totalhp
    if $game_map
      @obtainMode=0 # met
      @obtainMap=$game_map.map_id
      @obtainLevel=level
    else
      @obtainMode=0
      @obtainMap=0
      @obtainLevel=level
    end
    if withMoves
      atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
      offset=atkdata.getOffset(species-1)
      length=atkdata.getLength(species-1)>>1
      atkdata.pos=offset
      # Generating move list
      movelist=[]
      for i in 0..length-1
        alevel=atkdata.fgetw
        move=atkdata.fgetw
        if alevel<=level
          movelist[movelist.length]=move
        end
      end
      atkdata.close
      movelist|=[] # Remove duplicates
      # Use the last 4 items in the move list
      listend=movelist.length-4
      listend=0 if listend<0
      j=0
      for i in listend..listend+3
        moveid=(i>=movelist.length) ? 0 : movelist[i]
        @moves[j]=PBMove.new(moveid)
        j+=1
      end
    end
  end
end# This class stores data on each Pokemon.  Refer to $Trainer.party for an array
# of each Pokemon in the Trainer's current party.
class PokeBattle_Pokemon
  attr_reader(:totalhp)       # Current Total HP
  attr_reader(:attack)        # Current Attack stat
  attr_reader(:defense)       # Current Defense stat
  attr_reader(:speed)         # Current Speed stat
  attr_reader(:spatk)         # Current Special Attack stat
  attr_reader(:spdef)         # Current Special Defense stat
  attr_accessor(:iv)          # Array of 6 Individual Values for HP, Atk, Def,
                              #    Speed, Sp Atk, and Sp Def
  attr_accessor(:ev)          # Effort Values
  attr_accessor(:species)     # Species (National Pokedex number)
  attr_accessor(:personalID)  # Personal ID
  attr_accessor(:trainerID)   # 32-bit Trainer ID (the secret ID is in the upper
                              #    16 bits)
  attr_accessor(:hp)          # Current HP
  attr_accessor(:pokerus)     # Pokérus strain and infection time
  attr_accessor(:item)        # Held item
  attr_accessor(:itemRecycle) # Consumed held item (used in battle only)
  attr_accessor(:itemInitial) # Resulting held item (used in battle only)
  attr_accessor(:belch)       # Whether Pokémon can use Belch (used in battle only)
  attr_accessor(:burstAttack) # Whether the Pokémon has used its Burst Attack yet (used in battle only)
  attr_accessor(:mail)        # Mail
  attr_accessor(:fused)       # The Pokémon fused into this one
  attr_accessor(:name)        # Nickname
  attr_accessor(:exp)         # Current experience points
  attr_accessor(:happiness)   # Current happiness
  attr_accessor(:status)      # Status problem (PBStatuses) 
  attr_accessor(:statusCount) # Sleep count/Toxic flag
  attr_accessor(:eggsteps)    # Steps to hatch egg, 0 if Pokémon is not an egg
  attr_accessor(:moves)       # Moves (PBMove)
  attr_accessor(:ballused)    # Ball used
  attr_accessor(:markings)    # Markings
  attr_accessor(:obtainMode)  # Manner obtained:
                              #    0 - met, 1 - as egg, 2 - traded,
                              #    4 - fateful encounter
  attr_accessor(:obtainMap)   # Map where obtained
  attr_accessor(:obtainText)  # Replaces the obtain map's name if not nil
  attr_accessor(:obtainLevel) # Level obtained
  attr_accessor(:hatchedMap)  # Map where an egg was hatched
  attr_accessor(:language)    # Language
  attr_accessor(:ot)          # Original Trainer's name 
  attr_accessor(:otgender)    # Original Trainer's gender:
                              #    0 - male, 1 - female, 2 - mixed, 3 - unknown
                              #    For information only, not used to verify
                              #    ownership of the Pokemon
  attr_accessor(:abilityflag) # Forces the first/second/hidden (0/1/2) ability
  attr_accessor(:genderflag)  # Forces male (0) or female (1)
  attr_accessor(:natureflag)  # Forces a particular nature
  attr_accessor(:shinyflag)   # Forces the shininess (true/false)
  attr_accessor(:ribbons)     # Array of ribbons
  attr_accessor(:ballcapsule0)
  attr_accessor(:ballcapsule1)
  attr_accessor(:ballcapsule2)
  attr_accessor(:ballcapsule3)
  attr_accessor(:ballcapsule4)
  attr_accessor(:ballcapsule5)
  attr_accessor(:ballcapsule6)
  attr_accessor(:ballcapsule7)
  attr_accessor(:eggswitchlvl)
  attr_accessor(:eggmovesarray)
  attr_accessor :cool,:beauty,:cute,:smart,:tough,:sheen # Contest stats

#===============================================================================
# Ownership, obtained information
#===============================================================================
# Returns the gender of this Pokémon's original trainer (2=unknown).
  def otgender
    @otgender=2 if !@otgender
    return @otgender
  end

# Returns whether the specified Trainer is NOT this Pokemon's original trainer.
  def isForeign?(trainer)
    return @trainerID!=trainer.id || @ot!=trainer.name
  end

# Returns the public portion of the original trainer's ID.
  def publicID
    return @trainerID&0xFFFF
  end

# Returns this Pokémon's level when this Pokémon was obtained.
  def obtainLevel
    @obtainLevel=0 if !@obtainLevel
    return @obtainLevel
  end

# Returns the time when this Pokémon was obtained.
  def timeReceived
    return @timeReceived ? Time.at(@timeReceived) : Time.gm(2000)
  end

# Sets the time when this Pokémon was obtained.
  def timeReceived=(value)
    # Seconds since Unix epoch
    if value.is_a?(Time)
      @timeReceived=value.to_i
    else
      @timeReceived=value
    end
  end

# Returns the time when this Pokémon hatched.
  def timeEggHatched
    if obtainMode==1
      return @timeEggHatched ? Time.at(@timeEggHatched) : Time.gm(2000)
    else
      return Time.gm(2000)
    end
  end

# Sets the time when this Pokémon hatched.
  def timeEggHatched=(value)
    # Seconds since Unix epoch
    if value.is_a?(Time)
      @timeEggHatched=value.to_i
    else
      @timeEggHatched=value
    end
  end

#===============================================================================
# Level
#===============================================================================
# Returns this Pokemon's level.
  def level
    return PBExperience.pbGetLevelFromExperience(@exp,self.growthrate)
  end

# Sets this Pokemon's level by changing its Exp. Points.
  def level=(value)
    if value<1 || value>PBExperience::MAXLEVEL
      raise ArgumentError.new(_INTL("The level number ({1}) is invalid.",value))
    end
    self.exp=PBExperience.pbGetStartExperience(value,self.growthrate) 
  end

# Returns whether this Pokemon is an egg.
  def egg?
    return @eggsteps>0
  end

# Returns this Pokemon's growth rate.
  def growthrate
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,20)
    ret=dexdata.fgetb
    dexdata.close
    return ret
  end

# Returns this Pokemon's base Experience value.
  def baseExp
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,38)
    ret=dexdata.fgetw
    dexdata.close
    return ret
  end

#===============================================================================
# Gender
#===============================================================================
# Returns this Pokemon's gender. 0=male, 1=female, 2=genderless
  def gender
    @genderflag=nil if @genderflag==""
    return @genderflag if @genderflag
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,18)
    genderbyte=dexdata.fgetb
    dexdata.close
    case genderbyte
      when 255
        return 2 # genderless
      when 254
        return 1 # always female
      else
        lowbyte=@personalID&0xFF
        return PokeBattle_Pokemon.isFemale(lowbyte,genderbyte) ? 1 : 0
    end
  end

# Returns whether this Pokémon is female.
  def self.isFemale(b,genderRate)
    return (b<=30) if genderRate==0x1F  # FemaleOneEighth
    return (b<=63) if genderRate==0x3F  # Female25Percent
    return (b<=126) if genderRate==0x7F # Female50Percent
    return (b<=190) if genderRate==0xBF # Female75Percent
    return true if genderRate==0xFE     # AlwaysFemale
    return false if genderRate==0 || genderRate==0xFF # AlwaysMale or Genderless
    return (b<genderRate)
  end

# Sets this Pokémon's gender to a particular gender (if possible).
  def setGender(value)
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,18)
    genderbyte=dexdata.fgetb
    dexdata.close
    if genderbyte!=255 && genderbyte!=0 && genderbyte!=254
      @genderflag=value
    end
  end

#===============================================================================
# Ability
#===============================================================================
# Returns the index of this Pokémon's ability.
  def abilityIndex
    abil=@abilityflag!=nil ? @abilityflag : (@personalID&1)
    return abil
  end

# Returns the ID of this Pokemon's ability.
  def ability
    abil=abilityIndex
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,29)
    ret1=dexdata.fgetb
    ret2=dexdata.fgetb
    pbDexDataOffset(dexdata,@species,37)
    ret3=dexdata.fgetb
    dexdata.close
    ret=ret1
    if abil==2
      if ret3>0
        return ret3
      else
        abil=(@personalID&1)
      end
    end
    if abil==1
      ret=ret2
      if ret2==0
        ret=ret1
      end
    end
    return ret
  end

# Sets this Pokémon's ability to a particular ability (if possible).
  def setAbility(value)
    @abilityflag=value
  end

# Returns the list of abilities this Pokémon can have.
  def getAbilityList
    abils=[]; ret=[[],[]]
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,29)
    abils.push(dexdata.fgetb)
    abils.push(dexdata.fgetb)
    pbDexDataOffset(dexdata,@species,37)
    abils.push(dexdata.fgetb)
    dexdata.close
    for i in 0...abils.length
      if abils[i]>0 && !ret[0].include?(abils[i])
        ret[0].push(abils[i]); ret[1].push(i)
      end
    end
    return ret
  end

#===============================================================================
# Nature
#===============================================================================
# Returns the ID of this Pokémon's nature.
  def nature
    return @natureflag if @natureflag
    return @personalID%25
  end

# Sets this Pokémon's nature to a particular nature.
  def setNature(value)
    @natureflag=value
    self.calcStats
  end

#===============================================================================
# Shininess
#===============================================================================
# Returns whether this Pokemon is shiny (differently colored).
  def isShiny?
    
    ### BEANS ###
    return @shinyflag if @shinyflag
    mapname=pbGetMapNameFromId(@obtainMap)
    friendshiny=false
    friendloc="Friend Safari"
    friendshiny=true if friendloc==mapname && @shinyflag
    #return @shinyflag if (@shinyflag!=nil && !friendloc)
    return @shinyflag if friendshiny && @shinyflag
    a=@personalID^@trainerID
    b=a&0xFFFF
    c=(a>>16)&0xFFFF
    d=b^c
    if((d<SHINYPOKEMONCHANCE) && friendloc==mapname)
      return true
    else
      return @shinyflag if @shinyflag!=nil
      return (d<SHINYPOKEMONCHANCE)
    end
  end

# Makes this Pokemon shiny.
  def makeShiny
    @shinyflag=true
  end

# Makes this Pokemon not shiny.
  def makeNotShiny
    @shinyflag=false
  end

#===============================================================================
# Pokérus
#===============================================================================
# Gives this Pokemon Pokérus (either the specified strain or a random one).
  def givePokerus(strain=0)
    return if self.pokerusStage==2 # Can't re-infect a cured Pokémon
    if strain<=0 || strain>=16
      strain=1+rand(15)
    end
    time=1+(strain%4)
    @pokerus=time
    @pokerus|=strain<<4
  end

# Resets the infection time for this Pokemon's Pokérus (even if cured).
  def resetPokerusTime
    return if @pokerus==0
    strain=@pokerus%16
    time=1+(strain%4)
    @pokerus=time
    @pokerus|=strain<<4
  end

# Reduces the time remaining for this Pokemon's Pokérus (if infected).
  def lowerPokerusCount
    return if self.pokerusStage!=1
    @pokerus-=1
  end

# Returns the Pokérus infection stage for this Pokemon.
  def pokerusStage
    return 0 if !@pokerus                       # Not infected, not initialized
    @pokerus=@pokerus.to_i                      # Accounting for errors in trading
    return 0 if @pokerus==0                     # Not infected
    return 2 if @pokerus>0 && (@pokerus%16)==0  # Cured
    return 1                                    # Infected
  end

#===============================================================================
# Types
#===============================================================================
# Returns whether this Pokémon has the specified type.
  def hasType?(type)
    if type.is_a?(String) || type.is_a?(Symbol)
      return isConst?(self.type1,PBTypes,type)||isConst?(self.type2,PBTypes,type)
    else
      return self.type1==type || self.type2==type
    end
  end

# Returns this Pokémon's first type.
  def type1
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,8)
    ret=dexdata.fgetb
    dexdata.close
    return ret
  end

# Returns this Pokémon's second type.
  def type2
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,9)
    ret=dexdata.fgetb
    dexdata.close
    return ret
  end

#===============================================================================
# Moves
#===============================================================================
# Returns the list of moves this Pokémon can learn by levelling up.
  def getMoveList
    movelist=[]
    atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
    offset=atkdata.getOffset(@species-1)
    length=atkdata.getLength(@species-1)>>1
    atkdata.pos=offset
    for k in 0..length-1
      level=atkdata.fgetw
      move=atkdata.fgetw
      movelist.push([level,move])
    end
    atkdata.close
    return movelist
  end

# Sets this Pokémon's movelist to the default movelist it originally had.
def resetMoves(noohko=false)
  moves=self.getMoveList
  movelist=[]
  for i in moves
    if i[0]<=self.level
      movelist[movelist.length]=i[1]
    end
  end
  movelist=movelist.reverse
  movelist|=[] # Remove duplicates
  movelist=movelist.reverse
  listend=movelist.length-4
  listend=0 if listend<0
  j=0
  for i in listend...listend+4
    moveid=(i>=movelist.length) ? 0 : movelist[i]
    @moves[j]=PBMove.new(moveid)
    j+=1
  end
 # for i in listend...listend+4
 #   moveid=(i>=movelist.length) ? 0 : movelist[i]
 #   Kernel.pbMessage(PBMoves.getName(moveid))
    
 # end
  
end

#===============================================================================
# Contest attributes, ribbons
#===============================================================================
  def cool; @cool ? @cool : 0; end
  def beauty; @beauty ? @beauty : 0; end
  def cute; @cute ? @cute : 0; end
  def smart; @smart ? @smart : 0; end
  def tough; @tough ? @tough : 0; end
  def sheen; @sheen ? @sheen : 0; end

# Returns the number of ribbons this Pokemon has.
  def ribbonCount
    @ribbons=[] if !@ribbons
    return @ribbons.length
  end

# Returns whether this Pokémon has the specified ribbon.
  def hasRibbon?(ribbon) 
    @ribbons=[] if !@ribbons
    ribbon=getID(PBRibbons,ribbon) if !ribbon.is_a?(Integer)
    return false if ribbon==0
    return @ribbons.include?(ribbon)
  end

# Gives this Pokémon the specified ribbon.
  def giveRibbon(ribbon)
    @ribbons=[] if !@ribbons
    ribbon=getID(PBRibbons,ribbon) if !ribbon.is_a?(Integer)
    return if ribbon==0
    @ribbons.push(ribbon) if !@ribbons.include?(ribbon)
  end

# Replaces one ribbon with the next one along, if possible.
  def upgradeRibbon(*arg)
    @ribbons=[] if !@ribbons
    for i in 0...arg.length-1
      for j in 0...@ribbons.length
        thisribbon=(arg[i].is_a?(Integer)) ? arg[i] : getID(PBRibbons,arg[i])
        if @ribbons[j]==thisribbon
          nextribbon=(arg[i+1].is_a?(Integer)) ? arg[i+1] : getID(PBRibbons,arg[i+1])
          @ribbons[j]=nextribbon
          return nextribbon
        end
      end
    end
    if !hasRibbon?(arg[arg.length-1])
      firstribbon=(arg[0].is_a?(Integer)) ? arg[0] : getID(PBRibbons,arg[0])
      giveRibbon(firstribbon)
      return firstribbon
    end
    return 0
  end

# Removes the specified ribbon from this Pokémon.
  def takeRibbon(ribbon)
    return if !@ribbons
    ribbon=getID(PBRibbons,ribbon) if !ribbon.is_a?(Integer)
    return if ribbon==0
    for i in 0...@ribbons.length
      if @ribbons[i]==ribbon
        @ribbons[i]=nil; break
      end
    end
    @ribbons.compact!
  end
  
  def jsonarr
    return [method(:level), method(:nature), method(:isShiny?), method(:gender), 
           method(:ability), method(:abilityIndex)]
  end

# Removes all ribbons from this Pokémon.
  def clearAllRibbons
    @ribbons=[]
  end

#===============================================================================
# Other
#===============================================================================
# Returns the items this species can be found holding in the wild.
  def wildHoldItems
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,48)
    itemcommon=dexdata.fgetw
    itemuncommon=dexdata.fgetw
    itemrare=dexdata.fgetw
    dexdata.close
    itemcommon=0 if !itemcommon
    itemuncommon=0 if !itemuncommon
    itemrare=0 if !itemrare
    return [itemcommon,itemuncommon,itemrare]
  end

# Returns this Pokémon's mail.
  def mail
    return nil if !@mail
    if @mail.item==0 || self.item==0 || @mail.item!=self.item
      @mail=nil
      return nil
    end
    return @mail
  end

# Returns this Pokémon's language.
  def language; @language ? @language : 0; end

# Returns the markings this Pokémon has.
  def markings
    @markings=0 if !@markings
    @markings=0 if @markings=="nil"
    return @markings
  end

# Returns a string stating the Unown form of this Pokémon.
  def unownShape
    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ?!"[@form,1]
  end

# Returns the weight of this Pokémon.
  def weight
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,35)
    weight=dexdata.fgetw
    dexdata.close
    return weight
  end

# Returns the EV yield of this Pokémon.
  def evYield
    ret=[]
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,23)
    for i in 0...6
      v=dexdata.fgetb
      v=0 if !v
      ret.push(v)
    end
    dexdata.close
    return ret
  end

# Sets this Pokémon's HP.
  def hp=(value)
    value=0 if value<0
    @hp=value
    if @hp==0
      @status=0
      @statusCount=0
    end
  end

# Heals all HP, PP, and status problems of this Pokémon.
  def heal
    return if egg?
    @hp=@totalhp
    @status=0
    @statusCount=0
    for i in 0..3
      if @moves[i]
        @moves[i].pp=@moves[i].totalpp if !$game_switches[345]
      end
    end 
  end

# Changes the happiness of this Pokémon depending on what happened to change it.
  def changeHappiness(method)
    gain=0; luxury=false
    case method
      when "walking"
        gain=1
        luxury=true
      when "level up"
        gain=2
        gain=3 if @happiness<200
        gain=5 if @happiness<100
        luxury=true
      when "groom"
        gain=4
        gain=10 if @happiness<200
        luxury=true
      when "faint"
        gain=-1
      when "vitamin"
        gain=2
        gain=3 if @happiness<200
        gain=5 if @happiness<100
      when "EV berry"
        gain=2
        gain=5 if @happiness<200
        gain=10 if @happiness<100
      when "powder"
        gain=-10
        gain=-5 if @happiness<200
      when "Energy Root"
        gain=-15
        gain=-10 if @happiness<200
      when "Revival Herb"
        gain=-20
        gain=-15 if @happiness<200
      else
        Kernel.pbMessage(_INTL("Unknown happiness-changing method."))
    end
    if isConst?(self.item,PBItems,:SOOTHEBELL) && gain>0
      gain=(gain*3/2).floor
    end
    gain+=1 if luxury && @ballused==pbGetBallType(:LUXURYBALL)
    @happiness+=gain
    @happiness=[[255,@happiness].min,0].max
  end
  
  # Returns whether this Pokemon is a Delta Species
  def isDelta?
    deltaArray=Kernel.getAllDeltas
    return deltaArray.include?(@species)
  end
  
  # Returns whether this Pokemon is a Mega Evolution
  def isMega?
    if @form==nil || !@form
      @form=0
    end
    if @species==PBSpecies::EEVEE && @form>0
      return true
    end
    case @form
    when 0
      return false
    when 1
      if Kernel.pbGetMegaSpeciesList.include?(@species) && @species != PBSpecies::MEWTWO && 
         @species != PBSpecies::FLYGON
        return true
      elsif @species==PBSpecies::KYOGRE || @species==PBSpecies::GROUDON || @species==PBSpecies::REGIGIGAS
        return true
      end
    when 2
      if @species==PBSpecies::FLYGON || @species==PBSpecies::GIRATINA || @species==PBSpecies::MEWTWO || 
         @species==PBSpecies::SUNFLORA || @species==PBSpecies::DELTATYPHLOSION || 
         @species==PBSpecies::CHARIZARD || @species==PBSpecies::STEELIX || @species==PBSpecies::HYDREIGON ||
         @species==PBSpecies::DELTAMETAGROSS2
        return true
      end
    when 3
      if @species==PBSpecies::GARDEVOIR || @species==PBSpecies::LUCARIO || @species==PBSpecies::MEWTWO ||
         @species==PBSpecies::SUNFLORA || @species==PBSpecies::HYDREIGON
        return true
      end
    when 4
      if @species==PBSpecies::SUNFLORA || @species==PBSpecies::HYDREIGON
        return true
      end
    when 5
      if @species==PBSpecies::MEWTWO || @species==PBSpecies::HYDREIGON
        return true
      end
    when 19
      if @species==PBSpecies::ARCEUS
        return true
      end
    else
      return false
    end
    return false
  end
  
  # Returns whether this Pokemon is wearing Armor
  def isArmored?
    case @form
    when 0
      return false
    when 1
      if @species==PBSpecies::FLYGON || @species==PBSpecies::LEAVANNY || @species==PBSpecies::ZEKROM || 
         @species==PBSpecies::DELTAVOLCARONA || @species==PBSpecies::MEWTWO
        return true
      end
    when 2
      if @species==PBSpecies::TYRANITAR
        return true
      end
    else
      return false
    end
    return false
  end

#===============================================================================
# Stat calculations, Pokémon creation
#===============================================================================
# Returns this Pokémon's base stats.  An array of six values.
  def baseStats
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,10)
    ret=[
       dexdata.fgetb, # HP
       dexdata.fgetb, # Attack
       dexdata.fgetb, # Defense
       dexdata.fgetb, # Speed
       dexdata.fgetb, # Special Attack
       dexdata.fgetb  # Special Defense
    ]
    dexdata.close
    return ret
  end

# Returns the maximum HP of this Pokémon.
  def calcHP(base,level,iv,ev)
    return 1 if base==1
    return ((base*2+iv+(ev>>2))*level/100).floor+level+10
  end

# Returns the specified stat of this Pokémon (not used for total HP).
  def calcStat(base,level,iv,ev,pv)
    return ((((base*2+iv+(ev>>2))*level/100).floor+5)*pv/100).floor
  end

# Recalculates this Pokémon's stats.
  def calcStats
    nature=self.nature
    stats=[]
    pvalues=[100,100,100,100,100]
    nd5=(nature/5).floor
    nm5=(nature%5).floor
    if nd5!=nm5
      pvalues[nd5]=110
      pvalues[nm5]=90
    end
    level=self.level
    bs=self.baseStats
    for i in 0..5
      base=bs[i]
      if i==0
        stats[i]=calcHP(base,level,@iv[i],@ev[i])
      else
        stats[i]=calcStat(base,level,@iv[i],@ev[i],pvalues[i-1])
      end
    end
    diff=@totalhp-@hp
    @totalhp=stats[0]
    if @hp>0
      @hp=@totalhp-diff
      @hp=1 if @hp<=0
      @hp=@totalhp if @hp>@totalhp
    end
    @attack=stats[1]
    @defense=stats[2]
    @speed=stats[3]
    @spatk=stats[4]
    @spdef=stats[5]
  end

# Creates a new Pokémon object.
#    species   - Pokémon species.
#    level     - Pokémon level.
#    player    - PokeBattle_Trainer object for the original trainer.
#    withMoves - If false, this Pokémon has no moves.
  def initialize(species,level,player=nil,withMoves=true)
    if species<1 || species>PBSpecies.maxValue
      raise ArgumentError.new(_INTL("The species number (no. {1} of {2}) is invalid.",
         species,PBSpecies.maxValue))
      return nil
    end
    time=pbGetTimeNow
    @timeReceived=time.getgm.to_i # Use GMT
    @species=species
    # Individual Values
    @personalID=rand(256)
    @personalID|=rand(256)<<8
    @personalID|=rand(256)<<16
    @personalID|=rand(256)<<24
    @hp=1
    @totalhp=1
    @ev=[0,0,0,0,0,0]
    @iv=[]
    @iv[0]=rand(32)
    @iv[1]=rand(32)
    @iv[2]=rand(32)
    @iv[3]=rand(32)
    @iv[4]=rand(32)
    @iv[5]=rand(32)
    if player
      @trainerID=player.id
      @ot=player.name
      @otgender=player.gender
      @language=player.language
    else
      @trainerID=0
      @ot=""
      @otgender=2
    end
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,19)
    @happiness=dexdata.fgetb
    dexdata.close
    @name=PBSpecies.getName(@species)
    @eggsteps=0
    @status=0
    @statusCount=0
    @item=0
    @mail=nil
    @fused=nil
    @ribbons=[]
    @moves=[]
    @ballused=0
    @ballcapsule0=false
    @ballcapsule1=false
    @ballcapsule2=false
    @ballcapsule3=false
    @ballcapsule4=false
    @ballcapsule5=false
    @ballcapsule6=false
    @ballcapsule7=false

    self.level=level
    calcStats
    @hp=@totalhp
    if $game_map
      @obtainMap=$game_map.map_id
      @obtainText=nil
      @obtainLevel=level
    else
      @obtainMap=0
      @obtainText=nil
      @obtainLevel=level
    end
    @obtainMode=0   # Met
    @obtainMode=4 if $game_switches[32]   # Fateful encounter
    @hatchedMap=0
    if withMoves
      atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
      offset=atkdata.getOffset(species-1)
      length=atkdata.getLength(species-1)>>1
      atkdata.pos=offset
      # Generating move list
      movelist=[]
      for i in 0..length-1
        alevel=atkdata.fgetw
        move=atkdata.fgetw
        if alevel<=level
          movelist[movelist.length]=move
        end
      end
      atkdata.close
      movelist=movelist.reverse
      movelist|=[] # Remove duplicates
      movelist=movelist.reverse
      # Use the last 4 items in the move list
      listend=movelist.length-4
      listend=0 if listend<0
      j=0
      for i in listend..listend+3
        moveid=(i>=movelist.length) ? 0 : movelist[i]
        @moves[j]=PBMove.new(moveid)
        j+=1
      end
    end
  end
end