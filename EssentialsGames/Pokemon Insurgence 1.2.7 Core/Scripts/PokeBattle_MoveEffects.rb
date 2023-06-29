################################################################################
# Superclass that handles moves using a non-existent function code.
# Damaging moves just do damage with no additional effect.
# Non-damaging moves always fail.
################################################################################
class PokeBattle_UnimplementedMove < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @basedamage>0
      return super(attacker,opponent)
    else
      @battle.pbDisplay("But it failed!")
      return -1
    end
  end
end



################################################################################
# Superclass for a failed move.  Always fails.
################################################################################
class PokeBattle_FailedMove < PokeBattle_Move
  def pbEffect(attacker,opponent)
    @battle.pbDisplay("But it failed!")
    return -1
  end
end



################################################################################
# Pseudomove for confusion damage
################################################################################
class PokeBattle_Confusion < PokeBattle_Move
  def initialize(battle,move)
    @battle=battle
    @basedamage=40
    @type=-1
    @accuracy=100
    @pp=-1
    @addlEffect=0
    @target=0
    @priority=0
    @flags=0
    @thismove=move
    @name=""
    @id=0
  end

  def pbIsPhysical?(type)
    return true
  end

  def pbIsSpecial?(type)
    return false
  end
def pbIsConfusion?
    return true
  end
  def pbCalcDamage(attacker,opponent,options=0,kang=false)
#        Kernel.pbMessage("Endh")

    return super(attacker,opponent,
    PokeBattle_Move::NOCRITICAL|PokeBattle_Move::NOREFLECT|PokeBattle_Move::NOTYPE|PokeBattle_Move::NOWEIGHTING)
  end
end



################################################################################
# Implements the move Struggle.
# For cases where the real move named Struggle is not defined.
################################################################################
class PokeBattle_Struggle < PokeBattle_Move
  def initialize(battle,move)
    @id=-1        # doesn't work if 0
    @function=0
    @battle=battle
    @name=_INTL("Struggle")#""
    @basedamage=50
    @type=-1
    @accuracy=0
    @addlEffect=0
    @target=0
    @priority=0
    movedata = nil
    @flags=0
    #if $PokemonTemp
    #  movedata = $PokemonTemp.pbOpenMoveData
    #else
      #movedata = pbRgssOpen("Data/moves.dat")
    #end
    movedata=pbRgssOpen("Data/moves.dat")
    
    movedata.pos=move.id*14
    @function=movedata.fgetw
    @basedamage=movedata.fgetb
    @type=movedata.fgetb
    @category=movedata.fgetb
    @accuracy=movedata.fgetb
    @totalpp=movedata.fgetb
    @addlEffect=movedata.fgetb
    @target=movedata.fgetw
    @priority=movedata.fgetsb
    @flags=movedata.fgetw
    @contestType=movedata.fgetb
    movedata.close
    
    #@flags=movedata.fgetw
    #@flags&0x01=true    # Contact
    #@flags&0x02=true    # Protect/Detect
    #@flags&0x20=true    # King's Rock
    @thismove=nil # not associated with a move
    @pp=-1
    @totalpp=0
    if move
      @id = move.id
      @name = PBMoves.getName(id)
    end
    #movedata.close
  end

  def pbIsPhysical?(type)
    return true
  end

  def pbIsSpecial?(type)
    return false
  end

  def pbDisplayUseMessage(attacker)
    @battle.pbDisplayBrief(_INTL("{1} is struggling!",attacker.pbThis))
    return 0
  end

  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      attacker.pbReduceHP((attacker.totalhp/4).floor)
      @battle.pbDisplay(_INTL("{1} is hit with recoil!",attacker.pbThis))
    end
    return ret
  end

  def pbCalcDamage(attacker,opponent,options=0,kang=false)
#        Kernel.pbMessage("Enddork")
    return super(attacker,opponent,PokeBattle_Move::IGNOREPKMNTYPES)
  end
end



################################################################################
# No additional effect.
################################################################################
class PokeBattle_Move_000 < PokeBattle_Move
  def unusableInGravity?
    return true if @id==PBMoves::FLYINGPRESS
    return false
  end
end



################################################################################
# Does absolutely nothing (Splash).
################################################################################
class PokeBattle_Move_001 < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbEffect(attacker,opponent)
    @battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("But nothing happened!"))
    return 0
  end
end



################################################################################
# Struggle.  Overrides the default Struggle effect above.
################################################################################
class PokeBattle_Move_002 < PokeBattle_Struggle
end



################################################################################
# Puts the target to sleep.
################################################################################
class PokeBattle_Move_003 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if opponent.pbCanSleep?(attacker,true,self,false)
      @battle.pbAnimation(@id,attacker,opponent)
      opponent.pbSleep
      @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanSleep?(attacker,false,self,false)
      opponent.pbSleep
      @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Makes the target drowsy.  It will fall asleep at the end of the next turn.
################################################################################
class PokeBattle_Move_004 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return -1 if !opponent.pbCanSleep?(attacker,true,self,false)
    if opponent.effects[PBEffects::Yawn]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.effects[PBEffects::Yawn]=2
    @battle.pbDisplay(_INTL("{1} made {2} drowsy!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Poisons the target.
################################################################################
class PokeBattle_Move_005 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return 0 if !opponent.pbCanPoison?(attacker,true,self)
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} is poisoned!",opponent.pbThis))
    return 0
  end
  

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(attacker,false,self)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Badly poisons the target.
################################################################################
class PokeBattle_Move_006 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return 0 if !opponent.pbCanPoison?(attacker,true,self)
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.pbPoison(attacker,true)
    @battle.pbDisplay(_INTL("{1} is badly poisoned!",opponent.pbThis))
    return 0
  end
def pbAccuracyCheck(attacker,opponent)
    return true if @id==PBMoves::TOXIC && attacker.pbHasType?(PBTypes::POISON)
    return super(attacker,opponent)
  end
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(attacker,false,self)
    opponent.pbPoison(attacker,true)
    @battle.pbDisplay(_INTL("{1} was badly poisoned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Paralyzes the target.
################################################################################
class PokeBattle_Move_007 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    typemod=pbTypeModifier(@type,attacker,opponent)
    if isConst?(@type,PBTypes,:ELECTRIC) && opponent.hasWorkingAbility(:VOLTABSORB)
            hpgain=(opponent.hp/4).floor
      hpgain=0 if opponent.effects[PBEffects::HealBlock]>0
      hpgain=opponent.pbRecoverHP(hpgain)
      abilityname=PBAbilities.getName(opponent.ability)
      if hpgain==0
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} useless!",opponent.pbThis,abilityname,@name))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",opponent.pbThis,abilityname))
      end
      opponent.effects[PBEffects::TypeIdentified]=true
      return -1
    end
    if opponent.hasWorkingAbility(:MOTORDRIVE) && isConst?(type,PBTypes,:ELECTRIC)
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
      return -1
    end
    if isConst?(@type,PBTypes,:ELECTRIC) && (typemod==0 || (isConst?(@type,PBTypes,:ELECTRIC) && isConst?(attacker.type,PBTypes,:ELECTRIC)))
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      opponent.effects[PBEffects::TypeIdentified]=true
      return -1
    end
    return -1 if !opponent.pbCanParalyze?(attacker,true,self)
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(attacker,false,self)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# Paralyzes the target.  Hits some semi-invulnerable targets.  (Thunder)
# Always hits in rain.
# (Handled in pbCheck): Accuracy 50% in sunshine.
################################################################################
class PokeBattle_Move_008 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true if (@battle.pbWeather==PBWeather::RAINDANCE || @battle.pbWeather==PBWeather::HEAVYRAIN)
    super(attacker,opponent)
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(attacker,false,self)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# Paralyzes the target.  May cause the target to flinch.
################################################################################
class PokeBattle_Move_009 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    #hadeffect=0
    #if @battle.pbRandom(10)==0
    #  break if !opponent.pbCanParalyze?(attacker,false)
    #  opponent.pbParalyze(attacker)
    #  @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    #  hadeffect+=1
    #end
    #if @battle.pbRandom(10)==0
    # if !isConst?(opponent.ability,PBAbilities,:INNERFOCUS) &&
    #     opponent.effects[PBEffects::Substitute]==0
    #    opponent.effects[PBEffects::Flinch]=true
    #    hadeffect+=1
    #  end
    #end
    #return true if hadeffect>0
    #return false
  #end
  
  return if opponent.damagestate.substitute
    if @battle.pbRandom(10)==0
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
        @battle.pbDisplay(_INTL("{1} was paralyzed! It may be unable to move!",opponent.pbThis))
      end
    end
    if @battle.pbRandom(10)==0
      opponent.pbFlinch(attacker)
    end
  end
end



################################################################################
# Burns the target.
################################################################################
class PokeBattle_Move_00A < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanBurnFromFireMove?(attacker,self,true)
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(attacker,false,self)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Burns the target.  May cause the target to flinch.
################################################################################
class PokeBattle_Move_00B < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
  #  hadeffect=0
  #  if @battle.pbRandom(10)==0
  #    break if !opponent.pbCanBurn?(attacker,false)
  #    opponent.pbBurn(attacker)
  #    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
  #    hadeffect+=1
  #  end
  #  if @battle.pbRandom(10)==0
  #    if !isConst?(opponent.ability,PBAbilities,:INNERFOCUS) &&
  #       opponent.effects[PBEffects::Substitute]==0
  #      opponent.effects[PBEffects::Flinch]=true
  #      hadeffect+=1
  #   end
  #  end
  #  return true if hadeffect>0
  #  return false
    return if opponent.damagestate.substitute
    if @battle.pbRandom(10)==0
      if opponent.pbCanBurn?(attacker,false,self)
        opponent.pbBurn(attacker)
        @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
      end
    end
    if @battle.pbRandom(10)==0
      opponent.pbFlinch(attacker)
    end
  end
end



################################################################################
# Freezes the target.
################################################################################
class PokeBattle_Move_00C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanFreeze?(attacker,true,self)
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.pbFreeze
    @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanFreeze?(attacker,false,self)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Freezes the target.  Always hits in hail.
################################################################################
class PokeBattle_Move_00D < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true if @battle.pbWeather==PBWeather::HAIL
    super(attacker,opponent)
  end

  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanFreeze?(attacker,true,self)
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.pbFreeze
    @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanFreeze?(attacker,false,self)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Freezes the target.  May cause the target to flinch.
################################################################################
class PokeBattle_Move_00E < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    #hadeffect=0
    #if @battle.pbRandom(10)==0
    #  break if !opponent.pbCanFreeze?(attacker,false)
    #  opponent.pbFreeze
    #  @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
    #  hadeffect+=1
    #end
    #if @battle.pbRandom(10)==0
    #  if !isConst?(opponent.ability,PBAbilities,:INNERFOCUS) &&
    #     opponent.effects[PBEffects::Substitute]==0
    #   opponent.effects[PBEffects::Flinch]=true
    #    hadeffect+=1
    #  end
    #end
    #return true if hadeffect>0
    #eturn false
    
    return if opponent.damagestate.substitute
    if @battle.pbRandom(10)==0
      if opponent.pbCanFreeze?(attacker,false,self)
        opponent.pbFreeze
        @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      end
    end
    if @battle.pbRandom(10)==0
      opponent.pbFlinch(attacker)
    end
  end
end



################################################################################
# Causes the target to flinch.
################################################################################
class PokeBattle_Move_00F < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
end



################################################################################
# Causes the target to flinch.  Does double damage if the target is Minimized.
################################################################################
class PokeBattle_Move_010 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end

  def tramplesMinimize?(param=1)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end



################################################################################
# Causes the target to flinch.  Fails if the user is not asleep.
################################################################################
class PokeBattle_Move_011 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (attacker.status!=PBStatuses::SLEEP)
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
end



################################################################################
# Causes the target to flinch.  Fails if this isn't the user's first turn.
################################################################################
class PokeBattle_Move_012 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (attacker.turncount>1)
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbFlinch(attacker)
      @battle.successStates[opponent.index].protected=true
    end
  end
  
  #def pbEffect(attacker,opponent)
  # ret=super(attacker,opponent)
  #  if opponent.damagestate.calcdamage>0 &&
  #     !opponent.damagestate.substitute && opponent.hp>0
  #    if isConst?(opponent.ability,PBAbilities,:INNERFOCUS)
  #      @battle.pbDisplay(_INTL("{1}'s {2} prevents flinching!",
  #         opponent.pbThis,PBAbilities.getName(opponent.ability)))
  #     return ret
  #    elsif !isConst?(opponent.ability,PBAbilities,:SHIELDDUST)
  #      opponent.effects[PBEffects::Flinch]=true
  #   end
  #  end
  #  return ret
  #end

  #def pbMoveFailed(attacker,opponent)
  #  return (attacker.turncount!=1)
  #end
end



################################################################################
# Confuses the target.
################################################################################
class PokeBattle_Move_013 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if opponent.pbCanConfuse?(attacker,true,self)
      @battle.pbAnimation(@id,attacker,opponent)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",attacker,opponent) if !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanConfuse?(attacker,false,self)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",attacker,opponent) if !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Confuses the target.  Chance of causing confusion depends on the cry's volume.
# Works for Chatot only.  (Chatter)
################################################################################
class PokeBattle_Move_014 < PokeBattle_Move
  def pbEffect(attacker, opponent)
    if opponent.hasWorkingAbility(:SOUNDPROOF)
      @battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",opponent.pbThis,
         PBAbilities.getName(opponent.ability),name))
      return -1
    end
    @battle.scene.pbChatter(attacker, opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && opponent.hp>0 && attacker.pokemon &&
       isConst?(attacker.species,PBSpecies,:CHATOT) &&
       !attacker.effects[PBEffects::Transform] &&
       !opponent.hasWorkingAbility(:SHIELDDUST)
      chance=1
      if attacker.pokemon.chatter
        chance=attacker.pokemon.chatter.intensity*30/127
        chance+=1
      end
      if opponent.canConfuse?(false)
        @battle.pbAnimation(@id,attacker,opponent)
        opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
        @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# Confuses the target.  Hits some semi-invulnerable targets.  (Hurricane)
# Always hits in rain.
# (Handled in pbAccuracyCheck): Accuracy 50% in sunshine.
################################################################################
class PokeBattle_Move_015 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true if (@battle.pbWeather==PBWeather::RAINDANCE || @battle.pbWeather==PBWeather::HEAVYRAIN)
    super(attacker,opponent)
  end

  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if opponent.pbCanConfuse?(attacker,true,self)
      @battle.pbAnimation(@id,attacker,opponent)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",attacker,opponent) if !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanConfuse?(attacker,false,self)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",attacker,opponent) if !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Attracts the target.
################################################################################
class PokeBattle_Move_016 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.hasWorkingAbility(:OBLIVIOUS) && !attacker.hasMoldBreaker
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      return -1
    end
    if opponent.effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker
      if opponent.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    agender=attacker.gender
    ogender=opponent.gender
    if agender==2 || ogender==2 || agender==ogender
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Attract]=attacker.index
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} fell in love!",opponent.pbThis))
    if isConst?(opponent.item,PBItems,:DESTINYKNOT) &&
       !attacker.hasWorkingAbility(:OBLIVIOUS) &&
       attacker.effects[PBEffects::Attract]<0
      attacker.effects[PBEffects::Attract]=user.index
      pbDisplay(_INTL("{1}'s {2} infatuated {3}!",opponent.pbThis,
         PBItems.getName(opponent.item),attacker.pbThis(true)))
    end
    return 0
  end
end



################################################################################
# Burns, freezes or paralyzes the target.
################################################################################
class PokeBattle_Move_017 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    rnd=@battle.pbRandom(3)
    case rnd
      when 0
        return false if !opponent.pbCanBurn?(attacker,false,self)
        opponent.pbBurn(attacker)
        @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
      when 1
        return false if !opponent.pbCanFreeze?(attacker,false,self)
        opponent.pbFreeze
        @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      when 2
        return false if !opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
        @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
    end
    return true
  end
end



################################################################################
# Cures user of burn, poison and paralysis.
################################################################################
class PokeBattle_Move_018 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.status!=PBStatuses::BURN &&
       attacker.status!=PBStatuses::POISON &&
       attacker.status!=PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("But it failed!"))
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.status=0
      attacker.statusCount=0
      @battle.pbDisplay(_INTL("{1}'s status returned to normal!",attacker.pbThis))  
    end
  end
end



################################################################################
# Cures all party Pokémon of permanent status problems.
################################################################################
class PokeBattle_Move_019 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    @battle.pbAnimation(@id,attacker,nil)
    if isConst?(@id,PBMoves,:AROMATHERAPY)
      @battle.pbDisplay(_INTL("A soothing aroma wafted through the area!"))
    else
      @battle.pbDisplay(_INTL("A bell chimed!"))
    end
    activepkmn=[]
    for i in @battle.battlers
      next if attacker.pbIsOpposing?(i.index)
      if i.index!=attacker.index && i.hasWorkingAbility(:SAPSIPPER)
        if i.pbTooHigh?(PBStats::ATTACK)
          @battle.pbDisplay(_INTL("{1}'s {2} made Aromatherapy ineffective!",
              i.pbThis,PBAbilities.getName(i.ability)))
          i.effects[PBEffects::TypeIdentified]=true
        else
          @battle.pbAnimation(@id,i,nil)
          i.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",i,nil) if !i.isInvulnerable?
          @battle.pbDisplay(_INTL("{1}'s Sap Sipper raised its Attack!",i.pbThis))
          i.effects[PBEffects::TypeIdentified]=true
        end
      activepkmn[activepkmn.length]=i.pokemonIndex
        next
      end
      activepkmn[activepkmn.length]=i.pokemonIndex
      i.status=0
    end
    party=@battle.pbParty(attacker.index) # NOTE: Considers both parties in multi battles
    for i in 0...party.length
      found=false
      for j in activepkmn
        if j==i
          found=true
          break
        end
      end
      next if found
      next if !party[i] || party[i].egg?
      case party[i].status
        when PBStatuses::PARALYSIS
          @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",party[i].name))
        when PBStatuses::SLEEP
          @battle.pbDisplay(_INTL("{1} was woken from its sleep.",party[i].name))
        when PBStatuses::POISON
          @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",party[i].name))
        when PBStatuses::BURN
          @battle.pbDisplay(_INTL("{1} was cured of its burn.",party[i].name))
        when PBStatuses::FROZEN
          @battle.pbDisplay(_INTL("{1} was defrosted.",party[i].name))
      end
      party[i].status=0
      party[i].statusCount=0
    end
    return 0
  end
end



################################################################################
# Safeguards the user's side from being inflicted with status problems.
################################################################################
class PokeBattle_Move_01A < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbOwnSide.effects[PBEffects::Safeguard]=5
    @battle.pbAnimation(@id,attacker,nil,true)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("The ally's party is covered by a veil!"))
    else
      @battle.pbDisplay(_INTL("The foe's party is covered by a veil!"))
    end
    return 0
  end
end



################################################################################
# User passes its status problem to the target.
################################################################################
class PokeBattle_Move_01B < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.status==0 || opponent.status!=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    case attacker.status
      when PBStatuses::PARALYSIS
        if opponent.pbCanParalyze?(attacker,true,self)
          @battle.pbAnimation(@id,attacker,opponent)
          opponent.pbParalyze(attacker)
          @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
          opponent.pbAbilityCureCheck
          @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::PARALYSIS
          @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",attacker.pbThis))
          attacker.status=0
        end
      when PBStatuses::SLEEP
        if opponent.pbCanSleep?(attacker,true,self,false)
          @battle.pbAnimation(@id,attacker,opponent)
          opponent.pbSleep(attacker)
          @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
          opponent.pbAbilityCureCheck
          @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::SLEEP
          @battle.pbDisplay(_INTL("{1} was woken from its sleep.",attacker.pbThis))
          attacker.status=0
          attacker.statusCount=0
        end
      when PBStatuses::POISON
        if opponent.pbCanPoison?(attacker,true,self)
          @battle.pbAnimation(@id,attacker,opponent)
          opponent.pbPoison(attacker,attacker.statusCount!=0)
          if attacker.statusCount!=0
            @battle.pbDisplay(_INTL("{1} is badly poisoned!",opponent.pbThis))
          else
            @battle.pbDisplay(_INTL("{1} is poisoned!",opponent.pbThis))
          end
          opponent.pbAbilityCureCheck
          @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::POISON
          @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbThis))
          attacker.status=0
          attacker.statusCount=0
        end
      when PBStatuses::BURN
        if opponent.pbCanBurn?(attacker,true,self)
          @battle.pbAnimation(@id,attacker,opponent)
          opponent.pbBurn(attacker)
          @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
          opponent.pbAbilityCureCheck
          @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::BURN
          @battle.pbDisplay(_INTL("{1} was cured of its burn.",attacker.pbThis))
          attacker.status=0
        end
      when PBStatuses::FROZEN
        if opponent.pbCanFreeze?(attacker,true,self)
          @battle.pbAnimation(@id,attacker,opponent)
          opponent.pbFreeze(attacker)
          @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
          opponent.pbAbilityCureCheck
          @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::FROZEN
          @battle.pbDisplay(_INTL("{1} was defrosted.",attacker.pbThis))
          attacker.status=0
        end
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack by 1 stage.
################################################################################
class PokeBattle_Move_01C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbDisplay(_INTL("{1}'s Attack won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Defense by 1 stage.
################################################################################
class PokeBattle_Move_01D < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s Defense won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::DEFENSE)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Defense by 1 stage.  User curls up.
################################################################################
class PokeBattle_Move_01E < PokeBattle_Move
  def pbEffect(attacker,opponent)
    attacker.effects[PBEffects::DefenseCurl]=true
    if attacker.pbTooHigh?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s Defense won't go higher!",attacker.pbThis))
      return -1
    else
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# Increases the user's Speed by 1 stage.
################################################################################
class PokeBattle_Move_01F < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::SPEED)
      @battle.pbDisplay(_INTL("{1}'s Speed won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Speed rose!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::SPEED)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Speed rose!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Special Attack by 1 stage.
################################################################################
class PokeBattle_Move_020 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s Special Attack won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::SPATK)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Special Defense by 1 stage.  Charges up Electric attacks.
################################################################################
class PokeBattle_Move_021 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    attacker.effects[PBEffects::Charge]=2
    @battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("{1} began charging power!",attacker.pbThis))
    if attacker.pbTooHigh?(PBStats::SPDEF)
      @battle.pbDisplay(_INTL("{1}'s Special Defense won't go higher!",attacker.pbThis))
      return -1
    else
      attacker.pbIncreaseStatBasic(PBStats::SPDEF,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Special Defense rose!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# Increases the user's evasion by 1 stage.
################################################################################
class PokeBattle_Move_022 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::EVASION)
      @battle.pbDisplay(_INTL("{1}'s evasiveness won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::EVASION,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s evasiveness rose!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::EVASION)
      attacker.pbIncreaseStatBasic(PBStats::EVASION,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s evasiveness rose!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's critical hit rate.
################################################################################
class PokeBattle_Move_023 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.effects[PBEffects::FocusEnergy]>=2
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      attacker.effects[PBEffects::FocusEnergy]=2
      @battle.pbAnimation(@id,attacker,nil,true)
      @battle.pbDisplay(_INTL("{1} is getting pumped!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.effects[PBEffects::FocusEnergy]<2
      attacker.effects[PBEffects::FocusEnergy]=2
      @battle.pbDisplay(_INTL("{1} is getting pumped!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Attack and Defense by 1 stage each.
################################################################################
class PokeBattle_Move_024 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ATTACK) &&
       attacker.pbTooHigh?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::DEFENSE)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack, Defense and accuracy by 1 stage each.
################################################################################
class PokeBattle_Move_025 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ATTACK) &&
       attacker.pbTooHigh?(PBStats::DEFENSE) &&
       attacker.pbTooHigh?(PBStats::ACCURACY)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
      @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::DEFENSE)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
      @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::ACCURACY)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::ACCURACY,1)
      @battle.pbDisplay(_INTL("{1}'s accuracy rose!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and Speed by 1 stage each.
################################################################################
class PokeBattle_Move_026 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ATTACK) &&
       attacker.pbTooHigh?(PBStats::SPEED)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
      @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPEED)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
      @battle.pbDisplay(_INTL("{1}'s Speed rose!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and Special Attack by 1 stage each.
################################################################################
class PokeBattle_Move_027 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ATTACK) &&
       attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
      @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,1)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and Special Attack by 1 stage each (2 each in sunshine).
################################################################################
class PokeBattle_Move_028 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ATTACK) &&
       attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    increment=(@battle.weather==PBWeather::SUNNYDAY || @battle.weather==PBWeather::HARSHSUN) ? 2 : 1
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStat(PBStats::ATTACK,increment,true)
    end
    if !attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStat(PBStats::SPATK,increment,true)
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and accuracy by 1 stage each.
################################################################################
class PokeBattle_Move_029 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ATTACK) &&
       attacker.pbTooHigh?(PBStats::ACCURACY)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    increment=(@battle.weather==PBWeather::NEWMOON) ? 2 : 1
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStat(PBStats::ATTACK,increment,true)
    end
    if !attacker.pbTooHigh?(PBStats::ACCURACY)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStat(PBStats::ACCURACY,increment,true)
    end
    return 0
  end
end



################################################################################
# Increases the user's Defense and Special Defense by 1 stage each.
################################################################################
class PokeBattle_Move_02A < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::DEFENSE) &&
       attacker.pbTooHigh?(PBStats::SPDEF)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::DEFENSE)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
      @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPDEF)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPDEF,1)
      @battle.pbDisplay(_INTL("{1}'s Special Defense rose!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Speed, Special Attack and Special Defense by 1 stage each.
################################################################################
class PokeBattle_Move_02B < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::SPEED) &&
       attacker.pbTooHigh?(PBStats::SPATK) &&
       attacker.pbTooHigh?(PBStats::SPDEF)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,1)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPDEF)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPDEF,1)
      @battle.pbDisplay(_INTL("{1}'s Special Defense rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPEED)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
      @battle.pbDisplay(_INTL("{1}'s Speed rose!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Special Attack and Special Defense by 1 stage each.
################################################################################
class PokeBattle_Move_02C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::SPATK) &&
       attacker.pbTooHigh?(PBStats::SPDEF)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,1)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPDEF)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPDEF,1)
      @battle.pbDisplay(_INTL("{1}'s Special Defense rose!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 stage each.
################################################################################
class PokeBattle_Move_02D < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    haveanim=false
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil) if !haveanim; haveanim=true
      @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::DEFENSE)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil) if !haveanim; haveanim=true
      @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPATK)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil) if !haveanim; haveanim=true
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPDEF)
      attacker.pbIncreaseStatBasic(PBStats::SPDEF,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil) if !haveanim; haveanim=true
      @battle.pbDisplay(_INTL("{1}'s Special Defense rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPEED)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil) if !haveanim; haveanim=true
      @battle.pbDisplay(_INTL("{1}'s Speed rose!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Attack by 2 stages.
################################################################################
class PokeBattle_Move_02E < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbDisplay(_INTL("{1}'s Attack won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Attack rose sharply!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Attack rose sharply!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Defense by 2 stages.
################################################################################
class PokeBattle_Move_02F < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s Defense won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Defense rose sharply!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::DEFENSE)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Defense rose sharply!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Speed by 2 stages.
################################################################################
class PokeBattle_Move_030 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::SPEED)
      @battle.pbDisplay(_INTL("{1}'s Speed won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Speed rose sharply!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::SPEED)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Speed rose sharply!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Speed by 2 stages.  Halves the user's weight.
################################################################################
class PokeBattle_Move_031 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::SPEED)
      @battle.pbDisplay(_INTL("{1}'s Speed won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Speed rose sharply!",attacker.pbThis))
      #attacker.effects[PBEffects::WeightMultiplier]/=2
      attacker.effects[PBEffects::WeightChange]-=1000
      @battle.pbDisplay(_INTL("{1} became nimble!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# Increases the user's Special Attack by 2 stages.
################################################################################
class PokeBattle_Move_032 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s Special Attack won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose sharply!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::SPATK)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose sharply!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Special Defense by 2 stages.
################################################################################
class PokeBattle_Move_033 < PokeBattle_Move
  def pbEffect(attacker,opponent) 
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::SPDEF)
      @battle.pbDisplay(_INTL("{1}'s Special Defense won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPDEF,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Special Defense rose sharply!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::SPDEF)
      attacker.pbIncreaseStatBasic(PBStats::SPDEF,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Special Defense rose sharply!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's evasion by 2 stages.  Minimizes the user.
################################################################################
class PokeBattle_Move_034 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    attacker.effects[PBEffects::Minimize]=true
    if attacker.pbTooHigh?(PBStats::EVASION)
      @battle.pbDisplay(_INTL("{1}'s evasiveness won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::EVASION,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s evasiveness rose sharply!",attacker.pbThis))
      return 0
    end 
  end

  def pbAdditionalEffect(attacker,opponent)
    attacker.effects[PBEffects::Minimize]=true
    if !attacker.pbTooHigh?(PBStats::EVASION)
      attacker.pbIncreaseStatBasic(PBStats::EVASION,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s evasiveness rose sharply!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Attack, Speed and Special Attack by 2 stages each.
# Decreases the user's Defense and Special Defense by 1 stage each.
################################################################################
class PokeBattle_Move_035 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ATTACK) &&
       attacker.pbTooHigh?(PBStats::SPEED) &&
       attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,2)
      @battle.pbDisplay(_INTL("{1}'s Attack rose sharply!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,2)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose sharply!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPEED)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,2)
      @battle.pbDisplay(_INTL("{1}'s Speed rose sharply!",attacker.pbThis))
    end
    if !attacker.pbTooLow?(PBStats::DEFENSE)
      @battle.pbCommonAnimation("StatDown",attacker,nil)
      attacker.pbReduceStatBasic(PBStats::DEFENSE,1)
      @battle.pbDisplay(_INTL("{1}'s Defense fell!",attacker.pbThis))
    end
    if !attacker.pbTooLow?(PBStats::SPDEF)
      @battle.pbCommonAnimation("StatDown",attacker,nil)
      attacker.pbReduceStatBasic(PBStats::SPDEF,1)
      @battle.pbDisplay(_INTL("{1}'s Special Defense fell!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Speed by 2 stages, and its Attack by 1 stage.
################################################################################
class PokeBattle_Move_036 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ATTACK) &&
       attacker.pbTooHigh?(PBStats::SPEED)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
      @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))
    end
    if !attacker.pbTooHigh?(PBStats::SPEED)
      attacker.pbIncreaseStatBasic(PBStats::SPEED,2)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Speed rose sharply!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases one random stat of the user by 2 stages (except HP).
################################################################################
class PokeBattle_Move_037 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent && attacker.index!=opponent.index
      if (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)) ||
         opponent.pbOwnSide.effects[PBEffects::CraftyShield]
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    opponent=attacker if !opponent
    array=[]
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      array.push(i) if !opponent.pbTooHigh?(i)
    end
    if array.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",opponent.pbThis))
      return -1
    end
    stat=array[@battle.pbRandom(array.length)]
    statname=[_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),
              _INTL("Special Attack"),_INTL("Special Defense"),
              _INTL("accuracy"),_INTL("evasion")][stat-1]
    @battle.pbAnimation(@id,opponent,nil)
    @battle.pbCommonAnimation("StatUp",opponent,nil)
    opponent.stages[stat]+=2
    opponent.stages[stat]=6 if opponent.stages[stat]>6
    @battle.pbDisplay(_INTL("{1}'s {2} rose sharply!",opponent.pbThis,statname))
    return 0
  end
end



################################################################################
# Increases the user's Defense by 3 stages.
################################################################################
class PokeBattle_Move_038 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s Defense won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,3)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Defense rose drastically!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::DEFENSE)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,3)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Defense rose drastically!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Special Attack by 3 stages.
################################################################################
class PokeBattle_Move_039 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    if attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s Special Attack won't go higher!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,3)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose drastically!",attacker.pbThis))
      return 0
    end
  end

  def pbAdditionalEffect(attacker,opponent)
    if !attacker.pbTooHigh?(PBStats::SPATK)
      attacker.pbIncreaseStatBasic(PBStats::SPATK,3)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose drastically!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Reduces the user's HP by half of max, and sets its Attack to maximum.
################################################################################
class PokeBattle_Move_03A < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.hp<=(attacker.totalhp/2).floor ||
       attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.pbReduceHP((attacker.totalhp/2).floor)
    attacker.stages[PBStats::ATTACK]=6
    @battle.pbCommonAnimation("StatUp",attacker,nil)
    @battle.pbDisplay(_INTL("{1} cut its own HP and maximized its Attack!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Decreases the user's Attack and Defense by 1 stage each.
################################################################################
class PokeBattle_Move_03B < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && (attacker.effects[PBEffects::LerneanCounter]<=1 || opponent.fainted?)
      if !attacker.pbTooLow?(PBStats::ATTACK)
        attacker.pbReduceStatBasic(PBStats::ATTACK,1)
        @battle.pbCommonAnimation("StatDown",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Attack fell!",attacker.pbThis))
      end
      if !attacker.pbTooLow?(PBStats::DEFENSE)
        attacker.pbReduceStatBasic(PBStats::DEFENSE,1)
        @battle.pbCommonAnimation("StatDown",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Defense fell!",attacker.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Defense and Special Defense by 1 stage each.
################################################################################
class PokeBattle_Move_03C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && (attacker.effects[PBEffects::LerneanCounter]<=1 || opponent.fainted?)
      if !attacker.pbTooLow?(PBStats::DEFENSE)
        attacker.pbReduceStatBasic(PBStats::DEFENSE,1)
        @battle.pbCommonAnimation("StatDown",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Defense fell!",attacker.pbThis))
      end
      if !attacker.pbTooLow?(PBStats::SPDEF)
        attacker.pbReduceStatBasic(PBStats::SPDEF,1)
        @battle.pbCommonAnimation("StatDown",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Special Defense fell!",attacker.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Defense, Speed and Special Defense by 1 stage each.
################################################################################
class PokeBattle_Move_03D < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && (attacker.effects[PBEffects::LerneanCounter]<=1 || opponent.fainted?)
      if !attacker.pbTooLow?(PBStats::SPEED)
        attacker.pbReduceStatBasic(PBStats::SPEED,1)
        @battle.pbCommonAnimation("StatDown",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Speed fell!",attacker.pbThis))
      end
      if !attacker.pbTooLow?(PBStats::DEFENSE)
        attacker.pbReduceStatBasic(PBStats::DEFENSE,1)
        @battle.pbCommonAnimation("StatDown",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Defense fell!",attacker.pbThis))
      end
      if !attacker.pbTooLow?(PBStats::SPDEF)
        attacker.pbReduceStatBasic(PBStats::SPDEF,1)
        @battle.pbCommonAnimation("StatDown",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Special Defense fell!",attacker.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Speed by 1 stage.
################################################################################
class PokeBattle_Move_03E < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !attacker.pbTooLow?(PBStats::SPEED) && 
       (attacker.effects[PBEffects::LerneanCounter]<=1 || opponent.fainted?)
      attacker.pbReduceStatBasic(PBStats::SPEED,1)
      @battle.pbCommonAnimation("StatDown",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Speed fell!",attacker.pbThis))
    end
    return ret
  end
end



################################################################################
# Decreases the user's Special Attack by 2 stages.
################################################################################
class PokeBattle_Move_03F < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if attacker.effects[PBEffects::LerneanCounter]<=1 || opponent.fainted?
      if opponent.damagestate.calcdamage>0 && !attacker.pbTooLow?(PBStats::SPATK)
        attacker.pbReduceStatBasic(PBStats::SPATK,2)
        @battle.pbCommonAnimation("StatDown",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Special Attack harshly fell!",attacker.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# Increases the target's Special Attack by 1 stage.  Confuses the target.
################################################################################
class PokeBattle_Move_040 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=-1
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    if !opponent.pbTooHigh?(PBStats::SPATK)
      opponent.pbIncreaseStatBasic(PBStats::SPATK,1)
      @battle.pbCommonAnimation("StatUp",attacker,opponent) if !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",opponent.pbThis))
      ret=0
    end
    if opponent.effects[PBEffects::Confusion]==0 && opponent.pbCanConfuse?(attacker,true,self)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",attacker,opponent) if !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      ret=0
    end
    return ret
  end
end



################################################################################
# Increases the target's Attack by 2 stages.  Confuses the target.
################################################################################
class PokeBattle_Move_041 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=-1
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    if !opponent.pbTooHigh?(PBStats::ATTACK)
      opponent.pbIncreaseStatBasic(PBStats::ATTACK,2)
      @battle.pbCommonAnimation("StatUp",attacker,opponent) if !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1}'s Attack rose sharply!",opponent.pbThis))
      ret=0
    end
    if opponent.effects[PBEffects::Confusion]==0 && opponent.pbCanConfuse?(attacker,true,self)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",attacker,opponent) if !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      ret=0
    end
    return ret
  end
end



################################################################################
# Decreases the target's Attack by 1 stage.
################################################################################
class PokeBattle_Move_042 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,true,self)
    return opponent.pbReduceStat(PBStats::ATTACK,1,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
      return opponent.pbReduceStat(PBStats::ATTACK,1,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's Defense by 1 stage.
################################################################################
class PokeBattle_Move_043 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,true,self)
    return opponent.pbReduceStat(PBStats::DEFENSE,1,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      return opponent.pbReduceStat(PBStats::DEFENSE,1,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's Speed by 1 stage.
################################################################################
class PokeBattle_Move_044 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,true,self)
    return opponent.pbReduceStat(PBStats::SPEED,1,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
      return opponent.pbReduceStat(PBStats::SPEED,1,true,@id,attacker,self)
    end
  end
  
  def pbModifyDamage(damage,attacker,opponent)
    if isConst?(@id,PBMoves,:BULLDOZE) && !opponent.isInvulnerable? &&
       @battle.field.effects[PBEffects::GrassyTerrain]>0
      return (damage/2.0).round
    end
    return damage
  end
end



################################################################################
# Decreases the target's Special Attack by 1 stage.
################################################################################
class PokeBattle_Move_045 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,true,self)
    return opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
      return opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's Special Defense by 1 stage.
################################################################################
class PokeBattle_Move_046 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,true,self)
    return opponent.pbReduceStat(PBStats::SPDEF,1,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
      return opponent.pbReduceStat(PBStats::SPDEF,1,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's accuracy by 1 stage.
################################################################################
class PokeBattle_Move_047 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,true,self)
    if @id==PBMoves::FLASH && @battle.weather==PBWeather::NEWMOON
      return opponent.pbReduceStat(PBStats::ACCURACY,2,true,@id,attacker,self) ? 0 : -1
    end
    return opponent.pbReduceStat(PBStats::ACCURACY,1,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
      return opponent.pbReduceStat(PBStats::ACCURACY,1,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's evasion by 2 stages.
################################################################################
class PokeBattle_Move_048 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker,true,self)
    return opponent.pbReduceStat(PBStats::EVASION,2,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self)
      return opponent.pbReduceStat(PBStats::EVASION,2,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's evasion by 1 stage.  Ends all barriers and entry
# hazards for the target's side.
################################################################################
class PokeBattle_Move_049 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    ret=opponent.pbReduceStat(PBStats::EVASION,1,true,@id,attacker,self) ? 0 : -1
    oppside=opponent.pbOwnSide
    if oppside.effects[PBEffects::Reflect] > 0
      oppside.effects[PBEffects::Reflect]=0
      @battle.pbDisplay(_INTL("{1} removed the opponent's Reflect!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::LightScreen] > 0
      oppside.effects[PBEffects::LightScreen]=0
      @battle.pbDisplay(_INTL("{1} removed the opponent's Light Screen!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Mist] > 0
      oppside.effects[PBEffects::Mist]=0
      @battle.pbDisplay(_INTL("{1} removed the opponent's Mist!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Safeguard] > 0
      oppside.effects[PBEffects::Safeguard]=0
      @battle.pbDisplay(_INTL("{1} removed the opponent's Safeguard!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Spikes] > 0
      oppside.effects[PBEffects::Spikes]=0
      @battle.pbDisplay(_INTL("{1} removed spikes from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::StealthRock]
      oppside.effects[PBEffects::StealthRock]=false
      @battle.pbDisplay(_INTL("{1} removed pointed stones from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::FireRock]
      oppside.effects[PBEffects::FireRock]=false
      @battle.pbDisplay(_INTL("{1} removed molten rocks from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::ToxicSpikes] > 0
      oppside.effects[PBEffects::ToxicSpikes]=0
      @battle.pbDisplay(_INTL("{1} removed toxic spikes from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::StickyWeb]
      oppside.effects[PBEffects::StickyWeb]=false
      @battle.pbDisplay(_INTL("{1} removed webs from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Livewire] > 0
      oppside.effects[PBEffects::Livewire]=0
      @battle.pbDisplay(_INTL("{1} removed the wire from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Permafrost] > 0
      oppside.effects[PBEffects::Permafrost]=0
      @battle.pbDisplay(_INTL("{1} removed the frost from the opponent's field!",attacker.pbThis))
    end

    oppside=attacker.pbOwnSide
    if oppside.effects[PBEffects::Spikes] > 0
      oppside.effects[PBEffects::Spikes]=0
      @battle.pbDisplay(_INTL("{1} removed spikes from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::StealthRock]
      oppside.effects[PBEffects::StealthRock]=false
      @battle.pbDisplay(_INTL("{1} removed pointed stones from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::FireRock]
      oppside.effects[PBEffects::FireRock]=false
      @battle.pbDisplay(_INTL("{1} removed molten rocks from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::ToxicSpikes] > 0
      oppside.effects[PBEffects::ToxicSpikes]=0
      @battle.pbDisplay(_INTL("{1} removed toxic spikes from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Livewire] > 0
      oppside.effects[PBEffects::Livewire]=0
      @battle.pbDisplay(_INTL("{1} removed the wire from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Permafrost] > 0
      oppside.effects[PBEffects::Permafrost]=0
      @battle.pbDisplay(_INTL("{1} removed the frost from the surrounding field!",attacker.pbThis))
    end

    return ret
  end

  def pbAdditionalEffect(attacker,opponent)
    if !opponent.damagestate.substitute
      if opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker,false,self)
        ret=opponent.pbReduceStat(PBStats::EVASION,1,true,@id,attacker,self)
      end
    end
    oppside=opponent.pbOwnSide
    if oppside.effects[PBEffects::Reflect] > 0
      oppside.effects[PBEffects::Reflect]=0
      @battle.pbDisplay(_INTL("{1} removed the opponent's Reflect!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::LightScreen] > 0
      oppside.effects[PBEffects::LightScreen]=0
      @battle.pbDisplay(_INTL("{1} removed the opponent's Light Screen!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Mist] > 0
      oppside.effects[PBEffects::Mist]=0
      @battle.pbDisplay(_INTL("{1} removed the opponent's Mist!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Safeguard] > 0
      oppside.effects[PBEffects::Safeguard]=0
      @battle.pbDisplay(_INTL("{1} removed the opponent's Safeguard!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Spikes] > 0
      oppside.effects[PBEffects::Spikes]=0
      @battle.pbDisplay(_INTL("{1} removed spikes from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::StealthRock]
      oppside.effects[PBEffects::StealthRock]=false
      @battle.pbDisplay(_INTL("{1} removed pointed stones from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::FireRock]
      oppside.effects[PBEffects::FireRock]=false
      @battle.pbDisplay(_INTL("{1} removed molten rocks from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::ToxicSpikes] > 0
      oppside.effects[PBEffects::ToxicSpikes]=0
      @battle.pbDisplay(_INTL("{1} removed toxic spikes from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::StickyWeb]
      oppside.effects[PBEffects::StickyWeb]=false
      @battle.pbDisplay(_INTL("{1} removed webs from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Livewire] > 0
      oppside.effects[PBEffects::Livewire]=0
      @battle.pbDisplay(_INTL("{1} removed the wire from the opponent's field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Permafrost] > 0
      oppside.effects[PBEffects::Permafrost]=0
      @battle.pbDisplay(_INTL("{1} removed the frost from the opponent's field!",attacker.pbThis))
    end

    oppside=attacker.pbOwnSide
    if oppside.effects[PBEffects::Spikes] > 0
      oppside.effects[PBEffects::Spikes]=0
      @battle.pbDisplay(_INTL("{1} removed spikes from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::StealthRock]
      oppside.effects[PBEffects::StealthRock]=false
      @battle.pbDisplay(_INTL("{1} removed pointed stones from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::FireRock]
      oppside.effects[PBEffects::FireRock]=false
      @battle.pbDisplay(_INTL("{1} removed molten rocks from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::ToxicSpikes] > 0
      oppside.effects[PBEffects::ToxicSpikes]=0
      @battle.pbDisplay(_INTL("{1} removed toxic spikes from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Livewire] > 0
      oppside.effects[PBEffects::Livewire]=0
      @battle.pbDisplay(_INTL("{1} removed the wire from the surrounding field!",attacker.pbThis))
    end
    if oppside.effects[PBEffects::Permafrost] > 0
      oppside.effects[PBEffects::Permafrost]=0
      @battle.pbDisplay(_INTL("{1} removed the frost from the surrounding field!",attacker.pbThis))
    end

    return ret
  end
end



################################################################################
# Decreases the target's Attack and Defense by 1 stage each.
################################################################################
class PokeBattle_Move_04A < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    if opponent.pbTooLow?(PBStats::ATTACK) &&
       opponent.pbTooLow?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s stats won't go lower!",opponent.pbThis))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      return -1
    end
    if !attacker.hasMoldBreaker && (opponent.hasWorkingAbility(:CLEARBODY) ||
       opponent.hasWorkingAbility(:WHITESMOKE))
      abilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,abilityname))
      return -1
    end
    fail=-1
    hadanim=false
    @battle.pbAnimation(@id,attacker,opponent)
    if (!attacker.hasMoldBreaker && opponent.hasWorkingAbility(:HYPERCUTTER))
      abilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",opponent.pbThis,abilityname))
    elsif opponent.pbTooLow?(PBStats::ATTACK)
      @battle.pbDisplay(_INTL("{1}'s Attack won't go lower!",opponent.pbThis))
    else
      opponent.pbReduceStatBasic(PBStats::ATTACK,1)
      @battle.pbCommonAnimation("StatDown",attacker,opponent) if !opponent.isInvulnerable?; hadanim=true
      @battle.pbDisplay(_INTL("{1}'s Attack fell!",opponent.pbThis))
      fail=0
    end
    if (!attacker.hasMoldBreaker && opponent.hasWorkingAbility(:BIGPECKS))
      abilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents Defense loss!",opponent.pbThis,abilityname))
    elsif opponent.pbTooLow?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s Defense won't go lower!",opponent.pbThis))
    else
      opponent.pbReduceStatBasic(PBStats::DEFENSE,1)
      @battle.pbCommonAnimation("StatDown",attacker,opponent) if !hadanim && !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1}'s Defense fell!",opponent.pbThis))
      fail=0
    end
    return fail
  end
end



################################################################################
# Decreases the target's Attack by 2 stages.
################################################################################
class PokeBattle_Move_04B < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,true,self)
    return opponent.pbReduceStat(PBStats::ATTACK,2,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
      return opponent.pbReduceStat(PBStats::ATTACK,2,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's Defense by 2 stages.
################################################################################
class PokeBattle_Move_04C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,true,self)
    return opponent.pbReduceStat(PBStats::DEFENSE,2,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker,false,self)
      return opponent.pbReduceStat(PBStats::DEFENSE,2,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's Speed by 2 stages.
################################################################################
class PokeBattle_Move_04D < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,true,self)
    return opponent.pbReduceStat(PBStats::SPEED,2,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
      return opponent.pbReduceStat(PBStats::SPEED,2,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's Special Attack by 2 stages.  Only works on the opposite
# gender.
################################################################################
class PokeBattle_Move_04E < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,true,self)
    agender=attacker.gender
    ogender=opponent.gender
    if agender==2 || ogender==2 || agender==ogender
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:OBLIVIOUS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      return -1
    end
    return opponent.pbReduceStat(PBStats::SPATK,2,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    agender=attacker.gender
    ogender=opponent.gender
    return false if agender==2 || ogender==2 || agender==ogender
    return false if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:OBLIVIOUS)
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
      return opponent.pbReduceStat(PBStats::SPATK,2,true,@id,attacker,self)
    end
  end
end



################################################################################
# Decreases the target's Special Defense by 2 stages.
################################################################################
class PokeBattle_Move_04F < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,true,self)
    return opponent.pbReduceStat(PBStats::SPDEF,2,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker,false,self)
      return opponent.pbReduceStat(PBStats::SPDEF,2,true,@id,attacker,self)
    end
  end
end



################################################################################
# Resets all target's stat stages to 0.
################################################################################
class PokeBattle_Move_050 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      opponent.stages[PBStats::ATTACK]=0
      opponent.stages[PBStats::DEFENSE]=0
      opponent.stages[PBStats::SPEED]=0
      opponent.stages[PBStats::SPATK]=0
      opponent.stages[PBStats::SPDEF]=0
      opponent.stages[PBStats::ACCURACY]=0
      opponent.stages[PBStats::EVASION]=0
      @battle.pbDisplay(_INTL("{1}'s stat changes were removed!",opponent.pbThis))
    end
    return ret
  end
end



################################################################################
# Resets all stat stages for all battlers to 0.
################################################################################
class PokeBattle_Move_051 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    for i in 0..3
      @battle.battlers[i].stages[PBStats::ATTACK]=0
      @battle.battlers[i].stages[PBStats::DEFENSE]=0
      @battle.battlers[i].stages[PBStats::SPEED]=0
      @battle.battlers[i].stages[PBStats::SPATK]=0
      @battle.battlers[i].stages[PBStats::SPDEF]=0
      @battle.battlers[i].stages[PBStats::ACCURACY]=0
      @battle.battlers[i].stages[PBStats::EVASION]=0
    end
    @battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("All stat changes were eliminated!"))
    return 0
  end
end



################################################################################
# User and target swap their Attack and Special Attack stat stages.
################################################################################
class PokeBattle_Move_052 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    astage=attacker.stages
    ostage=opponent.stages
    astage[PBStats::ATTACK],ostage[PBStats::ATTACK]=ostage[PBStats::ATTACK],astage[PBStats::ATTACK]
    astage[PBStats::SPATK],ostage[PBStats::SPATK]=ostage[PBStats::SPATK],astage[PBStats::SPATK]
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} switched its stat boosts with {2}!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# User and target swap their Defense and Special Defense stat stages.
################################################################################
class PokeBattle_Move_053 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    astage=attacker.stages
    ostage=opponent.stages
    astage[PBStats::DEFENSE],ostage[PBStats::DEFENSE]=ostage[PBStats::DEFENSE],astage[PBStats::DEFENSE]
    astage[PBStats::SPDEF],ostage[PBStats::SPDEF]=ostage[PBStats::SPDEF],astage[PBStats::SPDEF]
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} switched its stat boosts with {2}!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# User and target swap all their stat stages.
################################################################################
class PokeBattle_Move_054 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    astage=attacker.stages
    ostage=opponent.stages
    for i in astage
      astage[i],ostage[i]=ostage[i],astage[i]
    end
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} switched its stat boosts with {2}!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# User copies the target's stat stages.
################################################################################
class PokeBattle_Move_055 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
      attacker.stages[i]=opponent.stages[i]
    end
    attacker.effects[PBEffects::FocusEnergy]=opponent.effects[PBEffects::FocusEnergy]
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# For 5 rounds, user's and ally's stat stages cannot be lowered by foes.
################################################################################
class PokeBattle_Move_056 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbOwnSide.effects[PBEffects::Mist]=5
    @battle.pbAnimation(@id,attacker,nil,true)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team became shrouded in mist!"))
    else
      @battle.pbDisplay(_INTL("The foe's team became shrouded in mist!"))
    end
    return 0
  end
end



################################################################################
# Swaps the user's Attack and Defense.
################################################################################
class PokeBattle_Move_057 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    attacker.attack,attacker.defense=attacker.defense,attacker.attack
    attacker.effects[PBEffects::PowerTrick]=!attacker.effects[PBEffects::PowerTrick]
    @battle.pbAnimation(@id,attacker,nil,true)
    @battle.pbDisplay(_INTL("{1} switched its Attack and Defense!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Averages the user's and target's Attack and Special Attack (separately).
################################################################################
class PokeBattle_Move_058 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    aatk=attacker.attack
    asatk=attacker.spatk
    oatk=opponent.attack
    osatk=opponent.spatk
    attacker.attack=opponent.attack=((aatk+oatk)/2).floor
    attacker.spatk=opponent.spatk=((asatk+osatk)/2).floor
    @battle.pbAnimation(@id,attacker,nil,true)
    @battle.pbDisplay(_INTL("{1} shared its power with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Averages the user's and target's Defense and Special Defense (separately).
################################################################################
class PokeBattle_Move_059 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    adef=attacker.defense
    asdef=attacker.spdef
    odef=opponent.defense
    osdef=opponent.spdef
    attacker.defense=opponent.defense=((adef+odef)/2).floor
    attacker.spdef=opponent.spdef=((asdef+osdef)/2).floor
    @battle.pbAnimation(@id,attacker,nil,true)
    @battle.pbDisplay(_INTL("{1} shared its guard with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Averages the user's and target's current HP.
################################################################################
class PokeBattle_Move_05A < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    oldahp=attacker.hp
    oldohp=opponent.hp
    avghp=((opponent.hp+attacker.hp)/2).floor
    attackerhp=avghp
    opponenthp=avghp
    attackerhp=attacker.totalhp if attackerhp>attacker.totalhp
    opponenthp=opponent.totalhp if opponenthp>opponent.totalhp
    attacker.hp=attackerhp
    opponent.hp=opponenthp
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.scene.pbHPChanged(attacker,oldahp)
    @battle.scene.pbHPChanged(opponent,oldohp)
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
   return 0
  end
end



################################################################################
# For 5 rounds, doubles the user's and ally's Speed.
################################################################################
class PokeBattle_Move_05B < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbOwnSide.effects[PBEffects::Tailwind]=4
    @battle.pbAnimation(@id,attacker,nil,true)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("The tailwind blew from behind your team!"))
    else
      @battle.pbDisplay(_INTL("The tailwind blew from behind the opposing team!"))
    end
    return 0
  end
end



################################################################################
# This move turns into the last move used by the target, until user switches out.
################################################################################
class PokeBattle_Move_05C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::Transform]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.lastMoveUsed<=0 ||
       isConst?(opponent.lastMoveUsed,PBMoves,:CHATTER) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:METRONOME) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:MIMIC) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:SKETCH) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:STRUGGLE) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:FAIRYTEMPEST) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:DYNAMICFURY) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:AURABLAST) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:DARKNOVA) 
       isConst?(opponent.lastMoveUsed,PBMoves,:TRANSFORM) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:MORPH)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in attacker.moves
      if i.id==opponent.lastMoveUsed
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1 
      end
    end
    #TODO: May be unsatisfactory (Sleep Talk/Mimic, etc.),
    #Mimic's position is considered
    @battle.pbAnimation(@id,attacker,opponent)
    for i in 0..attacker.moves.length-1
      if attacker.moves[i].id==@id
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(
           @battle,PBMove.new(opponent.lastMoveUsed))
        #attacker.moves[i].pp=5
        movename=PBMoves.getName(opponent.lastMoveUsed)
        @battle.pbDisplay(_INTL("{1} learned {2}!",attacker.pbThis,movename))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# This move permanently turns into the last move used by the target.
################################################################################
class PokeBattle_Move_05D < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::Transform]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.lastMoveUsedSketch<=0 ||
       isConst?(opponent.lastMoveUsedSketch,PBMoves,:CHATTER) ||
       isConst?(opponent.lastMoveUsedSketch,PBMoves,:SKETCH) ||
       isConst?(opponent.lastMoveUsedSketch,PBMoves,:STRUGGLE) ||
       isConst?(opponent.lastMoveUsedSketch,PBMoves,:FAIRYTEMPEST) ||
       isConst?(opponent.lastMoveUsedSketch,PBMoves,:DYNAMICFURY) ||
       isConst?(opponent.lastMoveUsedSketch,PBMoves,:AURABLAST) ||
       isConst?(opponent.lastMoveUsedSketch,PBMoves,:DARKNOVA)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in attacker.moves
      if i.id==opponent.lastMoveUsedSketch
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1 
      end
    end
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    #TODO: May be unsatisfactory (Sleep Talk/Sketch, etc.),
    #Sketch's position is considered
    for i in 0..attacker.moves.length-1
      if attacker.moves[i].id==@id
        newmove=PBMove.new(opponent.lastMoveUsedSketch)
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,newmove)
        party=@battle.pbParty(attacker.index)
        party[attacker.pokemonIndex].moves[i]=newmove
        movename=PBMoves.getName(opponent.lastMoveUsedSketch)
        @battle.pbAnimation(@id,attacker,opponent)
        @battle.pbDisplay(_INTL("{1} sketched {2}!",attacker.pbThis,movename))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# Changes user's type to that of a random move of the user.
################################################################################
class PokeBattle_Move_05E < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types=[]
    for i in attacker.moves
      next if i.id==@id
      next if PBTypes.isPseudoType?(i.type)
      #next if attacker.pbHasType?(i.type)
      #if !types.include?(i.type)
        types.push(i.type)
        break
      #end
    end
    if types.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    newtype=types[@battle.pbRandom(types.length)]
    attacker.type1=newtype
    attacker.type2=newtype
    attacker.effects[PBEffects::ForestsCurse]=false
    attacker.effects[PBEffects::TrickOrTreat]=false
    typename=PBTypes.getName(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
  end
=begin
  def pbEffect(attacker,opponent)
    if attacker.hasWorkingAbility(:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types=[]
    for i in attacker.moves
      next if attacker.pbHasType?(i.type)
      next if PBTypes.isPseudoType?(i.type)
      found=false
      for j in types
        if i.type==j
          found=true
          break
        end
      end
      types[types.length]=i.type if !found
    end
    if types.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    thistype=types[@battle.pbRandom(types.length)]
    attacker.type1=thistype
    attacker.type2=thistype
    typename=PBTypes.getName(thistype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
  end
=end
end



################################################################################
# Changes user's type to a random one that resists the last attack against user.
################################################################################
class PokeBattle_Move_05F < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.lastMoveUsed<=0 ||
       PBTypes.isPseudoType?(PBMoveData.new(opponent.lastMoveUsed).type)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types=[]
    atype=opponent.lastMoveUsedType
    if atype<0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in 0..PBTypes.maxValue
      next if PBTypes.isPseudoType?(i)
      next if attacker.pbHasType?(i)
      types.push(i) if PBTypes.getEffectiveness(atype,i)<2 
    end
    if types.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    newtype=types[@battle.pbRandom(types.length)]
    attacker.type1=newtype
    attacker.type2=newtype
    attacker.effects[PBEffects::ForestsCurse]=false
    attacker.effects[PBEffects::TrickOrTreat]=false
    typename=PBTypes.getName(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
    return 0
  end
=begin
  def pbEffect(attacker,opponent)
    if attacker.hasWorkingAbility(:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.effects[PBEffects::Conversion2Move]<=0 ||
       attacker.effects[PBEffects::Conversion2Type]<0 ||
       PBTypes.isPseudoType?(attacker.effects[PBEffects::Conversion2Type])
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types=[]
    atype=attacker.effects[PBEffects::Conversion2Type]
    for i in 0..PBTypes.maxValue
      otype=i
      if PBTypes.getEffectiveness(atype,otype)<2 
        types.push(i) # Add resistant or immune type
      end
    end
    if types.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ctype=types[@battle.pbRandom(types.length)]
    attacker.type1=ctype
    attacker.type2=ctype
    @battle.pbAnimation(@id,attacker,nil)
    typename=PBTypes.getName(ctype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
    return 0
  end
=end
end



################################################################################
# Changes user's type depending on the environment.
################################################################################
class PokeBattle_Move_060 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.hasWorkingAbility(:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    type=getConst(PBTypes,:NORMAL) || 0
    case @battle.environment
    when PBEnvironment::None;        type=getConst(PBTypes,:NORMAL) || 0
    when PBEnvironment::Grass;       type=getConst(PBTypes,:GRASS) || 0
    when PBEnvironment::TallGrass;   type=getConst(PBTypes,:GRASS) || 0
    when PBEnvironment::MovingWater; type=getConst(PBTypes,:WATER) || 0
    when PBEnvironment::StillWater;  type=getConst(PBTypes,:WATER) || 0
    when PBEnvironment::Underwater;  type=getConst(PBTypes,:WATER) || 0
    when PBEnvironment::Cave;        type=getConst(PBTypes,:ROCK) || 0
    when PBEnvironment::Rock;        type=getConst(PBTypes,:GROUND) || 0
    when PBEnvironment::Sand;        type=getConst(PBTypes,:GROUND) || 0
    when PBEnvironment::Forest;      type=getConst(PBTypes,:BUG) || 0
    when PBEnvironment::Snow;        type=getConst(PBTypes,:ICE) || 0
    when PBEnvironment::Volcano;     type=getConst(PBTypes,:FIRE) || 0
    when PBEnvironment::Sky;         type=getConst(PBTypes,:FLYING) || 0
    when PBEnvironment::Space;       type=getConst(PBTypes,:DRAGON) || 0
    end
    if @battle.field.effects[PBEffects::ElectricTerrain]>0
      type=getConst(PBTypes,:ELECTRIC) if hasConst?(PBTypes,:ELECTRIC)
    elsif @battle.field.effects[PBEffects::GrassyTerrain]>0
      type=getConst(PBTypes,:GRASS) if hasConst?(PBTypes,:GRASS)
    elsif @battle.field.effects[PBEffects::MistyTerrain]>0
      type=getConst(PBTypes,:FAIRY) if hasConst?(PBTypes,:FAIRY)
    end
    if attacker.pbHasType?(type)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1  
    end
    @battle.pbAnimation(@id,attacker,opponent)
    attacker.type1=type
    attacker.type2=type
    attacker.effects[PBEffects::Type3]=-1
    typename=PBTypes.getName(type)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))  
  end
end



################################################################################
# Target becomes Water type.
################################################################################
class PokeBattle_Move_061 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasWorkingAbility(:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if isConst?(opponent.type1,PBTypes,:WATER) && isConst?(opponent.type2,PBTypes,:WATER)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.type1=PBTypes::WATER
    opponent.type2=PBTypes::WATER
    typename=PBTypes.getName(opponent.type1)
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end



################################################################################
# User copes target's types.
################################################################################
class PokeBattle_Move_062 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.hasWorkingAbility(:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.pbHasType?(opponent.type1) && attacker.pbHasType?(opponent.type2) &&
       opponent.pbHasType?(attacker.type1) && opponent.pbHasType?(attacker.type2)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.type1=opponent.type1
    attacker.type2=opponent.type2
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1}'s type changed to match the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Target's ability becomes Simple.
################################################################################
class PokeBattle_Move_063 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.hasWorkingAbility(:MULTITYPE) ||
       opponent.hasWorkingAbility(:SIMPLE) ||
       opponent.hasWorkingAbility(:TRUANT) ||
       opponent.hasWorkingAbility(:STANCECHANGE) ||
       opponent.hasWorkingAbility(:POWERCONSTRUCT) 
       opponent.hasWorkingAbility(:LERNEAN) ||
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.ability=getConst(PBAbilities,:SIMPLE)
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
    return 0
  end
end



################################################################################
# Target's ability becomes Insomnia.
################################################################################
class PokeBattle_Move_064 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.hasWorkingAbility(:MULTITYPE) ||
       opponent.hasWorkingAbility(:INSOMNIA) ||
       opponent.hasWorkingAbility(:TRUANT) ||
       opponent.hasWorkingAbility(:STANCECHANGE) ||
       opponent.hasWorkingAbility(:POWERCONSTRUCT) 
       opponent.hasWorkingAbility(:LERNEAN) ||
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.ability=getConst(PBAbilities,:INSOMNIA)#&& $Trainer != nil && $Trainer.caught[i] || 0
    @battle.pbAnimation(@id,attacker,opponent)
   # Kernel.pbMessage("1") if opponent.pbThis
   # Kernel.pbMessage("2") if opponent.ability
   # Kernel.pbMessage("3") if PBAbilities.getName(opponent.ability)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))
    return 0
  end
end



################################################################################
# User copies target's ability.
################################################################################
class PokeBattle_Move_065 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.ability(true)==opponent.ability(true) || opponent.ability(true)==0 ||
       attacker.hasWorkingAbility(:MULTITYPE) ||
       opponent.hasWorkingAbility(:MULTITYPE) ||
       opponent.hasWorkingAbility(:FLOWERGIFT) ||
       opponent.hasWorkingAbility(:FORECAST) ||
       opponent.hasWorkingAbility(:ILLUSION) ||
       opponent.hasWorkingAbility(:IMPOSTER) ||
       opponent.hasWorkingAbility(:TRACE) ||
       opponent.hasWorkingAbility(:WONDERGUARD) ||
       attacker.hasWorkingAbility(:LERNEAN) ||
       opponent.hasWorkingAbility(:LERNEAN) ||
       attacker.hasWorkingAbility(:ZENMODE) ||
       opponent.hasWorkingAbility(:ZENMODE) ||
       attacker.hasWorkingAbility(:STANCECHANGE) ||
       opponent.hasWorkingAbility(:STANCECHANGE) ||
       attacker.hasWorkingAbility(:POWERCONSTRUCT) ||
       opponent.hasWorkingAbility(:POWERCONSTRUCT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -0
    end
    @battle.pbAnimation(@id,attacker,opponent)
    attacker.ability=opponent.ability(true)
    abilityname=PBAbilities.getName(opponent.ability(true))
    @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),abilityname))
    return 0
  end
end



################################################################################
# Target copies user's ability.
################################################################################
class PokeBattle_Move_066 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.ability(true)==opponent.ability(true) || attacker.ability(true)==0 ||
       opponent.hasWorkingAbility(:TRUANT) ||
       opponent.hasWorkingAbility(:MULTITYPE) ||
       attacker.hasWorkingAbility(:FLOWERGIFT) ||
       attacker.hasWorkingAbility(:FORECAST) ||
       attacker.hasWorkingAbility(:ILLUSION) ||
       attacker.hasWorkingAbility(:IMPOSTER) ||
       attacker.hasWorkingAbility(:TRACE) ||
       attacker.hasWorkingAbility(:LERNEAN) ||
       opponent.hasWorkingAbility(:LERNEAN) ||
       attacker.hasWorkingAbility(:ZENMODE) ||
       opponent.hasWorkingAbility(:ZENMODE) ||
       opponent.hasWorkingAbility(:STANCECHANGE) ||
       attacker.hasWorkingAbility(:POWERCONSTRUCT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -0
    end
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.ability=attacker.ability(true)
    abilityname=PBAbilities.getName(attacker.ability(true))
    @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!",opponent.pbThis,attacker.pbThis(true),abilityname))
    return 0
  end
end



################################################################################
# User and target swap abilities.
################################################################################
class PokeBattle_Move_067 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if (attacker.ability(true)==0 && opponent.ability(true)==0) ||
       attacker.ability(true)==opponent.ability(true) ||
       attacker.hasWorkingAbility(:MULTITYPE) ||
       opponent.hasWorkingAbility(:MULTITYPE) ||
       attacker.hasWorkingAbility(:ILLUSION) ||
       opponent.hasWorkingAbility(:ILLUSION) ||
       attacker.hasWorkingAbility(:WONDERGUARD) ||
       opponent.hasWorkingAbility(:WONDERGUARD) ||
       attacker.hasWorkingAbility(:LERNEAN) ||
       opponent.hasWorkingAbility(:LERNEAN) ||
       attacker.hasWorkingAbility(:STANCECHANGE) ||
       opponent.hasWorkingAbility(:STANCECHANGE) ||
       attacker.hasWorkingAbility(:POWERCONSTRUCT) ||
       opponent.hasWorkingAbility(:POWERCONSTRUCT) 
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    tmp=attacker.ability(true)
    attacker.ability=opponent.ability(true)
    opponent.ability=tmp
    @battle.pbDisplay(_INTL("{1} swapped its {2} ability with its target's {3} ability!",
       attacker.pbThis,PBAbilities.getName(opponent.ability(true)),
       PBAbilities.getName(attacker.ability(true))))
    attacker.pbAbilitiesOnSwitchIn(true)
    opponent.pbAbilitiesOnSwitchIn(true)
    return 0
  end
end



################################################################################
# Target's ability is negated.
################################################################################
class PokeBattle_Move_068 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasWorkingAbility(:MULTITYPE) ||
       opponent.hasWorkingAbility(:STANCECHANGE)  ||
       opponent.hasWorkingAbility(:LERNEAN)  ||
       opponent.hasWorkingAbility(:POWERCONSTRUCT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    oldabil=opponent.ability
    opponent.effects[PBEffects::GastroAcid]=true
    opponent.effects[PBEffects::Truant]=false
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1}'s ability was suppressed!",opponent.pbThis)) 
    if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
      opponent.effects[PBEffects::Illusion]=nil
      @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
      @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
    end
    return 0
  end
end



################################################################################
# User transforms into the target.
################################################################################
class PokeBattle_Move_069 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Substitute]>0 ||
       opponent.effects[PBEffects::SkyDrop] ||
       opponent.effects[PBEffects::SpiritAway] ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY) ||
       opponent.effects[PBEffects::Illusion]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      attacker.effects[PBEffects::Transform]=true
      @battle.pbAnimation(@id,attacker,opponent)
      oldpbthis=attacker.pbThis
      #attacker.species=opponent.species
      attacker.gender=opponent.gender
      attacker.form=opponent.form
      attacker.effects[PBEffects::WeightChange]+=opponent.weight
      attacker.type1=opponent.type1
      attacker.type2=opponent.type2
      attacker.ability=opponent.ability(true)
      attacker.attack=opponent.attack
      attacker.defense=opponent.defense
      attacker.speed=opponent.speed
      attacker.spatk=opponent.spatk
      attacker.spdef=opponent.spdef
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
        attacker.stages[i]=opponent.stages[i]
      end
      attacker.effects[PBEffects::FocusEnergy]=opponent.effects[PBEffects::FocusEnergy]
      hasTransform=false
      for i in 0..3
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(
           @battle,PBMove.new(opponent.moves[i].id))
        attacker.moves[i].pp=5
        attacker.moves[i].totalpp=5
        if isConst?(opponent.moves[i].id,PBMoves,:TRANSFORM)
          hasTransform=true
          attacker.effects[PBEffects::ChoiceBand]=opponent.moves[i].id
        end
      end
      if attacker.effects[PBEffects::ChoiceBand]>=0 && !hasTransform
        attacker.effects[PBEffects::ChoiceBand]=-1
      end
      attacker.effects[PBEffects::Disable]=0
      attacker.effects[PBEffects::DisableMove]=0
      speciesname=PBSpecies.getName(opponent.species)
      @battle.pbDisplay(_INTL("{1} transformed into {2}!",oldpbthis,speciesname))
      attacker.pbAbilitiesOnSwitchIn(attacker.ability)
      return 0
    end
  end
end



################################################################################
# Inflicts a fixed 20HP damage.
################################################################################
class PokeBattle_Move_06A < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return pbEffectFixedDamage(20,attacker,opponent)
  end
end



################################################################################
# Inflicts a fixed 40HP damage.
################################################################################
class PokeBattle_Move_06B < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.ability==PBAbilities::LERNEAN && attacker.effects[PBEffects::GastroAcid] &&
       attacker.form != 0
      return pbEffectFixedDamage(40/attacker.form,attacker,opponent)
      
    end
    
    return pbEffectFixedDamage(40,attacker,opponent)
  end
end



################################################################################
# Halves the target's current HP.
################################################################################
class PokeBattle_Move_06C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return pbEffectFixedDamage((opponent.hp/2).floor,attacker,opponent)
  end
end



################################################################################
# Inflicts damage equal to the user's level.
################################################################################
class PokeBattle_Move_06D < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return pbEffectFixedDamage(attacker.level,attacker,opponent)
  end
end



################################################################################
# Inflicts damage to bring the target's HP down to equal the user's HP.
################################################################################
class PokeBattle_Move_06E < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.hp>=opponent.hp
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      return pbEffectFixedDamage(opponent.hp-attacker.hp,attacker,opponent)
    end
  end
end



################################################################################
# Inflicts damage between 0.5 and 1.5 times the user's level.
################################################################################
class PokeBattle_Move_06F < PokeBattle_Move
  def pbEffect(attacker,opponent)
    rnd=@battle.pbRandom(11)
    dmg=((attacker.level)*(rnd+5)/10).floor
    return pbEffectFixedDamage(dmg,attacker,opponent)
  end
end



################################################################################
# OHKO. Accuracy increases by difference between levels of user and target.
################################################################################
class PokeBattle_Move_070 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    damage=pbEffectFixedDamage(opponent.totalhp,attacker,opponent)
    if opponent.hp<=0
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
    return damage
  end

  def pbAccuracyCheck(attacker,opponent)
    accuracy=@accuracy
    if @id==PBMoves::SHEERCOLD && (opponent.pbHasType?(PBTypes::ICE) || opponent.hasWorkingAbility(:OMNITYPE))
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis))
      attacker.effects[PBEffects::OHKOFailed]=true
      opponent.effects[PBEffects::TypeIdentified]=true
      return false
    end
    if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:STURDY)
      @battle.pbDisplay(_INTL("{1} was protected by {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))  
      attacker.effects[PBEffects::OHKOFailed]=true
      return false
    end
    if opponent.level > attacker.level
      @battle.pbDisplay(_INTL("{1} is unaffected!",opponent.pbThis))
      attacker.effects[PBEffects::OHKOFailed]=true
      return false
    end
    accuracy=accuracy+attacker.level-opponent.level
    accuracy=100 if accuracy>100
    return @battle.pbRandom(100)<accuracy
  end
end


################################################################################
# Counters a physical move used against the user this round, with 2x the power.
################################################################################
class PokeBattle_Move_071 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::CounterTarget]>=0 &&
       attacker.pbIsOpposing?(attacker.effects[PBEffects::CounterTarget])
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::CounterTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::Counter]<=0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    movelist=[
       0x214,   # Fairy Tempest
       0x215,   # Dynamic Fury
       0x216,   # Aura Blast
       0x217    # Dark Nova
    ]
    if movelist.include?(PBMoveData.new(opponent.lastMoveUsed).function)
      @battle.pbDisplay(_INTL("The Burst Attack couldn't be countered!"))
      return -1
    end
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::Counter]*2,attacker,opponent)
    return ret
  end
end



################################################################################
# Counters a specical move used against the user this round, with 2x the power.
################################################################################
class PokeBattle_Move_072 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::MirrorCoatTarget]>=0 && 
       attacker.pbIsOpposing?(attacker.effects[PBEffects::MirrorCoatTarget])
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::MirrorCoatTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::MirrorCoat]<=0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    movelist=[
       0x214,   # Fairy Tempest
       0x215,   # Dynamic Fury
       0x216,   # Aura Blast
       0x217    # Dark Nova
    ]
    if movelist.include?(PBMoveData.new(opponent.lastMoveUsed).function)
      @battle.pbDisplay(_INTL("The Burst Attack couldn't be countered!"))
      return -1
    end
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::MirrorCoat]*2,attacker,opponent)
    return ret
  end
end



################################################################################
# Counters the last damaging move used against the user this round, with 1.5x
# the power.
################################################################################
class PokeBattle_Move_073 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.lastAttacker.length>0
      lastattacker=attacker.lastAttacker[attacker.lastAttacker.length-1]
      if lastattacker>=0 && attacker.pbIsOpposing?(lastattacker)
        if !attacker.pbAddTarget(targets,@battle.battlers[lastattacker])
          attacker.pbRandomTarget(targets)
        end
      end
    end
    
    #if attacker.lastAttacker>=0 && attacker.pbIsOpposing?(attacker.lastAttacker)
    #  if !attacker.pbAddTarget(targets,@battle.battlers[attacker.lastAttacker])
    #    attacker.pbRandomTarget(targets)
    #  end
    #end
  end

  def pbEffect(attacker,opponent)
    if attacker.lastHPLost==0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    movelist=[
       0x214,   # Fairy Tempest
       0x215,   # Dynamic Fury
       0x216,   # Aura Blast
       0x217    # Dark Nova
    ]
    if movelist.include?(PBMoveData.new(opponent.lastMoveUsed).function)
      @battle.pbDisplay(_INTL("The Burst Attack couldn't be countered!"))
      return -1
    end
    ret=pbEffectFixedDamage([(attacker.lastHPLost*1.5).floor,1].max,attacker,opponent)
    return ret
  end
end



################################################################################
# The target's ally loses 1/16 of its max HP.
################################################################################
class PokeBattle_Move_074 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      if opponent.pbPartner && !opponent.pbPartner.fainted? &&
         !opponent.pbPartner.hasWorkingAbility(:MAGICGUARD)
        opponent.pbPartner.pbReduceHP((opponent.pbPartner.totalhp/16).floor)
        @battle.pbDisplay(_INTL("The bursting flame hit {1}!",opponent.pbPartner.pbThis(true)))
      end
    end
    return ret
    #if @battle.doublebattle
    #for battlerChar in @battle.battlers
    #  if @battle.pbGetOwner(opponent.index) == @battle.pbGetOwner(battlerChar.index)
    #    damage = (battlerChar.totalhp/16).floor
    #    if damage>0
    #      @battle.scene.pbDamageAnimation(battlerChar,0)
    #      battlerChar.pbReduceHP(damage)
    #    end
    #  end
    #end
    #end
  end
end



################################################################################
# Power is doubled if the target is using Dive. (Surf)
################################################################################
class PokeBattle_Move_075 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if @battle.weather==PBWeather::NEWMOON
      return (basedmg*1.5).floor
    end
    
    if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target is using Dig. (Earthquake)
################################################################################
class PokeBattle_Move_076 < PokeBattle_Move
  def pbModifyDamage(damage,attacker,opponent)
    ret=damage
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCA # Dig
      ret=(damage*2.0).round
    end
    if !opponent.isInvulnerable? &&
       @battle.field.effects[PBEffects::GrassyTerrain]>0
      ret=(damage/2.0).round
    end
    return ret
  end
end



################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop.
################################################################################
class PokeBattle_Move_077 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
       opponent.effects[PBEffects::SkyDrop]
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop.
# May make the target flinch.
################################################################################
class PokeBattle_Move_078 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
  
  #def pbAdditionalEffect(attacker,opponent)
  #  if !isConst?(opponent.ability,PBAbilities,:INNERFOCUS) &&
  #     opponent.effects[PBEffects::Substitute]==0
  #    opponent.effects[PBEffects::Flinch]=true
  #    return true
  #  end
  #  return false
  #end

  def pbBaseDamage(damage,attacker,opponent)
    if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
       opponent.effects[PBEffects::SkyDrop]
      damage*=2
    end
    return damage
  end
end



################################################################################
# Power is doubled if the target has already used Fusion Flare this round.
################################################################################
class PokeBattle_Move_079 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @battle.field.effects[PBEffects::FusionBolt]
      @battle.field.effects[PBEffects::FusionBolt]=false
      @doubled=true
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent)
    @doubled=false
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      @battle.field.effects[PBEffects::FusionFlare]=true
    end
    return ret
  end

  def pbShowAnimation(id,attacker,opponent)
    if opponent.damagestate.critical || @doubled
      return super(id,attacker,opponent) # Charged anim
    end
    return super(id,attacker,opponent)
  end
end



################################################################################
# Power is doubled if the target has already used Fusion Bolt this round.
################################################################################
class PokeBattle_Move_07A < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @battle.field.effects[PBEffects::FusionFlare]
      @battle.field.effects[PBEffects::FusionFlare]=false
      @doubled=true
      return (damagemult*2.0).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent)
    @doubled=false
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      @battle.field.effects[PBEffects::FusionBolt]=true
    end
    return ret
  end

  def pbShowAnimation(id,attacker,opponent)
    if opponent.damagestate.critical || @doubled
      return super(id,attacker,opponent) # Charged anim
    end
    return super(id,attacker,opponent)
  end
end



################################################################################
# Power is doubled if the target is poisoned.
################################################################################
class PokeBattle_Move_07B < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status==PBStatuses::POISON &&
       opponent.effects[PBEffects::Substitute]==0
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target is paralyzed.  Cures the target of paralysis.
################################################################################
class PokeBattle_Move_07C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && 
       opponent.status==PBStatuses::PARALYSIS
      opponent.status=0
      @battle.pbDisplay(_INTL("{1} was healed of paralysis!",opponent.pbThis))
    end
    return ret
  end

  def pbModifyDamage(damage,attacker,opponent)
    if opponent.status==PBStatuses::PARALYSIS &&
       opponent.effects[PBEffects::Substitute]==0
      return damage*2
    end
    return damage
  end
end



################################################################################
# Power is doubled if the target is asleep.  Wakes the target up.
################################################################################
class PokeBattle_Move_07D < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && 
       opponent.status==PBStatuses::SLEEP
      opponent.status=0
      opponent.statusCount=0
      @battle.pbDisplay(_INTL("{1} woke up!",opponent.pbThis))
    end
    return ret
  end

  def pbModifyDamage(damage,attacker,opponent)
    if opponent.status==PBStatuses::SLEEP &&
       opponent.effects[PBEffects::Substitute]==0
      return damage*2
    end
    return damage
  end
end



################################################################################
# Power is doubled if the user is burned, poisoned or paralyzed.
################################################################################
class PokeBattle_Move_07E < PokeBattle_Move
  def pbModifyDamage(damage,attacker,opponent)
    if attacker.status==PBStatuses::BURN ||
       attacker.status==PBStatuses::POISON ||
       attacker.status==PBStatuses::PARALYSIS
      return damage*2
    end
    return damage
  end
end



################################################################################
# Power is doubled if the target has a status problem.
################################################################################
class PokeBattle_Move_07F < PokeBattle_Move
  def pbModifyDamage(damage,attacker,opponent)
    if opponent.status>0 && opponent.effects[PBEffects::Substitute]==0
      return damage*2
    end
    return damage
  end
end



################################################################################
# Power is doubled if the target's HP is down to 1/2 or less.
################################################################################
class PokeBattle_Move_080 < PokeBattle_Move
  def pbModifyDamage(damage,attacker,opponent)
    if opponent.hp<=opponent.totalhp/2
      return damage*2
    end
    return damage
  end
end



################################################################################
# Power is doubled if the user has lost HP due to the target's move this round.
################################################################################
class PokeBattle_Move_081 < PokeBattle_Move
  def pbModifyDamage(damage,attacker,opponent)
    if attacker.lastHPLost>0 && attacker.lastAttacker.include?(opponent.index)
      damage*=2
    end
    return damage
  end
end



################################################################################
# Power is doubled if the target has already lost HP this round.
################################################################################
class PokeBattle_Move_082 < PokeBattle_Move
  def pbModifyDamage(damage,attacker,opponent)
    if opponent.lastHPLost>0
      damage*=2
    end
    return damage
  end
end



################################################################################
# Power is doubled if the user's ally has already used this move this round.
# This move goes immediately after the ally, ignoring priority.
################################################################################
class PokeBattle_Move_083 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    ret=basedmg
    attacker.pbOwnSide.effects[PBEffects::Round].times do
      ret*=2
    end
    return ret
  end

  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      attacker.pbOwnSide.effects[PBEffects::Round]+=1
      if attacker.pbPartner && !attacker.pbPartner.hasMovedThisRound?
        if @battle.choices[attacker.pbPartner.index][0]==1 # Will use a move
          partnermove=@battle.choices[attacker.pbPartner.index][2]
          if partnermove.function==@function
            attacker.pbPartner.effects[PBEffects::MoveNext]=true
            attacker.pbPartner.effects[PBEffects::Quash]=false
          end
        end
      end
    end
    return ret
  end
end



################################################################################
# Power is doubled if the target has already moved this round.
################################################################################
class PokeBattle_Move_084 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if @battle.choices[opponent.index][0]!=1 || # Didn't choose a move
       opponent.hasMovedThisRound? # Used a move already
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if a user's teammate fainted last round.
################################################################################
class PokeBattle_Move_085 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::LastRoundFainted]>=0 &&
       attacker.pbOwnSide.effects[PBEffects::LastRoundFainted]==@battle.turncount-1
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the user has no held item.
################################################################################
class PokeBattle_Move_086 < PokeBattle_Move
  def pbModifyDamage(damage,attacker,opponent)
    if attacker.item(true)==0 || attacker.damagestate.gemused
      return damage*2
    end
    return damage
  end
end



################################################################################
# Power is doubled in weather.  Type changes depending on the weather.
################################################################################
class PokeBattle_Move_087 < PokeBattle_Move
  def pbType(type,attacker,opponent)
    weather=@battle.pbWeather
    type=getConst(PBTypes,:NORMAL) || 0
    type=(getConst(PBTypes,:FIRE) || type) if (weather==PBWeather::SUNNYDAY || weather==PBWeather::HARSHSUN)
    type=(getConst(PBTypes,:WATER) || type) if (weather==PBWeather::RAINDANCE || weather==PBWeather::HEAVYRAIN)
    type=(getConst(PBTypes,:ROCK) || type) if weather==PBWeather::SANDSTORM
    type=(getConst(PBTypes,:ICE)  || type) if weather==PBWeather::HAIL
    type=(getConst(PBTypes,:DARK)  || type) if weather==PBWeather::NEWMOON
    return type
  end

  def pbModifyDamage(damage,attacker,opponent)
    damage*=2 if @battle.pbWeather!=0
    return damage
  end
end



################################################################################
# Power is doubled if a foe tries to switch out.
################################################################################
class PokeBattle_Move_088 < PokeBattle_Move
  def pbModifyDamage(damage,attacker,opponent)
    damage*=2 if @battle.switching
    return damage
  end
end



################################################################################
# Power increases with the user's happiness.
################################################################################
class PokeBattle_Move_089 < PokeBattle_Move
  def pbBaseDamage(damage,attacker,opponent)
    return (attacker.happiness*2/5).floor
  end
end



################################################################################
# Power decreases with the user's happiness.
################################################################################
class PokeBattle_Move_08A < PokeBattle_Move
  def pbBaseDamage(damage,attacker,opponent)
    return ((255-attacker.happiness)*2/5).floor
  end
end



################################################################################
# Power increases with the user's HP.
################################################################################
class PokeBattle_Move_08B < PokeBattle_Move
  def pbBaseDamage(damage,attacker,opponent)
    damage=(150*attacker.hp/attacker.totalhp).floor
    damage=1 if damage<1
    return damage
  end
end



################################################################################
# Power increases with the target's HP.
################################################################################
class PokeBattle_Move_08C < PokeBattle_Move
  def pbBaseDamage(damage,attacker,opponent)
    damage=(120*opponent.hp/opponent.totalhp).floor
    damage=1 if damage<1
    return damage
  end
end



################################################################################
# Power increases the quicker the target is than the user.
################################################################################
class PokeBattle_Move_08D < PokeBattle_Move
  def pbBaseDamage(damage,attacker,opponent)
    damage=(25*opponent.pbSpeed/attacker.pbSpeed).floor
    damage=1 if damage<1
    damage=150 if damage>150
    return damage
  end
end



################################################################################
# Power increases with the user's positive stat changes (ignores negative ones).
################################################################################
class PokeBattle_Move_08E < PokeBattle_Move
  def pbBaseDamage(damage,attacker,opponent)
    multiplier=0
      for i in [PBStats::ATTACK,PBStats::DEFENSE,
                PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                PBStats::EVASION,PBStats::ACCURACY]
        if attacker.stages[i]>0
            multiplier = multiplier + attacker.stages[i]
          end
      end

    damage=(20*(multiplier+1)).floor
    return damage
  end
end



################################################################################
# Power increases with the target's positive stat changes (ignores negative ones).
################################################################################
class PokeBattle_Move_08F < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    multiplier=0
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      multiplier+=opponent.stages[i] if opponent.stages[i]>0
    end
    ret=20*(multiplier+3)
    ret=200 if ret>200
    return ret
  end
end



################################################################################
# Power and type depends on the user's IVs.
################################################################################
class PokeBattle_Move_090 < PokeBattle_Move
  def pbType(type,attacker,opponent)
    hp=pbHiddenPower(attacker.iv)
    return hp[0]
  end
=begin
  def pbBaseDamage(basedmg,attacker,opponent)
    hp=pbHiddenPower(attacker.iv)
    return hp[1]
  end
=end
end

def pbHiddenPower(iv)
  powermin=30
  powermax=70
  type=0; base=0
  types=[]
  for i in 0..PBTypes.maxValue
    types.push(i) if !PBTypes.isPseudoType?(i) && 
                     !isConst?(i,PBTypes,:NORMAL) && 
                     !isConst?(i,PBTypes,:SHADOW) && 
                     !isConst?(i,PBTypes,:FAIRY) && 
                     !isConst?(i,PBTypes,:CRYSTAL)
  end
  type|=(iv[0]&1)
  type|=(iv[1]&1)<<1
  type|=(iv[2]&1)<<2
  type|=(iv[3]&1)<<3
  type|=(iv[4]&1)<<4
  type|=(iv[5]&1)<<5
  type=(type*(types.length-1)/63).floor
  hptype=types[type]
  base|=(iv[0]&2)>>1
  base|=(iv[1]&2)
  base|=(iv[2]&2)<<1
  base|=(iv[3]&2)<<2
  base|=(iv[4]&2)<<3
  base|=(iv[5]&2)<<4
  base=(base*(powermax-powermin)/63).floor+powermin
  return [hptype,base]
end

################################################################################
# Power doubles for each consecutive use.
################################################################################
class PokeBattle_Move_091 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    basedmg<<=(attacker.effects[PBEffects::FuryCutter]-1) # effects[PBEffects::FuryCutter] can be 1 to 4
    return basedmg
  end
end



################################################################################
# Power doubles for each consecutive use.
################################################################################
class PokeBattle_Move_092 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    basedmg*=attacker.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] # can be 1 to 5
    return basedmg
  end
end



################################################################################
# Increases the user's Attack by 1 stage each time it loses HP due to a move.
################################################################################
class PokeBattle_Move_093 < PokeBattle_Move
# Handled in Battler class, do not edit!
end



################################################################################
# Randomly damages or heals the target.
################################################################################
class PokeBattle_Move_094 < PokeBattle_Move
  @calcbasedmg=0

  def pbEffect(attacker,opponent)
    random=@battle.pbRandom(256)
    basedmg=0
    if random<52
      if opponent.effects[PBEffects::HealBlock]>0
        @battle.pbDisplay(_INTL("Healing was negated by Heal Block!",opponent.pbThis))
      else
        if opponent.hp==opponent.totalhp
          @battle.pbDisplay(_INTL("{1}'s HP is full!",opponent.pbThis))   
        else
          @battle.pbAnimation(@id,attacker,opponent)
          opponent.pbRecoverHP((opponent.totalhp/4).floor)
          @battle.pbDisplay(_INTL("{1} had its HP restored.",opponent.pbThis))   
        end
      end
      return 0
    elsif random<154
      @calcbasedmg=40
    elsif random<240
      @calcbasedmg=80
    else
      @calcbasedmg=120
    end
    return super(attacker,opponent)
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return @calcbasedmg 
  end
end



################################################################################
# Power is chosen at random.  Power is doubled if the target is using Dig. (Magntitude)
################################################################################
class PokeBattle_Move_095 < PokeBattle_Move
  @calcbasedmg=0

  def pbOnStartUse(attacker)
    basedmg=[10,30,50,70,90,110,150]
    magnitudes=[
       0,
       1,1,
       2,2,2,2,
       3,3,3,3,3,3,
       4,4,4,4,
       5,5,
       6
    ]
    magni=magnitudes[@battle.pbRandom(magnitudes.length)]
    @calcbasedmg=basedmg[magni]
    magni+=4
    @battle.pbDisplay(_INTL("Magnitude {1}!",magni))
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    ret=@calcbasedmg
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCA # Dig
      ret*=2
    end
    if !opponent.isInvulnerable? &&
       @battle.field.effects[PBEffects::GrassyTerrain]>0
      ret=(ret/2.0).round
    end
    return ret
  end
end



################################################################################
# Power and type depend on the user's held berry. Destroys the berry.
################################################################################
class PokeBattle_Move_096 < PokeBattle_Move
  @berry=0

  def pbOnStartUse(attacker)
    if !pbIsBerry?(attacker.item) ||
       attacker.effects[PBEffects::Embargo]>0 ||
       @battle.field.effects[PBEffects::MagicRoom]>0 ||
       attacker.hasWorkingAbility(:KLUTZ)
       #attacker.pbOpposing1.hasWorkingAbility(:UNNERVE) ||
       #attacker.pbOpposing2.hasWorkingAbility(:UNNERVE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    @berry=attacker.item
    return true
  end
=begin
  def pbEffect(attacker,opponent)
    if attacker.item==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return 0
    end
    attacker.pokemon.itemRecycle=attacker.item
    attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
    attacker.item=0
    return super(attacker,opponent)
  end
=end

  def pbBaseDamage(basedmg,attacker,opponent)
    damagearray={
       60 => [:CHERIBERRY,:CHESTOBERRY,:PECHABERRY,:RAWSTBERRY,:ASPEARBERRY,
              :LEPPABERRY,:ORANBERRY,:PERSIMBERRY,:LUMBERRY,:SITRUSBERRY,
              :FIGYBERRY,:WIKIBERRY,:MAGOBERRY,:AGUAVBERRY,:IAPAPABERRY,
              :RAZZBERRY,:OCCABERRY,:PASSHOBERRY,:WACANBERRY,:RINDOBERRY,
              :YACHEBERRY,:CHOPLEBERRY,:KEBIABERRY,:SHUCABERRY,:COBABERRY,
              :PAYAPABERRY,:TANGABERRY,:CHARTIBERRY,:KASIBBERRY,:HABANBERRY,
              :COLBURBERRY,:BABIRIBERRY,:CHILANBERRY,:ROSELIBERRY],
       70 => [:BLUKBERRY,:NANABBERRY,:WEPEARBERRY,:PINAPBERRY,:POMEGBERRY,
              :KELPSYBERRY,:QUALOTBERRY,:HONDEWBERRY,:GREPABERRY,:TAMATOBERRY,
              :CORNNBERRY,:MAGOSTBERRY,:RABUTABERRY,:NOMELBERRY,:SPELONBERRY,
              :PAMTREBERRY],
       80 => [:WATMELBERRY,:DURINBERRY,:BELUEBERRY,:LIECHIBERRY,:GANLONBERRY,
              :SALACBERRY,:PETAYABERRY,:APICOTBERRY,:LANSATBERRY,:STARFBERRY,
              :ENIGMABERRY,:MICLEBERRY,:CUSTAPBERRY,:JACOBABERRY,:ROWAPBERRY,
              :KEEBERRY,:MARANGABERRY]
    }
    for i in damagearray.keys
      data=damagearray[i]
      if data
        for j in data
          if isConst?(@berry,PBItems,j)
            ret=i
            ret+=20
            return ret
          end
        end
      end
    end
    return 1
  end

  def pbType(type,attacker,opponent)
    typearray={
       :NORMAL   => [:CHILANBERRY],
       :FIRE     => [:CHERIBERRY,:BLUKBERRY,:WATMELBERRY,:OCCABERRY],
       :WATER    => [:CHESTOBERRY,:NANABBERRY,:DURINBERRY,:PASSHOBERRY],
       :ELECTRIC => [:PECHABERRY,:WEPEARBERRY,:BELUEBERRY,:WACANBERRY],
       :GRASS    => [:RAWSTBERRY,:PINAPBERRY,:RINDOBERRY,:LIECHIBERRY],
       :ICE      => [:ASPEARBERRY,:POMEGBERRY,:YACHEBERRY,:GANLONBERRY],
       :FIGHTING => [:LEPPABERRY,:KELPSYBERRY,:CHOPLEBERRY,:SALACBERRY],
       :POISON   => [:ORANBERRY,:QUALOTBERRY,:KEBIABERRY,:PETAYABERRY],
       :GROUND   => [:PERSIMBERRY,:HONDEWBERRY,:SHUCABERRY,:APICOTBERRY],
       :FLYING   => [:LUMBERRY,:GREPABERRY,:COBABERRY,:LANSATBERRY],
       :PSYCHIC  => [:SITRUSBERRY,:TAMATOBERRY,:PAYAPABERRY,:STARFBERRY],
       :BUG      => [:FIGYBERRY,:CORNNBERRY,:TANGABERRY,:ENIGMABERRY],
       :ROCK     => [:WIKIBERRY,:MAGOSTBERRY,:CHARTIBERRY,:MICLEBERRY],
       :GHOST    => [:MAGOBERRY,:RABUTABERRY,:KASIBBERRY,:CUSTAPBERRY],
       :DRAGON   => [:AGUAVBERRY,:NOMELBERRY,:HABANBERRY,:JACOBABERRY],
       :DARK     => [:IAPAPABERRY,:SPELONBERRY,:COLBURBERRY,:ROWAPBERRY,:MARANGABERRY],
       :STEEL    => [:RAZZBERRY,:PAMTREBERRY,:BABIRIBERRY],
       :FAIRY    => [:ROSELIBERRY,:KEEBERRY]
    }
    for i in typearray.keys
      data=typearray[i]
      if data
        for j in data
          if isConst?(@berry,PBItems,j)
            return getConst(PBTypes,i)
          end
        end
      end
    end
    return getConst(PBTypes,:NORMAL)
  end
  
  def pbEffectAfterHit(attacker,opponent,turneffects)
    if turneffects[PBEffects::TotalDamage]>0
      attacker.pbConsumeItem
    end
  end
end



################################################################################
# Power increases the less PP this move has.
################################################################################
class PokeBattle_Move_097 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    dmgs=[200,80,60,50,40]
    ppleft=[@pp,4].min
    basedmg=dmgs[ppleft]
    return basedmg
  end
end



################################################################################
# Power increases the less HP the user has.
################################################################################
class PokeBattle_Move_098 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=(48*attacker.hp/attacker.totalhp).floor
    basedmg=20
    basedmg=40 if n<33
    basedmg=80 if n<17
    basedmg=100 if n<10
    basedmg=150 if n<5
    basedmg=200 if n<2
    return basedmg
  end
end



################################################################################
# Power increases the quicker the user is than the target.
################################################################################
class PokeBattle_Move_099 < PokeBattle_Move
  def pbBaseDamage(damage,attacker,opponent)
    n=(attacker.pbSpeed/opponent.pbSpeed).floor
    basedmg=40
    basedmg=60 if n>=1
    basedmg=80 if n>=2
    basedmg=120 if n>=3
    basedmg=150 if n>=4
    return basedmg
  end
end



################################################################################
# Power increases the heavier the target is.
################################################################################
class PokeBattle_Move_09A < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    weight=opponent.weight(attacker)
    basedmg=20
    basedmg=40 if weight>100
    basedmg=60 if weight>250
    basedmg=80 if weight>500
    basedmg=100 if weight>1000
    basedmg=120 if weight>2000
    return basedmg
  end
end



################################################################################
# Power increases the heavier the user is than the target. Doubles damage and
# has perfect accuracy against Minimize foes.
################################################################################
class PokeBattle_Move_09B < PokeBattle_Move
  def pbBaseDamage(damage,attacker,opponent)
    attweight=attacker.weight
    oppweight=opponent.weight(attacker)
    n=(attweight/oppweight).floor
    basedmg=40
    basedmg=60 if n>=2
    basedmg=80 if n>=3
    basedmg=100 if n>=4
    basedmg=120 if n>=5
    return basedmg
  end
  
  def tramplesMinimize?(param=1)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end



################################################################################
# Powers up the ally's attack this round by 1.5.
################################################################################
class PokeBattle_Move_09C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbPartner.hp>0 && !attacker.pbPartner.effects[PBEffects::HelpingHand]
      attacker.pbPartner.effects[PBEffects::HelpingHand]=true
      @battle.pbAnimation(@id,attacker,attacker.pbPartner)
      @battle.pbDisplay(_INTL("{1} is ready to help {2}!",attacker.pbThis,attacker.pbPartner.pbThis(true)))
      return 0
    else
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
  end
end



################################################################################
# Weakens Electric attacks.
################################################################################
class PokeBattle_Move_09D < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.field.effects[PBEffects::MudSportField]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    @battle.field.effects[PBEffects::MudSportField]=5
    @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
    return 0
    #if attacker.effects[PBEffects::MudSport]
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    #else
    #  @battle.pbAnimation(@id,attacker,nil)
    #  attacker.effects[PBEffects::MudSport]=true
    # @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
    #  return 0
    #end
  end
end



################################################################################
# Weakens Fire attacks.
################################################################################
class PokeBattle_Move_09E < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.field.effects[PBEffects::WaterSportField]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    @battle.field.effects[PBEffects::WaterSportField]=5
    @battle.pbDisplay(_INTL("Fire's power was weakened!"))
    return 0
    #if attacker.effects[PBEffects::WaterSport]
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    #else
    #  @battle.pbAnimation(@id,attacker,nil)
    #  attacker.effects[PBEffects::WaterSport]=true
    #  @battle.pbDisplay(_INTL("Fire's power was weakened!"))
    #  return 0
    #end
  end
end



################################################################################
# Type depends on the user's held item.
################################################################################
class PokeBattle_Move_09F < PokeBattle_Move
  def pbType(type,attacker,opponent)
    if isConst?(@id,PBMoves,:JUDGMENT)
      return getConst(PBTypes,:FIGHTING) if isConst?(attacker.item,PBItems,:FISTPLATE)
      return getConst(PBTypes,:FLYING)   if isConst?(attacker.item,PBItems,:SKYPLATE)
      return getConst(PBTypes,:POISON)   if isConst?(attacker.item,PBItems,:TOXICPLATE)
      return getConst(PBTypes,:GROUND)   if isConst?(attacker.item,PBItems,:EARTHPLATE)
      return getConst(PBTypes,:ROCK)     if isConst?(attacker.item,PBItems,:STONEPLATE)
      return getConst(PBTypes,:BUG)      if isConst?(attacker.item,PBItems,:INSECTPLATE)
      return getConst(PBTypes,:GHOST)    if isConst?(attacker.item,PBItems,:SPOOKYPLATE)
      return getConst(PBTypes,:STEEL)    if isConst?(attacker.item,PBItems,:IRONPLATE)
      return getConst(PBTypes,:FIRE)     if isConst?(attacker.item,PBItems,:FLAMEPLATE)
      return getConst(PBTypes,:WATER)    if isConst?(attacker.item,PBItems,:SPLASHPLATE)
      return getConst(PBTypes,:GRASS)    if isConst?(attacker.item,PBItems,:MEADOWPLATE)
      return getConst(PBTypes,:ELECTRIC) if isConst?(attacker.item,PBItems,:ZAPPLATE)
      return getConst(PBTypes,:PSYCHIC)  if isConst?(attacker.item,PBItems,:MINDPLATE)
      return getConst(PBTypes,:ICE)      if isConst?(attacker.item,PBItems,:ICICLEPLATE)
      return getConst(PBTypes,:DRAGON)   if isConst?(attacker.item,PBItems,:DRACOPLATE)
      return getConst(PBTypes,:FAIRY)   if isConst?(attacker.item,PBItems,:PIXIEPLATE)
      return getConst(PBTypes,:DARK)     if isConst?(attacker.item,PBItems,:DREADPLATE)
    elsif isConst?(@id,PBMoves,:TECHNOBLAST)
      return getConst(PBTypes,:ELECTRIC) if isConst?(attacker.item,PBItems,:SHOCKDRIVE)
      return getConst(PBTypes,:FIRE)     if isConst?(attacker.item,PBItems,:BURNDRIVE)
      return getConst(PBTypes,:ICE)      if isConst?(attacker.item,PBItems,:CHILLDRIVE)
      return getConst(PBTypes,:WATER)    if isConst?(attacker.item,PBItems,:DOUSEDRIVE)
    end
    return getConst(PBTypes,:NORMAL)
  end
  
end



################################################################################
# This attack is always a critical hit, if successful.
################################################################################
class PokeBattle_Move_0A0 < PokeBattle_Move
# Handled in superclass, do not edit!
end



################################################################################
# For 5 rounds, foes' attacks cannot become critical hits.
################################################################################
class PokeBattle_Move_0A1 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::LuckyChant]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      attacker.pbOwnSide.effects[PBEffects::LuckyChant]=5
      @battle.pbAnimation(@id,attacker,nil,true)
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The Lucky Chant shielded your team from critical hits!"))
      else
        @battle.pbDisplay(_INTL("The Lucky Chant shielded the foe's team from critical hits!"))
      end  
    end
  end
end



################################################################################
# For 5 rounds, lowers power of physical attacks against the user's side.
################################################################################
class PokeBattle_Move_0A2 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::Reflect]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      attacker.pbOwnSide.effects[PBEffects::Reflect]=5
      attacker.pbOwnSide.effects[PBEffects::Reflect]=8 if isConst?(attacker.item,PBItems,:LIGHTCLAY)
      @battle.pbAnimation(@id,attacker,nil,true)
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("Ally's Reflect raised Defense!"))
      else
        @battle.pbDisplay(_INTL("Foe's Reflect raised Defense!"))
      end  
    end
  end
end



################################################################################
# For 5 rounds, lowers power of special attacks against the user's side.
################################################################################
class PokeBattle_Move_0A3 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      attacker.pbOwnSide.effects[PBEffects::LightScreen]=5
      attacker.pbOwnSide.effects[PBEffects::LightScreen]=8 if isConst?(attacker.item,PBItems,:LIGHTCLAY)
      @battle.pbAnimation(@id,attacker,nil,true)
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("Ally's Light Screen raised Special Defense!"))
      else
        @battle.pbDisplay(_INTL("Foe's Light Screen raised Special Defense!"))
      end  
    end
  end
end



################################################################################
# Effect depends on the environment.
################################################################################
class PokeBattle_Move_0A4 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if @battle.field.effects[PBEffects::ElectricTerrain]>0
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
        @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
      end
      return
    elsif @battle.field.effects[PBEffects::GrassyTerrain]>0
      if opponent.pbCanSleep?(attacker,false,self,false)
        opponent.pbSleep
        @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
      end
      return
    elsif @battle.field.effects[PBEffects::MistyTerrain]>0
      if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
        opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker,self)
      end
      return
    end
    case @battle.environment
    when PBEnvironment::Grass, PBEnvironment::TallGrass, PBEnvironment::Forest
      if opponent.pbCanSleep?(attacker,false,self,false)
        opponent.pbSleep
        @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
      end
    when PBEnvironment::MovingWater, PBEnvironment::Underwater
      if opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
        opponent.pbReduceStat(PBStats::ATTACK,1,true,@id,attacker,self)
      end
    when PBEnvironment::StillWater, PBEnvironment::Sky
      if opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
        opponent.pbReduceStat(PBStats::SPEED,1,true,@id,attacker,self)
      end
    when PBEnvironment::Sand
      if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
        opponent.pbReduceStat(PBStats::ACCURACY,1,true,@id,attacker,self)
      end
    when PBEnvironment::Rock
      if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker,false,self)
        opponent.pbReduceStat(PBStats::ACCURACY,1,true,@id,attacker,self)
      end
    when PBEnvironment::Cave, PBEnvironment::Space
      if opponent.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(attacker)
        opponent.pbFlinch(attacker)
      end
    when PBEnvironment::Snow
      if opponent.pbCanFreeze?(attacker,false,self)
        opponent.pbFreeze
        @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      end
    when PBEnvironment::Volcano
      if opponent.pbCanBurn?(attacker,false,self)
        opponent.pbBurn(attacker)
        @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
      end
    else
      if opponent.pbCanParalyze?(attacker,false,self)
        opponent.pbParalyze(attacker)
        @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
      end
    end
  end

  def pbShowAnimation(id,attacker,opponent)
    id=getConst(PBMoves,:BODYSLAM)
    if @battle.field.effects[PBEffects::ElectricTerrain]>0
      id=getConst(PBMoves,:THUNDERSHOCK) || id
    elsif @battle.field.effects[PBEffects::GrassyTerrain]>0
      id=getConst(PBMoves,:VINEWHIP) || id
    elsif @battle.field.effects[PBEffects::MistyTerrain]>0
      id=getConst(PBMoves,:FAIRYWIND) || id
    else
      case @battle.environment
      when PBEnvironment::Grass, 
        PBEnvironment::TallGrass;      id=getConst(PBMoves,:VINEWHIP) || id
      when PBEnvironment::MovingWater; id=getConst(PBMoves,:WATERPULSE) || id
      when PBEnvironment::StillWater;  id=getConst(PBMoves,:MUDSHOT) || id
      when PBEnvironment::Underwater;  id=getConst(PBMoves,:WATERPULSE) || id
      when PBEnvironment::Cave;        id=getConst(PBMoves,:ROCKTHROW) || id
      when PBEnvironment::Rock;        id=getConst(PBMoves,:MUDSLAP) || id
      when PBEnvironment::Sand;        id=getConst(PBMoves,:MUDSLAP) || id
      when PBEnvironment::Forest;      id=getConst(PBMoves,:RAZORLEAF) || id
      when PBEnvironment::Snow;        id=getConst(PBMoves,:AVALANCHE) || id
      when PBEnvironment::Volcano;     id=getConst(PBMoves,:INCINERATE) || id
      when PBEnvironment::Sky;         id=getConst(PBMoves,:GUST) || id
      when PBEnvironment::Space;       id=getConst(PBMoves,:SWIFT) || id
      end
    end
    return super(id,attacker,opponent,showanimation) # Environment-specific anim
  end
end
    
    #case @battle.environment
    #  when PBEnvironment::None
    #   return false if !opponent.pbCanParalyze?(false)
    #   opponent.pbParalyze(attacker)
    #   @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
    #  when PBEnvironment::Grass || PBEnvironment::TallGrass
    #    return false if !opponent.pbCanSleep?(attacker,false)
    #    opponent.pbSleep
    #    @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))   
    #  when PBEnvironment::MovingWater
    #    return false if !opponent.pbReduceStat(PBStats::ATTACK,1,false)
    #   @battle.pbDisplay(_INTL("{1}'s Attack fell!",opponent.pbThis))
    #  when PBEnvironment::StillWater
    #    return false if !opponent.pbReduceStat(PBStats::SPEED,1,false)
    #    @battle.pbDisplay(_INTL("{1}'s Speed fell!",opponent.pbThis))
    #  when PBEnvironment::Underwater
    #    return false if !opponent.pbReduceStat(PBStats::DEFENSE,1,false)
    #    @battle.pbDisplay(_INTL("{1}'s Defense fell!",opponent.pbThis))
    #  when PBEnvironment::Cave
    #    return false if isConst?(opponent.ability,PBAbilities,:INNERFOCUS) ||
    #       opponent.effects[PBEffects::Substitute]>0
    #    opponent.effects[PBEffects::Flinch]=true
    #  when PBEnvironment::Rock || PBEnvironment::Sand
    #    return false if !opponent.pbReduceStat(PBStats::ACCURACY,1,false)
    #    @battle.pbDisplay(_INTL("{1}'s accuracy fell!",opponent.pbThis))
    #  else
    #    return false
    #end
    #return true



################################################################################
# Always hits.
################################################################################
class PokeBattle_Move_0A5 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end
end



################################################################################
# User's attack next round against the target will definitely hit.
################################################################################
class PokeBattle_Move_0A6 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    opponent.effects[PBEffects::LockOn]=2
    opponent.effects[PBEffects::LockOnPos]=attacker.index
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} took aim at {2}!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Target's evasion stat changes are ignored from now on.
# Normal and Fighting moves have normal effectiveness against the Ghost-type target.
################################################################################
class PokeBattle_Move_0A7 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    opponent.effects[PBEffects::Foresight]=true
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} was identified!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Target's evasion stat changes are ignored from now on.
# Psychic moves have normal effectiveness against the Dark-type target.
################################################################################
class PokeBattle_Move_0A8 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    opponent.effects[PBEffects::MiracleEye]=true
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} was identified!",opponent.pbThis))
    return 0
  end
end



################################################################################
# This move ignores target's Defense, Special Defense and evasion stat changes.
################################################################################
class PokeBattle_Move_0A9 < PokeBattle_Move
# Handled in superclass, do not edit!
end



################################################################################
# User is protected against moves with the "B" flag this round. (Protect, Detect)
################################################################################
class PokeBattle_Move_0AA < PokeBattle_Move
  def pbEffect(attacker,opponent)
    protectlist=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C   # Spiky Shield
    ]
    if !protectlist.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved ||
       @battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.effects[PBEffects::Protect]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User's side is protected against moves with priority greater than 0 this round.
################################################################################
class PokeBattle_Move_0AB < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::QuickGuard]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    protectlist=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C   # Spiky Shield
    ]
    if !protectlist.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved #|| (@battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor)
      #attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.pbOwnSide.effects[PBEffects::QuickGuard]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Quick Guard protected your team!"))
    else
      @battle.pbDisplay(_INTL("Quick Guard protected the opposing team!"))
    end
    return 0
  end
end



################################################################################
# User's side is protected against moves that target multiple battlers this round.
################################################################################
class PokeBattle_Move_0AC < PokeBattle_Move
def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::WideGuard]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    protectlist=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C   # Spiky Shield
    ]
    if !protectlist.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved #||
       #(@battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor)
      #attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.pbOwnSide.effects[PBEffects::WideGuard]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Wide Guard protected your team!"))
    else
      @battle.pbDisplay(_INTL("Wide Guard protected the opposing team!"))
    end
    return 0
  end
end



################################################################################
# Ignores target's protections.  If successful, all other moves this round
# ignore them too.
################################################################################
class PokeBattle_Move_0AD < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    opponent.effects[PBEffects::ProtectNegation]=true if ret
    opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false if ret
    return ret
  end
end



################################################################################
# Uses the last move that targeted the user.
################################################################################
class PokeBattle_Move_0AE < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::MirrorMove]<=0
      @battle.pbDisplay(_INTL("The mirror move failed!"))
      return -1
    end
    blacklist=[
         :FAIRYTEMPEST,
         :DYNAMICFURY,
         :AURABLAST,
         :DARKNOVA
    ]
    found=false
    if opponent.lastMoveUsed > 0
      for i in blacklist
        if isConst?(opponent.lastMoveUsed,PBMoves,i)
          found=true
        end
      end
    end
    if opponent.lastMoveUsed<=0 || found
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbUseMoveSimple(attacker.effects[PBEffects::MirrorMove])
    return 0
  end
end



################################################################################
# Uses the last move that was used.
################################################################################
class PokeBattle_Move_0AF < PokeBattle_Move
  def pbEffect(attacker,opponent)
      blacklist=[
         :STRUGGLE,
         :TRANSFORM,
         :COUNTER,
         :MIRRORCOAT,
         :METALBURST,
         :HELPINGHAND,
         :DETECT,
         :PROTECT,
         :FEINT,
         :MIRRORMOVE,
         :COPYCAT,
         :SNATCH,
         :DESTINYBOND,
         :ENDURE,
         :CIRCLETHROW,
         :DRAGONTAIL,
         :COVET,
         :THIEF,
         :SWITCHEROO,
         :TRICK,
         :BESTOW,    
         :FOCUSPUNCH,
         :FOLLOWME,
         :RAGEPOWDER,
         :BELCH,
         :BOUNCE,
         :DIG,
         :DIVE,
         :FLY,
         :SHADOWFORCE,
         :PHANTOMFORCE,
         :SKULLBASH,
         :SKYATTACK,
         :SOLARBEAM,
         :LUNARCANNON,
         :RAZORWIND,
         :GEOMANCY,
         :SKYDROP,
         :SPIRITAWAY,
         :FREEZESHOCK,
         :ICEBURN,
         :FAIRYTEMPEST,
         :DYNAMICFURY,
         :AURABLAST,
         :DARKNOVA
    ]
    
    found=false
    if @battle.lastMoveUsed > 0
      for i in blacklist
        if isConst?(@battle.lastMoveUsed,PBMoves,i)
          found=true
        end
      end
    end
    if @battle.lastMoveUsed<=0 || found
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbUseMoveSimple(@battle.lastMoveUsed)
    
    return 0
  end
end



################################################################################
# Uses the move the target was about to use this round, with 1.5x power.
################################################################################
class PokeBattle_Move_0B0 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    blacklist=[
       0x02,    # Struggle
       0x14,    # Chatter
       0x71,    # Counter
       0x72,    # Mirror Coat
       0x73,    # Metal Burst
       0xB0,    # Me First
       0xF1,    # Covet, Thief
       0x115,   # Focus Punch
       0x174,   # Belch
       0x214,   # Fairy Tempest
       0x215,   # Dynamic Fury
       0x216,   # Aura Blast
       0x217    # Dark Nova
    ]
    oppmove=@battle.choices[opponent.index][2]
    if @battle.choices[opponent.index][0]!=1 || # Didn't choose a move
       opponent.hasMovedThisRound? ||
       !oppmove || oppmove.id<=0 ||
       oppmove.pbIsStatus? ||
       blacklist.include?(oppmove.function)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.effects[PBEffects::MeFirst]=true
    attacker.pbUseMoveSimple(oppmove.id)
    attacker.effects[PBEffects::MeFirst]=false
    return 0
  end
end



################################################################################
# This round, reflects all moves with the "C" flag targeting the user back at
# their origin.
################################################################################
class PokeBattle_Move_0B1 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    @battle.pbAnimation(@id,attacker,nil)
    attacker.effects[PBEffects::MagicCoat]=true
    @battle.pbDisplay(_INTL("{1} shrouded itself in Magic Coat!",attacker.pbThis))
    return 0
  end
end



################################################################################
# This round, snatches all used moves with the "D" flag.
################################################################################
class PokeBattle_Move_0B2 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    # TODO: Fails if attacker is last in priority
    attacker.effects[PBEffects::Snatch]=true
    @battle.pbAnimation(@id,attacker,nil)
    if @battle.doublebattle
      @battle.pbDisplay(_INTL("{1} waits for a target to make a move!",attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} waits for its foe to make a move!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Uses a different move depending on the environment.
################################################################################
class PokeBattle_Move_0B3 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    move=getConst(PBMoves,:TRIATTACK) || 0
    case @battle.environment
    when PBEnvironment::Grass, PBEnvironment::TallGrass, PBEnvironment::Forest
      move=getConst(PBMoves,:ENERGYBALL) || move
    when PBEnvironment::MovingWater; move=getConst(PBMoves,:HYDROPUMP) || move
    when PBEnvironment::StillWater;  move=getConst(PBMoves,:MUDBOMB) || move
    when PBEnvironment::Underwater;  move=getConst(PBMoves,:HYDROPUMP) || move
    when PBEnvironment::Cave;        move=getConst(PBMoves,:POWERGEM) || move
    when PBEnvironment::Rock;        move=getConst(PBMoves,:EARTHPOWER) || move
    when PBEnvironment::Sand;        move=getConst(PBMoves,:EARTHPOWER) || move
    when PBEnvironment::Snow;        move=getConst(PBMoves,:FROSTBREATH) || move
    when PBEnvironment::Volcano;     move=getConst(PBMoves,:LAVAPLUME) || move
    when PBEnvironment::Sky;         move=getConst(PBMoves,:AIRSLASH) || move
    when PBEnvironment::Space;       move=getConst(PBMoves,:DRACOMETEOR) || move
    end
    if @battle.field.effects[PBEffects::ElectricTerrain]>0
      move=getConst(PBMoves,:THUNDERBOLT) || move
    elsif @battle.field.effects[PBEffects::GrassyTerrain]>0
      move=getConst(PBMoves,:ENERGYBALL) || move
    elsif @battle.field.effects[PBEffects::MistyTerrain]>0
      move=getConst(PBMoves,:MOONBLAST) || move
    end
    if move==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    thismovename=PBMoves.getName(@id)
    movename=PBMoves.getName(move)
    @battle.pbDisplay(_INTL("{1} turned into {2}!",thismovename,movename))
    #target=(USENEWBATTLEMECHANICS && opponent) ? opponent.index : -1
    attacker.pbUseMoveSimple(move)
    return 0
    
    
    #move=0
    #case @battle.environment
    #  when PBEnvironment::None
    #    move=getConst(PBMoves,:TRIATTACK) || 0
    #  when PBEnvironment::Grass || PBEnvironment::TallGrass
    #    move=getConst(PBMoves,:SEEDBOMB) || 0
    #  when @battle.grassyterrain
    #    move=getConst(PBMoves,:ENERGYBALL) || 0
    #    when @battle.electricterrain
    #    move=getConst(PBMoves,:THUNDERBOLT) || 0
    #    when @battle.mistyterrain
    #    move=getConst(PBMoves,:MOONBLAST) || 0
    #  when PBEnvironment::MovingWater, PBEnvironment::Underwater
    #    move=getConst(PBMoves,:HYDROPUMP) || 0
    #  when PBEnvironment::StillWater
    #    move=getConst(PBMoves,:MUDBOMB) || 0
    #  when PBEnvironment::Rock, PBEnvironment::Sand
    #    move=getConst(PBMoves,:EARTHQUAKE) || 0
    #  when PBEnvironment::Cave
    #    move=getConst(PBMoves,:ROCKSLIDE) || 0
    #end
    #if move==0
    #  move=getConst(PBMoves,:TRIATTACK) || 0 
    #end
    #if move==0
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    #end
    #thismovename=PBMoves.getName(@id)
    #movename=PBMoves.getName(move)
    #@battle.pbDisplay(_INTL("{1} turned into {2}!",thismovename,movename))
    #attacker.pbUseMoveSimple(move)
    #return 0
  end
end



################################################################################
# Uses a random move the user knows.  Fails if user is not asleep.
################################################################################
class PokeBattle_Move_0B4 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.status!=PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    blacklist=[
       :ASSIST,
       :BIDE,
       :CHATTER,
       :COPYCAT,
       :FOCUSPUNCH,
       :MEFIRST,
       :METRONOME,
       :MIMIC,
       :MIRRORMOVE,
       :NATUREPOWER,
       :SKETCH,
       :SLEEPTALK,
       :STRUGGLE,
       :UPROAR,
       :FAIRYTEMPEST,
       :DYNAMICFURY,
       :AURABLAST,
       :DARKNOVA,
# Two-turn attacks
       :BOUNCE,
       :DIG,
       :DIVE,
       :FLY,
       :SHADOWFORCE,
       :PHANTOMFORCE,
       :SKYDROP,
       :SPIRITAWAY,
       :SKULLBASH,
       :SKYATTACK,
       :SOLARBEAM,
       :LUNARCANNON,
       :RAZORWIND,
       :GEOMANCY,
# Zeta/Omicron shit
       :ADAPT,
       :RAGESTATE,
       :DEVOUR,
       :TESSERACT,
       :DARKEPITAPH,
       :RENAISSANCE,
       :SOULWRECKER,
       :INFERNALRAGE,
       :ABYSSALCRUSH,
       :FORESTSURGE,
       :TITANICFORCE,
       :NERVALCUT,
       :OMNIFIST,
       :VOIDCALLER,
       :DRAGONFLUX,
       :RAZORSTORM,
       :EPICENTER,
       :ECHOLOCATION,
       :FLASHFREEZE,
       :PERMAFROST,
       :MEDUSARAY,
       :POWERSHRINE,
       :SPECIALSHRINE,
       :DRADESTORM,
       :ANGELWINGS,
       :FUMBLE,
       :SILVERFORCE,
       :VENUSFORCE,
       :EARTHFORCE,
       :MARSFORCE,
       :ZEUSFORCE,
       :SATURNFORCE,
       :CLOUDFORCE,
       :PLUTOFORCE,
       :LUNAFORCE,
       :GRAVIFORCE,
       :FAIRYFORCE,
       :FAIRYFYRE,
       :BULLETHAIL,
       :SOLARCHARGE,
       :WORMHOLE,
       :DARKSONATA,
       :KARMASURGE,
       :KARMASOW,
       :KARMAREAP,
       :RAGNAROK
    ]
    choices=[]
    for i in 0..3
      found=false
      next if attacker.moves[i].id==0
      for j in 0...blacklist.length
        found=true if isConst?(attacker.moves[i].id,PBMoves,blacklist[j])
      end
      next if found
      choices[choices.length]=i if @battle.pbCanChooseMove?(attacker.index,i,false)
    end
    if choices.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    choice=choices[@battle.pbRandom(choices.length)]
    attacker.pbUseMoveSimple(attacker.moves[choice].id,choice)
    return 0
  end
end



################################################################################
# Uses a random move known by any non-user Pokémon in the user's party.
################################################################################
class PokeBattle_Move_0B5 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    moves=[]
    blacklist=[
       :ASSIST,
       :CHATTER,
       :CIRCLETHROW,
       :COPYCAT,
       :COUNTER,
       :COVET,
       :DESTINYBOND,
       :DETECT,
       :DRAGONTAIL,
       :ENDURE,
       :FEINT,
       :FOCUSPUNCH,
       :FOLLOWME,
       :HELPINGHAND,
       :MEFIRST,
       :METRONOME,
       :MIMIC,
       :MIRRORCOAT,
       :MIRRORMOVE,
       :NATUREPOWER,
       :PROTECT,
       :RAGEPOWDER,
       :SKETCH,
       :SLEEPTALK,
       :SNATCH,
       :STRUGGLE,
       :SWITCHEROO,
       :THIEF,
       :TRANSFORM,
       :TRICK,
       :SILVERFORCE,
       :VENUSFORCE,
       :EARTHFORCE,
       :MARSFORCE,
       :ZEUSFORCE,
       :SATURNFORCE,
       :CLOUDFORCE,
       :PLUTOFORCE,
       :LUNAFORCE,
       :GRAVIFORCE,
       :DARKSONATA,
       :FAIRYTEMPEST,
       :DYNAMICFURY,
       :AURABLAST,
       :DARKNOVA,
# Shadow moves
       :SHADOWBLAST,
       :SHADOWBLITZ,
       :SHADOWBOLT,
       :SHADOWBREAK,
       :SHADOWCHILL,
       :SHADOWDOWN,
       :SHADOWEND,
       :SHADOWFIRE,
       :SHADOWHALF,
       :SHADOWHOLD,
       :SHADOWMIST,
       :SHADOWPANIC,
       :SHADOWRAVE,
       :SHADOWRUSH,
       :SHADOWSHED,
       :SHADOWSKY,
       :SHADOWSTORM,
       :SHADOWWAVE,
       :HEARTSWAP
    ]
    party=@battle.pbParty(attacker.index) # NOTE: pbParty is common to both allies in multi battles
    for i in 0...party.length
      if i!=attacker.pokemonIndex && party[i]
        for j in party[i].moves
          found=false
          for k in blacklist
            if j.id==0 || isConst?(j.id,PBMoves,k)
              found=true
              break
            end
          end
          moves[moves.length]=j.id if !found
        end
      end
    end
    if moves.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    move=moves[@battle.pbRandom(moves.length)]
    attacker.pbUseMoveSimple(move)
    return 0
  end
end



################################################################################
# Uses a random move that exists.
################################################################################
class PokeBattle_Move_0B6 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    blacklist=[
       :ASSIST,
       :BIDE,
       :CHATTER,
       :COPYCAT,
       :FOCUSPUNCH,
       :MEFIRST,
       :METRONOME,
       :MIMIC,
       :MIRRORMOVE,
       :NATUREPOWER,
       :SKETCH,
       :SLEEPTALK,
       :STRUGGLE,
       :UPROAR,
       :FAIRYTEMPEST,
       :DYNAMICFURY,
       :AURABLAST,
       :DARKNOVA,
       :INSURGENCY,
       :BANISHMENT,
       :REGURGITATION,
       :HOLLOWBREATH,
       :MIDNIGHTSTRIKE,
       :RECOLLECTION,
# Two-turn attacks
       :BOUNCE,
       :DIG,
       :DIVE,
       :FLY,
       :SHADOWFORCE,
       :PHANTOMFORCE,
       :SKYDROP,
       :SPIRITAWAY,
       :SKULLBASH,
       :SKYATTACK,
       :SOLARBEAM,
       :LUNARCANNON,
       :RAZORWIND,
       :GEOMANCY,
# Zeta/Omicron shit
       :ADAPT,
       :RAGESTATE,
       :DEVOUR,
       :TESSERACT,
       :DARKEPITAPH,
       :RENAISSANCE,
       :SOULWRECKER,
       :INFERNALRAGE,
       :ABYSSALCRUSH,
       :FORESTSURGE,
       :TITANICFORCE,
       :NERVALCUT,
       :OMNIFIST,
       :VOIDCALLER,
       :DRAGONFLUX,
       :RAZORSTORM,
       :ZOMBIESTRIKE,
       :CUSTOMMOVE,
       :EPICENTER,
       :ECHOLOCATION,
       :FLASHFREEZE,
       :POWERSHRINE,
       :SPECIALSHRINE,
       :DRADESTORM,
       :ANGELWINGS,
       :FUMBLE,
       :SILVERFORCE,
       :VENUSFORCE,
       :EARTHFORCE,
       :MARSFORCE,
       :ZEUSFORCE,
       :SATURNFORCE,
       :CLOUDFORCE,
       :PLUTOFORCE,
       :LUNAFORCE,
       :GRAVIFORCE,
       :FAIRYFORCE,
       :FAIRYFYRE,
       :TERRAFORCE,
       :BULLETHAIL,
       :SOLARCHARGE,
       :DARKSONATA,
       :KARMASURGE,
       :KARMASOW,
       :KARMAREAP,
       :RAGNAROK,
# Shadow moves
       :SHADOWHEAT,
       :SHADOWSURF,
       :SHADOWGALE,
       :SHADOWSWORD,
       :SHADOWWRATH,
       :SHADOWCRUSH,
       :SHADOWEND,
       :SHADOWSTORM,
       :SHADOWBLAST,
       :SHADOWBOLT,
       :SHADOWBREAK,
       :SHADOWCHILL,
       :SHADOWFIRE,
       :SHADOWRAVE,
       :SHADOWRUSH,
       :SHADOWWAVE,
       :SHADOWBLITZ,
       :SHADOWDOWN,
       :SHADOWHALF,
       :SHADOWHOLD,
       :SHADOWMIST,
       :SHADOWPANIC,
       :SHADOWSHED,
       :SHADOWSKY
    ]
    loop do
      move=@battle.pbRandom(PBMoves.maxValue)+1
      found=false
      for i in blacklist
        if isConst?(move,PBMoves,i)
          found=true
          break
        end
      end
      if !found
        attacker.pbUseMoveSimple(move)
        break
      end
    end
    return 0
  end
end



################################################################################
# The target can no longer use the same move twice in a row.
################################################################################
class PokeBattle_Move_0B7 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Torment]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker
      if opponent.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    opponent.effects[PBEffects::Torment]=true
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} was subjected to Torment!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Disables all target's moves that the user also knows.
################################################################################
class PokeBattle_Move_0B8 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::Imprison]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1  
    end
    #found=false
    for i in 0...attacker.moves.length
      next if attacker.moves[i].id==0
      if attacker.pbOpposing1.hp>0
        for j in 0...attacker.pbOpposing1.moves.length
          m=attacker.pbOpposing1.moves[j]
          #found=true if m.id==attacker.moves[i].id
        end
      end
      if attacker.pbOpposing2.hp>0
        for j in 0...attacker.pbOpposing2.moves.length
          m=attacker.pbOpposing2.moves[j]
          #found=true if m.id==attacker.moves[i].id
        end
      end
    end
    #if !found
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    #end
    @battle.pbAnimation(@id,attacker,nil,true)
    attacker.effects[PBEffects::Imprison]=true
    @battle.pbDisplay(_INTL("{1} sealed the opponent's move(s)!",attacker.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, disables the last move the target used.
################################################################################
class PokeBattle_Move_0B9 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Disable]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker
      if opponent.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    for i in opponent.moves
      if i.id==opponent.lastMoveUsed && i.id>0 && (i.pp>0 || i.totalpp==0)
        @battle.pbAnimation(@id,attacker,opponent)
        opponent.effects[PBEffects::Disable]=4+@battle.pbRandom(4)
        opponent.effects[PBEffects::DisableMove]=opponent.lastMoveUsed
        @battle.pbDisplay(_INTL("{1}'s {2} was disabled!",opponent.pbThis,i.name))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# For 4 rounds, disables the target's non-damaging moves.
################################################################################
class PokeBattle_Move_0BA < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Taunt]>0 ||
       (!attacker.hasMoldBreaker && opponent.hasWorkingAbility(:OBLIVIOUS))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker
      if opponent.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    opponent.effects[PBEffects::Taunt]=4
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} fell for the taunt!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, disables the target's healing moves.
################################################################################
class PokeBattle_Move_0BB < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::HealBlock]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker
      if opponent.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    opponent.effects[PBEffects::HealBlock]=5
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} was prevented from healing!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 4 rounds, the target must use the same move each round.
################################################################################
class PokeBattle_Move_0BC < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Encore]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.lastMoveUsed<=0 ||
       isConst?(opponent.lastMoveUsed,PBMoves,:ASSIST) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:COPYCAT) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:ENCORE) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:MEFIRST) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:METRONOME) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:MIMIC) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:MIRRORMOVE) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:NATUREPOWER) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:SKETCH) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:SLEEPTALK) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:SNATCH) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:STRUGGLE) ||
       isConst?(opponent.lastMoveUsed,PBMoves,:TRANSFORM)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker
      if opponent.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
        return -1
      elsif opponent.pbPartner.hasWorkingAbility(:AROMAVEIL)
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           opponent.pbPartner.pbThis,PBAbilities.getName(opponent.pbPartner.ability)))
        return -1
      end
    end
    for i in 0..3
      if opponent.lastMoveUsed==opponent.moves[i].id &&
         (opponent.moves[i].pp>0 || opponent.moves[i].totalpp==0)
        opponent.effects[PBEffects::Encore]=3
        opponent.effects[PBEffects::EncoreIndex]=i
        opponent.effects[PBEffects::EncoreMove]=opponent.moves[i].id
        @battle.pbAnimation(@id,attacker,opponent)
        @battle.pbDisplay(_INTL("{1} got an encore!",opponent.pbThis))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# Hits twice.
################################################################################
class PokeBattle_Move_0BD < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end
end



################################################################################
# Hits twice.  May poison the target on each hit.
################################################################################
class PokeBattle_Move_0BE < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if !opponent.pbCanPoison?(attacker,false,self)
      return false
    end
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
    return true
  end

  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end
end



################################################################################
# Hits 3 times.  Power is multiplied by the hit number.
################################################################################
class PokeBattle_Move_0BF < PokeBattle_Move
  def pbOnStartUse(attacker)
    @calcbasedmg=@basedamage
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    damage=@calcbasedmg
    @calcbasedmg+=basedmg
    return damage
  end

  def pbNumHits(attacker)
    return 3
  end

  def pbIsMultiHit
    return true
  end
end



################################################################################
# Hits 2-5 times.
################################################################################
class PokeBattle_Move_0C0 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @skilllink=attacker.hasWorkingAbility(:SKILLLINK)
    return true
  end

  def pbNumHits(attacker)
    hitchances=[2,2,3,3,4,5]
    hits=hitchances[@battle.pbRandom(hitchances.length)]
    hits=5 if @skilllink
    return hits
  end

  def pbIsMultiHit
    return true
  end
end



################################################################################
# Hits X times, where X is 1 (the user) plus the number of non-user unfainted
# status-free Pokémon in the user's party (the participants). Fails if X is 0.
# Base power of each hit depends on the base Attack stat for the species of that
# hit's participant. (Beat Up)
################################################################################
class PokeBattle_Move_0C1 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return @participants.length
  end
  
  def pbOnStartUse(attacker)
    party=@battle.pbParty(attacker.index)
    @participants=[]
    for i in 0...party.length
      if attacker.pokemonIndex==i
        @participants.push(i)
      elsif party[i] && !party[i].egg? && party[i].hp>0 && party[i].status==0
        @participants.push(i)
      end
    end
    if @participants.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    party=@battle.pbParty(attacker.index)
    atk=party[@participants[0]].baseStats[1]
    @participants[0]=nil; @participants.compact!
    return 5+(atk/10)
  end
  
  #def pbSetThisPkmn(thispkmn)
  #  @thispkmn=thispkmn
  #end

  #def pbCalcDamage(attacker,opponent,options=0,kang=false,lernean=0)

  #  opponent.damagestate.critical=pbIsCritical?(attacker,opponent)
  #  opponent.damagestate.typemod=4
  #  opponent.damagestate.hplost=0
  #  basedmg=@basedamage
  #  dexdata=pbOpenDexData
  #  pbDexDataOffset(dexdata,attacker.species,11) # Base Attack of attacker
  #  atk=dexdata.fgetb
  #  pbDexDataOffset(dexdata,opponent.species,12) # Base Defense of opponent
  #  defense=dexdata.fgetb
  #  dexdata.close
  #  #Kernel.pbMessage(atk.to_s+" "+defense.to_s+" "+@thispkmn.level.to_s)
  #  damage=(atk/10)+5
  ##    damage=((((2*@thispkmn.level/5)+2).floor*atk*basedmg/defense).floor/50).floor
  ##      Kernel.pbMessage(damage.to_s)

  #  if attacker.effects[PBEffects::HelpingHand]
  #    damage=(damage*1.5).floor
  #  end
  # #     Kernel.pbMessage(damage.to_s)
  #  #Damage weighting
  #  random=85+@battle.pbRandom(16)
  #  #    Kernel.pbMessage(damage.to_s)
  #  damage=(damage*random/100).floor
  #   #   Kernel.pbMessage(damage.to_s)
  #  if opponent.damagestate.critical
  #    damage*=2
  #    #  Kernel.pbMessage(damage.to_s)
  #  end
  #     # Kernel.pbMessage(damage.to_s)
  #  opponent.damagestate.calcdamage=damage
  #      #Kernel.pbMessage(damage.to_s)
  #  return damage
  #end
end



################################################################################
# Two turn attack.  Attacks first turn, skips second turn (if successful).
################################################################################
class PokeBattle_Move_0C2 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      attacker.effects[PBEffects::HyperBeam]=2
      attacker.currentMove=@id
    end
    return ret
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
################################################################################
class PokeBattle_Move_0C3 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} whipped up a whirlwind!",attacker.pbThis))
    end
    if @immediate
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!",attacker.pbThis))
      attacker.pbConsumeItem
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super(attacker,opponent)
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# Power halved in all weather except sunshine.  In sunshine, takes 1 turn instead.
################################################################################
class PokeBattle_Move_0C4 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if attacker.effects[PBEffects::TwoTurnAttack]==0
      @immediate=true if (@battle.pbWeather==PBWeather::SUNNYDAY || @battle.pbWeather==PBWeather::HARSHSUN)
    end
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end
  def pbBaseDamage(basedmg,attacker,opponent)
    if @battle.weather==PBWeather::NEWMOON
      return (basedmg*0.3).floor
    elsif (@battle.weather==PBWeather::RAINDANCE || 
      @battle.weather==PBWeather::HEAVYRAIN ||
      @battle.weather==PBWeather::SANDSTORM ||
      @battle.weather==PBWeather::HAIL)
      return (basedmg*0.5).floor
    else
      return basedmg
    end
  end
  def pbEffect(attacker,opponent)
    if @immediate
      if isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
#      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} took in sunlight!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
#      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} took in sunlight!",attacker.pbThis))
      return 0
    end
    return super
  end
end




################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May paralyze the target.
################################################################################
class PokeBattle_Move_0C5 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    if @immediate
       if isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!",attacker.pbThis))
      return 0
    end
    return super
  end
    
  
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(attacker,false,self)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May burn the target.
################################################################################
class PokeBattle_Move_0C6 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    if @immediate
      if isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!",attacker.pbThis))
      return 0
    end
    return super
  end
  
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(attacker,false,self)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May make the target flinch.
################################################################################
class PokeBattle_Move_0C7 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    if @immediate
      if isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} is glowing!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} is glowing!",attacker.pbThis))
      return 0
    end
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    opponent.pbFlinch(attacker)
  end
end



################################################################################
# Two turn attack.  Ups user's Defence by 1 stage first turn, attacks second turn.
################################################################################
class PokeBattle_Move_0C8 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    if @immediate
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} lowered its head!",attacker.pbThis))
      if !attacker.pbTooHigh?(PBStats::DEFENSE)
        attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis)) 
      end
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} lowered its head!",attacker.pbThis))
      if !attacker.pbTooHigh?(PBStats::DEFENSE)
        attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis)) 
      end
      return 0
    end
    return super
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Fly)
# Is semi-invulnerable during use, vulnerable only to sky-based moves.
################################################################################
class PokeBattle_Move_0C9 < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pbConsumeItem
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
      @battle.scene.pbShowSprites(attacker.index)
    if @immediate
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} flew up high!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} flew up high!",attacker.pbThis))
      return 0
    end
    return super
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Dig)
# Is semi-invulnerable during use, vulnerable only to underground-based moves.
################################################################################
class PokeBattle_Move_0CA < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    @battle.scene.pbShowSprites(attacker.index)
    if @immediate
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} dug a hole!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} dug a hole!",attacker.pbThis))
      return 0
    end
    return super
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Dive)
# Is semi-invulnerable during use, vulnerable only to underwater-based moves.
################################################################################
class PokeBattle_Move_0CB < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    @battle.scene.pbShowSprites(attacker.index)
    if @immediate
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} hid underwater!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} hid underwater!",attacker.pbThis))
      return 0
    end
    return super
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Bounce)
# Is semi-invulnerable during use, vulnerable only to sky-based moves.
# May paralyze the target.
################################################################################
class PokeBattle_Move_0CC < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    @battle.scene.pbShowSprites(attacker.index)
    if @immediate
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} sprang up!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} sprang up!",attacker.pbThis))
      return 0
    end
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(attacker,false,self)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Shadow Force)
# Is invulnerable during use.
# Ignores target's Detect and Protect.  If successful, negates them this round.
################################################################################
class PokeBattle_Move_0CD < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
    if !@immediate && @battle.pbWeather==PBWeather::NEWMOON
      @immediate=true
    end
    
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
      @battle.scene.pbShowSprites(attacker.index)
    if @immediate
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} vanished instantly!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.scene.pbHideSprites(attacker.index)
      @battle.pbDisplay(_INTL("{1} vanished instantly!",attacker.pbThis))
      return 0
    end
    ret=super(attacker,opponent)
    opponent.effects[PBEffects::ProtectNegation]=true if ret
    opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false if ret
    return ret
  end
  
  def tramplesMinimize?(param=1)
    return true if param==1 # Perfect accuracy
    return true if param==2 # Double damage
    return false
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Sky Drop)
# Is semi-invulnerable during use, vulnerable only to sky-based moves.
# Target is also semi-invulnerable during use, and can't take any action.
# Doesn't damage airborne Pokémon (but still makes them unable to move during).
################################################################################
class PokeBattle_Move_0CE < PokeBattle_Move
  def unusableInGravity?
    return true
  end
  
  def pbMoveFailed(attacker,opponent)
    ret=false
    ret=true if opponent.effects[PBEffects::Substitute]>0
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY)
    ret=true if opponent.effects[PBEffects::SkyDrop] && opponent.effects[PBEffects::SkyDropPartnerPos]!=attacker.index
    ret=true if !opponent.pbIsOpposing?(attacker.index)
    ret=true if opponent.weight(attacker)>=2000
    #if ret
    #  opponent.effects[PBEffects::SkyDrop]=false
    #end
    return ret
  end
  
  def pbTwoTurnAttack(attacker)
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    if pbMoveFailed(attacker,opponent)
      attacker.effects[PBEffects::TwoTurnAttack]=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} took {2} into the sky!",attacker.pbThis,opponent.pbThis(true)))
      opponent.effects[PBEffects::SkyDrop]=true
      opponent.effects[PBEffects::SkyDropPartnerPos]=attacker.index
      attacker.effects[PBEffects::SkyDropPartnerPos]=opponent.index
      @battle.scene.pbHideSprites(attacker.index)
      @battle.scene.pbHideSprites(opponent.index)
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    @battle.scene.pbShowSprites(attacker.index)
    @battle.scene.pbShowSprites(opponent.index)
    ret=super
    @battle.pbDisplay(_INTL("{1} was freed from the Sky Drop!",opponent.pbThis))
    opponent.effects[PBEffects::SkyDrop]=false
    opponent.effects[PBEffects::SkyDropPartnerPos]=-1
    attacker.effects[PBEffects::SkyDropPartnerPos]=-1
    return ret
  end

  def pbTypeModifier(type,attacker,opponent)
    if opponent.pbHasType?(:FLYING)
      opponent.effects[PBEffects::SkyDrop]=false
      @battle.scene.pbShowSprites(attacker.index)
      @battle.scene.pbShowSprites(opponent.index)
      return 0
    end
    return super
  end
end



################################################################################
# Trapping move.  Traps for 4 or 5 rounds.  Trapped Pokémon lose 1/16 of max HP
# at end of each round.
################################################################################
class PokeBattle_Move_0CF < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && opponent.hp>0
      if opponent.effects[PBEffects::MultiTurn]==0
        opponent.effects[PBEffects::MultiTurn]=5+@battle.pbRandom(2)
        opponent.effects[PBEffects::MultiTurn]=8 if isConst?(attacker.item,PBItems,:GRIPCLAW)
        opponent.effects[PBEffects::MultiTurnUser]=attacker.index
        opponent.effects[PBEffects::MultiTurnAttack]=@id
        if isConst?(@id,PBMoves,:BIND)
          @battle.pbDisplay(_INTL("{1} was squeezed by {2}!",opponent.pbThis,attacker.pbThis(true)))
        elsif isConst?(@id,PBMoves,:CLAMP)
          @battle.pbDisplay(_INTL("{1} clamped {2}!",attacker.pbThis,opponent.pbThis(true)))
        elsif isConst?(@id,PBMoves,:FIRESPIN)
          @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
        elsif isConst?(@id,PBMoves,:MAGMASTORM)
          @battle.pbDisplay(_INTL("{1} was trapped by Magma Storm!",opponent.pbThis))
        elsif isConst?(@id,PBMoves,:SANDTOMB)
          @battle.pbDisplay(_INTL("{1} was trapped by Sand Tomb!",opponent.pbThis))
        elsif isConst?(@id,PBMoves,:WRAP)
          @battle.pbDisplay(_INTL("{1} was wrapped by {2}!",opponent.pbThis,attacker.pbThis(true)))
        elsif isConst?(@id,PBMoves,:INFESTATION)
          @battle.pbDisplay(_INTL("{1} has been afflicted with an infestation by {2}!",opponent.pbThis,attacker.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
        end
      end
    end
    return ret
  end
end



################################################################################
# Trapping move.  Traps for 4 or 5 rounds.  Trapped Pokémon lose 1/16 of max HP
# at end of each round.
# Power is doubled if target is using Dive.
################################################################################
class PokeBattle_Move_0D0 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && opponent.hp>0
      if opponent.effects[PBEffects::MultiTurn]==0
        opponent.effects[PBEffects::MultiTurn]=5+@battle.pbRandom(2)
        opponent.effects[PBEffects::MultiTurn]=6 if isConst?(attacker.item,PBItems,:GRIPCLAW)
        opponent.effects[PBEffects::MultiTurnUser]=attacker.index
        opponent.effects[PBEffects::MultiTurnAttack]=@id
        @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
      end
    end
    return ret
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# User must use this move for 2 more rounds.  No battlers can sleep.
################################################################################
class PokeBattle_Move_0D1 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      if attacker.effects[PBEffects::Uproar]==0
        attacker.effects[PBEffects::Uproar]=3
        @battle.pbDisplay(_INTL("{1} caused an uproar!",attacker.pbThis))
        attacker.currentMove=@id
      end
    end
    return ret
  end
end



################################################################################
# User must use this move for 1 or 2 more rounds.  At end, user becomes confused.
################################################################################
class PokeBattle_Move_0D2 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 &&
       attacker.effects[PBEffects::Outrage]==0 && 
       attacker.status!=PBStatuses::SLEEP  #TODO: Not likely what actually happens, but good enough
      attacker.effects[PBEffects::Outrage]=2+@battle.pbRandom(2)
      attacker.currentMove=@id
    elsif pbTypeModifier(@type,attacker,opponent)==0
      # Cancel effect if attack is ineffective
      attacker.effects[PBEffects::Outrage]=0 if attacker.effects[PBEffects::Outrage]>1
    end
=begin
    if attacker.effects[PBEffects::Outrage]>0 #&& attacker.effects[PBEffects::LerneanCounter]<=1 #&& attacker.effects[PBEffects::ParentalBond]==0
      attacker.effects[PBEffects::Outrage]-=1
      if attacker.effects[PBEffects::Outrage]==0 &&
         attacker.effects[PBEffects::Confusion]==0 &&
         !attacker.hasWorkingAbility(:OWNTEMPO)
        attacker.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
        @battle.pbCommonAnimation("Confusion",attacker,nil)
        @battle.pbDisplay(_INTL("{1} became confused due to fatigue!",attacker.pbThis))
      end
    end
=end
    return ret
  end
end



################################################################################
# User must use this move for 4 more rounds.  Power doubles each round.
# Power is also doubled if user has curled up.
################################################################################
class PokeBattle_Move_0D3 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    shift=(4-attacker.effects[PBEffects::Rollout]) # from 0 through 4, 0 is most powerful
    shift+=1 if attacker.effects[PBEffects::DefenseCurl]
    basedmg<<=shift
    return basedmg
  end
end



################################################################################
# User bides its time this round and next round.  The round after, deals 2x the
# total damage it took while biding to the last battler that damaged it.
################################################################################
class PokeBattle_Move_0D4 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    if attacker.effects[PBEffects::Bide]==0
      @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,name))
      attacker.effects[PBEffects::Bide]=2
      attacker.effects[PBEffects::BideDamage]=0
      attacker.effects[PBEffects::BideTarget]=-1
      attacker.currentMove=@id
      @battle.pbAnimation(@id,attacker,nil)
      attacker.effects[PBEffects::SkipTurn]=true
      return 1
    else
      attacker.effects[PBEffects::Bide]-=1
      if attacker.effects[PBEffects::Bide]==0
        @battle.pbDisplayBrief(_INTL("{1} unleashed energy!",attacker.pbThis))
        return 0
      else
        @battle.pbDisplayBrief(_INTL("{1} is storing energy!",attacker.pbThis))
        attacker.effects[PBEffects::SkipTurn]=true
        return 2
      end
    end
  end

  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::BideTarget]>=0
      if !attacker.pbAddTarget(targets, @battle.battlers[attacker.effects[PBEffects::BideTarget]])
        attacker.pbRandomTarget(targets)
      end
    else
      attacker.pbRandomTarget(targets)
    end
  end

  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::BideDamage]==0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::BideDamage]*2,attacker,opponent)
    attacker.effects[PBEffects::BideDamage]=0
    return ret
  end
end



################################################################################
# Heals user by 1/2 of its max HP.
################################################################################
class PokeBattle_Move_0D5 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      hpgain=(attacker.totalhp/2).floor
      attacker.pbRecoverHP(hpgain)
      @battle.pbDisplay(_INTL("{1} regained health!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# Heals user by 1/2 of its max HP.
# User roosts, and its Flying type is ignored for attacks used against it.
################################################################################
class PokeBattle_Move_0D6 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    #if attacker.hp==attacker.totalhp
    #  @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
    #  return -1
    #else
    #  @battle.pbAnimation(@id,attacker,nil)
    #  hpgain=(attacker.totalhp/2).floor
    #  attacker.pbRecoverHP(hpgain)
    #  @battle.pbDisplay(_INTL("{1} regained health!",attacker.pbThis))
    #  attacker.effects[PBEffects::Roost]=1
    # if isConst?(attacker.type1,PBTypes,:FLYING) && !isConst?(attacker.type2,PBTypes,:FLYING)
    #    attacker.type1=attacker.type2
    #  elsif isConst?(attacker.type2,PBTypes,:FLYING) && !isConst?(attacker.type1,PBTypes,:FLYING)
    #    attacker.type2=attacker.type1
    #  elsif isConst?(attacker.type1,PBTypes,:FLYING) || isConst?(attacker.type2,PBTypes,:FLYING)
    #    attacker.type1=PBTypes::NORMAL
    #    attacker.type2=PBTypes::NORMAL
    #    attacker.effects[PBEffects::Roost]=2
    #  else
    #    attacker.effects[PBEffects::Roost]=0
    #  end
    #  return 0
    #end
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor)
    attacker.effects[PBEffects::Roost]=true
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end



################################################################################
# Battler in user's position is healed by 1/2 of its max HP, at the end of the
# next round.
################################################################################
class PokeBattle_Move_0D7 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::Wish]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.effects[PBEffects::Wish]=2
    attacker.effects[PBEffects::WishLoop]=attacker.hasWorkingAbility(:PERIODICORBIT)
    attacker.effects[PBEffects::WishAmount]=((attacker.totalhp+1)/2).floor
    attacker.effects[PBEffects::WishMaker]=attacker.pokemonIndex
    return 0
  end
end



################################################################################
# Heals user by an amount depending on the weather.
################################################################################
class PokeBattle_Move_0D8 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    hpgain=0
    if @battle.pbWeather==PBWeather::NEWMOON && @id==PBMoves::MOONLIGHT
      hpgain=(attacker.totalhp*2/3).floor
    elsif (@battle.pbWeather==PBWeather::SUNNYDAY || @battle.pbWeather==PBWeather::HARSHSUN) && @id==PBMoves::MOONLIGHT
      hpgain=(attacker.totalhp*1/3).floor
    elsif (@battle.pbWeather==PBWeather::SUNNYDAY || @battle.pbWeather==PBWeather::HARSHSUN)
      hpgain=(attacker.totalhp*2/3).floor
    elsif @battle.pbWeather==PBWeather::NEWMOON
      hpgain=(attacker.totalhp*1/3).floor
    elsif @battle.pbWeather!=0
      hpgain=(attacker.totalhp/4).floor
    else
      hpgain=(attacker.totalhp/2).floor
    end
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbRecoverHP(hpgain)
      @battle.pbDisplay(_INTL("{1} regained health!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# Heals user to full HP.  User falls asleep for 2 more rounds.
################################################################################
class PokeBattle_Move_0D9 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    return -1 if !attacker.pbCanSleep?(attacker,true,self,true)
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    if attacker.status>0
      @battle.pbDisplay(_INTL("{1} slept and became healthy!",attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} went to sleep!",attacker.pbThis))
    end
    attacker.pbSleepSelf(3)
    attacker.pbRecoverHP(attacker.totalhp-attacker.hp)
    @battle.pbDisplay(_INTL("{1} regained health!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Rings the user.  Ringed Pokémon gain 1/16 of max HP at the end of each round.
################################################################################
class PokeBattle_Move_0DA < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::AquaRing]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.effects[PBEffects::AquaRing]=true
      @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# Ingrains the user.  Ingrained Pokémon gain 1/16 of max HP at the end of each
# round, and cannot flee or switch out.
################################################################################
class PokeBattle_Move_0DB < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.effects[PBEffects::Ingrain]=true
      @battle.pbDisplay(_INTL("{1} planted its roots!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# Seeds the target.  Seeded Pokémon lose 1/8 of max HP at the end of each
# round, and the Pokémon in the user's position gains the same amount.
################################################################################
class PokeBattle_Move_0DC < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::LeechSeed]>=0 ||
       opponent.effects[PBEffects::Substitute]>0 # TODO: Same message upon Protect or miss
      @battle.pbDisplay(_INTL("{1} evaded the attack!",opponent.pbThis))
      return -1
    end
    if opponent.pbHasType?(:GRASS) || opponent.effects[PBEffects::ForestsCurse] ||
       opponent.hasWorkingAbility(:OMNITYPE)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      opponent.effects[PBEffects::TypeIdentified]=true
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.effects[PBEffects::LeechSeed]=attacker.index
    @battle.pbDisplay(_INTL("{1} was seeded!",opponent.pbThis))
    return 0
  end
end



################################################################################
# User gains half the HP it inflicts as damage.
################################################################################
class PokeBattle_Move_0DD < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      hpgain=(opponent.damagestate.hplost/2).floor
      if opponent.hasWorkingAbility(:LIQUIDOOZE)
        attacker.pbReduceHP(hpgain)
        @battle.pbDisplay(_INTL("It sucked up the liquid ooze!"))
      elsif attacker.effects[PBEffects::HealBlock]==0
        hpgain*=1.3 if isConst?(attacker.item,PBItems,:BIGROOT)
        attacker.pbRecoverHP(hpgain)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# User gains half the HP it inflicts as damage.  Fails if target is not asleep.
################################################################################
class PokeBattle_Move_0DE < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      hpgain=(opponent.damagestate.hplost/2).floor
      hpgain*=1.3 if isConst?(attacker.item,PBItems,:BIGROOT)
      attacker.pbRecoverHP(hpgain) if attacker.effects[PBEffects::HealBlock]==0
      @battle.pbDisplay(_INTL("{1}'s dream was eaten!",opponent.pbThis))
      return ret
    end
  end
end



################################################################################
# Heals target by 1/2 of its max HP.
################################################################################
class PokeBattle_Move_0DF < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    if opponent.hp==opponent.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",opponent.pbThis))  
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      hpgain=(opponent.totalhp/2).floor
      opponent.pbRecoverHP(hpgain)
      @battle.pbDisplay(_INTL("{1} regained health!",opponent.pbThis))  
      return 0
    end
  end
end



################################################################################
# User faints.
################################################################################
class PokeBattle_Move_0E0 < PokeBattle_Move
  def pbOnStartUse(attacker)
    bearer=@battle.pbCheckGlobalAbility(:DAMP)
    if bearer && !attacker.hasMoldBreaker
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
         bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
      return false
    else
      attacker.hp=0
      @battle.pbAnimation(@id,attacker,nil)
      return true
    end
  end
end



################################################################################
# Inflicts fixed damage equal to user's current HP.
# User faints (if successful).
################################################################################
class PokeBattle_Move_0E1 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    typemod=pbTypeModifier(pbType(@type,attacker,opponent),attacker,opponent)
    if typemod==0
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      opponent.effects[PBEffects::TypeIdentified]=true
      return -1
    end
    ret=pbEffectFixedDamage(attacker.hp,attacker,opponent)
    #Kernel.pbMessage(_INTL("{1}",attacker.hp.to_s))
    return ret
  end

  def pbShowAnimation(id,attacker,opponent)
    super(id,attacker,opponent)
    if !attacker.fainted?
      attacker.pbReduceHP(attacker.hp)
      attacker.pbFaint if attacker.fainted?
    end
  end
end



################################################################################
# Decreases the target's Attack and Special Attack by 2 stages each.
# User faints (if successful).
################################################################################
class PokeBattle_Move_0E2 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it had no effect!"))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      return -1
    end
    if opponent.hasWorkingAbility(:CLEARBODY) || opponent.hasWorkingAbility(:WHITESMOKE)
      abilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,abilityname))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    fail=-1
    if opponent.hasWorkingAbility(:HYPERCUTTER)
      abilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",opponent.pbThis,abilityname))
    elsif opponent.pbTooLow?(PBStats::ATTACK)
      @battle.pbDisplay(_INTL("{1}'s Attack won't go lower!",opponent.pbThis))
    else
      opponent.pbReduceStatBasic(PBStats::ATTACK,2)
      @battle.pbCommonAnimation("StatDown",attacker,opponent) if fail==-1 && !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1}'s Attack harshly fell!",opponent.pbThis))
      fail=0
    end
    if opponent.pbTooLow?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s Special Attack won't go lower!",opponent.pbThis))
    else
      opponent.pbReduceStatBasic(PBStats::SPATK,2)
      @battle.pbCommonAnimation("StatDown",attacker,opponent) if fail==-1 && !opponent.isInvulnerable?
      @battle.pbDisplay(_INTL("{1}'s Special Attack harshly fell!",opponent.pbThis))
      fail=0
    end
    return fail
  end
end



################################################################################
# User faints.  The Pokémon that replaces the user is fully healed (HP and
# status).  Fails if user won't be replaced.
################################################################################
class PokeBattle_Move_0E3 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    if !@battle.pbCanChooseNonActive?(attacker.index) || 
       (!@battle.opponent && !@battle.pbOwnedByPlayer?(attacker.index))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      attacker.hp=0
      attacker.effects[PBEffects::HealingWish]=true
            attacker.pbFaint

      @battle.pbAnimation(@id,attacker,nil)
      return 0
    end
  end
end



################################################################################
# User faints.  The Pokémon that replaces the user is fully healed (HP, PP and
# status).  Fails if user won't be replaced.
################################################################################
class PokeBattle_Move_0E4 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    if !@battle.pbCanChooseNonActive?(attacker.index) || 
       (!@battle.opponent && !@battle.pbOwnedByPlayer?(attacker.index))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      attacker.hp=0
      attacker.effects[PBEffects::LunarDance]=true
      @battle.pbAnimation(@id,attacker,nil)
      return 0
    end
  end
end



################################################################################
# All current battlers will perish after 3 more rounds.
################################################################################
class PokeBattle_Move_0E5 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    failed=true
    for i in 0..3

      if @battle && @battle.battlers[i] && @battle.battlers[i] != nil && @battle.battlers[i].effects[PBEffects::PerishSong]==0 &&
         (!@battle.battlers[i].hasWorkingAbility(:SOUNDPROOF) || attacker.hasMoldBreaker)
        failed=false
      end   
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("All affected Pokémon will faint in three turns!"))
    for i in 0..3
      if @battle.battlers[i].effects[PBEffects::PerishSong]==0
        if !attacker.hasMoldBreaker && @battle.battlers[i].hasWorkingAbility(:SOUNDPROOF)
          @battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",@battle.battlers[i].pbThis,
             PBAbilities.getName(@battle.battlers[i].ability),name))
        else
          @battle.battlers[i].effects[PBEffects::PerishSong]=4
          @battle.battlers[i].effects[PBEffects::PerishSongUser]=attacker.index
        end
      end
    end
    return 0
  end
end



################################################################################
# If user is KO'd before it next moves, the attack that caused it loses all PP.
################################################################################
class PokeBattle_Move_0E6 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    @battle.pbAnimation(@id,attacker,nil)
    attacker.effects[PBEffects::Grudge]=true
    @battle.pbDisplay(_INTL("{1} wants the opponent to bear a grudge!",attacker.pbThis))
    return 0
  end
end



################################################################################
# If user is KO'd before it next moves, the battler that caused it also faints.
################################################################################
class PokeBattle_Move_0E7 < PokeBattle_Move
  def pbEffect(attacker,opponent)
     attacker.effects[PBEffects::DestinyBond]=true
     @battle.pbAnimation(@id,attacker,nil,true)
     @battle.pbDisplay(_INTL("{1} is trying to take its foe with it!",attacker.pbThis))
     return 0
  end
end



################################################################################
# If user would be KO'd this round, it survives with 1HP instead. (Endure)
################################################################################
class PokeBattle_Move_0E8 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    #TODO: Fails if attack strikes last
    if !isConst?(attacker.lastMoveCalled,PBMoves,:DETECT) &&
       !isConst?(attacker.lastMoveCalled,PBMoves,:ENDURE) &&
       !isConst?(attacker.lastMoveCalled,PBMoves,:PROTECT) &&
       !isConst?(attacker.lastMoveCalled,PBMoves,:QUICKGUARD) &&
       !isConst?(attacker.lastMoveCalled,PBMoves,:WIDEGUARD)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    if @battle.pbRandom(65536)<=(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::Endure]=true
      attacker.effects[PBEffects::ProtectRate]*=2
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} braced itself!",attacker.pbThis))
      return 0
    else
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end



################################################################################
# If target would be KO'd by this attack, it survives with 1HP instead.
################################################################################
class PokeBattle_Move_0E9 < PokeBattle_Move
# Handled in superclass, do not edit!
end




################################################################################
# User flees from battle.  Fails in trainer battles.
################################################################################
class PokeBattle_Move_0EA < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.opponent || @battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    elsif @battle.pbCanRun?(attacker.index)
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} fled from battle!",attacker.pbThis))
      @battle.decision=3
      return 0
    else
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end



################################################################################
# Target flees from battle.  In trainer battles, target switches out instead.
# Fails if target is a higher level than the user.  For status moves.
################################################################################
class PokeBattle_Move_0EB < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:SUCTIONCUPS)
      @battle.pbDisplay(_INTL("{1} anchored itself with {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))  
      return -1
    end
    if opponent.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",opponent.pbThis))  
      return -1
    end
    if opponent.effects[PBEffects::MeloettaForme] != nil && opponent.effects[PBEffects::MeloettaForme] != 0
            @battle.pbDisplay(_INTL("{1} couldn't be switched out!",opponent.pbThis))  
      return -1
    end
    if @battle.pbOwnedByPlayer?(opponent.index) && ($game_switches[346] || $game_switches[347])
            @battle.pbDisplay(_INTL("But it failed!",opponent.pbThis))  
      return -1
    end
    if opponent.effects[PBEffects::SkyDropPartnerPos]!=-1 ||
       opponent.effects[PBEffects::SpiritAwayPartnerPos]!=-1
      @battle.pbDisplay(_INTL("But it failed!",opponent.pbThis))  
      return -1
    end
    if !@battle.opponent && !@battle.pbOwnedByPlayer?(attacker.index)
      if opponent.level>=attacker.level
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      @battle.decision=3 # Set decision to escaped
      return 0
    elsif !@battle.opponent
            @battle.decision=3 # Set decision to escaped
      return 0
    else
      #choices=[]
      choices=false
      party=@battle.pbParty(opponent.index)
      for i in 0..party.length-1
        #choices[choices.length]=i if @battle.pbCanSwitchLax?(opponent.index,i,false)
        if @battle.pbCanSwitch?(opponent.index,i,false)
          choices=true
          break
        end
      end
      #if choices.length==0
      if !choices
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      #newpoke=choices[@battle.pbRandom(choices.length)]
      @battle.pbAnimation(@id,attacker,opponent)
      opponent.effects[PBEffects::Roar]=true
#      opponent.pbResetForm
      #@battle.pbReplace(opponent.index,newpoke,false)
      #@battle.pbDisplay(_INTL("{1} was dragged out!",opponent.pbThis))
      #@battle.pbOnActiveOne(opponent)
      #opponent.pbAbilitiesOnSwitchIn(true)
      return 0
    end
  end
end



################################################################################
# Target flees from battle.  In trainer battles, target switches out instead.
# Fails if target is a higher level than the user.  For damaging moves.
################################################################################
class PokeBattle_Move_0EC < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if attacker.hp>0 && opponent.hp>0 &&
       opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && 
       (attacker.hasMoldBreaker || !opponent.hasWorkingAbility(:SUCTIONCUPS)) &&
       !opponent.effects[PBEffects::Ingrain] && 
       opponent.effects[PBEffects::SkyDropPartnerPos]==-1 &&
       opponent.effects[PBEffects::SpiritAwayPartnerPos]==-1
      if !@battle.opponent && !@battle.doublebattle
        if opponent.level<attacker.level
          @battle.decision=3 # Set decision to escaped
        end
      else#if !@battle.doublebattle || $Trainer.ablePokemonCount>1
        #choices=[]
        #party=@battle.pbParty(opponent.index)
        #for i in 0..party.length-1
        #  choices[choices.length]=i if @battle.pbCanSwitchLax?(opponent.index,i,false)
        #end
        #if choices.length>0
        #  newpoke=choices[@battle.pbRandom(choices.length)]
        #  @battle.pbAnimation(@id,attacker,opponent)
        ##  opponent.pbResetForm
        #  @battle.pbReplace(opponent.index,newpoke,false)
        #  @battle.pbDisplay(_INTL("{1} was dragged out!",opponent.pbThis))
        #  @battle.pbOnActiveOne(opponent)
        #  opponent.pbAbilitiesOnSwitchIn(true)
        #end
        #if @battle.opponent
          party=@battle.pbParty(opponent.index)
          for i in 0..party.length-1
            if @battle.pbCanSwitch?(opponent.index,i,false) && @battle.opponent
              opponent.effects[PBEffects::Roar]=true
              break
            end
          end
        #end
      end
    end
    return ret
  end
end



################################################################################
# User switches out.  Various effects affecting the user are passed to the
# replacement.
################################################################################
class PokeBattle_Move_0ED < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if !@battle.pbCanChooseNonActive?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.doublebattle && !@battle.opponent && @battle.pbIsOpposing?(attacker.index)
       @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.effects[PBEffects::BatonPass]=true
    return 0
  end
end



################################################################################
# After inflicting damage, user switches out.  Ignores trapping moves.
################################################################################
class PokeBattle_Move_0EE < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    
    #if (opponent.ability==PBAbilities::VOLTABSORB || opponent.ability==PBAbilities::LIGHTNINGROD || opponent.ability==PBAbilities::MOTORDRIVE) &&
    #  @type==PBTypes::ELECTRIC
    #else
    if @battle.pbOwnedByPlayer?(attacker.index) && ($game_switches[346] || $game_switches[347])
            @battle.pbDisplay(_INTL("But it failed!",attacker.pbThis))  
      return -1
    end
    if attacker.hp>0 && opponent.damagestate.calcdamage>0 && 
       @battle.pbCanChooseNonActive?(attacker.index) &&
       !@battle.pbAllFainted?(@battle.pbParty(opponent.index))
      #newpoke=0
      #newpoke=@battle.pbSwitchInBetween(attacker.index,true,false,true)
                    # newpoke=pbSwitchInBetween(index,true,false)
      #if $hasSentData
      #  $network.send("<BAT\tnew=#{newpoke}>")
      #end

      #@battle.pbMessagesOnReplace(attacker.index,newpoke)
      #@battle.pbReplace(attacker.index,newpoke,true)
      #@battle.pbOnActiveOne(attacker)
      #attacker.pbAbilitiesOnSwitchIn(true)
     # attacker.pbResetForm
      #attacker.stages[PBStats::ATTACK]=0
      #attacker.stages[PBStats::DEFENSE]=0
      #attacker.stages[PBStats::SPEED]=0
      #attacker.stages[PBStats::SPATK]=0
      #attacker.stages[PBStats::SPDEF]=0
      #attacker.stages[PBStats::ACCURACY]=0
      #attacker.stages[PBStats::EVASION]=0

      #attacker.effects[PBEffects::Substitute]=0
      #attacker.effects[PBEffects::LeechSeed]=-1
      #attacker.effects[PBEffects::Confusion]=00
      #newpoke=newpoke[0] if newpoke.is_a?(Array)
      #attacker.status=@battle.pbParty(attacker.index)[newpoke].status if attacker && @battle.pbParty(attacker.index)[newpoke]#.pokemon
     ## attacker.status=@battle.pbParty[attacker.index][newpoke].status if attacker && @battle.pbParty[attacker.index][newpoke]
    #  Kernel.pbMessage("0")
      #if $hasSentData
      #  @battle.waitnewenemy
      #  $hasSentData=nil
      #end
      attacker.effects[PBEffects::Uturn]=true
      #opponent.pbFaint if opponent.hp <= 0
    end
    return ret
  end
end



################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
################################################################################
class PokeBattle_Move_0EF < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if !pbIsStatus?
      ret=super(attacker,opponent)
      if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
         !opponent.fainted?
        if opponent.effects[PBEffects::MeanLook]<0 && (!opponent.pbHasType?(:GHOST) || opponent.effects[PBEffects::TrickOrTreat])
          opponent.effects[PBEffects::MeanLook]=attacker.index
          @battle.pbDisplay(_INTL("{1} can no longer escape!",opponent.pbThis))
        end
      end
      return ret
    end
    if opponent.effects[PBEffects::MeanLook]>=0 ||
       (opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.pbHasType?(:GHOST) || opponent.effects[PBEffects::TrickOrTreat]
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      opponent.effects[PBEffects::TypeIdentified]=true
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.effects[PBEffects::MeanLook]=attacker.index
    @battle.pbDisplay(_INTL("{1} can no longer escape!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Target drops its item.  It regains the item at the end of the battle.
################################################################################
class PokeBattle_Move_0F0 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       opponent.item(true)!=0
      if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:STICKYHOLD)
        abilityname=PBAbilities.getName(opponent.ability(true))
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      elsif !@battle.pbIsUnlosableItem(opponent,opponent.item(true))
        itemname=PBItems.getName(opponent.item(true))
        opponent.item=0
        opponent.effects[PBEffects::ChoiceBand]=-1
        opponent.effects[PBEffects::Unburden]=true
        @battle.pbDisplay(_INTL("{1} knocked off {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
      end
    end
    return ret
  end
end



################################################################################
# User steals the target's item, if the user has none itself.
# Items stolen from wild Pokémon are kept after the battle.
################################################################################
class PokeBattle_Move_0F1 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && opponent.item(true)!=0
      if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:STICKYHOLD)
        abilityname=PBAbilities.getName(opponent.ability(true))
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      elsif !@battle.pbIsUnlosableItem(opponent,opponent.item(true)) &&
            !@battle.pbIsUnlosableItem(attacker,opponent.item(true)) &&
            attacker.item(true)==0 &&
            (@battle.opponent || !@battle.pbIsOpposing?(attacker.index))
        itemname=PBItems.getName(opponent.item(true))
        attacker.item=opponent.item(true)
        opponent.item=0
        opponent.effects[PBEffects::ChoiceBand]=-1
        opponent.effects[PBEffects::Unburden]=true
        if !@battle.opponent && # In a wild battle
           attacker.pokemon.itemInitial==0 &&
           opponent.pokemon.itemInitial==attacker.item(true)
          attacker.pokemon.itemInitial=attacker.item(true) 
          opponent.pokemon.itemInitial=0
        end
        @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
      end
    end
    return ret
  end
end



################################################################################
# User and target swap items.  They remain swapped after the battle.
################################################################################
class PokeBattle_Move_0F2 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (attacker.item(true)==0 && opponent.item(true)==0) ||
       (!@battle.opponent && @battle.pbIsOpposing?(attacker.index))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbIsUnlosableItem(opponent,opponent.item(true)) ||
       @battle.pbIsUnlosableItem(attacker,opponent.item(true)) ||
       @battle.pbIsUnlosableItem(opponent,attacker.item(true)) ||
       @battle.pbIsUnlosableItem(attacker,attacker.item(true))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:STICKYHOLD)
      abilityname=PBAbilities.getName(opponent.ability(true))
      @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,name))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    oldattitem=attacker.item(true)
    oldoppitem=opponent.item(true)
    oldattitemname=PBItems.getName(oldattitem)
    oldoppitemname=PBItems.getName(oldoppitem)
    tmpitem=attacker.item(true)
    attacker.item=opponent.item(true)
    opponent.item=tmpitem
    if !@battle.opponent && # In a wild battle
       attacker.pokemon.itemInitial==oldattitem &&
       opponent.pokemon.itemInitial==oldoppitem
      attacker.pokemon.itemInitial=oldoppitem
      opponent.pokemon.itemInitial=oldattitem
    end
    @battle.pbDisplay(_INTL("{1} switched items with its opponent!",attacker.pbThis))
    if oldoppitem>0 && oldattitem>0
      @battle.pbDisplayPaused(_INTL("{1} obtained {2}.",attacker.pbThis,oldoppitemname))
      @battle.pbDisplay(_INTL("{1} obtained {2}.",opponent.pbThis,oldattitemname))
    else
      @battle.pbDisplay(_INTL("{1} obtained {2}.",attacker.pbThis,oldoppitemname)) if oldoppitem>0
      @battle.pbDisplay(_INTL("{1} obtained {2}.",opponent.pbThis,oldattitemname)) if oldattitem>0
    end
    if oldattitem!=oldoppitem # TODO: Not exactly correct
      attacker.effects[PBEffects::ChoiceBand]=-1
    end
    opponent.effects[PBEffects::ChoiceBand]=-1
    if attacker.item(true)==0
      attacker.effects[PBEffects::Unburden]=true
    else
      attacker.effects[PBEffects::Unburden]=false
    end
    if opponent.item(true)==0
      opponent.effects[PBEffects::Unburden]=true
    else
      opponent.effects[PBEffects::Unburden]=false
    end
    return 0
  end
end



################################################################################
# User gives its item to the target. The item remains given after the battle.
################################################################################
class PokeBattle_Move_0F3 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.item(true)==0 || opponent.item(true)!=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbIsUnlosableItem(attacker,attacker.item(true)) ||
       @battle.pbIsUnlosableItem(opponent,attacker.item(true))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    itemname=PBItems.getName(attacker.item(true))
    opponent.item=attacker.item(true)
    attacker.item=0
    attacker.effects[PBEffects::ChoiceBand]=-1
    attacker.effects[PBEffects::Unburden]=true
    if !@battle.opponent && # In a wild battle
       opponent.pokemon.itemInitial==0 &&
      attacker.pokemon.itemInitial==opponent.item(true)
       opponent.pokemon.itemInitial=opponent.item(true)
      attacker.pokemon.itemInitial=0
    end
    @battle.pbDisplay(_INTL("{1} received {2} from {3}!",opponent.pbThis,itemname,attacker.pbThis(true)))
    return 0
  end
end



################################################################################
# User consumes target's berry and gains its effect.
################################################################################
class PokeBattle_Move_0F4 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && 
       attacker.hp>0 && pbIsBerry?(opponent.item(true))
      if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:STICKYHOLD)
        abilityname=PBAbilities.getName(opponent.ability(true))
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      else
        item=opponent.item(true)
        itemname=PBItems.getName(item)
        opponent.pbConsumeItem(false,false)
        @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!",attacker.pbThis,itemname))
        if !attacker.hasWorkingAbility(:KLUTZ) #&&
           #attacker.effects[PBEffects::Embargo]==0
          attacker.pbActivateBerryEffect(item,false)
        end
        # Symbiosis
        if attacker.item==0 &&
           attacker.pbPartner && attacker.pbPartner.hasWorkingAbility(:SYMBIOSIS)
          partner=attacker.pbPartner
          if partner.item>0 &&
             !@battle.pbIsUnlosableItem(partner,partner.item) &&
             !@battle.pbIsUnlosableItem(attacker,partner.item)
            @battle.pbDisplay(_INTL("{1}'s {2} let it share its {3} with {4}!",
               partner.pbThis,PBAbilities.getName(partner.ability),
               PBItems.getName(partner.item),attacker.pbThis(true)))
            attacker.item=partner.item
            attacker.effects[PBEffects::SymbiosisTriggered]=true
            partner.item=0
            partner.effects[PBEffects::Unburden]=true
            attacker.pbBerryCureCheck(true)
          end
        end
      end
    end
    return ret
  end
end



################################################################################
# Target's berry is destroyed.
################################################################################
class PokeBattle_Move_0F5 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && 
       attacker.hp>0 && pbIsBerry?(opponent.item(true))
      item=opponent.item(true)
      itemname=PBItems.getName(item)
      opponent.pbConsumeItem(false,false)
      @battle.pbDisplay(_INTL("{1}'s {2} was incinerated!",opponent.pbThis,itemname))
    end
    return ret
  end
end



################################################################################
# User recovers the last item it held and consumed.
################################################################################
class PokeBattle_Move_0F6 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pokemon.itemRecycle==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    item=attacker.pokemon.itemRecycle
    itemname=PBItems.getName(item)
    attacker.item=item
    attacker.pokemon.itemInitial=item if attacker.pokemon.itemInitial==0
    attacker.pokemon.itemRecycle=0
    attacker.effects[PBEffects::PickupItem]=0
    attacker.effects[PBEffects::PickupUse]=0
    attacker.effects[PBEffects::Unburden]=false
    @battle.pbDisplay(_INTL("{1} found one {2}!",attacker.pbThis,itemname))
    return 0
  end
end



################################################################################
# User flings its item at the target.  Power and effect depend on the item.
################################################################################
class PokeBattle_Move_0F7 < PokeBattle_Move
  def setDamageArray
  @damagearray={
     130 => [:IRONBALL],
     100 => [:ARMORFOSSIL,:CLAWFOSSIL,:COVERFOSSIL,:DOMEFOSSIL,:HARDSTONE,
             :HELIXFOSSIL,:OLDAMBER,:PLUMEFOSSIL,:RAREBONE,:ROOTFOSSIL,
             :SKULLFOSSIL],
      90 => [:DEEPSEATOOTH,:DRACOPLATE,:DREADPLATE,:EARTHPLATE,:FISTPLATE,
             :FLAMEPLATE,:GRIPCLAW,:ICICLEPLATE,:INSECTPLATE,:IRONPLATE,
             :MEADOWPLATE,:MINDPLATE,:SKYPLATE,:SPLASHPLATE,:SPOOKYPLATE,
             :STONEPLATE,:THICKCLUB,:TOXICPLATE,:ZAPPLATE,:PIXIEPLATE],
      80 => [:DAWNSTONE,:DUSKSTONE,:ELECTIRIZER,:MAGMARIZER,:ODDKEYSTONE,
             :OVALSTONE,:PROTECTOR,:QUICKCLAW,:RAZORCLAW,:SHINYSTONE,
             :STICKYBARB],
      70 => [:BURNDRIVE,:CHILLDRIVE,:DOUSEDRIVE,:DRAGONFANG,:POISONBARB,
             :POWERANKLET,:POWERBAND,:POWERBELT,:POWERBRACER,:POWERLENS,
             :POWERWEIGHT,:SHOCKDRIVE],
      60 => [:ADAMANTORB,:DAMPROCK,:HEATROCK,:LUSTROUSORB,:MACHOBRACE,
             :ROCKYHELMET,:STICK],
      50 => [:DUBIOUSDISC,:SHARPBEAK],
      40 => [:EVIOLITE,:ICYROCK,:LUCKYPUNCH],
      30 => [:ABILITYURGE,:ABSORBBULB,:AMULETCOIN,:ANTIDOTE,:AWAKENING,
             :BALMMUSHROOM,:BERRYJUICE,:BIGMUSHROOM,:BIGNUGGET,:BIGPEARL,
             :BINDINGBAND,:BLACKBELT,:BLACKFLUTE,:BLACKGLASSES,:BLACKSLUDGE,
             :BLUEFLUTE,:BLUESHARD,:BURNHEAL,:CALCIUM,:CARBOS,
             :CASTELIACONE,:CELLBATTERY,:CHARCOAL,:CLEANSETAG,:COMETSHARD,
             :DAMPMULCH,:DEEPSEASCALE,:DIREHIT,:DIREHIT2,:DIREHIT3,
             :DRAGONSCALE,:EJECTBUTTON,:ELIXIR,:ENERGYPOWDER,:ENERGYROOT,
             :ESCAPEROPE,:ETHER,:EVERSTONE,:EXPSHARE,:FIRESTONE,
             :FLAMEORB,:FLOATSTONE,:FLUFFYTAIL,:FRESHWATER,:FULLHEAL,
             :FULLRESTORE,:GOOEYMULCH,:GREENSHARD,:GROWTHMULCH,:GUARDSPEC,
             :HEALPOWDER,:HEARTSCALE,:HONEY,:HPUP,:HYPERPOTION,
             :ICEHEAL,:IRON,:ITEMDROP,:ITEMURGE,:KINGSROCK,
             :LAVACOOKIE,:LEAFSTONE,:LEMONADE,:LIFEORB,:LIGHTBALL,
             :LIGHTCLAY,:LUCKYEGG,:MAGNET,:MAXELIXIR,:MAXETHER,
             :MAXPOTION,:MAXREPEL,:MAXREVIVE,:METALCOAT,:METRONOME,
             :MIRACLESEED,:MOOMOOMILK,:MOONSTONE,:MYSTICWATER,:NEVERMELTICE,
             :NUGGET,:OLDGATEAU,:PARLYZHEAL,:PEARL,:PEARLSTRING,
             :POKEDOLL,:POKETOY,:POTION,:PPMAX,:PPUP,
             :PRISMSCALE,:PROTEIN,:RAGECANDYBAR,:RARECANDY,:RAZORFANG,
             :REDFLUTE,:REDSHARD,:RELICBAND,:RELICCOPPER,:RELICCROWN,
             :RELICGOLD,:RELICSILVER,:RELICSTATUE,:RELICVASE,:REPEL,
             :RESETURGE,:REVIVALHERB,:REVIVE,:SACREDASH,:SCOPELENS,
             :SHELLBELL,:SHOALSALT,:SHOALSHELL,:SMOKEBALL,:SODAPOP,
             :SOULDEW,:SPELLTAG,:STABLEMULCH,:STARDUST,:STARPIECE,
             :SUNSTONE,:SUPERPOTION,:SUPERREPEL,:SWEETHEART,:THUNDERSTONE,
             :TINYMUSHROOM,:TOXICORB,:TWISTEDSPOON,:UPGRADE,:WATERSTONE,
             :WHITEFLUTE,:XACCURACY,:XACCURACY2,:XACCURACY3,:XACCURACY6,
             :XATTACK,:XATTACK2,:XATTACK3,:XATTACK6,:XDEFEND,
             :XDEFEND2,:XDEFEND3,:XDEFEND6,:XSPDEF,:XSPDEF2,
             :XSPDEF3,:XSPDEF6,:XSPECIAL,:XSPECIAL2,:XSPECIAL3,
             :XSPECIAL6,:XSPEED,:XSPEED2,:XSPEED3,:XSPEED6,
             :YELLOWFLUTE,:YELLOWSHARD,:ZINC],
      20 => [:CLEVERWING,:GENIUSWING,:HEALTHWING,:MUSCLEWING,:PRETTYWING,
             :RESISTWING,:SWIFTWING],
      10 => [:AIRBALLOON,:BIGROOT,:BLUESCARF,:BRIGHTPOWDER,:CHOICEBAND,
             :CHOICESCARF,:CHOICESPECS,:DESTINYKNOT,:EXPERTBELT,:FOCUSBAND,
             :FOCUSSASH,:FULLINCENSE,:GREENSCARF,:LAGGINGTAIL,:LAXINCENSE,
             :LEFTOVERS,:LUCKINCENSE,:MENTALHERB,:METALPOWDER,:MUSCLEBAND,
             :ODDINCENSE,:PINKSCARF,:POWERHERB,:PUREINCENSE,:QUICKPOWDER,
             :REAPERCLOTH,:REDCARD,:REDSCARF,:RINGTARGET,:ROCKINCENSE,
             :ROSEINCENSE,:SEAINCENSE,:SHEDSHELL,:SILKSCARF,:SILVERPOWDER,
             :SMOOTHROCK,:SOFTSAND,:SOOTHEBELL,:WAVEINCENSE,:WHITEHERB,
             :WIDELENS,:WISEGLASSES,:YELLOWSCARF,:ZOOMLENS]
  }
  end

  def pbMoveFailed(attacker,opponent)
    setDamageArray
    return true if attacker.item==0 ||
                   @battle.pbIsUnlosableItem(attacker,attacker.item(true)) ||
                   pbIsPokeBall?(attacker.item(true)) ||
                   attacker.hasWorkingAbility(:KLUTZ)
    for i in @damagearray.keys
      data=@damagearray[i]
      if data
        for j in data
          return false if isConst?(attacker.item,PBItems,j)
        end
      end
    end
    return false if pbIsBerry?(attacker.item)
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    for i in @damagearray.keys
      data=@damagearray[i]
      if data
        for j in data
          if isConst?(attacker.item,PBItems,j)
            return i
          end
        end
      end
    end
    return 10 if pbIsBerry?(attacker.item)
    return 1
  end

  def pbEffect(attacker,opponent)
    if attacker.item==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return 0
    end
    attacker.effects[PBEffects::Unburden]=true
    if !opponent.effects[PBEffects::Protect] && !opponent.effects[PBEffects::KingsShield]
      @battle.pbDisplay(_INTL("{1} flung its {2}!",attacker.pbThis,PBItems.getName(attacker.item)))
    end
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       (attacker.hasMoldBreaker || !opponent.hasWorkingAbility(:SHIELDDUST))
      case attacker.item
      when PBItems::FLAMEORB
        if opponent.pbCanBurn?(attacker,false,self)
          opponent.pbBurn(attacker)
          @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
        end
      when PBItems::KINGSROCK, PBItems::RAZORFANG
        opponent.pbFlinch(attacker)
      when PBItems::LIGHTBALL
        if opponent.pbCanParalyze?(attacker,false,self)
          opponent.pbParalyze(attacker)
          @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
        end
      when PBItems::MENTALHERB
        if opponent.effects[PBEffects::Attract]>=0
          opponent.effects[PBEffects::Attract]=-1
          @battle.pbDisplay(_INTL("{1}'s {2} cured {3}'s love problem!",
              attacker.pbThis,PBItems.getName(attacker.item),opponent.pbThis(true)))
        end
      when PBItems::POISONBARB
        if opponent.pbCanPoison?(attacker,false,self)
          opponent.pbPoison(attacker)
          @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
        end
      when PBItems::TOXICORB
        if opponent.pbCanPoison?(attacker,false,self)
          opponent.pbPoison(attacker,true)
          @battle.pbDisplay(_INTL("{1} was badly poisoned!",opponent.pbThis))
        end
      when PBItems::WHITEHERB
        while true
          reducedstats=false
          for i in [PBStats::ATTACK,PBStats::DEFENSE,
                    PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                    PBStats::EVASION,PBStats::ACCURACY]
            if opponent.stages[i]<0
              opponent.stages[i]=0; reducedstats=true
            end
          end
          break if !reducedstats
          @battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s status!",
              attacker.pbThis,PBItems.getName(attacker.item),opponent.pbThis(true)))
        end
      end
    end
    attacker.pbConsumeItem
    #attacker.pokemon.itemRecycle=attacker.item
    #attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
    #attacker.item=0
    return ret
  end
end



################################################################################
# For 5 rounds, the target cannnot use its held item, its held item has no
# effect, and no items can be used on it.
################################################################################
class PokeBattle_Move_0F8 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Embargo]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Embargo]=5
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} can't use items anymore!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, all held items cannot be used in any way and have no effect.
# Held items can still change hands, but can't be thrown.
################################################################################
class PokeBattle_Move_0F9 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.field.effects[PBEffects::MagicRoom]>0
      @battle.field.effects[PBEffects::MagicRoom]=0
      @battle.pbDisplay(_INTL("The area returned to normal!"))
    #if attacker.pbOwnSide.effects[PBEffects::MagicRoom]>0 ||
    #   attacker.pbOpposingSide.effects[PBEffects::MagicRoom]>0
    #  attacker.pbOwnSide.effects[PBEffects::MagicRoom]=0
    #  attacker.pbOpposingSide.effects[PBEffects::MagicRoom]=0
    #  @battle.pbDisplay(_INTL("The area returned to normal!"))
    else
      #attacker.pbOwnSide.effects[PBEffects::MagicRoom]=5
      #attacker.pbOpposingSide.effects[PBEffects::MagicRoom]=5
      @battle.pbAnimation(@id,attacker,opponent)
      @battle.field.effects[PBEffects::MagicRoom]=5
      @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
      #@battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
    end
    return 0
  end
end



################################################################################
# User takes recoil damage equal to 1/4 of the damage this move dealt.
################################################################################
class PokeBattle_Move_0FA < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:MAGICGUARD)
        attacker.pbReduceHP([1,(opponent.damagestate.hplost/4).floor].max)
        @battle.pbDisplay(_INTL("{1} is hit with recoil!",attacker.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
################################################################################
class PokeBattle_Move_0FB < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:MAGICGUARD)
        attacker.pbReduceHP([1,(opponent.damagestate.hplost/3).floor].max)
        @battle.pbDisplay(_INTL("{1} is hit with recoil!",attacker.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# User takes recoil damage equal to 1/2 of the damage this move dealt.
################################################################################
class PokeBattle_Move_0FC < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:MAGICGUARD)
        attacker.pbReduceHP([1,(opponent.damagestate.hplost/2).floor].max)
        @battle.pbDisplay(_INTL("{1} is hit with recoil!",attacker.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May paralyze the target.
################################################################################
class PokeBattle_Move_0FD < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:MAGICGUARD)
        attacker.pbReduceHP([1,(opponent.damagestate.hplost/3).floor].max)
        @battle.pbDisplay(_INTL("{1} is hit with recoil!",attacker.pbThis))
      end
    end
    return ret
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(attacker,false,self)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May burn the target.
################################################################################
class PokeBattle_Move_0FE < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:MAGICGUARD)
        attacker.pbReduceHP([1,(opponent.damagestate.hplost/3).floor].max)
        @battle.pbDisplay(_INTL("{1} is hit with recoil!",attacker.pbThis))
      end
    end
    return ret
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(attacker,false,self)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Starts sunny weather.
################################################################################
class PokeBattle_Move_0FF < PokeBattle_Move
  def pbEffect(attacker,opponent)
    case @battle.weather
    when PBWeather::HEAVYRAIN
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return -1
    when PBWeather::HARSHSUN
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    when PBWeather::STRONGWINDS
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    when PBWeather::SUNNYDAY
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    #if @battle.weather==PBWeather::SUNNYDAY  || @battle.deltastream || @battle.primordialsea || @battle.desolateland
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    #else
    @battle.weather=PBWeather::SUNNYDAY
    @battle.weatherduration=5
    @battle.weatherduration=8 if isConst?(attacker.item,PBItems,:HEATROCK)
    @battle.pbDisplay(_INTL("The sunlight turned harsh!"))
    @battle.scene.pbBackdropMove(0,true,true)
    return 0
    #end
  end
end



################################################################################
# Starts rainy weather.
################################################################################
class PokeBattle_Move_100 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    #if @battle.weather==PBWeather::RAINDANCE  || @battle.deltastream || @battle.primordialsea || @battle.desolateland
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    #else
    case @battle.weather
    when PBWeather::HEAVYRAIN
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return -1
    when PBWeather::HARSHSUN
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    when PBWeather::STRONGWINDS
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    when PBWeather::RAINDANCE
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.weather=PBWeather::RAINDANCE
    @battle.weatherduration=5
    @battle.weatherduration=8 if isConst?(attacker.item,PBItems,:DAMPROCK)
    @battle.scene.pbBackdropMove(0,true,true)
    @battle.pbDisplay(_INTL("It started to rain!"))
    return 0
    #end
  end
end



################################################################################
# Starts sandstorm weather.
################################################################################
class PokeBattle_Move_101 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    #if @battle.weather==PBWeather::SANDSTORM  || @battle.deltastream || @battle.primordialsea || @battle.desolateland
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    #else
    case @battle.weather
    when PBWeather::HEAVYRAIN
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return -1
    when PBWeather::HARSHSUN
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    when PBWeather::STRONGWINDS
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    when PBWeather::SANDSTORM
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.weather=PBWeather::SANDSTORM
    @battle.weatherduration=5
    @battle.weatherduration=8 if isConst?(attacker.item,PBItems,:SMOOTHROCK)
    @battle.scene.pbBackdropMove(0,true,true)
    @battle.pbDisplay(_INTL("A sandstorm brewed!"))
    return 0
    #end
  end
end



################################################################################
# Starts hail weather.
################################################################################
class PokeBattle_Move_102 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    #if @battle.weather==PBWeather::HAIL   || @battle.deltastream || @battle.primordialsea || @battle.desolateland
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    #else
    case @battle.weather
    when PBWeather::HEAVYRAIN
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return -1
    when PBWeather::HARSHSUN
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    when PBWeather::STRONGWINDS
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    when PBWeather::HAIL
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.weather=PBWeather::HAIL
    @battle.weatherduration=5
    @battle.weatherduration=8 if isConst?(attacker.item,PBItems,:ICYROCK)
    @battle.scene.pbBackdropMove(0,true,true)
    @battle.pbDisplay(_INTL("It started to hail!"))
    return 0
    #end
  end
end



################################################################################
# Entry hazard.  Lays spikes on the opposing side (max. 3 layers).
################################################################################
class PokeBattle_Move_103 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOpposingSide.effects[PBEffects::Spikes]>=3
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil,true)
      attacker.pbOpposingSide.effects[PBEffects::Spikes]+=1
      @battle.pbDisplay(_INTL("Spikes were scattered all around the feet of the foe's team!"))
      return 0
    end
  end
end



################################################################################
# Entry hazard.  Lays poison spikes on the opposing side (max. 2 layers).
################################################################################
class PokeBattle_Move_104 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil,true)
      attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]+=1
      @battle.pbDisplay(_INTL("Poison spikes were scattered all around the foe's team's feet!"))
      return 0
    end
  end
end



################################################################################
# Entry hazard.  Lays stealth rocks on the opposing side.
################################################################################
class PokeBattle_Move_105 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if !attacker.hasWorkingAbility(:FOUNDRY)
      if attacker.pbOpposingSide.effects[PBEffects::StealthRock]
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      else
        @battle.pbAnimation(@id,attacker,nil,true)
        attacker.pbOpposingSide.effects[PBEffects::StealthRock]=true
        @battle.pbDisplay(_INTL("Pointed stones float in the air!"))
        return 0
      end
    else
      if attacker.pbOpposingSide.effects[PBEffects::FireRock]
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      else
        @battle.pbAnimation(@id,attacker,nil,true)
        attacker.pbOpposingSide.effects[PBEffects::FireRock]=true
        @battle.pbDisplay(_INTL("Molten rocks float in the air!"))
        return 0
      end
    end
  
  end
end



################################################################################
# If used after ally's Fire Pledge, makes a sea of fire on the opposing side.
################################################################################
class PokeBattle_Move_106 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @doubledamage=false; @overridetype=false
    if attacker.effects[PBEffects::FirstPledge]==0x107 ||   # Fire Pledge
       attacker.effects[PBEffects::FirstPledge]==0x108      # Water Pledge
      @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
      @doubledamage=true
      if attacker.effects[PBEffects::FirstPledge]==0x107   # Fire Pledge
        @overridetype=true
      end
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if @doubledamage
      return basedmg*1.875
    end
    return basedmg
  end

  def pbModifyType(type,attacker,opponent)
    if @overridetype
      type=getConst(PBTypes,:FIRE) || 0
    end
    return super(type,attacker,opponent)
  end

  def pbEffect(attacker,opponent)
    if !@battle.doublebattle || !attacker.pbPartner || attacker.pbPartner.fainted?
      attacker.effects[PBEffects::FirstPledge]=0
      return super(attacker,opponent)
    end
    # Combined move's effect
    if attacker.effects[PBEffects::FirstPledge]==0x107   # Fire Pledge
      ret=super(attacker,opponent)
      if opponent.damagestate.calcdamage>0
        attacker.pbOpposingSide.effects[PBEffects::SeaOfFire]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A sea of fire enveloped the opposing team!"))
        else
          @battle.pbDisplay(_INTL("A sea of fire enveloped your team!"))
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    elsif attacker.effects[PBEffects::FirstPledge]==0x108   # Water Pledge
      ret=super(attacker,opponent)
      if opponent.damagestate.calcdamage>0
        attacker.pbOpposingSide.effects[PBEffects::Swamp]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A swamp enveloped the opposing team!"))
        else
          @battle.pbDisplay(_INTL("A swamp enveloped your team!"))
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    end
    # Set up partner for a combined move
    attacker.effects[PBEffects::FirstPledge]=0
    partnermove=-1
    if @battle.choices[attacker.pbPartner.index][0]==1 # Chose a move
      if !attacker.pbPartner.hasMovedThisRound?
        move=@battle.choices[attacker.pbPartner.index][2]
        if move && move.id>0
          partnermove=@battle.choices[attacker.pbPartner.index][2].function
        end
      end
    end
    if partnermove==0x107 ||   # Fire Pledge
       partnermove==0x108      # Water Pledge
      @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",attacker.pbThis,attacker.pbPartner.pbThis(true)))
      attacker.pbPartner.effects[PBEffects::FirstPledge]=@function
      attacker.pbPartner.effects[PBEffects::MoveNext]=true
      return 0
    end
    # Use the move on its own
    return super(attacker,opponent)
  end

  def pbShowAnimation(id,attacker,opponent)
    if @overridetype
      return super(getConst(PBMoves,:FIREPLEDGE),attacker,opponent)
    end
    return super(id,attacker,opponent)
  end
end



################################################################################
# If used after ally's Water Pledge, makes a rainbow appear on the user's side.
################################################################################
class PokeBattle_Move_107 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @doubledamage=false; @overridetype=false
    if attacker.effects[PBEffects::FirstPledge]==0x106 ||   # Grass Pledge
       attacker.effects[PBEffects::FirstPledge]==0x108      # Water Pledge
      @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
      @doubledamage=true
      if attacker.effects[PBEffects::FirstPledge]==0x108   # Water Pledge
        @overridetype=true
      end
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if @doubledamage
      return basedmg*1.875
    end
    return basedmg
  end

  def pbModifyType(type,attacker,opponent)
    if @overridetype
      type=getConst(PBTypes,:WATER) || 0
    end
    return super(type,attacker,opponent)
  end

  def pbEffect(attacker,opponent)
    if !@battle.doublebattle || !attacker.pbPartner || attacker.pbPartner.fainted?
      attacker.effects[PBEffects::FirstPledge]=0
      return super(attacker,opponent)
    end
    # Combined move's effect
    if attacker.effects[PBEffects::FirstPledge]==0x106   # Grass Pledge
      ret=super(attacker,opponent)
      if opponent.damagestate.calcdamage>0
        attacker.pbOpposingSide.effects[PBEffects::SeaOfFire]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A sea of fire enveloped the opposing team!"))
        else
          @battle.pbDisplay(_INTL("A sea of fire enveloped your team!"))
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    elsif attacker.effects[PBEffects::FirstPledge]==0x108   # Water Pledge
      ret=super(attacker,opponent)
      if opponent.damagestate.calcdamage>0
        attacker.pbOwnSide.effects[PBEffects::Rainbow]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A rainbow appeared in the sky on your team's side!"))
        else
          @battle.pbDisplay(_INTL("A rainbow appeared in the sky on the opposing team's side!"))
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    end
    # Set up partner for a combined move
    attacker.effects[PBEffects::FirstPledge]=0
    partnermove=-1
    if @battle.choices[attacker.pbPartner.index][0]==1 # Chose a move
      if !attacker.pbPartner.hasMovedThisRound?
        move=@battle.choices[attacker.pbPartner.index][2]
        if move && move.id>0
          partnermove=@battle.choices[attacker.pbPartner.index][2].function
        end
      end
    end
    if partnermove==0x106 ||   # Grass Pledge
       partnermove==0x108      # Water Pledge
      @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",attacker.pbThis,attacker.pbPartner.pbThis(true)))
      attacker.pbPartner.effects[PBEffects::FirstPledge]=@function
      attacker.pbPartner.effects[PBEffects::MoveNext]=true
      return 0
    end
    # Use the move on its own
    return super(attacker,opponent)
  end

  def pbShowAnimation(id,attacker,opponent)
    if @overridetype
      return super(getConst(PBMoves,:WATERPLEDGE),attacker,opponent)
    end
    return super(id,attacker,opponent)
  end
end



################################################################################
# If used after ally's Grass Pledge, makes a swamp appear on the opposing side.
################################################################################
class PokeBattle_Move_108 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @doubledamage=false; @overridetype=false
    if attacker.effects[PBEffects::FirstPledge]==0x106 ||   # Grass Pledge
       attacker.effects[PBEffects::FirstPledge]==0x107      # Fire Pledge
      @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
      @doubledamage=true
      if attacker.effects[PBEffects::FirstPledge]==0x106   # Grass Pledge
        @overridetype=true
      end
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if @doubledamage
      return basedmg*1.875
    end
    return basedmg
  end

  def pbModifyType(type,attacker,opponent)
    if @overridetype
      type=getConst(PBTypes,:GRASS) || 0
    end
    return super(type,attacker,opponent)
  end

  def pbEffect(attacker,opponent)
    if !@battle.doublebattle || !attacker.pbPartner || attacker.pbPartner.fainted?
      attacker.effects[PBEffects::FirstPledge]=0
      return super(attacker,opponent)
    end
    # Combined move's effect
    if attacker.effects[PBEffects::FirstPledge]==0x106   # Grass Pledge
      ret=super(attacker,opponent)
      if opponent.damagestate.calcdamage>0
        attacker.pbOpposingSide.effects[PBEffects::Swamp]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A swamp enveloped the opposing team!"))
        else
          @battle.pbDisplay(_INTL("A swamp enveloped your team!"))
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    elsif attacker.effects[PBEffects::FirstPledge]==0x107   # Fire Pledge
      ret=super(attacker,opponent)
      if opponent.damagestate.calcdamage>0
        attacker.pbOwnSide.effects[PBEffects::Rainbow]=4
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("A rainbow appeared in the sky on your team's side!"))
        else
          @battle.pbDisplay(_INTL("A rainbow appeared in the sky on the opposing team's side!"))
        end
      end
      attacker.effects[PBEffects::FirstPledge]=0
      return ret
    end
    # Set up partner for a combined move
    attacker.effects[PBEffects::FirstPledge]=0
    partnermove=-1
    if @battle.choices[attacker.pbPartner.index][0]==1 # Chose a move
      if !attacker.pbPartner.hasMovedThisRound?
        move=@battle.choices[attacker.pbPartner.index][2]
        if move && move.id>0
          partnermove=@battle.choices[attacker.pbPartner.index][2].function
        end
      end
    end
    if partnermove==0x106 ||   # Grass Pledge
       partnermove==0x107      # Fire Pledge
      @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",attacker.pbThis,attacker.pbPartner.pbThis(true)))
      attacker.pbPartner.effects[PBEffects::FirstPledge]=@function
      attacker.pbPartner.effects[PBEffects::MoveNext]=true
      return 0
    end
    # Use the move on its own
    return super(attacker,opponent)
  end

  def pbShowAnimation(id,attacker,opponent)
    if @overridetype
      return super(getConst(PBMoves,:GRASSPLEDGE),attacker,opponent,hitnum,alltargets,showanimation)
    end
    return super(id,attacker,opponent)
  end
end



################################################################################
# Scatters coins that the player picks up after winning the battle.
################################################################################
class PokeBattle_Move_109 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      if @battle.pbOwnedByPlayer?(attacker.index)
        @battle.moneygained+=5*attacker.level
        @battle.moneygained=MAXMONEY if @battle.moneygained>MAXMONEY
      end
      @battle.pbDisplay(_INTL("Coins scattered everywhere!"))
    end
    return ret
  end
end



################################################################################
# Ends the opposing side's Light Screen and Reflect.
################################################################################
class PokeBattle_Move_10A < PokeBattle_Move
  def pbEffect(attacker,opponent)
    reflect=false; lightscreen=false # TODO: Actually handled earlier
    if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
      attacker.pbOpposingSide.effects[PBEffects::Reflect]=0
      reflect=true
    end
    if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
      attacker.pbOpposingSide.effects[PBEffects::LightScreen]=0
      lightscreen=true
    end
    ret=super(attacker,opponent)
    if reflect && lightscreen
      @battle.pbDisplayPaused(_INTL("The opposing team's Reflect wore off!"))
      @battle.pbDisplay(_INTL("The opposing team's Light Screen wore off!"))
    else
      @battle.pbDisplay(_INTL("The opposing team's Reflect wore off!")) if reflect
      @battle.pbDisplay(_INTL("The opposing team's Light Screen wore off!")) if lightscreen
    end
    return ret
  end
end



################################################################################
# If attack misses, user takes crash damage of 1/2 of max HP.
################################################################################
class PokeBattle_Move_10B < PokeBattle_Move
  def unusableInGravity?
    return true
  end
end



################################################################################
# User turns 1/4 of max HP into a substitute.
################################################################################
class PokeBattle_Move_10C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1} already has a Substitute!",attacker.pbThis))
      return -1
    end
    sublife=[(attacker.totalhp/4).floor,1].max
    if attacker.hp<=sublife
      @battle.pbDisplay(_INTL("It was too weak to make a Substitute!"))
      return -1  
    end
    @battle.pbAnimation(@id,attacker,nil)
    @battle.scene.pbChangePokemon(attacker,attacker.pokemon,true)
    attacker.pbReduceHP(sublife)
    attacker.effects[PBEffects::MultiTurn]=0
    attacker.effects[PBEffects::MultiTurnAttack]=0
    attacker.effects[PBEffects::Substitute]=sublife
    @battle.pbDisplay(_INTL("{1} made a Substitute!",attacker.pbThis))
    attacker.pbBerryCureCheck(true)
    return 0
  end
end



################################################################################
# User is not Ghost: Decreases user's Speed, increases user's Attack & Defense by
# 1 stage each.
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
################################################################################
class PokeBattle_Move_10D < PokeBattle_Move
  def pbEffect(attacker,opponent)
    failed=false
    if !attacker.pbHasType?(:GHOST)
      lowerspeed=!attacker.pbTooLow?(PBStats::SPEED)
      raiseatk=!attacker.pbTooHigh?(PBStats::ATTACK)
      raisedef=!attacker.pbTooHigh?(PBStats::DEFENSE)
      if !lowerspeed && !raiseatk && !raisedef
        failed=true
      else
        @battle.pbAnimation(@id,attacker,nil)
        if lowerspeed
          attacker.pbReduceStatBasic(PBStats::SPEED,1)
          @battle.pbCommonAnimation("StatDown",attacker,nil)
          @battle.pbDisplay(_INTL("{1}'s Speed fell!",attacker.pbThis))  
        else
          @battle.pbDisplay(_INTL("{1}'s Speed won't go lower!",attacker.pbThis))  
        end
        hadanim=false
        if raiseatk
          attacker.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",attacker,nil); hadanim=true
          @battle.pbDisplay(_INTL("{1}'s Attack rose!",attacker.pbThis))  
        else
          @battle.pbDisplay(_INTL("{1}'s Attack won't go higher!",attacker.pbThis))  
        end
        if raisedef
          attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
          @battle.pbCommonAnimation("StatUp",attacker,nil) if !hadanim
          @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis))  
        else
          @battle.pbDisplay(_INTL("{1}'s Defense won't go higher!",attacker.pbThis))  
        end
      end
    else
      if opponent.effects[PBEffects::Curse]
        failed=true
      else
        @battle.pbAnimation(@id,attacker,opponent)
        attacker.pbReduceHP((attacker.totalhp/2).floor)
        opponent.effects[PBEffects::Curse]=true
        @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!",attacker.pbThis,opponent.pbThis(true)))
      end
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
    end
    return failed ? -1 : 0
  end
end



################################################################################
# Target's last move used loses 4 PP.
################################################################################
class PokeBattle_Move_10E < PokeBattle_Move
  def pbEffect(attacker,opponent)
    for i in opponent.moves
      if i.id==opponent.lastMoveUsed && i.id>0 && i.pp>0
        reduction=[4,i.pp].min
        i.pp-=reduction
        @battle.pbAnimation(@id,attacker,opponent)
        @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",opponent.pbThis(true),i.name,reduction))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# Target will lose 1/4 of max HP at end of each round, while asleep.
################################################################################
class PokeBattle_Move_10F < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.status!=PBStatuses::SLEEP || opponent.effects[PBEffects::Nightmare] ||
       opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    opponent.effects[PBEffects::Nightmare]=true
    @battle.pbDisplay(_INTL("{1} fell into a nightmare!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Removes trapping moves, entry hazards and Leech Seed on user/user's side.
################################################################################
class PokeBattle_Move_110 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      if attacker.effects[PBEffects::MultiTurn]>0
        mtuser=@battle.battlers[attacker.effects[PBEffects::MultiTurnUser]]
        mtattack=PBMoves.getName(attacker.effects[PBEffects::MultiTurnAttack])
        @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!",attacker.pbThis,mtuser.pbThis(true),mtattack))
        attacker.effects[PBEffects::MultiTurn]=-1
        attacker.effects[PBEffects::MultiTurnUser]=-1
        attacker.effects[PBEffects::MultiTurnAttack]=0
      end
      if attacker.effects[PBEffects::LeechSeed]>=0
        attacker.effects[PBEffects::LeechSeed]=-1
        @battle.pbDisplay(_INTL("{1} shed Leech Seed!",attacker.pbThis))   
      end
      if attacker.pbOwnSide.effects[PBEffects::Spikes]>0
        attacker.pbOwnSide.effects[PBEffects::Spikes]=0
        @battle.pbDisplay(_INTL("{1} blew away Spikes!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
        @battle.pbDisplay(_INTL("{1} blew away poison spikes!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::StealthRock]
        attacker.pbOwnSide.effects[PBEffects::StealthRock]=false
        @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::FireRock]
        attacker.pbOwnSide.effects[PBEffects::FireRock]=false
        @battle.pbDisplay(_INTL("{1} blew away molten rocks!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::StickyWeb]
        attacker.pbOwnSide.effects[PBEffects::StickyWeb]=false
        @battle.pbDisplay(_INTL("{1} blew away webs!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::Livewire]>0
        attacker.pbOwnSide.effects[PBEffects::Livewire]=0
        @battle.pbDisplay(_INTL("{1} removed the livewire!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::Permafrost]>0
        attacker.pbOwnSide.effects[PBEffects::Permafrost]=0
        @battle.pbDisplay(_INTL("{1} removed the frost!",attacker.pbThis))     
      end
    end
    return ret
  end
end



################################################################################
# Attacks 2 rounds in the future.
################################################################################
class PokeBattle_Move_111 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    return 0 if @battle.futuresight
    return super(attacker)
  end
  
  def pbEffect(attacker,opponent)
    #TODO: Should ignore Wonder Guard/immunity
    if opponent.effects[PBEffects::FutureSight]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.futuresight
      # Attack hits
      return super(attacker,opponent)
    end
    # Attack is launched
    #else
    #  damage=pbCalcDamage(attacker,opponent,
    #     PokeBattle_Move::NOCRITICAL|
    #     PokeBattle_Move::NOWEIGHTING|
    #     PokeBattle_Move::IGNOREPKMNTYPES)
    @battle.pbAnimation(@id,attacker,nil)
    opponent.effects[PBEffects::FutureSight]=3 
    opponent.effects[PBEffects::FutureSightLoop]=(attacker.hasWorkingAbility(:PERIODICORBIT))
    #opponent.effects[PBEffects::FutureSightDamage]=damage
    opponent.effects[PBEffects::FutureSightMove]=@id
    opponent.effects[PBEffects::FutureSightUser]=attacker.pokemonIndex
    opponent.effects[PBEffects::FutureSightUserPos]=attacker.index
    if isConst?(@id,PBMoves,:FUTURESIGHT)
      @battle.pbDisplay(_INTL("{1} foresaw an attack!",attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} chose Doom Desire as its destiny!",attacker.pbThis))
    end
    return 0
    #end
  end
  
  def pbShowAnimation(id,attacker,opponent)
    if @battle.futuresight
      return super(id,attacker,opponent) # Hit opponent anim
    end
    return super(id,attacker,opponent)
  end
end



################################################################################
# Increases user's Defense and Special Defense by 1 stage each.  Ups user's
# stockpile by 1 (max. 3).
################################################################################
class PokeBattle_Move_112 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::Stockpile]>=3
      @battle.pbDisplay(_INTL("{1} can't stockpile any more!",attacker.pbThis))
      return -1
    else
      attacker.effects[PBEffects::Stockpile]+=1
      @battle.pbAnimation(@id,attacker,nil)
      @battle.pbDisplay(_INTL("{1} stockpiled {2}!",attacker.pbThis,
         attacker.effects[PBEffects::Stockpile]))
      hadanim=false
      if !attacker.pbTooHigh?(PBStats::DEFENSE)
        attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
        attacker.effects[PBEffects::StockpileDef]+=1
        @battle.pbCommonAnimation("StatUp",attacker,nil); hadanim=true
        @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis)) 
      end
      if !attacker.pbTooHigh?(PBStats::SPDEF)
        attacker.pbIncreaseStatBasic(PBStats::SPDEF,1)
        attacker.effects[PBEffects::StockpileSpDef]+=1
        @battle.pbCommonAnimation("StatUp",attacker,nil) if !hadanim
        @battle.pbDisplay(_INTL("{1}'s Special Defense rose!",attacker.pbThis)) 
      end
      return 0
    end
  end
end



################################################################################
# Power is multiplied by the user's stockpile (X).  Reduces the stockpile to 0.
# Decreases user's Defense and Special Defense by X stages each.
################################################################################
class PokeBattle_Move_113 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return (attacker.effects[PBEffects::Stockpile]==0)
  end
  
  def pbEffect(attacker,opponent)
    ret=super
    hadanim=false
    if attacker.effects[PBEffects::StockpileDef]>0
      attacker.pbReduceStatBasic(PBStats::DEFENSE,attacker.effects[PBEffects::StockpileDef])
      @battle.pbCommonAnimation("StatDown",attacker,nil); hadanim=true
      case attacker.effects[PBEffects::StockpileDef]
      when 1
        @battle.pbDisplay(_INTL("{1}'s Defense fell!",attacker.pbThis)) 
      when 2
        @battle.pbDisplay(_INTL("{1}'s Defense harshly fell!",attacker.pbThis))
      when 3
        @battle.pbDisplay(_INTL("{1}'s Defense severely fell!",attacker.pbThis))
      end
    end
    if attacker.effects[PBEffects::StockpileSpDef]>0
      attacker.pbReduceStatBasic(PBStats::SPDEF,attacker.effects[PBEffects::StockpileSpDef])
      @battle.pbCommonAnimation("StatDown",attacker,nil) if !hadanim
      case attacker.effects[PBEffects::StockpileSpDef]
      when 1
        @battle.pbDisplay(_INTL("{1}'s Special Defense fell!",attacker.pbThis)) 
      when 2
        @battle.pbDisplay(_INTL("{1}'s Special Defense harshly fell!",attacker.pbThis))
      when 3
        @battle.pbDisplay(_INTL("{1}'s Special Defense severely fell!",attacker.pbThis)) 
      end
    end
    attacker.effects[PBEffects::Stockpile]=0
    attacker.effects[PBEffects::StockpileDef]=0
    attacker.effects[PBEffects::StockpileSpDef]=0
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",attacker.pbThis))
    return ret
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return 100*attacker.effects[PBEffects::Stockpile]
  end
end



################################################################################
# Heals user depending on the user's stockpile (X).  Reduces the stockpile to 0.
# Decreases user's Defense and Special Defense by X stages each.
################################################################################
class PokeBattle_Move_114 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    hpgain=0
    case attacker.effects[PBEffects::Stockpile]
      when 0
        @battle.pbDisplay(_INTL("But it failed to swallow a thing!"))
        return -1
      when 1
        hpgain=(attacker.totalhp/4).floor
      when 2
        hpgain=(attacker.totalhp/2).floor
      when 3
        hpgain=attacker.totalhp
    end
    if attacker.hp==attacker.totalhp &&
       attacker.effects[PBEffects::StockpileDef]==0 &&
       attacker.effects[PBEffects::StockpileSpDef]==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,opponent)
      if attacker.pbRecoverHP(hpgain)>0
        @battle.pbDisplay(_INTL("{1} regained health!",attacker.pbThis))
      end
      hadanim=false
      if attacker.effects[PBEffects::StockpileDef]>0
        attacker.pbReduceStatBasic(PBStats::DEFENSE,attacker.effects[PBEffects::StockpileDef])
        @battle.pbCommonAnimation("StatDown",attacker,nil); hadanim=true
        case attacker.effects[PBEffects::StockpileDef]
        when 1
          @battle.pbDisplay(_INTL("{1}'s Defense fell!",attacker.pbThis)) 
        when 2
          @battle.pbDisplay(_INTL("{1}'s Defense harshly fell!",attacker.pbThis))
        when 3
          @battle.pbDisplay(_INTL("{1}'s Defense severely fell!",attacker.pbThis))
        end
      end
      if attacker.effects[PBEffects::StockpileSpDef]>0
        attacker.pbReduceStatBasic(PBStats::SPDEF,attacker.effects[PBEffects::StockpileSpDef])
        @battle.pbCommonAnimation("StatDown",attacker,nil) if !hadanim
        case attacker.effects[PBEffects::StockpileSpDef]
        when 1
          @battle.pbDisplay(_INTL("{1}'s Special Defense fell!",attacker.pbThis)) 
        when 2
          @battle.pbDisplay(_INTL("{1}'s Special Defense harshly fell!",attacker.pbThis))
        when 3
          @battle.pbDisplay(_INTL("{1}'s Special Defense severely fell!",attacker.pbThis)) 
        end
      end
      attacker.effects[PBEffects::Stockpile]=0
      attacker.effects[PBEffects::StockpileDef]=0    
      attacker.effects[PBEffects::StockpileSpDef]=0  
      @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# Fails if user was hit by a damaging move this round.
################################################################################
class PokeBattle_Move_115 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    if attacker.lastHPLost > 0
      @battle.pbDisplayBrief(_INTL("{1} lost its focus and couldn't move!",attacker.pbThis))
      for move in attacker.moves
        if move.id==@id
          move.pp+=1
          break
        end
      end
      attacker.effects[PBEffects::SkipTurn]=true
      return -1
    end
    #else
      #@battle.pbCommonAnimation("StatUp",attacker,nil)
      #@battle.pbDisplay(_INTL("{1} is tightening its focus!",attacker.pbThis))
    return super(attacker)
  end
end



################################################################################
# Fails if the target didn't chose a damaging move to use this round, or has
# already moved.
################################################################################
class PokeBattle_Move_116 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if @battle.choices[opponent.index][0]!=1 # Didn't choose a move
    oppmove=@battle.choices[opponent.index][2]
    return true if !oppmove || oppmove.id<=0 || oppmove.pbIsStatus?
    return true if opponent.hasMovedThisRound? && oppmove.function!=0xB0 # Me First
    return false
  end
  
#def pbDisplayUseMessage(attacker)
#  attacker.effects[PBEffects::SuckerPunch]=true
#  return super
#end

  #def pbEffect(attacker,opponent)
    
#    Kernel.pbMessage("1") if @battle == nil || @battle.choices == nil || @battle.choices[opponent.index] == nil
 
#    Kernel.pbMessage("2") if @battle.choices[opponent.index][2] == nil || @battle.choices[opponent.index][2].basedamage == 0
    
#    Kernel.pbMessage("3") if attacker.effects[PBEffects::SuckerPunch]==false
    
    #if @battle == nil || @battle.choices == nil || @battle.choices[opponent.index] == nil || 
     # @battle.choices[opponent.index][2] == nil || @battle.choices[opponent.index][2].basedamage == 0 || 
     # attacker.effects[PBEffects::SuckerPunch]==false
      
     # @battle.pbDisplay(_INTL("But it failed!"))
     # return -1      
    #else
#      if @battle.priority.index(opponent) < @battle.priority.index(attacker)
#            @battle.pbDisplay(_INTL("But it failed!"))
#      return -1      

#      end
      #attacker.effects[PBEffects::SuckerPunch]=false
      #return super
      #end
  #end
end



################################################################################
# This round, user becomes the target of attacks that have single targets.
################################################################################
class PokeBattle_Move_117 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if !@battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @id==PBMoves::FOLLOWME
      attacker.effects[PBEffects::FollowMe]=1
      if !attacker.pbPartner.fainted? && attacker.pbPartner.effects[PBEffects::FollowMe]>0
        attacker.effects[PBEffects::FollowMe]=attacker.pbPartner.effects[PBEffects::FollowMe]+1
      end
    else
      attacker.effects[PBEffects::RagePowder]=1
      if !attacker.pbPartner.fainted? && attacker.pbPartner.effects[PBEffects::RagePowder]>0
        attacker.effects[PBEffects::RagePowder]=attacker.pbPartner.effects[PBEffects::RagePowder]+1
      end
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!",attacker.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, increases gravity on the field.  Pokémon cannot become airborne.
################################################################################
class PokeBattle_Move_118 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    #if attacker.pbOwnSide.effects[PBEffects::Gravity]>0 ||
    #   attacker.pbOpposingSide.effects[PBEffects::Gravity]>0
    # @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    if @battle.field.effects[PBEffects::Gravity]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil,true)
    @battle.field.effects[PBEffects::Gravity]=5
    for i in 0...4
      poke=@battle.battlers[i]
      next if !poke
      if PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
         PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xCC || # Bounce
         PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xCE    # Sky Drop
        poke.effects[PBEffects::TwoTurnAttack]=0
      end
      if poke.effects[PBEffects::SkyDrop]
        poke.effects[PBEffects::SkyDrop]=false
      end
      if poke.effects[PBEffects::SkyDropPartnerPos]!=-1
        poke.effects[PBEffects::SkyDropPartnerPos]=-1
      end
      if poke.effects[PBEffects::MagnetRise]>0
        poke.effects[PBEffects::MagnetRise]=0
      end
      if poke.effects[PBEffects::Telekinesis]>0
        poke.effects[PBEffects::Telekinesis]=0
      end
    end
    @battle.pbDisplay(_INTL("Gravity intensified!"))
    return 0
    #else
    #  attacker.pbOwnSide.effects[PBEffects::Gravity]=5
    #  attacker.pbOpposingSide.effects[PBEffects::Gravity]=5
    #  for i in 0...4
    #    poke=@battle.battlers[i]
    #    next if !poke
    #    if isConst?(poke.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
    #       isConst?(poke.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
    #       isConst?(poke.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP)
    #      poke.effects[PBEffects::TwoTurnAttack]=0
    #   end
    #    if poke.effects[PBEffects::SkyDrop]
    #      poke.effects[PBEffects::SkyDrop]=false
    #    end
    #    if poke.effects[PBEffects::MagnetRise]>0
    #      poke.effects[PBEffects::MagnetRise]=0
    #    end
    #    if poke.effects[PBEffects::Telekinesis]>0
    #      poke.effects[PBEffects::Telekinesis]=0
    #    end
    #  end
    #  @battle.pbDisplay(_INTL("Gravity intensified!"))
    #  return 0
    #end
  end
end



################################################################################
# For 5 rounds, user becomes airborne.
################################################################################
class PokeBattle_Move_119 < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::Ingrain] ||
       attacker.effects[PBEffects::SmackDown] ||
       attacker.effects[PBEffects::MagnetRise]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      attacker.effects[PBEffects::MagnetRise]=5
      @battle.pbAnimation(@id,attacker,nil,true)
      @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# For 3 rounds, target becomes airborne and can always be hit.
################################################################################
class PokeBattle_Move_11A < PokeBattle_Move
  def unusableInGravity?
    return true
  end

  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Ingrain] ||
       opponent.effects[PBEffects::SmackDown] ||
       opponent.effects[PBEffects::Telekinesis]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      opponent.effects[PBEffects::Telekinesis]=3
      @battle.pbAnimation(@id,attacker,opponent,true)
      @battle.pbDisplay(_INTL("{1} was hurled into the air!",opponent.pbThis))
      return 0
    end
  end
end




################################################################################
# Hits airborne semi-invulnerable targets.
################################################################################
class PokeBattle_Move_11B < PokeBattle_Move
# Handled in Battler class, do not edit!
end



################################################################################
# Hits airborne semi-invulnerable targets.  Grounds the target while it remains
# active.
################################################################################
class PokeBattle_Move_11C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent && attacker
      if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
         !opponent.effects[PBEffects::Roost]
        showmsg=false
        showmsg=true if opponent.isAirborne?(attacker.hasMoldBreaker)
        if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
           isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE)
          opponent.effects[PBEffects::TwoTurnAttack]=0
          showmsg=true
        end
        if opponent.effects[PBEffects::MagnetRise]>0
          opponent.effects[PBEffects::MagnetRise]=0
          showmsg=true
        end
        if opponent.effects[PBEffects::Telekinesis]>0
          opponent.effects[PBEffects::Telekinesis]=0
          showmsg=true
        end
        opponent.effects[PBEffects::SmackDown]=true if showmsg
        @battle.pbDisplay(_INTL("{1} fell straight down!",opponent.pbThis)) if showmsg
      end
    end
    return ret
  end
end



################################################################################
# Target moves immediately after the user, ignoring priority/speed.
################################################################################
class PokeBattle_Move_11D < PokeBattle_Move
  def pbEffect(attacker,opponent)
    opponent.effects[PBEffects::MoveNext]=true
    opponent.effects[PBEffects::Quash]=false
    @battle.pbDisplay(_INTL("{1} took the kind offer!",opponent.pbThis))
    return 0
  end
  
  def pbMoveFailed(attacker,opponent)
    return true if opponent.effects[PBEffects::MoveNext]
    return true if @battle.choices[opponent.index][0]!=1 # Didn't choose a move
    oppmove=@battle.choices[opponent.index][2]
    return true if !oppmove || oppmove.id<=0
    return true if opponent.hasMovedThisRound?
    return false
  end
end



################################################################################
# Target moves last this round, ignoring priority/speed.
################################################################################
class PokeBattle_Move_11E < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if opponent.effects[PBEffects::Quash]
    return true if @battle.choices[opponent.index][0]!=1 # Didn't choose a move
    oppmove=@battle.choices[opponent.index][2]
    return true if !oppmove || oppmove.id<=0
    return true if opponent.hasMovedThisRound?
    return false
  end

  def pbEffect(attacker,opponent)
    opponent.effects[PBEffects::Quash]=true
    opponent.effects[PBEffects::MoveNext]=false
    @battle.pbDisplay(_INTL("{1}'s move was postponed!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, for each priority bracket, slow Pokémon move before fast ones.
################################################################################
class PokeBattle_Move_11F < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.field.effects[PBEffects::TrickRoom]>0
      @battle.field.effects[PBEffects::TrickRoom]=0
      @battle.pbDisplay(_INTL("{1} reverted the dimensions!",attacker.pbThis))
    else
      @battle.field.effects[PBEffects::TrickRoom]=5
      @battle.field.effects[PBEffects::TrickRoom]=8 if isConst?(attacker.item,PBItems,:TRICKROCK)
      @battle.pbDisplay(_INTL("{1} twisted the dimensions!",attacker.pbThis))
    end
    return 0
      #@battle.trickroom=5
      #@battle.pbDisplay(_INTL("{1} twisted the dimensions!",attacker.pbThis))
  end
  
end



################################################################################
# User switches places with its ally.
################################################################################
class PokeBattle_Move_120 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if !@battle.doublebattle ||
       !attacker.pbPartner || attacker.pbPartner.fainted?
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if !attacker.effects[PBEffects::AllySwitch]
      attacker.effects[PBEffects::AllySwitch]=true
      attacker.pbPartner.effects[PBEffects::AllySwitch]=true
    else
      attacker.effects[PBEffects::AllySwitch]=false
      attacker.pbPartner.effects[PBEffects::AllySwitch]=false
    end
=begin
    a=@battle.battlers[attacker.index]
    b=@battle.battlers[attacker.pbPartner.index]
    
    choices=[]
    choices[0]=b
    choices[1]=a
    
    temp=a; a=b; b=temp
    # Swap effects that point at the position rather than the Pokémon
    # NOT PerishSongUser (no need to swap), Attract, MultiTurnUser
    effectstoswap=[PBEffects::BideTarget,
                   PBEffects::CounterTarget,
                   PBEffects::LeechSeed,
                   PBEffects::LockOnPos,
                   PBEffects::MeanLook,
                   PBEffects::MirrorCoatTarget]
    for i in effectstoswap
      choices[1].effects[i],choices[0].effects[i]=choices[0].effects[i],choices[1].effects[i]
    end
    
    a1=attacker.index
    b1=attacker.pbPartner.index
    Kernel.pbMessage(_INTL("Species 1: {1}",@battle.battlers[a1].species.to_s))
    Kernel.pbMessage(_INTL("Species 2: {1}",@battle.battlers[b1].species.to_s))
    
    @battle.battlers[a1]=choices[0]
    @battle.battlers[b1]=choices[1]
    Kernel.pbMessage(_INTL("Species 1.1: {1}",@battle.battlers[a1].species.to_s))
    Kernel.pbMessage(_INTL("Species 2.1: {1}",@battle.battlers[b1].species.to_s))
    Kernel.pbMessage("2")
    
    @battle.scene.pbChangePokemon(@battle.battlers[a1],@battle.battlers[a1].pokemon,true) if @battle.battlers[a1].effects[PBEffects::Substitute]!=0
    @battle.scene.pbChangePokemon(@battle.battlers[b1],@battle.battlers[b1].pokemon,true) if @battle.battlers[b1].effects[PBEffects::Substitute]!=0
    @battle.battlers[a1].pbUpdate(true)
    @battle.battlers[b1].pbUpdate(true)
    Kernel.pbMessage(_INTL("Species 1.2: {1}",@battle.battlers[a1].species.to_s))
    Kernel.pbMessage(_INTL("Species 2.2: {1}",@battle.battlers[b1].species.to_s))
    @battle.scene.pbGraphicsUpdate
    Kernel.pbMessage("3")
    @battle.scene.pbRefresh
=end
    @battle.pbDisplay(_INTL("{1} and {2} switched places!",@battle.battlers[attacker.index].pbThis,@battle.battlers[attacker.pbPartner.index].pbThis(true)))
  end
end



################################################################################
# Target's Attack is used instead of user's Attack for this move's calculations.
################################################################################
class PokeBattle_Move_121 < PokeBattle_UnimplementedMove
# Handled elsewhere, do not edit!
end



################################################################################
# Target's Defense is used instead of its Special Defense for this move's
# calculations.
################################################################################
class PokeBattle_Move_122 < PokeBattle_Move
# Handled in superclass, do not edit!
end



################################################################################
# Only damages Pokémon that share a type with the user.
################################################################################
class PokeBattle_Move_123 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.pbHasType?(attacker.type1) ||
       opponent.pbHasType?(attacker.type2) ||
       (opponent.effects[PBEffects::ForestsCurse] && attacker.pbHasType?(:GRASS)) ||
       (opponent.effects[PBEffects::TrickOrTreat] && attacker.pbHasType?(:GHOST))
      return super(attacker,opponent)
    else
      @battle.pbDisplay(_INTL("{1} was unaffected!",opponent.pbThis))
      return -1
    end
  end
end



################################################################################
# For 5 rounds, swaps all battlers' base Defense with base Special Defense.
################################################################################
class PokeBattle_Move_124 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.field.effects[PBEffects::WonderRoom]>0
      @battle.field.effects[PBEffects::WonderRoom]=0
      @battle.pbDisplay(_INTL("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!"))
    else
      @battle.field.effects[PBEffects::WonderRoom]=5
      @battle.pbDisplay(_INTL("It created a bizarre area in which the Defense and Sp. Def stats are swapped!"))
    end
    return 0
  end
end



################################################################################
# Fails unless user has already used all other moves it knows. (Last Resort)
################################################################################
class PokeBattle_Move_125 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    counter=0; nummoves=0
    for move in attacker.moves
      next if move.id<=0
      counter+=1 if move.id!=@id && !attacker.movesUsed.include?(move.id)
      nummoves+=1
    end
    return counter!=0 || nummoves==1
  end
end



#########################################
#
#########################################
class PokeBattle_Move_133 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ATTACK)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.stages[PBStats::DEFENSE]=-6
    attacker.stages[PBStats::ATTACK]=6
    @battle.pbCommonAnimation("StatUp",attacker,nil)
    @battle.pbDisplay(_INTL("{1} entered a Rage State and maximized its attack!",attacker.pbThis))
    return 0
  end
end
class PokeBattle_Move_134 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.stages[PBStats::DEFENSE]=6
    attacker.stages[PBStats::ATTACK]=-6
    @battle.pbCommonAnimation("StatUp",attacker,nil)
    @battle.pbDisplay(_INTL("{1} adapted and maximized its defense!",attacker.pbThis))
    return 0
  end
end
#===============================================================================
# NOTE: Shadow moves use function codes 126-132 inclusive.  If you're inventing
#       new move effects, use function code 133 and onwards.
#===============================================================================

class PokeBattle_Move_135 < PokeBattle_Move
  def pbType(type,attacker,opponent)
    if $game_variables[98] == 0
      return getConst(PBTypes,:NORMAL)
    end
    if $game_variables[98] == 1
      return getConst(PBTypes,:GRASS)
    end
    if $game_variables[98] == 2
      return getConst(PBTypes,:FIRE)
    end
    if $game_variables[98] == 3
      return getConst(PBTypes,:WATER)
    end
    if $game_variables[98] == 4
      return getConst(PBTypes,:POISON)
    end
    if $game_variables[98] == 5
      return getConst(PBTypes,:FIGHTING)
    end
    if $game_variables[98] == 6
      return getConst(PBTypes,:DARK)
    end
    if $game_variables[98] == 7
      return getConst(PBTypes,:PSYCHIC)
    end
    if $game_variables[98] == 8
      return getConst(PBTypes,:GHOST)
    end
    if $game_variables[98] == 9
      return getConst(PBTypes,:ICE)
    end
    if $game_variables[98] == 10
      return getConst(PBTypes,:GROUND)
    end
    if $game_variables[98] == 11
      return getConst(PBTypes,:ROCK)
    end
    if $game_variables[98] == 12
      return getConst(PBTypes,:FLYING)
    end
     if $game_variables[98] == 13
      return getConst(PBTypes,:BUG)
    end
    if $game_variables[98] == 14
      return getConst(PBTypes,:ELECTRIC)
    end
    if $game_variables[98] == 15
      return getConst(PBTypes,:DRAGON)
    end
    if $game_variables[98] == 16
      return getConst(PBTypes,:STEEL)
    end
    if $game_variables[98] == 17
      return getConst(PBTypes,:FAIRY)
    end

    return getConst(PBTypes,:NORMAL)
  end
 # def pbEffect(attacker,opponent)
 #   ret = super
 #         @battle.pbDisplay(_INTL("{1} used {2}!",attacker.pbThis,$game_variables[100]))
 #         return ret;
 # end
end

###############################################################################
# Entry hazard.  Lays livewire on the opposing side (max. 5 layers).
################################################################################
class PokeBattle_Move_136 < PokeBattle_Move 
  def pbEffect(attacker,opponent)
    if attacker.pbOpposingSide.effects[PBEffects::Livewire] > 4
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil,true)
      attacker.pbOpposingSide.effects[PBEffects::Livewire]+=1
      @battle.pbDisplay(_INTL("Wires were set at the feet of the foe!"))
      return 0
    end
  end
end

################################################################################
# Increases the user's accuracy by 2 stages.
################################################################################
class PokeBattle_Move_137 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::ACCURACY)
      @battle.pbDisplay(_INTL("{1}'s stats won't go higher!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    if !attacker.pbTooHigh?(PBStats::ACCURACY)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::ACCURACY,2)
      @battle.pbDisplay(_INTL("{1}'s accuracy sharply rose!",attacker.pbThis))
    end
    return 0
  end
end
################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# Power halved in sunshine. 
################################################################################
class PokeBattle_Move_138 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
    if attacker.effects[PBEffects::TwoTurnAttack]==0
      @immediate=true if @battle.pbWeather==PBWeather::NEWMOON
    end
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      @immediate=true
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end
  def pbBaseDamage(basedmg,attacker,opponent)
    if (@battle.weather==PBWeather::SUNNYDAY || @battle.weather==PBWeather::HARSHSUN)
      return (basedmg*0.5).floor
    else
      return basedmg
    end
  end
  def pbEffect(attacker,opponent)
    if @immediate
      if isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
#      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} absorbed darkness!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
#      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} absorbed darkness!",attacker.pbThis))
      return 0
    end
    return super
  end
end


class PokeBattle_Move_139 < PokeBattle_Move #Renaissance
  def pbEffect(attacker,opponent)
    ret=0
    if attacker.hp>0 && @battle.pbCanChooseNonActive?(attacker.index)
      newpoke=0
      $game_switches[158] = true
      newpoke=@battle.pbSwitchInBetween(attacker.index,true,false)
      @battle.pbMessagesOnReplace(attacker.index,newpoke)
      attacker.pbResetForm
      @battle.pbReplace(attacker.index,newpoke,true)
      @battle.pbOnActiveOne(attacker)
      attacker.pbAbilitiesOnSwitchIn(true)
          $game_switches[158] = false

      end
    return ret
    end
  end
  
################################################################################
# FLASH FREEZE
################################################################################
class PokeBattle_Move_140 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasWorkingAbility(:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if isConst?(opponent.type1,PBTypes,:ICE) && isConst?(opponent.type2,PBTypes,:ICE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.type1=PBTypes::ICE
    opponent.type2=PBTypes::ICE
    typename=PBTypes.getName(opponent.type1)
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end

################################################################################
# PERMAFROST
################################################################################
class PokeBattle_Move_141 < PokeBattle_Move 
  def pbEffect(attacker,opponent)
    if attacker.pbOpposingSide.effects[PBEffects::Permafrost] > 4
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil,true)
      attacker.pbOpposingSide.effects[PBEffects::Permafrost]+=1
      @battle.pbDisplay(_INTL("A layer of frost was created over the ground!"))
      return 0
    end
  end
end



################################################################################
# MEDUSA RAY
################################################################################
class PokeBattle_Move_142 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasWorkingAbility(:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if isConst?(opponent.type1,PBTypes,:ROCK) && isConst?(opponent.type2,PBTypes,:ROCK)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.type1=PBTypes::ROCK
    opponent.type2=PBTypes::ROCK
    typename=PBTypes.getName(opponent.type1)
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} solidified into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end



################################################################################
# ANGEL WINGS
################################################################################
class PokeBattle_Move_143 < PokeBattle_Move
  def pbEffect(attacker,opponent)
   # Kernel.pbMessage("hah")
    if attacker.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
  #      Kernel.pbMessage("hah2")

    if attacker.hasWorkingAbility(:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
 #       Kernel.pbMessage("hah3")

    if isConst?(attacker.type1,PBTypes,:WEAK) && isConst?(attacker.type2,PBTypes,:WEAK)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
#        Kernel.pbMessage("hah4")
@battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("{1} grew a pair of wings!",attacker.pbThis))

    attacker.type1=PBTypes::WEAK
    attacker.type2=PBTypes::WEAK
       # Kernel.pbMessage("hah5")
     if attacker.pbTooHigh?(PBStats::ATTACK)
        @battle.pbDisplay(_INTL("{1}'s Attack won't go higher!",attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1}'s Attack rose sharply!",attacker.pbThis))
      attacker.pbIncreaseStatBasic(PBStats::ATTACK,2)
    end
       if attacker.pbTooHigh?(PBStats::SPATK)
        @battle.pbDisplay(_INTL("{1}'s Special Attack won't go higher!",attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1}'s Special Attack rose sharply!",attacker.pbThis))
      attacker.pbIncreaseStatBasic(PBStats::SPATK,2)
    end
    
    
      if attacker.pbTooHigh?(PBStats::SPEED)
        @battle.pbDisplay(_INTL("{1}'s Speed won't go higher!",attacker.pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s Speed rose!",attacker.pbThis))
        attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
      end

    #attacker.pbIncreaseStatBasic(PBStats::SPEED,1)

#    Kernel.pbMessage("hah6")

    typename=PBTypes.getName(attacker.type1)
 #       Kernel.pbMessage("haha8")

#    @battle.pbAnimation(@id,attacker,opponent)
    return 0
  end
end



################################################################################
# POWER SHRINE
################################################################################
class PokeBattle_Move_145 < PokeBattle_Move 
  def pbEffect(attacker,opponent)
    if opponent.pbOpposingSide.effects[PBEffects::PowerShrine] > 0 || opponent.pbOpposingSide.effects[PBEffects::SpecialShrine] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil,true)
      opponent.pbOpposingSide.effects[PBEffects::PowerShrine] = 2
      @battle.pbDisplay(_INTL("A shrine was constructed!"))
      return 0
    end
  end
end



################################################################################
# SPECIAL SHRINE
################################################################################
class PokeBattle_Move_146 < PokeBattle_Move 
  def pbEffect(attacker,opponent)
    if opponent.pbOpposingSide.effects[PBEffects::PowerShrine] > 0 || opponent.pbOpposingSide.effects[PBEffects::SpecialShrine] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil,true)
      opponent.pbOpposingSide.effects[PBEffects::SpecialShrine] = 2
      @battle.pbDisplay(_INTL("A shrine was constructed!"))
      return 0
    end
  end
end



################################################################################
# DRAGONIFY
################################################################################
class PokeBattle_Move_147 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasWorkingAbility(:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if isConst?(opponent.type1,PBTypes,:DRAGON) && isConst?(opponent.type2,PBTypes,:DRAGON)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.type1=PBTypes::DRAGON
    opponent.type2=PBTypes::DRAGON
    typename=PBTypes.getName(opponent.type1)
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} morphed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end




class PokeBattle_Move_148 < PokeBattle_Move
#  def pbEffect(attacker,opponent)
#  end

  def pbBaseDamage(basedmg,attacker,opponent)          
    if $ItemData[attacker.item][ITEMPRICE] > 0
      number = attacker.item
      @battle.pbDisplay(_INTL("{1} fumbled its {2} and dealt damage!",attacker.pbThis,PBItems.getName(attacker.item)))
      attacker.item = 0
      return $ItemData[number][ITEMPRICE]/40
  else
    @battle.pbDisplay(_INTL("But no damage was dealt!"))
    return 0
  end
  
  end
end


################################################################################
# WILDFIRE
################################################################################
class PokeBattle_Move_149 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    #    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanBurnFromFireMove?(attacker,self,true)

    @battle.pbDisplay(_INTL("The wildfire burned the opponent!"))
    opponent.pbBurn(opponent)
    if isConst?(opponent.type1,PBTypes,:GRASS) || isConst?(opponent.type2,PBTypes,:GRASS)
      @battle.pbDisplay(_INTL("The wildfire spread to other Pokemon weak to fire!"))
      
    party=@battle.pbParty(opponent.index)
    if party.length>1
      for i in 0..party.length-1  
       @battle.pbDisplay(_INTL("{1} was burned!",party[i].name)) if (PBTypes.getEffectiveness(PBTypes::FIRE,party[i].type1) + PBTypes.getEffectiveness(PBTypes::FIRE,party[i].type2))/2 > 4
        party[i].status=3 if (PBTypes.getEffectiveness(PBTypes::FIRE,party[i].type1)*PBTypes.getEffectiveness(PBTypes::FIRE,party[i].type2)) > 4
      end
    end
  end
  return 0
  end
end



################################################################################
# User's side is protected against status moves this round. (Crafty Shield)
################################################################################
class PokeBattle_Move_14A < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.pbOwnSide.effects[PBEffects::CraftyShield]=true
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Crafty Shield protected your team!"))
    else
      @battle.pbDisplay(_INTL("Crafty Shield protected the opposing team!"))
    end
    return 0
  end
end



################################################################################
# User is protected against damaging moves this round. Decreases the Attack of
# the user of a stopped contact move by 2 stages. (King's Shield)
################################################################################
class PokeBattle_Move_14B < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::KingsShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    protectlist=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C   # Spiky Shield
    ]
    if !protectlist.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved || (@battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor)
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.effects[PBEffects::KingsShield]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User is protected against moves that target it this round. Damages the user of
# a stopped contact move by 1/8 of its max HP. (Spiky Shield)
################################################################################
class PokeBattle_Move_14C < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.effects[PBEffects::SpikyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    protectlist=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8,   # Endure
       0x14B,  # King's Shield
       0x14C   # Spiky Shield
    ]
    if !protectlist.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved || (@battle.pbRandom(65536)>=(65536/attacker.effects[PBEffects::ProtectRate]).floor)
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    attacker.effects[PBEffects::SpikyShield]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end



class PokeBattle_Move_150 < PokeBattle_Move
  def pbEffect(attacker,opponent)
      ret=super(attacker,opponent)
      alive = []
      party=@battle.pbParty(opponent.index)

      for i in 0..party.length-1
          alive.push(party[i]) if party[i].hp > 0
      end
      
      displaymessage=false
      for i in 0..party.length-1
        if i != opponent.pokemonIndex
      @battle.pbDisplay(_INTL("The rest of the party was hit!")) if !displaymessage
      displaymessage=true
          if party[i].hp < 25
            party[i].hp=0
            else
            party[i].hp = party[i].hp - 25
          end
        end
        #Kernel.pbMessage("hey0")

      for i in 0..alive.length-1
          #  Kernel.pbMessage("hey1")

        inbattle=false
                  #    Kernel.pbMessage("hey1.6") if @battle
                  #    Kernel.pbMessage("hey1.7") if @battle.battlers
                  #    Kernel.pbMessage("hey1.8") if @battle.battlers.length>-1

                  for i in 0..@battle.battlers.length-1
             #     Kernel.pbMessage("hey2")

                        for j in party
             #           Kernel.pbMessage("hey3")
                        inbattle=true if @battle.battlers[i].pokemon == alive[i]
             #           Kernel.pbMessage("hey4")
                        end
        #          Kernel.pbMessage("hey5")
                  end
         #   Kernel.pbMessage("hey6")

        if alive != nil && alive[i] != nil && alive[i].hp <= 0
            #  Kernel.pbMessage("hey7")

         @battle.pbDisplay(_INTL("{1} fainted!",party[i].name))
         alive[i].pbFaint
             #Kernel.pbMessage("hey8")
           end
              # Kernel.pbMessage("hey9")

             end
               #  Kernel.pbMessage("hey10")

    end
    
  #  Kernel.pbMessage("hey11")
    return ret
   end
end

class PokeBattle_Move_151 < PokeBattle_Move
    def pbBaseDamage(damage,attacker,opponent)
      if @battle.pbRandom(5) == 3 && !isConst?(opponent.type1,PBTypes,:QMARKS) && !isConst?(opponent.type2,PBTypes,:QMARKS)
      @battle.pbDisplay(_INTL("It's super effective!"))
      dmg = damage*2
    else
      dmg = damage
    end
    
    return dmg
  end
end



class PokeBattle_Move_152 < PokeBattle_Move
   def pbEffect(attacker,opponent)
           reducedstats=false
           
      for i in [PBStats::ATTACK,PBStats::DEFENSE,
                PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                PBStats::EVASION,PBStats::ACCURACY]
        if attacker.stages[i]<0
          attacker.stages[i]=0; reducedstats=true
        end
      end
      if reducedstats
        @battle.pbDisplay(_INTL("{1} restored its status!",attacker))
      end
  end
end



################################################################################
# GEOMANCY
################################################################################
class PokeBattle_Move_153 < PokeBattle_Move
  def pbTwoTurnAttack(attacker)
    @immediate=false
  #  if attacker.effects[PBEffects::TwoTurnAttack]==0
  #    @immediate=true if @battle.pbWeather==PBWeather::0DAY
  #  end
    if !@immediate && isConst?(attacker.item,PBItems,:POWERHERB)
      itemname=PBItems.getName(attacker.item)
      @immediate=true
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
      @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent)
    if @immediate
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} is shining!",attacker.pbThis))
    elsif attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{1} is shining!",attacker.pbThis))
      return 0
    end
    if attacker.pbTooHigh?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s Special Attack won't go higher!",attacker.pbThis))
    else
      @battle.pbAnimation(@id,attacker,nil)
      if @battle.weather==PBWeather::NEWMOON
        attacker.pbIncreaseStatBasic(PBStats::SPATK,1)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",attacker.pbThis))
      else
        attacker.pbIncreaseStatBasic(PBStats::SPATK,2)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Special Attack rose sharply!",attacker.pbThis))
      end
    end
    if attacker.pbTooHigh?(PBStats::SPDEF)
      @battle.pbDisplay(_INTL("{1}'s Special Defense won't go higher!",attacker.pbThis))
    else
      @battle.pbAnimation(@id,attacker,nil)
      if @battle.weather==PBWeather::NEWMOON
        attacker.pbIncreaseStatBasic(PBStats::SPDEF,1)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Special Defense rose!",attacker.pbThis))
      else
        attacker.pbIncreaseStatBasic(PBStats::SPDEF,2)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Special Defense rose sharply!",attacker.pbThis))
      end
    end
    if attacker.pbTooHigh?(PBStats::SPEED)
      @battle.pbDisplay(_INTL("{1}'s Speed won't go higher!",attacker.pbThis))
    else
      @battle.pbAnimation(@id,attacker,nil)
      if @battle.weather==PBWeather::NEWMOON
        attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Speed rose!",attacker.pbThis))
      else
        attacker.pbIncreaseStatBasic(PBStats::SPEED,2)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Speed rose sharply",attacker.pbThis))
      end
    end
    return super
  end
end



class PokeBattle_Move_154 < PokeBattle_Move
  def pbEffect(attacker,opponent)
# STOP HERE
    #    if !@battle.pbCanChooseNonActive?(opponent.index)
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return -1
    #else
      
   #   opponent.effects[PBEffects::LunarDance]=true
       if !@battle.opponent && !pbIsOpposing?(attacker.index)
           @battle.pbDisplay(_INTL("But it failed!"))
           return -1
         end
         
       if attacker.pbOwnSide.effects[PBEffects::HasMeloetta] != nil && attacker.pbOwnSide.effects[PBEffects::HasMeloetta] == 1
         @battle.pbDisplay(_INTL("But it failed!"))
       end
       
      @battle.pbAnimation(@id,opponent,nil)
              if attacker.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1} is already possessing a Pokemon!",attacker.pbThis))
      return -1
    end
    sublife=[(attacker.totalhp/4).floor,1].max
    if attacker.hp<=sublife
      @battle.pbDisplay(_INTL("It was too weak to do so!"))
      return -1  
    end
        attacker.pbReduceHP(sublife)

            @battle.pbDisplay(_INTL("{2} was corrupted by {1}'s song!",attacker.pbThis,opponent.pbThis))
      attacker.effects[PBEffects::MeloettaForme]=opponent.clone
      attacker.pbOwnSide.effects[PBEffects::HasMeloetta] = 1

    attacker.effects[PBEffects::Substitute]=sublife
    speciesname=PBSpecies.getName(opponent.species)
        attacker.species=opponent.species
        attacker.gender=opponent.gender
        attacker.form=opponent.form
        attacker.type1=opponent.type1
        attacker.item=opponent.item
        attacker.type2=opponent.type2
        attacker.ability=opponent.ability(true)
        attacker.attack=opponent.attack
        attacker.defense=opponent.defense
        attacker.speed=opponent.speed
        attacker.spatk=opponent.spatk
        attacker.spdef=opponent.spdef

          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                    PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
            attacker.stages[i]=opponent.stages[i]
          end
          for i in 0..3
            attacker.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(opponent.moves[i].id))
            attacker.moves[i].pp=5
          end

    #      @effects[PBEffects::Disable]=0
    #      @effects[PBEffects::DisableMove]=0
    
    
   # opponent.pbFaint(false,true)
   #           @battle.pbRemoveFromParty(opponent.index,opponent.pokemonIndex)
      #@battle.deleteSpriteAt(opponent.index)
 #     @battle.scene.sprites["battler#{opponent.index}"].setBitmap(nil)
    #  Kernel.pbMessage("hey") if @battle != nil
    #  Kernel.pbMessage("hey2") if @battle.scene != nil
    #  Kernel.pbMessage("hey3") if @battle.scene.sprites != nil
    #  Kernel.pbMessage("hey4") if @battle.scene.sprites["battler#{opponent.index"] != nil
  #  opponentb = opponent.clone
        @battle.pbAnimation(PBMoves::TRANSFORM,attacker,opponent)
    temppokemonindex=opponent.pokemonIndex
    if @battle.pbCanChooseNonActive?(opponent.index)
   #   Kernel.pbMessage("hey")
   #   Kernel.pbMessage("hey "+@battle.pbParty(opponent.index).length.to_s)
   #   opponent.hp=0
        for i in 0..@battle.pbParty(opponent.index).length-1
            if @battle.pbParty(opponent.index)[i] != nil && @battle.pbParty(opponent.index)[i].hp > 0 && i != opponent.pokemonIndex
#         Kernel.pbMessage("ho")

              $meloettatemp=true
              @battle.pbRecallAndReplace(opponent.index,i)
              break
            end
            
          end
#                    @battle.pbAnimation(PBMoves::TRANSFORM,attacker,opponent)

        @battle.pbRemoveFromParty(opponent.index,temppokemonindex)
        $meloettatemp=false
     # $meloettatemp=[opponent.index,opponent.pokemonIndex]
      end
      return super(attacker,opponent)
   # end
# STOP HERE
      
     # Kernel.pbMessage("yeyey")
#          @battle.pbAnimation(getConst(PBMoves,:TRANSFORM),attacker,speciesname)
   #       @battle.pbDisplay(_INTL("{1} transformed into the {2}!",pbThis,speciesname))
   end
end



################################################################################
# PARTING SHOT (???)
################################################################################
class PokeBattle_Move_155 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=-1
    if !self.isSoundBased? ||
       attacker.hasMoldBreaker || !opponent.hasWorkingAbility(:SOUNDPROOF)
      showanim=true
      if opponent.pbReduceStat(PBStats::ATTACK,1,attacker,false,self,showanim)
        showanim=false
        ret=0
      end
      if opponent.pbReduceStat(PBStats::SPATK,1,attacker,false,self,showanim)
        showanim=false
        ret=0
      end
    end
    if !attacker.fainted? &&
       @battle.pbCanChooseNonActive?(attacker.index) &&
       !@battle.pbAllFainted?(@battle.pbParty(opponent.index))
      attacker.effects[PBEffects::Uturn]=true
      ret=0
    end
    return ret
  end
  
  #def pbEffect(attacker,opponent)
  #  ret=super(attacker,opponent)
  #  
  #  if attacker.effects[PBEffects::MeloettaForme] != nil && attacker.effects[PBEffects::MeloettaForme] != 0
  #    @battle.pbDisplay(_INTL("Switching out failed!"))
  #    return ret
  #  end
  #  #return super(attacker,opponent) if @basedamage>0
  #  opponent.pbReduceStat(PBStats::ATTACK,1,true,@id,attacker)
  #  opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker)

  #  if attacker.hp>0 && @battle.pbCanChooseNonActive?(attacker.index)
  #    newpoke=0
  #    newpoke=@battle.pbSwitchInBetween(attacker.index,true,false)
  #    @battle.pbMessagesOnReplace(attacker.index,newpoke)
  #    @battle.pbReplace(attacker.index,newpoke,true)
  #    @battle.pbOnActiveOne(attacker)
  #    attacker.pbAbilitiesOnSwitchIn(true)
  #   # attacker.pbResetForm
  #    attacker.effects[PBEffects::Substitute]=0
  #    attacker.effects[PBEffects::LeechSeed]=-1
  #    attacker.effects[PBEffects::Confusion]=0
  #    attacker.pokemon.status=newpoke.pokemon.status if attacker.pokemon && newpoke && newpoke.pokemon
  #    attacker.pokemon.status=newpoke.status if attacker.pokemon && newpoke
  #  end
  #  return ret
  #end
end



################################################################################
# POWDER
################################################################################
class PokeBattle_Move_162 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Powder]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Powder]=true
    @battle.pbDisplay(_INTL("{1} is covered in powder!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Decreases the target's Attack and Special Attack by 1 stage each. (Noble Roar)
################################################################################
class PokeBattle_Move_163 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    if opponent.pbTooLow?(PBStats::ATTACK) &&
       opponent.pbTooLow?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s stats won't go lower!",opponent.pbThis))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      return -1
    end
    if !attacker.hasMoldBreaker
      if opponent.hasWorkingAbility(:CLEARBODY) ||
         opponent.hasWorkingAbility(:WHITESMOKE)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,abilityname))
        return -1
      end
    end
    fail=-1
    hadanim=false
    if !attacker.hasMoldBreaker && opponent.hasWorkingAbility(:HYPERCUTTER)
      abilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",opponent.pbThis,abilityname))
    elsif opponent.pbTooLow?(PBStats::ATTACK)
      @battle.pbDisplay(_INTL("{1}'s Attack won't go lower!",opponent.pbThis))
    else
      opponent.pbReduceStat(PBStats::ATTACK,1,true,@id,attacker,self)
      fail=0
    end
    if opponent.pbTooLow?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s Special Attack won't go lower!",opponent.pbThis))
    else
      opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker,self)
      fail=0
    end
    return fail
  end
end



################################################################################
# For 5 rounds, creates a grassy terrain which boosts Grass-type moves and heals
# Pokémon at the end of each round. Affects non-airborne Pokémon only.
# (Grassy Terrain)
################################################################################
class PokeBattle_Move_164 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.field.effects[PBEffects::GrassyTerrain]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.field.effects[PBEffects::ElectricTerrain]=0
    @battle.field.effects[PBEffects::MistyTerrain]=0
    @battle.field.effects[PBEffects::GrassyTerrain]=5
    @battle.pbDisplay(_INTL("Grass grew to cover the battlefield!"))
    return 0
  end
end



################################################################################
# MISTY TERRAIN
################################################################################
class PokeBattle_Move_165 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.field.effects[PBEffects::MistyTerrain]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.field.effects[PBEffects::ElectricTerrain]=0
    @battle.field.effects[PBEffects::GrassyTerrain]=0
    @battle.field.effects[PBEffects::MistyTerrain]=5
    @battle.pbDisplay(_INTL("Mist swirled about the battlefield!"))
    return 0
  end
end


################################################################################
# For 5 rounds, creates an electric terrain which boosts Electric-type moves and
# prevents Pokémon from falling asleep. Affects non-airborne Pokémon only.
# (Electric Terrain)
################################################################################
class PokeBattle_Move_166 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.field.effects[PBEffects::ElectricTerrain]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.field.effects[PBEffects::GrassyTerrain]=0
    @battle.field.effects[PBEffects::MistyTerrain]=0
    @battle.field.effects[PBEffects::ElectricTerrain]=5
    @battle.pbDisplay(_INTL("An electric current runs across the battlefield!"))
    return 0
  end
end



################################################################################
# Increases the Defense of all Grass-type Pokémon on the field by 1 stage each.
# (Flower Shield)
################################################################################
class PokeBattle_Move_167 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    didsomething=false
    for i in 0..@battle.battlers.length-1
      next if !@battle.battlers[i] || @battle.battlers[i].fainted?
      next if @battle.battlers[i].isInvulnerable?
      if @battle.battlers[i] && @battle.battlers[i].pbHasType?(PBTypes::GRASS)
        if @battle.battlers[i].pbTooHigh?(PBStats::DEFENSE)
          @battle.pbDisplay(_INTL("{1}'s Defense won't go higher!",@battle.battlers[i].pbThis))
          didsomething=true
        else
          @battle.battlers[i].pbIncreaseStatBasic(PBStats::DEFENSE,1)
          @battle.pbCommonAnimation("StatUp",@battle.battlers[i],nil) if !@battle.battlers[i].isInvulnerable?
          @battle.pbDisplay(_INTL("{1}'s Defense rose!",@battle.battlers[i].pbThis))
          didsomething=true
        end
      end
    end
    if !didsomething
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end


################################################################################
# Increases ally's Special Defense by 1 stage. (Aromatic Mist)
################################################################################
class PokeBattle_Move_168 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if !@battle.doublebattle || attacker.pbPartner.fainted? ||
       attacker.pbPartner.pbTooHigh?(PBStats::SPDEF) ||
       isConst?(attacker.pbPartner.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
       isConst?(attacker.pbPartner.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) ||
       isConst?(attacker.pbPartner.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE) ||
       isConst?(attacker.pbPartner.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
       isConst?(attacker.pbPartner.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE) ||
       isConst?(attacker.pbPartner.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
       isConst?(attacker.pbPartner.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
       isConst?(attacker.pbPartner.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY)
      @battle.pbDisplay(_INTL("But it failed!"))
      ret=-1
    elsif attacker.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("Crafty Shield protected your team!"))
      return -1
    else
      attacker.pbPartner.pbIncreaseStatBasic(PBStats::SPDEF,1)
      @battle.pbCommonAnimation("StatUp",attacker.pbPartner,nil) if !attacker.pbPartner.isInvulnerable?
      @battle.pbDisplay(_INTL("{1}'s Special Defense rose!",attacker.pbPartner.pbThis))
      ret=0
    end
    return ret
  end
end



################################################################################
# Decreases the target's Attack by 1 stage. Always hits. (Play Nice)
################################################################################
class PokeBattle_Move_169 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end
  
  def pbEffect(attacker,opponent)
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,true,self)
    return opponent.pbReduceStat(PBStats::ATTACK,1,true,@id,attacker,self) ? 0 : -1
  end
end



################################################################################
# Gives target the Grass type in addition to their other types. Replaces the 
# effects of Trick-or-Treat. Fails if the target is already a Grass-type, is 
# behind a Substitute, or has the abilities Multitype, Omnitype, or Ethereal 
# Shroud (Forest's Curse)
################################################################################
class PokeBattle_Move_170 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasWorkingAbility(:MULTITYPE) || 
       opponent.hasWorkingAbility(:ETHEREALSHROUD) ||
       opponent.hasWorkingAbility(:OMNITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if isConst?(opponent.type1,PBTypes,:GRASS) || isConst?(opponent.type2,PBTypes,:GRASS) || opponent.effects[PBEffects::ForestsCurse]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::TrickOrTreat]=false
    opponent.effects[PBEffects::ForestsCurse]=true
    typename=PBTypes.getName(getConst(PBTypes,:GRASS))
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} changed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end



################################################################################
# Gives target the Ghost type in addition to their other types. Replace the 
# effects of Forest's Curse. Fails if the target is already a Ghost-type, is
# behind a Substitute, or has the abilities Multitype, Omnitype, or Ethereal 
# Shroud (Trick-or-Treat)
################################################################################
class PokeBattle_Move_171 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hasWorkingAbility(:MULTITYPE) || 
       opponent.hasWorkingAbility(:ETHEREALSHROUD) ||
       opponent.hasWorkingAbility(:OMNITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if isConst?(opponent.type1,PBTypes,:GHOST) || isConst?(opponent.type2,PBTypes,:GHOST) || opponent.effects[PBEffects::TrickOrTreat]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::TrickOrTreat]=true
    opponent.effects[PBEffects::ForestsCurse]=false
    typename=PBTypes.getName(getConst(PBTypes,:GHOST))
    @battle.pbAnimation(@id,attacker,opponent)
    @battle.pbDisplay(_INTL("{1} changed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end 



################################################################################
# Decreases the Attack, Special Attack and Speed of all poisoned opponents by 1
# stage each. (Venom Drench)
################################################################################
class PokeBattle_Move_172 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.status==PBStatuses::POISON
      @battle.pbAnimation(@id,attacker,opponent)
      if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self) &&
         !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self) &&
         !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
        @battle.pbDisplay(_INTL("{1}'s stats won't go lower!",opponent.pbThis))
        return -1
      end
      if opponent.pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
        return -1
      end
      if opponent.hasWorkingAbility(:CLEARBODY) ||
         opponent.hasWorkingAbility(:WHITESMOKE)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,abilityname))
        return -1
      end
      fail=-1
      hadanim=false
      if opponent.hasWorkingAbility(:HYPERCUTTER)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",opponent.pbThis,abilityname))
      elsif !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker,false,self)
        @battle.pbDisplay(_INTL("{1}'s Attack won't go lower!",opponent.pbThis))
      else
        opponent.pbReduceStat(PBStats::ATTACK,1,true,@id,attacker,self)
        fail=0
      end
      if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
        @battle.pbDisplay(_INTL("{1}'s Special Attack won't go lower!",opponent.pbThis))
      else
        opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker,self)
        fail=0
      end
      if !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker,false,self)
        @battle.pbDisplay(_INTL("{1}'s Speed won't go lower!",opponent.pbThis))
      else
        opponent.pbReduceStat(PBStats::SPEED,1,true,@id,attacker,self)
        fail=0
      end
      return fail
    else
      @battle.pbDisplay(_INTL("{1} was unaffected!",opponent.pbThis))
      return -1
    end
  end
end



################################################################################
# Increases the Attack and Special Attack of all Grass-type Pokémon on the field
# by 1 stage each. Doesn't affect airborne Pokémon. (Rototiller)
################################################################################
class PokeBattle_Move_173 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    hasGrass=false
    for i in 0..@battle.battlers.length-1
      if (@battle.battlers[i].pbHasType?(:GRASS) ||  @battle.battlers[i].effects[PBEffects::ForestsCurse]) && 
         !@battle.battlers[i].isAirborne?(attacker.hasMoldBreaker)
        hasGrass=true 
        break
      end
    end
    if !hasGrass
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in 0..@battle.battlers.length-1
      if (@battle.battlers[i].pbHasType?(:GRASS) ||  @battle.battlers[i].effects[PBEffects::ForestsCurse]) && 
         !@battle.battlers[i].isAirborne?(attacker.hasMoldBreaker)
        @battle.pbAnimation(@id,@battle.battlers[i],nil)
        if @battle.battlers[i].pbTooHigh?(PBStats::ATTACK)
          @battle.pbDisplay(_INTL("{1}'s Attack won't go higher!",@battle.battlers[i].pbThis))
        else
          @battle.battlers[i].pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",@battle.battlers[i],nil) if !@battle.battlers[i].isInvulnerable?
          @battle.pbDisplay(_INTL("{1}'s Attack rose!",@battle.battlers[i].pbThis))
        end
        if @battle.battlers[i].pbTooHigh?(PBStats::SPATK)
          @battle.pbDisplay(_INTL("{1}'s Special Attack won't go higher!",@battle.battlers[i].pbThis))
        else
          @battle.battlers[i].pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",@battle.battlers[i],nil) if !@battle.battlers[i].isInvulnerable?
          @battle.pbDisplay(_INTL("{1}'s Special Attack rose!",@battle.battlers[i].pbThis))
        end
      end
    end
    return 0
  end
end 



################################################################################
# Fails unless user has consumed a berry at some point. (Belch)
################################################################################
class PokeBattle_Move_174 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return !attacker.pokemon || !attacker.pokemon.belch
  end
  
  #def pbEffect(attacker,opponent)
  #  if (!pbIsBerry?(attacker.pokemon.itemRecycle) || attacker.item!=0) || attacker.effects[PBEffects::Belch]==0
  #    @battle.pbDisplay(_INTL("But it failed!",opponent.pbThis))
  #    return -1
  # end
  # 
  #  return super(attacker,opponent)
  #end
end 



class PokeBattle_Move_175 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    
  end
end



################################################################################
# This round, the user's side is unaffected by damaging moves. (Mat Block)
################################################################################
class PokeBattle_Move_176 < PokeBattle_Move
  def pbEffect(attacker,opponent)
      if attacker.pbOwnSide.effects[PBEffects::MatBlock]
        @battle.pbDisplay(_INTL("But it failed!",opponent.pbThis))
        return -1
      end
      attacker.pbOwnSide.effects[PBEffects::MatBlock]=true
      @battle.pbDisplay(_INTL("{1} kicked up a mat to protect its team!",attacker.pbThis))
    end
    
  def pbMoveFailed(attacker,opponent)
    return (attacker.turncount!=1)
  end
end



class PokeBattle_Move_177 < PokeBattle_Move
  def pbEffect(attacker,opponent)
      
    end
end
  


################################################################################
# Entry hazard. Lays sticky web on the opposing side. (Sticky Web)
################################################################################
class PokeBattle_Move_178 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOpposingSide.effects[PBEffects::StickyWeb]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil,true)
      attacker.pbOpposingSide.effects[PBEffects::StickyWeb]=true
      @battle.pbDisplay(_INTL("Webs were spread on the field!"))
      return 0
    end  
  end
end



################################################################################
# Reverses all stat changes of the target. (Topsy-Turvy)
################################################################################
class PokeBattle_Move_179 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    nonzero=false
    for i in [PBStats::ATTACK,PBStats::DEFENSE,
                PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                PBStats::EVASION,PBStats::ACCURACY]
      if opponent.stages[i]!=0
        nonzero=true; break
      end
    end
    if !nonzero
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      opponent.stages[i]*=-1
    end
    @battle.pbDisplay(_INTL("The Pokemon's stat changes were reversed!"))
    return 0
  end
end

################################################################################
# Starts dark weather.
################################################################################
class PokeBattle_Move_182 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    #if @battle.weather==PBWeather::NEWMOON  || @battle.deltastream || @battle.primordialsea || @battle.desolateland
    # @battle.pbDisplay(_INTL("But it failed!"))
    # return -1
    #else
    case @battle.weather
    when PBWeather::HEAVYRAIN
      @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
      return -1
    when PBWeather::HARSHSUN
      @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
      return -1
    when PBWeather::STRONGWINDS
      @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
      return -1
    when PBWeather::NEWMOON
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.weather=PBWeather::NEWMOON
    @battle.weatherduration=5
    @battle.weatherduration=8 if isConst?(attacker.item,PBItems,:DARKROCK)
    @battle.pbDisplay(_INTL("The sky faded to pitch-black!"))
    @battle.scene.pbBackdropMove(0,true,true)
    return 0
    #end
  end
end



################################################################################
# Decreases the target's Special Attack by 2 stages. (Eerie Impulse)
################################################################################
class PokeBattle_Move_183 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,true,self)
    return opponent.pbReduceStat(PBStats::SPATK,2,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
      return opponent.pbReduceStat(PBStats::SPATK,2,true,@id,attacker,self)
    end
  end
end



################################################################################
# Increases the priority of all moves used next turn (Jet Stream)
################################################################################
class PokeBattle_Move_184 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if attacker.pbOwnSide.effects[PBEffects::JetStream]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      @battle.pbDisplay(_INTL("A current of supercharged air filled the field!"))
      attacker.pbOwnSide.effects[PBEffects::JetStream]=2
      return 0
    end
  end
end



class PokeBattle_Move_180 < PokeBattle_Move
  def pbEffect(attacker,opponent)

  end
end



class PokeBattle_Move_185 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    blacklist=[
       :AFTERYOU,
       :ASSIST,
       :BESTOW,
       :CHATTER,
       :COPYCAT,
       :COUNTER,
       :COVET,
       :DESTINYBOND,
       :DETECT,
       :ENDURE,
       :FEINT,
       :FOCUSPUNCH,
       :FOLLOWME,
       :FREEZESHOCK,
       :HELPINGHAND,
       :ICEBURN,
       :MEFIRST,
       :METRONOME,
       :MIMIC,
       :MIRRORCOAT,
       :MIRRORMOVE,
       :NATUREPOWER,
       :PROTECT,
       :QUASH,
       :QUICKGUARD,
       :RAGEPOWDER,
       :RELICSONG,
       :SECRETSWORD,
       :SKETCH,
       :SLEEPTALK,
       :SNARL,
       :SNATCH,
       :SNORE,
       :STRUGGLE,
       :SWITCHEROO,
       :TECHNOBLAST,
       :THIEF,
       :TRANSFORM,
       :TRICK,
       :VCREATE,
       :WIDEGUARD,
       :SILVERFORCE,
       :VENUSFORCE,
       :EARTHFORCE,
       :MARSFORCE,
       :ZEUSFORCE,
       :SATURNFORCE,
       :CLOUDFORCE,
       :PLUTOFORCE,
       :LUNAFORCE,
       :GRAVIFORCE,
       :DARKSONATA,
       :INSURGENCY,
       :BANISHMENT,
       :FAIRYTEMPEST,
       :DYNAMICFURY,
       :AURABLAST,
       :DARKNOVA,
# Shadow moves
       :SHADOWBLAST,
       :SHADOWBLITZ,
       :SHADOWBOLT,
       :SHADOWBREAK,
       :SHADOWCHILL,
       :SHADOWDOWN,
       :SHADOWEND,
       :SHADOWFIRE,
       :SHADOWHALF,
       :SHADOWHOLD,
       :SHADOWMIST,
       :SHADOWPANIC,
       :SHADOWRAVE,
       :SHADOWRUSH,
       :SHADOWSHED,
       :SHADOWSKY,
       :SHADOWSTORM,
       :SHADOWWAVE
    ]
          Kernel.pbMessage("Recollection 0")

    loop do
      moveAry=[]
      for i in 0..3
        for j in 0..3
          if @battle.battlers[i]
          Kernel.pbMessage("Recollection 0.01 "+i.to_s+" "+j.to_s)
            if @battle.battlers[i].pokemon.moves 
          Kernel.pbMessage("Recollection 0.01 "+i.to_s+" "+j.to_s)
              if @battler.battlers[i].pokemon.moves[j]
          Kernel.pbMessage("Recollection 0.1 "+i.to_s+" "+j.to_s)
            moveAry.push(@battle.battlers[i].moves[j].id)
          end; end; end
          
        end
        
      end
      Kernel.pbMessage("Recollection 1")
      move=moveAry=[@battle.pbRandom(moveAry.length)]
      found=false
      for i in blacklist
        if isConst?(move,PBMoves,i)
          found=true
          break
        end
      end
            Kernel.pbMessage("Recollection 2")

      if !found
        attacker.pbUseMoveSimple(move)
        break
      end
    end
    return 0
  end
end


################################################################################
# User releases a second attack during the same turn. (Regurgitation)
################################################################################
class PokeBattle_Move_186 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.hp != 0
      @battle.pbDisplay(_INTL("{1}'s Regurgitation unleashed a second attack on the foe!",attacker.pbThis))
      i = opponent.totalhp/4
      
      typeArray=[PBTypes::WATER,PBTypes::GRASS,PBTypes::FIRE,PBTypes::DARK,
      PBTypes::NORMAL,PBTypes::PSYCHIC]
      typeC=typeArray[attacker.form-1]
      i=(i*pbTypeModifier(typeC,attacker,opponent))/6
      if (pbTypeModifier(typeC,attacker,opponent)==0)
        @battle.pbDisplay(_INTL("But it had no effect!",attacker.pbThis))
      elsif (pbTypeModifier(typeC,attacker,opponent) == 2)
        @battle.pbDisplay(_INTL("It wasn't very effective...",attacker.pbThis))
      elsif (pbTypeModifier(typeC,attacker,opponent) == 8)
        @battle.pbDisplay(_INTL("It was super effective!",attacker.pbThis))
      end
      return pbEffectFixedDamage(i,attacker,opponent)
    end
    return 0
  end
end



################################################################################
# After lowering stats, the user switches out. Ignores trapping moves. (Parting Shot)
################################################################################
class PokeBattle_Move_187 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    #ret=super(attacker,opponent)
  
    #if !self.isSoundBased? ||
    #   attacker.hasMoldBreaker || !opponent.hasWorkingAbility(:SOUNDPROOF)
    #  if @battle.pbOwnedByPlayer?(attacker.index) && ($game_switches[346] || $game_switches[347])
    #          @battle.pbDisplay(_INTL("But it failed!",attacker.pbThis))  
    #    return -1
    #  end
      
    #  opponent.pbReduceStat(PBStats::ATTACK,1,true,@id,attacker)
    #  opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker)
      
      
    #  if attacker.hp>0 && @battle.pbCanChooseNonActive?(attacker.index)
    #    newpoke=0
    #    newpoke=@battle.pbSwitchInBetween(attacker.index,true,false,true)
    #                  # newpoke=pbSwitchInBetween(index,true,false)
    #    if $hasSentData
    #      $network.send("<BAT\tnew=#{newpoke}>")
    #    end
  
    #    @battle.pbMessagesOnReplace(attacker.index,newpoke)
    #    @battle.pbReplace(attacker.index,newpoke,true)
    #    @battle.pbOnActiveOne(attacker)
    #    attacker.pbAbilitiesOnSwitchIn(true)
    #   # attacker.pbResetForm
  
    #    attacker.effects[PBEffects::Substitute]=0
    #    attacker.effects[PBEffects::LeechSeed]=-1
    #    attacker.effects[PBEffects::Confusion]=0
    #    newpoke=newpoke[0] if newpoke.is_a?(Array)
    #    attacker.status=@battle.pbParty(attacker.index)[newpoke].status if attacker && @battle.pbParty(attacker.index)[newpoke]#.pokemon
    #   # attacker.status=@battle.pbParty[attacker.index][newpoke].status if attacker && @battle.pbParty[attacker.index][newpoke]
    #  #  Kernel.pbMessage("0")
    #    if $hasSentData
    #      @battle.waitnewenemy
    #      $hasSentData=nil
    #    end
    #    opponent.pbFaint if opponent.hp <= 0
    #  end      
    #end
    #return ret
    
    ret=-1
    if !self.isSoundBased? ||
       attacker.hasMoldBreaker || !opponent.hasWorkingAbility(:SOUNDPROOF)
      showanim=true
      if opponent.pbReduceStat(PBStats::ATTACK,1,true,@id,attacker,self)
        showanim=false
        ret=0
      end
      if opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker,self)
        showanim=false
        ret=0
      end
    end
    if !attacker.fainted? &&
       @battle.pbCanChooseNonActive?(attacker.index) &&
       !@battle.pbAllFainted?(@battle.pbParty(opponent.index))
      attacker.effects[PBEffects::Uturn]=true
      ret=0
    end
    return ret
  end
end



################################################################################
# User transforms into the target. If a Delta version of the target exists, the
# User transforms into them instead. (Morph)
################################################################################
class PokeBattle_Move_188 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Substitute]>0 ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
       isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY) ||
       opponent.effects[PBEffects::Illusion]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      attacker.effects[PBEffects::Transform]=true
      oldpbthis=attacker.pbThis
      morphVar=false
      arySpecies=[]
      for i in PBSpecies::DELTABULBASAUR..PBSpecies::DELTAHOOPA
        if i!=opponent.species && PBSpecies.getName(i)==PBSpecies.getName(opponent.species)
          arySpecies.push(i)
          attacker.species=i
    
          #Kernel.pbMessage(_INTL("{1}",newMoves[newMoves.length]))
          #moveLength=newMoves.length
          #Kernel.pbMessage(_INTL("{1}",newMoves.length.to_s))
          #Kernel.pbMessage(_INTL("{1}",newMoves[moveLength-1]))
          #Kernel.pbMessage(_INTL("{1}",newMoves[moveLength-2]))
          #Kernel.pbMessage(_INTL("{1}",newMoves[moveLength-3]))
          #Kernel.pbMessage(_INTL("{1}",newMoves[moveLength-4]))
          #attacker.pokemon.resetMoves
            
          morphVar=true
        end
      end
      if !morphVar
        @battle.pbAnimation(@id,attacker,opponent)
      else
        speciesNum=@battle.pbRandom(arySpecies.length)
        pkmnSpecies=arySpecies[speciesNum]
        attacker.species=pkmnSpecies
        
        movelist=[]
        dexdata=pbOpenDexData
          
        pbDexDataOffset(dexdata,pkmnSpecies,8)
        attacker.type1=dexdata.fgetb
          
        pbDexDataOffset(dexdata,pkmnSpecies,9)
        attacker.type2=dexdata.fgetb
          
        abils=[]; abilAry=[]
        pbDexDataOffset(dexdata,pkmnSpecies,29)
        abils.push(dexdata.fgetb)
        abils.push(dexdata.fgetb)
        pbDexDataOffset(dexdata,pkmnSpecies,37)
        abils.push(dexdata.fgetb)
        
        pbDexDataOffset(dexdata,pkmnSpecies,35)
        weight=dexdata.fgetw
        attacker.effects[PBEffects::WeightChange]+=weight
        
        dexdata.close
        for m in 0...abils.length
          if abils[m]>0 && !abilAry.include?(abils[m])
            abilAry.push(abils[m])
          end
        end
        abilNum=@battle.pbRandom(abilAry.length)
        attacker.ability=abilAry[abilNum]
        
        atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
        offset=atkdata.getOffset(pkmnSpecies-1)
        length=atkdata.getLength(pkmnSpecies-1)>>1
        atkdata.pos=offset
        for k in 0..length-1
          level=atkdata.fgetw
          move=atkdata.fgetw
          movelist.push([level,move])
        end
        atkdata.close
        newMovelist=[]
        for j in movelist
          if j[0]<=opponent.level
            newMovelist[newMovelist.length]=j[1]
          end
        end
        newMovelist|=[] # Remove duplicates
        listend=newMovelist.length-4
        listend=0 if listend<0
        k=0
        for l in listend...listend+4
          moveid=(l>=newMovelist.length) ? 0 : newMovelist[l]
          attacker.moves[k]=PokeBattle_Move.pbFromPBMove(
              @battle,PBMove.new(moveid))
          k+=1
        end
        
        @battle.pbAnimation(@id,attacker,opponent,true,attacker.species)
      end
      
      #attacker.species=opponent.species if !morphVar
      attacker.gender=opponent.gender
      attacker.form=opponent.form
      attacker.type1=opponent.type1 if !morphVar
      attacker.type2=opponent.type2 if !morphVar
      attacker.effects[PBEffects::WeightChange]+=opponent.weight if !morphVar
      attacker.ability=opponent.ability(true) if !morphVar
      attacker.attack=opponent.attack
      attacker.defense=opponent.defense
      attacker.speed=opponent.speed
      attacker.spatk=opponent.spatk
      attacker.spdef=opponent.spdef
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
        attacker.stages[i]=opponent.stages[i]
      end
      attacker.effects[PBEffects::FocusEnergy]=opponent.effects[PBEffects::FocusEnergy]
      hasMorph=false
      for i in 0..3
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(
           @battle,PBMove.new(opponent.moves[i].id)) if !morphVar
        attacker.moves[i].pp=5 #if !morphVar
        attacker.moves[i].totalpp=5
        if isConst?(attacker.moves[i].id,PBMoves,:MORPH)
          hasMorph=true
          attacker.effects[PBEffects::ChoiceBand]=attacker.moves[i].id
        end
      end
      if attacker.effects[PBEffects::ChoiceBand]>=0 && !hasMorph
        attacker.effects[PBEffects::ChoiceBand]=-1
      end
      attacker.effects[PBEffects::Disable]=0
      attacker.effects[PBEffects::DisableMove]=0
      speciesname=PBSpecies.getName(opponent.species)
      @battle.pbDisplay(_INTL("{1} transformed into {2}!",oldpbthis,speciesname))
      attacker.pbAbilitiesOnSwitchIn(attacker.ability)
      return 0
    end
  end
end



################################################################################
# Fails unless player has pkmn.
################################################################################
class PokeBattle_Move_190 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    # This function runs in O(evolutionBranches^pokemonLines + numberOfTotalPokemon) time and is disgustingly formatted. I am so, so, sorry
    # I'm  too tired and on way too much adderall to actually think about how to code this better
    for poke in attacker.pbParty
      if recursiveCheck(poke.species,opponent.species,[])
        return super(attacker,opponent)
      end
    end
    return  -1
  end
  #  ret=pbCheckEvolutionEx(pokemon){|pokemon,evonib,level,poke|
  #form=[evonib,level,poke]
  def recursiveCheck(currentPoke,comparePoke,accumulatorChecked)
    accumulatorChecked.push(currentPoke)
    for form in pbGetEvolvedFormData(currentPoke)
      if form[2]==comparePoke || recursiveCheck(form[2],comparePoke,accumulatorChecked)
        return true
      end
    end
    for i in 0..PBSpecies.maxValue-1
      for newForm in pbGetEvolvedFormData(currentPoke)
        if newForm[2]==currentPoke
          if recursiveCheck(newForm[2],comparePoke,accumulatorChecked)
            return true
          end
        end
      end
    end
    return false
  end
end



################################################################################
# Reverts a Mega Evolved Pokemon to its base form. (Retrograde)
################################################################################
class PokeBattle_Move_199 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if Kernel.pbGetMegaSpeciesList.include?(opponent.species) && opponent.form>0
      if ![2,3,5].include?(opponent.form) && opponent.species==PBSpecies::MEWTWO
        @battle.pbDisplay("But it failed!")
        return -1
      elsif ![1,3].include?(opponent.form) && (opponent.species==PBSpecies::GARDEVOIR || 
            opponent.species==PBSpecies::LUCARIO)
        @battle.pbDisplay("But it failed!")
        return -1
      elsif opponent.species==PBSpecies::FLYGON && opponent.form==1
        @battle.pbDisplay("But it failed!")
        return -1
      elsif opponent.species==PBSpecies::TYRANITAR && opponent.form==2
        @battle.pbDisplay("But it failed!")
        return -1
      elsif opponent.species==PBSpecies::MEWTWO && opponent.form==5
        opponent.form=4
        @battle.scene.pbUpdateSprites(opponent.index)
        @battle.pbDisplay(opponent.pbThis+" was reverted to its original form!")
        return 0
      elsif (opponent.species==PBSpecies::GARDEVOIR || opponent.species==PBSpecies::LUCARIO) &&
            opponent.form==3
        opponent.form=2
        @battle.scene.pbUpdateSprites(opponent.index)
        @battle.pbDisplay(opponent.pbThis+" was reverted to its original form!")
        return 0
      else
        opponent.form=0
        @battle.scene.pbUpdateSprites(opponent.index)
        @battle.pbDisplay(opponent.pbThis+" was reverted to its original form!")
        return 0
      end
    else
      @battle.pbDisplay("But it failed!")
      return -1
    end
  end
end



################################################################################
# Restores 1/2 of the user's HP and raises their Defense 1 stage. (Nanorepair)
################################################################################
class PokeBattle_Move_200 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    if attacker.pbTooHigh?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s Defense won't go higher!",attacker.pbThis))
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbIncreaseStatBasic(PBStats::DEFENSE,1)
      @battle.pbCommonAnimation("StatUp",attacker,nil)
      @battle.pbDisplay(_INTL("{1}'s Defense rose!",attacker.pbThis))
    end
    hpgain=(attacker.totalhp/2).floor
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    else
      @battle.pbAnimation(@id,attacker,nil)
      attacker.pbRecoverHP(hpgain)
      @battle.pbDisplay(_INTL("{1} regained health!",attacker.pbThis))
      return 0
    end
  end
end



################################################################################
# Ignores Protect effects and cannot miss
################################################################################
class PokeBattle_Move_201 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end
  
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    opponent.effects[PBEffects::ProtectNegation]=true if ret
    opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false if ret
    return ret
  end
end

################################################################################
# Ignores Protect effects, cannot miss, and lowers the user's Defense
################################################################################
class PokeBattle_Move_202 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end
  
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,self)
        attacker.pbReduceStatBasic(PBStats::DEFENSE,1)
        @battle.pbCommonAnimation("StatDown",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Defense fell!",attacker.pbThis))
      end
    end
    return ret
  end
  
  def pbAdditionalEffect(attacker,opponent)
    ret=super(attacker,opponent)
    opponent.effects[PBEffects::ProtectNegation]=true if ret
    opponent.pbOwnSide.effects[PBEffects::CraftyShield]=false if ret
    return ret
  end
end

################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
################################################################################
class PokeBattle_Move_203 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.field.effects[PBEffects::FairyLock]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.pbAnimation(@id,attacker,nil)
    @battle.field.effects[PBEffects::FairyLock]=2
    @battle.pbDisplay(_INTL("No one will be able to run away during the next turn!"))
    return 0
  end
end

################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Spirit Away)
# Is semi-invulnerable during use, vulnerable only to Spirit Away.
# Target is also semi-invulnerable during use, and can't take any action.
# Doesn't damage airborne Pokémon (but still makes them unable to move during).
################################################################################
class PokeBattle_Move_204 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    ret=false
    ret=true if opponent.effects[PBEffects::Substitute]>0
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE)
    ret=true if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY)
    ret=true if opponent.effects[PBEffects::SpiritAway] && opponent.effects[PBEffects::SpiritAwayPartnerPos]!=attacker.index
    ret=true if !opponent.pbIsOpposing?(attacker.index)
    #ret=true if opponent.weight>=2000
    return ret
  end  

  def pbTwoTurnAttack(attacker)
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end
  
  def pbEffect(attacker,opponent)
    if pbMoveFailed(attacker,opponent)
      attacker.effects[PBEffects::TwoTurnAttack]=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    if attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbAnimation(@id,attacker,nil) # Placeholder for charging Common anim
      @battle.pbDisplay(_INTL("{2} was taken away by {1}!",attacker.pbThis,opponent.pbThis))
      opponent.effects[PBEffects::SpiritAway]=true
      opponent.effects[PBEffects::SpiritAwayPartnerPos]=attacker.index
      attacker.effects[PBEffects::SpiritAwayPartnerPos]=opponent.index
      @battle.scene.pbHideSprites(attacker.index)
      @battle.scene.pbHideSprites(opponent.index)
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    @battle.scene.pbShowSprites(attacker.index)
    @battle.scene.pbShowSprites(opponent.index)
    ret=super
    @battle.pbDisplay(_INTL("{1} is no longer Spirited Away!",opponent.pbThis))
    opponent.effects[PBEffects::SpiritAway]=false
    opponent.effects[PBEffects::SpiritAwayPartnerPos]=-1
    attacker.effects[PBEffects::SpiritAwayPartnerPos]=-1
    return ret
  end
end

################################################################################
# User gains 3/4 the HP it inflicts as damage.
################################################################################
class PokeBattle_Move_205 < PokeBattle_Move
  def isHealingMove?
    return true
  end
  
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if opponent.damagestate.calcdamage>0
      hpgain=(opponent.damagestate.hplost*3/4).floor
      if opponent.hasWorkingAbility(:LIQUIDOOZE)
        attacker.pbReduceHP(hpgain)
        @battle.pbDisplay(_INTL("It sucked up the liquid ooze!"))
      elsif attacker.effects[PBEffects::HealBlock]==0
        hpgain*=1.3 if isConst?(attacker.item,PBItems,:BIGROOT)
        attacker.pbRecoverHP(hpgain)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# Does absolutely nothing. Shows a special message. (Celebrate)
################################################################################
class PokeBattle_Move_206 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    @battle.pbDisplay(_INTL("Congratulations, {1}!",@battle.pbGetOwner(attacker.index).name))
    return 0
  end
end



################################################################################
# Doubles the prize money the player gets after winning the battle. (Happy Hour)
################################################################################
class PokeBattle_Move_207 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if @battle.pbIsOpposing?(attacker.index) || @battle.doublemoney
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.doublemoney=true
    @battle.pbDisplay(_INTL("Everyone is caught up in the happy atmosphere!"))
    return 0
  end
end



################################################################################
# Does absolutely nothing. (Hold Hands)
################################################################################
class PokeBattle_Move_208 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if !@battle.doublebattle ||
       !attacker.pbPartner || attacker.pbPartner.fainted?
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end



################################################################################
# Target's moves become Electric-type for the rest of the round. (Electrify)
################################################################################
class PokeBattle_Move_209 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    if opponent.effects[PBEffects::Electrify]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.choices[opponent.index][0]!=1 || # Didn't choose a move
       !@battle.choices[opponent.index][2] ||
       @battle.choices[opponent.index][2].id<=0 ||
       opponent.hasMovedThisRound?
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    opponent.effects[PBEffects::Electrify]=true
    @battle.pbDisplay(_INTL("{1} was electrified!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Increases the user's and its ally's Defense and Special Defense by 1 stage
# each, if they have Plus or Minus. (Magnetic Flux)
################################################################################
class PokeBattle_Move_210 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    didsomething=false
    for i in [attacker,attacker.pbPartner]
      next if !i || i.fainted?
      next if !i.hasWorkingAbility(:PLUS) && !i.hasWorkingAbility(:MINUS)
      next if i.pbTooHigh?(PBStats::DEFENSE) && i.pbTooHigh?(PBStats::SPDEF)
      didsomething=true
      if !i.pbTooHigh?(PBStats::DEFENSE)
        i.pbIncreaseStatBasic(PBStats::DEFENSE,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil) if !i.isInvulnerable?
        @battle.pbDisplay(_INTL("{1}'s Defense rose!",i.pbThis))
      end
      if !i.pbTooHigh?(PBStats::SPDEF)
        i.pbIncreaseStatBasic(PBStats::SPDEF,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil) if !i.isInvulnerable?
        @battle.pbDisplay(_INTL("{1}'s Special Defense rose!",i.pbThis))
      end
    end
    if !didsomething
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return 0
  end
end



################################################################################
# All Normal-type moves become Electric-type for the rest of the round.
# (Ion Deluge)
################################################################################
class PokeBattle_Move_211 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    unmoved=false
    for poke in @battle.battlers
      next if poke.index==attacker.index
      if @battle.choices[poke.index][0]==1 && # Chose a move
         !poke.hasMovedThisRound?
        unmoved=true; break
      end
    end
    if !unmoved || @battle.field.effects[PBEffects::IonDeluge]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    @battle.field.effects[PBEffects::IonDeluge]=true
    @battle.pbDisplay(_INTL("The Ion Deluge started!"))
    return 0
  end
end



################################################################################
# All Pokemon that move before the user will have their abilities removed. (Core 
# Enforcer)
################################################################################
class PokeBattle_Move_212 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    unmoved=false
    return -1 if opponent.hp<=0
    return -1 if opponent.hasWorkingAbility(:MULTITYPE) || 
            opponent.hasWorkingAbility(:STANCECHANGE)  ||
            opponent.hasWorkingAbility(:LERNEAN)  ||
            opponent.hasWorkingAbility(:POWERCONSTRUCT)
    return -1 if opponent.effects[PBEffects::Substitute]>0 && 
            !ignoresSubstitute?(attacker)
    if @battle.choices[opponent.index][0]==1 && # Chose a move
       !opponent.hasMovedThisRound?
      unmoved=true#; break
    end
    if !unmoved && !opponent.effects[PBEffects::GastroAcid]
      oldabil=opponent.ability
      opponent.effects[PBEffects::GastroAcid]=true
      opponent.effects[PBEffects::Truant]=false
      @battle.pbAnimation(@id,attacker,opponent)
      @battle.pbDisplay(_INTL("{1}'s ability was suppressed!",opponent.pbThis)) 
      if opponent.effects[PBEffects::Illusion] && isConst?(oldabil,PBAbilities,:ILLUSION)
        opponent.effects[PBEffects::Illusion]=nil
        @battle.scene.pbChangePokemon(opponent,opponent.pokemon)
        @battle.pbDisplay(_INTL("{1}'s {2} wore off!",opponent.pbThis,PBAbilities.getName(oldabil)))
      end
    end
    return ret
  end
end



################################################################################
# If this move KO's the target, increases the user's Attack by 2 stages.
# (Fell Stinger)
################################################################################
class PokeBattle_Move_213 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent) #if @basedamage>0
    if opponent.damagestate.calcdamage>0 && opponent.fainted?
      if !attacker.pbTooHigh?(PBStats::ATTACK)
        @battle.pbAnimation(@id,attacker,nil)
        attacker.pbIncreaseStatBasic(PBStats::ATTACK,2)
        @battle.pbCommonAnimation("StatUp",attacker,nil)
        @battle.pbDisplay(_INTL("{1}'s Attack sharply rose!",attacker.pbThis))
        return 0
      else
        @battle.pbDisplay(_INTL("{1}'s Attack won't go higher!",attacker.pbThis))
        return -1
      end
    end
    return ret
  end
end


################################################################################
# Burst attack. Hits both opponents, gaining Synergy Power for each foe that is
# hit. (Fairy Tempest)
################################################################################
class PokeBattle_Move_214 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if !attacker.pokemon.burstAttack
      attacker.pokemon.burstAttack=true
    end
    return ret
  end
  
  def pbMoveFailed(attacker,opponent)
    return !attacker.pokemon || !attacker.effects[PBEffects::BurstMode]
  end
end


################################################################################
# Burst attack. Hits the opponent up to 5 times, depending on how much Synergy
# Power it currently possesses, losing Synergy Power for each hit that makes 
# contact. (Dynamic Fury)
################################################################################
class PokeBattle_Move_215 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if !attacker.pokemon.burstAttack
      attacker.pokemon.burstAttack=true
    end
    return ret
  end
  
  def pbNumHits(attacker)
    hits=attacker.effects[PBEffects::SynergyBurst]
    hits=1 if hits<1
    return hits
  end

  def pbIsMultiHit
    return true
  end
  
  def pbMoveFailed(attacker,opponent)
    return !attacker.pokemon || !attacker.effects[PBEffects::BurstMode]
  end
end


################################################################################
# Burst attack. Adds an extra hit for every turn that passes while in Burst Mode.
# The final hit deals twice as much damage. (Aura Blast)
################################################################################
class PokeBattle_Move_216 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if !attacker.pokemon.burstAttack
      attacker.pokemon.burstAttack=true
    end
    return ret
  end
  
  def pbNumHits(attacker)
    hits=attacker.effects[PBEffects::AuraBlastCharges]
    hits=1 if hits<1
    return hits
  end

  def pbIsMultiHit
    return true
  end
  
  def pbMoveFailed(attacker,opponent)
    return !attacker.pokemon || !attacker.effects[PBEffects::BurstMode]
  end
end


################################################################################
# Burst attack. Hits the foe twice for massive damage. Damage calculation is done
# using whichever offensive stat is higher at the time (Dark Nova)
################################################################################
class PokeBattle_Move_217 < PokeBattle_Move
  def pbEffect(attacker,opponent)
    ret=super(attacker,opponent)
    if !attacker.pokemon.burstAttack
      attacker.pokemon.burstAttack=true
    end
    return ret
  end
  
  def pbNumHits(attacker)
    return 2
  end

  def pbIsMultiHit
    return true
  end
  
  def pbMoveFailed(attacker,opponent)
    return !attacker.pokemon || !attacker.effects[PBEffects::BurstMode]
  end
end


################################################################################
# Decreases the target's Special Attack by 1 stage. Never misses. (Confide)
################################################################################
class PokeBattle_Move_218 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end
  
  def pbEffect(attacker,opponent)
    return super(attacker,opponent) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,true,self)
    return opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker,self) ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return if opponent.damagestate.substitute
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker,false,self)
      return opponent.pbReduceStat(PBStats::SPATK,1,true,@id,attacker,self)
    end
  end
end