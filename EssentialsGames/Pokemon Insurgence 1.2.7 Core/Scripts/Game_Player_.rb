#===============================================================================
# ** Game_Player
#-------------------------------------------------------------------------------
#  This class handles the player. Its functions include event starting
#  determinants and map scrolling. Refer to "$game_player" for the one
#  instance of this class.
#===============================================================================
class Game_Player < Game_Character
  attr_accessor :bump_se
  CENTER_X = (320 - 16) * 4   # Center screen x-coordinate * 4
  CENTER_Y = (240 - 16) * 4   # Center screen y-coordinate * 4
  def map
    @map=nil
    return $game_map
  end

  def initialize(*arg)
    super(*arg)
    @lastdir=0
    @lastdirframe=0
    @bump_se=0
  end

  def pbHasDependentEvents?
    return $PokemonGlobal.dependentEvents.length>0   
  end

  def move_down(turn_enabled = true)
    if turn_enabled
      turn_down
    end
    if passable?(@x, @y, 2)
      return if pbLedge(0,1)
      return if pbEndSurf(0,1)
      turn_down
      @y += 1
      $PokemonTemp.dependentEvents.pbMoveDependentEvents
      increase_steps
    else
      if !check_event_trigger_touch(@x, @y+1)
        if !@bump_se || @bump_se<=0
if $game_switches[186] 
            pbSEPlay("bump"); @bump_se=10
          end        end
      end
    end
  end

  def move_left(turn_enabled = true)
    if turn_enabled
      turn_left
    end
    if passable?(@x, @y, 4)
      return if pbLedge(-1,0)
      return if pbEndSurf(-1,0)
      turn_left
      @x -= 1
      $PokemonTemp.dependentEvents.pbMoveDependentEvents
      increase_steps
    else
      if !check_event_trigger_touch(@x-1, @y)
        if !@bump_se || @bump_se<=0
          if $game_switches[186] 
            pbSEPlay("bump"); @bump_se=10
          end
          
        end
      end
    end
  end

  def move_right(turn_enabled = true)
    if turn_enabled
      turn_right
    end
    if passable?(@x, @y, 6)
      return if pbLedge(1,0)
      return if pbEndSurf(1,0)
      turn_right
      @x += 1
      $PokemonTemp.dependentEvents.pbMoveDependentEvents
      increase_steps
    else
      if !check_event_trigger_touch(@x+1, @y)
        if !@bump_se || @bump_se<=0
if $game_switches[186] 
            pbSEPlay("bump"); @bump_se=10
          end        end
      end
    end
  end

  def move_up(turn_enabled = true)
    if turn_enabled
      turn_up
    end
    if passable?(@x, @y, 8)
      return if pbLedge(0,-1)
      return if pbEndSurf(0,-1)
      turn_up
      @y -= 1
      $PokemonTemp.dependentEvents.pbMoveDependentEvents
      increase_steps
    else
      if !check_event_trigger_touch(@x, @y-1)
        if !@bump_se || @bump_se<=0
if $game_switches[186] 
            pbSEPlay("bump"); @bump_se=10
          end        end
      end
    end
  end

  def pbTriggeredTrainerEvents(triggers,checkIfRunning=true)
    result = []
    # If event is running
    if checkIfRunning && $game_system.map_interpreter.running?
      return result
    end
    ### FIX FOR PYRAMID ###
    darkenScreenIfNecessary
    # All event loops
    $game_switches[451]=false
    $game_switches[651]=false
    for event in $game_map.events.values
      $game_variables[52]=Array.new if !$game_variables[52].is_a?(Array)
      next if !event.name[/^Trainer\((\d+)\)$/] && !event.name[/^Angry\((\d+)\)$/] && !event.name[/^Nervous\((\d+)\)$/] && !event.name[/^Sleepy\((\d+)\)$/] && !event.name[/^Romantic\((\d+)\)$/] 
      next if $game_variables[52].include?(event.id)
      distance=$~[1].to_i
      # If event coordinates and triggers are consistent
      if pbEventCanReachPlayer?(event,self,distance) and triggers.include?(event.trigger)
          # If starting determinant is front event (other than jumping)
        if not event.jumping? and not event.over_trigger? #and not $PokemonGlobal.surfing
          #Kernel.pbMessage("1")
          result.push(event)
        end
      end
      #Kernel.pbMessage(_INTL("{1}",event.character_name))
      if (pbEventCanReachPlayerNextOver?(event,self,distance) and event.character_name!="" and (!$game_self_switches[[$game_map.map_id,event.id,"A"]] &&
         !$game_self_switches[[$game_map.map_id,event.id,"B"]] && !$game_self_switches[[$game_map.map_id,event.id,"C"]] &&
         !$game_self_switches[[$game_map.map_id,event.id,"D"]])) or result.length>0     
          $game_switches[451]=true
          checkswitch=false
          #for poke in $Trainer.party
          #  checkswitch=true if pbHasMove?(poke,PBMoves::HYPNOSIS)
          #  checkswitch=true if pbHasMove?(poke,PBMoves::SLEEPPOWDER)
          #  checkswitch=true if pbHasMove?(poke,PBMoves::GRASSWHISTLE)
          #  checkswitch=true if pbHasMove?(poke,PBMoves::SING)
          #  checkswitch=true if pbHasMove?(poke,PBMoves::SPORE)
          #end #soscrewed
          if checkswitch && event.name[/^Sleepy\((\d+)\)$/]
            $game_switches[651]=true
            character = pbMapInterpreter.get_character(event.id)
            if character != nil
              # Set animation ID
              character.animation_id = 11
            end
          else
            $game_switches[651]=false
          end
      else

    #    $game_switches[451]=false
      end
    end
    darkenScreenIfNecessary
    return result
  end

  def darkenScreenIfNecessary
    if ($game_switches[7] && $game_map.map_id==184) || $game_switches[704]
      return nil
    end
    
    if $game_switches[451] && $PokemonSystem.trainerdetection==1
      imgname="trainer_prebattle_warning"
      if $game_screen && $game_screen.pictures && ($game_screen.pictures[22].opacity >= 255 || $game_screen.pictures[22].opacity <= 0)
        $game_screen.pictures[22].show(imgname, 0,
         0, 0, 100, 100, 0, 0) 
         
      end       
    else
      $game_screen.pictures[22].erase if $game_screen && $game_screen.pictures && $game_screen.pictures[22].opacity <= 0 
    end
    
  end
    
  
  def pbTriggeredCounterEvents(triggers,checkIfRunning=true)
    result = []
    # If event is running
    if checkIfRunning && $game_system.map_interpreter.running?
      return result
    end
    # All event loops
    for event in $game_map.events.values
      next if !event.name[/^Counter\((\d+)\)$/]
      distance=$~[1].to_i
      # If event coordinates and triggers are consistent
      if pbEventFacesPlayer?(event,self,distance) and triggers.include?(event.trigger)
          # If starting determinant is front event (other than jumping)
        if not event.jumping? and not event.over_trigger?
          result.push(event)
        end
      end
    end
    return result
  end

  def pbCheckEventTriggerAfterTurning
  end

  def pbCheckEventTriggerFromDistance(triggers)
    ret=pbTriggeredTrainerEvents(triggers)
    ret.concat(pbTriggeredCounterEvents(triggers))
    return false if ret.length==0
    for event in ret
      event.start
    end
    return true
  end

  def pbFacingEvent
    if $game_system.map_interpreter.running?
      return nil
    end
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    for event in $game_map.events.values
      if event.x == new_x and event.y == new_y
        if not event.jumping? and not event.over_trigger?
          return event
        end
      end
    end
    if $game_map.counter?(new_x, new_y)
      new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
      new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
      for event in $game_map.events.values
        if event.x == new_x and event.y == new_y
          if not event.jumping? and not event.over_trigger?
            return event
          end
        end
      end
    end
    return nil
  end
  #-----------------------------------------------------------------------------
  # * Passable Determinants
  #     x : x-coordinate
  #     y : y-coordinate
  #     d : direction (0,2,4,6,8)
  #         * 0 = Determines if all directions are impassable (for jumping)
  #-----------------------------------------------------------------------------
  def passable?(x, y, d)
    # Get new coordinates
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # If coordinates are outside of map
    unless $game_map.validLax?(new_x, new_y)
      # Impassable
      return false
    end
    if !$game_map.valid?(new_x, new_y)
      return false if !$MapFactory
      return $MapFactory.isPassableFromEdge?(new_x, new_y)
    end
    # If debug mode is ON and ctrl key was pressed
    if $DEBUG and Input.press?(Input::CTRL)
      # Passable
      return true
    end
    super
  end
  #-----------------------------------------------------------------------------
  # * Set Map Display Position to Center of Screen
  #-----------------------------------------------------------------------------
  def center(x, y)
    # X coordinate in the center of the screen
    center_x = (Graphics.width/2 - Game_Map::TILEWIDTH/2) * Game_Map::XSUBPIXEL 
    # Y coordinate in the center of the screen   
    center_y = (Graphics.height/2 - Game_Map::TILEHEIGHT/2) * Game_Map::YSUBPIXEL
    max_x = (self.map.width - Graphics.width*1.0/Game_Map::TILEWIDTH) * Game_Map.realResX
    max_y = (self.map.height - Graphics.height*1.0/Game_Map::TILEHEIGHT) * Game_Map.realResY
    dispx=x * Game_Map.realResX - center_x
    dispy=y * Game_Map.realResY - center_y
    self.map.display_x = dispx
    self.map.display_y = dispy
  end
  #-----------------------------------------------------------------------------
  # * Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  #-----------------------------------------------------------------------------
  def moveto(x, y)
    super
    # Centering
    center(x, y)
    # Make encounter count
    make_encounter_count
  end
  #-----------------------------------------------------------------------------
  # * Get Encounter Count
  #-----------------------------------------------------------------------------
  def encounter_count
    return @encounter_count
  end
  #-----------------------------------------------------------------------------
  # * Make Encounter Count
  #-----------------------------------------------------------------------------
  def make_encounter_count
    # Image of two dice rolling
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end
  #-----------------------------------------------------------------------------
  # * Refresh
  #-----------------------------------------------------------------------------
  def refresh
    @opacity = 255
    @blend_type = 0
  end
  #-----------------------------------------------------------------------------
  # * Same Position Starting Determinant
  #-----------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end
    # All event loops
    for event in $game_map.events.values
      # If event coordinates and triggers are consistent
      if event.x == @x and event.y == @y and triggers.include?(event.trigger)
        # If starting determinant is same position event (other than jumping)
        if not event.jumping? and event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #-----------------------------------------------------------------------------
  # * Front Event Starting Determinant
  #-----------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end
    # Calculate front event coordinates
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    # All event loops
    for event in $game_map.events.values
      # If event coordinates and triggers are consistent
      if event.x == new_x and event.y == new_y and
         triggers.include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        if not event.jumping? and (!event.over_trigger?)
          event.start
          result = true
        end
      end
    end
    # If fitting event is not found
    if result == false
      # If front tile is a counter
      if $game_map.counter?(new_x, new_y)
        # Calculate 1 tile inside coordinates
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        # All event loops
        for event in $game_map.events.values
          # If event coordinates and triggers are consistent
          if event.x == new_x and event.y == new_y and
             triggers.include?(event.trigger)
            # If starting determinant is front event (other than jumping)
            if not event.jumping? and (!event.over_trigger?)
              event.start
              result = true
            end
          end
        end
      end
    end
    return result
  end
  #-----------------------------------------------------------------------------
  # * Touch Event Starting Determinant
  #-----------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end
    # All event loops
    for event in $game_map.events.values
      if event.name[/^Trainer\((\d+)\)$/]
        distance=$~[1].to_i
        next if !pbEventCanReachPlayer?(event,self,distance)
      end
      if event.name[/^Counter\((\d+)\)$/]
        distance=$~[1].to_i
        next if !pbEventFacesPlayer?(event,self,distance)
      end
      # If event coordinates and triggers are consistent
      if event.x == x and event.y == y and [1,2].include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    # Remember whether or not moving in local variables
    last_moving = moving?
    # If moving, event running, move route forcing, and message window
    # display are all not occurring
    dir=Input.dir4
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing or
           $PokemonTemp.miniupdate
      # Move player in the direction the directional button is being pressed
      if dir==@lastdir && Graphics.frame_count-@lastdirframe>2
        case dir
          when 2
            move_down
          when 4
            move_left
          when 6
            move_right
          when 8
            move_up
        end
      elsif dir!=@lastdir
        case dir
          when 2
            turn_down
          when 4
            turn_left
          when 6
            turn_right
          when 8
            turn_up
        end
      end
    end
    $PokemonTemp.dependentEvents.updateDependentEvents
    $PokemonTemp.dependentEvents.add_following_time
    if dir!=@lastdir
      @lastdirframe=Graphics.frame_count
    end
    @lastdir=dir
    # Remember coordinates in local variables
    last_real_x = @real_x
    last_real_y = @real_y
    super
    center_x = (Graphics.width/2 - Game_Map::TILEWIDTH/2) * 
              Game_Map::XSUBPIXEL   # Center screen x-coordinate * 4
    center_y = (Graphics.height/2 - Game_Map::TILEHEIGHT/2) * 
              Game_Map::YSUBPIXEL   # Center screen y-coordinate * 4
    # If character moves down and is positioned lower than the center
    # of the screen
    if @real_y > last_real_y and @real_y - $game_map.display_y > center_y
      # Scroll map down
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # If character moves left and is positioned more left on-screen than
    # center
    if @real_x < last_real_x and @real_x - $game_map.display_x < center_x
      # Scroll map left
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # If character moves right and is positioned more right on-screen than
    # center
    if @real_x > last_real_x and @real_x - $game_map.display_x > center_x
      # Scroll map right
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # If character moves up and is positioned higher than the center
    # of the screen
    if @real_y < last_real_y and @real_y - $game_map.display_y < center_y
      # Scroll map up
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # Count down the time between allowed bump sounds
    @bump_se-=1 if @bump_se && @bump_se>0
    # If not moving
    unless moving?
      # If player was moving last time
      if last_moving
        $PokemonTemp.dependentEvents.pbTurnDependentEvents
        result = pbCheckEventTriggerFromDistance([2])
        # Event determinant is via touch of same position event
        #Grimer
        result |= check_event_trigger_here([1,2])
        # If event which started does not exist
        Kernel.pbOnStepTaken(result) # *Added function call
      end
      # If C button was pressed
      if Input.trigger?(Input::C) && !$PokemonTemp.miniupdate
        if $sb_is_placing==true
          tempx = $game_player.x
          tempy = $game_player.y
          case $game_player.direction
                when 2
                  tempy += 1
                when 4
                  tempx -= 1
                when 6
                  tempx += 1
                when 8
                  tempy -= 1
                end
            tempvar = false
            for i in 1..100
              if $game_map.events[i].x==tempx && $game_map.events[i].y==tempy
                tempvar=true
              end
            end              
             if !$game_map.passable?(tempx,tempy,$game_player.direction) || tempvar
               Kernel.pbMessage("Cannot place object there.")
               
             else
          for i in 1..100
            if !$game_variables[78].is_a?(Array)
              $game_variables[78]=Array.new
            end
            if !$game_variables[78][i].is_a?(Array)
              $game_variables[78][i]=Array.new
            end
           if !$game_variables[76].is_a?(Array)
              $game_variables[76]=Array.new
            end
            if !$game_variables[76][i].is_a?(Array)
              $game_variables[76][i]=Array.new
            end

            if $game_variables[78][i][0]!= true
              #$game_map.events[i]
              $game_variables[78][i][2]=Kernel.getFileNameForUpgrade($sb_what_upgrade)
              $game_variables[76][i][2]=Kernel.getFileNameForUpgrade($sb_what_upgrade)

          #    Kernel.pbMessage($game_variables[78][i][2].to_s)
              $game_map.events[i].character_name=$game_variables[78][i][2]
              $game_map.events[i].character_name=$game_variables[76][i][2]
         #     Kernel.pbMessage($game_map.events[i].character_name.to_s)
             placex = $game_player.x
              placey = $game_player.y
              case $game_player.direction
                when 2
                  placey += 1
                when 4
                  placex -= 1
                when 6
                  placex += 1
                when 8
                  placey -= 1
                end
              $game_variables[78][i][1]=$sb_what_upgrade
              $game_variables[78][i][3]=placex#$game_player.x        
              $game_variables[78][i][4]=placey#$game_player.y 
              $game_variables[76][i][1]=$sb_what_upgrade
              $game_variables[76][i][3]=placex#$game_player.x        
              $game_variables[76][i][4]=placey#$game_player.y   

         #     placex += 1 if $game_player.direction == 6
         #     placey += 1 if $game_player.direction == 2
         #     placex -= 1 if $game_player.direction == 4
         #     placey -= 1 if $game_player.direction == 8
              $game_map.events[i].moveto(placex,placey)    
              $game_map.events[i].turn_toward_player
              $game_variables[78][i][5]=$game_map.events[i].direction
      $game_map.events[i].trigger=1 
       
              if Kernel.isWalkOnSB.include?($sb_what_upgrade)
                $game_map.events[i].through=true
                $game_map.events[i].trigger=1
              else
                $game_map.events[i].through=false
                $game_map.events[i].trigger=0
              end
              
              $game_map.events[i].opacity=255
              $game_map.events[i].transparent=false
                  $game_variables[78][i][0] = true
                  $game_variables[76][i][0] = true
              $game_map.events[i].refresh
              $game_map.need_refresh=true
              $game_map.update
              $game_switches[368]=true
             $sb_is_placing=false
             if Kernel.pbConfirmMessage("Would you like to place another?")
              $sb_is_placing=true
              $sb_what_upgrade=$game_variables[78][i][1]
           #   $sb_previous_event=previousevent
              $sb_is_deleting=false
             end
             
             break
           end
         end
         
          end
        end
      
      #  def startSBPlacement(upgradeid,previousevent=nil)
   #     $sb_is_placing=true
  #      $sb_what_upgrade=upgradeid
 # $sb_previous_event=previousevent
        #en d
        # Same position and front event determinant
        check_event_trigger_here([0])
        check_event_trigger_there([0,2]) # *Modified to prevent unnecessary triggers
      end
    end
  end
end