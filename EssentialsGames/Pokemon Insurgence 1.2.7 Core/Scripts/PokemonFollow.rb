#==============================================================================
# ¡Ü Credits to Help - 14 for both the scripts and Sprites
# ¡Ü Edited by Zingzags 
# -Fixed bugs
# -Clean ups
# -Fixed Surf Bug (After Surf is done)
# -Fixed def talk_to_pokemon while in surf
# -Fixed Surf Check
# -Fixed Type Check
# -Added Door Support
# -Fixed Hp Bug
# -Added Pokemon Center Support
# -Animation problems
# -Fixed Walk_time_variable problem
# -Added random item loot
# -Added egg check
#==============================================================================
# Zingzags comments
#==============================================================================
# I know its not perfect, and it can be shortened, for example addind an array 
# for the random items.
#==============================================================================

#==============================================================================
#   ¡Ü Control the following Pokemon
#==============================================================================

def FollowingMoveRoute(commands,waitComplete=false)
  return if $Trainer.party[0].hp<=0 || $Trainer.party[0].egg?
  $PokemonTemp.dependentEvents.SetMoveRoute(commands,waitComplete)
end
  
def pbPokeStep
  for event in $game_map.events.values
    if event.name=="Poke"              
      pbMoveRoute(event,[PBMoveRoute::StepAnimeOn])
    end
  end
end

#==============================================================================
#   ¡Ü Pokemon Following Character v3 By Help-14
#==============================================================================

class DependentEvents
#==============================================================================
# Raises The Current Pokemon's Happiness levels +1 per each time the 
# Walk_time_Variable reachs 5000 then resets to 0
# ItemWalk, is when the variable reaches a certain amount, that you are able to talk to your pokemon to recieve an item
#==============================================================================
  def add_following_time
    if $game_switches[2]==true && $Trainer.party.length>=1
      $game_variables[Walking_Time_Variable]+=1 if $game_variables[Current_Following_Variable]!=$Trainer.party.length
      if $game_variables[Walking_Time_Variable]==5000
        $Trainer.party[0].happiness+=1
        $game_variables[Walking_Time_Variable]=0
      if $game_variables[91]=3
      else
        $game_variables[ItemWalk]+=1
      end
      end
    end
  end
  #----------------------------------------------------------------------------
  # -  refresh_sprite
  # -  Change sprite without animation
  #----------------------------------------------------------------------------
  
  def refresh_sprite(animation=true)
    if $game_switches[51]
      remove_sprite
      return
    end
    if $Trainer && $Trainer.party.is_a?(Array) && $Trainer.party.length!=$game_variables[Current_Following_Variable]
      if $Trainer.party[0].isShiny?
        shiny=true
      else
        shiny=false
      end
      if $Trainer.party[0].hp>0 && !$Trainer.party[0].egg?
        change_sprite($Trainer.party[0].species, $Trainer.party[0].form, shiny, false, $Trainer.party[0].gender==1)
        $PokemonTemp.dependentEvents.update_stepping
      elsif $Trainer.party[0].hp<=0 || $Trainer.party[0].egg?
        remove_sprite
      end
    end
  end
  #----------------------------------------------------------------------------
  # - change_sprite(id, shiny, animation)
  # - Example, to change sprite to shiny lugia with animation:
  #     change_sprite(249, true, true)
  # - If just change sprite:
  #     change_sprite(249)
  #----------------------------------------------------------------------------
  def change_sprite(id, form=0, shiny=nil, animation=nil, female = false)
    #  Kernel.pbMessage("ah") if female
    events=$PokemonGlobal.dependentEvents
    formcheck = form
    form = form.to_s
    if $PokemonGlobal.surfing || $PokemonGlobal.diving || $PokemonGlobal.bicycle
      for i in 0...events.length
        if events[i][6]!=sprintf("000") || @realEvents[i].character_name!=sprintf("000")
          #if $scene.spriteset
          #  $scene.spriteset.addUserAnimation(Animation_Come_In,@realEvents[i].x,@realEvents[i].y)
          #end
          events[i][6]=sprintf("000")
          @realEvents[i].character_name=sprintf("000")
        end
      end
    else
    for i in 0...events.length
      if events[i] && events[i][8]=="Dependent"
        #if shiny==true
        #events[i][6]=sprintf("%03dfs",id)
        #if female && FileTest.image_exist?("Graphics/Characters/"+events[i][6])# && [727,728,729].include?(id)
        #events[i][6]=sprintf("%03dfs",id)
        #  @realEvents[i].character_name=events[i][6]
        #elsif formcheck==0
        #  events[i][6]=sprintf("%03ds",id) 
        #  @realEvents[i].character_name=sprintf("%03ds",id) 
        #else
        #  events[i][6]=sprintf("%03ds_"+form,id) 
        #  @realEvents[i].character_name=sprintf("%03ds_"+form,id)
        #end
        #   if FileTest.image_exist?("Graphics/Characters/"+events[i][6])
        #if female && [727,728,729].include?(id)
        #  events[i][6]=sprintf("%03df",id)
        #elsif formcheck==0
        #  @realEvents[i].character_name=sprintf("%03ds",id) 
        #else
        #  @realEvents[i].character_name=sprintf("%03ds_"+form,id)
        #end
        #  else
        #     if formcheck==0
        #     @realEvents[i].character_name=sprintf("%03d",id)
        ##     else
        #     @realEvents[i].character_name=sprintf("%03d_"+form,id)
        #     end
        # end
        #else
        append="%03d"
        #events[i][6]=sprintf("%03df",id)
        #events[i][6]=sprintf(append+"f",id)
        if female && FileTest.image_exist?("Graphics/Characters/"+sprintf(append+"f",id))#&& [727,728,729].include?(id)
          #events[i][6]=sprintf("%03df",id)
          append+="f"
          #@realEvents[i].character_name=events[i][6]
          #elsif formcheck==0
        end
        if shiny
          append+="s"
        end
        if formcheck!=0
          #events[i][6]=sprintf("%03d",id)
          #@realEvents[i].character_name=events[i][6]
          #else
          # Kernel.pbMessage("_"+form)
          append+=("_"+form)
          #events[i][6]=sprintf("%03d_"+form,id)
          #@realEvents[i].character_name=events[i][6]
        end
        #end
        events[i][6]=sprintf(append,id)
        @realEvents[i].character_name=events[i][6]
        #if animation==true
        #  $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
        #end
        $game_variables[Walking_Time_Variable]=0
      end
    end
  end
  
  end
  def getMew
    return @realEvents[0]
  end
  
  #===============================================================================
  # * update_stepping
  # * Adds step animation for followers
  #===============================================================================
  
  def update_stepping
    FollowingMoveRoute([PBMoveRoute::StepAnimeOn])
  end
 
  def stop_stepping
    FollowingMoveRoute([PBMoveRoute::StepAnimeOff])
  end
  
  #----------------------------------------------------------------------------
  # - remove_sprite(animation)
  # - Example, to remove sprite with animation:
  #     remove_sprite(true)
  # - If just remove sprite:
  #     remove_sprite
  #----------------------------------------------------------------------------
  
  def remove_sprite(animation=nil)
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]=="Dependent"
          events[i][6]=sprintf("nil")
          #Kernel.pbGetDependency("Dependent").character_name=sprintf("nil")
          @realEvents[i].character_name=sprintf("nil")
         if animation==true
          $scene.spriteset.addUserAnimation(Animation_Come_In,@realEvents[i].x,@realEvents[i].y) if $Trainer && $Trainer.party[0] && $Trainer.party[0].hp > 0
          pbWait(10)
          end
        $game_variables[Current_Following_Variable]=$Trainer.party[0]
        $game_variables[Walking_Time_Variable]=0
      end
    end
  end

  #----------------------------------------------------------------------------
  # - check_surf(animation)
  # - If current Pokemon is a water Pokemon, it is still following.
  # - If current Pokemon is not a water Pokemon, remove sprite.
  # - Require Water_Pokemon_Can_Surf = true to enable
  #----------------------------------------------------------------------------
  def check_surf(animation=nil)
    events=$PokemonGlobal.dependentEvents
    #Kernel.pbMessage("1")
    for i in 0...events.length
      #Kernel.pbMessage(_INTL("{1}",events[i].to_s))
      if events[i] && events[i][8]=="Dependent"
        events[i][6]=sprintf("nil")
        @realEvents[i].character_name=sprintf("nil")
      else
        if $Trainer.party[0].hp>0 && !$Trainer.party[0].egg?
          if $Trainer.party[0].hasType?(:WATER)
            remove_sprite
          else
            remove_sprite
            pbWait(20)
          end
        elsif $Trainer.party[0].hp<=0 
        end
      end
    end
  end  
  
  #----------------------------------------------------------------------------
  # -  talk_to_pokemon
  # -  It will run when you talk to Pokemon following
  #----------------------------------------------------------------------------

  def talk_to_pokemon
    return if !$scene
    return if !$scene.spriteset
    return if $scene == nil
    return if $scene.spriteset ==nil
    return if $game_system.hm7
    return if $PokemonGlobal.surfing || $PokemonGlobal.diving
    #    if !$game_switches[241]
    #     return 
    #    end
    $game_switches[262]=true
    e=$Trainer.party[0]
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]=="Dependent"
        pos_x=@realEvents[i].x
        pos_y=@realEvents[i].y
      end
    end
    if e==0
    else
      if e.hp>0 && !$Trainer.party[0].egg?
        if $PokemonGlobal.surfing==true || $PokemonGlobal.diving==true || $PokemonGlobal.bicycle==true
        else
          if e!=6
            pbPlayCry(e.species)
            random1=rand(15)
            if $game_variables[ItemWalk]==5 
              items=[:POTION,:SUPERPOTION,:FULLRESTORE,:REVIVE,:PPUP,
                   :PPMAX,:RARECANDY,:REPEL,:MAXREPEL,:ESCAPEROPE,
                   :HONEY,:TINYMUSHROOM,:PEARL,:NUGGET,:GREATBALL,
                   :ULTRABALL,:THUNDERSTONE,:MOONSTONE,:SUNSTONE,:DUSKSTONE,
                   :REDAPRICORN,:BLUAPRICORN,:YLWAPRICORN,:GRNAPRICORN,:PNKAPRICORN,
                   :BLKAPRICORN,:WHTAPRICORN
                  ]
              random2=0
              loop do
                random2=rand(items.length)
                break if hasConst?(PBItems,items[random2])
              end
              Kernel.pbMessage(_INTL("{1} seems to be holding something, it looks like {1} wants to give it to me.",e.name))
              Kernel.pbPokemonFound(getConst(PBItems,items[random2]))
              $game_variables[ItemWalk]=0
            end
            if isConst?(e.species,PBSpecies,:MEW) && $game_switches[42]
              ary1=["Talk","Transform"]
              v0 = Kernel.pbMessage("Choose an interaction.",ary1)
              if v0==0
                facePlayer(Kernel.pbGetDependency("Dependent"))
                if random1==0
                  #    $scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} loves this tune so much that {1} is singing it.",e.name)) 
                elsif random1==1
                  #    $scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} is pumped up and raring to go!",e.name)) 
                elsif random1==2
                  #    $scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} is practicing its {2} move for the next battle!",e.name,PBMoves.getName(e.moves[0].id))) 
                elsif random1==3
                  #    $scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} is chilling out, maxing, relaxing all cool.",e.name)) 
                elsif random1==4
                  #    $scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} is anxious to see what {2} will do next.",e.name, $Trainer.name)) 
                elsif random1==5
                  #    $scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} seems to be trying to tell {2} something with their eyes.",e.name, $Trainer.name)) 
                elsif e.happiness>0 && e.happiness<=50
                  #    $scene.spriteset.addUserAnimation(Emo_Hate, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} hates to travel with {2}.",e.name,$Trainer.name))
                elsif e.status==PBStatuses::POISON && e.hp>0 && !e.egg?
                  #    $scene.spriteset.addUserAnimation(Emo_Poison, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} is badly poisoned, {1} needs help quick.",e.name))
                elsif e.happiness>50 && e.happiness<=100
                  #    $scene.spriteset.addUserAnimation(Emo_Normal, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} is still undecided for whether traveling with {2} is a good thing or not.",e.name,$Trainer.name))
                elsif e.happiness>100 && e.happiness<150
                  #   $scene.spriteset.addUserAnimation(Emo_Happy, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} is happy traveling with {2}.",e.name,$Trainer.name))
                elsif e.happiness>=150 && e.happiness<200
                  #  $scene.spriteset.addUserAnimation(Emo_love, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} loves traveling with {2}.",e.name,$Trainer.name))
                elsif e.happiness>=200
                  $scene.spriteset.addUserAnimation(Emo_love, pos_x, pos_y-2)
                  Kernel.pbMessage(_INTL("{1} loves nothing more than being with {2}.",e.name,$Trainer.name))
                end
              elsif v0==1
                ary=[]
                ary.push("Darkrai Cultist") if $game_variables[42][1] == true
                ary.push("Seed Flare") if $game_variables[42][2] == true
                ary.push("Relic Song") if $game_variables[42][3] == true
                ary.push("Tesseract") if $game_variables[42][4] == true
                ary.push("Heart Swap") if $game_variables[42][5] == true
                ary.push("Hyperspace Hole") if $game_variables[42][6] == true
                ary.push("Diamond Storm") if $game_variables[42][7] == true
                ary.push("Doom Desire") if $game_variables[42][8] == true
                ary.push("V-Create") if $game_variables[42][9] == true
                ary.push("Abyssal Cultist") if $game_variables[42][10] == true
                ary.push("Abyssal Scientist") if $game_variables[42][11] == true
                ary.push("Audrey") if $game_variables[42][12] == true
                ary.push("Infernal Cultist") if $game_variables[42][13] == true
                ary.push("Zenith") if $game_variables[42][14] == true
                v = Kernel.pbMessage("Choose an interaction.",ary)
                if ary[v]=="Darkrai Cultist"
                  if $game_map.map_id!=42 && $game_map.map_id!=69 && $game_map.map_id!=70 && $game_map.map_id!=71
                    Kernel.pbMessage("There's no reason to do that now.")
                    return
                  end
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
                  $game_variables[112]=$PokemonGlobal.playerID if $PokemonGlobal.playerID < 6
                  pbChangePlayer(6)
                  $game_variables[41]=1
                elsif ary[v]=="Abyssal Cultist"
                  if $game_map.map_id!=278 || $PokemonGlobal.surfing
                    Kernel.pbMessage("There's no reason to do that now.")
                    return false
                  end  
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
                  $game_variables[112]=$PokemonGlobal.playerID if $PokemonGlobal.playerID < 6
                  pbChangePlayer(7)
                  $game_variables[41]=2
                  $game_map.need_refresh=true
                  return true
                elsif ary[v]=="Abyssal Scientist"
                  if $game_map.map_id!=278
                    Kernel.pbMessage("There's no reason to do that now.")
                    return false
                  end  
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
                  $game_variables[112]=$PokemonGlobal.playerID if $PokemonGlobal.playerID < 6
                  pbChangePlayer(8)
                  $game_variables[41]=3
                  $game_map.need_refresh=true
                  return true
                elsif ary[v]=="Audrey"
                  if $game_map.map_id!=278
                    Kernel.pbMessage("There's no reason to do that now.")
                    return false
                  end  
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
                  $game_variables[112]=$PokemonGlobal.playerID if $PokemonGlobal.playerID < 6
                  pbChangePlayer(9)
                  $game_variables[41]=4
                  $game_map.need_refresh=true
                  return true
                elsif ary[v]=="Infernal Cultist"
                  if ($game_map.map_id!=433 && $game_map.map_id!=432) || $game_switches[478]
                    Kernel.pbMessage("There's no reason to do that now.")
                    return false
                  end  
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
                  $game_variables[112]=$PokemonGlobal.playerID if $PokemonGlobal.playerID < 6
                  pbChangePlayer(10)
                  $game_variables[41]=13
                  $game_map.need_refresh=true
                  return true
                elsif ary[v]=="Zenith"
                  if ($game_map.map_id!=607 && $game_map.map_id!=432) || ($game_switches[478] && $game_map.map_id!=607)#
                    Kernel.pbMessage("There's no reason to do that now.")
                    return false
                  end  
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
                  $game_variables[112]=$PokemonGlobal.playerID if $PokemonGlobal.playerID < 6
                  pbChangePlayer(11)
                  $game_variables[41]=14
                  $game_map.need_refresh=true
                  return true  
                elsif ary[v]=="Seed Flare" 
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, pos_x, pos_y)
                  for i in 0...events.length
                    if events[i] && events[i][8]=="Dependent"
                      $game_variables[39]=124
                      $game_variables[40]=1
                      events[i][6]=sprintf("492")
                      @realEvents[i].character_name=sprintf("492")
                    end
                  end
                  pbPlayCry(492)
                  $scene.spriteset.addUserAnimation(Seed_Flare, pos_x, pos_y)
                  pbWait(150)
                  $PokemonTemp.dependentEvents.refresh_sprite
                  Kernel.useShayminAbility
                elsif ary[v]=="Relic Song" 
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, pos_x, pos_y)
                  for i in 0...events.length
                    if events[i] && events[i][8]=="Dependent"
                      $game_variables[39]=400
                      $game_variables[40]=2
                      events[i][6]=sprintf("648")
                      @realEvents[i].character_name=sprintf("648")
                    end
                  end
                  pbPlayCry(648)
                  $scene.spriteset.addUserAnimation(Relic_Song, pos_x, pos_y)
                  pbWait(300)
                  $PokemonTemp.dependentEvents.refresh_sprite
                  Kernel.useRelicSong
                elsif ary[v]=="Tesseract" 
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, pos_x, pos_y)
                  for i in 0...events.length
                    if events[i] && events[i][8]=="Dependent"
                      $game_variables[39]=10
                      $game_variables[40]=3
                      events[i][6]=sprintf("251")
                      @realEvents[i].character_name=sprintf("251")
                    end
                  end
                  pbPlayCry(251)
                  $scene.spriteset.addUserAnimation(Tesseract, pos_x, pos_y)
                  pbWait(150)
                  $PokemonTemp.dependentEvents.refresh_sprite
                  Kernel.useTesseract
                elsif ary[v]=="Heart Swap"
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, pos_x, pos_y)
                  for i in 0...events.length
                    if events[i] && events[i][8]=="Dependent"
                      $game_variables[39]=100
                      $game_variables[40]=4
                      events[i][6]=sprintf("490")
                      @realEvents[i].character_name=sprintf("490")
                    end
                  end
                  pbPlayCry(490)
                  $scene.spriteset.addUserAnimation(Heart_Swap, pos_x, pos_y)
                  pbWait(100)
                  Kernel.pbUseHeartSwap
                  $PokemonTemp.dependentEvents.refresh_sprite
                elsif ary[v]=="Hyperspace Hole" 
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, pos_x, pos_y)
                  for i in 0...events.length
                    if events[i] && events[i][8]=="Dependent"
                      $game_variables[39]=100
                      $game_variables[40]=5
                      events[i][6]=sprintf("720")
                      @realEvents[i].character_name=sprintf("720")
                    end
                  end
                  pbPlayCry(720)
                  $scene.spriteset.addUserAnimation(Hyperspace_Hole, pos_x, pos_y)
                  pbWait(100)
                  $PokemonTemp.dependentEvents.refresh_sprite
                  Kernel.pbUseHyperspaceHole
                elsif ary[v]=="Doom Desire" 
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, pos_x, pos_y)
                  for i in 0...events.length
                    if events[i] && events[i][8]=="Dependent"
                      $game_variables[39]=100
                      $game_variables[40]=6
                      events[i][6]=sprintf("385")
                      @realEvents[i].character_name=sprintf("385")
                    end
                  end
                  pbPlayCry(385)
                  $scene.spriteset.addUserAnimation(Doom_Desire, pos_x, pos_y)
                elsif ary[v]=="V-Create" 
                  pbPlayCry(151)
                  $scene.spriteset.addUserAnimation(Animation_Come_Out, pos_x, pos_y)
                  for i in 0...events.length
                    if events[i] && events[i][8]=="Dependent"
                      $game_variables[39]=100
                      $game_variables[40]=7
                      events[i][6]=sprintf("494")
                      @realEvents[i].character_name=sprintf("494")
                    end
                  end
                  pbPlayCry(494)
                  $scene.spriteset.addUserAnimation(V_Create, pos_x, pos_y)
                end 
              end
            else
              facePlayer(Kernel.pbGetDependency("Dependent"))
              if random1==0
                $scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2) if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} loves this tune so much that {1} is singing it.",e.name)) 
              elsif random1==1
                $scene.spriteset.addUserAnimation(Emo_Happy, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} is pumped up and raring to go!",e.name)) 
              elsif random1==2
                $scene.spriteset.addUserAnimation(Emo_Happy, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} is practicing its {2} move for the next battle!",e.name,PBMoves.getName(e.moves[0].id))) 
              elsif random1==3
                $scene.spriteset.addUserAnimation(Emo_Happy, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} is chilling out, maxing, relaxing all cool.",e.name)) 
              elsif random1==4
                $scene.spriteset.addUserAnimation(Emo_sing, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} is anxious to see what {2} will do next.",e.name, $Trainer.name)) 
              elsif random1==5
                $scene.spriteset.addUserAnimation(Emo_exclaim, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} seems to be trying to tell {2} something with their eyes.",e.name, $Trainer.name)) 
              elsif random1==6
                $scene.spriteset.addUserAnimation(Emo_tired, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} is taking it easy.",e.name, $Trainer.name)) 
              elsif random1==7
                $scene.spriteset.addUserAnimation(Emo_sad, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} found an item, but dropped it.",e.name, $Trainer.name)) 
              elsif random1==8
                $scene.spriteset.addUserAnimation(Emo_Happy, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} is stoked for its next battle!",e.name, $Trainer.name)) 
              elsif e.happiness>0 && e.happiness<=50
                $scene.spriteset.addUserAnimation(Emo_Hate, pos_x, pos_y-2) if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} hates to travel with {2}.",e.name,$Trainer.name))
              elsif e.status==PBStatuses::POISON && e.hp>0 && !e.egg?
                $scene.spriteset.addUserAnimation(Emo_Poison, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} is badly poisoned, {1} needs help quick.",e.name))
              elsif e.happiness>50 && e.happiness<=100
                $scene.spriteset.addUserAnimation(Emo_Normal, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} is still undecided for whether traveling with {2} is a good thing or not.",e.name,$Trainer.name))
              elsif e.happiness>100 && e.happiness<150
                $scene.spriteset.addUserAnimation(Emo_Happy, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} is happy traveling with {2}.",e.name,$Trainer.name))
              elsif e.happiness>=150 && e.happiness<200
                $scene.spriteset.addUserAnimation(Emo_love, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} loves traveling with {2}.",e.name,$Trainer.name))
              elsif e.happiness>=200
                $scene.spriteset.addUserAnimation(Emo_love, pos_x, pos_y-2)  if $scene && $scene.spriteset && pos_x && pos_y
                Kernel.pbMessage(_INTL("{1} loves nothing more than being with {2}.",e.name,$Trainer.name))
              end
            end
          end
        end
      end
    end
  end


   def check_sprite_follow
    return
    return if !$scene
        return if !$scene.spriteset
    return if $scene == nil
        return if $scene.spriteset ==nil

#    if !$game_switches[241]
#     return 
#    end
    $game_switches[262]=true
    e=$Trainer.party[0]
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]=="Dependent"
          pos_x=@realEvents[i].x
          pos_y=@realEvents[i].y
      end
    end
    if e==0
    else
    if e.hp>0 && !$Trainer.party[0].egg?
    if $PokemonGlobal.surfing==true || $PokemonGlobal.diving ||$PokemonGlobal.bicycle==true
    else
      if e!=6
  #     pbPlayCry(e.species)
       random1=rand(15)     
     end
     
    end
   end
  end
 end

 
def Come_back(shiny=nil, animation=nil)
  if @realEvents[0] != nil
    events=$PokemonGlobal.dependentEvents
    $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[0].x,@realEvents[0].y)

    if $game_variables[Current_Following_Variable]==$Trainer.party.length
      $game_variables[Current_Following_Variable]
    else
      $game_variables[Current_Following_Variable]
    end
    if $game_variables[Current_Following_Variable]==$Trainer.party.length
      remove_sprite(false)
      for i in 0...events.length 
        $scene.spriteset.addUserAnimation(Animation_Come_Out,@realEvents[i].x,@realEvents[i].y)
      end
    else
      if $Trainer.party[0].isShiny?
        shiny=true
      else
        shiny=false
      end
      change_sprite($Trainer.party[0].species,shiny,false,$Trainer.party[0].gender==1)
    end
    for i in 0..$Trainer.party.length-1
      if $Trainer.party[i].hp>0 && !$Trainer.party[0].egg?
        $game_variables[Current_Following_Variable]=i
        refresh_sprite
        break
      end
    end
    for i in 0...events.length 
      for i in 0..$Trainer.party.length-1
        if $Trainer.party[i].hp<=0 
          id = $Trainer.party[i].species
        else
          id = $Trainer.party[i].species
        end
      end
      if events[i] && events[i][8]=="Dependent"
        append="%03d"
        if $Trainer.party[0].gender==1 && FileTest.image_exist?("Graphics/Characters/"+sprintf(append+"f",id))
          append+="f"
        end
        if shiny
          append+="s"
        end
        if $Trainer.party[0].form!=0
          append+=("_"+($Trainer.party[0].form).to_s)
        end
        events[i][6]=sprintf(append,id)
        @realEvents[i].character_name=events[i][6]
=begin
        if shiny==true
           events[i][6]=sprintf("%03ds",id)
        if FileTest.image_exist?("Graphics/Characters/"+events[i][6])
          @realEvents[i].character_name=sprintf("%03ds",id)
        else
          events[i][6]=sprintf("%03d",id)
          @realEvents[i].character_name=sprintf("%03d",id)
          end
        else
          events[i][6]=sprintf("%03d",id)
          @realEvents[i].character_name=sprintf("%03d",id)
        end
=end
        if animation==true
        else
        end
      end 
    end 
  end
end


  #----------------------------------------------------------------------------
  # - check_faint
  # - If current Pokemon is fainted, change other Pokemon.
  #----------------------------------------------------------------------------

def check_faint
  if $PokemonGlobal.surfing==true || $PokemonGlobal.diving || $PokemonGlobal.bicycle==true
  else
=begin
  if $Trainer.party[0].hp<=0 
    $game_variables[Current_Following_Variable]=0  
    remove_sprite
   elsif $Trainer.party[0].hp>0 && !$Trainer.party[0].egg?

   end
=end
  end
end

def SetMoveRoute(commands,waitComplete=false)
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]=="Dependent"
        pbMoveRoute(@realEvents[i],commands,waitComplete)
      end
    end
  end
end

  #----------------------------------------------------------------------------
  # -  Auto add Script to Kernel.pbSurf, It'll check curent Pokemon when surf
  #----------------------------------------------------------------------------  

  def Kernel.pbSurf
#  if $game_player.pbHasDependentEvents?
#    return false
#  end
  if $DEBUG ||
    ($game_switches[4])
    movefinder=Kernel.pbCheckMove(:SURF)
    if $DEBUG || movefinder
      if Kernel.pbConfirmMessage(_INTL("The water is dyed a deep blue...  Would you like to surf?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Surf!",speciesname))
        pbHiddenMoveAnimation(movefinder)
    #    $PokemonTemp.dependentEvents.check_surf
        surfbgm=pbGetMetadata(0,MetadataSurfBGM)
    #    $PokemonTemp.dependentEvents.check_surf
        if surfbgm
          pbCueBGM(surfbgm,0.5)
        end
        pbStartSurfing()
        return true
      end
    end
  end
  return false
end



  #----------------------------------------------------------------------------
  # -  Auto add Script to pbEndSurf, It'll show sprite after surf
  #----------------------------------------------------------------------------  

  def pbEndSurf(xOffset,yOffset)
      return false if !$PokemonGlobal.surfing || $PokemonGlobal.diving
  x=$game_player.x
  y=$game_player.y
  currentTag=$game_map.terrain_tag(x,y)
  facingTag=Kernel.pbFacingTerrainTag
  if !pbIsSurfableTag?(facingTag) && facingTag!=PBTerrain::StillWater && (pbIsSurfableTag?(currentTag) || currentTag==PBTerrain::StillWater)
    if Kernel.pbJumpToward
      Kernel.pbCancelVehicles
      $game_map.autoplayAsCue
      $game_player.increase_steps
      result=$game_player.check_event_trigger_here([1,2])
      Kernel.pbOnStepTaken(result)
      $PokemonTemp.dependentEvents.Come_back(true)
    end
    return true
  end
  return false
end

=begin


HiddenMoveHandlers::CanUseMove.add(:HYPNOSIS,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})


HiddenMoveHandlers::CanUseMove.add(:GRASSWHISTLE,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:SLEEPPOWDER,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:SPORE,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:SING,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:WHIRLWIND,proc{|move,pkmn|
  return Kernel.pbCanUseWhirlwind(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:ROAR,proc{|move,pkmn|
  return Kernel.pbCanUseWhirlwind(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:MILKDRINK,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:RECOVER,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:SLACKOFF,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:ROOST,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:SYTNHESIS,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:MORNINGSUN,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:HEALORDER,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

def Kernel.pbCanUseHypnosis(move,pkmn)
     eventArray = $game_map.events
    useEvent=nil
    for event in eventArray
      if event.x < $game_player.x+2 && event.x > $game_player.x-2
         if event.y < $game_player.y+2 && event.y > $game_player.y-2
          if event.name.include?("Sleepy")
           useEvent=event
           break
          end
        end
      end
    end
    if useEvent==nil
     Kernel.pbMessage(_INTL("Can't use that here."))
   end
   return true  

end

def Kernel.pbCanUseHealSelf(move,pkmn)
  Kernel.pbMessage("Ah")
  return false if pkmn.hp >= pkmn.totalhp
  Kernel.pbMessage("Ah")
  return false if move.pp==0
  Kernel.pbMessage("Ah")
  return true
end

def Kernel.pbCanUseWhirlwind(move,pkmn)
  return false if move.pp==0
  return true
end



=end
  #----------------------------------------------------------------------------
  # -  Auto add Script to Kernel.pbCanUseHiddenMove, fix HM bug
  #----------------------------------------------------------------------------  
def Kernel.pbCanUseHiddenMove?(pkmn,move)
 case move
  when PBMoves::WHIRLWIND

    return Kernel.pbCanUseWhirlwind(move,pkmn)
  when PBMoves::ROAR
    return Kernel.pbCanUseWhirlwind(move,pkmn)
=begin
  when PBMoves::SLEEPPOWDER
    return Kernel.pbCanUseHypnosis(move,pkmn)
  when PBMoves::SLEEPPOWDER
    return Kernel.pbCanUseHypnosis(move,pkmn)
  when PBMoves::SPORE
    return Kernel.pbCanUseHypnosis(move,pkmn)
  when PBMoves::SING
    return Kernel.pbCanUseHypnosis(move,pkmn)
=end
  when PBMoves::MILKDRINK
    return Kernel.pbCanUseHealSelf(move,pkmn)
  when PBMoves::RECOVER
    return Kernel.pbCanUseHealSelf(move,pkmn)
  when PBMoves::HEALORDER
    return Kernel.pbCanUseHealSelf(move,pkmn)
  when PBMoves::SLACKOFF
    return Kernel.pbCanUseHealSelf(move,pkmn)
  when PBMoves::ROOST
    return Kernel.pbCanUseHealSelf(move,pkmn)
  when PBMoves::SYNTHESIS
    return Kernel.pbCanUseHealSelf(move,pkmn)
  when PBMoves::MORNINGSUN
    return Kernel.pbCanUseHealSelf(move,pkmn)
  when PBMoves::FLY
  if !$game_switches[7]
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
    return false
  end
  noFlyAry=[447,619,451,459,453,452,563,488,558,461,454,560,455,460,749,750,769]
  if $game_map.map_id==287
    Kernel.pbMessage("Some force keeps you from flying here...")
    return false
  end
  
  #if $game_player.pbHasDependentEvents?
  # Kernel.pbMessage(_INTL("You can't use that if you have someone with you."))
  # return false
  #end
  if !pbGetMetadata($game_map.map_id,MetadataOutdoor) || noFlyAry.include?($game_map.map_id)
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
  end
  return true
   
  when PBMoves::DIG
    escape=($PokemonGlobal.escapePoint rescue nil)
  if !escape || escape==[] || $game_map.map_id==827
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
  end
  if $game_map.map_id==502
    Kernel.pbMessage(_INTL("Can't use that in this room."))
    return false
  end
  mapname=pbGetMapNameFromId(escape[0])
  if Kernel.pbConfirmMessage(_INTL("Want to escape from here and return to {1}?",mapname))
    return true
  end
  return false

   
   
  when PBMoves::TESSERACT
    if $game_switches[172]
      return true
    end
    Kernel.pbMessage("Can't use that here.")
    return false
  when PBMoves::CUT
   if !$DEBUG && !$game_switches[6]
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
    return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Tree"
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
   end
   return true
  when PBMoves::HEADBUTT 
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="HeadbuttTree"
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
   end
   return true
  when PBMoves::SURF
   terrain=Kernel.pbFacingTerrainTag
   if !$game_switches[4]
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
    return false
   end
   if $PokemonGlobal.surfing
    Kernel.pbMessage(_INTL("You're already surfing."))
    return false
   end
   #if $game_player.pbHasDependentEvents?
   # Kernel.pbMessage(_INTL("You can't use that if you have someone with you."))
   # return false
   #end
   terrain=Kernel.pbFacingTerrainTag
   if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
    Kernel.pbMessage(_INTL("Let's enjoy cycling!"))
    return false
   end
   if !pbIsWaterTag?(terrain)
    Kernel.pbMessage(_INTL("No surfing here!"))
    return false
   end
   return true
  when PBMoves::STRENGTH
   if !$game_switches[4]
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
    return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Boulder"
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
   end
   return true  
  when PBMoves::ROCKSMASH
   terrain=Kernel.pbFacingTerrainTag
   if !$game_switches[10]
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
    return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Rock"
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
    end


   return true  
  when PBMoves::FLASH
   if !pbGetMetadata($game_map.map_id,MetadataDarkMap)
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
   end
   if $PokemonGlobal.flashUsed
    Kernel.pbMessage(_INTL("This is in use already."))
    return false
   end
   return true
=begin
  when PBMoves::WATERFALL 
   if !$game_switches[9]
    Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
    return false
   end
   terrain=Kernel.pbFacingTerrainTag
#   if terrain!=PBTerrain::Waterfall
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
#   end
   return true
=end
  when PBMoves::DIVE
#   if !$game_switches[11]
#    Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
#    return false
#  end
   if $PokemonGlobal.diving
     return true if DIVINGSURFACEANYWHERE
     divemap=nil
     meta=pbLoadMetadata
     for i in 0...meta.length
       if meta[i] && meta[i][MetadataDiveMap]
         if meta[i][MetadataDiveMap]==$game_map.map_id
           divemap=i
           break
         end
       end
     end
     if $MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y)==PBTerrain::DeepWater
       return true
     else
       Kernel.pbMessage(_INTL("Can't use that here."))
       return false
     end
   end
   if $game_player.terrain_tag!=PBTerrain::DeepWater
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataDiveMap)
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
   end
   return true
=begin
   when PBMoves::HYPNOSIS
   eventArray = $game_map.events.values
    useEvent=nil
    for event2 in eventArray
      if event2.x < $game_player.x+2 && event2.x > $game_player.x-2
         if event2.y < $game_player.y+2 && event2.y > $game_player.y-2
          if event2.name.include?("Sleepy")
           useEvent=event2
           break
          end
        end
      end
    end
    if useEvent==nil
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true  
=end

  when PBMoves::TELEPORT
    if $game_map.map_id==287
      Kernel.pbMessage("Some force keeps you from flying here...")
      return false
    end
    if !pbGetMetadata($game_map.map_id,MetadataOutdoor) || $game_switches[134]
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end

    #if $game_player.pbHasDependentEvents?
    # Kernel.pbMessage(_INTL("You can't use that if you have someone with you."))
    # return false
    #end
    healing=$PokemonGlobal.healingSpot
    if !healing
      healing=pbGetMetadata(0,MetadataHome) # Home
    end
    if healing
      mapname=pbGetMapNameFromId(healing[0])
      if mapname=="Shade Forest" || mapname=="Telnor Cave"
        healing=pbGetMetadata(32,MetadataHealingSpot)
        #  Kernel.pbMessage("1")
      end
      if Kernel.pbConfirmMessage(_INTL("Want to return to the healing spot used last in {1}?",mapname))
        return true
      end
      return false
    else
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
  when PBMoves::SWEETSCENT
    return true
  end
end
   

def pbPokemonFollow(x)
  if $PokemonGlobal.dependentEvents.length==0
    Kernel.pbAddDependency2(x, "Dependent", CommonEvent)
    $PokemonTemp.dependentEvents.refresh_sprite
  end
end

def Talkative
  $PokemonTemp.dependentEvents.talk_to_pokemon
end

def facePlayer(follower)
  case $game_player.direction
  when 2 # down
    follower.turn_up
  when 4 # left
    follower.turn_right
  when 6 # right
    follower.turn_left
  when 8 # up
    follower.turn_down
  end
end