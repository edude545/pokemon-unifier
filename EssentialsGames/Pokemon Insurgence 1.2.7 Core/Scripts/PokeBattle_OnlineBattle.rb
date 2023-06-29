# Results of battle:
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw
################################################################################
  class PokeBattle_Move
    def battle=(value)
      @battle=value
    end
  end

################################################################################
# Main battle class.
################################################################################
class PokeBattle_OnlineBattle
  attr_reader(:scene)             # Scene object for this battle
  attr_accessor(:decision)        # Decision: 0=undecided; 1=win; 2=loss; 3=escaped; 4=caught
  attr_accessor(:internalbattle)  # Internal battle flag
  attr_accessor(:doublebattle)    # Double battle flag
  attr_accessor(:cantescape)      # True if player can't escape
  attr_accessor(:shiftStyle)      # Shift/Set "battle style" option
  attr_accessor(:battlescene)     # "Battle scene" option
  attr_accessor(:debug)           # Debug flag
  attr_reader(:player)            # Player trainer
  attr_reader(:opponent)          # Opponent trainer
  attr_reader(:party1)            # Player's Pokémon party
  attr_accessor(:trickroom)
  attr_accessor(:TIEVAR)
  attr_accessor(:desolateland)
  attr_accessor(:primordialsea)
  attr_accessor(:deltastream)
  attr_accessor(:grassyterrain)
  attr_accessor(:mistyterrain)
  attr_accessor(:electricterrain)
  attr_accessor(:wonderroom)

  attr_reader(:party2)            # Foe's Pokémon party
  attr_accessor(:fullparty1)      # True if player's party's max size is 6 instead of 3
  attr_accessor(:fullparty2)      # True if opponent's party's max size is 6 instead of 3
  attr_reader(:battlers)          # Currently active Pokémon
  attr_accessor(:items)           # Items held by opponents
  attr_reader(:sides)             # Effects common to each side of a battle
  attr_accessor(:environment)     # Battle surroundings
  attr_accessor(:weather)         # Current weather, custom methods should use pbWeather instead
  attr_accessor(:weatherduration) # Duration of current weather, or -1 if indefinite
  attr_reader(:switching)         # True if during the switching phase of the round
  attr_accessor(:choices)         # Choices made by each Pokémon this round
  attr_reader(:successStates)     # Success states
  attr_accessor(:lastMoveUser)    # Last move user
  attr_accessor(:synchronize)     # Synchronize state
  attr_accessor(:amuletcoin)      # Whether Amulet Coin's effect applies
  attr_accessor(:extramoney)      # Money gained in battle by using Pay Day
  attr_accessor(:endspeech)       # Speech by opponent when player wins
  attr_accessor(:endspeech2)      # Speech by opponent when player wins
  attr_accessor(:endspeechwin)    # Speech by opponent when opponent wins
  attr_accessor(:endspeechwin2)   # Speech by opponent when opponent wins
  attr_accessor(:rules)
  attr_reader(:turncount)
  attr_accessor :controlPlayer
  include PokeBattle_BattleCommon
  
  MAXPARTYSIZE = 6

  class BattleAbortedException < Exception; end

  def pbAbort
    raise BattleAbortedException.new("Battle aborted")
  end

  def pbDebugUpdate
  end

  def pbRandom(x)
 #   return rand(x)
    if !@turnRandoms
      @turnRandoms=Array.new
      @turnRandoms=[1,2,3,4,5,6,7,8,9,10,11,12]
    end
    if !@randCount
      @randCount=0
    end
    
    if @turnRandoms.length<=@randCount
      @randCount=0
    end
    randVar=@turnRandoms[@randCount]
    @randCount += 1
    while 1==1 do
      if randVar >= x
        randVar -= x
      else
        break
      end
    end
   # Kernel.pbMessage(randVar.to_s)
    return randVar
  end
  
  

  def pbAIRandom(x)
    if @turnRandoms.length<=@randCount
      @randCount=0
    end
    randVar=@turnRandoms[@randCount]
    @randCount += 1
    while 1==1 do
      if randVar >= x
        randVar -= x
      else
        break
      end
    end
    return randVar
  end

################################################################################
# Initialise battle class.
################################################################################
  def initialize(scene,p1,p2,player,opponent)
    #            Kernel.pbMessage("4")
    @scene           = scene
 #   Kernel.pbMessage("5")
    @turncount=0
 #   Kernel.pbMessage("6")
    receive_seed
    if p1.length==0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
      return
    end
    if p2.length==0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
      return
    end
    if p2.length>2 && !opponent
      raise ArgumentError.new(_INTL("Wild battles with more than two Pokémon are not allowed."))
      return
    end

    @decision        = 0
    @internalbattle  = true
    @doublebattle    = false
    @cantescape      = false
    @shiftStyle      = true
    @battlescene     = true
    @debug           = false
    @debugupdate     = 0
    if opponent && player.is_a?(Array) && player.length==0
      player = player[0]
    end
    if opponent && opponent.is_a?(Array) && opponent.length==0
      opponent = opponent[0]
    end
#    Kernel.pbMessage("10")
    @player          = player                # PokeBattle_Trainer object
    @opponent        = opponent              # PokeBattle_Trainer object
    @party1          = p1
    @party2          = p2
    @fullparty1      = false
    @fullparty2      = false
    @battlers        = []
    @items           = nil
    @sides           = [PokeBattle_ActiveSide.new,   # Player's side
                        PokeBattle_ActiveSide.new]   # Foe's side
    @environment     = PBEnvironment::None   # e.g. Tall grass, cave, still water
    @weather         = 0
    @weatherduration = 0
        @trickroom=0
    @grassyterrain=0
    @electricterrain=0
       # Kernel.pbMessage("bitahh-4")

    @mistyterrain=0
    @wonderroom=0
    @primordialsea=false
    @deltastream=false
    @TIEVAR=nil
    @desolateland=false

    @switching       = false
    @choices         = [ [0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1] ]
    @successStates   = []
    for i in 0...4
      @successStates.push(PokeBattle_SuccessState.new)
    end
   #     Kernel.pbMessage("bitahh-3")

    @lastMoveUser    = -1
    @synchronize     = [-1,-1,0]
    @amuletcoin      = false
    @extramoney      = 0
    @endspeech       = ""
    @endspeech2      = ""
    @endspeechwin    = ""
    @endspeechwin2   = ""
    @rules           = {}
    @turncount       = 0
    @peer            = PokeBattle_BattlePeer.create()
    @priority        = []
        @player.megaforme = false
   $mega_battlers = Array.new
    @player.megaforme = false if !(@player.kind_of?(Array))
    @player[0].megaforme = false if (@player.kind_of?(Array))
    @player[1].megaforme = false if (@player.kind_of?(Array))
    #Kernel.pbMessage("bitahh-2")

    @usepriority     = false
    @snaggedpokemon  = []
    @runCommand      = 0
    if hasConst?(PBMoves,:STRUGGLE)
      @struggle = PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:STRUGGLE)))
    else
      @struggle = PokeBattle_Struggle.new(self,nil)
    end
    @struggle.pp     = -1
    for i in 0..3
      battlers[i] = PokeBattle_Battler.new(self,i)
    end
#        Kernel.pbMessage("bitahh-1")

    for i in @party1
      next if !i
      i.itemRecycle = 0
      i.itemInitial = i.item
    end
    for i in @party2
      next if !i
      i.itemRecycle = 0
      i.itemInitial = i.item
    end
    #Kernel.pbMessage("bitahh")
  end

################################################################################
# Info about battle.
################################################################################
  def pbDoubleBattleAllowed?
    if !@fullparty1 && @party1.length>MAXPARTYSIZE
      return false
    end
    if !@fullparty2 && @party2.length>MAXPARTYSIZE
      return false
    end
    _opponent=@opponent
    _player=@player
    if !_opponent
      if @party2.length==1
        return false
      elsif @party2.length==2
        return true
      else
        return false
      end
    else
      if _opponent.is_a?(Array)
        if _opponent.length==1
          _opponent=_opponent[0]
        elsif _opponent.length!=2
          return false
        end
      end
      _player=_player
      if _player.is_a?(Array)
        if _player.length==1
          _player=_player[0]
        elsif _player.length!=2
          return false
        end
      end
      if _opponent.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party2,0,pbSecondPartyBegin(1))
        sendout2=pbFindNextUnfainted(@party2,pbSecondPartyBegin(1))
        return false if sendout1<0 || sendout2<0
      else
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        return false if sendout1<0 || sendout2<0
      end
    end
    if _player.is_a?(Array)
      sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
      sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
      return false if sendout1<0 || sendout2<0
    else
      sendout1=pbFindNextUnfainted(@party1,0)
      sendout2=pbFindNextUnfainted(@party1,sendout1+1)
      return false if sendout1<0 || sendout2<0
    end
    return true
  end

  def pbWeather
    for i in 0...4
      if isConst?(@battlers[i].ability,PBAbilities,:CLOUDNINE) ||
         isConst?(@battlers[i].ability,PBAbilities,:AIRLOCK)
        return 0
      end
    end
    return @weather
  end

################################################################################
# Get battler info.
################################################################################
  def pbIsOpposing?(index)
    return (index%2)==1
  end

  def pbOwnedByPlayer?(index)
    return false if pbIsOpposing?(index)
    return false if @player.is_a?(Array) && index==2
    return true
  end

  def pbIsDoubleBattler?(index)
    return (index>=2)
  end

  def pbThisEx(battlerindex,pokemonindex)
    party=pbParty(battlerindex)
    if pbIsOpposing?(battlerindex)
      if @opponent
        return _INTL("The foe {1}",party[pokemonindex].name)
      else
        return _INTL("The wild {1}",party[pokemonindex].name)
      end
    else
      return _INTL("{1}",party[pokemonindex].name)
    end
  end
 def pbIsUnlosableItem(pkmn,item)
    return true if pbIsMail?(item)
    return false if pkmn.effects[PBEffects::Transform]
    if isConst?(pkmn.ability(true),PBAbilities,:MULTITYPE) &&
       (isConst?(item,PBItems,:FISTPLATE) ||
        isConst?(item,PBItems,:SKYPLATE) ||
        isConst?(item,PBItems,:TOXICPLATE) ||
        isConst?(item,PBItems,:EARTHPLATE) ||
        isConst?(item,PBItems,:STONEPLATE) ||
        isConst?(item,PBItems,:INSECTPLATE) ||
        isConst?(item,PBItems,:SPOOKYPLATE) ||
        isConst?(item,PBItems,:IRONPLATE) ||
        isConst?(item,PBItems,:FLAMEPLATE) ||
        isConst?(item,PBItems,:SPLASHPLATE) ||
        isConst?(item,PBItems,:MEADOWPLATE) ||
        isConst?(item,PBItems,:ZAPPLATE) ||
        isConst?(item,PBItems,:MINDPLATE) ||
        isConst?(item,PBItems,:ICICLEPLATE) ||
        isConst?(item,PBItems,:DRACOPLATE) ||
        isConst?(item,PBItems,:DRACOPLATE) ||
        isConst?(item,PBItems,:DRACOPLATE) ||
        isConst?(item,PBItems,:PIXIEPLATE) ||
        isConst?(item,PBItems,:DREADPLATE))
      return true
    end
    if  isConst?(item,PBItems,:MEWTWOMACHINE) ||
        isConst?(item,PBItems,:ZEKROMMACHINE) ||
        isConst?(item,PBItems,:TYRANITARMACHINE) ||
        isConst?(item,PBItems,:LEAVANNYMACHINE) ||
        isConst?(item,PBItems,:FLYGONMACHINE)
        return true
      end
      
=begin

=end
    if Kernel.pbGetMegaStoneList.include?(item)
        return true
      end
      
        

    if isConst?(pkmn.species,PBSpecies,:GIRATINA) &&
       isConst?(item,PBItems,:GRISEOUSORB)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GENESECT) &&
       (isConst?(item,PBItems,:SHOCKDRIVE) ||
        isConst?(item,PBItems,:BURNDRIVE) ||
        isConst?(item,PBItems,:CHILLDRIVE) ||
        isConst?(item,PBItems,:DOUSEDRIVE))
      return true
    end
    return false
  end
  
  def pbCheckGlobalAbility(a)
    for i in 0..3 # in order from own first, opposing first, own second, opposing second
      if @battlers[i].hp>0 && isConst?(@battlers[i].ability,PBAbilities,a)
        return @battlers[i]
      end
    end
    return nil
  end

################################################################################
# Player-related info.
################################################################################
  def pbPlayer
    if @player.is_a?(Array)
      return @player[0]
    else
      return @player
    end
  end

  def pbGetOwnerItems(battlerIndex)
    return [] if !@items
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @items[0] : @items[1]
      else
        return @items
      end
    else
      return []
    end
  end

  def pbSetSeen(pokemon)
    if pokemon && @internalbattle
      self.pbPlayer.seen[pokemon.species]=true
      pbSeenForm(pokemon)
    end
  end

################################################################################
# Get party info, manipulate parties.
################################################################################
  def pbPokemonCount(party)
    count=0
    for i in party
      next if !i
      count+=1 if i.hp>0 && !i.egg?
    end
    return count
  end

  def pbAllFainted?(party)
    pbPokemonCount(party)==0
  end

  def pbMaxLevel(party)
    lv=0
    for i in party
      next if !i
      lv=i.level if lv<i.level
    end
    return lv
  end

  def pbParty(index)
    return pbIsOpposing?(index) ? party2 : party1
  end

  def pbSecondPartyBegin(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return @fullparty2 ? 6 : 3
    else
      return @fullparty1 ? 6 : 3
    end
  end

  def pbFindNextUnfainted(party,start,finish=-1)
    finish=party.length if finish<0
    for i in start...finish
      next if !party[i]
      return i if party[i].hp>0 && !party[i].egg?
    end
    return -1
  end

  def pbFindPlayerBattler(pkmnIndex)
    battler=nil
    for k in 0...4
      if !pbIsOpposing?(k) && @battlers[k].pokemonIndex==pkmnIndex
        battler=@battlers[k]
        break
      end
    end
    return battler
  end

  def pbIsOwner?(battlerIndex,partyIndex)
    secondParty=pbSecondPartyBegin(battlerIndex)
    if !pbIsOpposing?(battlerIndex)
      return true if !@player || !@player.is_a?(Array)
      return (battlerIndex==0) ? partyIndex<secondParty : partyIndex>=secondParty
    else
      return true if !@opponent || !@opponent.is_a?(Array)
      return (battlerIndex==1) ? partyIndex<secondParty : partyIndex>=secondParty
    end
  end

  def pbGetOwner(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @opponent[0] : @opponent[1]
      else
        return @opponent
      end
    else
      if @player.is_a?(Array)
        return (battlerIndex==0) ? @player[0] : @player[1]
      else
        return @player
      end
    end
  end

  def pbGetOwnerPartner(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @opponent[1] : @opponent[0]
      else
        return @opponent
      end
    else
      if @player.is_a?(Array)
        return (battlerIndex==0) ? @player[1] : @player[0]
      else
        return @player
      end
    end
  end

  def pbPartyGetOwner(battlerIndex,partyIndex)
    secondParty=pbSecondPartyBegin(battlerIndex)
    if !pbIsOpposing?(battlerIndex)
      return @player if !@player || !@player.is_a?(Array)
      return (partyIndex<secondParty) ? @player[0] : @player[1]
    else
      return @opponent if !@opponent || !@opponent.is_a?(Array)
      return (partyIndex<secondParty) ? @opponent[0] : @opponent[1]
    end
  end

  def pbAddToPlayerParty(pokemon)
    party=pbParty(0)
    for i in 0...party.length
      party[i]=pokemon if pbIsOwner?(0,i) && !party[i]
    end
  end

  def pbRemoveFromParty(battlerIndex,partyIndex)
    party=pbParty(battlerIndex)
    side=(pbIsOpposing?(battlerIndex)) ? @opponent : @player
    party[partyIndex]=nil
    if !side || !side.is_a?(Array) # Wild or single opponent
      party.compact!
      for i in battlerIndex...party.length
        for j in 0..3
          next if !@battlers[j]
          if pbGetOwner(j)==side && @battlers[j].pokemonIndex==i
            @battlers[j].pokemonIndex-=1
            break
          end
        end
      end
    else
      if battlerIndex<pbSecondPartyBegin(battlerIndex)-1
        for i in battlerIndex...pbSecondPartyBegin(battlerIndex)
          if i>=pbSecondPartyBegin(battlerIndex)-1
            party[i]=nil
          else
            party[i]=party[i+1]
          end
        end
      else
        for i in battlerIndex...party.length
          if i>=party.length-1
            party[i]=nil
          else
            party[i]=party[i+1]
          end
        end
      end
    end
  end

################################################################################
# Check whether actions can be taken.
################################################################################
  def pbCanShowCommands?(idxPokemon)
    thispkmn=@battlers[idxPokemon]
    return false if thispkmn.hp<=0
    return false if thispkmn.effects[PBEffects::TwoTurnAttack]>0
    return false if thispkmn.effects[PBEffects::HyperBeam]>0
    return false if thispkmn.effects[PBEffects::Rollout]>0
    return false if thispkmn.effects[PBEffects::Outrage]>0
    return false if thispkmn.effects[PBEffects::Uproar]>0
    return false if thispkmn.effects[PBEffects::Bide]>0
    return true
  end

################################################################################
# Attacking.
################################################################################
  def pbCanShowFightMenu?(idxPokemon)
    thispkmn=@battlers[idxPokemon]
    if !pbCanShowCommands?(idxPokemon)
      return false
    end
    # No moves that can be chosen
    if !pbCanChooseMove?(idxPokemon,0,false) &&
       !pbCanChooseMove?(idxPokemon,1,false) &&
       !pbCanChooseMove?(idxPokemon,2,false) &&
       !pbCanChooseMove?(idxPokemon,3,false)
      return false
    end
    # Encore
    return false if thispkmn.effects[PBEffects::Encore]>0
    return true
  end

  def pbCanChooseMove?(idxPokemon,idxMove,showMessages)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    opp1=thispkmn.pbOpposing1
    opp2=thispkmn.pbOpposing2
    if !thismove||thismove.id==0
      return false
    end
    if thismove.pp<=0 && thismove.totalpp>0
      if showMessages
        pbDisplayPaused(_INTL("There's no PP left for this move!"))
      end
      return false
    end
    if thismove.id==PBMoves::CUSTOMMOVE
            if showMessages
        pbDisplayPaused(_INTL("Custom Moves cannot be used online."))
        
      end
      return false
    end
    if thispkmn.effects[PBEffects::ChoiceBand]>=0 &&
      (isConst?(thispkmn.item,PBItems,:CHOICEBAND) ||
      isConst?(thispkmn.item,PBItems,:CHOICESPECS) ||
      isConst?(thispkmn.item,PBItems,:CHOICESCARF))
      hasmove=false
      for i in 0...4
        if thispkmn.moves[i].id==thispkmn.effects[PBEffects::ChoiceBand]
          hasmove=true
          break
        end
      end
      if hasmove && thismove.id!=thispkmn.effects[PBEffects::ChoiceBand]
        if showMessages
          pbDisplayPaused(_INTL("{1} allows the use of only {2}!",
             PBItems.getName(thispkmn.item),
             PBMoves.getName(thispkmn.effects[PBEffects::ChoiceBand])))
        end
        return false
      end
    end
    if opp1.effects[PBEffects::Imprison]
      if thismove.id==opp1.moves[0].id ||
         thismove.id==opp1.moves[1].id ||
         thismove.id==opp1.moves[2].id ||
         thismove.id==opp1.moves[3].id
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the sealed {2}!",thispkmn.pbThis,thismove.name))
        end
       #PBDebug.log("[CanChoose][#{opp1.pbThis} has: #{opp1.moves[0].name}, #{opp1.moves[1].name},#{opp1.moves[2].name},#{opp1.moves[3].name}]")
        return false
      end
    end
    if opp2.effects[PBEffects::Imprison]
      if thismove.id==opp2.moves[0].id ||
         thismove.id==opp2.moves[1].id ||
         thismove.id==opp2.moves[2].id ||
         thismove.id==opp2.moves[3].id
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the sealed {2}!",thispkmn.pbThis,thismove.name))
        end
        #PBDebug.log("[CanChoose][#{opp2.pbThis} has: #{opp2.moves[0].name}, #{opp2.moves[1].name},#{opp2.moves[2].name},#{opp2.moves[3].name}]")
        return false
      end
    end
    if thispkmn.effects[PBEffects::Taunt]>0 && thismove.basedamage==0
      if showMessages
        pbDisplayPaused(_INTL("{1} can't use {2} after the Taunt!",thispkmn.pbThis,thismove.name))
      end
      return false
    end
    if thispkmn.effects[PBEffects::Torment]
      if thismove.id==thispkmn.lastMoveUsed
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the same move in a row due to the torment!",thispkmn.pbThis))
        end
        return false
      end
    end
    if thismove.id==thispkmn.effects[PBEffects::DisableMove]
      if showMessages
        pbDisplayPaused(_INTL("{1}'s {2} is disabled!",thispkmn.pbThis,thismove.name))
      end
      return false
    end
    
    if isConst?(thismove.id,PBMoves,:SUCKERPUNCH)
  #    Kernel.pbMessage("yap")
      thispkmn.effects[PBEffects::SuckerPunch]=true
    end
      thispkmn.effects[PBEffects::LastResort][idxMove]=true

    
    if thispkmn.effects[PBEffects::Encore]>0 && idxMove!=thispkmn.effects[PBEffects::EncoreIndex]
      return false
    end
    return true
  end

  def pbAutoChooseMove(idxPokemon,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    if thispkmn.hp<=0
      @choices[idxPokemon][0]=0
      @choices[idxPokemon][1]=0
      @choices[idxPokemon][2]=nil
      return
    end
    if thispkmn.effects[PBEffects::Encore]>0 && 
       pbCanChooseMove?(idxPokemon,thispkmn.effects[PBEffects::EncoreIndex],false)
      PBDebug.log("[Auto choosing Encore move...]")
      @choices[idxPokemon][0]=1    # "Use move"
      @choices[idxPokemon][1]=thispkmn.effects[PBEffects::EncoreIndex] # Index of move
      @choices[idxPokemon][2]=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
      @choices[idxPokemon][3]=-1   # No target chosen yet
      if @doublebattle
        thismove=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
        target=thispkmn.pbTarget(thismove)
        if target==PBTargets::SingleNonUser
          target=@scene.pbChooseTarget(idxPokemon)
          pbRegisterTarget(idxPokemon,target) if target>=0
        elsif target==PBTargets::UserOrPartner
          target=@scene.pbChooseTarget(idxPokemon)
          pbRegisterTarget(idxPokemon,target) if target>=0 && (target&1)==(idxPokemon&1)
        end
      end
    else
      if !pbIsOpposing?(idxPokemon)
        pbDisplayPaused(_INTL("{1} has no moves left!",thispkmn.name)) if showMessages
      end
      @choices[idxPokemon][0]=1           # "Use move"
      @choices[idxPokemon][1]=-1          # Index of move to be used
      @choices[idxPokemon][2]=@struggle   # Use Struggle
      @choices[idxPokemon][3]=-1          # No target chosen yet
    end
  end

  def pbRegisterMove(idxPokemon,idxMove,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    return false if !pbCanChooseMove?(idxPokemon,idxMove,showMessages)
    @choices[idxPokemon][0]=1         # "Use move"
    @choices[idxPokemon][1]=idxMove   # Index of move to be used
    @choices[idxPokemon][2]=thismove  # PokeBattle_Move object of the move
    @choices[idxPokemon][3]=-1        # No target chosen yet
    return true
  end

  def pbChoseMove?(i,move)
    return false if @battlers[i].hp<=0
    if @choices[i][0]==1 && @choices[i][1]>=0
      choice=@choices[i][1]
      return isConst?(@battlers[i].moves[choice].id,PBMoves,move)
    end
    return false
  end
def pbChoseMove2?(i,move)
    return false if @battlers[i].hp<=0
    if @choices[i][0]==1 && @choices[i][1]>=0
      choice=@choices[i][1]
      return @battlers[i].moves[choice].id==move
    end
    return false
  end
  def pbChoseMoveFunctionCode?(i,code)
    return false if @battlers[i].hp<=0
    if @choices[i][0]==1 && @choices[i][1]>=0
      choice=@choices[i][1]
      return @battlers[i].moves[choice].function==code
    end
    return false
  end

  def pbRegisterTarget(idxPokemon,idxTarget)
    @choices[idxPokemon][3]=idxTarget   # Set target of move
    return true
  end

  def pbPriority
    if @usepriority
      # use stored priority if round isn't over yet
      return @priority
    end
    speeds=[]
    quickclaw=[]
    priorities=[]
    temp=[]
    @priority.clear
    maxpri=0
    minpri=0
    # Calculate each Pokémon's speed
    speeds[0]=@battlers[0].pbSpeed
    speeds[1]=@battlers[1].pbSpeed
    speeds[2]=@battlers[2].pbSpeed
    speeds[3]=@battlers[3].pbSpeed
    quickclaw[0]=isConst?(@battlers[0].item,PBItems,:QUICKCLAW)
    quickclaw[1]=isConst?(@battlers[1].item,PBItems,:QUICKCLAW)
    quickclaw[2]=isConst?(@battlers[2].item,PBItems,:QUICKCLAW)
    quickclaw[3]=isConst?(@battlers[3].item,PBItems,:QUICKCLAW)
    # Find the maximum and minimum priority
    for i in 0..3
      # For this function, switching and using items
      # is the same as using a move with a priority of 0
      pri=0
      if @choices[i][0]==1 # Is a move
        pri=@choices[i][2].priority
        pri+=1 if isConst?(@battlers[i].ability,PBAbilities,:PRANKSTER) &&
                  @choices[i][2].basedamage==0 # Is status move
         pri+=1 if isConst?(@battlers[i].ability,PBAbilities,:GALEWINGS) &&
                  isConst?(@choices[i][2].type,PBTypes,:FLYING) # Is gale wings
     end
      priorities[i]=pri
      if i==0
        maxpri=pri
        minpri=pri
      else
        maxpri=pri if maxpri<pri
        minpri=pri if minpri>pri
      end
    end
    # Find and order all moves with the same priority
    curpri=maxpri
    loop do
      temp.clear
      for j in 0..3
        if priorities[j]==curpri
          temp[temp.length]=j
        end
      end
      # Sort by speed
      if temp.length==1
        @priority[@priority.length]=@battlers[temp[0]]
      else
        n=temp.length
        usequickclaw=(pbRandom(5)==0)
        for m in 0..n-2
          for i in 1..n-1
            if quickclaw[temp[i]] && usequickclaw
              cmp=(quickclaw[temp[i-1]]) ? 0 : -1 #Rank higher if without Quick Claw, or equal if with it
            elsif quickclaw[temp[i-1]] && usequickclaw
              cmp=1 # Rank lower
            elsif speeds[temp[i]]!=speeds[temp[i-1]]
              cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? -1 : 1 #Rank higher to higher-speed battler
            else
              cmp=0
            end
            if cmp<0  && @trickroom==0
              # put higher-speed Pokémon first
              swaptmp=temp[i]
              temp[i]=temp[i-1]
              temp[i-1]=swaptmp
                          elsif cmp>0 && @trickroom>0
                            swaptmp=temp[i]
              temp[i]=temp[i-1]
              temp[i-1]=swaptmp

            elsif cmp==0
              if @battlers[0].pokemon != nil && @battlers[1].pokemon != nil
 #               Kernel.pbMessage(@battlers[0].pokemon.trainerID.to_s)
#                Kernel.pbMessage(@battlers[1].pokemon.trainerID.to_s)
                
                if @TIEVAR==1
              #    Kernel.pbMessage("1")
                swaptmp=temp[i]
                temp[i]=temp[i-1]
                temp[i-1]=swaptmp
                  end
              end
=begin
              # swap at random if speeds are equal
                if pbOwnedByPlayer?(pbRandom(2))
                swaptmp=temp[i]
                temp[i]=temp[i-1]
                temp[i-1]=swaptmp
=end
             # end
            end
          end
        end
        #Now add the temp array to priority
        for i in temp
          @priority[@priority.length]=@battlers[i]
        end
      end
      curpri-=1
      break unless curpri>=minpri
    end
=begin
    prioind=[
       @priority[0].index,
       @priority[1].index,
       @priority[2] ? @priority[2].index : -1,
       @priority[3] ? @priority[3].index : -1
    ]
    print("#{speeds.inspect} #{prioind.inspect}")
=end
    @usepriority=true
    return @priority
  end

################################################################################
# Switching Pokémon.
################################################################################
  def pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
    if pkmnidxTo>=0
      party=pbParty(idxPokemon)
      if pkmnidxTo>=party.length
        return false
      end
      if !party[pkmnidxTo]
        return false
      end
      if party[pkmnidxTo].egg?
        pbDisplayPaused(_INTL("An Egg can't battle!")) if showMessages 
        return false
      end
      if !pbIsOwner?(idxPokemon,pkmnidxTo)
        owner=pbPartyGetOwner(idxPokemon,pkmnidxTo)
        pbDisplayPaused(_INTL("You can't switch {1}'s Pokémon with one of yours!",owner.name)) if showMessages 
        return false
      end
      if party[pkmnidxTo].hp<=0
        pbDisplayPaused(_INTL("{1} has no energy left to battle!",party[pkmnidxTo].name)) if showMessages 
        return false
      end   
      if @battlers[idxPokemon].pokemonIndex==pkmnidxTo
        pbDisplayPaused(_INTL("{1} is already in battle!",party[pkmnidxTo].name)) if showMessages 
        return false
      end
      if @battlers[idxPokemon].pbPartner.pokemonIndex==pkmnidxTo
        pbDisplayPaused(_INTL("{1} is already in battle!",party[pkmnidxTo].name)) if showMessages 
        return false
      end
    end
    return true
  end

  def pbCanSwitch?(idxPokemon,pkmnidxTo,showMessages)
    thispkmn=@battlers[idxPokemon]
    # Multi-Turn Attacks/Mean Look
    if !pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
      return false
    end
    isOpposing=pbIsOpposing?(idxPokemon)
    party=pbParty(idxPokemon)
    for i in 0...4
      next if isOpposing!=pbIsOpposing?(i)
      if choices[i][0]==2 && choices[i][1]==pkmnidxTo
        pbDisplayPaused(_INTL("{1} has already been selected.",party[pkmnidxTo].name)) if showMessages 
        return false
      end
    end
    if isConst?(thispkmn.item,PBItems,:SHEDSHELL)
      return true
    end
    if thispkmn.effects[PBEffects::MultiTurn]>0 ||
       thispkmn.effects[PBEffects::MeanLook]>=0
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    # Ingrain
    if thispkmn.effects[PBEffects::Ingrain]
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    opp1=thispkmn.pbOpposing1
    opp2=thispkmn.pbOpposing2
    opp=nil
    if thispkmn.pbHasType?(:STEEL)
      opp=opp1 if isConst?(opp1.ability,PBAbilities,:MAGNETPULL) && opp1.hp>0
      opp=opp2 if isConst?(opp2.ability,PBAbilities,:MAGNETPULL) && opp2.hp>0
    end
    if isConst?(thispkmn.item,PBItems,:IRONBALL) ||
       thispkmn.effects[PBEffects::Ingrain] ||
       thispkmn.effects[PBEffects::SmackDown] ||
       thispkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
       thispkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
       !(thispkmn.pbHasType?(:FLYING) ||
         isConst?(thispkmn.ability,PBAbilities,:LEVITATE) ||
         isConst?(thispkmn.item,PBItems,:AIRBALLOON) ||
         thispkmn.effects[PBEffects::MagnetRise]>0 ||
         thispkmn.effects[PBEffects::Telekinesis]>0)
      opp=opp1 if isConst?(opp1.ability,PBAbilities,:ARENATRAP) && opp1.hp>0
      opp=opp2 if isConst?(opp2.ability,PBAbilities,:ARENATRAP) && opp2.hp>0
    end
    if !isConst?(thispkmn.ability,PBAbilities,:SHADOWTAG)
      opp=opp1 if isConst?(opp1.ability,PBAbilities,:SHADOWTAG) && opp1.hp>0
      opp=opp2 if isConst?(opp2.ability,PBAbilities,:SHADOWTAG) && opp2.hp>0
    end
    if opp
      abilityname=PBAbilities.getName(opp.ability)
      pbDisplayPaused(_INTL("{1}'s {2} prevents switching!",opp.pbThis,abilityname)) if showMessages
      return false
    end
    return true
  end

  def pbRegisterSwitch(idxPokemon,idxOther)
    thispkmn=@battlers[idxPokemon]
    if !pbCanSwitch?(idxPokemon,idxOther,false)
      return false
    else
      @choices[idxPokemon][0]=2          # "Switch Pokémon"
      @choices[idxPokemon][1]=idxOther   # Index of other Pokémon to switch with
      @choices[idxPokemon][2]=nil
          $mega_battlers[idxPokemon]=false

      return true
    end
  end
    def pbCanMegaEvolve?(index)
  #    return false if index > -1
   # return false if $game_switches[NO_MEGA_EVOLUTION]
#   if Kernel.pbGetMegaSpeciesList.include?(@battlers[i].species) && Kernel.pbGetMegaStoneList.include?(@battlers[i].item)
#          if Kernel.pbGetMegaStoneList.index(@battlers[i].item)==Kernel.pbGetMegaSpeciesList.index(@battlers[i].species)
            canMega3=true if Kernel.pbGetMegaSpeciesStoneWorks(@battlers[i].species,@battlers[i].item)
#          end
#        end
        
       if @battlers[i].species==PBSpecies::RAYQUAZA
        rayq=false
           canMega3=true if @battlers[i].moves[0].id==PBMoves::DRAGONSASCENT
           canMega3=true if @battlers[i].moves[1].id==PBMoves::DRAGONSASCENT
           canMega3=true if @battlers[i].moves[2].id==PBMoves::DRAGONSASCENT
           canMega3=true if @battlers[i].moves[3].id==PBMoves::DRAGONSASCENT
  end 
   return false if !canMega3

    return false if @player.megaforme
    return true
  end

  def pbMegaEvolve(index,primal=false)
  $tempDoubleMega=nil
    if @player.is_a?(Array)
        playervar = @player[0]
      else
        playervar = @player
      end
    ownername=pbGetOwner(index).name #
    megaObject="Ring"
    megaObject="Bong" if !pbOwnedByPlayer?(index) && ownername=="Xavier"
    megaObject="Cane" if pbIsOpposing?(index) && ownername=="East"
    megaObject="Necklace" if pbIsOpposing?(index) && ownername=="Harmony"
    megaObject="Device" if pbIsOpposing?(index) && ownername=="Anastasia"
    megaObject="Pendant" if pbIsOpposing?(index) && ownername=="Diana"
    megaObject="Glove" if pbIsOpposing?(index) && ownername=="Calreath"
    megaObject="Ring" if pbIsOpposing?(index) && ownername=="Adam"
    megaObject="Ring" if pbIsOpposing?(index) && ownername=="Persephone"
    megaObject="Belt" if pbIsOpposing?(index) && ownername=="Zenith"
    megaObject="Ring" if pbIsOpposing?(index) && ownername=="Taen"
    megaObject="Ring" if pbIsOpposing?(index) && ownername=="Reukra"
    megaObject="Charm" if pbIsOpposing?(index) && ownername=="Yuki"
    megaObject="Mixtape" if pbIsOpposing?(index) && ownername=="Darude"
    megaObject="Ankh" if pbIsOpposing?(index) && ownername=="Kayla"
    megaObject="Band" if pbIsOpposing?(index) && ownername=="London"
    megaObject="Bracelet" if pbIsOpposing?(index) && ownername=="Audrey"
    megaObject="Ring" if pbIsOpposing?(index) && ownername=="Damian"
    megaObject="Ring" if pbIsOpposing?(index) && ownername=="Nora"
    megaObject="Crown" if pbIsOpposing?(index) && ownername=="Jaern"
    megaObject="Crystal" if pbIsOpposing?(index) && ownername=="Nyx"
    megaObject="Core" if pbIsOpposing?(index) && ownername=="Malde"
    illusionStatus=!(@battlers[index].ability!=PBAbilities::ILLUSION || $illusion == nil || (!$illusion.is_a?(Array) && $illusion[index] == nil))
    if illusionStatus && pbIsOpposing?(index)
      $illusionpoke = @party2[@party2.length-1]# if isConst?(pokemon.ability,PBAbilities,:ILLUSION)
    end
    pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s Mega "+megaObject+"!",
       @battlers[index].pbThis,
       PBItems.getName(@battlers[index].item(true)),
       ownername)) if !primal && !isConst?(@battlers[index].pokemon.species,PBSpecies,:RAYQUAZA) && !illusionStatus
    pbDisplay(_INTL("{1} is reacting to its {2}!",@battlers[index].pbThis,
       PBItems.getName(@battlers[index].item(true)))) if primal && !isConst?(@battlers[index].pokemon.species,PBSpecies,:DELTAMETAGROSS2) 
       
                  pbDisplay(_INTL("{1} began to crystallize!",@battlers[index].pbThis)) if primal && isConst?(@battlers[index].pokemon.species,PBSpecies,:DELTAMETAGROSS2) 

       
    pbDisplay(_INTL("{1}'s prayers reached {2}!",ownername,
       @battlers[index].pbThis)) if pbOwnedByPlayer?(index) && isConst?(@battlers[index].pokemon.species,PBSpecies,:RAYQUAZA) 
    pbDisplay(_INTL("{2} was reached by {1}'s prayers!",ownername,
       @battlers[index].pbThis)) if !pbOwnedByPlayer?(index) && isConst?(@battlers[index].pokemon.species,PBSpecies,:RAYQUAZA) 

       # Mega Zoroark's ability to fake other megas.
   #    Kernel.pbMessage($illusionpoke.species.to_s)
       if illusionStatus && Kernel.pbGetMegaSpeciesList.include?($illusionpoke.species)
        theirFakeStone=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index($illusionpoke.species)]
  #     Kernel.pbMessage(PBItems.getName(theirFakeStone))
        pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s Mega "+megaObject+"!",
             @battlers[index].pbThis,
             PBItems.getName(theirFakeStone),
             ownername)) if illusionStatus

           end
                 playervar.megaforme=true if pbOwnedByPlayer?(index)
    if !pbIsOpposing?(index) && !(#isConst?(@battlers[index].pokemon.species,PBSpecies,:STEELIX) || 
      isConst?(@battlers[index].pokemon.species,PBSpecies,:DELTACHARIZARD))# ||
      $mega_transfer = true
    end

           zoroarkopp = false
    zoroarkopp = true if !pbOwnedByPlayer?(index) && $illusion != nil && $illusion.is_a?(Array) && $illusion[index] != nil #&& isConst?(@battlers[index].pokemon.species,PBSpecies,:ZOROARK)
    @battlers[index].isMZO=true if zoroarkopp

       #TEMPMEGASLOT
       if zoroarkopp && $illusionpoke #&& !Kernel.pbGetMegaSpeciesList($illusionpoke.species)#      @battlers[index].pokemon.form=1
        #Kernel.pbMessage("1")    
        saveform=@battlers[index].pokemon.form
         @battlers[index].pokemon.form=1
                 @battlers[index].pokemon.form=2 if isConst?(@battlers[index].species,PBSpecies,:DELTAMETAGROSS2) && primal

         @battlers[index].pokemon.form=2 if isConst?(@battlers[index].item,PBItems,:CHARIZARDITEY) || isConst?(@battlers[index].item,PBItems,:MEWTWONITEX) || isConst?(@battlers[index].item,PBItems,:FLYGONITE)
        @battlers[index].pokemon.form=2 if isConst?(@battlers[index].item,PBItems,:STEELIXITE)
          @battlers[index].pokemon.form=3 if isConst?(@battlers[index].item,PBItems,:MEWTWONITEY)
         @battlers[index].pokemon.form=2 if isConst?(@battlers[index].species,PBSpecies,:GIRATINA)
       @battlers[index].pokemon.form=18 if isConst?(@battlers[index].species,PBSpecies,:ARCEUS)
        @battlers[index].pokemon.form=5 if saveform==4 && isConst?(@battlers[index].species,PBSpecies,:MEWTWO)
              $mega_transfer = true if pbIsOpposing(index) && isConst?(@battlers[index].pokemon.species,PBSpecies,:MAGMORTAR)

         else
           pbHiddenMoveAnimation(@battlers[index].pokemon,true,zoroarkopp)
       end
       
       #TEMPMEGASLOT
#       Kernel.pbMessage("ahhhh")
#      @scene.pbMoveAnimation("Mega2",@battlers[index],nil) #if $illusion == nil || !$illusion.is_a?(Array) && $illusion[index]
#      @battlers[index].pokemon.form=1
#      @battlers[index].pokemon.form=2 if isConst?(@battlers[index].item,PBItems,:CHARIZARDITEY) || isConst?(@battlers[index].item,PBItems,:MEWTWONITEX) || isConst?(@battlers[index].item,PBItems,:FLYGONITE)
#      @battlers[index].pokemon.form=3 if isConst?(@battlers[index].item,PBItems,:MEWTWONITEY)
#    $mega_transfer = true if pbIsOpposing(index) && isConst?(@battlers[index].pokemon.species,PBSpecies,:MAGMORTAR)
    @battlers[index].pbCheckForm(zoroarkopp)
    pbDisplay(_INTL("Pierce the heavens with your drill!")) if isConst?(@battlers[index].pokemon.species,PBSpecies,:GOLURK)

    side=(pbIsOpposing?(index)) ? 1 : 0
    $mega_battlers[index]=false
     @battlers[index].pbAbilitiesOnSwitchIn(true)
     
       if isConst?(@battlers[index].pokemon.species,PBSpecies,:KYOGRE)
      @weather=PBWeather::RAINDANCE
      @weatherduration=-1
      @primordialsea=true
      pbDisplay(_INTL("{1}'s Primordial Sea caused a heavy rain to fall.",@battlers[index].pbThis))
         @scene.pbBackdropMove(0,true,true)
       end
      if isConst?(@battlers[index].pokemon.species,PBSpecies,:SUNFLORA)
       var=0
       for poke in pbParty(index)
         var+=1 if poke.hp<1
       end
       if var<1
         pbDisplay(_INTL("{1} is calm.",@battlers[index].pbThis))
       else
         @battlers[index].pbIncreaseStatBasic(PBStats::SPEED,1)
         @battlers[index].pbIncreaseStatBasic(PBStats::ATTACK,1)
         @battlers[index].pbIncreaseStatBasic(PBStats::DEFENSE,1)
         @battlers[index].pbIncreaseStatBasic(PBStats::SPATK,1)
         @battlers[index].pbIncreaseStatBasic(PBStats::SPDEF,1)
         @battlers[index].effects[PBEffects::Unleafed]=var
         @battlers[index].pokemon.form += 2
         @battlers[index].pbCheckForm
         pbDisplay(_INTL("Enraged, {1} Unleafed its power!.",@battlers[index].pbThis))
       end
       
     end
      if isConst?(@battlers[index].pokemon.species,PBSpecies,:DELTASUNFLORA)
     #    @battlers[index].pbIncreaseStatBasic(PBStats::SPEED,1)
         @battlers[index].pbIncreaseStatBasic(PBStats::SPATK,1)
         pbDisplay(_INTL("{1} is furious!",@battlers[index].pbThis))

       
     end
     
       if isConst?(@battlers[index].pokemon.species,PBSpecies,:GROUDON)
         @weather=PBWeather::SUNNYDAY
      @weatherduration=-1
            @desolateland=true

      pbDisplay(_INTL("{1}'s Desolate Land made the sun turn harsh!",@battlers[index].pbThis))
         @scene.pbBackdropMove(0,true,true)
       end
       if isConst?(@battlers[index].pokemon.species,PBSpecies,:RAYQUAZA)
         @deltastream=true
         @weather=0

          pbDisplay(_INTL("A mysterious air current is protecting Flying-type Pokemon!"))
         @scene.pbBackdropMove(0,true,true)
       end
       
     
     
  end

  
  
=begin


















=end


  def pbCanChooseNonActive?(index)
    party=pbParty(index)
    for i in 0..party.length-1
      return true if pbCanSwitchLax?(index,i,false)
    end
    return false
  end

  def pbSwitch(favorDraws=false)
    if !favorDraws
      return if @decision>0
      pbJudge()
      return if @decision>0
    else
      return if @decision==5
      pbJudge()
      return if @decision>0
    end
    firstbattlerhp=@battlers[0].hp
    switched=[]
    oneByYou=-1
    oneByOpponent=-1
    for index in 0..4
      next if !@doublebattle && pbIsDoubleBattler?(index)
      next if @battlers[index] && @battlers[index].hp>0
      next if !pbCanChooseNonActive?(index)
      oneByYou=index if pbOwnedByPlayer?(index)
      oneByOpponent=index if !pbOwnedByPlayer?(index)
    end
    
    if oneByYou!=-1 && oneByOpponent!=-1

       meIsFaster=false
       if @battlers[oneByYou].speed>@battlers[oneByOpponent].speed
            meIsFaster=true
          elsif @battlers[oneByYou].speed>@battlers[oneByOpponent].speed
            if @battlers[oneByYou].trainerID>@battlers[oneByOpponent].trainerID
              meIsFaster=true
            end
        end
  #     Kernel.pbMessage("I'm faster") if meIsFaster
   #    Kernel.pbMessage("I'm slower") if !meIsFaster
       indexAry=[0,1,2,3] if meIsFaster
       indexAry=[1,0,3,2] if !meIsFaster
    else
        indexAry=[0,1,2,3,4]
    end
    for index in indexAry
          next if !@doublebattle && pbIsDoubleBattler?(index)
          next if @battlers[index] && @battlers[index].hp>0
          next if !pbCanChooseNonActive?(index)
          if !pbOwnedByPlayer?(index)
            if @opponent
               newenemy = waitnewenemy
               $network.send("<BAT\tnew=-1>")
               pbRecallAndReplace(index,newenemy)
               switched.push(index)
            end
          elsif @opponent
               newpoke=pbSwitchInBetween(index,true,false)
               $network.send("<BAT\tnew=#{newpoke}>")
               waitnewenemy
               pbRecallAndReplace(index,newpoke)
               switched.push(index)
          else
            switch=false
            if !pbDisplayConfirm(_INTL("Use next Pokémon?")) 
              switch=(pbRun(index,true)<=0)
            else
              switch=true
            end
            if switch
              newpoke=pbSwitchInBetween(index,true,false)
              pbRecallAndReplace(index,newpoke)
              switched.push(index)
            end
          end
    end
    if switched.length>0
      priority=pbPriority
      for i in priority
        i.pbAbilitiesOnSwitchIn(true) if switched.include?(i.index)
      end
    end
    end

  def pbSendOut(index,pokemon)
#    Kernel.pbMessage("!")
    pbSetSeen(pokemon)
    @peer.pbOnEnteringBattle(self,pokemon)   

    if !pbIsOpposing?(index)
       $illusionpoke = @party1[@party1.length-1] if isConst?(pokemon.ability,PBAbilities,:ILLUSION)
     end
    if pbIsOpposing?(index)
      $illusionpoke = @party2[@party2.length-1] if isConst?(pokemon.ability,PBAbilities,:ILLUSION)
      @scene.pbTrainerSendOut(index,pokemon,false)
  #    @scene.pbTrainerSendOut(index,pokemon)
    else
      @scene.pbSendOut(index,pokemon)
    end

  end

  def pbReplace(index,newpoke,batonpass=false)
    party=pbParty(index)
    if @battlers[index].species==PBSpecies::KYOGRE && @battlers[index].item==PBItems::BLUEORB #&& party[newpoke].ability!=PBAbilities::PRIMORDIALSEA
      @primordialsea=false
      @weather=0
        pbDisplayBrief("The heavy rain relented.",!$is_insane)
    end
    if @battlers[index].species==PBSpecies::GROUDON && @battlers[index].item==PBItems::REDORB #&& party[newpoke].ability!=PBAbilities::DESOLATELAND
      @desolateland=false
      @weather=0
        pbDisplayBrief("The harsh sunlight faded.",!$is_insane)
      end
      if @battlers[index].ability==PBSpecies::RAYQUAZA && @battlers[index].form>0 #&& party[newpoke].ability!=PBAbilities::DELTASTREAM
      @deltastream=false
        pbDisplayBrief("The air current faded.",!$is_insane)
    end
    if pbOwnedByPlayer?(index)
            newpoke=newpoke[0] if newpoke.is_a?(Array)

      @battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      pbSendOut(index,party[newpoke])
    else
      newpoke=newpoke[0] if newpoke.is_a?(Array)
      @battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      pbSetSeen(party[newpoke])
      if pbIsOpposing?(index)
        pbSendOut(index,party[newpoke])
      else
        pbSendOut(index,party[newpoke])
      end
    end
  end

  def pbRecallAndReplace(index,newpoke,batonpass=false)
    @battlers[index].pbResetForm
    if @battlers[index].hp>0
      @scene.pbRecall(index)
    end
    newpoke=newpoke[0] if newpoke.is_a?(Array)
    pbMessagesOnReplace(index,newpoke)
    pbReplace(index,newpoke,batonpass)
    return pbOnActiveOne(@battlers[index])
  end

  def pbMessagesOnReplace(index,newpoke)
    party=pbParty(index)
    if pbOwnedByPlayer?(index)
#     if !party[newpoke]
#       p [index,newpoke,party[newpoke],pbAllFainted?(party)]
#       PBDebug.log([index,newpoke,party[newpoke],"pbMOR"].inspect)
#       for i in 0...party.length
#         PBDebug.log([i,party[i].hp].inspect)
#       end
#       raise BattleAbortedException.new
#     end
      opposing=@battlers[index].pbOppositeOpposing
      if opposing.hp<=0 || opposing.hp==opposing.totalhp
        pbDisplayBrief(_INTL("Go! {1}!",party[newpoke].name))
      elsif opposing.hp>=(opposing.totalhp/2)
        pbDisplayBrief(_INTL("Do it! {1}!",party[newpoke].name))
      elsif opposing.hp>=(opposing.totalhp/4)
        pbDisplayBrief(_INTL("Go for it, {1}!",party[newpoke].name))
      else
        pbDisplayBrief(_INTL("Your foe's weak!\nGet 'em, {1}!",party[newpoke].name))
      end
    else
#     if !party[newpoke]
#       p [index,newpoke,party[newpoke],pbAllFainted?(party)]
#       PBDebug.log([index,newpoke,party[newpoke],"pbMOR"].inspect)
#       for i in 0...party.length
#         PBDebug.log([i,party[i].hp].inspect)
#       end
#       raise BattleAbortedException.new
#     end
      owner=pbGetOwner(index)
    #  Kernel.pbMessage(newpoke.to_s)
          newpoke=newpoke[0] if newpoke.is_a?(Array)

      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",owner.fullname,party[newpoke].name))
    end
  end

  def pbSwitchInBetween(index,lax,cancancel,activatedata=false)
    if !pbOwnedByPlayer?(index)
      switched=[] if !switched
            #Kernel.pbMessage("1")
               newenemy = waitnewenemy
           # Kernel.pbMessage("2")
               $network.send("<BAT\tnew=-1>")
               pbRecallAndReplace(index,newenemy)
               switched.push(index)      
      #ReturnTruth
    
   #   return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      if activatedata
     #   Kernel.pbMessage("activate")
      $hasSentData=true 
    else
           # Kernel.pbMessage("activate3")
    end
    
      return pbSwitchPlayer(index,lax,cancancel)
    end
  end

  def pbSwitchPlayer(index,lax,cancancel)
    if @debug
      return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      return @scene.pbSwitch(index,lax,cancancel)
    end
  end

################################################################################
# Using an item.
################################################################################
# Uses an item on a Pokémon in the player's party.
  def pbUseItemOnPokemon(item,pkmnIndex,scene)
    pokemon=@party1[pkmnIndex]
    battler=nil
    if pokemon.egg?
      scene.pbDisplay(_INTL("It won't have any effect."))
      return false
    end
    for i in 0...4
      if !pbIsOpposing?(i) && @battlers[i].pokemonIndex==pkmnIndex
        battler=@battlers[i]
      end
    end
    return ItemHandlers.triggerBattleUseOnPokemon(item,pokemon,battler,scene)
  end
  
# Uses an item on an active Pokémon.
  def pbUseItemOnBattler(item,index,scene)
    return ItemHandlers.triggerBattleUseOnBattler(item,@battlers[index],scene)
  end

  def pbRegisterItem(idxPokemon,idxItem)
    thispkmn=@battlers[idxPokemon]
    @choices[idxPokemon][0]=3         # "Use an item"
    @choices[idxPokemon][1]=idxItem   # ID of item to be used
    @choices[idxPokemon][2]=nil
        $mega_battlers[idxPokemon]=false

    ItemHandlers.triggerUseInBattle(idxItem,@battlers[idxPokemon],self)
    return true
  end

  def pbEnemyUseItem(item,battler)
    return 0 if !@internalbattle
    items=pbGetOwnerItems(battler.index)
    return if !items
    opponent=pbGetOwner(battler.index)
    for i in 0...items.length
      if items[i]==item
        items.delete_at(i)
        break
      end
    end
    itemname=PBItems.getName(item)
    pbDisplayBrief(_INTL("{1} used the\r\n{2}!",opponent.fullname,itemname))
    if isConst?(item,PBItems,:POTION)
      battler.pbRecoverHP(20,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:SUPERPOTION)
      battler.pbRecoverHP(50,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:HYPERPOTION)
      battler.pbRecoverHP(200,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:MAXPOTION)
      battler.pbRecoverHP(battler.totalhp-battler.hp,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:FULLRESTORE)
      fullhp=(battler.hp==battler.totalhp)
      battler.pbRecoverHP(battler.totalhp-battler.hp,true)
      battler.status=0; battler.statusCount=0
      battler.effects[PBEffects::Confusion]=0
      if fullhp
        pbDisplay(_INTL("{1} became healthy!",battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:FULLHEAL)
      battler.status=0; battler.statusCount=0
      battler.effects[PBEffects::Confusion]=0
      pbDisplay(_INTL("{1} became healthy!",battler.pbThis))
    elsif isConst?(item,PBItems,:XATTACK)
      if battler.pbCanIncreaseStatStage?(PBStats::ATTACK)
        battler.pbIncreaseStat(PBStats::ATTACK,1,true)
      end
    elsif isConst?(item,PBItems,:XDEFEND)
      if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE)
        battler.pbIncreaseStat(PBStats::DEFENSE,1,true)
      end
    elsif isConst?(item,PBItems,:XSPEED)
      if battler.pbCanIncreaseStatStage?(PBStats::SPEED)
        battler.pbIncreaseStat(PBStats::SPEED,1,true)
      end
    elsif isConst?(item,PBItems,:XSPECIAL)
      if battler.pbCanIncreaseStatStage?(PBStats::SPATK)
        battler.pbIncreaseStat(PBStats::SPATK,1,true)
      end
    elsif isConst?(item,PBItems,:XSPDEF)
      if battler.pbCanIncreaseStatStage?(PBStats::SPDEF)
        battler.pbIncreaseStat(PBStats::SPDEF,1,true)
      end
    elsif isConst?(item,PBItems,:XACCURACY)
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY)
        battler.pbIncreaseStat(PBStats::ACCURACY,1,true)
      end
    end
  end

################################################################################
# Fleeing from battle.
################################################################################
  def pbCanRun?(idxPokemon)
    return false if @opponent
    thispkmn=@battlers[idxPokemon]
    return true if isConst?(thispkmn.item,PBItems,:SMOKEBALL)
    return true if isConst?(thispkmn.ability,PBAbilities,:RUNAWAY)
    return pbCanSwitch?(idxPokemon,-1,false)
  end

  def pbRun(idxPokemon,duringBattle=false)
    thispkmn=@battlers[idxPokemon]
    if pbIsOpposing?(idxPokemon)
      if @opponent
        return 0
      else
        @choices[i][0]=5 # run
        @choices[i][1]=0 
        @choices[i][2]=nil
        return -1
      end
    end
    if @opponent
      if $DEBUG && Input.press?(Input::CTRL)
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision=1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision=2
          return 1
        end
      elsif @internalbattle
        pbDisplayPaused(_INTL("No!  There's no running from a Trainer battle!"))
      elsif pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
        pbDisplay(_INTL("{1} forfeited the match!",self.pbPlayer.name))
        @decision=3
        return 1
      end
      return 0
    end
    if $DEBUG && Input.press?(Input::CTRL)
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
      return 1
    end
    if @cantescape
      pbDisplayPaused(_INTL("Can't escape!"))
      return 0
    end
    if isConst?(thispkmn.item,PBItems,:SMOKEBALL)
      if duringBattle
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbDisplayPaused(_INTL("{1} fled using its {2}!",thispkmn.pbThis,PBItems.getName(thispkmn.item)))
      end
      @decision=3
      return 1
    end
    if isConst?(thispkmn.ability,PBAbilities,:RUNAWAY)
      if duringBattle
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbDisplayPaused(_INTL("{1} fled using Run Away!",thispkmn.pbThis))
      end
      @decision=3
      return 1
    end
    if !duringBattle && !pbCanSwitch?(idxPokemon,-1,false) # TODO: Use real messages
      pbDisplayPaused(_INTL("Can't escape!"))
      return 0
    end
    # Note: not pbSpeed, because using unmodified Speed
    speedPlayer=@battlers[idxPokemon].speed
    opposing=@battlers[idxPokemon].pbOppositeOpposing
    if opposing.hp<=0
      opposing=opposing.pbPartner
    end
    if opposing.hp>0
      speedEnemy=opposing.speed
      if speedPlayer>speedEnemy
        rate=256 
      else
        speedEnemy=1 if speedEnemy<=0
        rate=speedPlayer*128/speedEnemy
        rate+=@runCommand*30
        rate&=0xFF
      end
    else
      rate=256
    end
    ret=1
    if pbAIRandom(256)<rate
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
    else
      pbDisplayPaused(_INTL("Can't escape!"))
      ret=-1
    end
    if !duringBattle
      @runCommand+=1
    end
    return ret
  end

################################################################################
# Call battler.
################################################################################
  def pbCall(index)
    owner=pbGetOwner(index)
    pbDisplay(_INTL("{1} called {2}!",owner.name,@battlers[index].name))
    pbDisplay(_INTL("{1}!",@battlers[index].name))
    if @battlers[index].isShadow?
      if @battlers[index].inHyperMode?
        @battlers[index].pokemon.hypermode=false
        @battlers[index].pokemon.adjustHeart(-300)
        pbDisplay(_INTL("{1} came to its senses from the Trainer's call!",@battlers[index].pbThis))
      else
        pbDisplay(_INTL("But nothing happened!"))
      end
    elsif @battlers[index].status!=PBStatuses::SLEEP &&
          @battlers[index].pbCanIncreaseStatStage?(PBStats::ACCURACY)
      @battlers[index].pbIncreaseStat(PBStats::ACCURACY,1,true)
    else
      pbDisplay(_INTL("But nothing happened!"))
    end
  end

################################################################################
# Gaining Experience.
################################################################################
  def pbGainEXP
    return if Options::ONLINEEXPGAIN == false
    return if !@internalbattle
    successbegin=true
    for i in 0...4 # Not ordered by priority
      if !@doublebattle && pbIsDoubleBattler?(i)
        @battlers[i].participants=[]
        next
      end
      if pbIsOpposing?(i) && @battlers[i].participants.length>0 && @battlers[i].hp<=0
        battlerSpecies=@battlers[i].pokemon.species
        # Original species, not current species
        baseexp=@battlers[i].pokemon.baseExp
        level=@battlers[i].level
        # First count the number of participants
        partic=0
        expshare=0
        for j in @battlers[i].participants
          next if !@party1[j] || !pbIsOwner?(0,j)
          partic+=1 if @party1[j].hp>0 && !@party1[j].egg?
        end
        for j in 0..@party1.length-1
          next if !@party1[j] || !pbIsOwner?(0,j)
          expshare+=1 if @party1[j].hp>0 && !@party1[j].egg? && 
             (isConst?(@party1[j].item,PBItems,:EXPSHARE) ||
              isConst?(@party1[j].itemInitial,PBItems,:EXPSHARE))
        end
        # Now calculate EXP for the participants
        if partic>0
          if !@opponent && successbegin && pbAllFainted?(@party2)
            @scene.pbWildBattleSuccess
            successbegin=false
          end
          for j in 0..@party1.length-1
            thispoke=@party1[j]
            next if !@party1[j] || !pbIsOwner?(0,j)
            ispartic=0
            haveexpshare=(isConst?(thispoke.item,PBItems,:EXPSHARE) ||
                          isConst?(thispoke.itemInitial,PBItems,:EXPSHARE)) ? 1 : 0
            for k in @battlers[i].participants
              ispartic=1 if k==j
            end
            if thispoke.hp>0 && !thispoke.egg?
              exp=0
              if expshare>0
                exp=(level*baseexp/2).floor
                exp=(exp/partic).floor*ispartic + (exp/expshare).floor*haveexpshare
              elsif ispartic==1
                exp=(level*baseexp/partic).floor
              end
              exp=(exp*3/2).floor if @opponent
              if USENEWEXPFORMULA   # Use new (Gen 5) Exp. formula
                exp=(exp/5).floor
                leveladjust=(2*level+10.0)/(level+thispoke.level+10.0)
                leveladjust=leveladjust**5
                leveladjust=Math.sqrt(leveladjust)
                exp=(exp*leveladjust).floor
                exp+=1 if ispartic>0 || haveexpshare>0
              else                  # Use old (Gen 1-4) Exp. formula
                exp=(exp/7).floor
              end
              isOutsider=(thispoke.trainerID!=self.pbPlayer.id ||
                 (thispoke.language!=0 && thispoke.language!=self.pbPlayer.language))
              if isOutsider
                if thispoke.language!=0 && thispoke.language!=self.pbPlayer.language
                  exp=(exp*17/10).floor
                else
                  exp=(exp*3/2).floor
                end
              end
              exp=(exp*3/2).floor if isConst?(thispoke.item,PBItems,:LUCKYEGG) ||
                                     isConst?(thispoke.itemInitial,PBItems,:LUCKYEGG)
              growthrate=thispoke.growthrate
              newexp=PBExperience.pbAddExperience(thispoke.exp,exp,growthrate)
              exp=newexp-thispoke.exp
              if exp > 0 && !$game_switches[340]  && !$game_switches[267]
                if isOutsider
                  pbDisplayPaused(_INTL("{1} gained a boosted {2} Exp. Points!",thispoke.name,exp))
                else
                  pbDisplayPaused(_INTL("{1} gained {2} Exp. Points!",thispoke.name,exp))
                end
                #Gain effort value points, using RS effort values
                totalev=0
                for k in 0..5
                  totalev+=thispoke.ev[k]
                end
                # Original species, not current species
                evyield=@battlers[i].pokemon.evYield
                for k in 0..5
                  evgain=evyield[k]
                  evgain*=2 if isConst?(thispoke.item,PBItems,:MACHOBRACE) ||
                               isConst?(thispoke.itemInitial,PBItems,:MACHOBRACE)
                  evgain+=4 if k==0 && isConst?(thispoke.item,PBItems,:POWERWEIGHT) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERWEIGHT)
                  evgain+=4 if k==1 && isConst?(thispoke.item,PBItems,:POWERBRACER) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERBRACER)
                  evgain+=4 if k==2 && isConst?(thispoke.item,PBItems,:POWERBELT) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERBELT)
                  evgain+=4 if k==3 && isConst?(thispoke.item,PBItems,:POWERANKLET) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERANKLET)
                  evgain+=4 if k==4 && isConst?(thispoke.item,PBItems,:POWERLENS) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERLENS)
                  evgain+=4 if k==5 && isConst?(thispoke.item,PBItems,:POWERBAND) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERBAND)
                  evgain*=2 if thispoke.pokerusStage>=1 # Infected or cured
                  if evgain>0
                    # Can't exceed overall limit
                    if totalev+evgain>510
                      evgain-=totalev+evgain-510
                    end
                    # Can't exceed stat limit
                    if thispoke.ev[k]+evgain>255
                      evgain-=thispoke.ev[k]+evgain-255
                    end
                    # Add EV gain
                    thispoke.ev[k]+=evgain
                    if thispoke.ev[k]>255
                      print "Single-stat EV limit 255 exceeded.\r\nStat: #{k}  EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
                      thispoke.ev[k]=255
                    end
                    totalev+=evgain
                    if totalev>510
                      print "EV limit 510 exceeded.\r\nTotal EVs: #{totalev} EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
                    end
                  end
                end
                newlevel=PBExperience.pbGetLevelFromExperience(newexp,growthrate)
                tempexp=0
                curlevel=thispoke.level
                thisPokeSpecies=thispoke.species
                if newlevel<curlevel
                  debuginfo="#{thispoke.name}: #{thispoke.level}/#{newlevel} | #{thispoke.exp}/#{newexp} | gain: #{exp}"
                  raise RuntimeError.new(
                     _INTL("The new level ({1}) is less than the Pokémon's\r\ncurrent level ({2}), which shouldn't happen.\r\n[Debug: {3}]",
                     newlevel,curlevel,debuginfo))
                  return
                end
                if thispoke.respond_to?("isShadow?") && thispoke.isShadow?
                  thispoke.exp+=exp
                else
                  tempexp1=thispoke.exp
                  tempexp2=0
                  # Find battler
                  battler=pbFindPlayerBattler(j)
                  loop do
                    #EXP Bar animation
                    startexp=PBExperience.pbGetStartExperience(curlevel,growthrate)
                    endexp=PBExperience.pbGetStartExperience(curlevel+1,growthrate)
                    tempexp2=(endexp<newexp) ? endexp : newexp
                    thispoke.exp=tempexp2
                    @scene.pbEXPBar(thispoke,battler,startexp,endexp,tempexp1,tempexp2)
                    tempexp1=tempexp2
                    curlevel+=1
                    break if curlevel>newlevel
                    oldtotalhp=thispoke.totalhp
                    oldattack=thispoke.attack
                    olddefense=thispoke.defense
                    oldspeed=thispoke.speed
                    oldspatk=thispoke.spatk
                    oldspdef=thispoke.spdef
                    thispoke.calcStats
                    if battler
                      if battler.pokemon && @internalbattle
                        battler.pokemon.changeHappiness("level up")
                      end
                    end
                    battler.pbUpdate(false) if battler
                    @scene.pbRefresh
                    pbDisplayPaused(_INTL("{1} grew to Level {2}!",thispoke.name,curlevel))
                    @scene.pbLevelUp(thispoke,battler,oldtotalhp,oldattack,
                       olddefense,oldspeed,oldspatk,oldspdef)
                    # Finding all moves learned at this level
                    movelist=thispoke.getMoveList
                    for k in movelist
                      if k[0]==thispoke.level   # Learned a new move
                        pbLearnMove(j,k[1])
                      end
                    end
                  end
                end
              end
            end
          end
        end
        # Now clear the participants array
        @battlers[i].participants=[]
      end
    end
  end

################################################################################
# Learning a move.
################################################################################
  def pbLearnMove(pkmnIndex,move)
    pokemon=@party1[pkmnIndex]
    return if !pokemon
    pkmnname=pokemon.name
    battler=pbFindPlayerBattler(pkmnIndex)
    movename=PBMoves.getName(move)
    for i in 0..3
      if pokemon.moves[i].id==move
        return
      end
      if pokemon.moves[i].id==0
        pokemon.moves[i]=PBMove.new(move)
        battler.moves[i]=PokeBattle_Move.pbFromPBMove(self,pokemon.moves[i]) if battler
        pbDisplayPaused(_INTL("{1} learned {2}!",pkmnname,movename))
        return
      end
    end
    loop do
      pbDisplayPaused(_INTL("{1} is trying to learn {2}.",pkmnname,movename))
      pbDisplayPaused(_INTL("But {1} can't learn more than four moves.",pkmnname))
      if pbDisplayConfirm(_INTL("Delete a move to make room for {1}?",movename))
        pbDisplayPaused(_INTL("Which move should be forgotten?"))
        forgetmove=@scene.pbForgetMove(pokemon,move)
        if forgetmove >=0
          oldmovename=PBMoves.getName(pokemon.moves[forgetmove].id)
          pokemon.moves[forgetmove]=PBMove.new(move) # Replaces current/total PP
          battler.moves[forgetmove]=PokeBattle_Move.pbFromPBMove(self,pokemon.moves[forgetmove]) if battler
          pbDisplayPaused(_INTL("1,  2, and... ... ..."))
          pbDisplayPaused(_INTL("Poof!"))
          pbDisplayPaused(_INTL("{1} forgot {2}.",pkmnname,oldmovename))
          pbDisplayPaused(_INTL("And..."))
          pbDisplayPaused(_INTL("{1} learned {2}!",pkmnname,movename))
          return
        elsif pbDisplayConfirm(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
          pbDisplayPaused(_INTL("{1} did not learn {2}.",pkmnname,movename))
          return
        end
      elsif pbDisplayConfirm(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
        pbDisplayPaused(_INTL("{1} did not learn {2}.",pkmnname,movename))
        return
      end
    end
  end

################################################################################
# Abilities.
################################################################################
  def pbOnActiveAll
    for i in 0...4 # Currently unfainted participants will earn EXP even if they faint afterwards
      @battlers[i].pbUpdateParticipants if pbIsOpposing?(i)
      @amuletcoin=true if !pbIsOpposing?(i) &&
                          (isConst?(@battlers[i].item(true),PBItems,:AMULETCOIN) ||
                           isConst?(@battlers[i].item(true),PBItems,:LUCKINCENSE))
    end
    for i in 0...4
      if @battlers[i] && @battlers[i].hp>0 && pbIsOpposing?(i)
        if @battlers[i].isShadow?
          pbCommonAnimation("Shadow",@battlers[i],nil)
          pbDisplay(_INTL("Oh!\nA Shadow Pokemon!"))
        end
      end
    end
    # Weather-inducing abilities, Trace, Imposter, etc.
    @usepriority=false
    priority=pbPriority
    for i in priority
      i.pbAbilitiesOnSwitchIn(true)
    end
    # Check forms are correct
    for i in 0...4
      pkmn=@battlers[i]
      next if pkmn.hp<=0
      @battlers[i].pbCheckForm
    end
  end

  def pbOnActiveOne(pkmn,onlyabilities=false)
    return false if pkmn.hp<=0
    if !onlyabilities
      for i in 0...4 # Currently unfainted participants will earn EXP even if they faint afterwards
        @battlers[i].pbUpdateParticipants if pbIsOpposing?(i)
        @amuletcoin=true if !pbIsOpposing?(i) &&
                            (isConst?(@battlers[i].item(true),PBItems,:AMULETCOIN) ||
                             isConst?(@battlers[i].item(true),PBItems,:LUCKINCENSE))
      end
      if pkmn.isShadow? && !pbOwnedByPlayer?(pkmn.index)
        pbDisplay(_INTL("Oh!\nA Shadow Pokemon!"))
      end
      # Healing Wish
      if pkmn.effects[PBEffects::HealingWish]
        pkmn.pbRecoverHP(pkmn.totalhp,true)
        pkmn.status=0
        pkmn.statusCount=0
        pbDisplayPaused(_INTL("The healing wish came true for {1}!",pkmn.pbThis(true)))
        pkmn.effects[PBEffects::HealingWish]=false
      end
      # Lunar Dance
      if pkmn.effects[PBEffects::LunarDance]
        pkmn.pbRecoverHP(pkmn.totalhp,true)
        pkmn.status=0
        pkmn.statusCount=0
        for i in 0...4
          pkmn.moves[i].pp=pkmn.moves[i].totalpp
        end
        pbDisplayPaused(_INTL("{1} became cloaked in mystical moonlight!",pkmn.pbThis))
        pkmn.effects[PBEffects::LunarDance]=false
      end
      # Spikes
      if pkmn.pbOwnSide.effects[PBEffects::Spikes]>0
        if isConst?(pkmn.item,PBItems,:IRONBALL) ||
           pkmn.effects[PBEffects::Ingrain] ||
           pkmn.effects[PBEffects::SmackDown] ||
           pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
           pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
           !(pkmn.pbHasType?(:FLYING) ||
             isConst?(pkmn.ability,PBAbilities,:LEVITATE) ||
             isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
             pkmn.effects[PBEffects::MagnetRise]>0 ||
             pkmn.effects[PBEffects::Telekinesis]>0)
          if !isConst?(pkmn.ability,PBAbilities,:MAGICGUARD)
            spikesdiv=[8,8,6,4][pkmn.pbOwnSide.effects[PBEffects::Spikes]]
            @scene.pbDamageAnimation(pkmn,0)
            pkmn.pbReduceHP([(pkmn.totalhp/spikesdiv).floor,1].max)
            pbDisplayPaused(_INTL("{1} was hurt by spikes!",pkmn.pbThis))
          end
        end
      end
      pkmn.pbFaint if pkmn.hp<=0
      # Stealth Rock
      if pkmn.pbOwnSide.effects[PBEffects::Permafrost] > 0
     #     Kernel.pbMessage("got the frost")
        if isConst?(pkmn.item,PBItems,:IRONBALL) ||
           pkmn.effects[PBEffects::Ingrain] ||
           pkmn.effects[PBEffects::SmackDown] ||
           pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
           pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
           !(pkmn.pbHasType?(:FLYING) ||
           isConst?(pkmn.ability,PBAbilities,:LEVITATE) ||
           isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
           pkmn.effects[PBEffects::MagnetRise]>0 ||
           pkmn.effects[PBEffects::Telekinesis]>0)
         #            Kernel.pbMessage("inside conditional")

           if pkmn.pbHasType?(:ICE)
            pbDisplayPaused(_INTL("{1} was unaffected by the frost!",pkmn.pbThis))
          else #!isConst?(pkmn.ability,PBAbilities,:MAGICGUARD)
         #             Kernel.pbMessage("before om")

            if pbRandom(8) == 1
                #        Kernel.pbMessage("inside random true")

                pbDisplayPaused(_INTL("{1} was frozen by the frost on the ground!",pkmn.pbThis))
               pkmn.pbFreeze
             else
                  #       Kernel.pbMessage("inside random false")

               pbDisplayPaused(_INTL("{1} avoided the frost!",pkmn.pbThis))
            end
           end
         end
         end
       if pkmn.pbOwnSide.effects[PBEffects::StickyWeb]
        if isConst?(pkmn.item,PBItems,:IRONBALL) ||
           pkmn.effects[PBEffects::Ingrain] ||
           pkmn.effects[PBEffects::SmackDown] ||
           pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
           pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
           !(pkmn.pbHasType?(:FLYING) ||
           isConst?(pkmn.ability,PBAbilities,:LEVITATE) ||
           isConst?(pkmn.ability,PBAbilities,:CLEARBODY) ||
           isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
           pkmn.effects[PBEffects::MagnetRise]>0 ||
           pkmn.effects[PBEffects::Telekinesis]>0)
           if pkmn.pbTooLow?(PBStats::SPEED)
              pbDisplay(_INTL("{1}'s Speed won't go lower!",pkmn.pbThis))
            else
              pkmn.pbReduceStatBasic(PBStats::SPEED,1)
              pbCommonAnimation("StatDown",pkmn,nil)
              pbDisplay(_INTL("{1}'s Speed fell!",pkmn.pbThis))
            end
           end
         end
# Livewire
    
      if pkmn.pbOwnSide.effects[PBEffects::Livewire] > 0
        if isConst?(pkmn.item,PBItems,:IRONBALL) ||
           pkmn.effects[PBEffects::Ingrain] ||
           pkmn.effects[PBEffects::SmackDown] ||
           pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
           pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
           !(pkmn.pbHasType?(:FLYING) ||
             isConst?(pkmn.ability,PBAbilities,:LEVITATE) ||
             isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
             pkmn.effects[PBEffects::MagnetRise]>0 ||
             pkmn.effects[PBEffects::Telekinesis]>0)
          if pkmn.pbHasType?(:ELECTRIC) || pkmn.pbHasType?(:GROUND)
            pkmn.pbOwnSide.effects[PBEffects::Livewire]=0
            pbDisplayPaused(_INTL("{1} absorbed the Livewire!",pkmn.pbThis))
          else # !isConst?(pkmn.ability,PBAbilities,:MAGICGUARD)
            pkmn.pbParalyze(pkmn)
            pbDisplayPaused(_INTL("{1} was shocked by the Livewire!",pkmn.pbThis))
          end
        else
            pbDisplayPaused(_INTL("{1} avoided the Livewire!",pkmn.pbThis))

          end
        end
      # Stealth Rock
      if pkmn.pbOwnSide.effects[PBEffects::StealthRock] && !isConst?(pkmn.ability,PBAbilities,:MAGICGUARD)
        if !isConst?(pkmn.ability,PBAbilities,:MAGICGUARD)
          atype=getConst(PBTypes,:ROCK) || 0
          otype1=pkmn.type1
          otype2=pkmn.type2
          eff=PBTypes.getCombinedEffectiveness(atype,otype1,otype2)
          if eff>0
            pkmn.pbReduceHP(pkmn.totalhp*eff/32)
            pbDisplayPaused(_INTL("{1} is hurt by stealth rocks!",pkmn.pbThis))
          end
        end
      end
      pkmn.pbFaint if pkmn.hp<=0
            if pkmn.pbOwnSide.effects[PBEffects::FireRock] && !isConst?(pkmn.ability,PBAbilities,:MAGICGUARD)
        if !isConst?(pkmn.ability,PBAbilities,:MAGICGUARD)
          atype=getConst(PBTypes,:FIRE) || 0
          otype1=pkmn.type1
          otype2=pkmn.type2
          eff=PBTypes.getCombinedEffectiveness(atype,otype1,otype2)
          if eff>0
            pkmn.pbReduceHP(pkmn.totalhp*eff/32)
            pbDisplayPaused(_INTL("{1} is hurt by molten rocks!",pkmn.pbThis))
          end
        end
      end

      pkmn.pbFaint if pkmn.hp<=0
      # Toxic Spikes
      if pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        if isConst?(pkmn.item,PBItems,:IRONBALL) ||
           pkmn.effects[PBEffects::Ingrain] ||
           pkmn.effects[PBEffects::SmackDown] ||
           pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
           pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
           !(pkmn.pbHasType?(:FLYING) ||
             isConst?(pkmn.ability,PBAbilities,:LEVITATE) ||
             isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
             pkmn.effects[PBEffects::MagnetRise]>0 ||
             pkmn.effects[PBEffects::Telekinesis]>0)
          if pkmn.pbHasType?(:POISON)
            pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
            pbDisplayPaused(_INTL("{1} absorbed the poison spikes!",pkmn.pbThis))
          elsif pkmn.pbCanPoisonSpikes?
            if pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]==2
              pkmn.pbPoison(pkmn,true)
              pbDisplayPaused(_INTL("{1} was badly poisoned!",pkmn.pbThis))
            else
              pkmn.pbPoison(pkmn)
              pbDisplayPaused(_INTL("{1} was poisoned!",pkmn.pbThis))
            end
          end
        end
      end
    end
    pkmn.pbAbilityCureCheck
    if pkmn.hp<=0
      pbGainEXP
      pbSwitch
      return false
    end
    if !onlyabilities
      pkmn.pbCheckForm
      pkmn.pbBerryCureCheck
    end
    return true
  end

  def pbAbilityEffect(move,user,target,damage)
    if (target.effects[PBEffects::SuckerPunch]) && damage>0
#      Kernel.pbMessage("hey")
        target.effects[PBEffects::SuckerPunch]=false
      end


#    receive_seed
      if (isConst?(target.ability,PBAbilities,:ILLUSION) || target.species==PBSpecies::ZOROARK) && damage > 0&& target.hp>0
        if $illusion[target.index] != nil || (target.species==PBSpecies::ZOROARK && target.form!=0)
            if !target.saidIllu
          pbDisplay("The Illusion was broken!")
          target.saidIllu=true
                    @scene.pbTrainerSendOut(target.index,$illusion[target.index],true) if !pbOwnedByPlayer?(target.index)
          @scene.pbSendOut(target.index,$illusion[target.index],true) if pbOwnedByPlayer?(target.index)
          end
          $illusion[target.index]=nil
          end
        end
      
=begin
               if isConst?(target.ability,PBAbilities,:ILLUSION)
 #       Kernel.pbMessage(_INTL("yo {1}",target.effects[PBEffects::Illusion].species))
#        gg = target.effects[PBEffects::Illusion]
#        target.effects[PBEffects::Illusion] = 0
    pkmn=@sprites["pokemon#{target.index}"]
    shadow=@sprites["shadow#{target.index}"]
    back=!@battle.pbIsOpposing?(target.index)
    pkmn.setPokemonBitmap(target.effects[PBEffects::Illusion],back)
    pkmn.y=adjustBattleSpriteY(pkmn,target.effects[PBEffects::Illusion].species,attacker.index)
    if shadow && !back
      shadow.visible=showShadow?(target.effects[PBEffects::Illusion].species)
    end

    #          pbChangePokemon(target,target.effects[PBEffects::Illusion])
    end
=end
      if isConst?(user.ability,PBAbilities,:MOXIE) && user.hp>0 && target.hp<=0
          user.pbIncreaseStatBasic(PBStats::ATTACK,1)
          pbDisplay(_INTL("{1}'s Moxie increased its attack!",user.pbThis))

        end
      if isConst?(user.ability,PBAbilities,:HUBRIS) && user.hp>0 && target.hp<=0
          user.pbIncreaseStatBasic(PBStats::SPATK,1)
          pbDisplay(_INTL("{1}'s Hubris increased its Sp. Atk!",user.pbThis))

        end

    if (move.flags&0x01)!=0 && damage>0 # flag A: Makes contact
      if isConst?(target.ability,PBAbilities,:STATIC) && self.pbRandom(10)<3 &&
         user.pbCanParalyze?(false)
        user.pbParalyze(target)
        pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
           target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
         end
           if isConst?(target.ability,PBAbilities,:GOOEY)
          user.pbReduceStatBasic(PBStats::SPEED,1)
        pbDisplay(_INTL("{1}'s {2} lowered {3}'s Speed!",
           target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
      end
      if isConst?(target.ability,PBAbilities,:POISONPOINT) &&
         self.pbRandom(10)<3 && user.pbCanPoison?(false)
        user.pbPoison(target)
        pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
           PBAbilities.getName(target.ability),user.pbThis(true)))
      end
      if isConst?(user.ability,PBAbilities,:POISONTOUCH) &&
         self.pbRandom(10)<3 && target.pbCanPoison?(false)
        target.pbPoison(user)
        pbDisplay(_INTL("{1}'s {2} poisoned {3}!",user.pbThis,
           PBAbilities.getName(user.ability),target.pbThis(true)))
      end
      if isConst?(target.ability,PBAbilities,:FLAMEBODY) &&
         self.pbRandom(10)<3 && user.pbCanBurn?(false)
        user.pbBurn(target)
        pbDisplay(_INTL("{1}'s {2} burned {3}!",target.pbThis,
           PBAbilities.getName(target.ability),user.pbThis(true)))
      end
      if isConst?(target.ability,PBAbilities,:EFFECTSPORE) && self.pbRandom(10)<3
        rnd=self.pbRandom(3)
        if rnd==0 && user.pbCanPoison?(false)
          user.pbPoison(target)
          pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        elsif rnd==1 && user.pbCanSleep?(nil,false)
          user.pbSleep
          pbDisplay(_INTL("{1}'s {2} made {3} sleep!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        elsif rnd==2 && user.pbCanParalyze?(false)
          user.pbParalyze(target)
          pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
             target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
        end
      end
      if isConst?(target.ability,PBAbilities,:CUTECHARM) && self.pbRandom(10)<3
        if !isConst?(user.ability,PBAbilities,:OBLIVIOUS) &&
           ((user.gender==1 && target.gender==0) ||
           (user.gender==0 && target.gender==1)) &&
           user.effects[PBEffects::Attract]<0 && user.hp>0 && target.hp>0
          user.effects[PBEffects::Attract]=target.index
          pbDisplay(_INTL("{1}'s {2} infatuated {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
          if isConst?(user.item,PBItems,:DESTINYKNOT) &&
             !isConst?(target.ability,PBAbilities,:OBLIVIOUS) &&
             target.effects[PBEffects::Attract]<0
            target.effects[PBEffects::Attract]=user.index
            pbDisplay(_INTL("{1}'s {2} infatuated {3}!",user.pbThis,
               PBItems.getName(user.item),target.pbThis(true)))
          end
        end
      end
      if isConst?(target.ability,PBAbilities,:ROUGHSKIN) && user.hp>0
        @scene.pbDamageAnimation(user,0)
        user.pbReduceHP((user.totalhp/8).floor)
        pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
           PBAbilities.getName(target.ability),user.pbThis(true)))
         end
         
         
             
      if isConst?(target.ability,PBAbilities,:EVENTHORIZON) && user.hp>0
        if user.effects[PBEffects::MeanLook]>=0 ||
           user.effects[PBEffects::Substitute]>0
          #  @battle.pbDisplay(_INTL("But it failed!"))
          #return -1
        else
          user.effects[PBEffects::MeanLook]=target.index
         # @battle.pbAnimation(@id,attacker,opponent)
          @battle.pbDisplay(_INTL("Event Horizon stopped {1} from escaping!",user.pbThis))
        end
      end
      if isConst?(target.ability,PBAbilities,:IRONBARBS) && user.hp>0
        @scene.pbDamageAnimation(user,0)
        user.pbReduceHP((user.totalhp/8).floor)
        pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
           PBAbilities.getName(target.ability),user.pbThis(true)))
      end
      if isConst?(target.ability,PBAbilities,:AFTERMATH) && user.hp>0 && target.hp<=0
        if !pbCheckGlobalAbility(:DAMP)
          @scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/4).floor)
          pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
        end
      end
      if isConst?(target.item,PBItems,:ROCKYHELMET) && user.hp>0
        @scene.pbDamageAnimation(user,0)
        user.pbReduceHP((user.totalhp/6).floor)
        pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
           PBItems.getName(target.item),user.pbThis(true)))
      end
      if isConst?(target.ability,PBAbilities,:PICKPOCKET) && target.hp>0
        if target.item(true)==0 && user.item(true)>0 &&
           user.effects[PBEffects::Substitute]==0 &&
           target.effects[PBEffects::Substitute]==0 &&
           !isConst?(user.ability,PBAbilities,:STICKYHOLD) &&
           !pbIsUnlosableItem(user,user.item(true)) &&
           !pbIsUnlosableItem(target,user.item(true)) &&
           (@battle.opponent || !@battle.pbIsOpposing?(target.index))
          target.item=user.item(true)
          user.item=0
          if !@battle.opponent &&   # In a wild battle
             target.pokemon.itemInitial==0 &&
             user.pokemon.itemInitial==target.item(true)
            target.pokemon.itemInitial=target.item(true)
            user.pokemon.itemInitial=0
          end
          pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
             user.pbThis(true),PBItems.getName(target.item(true))))
        end
      end
      if isConst?(target.ability,PBAbilities,:MUMMY) && user.hp>0
        if !isConst?(user.ability(true),PBAbilities,:MULTITYPE) &&
           !isConst?(user.ability(true),PBAbilities,:WONDERGUARD) &&
           !isConst?(user.ability(true),PBAbilities,:MUMMY)
          user.ability=getConst(PBAbilities,:MUMMY) || 0
          pbDisplay(_INTL("{1} was mummified by {2}!",user.pbThis,target.pbThis(true)))
        end
      end
    end
    if isConst?(target.ability,PBAbilities,:CURSEDBODY) && self.pbRandom(10)<3
      if user.effects[PBEffects::Disable]<=0 && move.pp>0 && user.hp>0
        user.effects[PBEffects::Disable]=4
        user.effects[PBEffects::DisableMove]=move.id
        pbDisplay(_INTL("{1}'s {2} disabled {3}!",target.pbThis,
           PBAbilities.getName(target.ability),user.pbThis(true)))
      end
    end
    type=move.pbType(move.type,user,target)
    if isConst?(target.ability,PBAbilities,:COLORCHANGE) && target.hp>0 &&
       damage>0 && !PBTypes.isPseudoType?(type) && !target.pbHasType?(type)
      target.type1=type
      target.type2=type
      pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
         PBAbilities.getName(target.ability),PBTypes.getName(type)))
    end
    user.pbAbilityCureCheck
    target.pbAbilityCureCheck
    # Synchronize here
    s=@synchronize[0]
    t=@synchronize[1]
#   PBDebug.log("[synchronize: #{@synchronize.inspect}]")
    if s>=0 && t>=0 && isConst?(@battlers[s].ability,PBAbilities,:SYNCHRONIZE) &&
       @synchronize[2]>0 && @battlers[t].hp>0
# see [2024281]&0xF0, [202420C]
      sbattler=@battlers[s]
      tbattler=@battlers[t]
      if @synchronize[2]==PBStatuses::POISON && tbattler.pbCanPoisonSynchronize?(sbattler)
        tbattler.pbPoison(sbattler)
        pbDisplay(_INTL("{1}'s {2} poisoned {3}!",sbattler.pbThis,
           PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      elsif @synchronize[2]==PBStatuses::BURN && tbattler.pbCanBurnSynchronize?(sbattler)
        tbattler.pbBurn(sbattler)
        pbDisplay(_INTL("{1}'s {2} burned {3}!",sbattler.pbThis,
           PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      elsif @synchronize[2]==PBStatuses::PARALYSIS && tbattler.pbCanParalyzeSynchronize?(sbattler)
        tbattler.pbParalyze(sbattler)
        pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
           sbattler.pbThis,PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      end
    end
  end

################################################################################
# Judging.
################################################################################
  def pbJudgeCheckpoint(attacker,move=0)
  end

  def pbDecisionOnTime
    count1=0
    count2=0
    hptotal1=0
    hptotal2=0
    for i in @party1
      next if !i
      if i.hp>0 && !i.egg?
        count1+=1
        hptotal1+=i.hp
      end
    end
    for i in @party2
      next if !i
      if i.hp>0 && !i.egg?
        count2+=1
        hptotal2+=i.hp
      end
    end
    return 1 if count1>count2     # win
    return 2 if count1<count2     # loss
    return 1 if hptotal1>hptotal2 # win
    return 2 if hptotal1<hptotal2 # loss
    return 5                      # draw
  end

  def pbDecisionOnTime2
    count1=0
    count2=0
    hptotal1=0
    hptotal2=0
    for i in @party1
      next if !i
      if i.hp>0 && !i.egg?
        count1+=1
        hptotal1+=(i.hp*100/i.totalhp)
      end
    end
    hptotal1/=count1 if count1>0
    for i in @party2
      next if !i
      if i.hp>0 && !i.egg?
        count2+=1
        hptotal2+=(i.hp*100/i.totalhp)
      end
    end
    hptotal2/=count2 if count2>0
    return 1 if count1>count2     # win
    return 2 if count1<count2     # loss
    return 1 if hptotal1>hptotal2 # win
    return 2 if hptotal1<hptotal2 # loss
    return 5                      # draw
  end

  def pbDecisionOnDraw
    return 5 # draw
  end

  def pbJudge
#   PBDebug.log("[Counts: #{pbPokemonCount(@party1)}/#{pbPokemonCount(@party2)}]")
    if pbAllFainted?(@party1) && pbAllFainted?(@party2)
      @decision=pbDecisionOnDraw() # Draw
      return
    end
    if pbAllFainted?(@party1)
      @decision=2 # Loss
      return
    end
    if pbAllFainted?(@party2)
      @decision=1 # Win
      return
    end
  end

################################################################################
# Messages and animations.
################################################################################
  def pbDisplay(msg)
    @scene.pbDisplayMessage(msg)
  end

  def pbDisplayPaused(msg)
    @scene.pbDisplayPausedMessage(msg)
  end

  def pbDisplayBrief(msg,danger=true)
    #TITAYS 
#    Kernel.pbMessage("Greetings!") if $is_insane
# ---
    @scene.pbDisplayMessage(msg,true) if !danger
    @scene.pbDisplayMessage(msg,!$is_insane) if danger
  # ---
 #   @scene.pbDisplayMessage(msg,true)
  end

  def pbDisplayConfirm(msg)
    @scene.pbDisplayConfirmMessage(msg)
  end

  def pbShowCommands(msg,commands,cancancel=true)
    @scene.pbShowCommands(msg,commands,cancancel)
  end

  def pbAnimation(move,attacker,opponent,side=true)
    if @battlescene
      @scene.pbAnimation(move,attacker,opponent,side)
    end
  end

  def pbCommonAnimation(name,attacker,opponent,side=true)
    if @battlescene
      @scene.pbCommonAnimation(name,attacker,opponent,side)
    end
  end

################################################################################
# Battle core.
################################################################################
  def pbStartBattle(canlose=false)
    begin
      pbStartBattleCore(canlose)
      rescue BattleAbortedException
     @decision=0
     @scene.pbEndBattle(@decision)
    end
    return @decision
  end

  def pbStartBattleCore(canlose)
    if !@fullparty1 && @party1.length>MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 1 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@fullparty2 && @party2.length>MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 2 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@opponent
#========================
# Initialize wild Pokémon
#========================
      if @party2.length==1
        if @doublebattle
          raise _INTL("Only two wild Pokémon are allowed in double battles")
        end
        wildpoke=@party2[0]
        @battlers[1].pbInitialize(wildpoke,0,false)
        @peer.pbOnEnteringBattle(self,wildpoke)
        pbSetSeen(wildpoke)
        @scene.pbStartBattle(self)
        pbDisplayPaused(_INTL("Wild {1} appeared!",wildpoke.name))
      elsif @party2.length==2
        if !@doublebattle
          raise _INTL("Only one wild Pokémon is allowed in single battles")
        end
        @battlers[1].pbInitialize(@party2[0],0,false)
        @battlers[3].pbInitialize(@party2[1],0,false)
        @peer.pbOnEnteringBattle(self,@party2[0])
        @peer.pbOnEnteringBattle(self,@party2[1])
        pbSetSeen(@party2[0])
        pbSetSeen(@party2[1])
        @scene.pbStartBattle(self)
        pbDisplayPaused(_INTL("Wild {1} and\r\n{2} appeared!",
           @party2[0].name,@party2[1].name))
      else
        raise _INTL("Only one or two wild Pokémon are allowed")
      end
    elsif @doublebattle
#=======================================
# Initialize opponents in double battles
#=======================================
      if @opponent.is_a?(Array)
        if @opponent.length==1
          @opponent=@opponent[0]
        elsif @opponent.length!=2
          raise _INTL("Opponents with zero or more than two people are not allowed")
        end
      end
      if @player.is_a?(Array)
        if @player.length==1
          @player=@player[0]
        elsif @player.length!=2
          raise _INTL("Player trainers with zero or more than two people are not allowed")
        end
      end
      @scene.pbStartBattle(self)
      if @opponent.is_a?(Array)
        pbDisplayPaused(_INTL("{1} and {2} want to battle!",@opponent[0].fullname,@opponent[1].fullname))
        sendout1=pbFindNextUnfainted(@party2,0,pbSecondPartyBegin(1))
        raise _INTL("Opponent 1 has no unfainted Pokémon") if sendout1<0
        sendout2=pbFindNextUnfainted(@party2,pbSecondPartyBegin(1))
        raise _INTL("Opponent 2 has no unfainted Pokémon") if sendout2<0
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[0].fullname,@party2[sendout1].name))
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbSendOut(1,@party2[sendout1])
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[1].fullname,@party2[sendout2].name))
        pbSendOut(3,@party2[sendout2])
      else
        pbDisplayPaused(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        if sendout1<0 || sendout2<0
          raise _INTL("Opponent doesn't have two unfainted Pokémon")
        end
        pbDisplayBrief(_INTL("{1} sent\r\nout {2} and {3}!",
           @opponent.fullname,@party2[sendout1].name,@party2[sendout2].name))
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbSendOut(1,@party2[sendout1])
        pbSendOut(3,@party2[sendout2])
      end
    else
#======================================
# Initialize opponent in single battles
#======================================
      sendout=pbFindNextUnfainted(@party2,0)
      raise _INTL("Trainer has no unfainted Pokémon") if sendout<0
      if @opponent.is_a?(Array)
        raise _INTL("Opponent trainer must be only one person in single battles") if @opponent.length!=1
        @opponent=@opponent[0]
      end
      if @player.is_a?(Array)
        raise _INTL("Player trainer must be only one person in single battles") if @player.length!=1
        @player=@player[0]
      end
      trainerpoke=@party2[0]
      @scene.pbStartBattle(self)
      pbDisplayPaused(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent.fullname,trainerpoke.name))
      @battlers[1].pbInitialize(trainerpoke,sendout,false)
      pbSendOut(1,trainerpoke)
    end
#=====================================
# Initialize players in double battles
#=====================================
    if @doublebattle
      if @player.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
        raise _INTL("Player 1 has no unfainted Pokémon") if sendout1<0
        sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
        raise _INTL("Player 2 has no unfainted Pokémon") if sendout2<0
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!  Go! {3}!",
           @player[1].fullname,@party1[sendout2].name,@party1[sendout1].name))
        pbSetSeen(@party1[sendout1])
        pbSetSeen(@party1[sendout2])
      else
        sendout1=pbFindNextUnfainted(@party1,0)
        sendout2=pbFindNextUnfainted(@party1,sendout1+1)
        if sendout1<0 || sendout2<0
          raise _INTL("Player doesn't have two unfainted Pokémon")
        end
        pbDisplayBrief(_INTL("Go! {1} and {2}!",@party1[sendout1].name,@party1[sendout2].name))
      end
      @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
      @battlers[2].pbInitialize(@party1[sendout2],sendout2,false)
      pbSendOut(0,@party1[sendout1])
      pbSendOut(2,@party1[sendout2])
    else
#====================================
# Initialize player in single battles
#====================================
      sendout=pbFindNextUnfainted(@party1,0)
      if sendout<0
        raise _INTL("Player has no unfainted Pokémon")
      end
      playerpoke=@party1[sendout]
      pbDisplayBrief(_INTL("Go! {1}!",playerpoke.name))
      @battlers[0].pbInitialize(playerpoke,sendout,false)
      pbSendOut(0,playerpoke)
    end
#==================
# Initialize battle
#==================
    @weather=0
    if @weather==PBWeather::SUNNYDAY
      pbDisplay(_INTL("The sunlight is strong."))
    elsif @weather==PBWeather::RAINDANCE
      pbDisplay(_INTL("It is raining."))
    elsif @weather==PBWeather::NEWMOON
      pbDisplay(_INTL("The sky is dark."))
    elsif @weather==PBWeather::SANDSTORM
      pbDisplay(_INTL("A sandstorm is raging."))
    elsif @weather==PBWeather::HAIL
      pbDisplay(_INTL("Hail is falling."))
    end
    
    pbOnActiveAll   # Abilities
    @turncount=0
    loop do # Now begin the battle loop
      if @debug
        if @turncount>=100
          @decision=pbDecisionOnTime()
          PBDebug.log("***[Undecided after 100 rounds]")
          pbAbort
          break
        end
        PBDebug.log("***Round #{@turncount+1}")
      end
      PBDebug.logonerr{
         pbCommandPhase
      }
      for i in 0..3
        @battlers[0].moves[i].battle = nil
      end
      choices = ([Marshal.dump(@choices[0])].pack("m").delete("\n") rescue nil)
      #if choices == nil
        
      #end
      
     for i in 0..3
        @battlers[0].moves[i].battle = self
      end
      megg=-1
      megg=0 if $mega_battlers[0]
      myarray=[]
      for i in 0..35
        myarray.push(rand(100))
      end
      
      rseed=""
      for int in myarray
          rseed += int.to_s
          rseed += "."
        end
      #Kernel.pbMessage(rseed+"mine immediate")
 #     $network.send("<BAT new=-1>")
#      waitnewenemy2
      $network.send("<BAT\tchoices=#{choices}\tm=#{megg.to_s}\trseed=#{rseed.to_s}>")
      
      #$network.send("<BAT choices=#{choices}>")

      loop do
              pbDisplay("Waiting...")

        Graphics.update
        Input.update
        message = $network.listen
        @turnRandoms=[]
        case message
        when /<BAT choices=(.*) m=(.*) rseed=(.*)>/ 
            @choices[1] = Marshal.load($1.unpack("m")[0])
            for i in 0..3
              @battlers[1].moves[i].battle = self
            end
            i = 0
            $mega_battlers[$2.to_i+1]=true if $2.to_i != -1
            temparray=[]
            $3.each_line("."){|s| 
              temparray.push(s.chomp(".").to_i)
            }

            for i in 0..temparray.length-1
              if temparray[i] != nil && myarray[i] != nil
              @turnRandoms[i]=temparray[i]+myarray[i]
       #       Kernel.pbMessage(@turnRandoms[i].to_s+" randoms1")
              @turnRandoms[i] /= 2
              @turnRandoms[i]=@turnRandoms[i].floor
          #    Kernel.pbMessage(@turnRandoms[i].to_s)
             # Kernel.pbMessage(@turnRandoms[i].to_s)
              end
         #     Kernel.pbMessage("Yo") if temparray[i] != nil
         #     Kernel.pbMessage("Ya") if myarray[i] != nil
            end
        #    Kernel.pbMessage($3.to_s+" theirs immediate")
                             #Kernel.pbMessage(myarray[tempi].to_s+" mine")
           #      Kernel.pbMessage(temparray[tempi].to_s+" theirs")
           for i in 0..10
           #      Kernel.pbMessage(@turnRandoms[i].to_s+" randoms2")
               end
               

            if @TIEVAR!=1 && @TIEVAR!=2
#              Kernel.pbMessage("0")
              tempi=0
              while 1==1
                if (temparray[tempi]==nil || myarray[tempi]==nil) && temparray[0] != nil && temparray[1] != nil
                   if temparray[0]+temparray[1] > myarray[0]+myarray[1]
                     @TIEVAR=1
                     break
                   else
                     @TIEVAR=2
                     break
                   end
                 elsif temparray[tempi]==nil || myarray[tempi]==nil
                   @TIEVAR=pbRandom(1)+1
                     break
                     
                end
                                
                 if temparray[tempi] > myarray[tempi]
                   @TIEVAR=1
                   break
                 elsif temparray[tempi] < myarray[tempi]
                   @TIEVAR=2
                   break
                 end
                 tempi += 1
              end
            elsif @TIEVAR==1
              @TIEVAR=2
            else
              @TIEVAR=1
            end
          
            break

            when /<BAT choices=(.*)>/ 
          raise "crash"

          when /<BAT dead>/
            @decision = 1
            Kernel.pbMessage("Other player disconnected.")
            return pbEndOfBattle
            
          end
        end
    @choices[1][2]=@battlers[1].moves[@choices[1][1]] if @choices[1][0] == 1 # Need to reset move object
    
    if isConst?(@battlers[1].moves[@choices[1][1]].id,PBMoves,:SUCKERPUNCH)
      #Kernel.pbMessage("yap")
      @battlers[1].effects[PBEffects::SuckerPunch]=true
    end

    
    receive_seed  
   
    break if @decision>0
      PBDebug.logonerr{

         pbAttackPhase

      }
      break if @decision>0
      PBDebug.logonerr{
         pbEndOfRoundPhase
      }
      break if @decision>0
      @turncount+=1
    end
    return pbEndOfBattle(canlose)
  end

################################################################################
# Command phase.
################################################################################
  def pbCommandMenu(i)
    return @scene.pbCommandMenu(i)
  end

  def pbItemMenu(i)
    return @scene.pbItemMenu(i)
  end

  def pbAutoFightMenu(i)
    return false
  end

  def pbCommandPhase
    @scene.pbBeginCommandPhase
    for i in 0...4   # Reset choices if commands can be shown
      if pbCanShowCommands?(i) || @battlers[i].hp<=0
        @choices[i][0]=0
        @choices[i][1]=0
        @choices[i][2]=nil
        @choices[i][3]=-1
      else
        battler=@battlers[i]
        PBDebug.log("[reusing commands for #{battler.pbThis}]") unless !@doublebattle && pbIsDoubleBattler?(i)
      end
    end
    for i in 0...4
      break if @decision!=0
      if !pbOwnedByPlayer?(i) || @controlPlayer
        if @battlers[i].hp>0 && pbCanShowCommands?(i)
          @scene.pbChooseEnemyCommand(i)
        end
      else
        commandDone=false
        commandEnd=false
        if pbCanShowCommands?(i)
          loop do
            cmd=pbCommandMenu(i)
            if cmd==0 # Fight
              if pbCanShowFightMenu?(i)
                commandDone=true if pbAutoFightMenu(i)
                until commandDone
                  index=@scene.pbFightMenu(i)
                  break if index<0
                  next if !pbRegisterMove(i,index)
                  if @doublebattle
                    thismove=@battlers[i].moves[index]
                    target=@battlers[i].pbTarget(thismove)
                    if target==PBTargets::SingleNonUser # single non-user
                      target=@scene.pbChooseTarget(i)
                      next if target<0
                      pbRegisterTarget(i,target)
                    elsif target==PBTargets::UserOrPartner # Acupressure
                      target=@scene.pbChooseTarget(i)
                      next if target<0 || (target&1)==1
                      pbRegisterTarget(i,target)
                    end
                  end
                  commandDone=true
                end
              else
                pbAutoChooseMove(i)
                commandDone=true
              end
            elsif cmd==2 # Bag
              if !@internalbattle
                if pbOwnedByPlayer?(i)
                  pbDisplay(_INTL("Items can't be used here."))
                end
              else
                item=pbItemMenu(i)
                if item>0
                  pbRegisterItem(i,item)
                  commandDone=true
                end
              end
            elsif cmd==1 # Pokémon
              pkmn=pbSwitchPlayer(i,false,true)
              if pkmn>=0
                commandDone=true if pbRegisterSwitch(i,pkmn)
              end
            elsif cmd==3   # Run
              run=pbRun(i) 
              if run > 0
                commandDone=true
                return
              elsif run < 0
                commandDone=true
              end
            elsif cmd==4   # Call
              thispkmn=@battlers[i]
              @choices[i][0]=4   # "Call Pokémon"
              @choices[i][1]=0
              @choices[i][2]=nil
                            $mega_battlers[i]=false

              commandDone=true
            elsif cmd==-1   # Go back to first battler's choice
              pbCommandPhase
              return
            end
            break if commandDone
          end
        end
      end
    end
  end
  

################################################################################
# Attack phase.
################################################################################
  def pbAttackPhase
#        Kernel.pbMessage("BattleTest1")

    @scene.pbBeginAttackPhase
    for i in 0...4
      @successStates[i].clear
    end

    for i in 0...4
      if @choices[i][0]==4
        pbCall(i)
      end
      if @choices[i][0]!=1 && choices[i][0]!=2
        @battlers[i].effects[PBEffects::DestinyBond]=false
        @battlers[i].effects[PBEffects::Grudge]=false
      end
    end
    for i in 0...4
      if pbIsOpposing?(i) && @choices[i][0]==3
        pbEnemyUseItem(@choices[i][1],@battlers[i])
      end
    end
    for i in 0...4
      if @battlers[i].hp>0
        @battlers[i].turncount+=1
      end
    end
    for i in 0...4
      if !pbChoseMove?(i,:RAGE)
        @battlers[i].effects[PBEffects::Rage]=false
      end
    end
        for i in 0..3
          if !pbChoseMove2?(i,@battlers[i].effects[PBEffects::Metronome])
            @battlers[i].effects[PBEffects::MetronomeCounter]=-1
          end
        end

        for i in 0..3
          if !pbChoseMove2?(i,@battlers[i].effects[PBEffects::Pendulum])
            @battlers[i].effects[PBEffects::PendulumCounter]=-1
          end
        end
    @switching=true
    switched=[]

    for i in 0...4 # in order from own first, opposing first, own second, opposing second
      if @choices[i][0]==2
        index=@choices[i][1] # party position of Pokémon to switch to
        self.lastMoveUser=i
        if !pbOwnedByPlayer?(i)
          owner=pbGetOwner(i)
          pbDisplayBrief(_INTL("{1} withdrew {2}!",owner.fullname,battlers[i].name))
        else
          pbDisplayBrief(_INTL("{1}, that's enough!\r\nCome back!",battlers[i].name))
        end
        for j in [3,2,1,0] # in reverse order
          next if !@battlers[i].pbIsOpposing?(j)
          # if Pursuit and this target ("i") was chosen
          if pbChoseMoveFunctionCode?(j,0x88) && (@choices[j][3]==-1 || @choices[j][3]==i)
            if @battlers[j].status!=PBStatuses::SLEEP &&
               @battlers[j].status!=PBStatuses::FROZEN &&
               (!isConst?(@battlers[j].ability,PBAbilities,:TRUANT) || !@battlers[j].effects[PBEffects::Truant])
              @battlers[j].pbUseMove(@choices[j])
              @battlers[j].effects[PBEffects::Pursuit]=true
              #UseMove calls pbGainEXP as appropriate
              @switching=false
              return if @decision>0
            end
          end
          break if @battlers[i].hp<=0
        end
        if !pbRecallAndReplace(i,index)
          # If a forced switch somehow occurs here in single battles
          # the attack phase now ends
          if !@doublebattle
            @switching=false
            return
          end
        else
          switched.push(i)
        end
      end
    end

    if switched.length>0
      priority=pbPriority
      for i in priority
        i.pbAbilitiesOnSwitchIn(true) if switched.include?(i.index)
      end
    end

    @switching=false
    # calculate priority at this time
    @usepriority=false  # recalculate priority
    priority=pbPriority
    #for i in priority
    #  if pbChoseMoveFunctionCode?(i.index,0x115) # Focus Punch
    #    pbCommonAnimation("FocusPunch",i,nil)
    #    pbDisplay(_INTL("{1} is tightening its focus!",i.pbThis))
    #  end
    #end
        priority=pbPriority
    for i in priority #its not actually sending the mega evolution switch through the server.F
      next if @choices[i.index][0]!=1
  #    side=(pbIsOpposing?(i.index)) ? 1 : 0
  #    owner=pbGetOwnerIndex(i.index)
      if $mega_battlers[i.index]
        pbMegaEvolve(i.index)
      end
    end
    
     for i in priority
      next if @choices[i.index][0]!=1
      thismove=@choices[i.index][2]
       if isConst?(i.species,PBSpecies,:EEVEE) && i.form>0
        if i.type1 != thismove.type || i.type2 != thismove.type
        case thismove.type
          when PBTypes::NORMAL
            i.pokemon.form=1
          when PBTypes::WATER
            i.pokemon.form=2
          when PBTypes::ELECTRIC
            i.pokemon.form=3
          when PBTypes::FIRE
            i.pokemon.form=4
          when PBTypes::PSYCHIC
            i.pokemon.form=5
          when PBTypes::DARK
            i.pokemon.form=6
          when PBTypes::GRASS
            i.pokemon.form=7
          when PBTypes::ICE
            i.pokemon.form=8
          when PBTypes::FAIRY
            i.pokemon.form=9
          end
          i.pbCheckForm
          @usepriority=false
          priority=pbPriority
        end
      end
    end
    
    
    for i in priority
      i.pbProcessTurn(@choices[i.index])
      return if @decision>0
    end

    
        for i in priority
 if i.hp>0  && i.ability==PBAbilities::LERNEAN
        if (100*i.pokemon.totalhp)/i.pokemon.hp <= 90 && i.form<5 #60%, 9 heads 
          i.form=5
          i.pokemon.form=5
        elsif (100*i.pokemon.totalhp)/i.pokemon.hp <= 80 && i.form<4 #60%, 8 heads 
          i.form=4
          i.pokemon.form=4
        elsif (100*i.pokemon.totalhp)/i.pokemon.hp <= 60 && i.form<3 #60%, 7 heads
         i.form=3
         i.pokemon.form=3
        elsif (100*i.pokemon.totalhp)/i.pokemon.hp <= 50 && i.form<2 #60%, 6 heads
          i.form=2
          i.pokemon.form=2
        else
          #i.form=1
        end
        
      end
      end

    
    pbWait(20)
  end

################################################################################
# End of round.
################################################################################
  def pbEndOfRoundPhase
    for i in 0...4
      @battlers[i].effects[PBEffects::Roost]=false
      @battlers[i].effects[PBEffects::Protect]=false
      @battlers[i].effects[PBEffects::ProtectNegation]=false
      @battlers[i].effects[PBEffects::KingsShield]=false
      @battlers[i].effects[PBEffects::Endure]=false
      @battlers[i].effects[PBEffects::HyperBeam]-=1 if @battlers[i].effects[PBEffects::HyperBeam]>0
    end
    @usepriority=false  # recalculate priority
    priority=pbPriority
    # Weather
      if @trickroom > 0
      @trickroom=@trickroom-1
      if @trickroom == 0
          pbDisplay("The twisted dimensions returned to normal!")
        end
      end
      
       if @grassyterrain > 0
      @grassyterrain=@grassyterrain-1
      if @grassyterrain == 0
          Kernel.pbMessage("The grassy terrain returned to normal!")
      end
    end
    
     if @electricterrain > 0
      @electricterrain=@electricterrain-1
      if @electricterrain == 0
          Kernel.pbMessage("The electric terrain returned to normal!")
        end
      end
          for i in 0..3
        if @battlers[i].effects[PBEffects::Unleafed] > 0
          @battlers[i].effects[PBEffects::Unleafed] -= 1
          if @battlers[i].effects[PBEffects::Unleafed] == 0
if @battlers[i].form>2
             # @battlers[i].form -= 2
              @battlers[i].pokemon.form -= 2
              @battlers[i].pbReduceStatBasic(PBStats::SPEED,1)
              @battlers[i].pbReduceStatBasic(PBStats::SPATK,1)
              @battlers[i].pbReduceStatBasic(PBStats::SPDEF,1)
              @battlers[i].pbReduceStatBasic(PBStats::ATTACK,1)
              @battlers[i].pbReduceStatBasic(PBStats::DEFENSE,1)
              @battlers[index].pbCheckForm

            pbDisplay(@battlers[i].pbThis+" cooled down.")
            end            
          end
        end
      end
       if @mistyterrain > 0
      @mistyterrain=@mistyterrain-1
      if @mistyterrain == 0
          Kernel.pbMessage("The misty terrain returned to normal!")
      end
    end
    
    if @wonderroom > 0
      @wonderroom=@wonderroom-1
      if @wonderroom == 0
          Kernel.pbMessage("The Magic Room returned to normal!")
      end
      
    end
    
    
        if @deltastream
            cornhole=false
       for i in @battlers
           cornhole =true if i.hp>0 && i.ability==PBAbilities::DELTASTREAM
       end
       if !cornhole
       @weatherduration=0
          pbDisplay(_INTL("The Delta Stream faded."))
          @weather=0
          @deltastream=false
        @scene.pbBackdropMove(0,true,true)
      end
end
    if @primordialsea
            cornhole=false
       for i in @battlers
           cornhole =true if i.hp>0 && i.ability==PBAbilities::PRIMORDIALSEA
       end
       if !cornhole
       @weatherduration=0
          pbDisplay(_INTL("The heavy rain faded."))
          
          @primordialsea=false
          @weather=0
        @scene.pbBackdropMove(0,true,true)
      end

    end
    
    if @desolateland
      cornhole=false
       for i in @battlers
           cornhole =true if i.hp>0 && i.ability==PBAbilities::DESOLATELAND
       end
       if !cornhole
       @weatherduration=0
          pbDisplay(_INTL("The intense sunlight faded."))
          @desolateland=false
          @weather=0
        @scene.pbBackdropMove(0,true,true)
      end
      
    end

    
    case @weather
      when PBWeather::SUNNYDAY
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sunlight faded."))
          @weather=0
        else
          pbCommonAnimation("Sunny",nil,nil)
          pbDisplay(_INTL("The sunlight is strong."));
          if pbWeather==PBWeather::SUNNYDAY
            for i in priority
              next if i.hp<=0
              if isConst?(i.ability,PBAbilities,:SOLARPOWER)
                pbDisplay(_INTL("{1} was hurt by the sunlight!",i.pbThis))
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP((i.totalhp/8).floor)
                if i.hp<=0
                  return if !i.pbFaint
                end
              end
            end
          end
        end
      when PBWeather::RAINDANCE
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The rain stopped."))
          @weather=0
        else
          pbCommonAnimation("Rain",nil,nil)
          pbDisplay(_INTL("Rain continues to fall."));
        end
                when PBWeather::NEWMOON
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sky brightened again."))
          @weather=0
        else
          @scene.pbMoveAnimation("NewMoon",nil,nil)
          pbDisplay(_INTL("The sky is dark."));
                    if pbWeather==PBWeather::NEWMOON
            for i in priority
              next if i.hp<=0
              if isConst?(i.ability,PBAbilities,:ABSOLUTION)
                pbDisplay(_INTL("{1} was hurt by the fog!",i.pbThis))
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP(i.totalhp/8)
                if i.hp<=0
                  return if !i.pbFaint
                end
              end
            end
          end

        end

      when PBWeather::SANDSTORM
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sandstorm subsided."))
          @weather=0
        else
          pbCommonAnimation("Sandstorm",nil,nil)
          pbDisplay(_INTL("The sandstorm rages."));
          if pbWeather==PBWeather::SANDSTORM
            for i in priority
              next if i.hp<=0
              if !i.pbHasType?(:GROUND) && !i.pbHasType?(:ROCK) && !i.pbHasType?(:STEEL) &&
                 !isConst?(i.ability,PBAbilities,:SANDVEIL) &&
                 !isConst?(i.ability,PBAbilities,:SANDRUSH) &&
                 !isConst?(i.ability,PBAbilities,:SANDFORCE) &&
                 !isConst?(i.ability,PBAbilities,:MAGICGUARD) &&
                 !isConst?(i.ability,PBAbilities,:OVERCOAT) &&
                 ![0xCA,0xCB].include?(PBMoveData.new(i.effects[PBEffects::TwoTurnAttack]).function) # Dig, Dive
                pbDisplay(_INTL("{1} was buffeted by the sandstorm!",i.pbThis))
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP((i.totalhp/16).floor)
                if i.hp<=0
                  return if !i.pbFaint
                end
              end
            end
          end
        end
      when PBWeather::HAIL
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The hail stopped."))
          @weather=0
        else
          pbCommonAnimation("Hail",nil,nil)
          pbDisplay(_INTL("Hail continues to fall."));
          if pbWeather==PBWeather::HAIL
            for i in priority
              next if i.hp<=0
              if !i.pbHasType?(:ICE) &&
                 !isConst?(i.ability,PBAbilities,:ICEBODY) &&
                 !isConst?(i.ability,PBAbilities,:SNOWCLOAK) &&
                 !isConst?(i.ability,PBAbilities,:MAGICGUARD) &&
                                  !isConst?(i.ability,PBAbilities,:SNOWWARNING) &&

                 !isConst?(i.ability,PBAbilities,:OVERCOAT) &&
                 ![0xCA,0xCB].include?(PBMoveData.new(i.effects[PBEffects::TwoTurnAttack]).function) # Dig, Dive
                sleetExists=false
                for j in priority
                  if j.ability==PBAbilities::SLEET
                    sleetExists=true
                  end
                end
                
                pbDisplay(_INTL("{1} was pelted by hail!",i.pbThis)) if !sleetExists
                pbDisplay(_INTL("{1} was bombarded by the heavy sleet!",i.pbThis)) if sleetExists
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP(i.totalhp/16) if !sleetExists
                i.pbReduceHP(i.totalhp/5) if sleetExists
                if i.hp<=0
                  return if !i.pbFaint
                end
              end
            end
          end
        end
    end
    # Shadow Sky weather
    if isConst?(@weather,PBWeather,:SHADOWSKY)
      @weatherduration=@weatherduration-1 if @weatherduration>0
      if @weatherduration==0
        pbDisplay(_INTL("The shadow sky faded."))
        @weather=0
      else
        pbCommonAnimation("ShadowSky",nil,nil)
        pbDisplay(_INTL("The shadow sky continues."));
        if isConst?(pbWeather,PBWeather,:SHADOWSKY)
          for i in priority
            next if i.hp<=0
            if !i.isShadow?
              pbDisplay(_INTL("{1} was hurt by the shadow sky!",i.pbThis))
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP((i.totalhp/16).floor)
              if i.hp<=0
                return if !i.pbFaint
              end
            end
          end
        end
      end
    end
    # Future Sight/Doom Desire
    for i in battlers   # not priority
      next if i.hp<=0
      if i.hp>0 && i.effects[PBEffects::FutureSight]>0
        i.effects[PBEffects::FutureSight]-=1
        if i.effects[PBEffects::FutureSight]==0
          move=PokeBattle_Move.pbFromPBMove(self,PBMove.new(i.effects[PBEffects::FutureSightMove]))
          pbDisplay(_INTL("{1} took the {2} attack!",i.pbThis,move.name))
          moveuser=@battlers[i.effects[PBEffects::FutureSightUser]]
          if i.hp<=0 || move.pbAccuracyCheck(moveuser,i)
            damage=((i.effects[PBEffects::FutureSightDamage]*85)/100).floor
            damage=1 if damage<1
            i.damagestate.reset
            pbCommonAnimation("FutureSight",i,nil)
            move.pbReduceHPDamage(damage,nil,i)
          else
            pbDisplay(_INTL("But it failed!"))
          end
          i.effects[PBEffects::FutureSight]=0
          i.effects[PBEffects::FutureSightMove]=0
          i.effects[PBEffects::FutureSightDamage]=0
          i.effects[PBEffects::FutureSightUser]=-1
          if i.hp<=0
            return if !i.pbFaint
            next
          end
        end
      end
    end
    for i in priority
      next if i.hp<=0
      vaccine=false
      for j in @battlers
          vaccine=true if j.ability==PBAbilities::VAPORIZATION
      end
      if vaccine && (isConst?(i.ability,PBAbilities,:DRYSKIN) || i.pbHasType?(PBTypes::WATER))
                  hploss=i.pbReduceHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s was vaporized",i.pbThis)) if hploss>0
      end
      # Rain Dish
      if pbWeather==PBWeather::RAINDANCE && isConst?(i.ability,PBAbilities,:RAINDISH)
        hpgain=i.pbRecoverHP((i.totalhp/16).floor,true)
        pbDisplay(_INTL("{1}'s Rain Dish restored its HP a little!",i.pbThis)) if hpgain>0
      end
      # Dry Skin
      if isConst?(i.ability,PBAbilities,:DRYSKIN)
        if pbWeather==PBWeather::RAINDANCE
          hpgain=i.pbRecoverHP((i.totalhp/8).floor,true)
          pbDisplay(_INTL("{1}'s Dry Skin was healed by the rain!",i.pbThis)) if hpgain>0
        elsif pbWeather==PBWeather::SUNNYDAY
          @scene.pbDamageAnimation(i,0)
          hploss=i.pbReduceHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s Dry Skin was hurt by the sunlight!",i.pbThis)) if hploss>0
        end
      end
            if isConst?(i.ability,PBAbilities,:HELIOPHOBIA)
        if @weather==PBWeather::NEWMOON
          hpgain=i.pbRecoverHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s Heliophobia was healed by the darkness!",i.pbThis)) if hpgain >0
      
        end
      end

      # Ice Body
      if pbWeather==PBWeather::HAIL && isConst?(i.ability,PBAbilities,:ICEBODY)
        hpgain=i.pbRecoverHP((i.totalhp/16).floor,true)
        pbDisplay(_INTL("{1}'s Ice Body restored its HP a little!",i.pbThis)) if hpgain>0
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Wish
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Wish]>0
        i.effects[PBEffects::Wish]-=1
        if i.effects[PBEffects::Wish]==0 && i.hp>0
          hpgain=i.pbRecoverHP(i.effects[PBEffects::WishAmount],true)
          if hpgain>0
            wishmaker=pbThisEx(i.index,i.effects[PBEffects::WishMaker])
            pbDisplay(_INTL("{1}'s wish came true!",wishmaker))
          end
        end
      end
    end
    # Fire Pledge + Grass Pledge combination damage - should go here
    for i in priority
      next if i.hp<=0
      # Shed Skin
      if isConst?(i.ability,PBAbilities,:SHEDSKIN)
        if pbRandom(10)<3 && i.status>0
          case i.status
            when PBStatuses::SLEEP
              pbDisplay(_INTL("{1}'s Shed Skin cured its sleep problem!",i.pbThis))
            when PBStatuses::FROZEN
              pbDisplay(_INTL("{1}'s Shed Skin cured its ice problem!",i.pbThis))
            when PBStatuses::BURN
              pbDisplay(_INTL("{1}'s Shed Skin cured its burn problem!",i.pbThis))
            when PBStatuses::POISON
              pbDisplay(_INTL("{1}'s Shed Skin cured its poison problem!",i.pbThis))
            when PBStatuses::PARALYSIS
              pbDisplay(_INTL("{1}'s Shed Skin cured its paralysis problem!",i.pbThis))
          end
          i.status=0
          i.statusCount=0
        end
      end
      # Hydration
      if isConst?(i.ability,PBAbilities,:HYDRATION) && pbWeather==PBWeather::RAINDANCE
        if i.status>0
          case i.status
            when PBStatuses::SLEEP
              pbDisplay(_INTL("{1}'s Hydration cured its sleep problem!",i.pbThis))
            when PBStatuses::FROZEN
              pbDisplay(_INTL("{1}'s Hydration cured its ice problem!",i.pbThis))
            when PBStatuses::BURN
              pbDisplay(_INTL("{1}'s Hydration cured its burn problem!",i.pbThis))
            when PBStatuses::POISON
              pbDisplay(_INTL("{1}'s Hydration cured its poison problem!",i.pbThis))
            when PBStatuses::PARALYSIS
              pbDisplay(_INTL("{1}'s Hydration cured its paralysis problem!",i.pbThis))
          end
          i.status=0
          i.statusCount=0
        end
      end
      # Healer
      if isConst?(i.ability,PBAbilities,:HEALER)
        partner=i.pbPartner
        if partner
          if pbRandom(10)<3 && partner.status>0
            case partner.status
              when PBStatuses::SLEEP
                pbDisplay(_INTL("{1}'s Healer cured its partner's sleep problem!",i.pbThis))
              when PBStatuses::FROZEN
                pbDisplay(_INTL("{1}'s Healer cured its partner's ice problem!",i.pbThis))
              when PBStatuses::BURN
                pbDisplay(_INTL("{1}'s Healer cured its partner's burn problem!",i.pbThis))
              when PBStatuses::POISON
                pbDisplay(_INTL("{1}'s Healer cured its partner's poison problem!",i.pbThis))
              when PBStatuses::PARALYSIS
                pbDisplay(_INTL("{1}'s Healer cured its partner's paralysis problem!",i.pbThis))
            end
            partner.status=0
            partner.statusCount=0
          end
        end
      end
    end
    # Held berries/Leftovers/Black Sludge
    for i in priority
      next if i.hp<=0
      i.pbBerryCureCheck(true)
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Aqua Ring
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::AquaRing]
        hpgain=(i.totalhp/16).floor
        hpgain=(hpgain*1.3).floor if isConst?(i.item,PBItems,:BIGROOT)
        hpgain=i.pbRecoverHP(hpgain,true)
        pbDisplay(_INTL("{1}'s Aqua Ring restored its HP a little!",i.pbThis)) if hpgain>0
      end
    end
    # Ingrain
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Ingrain]
        hpgain=(i.totalhp/16).floor
        hpgain=(hpgain*1.3).floor if isConst?(i.item,PBItems,:BIGROOT)
        hpgain=i.pbRecoverHP(hpgain,true)
        pbDisplay(_INTL("{1} absorbed nutrients with its roots!",i.pbThis)) if hpgain>0
      end
    end
    # Leech Seed
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::LeechSeed]>=0
        recipient=@battlers[i.effects[PBEffects::LeechSeed]]
        if recipient && recipient.hp>0 # if recipient exists
#          pbCommonAnimation("LeechSeed",recipient,i)
          hploss=i.pbReduceHP((i.totalhp/8).floor,true)
          if isConst?(i.ability,PBAbilities,:LIQUIDOOZE)
            recipient.pbReduceHP(hploss,true)
            pbDisplay(_INTL("{1} sucked up the liquid ooze!",recipient.pbThis))
          elsif recipient.effects[PBEffects::HealBlock]==0
            hploss=(hploss*1.3).floor if isConst?(recipient.item,PBItems,:BIGROOT)
            recipient.pbRecoverHP(hploss,true)
            pbDisplay(_INTL("{1}'s health was sapped by Leech Seed!",i.pbThis))
          end
          i.pbFaint if i.hp<=0
          recipient.pbFaint if recipient.hp<=0
        end
      end
    end
    for i in priority
      next if i.hp<=0
      # Poison/Bad poison
      if i.status==PBStatuses::POISON
        if isConst?(i.ability,PBAbilities,:POISONHEAL)
          if i.effects[PBEffects:HealBlock]==0
            if i.hp<i.totalhp
              pbCommonAnimation("Poison",i,nil)
              i.pbRecoverHP((i.totalhp/8).floor,true)
              pbDisplay(_INTL("{1} is healed by poison!",i.pbThis))
            end
            if i.statusCount>0
              i.effects[PBEffects::Toxic]+=1
              i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
            end
          end
        else
          pbDisplay(_INTL("{1} is hurt by poison!",i.pbThis))
          pbCommonAnimation("Poison",i,nil)
          if i.statusCount==0
            i.pbReduceHP((i.totalhp/8).floor)
          else
            i.effects[PBEffects::Toxic]+=1
            i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
            i.pbReduceHP((i.totalhp/16).floor*i.effects[PBEffects::Toxic])
          end
        end
      end
      # Burn
      if i.status==PBStatuses::BURN
        pbCommonAnimation("Burn",i,nil)
        pbDisplay(_INTL("{1} is hurt by its burn!",i.pbThis))
        if isConst?(i.ability,PBAbilities,:HEATPROOF)
          i.pbReduceHP((i.totalhp/16).floor)
        else
          i.pbReduceHP((i.totalhp/8).floor)
        end
      end
      # Nightmare
      if i.effects[PBEffects::Nightmare]
        if i.status==PBStatuses::SLEEP
          pbDisplay(_INTL("{1} is locked in a nightmare!",i.pbThis))
          i.pbReduceHP((i.totalhp/4).floor,true)
        else
          i.effects[PBEffects::Nightmare]=false
        end
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Curse
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Curse]
        pbDisplay(_INTL("{1} is afflicted by the curse!",i.pbThis))
        i.pbReduceHP((i.totalhp/4).floor,true)
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Multi-turn attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    begin
          for i in priority
          next if i.hp<=0
          if i.effects[PBEffects::MultiTurn]>0
            i.effects[PBEffects::MultiTurn]-=1
            movename=PBMoves.getName(i.effects[PBEffects::MultiTurnAttack])
            if i.effects[PBEffects::MultiTurn]==0
              pbDisplay(_INTL("{1} was freed from {2}!",i.pbThis,movename))
            else
              pbDisplay(_INTL("{1} is hurt by {2}!",i.pbThis,movename))
              if isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:BIND)
                pbCommonAnimation("Bind",i,nil)
              elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:CLAMP)
                pbCommonAnimation("Clamp",i,nil)
              elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:FIRESPIN)
                pbCommonAnimation("FireSpin",i,nil)
              elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:MAGMASTORM)
                pbCommonAnimation("MagmaStorm",i,nil)
              elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:SANDTOMB)
                pbCommonAnimation("SandTomb",i,nil)
              elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:WRAP)
                pbCommonAnimation("Wrap",i,nil)
              else
                pbCommonAnimation("Wrap",i,nil)
              end
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP((i.totalhp/8).floor)
            end
          end  
          if i.hp<=0
            return if !i.pbFaint
            next
          end
        end
      rescue
    end
      
    # Taunt
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Taunt]>0
        i.effects[PBEffects::Taunt]-=1
        if i.effects[PBEffects::Taunt]==0
          pbDisplay(_INTL("{1} recovered from the taunting!",i.pbThis))
        end 
      end
    end
    # Encore
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Encore]>0
        if i.moves[i.effects[PBEffects::EncoreIndex]].id!=i.effects[PBEffects::EncoreMove]
          i.effects[PBEffects::Encore]=0
          i.effects[PBEffects::EncoreIndex]=0
          i.effects[PBEffects::EncoreMove]=0
        else
          i.effects[PBEffects::Encore]-=1
          if i.effects[PBEffects::Encore]==0 || i.moves[i.effects[PBEffects::EncoreIndex]].pp==0
            i.effects[PBEffects::Encore]=0
            pbDisplay(_INTL("{1}'s encore ended!",i.pbThis))
          end 
        end
      end
    end
    # Disable/Cursed Body
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Disable]>0
        i.effects[PBEffects::Disable]-=1
        if i.effects[PBEffects::Disable]==0
          i.effects[PBEffects::DisableMove]=0
          pbDisplay(_INTL("{1} is disabled no more!",i.pbThis))
        end
      end
    end
    # Magnet Rise
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::MagnetRise]>0
        i.effects[PBEffects::MagnetRise]-=1
        if i.effects[PBEffects::MagnetRise]==0
          pbDisplay(_INTL("{1} stopped levitating.",i.pbThis))
        end
      end
    end
    # Telekinesis
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Telekinesis]>0
        i.effects[PBEffects::Telekinesis]-=1
        if i.effects[PBEffects::Telekinesis]==0
          pbDisplay(_INTL("{1} stopped levitating.",i.pbThis))
        end
      end
    end
    # Heal Block
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::HealBlock]>0
        i.effects[PBEffects::HealBlock]-=1
        if i.effects[PBEffects::HealBlock]==0
          pbDisplay(_INTL("The heal block on {1} ended.",i.pbThis))
        end
      end
    end
    # Embargo
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Embargo]>0
        i.effects[PBEffects::Embargo]-=1
        if i.effects[PBEffects::Embargo]==0
          pbDisplay(_INTL("The embargo on {1} was lifted.",i.pbThis(true)))
        end
      end
    end
    # Yawn
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Yawn]>0
        i.effects[PBEffects::Yawn]-=1
        if i.effects[PBEffects::Yawn]==0 && i.pbCanSleepYawn?
          i.pbSleep
          pbDisplay(_INTL("{1} fell asleep!",i.pbThis))
        end
      end
    end
    # Perish Song
    perishSongUsers=[]
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::PerishSong]>0
        i.effects[PBEffects::PerishSong]-=1
        pbDisplay(_INTL("{1}'s Perish count fell to {2}!",i.pbThis,i.effects[PBEffects::PerishSong]))
        if i.effects[PBEffects::PerishSong]==0
          perishSongUsers.push(i.effects[PBEffects::PerishSongUser])
          i.pbReduceHP(i.hp,true)
        end
      end
      if i.hp<=0
        return if !i.pbFaint
      end
    end
    if perishSongUsers.length>0
      # If all remaining Pokemon fainted by a Perish Song triggered by a single side
      if (perishSongUsers.find_all{|item| pbIsOpposing?(item) }.length==perishSongUsers.length) ||
         (perishSongUsers.find_all{|item| !pbIsOpposing?(item) }.length==perishSongUsers.length)
        pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
      end
    end
    if @decision>0
      pbGainEXP
      return
    end
    # Reflect
    for i in 0...2
      if sides[i].effects[PBEffects::Reflect]>0
        sides[i].effects[PBEffects::Reflect]-=1
        if sides[i].effects[PBEffects::Reflect]==0
          pbDisplay(_INTL("Your team's Reflect faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Reflect faded!")) if i==1
        end
      end
    end
    # Light Screen
    for i in 0...2
      if sides[i].effects[PBEffects::LightScreen]>0
        sides[i].effects[PBEffects::LightScreen]-=1
        if sides[i].effects[PBEffects::LightScreen]==0
          pbDisplay(_INTL("Your team's Light Screen faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Light Screen faded!")) if i==1
        end
      end
    end
    # Safeguard
    for i in 0...2
      if sides[i].effects[PBEffects::Safeguard]>0
        sides[i].effects[PBEffects::Safeguard]-=1
        if sides[i].effects[PBEffects::Safeguard]==0
          pbDisplay(_INTL("The opposing team is no longer protected by Safeguard!")) if i==0
          pbDisplay(_INTL("Your team is no longer protected by Safeguard!")) if i==1
        end
      end
    end
    # Mist
    for i in 0...2
      if sides[i].effects[PBEffects::Mist]>0
        sides[i].effects[PBEffects::Mist]-=1
        if sides[i].effects[PBEffects::Mist]==0
          pbDisplay(_INTL("Your team's Mist faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Mist faded!")) if i==1
        end
      end
    end
    # Tailwind
    for i in 0...2
      if sides[i].effects[PBEffects::Tailwind]>0
        sides[i].effects[PBEffects::Tailwind]-=1
        if sides[i].effects[PBEffects::Tailwind]==0
          pbDisplay(_INTL("Your team's tailwind stopped blowing!")) if i==0
          pbDisplay(_INTL("The opposing team's tailwind stopped blowing!")) if i==1
        end
      end
    end
    # Lucky Chant
    for i in 0...2
      if sides[i].effects[PBEffects::LuckyChant]>0
        sides[i].effects[PBEffects::LuckyChant]-=1
        if sides[i].effects[PBEffects::LuckyChant]==0
          pbDisplay(_INTL("Your team's Lucky Chant faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Lucky Chant faded!")) if i==1
        end
      end
    end
    # End of Pledge move combinations - should go here
    # Gravity
    if sides[0].effects[PBEffects::Gravity]>0 ||
       sides[1].effects[PBEffects::Gravity]>0
      gravity=[sides[0].effects[PBEffects::Gravity],
               sides[1].effects[PBEffects::Gravity]].max
      gravity-=1
      sides[0].effects[PBEffects::Gravity] = gravity
      sides[1].effects[PBEffects::Gravity] = gravity
      if gravity==0
        pbDisplay(_INTL("Gravity returned to normal."))
      end
    end
    # Trick Room - should go here
    # Wonder Room - should go here
    # Magic Room
    if sides[0].effects[PBEffects::MagicRoom] > 0 ||
       sides[1].effects[PBEffects::MagicRoom] > 0
      magicroom=[sides[0].effects[PBEffects::MagicRoom],
                 sides[1].effects[PBEffects::MagicRoom]].max
      magicroom-=1
      sides[0].effects[PBEffects::MagicRoom] = magicroom
      sides[1].effects[PBEffects::MagicRoom] = magicroom
      if magicroom==0
        pbDisplay(_INTL("The area returned to normal."))
      end
    end
    # Uproar
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Uproar]>0
        for j in priority
          if j.hp>0 && j.status==PBStatuses::SLEEP && !isConst?(j.ability,PBAbilities,:SOUNDPROOF)
            j.effects[PBEffects::Nightmare]=false
            j.status=0
            j.statusCount=0
            pbDisplay(_INTL("{1} woke up in the uproar!",j.pbThis))
          end
        end
        i.effects[PBEffects::Uproar]-=1
        if i.effects[PBEffects::Uproar]==0
          pbDisplay(_INTL("{1} calmed down.",i.pbThis))
        else
          pbDisplay(_INTL("{1} is making an uproar!",i.pbThis)) 
        end
      end
    end
    for i in priority
      next if i.hp<=0
      # Speed Boost
      # A Pokémon's turncount is 0 if it became active after the beginning of a round
      if i.turncount>0 && isConst?(i.ability,PBAbilities,:SPEEDBOOST)
        if !i.pbTooHigh?(PBStats::SPEED)
          i.pbIncreaseStatBasic(PBStats::SPEED,1)
          pbCommonAnimation("StatUp",i,nil)
          pbDisplay(_INTL("{1}'s Speed Boost raised its Speed!",i.pbThis))
        end 
      end
      # Bad Dreams
      if i.status==PBStatuses::SLEEP
        if isConst?(i.pbOpposing1.ability,PBAbilities,:BADDREAMS) ||
           isConst?(i.pbOpposing2.ability,PBAbilities,:BADDREAMS)
          hploss=i.pbReduceHP((i.totalhp/8).floor,true)
          pbDisplay(_INTL("{1} is having a bad dream!",i.pbThis)) if hploss>0
        end
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
      # Harvest - should go here
      # Moody
      if isConst?(i.ability,PBAbilities,:MOODY)
        randoms=[]
        loop do
          rand=1+self.pbRandom(7)
          if !i.pbTooHigh?(rand)
            randoms.push(rand)
            break
          end
        end
        loop do
          rand=1+self.pbRandom(7)
          if !i.pbTooLow?(rand) && rand!=randoms[0]
            randoms.push(rand)
            break
          end
        end
        statnames=[_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),_INTL("Special Attack"),
                   _INTL("Special Defense"),_INTL("accuracy"),_INTL("evasiveness")]
        i.stages[randoms[0]]+=2
        i.stages[randoms[0]]=6 if i.stages[randoms[0]]>6
        pbCommonAnimation("StatUp",i,nil)
        pbDisplay(_INTL("{1}'s Moody sharply raised its {2}!",i.pbThis,statnames[randoms[0]-1]))
        i.stages[randoms[1]]-=1
        pbCommonAnimation("StatDown",i,nil)
        pbDisplay(_INTL("{1}'s Moody lowered its {2}!",i.pbThis,statnames[randoms[1]-1]))
      end
    end
    for i in priority
      next if i.hp<=0
      # Toxic Orb
      if isConst?(i.item,PBItems,:TOXICORB) && i.status==0 && i.pbCanPoison?(false)
        i.status=PBStatuses::POISON
        i.statusCount=1
        i.effects[PBEffects::Toxic]=0
        pbCommonAnimation("Poison",i,nil)
        pbDisplay(_INTL("{1} was poisoned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Flame Orb
      if isConst?(i.item,PBItems,:FLAMEORB) && i.status==0 && i.pbCanBurn?(false)
        i.status=PBStatuses::BURN
        i.statusCount=0
        pbCommonAnimation("Burn",i,nil)
        pbDisplay(_INTL("{1} was burned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Sticky Barb
      if isConst?(i.item,PBItems,:STICKYBARB) && !isConst?(i.ability,PBAbilities,:MAGICGUARD)
        pbDisplay(_INTL("{1} is hurt by its {2}!",i.pbThis,PBItems.getName(i.item)))
        @scene.pbDamageAnimation(i,0)
        i.pbReduceHP((i.totalhp/8).floor)
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Form checks
    for i in 0...4
      next if @battlers[i].hp<=0
      @battlers[i].pbCheckForm
    end
    pbGainEXP
    pbSwitch
    return if @decision>0
    for i in priority
      next if i.hp<=0
      i.pbAbilitiesOnSwitchIn(false)
    end
    # Healing Wish/Lunar Dance - should go here
    # Spikes/Toxic Spikes/Stealth Rock - should go here (in order of their 1st use)
    for i in 0...4
      if @battlers[i].turncount>0 && isConst?(@battlers[i].ability,PBAbilities,:TRUANT)
        @battlers[i].effects[PBEffects::Truant]=!@battlers[i].effects[PBEffects::Truant]
      end
      if @battlers[i].effects[PBEffects::LockOn]>0   # Also Mind Reader
        @battlers[i].effects[PBEffects::LockOn]-=1
        @battlers[i].effects[PBEffects::LockOnPos]=-1 if @battlers[i].effects[PBEffects::LockOn]==0
      end
      @battlers[i].effects[PBEffects::Flinch]=false
      @battlers[i].effects[PBEffects::FollowMe]=false
      @battlers[i].effects[PBEffects::HelpingHand]=false
      @battlers[i].effects[PBEffects::MagicCoat]=false
      @battlers[i].effects[PBEffects::Snatch]=false
      @battlers[i].effects[PBEffects::Charge]-=1 if @battlers[i].effects[PBEffects::Charge]>0
      @battlers[i].lastHPLost=0
      @battlers[i].lastAttacker=-1
      @battlers[i].effects[PBEffects::Counter]=-1
      @battlers[i].effects[PBEffects::CounterTarget]=-1
      @battlers[i].effects[PBEffects::MirrorCoat]=-1
      @battlers[i].effects[PBEffects::MirrorCoatTarget]=-1
    end
    # invalidate stored priority
    @usepriority=false
  end

################################################################################
# End of battle.
################################################################################
  def pbEndOfBattle(canlose=false)
    
    case @decision
    ##### WIN #####

      when 1
        if @opponent
          $network.send("<BAT\twinner>")
          @scene.pbTrainerBattleSuccess
          if @opponent.is_a?(Array)
            pbDisplayPaused(_INTL("{1} defeated {2} and {3}!",self.pbPlayer.name,@opponent[0].fullname,@opponent[1].fullname))
          else
            pbDisplayPaused(_INTL("{1} defeated\r\n{2}!",self.pbPlayer.name,@opponent.fullname))
          end
          @scene.pbShowOpponent(0)
          pbDisplayPaused(@endspeech.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
          if @opponent.is_a?(Array)
            @scene.pbHideOpponent
            @scene.pbShowOpponent(1)
            pbDisplayPaused(@endspeech2.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
          end
          # Calculate money gained for winning
          if Options::ONLINEGAINMONEY == true
          if @internalbattle
            maxlevel=0
            for i in @party2
              next if !i
              maxlevel=i.level if maxlevel<i.level
            end
            if @opponent.is_a?(Array)
              maxlevel*=@opponent[0].moneyEarned+@opponent[1].moneyEarned
            else
              maxlevel*=@opponent.moneyEarned
            end
            # If Amulet Coin/Luck Incense's effect applies, double money earned
            maxlevel*=2 if @amuletcoin
            oldmoney=self.pbPlayer.money
            self.pbPlayer.money+=maxlevel
            moneygained=self.pbPlayer.money-oldmoney
            if moneygained>0
              pbDisplayPaused(_INTL("{1} got ${2}\r\nfor winning!",self.pbPlayer.name,maxlevel))
            end
          end
        end
        if @internalbattle && @extramoney>0
          @extramoney*=2 if @amuletcoin
          pbDisplayPaused(_INTL("{1} picked up ${2}!",self.pbPlayer.name,@extramoney))      
          self.pbPlayer.money+=@extramoney
        end
        end
    ##### LOSE, DRAW #####
      when 2, 5
        if @internalbattle
          pbDisplayPaused(_INTL("{1} is out of usable Pokémon!",self.pbPlayer.name))
          if Options::ONLINEGAINMONEY == true
          moneylost=pbMaxLevel(@party1)
          multiplier=[8,16,24,36,48,60,80,100,120]
          moneylost*=multiplier[[multiplier.length-1,self.pbPlayer.numbadges].min]
          moneylost=self.pbPlayer.money if moneylost>self.pbPlayer.money
          moneylost=0 if $game_switches[NO_MONEY_LOSS]
          self.pbPlayer.money-=moneylost
          if @opponent
            if @opponent.is_a?(Array)
              pbDisplayPaused(_INTL("{1} lost against {2} and {3}!",self.pbPlayer.name,@opponent[0].fullname,@opponent[1].fullname))
            else
              pbDisplayPaused(_INTL("{1} lost against\r\n{2}!",self.pbPlayer.name,@opponent.fullname))
            end
            if moneylost>0
              pbDisplayPaused(_INTL("{1} paid ${2}\r\nas the prize money...",self.pbPlayer.name,moneylost))  
              pbDisplayPaused(_INTL("...")) if !canlose
            end
          else
            if moneylost>0
              pbDisplayPaused(_INTL("{1} panicked and lost\r\n${2}...",self.pbPlayer.name,moneylost))
              pbDisplayPaused(_INTL("...")) if !canlose
            end
          end
          end
          pbDisplayPaused(_INTL("{1} blacked out!",self.pbPlayer.name)) if !canlose
        elsif @decision==2
          @scene.pbShowOpponent(0)
          pbDisplayPaused(@endspeechwin.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
          if @opponent.is_a?(Array)
            @scene.pbHideOpponent
            @scene.pbShowOpponent(1)
            pbDisplayPaused(@endspeechwin2.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
          end
        elsif @decision==5
          PBDebug.log("[Draw game]") if $INTERNAL
        end
    end
    # Pass on Pokérus within the party
    infected=[]
    for i in 0...$Trainer.party.length
      if $Trainer.party[i].pokerusStage==1
        infected.push(i)
      end
    end
    if infected.length>=1
      for i in infected
        strain=$Trainer.party[i].pokerus/16
        if i>0 && $Trainer.party[i-1].pokerusStage==0
          $Trainer.party[i-1].givePokerus(strain) if pbRandom(3)==0
        end
        if i<$Trainer.party.length-1 && $Trainer.party[i+1].pokerusStage==0
          $Trainer.party[i+1].givePokerus(strain) if pbRandom(3)==0
        end
      end
    end
    @scene.pbEndBattle(@decision)
    for i in @battlers
      i.pbResetForm
    end
    for i in $Trainer.party
      i.item=i.itemInitial
      i.itemInitial=i.itemRecycle=0
    end
    $network.send("<DSC>")
    return @decision
  end
end