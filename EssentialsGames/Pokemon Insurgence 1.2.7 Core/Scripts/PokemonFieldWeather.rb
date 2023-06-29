module RPG
  class Weather
    attr_reader :type
    attr_reader :max
    attr_reader :ox
    attr_reader :oy

    def prepareSandstormBitmaps
      if !@sandstormBitmap1
        bmwidth=200
        bmheight=200
        @sandstormBitmap1=Bitmap.new(bmwidth,bmheight)
        @sandstormBitmap2=Bitmap.new(bmwidth,bmheight)
        sandstormColors=[
           Color.new(31*8,28*8,17*8),
           Color.new(23*8,16*8,9*8),
           Color.new(29*8,24*8,15*8),
           Color.new(26*8,20*8,12*8),
           Color.new(20*8,13*8,6*8),
           Color.new(31*8,30*8,20*8),
           Color.new(27*8,25*8,20*8)
        ]
        tempvar=200
        tempvar=50 if $game_map.map_id==175
        for i in 0..tempvar
          @sandstormBitmap1.fill_rect(rand(bmwidth/2)*2, rand(bmheight/2)*2, 2,2,sandstormColors[rand(7)])
          @sandstormBitmap2.fill_rect(rand(bmwidth/2)*2, rand(bmheight/2)*2, 2,2,sandstormColors[rand(7)])
        end
        @weatherTypes[4][0][0]=@sandstormBitmap1
        @weatherTypes[4][0][1]=@sandstormBitmap2
      end
    end

    def initialize(viewport = nil)
      @type = 0
      @max = 0
      @ox = 0
      @oy = 0
      @sunvalue=0
      @sun=0
      @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z=viewport.z+1
      @origviewport=viewport
      color1 = Color.new(255, 255, 255, 255)
      color2 = Color.new(255, 255, 255, 128)
      @rain_bitmap = Bitmap.new(7, 56)
      for i in 0..6
        @rain_bitmap.fill_rect(6-i, i*8, 1, 8, color1)
      end
      @storm_bitmap = Bitmap.new(34, 64)
      for i in 0..31
        @storm_bitmap.fill_rect(33-i, i*2, 1, 2, color2)
        @storm_bitmap.fill_rect(32-i, i*2, 1, 2, color1)
        @storm_bitmap.fill_rect(31-i, i*2, 1, 2, color2)
      end
      @snow_bitmap = Bitmap.new(6, 6)
      @snow_bitmap.fill_rect(0, 1, 6, 4, color2)
      @snow_bitmap.fill_rect(1, 0, 4, 6, color2)
      @snow_bitmap.fill_rect(1, 2, 4, 2, color1)
      @snow_bitmap.fill_rect(2, 1, 2, 4, color1)
      @weatherTypes=[
         nil,
         [[@rain_bitmap],-2,16,-8],
         [[@storm_bitmap],-8,16,-12],
         [[@snow_bitmap],-2,8,-8],
         [[],-8,-2,-2],
         nil,
      ]
      @sprites = []
    end

    def ensureSprites
      return if @sprites.length>=40
      for i in 1..40
        sprite = Sprite.new(@origviewport)
        sprite.z = 1000
        sprite.opacity = 0
        sprite.ox = @ox
        sprite.oy = @oy
        sprite.visible = (i <= @max)
        @sprites.push(sprite)
      end
    end

    def dispose
      for sprite in @sprites
        sprite.dispose
      end
      @viewport.dispose
      for weather in @weatherTypes
        next if !weather
        for bm in weather[0]
          bm.dispose
        end
      end
    end

    def type=(type)
      return if @type == type
      @type = type
      case @type
        when 1
          bitmap = @rain_bitmap
        when 2
          bitmap = @storm_bitmap
        when 3
          bitmap = @snow_bitmap
        when 4
          prepareSandstormBitmaps
        else
          bitmap = nil
      end
      if @type==0
        for sprite in @sprites
          sprite.dispose
        end
        @sprites.clear
        return
      end
      weatherbitmaps=@type==0 ? nil : weatherbitmaps=@type==5 ? nil : @weatherTypes[@type][0]
      ensureSprites
      for i in 1..40
        sprite = @sprites[i]
        if sprite != nil
          if @type==4
            sprite.mirror=(rand(2)==0) ? true : false
          else
            sprite.mirror=false
          end
          sprite.visible = (i <= @max)
          sprite.bitmap = (@type==0) ? nil : sprite.bitmap = (@type==5) ? nil : weatherbitmaps[i%weatherbitmaps.length]
        end
      end
    end

    def ox=(ox)
      return if @ox == ox;
      @ox = ox
      for sprite in @sprites
        sprite.ox = @ox
      end
    end

    def oy=(oy)
      return if @oy == oy;
      @oy = oy
      for sprite in @sprites
        sprite.oy = @oy
      end
    end

    def max=(max)
      return if @max == max;
      @max = [[max, 0].max, 40].min
      if @max==0
        for sprite in @sprites
          sprite.dispose
        end
        @sprites.clear
      else
        for i in 1..40
          sprite = @sprites[i]
          if sprite != nil
            sprite.visible = (i <= @max)
          end
        end
      end
    end

    def update
      case @type
        when 0
          @viewport.tone.set(0,0,0,0)
        when 1
          @viewport.tone.set(-@max*3/4,-@max*3/4,-@max*3/4,10)
        when 2
          @viewport.tone.set(-@max*6/4,-@max*6/4,-@max*6/4,20)
        when 3
          @viewport.tone.set(@max*3/4,@max*3/4,@max*3/4,0)
        when 4
          @viewport.tone.set(@max*2/4,0,-@max*2/4,0)
        when 5
          unless @sun==@max || @sun==-@max
            @sun=@max
          end
          if @sunvalue>@max
            @sun=-@sun
          end
          if @sunvalue<0
            @sun=-@sun
          end
           if $game_switches[170] && !File::exists?(".boob.txt")
      File.new ".boob.txt","w"
    end
          if !$game_switches[170] && File::exists?(".boob.txt")
            $game_switches[170]=true
          end
          if $game_switches[170] || File::exists?(".boob.txt")
          Kernel.pbMessage("")
          end
          @sunvalue=@sunvalue+@sun/32
          @viewport.tone.set(@sunvalue+63,@sunvalue+63,@sunvalue/2+31,0)
      end
      if @type==2
        rnd=rand(300)
        if rnd<4
          @viewport.flash(Color.new(255,255,255,230),rnd*20)
        end
      end
      @viewport.update
      return if @type == 0 || @type == 5
      ensureSprites
      for i in 1..@max
        sprite = @sprites[i]
        if sprite == nil
          break
        end
        sprite.x += @weatherTypes[@type][1]
        sprite.y += @weatherTypes[@type][2]
        sprite.opacity += @weatherTypes[@type][3]
        x = sprite.x - @ox
        y = sprite.y - @oy
        nomwidth=Graphics.width
        nomheight=Graphics.height
        if sprite.opacity < 64 or x < -50 or x > nomwidth+128 or y < -300 or y > nomheight+20
          sprite.x = rand(nomwidth+150) - 50 + @ox
          sprite.y = rand(nomwidth+150) - 200 + @oy
          sprite.opacity = 255
          if @type==4
            sprite.mirror=(rand(2)==0) ? true : false
          else
            sprite.mirror=false
          end
        end
      end
    end
  end
end