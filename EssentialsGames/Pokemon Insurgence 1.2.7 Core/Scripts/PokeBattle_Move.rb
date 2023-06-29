class PBTargets
  SingleNonUser    = 0x00
  NoTarget         = 0x01
  RandomOpposing   = 0x02
  AllOpposing      = 0x04
  AllNonUsers      = 0x08
  User             = 0x10
  UserSide         = 0x20
  BothSides        = 0x40
  OpposingSide     = 0x80
  Partner          = 0x100
  UserOrPartner    = 0x200
  SingleOpposing   = 0x400
  OppositeOpposing = 0x800
end



class PokeBattle_Move
  attr_accessor(:id)
  attr_reader(:battle)
  attr_reader(:name)
  attr_reader(:function)
  attr_reader(:basedamage)
  attr_reader(:type)
  attr_reader(:accuracy)
  attr_reader(:addlEffect)
  attr_reader(:target)
  attr_reader(:priority)
  attr_reader(:flags)
  attr_reader(:thismove)
  attr_accessor(:pp)
  attr_accessor(:totalpp)
  attr_accessor(:numPokemonHit)
  attr_accessor(:moveInProgress)

  NOTYPE          = 0x01
  IGNOREPKMNTYPES = 0x02
  NOWEIGHTING     = 0x04
  NOCRITICAL      = 0x08
  NOREFLECT       = 0x10

################################################################################
# Creating a move
################################################################################
  def initialize(battle,move)
    @id = move.id
    @battle = battle
    @name = PBMoves.getName(id)   # Get the move's name
    # Get data on the move
    movedata       = PBMoveData.new(id)
    @function      = movedata.function
    @basedamage    = movedata.basedamage
    @type          = movedata.type
    @accuracy      = movedata.accuracy
    @addlEffect    = movedata.addlEffect
    @target        = movedata.target
    @priority      = movedata.priority
    @flags         = movedata.flags
    @category      = movedata.category
    @thismove      = move
    @pp            = move.pp   # Can be changed with Mimic/Transform
    @numPokemonHit = 0
    @moveInProgress= false
  end

# This is the code actually used to generate a PokeBattle_Move object.  The
# object generated is a subclass of this one which depends on the move's
# function code (found in the script section PokeBattle_MoveEffect).
  def PokeBattle_Move.pbFromPBMove(battle,move)
    move=PBMove.new(0) if !move
    movedata=PBMoveData.new(move.id)
    className=sprintf("PokeBattle_Move_%03X",movedata.function)
    if Object.const_defined?(className)
      return Kernel.const_get(className).new(battle,move)
    else
      return PokeBattle_UnimplementedMove.new(battle,move)
    end
  end



################################################################################
# About the move
################################################################################
  def totalpp
    return @totalpp if @totalpp && @totalpp>0
    return @thismove.totalpp if @thismove
  end
  
  def addlEffect
    return @addlEffect
  end
  
  def priority
    return @priority
  end
  def to_int
    return @id
  end
  
  def pbModifyType(type,attacker,opponent)
    if type>=0
      if attacker.hasWorkingAbility(:NORMALIZE) && hasConst?(PBTypes,:NORMAL)
        type=getConst(PBTypes,:NORMAL)
      elsif isConst?(type,PBTypes,:NORMAL)
        if attacker.hasWorkingAbility(:AERILATE) && hasConst?(PBTypes,:FLYING)
          type=getConst(PBTypes,:FLYING)
          #@powerboost=true
        elsif attacker.hasWorkingAbility(:REFRIGERATE) && hasConst?(PBTypes,:ICE)
          type=getConst(PBTypes,:ICE)
          #@powerboost=true
        elsif attacker.hasWorkingAbility(:PIXILATE) && hasConst?(PBTypes,:FAIRY)
          type=getConst(PBTypes,:FAIRY)
          #@powerboost=true
        end
      end
    end
    return type
  end

  def pbType(type,attacker,opponent)
    if type>=0 && attacker.hasWorkingAbility(:NORMALIZE)
      type=getConst(PBTypes,:NORMAL) || 0
      if type==getConst(PBTypes,:NORMAL)
        attacker.effects[PBEffects::MoveTypeChanged]=true
      end
    end
    if @battle.field.effects[PBEffects::IonDeluge] && isConst?(type,PBTypes,:NORMAL)
      type=getConst(PBTypes,:ELECTRIC)
      attacker.effects[PBEffects::MoveTypeChanged]=true
    end
    if attacker.effects[PBEffects::Electrify]
      type=getConst(PBTypes,:ELECTRIC)
      attacker.effects[PBEffects::MoveTypeChanged]=true
    end
    return type
  end

  def pbIsPhysical?(type)
    if USEMOVECATEGORY
      return @category==0
    else
      return !PBTypes.isSpecialType?(type)
    end
  end
  
  def pbIsConfusion?
    return false
  end
  
  def pbIsSpecial?(type)
    if USEMOVECATEGORY
      return @category==1
    else
      return PBTypes.isSpecialType?(type)
    end
  end
  
  def pbIsStatus?
    return @category==2
  end

  def pbTargetsAll?(attacker)
    if @target==PBTargets::AllOpposing # All opposing Pokémon
      # TODO: should apply even if partner faints during an attack
      return attacker.pbOpposing1.hp>0 && attacker.pbOpposing2.hp>0
    end
    return false
  end
  
  def pbTargetsMultiple?(attacker)
    numtargets=0
    if @target==PBTargets::AllOpposing
      # TODO: should apply even if partner faints during an attack
      numtargets+=1 if !attacker.pbOpposing1.fainted?
      numtargets+=1 if !attacker.pbOpposing2.fainted?
      @moveInProgress=true if numtargets>1
      return numtargets>1
    elsif @target==PBTargets::AllNonUsers
      # TODO: should apply even if partner faints during an attack
      numtargets+=1 if !attacker.pbOpposing1.fainted?
      numtargets+=1 if !attacker.pbOpposing2.fainted?
      numtargets+=1 if !attacker.pbPartner.fainted?
      @moveInProgress=true if numtargets>1
      return numtargets>1
    end
    return false
  end

  def pbNumHits(attacker)
    # Parental Bond goes here (for single target moves only)
    if attacker.hasWorkingAbility(:PARENTALBOND)
      if !pbIsStatus? && !pbTargetsMultiple?(attacker) &&
         !pbIsMultiHit && !pbTwoTurnAttack(attacker)
        exceptions=[0x6E,   # Endeavor
                    0xE0,   # Selfdestruct/Explosion
                    0xE1,   # Final Gambit
                    0xF7]   # Fling
        if !exceptions.include?(@function)
          attacker.effects[PBEffects::ParentalBond]=3
          return 2
        end
      end
    end
    # Lernean goes here (for non-MultiHit, non-set damage damaging moves only)
    if attacker.hasWorkingAbility(:LERNEAN)
      if !pbIsStatus? &&
         !pbIsMultiHit #&& !pbTwoTurnAttack(attacker)
        exceptions=[0x6A,   # Sonic Boom
                    0x6B,   # Dragon Rage
                    0x6C,   # Super Fang
                    0x6D,   # Seismic Toss/Night Shade
                    0x6E,   # Endeavor
                    0x6F,   # Psywave                    
                    0xE0,   # Selfdestruct/Explosion
                    0xE1,   # Final Gambit
                    0xF7,   # Fling
                    0x96]   # Natural Gift
        if !exceptions.include?(@function)
          minheads=5
          maxheads=9
          attacker.effects[PBEffects::LerneanHeads]=(maxheads-minheads)+attacker.form
          headnum=attacker.effects[PBEffects::LerneanHeads]
          attacker.effects[PBEffects::LerneanCounter]=headnum+1
          return headnum
        end
      end
    end
    return 1
  end

  def basedamage=(value)
      @basedamage=value
  end
  
  
  def pbIsMultiHit   # not the same as pbNumHits>1
    return false
  end
  
  

  def pbTwoTurnAttack(attacker)
    return false
  end

  def pbAdditionalEffect(attacker,opponent)
  end

  def pbAdditionalEffect2(attacker,opponent)
  end
  
  def isHealingMove?
    return false
  end
  
  def unusableInGravity?
    return false
  end
  
  def isContactMove?
    return (@flags&0x01)!=0 # flag a: Makes contact
  end
  
  def canProtectAgainst?
    return (@flags&0x02)!=0 # flag b: Protect/Detect
  end

  def canMagicCoat?
    return (@flags&0x04)!=0 # flag c: Magic Coat
  end
  
  def canSnatch?
    return (@flags&0x08)!=0 # flag d: Snatch
  end

  def canMirrorMove? # This method isn't used
    return (@flags&0x10)!=0 # flag e: Copyable by Mirror Move
  end

  def canKingsRock?
    return (@flags&0x20)!=0 # flag f: King's Rock
  end

  def canThawUser?
    return (@flags&0x40)!=0 # flag g: Thaws user before moving
  end

  def hasHighCriticalRate?
    return (@flags&0x80)!=0 # flag h: Has high critical hit rate
  end
  
  def isBitingMove?
    return (@flags&0x100)!=0 # flag i: Is biting move
  end
  
  def isPunchingMove?
    return (@flags&0x200)!=0 # flag j: Is punching move
  end
  
  def isSoundBased?
    return (@flags&0x400)!=0 # flag k: Is sound-based move
  end
  
  def isPowderMove?
    return (@flags&0x800)!=0 # flag l: Is powder move
  end

  def isPulseMove?
    return (@flags&0x1000)!=0 # flag m: Is pulse move
  end

  def isBombMove?
    return (@flags&0x2000)!=0 # flag n: Is bomb move
  end
  
  def isBurstAttack?
    movelist=[0x214,   # Fairy Tempest
              0x215,   # Dynamic Fury
              0x216,   # Aura Blast
              0x217]   # Dark Nova
    if movelist.include?(@function)
      return true
    end
  end
  
  def tramplesMinimize?(param=1) # Causes perfect accuracy and double damage
    return isConst?(@id,PBMoves,:BODYSLAM) ||
           isConst?(@id,PBMoves,:STOMP) ||
           isConst?(@id,PBMoves,:STEAMROLLER) ||
           isConst?(@id,PBMoves,:DRAGONRUSH) ||
           isConst?(@id,PBMoves,:HEATCRASH) ||
           isConst?(@id,PBMoves,:HEAVYSLAM) ||
           isConst?(@id,PBMoves,:FLYINGPRESS) ||
           isConst?(@id,PBMoves,:PHANTOMFORCE) ||
           isConst?(@id,PBMoves,:SHADOWFORCE)
  end
  
  def ignoresSubstitute?(attacker)
    return true if isSoundBased?
    return true if attacker && attacker.hasWorkingAbility(:INFILTRATOR)
    return false
  end
  

################################################################################
# This move's type effectiveness
################################################################################
  def pbTypeModifier(type,attacker,opponent)
    i = pbTypeModifierTrue(type,attacker,opponent)
    has_changed = false
    if isConst?(type,PBTypes,:SHADOW)
      if opponent.pokemon.isShadowForMove?
        i = 2
      else
        i = 8
      end
    end
    if $game_switches[302]
      if i==32
        i=0
        has_changed=true
      end
      if i==8
        i=2
        has_changed=true
      end
      if i==2 && !has_changed
        i=8
        has_changed=true
      end
      if i==1 && !has_changed
        i=16
        has_changed=true
      end
      if i==16 && !has_changed
        i=1
        has_changed=true
      end
      if i==0 && !has_changed
        i=8
        has_changed=true
      end
    end
    return i
  end

  def pbTypeModifierTrue(type,attacker,opponent)
    return 4 if type<0
    return 4 if isConst?(type,PBTypes,:GROUND) && opponent.pbHasType?(:FLYING) &&
                isConst?(opponent.item,PBItems,:IRONBALL)
    atype=type # attack type
    otype1=opponent.type1
    otype2=opponent.type2
    otype3=opponent.effects[PBEffects::Type3] || -1
    # Roost
    if isConst?(otype1,PBTypes,:FLYING) && opponent.effects[PBEffects::Roost]
      if isConst?(otype2,PBTypes,:FLYING) && isConst?(otype3,PBTypes,:FLYING)
        otype1=getConst(PBTypes,:NORMAL) || 0
      else
        otype1=otype2
      end
    end
    if isConst?(otype2,PBTypes,:FLYING) && opponent.effects[PBEffects::Roost]
      otype2=otype1
    end
    mod1=PBTypes.getEffectiveness(atype,otype1)
  ##  @battle.pbDisplayPaused(PBSpecies.getName(opponent.species))
  #  @battle.pbDisplayPaused(opponent.ability)
  #  @battle.pbDisplayPaused(PBAbilities.getName(opponent.ability))

    if(opponent.ability==PBAbilities::OMNITYPE && !opponent.effects[PBEffects::GastroAcid] && 
      !attacker.hasMoldBreaker && !attacker.hasWorkingAbility(:ANCIENTPRESENCE))
      if isConst?(@id,PBMoves,:THOUSANDARROWS) && !opponent.effects[PBEffects::SmackDown]
        return 4
      elsif isConst?(@id,PBMoves,:THOUSANDARROWS)
        return 32
      end
      if (opponent.hasWorkingItem(:RINGTARGET) || 
         attacker.hasWorkingAbility(:IRRELEPHANT)) && !$game_switches[302]
        case atype
        when PBTypes::GROUND
          return 32
        when PBTypes::GHOST
          return 8
        when PBTypes::FIGHTING,PBTypes::PSYCHIC,PBTypes::DRAGON
          return 4
        when PBTypes::ELECTRIC
          return 2
        when PBTypes::NORMAL,PBTypes::POISON
          return 1
        else
          # return nothing...yet
        end
      end
      case atype
      when PBTypes::FLYING,PBTypes::FIRE,PBTypes::WATER,PBTypes::ICE,PBTypes::FAIRY
        return 4
      when PBTypes::ROCK
        return 8
      when PBTypes::NORMAL,PBTypes::FIGHTING,PBTypes::POISON,PBTypes::GROUND,PBTypes::GHOST,PBTypes::ELECTRIC,PBTypes::PSYCHIC,PBTypes::DRAGON
        if atype==PBTypes::GROUND && @battle.field.effects[PBEffects::Gravity]>0
          return 32
        elsif atype==PBTypes::NORMAL && (attacker.hasWorkingAbility(:SCRAPPY) ||
           opponent.effects[PBEffects::Foresight])
          return 1
        elsif (atype==PBTypes::FIGHTING && (attacker.hasWorkingAbility(:SCRAPPY) ||
           opponent.effects[PBEffects::Foresight])) ||
           (atype==PBTypes::PSYCHIC && opponent.effects[PBEffects::MiracleEye])
          return 4
        else
          return 0
        end
      when PBTypes::DARK,PBTypes::STEEL
        return 2
      when PBTypes::BUG,PBTypes::GRASS
        return 1
      else
        return 4
      end
    end 
    if(attacker.ability==PBAbilities::ANCIENTPRESENCE) && !attacker.effects[PBEffects::GastroAcid]
      return 4
    end
    if isConst?(@id,PBMoves,:ACHILLESHEEL)
      tempMod2=PBTypes.getEffectiveness(atype,otype2)
      tempMod1=0 if mod1==0
      tempMod2=0 if tempMod2==0
      if (tempMod1==0 || tempMod2==0)
        if attacker.effects[PBEffects::MoveTypeChanged] && (attacker.hasWorkingAbility(:PIXILATE) || attacker.hasWorkingAbility(:NORMALIZE) ||
           attacker.hasWorkingAbility(:REFRIGERATE) || attacker.hasWorkingAbility(:AERILATE) || 
           attacker.hasWorkingAbility(:INTOXICATE) || attacker.hasWorkingAbility(:FOUNDRY))
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
          opponent.effects[PBEffects::TypeIdentified]=true
          attacker.effects[PBEffects::MoveTypeChanged]=false
        end
        return 0
      else
        return 8
      end
    end
    # || ((attacker.hasMoldBreaker || opponent.effects[PBEffects::GastroAcid]) && opponent.ability==PBAbilities::OMNITYPE)
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    if isConst?(opponent.item,PBItems,:RINGTARGET) && !$game_switches[302]
      mod1=2 if mod1==0
      mod2=2 if mod2==0
    end
    if attacker.hasWorkingAbility(:IRRELEPHANT) && !$game_switches[302]
      mod1=2 if mod1==0
      mod2=2 if mod2==0      
    end
    
    if attacker.hasWorkingAbility(:SCRAPPY) || opponent.effects[PBEffects::Foresight]
      mod1=2 if (isConst?(otype1,PBTypes,:GHOST) || opponent.effects[PBEffects::TrickOrTreat]) &&
        (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) &&
        (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
    end
    if (!opponent.isAirborne?(attacker.hasMoldBreaker) || @function==0x11C) && # Smack Down
       isConst?(atype,PBTypes,:GROUND)
    #  opponent.effects[PBEffects::Ingrain] ||
    #   opponent.effects[PBEffects::SmackDown] ||
    #   isConst?(@id,PBMoves,:THOUSANDARROWS) ||
    #   attacker.pbOwnSide.effects[PBEffects::Gravity]>0 ||
    #   attacker.pbOpposingSide.effects[PBEffects::Gravity]>0
      mod1=2 if isConst?(otype1,PBTypes,:FLYING)
      mod2=2 if isConst?(otype2,PBTypes,:FLYING)
    #  mod1=2 if opponent.hasWorkingAbility(:OMNITYPE) && isConst?(atype,PBTypes,:GROUND)
    #  mod2=2 if opponent.hasWorkingAbility(:OMNITYPE) && isConst?(atype,PBTypes,:GROUND)
    end
    if opponent.effects[PBEffects::MiracleEye]
      mod1=2 if isConst?(otype1,PBTypes,:DARK) && isConst?(atype,PBTypes,:PSYCHIC)
      mod2=2 if isConst?(otype2,PBTypes,:DARK) && isConst?(atype,PBTypes,:PSYCHIC)
    end
 #   if opponent.type
#&&
#      !isConst?(id,PBMoves,:CORRODE)
    if isConst?(@id,PBMoves,:CORRODE)
      mod1=4 if isConst?(otype1,PBTypes,:STEEL)
      mod2=4 if isConst?(otype2,PBTypes,:STEEL)
    end
    if isConst?(@id,PBMoves,:THOUSANDARROWS) && !opponent.effects[PBEffects::SmackDown]
      #&& opponent.isAirborne?(attacker.hasMoldBreaker)
      return 4 if isConst?(otype1,PBTypes,:FLYING)
      return 4 if isConst?(otype2,PBTypes,:FLYING)
    end
      
    retmod=mod1*mod2
   # if retmod==0 &&
   #   retmod==4
   # end
    
    return retmod

  end
  
  def pbTypeModMessages(type,attacker,opponent,isInSpecific=false)
    return 4 if type<0
    #if @battle.primordialsea && isConst?(type,PBTypes,:FIRE)
    #     @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
    #  
    #    return 0
    #end
    #if @battle.desolateland && isConst?(type,PBTypes,:WATER)
    #     @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
    # 
    #   return 0
    #end
    #if (opponent.hasWorkingAbility(:RATTLED) && !attacker.hasMoldBreaker)
    #  (isConst?(type,PBTypes,:DARK) || isConst?(type,PBTypes,:BUG) ||
    #   isConst?(type,PBTypes,:GHOST))
    #  if !opponent.pbTooHigh?(PBStats::SPEED)
    #    @battle.pbAnimation(@id,opponent,nil)
    #    opponent.pbIncreaseStatBasic(PBStats::SPEED,1)
    #    @battle.pbCommonAnimation("StatUp",opponent,nil)
    #    @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
    #  end
    #end
    #if (opponent.hasWorkingAbility(:JUSTIFIED) && !attacker.hasMoldBreaker) && isConst?(type,PBTypes,:DARK)
    #  if !opponent.pbTooHigh?(PBStats::ATTACK)
    #    @battle.pbAnimation(@id,opponent,nil)
    #    opponent.pbIncreaseStatBasic(PBStats::ATTACK,1)
    #    @battle.pbCommonAnimation("StatUp",opponent,nil)
    #    @battle.pbDisplay(_INTL("{1}'s {2} raised its attack!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
    #  end
    #end
    if (opponent.hasWorkingAbility(:FLASHFIRE) && !attacker.hasMoldBreaker) && isConst?(type,PBTypes,:FIRE)
      if !opponent.effects[PBEffects::FlashFire]
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Fire power!",opponent.pbThis,
           PBAbilities.getName(opponent.ability)))
        opponent.effects[PBEffects::FlashFire]=true
        opponent.effects[PBEffects::TypeIdentified]=true
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,
           PBAbilities.getName(opponent.ability),self.name))
        opponent.effects[PBEffects::TypeIdentified]=true
      end
      return 0
    end
    if opponent.hasWorkingAbility(:TELEPATHY) && !pbIsStatus? &&
       !opponent.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("{1} avoids attacks from its ally Pokémon!",opponent.pbThis))
      return 0
    end
    if ((opponent.hasWorkingAbility(:STORMDRAIN) && 
       !attacker.hasMoldBreaker) && isConst?(type,PBTypes,:WATER)) ||
       ((opponent.hasWorkingAbility(:LIGHTNINGROD) && 
       !attacker.hasMoldBreaker) && isConst?(type,PBTypes,:ELECTRIC))
      if opponent.pbTooHigh?(PBStats::SPATK)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,
           PBAbilities.getName(opponent.ability),self.name))
        opponent.effects[PBEffects::TypeIdentified]=true
      else
        @battle.pbAnimation(@id,opponent,nil)
        opponent.pbIncreaseStatBasic(PBStats::SPATK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil) if !opponent.isInvulnerable?
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!",opponent.pbThis,
           PBAbilities.getName(opponent.ability)))
        opponent.effects[PBEffects::TypeIdentified]=true
      end
      return 0
    end
    if (opponent.hasWorkingAbility(:MOTORDRIVE) && !attacker.hasMoldBreaker) && isConst?(type,PBTypes,:ELECTRIC)
      if opponent.pbTooHigh?(PBStats::SPEED)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,
           PBAbilities.getName(opponent.ability),self.name))
        opponent.effects[PBEffects::TypeIdentified]=true
      else
        @battle.pbAnimation(@id,opponent,nil)
        opponent.pbIncreaseStatBasic(PBStats::SPEED,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil) if !opponent.isInvulnerable?
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",opponent.pbThis,
           PBAbilities.getName(opponent.ability)))
        opponent.effects[PBEffects::TypeIdentified]=true
      end
      return 0
    end
    bulletproofMoves=[PBMoves::ACIDSPRAY,PBMoves::AURASPHERE,PBMoves::AURABLAST,
    PBMoves::BARRAGE,PBMoves::BULLETSEED,PBMoves::EGGBOMB,
    PBMoves::ELECTROBALL,PBMoves::ENERGYBALL,PBMoves::FOCUSBLAST,
    PBMoves::GYROBALL,PBMoves::ICEBALL,PBMoves::MISTBALL,
    PBMoves::MAGNETBOMB,PBMoves::MUDBOMB,PBMoves::OCTAZOOKA,
    PBMoves::ROCKWRECKER,PBMoves::SEARINGSHOT,PBMoves::SEEDBOMB,
    PBMoves::SHADOWBALL,PBMoves::SLUDGEBOMB,PBMoves::WEATHERBALL,PBMoves::ZAPCANNON]
    
    if (opponent.hasWorkingAbility(:BULLETPROOF) && !attacker.hasMoldBreaker) && bulletproofMoves.include?(id)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,
           PBAbilities.getName(opponent.ability),self.name))
           return 0
         end
    

      if (opponent.hasWorkingAbility(:SAPSIPPER) && !attacker.hasMoldBreaker) && isConst?(type,PBTypes,:GRASS)
        if opponent.pbTooHigh?(PBStats::ATTACK)
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,
           PBAbilities.getName(opponent.ability),self.name))
           opponent.effects[PBEffects::TypeIdentified]=true
      else
        @battle.pbAnimation(@id,opponent,nil)
        opponent.pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil) if !opponent.isInvulnerable?
        @battle.pbDisplay(_INTL("{1}'s Sap Sipper raised its Attack!",opponent.pbThis))
        opponent.effects[PBEffects::TypeIdentified]=true
      end
      return 0
    end
    
    if (opponent.hasWorkingAbility(:WINDFORCE) && !attacker.hasMoldBreaker) && isConst?(type,PBTypes,:FLYING)
      if opponent.pbTooHigh?(PBStats::SPEED)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,
           PBAbilities.getName(opponent.ability),self.name))
      else
        @battle.pbAnimation(@id,opponent,nil)
        opponent.pbIncreaseStatBasic(PBStats::SPEED,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil) if !opponent.isInvulnerable?
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",opponent.pbThis,
           PBAbilities.getName(opponent.ability)))
      end
      return 0
    end
    
    if opponent.hasWorkingAbility(:CASTLEMOAT) && isConst?(type,PBTypes,:WATER)
      if opponent.pbTooHigh?(PBStats::SPDEF)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,
           PBAbilities.getName(opponent.ability),self.name))
      else
        opponent.pbIncreaseStatBasic(PBStats::SPDEF,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Sp. Defense!",opponent.pbThis,
           PBAbilities.getName(opponent.ability)))
      end
      return 0
    end
    for j in @battle.battlers
      if j.ability==PBAbilities::VAPORIZATION && isConst?(type,PBTypes,:WATER) && !j.effects[PBEffects::GastroAcid]
        @battle.pbAnimation(@id,opponent,nil)
        attacker.effects[PBEffects::SkipTurn]=true
        @battle.pbDisplay(_INTL("{1} was vaporized!",self.name))
        return 0
      end
    end
    powderAry=[PBMoves::COTTONSPORE,PBMoves::POISONPOWDER,PBMoves::POWDER,
    PBMoves::RAGEPOWDER,PBMoves::SLEEPPOWDER,PBMoves::SPORE,PBMoves::STUNSPORE]
    
    if powderAry.include?(@id) && (isConst?(opponent.item,PBItems,:SAFETYGOGGLES) || opponent.pbHasType?(PBTypes::GRASS) ||
       opponent.effects[PBEffects::ForestsCurse] || (!attacker.hasMoldBreaker && opponent.hasWorkingAbility(:OVERCOAT)) || 
       opponent.hasWorkingAbility(:OMNITYPE))
        @battle.pbDisplay(_INTL("{1} was unaffected!",opponent.pbThis))
        return 0
      
    end
    
    #if isConst?(opponent.ability,PBAbilities,:WINDFORCE) && isConst?(type,PBTypes,:FLYING)
    #    @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,
    #     PBAbilities.getName(opponent.ability),self.name))
    #  return 0
    #end
    if !attacker.hasMoldBreaker && ((opponent.hasWorkingAbility(:WATERABSORB) && isConst?(type,PBTypes,:WATER)) ||
       (opponent.hasWorkingAbility(:DRYSKIN) && isConst?(type,PBTypes,:WATER)) ||
       (opponent.hasWorkingAbility(:VOLTABSORB) && isConst?(type,PBTypes,:ELECTRIC)))
      hpgain=(opponent.totalhp/4).floor
      hpgain=0 if opponent.effects[PBEffects::HealBlock]>0
      hpgain=opponent.pbRecoverHP(hpgain)
      abilityname=PBAbilities.getName(opponent.ability)
      if hpgain==0
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} useless!",opponent.pbThis,abilityname,@name))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",opponent.pbThis,abilityname))
      end
      opponent.effects[PBEffects::TypeIdentified]=true
      return 0
    end
=begin
    if isConst?(opponent.ability,PBAbilities,:WEAKARMOR) && pbIsPhysical?(type) && opponent.hp>0
      if !opponent.pbTooLow?(PBStats::DEFENSE)
        @battle.pbAnimation(@id,opponent,nil)
        opponent.pbReduceStatBasic(PBStats::DEFENSE,1)
        @battle.pbCommonAnimation("StatDown",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} lowered its Defense!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
      end
      if !opponent.pbTooHigh?(PBStats::SPEED)
        @battle.pbAnimation(@id,opponent,nil)
        opponent.pbIncreaseStatBasic(PBStats::SPEED,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
      end
    end
=end
    #if isConst?(opponent.item,PBItems,:ABSORBBULB) && isConst?(type,PBTypes,:WATER)
    #  if !opponent.pbTooHigh?(PBStats::SPATK)
    #    opponent.pbIncreaseStatBasic(PBStats::SPATK,1)
    #    @battle.pbCommonAnimation("StatUp",opponent,nil)
    #    @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!",opponent.pbThis,
    #       PBItems.getName(opponent.item)))
    #    opponent.pokemon.itemRecycle=opponent.item
    #    opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
    #    opponent.item=0
    #  end
    #end
    #
    #if opponent.hasWorkingItem(:LUMINOUSMOSS) && isConst?(type,PBTypes,:WATER)
    #  if !opponent.pbTooHigh?(PBStats::SPDEF)
    #    opponent.pbIncreaseStatBasic(PBStats::SPDEF,1)
    #    @battle.pbCommonAnimation("StatUp",opponent,nil)
    #    @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Defense!",opponent.pbThis,
    #       PBItems.getName(opponent.item)))
    #    opponent.pbConsumeItem
    #  end
    #end
    #if isConst?(opponent.item,PBItems,:CELLBATTERY) && isConst?(type,PBTypes,:ELECTRIC)
    #  if !opponent.pbTooHigh?(PBStats::ATTACK)
    #    opponent.pbIncreaseStatBasic(PBStats::ATTACK,1)
    #    @battle.pbCommonAnimation("StatUp",opponent,nil)
    #    @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",opponent.pbThis,
    #       PBItems.getName(opponent.item)))
    #    opponent.pokemon.itemRecycle=opponent.item
    #    opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
    #    opponent.item=0
    #  end
    #end
    #if opponent.hasWorkingItem(:SNOWBALL) && isConst?(type,PBTypes,:ICE)
    #  if !opponent.pbTooHigh?(PBStats::ATTACK)
    #    opponent.pbIncreaseStatBasic(PBStats::ATTACK,1)
    #    @battle.pbCommonAnimation("StatUp",opponent,nil)
    #    @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",opponent.pbThis,
    #       PBItems.getName(opponent.item)))
    #    opponent.pbConsumeItem
    #  end
    #end
    #if (opponent.hasWorkingItem(:JABOCABERRY) && pbIsPhysical?(type)) ||
    #   (opponent.hasWorkingItem(:ROWAPBERRY) && pbIsSpecial?(type))
    #  if !attacker.hasWorkingAbility(:MAGICGUARD) && !attacker.fainted?
    #    #@battle.scene.pbDamageAnimation(attacker,0)
    #    attacker.pbReduceHP((attacker.totalhp/8).floor)
    #    @battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",opponent.pbThis,
    #    PBItems.getName(opponent.item),attacker.pbThis(true)))
    #    opponent.pbConsumeItem
    #  end
    #end
    #if opponent.hasWorkingItem(:KEEBERRY) && pbIsPhysical?(type)
    #  opponent.pbActivateBerryEffect
    #elsif opponent.hasWorkingItem(:MARANGABERRY) && pbIsSpecial?(type)
    #  opponent.pbActivateBerryEffect
    #end
    return 10 if isInSpecific
    typemod=pbTypeModifier(type,attacker,opponent)
    
    if id==PBMoves::FREEZEDRY && opponent.pbHasType?(PBTypes::WATER) && !attacker.effects[PBEffects::Electrify] && !@battle.field.effects[PBEffects::IonDeluge]
      if !$game_switches[302]
        typemod *= 4
      else
        typemod=8
      end
    end
    
#        if id == PBMoves::CORRODE && opponent.pbHasType?(PBTypes::STEEL)
#      typemod *= 4
#end

#f id == PBMoves::THOUSANDARROWS && opponent.pbHasType?(PBTypes::FLYING)
#      typemod = 4
#    end

    if id == PBMoves::FLYINGPRESS
      typemod2=pbTypeModifier(PBTypes::FLYING,attacker,opponent)
      typemod3=(typemod+typemod2)/2
      typemod3= 2 if typemod3==3
      typemod3= 8 if typemod3==6
      typemod=typemod3
    end
    aryofflyingweak=[PBTypes::ICE,PBTypes::ROCK,PBTypes::ELECTRIC]
    aryofflyingstrong=[PBTypes::BUG,PBTypes::FIGHTING,PBTypes::GRASS,PBTypes::GROUND]
    if !$game_switches[302] && @battle.pbWeather==PBWeather::STRONGWINDS && typemod>4 && 
       opponent.pbHasType?(PBTypes::FLYING) && aryofflyingweak.include?(type)
      typemod /= 2
    elsif $game_switches[302] && @battle.pbWeather==PBWeather::STRONGWINDS && typemod>4 && 
          opponent.pbHasType?(PBTypes::FLYING) && aryofflyingstrong.include?(type)
      typemod /= 2
    end
    if (opponent.ability==PBAbilities::ETHEREALSHROUD && !attacker.hasMoldBreaker && 
       !opponent.effects[PBEffects::GastroAcid]) && 
       !attacker.hasWorkingAbility(:SCRAPPY)
      if type==PBTypes::NORMAL || type==PBTypes::FIGHTING
        typemod=0
      end
      if type==PBTypes::BUG || type==PBTypes::POISON
        typemod /= 2
      end
    end
    if opponent.effects[PBEffects::ForestsCurse]
      if type==PBTypes::GRASS || type==PBTypes::WATER || type==PBTypes::GROUND ||
         type==PBTypes::ELECTRIC 
        typemod /= 2
      elsif type==PBTypes::FIRE || type==PBTypes::ICE || type==PBTypes::FLYING ||
         type==PBTypes::BUG || type==PBTypes::POISON
        typemod *= 2
      end
    end
    if opponent.effects[PBEffects::TrickOrTreat]
      if type==PBTypes::NORMAL || type==PBTypes::FIGHTING
        typemod=0
      elsif type==PBTypes::BUG || type==PBTypes::POISON
        typemod /= 2
      elsif type==PBTypes::DARK || type==PBTypes::GHOST
        typemod *= 2
      end
    end
    if opponent.ability==PBAbilities::SYNTHETICALLOY && type==PBTypes::FIRE && !opponent.effects[PBEffects::GastroAcid]
      typemod=4
    end
    
    if typemod==0 && !(isConst?(type,PBTypes,:NORMAL) && (attacker.hasWorkingAbility(:PIXILATE) || 
       attacker.hasWorkingAbility(:NORMALIZE) || attacker.hasWorkingAbility(:REFRIGERATE) || 
       attacker.hasWorkingAbility(:AERILATE) || attacker.hasWorkingAbility(:INTOXICATE)))
#      !isConst?(id,PBMoves,:CORRODE)
      attacker.pbConsumeItem if isConst?(@id,PBMoves,:NATURALGIFT)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      opponent.effects[PBEffects::TypeIdentified]=true
      skipForFutureSight=false
      for i in 0..3
        if attacker.pokemonIndex==@battle.battlers[i].effects[PBEffects::FutureSightUser]
          if @battle.battlers[i].effects[PBEffects::FutureSight]==0
            skipForFutureSight=true
            break
          end
        end
      end
      attacker.pbCancelMoves if !skipForFutureSight
    end
    if opponent.hasWorkingAbility(:WONDERGUARD) && !attacker.hasMoldBreaker && typemod<=4 && type>=0
      attacker.pbConsumeItem if isConst?(@id,PBMoves,:NATURALGIFT)
      @battle.pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",opponent.pbThis))
      opponent.damagestate.critical=false
      opponent.effects[PBEffects::TypeIdentified]=true
      return 0 
    end
      
    return typemod
  end



################################################################################
# This move's accuracy check
################################################################################
  def pbAccuracyCheck(attacker,opponent)
    baseaccuracy=@accuracy
    baseaccuracy=0 if opponent.effects[PBEffects::Minimize] && (tramplesMinimize?(1) || id == PBMoves::FLYINGPRESS)
    return true if baseaccuracy==0
    #return true if @battle.futuresight
    return true if attacker.hasWorkingAbility(:NOGUARD)
    return true if opponent.hasWorkingAbility(:NOGUARD)
    return true if opponent.hasWorkingAbility(:STORMDRAIN) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:WATER)
    return true if opponent.hasWorkingAbility(:LIGHTNINGROD) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:ELECTRIC)
    return true if opponent.hasWorkingAbility(:WATERABSORB) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:WATER)
    return true if opponent.hasWorkingAbility(:VOLTABSORB) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:ELECTRIC)
    return true if opponent.hasWorkingAbility(:FLASHFIRE) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:FIRE)
    return true if opponent.hasWorkingAbility(:DRYSKIN) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:WATER)
    return true if opponent.hasWorkingAbility(:MOTORDRIVE) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:ELECTRIC)
    return true if opponent.hasWorkingAbility(:LEVITATE) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:GROUND)
    return true if opponent.hasWorkingAbility(:SAPSIPPER) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:GRASS)
    return true if opponent.hasWorkingAbility(:WINDFORCE) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:FLYING)
    return true if opponent.hasWorkingAbility(:WINDFORCE) &&
                   isConst?(pbType(@type,attacker,opponent),PBTypes,:FLYING)
    return true if opponent.hasWorkingAbility(:SOUNDPROOF) && isSoundBased?
    return true if isPowderMove? &&
                   (opponent.pbHasType?(PBTypes::GRASS) ||
                   opponent.hasWorkingItem(:SAFETYGOGGLES) || 
                   opponent.hasWorkingAbility(:OVERCOAT))
    return true if opponent.hasWorkingAbility(:BULLETPROOF) && isBombMove?
    return true if opponent.hasWorkingAbility(:TELEPATHY) && !pbIsStatus? &&
                    !opponent.pbIsOpposing?(attacker.index)
    return true if opponent.hasWorkingAbility(:ETHEREALSHROUD) &&
                    (isConst?(pbType(@type,attacker,opponent),PBTypes,:NORMAL) ||
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:FIGHTING)) &&
                    !attacker.hasWorkingAbility(:SCRAPPY)
    for j in @battle.battlers
      if !attacker.hasMoldBreaker && j.ability==PBAbilities::VAPORIZATION && 
         isConst?(type,PBTypes,:WATER) && !j.effects[PBEffects::GastroAcid]
        return true
      end
    end
    return true if opponent.effects[PBEffects::Telekinesis]>0
    
    # One-hit KO accuracy handled elsewhere
    baseaccuracy=50 if (@battle.pbWeather==PBWeather::SUNNYDAY || 
                       @battle.pbWeather==PBWeather::HARSHSUN) &&
                       (@function==0x08 || @function==0x15) # Thunder or Hurricane
    accstage=attacker.stages[PBStats::ACCURACY]
    accstage=0 if (opponent.hasWorkingAbility(:UNAWARE) && !attacker.hasMoldBreaker)
    accuracy=(accstage>=0) ? (accstage+3)*100.0/3 : 300.0/(3-accstage)
    evastage=opponent.stages[PBStats::EVASION]
    evastage-=2 if @battle.field.effects[PBEffects::Gravity]>0
    evastage=-6 if evastage<-6
    evastage=0 if opponent.effects[PBEffects::Foresight] ||
                  opponent.effects[PBEffects::MiracleEye] ||
                  @function==0xA9 || # Chip Away
                  attacker.hasWorkingAbility(:UNAWARE)
    evasion=(evastage>=0) ? (evastage+3)*100.0/3 : 300.0/(3-evastage)
    if attacker.hasWorkingAbility(:COMPOUNDEYES)
      accuracy*=1.3
    end
    if isConst?(attacker.item,PBItems,:MICLEBERRY)
      if (attacker.hasWorkingAbility(:GLUTTONY) && attacker.hp<=(attacker.totalhp/2).floor) ||
         attacker.hp<=(attacker.totalhp/4).floor
        accuracy*=1.2
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
      end
    end
    if attacker.hasWorkingAbility(:VICTORYSTAR)
      accuracy*=1.1
    end
    partner=attacker.pbPartner
    if partner && partner.hasWorkingAbility(:VICTORYSTAR)
      accuracy*=1.1
    end
    if isConst?(attacker.item,PBItems,:WIDELENS)
      accuracy*=1.1
    end
    realtype=pbType(@type,attacker,opponent)
    if attacker.hasWorkingAbility(:HUSTLE) && pbIsPhysical?(realtype)
      accuracy*=0.8
    end
#    if @battle.pbWeather==PBWeather::NEWMOON && @id==PBMoves::DARKVOID
#      accuracy*=8
#    end
    if (opponent.hasWorkingAbility(:WONDERSKIN) && !attacker.hasMoldBreaker) && @basedamage==0 &&
       attacker.pbIsOpposing?(opponent.index)
      accuracy=50 if accuracy>50
    end
    if (opponent.hasWorkingAbility(:TANGLEDFEET) && !attacker.hasMoldBreaker) &&
       opponent.effects[PBEffects::Confusion]>0
      evasion*=1.2
    end
    if @battle.pbWeather==PBWeather::SANDSTORM && (opponent.hasWorkingAbility(:SANDVEIL) && !attacker.hasMoldBreaker)
      evasion*=1.25
    end
    if @battle.pbWeather==PBWeather::HAIL && (opponent.hasWorkingAbility(:SNOWCLOAK) && !attacker.hasMoldBreaker)
      evasion*=1.25
    end
    if @battle.pbWeather==PBWeather::NEWMOON && (opponent.hasWorkingAbility(:ILLUMINATE) && !attacker.hasMoldBreaker)
      evasion*=1.25
    end
    if isConst?(opponent.item,PBItems,:BRIGHTPOWDER)
      evasion*=1.1
    end
    if isConst?(opponent.item,PBItems,:LAXINCENSE)
      evasion*=1.1
    end
  #  Kernel.pbMessage
 # Kernel.pbMessage(Kernel.pbMessage(accuracy))
=begin
    if @battle.internalbattle && @battle.pbOwnedByPlayer?(attacker.index)
        accuracy=95 if accuracy <= 95 && accuracy >= 90
        accuracy=90 if accuracy >= 80 && accuracy <= 90
        accuracy=85 if accuracy >= 70 && accuracy <= 80
      end
    if @battle.internalbattle
        firstvalue = (99 - @battle.pbRandom(100))
        secondvalue= (baseaccuracy*accuracy/evasion)
       value = firstvalue<secondvalue
      else
        firstvalue=@battle.pbRandom(100)
        secondvalue= (baseaccuracy*accuracy/evasion)
    #    Kernel.pbMessage(firstvalue.to_s+" "+secondvalue.to_s)
        value = firstvalue<secondvalue
      end
      #Kernel.pbMessage(secondvalue.to_s)

    return value
=end
    return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)
  end


  
  
################################################################################
# Damage calculation and modifiers
################################################################################
  def pbIsCritical?(attacker,opponent)
    if opponent.hasWorkingAbility(:SHELLARMOR) ||
       opponent.hasWorkingAbility(:BATTLEARMOR)
      return false if !attacker.hasMoldBreaker
    end
    return false if opponent.pbOwnSide.effects[PBEffects::LuckyChant]>0
    return false if opponent.hasWorkingAbility(:STORMDRAIN) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:WATER)
    return false if opponent.hasWorkingAbility(:LIGHTNINGROD) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:ELECTRIC)
    return false if opponent.hasWorkingAbility(:WATERABSORB) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:WATER)
    return false if opponent.hasWorkingAbility(:VOLTABSORB) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:ELECTRIC)
    return false if opponent.hasWorkingAbility(:FLASHFIRE) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:FIRE)
    return false if opponent.hasWorkingAbility(:DRYSKIN) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:WATER)
    return false if opponent.hasWorkingAbility(:MOTORDRIVE) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:ELECTRIC)
    return false if opponent.hasWorkingAbility(:LEVITATE) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:GROUND)
    return false if opponent.hasWorkingAbility(:SAPSIPPER) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:GRASS)
    return false if opponent.hasWorkingAbility(:WINDFORCE) &&
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:FLYING)
    return false if opponent.hasWorkingAbility(:SOUNDPROOF) && self.isSoundBased?
    return false if isPowderMove? &&
                    (opponent.pbHasType?(PBTypes::GRASS) ||
                    opponent.hasWorkingItem(:SAFETYGOGGLES) || 
                    opponent.hasWorkingAbility(:OVERCOAT))
    return false if opponent.hasWorkingAbility(:BULLETPROOF) && isBombMove?  
    return false if opponent.hasWorkingAbility(:TELEPATHY) && !pbIsStatus? &&
                    !opponent.pbIsOpposing?(attacker.index)
    return false if opponent.hasWorkingAbility(:ETHEREALSHROUD) &&
                    (isConst?(pbType(@type,attacker,opponent),PBTypes,:NORMAL) ||
                    isConst?(pbType(@type,attacker,opponent),PBTypes,:FIGHTING)) &&
                    !attacker.hasWorkingAbility(:SCRAPPY)
    for j in @battle.battlers
      if !attacker.hasMoldBreaker && j.ability==PBAbilities::VAPORIZATION && 
         isConst?(type,PBTypes,:WATER) && !j.effects[PBEffects::GastroAcid]
        return false
      end
    end
    return true if @function==0xA0 # Frost Breath
    c=0
    ratios=[16,8,2,1,1,1,1,1]
    c+=attacker.effects[PBEffects::FocusEnergy]
    c+=1 if (@flags&0x80)!=0 # flag h: Has high critical hit rate
    if (attacker.inHyperMode? rescue false) && isConst?(self.type,PBTypes,:SHADOW)
      c+=1
    end
    if isConst?(attacker.species,PBSpecies,:CHANSEY) && 
       isConst?(attacker.item,PBItems,:LUCKYPUNCH)
      c+=2
    end
    if isConst?(attacker.species,PBSpecies,:FARFETCHD) && 
       isConst?(attacker.item,PBItems,:STICK)
      c+=2
    end
    c+=1 if attacker.hasWorkingAbility(:SUPERLUCK)
    c+=1 if isConst?(attacker.item,PBItems,:SCOPELENS)
    c+=1 if isConst?(attacker.item,PBItems,:RAZORCLAW)
    
    
    #c=4
    
    c=4 if c>4
=begin
    if @battle.internalbattle && @battle.pbOwnedByPlayer?(attacker.index)
        return false if c < 3 && @battle.pbRandom(3)==0
      end
=end
    return @battle.pbRandom(ratios[c])==0
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg
  end
  
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    return damagemult
  end

  def pbCalcDamage(attacker,opponent,options=0,kang=false,lernean=0,hypothetical=false)
    opponent.damagestate.critical=false
    opponent.damagestate.typemod=0
    opponent.damagestate.calcdamage=0
    opponent.damagestate.hplost=0 
    if @basedamage==0
      return 0
    end   
    if (options&NOCRITICAL)==0
      opponent.damagestate.critical=pbIsCritical?(attacker,opponent)
    end
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    basedmg=@basedamage
    basedmg=pbBaseDamage(basedmg,attacker,opponent)
    Kernel.pbMessage(_INTL("Base damage: {1}",basedmg.to_s)) if $game_switches[670]
    if (options&NOTYPE)==0
      type=@type
      type=pbType(type,attacker,opponent)
    else
      type=-1 # Will be treated as physical
    end
    atk=attacker.attack
    defense=opponent.defense
    spatk=attacker.spatk
    spdef=opponent.spdef
    #Gym Badges (internal battles only)
    #if @battle.internalbattle
    #  if @battle.pbOwnedByPlayer?(attacker.index)
    #    atk=(atk*1.1).floor if @battle.pbPlayer.numbadges>=BADGESBOOSTATTACK
    #  end
    #  if @battle.pbOwnedByPlayer?(opponent.index)
    #    defense=(defense*1.1).floor if @battle.pbPlayer.numbadges>=BADGESBOOSTDEFENSE
    #  end
    #  if @battle.pbOwnedByPlayer?(attacker.index)
    #   spatk=(spatk*1.1).floor if @battle.pbPlayer.numbadges>=BADGESBOOSTSPATK
    #  end
    #  if @battle.pbOwnedByPlayer?(opponent.index)
    #    spdef=(spdef*1.1).floor if @battle.pbPlayer.numbadges>=BADGESBOOSTSPDEF
    #  end
    #end
    #Stat Stage
    atkstage=attacker.stages[PBStats::ATTACK]+6
    spatkstage=attacker.stages[PBStats::SPATK]+6
    defstage=opponent.stages[PBStats::DEFENSE]+6
    spdefstage=opponent.stages[PBStats::SPDEF]+6
    defstage=spdefstage=6 if @function==0xA9 # Chip Away
    if attacker.hasWorkingAbility(:UNAWARE)
      defstage=spdefstage=6
    end
    if opponent.hasWorkingAbility(:UNAWARE)
      atkstage=spatkstage=6
    end
    if opponent.damagestate.critical
      atkstage=6 if atkstage<6
      spatkstage=6 if spatkstage<6
      defstage=6 if defstage>6
      spdefstage=6 if spdefstage>6
    end
    atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
    spatk=(spatk*1.0*stagemul[spatkstage]/stagediv[spatkstage]).floor
    defense=(defense*1.0*stagemul[defstage]/stagediv[defstage]).floor
    spdef=(spdef*1.0*stagemul[spdefstage]/stagediv[spdefstage]).floor
    # Helping Hand
    if attacker.effects[PBEffects::HelpingHand] && (options&NOREFLECT)==0
      basedmg=(basedmg*1.5).round
      Kernel.pbMessage(_INTL("Helping Hand boost: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.hasWorkingAbility(:TECHNICIAN) && basedmg<=60
      basedmg=(basedmg*1.5).round
      Kernel.pbMessage(_INTL("Technician boost: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if opponent.hasWorkingAbility(:MARVELSCALE) && opponent.status>0
      defense=(defense*1.5).round
    end
    if (isConst?(opponent.type1,PBTypes,:ROCK) ||
       isConst?(opponent.type2,PBTypes,:ROCK)) &&
       @battle.pbWeather==PBWeather::SANDSTORM
      spdef=(spdef*1.5).round
    end
    if isConst?(opponent.item,PBItems,:EVIOLITE)
      evos=pbGetEvolvedFormData(opponent.species)
      if evos && evos.length>0
        defense=(defense*1.5).round
        spdef=(spdef*1.5).round
      end
    end
    defense = (defense*2.0).round if opponent.hasWorkingAbility(:FURCOAT)
    # Grass Pelt activates while Grassy Terrain is active
    if @battle.field.effects[PBEffects::GrassyTerrain]>0 && 
       !opponent.isAirborne?(attacker && attacker.hasMoldBreaker) &&
       !opponent.isInvulnerable? && opponent.hasWorkingAbility(:GRASSPELT)
      defense = (defense*1.5).round
    end
    if opponent.effects[PBEffects::BurstMode]
      defense=(defense*1.1).round
      spdef=(spdef*1.1).round
    end
    #basedmg=(basedmg*0.5).floor if kang
    #basedmg /= lernean if lernean!=0
    #basedmg += 5 if lernean!=0
    #if @battle.mistyterrain > 0 
    #    if !isConst?(attacker.type,PBTypes,:FLYING) && !isConst?(attacker.ability,PBAbilities,:LEVITATE) && !isConst?(attacker.item,PBItems,:AIRBALLOON) && attacker.effects[PBEffects::MagnetRise]==0 && attacker.effects[PBEffects::Telekinesis]==0
    #      basedmg=(basedmg*0.5)  if isConst?(attacker.type,PBTypes,:DRAGON)
    #    end
    #end
=begin
if attacker.ability==PBAbilities::STRONGJAW &&
      [PBMoves::BITE,PBMoves::CRUNCH,PBMoves::FIREFANG,
      PBMoves::ICEFANG,PBMoves::HYPERFANG,PBMoves::POISONFANG,
      PBMoves::THUNDERFANG].include?(@id)
      basedmg=(basedmg*1.5).floor 
    end
=end   
    #basedmg=(basedmg*1.5)  if @battle.electricterrain > 0 && isConst?(type,PBTypes,:ELECTRIC)
    # Type boosting items
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:SILKSCARF) && isConst?(type,PBTypes,:NORMAL)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:BLACKBELT) && isConst?(type,PBTypes,:FIGHTING)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:SHARPBEAK) && isConst?(type,PBTypes,:FLYING)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:POISONBARB) && isConst?(type,PBTypes,:POISON)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:SOFTSAND) && isConst?(type,PBTypes,:GROUND)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:HARDSTONE) && isConst?(type,PBTypes,:ROCK)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:SILVERPOWDER) && isConst?(type,PBTypes,:BUG)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:SPELLTAG) && isConst?(type,PBTypes,:GHOST)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:METALCOAT) && isConst?(type,PBTypes,:STEEL)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:CHARCOAL) && isConst?(type,PBTypes,:FIRE)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:MYSTICWATER) && isConst?(type,PBTypes,:WATER)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:MIRACLESEED) && isConst?(type,PBTypes,:GRASS)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:MAGNET) && isConst?(type,PBTypes,:ELECTRIC)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:TWISTEDSPOON) && isConst?(type,PBTypes,:PSYCHIC)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:NEVERMELTICE) && isConst?(type,PBTypes,:ICE)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:DRAGONFANG) && isConst?(type,PBTypes,:DRAGON)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:BLACKGLASSES) && isConst?(type,PBTypes,:DARK)
    # Plates
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:FISTPLATE) && isConst?(type,PBTypes,:FIGHTING)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:SKYPLATE) && isConst?(type,PBTypes,:FLYING)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:TOXICPLATE) && isConst?(type,PBTypes,:POISON)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:EARTHPLATE) && isConst?(type,PBTypes,:GROUND)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:STONEPLATE) && isConst?(type,PBTypes,:ROCK)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:INSECTPLATE) && isConst?(type,PBTypes,:BUG)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:SPOOKYPLATE) && isConst?(type,PBTypes,:GHOST)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:IRONPLATE) && isConst?(type,PBTypes,:STEEL)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:FLAMEPLATE) && isConst?(type,PBTypes,:FIRE)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:SPLASHPLATE) && isConst?(type,PBTypes,:WATER)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:MEADOWPLATE) && isConst?(type,PBTypes,:GRASS)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:ZAPPLATE) && isConst?(type,PBTypes,:ELECTRIC)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:MINDPLATE) && isConst?(type,PBTypes,:PSYCHIC)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:ICICLEPLATE) && isConst?(type,PBTypes,:ICE)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:DRACOPLATE) && isConst?(type,PBTypes,:DRAGON)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:DREADPLATE) && isConst?(type,PBTypes,:DARK)
    basedmg=(basedmg*1.2).round if isConst?(attacker.item,PBItems,:PIXIEPLATE) && isConst?(type,PBTypes,:FAIRY)
    Kernel.pbMessage(_INTL("After Plates multipliers: {1}",basedmg.to_s)) if $game_switches[670]
    if attacker.hasWorkingAbility(:AMPLIFIER) &&
      (@flags&0x400)!=0 && # flag k: Is sound-based move
      basedmg=(basedmg*1.25).round
      Kernel.pbMessage(_INTL("Amplifier boost: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if isConst?(type,PBTypes,:ELECTRIC)
      if $game_map.map_id==455 && $game_player.y >= 17 && $game_player.y <= 27 && 
         $game_player.x >= 60 && $game_player.x <= 71 && !$game_switches[521]
         @battle.pbDisplay(_INTL("The electric attack seemed to trigger the lightningrod nearby!",attacker.pbThis(true),PBItems.getName(attacker.item)))      
        @battle.pbDisplay(_INTL("It's now pulsing with an electric light!",attacker.pbThis(true),PBItems.getName(attacker.item)))  if !hypothetical 
        $game_switches[521]=true if !hypothetical
        $game_map.need_refresh=true
      end
    end
    if isConst?(type,PBTypes,:FIRE) && attacker.hasWorkingAbility(:BLAZEBOOST)
      attacker.effects[PBEffects::BlazeBoost]=true
      attacker.pbCheckForm
      if !attacker.pbTooHigh?(PBStats::ATTACK) || !attacker.pbTooHigh?(PBStats::SPATK) ||
         !attacker.pbTooHigh?(PBStats::SPEED)
        @battle.pbDisplay("Blaze Boost kicked in!")
        if !attacker.pbTooHigh?(PBStats::ATTACK)
          attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",attacker,nil)
          @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))
        end
        if !attacker.pbTooHigh?(PBStats::SPATK)
          attacker.pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",attacker,nil)
          @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",attacker.pbThis))
        end
        if !attacker.pbTooHigh?(PBStats::SPEED)
          attacker.pbIncreaseStatBasic(PBStats::SPEED,1) 
          @battle.pbCommonAnimation("StatUp",attacker,nil)
          @battle.pbDisplay(_INTL("{1}'s Speed rose!",attacker.pbThis))
        end
      end
    end
    # Gems
    if (isConst?(attacker.item,PBItems,:NORMALGEM) && isConst?(type,PBTypes,:NORMAL)) ||
         (isConst?(attacker.item,PBItems,:FIGHTINGGEM) && isConst?(type,PBTypes,:FIGHTING)) ||
         (isConst?(attacker.item,PBItems,:FLYINGGEM) && isConst?(type,PBTypes,:FLYING)) ||
         (isConst?(attacker.item,PBItems,:POISONGEM) && isConst?(type,PBTypes,:POISON)) ||
         (isConst?(attacker.item,PBItems,:GROUNDGEM) && isConst?(type,PBTypes,:GROUND)) ||
         (isConst?(attacker.item,PBItems,:ROCKGEM) && isConst?(type,PBTypes,:ROCK)) ||
         (isConst?(attacker.item,PBItems,:BUGGEM) && isConst?(type,PBTypes,:BUG)) ||
         (isConst?(attacker.item,PBItems,:GHOSTGEM) && isConst?(type,PBTypes,:GHOST)) ||
         (isConst?(attacker.item,PBItems,:STEELGEM) && isConst?(type,PBTypes,:STEEL)) ||
         (isConst?(attacker.item,PBItems,:FIREGEM) && isConst?(type,PBTypes,:FIRE)) ||
         (isConst?(attacker.item,PBItems,:WATERGEM) && isConst?(type,PBTypes,:WATER)) ||
         (isConst?(attacker.item,PBItems,:GRASSGEM) && isConst?(type,PBTypes,:GRASS)) ||
         (isConst?(attacker.item,PBItems,:ELECTRICGEM) && isConst?(type,PBTypes,:ELECTRIC)) ||
         (isConst?(attacker.item,PBItems,:PSYCHICGEM) && isConst?(type,PBTypes,:PSYCHIC)) ||
         (isConst?(attacker.item,PBItems,:ICEGEM) && isConst?(type,PBTypes,:ICE)) ||
         (isConst?(attacker.item,PBItems,:DRAGONGEM) && isConst?(type,PBTypes,:DRAGON)) ||
         (isConst?(attacker.item,PBItems,:FAIRYGEM) && isConst?(type,PBTypes,:FAIRY)) ||
         (isConst?(attacker.item,PBItems,:DARKGEM) && isConst?(type,PBTypes,:DARK))
        basedmg=(basedmg*1.3).round
        Kernel.pbMessage(_INTL("Gem boost: {1}",basedmg.to_s)) if $game_switches[670]
        @battle.pbDisplay(_INTL("{1} consumed its {2} and increased its power!",attacker.pbThis(false),PBItems.getName(attacker.item)))    if !hypothetical   
        attacker.damagestate.gemused=true
        #attacker.pbConsumeItem  if !hypothetical
    end
    if @battle.field.effects[PBEffects::ElectricTerrain]>0 &&
       !attacker.isAirborne? && isConst?(type,PBTypes,:ELECTRIC) &&
       !attacker.isInvulnerable?
      basedmg=(basedmg*1.5).round
      Kernel.pbMessage(_INTL("Electric Terrain boost: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if @battle.field.effects[PBEffects::GrassyTerrain]>0 &&
       !attacker.isAirborne? && !attacker.isInvulnerable? && 
       isConst?(type,PBTypes,:GRASS)
      basedmg=(basedmg*1.5).round
      Kernel.pbMessage(_INTL("Grassy Terrain boost: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !opponent.isAirborne?(attacker.hasMoldBreaker) && 
       !opponent.isInvulnerable? && isConst?(type,PBTypes,:DRAGON)
      basedmg=(basedmg*0.5).round
      Kernel.pbMessage(_INTL("Misty Terrain reduction: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if @function===0x121 #Foul Play
      atk=opponent.attack
      #atkstage=attacker.stages[PBStats::ATTACK]+6
      atk=(atk*stagemul[opponent.stages[PBStats::ATTACK]+6]/stagediv[opponent.stages[PBStats::ATTACK]+6]).floor
    end
    if isConst?(@id,PBMoves,:KNOCKOFF) && (!@battle.pbIsUnlosableItem(opponent,opponent.item) && opponent.item!=0)
      basedmg=(basedmg*1.5).round
      Kernel.pbMessage(_INTL("Knock Off applied: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if isConst?(attacker.item,PBItems,:ROCKINCENSE) && isConst?(type,PBTypes,:ROCK)
      basedmg=(basedmg*1.2).round
    end
    if isConst?(attacker.item,PBItems,:ROSEINCENSE) && isConst?(type,PBTypes,:GRASS)
      basedmg=(basedmg*1.2).round
    end
    if isConst?(attacker.item,PBItems,:SEAINCENSE) && isConst?(type,PBTypes,:WATER)
      basedmg=(basedmg*1.2).round
    end
    if isConst?(attacker.item,PBItems,:WAVEINCENSE) && isConst?(type,PBTypes,:WATER)
      basedmg=(basedmg*1.2).round
    end
    if isConst?(attacker.item,PBItems,:ODDINCENSE) && isConst?(type,PBTypes,:PSYCHIC)
      basedmg=(basedmg*1.2).round
    end
    spdef=(spdef*1.5).round if isConst?(opponent.item,PBItems,:ASSAULTVEST) && pbIsSpecial?(type)
    Kernel.pbMessage(_INTL("Damage after Assault Vest: {1}",basedmg.to_s)) if $game_switches[670]
    Kernel.pbMessage(_INTL("Damage after Incenses: {1}",basedmg.to_s)) if $game_switches[670]
    atk=(atk*1.5).round if isConst?(attacker.item,PBItems,:CHOICEBAND)
    spatk=(spatk*1.5).round if isConst?(attacker.item,PBItems,:CHOICESPECS)
    if (isConst?(attacker.species,PBSpecies,:PIKACHU) || isConst?(attacker.species,PBSpecies,:DELTAPIKACHU)) && isConst?(attacker.item,PBItems,:LIGHTBALL)
      basedmg=(basedmg*2.0).round
      Kernel.pbMessage(_INTL("Light Ball: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if (isConst?(attacker.species,PBSpecies,:CUBONE) ||
       isConst?(attacker.species,PBSpecies,:MAROWAK)) &&
       isConst?(attacker.item,PBItems,:THICKCLUB)
      atk=(atk*2.0).round
    end
    if (isConst?(opponent.species,PBSpecies,:DITTO) || isConst?(opponent.species,PBSpecies,:DELTADITTO)) && 
       !opponent.effects[PBEffects::Transform] && isConst?(opponent.item,PBItems,:METALPOWDER)
      defense=(defense*1.5).round
      spdef=(spdef*1.5).round
    end
    if isConst?(attacker.species,PBSpecies,:CLAMPERL)
      if attacker.hasWorkingItem(:DEEPSEATOOTH)
        spatk=(spatk*2.0).round
      end
    end
    if isConst?(opponent.species,PBSpecies,:CLAMPERL)
      if opponent.hasWorkingItem(:DEEPSEASCALE)
        spdef=(spdef*2.0).round
      end
    end
    if isConst?(attacker.species,PBSpecies,:DELTACLAMPERL)
      if attacker.hasWorkingItem(:DRAGONFANG)
        atk=(atk*2.0).round
      end
    end
    if isConst?(opponent.species,PBSpecies,:DELTACLAMPERL)
      if opponent.hasWorkingItem(:DRAGONSCALE)
        defense=(defense*2.0).round
      end
    end
    if (isConst?(attacker.species,PBSpecies,:LATIAS) ||
       isConst?(attacker.species,PBSpecies,:LATIOS)) &&
       attacker.hasWorkingItem(:SOULDEW) && !@battle.rules["souldewclause"]
      spatk=(spatk*1.5).round 
    end
    if (isConst?(opponent.species,PBSpecies,:LATIAS) ||
       isConst?(opponent.species,PBSpecies,:LATIOS)) &&
       attacker.hasWorkingItem(:SOULDEW) && !@battle.rules["souldewclause"]
      spdef=(spdef*1.5).round
    end
    #if isConst?(attacker.item,PBItems,:LIFEOB)
    #  basedmg=(basedmg*1.3).floor
    #  Kernel.pbMessage(_INTL("Damage 4: {1}",basedmg.to_s))
    #end
    if isConst?(attacker.item,PBItems,:MUSCLEBAND) && pbIsPhysical?(type)
      basedmg=(basedmg*1.1).round
      Kernel.pbMessage(_INTL("Muscle Band: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if isConst?(attacker.item,PBItems,:WISEGLASSES) && pbIsSpecial?(type)
      basedmg=(basedmg*1.1).round
      Kernel.pbMessage(_INTL("Wise Glasses: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if isConst?(attacker.species,PBSpecies,:DIALGA) &&
       isConst?(attacker.item,PBItems,:ADAMANTORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:STEEL))
      basedmg=(basedmg*1.2).round
      Kernel.pbMessage(_INTL("Adamant Orb: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if isConst?(attacker.species,PBSpecies,:PALKIA) &&
       isConst?(attacker.item,PBItems,:LUSTROUSORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:WATER))
      basedmg=(basedmg*1.2).round
      Kernel.pbMessage(_INTL("Lustrous Orb: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if isConst?(attacker.species,PBSpecies,:GIRATINA) &&
       isConst?(attacker.item,PBItems,:GRISEOUSORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:GHOST))
      basedmg=(basedmg*1.2).round
      Kernel.pbMessage(_INTL("Griseous Orb: {1}",basedmg.to_s)) if $game_switches[670]
    end
    basedmg=pbBaseDamageMultiplier(basedmg,attacker,opponent)
    if attacker.effects[PBEffects::MeFirst]
      basedmg=(basedmg*1.5).round
      Kernel.pbMessage(_INTL("Me First: {1}",basedmg.to_s)) if $game_switches[670]
    end
    spatk=(spatk*2.0).round if attacker.hasWorkingAbility(:ATHENIAN)
    atk=(atk*2.0).round if attacker.hasWorkingAbility(:PUREPOWER)
    atk=(atk*2.0).round if attacker.hasWorkingAbility(:HUGEPOWER)
    if attacker.hasWorkingAbility(:WINTERJOY)
      pbIsMonth(1)
      if $game_variables[1]=="November" ||
         $game_variables[1]=="December" ||
         $game_variables[1]=="January" ||
         $game_variables[1]=="February"
        atk=(atk*1.4).round
        spatk=(spatk*1.4).round
      end
      if $game_variables[1]=="May" ||
         $game_variables[1]=="June" ||
         $game_variables[1]=="July" ||
         $game_variables[1]=="August"
        atk=(atk*0.7).round
        spatk=(spatk*0.7).round
      end
    end
    atk=(atk*1.5).round if attacker.hasWorkingAbility(:HUSTLE)
    if attacker.hasWorkingAbility(:GUTS) &&
       (attacker.status==PBStatuses::BURN ||
       attacker.status==PBStatuses::PARALYSIS ||
       attacker.status==PBStatuses::POISON)
      atk=(atk*1.5).round
    end
    if (attacker.hasWorkingAbility(:PLUS) ||
       attacker.hasWorkingAbility(:MINUS))
      partner=attacker.pbPartner
      if partner && (partner.hasWorkingAbility(:PLUS) ||
         partner.hasWorkingAbility(:MINUS))
        spatk=(spatk*1.5).round
      end
    end
    if isConst?(type,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:AERILATE)
      attacker.effects[PBEffects::MoveTypeChanged]=true
      type=PBTypes::FLYING
      basedmg=(basedmg*1.3).round
    end
    if isConst?(type,PBTypes,:ROCK) && attacker.hasWorkingAbility(:FOUNDRY)
      attacker.effects[PBEffects::MoveTypeChanged]=true
      type=PBTypes::FIRE
      basedmg=(basedmg*1.3).round
    end
=begin
    if isConst?(attacker.ability,PBAbilities,:PROTEAN)
      if (attacker.isShadow? rescue false)
        @battle.pbDisplay(_INTL("{1}'s corruption prevented Protean from working!",attacker.pbThis(true)))
      elsif pbIsConfusion?
        elsif attacker.type1 != type || attacker.type2 != type
        attacker.type1=type
        attacker.type2=type
        typenameprotean=PBTypes.getName(attacker.type1)
        @battle.pbDisplay(_INTL("{1} became {2}-type!",attacker.pbThis(true),typenameprotean))
        end
      end
=end
    if isConst?(type,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:INTOXICATE)
      attacker.effects[PBEffects::MoveTypeChanged]=true
      type=PBTypes::POISON
      basedmg=(basedmg*1.3).round
    end
    if isConst?(type,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:PIXILATE)
      attacker.effects[PBEffects::MoveTypeChanged]=true
      type=PBTypes::FAIRY
      basedmg=(basedmg*1.3).round
    end
    if isConst?(type,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:REFRIGERATE)
      attacker.effects[PBEffects::MoveTypeChanged]=true
      type=PBTypes::ICE
      basedmg=(basedmg*1.3).round
    end
    Kernel.pbMessage(_INTL("Damage after -ate abilities: {1}",basedmg.to_s)) if $game_switches[670]
    if attacker.hasWorkingAbility(:TOUGHCLAWS) && (@flags&0x01)!=0 && basedmg>0
      basedmg=(basedmg*4.0/3.0).round
      Kernel.pbMessage(_INTL("Tough Claws: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && isConst?(type,PBTypes,:DARK)) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && isConst?(type,PBTypes,:FAIRY))
      if @battle.pbCheckGlobalAbility(:AURABREAK) && @battle.pbWeather!=PBWeather::NEWMOON
        basedmg=(basedmg*3/4).round
        Kernel.pbMessage(_INTL("Aura abilities: {1}",basedmg.to_s)) if $game_switches[670]
      elsif @battle.pbCheckGlobalAbility(:AURABREAK) && @battle.pbWeather==PBWeather::NEWMOON
        if (@battle.pbCheckGlobalAbility(:DARKAURA) && isConst?(type,PBTypes,:DARK))
          basedmg=(basedmg*3/5).round
          Kernel.pbMessage(_INTL("Aura abilities: {1}",basedmg.to_s)) if $game_switches[670]
        end
      elsif !@battle.pbCheckGlobalAbility(:AURABREAK) && @battle.pbWeather==PBWeather::NEWMOON
        if (@battle.pbCheckGlobalAbility(:DARKAURA) && isConst?(type,PBTypes,:DARK))
          basedmg=(basedmg*5/3).round
          Kernel.pbMessage(_INTL("Aura abilities: {1}",basedmg.to_s)) if $game_switches[670]
        end
      else
        basedmg=(basedmg*4/3).round
        Kernel.pbMessage(_INTL("Aura abilities: {1}",basedmg.to_s)) if $game_switches[670]
      end
    end
    if attacker.hasWorkingAbility(:MEGALAUNCHER)
      if @id == 93 || @id == 25 || @id == 56 || @id == 476 ||  @id == 548 || 
         @id == 714 || @id == 740
        basedmg=(basedmg*1.5).round
        Kernel.pbMessage(_INTL("Mega Launcher: {1}",basedmg.to_s)) if $game_switches[670]
      end
    end
    if attacker.hasWorkingAbility(:FLASHFIRE) &&
      attacker.effects[PBEffects::FlashFire] && isConst?(type,PBTypes,:FIRE)
      basedmg=(basedmg*1.5).round
      Kernel.pbMessage(_INTL("Flash Fire: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if (opponent.hasWorkingAbility(:DRYSKIN) && !attacker.hasMoldBreaker) && isConst?(type,PBTypes,:FIRE)
      basedmg=(basedmg*1.25).round
      Kernel.pbMessage(_INTL("Dry Skin: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.hasWorkingAbility(:ANALYTIC) &&
       (@battle.choices[opponent.index][0]!=1 || # Didn't choose a move
       opponent.hasMovedThisRound?) # Used a move already
      basedmg=(basedmg*1.3).round
      Kernel.pbMessage(_INTL("Analytic: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.hasWorkingAbility(:RIVALRY) &&
      attacker.gender!=2 && opponent.gender!=2
      if attacker.gender==opponent.gender
        basedmg=(basedmg*1.25).round
      else
        basedmg=(basedmg*0.75).round
      end
      Kernel.pbMessage(_INTL("Rivalry: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.hasWorkingAbility(:IRONFIST) &&
      (@flags&0x200)!=0 # flag j: Is punching move
      basedmg=(basedmg*1.2).round
      Kernel.pbMessage(_INTL("Iron Fist: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.hasWorkingAbility(:STRONGJAWS) && isBitingMove?
      basedmg=(basedmg*1.5).round
      Kernel.pbMessage(_INTL("Strong Jaw: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.hasWorkingAbility(:RECKLESS)
      if @function==0xFA ||  # Take Down, etc.
         @function==0xFB ||  # Double-Edge, etc.
         @function==0xFC ||  # Head Smash
         @function==0xFD ||  # Volt Tackle
         @function==0xFE ||  # Flare Blitz
         @function==0x10B || # Jump Kick, Hi Jump Kick
         @function==0x130    # Shadow End
        basedmg=(basedmg*1.2).round
        Kernel.pbMessage(_INTL("Reckless: {1}",basedmg.to_s)) if $game_switches[670]
      end
    end
    if attacker.hasWorkingAbility(:SLOWSTART) && attacker.turncount<6
      atk=(atk*0.5).round
      Kernel.pbMessage(_INTL("Slow Start: {1}",attacker.turncount)) if $game_switches[670]
    end
    if (@battle.pbWeather==PBWeather::NEWMOON || 
       @battle.pbWeather==PBWeather::RAINDANCE ||
       @battle.pbWeather==PBWeather::HEAVYRAIN)
      if attacker.hasWorkingAbility(:SUPERCELL)
        spatk=(spatk*1.5).round
      end  
    end
    if (@battle.pbWeather==PBWeather::SUNNYDAY || 
       @battle.pbWeather==PBWeather::HARSHSUN)
      if attacker.hasWorkingAbility(:SOLARPOWER)
        spatk=(spatk*1.5).round
      end
      if attacker.hasWorkingAbility(:FLOWERGIFT) ||
         attacker.pbPartner.hasWorkingAbility(:FLOWERGIFT)
        atk=(atk*1.5).round
      end
      if !attacker.hasMoldBreaker && (opponent.hasWorkingAbility(:FLOWERGIFT) ||
         opponent.pbPartner.hasWorkingAbility(:FLOWERGIFT))
        spdef=(spdef*1.5).round
      end
    end
    if @battle.pbWeather==PBWeather::NEWMOON
      if attacker.hasWorkingAbility(:ABSOLUTION)
        spatk=(spatk*1.5).round
      end
    end
    if @battle.pbWeather==PBWeather::SANDSTORM
      if attacker.hasWorkingAbility(:SANDFORCE) &&
         (isConst?(type,PBTypes,:ROCK) || isConst?(type,PBTypes,:GROUND) ||
         isConst?(type,PBTypes,:STEEL))
        basedmg=(basedmg*1.3).round
        Kernel.pbMessage(_INTL("Sand Force: {1}",basedmg.to_s)) if $game_switches[670]
      end
    end
    if attacker.hasWorkingAbility(:SHEERFORCE) && self.addlEffect>0
      basedmg=(basedmg*1.3).round
      Kernel.pbMessage(_INTL("Sheer Force: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.effects[PBEffects::BurstMode]
      atk=(atk*1.1).round
      spatk=(spatk*1.1).round
    end
    # Burns
    if attacker.status == PBStatuses::BURN &&
       !attacker.hasWorkingAbility(:GUTS)
      atk=(atk*0.5).round
    end
    if attacker.hasWorkingAbility(:TOXICBOOST) && attacker.status==PBStatuses::POISON
      atk=(atk*1.5).round
    end
    if attacker.hasWorkingAbility(:FLAREBOOST) && attacker.status==PBStatuses::BURN
      spatk=(spatk*1.5).round
    end
    if attacker.hp<=(attacker.totalhp/3).floor
      modbasedmg=(basedmg*1.5).round
      basedmg=modbasedmg if attacker.hasWorkingAbility(:OVERGROW) && isConst?(type,PBTypes,:GRASS)
      basedmg=modbasedmg if attacker.hasWorkingAbility(:SPIRITCALL) && isConst?(type,PBTypes,:GHOST)
      basedmg=modbasedmg if attacker.hasWorkingAbility(:SHADOWCALL) && isConst?(type,PBTypes,:DARK)
      basedmg=modbasedmg if attacker.hasWorkingAbility(:PSYCHOCALL) && isConst?(type,PBTypes,:PSYCHIC)
      basedmg=modbasedmg if attacker.hasWorkingAbility(:BLAZE) && isConst?(type,PBTypes,:FIRE)
      basedmg=modbasedmg if attacker.hasWorkingAbility(:TORRENT) && isConst?(type,PBTypes,:WATER)
      basedmg=modbasedmg if attacker.hasWorkingAbility(:SWARM) && isConst?(type,PBTypes,:BUG)
      Kernel.pbMessage(_INTL("Overgrow, Blaze, etc: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.hasWorkingAbility(:DEFEATIST) &&
       attacker.hp<=(attacker.totalhp/2).floor
      atk=(atk*0.5).round
      spatk=(spatk*0.5).round
    end
    if isConst?(type,PBTypes,:ELECTRIC)
      if @battle.field.effects[PBEffects::MudSportField]>0
        basedmg=(basedmg*0.33).round
        Kernel.pbMessage(_INTL("Mud Sport: {1}",basedmg.to_s)) if $game_switches[670]
      end
      #for i in 0..3
      #  if @battle.battlers[i].effects[PBEffects::MudSport]
      #    basedmg=(basedmg/2).round
      #    Kernel.pbMessage(_INTL("Mud Sport: {1}",basedmg.to_s)) if $game_switches[670]
      #    break #Not cumulative
      #  end
      #end
    end
    if isConst?(type,PBTypes,:FIRE)
      if @battle.field.effects[PBEffects::WaterSportField]>0
        basedmg=(basedmg*0.33).round
        Kernel.pbMessage(_INTL("Water Sport: {1}",basedmg.to_s)) if $game_switches[670]
      end
      #for i in 0..3
      #  if @battle.battlers[i].effects[PBEffects::WaterSport]
      #    basedmg=(basedmg/2).round
      #    
      #    break #Not cumulative
      #  end
      #end
    end
    if (opponent.hasWorkingAbility(:THICKFAT) && !attacker.hasMoldBreaker) &&
       (isConst?(type,PBTypes,:ICE) || isConst?(type,PBTypes,:FIRE))
      basedmg=(basedmg*0.5).round
      Kernel.pbMessage(_INTL("Thick Fat: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if (opponent.hasWorkingAbility(:HEATPROOF) && !attacker.hasMoldBreaker) && isConst?(type,PBTypes,:FIRE)
      basedmg=(basedmg*0.5).round
      Kernel.pbMessage(_INTL("Heatproof: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.hasWorkingAbility(:TINTEDLENS) &&
       PBTypes.isNotVeryEffective?(type,opponent.type1,opponent.type2)
      basedmg=(basedmg*2.0).round
      Kernel.pbMessage(_INTL("Tinted Lens: {1}",basedmg.to_s)) if $game_switches[670]
    end
    if attacker.hasWorkingAbility(:SPECTRALJAWS)
      if [PBMoves::BITE,PBMoves::CRUNCH,PBMoves::FIREFANG,PBMoves::ICEFANG,
        PBMoves::POISONFANG,PBMoves::THUNDERFANG,PBMoves::HYPERFANG].include?(@id)
        atk=spatk
        defense=spdef
      end
    end
    #Damage formula
    if type>=0 && pbIsSpecial?(type)
      if @id==PBMoves::INSURGENCY
        atk = spatk if spatk > atk
      else
        if atk>spatk && @function==0x217
          # Move continues to use the Attack Stat
        else
          atk=spatk
        end
        defense=spdef if @function!=0x122 #|| @battle.wonderroom<1 # Psyshock
      end
    end
    defense=1 if defense<1
    atk=1 if atk<1
    damage=(((2.0*attacker.level/5+2).floor*atk*basedmg/defense).floor/50).floor+2
    Kernel.pbMessage(_INTL("Main damage calc: {1}",damage.to_s)) if $game_switches[670]
    #Kernel.pbMessage(_INTL("Damage 5: {1}",damage.to_s))
    if pbTargetsMultiple?(attacker) || @moveInProgress
      damage=(damage*0.75).round
      Kernel.pbMessage(_INTL("Multiple target reduction: {1}",damage.to_s)) if $game_switches[670]
    end
    #if pbTargetsAll?(attacker)
    #  damage>>=1
    #end
    #Weather
    weather=@battle.pbWeather
    #if weather==PBWeather::SUNNYDAY
    #  if isConst?(type,PBTypes,:FIRE)
    #   damage=(damage*1.5).floor
    #  elsif isConst?(type,PBTypes,:WATER)
    #    damage>>=1
    #  end
    #nd
    #if weather==PBWeather::RAINDANCE
    #  if isConst?(type,PBTypes,:FIRE)
    #    damage>>=1
    #  elsif isConst?(type,PBTypes,:WATER)
    #    damage=(damage*1.5).floor
    #  end
    #end
    case weather
    when PBWeather::SUNNYDAY, PBWeather::HARSHSUN
      if isConst?(type,PBTypes,:FIRE)
        damage=(damage*1.5).round
        Kernel.pbMessage(_INTL("Boosted by sun: {1}",damage.to_s)) if $game_switches[670]
      elsif isConst?(type,PBTypes,:WATER)
        damage=(damage*0.5).round
        Kernel.pbMessage(_INTL("Reduced by sun: {1}",damage.to_s)) if $game_switches[670]
      end
    when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
      if isConst?(type,PBTypes,:FIRE)
        damage=(damage*0.5).round
        Kernel.pbMessage(_INTL("Reduced by rain: {1}",damage.to_s)) if $game_switches[670]
      elsif isConst?(type,PBTypes,:WATER)
        damage=(damage*1.5).round
        Kernel.pbMessage(_INTL("Boosted by rain: {1}",damage.to_s)) if $game_switches[670]
      end
    when PBWeather::NEWMOON
      if isConst?(type,PBTypes,:GHOST) || isConst?(type,PBTypes,:DARK)
        damage=(damage*1.35).round
        Kernel.pbMessage(_INTL("Boosted by Noctem: {1}",damage.to_s)) if $game_switches[670]
      elsif isConst?(type,PBTypes,:FAIRY)
        damage=(damage*0.75).round
        Kernel.pbMessage(_INTL("Reduced by Noctem: {1}",damage.to_s)) if $game_switches[670]
      end
      #Kernel.pbMessage(_INTL("Damage 7: {1}",damage.to_s))
    #if @battle.weather==PBWeather::NEWMOON
    #   basedmg=(basedmg*0.75) if isConst?(type,PBTypes,:FAIRY)
    #   basedmg=(basedmg*1.35) if isConst?(type,PBTypes,:DARK)
    #    basedmg=(basedmg*1.35) if isConst?(type,PBTypes,:GHOST)
    end
    #Kernel.pbMessage(_INTL("Damage 8: {1}",damage.to_s))
    if (options&IGNOREPKMNTYPES)==0
      #Same Type Attack Bonus
      if attacker.hasWorkingAbility(:ANCIENTPRESENCE)
        damage=(damage*1.5).round
        Kernel.pbMessage(_INTL("Ancient Presence: {1}",damage.to_s)) if $game_switches[670]
      elsif (attacker.pbHasType?(type) && !attacker.hasWorkingAbility(:OMNITYPE)) ||
            (attacker.hasWorkingAbility(:OMNITYPE) && (attacker.type1==type ||
            attacker.type2==type)) ||
            (attacker.hasWorkingAbility(:SHADOWSYNERGY) && 
            isConst?(type,PBTypes,:DARK)) ||
            (attacker.effects[PBEffects::ForestsCurse] && 
            isConst?(type,PBTypes,:GRASS)) ||
            (attacker.effects[PBEffects::TrickOrTreat] && isConst?(type,PBTypes,:GHOST))
        if attacker.hasWorkingAbility(:ADAPTABILITY)
          damage=(damage*2).round
          Kernel.pbMessage(_INTL("Adaptability: {1}",damage.to_s)) if $game_switches[670]
        else
          damage=(damage*1.5).round
          Kernel.pbMessage(_INTL("STAB/Shadow Synergy: {1}",damage.to_s)) if $game_switches[670]
        end
      end
      
      if opponent.effects[PBEffects::Minimize] && (tramplesMinimize?(2) || id == PBMoves::FLYINGPRESS)
        damage=(damage*2.0).round
        Kernel.pbMessage(_INTL("Minimize boost: {1}",damage.to_s)) if $game_switches[670]
      end
      if (opponent.hasWorkingAbility(:MULTISCALE) && !attacker.hasMoldBreaker) && opponent.hp==opponent.totalhp
        damage=(damage*0.5).round
        Kernel.pbMessage(_INTL("Multiscale: {1}",damage.to_s)) if $game_switches[670]
      end
      if opponent.pbPartner.hasWorkingAbility(:FRIENDGUARD) && !attacker.hasMoldBreaker
        damage=(damage*0.75).round
        Kernel.pbMessage(_INTL("Friend Guard: {1}",damage.to_s)) if $game_switches[670]
      end
      if attacker.effects[PBEffects::MetronomeCounter] != -1
        var=attacker.effects[PBEffects::MetronomeCounter]*0.2 + 1
        damage=(damage*var).round
        Kernel.pbMessage(_INTL("Metronome: {1}",damage.to_s)) if $game_switches[670]
      end
      if attacker.effects[PBEffects::PendulumCounter] != -1
        var=attacker.effects[PBEffects::PendulumCounter]*0.2 + 1
        damage=(damage*var).round
        Kernel.pbMessage(_INTL("Pendulum: {1}",damage.to_s)) if $game_switches[670]
      end
      #Type Effectiveness
      typemod=pbTypeModMessages(type,attacker,opponent)
      damage=(damage*typemod/4.0).round
      Kernel.pbMessage(_INTL("Damage after type effectiveness: {1}",damage.to_s)) if $game_switches[670]
      if opponent.hasWorkingAbility(:OMNITYPE) && (isConst?(type,PBTypes,:GRASS) ||
         isConst?(type,PBTypes,:BUG)) && !opponent.hasMoldBreaker
        damage=(damage/4.0).round
        Kernel.pbMessage(_INTL("Further reduction for Omnitype: {1}",damage.to_s)) if $game_switches[670]
      end
      opponent.damagestate.typemod=typemod
      if typemod==0
        opponent.damagestate.calcdamage=0
        return 0
      end
      #Kernel.pbMessage(_INTL("Damage 10: {1}",damage.to_s))
      if isConst?(attacker.item,PBItems,:LIFEORB)
        damage=(damage*1.3).round
        Kernel.pbMessage(_INTL("Life Orb: {1}",damage.to_s)) if $game_switches[670]
        #Kernel.pbMessage(_INTL("Damage 11: {1}",damage.to_s))
      end
      if typemod>4 # Super-effective
        if !attacker.hasMoldBreaker && (opponent.hasWorkingAbility(:SOLIDROCK) ||
           opponent.hasWorkingAbility(:FILTER))
          damage=(damage*0.75).round
          Kernel.pbMessage(_INTL("Filter/Solid Rock: {1}",damage.to_s)) if $game_switches[670]
        end
        if isConst?(attacker.item,PBItems,:EXPERTBELT)
          damage=(damage*1.2).round
          Kernel.pbMessage(_INTL("Expert Belt: {1}",damage.to_s)) if $game_switches[670]
        end
        if (isConst?(opponent.item,PBItems,:CHOPLEBERRY) && isConst?(type,PBTypes,:FIGHTING)) ||
           (isConst?(opponent.item,PBItems,:COBABERRY) && isConst?(type,PBTypes,:FLYING)) ||
           (isConst?(opponent.item,PBItems,:KEBIABERRY) && isConst?(type,PBTypes,:POISON)) ||
           (isConst?(opponent.item,PBItems,:SHUCABERRY) && isConst?(type,PBTypes,:GROUND)) ||
           (isConst?(opponent.item,PBItems,:CHARTIBERRY) && isConst?(type,PBTypes,:ROCK)) ||
           (isConst?(opponent.item,PBItems,:TANGABERRY) && isConst?(type,PBTypes,:BUG)) ||
           (isConst?(opponent.item,PBItems,:KASIBBERRY) && isConst?(type,PBTypes,:GHOST)) ||
           (isConst?(opponent.item,PBItems,:BABIRIBERRY) && isConst?(type,PBTypes,:STEEL)) ||
           (isConst?(opponent.item,PBItems,:OCCABERRY) && isConst?(type,PBTypes,:FIRE)) ||
           (isConst?(opponent.item,PBItems,:PASSHOBERRY) && isConst?(type,PBTypes,:WATER)) ||
           (isConst?(opponent.item,PBItems,:RINDOBERRY) && isConst?(type,PBTypes,:GRASS)) ||
           (isConst?(opponent.item,PBItems,:WACANBERRY) && isConst?(type,PBTypes,:ELECTRIC)) ||
           (isConst?(opponent.item,PBItems,:PAYAPABERRY) && isConst?(type,PBTypes,:PSYCHIC)) ||
           (isConst?(opponent.item,PBItems,:YACHEBERRY) && isConst?(type,PBTypes,:ICE)) ||
           (isConst?(opponent.item,PBItems,:HABANBERRY) && isConst?(type,PBTypes,:DRAGON)) ||
           (isConst?(opponent.item,PBItems,:COLBURBERRY) && isConst?(type,PBTypes,:DARK)) ||
           (isConst?(opponent.item,PBItems,:ROSELIBERRY) && isConst?(type,PBTypes,:FAIRY))
          berryName=PBItems.getName(opponent.item)
          @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",berryName,opponent.pbThis))
          damage=(damage/2).round
          opponent.damagestate.berryweakened=true
          Kernel.pbMessage(_INTL("Reduced by berries: {1}",damage.to_s)) if $game_switches[670]
          #opponent.pbConsumeItem if !hypothetical
        end
      end
      if (isConst?(opponent.item,PBItems,:CHILANBERRY) && isConst?(type,PBTypes,:NORMAL))
        damage=(damage/2).round
        Kernel.pbMessage(_INTL("Reduced by berries: {1}",damage.to_s)) if $game_switches[670]
        berryName=PBItems.getName(opponent.item)
        @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",berryName,opponent.pbThis))
        opponent.damagestate.berryweakened=true
        #opponent.pbConsumeItem  if !hypothetical
      end
    else
      opponent.damagestate.typemod=4
    end

    damage=pbModifyDamage(damage,attacker,opponent)
    Kernel.pbMessage(_INTL("Damage modifications: {1}",damage.to_s)) if $game_switches[670]
    #Kernel.pbMessage(_INTL("Damage 12: {1}",damage.to_s))

    # Charge
    if attacker.effects[PBEffects::Charge]>0 && isConst?(type,PBTypes,:ELECTRIC)
      damage=(damage*2.0).round
      Kernel.pbMessage(_INTL("Charge: {1}",damage.to_s)) if $game_switches[670]
    end
    if !opponent.damagestate.critical && (options&NOREFLECT)==0 &&
       !attacker.hasWorkingAbility(:INFILTRATOR)
      #Reflect
      oppside=opponent.pbOwnSide
      if oppside.effects[PBEffects::Reflect] > 0 && pbIsPhysical?(type)
# if opponent has a partner [TODO: should apply even if partner faints during an attack]
        if opponent.pbPartner.hp>0
          damage=(damage*2.0/3.0).round
        else
          damage=(damage*0.5).round
        end
        if @battle.weather==PBWeather::NEWMOON
          damage=(damage*4.0/5.0).round
        end
        Kernel.pbMessage(_INTL("Reflect: {1}",damage.to_s)) if $game_switches[670]
      end
      #Light Screen
      if oppside.effects[PBEffects::LightScreen] > 0 && pbIsSpecial?(type)
# if opponent has a partner [TODO: should apply even if partner faints during an attack]
        if opponent.pbPartner.hp>0
          damage=(damage*2.0/3.0).round
        else
          damage=(damage*0.5).round
        end
        if @battle.weather==PBWeather::NEWMOON
          damage=(damage*4.0/5.0).round
        end
        Kernel.pbMessage(_INTL("Light Screen: {1}",damage.to_s)) if $game_switches[670]
      end
    end
    # Damage for each hit of Lernean. The values should decrease with each new hit
    if attacker.effects[PBEffects::LerneanCounter]>0
      headnum=attacker.effects[PBEffects::LerneanHeads]
      currentheadnum=attacker.effects[PBEffects::LerneanCounter]
      
      # 5 is the starting head number
      damagegoal=(1.15+0.0750*(headnum-5))*damage
      hitdamage=((damagegoal-damage)/(headnum*(2+0.5*(headnum-5)))*(currentheadnum-1)+damage/headnum)
      damage=hitdamage.round
      Kernel.pbMessage(_INTL("Lernean mod: {1}",damage.to_s)) if $game_switches[670]
    end
    if attacker.effects[PBEffects::ParentalBond]==1
      damage=(damage*0.5).round
      Kernel.pbMessage(_INTL("Parental Bond mod: {1}",damage.to_s)) if $game_switches[670]
    end
    if @id==PBMoves::AURABLAST
      if attacker.effects[PBEffects::AuraBlastCharges]==0
        @battle.pbDisplay("Give it all you've got!")
        damage=(damage*2).round
        Kernel.pbMessage(_INTL("Aura Blast mod: {1}",damage.to_s)) if $game_switches[670]
      end
    end
    #Damage weighting
    if (options&NOWEIGHTING)==0
      random=85+@battle.pbRandom(16)
      damage=(damage*random/100.0).floor
      Kernel.pbMessage(_INTL("Random variance: {1}",damage.to_s)) if $game_switches[670]
    end
    if opponent.damagestate.critical
      if attacker.hasWorkingAbility(:SNIPER)# && opponent.damagestate.critical
        damage=(damage*2.25).round
        Kernel.pbMessage(_INTL("Sniper: {1}",damage.to_s)) if $game_switches[670]
      else
        damage=(damage*1.5).round
        Kernel.pbMessage(_INTL("Crit: {1}",damage.to_s)) if $game_switches[670]
      end
    end
    damage=1 if damage<1
    ##########
    if false
      if attacker.index==0
        return opponent.hp
      end
      if opponent.index==0
        return 0
      end
    end
    ##########

    opponent.damagestate.calcdamage=damage
    return damage
  end

  def pbModifyDamage(damage,attacker,opponent)
    return damage
  end

  def pbReduceHPDamage(damage,attacker,opponent)
    endure=false
    Kernel.pbPushRecent("32.1")
    tempIsOutrage=opponent.effects[PBEffects::Outrage]
    if !ignoresSubstitute?(attacker) && opponent.effects[PBEffects::Substitute]>0 && (!attacker || attacker.index!=opponent.index)
      damage=opponent.effects[PBEffects::Substitute] if damage>opponent.effects[PBEffects::Substitute]
      opponent.effects[PBEffects::Substitute]-=damage
      opponent.damagestate.substitute=true
      attacker.effects[PBEffects::HitSubstitute]=true
      @battle.scene.pbDamageAnimation(opponent,0)
      @battle.pbDisplayPaused(_INTL("The substitute took damage for {1}!",opponent.name)) if opponent.effects[PBEffects::MeloettaForme] == nil || !isConst?(opponent.species,PBSpecies,:MELOETTA)
      if opponent.effects[113] != nil && opponent.effects[113] != 0# && (opponent.effects[13].name != nil)
        @battle.pbDisplayPaused(_INTL("{2} took damage for {1}!",opponent.name,opponent.effects[PBEffects::MeloettaForme].name))
      end
      Kernel.pbPushRecent("32.2")
      if opponent.effects[PBEffects::Substitute]<=0
        opponent.effects[PBEffects::Substitute]=0
        @battle.pbDisplayPaused(_INTL("{1}'s substitute faded!",opponent.name)) if opponent.effects[PBEffects::MeloettaForme] == nil || opponent.effects[PBEffects::MeloettaForme] == 0
        newBattler=opponent.pokemon
        if opponent.effects[PBEffects::Illusion]
          newBattler=opponent.effects[PBEffects::Illusion]
        end
        @battle.scene.pbChangePokemon(opponent,newBattler,false)
        #@battle.scene.pbChangePokemon(opponent,opponent.pokemon,false)
      end
      opponent.damagestate.hplost=damage
      damage=0
    else
      opponent.damagestate.substitute=false
      Kernel.pbPushRecent("32.3")
      if damage>=opponent.hp
        damage=opponent.hp
        if opponent.effects[PBEffects::Endure]
          damage=damage-1
          opponent.damagestate.endured=true
        elsif opponent.hasWorkingAbility(:STURDY) && damage==opponent.totalhp && !attacker.hasMoldBreaker
          opponent.damagestate.sturdy=true
          damage=damage-1
        elsif opponent.hasWorkingItem(:FOCUSSASH) && opponent.hp==opponent.totalhp
          opponent.damagestate.focussash=true
          damage=damage-1
        elsif opponent.hasWorkingItem(:FOCUSBAND) && @battle.pbRandom(10)==0
          opponent.damagestate.focusband=true
          damage=damage-1
        elsif @function==0xE9# || @function==0x150# False Swipe
          damage=damage-1
        end
        damage=0 if damage<0
      end
      Kernel.pbPushRecent("32.4")

      oldhp=opponent.hp
      opponent.hp-=damage
      opponent.hp=0 if opponent.hp == 0.5
      effectiveness=0
      if opponent.damagestate.typemod<4
        effectiveness=1   # "Not very effective"
      elsif opponent.damagestate.typemod>8
        effectiveness=3
      elsif opponent.damagestate.typemod>4
        effectiveness=2   # "Super effective"
      end
      Kernel.pbPushRecent("32.5")

      if opponent.damagestate.typemod!=0
        @battle.scene.pbDamageAnimation(opponent,effectiveness,opponent.damagestate.critical)
      end
      Kernel.pbPushRecent("32.6")

      @battle.scene.pbHPChanged(opponent,oldhp)
      Kernel.pbPushRecent("32.7")

      opponent.damagestate.hplost=damage
      Kernel.pbPushRecent("32.8")

    end
    if isConst?(attacker.item,PBItems,:LIFEORB) && !attacker.hasWorkingAbility(:MAGICGUARD) && attacker.effects[PBEffects::TwoTurnAttack]==0 #&& @function!=0xEE    
      if checkTarget(@target) #&& damage>0
        @numPokemonHit+=1
      end
    end
    #opponent.effects[PBEffects::Outrage]=tempIsOutrage
    return damage
  end



################################################################################
# Effects
################################################################################
  def pbEffectMessages(opponent,attacker=nil)
    return if pbIsMultiHit #|| attacker.effects[PBEffects::ParentalBond]>0
    if opponent.damagestate.critical
      @battle.pbDisplay(_INTL("A critical hit!"))
      #  if opponent.hasWorkingAbility(:ANGERPOINT) &&
      #     !opponent.pbTooHigh?(PBStats::ATTACK)
      #    opponent.stages[PBStats::ATTACK]=6
      #    @battle.pbDisplay(_INTL("{1}'s Anger Point maxed its Attack!",opponent.name))
      #  end
    end
    if attacker.effects[PBEffects::LerneanCounter]<=1 && attacker.effects[PBEffects::ParentalBond]==0
      if opponent.damagestate.typemod>=1 && opponent.damagestate.typemod<4
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
      if opponent.damagestate.typemod>4
        @battle.pbDisplay(_INTL("It's super effective!"))
      end
    end
    if opponent.damagestate.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!",opponent.name))
    elsif opponent.damagestate.sturdy
      @battle.pbDisplay(_INTL("{1} hung on with Sturdy!",opponent.name))
    elsif opponent.damagestate.focussash
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",opponent.name))
      opponent.pbConsumeItem
    elsif opponent.damagestate.focusband
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",opponent.name))
    end
    #if isConst?(opponent.item,PBItems,:AIRBALLOON)
    # opponent.pokemon.itemRecycle=opponent.item
    #  opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
    #  opponent.item=0
    #  @battle.pbDisplay(_INTL("{1}'s Air Balloon burst!",opponent.pbThis));
    #end
    #if isConst?(opponent.item,PBItems,:WEAKNESSPOLICY) && opponent.hp > 0 && opponent.damagestate.typemod>4
    #  opponent.pokemon.itemRecycle=opponent.item
    #  opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
    #  opponent.item=0
    #  @battle.pbDisplay(_INTL("{1}'s Weakness Policy was activated!",opponent.pbThis));
#   #   @battle.pbAnimation(@id,opponent,nil)
    #  opponent.pbIncreaseStatBasic(PBStats::ATTACK,2)
    #  @battle.pbCommonAnimation("StatUp",opponent,nil)
    #  @battle.pbDisplay(_INTL("{1}'s Attack rose sharply!",opponent.pbThis))
    # # @battle.pbAnimation(@id,opponent,nil)
    #  opponent.pbIncreaseStatBasic(PBStats::SPATK,2)
    #  @battle.pbCommonAnimation("StatUp",opponent,nil)
    #  @battle.pbDisplay(_INTL("{1}'s Special Attack rose sharply!",opponent.pbThis))
    #end
    #if opponent.hasWorkingItem(:ENIGMABERRY) && opponent.damagestate.typemod>4
    #  opponent.pbActivateBerryEffect
    #end
  end

  def pbEffectFixedDamage(damage,attacker,opponent)
    type=pbType(@type,attacker,opponent)
    typemod=pbTypeModMessages(type,attacker,opponent)
    opponent.damagestate.critical=false
    opponent.damagestate.typemod=0
    opponent.damagestate.calcdamage=0
    opponent.damagestate.hplost=0
    if typemod!=0
      opponent.damagestate.calcdamage=damage
      opponent.damagestate.typemod=4
      @battle.pbAnimation(@id,attacker,opponent)
      damage=1 if damage<1 # HP reduced can't be less than 1
      damage=pbReduceHPDamage(damage,attacker,opponent)
      pbEffectMessages(opponent,attacker)
      pbOnDamageLost(damage,attacker,opponent)
      return damage
    end
    return 0
  end

  def pbEffect(attacker,opponent)
    return 0 if !opponent
    #kang = false
    #kang = true if $tempkang != nil && $tempkang

    #lernean=0
    #lernean=$templernean if $templernean != nil && $templernean!=0
    damage=pbCalcDamage(attacker,opponent,0,false)
    skipForFutureSight=false
    for i in 0..3
      if attacker.pokemonIndex==@battle.battlers[i].effects[PBEffects::FutureSightUser]
        if @battle.battlers[i].effects[PBEffects::FutureSight]==0
          skipForFutureSight=true
          break
        end
      end
    end
    if !attacker.hasWorkingAbility(:LERNEAN) ||
      attacker.effects[PBEffects::LerneanCounter]==attacker.effects[PBEffects::LerneanHeads]
      if opponent.damagestate.typemod!=0
        @battle.pbAnimation(@id,attacker,opponent) if !skipForFutureSight
      end
    end
    damage=pbReduceHPDamage(damage,attacker,opponent)
    pbEffectMessages(opponent,attacker)
    #multihit=true if $ismultihit==true
    pbOnDamageLost(damage,attacker,opponent)
    #$ismultihit=nil
    #if opponent.hasWorkingAbility(:WEAKARMOR) && pbIsPhysical?(type) && opponent.hp>0
    #  if !opponent.pbTooLow?(PBStats::DEFENSE)
    #    @battle.pbAnimation(@id,opponent,nil)
    #    opponent.pbReduceStatBasic(PBStats::DEFENSE,1)
    #    @battle.pbCommonAnimation("StatDown",opponent,nil)
    #    @battle.pbDisplay(_INTL("{1}'s {2} lowered its Defense!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
    #  end
    #  if !opponent.pbTooHigh?(PBStats::SPEED)
    #    @battle.pbAnimation(@id,opponent,nil)
    #    opponent.pbIncreaseStatBasic(PBStats::SPEED,1)
    #    @battle.pbCommonAnimation("StatUp",opponent,nil)
    #    @battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
    #  end
    #end    
    return damage   # The HP lost by the opponent due to this attack
  end
  
  def pbEffectAfterHit(attacker,opponent,turneffects)
  end


################################################################################
# Using the move
################################################################################
  def pbOnStartUse(attacker)
    return true
  end

  def pbAddTarget(targets,attacker)
  end

  def pbSuccessCheck(attacker,opponent,numtargets)
  end

  def pbDisplayUseMessage(attacker)
  # Return values:
  # -1 if the attack should exit as a failure
  # 1 if the attack should exit as a success
  # 0 if the attack should proceed its effect
    Kernel.pbPushRecent("1")
    if name != nil && name == "Custom Move"
      @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,$game_variables[100]),false) if $is_insane
      @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,$game_variables[100]),false) if !$is_insane
    else
      @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,name),false) if $is_insane != nil && $is_insane!=false
      @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,name)) if $is_insane==nil || $is_insane==false
    end
    Kernel.pbPushRecent("2")
    return 0
  end
  
  def pbShowAnimation(id,attacker,opponent,showanimation=true)
    return if !showanimation
    if attacker.effects[PBEffects::ParentalBond]==1
      @battle.pbCommonAnimation("ParentalBond",attacker,opponent)
      return
    end
    if attacker.effects[PBEffects::LerneanCounter]==0
      @battle.pbCommonAnimation("ParentalBond",attacker,opponent)
      return
    end
    @battle.pbAnimation(id,attacker,opponent)
  end

  def pbOnDamageLost(damage,attacker,opponent)
    #Used by Counter/Mirror Coat/Revenge/Focus Punch/Bide
    type=@type
    type=pbType(type,attacker,opponent)
    if opponent.effects[PBEffects::Bide]
      opponent.effects[PBEffects::BideDamage]+=damage
      opponent.effects[PBEffects::BideTarget]=attacker.index
    end
    if @function==90 # Hidden Power
      type=getConst(PBTypes,:NORMAL) || 0
    end
    if pbIsPhysical?(type)
      opponent.effects[PBEffects::Counter]=damage
      opponent.effects[PBEffects::CounterTarget]=attacker.index
    end
    if pbIsSpecial?(type)
      opponent.effects[PBEffects::MirrorCoat]=damage
      opponent.effects[PBEffects::MirrorCoatTarget]=attacker.index
    end
#
#      def pbEffect(attacker,opponent)
#    ret=super(attacker,opponent)
#    if opponent.damagestate.calcdamage>0
#      attacker.pbReduceHP((attacker.totalhp/4).floor)
#      @battle.pbDisplay(_INTL("{1} is hit with recoil!",attacker.pbThis))
#    end
#    return ret
#  end

    #if isConst?(attacker.item,PBItems,:LIFEORB) && !attacker.hasWorkingAbility(:MAGICGUARD) && attacker.effects[PBEffects::TwoTurnAttack]==0 #&& @function!=0xEE    
    #  if checkTarget(@target) && damage>0
    #    @numPokemonHit+=1
          
        #attacker.pbReduceHP((attacker.totalhp/10).floor) && !isConst?(attacker.ability,PBAbilities,:SHEERFORCE) && !isConst?(@ability,PBAbilities,:MAGICGUARD)
        #@battle.pbDisplay(_INTL("{1} is damaged by its Life Orb!",attacker.pbThis)) && !isConst?(attacker.ability,PBAbilities,:SHEERFORCE) && !isConst?(@ability,PBAbilities,:MAGICGUARD)
    #  else  
    #    $templifeorb=true
    #  end
    #end
    opponent.lastHPLost=damage # for Revenge/Focus Punch
    opponent.lastAttacker.push(attacker.index) # for Revenge
    if !opponent.effects[PBEffects::BurstMode]
      opponent.effects[PBEffects::SynergyBurstDamage]+=(damage.to_f/opponent.totalhp.to_f)
    end
    @battle.scene.pbRefresh
  end
  
  def checkTarget(target)
    return true if target==PBTargets::SingleNonUser
    return true if target==PBTargets::NoTarget
    return true if target==PBTargets::RandomOpposing
    return true if target==PBTargets::User
    return true if target==PBTargets::SingleOpposing
    return true if target==PBTargets::OppositeOpposing
    return true if target==PBTargets::Partner
    return true if target==PBTargets::UserOrPartner
    return true if target==PBTargets::AllOpposing
    return true if target==PBTargets::AllNonUsers
 #   targetArray=[]
 #   has3=false
 #   has2=false
 #   has1=false
 #   has0=false
 #   has3 = true if @battle.battlers[3] != nil && @battle.battlers[3]
 #   has2 = true if @battle.battlers[2] != nil && @battle.battlers[2]
 #   has1 = true if @battle.battlers[1] != nil && @battle.battlers[1]
 #   has0 = true if @battle.battlers[0] != nil && @battle.battlers[0]
    return false
  end
  
  #def hasMultipleTargets?(target)
  #  return true if target==PBTargets::AllOpposing
  #  return true if target==PBTargets::AllNonUsers
  #end
  
  def pbMoveFailed(attacker,opponent)
    # Called to determine whether the move failed
    return false
  end
end