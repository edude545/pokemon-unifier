class BushBitmap
  def initialize(bitmap,isTile)
    @bitmaps=[]
    @bitmap=bitmap
    @isTile=isTile
    @isBitmap=@bitmap.is_a?(Bitmap)
  end

  def dispose
    for b in @bitmaps
      b.dispose if b
    end
  end

  def bitmap
    thisBitmap=@isBitmap ? @bitmap : @bitmap.bitmap
    current=@isBitmap ? 0 : @bitmap.currentIndex
    if !@bitmaps[current]
      if @isTile
        @bitmaps[current]=Sprite_Character.pbBushDepthTile(thisBitmap,12)
      else
        @bitmaps[current]=Sprite_Character.pbBushDepthBitmap(thisBitmap,12)
      end
    end
    return @bitmaps[current]
  end
end



class Sprite_Character < RPG::Sprite
  attr_accessor :character
  attr_accessor :charbitmap
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    update
  end

  def self.pbBushDepthBitmap(bitmap,depth)
    ret=Bitmap.new(bitmap.width,bitmap.height)
    charheight=ret.height/4
    for i in 0...4
      cy=charheight-depth-2
      y=i*charheight
      ret.blt(0,y,bitmap,Rect.new(0,y,ret.width,cy)) if cy>=0
      ret.blt(0,y+cy,bitmap,Rect.new(0,y+cy,ret.width,2),170) if cy>=0    
      ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85) if cy+2>=0    
    end
    return ret
  end

  def self.pbBushDepthTile(bitmap,depth)
    ret=Bitmap.new(bitmap.width,bitmap.height)
    charheight=ret.height
    cy=charheight-depth-2
    y=charheight
    ret.blt(0,y,bitmap,Rect.new(0,y,ret.width,cy)) if cy>=0
    ret.blt(0,y+cy,bitmap,Rect.new(0,y+cy,ret.width,2),170) if cy>=0    
    ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85) if cy+2>=0    
    return ret
  end

  def dispose
    @bushbitmap.dispose if @bushbitmap
    @bushbitmap=nil
    @charbitmap.dispose if @charbitmap
    @charbitmap=nil
    super
  end

  def update
    super
      if @tile_id != @character.tile_id or
        @character_name != @character.character_name or
        @character_hue != @character.character_hue
       
        @tile_id = @character.tile_id
        @character_name = @character.character_name
        @character_hue = @character.character_hue
      if @tile_id >= 384
        @charbitmap.dispose if @charbitmap
        @charbitmap = pbGetTileBitmap(@character.map.tileset_name,
           @tile_id, @character.character_hue)
        @charbitmapAnimated=false
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap=nil
        @cw = 32  # added
        @ch = 32  # added
        self.src_rect.set(0, 0, 32, 32)
        self.ox = Game_Map::TILEWIDTH/2
        self.oy = Game_Map::TILEHEIGHT
      else
        if @character.character_name != nil
          @charbitmap.dispose if @charbitmap
          # if $game_switches[136]
          #    @charbitmap = AnimatedBitmap.new(
          #    "Graphics/Characters/"+
          #    sprintf("%03d",$game_variables[1].species),
          #    @character.character_hue)
          #  end
          #  if !$game_switches[136]
          @charbitmap = AnimatedBitmap.new(
             "Graphics/Characters/"+@character.character_name,
             @character.character_hue)
          #   end
          #    if $game_switches[136] && @character.character_name=$game_player.character_name
          #        @charbitmap = AnimatedBitmap.new(
          #        "Graphics/Characters/"+
          #        sprintf("%03d",$game_variables[1].species),
          #        @character.character_hue)
          #      end  
          aryOfSBFS=[113,116,119,165,190,354,390,731,729,727]
          if $game_switches[647] && aryOfSBFS.include?($game_map.map_id)
            #     setSpriteTrainerBase(pbGet(1),16)
          end
          if $Trainer && $game_player && !$game_switches[136] && @character.character_name == $game_player.character_name #clothcloth
            append="/"
            ### The below lines of code are used because for whatever reason some maps stop acting as if the player stops moving on specific tiles ###
            isRunning=false
            if $game_player.runClothesCheck
              isRunning=true
            end
            if !isRunning && $game_player.moving?
              if ($game_switches[86] && !Input.press?(Input::A)) ||
                 (!$game_switches[86] && Input.press?(Input::A))
                isRunning=true
              end
            end
            
            append="/run/" if isRunning
            append="/bike/" if $PokemonGlobal.bicycle
            append="/surf/" if $PokemonGlobal.surfing || $PokemonGlobal.diving
            #if !$game_player.pbIsRunning?
            #  if $game_player.moving? 
            #    Kernel.pbMessage("1")
            #  end
            #  if $game_player.move_route_forcing
            #    Kernel.pbMessage("2")
            #  end
            #  if !$PokemonGlobal
            #    Kernel.pbMessage("3")
            #  end
            #  if !$game_player.pbCanRun?
            #    Kernel.pbMessage("4")
            #  end
            #end
            
            for i in 0..5
              $Trainer.clothes[i] = 0 if $Trainer.clothes[i]==nil 
            end
            appendEnd=""
            appendEnd="b" if $Trainer.clothes[5]%2==0 && $Trainer.bald
            appendEnd="c" if $Trainer.clothes[5]%2==1 && $Trainer.bald
            if !$PokemonGlobal.surfing && !$PokemonGlobal.diving
              #       bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"shoes#{$Trainer.clothes[5]}")
              #   @charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))    
              if $Trainer.clothes[4] >= 0 && $Trainer.clothes[3] >= 0 && $Trainer.clothes[2] >= 0 && $Trainer.clothes[1] >= 0 && $Trainer.clothes[0] >= 0 && $PokemonGlobal.playerID < 6
                bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"pants#{$Trainer.clothes[4]}")
                @charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))    
          
                bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"shirt#{$Trainer.clothes[2]}")
                @charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))

                bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"coat#{$Trainer.clothes[1]}")
                @charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))

                bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes/backpack#{$Trainer.clothes[3]}")
                @charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
                #if $PokemonGlobal.playerID>0
                
                #Kernel.pbMessage("Graphics/Characters/Clothes"+append+"hair#{$Trainer.clothes[5]}"+appendEnd) if isRunning
                bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"hair#{$Trainer.clothes[5]}"+appendEnd)
                @charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
                if $Trainer && $Trainer.clothes && $Trainer.clothes[0] && $Trainer.clothes[0] >= 806 && $Trainer.clothes[0] <= 809 && $Trainer.gender==1
                  append = append+"f"
                end
    
                bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"hat#{$Trainer.clothes[0]}")
                @charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
              end
            end
          end

          @charbitmapAnimated=true
          @bushbitmap.dispose if @bushbitmap
          @bushbitmap=nil
          @cw = @charbitmap.width / 4
          @ch = @charbitmap.height / 4
          self.ox = @cw / 2
          if @character_name[/offset/]
            self.oy = @ch - 16
          else
            self.oy = @ch
          end
        end
      end
    end
  
    @charbitmap.update if @charbitmapAnimated
    if @character.bush_depth==0
      self.bitmap=@charbitmapAnimated ? @charbitmap.bitmap : @charbitmap
    else
      if !@bushbitmap
        @bushbitmap=BushBitmap.new(@charbitmap,@tile_id >= 384)
      end
      self.bitmap=@bushbitmap.bitmap
    end
    self.visible = (not @character.transparent)
    if @character==$game_player && @tile_id == 0
      if $PokemonGlobal.surfing || $PokemonGlobal.diving
        bob=((Graphics.frame_count%60)<30) ? 0 : 1
        self.oy=(bob>0) ? @ch-16-2 : @ch-16
      end
    end
    if @tile_id == 0
      if @character==$game_player && !$PokemonGlobal.fishing &&
         ($PokemonGlobal.surfing || $PokemonGlobal.diving)
        sx = bob * @cw
        sy = (@character.direction - 2) / 2 * @ch
        self.src_rect.set(sx, sy, @cw, @ch)
      else
        sx = @character.pattern * @cw
        sy = (@character.direction - 2) / 2 * @ch
        self.src_rect.set(sx, sy, @cw, @ch)
      end
    end
    if self.visible
      if $PokemonSystem.tilemap==0 ||
         (@character.is_a?(Game_Event) && @character.name=="RegularTone")
        self.tone.set(0,0,0,0)
      else
        pbDayNightTint(self)
      end
    end
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    self.zoom_x = Game_Map::TILEWIDTH/32.0
    self.zoom_y = Game_Map::TILEHEIGHT/32.0
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    #self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
=begin
def update
    super
    #if @oldbushdepth != @character.bush_depth  #JV
    #  @oldbushdepth = @character.bush_depth
    #  @bushbitmap.dispose if @bushbitmap
    #  @bushbitmap=nil
    #end
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_hue != @character.character_hue or
       @oldbushdepth != @character.bush_depth
       echoln(Graphics.frame_count)
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      if @tile_id >= 384
        @charbitmap.dispose if @charbitmap
        @charbitmap = pbGetTileBitmap(@character.map.tileset_name,
           @tile_id, @character.character_hue)
        @charbitmapAnimated=false
       
        @oldbushdepth = @character.bush_depth #JV
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap=nil
       
        @cw = 32  # added
        @ch = 32  # added
        self.src_rect.set(0, 0, 32, 32)
        self.ox = Game_Map::TILEWIDTH/2
        self.oy = Game_Map::TILEHEIGHT
      else
        @charbitmap.dispose if @charbitmap
        @charbitmap = AnimatedBitmap.new(
           "Graphics/Characters/"+@character.character_name,
           @character.character_hue)
        @charbitmapAnimated=true
       
        @oldbushdepth = @character.bush_depth #JV
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap=nil
       
        @cw = @charbitmap.width / 4
        @ch = @charbitmap.height / 4
        self.ox = @cw / 2
        if @character_name[/offset/]
          self.oy = @ch - 16
        else
          self.oy = @ch
        end
      end
    end
    @charbitmap.update if @charbitmapAnimated
    if @character.bush_depth==0
      self.bitmap=@charbitmapAnimated ? @charbitmap.bitmap : @charbitmap
    else
      if !@bushbitmap
        @bushbitmap=BushBitmap.new(@charbitmap,@tile_id >= 384,@character.bush_depth)
      end
      self.bitmap=@bushbitmap.bitmap
    end
    self.visible = (not @character.transparent)
    if @character==$game_player && @tile_id == 0
      if $PokemonGlobal.surfing || $PokemonGlobal.diving
        bob=((Graphics.frame_count%60)/15).floor
        self.oy=(bob>=2) ? @ch-16-2 : @ch-16
      end
    end
    if @tile_id == 0
      if @character==$game_player && !$PokemonGlobal.fishing &&
         ($PokemonGlobal.surfing || $PokemonGlobal.diving)
        sx = bob * @cw
        sy = (@character.direction - 2) / 2 * @ch
        self.src_rect.set(sx, sy, @cw, @ch)
      else
        sx = @character.pattern * @cw
        sy = (@character.direction - 2) / 2 * @ch
        self.src_rect.set(sx, sy, @cw, @ch)
      end
    end
    if self.visible
      if $PokemonSystem.tilemap==0 ||
         (@character.is_a?(Game_Event) && @character.name=="RegularTone")
        self.tone.set(0,0,0,0)
      else
        pbDayNightTint(self)
      end
    end
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    self.zoom_x = Game_Map::TILEWIDTH/32.0
    self.zoom_y = Game_Map::TILEHEIGHT/32.0
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
#    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end
=end

end