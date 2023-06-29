################################################################################
#-------------------------------------------------------------------------------
#Author: Alexandre
#Simple trade system.
#-------------------------------------------------------------------------------
################################################################################
class Scene_Trade
  ################################################################################
  #-------------------------------------------------------------------------------
  #Author: Alexandre
  #Lets initialise the scene:
  #@list is the main trade background
  #@info is the background that appears when confirming the trade
  #-------------------------------------------------------------------------------
  ################################################################################
  def initialize(user)
    #--------
    #necessary to make sure both users have started the trade scene before
    #proceeding with the trade
    #    $network.send("<TRA start>")
    #    loop do
    #      Graphics.update
    #      Input.update
    #      message = $network.listen
    #      case message
    #      when /<TRA start>/ then break
    #      when /<TRA dead>/ then $scene = Scene_Map.new; break
    #      end
    #    end
    #--------
    @username = user
    @partysent = false
    @pokemonselected = false
    @theirparty = nil
    @theirpartylength = 0
    @theirchosen = nil
    @index = 1
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @overlay = SpriteWrapper.new(@viewport)
    @overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @overlay.z = 1000005
    @overlay2 = SpriteWrapper.new(@viewport)
    @overlay2.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @overlay2.z = 1000009
    @overlay3 = SpriteWrapper.new(@viewport)
    @overlay3.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @overlay3.z = 1000009
    @list = SpriteWrapper.new(@viewport)
    @list.visible = true
    @list.bitmap = BitmapCache.load_bitmap("Graphics/Pictures/tradebackground.png")
    @list.z = 1000004
    @selector = SpriteWrapper.new(@viewport)
    @selector.visible = true
    @selector.bitmap = BitmapCache.load_bitmap("Graphics/Pictures/boxpoint1.png")
    @selector.z = 1000006
    @waiting = Window_AdvancedTextPokemon.new("Waiting...")
    @waiting.visible = false
    @waiting.width = 120
    @waiting.x = Graphics.width / 2 - 50
    @waiting.y = 160
    @sprite = []
    @spritex = []
    @sprites = {}
    @info = SpriteWrapper.new(@viewport)
    @info.visible = true
    @info.bitmap = BitmapCache.load_bitmap("Graphics/Pictures/tradebottom.png")
    @info.z = 1000008
    @info.visible = false
    @accepted = false
    @received = false
    @listreceived = false
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Main procedure of the Scene, contains the loop that keeps it alive. When B is
  #pressed, the Trade dead message is sent to the server and the scene is disposed
  #-------------------------------------------------------------------------------
  ################################################################################
  def main
    mylist
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
      if Input.trigger?(Input::B)
        $scene = Connect.new
        $network.send("<TRA|dead>")
      end
    end
    Graphics.freeze
    @waiting.dispose
    @viewport.dispose
    @list.dispose
    @overlay.dispose
    @overlay2.dispose
    @overlay3.dispose
    @sprite[0].dispose if @sprite[0] != nil
    @sprite[1].dispose if @sprite[1] != nil
    @sprite[2].dispose if @sprite[2] != nil
    @sprite[3].dispose if @sprite[3] != nil
    @sprite[4].dispose if @sprite[4] != nil
    @sprite[5].dispose if @sprite[5] != nil
    @spritex[0].dispose if @spritex[0] != nil
    @spritex[1].dispose if @spritex[1] != nil
    @spritex[2].dispose if @spritex[2] != nil
    @spritex[3].dispose if @spritex[3] != nil
    @spritex[4].dispose if @spritex[4] != nil
    @spritex[5].dispose if @spritex[5] != nil
    @sprites["mypokemon"].dispose if @sprites["mypokemon"] != nil
    @sprites["theirpokemon"].dispose if @sprites["theirpokemon"] != nil
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Just a procedure to update the scene and check for any incoming messages
  #-------------------------------------------------------------------------------
  ################################################################################
  def update
    their_info if @received == true and @pokemonselected == true
    their_list if @listreceived == true
    message = $network.listen
    handle(message)
    @sprite[0].update if @sprite[0] != nil
    @sprite[1].update if @sprite[1] != nil
    @sprite[2].update if @sprite[2] != nil
    @sprite[3].update if @sprite[3] != nil
    @sprite[4].update if @sprite[4] != nil
    @sprite[5].update if @sprite[5] != nil
    @spritex[0].update if @spritex[0] != nil
    @spritex[1].update if @spritex[1] != nil
    @spritex[2].update if @spritex[2] != nil
    @spritex[3].update if @spritex[3] != nil
    @spritex[4].update if @spritex[4] != nil
    @spritex[5].update if @spritex[5] != nil
    @viewport.update
    @overlay.update
    @overlay2.update
    @overlay3.update
    @selector.update
    check_input
    if @pokemonselected == false and @theirparty != nil
      update_selector_input
      update_selector
    end
    @waiting.update
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Listens to incoming messages and determines what to do when trade messages are
  #received.
  #-------------------------------------------------------------------------------
  ################################################################################
  def handle(message)
    case message
    when /<TRA party=(.*)>/ #$Trainer.party dump
      theirparty($1) if @theirparty == nil
    when /<TRA offer=(.*)>/ #Trainer.party[@index - 1] dump
      receiveoffer($1) if @theirchosen == nil
    when /<TRA accepted>/
      execute_trade if @accepted == true
    when /<TRA declined>/ then trade_declined
    when /<TRA dead>/
      Kernel.pbMessage("The user exited the trade.")
      $scene = Connect.new
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Checks for input from C to select a pokemon or show the summary.
  #-------------------------------------------------------------------------------
  ################################################################################
  def check_input
    #Player's pokemon
    if Input.trigger?(Input::C) and @pokemonselected == false
      if @index >= 1 and @index <= $Trainer.party.length
        commands = [_INTL("Offer"), _INTL("Summary"), _INTL("Cancel")]
        choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands)
        if choice == 0
          serialized = [JSON.encode($Trainer.party[@index - 1])].pack("m").delete("\n")
          $network.send("<TRA|offer=" + serialized + ">")
          show_information
          @waiting.visible = true
          @pokemonselected = true
        elsif choice == 1
          scene = PokemonSummaryScene.new
          screen = PokemonSummary.new(scene)
          screen.pbStartScreen($Trainer.party, @index - 1)
        elsif choice == 2
          #do nothing
        end
      else
        #Other user's pokemon
        commands = [_INTL("Summary"), _INTL("Cancel")]
        choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands)
        if choice == 0
          scene = PokemonSummaryScene.new
          screen = PokemonSummary.new(scene)
          screen.pbStartScreen(@theirparty, @index - 1 - $Trainer.party.length)
        elsif choice == 1
          #donothing
        end
      end
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Checks for left and right input to move selector.
  #-------------------------------------------------------------------------------
  ################################################################################
  def update_selector_input
    @index += 1 if Input.trigger?(Input::RIGHT)
    @index += 1 if Input.trigger?(Input::DOWN)
    @index -= 1 if Input.trigger?(Input::LEFT)
    @index -= 1 if Input.trigger?(Input::UP)
    @index = 1 if @index > $Trainer.party.length + @theirparty.length
    @index = $Trainer.party.length + @theirparty.length if @index <= 0
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Updates the position of the selector.
  #-------------------------------------------------------------------------------
  ################################################################################
  def update_selector
    case @index
    when 1 then @selector.x = 46; @selector.y = 40
    when 2 then @selector.x = 135; @selector.y = 40
    when 3 then @selector.x = 46; @selector.y = 120
    when 4 then @selector.x = 135; @selector.y = 120
    when 5 then @selector.x = 46; @selector.y = 220
    when 6 then @selector.x = 135; @selector.y = 220
    when 7 then @selector.x = 299; @selector.y = 40
    when 8 then @selector.x = 388; @selector.y = 40
    when 9 then @selector.x = 299; @selector.y = 120
    when 10 then @selector.x = 388; @selector.y = 120
    when 11 then @selector.x = 299; @selector.y = 220
    when 12 then @selector.x = 388; @selector.y = 220
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Receives the other user's party.
  #-------------------------------------------------------------------------------
  ################################################################################
  def theirparty(data)
    @theirparty = Marshal.load(data.unpack("m")[0]) #load serialised party data
    @listreceived = true
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Display the other uer's party.
  #-------------------------------------------------------------------------------
  ################################################################################
  def their_list
    @listreceived = false

    @theirpartylength = 1 if @theirparty[0] != nil
    @theirpartylength = 2 if @theirparty[1] != nil
    @theirpartylength = 3 if @theirparty[2] != nil
    @theirpartylength = 4 if @theirparty[3] != nil
    @theirpartylength = 5 if @theirparty[4] != nil
    @theirpartylength = 6 if @theirparty[5] != nil
    for i in 0..@theirpartylength - 1
      @spritex[i] = PokemonTradeIcon.new(@theirparty[i].species, @theirparty[i].eggsteps, @theirparty[i].personalID, false, @viewport)
    end
    @spritex[0].x = 284 if @spritex[0] != nil
    @spritex[0].y = 55 if @spritex[0] != nil
    @spritex[1].x = 373 if @spritex[1] != nil
    @spritex[1].y = 55 if @spritex[1] != nil
    @spritex[2].x = 284 if @spritex[2] != nil
    @spritex[2].y = 135 if @spritex[2] != nil
    @spritex[3].x = 373 if @spritex[3] != nil
    @spritex[3].y = 135 if @spritex[3] != nil
    @spritex[4].x = 284 if @spritex[4] != nil
    @spritex[4].y = 235 if @spritex[4] != nil
    @spritex[5].x = 373 if @spritex[5] != nil
    @spritex[5].y = 235 if @spritex[5] != nil
    @spritex[0].z = 1000005 if @spritex[0] != nil
    @spritex[1].z = 1000005 if @spritex[1] != nil
    @spritex[2].z = 1000005 if @spritex[2] != nil
    @spritex[3].z = 1000005 if @spritex[3] != nil
    @spritex[4].z = 1000005 if @spritex[4] != nil
    @spritex[5].z = 1000005 if @spritex[5] != nil
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Show's information about your chosen pokemon.
  #-------------------------------------------------------------------------------
  ################################################################################
  def show_information
    @waiting.visible = false
    @info.visible = true
    pkmn = $Trainer.party[@index - 1]
    itemname = pkmn.item == 0 ? _INTL("NONE") : PBItems.getName(pkmn.item)
    imagepos = []
    @overlay2.bitmap.clear
    @typebitmap = BitmapCache.load_bitmap(_INTL("Graphics/Pictures/types.png"))
    @sprites["mypokemon"] = SpriteWrapper.new(@viewport)
    @sprites["mypokemon"].bitmap = pbLoadTradeBitmap(pkmn.species, pkmn.eggsteps, pkmn.personalID, pkmn.trainerID)
    @sprites["mypokemon"].mirror = true
    pbPositionPokemonSprite(@sprites["mypokemon"], -10, 24)
    @sprites["mypokemon"].z = 1000009
    @sprites["mypokemon"].visible = true
    @chosenpokemon = false
    move0 = pkmn.moves[0].id == 0 ? "--" : PBMoves.getName(pkmn.moves[0].id)
    move1 = pkmn.moves[1].id == 0 ? "--" : PBMoves.getName(pkmn.moves[1].id)
    move2 = pkmn.moves[2].id == 0 ? "--" : PBMoves.getName(pkmn.moves[2].id)
    move3 = pkmn.moves[3].id == 0 ? "--" : PBMoves.getName(pkmn.moves[3].id)
    textpositions = [
      [_INTL("#{pkmn.name}"), 40, 12, 2, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Lv: #{pkmn.level}"), 105, 0, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("HP: #{pkmn.hp}/#{pkmn.totalhp}"), 105, 11, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Attack: #{pkmn.attack}"), 105, 22, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Defense: #{pkmn.defense}"), 105, 33, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Speed: #{pkmn.speed}"), 105, 44, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Sp. Att: #{pkmn.spatk}"), 105, 55, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Sp. Def: #{pkmn.spdef}"), 105, 66, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Nature: #{PBNatures.getName(pkmn.nature)}"), 105, 77, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Ability: #{PBAbilities.getName(pkmn.ability)}"), 105, 88, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Move 1: #{move0}"), 105, 99, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Move 2: #{move1}"), 105, 110, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Move 3: #{move2}"), 105, 121, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Move 4: #{move3}"), 105, 132, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Item: #{itemname}"), 2, 27, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
    ]
    if pkmn.gender == 0
      textpositions.push([_INTL("♂f0 "), 90, 12, false, Color.new(120, 184, 248), Color.new(0, 120, 248)])
    elsif pkmn.gender == 1
      textpositions.push([_INTL("♀f0 "), 90, 12, false, Color.new(248, 128, 128), Color.new(168, 24, 24)])
    end
    pbSetExtraSmallFont(@overlay2.bitmap)
    pbDrawTextPositions(@overlay2.bitmap, textpositions)
    type1rect = Rect.new(0, pkmn.type1 * 28, 64, 28)
    type2rect = Rect.new(0, pkmn.type2 * 28, 64, 28)
    @overlay2.bitmap.blt(170, 4, @typebitmap, type1rect)
    @overlay2.bitmap.blt(170, 4 + 28, @typebitmap, type2rect) if pkmn.type1 != pkmn.type2
    ballimage = sprintf("Graphics/Pictures/ball%02d_0.png", pkmn.ballused)
    imagepos.push([ballimage, -4, 124, 0, 0, -1, -1])
    pbDrawImagePositions(@overlay2.bitmap, imagepos)
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Display's the user's party.
  #-------------------------------------------------------------------------------
  ################################################################################
  def mylist
    textpos = [
      [_INTL("#{$network.username}'s list"), 91, 14, 2, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("#{@username}'s list"), 390, 14, 2, Color.new(255, 255, 255), Color.new(0, 0, 0)],
    ]
    @overlay.bitmap.font.name = ["Pokemon Emerald Small", "Arial Narrow", "Arial"]
    pbDrawTextPositions(@overlay.bitmap, textpos)
    if @partysent == false
      #we must serialie the data in order to send the whole class then encode
      #in base 64 (and delete the newline that the packing causes) in order for
      #server not to go beserk (serialised data is binary, server does not understand
      #how to receive this data as it is, encoding in base 64 avoids this)
      party = [Marshal.dump($Trainer.party)].pack("m").delete("\n")
      $network.send("<TRA|party=" + party + ">")
      @partysent = true
    end
    for i in 0..$Trainer.party.length - 1
      @sprite[i] = PokemonTradeIcon.new($Trainer.party[i].species, $Trainer.party[i].eggsteps, $Trainer.party[i].personalID, false, @viewport)
    end
    @sprite[0].x = 31 if @sprite[0] != nil
    @sprite[0].y = 55 if @sprite[0] != nil
    @sprite[1].x = 120 if @sprite[1] != nil
    @sprite[1].y = 55 if @sprite[1] != nil
    @sprite[2].x = 31 if @sprite[2] != nil
    @sprite[2].y = 135 if @sprite[2] != nil
    @sprite[3].x = 120 if @sprite[3] != nil
    @sprite[3].y = 135 if @sprite[3] != nil
    @sprite[4].x = 31 if @sprite[4] != nil
    @sprite[4].y = 235 if @sprite[4] != nil
    @sprite[5].x = 120 if @sprite[5] != nil
    @sprite[5].y = 235 if @sprite[5] != nil
    @sprite[0].z = 1000005 if @sprite[0] != nil
    @sprite[1].z = 1000005 if @sprite[1] != nil
    @sprite[2].z = 1000005 if @sprite[2] != nil
    @sprite[3].z = 1000005 if @sprite[3] != nil
    @sprite[4].z = 1000005 if @sprite[4] != nil
    @sprite[5].z = 1000005 if @sprite[5] != nil
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Receives the data for the other user's chosen pokemon.
  #-------------------------------------------------------------------------------
  ################################################################################
  def receiveoffer(data)
    @theirchosen = GTSHandler.objecttobattler(JSON.decode(data.unpack("m")[0])) #decode base 64 and load serialised data
    @received = true
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Displays the information about the other user's chosen pokemon.
  #-------------------------------------------------------------------------------
  ################################################################################
  def their_info
    @received = false
    @waiting.visible = false
    itemname = @theirchosen.item == 0 ? _INTL("NONE") : PBItems.getName(@theirchosen.item)
    @sprites["theirpokemon"].dispose if @sprites["theirpokemon"] != nil
    @sprites["theirpokemon"] = SpriteWrapper.new(@viewport)
    @sprites["theirpokemon"].bitmap = pbLoadTradeBitmap(@theirchosen.species, @theirchosen.eggsteps, @theirchosen.personalID, @theirchosen.trainerID)
    pbPositionPokemonSprite(@sprites["theirpokemon"], 368, 24)
    @sprites["theirpokemon"].z = 1000009
    @sprites["theirpokemon"].visible = true
    @overlay3.bitmap.clear
    imagepos2 = []
    @typebitmap2 = BitmapCache.load_bitmap(_INTL("Graphics/Pictures/types.png"))
    move0x = @theirchosen.moves[0] == 0 ? "--" : PBMoves.getName(@theirchosen.moves[0].id)
    move1x = @theirchosen.moves[1] == 0 ? "--" : PBMoves.getName(@theirchosen.moves[1].id)
    move2x = @theirchosen.moves[2] == 0 ? "--" : PBMoves.getName(@theirchosen.moves[2].id)
    move3x = @theirchosen.moves[3] == 0 ? "--" : PBMoves.getName(@theirchosen.moves[3].id)
    textpositions2 = [
      [_INTL("{1}", @theirchosen.name), 440, 12, 2, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Lv: {1}", @theirchosen.level), 257, 0, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("HP: {1}/{2}", @theirchosen.hp, @theirchosen.totalhp), 257, 11, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Attack: {1}", @theirchosen.attack), 257, 22, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Defense: {1}", @theirchosen.defense), 257, 33, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Speed: {1}", @theirchosen.speed), 257, 44, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Sp. Att: {1}", @theirchosen.spatk), 257, 55, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Sp. Def: {1}", @theirchosen.spdef), 257, 66, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Nature: {1}", PBNatures.getName(@theirchosen.nature)), 257, 77, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Ability: {1}", PBAbilities.getName(@theirchosen.ability)), 257, 88, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Move 1: {1}", move0x), 257, 99, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Move 2: {1}", move1x), 257, 110, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Move 3: {1}", move2x), 257, 121, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Move 4: {1}", move3x), 257, 132, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Item: {1}", itemname), 383, 27, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
    ]
    if @theirchosen.gender == 0
      textpositions2.push([_INTL("♂f0 "), 390, 12, false, Color.new(120, 184, 248), Color.new(0, 120, 248)])
    elsif @theirchosen.gender == 1
      textpositions2.push([_INTL("♀f0 "), 390, 12, false, Color.new(248, 128, 128), Color.new(168, 24, 24)])
    end
    pbSetExtraSmallFont(@overlay3.bitmap)
    pbDrawTextPositions(@overlay3.bitmap, textpositions2)
    type1rect2 = Rect.new(0, (@theirchosen.type1) * 28, 64, 28)
    type2rect2 = Rect.new(0, (@theirchosen.type2) * 28, 64, 28)
    @overlay3.bitmap.blt(320, 4, @typebitmap2, type1rect2)
    @overlay3.bitmap.blt(320, 4 + 28, @typebitmap2, type2rect2) if @theirchosen.type1 != @theirchosen.type2
    ballimage = sprintf("Graphics/Pictures/ball%02d_0.png", @theirchosen.ballused)
    imagepos2.push([ballimage, 452, 124, 0, 0, -1, -1])
    pbDrawImagePositions(@overlay2.bitmap, imagepos2)
    if Kernel.pbConfirmMessage(_INTL("Trade your #{$Trainer.party[@index - 1].name} for their #{@theirchosen.name}?"))
      @waiting.visible = true
      $network.send("<TRA|accepted>")
      @accepted = true
    else
      trade_declined
      $network.send("<TRA|declined>")
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Procedure that is called when the other player declines the trade.
  #-------------------------------------------------------------------------------
  ################################################################################
  def trade_declined
    @waiting.visible = false
    @info.visible = false
    @sprites["mypokemon"].dispose
    @sprites["theirpokemon"].dispose
    @overlay2.bitmap.clear
    @overlay3.bitmap.clear
    @pokemonselected = false
    @theirchosen = nil
    @accepted = false
    @received = false
    @listreceived = false
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  #Excutes the trade, this is where the pokemon chosen is modified to the new one.
  #-------------------------------------------------------------------------------
  ################################################################################
  def execute_trade
    @waiting.visible = false
    old = $Trainer.party[@index - 1]
    $Trainer.party[@index - 1] = @theirchosen
    pbSave
    #backtotrade
    evo = PokemonTradeScene.new
    evo.pbStartScreen(old, @theirchosen, $network.username, @username)
    evo.pbTrade(true)
    evo.pbEndScreen
    $Trainer.seen[@theirchosen.species] = true
    $Trainer.owned[@theirchosen.species] = true

    $network.send("<TRA|dead>")
    pbSave
    Kernel.pbMessage("Saved the game!")
    $scene = Connect.new
  end
end

################################################################################
#-------------------------------------------------------------------------------
#Other Essentials based classes and methods needed for the scene to function
#-------------------------------------------------------------------------------
################################################################################
class PokemonTradeIcon < SpriteWrapper
  attr_accessor :selected
  attr_accessor :active
  attr_reader :pokemon

  def initialize(pokemon, eggsteps, personalID, active, viewport = nil)
    super(viewport)
    @eggsteps = eggsteps
    @personalID = personalID
    @animbitmap = nil
    @frames = [
      Rect.new(0, 0, 64, 64),
      Rect.new(64, 0, 64, 64),
    ]
    @active = active
    @selected = false
    @animframe = 0
    self.pokemon = pokemon
    @frame = 0
    @pokemon = pokemon
    @spriteX = self.x
    @spriteY = self.y
    @updating = false
  end

  def width
    return 300
  end

  def height
    return 300
  end

  def pokemon=(value)
    @animbitmap.dispose if @animbitmap
    @animbitmap = pbLoadTradeIcon(value, @eggsteps, @personalID)
    self.bitmap = @animbitmap
    self.src_rect = @frames[@animframe]
  end

  def dispose
    @animbitmap.dispose
    super
  end

  def update
    @updating = true
    super
    frameskip = 5
    if frameskip == -1
      @animframe = 0
      self.src_rect = @frames[@animframe]
    else
      @frame += 1
      @frame = 0 if @frame > 100
      if @frame >= frameskip
        @animframe = (@animframe == 1) ? 0 : 1
        self.src_rect = @frames[@animframe]
        @frame = 0
      end
    end
    if self.selected
      if !self.active
        self.x = @spriteX + 8
        self.y = (@animframe == 0) ? @spriteY - 6 : @spriteY + 2
      else
        self.x = @spriteX
        self.y = (@animframe == 0) ? @spriteY + 2 : @spriteY + 10
      end
    end
  end

  def x=(value)
    super
    @spriteX = value if !@updating
  end

  def y=(value)
    super
    @spriteY = value if !@updating
  end
end

def pbLoadTradeIcon(pokemon, eggsteps, personalID)
  return BitmapCache.load_bitmap(pbPokemonTradeFile(pokemon, eggsteps, personalID))
end

def pbPokemonTradeFile(pokemon, eggsteps, personalID)
  # return sprintf("Graphics/Pictures/ball00.png")

  @pokemon = pokemon.to_i
  @eggsteps = eggsteps.to_i
  @personalID = personalID.to_i
  # if @eggsteps > 1
  # Special case for eggs
  #  return sprintf("Graphics/Pictures/iconEgg.png")
  # end
  if isConst?(@pokemon, PBSpecies, :UNOWN)
    # Special case for Unown
    d = @personalID & 3
    d |= ((@personalID >> 8) & 3) << 2
    d |= ((@personalID >> 16) & 3) << 4
    d |= ((@personalID >> 24) & 3) << 6
    d %= 28  # index of letter : ABCDEFGHIJKLMNOPQRSTUVWXYZ!?
    filename = sprintf("Graphics/Icons/icon%03d_%02d.png", @pokemon, d)
    begin
      load_data(filename)
      return filename
    rescue Errno::ENOENT, Errno::EACCES, RGSSError
      # File not found, just fall back
    end
  end
  return sprintf("Graphics/Icons/icon%03d.png", pokemon)
end

def pbLoadTradeBitmap(species, eggsteps, personalID, trainerID)
  return pbLoadTradeBitmapSpecies(species, eggsteps, personalID, trainerID)
end

def pbLoadTradeBitmapSpecies(species, eggsteps, personalID, trainerID)
  return BitmapCache.load_bitmap(
           sprintf("Graphics/Pictures/ball00.png")
         )
=begin
  if eggsteps.to_i > 0
   return BitmapCache.load_bitmap(
     sprintf("Graphics/Pictures/egg.png"))
  end
  bitmapFileName=sprintf("Graphics/Battlers/%03d%s.png",species,pbcheckShiny(personalID,trainerID) ? "s" : "")
  if isConst?(species,PBSpecies,:SPINDA)
   bitmap=Bitmap.new(bitmapFileName)
   pbTradeSpindaSpots(pokemon,bitmap)
   return bitmap
  elsif isConst?(species,PBSpecies,:UNOWN)
   d=personalID&3
   d|=((personalID>>8)&3)<<2
   d|=((personalID>>16)&3)<<4
   d|=((personalID>>24)&3)<<6
   d%=28 # index of letter : ABCDEFGHIJKLMNOPQRSTUVWXYZ!?
   begin
    # Load special bitmap if found
    # Example: 201b_02 for the letter C
    return BitmapCache.load_bitmap(
      sprintf("Graphics/Battlers/%03d%s_%02d.png",species,
       pbcheckShiny(personalID,trainerID) ? "s" : "",d)
    )
   rescue
    # Load plain bitmap as usual (see below)
   end
 end
  return BitmapCache.load_bitmap(bitmapFileName)
=end
end

def pbSetExtraSmallFont(bitmap)
  bitmap.font.name = ["Pokemon Emerald Small", "Arial Narrow", "Arial"]
  bitmap.font.size = 16
end

def pbcheckShiny(personalID, trainerID)
  a = personalID.to_i ^ trainerID.to_i
  b = a & 0xFFFF
  c = (a >> 16) & 0xFFFF
  d = b ^ c
  return (d < 8)
end