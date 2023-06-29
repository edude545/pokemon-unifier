# AI skill levels:
#           0:     Wild Pokémon
#           1-31:  Basic trainer (young/inexperienced)
#           32-47: Some skill
#           48-99: High skill
#           100+:  Gym Leaders, E4, Champion, highest level
module PBTrainerAI
  # Minimum skill level to be in each AI category
  def PBTrainerAI.minimumSkill; 1; end
  def PBTrainerAI.mediumSkill; 32; end
  def PBTrainerAI.highSkill; 48; end
  def PBTrainerAI.bestSkill; 100; end   # Gym Leaders, E4, Champion
end

class PokeBattle_Battle
  attr_accessor(:aimove)
################################################################################
# Get a score for each move being considered.
# Moves with higher scores are more likely to be chosen.
################################################################################
  def pbGetMoveScore(move,attacker,opponent,skill=100)
    debugScore=false #if attacker.species==PBSpecies::KYOGRE
    Kernel.pbMessage("Get score 0") if debugScore
    Kernel.pbMessage(_INTL("{1}",move.name)) if debugScore
    @aimove=true
    oppunaware=true if attacker.hasWorkingAbility(:UNAWARE)
    attunaware=true if opponent.hasWorkingAbility(:UNAWARE)
    if $PokemonSystem.chooseDifficulty==0
      skill=PBTrainerAI.mediumSkill if skill>PBTrainerAI.mediumSkill
    end
    score=100
    
# Alter score depending on the move's function code.
    case move.function
      when 0x00
        if @field.effects[PBEffects::Gravity]>0 && isConst?(move.id,PBMoves,:FLYINGPRESS)
          score-=90
        end
      when 0x01
        score-=95
        if skill>=PBTrainerAI.highSkill
          score=0
        end
      when 0x02 # Struggle
      when 0x03
        if isConst?(move.id,PBMoves,:DARKVOID)
          if @doublebattle
            if opponent.pbPartner.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
              score-=90
            elsif opponent.pbPartner.pbCanSleep?(attacker,false,move)
              score+=30
              if skill>=PBTrainerAI.mediumSkill
                score-=30 if opponent.pbPartner.effects[PBEffects::Yawn]>0
              end
              if skill>=PBTrainerAI.highSkill
                score-=30 if opponent.pbPartner.hasWorkingAbility(:MARVELSCALE)
              end
              if skill>=PBTrainerAI.bestSkill
                for i in opponent.pbPartner.moves
                  movedata=PBMoveData.new(i.id)
                  if movedata.function==0xB4 || # Sleep Talk
                     movedata.function==0x11    # Snore
                    score-=50
                    break
                  end
                end
              end
              if attacker.hasWorkingAbility(:BADDREAMS) || (@doublebattle && 
                 attacker.pbPartner.hasWorkingAbility(:BADDREAMS))
                if pbWeather==PBWeather::NEWMOON
                  score+=40
                else
                  score+=20
                end
              end
            else
              score-=90 if skill>=PBTrainerAI.mediumSkill
            end
          end
        end
        if opponent.pbCanSleep?(attacker,false,move)
          score+=5
          if move.basedamage==0
            score+=25
            if skill>=PBTrainerAI.mediumSkill
              score-=30 if opponent.effects[PBEffects::Yawn]>0
            end
            if skill>=PBTrainerAI.highSkill
              score-=30 if opponent.hasWorkingAbility(:MARVELSCALE)
            end
            if skill>=PBTrainerAI.bestSkill
              for i in opponent.moves
                movedata=PBMoveData.new(i.id)
                if movedata.function==0xB4 || # Sleep Talk
                   movedata.function==0x11    # Snore
                  score-=50
                  break
                end
              end
            end
            if attacker.hasWorkingAbility(:BADDREAMS) || (@doublebattle && 
               attacker.pbPartner.hasWorkingAbility(:BADDREAMS))
              if pbWeather==PBWeather::NEWMOON
                score+=40
              else
                score+=20
              end
            end
            if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
              score=0
            elsif skill>=PBTrainerAI.bestSkill
              # Allow status spamming for higher level opponents to dissuade 
              # cheesing fights with healing items
            else
              score-=70 if $justUsedStatusCure
            end
          end
        else
          if skill>=PBTrainerAI.mediumSkill
            score-=90 if move.basedamage==0
          elsif skill>=PBTrainerAI.highSkill
            score=0 if move.basedamage==0
          end
        end
      when 0x04
        if opponent.effects[PBEffects::Yawn]>0 || !opponent.pbCanSleep?(attacker,false,move)
          score-=90 if skill>=PBTrainerAI.mediumSkill
        elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        else
          score+=30
          if skill>=PBTrainerAI.mediumSkill
            score-=30 if opponent.hasWorkingAbility(:MARVELSCALE)
          end
          if skill>=PBTrainerAI.highSkill
            for i in opponent.moves
              movedata=PBMoveData.new(i.id)
              if movedata.function==0xB4 || # Sleep Talk
                 movedata.function==0x11    # Snore
                score-=50
                break
              end
            end
          end
          if attacker.hasWorkingAbility(:BADDREAMS) || (@doublebattle && 
             attacker.pbPartner.hasWorkingAbility(:BADDREAMS))
            if pbWeather==PBWeather::NEWMOON
              score+=40
            else
              score+=20
            end
          end
          if move.basedamage==0
            if skill>=PBTrainerAI.bestSkill
              # Allow status spamming for higher level opponents to dissuade 
              # cheesing fights with healing items
            else
              score-=70 if $justUsedStatusCure
            end
          end
        end
      when 0x05
        if opponent.pbCanPoison?(attacker,false,move)
          score+=5
          if move.basedamage==0
            score+=25
            if skill>=PBTrainerAI.mediumSkill
              score+=30 if opponent.hp<=opponent.totalhp/4
              score+=50 if opponent.hp<=opponent.totalhp/8
              score-=40 if opponent.effects[PBEffects::Yawn]>0
            end
            if skill>=PBTrainerAI.highSkill
              score+=10 if pbRoughStat(opponent,PBStats::DEFENSE,skill,oppunaware)>100
              score+=10 if pbRoughStat(opponent,PBStats::SPDEF,skill,oppunaware)>100
              score-=40 if opponent.hasWorkingAbility(:GUTS)
              score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
              score-=40 if opponent.hasWorkingAbility(:TOXICBOOST)
            end
            if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
              score=0
            elsif skill>=PBTrainerAI.highSkill
              # Allow status spamming for higher level opponents to dissuade 
              # cheesing fights with healing items
            else
              score-=70 if $justUsedStatusCure
            end
          end
        else
          if skill>=PBTrainerAI.mediumSkill
            score-=90 if move.basedamage==0
          elsif skill>=PBTrainerAI.highSkill
            score=0 if move.basedamage==0
          end
        end
      when 0x06
        if opponent.pbCanPoison?(attacker,false,move)
          score+=5
          if skill>=PBTrainerAI.mediumSkill
            #score+=30 if opponent.hp<=opponent.totalhp/4
            #score+=50 if opponent.hp<=opponent.totalhp/8
            score-=40 if opponent.effects[PBEffects::Yawn]>0
          end
          if skill>=PBTrainerAI.highSkill
            score+=10 if pbRoughStat(opponent,PBStats::DEFENSE,skill,oppunaware)>100
            score+=10 if pbRoughStat(opponent,PBStats::SPDEF,skill,oppunaware)>100
            score-=40 if opponent.hasWorkingAbility(:GUTS)
            score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
            score-=40 if opponent.hasWorkingAbility(:TOXICBOOST)
          end
          if move.basedamage==0
            if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
              score-=90
            elsif skill>=PBTrainerAI.highSkill
              # Allow status spamming for higher level opponents to dissuade 
              # cheesing fights with healing items
              score+=25
            else
              if $justUsedStatusCure
                score-=70 
              else
                score+=25
              end
            end
          end
        else
          if skill>=PBTrainerAI.mediumSkill
            score-=90 if move.basedamage==0
          end
        end
      when 0x07
        typemod=pbTypeModMove(move,attacker,opponent)
        if opponent.pbCanParalyze?(attacker,false,move) && 
           !(skill>=PBTrainerAI.mediumSkill && isConst?(move.id,PBMoves,:THUNDERWAVE) &&
           typemod==0)
          score+=5
          if skill>=PBTrainerAI.mediumSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed
              score+=5
            elsif aspeed>ospeed
              score-=5
            end
          end
          if skill>=PBTrainerAI.highSkill
            score-=40 if opponent.hasWorkingAbility(:GUTS)
            score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
            score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
          end
          if move.basedamage==0
            if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
              score=0
            elsif skill>=PBTrainerAI.highSkill
              # Allow status spamming for higher level opponents to dissuade 
              # cheesing fights with healing items
              score+=25
            else
              score+=25
              score-=70 if $justUsedStatusCure
            end
          end
        else
          if skill>=PBTrainerAI.mediumSkill
            score-=90 if move.basedamage==0
          end
        end
      when 0x08
        typemod=pbTypeModMove(move,attacker,opponent)
        if opponent.pbCanParalyze?(attacker,false,move) && 
           !(skill>=PBTrainerAI.mediumSkill && isConst?(move.id,PBMoves,:THUNDERWAVE) &&
           typemod==0)
          score+=5
          if skill>=PBTrainerAI.mediumSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed
              score+=5
              score+=25 if move.basedamage==0
            elsif aspeed>ospeed
              score-=5
            end
          end
          if skill>=PBTrainerAI.highSkill
            score-=40 if opponent.hasWorkingAbility(:GUTS)
            score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
            score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
          end
        end
      when 0x09
        typemod=pbTypeModMove(move,attacker,opponent)
        if opponent.pbCanParalyze?(attacker,false,move) && 
           !(skill>=PBTrainerAI.mediumSkill && isConst?(move.id,PBMoves,:THUNDERWAVE) &&
           typemod==0)
          if skill>=PBTrainerAI.mediumSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed
              score+=5
              score+=25 if move.basedamage==0
            elsif aspeed>ospeed
              score-=5
            end
          end
          if skill>=PBTrainerAI.highSkill
            score-=40 if opponent.hasWorkingAbility(:GUTS)
            score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
            score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
          end
        end
        #score-=10 if opponent.status==PBStatuses::PARALYSIS
      
      when 0x149
        if opponent.pbHasType?(:GRASS)
          if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif opponent.pbCanBurn?(attacker,false,move)
            score+=200 
            if skill>=PBTrainerAI.highSkill
              score-=40 if opponent.hasWorkingAbility(:GUTS)
              score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
              score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
              score-=40 if opponent.hasWorkingAbility(:FLAREBOOST)
            end
            if move.basedamage==0
              if skill>=PBTrainerAI.highSkill
                # Allow status spamming for higher level opponents to dissuade 
                # cheesing fights with healing items
                hasAttack=false
                for thismove in opponent.moves
                  if thismove.id!=0 && thismove.basedamage>0 &&
                     thismove.pbIsPhysical?(thismove.type)
                    hasAttack=true
                  end
                end
                if !hasAttack
                  # No score modifier if no physical moves exist
                else
                  score+=30 if !opponent.hasWorkingAbility(:GUTS)
                end
              else
                score-=70 if $justUsedStatusCure
              end
            end
          end
          score-=80 if !opponent.pbCanBurn?(attacker,false,move)
        else
          if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          #score-=80 if opponent.status!=0
          elsif !opponent.pbCanBurn?(attacker,false,move)
            score-=90
          else
            if skill>=PBTrainerAI.highSkill
              score-=40 if opponent.hasWorkingAbility(:GUTS)
              score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
              score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
              score-=40 if opponent.hasWorkingAbility(:FLAREBOOST)
            end
            if move.basedamage==0
              if skill>=PBTrainerAI.highSkill
                # Allow status spamming for higher level opponents to dissuade 
                # cheesing fights with healing items
                hasAttack=false
                for thismove in opponent.moves
                  if thismove.id!=0 && thismove.basedamage>0 &&
                     thismove.pbIsPhysical?(thismove.type)
                    hasAttack=true
                  end
                end
                if !hasAttack
                  # No score modifier if no physical moves exist
                else
                  score+=30 if !opponent.hasWorkingAbility(:GUTS)
                end
              else
                score-=70 if $justUsedStatusCure
              end
            end
          end
        end
      when 0x0A
        if move.basedamage==0
          if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          #score-=80 if opponent.status!=0
          elsif !opponent.pbCanBurn?(attacker,false,move)
            score-=90 
          elsif skill>=PBTrainerAI.highSkill
            score+=30
            # Allow status spamming for higher level opponents to dissuade 
            # cheesing fights with healing items
            score-=40 if opponent.hasWorkingAbility(:GUTS)
            score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
            score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
            score-=40 if opponent.hasWorkingAbility(:FLAREBOOST)
            hasAttack=false
            for thismove in opponent.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if !hasAttack
              if attacker.stages[PBStats::SPDEF]>=0 || 
                 attacker.stages[PBStats::DEFENSE]>=0
                score+=50
              end
              score+=30
              # Smaller score modifier if no physical moves exist
            else
              if attacker.stages[PBStats::SPDEF]>=0 || 
                 attacker.stages[PBStats::DEFENSE]>=0
                score+=50
              end
              score+=50 if !opponent.hasWorkingAbility(:GUTS)
            end
          else
            score+=30
            score-=70 if $justUsedStatusCure
          end
        else
          if opponent.pbCanBurn?(attacker,false,move)
            score+=5 
            #score-=40 if opponent.pbHasType?(:FIRE)
            if skill>=PBTrainerAI.highSkill
              score-=40 if opponent.hasWorkingAbility(:GUTS)
              score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
              score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
              score-=40 if opponent.hasWorkingAbility(:FLAREBOOST)
              hasAttack=false
              for thismove in opponent.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                  thismove.pbIsPhysical?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                # No score modifier if no physical moves exist
              else
                score+=30 if !opponent.hasWorkingAbility(:GUTS)
              end
            end
          end
        end
      when 0x0B
        if opponent.pbCanBurn?(attacker,false,move)
          if skill>=PBTrainerAI.highSkill
            score-=40 if opponent.hasWorkingAbility(:GUTS)
            score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
            score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
            score-=40 if opponent.hasWorkingAbility(:FLAREBOOST)
          end
          hasAttack=false
          for thismove in opponent.moves
            if thismove.id!=0 && thismove.basedamage>0 &&
               thismove.pbIsPhysical?(thismove.type)
              hasAttack=true
            end
          end
          if !hasAttack
            # No score modifier if no physical moves exist
          else
            score+=30 if !opponent.hasWorkingAbility(:GUTS)
          end
        end
        #score-=40 if opponent.pbHasType?(:FIRE)
      when 0x0C
        if move.basedamage==0
          #score-=80 if opponent.status!=0
          score-=90 if !opponent.pbCanFreeze?(attacker,false,move)
        elsif opponent.pbCanFreeze?(attacker,false,move)
          score+=30
          if skill>=PBTrainerAI.highSkill
            score-=20 if opponent.hasWorkingAbility(:MARVELSCALE)
          end
        end
      when 0x0D
        if opponent.pbCanFreeze?(attacker,false,move)
          score+=30 
          if skill>=PBTrainerAI.highSkill
            score-=20 if opponent.hasWorkingAbility(:MARVELSCALE)
          end
        end
      when 0x0E
        if opponent.pbCanFreeze?(attacker,false,move)
          if skill>=PBTrainerAI.highSkill
            score-=20 if opponent.hasWorkingAbility(:MARVELSCALE)
          end
        end
      when 0x0F
        score+=5 if !opponent.hasWorkingAbility(:INNERFOCUS) &&
                     (opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker))
      when 0x10
        score+=5 if !opponent.hasWorkingAbility(:INNERFOCUS) &&
                     (opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker))
        score+=30 if opponent.effects[PBEffects::Minimize]
      when 0x11
        if attacker.status==PBStatuses::SLEEP
          if skill>=PBTrainerAI.highSkill && attacker.statusCount<=1
            score-=90
          else
            score+=100
            score+=5 if !opponent.hasWorkingAbility(:INNERFOCUS) &&
                         (opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker))
          end
        end
        score=0 if attacker.status!=PBStatuses::SLEEP
      when 0x12
        score+=30 if !opponent.hasWorkingAbility(:INNERFOCUS) &&
                     (opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker))
        score=0 if attacker.turncount>=1
      when 0x13
        if opponent.pbCanConfuse?(attacker,false,move)
          score+=30
          if move.basedamage==0
            if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
              score-=90
            elsif skill>=PBTrainerAI.highSkill
              # Allow status spamming for higher level opponents to dissuade 
              # cheesing fights with healing items
            else
              score-=70 if $justUsedStatusCure
            end
          end
        else
          if skill>=PBTrainerAI.mediumSkill
            score-=90 if move.basedamage==0
          end
        end
      when 0x14
        if opponent.pbCanConfuse?(attacker,false,move)
          score+=30
        else
          if skill>=PBTrainerAI.mediumSkill
            score-=90 if move.basedamage==0
          end
        end
      when 0x15
        score+=30 if opponent.pbCanConfuse?(attacker,false,move)
      when 0x16
        canattract=true
        agender=attacker.gender
        ogender=opponent.gender
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
              score-=90
        elsif agender==2 || ogender==2 || agender==ogender
          score-=90; canattract=false
        elsif opponent.effects[PBEffects::Attract]>=0
          score-=80; canattract=false
        elsif skill>=PBTrainerAI.bestSkill &&
           opponent.hasWorkingAbility(:OBLIVIOUS)
          score-=80; canattract=false
        end
        if skill>=PBTrainerAI.highSkill
          if canattract && opponent.hasWorkingItem(:DESTINYKNOT) &&
             #attacker.pbCanAttract?(opponent,false)
            score-=30
          end
        end
      when 0x17
        score+=30 if opponent.status==0
      when 0x18
        if attacker.status==PBStatuses::BURN
          score+=40
        elsif attacker.status==PBStatuses::POISON
          score+=40
          if attacker.hp<attacker.totalhp/8
            score+=60
          elsif attacker.hp<(attacker.effects[PBEffects::Toxic]+1)*attacker.totalhp/16
            score+=60
          end
        elsif attacker.status==PBStatuses::PARALYSIS
          score+=40
        else
          score-=90
        end
      when 0x19
        party=pbParty(attacker.index)
        statuses=0
        for i in 0...party.length
          statuses+=1 if party[i] && party[i].status!=0
        end
        if statuses==0
          score-=80
        else
          score+=20*statuses
        end
      when 0x1A
        if attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
          score-=90 
        elsif attacker.status!=0
          score-=40
        else
          score+=30
        end
      when 0x1B
        if attacker.status==0
          score-=90
        else
          score+=40
        end
      when 0x1C
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          else
            score-=90 if attacker.pbTooHigh?(PBStats::ATTACK)
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in attacker.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   thismove.pbIsPhysical?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
                score+=20 if attacker.hasWorkingAbility(:SIMPLE)
              end
            end
            #if score>20
            #  score-=(attacker.stages[PBStats::ATTACK]*10)
            #end
          end
        else
          score+=20 if (attacker.stages[PBStats::ATTACK]<0)
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if hasAttack
              score+=20
              score+=20 if attacker.hasWorkingAbility(:SIMPLE)
            end
          end
          score-=60 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x1D
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::DEFENSE)
            score-=90
          else
            amount=0
            amount-=(attacker.stages[PBStats::DEFENSE]*20)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=20 if (attacker.stages[PBStats::DEFENSE]<0)
          score-=40 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x1E
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::DEFENSE)
          score-=90
        else
          amount=0
          amount-=(attacker.stages[PBStats::DEFENSE]*20)
          amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
          score+=amount
        end
      when 0x154
        score-=200
      when 0x133 #Rage State
        if attacker.pbTooHigh?(PBStats::ATTACK) || attacker.pbTooHigh?(PBStats::SPATK)
          score+=200
        else
          score-=200
        end
      when 0x134 #Adapt
        if attacker.pbTooHigh?(PBStats::DEFENSE) || attacker.pbTooHigh?(PBStats::SPDEF) 
          score+=200
        else
          score-=200
        end
      when 0x1F
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::SPEED)
            score-=90
          else
            score-=(attacker.stages[PBStats::SPEED]*10)
            if skill>=PBTrainerAI.highSkill
              aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
              ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
              if aspeed<ospeed && aspeed*2>ospeed
                score+=30
                score+=30 if attacker.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=20 if (attacker.stages[PBStats::SPEED]<0)
          score-=40 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x20
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::SPATK)
            score-=90
          else
            score-=(attacker.stages[PBStats::SPATK]*20)
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in attacker.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   thismove.pbIsSpecial?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
                score+=20 if attacker.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=20 if (attacker.stages[PBStats::SPATK]<0)
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsSpecial?(thismove.type)
                hasAttack=true
              end
            end
            if hasAttack
              score+=20
            end
          end
          score-=60 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x21
        found=false
        for i in 0...4
          if isConst?(attacker.moves[i].type,PBTypes,:ELECTRIC) &&
             attacker.moves[i].basedamage>0
            found=true
            break
          end
        end
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::SPDEF)
            score-=90 
          else
            amount=0
            amount-=(attacker.stages[PBStats::SPDEF]*20)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
          score+=20 if !found
          #score-=80 if opponent.effects[PBEffects::Charge]>0
        else
          #score-=20 if opponent.effects[PBEffects::Charge]>0
          score+=20 if (attacker.stages[PBStats::SPDEF]<0)
          score+=20 if found
          score-=60 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x22
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::EVASION)
            score-=90
          else
            amount=0
            amount-=(attacker.stages[PBStats::EVASION]*10)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=20 if (attacker.stages[PBStats::EVASION]<0)
          score-=40 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x23
        if move.basedamage==0
          if attacker.effects[PBEffects::FocusEnergy]>=2
            score-=80
          else
            score+=30
          end
          #score-=80 if attacker.effects[PBEffects::FocusEnergy]>0
        else
          score+=30 if attacker.effects[PBEffects::FocusEnergy]<2
          #score-=20 if attacker.effects[PBEffects::FocusEnergy]>0
        end
      when 0x24
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::ATTACK) &&
           attacker.pbTooHigh?(PBStats::DEFENSE)
          score-=90
        else
          amount=0
          amount-=(attacker.stages[PBStats::ATTACK]*10)
          amount-=(attacker.stages[PBStats::DEFENSE]*10)
          amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
          score+=amount
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if !hasAttack
              score-=90
            else
              score+=20
            end
          end
        end
      when 0x25
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::ATTACK) &&
           attacker.pbTooHigh?(PBStats::DEFENSE) &&
           attacker.pbTooHigh?(PBStats::ACCURACY)
          score-=90
        else
          amount=0
          amount-=(attacker.stages[PBStats::ATTACK]*10)
          amount-=(attacker.stages[PBStats::DEFENSE]*10)
          amount-=(attacker.stages[PBStats::ACCURACY]*10)
          amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
          score+=amount
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if !hasAttack
              score-=90
            else
              score+=20
            end
          end
        end
      when 0x26 # Dragon Dance tends to be popular
        score+=40 if attacker.turncount==0
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::ATTACK) &&
           attacker.pbTooHigh?(PBStats::SPEED)
          score-=90
        else
          amount=0
          amount-=(attacker.stages[PBStats::ATTACK]*10)
          amount-=(attacker.stages[PBStats::SPEED]*10)
          amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
          score+=amount
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if !hasAttack
              score-=90
            else
              score+=20
            end
          end
        end
      when 0x27
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::ATTACK) &&
           attacker.pbTooHigh?(PBStats::SPATK)
          score-=90 
        else
          amount=0
          amount-=(attacker.stages[PBStats::ATTACK]*10)
          amount-=(attacker.stages[PBStats::SPATK]*10)
          amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
          score+=amount
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0
                hasAttack=true
              end
            end
            if !hasAttack
              score-=90
            else
              score+=20
            end
          end
        end
      when 0x28
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        else
          if attacker.pbTooHigh?(PBStats::ATTACK) &&
             attacker.pbTooHigh?(PBStats::SPATK)
            score-=90 
          else
            amount=0
            amount-=(attacker.stages[PBStats::ATTACK]*10)
            amount-=(attacker.stages[PBStats::SPATK]*10)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in attacker.moves
                if thismove.id!=0 && thismove.basedamage>0
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
              end
            end
          end
          score+=20 if pbWeather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN
        end
      when 0x29
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        else
          if attacker.pbTooHigh?(PBStats::ATTACK) &&
             attacker.pbTooHigh?(PBStats::ACCURACY)
            score-=90 
          else
            amount=0
            amount-=(attacker.stages[PBStats::ATTACK]*10)
            amount-=(attacker.stages[PBStats::ACCURACY]*10)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in attacker.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   thismove.pbIsPhysical?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
              end
            end
          end
          score+=20 if pbWeather==PBWeather::NEWMOON
        end
      when 0x2A
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::DEFENSE) &&
           attacker.pbTooHigh?(PBStats::SPDEF)
          score-=90 
        else
          amount=0
          amount-=(attacker.stages[PBStats::DEFENSE]*10)
          amount-=(attacker.stages[PBStats::SPDEF]*10)
          amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
          score+=amount
        end
      when 0x2B
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::SPEED) &&
           attacker.pbTooHigh?(PBStats::SPATK) &&
           attacker.pbTooHigh?(PBStats::SPDEF)
          score-=90 
        else
          amount=0
          amount-=(attacker.stages[PBStats::SPEED]*10)
          amount-=(attacker.stages[PBStats::SPATK]*10)
          amount-=(attacker.stages[PBStats::SPDEF]*10)
          amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
          score+=amount
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsSpecial?(thismove.type)
                hasAttack=true
              end
            end
            if !hasAttack
              score-=90
            else
              score+=20
            end
          end
          if skill>=PBTrainerAI.mediumSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed && aspeed*2>ospeed
              score+=20
              score+=20 if attacker.hasWorkingAbility(:SIMPLE)
            end
          end
        end
      when 0x2C # Calm Mind tends to be popular
        score+=40 if attacker.turncount==0
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::SPATK) &&
           attacker.pbTooHigh?(PBStats::SPDEF)
          score-=90
        else
          amount=0
          amount-=(attacker.stages[PBStats::SPATK]*10)
          amount-=(attacker.stages[PBStats::SPDEF]*10)
          amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
          score+=amount
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsSpecial?(thismove.type)
                hasAttack=true
              end
            end
            if !hasAttack
              score-=90
            else
              score+=20
              score+=20 if attacker.hasWorkingAbility(:SIMPLE)
            end
          end
        end
      when 0x2D
        score+=10 if (attacker.stages[PBStats::ATTACK]<0)
        score+=10 if (attacker.stages[PBStats::DEFENSE]<0)
        score+=10 if (attacker.stages[PBStats::SPEED]<0)
        score+=10 if (attacker.stages[PBStats::SPATK]<0)
        score+=10 if (attacker.stages[PBStats::SPDEF]<0)
        if skill>=PBTrainerAI.mediumSkill
          hasAttack=false
          for thismove in attacker.moves
            if thismove.id!=0 && thismove.basedamage>0 &&
              hasAttack=true
            end
          end
          if hasAttack
            score+=20
          end
        end
        score-=90 if attacker.hasWorkingAbility(:CONTRARY)
      when 0x2E
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::ATTACK)
            score-=90 
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount-=(attacker.stages[PBStats::ATTACK]*20)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in attacker.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   thismove.pbIsPhysical?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
                score+=20 if attacker.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if attacker.stages[PBStats::ATTACK]<0
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            score+=20 if hasAttack
          end
          score-=70 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x2F
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::DEFENSE)
            score-=90 
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount-=(attacker.stages[PBStats::DEFENSE]*20)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if (attacker.stages[PBStats::DEFENSE]<0)
          score-=50 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x30
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::SPEED)
            score-=90
          else
            score+=20 if attacker.turncount==0
            score-=(attacker.stages[PBStats::SPEED]*10)
            if skill>=PBTrainerAI.highSkill
              aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
              ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
              if aspeed<ospeed && aspeed*2>ospeed
                score+=30
                score+=30 if attacker.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if (attacker.stages[PBStats::SPEED]<0)
          score-=50 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x31
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::SPEED)
            score-=90
          else
            score+=20 if attacker.turncount==0
            score-=(attacker.stages[PBStats::SPEED]*10)
            if skill>=PBTrainerAI.highSkill
              aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
              ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
              if aspeed<ospeed && aspeed*2>ospeed
                score+=30
                score+=30 if attacker.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if (attacker.stages[PBStats::SPEED]<0)
          score-=50 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x32
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::SPATK)
            score-=90
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount-=(attacker.stages[PBStats::SPATK]*20)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
            
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in attacker.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   !thismove.pbIsPhysical?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
                score+=20 if attacker.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if attacker.stages[PBStats::SPATK]<0
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 !thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if hasAttack
              score+=20 
            end
          end
          score-=70 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x33
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::SPDEF)
            score-=90 
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount-=(attacker.stages[PBStats::SPDEF]*20)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if attacker.stages[PBStats::SPDEF]<0
          score-=50 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x34
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::EVASION)
            score-=90
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount-=(attacker.stages[PBStats::EVASION]*10)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if attacker.stages[PBStats::EVASION]<0
          score-=50 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x35
        amount=0
        amount-=attacker.stages[PBStats::ATTACK]*20
        amount-=attacker.stages[PBStats::SPEED]*20
        amount-=attacker.stages[PBStats::SPATK]*20
        amount+=attacker.stages[PBStats::DEFENSE]*10
        amount+=attacker.stages[PBStats::SPDEF]*10
        amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
        amount*=-1 if attacker.hasWorkingAbility(:CONTRARY)
        score+=amount
        score+=50 if attacker.hasWorkingAbility(:WHITEHERB)
        if skill>=PBTrainerAI.mediumSkill
          hasAttack=false
          for thismove in attacker.moves
            if thismove.id!=0 && thismove.basedamage>0
              hasAttack=true
            end
          end
          if hasAttack
            score+=20
            score-=40 if attacker.hasWorkingAbility(:CONTRARY)
          end
        end
      when 0x36
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::ATTACK) &&
           attacker.pbTooHigh?(PBStats::SPEED)
          score-=90
        else
          amount=0
          amount-=(attacker.stages[PBStats::ATTACK]*10)
          amount-=(attacker.stages[PBStats::SPEED]*10)
          amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
          score+=amount
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if !hasAttack
              score-=90
            elsif 
              score+=20
              score+=20 if attacker.hasWorkingAbility(:SIMPLE)
            end
          end
          if skill>=PBTrainerAI.mediumSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed && aspeed*2>ospeed
              score+=30
              score+=30 if attacker.hasWorkingAbility(:SIMPLE)
            end
          end
        end
      when 0x37
        if opponent.pbTooHigh?(PBStats::ATTACK) &&
           opponent.pbTooHigh?(PBStats::DEFENSE) &&
           opponent.pbTooHigh?(PBStats::SPEED) &&
           opponent.pbTooHigh?(PBStats::SPATK) &&
           opponent.pbTooHigh?(PBStats::SPDEF) &&
           opponent.pbTooHigh?(PBStats::ACCURACY) &&
           opponent.pbTooHigh?(PBStats::EVASION)
          score-=90
        else
          avstat=0
          avstat-=opponent.stages[PBStats::ATTACK]
          avstat-=opponent.stages[PBStats::DEFENSE]
          avstat-=opponent.stages[PBStats::SPEED]
          avstat-=opponent.stages[PBStats::SPATK]
          avstat-=opponent.stages[PBStats::SPDEF]
          avstat-=opponent.stages[PBStats::ACCURACY]
          avstat-=opponent.stages[PBStats::EVASION]
          avstat=(avstat/2).floor if avstat<0 # More chance of getting even better
          avstat*=2 if opponent.hasWorkingAbility(:SIMPLE)
          avstat*=-1 if opponent.hasWorkingAbility(:CONTRARY)
          score+=avstat*10
        end
      when 0x38
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::DEFENSE)
            score-=90 
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount-=(attacker.stages[PBStats::DEFENSE]*30)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if attacker.turncount==0
          score+=30 if (attacker.stages[PBStats::DEFENSE]<0)
          score-=60 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x39
        if move.basedamage==0
          if attacker.hasWorkingAbility(:CONTRARY)
            score=0
          elsif attacker.pbTooHigh?(PBStats::SPATK)
            score-=90
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount-=(attacker.stages[PBStats::SPATK]*30)
            amount*=2 if attacker.hasWorkingAbility(:SIMPLE)
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in attacker.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   thismove.pbIsSpecial?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
                score+=20 if attacker.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=10 if attacker.turncount==0
          score+=30 if attacker.stages[PBStats::SPATK]<0
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsSpecial?(thismove.type)
                hasAttack=true
              end
            end
            if hasAttack
              score+=30
            end
          end
          score-=90 if attacker.hasWorkingAbility(:CONTRARY)
        end
      when 0x3A
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::ATTACK) ||
           attacker.hp<=attacker.totalhp/2
          score-=100
        else
          score+=(6-attacker.stages[PBStats::ATTACK])*10
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if !hasAttack
              score-=90
            else
              score+=40
            end
          end
        end
      when 0x3B
        avg=(attacker.stages[PBStats::ATTACK]*10)
        avg+=(attacker.stages[PBStats::DEFENSE]*10)
        avg*=2 if attacker.hasWorkingAbility(:SIMPLE)
        score+=avg/2
        score*=-1 if attacker.hasWorkingAbility(:CONTRARY)
      when 0x3C
        avg=(attacker.stages[PBStats::DEFENSE]*10)
        avg+=(attacker.stages[PBStats::SPDEF]*10)
        score+=avg/2
        score*=-1 if attacker.hasWorkingAbility(:CONTRARY)
      when 0x3D
        avg=(attacker.stages[PBStats::DEFENSE]*10)
        avg+=(attacker.stages[PBStats::SPEED]*10)
        avg+=(attacker.stages[PBStats::SPDEF]*10)
        score+=(avg/3).floor
        score*=-1 if attacker.hasWorkingAbility(:CONTRARY)
      when 0x3E
        if attacker.hasWorkingAbility(:CONTRARY)
          score+=20 if attacker.stages[PBStats::SPEED]<=0
        else
          score+=(attacker.stages[PBStats::SPEED]*10)
        end
      when 0x3F
        if attacker.hasWorkingAbility(:CONTRARY)
          score+=20 if attacker.stages[PBStats::SPATK]<=0
        else
          score+=(attacker.stages[PBStats::SPATK]*10)
        end
      when 0x40
        if !opponent.pbCanConfuse?(attacker,false,move)
          score-=90
        else 
          score+=30 if opponent.stages[PBStats::SPATK]<=0
        end
      when 0x41
        if (opponent.hasWorkingAbility(:MAGICBOUNCE) || 
           (opponent.effects[PBEffects::Substitute]>0 && 
           !move.ignoresSubstitute?(attacker))) && skill>=PBTrainerAI.highSkill
          score=0
        elsif !opponent.pbCanConfuse?(attacker,false,move)
          hasAttack=false
          for thismove in opponent.moves
            if thismove.id!=0 && thismove.basedamage>0 &&
               thismove.pbIsPhysical?(thismove.type)
              hasAttack=true
            end
          end
          if !hasAttack && attacker.pbHasMoveFunction?(0x121) && 
             skill>=PBTrainerAI.highSkill
            score+=30 if opponent.stages[PBStats::ATTACK]<=0 
            score-=30 if opponent.stages[PBStats::ATTACK]>0 
          else
            score-=90
          end
        else
          score+=30
          score+=30 if opponent.stages[PBStats::ATTACK]<=0 
          score-=30 if opponent.stages[PBStats::ATTACK]>0 
        end
      when 0x42
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
              score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker)
            score-=90
          else
            amount=0
            amount+=opponent.stages[PBStats::ATTACK]*20
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in opponent.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   thismove.pbIsPhysical?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
                score+=20 if opponent.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=20 if opponent.stages[PBStats::ATTACK]>0
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in opponent.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if hasAttack
              score+=20
            end
          end
          score-=40 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x43
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker)
            score-=90 
          else
            amount=0
            amount+=opponent.stages[PBStats::DEFENSE]*20
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if opponent.stages[PBStats::DEFENSE]>0
          score-=10 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x44
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker)
            score-=90
          else
            score+=opponent.stages[PBStats::SPEED]*10
            if skill>=PBTrainerAI.highSkill
              aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
              ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
              if aspeed<ospeed && aspeed*2>ospeed
                score+=30
                score+=30 if opponent.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          amt=0
          amt+=opponent.stages[PBStats::SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed && aspeed*2>ospeed
              amt+=30
              amt+=30 if opponent.hasWorkingAbility(:SIMPLE)
            end
          end
          amt*=-1 if opponent.hasWorkingAbility(:CONTRARY)
          score+=amt
        end
      when 0x45
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker)
            score-=90
          else
            amount=0
            amount+=opponent.stages[PBStats::SPATK]*20
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in opponent.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   thismove.pbIsSpecial?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else 
                score+=20
                score+=20 if opponent.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=20 if attacker.stages[PBStats::SPATK]>0
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in opponent.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsSpecial?(thismove.type)
                hasAttack=true
              end
            end
            if hasAttack
              score+=20
            end
          end
          score-=60 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x46
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker)
            score-=90
          else
            amount=0
            amount+=opponent.stages[PBStats::SPDEF]*20
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if opponent.stages[PBStats::SPDEF]>0
          score-=20 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x47
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,attacker)
            score-=90
          else
            amount=0
            amount+=opponent.stages[PBStats::ACCURACY]*10
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if opponent.stages[PBStats::ACCURACY]>0
          score-=20 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x48
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker)
            score-=90
          else
            amount=0
            amount+=opponent.stages[PBStats::EVASION]*10
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if opponent.stages[PBStats::EVASION]>0
          score-=20 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x49
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score-=30
          elsif !opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker)
            score-=30 
          else
            amount=0
            amount+=opponent.stages[PBStats::EVASION]*10
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=20 if opponent.stages[PBStats::EVASION]>0
          score-=20 if opponent.hasWorkingAbility(:CONTRARY)
        end
        score+=30 if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                     opponent.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                     opponent.pbOwnSide.effects[PBEffects::Mist]>0 ||
                     opponent.pbOwnSide.effects[PBEffects::Safeguard]>0
        score+=30 if attacker.pbOwnSide.effects[PBEffects::Spikes]>0 ||
                     attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
                     attacker.pbOwnSide.effects[PBEffects::StealthRock] ||
                     attacker.pbOwnSide.effects[PBEffects::FireRock] ||
                     attacker.pbOwnSide.effects[PBEffects::Livewire]>0 ||
                     attacker.pbOwnSide.effects[PBEffects::Permafrost]>0 ||
                     attacker.pbOwnSide.effects[PBEffects::StickyWeb]
        score-=30 if attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                     attacker.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                     attacker.pbOwnSide.effects[PBEffects::Mist]>0 ||
                     attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
        score-=30 if opponent.pbOwnSide.effects[PBEffects::Spikes]>0 ||
                     opponent.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
                     opponent.pbOwnSide.effects[PBEffects::StealthRock] ||
                     opponent.pbOwnSide.effects[PBEffects::FireRock] ||
                     opponent.pbOwnSide.effects[PBEffects::Livewire]>0 ||
                     opponent.pbOwnSide.effects[PBEffects::Permafrost]>0 ||
                     opponent.pbOwnSide.effects[PBEffects::StickyWeb]
      when 0x4A
        if opponent.hasWorkingAbility(:CONTRARY)
          score=0
        elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        else
          avg=(opponent.stages[PBStats::ATTACK]*10)
          avg+=(opponent.stages[PBStats::DEFENSE]*10)
          avg*=2 if opponent.hasWorkingAbility(:SIMPLE)
          score+=avg/2
        end
      when 0x4B
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score=0
          elsif !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker)
            score-=90
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount+=opponent.stages[PBStats::ATTACK]*20
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in opponent.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   thismove.pbIsPhysical?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
                score+=20 if opponent.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if opponent.stages[PBStats::ATTACK]>0
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in opponent.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            if hasAttack
              score+=20
            end
          end
          score-=70 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x4C
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker)
            score-=90
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount+=opponent.stages[PBStats::DEFENSE]*20
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if opponent.stages[PBStats::DEFENSE]>0
          score-=50 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x4D
        if opponent.hasWorkingAbility(:CONTRARY)
          score=0
        elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif move.basedamage==0
          if !opponent.pbCanReduceStatStage?(PBStats::SPEED,attacker)
            score-=90
          else
            score+=20 if attacker.turncount==0
            score+=opponent.stages[PBStats::SPEED]*20
            if skill>=PBTrainerAI.highSkill
              aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
              ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
              if aspeed<ospeed && aspeed*2>ospeed
                score+=30
                score+=30 if opponent.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=10 if attacker.turncount==0
          score+=30 if opponent.stages[PBStats::SPEED]>0
        end
      when 0x4E
        if attacker.gender==2 || opponent.gender==2 ||
           attacker.gender==opponent.gender ||
           opponent.hasWorkingAbility(:OBLIVIOUS)
          score-=90
        elsif move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker)
            score-=90
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount+=opponent.stages[PBStats::SPATK]*20
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
            if skill>=PBTrainerAI.mediumSkill
              hasAttack=false
              for thismove in opponent.moves
                if thismove.id!=0 && thismove.basedamage>0 &&
                   thismove.pbIsSpecial?(thismove.type)
                  hasAttack=true
                end
              end
              if !hasAttack
                score-=90
              else
                score+=20
                score+=20 if opponent.hasWorkingAbility(:SIMPLE)
              end
            end
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if opponent.stages[PBStats::SPATK]>0
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in opponent.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsSpecial?(thismove.type)
                hasAttack=true
              end
            end
            if hasAttack
              score+=30
            end
          end
          score-=80 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x4F
        if move.basedamage==0
          if opponent.hasWorkingAbility(:CONTRARY)
            score=0
          elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
            score-=90
          elsif !opponent.pbCanReduceStatStage?(PBStats::SPDEF,attacker)
            score-=90
          else
            score+=40 if attacker.turncount==0
            amount=0
            amount+=opponent.stages[PBStats::SPDEF]*20
            amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
            score+=amount
          end
        else
          score+=10 if attacker.turncount==0
          score+=20 if opponent.stages[PBStats::SPDEF]>0
          score-=50 if opponent.hasWorkingAbility(:CONTRARY)
        end
      when 0x50
        if opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)
          score-=90
        else
          anychange=false
          avg=opponent.stages[PBStats::ATTACK]; anychange=true if avg!=0
          avg+=opponent.stages[PBStats::DEFENSE]; anychange=true if avg!=0
          avg+=opponent.stages[PBStats::SPEED]; anychange=true if avg!=0
          avg+=opponent.stages[PBStats::SPATK]; anychange=true if avg!=0
          avg+=opponent.stages[PBStats::SPDEF]; anychange=true if avg!=0
          avg+=opponent.stages[PBStats::ACCURACY]; anychange=true if avg!=0
          avg+=opponent.stages[PBStats::EVASION]; anychange=true if avg!=0
          if anychange
            score+=avg*10
          else
            score-=90
          end
        end
      when 0x51
        if skill>=PBTrainerAI.mediumSkill
          stages=0
          for i in 0...4
            battler=@battlers[i]
            if !battler.fainted?
              if attacker.pbIsOpposing?(i)
                stages+=battler.stages[PBStats::ATTACK]
                stages+=battler.stages[PBStats::DEFENSE]
                stages+=battler.stages[PBStats::SPEED]
                stages+=battler.stages[PBStats::SPATK]
                stages+=battler.stages[PBStats::SPDEF]
                stages+=battler.stages[PBStats::EVASION]
                stages+=battler.stages[PBStats::ACCURACY]
              else
                stages-=battler.stages[PBStats::ATTACK]
                stages-=battler.stages[PBStats::DEFENSE]
                stages-=battler.stages[PBStats::SPEED]
                stages-=battler.stages[PBStats::SPATK]
                stages-=battler.stages[PBStats::SPDEF]
                stages-=battler.stages[PBStats::EVASION]
                stages-=battler.stages[PBStats::ACCURACY]
              end
            end
          end
          if stages>0
            score+=stages*10
          else
            score=0
          end
        end
      when 0x52
        if skill>=PBTrainerAI.mediumSkill
          aatk=attacker.stages[PBStats::ATTACK]
          aspa=attacker.stages[PBStats::SPATK]
          oatk=opponent.stages[PBStats::ATTACK]
          ospa=opponent.stages[PBStats::SPATK]
          if aatk>=oatk && aspa>=ospa
            score-=80
          else
            score+=(oatk-aatk)*10
            score+=(ospa-aspa)*10
          end
        else
          score-=50
        end
      when 0x53
        if skill>=PBTrainerAI.mediumSkill
          adef=attacker.stages[PBStats::DEFENSE]
          aspd=attacker.stages[PBStats::SPDEF]
          odef=opponent.stages[PBStats::DEFENSE]
          ospd=opponent.stages[PBStats::SPDEF]
          if adef>=odef && aspd>=ospd
            score-=80
          else
            score+=(odef-adef)*10
            score+=(ospd-aspd)*10
          end
        else
          score-=50
        end
      when 0x54
        if skill>=PBTrainerAI.mediumSkill
          astages=attacker.stages[PBStats::ATTACK]
          astages+=attacker.stages[PBStats::DEFENSE]
          astages+=attacker.stages[PBStats::SPEED]
          astages+=attacker.stages[PBStats::SPATK]
          astages+=attacker.stages[PBStats::SPDEF]
          astages+=attacker.stages[PBStats::EVASION]
          astages+=attacker.stages[PBStats::ACCURACY]
          ostages=opponent.stages[PBStats::ATTACK]
          ostages+=opponent.stages[PBStats::DEFENSE]
          ostages+=opponent.stages[PBStats::SPEED]
          ostages+=opponent.stages[PBStats::SPATK]
          ostages+=opponent.stages[PBStats::SPDEF]
          ostages+=opponent.stages[PBStats::EVASION]
          ostages+=opponent.stages[PBStats::ACCURACY]
          score+=(ostages-astages)*10
        else
          score-=50
        end
      when 0x55
        if skill>=PBTrainerAI.mediumSkill
          equal=true
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                   PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
            stagediff=opponent.stages[i]-attacker.stages[i]
            score+=stagediff*10
            equal=false if stagediff!=0
          end
          score-=80 if equal
        else
          score-=50
        end
      when 0x56
        score-=80 if attacker.pbOwnSide.effects[PBEffects::Mist]>0
      when 0x57
        if skill>=PBTrainerAI.mediumSkill
          aatk=pbRoughStat(attacker,PBStats::ATTACK,skill)
          adef=pbRoughStat(attacker,PBStats::DEFENSE,skill)
          if aatk==adef ||
             attacker.effects[PBEffects::PowerTrick] # No flip-flopping
            score-=90
          elsif adef>aatk # Prefer a higher Attack
            score+=30
          else
            score-=30
          end
        else
          score-=30
        end
      when 0x58
        if skill>=PBTrainerAI.mediumSkill
          aatk=pbRoughStat(attacker,PBStats::ATTACK,skill)
          aspatk=pbRoughStat(attacker,PBStats::SPATK,skill)
          oatk=pbRoughStat(opponent,PBStats::ATTACK,skill)
          ospatk=pbRoughStat(opponent,PBStats::SPATK,skill)
          if aatk<oatk && aspatk<ospatk
            score+=50
          elsif (aatk+aspatk)<(oatk+ospatk)
            score+=30
          else
            score-=50
          end
        else
          score-=30
        end
      when 0x59
        if skill>=PBTrainerAI.mediumSkill
          adef=pbRoughStat(attacker,PBStats::DEFENSE,skill)
          aspdef=pbRoughStat(attacker,PBStats::SPDEF,skill)
          odef=pbRoughStat(opponent,PBStats::DEFENSE,skill)
          ospdef=pbRoughStat(opponent,PBStats::SPDEF,skill)
          if adef<odef && aspdef<ospdef
            score+=50
          elsif (adef+aspdef)<(odef+ospdef)
            score+=30
          else
            score-=50
          end
        else
          score-=30
        end
      when 0x5A
        if opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)
          score-=90
        elsif attacker.hp>=(attacker.hp+opponent.hp)/2
          score-=90
        else
          score+=40
        end
      when 0x5B
        if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0
          score-=90
        elsif @doublebattle
          score*=2
        end
      when 0x5C
        blacklist=[
           0x02,   # Struggle
           0x14,   # Chatter
           0x5C,   # Mimic
           0x5D,   # Sketch
           0xB6,    # Metronome
           0x214,  # Fairy Tempest
           0x215,  # Dynamic Fury
           0x216,  # Aura Blast
           0x217   # Dark Nova
        ]
        if attacker.effects[PBEffects::Transform] ||
           opponent.lastMoveUsed<=0 ||
           isConst?(PBMoveData.new(opponent.lastMoveUsed).type,PBTypes,:SHADOW) ||
           blacklist.include?(PBMoveData.new(opponent.lastMoveUsed).function)
          score-=90
        end
        for i in attacker.moves
          if i.id==opponent.lastMoveUsed
            score-=90; break
          end
        end
      when 0x5D
        blacklist=[
         0x02,   # Struggle
         0x14,   # Chatter
         0x5D,    # Sketch
         0x214,  # Fairy Tempest
         0x215,  # Dynamic Fury
         0x216,  # Aura Blast
         0x217   # Dark Nova
        ]
        if attacker.effects[PBEffects::Transform] ||
           opponent.lastMoveUsedSketch<=0 ||
           isConst?(PBMoveData.new(opponent.lastMoveUsedSketch).type,PBTypes,:SHADOW) ||
           blacklist.include?(PBMoveData.new(opponent.lastMoveUsedSketch).function)
          score-=90
        end
        for i in attacker.moves
          if i.id==opponent.lastMoveUsedSketch
            score-=90; break
          end
        end
      when 0x5E
        if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
          score-=90
        else
          types=[]
          for i in attacker.moves
            next if i.id==@id
            next if PBTypes.isPseudoType?(i.type)
            next if attacker.pbHasType?(i.type)
            found=false
            types.push(i.type) if !types.include?(i.type)
          end
          if types.length==0
            score-=90
          end
        end
      when 0x5F
        if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
          score-=90
        elsif opponent.lastMoveUsed<=0 ||
           PBTypes.isPseudoType?(PBMoveData.new(opponent.lastMoveUsed).type)
          score-=90
        else
          atype=-1
          for i in opponent.moves
            if i.id==opponent.lastMoveUsed
              atype=i.pbType(move.type,attacker,opponent); break
            end
          end
          if atype<0
            score-=90
          else
            types=[]
            for i in 0..PBTypes.maxValue
              next if attacker.pbHasType?(i)
              types.push(i) if PBTypes.getEffectiveness(atype,i)<2 
            end
            if types.length==0
              score-=90
            end
          end
        end
      when 0x60
        if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
          score-=90
        elsif skill>=PBTrainerAI.mediumSkill
          envtypes=[
             :NORMAL, # None
             :GRASS,  # Grass
             :GRASS,  # Tall grass
             :WATER,  # Moving water
             :WATER,  # Still water
             :WATER,  # Underwater
             :ROCK,   # Rock
             :ROCK,   # Cave
             :GROUND  # Sand
          ]
          type=envtypes[@environment]
          score-=90 if attacker.pbHasType?(type)
        end
      when 0x61
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif (opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)) ||
           isConst?(opponent.ability,PBAbilities,:MULTITYPE)
          score-=90
        elsif opponent.pbHasType?(:WATER)
          score-=90
        end
      when 0x62
        if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
          score-=90
        elsif attacker.pbHasType?(opponent.type1) &&
           attacker.pbHasType?(opponent.type2) &&
           opponent.pbHasType?(attacker.type1) &&
           opponent.pbHasType?(attacker.type2)
          score-=90
        end
      when 0x63
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)
          score-=90
        elsif skill>=PBTrainerAI.mediumSkill
          if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
             isConst?(opponent.ability,PBAbilities,:SIMPLE) ||
             isConst?(opponent.ability,PBAbilities,:TRUANT) ||
             isConst?(opponent.ability,PBAbilities,:STANCECHANGE) ||
             isConst?(opponent.ability,PBAbilities,:POWERCONSTRUCT) ||
             isConst?(opponent.ability,PBAbilities,:LERNEAN)
            score-=90
          end
        end
      when 0x64
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)
          score-=90
        elsif skill>=PBTrainerAI.mediumSkill
          if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
             isConst?(opponent.ability,PBAbilities,:INSOMNIA) ||
             isConst?(opponent.ability,PBAbilities,:TRUANT) ||
             isConst?(opponent.ability,PBAbilities,:STANCECHANGE) ||
             isConst?(opponent.ability,PBAbilities,:POWERCONSTRUCT) ||
             isConst?(opponent.ability,PBAbilities,:LERNEAN)
            score-=90
          end
        end
      when 0x65
        score-=40 # don't prefer this move
        if skill>=PBTrainerAI.mediumSkill
          if opponent.ability==0 ||
             attacker.ability==opponent.ability ||
             isConst?(attacker.ability,PBAbilities,:MULTITYPE) ||
             isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
             isConst?(opponent.ability,PBAbilities,:FLOWERGIFT) ||
             isConst?(opponent.ability,PBAbilities,:FORECAST) ||
             isConst?(opponent.ability,PBAbilities,:ILLUSION) ||
             isConst?(opponent.ability,PBAbilities,:IMPOSTER) ||
             isConst?(opponent.ability,PBAbilities,:TRACE) ||
             isConst?(opponent.ability,PBAbilities,:WONDERGUARD) ||
             isConst?(attacker.ability,PBAbilities,:LERNEAN) ||
             isConst?(opponent.ability,PBAbilities,:LERNEAN) ||
             isConst?(attacker.ability,PBAbilities,:ZENMODE) ||
             isConst?(opponent.ability,PBAbilities,:ZENMODE) ||
             isConst?(attacker.ability,PBAbilities,:STANCECHANGE) ||
             isConst?(opponent.ability,PBAbilities,:STANCECHANGE) ||
             isConst?(attacker.ability,PBAbilities,:POWERCONSTRUCT) ||
             isConst?(opponent.ability,PBAbilities,:POWERCONSTRUCT)
            score-=90
          end
        end
        if skill>=PBTrainerAI.highSkill
          if isConst?(opponent.ability,PBAbilities,:TRUANT) && 
             attacker.pbIsOpposing?(opponent.index)
            score-=90
          elsif isConst?(opponent.ability,PBAbilities,:SLOWSTART) &&
             attacker.pbIsOpposing?(opponent.index)
            score-=90
          end
        end
      when 0x66
        score-=40 # don't prefer this move
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)
          score-=90
        elsif skill>=PBTrainerAI.mediumSkill
          if attacker.ability==0 ||
             attacker.ability==opponent.ability ||
             isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
             isConst?(opponent.ability,PBAbilities,:TRUANT) ||
             isConst?(attacker.ability,PBAbilities,:FLOWERGIFT) ||
             isConst?(attacker.ability,PBAbilities,:FORECAST) ||
             isConst?(attacker.ability,PBAbilities,:ILLUSION) ||
             isConst?(attacker.ability,PBAbilities,:IMPOSTER) ||
             isConst?(attacker.ability,PBAbilities,:TRACE) ||
             isConst?(attacker.ability,PBAbilities,:ZENMODE) ||
             isConst?(attacker.ability,PBAbilities,:LERNEAN) ||
             isConst?(opponent.ability,PBAbilities,:STANCECHANGE) ||
             isConst?(attacker.ability,PBAbilities,:POWERCONTRUCT)
            score-=90
          end
          if skill>=PBTrainerAI.highSkill
            if isConst?(attacker.ability,PBAbilities,:TRUANT) && 
               attacker.pbIsOpposing?(opponent.index)
              score+=90
            elsif isConst?(attacker.ability,PBAbilities,:SLOWSTART) &&
               attacker.pbIsOpposing?(opponent.index)
              score+=90
            end
          end
        end
      when 0x67
        score-=40 # don't prefer this move
        if skill>=PBTrainerAI.mediumSkill
          if (attacker.ability==0 && opponent.ability==0) ||
             attacker.ability==opponent.ability ||
             isConst?(attacker.ability,PBAbilities,:MULTITYPE) ||
             isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
             isConst?(attacker.ability,PBAbilities,:ILLUSION) ||
             isConst?(opponent.ability,PBAbilities,:ILLUSION) ||
             isConst?(attacker.ability,PBAbilities,:WONDERGUARD) ||
             isConst?(opponent.ability,PBAbilities,:WONDERGUARD) ||
             isConst?(attacker.ability,PBAbilities,:LERNEAN) ||
             isConst?(opponent.ability,PBAbilities,:LERNEAN) ||
             isConst?(attacker.ability,PBAbilities,:STANCECHANGE) ||
             isConst?(opponent.ability,PBAbilities,:STANCECHANGE) ||
             isConst?(attacker.ability,PBAbilities,:POWERCONSTRUCT) ||
             isConst?(opponent.ability,PBAbilities,:POWERCONSTRUCT)
            score-=90
          end
        end
        if skill>=PBTrainerAI.highSkill
          if isConst?(opponent.ability,PBAbilities,:TRUANT) && 
             attacker.pbIsOpposing?(opponent.index)
            score-=90
          elsif isConst?(opponent.ability,PBAbilities,:SLOWSTART) &&
            attacker.pbIsOpposing?(opponent.index)
            score-=90
          end
        end
      when 0x68
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif (opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)) ||
           opponent.effects[PBEffects::GastroAcid]
          score-=90
        elsif skill>=PBTrainerAI.highSkill
          score-=90 if isConst?(opponent.ability,PBAbilities,:MULTITYPE)
          score-=90 if isConst?(opponent.ability,PBAbilities,:SLOWSTART)
          score-=90 if isConst?(opponent.ability,PBAbilities,:TRUANT)
        end
      when 0x69
        score-=70
      when 0x6A
        if opponent.hp<=20
          score+=80
        elsif opponent.level>=25
          score-=80 # Not useful against high-level Pokemon
        end
      when 0x6B
        score+=80 if opponent.hp<=40
      when 0x6C
        score-=50
      when 0x6D
        score+=80 if opponent.hp<=attacker.level
      when 0x6E
        if attacker.hp>=opponent.hp
          score-=90
        elsif attacker.hp*2<opponent.hp
          score+=50
        end
      when 0x6F
        score+=30 if opponent.hp<=attacker.level
      when 0x70
        score-=90 if opponent.hasWorkingAbility(:STURDY)
        score-=90 if opponent.level>attacker.level
        score-=90 if isConst?(move.id,PBMoves,:SHEERCOLD) && opponent.pbHasType?(:ICE)
      when 0x71
        if opponent.effects[PBEffects::HyperBeam]>0
          score-=90
        else
          if opponent.lastMoveUsed>0
            moveData=PBMoveData.new(opponent.lastMoveUsed)
          else
            moveData=0
          end
          if (opponent.effects[PBEffects::TwoTurnAttack]!=0 && 
             PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).category==0) ||
             (opponent.effects[PBEffects::Outrage]>0 && 
             (moveData!=0 && moveData.category==0))
            score+=100 # Opponent is guaranteed to go for a physical move this turn
          else
            attack=pbRoughStat(opponent,PBStats::ATTACK,skill,oppunaware)
            spatk=pbRoughStat(opponent,PBStats::SPATK,skill,oppunaware)
            if attack<spatk # Opponent is more likely to use a Physical attack if Attack is higher
              score-=60
            else
              score+=20
            end
            if skill>=PBTrainerAI.highSkill
              for thismove in opponent.moves
                if thismove.pbIsPhysical?(thismove.type) # Higher chance of using a physical move
                  score+=10
                else
                  score-=10
                end
              end
            end
            if skill>=PBTrainerAI.mediumSkill && moveData!=0
              if moveData.category==0
                score+=20
              else
                score-=20
              end
            end
          end
        end
      when 0x72
        if opponent.effects[PBEffects::HyperBeam]>0
          score-=90
        else
          if opponent.lastMoveUsed>0
            moveData=PBMoveData.new(opponent.lastMoveUsed)
          else
            moveData=0
          end
          if (opponent.effects[PBEffects::TwoTurnAttack]!=0 && 
             PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).category==1) ||
             (opponent.effects[PBEffects::Outrage]>0 && 
             (moveData!=0 && moveData.category==1))
            score+=100 # Opponent is guaranteed to go for a physical move this turn
          else
            attack=pbRoughStat(opponent,PBStats::ATTACK,skill,oppunaware)
            spatk=pbRoughStat(opponent,PBStats::SPATK,skill,oppunaware)
            if attack>spatk # Opponent is more likely to use a Special attack if SpA is higher
              score-=60
            else
              score+=20
            end
            if skill>=PBTrainerAI.highSkill
              for thismove in opponent.moves
                if thismove.pbIsSpecial?(thismove.type) # Higher chance of using a special move
                  score+=10
                else
                  score-=10
                end
              end
            end
            if skill>=PBTrainerAI.mediumSkill && moveData!=0
              if moveData.category==1
                score+=20
              else
                score-=20
              end
            end
          end
        end
      when 0x73
        aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
        if opponent.effects[PBEffects::HyperBeam]>0
          score-=90 
        elsif aspeed>ospeed # Don't use at all if attacker is faster than opponent
          score-=90
        else
          if opponent.lastMoveUsed>0
            moveData=PBMoveData.new(opponent.lastMoveUsed)
          else
            moveData=0
          end
          if (opponent.effects[PBEffects::TwoTurnAttack]!=0 && 
             PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).category!=2) ||
             opponent.effects[PBEffects::Outrage]>0
            score+=100 # Opponent is guaranteed to go for a damaging move this turn
          else
            if skill>=PBTrainerAI.highSkill
              for thismove in opponent.moves
                if !thismove.pbIsStatus? # Higher chance of using a damaging move
                  score+=15
                else
                  score-=15
                end
              end
            end
            if skill>=PBTrainerAI.mediumSkill && moveData!=0
              if !moveData.category==2
                score+=20
              else
                score-=20
              end
            end
          end
        end
      when 0x74
        score+=10 if !opponent.pbPartner.fainted?
      when 0x75
      when 0x76
      when 0x77
      when 0x78
        aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
        if skill>=PBTrainerAI.mediumSkill && aspeed>ospeed
          score+=30 if !opponent.hasWorkingAbility(:INNERFOCUS) &&
                       (opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker))
        end
      when 0x79
        if @doublebattle
          if attacker.pbPartner.effects[PBEffects::TwoTurnAttack]!=0 ||
             attacker.pbPartner.effects[PBEffects::Outrage]>0 || 
             attacker.pbPartner.effects[PBEffects::HyperBeam]>0
            # Don't increase the score of this move if the partner is locked into a different move choice
          else
            score+=500 if attacker.pbPartner.pbHasMoveFunction?(0x7A) && !attacker.pbPartner.fainted?
          end
        end
      when 0x7A
        if @doublebattle
          if attacker.pbPartner.effects[PBEffects::TwoTurnAttack]!=0 ||
             attacker.pbPartner.effects[PBEffects::Outrage]>0 || 
             attacker.pbPartner.effects[PBEffects::HyperBeam]>0
            # Don't increase the score of this move if the partner is locked into a different move choice
          else
            score+=500 if attacker.pbPartner.pbHasMoveFunction?(0x79) && !attacker.pbPartner.fainted?
          end
        end
      when 0x7B
      when 0x7C
        score-=20 if opponent.status==PBStatuses::PARALYSIS # Will cure status
      when 0x7D
        score-=20 if opponent.status==PBStatuses::SLEEP && # Will cure status
                     opponent.statusCount>1
      when 0x7E
      when 0x7F
      when 0x80
      when 0x81
        attspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        oppspeed=pbRoughStat(opponent,PBStats::SPEED,skill)
        score+=30 if oppspeed>attspeed
      when 0x82
        score+=20 if @doublebattle
      when 0x83
        if skill>=PBTrainerAI.mediumSkill
          score+=20 if @doublebattle && !attacker.pbPartner.fainted? &&
                       attacker.pbPartner.pbHasMove?(move.id)
        end
      when 0x84
        attspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        oppspeed=pbRoughStat(opponent,PBStats::SPEED,skill)
        score+=30 if oppspeed>attspeed
      when 0x85
      when 0x86
      when 0x87
      when 0x88
        # TODO: Factor in opponent's current stats (more likely to switch with
        # decreased stats)
      when 0x89
      when 0x8A
      when 0x8B
      when 0x8C
      when 0x8D
      when 0x8E
      when 0x8F
      when 0x90
      when 0x91
      when 0x92
      when 0x93
        score+=25 if attacker.effects[PBEffects::Rage]
      when 0x94
        score-=20
      when 0x95
      when 0x96
        score-=90 if !pbIsBerry?(attacker.item)
      when 0x97
      when 0x98
      when 0x99
      when 0x9A
      when 0x9B
      when 0x9C
        if !@doublebattle
          score=0 
        elsif attacker.pbPartner.fainted?
          score-=90
        end
      when 0x9D
        if @field.effects[PBEffects::MudSportField]>0
          score-=90 
        elsif skill>=PBTrainerAI.mediumSkill
          score-=30 if !opponent.pbHasMoveType?(:ELECTRIC)
        end
      when 0x9E
        if @field.effects[PBEffects::WaterSportField]>0
          score-=90 
        elsif skill>=PBTrainerAI.mediumSkill
          score-=30 if !opponent.pbHasMoveType?(:FIRE)
        end
      when 0x9F
      when 0xA0
      when 0xA1
        if attacker.pbOwnSide.effects[PBEffects::LuckyChant]>0
          score-=90 
        else
          score-=20
        end
      when 0xA2
        score+=50 if @doublebattle
        score-=90 if attacker.pbOwnSide.effects[PBEffects::Reflect]>0
      when 0xA3
        score+=50 if @doublebattle
        score-=90 if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
      when 0xA4
      when 0xA5
        score+=(opponent.stages[PBStats::EVASION]*10)
        score-=(attacker.stages[PBStats::ACCURACY]*10)
      when 0xA6
        score-=90 if (opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker))
        score-=90 if opponent.effects[PBEffects::LockOn]>0
      when 0xA7
        if opponent.effects[PBEffects::Foresight]
          score-=90
        elsif opponent.pbHasType?(:GHOST)
          score+=70
        elsif opponent.stages[PBStats::EVASION]<=0
          score-=60
        end
      when 0xA8
        if opponent.effects[PBEffects::MiracleEye]
          score-=90
        elsif opponent.pbHasType?(:DARK)
          score+=70
        elsif opponent.stages[PBStats::EVASION]<=0
          score-=60
        end
      when 0xA9
      when 0xAA
        if attacker.effects[PBEffects::ProtectRate]>1 ||
           opponent.effects[PBEffects::HyperBeam]>0
          score-=90
        else
          if skill>=PBTrainerAI.mediumSkill
            score-=((attacker.effects[PBEffects::ProtectRate]-1)*40)
            if attacker.hasWorkingAbility(:SPEEDBOOST) && 
               skill>=PBTrainerAI.highSkill &&
               attacker.effects[PBEffects::ProtectRate]<=1
              attspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
              oppspeed=pbRoughStat(opponent,PBStats::SPEED,skill)
              score+=200 if oppspeed>attspeed
            end
          end
          #score+=50 if attacker.turncount==0
          score+=50 if attacker.effects[PBEffects::Wish]>0 && 
                       attacker.hp!=attacker.totalhp
          score+=30 if opponent.effects[PBEffects::TwoTurnAttack]!=0 &&
                    !(isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
                    isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE))
        end
      when 0xAB
        if opponent.effects[PBEffects::HyperBeam]>0
          score-=90
        elsif skill>=PBTrainerAI.bestSkill && @doublebattle
          for i in 0...4
            battler=@battlers[i]
            if attacker.pbIsOpposing?(i) && !battler.fainted?
              for thismove in battler.moves
                if thismove.priority>0 && thismove.function!=0xAA &&
                  thismove.function!=0xAB && thismove.function!=0xAC &&
                  thismove.function!=0xAD && thismove.function!=0xB1 &&
                  thismove.function!=0xB2 && thismove.function!=0xE8 &&
                  thismove.function!=0x117 && thismove.function!=0x120 && 
                  thismove.function!=162 && thismove.function!=0x14A &&
                  thismove.function!=0x14B && thismove.function!=0x14C &&
                  thismove.function!=0x211 &&
                  (thismove.function!=0x12 && battler.turncount!=0)
                  score+=40
                end
              end
            end
          end
        end
      when 0xAC
        if opponent.effects[PBEffects::HyperBeam]>0
          score-=90
        elsif skill>=PBTrainerAI.bestSkill && @doublebattle
          for i in 0...4
            battler=@battlers[i]
            if attacker.pbIsOpposing?(i) && !battler.fainted?
              for thismove in battler.moves
                if (thismove.target==PBTargets::AllOpposing || thismove.target==PBTargets::AllNonUsers) &&
                   !thismove.pbIsStatus?
                  score+=40
                end
              end
            end
          end
        end
      when 0xAD
        if opponent.effects[PBEffects::HyperBeam]>0
          score-=60 # Other moves are likely better suited to be used during recharge turns
        elsif skill>=PBTrainerAI.bestSkill
          for i in 0...4
            battler=@battlers[i]
            if attacker.pbIsOpposing?(i) && !battler.fainted?
              for thismove in battler.moves
                if thismove.function==0xAA || thismove.function==0xAB || 
                   thismove.function==0xAC || thismove.function==0x14A ||
                   thismove.function==0x14B || thismove.function==0x14C ||
                   (thismove.function==0x176 && battler.turncount==0)
            Kernel.pbMessage("5")
                  score+=20
                else
                  score-=20
                end
              end
            end
          end
        end
      when 0xAE
        score-=40
        if skill>=PBTrainerAI.highSkill
          score-=100 if opponent.lastMoveUsed<=0 ||
                       (PBMoveData.new(opponent.lastMoveUsed).flags&0x10)==0 # flag e: Copyable by Mirror Move
        end
      when 0xAF
      when 0xB0
        aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
        if aspeed<ospeed
          score-=90 # Need to be faster to use Me First
        end
      when 0xB1
      when 0xB2
      when 0xB3
      when 0xB4
        if attacker.status==PBStatuses::SLEEP
          if skill>=PBTrainerAI.highSkill && attacker.statusCount<=1
            score-=90
          else
            score+=200 # Because it can be used while asleep
          end
        else
          if skill>=PBTrainerAI.highSkill && attacker.statusCount<=1
            score=0
          else
            score-=90
          end
        end
      when 0xB5
      when 0xB6
      when 0xB7
        score-=90 if opponent.effects[PBEffects::Torment]
      when 0xB8
        score-=90 if attacker.effects[PBEffects::Imprison]
      when 0xB9
        score-=90 if opponent.effects[PBEffects::Disable]>0 || opponent.lastMoveUsed<=0
      when 0xBA
        if skill>=PBTrainerAI.highSkill && opponent.effects[PBEffects::Taunt]>0
          score=0
        elsif opponent.effects[PBEffects::Taunt]>0
          score-=90 
        elsif skill>=PBTrainerAI.highSkill
          for thismove in opponent.moves
            if thismove.pbIsStatus?
              score+=20
            end
          end
        end
      when 0xBB
        if opponent.effects[PBEffects::HealBlock]>0
          score-=90 
        elsif skill>=PBTrainerAI.highSkill
          for thismove in opponent.moves
            if !thismove.isHealingMove?
              score-=20
            end
          end
        end
      when 0xBC
        aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
        if opponent.effects[PBEffects::Encore]>0
          score-=90
        elsif aspeed>ospeed
          if opponent.lastMoveUsed<=0
            score-=90
          else
            moveData=PBMoveData.new(opponent.lastMoveUsed)
            typemod=pbTypeModMove(moveData,attacker,opponent)
            if moveData.basedamage==0 && (moveData.target==0x10 || moveData.target==0x20)
              score+=60
            elsif moveData.basedamage!=0 && moveData.target==0x00 && typemod==0
              score+=60
            end
          end
        end
      when 0xBD
      when 0xBE
        if opponent.pbCanPoison?(attacker,false,move)
          score+=30
          if skill>=PBTrainerAI.mediumSkill
            score+=30 if opponent.hp<=opponent.totalhp/4
            score+=50 if opponent.hp<=opponent.totalhp/8
            score-=40 if opponent.effects[PBEffects::Yawn]>0
          end
          if skill>=PBTrainerAI.highSkill
            score+=10 if pbRoughStat(opponent,PBStats::DEFENSE,skill,oppunaware)>100
            score+=10 if pbRoughStat(opponent,PBStats::SPDEF,skill,oppunaware)>100
            score-=40 if opponent.hasWorkingAbility(:GUTS)
            score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
            score-=40 if opponent.hasWorkingAbility(:TOXICBOOST)
          end
        end
      when 0xBF
      when 0xC0
      when 0xC1
      when 0xC2
        if attacker.hasWorkingAbility(:TRUANT)
          score+=10
        else
          score-=10
        end
      when 0xC3
        score-=30
      when 0xC4
      when 0x138
      when 0xC5
        typemod=pbTypeModMove(move,attacker,opponent)
        if opponent.pbCanParalyze?(attacker,false,move) && 
           !(skill>=PBTrainerAI.mediumSkill && isConst?(move.id,PBMoves,:THUNDERWAVE) &&
           typemod==0)
          score+=30
          if skill>=PBTrainerAI.mediumSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed
              score+=30
            elsif aspeed>ospeed
              score-=40
            end
          end
          if skill>=PBTrainerAI.highSkill
            score-=40 if opponent.hasWorkingAbility(:GUTS)
            score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
            score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
          end
        end
      when 0xC6
        if opponent.pbCanBurn?(attacker,false,move)
          score+=30 
          if skill>=PBTrainerAI.highSkill
            score-=40 if opponent.hasWorkingAbility(:GUTS)
            score-=40 if opponent.hasWorkingAbility(:MARVELSCALE)
            score-=40 if opponent.hasWorkingAbility(:QUICKFEET)
            score-=40 if opponent.hasWorkingAbility(:FLAREBOOST)
          end
        end
      when 0xC7
        score+=20 if attacker.effects[PBEffects::FocusEnergy]>0
        score+=20 if !opponent.hasWorkingAbility(:INNERFOCUS) &&
                     (opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker))
      when 0xC8
        if attacker.stages[PBStats::DEFENSE]<0
          score+=20 
        elsif skill>=PBTrainerAI.mediumSkill
          score-=30
        end
      when 0xC9
        if @field.effects[PBEffects::Gravity]>0
          score-=90
        elsif skill>=PBTrainerAI.mediumSkill
          score-=30
        end
      when 0xCA
        if skill>=PBTrainerAI.mediumSkill
          score-=30
        end
      when 0xCB
        if skill>=PBTrainerAI.mediumSkill
          score-=30
        end
      when 0xCC
        if @field.effects[PBEffects::Gravity]>0
          score-=90
        else
          score+=15 if pbRoughStat(attacker,
             PBStats::SPEED,skill)<pbRoughStat(opponent,PBStats::SPEED,skill)
          score-=30 if !opponent.pbCanParalyze?(attacker,false,move)
        end
      when 0xCD
        score+=20 if pbWeather==PBWeather::NEWMOON
      when 0xCE
        if skill>=PBTrainerAI.mediumSkill
          if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
            score-=90
          elsif isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY)
            score-=90
          elsif opponent.effects[PBEffects::SkyDrop] && opponent.effects[PBEffects::SkyDropPartnerPos]!=attacker.index
            score-=90
          elsif !opponent.pbIsOpposing?(attacker.index)
            score-=90
          elsif opponent.weight(attacker)>=2000
            score-=90
          elsif @field.effects[PBEffects::Gravity]>0
            score-=90
          elsif opponent.pbHasType?(:FLYING)
            score-=90
          end
        elsif skill>=PBTrainerAI.highSkill
          if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
            score=0
          elsif isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY)
            score=0
          elsif opponent.effects[PBEffects::SkyDrop] && opponent.effects[PBEffects::SkyDropPartnerPos]!=attacker.index
            score=0
          elsif !opponent.pbIsOpposing?(attacker.index)
            score=0
          elsif opponent.weight(attacker)>=2000
            score=0
          elsif @field.effects[PBEffects::Gravity]>0
            score=0
          elsif opponent.pbHasType?(:FLYING)
            score=0
          end
        end
      when 0xCF
        if opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)
          score-=90
        else
          score+=40 if opponent.effects[PBEffects::MultiTurn]==0
          score+=40 if attacker.pbHasMoveFunction?(0xE5)
        end
      when 0xD0
        if opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)
          score-=90
        else
          score+=40 if opponent.effects[PBEffects::MultiTurn]==0
          score+=40 if attacker.pbHasMoveFunction?(0xE5)
        end
      when 0xD1
      when 0xD2
        #score-=20 if !opponent.pbCanConfuse?(attacker,false)
      when 0xD3
      when 0xD4
        if attacker.hp<=attacker.totalhp/4
          score-=90 
        elsif attacker.hp<=attacker.totalhp/2
          score-=50 
        end
      when 0xD5
        if attacker.hp==attacker.totalhp
          score-=90
        else
          score+=50
          score-=(attacker.hp*100/attacker.totalhp)
        end
      when 0xD6
        if attacker.hp==attacker.totalhp
          score-=90
        else
          score+=50
          score-=(attacker.hp*100/attacker.totalhp)
        end
      when 0xD7
        score-=90 if attacker.effects[PBEffects::Wish]>0
      when 0xD8
        if attacker.hp==attacker.totalhp
          if skill>=PBTrainerAI.highSkill
            score=0
          else
            score-=90
          end
        else
          case pbWeather
          when PBWeather::NEWMOON
            if isConst?(move.id,PBMoves,:MOONLIGHT)
              score+=30
            else
              score-=30
            end
          when PBWeather::SUNNYDAY, pbWeather==PBWeather::HARSHSUN
            if isConst?(move.id,PBMoves,:MOONLIGHT)
              score-=30
            else
              score+=30
            end
          when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN, PBWeather::HAIL, PBWeather::SANDSTORM
            score-=30
          end
          score+=50
          score-=(attacker.hp*100/attacker.totalhp)
        end
      when 0xD9
        if attacker.hp==attacker.totalhp || !attacker.pbCanSleep?(attacker,false,nil,true)
          score-=90
        else
          score+=70
          score-=(attacker.hp*140/attacker.totalhp)
          if score<=100
            if attacker.hasWorkingItem(:LUMBERRY) || 
               attacker.hasWorkingItem(:CHESTOBERRY) ||
               attacker.hasWorkingAbility(:SHEDSKIN) ||
               attacker.hasWorkingAbility(:EARLYBIRD) ||
               (@doublebattle && attacker.pbPartner.hasWorkingAbility(:HEALER))
              score+=30
            elsif attacker.hasWorkingAbility(:HYDRATION) && 
                 (pbWeather==PBWeather::RAINDANCE || pbWeather==PBWeather::HEAVYRAIN)
              score+=50
           end
          end
          score+=30 if attacker.status!=0
        end
      when 0xDA
        score-=90 if attacker.effects[PBEffects::AquaRing]
      when 0xDB
        score-=90 if attacker.effects[PBEffects::Ingrain]
      when 0xDC
        if skill>=PBTrainerAI.mediumSkill && opponent.effects[PBEffects::Substitute]>0 && 
           !move.ignoresSubstitute?(attacker)
          score-=90
        elsif opponent.effects[PBEffects::LeechSeed]>=0
          if skill>=PBTrainerAI.highSkill
            score=0
          else
            score-=90
          end
        elsif skill>=PBTrainerAI.minimumSkill && opponent.pbHasType?(:GRASS)
          if skill>=PBTrainerAI.highSkill
            score=0
          else
            score-=90
          end
        elsif skill>=PBTrainerAI.mediumSkill && opponent.hasWorkingAbility(:LIQUIDOOZE)
          if skill>=PBTrainerAI.highSkill
            score=0
          else
            score-=90
          end
        else
        score+=60 if attacker.turncount==0
      end
      when 0xDD
        if skill>=PBTrainerAI.mediumSkill && opponent.hasWorkingAbility(:LIQUIDOOZE)
          score-=20
        else
          score+=20 if attacker.hp<=(attacker.totalhp/2)
        end
      when 0xDE
        if opponent.status!=PBStatuses::SLEEP
          score-=100
        elsif skill>=PBTrainerAI.mediumSkill && opponent.hasWorkingAbility(:LIQUIDOOZE)
          score-=70
        else
          score+=20 if attacker.hp<=(attacker.totalhp/2)
        end
      when 0xDF
        if attacker.pbIsOpposing?(opponent.index)
          score-=100
        else
          score+=20 if opponent.hp<(opponent.totalhp/2) &&
                       (opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker))
        end
      when 0xE0
        reserves=attacker.pbNonActivePokemonCount
        foes=attacker.pbOppositeOpposing.pbNonActivePokemonCount
        if pbCheckGlobalAbility(:DAMP)
          score-=100
        elsif skill>=PBTrainerAI.mediumSkill && reserves==0 && foes>=0
          score-=100 # don't want to lose or draw
        else
          score-=(attacker.hp*100/attacker.totalhp)
        end
      when 0xE1
        typemod=pbTypeModMove(move,attacker,opponent)
        if attacker.hp>=opponent.totalhp && typemod!=0
          score+=90
        else
          score-=90
        end
      when 0xE2
        if opponent.hasWorkingAbility(:CONTRARY)
          score=0
        elsif !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker) &&
              !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker)
          score-=100
        elsif attacker.pbNonActivePokemonCount()==0
          score-=100 
        else
          score+=(opponent.stages[PBStats::ATTACK]*10)
          score+=(opponent.stages[PBStats::SPATK]*10)
          score-=(attacker.hp*100/attacker.totalhp)
        end
      when 0xE3
        score-=70
      when 0xE4
        score-=70
      when 0xE5
        if opponent.effects[PBEffects::PerishSong]>0
          score-=90
        elsif opponent.hasWorkingAbility(:SOUNDPROOF)
          score-=90
        elsif skill>=PBTrainerAI.mediumSkill && !opponent.canEscape?(attacker,opponent)
          score+=90
        elsif attacker.pbNonActivePokemonCount()==0
          score-=90
        end
      when 0xE6
        score+=50
        score-=(attacker.hp*100/attacker.totalhp)
        score+=30 if attacker.hp<=(attacker.totalhp/10)
      when 0xE7
        score+=50
        score-=(attacker.hp*100/attacker.totalhp)
        score+=30 if attacker.hp<=(attacker.totalhp/10)
      when 0xE8
        score-=25 if attacker.hp>(attacker.totalhp/2)
        if skill>=PBTrainerAI.mediumSkill
          score-=90 if attacker.effects[PBEffects::ProtectRate]>1
          score-=90 if opponent.effects[PBEffects::HyperBeam]>0
        else
          score-=((attacker.effects[PBEffects::ProtectRate]-1)*40)
        end
      when 0xE9
        if opponent.hp==1
          score-=90
        elsif opponent.hp<=(opponent.totalhp/8)
          score-=60
        elsif opponent.hp<=(opponent.totalhp/4)
          score-=30
        end
      when 0xEA
        score-=100 if @opponent
      when 0xEB
        if opponent.effects[PBEffects::Ingrain] ||
         (skill>=PBTrainerAI.highSkill && opponent.hasWorkingAbility(:SUCTIONCUPS))
          score-=90 
        else
          party=pbParty(opponent.index)
          ch=0
          for i in 0...party.length
            ch+=1 if pbCanSwitchLax?(opponent.index,i,false)
          end
          score-=90 if ch==0
        end
        if score>20
          score+=50 if opponent.pbOwnSide.effects[PBEffects::Spikes]>0
          score+=50 if opponent.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
          score+=50 if opponent.pbOwnSide.effects[PBEffects::Livewire]>0
          score+=50 if opponent.pbOwnSide.effects[PBEffects::Permafrost]>0
          score+=50 if opponent.pbOwnSide.effects[PBEffects::StealthRock]
          score+=50 if opponent.pbOwnSide.effects[PBEffects::StickyWeb]
          score+=50 if opponent.pbOwnSide.effects[PBEffects::FireRock]
        end
      when 0xEC
        if !opponent.effects[PBEffects::Ingrain] &&
           !(skill>=PBTrainerAI.highSkill && opponent.hasWorkingAbility(:SUCTIONCUPS))
          score+=40 if opponent.pbOwnSide.effects[PBEffects::Spikes]>0
          score+=40 if opponent.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
          score+=40 if opponent.pbOwnSide.effects[PBEffects::Livewire]>0
          score+=40 if opponent.pbOwnSide.effects[PBEffects::Permafrost]>0
          score+=40 if opponent.pbOwnSide.effects[PBEffects::StealthRock]
          score+=40 if opponent.pbOwnSide.effects[PBEffects::StickyWeb]
          score+=40 if opponent.pbOwnSide.effects[PBEffects::FireRock]
        end
      when 0xED
        if !pbCanChooseNonActive?(attacker.index)
          score-=80
        else
          score-=40 if attacker.effects[PBEffects::Confusion]>0
          total=0
          total+=(attacker.stages[PBStats::ATTACK]*10)
          total+=(attacker.stages[PBStats::DEFENSE]*10)
          total+=(attacker.stages[PBStats::SPEED]*10)
          total+=(attacker.stages[PBStats::SPATK]*10)
          total+=(attacker.stages[PBStats::SPDEF]*10)
          total+=(attacker.stages[PBStats::EVASION]*10)
          total+=(attacker.stages[PBStats::ACCURACY]*10)
          total+=20 if !move.ignoresSubstitute?(opponent) && attacker.effects[PBEffects::Substitute]>0
          if total<=0 || attacker.turncount==0
            score-=60
          else
            score+=total
            # special case: attacker has no damaging moves
            hasDamagingMove=false
            for m in attacker.moves
              if move.id!=0 && move.basedamage>0
                hasDamagingMove=true
              end
            end
            if !hasDamagingMove
              score+=75
            end
          end
        end
      when 0xEE
        total=0
        total+=(attacker.stages[PBStats::ATTACK]*10)
        total+=(attacker.stages[PBStats::DEFENSE]*10)
        total+=(attacker.stages[PBStats::SPEED]*10)
        total+=(attacker.stages[PBStats::SPATK]*10)
        total+=(attacker.stages[PBStats::SPDEF]*10)
        total+=(attacker.stages[PBStats::EVASION]*10)
        total+=(attacker.stages[PBStats::ACCURACY]*10)
        total+=20 if !move.ignoresSubstitute?(opponent) && attacker.effects[PBEffects::Substitute]>0
        score+=total
        if total>0
          score-=60
        end
      when 0xEF
        if opponent.effects[PBEffects::MeanLook]>=0
          score-=90
        else
          score+=40 if attacker.pbHasMoveFunction?(0xE5)
        end
      when 0xF0
        if skill>=PBTrainerAI.highSkill
          score+=20 if !pbIsUnlosableItem(opponent,opponent.item) && opponent.item!=0
        end
      when 0xF1
        if skill>=PBTrainerAI.highSkill
          if attacker.item==0 && opponent.item!=0 && !pbIsUnlosableItem(opponent,opponent.item) &&
             opponent.hasWorkingAbility(:STICKYHOLD)
            score+=40
          else
            score-=90
          end
        else
          score-=80
        end
      when 0xF2
        if pbIsUnlosableItem(attacker,attacker.item) || (attacker.item==0 && opponent.item==0)
          score-=90
        elsif skill>=PBTrainerAI.highSkill && (opponent.hasWorkingAbility(:STICKYHOLD) || pbIsUnlosableItem(opponent,opponent.item))
          score-=90
        elsif attacker.hasWorkingItem(:FLAMEORB) ||
              attacker.hasWorkingItem(:TOXICORB) ||
              attacker.hasWorkingItem(:STICKYBARB) ||
              attacker.hasWorkingItem(:IRONBALL) ||
              attacker.hasWorkingItem(:CHOICEBAND) ||
              attacker.hasWorkingItem(:CHOICESCARF) ||
              attacker.hasWorkingItem(:CHOICESPECS)
          score+=50
        elsif attacker.item==0 && opponent.item!=0
          score-=30 if PBMoveData.new(attacker.lastMoveUsed).function==0xF2 # Trick/Switcheroo
        end
      when 0xF3
        if pbIsUnlosableItem(attacker,attacker.item) || attacker.item==0 || opponent.item!=0
          score-=90
        else
          if attacker.hasWorkingItem(:FLAMEORB) ||
             attacker.hasWorkingItem(:TOXICORB) ||
             attacker.hasWorkingItem(:STICKYBARB) ||
             attacker.hasWorkingItem(:IRONBALL) ||
             attacker.hasWorkingItem(:CHOICEBAND) ||
             attacker.hasWorkingItem(:CHOICESCARF) ||
             attacker.hasWorkingItem(:CHOICESPECS)
            score+=50
          else
            score-=80
          end
        end
      when 0xF4
        if opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker)
          if skill>=PBTrainerAI.highSkill && pbIsBerry?(opponent.item)
            score+=30
          end
        end
      when 0xF5
        if opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker)
          if skill>=PBTrainerAI.highSkill && pbIsBerry?(opponent.item)
            score+=30
          end
        end
      when 0xF6
        if attacker.pokemon.itemRecycle==0 || attacker.item!=0
          score-=80
        elsif attacker.pokemon.itemRecycle!=0
          score+=30
        end
      when 0xF7
        if attacker.item==0 ||
           pbIsUnlosableItem(attacker,attacker.item) ||
           pbIsPokeBall?(attacker.item) ||
           attacker.hasWorkingAbility(:KLUTZ) ||
           attacker.effects[PBEffects::Embargo]>0 ||
           @field.effects[PBEffects::MagicRoom]>0 ||
           (pbIsBerry?(attacker.item) && opponent.hasWorkingAbility(:UNNERVE))
          score=0
        elsif attacker.hasWorkingItem(:FLAMEORB) ||
              attacker.hasWorkingItem(:TOXICORB) ||
              attacker.hasWorkingItem(:STICKYBARB) ||
              attacker.hasWorkingItem(:IRONBALL) ||
              attacker.hasWorkingItem(:KINGSROCK) ||
              attacker.hasWorkingItem(:LIGHTBALL) ||
              attacker.hasWorkingItem(:POISONBARB) ||
              attacker.hasWorkingItem(:RAZORFANG)
          score+=50
        end
      when 0xF8
        if opponent.effects[PBEffects::Embargo]>0
          score-=90 
        else
          score+=40
        end
      when 0xF9
        if @field.effects[PBEffects::MagicRoom]>0
          score-=90
        else
          score+=30 if attacker.item==0 && opponent.item!=0
        end
      when 0xFA
        if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:RECKLESS)
          score-=5
        end
      when 0xFB
        if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:RECKLESS)
          score-=10
        end
      when 0xFC
        if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:RECKLESS)
          score-=15
        end
      when 0xFD
        if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:RECKLESS)
          score-=25
        end
        if opponent.pbCanParalyze?(attacker,false,move)
          score+=10
          if skill>=PBTrainerAI.mediumSkill
             aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
             ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed
              score+=10
            elsif aspeed>ospeed
              score-=10
            end
          end
        end
      when 0xFE
        if !attacker.hasWorkingAbility(:ROCKHEAD) && !attacker.hasWorkingAbility(:RECKLESS)
          score-=5
        end
        if opponent.pbCanBurn?(attacker,false,move)
          score+=5
        end
      when 0xFF
        if pbCheckGlobalAbility(:AIRLOCK) ||
           pbCheckGlobalAbility(:CLOUDNINE) ||
           pbWeather==PBWeather::HARSHSUN ||
           pbWeather==PBWeather::HEAVYRAIN ||
           pbWeather==PBWeather::STRONGWINDS
          score-=90
        elsif pbWeather==PBWeather::SUNNYDAY
          score-=90
        elsif pbWeather!=0 && pbWeather!=PBWeather::SUNNYDAY && !attacker.hasWorkingAbility(:FORECAST)
          score+=40
        else
          for move in attacker.moves
            if move.id!=0 && move.basedamage>0 &&
               isConst?(move.type,PBTypes,:FIRE)
              score+=20
            end
          end
        end
      when 0x100
        if pbCheckGlobalAbility(:AIRLOCK) ||
           pbCheckGlobalAbility(:CLOUDNINE) ||
           pbWeather==PBWeather::HARSHSUN ||
           pbWeather==PBWeather::HEAVYRAIN ||
           pbWeather==PBWeather::STRONGWINDS
          score-=90
        elsif pbWeather==PBWeather::RAINDANCE
          score-=90
        elsif pbWeather!=0 && pbWeather!=PBWeather::RAINDANCE && !attacker.hasWorkingAbility(:FORECAST)
          score+=40
        else
          for move in attacker.moves
            if move.id!=0 && move.basedamage>0 &&
               isConst?(move.type,PBTypes,:WATER)
              score+=20
            end
          end
        end
      when 0x101
        if pbCheckGlobalAbility(:AIRLOCK) ||
           pbCheckGlobalAbility(:CLOUDNINE) ||
           pbWeather==PBWeather::HARSHSUN ||
           pbWeather==PBWeather::HEAVYRAIN ||
           pbWeather==PBWeather::STRONGWINDS
          score-=90
        elsif pbWeather==PBWeather::SANDSTORM
          score-=90
        elsif pbWeather!=0 && pbWeather!=PBWeather::SANDSTORM && !attacker.hasWorkingAbility(:FORECAST)
          score+=40
        end
      when 0x102
        if pbCheckGlobalAbility(:AIRLOCK) ||
           pbCheckGlobalAbility(:CLOUDNINE) ||
           pbWeather==PBWeather::HARSHSUN ||
           pbWeather==PBWeather::HEAVYRAIN ||
           pbWeather==PBWeather::STRONGWINDS
          score-=90
        elsif pbWeather==PBWeather::HAIL
          score-=90
        elsif pbWeather!=0 && pbWeather!=PBWeather::HAIL && !attacker.hasWorkingAbility(:FORECAST)
          score+=40
      end
      when 0x103
        if opponent.hasWorkingAbility(:MAGICBOUNCE)
          score=0
        else
          if skill>=PBTrainerAI.highSkill && opponent.pbHasMoveFunction?(0xB1)
            score-=30
          end
          if attacker.pbOpposingSide.effects[PBEffects::Spikes]>=3
            score-=90
          elsif !pbCanChooseNonActive?(attacker.pbOpposing1.index) &&
               !pbCanChooseNonActive?(attacker.pbOpposing2.index)
            # No active Pokemon remains on opposing side
            score-=90
          else
            score+=[40,26,13][attacker.pbOpposingSide.effects[PBEffects::Spikes]]
            score+=5*attacker.pbOppositeOpposing.pbNonActivePokemonCount()
          end
        end
      when 0x104
        if opponent.hasWorkingAbility(:MAGICBOUNCE)
          score=0
        else
          if skill>=PBTrainerAI.highSkill && opponent.pbHasMoveFunction?(0xB1)
            score-=30
          end
          if attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
            score-=90
          elsif !pbCanChooseNonActive?(attacker.pbOpposing1.index) &&
                !pbCanChooseNonActive?(attacker.pbOpposing2.index)
            # Opponent can't switch in any Pokemon
            score-=90
          else
            score+=4*attacker.pbOppositeOpposing.pbNonActivePokemonCount()
            score+=[26,13][attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
          end
        end
      when 0x105
        if opponent.hasWorkingAbility(:MAGICBOUNCE)
          score=0
        else
          if skill>=PBTrainerAI.highSkill && opponent.pbHasMoveFunction?(0xB1)
            score-=30
          end
          if attacker.hasWorkingAbility(:FOUNDRY)
            if attacker.pbOpposingSide.effects[PBEffects::FireRock]
              score-=90
            elsif !pbCanChooseNonActive?(attacker.pbOpposing1.index) &&
                  !pbCanChooseNonActive?(attacker.pbOpposing2.index)
              # Opponent can't switch in any Pokemon
              score-=90
            else
              score+=15*attacker.pbOppositeOpposing.pbNonActivePokemonCount()
            end
          else
            if attacker.pbOpposingSide.effects[PBEffects::StealthRock]
              score-=90
            elsif !pbCanChooseNonActive?(attacker.pbOpposing1.index) &&
                  !pbCanChooseNonActive?(attacker.pbOpposing2.index)
              # Opponent can't switch in any Pokemon
              score-=90
            else
              score+=15*attacker.pbOppositeOpposing.pbNonActivePokemonCount()
            end
          end
        end
      when 0x106
        if @doublebattle
          score+=50 if attacker.pbPartner.pbHasMoveFunction?(0x107) ||
                       attacker.pbPartner.pbHasMoveFunction?(0x108)
        end
      when 0x107
        if @doublebattle
          score+=50 if attacker.pbPartner.pbHasMoveFunction?(0x106) ||
                       attacker.pbPartner.pbHasMoveFunction?(0x108)
        end
      when 0x108
        if @doublebattle
          score+=50 if attacker.pbPartner.pbHasMoveFunction?(0x106) ||
                       attacker.pbPartner.pbHasMoveFunction?(0x107)
        end
      when 0x109
      when 0x10A
        score+=20 if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
        score+=20 if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
      when 0x10B
        if @field.effects[PBEffects::Gravity]>0
          score-=90
        elsif opponent.pbHasMoveFunction?(0xAA)
          score-=50
        elsif opponent.effects[PBEffects::LockOn]>0 &&
              opponent.effects[PBEffects::LockOnPos]==attacker.index
          score+=40
        else
          score+=10*(attacker.stages[PBStats::ACCURACY]-opponent.stages[PBStats::EVASION])
        end
        score+=10 if score>=0 && attacker.hasWorkingAbility(:RECKLESS)
      when 0x10C
        if attacker.effects[PBEffects::Substitute]>0
          score-=90
        elsif attacker.hp<=(attacker.totalhp/4)
          score-=90
        end
      when 0x10D
        if attacker.pbHasType?(:GHOST)
          if opponent.effects[PBEffects::Curse]
            score-=90
          elsif attacker.hp<=(attacker.totalhp/2)
            if attacker.pbNonActivePokemonCount()==0
              score-=90
            else
              score-=50
              score-=30 if @shiftStyle
            end
          end
        else
          avg=(attacker.stages[PBStats::SPEED]*10)
          avg-=(attacker.stages[PBStats::ATTACK]*10)
          avg-=(attacker.stages[PBStats::DEFENSE]*10)
          avg*=-1 if attacker.hasWorkingAbility(:CONTRARY)
          score+=avg/3
        end
      when 0x10E
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif opponent.lastMoveUsed>0
          for i in opponent.moves
            if i.id==opponent.lastMoveUsed && i.id>0 && i.pp>0 && i.pp<=4
              score+=30; break
            end
          end
        else
          score-=90
        end
      when 0x10F
        if opponent.effects[PBEffects::Nightmare] ||
           (opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker))
          score-=90
        elsif opponent.status!=PBStatuses::SLEEP
          score-=90
        else
          if opponent.statusCount<=1
            score-=90
          else
            score+=50 if opponent.statusCount>3
            score+=20 if pbWeather==PBWeather::NEWMOON
          end
        end
      when 0x110
        score+=30 if attacker.effects[PBEffects::MultiTurn]>0
        score+=30 if attacker.effects[PBEffects::LeechSeed]>=0
        if attacker.pbNonActivePokemonCount()>0
          score+=80 if attacker.pbOwnSide.effects[PBEffects::Spikes]>0
          score+=80 if attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
          score+=80 if attacker.pbOwnSide.effects[PBEffects::Livewire]>0
          score+=80 if attacker.pbOwnSide.effects[PBEffects::Permafrost]>0
          score+=80 if attacker.pbOwnSide.effects[PBEffects::StealthRock]
          score+=80 if attacker.pbOwnSide.effects[PBEffects::FireRock]
          score+=80 if attacker.pbOwnSide.effects[PBEffects::StickyWeb]
        end
        if score<=100
          score-=80 # Don't prioritize Rapid Spin if no hazards on the field
        end
      when 0x111
        if opponent.effects[PBEffects::FutureSight]>0
          score-=100
        #elsif attacker.pbNonActivePokemonCount()==0
          # Future Sight tends to be wasteful if down to last Pokemon
        #  score-=70
        else
          score+=30 if attacker.hasWorkingAbility(:PERIODICORBIT)
        end
      when 0x112
        avg=0
        avg-=(attacker.stages[PBStats::DEFENSE]*10)
        avg-=(attacker.stages[PBStats::SPDEF]*10)
        avg*=-1 if attacker.hasWorkingAbility(:CONTRARY)
        score+=avg/2
        if attacker.effects[PBEffects::Stockpile]>=3
          score-=80
        else
          # More preferable if user also has Spit Up/Swallow
          for move in attacker.moves
            if move.function==0x113 || move.function==0x114 # Spit Up, Swallow
              score+=20; break
            end
          end
        end
      when 0x113
        score-=100 if attacker.effects[PBEffects::Stockpile]==0
      when 0x114
        if attacker.effects[PBEffects::Stockpile]==0
          score-=90
        elsif attacker.hp==attacker.totalhp
          score-=90
        else
          mult=[0,25,50,100][attacker.effects[PBEffects::Stockpile]]
          score+=mult
          score-=(attacker.hp*mult*2/attacker.totalhp)
        end
      when 0x115
        score+=50 if opponent.effects[PBEffects::HyperBeam]>0
        # Modified this to be opposite to Essential's logic. Basically...
        # 1 - If the player is at full HP they either feel more inclined to attack
        # or to use stat boosting moves. Other moves than Focus Punch may be more 
        # useful in this situation and the AI has been observed to spam Focus Punch 
        # otherwise.
        # 2 - As the player's HP starts to get low (especially on Nuzlockes) and
        # they have not seen Focus Punch come out from this Pokemon, they are more
        # likely to either heal or switch to another Pokemon, making Focus Punch an
        # ideal punishment for them.
        score-=35 if opponent.hp>(opponent.totalhp/2)
        score+=35 if opponent.hp<=(opponent.totalhp/2)
        score+=70 if opponent.hp<=(opponent.totalhp/4)
      when 0x116
        if skill>=PBTrainerAI.highSkill
          # Probability of using Sucker Punch increases with the ratio of status 
          # to damaging moves
          # TODO: Factor in opponent's stat increases (more likely to attack with
          # higher stats)
          for thismove in opponent.moves
            if thismove.pbIsStatus?
              score-=20
            else
              score+=20
            end
          end
        end
      when 0x117
        if !@doublebattle
          score-=100
        elsif attacker.pbPartner.fainted?
          score-=90
        end
      when 0x118
        if @field.effects[PBEffects::Gravity]>0
          score-=90
        elsif skill>=PBTrainerAI.mediumSkill
          score-=30
          score-=20 if attacker.effects[PBEffects::SkyDrop]
          score-=20 if attacker.effects[PBEffects::MagnetRise]>0
          score-=20 if attacker.effects[PBEffects::Telekinesis]>0
          score-=20 if attacker.pbHasType?(:FLYING)
          score-=20 if attacker.hasWorkingAbility(:LEVITATE)
          score-=20 if attacker.hasWorkingItem(:AIRBALLOON)
          score+=20 if opponent.effects[PBEffects::SkyDrop]
          score+=20 if opponent.effects[PBEffects::MagnetRise]>0
          score+=20 if opponent.effects[PBEffects::Telekinesis]>0
          score+=20 if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
                       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC || # Bounce
                       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCE    # Sky Drop
          score+=20 if opponent.pbHasType?(:FLYING)
          score+=20 if opponent.hasWorkingAbility(:LEVITATE)
          score+=20 if opponent.hasWorkingItem(:AIRBALLOON)
        end
      when 0x119
        if @field.effects[PBEffects::Gravity]>0
          score-=90
        elsif attacker.effects[PBEffects::MagnetRise]>0 ||
           attacker.effects[PBEffects::Ingrain] ||
           attacker.effects[PBEffects::SmackDown]
          score-=90
        end
      when 0x11A
        if @field.effects[PBEffects::Gravity]>0
          score-=90
        elsif opponent.effects[PBEffects::Telekinesis]>0 ||
           opponent.effects[PBEffects::Ingrain] ||
           opponent.effects[PBEffects::SmackDown]
          score-=90
        end
      when 0x11B
        if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
           isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
           isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP)
          aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
          ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
          if skill>=PBTrainerAI.mediumSkill && aspeed>ospeed
            score+=20 # Smaller since most of these move users are Flying types
          end
        end
      when 0x11C
        if skill>=PBTrainerAI.mediumSkill
          score+=20 if opponent.effects[PBEffects::MagnetRise]>0
          score+=20 if opponent.effects[PBEffects::Telekinesis]>0
          score+=20 if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
                       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC    # Bounce
          score+=20 if opponent.pbHasType?(:FLYING)
          score+=20 if opponent.hasWorkingAbility(:LEVITATE)
          score+=20 if opponent.hasWorkingItem(:AIRBALLOON)
          if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
             isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
             isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP)
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if skill>=PBTrainerAI.mediumSkill && aspeed>ospeed
              score+=50 # Larger since most of these move users are Flying types and cancels most of these moves
            end
          end
        end
      when 0x11D
        score-=80
      when 0x11E
        score-=80
      when 0x11F
        if @field.effects[PBEffects::TrickRoom]>0
          score-=90
        else
          aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
          ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
          if skill>=PBTrainerAI.highSkill && aspeed<ospeed
            score+=70
          end
        end
      when 0x120
        if !@doublebattle
          score-=100
        elsif attacker.pbPartner.fainted?
          score-=90
        else
          score-=80
        end
      when 0x121
      when 0x122
      when 0x123
        if !opponent.pbHasType?(attacker.type1) &&
           !opponent.pbHasType?(attacker.type2)
          score=0
        end
      when 0x124
        if @field.effects[PBEffects::WonderRoom]>0
          score-=90
        end
      when 0x125
        for move in attacker.moves
          if move.function!=0x125 && move.pp>0
            score-=90; break
          end
        end
      when 0x126
        score+=20 # Shadow moves are more preferable
      when 0x127
        score+=20 # Shadow moves are more preferable
        score+=15 if pbRoughStat(attacker,
           PBStats::SPEED,skill)<pbRoughStat(opponent,PBStats::SPEED,skill)
        score-=10 if opponent.status==PBStatuses::PARALYSIS
      when 0x128
        score+=20 # Shadow moves are more preferable
        score-=10 if opponent.status==PBStatuses::BURN
        score-=40 if opponent.pbHasType?(:FIRE)
      when 0x129
        score+=20 # Shadow moves are more preferable
        score-=10 if opponent.status==PBStatuses::FROZEN
        score-=40 if opponent.pbHasType?(:ICE)
      when 0x12A
        score+=20 # Shadow moves are more preferable
        if !opponent.pbCanConfuse?(attacker,false,move)
          score-=100
        elsif move.accuracy>=75
          score+=70 if attacker.turncount<3
          score+=40 if attacker.turncount>=3  
        end
      when 0x12B
        score+=20 # Shadow moves are more preferable
        score-=100 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,attacker)
        if score>20
          score+=(opponent.stages[PBStats::DEFENSE]*20)
        end
      when 0x12C
        score+=20 # Shadow moves are more preferable
        score-=100 if !opponent.pbCanReduceStatStage?(PBStats::EVASION,attacker)
        if score>20
          score+=(opponent.stages[PBStats::EVASION]*10)
        end
      when 0x12D
        score+=20 # Shadow moves are more preferable
        score+=20 if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
      when 0x12E
        score+=20 # Shadow moves are more preferable
      when 0x12F
        score+=20 # Shadow moves are more preferable
        score-=100 if opponent.effects[PBEffects::MeanLook]>=0
      when 0x130
        score+=20 # Shadow moves are more preferable
        score-=25
        score+=(attacker.hp*50/attacker.totalhp)
      when 0x131
        score+=20 # Shadow moves are more preferable
        score-=90 if pbCheckGlobalAbility(:AIRLOCK)
        score-=90 if pbCheckGlobalAbility(:CLOUDNINE)
        score-=100 if pbWeather==PBWeather::SHADOWSKY
      when 0x132
        score+=20 # Shadow moves are more preferable
        score+=30 if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
        score+=30 if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
        score+=30 if attacker.pbOpposingSide.effects[PBEffects::Safeguard]>0
        score-=90 if attacker.pbOwnSide.effects[PBEffects::Reflect]>0
        score-=90 if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
        score-=90 if attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
      when 0x136
        if opponent.hasWorkingAbility(:MAGICBOUNCE)
          score=0
        else
          if skill>=PBTrainerAI.highSkill && opponent.pbHasMoveFunction?(0xB1)
            score-=30
          end
          if attacker.pbOpposingSide.effects[PBEffects::Livewire] > 4 ||
             (attacker.pbOpposingSide.effects[PBEffects::Livewire] > 2 && 
             (pbWeather==PBWeather::RAINDANCE || pbWeather==PBWeather::HEAVYRAIN))
            score-=90
          elsif !pbCanChooseNonActive?(attacker.pbOpposing1.index) &&
               !pbCanChooseNonActive?(attacker.pbOpposing2.index)
            # No active Pokemon remains on opposing side
            score-=90
          elsif attacker.pbOpposingSide.effects[PBEffects::Livewire]>=0
            score+=[90,26,13,13,13][attacker.pbOpposingSide.effects[PBEffects::Livewire]]
            score+=5*attacker.pbOppositeOpposing.pbNonActivePokemonCount()
          end
          score/=2 if ((pbWeather==PBWeather::RAINDANCE || pbWeather==PBWeather::HEAVYRAIN) && attacker.pbOpposingSide.effects[PBEffects::Livewire] > 0)
        end
      when 0x141
        if opponent.hasWorkingAbility(:MAGICBOUNCE)
          score=0
        else
          if skill>=PBTrainerAI.highSkill && opponent.pbHasMoveFunction?(0xB1)
            score-=30
          end
          if attacker.pbOpposingSide.effects[PBEffects::Permafrost] > 4
            score-=90
          elsif !pbCanChooseNonActive?(attacker.pbOpposing1.index) &&
               !pbCanChooseNonActive?(attacker.pbOpposing2.index)
            # No active Pokemon remains on opposing side
            score-=90
          elsif attacker.pbOpposingSide.effects[PBEffects::Permafrost]>=0
            score+=[90,26,13,13,13][attacker.pbOpposingSide.effects[PBEffects::Permafrost]]
            score+=5*attacker.pbOppositeOpposing.pbNonActivePokemonCount()
          end
        end
      when 0x142
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif (opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)) ||
           isConst?(opponent.ability,PBAbilities,:MULTITYPE)
          score-=90
        elsif opponent.pbHasType?(:ROCK)
          score-=90
        end
      when 0x147
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif (opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)) ||
           isConst?(opponent.ability,PBAbilities,:MULTITYPE)
          score-=90
        elsif opponent.pbHasType?(:DRAGON)
          score-=90
        end
      when 0x14A
        if !@doublebattle
          score-=80 # Waste of a turn in singles battles
        else
          if skill>=PBTrainerAI.highSkill
            # Probability of using Crafty Shield increases with the ratio of status 
            # to damaging moves
            # TODO: Factor in opponent's stat increases (more likely to attack with
            # higher stats)
            for thismove in opponent.moves
              if thismove.pbIsStatus?
                score+=20
              else
                score-=20
              end
            end
          end
        end
      when 0x14B
        if skill>=PBTrainerAI.mediumSkill && attacker.species==PBSpecies::AEGISLASH && attacker.form>0 &&
           attacker.hasWorkingAbility(:STANCECHANGE)
          # Aegislash should revert to Shield forme when possible
          score+=200
        elsif attacker.effects[PBEffects::ProtectRate]>1 ||
              opponent.effects[PBEffects::HyperBeam]>0
          score-=90
        else
          if skill>=PBTrainerAI.mediumSkill
            score-=((attacker.effects[PBEffects::ProtectRate]-1)*40)
          end
          #score+=50 if attacker.turncount==0
          score+=30 if opponent.effects[PBEffects::TwoTurnAttack]!=0 && !(isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
                    isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE))
        end
      when 0x14C
        if attacker.effects[PBEffects::ProtectRate]>1 ||
           opponent.effects[PBEffects::HyperBeam]>0
          score-=90
        else
          if skill>=PBTrainerAI.mediumSkill
            score-=((attacker.effects[PBEffects::ProtectRate]-1)*40)
          end
          #score+=50 if attacker.turncount==0
          score+=30 if opponent.effects[PBEffects::TwoTurnAttack]!=0 &&
                    !(isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
                    isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE))
        end
      when 0x153
        if attacker.hasWorkingAbility(:CONTRARY)
          score=0
        elsif attacker.pbTooHigh?(PBStats::SPATK) &&
           attacker.pbTooHigh?(PBStats::SPDEF) &&
           attacker.pbTooHigh?(PBStats::SPEED)
          score-=90
        else
          score-=attacker.stages[PBStats::SPATK]*10 # Only *10 isntead of *20
          score-=attacker.stages[PBStats::SPDEF]*10 # because two-turn attack
          score-=attacker.stages[PBStats::SPEED]*10
          if skill>=PBTrainerAI.mediumSkill
            hasspecialattack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsSpecial?(thismove.type)
                hasspecialattack=true
              end
            end
            if hasspecialattack
              score+=20
            elsif skill>=PBTrainerAI.highSkill
              score-=90
            end
          end
          if skill>=PBTrainerAI.highSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed && aspeed*2>ospeed
              score+=30
            end
          end
        end
      when 0x162
        aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
        if aspeed>ospeed
          score-=90
        else
          score+=30 if opponent.pbHasMoveType?(:FIRE)
        end
      when 0x163
        if opponent.hasWorkingAbility(:CONTRARY)
          score=0
        elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif opponent.hasWorkingAbility(:SOUNDPROOF) && skill>=PBTrainerAI.highSkill
          score-=90
        else
          avg=opponent.stages[PBStats::ATTACK]*10
          avg+=opponent.stages[PBStats::SPATK]*10
          avg*=2 if opponent.hasWorkingAbility(:SIMPLE)
          score+=avg/2
        end
      when 0x164
        if @field.effects[PBEffects::GrassyTerrain]>0 || attacker.isAirborne? ||
           attacker.effects[PBEffects::HealBlock]>0
          score-=90
        elsif !attacker.isAirborne? || (@doublebattle && !attacker.pbPartner.isAirborne?)
          for thismove in attacker.moves
            if thismove.id!=0 && thismove.basedamage>0 &&
               isConst?(thismove.type,PBTypes,:GRASS)
              score+=20
            end
          end
          if attacker.hasWorkingAbility(:GRASSPELT)
            score+=20
          end
          if @doublebattle
            for thismove in attacker.pbPartner.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 isConst?(thismove.type,PBTypes,:GRASS)
                score+=20
              end
            end
            if attacker.pbPartner.hasWorkingAbility(:GRASSPELT)
              score+=20
            end
          end
        end
      when 0x165
        if @field.effects[PBEffects::MistyTerrain]>0 || attacker.isAirborne?
          score-=90
        elsif !attacker.isAirborne? || (@doublebattle && !attacker.pbPartner.isAirborne?)
          for thismove in attacker.moves
            if thismove.id!=0 && thismove.basedamage>0 &&
               isConst?(thismove.type,PBTypes,:DRAGON)
              score-=10
            end
          end
          if attacker.pbHasStatusMove? || opponent.effects[PBEffects::Yawn]>0 ||
             attacker.pbHasMoveFunction?(0xD9) # Rest
            score-=50
          end
          if attacker.effects[PBEffects::Yawn]>0 || (skill>=PBTrainerAI.highSkill && 
             (opponent.pbHasStatusMove? || opponent.pbHasMoveFunction?(0xD9))) # Rest
            score+=50
          end
          if @doublebattle
            for thismove in attacker.pbPartner.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 isConst?(thismove.type,PBTypes,:DRAGON)
                score-=10
              end
            end
            if attacker.pbPartner.pbHasStatusMove? || opponent.pbPartner.effects[PBEffects::Yawn]>0 ||
               attacker.pbPartner.pbHasMoveFunction?(0xD9) # Rest
              score-=50
            end
            if attacker.pbPartner.effects[PBEffects::Yawn]>0 || (skill>=PBTrainerAI.highSkill && 
               (opponent.pbPartner.pbHasStatusMove? || opponent.pbPartner.pbHasMoveFunction?(0xD9))) # Rest
              score+=50
            end
          end
        end
      when 0x166
        if @field.effects[PBEffects::ElectricTerrain]>0 || attacker.isAirborne?
          score-=90
        elsif !attacker.isAirborne? || (@doublebattle && !attacker.pbPartner.isAirborne?)
          for thismove in attacker.moves
            if thismove.id!=0 && thismove.basedamage>0 &&
               isConst?(thismove.type,PBTypes,:ELECTRIC)
              score+=20
            end
          end
          if attacker.pbHasSleepMove? || opponent.effects[PBEffects::Yawn]>0 ||
             attacker.pbHasMoveFunction?(0xD9) # Rest
            score-=50
          end
          if attacker.effects[PBEffects::Yawn]>0 || (skill>=PBTrainerAI.highSkill && 
             (opponent.pbHasSleepMove? || opponent.pbHasMoveFunction?(0xD9))) # Rest
            score+=50
          end
          if @doublebattle
            for thismove in attacker.pbPartner.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 isConst?(thismove.type,PBTypes,:ELECTRIC)
                score+=20
              end
            end
            if attacker.pbPartner.pbHasSleepMove? || opponent.pbPartner.effects[PBEffects::Yawn]>0 ||
               attacker.pbPartner.pbHasMoveFunction?(0xD9) # Rest
              score-=50
            end
            if attacker.pbPartner.effects[PBEffects::Yawn]>0 || (skill>=PBTrainerAI.highSkill && 
               (opponent.pbPartner.pbHasSleepMove? || opponent.pbPartner.pbHasMoveFunction?(0xD9))) # Rest
              score+=50
            end
          end
        end
      when 0x167
        count=0
        for i in 0...4
          battler=@battlers[i]
          if battler.pbHasType?(:GRASS) && !battler.pbTooHigh?(PBStats::DEFENSE) && !battler.fainted?
            count+=1
            if attacker.pbIsOpposing?(i)
              amount=0
              amount+=20
              amount*=2 if battler.hasWorkingAbility(:SIMPLE)
              amount*=-1 if battler.hasWorkingAbility(:CONTRARY)
              score-=amount
            else
              amount=0
              amount-=attacker.stages[PBStats::DEFENSE]*10
              amount*=2 if battler.hasWorkingAbility(:SIMPLE)
              amount*=-1 if battler.hasWorkingAbility(:CONTRARY)
              score+=amount
            end
          end
        end
        score-=95 if count==0
      when 0x168
        if !@doublebattle
          score-=100
        elsif attacker.pbPartner.fainted?
          score-=90
        else
          amount=0
          amount-=attacker.pbPartner.stages[PBStats::SPDEF]*10
          amount*=-1 if attacker.pbPartner.hasWorkingAbility(:CONTRARY)
          amount*=2 if attacker.pbPartner.hasWorkingAbility(:SIMPLE)
          score+=amount
        end
      when 0x169
        if opponent.hasWorkingAbility(:CONTRARY)
          score=0
        elsif !opponent.pbCanReduceStatStage?(PBStats::ATTACK,attacker)
          score-=90
        else
          amount=0
          amount+=opponent.stages[PBStats::ATTACK]*20
          amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
          score+=amount
          if skill>=PBTrainerAI.mediumSkill
            hasphysicalattack=false
            for thismove in opponent.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasphysicalattack=true
              end
            end
            if hasphysicalattack
              score+=20
              score+=20 if opponent.hasWorkingAbility(:SIMPLE)
            elsif skill>=PBTrainerAI.highSkill
              score-=90
            end
          end
        end
      when 0x170
        if opponent.pbHasType?(:GRASS)
          score-=90
        end
      when 0x171
        if opponent.pbHasType?(:GHOST)
          score-=90
        end
      when 0x172
        count=0
        for i in 0...4
          battler=@battlers[i]
          if battler.status==PBStatuses::POISON && !battler.fainted? &&
             (!battler.pbTooLow?(PBStats::ATTACK) ||
             !battler.pbTooLow?(PBStats::SPATK) ||
             !battler.pbTooLow?(PBStats::SPEED))
            count+=1
            if attacker.pbIsOpposing?(i)
              if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
                score-=30
              end
              amount=0
              amount+=battler.stages[PBStats::ATTACK]*10
              amount+=battler.stages[PBStats::SPATK]*10
              amount+=battler.stages[PBStats::SPEED]*10
              amount*=2 if battler.hasWorkingAbility(:SIMPLE)
              score+=amount
            else
              score-=20
            end
          end
        end
        score-=95 if count==0
      when 0x173
        count=0
        for i in 0...4
          battler=@battlers[i]
          if battler.pbHasType?(:GRASS) && !battler.isAirborne? &&
             (!battler.pbTooHigh?(PBStats::ATTACK) || !battler.pbTooHigh?(PBStats::SPATK))
            count+=1
            if attacker.pbIsOpposing?(i)
              score-=20
              score-=20 if battler.hasWorkingAbility(:SIMPLE)
            else
              amount=0
              amount-=battler.stages[PBStats::ATTACK]*10
              amount-=battler.stages[PBStats::SPATK]*10
              amount*=2 if battler.hasWorkingAbility(:SIMPLE)
              score+=amount
            end
          end
        end
        score-=95 if count==0
      when 0x174
        score-=90 if !attacker.pokemon || !attacker.pokemon.belch
      when 0x176
        if attacker.turncount==0
          score+=30
        else
          score-=90 # Because it will fail here
          score=0 if skill>=PBTrainerAI.bestSkill
        end
      when 0x178
        if opponent.hasWorkingAbility(:MAGICBOUNCE)
          score=0
        else
          if skill>=PBTrainerAI.highSkill && opponent.pbHasMoveFunction?(0xB1)
            score-=30
          end
          if opponent.pbOwnSide.effects[PBEffects::StickyWeb]
            score-=95
          elsif !pbCanChooseNonActive?(attacker.pbOpposing1.index) &&
                !pbCanChooseNonActive?(attacker.pbOpposing2.index)
            # Opponent can't switch in any Pokemon
            score-=90
          else
            score+=15*attacker.pbOppositeOpposing.pbNonActivePokemonCount()
          end
        end
      when 0x179
        if opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)
          score-=90
        else
          numpos=0; numneg=0
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                    PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
            stat=opponent.stages[i]
            (stat>0) ? numpos+=stat : numneg+=stat
          end
          if numpos!=0 || numneg!=0
            score+=(numpos-numneg)*10
          else
            score-=95
          end
        end
      when 0x182
        if pbCheckGlobalAbility(:AIRLOCK) ||
           pbCheckGlobalAbility(:CLOUDNINE) ||
           pbWeather==PBWeather::HARSHSUN ||
           pbWeather==PBWeather::HEAVYRAIN ||
           pbWeather==PBWeather::STRONGWINDS
          score-=90
        elsif pbWeather==PBWeather::NEWMOON
          score-=90
        elsif pbWeather!=0 && pbWeather!=PBWeather::NEWMOON && !attacker.hasWorkingAbility(:FORECAST)
          score+=40
        else
          for move in attacker.moves
            if move.id!=0 && move.basedamage>0 &&
               isConst?(move.type,PBTypes,:DARK)
              score+=20
            end
          end
        end
      when 0x183
        if opponent.hasWorkingAbility(:CONTRARY)
          score=0
        elsif opponent.hasWorkingAbility(:MAGICBOUNCE) && skill>=PBTrainerAI.highSkill
          score-=90
        elsif !opponent.pbCanReduceStatStage?(PBStats::SPATK,attacker)
          score-=90
        else
          score+=40 if attacker.turncount==0
          amount=0
          amount+=opponent.stages[PBStats::SPATK]*20
          amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
          score+=amount
        end
      when 0x184
        if attacker.pbOwnSide.effects[PBEffects::JetStream]>0
          score-=90
        elsif @doublebattle
          score+=10
        end
      when 0x187
        total=0
        total+=(attacker.stages[PBStats::ATTACK]*10)
        total+=(attacker.stages[PBStats::DEFENSE]*10)
        total+=(attacker.stages[PBStats::SPEED]*10)
        total+=(attacker.stages[PBStats::SPATK]*10)
        total+=(attacker.stages[PBStats::SPDEF]*10)
        total+=(attacker.stages[PBStats::EVASION]*10)
        total+=(attacker.stages[PBStats::ACCURACY]*10)
        total+=20 if attacker.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(opponent)
        score+=total
        if total>0
          score-=60
        end
        avg=opponent.stages[PBStats::ATTACK]*10
        avg+=opponent.stages[PBStats::SPATK]*10
        avg*=2 if opponent.hasWorkingAbility(:SIMPLE)
        avg*=-1 if opponent.hasWorkingAbility(:CONTRARY)
        score+=avg/2
      when 0x188
        score-=70
      when 0x199
        notMega=[
          PBSpecies::ARCEUS,
          PBSpecies::GIRATINA,
          PBSpecies::REGIGIGAS,
          PBSpecies::KYOGRE,
          PBSpecies::GROUDON
        ]
        if opponent.hasWorkingAbility(:MAGICBOUNCE)
          score=0
        elsif opponent.isMega? && !notMega.include?(opponent.species)
          score+=50
        else
          score-=90
        end
      when 0x200
        if attacker.hp==attacker.totalhp
          score-=90
        else
          score+=50
          score-=(attacker.hp*100/attacker.totalhp)
        end
        score+=20 if (attacker.stages[PBStats::DEFENSE]<0)
        score-=40 if attacker.hasWorkingAbility(:CONTRARY)
      when 0x201
      when 0x202
        amount=0
        amount+=(attacker.stages[PBStats::DEFENSE]*10)
        amount*=2 if opponent.hasWorkingAbility(:SIMPLE)
        amount*=-1 if opponent.hasWorkingAbility(:CONTRARY)
        score+=amount
      when 0x203
        score-=10
      when 0x204
        if skill>=PBTrainerAI.mediumSkill
          if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
            score-=90
          elsif isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY)
            score-=90
          elsif opponent.effects[PBEffects::SpiritAway] && opponent.effects[PBEffects::SpiritAwayPartnerPos]!=attacker.index
            score-=90
          elsif !opponent.pbIsOpposing?(attacker.index)
            score-=90
          end
        elsif skill>=PBTrainerAI.highSkill
          if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker)
            score=0
          elsif isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SKYDROP) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:PHANTOMFORCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SHADOWFORCE) ||
                isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:SPIRITAWAY)
            score=0
          elsif opponent.effects[PBEffects::SkyDrop] && opponent.effects[PBEffects::SkyDropPartnerPos]!=attacker.index
            score=0
          elsif !opponent.pbIsOpposing?(attacker.index)
            score=0
          end
        end
      when 0x205
        if skill>=PBTrainerAI.highSkill && opponent.hasWorkingAbility(:LIQUIDOOZE)
          score-=80
        else
          score+=40 if attacker.hp<=(attacker.totalhp/2)
        end
      when 0x206, 0x207, 0x208
        score-=95
        if skill>=PBTrainerAI.highSkill
          score=0
        end
      when 0x209
        aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
        if aspeed<ospeed
          score-=90
        elsif ((attacker.hasWorkingAbility(:VOLTABSORB) || attacker.hasWorkingAbility(:MOTORDRIVE)) && 
             !@doublebattle) || attacker.hasWorkingAbility(:LIGHTNINGROD)
          score+=90
        end
      when 0x210
        if !attacker.hasWorkingAbility(:PLUS) && !attacker.hasWorkingAbility(:MINUS) &&
           !attacker.pbPartner.hasWorkingAbility(:PLUS) && !attacker.pbPartner.hasWorkingAbility(:MINUS)
          score-=90
        else
          if attacker.pbTooHigh?(PBStats::DEFENSE) &&
             attacker.pbTooHigh?(PBStats::SPDEF) &&
             !attacker.pbPartner.fainted? &&
             attacker.pbPartner.pbTooHigh?(PBStats::DEFENSE) &&
             attacker.pbPartner.pbTooHigh?(PBStats::SPDEF)
            score-=90
          else
            score-=attacker.stages[PBStats::DEFENSE]*10
            score-=attacker.stages[PBStats::SPDEF]*10
            if !attacker.pbPartner.fainted?
              score-=attacker.pbPartner.stages[PBStats::DEFENSE]*10
              score-=attacker.pbPartner.stages[PBStats::SPDEF]*10
            end
          end
        end
      when 0x211
        if ((attacker.hasWorkingAbility(:VOLTABSORB) || attacker.hasWorkingAbility(:MOTORDRIVE)) && 
           !@doublebattle) || attacker.hasWorkingAbility(:LIGHTNINGROD)
          if skill>=PBTrainerAI.highSkill
            # Probability of using Ion Deluge increases with the ratio of Normal and
            # Electric type moves to other move types
            # TODO: Factor in type match-ups
            for thismove in opponent.moves
              if isConst?(move.type,PBTypes,:NORMAL) || 
                 isConst?(move.type,PBTypes,:ELECTRIC)
                score+=20
              else
                score-=20
              end
            end
          end
        else
          score-=90 
        end
      when 0x212
        aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        ospeed1=pbRoughStat(opponent,PBStats::SPEED,skill)
        if aspeed<ospeed1
          if (opponent.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)) ||
             opponent.effects[PBEffects::GastroAcid]
            score-=10
          elsif skill>=PBTrainerAI.highSkill
            if isConst?(opponent.ability,PBAbilities,:MULTITYPE)
              # Don't change score in this case
            elsif isConst?(opponent.ability,PBAbilities,:SLOWSTART)
              score-=90
            elsif isConst?(opponent.ability,PBAbilities,:TRUANT)
              score-=90 
            else
              score+=20
            end
          end
        end
        if @doublebattle
          ospeed2=pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)
          if aspeed<ospeed2
            if (opponent.pbPartner.effects[PBEffects::Substitute]>0 && !move.ignoresSubstitute?(attacker)) ||
             opponent.pbPartner.effects[PBEffects::GastroAcid]
              score-=10
            elsif skill>=PBTrainerAI.highSkill
              if isConst?(opponent.pbPartner.ability,PBAbilities,:MULTITYPE)
                # Don't change score in this case
              elsif isConst?(opponent.pbPartner.ability,PBAbilities,:SLOWSTART)
                score-=90
              elsif isConst?(opponent.pbPartner.ability,PBAbilities,:TRUANT)
                score-=90 
              else
                score+=20
              end
            end
          end
        end
      when 0x213
        score+=20 if !attacker.pbTooHigh?(PBStats::ATTACK) && opponent.hp<=(opponent.totalhp/4)
        score-=40 if attacker.hasWorkingAbility(:CONTRARY)
      when 0x214
        score-=90 if !attacker.pokemon || attacker.pokemon.burstAttack || !attacker.effects[PBEffects::BurstMode]
      when 0x215
        score-=90 if !attacker.pokemon || attacker.pokemon.burstAttack || !attacker.effects[PBEffects::BurstMode]
      when 0x216
        score-=90 if !attacker.pokemon || attacker.pokemon.burstAttack || !attacker.effects[PBEffects::BurstMode]
      when 0x217
        score-=90 if !attacker.pokemon || attacker.pokemon.burstAttack || !attacker.effects[PBEffects::BurstMode]
      end
    # A score of 0 here means it should absolutely not be used
    Kernel.pbMessage("Get score 1") if debugScore
    return score if score<=0
    Kernel.pbMessage("Get score 2") if debugScore
##### Other score modifications ################################################
    opponent=attacker.pbOppositeOpposing if !opponent
    opponent=opponent.pbPartner if opponent && opponent.hp==0
    Kernel.pbMessage("Get score 3") if debugScore
    # Prefer damaging moves if AI has no more Pokémon
    if attacker.pbNonActivePokemonCount==0
      if skill>=PBTrainerAI.mediumSkill &&
         !(skill>=PBTrainerAI.highSkill && opponent.pbNonActivePokemonCount>0)
        if move.basedamage==0
          score/=1.5
        elsif opponent.hp<=opponent.totalhp/2
          score*=1.5
        end
      end
    end
    Kernel.pbMessage("Get score 4") if debugScore
    # Don't prefer attacking the opponent if they'd be semi-invulnerable
    if opponent.effects[PBEffects::TwoTurnAttack]>0 &&
       skill>=PBTrainerAI.highSkill
      invulmove=PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function
      if move.accuracy>0 &&   # Checks accuracy, i.e. targets opponent
         ([0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0x204].include?(invulmove) ||
         opponent.effects[PBEffects::SkyDrop]) &&
         attacker.pbSpeed>opponent.pbSpeed
        if skill>=PBTrainerAI.highSkill   # Can get past semi-invulnerability
          miss=false
          case invulmove
          when 0xC9, 0xCC # Fly, Bounce
            miss=true unless move.function==0x08 ||  # Thunder
                             move.function==0x15 ||  # Hurricane
                             move.function==0x77 ||  # Gust
                             move.function==0x78 ||  # Twister
                             move.function==0x11B || # Sky Uppercut
                             move.function==0x11C # Smack Down
          when 0xCA # Dig
            miss=true unless move.function==0x76 || # Earthquake
                             move.function==0x95    # Magnitude
          when 0xCB # Dive
            miss=true unless move.function==0x75 || # Surf
                             move.function==0xD0    # Whirlpool
          when 0xCD # Shadow Force
            miss=true
          when 0xCE # Sky Drop
            miss=true unless move.function==0x08 ||  # Thunder
                             move.function==0x15 ||  # Hurricane
                             move.function==0x77 ||  # Gust
                             move.function==0x78 ||  # Twister
                             move.function==0x11B || # Sky Uppercut
                             move.function==0x11C    # Smack Down
          when 0x14D # Phantom Force
            miss=true
          end
          if opponent.effects[PBEffects::SkyDrop]
            miss=true unless move.function==0x08 ||  # Thunder
                             move.function==0x15 ||  # Hurricane
                             move.function==0x77 ||  # Gust
                             move.function==0x78 ||  # Twister
                             move.function==0x11B || # Sky Uppercut
                             move.function==0x11C    # Smack Down
          end
          miss=false if opponent.effects[PBEffects::LockOn]>0 &&
                        opponent.effects[PBEffects::LockOnPos]==attacker.index
          miss=false if attacker.hasWorkingAbility(:NOGUARD) || 
                        opponent.hasWorkingAbility(:NOGUARD)
          miss=false if attacker.pbHasType?(:POISON) && isConst?(move.id,PBMoves,:TOXIC)
          score-=80 if miss
        else
          score-=80
        end
      end
    end
    Kernel.pbMessage("Get score 5") if debugScore
    # Don't prefer attacking moves if they would trigger Rough Skin, etc.
    if !attacker.hasWorkingAbility(:MAGICGUARD) && skill>=PBTrainerAI.highSkill &&
       (opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker))
      if !move.isContactMove? && opponent.hasWorkingAbility(:DIAMONDSKIN,true)
        score-=20
      elsif move.isContactMove?
        if opponent.hasWorkingAbility(:ROUGHSKIN,true) || 
           opponent.hasWorkingAbility(:IRONBARBS,true)
          score-=20
        elsif opponent.hasWorkingAbility(:AFTERMATH,true)
          if !pbCheckGlobalAbility(:DAMP,true) && !attacker.hasMoldBreaker
            if opponent.hp<=opponent.totalhp/4
              score-=40
            elsif opponent.hp<=opponent.totalhp/2
              score-=20
            end
          end
        elsif opponent.hasWorkingAbility(:GLITCH,true)
          score-=90
        end
        if opponent.hasWorkingItem(:ROCKYHELMET,true)
          score-=30
        end
      end
    end
    Kernel.pbMessage("Get score 6") if debugScore
    # Pick a good move for the Choice items
    if attacker.hasWorkingItem(:CHOICEBAND) ||
       attacker.hasWorkingItem(:CHOICESPECS) ||
       attacker.hasWorkingItem(:CHOICESCARF)
      if skill>=PBTrainerAI.mediumSkill
        if move.basedamage>=60
          score+=60
        elsif move.basedamage>0
          score+=30
        elsif move.function==0xF2 # Trick
          score+=70
        else
          score-=60
        end
      end
    end
    Kernel.pbMessage("Get score 7") if debugScore
    # If user has King's Rock, prefer moves that may cause flinching with it # TODO
    # If user is asleep, prefer moves that are usable while asleep
    if attacker.status==PBStatuses::SLEEP
      if skill>=PBTrainerAI.mediumSkill
        if move.function!=0x11 && move.function!=0xB4 # Snore, Sleep Talk
          hasSleepMove=false
          hasSleepMove=true if attacker.pbHasMoveFunction?(0x11) || 
                               attacker.pbHasMoveFunction?(0xB4)
          score-=60 if hasSleepMove
        end
      end
    end
    Kernel.pbMessage("Get score 8") if debugScore
    # If user is frozen, prefer a move that can thaw the user
    if attacker.status==PBStatuses::FROZEN
      if skill>=PBTrainerAI.mediumSkill
        if move.canThawUser?
          score+=40
        else
          hasFreezeMove=false
          for m in attacker.moves
            if m.canThawUser?
              hasFreezeMove=true; break
            end
          end
          score-=60 if hasFreezeMove
        end
      end
    end
    Kernel.pbMessage("Get score 9") if debugScore
    # If target is frozen, don't prefer moves that could thaw them
    if opponent.status==PBStatuses::FROZEN
      if skill>=PBTrainerAI.mediumSkill
        if move.canThawUser?
          score-=40
        else
          hasFreezeMove=false
          for m in attacker.moves
            if m.canThawUser?
              hasFreezeMove=true; break
            end
          end
          score+=60 if hasFreezeMove
        end
      end
    end
    Kernel.pbMessage("Get score 10") if debugScore
    # Prioritize Flying-type moves slightly if user has Gale Wings
    if attacker.hasWorkingAbility(:GALEWINGS)
      if skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:FLYING)
        score+=10
      end
    end
    Kernel.pbMessage("Get score 11") if debugScore
    # Prioritize status moves slightly if user has Prankster
    if attacker.hasWorkingAbility(:PRANKSTER)
      if skill>=PBTrainerAI.mediumSkill && move.pbIsStatus?
        score+=10
      end
    end
    Kernel.pbMessage("Get score 12") if debugScore
    # Prioritize Fire-type moves relative to current stats if the user has Blaze
    # Boost
    if attacker.hasWorkingAbility(:BLAZEBOOST)
      if skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:FIRE)
        if attacker.pbTooHigh?(PBStats::SPEED) &&
           attacker.pbTooHigh?(PBStats::SPATK) &&
           attacker.pbTooHigh?(PBStats::ATTACK)
          # No score added if stats are at max
        else
          amount=0
          amount-=(attacker.stages[PBStats::SPEED]*10)
          amount-=(attacker.stages[PBStats::SPATK]*10)
          amount-=(attacker.stages[PBStats::ATTACK]*10)
          score+=amount
          if skill>=PBTrainerAI.mediumSkill
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0
                hasAttack=true
              end
            end
            if !hasAttack
              # No score added if no moves meet the requirements
            else
              score+=20
            end
          end
          if skill>=PBTrainerAI.mediumSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed && aspeed*2>ospeed
              score+=20
            end
          end
        end
      end
    end
    Kernel.pbMessage("Get score 13") if debugScore
    # Adjust score based on how much damage it can deal
    if move.basedamage>0
    Kernel.pbMessage("Get score 14") if debugScore
      typemod=pbTypeModMove(move,attacker,opponent)
    Kernel.pbMessage("Get score 15") if debugScore
      if typemod==0 || score<=0
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && typemod<=4 &&
            opponent.hasWorkingAbility(:WONDERGUARD)
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:GROUND) &&
            (opponent.isAirborne? && !(opponent.pbHasType?(PBTypes::FLYING) &&
            attacker.hasWorkingAbility(:IRRELEPHANT)))
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:FIRE) &&
            (opponent.hasWorkingAbility(:FLASHFIRE) ||
            pbWeather==PBWeather::HEAVYRAIN)
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:WATER) &&
            (opponent.hasWorkingAbility(:WATERABSORB) ||
            opponent.hasWorkingAbility(:STORMDRAIN) ||
            opponent.hasWorkingAbility(:DRYSKIN) ||
            opponent.hasWorkingAbility(:VAPORIZATION) ||
            pbWeather==PBWeather::HARSHSUN)
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:GRASS) &&
            opponent.hasWorkingAbility(:SAPSIPPER)
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:ELECTRIC) &&
            (opponent.hasWorkingAbility(:VOLTABSORB) ||
            opponent.hasWorkingAbility(:LIGHTNINGROD) ||
            opponent.hasWorkingAbility(:MOTORDRIVE))
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:FLYING) &&
            opponent.hasWorkingAbility(:WINDFORCE)
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && opponent.hasWorkingAbility(:BULLETPROOF) &&
            move.isBombMove?
        score=0
    Kernel.pbMessage("Get score 15.1") if debugScore
      else
    Kernel.pbMessage("Get score 15.2") if debugScore
        # Calculate how much damage the move will do (roughly)
        realDamage=move.basedamage
    Kernel.pbMessage("Get score 16") if debugScore
        realDamage=60 if move.basedamage==1
        if skill>=PBTrainerAI.mediumSkill
    Kernel.pbMessage("Get score 16.1") if debugScore
          realDamage=pbBetterBaseDamage(move,attacker,opponent,skill,realDamage)
        end
    Kernel.pbMessage("Get score 17") if debugScore
        realDamage=pbRoughDamage(move,attacker,opponent,skill,realDamage)
    Kernel.pbMessage("Get score 18") if debugScore
        # Account for accuracy of move
        accuracy=pbRoughAccuracy(move,attacker,opponent,skill)
    Kernel.pbMessage("Get score 19") if debugScore
        basedamage=realDamage*accuracy/100.0
    Kernel.pbMessage("Get score 20") if debugScore
        # Two-turn attacks waste 2 turns to deal a lot of damage
        if move.pbTwoTurnAttack(attacker) || move.function==0xC2 # Hyper Beam
          basedamage*=2/3   # Not halved because semi-invulnerable during use or hits first turn
        end
        # Future Sight and Doom Desire take 3 turns before dealing a lot of damage
        if move.function==0x111 # Future Sight/Doom Desire
          basedamage*=2/3   # Not 1/2 or less because user can act after 1 turn
        end
    Kernel.pbMessage("Get score 21") if debugScore
        # Prefer flinching effects
        if !opponent.hasWorkingAbility(:INNERFOCUS) &&
           (opponent.effects[PBEffects::Substitute]==0 || move.ignoresSubstitute?(attacker))
          if (attacker.hasWorkingItem(:KINGSROCK) || attacker.hasWorkingItem(:RAZORFANG)) &&
             move.canKingsRock?
            basedamage*=1.05
          elsif attacker.hasWorkingAbility(:STENCH) &&
                move.function!=0x09 && # Thunder Fang
                move.function!=0x0B && # Fire Fang
                move.function!=0x0E && # Ice Fang
                move.function!=0x0F && # flinch-inducing moves
                move.function!=0x10 && # Stomp
                move.function!=0x11 && # Snore
                move.function!=0x12 && # Fake Out
                move.function!=0x78 && # Twister
                move.function!=0xC7    # Sky Attack
            basedamage*=1.05
          end
        end
    Kernel.pbMessage("Get score 22") if debugScore
        # Convert damage to proportion of opponent's remaining HP
        basedamage=(basedamage*100.0/opponent.hp)
    Kernel.pbMessage("Get score 23") if debugScore
        # Don't prefer weak attacks
        #basedamage/=2 if basedamage<40
        basedamage-=40 if basedamage<40 && basedamage>0
        # Prefer damaging attack if level difference is significantly high
        #basedamage*=1.2 if attacker.level-10>opponent.level
    Kernel.pbMessage("Get score 24") if debugScore
        # Adjust score
        basedamage=basedamage.round
    Kernel.pbMessage("Get score 24.1") if debugScore
        basedamage=120 if basedamage>120   # Treat all OHKO moves the same
    Kernel.pbMessage("Get score 24.2") if debugScore
        basedamage+=40 if basedamage>100   # Prefer moves likely to OHKO
    Kernel.pbMessage("Get score 24.3") if debugScore
        oldscore=score
    Kernel.pbMessage("Get score 24.4") if debugScore
        score+=basedamage
    Kernel.pbMessage("Get score 24.5") if debugScore
        #score=score*basedamage/[realDamage,1].max
    Kernel.pbMessage("Get score 25") if debugScore
        if $INTERNAL
	        PBDebug.log(sprintf("%s: %d=>%d",PBMoves.getName(move.id),realBaseDamage,basedamage))
          PBDebug.log(sprintf("   change: %d=>%d",oldscore,score))
        end
    Kernel.pbMessage("Get score 26") if debugScore
      end
    else
      if move.target==PBTargets::AllOpposing || move.target==PBTargets::SingleOpposing ||
         move.target==PBTargets::RandomOpposing || move.target==PBTargets::SingleNonUser
        if move.isPowderMove?
          if skill>=PBTrainerAI.mediumSkill && opponent.pbHasType?(PBTypes::GRASS)
            score=0
          elsif skill>=PBTrainerAI.highSkill
            if opponent.hasWorkingItem(:SAFETYGOGGLES) || 
               opponent.hasWorkingAbility(:OVERCOAT)
              score=0
            end
          end
        elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:FIRE) &&
              opponent.hasWorkingAbility(:FLASHFIRE)
          score=0
        elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:WATER) &&
              (opponent.hasWorkingAbility(:WATERABSORB) ||
              opponent.hasWorkingAbility(:STORMDRAIN) ||
              opponent.hasWorkingAbility(:DRYSKIN))
          score=0
        elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:GRASS) &&
              opponent.hasWorkingAbility(:SAPSIPPER)
          score=0
        elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:ELECTRIC) &&
              (opponent.hasWorkingAbility(:VOLTABSORB) ||
              opponent.hasWorkingAbility(:LIGHTNINGROD) ||
              opponent.hasWorkingAbility(:MOTORDRIVE))
          score=0
        elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:FLYING) &&
              opponent.hasWorkingAbility(:WINDFORCE)
          score=0
        end
      end
      # Don't prefer attacks which don't deal damage
      #score-=10
      # Account for accuracy of move
      accuracy=pbRoughAccuracy(move,attacker,opponent,skill)
      score*=accuracy/100.0
      score=0 if score<=10 && skill>=PBTrainerAI.highSkill
    end
    Kernel.pbMessage("Get score 27") if debugScore
    score=score.to_i
    score=0 if score<0
    Kernel.pbMessage("Get score 28") if debugScore
    return score
  end

################################################################################
# Get type effectiveness and approximate stats.
################################################################################
  def pbTypeModifier(type,attacker,opponent)
    debugTypeMod=false
    Kernel.pbMessage("Get TypeMod 1") if debugTypeMod
    return 4 if type<0
    Kernel.pbMessage("Get TypeMod 2") if debugTypeMod
    return 4 if isConst?(type,PBTypes,:GROUND) && opponent.pbHasType?(PBTypes::FLYING) &&
                isConst?(opponent.item,PBItems,:IRONBALL)
    Kernel.pbMessage("Get TypeMod 3") if debugTypeMod
    atype=type
    otype1=opponent.type1
    otype2=opponent.type2
    otype3=opponent.effects[PBEffects::Type3] || -1
    Kernel.pbMessage("Get TypeMod 4") if debugTypeMod
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
    Kernel.pbMessage("Get TypeMod 5") if debugTypeMod
    # Ancient Presence
    mod1=PBTypes.getEffectiveness(atype,otype1)
    Kernel.pbMessage("Get TypeMod 5.1") if debugTypeMod
    if (attacker.hasWorkingAbility(:ANCIENTPRESENCE) rescue false)
      return 4
    end
    Kernel.pbMessage("Get TypeMod 6") if debugTypeMod
    # Ring Target
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    if opponent.hasWorkingItem(:RINGTARGET) && !$game_switches[302]
      mod1=2 if mod1==0
      mod2=2 if mod2==0
    end
    Kernel.pbMessage("Get TypeMod 7") if debugTypeMod
    # Irrelephant
    if (attacker.hasWorkingAbility(:IRRELEPHANT) rescue false) && !$game_switches[302]
      mod1=2 if mod1==0
      mod2=2 if mod2==0
    end
    Kernel.pbMessage("Get TypeMod 8") if debugTypeMod
    # Foresight
    if (attacker.hasWorkingAbility(:SCRAPPY) rescue false) || opponent.effects[PBEffects::Foresight]
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) && PBTypes.isIneffective?(atype,otype1)
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) && PBTypes.isIneffective?(atype,otype2)
    end
    Kernel.pbMessage("Get TypeMod 9") if debugTypeMod
    # Miracle Eye
    if opponent.effects[PBEffects::MiracleEye]
      mod1=2 if isConst?(otype1,PBTypes,:DARK) && PBTypes.isIneffective?(atype,otype1)
      mod2=2 if isConst?(otype2,PBTypes,:DARK) && PBTypes.isIneffective?(atype,otype2)
    end
    Kernel.pbMessage("Get TypeMod 10") if debugTypeMod
    # Delta Stream's weather
    if pbWeather==PBWeather::STRONGWINDS
      if !$game_switches[302]
        mod1=2 if isConst?(otype1,PBTypes,:FLYING) && PBTypes.isSuperEffective?(atype,otype1)
        mod2=2 if isConst?(otype2,PBTypes,:FLYING) && PBTypes.isSuperEffective?(atype,otype2)
      else
        mod1=2 if isConst?(otype1,PBTypes,:FLYING) && PBTypes.isNotVeryEffective?(atype,otype1)
        mod2=2 if isConst?(otype2,PBTypes,:FLYING) && PBTypes.isNotVeryEffective?(atype,otype2)
      end
    end
    Kernel.pbMessage("Get TypeMod 11") if debugTypeMod
    # Smack Down makes Ground moves work against fliers
    if !opponent.isAirborne?((attacker.hasMoldBreaker rescue false)) && isConst?(atype,PBTypes,:GROUND)
      mod1=2 if isConst?(otype1,PBTypes,:FLYING)
      mod2=2 if isConst?(otype2,PBTypes,:FLYING)
    end
    i = mod1*mod2
    Kernel.pbMessage("Get TypeMod 12") if debugTypeMod
    return i
  end
  
  def pbTypeModOmnitypeInitial(move,attacker,opponent,movetype)
    if isConst?(move.id,PBMoves,:THOUSANDARROWS) && !opponent.effects[PBEffects::SmackDown]
      return 4
    elsif isConst?(move.id,PBMoves,:THOUSANDARROWS)
      return 32
    end
    if (opponent.hasWorkingItem(:RINGTARGET) ||
       (attacker.hasWorkingAbility(:IRRELEPHANT) rescue false))&& !$game_switches[302]
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
    case movetype
    when PBTypes::FLYING,PBTypes::FIRE,PBTypes::WATER,PBTypes::ICE,PBTypes::FAIRY
      return 4
    when PBTypes::ROCK
      return 8
    when PBTypes::NORMAL,PBTypes::FIGHTING,PBTypes::POISON,PBTypes::GROUND,PBTypes::GHOST,PBTypes::ELECTRIC,PBTypes::PSYCHIC,PBTypes::DRAGON
      if movetype==PBTypes::GROUND && @field.effects[PBEffects::Gravity]>0
        return 32
      elsif movetype==PBTypes::NORMAL && (attacker.hasWorkingAbility(:SCRAPPY) ||
          opponent.effects[PBEffects::Foresight])
        return 1
      elsif (movetype==PBTypes::FIGHTING && (attacker.hasWorkingAbility(:SCRAPPY) ||
          opponent.effects[PBEffects::Foresight])) ||
          (movetype==PBTypes::PSYCHIC && opponent.effects[PBEffects::MiracleEye])
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
  
  def pbTypeModOmnitype(move,attacker,opponent,movetype)
    debugTypeMod=false
    Kernel.pbMessage("Get TypeModOmni 1") if debugTypeMod
    mod=pbTypeModOmnitypeInitial(move,attacker,opponent,movetype)
    Kernel.pbMessage("Get TypeModOmni 2") if debugTypeMod
    return mod
  end
  
  def pbTypeModMove(move,attacker,opponent)
    debugTypeMod=false
    Kernel.pbMessage("Get TypeModMove 1") if debugTypeMod
    omnitype=false
    movetype=move.type
    
    #movetype=move.pbType(type,attacker,opponent)
    if isConst?(movetype,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:REFRIGERATE)
      movetype=getConst(PBTypes,:ICE)
    elsif isConst?(movetype,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:PIXILATE)
      movetype=getConst(PBTypes,:FAIRY)
    elsif isConst?(movetype,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:AERILATE)
      movetype=getConst(PBTypes,:FLYING)
    elsif isConst?(movetype,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:INTOXICATE)
      movetype=getConst(PBTypes,:POISON)
    elsif isConst?(movetype,PBTypes,:ROCK) && attacker.hasWorkingAbility(:FOUNDRY)
      movetype=getConst(PBTypes,:FIRE)
    end

    if opponent.hasWorkingAbility(:OMNITYPE) && !attacker.hasWorkingAbility(:ANCIENTPRESENCE)
      typemod=pbTypeModOmnitype(move,attacker,opponent,movetype)
      omnitype=true
    else
      typemod=pbTypeModifier(movetype,attacker,opponent)
      omnitype=false
    end
    Kernel.pbMessage("Get TypeModMove 2") if debugTypeMod
    if !attacker.hasWorkingAbility(:ANCIENTPRESENCE)
    Kernel.pbMessage("Get TypeModMove 3") if debugTypeMod
      if isConst?(move.id,PBMoves,:ACHILLESHEEL)
        mod1=PBTypes.getEffectiveness(movetype,opponent.type1)
        mod2=PBTypes.getEffectiveness(movetype,opponent.type2)
        if mod1==0 || mod2==0 || omnitype
          typemod=pbTypeInverse(0)
        else
          typemod=pbTypeInverse(8)
        end
      end
    Kernel.pbMessage("Get TypeModMove 4") if debugTypeMod
      if isConst?(move.id,PBMoves,:CORRODE)
        return 4 if isConst?(opponent.type1,PBTypes,:STEEL) && omnitype
        if !omnitype && isConst?(opponent.type2,PBTypes,:STEEL)
          mod1=PBTypes.getEffectiveness(movetype,opponent.type1)
          mod2=(opponent.type1==opponent.type2) ? 2 : PBTypes.getEffectiveness(movetype,opponent.type2)
          mod1=4 if isConst?(opponent.type1,PBTypes,:STEEL)
          mod2=4 if isConst?(opponent.type2,PBTypes,:STEEL)
          typemod=pbTypeInverse(mod1*mod2)
        end
      end
    Kernel.pbMessage("Get TypeModMove 5") if debugTypeMod
      if isConst?(move.id,PBMoves,:FREEZEDRY)
        if (opponent.pbHasType?(PBTypes::WATER) && 
           !attacker.effects[PBEffects::Electrify] && 
           !@field.effects[PBEffects::IonDeluge]) || omnitype
          if !$game_switches[302]
            typemod*=4
          else
            typemod=8
          end
        end
      end
    Kernel.pbMessage("Get TypeModMove 6") if debugTypeMod
      if isConst?(move.id,PBMoves,:THOUSANDARROWS) && !omnitype &&
         !opponent.effects[PBEffects::SmackDown]
        return 4 if isConst?(opponent.type1,PBTypes,:FLYING)
        return 4 if isConst?(opponent.type2,PBTypes,:FLYING)
      end
    end
    Kernel.pbMessage("Get TypeModMove 7") if debugTypeMod
    retvar=pbTypeInverse(typemod)
    return retvar
  end
  
  def pbTypeInverse(mod)
    if $game_switches[302]
      case mod
      when 32
        retvar=0
      when 16
        retvar=1
      when 8
        retvar=2
      when 2
        retvar=8
      when 1
        retvar=16
      when 0
        retvar=8
      else
        retvar=4
      end
    else 
      retvar=mod
    end
    return retvar
  end

  def pbTypeModifier2(battlerThis,battlerOther)
    debugTypeMod=false
    Kernel.pbMessage("TypeMod2 1") if debugTypeMod
    # battlerThis isn't a Battler object, it's a Pokémon - it has no third type
    if battlerThis.type1==battlerThis.type2
    Kernel.pbMessage("TypeMod2 2") if debugTypeMod
      return 4*pbTypeModifier(battlerThis.type1,battlerThis,battlerOther)
    end
    ret=pbTypeModifier(battlerThis.type1,battlerThis,battlerOther)
    Kernel.pbMessage("TypeMod2 3") if debugTypeMod
    ret*=pbTypeModifier(battlerThis.type2,battlerThis,battlerOther)
    Kernel.pbMessage("TypeMod2 4") if debugTypeMod
    return ret # 0,1,2,4,8,_16_,32,64,128,256
  end

  def pbRoughStat(battler,stat,skill,unaware=false)
    debugRoughStat=false
    Kernel.pbMessage("Get roughstat 1") if debugRoughStat
    return battler.pbSpeed if skill>=PBTrainerAI.highSkill && stat==PBStats::SPEED
    Kernel.pbMessage("Get roughstat 2") if debugRoughStat
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    stage=battler.stages[stat]+6
    if unaware && (stat==PBStats::DEFENSE || stat==PBStats::SPDEF)
      stage=6
    end
    if unaware && (stat==PBStats::ATTACK || stat==PBStats::SPATK)
      stage=6
    end
    Kernel.pbMessage("Get roughstat 3") if debugRoughStat
    value=0
    value=battler.attack if stat==PBStats::ATTACK
    value=battler.defense if stat==PBStats::DEFENSE
    value=battler.speed if stat==PBStats::SPEED
    value=battler.spatk if stat==PBStats::SPATK
    value=battler.spdef if stat==PBStats::SPDEF
    Kernel.pbMessage("Get roughstat 4") if debugRoughStat
    return (value*1.0*stagemul[stage]/stagediv[stage]).floor
  end
  
  def pbBetterBaseDamage(move,attacker,opponent,skill,basedamage)
    #Kernel.pbMessage("Get better base damage 1")
    # Covers all function codes which have their own def pbBaseDamage
    case move.function
    when 0x00
      if move.id == PBMoves::FLYINGPRESS
        typemod=pbTypeModMove(move,attacker,opponent)
        typemod2=pbTypeModifier(PBTypes::FLYING,attacker,opponent)
        typemod3=(typemod+typemod2)/2
        typemod3= 2 if typemod3==3
        typemod3= 8 if typemod3==6
        typemod=typemod3
        damagemult=(typemod3/4).floor
        basedamage*=damagemult
      end
    when 0x6A # SonicBoom
      basedamage=20
    when 0x6B # Dragon Rage
      basedamage=40
    when 0x6C # Super Fang
      basedamage=(opponent.hp/2).floor
    when 0x6D # Night Shade
      basedamage=attacker.level
    when 0x6E # Endeavor
      basedamage=opponent.hp-attacker.hp
    when 0x6F # Psywave
      basedamage=attacker.level
    when 0x70 # OHKO
      basedamage=opponent.totalhp
    when 0x71 # Counter
      basedamage=60
    when 0x72 # Mirror Coat
      basedamage=60
    when 0x73 # Metal Burst
      basedamage=60
    when 0x75, 0x12D # Surf, Shadow Storm
      basedamage*=1.5 if pbWeather==PBWeather::NEWMOON
      basedamage*=2 if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCB # Dive
    when 0x76 # Earthquake
      basedamage*=2 if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCA # Dig
    when 0x77, 0x78 # Gust, Twister
      basedamage*=2 if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
                       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC || # Bounce
                       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCE    # Sky Drop
    when 0x7B # Venoshock
      basedamage*=2 if opponent.status==PBStatuses::POISON
    when 0x7C # SmellingSalt
      basedamage*=2 if opponent.status==PBStatuses::PARALYSIS
    when 0x7D # Wake-Up Slap
      basedamage*=2 if opponent.status==PBStatuses::SLEEP
    when 0x7E # Facade
      basedamage*=2 if attacker.status==PBStatuses::POISON ||
                       attacker.status==PBStatuses::BURN ||
                       attacker.status==PBStatuses::PARALYSIS
    when 0x7F # Hex
      basedamage*=2 if opponent.status!=0
    when 0x80 # Brine
      basedamage*=2 if opponent.hp<=(opponent.totalhp/2).floor
    when 0x85 # Retaliate
      # TODO
    when 0x86 # Acrobatics
      basedamage*=2 if attacker.item==0 || attacker.hasWorkingItem(:FLYINGGEM)
    when 0x87 # Weather Ball
      basedamage*=2 if pbWeather!=0
    when 0x89 # Return
      basedamage=[(attacker.happiness*2/5).floor,1].max
    when 0x8A # Frustration
      basedamage=[((255-attacker.happiness)*2/5).floor,1].max
    when 0x8B # Eruption
      basedamage=[(150*attacker.hp/attacker.totalhp).floor,1].max
    when 0x8C # Crush Grip
      basedamage=[(120*opponent.hp/opponent.totalhp).floor,1].max
    when 0x8D # Gyro Ball
      ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
      aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
      basedamage=[[(25*ospeed/aspeed).floor,150].min,1].max
    when 0x8E # Stored Power
      mult=0
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
        mult+=attacker.stages[i] if attacker.stages[i]>0
      end
      basedamage=20*(mult+1)
    when 0x8F # Punishment
      mult=0
      for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
        mult+=opponent.stages[i] if opponent.stages[i]>0
      end
      basedamage=[20*(mult+3),200].min
    when 0x90 # Hidden Power
      hp=pbHiddenPower(attacker.iv)
      basedamage=hp[1]
    when 0x91 # Fury Cutter
      basedamage=basedamage<<(attacker.effects[PBEffects::FuryCutter]-1)
    when 0x92 # Echoed Voice
      basedamage*=attacker.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]
    when 0x94 # Present
      basedamage=50
    when 0x95 # Magnitude
      basedamage=71
      basedamage*=2 if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCA # Dig
    when 0x96 # Natural Gift
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
                :ENIGMABERRY,:MICLEBERRY,:CUSTAPBERRY,:JABOCABERRY,:ROWAPBERRY,
                :KEEBERRY,:MARANGABERRY]
      }
      haveanswer=false
      for i in damagearray.keys
        data=damagearray[i]
        if data
          for j in data
            if isConst?(attacker.item,PBItems,j)
              basedamage=i; haveanswer=true; break
            end
          end
        end
        break if haveanswer
      end
    when 0x97 # Trump Card
      dmgs=[200,80,60,50,40]
      ppleft=[move.pp-1,4].min   # PP is reduced before the move is used
      basedamage=dmgs[ppleft]
    when 0x98 # Flail
      n=(48*attacker.hp/attacker.totalhp).floor
      basedamage=20
      basedamage=40 if n<33
      basedamage=80 if n<17
      basedamage=100 if n<10
      basedamage=150 if n<5
      basedamage=200 if n<2
    when 0x99 # Electro Ball
      n=(attacker.pbSpeed/opponent.pbSpeed).floor
      basedamage=40
      basedamage=60 if n>=1
      basedamage=80 if n>=2
      basedamage=120 if n>=3
      basedamage=150 if n>=4
    when 0x9A # Low Kick
      weight=opponent.weight(attacker)
      basedamage=20
      basedamage=40 if weight>100
      basedamage=60 if weight>250
      basedamage=80 if weight>500
      basedamage=100 if weight>1000
      basedamage=120 if weight>2000
    when 0x9B # Heavy Slam
      n=(attacker.weight/opponent.weight(attacker)).floor
      basedamage=40
      basedamage=60 if n>=2
      basedamage=80 if n>=3
      basedamage=100 if n>=4
      basedamage=120 if n>=5
    when 0xA0 # Frost Breath
      basedamage*=2 if !opponent.hasWorkingAbility(:BATTLEARMOR) &&
                       !opponent.hasWorkingAbility(:SHELLARMOR) &&
                       opponent.pbOwnSide.effects[PBEffects::LuckyChant]==0
    when 0xBD, 0xBE # Double Kick, Twineedle
      basedamage*=2
    when 0xBF # Triple Kick
      basedamage*=6
    when 0xC0 # Fury Attack
      if attacker.hasWorkingAbility(:SKILLLINK)
        basedamage*=5
      else
        basedamage=(basedamage*19/6).floor
      end
    when 0xC1 # Beat Up
      party=pbParty(attacker.index)
      mult=0
      for i in 0...party.length
        mult+=1 if party[i] && !party[i].egg? &&
                   party[i].hp>0 && party[i].status==0
      end
      basedamage*=mult
    when 0xC4 # SolarBeam
      if pbWeather!=0 && pbWeather==PBWeather::NEWMOON
        basedamage=(basedamage*0.25).floor
      elsif pbWeather!=0 && pbWeather!=PBWeather::SUNNYDAY && 
            pbWeather!=PBWeather::HARSHSUN
        basedamage=(basedamage*0.5).floor
      end
    when 0xD0 # Whirlpool
      if skill>=PBTrainerAI.mediumSkill
        basedamage*=2 if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCB # Dive
      end
    when 0xD3 # Rollout
      if skill>=PBTrainerAI.mediumSkill
        basedamage*=2 if attacker.effects[PBEffects::DefenseCurl]
      end
    when 0xE1 # Final Gambit
      basedamage=attacker.hp
    when 0xF7 # Fling
      damagearray={
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
      
      haveanswer=false
      for i in damagearray.keys
        data=damagearray[i]
        if data
          for j in data
            if isConst?(attacker.item,PBItems,j)
              basedamage=i; haveanswer=true; break
            elsif pbIsBerry?(attacker.item)
              basedamage=10; haveanswer=true; break
            end
          end
        end
        break if haveanswer
      end
    when 0x113 # Spit Up
      basedamage*=attacker.effects[PBEffects::Stockpile]
    when 0x138 # Lunar Cannon
      if pbWeather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN
        basedamage=(basedamage*0.5).floor
      end
    when 0x215 # Dynamic Fury
      basedamage*=attacker.effects[PBEffects::SynergyBurst]
    when 0x216 # Aura Blast
      basedamage*=(attacker.effects[PBEffects::AuraBlastCharges]+1)
    when 0x217 # Dark Nova
      basedamage*=2
    end
    #Kernel.pbMessage("Get better base damage 2")
    return basedamage
  end
  
  def pbRoughDamage(move,attacker,opponent,skill,basedamage)
    debugRoughDamage=false
    Kernel.pbMessage("Get rough damage 1") if debugRoughDamage
    # Fixed damage moves
    return basedamage if move.function==0x6A ||   # SonicBoom
                         move.function==0x6B ||   # Dragon Rage
                         move.function==0x6C ||   # Super Fang
                         move.function==0x6D ||   # Night Shade
                         move.function==0x6E ||   # Endeavor
                         move.function==0x6F ||   # Psywave
                         move.function==0x70 ||   # OHKO
                         move.function==0x71 ||   # Counter
                         move.function==0x72 ||   # Mirror Coat
                         move.function==0x73 ||   # Metal Burst
                         move.function==0xE1      # Final Gambit
    Kernel.pbMessage("Get rough damage 2") if debugRoughDamage
    type=move.type
    ateAbility=false
    # More accurate move type (includes Normalize, most type-changing moves, etc.)
    if skill>=PBTrainerAI.highSkill
      type=move.pbType(type,attacker,opponent)
      if isConst?(type,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:REFRIGERATE)
        type=getConst(PBTypes,:ICE)
        ateAbility=true
      elsif isConst?(type,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:PIXILATE)
        type=getConst(PBTypes,:FAIRY)
        ateAbility=true
      elsif isConst?(type,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:AERILITE)
        type=getConst(PBTypes,:FLYING)
        ateAbility=true
      elsif isConst?(type,PBTypes,:NORMAL) && attacker.hasWorkingAbility(:INTOXICATE)
        type=getConst(PBTypes,:POISON)
        ateAbility=true
      elsif isConst?(type,PBTypes,:ROCK) && attacker.hasWorkingAbility(:FOUNDRY)
        type=getConst(PBTypes,:FIRE)
        ateAbility=true
      end
    end
    Kernel.pbMessage("Get rough damage 3") if debugRoughDamage
    # Type-changing ability boosts
    if skill>=PBTrainerAI.highSkill
      if ateAbility
        damage=(basedamage*1.3).round
      end
    end
    Kernel.pbMessage("Get rough damage 4") if debugRoughDamage
    # Minimize boost
    if skill>=PBTrainerAI.highSkill
      if opponent.effects[PBEffects::Minimize] && move.tramplesMinimize?(2)
        basedamage=(basedamage*2.0).round
      end
    end
    Kernel.pbMessage("Get rough damage 5") if debugRoughDamage
    # Technician
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:TECHNICIAN) && basedamage<=60
        basedamage=(basedamage*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 6") if debugRoughDamage
    # Iron Fist
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:IRONFIST) && move.isPunchingMove?
        basedamage=(basedamage*1.2).round
      end
    end
    Kernel.pbMessage("Get rough damage 7") if debugRoughDamage
    # Amplifier
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:AMPLIFIER) && move.isSoundBased?
        basedamage=(basedamage*1.25).round
      end
    end
    Kernel.pbMessage("Get rough damage 8") if debugRoughDamage
    # Reckless
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:RECKLESS)
        if @function==0xFA ||  # Take Down, etc.
           @function==0xFB ||  # Double-Edge, etc.
           @function==0xFC ||  # Head Smash
           @function==0xFD ||  # Volt Tackle
           @function==0xFE ||  # Flare Blitz
           @function==0x10B || # Jump Kick, Hi Jump Kick
           @function==0x130    # Shadow End
          basedamage=(basedamage*1.2).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 9") if debugRoughDamage
    # Flare Boost
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:FLAREBOOST) &&
         attacker.status==PBStatuses::BURN && move.pbIsSpecial?(type)
        basedamage=(basedamage*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 10") if debugRoughDamage
    # Toxic Boost
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:TOXICBOOST) &&
         attacker.status==PBStatuses::POISON && move.pbIsPhysical?(type)
        basedamage=(basedamage*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 11") if debugRoughDamage
    # Analytic
    if skill>=PBTrainerAI.bestSkill
      if attacker.hasWorkingAbility(:ANALYTIC) && !move.pbIsStatus?
        for i in 0...4
          if !@battlers[i].fainted?
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(@battlers[i],PBStats::SPEED,skill)
            fasterPokes=false
            if (aspeed>ospeed && move.priority==0) || move.priority>0
              fasterPokes=true
              break
            end
          end
        end
        if !fasterPokes
          basedamage=(basedamage*1.3).round
        end
      end
    end
    # Rivalry
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:RIVALRY) &&
         attacker.gender!=2 && opponent.gender!=2
        if attacker.gender==opponent.gender
          basedamage=(basedamage*1.25).round
        else
          basedamage=(basedamage*0.75).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 12") if debugRoughDamage
    # Sand Force
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:SANDFORCE) &&
         pbWeather==PBWeather::SANDSTORM &&
         (isConst?(type,PBTypes,:ROCK) ||
         isConst?(type,PBTypes,:GROUND) ||
         isConst?(type,PBTypes,:STEEL))
        basedamage=(basedamage*1.3).round
      end
    end
    Kernel.pbMessage("Get rough damage 13") if debugRoughDamage
    # Heatproof
    if skill>=PBTrainerAI.bestSkill
      if opponent.hasWorkingAbility(:HEATPROOF) &&
         isConst?(type,PBTypes,:FIRE)
        basedamage=(basedamage*0.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 14") if debugRoughDamage
    # Dry Skin
    if skill>=PBTrainerAI.bestSkill
      if opponent.hasWorkingAbility(:DRYSKIN) &&
         isConst?(type,PBTypes,:FIRE)
        basedamage=(basedamage*1.25).round
      end
    end
    Kernel.pbMessage("Get rough damage 15") if debugRoughDamage
    # Sheer Force
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:SHEERFORCE) && move.addlEffect>0
        basedamage=(basedamage*1.3).round
      end
    end
    Kernel.pbMessage("Get rough damage 16") if debugRoughDamage
    # Type-boosting items
    if (attacker.hasWorkingItem(:SILKSCARF) && isConst?(type,PBTypes,:NORMAL)) ||
       (attacker.hasWorkingItem(:BLACKBELT) && isConst?(type,PBTypes,:FIGHTING)) ||
       (attacker.hasWorkingItem(:SHARPBEAK) && isConst?(type,PBTypes,:FLYING)) ||
       (attacker.hasWorkingItem(:POISONBARB) && isConst?(type,PBTypes,:POISON)) ||
       (attacker.hasWorkingItem(:SOFTSAND) && isConst?(type,PBTypes,:GROUND)) ||
       (attacker.hasWorkingItem(:HARDSTONE) && isConst?(type,PBTypes,:ROCK)) ||
       (attacker.hasWorkingItem(:SILVERPOWDER) && isConst?(type,PBTypes,:BUG)) ||
       (attacker.hasWorkingItem(:SPELLTAG) && isConst?(type,PBTypes,:GHOST)) ||
       (attacker.hasWorkingItem(:METALCOAT) && isConst?(type,PBTypes,:STEEL)) ||
       (attacker.hasWorkingItem(:CHARCOAL) && isConst?(type,PBTypes,:FIRE)) ||
       (attacker.hasWorkingItem(:MYSTICWATER) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingItem(:MIRACLESEED) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingItem(:MAGNET) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (attacker.hasWorkingItem(:TWISTEDSPOON) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (attacker.hasWorkingItem(:NEVERMELTICE) && isConst?(type,PBTypes,:ICE)) ||
       (attacker.hasWorkingItem(:DRAGONFANG) && isConst?(type,PBTypes,:DRAGON)) ||
       (attacker.hasWorkingItem(:BLACKGLASSES) && isConst?(type,PBTypes,:DARK))
      basedamage=(basedamage*1.2).round
    end
    Kernel.pbMessage("Get rough damage 17") if debugRoughDamage
    if (attacker.hasWorkingItem(:FISTPLATE) && isConst?(type,PBTypes,:FIGHTING)) ||
       (attacker.hasWorkingItem(:SKYPLATE) && isConst?(type,PBTypes,:FLYING)) ||
       (attacker.hasWorkingItem(:TOXICPLATE) && isConst?(type,PBTypes,:POISON)) ||
       (attacker.hasWorkingItem(:EARTHPLATE) && isConst?(type,PBTypes,:GROUND)) ||
       (attacker.hasWorkingItem(:STONEPLATE) && isConst?(type,PBTypes,:ROCK)) ||
       (attacker.hasWorkingItem(:INSECTPLATE) && isConst?(type,PBTypes,:BUG)) ||
       (attacker.hasWorkingItem(:SPOOKYPLATE) && isConst?(type,PBTypes,:GHOST)) ||
       (attacker.hasWorkingItem(:IRONPLATE) && isConst?(type,PBTypes,:STEEL)) ||
       (attacker.hasWorkingItem(:FLAMEPLATE) && isConst?(type,PBTypes,:FIRE)) ||
       (attacker.hasWorkingItem(:SPLASHPLATE) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingItem(:MEADOWPLATE) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingItem(:ZAPPLATE) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (attacker.hasWorkingItem(:MINDPLATE) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (attacker.hasWorkingItem(:ICICLEPLATE) && isConst?(type,PBTypes,:ICE)) ||
       (attacker.hasWorkingItem(:DRACOPLATE) && isConst?(type,PBTypes,:DRAGON)) ||
       (attacker.hasWorkingItem(:DREADPLATE) && isConst?(type,PBTypes,:DARK)) ||
       (attacker.hasWorkingItem(:PIXIEPLATE) && isConst?(type,PBTypes,:FAIRY))
      basedamage=(basedamage*1.2).round
    end
    Kernel.pbMessage("Get rough damage 18") if debugRoughDamage
    if (attacker.hasWorkingItem(:NORMALGEM) && isConst?(type,PBTypes,:NORMAL)) ||
       (attacker.hasWorkingItem(:FIGHTINGGEM) && isConst?(type,PBTypes,:FIGHTING)) ||
       (attacker.hasWorkingItem(:FLYINGGEM) && isConst?(type,PBTypes,:FLYING)) ||
       (attacker.hasWorkingItem(:POISONGEM) && isConst?(type,PBTypes,:POISON)) ||
       (attacker.hasWorkingItem(:GROUNDGEM) && isConst?(type,PBTypes,:GROUND)) ||
       (attacker.hasWorkingItem(:ROCKGEM) && isConst?(type,PBTypes,:ROCK)) ||
       (attacker.hasWorkingItem(:BUGGEM) && isConst?(type,PBTypes,:BUG)) ||
       (attacker.hasWorkingItem(:GHOSTGEM) && isConst?(type,PBTypes,:GHOST)) ||
       (attacker.hasWorkingItem(:STEELGEM) && isConst?(type,PBTypes,:STEEL)) ||
       (attacker.hasWorkingItem(:FIREGEM) && isConst?(type,PBTypes,:FIRE)) ||
       (attacker.hasWorkingItem(:WATERGEM) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingItem(:GRASSGEM) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingItem(:ELECTRICGEM) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (attacker.hasWorkingItem(:PSYCHICGEM) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (attacker.hasWorkingItem(:ICEGEM) && isConst?(type,PBTypes,:ICE)) ||
       (attacker.hasWorkingItem(:DRAGONGEM) && isConst?(type,PBTypes,:DRAGON)) ||
       (attacker.hasWorkingItem(:DARKGEM) && isConst?(type,PBTypes,:DARK)) ||
       (attacker.hasWorkingItem(:FAIRYGEM) && isConst?(type,PBTypes,:FAIRY))
      basedamage=(basedamage*1.3).round
    end
    Kernel.pbMessage("Get rough damage 19") if debugRoughDamage
    if attacker.hasWorkingItem(:ROCKINCENSE) && isConst?(type,PBTypes,:ROCK)
      basedamage=(basedamage*1.2).round
    end
    if attacker.hasWorkingItem(:ROSEINCENSE) && isConst?(type,PBTypes,:GRASS)
      basedamage=(basedamage*1.2).round
    end
    if attacker.hasWorkingItem(:SEAINCENSE) && isConst?(type,PBTypes,:WATER)
      basedamage=(basedamage*1.2).round
    end
    if attacker.hasWorkingItem(:WAVEINCENSE) && isConst?(type,PBTypes,:WATER)
      basedamage=(basedamage*1.2).round
    end
    if attacker.hasWorkingItem(:ODDINCENSE) && isConst?(type,PBTypes,:PSYCHIC)
      basedamage=(basedamage*1.2).round
    end
    Kernel.pbMessage("Get rough damage 20") if debugRoughDamage
    # Muscle Band
    if attacker.hasWorkingItem(:MUSCLEBAND) && move.pbIsPhysical?(type)
      basedamage=(basedamage*1.1).round
    end
    # Wise Glasses
    if attacker.hasWorkingItem(:WISEGLASSES) && move.pbIsSpecial?(type)
      basedamage=(basedamage*1.1).round
    end
    Kernel.pbMessage("Get rough damage 21") if debugRoughDamage
    # Legendary Orbs
    if isConst?(attacker.species,PBSpecies,:PALKIA) &&
       attacker.hasWorkingItem(:LUSTROUSORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:WATER))
      basedamage=(basedamage*1.2).round
    end
    if isConst?(attacker.species,PBSpecies,:DIALGA) &&
       attacker.hasWorkingItem(:ADAMANTORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:STEEL))
      basedamage=(basedamage*1.2).round
    end
    if isConst?(attacker.species,PBSpecies,:GIRATINA) &&
       attacker.hasWorkingItem(:GRISEOUSORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:GHOST))
      basedamage=(basedamage*1.2).round
    end
    Kernel.pbMessage("Get rough damage 22") if debugRoughDamage
    # pbBaseDamageMultiplier - TODO
    # Me First
    # Charge
    if attacker.effects[PBEffects::Charge]>0 && isConst?(type,PBTypes,:ELECTRIC)
      basedamage=(basedamage*2.0).round
    end
    Kernel.pbMessage("Get rough damage 23") if debugRoughDamage
    # Helping Hand - n/a
    # Water Sport
    if skill>=PBTrainerAI.mediumSkill
      if isConst?(type,PBTypes,:FIRE)
        for i in 0...4
          if @field.effects[PBEffects::WaterSportField]>0 && !@battlers[i].fainted?
            basedamage=(basedamage*0.33).round
            break
          end
        end
      end
    end
    Kernel.pbMessage("Get rough damage 24") if debugRoughDamage
    # Mud Sport
    if skill>=PBTrainerAI.mediumSkill
      if isConst?(type,PBTypes,:ELECTRIC)
        for i in 0...4
          if @field.effects[PBEffects::MudSportField]>0 && !@battlers[i].fainted?
            basedamage=(basedamage*0.33).round
            break
          end
        end
      end
    end
    Kernel.pbMessage("Get rough damage 25") if debugRoughDamage
    # Get base attack stat
    atk=pbRoughStat(attacker,PBStats::ATTACK,skill,opponent.hasWorkingAbility(:UNAWARE))
    if move.function==0x121 # Foul Play
      atk=pbRoughStat(opponent,PBStats::ATTACK,skill)
    end
    if type>=0 && move.pbIsSpecial?(type)
      atk=pbRoughStat(attacker,PBStats::SPATK,skill,opponent.hasWorkingAbility(:UNAWARE))
      if move.function==0x121 # Foul Play
        atk=pbRoughStat(opponent,PBStats::SPATK,skill)
      end
    end
    Kernel.pbMessage("Get rough damage 26") if debugRoughDamage
    # Hustle
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:HUSTLE) && move.pbIsPhysical?(type)
        atk=(atk*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 27") if debugRoughDamage
    # Thick Fat
    if skill>=PBTrainerAI.bestSkill
      if opponent.hasWorkingAbility(:THICKFAT) &&
         (isConst?(type,PBTypes,:ICE) || isConst?(type,PBTypes,:FIRE))
        atk=(atk*0.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 28") if debugRoughDamage
    # Pinch abilities
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hp<=(attacker.totalhp/3).floor
        if (attacker.hasWorkingAbility(:OVERGROW) && isConst?(type,PBTypes,:GRASS)) ||
           (attacker.hasWorkingAbility(:BLAZE) && isConst?(type,PBTypes,:FIRE)) ||
           (attacker.hasWorkingAbility(:TORRENT) && isConst?(type,PBTypes,:WATER)) ||
           (attacker.hasWorkingAbility(:SWARM) && isConst?(type,PBTypes,:BUG)) ||
           (attacker.hasWorkingAbility(:PSYCHOCALL) && isConst?(type,PBTypes,:PSYCHIC)) ||
           (attacker.hasWorkingAbility(:SPIRITCALL) && isConst?(type,PBTypes,:GHOST)) ||
           (attacker.hasWorkingAbility(:SHADOWCALL) && isConst?(type,PBTypes,:DARK))
          atk=(atk*1.5).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 29") if debugRoughDamage
    # Aura abilities
    if skill>=PBTrainerAI.mediumSkill
      if (pbCheckGlobalAbility(:DARKAURA) && isConst?(type,PBTypes,:DARK)) ||
       (pbCheckGlobalAbility(:FAIRYAURA) && isConst?(type,PBTypes,:FAIRY))
        if pbCheckGlobalAbility(:AURABREAK) && pbWeather!=PBWeather::NEWMOON
          atk=(atk*3/4).round
        elsif pbCheckGlobalAbility(:AURABREAK) && pbWeather==PBWeather::NEWMOON
          if (pbCheckGlobalAbility(:DARKAURA) && isConst?(type,PBTypes,:DARK))
            atk=(atk*3/5).round
          end
        elsif !pbCheckGlobalAbility(:AURABREAK) && pbWeather==PBWeather::NEWMOON
          if (pbCheckGlobalAbility(:DARKAURA) && isConst?(type,PBTypes,:DARK))
            atk=(atk*5/3).round
          end
        else
          atk=(atk*4/3).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 30") if debugRoughDamage
    # Guts
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:GUTS) &&
         attacker.status!=0 && move.pbIsPhysical?(type)
        atk=(atk*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 31") if debugRoughDamage
    # Plus, Minus
    if skill>=PBTrainerAI.mediumSkill
      if (attacker.hasWorkingAbility(:PLUS) ||
         attacker.hasWorkingAbility(:MINUS)) && move.pbIsSpecial?(type)
        partner=attacker.pbPartner
        if partner.hasWorkingAbility(:PLUS) || partner.hasWorkingAbility(:MINUS)
          atk=(atk*1.5).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 32") if debugRoughDamage
    # Defeatist
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:DEFEATIST) &&
         attacker.hp<=(attacker.totalhp/2).floor
        atk=(atk*0.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 33") if debugRoughDamage
    # Pure Power, Huge Power
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:PUREPOWER) ||
         attacker.hasWorkingAbility(:HUGEPOWER)
        atk=(atk*2.0).round
      end
    end
    Kernel.pbMessage("Get rough damage 34") if debugRoughDamage
    # Athenian
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:ATHENIAN) && move.pbIsSpecial?(type)
        atk=(atk*2.0).round
      end
    end
    Kernel.pbMessage("Get rough damage 35") if debugRoughDamage
    # Winter Joy
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:WINTERJOY)
        pbIsMonth(1)
        if $game_variables[1]=="November" ||
           $game_variables[1]=="December" ||
           $game_variables[1]=="January" ||
           $game_variables[1]=="February"
          atk=(atk*1.4).round
        end
        if $game_variables[1]=="May" ||
           $game_variables[1]=="June" ||
           $game_variables[1]=="July" ||
           $game_variables[1]=="August"
          atk=(atk*0.7).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 36") if debugRoughDamage
    # Solar Power
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:SOLARPOWER) &&
         (pbWeather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN)  && 
         move.pbIsSpecial?(type)
        atk=(atk*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 37") if debugRoughDamage
    # Absolution
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:ABSOLUTION) &&
         pbWeather==PBWeather::NEWMOON && move.pbIsSpecial?(type)
        atk=(atk*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 38") if debugRoughDamage
    # Flash Fire
    if skill>=PBTrainerAI.highSkill
      if attacker.hasWorkingAbility(:FLASHFIRE) &&
         attacker.effects[PBEffects::FlashFire] && isConst?(type,PBTypes,:FIRE)
        atk=(atk*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 39") if debugRoughDamage
    # Slow Start
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:SLOWSTART) &&
         attacker.turncount<5 && move.pbIsPhysical?(type)
        atk=(atk*0.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 40") if debugRoughDamage
    # Flower Gift
    if skill>=PBTrainerAI.highSkill
      if (pbWeather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN) && 
         move.pbIsPhysical?(type)
        if attacker.hasWorkingAbility(:FLOWERGIFT)
          atk=(atk*1.5).round
        end
        if attacker.pbPartner.hasWorkingAbility(:FLOWERGIFT)
          atk=(atk*1.5).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 41") if debugRoughDamage
    # Supercell
    if skill>=PBTrainerAI.highSkill
      if (pbWeather==PBWeather::RAINDANCE || pbWeather==PBWeather::HEAVYRAIN ||
         pbWeather==PBWeather::NEWMOON) && move.pbIsSpecial?(type)
        if attacker.hasWorkingAbility(:SUPERCELL)
          atk=(atk*1.5).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 42") if debugRoughDamage
    # Attack-boosting items
    if attacker.hasWorkingItem(:THICKCLUB) &&
       (isConst?(attacker.species,PBSpecies,:CUBONE) ||
       isConst?(attacker.species,PBSpecies,:MAROWAK)) && move.pbIsPhysical?(type)
      atk=(atk*2.0).round
    end
    if attacker.hasWorkingItem(:DEEPSEATOOTH) &&
       isConst?(attacker.species,PBSpecies,:CLAMPERL) && move.pbIsSpecial?(type)
      atk=(atk*2.0).round
    end
    if attacker.hasWorkingItem(:DRAGONFANG) &&
       isConst?(attacker.species,PBSpecies,:DELTACLAMPERL) && move.pbIsPhysical?(type)
      atk=(atk*2.0).round
    end
    if attacker.hasWorkingItem(:LIGHTBALL) &&
       isConst?(attacker.species,PBSpecies,:PIKACHU) || 
       isConst?(attacker.species,PBSpecies,:DELTAPIKACHU)
      atk=(atk*2.0).round
    end
    if attacker.hasWorkingItem(:SOULDEW) &&
       (isConst?(attacker.species,PBSpecies,:LATIAS) ||
       isConst?(attacker.species,PBSpecies,:LATIOS)) && move.pbIsSpecial?(type)
      atk=(atk*1.5).round
    end
    if attacker.hasWorkingItem(:CHOICEBAND) && move.pbIsPhysical?(type)
      atk=(atk*1.5).round
    end
    if attacker.hasWorkingItem(:CHOICESPECS) && move.pbIsSpecial?(type)
      atk=(atk*1.5).round
    end
    Kernel.pbMessage("Get rough damage 43") if debugRoughDamage
    # Get base defense stat
    defense=pbRoughStat(opponent,PBStats::DEFENSE,skill,attacker.hasWorkingAbility(:UNAWARE))
    applysandstorm=false
    if type>=0 && move.pbIsSpecial?(type)
      if move.function!=0x122 # Psyshock
        defense=pbRoughStat(opponent,PBStats::SPDEF,skill,attacker.hasWorkingAbility(:UNAWARE))
        applysandstorm=true
      end
    elsif type>=0 && attacker.hasWorkingAbility(:SPECTRALJAWS) 
      if move.isBitingMove?
        defense=pbRoughStat(opponent,PBStats::DEFENSE,skill,attacker.hasWorkingAbility(:UNAWARE))
        applysandstorm=false
      end
    end
    Kernel.pbMessage("Get rough damage 44") if debugRoughDamage
    # Sandstorm weather
    if skill>=PBTrainerAI.highSkill
      if pbWeather==PBWeather::SANDSTORM &&
         opponent.pbHasType?(:ROCK) && applysandstorm
        defense=(defense*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 45") if debugRoughDamage
    # Marvel Scale
    if skill>=PBTrainerAI.bestSkill
      if opponent.hasWorkingAbility(:MARVELSCALE) &&
         opponent.status>0 && move.pbIsPhysical?(type)
        defense=(defense*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 46") if debugRoughDamage
    # Flower Gift
    if skill>=PBTrainerAI.bestSkill
      if (pbWeather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN) && 
         move.pbIsSpecial?(type)
        if opponent.hasWorkingAbility(:FLOWERGIFT)
          defense=(defense*1.5).round
        end
        if opponent.pbPartner.hasWorkingAbility(:FLOWERGIFT)
          defense=(defense*1.5).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 47") if debugRoughDamage
    # Defense-boosting items
    if skill>=PBTrainerAI.highSkill
      if opponent.hasWorkingItem(:EVIOLITE)
        evos=pbGetEvolvedFormData(opponent.species)
        if evos && evos.length>0
          defense=(defense*1.5).round
        end
      end
      if opponent.hasWorkingItem(:DEEPSEASCALE) &&
         isConst?(opponent.species,PBSpecies,:CLAMPERL) && move.pbIsSpecial?(type)
        defense=(defense*2.0).round
      end
      if opponent.hasWorkingItem(:DRAGONSCALE) &&
         isConst?(opponent.species,PBSpecies,:DELTACLAMPERL) && 
         move.pbIsPhysical?(type)
        defense=(defense*2.0).round
      end
      if opponent.hasWorkingItem(:METALPOWDER) &&
         (isConst?(opponent.species,PBSpecies,:DITTO) ||
         isConst?(opponent.species,PBSpecies,:DELTADITTO)) &&
         !opponent.effects[PBEffects::Transform] && move.pbIsPhysical?(type)
        defense=(defense*2.0).round
      end
      if opponent.hasWorkingItem(:SOULDEW) &&
         (isConst?(opponent.species,PBSpecies,:LATIAS) ||
         isConst?(opponent.species,PBSpecies,:LATIOS)) && move.pbIsSpecial?(type)
        defense=(defense*1.5).round
      end
      if opponent.hasWorkingItem(:ASSAULTVEST) && move.pbIsSpecial?(type)
        defense=(defense*1.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 48") if debugRoughDamage
    defense = [defense.round,1].max
    # Main damage calculation
    damage=(((2.0*attacker.level/5+2).floor*basedamage*atk/defense).floor/50).floor+2
    Kernel.pbMessage("Get rough damage 49") if debugRoughDamage
    # Multi-targeting attacks
    if skill>=PBTrainerAI.highSkill
      if move.pbTargetsMultiple?(attacker) && @doublebattle
        damage=(damage*0.75).round
      end
    end
    Kernel.pbMessage("Get rough damage 50") if debugRoughDamage
    # Weather
    if skill>=PBTrainerAI.mediumSkill
      case pbWeather
      when PBWeather::SUNNYDAY
        if isConst?(type,PBTypes,:FIRE)
          damage=(damage*1.5).round
        elsif isConst?(type,PBTypes,:WATER)
          damage=(damage*0.5).round
        end
      when PBWeather::RAINDANCE
        if isConst?(type,PBTypes,:FIRE)
          damage=(damage*0.5).round
        elsif isConst?(type,PBTypes,:WATER)
          damage=(damage*1.5).round
        end
      when PBWeather::NEWMOON
        if isConst?(type,PBTypes,:DARK) || isConst?(type,PBTypes,:GHOST)
          damage=(damage*1.35).round
        elsif isConst?(type,PBTypes,:FAIRY)
          damage=(damage*0.75).round
        end
      when PBWeather::HARSHSUN
        if isConst?(type,PBTypes,:FIRE)
          damage=(damage*1.5).round
        elsif isConst?(type,PBTypes,:WATER)
          damage=0
        end
      when PBWeather::HEAVYRAIN
        if isConst?(type,PBTypes,:FIRE)
          damage=0
        elsif isConst?(type,PBTypes,:WATER)
          damage=(damage*1.5).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 51") if debugRoughDamage
    # Critical hits - n/a
    # Random variance - Assume the absolute minimum damage, especially for anticipating KOs
    # When calculating damage dealt by player's Pokemon, damage is assumed to be at max
    if skill>=PBTrainerAI.bestSkill && !pbOwnedByPlayer?(attacker.index)
      damage=(damage*0.85).round
    end
    # STAB
    if skill>=PBTrainerAI.mediumSkill
      if attacker.hasWorkingAbility(:ANCIENTPRESENCE)
          damage=(damage*1.5).round
      elsif (attacker.pbHasType?(type) && !attacker.hasWorkingAbility(:OMNITYPE)) ||
            (attacker.hasWorkingAbility(:OMNITYPE) && (attacker.type1==type ||
            attacker.type2==type)) ||
            (attacker.hasWorkingAbility(:SHADOWSYNERGY) && 
            isConst?(type,PBTypes,:DARK)) ||
            (attacker.effects[PBEffects::ForestsCurse] && 
            isConst?(type,PBTypes,:GRASS)) ||
            (attacker.effects[PBEffects::TrickOrTreat] && isConst?(type,PBTypes,:GHOST))
        if attacker.hasWorkingAbility(:ADAPTABILITY) &&
           skill>=PBTrainerAI.highSkill
          damage=(damage*2).round
        else
          damage=(damage*1.5).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 52") if debugRoughDamage
    # Type effectiveness
    typemod=pbTypeModMove(move,attacker,opponent)
    Kernel.pbMessage("Get rough damage 53") if debugRoughDamage
    if skill>=PBTrainerAI.mediumSkill
      damage=(damage*typemod*1.0/4.0).round
    end
    Kernel.pbMessage("Get rough damage 54") if debugRoughDamage
    # Burn
    if skill>=PBTrainerAI.mediumSkill
      if attacker.status==PBStatuses::BURN && move.pbIsPhysical?(type) &&
         !attacker.hasWorkingAbility(:GUTS)
        damage=(damage*0.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 55") if debugRoughDamage
    # Make sure damage is at least 1
    damage=1 if damage<1
    # Reflect
    if skill>=PBTrainerAI.highSkill
      if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 && move.pbIsPhysical?(type)
        if !opponent.pbPartner.fainted?
          damage=(damage*2.0/3.0).round
        else
          damage=(damage*0.5).round
        end
        if pbWeather==PBWeather::NEWMOON
          damage=(damage*4.0/5.0).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 56") if debugRoughDamage
    # Light Screen
    if skill>=PBTrainerAI.highSkill
      if opponent.pbOwnSide.effects[PBEffects::LightScreen]>0 && move.pbIsSpecial?(type)
        if !opponent.pbPartner.fainted?
          damage=(damage*2.0/3.0).round
        else
          damage=(damage*0.5).round
        end
        if pbWeather==PBWeather::NEWMOON
          damage=(damage*4.0/5.0).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 57") if debugRoughDamage
    # Multiscale
    if skill>=PBTrainerAI.bestSkill
      if opponent.hasWorkingAbility(:MULTISCALE) &&
         opponent.hp==opponent.totalhp
        damage=(damage*0.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 58") if debugRoughDamage
    # Tinted Lens
    if skill>=PBTrainerAI.bestSkill
      if attacker.hasWorkingAbility(:TINTEDLENS) && typemod<4
        damage=(damage*2.0).round
      end
    end
    Kernel.pbMessage("Get rough damage 59") if debugRoughDamage
    # Friend Guard
    if skill>=PBTrainerAI.bestSkill
      if @doublebattle
        if opponent.pbPartner.hasWorkingAbility(:FRIENDGUARD) && !opponent.pbPartner.fainted?
          damage=(damage*0.75).round
        end
      end
    end
    Kernel.pbMessage("Get rough damage 60") if debugRoughDamage
    # Sniper - n/a
    # Solid Rock, Filter
    if skill>=PBTrainerAI.bestSkill
      if (opponent.hasWorkingAbility(:SOLIDROCK) || opponent.hasWorkingAbility(:FILTER)) &&
         typemod>4
        damage=(damage*0.75).round
      end
    end
    Kernel.pbMessage("Get rough damage 61") if debugRoughDamage
    # Pendulum
    if attacker.hasWorkingAbility(:PENDULUM)
      if attacker.effects[PBEffects::PendulumCounter]>4
        damage=(damage*2.0).round
      else
        met=1.0+attacker.effects[PBEffects::PendulumCounter]*0.2
        damage=(damage*met).round
      end
    end
    Kernel.pbMessage("Get rough damage 62") if debugRoughDamage
    # Final damage-altering items
    if attacker.hasWorkingItem(:METRONOME)
      if attacker.effects[PBEffects::Metronome]>4
        damage=(damage*2.0).round
      else
        met=1.0+attacker.effects[PBEffects::Metronome]*0.2
        damage=(damage*met).round
      end
    end
    Kernel.pbMessage("Get rough damage 63") if debugRoughDamage
    if attacker.hasWorkingItem(:EXPERTBELT) && typemod>4
      damage=(damage*1.2).round
    end
    if attacker.hasWorkingItem(:LIFEORB)
      damage=(damage*1.3).round
    end
    Kernel.pbMessage("Get rough damage 64") if debugRoughDamage
    if typemod>4 && skill>=PBTrainerAI.highSkill
      if (opponent.hasWorkingItem(:CHOPLEBERRY) && isConst?(type,PBTypes,:FIGHTING)) ||
         (opponent.hasWorkingItem(:COBABERRY) && isConst?(type,PBTypes,:FLYING)) ||
         (opponent.hasWorkingItem(:KEBIABERRY) && isConst?(type,PBTypes,:POISON)) ||
         (opponent.hasWorkingItem(:SHUCABERRY) && isConst?(type,PBTypes,:GROUND)) ||
         (opponent.hasWorkingItem(:CHARTIBERRY) && isConst?(type,PBTypes,:ROCK)) ||
         (opponent.hasWorkingItem(:TANGABERRY) && isConst?(type,PBTypes,:BUG)) ||
         (opponent.hasWorkingItem(:KASIBBERRY) && isConst?(type,PBTypes,:GHOST)) ||
         (opponent.hasWorkingItem(:BABIRIBERRY) && isConst?(type,PBTypes,:STEEL)) ||
         (opponent.hasWorkingItem(:OCCABERRY) && isConst?(type,PBTypes,:FIRE)) ||
         (opponent.hasWorkingItem(:PASSHOBERRY) && isConst?(type,PBTypes,:WATER)) ||
         (opponent.hasWorkingItem(:RINDOBERRY) && isConst?(type,PBTypes,:GRASS)) ||
         (opponent.hasWorkingItem(:WACANBERRY) && isConst?(type,PBTypes,:ELECTRIC)) ||
         (opponent.hasWorkingItem(:PAYAPABERRY) && isConst?(type,PBTypes,:PSYCHIC)) ||
         (opponent.hasWorkingItem(:YACHEBERRY) && isConst?(type,PBTypes,:ICE)) ||
         (opponent.hasWorkingItem(:HABANBERRY) && isConst?(type,PBTypes,:DRAGON)) ||
         (opponent.hasWorkingItem(:COLBURBERRY) && isConst?(type,PBTypes,:DARK)) ||
         (opponent.hasWorkingItem(:ROSELIBERRY) && isConst?(type,PBTypes,:FAIRY))
        damage=(damage*0.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 65") if debugRoughDamage
    if skill>=PBTrainerAI.highSkill
      if opponent.hasWorkingItem(:CHILANBERRY) && isConst?(type,PBTypes,:NORMAL)
        damage=(damage*0.5).round
      end
    end
    Kernel.pbMessage("Get rough damage 66") if debugRoughDamage
    # pbModifyDamage - TODO
    # "AI-specific calculations below"
    # Increased critical hit rates
    if skill>=PBTrainerAI.mediumSkill
      c=0
      c+=attacker.effects[PBEffects::FocusEnergy]
      c+=1 if move.hasHighCriticalRate?
      c+=1 if (attacker.inHyperMode? rescue false) && isConst?(self.type,PBTypes,:SHADOW)
      c+=2 if isConst?(attacker.species,PBSpecies,:CHANSEY) && 
              attacker.hasWorkingItem(:LUCKYPUNCH)
      c+=2 if isConst?(attacker.species,PBSpecies,:FARFETCHD) && 
              attacker.hasWorkingItem(:STICK)
      c+=1 if attacker.hasWorkingAbility(:SUPERLUCK)
      c+=1 if attacker.hasWorkingItem(:SCOPELENS)
      c+=1 if attacker.hasWorkingItem(:RAZORCLAW)
      c=4 if c>4
      c=0 if (opponent.hasWorkingAbility(:SHELLARMOR) || 
             opponent.hasWorkingAbility(:BATTLEARMOR)) && skill>=PBTrainerAI.highSkill
      damage+=(damage*0.1*c)
    end
    Kernel.pbMessage("Get rough damage 67") if debugRoughDamage
    return damage
  end
  
  def pbRoughAccuracy(move,attacker,opponent,skill)
    debugRoughAccuracy=false
    Kernel.pbMessage("Get rough accuracy 1") if debugRoughAccuracy
    # Get base accuracy
    baseaccuracy=move.accuracy
    Kernel.pbMessage("Get rough accuracy 2") if debugRoughAccuracy
    Kernel.pbMessage("Get rough accuracy 3") if debugRoughAccuracy
    if skill>=PBTrainerAI.mediumSkill
      if (pbWeather==PBWeather::SUNNYDAY || pbWeather==PBWeather::HARSHSUN)  &&
         (move.function==0x08 || move.function==0x15) # Thunder, Hurricane
        accuracy=50
      end
    end
    Kernel.pbMessage("Get rough accuracy 4") if debugRoughAccuracy
    # Accuracy stages
    accstage=attacker.stages[PBStats::ACCURACY]
    Kernel.pbMessage("Get rough accuracy 5") if debugRoughAccuracy
    accstage=0 if opponent.hasWorkingAbility(:UNAWARE)
    Kernel.pbMessage("Get rough accuracy 6") if debugRoughAccuracy
    accuracy=(accstage>=0) ? (accstage+3)*100.0/3 : 300.0/(3-accstage)
    Kernel.pbMessage("Get rough accuracy 7") if debugRoughAccuracy
    evastage=opponent.stages[PBStats::EVASION]
    Kernel.pbMessage("Get rough accuracy 8") if debugRoughAccuracy
    evastage-=2 if @field.effects[PBEffects::Gravity]>0
    Kernel.pbMessage("Get rough accuracy 9") if debugRoughAccuracy
    evastage=-6 if evastage<-6
    Kernel.pbMessage("Get rough accuracy 10") if debugRoughAccuracy
    evastage=0 if opponent.effects[PBEffects::Foresight] ||
                  opponent.effects[PBEffects::MiracleEye] ||
                  move.function==0xA9 || # Chip Away
                  attacker.hasWorkingAbility(:UNAWARE)
    Kernel.pbMessage("Get rough accuracy 11") if debugRoughAccuracy
    evasion=(evastage>=0) ? (evastage+3)*100.0/3 : 300.0/(3-evastage)
    Kernel.pbMessage("Get rough accuracy 12") if debugRoughAccuracy
    accuracy*=baseaccuracy/evasion
    Kernel.pbMessage("Get rough accuracy 13") if debugRoughAccuracy
    # Accuracy modifiers
    if skill>=PBTrainerAI.mediumSkill
    Kernel.pbMessage("Get rough accuracy 14") if debugRoughAccuracy
      accuracy*=1.3 if attacker.hasWorkingAbility(:COMPOUNDEYES)
    Kernel.pbMessage("Get rough accuracy 15") if debugRoughAccuracy
      accuracy*=1.1 if attacker.hasWorkingAbility(:VICTORYSTAR)
    Kernel.pbMessage("Get rough accuracy 16") if debugRoughAccuracy
      if skill>=PBTrainerAI.highSkill
    Kernel.pbMessage("Get rough accuracy 17") if debugRoughAccuracy
        partner=attacker.pbPartner
    Kernel.pbMessage("Get rough accuracy 18") if debugRoughAccuracy
        accuracy*=1.1 if partner && partner.hasWorkingAbility(:VICTORYSTAR)
    Kernel.pbMessage("Get rough accuracy 19") if debugRoughAccuracy
      end
      accuracy*=1.2 if attacker.effects[PBEffects::MicleBerry]
    Kernel.pbMessage("Get rough accuracy 20") if debugRoughAccuracy
      accuracy*=1.1 if attacker.hasWorkingItem(:WIDELENS)
    Kernel.pbMessage("Get rough accuracy 21") if debugRoughAccuracy
      if skill>=PBTrainerAI.highSkill
    Kernel.pbMessage("Get rough accuracy 22") if debugRoughAccuracy
        accuracy*=0.8 if attacker.hasWorkingAbility(:HUSTLE) &&
                         move.basedamage>0 &&
                         move.pbIsPhysical?(move.pbType(move.type,attacker,opponent))
      end
    Kernel.pbMessage("Get rough accuracy 23") if debugRoughAccuracy
      if skill>=PBTrainerAI.bestSkill
    Kernel.pbMessage("Get rough accuracy 24") if debugRoughAccuracy
        accuracy/=2 if opponent.hasWorkingAbility(:WONDERSKIN) &&
                       move.basedamage==0 &&
                       attacker.pbIsOpposing?(opponent.index)
    Kernel.pbMessage("Get rough accuracy 25") if debugRoughAccuracy
        accuracy/=1.25 if opponent.hasWorkingAbility(:TANGLEDFEET) &&
                         opponent.effects[PBEffects::Confusion]>0
    Kernel.pbMessage("Get rough accuracy 26") if debugRoughAccuracy
        accuracy/=1.25 if pbWeather==PBWeather::SANDSTORM &&
                         opponent.hasWorkingAbility(:SANDVEIL)
    Kernel.pbMessage("Get rough accuracy 27") if debugRoughAccuracy
        accuracy/=1.25 if pbWeather==PBWeather::HAIL &&
                         opponent.hasWorkingAbility(:SNOWCLOAK)
    Kernel.pbMessage("Get rough accuracy 28") if debugRoughAccuracy
        accuracy/=1.25 if pbWeather==PBWeather::NEWMOON &&
                         opponent.hasWorkingAbility(:ILLUMINATE)
    Kernel.pbMessage("Get rough accuracy 29") if debugRoughAccuracy
      end
      if skill>=PBTrainerAI.highSkill
    Kernel.pbMessage("Get rough accuracy 30") if debugRoughAccuracy
        accuracy/=1.1 if opponent.hasWorkingItem(:BRIGHTPOWDER)
    Kernel.pbMessage("Get rough accuracy 31") if debugRoughAccuracy
        accuracy/=1.1 if opponent.hasWorkingItem(:LAXINCENSE)
    Kernel.pbMessage("Get rough accuracy 32") if debugRoughAccuracy
      end
    end
    accuracy=100 if accuracy>100
    # Override accuracy
    accuracy=125 if move.accuracy==0 #&& !move.target==PBTargets::User  # Doesn't do accuracy check (always hits)
    accuracy=125 if opponent.effects[PBEffects::Minimize] && move.tramplesMinimize?(1)
    accuracy=125 if attacker.pbHasType?(:POISON) && isConst?(move.id,PBMoves,:TOXIC)
    Kernel.pbMessage("Get rough accuracy 33") if debugRoughAccuracy
    accuracy=125 if move.function==0xA5 # Swift
    Kernel.pbMessage("Get rough accuracy 34") if debugRoughAccuracy
    if skill>=PBTrainerAI.mediumSkill
    Kernel.pbMessage("Get rough accuracy 35") if debugRoughAccuracy
      accuracy=125 if opponent.effects[PBEffects::LockOn]>0 &&
                      opponent.effects[PBEffects::LockOnPos]==attacker.index
    Kernel.pbMessage("Get rough accuracy 36") if debugRoughAccuracy
      if skill>=PBTrainerAI.highSkill
    Kernel.pbMessage("Get rough accuracy 37") if debugRoughAccuracy
        accuracy=125 if attacker.hasWorkingAbility(:NOGUARD) ||
                        opponent.hasWorkingAbility(:NOGUARD)
    Kernel.pbMessage("Get rough accuracy 38") if debugRoughAccuracy
      end
      accuracy=125 if opponent.effects[PBEffects::Telekinesis]>0
    Kernel.pbMessage("Get rough accuracy 39") if debugRoughAccuracy
      case pbWeather
      when PBWeather::HAIL
        accuracy=125 if move.function==0x0D # Blizzard
    Kernel.pbMessage("Get rough accuracy 40") if debugRoughAccuracy
      when PBWeather::RAINDANCE, PBWeather::HEAVYRAIN
        accuracy=125 if move.function==0x08 || move.function==0x15 # Thunder, Hurricane
    Kernel.pbMessage("Get rough accuracy 41") if debugRoughAccuracy
      end
      if move.function==0x70 # OHKO moves
    Kernel.pbMessage("Get rough accuracy 42") if debugRoughAccuracy
        accuracy=move.accuracy+attacker.level-opponent.level
    Kernel.pbMessage("Get rough accuracy 43") if debugRoughAccuracy
        accuracy=0 if opponent.hasWorkingAbility(:STURDY)
    Kernel.pbMessage("Get rough accuracy 44") if debugRoughAccuracy
        accuracy=0 if opponent.level>attacker.level
    Kernel.pbMessage("Get rough accuracy 45") if debugRoughAccuracy
        accuracy=0 if isConst?(move.id,PBMoves,:SHEERCOLD) && opponent.pbHasType?(:ICE)
      end
    end
    Kernel.pbMessage("Get rough accuracy 46") if debugRoughAccuracy
    return accuracy
  end

################################################################################
# Choose a move to use.
################################################################################
  def pbChooseMoves(index)
    begin
    debugChooseMove=false
    Kernel.pbMessage("Choose move 1") if debugChooseMove
    if $INTERNAL && !pbIsOpposing?(index)
      pbChooseMovesOld(index)
      return
    end
    Kernel.pbMessage("Choose move 2") if debugChooseMove
    attacker=@battlers[index]
    scores=[0,0,0,0]
    targets=nil
    myChoices=[]
    totalscore=0
    target=-1
    wildbattle=!@opponent && pbIsOpposing?(index)
    Kernel.pbMessage("Choose move 3") if debugChooseMove
    
    if wildbattle # If wild battle
      for i in 0...4
        if pbCanChooseMove?(index,i,false)
          scores[i]=100
          myChoices.push(i)
          totalscore+=100
        end
      end
    elsif !$game_switches[321] &&
      (pbGetOwner(attacker.index).trainertype==PBTrainers::QMARKS ||
      (pbGetOwner(attacker.index).trainertype==PBTrainers::ELITEFOUR_BatonPass && 
      attacker.pokemon.species!=PBSpecies::SLOWBRO)) && !movesRestricted?(attacker)
      #||
      #   pbGetOwner(attacker.index).trainertype==PBTrainers::ELITEFOUR_TrickRoom ||
      #   pbGetOwner(attacker.index).trainertype==PBTrainers::CHAMPION_Reukra
      
      opponent = attacker.pbOppositeOpposing 
      #
      # Kernel.pbMessage("targeted1")
      # AI for Elite Four
      if pbGetOwner(attacker.index).trainertype==PBTrainers::ELITEFOUR_Hail
        #Hail, Yuki
      elsif pbGetOwner(attacker.index).trainertype==PBTrainers::ELITEFOUR_Darude
        #Sandstorm, Eduard
      elsif pbGetOwner(attacker.index).trainertype==PBTrainers::QMARKS
        #Lugia
        for i in 0..3
            attacker.pokemon.moves[i].pp=attacker.pokemon.moves[i].totalpp #if !$game_switches[345]
        end 
        if $throwingBalls!=nil
          o=3
        else 
          o=2 
        end
        pbRegisterMove(attacker.index,o,false)
        target=targets[o] if targets
        pbRegisterTarget(index,target)
        return 

      elsif pbGetOwner(attacker.index).trainertype==PBTrainers::ELITEFOUR_BatonPass && 
            attacker.pokemon.species!=PBSpecies::SLOWBRO
          #Baton Pass, Kayla
        fainted=0
        skillKayla=pbGetOwner(attacker.index).skill
        skillPlayer=100
        for i in 0...pbParty(attacker.index).length
          pkmn=pbParty(attacker.index)[i]
          fainted+=1 if pkmn.hp<1
        end
        if $PokemonSystem.chooseDifficulty==0
          skillKayla=PBTrainerAI.mediumSkill
          skillPlayer=PBTrainerAI.mediumSkill
        end
        scorePlayer=0
        useSubstitute=true
        for thismove in opponent.moves
          if !thismove.pbIsStatus?
            scorePlayer=pbGetMoveScore(thismove,opponent,attacker,skillPlayer)
        #Kernel.pbMessage(_INTL("{1}",scorePlayer))
            if canBreakSubstitute?(thismove,opponent,attacker,skillPlayer)
              useSubstitute=false
            end
            break if scorePlayer>=220
          end
        end
        ### BEANS ###
        if attacker.pokemon.species==PBSpecies::SMEARGLE
          if ![PBAbilities::OVERCOAT,PBAbilities::VITALSPIRIT,
             PBAbilities::INSOMNIA,PBAbilities::MAGICBOUNCE].include?(opponent.pokemon.ability) &&
             ![PBItems::LUMBERRY,PBItems::CHESTOBERRY].include?(opponent.pokemon.item) &&
             !opponent.pbHasType?(:GRASS) &&
             opponent.status==0 &&
             $justUsedStatusCure==nil
            o=2
          else
            if attacker.stages[PBStats::SPEED]>=3 || attacker.stages[PBStats::SPATK]>=3 || attacker.stages[PBStats::SPDEF]>=3
              hasRrWw=false
              for pokemon in $Trainer.party 
                hasRrWw = pbHasMove?(pokemon,PBMoves::WHIRLWIND) || pbHasMove?(pokemon,PBMoves::ROAR) || 
                   (pbHasMove?(pokemon,PBMoves::CIRCLETHROW) || pbHasMove?(pokemon,PBMoves::DRAGONTAIL) && attacker.effects[PBEffects::Substitute]==0)
                break if hasRrWw
              end
              if (hasRrWw || (opponent.status==PBStatuses::SLEEP && opponent.statusCount>1)) && attacker.effects[PBEffects::INGRAIN]
                o=0
              else
                o=3  
              end
            else
              #oppHasLethal=false
              #for moves in opponent.moves
              #  oppHasLethal = (moves.pbCalcDamage(opponent,attacker,0,false,0,true) >= attacker.hp)
              #  break if oppHasLethal
              #end
              if scorePlayer>=220 && (!attacker.hasWorkingItem(:FOCUSSASH) || attacker.hp!=attacker.totalhp)
              #if (oppHasLethal && attacker.item != PBItems::FOCUSSASH)
                o=3
              else
                o=1
              end
            end
          end
        end
        if attacker.pokemon.species==PBSpecies::BLAZIKEN
          attHasLethal=false
          oppHasLethal=false
          attIsFaster=false
          if pbGetMoveScore(attacker.moves[2],attacker,opponent,skillKayla)>=220
          #if (attacker.moves[2].pbCalcDamage(attacker,opponent,0,false,0,true) >= opponent.hp)
             attHasLethal=true
             #Kernel.pbMessage(attacker.moves[2].pbCalcDamage(attacker,opponent,0,false,0,true).to_s+" "+opponent.hp.to_s)
          end
          attspeed=pbRoughStat(attacker,PBStats::SPEED,skillKayla)
          oppspeed=pbRoughStat(opponent,PBStats::SPEED,skillKayla) 
          if attspeed>oppspeed
          #if (attacker.pbFasterThen?(opponent))
           attIsFaster=true
          end
          oppHasLethal=true if scorePlayer>=220
          #for moves in opponent.moves
          #  oppHasLethal = (moves.pbCalcDamage(opponent,attacker,0,false,0,true) >= attacker.hp)
          #  break if oppHasLethal
          #end
          if useSubstitute && attacker.effects[PBEffects::Substitute]==0 && attacker.hp/attacker.totalhp > 0.25
            o=1
          elsif ((attHasLethal && attIsFaster) || (attHasLethal && (attacker.hasWorkingItem(:FOCUSSASH) &&
                attacker.hp==attacker.totalhp)) || 
                (attacker.stages[PBStats::ATTACK]==6 && attacker.stages[PBStats::DEFENSE]==6 && !oppHasLethal) ||
                fainted==5)
            o=2
          elsif((oppHasLethal && (!attacker.hasWorkingItem(:FOCUSSASH) || attacker.hp!=attacker.totalhp)) || 
             (attacker.effects[PBEffects::Substitute]>0 && attacker.stages[PBStats::ATTACK]>3 && attacker.stages[PBStats::DEFENSE]>3))
            o=3
          else
            #if attacker.effects[PBEffects::Substitute]==0 && attacker.hp/attacker.totalhp > 0.25
            #  o=1
            #else
            if oppHasLethal
              o=3
            else
              o=0
            end
            #end
          end
        end
        if attacker.pokemon.species==PBSpecies::SCIZOR
          #Kernel.pbMessage("Its checking here")
          attHasLethal=false
          oppHasLethal=false
          if pbGetMoveScore(attacker.moves[1],attacker,opponent,skillKayla)>=220
          #if (attacker.moves[1].pbCalcDamage(attacker,opponent,0,false,0,true) >= opponent.hp)
             attHasLethal=true
             #Kernel.pbMessage(attacker.moves[1].pbCalcDamage(attacker,opponent,0,false,0,true).to_s+" "+opponent.hp.to_s)
          end
          oppHasLethal=true if scorePlayer>=220
          #for moves in opponent.moves
          #  oppHasLethal = (moves.pbCalcDamage(opponent,attacker,0,false,0,true) >= attacker.hp)
          #  break if oppHasLethal
          #end
          #Kernel.pbMessage("attHasLethal") if attHasLethal
          #Kernel.pbMessage("afainted") if fainted==5
          if (attHasLethal || 
             (attacker.stages[PBStats::ATTACK]==6 && attacker.stages[PBStats::DEFENSE]==6 && !oppHasLethal) ||
             fainted==5)
            o=1
          elsif oppHasLethal || (attacker.stages[PBStats::ATTACK]>=4 && attacker.stages[PBStats::DEFENSE]>=6)
            o=3
          else
            if attacker.stages[PBStats::DEFENSE]>=6
              o=2
            else
              o=0
            end
          end
        end
        if attacker.pokemon.species==PBSpecies::SYLVEON
          att1HasLethal=false
          att2HasLethal=false
          oppHasLethal=false
          attIsFaster=false
          if pbGetMoveScore(attacker.moves[1],attacker,opponent,skillKayla)>=220
          #if (attacker.moves[1].pbCalcDamage(attacker,opponent,0,false,0,true) >= opponent.hp)
            att1HasLethal=true
          end
          if pbGetMoveScore(attacker.moves[2],attacker,opponent,skillKayla)>=220
          #if (attacker.moves[2].pbCalcDamage(attacker,opponent,0,false,0,true) >= opponent.hp)
            att2HasLethal=true
          end
          attspeed=pbRoughStat(attacker,PBStats::SPEED,skillKayla)
          oppspeed=pbRoughStat(opponent,PBStats::SPEED,skillKayla) 
          if attspeed>oppspeed
          #if (attacker.pbFasterThen?(opponent))
            attIsFaster=true
          end
          oppHasLethal=true if scorePlayer>=220
          #for moves in opponent.moves
          #  oppHasLethal = (moves.pbCalcDamage(opponent,attacker,0,false,0,true) >= attacker.hp)
          #  break if oppHasLethal
          #end
          if ((att2HasLethal && attIsFaster) || (att2HasLethal && !oppHasLethal) ||
             (attacker.stages[PBStats::SPATK]==6 && attacker.stages[PBStats::SPDEF]==6) ||
             fainted==5)
            o=2
          elsif ((att1HasLethal && attIsFaster) || (att1HasLethal && !oppHasLethal) || (att1HasLethal && 
                opponent.effects[PBEffects::Substitute]==0))
            o=1
          elsif (oppHasLethal && attacker.effects[PBEffects::Substitute]==0)
            o=3
          else
            o=0
          end
        end
        if attacker.pokemon.species==PBSpecies::ESPEON
          attHasLethal=false
          oppHasLethal=false
          attIsFaster=false
          if pbGetMoveScore(attacker.moves[1],attacker,opponent,skillKayla)>=220
          #if (attacker.moves[1].pbCalcDamage(attacker,opponent,0,false,0,true) >= opponent.hp)
            attHasLethal=true
            #Kernel.pbMessage(attacker.moves[1].pbCalcDamage(attacker,opponent,0,false,0,true).to_s+" "+opponent.hp.to_s)
          end
          attspeed=pbRoughStat(attacker,PBStats::SPEED,skillKayla)
          oppspeed=pbRoughStat(opponent,PBStats::SPEED,skillKayla) 
          if attspeed>oppspeed
          #if (attacker.pbFasterThen?(opponent))
             attIsFaster=true
          end
          oppHasLethal=true if scorePlayer>=220
          #for moves in opponent.moves
          #   oppHasLethal = (moves.pbCalcDamage(opponent,attacker,0,false,0,true) >= attacker.hp)
          #   break if oppHasLethal
          #end
          if useSubstitute && attacker.effects[PBEffects::Substitute]==0
            o=2
          elsif ((attHasLethal && attIsFaster) || (attHasLethal && !oppHasLethal) ||
             (attacker.stages[PBStats::SPATK]==6 && attacker.stages[PBStats::SPDEF]==6 && 
             pbGetMoveScore(attacker.moves[1],attacker,opponent,skillKayla)>0) ||
             fainted==5)
            o=1
          elsif (oppHasLethal && attacker.effects[PBEffects::Substitute]==0) || 
                (attacker.stages[PBStats::SPATK]==6 && attacker.stages[PBStats::SPDEF]==6)
            o=3
          #elsif attacker.effects[PBEffects::Substitute]==0 && attacker.hp/attacker.totalhp > 0.25
          #  o=2
          else
            o=0
          end
        end
        #
        #   e=$!
        #  raise if e.is_a?(Hangup) || e.is_a?(SystemExit) || "#{e.class}"=="Reset"
        #  event=get_character(0)
        # s=""
        #  message=pbGetExceptionMessage(e)      
        # end
        pbRegisterMove(attacker.index,o,false)
        target=targets[o] if targets
        pbRegisterTarget(index,target)
        return 
      elsif pbGetOwner(attacker.index)==PBTrainers::ELITEFOUR_TrickRoom
        #Trick Room, London        
      elsif pbGetOwner(attacker.index)==PBTrainers::CHAMPION_Reukra
        # Champion, Reukra
      end
    else
    Kernel.pbMessage("Choose move 4") if debugChooseMove
      skill=pbGetOwner(attacker.index).skill || 0
      opponent=attacker.pbOppositeOpposing
    Kernel.pbMessage("Choose move 5") if debugChooseMove
      if @doublebattle && opponent.hp>0 && opponent.pbPartner.hp>0
        # Choose a target and move.  Also care about partner.
        otheropp=opponent.pbPartner
        scoresAndTargets=[]
        targets=[-1,-1,-1,-1]
        maxscore1=0
        maxscore2=0
        totalscore1=0
        totalscore2=0
        for i in 0...4
          opponent=attacker if attacker.moves[i].target==PBTargets::UserOrPartner
          otheropp=attacker.pbPartner if attacker.moves[i].target==PBTargets::UserOrPartner
          if pbCanChooseMove?(index,i,false)
            score1=pbGetMoveScore(attacker.moves[i],attacker,opponent,skill)
            score2=pbGetMoveScore(attacker.moves[i],attacker,otheropp,skill)
            if (attacker.moves[i].target&0x20)!=0 # Target's user's side
              if attacker.pbPartner.hp<=0 # No partner
                score1=score1*5/3
                score2=score2*5/3
              else
                # If this move can also target the partner, get the partner's
                # score too
                s=pbGetMoveScore(attacker.moves[i],attacker,attacker.pbPartner,skill)
                if s>=100 # Highly effective
                  score1=score1*1/3
                  score2=score2*1/3
                elsif s>=70 # Very effective
                  score1=score1*2/3
                  score2=score2*2/3
                elsif s<=40 # Less effective
                  score1=score1*4/3
                  score2=score2*4/3
                else # Hardly effective
                  score1=score1*5/3
                  score2=score2*5/3
                end
              end
            end
            myChoices.push(i)
            if score1>score2
              scores[i]=score1
              targets[i]=opponent.index
            elsif score1<score2
              scores[i]=score2
              targets[i]=otheropp.index
            else
              if pbAIRandom(2)==0
                scores[i]=score1
                targets[i]=opponent.index
              else
                scores[i]=score2
                targets[i]=otheropp.index
              end
            end
            #scoresAndTargets.push([i*2,i,score1,opponent.index])
            #scoresAndTargets.push([i*2+1,i,score2,otheropp.index])
          end
        end
=begin
        scoresAndTargets.sort!{|a,b|
           if a[2]==b[2] # if scores are equal
             a[0]<=>b[0] # sort by index (for stable comparison)
           else
             b[2]<=>a[2]
           end
        }
        for i in 0...scoresAndTargets.length
          idx=scoresAndTargets[i][1]
          thisScore=scoresAndTargets[i][2]
          if thisScore>0
            if scores[idx]==0 || ((scores[idx]==thisScore && pbAIRandom(10)<5) ||
               (scores[idx]!=thisScore && pbAIRandom(10)<3))
              scores[idx]=thisScore
              targets[idx]=scoresAndTargets[i][3]
            end
          end
        end
=end
        for i in 0...4
          scores[i]=0 if scores[i]<0
          totalscore+=scores[i]
        end
      else
    Kernel.pbMessage("Choose move 6") if debugChooseMove
        # Choose a move. There is only 1 opposing Pokémon.
        if @doublebattle && opponent.hp<=0
          opponent=opponent.pbPartner
        end
    Kernel.pbMessage("Choose move 7") if debugChooseMove
        for i in 0...4
          if pbCanChooseMove?(index,i,false)
            scores[i]=pbGetMoveScore(attacker.moves[i],attacker,opponent,skill)
            myChoices.push(i)
          end
          scores[i]=0 if scores[i]<0
          totalscore+=scores[i]
        end
      end
    end
    maxscore=0
    minscore=10000
    Kernel.pbMessage("Choose move 8") if debugChooseMove
    #maxscore=scores[0]
    #maxscore=scores[1] if maxscore<scores[1]
    #maxscore=scores[2] if maxscore<scores[2]
    #maxscore=scores[3] if maxscore<scores[3]
    for i in 0...4
      maxscore=scores[i] if scores[i] && scores[i]>maxscore
      minscore=scores[i] if scores[i] && scores[i]>0 && scores[i]<minscore
    end
    Kernel.pbMessage("Choose move 9") if debugChooseMove
    # Minmax choices depending on AI
    if !wildbattle && skill>=PBTrainerAI.mediumSkill
      threshold=(skill>=PBTrainerAI.bestSkill) ? 1.5 : (skill>=PBTrainerAI.highSkill) ? 2 : 3
      newscore=(skill>=PBTrainerAI.bestSkill) ? 5 : (skill>=PBTrainerAI.highSkill) ? 10 : 15
      for i in 0...scores.length
        if scores[i]>newscore && scores[i]*threshold<maxscore
          totalscore-=(scores[i]-newscore)
          scores[i]=newscore
        end
      end
      maxscore=0
      minscore=10000
      for i in 0...4
        maxscore=scores[i] if scores[i] && scores[i]>maxscore
        minscore=scores[i] if scores[i] && scores[i]>0 && scores[i]<minscore
      end
    end
    Kernel.pbMessage("Choose move 10") if debugChooseMove
    if $INTERNAL
      x="[#{attacker.pbThis}:"
      j=0
      for i in 0...4
        if attacker.moves[i].id!=0
          x+=", " if j>0
          x+=PBMoves.getName(attacker.moves[i].id)+"="+scores[i].to_s
          j+=1
        end
      end
      PBDebug.log(x)
    end
    Kernel.pbMessage("Choose move 11") if debugChooseMove
    if !wildbattle && maxscore>100
    Kernel.pbMessage("Choose move 11.1") if debugChooseMove
      stdev=pbStdDev(scores)
      if stdev>=40 && pbAIRandom(10)!=0
    Kernel.pbMessage("Choose move 11.2") if debugChooseMove
        # If standard deviation is 40 or more,
        # there is a highly preferred move. Choose it.
        preferredMoves=[]
        for i in 0...4
          #Kernel.pbMessage(_INTL("Maxed -1: {1} " + "{2} " + "{3}",attacker.moves[i].name,scores[i],@battlers[targets[i]].name))
            if attacker.moves[i].id!=0 && (scores[i]==maxscore || scores[i]>=200)
           #if attacker.moves[i].id!=0 && (scores[i]>=maxscore*0.8 || scores[i]>=200)
            preferredMoves.push(i)
            #if scores[i]==maxscore
            #  preferredMoves.push(i) # Doubly prefer the best move
            #end
          end
        end
    Kernel.pbMessage("Choose move 11.3") if debugChooseMove
        if preferredMoves.length>0
          i=preferredMoves[pbAIRandom(preferredMoves.length)]
          if $INTERNAL
            PBDebug.log("[Prefer "+PBMoves.getName(attacker.moves[i].id)+"]")
          end
          pbRegisterMove(index,i,false)
          target=targets[i] if targets
        #Kernel.pbMessage(_INTL("Maxed 1: {1} " + "{2} " + "{3}",attacker.moves[i].name,scores[i],@battlers[targets[i]].name))
          if @doublebattle && target>=0
            pbRegisterTarget(index,target)
          end
          return
        end
    Kernel.pbMessage("Choose move 11.4") if debugChooseMove
      end
    end
    Kernel.pbMessage("Choose move 12") if debugChooseMove
    if !wildbattle && attacker.turncount
      badmoves=false
      if ((maxscore<=20 && attacker.turncount>2) ||
         (maxscore<=30 && attacker.turncount>5)) && pbAIRandom(10)<8
        badmoves=true
      end
      if totalscore<100 && attacker.turncount>1
        badmoves=true
        movecount=0
        for i in 0...4
          if attacker.moves[i].id!=0
            if scores[i]>0 && attacker.moves[i].basedamage>0
              badmoves=false
            end
            movecount+=1
          end
        end
        badmoves=badmoves && pbAIRandom(10)!=0
      end
      if badmoves
        # Attacker has terrible moves, try switching instead
        if pbEnemyShouldWithdrawEx?(index,true)
          if $INTERNAL
            PBDebug.log("Switching due to terrible moves")
            PBDebug.log([index,@choices[index][0],@choices[index][1],
               pbCanChooseNonActive?(index),
               @battlers[index].pbNonActivePokemonCount()].inspect)
          end
          return
        end
      end
    end
    Kernel.pbMessage("Choose move 13") if debugChooseMove
    if maxscore<=0
      # If all scores are 0 or less, choose a move at random
      if myChoices.length>0
        pbRegisterMove(index,myChoices[pbAIRandom(myChoices.length)],false)
      else
        pbAutoChooseMove(index)
      end
    else
      randnum=pbAIRandom(totalscore)
      cumtotal=0
      #for i in 0...4
      #  Kernel.pbMessage(_INTL("{1}: {2}",attacker.moves[i].name,scores[i]))
      #end
      for i in 0...4
        if scores[i]>0
          modscore=scores[i]
          if minscore!=maxscore
            if modscore==minscore
              modscore/=2
            elsif modscore==maxscore
              modscore*=2
            end
          end
          #cumtotal+=scores[i]
          cumtotal+=modscore
          #Kernel.pbMessage(_INTL("{1}",randnum))
          #Kernel.pbMessage(_INTL("{1}",cumtotal))
          if randnum<cumtotal
            pbRegisterMove(index,i,false)
            target=targets[i] if targets
            break
          end
        end
      end
    end
    Kernel.pbMessage("Choose move 14") if debugChooseMove
    if @doublebattle && target>=0
      pbRegisterTarget(index,target)
    end
    rescue
    #Kernel.pbMessage("bug found")
    #Kernel.pbMessage("e"+$!)
  end
    Kernel.pbMessage("Choose move 15") if debugChooseMove
  
  end

################################################################################
# Decide whether the opponent should switch Pokémon.
################################################################################
  def pbEnemyShouldWithdrawEx?(index,alwaysSwitch)
    debugWithdraw=false
    Kernel.pbMessage("Withdraw 1") if debugWithdraw
    return false if !@opponent
    shouldswitch=alwaysSwitch
    typecheck=false
    batonpass=-1
    movetype=-1
    skill=pbGetOwner(index).skill || 0
    Kernel.pbMessage("Withdraw 2") if debugWithdraw
    if @opponent && !shouldswitch && @battlers[index].turncount>0
      if skill>=PBTrainerAI.highSkill # Experienced trainers only
        opponent=@battlers[index].pbOppositeOpposing
        opponent=opponent.pbPartner if opponent.fainted?
        if !opponent.fainted? && opponent.lastMoveUsed>0 && 
           (opponent.level-@battlers[index].level).abs<=6
          move=PBMoveData.new(opponent.lastMoveUsed)
          typemod=pbTypeModMove(move,@battlers[index],@battlers[index])
          movetype=move.type
          if move.basedamage>70 && typemod>4
            shouldswitch=pbAIRandom(100)<30
            movetype=move.type
          elsif move.basedamage>50 && typemod>4
            shouldswitch=pbAIRandom(100)<20
            movetype=move.type
          end
        end
      end
    end
    Kernel.pbMessage("Withdraw 3") if debugWithdraw
    if !pbCanChooseMove?(index,0,false) &&
       !pbCanChooseMove?(index,1,false) &&
       !pbCanChooseMove?(index,2,false) &&
       !pbCanChooseMove?(index,3,false) &&
       @battlers[index].turncount &&
       @battlers[index].turncount>5
      shouldswitch=true
    end
    Kernel.pbMessage("Withdraw 4") if debugWithdraw
    if skill>=PBTrainerAI.highSkill && @battlers[index].effects[PBEffects::PerishSong]!=1
      for i in 0...4
        move=@battlers[index].moves[i]
        if move.id!=0 && pbCanChooseMove?(index,i,false) &&
          move.function==0xED # Baton Pass
          batonpass=i
          break
        end
      end
    end
    Kernel.pbMessage("Withdraw 5") if debugWithdraw
    if skill>=PBTrainerAI.highSkill
      if @battlers[index].status==PBStatuses::POISON &&
         @battlers[index].statusCount>0
        toxicHP=(@battlers[index].totalhp/16)
        nextToxicHP=toxicHP*(@battlers[index].effects[PBEffects::Toxic]+1)
        if nextToxicHP>=@battlers[index].hp &&
           toxicHP<@battlers[index].hp && pbAIRandom(100)<80
          PBDebug.log("Should switch to reduce toxic effects") if $INTERNAL
          shouldswitch=true
        end
      end
    end
    Kernel.pbMessage("Withdraw 6") if debugWithdraw
    if skill>=PBTrainerAI.mediumSkill
      if @battlers[index].effects[PBEffects::Encore]>0
        scoreSum=0
        scoreCount=0
        attacker=@battlers[index]
        encoreIndex=@battlers[index].effects[PBEffects::EncoreIndex]
        if attacker.pbOpposing1.hp>0
          scoreSum+=pbGetMoveScore(attacker.moves[encoreIndex],
             attacker,attacker.pbOpposing1,skill)
          scoreCount+=1
        end
        if attacker.pbOpposing2.hp>0
          scoreSum+=pbGetMoveScore(attacker.moves[encoreIndex],
             attacker,attacker.pbOpposing2,skill)
          scoreCount+=1
        end
        if scoreCount>0 && scoreSum/scoreCount<=20 && pbAIRandom(10)<8
          shouldswitch=true
        end
      end
    end
    Kernel.pbMessage("Withdraw 7") if debugWithdraw
    if skill>=PBTrainerAI.highSkill
      if !@doublebattle && @battlers[index].pbOppositeOpposing.hp>0 
        opp=@battlers[index].pbOppositeOpposing
        if (opp.effects[PBEffects::HyperBeam]>0 ||
           (opp.hasWorkingAbility(:TRUANT) &&
           opp.effects[PBEffects::Truant])) && pbAIRandom(100)<80
          shouldswitch=false
        end
      end
    end
    Kernel.pbMessage("Withdraw 8") if debugWithdraw
    if @rules["suddendeath"]
      if @battlers[index].hp<=(@battlers[index].totalhp/4) && pbAIRandom(10)<3 && 
         @battlers[index].turncount>0
        shouldswitch=true if !@battlers[index].effects[PBEffects::BurstMode]
      elsif @battlers[index].hp<=(@battlers[index].totalhp/2) && pbAIRandom(10)<8 && 
         @battlers[index].turncount>0
        shouldswitch=true if !@battlers[index].effects[PBEffects::BurstMode]
      end
    end
    Kernel.pbMessage("Withdraw 9") if debugWithdraw
    if @battlers[index].effects[PBEffects::PerishSong]==1
      shouldswitch=true
    end
    Kernel.pbMessage("Withdraw 10") if debugWithdraw
    if shouldswitch
      list=[]
      party=pbParty(index)
      for i in 0...party.length
        if pbCanSwitch?(index,i,false)
          # If perish count is 1, it may be worth it to switch
          # even with Spikes, since Perish Song's effect will end
          if @battlers[index].effects[PBEffects::PerishSong]!=1
            # Will contain effects that recommend against switching
            spikes=@battlers[index].pbOwnSide.effects[PBEffects::Spikes]
            if (spikes==1 && party[i].hp<=(party[i].totalhp/8)) ||
               (spikes==2 && party[i].hp<=(party[i].totalhp/6)) ||
               (spikes==3 && party[i].hp<=(party[i].totalhp/4))
              if !party[i].hasType?(:FLYING) &&
                 !party[i].hasWorkingAbility(:LEVITATE)
                # Don't switch to this if too little HP
                next
              end
            end
          end
          Kernel.pbMessage("Withdraw 10.1") if debugWithdraw
          #typemod=pbTypeModMove(move,@battlers[index],@battlers[index])
          Kernel.pbMessage("Withdraw 10.11") if debugWithdraw
          #if movetype>=0 && typemod==0
          if movetype>=0 && pbTypeModifier(movetype,@battlers[index],@battlers[index])==0
            weight=65
            if pbTypeModifier2(party[i],@battlers[index].pbOppositeOpposing)<16
              # Greater weight if new Pokemon's type is effective against opponent
              weight=85
            end
          Kernel.pbMessage("Withdraw 10.12") if debugWithdraw
            if pbAIRandom(100)<weight
              list.unshift(i) # put this Pokemon first
            end
          Kernel.pbMessage("Withdraw 10.13") if debugWithdraw
          elsif movetype>=0 && pbTypeModifier(movetype,@battlers[index],@battlers[index])<4
          #elsif movetype>=0 && typemod<4
            weight=40
            if pbTypeModifier2(party[i],@battlers[index].pbOppositeOpposing)<16
              # Greater weight if new Pokemon's type is effective against opponent
              weight=60
            end
          Kernel.pbMessage("Withdraw 10.14") if debugWithdraw
            if pbAIRandom(100)<weight
              list.unshift(i) # put this Pokemon first
            end
          Kernel.pbMessage("Withdraw 10.15") if debugWithdraw
          else
            list.push(i) # put this Pokemon last
          end
          Kernel.pbMessage("Withdraw 10.2") if debugWithdraw
        end
      end
      if list.length>0
        if batonpass!=-1
          if !pbRegisterMove(index,batonpass,false)
            #if pbRandom(4)==0
            return pbRegisterSwitch(index,list[0])
            #  else
            #    return false
            #end
          end
          return true
        else
         # if pbRandom(4)==0
          return pbRegisterSwitch(index,list[0])
        end
      end
      Kernel.pbMessage("Withdraw 10.3") if debugWithdraw
    end
    Kernel.pbMessage("Withdraw 11") if debugWithdraw
    return false
  end

  def pbEnemyShouldWithdraw?(index)
    #return false if !wildbattle && pbGetOwner(index).trainertype==PBTrainers::ELITEFOUR_BatonPass && !$game_switches[321]
    if $INTERNAL && !pbIsOpposing?(index)
      return pbEnemyShouldWithdrawOld?(index)
    end
    return pbEnemyShouldWithdrawEx?(index,false)
  end

  def pbChooseBestNewEnemy(index,party,enemies)
    return -1 if !enemies || enemies.length==0
    $PokemonTemp=PokemonTemp.new if !$PokemonTemp
    o1=@battlers[index].pbOpposing1
    o2=@battlers[index].pbOpposing2
    o1=nil if o1 && o1.hp<=0
    o2=nil if o2 && o2.hp<=0
    best=-1
    bestSum=0
    attacker=@battlers[index]
    if pbGetOwner(index).trainertype==PBTrainers::ELITEFOUR_Darude && !$game_switches[321]
      hippowdonAlive = -1
      cacturneAlive = -1
      tyranitarAlive = -1
      for i in 0..party.length-1
        pkmn=party[i]
        hippowdonAlive = i if pkmn.species==PBSpecies::HIPPOWDON && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        cacturneAlive = i if pkmn.species==PBSpecies::CACTURNE && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        tyranitarAlive = i if pkmn.species==PBSpecies::TYRANITAR && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
      end
      if pbWeather==PBWeather::SANDSTORM
        if cacturneAlive >= 0
          return cacturneAlive
        end
      else
        if hippowdonAlive >= 0
          return hippowdonAlive
        elsif tyranitarAlive>=0
          return tyranitarAlive
        end
      end
    end
    if pbGetOwner(index).trainertype==PBTrainers::ELITEFOUR_BatonPass && !$game_switches[321]#&& attacker.pokemon.species!=PBSpecies::SLOWBRO
      skillKayla=100
      if $PokemonSystem.chooseDifficulty==0
        skillKayla=PBTrainerAI.mediumSkill
      end
      #Kernel.pbMessage("Switching 1")
      #blazikenAlive=-1
      #smeargleAlive=-1
      #scizorAlive=-1
      #espeonAlive=-1
      #slowbroAlive=-1
      #sylveonAlive=-1
      #chosenValue=0
      #hasFire=false
      #for moves in o1.pokemon.moves
      #  if moves.type==PBTypes::FIRE && moves.basedamage > 0
      #    hasFire=true
      #    break
      #  end
      #end
      scores=[]
      for i in 0...party.length
        scores[i]=0
        pkmn=party[i]
      #Kernel.pbMessage("Switching 1.1")
        newbattler=PokeBattle_Battler.new(self,index)
      #Kernel.pbMessage("Switching 1.2")
        newbattler.pbInitDummyPokemon(party[i],i,true)
        newbattler.stages[PBStats::ATTACK]=attacker.stages[PBStats::ATTACK]
        newbattler.stages[PBStats::DEFENSE]=attacker.stages[PBStats::DEFENSE]
        newbattler.stages[PBStats::SPEED]=attacker.stages[PBStats::SPEED]
        newbattler.stages[PBStats::SPATK]=attacker.stages[PBStats::SPATK]
        newbattler.stages[PBStats::SPDEF]=attacker.stages[PBStats::SPDEF]
        newbattler.stages[PBStats::EVASION]=attacker.stages[PBStats::EVASION]
        newbattler.stages[PBStats::ACCURACY]=attacker.stages[PBStats::ACCURACY]
      #Kernel.pbMessage("Switching 1.3")
      #Kernel.pbMessage("Switching 1.4")
        if pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
      #Kernel.pbMessage("Switching 1.5")
          for moves in o1.moves
      #Kernel.pbMessage("Switching 1.6")
            if moves.basedamage>0
      #Kernel.pbMessage("Switching 1.7")
              score=pbGetMoveScore(moves,o1,newbattler,skillKayla)
      #Kernel.pbMessage("Switching 1.8")
              scores[i]=score if score>scores[i]
      #Kernel.pbMessage("Switching 1.9")
            end
          end
        else
          scores[i]=100000
      #Kernel.pbMessage("Switching 1.10")
        end
        #Kernel.pbMessage(_INTL("Score Init: {1}",scores[i]))
        #blazikenAlive = i if pkmn.species==PBSpecies::BLAZIKEN && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        #smeargleAlive = i if pkmn.species==PBSpecies::SMEARGLE && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        #scizorAlive = i if pkmn.species==PBSpecies::SCIZOR && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        #espeonAlive = i if pkmn.species==PBSpecies::ESPEON && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        #slowbroAlive = i if pkmn.species==PBSpecies::SLOWBRO && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        #sylveonAlive = i if pkmn.species==PBSpecies::SYLVEON && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
      end
      #Kernel.pbMessage("Switching 2")
      #if attacker.stages[PBStats::SPEED]<2
      #  if blazikenAlive>=0 && ((party[blazikenAlive].item==PBItems::FOCUSSASH && party[blazikenAlive].hp/party[blazikenAlive].totalhp == 1) || attacker.effects[PBEffects::Substitute]>0)
      #    return blazikenAlive 
      #  end
      #end
      #if attacker.stages[PBStats::ATTACK]<4 || attacker.stages[PBStats::DEFENSE]<4
      #  if scizorAlive>=0 && !hasFire
      #    return scizorAlive
      #  elsif blazikenAlive>=0 && (party[blazikenAlive].item==PBItems::FOCUSSASH || attacker.effects[PBEffects::Substitute]>0)
      #    return blazikenAlive
      #  end
      #end
      #if attacker.stages[PBStats::SPATK]<4 || attacker.stages[PBStats::SPDEF]<4
      #  if sylveonAlive>=0 && o1.pbHasType?(PBTypes::DARK)
      #    return sylveonAlive
      #  end
      #  if espeonAlive>=0 && o1.pbHasType?(PBTypes::STEEL) && o1.pbHasType?(PBTypes::POISON) && !o1.pbHasType?(PBTypes::DARK)
      #    return espeonAlive
      #  end
      #  if espeonAlive>=0 && party[espeonAlive].hp/party[espeonAlive].totalhp > 0.25 && attacker.effects[PBEffects::Substitute]<1
      #    return espeonAlive
      #  end
      #  if sylveonAlive>=0
      #    return sylveonAlive
      #  end
      #  if espeonAlive>=0
      #    return espeonAlive
      #  end
      #end
      #if slowbroAlive>=0
      #  return slowbroAlive
      #end
      return scores.index(scores.min)
    end
    for e in enemies
      pkmn=party[e]
      sum=0
      for move in pkmn.moves
        next if move.id==0
        md=PBMoveData.new(move.id)
        next if md.basedamage==0
        if o1
          sum+=PBTypes.getCombinedEffectiveness(md.type,o1.type1,o1.type2)
        end
        if o2
          sum+=PBTypes.getCombinedEffectiveness(md.type,o2.type1,o2.type2)
        end
      end
      if best==-1 || sum>bestSum
        best=e
        bestSum=sum
      end
    end
    return best
  end

################################################################################
# Other functions.
################################################################################
  def pbDbgPlayerOnly?(idx)
    return true if !$INTERNAL
    return pbOwnedByPlayer?(idx.index) if idx.respond_to?("index")
    return pbOwnedByPlayer?(idx)
  end

  def pbStdDev(scores)
    n=0
    sum=0
    scores.each{|s| sum+=s; n+=1 }
    return 0 if n==0
    mean=sum.to_f/n.to_f
    varianceTimesN=0
    for i in 0...scores.length
      if scores[i]>0
        deviation=scores[i].to_f-mean
        varianceTimesN+=deviation*deviation
      end
    end
    # Using population standard deviation 
    # [(n-1) makes it a sample std dev, would be 0 with only 1 sample]
    return Math.sqrt(varianceTimesN/n)
  end
  
  def canBreakSubstitute?(move,attacker,opponent,skill)
    if move.basedamage>0
      typemod=pbTypeModMove(move,attacker,opponent)
      if typemod==0
        return false
      elsif skill>=PBTrainerAI.mediumSkill && typemod<=4 &&
            opponent.hasWorkingAbility(:WONDERGUARD)
        return false
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:GROUND) &&
            (opponent.hasWorkingAbility(:LEVITATE) ||
            opponent.effects[PBEffects::MagnetRise]>0)
        return false
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:FIRE) &&
            opponent.hasWorkingAbility(:FLASHFIRE) ||
            pbWeather==PBWeather::HEAVYRAIN
        return false
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:WATER) &&
            (opponent.hasWorkingAbility(:WATERABSORB) ||
            opponent.hasWorkingAbility(:STORMDRAIN) ||
            opponent.hasWorkingAbility(:DRYSKIN) ||
            opponent.hasWorkingAbility(:VAPORIZATION) ||
            pbWeather==PBWeather::HARSHSUN)
        return false
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:GRASS) &&
            opponent.hasWorkingAbility(:SAPSIPPER)
        return false
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:ELECTRIC) &&
            (opponent.hasWorkingAbility(:VOLTABSORB) ||
            opponent.hasWorkingAbility(:LIGHTNINGROD) ||
            opponent.hasWorkingAbility(:MOTORDRIVE))
        return false
      elsif skill>=PBTrainerAI.mediumSkill && isConst?(move.type,PBTypes,:FLYING) &&
            opponent.hasWorkingAbility(:WINDFORCE)
        return false
      elsif skill>=PBTrainerAI.mediumSkill && opponent.hasWorkingAbility(:BULLETPROOF) &&
            move.isBombMove?
        return false
      else
        realDamage=move.basedamage
        realDamage=60 if move.basedamage==1
        if skill>=PBTrainerAI.mediumSkill
          realDamage=pbBetterBaseDamage(move,attacker,opponent,skill,realDamage)
        end
        realDamage=pbRoughDamage(move,attacker,opponent,skill,realDamage)
        # Convert damage to proportion of opponent's total HP
        realDamage=(realDamage*100.0/opponent.totalhp)
        # If attack deals at least 25% of target's HP in damage, sub can be broken
        if realDamage>=25
          return true
        end
      end
    end
    return false
  end
  
  def movesRestricted?(attacker)
    return true if attacker.effects[PBEffects::Taunt]>0
    return true if (isConst?(attacker.item,PBItems,:CHOICEBAND) || isConst?(attacker.item,PBItems,:CHOICESPECS) || isConst?(attacker.item,PBItems,:CHOICESCARF))
    return true if attacker.effects[PBEffects::Torment]
    return true if attacker.effects[PBEffects::Encore]>0
    return true if attacker.effects[PBEffects::Disable]>0
    return true if attacker.effects[PBEffects::PerishSong]>0 # This is specifically for Kayla, if using this for other trainers later, this will need to be modified
    return true if attacker.hasWorkingItem(:ASSAULTVEST)
    if attacker.pbOpposing1.effects[PBEffects::Imprison]
      for move in attacker.moves
        if move.id==attacker.pbOpposing1.moves[0].id ||
           move.id==attacker.pbOpposing1.moves[1].id ||
           move.id==attacker.pbOpposing1.moves[2].id ||
           move.id==attacker.pbOpposing1.moves[3].id
          return true
        end
      end
    end
    for move in attacker.moves
      struggle=true
      break if move.pp==0
      struggle=false
    end
    return true if struggle
    return false
  end
end