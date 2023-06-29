class SpriteMetafile
  VIEWPORT      = 0
  TONE          = 1
  SRC_RECT      = 2
  VISIBLE       = 3
  X             = 4
  Y             = 5
  Z             = 6
  OX            = 7
  OY            = 8
  ZOOM_X        = 9
  ZOOM_Y        = 10
  ANGLE         = 11
  MIRROR        = 12
  BUSH_DEPTH    = 13
  OPACITY       = 14
  BLEND_TYPE    = 15
  COLOR         = 16
  FLASHCOLOR    = 17
  FLASHDURATION = 18
  BITMAP        = 19

  def length
    return @metafile.length
  end

  def [](i)
    return @metafile[i]
  end

  def initialize(viewport=nil)
    @metafile=[]
    @values=[
       viewport,
       Tone.new(0,0,0,0),Rect.new(0,0,0,0),
       true,
       0,0,0,0,0,100,100,
       0,false,0,255,0,
       Color.new(0,0,0,0),Color.new(0,0,0,0),
       0
    ]
  end

  def disposed?
    return false
  end

  def dispose
  end

  def flash(color,duration)
    if duration>0
      @values[FLASHCOLOR]=color.clone
      @values[FLASHDURATION]=duration
      @metafile.push([FLASHCOLOR,color])
      @metafile.push([FLASHDURATION,duration])
    end
  end

  def x
    return @values[X]
  end

  def x=(value)
    @values[X]=value
    @metafile.push([X,value])
  end

  def y
    return @values[Y]
  end

  def y=(value)
    @values[Y]=value
    @metafile.push([Y,value])
  end

  def bitmap
    return nil
  end

  def bitmap=(value)
    if value && !value.disposed?
      @values[SRC_RECT].set(0,0,value.width,value.height)
      @metafile.push([SRC_RECT,@values[SRC_RECT].clone])
    end
  end

  def src_rect
    return @values[SRC_RECT]
  end

  def src_rect=(value)
    @values[SRC_RECT]=value
   @metafile.push([SRC_RECT,value])
 end

  def visible
    return @values[VISIBLE]
  end

  def visible=(value)
    @values[VISIBLE]=value
    @metafile.push([VISIBLE,value])
  end

  def z
    return @values[Z]
  end

  def z=(value)
    @values[Z]=value
    @metafile.push([Z,value])
  end

  def ox
    return @values[OX]
  end

  def ox=(value)
    @values[OX]=value
    @metafile.push([OX,value])
  end

  def oy
    return @values[OY]
  end

  def oy=(value)
    @values[OY]=value
    @metafile.push([OY,value])
  end

  def zoom_x
    return @values[ZOOM_X]
  end

  def zoom_x=(value)
    @values[ZOOM_X]=value
    @metafile.push([ZOOM_X,value])
  end

  def zoom_y
    return @values[ZOOM_Y]
  end

  def zoom_y=(value)
    @values[ZOOM_Y]=value
    @metafile.push([ZOOM_Y,value])
  end

  def angle
    return @values[ANGLE]
  end

  def angle=(value)
    @values[ANGLE]=value
    @metafile.push([ANGLE,value])
  end

  def mirror
    return @values[MIRROR]
  end

  def mirror=(value)
    @values[MIRROR]=value
    @metafile.push([MIRROR,value])
  end

  def bush_depth
    return @values[BUSH_DEPTH]
  end

  def bush_depth=(value)
    @values[BUSH_DEPTH]=value
    @metafile.push([BUSH_DEPTH,value])
  end

  def opacity
    return @values[OPACITY]
  end

  def opacity=(value)
    @values[OPACITY]=value
    @metafile.push([OPACITY,value])
  end

  def blend_type
    return @values[BLEND_TYPE]
  end

  def blend_type=(value)
    @values[BLEND_TYPE]=value
    @metafile.push([BLEND_TYPE,value])
  end

  def color
    return @values[COLOR]
  end

  def color=(value)
    @values[COLOR]=value.clone
    @metafile.push([COLOR,@values[COLOR]])
  end

  def tone
    return @values[TONE]
  end

  def tone=(value)
    @values[TONE]=value.clone
    @metafile.push([TONE,@values[TONE]])
  end

  def update
    @metafile.push([-1,nil])
  end
end



class SpriteMetafilePlayer
  def initialize(metafile,sprite=nil)
    @metafile=metafile
    @sprites=[]
    @playing=false
    @index=0
    @sprites.push(sprite) if sprite
  end

  def add(sprite)
    @sprites.push(sprite)
  end

  def playing?
    return @playing
  end

  def play
    @playing=true
    @index=0
  end

  def update
    if @playing
      for j in @index...@metafile.length
        @index=j+1
        break if @metafile[j][0]<0
        code=@metafile[j][0]
        value=@metafile[j][1]
        for sprite in @sprites
          sprite.x=value if code==SpriteMetafile::X
          sprite.y=value if code==SpriteMetafile::Y
          sprite.src_rect=value if code==SpriteMetafile::SRC_RECT
          sprite.visible=value if code==SpriteMetafile::VISIBLE
          sprite.z=value if code==SpriteMetafile::Z
          sprite.ox=value if code==SpriteMetafile::OX
          sprite.oy=value if code==SpriteMetafile::OY
          sprite.zoom_x=value if code==SpriteMetafile::ZOOM_X
          sprite.zoom_y=value if code==SpriteMetafile::ZOOM_Y
          # prevent crashes
          sprite.angle=(value==180) ? 179.9 : value if code==SpriteMetafile::ANGLE
          sprite.mirror=value if code==SpriteMetafile::MIRROR
          sprite.bush_depth=value if code==SpriteMetafile::BUSH_DEPTH
          sprite.opacity=value if code==SpriteMetafile::OPACITY
          sprite.blend_type=value if code==SpriteMetafile::BLEND_TYPE
          sprite.color=value if code==SpriteMetafile::COLOR
          sprite.tone=value if code==SpriteMetafile::TONE
        end
      end
      @playing=false if @index==@metafile.length
    end
  end
end



def pbSaveSpriteState(sprite)
  state=[]
  return state if !sprite || sprite.disposed?
  state[SpriteMetafile::BITMAP]     = sprite.x
  state[SpriteMetafile::X]          = sprite.x
  state[SpriteMetafile::Y]          = sprite.y
  state[SpriteMetafile::SRC_RECT]   = sprite.src_rect.clone
  state[SpriteMetafile::VISIBLE]    = sprite.visible
  state[SpriteMetafile::Z]          = sprite.z
  state[SpriteMetafile::OX]         = sprite.ox
  state[SpriteMetafile::OY]         = sprite.oy
  state[SpriteMetafile::ZOOM_X]     = sprite.zoom_x
  state[SpriteMetafile::ZOOM_Y]     = sprite.zoom_y
  state[SpriteMetafile::ANGLE]      = sprite.angle
  state[SpriteMetafile::MIRROR]     = sprite.mirror
  state[SpriteMetafile::BUSH_DEPTH] = sprite.bush_depth
  state[SpriteMetafile::OPACITY]    = sprite.opacity
  state[SpriteMetafile::BLEND_TYPE] = sprite.blend_type
  state[SpriteMetafile::COLOR]      = sprite.color.clone
  state[SpriteMetafile::TONE]       = sprite.tone.clone
  return state
end

def pbRestoreSpriteState(sprite,state)
  return if !state || !sprite || sprite.disposed?
  sprite.x          = state[SpriteMetafile::X]
  sprite.y          = state[SpriteMetafile::Y]
  sprite.src_rect   = state[SpriteMetafile::SRC_RECT]
  sprite.visible    = state[SpriteMetafile::VISIBLE]
  sprite.z          = state[SpriteMetafile::Z]
  sprite.ox         = state[SpriteMetafile::OX]
  sprite.oy         = state[SpriteMetafile::OY]
  sprite.zoom_x     = state[SpriteMetafile::ZOOM_X]
  sprite.zoom_y     = state[SpriteMetafile::ZOOM_Y]
  sprite.angle      = state[SpriteMetafile::ANGLE]
  sprite.mirror     = state[SpriteMetafile::MIRROR]
  sprite.bush_depth = state[SpriteMetafile::BUSH_DEPTH]
  sprite.opacity    = state[SpriteMetafile::OPACITY]
  sprite.blend_type = state[SpriteMetafile::BLEND_TYPE]
  sprite.color      = state[SpriteMetafile::COLOR]
  sprite.tone       = state[SpriteMetafile::TONE]
end

def pbSaveSpriteStateAndBitmap(sprite)
  return [] if !sprite || sprite.disposed?
  state=pbSaveSpriteState(sprite)
  state[SpriteMetafile::BITMAP]=sprite.bitmap
  return state
end

def pbRestoreSpriteStateAndBitmap(sprite,state)
  return if !state || !sprite || sprite.disposed?
  sprite.bitmap=state[SpriteMetafile::BITMAP]
  pbRestoreSpriteState(sprite,state)
  return state
end



#####################

class PokemonEvolutionScene
  private

  def pbGenerateMetafiles(s1x,s1y,s2x,s2y)
    tempFrameRate=40#Graphics.frame_rate
    sprite=SpriteMetafile.new
    sprite2=SpriteMetafile.new
    sprite.opacity=255
    sprite2.opacity=0
    sprite.ox=s1x
    sprite.oy=s1y
    sprite2.ox=s2x
    sprite2.oy=s2y
    for j in 0...26
      sprite.color.red=128
      sprite.color.green=0 
      sprite.color.blue=0
      sprite.color.alpha=j*10
      sprite.color=sprite.color
      sprite2.color=sprite.color
      sprite.update
      sprite2.update
    end
    anglechange=0
    sevenseconds=tempFrameRate*7
    for j in 0...sevenseconds
      sprite.angle+=anglechange
      sprite.angle%=360
      anglechange+=1 if j%2==0
      if j>=sevenseconds-50
        sprite2.angle=sprite.angle
        sprite2.opacity+=6
      end
      sprite.update
      sprite2.update
    end
    sprite.angle=360-sprite.angle
    sprite2.angle=360-sprite2.angle
    for j in 0...sevenseconds
      sprite2.angle+=anglechange
      sprite2.angle%=360
      anglechange-=1 if j%2==0
      if j<50
        sprite.angle=sprite2.angle
        sprite.opacity-=6
      end
      sprite.update
      sprite2.update
    end
    for j in 0...26
      sprite2.color.red=128
      sprite2.color.green=0 
      sprite2.color.blue=0
      sprite2.color.alpha=(26-j)*10
      sprite2.color=sprite2.color
      sprite.color=sprite2.color
      sprite.update
      sprite2.update
    end
    @metafile1=sprite
    @metafile2=sprite2
  end

# Starts the evolution screen with the given Pokemon and new Pokemon species.
  public

  def pbStartScreen(pokemon,newspecies)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @pokemon=pokemon
    @newspecies=newspecies
    addBackgroundOrColoredPlane(@sprites,"background","evolutionbg",
       Color.new(248,248,248),@viewport)
    rsprite1=PokemonSprite.new(@viewport)
    rsprite2=PokemonSprite.new(@viewport)
    rsprite1.setPokemonBitmap(@pokemon,false)
    rsprite2.setPokemonBitmapSpecies(@pokemon,@newspecies,false)
    rsprite1.ox=rsprite1.bitmap.width/2
    rsprite1.oy=rsprite1.bitmap.height/2
    rsprite2.ox=rsprite2.bitmap.width/2
    rsprite2.oy=rsprite2.bitmap.height/2
    rsprite1.x=Graphics.width/2
    rsprite1.y=(Graphics.height-96)/2
    rsprite2.x=Graphics.width/2
    rsprite2.y=(Graphics.height-96)/2
    rsprite2.opacity=0
    @sprites["rsprite1"]=rsprite1
    @sprites["rsprite2"]=rsprite2
    pbGenerateMetafiles(rsprite1.ox,rsprite1.oy,rsprite2.ox,rsprite2.oy)
    @sprites["msgwindow"]=Kernel.pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)
  end

# Closes the evolution screen.
  def pbEndScreen
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"])
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

# Opens the evolution screen
  def pbEvolution(cancancel=true)
    metaplayer1=SpriteMetafilePlayer.new(@metafile1,@sprites["rsprite1"])
    metaplayer2=SpriteMetafilePlayer.new(@metafile2,@sprites["rsprite2"])
    metaplayer1.play
    metaplayer2.play
    pbBGMStop()
    pbPlayCry(@pokemon)
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
       _INTL("\\se[]What?\r\n{1} is evolving!\\^",@pokemon.name))
    Kernel.pbMessageWaitForInput(@sprites["msgwindow"],100,true)
    pbPlayDecisionSE()
    oldstate=pbSaveSpriteState(@sprites["rsprite1"])
    oldstate2=pbSaveSpriteState(@sprites["rsprite2"])
    pbBGMPlay("evolv")
    canceled=false
    begin
      metaplayer1.update
      metaplayer2.update
      Graphics.update
      Input.update
      if Input.trigger?(Input::B) && cancancel
        canceled=true
        pbRestoreSpriteState(@sprites["rsprite1"],oldstate)
        pbRestoreSpriteState(@sprites["rsprite2"],oldstate2)
        Graphics.update 
        break
      end
    end while metaplayer1.playing? && metaplayer2.playing?
    if canceled
      pbBGMStop()
      pbPlayCancelSE()
      Kernel.pbMessageDisplay(@sprites["msgwindow"],
         _INTL("Huh?\r\n{1} stopped evolving!",@pokemon.name))
         return false
    else
      begin
        frames=pbCryFrameLength(@newspecies)
      rescue
         frames=5
      end
       
      pbBGMStop()
      pbPlayCry(@newspecies)
      frames.times do
        Graphics.update
      end
      pbMEPlay("004-Victory04")
      newspeciesname=PBSpecies.getName(@newspecies)
      oldspeciesname=PBSpecies.getName(@pokemon.species)
      Kernel.pbMessageDisplay(@sprites["msgwindow"],
         _INTL("\\se[]Congratulations!  Your {1} evolved into {2}!\\wt[80]",@pokemon.name,newspeciesname))
      @sprites["msgwindow"].text=""
      removeItem=false
      if @pokemon.species==PBSpecies::DELTAGRIMER && @pokemon.abilityIndex==1
        abil=rand(6)
        @pokemon.form=abil + 1
      elsif @pokemon.species==PBSpecies::DELTAGRIMER && @pokemon.abilityIndex!=1
        @pokemon.form=0
      end
      createSpecies=pbCheckEvolutionEx(@pokemon){|pokemon,evonib,level,poke|
         if evonib==14 && !$game_switches[346] && !$game_switches[347] # Shedinja
           if $PokemonBag.pbQuantity(getConst(PBItems,:POKEBALL))>0
             next poke
           end
           next -1
         elsif evonib==6 || evonib==18 || evonib==19 # Evolves if traded with item/holding item
           if poke==@newspecies
             removeItem=true  # Item is now consumed
           end
           next -1
         else
           next -1
         end
      }
      @pokemon.item=0 if removeItem
      if isConst?(@newspecies,PBSpecies,:NINJASK) && ($game_switches[346] || $game_switches[347])
        if Kernel.pbConfirmMessage("Would you like to use Shedinja instead of Ninjask?")
        pokemon.species=PBSpecies::SHEDINJA  
        end
      end
      @pokemon.species=@newspecies
      $Trainer.seen[@newspecies]=true
      $Trainer.owned[@newspecies]=true
      pbSeenForm(@pokemon)
      @pokemon.name=newspeciesname if @pokemon.name==oldspeciesname
      @pokemon.calcStats
      # Check moves for new species
      movelist=@pokemon.getMoveList
      for i in movelist
        if i[0]==@pokemon.level          # Learned a new move
          pbLearnMove(@pokemon,i[1],true)
        end
      end
      if createSpecies>0 && $Trainer.party.length<6
        newpokemon=@pokemon.clone
        newpokemon.iv=@pokemon.iv.clone
        newpokemon.ev=@pokemon.ev.clone
        newpokemon.moves=@pokemon.moves.clone
        newpokemon.species=createSpecies
        newpokemon.name=PBSpecies.getName(createSpecies)
        newpokemon.item=0
        newpokemon.clearAllRibbons
        newpokemon.markings=0
        newpokemon.ballused=0
        newpokemon.calcStats
        newpokemon.heal
        $Trainer.party.push(newpokemon)
        $Trainer.seen[createSpecies]=true
        $Trainer.owned[createSpecies]=true
        pbSeenForm(newpokemon)
        $PokemonBag.pbDeleteItem(getConst(PBItems,:POKEBALL))
      end
      $PokemonTemp.dependentEvents.refresh_sprite
      return true

    end
  end
end



def pbMiniCheckEvolution(pokemon,evonib,level,poke)
  case evonib
    when 1 # Evolves if happy enough
      return poke if pokemon.happiness>=175
    when 2 # Evolves during the day if happy enough
      return poke if pokemon.happiness>=175 && PBDayNight.isDay?(pbGetTimeNow)
    when 3 # Evolves at night if happy enough
      return poke if pokemon.happiness>=175 && PBDayNight.isNight?(pbGetTimeNow)
    when 4 # Evolves on level up
      return poke if pokemon.level>=level
    when 5, 6 # Evolves if traded, without/with held item
      return -1
    when 8 # Hitmonlee
      return poke if pokemon.level>=level && pokemon.attack>pokemon.defense
    when 9 # Hitmontop
      return poke if pokemon.level>=level && pokemon.attack==pokemon.defense
    when 10 # Hitmonchan
      return poke if pokemon.level>=level && pokemon.attack<pokemon.defense
    when 11 # Silcoon
      return poke if pokemon.level>=level && (((pokemon.personalID>>16)&0xFFFF)%10)<5
    when 12 # Cascoon
      return poke if pokemon.level>=level && (((pokemon.personalID>>16)&0xFFFF)%10)>=5
    when 13 # Ninjask
      return poke if pokemon.level>=level
    when 14 # Shedinja
      return -1
    when 15 # Feebas
      return poke if pokemon.beauty>=level
    when 18 # Evolves during the day if holding item
      return poke if pokemon.item==level && PBDayNight.isDay?(pbGetTimeNow)
    when 19 # Evolves at night if holding item
      return poke if pokemon.item==level && PBDayNight.isNight?(pbGetTimeNow)
    when 20 # Evolves if it has move
      for i in 0...4
        return poke if pokemon.moves[i].id==level
      end
    when 21 # Evolves if there is species
      for i in $Trainer.party
        return poke if !i.egg? && i.species==level
      end
    when 22 # Evolves if male
      return poke if pokemon.level>=level && pokemon.gender==0
    when 23 # Evolves if female
      return poke if pokemon.level>=level && pokemon.gender==1
    when 24 # Evolves on a certain map
      return poke if $game_map.map_id==level
    when 25 # Evolves if traded for a certain species
      return -1
    when 26 # Custom 1
      # Add code for custom evolution type 1
    when 27 # Custom 2
      # Add code for custom evolution type 2
    when 28 # Custom 3
      # Add code for custom evolution type 3
    when 29 # Custom 4
      # Add code for custom evolution type 4
    when 30 # Custom 5
      # Add code for custom evolution type 5
    when 31 # Custom 6
      # Add code for custom evolution type 6
    when 32 # Custom 7
      fairy=false
      for i in 0..3
        if pokemon.moves[i].type==PBTypes::FAIRY
          fairy=true
          break
        end
      end
      return poke if pokemon.happiness>=175 && fairy
    when 33 #unhappiness
      return poke if pokemon.happiness<=30
    when 34 #LevelDay
      return poke if pokemon.level>=level && PBDayNight.isDay?(pbGetTimeNow)
    when 35 #LevelNight
      return poke if pokemon.level>=level && PBDayNight.isNight?(pbGetTimeNow)
    when 36 #LevelRain
      return poke if pokemon.level>=level && $game_screen.weather_type==1 || 
                     $game_screen.weather_type==2
    when 37 #LevelDarkInParty
      if pokemon.level>=level
        for i in $Trainer.pokemonParty
          return poke if i.hasType?(:DARK)
        end
      end
  end
  return -1
end

def pbMiniCheckEvolutionItem(pokemon,evonib,level,poke,item) # :nodoc:
  case evonib
    when 7 # Evolves when item used on it (e.g. evolution stone)
      return poke if level==item
    when 16 # Evolves when item used on it if male
      return poke if level==item && pokemon.gender==0
    when 17 # Evolves when item used on it if female
      return poke if level==item && pokemon.gender==1
  end
  return -1
end

# Checks whether a Pokemon can evolve now. If a block is given, calls the block
# with the following parameters:
#  Pokemon to check; evolution type; level or other parameter; ID of the new Pokemon species
def pbCheckEvolutionEx(pokemon)
  return -1 if isConst?(pokemon.item,PBItems,:EVERSTONE)
  return -1 if isConst?(pokemon.item,PBItems,:EEVITE) && isConst?(pokemon.species,PBSpecies,:EEVEE)
  if isConst?(pokemon.species,PBSpecies,:EEVEE)
    blacklist=[
      :FIREBLAST,:FLAREBLITZ, # Flareon
      :THUNDERBOLT,:VOLTSWITCH, # Jolteon
      :HYDROPUMP,:SCALD, # VAPOREON
      :FOULPLAY,:PURSUIT, # UMBREON
      :PSYCHIC,:PSYSHOCK, # ESPEON
      :LEAFBLADE,:GIGADRAIN, # LEAFEON
      :ICEBEAM,:BLIZZARD, # GLACEON
      :MOONBLAST,:DAZZLINGGLEAM, # Flareon
      :GIGAIMPACT, # Mega Eevee
    ]
    for i in pokemon.moves
      for j in blacklist
        if isConst?(i.id,PBMoves,j)
          return -1
        end
      end
    end
  end
  if isConst?(pokemon.species,PBSpecies,:FLOETTE) && pokemon.form==5
    return -1
  end
    
  return -1 if isConst?(pokemon.item,PBItems,:EEVITE) && isConst?(pokemon.species,PBSpecies,:EEVEE)
  return -1 if pokemon.species<=0 || pokemon.egg?
  ret=-1
  for form in pbGetEvolvedFormData(pokemon.species)
    ret=yield pokemon,form[0],form[1],form[2]
    break if ret>0
  end
  return ret
end

# Checks whether a Pokemon can evolve now. If an item is used on the Pokémon,
# checks whether the Pokemon can evolve with the given item.
def pbCheckEvolution(pokemon,item=0)
  if item==0
    return pbCheckEvolutionEx(pokemon){|pokemon,evonib,level,poke|
       next pbMiniCheckEvolution(pokemon,evonib,level,poke)
    }
  else
    return pbCheckEvolutionEx(pokemon){|pokemon,evonib,level,poke|
       next pbMiniCheckEvolutionItem(pokemon,evonib,level,poke,item)
    }
  end
end