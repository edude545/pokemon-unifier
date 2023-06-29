#============================================================================
# H-Mode7 Engine
# V.1.2.1 - 15/05/2011
# Author : MGC (MGCaladtogel)
# Heightmaps cache by DerVVulman
#
# New classes
#============================================================================


#==============================================================================
# ** RPG
#------------------------------------------------------------------------------
#  A module containing RPGXP's data structures and more.
#==============================================================================
module RPG
  #============================================================================
  # ** Cache
  #----------------------------------------------------------------------------
  #  A module that loads each of RPGXP's graphic formats, creates a Bitmap
  #  object, and retains it.
  #============================================================================
  module Cache
    #------------------------------------------------------------------------
    # * Obtains a heightmap graphic
    # V.1.2 : heightmaps cache
    #------------------------------------------------------------------------
    def self.heightmap(filename)
      self.load_bitmap("Graphics/Heightmap/", filename)
    end
  end
end


#==============================================================================
# ** HM7
#------------------------------------------------------------------------------
#  DLL calls to load C functions into memory
#==============================================================================
module HM7
  Draw_Map_Tileset = Win32API.new("MGC_Hmode7", "drawMapTileset", "lllll", "l")
  Draw_Textureset = Win32API.new("MGC_Hmode7", "drawTextureset", "lll", "l")
  Draw_Heightmap = Win32API.new("MGC_Hmode7", "drawHeightmap", "llll", "l")
  Apply_Lighting = Win32API.new("MGC_Hmode7", "applyLighting", "l", "l")
  Compute_M7 = Win32API.new("MGC_Hmode7", "computeM7", "lll", "l")
  Render_HM7 = Win32API.new("MGC_Hmode7", "renderHM7", "lll", "l")
  Refresh_Map_Tileset = Win32API.new("MGC_Hmode7", "refreshMapTileset", "llll", "l")
  # V.1.2 : events translucidity & blend type
  Apply_Opacity = Win32API.new("MGC_Hmode7", "applyOpacity", "ll", "l")
  #--------------------------------------------------------------------------
  # * Draw the specific tileset for the map
  #--------------------------------------------------------------------------
  def self.draw_map_tileset(map_tileset, tileset, heightset, tilemap_hash, auto_tilesets)
    Draw_Map_Tileset.call(map_tileset.__id__, tileset.__id__, heightset.__id__,
    tilemap_hash.__id__, auto_tilesets.__id__)
  end
  #--------------------------------------------------------------------------
  # * Draw the specific textureset for the map
  #--------------------------------------------------------------------------
  def self.draw_textureset(textures, colormap, texture_auto)
    Draw_Textureset.call(textures.__id__, colormap.__id__, texture_auto.__id__)
  end
  #--------------------------------------------------------------------------
  # * Draw the complete heightmap
  #--------------------------------------------------------------------------
  def self.draw_heightmap(heightmap, heightpattern, map_tileset, tilemap_data)
    Draw_Heightmap.call(heightmap.__id__, heightpattern.__id__,
    map_tileset.__id__, tilemap_data.__id__)
  end
  #--------------------------------------------------------------------------
  # * Apply the lighting effects on the map
  #--------------------------------------------------------------------------
  def self.apply_lighting(heightmap)
    Apply_Lighting.call(heightmap.__id__)
  end
  #--------------------------------------------------------------------------
  # * Calculate a basic mode7 rendering
  #--------------------------------------------------------------------------
  def self.compute_m7(datatable, lightline, params)
    Compute_M7.call(datatable.__id__, lightline.__id__, params.__id__)
  end
  #--------------------------------------------------------------------------
  # * H-Mode7 rendering
  #--------------------------------------------------------------------------
  def self.render_hm7(params, vars, surfaces)
    return Render_HM7.call(params.__id__, vars.__id__, surfaces.__id__)
  end
  #--------------------------------------------------------------------------
  # * Refresh the specific tileset for the map for animated autotiles
  #--------------------------------------------------------------------------
  def self.refresh_map_tileset(map_tileset, tileset, tilemap_hash, auto_tilesets)
    Refresh_Map_Tileset.call(map_tileset.__id__, tileset.__id__,
    tilemap_hash.__id__, auto_tilesets.__id__)
  end
  #--------------------------------------------------------------------------
  # * Alter a bitmap by applying an opacity value
  # V.1.2 : events translucidity & blend type
  #--------------------------------------------------------------------------
  def self.apply_opacity(bitmap, opacity)
    Apply_Opacity.call(bitmap.__id__, opacity)
  end
end

#============================================================================
# ** HM7::Bitmap_Autotiles
#============================================================================
module HM7
  class Bitmap_Autotiles < Bitmap
    # data list to form tiles from an autotiles file
    Data_Patterns = [[27,28,33,34],[5,28,33,34],[27,6,33,34],[5,6,33,34],
    [27,28,33,12],[5,28,33,12],[27,6,33,12],[5,6,33,12],[27,28,11,34],
    [5,28,11,34],[27,6,11,34],[5,6,11,34],[27,28,11,12],[5,28,11,12],
    [27,6,11,12],[5,6,11,12],[25,26,31,32],[25,6,31,32],[25,26,31,12],
    [25,6,31,12],[15,16,21,22],[15,16,21,12],[15,16,11,22],[15,16,11,12],
    [29,30,35,36],[29,30,11,36],[5,30,35,36],[5,30,11,36],[39,40,45,46],
    [5,40,45,46],[39,6,45,46],[5,6,45,46],[25,30,31,36],[15,16,45,46],
    [13,14,19,20],[13,14,19,12],[17,18,23,24],[17,18,11,24],[41,42,47,48],
    [5,42,47,48],[37,38,43,44],[37,6,43,44],[13,18,19,24],[13,14,43,44],
    [37,42,43,48],[17,18,47,48],[13,18,43,48],[13,18,43,48]]
    #--------------------------------------------------------------------------
    # * Attributes
    #--------------------------------------------------------------------------
    attr_accessor :number # autotile's number to identify it
    attr_accessor :animated # TRUE if the autotile is animated
    #--------------------------------------------------------------------------
    # * Initialize Object
    #     file : autotiles file's bitmap (Bitmap)
    #     l : pattern's number for animated autotiles
    #--------------------------------------------------------------------------
    def initialize(file, l)
      super(256, 192)
      create(file, l)
    end
    #--------------------------------------------------------------------------
    # * Create the tiles set
    #     file : autotiles file's bitmap (Bitmap)
    #     l : pattern's number for animated autotiles
    #--------------------------------------------------------------------------
    def create(file, l)
      l = (file.width > 96 ? l : 0)
      self.animated = (file.width > 96)
      for i in 0..5
        for j in 0..7
          data = Data_Patterns[(i << 3) + j]
          for number in data
            number -= 1
            m = number % 6 << 4
            n = number / 6 << 4
            blt((j << 5) + m % 32, (i << 5) + n % 32, file,
            Rect.new(m + 96 * l, n, 16, 16))
          end
        end
      end
    end
  end
end

#============================================================================
# ** HM7::Autotile
#============================================================================
module HM7
  class Autotile
    #--------------------------------------------------------------------------
    # * Attributes
    #--------------------------------------------------------------------------
    attr_accessor :autotile_id
    attr_accessor :animated
    attr_accessor :animations_number
    attr_accessor :graphics
    attr_accessor :animation_index
    #--------------------------------------------------------------------------
    # * Initialize Object
    #--------------------------------------------------------------------------
    def initialize(autotile_id, autotile_name)
      self.autotile_id = autotile_id
      bmp_file = RPG::Cache.autotile(autotile_name)

      self.animations_number = bmp_file.width / 96
      self.animated = (animations_number > 1)
      self.graphics = []
      for pattern_iterator in 0...animations_number
        data_autotile = HM7::Bitmap_Autotiles.new(bmp_file, pattern_iterator)
        data_autotile.number = pattern_iterator * 10 + autotile_id
        graphics.push(data_autotile)
      end
      self.animation_index = 0
    end
    #--------------------------------------------------------------------------
    # * Get current graphics
    #--------------------------------------------------------------------------
    def get_current_graphics
      return graphics[animation_index]
    end
    #--------------------------------------------------------------------------
    # * Animate - next pattern
    #--------------------------------------------------------------------------
    def animate
      self.animations_number=4 if animations_number==0 || animations_number==nil
      self.animation_index = animation_index.succ % animations_number
    end
  end
end

#============================================================================
# ** HM7::Surface
#============================================================================
module HM7
  class Surface
    attr_accessor :type, :bitmap, :bitmap_set, :screen_x, :screen_y, :character,
    :visible, :opacity, :blend_type, :displayed, :altitude
    #--------------------------------------------------------------------------
    # * Technical constant to handle relative reference of frame
    #--------------------------------------------------------------------------
    Left = [6, 2, 8, 4]
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     character (Game_Character) : character to display
    #     tilemap (HM7::Tilemap)
    #--------------------------------------------------------------------------
    def initialize(character, tilemap)
      self.character = character
      @tilemap = tilemap
      self.type = 0
      @need_refresh = false
      @sx_old = nil
      @sy_old = nil
      @visible_old = nil
      @opacity_old = nil
      @blend_type_old = nil
      @screen_x_old = nil
      @screen_y_old = nil
      @altitude_old = nil
      update
    end
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    def update
      # If tile ID, file name, or hue are different from current ones
      if @tile_id != character.tile_id or
         @character_name != character.character_name or
         @character_hue != character.character_hue
        # Remember tile ID, file name, and hue
        @tile_id = character.tile_id
        @character_name = character.character_name
        @character_hue = character.character_hue
        # If tile ID value is valid
        if @tile_id >= 384
          @offset_height = 0
          self.bitmap_set = RPG::Cache.tile($game_map.tileset_name,
          @tile_id, character.character_hue)
          @sx = 0
          @sy = 0
          @cw = 32
          @ch = 32
        # If tile ID value is invalid
        else
          @offset_height = 2
          self.bitmap_set = RPG::Cache.character(character.character_name,
          character.character_hue)
          @cw = bitmap_set.width >> 2
          # V.1.1 : 8-directions graphics
          
          character.directions=4 if !character.directions
          
          @ch = bitmap_set.height / character.directions
        end
        self.bitmap = Bitmap.new(@cw, @ch - @offset_height)
        @need_refresh = true
      end
      # Set visible situation
      self.visible = (not character.transparent)
      # If graphic is character
      if @tile_id == 0
        # Set rectangular transfer
        @sx = character.pattern * @cw
        unless character.instance_variable_get(:@direction_fix)
          # V.1.1 : 8-directions graphics
          current_direction = (@character.direction - 2) / 2
          directions_list = HM7::Dirs[character.directions]
          list_size = directions_list.size
          current_direction = directions_list[(directions_list.index(current_direction) +
          (($game_system.hm7_theta + (180 / list_size)) % 360) / (360 / list_size)) % list_size]
          @sy = current_direction * @ch
        else
          @sy = ((character.direction >> 1) - 1) * @ch
        end
      end
      if @need_refresh || @sx_old != @sx || @sy_old != @sy
        bitmap.clear
        bitmap.blt(0, 0, bitmap_set, Rect.new(@sx, @sy, @cw, @ch - @offset_height))
        # V.1.2 : events translucidity & blend type
        HM7.apply_opacity(bitmap, character.opacity)
      end
      # Set sprite coordinates
      update_screen_coordinates
      # Set sprite altitude
      update_altitude
      # Set opacity level, blend method
      self.opacity = character.opacity
      self.blend_type = character.blend_type
      # Force rendering if condition changed
      if @need_refresh || @screen_x_old != screen_x || @screen_y_old != screen_y ||
        @sx_old != @sx || @sy_old != @sy ||
        @visible_old != visible || @opacity_old != opacity ||
        @blend_type_old != blend_type || @altitude_old != altitude
      then
        #if displayed then $game_temp.force_render = true end
        @tilemap.need_update_surfaces = true
        @screen_x_old = screen_x
        @screen_y_old = screen_y
        @sx_old = @sx
        @sy_old = @sy
        @visible_old = visible
        @opacity_old = opacity
        @blend_type_old = blend_type
        @altitude_old = altitude
        @need_refresh = false
      end
      # V.1.1 : map animations
      if character.animation_id != 0
        @tilemap.spriteset.play_animation(@character.animation_id, screen_x, screen_y, get_zoom)
        character.animation_id = 0
      end
    end
    #--------------------------------------------------------------------------
    # * Dispose
    #--------------------------------------------------------------------------
    def dispose
      unless bitmap.nil? then bitmap.dispose end
      unless bitmap_set.nil? then bitmap_set.dispose end
    end
    #--------------------------------------------------------------------------
    # * Get data to render the surface
    #--------------------------------------------------------------------------
    def get_data
      # V.1.2 : events translucidity & blend type
      return [type, screen_x, screen_y, bitmap, altitude, blend_type]
    end
    #--------------------------------------------------------------------------
    # calculate x and y coordinates in mode 7 for a character sprite
    #--------------------------------------------------------------------------
    def update_screen_coordinates
      x_intermediate = character.screen_x
      y_intermediate = character.screen_y - 12
      y_init = $game_temp.zoom_sprites * (y_intermediate - $game_temp.pivot)
      x_init = $game_temp.zoom_sprites * (x_intermediate - 320)
      y_intermediate = (y_init * $game_temp.cos_theta -
      x_init * $game_temp.sin_theta).to_i >> 11
      x_intermediate = (x_init * $game_temp.cos_theta +
      y_init * $game_temp.sin_theta).to_i >> 11
      scr_y = $game_temp.pivot + ($game_temp.distance_h * y_intermediate *
      $game_temp.cos_alpha) / (($game_temp.distance_h << 11) - y_intermediate *
      $game_temp.sin_alpha)
      self.screen_y = (scr_y / @tilemap.coeff_resolution).to_i
      unless screen_y.between?(0, @tilemap.render.height - 1)
        self.displayed = false
        return
      end
      self.screen_x = ((320 + ($game_temp.slope_value * scr_y +
      $game_temp.corrective_value) * x_intermediate) / @tilemap.coeff_resolution).to_i
      unless screen_x.between?(0, @tilemap.render.width - 1)
        self.displayed = false
        return
      end
      self.displayed = true
    end
    #--------------------------------------------------------------------------
    # calculate x and y coordinates in mode 7 for a character sprite
    #--------------------------------------------------------------------------
    def update_altitude
      # V.1.1 : integer values for better compatibility
      xx = ((character.real_x.to_i >> 2) + 16) % ($game_map.width << 5)
      yy = ((character.real_y.to_i >> 2) + 16) % ($game_map.height << 5)
      # V.1.1 : replaced $game_map.width << 4 by $game_map.width << 5
      if yy & 1 == 1 then xx += ($game_map.width << 5) end
      yy = ($game_map.height << 5) + (yy >> 1)
      # V.1.1 : jump command
      self.altitude = character.get_altitude + (character.floating ? 0 : @tilemap.heightmap[xx, yy])
    end
    #--------------------------------------------------------------------------
    # * Get zoom 
    # V.1.1 : map animations
    #--------------------------------------------------------------------------
    def get_zoom
      color = @tilemap.rowsdata.get_pixel(screen_y, 1)
      return ((color.red.to_i << 8) + color.alpha).to_f / 4096
    end
  end
end

#============================================================================
# ** HM7::Tilemap
#----------------------------------------------------------------------------
# This new Tilemap class handles the drawing of a HM7 map
#============================================================================
module HM7
  class Tilemap
    #--------------------------------------------------------------------------
    # * Attributes
    #--------------------------------------------------------------------------
    attr_reader :spriteset # spriteset that called this class
    attr_accessor :sprite # sprite used to contain the map's drawing
    attr_accessor :alpha # angle of slant
    attr_accessor :theta # angle of rotation
    attr_writer :need_update_surfaces
    attr_reader :heightmap
    attr_reader :coeff_resolution
    attr_reader :render
    attr_reader :rowsdata # V.1.1 : map animations
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     viewport  : viewport
    #--------------------------------------------------------------------------
    def initialize(viewport, spriteset)
      @viewport = viewport
      @spriteset = spriteset
      @id = $game_map.map_id
      @height = $game_map.height << 5 # @height : map's height (in pixel)
      @width = $game_map.width << 5 # @width : map's width (in pixel)
      @zoom = $game_system.hm7_zoom # zoom level of the map
      $game_temp.zoom_sprites = @zoom.to_f / 100
      $game_temp.zoom_map = (4096 * (1.0 / $game_temp.zoom_sprites)).to_i
      
      # angle of rotation (theta)
      self.theta = $game_system.hm7_theta
      theta_rad = (Math::PI * theta) / 180
      # easier to work with integer value than floats ('>>' and '<<' operations)
      $game_temp.cos_theta = (2048 * Math.cos(theta_rad)).to_i
      $game_temp.sin_theta = (2048 * Math.sin(theta_rad)).to_i
      
      $game_temp.distance_h = 480 # distance between the center of the map (halfwidth, pivot) and the point of view
      # screenline's number of the slant's pivot = y-coordinate of the rotation center
      $game_temp.pivot = $game_system.hm7_pivot # character sprites
      $game_temp.pivot_map = $game_temp.pivot /
      ($game_system.hm7_resolution == 1 ? 1 :
      ($game_system.hm7_resolution == 2 ? 1.33 : 2)) # map sprite
      # distance between the center of the map (halfwidth, pivot) and the projection plane surface
      $game_temp.distance_p = $game_temp.distance_h - $game_temp.distance_h /
      ($game_system.hm7_resolution == 1 ? 1 :
      ($game_system.hm7_resolution == 2 ? 1.334 :  2))
      # zoom value of the map sprite
      @coeff_resolution = ($game_system.hm7_resolution == 1 ? 1 :
      ($game_system.hm7_resolution == 2 ? 1.334 : 2))
      # x-offset for the 3 resolutions
      @offset_x_res = ($game_system.hm7_resolution == 1 ? 0 :
      ($game_system.hm7_resolution == 2 ? 40 : 80))
      # y-offset for the 3 resolutions
      @offset_y_res = ($game_temp.pivot - $game_temp.pivot_map).to_i >> 1
      @index_animated = 0 # 0..3 : index of animated tiles pattern
      
      # map sprite
      self.sprite = Sprite.new(@viewport)
      sprite.x = 0
      sprite.y = 0
      sprite.z = -99999
      if $game_system.hm7_resolution != 1
        @render = ($game_system.hm7_resolution == 2 ?
        Bitmap.new(480, 360) : Bitmap.new(320, 240))
      else
        @render = Bitmap.new(640, 480)
      end
      sprite.zoom_x = @coeff_resolution
      sprite.zoom_y = @coeff_resolution
      sprite.bitmap = @render
      if $game_system.hm7_less_cut # V.1.2.1
        @computetable = Table.new(@render.width, @render.height << 1, 2)
        @rowsdata = Bitmap.new(@render.height << 1, 3)
      else
        @computetable = Table.new(@render.width, @render.height, 2)
        @rowsdata = Bitmap.new(@render.width, 3)
      end
      
      if HM7::Cache.in_cache?(@id)
        # load the data in the Cache
        array = HM7::Cache.load(@id)
        @heightmap = array[0]
        @map_tileset = array[1]
        @tiletable = array[2]
        @textureset = array[3]
        @autotiles = array[4]
        @tilemap_hash_animated = array[5]
      else
        HM7::Cache.clear
        # create specific tilesets for the map
        initialize_map_data
        # load the ground heightmap
        if $game_system.hm7_heightmap == ""
          heightpattern = Bitmap.new(32, 32)
        else
          # V.1.2 : heightmaps cache
          heightpattern = RPG::Cache.heightmap($game_system.hm7_heightmap)
        end
        # create the complete heightmap : HUGE OBJECT IN MEMORY !!!
        @heightmap = Table.new(@width << 1, @height + (@height >> 1))
        HM7.draw_heightmap(@heightmap, heightpattern,
        @map_tileset, @tiletable)
        heightpattern.dispose
        # generate lighting effects
        if $game_system.hm7_lighting
          HM7.apply_lighting(@heightmap)
        end
        # save the data in the Cache
        HM7::Cache.save(@id, [@heightmap, @map_tileset, @tiletable,
        @textureset, @autotiles, @tilemap_hash_animated])
      end
      
      # angle of slant (alpha)
      self.alpha = $game_system.hm7_alpha
      
      # V.1.2 : events translucidity & blend type
      @params = [@render, @computetable, @rowsdata, @heightmap,
      @map_tileset, @tiletable, @textureset, $game_system.hm7_loop_x,
      $game_system.hm7_loop_y, $game_system.hm7_camera_mode,
      Bitmap.new(@render.width, @render.height), $game_system.hm7_less_cut,
      $game_system.hm7_no_black_cut] # V.1.2.1
      @vars = [0, 0, 0, 0, 0]
      @parameters = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      refresh_alpha
      
      # initialize surfaces
      @surfaces = []
      for i in $game_map.events.keys.sort
        surface = HM7::Surface.new($game_map.events[i], self)
        @surfaces.push(surface)
      end
      surface_player = HM7::Surface.new($game_player, self)
      @surfaces.push(surface_player)
      @render_surfaces = []
      self.need_update_surfaces = true
      update_surfaces
      
      #Test for horizon blue colors
      
      
    end
    #--------------------------------------------------------------------------
    # * Refresh all the parameters dependent on the angle of slant
    #--------------------------------------------------------------------------
    def refresh_alpha
      # angle of slant
      alpha_rad = (Math::PI * alpha) / 180
      $game_temp.cos_alpha = (2048 * Math.cos(alpha_rad)).to_i
      $game_temp.sin_alpha = (2048 * Math.sin(alpha_rad)).to_i
      $game_system.hm7_alpha = alpha
      $game_system.hm7_pivot = $game_temp.pivot
      # h0,  z0 : intermediate values used to calculate the slope
      h0 = (- ($game_temp.distance_h) * $game_temp.pivot *
      $game_temp.cos_alpha) / (($game_temp.distance_h << 11) +
      $game_temp.pivot * $game_temp.sin_alpha) + $game_temp.pivot
      z0 = ($game_temp.distance_h << 11).to_f /
      (($game_temp.distance_h << 11) + $game_temp.pivot * $game_temp.sin_alpha)
      # slope
      $game_temp.slope_value = (1.0 - z0) / ($game_temp.pivot - h0)
      $game_temp.slope_value_map = (131072 * $game_temp.slope_value).to_i
      $game_temp.corrective_value = 1.0 - $game_temp.pivot * $game_temp.slope_value
      $game_temp.corrective_value_map = (131072 * $game_temp.corrective_value / @coeff_resolution).to_i
      last_line = - $game_temp.pivot_map - $game_system.hm7_horizon
      old_limit = $game_temp.hm7_height_limit
      $game_temp.hm7_height_limit = (($game_temp.distance_h - $game_temp.distance_p) *
      last_line * $game_temp.cos_alpha) / (($game_temp.distance_h << 11) -
      last_line * $game_temp.sin_alpha) + $game_temp.pivot_map
      $game_temp.hm7_height_limit = [$game_temp.hm7_height_limit.to_i, 0].max
      
      @parameters = [$game_temp.cos_alpha, $game_temp.sin_alpha,
      $game_temp.distance_h, $game_temp.pivot_map.to_i,
      $game_temp.slope_value_map, $game_temp.corrective_value_map,
      $game_temp.hm7_height_limit, $game_temp.cos_theta, $game_temp.sin_theta,
      $game_temp.distance_p.to_i, $game_temp.zoom_map, @parameters[11]]
      @rowsdata.set_pixel(0, 0, $game_system.hm7_fading_color)
      HM7.compute_m7(@computetable, @rowsdata, @parameters)
      
      
      #thing test color horizon
      
      $game_system.hm7_fading_color = Color.new(0, 0, 255, 1)
      @rowsdata.set_pixel(0, 0, $game_system.hm7_fading_color)
      HM7.compute_m7(@computetable, @rowsdata, @parameters)
      
      
      
      @vars[0] = $game_temp.hm7_height_limit
      @need_update = true
    end
    #--------------------------------------------------------------------------
    # * Increase (or decrease) the angle of slant
    #--------------------------------------------------------------------------
    def increase_alpha(value)
      self.alpha = [[alpha + value, 80].min, 0].max
      refresh_alpha
    end
    #--------------------------------------------------------------------------
    # * Set the angle of slant
    #--------------------------------------------------------------------------
    def set_alpha(value)
      self.alpha = [[value, 80].min, 0].max
      refresh_alpha
    end
    #--------------------------------------------------------------------------
    # * Slide from the current slant angle into the target value
    #--------------------------------------------------------------------------
    def to_alpha(value, speed)
      value = [[value, 80].min, 0].max
      while value > alpha
        increase_alpha([speed, value - alpha].min)
        spriteset.update
        Graphics.update
      end
      while value < alpha
        increase_alpha(-([speed, alpha - value].min))
        spriteset.update
        Graphics.update
      end
    end
    #--------------------------------------------------------------------------
    # * Refresh all the parameters dependent on the angle of rotation
    #--------------------------------------------------------------------------
    def refresh_theta
      @rowsdata.set_pixel(0, 0, $game_system.hm7_fading_color)
      @parameters[7] = $game_temp.cos_theta
      @parameters[8] = $game_temp.sin_theta
      HM7.compute_m7(@computetable, @rowsdata, @parameters)
      @need_update = true
    end
    #--------------------------------------------------------------------------
    # * Increase (or decrease) the angle of rotation
    #--------------------------------------------------------------------------
    def increase_theta(value)
      self.theta += value
      self.theta %= 360
      theta_rad = (Math::PI * theta) / 180
      $game_temp.cos_theta = (2048 * Math.cos(theta_rad)).to_i
      $game_temp.sin_theta = (2048 * Math.sin(theta_rad)).to_i
      $game_system.hm7_theta = theta
      refresh_theta
    end
    #--------------------------------------------------------------------------
    # * Set the angle of rotation
    #--------------------------------------------------------------------------
    def set_theta(value)
      self.theta = value % 360
      theta_rad = (Math::PI * theta) / 180
      $game_temp.cos_theta = (2048 * Math.cos(theta_rad)).to_i
      $game_temp.sin_theta = (2048 * Math.sin(theta_rad)).to_i
      $game_system.hm7_theta = theta
      refresh_theta
    end
    #--------------------------------------------------------------------------
    # * Slide from the current theta into the target value
    #--------------------------------------------------------------------------
    def to_theta(value, speed, direction)
      value %= 360
      while value != theta
        increase_theta(direction * ([(value - theta).abs, speed].min))
        spriteset.update
        Graphics.update
      end
    end
    #--------------------------------------------------------------------------
    # * Increase (or decrease) the zoom level
    #--------------------------------------------------------------------------
    def increase_zoom(value)
      value = value.to_f / 100
      @zoom = [[@zoom * (2 ** value), 500].min, 50].max
      $game_temp.zoom_sprites = @zoom.to_f / 100
      $game_temp.zoom_map = (4096 * (1.0 / $game_temp.zoom_sprites)).to_i
      $game_system.hm7_zoom = @zoom
      refresh_alpha
    end
    #--------------------------------------------------------------------------
    # * Set the zoom level
    #--------------------------------------------------------------------------
    def set_zoom(value)
      @zoom = [[value, 500].min, 1].max
      $game_temp.zoom_sprites = @zoom.to_f / 100
      $game_temp.zoom_map = (4096 * (1.0 / $game_temp.zoom_sprites)).to_i
      $game_system.hm7_zoom = @zoom
      refresh_alpha
    end
    #--------------------------------------------------------------------------
    # * Slide from the current zoom level into the target value
    #--------------------------------------------------------------------------
    def to_zoom(value, speed)
      value = [[value, 500].min, 1].max
      while value > @zoom
        increase_zoom(speed)
        if value < @zoom
          set_zoom(value)
        end
        spriteset.update
        Graphics.update
      end
      while value < @zoom
        increase_zoom(-speed)
        if value > @zoom
          set_zoom(value)
        end
        spriteset.update
        Graphics.update
      end
    end
    #--------------------------------------------------------------------------
    # * Set the light fading
    #--------------------------------------------------------------------------
    def set_fading(red, green, blue, flag)
      $game_system.hm7_fading_color = Color.new(red, green, blue, flag)
      @rowsdata.set_pixel(0, 0, $game_system.hm7_fading_color)
      HM7.compute_m7(@computetable, @rowsdata, @parameters)
      @need_update = true
    end
    #--------------------------------------------------------------------------
    # * Dispose
    #--------------------------------------------------------------------------
    def dispose
      @render.dispose
      @rowsdata.dispose
      # dispose of surfaces
      for surface in @surfaces
        surface.dispose
      end
      # dispose of map sprite
      sprite.dispose
    end
    #--------------------------------------------------------------------------
    # * Update
    #--------------------------------------------------------------------------
    def update
      # update animated autotiles
      if Graphics.frame_count % $game_system.hm7_anim_freq == 0 &&
        $game_system.hm7_animated
      then
         update_autotiles
        @need_update = true
      end
      # update surfaces
      update_surfaces
      if $game_system.hm7_two_frames_refresh && Graphics.frame_count & 1 == 0
        return
      end
      # update offsets
      offset_x = ($game_map.display_x >> 3) + @offset_x_res
      offset_y = ($game_map.display_y >> 3) + @offset_y_res
      if !@need_update && (offset_x != @offset_x_old || offset_y != @offset_y_old)
        @offset_x_old = offset_x
        @offset_y_old = offset_y
        @need_update = true
      end
      if @need_update
        @vars[1] = offset_x
        @vars[2] = offset_y
        @need_update = false
        if $game_system.hm7_filter
          if $game_system.hm7_two_frames_refresh
            @vars[3] = (Graphics.frame_count >> 1 & 1) + 1
          else
            @vars[3] = (Graphics.frame_count & 1) + 1
          end
        end
        @target_y = HM7.render_hm7(@params, @vars, @render_surfaces)
        @need_update_screen = true
      elsif @need_update_screen
        @vars[3] = 0
        @target_y = HM7.render_hm7(@params, @vars, @render_surfaces)
        @need_update_screen = false
      end
      # camera : vertical offset update
      update_camera
    end
    #--------------------------------------------------------------------------
    # * Update surfaces
    #--------------------------------------------------------------------------
    def update_surfaces
      for surface in @surfaces
        surface.update
      end
      if @need_update_surfaces
        @render_surfaces.clear
        for surface in @surfaces
          if surface.displayed then @render_surfaces.push(surface.get_data) end
        end
        @render_surfaces.sort! {|a, b| b[2] - a[2] == 0 ? a[1] - b[1] : b[2] - a[2]}
        self.need_update_surfaces = false
        @need_update = true
      end
    end
    #--------------------------------------------------------------------------
    # * Update animated autotiles
    #--------------------------------------------------------------------------
    def update_autotiles
      autotiles_graphics = {}
      for autotile in @autotiles
        autotile.animate
        autotiles_graphics[autotile.autotile_id] = autotile.get_current_graphics
      end
      auto_tilesets = []
      for i in 0..6
        if autotiles_graphics.has_key?(i)
          auto_tilesets.push(autotiles_graphics[i])
        else
          auto_tilesets.push(0)
        end
      end
      HM7.refresh_map_tileset(@map_tileset,
      RPG::Cache.tileset($game_map.tileset_name),
      @tilemap_hash_animated, auto_tilesets)
    end
    #--------------------------------------------------------------------------
    # * Update camera
    #--------------------------------------------------------------------------
    def update_camera
      if $game_system.hm7_camera_mode > 0
        if @vars[4] < @target_y
          @vars[4] = [@vars[4] + 1 + (@target_y - @vars[4] >> 2), @target_y].min
          @need_update = true
        elsif @vars[4] > @target_y + 1
          @vars[4] = [@vars[4] - 1 - (@vars[4] - @target_y >> 2), @target_y].max
          @need_update = true
        end
      end
    end
    #--------------------------------------------------------------------------
    # * no tileset for HM7 maps
    #--------------------------------------------------------------------------
    def tileset
      return nil
    end
  end
end

#============================================================================
# ** HM7::Tilemap
#============================================================================
module HM7
  class Tilemap
    #--------------------------------------------------------------------------
    # * Initialize the HM7 data depending on the map
    #--------------------------------------------------------------------------
    def initialize_map_data
      data = $game_map.data
      
      # Create autotiles graphics
      # autotiles_hmap : [autotile heightmap]
      autotiles_hmap = []
      # animated_autotiles_ids : [animated autotile identifier]
      animated_autotiles_ids = []
      # autotiles_graphics : {autotile identifier => HM7::Autotile_Bitmap}
      autotiles_graphics = {}
      # @autotiles : [HM7::Autotile]
      @autotiles = []
      # autotextures_map : {autotile identifier => texture name}
      autotextures_map = {}
      # create the graphics for the autotiles colormap
      texture_auto = HM7::Bitmap_Autotiles.new(RPG::Cache.autotile("Textures/Texture_Auto"), 0)
      for i in 0..6
        autotile_name = $game_map.autotile_names[i]
        if autotile_name == ""
          autotiles_hmap.push(0)
        else
          autotile = HM7::Autotile.new(i, autotile_name)
          @autotiles.push(autotile)
          if autotile.animated then animated_autotiles_ids.push(i) end
          autotiles_graphics[i] = autotile.get_current_graphics
          # heigthmap
          if FileTest.exist?("Graphics/Autotiles/" + autotile_name + "_Hmap.png") ||
            FileTest.exist?("Graphics/Autotiles/" + autotile_name + "_Hmap.PNG")
          then
            autotiles_hmap.push(HM7::Bitmap_Autotiles.new(RPG::Cache.autotile(autotile_name + "_Hmap"), 0))
          else
            autotiles_hmap.push(Bitmap.new(256, 192))
          end
          # texturemap
          if FileTest.exist?("Graphics/Autotiles/Textures/Texture_" + autotile_name + ".png") ||
            FileTest.exist?("Graphics/Autotiles/Textures/Texture_" + autotile_name + ".PNG")
          then
            autotextures_map[i] = autotile_name
          end
        end
      end
      
      # Get the textures graphics for the tileset
      textures_list = Dir.glob("Graphics/Tilesets/" + $game_map.tileset_name + "_Textures/*.{png,PNG}")
      textures_map = {} # {tileId => texture filename}
      for filename in textures_list
        basic_filename = File.basename(filename, ".*")
        num_tile = (basic_filename[/\d+/]).to_i
        textures_map[num_tile] = basic_filename
      end
      
      # tiletable : for each map square, store the HM7Ids of :
      # [3-layers tile, layer1 tile, layer2 tile, layer3 tile]
      @tiletable = Table.new(@width >> 3, @height >> 5, 1) 
      textures = {}
      basic_tiles_list = {}
      basic_tiles_count = 0
      tiles_list = {}
      tiles_count = 0
      animated_autotiles_keys = []
      bush_data = {}
      for i in 0...$game_map.height
        for j in 0...$game_map.width
          value1 = data[j, i, 0]
          value2 = data[j, i, 1]
          value3 = data[j, i, 2]
          unless tiles_list.has_key?([value1, value2, value3])
            tiles_count += 1
            tiles_list[[value1, value2, value3]] = tiles_count
            # determine the bush value
            bush_value = 3
            for tile_id in [value3, value2, value1]
              if tile_id.nil? || tile_id == 0 ||
                $game_map.passages[tile_id] & 0x40 == 0x40
              then
                bush_value -= 1
              else
                break
              end
            end
            bush_data[tiles_count - 1] = bush_value
          end
          count = tiles_list[[value1, value2, value3]]
          @tiletable[j << 2, i, 0] = count - 1
          k = 0
          for value in [value1, value2, value3]
            k += 1
            if value > 0
              unless basic_tiles_list.has_key?(value)
                basic_tiles_list[value] = basic_tiles_count
                if value >= 384
                 value -= 384
                 if textures_map.has_key?(value)
                   texture_bmp = RPG::Cache.tileset($game_map.tileset_name + "_Textures/" + textures_map[value])
                   textures[basic_tiles_count] = [value + 384, texture_bmp]
                 end
                 value += 384
                else # autotile
                  if autotextures_map.has_key?(value / 48 - 1)
                    texture_bmp = RPG::Cache.autotile("Textures/Texture_" + autotextures_map[value / 48 - 1])
                    textures[basic_tiles_count] = [value, texture_bmp]
                  end
                end
                basic_tiles_count += 1
              end
              if value < 384 &&
                animated_autotiles_ids.include?(value / 48 - 1)
              then
                animated_autotiles_keys.push(count - 1)
              end
              @tiletable[(j << 2) + k, i, 0] = basic_tiles_list[value]
            end
          end
        end
      end
      tileset_height = 1 + (tiles_count >> 3) << 5
      auto_tilesets = []
      for i in 0..6
        if autotiles_graphics.has_key?(i)
          auto_tilesets.push(autotiles_graphics[i])
        else
          auto_tilesets.push(0)
        end
      end
      for i in 0..6
        auto_tilesets.push(autotiles_hmap[i])
      end
      
      @map_tileset = Bitmap.new(512, tileset_height)
      tilemap_hash = {}
      for key in tiles_list.keys
        value = tiles_list[key] - 1
        tilemap_hash[value] = key.push(bush_data[value])
      end
  
      # create the specific 3-layers tileset for the map
      HM7.draw_map_tileset(@map_tileset,
      RPG::Cache.tileset($game_map.tileset_name),
      RPG::Cache.tileset($game_map.tileset_name + "_Hmap"),
      tilemap_hash, auto_tilesets)
      for bitmap in autotiles_hmap
        unless bitmap.is_a?(Fixnum)
          bitmap.dispose
        end
      end
      
      # create a hash that contains data for animated 3-layers tiles
      @tilemap_hash_animated = {}
      for key in animated_autotiles_keys
        if tilemap_hash.has_key?(key)
          @tilemap_hash_animated[key] = tilemap_hash[key]
        end
      end
      if animated_autotiles_keys.length == 0
        $game_system.hm7_animated = false
      end
  
      # create the textureset used to draw vertical walls
      @textureset = Bitmap.new(160, basic_tiles_count << 5)
      HM7.draw_textureset(textures, @textureset, texture_auto)
           
    end
  end
end

#============================================================================
# ** HM7::Cache
#============================================================================
module HM7
  module Cache
    @cache = {}
    #------------------------------------------------------------------------
    # * Check if the map is in the Cache
    #   map_id : map identifier
    #------------------------------------------------------------------------
    def self.in_cache?(map_id)
      return @cache.include?(map_id)
    end
    #------------------------------------------------------------------------
    # * Return the map data (Array)
    #   map_id : map identifier
    #------------------------------------------------------------------------
    def self.load(map_id)
      return @cache[map_id]
    end
    #------------------------------------------------------------------------
    # * Save the map data in the Cache
    #   map_id : map identifier
    #   params : map data (Array)
    #------------------------------------------------------------------------
    def self.save(map_id, params)
      @cache[map_id] = params
    end
    #------------------------------------------------------------------------
    # * Clear the Cache
    #------------------------------------------------------------------------
    def self.clear
      @cache = {}
      GC.start
    end
  end
end