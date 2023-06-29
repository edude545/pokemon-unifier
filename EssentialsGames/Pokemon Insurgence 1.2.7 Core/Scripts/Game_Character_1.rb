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
  attr_accessor :paths

  def map
    return @map ? @map : $game_map
  end

  def initialize(map=nil)
    @map=map
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @paths =[]
    @character_name = ""
    @character_hue = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    @move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @locked = false
    @prelock_direction = 0
  end
  def x
    return @x
  end
  def pattern2change(value)
    @pattern=value
    @original_pattern=value
  end
  
  def direction2change(value)
    @direction=value
    @original_direction=value
    end
  def direction=(int)
    @direction=int
    end
  def pattern
    return @pattern
  end
  def pattern=(value)
     @pattern=value
  end
  def y
    return @y
  end
  def through=(value)
    @through=value
  end
  
  def x=(value)
    @x=value
  end
  
  def y=(value)
    @y=value
  end
  
  def move_speed=(value)
    @move_speed=value
  end
  def walk_anime=(value)
    @walk_anime=value
  end
  
  def moving?
    return (@real_x != @x*4*Game_Map::TILEWIDTH or @real_y != @y*4*Game_Map::TILEHEIGHT)
  end

  def jumping?
    return @jump_count > 0
  end

  def straighten
    if @walk_anime or @step_anime
      @pattern = 0
    end
    @anime_count = 0
    @prelock_direction = 0
  end

  def force_move_route(move_route)
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
    move_type_custom
  end
  def direction=(int)
    @direction=int
  end
  
  def passableEx?(x, y, d, strict=false)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    return false unless self.map.valid?(new_x, new_y)
    return true if @through
    if strict
      return false unless self.map.passableStrict?(x, y, d, self)
      return false unless self.map.passableStrict?(new_x, new_y, 10 - d)
    else
      return false unless self.map.passable?(x, y, d, self)
      return false unless self.map.passable?(new_x, new_y, 10 - d)
    end
    for event in self.map.events.values
      if event.x == new_x and event.y == new_y
        unless event.through
          return false if self != $game_player || event.character_name != ""
        end
      end
    end
    if $game_player.x == new_x and $game_player.y == new_y
      unless $game_player.through
        return false if @character_name != ""
      end
    end
    return true
  end

  def passable?(x,y,d)
    return passableEx?(x,y,d,false)
  end

  def passableStrict?(x,y,d)
    return passableEx?(x,y,d,true)
  end

  def lock
    if @locked
      return
    end
    @prelock_direction = @direction
    turn_toward_player
    @locked = true
  end

  def lock?
    return @locked
  end

  def unlock
    unless @locked
      return
    end
    @locked = false
    unless @direction_fix
      if @prelock_direction != 0
        @direction = @prelock_direction
      end
    end
  end

  def triggerLeaveTile
    if @oldX && @oldY && @oldMap &&
         (@oldX!=self.x || @oldY!=self.y || @oldMap!=self.map.map_id)
      Events.onLeaveTile.trigger(self,self,@oldMap,@oldX,@oldY)
     end
     @oldX=self.x
     @oldY=self.y
     @oldMap=self.map.map_id
  end

  def moveto(x, y)
    @x = x % self.map.width
    @y = y % self.map.height
    @real_x = @x * Game_Map.realResX
    @real_y = @y * Game_Map.realResY
    @prelock_direction = 0
    triggerLeaveTile()
  end

  def screen_x
    return (@real_x - self.map.display_x + 3) / 4 + (Game_Map::TILEWIDTH/2)
  end

  def screen_y
    y = (@real_y - self.map.display_y + 3) / 4 + (Game_Map::TILEHEIGHT)
    if jumping?
      if @jump_count >= @jump_peak
        n = @jump_count - @jump_peak
      else
        n = @jump_peak - @jump_count
      end
      return y - (@jump_peak * @jump_peak - n * n) / 2
    else
      return y
    end
  end

  def screen_z(height = 0)
    if @always_on_top
      return 999
    end
    z = (@real_y - self.map.display_y + 3) / 4 + 32
    if @tile_id > 0
      return z + self.map.priorities[@tile_id] * 32
    else
      # Add Z if height exceeds 32
      return z + ((height > 32) ? 31 : 0)
    end
  end

  def bush_depth
    if @tile_id > 0 or @always_on_top
      return 0
    end
    if @jump_count <= 0 and self.map.bush?(@x, @y)
      return 12
    else
      return 0
    end
  end

  def terrain_tag
    return self.map.terrain_tag(@x, @y)
  end
end