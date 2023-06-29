class PokemonHatchingScene
  private

  def pbGenerateMetafiles(s1x,s1y,s2x,s2y)
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
    sevenseconds=Graphics.frame_rate*7
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

# Starts the hatching screen with the given Pokemon and new Pokemon species.
  public

  def pbStartScreen(pokemon)
    newspecies=pokemon.species
   pokemon.eggsteps=1
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
           pokemon.eggsteps=0

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

# Closes the hatching screen.
  def pbEndScreen
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"])
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

# Opens the hatching screen
  def pbHatching(pokemon,cancancel=false)
    metaplayer1=SpriteMetafilePlayer.new(@metafile1,@sprites["rsprite1"])
    metaplayer2=SpriteMetafilePlayer.new(@metafile2,@sprites["rsprite2"])
    metaplayer1.play
    metaplayer2.play
    pbBGMStop()
    pbPlayCry(@pokemon)
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
      frames=pbCryFrameLength(@newspecies)
      pbBGMStop()
      pbPlayCry(@newspecies)
      frames.times do
        Graphics.update
      end
      pbMEPlay("004-Victory04")
      
        speciesname=PBSpecies.getName(pokemon.species)
  pokemon.name=speciesname if !$game_switches[356]
  pokemon.trainerID=$Trainer.id
  pokemon.ot=$Trainer.name
  pokemon.happiness=120
  pokemon.timeEggHatched=pbGetTimeNow
  pokemon.obtainMode=1 # hatched from egg
  pokemon.hatchedMap=$game_map.map_id
  Kernel.pbMessage(_INTL("{1} hatched from the Egg!",speciesname)) if !$game_switches[356]
  Kernel.pbMessage(_INTL("{1} the {2} hatched from the Egg!",pokemon.name,speciesname)) if $game_switches[356]

      Kernel.pbMessageDisplay(@sprites["msgwindow"],
         _INTL("\\se[]{1} hatched from the Egg!!\\wt[80]",speciesname)) if !$game_switches[356]
      Kernel.pbMessageDisplay(@sprites["msgwindow"],
         _INTL("\\se[]{1} the {2} hatched from the Egg!\\wt[80]",pokemon.name,speciesname)) if $game_switches[356]
      @sprites["msgwindow"].text=""
      $PokemonTemp.dependentEvents.refresh_sprite
  end
end
