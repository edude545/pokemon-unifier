=begin
#==============================================================================
# ** Lemony's Always Update Events, 29/01/13, v.1.0.
#------------------------------------------------------------------------------
#  Allows to indicate which events will always update their move routes by
# placing a comment with "LAUE Update" in them.
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Update During Autonomous Movement Alias
  #--------------------------------------------------------------------------
 # alias laue_update_self_movement update_self_movement
  #--------------------------------------------------------------------------
  # * Update During Autonomous Movement
  #--------------------------------------------------------------------------
  def update_self_movement
    if !@laue_event
      @laue_event = false
      @list.each {|i| 
      if [108, 408].include?(i.code) && i.parameters[0].include?("LAUE Update")
        @laue_event = true
        break
      end}
    end
    if @laue_event
      if @stop_count > stop_count_threshold
        case @move_type
        when 1 then move_type_random
        when 2 then move_type_toward_player
        when 3 then move_type_custom
        end
      end
      return
    end
    laue_update_self_movement
  end
  
    def laue_update_self_movement
    if !@laue_event
      @laue_event = false
      @list.each {|i| 
      if [108, 408].include?(i.code) && i.parameters[0].include?("LAUE Update")
        @laue_event = true
        break
      end}
    end
    if @laue_event
      if @stop_count > stop_count_threshold
        case @move_type
        when 1 then move_type_random
        when 2 then move_type_toward_player
        when 3 then move_type_custom
        end
      end
      return
    end
    update_self_movement
  end

end
=end