=begin class PokeBattle_Battle
################################################################################
# Get a score for each move being considered.
# Moves with higher scores are more likely to be chosen.
################################################################################
  def pbGetMoveScore(move,attacker,opponent,skill=100)
    score=100
    if isConst?(move.type,PBMoves,:FAIRY) && pbWeather==PBWeather::NEWMOON
      score-=30
      
    elsif (isConst?(move.type,PBMoves,:DARK) || isConst?(move.type,PBMoves,:GHOST)) && pbWeather==PBWeather::NEWMOON
    
        score+=30
    end
    
# Alter score depending on the move's function code.
    case move.function
      when 0x00
        if move.priority>0
          score+=15
          score+=20 if attacker.hp<=(attacker.totalhp/2)
        end
        if (move.flags&0x80)!=0 # flag h: Has high critical hit rate
          score+=40 if attacker.effects[PBEffects::FocusEnergy]>0
        end
      when 0x01
        score-=100
      when 0x02 # Struggle
      when 0x03
        score-=80 if opponent.status!=0
        score-=60 if opponent.effects[PBEffects::Yawn]>0
        if move.basedamage==0
          score-=70 if !opponent.pbCanSleep?(false)
          score-=70 if $justUsedStatusCure
        end
      when 0x04
        score-=80 if opponent.status!=0
        score-=80 if opponent.effects[PBEffects::Yawn]>0
        score-=40 if !opponent.pbCanSleep?(false)
        score-=40 if $justUsedStatusCure
      when 0x05
        score-=15 if opponent.status==PBStatuses::POISON
        if move.basedamage==0
          score-=30 if @choices[attacker.index][0]=3
          score-=90 if !opponent.pbCanPoison?(false)
          score-=90 if $justUsedStatusCure
        end
        if (move.flags&0x80)!=0 # flag h: Has high critical hit rate
          score+=20 if attacker.effects[PBEffects::FocusEnergy]>0
        end
      when 0x06
        if move.basedamage==0
          if !opponent.pbCanPoison?(false)
            score-=90
          elsif attacker.turncount<4
            score+=90
          else
            score+=40
          end
        else
          
          score-=20 if opponent.status==PBStatuses::POISON
        end
      when 0x07
        if move.basedamage==0
          if !opponent.pbCanParalyze?(false) || pbTypeModifier(move.type,attacker,opponent)==0
            score-=80
          else
            score+=30 if pbRoughStat(attacker,
               PBStats::SPEED)<pbRoughStat(opponent,PBStats::SPEED)
            score+=70 if attacker.turncount<3
            score+=40 if attacker.turncount>=3  
          end
        else
          score+=15 if pbRoughStat(attacker,
             PBStats::SPEED)<pbRoughStat(opponent,PBStats::SPEED)
          score-=10 if opponent.status==PBStatuses::PARALYSIS
        end
      when 0x08
        score-=50 if pbWeather==PBWeather::SUNNYDAY
        score+=30 if pbWeather==PBWeather::RAINDANCE
      when 0x09
        score+=15 if pbRoughStat(attacker,
           PBStats::SPEED)<pbRoughStat(opponent,PBStats::SPEED)
        score-=10 if opponent.status==PBStatuses::PARALYSIS
        if (move.flags&0x80)!=0 # flag h: Has high critical hit rate
          score+=20 if attacker.effects[PBEffects::FocusEnergy]>0
        end
      when 0x149
        if opponent.pbHasType?(:GRASS)
          score+=200 if opponent.status==0
          score-=80 if opponent.status!=0
        else           
          score-=80 if opponent.status!=0
          score-=90 if opponent.pbHasType?(:FIRE)
        end
        
        when 0x0A
        if move.basedamage==0
          score-=80 if opponent.status!=0
          score-=90 if opponent.pbHasType?(:FIRE)
        else
          score-=10 if opponent.status==PBStatuses::BURN
          score-=40 if opponent.pbHasType?(:FIRE)
        end
        
        if (move.flags&0x40)==0 # flag g: Thaws user before moving
          score+=70 if attacker.status==PBStatuses::FROZEN
        end
        if (move.flags&0x80)!=0 # flag h: Has high critical hit rate
          score+=20 if attacker.effects[PBEffects::FocusEnergy]>0
        end
      when 0x0B
        score-=10 if opponent.status==PBStatuses::BURN
        score-=40 if opponent.pbHasType?(:FIRE)
        if (move.flags&0x80)!=0 # flag h: Has high critical hit rate
          score+=20 if attacker.effects[PBEffects::FocusEnergy]>0
        end
      when 0x0C
        if move.basedamage==0
          score-=80 if opponent.status!=0
          score-=90 if opponent.pbHasType?(:ICE)
        else
          score-=10 if opponent.status==PBStatuses::FROZEN
        end
      when 0x0D
        score-=10 if opponent.status==PBStatuses::FROZEN
        score+=30 if pbWeather==PBWeather::HAIL
      when 0x0E
        score-=10 if opponent.status==PBStatuses::FROZEN
        if (move.flags&0x80)!=0 # flag h: Has high critical hit rate
          score+=20 if attacker.effects[PBEffects::FocusEnergy]>0
        end
      when 0x0F
        score-=10 if isConst?(opponent.ability,PBAbilities,:INNERFOCUS)
      when 0x10
        score+=40 if opponent.effects[PBEffects::Minimize]
      when 0x11
        score-=140 if attacker.status!=PBStatuses::SLEEP
        score+=70 if attacker.status==PBStatuses::SLEEP
      when 0x12
        score-=200 if attacker.turncount>=1
      when 0x13
        if move.basedamage==0
          if !opponent.pbCanConfuse?(false)
            score-=80
          elsif move.accuracy>=75
            score+=70 if attacker.turncount<3
            score+=40 if attacker.turncount>=3  
          end
        else
          score-=10 if !opponent.pbCanConfuse?(false)
        end
      when 0x14
      when 0x15
        score-=10 if !opponent.pbCanConfuse?(false)
        score-=50 if pbWeather==PBWeather::SUNNYDAY
        score+=30 if pbWeather==PBWeather::RAINDANCE
      when 0x16
        agender=attacker.gender
        ogender=opponent.gender
        if agender==2 || ogender==2 || agender==ogender
         score-=80
        elsif opponent.effects[PBEffects::Attract]>=0
          score-=90
        end
        if isConst?(opponent.ability,PBAbilities,:OBLIVIOUS)
          score-=80
        end
      when 0x17
        score-=10 if opponent.status==PBStatuses::BURN
        score-=10 if opponent.status==PBStatuses::FROZEN
        score-=10 if opponent.status==PBStatuses::PARALYSIS
      when 0x18
        score-=80 if attacker.status==0
      when 0x19
        party=pbParty(opponent.index)
        statuses=0
        for i in 0...party.length
          statuses+=1 if party[i] && party[i].status!=0
        end
        score-=80 if statuses==0
      when 0x1A
        if attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
          score-=80 
        else
          score+=30
        end
      when 0x1B
      when 0x1C
        if move.basedamage==0
          score-=80 if attacker.pbTooHigh?(PBStats::ATTACK)
          if skill>=50
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            score-=80 if !hasAttack
          end
          if score>20
            score-=(attacker.stages[PBStats::ATTACK]*10)
          end
        else
          score+=20 if (attacker.stages[PBStats::ATTACK]<0)
        end
      when 0x1D
        if move.basedamage==0
          score-=80 if attacker.pbTooHigh?(PBStats::DEFENSE)
          score-=(attacker.stages[PBStats::DEFENSE]*10)
        else
          score+=20 if (attacker.stages[PBStats::DEFENSE]<0)
        end
      when 0x1E
        score-=(attacker.stages[PBStats::DEFENSE]*10)
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
          score-=80 if attacker.pbTooHigh?(PBStats::SPEED)
          score-=(attacker.stages[PBStats::SPEED]*10)
        else
          score+=20 if (attacker.stages[PBStats::SPEED]<0)
        end
      when 0x20
        if move.basedamage==0
          score-=80 if attacker.pbTooHigh?(PBStats::SPATK)
          score-=(attacker.stages[PBStats::SPATK]*10)
        else
          score+=20 if (attacker.stages[PBStats::SPATK]<0)
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
          score-=80 if !found
          score-=80 if opponent.effects[PBEffects::Charge]>0
          score-=80 if attacker.pbTooHigh?(PBStats::SPDEF)
          score-=(attacker.stages[PBStats::SPDEF]*10)
        else
          score-=20 if !found
          score-=20 if opponent.effects[PBEffects::Charge]>0
          score+=20 if (attacker.stages[PBStats::SPDEF]<0)
        end
      when 0x22
        if move.basedamage==0
          score-=80 if attacker.pbTooHigh?(PBStats::EVASION)
          score-=(attacker.stages[PBStats::EVASION]*10)
        else
          score+=20 if (attacker.stages[PBStats::EVASION]<0)
        end
      when 0x23
        if move.basedamage==0
          score-=80 if attacker.effects[PBEffects::FocusEnergy]>0
        else
          score-=20 if attacker.effects[PBEffects::FocusEnergy]>0
        end
      when 0x24
        score-=80 if attacker.pbTooHigh?(PBStats::ATTACK) &&
                     attacker.pbTooHigh?(PBStats::DEFENSE)
        if score>20
          avg=-(attacker.stages[PBStats::ATTACK]*10)
          avg-=(attacker.stages[PBStats::DEFENSE]*10)
          score+=avg/2
        end
      when 0x25
        score-=80 if attacker.pbTooHigh?(PBStats::ATTACK) &&
                     attacker.pbTooHigh?(PBStats::DEFENSE) &&
                     attacker.pbTooHigh?(PBStats::ACCURACY)
        if score>20
          avg=-(attacker.stages[PBStats::ATTACK]*10)
          avg-=(attacker.stages[PBStats::DEFENSE]*10)
          avg-=(attacker.stages[PBStats::ACCURACY]*10)
          score+=avg/3
        end
      when 0x26 # Dragon Dance tends to be popular
        score+=40 if attacker.turncount==0
        score-=80 if attacker.pbTooHigh?(PBStats::ATTACK) &&
                     attacker.pbTooHigh?(PBStats::SPEED)
        if score>20
          avg=-(attacker.stages[PBStats::ATTACK]*10)
          avg-=(attacker.stages[PBStats::SPEED]*10)
          score+=avg/2
        end
      when 0x27
        score-=80 if attacker.pbTooHigh?(PBStats::ATTACK) &&
                     attacker.pbTooHigh?(PBStats::SPATK)
        if score>20
          avg=-(attacker.stages[PBStats::ATTACK]*10)
          avg-=(attacker.stages[PBStats::SPATK]*10)
          score+=avg/2
        end
      when 0x28
        score-=80 if attacker.pbTooHigh?(PBStats::ATTACK) &&
                     attacker.pbTooHigh?(PBStats::SPATK)
        if score>20
          avg=-(attacker.stages[PBStats::ATTACK]*10)
          avg-=(attacker.stages[PBStats::SPATK]*10)
          score+=avg/2
        end
        score+=20 if pbWeather==PBWeather::SUNNYDAY
      when 0x29
        score+=20 if pbWeather==PBWeather::NEWMOON
        score-=80 if attacker.pbTooHigh?(PBStats::ATTACK) &&
                     attacker.pbTooHigh?(PBStats::ACCURACY)
        if score>20
          avg=-(attacker.stages[PBStats::ATTACK]*10)
          avg-=(attacker.stages[PBStats::ACCURACY]*10)
          score+=avg/2
        end
      when 0x2A
        score-=80 if attacker.pbTooHigh?(PBStats::DEFENSE) &&
                     attacker.pbTooHigh?(PBStats::SPDEF)
        if score>20
          avg=-(attacker.stages[PBStats::DEFENSE]*10)
          avg-=(attacker.stages[PBStats::SPDEF]*10)
          score+=avg/2
        end
      when 0x2B
        score-=80 if attacker.pbTooHigh?(PBStats::SPEED) &&
                     attacker.pbTooHigh?(PBStats::SPATK) &&
                     attacker.pbTooHigh?(PBStats::SPDEF)
        if score>20
          avg=-(attacker.stages[PBStats::SPEED]*10)
          avg-=(attacker.stages[PBStats::SPATK]*10)
          avg-=(attacker.stages[PBStats::SPDEF]*10)
          score+=avg/3
        end
      when 0x2C # Calm Mind tends to be popular
        score+=40 if attacker.turncount==0
        score-=80 if attacker.pbTooHigh?(PBStats::SPATK) &&
                     attacker.pbTooHigh?(PBStats::SPDEF)
        if score>20
          avg=-(attacker.stages[PBStats::SPATK]*10)
          avg-=(attacker.stages[PBStats::SPDEF]*10)
          score+=avg/2
        end
      when 0x2D
        score+=10 if (attacker.stages[PBStats::ATTACK]<0)
        score+=10 if (attacker.stages[PBStats::DEFENSE]<0)
        score+=10 if (attacker.stages[PBStats::SPEED]<0)
        score+=10 if (attacker.stages[PBStats::SPATK]<0)
        score+=10 if (attacker.stages[PBStats::SPDEF]<0)
      when 0x2E
        if move.basedamage==0
          score-=80 if attacker.pbTooHigh?(PBStats::ATTACK)
          if skill>=50
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            score-=80 if !hasAttack
          end
          if score>20
            score+=60 if attacker.turncount==0
            score-=(attacker.stages[PBStats::ATTACK]*20)
          end
        else
          score-=20 if attacker.pbTooHigh?(PBStats::ATTACK)
          if skill>=50
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            score-=20 if !hasAttack
          end
          if score>20
            score+=10 if attacker.turncount==0
            score-=(attacker.stages[PBStats::ATTACK]*10)
          end
        end
      when 0x2F
        if move.basedamage==0
          score-=80 if attacker.pbTooHigh?(PBStats::DEFENSE)
          if score>20
            score-=(attacker.stages[PBStats::DEFENSE]*20)
          end
        else
          score+=20 if (attacker.stages[PBStats::DEFENSE]<0)
        end
      when 0x30
        if move.basedamage==0
          if skill>=70
            score-=80 if pbRoughStat(attacker,
               PBStats::SPEED)>pbRoughStat(opponent,PBStats::SPEED)
          end
          score-=80 if attacker.pbTooHigh?(PBStats::SPEED)
          if score>20
            score-=(attacker.stages[PBStats::SPEED]*20)
          end
        else
          score+=20 if (attacker.stages[PBStats::SPEED]<0)
        end
      when 0x31
        if skill>=70
          score-=80 if pbRoughStat(attacker,
             PBStats::SPEED)>pbRoughStat(opponent,PBStats::SPEED)
        end
        score-=80 if attacker.pbTooHigh?(PBStats::SPEED)
        if score>20
          score-=(attacker.stages[PBStats::SPEED]*20)
        end
      when 0x32
        if move.basedamage==0
          score-=80 if attacker.pbTooHigh?(PBStats::SPATK)
          if skill>=50
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 !thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            score-=80 if !hasAttack
          end
          if score>20
            score+=60 if attacker.turncount==0
            score-=(attacker.stages[PBStats::SPATK]*20)
          end
        else
          score-=20 if attacker.pbTooHigh?(PBStats::SPATK)
          if skill>=50
            hasAttack=false
            for thismove in attacker.moves
              if thismove.id!=0 && thismove.basedamage>0 &&
                 !thismove.pbIsPhysical?(thismove.type)
                hasAttack=true
              end
            end
            score-=20 if !hasAttack
          end
          if score>20
            score+=20 if attacker.turncount==0
            score-=(attacker.stages[PBStats::SPATK]*10)
          end
        end
      when 0x33
        if move.basedamage==0
          score-=80 if attacker.pbTooHigh?(PBStats::SPDEF)
          if score>20
            score-=(attacker.stages[PBStats::SPDEF]*20)
          end
        else
          score-=20 if attacker.pbTooHigh?(PBStats::SPDEF)
          if score>20
            score-=(attacker.stages[PBStats::SPDEF]*10)
          end
        end
      when 0x34
        score-=(attacker.stages[PBStats::EVASION]*10)
      when 0x35
        score-=80 if attacker.pbTooHigh?(PBStats::ATTACK) &&
                     attacker.pbTooHigh?(PBStats::SPEED) &&
                     attacker.pbTooHigh?(PBStats::SPATK)
        if score>20
          avg=-(attacker.stages[PBStats::ATTACK]*20)
          avg-=(attacker.stages[PBStats::SPEED]*20)
          avg-=(attacker.stages[PBStats::SPATK]*20)
          score+=avg/3
        end
      when 0x36
        score-=80 if attacker.pbTooHigh?(PBStats::ATTACK) &&
                     attacker.pbTooHigh?(PBStats::SPEED)
        if score>20
          avg=-(attacker.stages[PBStats::ATTACK]*10)
          avg-=(attacker.stages[PBStats::SPEED]*20)
          score+=avg/2
        end
      when 0x37
      when 0x38
        if move.basedamage==0
          score-=80 if attacker.pbTooHigh?(PBStats::DEFENSE)
          score-=(attacker.stages[PBStats::DEFENSE]*30)
        else
          score+=30 if (attacker.stages[PBStats::DEFENSE]<0)
        end
      when 0x39
        score-=80 if attacker.pbTooHigh?(PBStats::SPATK)
        if skill>=50
          hasAttack=false
          for thismove in attacker.moves
            if thismove.id!=0 && thismove.basedamage>0 &&
               !thismove.pbIsPhysical?(thismove.type)
              hasAttack=true
            end
          end
          score-=80 if !hasAttack
        end
        if score>20
          score-=(attacker.stages[PBStats::SPATK]*30)
        end
      when 0x3A
        if attacker.hp<=attacker.totalhp/2 || attacker.pbTooHigh?(PBStats::ATTACK)
          score-=100
        end
      when 0x3B
        avg=(attacker.stages[PBStats::ATTACK]*10)
        avg+=(attacker.stages[PBStats::DEFENSE]*10)
        score+=avg/2
      when 0x3C
        avg=(attacker.stages[PBStats::DEFENSE]*10)
        avg+=(attacker.stages[PBStats::SPDEF]*10)
        score+=avg/2
      when 0x3D
        avg=(attacker.stages[PBStats::DEFENSE]*10)
        avg+=(attacker.stages[PBStats::SPEED]*10)
        avg+=(attacker.stages[PBStats::SPDEF]*10)
        score+=avg/3
      when 0x3E
        score+=(attacker.stages[PBStats::SPEED]*10)
      when 0x3F
        score+=(attacker.stages[PBStats::SPATK]*10)
      when 0x40
        if !opponent.pbCanConfuse?(false)
          score-=90
        elsif opponent.stages[PBStats::SPATK]<0 
          score+=30
        end
      when 0x41
        if !opponent.pbCanConfuse?(false)
          score-=90
        elsif opponent.stages[PBStats::ATTACK]<0 
          score+=30
        end
      when 0x42
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK)
          if score>20
            score+=(opponent.stages[PBStats::ATTACK]*10)
          end
        else
          score-=10 if opponent.stages[PBStats::ATTACK]<0
        end
      when 0x43
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE)
          if score>20
            score+=(opponent.stages[PBStats::DEFENSE]*10)
          end
        else
          score-=10 if opponent.stages[PBStats::DEFENSE]<0
        end
      when 0x44
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::SPEED)
          score-=80 if pbRoughStat(attacker,
             PBStats::SPEED)>pbRoughStat(opponent,PBStats::SPEED)
          if score>20
            score+=(opponent.stages[PBStats::SPEED]*10)
          end
        else
          score-=10 if opponent.stages[PBStats::SPEED]<0
        end
      when 0x45
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::SPATK)
          if score>20
            score+=(opponent.stages[PBStats::SPATK]*10)
          end
        else
          score-=10 if opponent.stages[PBStats::SPATK]<0
        end
      when 0x46
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF)
          if score>20
            score+=(opponent.stages[PBStats::SPDEF]*10)
          end
        else
          score-=10 if opponent.stages[PBStats::SPDEF]<0
        end
      when 0x47
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY)
          if score>20
            score+=(opponent.stages[PBStats::ACCURACY]*10)
          end
        else
          score-=10 if opponent.stages[PBStats::ACCURACY]<0
        end
      when 0x48
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::EVASION)
          if score>20
            score+=(opponent.stages[PBStats::EVASION]*10)
          end
        else
          score-=10 if opponent.stages[PBStats::EVASION]<0
        end
      when 0x49
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::EVASION)
          if score>20
            score+=(opponent.stages[PBStats::EVASION]*10)
          end
          score-=60 if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                       attacker.pbOwnSide.effects[PBEffects::Mist]>0 ||
                       attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                       attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
          score+=30 if attacker.pbOwnSide.effects[PBEffects::Spikes]>0
        else
          score-=10 if opponent.stages[PBStats::EVASION]<0
          score-=20 if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                       attacker.pbOwnSide.effects[PBEffects::Mist]>0 ||
                       attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                       attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
          score+=10 if attacker.pbOwnSide.effects[PBEffects::Spikes]>0
        end
      when 0x4A
        avg=(opponent.stages[PBStats::ATTACK]*10)
        avg+=(opponent.stages[PBStats::DEFENSE]*10)
        score+=avg/2
      when 0x4B
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK)
          if score>20
            score+=(opponent.stages[PBStats::ATTACK]*20)
          end
        else
          score-=20 if opponent.stages[PBStats::ATTACK]<0
        end
      when 0x4C
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE)
          if score>20
            score+=(opponent.stages[PBStats::DEFENSE]*20)
          end
        else
          score-=20 if opponent.stages[PBStats::DEFENSE]<0
        end
      when 0x4D
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::SPEED)
          score-=80 if pbRoughStat(attacker,
             PBStats::SPEED)>pbRoughStat(opponent,PBStats::SPEED)
          if score>20
            score+=(opponent.stages[PBStats::SPEED]*20)
          end
        else
          score-=20 if opponent.stages[PBStats::SPEED]<0
        end
      when 0x4E
        score-=80 if !opponent.pbCanReduceStatStage?(PBStats::SPATK)
        if score>20
          score+=(opponent.stages[PBStats::SPATK]*20)
        end
        agender=attacker.gender
        ogender=opponent.gender
        if agender==2 || ogender==2 || agender==ogender
         score-=80
        end
        if isConst?(opponent.ability,PBAbilities,:OBLIVIOUS)
          score-=80
        end
      when 0x4F
        if move.basedamage==0
          score-=80 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF)
          if score>20
            score+=(opponent.stages[PBStats::SPDEF]*20)
          end
        else
          score-=20 if opponent.stages[PBStats::SPDEF]<0
        end
      when 0x50
      when 0x51
        stages=0
        for i in 0..3
          battler=@battlers[i]
          stages+=battler.stages[PBStats::ATTACK]
          stages+=battler.stages[PBStats::DEFENSE]
          stages+=battler.stages[PBStats::SPEED]
          stages+=battler.stages[PBStats::SPATK]
          stages+=battler.stages[PBStats::SPDEF]
          stages+=battler.stages[PBStats::EVASION]
          stages+=battler.stages[PBStats::ACCURACY]
        end
        score-=80 if stages==0
      when 0x52
      when 0x53
      when 0x54
      when 0x55
        equal=true
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                 PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          score+=10 if opponent.stages[i]>attacker.stages[i]
          score-=10 if opponent.stages[i]<attacker.stages[i]
          equal=false if opponent.stages[i]!=attacker.stages[i]
        end
        score-=80 if equal
      when 0x56
        score-=80 if attacker.pbOwnSide.effects[PBEffects::Mist]>0
      when 0x57
      when 0x58
      when 0x59
      when 0x5A
        oldahp=attacker.hp
        oldohp=opponent.hp
        avghp=((opponent.hp+attacker.hp)/2).floor
        attackerhp=avghp
        opponenthp=avghp
        attackerhp=attacker.totalhp if attackerhp>attacker.totalhp
        opponenthp=opponent.totalhp if opponenthp>opponent.totalhp
        if opponenthp>opponent.hp || attackerhp<attacker.hp
          score-=80
        elsif opponent.effects[PBEffects::Substitute]>0
          score-=80
        else
      	  score+=30
        end
      when 0x5B
      when 0x5C
      when 0x5D
      when 0x5E
      when 0x5F
      when 0x60
        score-=80 if isConst?(attacker.ability(true),PBAbilities,:MULTITYPE)
        envtypes=[:NORMAL,  # None
                  :GRASS,   # Grass
                  :GRASS,   # Tall grass
                  :WATER,   # Moving water
                  :WATER,   # Still water
                  :WATER,   # Underwater
                  :ROCK,    # Rock
                  :ROCK,    # Cave
                  :GROUND]  # Sand
        type=envtypes[@environment]
        score-=80 if attacker.pbHasType?(type)
      when 0x61
      when 0x62
      when 0x63
      when 0x64
      when 0x65
        score-=80 if isConst?(opponent.ability(true),PBAbilities,:WONDERGUARD)
        score-=80 if attacker.ability==opponent.ability
      when 0x66
        score-=80 if isConst?(attacker.ability(true),PBAbilities,:WONDERGUARD)
        score-=80 if attacker.ability==opponent.ability
      when 0x67
        if isConst?(opponent.ability(true),PBAbilities,:WONDERGUARD) ||
           isConst?(attacker.ability(true),PBAbilities,:WONDERGUARD)
          score-=80
        end
        if skill>=80
          if opponent.ability==attacker.ability ||
             (isConst?(opponent.ability(true),PBAbilities,:TRUANT) && 
             attacker.pbIsOpposing?(opponent.index)) ||
             (isConst?(opponent.ability(true),PBAbilities,:SLOWSTART) &&
             attacker.pbIsOpposing?(opponent.index))
            score-=90
          end
        end
        score-=40 # don't prefer this move
      when 0x68
      when 0x69
      when 0x6A
        if opponent.hp<=20
          score+=50
        elsif opponent.level>=25
          score-=85 # Not useful against high-level Pokemon
        end
      when 0x6B
        score+=50 if opponent.hp<=40
      when 0x6C
        score-=50
        score+=(opponent.hp*100/opponent.totalhp)
      when 0x6D
        score+=50 if opponent.hp<=attacker.level
      when 0x6E
        score-=200 if attacker.hp>=opponent.hp
      when 0x6F
        score+=20 if opponent.hp<=attacker.level
      when 0x70
        score-=90 if isConst?(opponent.ability,PBAbilities,:STURDY)
        score-=80 if attacker.level<opponent.level
      when 0x71
        attack=pbRoughStat(attacker,PBStats::ATTACK)
        spatk=pbRoughStat(attacker,PBStats::SPATK)
        if attack<spatk
          score-=60
        elsif opponent.effects[PBEffects::HyperBeam]>0
          score-=90
        elsif opponent.lastMoveUsed>0
          moveData=PBMoveData.new(opponent.lastMoveUsed)
          if moveData.basedamage>0 &&
             (USEMOVECATEGORY && moveData.category==2) ||
             (!USEMOVECATEGORY && PBTypes.isSpecialType?(moveData.type))
            score-=60
          end
        end
      when 0x72
        attack=pbRoughStat(attacker,PBStats::ATTACK)
        spatk=pbRoughStat(attacker,PBStats::SPATK)
        if attack>spatk
          score-=60
        elsif opponent.effects[PBEffects::HyperBeam]>0
          score-=90
        elsif opponent.lastMoveUsed>0
          moveData=PBMoveData.new(opponent.lastMoveUsed)
          if moveData.basedamage>0 &&
             (USEMOVECATEGORY && moveData.category==1) ||
             (!USEMOVECATEGORY && !PBTypes.isSpecialType?(moveData.type))
            score-=60
          end
        end
      when 0x73
      when 0x74
      when 0x75
        score+=20 if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
      when 0x76
        score+=20 if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG)
      when 0x77
        score+=20 if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
                     isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY)
      when 0x78
        score+=20 if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
                     isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY)
      when 0x79
      when 0x7A
      when 0x7B
        score+=50 if opponent.status==PBStatuses::POISON
      when 0x7C
        score+=50 if opponent.status==PBStatuses::PARALYSIS
      when 0x7D
        score+=50 if opponent.status==PBStatuses::SLEEP
        score+=10 if opponent.statusCount<=1
      when 0x7E
        score+=50 if (attacker.status==PBStatuses::POISON ||
                      attacker.status==PBStatuses::BURN ||
                      attacker.status==PBStatuses::PARALYSIS)
      when 0x7F
        score+=50 if attacker.status!=0
      when 0x80
        score+=50 if opponent.hp<=opponent.totalhp/2
      when 0x81
        score+=50 if attacker.lastHPLost>0 && attacker.lastAttacker==opponent.index
      when 0x82
        score+=50 if opponent.lastHPLost>0
      when 0x83
      when 0x84
      when 0x85
      when 0x86
        score+=50 if attacker.item==0 || isConst?(opponent.item,PBItems,:FLYINGGEM)
      when 0x87
        score+=50 if pbWeather!=0
      when 0x88
      when 0x89
        damage=(attacker.happiness*10/25).floor
        damage/=2
        score+=damage-25
      when 0x8A
        damage=((255-attacker.happiness)*10/25).floor
        damage/=2
        score+=damage-25
      when 0x8B
        score-=50
        score+=(attacker.hp*100/attacker.totalhp)
      when 0x8C
        score-=50
        score+=(opponent.hp*100/opponent.totalhp)
      when 0x8D
        score-=50
        attspeed=pbRoughStat(attacker,PBStats::SPEED)
        oppspeed=pbRoughStat(opponent,PBStats::SPEED)
        score+=(oppspeed*50/attspeed)

      when 0x8E
        mods=0

        for i in attacker.stages

          mods += i if i != nil && i>0

        end

        mods=8 if mods>=8

        score+=mods*10

      when 0x8F
        mods=0
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                  PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          mods+=opponent.stages[i] if opponent.stages[i]>0 != nil && opponent.stages[i]>0
        end
        mods=7 if mods>=7
        score+=mods*10
      when 0x90
      when 0x91
        if attacker.effects[PBEffects::FuryCutter]<5
          score+=(attacker.effects[PBEffects::FuryCutter]*10)
        end
      when 0x92
      when 0x93
        score+=25 if attacker.effects[PBEffects::Rage]
      when 0x94
      when 0x95
      when 0x96
      when 0x97
        score+=(5-move.pp)*10 if move.pp<=2
      when 0x98
        score+=50
        score-=(attacker.hp*100/attacker.totalhp)
      when 0x99
        score-=20
        attspeed=pbRoughStat(attacker,PBStats::SPEED)
        oppspeed=pbRoughStat(opponent,PBStats::SPEED)
        score+=(attspeed*20/oppspeed)
      when 0x9A
      when 0x9B
      when 0x9C
        score-=80 if attacker.pbPartner.hp==0
      when 0x9D
        score-=80 if attacker.effects[PBEffects::MudSport]
      when 0x9E
        score-=80 if attacker.effects[PBEffects::WaterSport]
      when 0x9F
      when 0xA0
      when 0xA1
      when 0xA2
        score-=80 if attacker.pbOwnSide.effects[PBEffects::Reflect]>0
      when 0xA3
        score-=80 if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
      when 0xA4
      when 0xA5
        score+=10
      when 0xA6
        score-=80 if opponent.effects[PBEffects::LockOn]>0
      when 0xA7
        score-=35 if opponent.stages[PBStats::EVASION]<=0
        score-=45 if !attacker.pbHasType?(:GHOST)
        score-=80 if opponent.effects[PBEffects::Foresight]
      when 0xA8
        score-=35 if opponent.stages[PBStats::EVASION]<=0
        score-=45 if !attacker.pbHasType?(:DARK)
        score-=80 if opponent.effects[PBEffects::MiracleEye]
      when 0xA9
      when 0xAA
        score-=10
        if skill>=50
          score-=90 if attacker.effects[PBEffects::ProtectRate]>1
          score-=90 if opponent.effects[PBEffects::HyperBeam]>0
        else
          score-=(attacker.effects[PBEffects::ProtectRate]*40)
        end
        if score>=40
          score+=50 if attacker.turncount==0
          score+=30 if opponent.effects[PBEffects::TwoTurnAttack]!=0
        end
      when 0xAB
      when 0xAC
      when 0xAD
      when 0xAE
        score-=80 if attacker.effects[PBEffects::MirrorMove]<=0
      when 0xAF
      when 0xB0
      when 0xB1
      when 0xB2
      when 0xB3
      when 0xB4
        score-=140 if attacker.status!=PBStatuses::SLEEP
        score+=70 if attacker.status==PBStatuses::SLEEP
      when 0xB5
      when 0xB6
      when 0xB7
        score-=80 if opponent.effects[PBEffects::Torment]
      when 0xB8
        score-=80 if attacker.effects[PBEffects::Imprison]
      when 0xB9
        score-=80 if opponent.effects[PBEffects::Disable]>0 
      when 0xBA
        score-=80 if opponent.effects[PBEffects::Taunt]>0
      when 0xBB
      when 0xBC
        greaterSpeed=pbRoughStat(attacker,
           PBStats::SPEED)>pbRoughStat(opponent,PBStats::SPEED)
        if opponent.lastMoveUsed<=0 && greaterSpeed
          score-=70
        elsif opponent.effects[PBEffects::Encore]>0
          score-=80
        elsif opponent.lastMoveUsed>0 && greaterSpeed
          moveData=PBMoveData.new(opponent.lastMoveUsed)
          if moveData.basedamage==0 && (moveData.target==0x10 || moveData.target==0x20)
            score+=60
          elsif moveData.basedamage!=0 && moveData.target==0x00 &&
             pbTypeModifier(moveData.type,opponent,attacker)==0
            score+=60
          end
        end
      when 0xBD
      when 0xBE
        score-=10 if !opponent.pbCanPoison?(false)
      when 0xBF
      when 0xC0
      when 0xC1
        score-=70 if attacker.pbPartner.hp==0 && attacker.pbNonActivePokemonCount()==0
        if skill>=50 && opponent.level>=50
          # Damage too small to be useful
          score-=80
        end
      when 0xC2
      when 0xC3
      when 0xC4
        score-=30 if pbWeather==PBWeather::NEWMOON
        score+=30 if pbWeather==PBWeather::SUNNYDAY
        score-=30 if pbWeather==PBWeather::RAINDANCE
        score-=30 if pbWeather==PBWeather::SANDSTORM
        score-=30 if pbWeather==PBWeather::HAIL
       when 0x138
        score+=30 if pbWeather==PBWeather::NEWMOON
        score-=30 if pbWeather==PBWeather::SUNNYDAY
        score-=30 if pbWeather==PBWeather::RAINDANCE
        score-=30 if pbWeather==PBWeather::SANDSTORM
        score-=30 if pbWeather==PBWeather::HAIL

      when 0xC5
        score+=15 if pbRoughStat(attacker,
           PBStats::SPEED)<pbRoughStat(opponent,PBStats::SPEED)
        score-=10 if opponent.status==PBStatuses::PARALYSIS
      when 0xC6
        score-=10 if opponent.status==PBStatuses::BURN
        score-=40 if opponent.pbHasType?(:FIRE)
      when 0xC7
        score+=20 if attacker.effects[PBEffects::FocusEnergy]>0
      when 0xC8
        score+=10 if attacker.stages[PBStats::DEFENSE]<0
      when 0xC9
      when 0xCA
      when 0xCB
      when 0xCC
      when 0xCD
      when 0xCE
      when 0xCF
        score-=30 if opponent.effects[PBEffects::MultiTurn]>0
      when 0xD0
        score+=20 if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE)
      when 0xD1
      when 0xD2
        score-=20 if !opponent.pbCanConfuse?(false)
      when 0xD3
        score+=40 if attacker.effects[PBEffects::DefenseCurl]
      when 0xD4
      when 0xD5
        if attacker.hp==attacker.totalhp
          score-=80
        else
          score+=50
          score-=(attacker.hp*100/attacker.totalhp)
        end
      when 0xD6
        if attacker.hp==attacker.totalhp
          score-=80
        else
          score+=50
          score-=(attacker.hp*100/attacker.totalhp)
        end
      when 0xD7
        score-=80 if attacker.effects[PBEffects::Wish]>0
      when 0xD8
        if attacker.hp==attacker.totalhp
          score-=80
        else
          score+=30 if pbWeather==PBWeather::SUNNYDAY
          score-=30 if pbWeather==PBWeather::RAINDANCE
          score-=30 if pbWeather==PBWeather::SANDSTORM
          score-=30 if pbWeather==PBWeather::HAIL
          score-=50 if pbWeather==PBWeather::NEWMOON
          score+=70
          score-=(attacker.hp*140/attacker.totalhp)
        end
      when 0xD9
        if attacker.hp==attacker.totalhp || attacker.status==PBStatuses::SLEEP
          score-=80
        else
          score+=70
          score-=(attacker.hp*140/attacker.totalhp)
          score+=30 if attacker.status!=0
        end
      when 0xDA
      when 0xDB
        score-=80 if attacker.effects[PBEffects::Ingrain]
      when 0xDC
        score-=80 if opponent.effects[PBEffects::LeechSeed]>=0
        score-=80 if opponent.pbHasType?(:GRASS)
        if score>20
          score+=60 if attacker.turncount==0
        end
      when 0xDD
        score-=20 if isConst?(opponent.ability,PBAbilities,:LIQUIDOOZE)
        score+=20 if attacker.hp<=(attacker.totalhp/2)
      when 0xDE
        if opponent.status!=PBStatuses::SLEEP
          score-=200
          score-=50 if isConst?(opponent.ability,PBAbilities,:LIQUIDOOZE)
        else
          score-=50 if isConst?(opponent.ability,PBAbilities,:LIQUIDOOZE)
          score+=20 if attacker.hp<=(attacker.totalhp/2)
        end
      when 0xDF
        score-=80
      when 0xE0
        if isConst?(attacker.species,PBSpecies,:CLOYSTER) && (attacker.hp < 3)
            score+=1000
        end
        if pbCheckGlobalAbility(:DAMP)
          score-=100
        elsif skill>50 && attacker.pbNonActivePokemonCount()==0 &&
           attacker.pbOppositeOpposing.pbNonActivePokemonCount()>0
          score-=200
        elsif skill>80 && attacker.pbNonActivePokemonCount()==0 &&
           attacker.pbOppositeOpposing.pbNonActivePokemonCount()==0
          score-=200
        else
          score+=50
          score-=(attacker.hp*100/attacker.totalhp)
        end
      when 0xE1
        score-=200
      when 0xE2
        score-=80 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK) &&
                     !opponent.pbCanReduceStatStage?(PBStats::SPATK)
        score-=80 if attacker.pbNonActivePokemonCount()==0
        if score>20
          avg=(opponent.stages[PBStats::ATTACK]*10)
          avg+=(opponent.stages[PBStats::SPATK]*10)
          score+=avg
          score+=50
          score-=(attacker.hp*100/attacker.totalhp)
        end
      when 0xE3
      when 0xE4
      when 0xE5
        if attacker.pbNonActivePokemonCount()==0
          score-=100
        else
          score-=80 if opponent.effects[PBEffects::PerishSong]>0
        end
      when 0xE6
        score+=50
        score-=(attacker.hp*100/attacker.totalhp)
        score+=15 if attacker.hp<=(attacker.totalhp/10)
      when 0xE7
        score+=50
        score-=(attacker.hp*100/attacker.totalhp)
        score+=15 if attacker.hp<=(attacker.totalhp/10)
      when 0xE8
        score-=200
        score-=25 if attacker.hp>(attacker.totalhp/2)
        if skill>=50
          score-=90 if attacker.effects[PBEffects::ProtectRate]>1
          score-=90 if opponent.effects[PBEffects::HyperBeam]>0
        else
          score-=(attacker.effects[PBEffects::ProtectRate]*40)
        end
      when 0xE9
        score-=25
        score+=(opponent.hp*50/opponent.totalhp)
      when 0xEA
        score-=100 if @opponent
      when 0xEB
        party=pbParty(opponent.index)
        ch=0
        for i in 0...party.length
          ch+=1 if pbCanSwitchLax?(opponent.index,i,false)
        end
        score-=90 if ch==0
        score-=90 if opponent.effects[PBEffects::Ingrain]
        score-=90 if isConst?(opponent.ability,PBAbilities,:SUCTIONCUPS)
        if score>20
          score+=50 if opponent.pbOwnSide.effects[PBEffects::Spikes]>0
        end
      when 0xEC
      when 0xED
        score-=80 if !pbCanChooseNonActive?(attacker.index)
        score-=50 if attacker.effects[PBEffects::Confusion]>0
        total=0
        total+=(attacker.stages[PBStats::ATTACK]*10)
        total+=(attacker.stages[PBStats::DEFENSE]*10)
        total+=(attacker.stages[PBStats::SPEED]*10)
        total+=(attacker.stages[PBStats::SPATK]*10)
        total+=(attacker.stages[PBStats::SPDEF]*10)
        total+=(attacker.stages[PBStats::EVASION]*10)
        total+=(attacker.stages[PBStats::ACCURACY]*10)
        total+=10 if attacker.effects[PBEffects::Wish]>0
        if total==0 || attacker.turncount==0
          score-=60
        elsif score>20
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
      when 0xEE
      when 0xEF
        score-=80 if opponent.effects[PBEffects::MeanLook]>=0
      when 0xF0
        score-=20 if opponent.item==0
        score+=20 if opponent.item!=0
      when 0xF1
        score-=20 if attacker.item!=0
      when 0xF2
        if attacker.item==0 && opponent.item==0
          score-=80
        elsif isConst?(opponent.ability,PBAbilities,:STICKYHOLD)
          score-=80
        elsif isConst?(attacker.item,PBItems,:LAXINCENSE) ||
           isConst?(attacker.item,PBItems,:IRONBALL) ||
           isConst?(attacker.item,PBItems,:CHOICEBAND)
          score+=50
        elsif attacker.item==0 && opponent.item!=0
          score-=40
          score-=30 if isConst?(attacker.lastMoveUsed,PBMoves,:TRICK)
        end
      when 0xF3
      when 0xF4
      when 0xF5
      when 0xF6
        score-=80 if attacker.pokemon.itemRecycle==0 || attacker.item!=0
        score+=30 if attacker.pokemon.itemRecycle!=0
      when 0xF7
      when 0xF8
      when 0xF9
      when 0xFA
        score-=25
        score+=(attacker.hp*50/attacker.totalhp)
      when 0xFB
        score-=25
        score+=(attacker.hp*50/attacker.totalhp)
      when 0xFC
        score-=25
        score+=(attacker.hp*50/attacker.totalhp)
      when 0xFD
        score-=25
        score+=(attacker.hp*50/attacker.totalhp)
        score+=15 if pbRoughStat(attacker,
           PBStats::SPEED)<pbRoughStat(opponent,PBStats::SPEED)
        score-=10 if opponent.status==PBStatuses::PARALYSIS
      when 0xFE
        score-=25
        score+=(attacker.hp*50/attacker.totalhp)
        score-=10 if opponent.status==PBStatuses::BURN
        score-=40 if opponent.pbHasType?(:FIRE)
      when 0xFF
        score-=90 if pbCheckGlobalAbility(:AIRLOCK)
        score-=90 if pbCheckGlobalAbility(:CLOUDNINE)
        score-=80 if weather==PBWeather::SUNNYDAY
        if score>=50
          for move in attacker.moves
            if move.basedamage>0 && move.id!=0 && 
               isConst?(move.type,PBTypes,:FIRE)
              score+=20
            end
          end
        end
      when 0x100
        score-=90 if pbCheckGlobalAbility(:AIRLOCK)
        score-=90 if pbCheckGlobalAbility(:CLOUDNINE)
        score-=80 if weather==PBWeather::RAINDANCE
        if score>=50
          for move in attacker.moves
            if move.basedamage>0 && move.id!=0 && 
               isConst?(move.type,PBTypes,:WATER)
              score+=20
            end
          end
        end
        when 0x182
        score-=90 if pbCheckGlobalAbility(:AIRLOCK)
        score-=90 if pbCheckGlobalAbility(:CLOUDNINE)
        score-=80 if weather==PBWeather::NEWMOON
        if score>=50
          for move in attacker.moves
            if move.basedamage>0 && move.id!=0 && 
               isConst?(move.type,PBTypes,:DARK)
              score+=20
            end
          end
        end
      when 0x101
        score-=90 if pbCheckGlobalAbility(:AIRLOCK)
        score-=90 if pbCheckGlobalAbility(:CLOUDNINE)
        score-=80 if @weather==PBWeather::SANDSTORM
      when 0x102
        score-=90 if pbCheckGlobalAbility(:AIRLOCK)
        score-=90 if pbCheckGlobalAbility(:CLOUDNINE)
        score-=80 if @weather==PBWeather::HAIL
      when 0x103
        if attacker.pbOpposingSide.effects[PBEffects::Spikes]>=3
          score-=90
        elsif !pbCanChooseNonActive?(attacker.pbOpposing1.index) &&
             !pbCanChooseNonActive?(attacker.pbOpposing2.index)
          # No active Pokemon remains on opposing side
          score-=90
        elsif attacker.pbOpposingSide.effects[PBEffects::Spikes]>=0
          score+=[40,26,13][attacker.pbOpposingSide.effects[PBEffects::Spikes]]
          score-=5*attacker.pbOppositeOpposing.pbNonActivePokemonCount()
        end
      when 0x104
      when 0x105
      when 0x106
      when 0x107
      when 0x108
      when 0x109
      when 0x10A
        score+=30 if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
        score+=30 if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
      when 0x10B
        score+=10*(attacker.stages[PBStats::ACCURACY]-opponent.stages[PBStats::EVASION])
      when 0x10C
        score-=80 if attacker.effects[PBEffects::Substitute]>0 
        score-=90 if attacker.hp<=(attacker.totalhp/4)
        if score>20
          score+=60 if attacker.effects[PBEffects::Substitute]==0
        end
      when 0x10D
        if attacker.pbHasType?(:GHOST)
          if attacker.hp<=(attacker.totalhp/2)
            score-=40
            score-=40 if @shiftStyle
            score-=40 if attacker.pbNonActivePokemonCount()==0
          end
          score-=80 if opponent.effects[PBEffects::Curse]
        else
          avg=(attacker.stages[PBStats::SPEED]*10)
          avg-=(attacker.stages[PBStats::ATTACK]*10)
          avg-=(attacker.stages[PBStats::DEFENSE]*10)
          score+=avg/3
        end
      when 0x10E
      when 0x10F
        score-=80 if opponent.status!=PBStatuses::SLEEP
      when 0x110
        score+=30 if attacker.effects[PBEffects::MultiTurn]>0
        score+=30 if attacker.effects[PBEffects::LeechSeed]>=0
        score+=80 if attacker.pbOwnSide.effects[PBEffects::Spikes]>0
      when 0x111
        score-=110 if opponent.effects[PBEffects::FutureSight]>0
        # Future Sight tends to be wasteful if down to last Pokemon
        score-=70 if attacker.pbNonActivePokemonCount()==0
      when 0x112
        if attacker.effects[PBEffects::Stockpile]>=3
          score-=80
        end
        # More preferable if user also has Spit Up/Swallow
        foundmove=false
        for move in attacker.moves
          if move.function==0x113 || move.function==0x114 # Spit Up, Swallow
            foundmove=true
          end
        end
        if foundmove # Spit Up/Swallow found
          score+=20
        end
      when 0x113
        score-=110 if attacker.effects[PBEffects::Stockpile]==0
      when 0x114
        score-=90 if attacker.effects[PBEffects::Stockpile]==0 || attacker.hp==attacker.totalhp
      when 0x115
        score+=50 if opponent.effects[PBEffects::HyperBeam]>0
        score-=35 if opponent.hp<=(opponent.totalhp/2)
        score-=70 if opponent.hp<=(opponent.totalhp/4)
      when 0x116
      when 0x117
        score-=80 if attacker.pbPartner.hp==0
      when 0x118
      when 0x119
      when 0x11A
      when 0x11B
        score+=40 if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY)
        score+=40 if isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE)
      when 0x11C
      when 0x11D
      when 0x11E
      when 0x11F
      when 0x120
      when 0x121
      when 0x122
      when 0x123
      when 0x124
        score-=200
      when 0x125
        score-=200
      when 0x126
        score+=20 # Shadow moves are more preferable
      when 0x127
        score+=20 # Shadow moves are more preferable
        score+=15 if pbRoughStat(attacker,
           PBStats::SPEED)<pbRoughStat(opponent,PBStats::SPEED)
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
        if !opponent.pbCanConfuse?(false)
          score-=100
        elsif move.accuracy>=75
          score+=70 if attacker.turncount<3
          score+=40 if attacker.turncount>=3  
        end
      when 0x12B
        score+=20 # Shadow moves are more preferable
        score-=100 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE)
        if score>20
          score+=(opponent.stages[PBStats::DEFENSE]*20)
        end
      when 0x12C
        score+=20 # Shadow moves are more preferable
        score-=100 if !opponent.pbCanReduceStatStage?(PBStats::EVASION)
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
        score-=100 if @weather==PBWeather::SHADOWSKY
      when 0x132
        score+=20 # Shadow moves are more preferable
        score+=30 if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
        score+=30 if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
        score+=30 if attacker.pbOpposingSide.effects[PBEffects::Safeguard]>0
        score-=90 if attacker.pbOwnSide.effects[PBEffects::Reflect]>0
        score-=90 if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
        score-=90 if attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
    end
# Other score modifications.
    opponent=attacker.pbOppositeOpposing if !opponent
    opponent=opponent.pbPartner if opponent && opponent.hp==0
    if skill>=70
      # Endgame
      if attacker.pbNonActivePokemonCount()==0 &&
         opponent.pbNonActivePokemonCount()==0 &&
         pbParty(attacker.index).length>1 && pbParty(opponent.index).length>1
        if move.basedamage==0
	        score/=2 # Don't prefer nondamaging move
        elsif attacker.hp<=attacker.totalhp/2 && opponent.hp<=opponent.totalhp/2
	        PBDebug.log("[Preferring damaging move]") if $INTERNAL
	        score=score*3/2 # Prefer damaging move if game is close
        end
      end
      # Certain two-turn attacks
      if move.accuracy>0 && # checks accuracy
         (isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIVE) ||
         isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:BOUNCE) ||
         isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:FLY) ||
         isConst?(opponent.effects[PBEffects::TwoTurnAttack],PBMoves,:DIG)) &&
         pbRoughStat(attacker,PBStats::SPEED)>pbRoughStat(opponent,PBStats::SPEED)
        score-=80
      end
    end
    if skill>50
      if isConst?(attacker.item,PBItems,:CHOICEBAND) ||
         isConst?(attacker.item,PBItems,:CHOICESPECS) ||
         isConst?(attacker.item,PBItems,:CHOICESCARF)
        if move.basedamage>=60
          score+=70
        elsif move.basedamage>0
          score+=35
        elsif move.function==0xF2 # Trick
          score+=70
        else
          score-=60
        end
      end
      # Prefer a move usable while asleep if user is asleep.
      if attacker.status==PBStatuses::SLEEP &&
         move.function!=0x11 && move.function!=0xB4 # Snore or Sleep Talk
        hasSleepMove=false
        for m in attacker.moves
          if m.function==0x11 || m.function==0xB4 # Snore or Sleep Talk
            hasSleepMove=true; break
          end
        end
        score-=75 if hasSleepMove
      end
      # Prefer a self-thawing move if user is frozen.
      if attacker.status==PBStatuses::FROZEN &&
         (move.flags&0x40)==0 # flag g: Thaws user before moving
        hasFreezeMove=false
        for m in attacker.moves
          if (m.flags&0x40)!=0 # flag g: Thaws user before moving
            hasFreezeMove=true; break
          end
        end
        score-=75 if hasFreezeMove
      end
    end
    if move.basedamage>0
      typemod=pbTypeModifier(move.type,attacker,opponent)
      if typemod==0 || score<=0
        score=0
      elsif isConst?(move.type,PBTypes,:GROUND) && isConst?(opponent.ability,PBAbilities,:LEVITATE) && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      elsif isConst?(move.type,PBTypes,:FIRE) && isConst?(opponent.ability,PBAbilities,:FLASHFIRE) && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      elsif isConst?(move.type,PBTypes,:GRASS) && isConst?(opponent.ability,PBAbilities,:SAPSIPPER) && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      elsif isConst?(move.type,PBTypes,:ELECTRIC) && isConst?(opponent.ability,PBAbilities,:VOLTABSORB) && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      elsif isConst?(move.type,PBTypes,:ELECTRIC) && isConst?(opponent.ability,PBAbilities,:LIGHTNINGROD) && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)  && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      elsif isConst?(move.type,PBTypes,:ELECTRIC) && isConst?(opponent.ability,PBAbilities,:MOTORDRIVE)  && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      elsif isConst?(move.type,PBTypes,:WATER) && isConst?(opponent.ability,PBAbilities,:WATERABSORB)  && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      elsif isConst?(move.type,PBTypes,:WATER) && isConst?(opponent.ability,PBAbilities,:STORMDRAIN)  && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      elsif isConst?(move.type,PBTypes,:WATER) && isConst?(opponent.ability,PBAbilities,:DRYSKIN)  && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      elsif skill>50 && typemod<=4 && isConst?(opponent.ability,PBAbilities,:WONDERGUARD)  && !isConst?(attacker.ability,PBAbilities,:MOLDBREAKER)
        score=0
      else
        realBaseDamage=move.basedamage
        realBaseDamage=50 if move.basedamage==1
        basedamage=realBaseDamage
        attack=pbRoughStat(attacker,PBStats::ATTACK)
        spatk=pbRoughStat(attacker,PBStats::SPATK)
        defense=pbRoughStat(opponent,PBStats::DEFENSE)
        spdef=pbRoughStat(opponent,PBStats::SPDEF)
        isPhysical=move.pbIsPhysical?(move.type)
        if skill>=90
          if isPhysical
            basedamage=basedamage*attack/[defense,1].max
            basedamage=basedamage*3/2 if isConst?(attacker.item,PBItems,:CHOICEBAND)
            basedamage/=2 if opponent.pbOwnSide.effects[PBEffects::Reflect]>0
          else
            basedamage=basedamage*spatk/[spdef,1].max
            basedamage/=2 if opponent.pbOwnSide.effects[PBEffects::LightScreen]>0
          end
        end
        # STAB
        if skill>=50
          basedamage=basedamage*3/2 if attacker.pbHasType?(move.type)
        end
        # Type effectiveness
        basedamage=basedamage*typemod/4
        # Weather
        w=pbWeather()
        if w==PBWeather::SUNNYDAY
          basedamage=basedamage*3/2 if isConst?(move.type,PBTypes,:FIRE)
          basedamage/=2 if isConst?(move.type,PBTypes,:WATER)
        elsif w==PBWeather::RAINDANCE
          basedamage=basedamage*3/2 if isConst?(move.type,PBTypes,:WATER)
          basedamage/=2 if isConst?(move.type,PBTypes,:FIRE)
        end
        basedamage=basedamage*3/2 if attacker.effects[PBEffects::Charge]>0 &&
                                     isConst?(move.type,PBTypes,:ELECTRIC)
        # Two turn attacks
        if move.pbTwoTurnAttack(attacker)
          # Damage is effectively halved due to having to skip a turn
          basedamage/=2
          # Don't prefer if down to last Pokemon
          basedamage/=2 if attacker.pbNonActivePokemonCount()==0
        end
        # Don't prefer weak attacks
        basedamage/=2 if basedamage<40
        # Prefer damaging attack if level difference is significantly high
        basedamage=basedamage*7/5 if typemod>=4 && attacker.level-10>opponent.level
        # Low accuracy attack
        if move.accuracy<=70 && typemod>=4
          basedamage=basedamage*3/2 if opponent.effects[PBEffects::LockOn]>0 &&
                                       opponent.effects[PBEffects::LockOnPos]==attacker.index
        end
        if basedamage>realBaseDamage
	        basedamage=basedamage*5/6 # slightly weaken score increase
        end
        # Adjust score
        basedamage=600 if basedamage>600
        oldscore=score
        score+=basedamage/4
        score=score*basedamage/[realBaseDamage,1].max
        if $INTERNAL
	        PBDebug.log(sprintf("%s: %d=>%d",PBMoves.getName(move.id),realBaseDamage,basedamage))
          PBDebug.log(sprintf("   change: %d=>%d",oldscore,score))
        end
      end
    else
      score-=10
      score-=10 if score<=10 && skill>=70
    end
    score=0 if score<0
    return score
  end

################################################################################
# Get type effectiveness and approximate stats.
################################################################################
  def pbTypeModifier(type,attacker,opponent)
    return 4 if type<0
    return 4 if isConst?(type,PBTypes,:GROUND) && opponent.pbHasType?(:FLYING) &&
                isConst?(opponent.item,PBItems,:IRONBALL)
    atype=type
    otype1=opponent.type1
    otype2=opponent.type2
    mod1=PBTypes.getEffectiveness(atype,otype1)
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    if isConst?(attacker.ability,PBAbilities,:SCRAPPY) || opponent.effects[PBEffects::Foresight]
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) &&
         (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) &&
         (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
    end
    if opponent.effects[PBEffects::MiracleEye]
      mod1=2 if isConst?(otype1,PBTypes,:DARK) && isConst?(atype,PBTypes,:PSYCHIC)
      mod2=2 if isConst?(otype2,PBTypes,:DARK) && isConst?(atype,PBTypes,:PSYCHIC)
    end
    retvar = mod1*mod2
    retvar = 8 - retvar if $game_switches[302]
    return retvar
  end

  def pbTypeModifier2(battlerThis,battlerOther)
    if battlerThis.type1==battlerThis.type2
      return 4*pbTypeModifier(battlerThis.type1,battlerThis,battlerOther)
    else
      ret=pbTypeModifier(battlerThis.type1,battlerThis,battlerOther)
      ret*=pbTypeModifier(battlerThis.type2,battlerThis,battlerOther)
      return ret # 0,1,2,4,8,_16_,32,64,128,256
    end
  end

  def pbRoughStat(battler,stat)
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    stage=battler.stages[stat]
    value=0
    value=battler.attack if stat==PBStats::ATTACK
    value=battler.defense if stat==PBStats::DEFENSE
    value=battler.speed if stat==PBStats::SPEED
    value=battler.spatk if stat==PBStats::SPATK
    value=battler.spdef if stat==PBStats::SPDEF
    return (value*stagemul[stage]/stagediv[stage]).floor
  end

################################################################################
# Choose a move to use.
################################################################################
  def pbChooseMoves(index)
    if $INTERNAL && !pbIsOpposing?(index)
      pbChooseMovesOld(index)
      return
    end
    attacker=@battlers[index]
    scores=[0,0,0,0]
    targets=nil
    myChoices=[]
    totalscore=0
    target=-1
    wildbattle=!@opponent && pbIsOpposing?(index)
    if wildbattle # If wild battle
      for i in 0...4
        if pbCanChooseMove?(index,i,false)
          scores[i]=100
          myChoices.push(i)
          totalscore+=100
        end
      end
    elsif !$game_switches[321] &&
      pbGetOwner(attacker.index).trainertype==PBTrainers::QMARKS ||
      (pbGetOwner(attacker.index).trainertype==PBTrainers::ELITEFOUR_BatonPass && attacker.pokemon.species!=PBSpecies::SLOWBRO) #||
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
      elsif pbGetOwner(attacker.index).trainertype==PBTrainers::ELITEFOUR_BatonPass && attacker.pokemon.species!=PBSpecies::SLOWBRO
          #Baton Pass, Kayla
          if attacker.pokemon.species==PBSpecies::SMEARGLE
                if ![PBAbilities::OVERCOAT,PBAbilities::VITALSPIRIT,
                  PBAbilities::INSOMNIA,PBAbilities::MAGICBOUNCE].include?(opponent.pokemon.ability) &&
                  ![PBItems::LUMBERRY,PBItems::CHESTOBERRY].include?(opponent.pokemon.item) &&
                  !opponent.pbHasType?(:GRASS) &&
                  opponent.status==0 &&
                  $justUsedStatusCure==nil
                 o=2
                 
                else
                  if attacker.stages[PBStats::SPEED]>=3 && attacker.stages[PBStats::SPATK]>=3 && attacker.stages[PBStats::SPDEF]>=3
                      hasRrWw=false
                      for pokemon in $Trainer.party 
                        hasRrWw = pbHasMove?(pokemon,PBMoves::WHIRLWIND) || pbHasMove?(pokemon,PBMoves::ROAR)
                        break if hasRrWw
                      end
                      if hasRrWw || (opponent.status==PBStatuses::SLEEP && opponent.statusCount>1)
                        o=0
                      else
                        o=3  
                      end
                      
                    else
                      if (attacker.item != PBItems::FOCUSSASH || attacker.hp/attacker.totalhp < 0.4)# &&
                      #  (opponent.status==0 || opponent.statusCount<=2)
                          o=3
                      else
                          o=1
                      end
                    end
                  end
                end

          if attacker.pokemon.species==PBSpecies::BLAZIKEN 
            if (attacker.hp/attacker.totalhp <= 0.25 || 
               (attacker.stages[PBStats::ATTACK]>3 && attacker.stages[PBStats::DEFENSE]>3))
               o=3
             else
                statcount=0
                for i in [PBStats::ATTACK,PBStats::DEFENSE,
                          PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                          PBStats::EVASION,PBStats::ACCURACY]

                   if opponent.stages[i]>0
                     statcount += 1
                   end
                 end
                if attacker.item != PBItems::FOCUSSASH && (attacker.stages[PBStats::ATTACK]>3 || PBTypes.getEffectiveness(PBTypes::FIRE,opponent.pokemon.type1)*PBTypes.getEffectiveness(PBTypes::FIRE,opponent.pokemon.type2) > 4) && attacker.hp/attacker.totalhp > 0.4
                  o=2
                elsif attacker.item != PBItems::FOCUSSASH
                  o=3
                elsif attacker.effects[PBEffects::Substitute]==0 && attacker.hp/attacker.totalhp > 0.25
                  o=1
                else
                  o=0
                end
             end
              
          end

          if attacker.pokemon.species==PBSpecies::SCIZOR
            hasFire=false
            for moves in opponent.pokemon.moves
              if moves.type==PBTypes::FIRE && moves.basedamage > 0
                hasFire=true
                break
              end
            end
              if hasFire || attacker.hp/attacker.totalhp < 0.3 && opponent.hp/opponent.totalhp > 0.3
                o=3
              elsif attacker.stages[PBStats::ATTACK]>=4 || 
                (attacker.stages[PBStats::ATTACK]>1 && PBTypes.getEffectiveness(PBTypes::STEEL,opponent.pokemon.type1) * PBTypes.getEffectiveness(PBTypes::STEEL,opponent.pokemon.type2) > 4)
                o=1
              elsif attacker.stages[PBStats::ATTACK]>=4 && attacker.stages[PBStats::DEFENSE]>=5
                o=3
              elsif attacker.effects[PBEffects::Substitute]>0
                o=1
              else
                if attacker.stages[PBStats::ATTACK]>=4
                      o=0
                else
                    o=2
                end
              end
               
            end

          if attacker.pokemon.species==PBSpecies::SYLVEON

            hasWeak=false
            for moves in opponent.pokemon.moves
              if (moves.type==PBTypes::STEEL || moves.type==PBTypes::POISON) && moves.basedamage > 0
                hasWeak=true
                break
              end
            end
                  if hasWeak && (attacker.stages[PBStats::SPATK]<1 || attacker.stages[PBStats::SPDEF]<1)
                    o=3
      
                  else  
                              if ((attacker.stages[PBStats::DEFENSE]>2 && attacker.stages[PBStats::SPDEF]>2) ||
                                (attacker.stages[PBStats::SPEED]>opponent.stages[PBStats::SPEED]) ||
                                attacker.effects[PBEffects::Substitute]>0) &&
                                attacker.stages[PBStats::SPATK]>4 ||
                                (attacker.stages[PBStats::SPATK]>2 && ((PBTypes.getEffectiveness(PBTypes::PSYCHIC,opponent.pokemon.type1) * PBTypes.getEffectiveness(PBTypes::PSYCHIC,opponent.pokemon.type2) > 4) ||
                                (PBTypes.getEffectiveness(PBTypes::FAIRY,opponent.pokemon.type1) * PBTypes.getEffectiveness(PBTypes::FAIRY,opponent.pokemon.type2) > 4)))
                                 
                                                        if opponent.pbHasType?(PBTypes::DARK) || (PBTypes.getEffectiveness(PBTypes::FAIRY,opponent.pokemon.type1) * PBTypes.getEffectiveness(PBTypes::FAIRY,opponent.pokemon.type2) > PBTypes.getEffectiveness(PBTypes::PSYCHIC,opponent.pokemon.type1) * PBTypes.getEffectiveness(PBTypes::PSYCHIC,opponent.pokemon.type2))
                                                          o=2
                                                        else
                                                          o=1
                                                        end
                              else
                                                  if (attacker.stages[PBStats::SPATK]<4 || attacker.stages[PBStats::SPDEF]<4)
                                                    o=0
                                                  else
                                                    o=3
                                                  end
                              end
                  end
            end
            
       #   begin

          if attacker.pokemon.species==PBSpecies::ESPEON
            hasWeak=false
            for moves in opponent.pokemon.moves
              if (moves.type==PBTypes::BUG || moves.type==PBTypes::DARK || moves.type==PBTypes::GHOST) && moves.basedamage > 0
                hasWeak=true
                break
              end
            end
            if hasWeak && (attacker.stages[PBStats::SPATK]<1 || attacker.stages[PBStats::SPDEF]<1)
              o=3
            elsif attacker.hp/attacker.totalhp > 0.25 &&
              attacker.effects[PBEffects::Substitute]<1
              o=2
            else
              if  !opponent.pbHasType?(PBTypes::DARK) &&
                ((attacker.stages[PBStats::DEFENSE]>2 && attacker.stages[PBStats::SPDEF]>2) ||
                (attacker.stages[PBStats::DEFENSE]>opponent.stages[PBStats::DEFENSE]) ||
                attacker.effects[PBEffects::Substitute]>0) &&
                attacker.stages[PBStats::SPATK]>4 ||
                (attacker.stages[PBStats::SPATK]>2 && (PBTypes.getEffectiveness(PBTypes::PSYCHIC,opponent.pokemon.type1) * PBTypes.getEffectiveness(PBTypes::PSYCHIC,opponent.pokemon.type2) > 4))
                
                o=1
              else
                if (attacker.stages[PBStats::SPATK]<4 || attacker.stages[PBStats::SPDEF]<4)
                  o=0
                else
                  o=3
                end
              end
          end
        end
        
        
  #    rescue
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
      
      
        skill=pbGetOwner(attacker.index).moneyEarned || 0
      opponent=attacker.pbOppositeOpposing
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
          if pbCanChooseMove?(index,i,false)
            
                        score1=pbGetMoveScore(attacker.moves[i],attacker,opponent,skill)
            score2=pbGetMoveScore(attacker.moves[i],attacker,otheropp,skill)

         #   if pbGetOwner(attacker.index)==PBTrainers::CHAMPION_Reukra
         ##     if attacker.species==PBSpecies::ARON
          #        if attacker.moves[i].id==PBMoves::ENDEAVOR
          #            if !opponent.hasType?(:GHOST) && opponent.hp != 1
           #             score1=500000000000
            #            score2=500000000000
             #         end
              #        
               #   end
                  
              #end
              
            #end
            if (attacker.moves[i].target&0x20)!=0 
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
                elsif s<=10 # Hardly effective
                  score1=score1*5/3
                  score2=score2*5/3
                end
              end
            end
            myChoices.push(i)
            scoresAndTargets.push([i*2,i,score1,opponent.index])
            scoresAndTargets.push([i*2+1,i,score2,otheropp.index])
          end
        end
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
        for i in 0...4
          scores[i]=0 if scores[i]<0
          totalscore+=scores[i]
        end
      else
        # Choose a move.
        if @doublebattle && opponent.hp<=0
          opponent=opponent.pbPartner
        end
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
    maxscore=scores[0]
    maxscore=scores[1] if maxscore<scores[1]
    maxscore=scores[2] if maxscore<scores[2]
    maxscore=scores[3] if maxscore<scores[3]
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
    if !wildbattle && maxscore>100
      stdev=pbStdDev(scores)
      if stdev>=100 && pbAIRandom(10)!=0
        # If standard deviation is 100 or more
        # there is a highly preferred move. Choose it.
        preferredMoves=[]
        for i in 0...4
          if attacker.moves[i].id!=0 && (scores[i]==maxscore || scores[i]>=350)
            preferredMoves.push(i)
            if scores[i]==maxscore
              preferredMoves.push(i)
            end
          end
        end
        if preferredMoves.length>0
          i=preferredMoves[pbAIRandom(preferredMoves.length)]
          if $INTERNAL
            PBDebug.log("[Prefer "+PBMoves.getName(attacker.moves[i].id)+"]")
          end
          pbRegisterMove(index,i,false)
          target=targets[i] if targets
          if @doublebattle && target>=0
            pbRegisterTarget(index,target)
          end
          return
        end
      end
    end
    if !wildbattle && attacker.turncount
      badmoves=false
      if ((maxscore<=10 && attacker.turncount>5) ||
         (maxscore<=0 && attacker.turncount>2)) && pbAIRandom(10)<8
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
    if maxscore<=0
      # If all scores are 0 or less choose a move at random
      if myChoices.length>0
        pbRegisterMove(index,myChoices[pbAIRandom(myChoices.length)],false)
      else
        pbAutoChooseMove(index)
      end
    else
      randnum=pbAIRandom(totalscore)
      cumtotal=0
      for i in 0...4
        if scores[i]>0
          cumtotal+=scores[i]
          if randnum<cumtotal
            pbRegisterMove(index,i,false)
            target=targets[i] if targets
            break
          end
        end
      end
    end
    if @doublebattle && target>=0
      pbRegisterTarget(index,target)
    end
  end

################################################################################
# Decide whether the opponent should switch Pokémon.
################################################################################
  def pbEnemyShouldWithdrawEx?(index,alwaysSwitch)
    return false if !@opponent
    shouldswitch=alwaysSwitch
    typecheck=false
    batonpass=-1
    movetype=-1
    skill=pbGetOwner(index).moneyEarned || 0
    if @opponent && !shouldswitch && @battlers[index].turncount>0
      if skill>=70 # Experienced trainers only
        opponent=@battlers[index].pbOppositeOpposing
        if opponent.hp==0
          opponent=opponent.pbPartner
        end
        if opponent.hp>0 && opponent.lastMoveUsed>0 && 
           (opponent.level-@battlers[index].level).abs<=6
          move=PBMoveData.new(opponent.lastMoveUsed)
          typemod=pbTypeModifier(move.type,@battlers[index],@battlers[index])
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
    if !pbCanChooseMove?(index,0,false) &&
       !pbCanChooseMove?(index,1,false) &&
       !pbCanChooseMove?(index,2,false) &&
       !pbCanChooseMove?(index,3,false) &&
       @battlers[index].turncount &&
       @battlers[index].turncount>5
      shouldswitch=true
    end
    if skill>=70 && @battlers[index].effects[PBEffects::PerishSong]!=1
      for i in 0...4
        move=@battlers[index].moves[i]
        if move.id!=0 && pbCanChooseMove?(index,i,false) &&
          move.function==0xED # Baton Pass
          batonpass=i
          break
        end
      end
    end
    if skill>=80
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
    if skill>=60
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
    if skill>=70
      if !@doublebattle && @battlers[index].pbOppositeOpposing.hp>0 
        opp=@battlers[index].pbOppositeOpposing
        if (opp.effects[PBEffects::HyperBeam]>0 ||
           (isConst?(opp.ability,PBAbilities,:TRUANT) &&
           opp.effects[PBEffects::Truant])) && pbAIRandom(100)<80
          shouldswitch=false
        end
      end
    end
    if @rules["suddendeath"]
      if @battlers[index].hp<=(@battlers[index].totalhp/4) && pbAIRandom(10)<3 && 
         @battlers[index].turncount>0
        shouldswitch=true
      elsif @battlers[index].hp<=(@battlers[index].totalhp/2) && pbAIRandom(10)<8 && 
         @battlers[index].turncount>0
        shouldswitch=true
      end
    end
    if @battlers[index].effects[PBEffects::PerishSong]==1
      shouldswitch=true
    end
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
                 !isConst?(party[i].ability,PBAbilities,:LEVITATE)
                # Don't switch to this if too little HP
                next
              end
            end
          end
          if movetype>=0 && pbTypeModifier(movetype,@battlers[index],@battlers[index])==0
            weight=65
            if pbTypeModifier2(party[i],@battlers[index].pbOppositeOpposing)<16
              # Greater weight if new Pokemon's type is effective against opponent
              weight=85
            end
            if pbAIRandom(100)<weight
              list.unshift(i) # put this Pokemon first
            end
          elsif movetype>=0 && pbTypeModifier(movetype,@battlers[index],@battlers[index])<4
            weight=40
            if pbTypeModifier2(party[i],@battlers[index].pbOppositeOpposing)<16
              # Greater weight if new Pokemon's type is effective against opponent
              weight=60
            end
            if pbAIRandom(100)<weight
              list.unshift(i) # put this Pokemon first
            end
          else
            list.push(i) # put this Pokemon last
          end
        end
      end
      if list.length>0
        if batonpass!=-1
          if !pbRegisterMove(index,batonpass,false)
            if pbRandom(4)==0
                return pbRegisterSwitch(index,list[0])
              else
                return false
            end
          end
          return true
        else
         # if pbRandom(4)==0
          return pbRegisterSwitch(index,list[0])
        end
      end
    end
    return false
  end

  def pbEnemyShouldWithdraw?(index)
    if $INTERNAL && !pbIsOpposing?(index)
      return pbEnemyShouldWithdrawOld?(index)
    end
    return pbEnemyShouldWithdrawEx?(index,false)
  end

  def pbChooseBestNewEnemy(index,party,enemies) #hahah
    return -1 if !enemies || enemies.length==0
    $PokemonTemp=PokemonTemp.new if !$PokemonTemp

    o1=@battlers[index].pbOpposing1
    o2=@battlers[index].pbOpposing2
    o1=nil if o1 && o1.hp<=0

    o2=nil if o2 && o2.hp<=0
    best=-1
    bestSum=0
    attacker=@battlers[index]
      #Kernel.pbMessage("-1")

    if pbGetOwner(index).trainertype==PBTrainers::ELITEFOUR_BatonPass && !$game_switches[321]#&& attacker.pokemon.species!=PBSpecies::SLOWBRO
      blazikenAlive=-1
      smeargleAlive=-1
      scizorAlive=-1
      espeonAlive=-1
      slowbroAlive=-1
      sylveonAlive=-1
      chosenValue=0
      
          asFire=false
            for moves in o1.pokemon.moves
              if moves.type==PBTypes::FIRE && moves.basedamage > 0
                hasFire=true
                break
              end
            end

            #Kernel.pbMessage("0")

      for i in 0..party.length-1
        #kmn=party[e]
        pkmn=party[i]
        blazikenAlive = i if pkmn.species==PBSpecies::BLAZIKEN && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        smeargleAlive = i if pkmn.species==PBSpecies::SMEARGLE && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        scizorAlive = i if pkmn.species==PBSpecies::SCIZOR && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        espeonAlive = i if pkmn.species==PBSpecies::ESPEON && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        slowbroAlive = i if pkmn.species==PBSpecies::SLOWBRO && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
        sylveonAlive = i if pkmn.species==PBSpecies::SYLVEON && pkmn.hp>0 && attacker.pokemon.species!=pkmn.species
      end
      #Kernel.pbMessage("1")
      if attacker.stages[PBStats::SPEED]<2
          if blazikenAlive>=0 && ((party[blazikenAlive].item==PBItems::FOCUSSASH && party[blazikenAlive].hp/party[blazikenAlive].totalhp == 1) || attacker.effects[PBEffects::Substitute]>0)
             return blazikenAlive 
          end
        end
      if attacker.stages[PBStats::ATTACK]<4 || attacker.stages[PBStats::DEFENSE]<4
        if scizorAlive>=0 && !hasFire
          return scizorAlive
        elsif blazikenAlive>=0 && (party[blazikenAlive].item==PBItems::FOCUSSASH || attacker.effects[PBEffects::Substitute]>0)
        return blazikenAlive
      end
        
      end
        
      if attacker.stages[PBStats::SPATK]<4 || attacker.stages[PBStats::SPDEF]<4
        if sylveonAlive>=0 && o1.pbHasType?(PBTypes::DARK)
          return sylveonAlive
        end
        if espeonAlive>=0 && o1.pbHasType?(PBTypes::STEEL) && o1.pbHasType?(PBTypes::POISON) && !o1.pbHasType?(PBTypes::DARK)
          return espeonAlive
        end
        if espeonAlive>=0 && party[espeonAlive].hp/party[espeonAlive].totalhp > 0.25 && attacker.effects[PBEffects::Substitute]<1
          return espeonAlive
        end
        if sylveonAlive>=0
          return sylveonAlive
        end
        if espeonAlive>=0
          return espeonAlive
        end
      end

      if slowbroAlive>=0
        return slowbroAlive
      end


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
end

=end