#===============================================================================
# * Egg Hatch Animation - by FL (Credits will be apreciated)
#                         Tweaked by Maruno
#===============================================================================
# This script is for Pokémon Essentials. It's an egg hatch animation that
# works even with special eggs like Manaphy egg.
#===============================================================================
# To this script works, put it above Main and put a picture (a 5 frames
# sprite sheet) with egg sprite height and 5 times the egg sprite width at
# Graphics/Battlers/eggCracks.
#===============================================================================
class PokemonEggHatchScene
  def pbStartScene(pokemon)
    @sprites={}
    @pokemon=pokemon
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @pokemon.eggsteps=1 # Just for drawing the egg
    addBackgroundOrColoredPlane(@sprites,"background","hatchbg",
       Color.new(248,248,248),@viewport)
    @sprites["pokemon"]=PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].x=Graphics.width/2-@sprites["pokemon"].bitmap.width/2
    @sprites["pokemon"].y=48+Graphics.height/2-@sprites["pokemon"].bitmap.height/2
    @sprites["hatch"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"]=BitmapSprite.new(
        Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=200
    @sprites["overlay"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["overlay"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,
        Color.new(255,255,255))
    @sprites["overlay"].opacity=0
    @pokemon.eggsteps=0 # Correct egg steps again
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    hatchSheet=AnimatedBitmap.new(_INTL("Graphics/Battlers/eggCracks"))
    pbBGMPlay("evolv")
    # Egg animation
    updateScene(60)
    @sprites["hatch"].x -= 30
    pbPositionHatchMask(hatchSheet,0)
    pbSEPlay("ballshake")
    swingEgg(2)
    updateScene(8)
    pbPositionHatchMask(hatchSheet,1)
    pbSEPlay("ballshake")
    swingEgg(2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet,2)
    pbSEPlay("ballshake")
    swingEgg(4,2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet,3)
    pbSEPlay("ballshake")
    swingEgg(8,4)
    updateScene(8)
    pbPositionHatchMask(hatchSheet,4)
    pbSEPlay("recall")
    # Fade and change the sprite
    fadeSpeed=15
    for i in 1..(255/fadeSpeed)
      @sprites["pokemon"].tone=Tone.new(i*fadeSpeed,i*fadeSpeed,i*fadeSpeed)
      @sprites["overlay"].opacity=i*fadeSpeed
      updateScene
    end
    updateScene(30)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].x-=30
    @sprites["pokemon"].y-=60
    @sprites["hatch"].visible=false
    for i in 1..(255/fadeSpeed)
      @sprites["pokemon"].tone=Tone.new(255-i*fadeSpeed,255-i*fadeSpeed,255-i*fadeSpeed)
      @sprites["overlay"].opacity=255-i*fadeSpeed
      updateScene
    end
    @sprites["pokemon"].tone=Tone.new(0,0,0)
    @sprites["overlay"].opacity=0
    # Finish scene
    frames=pbCryFrameLength(@newspecies)
    pbBGMStop()
    pbPlayCry(@pokemon)
    frames.times do
      Graphics.update
    end
    pbMEPlay("004-Victory04")
    speciesname=PBSpecies.getName(@pokemon.species)
    speciesname=@pokemon.name if $game_switches[356]
    Kernel.pbMessage(_INTL("\\se[]{1} hatched from the Egg!\\wt[80]",speciesname))
    @pokemon.obtainMode=1
    @pokemon.hatchedMap=$game_map.map_id
    @pokemon.timeEggHatched=pbGetTimeNow
    $Trainer.owned[@pokemon.species]=true
    $Trainer.seen[@pokemon.species]=true
    @pokemon.obtainMap=$game_map.map_id
    @pokemon.eggmovesarray=@pokemon.moves.clone

    if !$game_switches[356]
        if Kernel.pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?",speciesname))
          species=PBSpecies.getName(@pokemon.species) 
          if species.split().last=="♂" || species.split().last=="♀"
             species=species.name[0..-2]
         end
         genderSymbol=""
         if @pokemon.gender==0
            genderSymbol=" "+_INTL("♂")
         elsif @pokemon.gender==1
               genderSymbol=" "+_INTL("♀")
         end
         $game_switches[697]=true
         nickname=pbEnterText(_INTL("{1}'s{2} nickname?",species,genderSymbol),0,11)
         $game_switches[697]=false
         @pokemon.name=nickname if nickname!=""
         @pokemon.name=PBSpecies.getName(@pokemon.species) if nickname==""
       else
           @pokemon.name=speciesname
       end
       
     end


  if Kernel.pbConfirmMessage(_INTL("Would you like to put {1} in a different Poké Ball?",@pokemon.name))
    while 1==1
        daycareball=[]
      ballchecker=[]
      daycareball[daycareball.length]=_INTL("Poké Ball")
      ballchecker[ballchecker.length]=0
      daycareball[daycareball.length]=_INTL("Great Ball x{1}",$PokemonBag.pbQuantity(PBItems::GREATBALL)) if $PokemonBag.pbQuantity(PBItems::GREATBALL) > 0
      ballchecker[ballchecker.length]=1 if $PokemonBag.pbQuantity(PBItems::GREATBALL) > 0
      daycareball[daycareball.length]=_INTL("Ultra Ball x{1}",$PokemonBag.pbQuantity(PBItems::ULTRABALL)) if $PokemonBag.pbQuantity(PBItems::ULTRABALL) > 0
      ballchecker[ballchecker.length]=3 if $PokemonBag.pbQuantity(PBItems::ULTRABALL) > 0
      daycareball[daycareball.length]=_INTL("Master Ball x{1}",$PokemonBag.pbQuantity(PBItems::MASTERBALL)) if $PokemonBag.pbQuantity(PBItems::MASTERBALL) > 0
      ballchecker[ballchecker.length]=4 if $PokemonBag.pbQuantity(PBItems::MASTERBALL) > 0
      daycareball[daycareball.length]=_INTL("Dive Ball x{1}",$PokemonBag.pbQuantity(PBItems::DIVEBALL)) if $PokemonBag.pbQuantity(PBItems::DIVEBALL) > 0
      ballchecker[ballchecker.length]=6 if $PokemonBag.pbQuantity(PBItems::DIVEBALL) > 0
      daycareball[daycareball.length]=_INTL("Dusk Ball x{1}",$PokemonBag.pbQuantity(PBItems::DUSKBALL)) if $PokemonBag.pbQuantity(PBItems::DUSKBALL) > 0
      ballchecker[ballchecker.length]=12 if $PokemonBag.pbQuantity(PBItems::DUSKBALL) > 0 
      daycareball[daycareball.length]=_INTL("Net Ball x{1}",$PokemonBag.pbQuantity(PBItems::NETBALL)) if $PokemonBag.pbQuantity(PBItems::NETBALL) > 0
      ballchecker[ballchecker.length]=5 if $PokemonBag.pbQuantity(PBItems::NETBALL) > 0
      daycareball[daycareball.length]=_INTL("Premier Ball x{1}",$PokemonBag.pbQuantity(PBItems::PREMIERBALL)) if $PokemonBag.pbQuantity(PBItems::PREMIERBALL) > 0
      ballchecker[ballchecker.length]=11 if $PokemonBag.pbQuantity(PBItems::PREMIERBALL) > 0
      daycareball[daycareball.length]=_INTL("Timer Ball x{1}",$PokemonBag.pbQuantity(PBItems::TIMERBALL)) if $PokemonBag.pbQuantity(PBItems::TIMERBALL) > 0
      ballchecker[ballchecker.length]=9 if $PokemonBag.pbQuantity(PBItems::TIMERBALL) > 0
      daycareball[daycareball.length]=_INTL("Quick Ball x{1}",$PokemonBag.pbQuantity(PBItems::QUICKBALL)) if $PokemonBag.pbQuantity(PBItems::QUICKBALL) > 0
      ballchecker[ballchecker.length]=14 if $PokemonBag.pbQuantity(PBItems::QUICKBALL) > 0
      daycareball[daycareball.length]=_INTL("Luxury Ball x{1}",$PokemonBag.pbQuantity(PBItems::LUXURYBALL)) if $PokemonBag.pbQuantity(PBItems::LUXURYBALL) > 0
      ballchecker[ballchecker.length]=10 if $PokemonBag.pbQuantity(PBItems::LUXURYBALL) > 0
      daycareball[daycareball.length]=_INTL("Level Ball x{1}",$PokemonBag.pbQuantity(PBItems::LEVELBALL)) if $PokemonBag.pbQuantity(PBItems::LEVELBALL) > 0
      ballchecker[ballchecker.length]=17 if $PokemonBag.pbQuantity(PBItems::LEVELBALL) > 0
      daycareball[daycareball.length]=_INTL("Lure Ball x{1}",$PokemonBag.pbQuantity(PBItems::LUREBALL)) if $PokemonBag.pbQuantity(PBItems::LUREBALL) > 0
      ballchecker[ballchecker.length]=18 if $PokemonBag.pbQuantity(PBItems::LUREBALL) > 0
      daycareball[daycareball.length]=_INTL("Moon Ball x{1}",$PokemonBag.pbQuantity(PBItems::MOONBALL)) if $PokemonBag.pbQuantity(PBItems::MOONBALL) > 0
      ballchecker[ballchecker.length]=22 if $PokemonBag.pbQuantity(PBItems::MOONBALL) > 0
      daycareball[daycareball.length]=_INTL("Friend Ball x{1}",$PokemonBag.pbQuantity(PBItems::FRIENDBALL)) if $PokemonBag.pbQuantity(PBItems::FRIENDBALL) > 0
      ballchecker[ballchecker.length]=21 if $PokemonBag.pbQuantity(PBItems::FRIENDBALL) > 0
      daycareball[daycareball.length]=_INTL("Love Ball x{1}",$PokemonBag.pbQuantity(PBItems::LOVEBALL)) if $PokemonBag.pbQuantity(PBItems::LOVEBALL) > 0
      ballchecker[ballchecker.length]=20 if $PokemonBag.pbQuantity(PBItems::LOVEBALL) > 0
      daycareball[daycareball.length]=_INTL("Heavy Ball x{1}",$PokemonBag.pbQuantity(PBItems::HEAVYBALL)) if $PokemonBag.pbQuantity(PBItems::HEAVYBALL) > 0
      ballchecker[ballchecker.length]=19 if $PokemonBag.pbQuantity(PBItems::HEAVYBALL) > 0
      daycareball[daycareball.length]=_INTL("Fast Ball x{1}",$PokemonBag.pbQuantity(PBItems::FASTBALL)) if $PokemonBag.pbQuantity(PBItems::FASTBALL) > 0
      ballchecker[ballchecker.length]=16 if $PokemonBag.pbQuantity(PBItems::FASTBALL) > 0
      daycareball[daycareball.length]=_INTL("Repeat Ball x{1}",$PokemonBag.pbQuantity(PBItems::REPEATBALL)) if $PokemonBag.pbQuantity(PBItems::REPEATBALL) > 0
      ballchecker[ballchecker.length]=8 if $PokemonBag.pbQuantity(PBItems::REPEATBALL) > 0
      daycareball[daycareball.length]=_INTL("Heal Ball x{1}",$PokemonBag.pbQuantity(PBItems::HEALBALL)) if $PokemonBag.pbQuantity(PBItems::HEALBALL) > 0
      ballchecker[ballchecker.length]=13 if $PokemonBag.pbQuantity(PBItems::HEALBALL) > 0
      daycareball[daycareball.length]=_INTL("Cherish Ball x{1}",$PokemonBag.pbQuantity(PBItems::CHERISHBALL)) if $PokemonBag.pbQuantity(PBItems::CHERISHBALL) > 0
      ballchecker[ballchecker.length]=15 if $PokemonBag.pbQuantity(PBItems::CHERISHBALL) > 0
      daycareball[daycareball.length]=_INTL("Delta Ball x{1}",$PokemonBag.pbQuantity(PBItems::DELTABALL)) if $PokemonBag.pbQuantity(PBItems::DELTABALL) > 0
      ballchecker[ballchecker.length]=26 if $PokemonBag.pbQuantity(PBItems::DELTABALL) > 0
      daycareball[daycareball.length]=_INTL("Shiny Ball x{1}",$PokemonBag.pbQuantity(PBItems::SHINYBALL)) if $PokemonBag.pbQuantity(PBItems::SHINYBALL) > 0
      ballchecker[ballchecker.length]=28 if $PokemonBag.pbQuantity(PBItems::SHINYBALL) > 0
      daycareball[daycareball.length]=_INTL("Snore Ball x{1}",$PokemonBag.pbQuantity(PBItems::SNOREBALL)) if $PokemonBag.pbQuantity(PBItems::SNOREBALL) > 0
      ballchecker[ballchecker.length]=27 if $PokemonBag.pbQuantity(PBItems::SNOREBALL) > 0
      daycareball[daycareball.length]=_INTL("Nuzlocke Ball x{1}",$PokemonBag.pbQuantity(PBItems::NUZLOCKEBALL)) if $PokemonBag.pbQuantity(PBItems::NUZLOCKEBALL) > 0
      ballchecker[ballchecker.length]=24 if $PokemonBag.pbQuantity(PBItems::NUZLOCKEBALL) > 0
      daycareball[daycareball.length]=_INTL("Ancient Ball x{1}",$PokemonBag.pbQuantity(PBItems::ANCIENTBALL)) if $PokemonBag.pbQuantity(PBItems::ANCIENTBALL) > 0
      ballchecker[ballchecker.length]=25 if $PokemonBag.pbQuantity(PBItems::ANCIENTBALL) > 0
      daycareball2=Kernel.pbMessage(_INTL("Which ball?"), daycareball)
      if Kernel.pbConfirmMessage(_INTL("Are you sure?"))
        @pokemon.ballused=ballchecker[daycareball2]
        if @pokemon.ballused==21
          @pokemon.happiness=200
        end
        break
      end
    end
  end
  $PokemonTemp.dependentEvents.refresh_sprite
  pbChangeLevel(@pokemon,@pokemon.eggswitchlvl,$scene,false) if $game_switches[356] && @pokemon.eggswitchlvl != nil # for convenience
  $game_map.autoplay
  $game_system.setDefaultBGM(nil)
  end

  def pbPositionHatchMask(hatchSheet,index)
    frames = 5
    frameWidth = hatchSheet.width/frames
    rect = Rect.new(frameWidth*index,0,frameWidth,hatchSheet.height)
    @sprites["hatch"].bitmap.blt(@sprites["pokemon"].x,@sprites["pokemon"].y,
        hatchSheet.bitmap,rect)
  end

  def swingEgg(speed,swingTimes=1) # Only accepts 2, 4 or 8 for speed.
    limit = 8
    targets = [@sprites["pokemon"].x-limit,@sprites["pokemon"].x+limit,
        @sprites["pokemon"].x]
    swingTimes.times do
      usedSpeed=speed
      for target in targets
        usedSpeed*=-1
        while target!=@sprites["pokemon"].x
          @sprites["pokemon"].x+=usedSpeed
          @sprites["hatch"].x+=usedSpeed
          updateScene
        end
      end
    end
  end

  def updateScene(frames=1) # Can be used for "wait" effect
    frames.times do
      Graphics.update
      Input.update
      self.update
    end
  end  

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonEggHatchScreen
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    @scene.pbMain
    @scene.pbEndScene
  end
end



def pbHatchAnimation(pokemon)
  begin
  #if pokemon.species==PBSpecies::DELTADRIFLOON
  #  pokemon.species==PBSpecies::DRIFLOON
  #  pokemon.resetMoves
  #end
  #if pokemon.species==PBSpecies::DELTAPHANTUMP
  #  pokemon.species==PBSpecies::PHANTUMP
  #  pokemon.resetMoves
  #end
  pokemon.calcStats
  rescue
  end
  Kernel.pbMessage(_INTL("Huh?\1"))
  pbFadeOutIn(99999) {
    scene=PokemonEggHatchScene.new
    screen=PokemonEggHatchScreen.new(scene)
    screen.pbStartScreen(pokemon)
  }
  return true
end
=begin


def pbHatch(pokemon)
  speciesname=PBSpecies.getName(pokemon.species)
  pokemon.name=speciesname
  pokemon.trainerID=$Trainer.id
  pokemon.ot=$Trainer.name
  pokemon.happiness=120
  pokemon.timeEggHatched=pbGetTimeNow
  pokemon.obtainMode=1 # hatched from egg
  pokemon.hatchedMap=$game_map.map_id
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon)
  if !pbHatchAnimation(pokemon)
    Kernel.pbMessage(_INTL("Huh?\1"))
    Kernel.pbMessage(_INTL("...\1"))
    Kernel.pbMessage(_INTL("... .... .....\1"))
    Kernel.pbMessage(_INTL("{1} hatched from the Egg!",speciesname))
    if Kernel.pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?",speciesname))
      species=PBSpecies.getName(pokemon.species)
      nickname=pbEnterPokemonName(_INTL("{1}'s nickname?",speciesname),0,10,"",pokemon)
      pokemon.name=nickname if nickname!=""
    end
  end
end

Events.onStepTaken+=proc {|sender,e|
   next if !$Trainer
   for egg in $Trainer.party
     if egg.eggsteps>0
       egg.eggsteps-=1
       for i in $Trainer.party
         if !i.egg? && (isConst?(i.ability,PBAbilities,:FLAMEBODY) ||
                        isConst?(i.ability,PBAbilities,:MAGMAARMOR))
           egg.eggsteps-=1
           break
         end
       end
       if egg.eggsteps<=0
         egg.eggsteps=0
         pbHatch(egg)
       end
     end
   end
}
=end