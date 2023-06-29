def loadSecretBaseEvents(playervar)
 #raise playervar.length.to_s
    playervar = Array.new if !playervar.is_a?(Array)
    for i in 1..100
      if playervar[i].is_a?(Array) && (playervar[i][0] || (!$game_switches[47] && playervar[i][2] && playervar[i][3] && playervar[i][3]>0))
        if Kernel.getFileNameForUpgrade(playervar[i][2])!="Dick"
          if !$game_switches[47]
            $game_map.events[i].character_name=Kernel.getFileNameForUpgrade(playervar[i][2])
          else
           $game_map.events[i].character_name=playervar[i][2].to_s
          end
          $game_map.events[i].moveto(playervar[i][3],playervar[i][4])
          if playervar[i][5]==nil
            $game_map.events[i].direction=2
            playervar[i][5]=2
          else
            $game_map.events[i].direction=playervar[i][5]
          end
          if $game_switches[47]  
            $game_map.events[i].trigger=1 if Kernel.isWalkOnSB.include?(playervar[i][1])
            $game_map.events[i].through=true if Kernel.isWalkOnSB.include?(playervar[i][1])
          else
            $game_map.events[i].trigger=1 if Kernel.isWalkOnSB.include?(playervar[i][2])
            $game_map.events[i].through=true if Kernel.isWalkOnSB.include?(playervar[i][2])      
          end
        end
      elsif !playervar[i].is_a?(Array)
        playervar[i]=Array.new
      end
    end
  end

def isWalkOnSB
  ret=[Kernel.gnfu("Movement Tile (Up)"),Kernel.gnfu("Movement Tile (Down)"),
  Kernel.gnfu("Movement Tile (Left)"),Kernel.gnfu("Movement Tile (Right)"),
  Kernel.gnfu("Teleporter (1)"),Kernel.gnfu("Teleporter (2)"),
  Kernel.gnfu("Teleporter (3)"),Kernel.gnfu("Teleporter (4)"),Kernel.gnfu("Teleporter (5)")]
  return ret
end

  
def getFileNameForUpgrade(id)
  id=Kernel.getNumberForUpgrade(id) if id.is_a?(String)
  case id
    when Kernel.getNumberForUpgrade("Movement Tile (Up)")
     return "up_arrow"
    when Kernel.getNumberForUpgrade("Movement Tile (Down)")
     return "down_arrow"
    when Kernel.getNumberForUpgrade("Movement Tile (Left)")
     return "left_arrow"
    when Kernel.getNumberForUpgrade("Movement Tile (Right)")
     return "right_arrow"
    when Kernel.getNumberForUpgrade("Teleport Tile")
    return "tempblank"
    when Kernel.getNumberForUpgrade("Teleporter (1)")
     return "teleporter"
    when Kernel.getNumberForUpgrade("Teleporter (2)")
     return "teleporter"
    when Kernel.getNumberForUpgrade("Teleporter (3)")
     return "teleporter"
     when Kernel.getNumberForUpgrade("Teleporter (4)")
     return "teleporter"
     when Kernel.getNumberForUpgrade("Teleporter (5)")
     return "teleporter"
    when Kernel.getNumberForUpgrade("Darkrai Statue")
      return "sb_darkraistatue"
    when Kernel.getNumberForUpgrade("Cresselia Statue")
      return "sb_cresseliastatue"
    when Kernel.getNumberForUpgrade("Keldeo Plush")
      return "647"
    when Kernel.getNumberForUpgrade("Virizion Plush")
      return "640"
    when Kernel.getNumberForUpgrade("Terrakion Plush")
      return "639"
    when Kernel.getNumberForUpgrade("Cobalion Plush")
      return "638"
    when Kernel.getNumberForUpgrade("Venusaur Plush")
      return "003"
    when Kernel.getNumberForUpgrade("Blastoise Plush")
      return "009"
    when Kernel.getNumberForUpgrade("Charizard Plush")
      return "006"
    when Kernel.getNumberForUpgrade("Tyranitar Plush")
      return "248"
    when Kernel.getNumberForUpgrade("Pikachu Plush")
      return "025"
    when Kernel.getNumberForUpgrade("Ninetales Plush")
      return "038"
    when Kernel.getNumberForUpgrade("Jigglypuff Plush")
      return "039"
    when Kernel.getNumberForUpgrade("Arcanine Plush")
      return "059"
    when Kernel.getNumberForUpgrade("Machamp Plush")
      return "068"
    when Kernel.getNumberForUpgrade("Gengar Plush")
      return "094"
    when Kernel.getNumberForUpgrade("Electrode Plush")
      return "101"
    when Kernel.getNumberForUpgrade("Scyther Plush")
      return "123"
    when Kernel.getNumberForUpgrade("Electabuzz Plush")
      return "125"
    when Kernel.getNumberForUpgrade("Magmar Plush")
      return "126"
    when Kernel.getNumberForUpgrade("Jynx Plush")
      return "124"
    when Kernel.getNumberForUpgrade("Lapras Plush")
      return "131"
    when Kernel.getNumberForUpgrade("Snorlax Plush")
      return "143"
    when Kernel.getNumberForUpgrade("Dragonite Plush")
      return "149"
    when Kernel.getNumberForUpgrade("Mewtwo Plush")
      return "150"
    when Kernel.getNumberForUpgrade("Meganium Plush")
      return "154"
    when Kernel.getNumberForUpgrade("Typhlosion Plush")
      return "157"
    when Kernel.getNumberForUpgrade("Feraligatr Plush")
      return "160"
    when Kernel.getNumberForUpgrade("Xatu Plush")
      return "178"
    when Kernel.getNumberForUpgrade("Ampharos Plush")
      return "181"
    when Kernel.getNumberForUpgrade("Wobbuffet Plush")
      return "202"
    when Kernel.getNumberForUpgrade("Scizor Plush")
      return "212"
    when Kernel.getNumberForUpgrade("Delibird Plush")
      return "225"
    when Kernel.getNumberForUpgrade("Sceptile Plush")
      return "254"
    when Kernel.getNumberForUpgrade("Blaziken Plush")
      return "257"
    when Kernel.getNumberForUpgrade("Swampert Plush")
      return "260"
    when Kernel.getNumberForUpgrade("Ludicolo Plush")
      return "272"
    when Kernel.getNumberForUpgrade("Shiftry Plush")
      return "275"
    when Kernel.getNumberForUpgrade("Pelipper Plush")
      return "279"
    when Kernel.getNumberForUpgrade("Aggron Plush")
      return "306"
    when Kernel.getNumberForUpgrade("Flygon Plush")
      return "330"
    when Kernel.getNumberForUpgrade("Zangoose Plush")
      return "335"
    when Kernel.getNumberForUpgrade("Seviper Plush")
      return "336"
    when Kernel.getNumberForUpgrade("Milotic Plush")
      return "350"
    when Kernel.getNumberForUpgrade("Tropius Plush")
      return "357"
    when Kernel.getNumberForUpgrade("Absol Plush")
      return "359"
    when Kernel.getNumberForUpgrade("Walrein Plush")
      return "365"
    when Kernel.getNumberForUpgrade("Salamence Plush")
      return "373"
    when Kernel.getNumberForUpgrade("Metagross Plush")
      return "376"
    when Kernel.getNumberForUpgrade("Torterra Plush")
      return "389"
    when Kernel.getNumberForUpgrade("Infernape Plush")
      return "392"
    when Kernel.getNumberForUpgrade("Empoleon Plush")
      return "395"
    when Kernel.getNumberForUpgrade("Luxray Plush")
      return "405"
    when Kernel.getNumberForUpgrade("Garchomp Plush")
      return "445"
    when Kernel.getNumberForUpgrade("Spiritomb Plush")
      return "442"
    when Kernel.getNumberForUpgrade("Lucario Plush")
      return "448"
    when Kernel.getNumberForUpgrade("Serperior Plush")
      return "497"
    when Kernel.getNumberForUpgrade("Emboar Plush")
      return "500"
    when Kernel.getNumberForUpgrade("Samurott Plush")
      return "503"
    when Kernel.getNumberForUpgrade("Zoroark Plush")
      return "571"
    when Kernel.getNumberForUpgrade("Reuniclus Plush")
      return "579"
    when Kernel.getNumberForUpgrade("Chandelure Plush")
      return "609"
    when Kernel.getNumberForUpgrade("Hydreigon Plush")
      return "635"    
      
    when Kernel.getNumberForUpgrade("Mart Worker")
      return "NPC 14"
    when Kernel.getNumberForUpgrade("Fossil Maniac")
      return "trchar018"
    when Kernel.getNumberForUpgrade("Level Trainer")
      return "trchar036"
    when Kernel.getNumberForUpgrade("EV Trainer")
      return "trchar039"
    when Kernel.getNumberForUpgrade("Pokegear Designer")
      return "trchar030"
    when Kernel.getNumberForUpgrade("Name Rater")
      return "NPC 10"
     when Kernel.getNumberForUpgrade("IV Changer")
      return "trchar060"
    when Kernel.getNumberForUpgrade("EV Resetter")
      return "trchar031"
    when Kernel.getNumberForUpgrade("Move Relearner")
      return "trchar073"
    when Kernel.getNumberForUpgrade("Move Deleter")
      return "trchar017"
    when Kernel.getNumberForUpgrade("Day-Care Agent")
      return "NPC 11"
    when Kernel.getNumberForUpgrade("Nurse")
      return "trchar056"
    when Kernel.getNumberForUpgrade("Flag Guy")
      return "NPC 03"
    when Kernel.getNumberForUpgrade("Pikataxi")
      return "NPC 16"
    when Kernel.getNumberForUpgrade("Nuzlocke Trophy")
      return "object_gold_coat"
    end
  end
 def gnfu(string)
   return Kernel.getNumberForUpgrade(string)
 end

def mc(string,color)
    if color=="blue"
      return "<c2=65467b14>"+string+"</c2>"
    end
    if color=="red"
      return "<c2=043c3aff>"+string+"</c2>"
    end
  end

def faceP(eventid)
  case $game_player.direction
    when 2
              $game_map.events[eventid].direction = 8
    when 4
              $game_map.events[eventid].direction = 6
    when 6
              $game_map.events[eventid].direction = 4
    when 8
              $game_map.events[eventid].direction = 2
            end
      $game_map.need_refresh
end

 
def runSBEvent(playervar,eventid)
    b="blue"
    r="red"
    event=playervar[eventid]
    if !$game_switches[47]
      event[1]=event[2]
    end
    
    if $sb_is_deleting
          $sb_is_deleting=false

    if Kernel.pbConfirmMessage("Are you sure you wish to delete this item?")
    event[0]=nil
    event[1]=nil
    event[2]=nil
    event[3]=nil
    event[4]=nil
    event[5]=nil
    $game_map.events[eventid].opacity=0
    $game_map.events[eventid].transparent=true
    $game_map.events[eventid].character_name=""
    $game_map.need_refresh
    return
  end
end
    if event[1]==Kernel.gnfu("Teleporter (2)")
      j = 0
      for i in 1..100
   #     Kernel.pbMessage(playervar[i][1].to_s) if playervar[i][1]!=nil
        if !$game_switches[47]
            playervar[i][1]=playervar[i][2]
        end
        if playervar[i].is_a?(Array) && playervar[i][1]==Kernel.gnfu("Teleporter (2)") && playervar[i]!=event #(playervar[i][3] != event[3] || playervar[i][4] != event[4])
    #      Kernel.pbMessage("feanfioenfse")
          j = i
          break
        end
      end
      if j != 0 && !$hold_it_faggot
        $game_temp.player_new_map_id=$game_map.map_id
        $game_temp.player_new_x=$game_map.events[j].x
        $game_temp.player_new_y=$game_map.events[j].y
        $game_temp.player_new_direction=$game_player.direction
         $scene.transfer_player(false)
        $hold_it_faggot=true
        $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)  
      elsif j == 0
        Kernel.pbMessage("This is the only Teleporter set to this connection.")        
      end
    end
    if event[1]==Kernel.gnfu("Teleporter (1)")
      j = 0
      for i in 1..100
        if !$game_switches[47]
            playervar[i][1]=playervar[i][2]
        end
        if playervar[i].is_a?(Array) && playervar[i][1]==Kernel.gnfu("Teleporter (1)") && playervar[i]!=event #(playervar[i][3] != event[3] || playervar[i][4] != event[4])
          j = i
          break
        end
      end
      if j != 0 && !$hold_it_faggot
        $game_temp.player_new_map_id=$game_map.map_id
        $game_temp.player_new_x=$game_map.events[j].x
        $game_temp.player_new_y=$game_map.events[j].y
        $game_temp.player_new_direction=$game_player.direction
         $scene.transfer_player(false)
        $hold_it_faggot=true
        $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)  
      elsif j == 0
        Kernel.pbMessage("This is the only Teleporter set to this connection.")        
      end
    end
    if event[1]==Kernel.gnfu("Teleporter (3)")
      j = 0
      for i in 1..100
        if !$game_switches[47]
            playervar[i][1]=playervar[i][2]
        end
        if playervar[i].is_a?(Array) && playervar[i][1]==Kernel.gnfu("Teleporter (3)") && playervar[i]!=event #(playervar[i][3] != event[3] || playervar[i][4] != event[4])
          j = i
          break
        end
      end
      if j != 0 && !$hold_it_faggot
        $game_temp.player_new_map_id=$game_map.map_id
        $game_temp.player_new_x=$game_map.events[j].x
        $game_temp.player_new_y=$game_map.events[j].y
        $game_temp.player_new_direction=$game_player.direction
         $scene.transfer_player(false)
        $hold_it_faggot=true
        $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)  
      elsif j == 0
        Kernel.pbMessage("This is the only Teleporter set to this connection.")        
      end
    end
    if event[1]==Kernel.gnfu("Teleporter (4)")
      j = 0
      for i in 1..100
        if !$game_switches[47]
            playervar[i][1]=playervar[i][2]
        end
        if playervar[i].is_a?(Array) && playervar[i][1]==Kernel.gnfu("Teleporter (4)") && playervar[i]!=event #(playervar[i][3] != event[3] || playervar[i][4] != event[4])
          j = i
          break
        end
      end
      if j != 0 && !$hold_it_faggot
        $game_temp.player_new_map_id=$game_map.map_id
        $game_temp.player_new_x=$game_map.events[j].x
        $game_temp.player_new_y=$game_map.events[j].y
        $game_temp.player_new_direction=$game_player.direction
         $scene.transfer_player(false)
        $hold_it_faggot=true
        $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)  
      elsif j == 0
        Kernel.pbMessage("This is the only Teleporter set to this connection.")        
      end
    end
    if event[1]==Kernel.gnfu("Teleporter (5)")
      j = 0
      for i in 1..100
        if !$game_switches[47]
            playervar[i][1]=playervar[i][2]
        end
        if playervar[i].is_a?(Array) && playervar[i][1]==Kernel.gnfu("Teleporter (5)") && playervar[i]!=event #(playervar[i][3] != event[3] || playervar[i][4] != event[4])
          j = i
          break
        end
      end
      if j != 0 && !$hold_it_faggot
        $game_temp.player_new_map_id=$game_map.map_id
        $game_temp.player_new_x=$game_map.events[j].x
        $game_temp.player_new_y=$game_map.events[j].y
        $game_temp.player_new_direction=$game_player.direction
         $scene.transfer_player(false)
        $hold_it_faggot=true
        $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)  
      elsif j == 0
        Kernel.pbMessage("This is the only Teleporter set to this connection.")        
      end
    end
=begin
    if event[1]==Kernel.getNumberForUpgrade("Teleport Tile")
      if event[10]==nil || event[10]==0
        ary=[]
        var1=0
            var2=0
            var3=0
            var4=0
            var5=0
        for i in 1..100
            if playervar[i][10]==1
              var1 += 1
            end
            if playervar[i][10]==2
              var2 += 1
            end
            if playervar[i][10]==3
              var3 += 1
            end
            if playervar[i][10]==4
              var4 += 1
            end
            
            if playervar[i][10]==5
              var5 += 1
            end
        end
        ary.push("1") if var1<2
        ary.push("2") if var2<2
        ary.push("3") if var3<2
        ary.push("4") if var4<2
        ary.push("5") if var5<2
        if ary.length==0
          Kernel.pbMessage("You've reached your limits of five teleporter connections.")
          return false
        end
        ary.push("(Exit)")
        var=Kernel.pbMessage("Which connection should this tile use?",ary)
        if !ary[var].include?("Exit")
          if ary[var].include?("1")
            Kernel.pbMessage("This Teleport Tile was set to the 1st connection.")
            event[10]=1
            elsif ary[var].include?("2")
            Kernel.pbMessage("This Teleport Tile was set to the 2nd connection.")
            event[10]=2
            elsif ary[var].include?("3")
            Kernel.pbMessage("This Teleport Tile was set to the 3rd connection.")
            event[10]=3
            elsif ary[var].include?("4")
            Kernel.pbMessage("This Teleport Tile was set to the 4th connection.")
            event[10]=4
            elsif ary[var].include?("5")
          Kernel.pbMessage("This Teleport Tile was set to the 5th connection.")
            event[10]=5
          end
        end
        
      elsif !$hold_it_faggot
        whatEventInt=0
        for i in 1..100
          if playervar[i][10] != nil && playervar[i][10] != 0
            if playervar[i][10]==event[10] && i != eventid
            whatEventInt=i
            break
            end
          end
        end
         if whatEventInt==0
           case event[10]
           when 1
           Kernel.pbMessage("This Teleport tile is set to the 1st connection.")
           when 2
           Kernel.pbMessage("This Teleport tile is set to the 2nd connection.")
           when 3
           Kernel.pbMessage("This Teleport tile is set to the 3rd connection.")
           when 4
           Kernel.pbMessage("This Teleport tile is set to the 4th connection.")
           when 5
           Kernel.pbMessage("This Teleport tile is set to the 5th connection.")
           end
           else
           $game_temp.player_new_map_id=$game_map.map_id
           $game_temp.player_new_x=$game_map.events[i].x
           $game_temp.player_new_y=$game_map.events[i].y
           $game_temp.player_new_direction=$game_player.direction
           $scene.transfer_player(false)
           $hold_it_faggot=true

        
                     $scene.spriteset.addUserAnimation(Animation_Come_Out, $game_player.x, $game_player.y)

        end
        end
    end
=end
    if event[1]==Kernel.getNumberForUpgrade("Movement Tile (Up)")
      $PokemonTemp.dependentEvents.remove_sprite(true)
      $game_switches[51]=true
      $game_switches[93]=true
      $game_player.direction=8
      $game_player.walk_anime=false
      $game_player.move_speed=6
      $go_up_constant=true
    end
    if event[1]==Kernel.getNumberForUpgrade("Movement Tile (Down)")
      $PokemonTemp.dependentEvents.remove_sprite(true)
      $game_switches[51]=true
      $game_switches[93]=true
      $game_player.direction=2
      $game_player.move_speed=6
      $game_player.walk_anime=false
      $go_up_constant=true
    end
    if event[1]==Kernel.getNumberForUpgrade("Movement Tile (Left)")
      $PokemonTemp.dependentEvents.remove_sprite(true)
      $game_switches[51]=true
      $game_switches[93]=true
      $game_player.direction=4
      $game_player.move_speed=6
      $game_player.walk_anime=false
      $go_up_constant=true
    end
    if event[1]==Kernel.getNumberForUpgrade("Movement Tile (Right)")
      $PokemonTemp.dependentEvents.remove_sprite(true)
      $game_switches[51]=true
      $game_switches[93]=true
      $game_player.direction=6
      $game_player.move_speed=6
      $game_player.walk_anime=false
      $go_up_constant=true
    end
    if event[1]==Kernel.gnfu("Mart Worker")
      Kernel.faceP(eventid)
      Kernel.pbPokeMartWorker
    end
    if event[1]==Kernel.gnfu("Fossil Maniac")
      Kernel.faceP(eventid)
      Kernel.pbMessage(mc("Why, hello there!",b))
      Kernel.pbMessage(mc("I'm the Fossil Maniac!",b))
      Kernel.pbMessage(mc("Guess what? I'll be pleased as punch to revive your fossils!",b))
      if Kernel.pbConfirmMessage(mc("What do you say? Do you want me to revive a fossil?",b))
        var=pbChooseItemFromList(mc("Choose a fossil.",b),1,:DOMEFOSSIL,:HELIXFOSSIL,:OLDAMBER,
        :ROOTFOSSIL,:CLAWFOSSIL,:ARMORFOSSIL,:SKULLFOSSIL,:COVERFOSSIL,:PLUMEFOSSIL,
        :JAWFOSSIL,:SAILFOSSIL)
        if var==0
          Kernel.pbMessage(mc("Well, you don't have any fossils! You'd better go get some!",b))
        elsif var==-1
          Kernel.pbMessage(mc("Get me a fossil to revive, and I'll do it for you.",b))
        else
          poke=0
          poke=PBSpecies::KABUTO if var==PBItems::DOMEFOSSIL
          poke=PBSpecies::OMANYTE if var==PBItems::HELIXFOSSIL
          poke=PBSpecies::AERODACTYL if var==PBItems::OLDAMBER
          poke=PBSpecies::LILEEP if var==PBItems::ROOTFOSSIL
          poke=PBSpecies::ANORITH if var==PBItems::CLAWFOSSIL
          poke=PBSpecies::SHIELDON if var==PBItems::ARMORFOSSIL
          poke=PBSpecies::CRANIDOS if var==PBItems::SKULLFOSSIL
          poke=PBSpecies::TIRTOUGA if var==PBItems::COVERFOSSIL
          poke=PBSpecies::ARCHEN if var==PBItems::PLUMEFOSSIL
          poke=PBSpecies::TYRUNT if var==PBItems::JAWFOSSIL
          poke=PBSpecies::AMAURA if var==PBItems::SAILFOSSIL
          $PokemonBag.pbDeleteItem(var)
          pbAddPokemon(poke,5)
        end
      else
        
      end
      Kernel.pbMessage(mc("Stop by again!",b))
    end
    

    if event[1]==Kernel.gnfu("Level Trainer")
      Kernel.faceP(eventid)
           Kernel.pbMessage(mc("So, you want to get tougher, huh?",b))
     Kernel.pbMessage(mc("I can help you with that.",b))
     Kernel.pbMessage(mc("I'm the Level Trainer, and I'll use multiple Audino of a level of your choice.",b))
       Kernel.pbMessage(mc("It costs $180 for every 10 levels.",b))
     
    tempary=["Cancel","10","20"]
    tempary.push("30") if $game_switches[5]
    tempary.push("40") if $game_switches[5]
    tempary.push("50") if $game_switches[6]
    tempary.push("60") if $game_switches[7]
    tempary.push("70") if $game_switches[8] 
    tempary.push("80") if $game_switches[9]
    tempary.push("90") if $game_switches[10]
    tempary.push("100") if $game_switches[11]
   # tempary.push("100") if $game_switches[1]
      var=Kernel.pbMessage(mc("You have $"+$Trainer.money.to_s+". What level should I use?",b),tempary)    
     if var==0
       Kernel.pbMessage(mc("Very well! Come another time, then.",b))
        return false
      end
      if $Trainer.money>=var*180 #|| $game_switches[47]
        $PokemonGlobal.nextBattleBack="City"
        $Trainer.money -= var*180 #if  !$game_switches[47]
        temp=false
        if $game_switches[321]
          $game_switches[321]=false
          $game_switches[671]=true
          temp=true
        end
        $game_switches[641]=true
        pbTrainerBattle(PBTrainers::ACETRAINER_M,"Trainer",_I("Oof! Training always gets a rush out of me!"),false,var)
        $game_switches[641]=false
        $game_switches[321]=true if temp
      else
       Kernel.pbMessage(mc("You don't have enough money.",b))
        return false
      end
      

    end
    if event[1]==Kernel.gnfu("EV Trainer")
 Kernel.faceP(eventid)
     Kernel.pbMessage(mc("EVs can be tough to train up- but I'm here to help you with that.",r))
     Kernel.pbMessage(mc(_INTL("For $1300 a battle, you can battle against 3 Pokemon."),r))
     var=Kernel.pbMessage(mc("You have $"+$Trainer.money.to_s+". What EV do you want to train?",r),["(Cancel)","HP","Attack","Defense","Speed","Special Attack","Special Defense"])
      if var==0
       Kernel.pbMessage(mc("Aww, boo!",r))
        return false
      end
      if $Trainer.money>=1300
        $PokemonGlobal.nextBattleBack="City"
        $Trainer.money -= 1300
        supvar=var
        supvar += 6 if $game_variables[114]>1
        supvar += 6 if $game_variables[114]>2

        temp=false
        if $game_switches[321]
          $game_switches[321]=false
          $game_switches[671]=true
          temp=true
        end
        pbTrainerBattle(PBTrainers::ACETRAINER_F_SNOW,"Trainer",_I("Keep up the good work!"),false,supvar)
        $game_switches[321]=true if temp
      else
       Kernel.pbMessage(mc("You gotta be able to pay up!.",b))
        return false
      end     
    end
    if event[1]==Kernel.gnfu("Pokegear Designer")
       Kernel.faceP(eventid)
       if !$game_switches[130]
     Kernel.pbMessage(mc("Why, hello there! I'm the Pokegear Designer!",b))
     Kernel.pbMessage(mc("I can give you some free updates to your Pokegear!",b))
     Kernel.pbMessage("... ... ...")
      Kernel.pbMessage(mc("And... done! Your Pokegear has now been upgraded!",b))

     $game_switches[130]=true
   else
     Kernel.pbMessage(mc("I've already updated your Pokegear.",b))
   end
 end
 
    if event[1]==Kernel.gnfu("Name Rater")
       Kernel.faceP(eventid)
     Kernel.pbMessage(mc("Hello, hello! I am the official Name Rater!",b))
      if Kernel.pbConfirmMessage(mc("Want me to rate the nicknames of your Pokémon?",b))
          Kernel.pbMessage(mc("No problem! Which Pokémon's nickname shall I critique?",b))
          pbChoosePokemon(1,3)
          if pbGet(1) < 0
            Kernel.pbMessage(mc("Very well, then! No worries!",b))
            return false
          end
          if $Trainer.party[pbGet(1)].egg?
            Kernel.pbMessage(mc("Now, that is merely an egg!",b))
            return false
          end
          Kernel.pbMessage(mc("Ah, "+pbGet(3)+"!",b))
          Kernel.pbMessage(mc("That is a fine nickname, but...",b))
          if Kernel.pbConfirmMessage(mc("Would you like me to give it a nicer name?",b))
            Kernel.pbMessage(mc("What shall the new nickname be?",b))
            pkmn=$Trainer.party[pbGet(1)]
            species=PBSpecies.getName(pkmn.species)
            pbTextEntry("#{species}'s nickname?",0,11,5)
            if $game_variables[5]=="" || $game_variables[5]==pbGet(3)
              pkmn=$Trainer.party[pbGet(1)]
              pkmn.name=PBSpecies.getName(pkmn.species)
              $game_variables[3]=pkmn.name
              Kernel.pbMessage(mc("Done! It appears no different than before, and yet it is vastly superior!",b))
              return true
            else
              pkmn=$Trainer.party[pbGet(1)]
              pkmn.name=pbGet(5)
              Kernel.pbMessage(mc("Done! It appears no different than before, and yet it is vastly superior!",b))
              return true
            end
            
          else
            Kernel.pbMessage(mc("Very well, then! No worries!",b))
            return false
          end
      else        
          Kernel.pbMessage(mc("Very well, then! No worries!",b))
          return false
      end
    end
    if event[1]==Kernel.gnfu("IV Changer")
       Kernel.faceP(eventid)
       Kernel.pbMessage(mc("I'm the IV Changer.",b))
      if !$game_switches[699]
        if  Kernel.pbConfirmMessage(mc("Do you know what an IV is?",b))
        else
          Kernel.pbMessage(mc(_INTL("IVs are statistics that every Pokemon can have."),b))
          Kernel.pbMessage(mc(_INTL("They're basically Pokemon genetics!"),b))
          Kernel.pbMessage(mc(_INTL("They can range from 0-31, and are the reason one Pokemon with the same amount of training as another can be stronger."),b))
        end
      end
      $game_switches[699]=true
      Kernel.pbMessage(mc(_INTL("If you have an IV Stone, I can max the IVs of one of your Pokemon."),b))
      if Kernel.pbConfirmMessage(mc("Well? What do you say?",b))
        if $PokemonBag.pbQuantity(PBItems::IVSTONE)>0
          Kernel.pbMessage(mc("Which Pokemon should have their IV maxed?",b))
          pbChoosePokemon(1,3)
          if pbGet(1) < 0
            Kernel.pbMessage(mc("Very well, then! No worries!",b))
            return false
          end
          if $Trainer.party[pbGet(1)].egg?
            Kernel.pbMessage(mc("I can't change the IVs of an Egg!",b))
            return false
          end
          ivArray=[]
          for i in 0...6
            ivArray[i]=$Trainer.party[pbGet(1)].iv[i]
          end
          var=Kernel.pbMessage(mc("Very well! And which IV shall I change?",b),["(Cancel)",
                               "HP: " + ivArray[0].to_s,"Attack: " + ivArray[1].to_s,
                               "Defense: " + ivArray[2].to_s,"Speed: " + ivArray[3].to_s,
                               "Special Attack: " + ivArray[4].to_s,
                               "Special Defense: " + ivArray[5].to_s])
          if var == 0
                Kernel.pbMessage(mc("Aww, a shame.",b))
                return false           
              end
          var -= 1
          $Trainer.party[pbGet(1)].iv[var]=31
          $PokemonBag.pbDeleteItem(PBItems::IVSTONE,1)
                Kernel.pbMessage(mc("Very well! It is done!",b))
                Kernel.pbMessage(mc("Come again soon!",b))
          
        else
         Kernel.pbMessage(mc("You don't have any IV Stones!",b))
          return false
        end
        
      else
               Kernel.pbMessage(mc("Aww, a shame.",b))
                return false
      end
    end
    if event[1]==Kernel.gnfu("EV Resetter")
      Kernel.faceP(eventid)
      Kernel.pbMessage(mc("Hey- I'm the EV Resetter.",r))
      if Kernel.pbConfirmMessage(mc(_INTL("Would you like me to reset the EVs of one of your Pokemon?"),r))
          Kernel.pbMessage(mc(_INTL("Which Pokemon should have their EVs reset?"),r))
          pbChoosePokemon(1,3)
          if pbGet(1) < 0
            Kernel.pbMessage(mc("What a shame.",r))
            return false
          end
          if $Trainer.party[pbGet(1)].egg?
            Kernel.pbMessage(mc("Eggs don't have EVs, fool!",r))
            return false
          end
          var=Kernel.pbMessage(mc("Which EV should be reset?",r),["(Cancel)","HP","Attack","Defense","Speed","Special Attack","Special Defense"])
          if var == 0
                Kernel.pbMessage(mc("Stop playing games and make a decision!",r))
                return false           
              end
          var -= 1
          $Trainer.party[pbGet(1)].ev[var]=0
          Kernel.pbMessage(mc("There you go, I've reset the EVs.",r))
            
      else
        Kernel.pbMessage(mc("Aww, come back another time I suppose.",r))
       
      end
      
        
    end
    if event[1]==Kernel.gnfu("Move Relearner")
      Kernel.faceP(eventid)
      Kernel.pbMessage(mc("I'm the MOVE RELEARNER!",b))
      Kernel.pbMessage(mc("Woohoo! I can help you RELEARN MOVES!",b))
      Kernel.pbMessage(mc("Man, I'm pumped! Give me a Heart Scale and I'll help you relearn some moves!",b))
      if $PokemonBag.pbQuantity(PBItems::HEARTSCALE)>0 
        if Kernel.pbMessage(mc("Are you interested?",b))
          Kernel.pbMessage(mc("Which Pokemon shall relearn moves?",b))
          pbChoosePokemon(1,3,proc{|p|pbHasRelearnableMove?(p)},true)
          if pbGet(1) < 0
            Kernel.pbMessage(mc("Come back another time, then.",b))
            return false
          end
          if $Trainer.party[pbGet(1)].egg?
            Kernel.pbMessage(mc("I can't teach moves to an Egg, yo!",b))
            return false
          end
          if $Trainer.party[pbGet(1)].egg?
            Kernel.pbMessage(mc("I can't teach moves to an Egg, yo!",b))
            return false
          end
          if !pbHasRelearnableMove?($Trainer.party[pbGet(1)])
            Kernel.pbMessage(mc("This one can't relearn any moves!",b))
            return false           
          end
          Kernel.pbMessage(mc("What move shall I teach?",b))
          if pbRelearnMoveScreen($Trainer.party[pbGet(1)])
            $PokemonBag.pbDeleteItem(PBItems::HEARTSCALE)
            Kernel.pbMessage(mc("There you go! Come back again!",b))
          else
            Kernel.pbMessage(mc("Come back another time, then.",b))
            return false
          end
        else
          Kernel.pbMessage(mc("Come back another time, then.",b))
          return false
        end
      else        
        Kernel.pbMessage(mc("Oh, man. You don't have any Heart Scales!",b))
        return false
      end
      $PokemonTemp.dependentEvents.refresh_sprite
    end
    if event[1]==Kernel.gnfu("Nurse")
        Kernel.faceP(eventid)
      Kernel.pbMessage(mc("Hello! I am the Nurse.",r))
      if Kernel.pbConfirmMessage(mc(_INTL("Would you like to heal your Pokemon?"),r))
        pbHealAll
        $PokemonTemp.dependentEvents.refresh_sprite
        Kernel.pbMessage(mc("Very well! They are healed.",r))
      end
    end
    if event[1]==Kernel.gnfu("Pikataxi")
      Kernel.faceP(eventid)
      pbCommonEvent(32)
    end
    if event[1]==Kernel.gnfu("Nuzlocke Trophy")
        Kernel.pbMessage("This golden coat shows that this base owner fully completed the game on Nuzlocke Mode.")
    end
    
    
    if event[1]==Kernel.gnfu("Flag Guy")
      Kernel.faceP(eventid)
      Kernel.pbMessage(mc("Yo, yo, yo! I'm the Flag Guy!",b))
      Kernel.pbMessage(mc("By visiting the bases of friends, you can find super-special flags!",b))
      Kernel.pbMessage(mc("If you get enough of them, maybe I'll have a reward for you!",b))
      if $game_variables[121]==0 && $game_variables[119]>=1
        Kernel.pbMessage(mc("Well, well, well! I've got a reward to start you off!",b))
        Kernel.pbMessage(mc("For your very first Flag, why don't you have a Rare Candy? I hear they're all the rage!",b))
        Kernel.pbReceiveItem(PBItems::RARECANDY)
        $game_variables[121] += 1
      end 
      if $game_variables[121]<5 && $game_variables[119]>=5
        Kernel.pbMessage(mc("Ohoho! Five flags! That's incredible!",b))
        Kernel.pbMessage(mc("Take these as a little prize from me!",b))
        Kernel.pbReceiveItem(PBItems::ULTRABALL,4)
        $game_variables[121]=5
      end
      if $game_variables[121]<10 && $game_variables[119]>=10
        Kernel.pbMessage(mc("Ten flags! Wow! That's impressive!",b))
        Kernel.pbMessage(mc("You should have these- a little gift!",b))
        Kernel.pbReceiveItem(PBItems::HEARTSCALE,4)
        $game_variables[121]=10
      end
      if $game_variables[121]<15 && $game_variables[119]>=15
        Kernel.pbMessage(mc("Fifteen flags- this gets better and better!",b))
        Kernel.pbMessage(mc("Take these as a little prize from me!",b))
        Kernel.pbReceiveItem(PBItems::TIMERBALL,5)
        $game_variables[121]=15
      end
      if $game_variables[121]<22 && $game_variables[119]>=22
        Kernel.pbMessage(mc("22 flags- not bad at all!",b))
        Kernel.pbMessage(mc("Here, take this TM, good old Sunny Day, and be proud of it!",b))
        Kernel.pbReceiveItem(PBItems::TM11)
        $game_variables[121]=22
      end
      if $game_variables[121]<35 && $game_variables[119]>=35
        Kernel.pbMessage(mc("35 flags... wow! I'm starting to run out of prizes!",b))
        Kernel.pbMessage(mc("I still have these though- why don't you have them?",b))
        Kernel.pbReceiveItem(PBItems::RARECANDY,3)
        $game_variables[121]=35
      end

      if $game_variables[121]<50 && $game_variables[119]>=50
        Kernel.pbMessage(mc("Wh-what? 50 flags? That's incredible!",b))
        Kernel.pbMessage(mc("Here... this is one of the most valuable prizes I have!",b))
        Kernel.pbReceiveItem(PBItems::STUNFISKITE)
        $game_variables[121]=50
      end
      if $game_variables[121]<60 && $game_variables[119]>=60
        Kernel.pbMessage(mc("I need to reward 60 flags. I simply couldn't do without!",b))
        Kernel.pbMessage(mc("It's not much, but I think you'll like it!",b))
        Kernel.pbReceiveItem(PBItems::RARECANDY,5)
        $game_variables[121]=60
      end
      if $game_variables[121]<80 && $game_variables[119]>=80
        Kernel.pbMessage(mc("80 Flags! That's... incredible! Wow!",b))
        Kernel.pbMessage(mc("Take these! I'm sure you'll find a use for them!",b))
        Kernel.pbReceiveItem(PBItems::MAXREVIVE,2)
        $game_variables[121]=80
      end
      if $game_variables[121]<100 && $game_variables[119]>=100
        Kernel.pbMessage(mc("Wow, 100 flags. That's absolutely stunning.",b))
        Kernel.pbMessage(mc("Why don't you take this? It's the greatest prize I have!",b))
        Kernel.pbReceiveItem(PBItems::SPIRITOMBITE,1)
        $game_variables[121]=100
      end

    end
    
    if event[1]==Kernel.gnfu("Move Deleter")
      Kernel.faceP(eventid)
      Kernel.pbMessage(mc("Ah! I'm the Move Deleter!","blue"))
      Kernel.pbMessage(mc(_INTL("I can administer medical amnesiacs to make your Pokemon forget moves."),b))
      if Kernel.pbConfirmMessage(mc("Would you like me to? I'm licensed- I swear!",b))
        while 1==1
        Kernel.pbMessage(mc(_INTL("Which Pokemon should forget a move?"),b))
        pbChoosePokemon(1,3)
        if pbGet(1)==-1
          Kernel.pbMessage(mc("Come back when a move needs forgetting.",b))
          return false
        end
        if $Trainer.party[pbGet(1)].egg?
          Kernel.pbMessage(mc("That's just an egg!",b))
          return false          
        end
        if pbNumMoves($Trainer.party[pbGet(1)])==1
          Kernel.pbMessage(mc(_INTL("That Pokemon only has one move!"),b))
          return false      
        end
        Kernel.pbMessage(mc("Which move needs forgetting?",b))
        pbChooseMove($Trainer.party[pbGet(1)],2,4)
        if pbGet(2)==-1
          
        else
          if Kernel.pbConfirmMessage(mc("You want to forget "+pbGet(3)+"'s "+pbGet(4)+"?",b))
            pbDeleteMove($Trainer.party[pbGet(1)],pbGet(2))
            $PokemonTemp.dependentEvents.refresh_sprite
            Kernel.pbMessage(mc("Very well! It has been done.",b))
            return true
          else
           Kernel.pbMessage(mc("Come again if there are moves to be forgotten.",b))
           return false
          end
        end   
        end
      else
           Kernel.pbMessage(mc("Come again if there are moves to be forgotten.",b))
           return false
         end

       end

    if event[1]==Kernel.gnfu("Day-Care Agent")
      Kernel.faceP(eventid)
           Kernel.pbMessage(mc("I'm an agent from the Day-Care.",r))
           Kernel.pbMessage(mc("I can deliver Eggs from there if any are hatched.",r))
           if Kernel.pbEggGenerated?
              Kernel.pbMessage(mc("My goodness! We were raising your Pokemon and-",r))
              Kernel.pbMessage(mc("You know what? I'm not going to lie to you.",r))
              Kernel.pbMessage(mc(_INTL("Your Pokemon had a baby, inside this Egg."),r))
              if $Trainer.party.length>=6
                Kernel.pbMessage(mc("You don't have enough room for it, though.",r))
                return false
              end
              if Kernel.pbConfirmMessage(mc("You do want it, don't you?",r))
                Kernel.pbMessage(mc("Take good care of it!",r))                
                pbDayCareGenerateEgg
                $PokemonGlobal.daycareEgg=0
                $PokemonGlobal.daycareEggSteps=0
              end
            else
            Kernel.pbMessage(mc("Unfortunately, there are no Eggs waiting for you right now.",r))
             end
    end

 #   if event[1]==Kernel.getNumberForUpgrade("Base Link")
 #     Kernel.pbConfirmMessage("Would you like to try connecting to somebody elses base?")
 #   end
    

  end
  
def pbASU(commands,string,price)
    if $game_variables[80][Kernel.gnfu(string)]!=true
        commands.push([price,string,_INTL("{2} ${1}",price,(string)),94])
    end
end
def getAllSBMaps
  return [78,115,118,164,189,353,389,387,730,728,726]
end

def startSBPlacement(upgradeid,previousevent=nil)
  $sb_is_placing=true
  $sb_what_upgrade=upgradeid
  $sb_previous_event=previousevent
  $sb_is_deleting=false
end


=begin

class Game_Character
  attr_reader   :id
  attr_reader   :x
  attr_reader   :y
  attr_reader   :real_x 
  attr_reader   :real_y
  attr_reader   :tile_id  
  attr_accessor :character_name
  attr_accessor :character_hue 
  attr_reader   :opacity   
  attr_reader   :blend_type 
  attr_reader   :direction  
  attr_reader   :pattern    
  attr_reader   :move_route_forcing   
  attr_accessor :through            
  attr_accessor :animation_id       
  attr_accessor :transparent        
  attr_reader   :map
  attr_accessor :move_speed
  attr_accessor :walk_anime
=end

################################################################################
# "Triple Triad" mini-game
# By Unknown
################################################################################
class PokemonGlobalMetadata
  attr_accessor :ids

  def ids
    @ids=IDStorage.new if !@ids
    return @triads
  end
end



class UpgradeStorage
  def maxSize
    return PBSpecies.getCount
  end

  def maxPerSlot
    return 99
  end

  def initialize
    @items=[]
  end

  def empty?
    return @items.length==0
  end

  def length
    @items.length
  end

  def [](i)
    @items[i]
  end

  def getItem(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][0]
    end
  end

  def getCount(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][1]
    end
  end

  def pbQuantity(item)
    return ItemStorageHelper.pbQuantity(@items,self.maxSize,item)
  end

  def pbDeleteItem(item,qty=1)
    return ItemStorageHelper.pbDeleteItem(@items,self.maxSize,item,qty)
  end

  def pbCanStore?(item,qty=1)
    return ItemStorageHelper.pbCanStore?(@items,self.maxSize,self.maxPerSlot,item,qty)
  end

  def pbStoreItem(item,qty=1)
    return ItemStorageHelper.pbStoreItem(@items,self.maxSize,self.maxPerSlot,item,qty)
  end
end



def buySecretBaseUpgrades(sort)
  commands=[]
  realcommands=[]
  if !$game_variables[80].is_a?(Array)
    $game_variables[80]=Array.new
  end
  if sort==0
    if $game_variables[80][Kernel.getNumberForUpgrade("Mart Worker")]!=true
    commands.push([1000,"Mart Worker",_INTL("{2} ${1}",1000,("Mart Worker")),94])
  end
    if $game_variables[80][Kernel.getNumberForUpgrade("Fossil Maniac")]!=true
    commands.push([10000,"Fossil Maniac",_INTL("{2} ${1}",10000,("Fossil Maniac")),94])
  end
    if $game_variables[80][Kernel.getNumberForUpgrade("Level Trainer")]!=true
    commands.push([2000,"Level Trainer",_INTL("{2} ${1}",2000,("Level Trainer")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("EV Trainer")]!=true
    commands.push([3000,"EV Trainer T1",_INTL("{2} ${1}",3000,("EV Trainer T1")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("EV Trainer")]==true && $game_variables[114]==1 && $game_switches[7]
    commands.push([3000,"EV Trainer T2",_INTL("{2} ${1}",3000,("EV Trainer T2")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("EV Trainer")]==true && $game_variables[114]==2 && $game_switches[11]
    commands.push([3000,"EV Trainer T3",_INTL("{2} ${1}",3000,("EV Trainer T3")),94])
  end
  #if $game_variables[80][Kernel.getNumberForUpgrade("Pokegear Designer")]!=true
  #  commands.push([1000,"Pokegear Designer",_INTL("{2} ${1}",1000,("Pokegear Designer")),94])
  #end
  if $game_variables[80][Kernel.getNumberForUpgrade("IV Changer")]!=true
    commands.push([40000,"IV Changer",_INTL("{2} ${1}",40000,("IV Changer")),94])
  end
    if $game_variables[80][Kernel.getNumberForUpgrade("Name Rater")]!=true
    commands.push([1000,"Name Rater",_INTL("{2} ${1}",1000,("Name Rater")),94])
  end
    if $game_variables[80][Kernel.getNumberForUpgrade("EV Resetter")]!=true
    commands.push([10000,"EV Resetter",_INTL("{2} ${1}",10000,("EV Resetter")),94])
  end
    if $game_variables[80][Kernel.getNumberForUpgrade("Move Relearner")]!=true
    commands.push([4000,"Move Relearner",_INTL("{2} ${1}",4000,("Move Relearner")),94])
  end
    if $game_variables[80][Kernel.getNumberForUpgrade("Move Deleter")]!=true
    commands.push([1000,"Move Deleter",_INTL("{2} ${1}",1000,("Move Deleter")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Nurse")]!=true
    commands.push([1000,"Nurse",_INTL("{2} ${1}",1000,("Nurse")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Flag Guy")]!=true
    commands.push([1000,"Flag Guy",_INTL("{2} ${1}",1000,("Flag Guy")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Pikataxi")]!=true
    commands.push([1000,"Pikataxi",_INTL("{2} ${1}",1000,("Pikataxi")),94])
  end
    if $game_variables[80][Kernel.getNumberForUpgrade("Day-Care Agent")]!=true
    commands.push([10000,"Day-Care Agent",_INTL("{2} ${1}",10000,("Day-Care Agent")),94])
  end

    
    
  end
  
  
  if sort == 1
    if $game_variables[80][Kernel.getNumberForUpgrade("Darkrai Statue")]!=true
    commands.push([8000,"Darkrai Statue",_INTL("{2} ${1}",8000,("Darkrai Statue")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Cresselia Statue")]!=true
    commands.push([8000,"Cresselia Statue",_INTL("{2} ${1}",8000,("Cresselia Statue")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Keldeo Plush")]!=true
    commands.push([4000,"Keldeo Plush",_INTL("{2} ${1}",4000,("Keldeo Plush")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Terrakion Plush")]!=true
    commands.push([2000,"Terrakion Plush",_INTL("{2} ${1}",2000,("Terrakion Plush")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Virizion Plush")]!=true
    commands.push([2000,"Virizion Plush",_INTL("{2} ${1}",2000,("Virizion Plush")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Cobalion Plush")]!=true
    commands.push([2000,"Cobalion Plush",_INTL("{2} ${1}",2000,("Cobalion Plush")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Charizard Plush")]!=true
    commands.push([1000,"Charizard Plush",_INTL("{2} ${1}",1000,("Charizard Plush")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Tyranitar Plush")]!=true
    commands.push([3000,"Tyranitar Plush",_INTL("{2} ${1}",3000,("Tyranitar Plush")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Venusaur Plush")]!=true
    commands.push([1000,"Venusaur Plush",_INTL("{2} ${1}",1000,("Venusaur Plush")),94])
  end
  if $game_variables[80][Kernel.getNumberForUpgrade("Blastoise Plush")]!=true
    commands.push([1000,"Blastoise Plush",_INTL("{2} ${1}",1000,("Blastoise Plush")),94])
  end
  
  Kernel.pbASU(commands,"Pikachu Plush",1000)
  Kernel.pbASU(commands,"Ninetales Plush",1000)
  Kernel.pbASU(commands,"Jigglypuff Plush",800)
  Kernel.pbASU(commands,"Arcanine Plush",1000)
  Kernel.pbASU(commands,"Machamp Plush",1000)
  Kernel.pbASU(commands,"Gengar Plush",1200)
  Kernel.pbASU(commands,"Electrode Plush",800)
  Kernel.pbASU(commands,"Scyther Plush",1000)
  Kernel.pbASU(commands,"Electabuzz Plush",1000)
  Kernel.pbASU(commands,"Magmar Plush",1000)
  Kernel.pbASU(commands,"Jynx Plush",1000)
  Kernel.pbASU(commands,"Lapras Plush",1000)
  Kernel.pbASU(commands,"Snorlax Plush",1000)
  Kernel.pbASU(commands,"Dragonite Plush",3000)
  Kernel.pbASU(commands,"Mewtwo Plush",10000)
  Kernel.pbASU(commands,"Meganium Plush",1000)
  Kernel.pbASU(commands,"Typhlosion Plush",1000)
  Kernel.pbASU(commands,"Feraligatr Plush",1000)
  Kernel.pbASU(commands,"Xatu Plush",1000)
  Kernel.pbASU(commands,"Ampharos Plush",1500)
  Kernel.pbASU(commands,"Wobbuffet Plush",1000)
  Kernel.pbASU(commands,"Scizor Plush",1500)
  Kernel.pbASU(commands,"Delibird Plush",1000)
  Kernel.pbASU(commands,"Sceptile Plush",1000)
  Kernel.pbASU(commands,"Blaziken Plush",1000)
  Kernel.pbASU(commands,"Swampert Plush",1000)
  Kernel.pbASU(commands,"Ludicolo Plush",1000)
  Kernel.pbASU(commands,"Shiftry Plush",1000)
  Kernel.pbASU(commands,"Pelipper Plush",1000)
  Kernel.pbASU(commands,"Aggron Plush",1500)
  Kernel.pbASU(commands,"Flygon Plush",1500)
  Kernel.pbASU(commands,"Zangoose Plush",1000)
  Kernel.pbASU(commands,"Seviper Plush",1000)
  Kernel.pbASU(commands,"Milotic Plush",1500)
  Kernel.pbASU(commands,"Tropius Plush",1000)
  Kernel.pbASU(commands,"Absol Plush",1000)
  Kernel.pbASU(commands,"Walrein Plush",1000)
  Kernel.pbASU(commands,"Salamence Plush",3000)
  Kernel.pbASU(commands,"Metagross Plush",3000)
  Kernel.pbASU(commands,"Torterra Plush",1000)
  Kernel.pbASU(commands,"Infernape Plush",1000)
  Kernel.pbASU(commands,"Empoleon Plush",1000)
  Kernel.pbASU(commands,"Luxray Plush",1300)
  Kernel.pbASU(commands,"Garchomp Plush",3000)
  Kernel.pbASU(commands,"Spiritomb Plush",1000)
  Kernel.pbASU(commands,"Lucario Plush",1500)
  Kernel.pbASU(commands,"Serperior Plush",1000)
  Kernel.pbASU(commands,"Emboar Plush",1000)
  Kernel.pbASU(commands,"Samurott Plush",1000)
  Kernel.pbASU(commands,"Zoroark Plush",1500)
  Kernel.pbASU(commands,"Reuniclus Plush",1500)
  Kernel.pbASU(commands,"Chandelure Plush",1000)
  Kernel.pbASU(commands,"Hydreigon Plush",3000)

  end
  
  

  
  if sort == 2
        if $game_variables[80][Kernel.gnfu("Teleport Tile")]==true
          Kernel.pbMessage("Your Teleport Tile purchase was refunded due to a revamp of how they worked.")
          $game_variables[80][Kernel.gnfu("Teleport Tile")]=false
          $Trainer.money += 50000
        end
        

    Kernel.pbASU(commands,"Teleporter (1)",10000)
    Kernel.pbASU(commands,"Teleporter (2)",10000)
    Kernel.pbASU(commands,"Teleporter (3)",10000)
    Kernel.pbASU(commands,"Teleporter (4)",10000)
    Kernel.pbASU(commands,"Teleporter (5)",10000)

  #  if $game_variables[80][Kernel.getNumberForUpgrade("Teleport Tile")]!=true
  #    commands.push([50000,"Teleport Tile",_INTL("{2} ${1}",50000,("Teleport Tile")),94])
  #  end
#if $game_variables[80][Kernel.getNumberForUpgrade("Battle Tile")]!=true
#      commands.push([1000,"Battle Tile",_INTL("{2} ${1}",1000,("Battle Tile")),94])
#    end
    if $game_variables[80][Kernel.getNumberForUpgrade("Movement Tile (Up)")]!=true
      commands.push([4000,"Movement Tile (Up)",_INTL("{2} ${1}",4000,("Movement Tile (Up)")),94])
    end
    if $game_variables[80][Kernel.getNumberForUpgrade("Movement Tile (Down)")]!=true
      commands.push([4000,"Movement Tile (Down)",_INTL("{2} ${1}",4000,("Movement Tile (Down)")),94])
    end
    if $game_variables[80][Kernel.getNumberForUpgrade("Movement Tile (Left)")]!=true
      commands.push([4000,"Movement Tile (Left)",_INTL("{2} ${1}",4000,("Movement Tile (Left)")),94])
    end
    if $game_variables[80][Kernel.getNumberForUpgrade("Movement Tile (Right)")]!=true
      commands.push([4000,"Movement Tile (Right)",_INTL("{2} ${1}",4000,("Movement Tile (Right)")),94])
    end
    
    
    
    end
  
  
  
  
  if commands.length==0
    Kernel.pbMessage(_INTL("You have purchased every avaliable upgrade for now!")) 
    return
  end
  
  #commands.sort!{|a,b| 
  #   if a[0]==b[0]
  #     a[1]<=>b[1] # sort by name
  #   else
  #     a[0]<=>b[0] # sort by price
  #   end
#  }
  for command in commands
    realcommands.push(command[2])
  end
  # Scroll right before showing screen
  pbScrollMap(4,3,5)
  cmdwindow=Window_CommandPokemonEx.newWithSize(realcommands,0,0,256,Graphics.height)
  cmdwindow.z=99999
  moneyString=_INTL("${1}",$Trainer.money)
  goldwindow=Window_UnformattedTextPokemon.newWithSize(
     _INTL("Money:\n{1}",moneyString),0,0,32,32)
  goldwindow.resizeToFit(goldwindow.text,Graphics.width)
  goldwindow.y=0
  goldwindow.x=Graphics.width-goldwindow.width
  goldwindow.z=99999
  Graphics.frame_reset
  done=false
  while !done
    loop do
      Graphics.update
      Input.update
      cmdwindow.active=true
      cmdwindow.update
      goldwindow.update
      if Input.trigger?(Input::B)
        done=true
        $game_variables[128]=0
        break
      end
      if Input.trigger?(Input::C)
        price=commands[cmdwindow.index][0]
        item=commands[cmdwindow.index][3]
        itemname=commands[cmdwindow.index][1]
        cmdwindow.active=false
        cmdwindow.update
        if $Trainer.money<price
          Kernel.pbMessage(_INTL("You don't have enough money."))
          break
        end
        maxafford=(price<=0) ? 99 : $Trainer.money/price
        maxafford=99 if maxafford>99
        params=ChooseNumberParams.new
        params.setRange(1,maxafford)
        params.setInitialValue(1)
        params.setCancelValue(0)
        quantity=1
  #      quantity=Kernel.pbMessageChooseNumber(
  #         _INTL("",itemname),params)
        if quantity>0
          price*=quantity
          if !Kernel.pbConfirmMessage(_INTL("The {1} upgrade? Certainly. That will be ${2}. OK?",itemname,price))
            break
          end
          if $Trainer.money<price
            Kernel.pbMessage(_INTL("You don't have enough money."))
            break
          end
          poop = 4
          if poop == 5
            Kernel.pbMessage(_INTL("You have no room for more upgrades."))
          else
            $game_variables[114]==0 if $game_variables[114] == nil
            if itemname.include?("EV Trainer")
              itemname="EV Trainer"
            end
            
            $game_variables[80][Kernel.getNumberForUpgrade(itemname)]=true
            $game_variables[114] += 1 if $game_variables[80][Kernel.gnfu(itemname)]==true 
            $Trainer.money-=price
            moneyString=_INTL("${1}",$Trainer.money)
            goldwindow.text=_INTL("Money:\n{1}",moneyString)
            for i in 0...commands.length
                if Kernel.getNumberForUpgrade(commands[i][1]) && $game_variables[80][Kernel.getNumberForUpgrade(commands[i][1])]==true
                  commands[i]=nil
                end
            end
            commands.compact!
            Kernel.pbMessage(_INTL("Here you are!\r\nThank you!"))
            done = true
            break
            end
        end
      end
    end
  end
  cmdwindow.dispose
  goldwindow.dispose
  Graphics.frame_reset
  # Scroll right before showing screen
  pbScrollMap(6,3,5)
end
def red(text)
    colorize(text,31)
end
def colorize(text, color_code)
  "\e[#{color_code}m#{text}e[0m"
end
def getNumberForUpgrade(name)
  return 1 if name=="Push Trap"
  return 2 if name=="Darkrai Statue"
  return 3 if name=="Cresselia Statue"
  return 4 if name=="Keldeo Plush"
  return 5 if name=="Terrakion Plush"
  return 6 if name=="Virizion Plush"
  return 7 if name=="Cobalion Plush"
  return 8 if name=="Blastoise Plush"
  return 9 if name=="Tyranitar Plush"
  return 10 if name=="Charizard Plush"
  return 11 if name=="Venusaur Plush"
  return 12 if name=="Teleport Tile"
  return 13 if name=="Battle Tile"
  return 14 if name=="Movement Tile (Down)"
  return 15 if name=="Movement Tile (Up)"
  return 16 if name=="Movement Tile (Left)"
  return 17 if name=="Movement Tile (Right)"
  return 18 if name=="Nigga Tile"
  return 19 if name=="Mart Worker"
  return 20 if name=="Fossil Maniac"
  return 21 if name=="Level Trainer"
  return 22 if name=="EV Trainer"
  return 23 if name=="Move Relearner"
  return 24 if name=="Move Deleter"
  return 25 if name=="EV Resetter"
  return 26 if name=="IV Changer"
  return 27 if name=="Day-Care Agent"
  return 28 if name=="Pokegear Designer"
  return 29 if name=="Name Rater"
  return 30 if name=="Nurse"
  return 31 if name=="Pikachu Plush"
  return 32 if name=="Ninetales Plush"
  return 33 if name=="Jigglypuff Plush"
  return 34 if name=="Machamp Plush"
  return 35 if name=="Gengar Plush"
  return 36 if name=="Electrode Plush"
  return 37 if name=="Scyther Plush"
  return 38 if name=="Electabuzz Plush"
  return 39 if name=="Magmar Plush"
  return 40 if name=="Jynx Plush"
  return 41 if name=="Lapras Plush"
  return 42 if name=="Snorlax Plush"
  return 43 if name=="Dragonite Plush"
  return 44 if name=="Mewtwo Plush"
  return 45 if name=="Meganium Plush"
  return 46 if name=="Typhlosion Plush"
  return 47 if name=="Feraligatr Plush"
  return 48 if name=="Xatu Plush"
  return 49 if name=="Ampharos Plush"
  return 50 if name=="Wobbuffet Plush"
  return 51 if name=="Scizor Plush"
  return 52 if name=="Delibird Plush"
  return 53 if name=="Sceptile Plush"
  return 54 if name=="Blaziken Plush"
  return 55 if name=="Swampert Plush"
  return 56 if name=="Ludicolo Plush"
  return 57 if name=="Shiftry Plush"
  return 58 if name=="Pelipper Plush"
  return 59 if name=="Aggron Plush"
  return 60 if name=="Flygon Plush"
  return 61 if name=="Zangoose Plush"
  return 62 if name=="Seviper Plush"
  return 63 if name=="Milotic Plush"
  return 64 if name=="Tropius Plush"
  return 65 if name=="Absol Plush"
  return 66 if name=="Walrein Plush"
  return 67 if name=="Salamence Plush"
  return 68 if name=="Metagross Plush"
  return 69 if name=="Torterra Plush"
  return 70 if name=="Luxray Plush"
  return 71 if name=="Garchomp Plush"
  return 72 if name=="Lucario Plush"
  return 73 if name=="Spiritomb Plush"
  return 74 if name=="Serperior Plush"
  return 75 if name=="Emboar Plush"
  return 76 if name=="Reuniclus Plush"
  return 77 if name=="Zoroark Plush"
  return 78 if name=="Samurott Plush"
  return 79 if name=="Chandelure Plush"
  return 80 if name=="Hydreigon Plush"
  return 81 if name=="Arcanine Plush"
  return 82 if name=="Infernape Plush"
  return 83 if name=="Empoleon Plush"
return 84 if name=="Flag Guy"
return 85 if name=="Teleporter (1)"
return 86 if name=="Teleporter (2)"
return 87 if name=="Teleporter (3)"
return 88 if name=="Teleporter (4)"
return 89 if name=="Teleporter (5)"

return 90 if name=="Pikataxi"
return 91 if name=="Nuzlocke Trophy"
end


def getStringsOfType(type)
  if type==0
    return ["Mart Worker","Fossil Maniac","Level Trainer","EV Trainer",
    "Move Relearner","Move Deleter","EV Resetter","IV Changer","Flag Guy","Nurse","Day-Care Agent","Name Rater","Pikataxi"]
  elsif type==1
    return ["Darkrai Statue","Cresselia Statue","Keldeo Plush","Terrakion Plush",
    "Virizion Plush","Cobalion Plush","Blastoise Plush","Tyranitar Plush",
    "Charizard Plush","Venusaur Plush","Pikachu Plush","Ninetales Plush",
    "Jigglypuff Plush","Arcanine Plush","Machamp Plush","Gengar Plush",
    "Electrode Plush","Scyther Plush","Electabuzz Plush","Magmar Plush",
    "Jynx Plush","Lapras Plush","Snorlax Plush","Dragonite Plush",
    "Mewtwo Plush","Meganium Plush","Typhlosion Plush","Feraligatr Plush",
    "Xatu Plush","Ampharos Plush","Wobbuffet Plush","Scizor Plush",
    "Delibird Plush","Sceptile Plush","Blaziken Plush","Swampert Plush",
    "Ludicolo Plush","Shiftry Plush","Pelipper Plush","Aggron Plush",
    "Flygon Plush","Zangoose Plush","Seviper Plush","Milotic Plush",
    "Tropius Plush","Absol Plush","Walrein Plush","Salamence Plush",
    "Metagross Plush","Torterra Plush","Infernape Plush","Empoleon Plush",
    "Luxray Plush","Garchomp Plush","Spiritomb Plush","Lucario Plush",
    "Serperior Plush","Emboar Plush","Samurott Plush","Zoroark Plush",
    "Reuniclus Plush","Chandelure Plush","Hydreigon Plush"]
  elsif type==2
    return ["Teleporter (1)","Teleporter (2)","Teleporter (3)","Teleporter (4)","Teleporter (5)","Battle Tile","Movement Tile (Up)","Movement Tile (Down)",
    "Movement Tile (Left)","Movement Tile (Right)"]
  end
end
