#class GTS
#  def self.open
#    Kernel.pbMessage("The server is down at the moment due to conflicts with saving the game.")
#    Kernel.pbMessage("We apologize for the inconvenience, and will try to fix this ASAP.")
#    end
#end


################################################################################
# GTS System                  Version 2.0.0
# By Hansiec                      RELEASE
# Special Thanks to Saving Raven for providing graphics and testing
# CREDITS REQUIRED
################################################################################
# WARNING: Do not use this script if you lack basic MySQL knowledge and/or basic
# PHP knowledge.
#
# WARNING: Do not mess with the script below, it is
#
# NOTICE: If a bug uccors, please state the message of the bug.
# NOTICE: You may not use the test server for your full game, I don't care what
#         you say, it's only for test purposes.
#
# What's new:
#   * Added Two new search methods, "By Pokemon" and "By ID", this let's you
#       search for a pokemon by usiing your pokemon and see what people want for
#       that species, and let's you input an online ID to see if a pokemon is
#       up for trade there.
#   * Added the abillity to see your own online ID
#
# Installation:
#   * Configure Settings `GTS.php`
#   * Upload `GTS.php` to your webserver
#   * Replace the `URL` variable in `GTSSettings` with your url
#   * Run the function "GTSCore.install"
#
# How To Use:
#   * Install
#   * Call "GTS.open"
#   * Report if any bugs uccor
#
# Settings:
#   * URL - The url link of "gts.php"
#   * SPECIES_SHOWN - Set to "All", "Owned", or "Seen" - this sets the available
#       species you can search for
#   * SORT_MODE - Set to "Alphabetical" or "Regional" - How species are arranged
#       during species finding
#   * GAME_CODE - A special Game Code, if you happen to trade with a game with
#       a different game code, the found map would be "Faraway Place"
#
# Bug Fixes:
#   * Fixed a cloning glitch where your pokemon duplicates if you exit shortly
#     after trading
#   * Fixed a small error in gts.php of where some tables setup incorrectly
#
################################################################################

module GTSSettings
 # URL = "http://originempires.site90.net/Rayd12smitty_gts.php"
  SPECIES_SHOWN = "All" # All/Seen/Owned Species you can search for
  SORT_MODE = "Alphabetical" # Alphabetical/Regional How species are arranged
  BLACK_LIST = []
  # Pokemon Species of which cannot be selected to search for

  GAME_CODE = "vesryn_zo_pokemon" # Please use a custom Game Code
                 # It IS case Sensitive and can be any length, this is to define
                 # Games as different from each other.
end

# Temporary boolean, DO NOT REMOVE
$TempBool = false

module GTS
  ##### Main Method
  def self.open
 #   Kernel.pbMessage("The servers are currently down. Try again another time.")
 #   return
    $scene = Scene_GTS.new
    scene = $scene
   # screen=
    #pbFadeOutIn(99999) { screen.pbStartScreen }
    #  elsif cmdLanguage>=0 && command==cmdLanguage
 #       Kernel.pbMessage("opening")
    scene.main
  end
  
  #### Brings up a summary of your uploaded pokemon (also allows you to delete it)
  def self.summary
    if GTSCore.isTaken
      newpoke = GTSCore.downloadPokemon($PokemonGlobal.onlineID).to_pokemon
      if finishTrade($PokemonGlobal.onlinePokemon, newpoke, false)
        pbAddPokemonSilent(newpoke)
        $PokemonGlobal.onlinePokemon = nil
        pbSave
      end
      return
    end
    pbFadeOutIn(99999){
      scene=PokemonSummaryScene.new
      screen=PokemonSummary.new(scene)
      screen.pbStartScreen([$PokemonGlobal.onlinePokemon],0)
    }
    if Kernel.pbConfirmMessageSerious(_INTL("Do you want to withdraw your "+
      "Pokemon from GTS?"))
      if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to "+
        "withdraw your Pokemon"))
        if GTSCore.deletePokemon
          pbAddPokemonSilent($PokemonGlobal.onlinePokemon)
          $PokemonGlobal.onlinePokemon = nil
          $TempBool = true
          pbSave
          # Long story short, we save before we show the message to help prevent
          # pokemon from being deleted by restarting, but if the game is restarted,
          # we don't want this message
          if $TempBool
            Kernel.pbMessage(_INTL("Pokemon withdrawn, please be aware that "+
            "your Pokemon may have had been taken by now."))
          end
        end
      end
    end
  end


=begin
  ##### Finishes the GTS trade
  def self.finishTrade(myPokemon, newpoke, searching, id=nil)
    $Trainer.seen[newpoke.species]=true
    $Trainer.owned[newpoke.species]=true
    pbSeenForm(newpoke)
    pbFadeOutInWithMusic(99999){
      evo=PokemonTradeScene.new
      evo.pbStartScreen(myPokemon,newpoke,$Trainer.name,newpoke.ot)
      evo.pbTrade
      evo.pbEndScreen
    }
    if !newpoke.game_code || newpoke.game_code != GTSSettings::GAME_CODE
      newpoke.obtainText = "Zela Region"
    end
    newpoke.obtainMode = 2 # Traded
    if searching
      if GTSCore.setTaken(id) && GTSCore.uploadNewPokemon(id, myPokemon)
        pbAddPokemonSilent(newpoke)
        pbSave
        return true
      end
      return false
    else
      pbSave
      return GTSCore.deletePokemon(false)
    end
    pbSave
  end
  
=end

  ##### Brings up all species of pokemon of the given index of the given sort mode
  def self.orderSpecies(speciesList)#index)
    commands=[]
   # Kernel.pbMessage(""+speciesList.length.to_s)
    for i in speciesList
      commands.push("#{i}: #{pbGetMessage(MessageTypes::Species,i,true)}")# if i > 0
    end
    if commands.length == 0
      Kernel.pbMessage(_INTL("No species found."))
      return [0, 0]
    end
   # (message,commands=nil,cmdIfCancel=0,skin=nil,defaultCmd=0,&block)
    c = Kernel.pbMessage("Select a species.",commands, 0, nil, 0)
    x = speciesList[c]
    if x.is_a?(Array)
      x = x[0]
    end
    #return [c == 0 ? -1 : x, c]
    return [x, c]
  end
  
  def self.orderItems(speciesList)#index)
    commands=[]
   # Kernel.pbMessage(""+speciesList.length.to_s)
    for i in speciesList
      commands.push("#{PBItems.getName(i)}") if i > 0
    end
    if commands.length == 0
      Kernel.pbMessage(_INTL("No items found."))
      return [0, 0]
    end
   # (message,commands=nil,cmdIfCancel=0,skin=nil,defaultCmd=0,&block)
    c = Kernel.pbMessage("Select an Item",commands, 0, nil, 1)
    x = speciesList[c]
    if x.is_a?(Array)
      x = x[0]
    end
    #return [c == 0 ? -1 : x, c]
    return [x, c]
  end
  



end


################################################################################
# GTS Scenes
# By Hansiec
# Scenes For GTS
################################################################################

######## GTS Buttons, A Basic options button for our GTS System
class GTS_Button < SpriteWrapper
  def initialize(x,y,name="",index=0,viewport=nil)
    super(viewport)
    @index=index
    @name=name
    @selected=false
    self.x=x
    self.y=y
    update
  end

  def dispose
    super
  end

  def refresh
    self.bitmap.dispose if self.bitmap
    self.bitmap = Bitmap.new("Graphics/Pictures/GTS/Options_bar")
    pbSetSystemFont(self.bitmap)
    textpos=[
       [@name,self.bitmap.width/2,1,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(self.bitmap,textpos)
  end

  def update
    refresh
    super
  end
end

########## GTS Search Method Selection
class GTSSearchMethod
  def initialize
    @exit = false
    @index = 0
  end
  
  def create_spriteset
    pbDisposeSpriteHash(@sprites) if @sprites
    @sprites = {}
    @sprites["background"] = IconSprite.new
    @sprites["background"].setBitmap("Graphics/Pictures/GTS/Background")
    
    pbSetSystemFont(@sprites["background"].bitmap)
    textpos=[          
       ["Select Search Method",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
 #      ["Online ID: #{$PokemonGlobal.onlineID}",350,6,2,Color.new(248,248,248),
 #      Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["background"].bitmap,textpos)
    
    @sprites["0"] = GTS_Button.new(Graphics.width/2, 50, "By Wanted")
    @sprites["0"].x -= @sprites["0"].bitmap.width / 2
    
    @sprites["1"] = GTS_Button.new(Graphics.width/2, 110, "By Pokemon")
    @sprites["1"].x -= @sprites["1"].bitmap.width / 2
    
    @sprites["2"] = GTS_Button.new(Graphics.width/2, 170, "By ID")
    @sprites["2"].x -= @sprites["2"].bitmap.width / 2
    
    @sprites["3"] = GTS_Button.new(Graphics.width/2, 230, "Exit")
    @sprites["3"].x -= @sprites["3"].bitmap.width / 2
    
    bit = Bitmap.new("Graphics/Pictures/GTS/Select")
    @sprites["selection_l"] = IconSprite.new
    @sprites["selection_l"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
    @sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))
    
    @sprites["selection_r"] = IconSprite.new
    @sprites["selection_r"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
    @sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))
    
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["#{@index}"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    
  end
  
  def main
    if !@exit
      Graphics.freeze
      create_spriteset
      Graphics.transition
      loop do
        Graphics.update
        Input.update
        update
        break if @exit
      end
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
  end
  
  def update
    pbUpdateSpriteHash(@sprites)
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["#{@index}"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    if Input.trigger?(Input::UP)
      @index -= 1
      if @index < 0
        @index = 3
      end
    elsif Input.trigger?(Input::DOWN)
      @index += 1
      if @index > 3
        @index = 0
      end
    end
    if (Input.trigger?(Input::B))
      pbPlayCancelSE
      @exit = true
    elsif (Input.trigger?(Input::C))
      pbPlayDecisionSE
      do_command
    end
  end
  
  def do_command
    if @index == 0
      Graphics.freeze
      scene = GTSWantedData.new
      @sprites["background"].dispose
      data=scene.main
      create_spriteset
      Graphics.transition
      return if !data.is_a?(Array)
      list = GTSCore.getPokemonList(data)
      if list[0] == "nothing"
        Kernel.pbMessage(_INTL("No Pokemon was found."))
      else
        pokemonList = []
        for i in list
          pokemonList.push(GTSCore.downloadPokemon(i).to_pokemon)
        end
        loop do
          scene=PokemonSummaryScene.new
          screen=PokemonSummary.new(scene)
          index = screen.pbStartGTSScreen(pokemonList,0)
          if index == false
            break
          else
            wantedData = GTSCore.downloadWantedData(list[index])
            for i in 0...wantedData.length
              wantedData[i] = wantedData[i].to_i
            end
            scene=PokemonSummaryScene.new
            screen=PokemonSummary.new(scene)
            takes = screen.pbStartGTSWantedScreen(wantedData,0)
            if takes
              pbFadeOutIn(99999){
               scene=PokemonStorageScene.new
               screen=PokemonStorageScreen.new(scene,$PokemonStorage)
               $choice = choice = screen.pbChoosePokemon
              }
              choice = $choice
              if choice == nil
                break
              else
                party = choice[0] == -1
                pkmn = $Trainer.party[choice[1]].clone
                pkmn = $PokemonStorage[choice[0]][choice[1]].clone if !party
                
                if pkmn.species != wantedData[0] || pkmn.level < wantedData[1] ||
                  pkmn.level > wantedData[2] ||
                  (wantedData[3] != -1 && pkmn.gender != wantedData[3])
                  Kernel.pbMessage(_INTL("The selected Pokemon does not match the"+
                  " wanted requirments."))
                else
                  if pkmn.moves[0].id > 559 || pkmn.moves[1].id > 559 || pkmn.moves[2].id > 559 || pkmn.moves[3].id > 559
            Kernel.pbMessage("This Pokemon has an illegal move for the GTS!")
            
          elsif pkmn.item > 525 
            Kernel.pbMessage("This Pokemon has an illegal item for the GTS!")
      
        elsif GTS.finishTrade(pkmn, pokemonList[index], true, list[index])
                    if party
                      pbRemovePokemonAt(choice[1])
                    else
                      $PokemonStorage[choice[0]][choice[1]] = nil
                    end
                    pbSave
                    return true
                  end
                end
                
                end

            end
          end
        end
      end
    elsif @index == 1
      Kernel.pbMessage(_INTL("To Continue, please select a Pokemon of yours,"+
      " we will match it up with any possible matches and allow you to choose a"+
      " match."))
      pbFadeOutIn(99999){
       scene=PokemonStorageScene.new
       screen=PokemonStorageScreen.new(scene,$PokemonStorage)
       $choice = choice = screen.pbChoosePokemon
      }
      choice = $choice
      if choice == nil
        return
      else
        party = choice[0] == -1
        pkmn = $Trainer.party[choice[1]].clone
        pkmn = $PokemonStorage[choice[0]][choice[1]].clone if !party
        if pkmn
          list = GTSCore.getPokemonListFromWanted(pkmn)
          if list[0] == "nothing"
            Kernel.pbMessage(_INTL("No Pokemon was found."))
          else
            pokemonList = []
            for i in list
              pokemonList.push(GTSCore.downloadPokemon(i).to_pokemon)
            end
            loop do
              scene=PokemonSummaryScene.new
              screen=PokemonSummary.new(scene)
              index = screen.pbStartGTSScreen(pokemonList,0)
              if index == false
                break
              else
                wantedData = GTSCore.downloadWantedData(list[index])
                for i in 0...wantedData.length
                  wantedData[i] = wantedData[i].to_i
                end
                Kernel.pbMessage(_INTL("To confirm, this is the wanted data."))
                scene=PokemonSummaryScene.new
                screen=PokemonSummary.new(scene)
                takes = screen.pbStartGTSWantedScreen(wantedData,0)
                if takes
                  if GTS.finishTrade(pkmn, pokemonList[index], true, list[index])
                    if party
                      pbRemovePokemonAt(choice[1])
                    else
                      $PokemonStorage[choice[0]][choice[1]] = nil
                    end
                    pbSave
                    return true
                  end
                else
                  break
                end
              end
            end
          end
        end
      end
    elsif @index == 2
      loop do
        params=ChooseNumberParams.new
        params.setRange(1,99999999)
        params.setInitialValue(1)
        params.setCancelValue(-1)
        id=Kernel.pbMessageChooseNumber(
           _INTL("Select the online ID."),params)
        return if id < 1
        if id == $PokemonGlobal.onlineID
          Kernel.pbMessage(_INTL("You cannot search by your own online ID!"))
        else
          break
        end
      end
      if !GTSCore.hasPokemonUploaded?(id)
        Kernel.pbMessage(_INTL("No Pokemon with this online ID exists!"))
        return
      end
      gpkmn = GTSCore.downloadPokemon(id).to_pokemon
      wantedData = GTSCore.downloadWantedData(id)
      for i in 0...wantedData.length
        wantedData[i] = wantedData[i].to_i
      end
      scene=PokemonSummaryScene.new
      screen=PokemonSummary.new(scene)
      index = screen.pbStartGTSScreen([gpkmn],0)
      if index
        scene=PokemonSummaryScene.new
        screen=PokemonSummary.new(scene)
        takes = screen.pbStartGTSWantedScreen(wantedData,0)
        if takes
          pbFadeOutIn(99999){
           scene=PokemonStorageScene.new
           screen=PokemonStorageScreen.new(scene,$PokemonStorage)
           $choice = choice = screen.pbChoosePokemon
          }
          choice = $choice
          if choice == nil
            return
          else
            party = choice[0] == -1
            pkmn = $Trainer.party[choice[1]].clone
            pkmn = $PokemonStorage[choice[0]][choice[1]].clone if !party
            
            if pkmn.species != wantedData[0] || pkmn.level < wantedData[1] ||
              pkmn.level > wantedData[2] ||
              (wantedData[3] != -1 && pkmn.gender != wantedData[3])
              Kernel.pbMessage(_INTL("The selected Pokemon does not match the"+
              " wanted requirments."))
            else      
              if GTS.finishTrade(pkmn, gpkmn, true, id)
                if party
                  pbRemovePokemonAt(choice[1])
                else
                  $PokemonStorage[choice[0]][choice[1]] = nil
                end
                pbSave
                return true
              end
            end
          end
        end
      end
    else
      @exit = true
    end
  end
end

########## GTS Wanted Data, shows a screen on which you can create wanted data
class GTSWantedData
  def initialize(data=nil)
    @exit = false
    @wanted_data = [-1, 1, 100, -1]
    @wanted_data = data if data!=nil
    @index = 0
  end
  
  def create_spriteset
    pbDisposeSpriteHash(@sprites) if @sprites
    @sprites = {}
    
    @sprites["background"] = IconSprite.new
    @sprites["background"].setBitmap("Graphics/Pictures/GTS/Background")
    
    pbSetSystemFont(@sprites["background"].bitmap)
    textpos=[          
       ["Pokemon Wanted Data",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
   #    ["Online ID: #{$PokemonGlobal.onlineID}",350,6,2,Color.new(248,248,248),
   #    Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["background"].bitmap,textpos)
    
    @sprites["0"] = IconSprite.new
    @sprites["0"].setBitmap("Graphics/Pictures/GTS/Pokemon_bar")
    @sprites["0"].x = Graphics.width / 2
    @sprites["0"].x -= @sprites["0"].bitmap.width / 2
    @sprites["0"].y = 44
    
    @sprites["0t"] = IconSprite.new
    @sprites["0t"].bitmap = Bitmap.new(@sprites["0"].bitmap.width, 
    @sprites["0"].bitmap.height)
    @sprites["0t"].x = @sprites["0"].x
    @sprites["0t"].y = @sprites["0"].y
    
    @sprites["1"] = IconSprite.new
    @sprites["1"].setBitmap("Graphics/Pictures/GTS/Gender_bar")
    @sprites["1"].x = Graphics.width / 2
    @sprites["1"].x -= @sprites["1"].bitmap.width / 2
    @sprites["1"].y = 82
    
    @sprites["1t"] = IconSprite.new
    @sprites["1t"].bitmap = Bitmap.new(@sprites["1"].bitmap.width, 
    @sprites["1"].bitmap.height)
    @sprites["1t"].x = @sprites["1"].x
    @sprites["1t"].y = @sprites["1"].y
    
    @sprites["2"] = IconSprite.new
    @sprites["2"].setBitmap("Graphics/Pictures/GTS/Level_bar")
    @sprites["2"].x = Graphics.width / 2
    @sprites["2"].x -= @sprites["2"].bitmap.width / 2
    @sprites["2"].y = 120
    
    @sprites["2t"] = IconSprite.new
    @sprites["2t"].bitmap = Bitmap.new(@sprites["2"].bitmap.width, 
    @sprites["2"].bitmap.height)
    @sprites["2t"].x = @sprites["2"].x
    @sprites["2t"].y = @sprites["2"].y
    
    @sprites["3"] = IconSprite.new
    @sprites["3"].setBitmap("Graphics/Pictures/GTS/ability_bar")
    @sprites["3"].x = Graphics.width / 2
    @sprites["3"].x -= @sprites["3"].bitmap.width / 2
    @sprites["3"].y = 158
    
    @sprites["3t"] = IconSprite.new
    @sprites["3t"].bitmap = Bitmap.new(@sprites["3"].bitmap.width, 
    @sprites["3"].bitmap.height)
    @sprites["3t"].x = @sprites["3"].x
    @sprites["3t"].y = @sprites["3"].y
    
    @sprites["8"] = IconSprite.new
    @sprites["8"].setBitmap("Graphics/Pictures/GTS/Search_bar")
    @sprites["8"].x = Graphics.width / 2
    @sprites["8"].x -= @sprites["8"].bitmap.width / 2
    @sprites["8"].y = 348
    
    @sprites["8t"] = IconSprite.new
    @sprites["8t"].bitmap = Bitmap.new(@sprites["8"].bitmap.width, 
    @sprites["8"].bitmap.height)
    @sprites["8t"].x = @sprites["8"].x
    @sprites["8t"].y = @sprites["8"].y
    
    @sprites["5"] = IconSprite.new
    @sprites["5"].setBitmap("Graphics/Pictures/GTS/ability_bar copy")
    @sprites["5"].x = Graphics.width / 2
    @sprites["5"].x -= @sprites["5"].bitmap.width / 2
    @sprites["5"].y = 234
    
    @sprites["5t"] = IconSprite.new
    @sprites["5t"].bitmap = Bitmap.new(@sprites["5"].bitmap.width, 
    @sprites["5"].bitmap.height)
    @sprites["5t"].x = @sprites["5"].x
    @sprites["5t"].y = @sprites["5"].y
    
    @sprites["6"] = IconSprite.new
    @sprites["6"].setBitmap("Graphics/Pictures/GTS/ability_bar copy 2")
    @sprites["6"].x = Graphics.width / 2
    @sprites["6"].x -= @sprites["6"].bitmap.width / 2
    @sprites["6"].y = 272
    
    @sprites["6t"] = IconSprite.new
    @sprites["6t"].bitmap = Bitmap.new(@sprites["6"].bitmap.width, 
    @sprites["6"].bitmap.height)
    @sprites["6t"].x = @sprites["6"].x
    @sprites["6t"].y = @sprites["6"].y
    
    @sprites["7"] = IconSprite.new
    @sprites["7"].setBitmap("Graphics/Pictures/GTS/ability_bar copy 3")
    @sprites["7"].x = Graphics.width / 2
    @sprites["7"].x -= @sprites["7"].bitmap.width / 2
    @sprites["7"].y = 310
    
    @sprites["7t"] = IconSprite.new
    @sprites["7t"].bitmap = Bitmap.new(@sprites["7"].bitmap.width, 
    @sprites["7"].bitmap.height)
    @sprites["7t"].x = @sprites["7"].x
    @sprites["7t"].y = @sprites["7"].y
    
    @sprites["4"] = IconSprite.new
    @sprites["4"].setBitmap("Graphics/Pictures/GTS/ability_bar copy 4")
    @sprites["4"].x = Graphics.width / 2
    @sprites["4"].x -= @sprites["4"].bitmap.width / 2
    @sprites["4"].y = 196
    
    @sprites["4t"] = IconSprite.new
    @sprites["4t"].bitmap = Bitmap.new(@sprites["8"].bitmap.width, 
    @sprites["4"].bitmap.height)
    @sprites["4t"].x = @sprites["4"].x
    @sprites["4t"].y = @sprites["4"].y
    
    @sprites["9"] = GTS_Button.new(Graphics.width/2, 290, "Back")
    @sprites["9"].x -= @sprites["5"].bitmap.width / 2
    @sprites["9"].y = 386
    
    pbSetSystemFont(@sprites["0"].bitmap)
    textpos=[          
       ["Species",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["0"].bitmap,textpos)

    pbSetSystemFont(@sprites["1"].bitmap)
    textpos=[          
       ["Gender",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["1"].bitmap,textpos)

    pbSetSystemFont(@sprites["2"].bitmap)
    textpos=[          
       ["Ability",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["2"].bitmap,textpos)

    pbSetSystemFont(@sprites["3"].bitmap)
    textpos2=[          
       ["Item",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["3"].bitmap,textpos2)

    
      pbSetSystemFont(@sprites["4"].bitmap)
    textpos2=[          
       ["Nature",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["4"].bitmap,textpos2)

        pbSetSystemFont(@sprites["5"].bitmap)
    textpos2=[          
       ["Nickname",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["5"].bitmap,textpos2)

        pbSetSystemFont(@sprites["6"].bitmap)
    textpos2=[          
       ["IVs",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["6"].bitmap,textpos2)

    
        pbSetSystemFont(@sprites["7"].bitmap)
    textpos2=[          
       ["Moves",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["7"].bitmap,textpos2)

    pbSetSystemFont(@sprites["8"].bitmap)
    textpos=[          
       ["Generate Egg!",
       #@sprites["4"].bitmap.width / 2, 2,2,Color.new(248,248,248),
       70,0,0,Color.new(248,248,248),
       Color.new(40,40,40)],       
    ]
    pbDrawTextPositions(@sprites["8"].bitmap,textpos)
    
    bit = Bitmap.new("Graphics/Pictures/GTS/Select")
    @sprites["selection_l"] = IconSprite.new
    @sprites["selection_l"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
    @sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))
    
    @sprites["selection_r"] = IconSprite.new
    @sprites["selection_r"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
    @sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))
    
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["#{@index}"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    
    drawWantedData
  end
  
  def drawWantedData
    #Kernel.pbMessage("1")
    @sprites["0t"].bitmap.clear
    s = "????"
    s = pbGetMessage(MessageTypes::Species,@wanted_data[0],true) if @wanted_data[0] > 0
    pbSetSystemFont(@sprites["0t"].bitmap)
    textpos=[          
       [s,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["0t"].bitmap,textpos)
    
    @sprites["1t"].bitmap.clear
#    g = "Either"
#    g = "Male" if @wanted_data[3] == 0
#    g = "Female" if @wanted_data[3] == 1
    
  #  if @wanted_data[3] == nil || @wanted_data[3] == 0 || @wanted_data[3] == -1
        dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@wanted_data[0],18)
    genderbyte=dexdata.fgetb
    dexdata.close
    @wanted_data[3]="Male" if @wanted_data[3] == nil || @wanted_data[3] == 0 || @wanted_data[3] == -1
    case genderbyte
      when 255
        @wanted_data[3]="Genderless"
      when 254
        @wanted_data[3]="Female"
      when 0
        @wanted_data[3]="Male"
      end
    #end
    @wanted_data[3]="Female" if @wanted_data && @wanted_data.is_a?(Array) && @wanted_data[3]==1
    @wanted_data[3]="Genderless" if @wanted_data && @wanted_data.is_a?(Array) &&  @wanted_data[3]==2
    g = @wanted_data[3].to_s
    #  raise g.to_s

    pbSetSystemFont(@sprites["1t"].bitmap)
    textpos=[          
       [g,325,2,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["1t"].bitmap,textpos)
    
    @sprites["2t"].bitmap.clear
    if @wanted_data[0] > 0
    abils=[]; ret=[[],[]]
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@wanted_data[0],29)
    abils.push(dexdata.fgetb)
    abils.push(dexdata.fgetb)
    if abils[1]<=0
        abils[1]=abils[0]
    end
    
    pbDexDataOffset(dexdata,@wanted_data[0],37)
    abils.push(dexdata.fgetb)
    dexdata.close
    for i in 0...abils.length
      if abils[i]>0 # && !ret[0].include?(abils[i])
        ret[0].push(abils[i]); ret[1].push(i)
      end
    end    
#    Kernel.pbMessage("true") if @wanted_data
#    Kernel.pbMessage("true "+@wanted_data.length.to_s)
#    Kernel.pbMessage("very "+@wanted_data[4].to_s)
    @wanted_data[4]=0 if @wanted_data[4] == nil
    lr = PBAbilities.getName(ret[0][@wanted_data[4]]) 
    #lr = (@wanted_data[4])
    pbSetSystemFont(@sprites["2t"].bitmap)
    textpos=[          
       [lr,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["2t"].bitmap,textpos)

    
    @sprites["3t"].bitmap.clear


    if @wanted_data[5] != nil && @wanted_data[5] > 0
      s = PBItems.getName(@wanted_data[5]) 
      pbSetSystemFont(@sprites["3t"].bitmap)
      textpos=[          
         [s,325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
      ]
      pbDrawTextPositions(@sprites["3t"].bitmap,textpos)
    end
  
    @sprites["4t"].bitmap.clear

  
    if @wanted_data[6] != nil && @wanted_data[6].is_a?(String) && @wanted_data[6] != ""
      #s = PBItems.getName(@wanted_data[5]) 
      pbSetSystemFont(@sprites["4t"].bitmap)
      textpos=[          
         [@wanted_data[6],325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
      ]
      pbDrawTextPositions(@sprites["4t"].bitmap,textpos)
    end    
    @sprites["5t"].bitmap.clear

    if @wanted_data[7] != nil && @wanted_data[7].is_a?(String) && @wanted_data[7] != ""
      #s = PBItems.getName(@wanted_data[5]) 
      pbSetSystemFont(@sprites["5t"].bitmap)
      textpos=[          
         [@wanted_data[7],325,4,2,Color.new(248,248,248),Color.new(40,40,40)],
      ]
      pbDrawTextPositions(@sprites["5t"].bitmap,textpos)
    end 
    if @wanted_data[8] != nil && @wanted_data[8].is_a?(Array) && @wanted_data[8][0] != nil
    #s = PBItems.getName(@wanted_data[5]) 
    pbSetSystemFont(@sprites["6t"].bitmap)
    qq=@wanted_data[8][0].to_s+"/"+@wanted_data[8][1].to_s+"/"+@wanted_data[8][2].to_s+"/"+@wanted_data[8][3].to_s+"/"+@wanted_data[8][4].to_s+"/"+@wanted_data[8][5].to_s
    textpos=[          
       [qq,322,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["6t"].bitmap,textpos)
  end 
    
    
    
    end 
  end
  
  def main
    if !@exit
      Graphics.freeze
      create_spriteset
      Graphics.transition
      loop do
        Graphics.update
        Input.update
        update
        break if @exit
      end
    end
    #Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    Graphics.transition
    return @wanted_data 
  end
  
  def update
    pbUpdateSpriteHash(@sprites)
    
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["#{@index}"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    
    if Input.trigger?(Input::B)
      pbPlayCancelSE
      #@wanted_data = -1
      @exit = true
    end
    
    if Input.trigger?(Input::C)
      pbPlayDecisionSE
      do_command
    end
    
    if Input.trigger?(Input::UP)
      @index -= 1
      if @index < 0
        @index = 8
      end
    end
    if Input.trigger?(Input::DOWN)
      @index += 1
      if @index > 8
        @index = 0
      end
    end
  end
  
  def do_command
    #      Kernel.pbMessage(""+@index.to_s)
    if @index == 0
      msg = ""
      commands2 = ["Cancel"]
      if GTSSettings::SORT_MODE == "Alphabetical"
        sL = "A"
        for i in 0...26
          s = sL.clone
          s[0] += i
          commands2.push(s)
        end
        msg = "Choose a Letter."
        c2 = Kernel.pbMessage(msg, commands2, 0, nil, 1)
        if c2 > 0
          aryofspecies=[]
          for i in 1..PBSpecies.maxValue-1
#           Kernel.pbMessage(""+pbGetMessage(MessageTypes::Species,i,true)[0,1].to_s)
            aryofspecies.push(i) if Kernel.checkIsIDLegal(i) && pbGetMessage(MessageTypes::Species,i,true)[0,1] == commands2[c2]
          end
          s = GTS.orderSpecies(aryofspecies)
          @wanted_data[0] = s[0] if s[0] > 0
        end
      end
    elsif @index == 1
      cmds=[]
      #Kernel.pbMessage("1")
      dexdata=pbOpenDexData
      pbDexDataOffset(dexdata,@wanted_data[0],18)
      genderbyte=dexdata.fgetb
      dexdata.close
      case genderbyte
      when 255
        cmds.push("Genderless")
      when 254
        cmds.push("Female")
      when 0
        cmds.push("Male")
      else
        cmds.push("Male")
        cmds.push("Female")
      end
      @wanted_data[3] = Kernel.pbMessage("Which gender do you want", cmds)
      #     @wanted_data[3] + 1, nil, @wanted_data[3]+1) - 1
      #     @wanted_data[3]=Kernel.pbMessage("Which gender do you want?",cmds)
    elsif @index == 2
      if @wanted_data[0] < 1
        Kernel.pbMessage("Select a species before selecting an ability.")
      else
        # temppoke=PokeBattle_Pokemon.new(@wanted_data[0],1)
        ary=[]
        abils=[]; ret=[[],[]]
        dexdata=pbOpenDexData
        pbDexDataOffset(dexdata,@wanted_data[0],29)
        abils.push(dexdata.fgetb)   
        abils.push(dexdata.fgetb)
        if abils[1]<=0
          abils[1]=abils[0]
        end
        pbDexDataOffset(dexdata,@wanted_data[0],37)
        abils.push(dexdata.fgetb)
        dexdata.close
        for i in 0...abils.length
          if abils[i]>0# && !ret[0].include?(abils[i])
            ret[0].push(abils[i])
            ret[1].push(i)
          end
        end 
        #Kernel.pbMessage(ret[0].length.to_s)
        #    @wanted_data[4]=0 if @wanted_data[4] == nil
        #    lr = PBAbilities.getName(ret[0][@wanted_data[4]])
        for i in 0..ret[0].length-1
          ary.push(PBAbilities.getName(ret[0][i]))
        end
        @wanted_data[4] = Kernel.pbMessage("Which ability would you like?", ary)
      end
    elsif @index == 3
      if @wanted_data[0] < 1
        Kernel.pbMessage("Select a species before selecting an item   .")
      else
        ary=[]
        for i in 1..PBItems.maxValue-1
          #        Kernel.pbMessage(""+pbGetMessage(MessageTypes::Species,i,true)[0,1].to_s)
          ary.push(i) if Kernel.checkIsItemLegal(i)# && pbGetMessage(MessageTypes::Species,i,true)[0,1] == commands2[c2]
        end
        ary=ary.sort
        s = GTS.orderItems(ary)
        @wanted_data[5] = s[0] if s[0] > 0
        #  if @wanted_data[0] > 0
        #    @exit = true
        #  else
        #    pbPlayCancelSE
        #  end
      end
    elsif @index == 4
      if @wanted_data[0] < 1
        Kernel.pbMessage("Select a species before selecting a nature.")
      else
        commands=[]
        (PBNatures.getCount).times do |i|
          commands.push(PBNatures.getName(i))
        end
        # Break
        temp=Kernel.pbMessage("Select a nature.",commands)
        @wanted_data[6]=commands[temp]
      end
    elsif @index == 5
      if @wanted_data[0] < 1
        Kernel.pbMessage("Select a species before selecting a nickname.")
      else
        # Break (message,currenttext,passwordbox,maxlength
        temp=Kernel.pbMessageFreeText("Select a nickname.","",false,10)
        @wanted_data[7]=temp
      end
      #@wanted_data = -1
      #@exit = true
    elsif @index == 6
      if @wanted_data[0] < 1
        Kernel.pbMessage("Select a species before selecting IVs.")
      else
        for i in 0..8
          k = i.to_s
          @sprites[k+"t"].bitmap.clear
        end
        scene=GTSWantedDataIVs.new(@wanted_data)
        @wanted_data=scene.main
      end
      #moves
    elsif @index == 7 
      if @wanted_data[0] < 1
        Kernel.pbMessage("Select a species before selecting moves.")
      else
        for i in 0..8
          k = i.to_s
            @sprites[k+"t"].bitmap.clear
        end
        scene=GTSWantedDataMoves.new(@wanted_data)
        @wanted_data=scene.main
      end
    elsif @index == 8
      canDo=true
      if @wanted_data[0] < 1
        Kernel.pbMessage("No species is defined.")
        canDo=false
      end
      if @wanted_data[5] == nil || @wanted_data[5] < 1
        Kernel.pbMessage("No item is defined.")
        canDo=false
      end
      if @wanted_data[6] == nil || @wanted_data[6] == ""
        Kernel.pbMessage("No nature is defined.")
        canDo=false
      end
      if @wanted_data[7] == nil || @wanted_data[7] == ""
        Kernel.pbMessage("No nickname is defined.")
        canDo=false
      end
      if @wanted_data[8] == nil || !@wanted_data[8].is_a?(Array)
        Kernel.pbMessage("No IVs are defined.")
        canDo=false
      end
      if @wanted_data[9] == nil || !@wanted_data[9].is_a?(Array) || (@wanted_data[9][0] == 0 && @wanted_data[9][1] == 0 && @wanted_data[9][2] == 0 && @wanted_data[9][3] == 0)
        Kernel.pbMessage("No moves are defined.")
        canDo=false
      else
        if canDo
          hasGenerated=false
          while !hasGenerated do
              temp=Kernel.pbMessageFreeText("Enter file name to export to.","",false,10)
              temp=temp+".txt" if !temp.include?(".txt")
              if !File::exists?("Eggs/"+temp)
                File.open("Eggs/"+temp, 'w') do |f2|
                tstring = @wanted_data[0].to_s
                tstring = tstring + ","
                tstring = tstring + "\""+@wanted_data[7]+"\""
                tstring = tstring + ","
                tstring = tstring + @wanted_data[5].to_s
                tstring = tstring + ","
                tstring = tstring + @wanted_data[4].to_s
                tstring = tstring + ","
                tstring = tstring + @wanted_data[3].to_s
                tstring = tstring + ","
                tstring = tstring + @wanted_data[6]
                tstring = tstring + ","
                for i in @wanted_data[8]
                  tstring = tstring + i.to_s
                  tstring = tstring + ","
                end
                for i in @wanted_data[9]
                  tstring = tstring + i.to_s
                  tstring = tstring + ","
                end
                f2.puts(tstring)
                Kernel.pbMessage("Egg saved to \"Eggs\" folder.")
                hasGenerated=true
                @exit=true
              end

              else
                Kernel.pbMessage("This file already exists.")
              end
              
            end
          end
        end
      end
      drawWantedData
    end
  end

=begin
Kernel.pbMessageFreeText
      params=ChooseNumberParams.new
      params.setRange(1,PBExperience::MAXLEVEL)
      params.setInitialValue(@wanted_data[1])
      params.setCancelValue(@wanted_data[1])
      @wanted_data[1]=Kernel.pbMessageChooseNumber(
         _INTL("Set the Minimum wanted level."),params)
      params=ChooseNumberParams.new
      params.setRange(1,PBExperience::MAXLEVEL)
      params.setInitialValue(@wanted_data[2])
      params.setCancelValue(@wanted_data[2])
      @wanted_data[2]=Kernel.pbMessageChooseNumber(
         _INTL("Set the Maximum wanted level."),params)

=end
########## Scene GTS Main GTS Functionality here.
class Scene_GTS
  def initialize
        #Kernel.pbMessage("-5")

    @index = 0
        #Kernel.pbMessage("-4")

    @exit = false
       #Kernel.pbMessage("-3")
 
   # @uploaded = GTSCore.hasPokemonUploaded?
  end
  
  def create_spriteset
      #  Kernel.pbMessage("-1")

    pbDisposeSpriteHash(@sprites) if @sprites
     #   Kernel.pbMessage("0")

    @sprites = {}
    #    Kernel.pbMessage("0.5")

    @sprites["background"] = IconSprite.new
   # Kernel.pbMessage("1")
    @sprites["background"].setBitmap("Graphics/Pictures/GTS/Background")
        #Kernel.pbMessage("2")

    pbSetSystemFont(@sprites["background"].bitmap)
    textpos=[          
       ["Egg Generator",100,6,2,Color.new(248,248,248),Color.new(40,40,40)],
     #  ["Online ID: #{$PokemonGlobal.onlineID}",350,6,2,Color.new(248,248,248),
     #  Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["background"].bitmap,textpos)
    
    @sprites["0"] = GTS_Button.new(Graphics.width/2, 100, "Create Egg")
    @sprites["0"].x -= @sprites["0"].bitmap.width / 2
    
 #   t = "Deposit"
   # t = "Summary" if @uploaded
    
 #   @sprites["1"] = GTS_Button.new(Graphics.width/2, 200, t)
 #   @sprites["1"].x -= @sprites["1"].bitmap.width / 2
    
    @sprites["1"] = GTS_Button.new(Graphics.width/2, 300, "Exit")
    @sprites["1"].x -= @sprites["1"].bitmap.width / 2
    
    bit = Bitmap.new("Graphics/Pictures/GTS/Select")
    @sprites["selection_l"] = IconSprite.new
    @sprites["selection_l"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
    @sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))
    
    @sprites["selection_r"] = IconSprite.new
    @sprites["selection_r"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
    @sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))
    
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["0"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    
  end
  
  def main
    #   Kernel.pbMessage("-0.5")
    #  Graphics.freeze
    #        Kernel.pbMessage("-0.4")
    #Kernel.pbMessage("1")
    #create_spriteset
    #      Kernel.pbMessage("-0.3")
    if !@exit
      Graphics.freeze
      create_spriteset
      Graphics.transition
      loop do
        #break if @exit
        Graphics.update
        Input.update
        update
        break if @exit
      end
    end
    #Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    Graphics.transition
  end
  
  #Graphics.freeze
  #    create_spriteset
  #    Graphics.transition
  #    loop do
  #      Graphics.update
  #      Input.update
  #      update
  #      break if @exit
  #    end
  #    Graphics.freeze
  #    pbDisposeSpriteHash(@sprites)
  #    return @wanted_data 
  
  def update
    pbUpdateSpriteHash(@sprites)
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["0"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    
    if Input.trigger?(Input::UP)
      
      if @index == 0
        @index = 1
      else
        @index -= 1  
      end
      
    end
    
    if Input.trigger?(Input::DOWN)
      @index += 1
      if @index > 1
        @index = 0
      end
    end
    
    if Input.trigger?(Input::B)
      pbPlayCancelSE
      #@exit = true #lookhere
      pbEndScene
    end
    
    if Input.trigger?(Input::C)
      pbPlayDecisionSE
      do_command
    end
    
  end
  
  def do_command
    @uploaded=false
    if @index == 0
      Graphics.freeze
      scene = GTSWantedData.new
      @sprites["background"].dispose
      data = scene.main
      create_spriteset
      Graphics.transition
    elsif @index == 4
      if @uploaded
        GTS.summary
        @uploaded = GTSCore.hasPokemonUploaded?
        create_spriteset
      else
        pbFadeOutIn(99999){
         scene=PokemonStorageScene.new
         screen=PokemonStorageScreen.new(scene,$PokemonStorage)
         $choice = screen.pbChoosePokemon
        }
        choice = $choice
        return false if choice == nil
        pkmn = $Trainer.party[choice[1]]
        pkmn = $PokemonStorage[choice[0]][choice[1]] if choice[0] >= 0
        if choice[0] == -1
          if $Trainer.party.length == 1
            Kernel.pbMessage(_INTL("You cannot deposit your last Pokemon in your party!"))
            return
          end
        end
        if pkmn.moves[0].id > 559 || pkmn.moves[1].id > 559 || pkmn.moves[2].id > 559 || pkmn.moves[3].id > 559
            Kernel.pbMessage(_INTL("This Pokemon has an illegal move for the GTS!"))
            return
          end
          if pkmn.item > 525 
            Kernel.pbMessage(_INTL("This Pokemon has an illegal item for the GTS!"))
            return
        end
        
        Graphics.freeze
        scene = GTSWantedData.new
        @sprites["background"].dispose
        data = scene.main
        create_spriteset
        Graphics.transition
        if GTSCore.uploadPokemon(pkmn, data)
     #     $PokemonGlobal.onlinePokemon = pkmn.clone
          if choice[0] >= 0
            $PokemonStorage[choice[0]][choice[1]] = nil
          else
            pbRemovePokemonAt(choice[1])
          end
          pbSave
          @uploaded = true
          create_spriteset
        end
      end
    else
      pbEndScene
      #@exit = true
    #  $scene=pbCallTitle
    end
  end
    def pbEndScene
    pbFadeOutAndHide(@sprites)
   #   Kernel.pbMessage("1")
    @exit=true
   #   Kernel.pbMessage("2")
    pbDisposeSpriteHash(@sprites)
    #     Kernel.pbMessage("4")
 pbRefreshSceneMap
     #     Kernel.pbMessage("4")

    
     # Kernel.pbMessage("5")
  end
  
end

################################################################################
# GTS Summary Scenes
# By Hansiec
# Summary Modifications for GTS
################################################################################
=begin
class PokemonSummary
  
  def pbStartGTSScreen(party,partyindex)
    @scene.pbStartScene(party,partyindex)
    ret=@scene.pbGTSScene
    @scene.pbEndScene
    return ret
  end
  
  def pbStartGTSWantedScreen(party,partyindex)
    @scene.pbStartGTSWantedScene(party)
    ret=@scene.pbGTSWantedScene(party)
    @scene.pbEndScene
    return ret
  end
  
end

class PokemonSummaryScene
  
  def pbStartGTSWantedScene(wantedData)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @party=nil
    @partyindex=0
    @pokemon=nil
    @sprites={}
    pk = PokeBattle_Pokemon.new(wantedData[0], 1)
    @typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["pokemon"]=PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap(pk)
    @sprites["pokemon"].mirror=false
    @sprites["pokemon"].color=Color.new(0,0,0,0)
    pbPositionPokemonSprite(@sprites["pokemon"],40,144)
    @sprites["pokeicon"]=PokemonBoxIcon.new(pk,@viewport)
    @sprites["pokeicon"].x=14
    @sprites["pokeicon"].y=52
    @sprites["pokeicon"].mirror=false
    @sprites["pokeicon"].visible=false
    @sprites["movepresel"]=MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible=false
    @sprites["movepresel"].preselected=true
    @sprites["movesel"]=MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible=false
    @page=0
    drawPageOneGTSWanted(wantedData)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  def pbGTSScene
    pbPlayCry(@pokemon)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        if Kernel.pbConfirmMessage(_INTL("Stop looking for a Pokemon?"))
          return false
        end
      end
      dorefresh=false
      if Input.trigger?(Input::C)
          if Kernel.pbConfirmMessage(_INTL("Is this the Pokemon you want?"))
            break
          end
      end
      if Input.trigger?(Input::UP) && @partyindex>0
        pbGoToPrevious
        @pokemon=@party[@partyindex]
        @sprites["pokemon"].setPokemonBitmap(@pokemon)
        @sprites["pokemon"].color=Color.new(0,0,0,0)
        pbPositionPokemonSprite(@sprites["pokemon"],40,144)
        dorefresh=true
        pbPlayCry(@pokemon)
      end
      if Input.trigger?(Input::DOWN) && @partyindex<@party.length-1
        pbGoToNext
        @pokemon=@party[@partyindex]
        @sprites["pokemon"].setPokemonBitmap(@pokemon)
        @sprites["pokemon"].color=Color.new(0,0,0,0)
        pbPositionPokemonSprite(@sprites["pokemon"],40,144)
        dorefresh=true
        pbPlayCry(@pokemon)
      end
      if Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage=@page
        @page-=1
        @page=0 if @page<0
        @page=4 if @page>4
        dorefresh=true
        if @page!=oldpage # Move to next page
          pbPlayCursorSE()
          dorefresh=true
        end
      end
      if Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage=@page
        @page+=1
        @page=0 if @page<0
        @page=4 if @page>4
        if @page!=oldpage # Move to next page
          pbPlayCursorSE()
          dorefresh=true
        end
      end
      if dorefresh
        case @page
          when 0
            drawPageOne(@pokemon)
          when 1
            drawPageTwo(@pokemon)
          when 2
            drawPageThree(@pokemon)
          when 3
            drawPageFour(@pokemon)
          when 4
            drawPageFive(@pokemon)
        end
      end
    end
    return @partyindex
  end
  
  def pbGTSWantedScene(wantedData)
    pbPlayCry(wantedData[0])
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        if Kernel.pbConfirmMessage(_INTL("Decline this trade?"))
          return false
        end
      end
      dorefresh=false
      if Input.trigger?(Input::C)
        if Kernel.pbConfirmMessage(_INTL("Accept this trade?"))
          return true
        end
      end
      if dorefresh
        drawPageOneGTSWanted(wantedData)
      end
    end
  end
  
  def drawPageOneGTSWanted(wantedData)
    pokemon = PokeBattle_Pokemon.new(wantedData[0], 1)
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    bit = "Graphics/Pictures/summaryGTS"
    bit = "Graphics/Pictures/summary1" if !pbResolveBitmap(bit)
    g = "Either"
    g = "Male" if wantedData[3] == 0
    g = "Female" if wantedData[3] == 1
    @sprites["background"].setBitmap(bit)
    base=Color.new(248,248,248)
    shadow=Color.new(104,104,104)
    numberbase=Color.new(64,64,64)
    numbershadow=Color.new(176,176,176)
    pbSetSystemFont(overlay)
    pokename = PBSpecies.getName(wantedData[0])
    imagepos=[]
    textpos=[
       [_INTL("WANTED INFO"),26,16,0,base,shadow],
       [_ISPRINTF("Dex No."),238,80,0,base,shadow],
       [_ISPRINTF("{1:03d}",wantedData[0]),435,80,2,numberbase,numbershadow],
       [_INTL("Species"),238,112,0,base,shadow],
       [_INTL("{1}",pokename),435,112,2,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Type"),238,144,0,base,shadow],
       [_INTL("Level"),238,176,0,base,shadow],
       [_INTL("{1} to {2}",wantedData[1], wantedData[2]),390,176,0,
       Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Gender"),238,208,0,base,shadow],
       [_INTL("{1}",g),435,208,2,Color.new(64,64,64),Color.new(176,176,176)],
    ]
    pbDrawTextPositions(overlay,textpos)
    type1rect=Rect.new(0,pokemon.type1*28,64,28)
    type2rect=Rect.new(0,pokemon.type2*28,64,28)
    if pokemon.type1==pokemon.type2
      overlay.blt(402,146,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(370,146,@typebitmap.bitmap,type1rect)
      overlay.blt(436,146,@typebitmap.bitmap,type2rect)
    end
  end
end

################################################################################
# GTS Core
# By Hansiec
# Core GTS functions (Basically this is what you need to make a complete GTS
# system)
################################################################################

module GTSCore
  
  # Tests connection to the server (not used anymore but kept for possible use)
  def self.testConnection
    x = execute("test")
    return x != ""
  rescue
    return false
  end
  
  # Our main execution method, since I'm too lazy to write GTSSettings::URL a lot
  def self.execute(action, data={})
    data["action"]=action
    return pbPostData(GTSSettings::URL, data)
  end
  
  # gets a new online ID from the server
  def self.getOnlineID
    r = execute("getOnlineID")
    return r.to_i
  end
  
  # registers our new online ID to the server
  def self.setOnlineID(id)
    r = execute("setOnlineID", {"id" => id})
    ret = r == "success"
    print "GTS Error: #{r}" if !ret && $DEBUG
    return ret
  end
  
  # checks whether you have a pokemon uploaded in the server
  def self.hasPokemonUploaded?(id=$PokemonGlobal.onlineID)
    r = execute("hasPokemonUploaded", {"id" => id})
    e = !(r == "yes" || r == "no")
    print "GTS Error: #{r}" if e && $DEBUG
    return r == "yes"
  end
  
  # sets the pokemon with the given online ID to taken
  def self.setTaken(id)
    r = execute("setTaken", {"id" => id})
    e = !r == "success"
    print "GTS Error: #{r}" if e && $DEBUG
    return r == "success"
  end
  
  # checks wether the pokemon with the give online ID is taken
  def self.isTaken(id=$PokemonGlobal.onlineID)
    r = execute("isTaken", {"id" => id})
    e = !(r == "yes" || r == "no")
    print "GTS Error: #{r}" if e && $DEBUG
    return r == "yes"
  end
  
  # uploads a pokemon to the server
  def self.uploadPokemon(pokemon, *wantedData)
    if wantedData[0].is_a?(Array)
      wantedData = wantedData[0]
    end
    pokemon.game_code = GTSSettings::GAME_CODE
    r = execute("uploadPokemon", {"id" => $PokemonGlobal.onlineID,
    "pokemon" => pokemon, "species" => pokemon.species,"level" => pokemon.level,
    "gender" => pokemon.gender, "Wspecies" => wantedData[0],
    "WlevelMin" => wantedData[1], "WlevelMax" => wantedData[2],
    "Wgender" => wantedData[3]})
    ret = r == "success"
    print "GTS Error: #{r}" if !ret && $DEBUG
    return ret
  end
  
  # uploads the newly traded pokemon to the given online ID to the server
  def self.uploadNewPokemon(id, pokemon)
    pokemon.game_code = GTSSettings::GAME_CODE
    r = execute("uploadNewPokemon", {"id" => id, "pokemon" => pokemon})
    ret = r == "success"
    print "GTS Error: #{r}" if !ret && $DEBUG
    return ret
  end
  
  # downloads a pokemon string with the given online ID
  def self.downloadPokemon(id)
    r = execute("downloadPokemon", {"id" => id})
    ret = r != ""
    print "GTS Error: #{r}" if !ret && $DEBUG
    return ret ? r : false
  end
  
  # downloads the wanted data with the given online ID
  def self.downloadWantedData(id)
    r = execute("downloadWantedData", {"id" => id})
    ret = r != ""
    print "GTS Error: #{r}" if !ret && $DEBUG
    return ret ? r.split(",") : false
  end
  
  # deletes your current pokemon from the server
  def self.deletePokemon(withdraw = true)
    r = execute("deletePokemon", {"id" => $PokemonGlobal.onlineID,
    "withdraw" => withdraw ? "y" : "n"})
    ret = r == "success"
    print "GTS Error: #{r}" if !ret && $DEBUG
    return ret
  end
  
  # gets a list of online IDs where the wanted data match up
  def self.getPokemonList(*wantedData)
    if wantedData[0].is_a?(Array)
      wantedData = wantedData[0]
    end
    r = execute("getPokemonList", {"id" => $PokemonGlobal.onlineID,
    "species" => wantedData[0], "levelMin" => wantedData[1],
    "levelMax" => wantedData[2], "gender" => wantedData[3]})
    return [r] if r == "nothing"
    if (r.include?("/,,,/"))
      return r.split("/,,,/")
    else
      return r.split(",")
    end
  end
  
  # Reverse Lookup pokemon
  def self.getPokemonListFromWanted(pokemon)
    r = execute("getPokemonListFromWanted", {"id" => $PokemonGlobal.onlineID,
    "species" => pokemon.species, "level" => pokemon.level,
    "gender" => pokemon.gender})
    return [r] if r == "nothing"
    if (r.include?("/,,,/"))
      return r.split("/,,,/")
    else
      return r.split(",")
    end
  end
  
  # installs the MYSQL tables in the server
  def self.install
    return execute("createTables")
  end
end

################################################################################
# Addons
# By Hansiec (pokemon to string and string to pokemon based from Maruno's
#             MysteryGift packer/unpacker)
# Addons to other scripts
################################################################################
=begin
class PokemonGlobalMetadata
  attr_accessor :onlineID
  attr_accessor :onlinePokemon
  attr_accessor :keepGTS
  
  alias gts_initialize initialize
  # Keep your old online ID when doing newgame to prevent "spamming" the server
  def initialize
    gts_initialize
    save = RTP.getSaveFileName("Game_"+$game_variables[96].to_s+".rxdata")
    save = RTP.getSaveFileName("Game.rxdata") if $game_variables[96]==0
    if FileTest.exist?(save)
      file = File.open(save, "rb")
      Marshal.load(file)
      Marshal.load(file)
      Marshal.load(file)
      Marshal.load(file)
      Marshal.load(file)
      Marshal.load(file)
      Marshal.load(file)
      Marshal.load(file)
      Marshal.load(file)
      Marshal.load(file)
      Marshal.load(file)
      pg = Marshal.load(file)
      file.close
      @onlineID = pg.rawOnlineID
    end
    @keepGTS = false
  end
  
  def onlineID
    if @onlineID == nil
      id = GTSCore.getOnlineID
      if id == 0
        #raise("GTS Error: Cannot get Online ID for GTS!")
      end
      if !GTSCore.setOnlineID(id)
        #raise("GTS Error: Cannot get Online ID for GTS!")
      end
      @onlineID = id
    end
    return @onlineID
  end
  
  # The rawOnlineID doesn't have the checksum to get a new ID, this is used for
  # when you do new game.
  def rawOnlineID
    if @onlineID
      return @onlineID
    else
      return nil
    end
  end
end

# Add a game_code field and to_s method to the pokemon class
class PokeBattle_Pokemon
  attr_accessor :game_code
  def to_s
    ret=[Zlib::Deflate.deflate(Marshal.dump(self))].pack("m")
    return ret
  end
end

# Add a to_pokemon method to the string class
class String
  def to_pokemon
    ret=Marshal.restore(Zlib::Inflate.inflate(unpack("m")[0]))
    return ret
  end
end

# Delete Pokemon if we began a newgame
alias pbSaveGTS pbSave
def pbSave(safesave=false)
  if !$PokemonGlobal.keepGTS
    if GTSCore.deletePokemon
      $PokemonGlobal.keepGTS=true
    end
  end
  pbSaveGTS(safesave)
end

=end

class GTSWantedDataIVs
  def initialize(data)
    @exit = false
    @wanted_data = data
    #@wanted_data = [-1, 1, 100, -1]
    @index = 0
 #   Kernel.pbMessage("1")
  end
  
  def create_spriteset
    pbDisposeSpriteHash(@sprites) if @sprites
    @sprites = {}
    
    @sprites["background"] = IconSprite.new
    @sprites["background"].setBitmap("Graphics/Pictures/GTS/Background")
    
    pbSetSystemFont(@sprites["background"].bitmap)
    textpos=[          
       ["Pokemon Wanted Data",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
   #    ["Online ID: #{$PokemonGlobal.onlineID}",350,6,2,Color.new(248,248,248),
   #    Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["background"].bitmap,textpos)
 
    @sprites["0"] = IconSprite.new
    @sprites["0"].setBitmap("Graphics/Pictures/GTS/iv0")
    @sprites["0"].x = Graphics.width / 2
    @sprites["0"].x -= @sprites["0"].bitmap.width / 2
    @sprites["0"].y = 50
    
    @sprites["0t"] = IconSprite.new
    @sprites["0t"].bitmap = Bitmap.new(@sprites["0"].bitmap.width, 
    @sprites["0"].bitmap.height)
    @sprites["0t"].x = @sprites["0"].x
    @sprites["0t"].y = @sprites["0"].y
    
    @sprites["1"] = IconSprite.new
    @sprites["1"].setBitmap("Graphics/Pictures/GTS/iv1")
    @sprites["1"].x = Graphics.width / 2
    @sprites["1"].x -= @sprites["1"].bitmap.width / 2
    @sprites["1"].y = 106
    
    @sprites["1t"] = IconSprite.new
    @sprites["1t"].bitmap = Bitmap.new(@sprites["1"].bitmap.width, 
    @sprites["1"].bitmap.height)
    @sprites["1t"].x = @sprites["1"].x
    @sprites["1t"].y = @sprites["1"].y
    
    @sprites["2"] = IconSprite.new
    @sprites["2"].setBitmap("Graphics/Pictures/GTS/iv2")
    @sprites["2"].x = Graphics.width / 2
    @sprites["2"].x -= @sprites["2"].bitmap.width / 2
    @sprites["2"].y = 162
  
    @sprites["2t"] = IconSprite.new
    @sprites["2t"].bitmap = Bitmap.new(@sprites["2"].bitmap.width, 
    @sprites["2"].bitmap.height)
    @sprites["2t"].x = @sprites["2"].x
    @sprites["2t"].y = @sprites["2"].y
    
    @sprites["3"] = IconSprite.new
    @sprites["3"].setBitmap("Graphics/Pictures/GTS/iv3")
    @sprites["3"].x = Graphics.width / 2
    @sprites["3"].x -= @sprites["3"].bitmap.width / 2
    @sprites["3"].y = 218
    
    @sprites["3t"] = IconSprite.new
    @sprites["3t"].bitmap = Bitmap.new(@sprites["3"].bitmap.width, 
    @sprites["3"].bitmap.height)
    @sprites["3t"].x = @sprites["3"].x
    @sprites["3t"].y = @sprites["3"].y
    
    @sprites["4"] = IconSprite.new
    @sprites["4"].setBitmap("Graphics/Pictures/GTS/iv4")
    @sprites["4"].x = Graphics.width / 2
    @sprites["4"].x -= @sprites["4"].bitmap.width / 2
    @sprites["4"].y = 274
    
    @sprites["4t"] = IconSprite.new
    @sprites["4t"].bitmap = Bitmap.new(@sprites["4"].bitmap.width, 
    @sprites["4"].bitmap.height)
    @sprites["4t"].x = @sprites["4"].x
    @sprites["4t"].y = @sprites["4"].y
    
    @sprites["5"] = IconSprite.new
    @sprites["5"].setBitmap("Graphics/Pictures/GTS/iv5")
    @sprites["5"].x = Graphics.width / 2
    @sprites["5"].x -= @sprites["5"].bitmap.width / 2
    @sprites["5"].y = 330
    
    @sprites["5t"] = IconSprite.new
    @sprites["5t"].bitmap = Bitmap.new(@sprites["5"].bitmap.width, 
    @sprites["5"].bitmap.height)
    @sprites["5t"].x = @sprites["5"].x
    @sprites["5t"].y = @sprites["5"].y
    
    @sprites["6"] = GTS_Button.new(Graphics.width/2, 290, "Back")
    @sprites["6"].x -= @sprites["5"].bitmap.width / 2
    @sprites["6"].y = 386
    
    pbSetSystemFont(@sprites["0"].bitmap)
    textpos=[          
       ["HP",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["0"].bitmap,textpos)

    pbSetSystemFont(@sprites["1"].bitmap)
    textpos=[          
       ["Attack",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["1"].bitmap,textpos)

    pbSetSystemFont(@sprites["2"].bitmap)
    textpos=[          
       ["Defense",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["2"].bitmap,textpos)

    pbSetSystemFont(@sprites["3"].bitmap)
    textpos2=[          
       ["Speed",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["3"].bitmap,textpos2)

    
      pbSetSystemFont(@sprites["4"].bitmap)
    textpos2=[          
       ["Sp. Atk",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["4"].bitmap,textpos2)

        pbSetSystemFont(@sprites["5"].bitmap)
    textpos2=[          
       ["Sp. Defense",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["5"].bitmap,textpos2)
    
    bit = Bitmap.new("Graphics/Pictures/GTS/Select")
    @sprites["selection_l"] = IconSprite.new
    @sprites["selection_l"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
    @sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))
    
    @sprites["selection_r"] = IconSprite.new
    @sprites["selection_r"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
    @sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))
    
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["#{@index}"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    
    drawWantedData
  end
  
  def drawWantedData
    if !@wanted_data[8].is_a?(Array)
    @wanted_data[8]=[]
      for i in 0..5
          @wanted_data[8][i]=31
      end
      
    end

        @sprites["0t"].bitmap.clear

    pbSetSystemFont(@sprites["0t"].bitmap)
    textpos=[          
       [@wanted_data[8][0].to_s,350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["0t"].bitmap,textpos)
  
        @sprites["1t"].bitmap.clear

    pbSetSystemFont(@sprites["1t"].bitmap)
    textpos=[          
       [@wanted_data[8][1].to_s,350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["1t"].bitmap,textpos)

            @sprites["2t"].bitmap.clear

    pbSetSystemFont(@sprites["2t"].bitmap)
    textpos=[          
       [@wanted_data[8][2].to_s,350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["2t"].bitmap,textpos)

            @sprites["3t"].bitmap.clear

    pbSetSystemFont(@sprites["3t"].bitmap)
    textpos=[          
       [@wanted_data[8][3].to_s,350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["3t"].bitmap,textpos)

            @sprites["4t"].bitmap.clear

    pbSetSystemFont(@sprites["4t"].bitmap)
    textpos=[          
       [@wanted_data[8][4].to_s,350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["4t"].bitmap,textpos)

            @sprites["5t"].bitmap.clear

    pbSetSystemFont(@sprites["5t"].bitmap)
    textpos=[          
       [@wanted_data[8][5].to_s,350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["5t"].bitmap,textpos)

    end 
  end
  
  def main
    if !@exit
      Graphics.freeze
      create_spriteset
      Graphics.transition
      loop do
        Graphics.update
        Input.update
        update
        break if @exit
      end
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    scene=GTSWantedData.new(@wanted_data)
    scene.main
  end
  
  def update
    if !@sprites
       #   pbDisposeSpriteHash(@sprites) if @sprites
    @sprites = {}
    
    @sprites["background"] = IconSprite.new
    @sprites["background"].setBitmap("Graphics/Pictures/GTS/Background")
  end
  
    pbUpdateSpriteHash(@sprites) 
    
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["#{@index}"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    
    if Input.trigger?(Input::B)
      pbPlayCancelSE
    #  @wanted_data #= -1
      @exit = true
    end
    
    if Input.trigger?(Input::C)
      pbPlayDecisionSE
      do_command
    end
    
    if Input.trigger?(Input::UP)
      @index -= 1
      if @index < 0
        @index = 6
        
      end
    end
    if Input.trigger?(Input::DOWN)
      @index += 1
      if @index > 6
        @index = 0
      end
    end
  end
  
  def do_command
    #      Kernel.pbMessage(""+@index.to_s)

#    if @index == 0

#    end
      if @index >= 0 && @index <= 5
        cmd2=@index
        stats=["HP","Attack","Defense","Speed","Sp. Atk","Sp. Def"]
        params=ChooseNumberParams.new
        params.setRange(0,31)
        params.setDefaultValue(@wanted_data[8][@index])
        params.setCancelValue(@wanted_data[8][@index])
        f=Kernel.pbMessageChooseNumber(
         _INTL("Set the IV for {1} (max. 31).",stats[cmd2]),params) { }
        @wanted_data[8][@index]=f
      end
      
    
    drawWantedData
  end
  
  #
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  ##
  #
  #
  #
  #


class GTSWantedDataMoves
  def initialize(data)
    @exit = false
    @wanted_data = data
    #@wanted_data = [-1, 1, 100, -1]
    @index = 0
  end
  
  def create_spriteset
    pbDisposeSpriteHash(@sprites) if @sprites
    @sprites = {}
    
    @sprites["background"] = IconSprite.new
    @sprites["background"].setBitmap("Graphics/Pictures/GTS/Background")
    
    pbSetSystemFont(@sprites["background"].bitmap)
    textpos=[          
       ["Pokemon Wanted Data",50,6,0,Color.new(248,248,248),Color.new(40,40,40)],
   #    ["Online ID: #{$PokemonGlobal.onlineID}",350,6,2,Color.new(248,248,248),
   #    Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["background"].bitmap,textpos)
 
    @sprites["0"] = IconSprite.new
    @sprites["0"].setBitmap("Graphics/Pictures/GTS/move0")
    @sprites["0"].x = Graphics.width / 2
    @sprites["0"].x -= @sprites["0"].bitmap.width / 2
    @sprites["0"].y = 50
    
    @sprites["0t"] = IconSprite.new
    @sprites["0t"].bitmap = Bitmap.new(@sprites["0"].bitmap.width, 
    @sprites["0"].bitmap.height)
    @sprites["0t"].x = @sprites["0"].x
    @sprites["0t"].y = @sprites["0"].y
    
    @sprites["1"] = IconSprite.new
    @sprites["1"].setBitmap("Graphics/Pictures/GTS/move1")
    @sprites["1"].x = Graphics.width / 2
    @sprites["1"].x -= @sprites["1"].bitmap.width / 2
    @sprites["1"].y = 135
    
    @sprites["1t"] = IconSprite.new
    @sprites["1t"].bitmap = Bitmap.new(@sprites["1"].bitmap.width, 
    @sprites["1"].bitmap.height)
    @sprites["1t"].x = @sprites["1"].x
    @sprites["1t"].y = @sprites["1"].y
    
    @sprites["2"] = IconSprite.new
    @sprites["2"].setBitmap("Graphics/Pictures/GTS/move2")
    @sprites["2"].x = Graphics.width / 2
    @sprites["2"].x -= @sprites["2"].bitmap.width / 2
    @sprites["2"].y = 220
  
    @sprites["2t"] = IconSprite.new
    @sprites["2t"].bitmap = Bitmap.new(@sprites["2"].bitmap.width, 
    @sprites["2"].bitmap.height)
    @sprites["2t"].x = @sprites["2"].x
    @sprites["2t"].y = @sprites["2"].y
    
    @sprites["3"] = IconSprite.new
    @sprites["3"].setBitmap("Graphics/Pictures/GTS/move3")
    @sprites["3"].x = Graphics.width / 2
    @sprites["3"].x -= @sprites["3"].bitmap.width / 2
    @sprites["3"].y = 305
    
    @sprites["3t"] = IconSprite.new
    @sprites["3t"].bitmap = Bitmap.new(@sprites["3"].bitmap.width, 
    @sprites["3"].bitmap.height)
    @sprites["3t"].x = @sprites["3"].x
    @sprites["3t"].y = @sprites["3"].y
    
    @sprites["4"] = GTS_Button.new(Graphics.width/2, 290, "Back")
    @sprites["4"].x -= @sprites["4"].bitmap.width / 2
    @sprites["4"].y = 390
    
    pbSetSystemFont(@sprites["0"].bitmap)
    textpos=[          
       ["Move 1",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["0"].bitmap,textpos)

    pbSetSystemFont(@sprites["1"].bitmap)
    textpos=[          
       ["Move 2",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["1"].bitmap,textpos)

    pbSetSystemFont(@sprites["2"].bitmap)
    textpos=[          
       ["Move 3",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["2"].bitmap,textpos)

    pbSetSystemFont(@sprites["3"].bitmap)
    textpos2=[          
       ["Move 4",80,0,0,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["3"].bitmap,textpos2)

    
    bit = Bitmap.new("Graphics/Pictures/GTS/Select")
    @sprites["selection_l"] = IconSprite.new
    @sprites["selection_l"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_l"].bitmap.blt(0, 0, bit, Rect.new(0, 0, 16, 16))
    @sprites["selection_l"].bitmap.blt(0, 23, bit, Rect.new(0, 16, 16, 32))
    
    @sprites["selection_r"] = IconSprite.new
    @sprites["selection_r"].bitmap = Bitmap.new(16, 46)
    @sprites["selection_r"].bitmap.blt(0, 0, bit, Rect.new(16, 0, 32, 16))
    @sprites["selection_r"].bitmap.blt(0, 23, bit, Rect.new(16, 16, 32, 32))
    
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["#{@index}"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    
    drawWantedData
  end
  
  def getMoveFor(integer)
    return integer if integer.is_a?(String)
      if integer == -1
        return "Empty"
      end
      return PBMoves.getName(integer)
  end
  
  
  def drawWantedData
    if !@wanted_data[9].is_a?(Array)
    @wanted_data[9]=[]
      for i in 0..5
          @wanted_data[9][i]=-1
      end
      
    end

        @sprites["0t"].bitmap.clear

    pbSetSystemFont(@sprites["0t"].bitmap)
    textpos=[          
       [getMoveFor(@wanted_data[9][0]),350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["0t"].bitmap,textpos)
  
        @sprites["1t"].bitmap.clear

    pbSetSystemFont(@sprites["1t"].bitmap)
    textpos=[          
       [getMoveFor(@wanted_data[9][1]),350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["1t"].bitmap,textpos)

            @sprites["2t"].bitmap.clear

    pbSetSystemFont(@sprites["2t"].bitmap)
    textpos=[          
       [getMoveFor(@wanted_data[9][2]),350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["2t"].bitmap,textpos)

            @sprites["3t"].bitmap.clear

    pbSetSystemFont(@sprites["3t"].bitmap)
    textpos=[          
       [getMoveFor(@wanted_data[9][3]),350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["3t"].bitmap,textpos)
=begin
            @sprites["4t"].bitmap.clear

    pbSetSystemFont(@sprites["4t"].bitmap)
    textpos=[          
       [getMoveFor(@wanted_data[9][4]),4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["4t"].bitmap,textpos)

            @sprites["5t"].bitmap.clear

    pbSetSystemFont(@sprites["5t"].bitmap)
    textpos=[          
       [getMoveFor(@wanted_data[9][5]),350,4,2,Color.new(248,248,248),Color.new(40,40,40)],
    ]
    pbDrawTextPositions(@sprites["5t"].bitmap,textpos)
=end
    end 
  
  def main
    Graphics.freeze
    create_spriteset
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if @exit
    end
    
    Graphics.freeze
    $tempsave=nil
    
    pbDisposeSpriteHash(@sprites)
    scene=GTSWantedData.new(@wanted_data)
    scene.main
  end
  
  def update
    if !@sprites
       #   pbDisposeSpriteHash(@sprites) if @sprites
    @sprites = {}
    
    @sprites["background"] = IconSprite.new
    @sprites["background"].setBitmap("Graphics/Pictures/GTS/Background")
  end
  
    pbUpdateSpriteHash(@sprites) 
    
    @sprites["selection_l"].x = @sprites["#{@index}"].x-2
    @sprites["selection_l"].y = @sprites["#{@index}"].y-2
    @sprites["selection_r"].x = @sprites["#{@index}"].x+
    @sprites["#{@index}"].bitmap.width-18
    @sprites["selection_r"].y = @sprites["#{@index}"].y-2
    
    if Input.trigger?(Input::B)
      pbPlayCancelSE
    #  @wanted_data #= -1
      @exit = true
    end
    
    if Input.trigger?(Input::C)
      pbPlayDecisionSE
      do_command
    end
    
    if Input.trigger?(Input::UP)
      @index -= 1
      if @index < 0
        @index = 4
      end
    end
    if Input.trigger?(Input::DOWN)
      @index += 1
      if @index > 4
        @index = 0
      end
    end
  end
  
  def do_command
    #      Kernel.pbMessage(""+@index.to_s)
    eggEmerald=pbRgssOpen("Data/eggEmerald.dat","rb")
#    if @index == 0
  #  $tempsave=[] if $tempsave == nil || !$tempsave.is_a?(Array)
#    end
      if @index >= 0 && @index <= 4
        #cmd2=@index
       # if $tempsave.length<1
        moves=[]
        numbermoves=[]
        for i in 1..PBMoves.maxValue-1
          if Kernel.isMoveLegalForSpecies(@wanted_data[0],i,eggEmerald)
            moves.push(PBMoves.getName(i))
            numbermoves.push(i)
          end
    #    end
    #    $tempsave=moves
      end
      m=Kernel.pbMessage("Choose a move.",moves)
      @wanted_data[9][@index]=numbermoves[m]
      
    end
    
        
      
    eggEmerald.close
    drawWantedData
  end
  
end

