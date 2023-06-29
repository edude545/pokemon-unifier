#===============================================================================
# General purpose utilities
#===============================================================================
class Array
  def shuffle
    dup.shuffle!
  end unless method_defined? :shuffle

  def ^(other) # xor of two arrays
    return (self|other)-(self&other)
  end

  def shuffle!
    size.times do |i|
      r = Kernel.rand(size)
      self[i], self[r] = self[r], self[i]
    end
    self
  end unless method_defined? :shuffle!
end

module Enumerable
  def transform
    ret=[]
    self.each(){|item| ret.push(yield(item)) }
    return ret
  end
end



#===============================================================================
# Pokémon Organized Battle
#===============================================================================
def pbHasEligible?(*arg)
  return pbBattleChallenge.rules.ruleset.hasValidTeam?($Trainer.party)
end

class PBPokemon
  attr_accessor :species
  attr_accessor :item
  attr_accessor :nature
  attr_accessor :move1
  attr_accessor :move2
  attr_accessor :move3
  attr_accessor :move4
  attr_accessor :ev

  def initialize(species,item,nature,move1,move2,move3,move4,ev)
    @species=species
    @item=item ? item : 0
    @nature=nature
    @move1=move1 ? move1 : 0
    @move2=move2 ? move2 : 0
    @move3=move3 ? move3 : 0
    @move4=move4 ? move4 : 0
    @ev=ev 
  end

=begin
  def _dump(depth)
    return [@species,@item,@nature,@move1,@move2,
       @move3,@move4,@ev].pack("vvCvvvvC")
  end

  def self._load(str)
    data=str.unpack("vvCvvvvC")
    return self.new(
       data[0],data[1],data[2],data[3],
       data[4],data[5],data[6],data[7]
    )
  end
=end

  def self.fromInspected(str)
    insp=str.gsub(/^\s+/,"").gsub(/\s+$/,"")
    pieces=insp.split(/\s*;\s*/)
    species=1
    if (PBSpecies.const_defined?(pieces[0]) rescue false)
      species=PBSpecies.const_get(pieces[0])
    end
    item=0
    if (PBItems.const_defined?(pieces[1]) rescue false)
      item=PBItems.const_get(pieces[1])
    end
    nature=PBNatures.const_get(pieces[2])
    ev=pieces[3].split(/\s*,\s*/)
    evvalue=0
    for i in 0...6
      next if !ev[i]||ev[i]==""
      evupcase=ev[i].upcase
      evvalue|=0x01 if evupcase=="HP"
      evvalue|=0x02 if evupcase=="ATK"
      evvalue|=0x04 if evupcase=="DEF"
      evvalue|=0x08 if evupcase=="SPD"
      evvalue|=0x10 if evupcase=="SA"
      evvalue|=0x20 if evupcase=="SD"
    end
    moves=pieces[4].split(/\s*,\s*/)
    moveid=[]
    for i in 0...4
      if (PBMoves.const_defined?(moves[i]) rescue false)
        moveid.push(PBMoves.const_get(moves[i]))
      end
    end
    moveid=[1] if moveid.length==0
    return self.new(species,item,nature,
       moveid[0],(moveid[1]||0),(moveid[2]||0),(moveid[3]||0),evvalue)
  end

  def self.fromPokemon(pokemon)
    evvalue=0
    evvalue|=0x01 if pokemon.ev[0]>60
    evvalue|=0x02 if pokemon.ev[1]>60
    evvalue|=0x04 if pokemon.ev[2]>60
    evvalue|=0x08 if pokemon.ev[3]>60
    evvalue|=0x10 if pokemon.ev[4]>60
    evvalue|=0x20 if pokemon.ev[5]>60
    return self.new(pokemon.species,pokemon.item,pokemon.nature,
       pokemon.moves[0].id,pokemon.moves[1].id,pokemon.moves[2].id,
       pokemon.moves[3].id,evvalue)
  end

  def inspect
    c1=getConstantName(PBSpecies,@species)
    c2=(@item==0) ? "" : getConstantName(PBItems,@item)
    c3=getConstantName(PBNatures,@nature)
    evlist=""
    for i in 0...@ev
      if ((@ev&(1<<i))!=0)
        evlist+="," if evlist.length>0
        evlist+=["HP","ATK","DEF","SPD","SA","SD"][i]
      end
    end
    c4=(@move1==0) ? "" : getConstantName(PBMoves,@move1)
    c5=(@move2==0) ? "" : getConstantName(PBMoves,@move2)
    c6=(@move3==0) ? "" : getConstantName(PBMoves,@move3)
    c7=(@move4==0) ? "" : getConstantName(PBMoves,@move4)
    return "#{c1};#{c2};#{c3};#{evlist};#{c4},#{c5},#{c6},#{c7}"
  end

  def tocompact
    return "#{species},#{item},#{nature},#{move1},#{move2},#{move3},#{move4},#{ev}"
  end

  def self.constFromStr(mod,str)
    maxconst=0
    for constant in mod.constants
      maxconst=[maxconst,mod.const_get(constant.to_sym)].max
    end
    for i in 1..maxconst
      val=mod.getName(i)
      next if !val || val==""
      return i if val==str
    end
    return 0
  end

  def self.fromString(str)
    return self.fromstring(str)
  end

  def self.fromstring(str)
    s=str.split(/\s*,\s*/)
    species=self.constFromStr(PBSpecies,s[1])
    item=self.constFromStr(PBItems,s[2])
    nature=self.constFromStr(PBNatures,s[3])
    move1=self.constFromStr(PBMoves,s[4])
    move2=(s.length>=12) ? self.constFromStr(PBMoves,s[5]) : 0
    move3=(s.length>=13) ? self.constFromStr(PBMoves,s[6]) : 0
    move4=(s.length>=14) ? self.constFromStr(PBMoves,s[7]) : 0
    ev=0
    slen=s.length-6
    ev|=0x01 if s[slen].to_i>0
    ev|=0x02 if s[slen+1].to_i>0
    ev|=0x04 if s[slen+2].to_i>0
    ev|=0x08 if s[slen+3].to_i>0
    ev|=0x10 if s[slen+4].to_i>0
    ev|=0x20 if s[slen+5].to_i>0
    return self.new(species,item,nature,move1,move2,move3,move4,ev)
  end

  def convertMove(move)
    if isConst?(move,PBMoves,:RETURN) && hasConst?(PBMoves,:FRUSTRATION)
       move=getConst(PBMoves,:FRUSTRATION)
    end
    return move
  end

  def createPokemon(level,iv,trainer)
    pokemon=PokeBattle_Pokemon.new(@species,level,trainer,false)
    pokemon.item=@item
    pokemon.personalID=rand(65536)
    pokemon.personalID|=rand(65536)<<8
    pokemon.personalID-=pokemon.personalID%25
    pokemon.personalID+=nature
    pokemon.personalID&=0xFFFFFFFF
    pokemon.happiness=0
    pokemon.moves[0]=PBMove.new(self.convertMove(@move1))
    pokemon.moves[1]=PBMove.new(self.convertMove(@move2))
    pokemon.moves[2]=PBMove.new(self.convertMove(@move3))
    pokemon.moves[3]=PBMove.new(self.convertMove(@move4))
    evcount=0
    for i in 0...6
      evcount+=1 if ((@ev&(1<<i))!=0)
    end
    evperstat=(evcount==0) ? 0 : 510/evcount
    for i in 0...6
      pokemon.iv[i]=iv
      pokemon.ev[i]=((@ev&(1<<i))!=0) ? evperstat : 0
      #Kernel.pbMessage(_INTL("IV: {1}",pokemon.iv[i].to_s))
      #Kernel.pbMessage(_INTL("EV: {1}",pokemon.ev[i].to_s))
    end
    pokemon.calcStats
    return pokemon
  end
end



def pbGetBTTrainers(challengeID)
  trlists=(load_data("Data/trainerlists.dat") rescue [])
  for i in 0...trlists.length
    tr=trlists[i]
    if !tr[5] && tr[2].include?(challengeID)
      return tr[0]
    end
  end
  for i in 0...trlists.length
    tr=trlists[i]
    if tr[5] # is default list
      return tr[0]
    end
  end
  return tr[0]
  return []
end

def pbGetBTPokemon(challengeID)
  trlists=(load_data("Data/trainerlists.dat") rescue [])
  for tr in trlists
    if !tr[5] && tr[2].include?(challengeID)
      return tr[1]
    end
  end
  for tr in trlists
    if tr[5] # is default list
      return tr[1]
    end
  end
  return []
end



class Game_Map
  attr_accessor :map_id
end



class Game_Player
  attr_accessor :direction

  def moveto2(x, y)
    @x = x
    @y = y
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
end



class BattleChallengeType
  attr_accessor :currentWins
  attr_accessor :previousWins
  attr_accessor :maxWins
  attr_accessor :currentSwaps
  attr_accessor :previousSwaps
  attr_accessor :maxSwaps
  attr_reader :doublebattle
  attr_reader :numPokemon
  attr_reader :battletype
  attr_reader :mode

  def initialize
    @previousWins=0
    @maxWins=0
    @currentWins=0
    @currentSwaps=0
    @previousSwaps=0
    @maxSwaps=0
  end

  def saveWins(challenge)
    if challenge.decision!=0 # if won or lost
      if challenge.decision==1 # if won
        @currentWins=challenge.wins
        @currentSwaps=challenge.swaps
      else
        @currentWins=0
        @currentSwaps=0
      end
      @maxWins=[@maxWins,challenge.wins].max
      @previousWins=challenge.wins
      @maxSwaps=[@maxSwaps,challenge.swaps].max
      @previousSwaps=challenge.swaps
    else # if undecided
      @currentWins=0
      @currentSwaps=0
    end
  end
end



class BattleChallengeData
  attr_reader :resting
  attr_reader :wins
  attr_reader :swaps
  attr_reader :inProgress
  attr_reader :battleNumber
  attr_reader :numRounds
  attr_accessor :decision
  attr_reader :party
  attr_reader :extraData

  def setExtraData(value)
    @extraData=value
  end
  
  def extras
    return @extraData
  end
  
  def pbAddWin
    if @inProgress
      @battleNumber+=1
      @wins+=1
    end
  end

  def pbAddSwap
    if @inProgress
      @swaps+=1
    end
  end

  def pbMatchOver?
    return true if !@inProgress
    return true if @decision!=0
    return (@battleNumber>@numRounds)
  end

  def initialize
    reset
  end

  def nextTrainer
    return @trainers[@battleNumber-1]
  end

  def pbGoToStart
    if $scene.is_a?(Scene_Map)
      $game_temp.player_transferring = true
      $game_temp.player_new_map_id = @start[0]
      $game_temp.player_new_x = @start[1]
      $game_temp.player_new_y = @start[2]+1
      $game_temp.player_new_direction = 8
      $scene.transfer_player
    end
  end

  def setParty(value)
    if @inProgress
      $Trainer.party=value
      @party=value
    else
      @party=value
    end
  end

  def pbStart(t,numRounds)
    @inProgress=true
    @resting=false
    @decision=0
    @swaps=t.currentSwaps
    @wins=t.currentWins
    @battleNumber=1
    @trainers=[]
    #    Kernel.pbMessage("Testing 1")

    raise _INTL("Number of rounds is 0 or less.") if numRounds<=0
    @numRounds=numRounds
    btTrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
#        Kernel.pbMessage("Testing 2")
    while @trainers.length<@numRounds
      newtrainer=pbBattleChallengeTrainer(@wins+@trainers.length,btTrainers)
      found=false
      for tr in @trainers
        found=true if tr==newtrainer
      end
      @trainers.push(newtrainer) if !found
    end
    #        Kernel.pbMessage("Testing 3")

    @start=[$game_map.map_id,$game_player.x,$game_player.y]
    @oldParty=$Trainer.party
    $Trainer.party=@party if @party
    pbSave(true)
  end

  def pbCancel
    $Trainer.party=@oldParty if @oldParty
    reset
  end

  def pbEnd
    currentParty=$Trainer.party
    $Trainer.party=@oldParty
    return if !@inProgress
    save=(@decision!=0)
    reset
    $game_map.need_refresh=true
    if save
      pbSave(true)
    end 
    $PokemonTemp.dependentEvents.refresh_sprite
  end

  def pbGoOn
    return if !@inProgress
    @resting=false
    pbSaveInProgress
  end

  def pbRest
    return if !@inProgress
    @resting=true
    pbSaveInProgress
  end

  private

  def reset
    @inProgress=false
    @resting=false
    @start=nil
    @decision=0
    @wins=0
    @swaps=0
    @battleNumber=0
    @trainers=[]
    @oldParty=nil
    @party=nil
    @extraData=nil
  end

  def pbSaveInProgress
    oldmapid=$game_map.map_id
    oldx=$game_player.x
    oldy=$game_player.y
    olddirection=$game_player.direction
    $game_map.map_id=@start[0]
    $game_player.moveto2(@start[1],@start[2])
    $game_player.direction=8 # facing up
    pbSave(true)
    $game_map.map_id=oldmapid
    $game_player.moveto2(oldx,oldy)
    $game_player.direction=olddirection
  end
end



class BattleChallenge
  attr_reader :currentChallenge
  BattleTower   = 0
  BattlePalace  = 1
  BattleArena   = 2
  BattleFactory = 3

  def initialize
    @bc=BattleChallengeData.new
    @currentChallenge=-1
    @types={}
  end

  def extras
    if !@bc
      @bc=BattleChallengeData.new
      @currentChallenge=-1
      @types={}
    end
    if !@bc.extras
      @bc.setExtraData(BattleFactoryData.new(@bc))
    end
    return @bc.extras
  end
  
  
  def rules
    if !@rules
      @rules=modeToRules(self.data.doublebattle,
      self.data.numPokemon,
      self.data.battletype,self.data.mode)
    end
    return @rules  
  end

  def modeToRules(doublebattle,numPokemon,battletype,mode)
    rules=PokemonChallengeRules.new
    if battletype==BattlePalace
      rules.setBattleType(BattlePalaceClass.new)
    elsif battletype==BattleArena
      rules.setBattleType(BattleArenaClass.new)
      doublebattle=false
    else
      rules.setBattleType(BattleTowerClass.new)
    end
    if mode==1 # Open Level
      rules.setRuleset(StandardRules.new(numPokemon,PBExperience::MAXLEVEL))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(30))
    elsif mode==2 # Battle Tent
      rules.setRuleset(StandardRules.new(numPokemon,PBExperience::MAXLEVEL))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(60))
    else
      rules.setRuleset(StandardRules.new(numPokemon,50))
      rules.setLevelAdjustment(OpenLevelAdjustment.new(50)) 
    end
    if doublebattle
      rules.addBattleRule(DoubleBattle.new)
    else
      rules.addBattleRule(SingleBattle.new)
    end
    return rules
  end

  def set(id,numrounds,rules)
    @rules=rules
    @id=id
    @numRounds=numrounds
    pbWriteCup(id,rules)
  end

  def start(*args)
    t=ensureType(@id)
    @currentChallenge=@id # must appear before pbStart
    $game_variables[89]=@bc
#    Kernel.pbMessage("hay" + $game_variables[89].to_s)
    @bc.pbStart(t,@numRounds)
  end

  def register(id,doublebattle,numrounds,numPokemon,battletype,mode=1)
    t=ensureType(id)
    if battletype=="BattleFactory"
      @bc.setExtraData(BattleFactoryData.new(@bc))
  #    Kernel.pbMessage("sup")
      numPokemon=3
      battletype=BattleTower
    end
    @numRounds=numrounds
    @rules=modeToRules(doublebattle,numPokemon,battletype,mode)
  end

  def pbInChallenge?
    return pbInProgress?
  end

  def data
    return nil if !pbInProgress? || @currentChallenge<0
    return ensureType(@currentChallenge).clone
  end

  def getCurrentWins(challenge)
    return ensureType(challenge).currentWins
  end

  def getPreviousWins(challenge)
    return ensureType(challenge).previousWins
  end

  def getMaxWins(challenge)
    return ensureType(challenge).maxWins
  end

  def getCurrentSwaps(challenge)
    return ensureType(challenge).currentSwaps
  end

  def getPreviousSwaps(challenge)
    return ensureType(challenge).previousSwaps
  end

  def getMaxSwaps(challenge)
    return ensureType(challenge).maxSwaps
  end

  def pbStart(challenge)
  end

  def pbEnd
    if @currentChallenge!=-1
      ensureType(@currentChallenge).saveWins(@bc)
      @currentChallenge=-1
    end
    @bc.pbEnd
  end
=begin
pbLoadTrainer(trainerid,trainername,trainerparty)
pbTrainerBattle(ChallengeChampionship.new.getTrainerClass,ChallengeChampionship.new.getTrainerName,_I("Could it be? You defeated the Battle Palace!"),false,5,true)

pbOrganizedBattleEx(pbLoadTrainer(ChallengeChampionship.new.getTrainerClass,ChallengeChampionship.new.getTrainerName),pbBattleChallenge.rules,"Could it be? You defeated the Battle Palace!","I knew you wouldn't have a chance of beating me!")
=end
  
  
  def pbBattle #purrloin
    return @bc.extraData.pbBattle(self) if @bc.extraData
    opponent=pbGenerateBattleTrainer(self.nextTrainer,self.rules)
    bttrainers=pbGetBTTrainers(@id) 
    trainerdata=bttrainers[self.nextTrainer]
    #Kernel.pbMessage(""+opponent.to_s)
    #Kernel.pbMessage(""+opponent[0].to_s)
    ret=pbOrganizedBattleEx(opponent,self.rules,
    pbGetMessageFromHash(MessageTypes::EndSpeechLose,trainerdata[4]),
    pbGetMessageFromHash(MessageTypes::EndSpeechWin,trainerdata[3]))
    return ret
  end

  def pbInProgress?
    return @bc.inProgress
  end

  def pbResting?
    return @bc.resting
  end

  def setDecision(value)
    @bc.decision=value
  end

  def setParty(value)
    @bc.setParty(value)
  end

  def extra; @bc.extraData; end
  def decision; @bc.decision; end
  def wins; @bc.wins; end
  def swaps; @bc.swaps; end
  def battleNumber; @bc.battleNumber; end
  def nextTrainer; @bc.nextTrainer; end
  def pbGoOn; @bc.pbGoOn; end
  def pbAddWin; @bc.pbAddWin; end
  def pbCancel; @bc.pbCancel; end
  def pbRest; @bc.pbRest; end
  def pbMatchOver?; @bc.pbMatchOver?; end
  def pbGoToStart; @bc.pbGoToStart; end

  private

  def ensureType(id)
    if @types.is_a?(Array)
      oldtypes=@types
      @types={}
      for i in 0...oldtypes.length
        if oldtypes[i]
          @types[i]=oldtypes[i]
        end
      end
    end
    if !@types[id]
      @types[id]=BattleChallengeType.new
    end
    return @types[id]
  end
end




def pbRecordLastBattle
  $PokemonGlobal.lastbattle=$PokemonTemp.lastbattle
  $PokemonTemp.lastbattle=nil
end

def pbPlayBattle(battledata)
  if battledata
    scene=pbNewBattleScene
    scene.abortable=true
    lastbattle=Marshal.restore(StringInput.new(battledata))
    case lastbattle[0]
      when BattleChallenge::BattleTower
        battleplayer=PokeBattle_BattlePlayer.new(scene,lastbattle)
      when BattleChallenge::BattlePalace
        battleplayer=PokeBattle_BattlePalacePlayer.new(scene,lastbattle)
      when BattleChallenge::BattleArena
        battleplayer=PokeBattle_BattleArenaPlayer.new(scene,lastbattle)
    end
    bgm=BattlePlayerHelper.pbGetBattleBGM(lastbattle)
    pbBattleAnimation(bgm) { 
       pbSceneStandby {
          decision=battleplayer.pbStartBattle
       }
    }
  end
end

def pbDebugPlayBattle
  params=ChooseNumberParams.new
  params.setRange(0,500)
  params.setInitialValue(0)
  params.setCancelValue(-1)
  num=Kernel.pbMessageChooseNumber(_INTL("Choose a battle."),params)
  if num>=0
    pbPlayBattleFromFile(sprintf("Battles/Battle%03d.dat",num))
  end
end

def pbPlayLastBattle
  pbPlayBattle($PokemonGlobal.lastbattle)
end

def pbPlayBattleFromFile(filename)
  pbRgssOpen(filename,"rb"){|f|
     pbPlayBattle(f.read)
  }
end



class Game_Event
  def pbInChallenge?
    return pbBattleChallenge.pbInChallenge?
  end
end



def pbBattleChallenge
  if !$PokemonGlobal.challenge
    
    $PokemonGlobal.challenge=BattleChallenge.new
  end
  return $PokemonGlobal.challenge
end

def pbBattleChallengeTrainer(numwins,bttrainers)
  table=[
     0,5,0,100,
     6,6,80,40,
     7,12,80,40,
     13,13,120,20,
     14,19,100,40,
     20,20,140,20,
     21,26,120,40,
     27,27,160,20,
     28,33,140,40,
     34,34,180,20,
     35,40,160,40,
     41,41,200,20,
     42,47,180,40,
     48,48,220,40,
     49,-1,200,100
  ]
  for i in 0...table.length/4
    if table[i*4]<=numwins
      if (table[i*4+1]<0 || table[i*4+1]>=numwins)
        offset=((table[i*4+2]*bttrainers.length).floor/300).floor
        length=((table[i*4+3]*bttrainers.length).floor/300).floor
        return (offset+rand(length)).floor
      end
    end
  end
  return 0
end

def pbBattleChallengeGraphic(event)
  nextTrainer=pbBattleChallenge.nextTrainer
  bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  filename=sprintf("trchar%03d",(bttrainers[nextTrainer][0] rescue 0))
  begin
    bitmap=AnimatedBitmap.new("Graphics/Characters/"+filename)
    bitmap.dispose
    event.character_name=filename
    rescue
    event.character_name="Red"
  end
end

def pbBattleChallengeBeginSpeech
  if !pbBattleChallenge.pbInProgress?
    return "..."
  else
    bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    tr=bttrainers[pbBattleChallenge.nextTrainer]
    return tr ? pbGetMessageFromHash(MessageTypes::BeginSpeech,tr[2]) : "..."
  end
end

def pbRemoveItemScreen
  ret=false
  pbFadeOutIn(99999){
     scene=PokemonScreen_Scene.new
     screen=PokemonScreen.new(scene,$Trainer.party)
     ret=screen.pbPokemonRemoveItemScreenEx
  }
  return ret
end

def pbEntryScreen(*arg)
  retval=false
  pbFadeOutIn(99999){
     scene=PokemonScreen_Scene.new
     screen=PokemonScreen.new(scene,$Trainer.party)
     ret=screen.pbPokemonMultipleEntryScreenEx(pbBattleChallenge.rules.ruleset)
     # Set party
     pbBattleChallenge.setParty(ret) if ret
     # Continue (return true) if Pokémon were chosen
     retval=(ret!=nil && ret.length>0)
  }
  return retval
end

def pbBattleChallengeBattle
  return pbBattleChallenge.pbBattle
end



class BattleFactoryData
  def initialize(bcdata)
    @bcdata=bcdata
  end

  def pbPrepareRentals
    @rentals=pbBattleFactoryPokemon(StandardRules.new(3),@bcdata.wins,@bcdata.swaps,[])
    @trainerid=@bcdata.nextTrainer
    bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata=bttrainers[@trainerid]
    @opponent=PokeBattle_Trainer.new(
       pbGetMessageFromHash(MessageTypes::TrainerNames,trainerdata[1]),
       trainerdata[0])
    opponentPkmn=pbBattleFactoryPokemon(StandardRules.new(3),@bcdata.wins,@bcdata.swaps,@rentals)
    for i in 0...3
      @opponent.party.push(opponentPkmn[i])
    end
    #@opponent.party=opponentPkmn.shuffle[0,3]
  end
  
  def pbSetItems
    @olditems=@opponentItems
  end

  def pbChooseRentals
    pbFadeOutIn(99999){
       scene=BattleSwapScene.new
      screen=BattleSwapScreen.new(scene)
      @rentals=screen.pbStartRent(@rentals)
      @bcdata.pbAddSwap
      pbBattleChallenge.setParty(@rentals)
    }
  end

  def pbBattle(challenge)
    bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata=bttrainers[@trainerid]
    return pbOrganizedBattleEx(@opponent,challenge.rules,
       pbGetMessageFromHash(MessageTypes::EndSpeechLose,trainerdata[4]),
       pbGetMessageFromHash(MessageTypes::EndSpeechWin,trainerdata[3]))
  end

  def pbPrepareSwaps(challenge)
    @oldopponent=@opponent.party
    trainerid=@bcdata.nextTrainer
    bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata=bttrainers[trainerid]
    @opponent=PokeBattle_Trainer.new(
       pbGetMessageFromHash(MessageTypes::TrainerNames,trainerdata[1]),
       trainerdata[0])
    opponentPkmn=pbBattleFactoryPokemon(
       challenge.rules,@bcdata.wins,@bcdata.swaps,
       [].concat(@rentals).concat(@oldopponent))
    for i in 0...3
      @opponent.party.push(opponentPkmn[i])
    end
    #@opponent.party=opponentPkmn.shuffle[0,3]
  end

  def pbChooseSwaps
    swapMade=true
    pbFadeOutIn(99999){
       scene=BattleSwapScene.new
       screen=BattleSwapScreen.new(scene)
       swapMade=screen.pbStartSwap(@rentals,@oldopponent,@olditems)
       if swapMade
         @bcdata.pbAddSwap
       end
       @bcdata.setParty(@rentals)
    }
    return swapMade
  end
end

#xxx.currentchallenge = @bcdata

def pbBattleFactoryPokemon(rule,numwins,numswaps,rentals)
  table=nil
  btpokemon=pbGetBTPokemon(pbBattleChallenge.currentChallenge)
  ivtable=[
     0,6,3,6,
     7,13,6,9,
     14,20,9,12,
     21,27,12,15,
     28,34,15,21,
     35,41,21,31,
     42,-1,31,31
  ]
  groups=[
     1,14,6,0,
     15,21,5,1,
     22,28,4,2,
     29,35,3,3,
     36,42,2,4,
     43,-1,1,5
  ]
 # if rule.suggestedLevel!=100
    table=[
       0,6,110,199,
       7,13,162,266,
       14,20,267,371,
       21,27,372,467,
       28,34,468,563,
       35,41,564,659,
       42,48,660,755,
       49,-1,372,849
    ]
  #else # Open Level (Level 100)
  #  table=[
  #     0,6,372,467,
  #     7,13,468,563,
  #     14,20,564,659,
  #     21,27,660,755,
  #     28,34,372,881,
  #     35,41,372,881,
  #     42,48,372,881,
  #     49,-1,372,881
  #  ]
  #end
  pokemonNumbers=[0,0]
  ivs=[0,0]
  ivgroups=[6,0]
  for i in 0...table.length/4
    if table[i*4]<=numwins
      if (table[i*4+1]<0 || table[i*4+1]>=numwins)
        pokemonNumbers=[
           table[i*4+2]*btpokemon.length/882,
	         table[i*4+3]*btpokemon.length/882
	      ]
      end
    end
  end
  for i in 0...ivtable.length/4
    if ivtable[i*4]<=numwins
      if (ivtable[i*4+1]<0 || ivtable[i*4+1]>=numwins)
        ivs=[ivtable[i*4+2],ivtable[i*4+3]]
      end
    end
  end
  for i in 0...groups.length/4
    if groups[i*4]<=numswaps
      if (groups[i*4+1]<0 || groups[i*4+1]>=numswaps)
        ivgroups=[groups[i*4+2],groups[i*4+3]]
      end
    end
  end
  party=[]
  partyItems=[]
  begin
    party.clear
    while party.length<6
=begin
      rnd=pokemonNumbers[0]+rand(pokemonNumbers[1]-pokemonNumbers[0]+1)
      rndpoke=btpokemon[rnd]
      indvalue=(party.length<ivgroups[0]) ? ivs[0] : ivs[1]
      poke=rndpoke.createPokemon(120,indvalue,nil) #delcatty
      poke.species=(ChallengeChampionship.new).generatePokemon(rand(1))
      poke.name=PBSpecies.getName(poke.species)
      poke.resetMoves
      poke.calcStats
=end
      if $game_map.map_id==695 || $game_map.map_id==696
        val=$game_variables[172]
      end
      if $game_map.map_id==693 || $game_map.map_id==700 || $game_map.map_id==699 || $game_map.map_id==701
        val=$game_variables[173]
      end
      if $game_map.map_id==694 || $game_map.map_id==698
        val=$game_variables[174]
      end
      
      allowedMons=[]
      if val<20
        for i in 1..152
          allowedMons.push($game_variables[175][i])
        end
      end
      if 14<val && val<27
        for i in 153..382
          allowedMons.push($game_variables[175][i])
        end
      end
      if 21<val && val<70
        for i in 383..852
          allowedMons.push($game_variables[175][i])
        end
      end
      if 49<val && val<85
        for i in 853..902
          allowedMons.push($game_variables[175][i])
        end
      end
      if 71<val && val<92
        for i in 903..1270
          allowedMons.push($game_variables[175][i])
        end
      end
      if 86<val
        for i in 1271..1554
          allowedMons.push($game_variables[175][i])
        end
        for i in 1893..1942
          allowedMons.push($game_variables[175][i])
        end
      end
      if 100<val
        for i in 1555..1870
          allowedMons.push($game_variables[175][i])
        end
        for i in 1943..2058
          allowedMons.push($game_variables[175][i])
        end
      end
      if 121<val 
        for i in 1871..1892
          allowedMons.push($game_variables[175][i])
        end
        for i in 2059..2082
          allowedMons.push($game_variables[175][i])
        end
      end
      player=true
      if rentals.length!=0
        player=false
      end
      if player
        if party.length<1
          num=rand(allowedMons.length)
          pkmn=allowedMons[num]
          #Kernel.pbMessage(_INTL("First member: {1}",pkmn.name))
          #Kernel.pbMessage(_INTL("First item: {1}",PBItems.getName(pkmn.item)))
        else
          pass=false
          while !pass
            num=rand(allowedMons.length)
            pkmn=allowedMons[num]
            #Kernel.pbMessage(_INTL("Checking member: {1}",pkmn.name))
            #Kernel.pbMessage(_INTL("Checking item: {1}",PBItems.getName(pkmn.item)))
            for i in 0...party.length
              if party[i].item==pkmn.item || party[i].species==pkmn.species
                pass=false
                break
              else
                pass=true
              end
            end
          end
        end
      else
        #5000.times do
          pass=false
          while !pass
            num=rand(allowedMons.length)
            pkmn=allowedMons[num]
            #Kernel.pbMessage(_INTL("Checking member: {1}",pkmn.name))
            #Kernel.pbMessage(_INTL("Checking item: {1}",PBItems.getName(pkmn.item)))
            for i in 0...rentals.length
              #if pkmn==nil
              #  for k in 0...allowedMons.length
              #    Kernel.pbMessage(_INTL("{1}",allowedMons[1104].name)) #if k>=295
              #  end
              #end
              rentalItem=rentals[i].item
              pkmnItem=pkmn.item
              if rentalItem==pkmnItem || rentals[i].species==pkmn.species #rentals[i].item==pkmn.item ||
                pass=false
                #Kernel.pbMessage("Redo1")
                break
              else
                if party.length>0
                  for j in 0...party.length
                    if party[j].item==pkmn.item || party[j].species==pkmn.species
                      pass=false
                      #Kernel.pbMessage("Redo2")
                      break
                    else
                      pass=true
                    end
                  end
                else
                  pass=true
                end
              end
            end
            #if party.length>0
              
            #end
          end
        #end
      end
      #pkmn=allowedMons[rand(allowedMons.length)+1]
      party.push(pkmn)
      if !player
        partyItems.push(pkmn.item)
        @opponentItems=partyItems
      end
    end
  end until party.length==6#rule.isValid?(party)
  return party
end

def pbGenerateBattleTrainer(trainerid,rule)
  bttrainers=pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  trainerdata=bttrainers[trainerid]
  opponent=PokeBattle_Trainer.new(
     pbGetMessageFromHash(MessageTypes::TrainerNames,trainerdata[1]),
     trainerdata[0])
  btpokemon=pbGetBTPokemon(pbBattleChallenge.currentChallenge)
  # Individual Values
  indvalues=31
  indvalues=21 if trainerid<220
  indvalues=18 if trainerid<200
  indvalues=15 if trainerid<180
  indvalues=12 if trainerid<160
  indvalues=9 if trainerid<140
  indvalues=6 if trainerid<120
  indvalues=3 if trainerid<100
  pokemonnumbers=trainerdata[5]
  #p trainerdata
  if pokemonnumbers.length<rule.ruleset.suggestedNumber
    for n in pokemonnumbers
      rndpoke=btpokemon[n]
      pkmn=rndpoke.createPokemon(
         rule.ruleset.suggestedLevel,indvalues,opponent)
         #DELCATTY
         randomint = rand(1)
         pkmn.species=(ChallengeChampionship.new).generatePokemon(randomint)
         pkmn.name=PBSpecies.getName(pkmn.species)

         pkmn.resetMoves
         pkmn.calcStats
      opponent.party.push(pkmn)
    end
    return opponent
  end
  begin
    opponent.party.clear
    while opponent.party.length<rule.ruleset.suggestedNumber
      rnd=pokemonnumbers[rand(pokemonnumbers.length)]
      rndpoke=btpokemon[rnd]
      pkmn=rndpoke.createPokemon(
        rule.ruleset.suggestedLevel,indvalues,opponent)
        #delcatty2
        randomint = rand(1)
        #Sunkern
        val=0
        if $game_map.map_id==695 || $game_map.map_id==696
          val=$game_variables[172]
        elsif $game_map.map_id==693 || $game_map.map_id==700 || $game_map.map_id==701
          val=$game_variables[173]
        elsif $game_map.map_id==694 || $game_map.map_id==698
          val=$game_variables[174]
        end
        allowedMons=[]
        if val<20
          for i in 1..152
            allowedMons.push($game_variables[175][i])
          end
        elsif 14<val && val<27
          for i in 153..382
            allowedMons.push($game_variables[175][i])
          end
        elsif 21<val && val<70
          for i in 383..852
            allowedMons.push($game_variables[175][i])
          end
        elsif 49<val && val<85
          for i in 853..902
            allowedMons.push($game_variables[175][i])
          end
        elsif 71<val && val<92
          for i in 903..1270
            allowedMons.push($game_variables[175][i])
          end
        elsif 86<val
          for i in 1271..1554
            allowedMons.push($game_variables[175][i])
          end
          for i in 1893..1942
            allowedMons.push($game_variables[175][i])
          end
        elsif 100<val
          for i in 1555..1870
            allowedMons.push($game_variables[175][i])
          end
          for i in 1943..2058
            allowedMons.push($game_variables[175][i])
          end
        elsif 121<val 
          for i in 1871..1892
            allowedMons.push($game_variables[175][i])
          end
          for i in 2059..2082
            allowedMons.push($game_variables[175][i])
          end
        end
        ### BEANS ###
        num=rand(allowedMons.length)+1
        pkmn=allowedMons[num]
        #Kernel.pbMessage(allowedMons[0].species.to_s)
        #Kernel.pbMessage(allowedMons[1].species.to_s)
        #Kernel.pbMessage(allowedMons[2].species.to_s)
        #Kernel.pbMessage(allowedMons[3].species.to_s)
        #Kernel.pbMessage(allowedMons[39].species.to_s + " "+pkmn.species.to_s)
        #Kernel.pbMessage(allowedMons[40].species.to_s + " "+pkmn.species.to_s)
        #pkmn.species=(ChallengeChampionship.new).generatePokemon(randomint)
        #pkmn.name=PBSpecies.getName(pkmn.species)
        #pkmn.resetMoves
        #pkmn.calcStats

      opponent.party.push(pkmn)
    end
  end until rule.ruleset.isValid?(opponent.party)
  return opponent
end

def pbOrganizedBattleEx(opponent,challengedata,endspeech,endspeechwin)
  if !challengedata
    challengedata=PokemonChallengeRules.new
  end
  scene=pbNewBattleScene
  for i in 0...$Trainer.party.length
    $Trainer.party[i].heal if !$game_switches[329]
  end
  olditems=$Trainer.party.transform{|p| p.item }
  olditems2=$Trainer.party.transform{|p| p.item }
    if pbGet(1)==7
      opponent=pbLoadTrainerScaled(ChallengeChampionship.new.getTrainerClass,ChallengeChampionship.new.getTrainerName,5)[0]
      oppparty=pbLoadTrainerScaled(ChallengeChampionship.new.getTrainerClass,ChallengeChampionship.new.getTrainerName,5)[2]
         oldlevels=challengedata.adjustLevels($Trainer.party,oppparty)
     maxl = 49
      for poke in $Trainer.party
        if maxl < poke.level
            max1 = poke.level
        end
      end
#      Kernel.pbMessage("maxlevel "+maxl.to_s)
      for poke in oppparty
#      Kernel.pbMessage("lvl1 "+poke.level.to_s)
        poke.level=max1
#        Kernel.pbMessage("lvl2 "+poke.level.to_s)

        poke.calcStats
 #             Kernel.pbMessage("lvl3 "+poke.level.to_s)

      end
    else
    
    
        oldlevels=challengedata.adjustLevels($Trainer.party,opponent.party)
        oppparty=opponent.party
end
  battle=challengedata.createBattle(scene,$Trainer,opponent)#purrloin
#  battle.internalbattle=false
  battle.endspeech=endspeech
  battle.endspeechwin=endspeechwin
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    $PokemonTemp.lastbattle=nil
    return true
  end
          tempparty=oppparty
      for poke in oppparty
#      Kernel.pbMessage("lvl4 "+poke.level.to_s)
      end

  pbPrepareBattle(battle)
  for poke in oppparty
 #     Kernel.pbMessage("lvl5 "+poke.level.to_s)
      end
  decision=0
  trainerbgm=pbGetTrainerBattleBGM(opponent)
  pbBattleAnimation(trainerbgm) { 
      pbSceneStandby {
         decision=battle.pbStartBattle
      }
  }
  challengedata.unadjustLevels($Trainer.party,tempparty,oldlevels)
  for i in 0...$Trainer.party.length
    $Trainer.party[i].heal if !$game_switches[329]
    $Trainer.party[i].item=olditems[i]
  end
  for i in 0...tempparty.length
    tempparty[i].heal
    tempparty[i].item=olditems2[i]
  end
  Input.update
  if decision==1||decision==2||decision==5
    $PokemonTemp.lastbattle=battle.pbDumpRecord
  else
    $PokemonTemp.lastbattle=nil
  end
  return (decision==1)
end

def pbIsBanned?(pokemon)
  return StandardSpeciesRestriction.new.isValid?(pokemon)
end