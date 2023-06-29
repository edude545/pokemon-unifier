class PokemonTradeScene
  def pbRunPictures(pictures,sprites)
    loop do
      for i in 0...pictures.length
        pictures[i].update
      end
      for i in 0...sprites.length
        if sprites[i].is_a?(IconSprite)
          setPictureIconSprite(sprites[i],pictures[i])
        else
          setPictureSprite(sprites[i],pictures[i])
        end
      end
      Graphics.update
      Input.update
      running=false
      for i in 0...pictures.length
        running=true if pictures[i].running?
      end
      break if !running
    end
  end

  def pbStartScreen(pokemon,pokemon2,trader1,trader2)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @pokemon=pokemon
    @pokemon2=pokemon2
    @trader1=trader1
    @trader2=trader2
    addBackgroundOrColoredPlane(@sprites,"background","tradebg",
       Color.new(248,248,248),@viewport)
    rsprite1=PokemonSprite.new(@viewport)
    rsprite1.setPokemonBitmap(@pokemon,false)
    rsprite1.ox=rsprite1.bitmap.width/2
    rsprite1.oy=rsprite1.bitmap.height/2
    rsprite1.x=Graphics.width/2
    rsprite1.y=(Graphics.height-96)*2/3
    @sprites["rsprite1"]=rsprite1
    rsprite2=PokemonSprite.new(@viewport)
    rsprite2.setPokemonBitmap(@pokemon2,false)
    rsprite2.ox=rsprite2.bitmap.width/2
    rsprite2.oy=rsprite2.bitmap.height/2
    rsprite2.x=Graphics.width/2
    rsprite2.y=(Graphics.height-96)*2/3
    rsprite2.visible=false
    @sprites["rsprite2"]=rsprite2
    @sprites["msgwindow"]=Kernel.pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)
  end

  def pbScene1
    spriteBall=IconSprite.new(0,0,@viewport)
    pictureBall=PictureEx.new(0)
    picturePoke=PictureEx.new(0)
    # Starting position of ball
    pictureBall.moveVisible(1,true)
    pictureBall.moveName(1,sprintf("Graphics/Pictures/ball%02d",@pokemon.ballused))
    pictureBall.moveOrigin(1,PictureOrigin::Center)
    pictureBall.moveXY(0,1,Graphics.width/2,48)
    # Starting position of sprite
    picturePoke.moveVisible(1,true)
    picturePoke.moveOrigin(1,PictureOrigin::Center)
    rsprite1=@sprites["rsprite1"]
    rsprite1.ox=0
    rsprite1.oy=0
    picturePoke.moveXY(0,1,rsprite1.x,rsprite1.y)
    # Change sprite color
    delay=picturePoke.totalDuration+4
    picturePoke.moveColor(10,delay,Color.new(31*8,22*8,30*8,255))
    # Recall
    delay=picturePoke.totalDuration
    picturePoke.moveSE(delay,"Audio/SE/recall")
    pictureBall.moveName(delay,sprintf("Graphics/Pictures/ball%02d_open",@pokemon.ballused))
    # Move sprite to ball
    picturePoke.moveZoom(15,delay,0)
    picturePoke.moveXY(15,delay,Graphics.width/2,48)
    picturePoke.moveSE(delay+10,"Audio/SE/jumptoball")
    picturePoke.moveVisible(delay+15,false)
    pictureBall.moveName(picturePoke.totalDuration+2,sprintf("Graphics/Pictures/ball%02d",@pokemon.ballused))
    delay=picturePoke.totalDuration+20
    pictureBall.moveXY(12,delay,Graphics.width/2,-32)
    pbRunPictures(
       [picturePoke,pictureBall],
       [@sprites["rsprite1"],spriteBall]
    )
    spriteBall.dispose
  end

  def pbScene2
    spriteBall=IconSprite.new(0,0,@viewport)
    pictureBall=PictureEx.new(0)
    picturePoke=PictureEx.new(0)
    # Starting position of ball
    pictureBall.moveVisible(1,true)
    pictureBall.moveName(1,sprintf("Graphics/Pictures/ball%02d",@pokemon2.ballused))
    pictureBall.moveOrigin(1,PictureOrigin::Center)
    pictureBall.moveXY(0,1,Graphics.width/2,-32)
    # Starting position of sprite
    picturePoke.moveVisible(1,false)
    picturePoke.moveOrigin(1,PictureOrigin::Center)
    picturePoke.moveZoom(0,1,0)
    picturePoke.moveColor(0,1,Color.new(31*8,22*8,30*8,255))
    # Dropping ball
    y=Graphics.height-96-16
    delay=picturePoke.totalDuration+4
    pictureBall.moveXY(15,delay,Graphics.width/2,y)
    pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
    pictureBall.moveXY(8,pictureBall.totalDuration+2,Graphics.width/2,y-60)
    pictureBall.moveXY(7,pictureBall.totalDuration+2,Graphics.width/2,y)
    pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
    pictureBall.moveXY(6,pictureBall.totalDuration+2,Graphics.width/2,y-40)
    pictureBall.moveXY(5,pictureBall.totalDuration+2,Graphics.width/2,y)
    pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
    pictureBall.moveXY(4,pictureBall.totalDuration+2,Graphics.width/2,y-20)
    pictureBall.moveXY(3,pictureBall.totalDuration+2,Graphics.width/2,y)
    pictureBall.moveSE(pictureBall.totalDuration,"Audio/SE/balldrop")
    picturePoke.moveXY(0,pictureBall.totalDuration,Graphics.width/2,y)
    delay=pictureBall.totalDuration+18
    y=(Graphics.height-96)*2/3
    picturePoke.moveSE(delay,"Audio/SE/recall")
    picturePoke.moveSE(delay,
       sprintf("Audio/SE/%03dCry",@pokemon2.species))
    pictureBall.moveName(delay,sprintf("Graphics/Pictures/ball%02d_open",@pokemon2.ballused))
    pictureBall.moveVisible(delay+10,false)
    picturePoke.moveVisible(delay,true)
    picturePoke.moveZoom(15,delay,100)
    picturePoke.moveXY(15,delay,Graphics.width/2,y)
    delay=picturePoke.totalDuration
    picturePoke.moveColor(10,delay,Color.new(31*8,22*8,30*8,0))
    pbRunPictures(
       [picturePoke,pictureBall],
       [@sprites["rsprite2"],spriteBall]
    )
    spriteBall.dispose
  end

  def pbEndScreen
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"])
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    newspecies=pbTradeCheckEvolution(@pokemon2,@pokemon)
    if newspecies>0
      evo=PokemonEvolutionScene.new
      evo.pbStartScreen(@pokemon2,newspecies)
      evo.pbEvolution(true)
      evo.pbEndScreen
    end
  end

  def pbTrade(shouldSave=false)
    pbBGMStop()
    pbPlayCry(@pokemon)
    $Trainer.seen[@pokemon.species] = true
    $Trainer.seen[@pokemon2.species] = true
    speciesname1=PBSpecies.getName(@pokemon.species)
    speciesname2=PBSpecies.getName(@pokemon2.species)
    pbSave if shouldSave
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
       _INTL("{1}\r\nID: {2}   OT: {3}\\wtnp[0]",@pokemon.name,
       (@pokemon.trainerID&0xFFFF), @pokemon.ot))
    Kernel.pbMessageWaitForInput(@sprites["msgwindow"],100,true)
    pbPlayDecisionSE()
    pbScene1
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
       _INTL("For {1}'s {2},\r\n{3} sends {4}.\1",@trader1,speciesname1,@trader2,speciesname2))
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
       _INTL("{1} bids farewell to {2}.",@trader2,speciesname2))
    pbScene2
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
       _INTL("{1}\r\nID: {2}   OT: {3}\1",@pokemon2.name,
       (@pokemon2.trainerID&0xFFFF), @pokemon2.ot))
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
       _INTL("Take good care of {1}.",speciesname2))
  end
end



def pbStartTrade(pokemonIndex,newpoke,nickname,trainerName,trainerGender=0)
  myPokemon=$Trainer.party[pokemonIndex]
  opponent=PokeBattle_Trainer.new(trainerName,trainerGender)
  opponent.setForeignID($Trainer)
  yourPokemon=nil
  if newpoke.is_a?(PokeBattle_Pokemon)
    newpoke.trainerID=opponent.id
    newpoke.ot=opponent.name
    newpoke.otgender=opponent.gender
    newpoke.language=opponent.language
    yourPokemon=newpoke
  else
    yourPokemon=PokeBattle_Pokemon.new(newpoke,myPokemon.level,opponent)
  end
  yourPokemon.name=nickname if nickname != "nonick"
  yourPokemon.resetMoves
  yourPokemon.obtainMode=2 # traded
  $Trainer.seen[yourPokemon.species]=true
  $Trainer.owned[yourPokemon.species]=true
  pbSeenForm(yourPokemon)
  pbFadeOutInWithMusic(99999){
    evo=PokemonTradeScene.new
    evo.pbStartScreen(myPokemon,yourPokemon,$Trainer.name,opponent.name)
    evo.pbTrade
    evo.pbEndScreen
  }
  $Trainer.party[pokemonIndex]=yourPokemon
  $PokemonTemp.dependentEvents.refresh_sprite
end

def pbTradeCheckEvolution(pokemon,pokemon2)
  ret=pbCheckEvolutionEx(pokemon){|pokemon,evonib,level,poke|
    case evonib
      when 5 # Evolves if traded
        next poke
      when 6 # Evolves if traded while holding a particular item
        if pokemon.item==level
          pokemon.item=0
          next poke
        end
      when 25 # Evolves if traded for a particular species
        next poke if pokemon2.species==level
    end
    next -1
  }
  return ret
end