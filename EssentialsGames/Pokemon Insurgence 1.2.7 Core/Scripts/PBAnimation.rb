def yaxisIntersect(x1,y1,x2,y2,px,py)
  dx=x2-x1
  dy=y2-y1
  x = (dx==0) ? 0.0 : (px-x1)*1.0/dx
  y = (dy==0) ? 0.0 : (py-y1)*1.0/dy
  return [x,y]
end

def repositionY(x1,y1,x2,y2,tx,ty)
  dx=x2-x1
  dy=y2-y1
  x=x1+tx*dx*1.0
  y=y1+ty*dy*1.0
  return [x,y]
end

def transformPoint(x1,y1,x2,y2,  # Source line
                   x3,y3,x4,y4,  # Destination line
                   px,py)        # Source point
  ret=yaxisIntersect(x1,y1,x2,y2,px,py)
  ret2=repositionY(x3,y3,x4,y4,ret[0],ret[1])
  return ret2
end

def getSpriteCenter(sprite)#:nodoc:
  if !sprite || sprite.disposed?
    return [0,0]
  end
  if !sprite.bitmap || sprite.bitmap.disposed?
    return [sprite.x,sprite.y]
  end
  centerX=sprite.src_rect.width/2
  centerY=sprite.src_rect.height/2
  offsetX=(centerX-sprite.ox)*sprite.zoom_x
  offsetY=(centerY-sprite.oy)*sprite.zoom_y
  return [sprite.x+offsetX,sprite.y+offsetY]
end



class AnimFrame#:nodoc:
  X          = 0
  Y          = 1
  ZOOMX      = 2
  ANGLE      = 3
  MIRROR     = 4 
  BLENDTYPE  = 5
  VISIBLE    = 6
  PATTERN    = 7
  OPACITY    = 8
  ZOOMY      = 11
  COLORRED   = 12
  COLORGREEN = 13
  COLORBLUE  = 14
  COLORALPHA = 15
  TONERED    = 16
  TONEGREEN  = 17
  TONEBLUE   = 18
  TONEGRAY   = 19
  LOCKED     = 20
  FLASHRED   = 21
  FLASHGREEN = 22
  FLASHBLUE  = 23
  FLASHALPHA = 24
  PRIORITY   = 25
end



class RPG::Animation
  def self.fromOther(otherAnim,id)
    ret=RPG::Animation.new
    ret.id=id
    ret.name=otherAnim.name.clone
    ret.animation_name=otherAnim.animation_name.clone
    ret.animation_hue=otherAnim.animation_hue
    ret.position=otherAnim.position
    return ret
  end

  def addSound(frame,se)
    timing=RPG::Animation::Timing.new
    timing.frame=frame
    timing.se=RPG::AudioFile.new(se,100)
    self.timings.push(timing)
  end

  def addAnimation(otherAnim,frame,x,y) # frame is zero-based
    if frame+otherAnim.frames.length>=self.frames.length
      totalframes=frame+otherAnim.frames.length+1
      for i in self.frames.length...totalframes
        self.frames.push(RPG::Animation::Frame.new)
      end
    end
    self.frame_max=self.frames.length
    for i in 0...otherAnim.frame_max
      thisframe=self.frames[frame+i]
      otherframe=otherAnim.frames[i]
      cellStart=thisframe.cell_max
      thisframe.cell_max+=otherframe.cell_max
      thisframe.cell_data.resize(thisframe.cell_max,8)
      for j in 0...otherframe.cell_max
        thisframe.cell_data[cellStart+j,0]=otherframe.cell_data[j,0]
        thisframe.cell_data[cellStart+j,1]=otherframe.cell_data[j,1]+x
        thisframe.cell_data[cellStart+j,2]=otherframe.cell_data[j,2]+y
        thisframe.cell_data[cellStart+j,3]=otherframe.cell_data[j,3]
        thisframe.cell_data[cellStart+j,4]=otherframe.cell_data[j,4]
        thisframe.cell_data[cellStart+j,5]=otherframe.cell_data[j,5]
        thisframe.cell_data[cellStart+j,6]=otherframe.cell_data[j,6]
        thisframe.cell_data[cellStart+j,7]=otherframe.cell_data[j,7]
      end
    end
    for i in 0...otherAnim.timings.length
      timing=RPG::Animation::Timing.new
      othertiming=otherAnim.timings[i]
      timing.frame=frame+othertiming.frame
      timing.se=RPG::AudioFile.new(
         othertiming.se.name.clone,
         othertiming.se.volume,
         othertiming.se.pitch)
      timing.flash_scope=othertiming.flash_scope
      timing.flash_color=othertiming.flash_color.clone
      timing.flash_duration=othertiming.flash_duration
      timing.condition=othertiming.condition
      self.timings.push(timing)
    end
    self.timings.sort!{|a,b| a.frame<=>b.frame }
  end
end



def pbSpriteSetAnimFrame(sprite,frame,ineditor=false)
  return if !sprite
  if !frame
    sprite.visible=false
    sprite.src_rect=Rect.new(0,0,1,1)
    return
  end
  sprite.blend_type=frame[AnimFrame::BLENDTYPE]
  sprite.angle=frame[AnimFrame::ANGLE]
  sprite.mirror=frame[AnimFrame::MIRROR]>0 ? true : false
  sprite.opacity=frame[AnimFrame::OPACITY]
  sprite.visible=true
  if !frame[AnimFrame::VISIBLE]==1 && ineditor
    sprite.opacity/=2
  else
    sprite.visible=(frame[AnimFrame::VISIBLE]==1)
  end
  pattern=frame[AnimFrame::PATTERN]
  if pattern>=0
    sprite.zoom_x=frame[AnimFrame::ZOOMX]/100.0
    sprite.zoom_y=frame[AnimFrame::ZOOMY]/100.0
    if sprite.bitmap && !sprite.bitmap.disposed?
      animwidth=192#sprite.bitmap.width/5
      #echo(animwidth.inspect+"\r\n")
    else
      animwidth=192
    end
    sprite.src_rect.set((pattern%5)*animwidth,(pattern/5)*animwidth,
       animwidth,animwidth)
  else
    sprite.zoom_x=frame[AnimFrame::ZOOMX]/100.0
    sprite.zoom_y=frame[AnimFrame::ZOOMY]/100.0
    sprite.src_rect.set(0,0,
       sprite.bitmap ? sprite.bitmap.width : 128,
       sprite.bitmap ? sprite.bitmap.height : 128)
  end
  sprite.color.set(
     frame[AnimFrame::COLORRED],
     frame[AnimFrame::COLORGREEN],
     frame[AnimFrame::COLORBLUE],
     frame[AnimFrame::COLORALPHA]
  )
  sprite.tone.set(
     frame[AnimFrame::TONERED],
     frame[AnimFrame::TONEGREEN],
     frame[AnimFrame::TONEBLUE],
     frame[AnimFrame::TONEGRAY] 
  )
  sprite.ox=sprite.src_rect.width/2
  sprite.oy=sprite.src_rect.height/2
  sprite.x=frame[AnimFrame::X]
  sprite.y=frame[AnimFrame::Y]
end

def pbResetCel(frame)
  return if !frame
  frame[AnimFrame::ZOOMX]=100
  frame[AnimFrame::ZOOMY]=100
  frame[AnimFrame::BLENDTYPE]=0
  frame[AnimFrame::VISIBLE]=1
  frame[AnimFrame::ANGLE]=0
  frame[AnimFrame::MIRROR]=0
  frame[AnimFrame::OPACITY]=255
  frame[AnimFrame::COLORRED]=0
  frame[AnimFrame::COLORGREEN]=0
  frame[AnimFrame::COLORBLUE]=0
  frame[AnimFrame::COLORALPHA]=0
  frame[AnimFrame::TONERED]=0
  frame[AnimFrame::TONEGREEN]=0
  frame[AnimFrame::TONEBLUE]=0
  frame[AnimFrame::TONEGRAY]=0
  frame[AnimFrame::FLASHRED]=0
  frame[AnimFrame::FLASHGREEN]=0
  frame[AnimFrame::FLASHBLUE]=0
  frame[AnimFrame::FLASHALPHA]=0
  frame[AnimFrame::PRIORITY]=1
end

def pbCreateCel(x,y,pattern)
  frame=[]
  frame[AnimFrame::X]=x
  frame[AnimFrame::Y]=y
  frame[AnimFrame::PATTERN]=pattern
  frame[AnimFrame::LOCKED]=0
  pbResetCel(frame)
  return frame
end



class PBAnimTiming
  attr_accessor :frame
  attr_accessor :name
  attr_accessor :volume
  attr_accessor :pitch
  attr_accessor :flashScope
  attr_accessor :flashColor
  attr_accessor :flashDuration

  def initialize
    @frame=0
    @name=""
    @volume=80
    @pitch=100
    @flashScope=0
    @flashColor=Color.new(255,255,255,255)
    @flashDuration=5
  end

  def to_s
    return "[#{@frame}] #{name} (volume #{@volume}, pitch #{@pitch})"
  end
end



class PBAnimations < Array
  include Enumerable
  attr_reader :array
  attr_accessor :selected

  def initialize(size=1)
    @array=[]
    @selected=0
    size=1 if size<1 # Always create at least one animation
    size.times do
      @array.push(PBAnimation.new)
    end
  end

  def length
    return @array.length
  end

  def each
    @array.each {|i| yield i }
  end

  def [](i)
    return @array[i]
  end

  def []=(i,value)
    @array[i]=value
  end

  def resize(len)
    startidx=@array.length
    endidx=len
    if startidx>endidx
      for i in endidx...startidx
        @array.pop
      end
    else
      for i in startidx...endidx
        @array.push(PBAnimation.new)
      end
    end
    self.selected=len if self.selected>=len
  end
end



def pbConvertRPGAnimation(animation)
  pbanim=PBAnimation.new
  pbanim.id=animation.id
  pbanim.name=animation.name.clone
  pbanim.graphic=animation.animation_name
  pbanim.hue=animation.animation_hue
  pbanim.array.clear
  yoffset=0
  pbanim.position=animation.position
  yoffset=-64 if animation.position==0
  yoffset=64 if animation.position==2
  for i in 0...animation.frames.length
    frame=pbanim.addFrame
    animframe=animation.frames[i]
    for j in 0...animframe.cell_max
      data=animframe.cell_data
      if data[j,0]!=-1
        if animation.position==3 # Screen
          point=transformPoint(
             -160,80,160,-80,
             128,224,384,98, # 144,188,352,108
             data[j,1],data[j,2]
          )
          cel=pbCreateCel(point[0],point[1],data[j,0])
        else
          cel=pbCreateCel(data[j,1],data[j,2]+yoffset,data[j,0])
        end
        cel[AnimFrame::ZOOMX]=data[j,3]
        cel[AnimFrame::ZOOMY]=data[j,3]
        cel[AnimFrame::ANGLE]=data[j,4]
        cel[AnimFrame::MIRROR]=data[j,5]
        cel[AnimFrame::OPACITY]=data[j,6]
        cel[AnimFrame::BLENDTYPE]=0
        frame.push(cel)
      else
        frame.push(nil)
      end
    end
  end
  for i in 0...animation.timings.length
    timing=animation.timings[i]
    newtiming=PBAnimTiming.new
    newtiming.frame=timing.frame
    newtiming.name=timing.se.name
    newtiming.volume=timing.se.volume
    newtiming.pitch=timing.se.pitch
    newtiming.flashScope=timing.flash_scope
    newtiming.flashColor=timing.flash_color.clone
    newtiming.flashDuration=timing.flash_duration
    pbanim.timing.push(newtiming)
  end
  return pbanim
end



class PBAnimation < Array
  include Enumerable
  attr_accessor :graphic
  attr_accessor :hue 
  attr_accessor :name
  attr_accessor :position
  attr_accessor :speed
  attr_reader :array
  attr_reader :timing
  attr_accessor :id
  MAXSPRITES=30

  def speed
    @speed=20 if !@speed
    return @speed
  end

  def initialize(size=1)
    @array=[]
    @timing=[]
    @name=""
    @id=-1
    @graphic=""
    @hue=0
    @scope=0
    @position=3
    size=1 if size<1 # Always create at least one frame
    size.times do
      addFrame
    end
  end

  def length
    return @array.length
  end

  def each
    @array.each {|i| yield i }
  end

  def [](i)
    return @array[i]
  end

  def []=(i,value)
    @array[i]=value
  end

  def insert(*arg)
    return @array.insert(*arg)
  end

  def delete_at(*arg)
    return @array.delete_at(*arg)
  end

  def playTiming(frame,sprite=nil)
    for i in @timing
      if i.frame==frame
        if i.name!="" && i.name
          pbSEPlay(i.name,i.volume,i.pitch)
        end
        if sprite
          sprite.flash(i.flashColor,i.flashDuration*2) if i.flashScope==1
          sprite.flash(nil,i.flashDuration*2) if i.flashScope==3
        end
      end
    end
  end
 
  def resize(len)
    if len<@array.length
      @array[len,@array.length-len]=[]
    elsif len>@array.length
      (len-@array.length).times do
        addFrame
      end
    end
  end

  def addFrame
    pos=@array.length
    @array[pos]=[]
    for i in 0...PBAnimation::MAXSPRITES # maximum sprites plus user and target
      if i==0
        @array[pos][i]=pbCreateCel(128,224,-1) # Move's user # 144,188
        @array[pos][i][AnimFrame::LOCKED]=1
      elsif i==1
        @array[pos][i]=pbCreateCel(384,98,-2) # Move's target # 352,108
        @array[pos][i][AnimFrame::LOCKED]=1
      end
    end
    return @array[pos]
  end
end



module PBAnimationPlayerModule
  def initialize(animation,target,viewport=nil); end
  def dispose; end
  def start; end
  def playing?; end
  def update; end
end



class PBAnimationPlayer
  def initialize(animation,user,target,viewport=nil)
    if animation.position==3
      @player=PBAnimationPlayerPosition3.new(animation,user,target,viewport)
    elsif animation.position==4
      @player=PBAnimationPlayerPosition4.new(animation,user,target,viewport)
    else
      @player=PBAnimationPlayerPositionCenter.new(animation,target,viewport)
    end
  end

  def dispose; @player.dispose; end
  def start; @player.start; end
  def playing?; @player.playing?; end
  def looping; @player.looping; end
  def looping=(v); @player.looping=v; end
  def update; @player.update; end

  def setLineTransform(x1,y1,x2,y2,x3,y3,x4,y4)
    @player.setLineTransform(x1,y1,x2,y2,x3,y3,x4,y4)
  end
end



class PBAnimationPlayerPositionCenter # Focussed on target, no battler sprites
  attr_accessor :looping
  MAXSPRITES=30

  def initialize(animation,target,viewport=nil)
    @animsprites=[]
    @looping=false
    @target=target
    @animation=animation
    @animbitmap=nil
    @viewport=viewport
    @frame=-1
    @srcLine=nil
    @dstLine=nil

    @haveobservers=false
    for i in 0...MAXSPRITES
      @animsprites[i]=Sprite.new(viewport)
      @animsprites[i].bitmap=nil
      @animsprites[i].visible=false
    end

  end

  def dispose
    @animbitmap.dispose if @animbitmap
    for i in 0...MAXSPRITES
      @animsprites[i].dispose
    end
  end

  def start
    @frame=0
  end

  def playing?
    return @frame>=0
  end

  def setLineTransform(x1,y1,x2,y2,x3,y3,x4,y4)
  end

  def update
    return if @frame<0
    if (@frame>>1) >= @animation.length
      @frame=(@looping) ? 0 : -1
      if @frame<0
        @animbitmap.dispose if @animbitmap
        @animbitmap=nil
        return
      end
    end
    if !@animbitmap || @animbitmap.disposed?
      @animbitmap=AnimatedBitmap.new("Graphics/Animations/"+@animation.graphic,
         @animation.hue).deanimate
      for i in 0...MAXSPRITES
        @animsprites[i].bitmap=@animbitmap
      end
    end
    if (@frame&1)==0
      thisframe=@animation[@frame>>1]
      for i in 0...MAXSPRITES
        sprite=@animsprites[i]
        sprite.visible=false
      end
      for i in 0...thisframe.length
        cel=thisframe[i]
        next if !cel
        sprite=@animsprites[i]
        if sprite && cel[AnimFrame::PATTERN]>=0
          sprite.bitmap=@animbitmap
          pbSpriteSetAnimFrame(sprite,cel)
          center=getSpriteCenter(@target)
          sprite.x=cel[AnimFrame::X]+center[0]
          sprite.y=cel[AnimFrame::Y]+center[1]
        end
      end
      @animation.playTiming(@frame>>1,@target)
    end
    @frame+=1
  end
end



def isReversed(src0,src1,dst0,dst1)
  if src0==src1
    return false
  elsif src0<src1
    return (dst0>dst1)
  else
    return (dst0<dst1)
  end
end



class PBAnimationPlayerPosition3 # Focussed on both battlers, with battler sprites
  attr_accessor :looping
  MAXSPRITES=30

  def initialize(animation,user,target,viewport=nil)
    @animsprites=[]
    @user=user
    @target=target
    @userbitmap=user.bitmap # not to be disposed
    @targetbitmap=target.bitmap # not to be disposed
    @looping=false
    @animation=animation
    @animbitmap=nil
    @viewport=viewport
    @frame=-1
    @srcLine=nil
    @dstLine=nil
    @haveobservers=false
    @animsprites[0]=user
    @animsprites[1]=target
    for i in 2...MAXSPRITES
      @animsprites[i]=Sprite.new(viewport)
      @animsprites[i].bitmap=nil
      @animsprites[i].visible=false
    end
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    for i in 2...MAXSPRITES
      @animsprites[i].dispose
    end
  end

  def start
    @frame=0
  end

  def setLineTransform(x1,y1,x2,y2,x3,y3,x4,y4)
    @srcLine=[x1,y1,x2,y2]
    @dstLine=[x3,y3,x4,y4]
  end

  def playing?
    return @frame>=0
  end

  def update
    return if @frame<0
    if (@frame>>1) >= @animation.length
      @frame=(@looping) ? 0 : -1
      if @frame<0
        @animbitmap.dispose if @animbitmap
        @animbitmap=nil
        return
      end
    end
    if !@animbitmap || @animbitmap.disposed?
      @animbitmap=AnimatedBitmap.new("Graphics/Animations/"+@animation.graphic,
         @animation.hue).deanimate
      for i in 0...MAXSPRITES
        @animsprites[i].bitmap=@animbitmap
      end
    end
    if (@frame&1)==0
      thisframe=@animation[@frame>>1]
      for i in 0...MAXSPRITES
        sprite=@animsprites[i]
        sprite.visible=false   
      end
      index=0
      for pri in [-1,1]
        for i in 0...thisframe.length
          cel=thisframe[i]
          next if !cel
          if cel[AnimFrame::PRIORITY]
            next if cel[AnimFrame::PRIORITY]!=pri
          else
            next if pri!=1
          end
          sprite=@animsprites[index]
          sprite.bitmap=@animbitmap
          sprite.bitmap=@userbitmap if cel[AnimFrame::PATTERN]==-1
          sprite.bitmap=@targetbitmap if cel[AnimFrame::PATTERN]==-2
          if sprite
            pbSpriteSetAnimFrame(sprite,cel)
            if @srcLine && @dstLine
              if isReversed(@srcLine[0],@srcLine[2],@dstLine[0],@dstLine[2]) &&
                 cel[AnimFrame::PATTERN]>=0
                # Reverse direction
                sprite.mirror=!sprite.mirror
              end
              point=transformPoint(
                 @srcLine[0],@srcLine[1],@srcLine[2],@srcLine[3],
                 @dstLine[0],@dstLine[1],@dstLine[2],@dstLine[3],
                 sprite.x,sprite.y)
              sprite.x=point[0]
              sprite.y=point[1]
            end
            index+=1
          end
        end
      end
      @animation.playTiming(@frame>>1)
    end
    @frame+=1
  end
end



class PBAnimationPlayerPosition4 # Focussed on screen, no battler sprites
  attr_accessor :looping
  MAXSPRITES=30

  def initialize(animation,target,viewport=nil)
    @animsprites=[]
    @looping=false
    @target=target
    @animation=animation
    @animbitmap=nil
    @viewport=viewport
    @frame=-1
    @srcLine=nil
    @dstLine=nil
    @haveobservers=false
    for i in 0...MAXSPRITES
      @animsprites[i]=Sprite.new(viewport)
      @animsprites[i].bitmap=nil
      @animsprites[i].visible=false
    end
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    for i in 0...MAXSPRITES
      @animsprites[i].dispose
    end
  end

  def start
    @frame=0
  end

  def playing?
    return @frame>=0
  end

  def setLineTransform(x1,y1,x2,y2,x3,y3,x4,y4)
  end

  def update
    return if @frame<0
    if (@frame>>1) >= @animation.length
      @frame=(@looping) ? 0 : -1
      if @frame<0
        @animbitmap.dispose if @animbitmap
        @animbitmap=nil
        return
      end
    end
    if !@animbitmap || @animbitmap.disposed?
      @animbitmap=AnimatedBitmap.new("Graphics/Animations/"+@animation.graphic,
         @animation.hue).deanimate
      for i in 0...MAXSPRITES
        @animsprites[i].bitmap=@animbitmap
      end
    end
    if (@frame&1)==0
      thisframe=@animation[@frame>>1]
      for i in 0...MAXSPRITES
        sprite=@animsprites[i]
        sprite.visible=false
      end
      for i in 0...thisframe.length
        cel=thisframe[i]
        next if !cel
        sprite=@animsprites[i]
        if sprite && cel[AnimFrame::PATTERN]>=0
          sprite.bitmap=@animbitmap
          pbSpriteSetAnimFrame(sprite,cel)
        end
      end
      @animation.playTiming(@frame>>1,@target)
    end
    @frame+=1
  end
end