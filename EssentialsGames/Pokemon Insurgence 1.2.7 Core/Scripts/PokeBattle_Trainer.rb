class PokeBattle_TrainerPrimitive
  attr_reader(:name)
  attr_accessor(:id)
  attr_accessor(:trainertype)
  attr_accessor(:party)
  attr_accessor(:clothes)
  attr_accessor(:custom)
  attr_accessor(:bald)
  
    def initialize(name,trainertype)
    @name=name
    @trainertype=trainertype
    @id=rand(256)
    @id|=rand(256)<<8
    @id|=rand(256)<<16
    @id|=rand(256)<<24
    @clothes=Array.new
    for i in 0..5
        clothes[i]=0
    end
    
    @custom=Array.new
    @party=[]
  end
  
  def bald
      if @bald==nil
        @bald=false
      end
      return @bald
  end
  def bald=(value)
      @bald=value
  end
  
  

end



class PokeBattle_Trainer < PokeBattle_TrainerPrimitive
  attr_reader(:name)
  attr_accessor(:id)
  attr_accessor(:trainertype)
  attr_accessor(:badges)
  attr_accessor(:money)
  attr_accessor(:seen)
  attr_accessor(:owned)
  attr_accessor(:formseen)
  attr_accessor(:formlastseen)
  attr_accessor(:shadowcaught)
  attr_accessor(:party)
  attr_accessor(:pokedex)    # Whether the Pokédex was obtained
  attr_accessor(:pokegear)   # Whether the Pokégear was obtained
  attr_accessor(:language)
  attr_accessor(:megaforme)
  attr_accessor(:clothes)
  attr_accessor(:custom)
  attr_accessor(:bald)

  def language
    if !$game_switches[666]
      $game_switches[666]=true
      if $game_switches[7]
        $game_switches[61]=true
      end
      $PokemonSystem.language=pbGetLanguage()
      @language=pbGetLanguage()
    end
    if !@language
      @language=pbGetLanguage()
    end
    return @language
  end
  
  def getMoney
    return @money
  end  
  
  def money=(value)
    @money=[[value,MAXMONEY].min,0].max
  end

  def trainerTypeName   # Name of this trainer type (localized)
    return PBTrainers.getName(@trainertype) rescue _INTL("PkMn Trainer")
  end

  def moneyEarned   # Money won when trainer is defeated
    ret=0
    pbRgssOpen("Data/trainertypes.dat","rb"){|f|
       trainertypes=Marshal.load(f)
       return 30 if !trainertypes[@trainertype]
       ret=trainertypes[@trainertype][3]
    }
    return ret
  end
  
  def skill   # Skill level (for AI)
    ret=0
    pbRgssOpen("Data/trainertypes.dat","rb"){|f|
       trainertypes=Marshal.load(f)
       return 30 if !trainertypes[@trainertype]
       ret=trainertypes[@trainertype][8]
    }
    return ret
  end

  def name=(value)
    @name=value
  end
  
  
  def gender
    ret=2 # 2 = gender unknown
    pbRgssOpen("Data/trainertypes.dat","rb"){|f|
       trainertypes=Marshal.load(f)
       if !trainertypes[trainertype]
         ret=2
       else
         ret=trainertypes[trainertype][7]
         ret=2 if !ret
       end
    }
    return ret
  end
  
  
  def party=(value)
    @party=value
  end
  def id=(value)
    @id=value
  end
  def megaforme=(value)
    @megaforme=value
  end
  def clothes=(value)
    @clothes=value
  end
  
    
    
    
  def pokemonParty
    return @party.find_all {|item| item && !item.egg? }
  end
  
  def ablePokemonParty
    return @party.find_all {|item| item && !item.egg? && item.hp>0 }
  end

  def pokemonCount
    ret=0
    for i in 0...@party.length
      ret+=1 if @party[i] && !@party[i].egg?
    end
    return ret
  end

  def ablePokemonCount
    ret=0
    for i in 0...@party.length
      ret+=1 if @party[i] && !@party[i].egg? && @party[i].hp>0
    end
    return ret
  end

  def fullname
    return _INTL("{1} {2}",self.trainerTypeName,@name)
  end

  def numbadges # Number of badges
    ret=0
    for i in 0...@badges.length
      ret+=1 if @badges[i]
    end
    return ret
  end
  
  def firstAblePokemon
    p=self.ablePokemonParty
    return nil if p.length==0
    return p[0]
  end

  def publicID(id=nil) # Portion of the ID which is visible on the Trainer Card
    return id ? id&0xFFFF : (@id&0xFFFF)
  end

  def pokedexSeen(region=-1) # Number of Pokémon seen
    ret=0
    if region==-1
      for i in 0..PBSpecies.maxValue
        ret+=1 if @seen[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        ret+=1 if @seen[i]
      end
    end
    return ret
  end

  def pokedexOwned(region=-1) # Number of Pokémon owned
    ret=0
    if region==-1
      for i in 0..PBSpecies.maxValue
        ret+=1 if @owned[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        ret+=1 if @owned[i]
      end
    end
    return ret
  end

  def numFormsSeen(species)
    ret=0
    a=@formseen[species]
    for i in 0...[a[0].length,a[1].length].max
      ret+=1 if a[0][i] || a[1][i]
    end
    return ret
  end

  def setForeignID(other)
    @id=other.getForeignID
  end

  def getForeignID # Random ID other than this Trainer's ID
    fid=0
    loop do
      fid=rand(256)
      fid|=rand(256)<<8
      fid|=rand(256)<<16
      fid|=rand(256)<<24
      break if fid!=@id
    end
    return fid 
  end

  def initialize(name,trainertype)
    @name=name
    @language=pbGetLanguage()
    @trainertype=trainertype
    @id=rand(256)
    @id|=rand(256)<<8
    @id|=rand(256)<<16
    @id|=rand(256)<<24
    @seen=[]
    @owned=[]
    @shadowcaught=[]
    @formseen=[]
    @formlastseen=[]
    @badges=[]
    @pokedex=false
    @pokegear=false
    @clothes=Array.new
    @custom=Array.new
    for i in 1..PBSpecies.maxValue
      @seen[i]=false
      @owned[i]=false
      @shadowcaught[i]=false
      @formlastseen[i]=[]
      @formseen[i]=[[],[]]
    end
    for i in 0..7
      @badges[i]=false
    end
    @money=INITIALMONEY
    @party=[]
  end
end