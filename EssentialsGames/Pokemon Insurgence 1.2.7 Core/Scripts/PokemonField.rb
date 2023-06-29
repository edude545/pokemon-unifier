################################################################################
# Interpolators
################################################################################
class RectInterpolator
  def initialize(oldrect,newrect,frames)
    restart(oldrect,newrect,frames)
  end

  def restart(oldrect,newrect,frames)
    @oldrect=oldrect
    @newrect=newrect
    @frames=[frames,1].max
    @curframe=0
    @rect=oldrect.clone
  end

  def set(rect)
    rect.set(@rect.x,@rect.y,@rect.width,@rect.height)
  end

  def done?
    @curframe>@frames
  end

  def update
    return if done?
    t=(@curframe*1.0/@frames)
    x1=@oldrect.x
    x2=@newrect.x
    x=x1+t*(x2-x1)
    y1=@oldrect.y
    y2=@newrect.y
    y=y1+t*(y2-y1)
    rx1=@oldrect.x+@oldrect.width
    rx2=@newrect.x+@newrect.width
    rx=rx1+t*(rx2-rx1)
    ry1=@oldrect.y+@oldrect.height
    ry2=@newrect.y+@newrect.height
    ry=ry1+t*(ry2-ry1)
    minx=x<rx ? x : rx
    maxx=x>rx ? x : rx
    miny=y<ry ? y : ry
    maxy=y>ry ? y : ry
    @rect.set(minx,miny,maxx-minx,maxy-miny)
    @curframe+=1
  end
end



class PointInterpolator
  def initialize(oldx,oldy,newx,newy,frames)
    restart(oldx,oldy,newx,newy,frames)
  end

  def restart(oldx,oldy,newx,newy,frames)
    @oldx=oldx
    @oldy=oldy
    @newx=newx
    @newy=newy
    @frames=frames
    @curframe=0
    @x=oldx
    @y=oldy
  end

  def x; @x;end
  def y; @y;end

  def done?
    @curframe>@frames
  end

  def update
    return if done?
    t=(@curframe*1.0/@frames)
    rx1=@oldx
    rx2=@newx
    @x=rx1+t*(rx2-rx1)
    ry1=@oldy
    ry2=@newy
    @y=ry1+t*(ry2-ry1)
    @curframe+=1
  end
end



################################################################################
# Visibility circle in dark maps
################################################################################
class DarknessSprite < SpriteWrapper
  attr_reader :radius

  def initialize(viewport=nil)
    super(viewport)
    @darkness=BitmapWrapper.new(Graphics.width,Graphics.height)
    @radius=64
    self.bitmap=@darkness
    self.z=99998
    refresh
  end

  def dispose
    @darkness.dispose
    super
  end

  def radius=(value)
    @radius=value
    refresh
  end

  def refresh
    @darkness.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0,255))
    cx=Graphics.width/2
    cy=Graphics.height/2
    cradius=@radius
    numfades=5
    for i in 1..numfades
      for j in cx-cradius..cx+cradius
        diff2 = (cradius * cradius) - ((j - cx) * (j - cx))
        diff = Math.sqrt(diff2)
        @darkness.fill_rect(j,cy-diff,1,diff*2,
           Color.new(0, 0, 0, 255.0*(numfades-i)/numfades ))
      end
     cradius=(cradius*0.9).floor
    end
  end
end



################################################################################
# Location signpost
################################################################################
class LocationWindow
  def initialize(name)
    @window=Window_AdvancedTextPokemon.new(name)
    @window.resizeToFit(name,Graphics.width)
    @window.x=0
    @window.y=-@window.height
    @window.z=99999
    @currentmap=$game_map.map_id
    @frames=0
  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    if $game_temp.message_window_showing ||
       @currentmap!=$game_map.map_id
      @window.dispose
      return
    end
    if @frames>80
      @window.y-=4
      @window.dispose if @window.y+@window.height<0
    else
      @window.y+=4 if @window.y<0
      @frames+=1
    end
  end
end



################################################################################
# Lights
################################################################################
class LightEffect
  def initialize(event,map=nil)
    @light = IconSprite.new(0,0)
    @light.setBitmap("Graphics/Pictures/LE")
    @light.z = 1000
    @event = event
    @map=map ? map : $game_map
    @disposed=false
  end

  def disposed?
    return @disposed
  end

  def dispose
    @light.dispose
    @map=nil
    @event=nil
    @disposed=true
  end

  def update
    @light.update
  end
end



class LightEffect_Lamp < LightEffect
  def initialize(event,map=nil)
    @light = Sprite.new
    lamp = AnimatedBitmap.new("Graphics/Pictures/LE")
    @light.bitmap = Bitmap.new(128,64)
    src_rect = Rect.new(0, 0, 64, 64) 
    @light.bitmap.blt(0, 0, lamp.bitmap, src_rect) 
    @light.bitmap.blt(20, 0, lamp.bitmap, src_rect) 
    lamp.dispose
    @light.visible = true
    @light.z = 1000
    @map=map ? map : $game_map
    @event = event
  end
end



class LightEffect_Basic < LightEffect
  def initialize(event,map=nil)
    super
  end

  def update
    return if !@light || !@event
    super
    @light.opacity = 100
    @light.ox=32
    @light.oy=48
    if (Object.const_defined?(:ScreenPosHelper) rescue false)
      @light.x = ScreenPosHelper.pbScreenX(@event)
      @light.y = ScreenPosHelper.pbScreenY(@event)
      @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
    else
      @light.x = @event.screen_x
      @light.y = @event.screen_y
      @light.zoom_x = 1.0
    end
    @light.zoom_y = @light.zoom_x
    @light.tone=$game_screen.tone
  end  
end



class LightEffect_DayNight < LightEffect
  def initialize(event,map=nil)
    super
  end

  def update
    return if !@light || !@event
    super
    shade=PBDayNight.getShade
    if shade>=144   # If light enough, call it fully day.
      shade=255
    elsif shade<=64   # If dark enough, call it fully night.
      shade=0
    else
      shade=255-(255*(144-shade)/(144-64))
    end
    @light.opacity = 255-shade
    if @light.opacity>0
      @light.ox=32
      @light.oy=48
      if (Object.const_defined?(:ScreenPosHelper) rescue false)
        @light.x = ScreenPosHelper.pbScreenX(@event)
        @light.y = ScreenPosHelper.pbScreenY(@event)
        @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
        @light.zoom_y = ScreenPosHelper.pbScreenZoomY(@event)
      else
        @light.x = @event.screen_x
        @light.y = @event.screen_y
        @light.zoom_x = 1.0
        @light.zoom_y = 1.0
      end
      @light.tone.set(
         $game_screen.tone.red,
         $game_screen.tone.green,
         $game_screen.tone.blue,
         $game_screen.tone.gray)
    end
  end  
end



################################################################################
# This module stores encounter-modifying events that can happen during the game.
# A procedure can subscribe to an event by adding itself to the event.  It will
# then be called whenever the event occurs.
################################################################################
module EncounterModifier
  @@procs=[]
  @@procsEnd=[]

  def self.register(p)
    @@procs.push(p)
  end

  def self.registerEncounterEnd(p)
    @@procsEnd.push(p)
  end

  def self.trigger(encounter)
    for prc in @@procs
      encounter=prc.call(encounter)
    end
    return encounter
  end

  def self.triggerEncounterEnd()
    for prc in @@procsEnd
      prc.call()
    end
  end
end



################################################################################
# This module stores events that can happen during the game.  A procedure can
# subscribe to an event by adding itself to the event.  It will then be called
# whenever the event occurs.
################################################################################
module Events
  @@OnMapChange=Event.new
  @@OnMapSceneChange=Event.new
  @@OnMapUpdate=Event.new
  @@OnMapChanging=Event.new
  @@OnLeaveTile=Event.new
  @@OnStepTaken=Event.new
  @@OnStepTakenTransferPossible=Event.new
  @@OnStepTakenFieldMovement=Event.new
  @@OnWildBattleOverride=Event.new
  @@OnWildBattleEnd=Event.new
  @@OnWildPokemonCreate=Event.new
  @@OnSpritesetCreate=Event.new
  @@OnStartBattle=Event.new
  @@OnEndBattle=Event.new
  @@OnMapCreate=Event.new
  @@OnAction=Event.new

# Triggers when the player presses the Action button on the map.
  def self.onAction=(v)
    @@OnAction=v
  end

  def self.onAction
    @@OnAction
  end

  def self.onStartBattle=(v)
    @@OnStartBattle=v
  end

  def self.onStartBattle
    @@OnStartBattle
  end

  def self.onEndBattle=(v)
    @@OnEndBattle=v
  end

  def self.onEndBattle
    @@OnEndBattle
  end

# Fires whenever a map is created. Event handler receives two parameters: the
# map (RPG::Map) and the tileset (RPG::Tileset)
  def self.onMapCreate=(v)
    @@OnMapCreate=v
  end

  def self.onMapCreate
    @@OnMapCreate
  end

# Fires whenever the player moves to a new map. Event handler receives the old
# map ID or 0 if none.  Also fires when the first map of the game is loaded
  def self.onMapChange=(v)
    @@OnMapChange=v
  end

  def self.onMapChange
    @@OnMapChange
  end

# Fires whenever one map is about to change to a different one. Event handler
# receives the new map ID and the Game_Map object representing the new map.
# When the event handler is called, $game_map still refers to the old map.
  def self.onMapChanging=(v)
    @@OnMapChanging=v
  end

  def self.onMapChanging
    @@OnMapChanging
  end

# Fires whenever the player takes a step.
  def self.onStepTaken=(v)
    @@OnStepTaken=v
  end

  def self.onStepTaken
    @@OnStepTaken
  end

# Fires whenever the player or another event leaves a tile.
# Parameters:
# e[0] - Event that just left the tile.
# e[1] - Map ID where the tile is located (not necessarily
#  the current map). Use "$MapFactory.getMap(e[1])" to
#  get the Game_Map object corresponding to that map.
# e[2] - X-coordinate of the tile
# e[3] - Y-coordinate of the tile
  def self.onLeaveTile=(v)
    @@OnLeaveTile=v
  end

  def self.onLeaveTile
    @@OnLeaveTile
  end

# Fires whenever the player or another event enters a tile.
# Parameters:
# e[0] - Event that just entered a tile.
  def self.onStepTakenFieldMovement=(v)
    @@OnStepTakenFieldMovement=v
  end

  def self.onStepTakenFieldMovement
    @@OnStepTakenFieldMovement
  end

# Fires whenever the player takes a step. The event handler may possibly move
# the player elsewhere.
# Parameters:
# e[0] = Array that contains a single boolean value.
#  If an event handler moves the player to a new map, it should set this value
# to true. Other event handlers should check this parameter's value.
  def self.onStepTakenTransferPossible=(v)
    @@OnStepTakenTransferPossible=v
  end

  def self.onStepTakenTransferPossible
    @@OnStepTakenTransferPossible
  end

# Fires each frame during a map update.
  def self.onMapUpdate=(v)
    @@OnMapUpdate=v
  end

  def self.onMapUpdate
    @@OnMapUpdate
  end

# Triggers at the start of a wild battle.  Event handlers can provide their own
# wild battle routines to override the default behavior.
  def self.onWildBattleOverride=(v)
    @@OnWildBattleOverride=v
  end

  def self.onWildBattleOverride
    @@OnWildBattleOverride
  end

# Triggers whenever a wild Pokémon battle ends
# Parameters: 
# e[0] - Pokémon species
# e[1] - Pokémon level
# e[2] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
  def self.onWildBattleEnd=(v)
    @@OnWildBattleEnd=v
  end

  def self.onWildBattleEnd
    @@OnWildBattleEnd
  end

# Triggers whenever a wild Pokémon is created
# Parameters: 
# e[0] - Pokémon being created
  def self.onWildPokemonCreate=(v)
    @@OnWildPokemonCreate=v
  end

  def self.onWildPokemonCreate
    @@OnWildPokemonCreate
  end

# Fires whenever the map scene is regenerated and soon after the player moves
# to a new map.
# Parameters:
# e[0] = Scene_Map object.
# e[1] = Whether the player just moved to a new map (either true or false).  If
#   false, some other code had called $scene.createSpritesets to regenerate the
#   map scene without transferring the player elsewhere
  def self.onMapSceneChange=(v)
    @@OnMapSceneChange=v
  end

  def self.onMapSceneChange
    @@OnMapSceneChange
  end

# Fires whenever a spriteset is created.
# Parameters:
# e[0] = Spriteset being created
# e[1] = Viewport used for tilemap and characters
# e[0].map = Map associated with the spriteset (not necessarily the current map).
  def self.onSpritesetCreate=(v)
    @@OnSpritesetCreate=v
  end

  def self.onSpritesetCreate
    @@OnSpritesetCreate
  end
end



################################################################################
# Terrain tags
################################################################################
class PBTerrain
  Ledge                  = 1
  Grass                  = 2
  Sand                   = 3
  RockClimb              = 4
  DeepWater              = 5
  StillWater             = 6
  Water                  = 7
  Waterfall              = 8
  WaterfallCrest         = 9
  TallGrass              = 10
  UnderwaterGrass        = 11
  Ice                    = 12
  Neutral                = 13
  SootGrass              = 14
  Bridge                 = 15
  NoEncounterSandAndSnow = 16
  SuperFastBike          = 17
end



def pbIsSurfableTag?(tag)
  return pbIsWaterTag?(tag)
end

def pbIsWaterTag?(tag)
  return tag==PBTerrain::DeepWater ||
         tag==PBTerrain::Water ||
         tag==PBTerrain::WaterfallCrest ||
         tag==PBTerrain::Waterfall
end

def pbIsPassableWaterTag?(tag)
  return tag==PBTerrain::DeepWater ||
         tag==PBTerrain::Water ||
         tag==PBTerrain::StillWater ||
         tag==PBTerrain::WaterfallCrest
end
       
def PBTerrain.isJustWater?(tag)
  return tag==PBTerrain::Water ||
         tag==PBTerrain::StillWater ||
         tag==PBTerrain::DeepWater
end

def pbIsJustWaterTag?(tag)
  return tag==PBTerrain::DeepWater ||
         tag==PBTerrain::Water ||
         tag==PBTerrain::StillWater
end

def pbIsGrassTag?(tag)
  if $game_map.map_id==397 && tag==PBTerrain::SuperFastBike
    return false
  end
  
  return tag==PBTerrain::Grass ||
         tag==PBTerrain::TallGrass ||
         tag==PBTerrain::Sand ||
         tag==PBTerrain::UnderwaterGrass
end



################################################################################
# Battles
################################################################################
class Game_Temp
  attr_accessor :background_bitmap
end



def pbNewBattleScene
  return PokeBattle_Scene.new
end

def pbSceneStandby
    $tempIsBattle=true

  if $scene && $scene.is_a?(Scene_Map)
    $scene.disposeSpritesets
  end
  GC.start
  Graphics.frame_reset
  yield
  if $scene && $scene.is_a?(Scene_Map)
    $scene.createSpritesets
  end
    $tempIsBattle=false

end

def pbBattleAnimation(bgm=nil,trainerid=-1,trainername="")
  handled=false
  playingBGS=nil
  playingBGM=nil
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS=$game_system.getPlayingBGS
    playingBGM=$game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  pbMEFade(0.25)
  pbWait(10)
  pbMEStop
  if bgm
    pbBGMPlay(bgm)
  else
    pbBGMPlay(pbGetWildBattleBGM(0))
  end
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
# Fade to gray a few times.
  viewport.color=Color.new(17*8,17*8,17*8)
  3.times do
    viewport.color.alpha=0
    6.times do
      viewport.color.alpha+=30
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    6.times do
      viewport.color.alpha-=30
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  if $game_temp.background_bitmap
    $game_temp.background_bitmap.dispose
  end
  $game_temp.background_bitmap=Graphics.snap_to_bitmap
# Animate the screen ($game_temp.background_bitmap contains
# the current game screen).
#
# The following example runs a common event that does a custom animation if some
# condition is true. The screen should fade to black when the common event is
# finished:
#
# if $game_map && $game_map.map_id==20  # If on map 20
#   pbCommonEvent(20)
#   handled=true                        # Note that the battle animation is done
# end
#
################################################################################
# VS animation, by Luka S.J.
# Tweaked by Maruno.
################################################################################
  
  if (trainerid>=0 || $game_switches[122]) && !$game_switches[306]
    if $game_switches[122]
      if $game_variables[25] == 1
        trainername = "Arceus"
      end
      if $game_variables[25] == 2
        trainername = "Zekrom"
      end
      if $game_variables[25] == 3
        trainername = "Reshiram"
      end
      if $game_variables[25] == 4
        trainername = "Mewtwo"
      end
      trainerid= $game_variables[25]*-1
    end
    aryOfCult=[PBTrainers::ABYSSALGRUNT_MCRAW,PBTrainers::ABYSSALGRUNT_MKING,
    PBTrainers::ABYSSALGRUNT_MDRAG,PBTrainers::ABYSSALGRUNT_FCRAW,
    PBTrainers::ABYSSALGRUNT_FKING,PBTrainers::ABYSSALGRUNT_FDRAG,PBTrainers::ABYSSALLEADER,
    PBTrainers::INFERNALGRUNT_M,PBTrainers::INFERNALGRUNT_F,PBTrainers::DARKRAI_M,
    PBTrainers::DARKRAILEADER,PBTrainers::PERFECTIONGRUNT_M,PBTrainers::PERFECTIONGRUNT_F,
    PBTrainers::SKYGRUNT_MSALA,PBTrainers::SKYGRUNT_FSALA,PBTrainers::SKYGRUNT_MCROB,
    PBTrainers::SKYGRUNT_FCROB,PBTrainers::SKYGRUNT_MHONC,PBTrainers::SKYGRUNT_FHONC,
    PBTrainers::PERFECTION_TAEN,PBTrainers::INFERNALLEADER,PBTrainers::DAMNED_M,
    PBTrainers::CORRUPTED,PBTrainers::SKYLEADER,PBTrainers::DAMNEDLEADER_Nyx]
      aryOfSBFS=[113,116,119,165,190,354,390,731,729,727]

    if !aryOfSBFS.include?($game_map.map_id) && (FileTest.image_exist?(sprintf("Graphics/Transitions/vsBar#{trainerid}")) &&
     FileTest.image_exist?(sprintf("Graphics/Transitions/vsTrainer#{trainerid}"))) || aryOfCult.include?(trainerid)

     
     isCult = aryOfCult.include?(trainerid)
     
     
    # Set up
    viewplayer=Viewport.new(0,Graphics.height/3,Graphics.width/2,128) if !isCult
    viewplayer=Viewport.new(16,-40,Graphics.width+16,Graphics.height+40) if isCult
    viewplayer.z=viewport.z
    viewopp=Viewport.new(Graphics.width/2,Graphics.height/3,Graphics.width/2,128) if !isCult
    viewopp=Viewport.new((Graphics.width/2) + 8,-40,Graphics.width,Graphics.height+40) if isCult
    viewopp.z=viewport.z
    viewvs=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewvs.z=viewport.z
    xoffset=(Graphics.width/2)/10
    xoffset=xoffset.round
    xoffset=xoffset*10
    fade=Sprite.new(viewport)
    fade.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsFlash")
    fade.tone=Tone.new(-255,-255,-255)
    fade.opacity=255
    overlay=Sprite.new(viewport)
    overlay.bitmap=Bitmap.new(Graphics.width,Graphics.height)
    pbSetSystemFont(overlay.bitmap)
    bar1=Sprite.new(viewplayer)
        bar1.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsBar#{trainerid}") if !isCult
        bar1.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/bar_transparent") if isCult
 
        
   
    
    
    bar1.x=-xoffset
    bar2=Sprite.new(viewopp)
    bar2.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsBar#{trainerid}") if !isCult
    bar2.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/bar_transparent") if isCult
    bar2.x=xoffset
    vs=Sprite.new(viewvs)
    vs.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vs") if !isCult
    vs.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vs_transparent") if isCult
    vs.ox=vs.bitmap.width/2
    vs.oy=vs.bitmap.height/2
    vs.x=Graphics.width/2
    vs.y=Graphics.height/1.5
    vs.visible=false
    flash=Sprite.new(viewvs)
    flash.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsFlash")
    flash.opacity=0
    # Animation
    10.times do
      bar1.x+=xoffset/10
      bar2.x-=xoffset/10
      pbWait(1)
    end
    pbSEPlay("Flash2")
    pbSEPlay("Sword2")
    flash.opacity=255

    bar1=AnimatedPlane.new(viewplayer)
    bar1.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsBar#{trainerid}") if !isCult
    bar1.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/bar_transparent") if isCult
    player=Sprite.new(viewplayer)
    if !isCult
      
          player.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsTrainer#{$Trainer.trainertype}")
          
        else
          
          abyssArray=[PBTrainers::ABYSSALGRUNT_MCRAW,
          PBTrainers::ABYSSALGRUNT_MKING,PBTrainers::ABYSSALGRUNT_MDRAG,
          PBTrainers::ABYSSALGRUNT_FCRAW,PBTrainers::ABYSSALGRUNT_FKING,
          PBTrainers::ABYSSALGRUNT_FDRAG,PBTrainers::ABYSSALLEADER]
          
          infernalArray=[PBTrainers::INFERNALLEADER,PBTrainers::INFERNALGRUNT_M,PBTrainers::INFERNALGRUNT_F]
          
          perfectArray=[PBTrainers::PERFECTIONGRUNT_M,PBTrainers::PERFECTIONGRUNT_F,PBTrainers::PERFECTION_TAEN]
          
          darkraiArray=[PBTrainers::DARKRAI_M,PBTrainers::DARKRAILEADER]
          
          skyArray=[PBTrainers::SKYGRUNT_MSALA,PBTrainers::SKYGRUNT_MCROB,
          PBTrainers::SKYGRUNT_MHONC,PBTrainers::SKYGRUNT_FSALA,
          PBTrainers::SKYGRUNT_FHONC,PBTrainers::SKYGRUNT_FCROB,PBTrainers::SKYLEADER]
          
          damnedArray=[PBTrainers::DAMNED_M,PBTrainers::DAMNEDLEADER_Nyx]
      
      if abyssArray.include?(trainerid)
           player.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/abyssal_left")
         end
      if infernalArray.include?(trainerid)
           player.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/infernal_left")
         end
      if perfectArray.include?(trainerid)
           player.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/perfection_left")
         end
      if darkraiArray.include?(trainerid)
           player.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/darkrai_left")
         end
      if skyArray.include?(trainerid)
           player.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/sky_left")
         end
      if damnedArray.include?(trainerid)
           player.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/damned_left")
         end
    end
    
    player.x=-xoffset
#    for i in 0..playerClothes.length-1
#      playerClothes[i].x=-xoffset
#    end
    
    bar2=AnimatedPlane.new(viewopp)
    bar2.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsBar#{trainerid}") if !isCult
    bar2.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/bar_transparent") if isCult
    trainer=Sprite.new(viewopp)
    if !isCult
      trainer.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/vsTrainer#{trainerid}") 
    else
      if abyssArray.include?(trainerid)
           trainer.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/abyssal_right")
         end
      if infernalArray.include?(trainerid)
           trainer.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/infernal_right")
      end
      if skyArray.include?(trainerid)
           trainer.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/sky_right")
      end
      if darkraiArray.include?(trainerid)
           trainer.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/darkrai_right")
      end
      if perfectArray.include?(trainerid)
           trainer.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/perfection_right")
      end
      if damnedArray.include?(trainerid)
           trainer.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/damned_right")
      end
    end
    
    trainer.x=xoffset
    trainer.tone=Tone.new(-255,-255,-255)
    25.times do
      flash.opacity-=51 if flash.opacity>0
      bar1.ox-=16
      bar2.ox+=16
      pbWait(1)
    end
    11.times do
      bar1.ox-=16
      bar2.ox+=16
      player.x+=xoffset/10
  #    for i in 0..playerClothes.length-1
  #    playerClothes[i].x+=xoffset/10
  #    end
      trainer.x-=xoffset/10
      pbWait(1)
    end
    2.times do
      bar1.ox-=16
      bar2.ox+=16
      player.x-=xoffset/20
    #  for i in 0..playerClothes.length-1
    #  playerClothes[i].x-=xoffset/20
    #  end
      trainer.x+=xoffset/20
      pbWait(1)
    end
    10.times do
      bar1.ox-=16
      bar2.ox+=16
      pbWait(1)
    end
    val=2
    flash.opacity=255
    vs.visible=true
    trainer.tone=Tone.new(0,0,0)
    textpos=[
    #   [_INTL("{1}",$Trainer.name),Graphics.width/4,(Graphics.height/1.5)+10,2,
    #      Color.new(248,248,248),Color.new(12*6,12*6,12*6)],
       [_INTL("{1}",trainername),(Graphics.width/4)+(Graphics.width/2),(Graphics.height/1.5)+10,2,
          Color.new(248,248,248),Color.new(12*6,12*6,12*6)]
    ]
    pbDrawTextPositions(overlay.bitmap,textpos) if !isCult
    pbSEPlay("Sword2")
    70.times do
      bar1.ox-=16
      bar2.ox+=16
      flash.opacity-=25.5 if flash.opacity>0
      vs.x+=val
      vs.y-=val
      val=2 if vs.x<=(Graphics.width/2)-2
      val=-2 if vs.x>=(Graphics.width/2)+2
      pbWait(1)
    end
    30.times do
      bar1.ox-=16
      bar2.ox+=16
      vs.zoom_x+=0.2
      vs.zoom_y+=0.2
      pbWait(1)
    end
    flash.tone=Tone.new(-255,-255,-255)
    10.times do
      bar1.ox-=16
      bar2.ox+=16
      flash.opacity+=25.5
      pbWait(1)
    end
    # End
    fade.dispose
    overlay.dispose
    bar1.dispose
    bar2.dispose
    player.dispose
  #  for i in 0..playerClothes.length-1
  #    playerClothes[i].dispose
  #  end
    trainer.dispose
    vs.dispose
    flash.dispose
    viewplayer.dispose
    viewopp.dispose
    viewvs.dispose
    handled=true
    end

end
  if !handled
    if Sprite.method_defined?(:wave_amp) && rand(15)==0
      viewport.color=Color.new(0,0,0,255)
      sprite = Sprite.new
      bitmap=Graphics.snap_to_bitmap
      bm=bitmap.clone
      sprite.z=99999
      sprite.bitmap = bm
      sprite.wave_speed=500
      for i in 0..25
        sprite.opacity-=10
        sprite.wave_amp+=60
        sprite.update
        sprite.wave_speed+=30
        2.times do
          Graphics.update
        end
      end
      bitmap.dispose
      bm.dispose
      sprite.dispose
    elsif Bitmap.method_defined?(:radial_blur) && rand(15)==0
      viewport.color=Color.new(0,0,0,255)
      sprite = Sprite.new
      bitmap=Graphics.snap_to_bitmap
      bm=bitmap.clone
      sprite.z=99999
      sprite.bitmap = bm
      for i in 0..15
        bm.radial_blur(i,2)
        sprite.opacity-=15
        2.times do
          Graphics.update
        end
      end
      bitmap.dispose
      bm.dispose
      sprite.dispose
    elsif rand(15)==0
      scroll=["ScrollDown","ScrollLeft","ScrollRight","ScrollUp"]
      Graphics.freeze
      viewport.color=Color.new(0,0,0,255)
      Graphics.transition(50,sprintf("Graphics/Transitions/%s",scroll[rand(4)]))
    elsif rand(15)==0
      scroll=["ScrollDownRight","ScrollDownLeft","ScrollUpRight","ScrollUpLeft"]
      Graphics.freeze
      viewport.color=Color.new(0,0,0,255)
      Graphics.transition(50,sprintf("Graphics/Transitions/%s",scroll[rand(4)]))
    else
      transitions=["Splash","Image1","Image2",
         "Image3","Image4","Random_stripe_h",
         "Random_stripe_v","BreakingGlass",
         "RotatingPieces","022-Normal02",
         "021-Normal01","Battle","Mosaic","ShrinkingPieces","zoomin",
         "computertrclose","hexatr","hexatzr",
         "battle1","battle2","battle3","battle4",
         "computertr","hexatrc"
      ]
      rnd=rand(transitions.length)
      Graphics.freeze
      viewport.color=Color.new(0,0,0,255)
      Graphics.transition(40,sprintf("Graphics/Transitions/%s",transitions[rnd]))
    end
    5.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  pbPushFade
  yield if block_given?
  pbPopFade
  if $game_system && $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  end
  $PokemonGlobal.nextBattleBGM=nil
  $PokemonGlobal.nextBattleME=nil
  $PokemonGlobal.nextBattleBack=nil
  $PokemonEncounters.clearStepCount
  for j in 0..17
    viewport.color=Color.new(0,0,0,(17-j)*15)
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
      $game_switches[306] = false

  viewport.dispose
end

def pbPrepareBattle(battle)
  if $game_screen.weather_type==1 || $game_screen.weather_type==2
    battle.weather=PBWeather::RAINDANCE
    battle.weatherduration=-1
  elsif $game_screen.weather_type==3
    battle.weather=PBWeather::HAIL
    battle.weatherduration=-1
  elsif $game_screen.weather_type==4
    battle.weather=PBWeather::SANDSTORM
    battle.weatherduration=-1
  elsif $game_screen.weather_type==5
    battle.weather=PBWeather::SUNNYDAY
    battle.weatherduration=-1
  elsif pbGetMetadata($game_map.map_id,MetadataDarkMap)
    battle.weather=PBWeather::NEWMOON
    battle.weatherduration=-1
  end
  battle.shiftStyle=($PokemonSystem.battlestyle==0) && !$game_switches[340] &&
    !eliteFourDifficulty(false) && !eliteFourDifficulty(true)
  battle.battlescene=($PokemonSystem.battlescene==0)
  battle.environment=pbGetEnvironment
end

def pbGetEnvironment
  return PBEnvironment::None if !$game_map
  if $PokemonGlobal && $PokemonGlobal.diving
    return PBEnvironment::Underwater
  elsif $PokemonEncounters && $PokemonEncounters.isCave?
    return PBEnvironment::Cave
  elsif !pbGetMetadata($game_map.map_id,MetadataOutdoor)
    return PBEnvironment::None
  else
    terrain=$game_player.terrain_tag
    if terrain==PBTerrain::Grass # Normal grass
      return PBEnvironment::Grass
    elsif terrain==PBTerrain::TallGrass # Tall grass
      return PBEnvironment::TallGrass
    elsif terrain==PBTerrain::DeepWater || terrain==PBTerrain::Water
      return PBEnvironment::MovingWater
    elsif terrain==PBTerrain::StillWater || $PokemonGlobal.surfing
      return PBEnvironment::StillWater
#    elsif terrain==PBTerrain::Rock
#      return PBEnvironment::Rock
    elsif terrain==PBTerrain::Sand
      return PBEnvironment::Sand
    end
    return PBEnvironment::None
  end
end

def pbGenerateWildPokemon(species,level,ability=nil,ivs=false)
 # species = rand(721)+1 if $game_switches[321]

  #species = 1 if species == 0
  deltaAry=[]
  for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
    deltaAry.push(i)
  end
  for i in deltaAry
    klj = i + 1
  end
  
  species=rand(722+deltaAry.length) if $game_switches[321]
  species = 1 if species == 0
  if species>PBSpecies::VOLCANION
    species=deltaAry[species-722] if $game_switches[321]
  end
      
  #Froakie, Frogadier, Greninja
  #Fennekin, Braixen, Delphox
  #Chespin, Quilladin, Chesnaught
  #Xerneas, Yveltal, Zygarde 12
  #Binacle, Barbaracle
  #Skrelp, Dragalge
  #Goomy, Sliggoo, Godora 19
  #Hawlucha
  #Sylveon
  #Noibat, Noivern
  #Honedge, Doublade, Aegislash 26
  #Tyrunt, Tyrantrum
  #Amaura, Aurorus
  #Bunnelby, Diggersby
  #Pancham, Pangoro
  #Klefki 35
  #Diancie, Volcanion
  #Espurr, Meowstic
  #Inkay, Malamar
  #Helioptile, Heliolisk 44
  genwildpoke=PokeBattle_Pokemon.new(species,level,$Trainer)
  items=genwildpoke.wildHoldItems
  chances=[50,5,1]
  chances=[60,20,5] if !$Trainer.party[0].egg? &&
     isConst?($Trainer.party[0].ability,PBAbilities,:COMPOUNDEYES)
  itemrnd=rand(100)
  if itemrnd<chances[0] || (items[0]==items[1] && items[1]==items[2])
    genwildpoke.item=items[0]
  elsif itemrnd<(chances[0]+chances[1])
    genwildpoke.item=items[1]
  elsif itemrnd<(chances[0]+chances[1]+chances[2])
    genwildpoke.item=items[2]
  end
  genwildpoke.item=Kernel.pbCheckForRandomItem(genwildpoke.item)
  if getConst(PBItems,:SHINYCHARM) && $PokemonBag.pbQuantity(PBItems::SHINYCHARM)>0
    for i in 0...2   # 3 times as likely
      genwildpoke.personalID=rand(65536)|(rand(65536)<<16) if !genwildpoke.isShiny?
    end
  end
  if rand(65536)<POKERUSCHANCE
    genwildpoke.givePokerus
  end
  if ability!=nil
    genwildpoke.setAbility(ability)
  end
  if ivs
    for i in 0...6
      genwildpoke.iv[i]=31
    end
  end
  Events.onWildPokemonCreate.trigger(nil,genwildpoke)
  return genwildpoke
end

def pbWildBattleFlee(species,level,form=0,name=nil)
    return pbWildBattle(species,level,nil,true,false,nil,true,form,name)
end

def pbItemBall(item,number=1,plural=nil,escape=false)
  Kernel.pbItemBall(item,number,plural,escape)
end

def pbReceiveItem(item,number=1)
  Kernel.pbItemBall(item,number)
end

def pbWildBattle(species,level,variable=nil,canescape=true,canlose=false,getpoke=nil,theyflee=false,form=0,nickname=nil,ability=nil,ivs=false)
  if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
    if $Trainer.pokemonCount>0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable,1)
    $PokemonGlobal.nextBattleBGM=nil
    $PokemonGlobal.nextBattleME=nil
    $PokemonGlobal.nextBattleBack=nil
    return true
  end
  handled=[nil]
  Events.onWildBattleOverride.trigger(nil,species,level,handled)
  if handled[0]!=nil
    return handled[0]
  end
  currentlevels=[]
  for i in $Trainer.party
    currentlevels.push(i.level)
  end
  genwildpoke=pbGenerateWildPokemon(species,level,ability,ivs)
  genwildpoke=getpoke if getpoke != nil
  genwildpoke.name=nickname if nickname != nil
  genwildpoke.form=form if form != 0
  Events.onStartBattle.trigger(nil,genwildpoke)
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke],$Trainer,nil)
  battle.internalbattle=true
  battle.cantescape=!canescape
  pbPrepareBattle(battle)
  decision=0
  pbBattleAnimation(pbGetWildBattleBGM(species)) { 
  $tempIsBattle=true
     pbSceneStandby {
   #  Kernel.pbMessage("canlose1") if canlose
        decision=battle.pbStartBattle(canlose,theyflee)
     }
     if $PokemonGlobal.partner
       pbHealAll if !$game_switches[329]
       for i in $PokemonGlobal.partner[3]; i.heal; end
       end
     if decision==2 || decision==5 # if loss or draw
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  pbSet(variable,decision)
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  return (decision!=2)
end

def pbDoubleWildBattle(species1,level1,species2,level2,variable=nil,canescape=true,canlose=false)
  if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount==0
    if $Trainer.pokemonCount>0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable,1)
    $PokemonGlobal.nextBattleBGM=nil
    $PokemonGlobal.nextBattleME=nil
    $PokemonGlobal.nextBattleBack=nil
    return true
  end
  currentlevels=[]
  for i in $Trainer.party
    currentlevels.push(i.level)
  end
  genwildpoke=pbGenerateWildPokemon(species1,level1)
  genwildpoke2=pbGenerateWildPokemon(species2,level2)
  Events.onStartBattle.trigger(nil,genwildpoke)
  scene=pbNewBattleScene
  if $PokemonGlobal.partner
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    combinedParty=[]
    for i in 0...$Trainer.party.length
      combinedParty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      combinedParty[6+i]=othertrainer.party[i]
    end
    battle=PokeBattle_Battle.new(scene,combinedParty,[genwildpoke,genwildpoke2],
       [$Trainer,othertrainer],nil)
    battle.fullparty1=true
  else
    battle=PokeBattle_Battle.new(scene,$Trainer.party,[genwildpoke,genwildpoke2],
       $Trainer,nil)
  end
  #Kernel.pbMessage(_INTL("Encounter 1.2: {1}",genwildpoke.level))
  #Kernel.pbMessage(_INTL("Encounter 2.2: {1}",genwildpoke2.level))
  battle.internalbattle=true
  battle.doublebattle=battle.pbDoubleBattleAllowed?()
  battle.cantescape=!canescape
  pbPrepareBattle(battle)
  decision=0
  $tempIsBattle=false
  pbBattleAnimation(pbGetWildBattleBGM(species1)) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]; i.heal; end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  pbSet(variable,decision)
  return (decision!=2 && decision!=5)
end

def pbCheckAllFainted()
  if pbAllFainted
    Kernel.pbMessage(_INTL("{1} has no usable Pokémon!\1",$Trainer.name))
    Kernel.pbMessage(_INTL("{1} blacked out!",$Trainer.name))
     if $game_switches[584]
          Kernel.pbMessage("Thank you for playing the Ironman Challenge.")
          Kernel.pbMessage("I'm sure you did well!")
          Kernel.pbMessage("Your save file was deleted. We encourage you to try again!")
          File.delete(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_3.rxdata")) if File.exist?(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_3.rxdata"))
          File.delete(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_2.rxdata")) if File.exist?(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_2.rxdata"))
          File.delete(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_1.rxdata")) if File.exist?(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_1.rxdata"))
         if $game_variables[96] == 0
                 File.delete(RTP.getSaveFileName("Game.rxdata")) if File.exist?(RTP.getSaveFileName("Game.rxdata"))

           else
            File.delete(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata")) if File.exist?(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata"))
  
       end
      
          raise("DELETED SAVE FILE")
          end
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn(99999){
       Kernel.pbStartOver
    }
  end
end

def pbEvolutionCheck(currentlevels)
  # Check conditions for evolution
  for i in 0...currentlevels.length
    pokemon=$Trainer.party[i]
    if pokemon && (!currentlevels[i] || pokemon.level!=currentlevels[i])
      newspecies=Kernel.pbCheckEvolution(pokemon)
      if newspecies>0
        # Start evolution scene
        evo=PokemonEvolutionScene.new
        evo.pbStartScreen(pokemon,newspecies)
        evo.pbEvolution
        evo.pbEndScreen
      end
    end
  end
end

def pbDynamicItemList(*args)
  ret=[]
  for i in 0...args.length
    if hasConst?(PBItems,args[i])
      ret.push(getConst(PBItems,args[i].to_sym))
    end
  end
  return ret
end

# Runs the Pickup event after a battle if a Pokemon has the ability Pickup.
def Kernel.pbPickup(pokemon)
  return if !isConst?(pokemon.ability,PBAbilities,:PICKUP) || pokemon.egg?
  return if pokemon.item!=0
  return if rand(10)!=0
  pickupList=pbDynamicItemList(
      :POTION,
      :ANTIDOTE,
      :SUPERPOTION,
      :GREATBALL,
      :REPEL,
      :ESCAPEROPE,
      :FULLHEAL,
      :HYPERPOTION,
      :ULTRABALL,
      :REVIVE,
      :RARECANDY,
      :SUNSTONE,
      :MOONSTONE,
      :HEARTSCALE,
      :FULLRESTORE,
      :MAXREVIVE,
      :PPUP,
      :MAXELIXIR
  )
  pickupListRare=pbDynamicItemList(
      :MAXREPEL,
      :NUGGET,
      :KINGSROCK,
      :FULLRESTORE,
      :IRONBALL,
      :LUCKYEGG,
      :IVSTONE,
      :ELIXIR,
      :IVSTONE,
      :LEFTOVERS,
      :IVSTONE
  )
  return if pickupList.length!=18
  return if pickupListRare.length!=11
  randlist=[30,10,10,10,10,10,10,4,4,1,1]
  items=[]
  plevel=[100,pokemon.level].min
  rnd=rand(100)
  itemstart=(plevel-1)/10
  itemstart=0 if itemstart<0
  for i in 0...9
    items.push(pickupList[i+itemstart])
  end
  items.push(pickupListRare[itemstart])
  items.push(pickupListRare[itemstart+1])
  cumnumber=0
  for i in 0...11
    cumnumber+=randlist[i]
    if rnd<cumnumber
      pokemon.item=items[i]
      break
    end
  end
end



class PokemonTemp
  attr_accessor :encounterType 
  attr_accessor :evolutionLevels
end



def pbEncounter(enctype)
  if $PokemonGlobal.partner# || rand(1)==0
    encounter1=$PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter1
    encounter2=$PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter2
    $PokemonTemp.encounterType=enctype
    pbDoubleWildBattle(encounter1[0],encounter1[1],encounter2[0],encounter2[1])
    $PokemonTemp.encounterType=-1
    return true
  else
    encounter=$PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter
    $PokemonTemp.encounterType=enctype
    pbWildBattle(encounter[0],encounter[1])
	  $PokemonTemp.encounterType=-1
    return true
  end
end

Events.onStartBattle+=proc {|sender,e|
  $PokemonTemp.evolutionLevels=[]
  for i in 0...$Trainer.party.length
    $PokemonTemp.evolutionLevels[i]=$Trainer.party[i].level
  end
}

Events.onEndBattle+=proc {|sender,e|
  decision=e[0]
  if decision!=2 && decision!=5 # not a loss or a draw
    if $PokemonTemp.evolutionLevels
      pbEvolutionCheck($PokemonTemp.evolutionLevels)
      $PokemonTemp.evolutionLevels=nil
    end
  end
  if decision==1
    for pkmn in $Trainer.party
      Kernel.pbPickup(pkmn)
      if isConst?(pkmn.ability,PBAbilities,:HONEYGATHER) && !pkmn.egg? && pkmn.item==0
        if hasConst?(PBItems,:HONEY)
          chance = 5 + ((pkmn.level-1)/10).floor*5
          pkmn.item=getConst(PBItems,:HONEY) if rand(100)<chance
        end
      end
    end
  end
}



################################################################################
# Scene_Map and Spriteset_Map
################################################################################
class Scene_Map
  def createSingleSpriteset(map)
    temp=$scene.spriteset.getAnimations
    @spritesets[map]=Spriteset_Map.new($MapFactory.maps[map])
    $scene.spriteset.restoreAnimations(temp)
    $MapFactory.setSceneStarted(self)
    updateSpritesets
  end
end



class Spriteset_Map
  def getAnimations
    return @usersprites
  end

  def restoreAnimations(anims)
    @usersprites=anims
  end
end



Events.onSpritesetCreate+=proc{|sender,e|
  spriteset=e[0] # Spriteset being created
  viewport=e[1] # Viewport used for tilemap and characters
  map=spriteset.map # Map associated with the spriteset (not necessarily the current map).
  for i in map.events.keys
    if map.events[i].name=="OutdoorLight"
     spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i],map))
    elsif map.events[i].name=="Light"
      spriteset.addUserSprite(LightEffect_Basic.new(map.events[i],map))
    end
  end
  spriteset.addUserSprite(Particle_Engine.new(viewport,map))
}

def Kernel.pbOnSpritesetCreate(spriteset,viewport)
  Events.onSpritesetCreate.trigger(nil,spriteset,viewport)
end



################################################################################
# Field movement
################################################################################
def pbLedge(xOffset,yOffset)
  if Kernel.pbFacingTerrainTag==PBTerrain::Ledge
    if Kernel.pbJumpToward(2,true)
      $game_player.increase_steps
      $game_player.check_event_trigger_here([1,2])
    end
    return true
  end
  return false
end

def Kernel.pbSlideOnIce(event=nil)
  event=$game_player if !event
  return if !event
  return if pbGetTerrainTag(event)!=PBTerrain::Ice
  direction=event.direction
  oldwalkanime=event.walk_anime
  event.straighten
  event.walk_anime=false
  loop do
    break if !event.passable?(event.x,event.y,direction)
    break if pbGetTerrainTag(event)!=PBTerrain::Ice
    event.move_forward
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  event.center(event.x,event.y)
  event.walk_anime=oldwalkanime
end

# Poison event on each step taken
Events.onStepTakenTransferPossible+=proc {|sender,e|
  handled=e[0]
  next if handled[0]
  if $PokemonGlobal.stepcount % 4 == 0 && POISONINFIELD
    flashed=false
    for i in $Trainer.party
      if i.status==PBStatuses::POISON && i.hp>0 && !i.egg? &&
         !isConst?(i.ability,PBAbilities,:POISONHEAL) &&
         !isConst?(i.ability,PBAbilities,:MAGICGUARD)
        if !flashed
          $game_screen.start_flash(Color.new(255,0,0,128), 4)
          flashed=true
        end
        if i.hp==1 && !POISONFAINTINFIELD
          i.status=0
          Kernel.pbMessage(_INTL("{1} survived the poisoning.\\nThe poison faded away!\\1",i.name))
          next
        end
        i.hp-=1
        if i.hp==1 && !POISONFAINTINFIELD
          i.status=0
          Kernel.pbMessage(_INTL("{1} survived the poisoning.\\nThe poison faded away!\\1",i.name))
        end
        if i.hp==0
          i.changeHappiness("faint")
          i.status=0
          Kernel.pbMessage(_INTL("{1} fainted...\\1",i.name))
        end
        handled[0]=true if pbAllFainted
        pbCheckAllFainted()
      elsif i.status==PBStatuses::POISON && i.hp<i.totalhp && !i.egg? &&
         isConst?(i.ability,PBAbilities,:POISONHEAL)
        if !flashed
          $game_screen.start_flash(Color.new(0,255,0,128), 4)
          flashed=true
        end
        i.hp+=1
      end
    end
  end
}

Events.onStepTaken+=proc{
if $scenetemp && $showMap && $showMap > 0
          
          mapinfos=$RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
          #mapname=mapinfos[$PokemonGlobal.mapTrail[1]].name
          mapname=mapinfos[$showMap].name
          #if $scene.spriteset
          $scenetemp.spriteset.addUserSprite(LocationWindow.new(mapname)) #if rand(20)
                  #  Kernel.pbMessage(mapname)
    #  $game_screen.pictures[22].show(LocationWindow.new(mapname), 0,
    #   15, 15, 100, 100, 255, 0) if $game_screen && $game_screen.pictures

  end
  $PokemonGlobal.happinessSteps=0 if !$PokemonGlobal.happinessSteps
  $PokemonGlobal.happinessSteps+=1
  if $PokemonGlobal.happinessSteps==256
    for pkmn in $Trainer.party
      if pkmn.hp>0 && !pkmn.egg?
        pkmn.changeHappiness("walking")
      end
    end
    $PokemonGlobal.happinessSteps=0
  end
}
=begin
Events.onStepTakenFieldMovement+=proc{|sender,e|
  event=e[0] # Get the event affected by field movement
  thistile=$MapFactory.getRealTilePos($game_map.map_id,event.x,event.y)
  if thistile = nil
    return
  end
  map=$MapFactory.getMap(thistile[0])
  sootlevel=nil
  for i in [2, 1, 0]
    tile_id = map.data[thistile[1],thistile[2],i]
    next if tile_id == nil
    if map.terrain_tags[tile_id] &&
       map.terrain_tags[tile_id]==PBTerrain::SootGrass
      sootlevel=i
      break
    end
  end
  if sootlevel
    $PokemonGlobal.sootsack=0 if !$PokemonGlobal.sootsack
    map.data[thistile[1],thistile[2],sootlevel]=0
    if event==$game_player && $PokemonBag.pbQuantity(getConst(PBItems,:SOOTSACK))>0
      $PokemonGlobal.sootsack+=1
    end
    $scene.createSingleSpriteset(map.map_id)
  end 
}
=end
Events.onStepTakenFieldMovement+=proc{|sender,e|
  event=e[0] # Get the event affected by field movement
  currentTag=pbGetTerrainTag(event)
  #otherTag=pbGetTerrainTag($game_map.map_id,$game_player.x,$game_player.y+1)
  
  if pbGetTerrainTag(event,true)==PBTerrain::Grass && event==$game_player  # Won't show if under bridge
    $scene.spriteset.addUserAnimation(GRASS_ANIMATION_ID,event.x,event.y)
  elsif event==$game_player && currentTag==PBTerrain::WaterfallCrest
    # Descend waterfall, but only if this event is the player
    Kernel.pbDescendWaterfall(event)
  elsif event==$game_player && Kernel.pbFacingTerrainTag==PBTerrain::Waterfall #&& Input.press?(Input::DOWN)
    # Descend waterfall, but only if this event is the player
    Kernel.pbDescendWaterfall(event)
  elsif event==$game_player && currentTag==PBTerrain::RockClimb
    # Descend waterfall, but only if this event is the player
    Kernel.pbDescendRockClimb(event)
  elsif event==$game_player && currentTag==PBTerrain::Ice
    Kernel.pbSlideOnIce(event)
  end
}

def pbBattleOnStepTaken(repel=false)
  if $Trainer.party.length > 0
    encounterType=$PokemonEncounters.pbEncounterType
    if encounterType>=0
      encounter=$PokemonEncounters.pbGenerateEncounter(encounterType)
      if $PokemonEncounters.isEncounterPossibleHere?() #$TEMPHOOPA=true
        encounter=EncounterModifier.trigger(encounter)
        if $PokemonEncounters.pbCanEncounter?(encounter,repel)
          
          #previously rand(30)
          if ($PokemonGlobal.partner || rand(30)==0) && $Trainer.ablePokemonCount>1 && !pbInSafari?
            encounter2=$PokemonEncounters.pbEncounteredPokemon(encounterType)
            pbDoubleWildBattle(encounter[0],encounter[1],encounter2[0],encounter2[1])
          else
            $tempCanHoopa=true
            pbWildBattle(encounter[0],encounter[1])
            $tempCanHoopa=false

          end
        end
        EncounterModifier.triggerEncounterEnd()
      end
    end
  end
end

def Kernel.pbOnStepTaken(eventTriggered)
  if $game_player.move_route_forcing || pbMapInterpreterRunning? || !$Trainer
    # if forced movement or if no trainer was created yet
    Events.onStepTakenFieldMovement.trigger(nil,$game_player)
    return
  end
  $PokemonGlobal.stepcount=0 if !$PokemonGlobal.stepcount
  $PokemonGlobal.stepcount+=1
  $PokemonGlobal.stepcount&=0x7FFFFFFF
  Events.onStepTaken.trigger(nil)
  repel = ($PokemonGlobal.repel>0)
  Events.onStepTakenFieldMovement.trigger(nil,$game_player)
  handled=[nil]
  Events.onStepTakenTransferPossible.trigger(nil,handled)
  return if handled[0]
  if !eventTriggered
    pbBattleOnStepTaken(repel)
  end
end

def Kernel.pbUpdateVehicle
  meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
  if meta
    if $PokemonGlobal.diving
      $game_player.character_name=meta[5] && meta[5]!="" ? meta[5] : meta[1] # Diving graphic
    elsif $PokemonGlobal.surfing
      $game_player.character_name=meta[3] && meta[3]!="" ? meta[3] : meta[1] # Surfing graphic
    elsif $PokemonGlobal.bicycle
      $game_player.character_name=meta[2] && meta[2]!="" ? meta[2] : meta[1] # Bicycle graphic
    else
      #$game_player.character_name=meta[1] if !$game_switches[136] # Regular graphic
    end
  end
end

def Kernel.pbCancelVehicles(destination=nil)
  $PokemonGlobal.surfing=false
  $PokemonGlobal.diving=false
  notNormalAry=[42,69,70,71,278,383,432,433]
  Kernel.pbChangeBackToNormal if !notNormalAry.include?($game_map.map_id)
  if !destination || !pbCanUseBike?(destination)
    $PokemonGlobal.bicycle=false
  end
  Kernel.pbUpdateVehicle
  if $Trainer && $Trainer.party
    $PokemonTemp.dependentEvents.refresh_sprite
  end
end

def pbCanUseBike?(mapid)
  return true if pbGetMetadata(mapid,MetadataBicycleAlways)
  val=pbGetMetadata(mapid,MetadataBicycle)
  val=pbGetMetadata(mapid,MetadataOutdoor) if val==nil
  return val ? true : false 
end

def Kernel.pbMountBike
  return if $PokemonGlobal.bicycle
  $PokemonGlobal.bicycle=true
  $PokemonTemp.dependentEvents.remove_sprite(true)
  Kernel.pbUpdateVehicle
  bikebgm=pbGetMetadata(0,MetadataBicycleBGM)
  if bikebgm
    pbCueBGM(bikebgm,0.5)
  end
end

def Kernel.pbDismountBike
  return if !$PokemonGlobal.bicycle
  $PokemonGlobal.bicycle=false
  Kernel.pbUpdateVehicle
  $game_map.autoplayAsCue
  $PokemonTemp.dependentEvents.refresh_sprite
end

def Kernel.pbSetPokemonCenter(deltaX=0,deltaY=0)
  $PokemonGlobal.pokecenterMapId=$game_map.map_id
  $PokemonGlobal.pokecenterX=$game_player.x+deltaX
  $PokemonGlobal.pokecenterY=$game_player.y+deltaY
  $PokemonGlobal.pokecenterDirection=$game_player.direction
  
  if $Trainer && $Trainer.party
    for poke in $Trainer.party
      for i in 0..3
        if poke.moves[i] && poke.moves[i].id==PBMoves::DARKSONATA
          poke.resetMoves
        end
      end
      
      if poke.species==PBSpecies::DELTAROSERADE || poke.species==PBSpecies::DELTAROSELIA
        for i in 0..3
          if poke.moves[i] && poke.moves[i].id==PBMoves::DARKVOID
            poke.moves[i]=PBMove.new(PBMoves::LOVELYKISS)
          end
          if poke.moves[i] && poke.moves[i].id==PBMoves::SWEETKISS
            poke.moves[i]=PBMove.new(PBMoves::LOVELYKISS)
          end
        end
      end
      if poke.species==PBSpecies::DELTADWEBBLE2 || poke.species==PBSpecies::DELTACRUSTLE2
        for i in 0..3
          if poke.moves[i] && poke.moves[i].id==PBMoves::EARTHQUAKE
            poke.moves[i]=PBMove.new(PBMoves::CELEBRATE)
          end
        end
      end
      blacklist=[
        :FIREBLAST,:FLAREBLITZ, # Flareon
        :THUNDERBOLT,:VOLTSWITCH, # Jolteon
        :HYDROPUMP,:SCALD, # VAPOREON
        :FOULPLAY,:PURSUIT, # UMBREON
        :PSYCHIC,:PSYSHOCK, # ESPEON
        :LEAFBLADE,:GIGADRAIN, # LEAFEON
        :ICEBEAM,:BLIZZARD, # GLACEON
        :MOONBLAST,:DAZZLINGGLEAM, # Sylveon
      ]
      exclusion=[]
      eeveelution=false
      case poke.species
      when PBSpecies::FLAREON
        exclusion=[:FIREBLAST,:FLAREBLITZ,]
        eeveelution=true
      when PBSpecies::JOLTEON
        exclusion=[:THUNDERBOLT,:VOLTSWITCH,]
        eeveelution=true
      when PBSpecies::VAPOREON
        exclusion=[:HYDROPUMP,:SCALD,:ICEBEAM,:BLIZZARD]
        eeveelution=true
      when PBSpecies::UMBREON
        exclusion=[:FOULPLAY,:PURSUIT,:PSYCHIC]
        eeveelution=true
      when PBSpecies::ESPEON
        exclusion=[:PSYCHIC,:PSYSHOCK,:DAZZLINGGLEAM]
        eeveelution=true
      when PBSpecies::LEAFEON
        exclusion=[:LEAFBLADE,:GIGADRAIN,]
        eeveelution=true
      when PBSpecies::GLACEON
        exclusion=[:ICEBEAM,:BLIZZARD,]
        eeveelution=true
      when PBSpecies::SYLVEON
        exclusion=[:MOONBLAST,:DAZZLINGGLEAM,:PSYSHOCK]
        eeveelution=true
      end
      if eeveelution
        tackleexists=false
        for i in 0..3
          move=poke.moves[i]
          for j in blacklist
            if isConst?(move.id,PBMoves,j) && !exclusion.include?(j)
              if !tackleexists
                poke.moves[i]=PBMove.new(PBMoves::TACKLE)
                tackleexists=true
              else
                pbDeleteMove(poke,i)
              end
            end
          end
        end
      end
    end
  end
end

def Kernel.pbSetSpawnPoint(mapid,deltaX=0,deltaY=0)
  $PokemonGlobal.pokecenterMapId=$game_map.map_id
  $PokemonGlobal.pokecenterX=$game_player.x+deltaX
  $PokemonGlobal.pokecenterY=$game_player.y+deltaY
  $PokemonGlobal.pokecenterDirection=$game_player.direction
end



################################################################################
# Fishing
################################################################################
def pbFishingBegin
  $PokemonGlobal.fishing=true
  if !pbCommonEvent(FISHINGBEGINCOMMONEVENT)
    patternb = 2*$game_player.direction - 1
    playertrainer=pbGetPlayerTrainerType
    meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
    num=($PokemonGlobal.surfing) ? 7 : 6
    if meta && meta[num] && meta[num]!=""
      4.times do |pattern|
        $game_player.setDefaultCharName(meta[num],patternb-pattern)
        2.times do
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
    end
  end
end

def pbFishingEnd
  if !pbCommonEvent(FISHINGENDCOMMONEVENT)
    patternb = 2*($game_player.direction - 2)
    playertrainer=pbGetPlayerTrainerType
    meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
    num=($PokemonGlobal.surfing) ? 7 : 6
    if meta && meta[num] && meta[num]!=""
      4.times do |pattern|
        $game_player.setDefaultCharName(meta[num],patternb+pattern)
        2.times do
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
    end
  end
  $PokemonGlobal.fishing=false
end

def pbFishing(hasencounter)
  biting=false
  bitechance=65
  hookchance=65
  oldpattern=$game_player.fullPattern
  pbFishingBegin
  msgwindow=Kernel.pbCreateMessageWindow
  loop do
    time=2+rand(10)
    #skipEllipsis=false
    message=""
    #if $Trainer.party.length>0 && !$Trainer.party[0].egg?
    #  if isConst?($Trainer.party[0].ability,PBAbilities,:SUCTIONCUPS) ||
    #     isConst?($Trainer.party[0].ability,PBAbilities,:STICKYHOLD)
    #    skipEllipsis=true
    #  end
    #end
    #if skipEllipsis
    #  time.times do 
    #    message+=".  "
    #  end
    #end
    if pbWaitMessage(msgwindow,time)
      pbFishingEnd
      $game_player.setDefaultCharName(nil,oldpattern)
      Kernel.pbMessageDisplay(msgwindow,_INTL("Not even a nibble..."))
      Kernel.pbDisposeMessageWindow(msgwindow)
      return false
    end
    rnd=rand(100)
    rnd=0 if biting
    if rnd<bitechance && hasencounter  && ($game_map.map_id != 553 || !$game_switches[526])
      frames=50
      if !pbWaitForInput(msgwindow,message+_INTL("\r\nOh!  A bite!"),frames)
        pbFishingEnd
        $game_player.setDefaultCharName(nil,oldpattern)
        Kernel.pbMessageDisplay(msgwindow,_INTL("It got away..."))
        Kernel.pbDisposeMessageWindow(msgwindow)
        return false
      end
      rnd=rand(100)
      if (rnd<hookchance || FISHINGAUTOHOOK) && ($game_map.map_id != 553 || !$game_switches[526])
        Kernel.pbMessageDisplay(msgwindow,_INTL("A Pokémon's on the hook!"))
        Kernel.pbDisposeMessageWindow(msgwindow)
        pbFishingEnd
        $game_player.setDefaultCharName(nil,oldpattern)
        return true
      end
      biting=true
      hookchance+=15
      bitechance+=15
    else
      pbFishingEnd
      $game_player.setDefaultCharName(nil,oldpattern)
      Kernel.pbMessageDisplay(msgwindow,_INTL("Not even a nibble..."))
      Kernel.pbDisposeMessageWindow(msgwindow)
      return false
    end
  end
  Kernel.pbDisposeMessageWindow(msgwindow)
  return false
end

def pbWaitForInput(msgwindow,message,frames)
  if $Trainer.party.length>0 && !$Trainer.party[0].egg?
    if isConst?($Trainer.party[0].ability,PBAbilities,:SUCTIONCUPS) ||
       isConst?($Trainer.party[0].ability,PBAbilities,:STICKYHOLD)
      return true
    end
  end
  return true if FISHINGAUTOHOOK
  Kernel.pbMessageDisplay(msgwindow,message,false)
  frames.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    if Input.trigger?(Input::C) || Input.trigger?(Input::B)
      return true
    end
  end
  return false
end

def pbWaitMessage(msgwindow,time)
  if $Trainer.party.length>0 && !$Trainer.party[0].egg?
    if isConst?($Trainer.party[0].ability,PBAbilities,:SUCTIONCUPS) ||
       isConst?($Trainer.party[0].ability,PBAbilities,:STICKYHOLD)
      return false
    end
  end
  message=""
  (time+1).times do |i|
    message+=".  " if i>0
    Kernel.pbMessageDisplay(msgwindow,message,false)
    20.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::C)||Input.trigger?(Input::B)
        return true
      end
    end
  end
  return false
end



################################################################################
# Moving between maps
################################################################################
Events.onMapChange+=proc {|sender,e|
  oldid=e[0] # previous map ID, 0 if no map ID
  healing=pbGetMetadata($game_map.map_id,MetadataHealingSpot)
  $PokemonGlobal.healingSpot=healing if healing
  $PokemonMap.clear if $PokemonMap
  $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  $PokemonGlobal.visitedMaps[$game_map.map_id]=true
#    $PokemonTemp.dependentEvents.updateDependentEvents if $PokemonTemp.dependentEvents

#tempdelc  $PokemonTemp.dependentEvents.walk_anime=true if $PokemonTemp.dependentEvents
  if oldid!=0 && oldid!=$game_map.map_id
    mapinfos=$RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
    if $game_map.name!=mapinfos[oldid].name
      weather=pbGetMetadata($game_map.map_id,MetadataWeather)
      $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
    end
  end
    $game_map.need_refresh=true

}

Events.onMapChanging+=proc {|sender,e|
  newmapID=e[0]
  newmap=e[1]
  # Undo the weather ($game_map still refers to the old map)
  mapinfos=$RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
  if newmapID>0 && $game_map.name!=mapinfos[newmapID].name
    weather=pbGetMetadata($game_map.map_id,MetadataWeather)
    $game_screen.weather(0,0,0) if weather
  end
}

Events.onMapSceneChange+=proc{|sender,e|
  scene=e[0]
  $tempscene=scene
  mapChanged=e[1]
  return if !scene || !scene.spriteset
  if $game_map
    lastmapdetails=$PokemonGlobal.mapTrail[0] ?
       pbGetMetadata($PokemonGlobal.mapTrail[0],MetadataMapPosition) : [-1,0,0]
    lastmapdetails=[-1,0,0] if !lastmapdetails
    newmapdetails=$game_map.map_id ?
       pbGetMetadata($game_map.map_id,MetadataMapPosition) : [-1,0,0]
    newmapdetails=[-1,0,0] if !newmapdetails
    $PokemonGlobal.mapTrail=[] if !$PokemonGlobal.mapTrail
    if $PokemonGlobal.mapTrail[0]!=$game_map.map_id
      $PokemonGlobal.mapTrail[3]=$PokemonGlobal.mapTrail[2] if $PokemonGlobal.mapTrail[2]
      $PokemonGlobal.mapTrail[2]=$PokemonGlobal.mapTrail[1] if $PokemonGlobal.mapTrail[1]
      $PokemonGlobal.mapTrail[1]=$PokemonGlobal.mapTrail[0] if $PokemonGlobal.mapTrail[0]
    end
    $PokemonGlobal.mapTrail[0]=$game_map.map_id   # Update map trail
  end
  darkmap=pbGetMetadata($game_map.map_id,MetadataDarkMap)
  if darkmap
    if $PokemonGlobal.flashUsed
      $PokemonTemp.darknessSprite=DarknessSprite.new
      scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
      darkness=$PokemonTemp.darknessSprite
      darkness.radius=176
    else
      $PokemonTemp.darknessSprite=DarknessSprite.new
      scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
    end
  elsif !darkmap
    $PokemonGlobal.flashUsed=false
    if $PokemonTemp.darknessSprite
      $PokemonTemp.darknessSprite.dispose
      $PokemonTemp.darknessSprite=nil
    end
  end
  if mapChanged
    if pbGetMetadata($game_map.map_id,MetadataShowArea)
      nosignpost=false
      if $PokemonGlobal.mapTrail[1]
        for i in 0...NOSIGNPOSTS.length/2
          nosignpost=true if NOSIGNPOSTS[2*i]==$PokemonGlobal.mapTrail[1] && NOSIGNPOSTS[2*i+1]==$game_map.map_id
          nosignpost=true if NOSIGNPOSTS[2*i+1]==$PokemonGlobal.mapTrail[1] && NOSIGNPOSTS[2*i]==$game_map.map_id
          break if nosignpost
        end
        mapinfos=$RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
        oldmapname=mapinfos[$PokemonGlobal.mapTrail[1]].name
        nosignpost=true if $game_map.name==oldmapname
      end
      scene.spriteset.addUserSprite(LocationWindow.new($game_map.name)) if !nosignpost
    end
  end
  if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
    Kernel.pbMountBike
  else
    if !pbCanUseBike?($game_map.map_id)
      Kernel.pbDismountBike
    end
  end
}

def Kernel.pbStartOver(gameover=false)
  setdive=false
  setsurf=false
  setbike=false
  if $PokemonGlobal.diving
    setdive=true
  elsif $PokemonGlobal.surfing
    setsurf=true
  elsif $PokemonGlobal.bicycle
    setbike=true
  end
  if $game_switches[584]
    Kernel.pbMessage("Thank you for playing the Ironman Challenge.")
    Kernel.pbMessage("I'm sure you did well!")
    Kernel.pbMessage("Your save file was deleted. We encourage you to try again!")
    File.delete(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_3.rxdata")) if File.exist?(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_3.rxdata"))
    File.delete(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_2.rxdata")) if File.exist?(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_2.rxdata"))
    File.delete(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_1.rxdata")) if File.exist?(RTP.getSaveFileName("Save_"+$game_variables[96].to_s+"_Backup_1.rxdata"))
    if $game_variables[96] == 0
      File.delete(RTP.getSaveFileName("Game.rxdata")) if File.exist?(RTP.getSaveFileName("Game.rxdata"))
    else
      File.delete(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata")) if File.exist?(RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata"))
    end
    raise("DELETED SAVE FILE")
  end

  if pbInBugContest?
    Kernel.pbBugContestStartOver
    return
  end
  pbHealAll()
  if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId>=0
    if gameover
      Kernel.pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, {1} scurried to a Pokémon Center.",$Trainer.name))
    else
      if $game_map.map_id==433 && $game_switches[674]
        pbFadeOutIn(99999){
          #Kernel.pbSetSpawnPoint(820,28,25)
          Kernel.pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After {1}'s defeat, everything faded to black...",$Trainer.name))
          $game_temp.player_new_map_id=820
          $game_temp.player_new_x=28
          $game_temp.player_new_y=26
          $game_temp.player_new_direction=$PokemonGlobal.pokecenterDirection
          $scene.transfer_player if $scene.is_a?(Scene_Map)
          $game_player.move_up(false)
        }
      else
        Kernel.pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]{1} scurried to a Pokémon Center, protecting the exhausted and fainted Pokémon from further harm.",$Trainer.name))
      end
    end
    Kernel.pbCancelVehicles
    #pbRemoveDependencies()
    $game_switches[STARTING_OVER_SWITCH]=true
    $game_temp.player_new_map_id=$PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x=$PokemonGlobal.pokecenterX
    $game_temp.player_new_y=$PokemonGlobal.pokecenterY+1
    $game_temp.player_new_direction=$PokemonGlobal.pokecenterDirection
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    if !$scene.is_a?(Scene_Map)
      if $game_switches[71]
        Kernel.pbMessage(_INTL("{1}, your Nuzlocke Challenge is over.\\nThank you for participating.\\nWe will revive your dead Pokemon, however, this Challenge is no longer considered a Nuzlocke Challenge and you are considered to have failed.\\nI'm sorry.",$Trainer.name))
        $game_switches[71]=false
      end
      if setdive
        $PokemonGlobal.diving=true
      elsif setsurf
        $PokemonGlobal.surfing=true
      elsif setbike
        $PokemonGlobal.bicycle=true
      end
      Kernel.pbUpdateVehicle
      pbHealAll()
      $PokemonTemp.dependentEvents.refresh_sprite
      $game_switches[1]=false
    else
      $game_player.move_up(false)
    end
    $game_map.refresh
  else
    homedata=pbGetMetadata(0,MetadataHome)
    if (homedata && !pbRxdataExists?(sprintf("Data/Map%03d",homedata[0])) )
      if $DEBUG
        Kernel.pbMessage(_ISPRINTF("Can't find the map 'Map{1:03d}' in the Data folder.  The game will resume at the player's position.",homedata[0]))
      end
      pbHealAll()
      return
    end
    if gameover
      Kernel.pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, {1} scurried home.",$Trainer.name))
    else
      Kernel.pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]{1} scurried home, protecting the exhausted and fainted Pokémon from further harm.",$Trainer.name))
    end
    if homedata
      Kernel.pbCancelVehicles
      pbRemoveDependencies()
      $game_switches[STARTING_OVER_SWITCH]=true
      $game_temp.player_new_map_id=homedata[0]
      $game_temp.player_new_x=homedata[1]
      $game_temp.player_new_y=homedata[2]+1
      $game_temp.player_new_direction=homedata[3]
      $scene.transfer_player
      $game_player.move_up(false)
      $game_map.refresh
    else
      pbHealAll()
    end
  end
  pbEraseEscapePoint
end

def pbCaveEntranceEx(exiting)
  sprite=BitmapSprite.new(Graphics.width,Graphics.height)
  sprite.z=100000
  totalBands=15
  totalFrames=15
  bandheight=((Graphics.height/2)-10).to_f/totalBands
  bandwidth=((Graphics.width/2)-12).to_f/totalBands
  grays=[]
  tbm1=totalBands-1
  for i in 0...totalBands
    grays.push(exiting ? 0 : 255)
  end
  totalFrames.times do |j|
    x=0
    y=0
    rectwidth=Graphics.width
    rectheight=Graphics.height
    for k in 0...j
      t=(255.0)/totalFrames
      if exiting
        t=1.0-t
        t*=1.0+((k)/totalFrames.to_f)
      else
        t*=1.0+0.3*(((totalFrames-k)/totalFrames.to_f)**0.7)
      end
      grays[k]-=t
      grays[k]=0 if grays[k]<0
    end
    for i in 0...totalBands
      currentGray=grays[i]
      sprite.bitmap.fill_rect(Rect.new(x,y,rectwidth,rectheight),
         Color.new(currentGray,currentGray,currentGray))
      x+=bandwidth
      y+=bandheight
      rectwidth-=bandwidth*2
      rectheight-=bandheight*2
    end
    Graphics.update
    Input.update
  end
  if exiting
    pbToneChangeAll(Tone.new(255,255,255),0)
  else
    pbToneChangeAll(Tone.new(-255,-255,-255),0)
  end
  for j in 0..15
    if exiting
      sprite.color=Color.new(255,255,255,j*255/15)
    else
      sprite.color=Color.new(0,0,0,j*255/15) 
    end
    Graphics.update
    Input.update
  end
  if !exiting
  pbToneChangeAll(Tone.new(0,0,0),8)
  end
  for j in 0..5
    Graphics.update
    Input.update
  end
  sprite.dispose
end

def pbCaveEntrance
  pbSetEscapePoint
#  pbCaveEntranceEx(false)
end

def pbCaveExit
  pbEraseEscapePoint
#  pbCaveEntranceEx(true)
end

def pbSetEscapePoint
  $PokemonGlobal.escapePoint=[] if !$PokemonGlobal.escapePoint
  xco=$game_player.x
  yco=$game_player.y
  case $game_player.direction
    when 2   # Down
      yco-=1; dir=8
    when 4   # Left
      xco+=1; dir=6
    when 6   # Right
      xco-=1; dir=4
    when 8   # Up
      yco+=1; dir=2
    end
  $PokemonGlobal.escapePoint=[$game_map.map_id,xco,yco,dir]
end

def pbEraseEscapePoint
  $PokemonGlobal.escapePoint=[]
end



################################################################################
# Partner trainer
################################################################################
def pbRegisterPartner(trainerid,trainername,partyid=0)
  Kernel.pbCancelVehicles
  trainer=pbLoadTrainer(trainerid,trainername,partyid)
  trainerobject=PokeBattle_Trainer.new(_INTL(trainername),trainerid)
  trainerobject.setForeignID($Trainer)
  for i in trainer[2]
    i.trainerID=trainerobject.id
    i.ot=trainerobject.name
    i.calcStats
  end
  $PokemonGlobal.partner=[trainerid,trainerobject.name,trainerobject.id,trainer[2]]
end

def pbDeregisterPartner
  $PokemonGlobal.partner=nil
end



################################################################################
# Constant checks
################################################################################
Events.onMapUpdate+=proc {|sender,e|   # Pokérus check
  last=$PokemonGlobal.pokerusTime
  now=pbGetTimeNow
  if !last || last.year!=now.year || last.month!=now.month || last.day!=now.day
    if $Trainer && $Trainer.party
      for i in $Trainer.pokemonParty
        i.lowerPokerusCount
      end
      $PokemonGlobal.pokerusTime=now
    end
  end
}

# Returns whether the Poké Center should explain Pokérus to the player, if a
# healed Pokémon has it.
def Kernel.pbPokerus?
  return false if $game_switches[SEEN_POKERUS_SWITCH]
  for i in $Trainer.party
    return true if i.pokerusStage==1
  end
  return false
end



class PokemonTemp
  attr_accessor :batterywarning
  attr_accessor :cueBGM
  attr_accessor :cueFrames
end



def pbBatteryLow?
  power="\0"*12
  begin
    sps=Win32API.new('kernel32.dll','GetSystemPowerStatus','p','l')
    rescue
    return false
  end
  if sps.call(power)==1
    status=power.unpack("CCCCVV")
    # Battery Flag
    if status[1]!=255 && (status[1]&6)!=0 # Low or Critical
      return true
    end
    # Battery Life Percent
    if status[2]<3 # Less than 3 percent
      return true
    end
    # Battery Life Time
    if status[4]<300 # Less than 5 minutes
      return true
    end
  end
  return false
end

Events.onMapUpdate+=proc {|sender,e|
  time=pbGetTimeNow
  if time.sec==0 && $Trainer && $PokemonGlobal && $game_player && $game_map &&
     !$PokemonTemp.batterywarning && !$game_player.move_route_forcing &&
     !pbMapInterpreterRunning? && !$game_temp.message_window_showing &&
     pbBatteryLow? && (!$game_switches || !$game_switches[136])
    $PokemonTemp.batterywarning=true
    Kernel.pbMessage(_INTL("The game has detected that the battery is low.  You should save soon to avoid losing your progress."))
  end
  if $PokemonTemp.cueFrames
    $PokemonTemp.cueFrames-=1
    if $PokemonTemp.cueFrames<=0
      $PokemonTemp.cueFrames=nil
      if $game_system.getPlayingBGM==nil
        pbBGMPlay($PokemonTemp.cueBGM)
      end
    end
  end
}



################################################################################
# Audio playing
################################################################################
def pbCueBGM(bgm,seconds,volume=nil,pitch=nil)
  return if !bgm
  bgm=pbResolveAudioFile(bgm,volume,pitch)
  playingBGM=$game_system.playing_bgm
  if !playingBGM || playingBGM.name!=bgm.name || playingBGM.pitch!=bgm.pitch
    pbBGMFade(seconds)
    if !$PokemonTemp.cueFrames
      $PokemonTemp.cueFrames=(seconds*Graphics.frame_rate)*3/5
    end
    $PokemonTemp.cueBGM=bgm
  elsif playingBGM
    pbBGMPlay(bgm)
  end
end

def pbAutoplayOnTransition
  surfbgm=pbGetMetadata(0,MetadataSurfBGM)
  bikebgm=pbGetMetadata(0,MetadataBicycleBGM)
  if $PokemonGlobal.surfing && surfbgm
    pbBGMPlay(surfbgm)
  elsif $PokemonGlobal.bicycle && bikebgm
    pbBGMPlay(bikebgm)
  else
    $game_map.autoplayAsCue
  end
end

def pbAutoplayOnSave
  surfbgm=pbGetMetadata(0,MetadataSurfBGM)
  bikebgm=pbGetMetadata(0,MetadataBicycleBGM)
  if $PokemonGlobal.surfing && surfbgm
    pbBGMPlay(surfbgm)
  elsif $PokemonGlobal.bicycle && bikebgm
    pbBGMPlay(bikebgm)
  else
    $game_map.autoplay
  end
end



################################################################################
# Voice recorder
################################################################################
def pbRecord(text,maxtime=30.0)
  text="" if !text
  textwindow=Window_UnformattedTextPokemon.newWithSize(text,
     0,0,Graphics.width,Graphics.height-96)
  textwindow.z=99999
  if text==""
    textwindow.visible=false
  end
  wave=nil
  msgwindow=Kernel.pbCreateMessageWindow
  oldvolume=Kernel.Audio_bgm_get_volume()
  Kernel.Audio_bgm_set_volume(0)
  delay=2
  delay.times do |i|
    Kernel.pbMessageDisplay(msgwindow,
      _ISPRINTF("Recording in {1:d} second(s)...\nPress ESC to cancel.",delay-i),false)
    Graphics.frame_rate.times do
      Graphics.update
      Input.update
      textwindow.update
      msgwindow.update
      if Input.trigger?(Input::B)
        Kernel.Audio_bgm_set_volume(oldvolume)
        Kernel.pbDisposeMessageWindow(msgwindow)
        textwindow.dispose
        return nil
      end
    end
  end
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("NOW RECORDING\nPress ESC to stop recording."),false)
  if beginRecordUI
    frames=(maxtime*Graphics.frame_rate).to_i
    frames.times do
      Graphics.update
      Input.update
      textwindow.update
      msgwindow.update
      if Input.trigger?(Input::B)
        break
      end
    end
    tmpFile=ENV["TEMP"]+"\\record.wav"
    endRecord(tmpFile)
    wave=getWaveDataUI(tmpFile,true)
    if wave
      Kernel.pbMessageDisplay(msgwindow,_INTL("PLAYING BACK..."),false)
      textwindow.update
      msgwindow.update
      Graphics.update
      Input.update
      wave.play
      (Graphics.frame_rate*wave.time).to_i.times do
        Graphics.update
        Input.update
        textwindow.update
        msgwindow.update
      end
    end
  end
  Kernel.Audio_bgm_set_volume(oldvolume)
  Kernel.pbDisposeMessageWindow(msgwindow)
  textwindow.dispose
  return wave
end

def Kernel.pbRxdataExists?(file)
  if $RPGVX
    return pbRgssExists?(file+".rvdata")
  else
    return pbRgssExists?(file+".rxdata") 
  end
end



################################################################################
# Gaining items
################################################################################
def Kernel.pbItemBall(item,quantity=1,plural=nil,escape=false)
  if item.is_a?(String) || item.is_a?(Symbol)
    item = getID(PBItems,item)
  end
  return false if !item || item<=0 || quantity<1
  
  item=pbCheckForRandomItem(item,escape)
  
  itemname=PBItems.getName(item)
  pocket=pbGetPocket(item)
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be picked up
    if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4
      Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found \\c[2]{2}\\c[0]!\\nIt contained \\c[2]{3}\\c[0].\\wtnp[30]",
         $Trainer.name,itemname,PBMoves.getName($ItemData[item][ITEMMACHINE])))
      Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
    elsif isConst?(item,PBItems,:LEFTOVERS)
      Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found some \\c[2]{2}\\c[0]!\\wtnp[30]",$Trainer.name,itemname))
      Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
    else
      if quantity>1
        if plural
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2} \\c[2]{3}\\c[0]!\\wtnp[30]",$Trainer.name,quantity,plural))
          Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,plural,PokemonBag.pocketNames()[pocket],pocket))
        else
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2} \\c[2]{3}s\\c[0]!\\wtnp[30]",$Trainer.name,quantity,itemname))
          Kernel.pbMessage(_INTL("{1} put the {2}s away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
        end
      else
        Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found one \\c[2]{2}\\c[0]!\\wtnp[30]",$Trainer.name,itemname))
        Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
      end
    end
    return true
  else   # Can't add the item
    if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4
      Kernel.pbMessage(_INTL("{1} found \\c[2]{2}\\c[0]!\\wtnp[20]",$Trainer.name,itemname))
    elsif isConst?(item,PBItems,:LEFTOVERS)
      Kernel.pbMessage(_INTL("{1} found some \\c[2]{2}\\c[0]!\\wtnp[20]",$Trainer.name,itemname))
    else
      if quantity>1
        if plural
          Kernel.pbMessage(_INTL("{1} found {2} \\c[2]{3}\\c[0]!\\wtnp[20]",$Trainer.name,quantity,plural))
        else
          Kernel.pbMessage(_INTL("{1} found {2} \\c[2]{3}s\\c[0]!\\wtnp[20]",$Trainer.name,quantity,itemname))
        end
      else
        Kernel.pbMessage(_INTL("{1} found one \\c[2]{2}\\c[0]!\\wtnp[20]",$Trainer.name,itemname))
      end
    end
    
    Kernel.pbMessage(_INTL("Too bad... The Bag is full..."))
    return false
  end
end

def Kernel.pbPokemonFound(item,quantity=1,plural=nil)
  itemname=PBItems.getName(item)
  pocket=pbGetPocket(item)
  e=$Trainer.party[0].name
if $PokemonBag.pbStoreItem(item,quantity) 
  pbWait(5)

    if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4
      Kernel.pbMessage(_INTL("\\se[]{1} found {2}!\\se[itemlevel]\\nIt contained {3}.\\wtnp[30]",e,itemname,PBMoves.getName($ItemData[item][ITEMMACHINE])))
      Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
    elsif isConst?(item,PBItems,:LEFTOVERS)
      Kernel.pbMessage(_INTL("\\se[]{1} found some {2}!\\se[itemlevel]\\wtnp[30]",e,itemname))
      Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
    else
      if quantity>1
        if plural
          Kernel.pbMessage(_INTL("\\se[]{1} found {2} {3}!\\se[itemlevel]\\wtnp[30]",e,quantity,plural))
          Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,plural,PokemonBag.pocketNames()[pocket],pocket))
        else
          Kernel.pbMessage(_INTL("\\se[]{1} found {2} {3}s!\\se[itemlevel]\\wtnp[30]",e,quantity,itemname))      
          Kernel.pbMessage(_INTL("{1} put the {2}s away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
        end
      else
        Kernel.pbMessage(_INTL("\\se[]{1} found one {2}!\\se[itemlevel]\\wtnp[30]",e,itemname))
        Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
      end
    end
    return true
  else   # Can't add the item
    if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4
      Kernel.pbMessage(_INTL("{1} found {2}!\\wtnp[20]",e,itemname))
    elsif isConst?(item,PBItems,:LEFTOVERS)
      Kernel.pbMessage(_INTL("{1} found some {2}!\\wtnp[20]",$Trainer.name,itemname))
    else
      if quantity>1
        if plural
          Kernel.pbMessage(_INTL("{1} found {2} {3}!\\wtnp[20]",e,quantity,plural))
        else
          Kernel.pbMessage(_INTL("{1} found {2} {3}s!\\wtnp[20]",$Trainer.name,quantity,itemname))
        end
      else
        Kernel.pbMessage(_INTL("{1} found one {2}!\\wtnp[20]",e,itemname))
      end
    end
    Kernel.pbMessage(_INTL("Too bad... The Bag is full..."))
    return false
  end
end

def Kernel.pbReceiveItem(item,quantity=1,plural=nil)
  item=pbCheckForRandomItem(item)
  itemname=PBItems.getName(item)
  pocket=pbGetPocket(item)
  if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained \\c[2]{1}\\c[0]!\\nIt contained \\c[2]{2}\\c[0].\\wtnp[30]",itemname,PBMoves.getName($ItemData[item][ITEMMACHINE])))
  elsif isConst?(item,PBItems,:LEFTOVERS)
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained some \\c[2]{1}\\c[0]!\\wtnp[30]",itemname))
  elsif quantity>1
    if plural
      Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained \\c[2]{1}\\c[0]!\\wtnp[30]",plural))
    else
      Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained \\c[2]{1}s\\c[0]!\\wtnp[30]",itemname))
    end
  else
    Kernel.pbMessage(_INTL("\\se[itemlevel]Obtained \\c[2]{1}\\c[0]!\\wtnp[30]",itemname))
  end
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be added
    if quantity>1
      if plural
        Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,plural,PokemonBag.pocketNames()[pocket],pocket))
      else
        Kernel.pbMessage(_INTL("{1} put the {2}s away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
      end
    else
      Kernel.pbMessage(_INTL("{1} put the {2} away\\nin the <icon=bagPocket{4}>\\c[2] {3} Pocket\\c[0].",$Trainer.name,itemname,PokemonBag.pocketNames()[pocket],pocket))
    end
    return true
  else   # Can't add the item
    return false
  end
end

def pbUseKeyItem
  if $PokemonBag.registeredItem==0
    Kernel.pbMessage(_INTL("A Key Item in the Bag can be registered to this key for instant use."))
  else
    Kernel.pbUseKeyItemInField($PokemonBag.registeredItem)
  end
end

def pbUseKeyItem2
  if $PokemonBag.registeredItem2==0
    Kernel.pbMessage(_INTL("A Key Item in the Bag can be registered to this key for instant use."))
  else
    Kernel.pbUseKeyItemInField($PokemonBag.registeredItem2)
  end
end

def pbUseKeyItem3
  if $PokemonBag.registeredItem3==0
    Kernel.pbMessage(_INTL("A Key Item in the Bag can be registered to this key for instant use."))
  else
    Kernel.pbUseKeyItemInField($PokemonBag.registeredItem3)
  end
end

def pbUseKeyItem4
  if $PokemonBag.registeredItem4==0
    Kernel.pbMessage(_INTL("A Key Item in the Bag can be registered to this key for instant use."))
  else
    Kernel.pbUseKeyItemInField($PokemonBag.registeredItem4)
  end
end


def pbUseKeyItem5
  if $PokemonBag.registeredItem5==0
    Kernel.pbMessage(_INTL("A Key Item in the Bag can be registered to this key for instant use."))
  else
    Kernel.pbUseKeyItemInField($PokemonBag.registeredItem5)
  end
end


################################################################################
# Event locations, terrain tags
################################################################################
def pbEventFacesPlayer?(event,player,distance)
  return false if distance<=0
  # Event can't reach player if no coordinates coincide
  return false if event.x!=player.x && event.y!=player.y
  deltaX = (event.direction == 6 ? 1 : event.direction == 4 ? -1 : 0)
  deltaY =  (event.direction == 2 ? 1 : event.direction == 8 ? -1 : 0)
  # Check for existence of player
  curx=event.x
  cury=event.y
  found=false
  for i in 0...distance
    curx+=deltaX
    cury+=deltaY
    if player.x==curx && player.y==cury
      found=true
      break
    end
  end
  return found
end

def pbEventCanReachPlayer?(event,player,distance)
  return false if distance<=0
  # Event can't reach player if no coordinates coincide
  return false if event.x!=player.x && event.y!=player.y
  deltaX = (event.direction == 6 ? 1 : event.direction == 4 ? -1 : 0)
  deltaY =  (event.direction == 2 ? 1 : event.direction == 8 ? -1 : 0)
  # Check for existence of player
  curx=event.x
  cury=event.y
  found=false
  realdist=0
  for i in 0...distance
    curx+=deltaX
    cury+=deltaY
    if player.x==curx && player.y==cury
      found=true
      break
    end
    realdist+=1
  end
  return false if !found
  # Check passibility
  curx=event.x
  cury=event.y
  for i in 0...realdist
    if !event.passable?(curx,cury,event.direction)
      return false
    end
    curx+=deltaX
    cury+=deltaY
  end
  return true
end
def pbEventCanReachPlayerNextOver?(event,player,distance)
  return false if distance<=0
  # Event can't reach player if no coordinates coincide
  for xchange in [-1,0,1]
    for ychange in [-1,0,1]
      next if event.x!=(player.x+xchange) && event.y!=(player.y+ychange)
      deltaX = (event.direction == 6 ? 1 : event.direction == 4 ? -1 : 0)
      deltaY =  (event.direction == 2 ? 1 : event.direction == 8 ? -1 : 0)
      # Check for existence of player
      curx=event.x
      cury=event.y
      found=false
      realdist=0
      for i in 0...distance
        curx+=deltaX
        cury+=deltaY
        if (player.x+xchange)==curx && (player.y+ychange)==cury
          found=true
          next
        end
        realdist+=1
      end
      next if !found
      # Check passibility
      curx=event.x
      cury=event.y
      for i in 0...realdist
        if !event.passable?(curx,cury,event.direction)
          next
        end
        curx+=deltaX
        cury+=deltaY
      end
        return true
    end
  end
  return false
end

def pbFacingTileRegular(direction=nil,event=nil)
  event=$game_player if !event
  return [0,0,0] if !event
  x=event.x
  y=event.y
  direction=event.direction if !direction
  case direction
    when 1; y+=1; x-=1
    when 2; y+=1
    when 3; y+=1; x+=1
    when 4; x-=1
    when 6; x+=1
    when 7; y-=1; x-=1
    when 8; y-=1
    when 9; y-=1; x+=1
  end
  return [$game_map ? $game_map.map_id : 0,x,y]
end

def pbFacingTile(direction=nil,event=nil)
  if $MapFactory
    return $MapFactory.getFacingTile(direction,event)
  else
    return pbFacingTileRegular(direction,event)
  end
end

def pbFacingEachOther(event1,event2)
  return false if !event1 || !event2
  if $MapFactory
    tile1=$MapFactory.getFacingTile(nil,event1)
    tile2=$MapFactory.getFacingTile(nil,event2)
    return false if !tile1 || !tile2
    if tile1[0]==event2.map.map_id &&
       tile1[1]==event2.x && tile1[2]==event2.y &&
       tile2[0]==event1.map.map_id &&
       tile2[1]==event1.x && tile2[2]==event1.y
      return true
    else
      return false
    end
  else
    tile1=Kernel.pbFacingTile(nil,event1)
    tile2=Kernel.pbFacingTile(nil,event2)
    return false if !tile1 || !tile2
    if tile1[1]==event2.x && tile1[2]==event2.y &&
       tile2[1]==event1.x && tile2[2]==event1.y
      return true
    else
      return false
    end
  end
end

def pbGetTerrainTag(event=nil,countBridge=false)
  event=$game_player if !event
  return 0 if !event
  if $MapFactory
    return $MapFactory.getTerrainTag(event.map.map_id,event.x,event.y,countBridge)
  else
    $game_map.terrain_tag(event.x,event.y,countBridge)
  end
end

def Kernel.pbFacingTerrainTag
  if $MapFactory
    return $MapFactory.getFacingTerrainTag
  else
    return 0 if !$game_player
    facing=pbFacingTile()
   return $game_map.terrain_tag(facing[1],facing[2])
  end
end



################################################################################
# Event movement
################################################################################
def pbTurnTowardEvent(event,otherEvent)
  sx=0
  sy=0
  if $MapFactory
    relativePos=$MapFactory.getThisAndOtherEventRelativePos(otherEvent,event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  if sx == 0 and sy == 0
    return
  end
  if sx.abs > sy.abs
    sx > 0 ? event.turn_left : event.turn_right
  else
    sy > 0 ? event.turn_up : event.turn_down
  end
end

def Kernel.pbMoveTowardPlayer(event)
  maxsize=[$game_map.width,$game_map.height].max
  return if !pbEventCanReachPlayer?(event,$game_player,maxsize)
  loop do
    x=event.x
    y=event.y
    event.move_toward_player
    break if event.x==x && event.y==y
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  $PokemonMap.addMovedEvent(event.id) if $PokemonMap
end

def Kernel.pbJumpToward(dist=1,playSound=false)
  x=$game_player.x
  y=$game_player.y
  case $game_player.direction
    when 2 # down
      $game_player.jump(0,dist)
    when 4 # left
      $game_player.jump(-dist,0)
    when 6 # right
      $game_player.jump(dist,0)
    when 8 # up
      $game_player.jump(0,-dist)
  end
  if $game_player.x!=x || $game_player.y!=y
    if playSound
      pbSEPlay("jump")
    end
    while $game_player.jumping?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    return true
  end
  return false
end

def pbWait(numframes)
  numframes.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end



module PBMoveRoute
  Down=1
  Left=2
  Right=3
  Up=4
  LowerLeft=5
  LowerRight=6
  UpperLeft=7
  UpperRight=8
  Random=9
  TowardPlayer=10
  AwayFromPlayer=11
  Forward=12
  Backward=13
  Jump=14 # xoffset, yoffset
  Wait=15 # frames
  TurnDown=16
  TurnLeft=17
  TurnRight=18
  TurnUp=19
  TurnRight90=20
  TurnLeft90=21
  Turn180=22
  TurnRightOrLeft90=23
  TurnRandom=24
  TurnTowardPlayer=25
  TurnAwayFromPlayer=26
  SwitchOn=27 # 1 param
  SwitchOff=28 # 1 param
  ChangeSpeed=29 # 1 param
  ChangeFreq=30 # 1 param
  WalkAnimeOn=31
  WalkAnimeOff=32
  StepAnimeOn=33
  StepAnimeOff=34
  DirectionFixOn=35
  DirectionFixOff=36
  ThroughOn=37
  ThroughOff=38
  AlwaysOnTopOn=39
  AlwaysOnTopOff=40
  Graphic=41 # Name, hue, direction, pattern
  Opacity=42 # 1 param
  Blending=43 # 1 param
  PlaySE=44 # 1 param
  Script=45 # 1 param
  
  ScriptAsync=101 # 1 param
end



class Game_Character
  def jumpForward
    case self.direction
      when 2 # down
        jump(0,1)
      when 4 # left
        jump(-1,0)
      when 6 # right
        jump(1,0)
      when 8 # up
        jump(0,-1)
    end
  end

  def jumpBackward
    case self.direction
      when 2 # down
        jump(0,-1)
      when 4 # left
        jump(1,0)
      when 6 # right
        jump(-1,0)
      when 8 # up
        jump(0,1)
    end
  end

  def moveLeft90
    case self.direction
      when 2 # down
        move_right
      when 4 # left
        move_down
      when 6 # right
        move_up
      when 8 # up
        move_left
    end
  end

  def moveRight90
    case self.direction
      when 2 # down
        move_left
      when 4 # left
        move_up
      when 6 # right
        move_down
      when 8 # up
        move_right
    end
  end

  def minilock
    @prelock_direction=@direction
    @locked=true
  end
end



def pbMoveRoute(event,commands,waitComplete=false,repeatRoute=false)
  route=RPG::MoveRoute.new
  if !repeatRoute
    route.repeat=false
  else
    route.repeat=true
  end
  route.skippable=true
  route.list.clear
  #route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOn))
  i=0;while i<commands.length
    case commands[i]
      when PBMoveRoute::Wait, PBMoveRoute::SwitchOn,
         PBMoveRoute::SwitchOff, PBMoveRoute::ChangeSpeed,
         PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
         PBMoveRoute::Blending, PBMoveRoute::PlaySE,
         PBMoveRoute::Script
        route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1]]))
        i+=1
      when PBMoveRoute::ScriptAsync
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,[commands[i+1]]))
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[0]))
        i+=1
      when PBMoveRoute::Jump
        route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2]]))
        i+=2
      when PBMoveRoute::Graphic
        route.list.push(RPG::MoveCommand.new(commands[i],
           [commands[i+1],commands[i+2],commands[i+3],commands[i+4]]))
        i+=4
      else
        route.list.push(RPG::MoveCommand.new(commands[i]))
    end
    i+=1
  end
  #route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOff))
  route.list.push(RPG::MoveCommand.new(0))
  if event
    event.force_move_route(route)
  end
  return route
end



################################################################################
# Screen effects
################################################################################
def pbToneChangeAll(tone, duration)
  $game_screen.start_tone_change(tone,duration * 2)
  for picture in $game_screen.pictures
    picture.start_tone_change(tone,duration * 2) if picture
  end
end

def pbShake(power,speed,frames)
  $game_screen.start_shake(power,speed,frames * 2)
end

def pbFlash(color,frames)
  $game_screen.start_flash(color,frames * 2)
end

def pbScrollMap(direction, distance, speed)
  return if !$game_map
  if speed==0
    case direction
      when 2
        $game_map.scroll_down(distance * 128)
      when 4
        $game_map.scroll_left(distance * 128)
      when 6
        $game_map.scroll_right(distance * 128)
      when 8
        $game_map.scroll_up(distance * 128)
    end
  else
    $game_map.start_scroll(direction, distance, speed);
    oldx=$game_map.display_x
    oldy=$game_map.display_y
    loop do
      Graphics.update
      Input.update
      if !$game_map.scrolling?
        break
      end
      pbUpdateSceneMap
      if $game_map.display_x==oldx && $game_map.display_y==oldy
        break
      end
      oldx=$game_map.display_x
      oldy=$game_map.display_y 
    end
  end
end



################################################################################
# Events
################################################################################
class Game_Event
  def cooledDown?(seconds)
    if !(expired?(seconds) && tsOff?("A"))
      self.need_refresh=true
      return false
    else
      return true
    end
  end

  def cooledDownDays?(days)
     if !(expiredDays?(days) && tsOff?("A"))
      self.need_refresh=true
      return false
    else
      return true
    end
  end
end



module InterpreterFieldMixin
  # Used in boulder events.  Allows an event to be pushed.  To be used in
  # a script event command.
  def pbPushThisEvent
    event=get_character(0)
    oldx=event.x
    oldy=event.y
    # Apply strict version of passable, which makes impassable
    # tiles that are passable only from certain directions
    if !event.passableStrict?(event.x,event.y,$game_player.direction)
      return
    end
    case $game_player.direction
      when 2 # down
        event.move_down
      when 4 # left
        event.move_left
      when 6 # right
        event.move_right
      when 8 # up
        event.move_up
    end
    $PokemonMap.addMovedEvent(@event_id) if $PokemonMap
    if oldx!=event.x || oldy!=event.y
      $game_player.lock
      begin
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end until !event.moving?
      $game_player.unlock
    end
  end

  def pbPushThisBoulder
    if $PokemonMap.strengthUsed
      pbPushThisEvent
    end
    return true
  end

  def pbHeadbutt
    Kernel.pbHeadbutt(get_character(0))
    return true
  end
  
  def pbDigWall
    Kernel.pbDigWall(get_character(0))
    return true
  end

  def pbTrainerIntro(symbol)
    if !$game_switches[693]
      if $DEBUG
        return if !Kernel.pbTrainerTypeCheck(symbol)
      end
      trtype=PBTrainers.const_get(symbol)
      pbGlobalLock
      Kernel.pbPlayTrainerIntroME(trtype)
      return true
    end
    return false
  end

  def pbTrainerEnd
    pbGlobalUnlock
    e=get_character(0)
    e.erase_route if e
  end

  def pbParams
    @parameters ? @parameters : @params
  end

  def pbGetPokemon(id)
    return $Trainer.party[pbGet(id)]
  end
  
  def pbCheckZygarde
    ret=false
    for i in 0...$Trainer.party.length
      if $Trainer.party[i].species==PBSpecies::ZYGARDE
        ret=true
        break
      end
    end
    return ret
  end

  def pbSetEventTime(*arg)
    $PokemonGlobal.eventvars={} if !$PokemonGlobal.eventvars
    time=pbGetTimeNow
    time=time.to_i
    pbSetSelfSwitch(@event_id,"A",true)
    $PokemonGlobal.eventvars[[@map_id,@event_id]]=time
    for otherevt in arg
      pbSetSelfSwitch(otherevt,"A",true)
      $PokemonGlobal.eventvars[[@map_id,otherevt]]=time
    end
  end

  def getVariable(*arg)
    if arg.length==0
      return nil if !$PokemonGlobal.eventvars
      return $PokemonGlobal.eventvars[[@map_id,@event_id]]
    else
      return $game_variables[arg[0]]
    end
  end

  def setVariable(*arg)
    if arg.length==1
      $PokemonGlobal.eventvars={} if !$PokemonGlobal.eventvars
      $PokemonGlobal.eventvars[[@map_id,@event_id]]=arg[0]
    else
      $game_variables[arg[0]]=arg[1]
      $game_map.need_refresh=true
    end
  end

  def tsOff?(c)
    get_character(0).tsOff?(c)
  end

  def tsOn?(c)
    get_character(0).tsOn?(c)
  end

  alias isTempSwitchOn? tsOn?
  alias isTempSwitchOff? tsOff?

  def setTempSwitchOn(c)
    if get_character(0) && get_character(0) != nil
    get_character(0).setTempSwitchOn(c)
    end
  end
def setTempSwitchOnFor(c,x)
    if get_character(x) && get_character(x) != nil
    get_character(x).setTempSwitchOn(c)
    end
  end
  def setTempSwitchOff(c)
    get_character(0).setTempSwitchOff(c)
  end
    def setTempSwitchOffFor(c,x)
    get_character(x).setTempSwitchOff(c)
  end


# Must use this approach to share the methods because the methods already
# defined in a class override those defined in an included module
  CustomEventCommands=<<_END_

  def command_352
    scene=PokemonSaveScene.new
    screen=PokemonSave.new(scene)
    screen.pbSaveScreen
    return true
  end

  def command_125
    value = operate_value(pbParams[0], pbParams[1], pbParams[2])
    $Trainer.money+=value
    return true
  end

  def command_132
    $PokemonGlobal.nextBattleBGM=(pbParams[0]) ? pbParams[0].clone : nil
    return true
  end

  def command_133
    $PokemonGlobal.nextBattleME=(pbParams[0]) ? pbParams[0].clone : nil
    return true
  end

  def command_353
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn(99999){ Kernel.pbStartOver(true) }
  end

  def command_314
    if pbParams[0] == 0 && $Trainer && $Trainer.party
      pbHealAll()
    end
    return true
  end

_END_
end



class Interpreter
  include InterpreterFieldMixin
  eval(InterpreterFieldMixin::CustomEventCommands)
end



class Game_Interpreter
  include InterpreterFieldMixin
  eval(InterpreterFieldMixin::CustomEventCommands)
end



################################################################################
#
################################################################################
class Transient
  def initialize(value)
    @value=value
  end

  attr_accessor :value

  def self._load(str)
    return Transient.new(nil)
  end

  def _dump(*arg)
    return ""
  end
end