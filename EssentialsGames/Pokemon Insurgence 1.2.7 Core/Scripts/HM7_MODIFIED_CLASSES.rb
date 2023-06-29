#============================================================================
# H-Mode7 Engine
# V.1.2.1 - 15/05/2011
# Author : MGC (MGCaladtogel)
#
# Modified classes
#============================================================================
#============================================================================
# ** RPG::MapInfo
#============================================================================
class RPG::MapInfo
  # defines the map's name as the name without anything within brackets,
  # including brackets
  def name
    return @name.gsub(/\[.*\]/) {""}
  end
  #--------------------------------------------------------------------------
  # the original name with the codes
  def full_name
    return @name
  end
end

#============================================================================
# ** Game_System
#============================================================================
class Game_System
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  unless @already_aliased_hm7
    alias initialize_hm7_game_system initialize
    @already_aliased_hm7 = true
  end
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :hm7 # true : enable H-Mode7
  attr_accessor :hm7_loop_x # true : horizontal map looping
  attr_accessor :hm7_loop_y # true : vertical map looping
  attr_accessor :hm7_animated # true : animated autotiles for HM7 maps
  attr_accessor :hm7_lighting # true : automatic lighting effects
  attr_accessor :hm7_alpha # angle of slant (in degree)
  attr_accessor :hm7_theta # angle of rotation (in degree)
  attr_accessor :hm7_horizon # horizon's distance
  attr_accessor :hm7_resolution # 1:max, 2:med, 3:low
  attr_accessor :hm7_filter # true : enable filter (increase perf., blurry when moving)
  attr_accessor :hm7_pivot # screenline's number of the slant/rotation pivot
  attr_accessor :hm7_zoom # zoom level (percentage, 100 = no zoom)
  attr_accessor :hm7_two_frames_refresh # true = refresh map all the two frames
  attr_accessor :hm7_camera_mode # 0:max, 1-2:change altitude depending of the ground's heights
  attr_accessor :hm7_anim_freq # autotiles animations period (default : 20 frames)
  attr_accessor :hm7_heightmap # heightmap filename
  attr_accessor :hm7_fading_color # light fading color for the horizon
  attr_accessor :hm7_less_cut # less cut elements at the bottom of the screen (V.1.2.1)
  attr_accessor :hm7_no_black_cut # no black for cut elements at the bottom of the screen (V.1.2.1)
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    initialize_hm7_game_system
    self.hm7 = false
    self.hm7_horizon = 960
    hm7_reset
  end
  #--------------------------------------------------------------------------
  # * Reset zoom and pivot
  #--------------------------------------------------------------------------
  def hm7_reset
    if !self.hm7_horizon
      self.hm7 = false
      self.hm7_horizon = 960
    end
  
    self.hm7_pivot = 240
    self.hm7_zoom = 80
    self.hm7_alpha = 0
    self.hm7_theta = 0
    self.hm7_loop_x = false
    self.hm7_loop_y = false
    self.hm7_animated = true
    self.hm7_lighting = true
    self.hm7_resolution = 1
    self.hm7_filter = true
    self.hm7_two_frames_refresh = false
    self.hm7_camera_mode = 0
    self.hm7_anim_freq = 20
    self.hm7_heightmap = ""
    self.hm7_fading_color = Color.new(150, 150, 150, 0)
    self.hm7_less_cut = false # V.1.2.1
    self.hm7_no_black_cut = false # V.1.2.1
  end
end

#============================================================================
# ** Game_Temp
#============================================================================
class Game_Temp
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  unless @already_aliased_hm7
    alias initialize_hm7_game_temp initialize
    @already_aliased_hm7 = true
  end
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :pivot # screenline's number of the pivot
  attr_accessor :pivot_map # same as pivot (depend of resolution)
  attr_accessor :hm7_height_limit # horizon
  attr_accessor :distance_h # distance between the center of the map (halfwidth, pivot) and the point of view
  attr_accessor :slope_value # intermediate value used to calculate x-coordinate
  attr_accessor :slope_value_map # same as slope_value (depend of resolution) (* 262144)
  attr_accessor :corrective_value # intermediate value used to calculate x-coordinate
  attr_accessor :corrective_value_map # same as corrective_value (depend of resolution) (* 262144)
  attr_accessor :cos_alpha # cosinus of the angle of slant (* 2048)
  attr_accessor :sin_alpha # sinus of the angle of slant (* 2048)
  attr_accessor :cos_theta # cosinus of the angle of rotation (* 2048)
  attr_accessor :sin_theta # sinus of the angle of rotation (* 2048)
  attr_accessor :distance_p # distance between the center of the map (halfwidth, pivot) and the projection plane surface
  attr_accessor :zoom_map # zoom level (map) (percentage * 4096)
  attr_accessor :zoom_sprites # same as zoom_map (ratio)
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    initialize_hm7_game_temp
    self.pivot = 0
    self.pivot_map = 0
    self.hm7_height_limit = 0
    self.distance_h = 0
    self.slope_value = 0.0
    self.slope_value = 0
    self.corrective_value = 0.0
    self.corrective_value_map = 0
    self.cos_alpha = 0
    self.sin_alpha = 0
    self.cos_theta = 0
    self.sin_theta = 0
    self.distance_p = 0
    self.zoom_map = 1
    self.zoom_sprites = 1.0
  end
end

#============================================================================
# ** Game_Map
#============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  unless @already_aliased_hm7
    alias scroll_down_hm7_game_map scroll_down
    alias scroll_left_hm7_game_map scroll_left
    alias scroll_right_hm7_game_map scroll_right
    alias scroll_up_hm7_game_map scroll_up
    alias valid_hm7_game_map? valid?
    alias passable_hm7_game_map? passable?
    alias setup_hm7_game_map setup
    @already_aliased_hm7 = true
  end
  #--------------------------------------------------------------------------
  # * Scroll Down
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    unless $game_system.hm7
      scroll_down_hm7_game_map(distance)
      return
    end
    # V.1.1 : integer values for better compatibility
    @display_y = @display_y + distance.to_i
  end
  #--------------------------------------------------------------------------
  # * Scroll Left
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    unless $game_system.hm7
      scroll_left_hm7_game_map(distance)
      return
    end
    # V.1.1 : integer values for better compatibility
    @display_x = @display_x - distance.to_i
  end
  #--------------------------------------------------------------------------
  # * Scroll Right
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    unless $game_system.hm7
      scroll_right_hm7_game_map(distance)
      return
    end
    # V.1.1 : integer values for better compatibility
    @display_x = @display_x + distance.to_i
  end
  #--------------------------------------------------------------------------
  # * Scroll Up
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    unless $game_system.hm7
      scroll_up_hm7_game_map(distance)
      return
    end
    # V.1.1 : integer values for better compatibility
    @display_y = @display_y - distance.to_i
  end
  #--------------------------------------------------------------------------
  # * Determine Valid Coordinates
  #     x          : x-coordinate
  #     y          : y-coordinate
  #--------------------------------------------------------------------------
  def valid?(x, y)
    unless $game_system.hm7
      return (valid_hm7_game_map?(x, y))
    end
    unless $game_system.hm7_loop_x || x >= 0 && x < width
      return false
    end
    unless $game_system.hm7_loop_y || y >= 0 && y < height
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x          : x-coordinate
  #     y          : y-coordinate
  #     d          : direction (0,2,4,6,8,10)
  #                  *  0,10 = determine if all directions are impassable
  #     self_event : Self (If event is determined passable)
  #--------------------------------------------------------------------------
  def passable?(x, y, d, self_event = nil)
    unless $game_system.hm7
      return (passable_hm7_game_map?(x, y, d, self_event))
    end
    unless valid?(x, y)
      return false
    end
    bit = (1 << (d / 2 - 1)) & 0x0f
    for event in events.values
      if event.tile_id >= 0 and event != self_event and
         event.x == x and event.y == y and not event.through
        if @passages[event.tile_id] & bit != 0
          return false
        elsif @passages[event.tile_id] & 0x0f == 0x0f
          return false
        elsif @priorities[event.tile_id] == 0
          return true
        end
      end
    end
    for i in [2, 1, 0]
      tile_id = data[x % width, y % height, i] # handle map looping
      if tile_id == nil
        return false
      elsif @passages[tile_id] & bit != 0
        return false
      elsif @passages[tile_id] & 0x0f == 0x0f
        return false
      elsif @priorities[tile_id] == 0
        return true
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Setup
  #     map_id : map ID
  #--------------------------------------------------------------------------
  def setup(map_id)
    setup_hm7_game_map(map_id)
    if width > 200 || height > 200
      return
    end
    map_data = HM7::Data_Maps[$game_map.map_id]
    for keyword in HM7::Maps_Settings.keys
      if map_data.full_name.include?(keyword)
        $game_system.hm7 = true
        $game_system.hm7_reset
        command_list = HM7::Maps_Settings[keyword]
        $game_system.hm7_loop_x = command_list.include?("X")
        $game_system.hm7_loop_y = command_list.include?("Y")
        $game_system.hm7_animated = !command_list.include?("DA")
        $game_system.hm7_lighting = !command_list.include?("DL")
        $game_system.hm7_filter = !command_list.include?("DF")
        $game_system.hm7_two_frames_refresh = command_list.include?("HF")
        $game_system.hm7_less_cut = command_list.include?("E") # V.1.2.1
        $game_system.hm7_no_black_cut = command_list.include?("DB") # V.1.2.1
        for command in command_list
          if command.include?("R")
            $game_system.hm7_resolution = command[/\d+/].to_i
            $game_system.hm7_resolution = [[$game_system.hm7_resolution, 1].max, 3].min
          end
          if command.include?("HMAP")
            $game_system.hm7_heightmap = sprintf("Heightmap_%03d", command[/\d+/].to_i)
          end
          if command.include?("#")
            $game_system.hm7_alpha = command[/\d+/].to_i
            $game_system.hm7_alpha = [[$game_system.hm7_alpha, 0].max, 80].min
          end
          if command.include?("%")
            $game_system.hm7_theta = command[/\d+/].to_i
            $game_system.hm7_theta = [[$game_system.hm7_theta, 0].max, 359].min
          end
          if command.include?("C")
            $game_system.hm7_camera_mode = command[/\d+/].to_i
            $game_system.hm7_camera_mode = [[$game_system.hm7_theta, 0].max, 2].min
          end
          if command.include?("AF")
            $game_system.hm7_anim_freq = command[/\d+/].to_i
            if $game_system.hm7_anim_freq == 0
              $game_system.hm7_anim_freq = 20
            end
            $game_system.hm7_anim_freq = [[$game_system.hm7_anim_freq, 1].max, 999].min
          end
        end
        return
      end
    end
    $game_system.hm7 = map_data.full_name.include?("[HM7]")
    $game_system.hm7_reset
    $game_system.hm7_loop_x = map_data.full_name.include?("[X]")
    $game_system.hm7_loop_y = map_data.full_name.include?("[Y]")
    $game_system.hm7_animated = !map_data.full_name.include?("[DA]")
    $game_system.hm7_lighting = !map_data.full_name.include?("[DL]")
    $game_system.hm7_filter = !map_data.full_name.include?("[DF]")
    $game_system.hm7_two_frames_refresh = map_data.full_name.include?("[HF]")
    $game_system.hm7_less_cut = map_data.full_name.include?("[E]") # V.1.2.1
    $game_system.hm7_no_black_cut = map_data.full_name.include?("[DB]") # V.1.2.1
    if $game_system.hm7
      map_data.full_name =~ /\[R(\d+)\]/i
      $game_system.hm7_resolution = $1.to_i
      $game_system.hm7_resolution = [[$game_system.hm7_resolution, 1].max, 3].min
      map_data.full_name =~ /\[HMAP(\d+)\]/i
      if $1.to_i > 0
        $game_system.hm7_heightmap = sprintf("Heightmap_%03d", $1.to_i)
      end
      map_data.full_name =~ /\[#(\d+)\]/i
      $game_system.hm7_alpha = $1.to_i
      $game_system.hm7_alpha = [[$game_system.hm7_alpha, 0].max, 80].min
      map_data.full_name =~ /\[%(\d+)\]/i
      $game_system.hm7_theta = $1.to_i
      $game_system.hm7_theta = [[$game_system.hm7_theta, 0].max, 359].min
      map_data.full_name =~ /\[C(\d+)\]/i
      $game_system.hm7_camera_mode = $1.to_i
      $game_system.hm7_camera_mode = [[$game_system.hm7_camera_mode, 0].max, 2].min
      map_data.full_name =~ /\[AF(\d+)\]/i
      $game_system.hm7_anim_freq = $1.to_i
      if $game_system.hm7_anim_freq == 0
        $game_system.hm7_anim_freq = 20
      end
      $game_system.hm7_anim_freq = [[$game_system.hm7_anim_freq, 1].max, 999].min
    end
  end
end

#============================================================================
# ** Game_Character
#============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  unless @already_aliased_hm7
    alias initialize_hm7_game_character initialize
    alias update_hm7_game_character update
    # V.1.1 : jump command
    alias screen_y_hm7_game_character screen_y
    @already_aliased_hm7 = true
  end
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :x, :y, :real_x, :real_y
  attr_accessor :altitude # vertical offset
  attr_accessor :floating # altitude doesn't depend on the ground heights
  attr_accessor :map_number_x # map's number with X-looping
  attr_accessor :map_number_y # map's number with Y-looping
  # V.1.1 : 8-directions graphics
  attr_accessor :directions # nummber of directions for the associated graphics
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(map=nil)
    initialize_hm7_game_character(map)
    self.altitude = 0
    self.floating = false
    self.map_number_x = 0
    self.map_number_y = 0
    # V.1.1 : 8-directions graphics
    self.directions = 4
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    unless $game_system.hm7
      update_hm7_game_character
      return
    end
    # if x-coordinate is out of the map
    unless x.between?(0, $game_map.width - 1)
      # V.1.1 : integer values for better compatibility
      difference = (x << 7) - real_x.to_i
      if self.is_a?(Game_Player)
        # increase or decrease map's number
        self.map_number_x = 0 if !self.map_number_x
        self.map_number_x += difference / difference.abs
      end
      # x-coordinate is equal to its equivalent in the map
      self.x %= $game_map.width
      self.real_x = (x << 7) - difference
    end
    # if y-coordinate is out of the map
    unless y.between?(0, $game_map.height - 1)
      # V.1.1 : integer values for better compatibility
      difference = (y << 7) - real_y.to_i
      if self.is_a?(Game_Player)
        # increase or decrease map's number
        self.map_number_y = 0 if !self.map_number_y
        self.map_number_y += difference / difference.abs
      end
      # y-coordinate is equal to its equivalent in the map
      self.y %= $game_map.height
      self.real_y = (y << 7) - difference
    end
    update_hm7_game_character
  end
  #--------------------------------------------------------------------------
  # * Screen Y
  # V.1.1 : jump command
  #--------------------------------------------------------------------------
  def screen_y
    unless $game_system.hm7
      return screen_y_hm7_game_character
    end
    return (@real_y - $game_map.display_y + 3) / 4 + 32
  end
  #--------------------------------------------------------------------------
  # * Get Altitude
  # V.1.1 : jump command
  #--------------------------------------------------------------------------
  def get_altitude
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    if !self.altitude
          self.altitude = 0
    self.floating = false

    end
    
    return self.altitude + (@jump_peak * @jump_peak - n * n << 1)
  end
end

#============================================================================
# ** Game_Event
#============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  unless @already_aliased_hm7
    alias refresh_hm7_game_character refresh
    @already_aliased_hm7 = true
  end
  #--------------------------------------------------------------------------
  # * scan the event's commands list
  #     page : the scanned page (RPG::Event::Page)
  #--------------------------------------------------------------------------
  def check_commands(page)
    self.altitude = 0
    self.floating = false
    command_list = page.list
    for k in 0..command_list.length - 2
      command = command_list[k]
      if (command.parameters[0].to_s).include?("Altitude")
        self.altitude = (command.parameters[0][9,command.parameters[0].length - 1]).to_i << 3
      elsif (command.parameters[0].to_s).include?("Floating")
        self.floating = true
      # V.1.1 : 8-directions graphics
      elsif (command.parameters[0].to_s).include?("Directions")
        self.directions = (command.parameters[0][11,command.parameters[0].length - 1]).to_i
      end
    end
  end
  #--------------------------------------------------------------------------
  # * scan the event's commands list of the current page when refreshed
  #--------------------------------------------------------------------------
  def refresh
    refresh_hm7_game_character

    unless @page.nil?
      check_commands(@page)
    end
  end
end

#============================================================================
# ** Game_Player
#============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  unless @already_aliased_hm7
    alias initialize_hm7_game_player initialize
    alias center_hm7_game_player center
    alias update_hm7_game_player update
    @already_aliased_hm7 = true
  end
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super
  end
  #--------------------------------------------------------------------------
  # * Set the altitude
  #--------------------------------------------------------------------------
  def altitude=(new_altitude)
    @altitude = new_altitude << 3
  end
  #--------------------------------------------------------------------------
  # * Always center around the hero in mode 7
  #--------------------------------------------------------------------------
  def center(x, y)
    unless $game_system.hm7
      center_hm7_game_player(x, y)
      return
    end
    $game_map.display_x = (x << 7) - CENTER_X
    $game_map.display_y = (y << 7) - CENTER_Y
  end
end

#============================================================================
# ** Spriteset_Map
#============================================================================
=begin
class Spriteset_Map
  alias __initialize initialize
  alias _animationSprite_update update
  alias _animationSprite_dispose dispose

  def initialize(map=nil)
        =[]
    _animationSprite_initialize(map)

  end

  def addUserAnimation(animID,x,y)
    viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z=99999
    sprite=AnimationSprite.new(animID,$game_map,x,y,viewport)
    addUserSprite(sprite)
    return sprite
  end

  def addUserSprite(sprite)
    @usersprites = [] if !@usersprites
    for i in 0...@usersprites.length
      if @usersprites[i]==nil || @usersprites[i].disposed?
        @usersprites[i]=sprite
        return
      end
    end
    @usersprites.push(sprite)
  end

  def dispose
    _animationSprite_dispose
    for i in 0...@usersprites.length
      @usersprites[i].dispose
    end
    @usersprites.clear
  end

  def update
    return if @tilemap.disposed?
    if $RPGVX || $PokemonSystem.tilemap==0
      if self.map==$game_map
        pbDayNightTint(@viewport3)
      else
        @viewport3.tone.set(0,0,0,0)
      end
    else
      pbDayNightTint(@tilemap)
      @viewport3.tone.set(0,0,0,0)
    end
    _animationSprite_update
    for i in 0...@usersprites.length
      @usersprites[i].update if !@usersprites[i].disposed?
    end
  end
end
=end
class Spriteset_Map
  #  alias _animationSprite_update update
  #alias _animationSprite_dispose dispose

  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  unless @already_aliased_hm7
    alias initialize_hm7_spriteset_map initialize
    alias dispose_hm7_spriteset_map dispose
    alias update_hm7_spriteset_map update
    @already_aliased_hm7 = true
  end
  #--------------------------------------------------------------------------
  # * Initialize Object
  #--------------------------------------------------------------------------
  def initialize(map=nil)
    unless $game_system.hm7
      initialize_hm7_spriteset_map(map)
      return
    end
  #  Kernel.pbMessage("1")
      @usersprites=[]

    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 200
    @viewport3.z = 5000
    @tilemap = HM7::Tilemap.new(@viewport1, self)
    @panorama = Plane.new(@viewport1)
    @panorama.z =  -100000
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    @weather = RPG::Weather.new(@viewport1)
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
      $game_screen.pictures[i]))
    end
    # V.1.1 : map animations
    @temp_sprites = []
    @timer_sprite = Sprite_Timer.new
  #  @character_sprites = [] if !@character_sprites
   # if map != nil 
#      for i in map.events.keys.sort
#      sprite = Sprite_Character.new(@viewport1, map.events[i])
 #     @character_sprites.push(sprite)
 #    # @reflectedSprites.push(ReflectedSprite.new(sprite,@map.events[i],@viewport1))
 #   end
    
    update
    #raise("3")
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    unless $game_system.hm7 || @tilemap.tileset.nil?
      dispose_hm7_spriteset_map
      return
    end
    @tilemap.dispose
    @panorama.dispose
    @fog.dispose
    @weather.dispose
    for sprite in @picture_sprites
      sprite.dispose
    end
    # V.1.1 : map animations
    if @temp_sprites
    for sprite in @temp_sprites
      sprite.dispose
    end
    end
        @timer_sprite.dispose
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    unless $game_system.hm7
      update_hm7_spriteset_map
      return
    end
  
    if @panorama_name != $game_map.panorama_name or
       @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      if @panorama_name != ""
        @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      if @fog_name != ""
        @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    @tilemap.update
    @panorama.ox = $game_map.display_x / 8
    @panorama.oy = $game_map.display_y / 8
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    for sprite in @picture_sprites
      sprite.update
    end
    # V.1.1 : map animations
    for sprite in @temp_sprites
      sprite.update
      unless sprite.effect?
        sprite.dispose
        @temp_sprites.delete(sprite)
      end
    end
    @timer_sprite.update
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    @viewport3.color = $game_screen.flash_color
    @viewport1.update
    @viewport3.update
    
    #_animationSprite_update
   #for i in 0...@usersprites.length
   #     @usersprites[i].update if !@usersprites[i].disposed?
   # end
    
  end
  #--------------------------------------------------------------------------
  # * Play Animation
  # V.1.1 : map animations
  #--------------------------------------------------------------------------
  def play_animation(animation_id, x, y, zoom)
    animation = $data_animations[animation_id]
    sprite = RPG::Sprite.new(@viewport1)
    sprite.x = x
    sprite.y = y
    sprite.hm7_zoom = zoom
    sprite.animation(animation, true)
    @temp_sprites.push(sprite)
  end
  #--------------------------------------------------------------------------
  # * Increase (or decrease) the angle of slant
  #--------------------------------------------------------------------------
  def hm7_increase_alpha(value)
    @tilemap.set_alpha(value)
  end
  #--------------------------------------------------------------------------
  # * Set the angle of slant
  #--------------------------------------------------------------------------
  def hm7_set_alpha(value)
    @tilemap.set_alpha(value)
  end
  #--------------------------------------------------------------------------
  # * Slide from the current slant angle into the target value
  #--------------------------------------------------------------------------
  def hm7_to_alpha(value, speed)
    @tilemap.to_alpha(value, speed)
  end
  #--------------------------------------------------------------------------
  # * Increase (or decrease) the angle of rotation
  #--------------------------------------------------------------------------
  def hm7_increase_theta(value)
    @tilemap.increase_theta(value)
  end
  #--------------------------------------------------------------------------
  # * Set the angle of rotation
  #--------------------------------------------------------------------------
  def hm7_set_theta(value)
    @tilemap.set_theta(value)
  end
  #--------------------------------------------------------------------------
  # * Slide from the current theta into the target value
  #--------------------------------------------------------------------------
  def hm7_to_theta(value, speed, direction)
    @tilemap.to_theta(value, speed, direction)
  end
  #--------------------------------------------------------------------------
  # * Increase (or decrease) the zoom level
  #--------------------------------------------------------------------------
  def hm7_increase_zoom(value)
    @tilemap.increase_zoom(value)
  end
  #--------------------------------------------------------------------------
  # * Set the zoom level
  #--------------------------------------------------------------------------
  def hm7_set_zoom(value)
    @tilemap.set_zoom(value)
  end
  #--------------------------------------------------------------------------
  # * Slide from the current zoom level into the target value
  #--------------------------------------------------------------------------
  def hm7_to_zoom(value, speed)
    @tilemap.to_zoom(value, speed)
  end
  #--------------------------------------------------------------------------
  # * Set the light fading
  #--------------------------------------------------------------------------
  def hm7_set_fading(red, green, blue, flag)
    @tilemap.set_fading(red, green, blue, flag)
  end
end

#============================================================================
# ** Scene_Map
#============================================================================
class Scene_Map
  #--------------------------------------------------------------------------
  # * Increase (or decrease) the angle of slant
  #--------------------------------------------------------------------------
  def hm7_increase_alpha(value)
    @spriteset.hm7_increase_alpha(value)
  end
  #--------------------------------------------------------------------------
  # * Set the angle of slant
  #--------------------------------------------------------------------------
  def hm7_set_alpha(value)
    @spriteset.hm7_set_alpha(value)
  end
  #--------------------------------------------------------------------------
  # * Slide from the current slant angle into the target value
  #--------------------------------------------------------------------------
  def hm7_to_alpha(value, speed)
    @spriteset.hm7_to_alpha(value, speed)
  end
  #--------------------------------------------------------------------------
  # * Increase (or decrease) the angle of rotation
  #--------------------------------------------------------------------------
  def hm7_increase_theta(value)
    @spriteset.hm7_increase_theta(value)
  end
  #--------------------------------------------------------------------------
  # * Set the angle of rotation
  #--------------------------------------------------------------------------
  def hm7_set_theta(value)
    @spriteset.hm7_set_theta(value)
  end
  #--------------------------------------------------------------------------
  # * Slide from the current theta into the target value
  #--------------------------------------------------------------------------
  def hm7_to_theta(value, speed, direction)
    @spriteset.hm7_to_theta(value, speed, direction)
  end
  #--------------------------------------------------------------------------
  # * Increase (or decrease) the zoom level
  #--------------------------------------------------------------------------
  def hm7_increase_zoom(value)
    @spriteset.hm7_increase_zoom(value)
  end
  #--------------------------------------------------------------------------
  # * Set the zoom level
  #--------------------------------------------------------------------------
  def hm7_set_zoom(value)
    @spriteset.hm7_set_zoom(value)
  end
  #--------------------------------------------------------------------------
  # * Slide from the current zoom level into the target value
  #--------------------------------------------------------------------------
  def hm7_to_zoom(value, speed)
    @spriteset.hm7_to_zoom(value, speed)
  end
  #--------------------------------------------------------------------------
  # * Set the light fading
  #--------------------------------------------------------------------------
  def hm7_set_fading(red, green, blue, flag)
    @spriteset.hm7_set_fading(red, green, blue, flag)
  end
end

#============================================================================
# ** RPG::Sprite
# V.1.1 : map animations
#============================================================================
module RPG
  class Sprite < ::Sprite
    #--------------------------------------------------------------------------
    # * Get current graphics
    #--------------------------------------------------------------------------
    def hm7_zoom=(value)
      @hm7_zoom = value
    end
    #--------------------------------------------------------------------------
    # * Animation Set Sprites
    #--------------------------------------------------------------------------
    def animation_set_sprites(sprites, cell_data, position)
      for i in 0..15
        sprite = sprites[i]
        pattern = cell_data[i, 0]
        if sprite == nil or pattern == nil or pattern == -1
          sprite.visible = false if sprite != nil
          next
        end
        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)
        if position == 3
          if self.viewport != nil
            sprite.x = self.viewport.rect.width / 2
            sprite.y = self.viewport.rect.height - 160
          else
            sprite.x = 320
            sprite.y = 240
          end
        else
          sprite.x = self.x - self.ox + self.src_rect.width / 2
          sprite.y = self.y - self.oy + self.src_rect.height / 2
          sprite.y -= self.src_rect.height / 4 if position == 0
          sprite.y += self.src_rect.height / 4 if position == 2
        end
        sprite.x += cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.z = 2000
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom_x = cell_data[i, 3] / 100.0
        sprite.zoom_y = cell_data[i, 3] / 100.0
        unless @hm7_zoom.nil?
          sprite.zoom_x *= @hm7_zoom
          sprite.zoom_y *= @hm7_zoom
        end
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
        sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
        sprite.blend_type = cell_data[i, 7]
      end
    end
  end
end