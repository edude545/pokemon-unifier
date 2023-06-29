class PokeBattle_Battler
  attr_reader :battle
  attr_reader :pokemon
  attr_reader :name
  attr_reader :index
  attr_reader :pokemonIndex
  attr_reader :totalhp
  attr_reader :fainted
  attr_reader :usingsubmove
  attr_accessor :lastAttacker
  attr_accessor :turncount
  attr_accessor :effects
  attr_accessor :species
  attr_accessor :type1
  attr_accessor :type2
  attr_accessor :ability
  attr_accessor :gender
  attr_accessor :happiness
  attr_accessor :attack
  attr_accessor :defense
  attr_accessor :spatk
  attr_accessor :spdef
  attr_accessor :speed
  attr_accessor :stages
  attr_accessor :iv
  attr_accessor :moves
  attr_accessor :participants
  attr_accessor :lastHPLost
  attr_accessor :lastMoveUsed
  attr_accessor :lastMoveUsedSketch
  attr_accessor :lastMoveUsedType
  attr_accessor :lastMoveUturn
  attr_accessor :lastMoveCalled
  attr_accessor :lastRoundMoved
  attr_accessor :movesUsed
  attr_accessor :currentMove
  attr_accessor :damagestate
  attr_accessor :owned
  attr_accessor :isMZO
  attr_accessor :saidIllu
  attr_accessor :moveHit
  attr_accessor :aimove
 # attr_accessor :attacksused

  def inHyperMode?; return false; end
  def isShadow?; return false; end

################################################################################
# Complex accessors
################################################################################
  def defense
    return @battle.field.effects[PBEffects::WonderRoom]>0 ? @spdef : @defense
  end

  def spdef
    return @battle.field.effects[PBEffects::WonderRoom]>0 ? @defense : @spdef
  end

  def nature
    return (@pokemon) ? @pokemon.nature : 0
  end

  def happiness
    return (@pokemon) ? @pokemon.happiness : 0
  end

  def pokerusStage
    return (@pokemon) ? @pokemon.pokerusStage : 0
  end

  attr_reader :form

  def form=(value)
    @form=value
    @pokemon.form=value if @pokemon
  end

  attr_reader :level

  def level=(value)
    @level=value
    @pokemon.level=(value) if @pokemon
  end

  attr_reader :status

  def status=(value)
    if @status==PBStatuses::SLEEP && value==0
      @effects[PBEffects::Truant]=false
    end
    @status=value
    @pokemon.status=value if @pokemon
    if value!=PBStatuses::POISON
      @effects[PBEffects::Toxic]=0
    end
    if value!=PBStatuses::POISON && value!=PBStatuses::SLEEP
      @statusCount=0
      @pokemon.statusCount=0 if @pokemon
    end
  end

  attr_reader :statusCount

  def statusCount=(value)
    @statusCount=value
    @pokemon.statusCount=value if @pokemon
  end

  attr_reader :hp

  def hp=(value)
    @hp=value
    @pokemon.hp=value if @pokemon
  end
  
  
  def type1
    if @effects[PBEffects::Illusion] && @battle.aimove && !@effects[PBEffects::TypeIdentified]
      return @effects[PBEffects::Illusion].type1
    end
 #   if @form > 0 || (@pokemon && @pokemon.form>0)
 #     if isConst?(@species,PBSpecies,:EEVEE)
 #         types=[:NORMAL,:WATER,:ELECTRIC,:FIRE,:PSYCHIC,:DARK,:GRASS,:ICE,:FAIRY]
 #         return getID(PBTypes,types[@pokemon.form-1])
 #     end
 #   end
    return @type1 
  end
  
  def type2
    if @effects[PBEffects::Illusion] && @battle.aimove && !@effects[PBEffects::TypeIdentified]
      return @effects[PBEffects::Illusion].type2
    end
    return @type2
  end
  
  def item(literal=false)
    #return 0 if @effects[PBEffects::Embargo]>0 && !literal && !Kernel.pbGetMegaStoneList.include?(@item)
    return 0 if @battle.field.effects[PBEffects::MagicRoom]>0 && !literal
    return 0 if self.hasWorkingAbility(:KLUTZ) && !literal
    return @item
  end
  
  def ability(literal=false)
    #return 0 if @effects[PBEffects::GastroAcid] && !literal
    if @form > 0 || (@pokemon && @pokemon.form>0)
      if isConst?(@species,PBSpecies,:AMPHAROS) 
        return PBAbilities::MOLDBREAKER
      end
      if isConst?(@species,PBSpecies,:STUNFISK) 
        return PBAbilities::ATHENIAN
      end
      if isConst?(@species,PBSpecies,:GARCHOMP) 
        return PBAbilities::SANDFORCE
      end
      if isConst?(@species,PBSpecies,:LANDORUS) && isConst?(@ability,PBAbilities,:SANDFORCE)
        return PBAbilities::INTIMIDATE
      end
      if isConst?(@species,PBSpecies,:THUNDURUS) && isConst?(@ability,PBAbilities,:PRANKSTER)
        return PBAbilities::VOLTABSORB
      end
      if isConst?(@species,PBSpecies,:TORNADUS) && isConst?(@ability,PBAbilities,:PRANKSTER)
        return PBAbilities::REGENERATOR
      end
    end
    if @effects[PBEffects::Illusion] && @battle.aimove && !@effects[PBEffects::TypeIdentified]
      return @effects[PBEffects::Illusion].ability
    end
    return @ability
  end
  def item=(value)
    @item=value
    @pokemon.item=value if @pokemon
  end

  def weight(attacker=nil)
    if @effects[PBEffects::Transform]
      w=0
    else
      w=(@pokemon) ? @pokemon.weight : 500
    end
    w+=@effects[PBEffects::WeightChange]
    if !attacker || !attacker.hasMoldBreaker
      w*=2 if self.hasWorkingAbility(:HEAVYMETAL)
      w/=2 if self.hasWorkingAbility(:LIGHTMETAL)
    end
    w/=2 if self.hasWorkingItem(:FLOATSTONE)
    w=w.floor
    w=1 if w<1
    #w*=@effects[PBEffects::WeightMultiplier]
    return w
  end
  
  def name
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].name
    end
    return @name
  end
  
  def species
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].species
    end
    return @species
  end
  
  def displayGender
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].gender
    end
    return self.gender
  end
  
  def isShiny?
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].isShiny?
    end
    return @pokemon.isShiny? if @pokemon
    return false
  end
  
  def isDelta?
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].isDelta?
    end
    return @pokemon.isDelta? if @pokemon
    return false
  end
  
  def isMega?
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].isMega?
    end
    return @pokemon.isMega? if @pokemon
    return false
  end
  
  def isArmored?
    if @effects[PBEffects::Illusion]
      return @effects[PBEffects::Illusion].isArmored?
    end
    return @pokemon.isArmored? if @pokemon
    return false
  end


################################################################################
# Creating a battler
################################################################################
  def initialize(btl,index)
    @battle       = btl
    @index        = index
    @hp           = 0
    @totalhp      = 0
    @fainted      = true
    @usingsubmove = false
    @stages       = []
    @effects      = []
    @moveHit      = true
    
    @damagestate  = PokeBattle_DamageState.new
    pbInitBlank
    pbInitEffects(false)
    pbInitPermanentEffects
  end

  def pbInitPokemon(pkmn,pkmnIndex)
    if pkmn.egg?
      raise _INTL("An egg can't be an active Pokémon")
    end
    @name         = pkmn.name
    @species      = pkmn.species
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @gender       = pkmn.gender
    @ability      = pkmn.ability
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @form         = pkmn.form
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @speed        = pkmn.speed
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @pokemon      = pkmn
    @pokemonIndex = pkmnIndex
    @effects[PBEffects::PID] = pkmn.personalID
    #if !$illusionnames || $illusionnames == nil
    #  $illusionnames = []
    #  $illusionnames[@index] = @name
    #end
    

    @participants = [] # Participants will earn Exp. Points if this battler is defeated
    @moves        = [
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[0]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[1]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[2]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[3])
    ]
    @iv           = []
    @iv[0]        = pkmn.iv[0]
    @iv[1]        = pkmn.iv[1]
    @iv[2]        = pkmn.iv[2]
    @iv[3]        = pkmn.iv[3]
    @iv[4]        = pkmn.iv[4]
    @iv[5]        = pkmn.iv[5]
    @item         = pkmn.item
    @happiness    = pkmn.happiness
    @owned        = ($Trainer.owned[pkmn.species] && !@battle.opponent)
    @isMZO = false
    @saidIllu = false
  end
  
  def pbInitDummyPokemon(pkmn,pkmnIndex,batonpass=false)
    if pkmn.egg?
      raise _INTL("An egg can't be an active Pokémon")
    end
    @name         = pkmn.name
    @species      = pkmn.species
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @gender       = pkmn.gender
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @form         = pkmn.form
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @speed        = pkmn.speed
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @pokemon      = pkmn
    @pokemonIndex = pkmnIndex
    @ability      = pkmn.ability
    @item         = pkmn.item
    #@effects      = pkmn.effects
    @effects[PBEffects::PID] = pkmn.personalID
    @participants = []
    @moves        = [
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[0]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[1]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[2]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[3])
    ]
    @iv           = []
    @iv[0]        = pkmn.iv[0]
    @iv[1]        = pkmn.iv[1]
    @iv[2]        = pkmn.iv[2]
    @iv[3]        = pkmn.iv[3]
    @iv[4]        = pkmn.iv[4]
    @iv[5]        = pkmn.iv[5]
    if batonpass
      @stages[PBStats::ATTACK]   = 0
      @stages[PBStats::DEFENSE]  = 0
      @stages[PBStats::SPEED]    = 0
      @stages[PBStats::SPATK]    = 0
      @stages[PBStats::SPDEF]    = 0
      @stages[PBStats::EVASION]  = 0
      @stages[PBStats::ACCURACY] = 0
    end
    @lastMoveUsedSketch          = -1
    @damagestate.reset
    @fainted                     = false
    @lastAttacker                = []
    @lastHPLost                  = 0
    @lastMoveUsed                = -1
    @lastMoveUsedType            = -1
    @lastMoveUturn               = false
    @lastMoveCalled              = 0
    @lastRoundMoved              = -1
    @movesUsed                   = []
    @turncount                   = 0
  end

  def pbInitBlank
    @name         = ""
    @species      = 0
    @level        = 0
    @hp           = 0
    @totalhp      = 0
    @gender       = 0
    @ability      = 0
    @type1        = 0
    @type2        = 0
    @form         = 0
    @attack       = 0
    @defense      = 0
    @speed        = 0
    @spatk        = 0
    @spdef        = 0
    @status       = 0
    @statusCount  = 0
    @pokemon      = nil
    @pokemonIndex = -1
    @participants = []
    @moves        = [nil,nil,nil,nil]
    @iv           = [0,0,0,0,0,0]
    @item         = 0
    @happiness    = 0
    @owned        = false
    @weight       = nil
  end

  def pbInitPermanentEffects
    # These effects are retained even if a Pokémon is replaced
    @effects[PBEffects::FutureSight]       = 0
    @effects[PBEffects::FutureSightDamage] = 0
    @effects[PBEffects::FutureSightMove]   = 0
    @effects[PBEffects::FutureSightLoop]   = false
    @effects[PBEffects::FutureSightUser]   = -1
    @effects[PBEffects::FutureSightUserPos]= -1
    @effects[PBEffects::HealingWish]       = false
    @effects[PBEffects::LunarDance]        = false
    @effects[PBEffects::Wish]              = 0
    @effects[PBEffects::WishAmount]        = 0
    @effects[PBEffects::WishLoop]          = false
    @effects[PBEffects::WishMaker]         = -1
  end

  def pbInitEffects(batonpass)
    if !batonpass
      # These effects are retained if Baton Pass is used
      @stages[PBStats::ATTACK]   = 0
      @stages[PBStats::DEFENSE]  = 0
      @stages[PBStats::SPEED]    = 0
      @stages[PBStats::SPATK]    = 0
      @stages[PBStats::SPDEF]    = 0
      @stages[PBStats::EVASION]  = 0
      @stages[PBStats::ACCURACY] = 0
      @lastMoveUsedSketch        = -1
      @effects[PBEffects::AquaRing]    = false
      @effects[PBEffects::Confusion]   = 0
      @effects[PBEffects::Curse]       = false
      @effects[PBEffects::Embargo]     = 0
      @effects[PBEffects::FocusEnergy] = 0
      @effects[PBEffects::GastroAcid]  = false
      @effects[PBEffects::Ingrain]     = false
      @effects[PBEffects::LeechSeed]   = -1
      @effects[PBEffects::LockOn]      = 0
      @effects[PBEffects::LockOnPos]   = -1
      for i in 0..3
        next if !@battle.battlers[i]
        if @battle.battlers[i].effects[PBEffects::LockOnPos]==@index &&
           @battle.battlers[i].effects[PBEffects::LockOn]>0
          @battle.battlers[i].effects[PBEffects::LockOn]=0
          @battle.battlers[i].effects[PBEffects::LockOnPos]=-1
        end
      end
      @effects[PBEffects::MagnetRise]     = 0
      @effects[PBEffects::PerishSong]     = 0
      @effects[PBEffects::PerishSongUser] = -1
      @effects[PBEffects::PowerTrick]     = false
      @effects[PBEffects::Substitute]     = 0
      @effects[PBEffects::Telekinesis]    = 0
    else
      if @effects[PBEffects::LockOn] && @effects[PBEffects::LockOn]>0
        @effects[PBEffects::LockOn]=2
      else
        @effects[PBEffects::LockOn]=0
      end
      if @effects[PBEffects::PowerTrick]
        s=@attack
        @attack=@defense
        @defense=a
      end
    end
    @damagestate.reset
    @fainted        = false
    @lastAttacker   = []
    @lastHPLost     = 0
    @lastMoveUsed   = -1
    @lastMoveUsedType = -1
    @lastMoveUturn  = false
    @lastMoveCalled = 0
    @lastRoundMoved = -1
    @movesUsed      = []
    @turncount      = 0
    @effects[PBEffects::Attract]          = -1
    for i in 0..3
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::Attract]==@index
        @battle.battlers[i].effects[PBEffects::Attract]=-1
      end
    end
    @effects[PBEffects::AllySwitch]       = false
    @effects[PBEffects::AuraBlastCharges] = 0
    @effects[PBEffects::BatonPass]        = false
    @effects[PBEffects::Bide]             = 0
    @effects[PBEffects::BideDamage]       = 0
    @effects[PBEffects::BideTarget]       = -1
    @effects[PBEffects::BlazeBoost]       = false
    @effects[PBEffects::BurstMode]        = false
    @effects[PBEffects::Charge]           = 0
    @effects[PBEffects::ChoiceBand]       = -1
    @effects[PBEffects::Conversion2Move]  = 0
    @effects[PBEffects::Conversion2Type]  = 0
    @effects[PBEffects::Counter]          = -1
    @effects[PBEffects::CounterTarget]    = -1
    @effects[PBEffects::DefenseCurl]      = false
    @effects[PBEffects::DestinyBond]      = false
    @effects[PBEffects::Disable]          = 0
    @effects[PBEffects::Powder]           = false
    @effects[PBEffects::DisableMove]      = 0
    @effects[PBEffects::EchoedVoice]      = 0
    @effects[PBEffects::EjectTriggered]   = false
    @effects[PBEffects::Electrify]        = false
    @effects[PBEffects::Encore]           = 0
    @effects[PBEffects::EncoreIndex]      = 0
    @effects[PBEffects::EncoreMove]       = 0
    @effects[PBEffects::Endure]           = false
    @effects[PBEffects::FirstPledge]      = 0
    @effects[PBEffects::FlashFire]        = false
    @effects[PBEffects::Flinch]           = false
    @effects[PBEffects::FollowMe]         = 0
    @effects[PBEffects::Foresight]        = false
    @effects[PBEffects::ForestsCurse]     = false
    @effects[PBEffects::FuryCutter]       = 0
    @effects[PBEffects::Grudge]           = false
    @effects[PBEffects::HarvestActivated] = false
    @effects[PBEffects::HealBlock]        = 0
    @effects[PBEffects::HelpingHand]      = false
    @effects[PBEffects::HitSubstitute]    = false
    @effects[PBEffects::HyperBeam]        = 0
    @effects[PBEffects::Illusion]         = nil
    if self.hasWorkingAbility(:ILLUSION) #&& !@battle.switching
      lastpoke=@battle.pbGetLastPokeInTeam(@index)
      if lastpoke!=@pokemonIndex
        if !@battle.doublebattle || (@battle.doublebattle && @battle.pbParty(@index).length>2)
          @effects[PBEffects::Illusion]   = @battle.pbParty(@index)[lastpoke].clone
        end
      end
    end
    @effects[PBEffects::Imposter]         = false
    @effects[PBEffects::Imprison]         = false
    @effects[PBEffects::LerneanCounter]   = 0
    @effects[PBEffects::LerneanHeads]     = 0
    @effects[PBEffects::MagicCoat]        = false
    @effects[PBEffects::MeanLook]         = -1
    for i in 0..3
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::MeanLook]==@index
        @battle.battlers[i].effects[PBEffects::MeanLook]=-1
      end
    end
    @effects[PBEffects::Metronome]        = 0
    @effects[PBEffects::MetronomeCounter] = -1
    @effects[PBEffects::MicleBerry]       = false
    @effects[PBEffects::Pendulum]         = 0
    @effects[PBEffects::PendulumCounter]  = -1
    @effects[PBEffects::MeFirst]          = false
    @effects[PBEffects::Minimize]         = false
    @effects[PBEffects::MiracleEye]       = false
    @effects[PBEffects::MirrorCoat]       = -1
    @effects[PBEffects::MirrorCoatTarget] = -1
    @effects[PBEffects::MirrorMove]       = 0
    pbOpposing1.effects[PBEffects::MirrorMove]=0 if pbOpposing1
    pbOpposing2.effects[PBEffects::MirrorMove]=0 if pbOpposing2
    @effects[PBEffects::MoveNext]         = false
    @effects[PBEffects::MoveTypeChanged]  = false
    #@effects[PBEffects::MudSport]         = false
    @effects[PBEffects::MultiTurn]        = 0
    @effects[PBEffects::MultiTurnAttack]  = 0
    @effects[PBEffects::MultiTurnUser]    = -1

    for i in 0..3
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::MultiTurnUser]==@index
        @battle.battlers[i].effects[PBEffects::MultiTurn]=0
        @battle.battlers[i].effects[PBEffects::MultiTurnUser]=-1
      end
    end
    @effects[PBEffects::Nightmare]            = false
    @effects[PBEffects::OHKOFailed]           = false
    @effects[PBEffects::Outrage]              = 0
    @effects[PBEffects::ParentalBond]         = 0
    @effects[PBEffects::PickupUse]            = 0
    @effects[PBEffects::PickupItem]           = 0
    @effects[PBEffects::Pinch]                = false
    @effects[PBEffects::Protect]              = false
    @effects[PBEffects::KingsShield]          = false
    @effects[PBEffects::ProtectNegation]      = false
    @effects[PBEffects::ProtectRate]          = 1
    @effects[PBEffects::Pursuit]              = false
    @effects[PBEffects::Quash]                = false
    @effects[PBEffects::Rage]                 = false
    @effects[PBEffects::RagePowder]           = 0
    @effects[PBEffects::RedCardTriggered]     = false
    @effects[PBEffects::Revenge]              = 0
    @effects[PBEffects::Roar]                 = false
    @effects[PBEffects::Rollout]              = 0
    @effects[PBEffects::Roost]                = false
    @effects[PBEffects::SkipTurn]             = false
    @effects[PBEffects::SkyDrop]              = false
    @effects[PBEffects::SkyDropPartnerPos]    = -1
    @effects[PBEffects::SpiritAway]           = false
    @effects[PBEffects::SpiritAwayPartnerPos] = -1    
    @effects[PBEffects::SmackDown]            = false
    @effects[PBEffects::Snatch]               = false
    @effects[PBEffects::SpikyShield]          = false
    @effects[PBEffects::Stockpile]            = 0
    @effects[PBEffects::StockpileDef]         = 0
    @effects[PBEffects::StockpileSpDef]       = 0
    @effects[PBEffects::SymbiosisTriggered]   = false
    @effects[PBEffects::SynergyBurst]         = 0
    @effects[PBEffects::SynergyBurstDamage]   = 0
    @effects[PBEffects::Taunt]                = 0
    @effects[PBEffects::Torment]              = false
    @effects[PBEffects::Toxic]                = 0
    @effects[PBEffects::Trace]                = false
    @effects[PBEffects::Transform]            = false
    @effects[PBEffects::TransformBaseExp]     = 0
    @effects[PBEffects::TrickOrTreat]         = false
    @effects[PBEffects::Truant]               = false
    @effects[PBEffects::TypeIdentified]       = false
    @effects[PBEffects::SuckerPunch]          = false
    @effects[PBEffects::TwoTurnAttack]        = 0
    @effects[PBEffects::Unburden]             = false
    @effects[PBEffects::Uproar]               = 0
    @effects[PBEffects::Uturn]                = false
    #@effects[PBEffects::WaterSport]           = false
    @effects[PBEffects::WeightChange]         = 0
    @effects[PBEffects::Yawn]                 = 0
    @effects[PBEffects::MeloettaBackup]       = 0
    @effects[PBEffects::CorruptLife]          = 0
    @effects[PBEffects::MeloettaForme]        = 0
    @effects[PBEffects::Belch]                = 0
    @effects[PBEffects::Infestation]          = 0
    @effects[PBEffects::Unleafed]             = 0
    @effects[PBEffects::Chlorofury]           = 0
    @effects[PBEffects::ChlorofuryBoost]      = 0
    #@effects[PBEffects::LastResort]    = [false,false,false,false]
  end

  def pbUpdate(fullchange=false)
    if @pokemon
      @pokemon.calcStats
      @level     = @pokemon.level
      @hp        = @pokemon.hp
      @totalhp   = @pokemon.totalhp
      @happiness = @pokemon.happiness
      if !@effects[PBEffects::Transform]
        @attack    = @pokemon.attack
        @defense   = @pokemon.defense
        @speed     = @pokemon.speed
        @spatk     = @pokemon.spatk
        @spdef     = @pokemon.spdef
        if fullchange
          @ability = @pokemon.ability
          @type1   = @pokemon.type1
          @type2   = @pokemon.type2
        end
      end
    end
  end

  def pbInitialize(pkmn,index,batonpass)
    # Cure status of previous Pokemon with Natural Cure
    if @hp>0 && @pokemon && self.hasWorkingAbility(:NATURALCURE)
      self.status=0
    end
    if @hp>0 && @pokemon && self.hasWorkingAbility(:REGENERATOR)
      self.pbRecoverHP((totalhp/3).floor)
    end
    pbInitPokemon(pkmn,index)
    pbInitEffects(batonpass)
  end

  # Used only to erase the battler of a Shadow Pokémon that has been snagged.
  def pbReset
    @pokemon                = nil
    self.hp                 = 0
    pbInitEffects(false)
    # reset status
    self.status             = 0
    self.statusCount        = 0
    @fainted                = true
    # reset choice
    @battle.choices[@index] = [0,0,nil,-1]
    return true
  end

# Update Pokémon who will gain EXP if this battler is defeated
  def pbUpdateParticipants
    return if hp<=0 # can't update if already fainted
    if @battle.pbIsOpposing?(@index)
      found1=false
      found2=false
      for i in @participants
        found1=true if i==pbOpposing1.pokemonIndex
        found2=true if i==pbOpposing2.pokemonIndex
      end
      if !found1 && pbOpposing1.hp>0
        @participants[@participants.length]=pbOpposing1.pokemonIndex
      end
      if !found2 && pbOpposing2.hp>0
        @participants[@participants.length]=pbOpposing2.pokemonIndex
      end
    end
  end



################################################################################
# About this battler
################################################################################
  def fainted?
    return @hp<=0
  end

  def pbThis(lowercase=false,forcename=nil)
    if @effects[PBEffects::Illusion]
      pokename=@effects[PBEffects::Illusion].name.clone
    else
      pokename=@name.clone
    end
    #pokename=@name.clone
    
   # pokename=forcename if forcename
    if @battle.pbIsOpposing?(@index)
      if @battle.opponent
        #pokename = $illusionnames[@index] if $illusion != nil && $illusionnames != nil && $illusionnames[@index] != nil && $illusion[@index] != nil
        return lowercase ? _INTL("the foe {1}",pokename) : _INTL("The foe {1}",pokename)
      else
        return lowercase ? _INTL("the wild {1}",pokename) : _INTL("The wild {1}",pokename)
      end
    elsif @battle.pbOwnedByPlayer?(@index)
      return _INTL("{1}",pokename)
    else
      return lowercase ? _INTL("the ally {1}",pokename) : _INTL("The ally {1}",pokename)
    end
  end

  def pbHasType?(type)
    if type.is_a?(Symbol) || type.is_a?(String)
      ret=isConst?(self.type1,PBTypes,type.to_sym) ||
         isConst?(self.type2,PBTypes,type.to_sym)
      ret=self.effects[PBEffects::TrickOrTreat] if isConst?(PBTypes::GHOST,PBTypes,type.to_sym) && self.effects[PBEffects::TrickOrTreat]
      ret=self.effects[PBEffects::ForestsCurse] if isConst?(PBTypes::GRASS,PBTypes,type.to_sym) && self.effects[PBEffects::ForestsCurse]
      ret=true if self.hasWorkingAbility(:OMNITYPE)
      return ret
    else
      return (self.type1==type||self.type2==type)
    end
  end
  
  def pbHasMove?(id)
    if id.is_a?(String) || id.is_a?(Symbol)
      id = getID(PBMoves,id)
    end
    return false if !id || id==0
    for i in @moves
      return true if i.id==id
    end
    return false
  end

  def pbHasMoveType?(type)
    if type.is_a?(String) || type.is_a?(Symbol)
      type = getConst(PBTypes,type)
    end
    return false if type==nil || type<0
    for i in @moves
      return true if i.type==type
    end
    return false
  end
  
  def pbHasMoveFunction?(code)
    return false if !code
    for i in @moves
      return true if i.function==code
    end
    return false
  end
  
  def pbHasStatusMove?
    statusArray=[
      0x03,
      0x04,
      0x05,
      0x06,
      0x07,
      0x0A,
      0x149
    ]
    for i in @moves
      return true if statusArray.include?(i.function)
    end
    return false
  end
  
  def pbHasSleepMove?
    statusArray=[
      0x03,
      0x04
    ]
    for i in @moves
      return true if statusArray.include?(i.function)
    end
    return false
  end
  
  def hasMovedThisRound?
    return false if !@lastRoundMoved
    return @lastRoundMoved==@battle.turncount
  end
  
  def hasWorkingItem(item,ignorefainted=false)
    return false if fainted? && !ignorefainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.field.effects[PBEffects::MagicRoom]>0
    return false if self.hasWorkingAbility(:KLUTZ,ignorefainted)
    return isConst?(@item,PBItems,item)
  end
  
  def isAirborne?(ignoreability=false)
    return false if self.hasWorkingItem(:IRONBALL)
    return false if @effects[PBEffects::Ingrain]
    return false if @effects[PBEffects::SmackDown]
    return false if @battle.field.effects[PBEffects::Gravity]>0
    return true if self.pbHasType?(:FLYING) && !@effects[PBEffects::Roost]
    return true if self.hasWorkingAbility(:LEVITATE) && !ignoreability
    return true if self.hasWorkingAbility(:OMNITYPE) && !ignoreability
    return true if self.hasWorkingItem(:AIRBALLOON)
    return true if @effects[PBEffects::MagnetRise]>0
    return true if @effects[PBEffects::Telekinesis]>0
    return false
  end
  
  def isInvulnerable?
    return true if isConst?(self.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE)
    return true if isConst?(self.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG)
    return true if isConst?(self.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
    return true if isConst?(self.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY)
    return true if isConst?(self.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE)
    return true if isConst?(self.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE)
    return true if isConst?(self.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP)
    return true if isConst?(self.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY)
    return false
  end
    
  def hasMoldBreaker
    return true if hasWorkingAbility(:MOLDBREAKER) ||
                   hasWorkingAbility(:TERAVOLT) ||
                   hasWorkingAbility(:TURBOBLAZE)
    return false
  end
  
  def hasWorkingAbility(ability,ignorefainted=false)
    return false if fainted? && !ignorefainted
    return false if @effects[PBEffects::GastroAcid]
    return isConst?(self.ability,PBAbilities,ability)
  end
  
  def canEscape?(attacker,opponent)
    return false if opponent.pbNonActivePokemonCount()==0
    return true if opponent.hasWorkingItem(:SHEDSHELL)
    return true if opponent.pbHasType?(:GHOST)
    if opponent.effects[PBEffects::MultiTurn]>0 || opponent.effects[PBEffects::MeanLook]>=0
      return false
    end
    if @battle.field.effects[PBEffects::FairyLock]>0
      return false
    end
    if opponent.effects[PBEffects::Ingrain]
      return false
    end
    if opponent.pbHasType?(:STEEL)
      return false if attacker.hasWorkingAbility(:MAGNETPULL) ||
                      attacker.pbPartner.hasWorkingAbility(:MAGNETPULL)
    end
    if !opponent.isAirborne?
      return false if attacker.hasWorkingAbility(:ARENATRAP) ||
                      attacker.pbPartner.hasWorkingAbility(:ARENATRAP)
    end
    if !opponent.hasWorkingAbility(:SHADOWTAG)
      return false if attacker.hasWorkingAbility(:SHADOWTAG)
                      attacker.pbPartner.hasWorkingAbility(:SHADOWTAG)
    end
    return true
  end
  
  def pbSkyDropReset
    skipForFutureSight=false
    for i in 0..3
      if self.pokemonIndex==@battle.battlers[i].effects[PBEffects::FutureSightUser]
        if @battle.battlers[i].effects[PBEffects::FutureSight]==0
          skipForFutureSight=true
          break
        end
      end
    end
    if !skipForFutureSight
      if self.effects[PBEffects::SkyDropPartnerPos]!=-1
        partnerNum=self.effects[PBEffects::SkyDropPartnerPos]
        @battle.scene.pbShowSprites(self.index) #if !self.fainted?
        @battle.scene.pbShowSprites(partnerNum) #if !@battle.battlers[partnerNum].fainted?
        @battle.battlers[partnerNum].effects[PBEffects::TwoTurnAttack]=0
        @battle.battlers[partnerNum].effects[PBEffects::SkyDrop]=false
        self.effects[PBEffects::TwoTurnAttack]=0
        self.effects[PBEffects::SkyDrop]=false
        @battle.battlers[partnerNum].effects[PBEffects::SkyDropPartnerPos]=-1
        self.effects[PBEffects::SkyDropPartnerPos]=-1
      end
      if self.effects[PBEffects::SpiritAwayPartnerPos]!=-1
        partnerNum=self.effects[PBEffects::SpiritAwayPartnerPos]
        @battle.scene.pbShowSprites(self.index) #if !self.fainted?
        @battle.scene.pbShowSprites(partnerNum) #if !@battle.battlers[partnerNum].fainted?
        @battle.battlers[partnerNum].effects[PBEffects::TwoTurnAttack]=0
        @battle.battlers[partnerNum].effects[PBEffects::SpiritAway]=false
        self.effects[PBEffects::TwoTurnAttack]=0
        self.effects[PBEffects::SpiritAway]=false
        @battle.battlers[partnerNum].effects[PBEffects::SpiritAwayPartnerPos]=-1
        self.effects[PBEffects::SpiritAwayPartnerPos]=-1
      end
    end
  end

  def pbSpeed()
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    speed=@speed
    stage=@stages[PBStats::SPEED]+6
    speed=(speed*stagemul[stage]/stagediv[stage]).floor
    if self.pbOwnSide.effects[PBEffects::Tailwind] > 0
      speed=speed*2
    end
    if self.pbOwnSide.effects[PBEffects::Swamp]>0
      speed=(speed/4).round
    end
    case @battle.pbWeather
    when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
      speed=speed*2 if self.hasWorkingAbility(:SWIFTSWIM)
    #if isConst?(self.ability,PBAbilities,:SWIFTSWIM) &&
    #   @battle.pbWeather==PBWeather::RAINDANCE
    #  speed=speed*2
    #end
    when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
      speed=speed*2 if self.hasWorkingAbility(:CHLOROPHYLL)
    #if isConst?(self.ability,PBAbilities,:CHLOROPHYLL) &&
    #   @battle.pbWeather==PBWeather::SUNNYDAY
    #  speed=speed*2
    #end
    when PBWeather::NEWMOON
      speed=speed*2 if self.hasWorkingAbility(:SHADOWDANCE)
    #if isConst?(self.ability,PBAbilities,:SHADOWDANCE) &&
    #   @battle.pbWeather==PBWeather::NEWMOON
    #  speed=speed*2
    #end
    when PBWeather::HAIL
      speed=speed*2 if self.hasWorkingAbility(:ICECLEATS)
    #if isConst?(self.ability,PBAbilities,:ICECLEATS) &&
    #   @battle.pbWeather==PBWeather::HAIL
    #  speed=speed*2
    #end
    when PBWeather::SANDSTORM
      speed=speed*2 if self.hasWorkingAbility(:SANDRUSH)
    end
    #if isConst?(self.ability,PBAbilities,:SANDRUSH) &&
    #   @battle.pbWeather==PBWeather::SANDSTORM
    #  speed=speed*2
    #end
    #if self.hasWorkingAbility(:STALL)
    #    speed = 0
    #end
    #if isConst?(self.item,PBItems,:LAGGINGTAIL)
    #    speed = 0
    #end
    if self.effects[PBEffects::BurstMode]
      speed=(speed*1.1).round
    end
    if self.hasWorkingAbility(:QUICKFEET) && self.status>0
      speed=(speed*1.5).round
    end
    if self.hasWorkingAbility(:UNBURDEN) && @effects[PBEffects::Unburden] &&
      self.item==0
      speed=speed*2
    end
    if isConst?(@item,PBItems,:MACHOBRACE) ||
       isConst?(@item,PBItems,:POWERWEIGHT) ||
       isConst?(@item,PBItems,:POWERBRACER) ||
       isConst?(@item,PBItems,:POWERBELT) ||
       isConst?(@item,PBItems,:POWERANKLET) ||
       isConst?(@item,PBItems,:POWERLENS) ||
       isConst?(@item,PBItems,:POWERBAND)
      speed=(speed/2).round
    end
    if isConst?(@item,PBItems,:CHOICESCARF)
      speed=(speed*1.5).round
    end
    if isConst?(self.item(true),PBItems,:IRONBALL)
      speed=(speed/2).round
    end
    if (isConst?(self.species,PBSpecies,:DITTO) || isConst?(self.species,PBSpecies,:DELTADITTO)) && 
       !@effects[PBEffects::Transform] && isConst?(@item,PBItems,:QUICKPOWDER)
      speed=speed*2
    end
    if self.hasWorkingAbility(:SLOWSTART) && self.turncount<5
      speed=(speed/2).round
    end
    if self.status==PBStatuses::PARALYSIS && !self.hasWorkingAbility(:QUICKFEET)
      speed=(speed/4).round
    end
    #if @battle.internalbattle && @battle.pbOwnedByPlayer?(@index)
    #  speed=(speed*1.1).floor if @battle.pbPlayer.numbadges>=BADGESBOOSTSPEED
    #end
    
    return [speed,1].max
  end



################################################################################
# Change HP
################################################################################
  def pbReduceHP(amt)
  #  Kernel.pbMessage(amt.to_s)
  #  Kernel.pbMessage(self.hp.to_s)
    if amt>=self.hp
      amt=self.hp
    elsif amt<=0 && self.hp!=0
      amt=1
    end
   #     Kernel.pbMessage(amt.to_s)
   # Kernel.pbMessage(self.hp.to_s)

    oldhp=self.hp
    self.hp-=amt
    self.hp = 0 if self.hp==0.5
    raise _INTL("HP less than 0") if self.hp<0
    raise _INTL("HP greater than total HP") if self.hp>@totalhp
    @battle.scene.pbHPChanged(self,oldhp) if amt>0
    return amt
  end

  def pbRecoverHP(amt)
    if self.hp+amt>@totalhp
      amt=@totalhp-self.hp
    elsif amt<=0 && self.hp!=@totalhp
      amt=1
    end
    oldhp=self.hp
    self.hp+=amt
    raise _INTL("HP less than 0") if self.hp<0
    raise _INTL("HP greater than total HP") if self.hp>@totalhp
    @battle.scene.pbHPChanged(self,oldhp) if amt>0
    return amt
  end

  def pbFaint(showMessage=true,meloetta=false)
    #     @battle.pbDisplayPaused("check0" + PBSpecies.getName(self.species)+" "+self.hp.to_s)
    pbSkyDropReset
    if self.effects[PBEffects::MeloettaForme] != nil && self.effects[PBEffects::MeloettaForme] != 0
      @battle.pbParty(pbOpposing1.index)[@battle.pbParty(pbOpposing1.index).length-1]=self.effects[PBEffects::MeloettaForme].pokemon
      self.effects[PBEffects::MeloettaForme]=nil
    end
    #          @battle.pbDisplay("check1" + self.hp.to_s)
    if self.hp>0
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return true
    end
    if @fainted
      #      PBDebug.log("!!!***Can't faint if already fainted")
      return true
    end
           #   @battle.pbDisplay("check2 " + self.hp.to_s)
    #if pbNonActivePokemonCount != 0
      #if (isConst?(@ability,PBAbilities,:ILLUSION) || @species==PBSpecies::ZOROARK)# && @hp>0
      #  if $illusion[@index] != nil || (@species==PBSpecies::ZOROARK && @form!=0)
      #    if !@saidIllu
      #      @battle.pbDisplay("The Illusion was broken!")
      #      @saidIllu=true
      #    end
      #  
      #    if @isMZO
      #      @pokemon.form=1
      #      @isMZO=false
      #    end
      #    if !@saidIllu
      #      @battle.scene.pbTrainerSendOut(@index,@pokemon,true) if !@battle.pbOwnedByPlayer?(@index)
      #      @battle.scene.pbSendOut(@index,@pokemon,true) if @battle.pbOwnedByPlayer?(@index)
      #    end
      #    $illusion[@index]=nil
      #  end
      #end
    #end
    @battle.scene.pbFainted(self)
    pbInitEffects(false)
    if Kernel.pbGetMegaSpeciesStoneWorks(@species,@item)
      if(isConst?(@pokemon.species,PBSpecies,:GARDEVOIR) && (@form==3 || @form==2)) ||
        (isConst?(@pokemon.species,PBSpecies,:LUCARIO) && (@form==3 || @form==2))
        @form=2
        @pokemon.form=2
      elsif (isConst?(@pokemon.species,PBSpecies,:MEWTWO) && (@form==4 || @form==5))
        @form=4
        @pokemon.form=4
        @pokemon.shadowMegaMewtwo(false)
      else
        @form=0
        @pokemon.form=0
        @pokemon.megaFlygon(false) if @pokemon.species==PBSpecies::FLYGON
        @pokemon.megaTyranitar(false) if @pokemon.species==PBSpecies::TYRANITAR
        @pokemon.normalMegaMewtwoX(false) if @pokemon.species==PBSpecies::MEWTWO
        @pokemon.normalMegaMewtwoY(false) if @pokemon.species==PBSpecies::MEWTWO
      end
    end
    if @pokemon.species==PBSpecies::ZYGARDE
      @form=@pokemon.getZygardeForm
      @pokemon.form=@pokemon.getZygardeForm
    end
    self.status=0
    self.statusCount=0
    if @pokemon && @battle.internalbattle
      @pokemon.changeHappiness("faint")
    end
    @fainted=true
    # reset choice
    @battle.choices[@index]=[0,0,nil,-1]
    pbOwnSide.effects[PBEffects::LastRoundFainted]=@battle.turncount
    @battle.pbDisplayPaused(_INTL("{1} fainted!",pbThis)) if showMessage
    return true
  end

  def pbFasterThen?(battler2)
      #TODO
      #aryOfChanges=[0.25,0.29,0.33,0.4,0.5,0.66,1,1.5,2,2.5,3,3.5,4]
      #speed1=@speed
      #speed2=battler2.speed
      #speed1 *= aryOfChanges[@stages[PBStats::SPEED]]
      #speed2 *= aryOfChanges[battler2.stages[PBStats::SPEED]]
      #speed1 *= 1.5 if self.item==PBItems::CHOICESCARF
      #speed2 *= 1.5 if battler2.item==PBItems::CHOICESCARF
      
      return pbSpeed>battler2.pbSpeed
    
  end
  

################################################################################
# Find other battlers/sides in relation to this battler
################################################################################
# Returns the data structure for this battler's side
  def pbOwnSide
    return @battle.sides[@index&1] # Player: 0 and 2; Foe: 1 and 3
  end

# Returns the data structure for the opposing Pokémon's side
  def pbOpposingSide
    return @battle.sides[(@index&1)^1] # Player: 1 and 3; Foe: 0 and 2
  end

# Returns whether the position belongs to the opposing Pokémon's side
  def pbIsOpposing?(i)
    return (@index&1)!=(i&1)
  end

# Returns the battler's partner
  def pbPartner
    return @battle.battlers[(@index&1)|((@index&2)^2)]
  end

# Returns the battler's first opposing Pokémon
  def pbOpposing1
    return @battle.battlers[((@index&1)^1)]
  end

# Returns the battler's second opposing Pokémon
  def pbOpposing2
    return @battle.battlers[((@index&1)^1)+2]
  end

  def pbOppositeOpposing
    return @battle.battlers[(@index^1)]
  end

  def pbOppositeOpposing2
    return @battle.battlers[(@index^1)|((@index&2)^2)]
  end

  def pbNonActivePokemonCount()
    count=0
    party=@battle.pbParty(self.index)
    for i in 0...party.length
      if (self.hp<=0 || i!=self.pokemonIndex) &&
         (self.pbPartner.hp<=0 || i!=self.pbPartner.pokemonIndex) &&
         party[i] && !party[i].egg? && party[i].hp>0
        count+=1
      end
    end
    return count
  end



################################################################################
# Forms
################################################################################
  def pbCheckForm(zoroarkopp=false)
    return if @effects[PBEffects::Transform]
    transformed=false
    # Forecast
    if self.hasWorkingAbility(:FORECAST) &&
       isConst?(self.species,PBSpecies,:CASTFORM) && hp>0
      case @battle.pbWeather
        when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
          if self.form!=1
            self.form=1
            transformed=true
          end
        when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
          if self.form!=2
            self.form=2
            transformed=true
          end
        when PBWeather::HAIL
          if self.form!=3
            self.form=3
            transformed=true
          end
        when PBWeather::NEWMOON
          if self.form!=4
            self.form=4
            transformed=true
          end
        when PBWeather::SANDSTORM
          if self.form!=5
            self.form=5
            transformed=true
          end
        else
          if self.form!=0
            self.form=0
            transformed=true
          end
      end
      showmessage=transformed
    end
    # Cherrim
    if isConst?(self.species,PBSpecies,:CHERRIM) && hp>0
      if self.hasWorkingAbility(:FLOWERGIFT) && 
        (@battle.pbWeather==PBWeather::SUNNYDAY || 
        @battle.pbWeather==PBWeather::HARSHSUN)
       if self.form!=1
         self.form=1; transformed=true
       end
      else
       if self.form!=0
         self.form=0; transformed=true
       end
      end
    end
    # Delta Emolga
    if isConst?(self.species,PBSpecies,:DELTAEMOLGA) && hp>0
      if self.effects[PBEffects::BlazeBoost]
        if self.form!=1
          self.form=1; transformed=true
        end
      else
        if self.form!=0
          self.form=0; transformed=true
        end
      end
    end
    # Hydreigon
    if isConst?(self.species,PBSpecies,:HYDREIGON) && hp>0 && self.form>0
      if self.form!=pokemon.form
          self.form=@pokemon.form
          transformed=true
      end
    end
    if isConst?(self.species,PBSpecies,:HYDREIGON) && hp>0 && self.form>0
      if self.form!=@pokemon.form
          self.form=@pokemon.form
          transformed=true
      end
    end
    # Delta Typhlosion
    if isConst?(self.species,PBSpecies,:DELTATYPHLOSION) && hp>0
      if self.hasWorkingAbility(:SUPERCELL) && 
        (@battle.pbWeather==PBWeather::NEWMOON || 
        @battle.pbWeather==PBWeather::RAINDANCE ||
        @battle.pbWeather==PBWeather::HEAVYRAIN)
        if self.form==1
          self.form=2; transformed=true
        end
      else
        if self.form==2
          self.form=1; transformed=true
        end
      end
    end
    # Shaymin
    if isConst?(self.species,PBSpecies,:SHAYMIN) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Giratina
    if isConst?(self.species,PBSpecies,:GIRATINA) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Meloetta
    if isConst?(self.species,PBSpecies,:MELOETTA) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Protean
    if self.hasWorkingAbility(:PROTEAN) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Color Change
    if self.hasWorkingAbility(:COLORCHANGE) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Aegislash
    if isConst?(self.species,PBSpecies,:AEGISLASH) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Delta Emolga
    if isConst?(self.species,PBSpecies,:DELTAEMOLGA) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Delta Meloetta
    if isConst?(self.species,PBSpecies,:DELTAMELOETTA) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Mega/Primal Evolutions
    poke=self
    megaChange=false
    if (Kernel.pbGetMegaSpeciesList.include?(self.species) ||
       self.species==PBSpecies::KYOGRE ||
       self.species==PBSpecies::REGIGIGAS ||
       self.species==PBSpecies::ARCEUS ||
       self.species==PBSpecies::GIRATINA ||
       self.species==PBSpecies::GROUDON) && hp>0
      if Kernel.pbGetMegaSpeciesList.include?(self.species)
        megaChange=true
      end
      if self.form!=@pokemon.form && !@effects[PBEffects::Illusion]
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Arceus
    if self.hasWorkingAbility(:MULTITYPE) &&
       isConst?(self.species,PBSpecies,:ARCEUS) && hp>0
       if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
       end
    end
    # Zen Mode
    if isConst?(self.species,PBSpecies,:DARMANITAN) && hp>0
      if self.hasWorkingAbility(:ZENMODE)
        if @hp<=((@totalhp/2).floor)
          if self.form!=1
            self.form=1; transformed=true
          end
        else
          if self.form!=0
            self.form=0; transformed=true
          end
        end
      else
        if self.form!=0
          self.form=0; transformed=true
        end
      end
    end
    # Power Construct
    if isConst?(self.species,PBSpecies,:ZYGARDE) && hp>0
      if self.hasWorkingAbility(:POWERCONSTRUCT)
        if @hp<=((@totalhp/2).floor)
          if self.form!=2
            @pokemon.zygardeForm(self.form)
            Kernel.pbMessage("You sense the presence of many!")
            self.form=2; transformed=true
          end
        end
      end
    end
    # Keldeo
    if isConst?(self.species,PBSpecies,:KELDEO) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Genesect
    if isConst?(self.species,PBSpecies,:GENESECT) && hp>0
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    if transformed #&& !zoroarkopp
      pbUpdate(true)
      #if @isMZO &&   #zoroarkopp && $illusionpoke
        #exceptions, mewtwo flygon which are 2, all are 1
        #$illusionpoke.form=1
        #$illusionpoke.form=2 if $illusionpoke.species==PBSpecies::MEWTWO || $illusionpoke.species==PBSpecies::FLYGON
        #@battle.scene.pbChangePokemon(self,$illusionpoke) if zoroarkopp && Kernel.pbGetMegaSpeciesList.include?($illusionpoke.species)
        #$illusionpoke.form=0
      #elsif !zoroarkopp #|| !$illusionpoke || Kernel.pbGetMegaSpeciesList.include?($illusionpoke.species)
      @battle.scene.pbChangePokemon(self,@pokemon,false,nil,megaChange) #if !zoroarkopp
      @battle.pbDisplay(_INTL("{1} transformed!",pbThis)) #if !(@isMZO && Kernel.pbGetMegaSpeciesList.include?($illusionpoke.species)) && @pokemon.species!=PBSpecies::ZOROARK#!zoroarkopp #|| 
 #if !zoroarkopp
      #  end
      if self.effects[PBEffects::Substitute]>0
        @battle.scene.pbChangePokemon(self,self.pokemon,true)
      end
    end
  end

  def pbResetForm
    poke=self
    if !@effects[PBEffects::Transform]
      if isConst?(self.species,PBSpecies,:CASTFORM) ||
         isConst?(self.species,PBSpecies,:CHERRIM) ||
         isConst?(self.species,PBSpecies,:DARMANITAN) ||
         isConst?(self.species,PBSpecies,:AEGISLASH) ||
         isConst?(self.species,PBSpecies,:MELOETTA) ||
         isConst?(self.species,PBSpecies,:DELTAEMOLGA) ||
         isConst?(self.species,PBSpecies,:DELTAMELOETTA)
=begin
isConst?(self.species,PBSpecies,:VENUSAUR) ||
         isConst?(self.species,PBSpecies,:CHARIZARD) ||
         isConst?(self.species,PBSpecies,:CHARIZARD) ||
         isConst?(self.species,PBSpecies,:LATIOS) ||
         isConst?(self.species,PBSpecies,:LATIAS) ||
         isConst?(self.species,PBSpecies,:BLASTOISE) ||
    #     isConst?(self.species,PBSpecies,:MEWTWO) ||
         isConst?(self.species,PBSpecies,:SCIZOR) ||
                  isConst?(poke.species,PBSpecies,:MEDICHAM) ||
         isConst?(poke.species,PBSpecies,:GYARADOS) ||
         isConst?(poke.species,PBSpecies,:MANECTRIC) ||
         isConst?(poke.species,PBSpecies,:KANGASKHAN) ||
         isConst?(poke.species,PBSpecies,:HOUNDOOM) ||

         isConst?(self.species,PBSpecies,:GARCHOMP) ||
         isConst?(self.species,PBSpecies,:MAWILE) ||
                  isConst?(self.species,PBSpecies,:ALAKAZAM) ||
         isConst?(self.species,PBSpecies,:BANETTE) ||
         isConst?(poke.species,PBSpecies,:DELTABLASTOISE) ||
         isConst?(poke.species,PBSpec
         isConst?(self.species,PBSpecies,:LUCARIO) ||
                  isConst?(self.species,PBSpecies,:AMPHAROS) ||
                  isConst?(self.species,PBSpecies,:MAROWAK) ||
        isConst?(self.species,PBSpecies,:GENGAR) ||
         isConst?(self.species,PBSpecies,:ABSOL)
=end
        if !poke.effects[PBEffects::Roar] && !poke.effects[PBEffects::Uturn]
          if Kernel.pbGetMegaSpeciesList.include?(self.species)
            if(isConst?(self.species,PBSpecies,:GARDEVOIR) && (self.form==2 || self.form==3)) ||
              (isConst?(self.species,PBSpecies,:LUCARIO) && (self.form==2 || self.form==3))
              self.form=2
            elsif(isConst?(self.species,PBSpecies,:MEWTWO) && (self.form==4 || self.form==5))
              self.form=4
            elsif(isConst?(self.species,PBSpecies,:ZYGARDE))
              # Don't reset the form for Zygarde here
            else
              self.form=0
            end
          end
        end
      end      
    end
    pbUpdate(true)
  end

  #def effects()[arg=0]
  #    if arg = PBEffects::Taunt || PBEffects::Torment || PBEffects::Encore || PBEffects::Disable || PBEffects::HealBlock || PBEffects::Attract
  #       
  #      if pbPartner != nil && isConst?(pbPartner.ability,PBAbilities,:AROMAVEIL)
  #         ary = Array.new
  #         ary[arg] = 0
  #         return ary
  #       end
  #    end
  #    return @effects
  #end
  
  
################################################################################
# Ability effects
################################################################################
  def pbAbilitiesOnSwitchIn(onactive)
    return if hp<=0
    for i in 0..3
      if @battle.battlers[i].effects[PBEffects::Substitute]==0
        @battle.battlers[i].damagestate.substitute=false
      end
    end
    if pokemon.form==0 && isConst?(self.species,PBSpecies,:KYOGRE) && isConst?(self.item,PBItems,:BLUEORB)
      @battle.pbMegaEvolve(@index,true)
    end
    if pokemon.form==0 && isConst?(self.species,PBSpecies,:GROUDON) && isConst?(self.item,PBItems,:REDORB)
      @battle.pbMegaEvolve(@index,true)
    end
    if pokemon.form==0 && isConst?(self.species,PBSpecies,:ARCEUS) && isConst?(self.item,PBItems,:CRYSTALPIECE)
      @battle.pbMegaEvolve(@index,true)
    end
    #if pokemon.form==0 && isConst?(self.species,PBSpecies,:DELTAMETAGROSS2) && isConst?(self.item,PBItems,:ITEMFINDER)
    #  @battle.pbMegaEvolve(@index,true)
    #end
    if pokemon.form<2 && isConst?(self.species,PBSpecies,:GIRATINA) && isConst?(self.item,PBItems,:CRYSTALPIECE)
      @battle.pbMegaEvolve(@index,true)
    end
    if pokemon.form==0 && isConst?(self.species,PBSpecies,:REGIGIGAS) && isConst?(self.item,PBItems,:CRYSTALPIECE)
      @battle.pbMegaEvolve(@index,true)
    end
    if isConst?(self.species,PBSpecies,:AEGISLASH) && onactive
      self.pokemon.form=0
      pbCheckForm
    end
    if isConst?(self.species,PBSpecies,:DELTAEMOLGA) && onactive
      self.pokemon.form=0
      pbCheckForm
    end
    
    if self.hasWorkingAbility(:UNLEAFED) && onactive
      var=0
      for poke in @battle.pbParty(@index)
        var+=1 if poke.hp<1
      end
      if var>0
        self.pbIncreaseStatBasic(PBStats::SPEED,1)
        @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
        self.pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
        self.pbIncreaseStatBasic(PBStats::DEFENSE,1)
        @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
        self.pbIncreaseStatBasic(PBStats::SPATK,1)
        @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
        self.pbIncreaseStatBasic(PBStats::SPDEF,1)
        @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
        self.effects[PBEffects::Unleafed]=var+1
        self.pokemon.form += 2 if isConst?(self.species,PBSpecies,:SUNFLORA)
        self.pbCheckForm
        @battle.pbDisplay(_INTL("Enraged, {1} Unleafed its power!",self.pbThis))
      end
    end
    
    if self.hasWorkingAbility(:CHLOROFURY) && onactive
      var=0
      for poke in @battle.pbParty(@index)
        var+=1 if poke.hp<1
      end
      self.pbIncreaseStatBasic(PBStats::SPEED,1)
      @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
      @battle.pbDisplay(_INTL("Chlorofury boosts {1}'s Speed for 1 turn!",self.pbThis))
      if var>0
        self.pbIncreaseStatBasic(PBStats::SPATK,var)
        @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
        self.effects[PBEffects::Chlorofury]=2
        self.effects[PBEffects::ChlorofuryBoost]=var
        @battle.pbDisplay(_INTL("{1} becomes stronger for its fallen allies!",self.pbThis))
      end
    end    
    @battle.pbPrimordialWeather
    if onactive
      if self.hasWorkingAbility(:PRIMORDIALSEA) && @battle.weather!=PBWeather::HEAVYRAIN
        @battle.weather=PBWeather::HEAVYRAIN
        @battle.weatherduration=-1
        @battle.scene.pbBackdropMove(0,true,true)
        @battle.pbCommonAnimation("HeavyRain",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} made a heavy rain begin to fall!",pbThis,PBAbilities.getName(self.ability)))
      end
      if self.hasWorkingAbility(:DESOLATELAND) && @battle.weather!=PBWeather::HARSHSUN
        @battle.weather=PBWeather::HARSHSUN
        @battle.weatherduration=-1
        @battle.scene.pbBackdropMove(0,true,true)
        @battle.pbCommonAnimation("HarshSun",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} turned the sunlight extremely harsh!",pbThis,PBAbilities.getName(self.ability)))
      end
      if self.hasWorkingAbility(:DELTASTREAM) && @battle.weather!=PBWeather::STRONGWINDS
        @battle.weather=PBWeather::STRONGWINDS
        @battle.weatherduration=-1
        @battle.scene.pbBackdropMove(0,true,true)
        @battle.pbCommonAnimation("StrongWinds",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} caused a mysterious air current that protects Flying-type Pokémon!",pbThis,PBAbilities.getName(self.ability)))
      end
      if @battle.weather!=PBWeather::HEAVYRAIN &&
         @battle.weather!=PBWeather::HARSHSUN &&
         @battle.weather!=PBWeather::STRONGWINDS
        if self.hasWorkingAbility(:DRIZZLE) && (@battle.weather!=PBWeather::RAINDANCE) #|| @battle.weatherduration!=-1)
          @battle.weather=PBWeather::RAINDANCE
          @battle.weatherduration=5
          @battle.weatherduration=8 if hasWorkingItem(:DAMPROCK)
          @battle.scene.pbBackdropMove(0,true,true)
          @battle.pbDisplay(_INTL("{1}'s {2} made it rain!",pbThis,PBAbilities.getName(self.ability)))
        end
        if self.hasWorkingAbility(:DROUGHT) && (@battle.weather!=PBWeather::SUNNYDAY) #|| @battle.weatherduration!=-1)
          @battle.weather=PBWeather::SUNNYDAY
          @battle.weatherduration=5
          @battle.weatherduration=8 if hasWorkingItem(:HEATROCK)
          @battle.scene.pbBackdropMove(0,true,true)
          @battle.pbDisplay(_INTL("{1}'s {2} intensified the sun's rays!",pbThis,PBAbilities.getName(self.ability)))
        end
        if self.hasWorkingAbility(:SANDSTREAM) && (@battle.weather!=PBWeather::SANDSTORM) #|| @battle.weatherduration!=-1)
          @battle.weather=PBWeather::SANDSTORM
          @battle.weatherduration=5
          @battle.weatherduration=8 if hasWorkingItem(:SMOOTHROCK)
          @battle.scene.pbBackdropMove(0,true,true)
          @battle.pbDisplay(_INTL("{1}'s {2} whipped up a sandstorm!",pbThis,PBAbilities.getName(self.ability)))
        end
        if (self.hasWorkingAbility(:SNOWWARNING) || self.hasWorkingAbility(:SLEET)) && 
            (@battle.weather!=PBWeather::HAIL) #|| @battle.weatherduration!=-1)
          @battle.weather=PBWeather::HAIL
          @battle.weatherduration=5
          @battle.weatherduration=8 if hasWorkingItem(:ICYROCK)
          @battle.scene.pbBackdropMove(0,true,true)
          @battle.pbDisplay(_INTL("{1}'s {2} made it hail!",pbThis,PBAbilities.getName(self.ability))) if self.hasWorkingAbility(:SNOWWARNING)
          @battle.pbDisplay(_INTL("{1}'s {2} makes it hail harder than ever!",pbThis,PBAbilities.getName(self.ability))) if self.hasWorkingAbility(:SLEET)
        end
        if self.hasWorkingAbility(:NOCTEM) && (@battle.weather!=PBWeather::NEWMOON) #|| @battle.weatherduration!=-1)
          @battle.weather=PBWeather::NEWMOON
          @battle.weatherduration=5
          @battle.weatherduration=8 if hasWorkingItem(:DARKROCK)
          @battle.scene.pbBackdropMove(0,true,true)
          @battle.pbDisplay(_INTL("{1}'s {2} darkened the sky!",pbThis,PBAbilities.getName(self.ability)))
        end
      end
      if self.hasWorkingAbility(:AIRLOCK) || self.hasWorkingAbility(:CLOUDNINE)
        @battle.pbDisplay(_INTL("{1} has {2}!",pbThis,PBAbilities.getName(self.ability)))
        @battle.pbDisplay(_INTL("The effects of the weather disappeared."))
      end
      for i in 0...4
        if @battle.battlers[i].hasWorkingAbility(:SUPERCELL) && 
           isConst?(@battle.battlers[i].species,PBSpecies,:DELTATYPHLOSION) &&
           @battle.battlers[i].form==1 && !@battle.battlers[i].fainted?
          @battle.battlers[i].pbCheckForm
        end
      end
    end
    # Weather
    #if isConst?(ability,PBAbilities,:DRIZZLE) && onactive && !@battle.deltastream && !@battle.primordialsea && !@battle.desolateland
    #  @battle.weather=PBWeather::RAINDANCE
    #  @battle.weatherduration=5
    #  @battle.weatherduration=8 if isConst?(self.item,PBItems,:DAMPROCK)
    #  @battle.pbDisplay(_INTL("{1}'s Drizzle made it rain!",pbThis))
    #  @battle.scene.pbBackdropMove(0,true,true)
    #end
    if isConst?(ability,PBAbilities,:SPEEDSWAP) && onactive
      @battle.field.effects[PBEffects::TrickRoom]=5
      @battle.field.effects[PBEffects::TrickRoom]=8 if isConst?(self.item,PBItems,:TRICKROCK)
      @battle.pbDisplay(_INTL("{1}'s Speed Swap twisted the dimensions!",pbThis))
    end
    #if isConst?(ability,PBAbilities,:SANDSTREAM) && onactive && !@battle.deltastream && !@battle.primordialsea && !@battle.desolateland
    #  @battle.weather=PBWeather::SANDSTORM
    #  @battle.weatherduration=5
    #  @battle.weatherduration=8 if isConst?(self.item,PBItems,:SMOOTHROCK)
    #  @battle.pbDisplay(_INTL("{1}'s Sand Stream whipped up a sandstorm!",pbThis))
    #  @battle.scene.pbBackdropMove(0,true,true)
    #end
       
    #pbOwnSide.effects[PBEffects::AmuletCoin] = true
       
    #if isConst?(ability,PBAbilities,:DROUGHT) && onactive && !@battle.deltastream && !@battle.primordialsea && !@battle.desolateland
    #  @battle.weather=PBWeather::SUNNYDAY
    #  @battle.weatherduration=5
    #  @battle.weatherduration=8 if isConst?(self.item,PBItems,:HEATROCK)
    #  @battle.pbDisplay(_INTL("{1}'s Drought intensified the sun's rays!",pbThis))
    #  @battle.scene.pbBackdropMove(0,true,true)
    #end
     
    #if isConst?(ability,PBAbilities,:NOCTEM) && onactive && !@battle.deltastream && !@battle.primordialsea && !@battle.desolateland
    #  @battle.weather=PBWeather::NEWMOON
    #  @battle.weatherduration=5
    #  @battle.weatherduration=8 if isConst?(self.item,PBItems,:DARKROCK)
    #  @battle.pbDisplay(_INTL("{1}'s Noctem darkened the sky!",pbThis))
    #  @battle.scene.pbBackdropMove(0,true,true)
    #end

    #if (isConst?(ability,PBAbilities,:SNOWWARNING) || isConst?(ability,PBAbilities,:SLEET)) && onactive && !@battle.deltastream && !@battle.primordialsea && !@battle.desolateland
    #  @battle.weather=PBWeather::HAIL
    # @battle.weatherduration=5
    # @battle.weatherduration=8 if isConst?(self.item,PBItems,:ICYROCK)
    # @battle.pbDisplay(_INTL("{1}'s Snow Warning made it hail!",pbThis)) if isConst?(ability,PBAbilities,:SNOWWARNING)
    # @battle.pbDisplay(_INTL("{1}'s Sleet makes it hail harder than ever!",pbThis)) if isConst?(ability,PBAbilities,:SLEET)
    # @battle.scene.pbBackdropMove(0,true,true)
    #end
    #if isConst?(ability,PBAbilities,:AIRLOCK) && onactive
    #  @battle.pbDisplay(_INTL("{1} has Air Lock!",pbThis))
    #end
    #if isConst?(ability,PBAbilities,:CLOUDNINE) && onactive
    #  @battle.pbDisplay(_INTL("The effects of weather disappeared."))
    #end
    # Trace
    if isConst?(ability,PBAbilities,:TRACE)
      if onactive#@effects[PBEffects::Trace] || 
        choices=[]
        for i in 0..3
          if pbIsOpposing?(i) && @battle.battlers[i].hp>0
            choices[choices.length]=i if @battle.battlers[i].ability(true)!=0 &&
               !@battle.battlers[i].hasWorkingAbility(:MULTITYPE) &&
               !@battle.battlers[i].hasWorkingAbility(:TRACE) &&
               !@battle.battlers[i].hasWorkingAbility(:FORECAST) &&
               !@battle.battlers[i].hasWorkingAbility(:FLOWERGIFT) &&
               !@battle.battlers[i].hasWorkingAbility(:ILLUSION) &&
               !@battle.battlers[i].hasWorkingAbility(:ZENMODE) &&
               !@battle.battlers[i].hasWorkingAbility(:IMPOSTER) &&
               !@battle.battlers[i].hasWorkingAbility(:STANCECHANGE) &&
               !@battle.battlers[i].hasWorkingAbility(:POWERCONSTRUCT) &&
               !@battle.battlers[i].hasWorkingAbility(:LERNEAN)
          end
        end
        if choices.length==0
          @effects[PBEffects::Trace]=true
        else
          choice=choices[@battle.pbRandom(choices.length)]
          battlername=@battle.battlers[choice].pbThis(true)
          battlerability=@battle.battlers[choice].ability(true)
          @ability=battlerability
          abilityname=PBAbilities.getName(battlerability)
          if !@effects[PBEffects::Illusion] #@battle.pbOwnedByPlayer?(@index) && #|| $illusion == nil || !$illusion.is_a?(Array) || $illusion[@index] == nil
            @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!",pbThis,battlername,abilityname))
          end
          @effects[PBEffects::Trace]=false
        end
      end
    end
    # Intimidate
    if isConst?(ability,PBAbilities,:INTIMIDATE) && onactive
      for i in 0..3
        if pbIsOpposing?(i) && @battle.battlers[i].hp>0
          @battle.battlers[i].pbReduceAttackStatStageIntimidate(self)
        end
      end
    end
    if isConst?(item,PBItems,:AIRBALLOON) && onactive
      @battle.pbDisplay(_INTL("{1} floats with a balloon!",pbThis))
    end
    if isConst?(ability,PBAbilities,:MOLDBREAKER) && onactive
      @battle.pbDisplay(_INTL("{1} breaks the mold!",pbThis))
    end
    if isConst?(ability,PBAbilities,:TERAVOLT) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",pbThis))
    end
    if isConst?(ability,PBAbilities,:TURBOBLAZE) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",pbThis))
    end
    # Dark Aura message
    if self.hasWorkingAbility(:DARKAURA) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a dark aura!",pbThis))
    end
    # Fairy Aura message
    if self.hasWorkingAbility(:FAIRYAURA) && onactive
      @battle.pbDisplay(_INTL("{1} is radiating a fairy aura!",pbThis))
    end
    # Aura Break message
    if self.hasWorkingAbility(:AURABREAK) && onactive
      @battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",pbThis))
    end
    # Slow Start message
    if self.hasWorkingAbility(:SLOWSTART) && onactive
      @battle.pbDisplay(_INTL("{1} can't get it going because of its {2}!",
         pbThis,PBAbilities.getName(self.ability)))
    end
    # Pressure message
    if self.hasWorkingAbility(:PRESSURE) && onactive
      @battle.pbDisplay(_INTL("{1} is exerting its {2}!",
         pbThis,PBAbilities.getName(self.ability)))
    end
    # Download
    if isConst?(ability,PBAbilities,:DOWNLOAD) && onactive
      odef=ospdef=0
      odef+=pbOpposing1.defense if pbOpposing1.hp>0
      ospdef+=pbOpposing1.spdef if pbOpposing1.hp>0
      if pbOpposing2
        odef+=pbOpposing2.defense if pbOpposing2.hp>0
        ospdef+=pbOpposing1.spdef if pbOpposing2.hp>0
      end
      if ospdef>odef
        if !pbTooHigh?(PBStats::ATTACK)
          pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} boosted its Attack!",
             pbThis,PBAbilities.getName(ability)))
        end
      else
        if !pbTooHigh?(PBStats::SPATK)
          pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} boosted its Special Attack!",
             pbThis,PBAbilities.getName(ability)))
        end
      end
    end
    # Frisk
    if isConst?(ability,PBAbilities,:FRISK) && onactive #&& @battle.pbOwnedByPlayer?(@index)
      foes=[]
      foes.push(pbOpposing1) if pbOpposing1.item>0 && !pbOpposing1.fainted?
      foes.push(pbOpposing2) if pbOpposing2.item>0 && !pbOpposing2.fainted?
      if foes.length>0
        for i in foes
          itemname=PBItems.getName(i.item)
          @battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",pbThis,i.pbThis(true),itemname))
        end
      #elsif foes.length>0
      #  PBDebug.log("[Ability triggered] #{pbThis}'s Frisk")
      #  foe=foes[@battle.pbRandom(foes.length)]
      #  itemname=PBItems.getName(foe.item)
      #  @battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",pbThis,itemname))
      end
    end
      
      #items=[]
      #items.push(pbOpposing1.item(true)) if pbOpposing1.item(true)>0 && pbOpposing1.hp>0
      #items.push(pbOpposing2.item(true)) if pbOpposing2.item(true)>0 && pbOpposing2.hp>0
      #if items.length>0
      #  item=items[@battle.pbRandom(items.length)]
      #  itemname=PBItems.getName(item)
      #  @battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",pbThis,itemname))
      #end
    #end
    # Anticipation
    if isConst?(ability,PBAbilities,:ANTICIPATION) && @battle.pbOwnedByPlayer?(@index) && onactive
      found=false
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.hp<=0
        for j in foe.moves
          movedata=PBMoveData.new(j.id)
          eff=PBTypes.getCombinedEffectiveness(movedata.type,type1,type2)
          if eff>4 ||
             movedata.function==0xE0 || # Selfdestruct
             (movedata.function==0x70 && eff>0) # OHKO
            found=true
            break
          end
        end
        break if found
      end
      @battle.pbDisplay(_INTL("{1} shuddered with anticipation!",pbThis)) if found
    end

    
    # Forewarn

    if isConst?(ability,PBAbilities,:FOREWARN) && @battle.pbOwnedByPlayer?(@index) && onactive
      highpower=0
      moves=[]
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.hp<=0
        for j in foe.moves
          movedata=PBMoveData.new(j.id)
          power=movedata.basedamage
          power=160 if movedata.function==0x70    # OHKO
          power=150 if movedata.function==0x8B    # Eruption
          power=120 if movedata.function==0x71 || # Counter
                       movedata.function==0x72 || # Mirror Coat
                       movedata.function==0x73 || # Metal Burst
          power=80 if movedata.function==0x6A ||  # SonicBoom
                      movedata.function==0x6B ||  # Dragon Rage
                      movedata.function==0x6D ||  # Night Shade
                      movedata.function==0x6E ||  # Endeavor
                      movedata.function==0x6F ||  # Psywave
                      movedata.function==0x89 ||  # Return
                      movedata.function==0x8A ||  # Frustration
                      movedata.function==0x8C ||  # Crush Grip
                      movedata.function==0x8D ||  # Gyro Ball
                      movedata.function==0x90 ||  # Hidden Power
                      movedata.function==0x96 ||  # Natural Gift
                      movedata.function==0x97 ||  # Trump Card
                      movedata.function==0x98 ||  # Flail
                      movedata.function==0x9A     # Grass Knot
          if power>highpower
            moves=[j.id]; highpower=power
          elsif power==highpower
            moves.push(j.id)
          end
        end
      end
      if moves.length>0
        move=moves[@battle.pbRandom(moves.length)]
        movename=PBMoves.getName(move)
        @battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",pbThis,movename))
      end
    end
    # Imposter
    if self.hasWorkingAbility(:IMPOSTER) && !@effects[PBEffects::Transform] && onactive
      if @effects[PBEffects::Imposter] || onactive
        choice=pbOppositeOpposing
        if choice.effects[PBEffects::Substitute]>0 ||
           choice.effects[PBEffects::Transform] ||
           choice.effects[PBEffects::SkyDrop] ||
           choice.effects[PBEffects::SpiritAway] ||
           isConst?(choice.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
           isConst?(choice.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) ||
           isConst?(choice.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE) ||
           isConst?(choice.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
           isConst?(choice.effects[PBEffects::TwoTurnAttack],PBMoves,:HYPERSPACE) ||
           isConst?(choice.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
           isConst?(choice.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE) ||
           isConst?(choice.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
           isConst?(choice.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY) ||
           pbOppositeOpposing.effects[PBEffects::Illusion]
          @effects[PBEffects::Imposter]=true
        else
          speciesname=PBSpecies.getName(choice.species)
          @effects[PBEffects::Transform]=true
          #@species=choice.species
          @gender=choice.gender
          @form=choice.form
          @effects[PBEffects::WeightChange]+=choice.weight
          #@baseexp=choice.baseexp
          @effects[PBEffects::TransformBaseExp]=choice.pokemon.baseExp
          @type1=choice.type1
          @type2=choice.type2
          @ability=choice.ability(true)
          @attack=choice.attack
          @defense=choice.defense
          @speed=choice.speed
          @spatk=choice.spatk
          @spdef=choice.spdef
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                    PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
            @stages[i]=choice.stages[i]
          end
          @effects[PBEffects::FocusEnergy]=choice.effects[PBEffects::FocusEnergy]
          for i in 0..3
            @moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(choice.moves[i].id))
            @moves[i].pp=5
            @moves[i].totalpp=5
          end
          @effects[PBEffects::Disable]=0
          @effects[PBEffects::DisableMove]=0
          @battle.pbAnimation(getConst(PBMoves,:TRANSFORM),self,choice)
          @battle.pbDisplay(_INTL("{1} transformed into {2}!",pbThis,speciesname))
          @effects[PBEffects::Imposter]=false
          pbAbilitiesOnSwitchIn(@ability)
        end
      end
    end
    for i in 0..3
      if @battle.battlers[i].hp>0 && @battle.battlers[i].damagestate.substitute
        @battle.battlers[i].damagestate.substitute=false
      end
    end
  end
  
  def pbEffectsOnDealingDamage(move,user,target,damage)
    movetype=move.pbType(move.type,user,target)
    if damage>0 && move.isContactMove?
      if !target.damagestate.substitute
        if target.hasWorkingItem(:STICKYBARB,true) && user.item==0 && user.hp>0
          user.item=target.item
          target.item=0
          target.effects[PBEffects::Unburden]=true
          if !@battle.opponent && !@battle.pbIsOpposing?(user.index)
            if user.pokemon.itemInitial==0 && target.pokemon.itemInitial==user.item(true)
              user.pokemon.itemInitial=user.item(true)
              target.pokemon.itemInitial=0
            end
          end
          @battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
             target.pbThis,PBItems.getName(user.item),user.pbThis(true)))
           end
        if target.hasWorkingItem(:ROCKYHELMET,true) && user.hp>0
          if !user.hasWorkingAbility(:MAGICGUARD)
            user.pbReduceHP((user.totalhp/6).floor)
            @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
               PBItems.getName(target.item),user.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:AFTERMATH,true) && user.hp>0 && target.fainted?
          if !@battle.pbCheckGlobalAbility(:DAMP,true) && !user.hasMoldBreaker && !user.hasWorkingAbility(:MAGICGUARD)
            user.pbReduceHP((user.totalhp/4).floor)
            @battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
          end
        end
        if target.hasWorkingAbility(:CUTECHARM) && @battle.pbRandom(10)<3
          if !user.hasWorkingAbility(:OBLIVIOUS) &&
             ((user.gender==1 && target.gender==0) ||
             (user.gender==0 && target.gender==1)) &&
             user.effects[PBEffects::Attract]<0 && user.hp>0 && target.hp>0
            user.effects[PBEffects::Attract]=target.index
            @battle.pbDisplay(_INTL("{1}'s {2} infatuated {3}!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
            if user.hasWorkingItem(:DESTINYKNOT) && !target.hasWorkingAbility(:OBLIVIOUS) &&
               target.effects[PBEffects::Attract]<0
              target.effects[PBEffects::Attract]=user.index
              @battle.pbDisplay(_INTL("{1}'s {2} infatuated {3}!",user.pbThis,
                 PBItems.getName(user.item),target.pbThis(true)))
            end
          end
        end
        if target.hasWorkingAbility(:EFFECTSPORE,true) && @battle.pbRandom(10)<3
          if user.pbHasType?(:GRASS) || user.effects[PBEffects::ForestsCurse] || 
             user.hasWorkingAbility(:OVERCOAT) || user.hasWorkingAbility(:OMNITYPE) ||
             user.hasWorkingItem(:SAFETYGOGGLES)
             # Do nothing
          else
            rnd=@battle.pbRandom(3)
            if rnd==0 && user.pbCanPoison?(nil,false,nil,true)
              user.pbPoison(target)
              @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
                 PBAbilities.getName(target.ability),user.pbThis(true)))
            elsif rnd==1 && user.pbCanSleep?(nil,false,nil,false,true)
              user.pbSleep
              @battle.pbDisplay(_INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,
                 PBAbilities.getName(target.ability),user.pbThis(true)))
            elsif rnd==2 && user.pbCanParalyze?(nil,false,nil,true)
              user.pbParalyze(target)
              @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
                 target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
            end
          end
        end
        if target.hasWorkingAbility(:FLAMEBODY,true) && @battle.pbRandom(10)<3 && 
           user.pbCanBurn?(nil,false,nil,true)
          user.pbBurn(target)
          @battle.pbDisplay(_INTL("{1}'s {2} burned {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.effects[PBEffects::BlazeBoost] && target.hasWorkingAbility(:BLAZEBOOST,true) &&
           @battle.pbRandom(10)<1 && user.pbCanBurn?(nil,false)
          user.pbBurn(target)
          @battle.pbDisplay(_INTL("{1}'s {2} burned {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:MUMMY,true) && user.hp>0
          if !user.hasWorkingAbility(:MULTITYPE) &&
             !user.hasWorkingAbility(:ZENMODE) &&
             !user.hasWorkingAbility(:STANCECHANGE) &&
             !user.hasWorkingAbility(:MUMMY)
            user.ability=getConst(PBAbilities,:MUMMY) || 0
            @battle.pbDisplay(_INTL("{1} was mummified by {2}!",user.pbThis,target.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:POISONPOINT,true) && @battle.pbRandom(10)<3 && 
           user.pbCanPoison?(nil,false,nil,true)
          user.pbPoison(target)
          @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if (target.hasWorkingAbility(:ROUGHSKIN,true) || 
           target.hasWorkingAbility(:IRONBARBS,true)) && user.hp>0
          if !user.hasWorkingAbility(:MAGICGUARD)
            user.pbReduceHP((user.totalhp/8).floor)
            @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:EVENTHORIZON) && user.hp>0
          if user.effects[PBEffects::MeanLook]>=0 ||
             user.effects[PBEffects::Substitute]>0
            #  @battle.pbDisplay(_INTL("But it failed!"))
            #return -1
          else
            user.effects[PBEffects::MeanLook]=target.index
           # @battle.pbAnimation(@id,attacker,opponent)
            @battle.pbDisplay(_INTL("{1} cannot escape the Event Horizon!",user.pbThis))
          end
        end
        if target.hasWorkingAbility(:STATIC,true) && @battle.pbRandom(10)<3 &&
           user.pbCanParalyze?(nil,false,nil,true)
          user.pbParalyze(target)
          @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
             target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:GOOEY,true)
          if !target.pbTooLow?(PBStats::SPEED)
            user.pbReduceStatBasic(PBStats::SPEED,1)
            @battle.pbCommonAnimation("StatDown",user,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} lowered {3}'s Speed!",
               target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if user.hasWorkingAbility(:POISONTOUCH,true) &&
           @battle.pbRandom(10)<3 && target.pbCanPoison?(nil,false)
          target.pbPoison(user)
          @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",user.pbThis,
             PBAbilities.getName(user.ability),target.pbThis(true)))
        end
        if target.hasWorkingAbility(:GLITCH,true) && user.hp>0
           @battle.pbDisplay(_INTL("{1} was corrupted by {2}!",user.pbThis,target.pbThis(true)))
          user.hp=0
        end
      end
    end
    if damage>0
      if !target.damagestate.substitute
        if move.function==0x215 # Dynamic Fury
          if user.effects[PBEffects::SynergyBurst]>0
            user.effects[PBEffects::SynergyBurst]-=1
          end
        end
        if target.hasWorkingAbility(:CURSEDBODY,true) && @battle.pbRandom(10)<3
          if user.effects[PBEffects::Disable]<=0 && move.pp>0 && user.hp>0
            user.effects[PBEffects::Disable]=4+@battle.pbRandom(4)
            user.effects[PBEffects::DisableMove]=move.id
            @battle.pbDisplay(_INTL("{1}'s {2} disabled {3}!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:JUSTIFIED) && isConst?(movetype,PBTypes,:DARK)
          if !target.pbTooHigh?(PBStats::ATTACK)
            @battle.pbAnimation(@id,target,nil)
            target.pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s {2} raised its attack!",target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:RATTLED) &&
           (isConst?(movetype,PBTypes,:DARK) || isConst?(movetype,PBTypes,:BUG) ||
           isConst?(movetype,PBTypes,:GHOST))
          if !target.pbTooHigh?(PBStats::SPEED)
            @battle.pbAnimation(@id,target,nil)
            target.pbIncreaseStatBasic(PBStats::SPEED,1)
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!",target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:WEAKARMOR) && move.pbIsPhysical?(movetype) && target.hp>0
          if !target.pbTooLow?(PBStats::DEFENSE)
            @battle.pbAnimation(@id,target,nil)
            target.pbReduceStatBasic(PBStats::DEFENSE,1)
            @battle.pbCommonAnimation("StatDown",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s {2} lowered its Defense!",target.pbThis,PBAbilities.getName(target.ability)))
          end
          if !target.pbTooHigh?(PBStats::SPEED)
            @battle.pbAnimation(@id,target,nil)
            target.pbIncreaseStatBasic(PBStats::SPEED,1)
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:DIAMONDSKIN,true) && user.hp>0 && !move.isContactMove?
          if !user.hasWorkingAbility(:MAGICGUARD)
            user.pbReduceHP((user.totalhp/8).floor)
            @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
              PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if target.hasWorkingItem(:AIRBALLOON,true)
          @battle.pbDisplay(_INTL("{1}'s Air Balloon popped!",target.pbThis));
          target.pbConsumeItem(true,false)
        elsif target.hasWorkingItem(:ABSORBBULB) && isConst?(movetype,PBTypes,:WATER)
          if !target.pbTooHigh?(PBStats::SPATK)
            target.pbIncreaseStatBasic(PBStats::SPATK,1)
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!",target.pbThis,
               PBItems.getName(target.item)))
            target.pbConsumeItem
          end       
        elsif target.hasWorkingItem(:LUMINOUSMOSS) && isConst?(movetype,PBTypes,:WATER)
          if !target.pbTooHigh?(PBStats::SPDEF)
            target.pbIncreaseStatBasic(PBStats::SPDEF,1)
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Defense!",target.pbThis,
               PBItems.getName(target.item)))
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:CELLBATTERY) && isConst?(movetype,PBTypes,:ELECTRIC)
          if !target.pbTooHigh?(PBStats::ATTACK)
            target.pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",target.pbThis,
               PBItems.getName(target.item)))
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:SNOWBALL) && isConst?(movetype,PBTypes,:ICE)
          if !target.pbTooHigh?(PBStats::ATTACK)
            target.pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",target.pbThis,
               PBItems.getName(target.item)))
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:WEAKNESSPOLICY) && target.damagestate.typemod>4
          @battle.pbDisplay(_INTL("{1}'s Weakness Policy was activated!",target.pbThis));
          if !target.pbTooHigh?(PBStats::ATTACK)
            target.pbIncreaseStatBasic(PBStats::ATTACK,2)
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s Attack rose sharply!",target.pbThis))
          end
          if !target.pbTooHigh?(PBStats::SPATK)
            target.pbIncreaseStatBasic(PBStats::SPATK,2)
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s Special Attack rose sharply!",target.pbThis))
          end
          target.pbConsumeItem
        elsif target.hasWorkingItem(:ENIGMABERRY) && target.damagestate.typemod>4
          target.pbActivateBerryEffect
        elsif (target.hasWorkingItem(:JABOCABERRY,true) && move.pbIsPhysical?(movetype)) ||
              (target.hasWorkingItem(:ROWAPBERRY,true) && move.pbIsSpecial?(movetype))
          if !user.hasWorkingAbility(:MAGICGUARD) && !user.fainted?
            user.pbReduceHP((user.totalhp/8).floor)
            @battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
            PBItems.getName(target.item),user.pbThis(true)))
            target.pbConsumeItem
          end
        elsif target.hasWorkingItem(:KEEBERRY) && move.pbIsPhysical?(movetype)
          if !(user.hasWorkingAbility(:SHEERFORCE) && move.addlEffect>0)
            target.pbActivateBerryEffect
          end
        elsif target.hasWorkingItem(:MARANGABERRY) && move.pbIsSpecial?(movetype)
          Kernel.pbMessage("moo") if move.addlEffect>0
          if !(user.hasWorkingAbility(:SHEERFORCE) && move.addlEffect>0)
            target.pbActivateBerryEffect
          end
        end
        if target.hasWorkingAbility(:ANGERPOINT)
          if target.damagestate.critical && !target.damagestate.substitute && !target.pbTooHigh?(PBStats::ATTACK)
            target.stages[PBStats::ATTACK]=6
            @battle.pbCommonAnimation("StatUp",target,nil) if !target.isInvulnerable?
            @battle.pbDisplay(_INTL("{1}'s Anger Point maxed its Attack!",target.name))
          end
        end
      end
    end
    user.pbBerryCureCheck(true)
    target.pbBerryCureCheck(true)
  end
  
  def pbEffectsAfterHit(user,target,thismove,turneffects)
    return if turneffects[PBEffects::TotalDamage]==0
    onField=false
    for i in 0...4
      if user==@battle.battlers[i]
        onField=true
        break
      end
    end
    if target.effects[PBEffects::BurstMode]
      target.effects[PBEffects::BurstModeDamaged]=true
    end
    if thismove.function==0x214 # Fairy Tempest
      if user.effects[PBEffects::SynergyBurst]>0 && user.effects[PBEffects::SynergyBurst]<5
        user.effects[PBEffects::SynergyBurst]+=1
      end
      if target.effects[PBEffects::SynergyBurst]>0
        target.effects[PBEffects::SynergyBurst]-=1
      end
    end
    # Magician
    if user.hasWorkingAbility(:MAGICIAN)
      if target.item(true)>0 && user.item(true)==0 &&
         user.effects[PBEffects::Substitute]==0 &&
         target.effects[PBEffects::Substitute]==0 &&
         !target.hasWorkingAbility(:STICKYHOLD) &&
         !@battle.pbIsUnlosableItem(target,target.item(true)) &&
         !@battle.pbIsUnlosableItem(user,target.item(true)) &&
         (@battle.opponent || !@battle.pbIsOpposing?(user.index))
        user.item=target.item(true)
        target.item=0
        target.effects[PBEffects::Unburden]=true
        if !@battle.opponent &&   # In a wild battle
           user.pokemon.itemInitial==0 &&
           target.pokemon.itemInitial==user.item(true)
          user.pokemon.itemInitial=user.item(true)
          target.pokemon.itemInitial=0
        end
        @battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,
          target.pbThis(true),PBItems.getName(user.item(true)),PBAbilities.getName(user.ability)))
      end
    end
    if !(user.hasWorkingAbility(:SHEERFORCE) && thismove.addlEffect>0)
      # Target's held items:
      if thismove.function!=0x0EC || # Do not consume these items if Dragon Tail/Circle Throw is used
         (thismove.function==0x0EC && target.hasWorkingItem(:EJECTBUTTON) &&
         (target.hasWorkingAbility(:SUCTIONCUPS) || target.effects[PBEffects::Ingrain]))
        if target.effects[PBEffects::SkyDropPartnerPos]==-1 &&
           target.effects[PBEffects::SpiritAwayPartnerPos]==-1
          # Red Card
          if target.hasWorkingItem(:REDCARD) && @battle.pbCanChooseNonActive?(user.index)
            if @battle.opponent || @battle.pbOwnedByPlayer?(user.index)
              target.pbConsumeItem
              target.effects[PBEffects::RedCardTriggered]=true
            end
          # Eject Button
          elsif target.hasWorkingItem(:EJECTBUTTON) && @battle.pbCanChooseNonActive?(target.index) &&
                !target.effects[PBEffects::SymbiosisTriggered]
            if @battle.opponent || @battle.pbOwnedByPlayer?(target.index)
              target.effects[PBEffects::EjectTriggered]=true
            end
          end
        end
      end
      # Shell Bell
      if user.hasWorkingItem(:SHELLBELL) && user.effects[PBEffects::HealBlock]==0
        hpgain=user.pbRecoverHP((turneffects[PBEffects::TotalDamage]/8).floor)
        if hpgain>0
          @battle.pbDisplay(_INTL("{1}'s Shell Bell restored its HP a little!",user.pbThis))
        end
      end
      # Life Orb
      #if user.effects[PBEffects::LifeOrb] && !user.hasWorkingAbility(:MAGICGUARD)
      #  hploss=user.pbReduceHP((user.totalhp/10).floor,true)
      #  if hploss>0
      #    @battle.pbDisplay(_INTL("{1} lost some of its HP!",user.pbThis))
      #  end
      #end
    end
    # Pickpocket
    if target.hasWorkingAbility(:PICKPOCKET) && thismove.isContactMove? && target.hp>0
      if !(user.hasWorkingAbility(:SHEERFORCE) && thismove.addlEffect>0)
        if target.item(true)==0 && user.item(true)>0 &&
           user.effects[PBEffects::Substitute]==0 &&
           target.effects[PBEffects::Substitute]==0 &&
           !user.hasWorkingAbility(:STICKYHOLD) &&
           !@battle.pbIsUnlosableItem(user,user.item(true)) &&
           !@battle.pbIsUnlosableItem(target,user.item(true)) &&
           (@battle.opponent || !@battle.pbIsOpposing?(target.index))
          target.item=user.item(true)
          user.item=0
          user.effects[PBEffects::Unburden]=true
          if !@battle.opponent &&   # In a wild battle
             target.pokemon.itemInitial==0 &&
             user.pokemon.itemInitial==target.item(true)
            target.pokemon.itemInitial=target.item(true)
            user.pokemon.itemInitial=0
          end
          @battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
            user.pbThis(true),PBItems.getName(target.item(true))))
        end
      end
    end
    if user.hasWorkingAbility(:VAMPIRIC) && thismove.isContactMove? && 
       user.effects[PBEffects::HealBlock]==0
      hpgain=user.pbRecoverHP((turneffects[PBEffects::TotalDamage]/4).floor)
      if hpgain>0
        @battle.pbDisplay(_INTL("{1}'s Vampiric restored its HP a little!",user.pbThis))
      end
    end
    user.pbFaint if user.fainted? && onField # no return
    # Color Change
    movetype=thismove.pbType(thismove.type,user,target)
    if target.hasWorkingAbility(:COLORCHANGE) && !isConst?(thismove.id,PBMoves,:STRUGGLE) # Do not apply Color Change if Struggle is used
      if !(user.hasWorkingAbility(:SHEERFORCE) && thismove.addlEffect>0)
        if !PBTypes.isPseudoType?(movetype) && !target.pbHasType?(movetype)
        target.type1=movetype
        target.type2=movetype
        target.effects[PBEffects::ForestsCurse]=false
        target.effects[PBEffects::TrickOrTreat]=false
        if target.species==PBSpecies::ARCEUS && target.form==19
          # Skip form changing if the target is Primal Arceus
        elsif [PBSpecies::KECLEON,PBSpecies::ARCEUS,PBSpecies::FROAKIE,PBSpecies::FROGADIER,PBSpecies::GRENINJA,PBSpecies::DELTADITTO].include?(target.species)
          if movetype==21
            target.form=18
          elsif movetype==20 && target.species==PBSpecies::KECLEON
            target.form=19
          else
            target.form=movetype
          end
          target.form+=1 if [PBSpecies::FROAKIE,PBSpecies::FROGADIER,PBSpecies::GRENINJA].include?(target.species)
          @battle.scene.pbChangePokemon(target,target.pokemon)
        end
        @battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis(false),
           PBAbilities.getName(target.ability),PBTypes.getName(movetype)))
        end
      end
    end
    # Moxie/Hubris
    if target.fainted?
      if user.hasWorkingAbility(:MOXIE)
        if !pbTooHigh?(PBStats::ATTACK)
          user.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",user,self)
          @battle.pbDisplay(_INTL("{1}'s Moxie increased its Attack!",user.pbThis))
        end
      elsif user.hasWorkingAbility(:HUBRIS)
        if !pbTooHigh?(PBStats::SPATK)
          user.pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",user,self)
          @battle.pbDisplay(_INTL("{1}'s Hubris boosted its Sp. Atk!",user.pbThis))
        end
      end
    end
  end

  def pbAbilityCureCheck
    return if hp<=0
    if self.hasWorkingAbility(:LIMBER) && self.status==PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1}'s Limber cured its paralysis problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:OBLIVIOUS) && @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1}'s Oblivious cured its love problem!",pbThis))
      @effects[PBEffects::Attract]=-1
    end
    if self.hasWorkingAbility(:VITALSPIRIT) && self.status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1}'s Vital Spirit cured its sleep problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:INSOMNIA) && self.status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1}'s Insomnia cured its sleep problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:IMMUNITY) && self.status==PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1}'s Immunity cured its poison problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:OWNTEMPO) && @effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1}'s Own Tempo cured its confusion problem!",pbThis))
      @effects[PBEffects::Confusion]=0
    end
    if self.hasWorkingAbility(:MAGMAARMOR) && self.status==PBStatuses::FROZEN
      @battle.pbDisplay(_INTL("{1}'s Magma Armor cured its ice problem!",pbThis))
      self.status=0
    end
    if self.hasWorkingAbility(:WATERVEIL) && self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1}'s Water Veil cured its burn problem!",pbThis))
      self.status=0
    end
  end



################################################################################
# Held item effects
################################################################################
  def pbConsumeItem(recycle=true,pickup=true)
    itemname=PBItems.getName(self.item)
    @pokemon.itemRecycle=self.item if recycle
    @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
    if pickup
      @effects[PBEffects::PickupItem]=self.item
      @effects[PBEffects::PickupUse]=@battle.nextPickupUse
    end
    self.item=0
    self.effects[PBEffects::Unburden]=true
    # Symbiosis
    if pbPartner && pbPartner.hasWorkingAbility(:SYMBIOSIS) && recycle
      if pbPartner.item>0 &&
         !@battle.pbIsUnlosableItem(pbPartner,pbPartner.item) &&
         !@battle.pbIsUnlosableItem(self,pbPartner.item)
        @battle.pbDisplay(_INTL("{1}'s {2} let it share its {3} with {4}!",
           pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
           PBItems.getName(pbPartner.item),pbThis(true)))
        self.item=pbPartner.item
        self.effects[PBEffects::SymbiosisTriggered]=true
        pbPartner.item=0
        pbPartner.effects[PBEffects::Unburden]=true
        pbBerryCureCheck(true)
      end
    end
  end

  def pbConfusionBerry(symbol,flavor,message1,message2)
    return false if @effects[PBEffects::HealBlock]>0
    if isConst?(self.item,PBItems,symbol) && self.hp<=(self.totalhp/2).floor
      pbRecoverHP((self.totalhp/8).floor)
      @battle.pbDisplay(message1)
      if (self.nature%5) == flavor && (self.nature/5).floor != (self.nature%5)
        @battle.pbDisplay(message2)
        if @effects[PBEffects::Confusion]==0 && !self.hasWorkingAbility(:OWNTEMPO)
          @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
          @battle.pbCommonAnimation("Confusion",self,nil) if !self.isInvulnerable?
          @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
        end
      end
      pbConsumeItem
    end
  end

  def pbStatIncreasingBerry(symbol,stat,message)
    if !self.pbTooHigh?(stat)
      #isConst?(self.item,PBItems,symbol) &&
      #if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
      #   self.hp<=(self.totalhp/4).floor
      pbIncreaseStatBasic(stat,1)
      @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
      @battle.pbDisplay(message)
      #@pokemon.itemRecycle=self.item
      #@pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
      #self.item=0
      #end
    else
      @battle.pbDisplay("The berry was consumed but the stats were already at max!")
    end
    pbConsumeItem
  end
  
  def pbActivateBerryEffect(berry=0,consume=true)
    berry=self.item if berry==0
    berryname=(berry==0) ? "" : PBItems.getName(berry)
    consumed=false
    if isConst?(berry,PBItems,:ORANBERRY)
      if @effects[PBEffects::HealBlock]==0
        amt=self.pbRecoverHP(10)
        if amt>0
          @battle.pbDisplay(_INTL("{1} restored its health using its {2}!",pbThis,berryname))
          consumed=true
        end
      end
    elsif isConst?(berry,PBItems,:SITRUSBERRY) ||
          isConst?(berry,PBItems,:ENIGMABERRY)
      if @effects[PBEffects::HealBlock]==0
        amt=self.pbRecoverHP((self.totalhp/4).floor)
        if amt>0
          @battle.pbDisplay(_INTL("{1} restored its health using its {2}!",pbThis,berryname))
          consumed=true
        end
      end
    elsif isConst?(berry,PBItems,:CHESTOBERRY)
      if self.status==PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1}'s {2} cured its sleep problem.",pbThis,berryname))
        self.status=0
        consumed=true
      end
    elsif isConst?(berry,PBItems,:PECHABERRY)
      if self.status==PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning.",pbThis,berryname))
        self.status=0
        consumed=true
      end
    elsif isConst?(berry,PBItems,:RAWSTBERRY)
      if self.status==PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1}'s {2} healed its burn.",pbThis,berryname))
        self.status=0
        consumed=true
      end
    elsif isConst?(berry,PBItems,:CHERIBERRY)
      if self.status==PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis.",pbThis,berryname))
        self.status=0
        consumed=true
      end
    elsif isConst?(berry,PBItems,:ASPEARBERRY)
      if self.status==PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1}'s {2} thawed it out.",pbThis,berryname))
        self.status=0
        consumed=true
      end
    elsif isConst?(berry,PBItems,:LEPPABERRY)
      found=[]
      for i in 0...@pokemon.moves.length
        if @pokemon.moves[i].id!=0
          if (consume && @pokemon.moves[i].pp==0) ||
             (!consume && @pokemon.moves[i].pp<@pokemon.moves[i].totalpp)
            found.push(i)
          end
        end
      end
      if found.length>0
        choice=(consume) ? found[0] : found[@battle.pbRandom(found.length)]
        pokemove=@pokemon.moves[choice]
        pokemove.pp+=10
        pokemove.pp=pokemove.totalpp if pokemove.pp>pokemove.totalpp 
        self.moves[choice].pp=pokemove.pp
        movename=PBMoves.getName(pokemove.id)
        @battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s PP!",pbThis,berryname,movename)) 
        consumed=true
      end
    elsif isConst?(berry,PBItems,:PERSIMBERRY)
      if @effects[PBEffects::Confusion]>0
        @battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",pbThis,berryname))
        @effects[PBEffects::Confusion]=0
        consumed=true
      end
    elsif isConst?(berry,PBItems,:LUMBERRY)
      if self.status>0 || @effects[PBEffects::Confusion]>0
        st=self.status; conf=(@effects[PBEffects::Confusion]>0)
        self.status=0
        @effects[PBEffects::Confusion]=0
        case st
        when PBStatuses::SLEEP
          @battle.pbDisplay(_INTL("{1}'s {2} woke it up!",pbThis,berryname))
        when PBStatuses::POISON
          @battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",pbThis,berryname))
        when PBStatuses::BURN
          @battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",pbThis,berryname))
        when PBStatuses::PARALYSIS
          @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",pbThis,berryname))
        when PBStatuses::FROZEN
          @battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",pbThis,berryname))
        end
        if conf
          @battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",pbThis,berryname))
        end
        consumed=true
      end
    elsif isConst?(berry,PBItems,:FIGYBERRY)
      consumed=pbConfusionBerry(berry,0,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too spicy!",pbThis(true),berryname))
    elsif isConst?(berry,PBItems,:WIKIBERRY)
      pbConfusionBerry(berry,3,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too dry!",pbThis(true),berryname))
      consumed=true
    elsif isConst?(berry,PBItems,:MAGOBERRY)
      pbConfusionBerry(berry,2,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too sweet!",pbThis(true),berryname))
      consumed=true
    elsif isConst?(berry,PBItems,:AGUAVBERRY)
      pbConfusionBerry(berry,4,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too bitter!",pbThis(true),berryname))
      consumed=true
    elsif isConst?(berry,PBItems,:IAPAPABERRY)
      pbConfusionBerry(berry,1,
         _INTL("{1}'s {2} restored health!",pbThis,berryname),
         _INTL("For {1}, the {2} was too sour!",pbThis(true),berryname))
      consumed=true
    elsif isConst?(berry,PBItems,:LIECHIBERRY)
      pbStatIncreasingBerry(berry,PBStats::ATTACK,
         _INTL("Using its {1}, the Attack of {2} rose!",berryname,pbThis(true)))
      consumed=true
    elsif isConst?(berry,PBItems,:GANLONBERRY) ||
          isConst?(berry,PBItems,:KEEBERRY)
      pbStatIncreasingBerry(berry,PBStats::DEFENSE,
         _INTL("Using its {1}, the Defense of {2} rose!",berryname,pbThis(true)))
      consumed=true
    elsif isConst?(berry,PBItems,:SALACBERRY)
      pbStatIncreasingBerry(berry,PBStats::SPEED,
         _INTL("Using its {1}, the Speed of {2} rose!",berryname,pbThis(true)))
      consumed=true
    elsif isConst?(berry,PBItems,:PETAYABERRY)
      pbStatIncreasingBerry(berry,PBStats::SPATK,
         _INTL("Using its {1}, the Special Attack of {2} rose!",berryname,pbThis(true)))
      consumed=true
    elsif isConst?(berry,PBItems,:APICOTBERRY) ||
          isConst?(berry,PBItems,:MARANGABERRY)
      pbStatIncreasingBerry(berry,PBStats::SPDEF,
         _INTL("Using its {1}, the Special Defense of {2} rose!",berryname,pbThis(true)))
      consumed=true
    elsif isConst?(berry,PBItems,:LANSATBERRY)
      if @effects[PBEffects::FocusEnergy]<2
        @effects[PBEffects::FocusEnergy]=2
        @battle.pbDisplay(_INTL("{1} used its {2} to get pumped!",pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:MICLEBERRY)
      if !@effects[PBEffects::MicleBerry]
        @effects[PBEffects::MicleBerry]=true
        @battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move using its {2}!",
           pbThis,berryname))
        consumed=true
      end
    elsif isConst?(berry,PBItems,:STARFBERRY)
      stats=[]
      messages=[]
      messages[PBStats::ATTACK]=_INTL("Using {1}, the Attack of {2} rose sharply!",berryname,pbThis(true))
      messages[PBStats::DEFENSE]=_INTL("Using {1}, the Defense of {2} rose sharply!",berryname,pbThis(true))
      messages[PBStats::SPEED]=_INTL("Using {1}, the Speed of {2} rose sharply!",berryname,pbThis(true))
      messages[PBStats::SPATK]=_INTL("Using {1}, the Special Attack of {2} rose sharply!",berryname,pbThis(true))
      messages[PBStats::SPDEF]=_INTL("Using {1}, the Special Defense of {2} rose sharply!",berryname,pbThis(true))
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPATK,PBStats::SPDEF,PBStats::SPEED]
        stats.push(i) if !pbTooHigh?(i)
      end
      if stats.length>0
        stat=stats[@battle.pbRandom(stats.length)]
        pbIncreaseStatBasic(stat,2)
        @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
        @battle.pbDisplay(messages[stat])
        consumed=true
      end
    end
    if consumed
      # Cheek Pouch
      if hasWorkingAbility(:CHEEKPOUCH) && @effects[PBEffects::HealBlock]==0
        amt=self.pbRecoverHP((@totalhp/3).floor)
        if amt>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its health!",
             pbThis,PBAbilities.getName(ability)))
        end
      end
      pbConsumeItem if consumed
      self.pokemon.belch=true if self.pokemon
    end
  end
  
  def pbBerryCureCheck(hpcure=false)
    return if hp<=0
    ateBerry=false
    unnerver=(pbOpposing1 && pbOpposing1.hp>0 && pbOpposing1.hasWorkingAbility(:UNNERVE)) ||
             (pbOpposing2 && pbOpposing2.hp>0 && pbOpposing2.hasWorkingAbility(:UNNERVE))
    itemname=(self.item==0) ? "" : PBItems.getName(self.item)
    if hpcure && isConst?(self.item,PBItems,:BERRYJUICE) && self.hp<=(self.totalhp/2).floor
      @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
      self.pbRecoverHP(20)
      pbConsumeItem
    end
    if !unnerver
      if hpcure && isConst?(self.item,PBItems,:ORANBERRY) &&
         ((self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
         self.hp<=(self.totalhp/3).floor)
        @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
        self.pbRecoverHP(10)
        pbConsumeItem
        ateBerry=true
      end
      if hpcure && isConst?(self.item,PBItems,:SITRUSBERRY) &&
         ((self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
         self.hp<=(self.totalhp/2).floor)
        @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
        self.pbRecoverHP((self.totalhp/4).floor)
        pbConsumeItem
        ateBerry=true
      end
      if isConst?(self.item,PBItems,:CHERIBERRY) && self.status==PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis problem!",pbThis,itemname))
        self.status=0
        pbConsumeItem
        ateBerry=true
      end
      if isConst?(self.item,PBItems,:CHESTOBERRY) && self.status==PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1}'s {2} cured its sleep problem!",pbThis,itemname))
        self.status=0
        pbConsumeItem
        ateBerry=true
      end
      if isConst?(self.item,PBItems,:PECHABERRY) && self.status==PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1}'s {2} cured its poison problem!",pbThis,itemname))
        self.status=0
        pbConsumeItem
        ateBerry=true
      end
      if isConst?(self.item,PBItems,:RAWSTBERRY) && self.status==PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1}'s {2} cured its burn problem!",pbThis,itemname))
        self.status=0
        pbConsumeItem
        ateBerry=true
      end
      if isConst?(self.item,PBItems,:ASPEARBERRY) && self.status==PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1}'s {2} cured its ice problem!",pbThis,itemname))
        self.status=0
        pbConsumeItem
        ateBerry=true
      end
      if isConst?(self.item,PBItems,:LEPPABERRY)
        for i in 0...@pokemon.moves.length
          pokemove=@pokemon.moves[i]
          battlermove=self.moves[i]
          if pokemove.pp==0 && pokemove.id!=0
            movename=PBMoves.getName(pokemove.id)
            pokemove.pp=10
            pokemove.pp=pokemove.totalpp if pokemove.pp>pokemove.totalpp 
            battlermove.pp=pokemove.pp
            @battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s PP!",pbThis,itemname,movename)) 
            pbConsumeItem
            break
          end
        end
        ateBerry=true
      end
      if isConst?(self.item,PBItems,:PERSIMBERRY) && @effects[PBEffects::Confusion]>0
        @battle.pbDisplay(_INTL("{1}'s {2} cured its confusion problem!",pbThis,itemname))
        @effects[PBEffects::Confusion]=0
        pbConsumeItem
        ateBerry=true
      end
      if isConst?(self.item,PBItems,:LUMBERRY) && (self.status>0 || @effects[PBEffects::Confusion]>0)
        if @effects[PBEffects::Confusion]>0
          @battle.pbDisplay(_INTL("{1}'s {2} cured its confusion problem!",pbThis,itemname))
        else
          case self.status
            when PBStatuses::PARALYSIS
              @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis problem!",pbThis,itemname))
            when PBStatuses::SLEEP
              @battle.pbDisplay(_INTL("{1}'s {2} cured its sleep problem!",pbThis,itemname))
            when PBStatuses::POISON
             @battle.pbDisplay(_INTL("{1}'s {2} cured its poison problem!",pbThis,itemname))
            when PBStatuses::BURN
              @battle.pbDisplay(_INTL("{1}'s {2} cured its burn problem!",pbThis,itemname))
            when PBStatuses::FROZEN
              @battle.pbDisplay(_INTL("{1}'s {2} cured its frozen problem!",pbThis,itemname))
          end
        end
        self.status=0
        @effects[PBEffects::Confusion]=0
        pbConsumeItem
        ateBerry=true
      end
      if hpcure
        if isConst?(self.item,PBItems,:FIGYBERRY)
          pbConfusionBerry(:FIGYBERRY,0,
             _INTL("{1}'s {2} restored health!",pbThis,itemname),
             _INTL("For {1}, the {2} was too spicy!",pbThis(true),itemname))
          ateBerry=true
        elsif isConst?(self.item,PBItems,:WIKIBERRY)
          pbConfusionBerry(:WIKIBERRY,3,
             _INTL("{1}'s {2} restored health!",pbThis,itemname),
             _INTL("For {1}, the {2} was too dry!",pbThis(true),itemname))
          ateBerry=true
        elsif isConst?(self.item,PBItems,:MAGOBERRY)
          pbConfusionBerry(:MAGOBERRY,2,
             _INTL("{1}'s {2} restored health!",pbThis,itemname),
             _INTL("For {1}, the {2} was too sweet!",pbThis(true),itemname))
          ateBerry=true
        elsif isConst?(self.item,PBItems,:AGUAVBERRY)
          pbConfusionBerry(:AGUAVBERRY,4,
             _INTL("{1}'s {2} restored health!",pbThis,itemname),
             _INTL("For {1}, the {2} was too bitter!",pbThis(true),itemname))
          ateBerry=true
        elsif isConst?(self.item,PBItems,:IAPAPABERRY)
          pbConfusionBerry(:IAPAPABERRY,1,
             _INTL("{1}'s {2} restored health!",pbThis,itemname),
             _INTL("For {1}, the {2} was too sour!",pbThis(true),itemname))
          ateBerry=true
        end
      end
      if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
        self.hp<=(self.totalhp/4).floor
        if isConst?(self.item,PBItems,:LIECHIBERRY)
          pbStatIncreasingBerry(:LIECHIBERRY,PBStats::ATTACK,
            _INTL("Using its {1}, the Attack of {2} rose!",itemname,pbThis(true)))
          ateBerry=true
        elsif isConst?(self.item,PBItems,:GANLONBERRY)
          pbStatIncreasingBerry(:GANLONBERRY,PBStats::DEFENSE,
            _INTL("Using its {1}, the Defense of {2} rose!",itemname,pbThis(true)))
          ateBerry=true
        elsif isConst?(self.item,PBItems,:SALACBERRY)
          pbStatIncreasingBerry(:SALACBERRY,PBStats::SPEED,
            _INTL("Using its {1}, the Speed of {2} rose!",itemname,pbThis(true)))
          ateBerry=true
        elsif isConst?(self.item,PBItems,:PETAYABERRY)
          pbStatIncreasingBerry(:PETAYABERRY,PBStats::SPATK,
            _INTL("Using its {1}, the Special Attack of {2} rose!",itemname,pbThis(true)))
          ateBerry=true
        elsif isConst?(self.item,PBItems,:APICOTBERRY)
          pbStatIncreasingBerry(:APICOTBERRY,PBStats::SPDEF,
            _INTL("Using its {1}, the Special Defense of {2} rose!",itemname,pbThis(true)))
          ateBerry=true
        end
      end
      if isConst?(self.item,PBItems,:LANSATBERRY) && @effects[PBEffects::FocusEnergy]==0
        if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
           self.hp<=(self.totalhp/4).floor
          @battle.pbDisplay(_INTL("{1} used its {2} to get pumped!",pbThis,itemname))
          @effects[PBEffects::FocusEnergy]=1
          pbConsumeItem
          ateBerry=true
        end
      end
      if isConst?(self.item,PBItems,:STARFBERRY)
        if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
           self.hp<=(self.totalhp/4).floor
          stats=[]
          messages=[]
          messages[PBStats::ATTACK]=_INTL("Using {1}, the Attack of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::DEFENSE]=_INTL("Using {1}, the Defense of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::SPEED]=_INTL("Using {1}, the Speed of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::SPATK]=_INTL("Using {1}, the Special Attack of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::SPDEF]=_INTL("Using {1}, the Special Defense of {2} rose sharply!",itemname,pbThis(true))
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
            stats[stats.length]=i if !pbTooHigh?(i)
          end
          if stats.length>0
            stat=stats[@battle.pbRandom(stats.length)]
            pbIncreaseStatBasic(stat,2)
            @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
            @battle.pbDisplay(messages[stat])
            pbConsumeItem
            ateBerry=true
          end
        end
      end
    end
    if self.hasWorkingItem(:WHITEHERB)
      reducedstats=false
      for i in [PBStats::ATTACK,PBStats::DEFENSE,
                PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                PBStats::EVASION,PBStats::ACCURACY]
        if @stages[i]<0
          @stages[i]=0
          reducedstats=true
        end
      end
      if reducedstats
        @battle.pbDisplay(_INTL("{1}'s {2} restored its status!",pbThis,itemname))
        pbConsumeItem
      end
    end
    if isConst?(self.item,PBItems,:MENTALHERB) &&
       (@effects[PBEffects::Attract]>=0 ||
       @effects[PBEffects::Taunt]>0 ||
       @effects[PBEffects::Encore]>0 ||
       @effects[PBEffects::Torment] ||
       @effects[PBEffects::Disable]>0 ||
       @effects[PBEffects::HealBlock]>0)
      @battle.pbDisplay(_INTL("{1}'s {2} cured its love problem!",pbThis,itemname)) if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1} is taunted no more!",pbThis)) if @effects[PBEffects::Taunt]>0
      @battle.pbDisplay(_INTL("{1}'s encore ended!",pbThis)) if @effects[PBEffects::Encore]>0
      @battle.pbDisplay(_INTL("{1} is tormented no more!",pbThis)) if @effects[PBEffects::Torment]
      @battle.pbDisplay(_INTL("{1} is disabled no more!",pbThis)) if @effects[PBEffects::Disable]>0
      @battle.pbDisplay(_INTL("{1}'s Heal Block wore off!",pbThis)) if @effects[PBEffects::HealBlock]>0
      @effects[PBEffects::Attract]=-1
      @effects[PBEffects::Taunt]=0
      @effects[PBEffects::Encore]=0
      @effects[PBEffects::EncoreMove]=0
      @effects[PBEffects::EncoreIndex]=0
      @effects[PBEffects::Torment]=false
      @effects[PBEffects::Disable]=0
      @effects[PBEffects::HealBlock]=0
      pbConsumeItem
    end
    self.pokemon.belch=true if self.pokemon && ateBerry
    if ateBerry && self.hasWorkingAbility(:CHEEKPOUCH) && @effects[PBEffects::HealBlock]==0
      self.pbRecoverHP(@totalhp/3).floor
      @battle.pbDisplay(_INTL("{1}'s {2} restored its health!",
             pbThis,PBAbilities.getName(ability)))
    end
  end



################################################################################
# Move user and targets
################################################################################
  def pbFindUser(choice,targets)
    priority=@battle.pbPriority
    move=choice[2]
    target=choice[3]
    user=self   # Normally, the user is self
    # Targets in normal cases
    case pbTarget(move)
    when PBTargets::SingleNonUser
      if target>=0
        targetBattler=@battle.battlers[target]
        if !isConst?(move.id,PBMoves,:FUTURESIGHT) && !isConst?(move.id,PBMoves,:DOOMDESIRE)
          if !pbIsOpposing?(targetBattler.index)
            if !pbAddTarget(targets,targetBattler)
              pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
            end
          else
            pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
          end
        else  
          targets[targets.length]=targetBattler
        end
      else
        pbRandomTarget(targets)
      end
    when PBTargets::SingleOpposing
      if target>=0
        targetBattler=@battle.battlers[target]
        if !pbIsOpposing?(targetBattler.index)
          if !pbAddTarget(targets,targetBattler)
            pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
          end
        else
          pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
        end
      else
        pbRandomTarget(targets)
      end
    when PBTargets::OppositeOpposing
      pbAddTarget(targets,pbOppositeOpposing) if !pbAddTarget(targets,pbOppositeOpposing2)
    when PBTargets::RandomOpposing
      pbRandomTarget(targets)
    when PBTargets::AllOpposing
      # Just pbOpposing1 because partner is determined late
      pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
    when PBTargets::AllNonUsers
      for i in 0..3 # not ordered by priority
        pbAddTarget(targets,@battle.battlers[i]) if i!=@index
      end
    when PBTargets::UserOrPartner
      if target>=0 # Pre-chosen target
        targetBattler=@battle.battlers[target]
        pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
      else
        pbAddTarget(targets,self)
      end
    when PBTargets::Partner
      pbAddTarget(targets,pbPartner)
    else
      move.pbAddTarget(targets,self)
    end
    return user
  end

  def pbChangeUser(thismove,user)
    priority=@battle.pbPriority
    changeeffect=0
    # Change user to user of Snatch
    if (thismove.flags&0x08)!=0 # flag d: Snatch
      for i in priority
        if i.effects[PBEffects::Snatch]
          @battle.pbDisplay(_INTL("{1} Snatched {2}'s move!",i.pbThis,user.pbThis(true)))
          i.effects[PBEffects::Snatch]=false
          target=user
          user=i
          # Snatch's PP is reduced if old user has Pressure
          userchoice=@battle.choices[user.index][1]
          if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
            pressuremove=user.moves[userchoice]
            if @battle.pbWeather==PBWeather::NEWMOON
              pbSetPP(pressuremove,pressuremove.pp-2) if pressuremove.pp>0
            else
              pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
            end
          end
        end
      end
    end
    # If this non-targeting move is affected by Magic Coat/Magic Bounce...
    if thismove.canMagicCoat?
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.hp<=0
        # And either foe has Magic Coat active...
        if foe.effects[PBEffects::MagicCoat]
          tmp=user
          user=foe
          changeeffect=1
        # Or either foe has Magic Bounce while the user doesn't have Mold Breaker...
        elsif(!user.hasMoldBreaker &&
          (foe.hasWorkingAbility(:MAGICBOUNCE) || 
          (foe.hasWorkingAbility(:PROTEANMAXIMA) &&
          foe.form == 5)))
            tmp=user
            user=foe
            changeeffect=2
        end
      end
      # Bounce back the effect and display different messages depending on the
      # two criteria above.
      if changeeffect==1
        @battle.pbDisplay(_INTL("{1}'s {2} was bounced back by Magic Coat!",tmp.pbThis,thismove.name))
      elsif changeeffect==2
        @battle.pbDisplay(_INTL("{1} bounced the {2} back!",user.pbThis,thismove.name))
      end
    end
    
    return user
  end

  def pbTarget(move)
    target=move.target
    if move.function==0x10D && pbHasType?(:GHOST) # Curse
      target=PBTargets::OppositeOpposing
    end
    return target
  end

  def pbAddTarget(targets,target)
    if target.hp>0
      targets[targets.length]=target
      return true
    end
    return false
  end

  def pbRandomTarget(targets)
    choices=[]
    pbAddTarget(choices,pbOpposing1)
    pbAddTarget(choices,pbOpposing2)
    if choices.length>0
      pbAddTarget(targets,choices[@battle.pbRandom(choices.length)])
    end
  end

  def pbChangeTarget(thismove,userandtarget,targets)
    priority=@battle.pbPriority
    changeeffect=0
    user=userandtarget[0]
    target=userandtarget[1]
    # Lightning Rod here
    if targets.length>0 && isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:ELECTRIC) && 
       !target.hasWorkingAbility(:LIGHTNINGROD)
      # all damaging Electric attacks have a target of "single non-user"
      for i in priority # use Pokémon earliest in priority
        next if user.index==i.index#!pbIsOpposing?(i.index)
        if i.hasWorkingAbility(:LIGHTNINGROD) && i.hp>0 && target.hp>0 &&
           !user.hasMoldBreaker
          target=i# X's LightningRod took the attack!
          changeeffect=1
          break
        end
      end
    end
    # Storm Drain here
    if targets.length==1 && isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:WATER) && 
       !target.hasWorkingAbility(:STORMDRAIN)
      for i in priority # use Pokémon earliest in priority
        next if user.index==i.index#!pbIsOpposing?(i.index)
        if i.hasWorkingAbility(:STORMDRAIN) && i.hp>0 && target.hp>0 &&
           !user.hasMoldBreaker
          target=i# X's Storm Drain took the attack!
          changeeffect=2
          break
        end
      end
    end
    # Change target to user of Follow Me (overrides Magic Coat
    # because check for Magic Coat below uses this target)
    if thismove.target==PBTargets::SingleNonUser ||
       thismove.target==PBTargets::SingleOpposing ||
       thismove.target==PBTargets::RandomOpposing ||
       thismove.target==PBTargets::OppositeOpposing
      newtarget=nil; strength=100
      for i in priority # use Pokémon latest in priority
        next if !pbIsOpposing?(i.index)
        if !i.fainted? && !i.effects[PBEffects::SkyDrop] && !i.effects[PBEffects::SpiritAway] &&
          i.effects[PBEffects::FollowMe]>0 && i.effects[PBEffects::FollowMe]<strength && 
          i.effects[PBEffects::RagePowder]<strength
          #change target to this
          newtarget=i; strength=i.effects[PBEffects::FollowMe]
          changeeffect=0
        elsif !i.fainted? && !i.effects[PBEffects::SkyDrop] && !i.effects[PBEffects::SpiritAway] &&
          i.effects[PBEffects::RagePowder]>0 && i.effects[PBEffects::FollowMe]<strength &&
          i.effects[PBEffects::RagePowder]<strength
          if !user.hasWorkingItem(:SAFETYGOGGLES) && !user.pbHasType?(:GRASS) &&
             !user.effects[PBEffects::ForestsCurse] && !user.hasWorkingAbility(:OVERCOAT) &&
             !user.hasWorkingAbility(:OMNITYPE)
            #change target to this
            newtarget=i; strength=i.effects[PBEffects::RagePowder]
            changeeffect=0
          end
        end
      end
      target=newtarget if newtarget
      if !target.fainted? && !target.effects[PBEffects::SkyDrop] && 
         !target.effects[PBEffects::SpiritAway] && target.effects[PBEffects::FollowMe]<=0 &&
         target.effects[PBEffects::RagePowder]<=0 && target!=user && 
         target!=user.pbPartner && target.effects[PBEffects::AllySwitch]
        #change target to other Pokemon
        newtarget=target.pbPartner
        changeeffect=0
      end
      target=newtarget if newtarget
      
    end
    # TODO: Pressure here is incorrect if Magic Coat redirects target
    if target.hasWorkingAbility(:PRESSURE)
      twoturnary=[
        0xC3,
        0xC4,
        0xC5,
        0xC6,
        0xC7,
        0xC8,
        0xC9,
        0xCA,
        0xCB,
        0xCC,
        0xCD,
        0xCE,
        0x138,
        0x204
      ]
      if twoturnary.include?(thismove.function)
        for i in 0..3
          if user.moves[i].name==thismove.name
            pbReducePP(user.moves[i])
            if @battle.pbWeather==PBWeather::NEWMOON
              pbReducePP(user.moves[i])
            end
          end
        end
      else
        pbReducePP(thismove) # Reduce PP
        if @battle.pbWeather==PBWeather::NEWMOON
          pbReducePP(thismove)
        end
      end
    end  
    # Change user to user of Snatch
    if (thismove.flags&0x08)!=0 # flag d: Snatch
      for i in priority
        if i.effects[PBEffects::Snatch]
          @battle.pbDisplay(_INTL("{1} Snatched {2}'s move!",i.pbThis,user.pbThis(true)))
          i.effects[PBEffects::Snatch]=false
          target=user
          user=i
          # Snatch's PP is reduced if old user has Pressure
          userchoice=@battle.choices[user.index][1]
          if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
            pressuremove=user.moves[userchoice]
            if @battle.pbWeather==PBWeather::NEWMOON
              pbSetPP(pressuremove,pressuremove.pp-2) if pressuremove.pp>0
            else
              pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
            end
          end
        end
      end
    end
    userandtarget[0]=user
    userandtarget[1]=target
    if target.hasWorkingAbility(:SOUNDPROOF) && !user.hasMoldBreaker &&
       (thismove.flags&0x400)!=0 && # flag k: Is sound-based move
       !(isConst?(thismove.id,PBMoves,:HEALBELL) || # Heal Bell/Perish Song
       isConst?(thismove.id,PBMoves,:PERISHSONG))   # handled elsewhere
      @battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",target.pbThis,
         PBAbilities.getName(target.ability),thismove.name))
      return false
    end
    if thismove.canMagicCoat?
      if target.effects[PBEffects::MagicCoat]
        # switch user and target
        changeeffect=3
        tmp=user
        user=target
        target=tmp
        # Magic Coat's PP is reduced if old user has Pressure
        userchoice=@battle.choices[user.index][1]
        if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
          pressuremove=user.moves[userchoice]
          if @battle.pbWeather==PBWeather::NEWMOON
            pbSetPP(pressuremove,pressuremove.pp-2) if pressuremove.pp>0
          else
            pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
          end
        end
      elsif(!user.hasMoldBreaker && 
        (target.hasWorkingAbility(:MAGICBOUNCE) || 
        (target.hasWorkingAbility(:PROTEANMAXIMA) && target.form==5)))
        # switch user and target
        changeeffect=4
        tmp=user
        user=target
        target=tmp
      end
    end
    if changeeffect==1
      @battle.pbDisplay(_INTL("{1}'s LightningRod took the move!",target.pbThis))
    elsif changeeffect==2
      @battle.pbDisplay(_INTL("{1}'s Storm Drain took the move!",target.pbThis))
    elsif changeeffect==3
      # Target refers to the move's old user
      @battle.pbDisplay(_INTL("{1}'s {2} was bounced back by Magic Coat!",target.pbThis,thismove.name))
    elsif changeeffect==4
      # Target refers to the move's old user
      @battle.pbDisplay(_INTL("{1} bounced the {2} back!",user.pbThis,thismove.name))
    end
    userandtarget[0]=user
    userandtarget[1]=target
    return true
  end



################################################################################
# Move PP
################################################################################
  def pbSetPP(move,pp)
    move.pp=pp
    #Not effects[PBEffects::Mimic], since Mimic can't copy Mimic
    if move.thismove && move.id==move.thismove.id && !@effects[PBEffects::Transform]
      move.thismove.pp=pp
    end
  end

  def pbReducePP(move)
    #TODO: Pressure
    if @effects[PBEffects::TwoTurnAttack]>0 ||
       @effects[PBEffects::Bide]>0 || 
       @effects[PBEffects::Outrage]>0 ||
       @effects[PBEffects::Rollout]>0 ||
       @effects[PBEffects::HyperBeam]>0 ||
       @effects[PBEffects::Uproar]>0
      # No need to reduce PP if two-turn attack
      return true
    end
    if move.pp<0
      # No need to reduce PP for special calls of moves
      return true
    end
    if move.totalpp==0
      # Infinite PP, can always be used
      return true
    end
    if move.pp==0
      return false
    end
    if move.pp>0
      pbSetPP(move,move.pp-1)
    end
    return true
  end

  def pbReducePPOther(move)
    pbSetPP(move,move.pp-1) if move.pp>0
  end



################################################################################
# Using a move
################################################################################
  def pbObedienceCheck?(choice)
    if choice[0]!=1
      return true
    end
    if $game_switches[356]
      return true
    end
    
    if @battle.pbOwnedByPlayer?(@index) && @battle.internalbattle
      badgelevel=25
      badgelevel=40  if @battle.pbPlayer.numbadges>=1
      badgelevel=50  if @battle.pbPlayer.numbadges>=2
      badgelevel=60  if @battle.pbPlayer.numbadges>=3
      badgelevel=70  if @battle.pbPlayer.numbadges>=4
      badgelevel=80  if @battle.pbPlayer.numbadges>=5
      badgelevel=90  if @battle.pbPlayer.numbadges>=6
      badgelevel=100  if @battle.pbPlayer.numbadges>=7
      badgelevel=110 if @battle.pbPlayer.numbadges>=8
      move=choice[2]
      disobedient=false
      if @pokemon.isForeign?(@battle.pbPlayer) && @level>badgelevel
        a=((@level+badgelevel)*@battle.pbRandom(256)/255).floor
        disobedient|=a<badgelevel
      end
      if self.respond_to?("pbHyperModeObedience")
        disobedient|=!self.pbHyperModeObedience(move)
      end
      if disobedient && !$game_switches[8]
        @effects[PBEffects::Rage]=false
        if self.status==PBStatuses::SLEEP && 
           (move.function==0x11 || move.function==0xB4) # Snore, Sleep Talk
          @battle.pbDisplay(_INTL("{1} ignored orders and kept sleeping!",pbThis)) 
          return false
        end
        b=((@level+badgelevel)*@battle.pbRandom(256)/255).floor
        if b<badgelevel
          if !@battle.pbCanShowFightMenu?(@index)
            return false
          end
          othermoves=[]
          for i in 0..3
            next if i==choice[1]
            othermoves[othermoves.length]=i if @battle.pbCanChooseMove?(@index,i,false)
          end
          if othermoves.length>0
            @battle.pbDisplay(_INTL("{1} ignored orders!",pbThis)) 
            newchoice=othermoves[@battle.pbRandom(othermoves.length)]
            choice[1]=newchoice
            choice[2]=@moves[newchoice]
            choice[3]=-1
          end
          return true
        elsif self.status!=PBStatuses::SLEEP
          c=@level-b
          r=@battle.pbRandom(256)
          if r<c && pbCanSleep?(self,false)
            pbSleepSelf()
            @battle.pbDisplay(_INTL("{1} took a nap!",pbThis))
            return false
          end
          r-=c
          if r<c
            @battle.pbDisplay(_INTL("It hurt itself from its confusion!"))
            pbConfusionDamage
          else
            message=@battle.pbRandom(4)
            @battle.pbDisplay(_INTL("{1} ignored orders!",pbThis)) if message==0
            @battle.pbDisplay(_INTL("{1} turned away!",pbThis)) if message==1
            @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis)) if message==2
            @battle.pbDisplay(_INTL("{1} pretended not to notice!",pbThis)) if message==3
            self.effects[PBEffects::SkipTurn]=true if message!=0
          end
          return false
        end
      end
      return true
    else
      return true
    end
  end

  def pbSuccessCheck(thismove,user,target,turneffects,accuracy=true)
    var = pbSuccessCheckHandle(thismove,user,target,turneffects,accuracy)
    if !var && thismove.isBurstAttack?
      user.pokemon.burstAttack=true
    end
    skipForFutureSight=false
    for i in 0..3
      if self.pokemonIndex==@battle.battlers[i].effects[PBEffects::FutureSightUser]
        if @battle.battlers[i].effects[PBEffects::FutureSight]==0
          skipForFutureSight=true
          break
        end
      end
    end
    pbCancelMoves if !var && !skipForFutureSight
    @battle.scene.pbShowSprites(user.index) if !var && !user.fainted? && !skipForFutureSight
    pbSkyDropReset if !var
    @moveHit=var
    return var
  end
  
  def pbSuccessCheckHandle(thismove,user,target,turneffects,accuracy=true)
    if user.effects[PBEffects::TwoTurnAttack]>0
      PBDebug.log("[Using two-turn attack]")
      return true
    end
    if thismove.basedamage<1
      return false if thismove.pbTypeModMessages(thismove.type,user,target,true) == 0 
    end
    # TODO: "Before Protect" applies to Counter/Mirror Coat
    if (target.status!=PBStatuses::SLEEP || target.effects[PBEffects::Substitute]>0) && 
       thismove.function==0xDE # Dream Eater
      @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
      return false
    end
    if thismove.function==0xE2 # Memento
      if target.pbTooLow?(PBStats::ATTACK) && target.pbTooLow?(PBStats::SPATK)
        @battle.pbDisplay(_INTL("But it failed!"))
        return false
      end
      user.hp=0
    end
    if thismove.function==0x113 && user.effects[PBEffects::Stockpile]==0 # Spit Up
      @battle.pbDisplay(_INTL("But it failed to spit up a thing!"))
      return false
    end
    if target.effects[PBEffects::Protect] && thismove.canProtectAgainst?
      if !target.effects[PBEffects::ProtectNegation]
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        #if thismove.isBurstAttack?
        #  user.pokemon.burstAttack=true
        #end
        @battle.successStates[user.index].protected=true
        return false
      end
    end
    p=thismove.priority
    p+=1 if user.hasWorkingAbility(:PRANKSTER) && thismove.pbIsStatus?
    p+=1 if user.hasWorkingAbility(:GALEWINGS) && isConst?(thismove.type,PBTypes,:FLYING)
    if target.pbOwnSide.effects[PBEffects::QuickGuard] && thismove.canProtectAgainst? &&
       p>0 && !target.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} was protected by Quick Guard!",target.pbThis))
        @battle.successStates[user.index].protected=true
      return false
    end
    if target.pbOwnSide.effects[PBEffects::WideGuard] &&
       (thismove.target==PBTargets::AllOpposing || thismove.target==PBTargets::AllNonUsers) &&
       !thismove.pbIsStatus? && !target.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} was protected by Wide Guard!",target.pbThis))
      @battle.successStates[user.index].protected=true
      return false
    end
    if target.pbOwnSide.effects[PBEffects::CraftyShield] && thismove.pbIsStatus? &&
       target!=user && thismove.function!=0xE5 # Perish Song
      @battle.pbDisplay(_INTL("Crafty Shield protected {1}!",target.pbThis(true)))
      @battle.successStates[user.index].protected=true
      return false
    end
    if target.pbOwnSide.effects[PBEffects::MatBlock] && !thismove.pbIsStatus? &&
       thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} was blocked by the kicked-up mat!",thismove.name))
      @battle.successStates[user.index].protected=true
      return false
    end
    #if target.pbOwnSide.effects[PBEffects::MatBlock] && (thismove.pbIsPhysical? || thismove.pbIsSpecial?) 
    #  if isConst?(thismove.id,PBMoves,:PHANTOMFORCE) || isConst?(thismove.id,PBMoves,:SHADOWFORCE) || isConst?(thismove.id,PBMoves,:HYPERSPACE) || isConst?(thismove.id,PBMoves,:HYPERSPACEFURY)
    #    target.pbOwnSide.effects[PBEffects::MatBlock]=false
    #    @battle.pbDisplay(_INTL("The Mat Block was broken!"))
    #  end
    #  @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
    #  @battle.successStates[user.index].protected=true
    #end
    # TODO: Mind Reader/Lock-On
    # --Sketch/FutureSight/PsychUp work even on Fly/Bounce/Dive/Dig
    if thismove.pbMoveFailed(user,target) #TODO:Applies to Snore/Fake Out
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    # King's Shield
    if target.effects[PBEffects::KingsShield] && !thismove.pbIsStatus? &&
       thismove.canProtectAgainst? && !target.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
      @battle.successStates[user.index].protected=true
      if thismove.isContactMove?
        @battle.pbCommonAnimation("StatDown",self,nil)
        user.pbReduceStat(PBStats::ATTACK,2,true)
      end
      return false
    end
    #if (!target.effects[PBEffects::KingsShield] || thismove.basedamage>0) &&
    #    target.effects[PBEffects::Protect] && (thismove.flags&0x02)!=0 && # flag b: Protect/Detect
    #  !target.effects[PBEffects::ProtectNegation]
    #  @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
    #  @battle.successStates[user.index].protected=true
    #  if target.species==PBSpecies::AEGISLASH && (thismove.flags&0x01) != 0
    #    if isConst?(user.ability,PBAbilities,:HYPERCUTTER) || isConst?(user.ability,PBAbilities,:CLEARBODY)
    #        abilityname=PBAbilities.getName(user.ability)
    #      @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",user.pbThis,abilityname))
    #    elsif user.pbTooLow?(PBStats::ATTACK)
    #      @battle.pbDisplay(_INTL("{1}'s Attack won't go lower!",user.pbThis))
    #    else
    #      pbReduceStatBasic(PBStats::ATTACK,2)
    #      @battle.pbDisplay(_INTL("{1}'s attack fell due to King's Shield!",user.pbThis))
    #      @battle.pbCommonAnimation("StatDown",target,user)# if fail==-1
    #      fail=0
    #    end
    #  end
    
    # Spiky Shield
    if target.effects[PBEffects::SpikyShield] && thismove.canProtectAgainst? &&
       !target.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
      @battle.successStates[user.index].protected=true
      if thismove.isContactMove? && user.hp>0
        @battle.scene.pbDamageAnimation(user,0)
        amt=user.pbReduceHP((user.totalhp/8).floor)
        @battle.pbDisplay(_INTL("{1} was hurt!",user.pbThis)) if amt>0
      end
      return false
    end
    #  if target.species==666 && user.hp>0
    #    user.pbReduceHP((user.totalhp/6).floor)
    #    pbDisplay(_INTL("{1}'s Spiky Shield hurt {3}!",target.pbThis,
    #      PBItems.getName(target.item),user.pbThis(true)))
    #  end
    #  return false
    #end
    if thismove.function==0x93 # Rage
      @effects[PBEffects::Rage]=true
    end
    if isConst?(user.item,PBItems,:METRONOME)
      if @effects[PBEffects::MetronomeCounter] == -1
        @effects[PBEffects::MetronomeCounter] == 1
        @effects[PBEffects::Metronome] = thismove.id
      end
      if @effects[PBEffects::MetronomeCounter] != 5
        @effects[PBEffects::MetronomeCounter] += 1
      end
      #     Kernel.pbMessage(@effects[PBEffects::MetronomeCounter].to_s)
    end
    if user.hasWorkingAbility(:PENDULUM)
      if @effects[PBEffects::PendulumCounter] == -1
        @effects[PBEffects::PendulumCounter] == 1
        @effects[PBEffects::Pendulum] = thismove.id
      end
      if @effects[PBEffects::PendulumCounter] != 5
        @effects[PBEffects::PendulumCounter] += 1
      end
    end
    if thismove.basedamage>0 && thismove.function!=0x02 #&& # Struggle
       #thismove.function!=0xC1 && thismove.function!=0x111 # Beat Up, Future Sight
      type=thismove.pbType(thismove.type,user,target)
      typemod=thismove.pbTypeModifier(type,user,target)
      # Airborne-based immunity to Ground moves
      if isConst?(type,PBTypes,:GROUND) && target.isAirborne?(user.hasMoldBreaker) &&
         #!isConst?(target.item,PBItems,:IRONBALL) &&
         #!isConst?(thismove.id,PBMoves,:THOUSANDARROWS) &&
         !isConst?(target.item,PBItems,:RINGTARGET) && thismove.function!=0x11C # Smack Down
         #!target.effects[PBEffects::Ingrain] &&
         #!target.effects[PBEffects::SmackDown] &&
         #target.pbOwnSide.effects[PBEffects::Gravity]==0 &&
         #target.pbOpposingSide.effects[PBEffects::Gravity]==0
        if target.hasWorkingAbility(:LEVITATE) && !user.hasMoldBreaker #&&
          #!target.hasWorkingItem(:RINGTARGET) && thismove.function!=0x11C 
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Levitate!",target.pbThis))
          target.effects[PBEffects::TypeIdentified]=true
          return false
        end
        if target.effects[PBEffects::MagnetRise]>0
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Magnet Rise!",target.pbThis))
          return false
        end
        if target.effects[PBEffects::Telekinesis]>0
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Telekinesis!",target.pbThis))
          return false
        end
        if isConst?(target.item,PBItems,:AIRBALLOON)
          @battle.pbDisplay(_INTL("{1}'s Air Balloon makes Ground moves miss!",target.pbThis))
          return false
        end
      end
      #if target.hasWorkingAbility(:WONDERGUARD) && typemod<=4 && type>=0
      #  @battle.pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",target.pbThis))
      #  return false
      #end
      #if typemod==0
      #end
      if typemod==0 && !user.hasWorkingAbility(:PIXILATE) &&
         !user.hasWorkingAbility(:AERILATE) && !user.hasWorkingAbility(:REFRIGERATE) && !user.hasWorkingAbility(:INTOXICATE)
        #raise "faggot"
        user.pbConsumeItem if isConst?(thismove.id,PBMoves,:NATURALGIFT)
        @battle.pbDisplay(_INTL("It doesn't affect\r\n{1}...",target.pbThis))
        target.effects[PBEffects::TypeIdentified]=true
        skipForFutureSight=false
        for i in 0..3
          if self.pokemonIndex==@battle.battlers[i].effects[PBEffects::FutureSightUser]
            if @battle.battlers[i].effects[PBEffects::FutureSight]==0
              skipForFutureSight=true
              break
            end
          end
        end
        user.pbCancelMoves if !skipForFutureSight
        return false 
      end
      #if target.hasWorkingAbility(:WONDERGUARD) && typemod<=4 && type>=0   && !user.hasMoldBreaker
      #  @battle.pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",target.pbThis))
      #  return false 
      #end
    end
    if accuracy
      if target.effects[PBEffects::LockOn]>0 && target.effects[PBEffects::LockOnPos]==user.index
        return true
      end
      miss=false; override=false
      if isConst?(target.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG)
        miss=true unless thismove.function==0x76 || # Earthquake
                         thismove.function==0x95 || # Magnitude
                         isConst?(thismove.id,PBMoves,:FISSURE)
      end
      if isConst?(target.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
        miss=true unless thismove.function==0x75 || # Surf
                         thismove.function==0xD0    # Whirlpool
      end
      if isConst?(target.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) || 
         isConst?(target.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE)
        miss=true unless thismove.function==0x77 ||  # Gust
                         thismove.function==0x15 ||  # Hurricane
                         thismove.function==0x08 ||  # Thunder
                         thismove.function==0x77 ||  # Twister
                         thismove.function==0x11B || # Sky Uppercut
                         thismove.function==0x11C    # Smack Down
                         isConst?(thismove.id,PBMoves,:WHIRLWIND)
      end
      if isConst?(target.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP)
        miss=true unless thismove.function==0x77 ||  # Gust
                         thismove.function==0x15 ||  # Hurricane
                         thismove.function==0x08 ||  # Thunder
                         thismove.function==0x77 ||  # Twister
                         thismove.function==0x11B || # Sky Uppercut
                         thismove.function==0x11C    # Smack Down
      end
      if target.effects[PBEffects::SkyDrop]
        miss=true unless thismove.function==0x08 ||  # Thunder
                         thismove.function==0x15 ||  # Hurricane
                         thismove.function==0x77 ||  # Gust
                         thismove.function==0x78 ||  # Twister
                         thismove.function==0xCE ||  # Sky Drop
                         thismove.function==0x11B || # Sky Uppercut
                         thismove.function==0x11C    # Smack Down
      end
      if target.effects[PBEffects::SpiritAway]
        miss=true unless thismove.function==0x204  # Spirit Away
      end
      if isConst?(target.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) || isConst?(target.effects[PBEffects::TwoTurnAttack],PBMoves,:HYPERSPACE) || isConst?(target.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE)
          miss=true
      end
      miss=false if user.hasWorkingAbility(:NOGUARD) || @battle.futuresight ||
                    target.hasWorkingAbility(:NOGUARD)
      override=true if !miss && turneffects[PBEffects::SkipAccuracyCheck]
      if !override && (miss || !thismove.pbAccuracyCheck(user,target)) # Includes Counter/Mirror Coat
        if thismove.target==PBTargets::AllOpposing && 
           (user.pbOpposing1.hp>0 ? 1 : 0) + (user.pbOpposing2.hp>0 ? 1 : 0) > 1
          # All opposing Pokémon
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.target==PBTargets::AllNonUsers && 
           (user.pbOpposing1.hp>0 ? 1 : 0) + (user.pbOpposing2.hp>0 ? 1 : 0) + (user.pbPartner.hp>0 ? 1 : 0) > 1
          # All non-users
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.function==0xDC # Leech Seed
          @battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
        elsif !user.effects[PBEffects::OHKOFailed]
          @battle.pbDisplay(_INTL("{1}'s attack missed!",user.pbThis))
        end
        return false
      end
      user.effects[PBEffects::OHKOFailed]=false
    end
    return true
  end

  def pbTryUseMove(choice,thismove,turneffects)
    return true if turneffects[PBEffects::PassedTrying]
    if choice[0]!=1# if move was not chosen
      return false
    end
    if @effects[PBEffects::SkyDrop] || @effects[PBEffects::SpiritAway] # Intentionally no message here
      return false
    end
    skipForFutureSight=false
    for i in 0..3
      if self.pokemonIndex==@battle.battlers[i].effects[PBEffects::FutureSightUser]
        if @battle.battlers[i].effects[PBEffects::FutureSight]==0
          skipForFutureSight=true
          break
        end
      end
    end
    if !skipForFutureSight
      if @effects[PBEffects::TwoTurnAttack]>0 ||
         @effects[PBEffects::Outrage]>0 ||
         @effects[PBEffects::HyperBeam]>0 ||
         @effects[PBEffects::Bide]>0 ||
         @effects[PBEffects::Rollout]>0 ||
         @effects[PBEffects::Uproar]>0
        choice[2]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@currentMove))
      elsif @effects[PBEffects::Encore]>0
        if @battle.pbCanShowCommands?(@index) &&
           @battle.pbCanChooseMove?(@index,@effects[PBEffects::EncoreIndex],false)
          PBDebug.log("[Using Encore move]")
          choice[1]=@effects[PBEffects::EncoreIndex]
          choice[2]=@moves[@effects[PBEffects::EncoreIndex]]
          choice[3]=-1 # No target chosen
        end
      end
    end
    thismove=choice[2]
    #pbBeginTurn(choice)
    if !turneffects[PBEffects::SkipAccuracyCheck]
      if self.status==PBStatuses::SLEEP
        if self.hasWorkingAbility(:EARLYBIRD)
          self.statusCount-=2
        else
          self.statusCount-=1
        end
        if self.statusCount<=0
          self.effects[PBEffects::Nightmare]=false
          @battle.pbDisplay(_INTL("{1} woke up!",pbThis))
          self.status=0
        else
          @battle.pbCommonAnimation("Sleep",self,nil)
          @battle.pbDisplay(_INTL("{1} is fast asleep.",pbThis))
          pbSkyDropReset
          @battle.scene.pbShowSprites(self.index) if !self.fainted?
          if thismove.function!=0x11 && # Snore
             thismove.function!=0xB4    # Sleep Talk
            self.effects[PBEffects::SkipTurn]=true
            return false
          end
        end
      end
    end
    if self.status==PBStatuses::FROZEN
      if (thismove.flags&0x40)!=0
        @battle.pbDisplay(_INTL("{1} melted the ice!",pbThis))
        self.status=0
      elsif @battle.pbRandom(5)==0 && !turneffects[PBEffects::SkipAccuracyCheck]
        @battle.pbDisplay(_INTL("{1} was defrosted!",pbThis))
        self.status=0
      elsif (thismove.flags&0x40)==0 # flag g: Thaws user before moving
        @battle.pbCommonAnimation("Frozen",self,nil)
        @battle.pbDisplay(_INTL("{1} is frozen solid!",pbThis))
        @battle.scene.pbShowSprites(self.index) if !self.fainted?
        self.effects[PBEffects::SkipTurn]=true
        return false
      end
    end
    if choice[1]==-2 # Battle Palace
      @battle.pbDisplay(_INTL("{1} appears incapable of using its power!",pbThis))
      self.effects[PBEffects::SkipTurn]=true
      return false  
    end
    if !turneffects[PBEffects::SkipAccuracyCheck]
      if !pbObedienceCheck?(choice)
        return false
      end
    end
    if self.hasWorkingAbility(:TRUANT) && @effects[PBEffects::Truant]
      @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis))
      @battle.scene.pbShowSprites(self.index) if !self.fainted?
      self.effects[PBEffects::SkipTurn]=true
      return false
    end
    # Focus Punch goes here
    if @effects[PBEffects::Flinch] # No Inner Focus check here
      @battle.pbDisplay(_INTL("{1} flinched!",pbThis))
      self.effects[PBEffects::SkipTurn]=true
      @effects[PBEffects::Flinch]=false
      pbSkyDropReset
      if self.hasWorkingAbility(:STEADFAST)
        if !self.pbTooHigh?(PBStats::SPEED)
          @battle.pbAnimation(@id,self,nil)
          pbIncreaseStatBasic(PBStats::SPEED,1)
          @battle.pbCommonAnimation("StatUp",self,nil) if !self.isInvulnerable?
          @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!",self.pbThis,PBAbilities.getName(self.ability)))
        end
      end
      return false
    end
    if !turneffects[PBEffects::SkipAccuracyCheck]
      if @effects[PBEffects::Confusion] > 0
        @effects[PBEffects::Confusion]-=1
        if @effects[PBEffects::Confusion]==0
          @battle.pbDisplay(_INTL("{1} snapped out of confusion!",pbThis))
        else 
          @battle.pbCommonAnimation("Confusion",self,nil) if !self.isInvulnerable?
          @battle.pbDisplayBrief(_INTL("{1} is confused!",pbThis))
        #  Kernel.pb
          if @battle.pbOwnedByPlayer?(@index)
            if @battle.pbRandom(2)==0
              @battle.pbDisplay(_INTL("It hurt itself from its confusion!"))
              self.effects[PBEffects::SkipTurn]=true
              pbConfusionDamage
              pbSkyDropReset
              @battle.scene.pbShowSprites(self.index) if !self.fainted?
              return false
            end
          else
            if @battle.pbRandom(2)==0
              @battle.pbDisplay(_INTL("It hurt itself from its confusion!"))
              self.effects[PBEffects::SkipTurn]=true
              pbConfusionDamage
              pbSkyDropReset
              @battle.scene.pbShowSprites(self.index) if !self.fainted?
              return false
            end
          end
        end
      end
    end
    if !turneffects[PBEffects::SkipAccuracyCheck]
      if self.status==PBStatuses::PARALYSIS
        if @battle.pbRandom(4) == 0
          @battle.pbCommonAnimation("Paralysis",self,nil)
          @battle.pbDisplay(_INTL("{1} is paralyzed! It can't move!",pbThis))
          pbSkyDropReset
          @battle.scene.pbShowSprites(self.index) if !self.fainted?
          self.effects[PBEffects::SkipTurn]=true
          return false
        end
      end
    end
    if !turneffects[PBEffects::SkipAccuracyCheck]
      if @effects[PBEffects::Attract]>=0
        other=@battle.battlers[@effects[PBEffects::Attract]]
          @battle.pbCommonAnimation("Attract",self,nil) if !self.isInvulnerable?
        @battle.pbDisplayBrief(_INTL("{1} is in love with {2}!",pbThis,other.pbThis(true)))
        tempi=2
        tempi=3 if @battle.pbOwnedByPlayer?(@index)
        if @battle.pbRandom(tempi) == 0
          @battle.pbDisplay(_INTL("{1} is immobilized by love!",pbThis))
          pbSkyDropReset
          @battle.scene.pbShowSprites(self.index) if !self.fainted?
          self.effects[PBEffects::SkipTurn]=true
          return false
        end
      end
    end
    # Check for no PP here
    if @effects[PBEffects::Disable]>0 && thismove.id==@effects[PBEffects::DisableMove]
      @battle.pbDisplayPaused(_INTL("{1}'s {2} is disabled!",pbThis,thismove.name))
      @battle.scene.pbShowSprites(self.index) if !self.fainted?
      self.effects[PBEffects::SkipTurn]=true
      return false
    end
    if @effects[PBEffects::HealBlock]>0 && thismove.isHealingMove?
      @battle.pbDisplay(_INTL("{1} can't use {2} because of Heal Block!",pbThis,thismove.name))
      @battle.scene.pbShowSprites(self.index) if !self.fainted?
      self.effects[PBEffects::SkipTurn]=true
      return false
    end
    if @battle.field.effects[PBEffects::Gravity]>0 && choice[2].unusableInGravity?
      @battle.pbDisplay(_INTL("{1} can't use {2} because of gravity!",pbThis,choice[2].name))
      @battle.scene.pbShowSprites(self.index) if !self.fainted?
      self.effects[PBEffects::SkipTurn]=true
      return false
    end
    # Choice locked goes here
    if @effects[PBEffects::Taunt] > 0 && thismove.basedamage == 0
      @battle.pbDisplayPaused(_INTL("{1} can't use {2} after the Taunt!",pbThis,thismove.name))
      @battle.scene.pbShowSprites(self.index) if !self.fainted?
      self.effects[PBEffects::SkipTurn]=true
      return false
    end
    if pbOpposing1.effects[PBEffects::Imprison]
      if thismove.id==pbOpposing1.moves[0].id ||
         thismove.id==pbOpposing1.moves[1].id ||
         thismove.id==pbOpposing1.moves[2].id ||
         thismove.id==pbOpposing1.moves[3].id
        @battle.pbDisplayPaused(_INTL("{1} can't use the sealed {2}!",pbThis,thismove.name))
        @battle.scene.pbShowSprites(self.index) if !self.fainted?
        self.effects[PBEffects::SkipTurn]=true
        PBDebug.log("[#{pbOpposing1.pbThis} has: #{pbOpposing1.moves[0].id}, #{pbOpposing1.moves[1].id},#{pbOpposing1.moves[2].id} #{pbOpposing1.moves[3].id}]")
        return false
      end
    end
    if pbOpposing2.effects[PBEffects::Imprison]
      if thismove.id==pbOpposing2.moves[0].id ||
         thismove.id==pbOpposing2.moves[1].id ||
         thismove.id==pbOpposing2.moves[2].id ||
         thismove.id==pbOpposing2.moves[3].id
        @battle.pbDisplayPaused(_INTL("{1} can't use the sealed {2}!",pbThis,thismove.name))
        @battle.scene.pbShowSprites(self.index) if !self.fainted?
        self.effects[PBEffects::SkipTurn]=true
        PBDebug.log("[#{pbOpposing2.pbThis} has: #{pbOpposing2.moves[0].id}, #{pbOpposing2.moves[1].id},#{pbOpposing2.moves[2].id} #{pbOpposing2.moves[3].id}]")
        return false
      end
    end
    # Lock into choice item here
    # Calling another move comes here. Repeats Heal Block and Gravity checks
    # Change form for Stance Change goes here
    # Move type changing due to Aerilate goes here
    # Set move type for Hidden Power, etc. goes here
    # Check move for type changing due to Electrify, etc.
    # Change Curse target if target is self goes here
    # Check for redirection due to Storm Drain, etc. here
    # Check for redirection due to Follow Me, etc. here
    # Subtract appropriate amount of PP here
    # Move conditions failures part 1:
    #  Sucker Punch/Me First target is invalid
    #  Mat Block/Fake Out conditions
    #  Protection moves fail if no other moves are used this turn, execute otherwise
    #  Destiny Bond: Move is repeated and previous attempt was successful
    #  Fling/Natural Gift: Embargo or Magic Room are in effect, or ineligible item
    #  Stockpile: Existing count is 3
    #  Swallow/Spit Up: Stockpile count is 0
    #  Bide: No energy to unleash
    #  Counter/Mirror Coat/Metal Burst: Target wasn't hit with eligible move
    #  Encore step should get moved here
    #  Rest: User is already asleep
    #  Rest: Has Insomnia/Vital Spirit
    #  Snore/Sleep Talk: User isn't asleep
    #  Future Sight/Doom Desire: Target is already affected
    if status==PBStatuses::FROZEN && (thismove.flags&0x40)!=0 # flag g: Thaws user before moving
      self.status=0
      @battle.pbDisplay(_INTL("{1} was defrosted by {2}!",pbThis,thismove.name))
      pbCheckForm if self.species==PBSpecies::SHAYMIN
    end
    # Check if blocked by Primordial Sea/Desolate Land here
    # Check for failure due to Powder here
    # If move is Future Sight, create the move and exit (does not count as using the move)
    # Fail current Pledge move and trigger teammate to start the conclusion
    # Check if move is blocked by Damp
    # Change type of Pokemon to move type if applicable for Protean
    # Apply Defense boost of Skull Bash, other 2 turn moves are suspended unless a Power Herb, etc. is present
    # Check for move failure due to lack of target
    # Check if move is stolen by pending Snatch. Resume from Heal Block check if so.
    # Reduce HP due to Explosion/Self-destruct but don't fail the move.
    # Move conditions failure part 2:
    #  Rest: Uproar is in effect
    #  Recovery moves other than Rest: user has full HP
    #  Sub/Belly Drum: Not enough HP to use move.
    #  Conversion/Camouflage: User is already designated type
    #  Conversion 2: no prior move, or all resistances to the move's type (if any) are already in user's own types
    #  Sky Drop: target is a teammate
    # Check for failure due to Fly, etc.
    # If non-status move or Thunder Wave and target does not hold a Ring Target, check for type immunity
    # Check for Levitate immunity
    # For Sky Drop, check if target is too heavy
    # Check if move is blocked by Quick Guard/Wide Guard/Crafty Shield
    # Check if move is blocked by Protect/Detect/King's Shield/Spiky Shield
    # Check if move is reflected by Magic Coat
    # If move is Telekinesis, check if fails vs Diglett/Dugtrio/Mega Gengar/Smacked Down/Ingrained Target
    # Check if move is reflected by Magic Bounce
    # Check if move is blocked by mat Block
    # Check for ability-based immunities part 1:
    #  Sap Sipper
    #  Flash Fire
    #  Dry Skin, Storm Drain, Water Absorb
    #  Lightning Rod, Motor Drive, Volt Absorb
    #  Soundproof
    #  Telepathy
    #  Wonderguard
    # Check for Magnet Rise/Telekinesis/Air Balloon immunity
    # Check for Overcoat immunity
    # Check for Safety Goggles immunity
    # Type-based move condition immunities:
    #  Powder moves
    #  Burning moves
    #  Poisoning moves
    #  Paralysis moves
    #  Sheer Cold
    #  Mean Look/Spider Web/Block
    #  Sky Drop coming down
    # Check for other move condition abilities:
    #  Synchronoise
    #  Dream Eater/Nightmare
    #  Attract
    #  Endeavor
    #  Fissure/Horn Drill/Guillotine/Sheer Cold
    # Check for ability-based immunities:
    #  Sturdy
    #  Sticky Hold
    #  Bulletproof
    #  Oblivious
    # Captivate gender immunity
    # If move is Curse, user isn't a ghost, and target isn't itself, change target to self
    # Redundancy checks
    #  Status when target already has one
    #  Creating weather/field effects/pseudo-status
    #  Stat changing moves that can't be raised/lowered
    #  Trick/Switcheroo/Bestow with no item, or unmovable item
    #  Disable/Sketch vs. no move, or ineligible move (note that Encore is checked earlier)
    #  Electrify/Quash/After You when target already made a move this turn
    #  Healing Wish/Lunar Dance with no one to switch to
    #  various other moves whose effects would naturally do nothing
    # Safeguard blocked?
    # Electric/Misty Terrain blocked?
    # Sweet Veil/Insomnia/Vital Spirit/Leaf Guard blocked?
    # Check for move accuracy
    # Blocked by Sub?
    # Mist blocked?
    # Check for ability-based immunities part 3:
    #  Clear Body/White Smoke
    #  Hyper Cutter
    #  Big Pecks
    #  Keen Eye
    #  Aroma Veil
    #  Flower Veil
    #  Water Veil
    #  Immunity
    #  Limber
    #  Own Tempo
    #  Suction Cups
    # Roar/Whirlwind failure due to Ingrain?
    # Apply effect of Brick Break/Pay Day here
    # Execute move
    if @effects[PBEffects::HyperBeam]>0
      @battle.pbDisplay(_INTL("{1} must recharge!",pbThis))
      @battle.scene.pbShowSprites(self.index) if !self.fainted?
      self.effects[PBEffects::SkipTurn]=true
      return false
    end
    # TODO: Torment message goes here
    if @effects[PBEffects::Torment] && thismove.id==@lastMoveUsed &&
       thismove.function!=0x02 && @effects[PBEffects::TwoTurnAttack]==0
      @battle.pbDisplayPaused(_INTL("{1} can't use the same move in a row due to the torment!",pbThis))
      @battle.scene.pbShowSprites(self.index) if !self.fainted?
      return false
    end
    #if self.species==PBSpecies::AEGISLASH
    #  if thismove.basedamage > 0
    #    @battle.pbDisplay(_INTL("{1} was unsheathed!",pbThis))
    #    @pokemon.form=1
    #    pbCheckForm
    #  else
    #     @battle.pbDisplay(_INTL("{1} was sheathed!",pbThis))
    #     @pokemon.form=0
    #     pbCheckForm
    #  end      
    #end
    turneffects[PBEffects::PassedTrying]=true
    return true
  end

  def pbConfusionDamage
    self.damagestate.reset
    confmove=PokeBattle_Confusion.new(@battle,nil)
    confmove.pbEffect(self,self)
    pbFaint if self.hp<=0
  end

  def pbUpdateTargetedMove(thismove,user)
    # TODO: Snatch, moves that use other moves
    if (thismove.target==PBTargets::SingleNonUser ||
       thismove.target==PBTargets::NoTarget ||
       thismove.target==PBTargets::RandomOpposing ||
       thismove.target==PBTargets::AllOpposing) &&
       (thismove.flags&0x10)!=0 && !user.usingsubmove
      @effects[PBEffects::MirrorMove]=thismove.id
    end
    # TODO: All targeting cases
    # Two-turn attacks, Magic Coat, Future Sight, Counter/MirrorCoat/Bide handled
    @effects[PBEffects::Conversion2Move]=thismove.id
    @effects[PBEffects::Conversion2Type]=thismove.pbType(thismove.type,user,self)
  end
=begin
  def pbProcessNonMultiHitMove(thismove,user,target,nocheck=false)
    $templernean=0
    $ismultihit=nil
    if !nocheck && !pbSuccessCheck(thismove,user,target,turneffects,true)
      if thismove.function==0x10B # Hi Jump Kick, Jump Kick
        #TODO: Not shown if message is "It doesn't affect XXX..."
        @battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
        damage=[1,(user.totalhp/2).floor].max
        if damage>0
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP(damage)
        end
        user.pbFaint if user.hp<=0
      end
      user.effects[PBEffects::Rollout]=0 if thismove.function==0xD3 # Rollout
      user.effects[PBEffects::FuryCutter]=0 if thismove.function==0x91 # Fury Cutter
      user.effects[PBEffects::Stockpile]=0 if thismove.function==0x113 # Spit Up
      target.effects[PBEffects::Conversion2Move]=-1
      target.effects[PBEffects::Conversion2Type]=0
      return
    else
      if thismove.function==0xD3 # Rollout
        user.effects[PBEffects::Rollout]=5 if user.effects[PBEffects::Rollout]==0
        user.effects[PBEffects::Rollout]-=1
        user.currentMove=thismove.id
      end
      if thismove.function==0x91 # Fury Cutter
        user.effects[PBEffects::FuryCutter]+=1 if user.effects[PBEffects::FuryCutter]<4
      else
        user.effects[PBEffects::FuryCutter]=0
      end
      if thismove.function==0x92 # Echoed Voice
        user.effects[PBEffects::EchoedVoice]+=1 if user.effects[PBEffects::EchoedVoice]<5
      else
        user.effects[PBEffects::EchoedVoice]=0
      end
    end
 
 #   begin

    damage=thismove.pbEffect(user,target) # Recoil/drain, etc. are applied here
#  rescue Exception => e
#    Kernel.pbMessage(e.message)
#  end
  
#if damage && damage!= 0
    if user.hp<=0
      user.pbFaint # no return
    end
    @battle.pbJudgeCheckpoint(user,thismove)
    if damage>=0
      # attack is successful
      @battle.successStates[user.index].useState=2
      @battle.successStates[user.index].typemod=target.damagestate.typemod
    end
 #   for movefunction in [
    if !user.hasWorkingAbility(:SHEERFORCE)# && (thismove.flags&0x8000) == 0
    # Additional effect
    if target.damagestate.calcdamage>0 && !target.damagestate.substitute &&
      (user.hasMoldBreaker || !target.hasWorkingAbility(:SHIELDDUST))
       
 
      # TODO: Shield Dust doesn't affect additional effects that
      # affect only the attack's user
      addleffect=thismove.addlEffect
      if user.hasWorkingAbility(:SERENEGRACE)
        addleffect*=2
      end
      #vaccine=false
      #for battler in @battle.battlers
      #  vaccine=true if (battler.ability==PBAbilities::VAPORIZATION && !battler.effects[PBEffects:GastroAcid])
      #end
      #if battler.pbHasType?(PBTypes::WATER) && vaccine
      #  add1effect=0
      #end
       
      
      if @battle.pbRandom(100)<addleffect 
        thismove.pbAdditionalEffect(user,target)
      end
      canflinch=false
      if (isConst?(user.item,PBItems,:KINGSROCK) || isConst?(user.item,PBItems,:RAZORFANG)) &&
         (thismove.flags&0x20)!=0 # flag f: King's Rock
        canflinch=true
      end
      if user.hasWorkingAbility(:STENCH)
         thismove.function!=0x009 && # Thunder Fang
         thismove.function!=0x00B && # Fire Fang
         thismove.function!=0x00E && # Ice Fang
         thismove.function!=0x00F && # flinch-inducing moves
         thismove.function!=0x010 && # Stomp
         thismove.function!=0x011 && # Snore
         thismove.function!=0x012 && # Fake Out
         thismove.function!=0x078 && # Twister
         thismove.function!=0x0C7    # Sky Attack
          canflinch=true
        end
      if canflinch && @battle.pbRandom(10)==0
        target.pbFlinch(user)
      end
    end
 
    # Rage
    if target.hp>0 && target.effects[PBEffects::Rage] &&
       target.pbIsOpposing?(user.index) && damage>0 
      # TODO: Apparently triggers if opposing Pokémon uses Future Sight after a Future Sight attack
      if !target.pbTooHigh?(PBStats::ATTACK)
        target.pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbCommonAnimation("StatUp",target,self)
        @battle.pbDisplay(_INTL("{1}'s rage is building!",target.pbThis))
      end
    end
    # Defrost
    if target.damagestate.calcdamage>0 && !target.fainted? && target.status==PBStatuses::FROZEN &&
       (isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:FIRE) ||
       (isConst?(thismove.id,PBMoves,:SCALD) || isConst?(thismove.id,PBMoves,:STEAMERUPTION)))
      @battle.pbDisplay(_INTL("{1} was defrosted!",target.pbThis))
      target.status=0
    end
    pbEffectsOnDealingDamage(thismove,user,target,damage)
    # Grudge
    if target.effects[PBEffects::Grudge] && user.hp>0 && target.hp<=0
      @battle.pbDisplay(_INTL("{1}'s {2} lost all PP due to the Grudge!",user.pbThis,thismove.name))
      thismove.pp=0
    end
 
    # Destiny Bond
    if thismove.function!=0xC1 && # Beat Up
       target.effects[PBEffects::DestinyBond] && user.hp>0 && target.hp<=0
      @battle.pbDisplay(_INTL("{1} took {2} with it!",target.pbThis,user.pbThis(true)))
      user.pbReduceHP(user.hp)
      user.pbFaint # no return
      @battle.pbJudgeCheckpoint(user)
    end
  end
  if thismove.id==PBMoves::RELICSONG && isConst?(user.species,PBSpecies,:MELOETTA) && user.pokemon.form == 0
      user.pokemon.form=1
      pbCheckForm
    elsif thismove.id==PBMoves::RELICSONG && isConst?(user.species,PBSpecies,:MELOETTA)
      user.pokemon.form=0
      pbCheckForm
      
    end
  if thismove.id==PBMoves::RELICSONG && isConst?(user.species,PBSpecies,:DELTAMELOETTA) && user.pokemon.form == 0
      user.pokemon.form=1
      pbCheckForm
    elsif thismove.id==PBMoves::RELICSONG && isConst?(user.species,PBSpecies,:DELTAMELOETTA)
      user.pokemon.form=0
      pbCheckForm
      
    end
 
    # Opponent faints if 0 HP
    if target.hp<=0
      target.pbFaint # no return
    end
 
    # Ability effects
    @battle.pbAbilityEffect(thismove,user,target,damage)
    
    for j in 0..3
      @battle.battlers[j].pbBerryCureCheck
    end
 
    if user.hp<=0
      user.pbFaint # no return
    end
    # Sticky Barb
    #if isConst?(target.item,PBItems,:STICKYBARB) && user.item==0 && user.hp>0 &&
    #   target.effects[PBEffects::Substitute]==0 && damage>0 &&
    #   (thismove.flags&0x01)!=0 # flag A: Makes contact
    #  user.item=target.item
    #  target.item=0
    #  target.effects[PBEffects::Unburden]=true
    #  if !@battle.opponent && !@battle.pbIsOpposing?(user.index)
    #    if user.pokemon.itemInitial==0 && target.pokemon.itemInitial==user.item(true)
    #      user.pokemon.itemInitial=user.item(true)
    #      target.pokemon.itemInitial=0
    #    end

    #  end
    #  @battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
    #     target.pbThis,PBItems.getName(user.item),user.pbThis(true)))
    #end
    
    if !(user.hasWorkingAbility(:SHEERFORCE) && thismove.addlEffect>0)
      # Target's held items:
      # Red Card
      if target.hasWorkingItem(:REDCARD) && @battle.pbCanSwitch?(user.index,-1,false)
        user.effects[PBEffects::Roar]=true
        @battle.pbDisplay(_INTL("{1} held up its {2} against the {3}!",
           target.pbThis,PBItems.getName(target.item),user.pbThis(true)))
        target.pbConsumeItem
      # Eject Button
      elsif target.hasWorkingItem(:EJECTBUTTON) && @battle.pbCanChooseNonActive?(target.index)
        target.effects[PBEffects::Uturn]=true
        @battle.pbDisplay(_INTL("{1} is switched out with the {2}!",
           target.pbThis,PBItems.getName(target.item)))
        target.pbConsumeItem
      end
      # Shell Bell
      if isConst?(user.item,PBItems,:SHELLBELL) && damage > 0 && user.hp>0 && user.effects[PBEffects::HealBlock]==0
        hpgain=user.pbRecoverHP((damage/8).floor)
        if hpgain>0
          @battle.pbDisplay(_INTL("{1}'s Shell Bell restored its HP a little!",user.pbThis))
        end
      end
    end
    
    target.pbUpdateTargetedMove(thismove,user)
    # @battle.pbDisplayPaused("Regur16")

  end
=end
=begin
  def pbProcessMultiHitMove(thismove,user,target,numhits,lernean=false)
    # Includes Triple Kick
    realnumhits=0
    for i in 0...numhits
      if !pbSuccessCheck(thismove,user,target,i==0 || thismove.function==0xBF) # Triple Kick
        target.effects[PBEffects::Conversion2Move]=-1
        target.effects[PBEffects::Conversion2Type]=0
        if thismove.function==0xBF && i>0 # Triple Kick
          break # considered a success if Triple Kick hits at least once
        else
          return
        end
      end
      # Count a hit for Parental Bond if it applies
      user.effects[PBEffects::ParentalBond]-=1 if user.effects[PBEffects::ParentalBond]>0
      # This hit will happen; count it
      realnumhits+=1

      kang = false
      #kang = true if i == 1 && user.hasWorkingAbility(:PARENTALBOND)
      kang = true if i == 1 && user.hasWorkingAbility(:REGURGITATION)
      $templernean=numhits if lernean
      #$tempkang=kang
      $ismultihit=true
      damage=thismove.pbEffect(user,target).ceil # Recoil/drain, etc. are applied here

      return if target.damagestate.calcdamage<=0

      # Critical hit message
      if target.damagestate.critical
        @battle.pbDisplay(_INTL("A critical hit!"))
      end
      @battle.pbJudgeCheckpoint(user,thismove)

      # Rage
      if target.hp>0 && target.effects[PBEffects::Rage] &&
         target.pbIsOpposing?(user.index) && damage>0 
        if !target.pbTooHigh?(PBStats::ATTACK)
          target.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",target,self)
          @battle.pbDisplay(_INTL("{1}'s Rage is building!",target.pbThis))
        end
      end

      # Ability effects
      @battle.pbAbilityEffect(thismove,user,target,damage)

      # Berry check (maybe just called by ability effect, since only necessary Berries are checked)
      for j in 0..3
        @battle.battlers[j].pbBerryCureCheck
      end

      # Shell Bell
      if isConst?(user.item,PBItems,:SHELLBELL) && damage > 0 && user.hp>0
        hpgain=user.pbRecoverHP((damage/8).floor)
        if hpgain>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP a little!",user.pbThis,
             PBItems.getName(user.item)))
        end
      end

      # Endure
      if target.damagestate.endured
        @battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
        break
      end

      target.pbUpdateTargetedMove(thismove,user)

      break if user.hp<=0
      break if target.hp<=0
    end

    # attack is successful
    @battle.successStates[user.index].useState=2
    @battle.successStates[user.index].typemod=target.damagestate.typemod

    # Focus Band
    if target.damagestate.focusbandused
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",target.pbThis))
    end
    # Focus Sash
    if target.damagestate.focussashused
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",target.pbThis))
    end
    # Sturdy
    if target.damagestate.sturdy
      @battle.pbDisplay(_INTL("{1} hung on with Sturdy!",target.pbThis))
    end
    # Type effectiveness
    if target.damagestate.typemod>=1&&target.damagestate.typemod<4
      @battle.pbDisplay(_INTL("It's not very effective..."))
    end
    if target.damagestate.typemod>4
      @battle.pbDisplay(_INTL("It's super effective!"))
    end

    # Number of hits
    @battle.pbDisplay(_INTL("Hit {1} time(s)!",realnumhits))
    # Opponent faints if 0 HP
    if target.hp<=0
      target.pbFaint # no return
    end
    if user.hp<=0
      user.pbFaint # no return
    end
    # Additional effect
    if target.damagestate.calcdamage>0 && !user.hasWorkingAbility(:SHEERFORCE) &&
         (user.hasMoldBreaker || !target.hasWorkingAbility(:SHIELDDUST))
      addleffect=thismove.addlEffect
      if user.hasWorkingAbility(:SERENEGRACE)
        addleffect*=2
      end
      if @battle.pbRandom(100)<addleffect
        thismove.pbAdditionalEffect(user,target)
      end
      if (isConst?(user.item,PBItems,:KINGSROCK) || isConst?(user.item,PBItems,:RAZORFANG)) &&
         (thismove.flags&0x20)!=0 && @battle.pbRandom(10)==0 # flag f: King's Rock
        if !target.hasWorkingAbility(:INNERFOCUS) && 
           target.effects[PBEffects::Substitute]==0
          target.effects[PBEffects::Flinch]=true
        end
      end
      if user.hasWorkingAbility(:STENCH) && @battle.pbRandom(10)==0
        if !target.hasWorkingAbility(:INNERFOCUS) &&
           target.effects[PBEffects::Substitute]==0 &&
           thismove.function!=0x009 && # Thunder Fang
           thismove.function!=0x00B && # Fire Fang
           thismove.function!=0x00E && # Ice Fang
           thismove.function!=0x00F && # flinch-inducing moves
           thismove.function!=0x010 && # Stomp
           thismove.function!=0x011 && # Snore
           thismove.function!=0x012 && # Fake Out
           thismove.function!=0x078 && # Twister
           thismove.function!=0x0C7    # Sky Attack
          target.effects[PBEffects::Flinch]=true
        end
      end
    end
    # TODO: If Poison Point, etc. triggered above, user's Synchronize somehow triggers
    # here even if condition is removed before now [true except for Triple Kick]
    # Berry check
    for j in 0..3
      @battle.battlers[j].pbBerryCureCheck
    end
    target.pbUpdateTargetedMove(thismove,user)
  end

  def pbProcessBeatUp(thismove,user,target)
    return if !pbSuccessCheck(thismove,user,target,true)
    numhits=0
    party=@battle.pbParty(@index) # NOTE: Considers both parties in multi battles
    for i in 0...party.length
      if party[i] && party[i].hp>0 && party[i].status==0 && !party[i].egg?
        thismove.pbSetThisPkmn(party[i])
        pbProcessNonMultiHitMove(thismove,user,target,true)
        numhits+=1
      end
    end
    if numhits==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return
    else
      @battle.pbDisplay(_INTL("Hit {1} time(s)!",numhits))
    end
  end
=end
  
  def pbProcessMoveAgainstTarget(thismove,user,target,numhits,turneffects,nocheck=false)
    realnumhits=0
		totaldamage=0
		destinybond=false
=begin
			if !pbSuccessCheck(thismove,user,target,i==0 || thismove.function==0xBF) # Triple Kick
				target.effects[PBEffects::Conversion2Move]=-1
				target.effects[PBEffects::Conversion2Type]=0
				if thismove.function==0xBF && i>0 # Triple Kick
					break # considered a success if Triple Kick hits at least once
				else
					return
				end
			end
			kang = false
			kang = true if i == 1 && user.hasWorkingAbility(:REGURGITATION)
			$templernean=numhits if lernean
			$ismultihit=true

			return if target.damagestate.calcdamage<=0

			# Critical hit message
			if target.damagestate.critical
				@battle.pbDisplay(_INTL("A critical hit!"))
			end
			@battle.pbJudgeCheckpoint(user,thismove)

			# Shell Bell
			if isConst?(user.item,PBItems,:SHELLBELL) && damage > 0 && user.hp>0
				hpgain=user.pbRecoverHP((damage/8).floor)
				if hpgain>0
					@battle.pbDisplay(_INTL("{1}'s {2} restored its HP a little!",user.pbThis,
					    PBItems.getName(user.item)))
				end
			end
			# Endure
			if target.damagestate.endured
				@battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
				break
			end

			target.pbUpdateTargetedMove(thismove,user)

			break if user.hp<=0
			break if target.hp<=0
		end
		
		if !(user.hasWorkingAbility(:SHEERFORCE) && thismove.addlEffect>0)
			# Target's held items:
			# Red Card
			if target.hasWorkingItem(:REDCARD) && @battle.pbCanSwitch?(user.index,-1,false)
				user.effects[PBEffects::Roar]=true
				@battle.pbDisplay(_INTL("{1} held up its {2} against the {3}!",
				    target.pbThis,PBItems.getName(target.item),user.pbThis(true)))
				target.pbConsumeItem
			# Eject Button
			elsif target.hasWorkingItem(:EJECTBUTTON) && @battle.pbCanChooseNonActive?(target.index)
				target.effects[PBEffects::Uturn]=true
				@battle.pbDisplay(_INTL("{1} is switched out with the {2}!",
				    target.pbThis,PBItems.getName(target.item)))
				target.pbConsumeItem
			end
		    # Shell Bell
		    if isConst?(user.item,PBItems,:SHELLBELL) && damage > 0 && user.hp>0 && user.effects[PBEffects::HealBlock]==0
				hpgain=user.pbRecoverHP((damage/8).floor)
				if hpgain>0
				  @battle.pbDisplay(_INTL("{1}'s Shell Bell restored its HP a little!",user.pbThis))
				end
			end
		end
		
		vaccine=false
		for battler in @battle.battlers
			vaccine=true if (battler.ability==PBAbilities::VAPORIZATION && !battler.effects[PBEffects:GastroAcid])
		end
		if battler.pbHasType?(PBTypes::WATER) && vaccine
			add1effect=0
		end
=end
    onField=false
    for i in 0...4
      if user==@battle.battlers[i]
        onField=true
        break
      end
    end
		for i in 0...numhits
			# Check success (accuracy/evasion calculation)
			if !nocheck && !pbSuccessCheck(thismove,user,target,turneffects,true)
        if thismove.function==0xBF && realnumhits>0   # Triple Kick
          break   # Considered a success if Triple Kick hits at least once
				elsif thismove.function==0x10B # Hi Jump Kick, Jump Kick
					#TODO: Not shown if message is "It doesn't affect XXX..."
					@battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
					damage=[1,(user.totalhp/2).floor].max
					if damage>0
					  @battle.scene.pbDamageAnimation(user,0)
					  user.pbReduceHP(damage)
					end
					user.pbFaint if user.hp<=0 && onField
				end
				user.effects[PBEffects::Rollout]=0 if thismove.function==0xD3 # Rollout
				user.effects[PBEffects::FuryCutter]=0 if thismove.function==0x91 # Fury Cutter
				user.effects[PBEffects::Stockpile]=0 if thismove.function==0x113 # Spit Up
				target.effects[PBEffects::Conversion2Move]=-1
				target.effects[PBEffects::Conversion2Type]=0
				return
			else
        if !nocheck && (user.hasWorkingAbility(:LERNEAN) || numhits>1)
          nocheck=true
        end
			    # Add to counters for moves which increase them when used in succession
				
				# TODO: May need to move Rollout to within its MoveEffect class
				if thismove.function==0xD3 # Rollout
					user.effects[PBEffects::Rollout]=5 if user.effects[PBEffects::Rollout]==0
					user.effects[PBEffects::Rollout]-=1
					user.currentMove=thismove.id
				end
				if thismove.function==0x91 # Fury Cutter
					user.effects[PBEffects::FuryCutter]+=1 if user.effects[PBEffects::FuryCutter]<3
          user.effects[PBEffects::FuryCutterUsed]=true
				else
					user.effects[PBEffects::FuryCutter]=0
				end
				if thismove.function==0x92 # Echoed Voice
					#user.effects[PBEffects::EchoedVoice]+=1 if user.effects[PBEffects::EchoedVoice]<5
          #Kernel.pbMessage(_INTL("{1}",user.effects[PBEffects::EchoedVoice].to_s))
				#else
					#user.effects[PBEffects::EchoedVoice]=0
          #Kernel.pbMessage(_INTL("{1}",user.effects[PBEffects::EchoedVoice].to_s))
				#end
          if !user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed] &&
             user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]<5
            user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]+=1
          end
          user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed]=true
        end
			end
			# Count a hit for Parental Bond, Lernean, and Aura Blast if it applies
			user.effects[PBEffects::ParentalBond]-=1 if user.effects[PBEffects::ParentalBond]>0
			user.effects[PBEffects::LerneanCounter]-=1 if user.effects[PBEffects::LerneanCounter]>0
			if thismove.function==0x216
        user.effects[PBEffects::AuraBlastCharges]-=1 if user.effects[PBEffects::AuraBlastCharges]>0
      end
      # This hit will happen; count it
			realnumhits+=1
			# Damage calculation and/or main effect
			damage=thismove.pbEffect(user,target).ceil # Recoil/drain, etc. are applied here
      totaldamage+=damage if damage>0
      # Message and consume for type-weakening berries
      if target.damagestate.berryweakened
        #@battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",
        #   PBItems.getName(target.item),target.pbThis(true)))
        target.pbConsumeItem
      end
      if user.damagestate.gemused
        #@battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",
        #   PBItems.getName(target.item),target.pbThis(true)))
        user.pbConsumeItem
      end
      # Illusion
      if target.effects[PBEffects::Illusion] && #target.hasWorkingAbility(:ILLUSION) &&
         damage>0 && !target.damagestate.substitute   
        target.effects[PBEffects::Illusion]=nil
        @battle.scene.pbChangePokemon(target,target.pokemon,false,nil,false,true)
        @battle.pbDisplay(_INTL("{1}'s Illusion wore off!",target.pbThis))
      end
      user.pbFaint if user.fainted? && onField # no return
			return if numhits>1 && target.damagestate.calcdamage<=0
			@battle.pbJudgeCheckpoint(user,thismove)
      # Prevent additional effects from activating until all hits have been conducted for Lernean
      if user.effects[PBEffects::LerneanCounter]<=1
        # Additional effect
        if target.damagestate.calcdamage>0 && 
           !user.hasWorkingAbility(:SHEERFORCE) &&
           (user.hasMoldBreaker || !target.hasWorkingAbility(:SHIELDDUST))
          addleffect=thismove.addlEffect
          addleffect*=2 if (user.hasWorkingAbility(:SERENEGRACE) || 
                           user.pbOwnSide.effects[PBEffects::Rainbow]>0) && 
                           thismove.function!=0xA4
          if @battle.pbRandom(100)<addleffect
            thismove.pbAdditionalEffect(user,target)
          end
        end
      end
      # Ability effects
      @battle.pbAbilityEffect(thismove,user,target,damage) # <--Move these later     
      pbEffectsOnDealingDamage(thismove,user,target,damage)
			# Grudge
			if !user.fainted? && target.fainted? &&
         !isConst?(thismove.id,PBMoves,:FUTURESIGHT) && 
         !isConst?(thismove.id,PBMoves,:DOOMDESIRE)
				if target.effects[PBEffects::Grudge] #&& target.pbIsOpposing?(user.index)
          twoturnary=[
            0xC3,
            0xC4,
            0xC5,
            0xC6,
            0xC7,
            0xC8,
            0xC9,
            0xCA,
            0xCB,
            0xCC,
            0xCD,
            0xCE,
            0x138,
            0x204
          ]
          if twoturnary.include?(thismove.function)
            for i in 0..3
              if user.moves[i].name==thismove.name
                pbSetPP(user.moves[i],0)
              end
            end
          else
            #thismove.pp=0
            pbSetPP(thismove,0)
          end
					@battle.pbDisplay(_INTL("{1}'s {2} lost all PP due to the Grudge!",user.pbThis,thismove.name))
				end
			end
			if target.fainted?
				destinybond=destinybond || target.effects[PBEffects::DestinyBond]
			end
			user.pbFaint if user.fainted? && onField # no return
			break if user.fainted? && onField
			break if target.fainted?
			if target.damagestate.calcdamage>0 && !target.damagestate.substitute
				if user.hasMoldBreaker || !target.hasWorkingAbility(:SHIELDDUST)
					canflinch=false
          if (isConst?(user.item,PBItems,:KINGSROCK) || isConst?(user.item,PBItems,:RAZORFANG)) &&
             (thismove.flags&0x20)!=0 # flag f: King's Rock
            canflinch=true
          end
          if user.hasWorkingAbility(:STENCH) &&
             thismove.function!=0x009 && # Thunder Fang
             thismove.function!=0x00B && # Fire Fang
             thismove.function!=0x00E && # Ice Fang
             thismove.function!=0x00F && # flinch-inducing moves
             thismove.function!=0x010 && # Stomp
             thismove.function!=0x011 && # Snore
             thismove.function!=0x012 && # Fake Out
             thismove.function!=0x078 && # Twister
             thismove.function!=0x0C7    # Sky Attack
            canflinch=true
          end
          if canflinch && @battle.pbRandom(10)==0
            target.pbFlinch(user)
          end
				end
			end
			if target.damagestate.calcdamage>0 && !target.fainted?
				# Defrost
				if target.status==PBStatuses::FROZEN &&
				   (isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:FIRE) ||
				   (isConst?(thismove.id,PBMoves,:SCALD) || isConst?(thismove.id,PBMoves,:STEAMERUPTION)))
					@battle.pbDisplay(_INTL("{1} was defrosted!",target.pbThis))
					target.status=0
				end
				# Rage
				if target.hp>0 && target.effects[PBEffects::Rage] #&& target.pbIsOpposing?(user.index) 
					if !target.pbTooHigh?(PBStats::ATTACK)
						target.pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battle.pbCommonAnimation("StatUp",target,target) if !target.isInvulnerable?
						@battle.pbDisplay(_INTL("{1}'s rage is building!",target.pbThis))
					end
				end
			end
			target.pbFaint if target.fainted? # no return
			user.pbFaint if user.fainted? && onField # no return
			break if (user.fainted? && onField) || target.fainted?
			# Berry check (maybe just called by ability effect, since only necessary Berries are checked)
			for j in 0..3
        @battle.battlers[j].pbBerryCureCheck(true)
			end
			break if (user.fainted? && onField) || target.fainted?
			target.pbUpdateTargetedMove(thismove,user)
			break if target.damagestate.calcdamage<=0
		end
    skipForFutureSight=false
    for i in 0..3
      if user.pokemonIndex==@battle.battlers[i].effects[PBEffects::FutureSightUser]
        if @battle.battlers[i].effects[PBEffects::FutureSight]==0
          skipForFutureSight=true
          break
        end
      end
    end
    @battle.scene.pbShowSprites(user.index) if user.effects[PBEffects::TwoTurnAttack]==0 && !user.fainted? && !skipForFutureSight
		turneffects[PBEffects::TotalDamage]+=totaldamage if totaldamage>0
		# Battle Arena only - attack is successful
		@battle.successStates[user.index].useState=2
    if totaldamage>0
      @battle.successStates[user.index].typemod=target.damagestate.typemod
    else
      @battle.successStates[user.index].typemod=4
    end
		# Type effectiveness
		if numhits>1 && !(user.hasWorkingAbility(:LERNEAN) && !thismove.pbIsMultiHit)
			if target.damagestate.typemod>4
				#if alltargets.length>1
				#	@battle.pbDisplay(_INTL("It's super effective on {1}!",target.pbThis(true)))
				#else
        @battle.pbDisplay(_INTL("It's super effective!"))
				#end
			elsif target.damagestate.typemod>=1 && target.damagestate.typemod<4
				#if alltargets.length>1
				#	@battle.pbDisplay(_INTL("It's not very effective on {1}...",target.pbThis(true)))
				#else
        @battle.pbDisplay(_INTL("It's not very effective..."))
				#end
			end
		end
    if numhits>1
      if realnumhits==1
				@battle.pbDisplay(_INTL("Hit {1} time!",realnumhits))
			else
				@battle.pbDisplay(_INTL("Hit {1} times!",realnumhits))
			end
    end
    if user.effects[PBEffects::Outrage]>0 #&& attacker.effects[PBEffects::LerneanCounter]<=1 #&& attacker.effects[PBEffects::ParentalBond]==0
      user.effects[PBEffects::Outrage]-=1
      if user.effects[PBEffects::Outrage]==0 &&
         user.effects[PBEffects::Confusion]==0 &&
         !user.hasWorkingAbility(:OWNTEMPO)
        user.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
        @battle.pbCommonAnimation("Confusion",user,nil)
        @battle.pbDisplay(_INTL("{1} became confused due to fatigue!",user.pbThis))
      end
    end
		# Faint if 0 HP
		target.pbFaint if target.fainted? # no return
		user.pbFaint if user.fainted? && onField # no return
    thismove.pbEffectAfterHit(user,target,turneffects)
		target.pbFaint if target.fainted? # no return
		user.pbFaint if user.fainted? && onField # no return
		# Destiny Bond
		if !user.fainted? && target.fainted?
			if destinybond && target.pbIsOpposing?(user.index)
				@battle.pbDisplay(_INTL("{1} took {2} with it!",target.pbThis,user.pbThis(true)))
				user.pbReduceHP(user.hp)
				user.pbFaint # no return
				@battle.pbJudgeCheckpoint(user)
			end
		end
    pbEffectsAfterHit(user,target,thismove,turneffects)
		# TODO: If Poison Point, etc. triggered above, user's Synchronize somehow triggers
		# here even if condition is removed before now [true except for Triple Kick]
		# Berry check
		for j in 0..3
		  @battle.battlers[j].pbBerryCureCheck(true)
		end
    
    target.pbUpdateTargetedMove(thismove,user)
	end

  def pbUseMoveSimple(moveid,index=-1,target=-1)
    choice=[]
    choice[0]=1
    choice[1]=index
    choice[2]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(moveid))
    choice[2].pp=-1
    choice[3]=target
    if index>=0
      @battle.choices[@index][1]=index
    end
    @usingsubmove=true
    pbUseMove(choice,true)
    @usingsubmove=false
    return #ret
  end

  def pbUseMove(choice,specialusage=false)
    turneffects=[]
    turneffects[PBEffects::SpecialUsage]=specialusage
    turneffects[PBEffects::SkipAccuracyCheck]=(specialusage && choice[2]!=@battle.struggle)
    turneffects[PBEffects::PassedTrying]=false
    turneffects[PBEffects::TotalDamage]=0
    pbBeginTurn(choice)
    if choice[0]!=1 # if move was not chosen
      return #false
    end
    thismove=choice[2]
    if !thismove || thismove.id==0 # if move was not chosen
      return #false
    end
    targets=[]
    user=pbFindUser(choice,targets)
    # Primordial Sea, Desolate Land
    #if @effects[PBEffects::Powder] && isConst?(thismove.type,PBTypes,:FIRE)
    #  @battle.pbDisplay("The powder around {1} exploded!",pbThis)
    #  pbReduceHP((@totalhp/25).floor)
    #  pbFaint if @hp<1
    #  return #false
    #end
    # Stance Change
    if isConst?(@ability,PBAbilities,:STANCECHANGE) && isConst?(species,PBSpecies,:AEGISLASH) &&
       !@effects[PBEffects::Transform]
      if !thismove.pbIsStatus? && self.form!=1
        self.form=1
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon) if @effects[PBEffects::Substitute]==0
        @battle.pbDisplay(_INTL("{1} changed to Blade Forme!",pbThis))
      elsif isConst?(thismove.id,PBMoves,:KINGSSHIELD) && self.form!=0
        self.form=0
        pbUpdate(true)
        @battle.scene.pbChangePokemon(self,@pokemon) if @effects[PBEffects::Substitute]==0
        @battle.pbDisplay(_INTL("{1} changed to Shield Forme!",pbThis))
      end      
    end
    # Record that user has used a move this round (or at least tried to)
    self.lastRoundMoved=@battle.turncount
    Kernel.pbPushRecent("3")
    if !pbTryUseMove(choice,thismove,turneffects)
      self.lastMoveUsedType=-1
      self.lastMoveUsed=-1
      if !turneffects[PBEffects::SpecialUsage]
        self.lastMoveUsedSketch=-1 if self.effects[PBEffects::TwoTurnAttack]==0
      end
      self.lastMoveCalled=-1
      skipForFutureSight=false
      for i in 0..3
        if self.pokemonIndex==@battle.battlers[i].effects[PBEffects::FutureSightUser]
          if @battle.battlers[i].effects[PBEffects::FutureSight]==0
            skipForFutureSight=true
            break
          end
        end
      end
      pbCancelMoves if !skipForFutureSight
      @battle.pbGainEXP
      pbEndTurn(choice)
      @battle.pbJudge
      return
    end
    return if !thismove || thismove.id==0   # if move was not chosen
    thismove=choice[2]
    if !turneffects[PBEffects::SpecialUsage]
      if !pbReducePP(thismove)
        @battle.pbDisplay(_INTL("{1} used\r\n{2}!",pbThis,thismove.name))
        @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
        self.lastMoveUsedSketch=thismove.id if self.effects[PBEffects::TwoTurnAttack]==0
        self.lastMoveUsed=-1
        self.lastMoveCalled=-1
        pbEndTurn(choice)
        @battle.pbJudge
        return
      end
    end
    ret=0
    targetOverride=false
    if thismove.pbTwoTurnAttack(self)
      # Beginning use of two-turn attack
      @effects[PBEffects::TwoTurnAttack]=thismove.id
      @currentMove=thismove.id
      targetOverride=PBTargets::User
    else
      skipForFutureSight=false
      for i in 0..3
        if self.pokemonIndex==@battle.battlers[i].effects[PBEffects::FutureSightUser]
          if @battle.battlers[i].effects[PBEffects::FutureSight]==0
            skipForFutureSight=true
            break
          end
        end
      end
      if !skipForFutureSight
        @effects[PBEffects::TwoTurnAttack]=0 # Cancel use of two-turn attack
      end
    end
    case thismove.pbDisplayUseMessage(self)
    when 2 # Continuing Bide
      self.lastMoveUsed=-1
      self.lastMoveCalled=-1
      return #true
    when 1 # Starting Bide
      self.lastMoveUsed=thismove.id
      self.lastMoveUsedType=thismove.pbType(thismove.type,self,nil)
      if !turneffects[PBEffects::SpecialUsage]
        self.lastMoveUsedSketch=thismove.id if self.effects[PBEffects::TwoTurnAttack]==0
      end
      self.lastMoveCalled=thismove.id
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=self.index
      @battle.successStates[self.index].useState=2
      @battle.successStates[self.index].typemod=4
      return #true
    when -1 # Focus Punch
      #self.lastMoveUsed=thismove.id
      #self.lastMoveUsedType=thismove.pbType(thismove.type,self,nil)
      #if !turneffects[PBEffects::SpecialUsage]
      #  self.lastMoveUsedSketch=thismove.id if self.effects[PBEffects::TwoTurnAttack]==0
      #end
      #self.lastMoveCalled=thismove.id
      #@battle.lastMoveUsed=thismove.id
      #@battle.lastMoveUser=self.index
      @battle.successStates[self.index].useState=2 # somehow treated as a success
      @battle.successStates[self.index].typemod=4
      return #true
    end
    targets=[]
    user=pbFindUser(choice,targets)
    # assume failure 
    @battle.successStates[user.index].useState=1
    @battle.successStates[user.index].typemod=4
    selffaint=(thismove.function==0xE0)||(thismove.function==0xE1) # Selfdestruct
    Kernel.pbPushRecent("4")

    if !thismove.pbOnStartUse(user) # Used by Magnitude/Selfdestruct/etc.
      user.lastMoveUsed=thismove.id
      user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
      if !turneffects[PBEffects::SpecialUsage]
        user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
      end
      user.lastMoveCalled=thismove.id
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=user.index
      return #false
    end
    if !thismove.pbIsStatus?
      case @battle.pbWeather
      when PBWeather::HEAVYRAIN
        if isConst?(thismove.pbType(thismove.type,user,nil),PBTypes,:FIRE)
          @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
          user.effects[PBEffects::SkipTurn]=true
          user.lastMoveUsed=thismove.id
          user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
          if !turneffects[PBEffects::SpecialUsage]
            user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
          #  user.lastRegularMoveUsed=thismove.id
          end
          @battle.lastMoveUsed=thismove.id
          @battle.lastMoveUser=user.index
          return
        end
      when PBWeather::HARSHSUN
        if isConst?(thismove.pbType(thismove.type,user,nil),PBTypes,:WATER)
          @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
          user.effects[PBEffects::SkipTurn]=true
          user.lastMoveUsed=thismove.id
          user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
          if !turneffects[PBEffects::SpecialUsage]
            user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
          #  user.lastRegularMoveUsed=thismove.id
          end
          @battle.lastMoveUsed=thismove.id
          @battle.lastMoveUser=user.index
          return
        end
      end
    end
    # Powder
    if user.effects[PBEffects::Powder] && isConst?(thismove.pbType(thismove.type,user,nil),PBTypes,:FIRE)
      @battle.pbCommonAnimation("Powder",user,nil)
      @battle.pbDisplay(_INTL("When the flame touched the powder on the Pokémon, it exploded!"))
      user.effects[PBEffects::SkipTurn]=true
      user.pbReduceHP(1+(user.totalhp/4).floor) if !user.hasWorkingAbility(:MAGICGUARD)   
      user.lastMoveUsed=thismove.id
      user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
      if !turneffects[PBEffects::SpecialUsage]
        user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=user.index
      user.pbFaint if user.fainted?
      #pbEndTurn(choice)
      return
    end
    if isConst?(@ability,PBAbilities,:PROTEAN) && !@effects[PBEffects::GastroAcid] && !isConst?(thismove.id,PBMoves,:STRUGGLE) # Do not apply Protean if attack is Struggle
      @effects[PBEffects::ForestsCurse]=false
      @effects[PBEffects::TrickOrTreat]=false
      if !thismove.pbIsConfusion? && ((@form-1) != thismove.type || (@pokemon.form-1) != thismove.type)
        if thismove.function==0x090 # Hidden Power
          hp=pbHiddenPower(user.iv)
          if @pokemon.species==PBSpecies::ARCEUS && @pokemon.form==19
            # Only change type if attacker is Primal Arceus
            @type1=hp[0]
            @type2=hp[0]
          elsif [PBSpecies::KECLEON,PBSpecies::ARCEUS,PBSpecies::FROAKIE,PBSpecies::FROGADIER,PBSpecies::GRENINJA,PBSpecies::DELTADITTO].include?(@pokemon.species)
            @pokemon.form=hp[0]
          else
            @type1=hp[0]
            @type2=hp[0]
          end
          typenameprotean=PBTypes.getName(hp[0])
        elsif thismove.function==0x135 # Custom Move
          case $game_variables[98]
          when 0
            cm=0
          when 1
            cm=12
          when 2
            cm=10
          when 3
            cm=11
          when 4
            cm=3
          when 5
            cm=1
          when 6
            cm=17
          when 7
            cm=14
          when 8
            cm=7
          when 9
            cm=15
          when 10
            cm=4
          when 11
            cm=5
          when 12
            cm=2
          when 13
            cm=6
          when 14
            cm=13
          when 15
            c=m=16
          when 16
            cm=8
          when 17
            cm=21
          else
            cm=0
          end
          typenameprotean=PBTypes.getName(cm)
          cm=18 if cm==21 # Renumber for Fairy typing
          if @pokemon.species==PBSpecies::ARCEUS && @pokemon.form==19
            # Only change type if attacker is Primal Arceus
            @type1=cm
            @type2=cm
          elsif [PBSpecies::KECLEON,PBSpecies::ARCEUS,PBSpecies::FROAKIE,PBSpecies::FROGADIER,PBSpecies::GRENINJA,PBSpecies::DELTADITTO].include?(@pokemon.species)
            @pokemon.form=cm
          else
            @type1=cm
            @type2=cm
          end
        else
          typenameprotean=PBTypes.getName(thismove.type)
          if @pokemon.species==PBSpecies::ARCEUS && @pokemon.form==19
            # Only change type if attacker is Primal Arceus
            typemessage=(@type1==thismove.type && @type2==thismove.type)
            @type1=thismove.type
            @type2=thismove.type
          elsif [PBSpecies::KECLEON,PBSpecies::ARCEUS,PBSpecies::FROAKIE,PBSpecies::FROGADIER,PBSpecies::GRENINJA,PBSpecies::DELTADITTO].include?(@pokemon.species)
            typemessage=(@pokemon.form==thismove.type)
            if thismove.type==21
              @pokemon.form=18
            else
              @pokemon.form=thismove.type
            end
          else
            typemessage=(@type1==thismove.type && @type2==thismove.type)
            @type1=thismove.type
            @type2=thismove.type
          end
        end
        @pokemon.form += 1 if [PBSpecies::FROAKIE,PBSpecies::FROGADIER,PBSpecies::GRENINJA].include?(@pokemon.species)
        pbCheckForm if [PBSpecies::KECLEON,PBSpecies::ARCEUS,PBSpecies::FROAKIE,PBSpecies::FROGADIER,PBSpecies::GRENINJA,PBSpecies::DELTADITTO].include?(@pokemon.species)
        @battle.pbDisplay(_INTL("{1} became {2}-type!",pbThis(false),typenameprotean)) if !typemessage
      end
    end
    #  Kernel.pbPushRecent("5")
    target=nil
    if targets.length==0
      user=pbChangeUser(thismove,user)
      if !targetOverride
        targetOverride=thismove.target
      end
      if targetOverride==PBTargets::SingleNonUser ||
         targetOverride==PBTargets::RandomOpposing ||
         targetOverride==PBTargets::AllOpposing ||
         targetOverride==PBTargets::AllNonUsers ||
         targetOverride==PBTargets::Partner ||
         targetOverride==PBTargets::UserOrPartner ||
         targetOverride==PBTargets::SingleOpposing ||
         targetOverride==PBTargets::OppositeOpposing
        @battle.pbDisplay(_INTL("But there was no target..."))
        @battle.scene.pbShowSprites(user.index)
      else
        Kernel.pbPushRecent("6")
        PBDebug.logonerr{
          thismove.pbEffect(user,nil)
        }
        @battle.successStates[user.index].useState=2
        @battle.successStates[user.index].typemod=4
      end
    else
      i=0; loop do break if i>=targets.length
        userandtarget=[user,targets[i]]
        success=false
        success=pbChangeTarget(thismove,userandtarget,targets)
        user=userandtarget[0]
        target=userandtarget[1]
        if i==0 && thismove.target==PBTargets::AllOpposing
          # Add partner to list of targets
          pbAddTarget(targets,target.pbPartner)
        end
        if !success
          i+=1
          next
        end
        # Get the number of hits
        numhits=thismove.pbNumHits(user)
        # Reset damage state, set Focus Band/Focus Sash to available
        target.damagestate.reset
        # Use move against the current target
        pbProcessMoveAgainstTarget(thismove,user,target,numhits,turneffects,false)
        if user.ability==PBAbilities::REGURGITATION && !user.effects[PBEffects::GastroAcid]
          numhits=1
          moveTemp=PBMove.new(PBMoves::REGURGITATION)
          moveTemp2=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:REGURGITATION)))
          pbProcessMoveAgainstTarget(moveTemp2,user,target,numhits,turneffects,false)
        end
=begin
        if isConst?(target.item,PBItems,:FOCUSBAND) && @battle.pbRandom(10)==0 
          target.damagestate.focusband=true
        end
        if isConst?(target.item,PBItems,:FOCUSSASH)
          target.damagestate.focussash=true
        end
        if thismove.function==0xC1 # Beat Up
          pbProcessBeatUp(thismove,user,target)
        elsif thismove.pbIsMultiHit || 
          user.hasWorkingAbility(:LERNEAN) ||
          user.hasWorkingAbility(:PARENTALBOND)
          numhits = 2 if user.hasWorkingAbility(:PARENTALBOND)
          numhits = user.form+4 if user.hasWorkingAbility(:LERNEAN)
          pbProcessMultiHitMove(thismove,user,target,numhits,true)
        else
          #@battle.pbDisplayPaused("1")
          begin
            pbProcessNonMultiHitMove(thismove,user,target)
          ensure
            #       @battle.pbDisplayPaused("0")
            if user.ability==PBAbilities::REGURGITATION && !user.effects[PBEffects::GastroAcid]
              #             @battle.pbDisplayPaused("-1")
              moveTemp=PBMove.new(PBMoves::REGURGITATION)
              moveTemp2=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:REGURGITATION)))
              #           @battle.pbDisplayPaused("-2")
              pbProcessNonMultiHitMove(moveTemp2,user,target)
              #           @battle.pbDisplayPaused("-3")
            end
          end
        end
        pbProcessNonMultiHitMove(thismove,user,target)
=end
        i+=1
      end
      thismove.moveInProgress=false
      # Red Card switching needs to happen after the move completes in order
      # to ensure that the fastest holder is the only one that is swapped out, in
      # the event that multiple Pokemon are targeted that are holding the item
      for j in @battle.pbPriority
        if @battle.battlers[j.index].effects[PBEffects::RedCardTriggered]
          if !@battle.opponent && !@battle.doublebattle
            @battle.pbDisplay(_INTL("{1} held up its Red Card against the {2}!",
              @battle.battlers[j.index].pbThis,
              user.pbThis(true)))
            #@battle.battlers[j.index].pbConsumeItem
            if user.hasWorkingAbility(:SUCTIONCUPS)
              @battle.battlers[j.index].effects[PBEffects::RedCardTriggered]=false
              @battle.pbDisplay(_INTL("{1} anchored itself with {2}!",
                 user.pbThis,PBAbilities.getName(user.ability)))
            elsif user.effects[PBEffects::Ingrain]
              @battle.battlers[j.index].effects[PBEffects::RedCardTriggered]=false   
              @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",
                 user.pbThis))
            else
              @battle.decision=3 # Set decision to escaped
            end
            break
          else
            @battle.pbDisplay(_INTL("{1} held up its Red Card against the {2}!",
              @battle.battlers[j.index].pbThis,
              user.pbThis(true)))
            #@battle.battlers[j.index].pbConsumeItem
            if user.hasWorkingAbility(:SUCTIONCUPS)
              @battle.battlers[j.index].effects[PBEffects::RedCardTriggered]=false
              @battle.pbDisplay(_INTL("{1} anchored itself with {2}!",
                 user.pbThis,PBAbilities.getName(user.ability)))
            elsif user.effects[PBEffects::Ingrain]
              @battle.battlers[j.index].effects[PBEffects::RedCardTriggered]=false
              @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",
                 user.pbThis))
            else
              user.effects[PBEffects::Roar]=true
              if user.effects[PBEffects::Uturn]
                user.effects[PBEffects::Uturn]=false
              end
            end
            break
          end
        end
      end
      # Eject Button switching needs to happen after the move completes in order
      # to ensure that the fastest holder is the only one that is swapped out, in
      # the event that multiple Pokemon are targeted that are holding the item
      for j in @battle.pbPriority
        if @battle.battlers[j.index].effects[PBEffects::EjectTriggered]
          @battle.battlers[j.index].effects[PBEffects::Uturn]=true
          if user.effects[PBEffects::Uturn]
            user.effects[PBEffects::Uturn]=false
          end
          @battle.pbDisplay(_INTL("{1} is switched out with the {2}!",
            @battle.battlers[j.index].pbThis,PBItems.getName(@battle.battlers[j.index].item)))
          @battle.battlers[j.index].pbConsumeItem
          break
        end
      end
      if thismove.id==PBMoves::RELICSONG && 
         (isConst?(user.species,PBSpecies,:MELOETTA) || 
         isConst?(user.species,PBSpecies,:DELTAMELOETTA)) && 
         user.pokemon.form==0 && !user.effects[PBEffects::Transform]
        user.pokemon.form=1
        pbCheckForm
      elsif thismove.id==PBMoves::RELICSONG && 
            (isConst?(user.species,PBSpecies,:MELOETTA) || 
            isConst?(user.species,PBSpecies,:DELTAMELOETTA)) && 
            !user.effects[PBEffects::Transform]
        user.pokemon.form=0
        pbCheckForm  
      end
      if turneffects[PBEffects::TotalDamage]>0 && thismove.function!=0x214 # Fairy Tempest
        if user.effects[PBEffects::SynergyBurst]>0 && user.effects[PBEffects::SynergyBurst]<5
          user.effects[PBEffects::SynergyBurst]+=1
        end
        if target.effects[PBEffects::SynergyBurst]>0
          target.effects[PBEffects::SynergyBurst]-=1
        end
      end
    end
    if isConst?(user.item,PBItems,:LIFEORB) && !(user.hasWorkingAbility(:SHEERFORCE) && thismove.addlEffect>0) && 
       !user.hasWorkingAbility(:MAGICGUARD) && user.effects[PBEffects::TwoTurnAttack]==0
      afterRedCard=false
      for j in @battle.pbPriority
        if @battle.battlers[j.index].effects[PBEffects::RedCardTriggered]
          afterRedCard=true
          break
        end
      end
       #thismove.function!=0xEE
      #numPokemon=@battle.battlers.length-1
      #if turneffects[PBEffects::TotalDamage]>0
      #end
      if !afterRedCard
        if thismove.numPokemonHit>0 && @moveHit && !user.fainted? && (turneffects[PBEffects::TotalDamage]>0 || user.effects[PBEffects::HitSubstitute])
          user.pbReduceHP((user.totalhp/10).floor) #&& !isConst?(attacker.ability,PBAbilities,:SHEERFORCE) && !isConst?(@ability,PBAbilities,:MAGICGUARD)
          @battle.pbDisplay(_INTL("{1} is damaged by its Life Orb!",user.pbThis)) #&& !isConst?(attacker.ability,PBAbilities,:SHEERFORCE) && !isConst?(@ability,PBAbilities,:MAGICGUARD)
          if user.hp<=0
            user.pbFaint
            #@battle.pbGainEXP
            #@battle.pbJudge     #pbSwitch
            return
          end
        end
        #else
        #  user.pbReduceHP((user.totalhp/10).floor) #&& !isConst?(attacker.ability,PBAbilities,:SHEERFORCE) && !isConst?(@ability,PBAbilities,:MAGICGUARD)
        #  @battle.pbDisplay(_INTL("{1} is damaged by its Life Orb!",user.pbThis)) #&& !isConst?(attacker.ability,PBAbilities,:SHEERFORCE) && !isConst?(@ability,PBAbilities,:MAGICGUARD)
      end
    end
    user.effects[PBEffects::HitSubstitute]=false
    for i in 0..3
      @battle.battlers[i].effects[PBEffects::RedCardTriggered]=false
      @battle.battlers[i].effects[PBEffects::EjectTriggered]=false
      @battle.battlers[i].effects[PBEffects::SymbiosisTriggered]=false
    end
    # The below may have been needed for something involving Red Card/Eject Card/
    # Symbiosis. It is removed due to it removing experience gained if the opponent
    # faints themselves in battle.
    #if user.hp<=0
    #  return if !i.pbFaint
    #  next
    #end
    # Pokémon switching caused by Roar, Whirlwind, Circle Throw, Dragon Tail, Red Card
    if !user.fainted?
      switched=[]
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Roar]
          next if @battle.battlers[i].fainted?
          next if !@battle.pbCanSwitch?(i,-1,false)
          choices=[]
          party=@battle.party1 if @battle.pbOwnedByPlayer?(i)
          party=@battle.party2 if !@battle.pbOwnedByPlayer?(i)
          #party=@battle.pbParty(i)
          for j in 0...party.length
            choices.push(j) if @battle.pbCanSwitchLax?(i,j,false)
          end
          if choices.length>0
            newpoke=choices[@battle.pbRandom(choices.length)]
            newpokename=newpoke
            if isConst?(party[newpoke].ability,PBAbilities,:ILLUSION)
              if party[@battle.pbGetLastPokeInTeam(i)]==party[newpoke]
                newpokename=@battle.battlers[i].pokemonIndex
              else
              #if newpoke==@battle.pbGetLastPokeInTeam(i)
              #  newpokename=@battle.pbGetLastExcludeTarget(i,@battle.party1[newpoke]) if @battle.pbOwnedByPlayer?(i)
              #  newpokename=@battle.pbGetLastExcludeTarget(i,@battle.party2[newpoke]) if !@battle.pbOwnedByPlayer?(i)
              #  #newpokename=@battle.pbGetLastExcludeTarget(i,party[newpoke])#@battlers[index].pokemonIndex
              #else
                newpokename=@battle.pbGetLastPokeInTeam(i)
              #end
              #newpokename=@battle.pbGetLastPokeInTeam(i)
              end
            end
            switched.push(i)
            @battle.battlers[i].pbResetForm
            @battle.pbRecallAndReplace(i,newpoke,false,newpokename,true)
            #@battle.pbDisplay(_INTL("{1} was dragged out!",@battle.battlers[i].pbThis))
            @battle.choices[i]=[0,0,nil,-1]   # Replacement Pokémon does nothing this round
            @battle.battlers[i].effects[PBEffects::Roar]=false
            @battle.battlers[i].effects[PBEffects::Uturn]=false
          end
        end
      end
      for i in @battle.pbPriority
        next if !switched.include?(i.index)
        i.pbAbilitiesOnSwitchIn(true)
      end
    end
    # Pokémon switching caused by U-Turn, Volt Switch, Eject Button
    switched=[]
    for i in 0...4
      if @battle.battlers[i].effects[PBEffects::Uturn]
        @battle.battlers[i].effects[PBEffects::Uturn]=false
        @battle.battlers[i].effects[PBEffects::Roar]=false
        
        if !@battle.battlers[i].fainted? && @battle.pbCanChooseNonActive?(i) &&
           !@battle.pbAllFainted?(@battle.pbOpposingParty(i))
          # TODO: Pursuit should go here, and negate this effect if it KO's attacker
          @battle.pbDisplay(_INTL("{1} went back to {2}!",@battle.battlers[i].pbThis,@battle.pbGetOwner(i).name))
          newpoke=0
          newpoke=@battle.pbSwitchInBetween(i,true,false)
          if $hasSentData
            $network.send("<BAT\tnew=#{newpoke}>")
          end
          newpokename=newpoke
          if isConst?(@battle.pbParty(i)[newpoke].ability,PBAbilities,:ILLUSION)
            if @battle.pbParty(i)[@battle.pbGetLastPokeInTeam(i)]==@battle.pbParty(i)[newpoke]
              newpokename=@battle.battlers[i].pokemonIndex
            else
              newpokename=@battle.pbGetLastPokeInTeam(i)
            end
          end
          switched.push(i)
          @battle.battlers[i].pbResetForm
          @battle.lastMoveUturn=true
          @battle.pbRecallAndReplace(i,newpoke,false,newpokename)
          @battle.choices[i]=[0,0,nil,-1]   # Replacement Pokémon does nothing this round
          if $hasSentData
            @battle.waitnewenemy
            $hasSentData=nil
          end
        end
      end
    end
    for i in @battle.pbPriority
      next if !switched.include?(i.index)
      i.pbAbilitiesOnSwitchIn(true)
    end
    # Baton Pass
    if user.effects[PBEffects::BatonPass]
      user.effects[PBEffects::BatonPass]=false
      if !user.fainted? && @battle.pbCanChooseNonActive?(user.index) &&
         !@battle.pbAllFainted?(@battle.pbParty(user.index))
        newpoke=0
        @battle.lastMoveUturn=true
        newpoke=@battle.pbSwitchInBetween(user.index,true,false)
        if $hasSentData
          $network.send("<BAT\tnew=#{newpoke}>")
        end
        newpokename=newpoke
        
        if isConst?(@battle.pbParty(user.index)[newpoke].ability,PBAbilities,:ILLUSION)
          if @battle.pbParty(user.index)[@battle.pbGetLastPokeInTeam(user.index)]==@battle.pbParty(user.index)[newpoke]
            newpokename=@battle.battlers[user.index].pokemonIndex
          else
            newpokename=@battle.pbGetLastPokeInTeam(user.index)
          end
        end
        
        #if isConst?(@battle.pbParty(user.index)[newpoke].ability,PBAbilities,:ILLUSION)
        #  newpokename=@battle.pbGetLastPokeInTeam(user.index)
        #end
        #@battle.pbMessagesOnReplace(user.index,newpoke)
        user.pbResetForm if !Kernel.pbGetMegaStoneList.include?(user.item)
        #@battle.pbReplace(user.index,newpoke,true)
        @battle.pbRecallAndReplace(user.index,newpoke,true,newpokename)
        #@battle.pbOnActiveOne(user)
        @battle.choices[user.index]=[0,0,nil,-1]   # Replacement Pokémon does nothing this round
        user.pbAbilitiesOnSwitchIn(true)
        if $hasSentData
          waitnewenemy
          $hasSentData=nil
        end
        @battle.scene.pbChangePokemon(user,user.pokemon,true) if user.effects[PBEffects::Substitute]!=0
      end
    end
    # TODO: lastMoveUsed is not to be updated on nested calls
    if thismove.function==0x5C || # Mimic
       thismove.function==0x5D || # Sketch
       thismove.function==0x69    # Transform
      user.lastMoveUsedSketch=-1
      user.lastMoveUsed=-1
    else
      if @effects[PBEffects::TwoTurnAttack]==0
        user.lastMoveUsedSketch=thismove.id
      end
      user.lastMoveUsed=thismove.id
      user.lastMoveUsedType=thismove.pbType(thismove.type,user,nil)
    end
    if !turneffects[PBEffects::SpecialUsage]
      user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
      user.movesUsed.push(thismove.id) if !user.movesUsed.include?(thismove.id) # For Last Resort
    end
    user.lastMoveCalled=thismove.id
    #user.movesUsed.push(thismove.id) if !user.movesUsed.include?(thismove.id) # For Last Resort
    @battle.lastMoveUsed=thismove.id
    @battle.lastMoveUser=user.index
    if selffaint
      user.hp=0
      user.pbFaint # no return
    end
    @battle.pbGainEXP
    return #true
  end

  def pbCancelMoves
    # Cancel two-turn attack
    # Note: Hyper Beam effect is not canceled here
    @effects[PBEffects::TwoTurnAttack]=0 if @effects[PBEffects::TwoTurnAttack]>0
    # Cancel current move (for Thrash, etc.)
    @currentMove=0
    @effects[PBEffects::Bide]=0
    @effects[PBEffects::Outrage]=0
    @effects[PBEffects::Uproar]=0
    @effects[PBEffects::Rollout]=0
    @effects[PBEffects::FuryCutter]=0
  end



################################################################################
# Turn processing
################################################################################
  def pbBeginTurn(choice)
    @effects[PBEffects::DestinyBond]=false
    @effects[PBEffects::Grudge]=false
    # Reset Lernean and Parental Bond's count
    @effects[PBEffects::LerneanCounter]=0
    @effects[PBEffects::ParentalBond]=0
    if @effects[PBEffects::Encore]>0 &&
       @moves[@effects[PBEffects::EncoreIndex]].id!=@effects[PBEffects::EncoreMove]
      PBDebug.log("[Resetting Encore effect]")
      @effects[PBEffects::Encore]=0
      @effects[PBEffects::EncoreIndex]=0
      @effects[PBEffects::EncoreMove]=0
    end
    if !self.hasWorkingAbility(:SOUNDPROOF) && self.status==PBStatuses::SLEEP
      for i in 0..3
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          self.effects[PBEffects::Nightmare]=false
          @battle.pbDisplay(_INTL("{1} woke up in the uproar!",pbThis))
          self.status=0
        end
      end
    end
  end

  def pbEndTurn(choice)
    @effects[PBEffects::Conversion2Move]=0
    @effects[PBEffects::Conversion2Type]=0
    if @effects[PBEffects::ChoiceBand]<0 && @lastMoveUsed>=0 && @hp>0 && 
       (isConst?(@item,PBItems,:CHOICEBAND) ||
       isConst?(@item,PBItems,:CHOICESPECS) ||
       isConst?(@item,PBItems,:CHOICESCARF))
      @effects[PBEffects::ChoiceBand]=@lastMoveUsed
    end
    if @battle.lastMoveUturn
      @lastMoveUsed=-1
      @effects[PBEffects::ChoiceBand]=@lastMoveUsed
      @battle.lastMoveUturn=false
    end
    @battle.pbPrimordialWeather
    
    $game_switches[359]=false
    @battle.synchronize[0]=-1
    @battle.synchronize[1]=-1
    @battle.synchronize[2]=0
    for i in 0..3
      @battle.battlers[i].pbAbilityCureCheck
    end
    for i in 0..3
      @battle.battlers[i].pbBerryCureCheck(true)
    end
    for i in 0..3
      @battle.battlers[i].pbAbilitiesOnSwitchIn(false)
    end
    for i in 0..3
      @battle.battlers[i].pbCheckForm if @battle.battlers[i].species==PBSpecies::CASTFORM ||
                                         @battle.battlers[i].species==PBSpecies::CHERRIM ||
                                         @battle.battlers[i].species==PBSpecies::DELTATYPHLOSION
    end
  end

  def pbProcessTurn(choice)

    if !@battle.opponent &&
       @battle.rules["alwaysflee"] && self.hp>0 &&
       @battle.pbIsOpposing?(self.index) && @battle.pbCanRun?(self.index)
      pbBeginTurn(choice)
      @battle.pbDisplay(_INTL("{1} fled!",self.pbThis))
      @battle.decision=3
      pbEndTurn(choice)
      return true
    end
    
    if choice[0]!=1
      # Clean up effects that end at battler's turn
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return false
    end
    # turn is skipped if Pursuit was used during switch
    if @effects[PBEffects::Pursuit]
      @effects[PBEffects::Pursuit]=false
      pbCancelMoves
      pbEndTurn(choice)
      @battle.pbJudge
      return false
    end
    
    #ret=pbTryUseMove(choice)
    #if !ret
    #  self.lastMoveUsed=-1
    #  self.lastMoveCalled=-1
    #  pbCancelMoves
    #  @battle.pbGainEXP
    #  pbEndTurn(choice)
    #  @battle.pbSwitch
    #  return false
    #end
    #thismove=choice[2]
    #if !pbReducePP(thismove)
    #  @battle.pbDisplay(_INTL("{1} used\r\n{2}!",pbThis,thismove.name))
    #  @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
    #  self.lastMoveUsedSketch=thismove.id
    #  self.lastMoveUsed=-1
    #  self.lastMoveCalled=-1
    #  pbEndTurn(choice)
    #  @battle.pbSwitch
    #  return false
    #end

    #ret=0
    
#   @battle.pbDisplayPaused("Before: [#{@lastMoveUsedSketch},#{@lastMoveUsed},#{@lastMoveCalled}]")
   PBDebug.logonerr{
       pbUseMove(choice,choice[2]==@battle.struggle)
    }
      #pbReduceHP((@totalhp/10).floor) if $templifeorb && (!isConst?(@ability,PBAbilities,:SHEERFORCE) && !isConst?(@ability,PBAbilities,:MAGICGUARD)) && !@effects[PBEffects::GastroAcid]
      #@battle.pbDisplay(_INTL("{1} is damaged by its Life Orb!",pbThis)) if $templifeorb && (!isConst?(@ability,PBAbilities,:SHEERFORCE) && !isConst?(@ability,PBAbilities,:MAGICGUARD)) && !@effects[PBEffects::GastroAcid]
      $templifeorb=nil
      for i in 0..1
     #    @battle.pbDisplayPaused("HP: "+@battle.battlers[i].hp.to_s)

        @battle.battlers[i].pbFaint if @battle.battlers[i].hp < 1
      end
      
      
#   @battle.pbDisplayPaused("After: [#{@lastMoveUsedSketch},#{@lastMoveUsed},#{@lastMoveCalled}]")
    for i in 0..3
      @battle.successStates[i].updateSkill
    end
    #@battle.pbSwitch
    pbEndTurn(choice)
    return true
  end
end