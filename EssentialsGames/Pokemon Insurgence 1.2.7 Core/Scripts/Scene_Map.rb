#===============================================================================
# ** Modified Scene_Map class for Pokémon.
#-------------------------------------------------------------------------------
#  
#===============================================================================
class Scene_Map
  def spriteset
    for i in @spritesets.values
      return i if i.map==$game_map
    end
    return @spritesets.values[0]
  end

  def disposeSpritesets
   return if !@spritesets
    for i in @spritesets.keys
      if @spritesets[i]
        @spritesets[i].dispose
        @spritesets[i]=nil
      end
    end
    @spritesets.clear
    @spritesets={}
  end

  def createSpritesets
    @spritesets={}
    for map in $MapFactory.maps
      @spritesets[map.map_id]=Spriteset_Map.new(map)
    end
    $MapFactory.setSceneStarted(self)
    updateSpritesets
  end

  def updateMaps
    for map in $MapFactory.maps
      map.update
    end
    $MapFactory.updateMaps(self)
  end

  def updateSpritesets
    @spritesets={} if !@spritesets
    keys=@spritesets.keys.clone
    for i in keys
     if !$MapFactory.hasMap?(i)
       @spritesets[i].dispose if @spritesets[i]
       @spritesets[i]=nil
       @spritesets.delete(i)
     else
       @spritesets[i].update
     end
    end
    for map in $MapFactory.maps
      if !@spritesets[map.map_id]
        @spritesets[map.map_id]=Spriteset_Map.new(map)
      end
    end
    Events.onMapUpdate.trigger(self)
  end

  def main
    createSpritesets
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    disposeSpritesets
    if $game_temp.to_title
      Graphics.transition
      Graphics.freeze
    end
  end

  def miniupdate
    $PokemonTemp.miniupdate=true if $PokemonTemp
    loop do
      updateMaps
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end
      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    updateSpritesets
    $PokemonTemp.miniupdate=false if $PokemonTemp
  end

  def update
    done = false
    loop do
      updateMaps
      pbMapInterpreter.update
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end
      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    updateSpritesets
    if $game_temp.to_title
      $scene = pbCallTitle
      return
    end
    if $game_switches[170]
      $DEBUG = false
      if $game_switches[64] && $PokemonBag.pbQuantity(PBItems::MEGARING)==0
        $PokemonBag.pbStoreItem(PBItems::MEGARING,1) 
      end
      if !$game_switches[360] && $PokemonBag != nil && $PokemonBag.pbQuantity(PBItems::HACKERCALL) < 1
        $PokemonBag.pbStoreItem(PBItems::HACKERCALL,1)
      end
    end
    if $game_variables && $game_variables[77].is_a?(Array)
      if !Kernel.checkIsFSLegal && $game_switches[47]
        $game_variables[77]=Kernel.generateFriendSafari
      end
    end
    if $Trainer && $Trainer.party.is_a?(Array)
      for poke in $Trainer.party
        if poke.is_a?(String)
          $Trainer.party.delete(poke)
        end
      end
    end
  
  case $PokemonGlobal.playerID
  when 0,1
    $game_variables[180]=0
  when 2,3
    $game_variables[180]=1
  when 4,5
    $game_variables[180]=2
  else
    $game_variables[180]=3
  end
  
  if !$game_switches[360] && $PokemonBag != nil && $PokemonBag.pbQuantity(PBItems::HACKERCALL) >= 1
    poke=$Trainer.party[0]
    poke.species=PBSpecies::DUNSPARCE
  end
  #x$PokemonSystem.tilemap=2
  # if $game_switches[35]
    
    #$scene.spriteset.characterUpdate
   #   $game_switches[35] = false
   # end
    
  if $game_switches[163]
    if $game_variables[50] > 400
      Kernel.pbMessage("Save failed.") if !pbAutosave && !$game_switches[136]
      $game_variables[50] = 0
    else
      $game_variables[50] = $game_variables[50] + 1
    end
  end
  $game_variables[62]=Array.new if $game_variables[62]==0
  if $game_temp.transition_processing
    $game_temp.transition_processing = false
    if $game_temp.transition_name == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
    end
  end
  if $game_temp.message_window_showing
    return
  end
  if Input.trigger?(Input::C)
    unless pbMapInterpreterRunning?
      $PokemonTemp.hiddenMoveEventCalling=true
    end
  end      
  if Input.trigger?(Input::B) && !$game_switches[136]
    if !pbMapInterpreterRunning? && !$game_system.menu_disabled
      $game_temp.menu_calling = true #TEMPDEXNAV should be menu
      #        $game_temp.menu_beep = true
    end
  end
  if Input.trigger?(Input::D)
    if $game_map.map_id==428 || $game_map.map_id==429 || $game_map.map_id==430 ||
       $game_map.map_id==431 || $game_map.map_id==491 || $game_map.map_id==771 || 
       $game_map.map_id==772 || $game_map.map_id==773 || $game_map.map_id==774
      Kernel.pbMessage("An electromagnetic pulse prevents use of the DexNav!")
    elsif $Trainer.pokegear && !$game_system.hm7 && !pbMapInterpreterRunning? && !$game_system.menu_disabled #&& !$DEBUG
      $game_temp.dexnav_calling = true #TEMPDEXNAV should be menu
      #      $game_temp.menu_beep = true
    end
  end
  if $game_switches[9]
    $game_variables[42][1]=true
    $game_variables[42][2]=true
    $game_variables[42][4]=true
    $game_variables[42][10]=true
    $game_variables[42][11]=true
    $game_variables[42][12]=true
    if $game_switches[435]
      $game_variables[42][5]=true
    end
    if $game_switches[11]
      $game_variables[42][6]=true
    end
  end
  if Input.trigger?(Input::Y) && $PokemonGlobal.runningShoes
    Input.updateKeyState(Input::Y) && !$game_switches[136]
    pbSEPlay("Choose") # Delete this line to remove the SE
    Kernel.pbMessage("Toggled autorun!")
    #Kernel.pbMessage ("was on") if $game_switches[86]
    $game_switches[86] = !$game_switches[86]
  end
  if $game_switches[168]
    (UpgradeStorage).pbBuyUpgradesPre
    $game_map.need_refresh = true
    $game_switches[168] = false
  end    
  $Trainer.badges[10]=true if $game_switches[155]
  Kernel.getCrystalCount
  if !$game_switches[389]
    $game_switches[389]=true
    $PokemonSystem.chooseDifficulty=1
  end
  if $game_switches[152]
    if !$game_variables[42].is_a?(Array)
      $game_variables[42]=[]
    end
    $game_variables[42][4]=true
  end
  if $Trainer && $Trainer.custom == nil
    $Trainer.custom=[]
  end
=begin
    if $Trainer && $game_variables
      #      $Trainer.custom[0]=$game_variables[98]
      #     $Trainer.custom[1]=$game_variables[100]
    end
=end
  if $game_switches[503] && $game_switches[533] &&
     $game_switches[489] && $game_switches[459]
    $game_switches[507]=true
  end
  if $game_map.map_id==488 && $game_switches[452]==false && $game_switches[453]==false && $game_player.y < 39
    Kernel.pbMessage("... ... ...")
    Kernel.pbMessage("There was a rumbling noise from beneath the sea...")
    $game_switches[452]=true
  end
=begin
  $game_variables[665]=true
  if $game_switches[665]
    Kernel.pbMessage("Starting...")
    compileFrontierData(false)
    $game_switches[665]=false
    Kernel.pbMessage("Done!")
  end
=end
  if $game_map.map_id==272
    for ev in $game_map.events.values
      if ev.y>62 || ev.y<36
        next
      end
      if !ev.name.include?("acer")
        next
      end
      if rand(50)==0
        displaceX=ev.x-21
        displaceY=ev.y-51
        if displaceY.abs > displaceX.abs
          if displaceY<0
            #              raise("shouldgodown")
            ev.move_down(false)
          else
            ev.move_up(false)
          end
        else
          if displaceX<0
            ev.move_right(false)
          else
            ev.move_left(false)
          end
        end
      end
    end
    if $game_player.y>62 || $game_player.y<36
    else
      if rand(50)==0
        displaceX=$game_player.x-21
        displaceY=$game_player.y-51
        if displaceY.abs > displaceX.abs
          if displaceY<0
            $game_player.move_down(false)
          else
            $game_player.move_up(false)
          end
        else
          if displaceX<0
            $game_player.move_right(false)
          else
            $game_player.move_left(false)
          end
        end
      end
    end
  end
  if $game_screen and $game_screen.pictures and $game_screen.pictures[22]
    if $game_switches[451]
      if $game_screen.pictures[22].opacity < 254
        $game_screen.pictures[22].opacity += 20 
        $game_screen.pictures[22].opacity = 254 if $game_screen.pictures[22].opacity > 254
      end
    else
      $game_screen.pictures[22].opacity -= 20 if $game_screen.pictures[22].opacity < 255
    end
  end
  if $game_switches[514]
    Kernel.pbTurnMirror($game_variables[146],$game_variables[147])
    $game_switches[514]=false
  end
  if $game_switches[523] && $game_map.map_id != 452
    $game_switches[524]=true
  end
  ## ALPHA
  if File::exists?(".boob.txt")
    File.delete(".boob.txt")
  end
  $game_switches[170] = false
  #if Input.trigger?(Input::O) 
  #  if $game_variables[7] != 0
  #    if Kernel.pbConfirmMessage("Are you sure you wish to toggle your follower?")
  #      pbRemoveDependencies
  #      if $game_switches[241]
  #        $PokemonTemp.dependentEvents.refresh_sprite
  #        pbWait(3)
  #        $game_switches[241]=false
  #        $PokemonTemp.dependentEvents.Come_back(true)
  #      else
  #        $PokemonTemp.dependentEvents.remove_sprite(true)
  #        pbWait(3)
  #        $game_switches[241]=true
  #      end
  #    end
  #  end
  #end
=begin  
    if !done && !$game_switches[170] && !$game_switches[171] && $DEBUG
      if !done
        if Kernel.pbConfirmMessage("Are you sure you want Debug Mode On?")
          $game_switches[170] = true
          done=true
        
      else
      while !done
          #if (!Keys.press?(Keys::N8) || !Keys.press?(Keys::U) || !Keys.press?(Keys::N3)) || Keys.press?(Keys::N4)
            $game_switches[170] = true
            done = true
          else
            $game_switches[171]=true
            done = true
          end
          end
        end
      end
    end
=end

#if $Trainer && $Trainer.party
#  for poke in $Trainer.party
#    if poke.species==PBSpecies::DELTAMUK && isConst?(poke.ability,PBAbilities,:REGURGITATION)
#      poke.form=poke.personalID%6 + 1
#    end
#    if poke.species==PBSpecies::DELTAMUK && !isConst?(poke.ability,PBAbilities,:REGURGITATION)
#      poke.form=0
#    end   
#  end
#end


# Snorlax Leaves

if $game_variables && !$game_variables[171].is_a?(Array)
  $game_variables[171]=Array.new
elsif $game_variables
  $game_variables[171][0]=true
  $game_variables[171][1]=true
end


if $game_switches && !$game_switches[598] && $game_switches[609] && rand(800)==0
  $game_switches[598]=true
  Kernel.pbMessage("There was a rumbling from somewhere far away...")
end






#if Keys.press?(Keys::G)
  
#  pbCompilePokemonData
#end
#if $game_switches[391] && !$game_switches[158]
 #if pbGetMetadata($game_map.map_id,MetadataOutdoor)
 #     $game_screen.weather(2,9,0)
 #   else
 #     $game_screen.weather(0,0,0)
 #     end
#end


if $game_switches && $game_switches[393]
  $game_switches[393]=false
  if $game_switches[371]
    $Trainer.party=$game_variables[124]
    $game_switches[371]=false
  end
end

  if $PokemonGlobal.playerID < 6 && [510,511,512,513,514,515,516,505,508].include?($game_map.map_id)
    $game_variables[112]=$PokemonGlobal.playerID if $PokemonGlobal.playerID < 6
    i=$PokemonGlobal.playerID + 13
    
    pbChangePlayer(12)
    $game_variables[41]=15
    $game_map.need_refresh=true
  end
  


if $game_switches[37] && $PokemonGlobal.playerID<6
  if $PokemonGlobal.playerID % 2 == 0 && $game_switches[78] && !$PokemonGlobal.surfing && !$PokemonGlobal.diving
    pbChangePlayer($PokemonGlobal.playerID+1)
  end
  if $PokemonGlobal.playerID % 2 != 0 && !$game_switches[78]
      pbChangePlayer($PokemonGlobal.playerID-1)
  end    
end


if $game_switches && $game_switches[467]
  $game_switches[476]=true
end


if $PokemonBag && $PokemonBag.pbQuantity(PBItems::ROCKETBOOTS) > 0
    $PokemonBag.pbDeleteItem(PBItems::ROCKETBOOTS)
    $PokemonBag.pbStoreItem(PBItems::VIPPASSTAXI,1)
    $game_switches[403]=true
  end

  #if rand(100) && $PokemonBag.pbQuantity(PBItems::VIPPASSTAXI)>0
  #  $PokemonBag.pbDeleteItem(PBItems::VIPPASSTAXI)
  #  $PokemonBag.pbStoreItem(PBItems::VIPPASSTAXI,1)
  #end
  
  if $game_switches[163]
    $game_switches[163]=false
    Kernel.pbMessage("Welcome to patch 1.2.5! We hope you enjoy a more bug-free gameplay from henceforth.")
    Kernel.pbMessage("The game has detected that you had autosave enabled prior to updating.")
    Kernel.pbMessage("In order to avoid several save corruption issues that were caused by autosave, this feature has been disabled.")
    Kernel.pbMessage("Please remember to save manually from here on out and enjoy the rest of your playing experience!")
  end
  
  if !$game_switches[702]
    $game_switches[702]=true
    if $PokemonBag && $PokemonBag.pbQuantity(PBItems::HIKINGBOOTS)>0 && $game_switches[12]
      Kernel.pbMessage("The game has detected that you have the Hiking Boots and as such likely also have visited the Human Calculator.")
      Kernel.pbMessage("Due to a catastrophic oversight, this previously may have altered the variable containing your starter Pokemon selection.")
      starterAry=["Delta Bulbasaur","Delta Charmander","Delta Squirtle","Eevee"]
      $game_variables[7]=Kernel.pbMessage("Which starter Pokemon did you choose?",starterAry)+1
    end
  end
  
  if $game_switches[671]
    $game_switches[321]=true
    $game_switches[671]=false
  end
  
  if !$game_switches[687]
    $game_switches[372]=false
    $game_switches[373]=false
    $game_switches[687]=true
  end
  
if !$game_switches[655]
  $game_switches[655]=true
  if $game_variables[7]>0 && $game_switches[56]
    Kernel.pbCancelVehicles
    $game_temp.player_new_map_id=43#$PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x=65#$PokemonGlobal.pokecenterX
    $game_temp.player_new_y=26#$PokemonGlobal.pokecenterY
    $game_temp.player_new_direction=2#$PokemonGlobal.pokecenterDirection
    $scene.transfer_player
    $game_map.refresh
    Kernel.pbMessage("Welcome to 1.2! Thank you for sticking with us.")
    Kernel.pbMessage("For safety in patching, you've been transported to the Midna Town Pokemon Center.")
  elsif $game_variables[7]>0
    Kernel.pbCancelVehicles
    $game_temp.player_new_map_id=2#$PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x=26#$PokemonGlobal.pokecenterX
    $game_temp.player_new_y=18#$PokemonGlobal.pokecenterY
    $game_temp.player_new_direction=2#$PokemonGlobal.pokecenterDirection
    $scene.transfer_player
    $game_map.refresh
    Kernel.pbMessage("Welcome to 1.2! Thank you for sticking with us.")
    Kernel.pbMessage("For safety in patching, you've been transported to the Telnor Town Pokemon Center.")
  end
end

if $game_switches && !$game_switches[596]
   MetricHandler.AddOne(PLAYEDGAME)
    if $game_switches[4]
      MetricHandler.AddOne(GYM1WIN)
      MetricHandler.AddOne(GYM1PREVIOUS)
    end
    if $game_switches[5]
      MetricHandler.AddOne(GYM2WIN)
      MetricHandler.AddOne(GYM2PREVIOUS)
    end
    if $game_switches[6]
      MetricHandler.AddOne(GYM3WIN)
      MetricHandler.AddOne(GYM3PREVIOUS)
    end
    if $game_switches[7]
      MetricHandler.AddOne(GYM4WIN)
      MetricHandler.AddOne(GYM4PREVIOUS)
    end
    if $game_switches[8]
      MetricHandler.AddOne(GYM5WIN)
      MetricHandler.AddOne(GYM5PREVIOUS)
    end
    if $game_switches[9]
      MetricHandler.AddOne(GYM6WIN)
      MetricHandler.AddOne(GYM6PREVIOUS)
    end

    $game_switches[596]=true
end
=begin
  if $Trainer && $Trainer.party
    for poke in $Trainer.party
      for i in 0..3
        if poke.moves[i] && poke.moves[i].id==PBMoves::DARKSONATA
          poke.resetMoves
        end
      end
      
      if poke.species==PBSpecies::DELTAROSERADE || poke.species==PBSpecies::DELTAROSELIA
        for i in 0..3
          if poke.moves[i] && poke.moves[i].id==PBMoves::DARKVOID
            poke.moves[i]=PBMove.new(PBMoves::LOVELYKISS)
          end
          if poke.moves[i] && poke.moves[i].id==PBMoves::SWEETKISS
            poke.moves[i]=PBMove.new(PBMoves::LOVELYKISS)
          end
        end
      end
      if poke.species==PBSpecies::DELTADWEBBLE2 || poke.species==PBSpecies::DELTACRUSTLE2
        for i in 0..3
          if poke.moves[i] && poke.moves[i].id==PBMoves::EARTHQUAKE
            poke.moves[i]=PBMove.new(PBMoves::CELEBRATE)
          end
        end
      end
      blacklist=[
        :FIREBLAST,:FLAREBLITZ, # Flareon
        :THUNDERBOLT,:VOLTSWITCH, # Jolteon
        :HYDROPUMP,:SCALD, # VAPOREON
        :FOULPLAY,:PURSUIT, # UMBREON
        :PSYCHIC,:PSYSHOCK, # ESPEON
        :LEAFBLADE,:GIGADRAIN, # LEAFEON
        :ICEBEAM,:BLIZZARD, # GLACEON
        :MOONBLAST,:DAZZLINGGLEAM, # Sylveon
      ]
      exclusion=[]
      eeveelution=false
      case poke.species
      when PBSpecies::FLAREON
        exclusion=[:FIREBLAST,:FLAREBLITZ,]
        eeveelution=true
      when PBSpecies::JOLTEON
        exclusion=[:THUNDERBOLT,:VOLTSWITCH,]
        eeveelution=true
      when PBSpecies::VAPOREON
        exclusion=[:HYDROPUMP,:SCALD,]
        eeveelution=true
      when PBSpecies::UMBREON
        exclusion=[:FOULPLAY,:PURSUIT,]
        eeveelution=true
      when PBSpecies::ESPEON
        exclusion=[:PSYCHIC,:PSYSHOCK,]
        eeveelution=true
      when PBSpecies::LEAFEON
        exclusion=[:LEAFBLADE,:GIGADRAIN,]
        eeveelution=true
      when PBSpecies::GLACEON
        exclusion=[:ICEBEAM,:BLIZZARD,]
        eeveelution=true
      when PBSpecies::SYLVEON
        exclusion=[:MOONBLAST,:DAZZLINGGLEAM,]
        eeveelution=true
      end
      if eeveelution
        tackleexists=false
        for i in 0..3
          move=poke.moves[i]
          for j in blacklist
            if isConst?(move.id,PBMoves,j) && !exclusion.include?(j)
              if !tackleexists
                poke.moves[i]=PBMove.new(PBMoves::TACKLE)
                tackleexists=true
              else
                pbDeleteMove(poke,i)
              end
            end
          end
        end
      end
    end
  end
=end
  

  if $templeavebasetrue
    pbCommonEvent(11)
    $templeavebasetrue=nil  
  end

  if $game_switches != nil && $Trainer != nil && !$game_switches[45] && $Trainer.clothes != nil && $game_switches[45]
    $game_switches[45]=true
    $PokemonBag.pbStoreItem(PBItems::C_JUMPSUIT,1)
    $PokemonBag.pbStoreItem(PBItems::C_NOHAT,1)
    $PokemonBag.pbStoreItem(PBItems::C_PURPLEPACK,1)
    $PokemonBag.pbStoreItem(PBItems::C_JUMPPANTS,1)
    $Trainer.clothes[0]=PBItems::C_NOHAT
    $Trainer.clothes[2]=PBItems::C_JUMPSUIT
    $Trainer.clothes[3]=PBItems::C_PURPLEPACK
    $Trainer.clothes[4]=PBItems::C_JUMPPANTS
    $game_variables[122]=$PokemonGlobal.playerID
    $Trainer.clothes[5]=$game_variables[116]
    pbChangePlayer($game_variables[122])
  elsif $game_switches != nil && $Trainer != nil && $Trainer.clothes != nil && $game_switches[45]
    $Trainer.clothes[5]=$game_variables[116]
    if $Trainer.clothes[2]!=0
      $game_variables[111]=Array.new
      for i in 0..4
        $game_variables[111][i]=$Trainer.clothes[i]
      end
      $game_variables[122]=$PokemonGlobal.playerID
    else
      for i in 0..4
        $Trainer.clothes[i]=$game_variables[111][i]
      end 
      pbChangePlayer($game_variables[122])
    end
  end
  $throwingBalls=nil
  if $game_switches != nil && $Trainer != nil && $Trainer.clothes != nil && $PokemonBag != nil
    $PokemonBag.pbStoreItem(PBItems::C_JUMPSUIT,1) if $PokemonBag.pbQuantity(PBItems::C_JUMPSUIT) == 0
    $PokemonBag.pbStoreItem(PBItems::C_NOHAT,1) if $PokemonBag.pbQuantity(PBItems::C_NOHAT) == 0
    $PokemonBag.pbStoreItem(PBItems::C_PURPLEPACK,1) if $PokemonBag.pbQuantity(PBItems::C_PURPLEPACK) == 0
    $PokemonBag.pbStoreItem(PBItems::C_JUMPPANTS,1) if $PokemonBag.pbQuantity(PBItems::C_JUMPPANTS) == 0
  end

  #if Input.trigger?(Input::F) 
  #  Input.updateKeyState(Keys::F)
  #  pbSave
  #  Kernel.pbMessage("Autosave: On!") if !$game_switches[163]
  #  Kernel.pbMessage("Autosave: Off!") if $game_switches[163]
  #  $game_switches[163] = !$game_switches[163]
  #end
#    if Input.trigger?(Input::G)
#        $game_switches[186] = !$game_switches[186]
#        Kernel.pbMessage("Toggled collision sounds!")
#    end
   # if Keys.press?(Keys::H)
   #     Kernel.pbMessage("Swag Mode: Off!") if !$game_switches[149]
   #             Kernel.pbMessage("Swag Mode: On!") if $game_switches[149]
   #             $game_switches[149] = !$game_switches[149]
   # end
  if $game_switches[354]
    if $Trainer != nil && $Trainer.party != nil && $Trainer.party.is_a?(Array)
      for poke in $Trainer.party
        if poke.name=="??? ???" && $Trainer.owned[poke.species]
          poke.name=PBSpecies.getName(poke.species)
        end
      end
    end
  end
  #   if $PokemonBag && $PokemonBag.pbQuantity(PBItems::TOWERPHOTOGRAPH2)>1
  #      $PokemonBag.pbDeleteItem(PBItems::TOWERPHOTOGRAPH2)
  #      $PokemonBag.pbStoreItem(PBItems::SILVERWING,1)
  #  end
  #   if $PokemonBag && $PokemonBag.pbQuantity(PBItems::TOWERPHOTOGRAPH)>0
  #      $PokemonBag.pbDeleteItem(PBItems::TOWERPHOTOGRAPH)
  #      $PokemonBag.pbStoreItem(PBItems::SILVERWING,1)
  #    end
=begin
if $game_switches != nil && $PokemonBag && $game_switches[238]
     if $PokemonBag.pbQuantity(PBItems::TM31) == 0
        $game_switches[366]=true
      end
    end
=end
  if $game_variables[118]>0
    if $game_variables[118]==1
      $game_screen.pictures[20].erase       
    end
    $game_variables[118] -= 1
  end
  if $game_switches[136]
    $game_variables[64] += 1
  end
  if !$game_variables[63].is_a?(Array)
    $game_variables[63]=[]
  end
  if $game_variables[63].is_a?(Array)
    for i in 0..3
      if $game_variables[63][i] != nil && $game_variables[63][i]>0
        $game_variables[63][i] -= 1
      end 
    end
  end
    
  if Input.trigger?(Input::V) 
    Input.updateKeyState(Keys::V)
    if $game_variables[118]==0 && !$game_system.save_disabled && !$game_switches[163]# && $game_variables[66]==0
      if pbSave
        $game_screen.pictures[20].show("save", 0,
             15, 15, 100, 100, 255, 0)
        $game_variables[118]=30
      else
        Kernel.pbMessage("Save failed.") if !$game_switches[136]
      end
    elsif $game_variables[118]==0
      Kernel.pbMessage("You can't save here.")
    end
      
    #if safeExists?(RTP.getSaveFileName("Game.rxdata"))
    #            Kernel.pbMessage("exists")
    #    File.open(RTP.getSaveFileName("Game.rxdata"),  'rb') {|r|
    #       File.open(RTP.getSaveFileName("Game.rxdata.bak"), 'wb') {|w|
    #          while s = r.read(4096)
    #                  Kernel.pbMessage("saving")
    #
    #           w.write s
  end
  #       }
  #      }
  #   end
  #   if Keys.press?(Keys::L) && $DEBUG
  #       pbFadeOutIn(99999) { 
  #        pbDebugMenu
  #@scene.pbRefresh
  #     }
  #   end
  if $game_switches && $game_switches[152]
    pbDeregisterPartner
  end
   
   
  $PokemonSystem.purism=0 if $PokemonSystem.purism==nil
    #  $game_variables[39] -= 1 if $game_variables[39] > 0
  $game_switches[368]=false
  $PokemonGlobal.runningShoes=true
begin
  if !File::exists?("Graphics/Titles/reached1.txt") && $game_switches[53]
    File.new "Graphics/Titles/reached1.txt","w"
    
  end
  if !File::exists?("Graphics/Titles/reached2.txt") && $game_switches[57]
    File.new "Graphics/Titles/reached2.txt","w"
  end
  if !File::exists?("Graphics/Titles/reached3.txt") && $game_switches[74]
    File.new "Graphics/Titles/reached3.txt","w"
  end
  if !File::exists?("Graphics/Titles/reached4.txt") && $game_switches[70]
    File.new "Graphics/Titles/reached4.txt","w"
  end
  if !File::exists?("Graphics/Titles/reached5.txt") && $game_switches[61]
    File.new "Graphics/Titles/reached5.txt","w"
  end
if !File::exists?("Graphics/Titles/reached6.txt") && $game_switches[133]
    File.new "Graphics/Titles/reached6.txt","w"
  end
  if !File::exists?("Graphics/Titles/reached7.txt") && $game_switches[158]
    File.new "Graphics/Titles/reached7.txt","w"
  end
  if !File::exists?("Graphics/Titles/reached8.txt") && $game_switches[142]
    File.new "Graphics/Titles/reached8.txt","w"
  end
  if !File::exists?("Graphics/Titles/reached9.txt") && $game_switches[146]
    File.new "Graphics/Titles/reached9.txt","w"
  end
  if !File::exists?("Graphics/Titles/reached10.txt") && $game_switches[152]
    File.new "Graphics/Titles/reached10.txt","w"
  end
if !File::exists?("Graphics/Titles/reached11.txt") && $game_switches[437]
    File.new "Graphics/Titles/reached11.txt","w"
  end
  if !File::exists?("Graphics/Titles/reached12.txt") && $game_switches[441]
    File.new "Graphics/Titles/reached12.txt","w"
  end
  if !File::exists?("Graphics/Titles/reached13.txt") && $game_switches[11]
    File.new "Graphics/Titles/reached13.txt","w"
  end
rescue
  
end
  if $Trainer != nil
  $Trainer.mysterygiftaccess=true
end


      if $PleaseTrigger!=nil && $PleaseTrigger==true
        $PleaseTrigger=nil
        var=Kernel.pbMessage("Which trainer would you like to battle? (Q and W to skip through list).",$game_variables[184])
        if Kernel.pbConfirmMessage("Are you sure you wish to battle this trainer?")
          pbTrainerBattle($game_variables[183][var][0],$game_variables[183][var][1],"...",false,0,
          false,true)
        else
      end
    end
      
   # if Keys.press?(Keys::E)
  #   Input.updateKeyState(Keys::E)
  #    $game_map.need_refresh=true if Kernel.pbConfirmMessage("Recreate map?")
  #end
  
      #    Kernel.pbMessage($game_map.tileset_name)#@tileset_name = "Outside"

    #  for i in 1..649
    #      if File.exist?("Graphics/Battlers/%03d.png" % i)
    #      else
    #        Kernel.pbMessage("Graphics/Battlers/%03d.png" % i)
    #      end
    #      if File.exist?("Graphics/Battlers/%03db.png" % i)
    #      else
    #        Kernel.pbMessage("Graphics/Battlers/%03ds.png" % i)
    #      end
    #      if File.exist?("Graphics/Battlers/%03d.png" % i)
    #      else
    #        Kernel.pbMessage("Graphics/Battlers/%03dsb.png" % i)
    #      end

    #    end
        
      if $game_switches[338]
      pbGet(62)[PBSpecies::KYOGRE]=true
    end
    
    if Kernel.getAllSBMaps.include?($game_map.map_id) && $PokemonBag.pbQuantity(PBItems::TABLET)==0
      $PokemonBag.pbStoreItem(PBItems::TABLET)
      
    end

    if $has_hacked && rand(100)==1
        Kernel.pbMessage("Hey! Hey! Listen!")
        $Trainer.party[0].species=PBSpecies::DUNSPARCE
        $Trainer.party[0].hp=1
                $Trainer.party[1].hp=1
        $Trainer.party[2].hp=1
        $Trainer.party[3].hp=1
        $Trainer.party[4].hp=1
        $Trainer.party[5].hp=1

        $Trainer.party[1].species=PBSpecies::DUNSPARCE
        $Trainer.party[2].species=PBSpecies::DUNSPARCE
        $Trainer.party[3].species=PBSpecies::DUNSPARCE
        $Trainer.party[4].species=PBSpecies::DUNSPARCE
        $Trainer.party[5].species=PBSpecies::DUNSPARCE
        
      end
    if $go_up_constant!=nil

      boobx = $game_player.x
      booby = $game_player.y
=begin
      case $game_player.direction
        when 2
          booby += 1
        when 4
          boobx
        when 6
        when 8
          booby -= 1
        end
=end
     # if passable?(boobx, booby)#, #$game_player.direction)
     if $game_player.moving?
        $game_player.move_forward
      elsif $temp_up_constant
        $go_up_constant=nil
        $temp_up_constant=nil
        $game_switches[51]=false
        $game_switches[93]=false
      $game_player.move_speed=4
      $game_player.walk_anime=true
 
        $PokemonTemp.dependentEvents.Come_back(nil,true)
      else
        $game_player.move_forward
        $temp_up_constant=true
        #$PokemonTemp.dependentEvents.remove_sprite(true)

        
      end
    elsif $game_switches[93]
      $game_switches[51]=false
      $game_player.move_speed=4
      $game_player.walk_anime=true

      $game_switches[93]=false
    end
    
    #if $game_map.map_id!=397 && $game_switches[537]
    #  $game_switches[550]=true
    #end
=begin
    megaarray=Kernel.pbGetMegaStoneList
    #   if Input.trigger?(Input::P) && !$game_switches[136]
    #      Input.updateKeyState(Keys::P)
    #            if $game_map.map_id != 380 && Kernel.pbConfirmMessage("Refresh the map?\nThis may disrupt events and cause more damage then it fixes.")
    #        $game_switches[157] = true
    #            pbRemoveDependencies
    #        $game_map.refresh
    ###        $game_player.reserve_transfer($game_variables[44],$game_variables[45],$game_variables[46])
    #         end
    #       end
    $game_switches[90] = false
    #         Kernel.pbGetMegaStoneList
    if $Trainer != nil && $Trainer.party != nil && $Trainer.party[0] != nil
      for i in 0..$Trainer.party.length-1
        poke = $Trainer.party[i]
        if isConst?(poke.species,PBSpecies,:DELTADITTO) 
          poke.form=PBTypes::WATER
        elsif isConst?(poke.species,PBSpecies,:CASTFORM) ||
              isConst?(poke.species,PBSpecies,:CHERRIM) ||
              isConst?(poke.species,PBSpecies,:DARMANITAN) ||
              isConst?(poke.species,PBSpecies,:AEGISLASH) ||
              isConst?(poke.species,PBSpecies,:GRENINJA) ||
              isConst?(poke.species,PBSpecies,:FROGADIER) ||
              isConst?(poke.species,PBSpecies,:FROAKIE) ||
              isConst?(poke.species,PBSpecies,:KECLEON) ||
              isConst?(poke.species,PBSpecies,:KYOGRE) ||
              isConst?(poke.species,PBSpecies,:GROUDON) ||
              isConst?(poke.species,PBSpecies,:MELOETTA) ||
              isConst?(poke.species,PBSpecies,:DELTAEMOLGA) ||
              isConst?(poke.species,PBSpecies,:REGIGIGAS) ||
              (isConst?(poke.species,PBSpecies,:GIRATINA) && poke.form==2) ||
              (isConst?(poke.species,PBSpecies,:ARCEUS) && poke.form==19) ||
              (Kernel.pbGetArmorSpeciesList.include?(poke.species) && 
              !Kernel.pbGetArmorItemList.include?(poke.item)) ||
              (isConst?(poke.species,PBSpecies,:GARDEVOIR) && poke.form==1) || 
              (isConst?(poke.species,PBSpecies,:GARDEVOIR) && poke.form==3) ||
              (isConst?(poke.species,PBSpecies,:LUCARIO) && poke.form==1) || 
              (isConst?(poke.species,PBSpecies,:LUCARIO) && poke.form==3) ||
              (isConst?(poke.species,PBSpecies,:DELTATYPHLOSION) && !poke.form==0) ||
              (isConst?(poke.species,PBSpecies,:MEWTWO) && !isConst?(poke.item,PBItems,:MEWTWOMACHINE) && !poke.form==4) ||
              (isConst?(poke.species,PBSpecies,:TYRANITAR) && !isConst?(poke.item,PBItems,:TYRANITARMACHINE)) ||
              (isConst?(poke.species,PBSpecies,:FLYGON) && !isConst?(poke.item,PBItems,:FLYGONMACHINE)) ||
              (!isConst?(poke.species,PBSpecies,:GARDEVOIR) && !isConst?(poke.species,PBSpecies,:LUCARIO) && !isConst?(poke.species,PBSpecies,:MEWTWO) && !isConst?(poke.species,PBSpecies,:TYRANITAR) && 
              !isConst?(poke.species,PBSpecies,:FLYGON) && Kernel.pbGetMegaSpeciesList.include?(poke.species))
          if (isConst?(poke.species,PBSpecies,:GARDEVOIR) && (poke.form==3 || poke.form==2)) || 
             (isConst?(poke.species,PBSpecies,:LUCARIO) && (poke.form==3 || poke.form==2))
            poke.form=2
          elsif (isConst?(poke.species,PBSpecies,:MEWTWO) && (poke.form==4 || poke.form==5))
            poke.form=4
          else
            poke.form=0
          end
        end
      end
    end
=end
  if !$game_switches[582]
    $game_switches[582]=true
    $PokemonSystem.trainerdetection=1 if $PokemonSystem
  end
  
  #if Input.trigger?(Input::P)
  #  i=$PokemonGlobal.playerID+1
  #  $game_variables[122]=i
  #  $game_variables[182]=i
  #  $PokemonGlobal.playerID=i
  #  $game_variables[112]=i
  #  #Kernel.pbMessage(i.to_s)
  #  pbChangePlayer(i)
  #nd
  #   if Keys.press?(Keys::O)
  #     if Kernel.pbConfirmMessage("Are you sure you wish to remove your followers?")
  #     pbRemoveDependencies
  # end
  #         events=$PokemonGlobal.dependentEvents
  #   for i in 0...events.length
  #     if events[i] && events[i][8]=="Dependent"
  #         events[i][6]=sprintf("nil")
  #          @realEvents[i].character_name=sprintf("nil")
  #       $game_variables[Current_Following_Variable]=$Trainer.party[0]
  #       $game_variables[Walking_Time_Variable]=0
  #     end
  #   end
  # end
  if $game_switches[170] && !File::exists?(".boob.txt")
    File.new ".boob.txt","w"
  end
  if $game_switches[307] 
    File.new "Graphics/Icons/icon10b.txt","w" if !File::exists?("Graphics/Icons/icon10b.txt")
    $has_hacked=true
  end
  if $game_switches[356] || $game_variables[7]==0
    if $Trainer && $Trainer.party
      for i in 0..$Trainer.party.length-1
        if $game_switches[356] && $game_variables[7]>0 && $Trainer.party[i] != nil && $Trainer.party[i].obtainMode!=1 && !$Trainer.party[i].egg?
          $Trainer.party[i].name="Egg Token"
          $Trainer.party[i].hp=0
        elsif $game_variables[7]==0 && $Trainer.party[i].species==PBSpecies::MEW
          $Trainer.party[i].name="Mew"
          $Trainer.party[i].hp=$Trainer.party[i].totalhp
        end
      end
    end
  end
  if $game_variables[124] == nil || $game_variables[124] == 0
    $game_switches[407]=true
  end
  if $game_switches[406]
    $Trainer.party=$game_variables[124]
    $game_switches[406]=false
  end
  $tempCanHoopa=false
  Kernel.pbGetDependency("Dependent").lock if $PokemonTemp.dependentEvents && Kernel.pbGetDependency("Dependent") != nil
 
    
  shouldUseHeartSwap=false
  shouldUseHyperspaceHole=false
  shouldUseTesseract=false
  if File::exists?("Graphics/Icons/icon10b.txt")
    $game_switches[307]=true
    $has_hacked=true
  end
  if $game_switches[428] #reukra revent
    $game_switches[427]=true if $game_map.map_id != 181
  end
  if $has_hacked
    File.new "Graphics/Icons/icon10b.txt","w" if !File::exists?("Graphics/Icons/icon10b.txt")
    $game_switches[307]=true
  end
  #PokemonTemp.dependentEvents.check_sprite_follow
  $hold_it_faggot=nil
=begin
    if $game_variables[7] != 0 && $PokemonTemp != nil && $PokemonTemp.dependentEvents != nil
      $PokemonTemp.dependentEvents.refresh_sprite if !$game_switches[33] && $game_variables[39]==0
      if $game_variables[39]==2 && !$game_switches[62]
        case $game_variables[40]
        when 1
          Kernel.useShayminAbility 
        when 2
          Kernel.useRelicSong
        when 3
          shouldUseTesseract=true
        when 4
          shouldUseHeartSwap=true
        when 5
          shouldUseHyperspaceHole=true
        when 6
          Kernel.useDoomDesire
        when 7
          Kernel.useVCreate
        when 8
          pbWildBattle(PBSpecies::MEW,65,1,false,false)
        end
      elsif $game_switches[62] && $game_variables[39]==2
        $game_switches[62]=false
      end
      # Kernel.pbMessage($game_variables[39].to_s) if $game_variables[39]>0
      #  Kernel.pbMessage($game_variables[39].to_s)
      $game_variables[39]-= 1 if $game_variables[39]>0
    end
=end
  if $game_system.hm7 && @spriteset
    hm7_set_fading(0,0,255,1)
  end
  if $game_system.hm7 && ($game_map.map_id==676 || $game_map.map_id==749)
    showMap=0
    areas=$game_map.map_id==749 ? Kernel.getSoarAreasHolon : Kernel.getSoarAreas
    for map in areas
      if $game_player.x>map[1] && $game_player.x<map[3]
        if $game_player.y>map[2] && $game_player.y<map[4]
          showMap=map[0]
          break
        end
      end
    end
    if showMap>0
      begin
        map = pbLoadRxData("Data/MapInfos")
        return "" if !map
        $tempMap= map[showMap].name
      rescue
        $tempMap= ""
      end
      #  $tempMap=getMapNameFromId(showMap)
    else
      $tempMap=""
    end
  end
  if !$game_system.hm7
    if Input.trigger?(Input::Q)
      Input.updateKeyState(Keys::Q)
      unless pbMapInterpreterRunning?
        $PokemonTemp.keyItemCalling = true if $PokemonTemp
      end
    end
    if Input.trigger?(Input::W)
      Input.updateKeyState(Keys::W)
      unless pbMapInterpreterRunning?
        $PokemonTemp.keyItemCalling2 = true if $PokemonTemp
      end
    end
    if Input.trigger?(Input::E)
      Input.updateKeyState(Keys::E)
      unless pbMapInterpreterRunning?
        $PokemonTemp.keyItemCalling3 = true if $PokemonTemp
      end
    end
    if Input.trigger?(Input::T)
      Input.updateKeyState(Keys::T)
      unless pbMapInterpreterRunning?
        $PokemonTemp.keyItemCalling4 = true if $PokemonTemp
      end
    end
    if Input.trigger?(Input::U)
      Input.updateKeyState(Keys::Y)
      unless pbMapInterpreterRunning?
        $PokemonTemp.keyItemCalling5 = true if $PokemonTemp
      end
    end
  end
=begin
  if shouldUseHeartSwap
    Kernel.pbUseHeartSwap      
  end
  if shouldUseHyperspaceHole
    Kernel.pbUseHyperspaceHole      
  end
  if shouldUseTesseract
    Kernel.useTesseract      
  end
=end
  if $DEBUG and Input.press?(Input::F9)
    $game_temp.debug_calling = true
  end
  unless $game_player.moving?
    if $game_temp.battle_calling
      call_battle
    elsif $game_temp.shop_calling
      call_shop
    elsif $game_temp.name_calling
      call_name
    elsif $game_temp.menu_calling
      call_menu if !$game_switches[136]
    elsif $game_temp.dexnav_calling
      call_dexnav
    elsif $game_temp.save_calling
      call_save
    elsif $game_temp.debug_calling
      call_debug
    elsif $PokemonTemp && $PokemonTemp.keyItemCalling
      $PokemonTemp.keyItemCalling=false
      $game_player.straighten
      Kernel.pbUseKeyItem
    elsif $PokemonTemp && $PokemonTemp.keyItemCalling2
      $PokemonTemp.keyItemCalling2=false
      $game_player.straighten
      Kernel.pbUseKeyItem2
    elsif $PokemonTemp && $PokemonTemp.keyItemCalling3
      $PokemonTemp.keyItemCalling3=false
      $game_player.straighten
      Kernel.pbUseKeyItem3
    elsif $PokemonTemp && $PokemonTemp.keyItemCalling4
      $PokemonTemp.keyItemCalling4=false
      $game_player.straighten
      Kernel.pbUseKeyItem4
    elsif $PokemonTemp && $PokemonTemp.keyItemCalling5
      $PokemonTemp.keyItemCalling5=false
      $game_player.straighten
      Kernel.pbUseKeyItem5
    elsif $PokemonTemp && $PokemonTemp.hiddenMoveEventCalling
      $PokemonTemp.hiddenMoveEventCalling=false
      $game_player.straighten
      Events.onAction.trigger(self)
    end
  end
end

  def call_name
    $game_temp.name_calling = false
    $game_player.straighten
    $game_map.update
  end

  def call_menu
    $game_temp.menu_calling = false
    $game_player.straighten
    $game_map.update
    sscene=PokemonMenu_Scene.new
    sscreen=PokemonMenu.new(sscene) 
    sscreen.pbStartPokemonMenu
  end

  def call_dexnav
    $game_temp.dexnav_calling = false
    $game_player.straighten
    $game_map.update
#    sscene=Scene_DexNav.new
#    sscene.main
pbLoadRpgxpScene(Scene_DexNav.new,false)
       # cmdwindow.visible=true
       # cmdwindow.update
        Graphics.update
  end
  
  def call_debug
    $game_temp.debug_calling = false
    pbPlayDecisionSE()
    $game_player.straighten
    $scene = Scene_Debug.new
  end

  def autofade(mapid)
    playingBGM=$game_system.playing_bgm
    playingBGS=$game_system.playing_bgs
    return if !playingBGM && !playingBGS
    map=pbLoadRxData(sprintf("Data/Map%03d", mapid))
    if playingBGM && map.autoplay_bgm
      if playingBGM.name!=map.bgm.name
        pbBGMFade(0.8)
      end
    end
    if playingBGS && map.autoplay_bgs
      if playingBGS.name!=map.bgs.name
        pbBGMFade(0.8)
      end
    end
    Graphics.frame_reset
  end

  def transfer_player(cancelVehicles=true)
    $sb_is_placing=false
    now=pbGetTimeNow
    if PBDayNight.isNight?(now)
      $game_switches[664]=true
    else
      $game_switches[664]=false
    end
    # Mew switch for Deyraan Town
    if !Kernel.pbCheckForMew
      $game_switches[695]=true
    else
      $game_switches[695]=false
    end
    # Delta Wooper time-based switches
    if !$game_switches[684]
      if now.hour<6
        $game_switches[680]=true
      else
        $game_switches[680]=false
        $game_switches[682]=false
      end
    end
    # More Delta Wooper switches
    if $game_switches[680] && $game_variables[190]>0 && !$game_switches[681] &&
       !$game_switches[684]
      $game_switches[682]=true
    end
    $game_temp.player_transferring = false
    if cancelVehicles
      Kernel.pbCancelVehicles($game_temp.player_new_map_id)
    end
    autofade($game_temp.player_new_map_id)
    pbBridgeOff
    if $game_map.map_id != $game_temp.player_new_map_id
      $MapFactory.setup($game_temp.player_new_map_id)
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    case $game_temp.player_new_direction
      when 2
        $game_player.turn_down
      when 4
        $game_player.turn_left
      when 6
        $game_player.turn_right
      when 8
        $game_player.turn_up
    end
    $game_player.straighten
    $game_map.update
    disposeSpritesets
    GC.start
    createSpritesets
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition(20)
    end
    $game_map.autoplay
    Graphics.frame_reset
    Input.update
    $PokemonTemp.dependentEvents.refresh_sprite
  end
end