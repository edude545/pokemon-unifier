class Window_Menu < Window_CommandPokemon
  def initialize(commands,x,y)
    tempbitmap=Bitmap.new(32,32)
    w=0
    for i in commands
      width=tempbitmap.text_size(i).width
      w=width if w<width
    end
    w+=16+self.borderX
    super(commands,w)
    h=[commands.length*32,480].min
    h+=self.borderY
    right=[x+w,640].min
    bottom=[y+h,480].min
    left=right-w
    top=bottom-h
    self.x=left
    self.y=top
    self.width=w
    self.height=h
    tempbitmap.dispose
  end

  def hittest
    mousepos=Mouse::getMousePos
    return -1 if !mousepos  
    toprow=self.top_row
    for i in toprow...toprow+@item_max
      rc=Rect.new(0,32*(i-toprow),self.contents.width,32)
      rc.x+=self.x+self.leftEdge
      rc.y+=self.y+self.topEdge
      if rc.contains(mousepos[0],mousepos[1])
        return i
      end
    end
    return -1 
  end
end



module ShadowText
  def shadowtext(bitmap,x,y,w,h,t,disabled=false,align=0)
    width=bitmap.text_size(t).width
    if align==2
      x+=(w-width)
    elsif align==1
      x+=(w/2)-(width/2)
    end
    pbDrawShadowText(bitmap,x,y,w,h,t,
       disabled ? Color.new(26*8,26*8,25*8) : Color.new(12*8,12*8,12*8),
       Color.new(26*8,26*8,25*8))
  end
end



class UIControl
  include ShadowText
  attr_accessor :bitmap
  attr_accessor :label
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height
  attr_accessor :changed
  attr_accessor :parent
  attr_accessor :disabled

  def text
    return self.label
  end

  def text=(value)
    self.label=value
  end

  def initialize(label)
    @label=label
    @x=0
    @y=0
    @width=0
    @height=0
    @changed=false
    @disabled=false
    @invalid=true
  end

  def toAbsoluteRect(rc)
    return Rect.new(
       rc.x+self.parentX,
       rc.y+self.parentY,
       rc.width,rc.height)
  end

  def parentX
    return 0 if !self.parent
    return self.parent.x+self.parent.leftEdge if self.parent.is_a?(SpriteWindow)
    return self.parent.x+16 if self.parent.is_a?(Window)
    return self.parent.x
  end

  def parentY
    return 0 if !self.parent
    return self.parent.y+self.parent.topEdge if self.parent.is_a?(SpriteWindow)
    return self.parent.y+16 if self.parent.is_a?(Window)
    return self.parent.y
  end

  def invalid?
    return @invalid
  end

  def invalidate # Marks that the control must be redrawn to reflect current logic
    @invalid=true
  end

  def update # Updates the logic on the control, invalidating it if necessary
  end

  def refresh # Redraws the control
  end

  def validate # Makes the control no longer invalid
    @invalid=false
  end

  def repaint # Redraws the control only if it is invalid
    if self.invalid?
      self.refresh
      self.validate
    end
  end
end



class Button < UIControl
  attr_accessor :label

  def initialize(label)
    super
    @captured=false
    @label=label
  end

  def update
    mousepos=Mouse::getMousePos
    self.changed=false
    return if !mousepos
    rect=Rect.new(self.x+1,self.y+1,self.width-2,self.height-2)
    rect=toAbsoluteRect(rect)
    if Input.triggerex?(Input::LeftMouseKey) && 
       rect.contains(mousepos[0],mousepos[1]) && !@captured
      @captured=true
      self.invalidate
    end
    if Input.releaseex?(Input::LeftMouseKey) && @captured
      self.changed=true if rect.contains(mousepos[0],mousepos[1])
      @captured=false
      self.invalidate
    end
  end

  def refresh
    bitmap=self.bitmap
    x=self.x
    y=self.y
    width=self.width
    height=self.height
    color=Color.new(120,120,120)
    bitmap.fill_rect(x+1,y+1,width-2,height-2,color)
    ret=Rect.new(x+1,y+1,width-2,height-2)
    if !@captured
      bitmap.fill_rect(x+2,y+2,width-4,height-4,Color.new(0,0,0,0))
    else
      bitmap.fill_rect(x+2,y+2,width-4,height-4,Color.new(120,120,120,80))
    end
    size=bitmap.text_size(self.label).width
     shadowtext(bitmap,x+4,y,size,height,self.label,@disabled)
    return ret
  end
end

class PlainText < UIControl
  attr_accessor :label

  def initialize(label)
    super
    @captured=false
    @label=label
  end

  def update
  end

  def refresh
    bitmap=self.bitmap
    x=self.x
    y=self.y
    width=self.width
    height=self.height
    color=Color.new(120,120,120)
    bitmap.fill_rect(x+1,y+1,width-2,height-2,color)
    ret=Rect.new(x+1,y+1,width-2,height-2)
    if !@captured
      bitmap.fill_rect(x+2,y+2,width-4,height-4,Color.new(0,0,0,0))
    else
      bitmap.fill_rect(x+2,y+2,width-4,height-4,Color.new(120,120,120,80))
    end
    size=bitmap.text_size(self.label).width
     shadowtext(bitmap,x+4,y,size,height,self.label,@disabled)
    return ret
  end
end

class Checkbox < Button
  attr_reader :checked

  def curvalue
    return self.checked
  end

  def curvalue=(value)
    self.checked=value
  end

  def checked=(value)
    @checked=value
    invalidate
  end

  def initialize(label)
    super
    @checked=false
  end

  def update
    super
    if self.changed
      @checked=!@checked
      self.invalidate
    end
  end

  def refresh
    bitmap=self.bitmap
    x=self.x
    y=self.y
    width=[self.width,32].min
    height=[self.height,32].min
    color=Color.new(120,120,120)
    bitmap.fill_rect(x+2,y+2,self.width-4,self.height-4,Color.new(0,0,0,0))
    bitmap.fill_rect(x+1,y+1,width-2,height-2,color)
    ret=Rect.new(x+1,y+1,width-2,height-2)
    if !@captured
      bitmap.fill_rect(x+2,y+2,width-4,height-4,Color.new(0,0,0,0))
    else
      bitmap.fill_rect(x+2,y+2,width-4,height-4,Color.new(120,120,120,80))
    end
    if self.checked
      shadowtext(bitmap,x,y,32,32,"X",@disabled,1)
    end
    size=bitmap.text_size(self.label).width
    shadowtext(bitmap,x+36,y,size,height,self.label,@disabled)
    return ret
  end
end



class TextField < UIControl
  attr_accessor :label
  attr_reader :text

  def text=(value)
    @text=value
    self.invalidate
  end

  def initialize(label,text)
    super(label)
    @frame=0
    @label=label
    @text=text
    @cursor=text.scan(/./m).length
  end

  def insert(ch)
    chars=self.text.scan(/./m)
    chars.insert(@cursor,ch)
    @text=""
    for ch in chars
      @text+=ch
    end
    @cursor+=1
    @frame=0
    self.changed=true
    self.invalidate
  end

  def delete
    chars=self.text.scan(/./m)
    chars.delete_at(@cursor-1)
    @text=""
    for ch in chars
      @text+=ch
    end
    @cursor-=1
    @frame=0
    self.changed=true
    self.invalidate
  end

  def update
    @frame+=1
    @frame%=20
    self.changed=false
    self.invalidate if ((@frame%10)==0)
    # Moving cursor
    if Input.repeat?(Input::LEFT)
      if @cursor > 0
        @cursor-=1
        @frame=0
        self.invalidate
      end
      return
    end
    if Input.repeat?(Input::RIGHT)
      if @cursor < self.text.scan(/./m).length
        @cursor+=1
        @frame=0
        self.invalidate
      end
      return
    end
    # Backspace
    if Input.repeatex?(8) || Input.repeatex?(0x2E)
      self.delete if @cursor > 0
      return
    end
    # Letter keys
    for i in 65..90
      if Input.repeatex?(i)
        shift=(Input.press?(Input::SHIFT)) ? 0x41 : 0x61
        insert((shift+(i-65)).chr)
        return
      end
    end
    # Number keys
    shifted=")!@\#$%^&*("
    unshifted="0123456789"
    for i in 48..57
      if Input.repeatex?(i)
        insert((Input.press?(Input::SHIFT)) ? shifted[i-48].chr : unshifted[i-48].chr)
        return
      end
    end
    keys=[
       [32," "," "],
       [106,"*","*"],
       [107,"+","+"],
       [109,"-","-"],
       [111,"/","/"],
       [186,";",":"],
       [187,"=","+"],
       [188,",","<"],
       [189,"-","_"],
       [190,".",">"],
       [191,"/","?"],
       [219,"[","{"],
       [220,"\\","|"],
       [221,"]","}"],
       [222,"\"","'"]
    ]
    for i in keys
      if Input.repeatex?(i[0])
        insert((Input.press?(Input::SHIFT)) ? i[2] : i[1])
        return
      end
    end
  end

  def refresh
    bitmap=self.bitmap
    x=self.x
    y=self.y
    width=self.width
    height=self.height
    color=Color.new(120,120,120)
    bitmap.font.color=color
    bitmap.fill_rect(x,y,width,height,Color.new(0,0,0,0))
    size=bitmap.text_size(self.label).width
    shadowtext(bitmap,x,y,size,height,self.label)
    x+=size
    width-=size
    bitmap.fill_rect(x+1,y+1,width-2,height-2,color)
    ret=Rect.new(x+1,y+1,width-2,height-2)
    if !@captured
      bitmap.fill_rect(x+2,y+2,width-4,height-4,Color.new(0,0,0,0))
    else
      bitmap.fill_rect(x+2,y+2,width-4,height-4,Color.new(120,120,120,80))
    end
    x+=4
    textscan=self.text.scan(/./m)
    scanlength=textscan.length
    @cursor=scanlength if @cursor>scanlength
    @cursor=0 if @cursor<0
    startpos=@cursor
    fromcursor=0
    while (startpos>0)
      c=textscan[startpos-1]
      fromcursor+=bitmap.text_size(c).width
      break if fromcursor>width-4
      startpos-=1
    end
    for i in startpos...scanlength
      c=textscan[i]
      textwidth=bitmap.text_size(c).width
      next if c=="\n"  
      # Draw text
      shadowtext(bitmap,x,y, textwidth+4, 32, c)
      # Draw cursor if necessary
      if ((@frame/10)&1) == 0 && i==@cursor
        bitmap.fill_rect(x,y+4,2,24,Color.new(120,120,120))
      end
      # Add x to drawn text width
      x += textwidth
    end
    if ((@frame/10)&1) == 0 && textscan.length==@cursor
      bitmap.fill_rect(x,y+4,2,24,Color.new(120,120,120))
    end
    return ret
  end
end



class Slider < UIControl
  attr_reader :minvalue
  attr_reader :maxvalue
  attr_reader :curvalue
  attr_accessor :label

  def curvalue=(value)
    @curvalue=value
    @curvalue=self.minvalue if self.minvalue && @curvalue<self.minvalue
    @curvalue=self.maxvalue if self.maxvalue && @curvalue>self.maxvalue
    self.invalidate
  end

  def minvalue=(value)
    @minvalue=value
    @curvalue=self.minvalue if self.minvalue && @curvalue<self.minvalue
    @curvalue=self.maxvalue if self.maxvalue && @curvalue>self.maxvalue
    self.invalidate
  end

  def maxvalue=(value)
    @maxvalue=value
    @curvalue=self.minvalue if self.minvalue && @curvalue<self.minvalue
    @curvalue=self.maxvalue if self.maxvalue && @curvalue>self.maxvalue
    self.invalidate
  end

  def initialize(label,minvalue,maxvalue,curval)
    super(label)
    @minvalue=minvalue
    @maxvalue=maxvalue
    @curvalue=curval
    @label=label
    @leftarrow=Rect.new(0,0,0,0)
    @rightarrow=Rect.new(0,0,0,0)
    self.minvalue=minvalue
    self.maxvalue=maxvalue
    self.curvalue=curval
  end

  def update
    mousepos=Mouse::getMousePos
    self.changed=false
    if self.minvalue<self.maxvalue && self.curvalue<self.minvalue
      self.curvalue=self.minvalue
    end
    return false if self.disabled
    return false if !Input.repeatex?(Input::LeftMouseKey)
    return false if !mousepos
    left=toAbsoluteRect(@leftarrow)
    right=toAbsoluteRect(@rightarrow)
    oldvalue=self.curvalue
    # Left arrow
    if left.contains(mousepos[0],mousepos[1])
      if Input.repeatcount(0x01)>40
        self.curvalue-=10
      elsif Input.repeatcount(0x01)>30
        self.curvalue-=5
      else
        self.curvalue-=1
      end
      self.changed=(self.curvalue!=oldvalue)
      self.invalidate
    end
    #Right arrow
    if right.contains(mousepos[0],mousepos[1])
      if Input.repeatcount(0x01)>40
        self.curvalue+=10
      elsif Input.repeatcount(0x01)>30
        self.curvalue+=5
      else
        self.curvalue+=1
      end
      self.changed=(self.curvalue!=oldvalue)
      self.invalidate
    end
  end

  def refresh
    bitmap=self.bitmap
    x=self.x
    y=self.y
    width=self.width
    height=self.height
    color=Color.new(120,120,120)
    colordisabled=Color.new(120,120,120,80)
    bitmap.fill_rect(x,y,width,height,Color.new(0,0,0,0))
    size=bitmap.text_size(self.label).width
    leftarrows=bitmap.text_size(_INTL(" << "))
    numbers=bitmap.text_size(" XXXX ").width
    rightarrows=bitmap.text_size(_INTL(" >> "))
    bitmap.font.color=color
    shadowtext(bitmap,x,y,size,height,self.label)
    x+=size
    shadowtext(bitmap,x,y,leftarrows.width,height,_INTL(" << "),
       self.disabled || self.curvalue==self.minvalue)
    @leftarrow=Rect.new(x,y,leftarrows.width,height)
    x+=leftarrows.width
    if !self.disabled
      bitmap.font.color=color
      shadowtext(bitmap,x,y,numbers,height," #{self.curvalue} ",false,1)
    end
    x+=numbers
    shadowtext(bitmap,x,y,rightarrows.width,height,_INTL(" >> "),
       self.disabled || self.curvalue==self.maxvalue)
    @rightarrow=Rect.new(x,y,rightarrows.width,height)
    x+=rightarrows.width
  end
end



class OptionalSlider < Slider
  def initialize(label,minvalue,maxvalue,curvalue)
    @slider=Slider.new(label,minvalue,maxvalue,curvalue)
    @checkbox=Checkbox.new("")
  end

  def curvalue
    return @checkbox.checked ? @slider.curvalue : nil
  end

  def curvalue=(value)
    slider.curvalue=value
  end

  def checked
    return @slider.checked
  end

  def checked=(value)
    slider.checked=checked
  end

  def invalid?
    return @slider.invalid? || @checkbox.invalid?
  end

  def invalidate
    @slider.invalidate
    @checkbox.invalidate
  end

  def validate?
    @slider.validate
    @checkbox.validate
  end

  def changed
    return @slider.changed || @checkbox.changed
  end

  def minvalue
    return @slider.minvalue
  end

  def minvalue=(value)
    slider.minvalue=value
  end

  def maxvalue
    return @slider.maxvalue
  end

  def maxvalue=(value)
    slider.maxvalue=value
  end

  def update
    updatedefs
    @slider.update
    @checkbox.update
  end

  def refresh
    updatedefs
    @slider.refresh
    @checkbox.refresh
  end

  private

  def updatedefs
    x=self.x
    y=self.y
    width=self.width
    height=self.height
    checkboxwidth=32
    @slider.bitmap=self.bitmap
    @slider.parent=self.parent
    @checkbox.x=self.x
    @checkbox.y=self.y
    @checkbox.width=checkboxwidth
    @checkbox.height=self.height
    @checkbox.bitmap=self.bitmap
    @checkbox.parent=self.parent
    @slider.x=self.x+checkboxwidth+4
    @slider.y=self.y
    @slider.width=self.width-checkboxwidth
    @slider.height=self.height
    @slider.disabled=!@checkbox.checked
  end
end



class ControlWindow < SpriteWindow_Base
  attr_reader :controls

  def initialize(x,y,width,height)
    super(x,y,width,height)
    self.contents=Bitmap.new(width-32,height-32)
    pbSetNarrowFont(self.contents)
    @controls=[]
  end

  def dispose
    self.contents.dispose
    super
  end

  def refresh
    for i in 0...@controls.length
      @controls[i].refresh
    end
  end

  def repaint
    for i in 0...@controls.length
      @controls[i].repaint
    end
  end

  def invalidate
    for i in 0...@controls.length
      @controls[i].invalidate
    end
  end

  def addControl(control)
    i=@controls.length
    @controls[i]=control
    @controls[i].x=0
    @controls[i].y=i*32
    @controls[i].width=self.contents.width
    @controls[i].height=32
    @controls[i].parent=self
    @controls[i].bitmap=self.contents
    @controls[i].invalidate
    refresh
    return i
  end

  def hittest?(i)
    mousepos=Mouse::getMousePos
    return false if !mousepos
    return false if i<0 || i>=@controls.length
    rc=Rect.new(
       @controls[i].parentX,
       @controls[i].parentY,
       @controls[i].width,
       @controls[i].height
    )
    return rc.contains(mousepos[0],mousepos[1])
  end

  def addButton(label)
    return addControl(Button.new(label))
  end

  def addSlider(label,minvalue,maxvalue,curvalue)
    return addControl(Slider.new(label,minvalue,maxvalue,curvalue))
  end

  def update
    super
    for i in 0...@controls.length
      @controls[i].update
    end
    repaint
  end

  def changed?(i)
    return false if i<0
    return @controls[i].changed
  end

  def value(i)
    return false if i<0
    return @controls[i].curvalue
  end
end



module Clipboard
  @data=nil
  @typekey=""

  def self.data
    return nil if !@data
    return Marshal::load(@data)
  end

  def self.typekey
    return @typekey
  end

  def self.setData(data,key)
    @data=Marshal.dump(data)
    @typekey=key
  end
end



#####################

class Rect < Object
  def contains(x,y)
    return x>=self.x&&x<self.x+self.width &&
           y>=self.y&&y<self.y+self.height
  end
end



def pbSpriteHitTest(sprite,x,y,usealpha=true,wholecanvas=false)
  return false if !sprite||sprite.disposed?
  return false if !sprite.bitmap
  return false if !sprite.visible
  return false if sprite.bitmap.disposed?
  width=sprite.src_rect.width
  height=sprite.src_rect.height
  if !wholecanvas
    xwidth=width-128
    xheight=height-128
    width=128 if width>128
    height=128 if height>128
  else
    xwidth=0
    xheight=0
  end
  width=sprite.bitmap.width if width>sprite.bitmap.width
  height=sprite.bitmap.height if height>sprite.bitmap.height
  spritex=sprite.x-(sprite.ox*sprite.zoom_x)
  spritey=sprite.y-(sprite.oy*sprite.zoom_y)
  spritex+=xwidth
  spritey+=xheight
  width*=sprite.zoom_x
  height*=sprite.zoom_y
  if !(x>=spritex && x<=spritex+width && y>=spritey && y<=spritey+height)
    return false
  end
  if usealpha
    bitmapX=sprite.src_rect.x
    bitmapY=sprite.src_rect.y
    bitmapX+=sprite.ox
    bitmapY+=sprite.oy
    bitmapX+=(x-sprite.x)/sprite.zoom_x if sprite.zoom_x>0
    bitmapY+=(y-sprite.y)/sprite.zoom_y if sprite.zoom_y>0
    bitmapX=bitmapX.round
    bitmapY=bitmapY.round
    bx=x-sprite.x
    by=y-sprite.y
    color=sprite.bitmap.get_pixel(bitmapX,bitmapY)
    return false if (color.alpha==0)
  end
  return true
end



class AnimationWindow < SpriteWrapper
  attr_reader :animbitmap
  attr_reader :start
  attr_reader :selected

  def animbitmap=(val)
    @animbitmap=val
    @start=0
    refresh
  end

  def selected=(val)
    @selected=val
    refresh
  end

  def dispose
    @contents.dispose
    @arrows.dispose
    @start=0
    @selected=0
    @changed=false
    super
  end

  def initialize(viewport=nil)
    super(viewport)
    @animbitmap=nil
    @arrows=AnimatedBitmap.new("Graphics/Pictures/arrows")
    self.x=240
    self.y=384
    @start=0
    @selected=0
    @contents=Bitmap.new(400,96)
    self.bitmap=@contents
    refresh
  end

  def drawrect(bm,x,y,width,height,color)
    bm.fill_rect(x,y,width,1,color)
    bm.fill_rect(x,y+height-1,width,1,color)
    bm.fill_rect(x,y,1,height,color)
    bm.fill_rect(x+width-1,y,1,height,color)
  end

  def drawborder(bm,x,y,width,height,color)
    bm.fill_rect(x,y,width,2,color)
    bm.fill_rect(x,y+height-2,width,2,color)
    bm.fill_rect(x,y,2,height,color)
    bm.fill_rect(x+width-2,y,2,height,color)
  end

  def refresh
    @contents.clear
    color=Color.new(180,180,180)
    @contents.fill_rect(0,0,@contents.width,@contents.height,color)
    @contents.blt(0,0,@arrows.bitmap,Rect.new(0,0,8,96))
    @contents.blt(392,0,@arrows.bitmap,Rect.new(8,0,8,96))
    havebitmap=(self.animbitmap && !self.animbitmap.disposed?)
    if havebitmap
      rect=Rect.new(0,0,0,0)
      rectdst=Rect.new(0,0,0,0)
      x=8
      for i in 0...4
        j=i+@start
        rect.set((j%5)*192,(j/5)*192,192,192)
        rectdst.set(x,0,96,96)
        @contents.stretch_blt(rectdst,self.animbitmap,rect)
        x+=96
      end
    end
    color=Color.new(100,100,100)
    swatchrects=[
       Rect.new(8,0,96,96),
       Rect.new(104,0,96,96),
       Rect.new(200,0,96,96),
       Rect.new(296,0,96,96)
    ]
    for i in 0...4
      drawrect(@contents,
         swatchrects[i].x,
         swatchrects[i].y,
         swatchrects[i].width,
         swatchrects[i].height,
         color)
      if @start+i==@selected && havebitmap
        drawborder(@contents,
           swatchrects[i].x,
           swatchrects[i].y,
           swatchrects[i].width,
           swatchrects[i].height,
           Color.new(255,0,0))         
      end
    end
  end

  def changed?
    return @changed
  end

  def update
    mousepos=Mouse::getMousePos
    @changed=false
    return if !Input.repeatex?(Input::LeftMouseKey)
    return if !mousepos
    return if !self.animbitmap
    maxindex=(self.animbitmap.height/192)*5
    left=Rect.new(0,0,8,96)
    right=Rect.new(392,0,8,96)
    left.x+=self.x
    left.y+=self.y
    right.x+=self.x
    right.y+=self.y
    swatchrects=[
       Rect.new(8+self.x,self.y,96,96),
       Rect.new(104+self.x,self.y,96,96),
       Rect.new(200+self.x,self.y,96,96),
       Rect.new(296+self.x,self.y,96,96)
    ]
    for i in 0...4
      if swatchrects[i].contains(mousepos[0],mousepos[1])
        @selected=@start+i
        @changed=true
        refresh
        return
      end
    end
    # Left arrow 
    if left.contains(mousepos[0],mousepos[1])
      if Input.repeatcount(0x01)>30
        @start-=3
      else
        @start-=1
      end
      @start=0 if @start<0
      refresh
    end
    # Right arrow
    if right.contains(mousepos[0],mousepos[1])
      if Input.repeatcount(0x01)>30
        @start+=3
      else
        @start+=1
      end
      @start=maxindex if @start>=maxindex
      refresh
    end
  end
end



class InvalidatableSprite < Sprite
  def initialize(viewport=nil)
    super(viewport)
    @invalid=false
  end

# Marks that the control must be redrawn to reflect current logic.
  def invalidate
    @invalid=true
  end

# Determines whether the control is invalid
  def invalid?
    return @invalid
  end

# Marks that the control is valid.  Normally called only by repaint.
  def validate
    @invalid=false
  end

# Redraws the sprite only if it is invalid, and then revalidates the sprite
  def repaint
    if self.invalid?
      refresh
      validate
    end
  end

 # Redraws the sprite.  This method should not check whether
 # the sprite is invalid, to allow it to be explicitly called.
  def refresh
  end

 # Updates the logic on the sprite, for example, in response
 # to user input, and invalidates it if necessary.  This should
 # be called only once per frame.
  def update
    super
  end
end



class SpriteFrame < InvalidatableSprite
  attr_reader :id
  attr_reader :locked
  attr_reader :selected
  attr_reader :sprite

  def sprite=(value)
    @sprite=value
    self.invalidate
  end

  def locked=(value)
    @locked=value
    self.invalidate
  end

  def selected=(value)
    @selected=value
    self.invalidate
  end

  def initialize(id,sprite,viewport)
    super(viewport)
    @id=id
    @sprite=sprite
    @locked=false
    @selected=false
    @contents=Bitmap.new(128,128)
    @iconbitmap=AnimatedBitmap.new("Graphics/Pictures/icon")
    self.bitmap=@contents
    self.invalidate
  end

  def dispose
    @contents.dispose
    super
  end

  def refresh
    selcolor=Color.new(0,0,0)
    unselcolor=Color.new(220,220,220)
    @contents.clear
    color=(@selected) ? selcolor : unselcolor
    @contents.fill_rect(0,0,128,1,color)
    @contents.fill_rect(0,127,128,1,color)
    @contents.fill_rect(0,0,1,128,color)
    @contents.fill_rect(127,0,1,128,color)
    bmrect=Rect.new((@id%10)*16,(@id/10)*16,16,16)
    @contents.blt(0,0,@iconbitmap.bitmap,bmrect)
    if @locked
      bmrect=Rect.new(0,48,16,16)
      @contents.blt(16,0,@iconbitmap.bitmap,bmrect)
    end
  end
end



class AnimationCanvas < Sprite
  attr_reader :currentframe # Currently active frame
  attr_reader :currentcel
  attr_reader :animation # Currently selected animation
  attr_reader :animbitmap # Currently selected animation bitmap
  attr_accessor :pattern  # Currently selected pattern

  def initialize(animation,viewport=nil)
    super(viewport)
    @currentframe=0
    @currentcel=-1
    @pattern=0
    @sprites=[]
    @framesprites=[]
    @dirty=[]
    @viewport=viewport
    @selecting=false
    @selectOffsetX=0
    @selectOffsetY=0
    @playing=false
    @playingframe=0
    @player=nil
    @user=AnimatedBitmap.new("Graphics/Pictures/testback").deanimate
    @target=AnimatedBitmap.new("Graphics/Pictures/testfront").deanimate
    @testscreen=AnimatedBitmap.new("Graphics/Pictures/testscreen")
    self.bitmap=@testscreen.bitmap
    for i in 0...PBAnimation::MAXSPRITES
      @sprites[i]=Sprite.new(viewport)
      @framesprites[i]=SpriteFrame.new(i,@sprites[i],viewport)
      @framesprites[i].selected=false
      @sprites[i].visible=false
      @framesprites[i].visible=false
      @sprites[i].src_rect=Rect.new(0,0,0,0)
      @sprites[i].bitmap=nil
      @dirty[i]=true
    end
    loadAnimation(animation)
  end

  def locked?(celindex)
    cel=@animation[self.currentframe]
    return false if !cel
    cel=cel[celindex]
    return cel ? (cel[AnimFrame::LOCKED]!=0) : false
  end

  def deletable?(celindex)
    cel=@animation[self.currentframe]
    return true if !cel
    cel=cel[celindex]
    return true if !cel
    return false if cel[AnimFrame::LOCKED]!=0
    if cel[AnimFrame::PATTERN]<0
      count=0
      pattern=cel[AnimFrame::PATTERN]
      for i in 0...PBAnimation::MAXSPRITES
        othercel=@animation[self.currentframe][i]
        count+=1 if othercel && othercel[AnimFrame::PATTERN]==pattern
      end
      return false if count<=1
    end
    return true
  end

  def loadAnimation(anim)
    @animation=anim
    @animbitmap.dispose if @animbitmap
    if @animation.graphic==""
      @animbitmap=nil
    else
      begin
        @animbitmap=AnimatedBitmap.new("Graphics/Animations/"+@animation.graphic,
           @animation.hue).deanimate
        rescue
        @animbitmap=nil
      end
    end
    @currentcel=-1
    self.currentframe=0
    @selecting=false
    @pattern=0
    self.invalidate
  end

  def animbitmap=(value)
    @animbitmap.dispose if @animbitmap
    @animbitmap=value
    for i in 2...PBAnimation::MAXSPRITES
      @sprites[i].bitmap=@animbitmap
    end
    self.invalidate
  end

  def dispose
    @user.dispose
    @target.dispose
    @animbitmap.dispose if @animbitmap
    @selectedbitmap.dispose if @selectedbitmap
    @celbitmap.dispose if @celbitmap
    self.bitmap.dispose if self.bitmap
    for i in 0...PBAnimation::MAXSPRITES
      @sprites[i].dispose
    end
    super
  end

  def play
    if !@playing
      usersprite=Sprite.new(@viewport)
      usersprite.bitmap=@user
      pbSpriteSetAnimFrame(usersprite,pbCreateCel(128,224,-1)) # 144,188
      targetsprite=Sprite.new(@viewport)
      targetsprite.bitmap=@target
      pbSpriteSetAnimFrame(targetsprite,pbCreateCel(384,98,-2)) # 352,108
      @player=PBAnimationPlayer.new(@animation,
         usersprite,targetsprite,@viewport)
      @player.start
      @playing=true
      oldstate=[]
      for i in 0...PBAnimation::MAXSPRITES
        oldstate.push([@sprites[i].visible,@framesprites[i].visible])
        @sprites[i].visible=false
        @framesprites[i].visible=false
      end
      begin
        Graphics.update
        self.update
      end while @playing
      for i in 0...PBAnimation::MAXSPRITES
        @sprites[i].visible=oldstate[i][0]
        @framesprites[i].visible=oldstate[i][1]
      end
      usersprite.dispose
      targetsprite.dispose
      @player.dispose
      @player=nil
    end
  end

  def invalidate
    for i in 0...PBAnimation::MAXSPRITES
      @dirty[i]=true
    end   
  end

  def currentframe=(value)
    @currentframe=value
    invalidate
  end

  # Clears all items in the frame except locked items
  def clearFrame(frame)
    if frame>=0 && frame<@animation.length
      for i in 0...PBAnimation::MAXSPRITES
        if self.deletable?(i)
          @animation[frame][i]=nil
        else
          pbResetCel(@animation[frame][i])
        end
        @dirty[i]=true if frame==@currentframe 
      end
    end
  end

  def offsetFrame(frame,ox,oy)
    if frame>=0 && frame<@animation.length
      for i in 0...PBAnimation::MAXSPRITES
        if !self.locked?(i) && @animation[frame][i]
          @animation[frame][i][AnimFrame::X]+=ox
          @animation[frame][i][AnimFrame::Y]+=oy
        end
        @dirty[i]=true if frame==@currentframe 
      end
    end
  end

  def deleteFrame(frame)
    return if frame <0 || frame>=@animation.length || @animation.length<=1
    @animation.delete_at(frame)
    @currentcel=-1
    self.invalidate
  end

  def pasteFrame(frame)
    return if frame <0 || frame>=@animation.length
    return if Clipboard.typekey!="PBAnimFrame"
    @animation[frame]=Clipboard.data
    self.invalidate if frame==@currentframe
  end

  def pasteCel(x,y)
    return if @currentframe>=@animation.length
    return if Clipboard.typekey!="PBAnimCel"
    for i in 0...PBAnimation::MAXSPRITES
      next if @animation[@currentframe][i]
      @animation[@currentframe][i]=Clipboard.data
      cel=@animation[@currentframe][i]
      cel[AnimFrame::X]=x
      cel[AnimFrame::Y]=y
      cel[AnimFrame::LOCKED]=0
      @sprites[i].bitmap=@user if cel[AnimFrame::PATTERN]==-1
      @sprites[i].bitmap=@target if cel[AnimFrame::PATTERN]==-2
      @currentcel=i
      break
    end
    invalidate
  end

  def deleteCel(cel)
    return if cel<0
    return if @currentframe <0 || @currentframe>=@animation.length
    return if !deletable?(cel)
    @animation[@currentframe][cel]=nil
    @dirty[cel]=true
  end

  def insertFrame(frame)
    return if frame>=@animation.length
    @animation.insert(frame,@animation[frame].clone)
    self.invalidate
  end

  def copyFrame(src,dst)
    return if dst>=@animation.length
    for i in 0...PBAnimation::MAXSPRITES
      clonedframe=@animation[src][i]
      clonedframe=clonedframe.clone if clonedframe && clonedframe!=true
      @animation[dst][i]=clonedframe
    end
    self.invalidate if dst==@currentframe
  end

  # This frame becomes a copy of the previous frame
  def pasteLast
    copyFrame(@currentframe-1,@currentframe) if @currentframe>0
  end

  def setBitmap(i,frame)
    if @sprites[i]
      cel=@animation[frame][i]
      @sprites[i].bitmap=@animbitmap
      if cel
        @sprites[i].bitmap=@user if cel[AnimFrame::PATTERN]==-1
        @sprites[i].bitmap=@target if cel[AnimFrame::PATTERN]==-2
      end
    end
  end

  def setSpriteBitmap(sprite,cel)
    if sprite && !sprite.disposed?
      sprite.bitmap=@animbitmap
      if cel
        sprite.bitmap=@user if cel[AnimFrame::PATTERN]==-1
        sprite.bitmap=@target if cel[AnimFrame::PATTERN]==-2
      end
    end
  end

  def setFrame(i)
    if @sprites[i]
      @framesprites[i].ox=64
      @framesprites[i].oy=64
      @framesprites[i].selected=(i==@currentcel)
      @framesprites[i].locked=self.locked?(i)
      @framesprites[i].x=@sprites[i].x
      @framesprites[i].y=@sprites[i].y
      @framesprites[i].visible=@sprites[i].visible
      @framesprites[i].repaint
    end
  end

  def invalidateCel(i)
    @dirty[i]=true
  end

  def addSprite(x,y)
    return false if @currentframe>=@animation.length
    for i in 0...PBAnimation::MAXSPRITES
      next if @animation[@currentframe][i]
      @animation[@currentframe][i]=pbCreateCel(x,y,@pattern)
      @dirty[i]=true
      @currentcel=i
      return true
    end
    return false
  end

  def currentCel
    return nil if @currentcel<0
    return nil if @currentframe>=@animation.length
    return @animation[@currentframe][@currentcel]
  end

  def getCurrentFrame
    return nil if @currentframe>=@animation.length
    return @animation[@currentframe]
  end

  def updateInput
    cel=currentCel
    mousepos=Mouse::getMousePos
    if mousepos && pbSpriteHitTest(self,mousepos[0],mousepos[1],false,true)
      if Input.triggerex?(Input::LeftMouseKey) # Left mouse button
        selectedcel=-1
        maxspr=PBAnimation::MAXSPRITES
        usealpha=(Input.press?(Input::ALT)) ? true : false 
        for j in 0...maxspr
          if pbSpriteHitTest(@sprites[j],mousepos[0],mousepos[1],usealpha,false)
            selectedcel=j
          end
        end
        if selectedcel<0
          if @animbitmap && addSprite(mousepos[0],mousepos[1])
            @selecting=true if !self.locked?(@currentcel)
            @selectOffsetX=0
            @selectOffsetY=0
            cel=currentCel
            invalidate
          end
        else
          @currentcel=selectedcel
          @selecting=true if !self.locked?(@currentcel)
          cel=currentCel
          if @animation.position>=3 || cel[AnimFrame::PATTERN]<0
            @selectOffsetX=cel[AnimFrame::X]-mousepos[0]
            @selectOffsetY=cel[AnimFrame::Y]-mousepos[1]
          else
            @selectOffsetX=cel[AnimFrame::X]-mousepos[0]+384
            @selectOffsetY=cel[AnimFrame::Y]-mousepos[1]+98
          end
          invalidate
        end
      end
    end
    currentFrame=getCurrentFrame
    if currentFrame && !@selecting && Input.repeatex?(0x09) # Tab
      currentFrame.length.times {
         @currentcel+=1
         @currentcel=0 if @currentcel>=currentFrame.length
         break if currentFrame[@currentcel]
      }
      invalidate
      return
    end
    if cel && @selecting && mousepos
      if @animation.position>=3 || cel[AnimFrame::PATTERN]<0
        cel[AnimFrame::X]=mousepos[0]+@selectOffsetX
        cel[AnimFrame::Y]=mousepos[1]+@selectOffsetY
      else
        cel[AnimFrame::X]=mousepos[0]+@selectOffsetX-384
        cel[AnimFrame::Y]=mousepos[1]+@selectOffsetY-98
      end
      @dirty[@currentcel]=true
    end
    if !Input.getstate(0x01) && @selecting
      @selecting=false
    end
    # "Delete"
    if cel && Input.repeatex?(0x2E) && self.deletable?(@currentcel)
      @animation[@currentframe][@currentcel]=nil
      @dirty[@currentcel]=true
      return
    end
    if cel && Input.repeatex?(0x50)
      pbCellProperties(self)
      @dirty[@currentcel]=true
      return
    end
    if cel && Input.repeatex?(0x4C) # "L" for lock
      cel[AnimFrame::LOCKED]=(cel[AnimFrame::LOCKED]==0)?1:0
      @dirty[@currentcel]=true
    end  
    if cel && Input.repeatex?(0x52) # "R" for rotate left
      cel[AnimFrame::ANGLE]+=10
      cel[AnimFrame::ANGLE]%=360
      @dirty[@currentcel]=true
    end
    if cel && Input.repeatex?(0x45) # "E" for rotate left
      cel[AnimFrame::ANGLE]-=10
      cel[AnimFrame::ANGLE]%=360
      @dirty[@currentcel]=true
    end
    if cel && Input.repeatex?(0x6B) # "+" for zoom in
      cel[AnimFrame::ZOOMX]+=10
      cel[AnimFrame::ZOOMX]=1000 if cel[AnimFrame::ZOOMX]>1000
      cel[AnimFrame::ZOOMY]+=10
      cel[AnimFrame::ZOOMY]=1000 if cel[AnimFrame::ZOOMY]>1000
      @dirty[@currentcel]=true
    end
    if cel && Input.repeatex?(0x6D) # "-" for zoom in
      cel[AnimFrame::ZOOMX]-=10
      cel[AnimFrame::ZOOMX]=10 if cel[AnimFrame::ZOOMX]<10
      cel[AnimFrame::ZOOMY]-=10
      cel[AnimFrame::ZOOMY]=10 if cel[AnimFrame::ZOOMY]<10
      @dirty[@currentcel]=true
    end
    increment=(Input.press?(Input::ALT)) ? 2 : 8
    if cel && Input.repeat?(Input::LEFT) &&  !self.locked?(@currentcel)
      cel[AnimFrame::X]-=(cel[AnimFrame::X]%increment)
      cel[AnimFrame::X]-=increment
      if @animation.position>=3 || cel[AnimFrame::PATTERN]<0
        cel[AnimFrame::X]=0 if cel[AnimFrame::X]<0
      end
      @dirty[@currentcel]=true
    end
    if cel && Input.repeat?(Input::RIGHT) &&  !self.locked?(@currentcel)
      cel[AnimFrame::X]-=(cel[AnimFrame::X]%increment)
      cel[AnimFrame::X]+=increment
      cel[AnimFrame::X]=512 if cel[AnimFrame::X]>512
      @dirty[@currentcel]=true
    end
    if cel && Input.repeat?(Input::UP) &&  !self.locked?(@currentcel)
      cel[AnimFrame::Y]-=increment
      if @animation.position>=3 || cel[AnimFrame::PATTERN]<0
        cel[AnimFrame::Y]=0 if cel[AnimFrame::Y]<0
      end
      @dirty[@currentcel]=true
    end
    if cel && Input.repeat?(Input::DOWN) &&  !self.locked?(@currentcel)
      cel[AnimFrame::Y]+=increment
      cel[AnimFrame::Y]=384 if cel[AnimFrame::Y]>384
      @dirty[@currentcel]=true
    end
  end

  def update
    super
    if @playing
      if !@player.playing?
        @playing=false
        invalidate
      else
        @player.update
      end
      return
    end
    updateInput
    @testscreen.update
    self.bitmap=@testscreen.bitmap
    if @currentframe < @animation.length
      count=0
      for i in 0...PBAnimation::MAXSPRITES
        if @dirty[i] && @sprites[i]
          setBitmap(i,@currentframe)
          pbSpriteSetAnimFrame(@sprites[i],@animation[@currentframe][i],true)
          if @animation.position<3 && @animation[@currentframe][i] &&
             @animation[@currentframe][i][AnimFrame::PATTERN]>=0
            @sprites[i].x+=384
            @sprites[i].y+=98
          end
          setFrame(i)
          @dirty[i]=false
        end
      end
    else
      for i in 0...PBAnimation::MAXSPRITES
        pbSpriteSetAnimFrame(@sprites[i],nil,true)
        setFrame(i)
        @dirty[i]=false   
      end
    end
  end
end



class FrameCountSlider < Slider
  def maxvalue
    return @canvas.animation.length-1
  end

  def initialize(canvas)
    @canvas=canvas
    super(_INTL("Frame:"),0,canvas.animation.length-1,0)
  end
end



class ArrayCountSlider < Slider
  def maxvalue
    return @array.length-1
  end

  def initialize(array,label)
    @array=array
    super(label,0,canvas.animation.length-1,0)
  end
end



class FrameCountButton < Button
  def label
    return _INTL("Frames: {1}",@canvas.animation.length)
  end

  def initialize(canvas)
    @canvas=canvas
    super(self.label)
  end
end



class CanvasAnimationWindow < AnimationWindow
  def animbitmap
    return @canvas.animbitmap
  end

  def initialize(canvas,viewport=nil)
    @canvas=canvas
    super(viewport)
  end    
end



def pbSetTone(cel)
  sliderwin2=ControlWindow.new(0,0,320,320)
  sliderwin2.z=99999
  sliderwin2.addSlider(_INTL("Red Offset:"),-255,255,cel[AnimFrame::TONERED])
  sliderwin2.addSlider(_INTL("Green Offset:"),-255,255,cel[AnimFrame::TONEGREEN])
  sliderwin2.addSlider(_INTL("Blue Offset:"),-255,255,cel[AnimFrame::TONEBLUE])
  sliderwin2.addSlider(_INTL("Gray Tone:"),0,255,cel[AnimFrame::TONEGRAY])
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton)
      cel[AnimFrame::TONERED]=sliderwin2.value(0)
      cel[AnimFrame::TONEGREEN]=sliderwin2.value(1)
      cel[AnimFrame::TONEBLUE]=sliderwin2.value(2)
      cel[AnimFrame::TONEGRAY]=sliderwin2.value(3)
      break
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  sliderwin2.dispose
  return
end

def pbSetFlash(cel)
  sliderwin2=ControlWindow.new(0,0,320,320)
  sliderwin2.z=99999
  sliderwin2.addSlider(_INTL("Red:"),0,255,cel[AnimFrame::COLORRED])
  sliderwin2.addSlider(_INTL("Green:"),0,255,cel[AnimFrame::COLORGREEN])
  sliderwin2.addSlider(_INTL("Blue:"),0,255,cel[AnimFrame::COLORBLUE])
  sliderwin2.addSlider(_INTL("Alpha:"),0,255,cel[AnimFrame::COLORALPHA])
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton)
      cel[AnimFrame::COLORRED]=sliderwin2.value(0)
      cel[AnimFrame::COLORGREEN]=sliderwin2.value(1)
      cel[AnimFrame::COLORBLUE]=sliderwin2.value(2)
      cel[AnimFrame::COLORALPHA]=sliderwin2.value(3)
      break
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  sliderwin2.dispose
  return
end

def pbTrackPopupMenu(commands)
  mousepos=Mouse::getMousePos
  return -1 if !mousepos
  menuwindow=Window_Menu.new(commands,mousepos[0],mousepos[1])
  menuwindow.z=99999
  loop do
    Graphics.update
    Input.update
    menuwindow.update
    hit=menuwindow.hittest
    menuwindow.index=hit if hit>=0
    if Input.triggerex?(Input::LeftMouseKey) || Input.triggerex?(Input::RightMouseKey) # Left or right button
      menuwindow.dispose
      return hit
    end
    if Input.trigger?(Input::C)
      hit=menuwindow.index
      menuwindow.dispose
      return hit   
    end
    if Input.trigger?(Input::B) # Escape
      break
    end
  end
  menuwindow.dispose
  return -1
end

def pbTweening(canvas)
  sliderwin2=ControlWindow.new(0,0,320,480)
  sliderwin2.viewport=canvas.viewport
  s1set0=sliderwin2.addSlider(_INTL("Starting Frame:"),0,canvas.animation.length-1,0)
  s1set1=sliderwin2.addSlider(_INTL("Ending Frame:"),0,canvas.animation.length-1,canvas.animation.length-1)
  s1set2=sliderwin2.addSlider(_INTL("First Cel:"),0,PBAnimation::MAXSPRITES-1,0)
  s1set3=sliderwin2.addSlider(_INTL("Last Cel:"),0,PBAnimation::MAXSPRITES-1,PBAnimation::MAXSPRITES-1)
  set0=sliderwin2.addControl(Checkbox.new(_INTL("Pattern")))
  set1=sliderwin2.addControl(Checkbox.new(_INTL("Position/Zoom/Angle")))
  set2=sliderwin2.addControl(Checkbox.new(_INTL("Opacity/Blending")))
  #set2=sliderwin2.addControl(Checkbox.new(_INTL("Opacity/Blending")))
  set3=sliderwin2.addControl(Checkbox.new(_INTL("Flip/Priority")))
  set4=sliderwin2.addControl(Checkbox.new(_INTL("Angle")))
  set5=sliderwin2.addControl(Checkbox.new(_INTL("Position")))
  set6=sliderwin2.addControl(Checkbox.new(_INTL("Zoom")))

  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton) || Input.trigger?(Input::C)
      startframe=sliderwin2.value(s1set0)
      endframe=sliderwin2.value(s1set1)
      break if startframe>=endframe
      frames=endframe-startframe
      startcel=sliderwin2.value(s1set2)
      endcel=sliderwin2.value(s1set3)
      for j in startcel..endcel
        cel1=canvas.animation[startframe][j]
        cel2=canvas.animation[endframe][j]
        next if !cel1||!cel2
        diffPattern=cel2[AnimFrame::PATTERN]-cel1[AnimFrame::PATTERN]
        diffX=cel2[AnimFrame::X]-cel1[AnimFrame::X]
        diffY=cel2[AnimFrame::Y]-cel1[AnimFrame::Y]
        diffZoomX=cel2[AnimFrame::ZOOMX]-cel1[AnimFrame::ZOOMX]
        diffZoomY=cel2[AnimFrame::ZOOMY]-cel1[AnimFrame::ZOOMY]
        diffAngle=cel2[AnimFrame::ANGLE]-cel1[AnimFrame::ANGLE]
        diffOpacity=cel2[AnimFrame::OPACITY]-cel1[AnimFrame::OPACITY]
        diffBlend=cel2[AnimFrame::BLENDTYPE]-cel1[AnimFrame::BLENDTYPE]
        diffFlip=cel2[AnimFrame::MIRROR]-cel1[AnimFrame::MIRROR]
        diffPriority=cel2[AnimFrame::PRIORITY]-cel1[AnimFrame::PRIORITY]
        startPattern=cel1[AnimFrame::PATTERN]
        startX=cel1[AnimFrame::X]
        startFlip=cel1[AnimFrame::MIRROR]
        startY=cel1[AnimFrame::Y]
        startZoomX=cel1[AnimFrame::ZOOMX]
        #startZoomX=cel1[AnimFrame::PRIORITY]
        startZoomY=cel1[AnimFrame::ZOOMY]
        startAngle=cel1[AnimFrame::ANGLE]
        startOpacity=cel1[AnimFrame::OPACITY]
        startBlend=cel1[AnimFrame::BLENDTYPE]
        startPriority=cel1[AnimFrame::PRIORITY]
        for k in 0..frames
          cel=canvas.animation[startframe+k][j]
          curcel=cel
          if !cel
            cel=pbCreateCel(0,0,0)
            canvas.animation[startframe+k][j]=cel
          end
          if sliderwin2.value(set0) || !curcel
            cel[AnimFrame::PATTERN]=startPattern+(diffPattern*k/frames)
          end
          if sliderwin2.value(set1) || !curcel
            cel[AnimFrame::X]=startX+(diffX*k/frames)
            cel[AnimFrame::Y]=startY+(diffY*k/frames)
            cel[AnimFrame::ZOOMX]=startZoomX+(diffZoomX*k/frames)
            cel[AnimFrame::ZOOMY]=startZoomY+(diffZoomY*k/frames)
            cel[AnimFrame::ANGLE]=startAngle+(diffAngle*k/frames)
          end
          if sliderwin2.value(set2) || !curcel
            cel[AnimFrame::OPACITY]=startOpacity+(diffOpacity*k/frames)
            cel[AnimFrame::BLENDTYPE]=startBlend+(diffBlend*k/frames)
          end
                    if sliderwin2.value(set3) || !curcel
            cel[AnimFrame::MIRROR]=startFlip+(diffFlip*k/frames)
            cel[AnimFrame::PRIORITY]=startPriority+(diffPriority*k/frames)
          end
          if sliderwin2.value(set4) || !curcel
            cel[AnimFrame::ANGLE]=startAngle+(diffAngle*k/frames)
          end
          if sliderwin2.value(set5) || !curcel
            cel[AnimFrame::X]=startX+(diffX*k/frames)
            cel[AnimFrame::Y]=startY+(diffY*k/frames)
          end
          if sliderwin2.value(set6) || !curcel
            cel[AnimFrame::ZOOMX]=startZoomX+(diffZoomX*k/frames)
            cel[AnimFrame::ZOOMY]=startZoomY+(diffZoomY*k/frames)
          end
        end
      end
      canvas.invalidate
      break
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  sliderwin2.dispose
end

def pbCellBatch(canvas)
  sliderwin1=ControlWindow.new(0,0,320,200)
  sliderwin1.viewport=canvas.viewport
  s1set0=sliderwin1.addSlider(_INTL("First Frame:"),0,canvas.animation.length-1,0)
  s1set1=sliderwin1.addSlider(_INTL("Last Frame:"),0,canvas.animation.length-1,canvas.animation.length-1)
  s1set2=sliderwin1.addSlider(_INTL("First Cel:"),0,PBAnimation::MAXSPRITES-1,0)
  s1set3=sliderwin1.addSlider(_INTL("Last Cel:"),0,PBAnimation::MAXSPRITES-1,PBAnimation::MAXSPRITES-1)
  sliderwin2=ControlWindow.new(320,0,320,480)
  sliderwin2.viewport=canvas.viewport
  set0=sliderwin2.addControl(OptionalSlider.new(_INTL("Pattern:"),-2,1000,0))
  set1=sliderwin2.addControl(OptionalSlider.new(_INTL("X:"),-64,544,0))
  set2=sliderwin2.addControl(OptionalSlider.new(_INTL("Y:"),-64,384,0))
  set3=sliderwin2.addControl(OptionalSlider.new(_INTL("Zoom X:"),5,1000,100))
  set4=sliderwin2.addControl(OptionalSlider.new(_INTL("Zoom Y:"),5,1000,100))
  set5=sliderwin2.addControl(OptionalSlider.new(_INTL("Angle:"),0,359,0))
  set6=sliderwin2.addControl(OptionalSlider.new(_INTL("Opacity:"),0,255,255))
  set7=sliderwin2.addControl(OptionalSlider.new(_INTL("Blending:"),0,2,0))
  set8=sliderwin2.addControl(OptionalSlider.new(_INTL("Flip:"),0,1,0))
  set9=sliderwin2.addControl(OptionalSlider.new(_INTL("Priority:"),-1,2,0))
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton) || Input.trigger?(Input::C)
      startframe=sliderwin1.value(s1set0)
      endframe=sliderwin1.value(s1set1)
      startcel=sliderwin1.value(s1set2)
      endcel=sliderwin1.value(s1set3)
      for i in startframe..endframe
        for j in startcel..endcel
          next if !canvas.animation[i][j]
          cel=canvas.animation[i][j]
          cel[AnimFrame::PATTERN]=sliderwin2.value(set0) if sliderwin2.value(set0)
          cel[AnimFrame::X]=sliderwin2.value(set1) if sliderwin2.value(set1)
          cel[AnimFrame::Y]=sliderwin2.value(set2) if sliderwin2.value(set2)
          cel[AnimFrame::ZOOMX]=sliderwin2.value(set3) if sliderwin2.value(set3)
          cel[AnimFrame::ZOOMY]=sliderwin2.value(set4) if sliderwin2.value(set4)
          cel[AnimFrame::ANGLE]=sliderwin2.value(set5) if sliderwin2.value(set5)
          cel[AnimFrame::OPACITY]=sliderwin2.value(set6) if sliderwin2.value(set6)
          cel[AnimFrame::BLENDTYPE]=sliderwin2.value(set7) if sliderwin2.value(set7)
          cel[AnimFrame::MIRROR]=sliderwin2.value(set8) if sliderwin2.value(set8)
          cel[AnimFrame::PRIORITY]=sliderwin2.value(set9) if sliderwin2.value(set9)
        end
      end
      canvas.invalidate
      break
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  sliderwin1.dispose
  sliderwin2.dispose
end

def pbCellProperties(canvas)
  cel=canvas.currentCel.clone # Clone cell, in case operation is canceled
  return if !cel
  sliderwin2=ControlWindow.new(0,0,320,480)
  previewwin=ControlWindow.new(320,0,160,160)
  sliderwin2.viewport=canvas.viewport
  previewwin.viewport=canvas.viewport
  previewsprite=Sprite.new(canvas.viewport)
  previewsprite.bitmap=canvas.animbitmap
  set0=sliderwin2.addSlider(_INTL("Pattern:"),-2,1000,cel[AnimFrame::PATTERN])
  set1=sliderwin2.addSlider(_INTL("X:"),-64,544,cel[AnimFrame::X])
  set2=sliderwin2.addSlider(_INTL("Y:"),-64,384,cel[AnimFrame::Y])
  set3=sliderwin2.addSlider(_INTL("Zoom X:"),10,1000,cel[AnimFrame::ZOOMX])
  set4=sliderwin2.addSlider(_INTL("Zoom Y:"),10,1000,cel[AnimFrame::ZOOMY])
  set5=sliderwin2.addSlider(_INTL("Angle:"),0,359,cel[AnimFrame::ANGLE])
  set6=sliderwin2.addSlider(_INTL("Opacity:"),0,255,cel[AnimFrame::OPACITY])
  set7=sliderwin2.addSlider(_INTL("Blending:"),0,2,cel[AnimFrame::BLENDTYPE])
  set8=sliderwin2.addSlider(_INTL("Flip:"),0,1,cel[AnimFrame::MIRROR])
  set9=sliderwin2.addSlider(_INTL("Priority:"),-1,2,cel[AnimFrame::PRIORITY])
  # Set X and Y for preview sprite
  cel[AnimFrame::X]=400
  cel[AnimFrame::Y]=80
  canvas.setSpriteBitmap(previewsprite,cel)
  pbSpriteSetAnimFrame(previewsprite,cel)
  flashbutton=sliderwin2.addButton(_INTL("Set Blending Color"))
  tonebutton=sliderwin2.addButton(_INTL("Set Color Tone"))
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  sliderwin2.opacity=200
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(set0) ||
       sliderwin2.changed?(set3) ||
       sliderwin2.changed?(set4) ||
       sliderwin2.changed?(set5) ||
       sliderwin2.changed?(set6) ||
       sliderwin2.changed?(set7) ||
       sliderwin2.changed?(set8) ||
       sliderwin2.changed?(set9)
      # Update preview sprite
      cel[AnimFrame::PATTERN]=sliderwin2.value(set0) if set0>=0
      cel[AnimFrame::ZOOMX]=sliderwin2.value(set3)
      cel[AnimFrame::ZOOMY]=sliderwin2.value(set4)
      cel[AnimFrame::ANGLE]=sliderwin2.value(set5)
      cel[AnimFrame::OPACITY]=sliderwin2.value(set6)
      cel[AnimFrame::BLENDTYPE]=sliderwin2.value(set7)
      cel[AnimFrame::MIRROR]=sliderwin2.value(set8)
      cel[AnimFrame::PRIORITY]=sliderwin2.value(set9)
      canvas.setSpriteBitmap(previewsprite,cel)
      pbSpriteSetAnimFrame(previewsprite,cel)
    end
    if sliderwin2.changed?(flashbutton)
      pbSetFlash(cel)
      pbSpriteSetAnimFrame(previewsprite,cel)
    end
    if sliderwin2.changed?(tonebutton)
      pbSetTone(cel)
      pbSpriteSetAnimFrame(previewsprite,cel)
    end
    if sliderwin2.changed?(okbutton)
      cel[AnimFrame::PATTERN]=sliderwin2.value(set0) if set0>=0
      cel[AnimFrame::X]=sliderwin2.value(set1)
      cel[AnimFrame::Y]=sliderwin2.value(set2)
      cel[AnimFrame::ZOOMX]=sliderwin2.value(set3)
      cel[AnimFrame::ZOOMY]=sliderwin2.value(set4)
      cel[AnimFrame::ANGLE]=sliderwin2.value(set5)
      cel[AnimFrame::OPACITY]=sliderwin2.value(set6)
      cel[AnimFrame::BLENDTYPE]=sliderwin2.value(set7)
      cel[AnimFrame::MIRROR]=sliderwin2.value(set8)
      cel[AnimFrame::PRIORITY]=sliderwin2.value(set9)
      thiscel=canvas.currentCel
      # Save by replacing current cell
      thiscel[0,thiscel.length]=cel
      break
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  previewwin.dispose
  previewsprite.dispose
  sliderwin2.dispose
  return
end

def pbChangeMaximum(canvas)
  sliderwin2=ControlWindow.new(0,0,320,320)
  sliderwin2.viewport=canvas.viewport
  sliderwin2.addSlider(_INTL("Frames:"),1,1000,canvas.animation.length)
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  sliderwin2.opacity=200
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton)
      canvas.animation.resize(sliderwin2.value(0))
      break
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  sliderwin2.dispose
  return
end

def pbCopyFrames(canvas)
  sliderwin2=ControlWindow.new(0,0,320,320)
  sliderwin2.viewport=canvas.viewport
  sliderwin2.addSlider(_INTL("First Frame:"),0,canvas.animation.length-1,0)
  sliderwin2.addSlider(_INTL("Last Frame:"),0,canvas.animation.length-1,
     canvas.animation.length-1)
  sliderwin2.addSlider(_INTL("Copy to:"),0,canvas.animation.length-1,
     canvas.currentframe)
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  sliderwin2.opacity=200
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton)
      startvalue=sliderwin2.value(0)
      endvalue=sliderwin2.value(1)
      dstvalue=sliderwin2.value(2)
      length=(endvalue-startvalue)+1
      if length>0 # Ensure correct overlap handling
        if (startvalue < dstvalue)
          startvalue += length; dstvalue += length; while length!=0
            canvas.copyFrame(startvalue-1,dstvalue-1)
            startvalue-=1
            dstvalue-=1
            length-=1; end
      elsif (startvalue != dstvalue)
        while length!=0
          canvas.copyFrame(startvalue,dstvalue)
          startvalue+=1
          dstvalue+=1
          length-=1
        end
      end
    end
    break
  end
  if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
    break
  end
  end
  sliderwin2.dispose
  return
end

def pbEntireSlide(canvas)
  sliderwin2=ControlWindow.new(0,0,320,320)
  sliderwin2.viewport=canvas.viewport
  sliderwin2.addSlider(_INTL("First Frame:"),0,canvas.animation.length-1,0)
  sliderwin2.addSlider(_INTL("Last Frame:"),0,canvas.animation.length-1,
     canvas.animation.length-1)
  sliderwin2.addSlider(_INTL("X-Axis Movement"),-500,500,0)
  sliderwin2.addSlider(_INTL("Y-Axis Movement"),-500,500,0)
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  sliderwin2.opacity=200
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton)
      startvalue=sliderwin2.value(0)
      endvalue=sliderwin2.value(1)
      xoffset=sliderwin2.value(2)
      yoffset=sliderwin2.value(3)
      for i in startvalue..endvalue
        canvas.offsetFrame(i,xoffset,yoffset)
      end
      break
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  sliderwin2.dispose
  return
end



class ControlPointSprite < SpriteWrapper
  attr_accessor :dragging

  def initialize(red,viewport=nil)
    super(viewport)
    self.bitmap=Bitmap.new(6,6)
    self.bitmap.fill_rect(0,0,6,1,Color.new(0,0,0))
    self.bitmap.fill_rect(0,0,1,6,Color.new(0,0,0))
    self.bitmap.fill_rect(0,5,6,1,Color.new(0,0,0))
    self.bitmap.fill_rect(5,0,1,6,Color.new(0,0,0))
    color=(red) ? Color.new(255,0,0) : Color.new(0,0,0)
    self.bitmap.fill_rect(2,2,2,2,color)
    self.x=-6
    self.y=-6
    self.visible=false
    @dragging=false
  end

  def mouseover
    if Input.repeatcount(0x01)==0 || !@dragging
      @dragging=false
      return
    end
    mouse=Mouse::getMousePos(true)
    self.x=[[mouse[0],0].max,512].min
    self.y=[[mouse[1],0].max,384].min
  end

  def hittest?
    return true if !self.visible
    mouse=Mouse::getMousePos(true)
    return true if mouse[0]>=self.x&&mouse[0]<self.x+6 &&
                   mouse[1]>=self.y&&mouse[1]<self.y+6
  end

  def inspect
    return "[#{self.x},#{self.y}]"
  end

  def dispose
    self.bitmap.dispose
    super
  end
end



def catmullRom(p1,p2,p3,p4,t) 
  # p1=prevPoint, p2=startPoint, p3=endPoint, p4=nextPoint, t is from 0 through 1
  t2=t*t
  t3=t2*t
  return 0.5*(2*p2+t*(p3-p1) +
         t2*(2*p1-5*p2+4*p3-p4)+
         t3*(p4-3*p3+3*p2-p1))
end

def getCubicPoint(src,t)
  x0=src[0].x;
  y0=src[0].y;
  cx0=src[1].x;
  cy0=src[1].y;
  cx1=src[2].x;
  cy1=src[2].y;
  x1=src[3].x;
  y1=src[3].y;
  x1=cx1+(x1-cx1)*t;
  y1=cy1+(y1-cy1)*t;
  x0=x0+(cx0-x0)*t;
  y0=y0+(cy0-y0)*t;
  cx0=cx0+(cx1-cx0)*t;
  cy0=cy0+(cy1-cy0)*t;
  cx1=cx0+(x1-cx0)*t;
  cy1=cy0+(y1-cy0)*t;
  cx0=x0+(cx0-x0)*t;
  cy0=y0+(cy0-y0)*t;
  cx=cx0+(cx1-cx0)*t;
  cy=cy0+(cy1-cy0)*t;
  return [cx,cy]
end

def getCatmullRomPoint(src,t)
  x=0,y=0
  t*=3.0
  if t<1.0
    x=catmullRom(src[0].x,src[0].x,src[1].x,src[2].x,t)
    y=catmullRom(src[0].y,src[0].y,src[1].y,src[2].y,t)
  elsif t<2.0
    t-=1.0
    x=catmullRom(src[0].x,src[1].x,src[2].x,src[3].x,t)
    y=catmullRom(src[0].y,src[1].y,src[2].y,src[3].y,t)
  else
    t-=2.0
    x=catmullRom(src[1].x,src[2].x,src[3].x,src[3].x,t)
    y=catmullRom(src[1].y,src[2].y,src[3].y,src[3].y,t)
  end
  return [x,y]
end

def getCurvePoint(src,t)
  return getCatmullRomPoint(src,t)
end

def curveToPointPath(curve,numpoints)
  if numpoints<2
    return nil
  end
  path=PointPath.new
  step=1.0/(numpoints-1)
  t=0.0
  for i in 0...numpoints
    point=getCurvePoint(curve,t)
    path.addPoint(point[0],point[1])
    t+=step
  end
  return path
end

def pbDefinePath(canvas)
  sliderwin2=ControlWindow.new(0,0,320,320)
  sliderwin2.viewport=canvas.viewport
  sliderwin2.addSlider(_INTL("Number of frames:"),2,500,20)
  sliderwin2.opacity=200
  defcurvebutton=sliderwin2.addButton(_INTL("Define Curve"))
  defpathbutton=sliderwin2.addButton(_INTL("Define Path"))
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  points=[]
  path=nil
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(0)
      if path
        path=path.smoothPointPath(sliderwin2.value(0),false)
        i=0
        for point in path
          if i<points.length
            points[i].x=point[0]
            points[i].y=point[1]
          else
            points.push(PointSprite.new(point[0],point[1],canvas.viewport))
          end
          i+=1
        end
        for j in i...points.length
          points[j].dispose
          points[j]=nil
        end
        points.compact!
#       File.open("pointpath.txt","wb"){|f| f.write(path.inspect) }
      end
    end
    if sliderwin2.changed?(okbutton) && path
#     File.open("pointpath.txt","wb"){|f| 
#        f.write(path.inspect)
#     }
      neededsize=canvas.currentframe+sliderwin2.value(0)
      if neededsize>canvas.animation.length
        canvas.animation.resize(neededsize)
      end
      thiscel=canvas.currentCel
      celnumber=canvas.currentcel
      for i in canvas.currentframe...neededsize
        cel=canvas.animation[i][celnumber]
        if !canvas.animation[i][celnumber]
          cel=pbCreateCel(0,0,thiscel[AnimFrame::PATTERN])
          canvas.animation[i][celnumber]=cel
        end
        cel[AnimFrame::X]=path[i-canvas.currentframe][0]#-374 #adjustment xoffset=-244
        cel[AnimFrame::Y]=path[i-canvas.currentframe][1]#-88
      end
      startframe=sliderwin2.value(0)
      break
    end
    if sliderwin2.changed?(defcurvebutton)
      for point in points
        point.dispose
      end
      points.clear
      30.times do
        point=PointSprite.new(0,0,canvas.viewport)
        point.visible=false
        points.push(point)
      end
      curve=[
         ControlPointSprite.new(true,canvas.viewport),
         ControlPointSprite.new(false,canvas.viewport),
         ControlPointSprite.new(false,canvas.viewport),
         ControlPointSprite.new(true,canvas.viewport)
      ]
      showline=false
      sliderwin2.visible=false
      # This window displays the mouse's current position
      window=Window_UnformattedTextPokemon.new("")
      window.x=0
      window.y=320-64
      window.width=128
      window.height=64
      window.viewport=canvas.viewport
      loop do
        Graphics.update
        Input.update
        redrawline=false
        if Input.trigger?(Input::B)
          break
        end
        if Input.triggerex?(Input::LeftMouseKey)
          for j in 0...4
            next if !curve[j].hittest?
            if j==1||j==2
              next if !curve[0].visible || !curve[3].visible
            end
            curve[j].visible=true
            for k in 0...4
              curve[k].dragging=(k==j)
            end
            break
          end
        end
        for j in 0...4
          curve[j].mouseover
        end
        mouse=Mouse::getMousePos(true)
        newtext=sprintf("(%d,%d)",mouse[0],mouse[1])
        if window.text!=newtext
          window.text=newtext
        end
        if curve[0].visible && curve[3].visible &&
           !curve[0].dragging && !curve[3].dragging
          for point in points
            point.visible=true
          end
          if !showline
            curve[1].visible=true
            curve[2].visible=true
            curve[1].x=curve[0].x+0.3333*(curve[3].x-curve[0].x)
            curve[1].y=curve[0].y+0.3333*(curve[3].y-curve[0].y)
            curve[2].x=curve[0].x+0.6666*(curve[3].x-curve[0].x)
            curve[2].y=curve[0].y+0.6666*(curve[3].y-curve[0].y)
          end
          showline=true
        end
        if showline
          step=1.0/(points.length-1)
          t=0.0
          for i in 0...points.length
            point=getCurvePoint(curve,t)
            points[i].x=point[0]
            points[i].y=point[1]
            t+=step
          end
        end
      end
      window.dispose
      # dispose temporary path
      for point in points
        point.dispose
      end
      points.clear
      if showline
        path=curveToPointPath(curve,sliderwin2.value(0))
#       File.open("pointpath.txt","wb"){|f| f.write(path.inspect) }
        for point in path
          points.push(PointSprite.new(point[0],point[1],canvas.viewport))
        end
      end
      for point in curve
        point.dispose
      end
      sliderwin2.visible=true
      next
    elsif sliderwin2.changed?(defpathbutton)
      canceled=false
      pointpath=PointPath.new
      for point in points
        point.dispose
      end
      points.clear
      window=Window_UnformattedTextPokemon.newWithSize("",
         0, 320-64, 128, 64, canvas.viewport)
      sliderwin2.visible=false
      loop do
        Graphics.update
        Input.update
        if Input.triggerex?(0x1b)
          canceled=true
          break
        end
        if Input.triggerex?(Input::LeftMouseKey)
          break
        end
        mousepos=Mouse::getMousePos(true)
        window.text=sprintf("(%d,%d)",mousepos[0],mousepos[1])
      end
      while !canceled
        mousepos=Mouse::getMousePos(true)
        if !pointpath.isEndPoint?(mousepos[0],mousepos[1])
          pointpath.addPoint(mousepos[0],mousepos[1])
          points.push(PointSprite.new(mousepos[0],mousepos[1],canvas.viewport))
        end
        window.text=sprintf("(%d,%d)",mousepos[0],mousepos[1])
        Graphics.update
        Input.update
        if Input.triggerex?(0x1b) || Input.repeatcount(0x01)==0
          break
        end
      end
      window.dispose
      # dispose temporary path
      for point in points
        point.dispose
      end
      points.clear
      # generate smooth path from temporary path
      path=pointpath.smoothPointPath(sliderwin2.value(0),true)
      # redraw path from smooth path
      for point in path
        points.push(PointSprite.new(point[0],point[1],canvas.viewport))
      end
#     File.open("pointpath.txt","wb"){|f| f.write(path.inspect) }
      sliderwin2.visible=true
      next
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  # dispose all points
  for point in points
    point.dispose
  end
  points.clear
  sliderwin2.dispose
  return
end

def pbClearFrames(canvas)
  sliderwin2=ControlWindow.new(0,0,320,320)
  sliderwin2.viewport=canvas.viewport
  sliderwin2.addSlider(_INTL("First Frame:"),0,canvas.animation.length-1,0)
  sliderwin2.addSlider(_INTL("Last Frame:"),0,canvas.animation.length-1,
     canvas.animation.length-1)
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  sliderwin2.opacity=200
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton)
      startframe=sliderwin2.value(0)
      endframe=sliderwin2.value(1)
      for i in startframe..endframe
        canvas.clearFrame(i)
      end
      break
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  sliderwin2.dispose
  return
end

def pbAnimName(animation,cmdwin)
  window=ControlWindow.new(320,96,320,128)
  window.z=99999
  window.addControl(TextField.new(_INTL("New Name:"),animation.name))
  okbutton=window.addButton(_INTL("OK"))
  cancelbutton=window.addButton(_INTL("Cancel"))
  window.opacity=200
  loop do
    Graphics.update
    Input.update
    window.update
    if window.changed?(okbutton) || Input.triggerex?(0x0D)
      cmdwin.commands[cmdwin.index]=_INTL("{1} {2}",cmdwin.index,window.controls[0].text)
      animation.name=window.controls[0].text
      break
    end
    if window.changed?(cancelbutton) || Input.triggerex?(0x1B)
      break
    end
  end
  window.dispose
  return
end

def pbAnimList(animations,canvas,animwin)
  commands=[]
  for i in 0...animations.length
    animations[i]=PBAnimation.new if !animations[i]  
    commands[commands.length]=_INTL("{1} {2}",i,animations[i].name) 
  end
  cmdwin=pbListWindow(commands,320)
  cmdwin.height=384
  cmdwin.opacity=200
  cmdwin.index=animations.selected
  cmdwin.viewport=canvas.viewport
  helpwindow=Window_UnformattedTextPokemon.newWithSize(
     _INTL("Press C to load/rename an animation; press ESC to cancel"),
     320,0,320,128,canvas.viewport)
  maxsizewindow=ControlWindow.new(0,384,320,96)
  maxsizewindow.addSlider(_INTL("Animations:"),1,2000,animations.length)
  maxsizewindow.addButton(_INTL("Resize Animation List"))
  maxsizewindow.opacity=200
  maxsizewindow.viewport=canvas.viewport
  loop do
    Graphics.update
    Input.update
    cmdwin.update
    maxsizewindow.update
    helpwindow.update
    if maxsizewindow.changed?(1)
      newsize=maxsizewindow.value(0)
      animations.resize(newsize)
      commands.clear
      for i in 0...animations.length
        commands[commands.length]=_INTL("{1} {2}",i,animations[i].name)
      end
      cmdwin.commands=commands
      cmdwin.index=animations.selected
      next
    end
    if (Input.trigger?(Input::C) || (cmdwin.doubleclick? rescue false)) && animations.length>0
      cmd2=Kernel.pbShowCommands(helpwindow,[
         _INTL("Load Animation"),
         _INTL("Rename"),
         _INTL("Delete")
      ],-1)
      if cmd2==0 # Load Animation
        canvas.loadAnimation(animations[cmdwin.index])
        animwin.animbitmap=canvas.animbitmap
        animations.selected=cmdwin.index
        break
      elsif cmd2==1 # Rename
        pbAnimName(animations[cmdwin.index],cmdwin)
        cmdwin.refresh
      elsif cmd2==2 # Delete
        if Kernel.pbConfirmMessage(_INTL("Are you sure you want to delete this animation?"))
          animations[cmdwin.index]=PBAnimation.new
          cmdwin.commands[cmdwin.index]=_INTL("{1} {2}",cmdwin.index,animations[cmdwin.index].name) 
          cmdwin.refresh
        end
      end
    end
    if Input.trigger?(Input::B)
      break
    end
  end
  helpwindow.dispose
  maxsizewindow.dispose
  cmdwin.dispose
end



class BitmapDisplayWindow < SpriteWindow_Base
  attr_reader :bitmapname 
  attr_reader :hue

  def initialize(x,y,width,height)
    super(x,y,width,height)
    @bitmapname=""
    @hue=0
    self.contents=Bitmap.new(width-32,height-32)
  end

  def bitmapname=(value)
    if @bitmapname!=value
      @bitmapname=value
      refresh
    end
  end

  def hue=(value)
    if @hue!=value
      @hue=value
      refresh
    end
  end

  def refresh
    self.contents.clear
    bmap=AnimatedBitmap.new("Graphics/Animations/"+@bitmapname,@hue).deanimate
    return if !bmap
    ww=bmap.width
    wh=bmap.height
    sx=self.contents.width*1.0/ww
    sy=self.contents.height*1.0/wh
    if sx>sy
      ww=sy*ww
      wh=self.contents.height
    else
      wh=sx*wh
      ww=self.contents.width   
    end
    dest=Rect.new(
       (self.contents.width-ww)/2,
       (self.contents.height-wh)/2,
       ww,wh)
    src=Rect.new(0,0,bmap.width,bmap.height)
    self.contents.stretch_blt(dest,bmap,src)
    bmap.dispose
  end
end



def pbRgssChdir(dir)
  RTP.eachPathFor(dir){|path| Dir.chdir(path) { yield } }
end

def dumpBase64Anim(s)
  return [Zlib::Deflate.deflate(Marshal.dump(s))].pack("m").gsub(/\n/,"\r\n")
end

def loadBase64Anim(s)
  return Marshal.restore(StringInput.new(Zlib::Inflate.inflate(s.unpack("m")[0])))
end

def pbExportAnim(animations)
  filename=Kernel.pbMessageFreeText(_INTL("Enter a filename."),"",false,32)
  if filename!=""
    begin
      filename+=".anm"
      File.open(filename,"wb"){|f|
         f.write(dumpBase64Anim(animations[animations.selected]))
      }
      failed=false
      rescue
      Kernel.pbMessage(_INTL("Couldn't save the animation to {1}.",filename))
      failed=true
    end
    if !failed
      Kernel.pbMessage(_INTL("Animation was saved to {1} in the game folder.",filename))
      Kernel.pbMessage(_INTL("It's a text file, so it can be transferred to others easily."))
    end
  end
end

def pbImportAnim(animations,canvas,animwin)
  animfiles=[]
  pbRgssChdir(".") {
     animfiles.concat(Dir.glob("*.anm"))
  }
  cmdwin=pbListWindow(animfiles,320)
  cmdwin.opacity=200
  cmdwin.height=480
  cmdwin.viewport=canvas.viewport
  loop do
    Graphics.update
    Input.update
    cmdwin.update
    if (Input.trigger?(Input::C) || (cmdwin.doubleclick? rescue false)) && animfiles.length>0
      begin
        textdata=loadBase64Anim(IO.read(animfiles[cmdwin.index]))
        throw "Bad data" if !textdata.is_a?(PBAnimation)
        textdata.id=-1 # this is not an RPG Maker XP animation
        animations[animations.selected]=textdata
        rescue
        Kernel.pbMessage(_INTL("The animation is invalid or could not be loaded."))
        next
      end
      graphic=animations[animations.selected].graphic
      graphic="Graphics/Animations/#{graphic}"
      if graphic && graphic!="" && !FileTest.image_exist?(graphic)
        Kernel.pbMessage(_INTL("The animation file {1} was not found.  The animation will load anyway.",graphic))
      end
      canvas.loadAnimation(animations[animations.selected])
      animwin.animbitmap=canvas.animbitmap
      animations.selected=cmdwin.index
      break
    end
    if Input.trigger?(Input::B)
      break
    end
  end
  cmdwin.dispose
  return
end

def pbSelectAnim(canvas,animwin)
  animfiles=[]
  pbRgssChdir(".\\Graphics\\Animations\\") {
     animfiles.concat(Dir.glob("*.png"))
  }
  cmdwin=pbListWindow(animfiles,320)
  cmdwin.opacity=200
  cmdwin.height=480
  bmpwin=BitmapDisplayWindow.new(320,0,320,418)
  ctlwin=ControlWindow.new(320,418,320,64)
  cmdwin.viewport=canvas.viewport
  bmpwin.viewport=canvas.viewport
  ctlwin.viewport=canvas.viewport
  ctlwin.addSlider(_INTL("Hue:"),0,359,0)
  loop do
    bmpwin.bitmapname=cmdwin.commands[cmdwin.index]
    Graphics.update
    Input.update
    cmdwin.update
    bmpwin.update
    ctlwin.update
    if ctlwin.changed?(0)
      bmpwin.hue=ctlwin.value(0)
    end
    if (Input.trigger?(Input::C) || (cmdwin.doubleclick? rescue false)) && animfiles.length>0
      bitmap=AnimatedBitmap.new("Graphics/Animations/"+cmdwin.commands[cmdwin.index],ctlwin.value(0)).deanimate
      canvas.animation.graphic=cmdwin.commands[cmdwin.index]
      canvas.animation.hue=ctlwin.value(0)
      canvas.animbitmap=bitmap
      animwin.animbitmap=bitmap
      break
    end
    if Input.trigger?(Input::B)
      break
    end
  end
  bmpwin.dispose
  cmdwin.dispose
  ctlwin.dispose
  return
end

def pbTimingList(canvas)
  commands=[]
  for i in canvas.animation.timing
    commands.push(sprintf("%s",i))
  end
  commands[commands.length]=_INTL("[Add New Sound...]")
  cmdwin=pbListWindow(commands,480)
  cmdwin.x=0
  cmdwin.y=0
  cmdwin.width=480
  cmdwin.height=352
  cmdwin.opacity=200
  framewindow=ControlWindow.new(0,352,480,128)
  framewindow.addSlider(_INTL("Frame:"),0,canvas.animation.length-1,canvas.currentframe)
  framewindow.addButton(_INTL("Set Frame"))
  framewindow.addButton(_INTL("Delete Sound Effect"))
  framewindow.opacity=200
  cmdwin.viewport=canvas.viewport
  framewindow.viewport=canvas.viewport
  loop do
    Graphics.update
    Input.update
    cmdwin.update
    framewindow.update
    if (Input.trigger?(Input::C) || (cmdwin.doubleclick? rescue false))
      if cmdwin.index==cmdwin.commands.length-1
        newaudio=PBAnimTiming.new
        if pbSelectSE(canvas,newaudio)
          canvas.animation.timing.push(newaudio)
          cmdwin.commands[cmdwin.index]=sprintf("%s",canvas.animation.timing[cmdwin.index])
          cmdwin.commands.push(_INTL("[Add New Sound...]"))
          cmdwin.refresh
        end
      else
        pbSelectSE(canvas,canvas.animation.timing[cmdwin.index])
        cmdwin.commands[cmdwin.index]=sprintf("%s",canvas.animation.timing[cmdwin.index])
        cmdwin.refresh
      end
      next
    end
    if framewindow.changed?(1) && cmdwin.index < cmdwin.commands.length-1
      canvas.animation.timing[cmdwin.index].frame=framewindow.value(0)
      cmdwin.commands[cmdwin.index]=sprintf("%s",canvas.animation.timing[cmdwin.index])
      cmdwin.refresh
      next
    end
    if framewindow.changed?(2) && cmdwin.index < cmdwin.commands.length-1
      canvas.animation.timing.delete_at(cmdwin.index)
      cmdwin.commands.delete_at(cmdwin.index)
      cmdwin.refresh
      next
    end
    if Input.trigger?(Input::B)
      break
    end
  end
  cmdwin.dispose
  framewindow.dispose
  return
end

def pbSelectSE(canvas,audio)
  animfiles=[]
  ret=false
  pbRgssChdir(".\\Audio\\SE\\") {
     animfiles.concat(Dir.glob("*.wav"))
     animfiles.concat(Dir.glob("*.mp3"))
     animfiles.concat(Dir.glob("*.ogg"))
     animfiles.concat(Dir.glob("*.wma"))
  }
  audiofile=PBAnimTiming.new
  audiofile.name=""
  audiofile.volume=audio.volume
  audiofile.pitch=audio.pitch
  cmdwin=pbListWindow(animfiles,320)
  cmdwin.opacity=200
  cmdwin.height=480
  maxsizewindow=ControlWindow.new(320,0,320,192)
  maxsizewindow.addSlider(_INTL("Volume:"),0,100,audiofile.volume)
  maxsizewindow.addSlider(_INTL("Pitch:"),20,250,audiofile.pitch)
  maxsizewindow.addButton(_INTL("Play Sound"))
  maxsizewindow.addButton(_INTL("Stop Sound"))
  maxsizewindow.opacity=200
  cmdwin.viewport=canvas.viewport
  maxsizewindow.viewport=canvas.viewport
  if animfiles.length>0
    audiofile.name=animfiles[0]
  end
  loop do
    Graphics.update
    Input.update
    cmdwin.update
    maxsizewindow.update
    if (Input.trigger?(Input::C) || (cmdwin.doubleclick? rescue false)) && animfiles.length>0
      audio.name=cmdwin.commands[cmdwin.index]
      audio.volume=maxsizewindow.value(0)
      audio.pitch=maxsizewindow.value(1)
      ret=true
      break
    end
    if maxsizewindow.changed?(2) && animfiles.length>0
      sefile=cmdwin.commands[cmdwin.index]
      audiofile.volume=maxsizewindow.value(0)
      audiofile.pitch=maxsizewindow.value(1)
      pbSEPlay(RPG::AudioFile.new(sefile,audiofile.volume,audiofile.pitch))
      next
    end
    if maxsizewindow.changed?(3) && animfiles.length>0
      pbSEStop()
      next
    end
    if Input.trigger?(Input::B)
      break
    end
  end
  cmdwin.dispose
  maxsizewindow.dispose
  return ret
end

def pbHelpWindow
  helptext=""+
     "To add a cel to the scene, click on the canvas.  The selected cel will have a black "+
     "frame.  After a cell is selected, you can modify its properties using the keyboard:\n"+
     "E, R - Rotate left/right;\nP - Open properties screen;\nArrow keys - Move cel 8 pixels "+
     "(hold Alt for 2 pixels);\n+/- : Zoom in/out.\nL - Lock a cell.  Locking a cell prevents it "+
     "from being moved or deleted.\nAlso press TAB to select a cell on the canvas."
  cmdwin=Window_UnformattedTextPokemon.newWithSize("",0,0,480,480)
  cmdwin.opacity=200
  cmdwin.z=99999
  cmdwin.text=helptext
  loop do
    Graphics.update
    Input.update
    cmdwin.update
    if Input.trigger?(Input::C)
      break
    end
    if Input.trigger?(Input::B)
      break
    end
  end
  cmdwin.dispose
end

def tryLoadData(file)
  begin
    return load_data(file)
    rescue
    return nil
  end
end



class AnimationNameWindow
  def initialize(canvas)
    @canvas=canvas
    @oldname=nil
    @window=Window_UnformattedTextPokemon.newWithSize(_INTL("Name: {1}",@canvas.animation.name),240,544-64,400,64)
  end

  def viewport=(value); @window.viewport=value; end

  def update
    newtext=_INTL("Name: {1}",@canvas.animation.name)
    if @oldname!=newtext
      @window.text=newtext
      @oldname=newtext
    end
    @window.update
  end

  def refresh; @window.refresh; end
  def dispose; @window.dispose; end
  def disposed; @window.disposed?; end
end



class PointSprite < SpriteWrapper
  def initialize(x,y,viewport=nil)
    super(viewport)
    self.bitmap=Bitmap.new(2,2)
    self.bitmap.fill_rect(0,0,2,2,Color.new(0,0,0))
    self.x=x
    self.y=y
  end

  def dispose
    self.bitmap.dispose
    super
  end
end



class PointPath
  include Enumerable

  def initialize
    @points=[]
    @distances=[]
    @totaldist=0
  end

  def [](x)
    return @points[x].clone
  end

  def each
    @points.each {|o| yield o.clone }
  end

  def size
    return @points.size
  end

  def length
    return @points.length
  end

  def totalDistance
    return @totaldist
  end

  def inspect
    p=[]
    for point in @points
      p.push([point[0].to_i,point[1].to_i])
    end
    return p.inspect
  end

  def isEndPoint?(x,y)
    return false if @points.length==0
    index=@points.length-1
    return @points[index][0]==x &&
       @points[index][1]==y
  end

  def addPoint(x,y)
    @points.push([x,y])
    if @points.length>1
      len=@points.length
      dx=@points[len-2][0]-@points[len-1][0]
      dy=@points[len-2][1]-@points[len-1][1]
      dist=Math.sqrt(dx*dx+dy*dy)
      @distances.push(dist)
      @totaldist+=dist
    end
  end

  def clear
    @points.clear
    @distances.clear
    @totaldist=0
  end

  def smoothPointPath(frames,roundValues=false)
    if frames<0
      raise ArgumentError.new("frames out of range: #{frames}")
    end
    ret=PointPath.new
    if @points.length==0
      return ret
    end
    step=1.0/frames
    t=0.0;
    for i in 0..frames+1
      point=pointOnPath(t)
      if roundValues
        ret.addPoint(point[0].round,point[1].round)
      else
        ret.addPoint(point[0],point[1])
      end
      t+=step
      t=[1.0,t].min
    end
    return ret
  end

  def pointOnPath(t)
    if t<0 || t>1
      raise ArgumentError.new("t out of range for pointOnPath: #{t}")
    end
    return nil if @points.length==0
    ret=@points[@points.length-1].clone
    if @points.length==1
      return ret
    end
    curdist=0
    distForT=@totaldist*t
    i=0
    for dist in @distances
      curdist+=dist
      if dist>0.0
        if curdist>=distForT
          distT=1.0-((curdist-distForT)/dist)
          dx=@points[i+1][0]-@points[i][0]
          dy=@points[i+1][1]-@points[i][1]
          ret=[@points[i][0]+dx*distT,
               @points[i][1]+dy*distT]
          break
        end
      end
      i+=1
    end
    return ret
  end
end



def animationEditorMain(animation)
  viewport=Viewport.new(0,0,672,544) # 512+160 , 384+160
  viewport.z=99999
  canvas=AnimationCanvas.new(animation[animation.selected],viewport)
  bottomwindow=AnimationNameWindow.new(canvas)
  bottomwindow.viewport=canvas.viewport
  sliderwin=ControlWindow.new(0,384,240,160)
  sliderwin.addControl(FrameCountSlider.new(canvas))
  sliderwin.addButton(_INTL("Set Animation Bitmap"))
  sliderwin.addControl(FrameCountButton.new(canvas))
  sliderwin.addButton(_INTL("List of Animations"))
  sidewin=ControlWindow.new(512,0,160,320)
  sidewin.addButton(_INTL("Paste Last"))
  sidewin.addButton(_INTL("Copy Frames..."))
  sidewin.addButton(_INTL("Clear Frames..."))
  sidewin.addButton(_INTL("Tweening..."))
  sidewin.addButton(_INTL("Adjust"))
  sidewin.addButton(_INTL("Entire Slide..."))
  sidewin.addButton(_INTL("Sounds"))
  sidewin.addButton(_INTL("Play Animation"))
  sidewin.addButton(_INTL("More Commands"))
  animwin=CanvasAnimationWindow.new(canvas)
  animwin.viewport=canvas.viewport
  sliderwin.viewport=canvas.viewport
  sidewin.viewport=canvas.viewport
  loop do
    Graphics.update
    Input.update
    sliderwin.update
    canvas.update
    sidewin.update
    animwin.update
    bottomwindow.update
    if animwin.changed?
      canvas.pattern=animwin.selected
    end
    if Input.trigger?(Input::B)
      if Kernel.pbConfirmMessage(_INTL("Save changes?"))
        save_data(animation,"Data/PkmnAnimations.rxdata")
      end
      if Kernel.pbConfirmMessage(_INTL("Exit from the editor?"))
        break
      end
    end
    if Input.trigger?(Input::F5)
      pbHelpWindow
      next
    elsif Input.triggerex?(Input::RightMouseKey) && sliderwin.hittest?(0)  # Right mouse button
      commands=[
         _INTL("Copy Frame"),
         _INTL("Paste Frame"),
         _INTL("Clear Frame"),
         _INTL("Insert Frame"),
         _INTL("Delete Frame")
      ]
      hit=pbTrackPopupMenu(commands)
      case hit
        when 0 # Copy
          if canvas.currentframe>=0
            Clipboard.setData(canvas.animation[canvas.currentframe],"PBAnimFrame")
          end
        when 1 # Paste
          if canvas.currentframe>=0
            canvas.pasteFrame(canvas.currentframe)
          end
        when 2 # Clear Frame
          canvas.clearFrame(canvas.currentframe)
        when 3 # Insert Frame
          canvas.insertFrame(canvas.currentframe)
          sliderwin.invalidate
        when 4 # Delete Frame
          canvas.deleteFrame(canvas.currentframe)
          sliderwin.invalidate
      end
      next
    elsif Input.triggerex?(0x51) # Q
      if canvas.currentCel
        pbDefinePath(canvas)
        sliderwin.invalidate
      end
      next
    elsif Input.triggerex?(Input::RightMouseKey)  # Right mouse button
      mousepos=Mouse::getMousePos
      mousepos=[0,0] if !mousepos
      commands=[
         _INTL("Properties..."),
         _INTL("Cut"),
         _INTL("Copy"),
         _INTL("Paste"),
         _INTL("Delete"),
         _INTL("Define Path...")
      ]
      hit=pbTrackPopupMenu(commands)
      case hit
        when 0 # Properties
          if canvas.currentCel
            pbCellProperties(canvas)
            canvas.invalidateCel(canvas.currentcel)
          end
        when 1 # Cut
          if canvas.currentCel
            Clipboard.setData(canvas.currentCel,"PBAnimCel")
            canvas.deleteCel(canvas.currentcel)
          end
        when 2 # Copy
          if canvas.currentCel
            Clipboard.setData(canvas.currentCel,"PBAnimCel")
          end
        when 3 # Paste
          canvas.pasteCel(mousepos[0],mousepos[1])
        when 4 # Delete
          canvas.deleteCel(canvas.currentcel)
        when 5 # Define Path
          if canvas.currentCel
            pbDefinePath(canvas)
            sliderwin.invalidate
          end
      end
      next
    end
    if sliderwin.changed?(0)
      canvas.currentframe=sliderwin.value(0)
    end
    if sliderwin.changed?(1)
      pbSelectAnim(canvas,animwin)
      animwin.refresh
      sliderwin.refresh
    end
    if sliderwin.changed?(2)
      pbChangeMaximum(canvas)
      sliderwin.refresh
    end
    if sliderwin.changed?(3)
      pbAnimList(animation,canvas,animwin)
      bottomwindow.refresh
      animwin.refresh
      sliderwin.refresh
    end
    if sidewin.changed?(0)
      canvas.pasteLast
    end
    if sidewin.changed?(1)
      pbCopyFrames(canvas)
    end
    if sidewin.changed?(2)
      pbClearFrames(canvas)
    end
    if sidewin.changed?(3)
      pbTweening(canvas)
    end
    if sidewin.changed?(4) # adjustment
      startvalue=0
      endvalue=canvas.animation.length-1
      xoffset=-350
      yoffset=-105
    #  yoffset=+96
      for i in startvalue..endvalue
        canvas.offsetFrame(i,xoffset,yoffset)
      end
    end
    if sidewin.changed?(5)
      pbEntireSlide(canvas)
    end
    if sidewin.changed?(6)
      pbTimingList(canvas)
    end
    if sidewin.changed?(7)
      canvas.play
    end
    if sidewin.changed?(8)
      cmd=Kernel.pbShowCommands(nil,[
         _INTL("Set Animation Position"),
         _INTL("Import Animation"),
         _INTL("Export Animation"),
         _INTL("Help")
      ],-1)
      case cmd
        when 0
          positions=[_INTL("Target"),_INTL("Both battlers"),_INTL("Screen")]
          indexes=[1,3,4]
          for i in 0...positions.length
            selected="[  ]"
            if animation[animation.selected].position==indexes[i]
              selected="[x]"
            end
            positions[i]=_INTL("{1} {2}",selected,positions[i])
          end
          pos=Kernel.pbShowCommands(nil,positions,-1)
          if pos>=0
            animation[animation.selected].position=indexes[pos]
            canvas.update
          end
        when 1;pbImportAnim(animation,canvas,animwin);
        when 2;pbExportAnim(animation)
        when 3;pbHelpWindow
      end
    end
  end
  canvas.dispose
  animwin.dispose
  sliderwin.dispose
  sidewin.dispose
  bottomwindow.dispose
  viewport.dispose
  GC.start
end

def pbAnimationEditor
  pbBGMStop()
  animation=tryLoadData("Data/PkmnAnimations.rxdata")
  if !animation || !animation[0]
    animation=PBAnimations.new
    animation[0].graphic=""
  end
  oldsize=Win32API.client_size
  Win32API.SetWindowPos(672*$ResizeFactor,544*$ResizeFactor)
  animationEditorMain(animation)
  Win32API.SetWindowPos(oldsize[0],oldsize[1])
  $game_map.autoplay if $game_map
end