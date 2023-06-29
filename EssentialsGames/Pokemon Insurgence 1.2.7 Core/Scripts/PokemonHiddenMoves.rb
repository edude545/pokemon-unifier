class MoveHandlerHash < HandlerHash
  def initialize
    super(:PBMoves)
  end
end



module HiddenMoveHandlers
  CanUseMove=MoveHandlerHash.new
  UseMove=MoveHandlerHash.new

  def self.addCanUseMove(item,proc)
    CanUseMove.add(item,proc)
  end

  def self.addUseMove(item,proc)
    UseMove.add(item,proc)
  end 

  def self.hasHandler(item)
    return CanUseMove[item]!=nil && UseMove[item]!=nil
  end

  def self.triggerCanUseMove(item,pokemon)
    # Returns whether move can be used
    if !CanUseMove[item]
      return false
    else
      return CanUseMove.trigger(item,pokemon)
    end
  end

  def self.triggerUseMove(item,pokemon)
    # Returns whether move was used
    if !UseMove[item]
      return false
    else
      return UseMove.trigger(item,pokemon)
    end
  end
end



def pbHiddenMoveAnimation(pokemon,megaEvolve=false,zoroarkopp=false,pikapad=false)
  return false if !pokemon && !pikapad
  #Kernel.pbMessage("ay")
  viewport=Viewport.new(0,0,0,0)
  continueThrough=0
  viewport.z=99999
  # viewport2=Viewport.new(0,0,0,0)
  # viewport2.z=100000
  # Kernel.pbMessage("ay2")

  ptinterp=nil
  plane=ColoredPlane.new(Color.new(0,0,0,255),viewport)
  pbPlayTaxi if pikapad
  
    #Kernel.pbMessage("a3")
  if !pikapad
    sprite=PokemonSprite.new
    sprite.z=99999
    #if zoroarkopp
      #sprite.setPokemonBitmap($illusionpoke)
    #else
      sprite.setPokemonBitmap(pokemon)
      if megaEvolve
        pokemon.primalBattle(true)
        pokemon.normalMegaMewtwoX(true) if isConst?(pokemon.species,PBSpecies,:MEWTWO) && pokemon.isNormalMewtwo?
        pokemon.normalMegaMewtwoY(true) if isConst?(pokemon.species,PBSpecies,:MEWTWO) && pokemon.isNormalMewtwo?
        pokemon.megaTyranitar(true) if isConst?(pokemon.species,PBSpecies,:TYRANITAR)
        pokemon.megaFlygon(true) if isConst?(pokemon.species,PBSpecies,:FLYGON)
      end
    #end
  else
    sprite = IconSprite.new(0,0)
    sprite.z=99999
    sprite.setBitmap("Graphics/Pictures/pikapadAnimation")
  end
  # Kernel.pbMessage("ay4")

  sprite.visible=false
  sprite.ox=sprite.bitmap.width/2
  sprite.oy=sprite.bitmap.height/2
  megaSymbol0=IconSprite.new(0,0)
  megaSymbol0.z=100000
  megaSymbol0.setBitmap("Graphics/Animations/mega_0")
  megaSymbol0.opacity=0
  megaSymbol0.ox=megaSymbol0.bitmap.width/2
  megaSymbol1=IconSprite.new(0,0)
  megaSymbol1.z=100000
  megaSymbol1.setBitmap("Graphics/Animations/mega_1")
  megaSymbol1.opacity=0
  megaSymbol1.ox=megaSymbol1.bitmap.width/2
  #Kernel.pbMessage("ay5")

  megaSymbol0.x=(Graphics.width/2)#-(megaSymbol0.width/2)
  megaSymbol0.y=(Graphics.height/2)-(megaSymbol0.bitmap.height/2)#(Graphics.height/2)#-(megaSymbol0.height/2)

  megaSymbol1.x=(Graphics.width/2)#-(megaSymbol0.width/2)
  megaSymbol1.y=(Graphics.height/2)-(megaSymbol1.bitmap.height/2)#(Graphics.height/2)#-(megaSymbol0.height/2)
 # Kernel.pbMessage("ay6")


  interp=RectInterpolator.new(
     Rect.new(0,Graphics.height/2,Graphics.width,0),
     Rect.new(0,(Graphics.height-sprite.bitmap.height)/2,Graphics.width,sprite.bitmap.height),
     15)
  strobes=[]
  15.times do |i|
    strobe=BitmapSprite.new(80,8,viewport)
    strobe.bitmap.fill_rect(0,0,80,8,Color.new(248,248,248))
    strobe.visible=false
    strobes.push(strobe)
  end
  phase=1
  frames=0
  begin
    Graphics.update
    Input.update
    case phase
      when 1
        interp.update
        interp.set(viewport.rect)
        if interp.done?
          phase=2
          ptinterp=PointInterpolator.new(
             Graphics.width+(sprite.bitmap.width/2),Graphics.height/2,
             Graphics.width/2,Graphics.height/2,
             15)
           end
          #   Kernel.pbMessage("ay7")

      when 2
        ptinterp.update
        sprite.x=ptinterp.x
        sprite.y=ptinterp.y
        sprite.visible=true
        if ptinterp.done?
          phase=3
          #if zoroarkopp
            #pbPlayCry($illusionpoke.species)
          #else
            pbPlayCry(pokemon)
          #end
          
          frames=0
        end
      when 3
        frames+=1
        if frames>30
          phase=4
          ptinterp=PointInterpolator.new(
             Graphics.width/2,Graphics.height/2,
             -(sprite.bitmap.width/2),Graphics.height/2,
             15)
          frames=0
        end
        #  Kernel.pbMessage("ay8")

      when 4
        continueThrough+=1
        #  raise "stop"
        if megaEvolve && continueThrough<85     # Frames 1-175
          if continueThrough<25                    # Frames 1-50 
            megaSymbol0.opacity += 20
          elsif continueThrough <60               # 
          
          else
            megaSymbol0.opacity -= 10           # Frames 100-175
          end          
        elsif megaEvolve && continueThrough<220
          if continueThrough<110                   #200 - 220, fade in of ega symbol
            megaSymbol1.opacity += 20
          elsif continueThrough<215
            if continueThrough>150                # Frames 240-285, the fadeout of t
              megaSymbol1.opacity -= 30
            end
            if continueThrough==130                 # Frame 220 - the actual change
              #if zoroarkopp
              #  tempbackup=$illusionpoke.clone
              #  $illusionpoke.form=1
              #  $illusionpoke.form=2 if $illusionpoke.species==PBSpecies::MEWTWO || $illusionpoke.species==PBSpecies::FLYGON
              #  sprite.setPokemonBitmap($illusionpoke)#.clone)
              #  pokemon.form=1
              #  $illusionpoke.form=0
              #  $illusionpoke=tempbackup

              #else
                saveform=pokemon.form

                pokemon.form=1
                pokemon.form=2 if isConst?(pokemon.item,PBItems,:STEELIXITE)
                pokemon.form=2 if isConst?(pokemon.item,PBItems,:CHARIZARDITEY) || (isConst?(pokemon.item,PBItems,:MEWTWONITEX) && saveform!=4) || 
                #pokemon.form=2 if isConst?(pokemon.item,PBItems,:CHARIZARDITEY) || isConst?(pokemon.item,PBItems,:MEWTWONITEX) || 
                                  isConst?(pokemon.item,PBItems,:FLYGONITE) || (isConst?(pokemon.species,PBSpecies,:SUNFLORA) && pokemon.gender==1)
                pokemon.form=3 if isConst?(pokemon.item,PBItems,:MEWTWONITEY) && saveform!=4
                pokemon.form=3 if saveform==2 && isConst?(pokemon.species,PBSpecies,:GARDEVOIR)
                pokemon.form=3 if saveform==2 && isConst?(pokemon.species,PBSpecies,:LUCARIO)
                if isConst?(pokemon.species,PBSpecies,:GIRATINA)
                  pokemon.form=2 
                end
                pokemon.form=19 if isConst?(pokemon.species,PBSpecies,:ARCEUS)
                pokemon.form=2 if isConst?(pokemon.species,PBSpecies,:DELTAMETAGROSS2) && isConst?(pokemon.item,PBItems,:CRYSTALFRAGMENT)
                if saveform==4 && isConst?(pokemon.species,PBSpecies,:MEWTWO)
                  pokemon.form=5 
                end
                sprite.setPokemonBitmap(pokemon)
              #end
            end
          end
          #   Kernel.pbMessage("ay10")

          #  megaSymbol.x -= (megaSymbol.bitmap.width*0.015).floor
          megaSymbol1.y -= (megaSymbol1.bitmap.width*0.02).floor
          megaSymbol1.zoom_x += 0.03
          megaSymbol1.zoom_y += 0.03
              

          #          end
        else
          ptinterp.update
          sprite.x=ptinterp.x
          sprite.y=ptinterp.y
          if ptinterp.done?
            phase=5
            sprite.visible=false
            interp=RectInterpolator.new(
               Rect.new(0,(Graphics.height-sprite.bitmap.height)/2,Graphics.width,sprite.bitmap.height),
               Rect.new(0,(Graphics.height)/2,Graphics.width,0),
               15)
        end;end
      when 5
        interp.update
        interp.set(viewport.rect)
        phase=6 if interp.done?    
      end
    for strobe in strobes
      strobe.ox=strobe.viewport.rect.x
      strobe.oy=strobe.viewport.rect.y
      if strobe.visible && strobe.x+strobe.src_rect.width>=0
        strobe.x-=32
      elsif !strobe.visible
        randomY=12+16*rand(sprite.bitmap.height/16-1)
        strobe.y=randomY+(Graphics.height-sprite.bitmap.height)/2
        strobe.x=rand(Graphics.width)
        strobe.src_rect.width=20+rand(40)
        strobe.visible=true
      else
        randomY=12+16*rand(sprite.bitmap.height/16-1)
        strobe.y=randomY+(Graphics.height-sprite.bitmap.height)/2
        strobe.x=Graphics.width+rand(Graphics.width/4)
        strobe.src_rect.width=20+rand(40)
      end
    end
    pbUpdateSceneMap
  end while phase!=6
  sprite.dispose
  for strobe in strobes
    strobe.dispose
  end
  strobes.clear
  plane.dispose
  viewport.dispose
  return true
end

#===============================================================================
# Cut
#===============================================================================
def Kernel.pbCut
  if $DEBUG || ($game_switches[6])
    movefinder=Kernel.pbCheckMove(:CUT)
    if $DEBUG || movefinder
      Kernel.pbMessage(_INTL("This tree looks like it can be cut down!\1"))
      if Kernel.pbConfirmMessage(_INTL("Would you like to cut it?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Cut!",speciesname))
        pbHiddenMoveAnimation(movefinder)
        return true
      end
    else
      Kernel.pbMessage(_INTL("This tree looks like it can be cut down."))
    end
  else
    Kernel.pbMessage(_INTL("This tree looks like it can be cut down."))
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:CUT,proc{|move,pkmn|
   if !$DEBUG &&
      !$game_switches[6]
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Tree"
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:CUT,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     facingEvent.erase
     $PokemonMap.addErasedEvent(facingEvent.id)
   end
   return true
})

#===============================================================================
# Headbutt
#===============================================================================
def Kernel.pbHeadbuttEffect(event)
  a=((event.x*event.y+event.x*event.y)/5)%10
  b=($Trainer.id&0xFFFF)%10
  chance=1
  if a==b
    chance=8
  elsif a>b && (a-b).abs<5
    chance=5
  elsif a<b && (a-b).abs>5
    chance=5
  end
 # if rand(10)>=chance
 #   Kernel.pbMessage(_INTL("Nope.  Nothing..."))
 # else
    if !pbEncounter(chance==1 ? EncounterTypes::HeadbuttLow : EncounterTypes::HeadbuttHigh)
      Kernel.pbMessage(_INTL("Nope.  Nothing..."))
    end
 # end
end

def Kernel.pbHeadbutt(event)
  movefinder=Kernel.pbCheckMove(:HEADBUTT)
  if $DEBUG || movefinder
    if Kernel.pbConfirmMessage(_INTL("Want to headbutt it?"))
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} did a headbutt!",speciesname))
      pbHiddenMoveAnimation(movefinder)
      #Kernel.pbHeadbuttEffect(event)
      lvl=movefinder ? movefinder.level : 1
      pbWildBattle(PBSpecies::DELTATENTACOOL,lvl) if !$game_switches[525]
      $game_switches[525]=true
    end
  else
#    Kernel.pbMessage(_INTL("A Pokémon could be in this tree.  Maybe a Pokémon could shake it."))
  end
  Input.update
  return
end
def Kernel.pbDigWall(event)
  movefinder=Kernel.pbCheckMove(:DIG)
  if movefinder
    if Kernel.pbConfirmMessage(_INTL("Want to Dig through?"))
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} dug through the wall!",speciesname))
      pbHiddenMoveAnimation(movefinder)
      #Kernel.pbHeadbuttEffect(event)
      $game_switches[532]=true
      $game_map.need_refresh=true
      Kernel.pbMessage("A wall caved open!")
    end
  else
#    Kernel.pbMessage(_INTL("A Pokémon could be in this tree.  Maybe a Pokémon could shake it."))
  end
  Input.update
  return
end
HiddenMoveHandlers::CanUseMove.add(:HEADBUTT,proc{|move,pkmn|
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="HeadbuttTree"
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:HEADBUTT,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   Kernel.pbHeadbuttEffect(event)
})

#===============================================================================
# Rock Smash
#===============================================================================
def pbRockSmashRandomEncounter
  if rand(100)<25
    pbEncounter(EncounterTypes::RockSmash)
  end
end

def Kernel.pbRockSmash
  
  if $DEBUG || $game_switches[10]#$PokemonBag.pbQuantity(PBItems::PICKAXE) > 0 ||
    movefinder=Kernel.pbCheckMove(:ROCKSMASH)
    if $DEBUG || movefinder || $PokemonBag.pbQuantity(PBItems::PICKAXE) > 0
      if $PokemonBag.pbQuantity(PBItems::PICKAXE) > 0
        Kernel.pbMessage(_INTL("You could break this with your Pickaxe."))  
      else
        Kernel.pbMessage(_INTL("This rock appears breakable."))          
      end
      if Kernel.pbConfirmMessage(_INTL("Would you like to use Rock Smash?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Rock Smash!",speciesname))
        pbHiddenMoveAnimation(movefinder)
        return true
      end
    else
      Kernel.pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
    end
  else
    Kernel.pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH,proc{|move,pkmn|
   terrain=Kernel.pbFacingTerrainTag
   if !$DEBUG && !$game_switches[10]
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Rock"
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true  
})

HiddenMoveHandlers::UseMove.add(:ROCKSMASH,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     facingEvent.erase
     $PokemonMap.addErasedEvent(facingEvent.id)
   end
   return true  
})
=begin
HiddenMoveHandlers::CanUseMove.add(:HYPNOSIS,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})


HiddenMoveHandlers::CanUseMove.add(:GRASSWHISTLE,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:SLEEPPOWDER,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:SPORE,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:SING,proc{|move,pkmn|
  return Kernel.pbCanUseHypnosis(move,pkmn)
})
=end
HiddenMoveHandlers::CanUseMove.add(:WHIRLWIND,proc{|move,pkmn|
  return Kernel.pbCanUseWhirlwind(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:ROAR,proc{|move,pkmn|
  return Kernel.pbCanUseWhirlwind(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:MILKDRINK,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:RECOVER,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:SLACKOFF,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:ROOST,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:SYTNHESIS,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

HiddenMoveHandlers::CanUseMove.add(:MORNINGSUN,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})
HiddenMoveHandlers::CanUseMove.add(:HEALORDER,proc{|move,pkmn|
  return Kernel.pbCanUseHealSelf(move,pkmn)
})

def Kernel.pbCanUseHypnosis(move,pkmn)
    ppcount=0
  for pps in pkmn.moves
    next if pps.id != move
      ppcount += pps.pp 
  end

     eventArray = $game_map.events.values
    useEvent=nil
    for event in eventArray
      if event.x < $game_player.x+2 && event.x > $game_player.x-2
         if event.y < $game_player.y+2 && event.y > $game_player.y-2
          if event.name.include?("Sleepy")
           useEvent=event
           break
          end
        end
      end
    end
    if useEvent==nil
     Kernel.pbMessage(_INTL("Can't use that here."))
   end
   return true  

end

def Kernel.pbCanUseHealSelf(move,pkmn)
#  Kernel.pbMessage("Ooooh")
  ppcount=0
  for pps in pkmn.moves
  next if pps.id != move
  ppcount += pps.pp 
  end
  if pkmn.hp >= pkmn.totalhp
    Kernel.pbMessage("Already fully healed.")
  end
  
  return false if pkmn.hp >= pkmn.totalhp
  return false if ppcount<=0
  return false if pkmn.hp<=0
  return true
end

def Kernel.pbCanUseWhirlwind(move,pkmn)
    ppcount=0
  for pps in pkmn.moves
     next if pps.id != move
      ppcount += pps.pp 
  end
  
  
  return false if ppcount==0

  return true
end










HiddenMoveHandlers::UseMove.add(:WHIRLWIND,proc{|move,pokemon|
    Kernel.pbWhirlwind(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:ROAR,proc{|move,pokemon|
    Kernel.pbWhirlwind(move,pokemon)
})


HiddenMoveHandlers::UseMove.add(:HYPNOSIS,proc{|move,pokemon|
     Kernel.pbHypnosis(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:GRASSWHISTLE,proc{|move,pokemon|
     Kernel.pbHypnosis(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:SLEEPPOWDER,proc{|move,pokemon|
     Kernel.pbHypnosis(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:SPORE,proc{|move,pokemon|
     Kernel.pbHypnosis(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:SING,proc{|move,pokemon|
     Kernel.pbHypnosis(move,pokemon)
})




HiddenMoveHandlers::UseMove.add(:RECOVER,proc{|move,pokemon|
     Kernel.pbHealSelf(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:ROOST,proc{|move,pokemon|
     Kernel.pbHealSelf(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:SLACKOFF,proc{|move,pokemon|
     Kernel.pbHealSelf(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:SYNTHESIS,proc{|move,pokemon|
     Kernel.pbHealSelf(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:MILKDRINK,proc{|move,pokemon|
     Kernel.pbHealSelf(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:MORNINGSUN,proc{|move,pokemon|
     Kernel.pbHealSelf(move,pokemon)
})
HiddenMoveHandlers::UseMove.add(:HEALORDER,proc{|move,pokemon|
     Kernel.pbHealSelf(move,pokemon)
})

def Kernel.pbHealSelf(move,pokemon)
  begin
    moveid=0
  for i in 0..pokemon.moves.length-1
    next if pokemon.moves[i].id != move
    moveid=i
  end

    if pokemon.hp>=pokemon.totalhp
      Kernel.pbMessage("HP full.")
      return false
    end
    
    pokemon.moves[moveid].pp-=1
    
    Kernel.pbMessage("Health was regained!")
    
    pokemon.hp += pokemon.totalhp/4
    
    pokemon.hp = pokemon.totalhp if pokemon.hp >= pokemon.totalhp
    return true
  
  rescue
  end
  
end

def Kernel.pbWhirlwind(move,pokemon)
  moveid=0
  for i in 0..pokemon.moves.length-1
    next if pokemon.moves[i].id != move
    moveid=i
  end
  if $PokemonGlobal.repel>0
    Kernel.pbMessage(_INTL("But the effects of a Repel lingered from earlier."))
    return false
  else
  if pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}! Wild Pokemon will not appear for 50 steps.",pokemon.name,PBMoves.getName(move)))
   end
        $PokemonGlobal.repel=50
        pokemon.moves[moveid].pp -= 1
    return true
  end

end

=begin
def Kernel.pbHypnosis(move,pokemon)
  
  if !pbHiddenMoveAnimation(pokemon)
    Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
  end
  eventArray = $game_map.events.values
  useEvent=nil
  for event2 in eventArray
    if event2.x < $game_player.x+2 && event2.x > $game_player.x-2
      if event2.y < $game_player.y+2 && event2.y > $game_player.y-2
        if event2.name.include?("Sleepy")
          useEvent=event2
          break
        end
      end
    end
  end
  $game_variables[52]=Array.new if !$game_variables[52].is_a?(Array)
  $game_variables[52].push(useEvent.id)
  character = pbMapInterpreter.get_character(useEvent.id)
  if character != nil
    # Set animation ID
    character.animation_id = 12
  end

      
  return true
end
=end
  

#===============================================================================
# Strength
#===============================================================================
def Kernel.pbStrength
  if $PokemonMap.strengthUsed
    Kernel.pbMessage(_INTL("It is possible to move boulders around."))
  elsif $DEBUG || ($game_switches[4])
    whichmove=0
    strengthary=[PBMoves::STRENGTH,PBMoves::BULLDOZE,PBMoves::STEAMROLLER,PBMoves::OMINOUSWIND,PBMoves::ICYWIND,
    PBMoves::GIGAIMPACT,PBMoves::SLAM,PBMoves::WHIRLWIND,PBMoves::ROCKTHROW,PBMoves::HEAVYSLAM,
    PBMoves::BARRAGE,PBMoves::PSYCHIC,PBMoves::HEADBUTT]
    hasMove=false
    movePokemon=0
    moveMove=0
 #3   for arrayint in strengthary
      for i in 0..$Trainer.party.length-1
        for j in 0..$Trainer.party[i].moves.length-1
          if strengthary.include?($Trainer.party[i].moves[j].id)
            hasMove=true
            movePokemon=i
            moveMove=$Trainer.party[i].moves[j].id
            break
          end
        end
        if hasMove
          break
        end
      end
      if !hasMove
       Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to move it aside."))
        return false
      end
   # end
    
    movename = PBMoves.getName(moveMove) #PBMoves.getName(getConst(PBMoves,strengthary[whichmove])) if movefinder
    if $Trainer.party[movePokemon]
      Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to move it aside."))
      if Kernel.pbConfirmMessage(_INTL("Would you like to use "+movename+"?"))
        speciesname=!$Trainer.party[movePokemon] ? $Trainer.name : $Trainer.party[movePokemon].name
        Kernel.pbMessage(_INTL("{1} used "+movename+"!\1",speciesname))
        pbHiddenMoveAnimation($Trainer.party[movePokemon])
        Kernel.pbMessage(_INTL("It is now possible to move boulders around!",speciesname))
        $PokemonMap.strengthUsed=true
        return true
      end
    else
      Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to move it aside."))
    end
  else
    Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to move it aside."))
  end
  return false
end

Events.onAction+=proc{|sender,e|
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     if facingEvent.name=="Boulder"
       Kernel.pbStrength
       return
     end
   end
}

HiddenMoveHandlers::CanUseMove.add(:STRENGTH,proc{|move,pkmn|
   if !$DEBUG &&
!$game_switches[4]     
Kernel.pbMessage(_INTL("Sorry, a new Badge is required.\nYou have {1} badges, and you need {2}.", $Trainer.numbadges, $Trainer.badges[BADGEFORSTRENGTH]))
     return false
   end
   if $PokemonMap.strengthUsed
     Kernel.pbMessage(_INTL("Strength is already being used."))
     return false
   end
   return true  
})

HiddenMoveHandlers::UseMove.add(:STRENGTH,proc{|move,pokemon|
   pbHiddenMoveAnimation(pokemon)
   Kernel.pbMessage(_INTL("{1} used {2}!\1",pokemon.name,PBMoves.getName(move)))
   Kernel.pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",pokemon.name))
   $PokemonMap.strengthUsed=true
   return true  
})

#===============================================================================
# Surf
#===============================================================================
def Kernel.pbSurf

  if ($DEBUG || $PokemonBag.pbQuantity(PBItems::LAPRAS) > 0 || movefinder=Kernel.pbCheckMove(:SURF)) && $game_switches[4]
    if ($DEBUG || movefinder || $PokemonBag.pbQuantity(PBItems::LAPRAS) > 0) && $game_switches[4]
      if $PokemonBag.pbQuantity(PBItems::LAPRAS) > 0
         Kernel.pbMessage(_INTL("The Instant Lapras pack is vibrating!"))
      else
        Kernel.pbMessage(_INTL("The water is dyed a deep blue..."))
      end
      if Kernel.pbConfirmMessage(_INTL("Would you like to surf?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Surf!",speciesname))
        pbHiddenMoveAnimation(movefinder)
        surfbgm=pbGetMetadata(0,MetadataSurfBGM)
        if surfbgm
          pbCueBGM(surfbgm,0.5)
        end
        pbStartSurfing()
        return true
      end
    end
  else
    Kernel.pbMessage(_INTL("The water is dyed a blue..."))
  end
  return false
end

def pbStartSurfing()
  Kernel.pbCancelVehicles
  Kernel.pbChangeBackToNormal
  $PokemonEncounters.clearStepCount
  $PokemonGlobal.surfing=true
  Kernel.pbUpdateVehicle
  Kernel.pbJumpToward
  Kernel.pbUpdateVehicle
  $game_player.check_event_trigger_here([1,2])
  $PokemonTemp.dependentEvents.refresh_sprite
end

def pbEndSurf(xOffset,yOffset)
  return false if !$PokemonGlobal.surfing
  x=$game_player.x
  y=$game_player.y
  currentTag=$game_map.terrain_tag(x,y)
  facingTag=Kernel.pbFacingTerrainTag
  if pbIsSurfableTag?(currentTag) && !pbIsSurfableTag?(facingTag)
    if Kernel.pbJumpToward
      Kernel.pbCancelVehicles
      $game_map.autoplayAsCue
      $game_player.increase_steps
      result=$game_player.check_event_trigger_here([1,2])
      Kernel.pbOnStepTaken(result)
    end
    return true
  end
  return false
end

Events.onAction+=proc{|sender,e|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,true)
   notCliff=false if $game_player.direction==8 && $game_map.passable?($game_player.x,$game_player.y-1,2,true)
   if (pbIsWaterTag?(terrain) || Kernel.pbSlimeCheck(terrain)) && !$PokemonGlobal.surfing && 
      !pbGetMetadata($game_map.map_id,MetadataBicycleAlways) && notCliff
   #    return false if $game_map.map_id == 381|| $game_map.map_id == 553 || $game_map.map_id == 563 || $game_map.map_id == 564  || $game_map.map_id == 374 || $game_map.map_id == 378  || $game_map.map_id == 180 #DRAGALGE

           if $PokemonBag.pbQuantity(PBItems::LAPRAS) > 0 && $game_switches[4]
         Kernel.pbMessage(_INTL("The Instant Lapras pack is vibrating!"))
      if Kernel.pbConfirmMessage(_INTL("Would you like to surf?"))
        Kernel.pbMessage(_INTL("Instant-Lapras used Surf!"))
        surfbgm=pbGetMetadata(0,MetadataSurfBGM)
        if surfbgm
          pbCueBGM(surfbgm,0.5)
        end
        pbStartSurfing()
        return true
      end

                 end
                 
     Kernel.pbSurf
     return
   end
}

HiddenMoveHandlers::CanUseMove.add(:SURF,proc{|move,pkmn|
   terrain=Kernel.pbFacingTerrainTag
   notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSURF : $Trainer.badges[BADGEFORSURF])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if $PokemonGlobal.surfing
     Kernel.pbMessage(_INTL("You're already surfing."))
     return false
   end

   if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
     Kernel.pbMessage(_INTL("Let's enjoy cycling!"))
     return false
   end
   if !pbIsWaterTag?(terrain) || !notCliff
     Kernel.pbMessage(_INTL("No surfing here!"))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:SURF,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   pbStartSurfing()
   return true
})

#===============================================================================
# Waterfall
#===============================================================================
def Kernel.pbAscendWaterfall(event=nil)
  event=$game_player if !event
  return if !event
  return if event.direction!=8 # can't ascend if not facing up
  oldthrough=event.through
  oldmovespeed=event.move_speed
  terrain=Kernel.pbFacingTerrainTag
  return if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  event.through=true
  event.move_speed=2
  loop do
    event.move_up
    terrain=pbGetTerrainTag(event)
    break if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  end
  event.through=oldthrough
  event.move_speed=oldmovespeed
end

def Kernel.pbDescendWaterfall(event=nil)
  event=$game_player if !event
  return if !event
  return if event.direction!=2 # Can't descend if not facing down
  oldthrough=event.through
  oldmovespeed=event.move_speed
  terrain=Kernel.pbFacingTerrainTag
 # Kernel.pbMessage(terrain.to_s)
  return if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  event.through=true
  event.move_speed=2
  loop do
    event.move_down
    terrain=pbGetTerrainTag(event)
    break if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  end
  event.through=oldthrough
  event.move_speed=oldmovespeed
end

def Kernel.pbAscendRockClimb(event=nil,force=false)
  event=$game_player if !event
  follower=Kernel.pbGetDependency("Dependent")
  return if !event
  return if event.direction!=8 # can't ascend if not facing up
  oldthrough=event.through
  oldfollowerthrough=follower.through
  oldmovespeed=event.move_speed
  terrain=Kernel.pbFacingTerrainTag
  return if terrain!=PBTerrain::RockClimb && !force
  event.through=true
  follower.through=true if event==$game_player
  event.move_speed=2
  follower.move_speed=2 if event==$game_player
  loop do
    event.move_up
    follower.move_up
    terrain=pbGetTerrainTag(event)
    break if terrain!=PBTerrain::RockClimb
  end
  event.through=oldthrough
  follower.through=oldfollowerthrough if event==$game_player
  event.move_up
  event.move_speed=oldmovespeed
  follower.move_speed=oldmovespeed if event==$game_player
end

def Kernel.pbDescendRockClimb(event=nil,force=false)
  event=$game_player if !event
  follower=Kernel.pbGetDependency("Dependent")
  return if !event
  return if event.direction!=2 # Can't descend if not facing down
  oldthrough=event.through
  oldfollowerthrough=follower.through
  oldmovespeed=event.move_speed
  terrain=Kernel.pbFacingTerrainTag
  return if terrain!=PBTerrain::RockClimb && !force
  event.through=true
  follower.through=true if event==$game_player
  event.move_speed=2
  follower.move_speed=2 if event==$game_player
  loop do
    event.move_down
    follower.move_down
    terrain=pbGetTerrainTag(event)
    break if terrain!=PBTerrain::RockClimb
  end
  event.through=oldthrough
  follower.through=oldfollowerthrough if event==$game_player
  event.move_down
  event.move_speed=oldmovespeed
  follower.move_speed=oldmovespeed if event==$game_player
end

def Kernel.pbWaterfall
  if $DEBUG ||  (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORWATERFALL : $Trainer.badges[BADGEFORWATERFALL])
    movefinder=Kernel.pbCheckMove(:WATERFALL)
    if $PokemonBag.pbQuantity(PBItems::JETPACK) > 0
        Kernel.pbMessage(_INTL("Unfurled the Magic Carpet."))
      if Kernel.pbConfirmMessage(_INTL("Would you like to use Waterfall?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Waterfall.",speciesname))
  #      pbHiddenMoveAnimation(movefinder)
        if $game_player.direction==2
          pbDescendWaterfall
          else
        pbAscendWaterfall
        end
        return true
      end
    else
      Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    end
  else
    Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
  end
  return false
end

Events.onAction+=proc{|sender,e|
   terrain=Kernel.pbFacingTerrainTag
   if terrain==PBTerrain::Waterfall && $game_player.direction==8
     Kernel.pbWaterfall
     return
   end
   if terrain==PBTerrain::WaterfallCrest
     Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
     return
   end
}
HiddenMoveHandlers::CanUseMove.add(:WATERFALL,proc{|move,pkmn|
  
   
  Kernel.pbMessage(_INTL("Can't use that here."))

   return false
   
   
   
   terrain=Kernel.pbFacingTerrainTag
   if terrain!=PBTerrain::Waterfall
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:WATERFALL,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}.",pokemon.name,PBMoves.getName(move)))
   end
   Kernel.pbAscendWaterfall
   return true
})

#===============================================================================
# Dive
#===============================================================================
def Kernel.pbDive
  divemap=pbGetMetadata($game_map.map_id,MetadataDiveMap)
  return false if !divemap
  movefinder=Kernel.pbCheckMove(:DIVE)
    if $PokemonBag.pbQuantity(PBItems::SCUBAGEAR) > 0
      if $PokemonBag.pbQuantity(PBItems::SCUBAGEAR) > 0
        Kernel.pbMessage(_INTL("Put the Scuba Gear on!"))
      else
        Kernel.pbMessage(_INTL("The sea is deep here."))
      end
      if Kernel.pbConfirmMessage(_INTL("Would you like to use Dive?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Dive.",speciesname))
        pbHiddenMoveAnimation(movefinder)
        pbFadeOutIn(99999){
           $game_temp.player_new_map_id=divemap
           $game_temp.player_new_x=$game_player.x
           $game_temp.player_new_y=$game_player.y
           $game_temp.player_new_direction=$game_player.direction
           Kernel.pbCancelVehicles
           $PokemonGlobal.diving=true
           Kernel.pbUpdateVehicle
           $PokemonTemp.dependentEvents.refresh_sprite
           $scene.transfer_player(false)
           $game_map.autoplay
           $game_map.refresh
        }
        return true
      end
    else
      Kernel.pbMessage(_INTL("The sea is deep here.  A Pokémon may be able to go underwater."))
    end
  return false
end

def Kernel.pbSurfacing
  return if !$PokemonGlobal.diving
  divemap=nil
  meta=pbLoadMetadata
  for i in 0...meta.length
    if meta[i] && meta[i][MetadataDiveMap]
      if meta[i][MetadataDiveMap]==$game_map.map_id
        divemap=i
        break
      end
    end
  end
  return if !divemap
  movefinder=Kernel.pbCheckMove(:DIVE)
  #if $DEBUG || $PokemonBag.pbQuantity(PBItems::SCUBAGEAR) > 0 || (movefinder &&
  #  (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE]) )
    if Kernel.pbConfirmMessage(_INTL("Light is filtering down from above.  Would you like to use Dive?"))
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} used Dive.",speciesname))
      pbHiddenMoveAnimation(movefinder)
      pbFadeOutIn(99999){
         $game_temp.player_new_map_id=divemap
         $game_temp.player_new_x=$game_player.x
         $game_temp.player_new_y=$game_player.y
         $game_temp.player_new_direction=$game_player.direction
         Kernel.pbCancelVehicles
         $PokemonGlobal.surfing=true
         Kernel.pbUpdateVehicle
         $PokemonTemp.dependentEvents.refresh_sprite
         $scene.transfer_player(false)
         surfbgm=pbGetMetadata(0,MetadataSurfBGM)
         if surfbgm
           pbBGMPlay(surfbgm)
         else
           $game_map.autoplayAsCue
         end
         $game_map.refresh
      }
      return true
    end
  #else
  #  Kernel.pbMessage(_INTL("Light is filtering down from above.  A Pokémon may be able to surface here."))
  #end
  return false
end

def Kernel.pbTransferUnderwater(mapid,xcoord,ycoord,direction=$game_player.direction)
  pbFadeOutIn(99999){
     $game_temp.player_new_map_id=mapid
     $game_temp.player_new_x=xcoord
     $game_temp.player_new_y=ycoord
     $game_temp.player_new_direction=direction
     Kernel.pbCancelVehicles
     $PokemonGlobal.diving=true
     Kernel.pbUpdateVehicle
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
  }
end

Events.onAction+=proc{|sender,e|
   terrain=$game_player.terrain_tag
   if terrain==PBTerrain::DeepWater
     Kernel.pbDive
     return
   end
   if $PokemonGlobal.diving
     if DIVINGSURFACEANYWHERE
       Kernel.pbSurfacing
       return
     else
       divemap=nil
       meta=pbLoadMetadata
       for i in 0...meta.length
         if meta[i] && meta[i][MetadataDiveMap]
           if meta[i][MetadataDiveMap]==$game_map.map_id
             divemap=i
             break
           end
         end
       end
       if $MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y)==PBTerrain::DeepWater
         Kernel.pbSurfacing
         return
       end
     end
   end
}

HiddenMoveHandlers::CanUseMove.add(:DIVE,proc{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if $PokemonGlobal.diving
     return true if DIVINGSURFACEANYWHERE
     divemap=nil
     meta=pbLoadMetadata
     for i in 0...meta.length
       if meta[i] && meta[i][MetadataDiveMap]
         if meta[i][MetadataDiveMap]==$game_map.map_id
           divemap=i
           break
         end
       end
     end
     if $MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y)==PBTerrain::DeepWater
       return true
     else
       Kernel.pbMessage(_INTL("Can't use that here."))
       return false
     end
   end
   if $game_player.terrain_tag!=PBTerrain::DeepWater
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataDiveMap)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:DIVE,proc{|move,pokemon|
   wasdiving=$PokemonGlobal.diving
   if $PokemonGlobal.diving
     divemap=nil
     meta=pbLoadMetadata
     for i in 0...meta.length
       if meta[i] && meta[i][MetadataDiveMap]
         if meta[i][MetadataDiveMap]==$game_map.map_id
           divemap=i
           break
         end
       end
     end
   else
     divemap=pbGetMetadata($game_map.map_id,MetadataDiveMap)
   end
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   return false if !divemap
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}.",pokemon.name,PBMoves.getName(move)))
   end
   pbFadeOutIn(99999){
      $game_temp.player_new_map_id=divemap
      $game_temp.player_new_x=$game_player.x
      $game_temp.player_new_y=$game_player.y
      $game_temp.player_new_direction=$game_player.direction
      Kernel.pbCancelVehicles
      if wasdiving
        $PokemonGlobal.surfing=true
      else
        $PokemonGlobal.diving=true
      end
      Kernel.pbUpdateVehicle
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
   }
   return true
})

#===============================================================================
# Fly
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLY,proc{|move,pkmn|
   if !$DEBUG && !$game_switches[7] 
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORFLY : $Trainer.badges[BADGEFORFLY])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end

   noFlyAry=[447,619,451,459,453,452,563,488,558,461,454,560,455,460,749,750,769]
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor) || noFlyAry.include?($game_map.map_id)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:FLY,proc{|move,pokemon|
  noFlyAry=[447,619,451,459,453,452,563,488,558,461,454,560,455,460,749,750,769]
  if !$PokemonTemp.flydata || noFlyAry.include?($game_map.map_id)
    Kernel.pbMessage(_INTL("Can't use that here."))
  end
  if !pbHiddenMoveAnimation(pokemon)
    Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
  end
  pbFadeOutIn(99999){
    $game_switches[172]=false
    $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
    $game_temp.player_new_x=$PokemonTemp.flydata[1]
    $game_temp.player_new_y=$PokemonTemp.flydata[2]
    if $game_temp.player_new_map_id==238 && $game_switches[391] && !$game_switches[158]
      $game_temp.player_new_map_id=276
    end
    $PokemonTemp.flydata=nil
    $game_temp.player_new_direction=2
    $scene.transfer_player
    $game_player.move_down
    $game_map.autoplay
    $game_map.refresh
    $game_screen.weather(0,0,0)
    weather=pbGetMetadata($game_map.map_id,MetadataWeather)
    $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
    $PokemonTemp.dependentEvents.refresh_sprite
  }
  pbEraseEscapePoint
  return true
})

#===============================================================================
# Flash
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLASH,proc{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORFLASH : $Trainer.badges[BADGEFORFLASH])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataDarkMap)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if $PokemonGlobal.flashUsed
     Kernel.pbMessage(_INTL("This is in use already."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:FLASH,proc{|move,pokemon|
   darkness=$PokemonTemp.darknessSprite
   return false if !darkness || darkness.disposed?
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   $PokemonGlobal.flashUsed=true
   while darkness.radius<176
     Graphics.update
     Input.update
     pbUpdateSceneMap
     darkness.radius+=4
   end
   return true
})

#===============================================================================
# Teleport
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:TELEPORT,proc{|move,pkmn|
   if $game_map.map_id==287
     Kernel.pbMessage("Some force keeps you from teleporting here...")
     return false
   end
   if $game_switches[134] || !pbGetMetadata($game_map.map_id,MetadataOutdoor) || 
      $game_map.map_id==750
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
  
   healing=$PokemonGlobal.healingSpot
   if !healing
     healing=pbGetMetadata(0,MetadataHome) # Home
   end
   if healing
     mapname=pbGetMapNameFromId(healing[0])
     if mapname=="Shade Forest" || mapname=="Telnor Cave"
       pbGetMetadata(32,MetadataHealingSpot)
     end
     
     if Kernel.pbConfirmMessage(_INTL("Want to return to the healing spot used last in {1}?",mapname))
       return true
     end
     return false
   else
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
})

HiddenMoveHandlers::UseMove.add(:TELEPORT,proc{|move,pokemon|
  healing=$PokemonGlobal.healingSpot
  if !healing
    healing=pbGetMetadata(0,MetadataHome)
  end
  if healing
    mapname=pbGetMapNameFromId(healing[0])
    if mapname=="Shade Forest" || mapname=="Telnor Cave"
      healing=pbGetMetadata(32,MetadataHealingSpot)
    end
    if !pbHiddenMoveAnimation(pokemon)
      Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
    end
    pbFadeOutIn(99999){
      Kernel.pbCancelVehicles
      $game_switches[172]=false
      $PokemonTemp.dependentEvents.refresh_sprite
      $game_temp.player_new_map_id=healing[0]
      if $game_temp.player_new_map_id==238 && $game_switches[391] && !$game_switches[158]
        $game_temp.player_new_map_id=276
      end
      $game_temp.player_new_x=healing[1]
      $game_temp.player_new_y=healing[2]
      $game_temp.player_new_direction=2
      $scene.transfer_player
      $game_player.move_down
      $game_map.autoplay
      $game_map.refresh
      $game_screen.weather(0,0,0)
      weather=pbGetMetadata($game_map.map_id,MetadataWeather)
      $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
    }
    pbEraseEscapePoint
    return true
  end
  return false
})

#===============================================================================
# Dig
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:DIG,proc{|move,pkmn|
   escape=($PokemonGlobal.escapePoint rescue nil)
   if !escape || escape==[] || $game_map.map_id==827
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if $game_map.map_id==502
     Kernel.pbMessage(_INTL("Can't use that in this room."))
     return false
   end
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     return false
   end
   mapname=pbGetMapNameFromId(escape[0])
   if Kernel.pbConfirmMessage(_INTL("Want to escape from here and return to {1}?",mapname))
     return true
   end
   return false
})

HiddenMoveHandlers::UseMove.add(:DIG,proc{|move,pokemon|
   escape=($PokemonGlobal.escapePoint rescue nil)
   if escape
     if !pbHiddenMoveAnimation(pokemon)
       Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
     end
     pbFadeOutIn(99999){
        Kernel.pbCancelVehicles
        $PokemonTemp.dependentEvents.refresh_sprite
        $game_temp.player_new_map_id=escape[0]
        $game_temp.player_new_x=escape[1]
        $game_temp.player_new_y=escape[2]
        $game_temp.player_new_direction=escape[3]
        $scene.transfer_player
        $game_map.autoplay
        $game_map.refresh
     }
     pbEraseEscapePoint
     return true
   end
   return false
})

#===============================================================================
# Tesseract
#===============================================================================


HiddenMoveHandlers::CanUseMove.add(:TESSERACT,proc{|move,pkmn|
   if $game_switches[172] || $game_map.map_id==33
     return true
   end
   Kernel.pbMessage("Can't use that here.")
   return false
})

HiddenMoveHandlers::UseMove.add(:TESSERACT,proc{|move,pokemon|
   if ($game_switches[172] || $game_map.map_id==33) && pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
        $PokemonMap.tesseract = true
        

    end


     return true
})



#===============================================================================
# Sweet Scent
#===============================================================================
def pbSweetScent
  if $game_screen.weather_type!=0
    Kernel.pbMessage(_INTL("The sweet scent faded for some reason..."))
    return
  end
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  count=0
  viewport.color.alpha-=10 
  begin
    if viewport.color.alpha<128 && count==0
      viewport.color.red=255
      viewport.color.green=0
      viewport.color.blue=0
      viewport.color.alpha+=8
    else
      count+=1
      if count>10
        viewport.color.alpha-=8 
      end
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end until viewport.color.alpha<=0
  viewport.dispose
  encounter=nil
  enctype=nil
  enctype=$PokemonEncounters.pbEncounterType
  if enctype<0 || !$PokemonEncounters.isEncounterPossibleHere?() ||
     !pbEncounter(enctype)
    Kernel.pbMessage(_INTL("There appears to be nothing here..."))
  end
end

HiddenMoveHandlers::CanUseMove.add(:SWEETSCENT,proc{|move,pkmn|
   return true
})

HiddenMoveHandlers::UseMove.add(:SWEETSCENT,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   pbSweetScent
   return true
})

def Kernel.pbRockClimb
  if $PokemonBag.pbQuantity(PBItems::HIKINGBOOTS) > 0
    if $PokemonBag.pbQuantity(PBItems::HIKINGBOOTS) > 0
      if $PokemonBag.pbQuantity(PBItems::HIKINGBOOTS) > 0
        Kernel.pbMessage(_INTL("Put on the Hiking Boots."))
      else
        Kernel.pbMessage(_INTL("These rocks look climbable."))
      end
      if Kernel.pbConfirmMessage(_INTL("Would you like to use Rock Climb?"))
#        speciesname=!movefinder ? $Trainer.name : movefinder.name
#        Kernel.pbMessage(_INTL("{1} used Rock Climb.",speciesname))
 #       pbHiddenMoveAnimation(movefinder)
        pbAscendRockClimb
        pbDescendRockClimb
        return true
      end
    else
      Kernel.pbMessage(_INTL("These rocks look climbable."))
    end
  else
    Kernel.pbMessage(_INTL("These rocks look climbable."))
  end
  return false
end

Events.onAction+=proc{|sender,e|
   terrain=Kernel.pbFacingTerrainTag
   if terrain==PBTerrain::RockClimb
     Kernel.pbRockClimb
     return
   end
}

HiddenMoveHandlers::CanUseMove.add(:ROCKCLIMB,proc{|move,pkmn|
  
   terrain=Kernel.pbFacingTerrainTag
   #if terrain!=PBTerrain::RockClimb
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
  # end
   return true
})

HiddenMoveHandlers::UseMove.add(:ROCKCLIMB,proc{|move,pokemon|
#   if !pbHiddenMoveAnimation(pokemon)
#     Kernel.pbMessage(_INTL("{1} used {2}.",pokemon.name,PBMoves.getName(move)))
#   end
   Kernel.pbAscendRockClimb
   Kernel.pbDescendRockClimb
   return true
})


def Kernel.pbCanUseHiddenMove?(pkmn,move)
  return HiddenMoveHandlers.triggerCanUseMove(move,pkmn)
end

def Kernel.pbUseHiddenMove(pokemon,move)
  return HiddenMoveHandlers.triggerUseMove(move,pokemon)
end

def Kernel.pbHiddenMoveEvent
  Events.onAction.trigger(nil)
end