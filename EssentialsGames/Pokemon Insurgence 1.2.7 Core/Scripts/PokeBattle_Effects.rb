class PokeBattle_Battler
#===============================================================================
# Sleep
#===============================================================================
  def pbCanSleep?(attacker,showMessages,move=nil,selfsleep=false,bypass=false)
    return false if hp<=0
    return false if self.damagestate.substitute
    if status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1} is already asleep!",pbThis)) if showMessages
      return false
    end
    if !selfsleep && (status!=0 || @effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))&&
       !bypass)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      if !self.isInvulnerable?
        if @battle.field.effects[PBEffects::ElectricTerrain]>0
          @battle.pbDisplay(_INTL("The Electric Terrain prevented {1} from falling asleep!",pbThis(true))) if showMessages
          return false
        elsif @battle.field.effects[PBEffects::MistyTerrain]>0
          @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from falling asleep!",pbThis(true))) if showMessages
          return false
        end
      end
    end
    if (attacker && attacker.hasMoldBreaker) || 
       !hasWorkingAbility(:SOUNDPROOF)
      for i in 0..3
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
          return false
        end
      end 
    end
    #if @battle.mistyterrain > 0
    #   if !isConst?(self.type,PBTypes,:FLYING) && !isConst?(self.ability,PBAbilities,:LEVITATE) && !isConst?(self.item,PBItems,:AIRBALLOON) && self.effects[PBEffects::MagnetRise]==0 && self.effects[PBEffects::Telekinesis]==0
    #      return false
    #    end
    #  end
    if (!attacker || attacker.index==self.index || !attacker.hasMoldBreaker) && 
       pbPartner.hasWorkingAbility(:SWEETVEIL) ||
       (pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS))
          abilityname=PBAbilities.getName(pbPartner.ability)
          @battle.pbDisplay(_INTL("{1} stayed awake using its partner's {2}!",pbThis,abilityname)) if showMessages
          return false
    end
    
    if (!attacker || attacker.index==self.index || !attacker.hasMoldBreaker) && 
       (self.hasWorkingAbility(:VITALSPIRIT) || 
       self.hasWorkingAbility(:INSOMNIA) ||
       self.hasWorkingAbility(:SWEETVEIL) || 
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (self.hasWorkingAbility(:LEAFGUARD) && 
       (@battle.pbWeather==PBWeather::SUNNYDAY ||
        @battle.pbWeather==PBWeather::HARSHSUN)))
      abilityname=PBAbilities.getName(self.ability)
      @battle.pbDisplay(_INTL("{1} stayed awake using its {2}!",pbThis,abilityname)) if showMessages
      return false
    end
    if !selfsleep && pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s party is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanSleepYawn?
    return false if status!=0
    if !hasWorkingAbility(:SOUNDPROOF)
      for i in 0..3
        return false if @battle.battlers[i].effects[PBEffects::Uproar]>0
      end 
    end
    if !self.isAirborne? && !self.isInvulnerable?
      return false if @battle.field.effects[PBEffects::ElectricTerrain]>0
      return false if @battle.field.effects[PBEffects::MistyTerrain]>0
    end
    if hasWorkingAbility(:VITALSPIRIT) || 
       hasWorkingAbility(:INSOMNIA) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && 
       (@battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN))
      return false
    end
    return true
  end

  def pbSleep
    self.status=PBStatuses::SLEEP
    self.statusCount=2+@battle.pbRandom(3)
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil) if !self.isInvulnerable?
  end

  def pbSleepSelf(duration=-1)
    self.status=PBStatuses::SLEEP
    if duration>0
      self.statusCount=duration  
    else
      self.statusCount=2+@battle.pbRandom(6)
    end
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
  end

#===============================================================================
# Poison
#===============================================================================
  def pbCanPoison?(attacker,showMessages,move=nil,bypass=false)
    return false if hp<=0
    return false if self.damagestate.substitute
    if status==PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} is already poisoned.",pbThis)) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !self.isInvulnerable? &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being poisoned!",pbThis(true))) if showMessages
      return false
    end
    if self.status!=0 || (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)) &&
       !bypass)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (pbHasType?(:POISON) || pbHasType?(:STEEL))
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      @effects[PBEffects::TypeIdentified]=true
      return false
    end   
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:IMMUNITY) || hasWorkingAbility(:OMNITYPE) || 
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && 
         (@battle.pbWeather==PBWeather::SUNNYDAY ||
         @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents poisoning!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents poisoning!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && 
      (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s party is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanPoisonSynchronize?(opponent)
    return false if hp<=0
    if (pbHasType?(:POISON) || pbHasType?(:STEEL))
      @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
         opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
      return false
    end   
    return false if self.status!=0
    if hasWorkingAbility(:IMMUNITY) || hasWorkingAbility(:OMNITYPE) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && 
       (@battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbCanPoisonSpikes?
    return false if @hp<=0
    return false if self.status!=0
    return false if pbHasType?(:POISON) || pbHasType?(:STEEL)
    return false if hasWorkingAbility(:IMMUNITY) ||
                    (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
                    (pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS))
    return false if hasWorkingAbility(:OMNITYPE)
    return false if hasWorkingAbility(:LEAFGUARD) && 
                    (@battle.pbWeather==PBWeather::SUNNYDAY ||
                    @battle.pbWeather==PBWeather::HARSHSUN)
    #end
    return false if pbOwnSide.effects[PBEffects::Safeguard]>0
    return true
  end

  def pbPoison(attacker,toxic=false)
    if attacker.hasWorkingAbility(:VENOMOUS) #&& !attacker.effects[PBEffects::GastroAcid]
   #   Kernel.pbMessage("lawdy?")#
      toxic=true
    end
    
    self.status=PBStatuses::POISON
    if toxic
      self.statusCount=1
      self.effects[PBEffects::Toxic]=0
    else
      self.statusCount=0
    end
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::POISON
    end
    @battle.pbCommonAnimation("Poison",attacker,self) if !self.isInvulnerable?
  end

#===============================================================================
# Burn
#===============================================================================
  def pbCanBurn?(attacker,showMessages,move=nil,bypass=false)
    return false if hp<=0
    return false if self.damagestate.substitute
    #return false if @effects[PBEffects::Substitute]!=0
    if self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} already has a burn.",pbThis)) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !self.isInvulnerable? &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being burned!",pbThis(true))) if showMessages
      return false
    end
    if self.status!=0 || (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)) && 
       !bypass)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (pbHasType?(:FIRE) || (self.ability==PBAbilities::OMNITYPE && !self.effects[PBEffects::GastroAcid] &&
       (!attacker || !attacker.hasMoldBreaker)))
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      @effects[PBEffects::TypeIdentified]=true
       return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:WATERVEIL) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && 
         (@battle.pbWeather==PBWeather::SUNNYDAY ||
         @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents burns!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents burns!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s party is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBurnFromFireMove?(attacker,move,showMessages)
    return false if hp<=0
    if self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} already has a burn.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !self.isInvulnerable? &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being burned!",pbThis(true))) if showMessages
      return false
    end
    if (pbHasType?(:FIRE) || (self.ability==PBAbilities::OMNITYPE && !self.effects[PBEffects::GastroAcid] && 
       (!attacker || !attacker.hasMoldBreaker)))
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      @effects[PBEffects::TypeIdentified]=true
      return false
    end
    if ((!attacker || !attacker.hasMoldBreaker) && hasWorkingAbility(:FLASHFIRE)) && 
      isConst?(move.type,PBTypes,:FIRE)
      if !@effects[PBEffects::FlashFire]
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Fire power!",pbThis,PBAbilities.getName(self.ability)))
        @effects[PBEffects::FlashFire]=true
        @effects[PBEffects::TypeIdentified]=true
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",pbThis,PBAbilities.getName(self.ability),move.name))
        @effects[PBEffects::TypeIdentified]=true
      end
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:WATERVEIL) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && 
         (@battle.pbWeather==PBWeather::SUNNYDAY ||
         @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents burns!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents burns!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s party is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBurnSynchronize?(opponent)
    return false if hp<=0
    return false if self.status!=0
    if (pbHasType?(:FIRE) || self.ability==PBAbilities::OMNITYPE) && !self.effects[PBEffects::GastroAcid]
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:WATERVEIL) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && 
       (@battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbBurn(attacker)
    self.status=PBStatuses::BURN
    self.statusCount=0
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::BURN
    end
    @battle.pbCommonAnimation("Burn",attacker,self) if !self.isInvulnerable?
  end

#===============================================================================
# Paralyze
#===============================================================================
  def pbCanParalyze?(attacker,showMessages,move=nil,bypass=false)
    return false if self.damagestate.substitute
    #return false if @effects[PBEffects::Substitute]!=0
    return false if hp<=0
    
    if status==PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} is already paralyzed!",pbThis)) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !self.isInvulnerable? &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being paralyzed!",pbThis(true))) if showMessages
      return false
    end
    if self.status!=0 || (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))&&
       !bypass)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (pbHasType?(:ELECTRIC) || (self.ability==PBAbilities::OMNITYPE) && !self.effects[PBEffects::GastroAcid] && 
       (!attacker || !attacker.hasMoldBreaker))
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      @effects[PBEffects::TypeIdentified]=true
      return false
    end

    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:LIMBER) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && 
         (@battle.pbWeather==PBWeather::SUNNYDAY ||
         @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents paralysis!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents paralysis!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s party is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanParalyzeSynchronize?(opponent)
    return false if self.status!=0
    return false if @battle.field.effects[PBEffects::MistyTerrain]>0 && !self.isAirborne? && !self.isInvulnerable?
    if hasWorkingAbility(:LIMBER) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && 
       (@battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if (pbHasType?(:ELECTRIC) || self.ability==PBAbilities::OMNITYPE) && !self.effects[PBEffects::GastroAcid]
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true)))
      @effects[PBEffects::TypeIdentified]=true
      return false
    end
    return true
  end

  def pbParalyze(attacker)
    self.status=PBStatuses::PARALYSIS
    self.statusCount=0
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::PARALYSIS
    end
    @battle.pbCommonAnimation("Paralysis",attacker,self) if !self.isInvulnerable?
  end

#===============================================================================
# Freeze
#===============================================================================
  def pbCanFreeze?(attacker,showMessages,move=nil,bypass=false)
    return false if hp<=0
    return false if self.damagestate.substitute
    
    if (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))&&
       !bypass)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if self.status!=0 || (@battle.pbWeather==PBWeather::SUNNYDAY || 
       @battle.pbWeather==PBWeather::HARSHSUN)
      return false
    end
    if (pbHasType?(:ICE) || hasWorkingAbility(:OMNITYPE))
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 && !self.isInvulnerable? &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being frozen!",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) || 
         hasWorkingAbility(:MAGMAARMOR)
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents freezing!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      return false
    end
    return true
  end

  def pbFreeze
    self.status=PBStatuses::FROZEN
    self.statusCount=0
    pbCancelMoves
    @battle.pbCommonAnimation("Frozen",self,nil) if !self.isInvulnerable?
  end

#===============================================================================
# Confuse
#===============================================================================
  def pbCanConfuse?(attacker,showMessages,move=nil)
    return false if hp<=0
    return false if self.damagestate.substitute 
    if effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if (effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (!attacker || !attacker.hasMoldBreaker) && 
       hasWorkingAbility(:OWNTEMPO)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false   
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s party is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbConfuseSelf
    if @effects[PBEffects::Confusion]==0 && 
       !hasWorkingAbility(:OWNTEMPO)
      @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",self,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
    end
  end
  
#===============================================================================
# Flinching
#===============================================================================
  def pbFlinch(attacker=nil)
    return false if (!attacker || !attacker.hasMoldBreaker) && 
                    hasWorkingAbility(:INNERFOCUS)
    if effects[PBEffects::BurstMode] 
      if (attacker.stages[PBStats::ATTACK]>0 ||
         attacker.stages[PBStats::SPATK]>0)
      elsif attacker.effects[PBEffects::BurstMode]
      elsif damagestate.critical
      else
        return false
      end
    end
    @effects[PBEffects::Flinch]=true
    return true
  end

#===============================================================================
# Increase stat stages
#===============================================================================
  def pbTooHigh?(stat)
    return @stages[stat]>=6
  end

  def pbCanIncreaseStatStage?(stat,showMessages=false,move=nil)
    return false if hp<=0
    if pbTooHigh?(stat)
      if showMessages
        @battle.pbDisplay(_INTL("{1}'s Attack won't go higher!",pbThis)) if stat==PBStats::ATTACK
        @battle.pbDisplay(_INTL("{1}'s Defense won't go higher!",pbThis)) if stat==PBStats::DEFENSE
        @battle.pbDisplay(_INTL("{1}'s Speed won't go higher!",pbThis)) if stat==PBStats::SPEED
        @battle.pbDisplay(_INTL("{1}'s Special Attack won't go higher!",pbThis)) if stat==PBStats::SPATK
        @battle.pbDisplay(_INTL("{1}'s Special Defense won't go higher!",pbThis)) if stat==PBStats::SPDEF
        @battle.pbDisplay(_INTL("{1}'s evasiveness won't go higher!",pbThis)) if stat==PBStats::EVASION
        @battle.pbDisplay(_INTL("{1}'s accuracy won't go higher!",pbThis)) if stat==PBStats::ACCURACY
      end
      return false
    end
    return true
  end

  def pbIncreaseStatBasic(stat,increment,contrary=false)
    if hasWorkingAbility(:CONTRARY) && !contrary
      @battle.pbDisplay(""+pbThis+"'s Contrary made its stats go down instead!")
        pbReduceStatBasic(stat,increment,true)
      return
    end
    increment*=2 if hasWorkingAbility(:SIMPLE)
    @stages[stat]+=increment
    @stages[stat]=6 if @stages[stat]>6
  end

  def pbIncreaseStat(stat,increment,showMessages,moveid=nil,attacker=nil,contrary=false)
    arrStatTexts=[]
    if stat==PBStats::ATTACK
      arrStatTexts=[_INTL("{1}'s Attack rose!",pbThis),
         _INTL("{1}'s Attack rose sharply!",pbThis),
         _INTL("{1}'s Attack rose drastically!",pbThis)]
    elsif stat==PBStats::DEFENSE
      arrStatTexts=[_INTL("{1}'s Defense rose!",pbThis),
         _INTL("{1}'s Defense rose sharply!",pbThis),
         _INTL("{1}'s Defense rose drastically!",pbThis)]
    elsif stat==PBStats::SPEED
      arrStatTexts=[_INTL("{1}'s Speed rose!",pbThis),
         _INTL("{1}'s Speed rose sharply!",pbThis),
         _INTL("{1}'s Speed rose drastically!",pbThis)]
    elsif stat==PBStats::SPATK
      arrStatTexts=[_INTL("{1}'s Special Attack rose!",pbThis),
         _INTL("{1}'s Special Attack rose sharply!",pbThis),
         _INTL("{1}'s Special Attack rose drastically!",pbThis)]
    elsif stat==PBStats::SPDEF
      arrStatTexts=[_INTL("{1}'s Special Defense rose!",pbThis),
         _INTL("{1}'s Special Defense rose sharply!",pbThis),
         _INTL("{1}'s Special Defense rose drastically!",pbThis)]
    elsif stat==PBStats::EVASION
      arrStatTexts=[_INTL("{1}'s evasiveness rose!",pbThis),
         _INTL("{1}'s evasiveness rose sharply!",pbThis),
         _INTL("{1}'s evasiveness rose drastically!",pbThis)]
    elsif stat==PBStats::ACCURACY
      arrStatTexts=[_INTL("{1}'s accuracy rose!",pbThis),
         _INTL("{1}'s accuracy rose sharply!",pbThis),
         _INTL("{1}'s accuracy rose drastically!",pbThis)]
    else
      return false
    end
    if pbCanIncreaseStatStage?(stat,showMessages)
      if true
        pbIncreaseStatBasic(stat,increment)
        if moveid
          @battle.pbAnimation(moveid,attacker,self)
        end
        @battle.pbCommonAnimation("StatUp",attacker,self) if !self.isInvulnerable?
        if increment==3
          @battle.pbDisplay(arrStatTexts[2]) if showMessages
        elsif increment==2
          @battle.pbDisplay(arrStatTexts[1]) if showMessages
        else
          @battle.pbDisplay(arrStatTexts[0]) if showMessages
        end
        return true
      end
    end
    return false
  end

#===============================================================================
# Decrease stat stages
#===============================================================================
  def pbTooLow?(stat)
    return @stages[stat]<=-6
  end

  def pbCanReduceStatStage?(stat,attacker=nil,showMessages=false,move=nil)
    return false if hp<=0
    return false if self.damagestate.substitute
    if (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))) # Note: Not used if move is Tickle
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showMessages
      return false
    end
    if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE)
      abilityname=PBAbilities.getName(self.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
      return false
    end
    if pbHasType?(:GRASS)
      if hasWorkingAbility(:FLOWERVEIL)
        abilityname=PBAbilities.getName(self.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
        return false
      elsif pbPartner.hasWorkingAbility(:FLOWERVEIL)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",pbPartner.pbThis,abilityname,pbThis(true))) if showMessages
        return false
      end
    end
    if stat==PBStats::ATTACK && hasWorkingAbility(:HYPERCUTTER)
      abilityname=PBAbilities.getName(self.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",pbThis,abilityname)) if showMessages
      return false
    end
    if stat==PBStats::DEFENSE && hasWorkingAbility(:BIGPECKS)
      abilityname=PBAbilities.getName(self.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents Defense loss!",pbThis,abilityname)) if showMessages
      return false
    end
    if stat==PBStats::ACCURACY && hasWorkingAbility(:KEENEYE)
      abilityname=PBAbilities.getName(self.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents Accuracy loss!",pbThis,abilityname)) if showMessages
      return false
    end
    if pbTooLow?(stat)
      if showMessages
        @battle.pbDisplay(_INTL("{1}'s Attack won't go lower!",pbThis)) if stat==PBStats::ATTACK
        @battle.pbDisplay(_INTL("{1}'s Defense won't go lower!",pbThis)) if stat==PBStats::DEFENSE
        @battle.pbDisplay(_INTL("{1}'s Speed won't go lower!",pbThis)) if stat==PBStats::SPEED
        @battle.pbDisplay(_INTL("{1}'s Special Attack won't go lower!",pbThis)) if stat==PBStats::SPATK
        @battle.pbDisplay(_INTL("{1}'s Special Defense won't go lower!",pbThis)) if stat==PBStats::SPDEF
        @battle.pbDisplay(_INTL("{1}'s evasiveness won't go lower!",pbThis)) if stat==PBStats::EVASION
        @battle.pbDisplay(_INTL("{1}'s accuracy won't go lower!",pbThis)) if stat==PBStats::ACCURACY
      end
      return false
    end
    return true
  end

  def pbReduceStatBasic(stat,increment,contrary=false)
    if hasWorkingAbility(:CONTRARY) && !contrary
      @battle.pbDisplay(""+pbThis+"'s Contrary made its stats go up instead!")
        pbIncreaseStatBasic(stat,increment,true)
      return false
    end

    increment*=2 if hasWorkingAbility(:SIMPLE)
    @stages[stat]-=increment
    @stages[stat]=-6 if @stages[stat]<-6
  end

# Note: Not used if attack is Tickle
  def pbReduceStat(stat,increment,showMessages,moveid=nil,attacker=nil,move=nil,contrary=false)
    
    arrStatTexts=[]
    if stat==PBStats::ATTACK
      arrStatTexts=[_INTL("{1}'s Attack fell!",pbThis),
         _INTL("{1}'s Attack harshly fell!",pbThis)]
    elsif stat==PBStats::DEFENSE
      arrStatTexts=[_INTL("{1}'s Defense fell!",pbThis),
         _INTL("{1}'s Defense harshly fell!",pbThis)]
    elsif stat==PBStats::SPEED
      arrStatTexts=[_INTL("{1}'s Speed fell!",pbThis),
         _INTL("{1}'s Speed harshly fell!",pbThis)]
    elsif stat==PBStats::SPATK
      arrStatTexts=[_INTL("{1}'s Special Attack fell!",pbThis),
         _INTL("{1}'s Special Attack harshly fell!",pbThis)]
    elsif stat==PBStats::SPDEF
      arrStatTexts=[_INTL("{1}'s Special Defense fell!",pbThis),
         _INTL("{1}'s Special Defense harshly fell!",pbThis)]
    elsif stat==PBStats::EVASION
      arrStatTexts=[_INTL("{1}'s evasiveness fell!",pbThis),
         _INTL("{1}'s evasiveness harshly fell!",pbThis)]
    elsif stat==PBStats::ACCURACY
      arrStatTexts=[_INTL("{1}'s accuracy fell!",pbThis),
         _INTL("{1}'s accuracy harshly fell!",pbThis)]
    else
      return false
    end
    if pbCanReduceStatStage?(stat,attacker,showMessages,move)
      if true
        if hasWorkingAbility(:DEFIANT)
          defiant(increment,attacker) 
        end
        if hasWorkingAbility(:COMPETITIVE)
          competitive(increment,attacker)
        end
        pbReduceStatBasic(stat,increment)
        #@battle.pbAnimation(moveid,attacker,self) if moveid
        @battle.pbCommonAnimation("StatDown",attacker,self) if !self.isInvulnerable?
        if increment==2
          @battle.pbDisplay(arrStatTexts[1]) if showMessages
        else
          @battle.pbDisplay(arrStatTexts[0]) if showMessages
        end
        return true
      end
    end
    return false
  end
  
  def defiant(increment,attacker)
    if !pbTooHigh?(PBStats::ATTACK)
      @battle.pbCommonAnimation("StatUp",attacker,self) if !self.isInvulnerable?
      pbIncreaseStat(PBStats::ATTACK,2,false)
      @battle.pbDisplay(_INTL("{1}'s Defiant upped its Attack!",pbThis))
      return true
    else
      @battle.pbDisplay(_INTL("{1}'s Defiant had no effect...",pbThis))
      return false
    end
  end
  
  def competitive(increment,attacker)
    if !pbTooHigh?(PBStats::SPATK)
      @battle.pbCommonAnimation("StatUp",attacker,self) if !self.isInvulnerable?
      pbIncreaseStat(PBStats::SPATK,2,false)
      @battle.pbDisplay(_INTL("{1}'s Competitive upped its Special Attack!",pbThis))
      return true
    else
      @battle.pbDisplay(_INTL("{1}'s Competitive had no effect...",pbThis))
      return false
    end
  end
  
  def pbReduceAttackStatStageIntimidate(opponent)
    return false if hp<=0
    return false if effects[PBEffects::Substitute]>0
    if !opponent.hasWorkingAbility(:CONTRARY)
      if hasWorkingAbility(:CLEARBODY) ||
         hasWorkingAbility(:WHITESMOKE) ||
         hasWorkingAbility(:HYPERCUTTER) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS))
        abilityname=PBAbilities.getName(self.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbPartner.pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis))
        return false
      end
      if pbCanReduceStatStage?(PBStats::ATTACK,nil,false)
        tempdefcom=false
        pbReduceStatBasic(PBStats::ATTACK,1)
        oppabilityname=PBAbilities.getName(opponent.ability)
        @battle.pbCommonAnimation("StatDown",opponent,self) if !opponent.isInvulnerable?
        @battle.pbDisplay(_INTL("{1}'s {2} cuts {3}'s Attack!",opponent.pbThis,
           oppabilityname,pbThis(true)))
        if hasWorkingAbility(:DEFIANT)
          tempdefcom=defiant(1,opponent)
        end
          
        if hasWorkingAbility(:COMPETITIVE)
          tempdefcom=competitive(1,opponent)
        end
        return true
      end
    end
    return false
  end
end