#===============================================================================
# This script implements items included by default in Pokemon Essentials.
#===============================================================================

#===============================================================================
# UseFromBag handlers
#===============================================================================


def pbTesseract
  if !$game_switches[156]
          Kernel.pbMessage(_INTL("Don't have enough badges!"))
     return 0
   end
    if !$game_switches[172] && !$game_map.map_id == 33#!$PokemonMap.tesseract
   Kernel.pbMessage("Can't use that here.")
   return 0
 end
   if $game_switches[172] || $game_map.map_id == 33
     Kernel.pbMessage(_INTL("The Time Caller was used!"))
        $PokemonMap.tesseract = true
        return 2
    end

  end

  ItemHandlers::UseFromBag.add(:TIMECALLER,proc{|item|  pbTesseract  })

def pbFlashlight
   darkness=$PokemonTemp.darknessSprite
   return false if !darkness || darkness.disposed?
   $PokemonGlobal.flashUsed=true
   while darkness.radius<176
     Graphics.update
     Input.update
     pbUpdateSceneMap
     darkness.radius+=4
   end
   return true
end
  
  
def pbRepel(item,steps)
  if $PokemonGlobal.repel>0
    Kernel.pbMessage(_INTL("But the effects of a Repel lingered from earlier."))
    return 0
  else
    Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
    $PokemonGlobal.repel=steps
    return 3
  end
end

ItemHandlers::UseFromBag.add(:REPEL,proc{|item|  pbRepel(item,100)  })

ItemHandlers::UseFromBag.add(:FLASHLIGHT,proc{|item| next 2 })
ItemHandlers::UseInField.add(:FLASHLIGHT,proc{|item| pbFlashlight })

ItemHandlers::UseFromBag.add(:SUPERREPEL,proc{|item|  pbRepel(item,200)  })

ItemHandlers::UseFromBag.add(:MAXREPEL,proc{|item|  pbRepel(item,250)  })

Events.onStepTaken+=proc {
   if $PokemonGlobal.repel>0
     $PokemonGlobal.repel-=1
     if $PokemonGlobal.repel<=0 && !$game_switches[136]
       Kernel.pbMessage(_INTL("Repel's effect wore off..."))
       ret=pbChooseItemFromList(_INTL("Do you want to use another Repel?"),1,
          :REPEL,:SUPERREPEL,:MAXREPEL)
       pbUseItem($PokemonBag,ret) if ret>0
     end
   end
}

ItemHandlers::UseFromBag.add(:BLACKFLUTE,proc{|item|
   Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
   Kernel.pbMessage(_INTL("Wild Pokémon will be repelled."))
   $PokemonMap.blackFluteUsed=true
   $PokemonMap.whiteFluteUsed=false
   next 1
})
ItemHandlers::UseFromBag.add(:SCUBAGEAR,proc{|item|
  divemap=pbGetMetadata($game_map.map_id,MetadataDiveMap)
  return false if !divemap
  if $DEBUG || $PokemonBag.pbQuantity(PBItems::SCUBAGEAR) > 0 ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE])
    movefinder=Kernel.pbCheckMove(:DIVE)
    if $DEBUG || movefinder || $PokemonBag.pbQuantity(PBItems::SCUBAGEAR) > 0
      if $PokemonBag.pbQuantity(PBItems::SCUBAGEAR) > 0
        Kernel.pbMessage(_INTL("Put the Scuba Gear on!"))
      else
        Kernel.pbMessage(_INTL("The sea is deep here."))
      end
      if Kernel.pbConfirmMessage(_INTL("Would you like to use Dive?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Dive.",speciesname))
        pbHiddenMoveAnimation(movefinder)
        pbFadeOutIn(99999){
           $game_temp.player_new_map_id=divemap
           $game_temp.player_new_x=$game_player.x
           $game_temp.player_new_y=$game_player.y
           $game_temp.player_new_direction=$game_player.direction
           Kernel.pbCancelVehicles
           $PokemonGlobal.diving=true
           Kernel.pbUpdateVehicle
           $PokemonTemp.dependentEvents.refresh_sprite
           $scene.transfer_player(false)
           $game_map.autoplay
           $game_map.refresh
        }
        next 1
      end
    else
      Kernel.pbMessage(_INTL("The sea is deep here.  A Pokémon may be able to go underwater."))
    end
  else
    Kernel.pbMessage(_INTL("The sea is deep here.  A Pokémon may be able to go underwater."))
  end
  next 1
})

ItemHandlers::UseFromBag.add(:WHITEFLUTE,proc{|item|
   Kernel.pbMessage(_INTL("{1} used the {2}.",$Trainer.name,PBItems.getName(item)))
   Kernel.pbMessage(_INTL("Wild Pokémon will be lured."))
   $PokemonMap.blackFluteUsed=false
   $PokemonMap.whiteFluteUsed=true
   next 1
})

ItemHandlers::UseFromBag.add(:HONEY,proc{|item|  next 4  })


ItemHandlers::UseFromBag.add(:ROCKETBOOTS,proc{|item|
  if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
    Kernel.pbMessage(_INTL("Can't use that here."))
    next 0
  end
  scene=PokemonRegionMapScene.new(-1,false)
  screen=PokemonRegionMap.new(scene)
  ret=screen.pbStartFlyScreen
  if ret
    $PokemonTemp.flydata=ret
  else
    next 0
  end
  if !$PokemonTemp.flydata
    Kernel.pbMessage(_INTL("Can't use that here.2"))
  end
   
  Kernel.pbMessage(_INTL("The Rocket Boots were used!"))
  pbFadeOutIn(99999){
      $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
      $game_temp.player_new_x=$PokemonTemp.flydata[1]
      $game_temp.player_new_y=$PokemonTemp.flydata[2]
           $game_switches[172]=false

      $PokemonTemp.flydata=nil
      $game_temp.player_new_direction=2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
      $game_screen.weather(0,0,0)
weather=pbGetMetadata($game_map.map_id,MetadataWeather)
      $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
   }
   pbEraseEscapePoint
   next 2
})


ItemHandlers::UseFromBag.add(:PIKAPAD,proc{|item|
Kernel.pbMessage("Equip the Pikapad and use it from the field.")
return
   noFlyAry=[447,619,451,459,453,452,563,488,558,461,454,560,455,460,749,750,769]
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor) || noFlyAry.include?($game_map.map_id)
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
   end
   scene=PokemonRegionMapScene.new(-1,false)
   screen=PokemonRegionMap.new(scene)
   ret=screen.pbStartFlyScreen
   if ret
     $PokemonTemp.flydata=ret
     else
       next 0
     end
   if !$PokemonTemp.flydata || noFlyAry.include?($game_map.map_id)
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
   end
   
   Kernel.pbMessage(_INTL("Dialed the EmolgaTaxi Guy!"))
   pbFadeOutIn(99999){
      $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
      $game_temp.player_new_x=$PokemonTemp.flydata[1]
      $game_temp.player_new_y=$PokemonTemp.flydata[2]
      $game_switches[172]=false
      $PokemonTemp.flydata=nil
      $game_temp.player_new_direction=2
      $scene.transfer_player
      $game_player.move_down
      $game_map.autoplay
      $game_map.refresh
      $game_screen.weather(0,0,0)
      weather=pbGetMetadata($game_map.map_id,MetadataWeather)
      $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
      $PokemonTemp.dependentEvents.refresh_sprite
   }
   pbEraseEscapePoint
   next 2
})


ItemHandlers::UseFromBag.add(:ESCAPEROPE,proc{|item|
    if $game_switches[134] || $game_map.map_id==827
      Kernel.pbMessage(_INTL("Can't use that here."))
      next 0
    end
    if $game_map.map_id==502
      Kernel.pbMessage(_INTL("Can't use that in this room."))
      next 0
    end
   #if $game_player.pbHasDependentEvents?
   #  Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
   #  next 0
   #end
   if ($PokemonGlobal.escapePoint rescue false) && $PokemonGlobal.escapePoint.length>0
     next 4 # End screen and consume item
   else
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
   end
})

ItemHandlers::UseFromBag.add(:GOGOGGLES,proc{|item|
  if $game_map.map_id==285 || $game_map.map_id==286 || $game_map.map_id==668 || $game_map.map_id==287 || $game_map.map_id==288 || $game_map.map_id==666
   else
    Kernel.pbMessage("Put the Go-Goggles on!")
    $game_screen.weather(0,0,0)
  end
  
})

ItemHandlers::UseFromBag.add(:ZYGARDECUBE,proc{|item|
  Kernel.pbMessage("Retrieving information...")
  coreString="Cores"
  cellString="Cells"
  if $game_variables[187]==1
    coreString="Core"
  end
  if $game_variables[188]==1
    cellString="Cell"
  end
  Kernel.pbMessage(_INTL("Contents:\\n\\c[2]{1} \\c[0]" + coreString + ", \\c[3]{2} \\c[0]" + cellString + ".",
      $game_variables[187].to_s,$game_variables[188].to_s))
  zygardePresent=false
  for i in $Trainer.party
    if isConst?(i.species,PBSpecies,:ZYGARDE)
      zygardePresent=true
      break
    end
  end
  choices=[]
  choices.push("Yes")
  choices.push("No")
  if zygardePresent && $game_variables[187]>0
    decision=Kernel.pbMessage("Zygarde's presence has been detected. Would you like to teach it a new move?",choices)
    if decision==0
      $game_switches[692]=true
      moveOptions=[]
      moveOptions.push("(Cancel)")
      if $game_variables[187]>0
        moveOptions.push("Dragon Dance")
      end
      if $game_variables[187]>1
        moveOptions.push("Extreme Speed")
      end
      if $game_variables[187]>2
        moveOptions.push("Thousand Waves")
      end
      if $game_variables[187]>3
        moveOptions.push("Thousand Arrows")
      end
      if $game_variables[187]>4
        moveOptions.push("Core Enforcer")
      end
      moveSelection=Kernel.pbMessage("Select a move.",moveOptions)
      case moveSelection
      when 1; pbMoveTutorChoose(PBMoves::DRAGONDANCE,nil,false,true)
      when 2; pbMoveTutorChoose(PBMoves::EXTREMESPEED,nil,false,true)
      when 3; pbMoveTutorChoose(PBMoves::THOUSANDWAVES,nil,false,true)
      when 4; pbMoveTutorChoose(PBMoves::THOUSANDARROWS,nil,false,true)
      when 5; pbMoveTutorChoose(PBMoves::COREENFORCER,nil,false,true)
      else
      end
    end
    $game_switches[692]=false
  end
  if ($game_variables[187]+$game_variables[188]>=50) && zygardePresent
    abilityDecision=Kernel.pbMessage("50 Cores and Cells are now available. Would you like to change Zygarde's ability?",choices)
    if abilityDecision==0
      pbFadeOutIn(99999){
      scene=PokemonScreen_Scene.new
      screen=PokemonScreen.new(scene,$Trainer.party)
      screen.pbStartScene(_INTL("Select Zygarde."),false)
      chosen=screen.pbChoosePokemon
      if chosen>=0
        poke=$Trainer.party[chosen]
        if isConst?(poke.species,PBSpecies,:ZYGARDE)
          abils=poke.getAbilityList          
          if poke.ability==abils[0][0]
            poke.setAbility(1)
            screen.pbDisplay(_INTL("{1}'s ability was changed to {2}!",poke.name,PBAbilities.getName(abils[0][1])))
          else
            poke.setAbility(0)
            screen.pbDisplay(_INTL("{1}'s ability was changed to {2}!",poke.name,PBAbilities.getName(abils[0][0])))
          end
          screen.pbEndScene
        else
          screen.pbDisplay(_INTL("{1} cannot be selected.",poke.name))
          screen.pbEndScene
        end
      else
        screen.pbEndScene
      end
    }
    end
  end
  Kernel.pbMessage("Ending sequence...")
  next 0
})


ItemHandlers::UseFromBag.add(:SACREDASH,proc{|item|
   revived=0
   if $Trainer.pokemonCount==0
     Kernel.pbMessage(_INTL("There is no Pokémon."))
     next 0
   end
      if $game_switches[71]
        Kernel.pbMessage(_INTL("You are doing a Nuzlocke Challenge!\nYou cannot revive Pokemon!"))
        next 0
      end
      
   pbFadeOutIn(99999){
      scene=PokemonScreen_Scene.new
      screen=PokemonScreen.new(scene,$Trainer.party)
      screen.pbStartScene(_INTL("Using item..."),false)
      for i in $Trainer.party
       if i.hp<=0 && !i.egg?
         revived+=1
         i.heal
         screen.pbDisplay(_INTL("{1} regained health.",i.name))
       end
     end
     if revived==0
       screen.pbDisplay(_INTL("It won't have any effect."))
     end
     $PokemonTemp.dependentEvents.refresh_sprite
     screen.pbEndScene
   }
   next (revived==0) ? 0 : 3
})
ItemHandlers::UseFromBag.add(:QUARTZFLUTE,proc{|item|
  #Kernel.pbMessage("1")

 next 2 #if Kernel.doQuartzFlute
 next 0
})
ItemHandlers::UseInField.add(:QUARTZFLUTE,proc{|item|
  #Kernel.pbMessage("2")
 next 2 if Kernel.doQuartzFlute
 next 0
})


ItemHandlers::UseFromBag.add(:TABLET,proc{|item|
 # if Kernel.pbTablet
    next 2
 # else
 #   next 0
 # end
  
})

#$game_variables[128]

def pbTablet
   if Kernel.getAllSBMaps.include?($game_map.map_id) && $game_switches[47]
    while 1==1
    #  if $game_variables[128] != 0
     #   if $game_variables[128]>4
      #    v = 0
       # else
        #  v=1
        #end
       #else
        v=Kernel.pbMessage("Select an option.",["Purchase Items","Place Items","Delete Items","Leave Base","(Exit)"],5)
    #  end
    case v
        when 0
          while 2==2
               v2=Kernel.pbMessage("What type of item should be purchased?",["Functions","Decorations","Online Items","(Exit)"],4)
               if v2==3
                  break
                else
                 Kernel.buySecretBaseUpgrades(v2)
               end
            # end
             
          end
        when 1
          
          while 2==2
             #if $game_variables[128] == 0
             v2=Kernel.pbMessage("What type of item should be placed?",["Functions","Decorations","Online Items","(Exit)"],4)
           #  $game_variables[128]=v2
           #  else
            # v2=$game_variables[128] -= 3
          # end
           
             if v2==3
                break
             else
                ary=[]
                ret=Kernel.getStringsOfType(v2)
                for i in ret
                  ary.push(i) if pbGet(80)[Kernel.getNumberForUpgrade(i)]==true
                end
                ary.push("(Exit)")
                str=ary[Kernel.pbMessage("Place which item?",ary)]
                if str.include?("(Exit)")
                  #$game_variables[128]=0
                    break
                  end
                  j123 = 0
                  for k123 in 1..5
                if str.include?("Teleporter ("+k123.to_s+")")
                  for i123 in 1..100
                    if $game_variables[76].is_a?(Array) && $game_variables[76][i123].is_a?(Array) && $game_variables[76][i123][1]==Kernel.gnfu("Teleporter Tile ("+k123.to_s+")")
                      j123 += 1
                      break
                    end
                  end
                end
                end
                if j123 >= 2
                    Kernel.pbMessage("There are too many Teleporters of this connection already!")
                    break
                end
                
                Kernel.pbMessage("Press C on a square to place the "+str+".")
                int=Kernel.getNumberForUpgrade(str)
                Kernel.startSBPlacement(int)
                return true
              end
          end          
        return true
        when 2
          
          $sb_is_deleting=false
            $sb_is_deleting=true
           Kernel.pbMessage("Interact with an item to delete it.")
           return true
        when 3

    if Kernel.pbConfirmMessage("Leave base?")
      $templeavebasetrue=true
      return true
    end          
          
          
        when 4
          return false
        end
      end
      
  elsif Kernel.getAllSBMaps.include?($game_map.map_id)
    if Kernel.pbConfirmMessage("Leave and return to own base?")
      pbCommonEvent(8)
      return true
    end


   else
     Kernel.pbMessage("Can't use that here.")
   return false
    end
 
end

ItemHandlers::UseFromBag.add(:PRISONBOTTLE,proc{|item|
  next 2#(pbHasSpecies?(PBSpecies::HOOPA)) ? 2 : 0
})
ItemHandlers::UseFromBag.add(:CLOUDBOTTLE,proc{|item|
  next 2#(pbHasSpecies?(PBSpecies::DELTAHOOPA)) ? 2 : 0
})

ItemHandlers::UseFromBag.add(:BICYCLE,proc{|item|
   next pbBikeCheck ? 2 : 0
})

ItemHandlers::UseFromBag.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

ItemHandlers::UseFromBag.add(:OLDROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if (pbIsWaterTag?(terrain) && !$PokemonGlobal.surfing && notCliff) ||
      (pbIsWaterTag?(terrain) && $PokemonGlobal.surfing)
     next 2
   else
     Kernel.pbMessage(_INTL("Can't use that here."))
     next 0
   end
})



ItemHandlers::UseFromBag.copy(:OLDROD,:GOODROD,:SUPERROD)

ItemHandlers::UseFromBag.add(:ITEMFINDER,proc{|item| next 2 })

ItemHandlers::UseFromBag.copy(:ITEMFINDER,:DOWSINGMCHN)

ItemHandlers::UseFromBag.add(:TOWNMAP,proc{|item|
   pbShowMap(-1,false)
   next 1 # Continue
})

#def getListOfClothes
#  ary = []
#  if $ItemData
#    for i in 0..$ItemData.length 
#      ary.push($ItemData[i][0]) if $ItemData[i][10] != 100
#    end
#  end
#  return ary
#  
#end

#def getListOfClothes
#    ary = [:C_KANTOCOAT,:C_KANTOCOAT,:C_KANTOPANTS,:C_KANTOSHOES,:C_HEADBAND,
#    :C_MINERSHAT,:C_POLICEHAT,:C_FEDORA,:C_POOPHAT,:C_CLOWNHAT,:C_DRSEUSSHAT,
#    :C_BUGCATCHERHAT,:C_BERET,:C_BEANIE,:C_YOUNGSTERCAP]
#    return ary
  
#end

#for i in getListOfClothes
#end

ItemHandlers::UseFromBag.add(:QUARTZFLUTE,proc{|item|
  #Kernel.pbMessage("1")

 next 2 #if Kernel.doQuartzFlute
 next 0
})
ItemHandlers::UseInField.add(:QUARTZFLUTE,proc{|item|
  #Kernel.pbMessage("2")
 next 2 if Kernel.doQuartzFlute
 next 0
})
def doQuartzFlute
  if $game_switches[418]
    aryb=["Interact","Battle"]
    b = Kernel.pbMessage("Choose an option.",aryb)
    if aryb[b]=="Interact"
    else
      pbPlayCry(151)
      $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
      for i in 0...$PokemonGlobal.dependentEvents.length
        if $PokemonGlobal.dependentEvents[i] && $PokemonGlobal.dependentEvents[i][8]=="Dependent"
          $game_variables[39]=124
          $game_variables[40]=8
          $PokemonGlobal.dependentEvents[i][6]=sprintf("151")
          $PokemonTemp.dependentEvents.realEvents[0].character_name=sprintf("151")
        end
      end
      pbPlayCry(151)
      return
    end
  end
  $tempbooleanfortalk=true
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
      Kernel.pbMessage("There's no reason to use that now.")
      return false
    end  
    pbPlayCry(151)
    $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
    $game_variables[112]=$PokemonGlobal.playerID if $PokemonGlobal.playerID < 6
    pbChangePlayer(6)
    $game_variables[41]=1
    return true
  elsif ary[v]=="Abyssal Cultist"
    if $game_map.map_id!=278 || $PokemonGlobal.surfing
      Kernel.pbMessage("There's no reason to use that now.")
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
      Kernel.pbMessage("There's no reason to use that now.")
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
      Kernel.pbMessage("There's no reason to use that now.")
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
      Kernel.pbMessage("There's no reason to use that now.")
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
      Kernel.pbMessage("There's no reason to use that now.")
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
    $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
    for i in 0...$PokemonGlobal.dependentEvents.length
      if $PokemonGlobal.dependentEvents[i] && $PokemonGlobal.dependentEvents[i][8]=="Dependent"
        $game_variables[39]=124
        $game_variables[40]=1
        $PokemonGlobal.dependentEvents[i][6]=sprintf("492")
        $PokemonTemp.dependentEvents.realEvents[0].character_name=sprintf("492")
      end
    end
    pbPlayCry(492)
    $scene.spriteset.addUserAnimation(Seed_Flare, $game_player.x, $game_player.y)
    pbWait(150)
    $PokemonTemp.dependentEvents.refresh_sprite
    Kernel.useShayminAbility
    return true
  elsif ary[v]=="Relic Song" 
    pbPlayCry(151)
    $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
    for i in 0...$PokemonGlobal.dependentEvents.length
      if $PokemonGlobal.dependentEvents[i] && $PokemonGlobal.dependentEvents[i][8]=="Dependent"
        $game_variables[39]=400
        $game_variables[40]=2
        $PokemonGlobal.dependentEvents[i][6]=sprintf("648")
        $PokemonTemp.dependentEvents.realEvents[0].character_name=sprintf("648")
      end
    end
    pbPlayCry(648)
    $scene.spriteset.addUserAnimation(Relic_Song, $game_player.x, $game_player.y)
    pbWait(300)
    $PokemonTemp.dependentEvents.refresh_sprite
    Kernel.useRelicSong
    return true
  elsif ary[v]=="Tesseract" 
    pbPlayCry(151)
    $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
    for i in 0...$PokemonGlobal.dependentEvents.length
      if $PokemonGlobal.dependentEvents[i] && $PokemonGlobal.dependentEvents[i][8]=="Dependent"
        $game_variables[39]=100
        $game_variables[40]=3
        $PokemonGlobal.dependentEvents[i][6]=sprintf("251")
        $PokemonTemp.dependentEvents.realEvents[0].character_name=sprintf("251")
      end
    end
    pbPlayCry(251)
    $scene.spriteset.addUserAnimation(Tesseract, $game_player.x, $game_player.y)
    pbWait(150)
    $PokemonTemp.dependentEvents.refresh_sprite
    Kernel.useTesseract
    return true
  elsif ary[v]=="Heart Swap"
    pbPlayCry(151)
    $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
    for i in 0...$PokemonGlobal.dependentEvents.length
      if $PokemonGlobal.dependentEvents[i] && $PokemonGlobal.dependentEvents[i][8]=="Dependent"
        $game_variables[39]=100
        $game_variables[40]=4
        $game_switches[62]=false
        $PokemonGlobal.dependentEvents[i][6]=sprintf("490")
        $PokemonTemp.dependentEvents.realEvents[0].character_name=sprintf("490")
      end
    end
    pbPlayCry(490)
    $scene.spriteset.addUserAnimation(Heart_Swap, $game_player.x, $game_player.y)
    pbWait(100)
    Kernel.pbUseHeartSwap
    $PokemonTemp.dependentEvents.refresh_sprite
    return true
  elsif ary[v]=="Hyperspace Hole" 
    pbPlayCry(151)
    $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
    for i in 0...$PokemonGlobal.dependentEvents.length
      if $PokemonGlobal.dependentEvents[i] && $PokemonGlobal.dependentEvents[i][8]=="Dependent"
        $game_variables[39]=100
        $game_variables[40]=5
        $game_switches[62]=false
        $PokemonGlobal.dependentEvents[i][6]=sprintf("720")
        $PokemonTemp.dependentEvents.realEvents[0].character_name=sprintf("720")
      end
    end
    pbPlayCry(720)
    $scene.spriteset.addUserAnimation(Hyperspace_Hole, $game_player.x, $game_player.y)
    pbWait(100)
    $PokemonTemp.dependentEvents.refresh_sprite
    Kernel.pbUseHyperspaceHole
    return true
  elsif ary[v]=="Doom Desire" 
    pbPlayCry(151)
    $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
    for i in 0...$PokemonGlobal.dependentEvents.length
      if $PokemonGlobal.dependentEvents[i] && $PokemonGlobal.dependentEvents[i][8]=="Dependent"
        $game_variables[39]=100
        $game_variables[40]=6
        $PokemonGlobal.dependentEvents[i][6]=sprintf("385")
        $PokemonTemp.dependentEvents.realEvents[0].character_name=sprintf("385")
      end
    end
    pbPlayCry(385)
    $scene.spriteset.addUserAnimation(Doom_Desire, $game_player.x, $game_player.y)
    return true
  elsif ary[v]=="V-Create" 
    pbPlayCry(151)
    $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)
    for i in 0...$PokemonGlobal.dependentEvents.length
      if $PokemonGlobal.dependentEvents[i] && $PokemonGlobal.dependentEvents[i][8]=="Dependent"
        $game_variables[39]=100
        $game_variables[40]=7
        $PokemonGlobal.dependentEvents.events[i][6]=sprintf("494")
        $PokemonTemp.dependentEvents.realEvents[0].character_name=sprintf("494")
      end
    end
    pbPlayCry(494)
    $scene.spriteset.addUserAnimation(V_Create, $game_player.x, $game_player.y)
    return true
  end
  return true
end


ItemHandlers::UseFromBag.add(:C_KANTOHAT,proc{|item|
    Kernel.pbMessage(_INTL("Put on the {1}!",PBItems.getName(item)))
    $Trainer.clothes[0]=$ItemData[item][0]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})

ItemHandlers::UseFromBag.copy(:C_KANTOHAT,:C_HEADBAND,:C_CATEARS,
    :C_DEVILHORNS,:C_SILVERCROWN,:C_GOLDENCROWN,
    :C_MINERSHAT,:C_POLICEHAT,:C_FEDORA,:C_POOPHAT,:C_CLOWNHAT,:C_DRSEUSSHAT,
    :C_BUGCATCHERHAT,:C_BERET,:C_BEANIE,:C_YOUNGSTERCAP,:C_NOHAT)

    ItemHandlers::UseFromBag.add(:C_KANTOSHIRT,proc{|item|
    Kernel.pbMessage(_INTL("Put on the {1}!",PBItems.getName(item)))
    $Trainer.clothes[2]=$ItemData[item][0]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})

ItemHandlers::UseFromBag.copy(:C_KANTOSHIRT,:C_JUMPSUIT,:C_REDSHIRT,:C_BLUESHIRT,:C_GREENSHIRT,
:C_PURPLESHIRT,:C_BLACKSHIRT,:C_ORANGESHIRT,:C_PINKSHIRT,:C_YELLOWSHIRT,:C_ALTERNATESUIT,
:C_LORDSSUIT,:C_SONICSUIT)

    ItemHandlers::UseFromBag.add(:C_PURPLEPACK,proc{|item|
    Kernel.pbMessage(_INTL("Put on the {1}!",PBItems.getName(item)))
    $Trainer.clothes[3]=$ItemData[item][0]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})
ItemHandlers::UseFromBag.copy(:C_PURPLEPACK,:C_BLACKPACK,:C_BLUEPACK,
:C_GREENPACK,:C_MAGENTAPACK,:C_ORANGEPACK,:C_REDPACK,
:C_YELLOWPACK)





    ItemHandlers::UseFromBag.add(:C_KANTOCOAT,proc{|item|
    Kernel.pbMessage(_INTL("Put on the {1}!",PBItems.getName(item)))
    $Trainer.clothes[1]=$ItemData[item][0]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})

#ItemHandlers::UseFromBag.copy(:C_KANTOSHIRT,:C_JUMPSUIT)


    ItemHandlers::UseFromBag.add(:C_KANTOPANTS,proc{|item|
    Kernel.pbMessage(_INTL("Put on the {1}!",PBItems.getName(item)))
    $Trainer.clothes[4]=$ItemData[item][0]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})

ItemHandlers::UseFromBag.copy(:C_KANTOPANTS,:C_JUMPPANTS,:C_REDPANTS,
:C_BLUEPANTS,:C_GREENPANTS,:C_GRAYPANTS,:C_ALTERNATEPANTS,
:C_LORDSPANTS)


ItemHandlers::UseFromBag.add(:C_PURPLEHAIR,proc{|item|
    Kernel.pbMessage(_INTL("Applied the dye!"))
    $Trainer.clothes[5]=0 if !$game_switches[78]
    $Trainer.clothes[5]=1 if $game_switches[78]
    $game_variables[116]=$Trainer.clothes[5]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})
ItemHandlers::UseFromBag.add(:C_BLUEHAIR,proc{|item|
    Kernel.pbMessage(_INTL("Applied the dye!"))
    $Trainer.clothes[5]=2 if !$game_switches[78]
    $Trainer.clothes[5]=3 if $game_switches[78]
    $game_variables[116]=$Trainer.clothes[5]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})
ItemHandlers::UseFromBag.add(:C_BROWNHAIR,proc{|item|
    Kernel.pbMessage(_INTL("Applied the dye!"))
    $Trainer.clothes[5]=4 if !$game_switches[78]
    $Trainer.clothes[5]=5 if $game_switches[78]
    $game_variables[116]=$Trainer.clothes[5]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})
ItemHandlers::UseFromBag.add(:C_BLACKHAIR,proc{|item|
    Kernel.pbMessage(_INTL("Applied the dye!"))
    $Trainer.clothes[5]=6 if !$game_switches[78]
    $Trainer.clothes[5]=7 if $game_switches[78]
    $game_variables[116]=$Trainer.clothes[5]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})
ItemHandlers::UseFromBag.add(:C_REDHAIR,proc{|item|
    Kernel.pbMessage(_INTL("Applied the dye!"))
    $Trainer.clothes[5]=8 if !$game_switches[78]
    $Trainer.clothes[5]=9 if $game_switches[78]
    $game_switches[35] = true
    $game_variables[116]=$Trainer.clothes[5]
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})
ItemHandlers::UseFromBag.add(:C_BLONDHAIR,proc{|item|
    Kernel.pbMessage(_INTL("Applied the dye!"))
    $Trainer.clothes[5]=10 if !$game_switches[78]
    $Trainer.clothes[5]=11 if $game_switches[78]
    $game_variables[116]=$Trainer.clothes[5]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})

ItemHandlers::UseFromBag.add(:C_GREENHAIR,proc{|item|
    Kernel.pbMessage(_INTL("Applied the dye!"))
    $Trainer.clothes[5]=14 if !$game_switches[78]
    $Trainer.clothes[5]=15 if $game_switches[78]
    $game_variables[116]=$Trainer.clothes[5]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})


ItemHandlers::UseFromBag.add(:C_PINKHAIR,proc{|item|
    Kernel.pbMessage(_INTL("Applied the dye!"))
    $Trainer.clothes[5]=12 if !$game_switches[78]
    $Trainer.clothes[5]=13  if $game_switches[78]
    $game_variables[116]=$Trainer.clothes[5]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})

ItemHandlers::UseFromBag.add(:C_CYANHAIR,proc{|item|
    Kernel.pbMessage(_INTL("Applied the dye!"))
    $Trainer.clothes[5]=16 if !$game_switches[78]
    $Trainer.clothes[5]=17 if $game_switches[78]
    $game_variables[116]=$Trainer.clothes[5]
    $game_switches[35] = true
    $game_player.straighten
    $game_map.update
    $scene.disposeSpritesets
    GC.start
    $scene.createSpritesets
  next 1
})




ItemHandlers::UseFromBag.add(:C_JUMPSHOES,proc{|item|
  Kernel.pbMessage(_INTL("Put on the {1}!",PBItems.getName(item)))
  $Trainer.clothes[5]=$ItemData[item][0]
  $game_switches[35] = true
  $game_variables[116]=$Trainer.clothes[5]
  $game_player.straighten
  $game_map.update
  $scene.disposeSpritesets
  GC.start
  $scene.createSpritesets
  next 1
})

#ItemHandlers::UseFromBag.copy(:C_KANTOHAT,:C_KANTOCOAT,:C_KANTOSHIRT,:C_KANTOPANTS,:C_KANTOSHOES,:C_HEADBAND,
#    :C_MINERSHAT,:C_POLICEHAT,:C_FEDORA,:C_POOPHAT,:C_CLOWNHAT,:C_DRSEUSSHAT,
#    :C_BUGCATCHERHAT,:C_BERET,:C_BEANIE,:C_YOUNGSTERCAP,:C_JUMPSUIT,
#    :C_JUMPSHOES,:C_JUMPPANTS,:C_PURPLEPACK)


#ItemHandlers::UseFromBag.copy(:C_KANTOHAT,:C_KANTOCOAT,:C_KANTOSHIRT,:C_KANTOPANTS,:C_KANTOSHOES,:C_HEADBAND,
 #   :C_MINERSHAT,:C_POLICEHAT,:C_FEDORA,:C_POOPHAT,:C_CLOWNHAT,:C_DRSEUSSHAT,
 #   :C_BUGCATCHERHAT,:C_BERET,:C_BEANIE,:C_YOUNGSTERCAP,:C_JUMPSUIT,
 #   :C_JUMPSHOES,:C_JUMPPANTS,:C_PURPLEPACK)

ItemHandlers::UseFromBag.add(:COINCASE,proc{|item|
   Kernel.pbMessage(_INTL("Coins: {1}",$PokemonGlobal.coins))
   next 1 # Continue
})
ItemHandlers::UseFromBag.add(:EXPSHARE2,proc{|item|
   Kernel.pbMessage(_INTL("EXP Share 2: On!")) if !$game_switches[339]
   Kernel.pbMessage(_INTL("EXP Share 2: Off!")) if $game_switches[339]
   $game_switches[339] = !$game_switches[339]
   next 1 # Continue
})


ItemHandlers::UseFromBag.add(:POKEBLOCKCASE,proc{|item| next 2 })

#===============================================================================
# UseOnPokemon handlers
#===============================================================================

ItemHandlers::UseOnPokemon.add(:FIRESTONE,proc{|item,pokemon,scene|
   if (pokemon.isShadow? rescue false)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
   newspecies=pbCheckEvolution(pokemon,item)
   if newspecies<=0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pbFadeOutInWithMusic(99999){
        evo=PokemonEvolutionScene.new
        evo.pbStartScreen(pokemon,newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
        scene.pbRefresh
     }
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:FIRESTONE,
   :THUNDERSTONE,:WATERSTONE,:LEAFSTONE,:MOONSTONE,
   :SUNSTONE,:DUSKSTONE,:DAWNSTONE,:SHINYSTONE)

ItemHandlers::UseOnPokemon.add(:POTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.add(:SUPERPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,50,scene)
})

ItemHandlers::UseOnPokemon.add(:HYPERPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,200,scene)
})

ItemHandlers::UseOnPokemon.add(:MAXPOTION,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,pokemon.totalhp-pokemon.hp,scene)
})

ItemHandlers::UseOnPokemon.add(:BERRYJUICE,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.add(:SWEETHEART,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,20,scene)
})

ItemHandlers::UseOnPokemon.add(:FRESHWATER,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,50,scene)
})

ItemHandlers::UseOnPokemon.add(:SODAPOP,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,60,scene)
})

ItemHandlers::UseOnPokemon.add(:LEMONADE,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,80,scene)
})

ItemHandlers::UseOnPokemon.add(:MOOMOOMILK,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,100,scene)
})

ItemHandlers::UseOnPokemon.add(:ORANBERRY,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,10,scene)
})

ItemHandlers::UseOnPokemon.add(:SITRUSBERRY,proc{|item,pokemon,scene|
   next pbHPItem(pokemon,(pokemon.totalhp/4).floor,scene)
})

#ItemHandlers::UseOnPokemon.add(:SITRUSBERRY,proc{|item,pokemon,scene|
#   next pbHPItem(pokemon,30,scene)
#})

ItemHandlers::UseOnPokemon.add(:AWAKENING,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::SLEEP
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} woke up.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:AWAKENING,:CHESTOBERRY,:BLUEFLUTE,:POKEFLUTE)

ItemHandlers::UseOnPokemon.add(:ANTIDOTE,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::POISON
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its poisoning.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:ANTIDOTE,:PECHABERRY)

ItemHandlers::UseOnPokemon.add(:BURNHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::BURN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s burn was healed.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:BURNHEAL,:RAWSTBERRY)

ItemHandlers::UseOnPokemon.add(:PARLYZHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::PARALYSIS
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of paralysis.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:PARLYZHEAL,:CHERIBERRY)

ItemHandlers::UseOnPokemon.add(:ICEHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::FROZEN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was thawed out.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

ItemHandlers::UseOnPokemon.add(:FULLHEAL,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::UseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:LUMBERRY)

ItemHandlers::UseOnPokemon.add(:FULLRESTORE,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && pokemon.hp==pokemon.totalhp)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     hpgain=pbItemRestoreHP(pokemon,pokemon.totalhp-pokemon.hp)
     pokemon.status=0
     pokemon.statusCount=0
     scene.pbRefresh
     if hpgain>0
       scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pokemon.name,hpgain.floor))
     else
       scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
       $justUsedStatusCure=true
     end
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:REVIVE,proc{|item,pokemon,scene|
 if $game_switches[71]
        Kernel.pbMessage(_INTL("You are doing a Nuzlocke Challenge!\nYou cannot revive Pokemon!"))
        next 0
      end
  if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=(pokemon.totalhp/2).floor
     pokemon.hp += 1 if isConst?(pokemon.species,PBSpecies,:SHEDINJA)
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} regained health.",pokemon.name))
     $PokemonTemp.dependentEvents.refresh_sprite
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:MAXREVIVE,proc{|item,pokemon,scene|
    if $game_switches[71]
        Kernel.pbMessage(_INTL("You are doing a Nuzlocke Challenge!\nYou cannot revive Pokemon!"))
        next 0
      end
     if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=pokemon.totalhp
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} regained health.",pokemon.name))
     $PokemonTemp.dependentEvents.refresh_sprite
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:ENERGYPOWDER,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,50,scene)
     pokemon.changeHappiness("powder")
     next true
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:ENERGYROOT,proc{|item,pokemon,scene|
   if pbHPItem(pokemon,200,scene)
     pokemon.changeHappiness("Energy Root")
     next true
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:HEALPOWDER,proc{|item,pokemon,scene|
   if pokemon.hp<=0 || pokemon.status==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     pokemon.changeHappiness("powder")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:REVIVALHERB,proc{|item,pokemon,scene|
   if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=pokemon.totalhp
     pokemon.changeHappiness("Revival Herb")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} regained health.",pokemon.name))
     $PokemonTemp.dependentEvents.refresh_sprite
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:ETHER,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbRestorePP(pokemon,move,10)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
      scene.pbDisplay(_INTL("PP was restored."))
      next true
    end
  end
  next false
})

ItemHandlers::UseOnPokemon.copy(:ETHER,:LEPPABERRY)

ItemHandlers::UseOnPokemon.add(:MAXETHER,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbRestorePP(pokemon,move,pokemon.moves[move].totalpp-pokemon.moves[move].pp)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       scene.pbDisplay(_INTL("PP was restored."))
       next true
     end
   end
   next false
})

ItemHandlers::UseOnPokemon.add(:ELIXIR,proc{|item,pokemon,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbRestorePP(pokemon,i,10)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:MAXELIXIR,proc{|item,pokemon,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbRestorePP(pokemon,i,pokemon.moves[i].totalpp-pokemon.moves[i].pp)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:PPUP,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Boost PP of which move?"))
   if move>=0
     if pokemon.moves[move].totalpp==0 || pokemon.moves[move].ppup>=3
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       pokemon.moves[move].ppup+=1
       movename=PBMoves.getName(pokemon.moves[move].id)
       scene.pbDisplay(_INTL("{1}'s PP increased.",movename))
       next true
     end
   end
})
ItemHandlers::UseOnPokemon.add(:FIRESEAL,proc{|item,pokemon,scene|
   pokemon.ballcapsule0= !pokemon.ballcapsule0
   scene.pbDisplay(_INTL("{1}'s Ball was given the Fire Seal.",pokemon.name))
   })
ItemHandlers::UseOnPokemon.add(:HEARTSEAL,proc{|item,pokemon,scene|
   pokemon.ballcapsule1= !pokemon.ballcapsule1
   scene.pbDisplay(_INTL("{1}'s Ball was given the Heart Seal.",pokemon.name))
   })
ItemHandlers::UseOnPokemon.add(:ELESEAL,proc{|item,pokemon,scene|
   pokemon.ballcapsule2= !pokemon.ballcapsule2
   scene.pbDisplay(_INTL("{1}'s Ball was given the Eleseal.",pokemon.name))
   })
ItemHandlers::UseOnPokemon.add(:SMOKESEAL,proc{|item,pokemon,scene|
   pokemon.ballcapsule3= !pokemon.ballcapsule3
   scene.pbDisplay(_INTL("{1}'s Ball was given the Question Seal.",pokemon.name))
   })

ItemHandlers::UseOnPokemon.add(:PPMAX,proc{|item,pokemon,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Boost PP of which move?"))
   if move>=0
     if pokemon.moves[move].totalpp==0 || pokemon.moves[move].ppup>=3
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       pokemon.moves[move].ppup=3
       movename=PBMoves.getName(pokemon.moves[move].id)
       scene.pbDisplay(_INTL("{1}'s PP increased.",movename))
       next true
     end
   end
})

ItemHandlers::UseOnPokemon.add(:HPUP,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,0)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:PROTEIN,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,1)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})


ItemHandlers::UseOnPokemon.add(:IRON,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,2)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CALCIUM,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,4)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:ZINC,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,5)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CARBOS,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,3)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Speed increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})


ItemHandlers::UseOnPokemon.add(:HPPILL,proc{|item,pokemon,scene|
   

   if pokemon.ev[0]<252
          total=0
     for i in 0..5
       total+=pokemon.ev[i]
     end
     if total+252 <= 510

     pokemon.ev[0]=252
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP was maximized.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
   end
})

ItemHandlers::UseOnPokemon.add(:ATKPILL,proc{|item,pokemon,scene|
   if pokemon.ev[1]<252
     total=0
     for i in 0..5
       total+=pokemon.ev[i]
     end
     if total+252 <= 510
     pokemon.ev[1]=252
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s Attack was maximized.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
     end
   end
})


ItemHandlers::UseOnPokemon.add(:DEFPILL,proc{|item,pokemon,scene|
   if pokemon.ev[2]<252
          total=0
     for i in 0..5
       total+=pokemon.ev[i]
     end
     if total+252 <= 510

     pokemon.ev[2]=252
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s Defense was maximized.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
     end
   end
})

ItemHandlers::UseOnPokemon.add(:SPATKPILL,proc{|item,pokemon,scene|
   if pokemon.ev[4]<252
          total=0
     for i in 0..5
       total+=pokemon.ev[i]
     end
     if total+252 <= 510

     pokemon.ev[4]=252
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s Special Attack was maximized.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
   end
})

ItemHandlers::UseOnPokemon.add(:SPDEFPILL,proc{|item,pokemon,scene|

   if pokemon.ev[5]<252
          total=0
     for i in 0..5
       total+=pokemon.ev[i]
     end
     if total+252 <= 510

     pokemon.ev[5]=252
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s Special Defense was maximized.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
   end
})

ItemHandlers::UseOnPokemon.add(:SPEEDPILL,proc{|item,pokemon,scene|
   if pokemon.ev[3]<252
          total=0
     for i in 0..5
       total+=pokemon.ev[i]
     end
     if total+252 <= 510

     pokemon.ev[3]=252
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s Speed was maximized.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
   end
})

  ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE,proc{|item,pokemon,scene|
    # Break
    abils=pokemon.getAbilityList
    if abils[0][2] != nil && abils[0][2] != pokemon.ability && pokemon.species!=PBSpecies::ZYGARDE
      if pokemon.ability==abils[0][0] || 
        (pokemon.species==PBSpecies::BASCULIN && pokemon.form==1 && 
        pokemon.abilityflag==0)
        if Kernel.pbConfirmMessage(_INTL("Would you like to change {1}'s ability to {2}?",pokemon.name,PBAbilities.getName(abils[0][1])))
          pokemon.setAbility(1)
          scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!",pokemon.name,PBAbilities.getName(abils[0][1])))
        else
          next false
        end
      else
        if pokemon.species==PBSpecies::BASCULIN && pokemon.form==1
          if Kernel.pbConfirmMessage(_INTL("Would you like to change {1}'s ability to Rock Head?",pokemon.name))
            pokemon.setAbility(0)
            scene.pbDisplay(_INTL("{1}'s ability was changed to Rock Head!",pokemon.name))
          else
            next false
          end
        else
          if Kernel.pbConfirmMessage(_INTL("Would you like to change {1}'s ability to {2}?",pokemon.name,PBAbilities.getName(abils[0][0])))
            pokemon.setAbility(0)
            scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!",pokemon.name,PBAbilities.getName(abils[0][0])))
          else
            next false
          end
        end
      end
      pokemon.calcStats  
      #if pokemon.species==PBSpecies::DELTAMUK && pokemon.ability==PBAbilities::REGURGITATION
      #          pokemon.form=pokemon.personalID%6 + 1
      #end
      if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
        abilNum=rand(6)
        pokemon.form=abilNum + 1
      elsif pokemon.species==PBSpecies::DELTAMUK && !isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
        pokemon.form=0
      end
      next true
    else
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    
  })


ItemHandlers::UseOnPokemon.add(:HEALTHWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,0,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s HP increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:MUSCLEWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,1,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:RESISTWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,2,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:GENIUSWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,4,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Attack increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:CLEVERWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,5,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Special Defense increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

ItemHandlers::UseOnPokemon.add(:SWIFTWING,proc{|item,pokemon,scene|
   if pbRaiseEffortValues(pokemon,3,1,false)==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("{1}'s Speed increased.",pokemon.name))
     pokemon.changeHappiness("vitamin")
     next true
   end
})

def pbChangeLevel(pokemon,newlevel,scene,shouldrefresh=true)
  oldlevelint=pokemon.level
  newlevel=1 if newlevel<1
  newlevel=PBExperience::MAXLEVEL if newlevel>PBExperience::MAXLEVEL
  if pokemon.level>newlevel
    pokemon.level=newlevel
    attackdiff=pokemon.attack
    defensediff=pokemon.defense
    speeddiff=pokemon.speed
    spatkdiff=pokemon.spatk
    spdefdiff=pokemon.spdef
    totalhpdiff=pokemon.totalhp
    pokemon.calcStats
    scene.pbRefresh if shouldrefresh
    Kernel.pbMessage(_INTL("{1} was downgraded to Level {2}!",pokemon.name,pokemon.level))
    attackdiff=pokemon.attack-attackdiff
    defensediff=pokemon.defense-defensediff
    speeddiff=pokemon.speed-speeddiff
    spatkdiff=pokemon.spatk-spatkdiff
    spdefdiff=pokemon.spdef-spdefdiff
    totalhpdiff=pokemon.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
  elsif pokemon.level==newlevel
    Kernel.pbMessage(_INTL("{1}'s level remained unchanged.",pokemon.name))
  else
    oldlevel=pokemon.level
    pokemon.level=newlevel
    attackdiff=pokemon.attack
    defensediff=pokemon.defense
    speeddiff=pokemon.speed
    spatkdiff=pokemon.spatk
    spdefdiff=pokemon.spdef
    totalhpdiff=pokemon.totalhp
    pokemon.changeHappiness("level up")
    pokemon.calcStats
    scene.pbRefresh if shouldrefresh
    Kernel.pbMessage(_INTL("{1} was elevated to Level {2}!",pokemon.name,pokemon.level))
    attackdiff=pokemon.attack-attackdiff
    defensediff=pokemon.defense-defensediff
    speeddiff=pokemon.speed-speeddiff
    spatkdiff=pokemon.spatk-spatkdiff
    spdefdiff=pokemon.spdef-spdefdiff
    totalhpdiff=pokemon.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
    movelist=pokemon.getMoveList
    for i in movelist
      if i[0]<=pokemon.level && i[0]>oldlevel          # Learned a new move
      #if i[0]==pokemon.level          # Learned a new move
        pbLearnMove(pokemon,i[1],true)
      end
    end
    newspecies=pbCheckEvolution(pokemon)
    if newspecies>0
      pbFadeOutInWithMusic(99999){
         evo=PokemonEvolutionScene.new
         evo.pbStartScreen(pokemon,newspecies)
         evo.pbEvolution
         evo.pbEndScreen
      }
    end
=begin
    cancelledEvo=false
    for i in movelist
      for j in oldlevelint+1..pokemon.level
        if i[0]==j          # Learned a new move
          pbLearnMove(pokemon,i[1],true)
        end
        newspecies=pbCheckEvolution(pokemon)
        if newspecies>0 && !cancelledEvo
          pbFadeOutInWithMusic(99999){
           evo=PokemonEvolutionScene.new
           evo.pbStartScreen(pokemon,newspecies)
           cancelledEvo=!evo.pbEvolution
           evo.pbEndScreen
          }          
        end
      end
    end
=end
    checkForMove=false
    for move in pokemon.moves
      checkForMove=true if move.basedamage>0
    end
    if checkForMove==false && $game_switches[356]
       pbLearnMove(pokemon,PBMoves::POUND,true)
    end
              
    end
  end
#end

ItemHandlers::UseOnPokemon.add(:RARECANDY,proc{|item,pokemon,scene|
   if pokemon.level>=PBExperience::MAXLEVEL || (pokemon.isShadow? rescue false)
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pbChangeLevel(pokemon,pokemon.level+1,scene)
     scene.pbHardRefresh
     next true
   end
})

def pbRaiseHappinessAndLowerEV(pokemon,scene,ev,messages)
  if pokemon.happiness==255 && pokemon.ev[ev]==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  elsif pokemon.happiness==255
    pokemon.ev[ev]-=10
    pokemon.ev[ev]=0 if pokemon.ev[ev]<0
    pokemon.calcStats
    scene.pbRefresh
    scene.pbDisplay(messages[0])
    return true
  elsif pokemon.ev[ev]==0
    pokemon.changeHappiness("EV berry")
    scene.pbRefresh
    scene.pbDisplay(messages[1])
    return true
  else
    pokemon.changeHappiness("EV berry")
    pokemon.ev[ev]-=10
    pokemon.ev[ev]=0 if pokemon.ev[ev]<0
    pokemon.calcStats
    scene.pbRefresh
    scene.pbDisplay(messages[2])
    return true
  end
end

ItemHandlers::UseOnPokemon.add(:POMEGBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,0,[
      _INTL("{1} adores you!\nThe base HP fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base HP can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base HP fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:KELPSYBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,1,[
      _INTL("{1} adores you!\nThe base Attack fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Attack can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Attack fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:QUALOTBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,2,[
      _INTL("{1} adores you!\nThe base Defense fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Defense can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Defense fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:HONDEWBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,4,[
      _INTL("{1} adores you!\nThe base Special Attack fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Special Attack can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Special Attack fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:GREPABERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,5,[
      _INTL("{1} adores you!\nThe base Special Defense fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Special Defense can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Special Defense fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:TAMATOBERRY,proc{|item,pokemon,scene|
   next pbRaiseHappinessAndLowerEV(pokemon,scene,3,[
      _INTL("{1} adores you!\nThe base Speed fell!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Speed can't fall!",pokemon.name),
      _INTL("{1} turned friendly.\nThe base Speed fell!",pokemon.name)
   ])
})

ItemHandlers::UseOnPokemon.add(:GRACIDEA,proc{|item,pokemon,scene|
   if isConst?(pokemon.species,PBSpecies,:SHAYMIN) && pokemon.form==0 &&
      pokemon.hp>=0 && pokemon.status!=PBStatuses::FROZEN &&
      !PBDayNight.isNight?(pbGetTimeNow)
     pokemon.form=1
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
     $PokemonTemp.dependentEvents.refresh_sprite
     next true
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:REVEALGLASS,proc{|item,pokemon,scene|
   if (isConst?(pokemon.species,PBSpecies,:TORNADUS) ||
      isConst?(pokemon.species,PBSpecies,:THUNDURUS) ||
      isConst?(pokemon.species,PBSpecies,:LANDORUS)) && pokemon.hp>=0
     pokemon.form=(pokemon.form==0) ? 1 : 0
     scene.pbRefresh
     $PokemonTemp.dependentEvents.refresh_sprite
     scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
     next true
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS,proc{|item,pokemon,scene|
   if isConst?(pokemon.species,PBSpecies,:KYUREM) && pokemon.hp>=0
     if pokemon.fused!=nil
       if $Trainer.party.length>=6
         scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.",pokemon.name))
         next false
       else
         $Trainer.party[$Trainer.party.length]=pokemon.fused
         pokemon.fused=nil
         pokemon.form=0
         scene.pbHardRefresh
         scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
         for i in 0..3
           move=pokemon.moves[i]
           if isConst?(move.id,PBMoves,:FUSIONFLARE) || 
              isConst?(move.id,PBMoves,:FUSIONBOLT)
             pokemon.moves[i]=PBMove.new(PBMoves::SCARYFACE)
           elsif isConst?(move.id,PBMoves,:ICEBURN) || 
                 isConst?(move.id,PBMoves,:FREEZESHOCK)
             pokemon.moves[i]=PBMove.new(PBMoves::GLACIATE)
           end
         end
         $PokemonTemp.dependentEvents.refresh_sprite
         next true
       end
     else
       chosen=scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
       if chosen>=0
         poke2=$Trainer.party[chosen]
         if (isConst?(poke2.species,PBSpecies,:RESHIRAM) ||
            isConst?(poke2.species,PBSpecies,:ZEKROM)) && poke2.hp>=0
           pokemon.form=1 if isConst?(poke2.species,PBSpecies,:RESHIRAM)
           pokemon.form=2 if isConst?(poke2.species,PBSpecies,:ZEKROM)
           pokemon.fused=poke2
           pbRemovePokemonAt(chosen)
           for i in 0..3
             move=pokemon.moves[i]
             if isConst?(move.id,PBMoves,:SCARYFACE)
               if isConst?(poke2.species,PBSpecies,:RESHIRAM)
                 pokemon.moves[i]=PBMove.new(PBMoves::FUSIONFLARE)
               elsif isConst?(poke2.species,PBSpecies,:ZEKROM)
                 pokemon.moves[i]=PBMove.new(PBMoves::FUSIONBOLT)
               end
             elsif isConst?(move.id,PBMoves,:GLACIATE)
               if isConst?(poke2.species,PBSpecies,:RESHIRAM)
                 pokemon.moves[i]=PBMove.new(PBMoves::ICEBURN)
               elsif isConst?(poke2.species,PBSpecies,:ZEKROM)
                 pokemon.moves[i]=PBMove.new(PBMoves::FREEZESHOCK)
               end
             end
           end
           scene.pbHardRefresh
           scene.pbDisplay(_INTL("{1} changed Forme!",pokemon.name))
           $PokemonTemp.dependentEvents.refresh_sprite
           next true
         elsif pokemon==poke2
           scene.pbDisplay(_INTL("{1} can't be fused with itself!",pokemon.name))
         else
           scene.pbDisplay(_INTL("{1} can't be fused with {2}.",poke2.name,pokemon.name))
         end
       else
         next false
       end
     end
   else
     scene.pbDisplay(_INTL("It had no effect."))
     next false
   end
})


ItemHandlers::UseOnPokemon.add(:LEAFBOOKLET,proc{|item,pokemon,scene|
   if isConst?(pokemon.species,PBSpecies,:DELTASNORLAX) && pokemon.hp>=0
      $game_variables[5]=pokemon.form
      pbLoadRpgxpScene(Scene_Leaf.new)
      if $game_variables[5]==-1
               scene.pbDisplay(_INTL("Nothing happened."))
               next false
             else
                   pokemon.form=$game_variables[5]
                     scene.pbDisplay(_INTL("Touching the booklet caused something to happen."))
     next true

      end
      
      
   end
})

#===============================================================================
# UseInField handlers
#===============================================================================

ItemHandlers::UseInField.add(:TIMECALLER,proc{|item|  pbTesseract  })
ItemHandlers::UseInField.add(:EXPSHARE2,proc{|item|
   Kernel.pbMessage(_INTL("EXP Share 2: On!")) if !$game_switches[339]
   Kernel.pbMessage(_INTL("EXP Share 2: Off!")) if $game_switches[339]
   $game_switches[339] = !$game_switches[339]
   next 1 # Continue
})

ItemHandlers::UseInField.add(:TABLET,proc{|item|
  if Kernel.pbTablet
    next 2
  else
    next 0
  end
  
})

ItemHandlers::UseInField.add(:HONEY,proc{|item|  
   Kernel.pbMessage(_INTL("{1} used the {2}!",$Trainer.name,PBItems.getName(item)))
   pbSweetScent
})

ItemHandlers::UseInField.add(:GOGOGGLES,proc{|item|
  if $game_map.map_id==285 || $game_map.map_id==286 || $game_map.map_id==668 || $game_map.map_id==287 || $game_map.map_id==288 || $game_map.map_id==666
else
Kernel.pbMessage("Put the Go-Goggles on!")
  $game_screen.weather(0,0,0)
end

})
ItemHandlers::UseInField.add(:ROCKETBOOTS,proc{|item|
    if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
              scene=PokemonRegionMapScene.new(-1,false)
              screen=PokemonRegionMap.new(scene)
              ret=screen.pbStartFlyScreen
              if ret
                $PokemonTemp.flydata=ret
              else
                return false
              end

   if !$PokemonTemp.flydata
     Kernel.pbMessage(_INTL("Can't use that here."))
   end
   
     Kernel.pbMessage(_INTL("The Rocket Boots were used!"))
   pbFadeOutIn(99999){
      $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
      $game_temp.player_new_x=$PokemonTemp.flydata[1]
      $game_temp.player_new_y=$PokemonTemp.flydata[2]
           $game_switches[172]=false

      $PokemonTemp.flydata=nil
      $game_temp.player_new_direction=2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
      $game_screen.weather(0,0,0)
weather=pbGetMetadata($game_map.map_id,MetadataWeather)
      $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
   }
   pbEraseEscapePoint
   return true
})

ItemHandlers::UseInField.add(:PIKAPAD,proc{|item|
if $game_map.map_id==287
    Kernel.pbMessage("Some force keeps you from flying here...")
    return false
  end
  noFlyAry=[447,619,451,459,453,452,563,488,558,461,454,560,455,460,749,750,769]
  if !pbGetMetadata($game_map.map_id,MetadataOutdoor) || noFlyAry.include?($game_map.map_id)
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
  end
              scene=PokemonRegionMapScene.new(-1,false)
              screen=PokemonRegionMap.new(scene)
              ret=screen.pbStartFlyScreen
              if ret
                $PokemonTemp.flydata=ret
              else
                return false
              end

   if !$PokemonTemp.flydata || noFlyAry.include?($game_map.map_id)
     Kernel.pbMessage(_INTL("Can't use that here."))
   end
   
     Kernel.pbMessage(_INTL("Dialed the EmolgaTaxi Guy!"))
     pbHiddenMoveAnimation(nil,false,false,true)
     pbFadeOutIn(99999){
      $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
      $game_temp.player_new_x=$PokemonTemp.flydata[1]
      $game_temp.player_new_y=$PokemonTemp.flydata[2]
      $game_switches[172]=false
      $PokemonTemp.flydata=nil
      $game_temp.player_new_direction=2
      $scene.transfer_player
      $game_player.move_down
      $game_map.autoplay
      $game_map.refresh
      $game_screen.weather(0,0,0)
      weather=pbGetMetadata($game_map.map_id,MetadataWeather)
      $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
      $PokemonTemp.dependentEvents.refresh_sprite
   }
   pbEraseEscapePoint
   return true
})

ItemHandlers::UseInField.add(:ESCAPEROPE,proc{|item|
    if $game_switches[134] || $game_map.map_id==827
      Kernel.pbMessage(_INTL("Can't use that here."))
      next
    end
    if $game_map.map_id==502
      Kernel.pbMessage(_INTL("Can't use that in this room."))
      next
    end
   escape=($PokemonGlobal.escapePoint rescue nil)
   if !escape || escape==[]
     Kernel.pbMessage(_INTL("Can't use that here."))
     next
   end
   Kernel.pbMessage(_INTL("{1} used the Escape Rope.",$Trainer.name))
   pbFadeOutIn(99999){
      Kernel.pbCancelVehicles
      $PokemonTemp.dependentEvents.refresh_sprite
      $game_temp.player_new_map_id=escape[0]
      $game_temp.player_new_x=escape[1]
      $game_temp.player_new_y=escape[2]
      $game_temp.player_new_direction=escape[3]
      $scene.transfer_player
      if pbIsWaterTag?(Kernel.pbGetTerrainTag)
        $PokemonGlobal.surfing = true
        Kernel.pbUpdateVehicle
        $scene.transfer_player(false)
      end
      $game_map.autoplay
      $game_map.refresh
   }
   pbEraseEscapePoint
})

ItemHandlers::UseInField.add(:BICYCLE,proc{|item|
   if pbBikeCheck
     if $PokemonGlobal.bicycle
       Kernel.pbDismountBike
     else
       Kernel.pbMountBike 
     end
   end
})

ItemHandlers::UseInField.add(:PRISONBOTTLE,proc{|item|
  test=false
  for poke in $Trainer.party
    if poke.species==PBSpecies::HOOPA
      if poke.form==0
        poke.form=1
        Kernel.pbMessage("The power of Hoopa was unleashed!")
        test=true
      else
        poke.form=0
        Kernel.pbMessage("The power of Hoopa was sealed away.")
        test=true
      end
    end
  end
  Kernel.pbMessage("Nothing happened...") if !test 
  $PokemonTemp.dependentEvents.refresh_sprite   
})

ItemHandlers::UseInField.add(:CLOUDBOTTLE,proc{|item|
  test=false
  for poke in $Trainer.party
    if poke.species==PBSpecies::DELTAHOOPA
      if poke.form==0
        poke.form=1
        Kernel.pbMessage("The power of Delta Hoopa was unleashed!")
        test=true
      else
        poke.form=0
        Kernel.pbMessage("The power of Delta Hoopa was sealed away.")
        test=true
      end
    end
  end
  Kernel.pbMessage("Nothing happened...") if !test
  $PokemonTemp.dependentEvents.refresh_sprite
})

ItemHandlers::UseInField.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

ItemHandlers::UseInField.add(:OLDROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if !pbIsWaterTag?(terrain) || (!notCliff && !$PokemonGlobal.surfing)
     Kernel.pbMessage(_INTL("Can't use that here."))
     next
   end
   encounter=$PokemonEncounters.hasEncounter?(EncounterTypes::OldRod)
   if pbFishing(encounter)
     pbEncounter(EncounterTypes::OldRod)
   end
})

ItemHandlers::UseInField.add(:GOODROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if !pbIsWaterTag?(terrain) || (!notCliff && !$PokemonGlobal.surfing)
     Kernel.pbMessage(_INTL("Can't use that here."))
     next
   end
   encounter=$PokemonEncounters.hasEncounter?(EncounterTypes::GoodRod)
   if pbFishing(encounter) 
     pbEncounter(EncounterTypes::GoodRod)
   end
})

ItemHandlers::UseInField.add(:SUPERROD,proc{|item|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if !pbIsWaterTag?(terrain) || (!notCliff && !$PokemonGlobal.surfing)
     Kernel.pbMessage(_INTL("Can't use that here."))
     next
   end
   encounter=$PokemonEncounters.hasEncounter?(EncounterTypes::SuperRod)
   if pbFishing(encounter)
     pbEncounter(EncounterTypes::SuperRod)
   end
})

ItemHandlers::UseInField.add(:ITEMFINDER,proc{|item|
   event=pbClosestHiddenItem
   if !event
     Kernel.pbMessage(_INTL("... ... ...Nope!\r\nThere's no response."))
   else
     offsetX=event.x-$game_player.x
     offsetY=event.y-$game_player.y
     if offsetX==0 && offsetY==0
       for i in 0...32
         Graphics.update
         Input.update
         $game_player.turn_right_90 if (i&7)==0
         pbUpdateSceneMap
       end
       Kernel.pbMessage(_INTL("Oh!\nThe {1}'s shaking wildly!\1",PBItems.getName(item)))
       Kernel.pbMessage(_INTL("There's an item buried underfoot!"))
     else
       direction=$game_player.direction
       if offsetX.abs>offsetY.abs
         direction=(offsetX<0) ? 4 : 6         
       else
         direction=(offsetY<0) ? 8 : 2
       end
       for i in 0...8
         Graphics.update
         Input.update
         if i==0
           $game_player.turn_down if direction==2
           $game_player.turn_left if direction==4
           $game_player.turn_right if direction==6
           $game_player.turn_up if direction==8
         end
         pbUpdateSceneMap
       end
       Kernel.pbMessage(_INTL("Oh!\nThe {1}'s responding!\1",PBItems.getName(item)))
       Kernel.pbMessage(_INTL("There's an item buried around here!"))
     end
   end
})

ItemHandlers::UseInField.copy(:ITEMFINDER,:DOWSINGMCHN)

ItemHandlers::UseInField.add(:TOWNMAP,proc{|item|
   pbShowMap(-1,false)
})

ItemHandlers::UseInField.add(:COINCASE,proc{|item|
   Kernel.pbMessage(_INTL("Coins: {1}",$PokemonGlobal.coins))
   next 1 # Continue
})

ItemHandlers::UseInField.add(:POKEBLOCKCASE,proc{|item|
   Kernel.pbMessage(_INTL("Can't use that here."))   
})

#===============================================================================
# BattleUseOnPokemon handlers
#===============================================================================

ItemHandlers::BattleUseOnPokemon.add(:POTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SUPERPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,50,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:HYPERPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,200,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MAXPOTION,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,pokemon.totalhp-pokemon.hp,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:BERRYJUICE,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:RAGECANDYBAR,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SWEETHEART,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FRESHWATER,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,50,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SODAPOP,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,60,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:LEMONADE,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,80,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MOOMOOMILK,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,100,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ORANBERRY,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,10,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SITRUSBERRY,proc{|item,pokemon,battler,scene|
   next pbBattleHPItem(pokemon,battler,(pokemon.totalhp/4).floor,scene)
})

#ItemHandlers::BattleUseOnPokemon.add(:SITRUSBERRY,proc{|item,pokemon,battler,scene|
#   next pbBattleHPItem(pokemon,battler,30,scene)
#})

ItemHandlers::BattleUseOnPokemon.add(:AWAKENING,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::SLEEP
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} woke up.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:AWAKENING,:CHESTOBERRY,:BLUEFLUTE,:POKEFLUTE)

ItemHandlers::BattleUseOnPokemon.add(:ANTIDOTE,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::POISON
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of its poisoning.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:ANTIDOTE,:PECHABERRY)

ItemHandlers::BattleUseOnPokemon.add(:BURNHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::BURN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1}'s burn was healed.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:BURNHEAL,:RAWSTBERRY)

ItemHandlers::BattleUseOnPokemon.add(:PARLYZHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::PARALYSIS
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was cured of paralysis.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:PARLYZHEAL,:CHERIBERRY)

ItemHandlers::BattleUseOnPokemon.add(:ICEHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || pokemon.status!=PBStatuses::FROZEN
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     battler.status=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} was thawed out.",pokemon.name))
      $justUsedStatusCure=true
    next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

ItemHandlers::BattleUseOnPokemon.add(:FULLHEAL,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     $justUsedStatusCure=true
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:LUMBERRY)

   
ItemHandlers::BattleUseOnBattler.add(:SPICYCURRY,proc{|item,battler,scene|
    if !battler.effects[PBEffects::FlashFire] && battler.pbCanBurn?(battler,false)
      battler.pbBurn(battler)
      scene.pbDisplay(_INTL("{1} was burned!",battler.pbThis))
      battler.effects[PBEffects::FlashFire]=true if battler
      scene.pbDisplay(_INTL("{1}'s Fire-type moves became stronger!",battler.pbThis))
      #$justUsedStatusCure=true
      return true
    else
      scene.pbDisplay(_INTL("It won't have any effect."))
      return false
    end
})

ItemHandlers::BattleUseOnBattler.add(:XDEFEND,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::DEFENSE)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
     scene.pbDisplay(_INTL("{1}'s Defense rose!",battler.pbThis))
     return true
   end
})

   
ItemHandlers::BattleUseOnPokemon.add(:FULLRESTORE,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && pokemon.hp==pokemon.totalhp &&
      (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     hpgain=pbItemRestoreHP(pokemon,pokemon.totalhp-pokemon.hp)
     battler.hp=pokemon.hp if battler
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     scene.pbRefresh
     if hpgain>0
       scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pokemon.name,hpgain.floor))
     else
       scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     end
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVE,proc{|item,pokemon,battler,scene|
if $game_switches[71]
        Kernel.pbMessage(_INTL("You are doing a Nuzlocke Challenge!\nYou cannot revive Pokemon!"))
        next false
      end
      if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=(pokemon.totalhp/2).floor
     pokemon.hp += 1 if isConst?(pokemon.species,PBSpecies,:SHEDINJA)

     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     scene.pbRefresh

     scene.pbDisplay(_INTL("{1} regained health.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:MAXREVIVE,proc{|item,pokemon,battler,scene|
      if $game_switches[71]
        Kernel.pbMessage(_INTL("You are doing a Nuzlocke Challenge!\nYou cannot revive Pokemon!"))
        next false
      end
   
    if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=pokemon.totalhp
     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} regained health.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYPOWDER,proc{|item,pokemon,battler,scene|
   if pbBattleHPItem(pokemon,battler,50,scene)
     pokemon.changeHappiness("powder")
     next true
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYROOT,proc{|item,pokemon,battler,scene|
   if pbBattleHPItem(pokemon,battler,200,scene)
     pokemon.changeHappiness("Energy Root")
     next true
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:HEALPOWDER,proc{|item,pokemon,battler,scene|
   if pokemon.hp<=0 || (pokemon.status==0 && (!battler || battler.effects[PBEffects::Confusion]==0))
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.statusCount=0
     battler.status=0 if battler
     battler.effects[PBEffects::Confusion]=0 if battler
     pokemon.changeHappiness("powder")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} became healthy.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVALHERB,proc{|item,pokemon,battler,scene|
   if pokemon.hp>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     pokemon.status=0
     pokemon.hp=pokemon.totalhp
     for i in 0...$Trainer.party.length
       if $Trainer.party[i]==pokemon
         battler.pbInitialize(pokemon,i,false) if battler
         break
       end
     end
     pokemon.changeHappiness("Revival Herb")
     scene.pbRefresh
     scene.pbDisplay(_INTL("{1} regained health.",pokemon.name))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:ETHER,proc{|item,pokemon,battler,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbBattleRestorePP(pokemon,battler,move,10)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       scene.pbDisplay(_INTL("PP was restored."))
       next true
     end
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.copy(:ETHER,:LEPPABERRY)

ItemHandlers::BattleUseOnPokemon.add(:MAXETHER,proc{|item,pokemon,battler,scene|
   move=scene.pbChooseMove(pokemon,_INTL("Restore which move?"))
   if move>=0
     if pbBattleRestorePP(pokemon,battler,move,pokemon.moves[move].totalpp-pokemon.moves[move].pp)==0
       scene.pbDisplay(_INTL("It won't have any effect."))
       next false
     else
       scene.pbDisplay(_INTL("PP was restored."))
       next true
     end
   end
   next false
})

ItemHandlers::BattleUseOnPokemon.add(:ELIXIR,proc{|item,pokemon,battler,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbBattleRestorePP(pokemon,battler,i,10)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:MAXELIXIR,proc{|item,pokemon,battler,scene|
   pprestored=0
   for i in 0...pokemon.moves.length
     pprestored+=pbBattleRestorePP(pokemon,battler,i,pokemon.moves[i].totalpp-pokemon.moves[i].pp)
   end
   if pprestored==0
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   else
     scene.pbDisplay(_INTL("PP was restored."))
     next true
   end
})

ItemHandlers::BattleUseOnPokemon.add(:REDFLUTE,proc{|item,pokemon,battler,scene|
   if battler && battler.effects[PBEffects::Attract]>=0
     battler.effects[PBEffects::Attract]=-1
     scene.pbDisplay(_INTL("{1} got over its infatuation.",pokemon.name))
     next true # :consumed:
   else
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
})

ItemHandlers::BattleUseOnPokemon.add(:YELLOWFLUTE,proc{|item,pokemon,battler,scene|
   if battler && battler.effects[PBEffects::Confusion]>0
     battler.effects[PBEffects::Confusion]=0
     scene.pbDisplay(_INTL("{1} snapped out of confusion.",pokemon.name))
     next true # :consumed:
   else
     scene.pbDisplay(_INTL("It won't have any effect."))
     next false
   end
})

ItemHandlers::BattleUseOnPokemon.copy(:YELLOWFLUTE,:PERSIMBERRY)

#===============================================================================
# BattleUseOnBattler handlers
#===============================================================================

ItemHandlers::BattleUseOnBattler.add(:XATTACK,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::ATTACK)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::ATTACK,1)
     scene.pbDisplay(_INTL("{1}'s Attack rose!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK2,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::ATTACK)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::ATTACK,2)
     scene.pbDisplay(_INTL("{1}'s Attack rose sharply!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK3,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::ATTACK)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::ATTACK,3)
     scene.pbDisplay(_INTL("{1}'s Attack rose drastically!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK6,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::ATTACK)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::ATTACK,6)
     scene.pbDisplay(_INTL("{1}'s Attack went way up!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XDEFEND,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::DEFENSE)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::DEFENSE,1)
     scene.pbDisplay(_INTL("{1}'s Defense rose!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XDEFEND2,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::DEFENSE)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::DEFENSE,2)
     scene.pbDisplay(_INTL("{1}'s Defense rose sharply!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XDEFEND3,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::DEFENSE)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::DEFENSE,3)
     scene.pbDisplay(_INTL("{1}'s Defense rose drastically!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XDEFEND6,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::DEFENSE)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::DEFENSE,6)
     scene.pbDisplay(_INTL("{1}'s Defense went way up!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPECIAL,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPATK)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPATK,1)
     scene.pbDisplay(_INTL("{1}'s Special Attack rose!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPECIAL2,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPATK)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPATK,2)
     scene.pbDisplay(_INTL("{1}'s Special Attack rose sharply!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPECIAL3,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPATK)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPATK,3)
     scene.pbDisplay(_INTL("{1}'s Special Attack rose drastically!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPECIAL6,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPATK)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPATK,6)
     scene.pbDisplay(_INTL("{1}'s Special Attack went way up!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPDEF)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPDEF,1)
     scene.pbDisplay(_INTL("{1}'s Special Defense rose!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF2,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPDEF)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPDEF,2)
     scene.pbDisplay(_INTL("{1}'s Special Defense rose sharply!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF3,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPDEF)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPDEF,3)
     scene.pbDisplay(_INTL("{1}'s Special Defense rose drastically!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF6,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPDEF)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPDEF,6)
     scene.pbDisplay(_INTL("{1}'s Special Defense went way up!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPEED)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPEED,1)
     scene.pbDisplay(_INTL("{1}'s Speed rose!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED2,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPEED)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPEED,2)
     scene.pbDisplay(_INTL("{1}'s Speed rose sharply!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED3,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPEED)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPEED,3)
     scene.pbDisplay(_INTL("{1}'s Speed rose drastically!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED6,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::SPEED)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::SPEED,6)
     scene.pbDisplay(_INTL("{1}'s Speed went way up!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::ACCURACY)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::ACCURACY,1)
     scene.pbDisplay(_INTL("{1}'s accuracy rose!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY2,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::ACCURACY)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::ACCURACY,2)
     scene.pbDisplay(_INTL("{1}'s accuracy rose sharply!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY3,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::ACCURACY)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::ACCURACY,3)
     scene.pbDisplay(_INTL("{1}'s accuracy rose drastically!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY6,proc{|item,battler,scene|
   if battler.pbTooHigh?(PBStats::ACCURACY)
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false  
   else
     battler.pbIncreaseStatBasic(PBStats::ACCURACY,6)
     scene.pbDisplay(_INTL("{1}'s accuracy went way up!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT,proc{|item,battler,scene|
   if battler.effects[PBEffects::FocusEnergy]>=1
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false
   else
     battler.effects[PBEffects::FocusEnergy]=1
     scene.pbDisplay(_INTL("{1} is getting pumped!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT2,proc{|item,battler,scene|
   if battler.effects[PBEffects::FocusEnergy]>=2
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false
   else
     battler.effects[PBEffects::FocusEnergy]=2
     scene.pbDisplay(_INTL("{1} is getting pumped!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT3,proc{|item,battler,scene|
   if battler.effects[PBEffects::FocusEnergy]>=3
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false
   else
     battler.effects[PBEffects::FocusEnergy]=3
     scene.pbDisplay(_INTL("{1} is getting pumped!",battler.pbThis))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.add(:GUARDSPEC,proc{|item,battler,scene|
   if battler.pbOwnSide.effects[PBEffects::Mist]>0
     scene.pbDisplay(_INTL("It won't have any effect."))
     return false
   else
     battler.pbOwnSide.effects[PBEffects::Mist]=5
     scene.pbDisplay(_INTL("Ally became shrouded in Mist!"))
     return true
   end
})



ItemHandlers::BattleUseOnBattler.add(:ITEMDROP,proc{|item,battler,scene|
   if !@battle.pbIsUnlosableItem(opponent,opponent.item(true))
       opponent=battler.pbOpposing1     
        itemname=PBItems.getName(opponent.item(true))
        opponent.item=0
        opponent.effects[PBEffects::ChoiceBand]=-1
        @battle.pbDisplay(_INTL("{1} knocked off {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
      else
        @battle.pbDisplay(_INTL("But it failed!"))
        
      end
      
})
=begin
ItemHandlers::BattleUseOnBattler.add(:ITEMDROP,proc{|item,battler,scene|
   if !@battle.pbIsUnlosableItem(opponent,opponent.item(true))
       partner=battler.pbPartner     
        itemname=PBItems.getName(opponent.item(true))
        opponent.item=0
        opponent.effects[PBEffects::ChoiceBand]=-1
        @battle.pbDisplay(_INTL("{1} knocked off {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
      else
        @battle.pbDisplay(_INTL("But it failed!"))
        
      end
      
})
=end

=begin

elsif !@battle.pbIsUnlosableItem(opponent,opponent.item(true))
        itemname=PBItems.getName(opponent.item(true))
        opponent.item=0
        opponent.effects[PBEffects::ChoiceBand]=-1
        @battle.pbDisplay(_INTL("{1} knocked off {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
      end
=end





ItemHandlers::BattleUseOnBattler.add(:RBDOOMDESIRE,proc{|item,battler,scene|
  
  if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  
  battle=battler.battle
  if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end
  $idbox = "Doom Desire"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:RBVCREATE,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "V-Create"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:RBSEEDFLARE,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Seed Flare"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:RBMISTBALL,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Mist Ball"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:RBLUSTERBALL,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Luster Purge"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:RBROAROFTIME,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Roar of Time"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:RBSPACIALREND,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Spacial Rend"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:RBSACREDSWORD,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Sacred Sword"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:RBDARKVOID,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Dark Void"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:ABPROTECT,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Protect"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:ABSLEEPPOWDER,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Sleep Powder"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:ABTHUNDERWAVE,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Thunder Wave"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:ABTOXIC,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Toxic"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:ABCONFUSERAY,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Confuse Ray"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:ABMEDUSARAY,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "Medusa Ray"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:ABFALSESWIPE,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
  battle=battler.battle
    if battle.doublebattle
    scene.pbDisplay(_INTL("You cannot use a Box in a double battle!"))
      return false
  end

  $idbox = "False Swipe"
  #battle.pbAttackBox(battler.index)
      return true
})
ItemHandlers::BattleUseOnBattler.add(:POKEDOLL,proc{|item,battler,scene|
if $idboxused
    scene.pbDisplay(_INTL("You've already used a Box this battle!"))
      return false
  end
   battle=battler.battle
   if battle.opponent
     scene.pbDisplay(_INTL("Can't use that here."))
     return false
   else
     playername=battle.pbPlayer.name
     itemname=PBItems.getName(item)
     scene.pbDisplay(_INTL("{1} used the {2}.",playername,itemname))
     return true
   end
})

ItemHandlers::BattleUseOnBattler.copy(:POKEDOLL,:FLUFFYTAIL,:POKETOY)

ItemHandlers::BattleUseOnBattler.addIf(proc{|item|
                pbIsPokeBall?(item)},proc{|item,battler,scene|  # Any Poké Ball
    $throwingBalls=true
   battle=battler.battle
   if battler.pbOpposing1.hp>0 && battler.pbOpposing2.hp>0
     if !pbIsSnagBall?(item)
       scene.pbDisplay(_INTL("It's no good!  It's impossible to aim when there are two Pokémon!"))
       return false
     end
   end
   if battle.pbPlayer.party.length>=6 && $PokemonStorage.full?
     scene.pbDisplay(_INTL("There is no room left in the PC!"))
     return false
   end
   return true
})

#===============================================================================
# UseInBattle handlers
#===============================================================================

ItemHandlers::UseInBattle.add(:POKEDOLL,proc{|item,battler,battle|
   battle.decision=3
   battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseInBattle.copy(:POKEDOLL,:FLUFFYTAIL,:POKETOY)

ItemHandlers::UseInBattle.addIf(proc{|item|
               pbIsPokeBall?(item)},proc{|item,battler,battle|  # Any Poké Ball 
   battle.pbThrowPokeBall(battler.index,item)
})
#ItemHandlers::UseInBattle.add(:RBDOOMDESIRE,proc{|item,battler,battle|
#battle.pbAttackBox(battler.index)
#
#      return true
#})

