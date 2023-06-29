def adjustBattleSpriteYEx(metrics,sprite,species,index)
  ret=0
  if index==1 || index==3   # Foe Pokémon
    ret=-14
    ret-=16 if index==3
    ret+=(metrics[1][species] || 0)*2 # enemy Y
    ret-=(metrics[2][species] || 0)*2 # altitude
    halfY=(sprite.bitmap &&
       !sprite.bitmap.disposed?) ? sprite.bitmap.height/2 : 64
    ret+=(64-halfY)
    ret+=((Graphics.height-320)*3/4).floor              # Adjust for screen size
  else                      # Player's Pokémon
    ret=96
    ret+=16 if index==2
    ret+=16
    ret+=(metrics[0][species] || 0)*2
    spriteheight=(sprite.bitmap && 
       !sprite.bitmap.disposed?) ? sprite.bitmap.height : 128
    ret+=(128-spriteheight)
    ret+=(Graphics.height-320)                          # Adjust for screen size
  end
  return ret
end

def adjustBattleSpriteY(sprite,species,index)
  metrics=load_data("Data/metrics.dat")
  return adjustBattleSpriteYEx(metrics,sprite,species,index)
end

def pbPositionPokemonSprite(sprite,left,top)
  if sprite.bitmap && !sprite.bitmap.disposed?
    sprite.x=left+(128-sprite.bitmap.width)/2
    sprite.y=top+(128-sprite.bitmap.height)/2
  else
    sprite.x=left
    sprite.y=top
  end
end

def pbSpriteSetCenter(sprite,cx,cy)
  return if !sprite
  if !sprite.bitmap
    sprite.x=cx
    sprite.y=cy
    return
  end
  realwidth=sprite.bitmap.width*sprite.zoom_x
  realheight=sprite.bitmap.height*sprite.zoom_y
  sprite.x=cx-(realwidth/2)
  sprite.y=cy-(realheight/2)
end



class PokemonSprite < SpriteWrapper
  def initialize(viewport=nil)
    super(viewport)
    @_iconbitmap=nil
  end

  def dispose
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.bitmap=nil if !self.disposed?
    super
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.bitmap=@_iconbitmap.bitmap
    end
  end

  def setPokemonBitmap(pokemon,back=false,substitute=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=pokemon ? pbLoadPokemonBitmap(pokemon,back,substitute) : nil
    self.bitmap=@_iconbitmap ? @_iconbitmap.bitmap : nil
    self.color=Color.new(0,0,0,0)
  end

  def setPokemonBitmapSpecies(pokemon,species,back=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=pokemon ? pbLoadPokemonBitmapSpecies(pokemon,species,back) : nil
    self.bitmap=@_iconbitmap ? @_iconbitmap.bitmap : nil
  end
end



class PokemonIconSprite < SpriteWrapper
  attr_accessor :selected
  attr_accessor :active
  attr_reader :pokemon

  def initialize(pokemon,viewport=nil)
    super(viewport)
    @animbitmap=nil
    @frames=[
       Rect.new(0,0,64,64),
       Rect.new(64,0,64,64)
    ]
    @selected=false
    @animframe=0
    @active=false
    self.pokemon=pokemon
    @frame=0
    @pokemon=pokemon
    @adjusted_x=0
    @adjusted_y=0
    @logical_x=0
    @logical_y=0
  end

  def pokemon=(value)
    @pokemon=value
    @animbitmap.dispose if @animbitmap
    @animbitmap=nil
    if @pokemon
      @animbitmap=AnimatedBitmap.new(pbPokemonIconFile(value))
      self.bitmap=@animbitmap.bitmap
      self.src_rect=@frames[@animframe]
    else
      self.bitmap=nil
    end
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    super
  end

  def x
    @logical_x
  end

  def y
    @logical_y
  end

  def x=(value)
    @logical_x=value
    super(@logical_x+@adjusted_x)
  end

  def y=(value)
    @logical_y=value
    super(@logical_y+@adjusted_y)
  end

  def update
    @updating=true
    super
    if @animbitmap
      @animbitmap.update
      self.bitmap=@animbitmap.bitmap 
      self.src_rect=@frames[@animframe]
    end
    self.color=Color.new(0,0,0,0)
    frameskip=5
    frameskip=10 if @pokemon && @pokemon.hp<=(@pokemon.totalhp/2)
    frameskip=20 if @pokemon && @pokemon.hp<=(@pokemon.totalhp/4)
    frameskip=-1 if @pokemon && @pokemon.hp==0
    if frameskip==-1
      @animframe=0
      self.src_rect=@frames[@animframe]
    else
      @frame+=1
      @frame=0 if @frame>100
      if @frame>=frameskip
        @animframe=(@animframe==1) ? 0 : 1
        self.src_rect=@frames[@animframe]
        @frame=0
      end
    end
    if self.selected
      @adjusted_x=4
      @adjusted_y=(@animframe==0) ? -2 : 6
    else
      @adjusted_x=0
      @adjusted_y=0
    end
    @updating=false
    self.x=self.x
    self.y=self.y
  end
end



class PokemonSpeciesIconSprite < SpriteWrapper
  attr_accessor :selected
  attr_accessor :active
  attr_reader :species
  attr_reader :gender
  attr_reader :form

  def initialize(species,viewport=nil)
    super(viewport)
    @animbitmap=nil
    @frames=[
       Rect.new(0,0,64,64),
       Rect.new(64,0,64,64)
    ]
    @animframe=0
    @frame=0
    @x=0
    @y=0
    @species=species
    @gender=0
    @form=0
    refresh
  end

  def species=(value)
    @species=value
    refresh
  end

  def gender=(value)
    @gender=value
    refresh
  end

  def form=(value)
    @form=value
    refresh
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    super
  end

  def x; @x; end
  def y; @y; end

  def x=(value)
    @x=value
    super(@x)
  end

  def y=(value)
    @y=value
    super(@y)
  end

  def refresh
    @animbitmap.dispose if @animbitmap
    @animbitmap=nil
    bitmapFileName=pbCheckPokemonIconFiles([@species,(@gender==1),false,@form,false])
    @animbitmap=AnimatedBitmap.new(bitmapFileName)
    self.bitmap=@animbitmap.bitmap
    self.src_rect=@frames[@animframe]
  end

  def update
    @updating=true
    super
    if @animbitmap
      @animbitmap.update
      self.bitmap=@animbitmap.bitmap 
      self.src_rect=@frames[@animframe]
    end
    frameskip=5
    @frame+=1
    @frame=0 if @frame>10
    if @frame>=frameskip
      @animframe=(@animframe==1) ? 0 : 1
      self.src_rect=@frames[@animframe]
      @frame=0
    end
    @updating=false
    self.x=self.x
    self.y=self.y
  end
end