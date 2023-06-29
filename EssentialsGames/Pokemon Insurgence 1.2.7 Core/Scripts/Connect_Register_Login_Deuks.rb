################################################################################
#-------------------------------------------------------------------------------
#Author: Alexandre
#Handles Connection, Registration and Login
#Modified by Deukhoofd for Insurgence
#-------------------------------------------------------------------------------
################################################################################
class Connect
  #Initialization
  def initialize(sbase = false)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @overlay = SpriteWrapper.new(@viewport)
    @overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    bgbit = BitmapCache.load_bitmap("Graphics/Pictures/onlineBG.png")
    @overlay.bitmap.blt(0, 0, bgbit, Rect.new(0, 0, bgbit.width, bgbit.height))
    #   image.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) if trainer.clothes[3] != 0
    #testblt
    @viewport.z = 99999
    @username = ""
    @password = ""
    @email = ""
    @base = sbase
    @idle = true
    GTSHandler.Connect = self
  end

  def main
    Graphics.transition
    $game_switches[697]=true
    Kernel.pbMessage("Connecting to server... (Press C)")
    version = getversion()
    begin
      $network = DeukNetwork.new
      $network.open
      $network.send("<CON|version=#{version}>")
    rescue Exception => e
      Kernel.pbMessage(e.message)
      Kernel.pbMessage("Server is not online or your internet connection has a problem.")
      $scene = Scene_Map.new
      Graphics.freeze
      $network.close
      @viewport.dispose
    end
    loop do
      break if $scene != self
      update
      if Input.trigger?(Input::B)
        $network.send("<DSC>")
        $scene = Scene_Map.new
        $PokemonTemp.dependentEvents.refresh_sprite
        $game_switches[697]=false
        break
      end
    end
    Graphics.freeze
    @viewport.dispose
  end

  def update
    message = $network.listen
    handle(message)
    @viewport.update
    @overlay.update
    Graphics.update
    Input.update
  end

  def handle(message)
    Input.trigger?(Input::B)
    if message.kind_of?(Array)
      message = message[0]
    end
    #Kernel.pbMessage(message)
    case message
    when /<CON result=(.*)>/ then check_connection($1.to_i)
    when /<DSC>/ then disconnect()
    when /<DSC reason=(.*)>/ then disconnect($1.to_s)
    when /<REG result=(.*)>/ then check_registration($1.to_i)
    when /<LOG result=(.*)>/ then check_login($1.to_i)
    when /<VBASE user=(.*) result=(.*) base=(.*) message=(.*)>/ then check_basevisit($1.to_s, $2.to_i, $3.to_s, $4.to_s)
    when /<UBASE result=(.*)>/ then check_baseupload($1.to_i)
    when /<TRA user=(.*) result=(.*)>/ then check_trade($1.to_s, $2.to_i)
    when /<BAT user=(.*) result=(.*) trainer=(.*)>/ then check_battle($1.to_s, $2.to_i, $3)
    when /<DIRGIFT result=(.*) gift=(.*)>/ then setdirgift($1.to_i, $2.to_s)
    when "" then nil

      #These handle Random Battle messages
    when /<RANTIER tier=(.*)>/ then rndbattle_tier($1.to_s)
    when /<RANDBAT user=(.*)>/ then rndbattle_check($1.to_s)
    when /<RAND INC>/ then randbattlenotallowed
    when /<GLOBAL message=(.*)>/ then Kernel.pbMessage("#{$1.to_s}")

      #this handles GTS messages
    when /<GTSCREATE result=(.*) index=(.*)>/ then GTSHandler.checkgtscreate($1.to_i, $2.to_i)
    when /<GTSREQUEST trades=(.*)>/ then GTSHandler.displaytrades($1.to_s, false)
    when /<GTSMINE trades=(.*)>/ then GTSHandler.displaytrades($1.to_s, true)
    when /<GTSOFFER result=(.*) pkmn=(.*)>/ then GTSHandler.gts_offer_response($1.to_i, $2.to_s)
    when /<GTSCANCEL result=(.*) pkmn=(.*)>/ then GTSHandler.gts_cancel_response($1.to_i, $2.to_s)
    when /<GTSCOLLECT result=(.*) pkmn=(.*)>/ then GTSHandler.gts_collect_response($1.to_i, $2.to_s)
    when /<WTRESULT result=(.*) user=(.*) pkmn=(.*)>/ then wtresult($1.to_i, $2.to_s, $3.to_s)
    when /<FSGIFTS gifts=(.*)>/ then readgifts($1.to_s)
    when /<PNG>/ then nil
    end
  end

  def setdirgift(result, gift)
    #Kernel.pbMessage(pbGet(167).to_s + " "+pbGet(166).to_s)
    $game_variables[167] = -1
    $game_variables[167] = result
    $game_variables[166] = gift
  end

  def check_connection(result)
    if result == 0
      Kernel.pbMessage("Your version is outdated, please download the latest version of the game")
      $scene = Scene_Map.new
    elsif result == 1
      Kernel.pbMessage("The server is full, please try again later.")
      $scene = Scene_Map.new
    else
      Kernel.pbMessage("Connection Successful.")
      registerorlogin
    end
  end

  def registerorlogin
    commands = [_INTL("Login"), _INTL("Register"), _INTL("Cancel")]
    choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands)
    if choice == 0
      attempt_login
    elsif choice == 1
      attempt_register
    elsif choice == 2
      $network.send("<DSC>")
      $scene = Scene_Map.new
      $PokemonTemp.dependentEvents.refresh_sprite
      $game_switches[697]=false
    end
  end

  def disconnect(reason = nil)
    if reason == nil
      Kernel.pbMessage("You have been disconnected.")
    else
      Kernel.pbMessage("You have been disconnected: #{reason}")
    end
    $scene = Scene_Map.new
  end

  def attempt_register
    Kernel.pbMessage("Please enter a username.")
    loop do
      @username = Kernel.pbMessageFreeText(_INTL("Username?"), "", false, 32)
      break if @username == ""
      if @username != ""
        Kernel.pbMessage("Please re-enter your username.")

        username = Kernel.pbMessageFreeText(_INTL("Username?"), "", false, 32)
        break if @username == username
        Kernel.pbMessage("The username you entered does not match, please try again.")
      end
    end
    if @username == ""
      registerorlogin
    else
      Kernel.pbMessage("Please enter a password.")
      loop do
        @password = Kernel.pbMessageFreeText(_INTL("Password?"), "", true, 32)
        if @password != ""
          Kernel.pbMessage("Please re-enter your password.")
          password = Kernel.pbMessageFreeText(_INTL("Password?"), "", true, 32)
          break if @password == password
          Kernel.pbMessage("The password you entered does not match, please try again.")
        end
        break if @password == ""
      end
      if @password == ""
        registerorlogin
      else
        @email = ($Trainer.party[0].trainerID * 100000 + rand(100000)).to_s
        $network.send("<REG|user=#{@username}|pass=#{encrypt_password(@password)}|email=#{@email}>")
      end
    end
  end

  def encrypt_password(password)
    encrypted = password.crypt("XS")
    return encrypted[2, encrypted.size - 2]
  end

  def check_registration(result)
    if result == 0
      Kernel.pbMessage("The username is already taken, please try a different username.")
      attempt_register
    elsif result == 1
      Kernel.pbMessage("The email you entered has already been used to register an account, you can only have one acount per email.")
      attempt_register
    elsif result == 2
      Kernel.pbMessage("Registration was successful!")
      registerorlogin
    end
  end

  def attempt_login
    Kernel.pbMessage("Please enter your username.")
    tempuser = ""
    tempuser = $game_variables[109] if $game_variables[109] != 0
    @username = Kernel.pbMessageFreeText(_INTL("Username?"), tempuser, false, 32)
    if @username == ""
      registerorlogin
    else
      temppass = ""
      temppass = $game_variables[110] if $game_variables[110] != 0

      Kernel.pbMessage("Please enter your password.")
      @password = Kernel.pbMessageFreeText(_INTL("Password?"), temppass, true, 32)
      if @password == ""
        registerorlogin
      else
        Kernel.pbMessage("Logging in... (Press C)")
        $network.send("<LOG|user=#{@username}|pass=#{encrypt_password(@password)}>")
      end
    end
  end

  def check_login(result)
    for pkmn in $Trainer.party do
      if pkmn.fused!=nil
        Kernel.pbMessage("You cannot trade with a fused Pokemon in your party.")
        result=5
        #registerorlogin
        break
      else
        for move in pkmn.moves do
          if move.id==PBMoves::CUSTOMMOVE
            Kernel.pbMessage("You cannot trade with a Custom Move on your party Pokemon.")
            result=5
            break
          end
        end
      end
    end
    if result == 0
      Kernel.pbMessage("The username entered does not exist.")
      registerorlogin
    elsif result == 1
      Kernel.pbMessage("The password entered is incorrect.")
      registerorlogin
    elsif result == 2
      Kernel.pbMessage("This account has been banned.")
      registerorlogin
    elsif result == 3
      Kernel.pbMessage("Your IP has been banned.")
      $Scene = Scene_Map.new
    elsif result == 4
      Kernel.pbMessage("Login was successful!")
      $network.loggedin = true
      $network.username = @username
      $game_variables[109] = @username
      $game_variables[110] = @password
      tradeorbattle
    elsif result==5
      registerorlogin
    end
  end

  def tradeorbattle
    if $game_switches[585]
      wtsend($game_variables[155])

      $game_variables[167] = -5
      #$network.send("<DIRGIFT>")
    elsif @base
      commands = [_INTL("Visit Friend's Base"), _INTL("Visit Random Base"), _INTL("Upload Base"),
                  _INTL("Set Welcome Message"), _INTL("Check for secret base gifts."), _INTL("Cancel")]
      choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands)
      if choice == 0
        visitbase
      elsif choice == 1
        visitrandombase
      elsif choice == 2
        uploadbase
      elsif choice == 3
        setmessage
      elsif choice == 4
        checkgifts
      elsif choice == 5
        $network.send("<DSC>")
        $scene = Scene_Map.new
        $PokemonTemp.dependentEvents.refresh_sprite
        $game_switches[697]=false
      end
    else
      #     if $game_variables[166]
      $network.send("<DIRGIFT>")
      loop do
        update
        break if $game_variables[167] != -5
        if Input.trigger?(Input::B)
          $network.send("<DSC>")
          $scene = Scene_Map.new
          $PokemonTemp.dependentEvents.refresh_sprite
          $game_switches[697]=false
          break
        end
      end
      if $game_switches[406]
        $Trainer.party = $game_variables[124]
        $game_switches[406] = false
      end
      if $game_variables[167] == 1 && $game_variables[166]!=nil &&
         $game_variables[166]!="nil" && $game_variables[166]!=""
        Kernel.pbMessage("You have (a) Direct Gift(s)!")
        $game_variables[166] = pbGet(166).unpack("m")[0]
        decoded = JSON.decode(pbGet(166))
        for obje in decoded
          if obje["Type"] == 1
            pkmn = GTSHandler.objecttobattler(obje["Pokemon"], true)
            for move in pkmn.moves
              move.pp = move.totalpp
            end
            pkmn.hp = pkmn.totalhp
            pkmn.ot == $Trainer.name
            pbAddPokemon(pkmn)
          elsif obje["Type"] == 2
            Kernel.pbReceiveItem(obje["Item"], obje["Amount"])
          end
        end
        $game_variables[166] = "fucking"
      end
      commands = [_INTL("Trade"), #_INTL("Battle"), _INTL("Random Battle"), _INTL("GTS"),
                  _INTL("Wonder Trade")]
      #  commands.push(_INTL("Check for Direct Gifts"))
      commands.push(_INTL("Cancel"))
      choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands)
      if choice == 0
        trade
      #elsif choice == 1
      #  battle
      #elsif choice == 2
      #  randombattle
      #elsif choice == 3
      #elsif choice == 1
      #  Kernel.pbMessage("Warning! The GTS is still a little buggy. Use with caution!")
      #  GTSHandler.handlegts
      #elsif choice == 4
      elsif choice == 1
        wtsend
      else
        $network.send("<DSC>")
        $scene = Scene_Map.new
        $PokemonTemp.dependentEvents.refresh_sprite
        $game_switches[697]=false
      end
    end
  end

  def readgifts(giftStr)
    if giftStr==nil || giftStr==0 || giftStr=="nil"
      Kernel.pbMessage("No new gifts.")
      tradeorbattle
    else
      ary = giftStr.split(",")
      for var in ary
        ary2 = var.split(":")
        Kernel.pbReceiveItem(ary2[0].to_i, ary2[1].to_i)
      end
    end
    pbSave
    tradeorbattle
  end

  def checkgifts
    #loop do
    $network.send("<GETGIFTS>")
    #end
  end

  def setmessage
    loop do
      message = Kernel.pbMessageFreeText(_INTL("What would you like the opening message to be?"), "", false, 32)
      packedMessage = [message].pack("m")
      $network.send("<BASEMSG|message=#{packedMessage}>")
      break
    end
    tradeorbattle
  end

  def visitbase
    loop do
      @player = Kernel.pbMessageFreeText(_INTL("Whose base would you like to visit?"), "", false, 32)
      Kernel.pbMessage("You cannot visit your own base.") if @player.downcase == $network.username.downcase
      return tradeorbattle if @player == "" || @player.downcase == $network.username.downcase
      break if @player != "" || @player != $network.username
    end
    $game_variables[5] = @player
    $game_variables[163] = @player
    $network.send("<VBASE|user=#{@player}>")
  end

  def visitrandombase
    $network.send("<VRAND>")
  end

  def uploadbase
    loop do
      truefalse = Kernel.pbConfirmMessage(_INTL("Would you like to save your base and upload it?"))
      if truefalse
        basevar = [compileSecretBase()].pack("m")
        $network.send("<UBASE|user=#{@player}|base=#{basevar}>")
        break
      else
        tradeorbattle
        break
      end
    end
  end

  def compileSecretBase
    baseStr = ""
    baseStr += $game_variables[81].to_s
    baseStr += "g"
    for i in $game_variables[76]
      if i != nil && i[1] != nil
        tempStr = ""
        tempStr += i[1].to_s
        tempStr += "n"
        tempStr += i[3].to_s
        tempStr += "n"
        tempStr += i[4].to_s
        tempStr += "n"
        tempStr += "f"
        baseStr += tempStr
      end
    end
    baseStr += "g"
    for i in $game_variables[77]
      baseStr += i.to_s
      baseStr += "f"
    end
    baseStr += "g"
    return baseStr
  end

  def decompileSecretBase(string)
    baseString = []
    string.each_line("g") { |s|
      baseString.push(s)
    }
    $game_variables[85] = baseString[0].chomp("g").to_i

    $game_variables[84] = Array.new
    eventsString = []
    baseString[1].each_line("f") { |s|
      eventsString.push(s)
      eventsString[eventsString.length - 1] = Array.new
    }
    for i in eventsString
      i = Array.new
    end
    eventNo = 0
    baseString[1].each_line("f") { |s|
      s = s.chomp("f")
      eventPart = 1
      s.each_line("n") { |s2|
        s2 = s2.chomp("n").to_i
        eventsString[eventNo][quickRenderInt(eventPart)] = s2
        eventPart += 1
      }
      eventNo += 1
    }
    $game_variables[84] = eventsString
    $game_variables[86] = Array.new
    baseString[2].each_line("f") { |s|
      s = s.chomp("f")
      $game_variables[86].push(s.to_i)
    }
  end

  def quickRenderInt(int)
    return 0 if int == 0
    int += 1
    return int
  end

  def trade
    loop do
      @player = Kernel.pbMessageFreeText(_INTL("Who would you like to trade with?"), "", false, 32)
      Kernel.pbMessage("You cannot trade with yourself.") if @player == $network.username
      return tradeorbattle if @player == "" || @player == $network.username
      break if @player != "" || @player != $network.username
    end
    $network.send("<TRA|user=#{@player}>")
  end

  def check_basevisit(player, result, basestring, message)
    if result == 0
      Kernel.pbMessage(_INTL("The user #{player} does not exist."))
      tradeorbattle
    elsif result == 1
      Kernel.pbMessage(_INTL("The user #{player} has been banned."))
      tradeorbattle
    elsif result == 2
      # begin
      # $game_variables[162]=Base64.decode(message)
      #rescue
      $game_variables[162] = message.unpack("m")

      # end
      $game_variables[5] = player
      $game_variables[163] = player

      if basestring != nil && basestring != ""
        $scene = Scene_Map.new
        player = $game_variables[5]
        Kernel.pbMessage(_INTL("The door to #{player}'s base has opened!"))
        $game_switches[697]=false
        $game_variables[87] = player

        decompileSecretBase(basestring)
        pbCommonEvent(7)
      else
        Kernel.pbMessage("The user #{player} doesn't exist or hasn't created a base.")
        tradeorbattle
      end
    end
  end

  def check_baseupload(result)
    if result == 0
      Kernel.pbMessage(_INTL("The base did not upload successfully."))
      tradeorbattle
    elsif result == 1
      Kernel.pbMessage(_INTL("The base was uploaded successfully!"))
      trainertemp = PokeBattle_TrainerPrimitive.new($Trainer.name, $Trainer.trainertype)
      for i in 0..5
        trainertemp.clothes[i] = $Trainer.clothes[i]
      end
      trainertemp.party = $Trainer.party
      trainertemp.custom = $Trainer.custom
      val = [JSON.encode(trainertemp)].pack("m")
      #       File.open("ah2", "wb"){|f|
      #           f.write(val)
      #        }
      $network.send("<BASEBAT|trainer=#{val}>")
      #  trainertemp2=JSON.decode(val.unpack("m")[0])

      tradeorbattle
    end
  end

  def check_trade(player, result)
    if result == 0
      Kernel.pbMessage(_INTL("The user #{player} does not exist."))
      tradeorbattle
    elsif result == 1
      Kernel.pbMessage(_INTL("The user #{player} has been banned."))
      tradeorbattle
    elsif result == 2
      Kernel.pbMessage(_INTL("The user #{player} is not online."))
      tradeorbattle
    elsif result == 3
      Kernel.pbMessage(_INTL("The user #{player} has declined or did not respond your trade request."))
      tradeorbattle
    elsif result == 4
      Kernel.pbMessage(_INTL("The user #{player} has accepted your trade request."))
      $scene = Scene_Trade.new(player)
    end
  end

  def battle
    if !$Trainer.party[0] || $Trainer.party[0].egg? || $Trainer.party[0].hp < 1
      Kernel.pbMessage("You need to be able to use the first Pokemon in your party.")
      return tradeorbattle
      break
    end

    for i in 0..$Trainer.party.length - 1
      $Trainer.party[i].heal
    end
    $game_variables[124] = Array.new
    for i in 0..$Trainer.party.length - 1
      $game_variables[124][i] = $Trainer.party[i].clone
    end
    $game_switches[371] = true
    $game_switches[406] = true
    for i in $Trainer.party
      i.level = 50
      i.calcStats
    end

    partyTemp = []
    for poke in $Trainer.party
      partyTemp.push(Marshal.dump(poke))
    end
    mons = Kernel.makeTeamString
    trainerAry = [$Trainer.name,
                  $Trainer.id,
                  $Trainer.trainertype,
                  $Trainer.megaforme,
                  $Trainer.clothes.join("s"),
                  mons]
    serialized = trainerAry.join("/g/")
    loop do
      @player = Kernel.pbMessageFreeText(_INTL("Who would you like to battle with?"), "", false, 32)
      Kernel.pbMessage("You cannot battle with yourself.") if @player == $network.username
      return tradeorbattle if @player == "" || @player == $network.username
      break
    end
    $network.send("<BAT|user=#{@player}|trainer=#{serialized}>")
  end

  def MakeTeamString
    pokemonArray = []
    for poke in $Trainer.party
      poke.abilityflag = "nil" if !poke.abilityflag
      if !poke.isShiny?
        shininess = 0
      else
        shininess = 1
      end
      varArray = [poke.species,
                  50,
                  poke.iv[0],
                  poke.iv[1],
                  poke.iv[2],
                  poke.iv[3],
                  poke.iv[4],
                  poke.iv[5],
                  poke.ev[0],
                  poke.ev[1],
                  poke.ev[2],
                  poke.ev[3],
                  poke.ev[4],
                  poke.ev[5],
                  poke.personalID,
                  poke.trainerID,
                  poke.item,
                  poke.name,
                  poke.exp,
                  poke.happiness,
                  poke.moves[0].id,
                  poke.moves[0].pp,
                  poke.moves[1].id,
                  poke.moves[1].pp,
                  poke.moves[2].id,
                  poke.moves[2].pp,
                  poke.moves[3].id,
                  poke.moves[3].pp,
                  poke.form,
                  poke.nature,
                  poke.totalhp,
                  poke.attack,
                  poke.defense,
                  poke.spatk,
                  poke.spdef,
                  poke.speed,
                  poke.ballused,
                  poke.ot,
                  shininess,
                  poke.abilityflag]
      for var in pokemonArray
        var = var.to_s
      end
      pokemonArray.push(varArray.join("^%*"))
    end
    mons = pokemonArray.join("/u/")
    return mons
  end

  def check_battle(player, result, opponent)
    if result == 0
      Kernel.pbMessage(_INTL("The user #{player} does not exist."))
      tradeorbattle
    elsif result == 1
      Kernel.pbMessage(_INTL("The user #{player} has been banned."))
      tradeorbattle
    elsif result == 2
      Kernel.pbMessage(_INTL("The user #{player} is not online."))
      tradeorbattle
    elsif result == 3
      Kernel.pbMessage(_INTL("The user #{player} has declined or did not respond your battle request."))
      tradeorbattle
    elsif result == 4
      Kernel.pbMessage(_INTL("The user #{player} has accepted your battle request."))
      Kernel.pbMessage(_INTL("Do not click outside the window during the battle!"))

      unpacked = opponent.split("/g/")
      unpacked[4] = unpacked[4].split("s")
      unpacked[5] = unpacked[5].split("/u/")

      pokeAry = []
      for prePoke in unpacked[5]
        longarray = prePoke.split("^%*")
        mon = PokeBattle_Pokemon.new(longarray[0].to_i, 50)
        thing = 0
        for v in 2..7
          mon.iv[thing] = longarray[v].to_i
          thing += 1
        end
        thing = 0
        for v in 8..13
          mon.ev[thing] = longarray[v].to_i
          thing += 1
        end

        mon.personalID = longarray[14].to_i
        mon.trainerID = longarray[15].to_i
        mon.item = longarray[16].to_i
        mon.name = longarray[17]
        mon.exp = longarray[18].to_i
        mon.happiness[19].to_i
        for i in 0..3
          mon.moves[i] = PBMove.new(longarray[20 + (i * 2)].to_i)
          mon.moves[i].pp = longarray[21 + (i * 2)].to_i
        end
        mon.form = longarray[28].to_i
        mon.setNature(longarray[29].to_i)

        mon.totalhp = longarray[30].to_i
        mon.attack = longarray[31].to_i
        mon.defense = longarray[32].to_i
        mon.spatk = longarray[33].to_i
        mon.spdef = longarray[34].to_i
        mon.speed = longarray[35].to_i

        mon.ballused = longarray[36].to_i
        mon.ot = longarray[37]

        if longarray[38].to_i == 0 && mon.isShiny?
          mon.makeNotShiny
        elsif !mon.isShiny?
          mon.makeShiny
        end

        if longarray[38] != "nil"
          mon.abilityflag = longarray[38].to_i
        end

        pokeAry.push(mon)
      end

      deserialized = PokeBattle_Trainer.new(unpacked[0], unpacked[2])
      deserialized.id = unpacked[1]
      deserialized.megaforme = unpacked[3]
      deserialized.clothes = unpacked[4]
      deserialized.party = pokeAry
      return start_battle(deserialized)
    end
  end

  def start_battle(opponent)
    scene = pbNewBattleScene
    battle = PokeBattle_OnlineBattle.new(scene, $Trainer.party, opponent.party, $Trainer, opponent)
    fullparty1 = true ? $Trainer.party.length == 6 : false
    fullparty2 = true ? opponent.party.length == 6 : false
    battle.fullparty1 = fullparty1
    battle.fullparty2 = fullparty2
    battle.endspeech = ""
    battle.internalbattle = false
    $game_switches[393] = true
    pbPrepareBattle(battle)
    restorebgm = true
    decision = 0

    decision = battle.pbStartBattle(true)

    $Trainer.party = $game_variables[124]
    $game_switches[406] = false
    $game_switches[371] = false
    for i in 0..$Trainer.party.length - 1
      $Trainer.party[i].heal
    end
    $game_switches[393] = false
    if decision == 1
      Kernel.pbMessage("You won the battle.")
    else
      Kernel.pbMessage("You lost the battle.")
    end
    tradeorbattle
  end

  def randombattle
    fullarray = []
    speciesArray = []
    itemsArray = []
    for poke in $Trainer.party
      pokeform = poke.form
      if poke.species == 384
        for i in 0..3
          if poke.moves[i] && poke.moves[i].id == PBMoves::DRAGONSASCENT
            pokeform = 1
          end
        end
      end
      species = "#{poke.species}_#{pokeform}"
      speciesArray.push(species)
    end
    speciesstring = speciesArray.join("^")
    fullarray.push(speciesstring)
    for poke in $Trainer.party
      helditem = poke.item
      itemsArray.push(helditem)
    end
    itemsstring = itemsArray.join("^")
    fullarray.push(itemsstring)
    fullstring = fullarray.join("/")
    $network.send("<RAND|battle|species=#{fullstring}>")
  end

  def rndbattle_tier(tier)
    commands = [_INTL("No Tier"), _INTL("Uber"), _INTL("OU"), _INTL("BL"), _INTL("UU"), _INTL("RU"), _INTL("NU"), _INTL("Cancel")]
    choice = Kernel.pbMessage(_INTL("The lowest tier you can battle in is #{tier}, what tier do you want to use?"), commands)
    if choice == 0
      $network.send("<RANBAT|tier=notier>")
    elsif choice == 1
      $network.send("<RANBAT|tier=Uber>")
    elsif choice == 2
      $network.send("<RANBAT|tier=OU>")
    elsif choice == 3
      $network.send("<RANBAT|tier=BL>")
    elsif choice == 4
      $network.send("<RANBAT|tier=UU>")
    elsif choice == 5
      $network.send("<RANBAT|tier=RU>")
    elsif choice == 6
      $network.send("<RANBAT|tier=NU>")
    else
      $network.send("<RANBAT|cancel>")
      return tradeorbattle
    end
  end

  def randbattlenotallowed
    Kernel.pbMessage("That tier is beneath you.")
    return tradeorbattle
  end

  def rndbattle_check(player)
    commands = [_INTL("Accept"), _INTL("Decline")]
    choice = Kernel.pbMessage(_INTL("User #{player} sent you a random battle request, What do you want to do?"), commands)
    if choice == 0
      if !$Trainer.party[0] || $Trainer.party[0].egg? || $Trainer.party[0].hp < 1
        Kernel.pbMessage("You need to be able to use the first Pokemon in your party.")
        return tradeorbattle
        break
      end

      for i in 0..$Trainer.party.length - 1
        $Trainer.party[i].heal
      end
      $game_variables[124] = Array.new
      for i in 0..$Trainer.party.length - 1
        $game_variables[124][i] = $Trainer.party[i].clone
      end
      $game_switches[371] = true
      $game_switches[406] = true
      for i in $Trainer.party
        i.level = 50
        i.calcStats
      end

      partyTemp = []
      for poke in $Trainer.party
        partyTemp.push(Marshal.dump(poke))
      end

      mons = Kernel.makeTeamString
      trainerAry = [$Trainer.name,
                    $Trainer.id,
                    $Trainer.trainertype,
                    $Trainer.megaforme,
                    $Trainer.clothes.join("s"),
                    mons]

      serialized = trainerAry.join("/g/")
      $network.send("<BAT|user=#{player}|trainer=#{serialized}>")
    elsif choice == 1
      $network.send("<RANBAT|decline|user=#{player}>")
      return tradeorbattle
    end
  end

  def ranbattle_denied(user)
    Kernel.pbMessage("#{user} has denied your random battle request")
    $network.send("<RANBAT|cancel>")
    tradeorbattle
  end

  def getversion
    _version = "5.0"
    _version = "6.84" if $DEBUG
    return _version
  end

  def wtsend(pokemon = nil)
    if $game_switches[583] || $Trainer.ablePokemonCount > 1
      if pokemon == nil
        pbChoosePokemon(1, 2, proc { |poke|
          !poke.egg? && poke.hp > 0
        })
        if $game_variables[1] >= 0
          @WTIndex = $game_variables[1]
          pokemon = $Trainer.party[@WTIndex.to_i]
          if pokemon.species == PBSpecies::MEW
            Kernel.pbMessage("ERROR. ERROR.")
            Kernel.pbMessage("Mew was lost in cyberspace.")
            pokemon.form = 1
            #iMew
            $PokemonStorage.pbStoreCaught(pokemon)
            pbRemovePokemonAt(@WTIndex.to_i)
            $network.send("<DSC>")
            $PokemonTemp.dependentEvents.refresh_sprite
            $game_switches[697]=false
          else
            pokestring = [JSON.encode(pokemon)].pack("m")
            $network.send("<WTCREATE|pkmn=#{pokestring}>")
          end
        else
          tradeorbattle
        end
      end
    else
      Kernel.pbMessage("You need to have more Pokemon in your party to use this.")
      tradeorbattle
    end
  end

  def wtresult(result, user, pkmn)
    if result == 0
      Kernel.pbMessage("You have been banned from the online server")
      return tradeorbattle
    elsif result == 1
      Kernel.pbMessage("Your wonder trade has timed out")
      return tradeorbattle
    elsif result != 2
      return tradeorbattle
    end
    if $game_switches[585]
      $game_switches[585] = false
      $game_variables[155] = GTSHandler.objecttobattler(JSON.decode(pkmn.unpack("m")[0]))
      bname = $game_variables[155].name
      Kernel.pbMessage("You received a #{bname} from #{user}!")
      $network.send("<DSC>")
      $scene = Scene_Map.new
      $PokemonTemp.dependentEvents.refresh_sprite
      $game_switches[697]=false
    else
      battler = GTSHandler.objecttobattler(JSON.decode(pkmn.unpack("m")[0]))
      Kernel.pbMessage("You received a #{battler.name} from #{user}!")
      $Trainer.party[@WTIndex] = battler
      $network.send("<DSC>")
      $scene = Scene_Map.new
      $PokemonTemp.dependentEvents.refresh_sprite
      $game_switches[697]=false
    end
    pbSave
  end
end

class GTSRequestHolder
  attr_accessor :Species
  attr_accessor :MinLevel
  attr_accessor :Gender
  attr_accessor :Nature
  @Species = 0
  @MinLevel = 1
  @Gender = 2
  @Nature = 25
end

class DeukNetwork
  attr_accessor :loggedin
  attr_accessor :socket
  attr_accessor :username

  def initialize()
    @loggedin = false
    @socket = nil
    @username = ""
  end

  def open
    @socket = TCPSocket.new("5.135.154.100", 6422)
  end

  def close
    @loggedin = false
    @socket.send("<DSC>") if @socket != nil
    @socket.close if @socket != nil
    $PokemonTemp.dependentEvents.refresh_sprite
    $game_switches[697]=false
  end

  def listen
    return "" if !@socket.ready?
    buffer = @socket.recv(0xFFFF)
    buffer = buffer.split("\n", -1)
    if @previous_chunk != nil
      buffer[0] = @previous_chunk + buffer[0]
      @previous_chunk = nil
    end
    last_chunk = buffer.pop
    @previous_chunk = last_chunk if last_chunk != ""
    buffer.each { |message|
      case message
      when /<PNG>/ then next
      else
        return message
      end
    }
  end

  def send(message)
    @socket.send(message + "\n")
  end
end