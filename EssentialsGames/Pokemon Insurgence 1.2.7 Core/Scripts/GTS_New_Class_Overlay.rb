class DisplayOverGTS < SpriteWrapper
  attr_reader :selected
  attr_reader :preselected
  attr_reader :switching
  attr_reader :pokemon
  attr_reader :active
  attr_accessor :text

  def initialize(pokemon,viewport)
    
    super(viewport)
        @sprites={}
    @pokemon=pokemon
    active=true#(index==0)
    @active=active
      @sprites["background"]=AnimatedBitmap.new("Graphics/Pictures/GTS_background")
      @sprites["stats"]=AnimatedBitmap.new("Graphics/Pictures/GTS_stats")
      @sprites["ivs"]=AnimatedBitmap.new("Graphics/Pictures/GTS_ivs")
      @sprites["natureicons"]=AnimatedBitmap.new("Graphics/Pictures/GTS_natureicon")
    @text=nil
=begin
@statuses=AnimatedBitmap.new(_INTL("Graphics/Pictures/statuses"))
    @hpbar=AnimatedBitmap.new("Graphics/Pictures/partyHP")
    @hpbarfnt=AnimatedBitmap.new("Graphics/Pictures/partyHPfnt")
    @hpbarswap=AnimatedBitmap.new("Graphics/Pictures/partyHPswap")
    @pokeballsprite=ChangelingSprite.new(0,0,viewport)
    @pokeballsprite.addBitmap("pokeballdesel","Graphics/Pictures/partyBall")
    @pokeballsprite.addBitmap("pokeballsel","Graphics/Pictures/partyBallSel")
    @pkmnsprite=PokemonIconSprite.new(pokemon,viewport)
    @pkmnsprite.active=active
    @itemsprite=ChangelingSprite.new(0,0,viewport)
    @itemsprite.addBitmap("itembitmap","Graphics/Pictures/item")
    @itemsprite.addBitmap("mailbitmap","Graphics/Pictures/mail")
    @spriteX=xvalues[index]
    @spriteY=yvalues[index]
=end
    @refreshBitmap=true
    @refreshing=false 
    @preselected=false
    @switching=false
=begin
    @pkmnsprite.z=self.z+2 # For compatibility with RGSS2
    @itemsprite.z=self.z+3 # For compatibility with RGSS2
    @pokeballsprite.z=self.z+1 # For compatibility with RGSS2
=end
  #  @background.z=self.z+1 # For compatibility with RGSS2
  #  @stats.z=self.z+2 # For compatibility with RGSS2
  #  @ivs.z=self.z+3 # For compatibility with RGSS2
#    @natureicon.z=self.z+4 # For compatibility with RGSS2

    #self.selected=false
    self.x=0
    self.y=0
    refresh
  end

  def dispose
    @background.dispose
    @stats.dispose
    @ivs.dispose
    @natureicon.dispose
    self.bitmap.dispose
    super
  end

  def text=(value)
    @text=value
    @refreshBitmap=true
    refresh
  end

  def pokemon=(value)
    @pokemon=value
    #if @pkmnsprite && !@pkmnsprite.disposed?
    #  @pkmnsprite.pokemon=value
    #end
    @refreshBitmap=true
    refresh
  end



  def color=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end
  def pbRefresh
    refresh
  end
  
  def refresh
    return if @refreshing
    return if disposed?
    @refreshing=true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap=BitmapWrapper.new(Graphics.width,Graphics.height)
    end
=begin
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x=self.x+@spriteXOffset
      @pkmnsprite.y=self.y+@spriteYOffset
      @pkmnsprite.color=pbSrcOver(@pkmnsprite.color,self.color)
      @pkmnsprite.selected=self.selected
    end
    if @pokeballsprite && !@pokeballsprite.disposed?
      @pokeballsprite.x=self.x+@pokeballXOffset
      @pokeballsprite.y=self.y+@pokeballYOffset
      @pokeballsprite.color=self.color
      @pokeballsprite.changeBitmap(self.selected ? "pokeballsel" : "pokeballdesel")
    end

    if @itemsprite && !@itemsprite.disposed?
      @itemsprite.visible=(@pokemon.item>0)
      if @itemsprite.visible
        @itemsprite.changeBitmap(@pokemon.mail ? "mailbitmap" : "itembitmap")
        @itemsprite.x=self.x+@itemXOffset
        @itemsprite.y=self.y+@itemYOffset
        @itemsprite.color=self.color
      end
    end
=end
=begin
if @refreshBitmap
      @refreshBitmap=false
      self.bitmap.clear if self.bitmap
      if self.selected
        if self.preselected
          self.bitmap.blt(0,0,@selswapbitmap.bitmap,Rect.new(0,0,@selswapbitmap.width,@selswapbitmap.height))
          self.bitmap.blt(0,0,@deselswapbitmap.bitmap,Rect.new(0,0,@deselswapbitmap.width,@deselswapbitmap.height))
        elsif @switching
          self.bitmap.blt(0,0,@selswapbitmap.bitmap,Rect.new(0,0,@selswapbitmap.width,@selswapbitmap.height))
        elsif @pokemon.hp<=0 && !@pokemon.egg?
          self.bitmap.blt(0,0,@selfntbitmap.bitmap,Rect.new(0,0,@selfntbitmap.width,@selfntbitmap.height))
        else
          self.bitmap.blt(0,0,@selbitmap.bitmap,Rect.new(0,0,@selbitmap.width,@selbitmap.height))
        end
      else
        if self.preselected
          self.bitmap.blt(0,0,@deselswapbitmap.bitmap,Rect.new(0,0,@deselswapbitmap.width,@deselswapbitmap.height))
        elsif @pokemon.hp<=0 && !@pokemon.egg?
          self.bitmap.blt(0,0,@deselfntbitmap.bitmap,Rect.new(0,0,@deselfntbitmap.width,@deselfntbitmap.height))
        else
          self.bitmap.blt(0,0,@deselbitmap.bitmap,Rect.new(0,0,@deselbitmap.width,@deselbitmap.height))
        end
      end
      base=Color.new(248,248,248)
      shadow=Color.new(40,40,40)
      pbSetSystemFont(self.bitmap)
      pokename=@pokemon.name
      if @pokemon.name.split('').last=="♂" || @pokemon.name.split('').last=="♀"
        pokename=@pokemon.name[0..-2]
      end
      textpos=[[pokename,@pokenameX,@pokenameY,0,base,shadow]]
      if !@pokemon.egg?
        if !@text || @text.length==0
          textpos.push([_ISPRINTF("{1: 3d}/{2: 3d}",@pokemon.hp,@pokemon.totalhp),
             @hpX,@hpY,1,base,shadow])
          barbg=(@pokemon.hp<=0) ? @hpbarfnt : @hpbar
          barbg=(self.preselected || (self.selected && @switching)) ? @hpbarswap : barbg
          self.bitmap.blt(@hpbarX,@hpbarY,barbg.bitmap,Rect.new(0,0,@hpbar.width,@hpbar.height))
          hpgauge=@pokemon.totalhp==0 ? 0 : (self.hp*96/@pokemon.totalhp)
          hpgauge=1 if hpgauge==0 && self.hp>0
          hpzone=0
          hpzone=1 if self.hp<=(@pokemon.totalhp/2).floor
          hpzone=2 if self.hp<=(@pokemon.totalhp/4).floor
          hpcolors=[
             Color.new(24,192,32),Color.new(96,248,96),   # Green
             Color.new(232,168,0),Color.new(248,216,0),   # Orange
             Color.new(248,72,56),Color.new(248,152,152)  # Red
          ]
          # fill with HP color
          self.bitmap.fill_rect(@gaugeX,@gaugeY,hpgauge,2,hpcolors[hpzone*2])
          self.bitmap.fill_rect(@gaugeX,@gaugeY+2,hpgauge,4,hpcolors[hpzone*2+1])
          self.bitmap.fill_rect(@gaugeX,@gaugeY+6,hpgauge,2,hpcolors[hpzone*2])
          if @pokemon.hp==0 || @pokemon.status>0
            status=(@pokemon.hp==0) ? 5 : @pokemon.status-1
            statusrect=Rect.new(0,16*status,44,16)
            self.bitmap.blt(@statusX,@statusY,@statuses.bitmap,statusrect)
          end
        end
        if @pokemon.gender==0
          textpos.push([_INTL("♂"),@genderX,@genderY,0,Color.new(0,112,248),Color.new(120,184,232)])
        elsif @pokemon.gender==1
          textpos.push([_INTL("♀"),@genderX,@genderY,0,Color.new(232,32,16),Color.new(248,168,184)])
        end
      end
      pbDrawTextPositions(self.bitmap,textpos)
      if !@pokemon.egg?
        pbSetSmallFont(self.bitmap)
        leveltext=[([_INTL("Lv.{1}",@pokemon.level),@levelX,@levelY,0,base,shadow])]
        pbDrawTextPositions(self.bitmap,leveltext)
      end
      if @text && @text.length>0
        pbSetSystemFont(self.bitmap)
        annotation=[[@text,@annotX,@annotY,0,base,shadow]]
        pbDrawTextPositions(self.bitmap,annotation)
      end
    end
    
=end
    @refreshing=false
  end

  def update
    super
    @background.update 
    @stats.update 
    @ivs.update 
    @natureicon.update 
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.update
    end
  end
end
