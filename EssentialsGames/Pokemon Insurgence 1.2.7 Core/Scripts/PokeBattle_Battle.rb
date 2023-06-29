class PokeBattle_NullBattlePeer
  def pbStorePokemon(player,pokemon)
    if player.party.length<6 && !$game_switches[347]
      player.party[player.party.length]=pokemon
      return -1
    else
      return -1
    end
  end

  def pbOnEnteringBattle(battle,pokemon)
  end

  def pbGetStorageCreator()
    return nil
  end

  def pbCurrentBox()
    return -1
  end

  def pbBoxName(box)
    return ""
  end 
end



class PokeBattle_BattlePeer
  def self.create
    return PokeBattle_NullBattlePeer.new()
  end
end



class PokeBattle_SuccessState
  attr_accessor :typemod
  attr_accessor :useState # 0 - not used, 1 - failed, 2 - succeeded
  attr_accessor :protected
  attr_accessor :skill

  def initialize
    clear
  end

  def clear
    @typemod=4
    @useState=0
    @protected=false
    @skill=0
  end

  def updateSkill
    if @useState==1 && !@protected
      @skill-=2
    elsif @useState==2
      if @typemod>4
        @skill+=2 # "Super effective"
      elsif @typemod>=1 && @typemod<4
        @skill-=1 # "Not very effective"
      elsif @typemod==0
        @skill-=2 # Ineffective
      else
        @skill+=1
      end
    end
    @typemod=4
    @useState=0
    @protected=false
  end
end


module PokeBattle_BattleCommon
  def pbStorePokemon(pokemon)
    $Trainer.owned[pokemon.species]=true if $game_switches[354]
    if !(pokemon.isShadow? rescue false)
    if $game_switches[71]
      species=PBSpecies.getName(pokemon.species)
      species=pbGetMessage(MessageTypes::Species,pokemon.species,true) if $game_switches[354]
      if species.split().last=="♂" || species.split().last=="♀"
        species=species.name[0..-2]
      end
      genderSymbol=""
      if pokemon.gender==0
        genderSymbol=" "+_INTL("♂")
      elsif pokemon.gender==1
        genderSymbol=" "+_INTL("♀")
      end
      $game_switches[697]=true
      nickname=@scene.pbNameEntry(_INTL("{1}'s{2} nickname?",species,genderSymbol))
      $game_switches[697]=false
      pokemon.name=nickname if nickname!="" 
    elsif pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?",pokemon.name))
      species=PBSpecies.getName(pokemon.species)
      if species.split().last=="♂" || species.split().last=="♀"
        species=species.name[0..-2]
      end
      genderSymbol=""
      if pokemon.gender==0
        genderSymbol=" "+_INTL("♂")
      elsif pokemon.gender==1
        genderSymbol=" "+_INTL("♀")
      end
      $game_switches[697]=true
      nickname=@scene.pbNameEntry(_INTL("{1}'s{2} nickname?",species,genderSymbol))
      $game_switches[697]=false
      pokemon.name=nickname if nickname!="" 
    end
    else
      # $wasshadow = true
    end
    if pokemon.name=="??? ???"
      pokemon.name=species=pbGetMessage(MessageTypes::Species,pokemon.species,true)
    end
    oldcurbox=@peer.pbCurrentBox()
    storedbox=@peer.pbStorePokemon(self.pbPlayer,pokemon)
    creator=@peer.pbGetStorageCreator()
    return if storedbox<0
    curboxname=@peer.pbBoxName(oldcurbox)
    boxname=@peer.pbBoxName(storedbox)
    if storedbox!=oldcurbox
      if creator
        pbDisplayPaused(_INTL("Box \"{1}\" on {2}'s PC was full.",curboxname,creator))
      else
        pbDisplayPaused(_INTL("Box \"{1}\" on someone's PC was full.",curboxname))
      end
      pbDisplayPaused(_INTL("{1} was transferred to box \"{2}\".",pokemon.name,boxname))
    else
      if creator
        pbDisplayPaused(_INTL("{1} was transferred to {2}'s PC.",pokemon.name,creator))
      else
        pbDisplayPaused(_INTL("{1} was transferred to someone's PC.",pokemon.name))
      end
      pbDisplayPaused(_INTL("It was stored in box \"{1}\".",boxname))
    end
  end
  
  def pbThrowPokeBall(idxPokemon,ball,rareness=nil)
    itemname=PBItems.getName(ball)
    battler=nil
    if pbIsOpposing?(idxPokemon)
      battler=self.battlers[idxPokemon]
    else
      battler=self.battlers[idxPokemon].pbOppositeOpposing
    end
    if battler.hp<=0
      battler=battler.pbPartner
    end
    #$game_switches[359]=true
    pbDisplayBrief(_INTL("{1} threw one {2}!",self.pbPlayer.name,itemname))
    if battler.hp<=0
      pbDisplay(_INTL("But there was no target..."))
      return
    end
    # if battler.hp<=0
    #   pbDisplay(_INTL("A Pokemon couldn't be targeted in ..."))
    #   return
    #end
    if $game_switches[259]
      pbDisplay(_INTL("This is your Pokemon! Why are you trying to catch it?"))
      return
    end
    if @opponent && (!pbIsSnagBall?(ball) || !battler.isShadow?)
      @scene.pbThrowAndDeflect(ball,1)
      pbDisplay(_INTL("The Trainer blocked the Ball!\nDon't be a thief!"))
    else
      pokemon=battler.pokemon
      species=pokemon.species
      if !rareness
        dexdata=pbOpenDexData
        pbDexDataOffset(dexdata,species,16)
        rareness=dexdata.fgetb # Get rareness from dexdata file
        dexdata.close
      end
      a=battler.totalhp
      b=battler.hp
      rareness=BallHandlers.modifyCatchRate(ball,rareness,self,battler)
      x=(((a*3-b*2)*rareness)/(a*3)).floor
      if battler.status==PBStatuses::SLEEP || battler.status==PBStatuses::FROZEN
        x=(x*2.5).floor
      elsif battler.status!=0
        x=(x*3/2).floor
      end
      shakes=0
      if x>255 || BallHandlers.isUnconditional?(ball,self,battler)
        shakes=4
      else
        x=1 if x==0
        y = 0x000FFFF0 / (Math.sqrt(Math.sqrt( 0x00FF0000/x ) ) )
        shakes+=1 if pbRandom(65536)<y
        shakes+=1 if pbRandom(65536)<y
        shakes+=1 if pbRandom(65536)<y
        shakes+=1 if pbRandom(65536)<y 
      end
      @scene.pbThrow(ball,shakes,battler.index)
      case shakes
      when 0
        pbDisplay(_INTL("Oh no!  The Pokémon broke free!"))
      when 1
        pbDisplay(_INTL("Aww... It appeared to be caught!"))
      when 2
        pbDisplay(_INTL("Aargh!  Almost had it!"))
      when 3
        pbDisplay(_INTL("Shoot!  It was so close, too!"))
      when 4
        pbDisplayBrief(_INTL("Gotcha!  {1} was caught!",pokemon.name))
        if $game_map.map_id==463
          pokemon.item=0
          pokemon.form=0
        end
        if $game_map.map_id==541
          pokemon.form=0
        end
        $game_switches[563]=true if pokemon.species==PBSpecies::CRESSELIA
        if (pokemon.species==PBSpecies::ZYGARDE && pokemon.form==2) || 
           pokemon.species==PBSpecies::REGIGIGAS ||
           (pokemon.species==PBSpecies::ARCEUS && pokemon.form==19) ||
           (pokemon.species==PBSpecies::GIRATINA && pokemon.form==2)
          pokemon.primalBattle(false)
          pokemon.form=0 
        end
        @scene.pbThrowSuccess
        pbGainEXP(true) if !pbInSafari?
        if pbIsSnagBall?(ball) && @opponent
          pbRemoveFromParty(battler.index,battler.pokemonIndex)
          battler.pbReset
          battler.participants=[]
        else
          @decision=4
        end
        if pbIsSnagBall?(ball)
          pokemon.ot=self.pbPlayer.name
          pokemon.trainerID=self.pbPlayer.id
          pokemon.ot="Gold" if isConst?(species,PBSpecies,:HOOH) || isConst?(species,PBSpecies,:LUGIA)
        end
        BallHandlers.onCatch(ball,self,pokemon)
        pokemon.ballused=pbGetBallType(ball)
        if isConst?(species,PBSpecies,:HOOPA)
          $game_switches[341]=true
        end
        if !self.pbPlayer.owned[species]
          self.pbPlayer.owned[species]=true
          if $Trainer.pokedex
            pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.",pokemon.name))
            @scene.pbShowPokedex(species) if !pbIsSnagBall?(ball)
            $wasshadow=true
          end
        end
        if pbIsSnagBall?(ball) && @opponent
          pokemon.pbUpdateShadowMoves rescue nil
          $wasshadow=true
          @snaggedpokemon.push(pokemon)
        else
          pbStorePokemon(pokemon)
        end
      end
    end
  end
end



class PokeBattle_Battle
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
  attr_reader(:party2)            # Foe's Pokémon party
  attr_reader(:party1order)       # Order of Pokémon in the player's party
  attr_reader(:party2order)       # Order of Pokémon in the opponent's party
  attr_accessor(:fullparty1)      # True if player's party's max size is 6 instead of 3
  attr_accessor(:fullparty2)      # True if opponent's party's max size is 6 instead of 3
  attr_reader(:battlers)          # Currently active Pokémon
  attr_accessor(:items)           # Items held by opponents
  #attr_accessor(:trickroom)
  #attr_accessor(:mistyterrain)
  #attr_accessor(:primordialsea)
  #attr_accessor(:desolateland)
  #attr_accessor(:deltastream)
  attr_accessor(:wonderroom)
  attr_reader(:sides)             # Effects common to each side of a battle
  attr_reader(:field)             # Effects common to the whole of a battle
  attr_accessor(:environment)     # Battle surroundings
  attr_accessor(:weather)         # Current weather, custom methods should use pbWeather instead
  attr_accessor(:weatherduration) # Duration of current weather, or -1 if indefinite
  attr_reader(:phase)             # Phase of the round.
  attr_reader(:switching)         # True if during the switching phase of the round
  attr_reader(:futuresight)       # True if Future Sight is hitting
  attr_reader(:struggle)          # The Struggle move
  attr_accessor(:choices)         # Choices made by each Pokémon this round
  attr_reader(:successStates)     # Success states
  attr_accessor(:lastMoveUsed)    # Last move used
  attr_accessor(:lastMoveUturn)   # Specifies that Uturn/Volt Switch/Baton Pass was used (for Choice items)
  attr_accessor(:lastMoveUser)    # Last move user
  attr_accessor(:synchronize)     # Synchronize state
  attr_accessor(:amuletcoin)      # Whether Amulet Coin's effect applies
  attr_accessor(:moneygained)     # Money gained in battle by using Pay Day
  attr_accessor(:doublemoney)     # Whether Happy Hour's effect applies
  attr_accessor(:endspeech)       # Speech by opponent when player wins
  attr_accessor(:endspeech2)      # Speech by opponent when player wins
  attr_accessor(:endspeechwin)    # Speech by opponent when opponent wins
  attr_accessor(:endspeechwin2)   # Speech by opponent when opponent wins
  attr_accessor(:rules)
  attr_reader(:turncount)
  attr_accessor :controlPlayer
  attr_accessor(:aimove)
  include PokeBattle_BattleCommon

  class BattleAbortedException < Exception; end

  def pbAbort
    raise BattleAbortedException.new("Battle aborted")
  end

  def initialize(scene,p1,p2,player,opponent)
    @scene=scene
    @party1=p1
    @party2=p2
    @party1order     = []
    for i in 0...12; @party1order.push(i); end
    @party2order     = []
    for i in 0...12; @party2order.push(i); end
    @peer=PokeBattle_BattlePeer.create()
    if opponent && player.is_a?(Array) && player.length==0
      player=player[0]
    end
    if opponent && opponent.is_a?(Array) && opponent.length==0
      opponent=opponent[0]
    end
    @player=player # PokeBattle_Trainer object
    @opponent=opponent # PokeBattle_Trainer object
    @environment=PBEnvironment::None # Environment for battle (ex. Tall grass, caves, still water...)
    @weatherduration=0
    @decision=0
    @rules={}
    @battlers=[]
    #@trickroom=0
    #@primordialsea=false
    #@desolateland=false
    #@deltastream=false
    #@mistyterrain=0
    @wonderroom=0
    @sides=[]
    @field= PokeBattle_ActiveField.new    # Whole field (gravity/rooms)
    @priority=[]
    $idboxused = false
    @player.megaforme = false if !(@player.kind_of?(Array))
    @player[0].megaforme = false if (@player.kind_of?(Array))
    @player[1].megaforme = false if (@player.kind_of?(Array))

    @participants=[]
    @successStates=[]
    for i in 0...4
      @successStates.push(PokeBattle_SuccessState.new)
    end
    @switching=false
    @aimove=false
    @futuresight=false
    @items=nil
    #    @megaEvolution = []
    #    @megaEvolution[0]=[-1]
   #     @megaEvolution[0][1]=Array.new
   # if @player.is_a?(Array)
   #   @megaEvolution[0]=[-1]*@player.length
   # else
   #   @megaEvolution[0]=[-1]
   # end
   $mega_battlers = Array.new
   
    @synchronize=[-1,-1,0]
    @internalbattle=true
    @usepriority=false
    @shiftStyle=true
    @battlescene=true
    @fullparty1=false
    @fullparty2=false
    @snaggedpokemon=[]
    if hasConst?(PBMoves,:STRUGGLE)
      @struggle=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:STRUGGLE)))
    else
      @struggle=PokeBattle_Struggle.new(self,nil)
    end

    @ab_protect=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:PROTECT)))
    @ab_sleeppowder=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:SLEEPPOWDER)))
    @ab_thunderwave=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:THUNDERWAVE)))
    @ab_toxic=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:TOXIC)))
    @ab_confuseray=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:CONFUSERAY)))
    @ab_medusaray=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:MEDUSARAY)))
    @ab_falseswipe=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:FALSESWIPE)))

    @ab_vcreate=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:VCREATE)))
    @ab_doomdesire=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:DOOMDESIRE)))
    @ab_seedflare=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:SEEDFLARE)))
    @ab_mistball=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:MISTBALL)))
    @ab_lusterpurge=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:LUSTERPURGE)))
    @ab_roaroftime=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:ROAROFTIME)))
    @ab_spacialrend=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:SPACIALREND)))
    @ab_sacredsword=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:SACREDSWORD)))
    @ab_darkvoid=PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:DARKVOID)))

    @struggle.pp=-1

    @ab_protect.pp=-1
        @ab_sleeppowder.pp=-1
    @ab_thunderwave.pp=-1
    @ab_toxic.pp=-1
    @ab_confuseray.pp=-1
    @ab_medusaray.pp=-1
    @ab_falseswipe.pp=-1
    @ab_vcreate.pp=-1
    @ab_doomdesire.pp=-1
    @ab_seedflare.pp=-1
    @ab_mistball.pp=-1
    @ab_lusterpurge.pp=-1
    @ab_spacialrend.pp=-1
    @ab_sacredsword.pp=-1
    @ab_darkvoid.pp=-1

    @lastMoveUsed=-1
    #@lastMoveUsed=false
    @lastMoveUser=-1
    @nextPickupUse   = 0
    @debug=false
    @debugupdate=0
    @endspeech=""
    @endspeech2=""
    @endspeechwin=""
    @endspeechwin2=""
    @doublebattle=false
    @runCommand=0
    @amuletcoin=false
    @moneygained=0
    @doublemoney=false
    @turncount=0
    @choices=[ [0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1] ]
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
    sides[0]=PokeBattle_ActiveSide.new # player's side
    sides[1]=PokeBattle_ActiveSide.new # foe's side
    for i in 0..3
      battlers[i]=PokeBattle_Battler.new(self,i)
    end
    for i in @party1
      next if !i
      i.itemRecycle=0
      i.itemInitial=i.item
      i.belch=false
      i.burstAttack=false
    end
    for i in @party2
      next if !i
      i.itemRecycle=0
      i.itemInitial=i.item
      i.belch=false
      i.burstAttack=false
    end
    @decision=0
    @opponent=opponent
    @weather=0
  end

  def pbIsOpposing?(index)
    return (index%2)==1
  end

  def pbIsDoubleBattler?(index)
    return (index>=2)
  end

  def pbParty(index)
    return pbIsOpposing?(index) ? party2 : party1
  end
  
  def pbOpposingParty(index)
    return pbIsOpposing?(index) ? party1 : party2
  end
  
  def pbSecondPartyBegin(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return @fullparty2 ? 6 : 3
    else
      return @fullparty1 ? 6 : 3
    end
  end

  def pbPartyLength(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return (@opponent.is_a?(Array)) ? pbSecondPartyBegin(battlerIndex) : MAXPARTYSIZE
    else
      return @player.is_a?(Array) ? pbSecondPartyBegin(battlerIndex) : MAXPARTYSIZE
    end
  end
  
  def pbGetLastPokeInTeam(index)
    party=pbParty(index)
    partyorder=(!pbIsOpposing?(index)) ? @party1order : @party2order
    plength=pbPartyLength(index)
    pstart=pbGetOwnerIndex(index)*plength
    lastpoke=-1
    for i in pstart...pstart+plength
      p=party[partyorder[i]]
      next if !p || p.egg? || p.hp<=0
      lastpoke=partyorder[i]
    end
    return lastpoke
  end
  
  def pbGetSecondLastPokeInTeam(index)
    party=pbParty(index)
    partyorder=(!pbIsOpposing?(index)) ? @party1order : @party2order
    plength=pbPartyLength(index)
    pmodlength=plength-1
    pstart=pbGetOwnerIndex(index)*plength
    lastpoke=-1
    for i in pstart...pstart+pmodlength
      p=party[partyorder[i]]
      next if !p || p.egg? || p.hp<=0
      lastpoke=partyorder[i]
    end
    return lastpoke
  end
  
  def pbGetLastExcludeTarget(index,target)
    party=pbParty(index)
    partyorder=(!pbIsOpposing?(index)) ? @party1order : @party2order
    plength=pbPartyLength(index)
    pstart=pbGetOwnerIndex(index)*plength
    lastpoke=-1
    for i in pstart...pstart+plength
      p=party[partyorder[i]]
      next if !p || p.egg? || p.hp<=0 || p==target
      lastpoke=partyorder[i]
    end
    return lastpoke
  end

  def pbThisEx(battlerindex,pokemonindex)
    party=pbParty(battlerindex)
    if pbIsOpposing?(battlerindex)
      if @opponent
        pokename=party[pokemonindex].name
        #pokename = $illusionnames[battlerindex] if $illusion != nil && $illusionnames != nil && $illusionnames[battlerindex] != nil && $illusion[battlerindex] != nil && (@battler[battlerindex].pokemon.hasWorkingAbility(:ILLUSION) || @battler[battlerindex].pokemon.species==PBSpecies::ZOROARK)

        return _INTL("The foe {1}",pokename)
      else
        return _INTL("The wild {1}",party[pokemonindex].name)
      end
    else
      return _INTL("{1}",party[pokemonindex].name)
    end
  end

  def pbFindNextUnfainted(party,start,finish=-1)
    finish=party.length if finish<0
    for i in start...finish
      next if !party[i]
      if party[i].hp>0 && !party[i].egg?
        return i
      end
    end
    return -1
  end


  def pbOwnedByPlayer?(index)
    return false if pbIsOpposing?(index)
    return false if @player.is_a?(Array) && index==2
    return true
  end

  def pbSecondPartyBegin(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return @fullparty2 ? 6 : 3
    else
      return @fullparty1 ? 6 : 3
    end
  end

  def pbRemoveFromParty(battlerIndex,partyIndex)
    party=pbParty(battlerIndex)
    side=(pbIsOpposing?(battlerIndex)) ? @opponent : @player
    party[partyIndex]=nil
    if !side || !side.is_a?(Array) # Wild or single opponent
      party.compact!
    else
      j=0
      for i in 0...pbSecondPartyBegin(battlerIndex)
        if party[i]
          party[j]=party[i]
          j+=1
        end
      end
      j=pbSecondPartyBegin(battlerIndex)
      for i in pbSecondPartyBegin(battlerIndex)...party.length
        if party[i]
          party[j]=party[i]
          j+=1
        end
      end
    end
  end

  def pbAddToPlayerParty(pokemon)
    party=pbParty(0)
    for i in 0...party.length
      if pbIsOwner?(0,i) && !party[i]
        party[i]=pokemon
      end
    end
  end

  def pbIsOwner?(battlerIndex,partyIndex)
    secondParty=pbSecondPartyBegin(battlerIndex)
    if !pbIsOpposing?(battlerIndex)
      if !@player || !@player.is_a?(Array)
        return true
      end
      return (battlerIndex==0) ? partyIndex<secondParty : partyIndex>=secondParty
    else
      if !@opponent || !@opponent.is_a?(Array)
        return true
      end
      return (battlerIndex==1) ? partyIndex<secondParty : partyIndex>=secondParty
    end
  end
  
  def pbGetOwnerIndex(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return (@opponent.is_a?(Array)) ? ((battlerIndex==1) ? 0 : 1) : 0
    else
      return (@player.is_a?(Array)) ? ((battlerIndex==0) ? 0 : 1) : 0
    end
  end
  
  def pbBelongsToPlayer?(battlerIndex)
    if @player.is_a?(Array) && @player.length>1
      return battlerIndex==0
    else
      return (battlerIndex%2)==0
    end
    return false
  end

  def pbPartyGetOwner(battlerIndex,partyIndex)
    secondParty=pbSecondPartyBegin(battlerIndex)
    if !pbIsOpposing?(battlerIndex)
      if !@player || !@player.is_a?(Array)
        return @player
      end
      return (partyIndex<secondParty) ? @player[0] : @player[1]
    else
      if !@opponent || !@opponent.is_a?(Array)
        return @opponent
      end
      return (partyIndex<secondParty) ? @opponent[0] : @opponent[1]
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

  def pbPlayer
    if @player.is_a?(Array)
      return @player[0]
    else
      return @player
    end
  end

  def pbSetSeen(pokemon)
    if pokemon && @internalbattle
      self.pbPlayer.seen[pokemon.species]=true
      pbSeenForm(pokemon)
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

# Return value
# 0 - Undecided or aborted
# 1 - Win
# 2 - Loss
# 3 - Escaped or match forfeited
# 4 - Wild Pokemon was caught
# 5 - Draw
  def pbStartBattle(canlose=false,theyflee=false)
    begin
      pbStartBattleCore(canlose,theyflee)
      rescue BattleAbortedException
      @decision=0
      @scene.pbEndBattle(@decision)
    end
    return @decision
  end

  MAXPARTYSIZE=6

  def pbDoubleBattleAllowed? #candoubleup
    return true
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

  def pbStartBattleCore(canlose,theyflee=false)

    if !@fullparty1 && @party1.length>MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 1 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@fullparty2 && @party2.length>MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 2 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
#    if @opponent && @opponent.is_a?(Array)
#  @doublebattle=true
#    end
        if @opponent && (@opponent.is_a?(Array) || @player.is_a?(Array)) && @doublebattle==false
      return
    end
    if !@opponent
#########################
# Initialize wild Pokémon
#########################
      if @party2.length==1
        if @doublebattle
          raise _INTL("Only two wild Pokémon are allowed in double battles")
        end
        wildpoke=@party2[0]
        @battlers[1].pbInitialize(wildpoke,0,false)
        @peer.pbOnEnteringBattle(self,wildpoke)
        pbSetSeen(wildpoke)
        @scene.pbStartBattle(self)
        if $game_switches[259]
            pbDisplayPaused(_INTL("{1}'s {2} appeared!",wildpoke.ot,wildpoke.name))
else
        pbDisplayPaused(_INTL("Wild {1} appeared!",wildpoke.name))
        if $game_switches[562]
                  pbDisplayPaused(_INTL("It looks familiar... did Diana release this?",wildpoke.name))
        end
        end
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
########################################
# Initialize opponents in double battles
########################################
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
        sendoutname1=@party2[sendout1].name

        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[0].fullname,@party2[sendout1].name)) if @party2[sendout1].ability!=PBAbilities::ILLUSION
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[0].fullname,@party2[@party2.length-1].name)) if @party2[sendout1].ability==PBAbilities::ILLUSION
        
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbSendOut(1,@party2[sendout1])
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[1].fullname,@party2[sendout2].name)) if @party2[sendout2].ability!=PBAbilities::ILLUSION
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[1].fullname,@party2[@party2.length-1].name)) if @party2[sendout2].ability==PBAbilities::ILLUSION
        pbSendOut(3,@party2[sendout2])
      else
        pbDisplayPaused(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        if sendout1<0 || sendout2<0
          raise _INTL("Opponent doesn't have two unfainted Pokémon")
        end
        pbDisplayBrief(_INTL("{1} sent\r\nout {2} and {3}!",
           @opponent.fullname,@party2[sendout1].name,@party2[sendout2].name)) if @party2[sendout1].ability!=PBAbilities::ILLUSION && @party2[sendout2].ability!=PBAbilities::ILLUSION
        pbDisplayBrief(_INTL("{1} sent\r\nout {2} and {3}!",
           @opponent.fullname,@party2[@party2.length-1].name,@party2[sendout2].name)) if @party2[sendout1].ability==PBAbilities::ILLUSION && @party2[sendout2].ability!=PBAbilities::ILLUSION
        pbDisplayBrief(_INTL("{1} sent\r\nout {2} and {3}!",
           @opponent.fullname,@party2[sendout1].name,@party2[@party2.length-1].name)) if @party2[sendout1].ability!=PBAbilities::ILLUSION && @party2[sendout2].ability==PBAbilities::ILLUSION
        pbDisplayBrief(_INTL("{1} sent\r\nout {2} and {3}!",
           @opponent.fullname,@party2[@party2.length-1].name,@party2[@party2.length-1].name)) if @party2[sendout1].ability==PBAbilities::ILLUSION && @party2[sendout2].ability==PBAbilities::ILLUSION
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbSendOut(1,@party2[sendout1])
        pbSendOut(3,@party2[sendout2])
      end
    else
#######################################
# Initialize opponent in single battles
#######################################
      
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
      trainerpoke=@party2[0] #if @party2[0].ability!=PBAbilities::ILLUSION
      trainerpokename=@party2[0].name if  @party2[0].ability!=PBAbilities::ILLUSION
      trainerpokename=@party2[@party2.length-1].name if @party2[0].ability==PBAbilities::ILLUSION
      @scene.pbStartBattle(self)
      
      pbDisplayPaused(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent.fullname,trainerpokename))      
      @battlers[1].pbInitialize(trainerpoke,sendout,false)
      pbSendOut(1,trainerpoke)
      $game_switches[190]=false
      
    end
    
######################################
# Initialize players in double battles
######################################
  #  Kernel.pbMessage(@party1[0].name+" "+@party1[0].hp.to_s)
  #  Kernel.pbMessage(@party1[1].name+" "+@party1[1].hp.to_s)
  #  Kernel.pbMessage(@party1[6].name+" "+@party1[6 ].hp.to_s)
    @party1=$Trainer.party if !@player.is_a?(Array)
    sendout1=0
    sendout1=pbFindNextUnfainted(@party1,0) if !@player.is_a?(Array)
  #  Kernel.pbMessage(sendout1.to_s)
    
    if @doublebattle && pbFindNextUnfainted(@party1,0) > -1 && sendout2=pbFindNextUnfainted(@party1,sendout1+1) > -1
      if @player.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
        raise _INTL("Player 1 has no unfainted Pokémon") if sendout1<0
        sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
        raise _INTL("Player 2 has no unfainted Pokémon") if sendout2<0
        @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
        @battlers[2].pbInitialize(@party1[sendout2],sendout2,false) if !$game_switches[346] || @player.is_a?(Array)
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!  Go! {3}!",
          @player[1].fullname,@battlers[2].name,@battlers[0].name),false) if $is_insane
           #@player[1].fullname,@party1[sendout2].name,@party1[sendout1].name),false) if $is_insane
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!  Go! {3}!",
          @player[1].fullname,@battlers[2].name,@battlers[0].name)) if !$is_insane
           #@player[1].fullname,@party1[sendout2].name,@party1[sendout1].name)) if !$is_insane
        pbSetSeen(@party1[sendout1])
        pbSetSeen(@party1[sendout2])
      else
        sendout1=pbFindNextUnfainted(@party1,0)
        sendout2=pbFindNextUnfainted(@party1,sendout1+1)
        tempneed=false
        if sendout1<0 || sendout2<0
          #if !$game_switches[346]
           # raise _INTL("Player doesn't have two unfainted Pokémon")
          #else
          @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
          @battlers[2].pbInitialize(@party1[sendout2],sendout2,false) if !$game_switches[346] || @player.is_a?(Array)
          pbDisplayBrief(_INTL("Go! {1}!",@battlers[0].name),false) if $is_insane
          pbDisplayBrief(_INTL("Go! {1}!",@battlers[0].name)) if !$is_insane
          #pbDisplayBrief(_INTL("Go! {1}!",@party1[sendout1].name),false) if $is_insane
          #pbDisplayBrief(_INTL("Go! {1}!",@party1[sendout1].name)) if !$is_insane
          #end
        else
          @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
          @battlers[2].pbInitialize(@party1[sendout2],sendout2,false) if !$game_switches[346] || @player.is_a?(Array)
          pbDisplayBrief(_INTL("Go! {1} and {2}!",@battlers[0].name,@battlers[2].name),false) if $is_insane
          pbDisplayBrief(_INTL("Go! {1} and {2}!",@battlers[0].name,@battlers[2].name)) if !$is_insane
          #pbDisplayBrief(_INTL("Go! {1} and {2}!",@party1[sendout1].name,@party1[sendout2].name),false) if $is_insane
          #pbDisplayBrief(_INTL("Go! {1} and {2}!",@party1[sendout1].name,@party1[sendout2].name)) if !$is_insane
        end
      
      end
      #@battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
      #@battlers[2].pbInitialize(@party1[sendout2],sendout2,false) if !$game_switches[346] || @player.is_a?(Array)
      pbSendOut(0,@party1[sendout1])
      pbSendOut(2,@party1[sendout2]) if !$game_switches[346] || @player.is_a?(Array)
    else
#####################################
# Initialize player in single battles
#####################################
      sendout=pbFindNextUnfainted(@party1,0)
      if sendout<0
        raise _INTL("Player has no unfainted Pokémon")
      end
      playerpoke=@party1[sendout]
      @battlers[0].pbInitialize(playerpoke,sendout1,false)
      pbDisplayBrief(_INTL("Go! {1}!",@battlers[0].name),false) if $is_insane
      pbDisplayBrief(_INTL("Go! {1}!",@battlers[0].name)) if !$is_insane
      #pbDisplayBrief(_INTL("Go! {1}!",playerpoke.name),false) if $is_insane
      #pbDisplayBrief(_INTL("Go! {1}!",playerpoke.name)) if !$is_insane
      @battlers[0].pbInitialize(playerpoke,sendout,false)
      pbSendOut(0,playerpoke)

    end
###################
# Initialize battle
###################
    if @weather==PBWeather::SUNNYDAY
      @scene.pbBackdropMove(0,true,true)
      @scene.pbMoveAnimation("Sunny",nil,nil)
      @scene.pbRefresh
      pbDisplay(_INTL("The sunlight is strong."))
    elsif @weather==PBWeather::RAINDANCE
      @scene.pbBackdropMove(0,true,true)
      @scene.pbMoveAnimation("Rain",nil,nil)
      @scene.pbRefresh
      pbDisplay(_INTL("It is raining."))
    elsif @weather==PBWeather::NEWMOON
      @scene.pbBackdropMove(0,true,true)
      @scene.pbMoveAnimation("NewMoon",nil,nil)
      @scene.pbRefresh
      pbDisplay(_INTL("The sky is dark."))
    elsif @weather==PBWeather::SANDSTORM
      @scene.pbBackdropMove(0,true,true)
      @scene.pbMoveAnimation("Sandstorm",nil,nil)
      @scene.pbRefresh
      pbDisplay(_INTL("A sandstorm is raging."))
    elsif @weather==PBWeather::HAIL
      @scene.pbBackdropMove(0,true,true)
      @scene.pbMoveAnimation("Hail",nil,nil)
      @scene.pbRefresh
      pbDisplay(_INTL("Hail is falling."))
    elsif @weather==PBWeather::HEAVYRAIN
      @scene.pbBackdropMove(0,true,true)
      @scene.pbMoveAnimation("HeavyRain",nil,nil)
      @scene.pbRefresh
      pbDisplay(_INTL("It is raining heavily."))
    elsif @weather==PBWeather::HARSHSUN
      @scene.pbBackdropMove(0,true,true)
      @scene.pbMoveAnimation("HarshSun",nil,nil)
      @scene.pbRefresh
      pbDisplay(_INTL("The sunlight is extremely harsh."))
    elsif @weather==PBWeather::STRONGWINDS
      @scene.pbBackdropMove(0,true,true)
      @scene.pbMoveAnimation("StrongWinds",nil,nil)
      @scene.pbRefresh
      pbDisplay(_INTL("The wind is strong."))
    end
# Abilities
    pbOnActiveAll
    pbSwitch
    
    if theyflee
       pbDisplay(_INTL("{1} fled!",@battlers[1].pbThis))
      @decision=3 
    else
      # Now begin the battle loop
      @turncount=0
      loop do
        if @debug
          if @turncount>=100
            @decision=pbDecisionOnTime()
            PBDebug.log("***[Undecided after 100 rounds]")
            pbAbort
            break
          end
          PBDebug.log("***Round #{@turncount+1}")
        end
        $justUsedStatusCure=nil
        PBDebug.logonerr{
          $idbox=nil
           pbCommandPhase
        }
        #Kernel.pbMessage("1")
        break if @decision>0
        #Kernel.pbMessage("2")
        PBDebug.logonerr{
           pbAttackPhase
        }
        #Kernel.pbMessage("3")
        pbJudge()
        #Kernel.pbMessage("4")
        break if @decision>0
        #Kernel.pbMessage("5")
        PBDebug.logonerr{
           pbEndOfRoundPhase
        }
        break if @decision>0
  
        pbSwitch
  
        break if @decision>0
        @turncount+=1
      end
    end
    $game_switches[562]=false
    return pbEndOfBattle(canlose)
  end

  def pbDefaultChooseNewEnemy(index,party)
    enemies=[]
    #for i in 0..party.length-1
    partyorder=(!pbIsOpposing?(index)) ? @party1order : @party2order
    plength=pbPartyLength(index)
    pstart=pbGetOwnerIndex(index)*plength
    for i in pstart...pstart+plength
      if pbCanSwitchLax?(index,partyorder[i],false)
      #if pbCanSwitchLax?(index,i,false)
        #enemies.push(i)
        enemies.push(partyorder[i])
      end
    end
    if enemies.length>0
      return pbChooseBestNewEnemy(index,party,enemies)
    end
    return -1
  end

  def pbEndOfBattle(canlose=false)
    if !@opponent && @party2[0].species==PBSpecies::HOOPA && !$game_switches[321]
      $game_variables[105]=@party2[0]
    end
    for i in @party1
      if i
        if (i.species==PBSpecies::ARCEUS && i.item==PBItems::CRYSTALPIECE) || i.species==PBSpecies::GIRATINA || 
            i.species==PBSpecies::REGIGIGAS
          i.primalBattle(false)
        elsif i.species==PBSpecies::ARCEUS && i.abilityflag==2
          i.form=0
        elsif i.species==PBSpecies::ZYGARDE && 
              i.ability==PBAbilities::POWERCONSTRUCT && i.form==2
          zygardeHP=i.hp
          i.form=i.getZygardeForm
          if i.totalhp > zygardeHP
            i.hp=zygardeHP
          else
            i.hp=i.totalhp
          end
        elsif i.species==PBSpecies::MEWTWO
          i.normalMegaMewtwoX(false)
          i.normalMegaMewtwoY(false)
        elsif i.species==PBSpecies::TYRANITAR
          i.megaTyranitar(false)
        elsif i.species==PBSpecies::FLYGON
          i.megaFlygon(false)
        elsif i.species==PBSpecies::MEOWSTIC
          i.form=0
        end
      end
    end
    if @doublebattle
    for i in 0..3
      next if !@battlers[i]
      if @battlers[i].effects[PBEffects::MeloettaForme] != nil && @battlers[i].effects[PBEffects::MeloettaForme] != 0
      pbParty(pbOpposing1.index)[pbParty(pbOpposing1.index).length-1]=@battlers[i].effects[PBEffects::MeloettaForme].pokemon
      @battlers[i].effects[PBEffects::MeloettaForme]=nil
      end
        #meloettasucks
    end
    end
    case @decision
#####
# WIN
#####
    when 1
      if @opponent
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
        maparyforfrontier=[695,696,693,700,701,694,698,834,835,836,837,838,839,840,841]
        
        if !maparyforfrontier.include?($game_map.map_id) && !$game_switches[369] && !$game_switches[641]
        # Calculate money gained for winning
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
            @moneygained*=2 if @amuletcoin
            # If Happy Hour's effect applies, double money earned
            maxlevel*=2 if @doublemoney
            @moneygained*=2 if @doublemoney
            moneygained=0 if !@opponent.is_a?(Array) && @opponent.name.include?("Trainer")
            maxlevel=0 if !@opponent.is_a?(Array) && @opponent.name.include?("Trainer")
            oldmoney=self.pbPlayer.money 
            self.pbPlayer.money+=maxlevel #if 0
            moneygained=self.pbPlayer.money-oldmoney
            if moneygained>0
              pbDisplayPaused(_INTL("{1} got ${2}\r\nfor winning!",self.pbPlayer.name,maxlevel)) #if ==0
            end
          end
        end
      end
      if @internalbattle && @moneygained>0
        pbDisplayPaused(_INTL("{1} picked up ${2}!",self.pbPlayer.name,@moneygained))
        self.pbPlayer.money+=@moneygained 
      end
      for pkmn in @snaggedpokemon
        pbStorePokemon(pkmn)
        self.pbPlayer.shadowcaught=[] if !self.pbPlayer.shadowcaught
        self.pbPlayer.shadowcaught[pkmn.species]=true
      end
      @snaggedpokemon.clear
      #    Spriteset_Map.new($game_map)

############
# LOSE, DRAW
############
        
    when 2, 5
      if (!@opponent || @internalbattle) && 
        pbDisplayPaused(_INTL("{1} is out of usable Pokémon!",self.pbPlayer.name))
          
        if !$game_switches[90]
          moneylost=pbMaxLevel(@party1) 
        else
          moneylost=pbMaxLevel(@party1) 
        end
        
        multiplier=[8,16,24,36,48,60,80,100,120]
        moneylost*=multiplier[[8,self.pbPlayer.numbadges].min]
        moneylost=self.pbPlayer.money if moneylost>self.pbPlayer.money
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
          
        pbDisplayPaused(_INTL("{1} blacked out!",self.pbPlayer.name)) if !canlose
      elsif @decision==2
        @scene.pbShowOpponent(0) if @opponent 
        pbDisplayPaused(@endspeechwin.gsub(/\\[Pp][Nn]/,self.pbPlayer.name)) if @opponent
        if @opponent.is_a?(Array)
          @scene.pbHideOpponent
          @scene.pbShowOpponent(1)
          pbDisplayPaused(@endspeechwin2.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
        end
      elsif @decision==5
        PBDebug.log("[Draw game]") if $INTERNAL
      end
      $game_screen.weather(0,0,0)
      weather=pbGetMetadata($game_map.map_id,MetadataWeather)
      $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
      $game_switches[187]=false
    #       Spriteset_Map.new($game_map)
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
          $Trainer.party[i-1].givePokerus(strain) if rand(3)==0
        end
        if i<$Trainer.party.length-1 && $Trainer.party[i+1].pokerusStage==0
          $Trainer.party[i+1].givePokerus(strain) if rand(3)==0
        end
      end
    end
    #        Spriteset_Map.new($game_map)
    @scene.pbEndBattle(@decision)
    #num=0
    for i in @battlers
      #num+=1
      #Kernel.pbMessage(_INTL("{1}",num.to_s))
      i.pbResetForm
      if i.hasWorkingAbility(:NATURALCURE)
        i.status=0
      #end
    end
    end
    for i in $Trainer.party
      i.item=i.itemInitial
      i.itemInitial=i.itemRecycle=0
      i.belch=false
      i.burstAttack=false
    end
    #@decision=1 if @decision==5 
    return @decision
  end

  def pbMaxLevel(party)
    lv=0
    for i in party
      next if !i
      lv=i.level if lv<i.level
    end
    return lv
  end

  def pbJudgeCheckpoint(attacker,move=0)
  end

  def pbCheckGlobalAbility(a,checkFainted=false)
    for i in 0..3 # in order from own first, opposing first, own second, opposing second
      if @battlers[i].hp>0 && @battlers[i].hasWorkingAbility(a,checkFainted)
        return @battlers[i]
      end
    end
    return nil
  end
  
  def nextPickupUse
    @nextPickupUse+=1
    return @nextPickupUse
  end

  def pbWeather
    for i in 0..3
      if @battlers[i].hasWorkingAbility(:CLOUDNINE) ||
         @battlers[i].hasWorkingAbility(:AIRLOCK)
        return 0
      end
    end
    return @weather
  end

  def pbCanRun?(idxPokemon)
    return false if @opponent
    thispkmn=@battlers[idxPokemon]
    return true if isConst?(thispkmn.item,PBItems,:SMOKEBALL) || isConst?(thispkmn.item,PBItems,:NOCTURNEINCENSE)
    return true if thispkmn.hasWorkingAbility(:RUNAWAY)
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
    wildbattle=!@opponent && pbIsOpposing?(idxPokemon)
    if @opponent
      if $DEBUG && Input.press?(Input::CTRL)
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision=1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision=2
          return 1
        end
      elsif (pbBattleChallenge.currentChallenge!=-1 && !wildbattle) || $game_switches[593]
        if pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
          pbDisplay(_INTL("{1} forfeited the match!",self.pbPlayer.name))
          @decision=3
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
    if $game_switches[357]
      pbDisplayPaused(_INTL("There's no running in a Bravery Challenge!"))
      return 0
    end
    if @doublebattle
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
      return 1
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
    if (isConst?(thispkmn.item,PBItems,:SMOKEBALL) || isConst?(thispkmn.item,PBItems,:NOCTURNEINCENSE))
      if duringBattle
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbDisplayPaused(_INTL("{1} fled using its {2}!",thispkmn.pbThis,PBItems.getName(thispkmn.item)))
      end
      @decision=3
      return 1
    end
    if thispkmn.hasWorkingAbility(:RUNAWAY)
      if duringBattle
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbDisplayPaused(_INTL("{1} fled using Run Away!",thispkmn.pbThis))
      end
      @decision=3
      return 1
    end
    if (thispkmn.pbHasType?(:GHOST) || thispkmn.effects[PBEffects::TrickOrTreat])
      if duringBattle
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbDisplayPaused(_INTL("Got away safely!",thispkmn.pbThis))
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

  def pbRegisterMove(idxPokemon,idxMove,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    return false if !pbCanChooseMove?(idxPokemon,idxMove,showMessages)
    @choices[idxPokemon][0]=1 # Move
    @choices[idxPokemon][1]=idxMove # Index of move
    @choices[idxPokemon][2]=thismove # Move object
    @choices[idxPokemon][3]=-1 # No target chosen
    return true
  end

  def pbDeregisterMove(idxPokemon,idxMove=0,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    return false if !pbCanChooseMove?(idxPokemon,idxMove,showMessages)
    @choices[idxPokemon][0]=0 # Move
    @choices[idxPokemon][1]=0 # Index of move
    @choices[idxPokemon][2]=nil # Move object
    @choices[idxPokemon][3]=-1 # No target chosen
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
    if isConst?(thispkmn.item,PBItems,:ASSAULTVEST) && !(thismove.pbIsPhysical?(thismove.type) || thismove.pbIsSpecial?(thismove.type))
        if showMessages
          pbDisplayPaused(_INTL("{1} doesn't allow use of non-attacking moves!",
             PBItems.getName(thispkmn.item)))
        end
        return false
    end
    if thispkmn.effects[PBEffects::HealBlock]>0 && thismove.isHealingMove?
      if showMessages
        pbDisplayPaused(_INTL("{1} can't use {2} because of Heal Block!",thispkmn.pbThis,thismove.name))
      end
      return false
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
    if thispkmn.effects[PBEffects::Taunt] > 0 && thismove.basedamage == 0
      if showMessages
        pbDisplayPaused(_INTL("{1} can't use {2} after the Taunt!",thispkmn.pbThis,thismove.name))
      end
      return false
    end
    if thispkmn.effects[PBEffects::Torment]
      if thismove.id==thispkmn.lastMoveUsed
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the same move in a row due to the Torment!",thispkmn.pbThis))
        end
        #thispkmn.effects[PBEffects::SkipTurn]=true
        return false
      end
    end
    if thismove.id==thispkmn.effects[PBEffects::DisableMove]
      if showMessages
        pbDisplayPaused(_INTL("{1}'s {2} is disabled!",thispkmn.pbThis,thismove.name))
      end
      return false
    end
    if thismove.function==0x174 && # Belch
       (!thispkmn.pokemon || !thispkmn.pokemon.belch)
      if showMessages
        pbDisplayPaused(_INTL("{1} hasn't eaten any berries, so it can't possibly belch!",thispkmn.pbThis))
      end
      return false
    end
    # Burst Attacks
    if thismove.isBurstAttack?
      if(!thispkmn.pokemon || !thispkmn.effects[PBEffects::BurstMode])
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use this move outside of Burst Mode!",thispkmn.pbThis))
        end
        return false
      elsif (!thispkmn.pokemon || thispkmn.pokemon.burstAttack)
        if showMessages
          pbDisplayPaused(_INTL("{1} has already used its Burst Attack in this Burst Mode!",thispkmn.pbThis))
        end
        return false
      end
    end
    #if isConst?(thismove.id,PBMoves,:SUCKERPUNCH)
    #  thispkmn.effects[PBEffects::SuckerPunch]=true
    #end
      #thispkmn.effects[PBEffects::LastResort][idxMove]=true

    if thispkmn.effects[PBEffects::Encore]>0 && idxMove!=thispkmn.effects[PBEffects::EncoreIndex]
      return false
    end
    return true
  end
  def pbAutoChooseMoveEnemy(idxPokemon,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    if thispkmn.hp<=0
      @choices[idxPokemon][0]=0
      @choices[idxPokemon][1]=0
      @choices[idxPokemon][2]=nil
      return
    end
    if thispkmn.effects[PBEffects::Encore] > 0 && 
       pbCanChooseMove?(idxPokemon,thispkmn.effects[PBEffects::EncoreIndex],false)
      PBDebug.log("[Auto choosing Encore move...]")
      @choices[idxPokemon][0]=1 # Move
      @choices[idxPokemon][1]=thispkmn.effects[PBEffects::EncoreIndex] # Index of move
      @choices[idxPokemon][2]=@battlers[idxPokemon].moves[thispkmn.effects[PBEffects::EncoreIndex]]
      @choices[idxPokemon][3]=-1
    else
      if !pbIsOpposing?(idxPokemon)
        pbDisplayPaused(_INTL("{1} has no moves left!",thispkmn.name)) if showMessages
      end
      @choices[idxPokemon][0]=1 # Move
      @choices[idxPokemon][1]=-1 # Index of move
      @choices[idxPokemon][2]=@struggle
      @choices[idxPokemon][3]=-1
    end
  end
  
  def pbAutoChooseMove(idxPokemon,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    if thispkmn.hp<=0
      @choices[idxPokemon][0]=0
      @choices[idxPokemon][1]=0
      @choices[idxPokemon][2]=nil
      return
    end

    if $idbox && $idbox != nil && !pbIsOpposing?(thispkmn.index)
      pbDisplayPaused(_INTL("{1} used the {2} box!",thispkmn.name, $idbox))
      $idboxused = true
              @choices[idxPokemon][0]=1 # Move
      @choices[idxPokemon][1]=-1 # Index of move
      if $idbox == "Doom Desire"
        @choices[idxPokemon][2]=@ab_doomdesire
      elsif $idbox == "V-Create"
        @choices[idxPokemon][2]=@ab_vcreate
      elsif $idbox == "Seed Flare"
        @choices[idxPokemon][2]=@ab_seedflare
      elsif $idbox == "Mist Ball"
        @choices[idxPokemon][2]=@ab_mistball
      elsif $idbox == "Luster Purge"
        @choices[idxPokemon][2]=@ab_lusterpurge
      elsif $idbox == "Roar of Time"
        @choices[idxPokemon][2]=@ab_roaroftime
      elsif $idbox == "Spacial Rend"
        @choices[idxPokemon][2]=@ab_spacialrend
      elsif $idbox == "Sacred Sword"
        @choices[idxPokemon][2]=@ab_sacredsword
      elsif $idbox == "Dark Void"
        @choices[idxPokemon][2]=@ab_darkvoid
      elsif $idbox == "Protect"
        @choices[idxPokemon][2]=@ab_protect
      elsif $idbox == "Sleep Powder"
        @choices[idxPokemon][2]=@ab_sleeppowder
        elsif $idbox == "Thunder Wave"
        @choices[idxPokemon][2]=@ab_thunderwave
        elsif $idbox == "Toxic"
        @choices[idxPokemon][2]=@ab_toxic
        elsif $idbox == "Confuse Ray"
        @choices[idxPokemon][2]=@ab_confuseray
        elsif $idbox == "Medusa Ray"
        @choices[idxPokemon][2]=@ab_medusaray
        elsif $idbox == "False Swipe"
        @choices[idxPokemon][2]=@ab_falseswipe
      else
        @choices[idxPokemon][2]=@struggle
      end
      @choices[idxPokemon][3]=-1
      return
    end
    
    if thispkmn.effects[PBEffects::Encore] > 0 && 
       pbCanChooseMove?(idxPokemon,thispkmn.effects[PBEffects::EncoreIndex],false)
      PBDebug.log("[Auto choosing Encore move...]")
      @choices[idxPokemon][0]=1 # Move
      @choices[idxPokemon][1]=thispkmn.effects[PBEffects::EncoreIndex] # Index of move
      @choices[idxPokemon][2]=@battlers[idxPokemon].moves[thispkmn.effects[PBEffects::EncoreIndex]]
      @choices[idxPokemon][3]=-1
    else
      if !pbIsOpposing?(idxPokemon)
        pbDisplayPaused(_INTL("{1} has no moves left!",thispkmn.name)) if showMessages
      end
      @choices[idxPokemon][0]=1 # Move
      @choices[idxPokemon][1]=-1 # Index of move
      @choices[idxPokemon][2]=@struggle
      @choices[idxPokemon][3]=-1
    end
  end
  
  def pbAttackBox(idxPokemon)
   #    battle.pbDisplayPaused(_INTL("Got away safely!"))

      @choices[idxPokemon][0]=1
      @choices[idxPokemon][1]=-1
      @choices[idxPokemon][2]=@struggle
      @choices[idxPokemon][3]=-1
  end
  
  def pbOnActiveAll
    for i in 0..3  # update participants in battles (unfainted participants will earn EXP even if they faint in between)
      if pbIsOpposing?(i)
        @battlers[i].pbUpdateParticipants
      end
      @amuletcoin=true if !pbIsOpposing?(i) &&
                          (isConst?(@battlers[i].item,PBItems,:AMULETCOIN) ||
                           isConst?(@battlers[i].item,PBItems,:LUCKINCENSE))
    end
    #for i in 0..3
     # if @battlers[i].hp>0 && @battlers[i].pokemon && pbIsOpposing?(i)
#        if (@battlers[i].pokemon.isShadow? rescue false)
#          pbCommonAnimation("Shadow",@battlers[i],nil)

#          pbDisplay(_INTL("Oh!\nA Shadow Pokemon!"))
 #       end
  #    end
   # end
    # Weather-inducing abilities, Trace, Imposter, etc.
    @usepriority=false
    priority=pbPriority
    for i in priority
      i.pbAbilitiesOnSwitchIn(true)
    end
    # Check forms are correct
    for i in 0..3
      pkmn=@battlers[i]
      next if pkmn.hp<=0
      @battlers[i].pbCheckForm
    end
  end

  def pbOnActiveOne(pkmn,onlyabilities=false)
    return false if pkmn.hp<=0
    if !onlyabilities
      if (pkmn.isShadow? rescue false)  && !pbOwnedByPlayer?(pkmn.index)
        pbDisplay(_INTL("Oh!\nA Shadow Pokemon!"))
      end
# update participants in battles (unfainted participants will earn EXP even if they faint in between)
      for i in 0..3
        if pbIsOpposing?(i)
          @battlers[i].pbUpdateParticipants
        end
        @amuletcoin=true if !pbIsOpposing?(i) &&
                            (isConst?(@battlers[i].item,PBItems,:AMULETCOIN) ||
                             isConst?(@battlers[i].item,PBItems,:LUCKINCENSE))
      end
      # Healing Wish
      if pkmn.effects[PBEffects::HealingWish]
        pkmn.pbRecoverHP(pkmn.totalhp)
        pkmn.status=0
        pkmn.statusCount=0
        pbDisplayPaused(_INTL("{1} was healed by the Healing Wish!",pkmn.pbThis))
        pkmn.effects[PBEffects::HealingWish]=false
      end
      # Lunar Dance
      if pkmn.effects[PBEffects::LunarDance]
        pkmn.pbRecoverHP(pkmn.totalhp)
        pkmn.status=0
        pkmn.statusCount=0
        for i in 0...4
          pkmn.moves[i].pp=pkmn.moves[i].totalpp
        end
        pbDisplayPaused(_INTL("{1} was healed by the Lunar Dance!",pkmn.pbThis))
        pkmn.effects[PBEffects::LunarDance]=false
      end
      # Spikes
      if pkmn.pbOwnSide.effects[PBEffects::Spikes] > 0 && !pkmn.isAirborne? && 
         !pkmn.fainted?
        #if isConst?(pkmn.item,PBItems,:IRONBALL) ||
        #   pkmn.effects[PBEffects::Ingrain] ||
        #   pkmn.effects[PBEffects::SmackDown] ||
        #   pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
        #   pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
        #   !(pkmn.pbHasType?(:FLYING) ||
        #     pkmn.hasWorkingAbility(:LEVITATE) ||
        #     isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
        #     pkmn.effects[PBEffects::MagnetRise]>0 ||
        #     pkmn.effects[PBEffects::Telekinesis]>0)
        if !pkmn.hasWorkingAbility(:MAGICGUARD)
          spikesdiv=[0,8,6,4]
          pkmn.pbReduceHP(pkmn.totalhp/spikesdiv[pkmn.pbOwnSide.effects[PBEffects::Spikes]])
          pbDisplayPaused(_INTL("{1} is hurt by spikes!",pkmn.pbThis))
        end
      end
      pkmn.pbFaint if pkmn.hp<=0
      # Toxic Spikes
      if pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 && !pkmn.fainted?
        if !pkmn.isAirborne? #isConst?(pkmn.item,PBItems,:IRONBALL) ||
           #pkmn.effects[PBEffects::Ingrain] ||
           #pkmn.effects[PBEffects::SmackDown] ||
           #pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
           #pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
           #!(pkmn.pbHasType?(:FLYING) ||
           #  pkmn.hasWorkingAbility(:LEVITATE) ||
           #  isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
           #  pkmn.effects[PBEffects::MagnetRise]>0 ||
           #  pkmn.effects[PBEffects::Telekinesis]>0)
          if pkmn.pbHasType?(:POISON)
            pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
            pbDisplayPaused(_INTL("{1} absorbed the poison spikes!",pkmn.pbThis))
          elsif pkmn.pbCanPoisonSpikes? && !pkmn.hasWorkingAbility(:MAGICGUARD)
            badly=(pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]==2)
            pkmn.pbPoison(pkmn,badly)
            pbDisplayPaused(_INTL("{1} was badly poisoned!",pkmn.pbThis)) if badly
            pbDisplayPaused(_INTL("{1} was poisoned!",pkmn.pbThis)) if !badly
          end
        end
      end
      # Livewire
      if pkmn.pbOwnSide.effects[PBEffects::Livewire] > 0 && !pkmn.fainted?
        avoided=true
        absorbed=false
        effectchance=pkmn.pbOwnSide.effects[PBEffects::Livewire]
        case @weather
        when PBWeather::HEAVYRAIN
          effectchance*=4
        when PBWeather::RAINDANCE
          effectchance*=4
        else
          effectchance*=2
        end
        if !pkmn.isAirborne? #isConst?(pkmn.item,PBItems,:IRONBALL) ||
           #pkmn.effects[PBEffects::Ingrain] ||
           #pkmn.effects[PBEffects::SmackDown] ||
           #pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
           #pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
           #!(pkmn.pbHasType?(:FLYING) ||
           #  pkmn.hasWorkingAbility(:LEVITATE) ||
           #  isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
           #  pkmn.effects[PBEffects::MagnetRise]>0 ||
           #  pkmn.effects[PBEffects::Telekinesis]>0)
          roll=pbRandom(10)
          if pkmn.pbHasType?(:ELECTRIC) || pkmn.pbHasType?(:GROUND)
            absorbed=true
          elsif roll<effectchance
            avoided=false
          else # !isConst?(pkmn.ability,PBAbilities,:MAGICGUARD)
            avoided=true
          end
        else
          avoided=true
        end
        if absorbed
          pkmn.pbOwnSide.effects[PBEffects::Livewire]=0
          if pkmn.pbHasType?(:GROUND)
            pbDisplayPaused(_INTL("{1} absorbed the Livewire!",pkmn.pbThis))
          else
            pbDisplayPaused(_INTL("{1} discharged the Livewire!",pkmn.pbThis))
          end
        else
          if !avoided && pkmn.status==0 && pkmn.pbCanParalyze?(nil,false,nil,true)
            pkmn.pbParalyze(pkmn)
            pbDisplayPaused(_INTL("{1} was shocked by the Livewire!",pkmn.pbThis))
          elsif pkmn.status!=0 || !pkmn.pbCanParalyze?(nil,false,nil,true) || 
                pkmn.isAirborne?
          else
            pbDisplayPaused(_INTL("{1} avoided the Livewire!",pkmn.pbThis))
          end
        end
      end
        #if pkmn.pbOwnSide.effects[PBEffects::PowerShrine] > 0

        #if isConst?(pkmn.item,PBItems,:IRONBALL) ||
        #   pkmn.effects[PBEffects::Ingrain] ||
        #   pkmn.effects[PBEffects::SmackDown] ||
        #   pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
        #   pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
        #   !(pkmn.pbHasType?(:FLYING) ||
        #     pkmn.hasWorkingAbility(:LEVITATE) ||
        #     isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
        #     pkmn.effects[PBEffects::MagnetRise]>0 ||
        #     pkmn.effects[PBEffects::Telekinesis]>0)
        #  if pkmn.pbHasType?(:SHADOW)
        #    pbDisplayPaused(_INTL("{1}'s corruption didn't let it use the Shrine!",pkmn.pbThis))
        #  else
        #      pkmn.pbOwnSide.effects[PBEffects::PowerShrine] = pkmn.pbOwnSide.effects[PBEffects::PowerShrine] - 1
        #      pbDisplayPaused(_INTL("{1}'s stats were boosted by the Shrine!",pkmn.pbThis))
        #      pkmn.pbIncreaseStatBasic(PBStats::ATTACK,1)
              #      attacker.pbIncreaseStatBasic(PBStats::ATTACK,2)

        #     pkmn.pbIncreaseStatBasic(PBStats::DEFENSE,1)
        #      pbCommonAnimation("StatUp",pkmn,nil)
        #      pbDisplayPaused("The Power Shrine fell to pieces!") if pkmn.pbOwnSide.effects[PBEffects::PowerShrine] == 0
      
        #  end
        #else
        #    pbDisplayPaused(_INTL("{1} was unaffected by the Shrine!",pkmn.pbThis))

        #  end
        #end
        #if pkmn.pbOwnSide.effects[PBEffects::SpecialShrine] > 0
        #if isConst?(pkmn.item,PBItems,:IRONBALL) ||
        #   pkmn.effects[PBEffects::Ingrain] ||
        #   pkmn.effects[PBEffects::SmackDown] ||
        #   pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
        #   pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
        #   !(pkmn.pbHasType?(:FLYING) ||
        #     pkmn.hasWorkingAbility(:LEVITATE) ||
        #     isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
        #     pkmn.effects[PBEffects::MagnetRise]>0 ||
        #     pkmn.effects[PBEffects::Telekinesis]>0)
        #  if pkmn.pbHasType?(:SHADOW)
        #    pbDisplayPaused(_INTL("{1}'s corruption didn't let it use the Shrine!",pkmn.pbThis))
        #  else
        #                  pkmn.pbOwnSide.effects[PBEffects::PowerShrine] = pkmn.pbOwnSide.effects[PBEffects::PowerShrine] - 1

        #      pkmn.pbIncreaseStatBasic(PBStats::SPATTACK,1)
        #      pkmn.pbIncreaseStatBasic(PBStats::SPDEFENSE,1)
        #pbCommonAnimation("StatUp",pkmn,nil)
        #    pbDisplayPaused(_INTL("{1}'s stats were boosted by the Shrine!",pkmn.pbThis))
        #                pbDisplayPaused("The Power Shrine fell to pieces!") if pkmn.pbOwnSide.effects[PBEffects::PowerShrine] == 0

        #    end
        #else
        #    pbDisplayPaused(_INTL("{1} was unaffected by the Shrine!",pkmn.pbThis))

        #  end
        #end
        
      if pkmn.pbOwnSide.effects[PBEffects::Permafrost] > 0 && !pkmn.fainted?
        avoided=true
        absorbed=false
        effectchance=pkmn.pbOwnSide.effects[PBEffects::Permafrost]
        case @weather
        when PBWeather::HAIL
          effectchance*=2
        else
          
        end
        if !pkmn.isAirborne? #isConst?(pkmn.item,PBItems,:IRONBALL) ||
           #pkmn.effects[PBEffects::Ingrain] ||
           #pkmn.effects[PBEffects::SmackDown] ||
           #pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
           #pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
           #!(pkmn.pbHasType?(:FLYING) ||
           #pkmn.hasWorkingAbility(:LEVITATE) ||
           #isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
           #pkmn.effects[PBEffects::MagnetRise]>0 ||
           #pkmn.effects[PBEffects::Telekinesis]>0)
          roll=pbRandom(10)
          if pkmn.pbHasType?(:FIRE) || pkmn.pbHasType?(:ICE)
            absorbed=true
          elsif roll<effectchance
            avoided=false
          else
            avoided=true
          end
        else
          avoided=true
        end
        if absorbed
          pkmn.pbOwnSide.effects[PBEffects::Permafrost]=0
          if pkmn.pbHasType?(:FIRE)
            pbDisplayPaused(_INTL("{1} melted the frost!",pkmn.pbThis))
          else
            pbDisplayPaused(_INTL("{1} absorbed the frost!",pkmn.pbThis))
          end
        else
          if !avoided && pkmn.status==0 && pkmn.pbCanFreeze?(nil,false,nil,true)
            pkmn.pbFreeze
            pbDisplayPaused(_INTL("{1} was frozen by the frost on the ground!",pkmn.pbThis))
          elsif pkmn.status!=0 || !pkmn.pbCanFreeze?(nil,false,nil,true) ||
                pkmn.isAirborne?
          else
            pbDisplayPaused(_INTL("{1} avoided the frost!",pkmn.pbThis))
          end
        end
      end
      if pkmn.pbOwnSide.effects[PBEffects::StickyWeb] && !pkmn.isAirborne? && 
         !pkmn.fainted?
        #if isConst?(pkmn.item,PBItems,:IRONBALL) ||
        #   pkmn.effects[PBEffects::Ingrain] ||
        #   pkmn.effects[PBEffects::SmackDown] ||
        #   pkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
        #   pkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
        #   !(pkmn.pbHasType?(:FLYING) ||
        #   pkmn.hasWorkingAbility(:LEVITATE) ||
        #   pkmn.hasWorkingAbility(:CLEARBODY) ||
        #   isConst?(pkmn.item,PBItems,:AIRBALLOON) ||
        #   pkmn.effects[PBEffects::MagnetRise]>0 ||
        #   pkmn.effects[PBEffects::Telekinesis]>0)
        
        if pkmn.pbTooLow?(PBStats::SPEED)
          pbDisplay(_INTL("{1}'s Speed won't go lower!",pkmn.pbThis))
        elsif pkmn.hasWorkingAbility(:CLEARBODY)
          pbDisplay(_INTL("{1}'s Clear Body prevents stat loss!",pkmn.pbThis))
        else
          #pkmn.pbReduceStatBasic(PBStats::SPEED,1)
          pkmn.pbReduceStat(PBStats::SPEED,1,false)
          pbCommonAnimation("StatDown",pkmn,nil)
          #pbDisplay(_INTL("{1}'s Speed fell!",pkmn.pbThis))
          pbDisplayPaused(_INTL("{1} was caught in a sticky web!",pkmn.pbThis))
        end
      end
      # Stealth Rock
      if pkmn.pbOwnSide.effects[PBEffects::StealthRock] && 
         !pkmn.hasWorkingAbility(:MAGICGUARD) && !pkmn.fainted?
        if !pkmn.hasWorkingAbility(:MAGICGUARD)
          atype=getConst(PBTypes,:ROCK) || 0
          otype1=pkmn.type1
          otype2=pkmn.type2
          eff=PBTypes.getCombinedEffectiveness(atype,otype1,otype2)
          if pkmn.hasWorkingAbility(:OMNITYPE)
            eff=8
          end
          if $game_switches[302]
            case eff
            when 32
              eff=0
            when 8
              eff=2
            when 2
              eff=8
            when 1
              eff=16
            when 16
              eff=1
            when 0
              eff=8
            end
          end
          if eff>0
            pkmn.pbReduceHP(pkmn.totalhp*eff/32)
            pbDisplayPaused(_INTL("{1} is hurt by stealth rocks!",pkmn.pbThis))
          end
        end
      end
      pkmn.pbFaint if pkmn.hp<=0
      if pkmn.pbOwnSide.effects[PBEffects::FireRock] && 
         !pkmn.hasWorkingAbility(:MAGICGUARD) && !pkmn.fainted?
        if !pkmn.hasWorkingAbility(:MAGICGUARD)
          atype=getConst(PBTypes,:FIRE) || 0
          otype1=pkmn.type1
          otype2=pkmn.type2
          eff=PBTypes.getCombinedEffectiveness(atype,otype1,otype2)
          if pkmn.hasWorkingAbility(:OMNITYPE)
            eff=4
          end
          if $game_switches[302]
            case eff
            when 32
              eff=0
            when 8
              eff=2
            when 2
              eff=8
            when 1
              eff=16
            when 16
              eff=1
            when 0
              eff=8
            end
          end
          if eff>0
            pkmn.pbReduceHP(pkmn.totalhp*eff/32)
            pbDisplayPaused(_INTL("{1} is hurt by molten rocks!",pkmn.pbThis))
          end
        end
      end
      pkmn.pbFaint if pkmn.hp<=0

    end
    pkmn.pbAbilityCureCheck
    if pkmn.hp<=0
      pbGainEXP
      pbSwitch#  pbJudge
      return false
    end
    if !onlyabilities
      pkmn.pbCheckForm
      pkmn.pbBerryCureCheck(true)
    end
    return true
  end
  
  def pbPrimordialWeather
    # End Primordial Sea, Desolate Land, Delta Stream
    hasabil=false
    case @weather
    when PBWeather::HEAVYRAIN
      for i in 0...4
        if @battlers[i].hasWorkingAbility(:PRIMORDIALSEA) &&
          !@battlers[i].fainted?
          hasabil=true; break
        end
      end
      if !hasabil
        @weather=0
        @scene.pbBackdropMove(0,true,true)
        @scene.pbRefresh
        pbDisplayBrief("The heavy rain has lifted!")
      end  
    when PBWeather::HARSHSUN
      for i in 0...4
        if @battlers[i].hasWorkingAbility(:DESOLATELAND) &&
          !@battlers[i].fainted?
          hasabil=true; break
        end
      end
      if !hasabil
        @weather=0
        @scene.pbBackdropMove(0,true,true)
        @scene.pbRefresh
        pbDisplayBrief("The harsh sunlight faded!")
      end
    when PBWeather::STRONGWINDS
      for i in 0...4
        if @battlers[i].hasWorkingAbility(:DELTASTREAM) &&
           !@battlers[i].fainted?
          hasabil=true; break
        end
      end
      if !hasabil
        @weather=0
        @scene.pbBackdropMove(0,true,true)
        @scene.pbRefresh
        pbDisplayBrief("The mysterious air current has dissipated!")
      end
    end
  end

  def pbCanShowCommands?(idxPokemon)
    thispkmn=@battlers[idxPokemon]
    if thispkmn.hp<=0
      return false
    end
    return false if thispkmn.effects[PBEffects::TwoTurnAttack]>0
    return false if thispkmn.effects[PBEffects::HyperBeam]>0
    return false if thispkmn.effects[PBEffects::Rollout]>0
    return false if thispkmn.effects[PBEffects::Outrage]>0
    return false if thispkmn.effects[PBEffects::Uproar]>0
    return false if thispkmn.effects[PBEffects::Bide]>0
    return true
  end

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
    return false if $idbox && $idbox != nil
    return false if thispkmn.effects[PBEffects::Encore]>0
    return true
  end
    def pbCanShowFightMenuEnemy?(idxPokemon)
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
 #   return false if $idbox && $idbox != nil
    return false if thispkmn.effects[PBEffects::Encore]>0
    return true
  end


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
      ##if party[pkmnidxTo].hp<=0 && $game_switches[158]
      ##  party[pkmnidxTo].hp=1
      ##end 
      
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
    for i in 0..3
      next if isOpposing!=pbIsOpposing?(i)
      if choices[i][0]==2&&choices[i][1]==pkmnidxTo
        pbDisplayPaused(_INTL("{1} has already been selected.",party[pkmnidxTo].name)) if showMessages 
        return false
      end
    end
    if isConst?(thispkmn.item,PBItems,:SHEDSHELL)
      return true
    end
    if !thispkmn.pbHasType?(:GHOST) && !thispkmn.effects[PBEffects::TrickOrTreat]
    if thispkmn.effects[PBEffects::MultiTurn]>0 || thispkmn.effects[PBEffects::MeanLook]>=0
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    if @field.effects[PBEffects::FairyLock]>0
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    # Ingrain
    if thispkmn.effects[PBEffects::Ingrain]
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    if thispkmn.effects[PBEffects::Infestation] > 0
      pbDisplayPaused(_INTL("{1} is infected with Infestation",thispkmn.pbThis)) if showMessages
      return false
    end
    
    if thispkmn.effects[PBEffects::MeloettaForme] != nil && thispkmn.effects[PBEffects::MeloettaForme] > 0
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    opp1=thispkmn.pbOpposing1
    opp2=thispkmn.pbOpposing2
    opp=nil
    if thispkmn.pbHasType?(:STEEL)
      opp=opp1 if opp1.hasWorkingAbility(:MAGNETPULL) && opp1.hp>0
      opp=opp2 if opp2.hasWorkingAbility(:MAGNETPULL) && opp2.hp>0
    end
    if !thispkmn.isAirborne? #isConst?(thispkmn.item,PBItems,:IRONBALL) ||
       #thispkmn.effects[PBEffects::Ingrain] ||
       #thispkmn.effects[PBEffects::SmackDown] ||
       #thispkmn.pbOwnSide.effects[PBEffects::Gravity]>0 ||
       #thispkmn.pbOpposingSide.effects[PBEffects::Gravity]>0 ||
       #!(thispkmn.pbHasType?(:FLYING) ||
       #  thispkmn.hasWorkingAbility(:LEVITATE) ||
       #  isConst?(thispkmn.item,PBItems,:AIRBALLOON) ||
       #  thispkmn.effects[PBEffects::MagnetRise]>0 ||
       #  thispkmn.effects[PBEffects::Telekinesis]>0)
      opp=opp1 if opp1.hasWorkingAbility(:ARENATRAP) && opp1.hp>0
      opp=opp2 if opp2.hasWorkingAbility(:ARENATRAP) && opp2.hp>0
    end
    if !thispkmn.hasWorkingAbility(:SHADOWTAG)
      opp=opp1 if opp1.hasWorkingAbility(:SHADOWTAG) && opp1.hp>0
      opp=opp2 if opp2.hasWorkingAbility(:SHADOWTAG) && opp2.hp>0
    end
    if opp
      abilityname=PBAbilities.getName(opp.ability)
      pbDisplayPaused(_INTL("{1}'s {2} prevents switching!",opp.pbThis,abilityname)) if showMessages
      return false
    end
    end
    return true
  end

  def pbRegisterSwitch(idxPokemon,idxOther)
    thispkmn=@battlers[idxPokemon]
    if !pbCanSwitch?(idxPokemon,idxOther,false)
      return false
    else
      @choices[idxPokemon][0]=2 # Pokémon
      @choices[idxPokemon][1]=idxOther # Pokémon to switch to
      @choices[idxPokemon][2]=nil
   #       side=(pbIsOpposing?(idxPokemon)) ? 1 : 0
    #owner=pbGetOwnerIndex(idxPokemon)
    $mega_battlers[idxPokemon]=false
    #if @megaEvolution[side][owner]==idxPokemon
    #  @megaEvolution[side][owner]=-1
    #end
    

      return true
    end
  end

# Checks whether an item can be removed from a Pokémon.
  def pbIsUnlosableItem(pkmn,item)
    #return true if pbIsMegaStone?(item)
    return false if pkmn.effects[PBEffects::Transform]
    if pkmn.hasWorkingAbility(:MULTITYPE) &&
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
        isConst?(item,PBItems,:DREADPLATE) ||
        isConst?(item,PBItems,:PIXIEPLATE))
      return true
    end
    if  (isConst?(pkmn.species,PBSpecies,:MEWTWO) && isConst?(item,PBItems,:MEWTWOMACHINE)) ||
        (isConst?(pkmn.species,PBSpecies,:ZEKROM) && isConst?(item,PBItems,:ZEKROMMACHINE)) ||
        (isConst?(pkmn.species,PBSpecies,:TYRANITAR) && isConst?(item,PBItems,:TYRANITARMACHINE)) ||
        (isConst?(pkmn.species,PBSpecies,:LEAVANNY) && isConst?(item,PBItems,:LEAVANNYMACHINE)) ||
        (isConst?(pkmn.species,PBSpecies,:FLYGON) && isConst?(item,PBItems,:FLYGONMACHINE)) ||
        (isConst?(pkmn.species,PBSpecies,:DELTAVOLCARONA) && isConst?(item,PBItems,:DVOLCARONAARMOR))
      return true
    end
    if Kernel.pbGetMegaStoneList.include?(item)
      idx=Kernel.pbGetMegaStoneList.index(item)
      if Kernel.pbGetMegaSpeciesList[idx]==pkmn.species
        return true
      end
    end
    if isConst?(pkmn.species,PBSpecies,:GIRATINA) &&
       (isConst?(item,PBItems,:GRISEOUSORB) || isConst?(item,PBItems,:CRYSTALPIECE))
      return true
    end
    if (isConst?(pkmn.species,PBSpecies,:ARCEUS) || isConst?(pkmn.species,PBSpecies,:REGIGIGAS)) &&
       isConst?(pkmn.item,PBItems,:CRYSTALPIECE)
       return true
    end
    if isConst?(pkmn.species,PBSpecies,:GROUDON) && isConst?(pkmn.item,PBItems,:REDORB)
       return true
    end
    if isConst?(pkmn.species,PBSpecies,:KYOGRE) && isConst?(pkmn.item,PBItems,:BLUEORB)
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
  
# Uses an item on a Pokémon in the player's party.
  def pbUseItemOnPokemon(item,pkmnIndex,scene,party=nil)
    if party==nil
      pokemon=@party1[pkmnIndex]
    else
      pokemon=party[pkmnIndex]
    end
    battler=nil
    if pokemon.egg?
      scene.pbDisplay(_INTL("It won't have any effect."))
      return false
    end
    for i in 0...3
      if !pbIsOpposing?(i) && @battlers[i].pokemonIndex==pkmnIndex #!pbIsOpposing?(i)
        #if !@doublebattle && pkmnIndex==0
          battler=@battlers[i]
        #elsif pkmnIndex==0 || pkmnIndex==1
        #  battler=@battlers[i]
        #end
      end
    end
    return ItemHandlers.triggerBattleUseOnPokemon(item,pokemon,battler,scene)
  end
  
# Uses an item on an active Pokémon.
  def pbUseItemOnBattler(item,index,scene)
    return ItemHandlers.triggerBattleUseOnBattler(item,@battlers[index],scene)
  end
  
  def pbRegisterItem(idxPokemon,idxItem,idxTarget=nil)
    if idxTarget!=nil && idxTarget>=0
      for i in 0...4
        if !@battlers[i].pbIsOpposing?(idxPokemon) &&
           @battlers[i].pokemonIndex==idxTarget &&
           @battlers[i].effects[PBEffects::Embargo]>0
          pbDisplay(_INTL("Embargo's effect prevents the item's use on {1}!",@battlers[i].pbThis(true)))
          if pbBelongsToPlayer?(@battlers[i].index)
            if $PokemonBag.pbCanStore?(idxItem)
              $PokemonBag.pbStoreItem(idxItem)
            else
              raise _INTL("Couldn't return unused item to Bag somehow.")
            end
          end
          return false
        end
      end
    end
    thispkmn=@battlers[idxPokemon]
    @choices[idxPokemon][0]=3 # item
    @choices[idxPokemon][1]=idxItem # item used
    @choices[idxPokemon][2]=nil
    #    side=(pbIsOpposing?(idxPokemon)) ? 1 : 0
    #owner=pbGetOwnerIndex(idxPokemon)
    $mega_battlers[idxPokemon]=false
#    if @megaEvolution[side][owner]==idxPokemon
#      @megaEvolution[side][owner]=-1
#    end
   # if $game_switches[359] #zubat
    ItemHandlers.triggerUseInBattle(idxItem,@battlers[idxPokemon],self)
    return true
  end

  def pbEnemyItemToUse(index)
  
    return 0 if !@internalbattle
    items=pbGetOwnerItems(index)
    return 0 if !items
    hashpitem=false
    battler=@battlers[index]
    
    return 0 if battler.pokemon.species==PBSpecies::ARON
    return 0 if battler.hp<=0
    for i in items
      next if pbEnemyItemAlreadyUsed?(index,i,items)
      if isConst?(i,PBItems,:POTION) || 
         isConst?(i,PBItems,:SUPERPOTION) || 
         isConst?(i,PBItems,:HYPERPOTION) || 
         isConst?(i,PBItems,:MAXPOTION) ||
         isConst?(i,PBItems,:FULLRESTORE)
        hashpitem=true
      end
    end
    for i in items
      next if pbEnemyItemAlreadyUsed?(index,i,items)
      if isConst?(i,PBItems,:POTION) || 
         isConst?(i,PBItems,:SUPERPOTION) || 
         isConst?(i,PBItems,:HYPERPOTION) || 
         isConst?(i,PBItems,:MAXPOTION)
        return i if battler.hp<=(battler.totalhp/4).floor
        return i if battler.hp<=(battler.totalhp/2).floor && (pbAIRandom(10)<2)
      elsif isConst?(i,PBItems,:MAXREVIVE)
        for poke in pbParty(battler.index)
          return i if poke.hp<1 && !$game_switches[71]
        end
      elsif isConst?(i,PBItems,:REVIVE)
        for poke in pbParty(battler.index)
          return i if poke.hp<1 && !$game_switches[71]
        end
      elsif isConst?(i,PBItems,:FULLRESTORE)
        return i if battler.hp<=(battler.totalhp/4).floor
        return i if battler.hp<=(battler.totalhp/2).floor && (pbAIRandom(10)<2)
        return i if battler.hp<=(battler.totalhp*2/3).floor && (battler.status>0 || 
           battler.effects[PBEffects::Confusion]>0) && (pbAIRandom(10)<2)
      elsif isConst?(i,PBItems,:FULLHEAL)
        return i if !hashpitem && (battler.status>0 || battler.effects[PBEffects::Confusion]>0)
      elsif isConst?(i,PBItems,:XATTACK)
        return i if !battler.pbTooHigh?(PBStats::ATTACK)
      elsif isConst?(i,PBItems,:XDEFEND)
        return i if !battler.pbTooHigh?(PBStats::DEFENSE)
      elsif isConst?(i,PBItems,:XSPEED)
        return i if !battler.pbTooHigh?(PBStats::SPEED)
      elsif isConst?(i,PBItems,:XSPECIAL)
        return i if !battler.pbTooHigh?(PBStats::SPATK)
      elsif isConst?(i,PBItems,:XSPDEF)
        return i if !battler.pbTooHigh?(PBStats::SPDEF)
      elsif isConst?(i,PBItems,:XACCURACY)
        return i if !battler.pbTooHigh?(PBStats::ACCURACY)
      end
    end
    return 0
  end
  def pbCanMegaEvolve?(index)
    #    return false if index > -1
    # return false if $game_switches[NO_MEGA_EVOLUTION]
    canMega3=false
    # if Kernel.pbGetMegaSpeciesList.include?(@battlers[i].species) && Kernel.pbGetMegaStoneList.include?(@battlers[i].item)
    #         if Kernel.pbGetMegaStoneList.index(@battlers[i].item)==Kernel.pbGetMegaSpeciesList.index(@battlers[i].species)
    canMega3=true if Kernel.pbGetMegaSpeciesStoneWorks(@battlers[i].species,@battlers[i].item)
    #end
    #       end
    if @battlers[i].species==PBSpecies::RAYQUAZA
      rayq=false
      canMega3=true if @battlers[i].moves[0].id==PBMoves::DRAGONSASCENT
      canMega3=true if @battlers[i].moves[1].id==PBMoves::DRAGONSASCENT
      canMega3=true if @battlers[i].moves[2].id==PBMoves::DRAGONSASCENT
      canMega3=true if @battlers[i].moves[3].id==PBMoves::DRAGONSASCENT
    end
    return false if !canMega3
  #return false if pbBelongsToPlayer?(index) && !$PokemonGlobal.megaRing
   # side=(pbIsOpposing?(index)) ? 1 : 0
   # owner=pbGetOwnerIndex(index)
    return false if @player.megaforme
    return true
  end

 # def pbRegisterMegaEvolution(index)
 #   side=(pbIsOpposing?(index)) ? 1 : 0
 #   owner=pbGetOwnerIndex(index)
 #   @megaEvolution[side][owner]=index
 # end
  def pbMegaEvolve(index,primal=false)
    $tempDoubleMega=nil
    playervar=pbGetOwner(index)
=begin
      if @player.is_a?(Array)
        playervar = @player[0]
      else
        playervar = @player
      end
=end
    zoroarkopp = false
    megaItem=@battlers[index].item(true)
    megaBattler=@battlers[index].pokemon
    if @battlers[index].effects[PBEffects::Illusion]
      #isConst?(@battlers[index].pokemon.ability,PBAbilities,:ILLUSION)
      megaList=Kernel.pbGetMegaSpeciesList
      if megaList.include?(@battlers[index].species)
        idx=Kernel.pbGetMegaSpeciesList.index(@battlers[index].species)
        megaItem=Kernel.pbGetMegaStoneList[idx]
        zoroarkopp=true
      end
      megaBattler=@battlers[index].effects[PBEffects::Illusion]
      #newpokename=@battle.pbGetLastPokeInTeam(i)
    end
    #if @battlers[index].pokemon.species==PBSpecies::ZOROARK
    #  Kernel.pbMessage("moo")
    #end

    ownername=pbGetOwner(index) ? pbGetOwner(index).name : "Null" #
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
    megaObject="Mixtape" if pbIsOpposing?(index) && (ownername=="Darude" || ownername=="Eduard")
    megaObject="Ankh" if pbIsOpposing?(index) && ownername=="Kayla"
    megaObject="Band" if pbIsOpposing?(index) && ownername=="London"
    megaObject="Bracelet" if pbIsOpposing?(index) && ownername=="Audrey"
    megaObject="Ring" if pbIsOpposing?(index) && ownername=="Damian"
    megaObject="Ring" if pbIsOpposing?(index) && ownername=="Nora"
    megaObject="Crown" if pbIsOpposing?(index) && ownername=="Jaern"
    megaObject="Crystal" if pbIsOpposing?(index) && ownername=="Nyx"
    megaObject="Core" if pbIsOpposing?(index) && ownername=="Malde"
    #illusionStatus=!(@battlers[index].ability!=PBAbilities::ILLUSION || $illusion == nil || (!$illusion.is_a?(Array) && $illusion[index] == nil))
    #if illusionStatus && pbIsOpposing?(index)
    #  $illusionpoke = @party2[@party2.length-1]# if isConst?(pokemon.ability,PBAbilities,:ILLUSION)
    #end
    if zoroarkopp || !@battlers[index].effects[PBEffects::Illusion]
      pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s Mega "+megaObject+"!",
         @battlers[index].pbThis,PBItems.getName(megaItem),#@battlers[index].item(true)),
         ownername)) if !primal && !isConst?(@battlers[index].species,PBSpecies,:RAYQUAZA) && !@battlers[index].hasWorkingItem(:CRYSTALFRAGMENT) #&& !illusionStatus
      pbDisplay(_INTL("{1} is reacting to its {2}!",@battlers[index].pbThis,
         PBItems.getName(megaItem))) if primal && !isConst?(@battlers[index].species,PBSpecies,:DELTAMETAGROSS2) 
      pbDisplay(_INTL("{1} began to crystallize!",@battlers[index].pbThis)) if @battlers[index].hasWorkingItem(:CRYSTALFRAGMENT) && isConst?(@battlers[index].species,PBSpecies,:DELTAMETAGROSS2)        
      pbDisplay(_INTL("{1}'s prayers reached {2}!",ownername,
         @battlers[index].pbThis)) if pbOwnedByPlayer?(index) && isConst?(@battlers[index].species,PBSpecies,:RAYQUAZA) 
      pbDisplay(_INTL("{2} was reached by {1}'s prayers!",ownername,
         @battlers[index].pbThis)) if !pbOwnedByPlayer?(index) && isConst?(@battlers[index].species,PBSpecies,:RAYQUAZA) 
    end
    # Mega Zoroark's ability to fake other megas.
    #if illusionStatus && Kernel.pbGetMegaSpeciesList.include?($illusionpoke.species)
    #  if $illusionpoke.species==PBSpecies::RAYQUAZA
    #    pbDisplay(_INTL("{1}'s prayers reached {2}!",ownername,@battlers[index].pbThis)) if illusionStatus
    #  else
    #    theirFakeStone=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index($illusionpoke.species)]
    #    pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s Mega "+megaObject+"!",
    #    @battlers[index].pbThis,PBItems.getName(theirFakeStone),ownername)) if illusionStatus
    #  end
    #end
    begin # ehhh megaforme
      playervar.megaforme=true if !primal
    rescue
    end
    if !pbIsOpposing?(index) && !(#isConst?(@battlers[index].pokemon.species,PBSpecies,:STEELIX) || 
      isConst?(@battlers[index].species,PBSpecies,:DELTACHARIZARD))# ||
      $mega_transfer = true
    end

    #zoroarkopp = true if !pbOwnedByPlayer?(index) && $illusion != nil && $illusion.is_a?(Array) && $illusion[index] != nil #&& isConst?(@battlers[index].pokemon.species,PBSpecies,:ZOROARK)
    #@battlers[index].isMZO=true if zoroarkopp
       #TEMPMEGASLOT
    #if zoroarkopp && $illusionpoke && !Kernel.pbGetMegaSpeciesList.include?($illusionpoke.species)  #&& !Kernel.pbGetMegaSpeciesList($illusionpoke.species)#      @battlers[index].pokemon.=1
    #  saveform=@battlers[index].pokemon.form
    #  @battlers[index].pokemon.form=1
    #  if isConst?(@battlers[index].species,PBSpecies,:GIRATINA)
    #    @battlers[index].pokemon.form=2 
    #  end
    #  @battlers[index].pokemon.form=19 if isConst?(@battlers[index].species,PBSpecies,:ARCEUS)
    #  @battlers[index].pokemon.form=2 if isConst?(@battlers[index].item,PBItems,:STEELIXITE)
    #  @battlers[index].pokemon.form=2 if isConst?(@battlers[index].species,PBSpecies,:DELTAMETAGROSS2) && primal
    #  @battlers[index].pokemon.form=5 if saveform==4 && isConst?(@battlers[index].species,PBSpecies,:MEWTWO)
    #  @battlers[index].pokemon.form=2 if isConst?(@battlers[index].item,PBItems,:CHARIZARDITEY) || isConst?(@battlers[index].item,PBItems,:MEWTWONITEX) || isConst?(@battlers[index].item,PBItems,:FLYGONITE)
    #  @battlers[index].pokemon.form=3 if isConst?(@battlers[index].item,PBItems,:MEWTWONITEY)
    #  #$mega_transfer = true if pbIsOpposing(index) && isConst?(@battlers[index].pokemon.species,PBSpecies,:MAGMORTAR)
    #else
    pbHiddenMoveAnimation(megaBattler,true,zoroarkopp) if zoroarkopp || !@battlers[index].effects[PBEffects::Illusion]
    if @battlers[index].effects[PBEffects::Illusion]#zoroarkopp
      @battlers[index].pokemon.form=1
      @battlers[index].form=1
      @battlers[index].pbUpdate(true)
      @scene.pbChangePokemon(@battlers[index],megaBattler,false,nil) if zoroarkopp
      pbDisplay(_INTL("{1} transformed!",@battlers[index].pbThis)) if zoroarkopp
      if @battlers[index].effects[PBEffects::Substitute]>0
        @scene.pbChangePokemon(@battlers[index],@battlers[index].pokemon,true)
      end
    else
      @battlers[index].pbCheckForm(zoroarkopp)
    end
    #pbHiddenMoveAnimation(@battlers[index].pokemon,true,zoroarkopp)
    #end
    pbDisplay(_INTL("Pierce the heavens with your drill!")) if isConst?(@battlers[index].pokemon.species,PBSpecies,:GOLURK)
    side=(pbIsOpposing?(index)) ? 1 : 0
    $mega_battlers[index]=false
    @battlers[index].pbAbilitiesOnSwitchIn(true)
=begin
    if isConst?(@battlers[index].pokemon.species,PBSpecies,:SUNFLORA)
      @battlers[index].pbIncreaseStatBasic(PBStats::SPEED,1)
      @battlers[index].pbIncreaseStatBasic(PBStats::SPATK,1)
      pbDisplay(_INTL("{1} is furious!",@battlers[index].pbThis))
    end
=end
    # if isConst?(@battlers[index].pokemon.species,PBSpecies,:KYOGRE)
    #@weather=PBWeather::RAINDANCE
    #@weatherduration=-1
    #primordialsea=true
    #pbDisplay(_INTL("{1}'s Primordial Sea caused a heavy rain to fall.",@battlers[index].pbThis))
    #   @scene.pbBackdropMove(0,true,true)
    #end
    
    # if isConst?(@battlers[index].pokemon.species,PBSpecies,:GROUDON)
    #   @weather=PBWeather::SUNNYDAY
    #@weatherduration=-1
    #      @desolateland=true
    
    #pbDisplay(_INTL("{1}'s Desolate Land made the sun turn harsh!",@battlers[index].pbThis))
    #   @scene.pbBackdropMove(0,true,true)
    #end
    # if isConst?(@battlers[index].pokemon.species,PBSpecies,:RAYQUAZA)
    #   @deltastream=true
    #   @weather=0

    #    pbDisplay(_INTL("A mysterious air current is protecting Flying-type Pokemon!"))
    #   @scene.pbBackdropMove(0,true,true)
    # end
  end


  
  def pbEnemyItemAlreadyUsed?(index,item,items)
    if @choices[1][0]==3 && @choices[1][1]==item
      qty=0
      for i in items
        qty+=1 if i==item
      end
      return true if qty<=1
    end
    return false
  end

  def pbEnemyShouldUseItem?(index)
    item=pbEnemyItemToUse(index)
    if item>0
      pbRegisterItem(index,item)
      return true
    end
    return false
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
      battler.pbRecoverHP(20)
      pbDisplayBrief(_INTL("{1} regained health!",battler.pbThis))
    elsif isConst?(item,PBItems,:REVIVE) && !$game_switches[71]
      for poke in pbParty(battler.index)
        if poke.hp<1
         poke.hp=(poke.totalhp/2).floor
          pbDisplayBrief(_INTL("{1} was revived!",poke.name))
          break
        end
      end
      elsif isConst?(item,PBItems,:MAXREVIVE)  && !$game_switches[71] 
      for poke in pbParty(battler.index)
        if poke.hp<1 #&& poke.species != PBSpecies::GRENINJA
         poke.hp=poke.totalhp
          pbDisplayBrief(_INTL("{1} was revived!",poke.name))
          break
        end
      end
    elsif isConst?(item,PBItems,:SUPERPOTION)
      battler.pbRecoverHP(50)
      pbDisplayBrief(_INTL("{1} regained health!",battler.pbThis))
    elsif isConst?(item,PBItems,:HYPERPOTION)
      battler.pbRecoverHP(200)
      pbDisplayBrief(_INTL("{1} regained health!",battler.pbThis))
    elsif isConst?(item,PBItems,:MAXPOTION)
      battler.pbRecoverHP(battler.totalhp-battler.hp)
      pbDisplayBrief(_INTL("{1} regained health!",battler.pbThis))
    elsif isConst?(item,PBItems,:XATTACK)
      if !battler.pbTooHigh?(PBStats::ATTACK)
        battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
        pbCommonAnimation("StatUp",battler,nil) if !battler.isInvulnerable?
        pbDisplayBrief(_INTL("{1}'s Attack rose!",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:XDEFEND)
      if !battler.pbTooHigh?(PBStats::DEFENSE)
        battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
        pbCommonAnimation("StatUp",battler,nil) if !battler.isInvulnerable?
        pbDisplayBrief(_INTL("{1}'s Defense rose!",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:XSPEED)
      if !battler.pbTooHigh?(PBStats::SPEED)
        battler.pbIncreaseStatBasic(PBStats::SPEED,1)
        pbCommonAnimation("StatUp",battler,nil) if !battler.isInvulnerable?
        pbDisplayBrief(_INTL("{1}'s Speed rose!",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:XSPECIAL)
      if !battler.pbTooHigh?(PBStats::SPATK)
        battler.pbIncreaseStatBasic(PBStats::SPATK,1)
        pbCommonAnimation("StatUp",battler,nil) if !battler.isInvulnerable?
        pbDisplayBrief(_INTL("{1}'s Special Attack rose!",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:XSPDEF)
      if !battler.pbTooHigh?(PBStats::SPDEF)
        battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
        pbCommonAnimation("StatUp",battler,nil) if !battler.isInvulnerable?
        pbDisplayBrief(_INTL("{1}'s Special Defense rose!",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:XACCURACY)
      if !battler.pbTooHigh?(PBStats::ACCURACY)
        battler.pbIncreaseStatBasic(PBStats::ACCURACY,1)
        pbCommonAnimation("StatUp",battler,nil) if !battler.isInvulnerable?
        pbDisplayBrief(_INTL("{1}'s accuracy rose!",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:FULLRESTORE)
      fullhp=(battler.hp==battler.totalhp)
      battler.pbRecoverHP(battler.totalhp-battler.hp)
      battler.status=0
      battler.effects[PBEffects::Confusion]=0
      if fullhp
        pbDisplayBrief(_INTL("{1} became healthy!",battler.pbThis))
      else
        pbDisplayBrief(_INTL("{1} regained health!",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:FULLHEAL)
      battler.status=0
      battler.effects[PBEffects::Confusion]=0
      pbDisplayBrief(_INTL("{1} became healthy!",battler.pbThis))
    end
  end

  def pbRegisterTarget(idxPokemon,idxTarget)
    thispkmn=@battlers[idxPokemon]
    @choices[idxPokemon][3]=idxTarget
    return true
  end

  def pbAIRandom(x)
    return rand(x)
  end
  
  def pbRandom(x)
    return rand(x)
  end
  

  def pbChoseMoveFunctionCode?(i,code)
    return false if @battlers[i].hp<=0
    if @choices[i][0]==1 && @choices[i][1]>=0
      choice=@choices[i][1]
      return @battlers[i].moves[choice].function==code
    end
    return false
  end

  def pbPriority(ignorequickclaw=false)
    if @usepriority
      # use stored priority if round isn't over yet
      return @priority
    end
    speeds=[]
    quickclaw=[]; lagging=[]
    priorities=[]
    temp=[]
    @priority.clear
    maxpri=0
    minpri=0
    # Calculate each Pokémon's speed
    ##dicktits
    
    for i in 0...4
      speeds[i]=@battlers[i].pbSpeed
      quickclaw[i]=false
      lagging[i]=false
      if !ignorequickclaw && @choices[i][0]==1 # Chose to use a move
        if !quickclaw[i] && @battlers[i].hasWorkingItem(:CUSTAPBERRY) &&
           !@battlers[i].pbOpposing1.hasWorkingAbility(:UNNERVE) &&
           !@battlers[i].pbOpposing2.hasWorkingAbility(:UNNERVE)
          if (@battlers[i].hasWorkingAbility(:GLUTTONY) && @battlers[i].hp<=(@battlers[i].totalhp/2).floor) ||
             @battlers[i].hp<=(@battlers[i].totalhp/4).floor
            #pbCommonAnimation("UseItem",@battlers[i],nil)
            quickclaw[i]=true
            pbDisplayBrief(_INTL("{1}'s {2} let it move first!",
               @battlers[i].pbThis,PBItems.getName(@battlers[i].item)))
            @battlers[i].pbConsumeItem
          end
        end
        if !quickclaw[i] && @battlers[i].hasWorkingItem(:QUICKCLAW)
          if pbRandom(10)<2
            #pbCommonAnimation("UseItem",@battlers[i],nil)
            quickclaw[i]=true
            pbDisplayBrief(_INTL("{1}'s {2} let it move first!",
               @battlers[i].pbThis,PBItems.getName(@battlers[i].item)))
          end
        end
        if !quickclaw[i] &&
           (@battlers[i].hasWorkingAbility(:STALL) ||
           @battlers[i].hasWorkingItem(:LAGGINGTAIL) ||
           @battlers[i].hasWorkingItem(:FULLINCENSE))
          lagging[i]=true
        end
      end
    end
    
    # Find the maximum and minimum priority
    for i in 0..3
      # For this function, switching and using items
      # is the same as using a move with a priority of 0
      pri=0
      if @choices[i][0]==1 # Is a move
        pri=@choices[i][2].priority
        pri+=1 if @battlers[i].hasWorkingAbility(:PRANKSTER) &&
                  @choices[i][2].basedamage==0 # Is status move
        pri+=1 if @battlers[i].pbOwnSide.effects[PBEffects::JetStream]>0
        pri+=1 if @battlers[i].hasWorkingAbility(:GALEWINGS) &&
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
=begin
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
        for m in 0..n-2
          for i in 1..n-1
            if quickclaw[temp[i]]
              cmp=(quickclaw[temp[i-1]]) ? 0 : -1 #Rank higher if without Quick Claw, or equal if with it
            elsif quickclaw[temp[i-1]]
              cmp=1 # Rank lower
            elsif lagging[temp[i]]
              cmp=(lagging[temp[i-1]]) ? -1 : 0
            elsif lagging[temp[i-1]]
              cmp=-1
            elsif speeds[temp[i]]!=speeds[temp[i-1]]
              cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? -1 : 1 #Rank higher to higher-speed battler
            else
              cmp=0
            end
            if cmp<0 && @field.effects[PBEffects::TrickRoom]==0
              # put higher-speed Pokémon first
              swaptmp=temp[i]
              temp[i]=temp[i-1]
              temp[i-1]=swaptmp

            #elsif speeds[temp[i]]!=speeds[temp[i-1]]
            #  if @field.effects[PBEffects::TrickRoom]>0
            #    cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? 1 : -1
            #  else
            #    cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? -1 : 1
            #  end
            #end
            
            elsif cmp>0 && @field.effects[PBEffects::TrickRoom]>0
              swaptmp=temp[i]
              temp[i]=temp[i-1]
              temp[i-1]=swaptmp

            elsif cmp==0
              # swap at random if speeds are equal
              if pbRandom(2)==0
                swaptmp=temp[i]
                temp[i]=temp[i-1]
                temp[i-1]=swaptmp
              end
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

    @usepriority=true
    return @priority
  end
=end
      for j in 0...4
        temp.push(j) if priorities[j]==curpri
      end
      # Sort by speed
      if temp.length==1
        @priority[@priority.length]=@battlers[temp[0]]
      elsif temp.length>1
        n=temp.length
        for m in 0...temp.length-1
          for i in 1...temp.length
            # For each pair of battlers, rank the second compared to the first
            # -1 means rank higher, 0 means rank equal, 1 means rank lower
            cmp=0
            if quickclaw[temp[i]]
              cmp=-1
              if quickclaw[temp[i-1]]
                if speeds[temp[i]]==speeds[temp[i-1]]
                  cmp=0
                else
                  cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? -1 : 1
                end
              end
            elsif quickclaw[temp[i-1]]
              cmp=1
            elsif lagging[temp[i]]
              cmp=1
              if lagging[temp[i-1]]
                if speeds[temp[i]]==speeds[temp[i-1]]
                  cmp=0
                else
                  cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? 1 : -1
                end
              end
            elsif lagging[temp[i-1]]
              cmp=-1
            elsif speeds[temp[i]]!=speeds[temp[i-1]]
              if @field.effects[PBEffects::TrickRoom]>0
                cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? 1 : -1
              else
                cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? -1 : 1
              end
            end
            if cmp<0 || # Swap the pair according to the second battler's rank
               (cmp==0 && pbRandom(2)==0)
              swaptmp=temp[i]
              temp[i]=temp[i-1]
              temp[i-1]=swaptmp
            end
          end
        end
        # Battlers in this bracket are properly sorted, so add them to @priority
        for i in temp
          @priority[@priority.length]=@battlers[i]
        end
      end
      curpri-=1
      break if curpri<minpri
    end
    @usepriority=true
    return @priority
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

  def pbPokemonCount(party)
    count=0
    for i in party
      next if !i
      if i.hp>0 && !i.egg?
        count+=1
      end
    end
    return count
  end

  def pbAllFainted?(party)
    pbPokemonCount(party)==0
  end

  def pbAbilityEffect(move,user,target,damage) #ILLU1 pbOwnedByPlayer
    #if (target.effects[PBEffects::SuckerPunch]) && damage>0
    #    target.effects[PBEffects::SuckerPunch]=false
    #  end
    #if pbParty(target.index).length>1
      #if (target.hasWorkingAbility(:ILLUSION) || target.species==PBSpecies::ZOROARK) && damage > 0 && target.hp>0
      #  if $illusion[target.index] != nil || (target.species==PBSpecies::ZOROARK && target.form!=0)
      #    if !target.saidIllu
      #    pbDisplay("The Illusion was broken!")
      #    target.saidIllu=true
      #    @scene.pbTrainerSendOut(target.index,$illusion[target.index],true) if !pbOwnedByPlayer?(target.index)
      #    @scene.pbSendOut(target.index,$illusion[target.index],true) if pbOwnedByPlayer?(target.index)
      #    end
      #    $illusion[target.index]=nil
      #    end
      #  end
    #end
      #if isConst?(move.id,PBMoves,:FELLSTINGER) && user.hp>0 && target.hp<=0
      #    user.pbIncreaseStatBasic(PBStats::ATTACK,2)
      #    pbDisplay(_INTL("{1}'s attack sharply rose!",user.pbThis))

      #  end    


    #if user.hasWorkingAbility(:MOXIE) && user.hp>0 && target.hp<=0
    #  user.pbIncreaseStatBasic(PBStats::ATTACK,1)
    #  pbDisplay(_INTL("{1}'s Moxie increased its attack!",user.pbThis))
    #end
    #if user.hasWorkingAbility(:HUBRIS) && user.hp>0 && target.hp<=0
    #  user.pbIncreaseStatBasic(PBStats::SPATK,1)
    #  pbDisplay(_INTL("Hubris boosted {1}'s Sp. Atk!",user.pbThis))
    #end
    if (move.flags&0x01)==0 && damage>0
      
      
    #if target.hasWorkingAbility(:DIAMONDSKIN) && user.hp>0
    #  user.pbReduceHP((user.totalhp/10).floor)
    #  pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
    #    PBAbilities.getName(target.ability),user.pbThis(true)))
    #  end
    end
    
    #if damage>0 && target.hasWorkingItem(:AIRBALLOON)
    #  target.pokemon.itemRecycle=target.item
    #  target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
    #  target.item=0
    #  pbDisplay(_INTL("{1}'s Air Balloon burst!",target.pbThis));
    #end
    
    if (move.flags&0x01)!=0 && damage>0 # flag A: Makes contact
      #if target.hasWorkingAbility(:STATIC) && self.pbRandom(10)<3 &&
      #   user.pbCanParalyze?(nil,false)
      #  user.pbParalyze(target)
      #  pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
      #     target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
      #   end
      #     if target.hasWorkingAbility(:GOOEY)
      #    user.pbReduceStatBasic(PBStats::SPEED,1)
      #  pbDisplay(_INTL("{1}'s {2} lowered {3}'s Speed!",
      #     target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
      #end
      #if target.hasWorkingAbility(:POISONPOINT) &&
      #   self.pbRandom(10)<3 && user.pbCanPoison?(nil,false)
      #  user.pbPoison(target)
      #  pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
      #     PBAbilities.getName(target.ability),user.pbThis(true)))
      #end
      #if user.hasWorkingAbility(:POISONTOUCH) &&
      #   self.pbRandom(10)<3 && target.pbCanPoison?(nil,false)
      #  target.pbPoison(user)
      #  pbDisplay(_INTL("{1}'s {2} poisoned {3}!",user.pbThis,
      #     PBAbilities.getName(user.ability),target.pbThis(true)))
      #end
      #if target.hasWorkingAbility(:FLAMEBODY) &&
      #  self.pbRandom(10)<3 && user.pbCanBurn?(nil,false)
      #  user.pbBurn(target)
      #  pbDisplay(_INTL("{1}'s {2} burned {3}!",target.pbThis,
      #     PBAbilities.getName(target.ability),user.pbThis(true)))
      #end
      #if target.hasWorkingAbility(:EFFECTSPORE) && self.pbRandom(10)<3
      #  if user.hasType?(:GRASS) || user.effects[PBEffects::ForestsCurse] || 
      #     user.hasWorkingAbility(:OVERCOAT) ||
      #     user.hasWorkingItem(:SAFETYGOGGLES)
      #     # Do nothing
      #  else
      #    rnd=self.pbRandom(3)
      #    if rnd==0 && user.pbCanPoison?(nil,false)
      #      user.pbPoison(target)
      #      pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
      #         PBAbilities.getName(target.ability),user.pbThis(true)))
      #    elsif rnd==1 && user.pbCanSleep?(nil,false)
      #      user.pbSleep
      #      pbDisplay(_INTL("{1}'s {2} made {3} sleep!",target.pbThis,
      #         PBAbilities.getName(target.ability),user.pbThis(true)))
      #    elsif rnd==2 && user.pbCanParalyze?(nil,false)
      #      user.pbParalyze(target)
      #      pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
      #         target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
      #    end
      #  end           
      #end
      #if target.hasWorkingAbility(:CUTECHARM) && self.pbRandom(10)<3
      # if !user.hasWorkingAbility(:OBLIVIOUS) &&
      #     ((user.gender==1 && target.gender==0) ||
      #     (user.gender==0 && target.gender==1)) &&
      #     user.effects[PBEffects::Attract]<0 && user.hp>0 && target.hp>0
      #    user.effects[PBEffects::Attract]=target.index
      #    pbDisplay(_INTL("{1}'s {2} infatuated {3}!",target.pbThis,
      #       PBAbilities.getName(target.ability),user.pbThis(true)))
      #    if isConst?(user.item,PBItems,:DESTINYKNOT) &&
      #       !target.hasWorkingAbility(:OBLIVIOUS) &&
      #       target.effects[PBEffects::Attract]<0
      #      target.effects[PBEffects::Attract]=user.index
      #      pbDisplay(_INTL("{1}'s {2} infatuated {3}!",user.pbThis,
      #         PBItems.getName(user.item),target.pbThis(true)))
      #    end
      #  end
      #end
      #if target.hasWorkingAbility(:ROUGHSKIN) && user.hp>0
      #  user.pbReduceHP((user.totalhp/8).floor)
      #  pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
      #     PBAbilities.getName(target.ability),user.pbThis(true)))
      #   end
         
      #if target.hasWorkingAbility(:EVENTHORIZON) && user.hp>0
      #  if user.effects[PBEffects::MeanLook]>=0 ||
      #     user.effects[PBEffects::Substitute]>0
      #    #  @battle.pbDisplay(_INTL("But it failed!"))
      #    #return -1
      #  else
      #    user.effects[PBEffects::MeanLook]=target.index
      #   # @battle.pbAnimation(@id,attacker,opponent)
      #    @battle.pbDisplay(_INTL("Event Horizon stopped {1} from escaping!",user.pbThis))
      #  end
      #end
      
      #if target.hasWorkingAbility(:IRONBARBS) && user.hp>0
      #  user.pbReduceHP((user.totalhp/8).floor)
      #  pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
      #     PBAbilities.getName(target.ability),user.pbThis(true)))
      #   end
      #if target.hasWorkingAbility(:AFTERMATH) && user.hp>0 && target.hp<=0
      #  if !pbCheckGlobalAbility(:DAMP) && !user.hasMoldbreaker && !user.hasWorkingAbility(:MAGICGUARD)
      #    user.pbReduceHP((user.totalhp/4).floor)
      #    pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
      #  end
      #end


      #if isConst?(target.item,PBItems,:ROCKYHELMET) && user.hp>0
      #  user.pbReduceHP((user.totalhp/6).floor)
      #  pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
      #     PBItems.getName(target.item),user.pbThis(true)))
      #end
      #if user.hasWorkingAbility(:MAGICIAN)
      #  if target.item(true)>0 && user.item(true)==0 &&
      #     user.effects[PBEffects::Substitute]==0 &&
      #     target.effects[PBEffects::Substitute]==0 &&
      #     !target.hasWorkingAbility(:STICKYHOLD) &&
      #     !pbIsUnlosableItem(target,target.item(true)) &&
      #     !pbIsUnlosableItem(user,target.item(true)) &&
      #     (@battle.opponent || !@battle.pbIsOpposing?(user.index))
      #    user.item=target.item(true)
      #    target.item=0
      #    target.effects[PBEffects::Unburden]=true
      #    if !@battle.opponent &&   # In a wild battle
      #       user.pokemon.itemInitial==0 &&
      #       target.pokemon.itemInitial==target.item(true)
      #      user.pokemon.itemInitial=target.item(true)
      #      target.pokemon.itemInitial=0
      #    end
      #    pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",target.pbThis,
      #       user.pbThis(true),PBItems.getName(target.item(true)),PBAbilities.getName(user.ability)))
      #  end
      #end
      #if target.hasWorkingAbility(:PICKPOCKET) && target.hp>0
      #  if target.item(true)==0 && user.item(true)>0 &&
      #     user.effects[PBEffects::Substitute]==0 &&
      #     target.effects[PBEffects::Substitute]==0 &&
      #     !user.hasWorkingAbility(:STICKYHOLD) &&
      #     !pbIsUnlosableItem(user,user.item(true)) &&
      #    !pbIsUnlosableItem(target,user.item(true)) &&
      #    (@battle.opponent || !@battle.pbIsOpposing?(target.index))
      #    target.item=user.item(true)
      #    user.item=0
      #    target.effects[PBEffects::Unburden]=true
      #    if !@battle.opponent &&   # In a wild battle
      #       target.pokemon.itemInitial==0 &&
      #       user.pokemon.itemInitial==target.item(true)
      #     target.pokemon.itemInitial=target.item(true)
      #      user.pokemon.itemInitial=0
      #    end
      #   pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
      #       user.pbThis(true),PBItems.getName(target.item(true))))
      #  end
      #end
      #if target.hasWorkingAbility(:MUMMY) && user.hp>0
      #  if !user.hasWorkingAbility(:MULTITYPE) &&
      #     !user.hasWorkingAbility(:WONDERGUARD) &&
      #     !user.hasWorkingAbility(:MUMMY)
      #    user.ability=getConst(PBAbilities,:MUMMY) || 0
      #    pbDisplay(_INTL("{1} was mummified by {2}!",user.pbThis,target.pbThis(true)))
      #  end
      #end
      #if target.hasWorkingAbility(:GLITCH) && user.hp>0
      #     pbDisplay(_INTL("{1} was corrupted by {2}!",user.pbThis,target.pbThis(true)))
      #    user.hp=0
      #    end
      end
    #if target.hasWorkingAbility(:CURSEDBODY) && self.pbRandom(10)<3
    #  if user.effects[PBEffects::Disable]<=0 && move.pp>0 && user.hp>0
    #    user.effects[PBEffects::Disable]=4+self.pbRandom(4)
    #    user.effects[PBEffects::DisableMove]=move.id
    #    pbDisplay(_INTL("{1}'s {2} disabled {3}!",target.pbThis,
    #       PBAbilities.getName(target.ability),user.pbThis(true)))
    #  end
    #end
    #type=move.pbType(move.type,user,target)
    #if target.hasWorkingAbility(:COLORCHANGE) && target.hp>0 &&
    #   damage>0 && !PBTypes.isPseudoType?(type) && !target.pbHasType?(type)
    #  target.type1=type
    #  target.type2=type
    #  pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
    #     PBAbilities.getName(target.ability),PBTypes.getName(type)))
    #end
    user.pbAbilityCureCheck
    target.pbAbilityCureCheck
    # Synchronize here
    s=@synchronize[0]
    t=@synchronize[1]
#   PBDebug.log("[synchronize: #{@synchronize.inspect}]")
    if s>=0 && t>=0 && @battlers[s].hasWorkingAbility(:SYNCHRONIZE) &&
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

  def pbFindPlayerBattler(pkmnIndex)
    battler=nil
    for k in 0..3
      if !pbIsOpposing?(k) && @battlers[k].pokemonIndex==pkmnIndex
        battler=@battlers[k]
        break
      end
    end
    return battler
  end
#=begin
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


  def pbGainEXP(wildbattle=false)#(justevs=false)
    return if [695,696,693,700,701,694,698,834,835,836,837,838,839,840,841].include?($game_map.map_id)
    return if !@internalbattle
        
    successbegin=true
    for i in 0..3 # Not ordered by priority
        
      if !@doublebattle && pbIsDoubleBattler?(i)
        @battlers[i].participants=[]
        next
      end
      if pbIsOpposing?(i) && @battlers[i].participants.length>0 && (@battlers[i].hp<=0 || wildbattle)
        battlerSpecies=@battlers[i].pokemon.species
    
        # Original species, not current species; also using R/S base EXP
        baseexp=@battlers[i].pokemon.baseExp
        level=@battlers[i].level
        # First count the number of participants
        partic=0
        expshare=0

        for j in @battlers[i].participants
          next if $game_map.map_id==709 || $game_map.map_id==108

          @participants[j]=true # Add participant to global list
        end
        for j in @battlers[i].participants
                    next if $game_map.map_id==709 || $game_map.map_id==108

          next if !@party1[j] || !pbIsOwner?(0,j)
          partic+=1 if @party1[j].hp>0 && !@party1[j].egg?
        end
        for j in 0..@party1.length-1
          next if !@party1[j] || !pbIsOwner?(0,j)
          next if $game_map.map_id==709 || $game_map.map_id==108
          expshare+=1 if @party1[j].hp>0 && !@party1[j].egg? && 
             (isConst?(@party1[j].item,PBItems,:EXPSHARE) ||
              isConst?(@party1[j].itemInitial,PBItems,:EXPSHARE) ||
              (@party1[j].level<120 && $game_switches[339]))
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
            haveexpshare=(isConst?(thispoke.item,PBItems,:EXPSHARE) || (thispoke.level<120 && $game_switches[339]) ||
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
              hasNoExpGain=false
              for miniAry in LEVELCAPS
                if $PokemonSystem.chooseDifficulty==2 && !$game_switches[miniAry[0]] && thispoke.level>=miniAry[1]
                  exp=1
                  hasNoExpGain=true
                  break
                end
              end

  #            LEVELCAPS = [
 # [57,17], #Tournament
 # [59,19], #Ruin
              if USENEWEXPFORMULA   # Use new (Gen 5) Exp. formula
                #exp=(exp/5).floor

                #leveladjust=(2*level+10.0)/(level+thispoke.level+10.0)
                leveladjust=((2*level+10.0)**2.5/(level+thispoke.level+10.0)**2.5)
                #leveladjust=leveladjust**5
                #leveladjust=Math.sqrt(leveladjust)
                exp=(exp*leveladjust/5).floor
                exp+=1 if ispartic>0 || haveexpshare>0
              else                  # Use old (Gen 1-4) Exp. formula
                exp=(exp/7).floor
              end

              isOutsider=(thispoke.trainerID!=self.pbPlayer.id ||
                 (thispoke.ot && thispoke.ot!=self.pbPlayer.name))
                 #(thispoke.language!=0 && thispoke.language!=self.pbPlayer.language))
              if isOutsider
                if thispoke.language!=0 && thispoke.language!=self.pbPlayer.language
                  exp=(exp*17/10).floor
                else
                  exp=(exp*3/2).floor
                end
              end

             exp=(exp*1.8).floor if $game_switches[4] && !$game_switches[5]
             exp=(exp*2.5).floor if $game_switches[153] && !$game_switches[197]
           #   exp=(exp*2).floor if $game_switches[154] && !$game_switches[197]
            #  exp=(exp*2).floor if $game_switches[155] && !$game_switches[197]
              exp=(exp*1.45).floor if !$game_switches[6] && !$game_map.map_id==149 && !$game_map.map_id=225
              exp=(exp*1/3).floor if $game_map.map_id==286
              #exp=(exp*5/3).floor if thispoke.species==PBSpecies::CHANSEY || thispoke.species==PBSpecies::BLISSEY
              exp=(exp*3/2).floor if isConst?(thispoke.item,PBItems,:LUCKYEGG) ||
                                     isConst?(thispoke.itemInitial,PBItems,:LUCKYEGG)
              growthrate=thispoke.growthrate
              newexp=PBExperience.pbAddExperience(thispoke.exp,exp,growthrate)
              exp=newexp-thispoke.exp
                              totalev=0
                for k in 0..5
                  totalev+=thispoke.ev[k]
                end
                if (exp > 0 || (thispoke.level == 120 && ((isConst?(thispoke.item,PBItems,:EXPSHARE)|| $game_switches[339]) || ispartic>0))) && (!$game_switches[340] || [428,429,430,431,491].include?($game_map.map_id)) && !$game_switches[267]
                                  evyield=@battlers[i].pokemon.evYield
                for k in 0..5
                  evgain=evyield[k]
                  evgain*=2 if isConst?(thispoke.item,PBItems,:MACHOBRACE)                  
                  evgain+=4 if k==0 && isConst?(thispoke.item,PBItems,:POWERWEIGHT) 
                  evgain+=4 if k==1 && isConst?(thispoke.item,PBItems,:POWERBRACER) 
                  evgain+=4 if k==2 && isConst?(thispoke.item,PBItems,:POWERBELT) 
                  evgain+=4 if k==3 && isConst?(thispoke.item,PBItems,:POWERANKLET)
                  evgain+=4 if k==4 && isConst?(thispoke.item,PBItems,:POWERLENS) 
                  evgain+=4 if k==5 && isConst?(thispoke.item,PBItems,:POWERBAND) 
                  evgain*=2 if thispoke.pokerusStage>=1 # Infected or cured
                  if evgain>0
                    # Can't exceed overall limit
                    if totalev+evgain>510
                      evgain-=totalev+evgain-510
                    end
                    # Can't exceed stat limit
                    if thispoke.ev[k]+evgain>252
                      evgain-=thispoke.ev[k]+evgain-252
                    end
                    # Add EV gain
                    thispoke.ev[k]+=evgain
                    if thispoke.ev[k]>252
                      print "Single-stat EV limit 255 exceeded.\r\nStat: #{k}  EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
                      thispoke.ev[k]=252
                    end
                    totalev+=evgain
                    if totalev>510
                      print "EV limit 510 exceeded.\r\nTotal EVs: #{totalev} EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
                    end
                  end
                end
              end
              if hasNoExpGain && exp > 0
                  pbDisplayPaused(_INTL("{1} gained only {2} Exp. Points due to the Hard Mode level cap.",thispoke.name,exp)) if !$game_switches[339]
                  
              elsif exp > 0 && !$game_switches[340]  && !$game_switches[267]
                if (isOutsider && !$game_switches[356]) || isConst?(thispoke.item,PBItems,:LUCKYEGG)
                  pbDisplayPaused(_INTL("{1} gained a boosted {2} Exp. Points!",thispoke.name,exp)) if !$game_switches[339]
                else
                  pbDisplayPaused(_INTL("{1} gained {2} Exp. Points!",thispoke.name,exp)) if !$game_switches[339]
                end
                #Gain effort value points, using RS effort values
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

  def pbCanChooseNonActive?(index)
    party=pbParty(index)
    for i in 0...party.length
      if pbCanSwitchLax?(index,i,false)
        return true 
      end
    end
    return false
  end
  
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
         !@battlers[index].pbTooHigh?(PBStats::ACCURACY)
      @battlers[index].pbIncreaseStatBasic(PBStats::ACCURACY,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      pbDisplay(_INTL("Its accuracy rose!"))
    else
      pbDisplay(_INTL("But nothing happened!"))
    end
  end

  def pbSwitchInBetween(index,lax,cancancel,nonexistent=false)
    if !pbOwnedByPlayer?(index)
      return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      return pbSwitchPlayer(index,lax,cancancel)
    end
  end

  def pbDecisionOnDraw
    return 5 # draw
  end

  def pbJudge
#   PBDebug.log("[Counts: #{pbPokemonCount(@party1)}/#{pbPokemonCount(@party2)}]")
    if pbAllFainted?(@party1) && pbAllFainted?(@party2)
      if $game_switches[120]
          @decision=1
          return
      end
      
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
    for index in 0..3
      next if !@doublebattle && pbIsDoubleBattler?(index)
      next if @battlers[index] && @battlers[index].hp>0
      next if !pbCanChooseNonActive?(index)
      $wasshadow = false
      if !pbOwnedByPlayer?(index)
        if @opponent
          newenemy=pbSwitchInBetween(index,false,false)
          newenemyname=newenemy
          if newenemy>=0 && isConst?(pbParty(index)[newenemy].ability,PBAbilities,:ILLUSION)
            if newenemy==pbGetLastPokeInTeam(index)
              newenemyname=pbGetLastExcludeTarget(index,@party2[newenemy])#@battlers[index].pokemonIndex
              #newpokename=pbGetSecondLastPokeInTeam(index)#@battlers[index].pokemonIndex)
            else
              newenemyname=pbGetLastPokeInTeam(index)
            end
            #newenemyname=pbGetLastPokeInTeam(index)
          end
          previewSecondParty = index==3 && @opponent.is_a?(Array) && pbSecondPartyBegin(1)==6
          @scene.partyAnimationRestart(index==1 && @doublebattle,previewSecondParty) if index != 2
          opponent=pbGetOwner(index)
          if $meloettatemp == nil
            $meloettatemp = false
          end
          if !@doublebattle && $meloettatemp==false && firstbattlerhp>0 && @shiftStyle && @opponent &&
              @internalbattle && pbCanChooseNonActive?(0) && pbIsOpposing?(index) &&
              @battlers[0].effects[PBEffects::Outrage]==0 && !$game_switches[340] && $game_map.map_id!=696
            pbDisplayPaused(_INTL("{1} is about to send in {2}.",opponent.fullname,PBSpecies.getName(pbParty(index)[newenemyname].species)))
            
            #pbDisplayPaused(_INTL("{1} is about to send in {2}.",opponent.fullname,PBSpecies.getName(@party2[newenemyname].species)))
            if pbDisplayConfirm(_INTL("Will {1} change Pokémon?",self.pbPlayer.name))
              newpoke=pbSwitchPlayer(0,true,true)
              if newpoke>=0
                newpokename=newpoke
                if isConst?(@party1[newpoke].ability,PBAbilities,:ILLUSION)
                  if newpoke==pbGetLastPokeInTeam(0)
                    newpokename=@battlers[0].pokemonIndex
                  else
                    newpokename=pbGetLastPokeInTeam(0)
                  end
                  #newpokename=pbGetLastPokeInTeam(0)
                end
                pbDisplayBrief(_INTL("{1}, that's enough!  Come back!",@battlers[0].name))
                #pbDeregisterMove(0)
                @choices[0]=[0,0,nil,-1]
                pbRecallAndReplace(0,newpoke,false,newpokename)
                switched.push(0)
              end
            end
          else
            $meloettatemp=false if $meloettatemp != nil
            # You can change the time delay for double/Set Option here
            timedelay=64 # Set Option
            timedelay=96 if @doublebattle
            for i in 0...timedelay
              @scene.pbGraphicsUpdate
            end
          end
          @scene.partyAnimationFade if index!=2
          pbRecallAndReplace(index,newenemy,false,newenemyname)
          switched.push(index)
        end
      elsif @opponent
        newpoke=pbSwitchInBetween(index,true,false)
        newpokename=newpoke
        if isConst?(@party1[newpoke].ability,PBAbilities,:ILLUSION)
          if newpoke==pbGetLastPokeInTeam(index)
            #newpokenname=pbGetLastPokeInTeamNonUser(index,@party1[newpoke])
            newpokename=pbGetSecondLastPokeInTeam(index)
          else
            newpokename=pbGetLastPokeInTeam(index)
          end
          #newpokename=pbGetLastPokeInTeam(index)
        end
        pbRecallAndReplace(index,newpoke,false,newpokename)
        switched.push(index)
      else
        switch=false
        #if @opponent || !@doublebattle || $Trainer.ablePokemonCount>1
        if !pbDisplayConfirm(_INTL("Use next Pokémon?")) 
          switch=(pbRun(index,true)<=0)
        else
          switch=true
        end
        if switch
          newpoke=pbSwitchInBetween(index,true,false)
          newpokename=newpoke
          if isConst?(@party1[newpoke].ability,PBAbilities,:ILLUSION)
            if newpoke==pbGetLastPokeInTeam(index)
              #newpokenname=pbGetLastPokeInTeamNonUser(index,@party1[newpoke])
              newpokename=pbGetSecondLastPokeInTeam(index)#@battlers[index].pokemonIndex
            else
              newpokename=pbGetLastPokeInTeam(index)
            end
            #newpokename=pbGetLastPokeInTeam(index)
          end
          pbRecallAndReplace(index,newpoke,false,newpokename)
          switched.push(index)
          #end
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

  # index - Battler index
  # newpoke - Index of Pokemon that is switching in
  # newpokename - Index of Pokemon switching in (modified if Pokemon has Illusion)
  def pbRecallAndReplace(index,newpoke,batonpass=false,newpokename=-1,forced=false)
    #$illusion[index]=nil if $illusion && $illusion.is_a?(Array)
    truebattler=@battlers[index]
    if @battlers[index].hp>0
      if [PBSpecies::KECLEON,PBSpecies::FROAKIE,PBSpecies::FROGADIER,PBSpecies::GRENINJA].include?(truebattler.species)
        truebattler.form=0
      elsif truebattler.species==PBSpecies::DELTADITTO
        truebattler.form=11
      elsif truebattler.species==PBSpecies::ARCEUS && truebattler.form!=19 &&
        truebattler.ability!=PBAbilities::MULTITYPE
        truebattler.form=0
      end
      @scene.pbRecall(index)
    end
    pbMessagesOnReplace(index,newpoke,newpokename)
    pbReplace(index,newpoke,batonpass)
    pbDisplay(_INTL("{1} was dragged out!",@battlers[index].pbThis)) if forced
    @choices[index]=[0,0,nil,-1]
    return pbOnActiveOne(@battlers[index])
  end

  def pbMessagesOnReplace(index,newpoke,newpokename=-1)
    newpokename=newpoke if newpokename<0
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
        pbDisplayBrief(_INTL("Go! {1}!",party[newpokename].name),!$is_insane)
      elsif opposing.hp>=(opposing.totalhp/2)
        pbDisplayBrief(_INTL("Do it! {1}!",party[newpokename].name),!$is_insane)
      elsif opposing.hp>=(opposing.totalhp/4)
        pbDisplayBrief(_INTL("Go for it, {1}!",party[newpokename].name),!$is_insane)
      else
        pbDisplayBrief(_INTL("Your foe's weak!\nGet 'em, {1}!",party[newpokename].name),!$is_insane)
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

      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",owner.fullname,party[newpokename].name))

    end
  end

  def pbSendOut(index,pokemon)
    pbSetSeen(pokemon)
    @peer.pbOnEnteringBattle(self,pokemon)
    #if !pbIsOpposing?(index)
    #  $illusionpoke = @party1[@party1.length-1] if isConst?(pokemon.ability,PBAbilities,:ILLUSION)
    #end
    if pbIsOpposing?(index)
      #$illusionpoke = @party2[@party2.length-1] if isConst?(pokemon.ability,PBAbilities,:ILLUSION)
      @scene.pbTrainerSendOut(index,pokemon,false)

      # Last Pokemon script; credits to venom12 and HelioAU
      if pbPokemonCount(@party2)==1
        # Define any trainers that you want to activate this script below
=begin
        if (@opponent.name.to_s == _INTL("Orion") ||
          @opponent.name.to_s == _INTL("Xavier")) ||
          @opponent.name.to_s == _INTL("East")) ||
          @opponent.name.to_s == _INTL("Harmony")) ||
          @opponent.name.to_s == _INTL("Anastasia")) ||
          @opponent.name.to_s == _INTL("Diana"))  ||
          @opponent.name.to_s == _INTL("Calreath")) ||
          @opponent.name.to_s == _INTL("Adam")) ||
          @opponent.name.to_s == _INTL("Kayla")) ||
          @opponent.name.to_s == _INTL("London")) ||
          @opponent.name.to_s == _INTL("Reukra")) ||
          @opponent.name.to_s == _INTL("Yuki")) ||
          @opponent.name.to_s == _INTL("Persephone")) ||
          @opponent.name.to_s == _INTL("Zenith")) ||
          @opponent.name.to_s == _INTL("Audrey")) ||
          @opponent.name.to_s == _INTL("Taen")) ||
          @opponent.name.to_s == _INTL("Malde"))
          @scene.pbShowOpponent(0)
          if @opponent.name.to_s == _INTL("Devon")
            pbDisplayPaused(_INTL("I've almost lost! It's time to turn it around!"))
          end
          if @opponent.name.to_s == _INTL("Aria")
            pbDisplayPaused(_INTL("The final challenge! If you defeat this, you will surpass even me!"))
          end
          # For each defined trainer, add the ABOVE section for them
          @scene.pbHideOpponent
        end
=end
      end
    else
      @scene.pbSendOut(index,pokemon,false)
    end
  end

  def pbReplace(index,newpoke,batonpass=false)
    party=pbParty(index)
    oldpoke=@battlers[index].pokemonIndex
    #if @battlers[index].species==PBSpecies::KYOGRE && @battlers[index].item==PBItems::BLUEORB #&& party[newpoke].ability!=PBAbilities::PRIMORDIALSEA
    #  @primordialsea=false
    #  @weather=0
    #    pbDisplayBrief("The heavy rain relented.",!$is_insane)
    #end
    #if @battlers[index].species==PBSpecies::GROUDON && @battlers[index].item==PBItems::REDORB #&& party[newpoke].ability!=PBAbilities::DESOLATELAND
    #  @desolateland=false
    # @weather=0
    #   pbDisplayBrief("The harsh sunlight faded.",!$is_insane)
    # end
    #  if @battlers[index].ability==PBSpecies::RAYQUAZA && @battlers[index].form>0 #&& party[newpoke].ability!=PBAbilities::DELTASTREAM
    #  @deltastream=false
    #    pbDisplayBrief("The air current faded.",!$is_insane)
    #end
    if pbOwnedByPlayer?(index)
      #@battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      # Reorder the party for this battle
      partyorder=(!pbIsOpposing?(index)) ? @party1order : @party2order
      bpo=-1; bpn=-1
      for i in 0...partyorder.length
        bpo=i if partyorder[i]==oldpoke
        bpn=i if partyorder[i]==newpoke
      end
      p=partyorder[bpo]; partyorder[bpo]=partyorder[bpn]; partyorder[bpn]=p
      # Reinitialize to reorder the party before sending out the next Pokemon (mainly for Illusion)
      @battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      pbSendOut(index,party[newpoke])
    else
      #@battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      pbSetSeen(party[newpoke])
      # Reorder the party for this battle
      partyorder=(!pbIsOpposing?(index)) ? @party1order : @party2order
      bpo=-1; bpn=-1
      for i in 0...partyorder.length
        bpo=i if partyorder[i]==oldpoke
        bpn=i if partyorder[i]==newpoke
      end
      p=partyorder[bpo]; partyorder[bpo]=partyorder[bpn]; partyorder[bpn]=p
      # Reinitialize to reorder the party before sending out the next Pokemon (mainly for Illusion)
      @battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      if pbIsOpposing?(index)
        pbSendOut(index,party[newpoke])
      else
        pbSendOut(index,party[newpoke])
      end
    end
  end

  def pbSwitchPlayer(index,lax,cancancel)
    if @debug
      return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      return @scene.pbSwitch(index,lax,cancancel)
    end
  end

  def pbDebugUpdate
  end

  def pbDisplayPaused(msg)
   # if $is_insane
      @scene.pbDisplayPausedMessage(msg) 
   # else
   #   @scene.pbDisplayMessage(msg) 
   # end
    
  end

  def pbDisplay(msg)
    @scene.pbDisplayMessage(msg)
  end

  def pbDisplayBrief(msg,danger=true)
# ---
    @scene.pbDisplayMessage(msg,true) if !danger
    @scene.pbDisplayMessage(msg,!$is_insane) if danger
  # ---
 #   @scene.pbDisplayMessage(msg,true)
  end

  def pbShowCommands(msg,commands,cancancel=true)
    @scene.pbShowCommands(msg,commands,cancancel)
  end

  def pbDisplayConfirm(msg)
    @scene.pbDisplayConfirmMessage(msg)
  end

  def pbCommonAnimation(name,attacker,opponent,side=true)
    if @battlescene
      @scene.pbCommonAnimation(name,attacker,opponent,side)
    end
  end

  def pbAnimation(move,attacker,opponent,side=true,delta=nil)
    if @battlescene
      @scene.pbAnimation(move,attacker,opponent,side,delta)
    end
  end

  def pbAutoFightMenu(i)
    return false
  end

  def pbItemMenu(i)
    return @scene.pbItemMenu(i)
  end
  def deleteSpriteAt(i)
      @scene.sprites["pokemon#{i}"].dispose
  end
  
  def pbCommandMenu(i)
    return @scene.pbCommandMenu(i)
  end

  def pbDefaultChooseEnemyCommand(index)
    i = index
    #    if Kernel.pbGetMegaSpeciesList.(@battlers[i].species) && Kernel.pbGetMegaStoneList.include?(@battlers[i].item)
    #          if Kernel.pbGetMegaStoneList.index(@battlers[i].item)==Kernel.pbGetMegaSpeciesList.index(@battlers[i].species)
    canMega3=true if Kernel.pbGetMegaSpeciesStoneWorks(@battlers[i].pokemon.species,@battlers[i].item)
    #          end
    #        end
    if @battlers[i].species==PBSpecies::RAYQUAZA
      rayq=false
      canMega3=true if @battlers[i].moves[0].id==PBMoves::DRAGONSASCENT
      canMega3=true if @battlers[i].moves[1].id==PBMoves::DRAGONSASCENT
      canMega3=true if @battlers[i].moves[2].id==PBMoves::DRAGONSASCENT
      canMega3=true if @battlers[i].moves[3].id==PBMoves::DRAGONSASCENT
    end
    if @opponent && !pbGetOwner(i).megaforme && canMega3 && @battlers[i].form==0
       pbMegaEvolve(i)
    end
    if !pbCanShowFightMenuEnemy?(index)
      return if pbEnemyShouldUseItem?(index) && !(@battlers[index].effects[PBEffects::Embargo]>0)
      return if pbEnemyShouldWithdraw?(index)
      pbAutoChooseMoveEnemy(index)
      return
    else
      return if pbEnemyShouldUseItem?(index)  && !(@battlers[index].effects[PBEffects::Embargo]>0)
      return if pbEnemyShouldWithdraw?(index)
      return if pbAutoFightMenu(index)
      pbChooseMoves(index)
    end
  end

  def pbCommandPhase
    pbCommandPhaseCore
  end

  def pbCommandPhaseCore
    @scene.pbBeginCommandPhase
    for i in 0..3 # Reset choices if commands can be shown
      @battlers[i].effects[PBEffects::SkipTurn]=false
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
 #   @megaEvolution[0][0]=-1# if @megaEvolution[0][0]>=0
 #   @megaEvolution[0][1]=-1 if @megaEvolution[0][1]>=0
 #   @megaEvolution[0][2]=-1 if @megaEvolution[0][2]>=0
 #   @megaEvolution[0][3]=-1 if @megaEvolution[0][3]>=0

 #       @megaEvolution[1][0]=-1# if @megaEvolution[1][0]>=0
  #  @megaEvolution[1][1]=-1 if @megaEvolution[1][1]>=0
  #  @megaEvolution[1][2]=-1 if @megaEvolution[1][2]>=0
  #  @megaEvolution[1][3]=-1 if @megaEvolution[1][3]>=0

    #for i in 0...@megaEvolution[0].length
    #  @megaEvolution[0][i]=-1 if @megaEvolution[0][i]>=0
    #end
    #for i in 0...@megaEvolution[1].length
    #  @megaEvolution[1][i]=-1 if @megaEvolution[1][i]>=0
    #end

    for i in 0..3
      break if @decision!=0
      next if @choices[i][0]!=0
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
                      target=@scene.pbChooseTarget(i,target)
                      next if target<0
                      pbRegisterTarget(i,target)
                    elsif target==PBTargets::UserOrPartner # Acupressure
                      target=@scene.pbChooseTarget(i,target)
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
            elsif cmd==1 # Pokémon
              pkmn=pbSwitchPlayer(i,false,true)
              if pkmn>=0
                commandDone=true if pbRegisterSwitch(i,pkmn)
              end
            elsif cmd==2 # Bag
              
#                  return if [695,696,693,700,701,694,698].include?($game_map.map_id)
              if !@internalbattle || $game_switches[340] || eliteFourDifficulty(true)
                if [695,696,693,700,701,694,698].include?($game_map.map_id) || pbOwnedByPlayer?(i)
                  pbDisplay(_INTL("Items can't be used here."))
#                  pbDisplay(_INTL("Items can't be used here2.")) if $game_switches[340]
                end
              else
                item=pbItemMenu(i)
                if pbIsPokeBall?(item[0]) && !@opponent && @party2.length!=1 && @party2[0].hp>0 && @party2[1].hp>0#&& $game_switches[359]
                  pbDisplay(_INTL("It's too difficult to aim a ball when there are two Pokemon!"))
                elsif item[0]>0
                  if pbRegisterItem(i,item[0],item[1])
                    pbAutoChooseMove(i) if $idbox && $idbox != nil
                    #  $idbox=nil
                    commandDone=true
                  end
                end
              end
            elsif cmd==3 # Run
              run=pbRun(i) 
              if run > 0
                commandDone=true
                return
              elsif run < 0
                commandDone=true
         #                       side=(pbIsOpposing?(i)) ? 1 : 0
         #       owner=pbGetOwnerIndex(i)
             #   if @megaEvolution[side][owner]==i
             #     @megaEvolution[side][owner]=-1
             #   end
              $mega_battlers[i]=false
              end
            elsif cmd==4 # Call
              thispkmn=@battlers[i]
              @choices[i][0]=4 # call
              @choices[i][1]=0 
              @choices[i][2]=nil
                            side=(pbIsOpposing?(i)) ? 1 : 0
              owner=pbGetOwnerIndex(i)

             #               if @megaEvolution[side][owner]==i
             #   @megaEvolution[side][owner]=-1
             # end
              $mega_battlers[i]=false

              commandDone=true
            elsif cmd==-1 # Go back to first battler's choice
          #                  @megaEvolution[0][0]=-1 if @megaEvolution[0][0]>=0
           #   @megaEvolution[1][0]=-1 if @megaEvolution[1][0]>=0
              $mega_battlers[i]=false

              pbCommandPhaseCore
              return
            end
            break if commandDone
          end # end command loop
        end # end CanShowCommands
      end
    end
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

  def pbAttackPhase
    @aimove=false
    @scene.pbBeginAttackPhase
    for i in 0..3
      @successStates[i].clear
    end
    for i in 0..3
      if @choices[i][0]==4
        pbCall(i)
      end
      if @choices[i][0]!=1 && choices[i][0]!=2
        @battlers[i].effects[PBEffects::DestinyBond]=false
        @battlers[i].effects[PBEffects::Grudge]=false
      end
    end

    for i in 0..3
      if pbIsOpposing?(i) && @choices[i][0]==3
        pbEnemyUseItem(@choices[i][1],@battlers[i])
      end
    end
    for i in 0..3
      if @battlers[i].hp>0
        @battlers[i].turncount+=1
      end
    end
    for i in 0..3
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
    
    for i in 0..3 # in order from own first, opposing first, own second, opposing second
      if @choices[i][0]==2 && !@battlers[i].effects[PBEffects::SkipTurn] &&
        index=@choices[i][1] # party position of Pokémon to switch to
        newpokename=index
        if isConst?(pbParty(i)[index].ability,PBAbilities,:ILLUSION)
          if index==pbGetLastPokeInTeam(i)
            newpokename=@battlers[i].pokemonIndex
          else
            newpokename=pbGetLastPokeInTeam(i)
          end
        end
        self.lastMoveUser=i
        if !@battlers[i].effects[PBEffects::SkyDrop] && 
           !@battlers[i].effects[PBEffects::SpiritAway]
          if !pbOwnedByPlayer?(i)
            owner=pbGetOwner(i)
            pbDisplayBrief(_INTL("{1} withdrew {2}!",owner.fullname,battlers[i].name))
          else
            pbDisplayBrief(_INTL("{1}, that's enough!\r\nCome back!",battlers[i].name))
          end
        end
        for j in [3,2,1,0] # in reverse order
          next if !@battlers[i].pbIsOpposing?(j)
          # if Pursuit and this target ("i") was chosen
          if pbChoseMove?(j,:PURSUIT) && (@choices[j][3]==-1 || @choices[j][3]==i)
            if @battlers[j].status!=PBStatuses::SLEEP &&
               @battlers[j].status!=PBStatuses::FROZEN &&
               (!@battlers[j].hasWorkingAbility(:TRUANT) || !@battlers[j].effects[PBEffects::Truant]) &&
               !@battlers[i].effects[PBEffects::SkyDrop] && 
               !@battlers[i].effects[PBEffects::SpiritAway]
              @battlers[j].pbUseMove(@choices[j])
              @battlers[j].effects[PBEffects::Pursuit]=true
              #UseMove calls pbGainEXP as appropriate
              @switching=false
              return if @decision>0
            end
          end
          break if @battlers[i].hp<=0
        end
        if !@battlers[i].effects[PBEffects::SkyDrop] && 
           !@battlers[i].effects[PBEffects::SpiritAway]
          if !pbRecallAndReplace(i,index,false,newpokename)
            # If a forced switch somehow occurs here in single battles
            # the attack phase now ends
            if !@doublebattle
              @switching=false
              return
            end
          else
            switched.push(i)
          end
        else
          @switching=false
          #return
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
    @usepriority=false  # recalculate priority
    priority=pbPriority
    for i in priority
      next if @choices[i.index][0]!=1
      #    side=(pbIsOpposing?(i.index)) ? 1 : 0
      #    owner=pbGetOwnerIndex(i.index)
      $tempDoubleMega=nil
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
    # Use attacks
    for i in priority
      next if i.effects[PBEffects::SkipTurn]
      if pbChoseMoveFunctionCode?(i.index,0x115) && # Focus Punch
               (!i.hasWorkingAbility(:TRUANT) || !i.effects[PBEffects::Truant]) 
        pbCommonAnimation("FocusPunch",i,nil)
        pbDisplay(_INTL("{1} is tightening its focus!",i.pbThis))
      end
    end
    10.times do
      # Forced to go next
      advance=false
      for i in priority
        next if !i.effects[PBEffects::MoveNext]
        next if i.hasMovedThisRound? || i.effects[PBEffects::SkipTurn]
        pbJudge()
        return if @decision>0
        advance=i.pbProcessTurn(@choices[i.index])
        break if advance
      end
      return if @decision>0
      next if advance
      # Regular priority order
      for i in priority
        next if i.effects[PBEffects::Quash]
        next if i.hasMovedThisRound? || i.effects[PBEffects::SkipTurn]
        pbJudge()
        return if @decision>0
        advance=i.pbProcessTurn(@choices[i.index])
        break if advance
      end
      return if @decision>0
      next if advance
      # Quashed
      for i in priority
        next if !i.effects[PBEffects::Quash]
        next if i.hasMovedThisRound? || i.effects[PBEffects::SkipTurn]
        pbJudge()
        return if @decision>0
        advance=i.pbProcessTurn(@choices[i.index])
        break if advance
      end
      return if @decision>0
      next if advance
      # Check for all done
      for i in priority
        advance=true if @choices[i.index][0]==1 && !i.hasMovedThisRound? &&
                        !i.effects[PBEffects::SkipTurn]
        break if advance
      end
      next if advance
      break
    end
    # calculate priority at this time
    #   @usepriority=false  # recalculate priority
    #   priority=pbPriority
    #for i in priority
    #  i.pbProcessTurn(@choices[i.index])
    #  return if @decision>0
    #end
    
    for i in priority
      # Kernel.pbMessage(i.ability.to_s)
      if i.hp>0  && i.ability==PBAbilities::LERNEAN && !i.effects[PBEffects::GastroAcid]
        #   Kernel.pbMessage((100*i.hp/i.totalhp).to_s)
        if (100*i.hp)/i.totalhp <= 20 && i.form<5 #20%, 9 heads 
          #i.form=5
          i.pokemon.form=5
          #Kernel.pbMessage("Lernean increased the number of heads! 9")
        elsif (100*i.hp)/i.totalhp <= 40 && i.form<4 #40%, 8 heads 
          #  i.form=4
          i.pokemon.form=4
          # Kernel.pbMessage("Lernean increased the number of heads! 8")
        elsif (100*i.hp)/i.totalhp <= 60 && i.form<3 #60%, 7 heads
          # i.form=3
          i.pokemon.form=3
          #  Kernel.pbMessage("Lernean increased the number of heads! 7")
        elsif (100*i.hp)/i.totalhp <= 80 && i.form<2 #80%, 6 heads
          #  i.form=2
          i.pokemon.form=2
          #   Kernel.pbMessage("Lernean increased the number of heads! 6")
        else
          #i.form=1
        end
        i.pbCheckForm
      end
      # Burst Mode
      for move in i.moves
        if move.isBurstAttack? && i.effects[PBEffects::SynergyBurstDamage] >= 0.5#i.totalhp/2
          i.effects[PBEffects::BurstMode]=true
          i.effects[PBEffects::SynergyBurst]=6
          i.effects[PBEffects::SynergyBurstDamage]=0
          if move.function==0x216
            i.effects[PBEffects::AuraBlastCharges]=1
          end
          Kernel.pbMessage(_INTL("The accumulated damage activated {1}'s Burst Mode!",i.pbThis))
          if i.hp<i.totalhp
            @scene.pbRefresh
            i.pbRecoverHP((i.totalhp/8).floor)
            pbDisplay(_INTL("{1} recovered a little of its HP from Synergy Burst!",i.pbThis))
          end
        end
      end
    end
    
    #pbSwitch #WhereShould
    pbWait(20) if !$is_insane
  end
  
  def pbEndOfRoundPhase
    pbJudge()
    if @decision > 0
      pbSwitch
    end
    for i in 0..3
      @battlers[i].effects[PBEffects::Electrify]=false
      @battlers[i].effects[PBEffects::Protect]=false
      @battlers[i].effects[PBEffects::KingsShield]=false
      @battlers[i].effects[PBEffects::MoveNext]=false
      @battlers[i].effects[PBEffects::SpikyShield]=false
      @battlers[i].effects[PBEffects::ProtectNegation]=false
      @battlers[i].effects[PBEffects::Quash]=false
      @battlers[i].effects[PBEffects::Powder]=false
      @battlers[i].effects[PBEffects::Endure]=false
      @battlers[i].effects[PBEffects::FirstPledge]=0
      @battlers[i].effects[PBEffects::HyperBeam]-=1 if @battlers[i].effects[PBEffects::HyperBeam]>0
    end
    @usepriority=false  # recalculate priority
    priority=pbPriority(true)

    # Weather statements
    case @weather
      when PBWeather::SUNNYDAY
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sunlight faded."))
          @weather=0
          @scene.pbBackdropMove(0,true,true)
          @scene.pbRefresh
        else
          @scene.pbMoveAnimation("Sunny",nil,nil)
          @scene.pbRefresh
          pbDisplay(_INTL("The sunlight is strong."));
        end
      when PBWeather::RAINDANCE
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The rain stopped."))
          @weather=0
          @scene.pbBackdropMove(0,true,true)
          @scene.pbRefresh
        else
          @scene.pbMoveAnimation("Rain",nil,nil)
          @scene.pbRefresh
          pbDisplay(_INTL("Rain continues to fall."));
        end
      when PBWeather::NEWMOON
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sky brightened again."))
          @weather=0
          @scene.pbBackdropMove(0,true,true)
          @scene.pbRefresh
        else
          @scene.pbMoveAnimation("NewMoon",nil,nil)
          @scene.pbRefresh
          pbDisplay(_INTL("The sky is dark."));
        end
      when PBWeather::SANDSTORM
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The sandstorm subsided."))
          @weather=0
          @scene.pbBackdropMove(0,true,true)
          @scene.pbRefresh
        else
          @scene.pbMoveAnimation("Sandstorm",nil,nil)
          @scene.pbRefresh
          pbDisplay(_INTL("The sandstorm rages."));
        end
      when PBWeather::HAIL
        @weatherduration=@weatherduration-1 if @weatherduration>0
        if @weatherduration==0
          pbDisplay(_INTL("The hail stopped."))
          @weather=0
          @scene.pbBackdropMove(0,true,true)
          @scene.pbRefresh
        else
          @scene.pbMoveAnimation("Hail",nil,nil)
          @scene.pbRefresh
          pbDisplay(_INTL("Hail continues to fall."));
        end
      when PBWeather::HEAVYRAIN
        hasabil=false
        for i in 0...4
          if @battlers[i].hasWorkingAbility(:PRIMORDIALSEA) && !@battlers[i].fainted?
            hasabil=true; break
          end
        end
        @weatherduration=0 if !hasabil
        if @weatherduration==0
          pbDisplay(_INTL("The heavy rain stopped."))
          @weather=0
          @scene.pbBackdropMove(0,true,true)
          @scene.pbRefresh
        else
          @scene.pbMoveAnimation("HeavyRain",nil,nil)
          @scene.pbRefresh
          pbDisplay(_INTL("It is raining heavily."))
        end
      when PBWeather::HARSHSUN
        hasabil=false
        for i in 0...4
          if @battlers[i].hasWorkingAbility(:DESOLATELAND) && !@battlers[i].fainted?
            hasabil=true; break
          end
        end
        @weatherduration=0 if !hasabil
        if @weatherduration==0
          pbDisplay(_INTL("The harsh sunlight faded."))
          @weather=0
          @scene.pbBackdropMove(0,true,true)
          @scene.pbRefresh
        else
          @scene.pbMoveAnimation("HarshSun",nil,nil)
          @scene.pbRefresh
          pbDisplay(_INTL("The sunlight is extremely harsh."))
        end
      when PBWeather::STRONGWINDS
        hasabil=false
        for i in 0...4
          if @battlers[i].hasWorkingAbility(:DELTASTREAM) && !@battlers[i].fainted?
            hasabil=true; break
          end
        end
        @weatherduration=0 if !hasabil
        if @weatherduration==0
          pbDisplay(_INTL("The air current subsided."))
          @weather=0
          @scene.pbBackdropMove(0,true,true)
          @scene.pbRefresh
        else
          @scene.pbMoveAnimation("StrongWinds",nil,nil)
          @scene.pbRefresh
          pbDisplay(_INTL("The wind is strong."))
        end
      end
    
    # Shadow Sky weather
    if isConst?(@weather,PBWeather,:SHADOWSKY)
      @weatherduration=@weatherduration-1 if @weatherduration>0
      if @weatherduration==0
        pbDisplay(_INTL("The shadow sky faded."))
        @weather=0
        @scene.pbBackdropMove(0,true,true)
        @scene.pbRefresh
     else
        @scene.pbMoveAnimation("ShadowSky",nil,nil)
        pbDisplay(_INTL("The shadow sky continues."));
        if isConst?(pbWeather,PBWeather,:SHADOWSKY)
          for i in priority
            next if i.hp<=0
            if !i.pokemon.isShadow? &&
              !i.hasWorkingAbility(:MAGICGUARD)
              pbDisplay(_INTL("{1} was hurt by the shadow sky.",i.pbThis))
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP(i.totalhp/16)
              if i.hp<=0
                return if !i.pbFaint
              end
            end
          end
        end
      end
    end
    for i in priority
      next if i.hp<=0
      # Solar Power
      if (pbWeather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN) &&
         i.hasWorkingAbility(:SOLARPOWER)
        pbDisplay(_INTL("{1} was hurt by the sunlight!",i.pbThis))
        @scene.pbDamageAnimation(i,0)
        i.pbReduceHP((i.totalhp/8).floor)
      end
      # Absolution
      if pbWeather==PBWeather::NEWMOON && i.hasWorkingAbility(:ABSOLUTION)
        pbDisplay(_INTL("{1} was hurt by the fog!",i.pbThis))
        @scene.pbDamageAnimation(i,0)
        i.pbReduceHP((i.totalhp/8).floor)
      end
      # Rain Dish
      if (pbWeather==PBWeather::RAINDANCE || pbWeather==PBWeather::HEAVYRAIN) && 
        i.hasWorkingAbility(:RAINDISH) && i.effects[PBEffects::HealBlock]==0
        hpgain=i.pbRecoverHP((i.totalhp/16).floor)
        pbDisplay(_INTL("{1}'s {2} restored its HP a little!",i.pbThis,PBAbilities.getName(i.ability))) if hpgain>0
      end
      # Phototroph
      if i.hasWorkingAbility(:PHOTOTROPH) && i.effects[PBEffects::HealBlock]==0
        if (pbWeather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN) 
          hpgain=i.pbRecoverHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s {2} restored its HP!",i.pbThis,PBAbilities.getName(i.ability))) if hpgain>0
        elsif (pbWeather==PBWeather::HEAVYRAIN || pbWeather==PBWeather::NEWMOON)
          pbDisplay(_INTL("{1} couldn't restore its HP due to the lack of light!",i.pbThis))
        else
          hpgain=i.pbRecoverHP((i.totalhp/16).floor)
          pbDisplay(_INTL("{1}'s {2} restored its HP a little!",i.pbThis,PBAbilities.getName(i.ability))) if hpgain>0
        end
      end
      # Dry Skin
      if i.hasWorkingAbility(:DRYSKIN)
        if (@weather==PBWeather::RAINDANCE || pbWeather==PBWeather::HEAVYRAIN) &&
          i.effects[PBEffects::HealBlock]==0
          hpgain=i.pbRecoverHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s {2} was healed by the rain!",i.pbThis,PBAbilities.getName(i.ability))) if hpgain>0
        elsif (@weather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN)
          hploss=i.pbReduceHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s {2} was hurt by the sunlight!",i.pbThis,PBAbilities.getName(i.ability))) if hploss>0
        end
      end
      # Heliophobia
      if i.hasWorkingAbility(:HELIOPHOBIA)
        if @weather==PBWeather::NEWMOON && i.effects[PBEffects::HealBlock]==0
          hpgain=i.pbRecoverHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s {2} was healed by the darkness!",i.pbThis,PBAbilities.getName(i.ability))) if hpgain >0
        elsif (@weather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN)
          hploss=i.pbReduceHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s {2} was hurt by the sunlight!",i.pbThis,PBAbilities.getName(i.ability))) if hploss>0
        end
      end
      # Damage from Sandstorm
      if pbWeather==PBWeather::SANDSTORM
        if !i.hasWorkingAbility(:SANDVEIL) &&
           !i.hasWorkingAbility(:SANDRUSH) &&
           !i.hasWorkingAbility(:SANDFORCE) &&
           !i.hasWorkingAbility(:OVERCOAT) &&
           !i.hasWorkingAbility(:MAGICGUARD) &&
           !i.hasWorkingAbility(:SANDSTREAM) &&
           !i.hasWorkingAbility(:OMNITYPE) &&
           !i.hasWorkingItem(:SAFETYGOGGLES) &&
           !i.pbHasType?(:GROUND) && !i.pbHasType?(:ROCK) && !i.pbHasType?(:STEEL) &&
           !isConst?(i.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) &&
           !isConst?(i.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
          pbDisplay(_INTL("{1} was buffeted by the sandstorm!",i.pbThis))
          @scene.pbDamageAnimation(i,0)
          i.pbReduceHP((i.totalhp/16).floor)
        end
      end
      if pbWeather==PBWeather::HAIL
        # Damage from Hail/Sleet
        if !i.pbHasType?(:ICE) &&
           !i.hasWorkingAbility(:ICEBODY) &&
           !i.hasWorkingAbility(:SNOWCLOAK) &&
           !i.hasWorkingAbility(:ICECLEATS) &&
           !i.hasWorkingAbility(:MAGICGUARD) &&
           !i.hasWorkingAbility(:SNOWWARNING) &&
           !i.hasWorkingAbility(:SLEET) &&
           !i.hasWorkingItem(:SAFETYGOGGLES) &&
           !i.hasWorkingAbility(:OVERCOAT) &&
           !i.hasWorkingAbility(:OMNITYPE) &&
           !isConst?(i.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) &&
           !isConst?(i.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
          sleetExists=false
          for j in priority
            if j.ability==PBAbilities::SLEET && !j.effects[PBEffects::GastroAcid]
              sleetExists=true
            end
          end
          pbDisplay(_INTL("{1} was pelted by hail!",i.pbThis)) if !sleetExists
          pbDisplay(_INTL("{1} was bombarded by the heavy sleet!",i.pbThis)) if sleetExists
          @scene.pbDamageAnimation(i,0)
          i.pbReduceHP((i.totalhp/16).floor) if !sleetExists
          i.pbReduceHP((i.totalhp/5).floor) if sleetExists
        # Ice Body
        elsif i.hasWorkingAbility(:ICEBODY) && i.effects[PBEffects::HealBlock]==0
          hpgain=i.pbRecoverHP((i.totalhp/16).floor)
          pbDisplay(_INTL("{1}'s {2} restored its HP a little!",i.pbThis,PBAbilities.getName(i.ability))) if hpgain>0
        end
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Future Sight/Doom Desire
    for i in priority   # not priority
      #next if i.hp<=0
      if i.effects[PBEffects::FutureSight]>0
        i.effects[PBEffects::FutureSight]-=1
        if i.effects[PBEffects::FutureSight]==0
          move=i.effects[PBEffects::FutureSightMove]
          moveuser=nil
          if i.hp>0
            #move=PokeBattle_Move.pbFromPBMove(self,PBMove.new(i.effects[PBEffects::FutureSightMove]))
            pbDisplay(_INTL("{1} took the {2} attack!",i.pbThis,PBMoves.getName(move)))
            #pbDisplay(_INTL("{1} took the {2} attack!",i.pbThis,move.name))
            for j in @battlers
              next if j.pbIsOpposing?(i.effects[PBEffects::FutureSightUserPos])
              if j.pokemonIndex==i.effects[PBEffects::FutureSightUser] && !j.fainted?
                moveuser=j; break
              end
            end
            if !moveuser
              party=pbParty(i.effects[PBEffects::FutureSightUserPos])
              #if party[i.effects[PBEffects::FutureSightUser]].hp>0
                moveuser=PokeBattle_Battler.new(self,i.effects[PBEffects::FutureSightUserPos])
                moveuser.pbInitDummyPokemon(party[i.effects[PBEffects::FutureSightUser]],
                                            i.effects[PBEffects::FutureSightUser])
                #moveuser.effects[PBEffects::TwoTurnAttack]=0
              #end
            end
            if !moveuser
              pbDisplay(_INTL("But it failed!"))
            else
              @futuresight=true
              moveuser.pbUseMoveSimple(move,-1,i.index)
              @futuresight=false
            end
          end
          #moveuser=@battlers[i.effects[PBEffects::FutureSightUser]]
          #if (i.hp<=0 || move.pbAccuracyCheck(moveuser,i)) && 
          #   !(isConst?(move.id,PBMoves,:FUTURESIGHT) && i.pbHasType?(PBTypes::DARK)) 
          #  damage=i.effects[PBEffects::FutureSightDamage].floor
          #  #damage=((i.effects[PBEffects::FutureSightDamage]*85)/100).floor
          #  damage=1 if damage<1
          #  i.damagestate.reset
          #  move.pbReduceHPDamage(damage,nil,i)
          #else
          #  pbDisplay(_INTL("But it failed!"))
          #end
          if !i.effects[PBEffects::FutureSightLoop]
            i.effects[PBEffects::FutureSight]=0
            i.effects[PBEffects::FutureSightMove]=0
            #i.effects[PBEffects::FutureSightDamage]=0
            i.effects[PBEffects::FutureSightUser]=-1
            i.effects[PBEffects::FutureSightUserPos]=-1
          else
            i.effects[PBEffects::FutureSightLoop]=false
            i.effects[PBEffects::FutureSight]=3
          end
          if i.fainted?
            return if !i.pbFaint
            next
          end
        end
      end
    end
    # Wish
    for i in priority
      #next if i.hp<=0
      if i.effects[PBEffects::Wish]>0
        i.effects[PBEffects::Wish]-=1
        if i.effects[PBEffects::Wish]==0 && i.hp>0 && i.effects[PBEffects::HealBlock]==0
          wishmaker=pbThisEx(i.index,i.effects[PBEffects::WishMaker])
          pbDisplay(_INTL("{1}'s Wish came true!",wishmaker))
          hpgain=i.pbRecoverHP(i.effects[PBEffects::WishAmount])
          if hpgain==0
            pbDisplay(_INTL("{1}'s HP is full!",i.pbThis))
          else
            pbDisplay(_INTL("{1} regained health!",i.pbThis))
          end
          if !i.effects[PBEffects::WishLoop]
            i.effects[PBEffects::Wish]=0
          else
            i.effects[PBEffects::WishLoop]=false
            i.effects[PBEffects::Wish]=2
          end
        end
      end
    end
    # Block A
    for i in priority
      next if i.fainted?
      # Vaporization
      vaccine=false
      for j in @battlers
        vaccine=true if j.ability==PBAbilities::VAPORIZATION && !j.effects[PBEffects::GastroAcid]
      end
      if vaccine && (i.hasWorkingAbility(:DRYSKIN) || i.pbHasType?(PBTypes::WATER))
        hploss=i.pbReduceHP((i.totalhp/8).floor)
        pbDisplay(_INTL("{1} was vaporized!",i.pbThis)) if hploss>0
      end
      if i.fainted?
        return if !i.pbFaint
        next
      end
      # Fire Pledge + Grass Pledge combination damage
      for j in 0...2
        if sides[j].effects[PBEffects::SeaOfFire]>0 &&
          pbWeather!=PBWeather::RAINDANCE && pbWeather!=PBWeather::HEAVYRAIN
          #for i in priority
          next if (i.index&1)!=j
          next if i.pbHasType?(:FIRE) || i.hasWorkingAbility(:MAGICGUARD)
          @scene.pbDamageAnimation(i,0)
          hploss=i.pbReduceHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1} is hurt by the sea of fire!",i.pbThis)) if hploss>0
          if i.fainted?
            return if !i.pbFaint
            next
          end
          #end
        end
      end
      # Grassy Terrain (healing)
      if @field.effects[PBEffects::GrassyTerrain]>0 && !i.isAirborne? &&
         !i.isInvulnerable?
        if i.effects[PBEffects::HealBlock]==0
          hpgain=i.pbRecoverHP((i.totalhp/16).floor)
          pbDisplay(_INTL("{1}'s HP was restored.",i.pbThis)) if hpgain>0
        end
      end
      # Shed Skin
      if i.hasWorkingAbility(:SHEDSKIN)
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
      if i.hasWorkingAbility(:HYDRATION) && (pbWeather==PBWeather::RAINDANCE ||
                                                        pbWeather==PBWeather::HEAVYRAIN)
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
      # Leftovers
      if i.hasWorkingItem(:LEFTOVERS) && i.hp!=i.totalhp && i.effects[PBEffects::HealBlock]==0
        i.pbRecoverHP((i.totalhp/16).floor)
        pbDisplay(_INTL("{1}'s {2} restored its HP a little!",i.pbThis,PBItems.getName(i.item)))
      end
      # Black Sludge
      if i.hasWorkingItem(:BLACKSLUDGE)
        if i.pbHasType?(:POISON) 
          if i.hp!=i.totalhp && i.effects[PBEffects::HealBlock]==0
            i.pbRecoverHP((i.totalhp/16).floor)
            pbDisplay(_INTL("{1}'s {2} restored its HP a little!",i.pbThis,PBItems.getName(i.item)))
          end
        elsif !i.hasWorkingAbility(:MAGICGUARD)
          i.pbReduceHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1} was hurt by its {2}!",i.pbThis,PBItems.getName(i.item)))
        end
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
      # Healer
      if i.hasWorkingAbility(:HEALER)
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
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    for i in priority
      next if i.hp<=0
      i.pbCheckForm if i.species==PBSpecies::ZYGARDE
    end
    # Aqua Ring
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::AquaRing] && i.effects[PBEffects::HealBlock]==0
        hpgain=i.totalhp/16
        hpgain*=1.3 if i.hasWorkingItem(:BIGROOT)
        hpgain=i.pbRecoverHP(hpgain)
        pbDisplay(_INTL("{1}'s Aqua Ring restored its HP a little!",i.pbThis)) if hpgain>0
      end
    end
    # Ingrain
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Ingrain] && i.effects[PBEffects::HealBlock]==0
        hpgain=i.totalhp/16
        hpgain*=1.3 if i.hasWorkingItem(:BIGROOT)
        hpgain=i.pbRecoverHP(hpgain)
        pbDisplay(_INTL("{1} absorbed nutrients with its roots!",i.pbThis)) if hpgain>0
      end
    end
    # Leech Seed
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::LeechSeed]>=0 && !i.hasWorkingAbility(:MAGICGUARD)
        recipient=@battlers[i.effects[PBEffects::LeechSeed]]
        if recipient.hp>0 # if recipient exists
          pbCommonAnimation("Leech Seed",recipient,i) if !i.isInvulnerable?
          hploss=i.pbReduceHP((i.totalhp/8).floor)
          if i.hasWorkingAbility(:LIQUIDOOZE)
            recipient.pbReduceHP(hploss)
            pbDisplay(_INTL("{1} sucked up the liquid ooze!",recipient.pbThis))
          elsif recipient.effects[PBEffects::HealBlock]==0
            hploss*=1.3 if recipient.hasWorkingItem(:BIGROOT)
            recipient.pbRecoverHP(hploss)
            pbDisplay(_INTL("{1}'s health is sapped by Leech Seed!",i.pbThis))
          end
          i.pbFaint if i.hp<=0
          recipient.pbFaint if recipient.hp<=0
          if i.fainted?
            return if !i.pbFaint
          end
          if recipient.fainted?
            return if !recipient.pbFaint
          end
        end
      end
    end
    # Poison/Bad poison
    for i in priority
      next if i.hp<=0
      if i.status==PBStatuses::POISON
        if i.hasWorkingAbility(:MAGICGUARD)
        elsif i.hasWorkingAbility(:POISONHEAL) 
          if i.effects[PBEffects::HealBlock]==0 && i.hp<i.totalhp
            pbDisplay(_INTL("{1} is healed by poison!",i.pbThis))
            #pbCommonAnimation("Poison",i,nil) if !i.isInvulnerable?
            i.pbRecoverHP((i.totalhp/8).floor)
          end
          if i.statusCount>0
            i.effects[PBEffects::Toxic]+=1
            i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
          end
        else
          pbDisplay(_INTL("{1} is hurt by poison!",i.pbThis))
          pbCommonAnimation("Poison",i,nil) if !i.isInvulnerable?
          if i.statusCount==0
            i.pbReduceHP((i.totalhp/8).floor)
          else
            i.effects[PBEffects::Toxic]+=1
            i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
            i.pbReduceHP((i.totalhp/16).floor*i.effects[PBEffects::Toxic])
          end
        end
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Burn
    for i in priority
      next if i.hp<=0
      if i.status==PBStatuses::BURN && !i.hasWorkingAbility(:MAGICGUARD)
        pbCommonAnimation("Burn",i,nil) if !i.isInvulnerable?
        pbDisplay(_INTL("{1} is hurt by its burn!",i.pbThis))
        if i.hasWorkingAbility(:HEATPROOF)
          i.pbReduceHP((i.totalhp/16).floor)
        else
          i.pbReduceHP((i.totalhp/8).floor)
        end
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Nightmare
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::Nightmare] && !i.hasWorkingAbility(:MAGICGUARD)
        if i.status==PBStatuses::SLEEP
          pbDisplay(_INTL("{1} is locked in a nightmare!",i.pbThis))
          if @weather==PBWeather::NEWMOON
            i.pbReduceHP((i.totalhp/2).floor)
          else
            i.pbReduceHP((i.totalhp/4).floor)
          end
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
      if i.effects[PBEffects::Curse] && !i.hasWorkingAbility(:MAGICGUARD)
        pbDisplay(_INTL("{1} is afflicted by the Curse!",i.pbThis))
        i.pbReduceHP((i.totalhp/4).floor)
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Multi-turn attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::MultiTurn]>0
        i.effects[PBEffects::MultiTurn]-=1
        movename=PBMoves.getName(i.effects[PBEffects::MultiTurnAttack])
        if i.effects[PBEffects::MultiTurn]==0
          pbDisplay(_INTL("{1} was freed from {2}!",i.pbThis,movename))
        else
          if !i.hasWorkingAbility(:MAGICGUARD)
            pbDisplay(_INTL("{1} is hurt by {2}!",i.pbThis,movename)) 
            amt=(i.totalhp/8).floor
            if @battlers[i.effects[PBEffects::MultiTurnUser]].hasWorkingItem(:BINDINGBAND)
              amt=(i.totalhp/6).floor
            end
            i.pbReduceHP(amt)
          end
        end
      end  
      if i.hp<=0
        return if !i.pbFaint
        next
      end
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
      next if i.fainted?
      if i.effects[PBEffects::HealBlock]>0
        i.effects[PBEffects::HealBlock]-=1
        if i.effects[PBEffects::HealBlock]==0
          pbDisplay(_INTL("{1}'s Heal Block wore off!",i.pbThis))
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
          i.pbBerryCureCheck
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
          i.pbReduceHP(i.hp)
        end
      end
      if i.hp<=0
        return if !i.pbFaint
        next
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
    # Roost fading
    for i in priority
      next if i.hp<=0
      i.effects[PBEffects::Roost]=false
    end
    # Reflect
    for i in 0..1
      if sides[i].effects[PBEffects::Reflect] > 0
        sides[i].effects[PBEffects::Reflect]-=1
        if sides[i].effects[PBEffects::Reflect]==0
          pbDisplay(_INTL("Ally's Reflect faded!")) if i==0
          pbDisplay(_INTL("Foe's Reflect faded!")) if i==1
        end
      end
    end
    # Light Screen
    for i in 0..1
      if sides[i].effects[PBEffects::LightScreen] > 0
        sides[i].effects[PBEffects::LightScreen]-=1
        if sides[i].effects[PBEffects::LightScreen]==0
          pbDisplay(_INTL("Ally's Light Screen faded!")) if i==0
          pbDisplay(_INTL("Foe's Light Screen faded!")) if i==1
        end
      end
    end
    # Safeguard
    for i in 0..1
      if sides[i].effects[PBEffects::Safeguard] > 0
        sides[i].effects[PBEffects::Safeguard]-=1
        if sides[i].effects[PBEffects::Safeguard]==0
          pbDisplay(_INTL("Ally's party is no longer protected by Safeguard!")) if i==0
          pbDisplay(_INTL("Foe's party is no longer protected by Safeguard!")) if i==1
        end
      end
    end
    # Mist
    for i in 0..1
      if sides[i].effects[PBEffects::Mist] > 0
        sides[i].effects[PBEffects::Mist]-=1
        if sides[i].effects[PBEffects::Mist]==0
          pbDisplay(_INTL("Ally's Mist faded!")) if i==0
          pbDisplay(_INTL("Foe's Mist faded!")) if i==1
        end
      end
    end
    # Tailwind
    for i in 0..1
      if sides[i].effects[PBEffects::Tailwind] > 0
        sides[i].effects[PBEffects::Tailwind]-=1
        if sides[i].effects[PBEffects::Tailwind]==0
          pbDisplay(_INTL("Your team's Tailwind stopped blowing!")) if i==0
          pbDisplay(_INTL("The opposing team's Tailwind stopped blowing!")) if i==1
        end
      end
    end
    # Jet Stream
    for i in 0..1
      if sides[i].effects[PBEffects::JetStream] > 0
        sides[i].effects[PBEffects::JetStream]-=1
        if sides[i].effects[PBEffects::JetStream]==0
          pbDisplay(_INTL("Your team's supercharged air current dissipated!")) if i==0
          pbDisplay(_INTL("The opposing team's supercharged air current dissipated!")) if i==1
        end
      end
    end
    # Lucky Chant
    for i in 0..1
      if sides[i].effects[PBEffects::LuckyChant] > 0
        sides[i].effects[PBEffects::LuckyChant]-=1
        if sides[i].effects[PBEffects::LuckyChant]==0
          pbDisplay(_INTL("Your team's Lucky Chant faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Lucky Chant faded!")) if i==1
        end
      end
    end
    # End of Pledge move combinations
    for i in 0...2
      if sides[i].effects[PBEffects::Swamp]>0
        sides[i].effects[PBEffects::Swamp]-=1
        if sides[i].effects[PBEffects::Swamp]==0
          pbDisplay(_INTL("The swamp around your team disappeared!")) if i==0
          pbDisplay(_INTL("The swamp around the opposing team disappeared!")) if i==1
        end
      end
      if sides[i].effects[PBEffects::SeaOfFire]>0
        sides[i].effects[PBEffects::SeaOfFire]-=1
        if sides[i].effects[PBEffects::SeaOfFire]==0
          pbDisplay(_INTL("The sea of fire around your team disappeared!")) if i==0
          pbDisplay(_INTL("The sea of fire around the opposing team disappeared!")) if i==1
        end
      end
      if sides[i].effects[PBEffects::Rainbow]>0
        sides[i].effects[PBEffects::Rainbow]-=1
        if sides[i].effects[PBEffects::Rainbow]==0
          pbDisplay(_INTL("The rainbow around your team disappeared!")) if i==0
          pbDisplay(_INTL("The rainbow around the opposing team disappeared!")) if i==1
        end
      end
    end
    # Trick Room
    if @field.effects[PBEffects::TrickRoom]>0
      @field.effects[PBEffects::TrickRoom]-=1
      if @field.effects[PBEffects::TrickRoom]==0
        pbDisplay(_INTL("The twisted dimensions returned to normal."))
      end
    end
    # Water Sport
    if @field.effects[PBEffects::WaterSportField]>0
      @field.effects[PBEffects::WaterSportField]-=1
      if @field.effects[PBEffects::WaterSportField]==0
        pbDisplay(_INTL("The effects of Water Sport have faded."))
      end
    end
    # Mud Sport
    if @field.effects[PBEffects::MudSportField]>0
      @field.effects[PBEffects::MudSportField]-=1
      if @field.effects[PBEffects::MudSportField]==0
        pbDisplay(_INTL("The effects of Mud Sport have faded."))
      end
    end
    # Wonder Room
    if @field.effects[PBEffects::WonderRoom]>0
      @field.effects[PBEffects::WonderRoom]-=1
      if @field.effects[PBEffects::WonderRoom]==0
        pbDisplay(_INTL("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!"))
      end
    end
    # Magic Room
    if @field.effects[PBEffects::MagicRoom]>0
      @field.effects[PBEffects::MagicRoom]-=1
      if @field.effects[PBEffects::MagicRoom]==0
        pbDisplay(_INTL("The area returned to normal."))
      end
    end
    #if sides[0].effects[PBEffects::MagicRoom] > 0 ||
    #   sides[1].effects[PBEffects::MagicRoom] > 0
    #  magicroom=[sides[0].effects[PBEffects::MagicRoom],
    #             sides[1].effects[PBEffects::MagicRoom]].max
    #  magicroom-=1
    # sides[0].effects[PBEffects::MagicRoom] = magicroom
    #  sides[1].effects[PBEffects::MagicRoom] = magicroom
    #  if magicroom==0
    #    pbDisplay(_INTL("The area returned to normal."))
    #  end
    #end
    # Gravity
    if @field.effects[PBEffects::Gravity]>0
      @field.effects[PBEffects::Gravity]-=1
      if @field.effects[PBEffects::Gravity]==0
        pbDisplay(_INTL("Gravity returned to normal."))
      end
    end
    # Electric Terrain (counting down)
    if @field.effects[PBEffects::ElectricTerrain]>0
      @field.effects[PBEffects::ElectricTerrain]-=1
      if @field.effects[PBEffects::ElectricTerrain]==0
        pbDisplay(_INTL("The electric current disappeared from the battlefield."))
      end
    end
    # Grassy Terrain (counting down)
    if @field.effects[PBEffects::GrassyTerrain]>0
      @field.effects[PBEffects::GrassyTerrain]-=1
      if @field.effects[PBEffects::GrassyTerrain]==0
        pbDisplay(_INTL("The grass disappeared from the battlefield."))
      end
    end
    # Misty Terrain (counting down)
    if @field.effects[PBEffects::MistyTerrain]>0
      @field.effects[PBEffects::MistyTerrain]-=1
      if @field.effects[PBEffects::MistyTerrain]==0
        pbDisplay(_INTL("The mist disappeared from the battlefield."))
        PBDebug.log("[End of effect] Misty Terrain ended")
      end
    end
    # Block B
    for i in priority
      next if i.hp<=0
      # Uproar
      if i.effects[PBEffects::Uproar]>0
        for j in priority
          if j.hp>0 && j.status==PBStatuses::SLEEP && !j.hasWorkingAbility(:SOUNDPROOF)
            pbDisplay(_INTL("{1} woke up in the uproar!",j.pbThis))
            j.effects[PBEffects::Nightmare]=false
            j.status=0
            j.statusCount=0
          end
        end
        i.effects[PBEffects::Uproar]-=1
        if i.effects[PBEffects::Uproar]==0
          pbDisplay(_INTL("{1} calmed down.",i.pbThis))
        else
          pbDisplay(_INTL("{1} is making an uproar!",i.pbThis)) 
        end
      end
      # Speed Boost
      # A Pokémon's turncount is 0 if it became active after the beginning of a round
      if i.turncount>0 && i.hasWorkingAbility(:SPEEDBOOST)
        if !i.pbTooHigh?(PBStats::SPEED)
          i.pbIncreaseStatBasic(PBStats::SPEED,1)
          pbCommonAnimation("StatUp",i,nil) if !i.isInvulnerable?
          pbDisplay(_INTL("{1}'s Speed Boost raised its Speed!",i.pbThis))
        end 
      end
      # Moody
      if i.hasWorkingAbility(:MOODY)
        randomup=[]; randomdown=[];
        for j in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
                  PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          randomup.push(j) if !i.pbTooHigh?(j)
          randomdown.push(j) if !i.pbTooLow?(j)
        end
        if randomup.length>0
          r=pbRandom(randomup.length)
          
          i.pbIncreaseStat(randomup[r],2,false)
          pbCommonAnimation("StatUp",i,nil) if !i.isInvulnerable?
          if randomup[r]==PBStats::ATTACK
            statnames=_INTL("Attack")
          elsif randomup[r]==PBStats::DEFENSE
            statnames=_INTL("Defense")
          elsif randomup[r]==PBStats::SPEED
            statnames=_INTL("Speed")
          elsif randomup[r]==PBStats::SPATK
            statnames=_INTL("Special Attack")
          elsif randomup[r]==PBStats::SPDEF
            statnames=_INTL("Special Defense")
          elsif randomup[r]==PBStats::EVASION
            statnames=_INTL("Evasion")
          elsif randomup[r]==PBStats::ACCURACY
            statnames=_INTL("Accuracy")
          end
          pbDisplay(_INTL("{1}'s Moody sharply raised its {2}!",i.pbThis,statnames))
          for j in 0...randomdown.length
            if randomdown[j]==randomup[r]
              randomdown[j]=nil; randomdown.compact!
              break
            end
          end
        end
        if randomdown.length>0
          r=pbRandom(randomdown.length)
          
          i.pbReduceStat(randomdown[r],1,false)
          pbCommonAnimation("StatDown",i,nil) if !i.isInvulnerable?
          if randomdown[r]==PBStats::ATTACK
            statnames=_INTL("Attack")
          elsif randomdown[r]==PBStats::DEFENSE
            statnames=_INTL("Defense")
          elsif randomdown[r]==PBStats::SPEED
            statnames=_INTL("Speed")
          elsif randomdown[r]==PBStats::SPATK
            statnames=_INTL("Special Attack")
          elsif randomdown[r]==PBStats::SPDEF
            statnames=_INTL("Special Defense")
          elsif randomdown[r]==PBStats::EVASION
            statnames=_INTL("Evasion")
          elsif randomdown[r]==PBStats::ACCURACY
            statnames=_INTL("Accuracy")
          end
          pbDisplay(_INTL("{1}'s Moody lowered its {2}!",i.pbThis,statnames))
        end
=begin
        toohigh=false
        toolow=false
        if i.pbTooHigh?(PBStats::SPEED) && i.pbTooHigh?(PBStats::ATTACK) &&
           i.pbTooHigh?(PBStats::SPATK) && i.pbTooHigh?(PBStats::SPDEF) && 
           i.pbTooHigh?(PBStats::DEFENSE) && i.pbTooHigh?(PBStats::EVASION) &&
           i.pbTooHigh?(PBStats::ACCURACY)
          toohigh=true
        end
        if i.pbTooLow?(PBStats::SPEED) && i.pbTooLow?(PBStats::ATTACK) &&
           i.pbTooLow?(PBStats::SPATK) && i.pbTooLow?(PBStats::SPDEF) && 
           i.pbTooLow?(PBStats::DEFENSE) && i.pbTooLow?(PBStats::EVASION) &&
           i.pbTooLow?(PBStats::ACCURACY)
          toolow=true
        end
        if !toohigh
          loop do
            rand=1+self.pbRandom(7)
            if !i.pbTooHigh?(rand)
              randoms.push(rand)
              break
            end
          end
        end
        if !toolow
          loop do
            rand=1+self.pbRandom(7)
            if !i.pbTooLow?(rand) && rand!=randoms[0]
              randoms.push(rand)
              break
            end
          end
        end
        statnames=[_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),_INTL("Special Attack"),
                   _INTL("Special Defense"),_INTL("accuracy"),_INTL("evasiveness")]
        if !toohigh
          i.stages[randoms[0]]+=2
          i.stages[randoms[0]]=6 if i.stages[randoms[0]]>6
          pbCommonAnimation("StatUp",i,nil)
          pbDisplay(_INTL("{1}'s Moody sharply raised its {2}!",i.pbThis,statnames[randoms[0]-1]))
        end
        if !toolow
          i.stages[randoms[1]]-=1
          pbCommonAnimation("StatDown",i,nil)
          pbDisplay(_INTL("{1}'s Moody lowered its {2}!",i.pbThis,statnames[randoms[1]-1]))
        end
=end
      end
      # Bad Dreams
      if i.hasWorkingAbility(:BADDREAMS) && i.hp>0
        if i.pbOpposing1.status==PBStatuses::SLEEP
          if @weather==PBWeather::NEWMOON
            hploss=i.pbOpposing1.pbReduceHP((i.pbOpposing1.totalhp/4).floor)
          else
            hploss=i.pbOpposing1.pbReduceHP((i.pbOpposing1.totalhp/8).floor)
          end
          pbDisplay(_INTL("{1} is having a bad dream!",i.pbOpposing1.pbThis)) if hploss>0
          i.pbOpposing1.pbFaint if (i.pbOpposing1.hp<=0)
          if i.pbOpposing1.hp<=0
            return if !i.pbOpposing1.pbFaint
          end
        end
        if i.pbOpposing2.status==PBStatuses::SLEEP
          if @weather==PBWeather::NEWMOON
            hploss=i.pbOpposing2.pbReduceHP((i.pbOpposing2.totalhp/4).floor)
          else
            hploss=i.pbOpposing2.pbReduceHP((i.pbOpposing2.totalhp/8).floor)
          end
          pbDisplay(_INTL("{1} is having a bad dream!",i.pbOpposing2.pbThis)) if hploss>0
          i.pbOpposing2.pbFaint if (i.pbOpposing2.hp<=0)
          if i.pbOpposing2.hp<=0
            return if !i.pbOpposing2.pbFaint
          end
        end
      end
      # Flame Orb
      if isConst?(i.item,PBItems,:FLAMEORB) && i.status==0 && i.pbCanBurn?(nil,false,nil,true)
        i.status=PBStatuses::BURN
        i.statusCount=0
        pbCommonAnimation("Burn",i,nil) if !i.isInvulnerable?
        pbDisplay(_INTL("{1} was burned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Toxic Orb
      if isConst?(i.item,PBItems,:TOXICORB) && i.status==0 && i.pbCanPoison?(nil,false,nil,true)
        i.status=PBStatuses::POISON
        i.statusCount=1
        i.effects[PBEffects::Toxic]=0
        pbCommonAnimation("Poison",i,nil) if !i.isInvulnerable?
        pbDisplay(_INTL("{1} was poisoned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Sticky Barb
      if isConst?(i.item,PBItems,:STICKYBARB) && !i.hasWorkingAbility(:MAGICGUARD)
        pbDisplay(_INTL("{1} is hurt by its {2}!",i.pbThis,PBItems.getName(i.item)))
        i.pbReduceHP((i.totalhp/8).floor)
      end
      # Pickup
      if i.hasWorkingAbility(:PICKUP) && i.item<=0
        item=0; index=-1; use=0
        for j in 0...4
          next if j==i.index
          if @battlers[j].effects[PBEffects::PickupUse]>use
            item=@battlers[j].effects[PBEffects::PickupItem]
            index=j
            use=@battlers[j].effects[PBEffects::PickupUse]
          end
        end
        if item>0
          i.item=item
          @battlers[index].effects[PBEffects::PickupItem]=0
          @battlers[index].effects[PBEffects::PickupUse]=0
          @battlers[index].pokemon.itemRecycle=0 if @battlers[index].pokemon.itemRecycle==item
          if !@opponent && # In a wild battle
             i.pokemon.itemInitial==0 &&
             @battlers[index].pokemon.itemInitial==item
            i.pokemon.itemInitial=item
            @battlers[index].pokemon.itemInitial=0
          end
          pbDisplay(_INTL("{1} found one {2}!",i.pbThis,PBItems.getName(item)))
          i.pbBerryCureCheck(true)
        end
      end
      # Harvest
      if i.hasWorkingAbility(:HARVEST) && i.item<=0 && i.pokemon.itemRecycle>0 && 
         !i.effects[PBEffects::HarvestActivated]
        if pbIsBerry?(i.pokemon.itemRecycle) &&
           (pbWeather==PBWeather::SUNNYDAY || 
           pbWeather==PBWeather::HARSHSUN || pbRandom(10)<5)
          i.item=i.pokemon.itemRecycle
          i.pokemon.itemRecycle=0
          i.pokemon.itemInitial=i.item if i.pokemon.itemInitial==0
          pbDisplay(_INTL("{1} harvested one {2}!",i.pbThis,PBItems.getName(i.item)))
          i.effects[PBEffects::HarvestActivated]=true
          i.pbBerryCureCheck(true)
        end
      end
      if i.hp<=0
        return if !i.pbFaint
        next
      end
    end
    # Unleafed, Chlorofury
    for i in priority
      if i.effects[PBEffects::Unleafed]>0
        i.effects[PBEffects::Unleafed]-=1
        if i.effects[PBEffects::Unleafed]==0
          # @battlers[i].form -= 2
          i.pokemon.form-=2 if isConst?(i.species,PBSpecies,:SUNFLORA)
          i.pbReduceStatBasic(PBStats::SPEED,1)
          pbCommonAnimation("StatDown",i,nil) if !i.isInvulnerable?
          i.pbReduceStatBasic(PBStats::SPATK,1)
          pbCommonAnimation("StatDown",i,nil) if !i.isInvulnerable?
          i.pbReduceStatBasic(PBStats::SPDEF,1)
          pbCommonAnimation("StatDown",i,nil) if !i.isInvulnerable?
          i.pbReduceStatBasic(PBStats::ATTACK,1)
          pbCommonAnimation("StatDown",i,nil) if !i.isInvulnerable?
          i.pbReduceStatBasic(PBStats::DEFENSE,1)
          pbCommonAnimation("StatDown",i,nil) if !i.isInvulnerable?
          pbDisplay(i.pbThis + " calmed down.")
          i.pbCheckForm
        end
      end
      if i.effects[PBEffects::Chlorofury]>0
        i.effects[PBEffects::Chlorofury]-=1
        if i.effects[PBEffects::Chlorofury]==0
          i.pbReduceStatBasic(PBStats::SPEED,1)
          pbCommonAnimation("StatDown",i,nil) if !i.isInvulnerable?
          i.pbReduceStatBasic(PBStats::SPATK,i.effects[PBEffects::ChlorofuryBoost])
          pbDisplay(i.pbThis + " cooled down.")
        end
      end
    end
    for i in priority
      next if i.hp<=0
      if i.effects[PBEffects::BurstMode]
        if i.effects[PBEffects::SynergyBurst]>1 && i.effects[PBEffects::SynergyBurst]<6 &&
           !i.effects[PBEffects::BurstModeDamaged] && i.hp<i.totalhp
          i.pbRecoverHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1} was able to recover a bit of its HP undisturbed!",i.pbThis(false)))
        end
        i.effects[PBEffects::SynergyBurst]-=1
        if i.effects[PBEffects::SynergyBurst]<=0
          i.pokemon.burstAttack=false
          pbDisplay(_INTL("{1} is no longer in Burst Mode!",i.pbThis(false)))
          i.effects[PBEffects::BurstMode]=false
          i.effects[PBEffects::SynergyBurst]=0
          i.effects[PBEffects::AuraBlastCharges]=0
          @scene.pbRefresh
        else
          if i.effects[PBEffects::AuraBlastCharges]>0 && i.effects[PBEffects::AuraBlastCharges]<7 &&
             !i.pokemon.burstAttack
            i.effects[PBEffects::AuraBlastCharges]+=1
          end
        end
      end
      i.effects[PBEffects::BurstModeDamaged]=false
    end
    # Slow Start's end message
    for i in priority
      if i.hasWorkingAbility(:SLOWSTART) && i.turncount==5
        pbDisplay(_INTL("{1} finally got its act together!",i.pbThis))
      end
    end
    # Form checks
    for i in priority
      next if i.hp<=0
      i.pbCheckForm
    end
    #      for i in 0..3
    #end
=begin
    for i in 0..3
      if @battlers[i].effects[PBEffects::Roost] == 1 && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DUNSPARCE) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:SCIZOR) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:LATIOS) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:LATIAS) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:BEEDRILL) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:VENOMOTH) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:MEW) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:VIBRAVA) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:FLYGON) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:HYDREIGON) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:VOLCARONA) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DUSTOX) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:VOLBEAT) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:ILLUMISE) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTASCYTHER) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTASCIZOR) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAVESPIQUEN) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAMISDREAVUS) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAMISMAGIUS) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAPURRLOIN) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTALIEPARD) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAPIDGEY) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAPIDGEOTTO) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAPIDGEOT) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAELECTABUZZ) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAELECTIVIRE) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAVOLCARONA) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAHYDREIGON) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:RESHIRAM) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:ZEKROM) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:KYUREM) && 
         (!isConst?(@battlers[i].pokemon.species,PBSpecies,:CHARIZARD) && 
         @battlers[i].form!=1) && 
         (!isConst?(@battlers[i].pokemon.species,PBSpecies,:ALTARIA) && 
         @battlers[i].form!=1) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTANOIBAT) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTANOIVERN)
        @battlers[i].type2=PBTypes::FLYING
      elsif @battlers[i].effects[PBEffects::Roost] == 1 && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DUNSPARCE) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:SCIZOR) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:LATIOS) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:LATIAS) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:BEEDRILL) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:VENOMOTH) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:MEW) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:VIBRAVA) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:FLYGON) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:HYDREIGON) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:VOLCARONA) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DUSTOX) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:VOLBEAT) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:ILLUMISE) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTASCYTHER) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTASCIZOR) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAVESPIQUEN) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAMISDREAVUS) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAMISMAGIUS) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAPURRLOIN) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTALIEPARD) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAPIDGEY) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAPIDGEOTTO) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAPIDGEOT) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAELECTABUZZ) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAELECTIVIRE) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAVOLCARONA) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTAHYDREIGON) &&
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:RESHIRAM) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:ZEKROM) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:KYUREM) && 
         (!isConst?(@battlers[i].pokemon.species,PBSpecies,:CHARIZARD) &&
         @battlers[i].form!=1) &&
         (!isConst?(@battlers[i].pokemon.species,PBSpecies,:ALTARIA) && 
         @battlers[i].form!=1) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTANOIBAT) && 
         !isConst?(@battlers[i].pokemon.species,PBSpecies,:DELTANOIVERN)
        @battlers[i].type1=PBTypes::FLYING if @battlers[i].pokemon.type1==PBTypes::FLYING
        @battlers[i].type2=PBTypes::FLYING if @battlers[i].pokemon.type2==PBTypes::FLYING
      end
      @battlers[i].effects[PBEffects::Roost] = 0
    end
=end

  
    #if @trickroom > 0
    #  @trickroom=@trickroom-1
    #  if @trickroom == 0
    #      pbDisplay("The twisted dimensions returned to normal!")
    #    end
    #  end
    #if @wonderroom > 0
    #  @wonderroom=@wonderroom-1
    #  if @wonderroom == 0
    #      pbDisplay("The Magic Room returned to normal!")
    #  end      
    #end
    # Weather
    #if @deltastream
    #        cornhole=false
    #   for i in @battlers
    #       cornhole =true if i.hp>0 && i.ability==PBAbilities::DELTASTREAM
    #   end
    #   if !cornhole
    #  @weatherduration=0
    #      pbDisplay(_INTL("The Delta Stream faded."))
    #     @deltastream=false
    #     @weather=0
    #    @scene.pbBackdropMove(0,true,true)
    #  end
    #end
    #if @primordialsea
    #        cornhole=false
    #   for i in @battlers
    #       cornhole =true if i.hp>0 && i.ability==PBAbilities::PRIMORDIALSEA
    #   end
    #   if !cornhole
    #   @weatherduration=0
    #     pbDisplay(_INTL("The heavy rain faded."))
    #      @primordialsea=false
    #      @weather=0
    #    @scene.pbBackdropMove(0,true,true)
    #  end
    #end
    #if @desolateland
    #  cornhole=false
    #   for i in @battlers
    #       cornhole =true if i.hp>0 && i.ability==PBAbilities::DESOLATELAND
    #   end
    #   if !cornhole
    #   @weatherduration=0
    #      pbDisplay(_INTL("The intense sunlight faded."))
    #      @desolateland=false
    #      @weather=0
    #    @scene.pbBackdropMove(0,true,true)
    #  end
    #end
    #if i.effects[PBEffects::Infestation]>0
    #  pbDisplay(_INTL("{1} is hurt by the Infestation!",i.pbThis))
#   #  pbCommonAnimation("Poison",i,nil)
    #  i.pbReduceHP((i.totalhp/8).floor)
    #  i.effects[PBEffects::Infestation] -= 1 
    #end
    #if sides[0].effects[PBEffects::Gravity] > 0 ||
    #   sides[1].effects[PBEffects::Gravity] > 0
    #  gravity=[sides[0].effects[PBEffects::Gravity],
    #           sides[1].effects[PBEffects::Gravity]].max
    #  gravity-=1
    #  sides[0].effects[PBEffects::Gravity] = gravity
    #  sides[1].effects[PBEffects::Gravity] = gravity
    #  if gravity==0
    #    pbDisplay(_INTL("Gravity returned to normal."))
    #  end
    #end

    pbGainEXP
   # pbSwitch

    return if @decision>0
    for i in priority
      next if i.hp<=0
      i.pbAbilitiesOnSwitchIn(false)
    end
    # Healing Wish/Lunar Dance - should go here
    # Spikes/Toxic Spikes/Stealth Rock - should go here (in order of their 1st use)
    for i in 0..3
      if @battlers[i].turncount>0 && @battlers[i].hasWorkingAbility(:TRUANT)
        @battlers[i].effects[PBEffects::Truant]=!@battlers[i].effects[PBEffects::Truant]
      end
      if @battlers[i].effects[PBEffects::LockOn]>0   # Also Mind Reader
        @battlers[i].effects[PBEffects::LockOn]-=1
        @battlers[i].effects[PBEffects::LockOnPos]=-1 if @battlers[i].effects[PBEffects::LockOn]==0
      end
      if !@battlers[i].effects[PBEffects::FuryCutterUsed]
        @battlers[i].effects[PBEffects::FuryCutter]=0
      end
      @battlers[i].effects[PBEffects::FuryCutterUsed]=false
      @battlers[i].effects[PBEffects::Flinch]=false
      @battlers[i].effects[PBEffects::FollowMe]=0
      @battlers[i].effects[PBEffects::HarvestActivated]=false
      @battlers[i].effects[PBEffects::AllySwitch]=false
      @battlers[i].effects[PBEffects::HelpingHand]=false
      @battlers[i].effects[PBEffects::MagicCoat]=false
      @battlers[i].effects[PBEffects::Snatch]=false
      @battlers[i].effects[PBEffects::Charge]-=1 if @battlers[i].effects[PBEffects::Charge]>0
      @battlers[i].lastHPLost=0
      @battlers[i].lastAttacker.clear
      @battlers[i].effects[PBEffects::Counter]=-1
      @battlers[i].effects[PBEffects::CounterTarget]=-1
      @battlers[i].effects[PBEffects::MirrorCoat]=-1
      @battlers[i].effects[PBEffects::MirrorCoatTarget]=-1
      @battlers[i].effects[PBEffects::RagePowder]=0
    end
    for i in 0...2
      if !@sides[i].effects[PBEffects::EchoedVoiceUsed]
        @sides[i].effects[PBEffects::EchoedVoiceCounter]=0
      end
      @sides[i].effects[PBEffects::EchoedVoiceUsed]=false
      @sides[i].effects[PBEffects::MatBlock]=false
      @sides[i].effects[PBEffects::QuickGuard]=false
      @sides[i].effects[PBEffects::WideGuard]=false
      @sides[i].effects[PBEffects::CraftyShield]=false
      @sides[i].effects[PBEffects::Round]=0
    end
    @field.effects[PBEffects::FusionBolt]=false
    @field.effects[PBEffects::FusionFlare]=false
    @field.effects[PBEffects::IonDeluge]=false
    @field.effects[PBEffects::FairyLock]-=1 if @field.effects[PBEffects::FairyLock]>0
    # invalidate stored priority
    @usepriority=false
  end
end
