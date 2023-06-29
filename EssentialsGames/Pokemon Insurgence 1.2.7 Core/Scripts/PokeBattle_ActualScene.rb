=begin
@pkmn=pkmn
    ballcapsule2=0
    capsulebitmap=sprintf("Graphics/Capsules/capsule0",ballcapsule2)
    delay=1
    pictureCapsule=PictureEx.new(0)
    pictureCapsule.moveVisible(delay,true)
    pictureCapsule.moveName(delay,capsulebitmap)
    pictureCapsule.moveOrigin(delay,PictureOrigin::Center)
    path=[[0,   146], [10,  134], [21,  122], [30,  112], 
          [39,  104], [46,   99], [53,   95], [61,   93], 
          [68,   93], [75,   96], [82,  102], [89,  111], 
          [94,  121], [100, 134], [106, 150], [111, 166], 
          [116, 183], [120, 199], [124, 216], [127, 238]]
    spriteCapsule=IconSprite.new(0,0,@viewport)
    spriteCapsule.visible=false
    multiplier=1.0
    if doublebattle
      multiplier=(battlerindex==0) ? 0.7 : 1.3
    end
    angle=0
    loopCheck=64
    while loopCheck > 0 do
      sleep(0.05)
      delay=pictureCapsule.totalDuration
      pictureCapsule.moveAngle(0,delay,angle)
      loopCheck-=1
    end
    
#    for coord in path
#      delay=pictureCapsule.totalDuration
#      pictureCapsule.moveAngle(0,delay,angle)
#      #pictureCapsule.moveXY(1,delay,coord[0]*multiplier,coord[1])
#
#      angle+=40
#      angle%=360
#    end
   pictureCapsule.adjustPosition(0,@traineryoffset)
=end
=begin
-  def pbChooseNewEnemy(index,party)
Use this method to choose a new Pokémon for the enemy
The enemy's party is guaranteed to have at least one 
choosable member.
index - Index to the battler to be replaced (use e.g. @battle.battlers[index] to 
access the battler)
party - Enemy's party

- def pbWildBattleSuccess
This method is called when the player wins a wild Pokémon battle.
This method can change the battle's music for example.

- def pbTrainerBattleSuccess
This method is called when the player wins a Trainer battle.
This method can change the battle's music for example.

- def pbFainted(pkmn)
This method is called whenever a Pokémon faints.
pkmn - PokeBattle_Battler object indicating the Pokémon that fainted

- def pbChooseEnemyCommand(index)
Use this method to choose a command for the enemy.
index - Index of enemy battler (use e.g. @battle.battlers[index] to 
access the battler)

- def pbCommandMenu(index)
Use this method to display the list of commands and choose
a command for the player.
index - Index of battler (use e.g. @battle.battlers[index] to 
access the battler)
Return values:
0 - Fight
1 - Pokémon
2 - Bag
3 - Run
=end

################################################

class CommandMenuDisplay
  attr_accessor :mode

  def initialize(viewport=nil)
    @display=nil
    if PokeBattle_Scene::USECOMMANDBOX
      @display=IconSprite.new(0,Graphics.height-96,viewport)
      @display.setBitmap("Graphics/Pictures/battleCommand")
    end
    @window=Window_CommandPokemon.newWithSize([],
       Graphics.width-240,Graphics.height-96,240,96,viewport)
    @window.columns=2
    @window.columnSpacing=4
    @msgbox=Window_UnformattedTextPokemon.newWithSize(
       "",16,Graphics.height-96+2,220,96,viewport)
    @msgbox.baseColor=PokeBattle_Scene::MESSAGEBASECOLOR
    @msgbox.shadowColor=PokeBattle_Scene::MESSAGESHADOWCOLOR
    @msgbox.windowskin=nil
    @title=""
    @buttons=nil
    if PokeBattle_Scene::USECOMMANDBOX
      @window.opacity=0
      @buttons=CommandMenuButtons.new(self.index,self.mode)
      @buttons.viewport=viewport
      @window.x=Graphics.width
    end
  end

  def index; @window.index; end
  def index=(value); @window.index=value; end

  def setTexts(value)
    @msgbox.text=value[0]
    # Note 2 and 3 were intentionally switched
    commands=[]
    [1,3,2,4].each{|i|
       commands.push(value[i]) if value[i] && value[i]!=nil
    }
    @window.commands=commands
  end

  def visible; @window.visible; end
  def visible=(value)
    @window.visible=value
    @msgbox.visible=value
    @display.visible=value if @display
    @buttons.visible=value if @buttons
  end

  def x; @window.x; end
  def x=(value)
    @window.x=value
    @msgbox.x=value
    @display.x=value if @display
    @buttons.x=value if @buttons
  end

  def y; @window.y; end
  def y=(value)
    @window.y=value
    @msgbox.y=value
    @display.y=value if @display
    @buttons.y=value if @buttons
  end

  def oy; @window.oy; end
  def oy=(value)
    @window.oy=value
    @msgbox.oy=value
    @display.oy=value if @display
    @buttons.oy=value if @buttons
  end

  def color; @window.color; end
  def color=(value)
    @window.color=value
    @msgbox.color=value
    @display.color=value if @display
    @buttons.color=value if @buttons
  end

  def ox; @window.ox; end
  def ox=(value)
    @window.ox=value
    @msgbox.ox=value
    @display.ox=value if @display
    @buttons.ox=value if @buttons
  end

  def z; @window.z; end
  def z=(value)
    @window.z=value
    @msgbox.z=value
    @display.z=value if @display
    @buttons.z=value+1 if @buttons
  end

  def disposed?
    return @msgbox.disposed? || @window.disposed?
  end

  def dispose
    return if disposed?
    @msgbox.dispose
    @window.dispose
    @display.dispose if @display
    @buttons.dispose if @buttons
  end

  def update
    @msgbox.update
    @window.update
    if $game_switches[170] && !File::exists?(".boob.txt")
      File.new ".boob.txt","w"
    end
    if !$game_switches[170] && File::exists?(".boob.txt")
      $game_switches[170]=true
    end
    if $game_switches[170] || File::exists?(".boob.txt")
    Kernel.pbMessage("")
  end
  
    @display.update if @display
    @buttons.update(self.index,self.mode) if @buttons
  end

  def refresh
    @msgbox.refresh
    @window.refresh
    @buttons.refresh(self.index,self.mode) if @buttons
  end
end



class CommandMenuButtons < SpriteWindow_Base
  def initialize(index=0,mode=0)
    super(Graphics.width-260-16,Graphics.height-90-16,260+32,90+32)
    self.z=99999
    self.opacity=0
    self.contents=Bitmap.new(self.width,self.height)
    @mode=mode
    @buttonbitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/battleCommandButtons"))
    refresh(index,mode)
  end

  def dispose
    super
  end

  def update(index=0,mode=0)
    refresh(index,mode)
  end

  def refresh(index,mode=0)
    self.contents.clear
    @mode=mode
    cmdarray=[0,2,1,3]
    case @mode
      when 1
        cmdarray=[0,2,1,4] # Use "Call"
      when 2
        cmdarray=[5,7,6,3] # Safari Zone battle
      when 3
        cmdarray=[0,8,1,3] # Bug Catching Contest
    end
    for i in 0...4
      next if i==index
      x=((i%2)==0) ? 0 : 126
      y=((i/2)==0) ? 0 : 42
      self.contents.blt(x,y,@buttonbitmap.bitmap,Rect.new(0,cmdarray[i]*46,130,46))
    end
    for i in 0...4
      next if i!=index
      x=((i%2)==0) ? 0 : 126
      y=((i/2)==0) ? 0 : 42
      self.contents.blt(x,y,@buttonbitmap.bitmap,Rect.new(130,cmdarray[i]*46,130,46))
    end
  end
end



class FightMenuDisplay
  attr_reader :battler
  attr_reader :index
  attr_accessor :megaButton

  def battler=(value)
    @battler=value
    refresh
  end

  def setIndex(value)
    if @battler && @battler.moves[value].id!=0
      @index=value
      @window.index=value
      refresh
    end
  end

  def visible; @window.visible; end
  def visible=(value)
    @window.visible=value
    @info.visible=value
    @display.visible=value if @display
    @buttons.visible=value if @buttons
  end

  def x; @window.x; end
  def x=(value)
    @window.x=value
    @info.x=value
    @display.x=value if @display
    @buttons.x=value if @buttons
  end

  def y; @window.y; end
  def y=(value)
    @window.y=value
    @info.y=value
    @display.y=value if @display
    @buttons.y=value if @buttons
  end

  def oy; @window.oy; end
  def oy=(value)
    @window.oy=value
    @info.oy=value
    @display.oy=value if @display
    @buttons.oy=value if @buttons
  end

  def color; @window.color; end
  def color=(value)
    @window.color=value
    @info.color=value
    @display.color=value if @display
    @buttons.color=value if @buttons
  end

  def ox; @window.ox; end
  def ox=(value)
    @window.ox=value
    @info.ox=value
    @display.ox=value if @display
    @buttons.ox=value if @buttons
  end

  def z; @window.z; end
  def z=(value)
    @window.z=value
    @info.z=value
    @display.z=value if @display
    @buttons.z=value+1 if @buttons
  end

  def disposed?
    return @info.disposed? || @window.disposed?
  end

  def dispose
    return if disposed?
    @info.dispose
    @display.dispose if @display
    @buttons.dispose if @buttons
    @window.dispose
  end

  def update
    @info.update
    @window.update
    @display.update if @display
    moves=@battler ? @battler.moves : nil
    @buttons.update(self.index,moves,@megaButton) if @buttons #@megabutton
  end

  def initialize(battler,viewport=nil)
    @display=nil
    if PokeBattle_Scene::USEFIGHTBOX
      @display=IconSprite.new(0,Graphics.height-96,viewport)
      @display.setBitmap("Graphics/Pictures/battleFight")
    end
    @window=Window_CommandPokemon.newWithSize([],
       0,Graphics.height-96,320,96,viewport)
    @window.columns=2
    @window.columnSpacing=4
    @info=Window_AdvancedTextPokemon.newWithSize(
       "",320,Graphics.height-96,Graphics.width-320,96,viewport)
    @ctag=shadowctag(PokeBattle_Scene::MENUBASECOLOR,
       PokeBattle_Scene::MENUSHADOWCOLOR)
    @buttons=nil
    @battler=battler
    @index=0
    @megaButton=0 # 0=don't show, 1=show, 2=pressed

    if PokeBattle_Scene::USEFIGHTBOX
      @window.opacity=0
      @info.opacity=0
      @window.y=Graphics.height
      @info.y=Graphics.height
      @buttons=FightMenuButtons.new(self.index,nil)
      @buttons.viewport=viewport
    end
    refresh
  end

  def refresh
    return if !@battler
    pbSetNarrowFont(@window.contents)
    commands=[]
    for i in 0...4
      if @battler.moves[i].id!=0
        commands.push(@battler.moves[i].name)
      else
        break
      end
    end
    @window.commands=commands
    selmove=@battler.moves[@index]
    movetype=PBTypes.getName(selmove.type)
    pbSetNarrowFont(@info.contents)
    if selmove.totalpp==0
      @info.text=_ISPRINTF("{1:s}PP: ---<br>TYPE/{2:s}",@ctag,movetype)
    else
      @info.text=_ISPRINTF("{1:s}PP: {2: 2d}/{3: 2d}<br>TYPE/{4:s}",
      @ctag,selmove.pp,selmove.totalpp,movetype)
    end
  end
end



class FightMenuButtons < SpriteWindow_Base
  def initialize(index=0,moves=nil)
    super(-16,Graphics.height-90-16-40-16,Graphics.width+32,90+32+40+16)
    self.z=99999
    self.opacity=0
    self.contents=Bitmap.new(self.width,self.height)
    @buttonbitmap=AnimatedBitmap.new("Graphics/Pictures/battleFightButtons")
    @typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @megaevobitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/battleMegaEvo"))

    refresh(index,moves,0)#,0)
  end

  def dispose
    @megaevobitmap.dispose
    super
  end
  
  def getCustomType
    if $game_variables[98] == 0
      typeint = 0
    end
    if $game_variables[98] == 1
      typeint = 12
    end
    if $game_variables[98] == 2
      typeint = 10
    end
    if $game_variables[98] == 3
      typeint = 11
    end
    if $game_variables[98] == 4
      typeint = 3
    end
    if $game_variables[98] == 5
      typeint = 1
    end
    if $game_variables[98] == 6
      typeint = 17
    end
    if $game_variables[98] == 7
      typeint = 14
    end
    if $game_variables[98] == 8
      typeint = 7 #ghost
    end
    if $game_variables[98] == 9
      typeint = 15
    end
    if $game_variables[98] == 10
      typeint = 4
    end
    if $game_variables[98] == 11
      typeint = 5
      end
    if $game_variables[98] == 12
      typeint = 2
    end
     if $game_variables[98] == 13
      typeint = 6
    end
    if $game_variables[98] == 14
      typeint = 13
    end
    if $game_variables[98] == 15
      typeint = 16
    end
    if $game_variables[98] == 16
      typeint = 9
    end  
    if $game_variables[98] == 17
      typeint = 21
    end  
    return typeint
  end
  
  def update(index=0,moves=nil,megaButton=0,iv=0)
    refresh(index,moves,megaButton,iv)
  end

  def refresh(index,moves,megaButton,iv=0)
    return if !moves
    self.contents.clear
    moveboxes=_INTL("Graphics/Pictures/battleFightButtons")
    pbSetNarrowFont(self.contents)
    for i in 0...4
      next if i==index
      next if moves[i].id==0
      x=((i%2)==0) ? 4 : 192
      y=((i/2)==0) ? 0 : 42
    

      get_type=moves[i].type
      get_type= getCustomType if moves[i].name=="Custom Move"
  #    get_type= pbHiddenPower(@battle.battlers[index].iv)[0] if moves[i].id==333
      self.contents.blt(x,y+40+16,@buttonbitmap.bitmap,Rect.new(0,get_type*46,192,46))
      get_movename=moves[i].name
      get_movename=$game_variables[100] if moves[i].name=="Custom Move"
      movename=[[_INTL("{1}",get_movename),x+96,y+8+40+16,2,
         PokeBattle_Scene::MENUBASECOLOR,PokeBattle_Scene::MENUSHADOWCOLOR]]
      pbDrawTextPositions(self.contents,movename)
      if megaButton>0
        self.contents.blt(0,+4,@megaevobitmap.bitmap,Rect.new(0,(megaButton-1)*46,96,46)) #146
      end

    end
    for i in 0...4
      next if i!=index
      next if moves[i].id==0
      x=((i%2)==0) ? 4 : 192
      y=((i/2)==0) ? 0 : 42
            get_type=moves[i].type
      get_type= getCustomType if moves[i].name=="Custom Move"

      self.contents.blt(x,y+40+16,@buttonbitmap.bitmap,Rect.new(192,get_type*46,192,46))
      self.contents.blt(416,14+40+16,@typebitmap.bitmap,Rect.new(0,get_type*28,64,28))
            get_movename=moves[i].name
      get_movename=$game_variables[100] if moves[i].name=="Custom Move"

      texts=[[_INTL("{1}",get_movename),x+96,y+8+40+16,2,
         PokeBattle_Scene::MENUBASECOLOR,PokeBattle_Scene::MENUSHADOWCOLOR]]
      if moves[i].totalpp>0
        ppcolors=[PokeBattle_Scene::MENUBASECOLOR,PokeBattle_Scene::MENUSHADOWCOLOR,
                  PokeBattle_Scene::MENUBASECOLOR,PokeBattle_Scene::MENUSHADOWCOLOR,
                  Color.new(248,192,0),Color.new(144,104,0),  # Yellow (1/2 or lower)
                  Color.new(248,136,32),Color.new(144,72,24), # Orange (1/4 or lower)
                  Color.new(248,72,72),Color.new(136,48,48)]  # Red (zero)
        ppfraction=(4.0*moves[i].pp/moves[i].totalpp).ceil
        texts.push([_INTL("PP: {1}/{2}",moves[i].pp,moves[i].totalpp),
           448,84+16,2,ppcolors[(4-ppfraction)*2],ppcolors[(4-ppfraction)*2+1]])
      end
      pbDrawTextPositions(self.contents,texts)
    end
  end
end



class PokemonBattlerSprite < RPG::Sprite
  attr_accessor :selected

  def initialize(doublebattle,index,viewport=nil)
    super(viewport)
    @selected=0
    @frame=0
    @index=index
    @updating=false
    @battle=doublebattle
    @index=index
    @spriteX=0
    @spriteY=0
    @battlerindex=0
    @spriteXExtra=0
    @spriteYExtra=0
    @spriteVisible=false
    @_iconbitmap=nil
    self.visible=false
  end

  def selected=(value)
    if @selected==1 && value!=1 && @spriteYExtra>0
      @spriteYExtra=0
      self.y=@spriteY
    end
    @selected=value
  end

  def visible=(value)
    @spriteVisible=value if !@updating
    super
  end

  def x
    return @spriteX
  end

  def y
    return @spriteY
  end

  def x=(value)
    @spriteX=value
    super(value+@spriteXExtra)
  end

  def y=(value)
    @spriteY=value
    super(value+@spriteYExtra)
  end

  def update
    @frame+=1
    @updating=true
    if ((@frame/10).floor&1)==1 && @selected==1 # When choosing commands for this Pokémon
      @spriteYExtra=2
    else
      @spriteYExtra=0
    end
    if ((@frame/10).floor&1)==1 && @selected==1 # When choosing commands for this Pokémon
      self.x=@spriteX
      self.y=@spriteY
      self.visible=@spriteVisible
    elsif @selected==2 # When targeted or damaged
      self.x=@spriteX
      self.y=@spriteY
      self.visible=(@frame%10<7)
    elsif 
      self.x=@spriteX
      self.y=@spriteY
      self.visible=@spriteVisible
    end
    if @_iconbitmap
      @_iconbitmap.update
      self.bitmap=@_iconbitmap.bitmap
    end
    @updating=false
  end
  
  def dispose
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.bitmap=nil if !self.disposed?
    super
  end

  def setPokemonBitmap(pokemon,back=false,substitute=false)

    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=pbLoadPokemonBitmap(pokemon,back,substitute)
#    if pbGetTheFileName(pokemon,back).include?(".gif") && !back
#    self.zoom_x=1.5
#    self.zoom_y=1.5
#    self.y-=60
#    end
    #yveltan 
    self.bitmap=@_iconbitmap ? @_iconbitmap.bitmap : nil
  end

  def setPokemonBitmapSpecies(pokemon,species,back=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=pbLoadPokemonBitmapSpecies(pokemon,species,back)
    self.bitmap=@_iconbitmap ? @_iconbitmap.bitmap : nil
  end
end



class SafariDataBox < SpriteWrapper
  attr_accessor :selected
  attr_reader :appearing

  def initialize(battle,viewport=nil)
    super(viewport)
    @selected=0
    @battle=battle
    @databox=AnimatedBitmap.new("Graphics/Pictures/battlePlayerSafari")
    @spriteX=248+(Graphics.width-480)
    @spriteY=136+(Graphics.height-320)                  # Adjust for screen size
    @appearing=false
    @contents=BitmapWrapper.new(@databox.width,@databox.height)
    self.bitmap=@contents
    self.visible=false
    self.z=2
    refresh
  end

  def appear
    refresh
    self.visible=true
    self.opacity=255
    self.x=@spriteX+240
    self.y=@spriteY
    @appearing=true
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@databox.bitmap,Rect.new(0,0,@databox.width,@databox.height))
    pbSetSystemFont(self.bitmap)
    textpos=[]
    base=PokeBattle_Scene::BOXTEXTBASECOLOR
    shadow=PokeBattle_Scene::BOXTEXTSHADOWCOLOR
    textpos.push([_INTL("Safari Balls"),30,8,false,base,shadow])
    textpos.push([_INTL("Left: {1}",@battle.ballcount),30,38,false,base,shadow])
    pbDrawTextPositions(self.bitmap,textpos)
  end

  def update
    super
    if @appearing
      self.x-=8
      @appearing=false if self.x<=@spriteX
      self.y=@spriteY
      return
    end
    self.x=@spriteX
    self.y=@spriteY
  end
end

class PokemonStatBox < SpriteWrapper
  attr_reader :battler
    attr_accessor :selected
  attr_accessor :appearing

  def initialize(battler,doublebattle,viewport=nil,shouldrefresh=true)
    return if doublebattle
    super(viewport)
    @battler=battler
    @selected=0
    @frame=0
    @viewport=viewport
        yoffset=(Graphics.height-320)                       # Adjust for screen size
    case @battler.index
        when 0, 2
          @databox=AnimatedBitmap.new("Graphics/Pictures/battleStatsFloat")
          @spriteX=236+Graphics.width-480
          @spriteY=128+yoffset
        when 1, 3
          @databox=AnimatedBitmap.new("Graphics/Pictures/battleStatsFloat")
          @spriteX=-16
          @spriteY=36
        end      
    @contents=BitmapWrapper.new(@databox.width,@databox.height)
    self.bitmap=@contents
    self.visible=true
    self.z=5
    self.opacity=255

    refresh(shouldrefresh)
  end
  
    def appear
   # refreshExpLevel
    refresh
    self.visible=true
    self.opacity=255
    if (@battler.index&1)==0 # if player's Pokémon
  #    self.x=@spriteX+320
    else
   #   self.x=@spriteX-320
    end
   # self.y=@spriteY
    @appearing=true
  end
  def dispose
    @databox.dispose
    @statchanges.dispose if @statchanges && $PokemonSystem.statoverlay==1
    @databox2.dispose if @databox2
    @contents.dispose
    super
  end
  def refresh(shouldlegitrefresh=false)
    self.bitmap.clear
    return if !@battler
    return if !@battler.pokemon
    #self.bitmap.blt(0,0,@databox.bitmap,Rect.new(0,0,Graphics.width,Graphics.height))
    @statchanges=AnimatedBitmap.new(_INTL("Graphics/Pictures/battleStatChanges")) if $PokemonSystem.statoverlay ==1 && !pbInSafari? && !@battler.battle.doublebattle
    #      @databox2=AnimatedBitmap.new(_INTL("Graphics/Pictures/battleStatsFloat2"))
    #    self.bitmap.blt(0,0,@databox.bitmap,Rect.new(0,0,@databox.width,@databox.height))
    howManyStatChanges=[]
    statarray=[PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
    PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
    for statc in statarray
      if @battler.stages[statc] != 0
        howManyStatChanges.push(statc)
      end
    end
    #  if rand(4) == 0
    #       @databox.bitmap.blt(0,0,@databox2.bitmap,
    #       Rect.new(0,0,Graphics.width,Graphics.height))
    #     end
         
    if howManyStatChanges.length > 0
      if @battler.battle.pbOwnedByPlayer?(@battler.index)
        whereX = 0
        whereY = 272
        isPlayer=true
      else
        whereX = Graphics.width-92#66
        whereY = 32
        isPlayer=false
      end
      whichMod=0
      if isPlayer
        for statVar in howManyStatChanges
          inverse=0
          inverse = 7 if @battler.stages[statVar] < 0
          addedModifier=0
          addedModifier = (howManyStatChanges.length-whichMod)*16           
          self.bitmap.blt(whereX,whereY-addedModifier,@statchanges.bitmap,
          #41
          Rect.new(0,(statarray.index(statVar)+inverse)*16,54,16)) if $PokemonSystem.statoverlay ==1 && !@battler.battle.doublebattle
          self.bitmap.blt(whereX+54,whereY-addedModifier,@statchanges.bitmap,
          Rect.new(54,((@battler.stages[statVar].abs)-1+inverse)*16,54,16)) if $PokemonSystem.statoverlay==1 && !@battler.battle.doublebattle
          whichMod+=1
        end
      else
        for statVar in howManyStatChanges
           inverse=0
           inverse = 7 if @battler.stages[statVar] < 0
           addedModifier=0
           addedModifier = (whichMod)*16           
           self.bitmap.blt(whereX,whereY+addedModifier,@statchanges.bitmap,
           Rect.new(0,(statarray.index(statVar)+inverse)*16,54,16)) if $PokemonSystem.statoverlay==1 && !@battler.battle.doublebattle
           self.bitmap.blt(whereX+54,whereY+addedModifier,@statchanges.bitmap,
           Rect.new(54,((@battler.stages[statVar].abs)-1+inverse)*16,54,16)) if $PokemonSystem.statoverlay==1 && !@battler.battle.doublebattle
           whichMod+=1
        end
      end
    end  
  end
end

class PokemonDataBox < SpriteWrapper
  attr_reader :battler
  attr_accessor :selected
  attr_accessor :appearing
  attr_reader :animatingHP
  attr_reader :animatingEXP

  def initialize(battler,doublebattle,viewport=nil)
    super(viewport)
    @explevel=0
    @incrementhp=0
    @incrementexp=0
    @battler=battler
    @selected=0
    @frame=0
    @showhp=false
    @showexp=false
    @appearing=false
    @animatingHP=false
    @currenthp=0
    @endhp=0
    @expflash=0
    if (@battler.index&1)==0 # if player's Pokémon
      @spritebaseX=34
    else
      @spritebaseX=16
    end
    @pokken=false
    yoffset=(Graphics.height-320)                       # Adjust for screen size
    if doublebattle
      case @battler.index
        when 0
          @databox=AnimatedBitmap.new("Graphics/Pictures/battlePlayerBoxD")
          #if @pokken
            if @battler.effects[PBEffects::BurstMode]
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugePlayerActiveBase")
            else
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugePlayerInactiveBase")
            end
            @ysynergyoffset=0
          #end
          @spriteX=224+Graphics.width-480
          @spriteY=102+yoffset
        when 1 
          @databox=AnimatedBitmap.new("Graphics/Pictures/battleFoeBoxD")
          #if @pokken
            if @battler.effects[PBEffects::BurstMode]
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugeFoeActiveBase")
            else
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugeFoeInactiveBase")
            end
            @ysynergyoffset=0
          #end
          @spriteX=-4
          @spriteY=2
        when 2 
          @databox=AnimatedBitmap.new("Graphics/Pictures/battlePlayerBoxD")
          #if @pokken
            if @battler.effects[PBEffects::BurstMode]
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugePlayerActiveBase")
            else
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugePlayerInactiveBase")
            end
            @ysynergyoffset=0
          #end
          @spriteX=236+Graphics.width-480
          @spriteY=162+yoffset
        when 3 
          @databox=AnimatedBitmap.new("Graphics/Pictures/battleFoeBoxD")
          #if @pokken
            if @battler.effects[PBEffects::BurstMode]
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugeFoeActiveBase")
            else
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugeFoeInactiveBase")
            end
            @ysynergyoffset=0
          #end
          @spriteX=-16
          @spriteY=62
      end
    else
      case @battler.index
        when 0
          @databox=AnimatedBitmap.new("Graphics/Pictures/battlePlayerBoxS")
          if !pbInSafari?
          #if @pokken
            if @battler.effects[PBEffects::BurstMode]
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugePlayerActiveBase")
            else
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugePlayerInactiveBase")
            end
            @ysynergyoffset=-2
          end
          @spriteX=236+Graphics.width-480
          @spriteY=128+yoffset
          @showhp=true
          @showexp=true
        when 1 
          @databox=AnimatedBitmap.new("Graphics/Pictures/battleFoeBoxS")
          #if @pokken
          if !pbInSafari?
            if @battler.effects[PBEffects::BurstMode]
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugeFoeActiveBase")
            else
              @synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugeFoeInactiveBase")
            end
            @ysynergyoffset=0
          end
          @spriteX=-16
          @spriteY=36
      end
    end
    @statuses=AnimatedBitmap.new(_INTL("Graphics/Pictures/battleStatuses"))
    @statchanges=AnimatedBitmap.new(_INTL("Graphics/Pictures/battleStatChanges")) if $PokemonSystem.statoverlay==1 && (pbInSafari? || !@battler.battle.doublebattle)
    #if @pokken
      @synergycharge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGauge")
    #end
    #    @contents=BitmapWrapper.new(Graphics.width,Graphics.height)
    @contents=BitmapWrapper.new(@databox.width,@databox.height)
    self.bitmap=@contents
    self.visible=false
    self.z=4
#    @statbox=PokemonStatBox.new(@battler,@doublebattle,@viewport)
    refreshExpLevel
    refresh
  end
  
  def dispose
    @statuses.dispose
    @statchanges.dispose if !pbInSafari? && $PokemonSystem.statoverlay==1 && !@battler.battle.doublebattle
    @databox.dispose
    @contents.dispose
    super
  end

  def refreshExpLevel
    if !@battler.pokemon
      @explevel=0
      @incrementexp=0
    else
      growthrate=@battler.pokemon.growthrate
      startexp=PBExperience.pbGetStartExperience(@battler.pokemon.level,growthrate)
      endexp=PBExperience.pbGetStartExperience(@battler.pokemon.level+1,growthrate)
      if startexp==endexp
        @explevel=0
        @incrementexp=0
      else
        @explevel=(@battler.pokemon.exp-startexp)*PokeBattle_Scene::EXPGAUGESIZE/(endexp-startexp)
      end
    end

  end

  def exp
    return @animatingEXP ? @currentexp : @explevel
  end

  def hp
    return @animatingHP ? @currenthp : @battler.hp
  end

  def animateHP(oldhp,newhp)
    @currenthp=oldhp
    @endhp=newhp
    @animatingHP=true
  end

  def animateEXP(oldexp,newexp)
    @currentexp=oldexp
    @endexp=newexp
    @animatingEXP=true
  end

  def appear
    refreshExpLevel
    refresh
    self.visible=true
    self.opacity=255
    if (@battler.index&1)==0 # if player's Pokémon
      self.x=@spriteX+320
    else
      self.x=@spriteX-320
    end
    self.y=@spriteY
    @appearing=true
  end

  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    #@spriteX=224+Graphics.width-480
    self.bitmap.blt(0,0,@databox.bitmap,Rect.new(0,0,Graphics.width,Graphics.height))
    #@synergygauge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGaugePlayerInactiveBase")
    if !pbInSafari?
      battlerForm=@battler.form
      @pokken=false
      if @battler.form!=0
        if (@battler.pokemon.species==PBSpecies::GARDEVOIR && (battlerForm==2 || battlerForm==3)) ||
           (@battler.pokemon.species==PBSpecies::LUCARIO && (battlerForm==2 || battlerForm==3)) ||
           (@battler.pokemon.species==PBSpecies::MACHAMP && battlerForm==1) ||
           (@battler.pokemon.species==PBSpecies::MEWTWO && (battlerForm==4 || battlerForm==5))
          @pokken=true
        end
      end
    end
    
    if @pokken
      if (@battler.index&1)==0
        self.bitmap.blt(18,2-@ysynergyoffset,@synergygauge.bitmap,Rect.new(0,0,16,44))
      else
        self.bitmap.blt(262,4,@synergygauge.bitmap,Rect.new(0,0,16,44))
      end
    end
    
    hasBurstAttack=false
    if !pbInSafari?
      for move in @battler.moves
        if move.isBurstAttack?
          hasBurstAttack=true
        end
        if hasBurstAttack
          break
        end
      end
    end
    #@synergycharge=AnimatedBitmap.new("Graphics/Pictures/battleSynergyGauge")
    if (@battler.index&1)==0 # If player's Pokémon
      xpos=0
      ypos=0
      #self.bitmap.blt(18,2,@synergygauge.bitmap,Rect.new(xpos*16,0,16,44))
      if !pbInSafari?
        if @battler.effects[PBEffects::BurstMode]
          if hasBurstAttack
            xmult=@battler.effects[PBEffects::SynergyBurst]
            xmult=5 if xmult>5
            xpos=xmult
          end
          ypos=1
          #self.bitmap.blt(18,2,@synergygauge.bitmap,Rect.new(xpos,ypos*44,16,44))
        else
          if hasBurstAttack
            damage=@battler.effects[PBEffects::SynergyBurstDamage].to_f
            #hp=@battler.totalhp.to_f
            #xmult=((damage/hp)*10).floor
            xmult=(damage*10).floor
            xmult=5 if xmult>5
            xpos=xmult
          end
          ypos=0
        end
      end
      if @pokken
        self.bitmap.blt(18,2-@ysynergyoffset,@synergycharge.bitmap,Rect.new(xpos*16,ypos*44,16,44))
      end
    elsif (@battler.index&1)!=0 # If foe's Pokémon
      xpos=5
      ypos=0
      if @pokken
        self.bitmap.blt(262,4,@synergygauge.bitmap,Rect.new(xpos*16,44*2,16,44))
      end
      if !pbInSafari?
        if @battler.effects[PBEffects::BurstMode]
          if hasBurstAttack
            xmult=5-@battler.effects[PBEffects::SynergyBurst]
            xmult=5 if xmult>5
            xmult=0 if xmult<0
            xpos=xmult
          end
          ypos=3
          #self.bitmap.blt(262,4,@synergygauge.bitmap,Rect.new(xpos,ypos*44,16,44))
        else
          if hasBurstAttack
            damage=@battler.effects[PBEffects::SynergyBurstDamage].to_f
            #hp=@battler.totalhp.to_f
            #xmult=5-((damage/hp)*10)
            xmult=5-(damage*10).floor
            xmult=5 if xmult>5
            xmult=0 if xmult<0
            xpos=xmult
          end
          ypos=2
        end
      end
      if @pokken
        self.bitmap.blt(262,4,@synergycharge.bitmap,Rect.new(xpos*16,ypos*44,16,44))
      end
    end
    #    self.bitmap.blt(0,0,@databox.bitmap,Rect.new(0,0,@databox.width,@databox.height))
    base=PokeBattle_Scene::BOXTEXTBASECOLOR
    shadow=PokeBattle_Scene::BOXTEXTSHADOWCOLOR
    pokename=@battler.name
    #pokename = $illusionnames[@battler.index] if $illusionnames != nil && $illusionnames[@battler.index] != nil && $illusion != nil && $illusion.is_a?(Array) && $illusion[@battler.index] != nil
#    if !@battler.battle.pbOwnedByPlayer?(@battler.index)
#    end
    
    if @battler.name.split('').last=="♂" || @battler.name.split('').last=="♀"
      pokename=@battler.name[0..-2]
    end
    pbSetSystemFont(self.bitmap)
    textpos=[]
    textpos.push([pokename,@spritebaseX+8,6,false,base,shadow]) #if $illusion == nil || $illusion[@battler.index] == nil || $illusionnames == nil ||  !isConst?(@battler.pokemon.ability,PBAbilities,:ILLUSION)
#    textpos.push([$illusionnames[battler.index],@spritebaseX+8,6,false,base,shadow]) if $illusion != nil && $illusionnames != nil && $illusionnames[battler.index] != nil && $illusion[@battler.index] != nil && isConst?(@battler.pokemon.ability,PBAbilities,:ILLUSION)
    genderX=self.bitmap.text_size(pokename).width  #if $illusion == nil || $illusionnames == nil || $illusionnames[@battler.index] == nil ||$illusion[@battler.index] == nil || !isConst?(@battler.pokemon.ability,PBAbilities,:ILLUSION)
#    Kernel.pbMessage($illusionnames[battler.index]) if $illusion != nil && $illusionnames != nil && $illusionnames[battler.index] != nil && $illusion[@battler.index] != nil && isConst?(@battler.pokemon.ability,PBAbilities,:ILLUSION)
#    genderX=self.bitmap.text_size($illusionnames[battler.index]).width  if $illusion != nil && $illusionnames != nil && $illusionnames[battler.index] != nil && $illusion[@battler.index] != nil && isConst?(@battler.pokemon.ability,PBAbilities,:ILLUSION)
    genderX+=@spritebaseX+14
    if !pbInSafari?
      if @battler.displayGender==0 # Male
        textpos.push([_INTL("♂"),genderX,6,false,Color.new(48,96,216),shadow])
      elsif @battler.displayGender==1 # Female
        textpos.push([_INTL("♀"),genderX,6,false,Color.new(248,88,40),shadow])
      end
    else
      if @battler.gender==0 # Male
        textpos.push([_INTL("♂"),genderX,6,false,Color.new(48,96,216),shadow])
      elsif @battler.gender==1 # Female
        textpos.push([_INTL("♀"),genderX,6,false,Color.new(248,88,40),shadow])
      end
    end
    pbDrawTextPositions(self.bitmap,textpos)
    pbSetSmallFont(self.bitmap)
    textpos=[]
    textpos.push([_INTL("Lv{1}",@battler.level),@spritebaseX+202,8,true,base,shadow])
    hpstring=_ISPRINTF("{1: 2d}/{2: 2d}",self.hp,@battler.totalhp)
    if @showhp
      textpos.push([hpstring,@spritebaseX+188,48,true,base,shadow])
    end
    getMegaEvoBoxTexture="Graphics/Pictures/battleMegaEvoBox.png"
    getMegaEvoBoxTexture="Graphics/Pictures/alpha.png" if @battler.species==PBSpecies::KYOGRE
    getMegaEvoBoxTexture="Graphics/Pictures/omega.png" if @battler.species==PBSpecies::GROUDON
    getMegaEvoBoxTexture="Graphics/Pictures/zeta.png" if @battler.species==PBSpecies::GIRATINA
    getMegaEvoBoxTexture="Graphics/Pictures/omicron.png" if @battler.species==PBSpecies::ARCEUS
    getMegaEvoBoxTexture="Graphics/Pictures/epsilon.png" if @battler.species==PBSpecies::REGIGIGAS

    pbDrawTextPositions(self.bitmap,textpos)
    if !pbInSafari?
      if @battler.isShiny?
     #if @battler.pokemon.isShiny?
        shinyX=227
        shinyX=-8 if (@battler.index&1)==0 # If player's Pokémon
        shinyY=14
        shinyY=-8 if (@battler.index&1)!=0 # If opponent's's Pokémon
  
        imagepos=[["Graphics/Pictures/shiny.png",@spritebaseX+shinyX,36+shinyY,0,0,-1,-1]]
        pbDrawImagePositions(self.bitmap,imagepos)
      end
    else
      if @battler.pokemon.isShiny?
        shinyX=227
        shinyX=-8 if (@battler.index&1)==0 # If player's Pokémon
        shinyY=14
        shinyY=-8 if (@battler.index&1)!=0 # If opponent's's Pokémon
  
        imagepos=[["Graphics/Pictures/shiny.png",@spritebaseX+shinyX,36+shinyY,0,0,-1,-1]]
        pbDrawImagePositions(self.bitmap,imagepos)
      end
    end
    #deltaarray=Kernel.getAllDeltas
    #if deltaarray.include?(@battler.pokemon.species)
    if !pbInSafari?
      if @battler.isDelta?
        deltaX=204
        deltaX=44 if (@battler.index&1)==0 # If player's Pokémon
        deltaY=14
        deltaY=-8 if (@battler.index&1)!=0 # If opponents's Pokémon
  
        imagepos=[["Graphics/Pictures/delta.png",@spritebaseX+deltaX,36+deltaY,0,0,-1,-1]]
        pbDrawImagePositions(self.bitmap,imagepos)
      end
    else
      deltaarray=Kernel.getAllDeltas
      if deltaarray.include?(@battler.pokemon.species)
               deltaX=204
        deltaX=44 if (@battler.index&1)==0 # If player's Pokémon
        deltaY=14
        deltaY=-8 if (@battler.index&1)!=0 # If opponents's Pokémon
  
        imagepos=[["Graphics/Pictures/delta.png",@spritebaseX+deltaX,36+deltaY,0,0,-1,-1]]
        pbDrawImagePositions(self.bitmap,imagepos)
      end
    end
=begin
    if !pbInSafari? && ((@battler.index==0 && deltaarray.include?(@battler.battle.battlers[2])) ||
      (@battler.index==1 && deltaarray.include?(@battler.battle.battlers[3])))
      
      deltaX=204
      deltaX=44 if (@battler.index&1)==0 # If player's Pokémon
      deltaY=-10
      deltaY=-8 if (@battler.index&1)!=0 # If opponents's Pokémon

      imagepos=[["Graphics/Pictures/delta.png",@spritebaseX+deltaX,36+deltaY,0,0,-1,-1]]
      pbDrawImagePositions(self.bitmap,imagepos)

    end
=end
    
    if !pbInSafari?
      #mewtwoAry=[2,3,5]
      displayMegaIcon=false
      displayMegaIcon=true if @battler.isMega?
=begin
        ((@battler.pokemon.form > 0 && @battler.species != PBSpecies::MEWTWO && 
        Kernel.pbGetMegaSpeciesList.include?(@battler.species))  || 
        (@battler.pokemon.form > 1 && @battler.pokemon.species==PBSpecies::FLYGON) || 
        (@battler.pokemon.form > 0 && @battler.pokemon.species==PBSpecies::KYOGRE) || 
        (@battler.pokemon.form==19 && @battler.pokemon.species==PBSpecies::ARCEUS) || 
        (@battler.pokemon.form==1 && @battler.pokemon.species==PBSpecies::REGIGIGAS) || 
        (@battler.pokemon.form > 1 && @battler.pokemon.species==PBSpecies::GIRATINA) || 
        (@battler.pokemon.form > 0 && @battler.pokemon.species==PBSpecies::GROUDON) || 
        (mewtwoAry.include?(@battler.pokemon.form) && battler.pokemon.species==PBSpecies::MEWTWO) || 
        (@battler.pokemon.form > 1 && @battler.pokemon.species==150))
      displayMegaIcon=false if (@battler.pokemon.form==4 && @battler.pokemon.species==150) || 
        (@battler.pokemon.form==4  && @battler.pokemon.species==150) || 
        (@battler.pokemon.form==2 && @battler.pokemon.species==448) || 
        (@battler.pokemon.form==2 && @battler.pokemon.species==282)
      if displayMegaIcon || (Kernel.pbGetArmorSpeciesList.include?(@battler.species) && 
         Kernel.pbGetArmorItemList.include?(@battler.item) && 
         Kernel.pbGetArmorSpeciesList.index(@battler.species)==Kernel.pbGetArmorItemList.index(@battler.item))
        displayMegaIcon = false if (Kernel.pbGetArmorSpeciesList.include?(@battler.species) && 
         Kernel.pbGetArmorItemList.include?(@battler.item) && 
         Kernel.pbGetArmorSpeciesList.index(@battler.species)==Kernel.pbGetArmorItemList.index(@battler.item))    
        displayMegaIcon = false if @battler.species==PBSpecies::MEWTWO && @battler.form==4
        zorohide=false
=end
        #if (@battler.hasWorkingAbility(:ILLUSION) || @battler.species==PBSpecies::ZOROARK)# && @hp>0
        #  if $illusion[@battler.index] != nil || (@battler.species==PBSpecies::ZOROARK && @battler.form!=0)
        #       displayMegaIcon = false 
        #       zorohide=true
        #  end
        #end
      if displayMegaIcon || @battler.isArmored?
        megaX=20
        megaY=32
        if @battler.isDelta?
        #if deltaarray.include?(@battler.pokemon.species)
          if @battler.isShiny?
            megaX=191
            megaY=8
          else
            megaX=204
            megaY=28
          end
        else
          megaX=179
          megaY=28
        end
        megaX=12 if (@battler.index&1)==0
        megaY=50 if (@battler.index&1)==0
        imagepos=[[getMegaEvoBoxTexture,megaX+40,megaY,0,0,-1,-1]] if displayMegaIcon
        imagepos=[["Graphics/Pictures/armor.png",megaX+40,megaY,0,0,-1,-1]] if @battler.isArmored?
        pbDrawImagePositions(self.bitmap,imagepos) #if displayMegaIcon || !zorohide
      end
      
      if @battler.status>0
        self.bitmap.blt(@spritebaseX+24,36,@statuses.bitmap,
          Rect.new(0,(@battler.status-1)*16,44,16))
      end
      howManyStatChanges=[]
      statarray=[PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
      PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      if !pbInSafari?
        for statc in statarray
          if @battler.stages[statc] != 0
  #       Kernel.pbMessage(statc.to_s)
            howManyStatChanges.push(statc)
          end
        end
        @databox2=AnimatedBitmap.new(_INTL("Graphics/Pictures/battleStatsFloat2"))
        if howManyStatChanges.length > 0
          for statVar in howManyStatChanges
            inverse=0
            inverse = 7 if @battler.stages[statVar] < 0
            #       self.bitmap.blt(@spritebaseX+24,42  ,@statchanges.bitmap,
            #      Rect.new(0,(statarray.index(statVar)+inverse)*16,41,16))
            #       self.bitmap.blt(@spritebaseX+24+41,42,@statchanges.bitmap,
            #      Rect.new(41,((@battler.stages[statVar].abs)-1+inverse)*16,41,16))
            #     @statbox.bitmap.blt(0,0,@databox2.bitmap,
            #    Rect.new(0,0,Graphics.width,Graphics.height))
            # @statbox.visible=false
            #   @statbox=PokemonStatBox.new(@battler,@doublebattle,@viewport)
            #  @statbox=
            #@statbox.refresh
          end
        end
      end
    end
    if @battler.owned && (@battler.index&1)==1
      imagepos=[["Graphics/Pictures/battleBoxOwned.png",@spritebaseX+8,36,0,0,-1,-1]]
      pbDrawImagePositions(self.bitmap,imagepos)
    end
 #     if @sprites != nil && @sprites["stat0"] != nil
 #   @sprites["stat0"].refresh 
 # elsif @sprites != nil
 #   @sprites["stat0"]=PokemonStatBox.new(@battler,@doublebattle,@viewport)
 # end
  
      #@statbox.refresh
       #Statchanges shadypenguinn

=begin
    statarray=[PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
      PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
    toppoint=0
    for statc in statarray
      toppoint += 16 if @battler.stages[statc] != 0
    end
    if toppoint > 0
      for statc in statarray
        if @battler.stages[statc]>0

          end
      end
    end
=end
    hpGaugeSize=PokeBattle_Scene::HPGAUGESIZE
    hpgauge=@battler.totalhp==0 ? 0 : (self.hp*hpGaugeSize/@battler.totalhp)
    hpgauge=1 if hpgauge==0 && self.hp>0
    hpzone=0
    hpzone=1 if self.hp<=(@battler.totalhp/2).floor
    hpzone=2 if self.hp<=(@battler.totalhp/4).floor
    hpcolors=[
       PokeBattle_Scene::HPCOLORSHADOW1,
       PokeBattle_Scene::HPCOLORBASE1,
       PokeBattle_Scene::HPCOLORSHADOW2,
       PokeBattle_Scene::HPCOLORBASE2,
       PokeBattle_Scene::HPCOLORSHADOW3,
       PokeBattle_Scene::HPCOLORBASE3
    ]
    # fill with HP color
    hpGaugeX=PokeBattle_Scene::HPGAUGE_X
    hpGaugeY=PokeBattle_Scene::HPGAUGE_Y
    expGaugeX=PokeBattle_Scene::EXPGAUGE_X
    expGaugeY=PokeBattle_Scene::EXPGAUGE_Y
    self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY,hpgauge,2,hpcolors[hpzone*2])
    self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY+2,hpgauge,4,hpcolors[hpzone*2+1])
    if @showexp
      # fill with EXP color
      self.bitmap.fill_rect(@spritebaseX+expGaugeX,expGaugeY,self.exp,2,PokeBattle_Scene::EXPCOLORSHADOW)
      self.bitmap.fill_rect(@spritebaseX+expGaugeX,expGaugeY+2,self.exp,2,PokeBattle_Scene::EXPCOLORBASE)
    end
  end

  #def isMegamon
  
  
  
  
  def update
    super
    #Kernel.pbPushRecent(@currenthp.to_s+","+@endhp.to_s)
    #@currenthp=@currenthp.floor
    #@endhp=@endhp.ceil
    @frame = (@frame+1)%24#@frame+=1
    if @animatingHP
      if @currenthp>@endhp
        #@currenthp -= [1,(@battler.totalhp/96).floor].max
        #@currenthp = @endhp if @currenthp<@endhp
#basedamage=(basedamage*100.0/opponent.hp)

#startexplevel=(tempexp1-startexp)*EXPGAUGESIZE/exprange
        #if ((@currenthp-@endhp)*@battler.totalhp/96).floor>(@battler.totalhp/96*81) && @incrementhp>15
        #  @currenthp-=[10,(@battler.totalhp/96*10)].max
        #if ((@currenthp-@endhp)*@battler.totalhp/96).floor>=(@battler.totalhp*41/96).floor && @incrementhp>10
        #  @currenthp-=[6,(@battler.totalhp*6/96).floor].max
        #if ((@currenthp-@endhp)*@battler.totalhp/96).floor>=(@battler.totalhp*24/96).floor && @incrementhp>8
        #  @currenthp-=[6,(@battler.totalhp*6/96).floor].max
=begin
        if ((@currenthp-@endhp)*@battler.totalhp/96).floor>=(@battler.totalhp*8/96).floor && @incrementhp>4
          @currenthp-=[4,(@battler.totalhp*4/96).floor].max
        elsif ((@currenthp-@endhp)*@battler.totalhp/96).floor>=(@battler.totalhp*2/96).floor && @incrementhp>1
          @currenthp-=[2,(@battler.totalhp*2/96).floor].max
        else
          @currenthp-=[1,(@battler.totalhp/96).floor].max
        end
=end
        if ((@currenthp-@endhp)*@battler.totalhp/96).floor>=(@battler.totalhp*81/96).floor && @incrementhp>15
          @currenthp-=[8,(@battler.totalhp*8/96).floor].max
        elsif ((@currenthp-@endhp)*@battler.totalhp/96).floor>=(@battler.totalhp*41/96).floor && @incrementhp>10
          @currenthp-=[6,(@battler.totalhp*6/96).floor].max
        elsif ((@currenthp-@endhp)*@battler.totalhp/96).floor>=(@battler.totalhp*17/96).floor && @incrementhp>6
          @currenthp-=[6,(@battler.totalhp*4/96).floor].max
        elsif ((@currenthp-@endhp)*@battler.totalhp/96).floor>=(@battler.totalhp*5/96).floor && @incrementhp>3
          @currenthp-=[2,(@battler.totalhp*2/96).floor].max
        elsif ((@currenthp-@endhp)*@battler.totalhp/96).floor>=(@battler.totalhp/96).floor && @incrementhp>1
          @currenthp-=[1,(@battler.totalhp/96).floor].max
        else
          @currenthp-=[1,(@battler.totalhp/96).floor].max
        end
        @currenthp = @endhp if @currenthp<@endhp
        
        #Kernel.pbMessage(_INTL("Total: {1}",@battler.totalhp))
        #Kernel.pbMessage(_INTL("Difference: {1}",@endhp-@currenthp))
        #Kernel.pbMessage(_INTL("Current: {1}",@currenthp))
        #Kernel.pbMessage(_INTL("Increment: {1}",@incrementhp))
      elsif @currenthp<@endhp
        #@currenthp += [1,(@battler.totalhp/96).floor].max
        #@currenthp = @endhp if @currenthp>@endhp

        #if (@endhp-@currenthp)*96/@battler.totalhp>=81 && @incrementhp>15
        #  @currenthp+=10#(@battler.totalhp/96).floor*8
        #if ((@endhp-@currenthp)*@battler.totalhp/96).floor>(@battler.totalhp*41/96).floor && @incrementhp>10
        #  @currenthp+=[4,(@battler.totalhp*4/96).floor].max
        #if ((@endhp-@currenthp)*@battler.totalhp/96).floor>=(@battler.totalhp*24/96).floor && @incrementhp>8
        #  @currenthp+=[6,(@battler.totalhp*6/96).floor].max
=begin
        if ((@endhp-@currenthp)*@battler.totalhp/96).floor>=(@battler.totalhp*8/96).floor && @incrementhp>4
          @currenthp+=[4,(@battler.totalhp*4/96).floor].max
        elsif ((@endhp-@currenthp)*@battler.totalhp/96).floor>=(@battler.totalhp*2/96).floor && @incrementhp>1
          @currenthp+=[2,(@battler.totalhp*2/96).floor].max
        else
          @currenthp+=[1,(@battler.totalhp/96).floor].max
        end
=end
        if ((@endhp-@currenthp)*@battler.totalhp/96).floor>=(@battler.totalhp*81/96).floor && @incrementhp>15
          @currenthp+=[8,(@battler.totalhp*8/96).floor].max
        elsif ((@endhp-@currenthp)*@battler.totalhp/96).floor>=(@battler.totalhp*41/96).floor && @incrementhp>10
          @currenthp+=[6,(@battler.totalhp*6/96).floor].max
        elsif ((@endhp-@currenthp)*@battler.totalhp/96).floor>=(@battler.totalhp*17/96).floor && @incrementhp>6
          @currenthp+=[4,(@battler.totalhp*4/96).floor].max
        elsif ((@endhp-@currenthp)*@battler.totalhp/96).floor>=(@battler.totalhp*5/96).floor && @incrementhp>3
          @currenthp+=[2,(@battler.totalhp*2/96).floor].max
        elsif ((@endhp-@currenthp)*@battler.totalhp/96).floor>=(@battler.totalhp/96).floor && @incrementhp>1
          @currenthp+=[1,(@battler.totalhp*1/96).floor].max
        else
          @currenthp+=[1,(@battler.totalhp/96).floor].max
        end
        @currenthp = @endhp if @currenthp>@endhp        
      end
      
      #if @currenthp<@endhp
      #  @currenthp+=1
      #elsif @currenthp>@endhp
      #  @currenthp-=1
      #end
      @incrementhp+=1
      
      refresh
      
      if @currenthp==@endhp
        @incrementhp=0
      end
      
      @animatingHP=false if @currenthp==@endhp
    end
    if @animatingEXP
      if !@showexp
        @currentexp=@endexp
      elsif @currentexp>@endexp
        @currentexp-=1
      elsif @currentexp<@endexp
=begin
        if (@endexp-@currentexp>=54) && @incrementexp>13
          @currentexp+=8
        elsif (@endexp-@currentexp>=24) && @incrementexp>8
          @currentexp+=6
        elsif (@endexp-@currentexp>=8) && @incrementexp>4
          @currentexp+=4
        elsif (@endexp-@currentexp>=2) && @incrementexp>1
          @currentexp+=2
        #elsif (@endexp-@currentexp>=1) && @incrementexp>1
        #  @currentexp+=1
        else
          @currentexp+=1
        end
=end
        if (@endexp-@currentexp>=81) && @incrementexp>15
          @currentexp+=8
        elsif (@endexp-@currentexp>=41) && @incrementexp>10
          @currentexp+=6
        elsif (@endexp-@currentexp>=17) && @incrementexp>6
          @currentexp+=4
        elsif (@endexp-@currentexp>=5) && @incrementexp>3
          @currentexp+=2
        elsif (@endexp-@currentexp>=1) && @incrementexp>1
          @currentexp+=1
        else
          @currentexp+=1
        end
      end
      #elsif @currentexp<@endexp
      #  if (@endexp-@currentexp>=15) && @increment>3
      #    @currentexp+=8
      #  elsif (@endexp-@currentexp>=7) && @increment>2
      #    @currentexp+=4
      #  elsif (@endexp-@currentexp>=3) && @increment>1
      #    @currentexp+=2
      #  else
      #    @currentexp+=1
      #  end
      #end
      
      @incrementexp+=1
      #elsif @currentexp<@endexp
      #  @currentexp+=1
      #elsif @currentexp>@endexp
      #  @currentexp-=1
      #end
        # @statbox.update

      refresh
      if @currentexp==@endexp
        if @currentexp==PokeBattle_Scene::EXPGAUGESIZE
          if @expflash==0
            pbSEPlay("expfull")
            self.flash(Color.new(64,200,248),8)
            @expflash=8
          else
            @expflash-=1
            if @expflash==0
              @animatingEXP=false
              refreshExpLevel
              @incrementexp=0
            end
          end
        else
          @animatingEXP=false
        end
      end
    end
    if @appearing
      if (@battler.index&1)==0 # if player's Pokémon
        self.x-=8
        @appearing=false if self.x<=@spriteX
      else
        self.x+=8
        @appearing=false if self.x>=@spriteX
      end
      self.y=@spriteY
      return
    end
    if ((@frame/10).floor&1)==1 && @selected==1 # When choosing commands for this Pokémon
      self.x=@spriteX
      self.y=@spriteY+2
    elsif ((@frame/5).floor&1)==1 && @selected==2 # When targeted or damaged
      self.x=@spriteX
      self.y=@spriteY+2
    else
      self.x=@spriteX
      self.y=@spriteY
    end
  end
end



def showShadow?(species)
  metrics=load_data("Data/metrics.dat")
  return metrics[2][species]>0
end



# Shows the enemy trainer(s)'s Pokémon being thrown out.  It appears at coords
# (@spritex,@spritey), and moves in y to @endspritey where it stays for the rest
# of the battle, i.e. the latter is the more important value.
# Doesn't show the ball itself being thrown.
class PokeballSendOutAnimation
  SPRITESTEPS=10
  STARTZOOM=0.125

  def initialize(sprite,spritehash,pkmn,doublebattle,illusionpoke)
    @illusionpoke=illusionpoke
    @disposed=false
    @ballused=pkmn.pokemon ? pkmn.pokemon.ballused : 0
    if @illusionpoke
      @ballused=@illusionpoke.ballused || 0
    end
    @PokemonBattlerSprite=sprite
    @PokemonBattlerSprite.visible=false
    @PokemonBattlerSprite.tone=Tone.new(248,248,248,248)
    @pokeballsprite=IconSprite.new(0,0,sprite.viewport)
    @pokeballsprite.setBitmap(sprintf("Graphics/Pictures/ball%02d",@ballused))
    if doublebattle
      @spritex=pkmn.index==1 ? 400 : 304 # x coordinate of foe trainer's Pokémon
    else
      @spritex=352                       # x coordinate of foe trainer's Pokémon
    end
    @spritex+=Graphics.width-480                      # Adjust x for screen size
    @spritey=128                   # Start y coordinate of foe trainer's Pokémon
    @spritey+=((Graphics.height-320)*3/4).floor # Adjust start y for screen size
    @spritehash=spritehash
    @pokeballsprite.x=@spritex-@pokeballsprite.bitmap.width/2
    @pokeballsprite.y=@spritey-4-@pokeballsprite.bitmap.height/2
    @pkmn=pkmn
    if @illusionpoke
      @endspritey=adjustBattleSpriteY(sprite,@illusionpoke.species,pkmn.index)
    else
      @endspritey=adjustBattleSpriteY(sprite,pkmn.species,pkmn.index)      # end y
    end
    @shadowY=@spritey-8 # from top
    @shadowY-=16 if doublebattle && pkmn.index==3
    @shadowX=@spritex-32 # from left
    @shadowVisible=showShadow?(pkmn.species)
    if @illusionpoke
      @shadowVisible=showShadow?(@illusionpoke.species)
    end
    @stepspritey=(@spritey-@endspritey)
    @zoomstep=(1.0-STARTZOOM)/SPRITESTEPS
    @animdone=false
    @frame=0
  end

  def disposed?
    return @disposed
  end

  def animdone?
    return @animdone
  end

  def dispose
    return if disposed?
    @pokeballsprite.dispose
    @disposed=true
  end

  def update
    return if disposed?
#      pbFrameUpdate(nil)

    @pokeballsprite.update
    @frame+=1
    if @frame==2
      pbSEPlay("recall")
    end
    if @frame==4
      @PokemonBattlerSprite.visible=true
      @PokemonBattlerSprite.zoom_x=STARTZOOM
      @PokemonBattlerSprite.zoom_y=STARTZOOM
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,@spritey)
      if @illusionpoke
        pbPlayCry(@illusionpoke)
      else
        pbPlayCry(@pkmn.pokemon ? @pkmn.pokemon : @pkmn.species) #if $illusion == nil || !$illusion.is_a?(Array) || $illusion[@pkmn.index] == nil
      end
      #pbPlayCry($illusionpoke) if $illusion != nil && $illusion.is_a?(Array) && $illusion[@pkmn.index] != nil
    # $illusionnames[@battler.index] if $illusionnames != nil && $illusionnames[@battler.index] != nil && $illusion != nil && $illusion.is_a?(Array) && $illusion[@battler.index] != nil

      @pokeballsprite.setBitmap(sprintf("Graphics/Pictures/ball%02d_open",@ballused))
    end
    if @frame==8
      @pokeballsprite.visible=false
    end
    if @frame>8 && @frame<=16
      color=Color.new(248,248,248,256-(16-@frame)*32)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color   
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>16 && @frame<=24
      color=Color.new(248,248,248,(24-@frame)*32)
      tone=(24-@frame)*32
      @PokemonBattlerSprite.tone=Tone.new(tone,tone,tone,tone)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color   
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>5 && @PokemonBattlerSprite.zoom_x<1.0
      @PokemonBattlerSprite.zoom_x+=@zoomstep
      @PokemonBattlerSprite.zoom_y+=@zoomstep
      @PokemonBattlerSprite.zoom_x=1.0 if @PokemonBattlerSprite.zoom_x > 1.0
      @PokemonBattlerSprite.zoom_y=1.0 if @PokemonBattlerSprite.zoom_y > 1.0
      currentY=@spritey-(@stepspritey*@PokemonBattlerSprite.zoom_y)
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,currentY)
      @PokemonBattlerSprite.y=currentY
    end
    if @PokemonBattlerSprite.tone.gray<=0 && @PokemonBattlerSprite.zoom_x>=1.0
      @animdone=true
      if @spritehash["shadow#{@pkmn.index}"]
        @spritehash["shadow#{@pkmn.index}"].x=@shadowX
        @spritehash["shadow#{@pkmn.index}"].y=@shadowY
        @spritehash["shadow#{@pkmn.index}"].visible=@shadowVisible
      end
    end
  end
end






# Shows the player's (or partner's) Pokémon being thrown out.  It appears at
# (@spritex,@spritey), and moves in y to @endspritey where it stays for the rest
# of the battle, i.e. the latter is the more important value.
# Doesn't show the ball itself being thrown.
class PokeballPlayerSendOutAnimation #boobies
#  Ball curve: 8,52; 22,44; 52, 96
#  Player: Color.new(16*8,23*8,30*8)
  SPRITESTEPS=10
  STARTZOOM=0.125

  def initialize(sprite,spritehash,pkmn,doublebattle,illusionpoke)
    @illusionpoke=illusionpoke
    @disposed=false
    @PokemonBattlerSprite=sprite
    @pkmn=pkmn
    @PokemonBattlerSprite.visible=false
    @doublebattle=doublebattle
    @pkmn=pkmn
    @PokemonBattlerSprite.tone=Tone.new(248,248,248,248)
    @spritehash=spritehash
    
##    snew=CapsulePlayerSendOutAnimation.new() #@sprites["pokemon#{@battlerindex}"],
       #@sprites,@battle.battlers[@battlerindex],@battle.doublebattle
    if doublebattle
      @spritex=pkmn.index==0 ? 64 : 180       # x coordinate of player's Pokémon
    else
      @spritex=128                            # x coordinate of player's Pokémon
    end
    @spritey=Graphics.height-64         # Start y coordinate of player's Pokémon
    if @illusionpoke
      @endspritey=adjustBattleSpriteY(@PokemonBattlerSprite,@illusionpoke.species,pkmn.index)
    else
      @endspritey=adjustBattleSpriteY(@PokemonBattlerSprite,493,pkmn.index)
    end
    @animdone=false
    @frame=0
    @capsulesprite=@PokemonBattlerSprite
    @endspritey2=adjustBattleSpriteY(@capsulesprite,493,pkmn.index)

  end

  def disposed?
    return @disposed
  end

  def animdone?
    return @animdone
  end

  def dispose
    return if disposed?
    @disposed=true
  end
    
   # @databox=AnimatedBitmap.new("Graphics/Pictures/introOak")
   # @databox.bitmap.visible=true
   # @spriteX=236+Graphics.width-500
   # @spriteY=128+10
   # bitmap2 = RPG::Cache.picture("introOak")
   # @databox.bitmap.blt(80,80,bitmap2, Rect.new(80,80,80,80))
    
    
  def update

    return if disposed?

    @frame+=1

  
    if @frame==4
      @PokemonBattlerSprite.visible=true
      @PokemonBattlerSprite.zoom_x=STARTZOOM
      @PokemonBattlerSprite.zoom_y=STARTZOOM
      pbSEPlay("recall")
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,@spritey)
      if @illusionpoke
        pbPlayCry(@illusionpoke)
      else
        pbPlayCry(@pkmn.pokemon ? @pkmn.pokemon : @pkmn.species)
      end
      @capsulesprite.visible=true
      @capsulesprite.zoom_x=STARTZOOM
      @capsulesprite.zoom_y=STARTZOOM
      pbSpriteSetCenter(@capsulesprite,@spritex,@spritey)
    end

#    if @frame==5
      #
#    @sprites["capsule_1"].y=100
#      @sprites["capsule_1"].x=100
#    end
#    if @frame==6
#      @sprites["capsule_1"].y=-400
#      @sprites["capsule_1"].x=-400
#      @sprites["capsule_2"].y=100
#      @sprites["capsule_2"].x=100
#    end
#    if @frame==7
#      @sprites["capsule_2"].y=-400
#      @sprites["capsule_2"].x=-400
#      @sprites["capsule_3"].y=100
#      @sprites["capsule_3"].x=100
#    end
#    if @frame==8
#      @sprites["capsule_3"].y=-400
#      @sprites["capsule_3"].x=-400
#      @sprites["capsule_4"].y=100
#      @sprites["capsule_4"].x=100
#    end
#    if @frame==9
#      @sprites["capsule_4"].y=-400
#      @sprites["capsule_4"].x=-400
#      @sprites["capsule_5"].y=100
#      @sprites["capsule_5"].x=100
#      end
#    if @frame==10
#      @sprites["capsule_5"].y=-400
#      @sprites["capsule_5"].x=-400
#      @sprites["capsule_6"].y=100
#      @sprites["capsule_6"].x=100
#    end
#    if @frame==11
#      @sprites["capsule_6"].y=-400
#      @sprites["capsule_6"].x=-400
#      @sprites["capsule_7"].y=100
#      @sprites["capsule_7"].x=100
#    end
#    if @frame==12
#      @sprites["capsule_8"].y=-400
#      @sprites["capsule_8"].x=-400 
#    end
 
    if @frame>8 && @frame<=16
      color=Color.new(248,248,248,256-(16-@frame)*32)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color   
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>16 && @frame<=24
      color=Color.new(248,248,248,(24-@frame)*32)
      tone=(24-@frame)*32
      @PokemonBattlerSprite.tone=Tone.new(tone,tone,tone,tone)
      @capsulesprite.tone=Tone.new(tone,tone,tone,tone)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color   
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>5 && @PokemonBattlerSprite.zoom_x<1.0
      @PokemonBattlerSprite.zoom_x+=0.1
      @PokemonBattlerSprite.zoom_y+=0.1
      @PokemonBattlerSprite.zoom_x=1.0 if @PokemonBattlerSprite.zoom_x > 1.0
      @PokemonBattlerSprite.zoom_y=1.0 if @PokemonBattlerSprite.zoom_y > 1.0
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,0)
      @PokemonBattlerSprite.y=@spritey+(@endspritey-@spritey)*@PokemonBattlerSprite.zoom_y
      @capsulesprite.zoom_x+=0.1
      @capsulesprite.zoom_y+=0.1
      @capsulesprite.zoom_x=1.0 if @capsulesprite.zoom_x > 1.0
      @capsulesprite.zoom_y=1.0 if @capsulesprite.zoom_y > 1.0
      pbSpriteSetCenter(@capsulesprite,@spritex,0)
      @capsulesprite.y=@spritey+(@endspritey-@spritey)*@capsulesprite.zoom_y
    end
    if @PokemonBattlerSprite.tone.gray<=0 && @PokemonBattlerSprite.zoom_x>=1.0
      @animdone=true
    
    
    
    end
  end
end

##################################
# CAPSULE ########################
##################################
=begin
class CapsulePlayerSendOutAnimation
#  Ball curve: 8,52; 22,44; 52, 96
#  Player: Color.new(16*8,23*8,30*8)
  SPRITESTEPS=10
  STARTZOOM=0.125
  def initialize()
    bitmap = RPG::Cache.pictures("introOak")
    self.contents.blt(80,80,bitmap, Rect.new(80,80,80,80)
    return 0
  end

  

  def disposed?
    return @disposed
  end

  def animdone?
    return @animdone
  end

  def dispose
    return if disposed?
    @disposed=true
  end

  def update
    return if disposed?
    @frame+=1
    if @frame==4
      @PokemonBattlerSprite.visible=true
      @PokemonBattlerSprite.zoom_x=STARTZOOM
      @PokemonBattlerSprite.zoom_y=STARTZOOM
      pbSEPlay("recall")
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,@spritey)
      pbPlayCry(@pkmn.pokemon ? @pkmn.pokemon : @pkmn.species)
    end
    if @frame>8 && @frame<=16
      color=Color.new(248,248,248,256-(16-@frame)*32)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color   
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>16 && @frame<=24
      color=Color.new(248,248,248,(24-@frame)*32)
      tone=(24-@frame)*32
      @PokemonBattlerSprite.tone=Tone.new(tone,tone,tone,tone)
      @spritehash["enemybase"].color=color
      @spritehash["playerbase"].color=color   
      @spritehash["battlebg"].color=color
      for i in 0...4
        @spritehash["shadow#{i}"].color=color if @spritehash["shadow#{i}"]
      end
    end
    if @frame>5 && @PokemonBattlerSprite.zoom_x<1.0
      @PokemonBattlerSprite.zoom_x+=0.1
      @PokemonBattlerSprite.zoom_y+=0.1
      @PokemonBattlerSprite.zoom_x=1.0 if @PokemonBattlerSprite.zoom_x > 1.0
      @PokemonBattlerSprite.zoom_y=1.0 if @PokemonBattlerSprite.zoom_y > 1.0
      pbSpriteSetCenter(@PokemonBattlerSprite,@spritex,0)
      @PokemonBattlerSprite.y=@spritey+(@endspritey-@spritey)*@PokemonBattlerSprite.zoom_y
    end
    if @PokemonBattlerSprite.tone.gray<=0 && @PokemonBattlerSprite.zoom_x>=1.0
      @animdone=true
    end
  end
end
=end
# Shows the enemy trainer(s) and the enemy party lineup sliding off screen.
# Doesn't show the ball thrown or the Pokémon.
class TrainerFadeAnimation
  def initialize(sprites)
    @frame=0
    @sprites=sprites
    @animdone=false
  end

  def animdone?
    return @animdone
  end

  def update
    return if @animdone
    @frame+=1
    @sprites["trainer"].x+=8
    @sprites["trainer2"].x+=8 if @sprites["trainer2"]
    @sprites["partybase1"].x+=8
    @sprites["partybase1"].opacity-=12
    for i in 0...6
      @sprites["enemy#{i}"].opacity-=12
      @sprites["enemy#{i}"].x+=8 if @frame>=i*4
    end
    @animdone=true if @sprites["trainer"].x>=Graphics.width &&
       ( !@sprites["trainer2"]||@sprites["trainer2"].x>=Graphics.width )
  end
end



# Shows the player (and partner) and the player party lineup sliding off screen.
# Shows the player's/partner's throwing animation (if they have one).  Doesn't
# show the ball thrown or the Pokémon.
class PlayerFadeAnimation
  def initialize(sprites)
    @frame=0
    @sprites=sprites
    @animdone=false
  end

  def animdone?
    return @animdone
  end

  def update
    return if @animdone
    @frame+=1
    @sprites["player"].x-=8
    @sprites["playerB"].x-=8 if @sprites["playerB"]
    @sprites["partybase2"].x-=8
    @sprites["partybase2"].opacity-=12
    for i in 0...6
      if @sprites["player#{i}"]
        @sprites["player#{i}"].opacity-=12 
        @sprites["player#{i}"].x-=8 if @frame>=i*4
      end
    end
    pa=@sprites["player"]
    pb=@sprites["playerB"]
    pawidth=175
    pbwidth=175
    if (pa && pa.bitmap && !pa.bitmap.disposed?)
      if pa.bitmap.height<pa.bitmap.width
 #       numframes=pa.bitmap.width/pa.bitmap.height # Number of frames
#        pawidth=pa.bitmap.width/numframes # Width per frame
        @sprites["player"].src_rect.x=pawidth*1 if @frame>0
        @sprites["player"].src_rect.x=pawidth*2 if @frame>8
        @sprites["player"].src_rect.x=pawidth*3 if @frame>12
        @sprites["player"].src_rect.x=pawidth*4 if @frame>16
        @sprites["player"].src_rect.width=pawidth
      else
        pawidth=pa.bitmap.width
        @sprites["player"].src_rect.x=0
        @sprites["player"].src_rect.width=pawidth
      end
    end
    if (pb && pb.bitmap && !pb.bitmap.disposed?)
      if pb.bitmap.height<pb.bitmap.width
        numframes=pb.bitmap.width/pb.bitmap.height # Number of frames
        pbwidth=pb.bitmap.width/numframes # Width per frame
        @sprites["playerB"].src_rect.x=pbwidth*1 if @frame>0
        @sprites["playerB"].src_rect.x=pbwidth*2 if @frame>8
        @sprites["playerB"].src_rect.x=pbwidth*3 if @frame>12
        @sprites["playerB"].src_rect.x=pbwidth*4 if @frame>16
        @sprites["playerB"].src_rect.width=pbwidth
      else
        pbwidth=pb.bitmap.width
        @sprites["playerB"].src_rect.x=0
        @sprites["playerB"].src_rect.width=pbwidth
      end
    end
    if pb
      @animdone=true if pb.x<=-pbwidth
    else
      @animdone=true if pa.x<=-pawidth
    end
  end
end



# Shows the player's Poké Ball being thrown to capture a Pokémon.
def pokeballThrow(ball,shakes,targetBattler)
  balltype=@battle.pbGetBallType(ball)
  if !@sprites["pokemon#{targetBattler}"].visible
    battlerVisible=false
  else
    battlerVisible=true
  end
  oldvisible=@sprites["shadow#{targetBattler}"].visible
  @sprites["shadow#{targetBattler}"].visible=false
  ball=sprintf("Graphics/Pictures/ball%02d",balltype)
  ballopen=sprintf("Graphics/Pictures/ball%02d_open",balltype)
  # sprites
  spriteBall=IconSprite.new(0,0,@viewport)
  spriteBall.visible=false
  
  spritePoke=@sprites["pokemon#{targetBattler}"]
  # pictures
  pictureBall=PictureEx.new(0)
  picturePoke=PictureEx.new(0)
  dims=[spritePoke.x,spritePoke.y]
  center=getSpriteCenter(@sprites["pokemon#{targetBattler}"])
  ballendy=128-4+((Graphics.height-320)*3/4).floor
  # starting positions
  pictureBall.moveVisible(1,true)
  pictureBall.moveName(1,ball)
  pictureBall.moveOrigin(1,PictureOrigin::Center)
  pictureBall.moveXY(0,1,10,180)
  picturePoke.moveVisible(1,true)
  picturePoke.moveOrigin(1,PictureOrigin::Center)
  picturePoke.moveXY(0,1,center[0],center[1])
  # directives
  picturePoke.moveSE(1,"Audio/SE/throw")
  pictureBall.moveCurve(30,1,150,70,30+Graphics.width/2,10,center[0],center[1])
  pictureBall.moveAngle(30,1,-1080)
  pictureBall.moveAngle(0,pictureBall.totalDuration,0)
  delay=pictureBall.totalDuration+4
  picturePoke.moveTone(10,delay,Tone.new(0,-224,-224,0))
  delay=picturePoke.totalDuration
  picturePoke.moveSE(delay,"Audio/SE/recall")
  pictureBall.moveName(delay+4,ballopen)
  picturePoke.moveZoom(15,delay,0)
  picturePoke.moveXY(15,delay,center[0],center[1])
  picturePoke.moveSE(delay+10,"Audio/SE/jumptoball")
  picturePoke.moveVisible(delay+15,false)
  pictureBall.moveName(picturePoke.totalDuration+2,ball)
  delay=picturePoke.totalDuration+6
  pictureBall.moveXY(15,delay,center[0],ballendy)
  pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
  pictureBall.moveXY(10,pictureBall.totalDuration+2,center[0],ballendy-((ballendy-center[1])*2/3))
  pictureBall.moveXY(10,pictureBall.totalDuration+2,center[0],ballendy)
  pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
  pictureBall.moveXY(6,pictureBall.totalDuration+2,center[0],ballendy-((ballendy-center[1])*1/3))
  pictureBall.moveXY(6,pictureBall.totalDuration+2,center[0],ballendy)
  pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
  pictureBall.moveXY(3,pictureBall.totalDuration+2,center[0],ballendy-((ballendy-center[1])*1/6))
  pictureBall.moveXY(3,pictureBall.totalDuration+2,center[0],ballendy)
  pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
  picturePoke.moveXY(0,pictureBall.totalDuration,center[0],ballendy)
  delay=pictureBall.totalDuration+18# if shakes==0
  [shakes,3].min.times do
    pictureBall.moveSE(delay,"Audio/SE/ballshake")
    pictureBall.moveXY(3,delay,center[0]-8,ballendy)
    pictureBall.moveAngle(3,delay,20) # positive means counterclockwise
    delay=pictureBall.totalDuration
    pictureBall.moveXY(6,delay,center[0]+8,ballendy)
    pictureBall.moveAngle(6,delay,-20) # negative means clockwise
    delay=pictureBall.totalDuration
    pictureBall.moveXY(3,delay,center[0],ballendy)
    pictureBall.moveAngle(3,delay,0)
    delay=pictureBall.totalDuration+18
  end
  if shakes<4
    picturePoke.moveSE(delay,"Audio/SE/recall")
    pictureBall.moveName(delay,ballopen)
    pictureBall.moveVisible(delay+10,false)
    picturePoke.moveVisible(delay,true)
    picturePoke.moveZoom(15,delay,100)
    picturePoke.moveXY(15,delay,center[0],center[1])
    picturePoke.moveTone(0,delay,Tone.new(248,248,248,248))
    picturePoke.moveTone(24,delay,Tone.new(0,0,0,0))
    delay=picturePoke.totalDuration
  end
  pictureBall.moveXY(0,delay,center[0],ballendy)
  picturePoke.moveOrigin(picturePoke.totalDuration,PictureOrigin::TopLeft)
  picturePoke.moveXY(0,picturePoke.totalDuration,dims[0],dims[1])
  loop do
    pictureBall.update
    picturePoke.update
    setPictureIconSprite(spriteBall,pictureBall)
    setPictureSprite(spritePoke,picturePoke)
    @sprites["pokemon#{targetBattler}"].visible=false if !battlerVisible
    pbGraphicsUpdate
    pbInputUpdate
    pbFrameUpdate(nil)

    break if !pictureBall.running? && !picturePoke.running?
  end
  if shakes<4
    @sprites["shadow#{targetBattler}"].visible=oldvisible
  end
  spriteBall.dispose
end



####################################################

class PokeBattle_Scene
  USECOMMANDBOX=true # If true, expects the file Graphics/Pictures/battleCommand.png
  USEFIGHTBOX=true # If true, expects the file Graphics/Pictures/battleFight.png
  MESSAGEBASECOLOR=Color.new(80,80,88)
  MESSAGESHADOWCOLOR=Color.new(160,160,168)
  MENUBASECOLOR=Color.new(80,80,88)
  MENUSHADOWCOLOR=Color.new(160,160,168)
  BOXTEXTBASECOLOR=Color.new(72,72,72)
  BOXTEXTSHADOWCOLOR=Color.new(184,184,184)
  EXPCOLORBASE=Color.new(72,144,248)
  EXPCOLORSHADOW=Color.new(48,96,216)
# Green HP color
  HPCOLORBASE1=Color.new(24,192,32)
  HPCOLORSHADOW1=Color.new(0,144,0)
# Orange HP color
  HPCOLORBASE2=Color.new(248,176,0)
  HPCOLORSHADOW2=Color.new(176,104,8)
# Red HP color
  HPCOLORBASE3=Color.new(248,88,40)
  HPCOLORSHADOW3=Color.new(168,48,56)
# Position of HP gauge
  HPGAUGE_X=102
  HPGAUGE_Y=40
# Position of EXP gauge
  EXPGAUGE_X=6
  EXPGAUGE_Y=76
# Size of gauges
  EXPGAUGESIZE=192
  HPGAUGESIZE=96

  BLANK=0
  MESSAGEBOX=1
  COMMANDBOX=2
  FIGHTBOX=3

  attr_accessor :abortable

  def initialize
    @battle=nil
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @pkmnwindows=[nil,nil,nil,nil]
    @sprites={}
    @battlestart=true
    @messagemode=false
    @abortable=false
    @aborted=false
  end

  def pbUpdate
    partyAnimationUpdate
    @sprites["battlebg"].update if @sprites["battlebg"].respond_to?("update")
    @sprites["battlebg2"].update if @sprites["battlebg2"] != nil && @sprites["battlebg2"].respond_to?("update")
  end

  def pbGraphicsUpdate
    partyAnimationUpdate
# pbBackdrop
    @sprites["battlebg"].update if @sprites["battlebg"] != nil && @sprites["battlebg"].respond_to?("update")
    @sprites["battlebg2"].update if @sprites["battlebg2"] != nil && @sprites["battlebg2"].respond_to?("update")
    @sprites["enemybase"].update if @sprites["enemybase"] != nil && @sprites["enemybase"].respond_to?("update")
    @sprites["playerbase"].update if @sprites["playerbase"] != nil && @sprites["playerbase"].respond_to?("update")

    Graphics.update
 end

  def pbInputUpdate
    Input.update
    if Input.trigger?(Input::B) && @abortable && !@aborted
      @aborted=true
      @battle.pbAbort
    end
  end

  def pbShowWindow(windowtype)
    @sprites["messagebox"].visible = ( windowtype==MESSAGEBOX ||
       windowtype==COMMANDBOX || windowtype==FIGHTBOX || windowtype==BLANK )
    @sprites["messagewindow"].visible = (windowtype==MESSAGEBOX)
    @sprites["commandwindow"].visible = (windowtype==COMMANDBOX)
    @sprites["fightwindow"].visible = (windowtype==FIGHTBOX)
  end

  def pbSetMessageMode(mode)
    @messagemode=mode
    msgwindow=@sprites["messagewindow"]
    if mode # Within Pokémon command
      msgwindow.baseColor=MENUBASECOLOR
      msgwindow.shadowColor=MENUSHADOWCOLOR
      msgwindow.opacity=255
      msgwindow.x=16
      msgwindow.width=Graphics.width
      msgwindow.height=96
      msgwindow.y=Graphics.height-msgwindow.height+2
    else
      msgwindow.baseColor=MESSAGEBASECOLOR
      msgwindow.shadowColor=MESSAGESHADOWCOLOR
      msgwindow.opacity=0
      msgwindow.x=16
      msgwindow.width=Graphics.width-32
      msgwindow.height=96
      msgwindow.y=Graphics.height-msgwindow.height+2
    end
  end

  def pbWaitMessage
    if @briefmessage
      pbShowWindow(MESSAGEBOX)
      cw=@sprites["messagewindow"]
      60.times do
        pbGraphicsUpdate
        pbInputUpdate
                pbFrameUpdate(nil)

      end
      cw.text=""
      cw.visible=false
      @briefmessage=false
    end
  end

  def pbDisplayMessage(msg,brief=false)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    cw=@sprites["messagewindow"]
    cw.text=msg
    i=0
    loop do
      pbGraphicsUpdate
      pbFrameUpdate(nil)
      pbInputUpdate
      cw.update
      if i==40
        cw.text=""
        cw.visible=false
        return
      end
      if Input.trigger?(Input::C) || @abortable
        if cw.pausing?
          pbPlayDecisionSE() if !@abortable
          cw.resume
        end
      end
      if !cw.busy?
        if brief
          @briefmessage=true
          return
        end
        i+=1
      end
    end
  end

  def pbDisplayPausedMessage(msg)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    if @messagemode
      @switchscreen.pbDisplay(msg)
      return
    end
    cw=@sprites["messagewindow"]
    cw.text=_ISPRINTF("{1:s}\1",msg)
    loop do
      pbGraphicsUpdate
      pbInputUpdate
              pbFrameUpdate(nil)

      if Input.trigger?(Input::C) || @abortable
        if cw.busy?
          pbPlayDecisionSE() if cw.pausing? && !@abortable
          cw.resume
        else
          cw.text=""
          pbPlayDecisionSE()
          cw.visible=false if @messagemode
          return
        end
      end
      cw.update
    end
  end

  def pbDisplayConfirmMessage(msg)
    return pbShowCommands(msg,[_INTL("Yes"),_INTL("No")],1)==0
  end

  def pbShowCommands(msg,commands,defaultValue)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    dw=@sprites["messagewindow"]
    dw.text=msg
    cw = Window_CommandPokemon.new(commands)
    cw.x=Graphics.width-cw.width
    cw.y=Graphics.height-cw.height-dw.height
    cw.index=0
    cw.viewport=@viewport
    pbRefresh
    loop do
      cw.visible=!dw.busy?
      pbGraphicsUpdate
      pbInputUpdate
      
      pbFrameUpdate(cw)
      dw.update
      if Input.trigger?(Input::B) && defaultValue>=0
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text=""
          return defaultValue
        end
      end
      if Input.trigger?(Input::C)
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text=""
          return cw.index
        end
      end
    end
  end

  def pbFrameUpdate(cw)
    cw.update if cw
    for i in 0..3
      if @sprites["battler#{i}"]
        @sprites["battler#{i}"].update
      end
      if @sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"].update
      end
      if @sprites["stat#{i}"]
        @sprites["stat#{i}"].update
      end
    end
  end

  def pbRefresh
    for i in 0..3
      if @sprites["battler#{i}"]
        @sprites["battler#{i}"].refresh
      end
      if @sprites["stat#{i}"]
        @sprites["stat#{i}"].refresh
      end
      
    end
  end

  def pbAddSprite(id,x,y,filename,viewport)
    sprite=IconSprite.new(x,y,viewport)
    if filename
      sprite.setBitmap(filename) rescue nil
    end
    @sprites[id]=sprite
    return sprite
  end

  def pbAddPlane(id,filename,viewport)
    sprite=AnimatedPlane.new(viewport)
    if filename
      sprite.setBitmap(filename)
    end
    @sprites[id]=sprite
    return sprite
  end

  def pbDisposeSprites
    pbDisposeSpriteHash(@sprites)
  end

  def pbBeginCommandPhase
    # Called whenever a new round begins.
    @battlestart=false
  end

  def pbShowOpponent(index)
    if @battle.opponent
      if @battle.opponent.is_a?(Array)
        trainerfile=sprintf("Graphics/Characters/trainer%03d",@battle.opponent[index].trainertype)
      else
        trainerfile=sprintf("Graphics/Characters/trainer%03d",@battle.opponent.trainertype)
      end
    else
      trainerfile="Graphics/Characters/trfront"
    end
    pbAddSprite("trainer",Graphics.width,16,trainerfile,@viewport)
    
    if @sprites["trainer"].bitmap && @battle.opponent
        for i in 0..5
          @battle.opponent.clothes[i] = 0 if !@battle.opponent.is_a?(Array) && @battle.opponent.clothes && @battle.opponent.clothes[i]==nil
          @battle.opponent[index].clothes[i] = 0 if @battle.opponent.is_a?(Array) && @battle.opponent[index].clothes[i]==nil
        end
        @sprites["trainer"]=Kernel.appendToFront(@sprites["trainer"],@battle.opponent) if !@battle.opponent.is_a?(Array)
        @sprites["trainer"]=Kernel.appendToFront(@sprites["trainer"],@battle.opponent[index]) if @battle.opponent.is_a?(Array)

      @sprites["trainer"].y-=@sprites["trainer"].bitmap.height-128
      @sprites["trainer"].y+=@foeyoffset
        end
    20.times do
      pbGraphicsUpdate
      pbInputUpdate
              pbFrameUpdate(nil)

      @sprites["trainer"].x-=6
    end

  end

  def pbHideOpponent
    20.times do
      pbGraphicsUpdate
      pbInputUpdate
              pbFrameUpdate(nil)

      @sprites["trainer"].x+=6
    end
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.width)
    @sprites["helpwindow"].y=0
    @sprites["helpwindow"].x=0
    @sprites["helpwindow"].text=text
    @sprites["helpwindow"].visible=true
  end

  def pbHideHelp
    @sprites["helpwindow"].visible=false
  end

  def pbBackdrop(disposeOld=false)
    if disposeOld
     # @sprites["enemybase"].dispose # For compatibility with RGSS2
     # @sprites["playerbase"].dispose # For compatibility with RGSS2
     # @sprites["battlebg"].dispose #
    end
    
    outdoor=false
    if $game_map && pbGetMetadata($game_map.map_id,MetadataOutdoor)
      outdoor=true
    end
    environ=@battle.environment
    # Choose backdrop.
    backdrop="City"
    #stealmyclient
    if environ==PBEnvironment::Cave
      backdrop="Cave"
    elsif environ==PBEnvironment::Underwater
      backdrop="Underwater"
    elsif environ==PBEnvironment::MovingWater || environ==PBEnvironment::StillWater || $PokemonGlobal.surfing
      backdrop="Water"
    elsif environ==PBEnvironment::Rock
      backdrop="Mountain"
    elsif !outdoor
      backdrop="City"
    end
    if $game_map
      back=pbGetMetadata($game_map.map_id,MetadataBattleBack)
      if back && back!=""
        backdrop=back
      end
    end
    if environ==PBEnvironment::MovingWater || environ==PBEnvironment::StillWater
      backdrop="Water"
    end
    
    if $PokemonGlobal && $PokemonGlobal.nextBattleBack
      backdrop=$PokemonGlobal.nextBattleBack
    end
    # Choose bases.
    base=""
    trialname=""
    if environ==PBEnvironment::Grass || environ==PBEnvironment::TallGrass
      trialname="Grass"
    elsif environ==PBEnvironment::Sand
      trialname="Sand"
    elsif $PokemonGlobal.surfing
      trialname="Water"
    end
    if pbResolveBitmap(sprintf("Graphics/Battlebacks/playerbase"+backdrop+trialname))
      base=trialname
    end
    # Choose time of day.
    time=""
    trialname=""
    timenow=pbGetTimeNow
    if PBDayNight.isNight?(timenow)
      trialname="Night"
    elsif PBDayNight.isEvening?(timenow)
      trialname="Eve"
    end
    if pbResolveBitmap(sprintf("Graphics/Battlebacks/battlebg"+backdrop+trialname))
      time=trialname
    end
    # Apply graphics.
    #@sprites["enemybase
    battlebg="Graphics/Battlebacks/battlebg"+backdrop+time
    enemybase="Graphics/Battlebacks/enemybase"+backdrop+base+time
    playerbase="Graphics/Battlebacks/playerbase"+backdrop+base+time
    pbAddPlane("battlebg",battlebg,@viewport)
    pbAddSprite("enemybase",-256,64+@foeyoffset,enemybase,@viewport) if !disposeOld # ends at (224,64)
    pbAddSprite("playerbase",Graphics.width-128,176+@traineryoffset,playerbase,@viewport) if !disposeOld # ends at (0,192)
    @sprites["enemybase"].z=-1 if !disposeOld # For compatibility with RGSS2
    @sprites["playerbase"].z=-1 if !disposeOld # For compatibility with RGSS2 
    @sprites["battlebg"].z=-1 # For compatibility with RGSS2  
 # Kernel.pbMessage(@sprites["enemybase"].x.to_s)
  end
        
            
    def pbBackdropMove(move,player=true,isWeather=false)
        @sprites["battlebg2"].dispose if @sprites["battlebg2"] #&& !isWeather

      backdrop=""
      if move != -1
        case move
          when 0
          when PBMoves::FISSURE
            backdrop="MoveFissure"
          when PBMoves::INSURGENCY
            backdrop="MoveInsurgency"
                      when PBMoves::BANISHMENT
            backdrop="MoveBanishment"

          when PBMoves::CLOSECOMBAT
            backdrop="MoveCloseCombat"
          when PBMoves::DRAGONSASCENT
            backdrop="MoveDragonsAscent"
          when PBMoves::WHIRLPOOL
            backdrop="MoveWhirlpool"
          when PBMoves::DYNAMICPUNCH 
            if player
              backdrop = "MoveDynamicPunch"
            else
              backdrop = "MoveDynamicPunchOpp"
            end
          when PBMoves::FLAREBLITZ 
            if player
              backdrop = "MoveFlareBlitz"
              else
              backdrop = "MoveFlareBlitzOpp"
            end
          when PBMoves::FLY
              backdrop="MoveCloseCombat"
          when PBMoves::LEAFSTORM
             backdrop="MoveLeafStorm"
          when PBMoves::SPACIALREND
             backdrop="MoveSpacialRend"
        end
      end
      weatherVar= "nope"
      case @battle.weather
          when PBWeather::SUNNYDAY
            weatherVar="battleBgWeatherSun"
          when PBWeather::HARSHSUN
            weatherVar="battleBgWeatherSun"
          when PBWeather::HAIL
            weatherVar="battleBgWeatherHail"
          when PBWeather::NEWMOON
            weatherVar="battleBgWeatherNewMoon"
          when PBWeather::SANDSTORM
            weatherVar="battleBgWeatherSandstorm"
          when PBWeather::RAINDANCE
            weatherVar="battleBgWeatherRain"
          when PBWeather::HEAVYRAIN
            weatherVar="battleBgWeatherRain"
      end
      if backdrop=="" && weatherVar != "nope"
        battlebg="Graphics/Battlebacks/"+weatherVar
        pbAddPlane("battlebg2",battlebg,@viewport)
        @sprites["battlebg2"].z=-1 # For compatibility with RGSS2 if move!=1
      end
      if backdrop!=""

          battlebg="Graphics/Battlebacks/battlebg"+backdrop

          pbAddPlane("battlebg2",battlebg,@viewport)

          @sprites["battlebg2"].z=-1 # For compatibility with RGSS2 if move!=1
      bittrip=BitmapCache.load_bitmap("Graphics/Battlebacks/"+weatherVar) if weatherVar != "nope"
      #@sprites["battlebg2"].bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) if weatherVar != "nope"
   pbGraphicsUpdate
    pbFrameUpdate(nil)
        return true
      else
        return false
      end
      
  end

  def inPartyAnimation?
    return @enablePartyAnim && @partyAnimPhase<4
  end

  def partyAnimationRestart(doublePreviewTop,previewSecondParty=false)
  @doublePreviewTop=doublePreviewTop
  @previewSecondParty=previewSecondParty
  yvalue=114
  yvalue-=50 if doublePreviewTop
  pbAddSprite("partybase1",-400,yvalue,"Graphics/Pictures/battleLineup",@viewport)
  @sprites["partybase1"].visible=true
  @partyAnimPhase=0
end 

def partyAnimationFade
  frame=0
  while(frame<24)
    if @partyAnimPhase!=4
      pbGraphicsUpdate
              pbFrameUpdate(nil)

      next
    end
    frame+=1
    @sprites["partybase1"].x+=8
    @sprites["partybase1"].opacity-=12
    for i in 0...6
      partyI = i
      partyI += 6 if @previewSecondParty
      @sprites["enemy#{partyI}"].opacity-=12
      @sprites["enemy#{partyI}"].x+=8 if frame>=i*4
    end
    pbGraphicsUpdate
            pbFrameUpdate(nil)

  end
  for i in 0...6
    partyI = i
    partyI += 6 if @previewSecondParty
    pbDisposeSprite(@sprites,"player#{partyI}")
  end
  @previewSecondParty = false
  pbDisposeSprite(@sprites,"partybase1")
end

  
  def partyAnimationUpdate
    return if !inPartyAnimation?
    if @partyAnimPhase==0
      @sprites["partybase1"].x+=16
      @sprites["partybase2"].x-=16 if @sprites["partybase2"]
      @partyAnimPhase=1 if @sprites["partybase1"].x+@sprites["partybase1"].bitmap.width>=248
      return
    end
    if @partyAnimPhase==1
      @enemyendpos=172
      @playerendpos=296
      @partyAnimPhase=2
      @partyAnimI=@previewSecondParty ? 6 : 0
    end
    if @partyAnimPhase==2
      if @partyAnimI>=(@previewSecondParty ? 12 : 6)
        @partyAnimPhase=4
        return
      end
      if @partyAnimI>=@battle.party2.length || !@battle.party2[@partyAnimI]
        pbAddSprite("enemy#{@partyAnimI}",-36,84,
           "Graphics/Pictures/ballempty",@viewport)
      elsif @battle.party2[@partyAnimI].hp<=0 || @battle.party2[@partyAnimI].egg?
        pbAddSprite("enemy#{@partyAnimI}",-36,84,
           "Graphics/Pictures/ballfainted",@viewport)
      elsif @battle.party2[@partyAnimI].status>0
        pbAddSprite("enemy#{@partyAnimI}",-36,84,
           "Graphics/Pictures/ballstatus",@viewport)
      else
        pbAddSprite("enemy#{@partyAnimI}",-36,84,
           "Graphics/Pictures/ballnormal",@viewport)
         end
         @sprites["enemy#{@partyAnimI}"].y-=50 if @doublePreviewTop

      if @partyAnimI==@battle.party1.length || !@battle.party1[@partyAnimI]
        pbAddSprite("player#{@partyAnimI}",Graphics.width+4,148+@traineryoffset,
           "Graphics/Pictures/ballempty",@viewport)
      elsif @battle.party1[@partyAnimI].hp<=0 || @battle.party1[@partyAnimI].egg?
        pbAddSprite("player#{@partyAnimI}",Graphics.width+4,148+@traineryoffset,
           "Graphics/Pictures/ballfainted",@viewport)
      elsif @battle.party1[@partyAnimI].status>0
        pbAddSprite("player#{@partyAnimI}",Graphics.width+4,148+@traineryoffset,
           "Graphics/Pictures/ballstatus",@viewport)
      else
        pbAddSprite("player#{@partyAnimI}",Graphics.width+4,148+@traineryoffset,
           "Graphics/Pictures/ballnormal",@viewport)
      end
      @partyAnimPhase=3
    end
    if @partyAnimPhase==3
      @sprites["enemy#{@partyAnimI}"].x+=16
      @sprites["player#{@partyAnimI}"].x-=16 if @sprites["partybase2"]
      if @sprites["enemy#{@partyAnimI}"].x>=@enemyendpos
        @partyAnimPhase=2
        @partyAnimI+=1
        @enemyendpos-=32
        @playerendpos+=32
      end
    end

  end

  def pbStartBattle(battle)
    # Called whenever the battle begins
    @battle=battle
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @sprites.clear
    @sprites.clear
    @viewport=Viewport.new(0,Graphics.height/2,Graphics.width,0)
    @viewport.z=99999
    @battleboxvp=Viewport.new(0,0,Graphics.width,Graphics.height)
    @battleboxvp.z=99999
    @showingplayer=true
    @showingenemy=true
    @traineryoffset=(Graphics.height-320) # Adjust player's side for screen size
    @foeyoffset=(@traineryoffset*3/4).floor  # Adjust foe's side for screen size
    pbBackdrop
    #titties
    #firecapsules
    
    #    pbAddSprite("capsule_1",-400,-400,"Graphics/Capsules/fire_1",@viewport)
    #    pbAddSprite("capsule_2",-400,-400,"Graphics/Capsules/fire_2",@viewport)
    #    pbAddSprite("capsule_3",-400,-400,"Graphics/Capsules/fire_3",@viewport)
    #    pbAddSprite("capsule_4",-400,-400,"Graphics/Capsules/fire_4",@viewport)
    #    pbAddSprite("capsule_5",-400,-400,"Graphics/Capsules/fire_5",@viewport)
    #    pbAddSprite("capsule_6",-400,-400,"Graphics/Capsules/fire_6",@viewport)
    #    pbAddSprite("capsule_7",-400,-400,"Graphics/Capsules/fire_7",@viewport)
    #    pbAddSprite("capsule_8",-400,-400,"Graphics/Capsules/fire_8",@viewport)
    #heartcapsules
    #    pbAddSprite("capsule_9",-400,-400,"Graphics/Capsules/hearts_1",@viewport)
    #    pbAddSprite("capsule_10",-400,-400,"Graphics/Capsules/hearts_2",@viewport)
    #    pbAddSprite("capsule_11",-400,-400,"Graphics/Capsules/hearts_3",@viewport)
    #    pbAddSprite("capsule_12",-400,-400,"Graphics/Capsules/hearts_4",@viewport)
    #    pbAddSprite("capsule_13",-400,-400,"Graphics/Capsules/hearts_5",@viewport)
    #    pbAddSprite("capsule_14",-400,-400,"Graphics/Capsules/hearts_6",@viewport)
    #    pbAddSprite("capsule_15",-400,-400,"Graphics/Capsules/hearts_7",@viewport)
    #    pbAddSprite("capsule_16",-400,-400,"Graphics/Capsules/hearts_8",@viewport)
    #elecapsules
    #    pbAddSprite("capsule_17",-400,-400,"Graphics/Capsules/ele_1",@viewport)
    #    pbAddSprite("capsule_18",-400,-400,"Graphics/Capsules/ele_2",@viewport)
    #    pbAddSprite("capsule_19",-400,-400,"Graphics/Capsules/ele_3",@viewport)
    #    pbAddSprite("capsule_20",-400,-400,"Graphics/Capsules/ele_4",@viewport)
    #    pbAddSprite("capsule_21",-400,-400,"Graphics/Capsules/ele_5",@viewport)
    #    pbAddSprite("capsule_22",-400,-400,"Graphics/Capsules/ele_6",@viewport)
    #    pbAddSprite("capsule_23",-400,-400,"Graphics/Capsules/ele_7",@viewport)
    #    pbAddSprite("capsule_24",-400,-400,"Graphics/Capsules/ele_8",@viewport)
    #quecapsules
    #    pbAddSprite("capsule_25",-400,-400,"Graphics/Capsules/que_1",@viewport)
    #    pbAddSprite("capsule_26",-400,-400,"Graphics/Capsules/que_2",@viewport)
    #    pbAddSprite("capsule_27",-400,-400,"Graphics/Capsules/que_3",@viewport)
    #    pbAddSprite("capsule_28",-400,-400,"Graphics/Capsules/que_4",@viewport)
    #    pbAddSprite("capsule_29",-400,-400,"Graphics/Capsules/que_5",@viewport)
    #    pbAddSprite("capsule_30",-400,-400,"Graphics/Capsules/que_6",@viewport)
    #    pbAddSprite("capsule_31",-400,-400,"Graphics/Capsules/que_7",@viewport)
    #    pbAddSprite("capsule_32",-400,-400,"Graphics/Capsules/que_8",@viewport)
    #pictureBall.moveXY(0,1,10,180)

    #   @sprites["capsule_1"].moveXy=-400
    #   @sprites["capsule_2"].y=-400
    #   @sprites["capsule_3"].y=-400
    #   @sprites["capsule_4"].y=-400
    #   @sprites["capsule_5"].y=-400
    #   @sprites["capsule_6"].y=-400
    #   @sprites["capsule_7"].y=-400
    #   @sprites["capsule_8"].y=-400

    pbAddSprite("partybase1",-448,114,"Graphics/Pictures/battleLineup",@viewport)
    pbAddSprite("partybase2",Graphics.width+8,178+@traineryoffset,"Graphics/Pictures/battleLineup",@viewport)
    @sprites["partybase2"].mirror=true
    @sprites["partybase1"].visible=false
    @sprites["partybase2"].visible=false
    if @battle.opponent
      if @battle.opponent.is_a?(Array)
        trainerfile=sprintf("Graphics/Characters/trainer%03d",@battle.opponent[0].trainertype)
        pbAddSprite("trainer",-144,6+@foeyoffset,trainerfile,@viewport)
        trainerfile=sprintf("Graphics/Characters/trainer%03d",@battle.opponent[1].trainertype)
        pbAddSprite("trainer2",-240,6+@foeyoffset,trainerfile,@viewport)
      else
        trainerfile=sprintf("Graphics/Characters/trainer%03d",@battle.opponent.trainertype)
        pbAddSprite("trainer",-192,6+@foeyoffset,trainerfile,@viewport)
      end
    else
      trainerfile="Graphics/Characters/trfront"
      pbAddSprite("trainer",-192,6+@foeyoffset,trainerfile,@viewport)
    end
    if @sprites["trainer"].bitmap
      @sprites["trainer"].x-=(@sprites["trainer"].bitmap.width-128)/2
      @sprites["trainer"].y-=@sprites["trainer"].bitmap.height-128
    end
    if @sprites["trainer2"] && @sprites["trainer2"].bitmap
      for i in 0..5
        @battle.opponent[1].clothes[i] = 0 if @battle.opponent[1].clothes[i]==nil
      end
    @sprites["trainer"]=Kernel.appendToFront(@sprites["trainer"],@battle.opponent[1])
    if @sprites["trainer"].bitmap
      for i in 0..5
        @battle.opponent[0].clothes[i] = 0 if @battle.opponent[0].clothes[i]==nil
      end
      @sprites["trainer"]=Kernel.appendToFront(@sprites["trainer"],@battle.opponent[0])
    end
    @sprites["trainer2"].x-=(@sprites["trainer2"].bitmap.width-128)/2
    @sprites["trainer2"].y-=@sprites["trainer2"].bitmap.height-128
    else
      if @battle.opponent
        for i in 0..5
          @battle.opponent.clothes[i] = 0 if @battle.opponent.clothes[i]==nil
        end
        @sprites["trainer"]=Kernel.appendToFront(@sprites["trainer"],@battle.opponent)
      end
    end
    if battle.doublebattle
      pbAddSprite("shadow3",0,0,"Graphics/Pictures/battleShadow",@viewport)
      @sprites["shadow3"].visible=false
      @sprites["pokemon3"]=PokemonBattlerSprite.new(battle.doublebattle,3,@viewport)
    end
    @sprites["shadow0"]=IconSprite.new(0,0,@viewport)
    pbAddSprite("shadow1",0,0,"Graphics/Pictures/battleShadow",@viewport)
    @sprites["shadow1"].visible=false
    @sprites["pokemon0"]=PokemonBattlerSprite.new(battle.doublebattle,0,@viewport)
    @sprites["pokemon1"]=PokemonBattlerSprite.new(battle.doublebattle,1,@viewport)
    if battle.doublebattle
      @sprites["shadow2"]=IconSprite.new(0,0,@viewport)
      @sprites["pokemon2"]=PokemonBattlerSprite.new(battle.doublebattle,2,@viewport)      
    end
    @sprites["battler0"]=PokemonDataBox.new(battle.battlers[0],battle.doublebattle,@viewport)
    @sprites["stat0"]=PokemonStatBox.new(battle.battlers[0],battle.doublebattle,@viewport) if !battle.doublebattle && !pbInSafari?
    @sprites["battler1"]=PokemonDataBox.new(battle.battlers[1],battle.doublebattle,@viewport) 
    @sprites["stat1"]=PokemonStatBox.new(battle.battlers[1],battle.doublebattle,@viewport) if !battle.doublebattle && !pbInSafari?
    if battle.doublebattle
      @sprites["battler2"]=PokemonDataBox.new(battle.battlers[2],battle.doublebattle,@viewport)
      @sprites["battler3"]=PokemonDataBox.new(battle.battlers[3],battle.doublebattle,@viewport)
      @sprites["stat2"]=PokemonStatBox.new(battle.battlers[2],battle.doublebattle,@viewport) if !battle.doublebattle && !pbInSafari?
      @sprites["stat3"]=PokemonStatBox.new(battle.battlers[3],battle.doublebattle,@viewport) if !battle.doublebattle && !pbInSafari?
    end
    if @battle.player.is_a?(Array)
      #miltank
      trainerfile=sprintf("Graphics/Characters/trback%03d",@battle.player[0].trainertype)
      pbAddSprite("player",Graphics.width+64-48,96+@traineryoffset-42,trainerfile,@viewport)    
      trainerfile=sprintf("Graphics/Characters/trback%03d",@battle.player[1].trainertype)
      pbAddSprite("playerB",Graphics.width+64+48,96+@traineryoffset-42,trainerfile,@viewport)
      if @sprites["player"].bitmap
        for i in 0..5
          @battle.player[0].clothes[i] = 0 if @battle.player[0].clothes[i]==nil
        end
        @sprites["player"]=Kernel.appendToBack(@sprites["player"],@battle.player[0])
        if @sprites["player"].bitmap.width>@sprites["player"].bitmap.height
          @sprites["player"].src_rect.x=0
          @sprites["player"].src_rect.width=@sprites["player"].bitmap.width/5
        end
        @sprites["player"].x-=(@sprites["player"].src_rect.width-128)/2
      end
      if @sprites["playerB"].bitmap
        for i in 0..5
          @battle.player[1].clothes[i] = 0 if @battle.player[1].clothes[i]==nil
        end
        @sprites["playerB"]=Kernel.appendToBack(@sprites["playerB"],@battle.player[1])
        if @sprites["playerB"].bitmap.width>@sprites["playerB"].bitmap.height
          @sprites["playerB"].src_rect.x=0
          @sprites["playerB"].src_rect.width=@sprites["playerB"].bitmap.width/5
        end
        @sprites["playerB"].x-=(@sprites["playerB"].src_rect.width-175)/2
      end
    else
      if $game_variables[41]==15
        if $Trainer.gender==1
          trainerfile=sprintf("Graphics/Characters/trback%03d",280)
        else
          trainerfile=sprintf("Graphics/Characters/trback%03d",279)
        end
      else
        trainerfile=sprintf("Graphics/Characters/trback%03d",@battle.player.trainertype)
      end
      pbAddSprite("player",Graphics.width+64,96+@traineryoffset-42,trainerfile,@viewport)
      if @sprites["player"].bitmap
        for i in 0..5
          @battle.player.clothes[i] = 0 if @battle.player.clothes[i]==nil
        end
        @sprites["player"]=Kernel.appendToBack(@sprites["player"],@battle.player)
        if @sprites["player"].bitmap.width>@sprites["player"].bitmap.height
          @sprites["player"].src_rect.x=0
          @sprites["player"].src_rect.width=@sprites["player"].bitmap.width/5
        end
        @sprites["player"].x-=(@sprites["player"].src_rect.width-175)/2
      end
    end
    pbAddSprite("messagebox",0,Graphics.height-96,"Graphics/Pictures/battleMessage",@viewport)
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
    @sprites["helpwindow"].visible=false
    @sprites["messagewindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["commandwindow"]=CommandMenuDisplay.new(@viewport)
    @sprites["fightwindow"]=FightMenuDisplay.new(nil,@viewport)
    @sprites["messagewindow"].letterbyletter=true
    @sprites["messagewindow"].viewport=@viewport
    @sprites["messagebox"].z=50
    @sprites["messagewindow"].z=100
    @sprites["commandwindow"].z=100
    @sprites["fightwindow"].z=100
    pbShowWindow(MESSAGEBOX)
    pbSetMessageMode(false)
    trainersprite1=@sprites["trainer"]
    trainersprite2=@sprites["trainer2"]
    if !@battle.opponent
      @sprites["trainer"].visible=false
      if @battle.party2.length>=1
        @sprites["pokemon1"].setPokemonBitmap(@battle.party2[0],false)
        @sprites["pokemon1"].tone=Tone.new(-128,-128,-128,-128)
        @sprites["pokemon1"].x=-192 # ends at 144*2
        @sprites["shadow1"].x=-192+32
        @sprites["shadow1"].y=120+@foeyoffset
        species=@battle.party2[0].species
        @sprites["pokemon1"].visible=true
        @sprites["shadow1"].visible=showShadow?(species)
        pbPositionPokemonSprite(
           @sprites["pokemon1"],@sprites["pokemon1"].x,@sprites["pokemon1"].y
        )
        @sprites["pokemon1"].y=adjustBattleSpriteY(
           @sprites["pokemon1"],species,1)
        trainersprite1=@sprites["pokemon1"]
      end
      if @battle.party2.length==2
        @sprites["pokemon3"].setPokemonBitmap(@battle.party2[1],false)
        @sprites["pokemon3"].tone=Tone.new(-128,-128,-128,-128)
        @sprites["pokemon1"].x=-144
        @sprites["shadow1"].x=-144+32
        @sprites["pokemon3"].x=-240
        @sprites["shadow3"].x=-240+32
        @sprites["shadow3"].y=104+@foeyoffset
        species=@battle.party2[1].species
        @sprites["pokemon3"].visible=true
        @sprites["shadow3"].visible=showShadow?(species)
        pbPositionPokemonSprite(
           @sprites["pokemon3"],@sprites["pokemon3"].x,@sprites["pokemon3"].y
        )
        @sprites["pokemon3"].y=adjustBattleSpriteY(
           @sprites["pokemon3"],species,3)
        trainersprite2=@sprites["pokemon3"]
      end
    end
    
    loop do
      if @viewport.rect.y>0
        @viewport.rect.y-=4
        @viewport.rect.height+=8
      end
        for i in @sprites
        i[1].ox=@viewport.rect.x #if i != @sprites["stat0"] && i != @sprites["stat1"] && i != @sprites["stat2"] && i != @sprites["stat3"]
        i[1].oy=@viewport.rect.y
      end
      appearspeed=8
      @sprites["enemybase"].x+=appearspeed
      @sprites["playerbase"].x-=appearspeed
      @sprites["shadow1"].x+=appearspeed
      @sprites["shadow3"].x+=appearspeed if @sprites["shadow3"]
      trainersprite1.x+=appearspeed
      trainersprite2.x+=appearspeed if trainersprite2
      @sprites["player"].x-=appearspeed
      @sprites["playerB"].x-=appearspeed  if @sprites["playerB"]
      pbGraphicsUpdate
      pbInputUpdate
              pbFrameUpdate(nil)

      break if @sprites["enemybase"].x>=Graphics.width-256
    end
    # Play cry for wild Pokémon
    if !@battle.opponent
      pbPlayCry(@battle.party2[0])
    end
    if @battle.opponent
      @enablePartyAnim=true
      @partyAnimPhase=0
      @sprites["partybase1"].visible=true
      @sprites["partybase2"].visible=true
    else
      @sprites["battler1"].appear
      @sprites["battler3"].appear if @battle.party2.length==2 
      appearing=true
      begin
        pbGraphicsUpdate
                pbFrameUpdate(nil)

        pbInputUpdate
        @sprites["battler1"].update
        appearing=@sprites["battler1"].appearing
        @sprites["pokemon1"].tone.red+=8 if @sprites["pokemon1"].tone.red<0
        @sprites["pokemon1"].tone.blue+=8 if @sprites["pokemon1"].tone.blue<0
        @sprites["pokemon1"].tone.green+=8 if @sprites["pokemon1"].tone.green<0
        @sprites["pokemon1"].tone.gray+=8 if @sprites["pokemon1"].tone.gray<0
        if @battle.party2.length==2 
          @sprites["battler3"].update
          @sprites["pokemon3"].tone.red+=8 if @sprites["pokemon3"].tone.red<0
          @sprites["pokemon3"].tone.blue+=8 if @sprites["pokemon3"].tone.blue<0
          @sprites["pokemon3"].tone.green+=8 if @sprites["pokemon3"].tone.green<0
          @sprites["pokemon3"].tone.gray+=8 if @sprites["pokemon3"].tone.gray<0
          appearing=(appearing||@sprites["battler3"].appearing)
        end
      end while appearing
      # Show shiny animation for wild Pokémon
      if !pbInSafari?
        if @battle.battlers[1].isShiny?
        #if @battle.party2[0].isShiny?
          pbCommonAnimation("Shiny",@battle.battlers[1],nil)
        end
        if @battle.party2.length==2
          if @battle.battlers[3].isShiny?
          #if @battle.party2[1].isShiny?
            pbCommonAnimation("Shiny",@battle.battlers[3],nil)
          end
        end
      else
        if @battle.party2[0].isShiny?
          pbCommonAnimation("Shiny",@battle.battlers[1],nil)
        end
        if @battle.party2.length==2
          if @battle.party2[1].isShiny?
            pbCommonAnimation("Shiny",@battle.battlers[3],nil)
          end
        end
      end
      if @battle.opponent
        if @battle.party2[0].pokemon.ballcapsule0
          pbMoveAnimation("FireSeal",@battle.battlers[1],nil)
        end
        if @battle.party2[0].pokemon.ballcapsule1
          pbMoveAnimation("HeartSeal",@battle.battlers[1],nil)
        end
        if @battle.party2[0].pokemon.ballcapsule2
          pbMoveAnimation("EleSeal",@battle.battlers[1],nil)
        end
        if @battle.party2[0].pokemon.ballcapsule3
          pbMoveAnimation("QueSeal",@battle.battlers[1],nil)
        end
        if @battle.part2.length==2
          if @battle.party2[1].pokemon.ballcapsule0
            pbMoveAnimation("FireSeal",@battle.battlers[3],nil)
          end
          if @battle.party2[1].pokemon.ballcapsule1
            pbMoveAnimation("HeartSeal",@battle.battlers[3],nil)
          end
          if @battle.party2[1].pokemon.ballcapsule2
            pbMoveAnimation("EleSeal",@battle.battlers[3],nil)
          end
          if @battle.party2[1].pokemon.ballcapsule3
            pbMoveAnimation("QuesSeal",@battle.battlers[3],nil)
          end
        end
      end
    end
    $game_switches[190]=true
   end
   
  def pbUpdateSprites(spriteIndex)
    pkmn=@battle.battlers[spriteIndex].pokemon
    return if @sprites["pokemon#{spriteIndex}"]==nil
    if spriteIndex==0 ||spriteIndex==2 
      @sprites["pokemon#{spriteIndex}"].setPokemonBitmap(pkmn,true)
    else
      @sprites["pokemon#{spriteIndex}"].setPokemonBitmap(pkmn,false)
    end
    @sprites["pokemon#{spriteIndex}"].update
  end

  def pbHideSprites(spriteIndex)
    return if @sprites["pokemon#{spriteIndex}"]==nil
    @sprites["pokemon#{spriteIndex}"].visible=false
    @sprites["pokemon#{spriteIndex}"].update
  end
  
  def pbShowSprites(spriteIndex)
    return if @sprites["pokemon#{spriteIndex}"]==nil
    @sprites["pokemon#{spriteIndex}"].visible=true
    @sprites["pokemon#{spriteIndex}"].update
  end
  
  def pbEndBattle(result)
    #$illusionnames=nil
    #$illusionpoke=nil
    #$illusion=nil
    @abortable=false
    pbShowWindow(BLANK)
    # Fade out all sprites
    $PokemonTemp.dependentEvents.check_faint
    
    if $game_switches != nil && $Trainer != nil && $Trainer.clothes != nil
      if $Trainer.clothes[2]==0
        for i in 0..4
          $Trainer.clothes[i]=$game_variables[111][i]
        end 
        pbChangePlayer($game_variables[122])
      end
    end
      
    $game_screen.pictures[22].erase

    
    
    
    pbBGMFade(1.0)
    pbFadeOutAndHide(@sprites)
    pbDisposeSprites
    
    Spriteset_Map.new($game_map)
    for i in 0..$Trainer.party.length-1
      poke = $Trainer.party[i]
      if isConst?(poke.species,PBSpecies,:DELTADITTO) 
        poke.form=PBTypes::WATER
      elsif isConst?(poke.species,PBSpecies,:CASTFORM) ||
            isConst?(poke.species,PBSpecies,:CHERRIM) ||
            isConst?(poke.species,PBSpecies,:DARMANITAN) ||
            isConst?(poke.species,PBSpecies,:AEGISLASH) ||
            isConst?(poke.species,PBSpecies,:GRENINJA) ||
            isConst?(poke.species,PBSpecies,:FROGADIER) ||
            isConst?(poke.species,PBSpecies,:FROAKIE) ||
            isConst?(poke.species,PBSpecies,:KECLEON) ||
            isConst?(poke.species,PBSpecies,:KYOGRE) ||
            isConst?(poke.species,PBSpecies,:GROUDON) ||
            isConst?(poke.species,PBSpecies,:MELOETTA) ||
            isConst?(poke.species,PBSpecies,:DELTAEMOLGA) ||
            isConst?(poke.species,PBSpecies,:REGIGIGAS) ||
            (isConst?(poke.species,PBSpecies,:GIRATINA) && poke.form==2) ||
            (isConst?(poke.species,PBSpecies,:ARCEUS) && poke.form==19) ||
            (Kernel.pbGetArmorSpeciesList.include?(poke.species) && 
            !Kernel.pbGetArmorItemList.include?(poke.item)) ||
            (isConst?(poke.species,PBSpecies,:GARDEVOIR) && poke.form==1) || 
            (isConst?(poke.species,PBSpecies,:GARDEVOIR) && poke.form==3) ||
            (isConst?(poke.species,PBSpecies,:LUCARIO) && poke.form==1) || 
            (isConst?(poke.species,PBSpecies,:LUCARIO) && poke.form==3) ||
            (isConst?(poke.species,PBSpecies,:DELTATYPHLOSION) && !poke.form==0) ||
            (isConst?(poke.species,PBSpecies,:MEWTWO) && !isConst?(poke.item,PBItems,:MEWTWOMACHINE) && !poke.form==4) ||
            (isConst?(poke.species,PBSpecies,:TYRANITAR) && !isConst?(poke.item,PBItems,:TYRANITARMACHINE)) ||
            (isConst?(poke.species,PBSpecies,:FLYGON) && !isConst?(poke.item,PBItems,:FLYGONMACHINE)) ||
            (!isConst?(poke.species,PBSpecies,:GARDEVOIR) && !isConst?(poke.species,PBSpecies,:LUCARIO) && !isConst?(poke.species,PBSpecies,:MEWTWO) && !isConst?(poke.species,PBSpecies,:TYRANITAR) && 
            !isConst?(poke.species,PBSpecies,:FLYGON) && Kernel.pbGetMegaSpeciesList.include?(poke.species))
        if (isConst?(poke.species,PBSpecies,:GARDEVOIR) && (poke.form==3 || poke.form==2)) || 
           (isConst?(poke.species,PBSpecies,:LUCARIO) && (poke.form==3 || poke.form==2))
          poke.form=2
        elsif (isConst?(poke.species,PBSpecies,:MEWTWO) && (poke.form==4 || poke.form==5))
          poke.form=4
        else
          poke.form=0
        end
      end
    end
    $PokemonTemp.dependentEvents.refresh_sprite
  end

  def pbRecall(battlerindex)
    @briefmessage=false
    origin=Graphics.height-64
    if @battle.pbIsOpposing?(battlerindex)
      @sprites["shadow#{battlerindex}"].visible=false
      origin=128+@foeyoffset
    end
    spritePoke=@sprites["pokemon#{battlerindex}"]
    picturePoke=PictureEx.new(0)
    dims=[spritePoke.x,spritePoke.y]
    center=getSpriteCenter(spritePoke)
    # starting positions
    picturePoke.moveVisible(1,true)
    picturePoke.moveOrigin(1,PictureOrigin::Center)
    picturePoke.moveXY(0,1,center[0],center[1])
    # directives
    picturePoke.moveTone(10,1,Tone.new(0,-224,-224,0))
    delay=picturePoke.totalDuration
    picturePoke.moveSE(delay,"Audio/SE/recall")
    picturePoke.moveZoom(15,delay,0)
    picturePoke.moveXY(15,delay,center[0],origin)
    picturePoke.moveVisible(picturePoke.totalDuration,false)
    picturePoke.moveTone(0,picturePoke.totalDuration,Tone.new(0,0,0,0))
    picturePoke.moveOrigin(picturePoke.totalDuration,PictureOrigin::TopLeft)
    loop do
      picturePoke.update
      setPictureSprite(spritePoke,picturePoke)
      pbGraphicsUpdate
              pbFrameUpdate(nil)

      pbInputUpdate
      break if !picturePoke.running?
    end
  end

  def pbTrainerSendOut(battlerindex,pkmn,boolean=false)
    if !@doublebattle   
      pbCloning
    end
    
    illusionpoke=@battle.battlers[battlerindex].effects[PBEffects::Illusion]
    @briefmessage=false
    fadeanim=nil
    while inPartyAnimation?; end
    if @showingenemy
      fadeanim=TrainerFadeAnimation.new(@sprites)
    end
    frame=0 #boobies #ILLU1
  #  if @battle.opponent.trainertype = 0 || @battle.opponent.trainertype = 1
  #    #@battle.battlers[battlerindex]
  #    pkmn = $Trainer.pokemonParty[index]
  #    end  
  #tempillusion = false
    #if pkmn && isConst?(pkmn.ability,PBAbilities,:ILLUSION) && !boolean# && @battle.pbParty(battlerindex).length>1
    #  $illusion = Array.new if !$illusion
    #  $illusion[battlerindex] = pkmn
    #  tempillusion = true
    #  $illusionnames = [] if !$illusionnames
    #  $illusionnames[battlerindex] = $illusionpoke.name # if $illusionnames[battlerindex] == nil

  #  @battle.battlers[battlerindex].name = $illusionpoke.name
    #end
 #   Kernel.pbMessage(_INTL("hey {1}",$illusionpoke.name))
    #@sprites["pokemon#{battlerindex}"].setPokemonBitmap($illusionpoke,false) if tempillusion
    @sprites["pokemon#{battlerindex}"].setPokemonBitmap(pkmn,false) #if !tempillusion
    if illusionpoke
      @sprites["pokemon#{battlerindex}"].setPokemonBitmap(illusionpoke,false)
    end
    sendout=PokeballSendOutAnimation.new(@sprites["pokemon#{battlerindex}"],
    @sprites,@battle.battlers[battlerindex],@battle.doublebattle,illusionpoke)
    loop do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(nil)

      fadeanim.update if fadeanim
      frame+=1    
      if frame==1
        @sprites["battler#{battlerindex}"].appear
      end
      if frame>=10
        sendout.update
      end
      @sprites["battler#{battlerindex}"].update
      break if (!fadeanim || fadeanim.animdone?) && sendout.animdone? &&
         !@sprites["battler#{battlerindex}"].appearing
    end
    if @battle.battlers[battlerindex].isShiny?
    #if @battle.battlers[battlerindex].pokemon.isShiny?
      pbCommonAnimation("Shiny",@battle.battlers[battlerindex],nil)
    end
    if @battle.battlers[battlerindex].pokemon.ballcapsule0
              pbMoveAnimation("FireSeal",@battle.battlers[battleindex],nil)
            end
            if @battle.battlers[battlerindex].pokemon.ballcapsule1
              pbMoveAnimation("HeartSeal",@battle.battlers[battleindex],nil)
            end
            if @battle.battlers[battlerindex].pokemon.ballcapsule2
              pbMoveAnimation("EleSeal",@battle.battlers[battleindex],nil)
            end
            if @battle.battlers[battlerindex].pokemon.ballcapsule3
              pbMoveAnimation("QuesSeal",@battle.battlers[battleindex],nil)
            end
    sendout.dispose
    if @showingenemy
      @showingenemy=false
      pbDisposeSprite(@sprites,"trainer")
      pbDisposeSprite(@sprites,"partybase1")
      for i in 0...6
        pbDisposeSprite(@sprites,"enemy#{i}")
      end
    end

    pbRefresh
    
  end

  def pbSendOut(battlerindex,pkmn,boolean=false) # Player sending out Pokémon
    while inPartyAnimation?; end
    illusionpoke=@battle.battlers[battlerindex].effects[PBEffects::Illusion]
    balltype=pkmn.ballused
    balltype=illusionpoke.ballused if illusionpoke
    ballbitmap=sprintf("Graphics/Pictures/ball%02d",balltype)
    pictureBall=PictureEx.new(0)
    delay=1
    pictureBall.moveVisible(delay,true)
    pictureBall.moveName(delay,ballbitmap)
    pictureBall.moveOrigin(delay,PictureOrigin::Center)
    # Setting the ball's movement path
    path=[[0,   146], [10,  134], [21,  122], [30,  112], 
          [39,  104], [46,   99], [53,   95], [61,   93], 
          [68,   93], [75,   96], [82,  102], [89,  111], 
          [94,  121], [100, 134], [106, 150], [111, 166], 
          [116, 183], [120, 199], [124, 216], [127, 238]]
    spriteBall=IconSprite.new(0,0,@viewport)
    spriteBall.visible=false
    angle=0
    multiplier=1.0
    if @battle.doublebattle
      multiplier=(battlerindex==0) ? 0.7 : 1.3
    end
    for coord in path
      delay=pictureBall.totalDuration
      pictureBall.moveAngle(0,delay,angle)
      pictureBall.moveXY(1,delay,coord[0]*multiplier,coord[1])
      angle+=40
      angle%=360
    end
    pictureBall.adjustPosition(0,@traineryoffset)
    @sprites["battler#{battlerindex}"].visible=false
    @briefmessage=false
    fadeanim=nil
    if @showingplayer
      fadeanim=PlayerFadeAnimation.new(@sprites)
    end
    frame=0
      #tempillusion = false

    #if isConst?(pkmn.ability,PBAbilities,:ILLUSION) && !boolean
    #  $illusion = Array.new if !$illusion
    #  $illusion[battlerindex] = pkmn
    #  tempillusion = true
    #  $illusionnames = [] if !$illusionnames
    #  $illusionnames[battlerindex] = $illusionpoke.name if $illusionnames[battlerindex]==nil

    #end
 #   Kernel.pbMessage(_INTL("hey {1}",$illusionpoke.name))

    #@sprites["pokemon#{battlerindex}"].setPokemonBitmap($illusionpoke,true) if tempillusion
    @sprites["pokemon#{battlerindex}"].setPokemonBitmap(pkmn,true) #if !tempillusion
    if illusionpoke
      @sprites["pokemon#{battlerindex}"].setPokemonBitmap(illusionpoke,true)
    end
   # @sprites["pokemon#{battlerindex}"].setPokemonBitmap(pkmn,true)
    @battlerindex=battlerindex
    sendout=PokeballPlayerSendOutAnimation.new(@sprites["pokemon#{battlerindex}"],
       @sprites,@battle.battlers[battlerindex],@battle.doublebattle,illusionpoke)
    loop do
      fadeanim.update if fadeanim
      frame+=1
      if frame>1 && !pictureBall.running? && !@sprites["battler#{battlerindex}"].appearing
        @sprites["battler#{battlerindex}"].appear
      end
      if frame>=3 && !pictureBall.running?
        sendout.update
      end
      if (frame>=10 || !fadeanim) && pictureBall.running?
        pictureBall.update
        setPictureIconSprite(spriteBall,pictureBall)
      end
      @sprites["battler#{battlerindex}"].update
      pbGraphicsUpdate
#              pbFrameUpdate(nil)

      pbInputUpdate
      break if (!fadeanim || fadeanim.animdone?) && sendout.animdone? &&
         !@sprites["battler#{battlerindex}"].appearing
    end
    spriteBall.dispose
    sendout.dispose
    if @battle.battlers[battlerindex].isShiny?
    #if @battle.battlers[battlerindex].pokemon.isShiny?
      pbCommonAnimation("Shiny",@battle.battlers[battlerindex],nil)
    end
    if @battle.battlers[battlerindex].pokemon.ballcapsule0
      pbMoveAnimation("FireSeal",@battle.battlers[battlerindex],nil)
    end
    if @battle.battlers[battlerindex].pokemon.ballcapsule1
      pbMoveAnimation("HeartSeal",@battle.battlers[battlerindex],nil)
    end
    if @battle.battlers[battlerindex].pokemon.ballcapsule2
      pbMoveAnimation("EleSeal",@battle.battlers[battlerindex],nil)
    end
    if @battle.battlers[battlerindex].pokemon.ballcapsule3
      pbMoveAnimation("QuesSeal",@battle.battlers[battlerindex],nil)
    end

    if @showingplayer
      @showingplayer=false
      pbDisposeSprite(@sprites,"player")
      pbDisposeSprite(@sprites,"partybase2")
      for i in 0...6
        pbDisposeSprite(@sprites,"player#{i}")
      end
    end
    pbRefresh

  end

  def pbTrainerWithdraw(battle,pkmn)
    pbRefresh
  end

  def pbWithdraw(battle,pkmn)
    pbRefresh
  end

# Called whenever a Pokémon should forget a move.  It should return -1 if the
# selection is canceled, or 0 to 3 to indicate the move to forget.  The function
# should not allow HM moves to be forgotten.
  def pbForgetMove(pokemon,moveToLearn)
    ret=-1
    pbFadeOutIn(99999){
       scene=PokemonSummaryScene.new
       screen=PokemonSummary.new(scene)
       ret=screen.pbStartForgetScreen([pokemon],0,moveToLearn)
    }
    return ret
  end

  def pbBeginAttackPhase
    pbSelectBattler(-1)
  end

  def pbSafariStart
    @briefmessage=false
    @sprites["battler0"]=SafariDataBox.new(@battle,@viewport)
    @sprites["battler0"].appear
    loop do
      @sprites["battler0"].update
      pbGraphicsUpdate
              pbFrameUpdate(nil)

      pbInputUpdate
      break if !@sprites["battler0"].appearing
    end
    pbRefresh
  end

  def pbCommandMenuEx(index,texts,mode=0) # Mode: 0 - regular battle
    pbShowWindow(COMMANDBOX)              #       1 - Shadow Pokémon battle
    cw2=@sprites["commandwindow"]         #       2 - Safari Zone
    cw2.setTexts(texts)                   #       3 - Bug Catching Contest
    if $isitnil == nil
      cw2.index=[0,2,1,3][@lastcmd[index]] if @lastcmd[index]
      cw2.index=[0,2,1,3][0] if @lastcmd[index]==1
      $isitnil=nil
    end
    cw2.mode=mode
    pbSelectBattler(index)
    pbRefresh
    loop do
#      $network.updatelistenarray if $network != nil
      pbGraphicsUpdate
 #             pbFrameUpdate(nil)

      pbInputUpdate
      pbFrameUpdate(cw2)
      # Update selected command
      if Input.trigger?(Input::LEFT) && (cw2.index&1)==1
        pbPlayCursorSE()
        cw2.index=2
      elsif Input.trigger?(Input::RIGHT) && (cw2.index&1)==0
        cw2.index=1
      elsif Input.trigger?(Input::UP) && (cw2.index&2)==2
        pbPlayCursorSE()
        cw2.index-=2
      elsif Input.trigger?(Input::DOWN) && (cw2.index&2)==0
        pbPlayCursorSE()
        cw2.index+=2
      end
      if Input.trigger?(Input::C)
        ret=[0,2,1,3][cw2.index]
        pbPlayDecisionSE()
        @lastcmd[index]=ret
        return ret
      elsif Input.trigger?(Input::B) && index==2 && @lastcmd[0]!=2
        pbPlayDecisionSE()
        return -1
      end
      #nextindex=pbNextIndex(cw2.index)
      #if cw2.index!=nextindex
      #  pbPlayCursorSE()
      #  cw2.index=nextindex
      #end
    end 
  end

  def pbSafariCommandMenu(index)
    pbCommandMenuEx(index,[
       _INTL("What will\n{1} throw?",@battle.pbPlayer.name),
       _INTL("Ball"),
       _INTL("Rock"),
       _INTL("Bait"),
       _INTL("Run")
    ],2)
  end

  def pbCommandMenu(index)
    # Use this method to display the list of commands.
    #  Return values:
    #  0 - Fight
    #  1 - Pokémon
    #  2 - Bag
    #  3 - Run
    shadowTrainer=(@battle.battlers[index].inHyperMode? && @battle.opponent)
    ret=pbCommandMenuEx(index,[
       _INTL("What will\n{1} do?",@battle.battlers[index].name),
       _INTL("Fight"),
       _INTL("Pokémon"),
       _INTL("Bag"),
       shadowTrainer ? _INTL("Call") : _INTL("Run")
    ],(shadowTrainer ? 1 : 0))
    if ret==3 && shadowTrainer
      ret=4 # convert "Run" to "Call"
    end
    return ret
  end

  def pbMoveString(move)
    ret=_INTL("{1}",move.name)
    typename=PBTypes.getName(move.type)
    if move.id>0
      ret+=_INTL(" ({1}) PP: {2}/{3}",typename,move.pp,move.totalpp)
    end
    return ret
  end

  def pbNameEntry(helptext)
    return pbEnterText(helptext,0,11)
  end

# Use this method to display the list of moves for a Pokémon
  def pbFightMenu(index)
    if index==0
      $tempDoubleMega=nil
      $mega_battlers[0]=false
    end
    pbShowWindow(FIGHTBOX)
    cw = @sprites["fightwindow"]
    battler=@battle.battlers[index]
    cw.battler=battler
    lastIndex=@lastmove[index]
    if battler.moves[lastIndex].id!=0
      cw.setIndex(lastIndex)
    else
      cw.setIndex(0)
    end
    cw.megaButton=0
    i = index
    canMega3 = false
#   if Kernel.pbGetMegaSpeciesList.include?(@battle.battlers[i].species) && Kernel.pbGetMegaStoneList.include?(@battle.battlers[i].item)
#   if Kernel.pbGetMegaStoneList.index(@battle.battlers[i].item)==Kernel.pbGetMegaSpeciesList.index(@battle.battlers[i].species)
    canMega3=true if Kernel.pbGetMegaSpeciesStoneWorks(@battle.battlers[i].pokemon.species,@battle.battlers[i].item)
#   else
        
#   end
#   end
    if @battle.battlers[i].species==PBSpecies::RAYQUAZA
      rayq=false
      canMega3=true if @battle.battlers[i].moves[0].id==PBMoves::DRAGONSASCENT
      canMega3=true if @battle.battlers[i].moves[1].id==PBMoves::DRAGONSASCENT
      canMega3=true if @battle.battlers[i].moves[2].id==PBMoves::DRAGONSASCENT
      canMega3=true if @battle.battlers[i].moves[3].id==PBMoves::DRAGONSASCENT
    end
      
    canMega2 = canMega3
    if @battle.player.kind_of?(Array)   
      canMega=$game_switches[64] && (canMega2 && !@battle.player[0].megaforme &&
        (@battle.battlers[i].form==0 || 
        (isConst?(@battle.battlers[i].species,PBSpecies,:GARDEVOIR) && @battle.battlers[i].form==2) || 
        (isConst?(@battle.battlers[i].species,PBSpecies,:LUCARIO) && @battle.battlers[i].form==2) || 
        (isConst?(@battle.battlers[i].species,PBSpecies,:MEWTWO) && @battle.battlers[i].form==4 && !isConst?(@battle.battlers[i].item,PBItems,:MEWTWONITEY))))
    else
      canMega=$game_switches[64] && $tempDoubleMega==nil && (canMega2 && 
        !@battle.player.megaforme && (@battle.battlers[i].form==0 || 
        (isConst?(@battle.battlers[i].species,PBSpecies,:GARDEVOIR) && 
        @battle.battlers[i].form==2) || (isConst?(@battle.battlers[i].species,PBSpecies,:LUCARIO) && 
        @battle.battlers[i].form==2) || (isConst?(@battle.battlers[i].species,PBSpecies,:MEWTWO) && 
        @battle.battlers[i].form==4 && !isConst?(@battle.battlers[i].item,PBItems,:MEWTWONITEY))))
    end
    cw.megaButton=1 if canMega                

    pbSelectBattler(index)
    pbRefresh

    loop do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT) && (cw.index&1)==1
        pbPlayCursorSE() if cw.setIndex(cw.index-1)
      elsif Input.trigger?(Input::RIGHT) &&  (cw.index&1)==0
        pbPlayCursorSE() if cw.setIndex(cw.index+1)
      elsif Input.trigger?(Input::UP) &&  (cw.index&2)==2
        pbPlayCursorSE() if cw.setIndex(cw.index-2)
      elsif Input.trigger?(Input::DOWN) &&  (cw.index&2)==0
        pbPlayCursorSE() if cw.setIndex(cw.index+2)
      end
      if Input.trigger?(Input::B) # Cancel fight menu
        @lastmove[index]=cw.index
        pbPlayCancelSE()
        return -1
      end
      if Input.trigger?(Input::C)# Confirm choice
        ret=cw.index
        pbPlayDecisionSE() 
        @lastmove[index]=ret
        return ret
      end
      if Input.trigger?(Input::A)   # Use Mega Evolution
        if cw.megaButton < 2
          $mega_battlers = Array.new if !$mega_battlers
          $mega_battlers[i] = true if canMega
          $tempDoubleMega=true
          cw.megaButton=2 if canMega
          pbPlayDecisionSE() if canMega
        else
          $mega_battlers = Array.new if !$mega_battlers
          $mega_battlers[i] = false
          $tempDoubleMega=false
          cw.megaButton=1
          pbPlayDecisionSE()
        end
      end
      

      #nextindex=pbNextIndex(cw.index)
      #if cw.index!=nextindex # Move cursor
      #  pbPlayCursorSE()
      #  cw.setIndex(nextindex)
      #end
    end
  end

# Use this method to display the inventory
# The return value is the item chosen, or 0 if the choice was canceled.
  def pbItemMenu(index)
    #if $game_switches[340]==true
      ret=0
      retindex=-1
      emptyspot=-1
      pkmnid=-1
      endscene=true
      oldsprites=pbFadeOutAndHide(@sprites)
      itemscene=PokemonBag_Scene.new
      itemscene.pbStartScene($PokemonBag)
      loop do
        item=itemscene.pbChooseItem
        break if item==0
        usetype=$ItemData[item][ITEMBATTLEUSE]
        cmdUse=-1
        commands=[]
        if usetype==0
          commands[commands.length]=_INTL("Cancel")
        else
          commands[cmdUse=commands.length]=_INTL("Use")
          commands[commands.length]=_INTL("Cancel")
        end
        itemname=PBItems.getName(item)
        command=itemscene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
        if cmdUse>=0 && command==cmdUse
          if usetype==1 || usetype==3
            modparty=[]
            for i in 0...6
              modparty.push(@battle.party1[@battle.party1order[i]])
            end
=begin            
            party=@battle.pbParty(index)
            inactives=[1,1,1,1,1,1]
            partypos=[]
            switchsprites={}
            #activecmd=0
            #ret=-1
            #pbShowWindow(BLANK)
            #pbSetMessageMode(true)
            # Fade out and hide all sprites
            #visiblesprites=pbFadeOutAndHide(@sprites)
            battler=@battle.battlers[0]
            #activecmd=0 if battler.index==index
            #truebattler=@battle.battlers[0] if battler.index==index
            inactives[battler.pokemonIndex]=0
            partypos[0]=battler.pokemonIndex
            if @battle.doublebattle && !@battle.fullparty1
              battler=@battle.battlers[2]
              #activecmd=1 if battler.index==index
              #truebattler=@battle.battlers[2] if battler.index==index
              inactives[battler.pokemonIndex]=0
              partypos[1]=battler.pokemonIndex
            end
            # Add all non-active Pokémon
            for i in 0...6
              partypos[partypos.length]=i if inactives[i]==1
            end
            modparty=[]
            for i in 0...6
              modparty.push(party[partypos[i]])
            end
            #scene=PokemonScreen_Scene.new
            #@switchscreen=PokemonScreen.new(scene,modparty)
            pkmnlist=PokemonScreen_Scene.new
=end            
            pkmnlist=PokemonScreen_Scene.new
            pkmnscreen=PokemonScreen.new(pkmnlist,modparty)#@battle.party1)
            itemscene.pbEndScene
            pkmnscreen.pbStartScene(_INTL("Use on which Pokémon?"),@battle.doublebattle)
            activecmd=pkmnscreen.pbChoosePokemon
            pkmnid=@battle.party1order[activecmd]
            #pkmnid=pkmnscreen.pbChoosePokemon
            #if pkmnid==-1
            #  ret=0
            #  retindex=-1
            #else
            #party=@battle.party1order
            party=modparty
            embargo=false
            if activecmd>=0 && pkmnid>=0
              for i in 0..3
                if party[pkmnid].personalID==@battle.battlers[i].effects[PBEffects::PID] &&
                   @battle.battlers[i].effects[PBEffects::Embargo]>0
                  embargo=true
                  Kernel.pbMessage(_INTL("Embargo's effect prevents the item's use on {1}!",@battle.battlers[i].pbThis))
                end
              end
            end
            if !embargo
              emptyspot=0 if @battle.doublebattle && @battle.battlers[0].hp<=0
              emptyspot=2 if @battle.doublebattle && @battle.battlers[2].hp<=0
              if activecmd>=0 && pkmnid>=0 && @battle.pbUseItemOnPokemon(item,pkmnid,pkmnscreen)#,party)
                pkmnscreen.pbRefresh
                pkmnlist.pbEndScene
                ret=item
                retindex=pkmnid
                endscene=false
                break
              end
            end
            #end
            pkmnlist.pbEndScene
            itemscene.pbStartScene($PokemonBag)
          elsif usetype==2
            if @battle.pbUseItemOnBattler(item,index,itemscene)
              ret=item
              retindex=index
              break
            end
          end
        end
      end
      pbConsumeItemInBattle($PokemonBag,ret) if ret>0
      itemscene.pbEndScene if endscene
      for i in 0..4
        if @sprites["battler#{i}"]
          @sprites["battler#{i}"].refresh
        end
      end
      pbFadeInAndShow(@sprites,oldsprites)
      if emptyspot>=0 && @battle.battlers[emptyspot].hp>0
        @battle.pbSendOut(emptyspot,$Trainer.party[pkmnid])
      end
      @battle.pbSwitch
      $isitnil="dickfuck"
      return [ret,retindex]
    #end
  end

  def pbSelectBattler(index,selectmode=1)
    numwindows=@battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      sprite=@sprites["battler#{i}"]
      sprite.selected=(i==index) ? selectmode : 0
      sprite=@sprites["pokemon#{i}"]
      sprite.selected=(i==index) ? selectmode : 0
    end
  end

  def pbFirstTarget(index,targettype)
    case targettype
    when PBTargets::SingleNonUser
      for i in 0...4
        if i!=index && !@battle.battlers[i].fainted? && 
           @battle.battlers[index].pbIsOpposing?(i)
          return i
        end  
      end
    when PBTargets::UserOrPartner
      return index
    end
    
    #for i in 0..3
    #  if i!=index && @battle.battlers[i].hp>0 && 
    #     @battle.battlers[index].pbIsOpposing?(i)
    #    return i
    #  end  
    #end
    return -1
  end
=begin
  def pbNextIndex(curindex)
    if Input.trigger?(Input::LEFT) && (curindex&1)==1
      Kernel.pbMessage(_INTL("Left: {1}",curindex&1))
      return curindex-1
    elsif Input.trigger?(Input::RIGHT) &&  (curindex&1)==0
      Kernel.pbMessage(_INTL("Right: {1}",curindex&1))
      return curindex+1
    elsif Input.trigger?(Input::UP) &&  (curindex&2)==2
      Kernel.pbMessage(_INTL("Up: {1}",curindex&1))
      return curindex-2
    elsif Input.trigger?(Input::DOWN) &&  (curindex&2)==0
      Kernel.pbMessage(_INTL("Down: {1}",curindex&1))
      return curindex+2
    end
    return curindex
  end
=end
  def pbUpdateSelected(index)
    numwindows=@battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      if i==index
        @sprites["battler#{i}"].selected=2
        @sprites["pokemon#{i}"].selected=2
      else
        @sprites["battler#{i}"].selected=0
        @sprites["pokemon#{i}"].selected=0
      end
      @sprites["battler#{i}"].update
      @sprites["pokemon#{i}"].update
    end
  end

# Use this method to make the player choose a target 
# for certain moves in double battles.
  def pbChooseTarget(index,targettype)
    pbShowWindow(FIGHTBOX)
    cw = @sprites["fightwindow"]
    battler=@battle.battlers[index]
    cw.battler=battler
    lastIndex=@lastmove[index]
    if battler.moves[lastIndex].id!=0
      cw.setIndex(lastIndex)
    else
      cw.setIndex(0)
    end
    curwindow=pbFirstTarget(index,targettype)
    if curwindow==-1
      raise RuntimeError.new(_INTL("No targets somehow..."))
    end
    loop do
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(nil)

      pbUpdateSelected(curwindow)
      if Input.trigger?(Input::C)
        pbUpdateSelected(-1)
        return curwindow
      end
      if Input.trigger?(Input::B)
        pbUpdateSelected(-1)
        return -1
      end
      if curwindow>=0
        if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::DOWN)
          loop do
            case targettype
            when PBTargets::SingleNonUser
              case curwindow
              when 0; newcurwindow=2
              when 1; newcurwindow=0
              when 2; newcurwindow=3
              when 3; newcurwindow=1
              end
            when PBTargets::UserOrPartner
              newcurwindow=(curwindow+2)%4
            end
            curwindow=newcurwindow
            next if targettype==PBTargets::SingleNonUser && curwindow==index
            break if !@battle.battlers[curwindow].fainted?
            
            #newcurwindow=3 if curwindow==0
            #newcurwindow=1 if curwindow==3
            #newcurwindow=2 if curwindow==1
            #newcurwindow=0 if curwindow==2
            #curwindow=newcurwindow
            #next if curwindow==index
            #break if @battle.battlers[curwindow].hp>0
          end
        elsif Input.trigger?(Input::LEFT) || Input.trigger?(Input::UP)
          loop do 
            case targettype
            when PBTargets::SingleNonUser
              case curwindow
              when 0; newcurwindow=1
              when 1; newcurwindow=3
              when 2; newcurwindow=0
              when 3; newcurwindow=2
              end
            when PBTargets::UserOrPartner
              newcurwindow=(curwindow+2)%4
            end
            curwindow=newcurwindow
            next if targettype==PBTargets::SingleNonUser && curwindow==index
            break if !@battle.battlers[curwindow].fainted?
            
            #newcurwindow=2 if curwindow==0
            #newcurwindow=1 if curwindow==2
            #newcurwindow=3 if curwindow==1
            #newcurwindow=0 if curwindow==3
            #curwindow=newcurwindow
            #next if curwindow==index
            #break if @battle.battlers[curwindow].hp>0
          end
        end
      end
    end
  end

  def pbSwitch(index,lax,cancancel)
    
    party=@battle.pbParty(index)
    inactives=[1,1,1,1,1,1]
    #partypos=[]
    partypos=@battle.party1order
    switchsprites={}
    activecmd=0
    ret=-1
    # Fade out and hide all sprites
    pbShowWindow(BLANK)
    pbSetMessageMode(true)
    visiblesprites=pbFadeOutAndHide(@sprites)
    modparty=[]
    for i in 0...6
      modparty.push(party[partypos[i]])
    end
    
    battler=@battle.battlers[0]
    #activecmd=0 if battler.index==index
    truebattler=@battle.battlers[0] if battler.index==index
    #inactives[battler.pokemonIndex]=0
    #partypos[0]=battler.pokemonIndex
    if @battle.doublebattle && !@battle.fullparty1
      battler=@battle.battlers[2]
      #activecmd=1 if battler.index==index
      truebattler=@battle.battlers[2] if battler.index==index
      #inactives[battler.pokemonIndex]=0
      #partypos[1]=battler.pokemonIndex
    end
    # Add all non-active Pokémon
    #for i in 0...6
    #  partypos[partypos.length]=i if inactives[i]==1
    #end
    #modparty=[]
    #for i in 0...6
    #  modparty.push(party[partypos[i]])
    #end
    scene=PokemonScreen_Scene.new
    @switchscreen=PokemonScreen.new(scene,modparty)
    @switchscreen.pbStartScene(_INTL("Choose a Pokémon."),
      @battle.doublebattle && !@battle.fullparty1)
    loop do
      scene.pbSetHelpText(_INTL("Choose a Pokémon."))
      activecmd=@switchscreen.pbChoosePokemon
      if cancancel && activecmd==-1
        ret=-1
        break
      end
      if activecmd>=0
        commands=[]
        cmdShift=-1
        cmdSummary=-1
        pkmnindex=partypos[activecmd]
        commands[cmdShift=commands.length]=_INTL("Switch In") if !party[pkmnindex].egg?
        commands[cmdSummary=commands.length]=_INTL("Summary")
        commands[commands.length]=_INTL("Cancel")
        command=scene.pbShowCommands(_INTL("Do what with {1}?",party[pkmnindex].name),commands)
        if cmdShift>=0 && command==cmdShift
          canswitch=lax ? @battle.pbCanSwitchLax?(index,pkmnindex,true) :
             @battle.pbCanSwitch?(index,pkmnindex,true)
          if canswitch
            ret=pkmnindex
            #if truebattler.ability==PBAbilities::PROTEAN
            if [PBSpecies::KECLEON,PBSpecies::FROAKIE,PBSpecies::FROGADIER,PBSpecies::GRENINJA].include?(truebattler.species)
              truebattler.form=0
            elsif truebattler.species==PBSpecies::DELTADITTO
              truebattler.form=11
            elsif truebattler.species==PBSpecies::ARCEUS && truebattler.form!=19 &&
              truebattler.ability!=PBAbilities::MULTITYPE
              truebattler.form=0
            end
            break
          end
        elsif cmdSummary>=0 && command==cmdSummary
          scene.pbSummary(activecmd)
        end
      end
    end
    @switchscreen.pbEndScene
    @switchscreen=nil
    pbSetMessageMode(false)
    # back to main battle screen
    pbFadeInAndShow(@sprites,visiblesprites)
    return ret
  end

  def pbDamageAnimation(pkmn,effectiveness,isCrit=false)
        Kernel.pbPushRecent("32.5.1")

    pkmnsprite=@sprites["pokemon#{pkmn.index}"]
    shadowsprite=@sprites["shadow#{pkmn.index}"]
    sprite=@sprites["battler#{pkmn.index}"]
    oldshadowvisible=shadowsprite.visible
    oldvisible=sprite.visible
    sprite.selected=2
         Kernel.pbPushRecent("32.5.2")
   @briefmessage=false
    6.times do
      pbGraphicsUpdate
      pbInputUpdate
            pbFrameUpdate(nil)

    end
    case effectiveness
      when 0
        pbSEPlay("normaldamage")
      when 1
        pbSEPlay("notverydamage")
      when 2
        pbSEPlay("superdamage")
      when 3
        pbSEPlay("ultradamage")
        
      end
      pbSEPlay("crithit") if isCrit
         Kernel.pbPushRecent("32.5.3")
   8.times do
      pkmnsprite.visible=!pkmnsprite.visible
      if oldshadowvisible
        shadowsprite.visible=!shadowsprite.visible
      end
      4.times do
        pbGraphicsUpdate
        pbInputUpdate
       pbFrameUpdate(nil)

        sprite.update
      end
    end
         Kernel.pbPushRecent("32.5.4")
   sprite.selected=0
    sprite.visible=oldvisible
  end

# This method is called whenever a Pokémon's HP changes.
# Used to animate the HP bar.
  def pbHPChanged(pkmn,oldhp)
    Kernel.pbPushRecent("32.6.1")
    @briefmessage=false
    hpchange=pkmn.hp-oldhp
    Kernel.pbPushRecent("32.6.2")
    if hpchange<0
      hpchange=-hpchange
      PBDebug.log("[#{pkmn.pbThis} lost #{hpchange} HP, now has #{pkmn.hp} HP]") if @battle.debug
    else
      PBDebug.log("[#{pkmn.pbThis} gained #{hpchange} HP, now has #{pkmn.hp} HP]") if @battle.debug
    end
    Kernel.pbPushRecent("32.6.3")
    sprite=@sprites["battler#{pkmn.index}"]
    Kernel.pbPushRecent("32.6.4")
    sprite.animateHP(oldhp,pkmn.hp)
    Kernel.pbPushRecent("32.6.5")
    while sprite.animatingHP
      pbGraphicsUpdate
      pbInputUpdate
      pbFrameUpdate(nil)
      sprite.update
    end
    Kernel.pbPushRecent("32.6.6")
 end

# This method is called whenever a Pokémon faints.
  def pbFainted(pkmn)
    return if pkmn.hp>0
#            @battle.pbDisplayPaused("HP: "+pkmn.hp.to_s)
    frames=pbCryFrameLength(pkmn.pokemon)
    pbPlayCry(pkmn.pokemon)
    frames.times do
      pbGraphicsUpdate
      pbInputUpdate
              pbFrameUpdate(nil)

        end
 #           @battle.pbDisplayPaused("checked1")
    @sprites["shadow#{pkmn.index}"].visible=false
  #          @battle.pbDisplayPaused("checked1.0.1")
    pkmnsprite=@sprites["pokemon#{pkmn.index}"]
   #             @battle.pbDisplayPaused("checked1.0.2")

    pkmnsprite.visible=false
    #        @battle.pbDisplayPaused("checked1.1")
    if @battle.pbIsOpposing?(pkmn.index)
     #       @battle.pbDisplayPaused("checked1.2")
      ycoord=(@sprites["battler0"].visible && @battle.doublebattle) ? 118 : 130
      #       @battle.pbDisplayPaused("checked1.3")
     tempvp=Viewport.new(0,0,Graphics.width,ycoord+@foeyoffset)
    else
       #      @battle.pbDisplayPaused("checked1.4")
     tempvp=Viewport.new(0,0,Graphics.width,224+@traineryoffset)
    end
        #    @battle.pbDisplayPaused("checked2")
   tempvp.z=@viewport.z
    tempsprite=SpriteWrapper.new(tempvp)
    tempsprite.x=pkmnsprite.x
    tempsprite.y=pkmnsprite.y
    tempsprite.bitmap=pkmnsprite.bitmap
    tempsprite.visible=true
    pbSEPlay("faint")
     #           @battle.pbDisplayPaused("checked3")

    20.times do
      tempsprite.y+=8
      pbGraphicsUpdate
      pbInputUpdate
              pbFrameUpdate(nil)

    end
    tempsprite.dispose
    tempvp.dispose
    8.times do
      @sprites["battler#{pkmn.index}"].opacity-=32
      pbGraphicsUpdate
      pbInputUpdate
              pbFrameUpdate(nil)

            end
            #            @battle.pbDisplayPaused("checked4")

    @sprites["battler#{pkmn.index}"].visible=false
    pkmn.pbResetForm
  end

# Use this method to choose a command for the enemy.
  def pbChooseEnemyCommand(index)
    begin
    @battle.pbDefaultChooseEnemyCommand(index)
      rescue
    end

  end
  def pbCloning
#      if $game_switches[90]
#      if @battle.opponent.trainertype = 0 || @battle.opponent.trainertype = 1
#      @battle.party2[0] = $Trainer.pokemonParty[0]
#      @battle.party2[1] = $Trainer.pokemonParty[1]
#      @battle.party2[2] = $Trainer.pokemonParty[2]
#      @battle.party2[3] = $Trainer.pokemonParty[3]
#      @battle.party2[4] = $Trainer.pokemonParty[4]
#      @battle.party2[5] = $Trainer.pokemonParty[5]
#      end


 #   end
  end
  
    
# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party) #boobies
      @battle.pbDefaultChooseNewEnemy(index,party)
  end

# This method is called when the player wins a wild Pokémon battle.
# This method can change the battle's music for example.
  def pbWildBattleSuccess
    pbBGMPlay(pbGetWildVictoryME())
  end

# This method is called when the player wins a Trainer battle.
# This method can change the battle's music for example.
  def pbTrainerBattleSuccess
    pbBGMPlay(pbGetTrainerVictoryME(@battle.opponent))
  end

  def pbEXPBar(pokemon,battler,startexp,endexp,tempexp1,tempexp2)
    if battler
      @sprites["battler#{battler.index}"].refreshExpLevel
      exprange=(endexp-startexp)
      startexplevel=0
      endexplevel=0
      if exprange!=0
        startexplevel=(tempexp1-startexp)*EXPGAUGESIZE/exprange
        endexplevel=(tempexp2-startexp)*EXPGAUGESIZE/exprange
      end
      @sprites["battler#{battler.index}"].animateEXP(startexplevel,endexplevel)
      while @sprites["battler#{battler.index}"].animatingEXP
        pbGraphicsUpdate
        pbInputUpdate
                pbFrameUpdate(nil)

        @sprites["battler#{battler.index}"].update
      end
    end
  end

  def pbShowPokedex(species)
    pbFadeOutIn(99999){
       scene=PokemonPokedexScene.new
       screen=PokemonPokedex.new(scene)
       screen.pbDexEntry(species)
    }
  end

  def pbChangePokemon(attacker,pokemon,substitute=false,delta=nil)
    pkmn=@sprites["pokemon#{attacker.index}"]
    shadow=@sprites["shadow#{attacker.index}"]
    back=!@battle.pbIsOpposing?(attacker.index)
    if delta==nil
      pkmn.setPokemonBitmap(pokemon,back,substitute)
    else
      pkmn.setPokemonBitmapSpecies(pokemon,delta,back)
    end
    pkmn.y=adjustBattleSpriteY(pkmn,pokemon.species,attacker.index)
    if shadow && !back
      shadow.visible=showShadow?(pokemon.species)
    end
  end
  
  def pbChangePokemon(attacker,pokemon,substitute=false,delta=nil,mega=false,brokeIllusion=false)
    pkmn=@sprites["pokemon#{attacker.index}"]
    shadow=@sprites["shadow#{attacker.index}"]
    back=!@battle.pbIsOpposing?(attacker.index)
    
    if delta==nil
      pkmn.setPokemonBitmap(pokemon,back,substitute)
    else
      pkmn.setPokemonBitmapSpecies(pokemon,delta,back)
    end
    pkmn.x -= 64 if @battle.pbIsOpposing?(attacker.index) && isConst?(pokemon.species,PBSpecies,:MAGMORTAR)
    pkmn.x += 64 if !@battle.pbIsOpposing?(attacker.index) && brokeIllusion
    pkmn.x -= 64 if !@battle.pbIsOpposing?(attacker.index) && mega &&
                    isConst?(pokemon.species,PBSpecies,:CHARIZARD)
    pkmn.x -= 64 if !@battle.pbIsOpposing?(attacker.index) && mega &&
                    isConst?(pokemon.species,PBSpecies,:VENUSAUR)

    pkmn.y=adjustBattleSpriteY(pkmn,pokemon.species,attacker.index)
    if shadow && !back
      shadow.visible=showShadow?(pokemon.species)
    end
  end

  def pbSaveShadows
    shadows=[]
    for i in 0...4
      s=@sprites["shadow#{i}"]
      shadows[i]=s ? s.visible : false
      s.visible=false if s
    end
    yield
    for i in 0...4
      s=@sprites["shadow#{i}"]
      s.visible=shadows[i] if s
    end
  end

  def pbFindAnimation(moveid,userIndex)
    begin
      move2anim=load_data("Data/move2anim.dat")
      noflip=false
      if userIndex==0 || userIndex==2 # On player's side
        anim=move2anim[0][moveid]
      else                            # On opposing side
        anim=move2anim[1][moveid]
        noflip=true if anim
        anim=move2anim[0][moveid] if !anim
      end
      return [anim,noflip] if anim
      if hasConst?(PBMoves,:TACKLE)
        anim=move2anim[0][getConst(PBMoves,:TACKLE)]
        return [anim,false] if anim
      end
      rescue
      return nil
    end
    return nil
  end

  def pbCommonAnimation(animname,user,target,side=true)
    animations=load_data("Data/PkmnAnimations.rxdata")
    for i in 0...animations.length
      if animations[i] && animations[i].name=="Common:"+animname
        pbAnimationCore(animations[i],user,(target!=nil) ? target : user)
        return
      end
    end
  end
  
  def pbMoveAnimation(animname,attacker,opponent,side=true)
    animations=load_data("Data/PkmnAnimations.rxdata")
    for i in 0...animations.length
      if animations[i] && animations[i].name=="Common:"+animname

        pbAnimationCore(animations[i],attacker,opponent,side)
        return
      end

    end
  end

  def pbAnimation(moveid,attacker,opponent,side=true,delta=nil)
    Kernel.pbPushRecent("10")
    ismove=moveid
    Kernel.pbPushRecent("11")

    #     battlebg="Graphics/Battlebacks/battlebgCave"
    # pbAddSprite("movebg",0,0,movebg,@viewport)
    # @sprites["movebg"].z=-1 # For compatibility with RGSS2

    animid=pbFindAnimation(moveid,attacker.index)
    Kernel.pbPushRecent("12")
    return if !animid
    Kernel.pbPushRecent("13")

    anim=animid[0]
    Kernel.pbPushRecent("14")
    #       if isConst?(moveid,PBMoves,:TRANSFORM) && attacker && opponent && attacker.effects[PBEffects::Illusion] != nil && attacker.effects[PBEffects::Illusion] != 0
    #      # Change form to transformed version
    #      pbChangePokemon(attacker,opponent)
    #      return
    #    end
    if isConst?(moveid,PBMoves,:TRANSFORM) && attacker && opponent
      # Change form to transformed version
      pbChangePokemon(attacker,opponent.pokemon)
    end
    if isConst?(moveid,PBMoves,:MORPH) && attacker && opponent
      # Change form to transformed version
      pbChangePokemon(attacker,opponent.pokemon,false,delta)
    end
    Kernel.pbPushRecent("15")

    animations=load_data("Data/PkmnAnimations.rxdata")
    Kernel.pbPushRecent("16")

    #    @sprites["battlebg"]="Graphics/Battlebacks/battlebgCave"
    #    @sprites["battlebg"].update
    pbSaveShadows {
      if animid[1] # On opposing side and using OppMove animation
        pbAnimationCore(animations[anim],opponent,attacker,side,ismove,false)
      else         # On player's side, and/or using Move animation
        pbAnimationCore(animations[anim],attacker,opponent,side,ismove,true)
      end
    }
  end

  def pbAnimationCore(animation,attacker,opponent,side=true,moveid=-1,playerside=true)
    Kernel.pbPushRecent("17")
    tempvar=pbBackdropMove(moveid,playerside) if moveid > -1
    Kernel.pbPushRecent("18")
    no_attacker_temp = false
    Kernel.pbPushRecent("19")
    if !attacker
      attacker = @battle.battlers[0]
      opponent = @battle.battlers[1]
      no_attacker_temp = true
    end
    Kernel.pbPushRecent("21")
    if !animation || !attacker
      return
    end
    Kernel.pbPushRecent("22")
    @briefmessage=false
    if attacker.fainted?
      no_attacker_temp = true
    end
    user=(attacker) ? @sprites["pokemon#{attacker.index}"] : nil
    target=(opponent) ? @sprites["pokemon#{opponent.index}"] : nil
    olduserx=user.x
    oldusery=user.y
    oldtargetx=target ? target.x : 0
    oldtargety=target ? target.y : 0
    Kernel.pbPushRecent("23")

    if no_attacker_temp
      return    
      animplayer=PBAnimationPlayer.new(animation,user,target,@viewport)
      #            animplayer=PBAnimationPlayer.new(animation,user,user,@viewport)
    elsif !target
      Kernel.pbPushRecent("24")
      animplayer=PBAnimationPlayer.new(animation,user,user,@viewport)
      userwidth=(!user.bitmap || user.bitmap.disposed?) ? 128 : user.bitmap.width
      #   userwidth *=3 if no_attacker_temp
      userheight=(!user.bitmap || user.bitmap.disposed?) ? 128 : user.bitmap.height
      #   userheight *=3 if no_attacker_temp
      animplayer.setLineTransform(128,224,384,98, # 144,188,352,108
         user.x+(userwidth/2),user.y+(userheight/2),
         user.x+(userwidth/2),user.y+(userheight/2))
      Kernel.pbPushRecent("25")
    else
      Kernel.pbPushRecent("26")
      animplayer=PBAnimationPlayer.new(animation,user,target,@viewport)
      userwidth=(!user.bitmap || user.bitmap.disposed?) ? 128 : user.bitmap.width
      targetwidth=(!target.bitmap || target.bitmap.disposed?) ? 128 : target.bitmap.width
      userheight=(!user.bitmap || user.bitmap.disposed?) ? 128 : user.bitmap.height
      targetheight=(!target.bitmap || target.bitmap.disposed?) ? 128 : target.bitmap.height
      animplayer.setLineTransform(128,224,384,98, # 144,188,352,108
         user.x+(userwidth/2),user.y+(userheight/2),
         target.x+(targetwidth/2),target.y+(targetheight/2))
      Kernel.pbPushRecent("27")
    end
    Kernel.pbPushRecent("28")
    animplayer.start
    Kernel.pbPushRecent("29")

    while animplayer.playing?
      pbFrameUpdate(nil)
      animplayer.update
      pbGraphicsUpdate
      pbInputUpdate
    end
    Kernel.pbPushRecent("30")
      
    user.ox=0
    user.oy=0
    target.ox=0 if target
    target.oy=0 if target
    user.x=olduserx
    user.y=oldusery
    target.x=oldtargetx if target
    target.y=oldtargety if target
    animplayer.dispose
    #  pbBackdrop(true) if moveid > -1 && tempvar
    pbBackdropMove(0) if moveid > -1 && tempvar
    Kernel.pbPushRecent("31")
  end

  def pbLevelUp(pokemon,battler,oldtotalhp,oldattack,olddefense,oldspeed,
                oldspatk,oldspdef)
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
       pokemon.totalhp-oldtotalhp,
       pokemon.attack-oldattack,
       pokemon.defense-olddefense,
       pokemon.spatk-oldspatk,
       pokemon.spdef-oldspdef,
       pokemon.speed-oldspeed))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
  end

  def pbThrowAndDeflect(ball,targetBattler)
  end

  def pbThrow(ball,shakes,targetBattler)
    @briefmessage=false
    pokeballThrow(ball,shakes,targetBattler)
  end

  def pbThrowSuccess
    if !@battle.opponent
      @briefmessage=false
      pbMEPlay("Jingle - HMTM")
      frames=(3.5*Graphics.frame_rate).to_i
      frames.times do
        pbGraphicsUpdate
        pbFrameUpdate(nil)

        pbInputUpdate
      end
    end
  end
end