=begin
################################################################################
#-------------------------------------------------------------------------------
#Author: Alexandre
#Handles Connection, Registration and Login
#-------------------------------------------------------------------------------
################################################################################
class Connect
  
################################################################################
#-------------------------------------------------------------------------------
#Let's start the Scene
#-------------------------------------------------------------------------------
################################################################################
  def initialize(sbase=false)
 
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @overlay=SpriteWrapper.new(@viewport)
    @overlay.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @viewport.z = 99999
    @username = ""
    @password = ""
    @email = ""
    @base = sbase
    @idle = true
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Opens a connection tests if it can and is allowed toconnect to the server
#-------------------------------------------------------------------------------
################################################################################
  def main
    Graphics.transition
    Kernel.pbMessage("Connecting to server... (Press C)")
    version = getversion()
    begin
    $network = Network.new
    $network.open
    $network.send("<CON version=#{version}>")
    rescue
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
        $scene=Scene_Map.new
        break
      end
    end
    Graphics.freeze
    @viewport.dispose
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Loop to constantly check for messages from the server
#-------------------------------------------------------------------------------
################################################################################
  def update
    message = $network.listen
    handle(message)
    @viewport.update
    @overlay.update
    Graphics.update
    Input.update
  end
 
################################################################################
#-------------------------------------------------------------------------------
#Handles incoming messages from server. Aborts connection if unkown message is
#received
#-------------------------------------------------------------------------------
################################################################################
  def handle(message)
    Input.trigger?(Input::B)
    if message.kind_of?(Array)
      message = message[0]
    end
  # Kernel.pbMessage(message) if message!=nil
    #Kernel.pbMessage(""+message) rescue Kernel.pbMessage(""+message[1])
    case message
      when /<CON result=(.*)>/ then check_connection($1.to_i)
      when /<DSC>/ then disconnect()
      when /<DSC reason=(.*)>/ then disconnect($1.to_s) 
      when /<REG result=(.*)>/ then check_registration($1.to_i)
      when /<LOG result=(.*)>/ then check_login($1.to_i)
      when /<VBASE user=(.*) result=(.*) base=(.*)>/ then check_basevisit($1.to_s,$2.to_i,$3.to_s)
      when /<UBASE result=(.*)>/ then check_baseupload($1.to_i)
      when /<TRA user=(.*) result=(.*)>/ then check_trade($1.to_s,$2.to_i)
      when /<BAT user=(.*) result=(.*) trainer=(.*)>/ then check_battle($1.to_s,$2.to_i,$3)
      when "" then nil
        
      #These handle Random Battle messages
      when /<RANTIER tier=(.*)>/ then rndbattle_tier($1.to_s) 
      when /<RANDBAT user=(.*)>/ then rndbattle_check($1.to_s)
      when /<RAND INC>/ then randbattlenotallowed
            
      when /<GLOBAL message=(.*)>/ then Kernel.pbMessage("#{$1.to_s}")
 
        
      when /<PNG>/ then nil
    #  else
     #   Kernel.pbMessage("Server has sent an abnormal message: #{message}. Aborting the connection")
       # $scene = Scene_Map.new
      end
    end
 
################################################################################
#-------------------------------------------------------------------------------
#Check's response from server to see if we are allowed to connect
#-------------------------------------------------------------------------------
################################################################################    
  def check_connection(result)
    if result == 0
      Kernel.pbMessage("Your version is outdated, please download the latest version")
      $scene = Scene_Map.new
    elsif result == 1
      Kernel.pbMessage("The server is full, please try again later.")
      $scene = Scene_Map.new
    else
      Kernel.pbMessage("Connection Successful.")
      registerorlogin
    end
  end
 
################################################################################
#-------------------------------------------------------------------------------
#Simply asks the user if he or she wants to register, login or abort.
#-------------------------------------------------------------------------------
################################################################################
  def registerorlogin
    commands=[_INTL("Login"),_INTL("Register"),_INTL("Cancel")]
    choice=Kernel.pbMessage(_INTL("What do you want to do?"),commands)
    if choice==0
      attempt_login
    elsif choice==1
      attempt_register
    elsif choice==2
      $network.send("<DSC>")
      $scene=Scene_Map.new
    end
  end
 
################################################################################
#-------------------------------------------------------------------------------
#Disconnects the user if the server requires it.
#-------------------------------------------------------------------------------
################################################################################
  def disconnect(reason)
    Kernel.pbMessage("You have been disconnected: #{reason}")
    $scene=Scene_Map.new
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Attempts to register the user.
#-------------------------------------------------------------------------------
################################################################################
  def attempt_register
    Kernel.pbMessage("Please enter a username.")
    loop do
      @username = Kernel.pbMessageFreeText(_INTL("Username?"),"",false,32)
      break if @username==""
      if @username != ""
        Kernel.pbMessage("Please re-enter your username.")
        
        username = Kernel.pbMessageFreeText(_INTL("Username?"),"",false,32)
        break if @username == username
        Kernel.pbMessage("The username you entered does not match, please try again.")
      end
    end
    if @username==""
      registerorlogin 
      else
      Kernel.pbMessage("Please enter a password.")
      loop do
        @password = Kernel.pbMessageFreeText(_INTL("Password?"),"",true,32)
        if @password != ""
          Kernel.pbMessage("Please re-enter your password.")
          password = Kernel.pbMessageFreeText(_INTL("Password?"),"",true,32)
          break if @password == password
          Kernel.pbMessage("The password you entered does not match, please try again.")
        end
        break if @password == ""
 
      end
        if @password==""
          registerorlogin
          else
        @email=($Trainer.party[0].trainerID*100000+rand(100000)).to_s
        $network.send("<REG user=#{@username} pass=#{encrypt_password(@password)} email=#{@email}>")
      end
      
        end
  end
  
  
################################################################################
#-------------------------------------------------------------------------------
#Encrypts a password.
#-------------------------------------------------------------------------------
################################################################################
  def encrypt_password(password)
    encrypted = password.crypt("XS")
    return encrypted[2, encrypted.size - 2]
  end
 
################################################################################
#-------------------------------------------------------------------------------
#Checks server's result for registration.
#-------------------------------------------------------------------------------
################################################################################
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
 
################################################################################
#-------------------------------------------------------------------------------
#Attempts to log into the server.
#-------------------------------------------------------------------------------
################################################################################
  def attempt_login
    Kernel.pbMessage("Please enter your username.")
    tempuser=""
    tempuser=$game_variables[109] if $game_variables[109] != 0
    @username = Kernel.pbMessageFreeText(_INTL("Username?"),tempuser,false,32)
    if @username==""
      registerorlogin 
    else
          temppass=""
    temppass=$game_variables[110] if $game_variables[110] != 0
 
      Kernel.pbMessage("Please enter your password.")
      @password = Kernel.pbMessageFreeText(_INTL("Password?"),temppass,true,32)
      if @password==""
        registerorlogin 
        else
        Kernel.pbMessage("Logging in... (Press C)")  
        $network.send("<LOG user=#{@username} pass=#{encrypt_password(@password)}>")
      end    
    end
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Check's login result from server
#-------------------------------------------------------------------------------
################################################################################
  def check_login(result)
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
      $Scene=Scene_Map.new
    elsif result == 4
      Kernel.pbMessage("Login was successful!")
      $network.loggedin=true
      $network.username = @username
      $game_variables[109]=@username
      $game_variables[110]=@password
      tradeorbattle
    end
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Simply asks the user if they want to trade or battle.
#-------------------------------------------------------------------------------
################################################################################ 
def tradeorbattle
  if @base
    commands=[_INTL("Visit Base"),_INTL("Upload Base"),_INTL("Cancel")]
    choice=Kernel.pbMessage(_INTL("What do you want to do?"),commands)
    if choice==0
      visitbase
    elsif choice==1
      uploadbase
    elsif choice==2
      $network.send("<DSC>")
      $scene=Scene_Map.new
    end
 
  else
    if $game_switches[406]
      $Trainer.party=$game_variables[124]
      $game_switches[406]=false
    end
    
      commands=[_INTL("Trade"),_INTL("Battle"), _INTL("Random Battle"), _INTL("Cancel")]
      choice=Kernel.pbMessage(_INTL("What do you want to do?"),commands)
      if choice==0
        trade
      elsif choice==1
        battle
      elsif choice==2
        randombattle
      elsif choice==3
        $network.send("<DSC>")
        $scene=Scene_Map.new
      end
    
    
  end
  
end
  
################################################################################
#-------------------------------------------------------------------------------
#Starts trade procedures
#-------------------------------------------------------------------------------
################################################################################
  def visitbase
    
    loop do
      @player = Kernel.pbMessageFreeText(_INTL("Whose base would you like to visit?"),"",false,32)
      Kernel.pbMessage("You cannot visit your own base.") if @player.downcase == $network.username.downcase
      return tradeorbattle if @player == "" || @player.downcase == $network.username.downcase
      break if @player !="" || @player !=$network.username      
    end
    $game_variables[5]=@player
    $network.send("<VBASE user=#{@player}>")    
  end
  
  def uploadbase
    loop do
 
      truefalse = Kernel.pbConfirmMessage(_INTL("Would you like to save your base and upload it?"))
      if truefalse
        basevar = compileSecretBase
       #     Kernel.pbMessage("<UBASE user=#{@player} base=#{basevar}>")
        $network.send("<UBASE user=#{@player} base=#{basevar}>")
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
        tempStr+=i[1].to_s
        tempStr+= "n"
        tempStr+=i[3].to_s
        tempStr+= "n"
        tempStr+=i[4].to_s
        tempStr+= "n"
        tempStr+= "f"
        baseStr+= tempStr
      end
    end
      
    baseStr+= "g"
    for i in $game_variables[77]
      baseStr+= i.to_s
      baseStr+= "f"
    end
    baseStr+="g"
    return baseStr
    
  end
  
  
  def decompileSecretBase(string)
    baseString=[]
    string.each_line("g") {|s|
      baseString.push(s)
    }
    $game_variables[85]=baseString[0].chomp("g").to_i
    
    $game_variables[84] = Array.new
    eventsString=[]
    baseString[1].each_line("f") {|s|
      eventsString.push(s)
      eventsString[eventsString.length-1]=Array.new
    }
    for i in eventsString
      i = Array.new
    end
    eventNo=0
    baseString[1].each_line("f") {|s|
      s=s.chomp("f")
      eventPart=1
      s.each_line("n") {|s2|
        s2=s2.chomp("n").to_i
    #    raise "lel" if eventsString.is_a?(String)
        eventsString[eventNo][quickRenderInt(eventPart)]=s2
        eventPart += 1
      }
      eventNo += 1
    }
    $game_variables[84]=eventsString
    $game_variables[86]=Array.new
    baseString[2].each_line("f") {|s|
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
    @player = Kernel.pbMessageFreeText(_INTL("Who would you like to trade with?"),"",false,32)
    Kernel.pbMessage("You cannot trade with yourself.") if @player == $network.username
    return tradeorbattle if @player == "" || @player == $network.username
    break if @player !="" || @player !=$network.username
    end
    $network.send("<TRA user=#{@player}>")
  end
  
################################################################################
#-------------------------------------------------------------------------------
#Checks server's response for trade
#-------------------------------------------------------------------------------
################################################################################
def check_basevisit(player,result,basestring)
    if result == 0
      Kernel.pbMessage(_INTL("The user #{player} does not exist."))
      tradeorbattle
    elsif result == 1
      Kernel.pbMessage(_INTL("The user #{player} has been banned."))
      tradeorbattle
    elsif result == 2
      if basestring != nil && basestring != ""
              $scene=Scene_Map.new
      player=$game_variables[5]
      Kernel.pbMessage(_INTL("The door to #{player}'s base has opened!"))
      $game_variables[87]=player
    
      decompileSecretBase(basestring)
      pbCommonEvent(7)
    else
      Kernel.pbMessage("The user #{player} doesn't exist or hasn't created a base.")
       tradeorbattle
      end
  end
  
  end  
 
  def check_baseupload(result)
   # Kernel.pbMessage("1")
    if result == 0
      Kernel.pbMessage(_INTL("The base did not upload successfully."))
      tradeorbattle
    elsif result == 1
      Kernel.pbMessage(_INTL("The base was uploaded successfully!"))
      tradeorbattle
    end
  end 
def check_trade(player,result)
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
################################################################################
#-------------------------------------------------------------------------------
#Starts battle procedures
#-------------------------------------------------------------------------------
################################################################################
  def battle
    if !$Trainer.party[0] || $Trainer.party[0].egg? || $Trainer.party[0].hp<1
      Kernel.pbMessage("You need to be able to use the first Pokemon in your party.")
      return tradeorbattle
      break
    end
    
     for i in 0..$Trainer.party.length-1
      $Trainer.party[i].heal
    end
    $game_variables[124]=Array.new
    for i in 0..$Trainer.party.length-1
      $game_variables[124][i]=$Trainer.party[i].clone
    end
    $game_switches[371]=true    
    $game_switches[406]=true
    for i in $Trainer.party
        i.level=50
        i.calcStats
    end
    
    partyTemp=[]
    for poke in $Trainer.party
        partyTemp.push(Marshal.dump(poke))
    end
    
    pokemonArray=[]
    for poke in $Trainer.party
      poke.abilityflag="nil" if !poke.abilityflag
      if !poke.isShiny?
        shininess=0
      else
        shininess=1 
      end
      Kernel.pbMessage(shininess.to_s)
        varArray=[poke.species,
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
            var=var.to_s
        end
      pokemonArray.push(varArray.join("^%*"))
    end
  mons=pokemonArray.join("/u/")
    trainerAry=[$Trainer.name,
    $Trainer.id,
    $Trainer.trainertype,
    $Trainer.megaforme,
    $Trainer.clothes.join("s"),
    mons]
    #Marshal.dump($Trainer.clothes),
    #Marshal.dump($Trainer.party)]

    
    
#    serialized=trainerAry.pack("m").delete("\n")
    serialized=trainerAry.join("/g/")
    #serialized = [
    #[Marshal.dump($Trainer)].pack("m").delete("\n")
    loop do
      @player = Kernel.pbMessageFreeText(_INTL("Who would you like to battle with?"),"",false,32)
      Kernel.pbMessage("You cannot battle with yourself.") if @player == $network.username
      return tradeorbattle if @player == "" || @player == $network.username
      break
      end
      $network.send("<BAT user=#{@player} trainer=#{serialized}>")
    end
################################################################################
#-------------------------------------------------------------------------------
#Checks server's response for battle
#-------------------------------------------------------------------------------
################################################################################
  def check_battle(player,result,opponent)
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
 
  #        trainerAry=[$Trainer.name,
  #  $Trainer.id,
  #  $Trainer.trainertype,
  #  $Trainer.megaforme,
  #  Marshal.dump($Trainer.clothes),
  #  Marshal.dump($Trainer.party)]
      unpacked=opponent.split("/g/")
     # unpacked[0]=opponent.unpack("m")[0]
     # unpacked[1]=opponent.unpack("m")[1]
     # unpacked[2]=opponent.unpack("m")[2]
     # unpacked[3]=opponent.unpack("m")[3]
     # for 
      unpacked[4]=unpacked[4].split("s")
      #unpacked[4]=opponent.unpack("m")[4].split("s")
      #unpacked[5]=opponent.unpack("m")[5].split("s")
      #unpacked[4]=Marshal.load(opponent.unpack("m")[4])
      #unpacked[5]=Marshal.load(opponent.unpack("m")[5])
      unpacked[5]=unpacked[5].split("/u/")
 
      pokeAry=[]
      for prePoke in unpacked[5]
          longarray=prePoke.split("^%*")
          mon=PokeBattle_Pokemon.new(longarray[0].to_i,50)
          thing=0
          for v in 2..7
            mon.iv[thing]=longarray[v].to_i
            thing+=1
          end
          thing=0
          for v in 8..13
            mon.ev[thing]=longarray[v].to_i
            thing+=1
          end
          
          mon.personalID=longarray[14].to_i
        mon.trainerID=longarray[15].to_i
        mon.item=longarray[16].to_i
        mon.name=longarray[17]
        mon.exp=longarray[18].to_i
        mon.happiness[19].to_i
        for i in 0..3
          mon.moves[i]=PBMove.new(longarray[20+(i*2)].to_i)
          mon.moves[i].pp=longarray[21+(i*2)].to_i
        end
        mon.form=longarray[28].to_i
        mon.setNature(longarray[29].to_i)
 
        mon.totalhp=longarray[30].to_i
        mon.attack=longarray[31].to_i
        mon.defense=longarray[32].to_i
        mon.spatk=longarray[33].to_i
        mon.spdef=longarray[34].to_i
        mon.speed=longarray[35].to_i
 
        mon. ballused=longarray[36].to_i
        mon.ot=longarray[37]
            Kernel.pbMessage(longarray[38].to_s)
 
        if longarray[38].to_i==0 && mon.isShiny?
          mon.makeNotShiny
        elsif !mon.isShiny?
          mon.makeShiny
        end
        
        if longarray[38]!="nil"
          mon.abilityflag=longarray[38].to_i
        end
        pokeAry.push(mon)
      end
      
      
      
      deserialized=PokeBattle_Trainer.new(unpacked[0],unpacked[2])
   #   deserialized.name=unpacked[0]
      deserialized.id=unpacked[1]
    #  deserialized.trainertype=unpacked[2]
      deserialized.megaforme=unpacked[3]
      deserialized.clothes=unpacked[4]
      deserialized.party=pokeAry
      #deserialized.party=Marshal.load(unpacked[5])
      #deserialized = Marshal.load(opponent.unpack("m")[0])
 
      return start_battle(deserialized)
    end
  end
################################################################################
#-------------------------------------------------------------------------------
#Executes a battle
#-------------------------------------------------------------------------------
################################################################################
  def start_battle(opponent)
   #             Kernel.pbMessage("3")
 
    scene=pbNewBattleScene
    #            Kernel.pbMessage("4")
 
   # for i in 0..opponent.party.length-1
   #   opponent.party[i].heal
   # end
    
   # for i in opponent.party
   #     i.level=50
   #     i.calcStats
   #   end
  #    Kernel.pbMessage("My: "+$Trainer.party[0].attack.to_s)
  #    Kernel.pbMessage("Your: "+opponent.party[0].attack.to_s)
      
      
    battle=PokeBattle_OnlineBattle.new(scene,$Trainer.party,opponent.party,$Trainer,opponent)
  fullparty1 = true ? $Trainer.party.length == 6 : false
    fullparty2 = true ? opponent.party.length == 6 : false
    battle.fullparty1=fullparty1
    battle.fullparty2=fullparty2
    battle.endspeech=""
  battle.internalbattle=false
  $game_switches[393]=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  decision=battle.pbStartBattle(true)
  
  
  
  $Trainer.party=$game_variables[124]
    $game_switches[406]=false
  $game_switches[371]=false
  for i in 0..$Trainer.party.length-1
      $Trainer.party[i].heal
    end
$game_switches[393]=false
    if decision==1
    Kernel.pbMessage("You won the battle.")
    else
    Kernel.pbMessage("You lost the battle.")
    end
  tradeorbattle
       end
     end
     
################################################################################
#-------------------------------------------------------------------------------
#Handles Random Battling
#-------------------------------------------------------------------------------
################################################################################
 
 
  def randombattle
      fullarray=[]
      speciesArray=[]
      itemsArray=[]
      for poke in $Trainer.party
        pokeform=poke.form
        if poke.species==384
          for i in 0..3
            if poke.moves[i] && poke.moves[i].id==PBMoves::DRAGONSASCENT
                 pokeform=1
            end
          end
        end
        species="#{poke.species}_#{pokeform}"
        speciesArray.push(species)
      end
      speciesstring=speciesArray.join("^")
      fullarray.push(speciesstring)
      for poke in $Trainer.party
        helditem = poke.item
        itemsArray.push(helditem)
      end
      itemsstring=itemsArray.join("^")
      fullarray.push(itemsstring)
      fullstring = fullarray.join("/")
      $network.send("<RAND battle species=#{fullstring}>")
    end
    
    def rndbattle_tier(tier)
      commands=[_INTL("No Tier"),_INTL("Uber"),_INTL("OU"),_INTL("BL"),_INTL("UU"),_INTL("RU"),_INTL("NU"),_INTL("Cancel")]
      choice=Kernel.pbMessage(_INTL("The lowest tier you can battle in is #{tier}, what tier do you want to use?"),commands)
      if choice == 0
        $network.send("<RANBAT tier=notier>")
      elsif choice == 1
        $network.send("<RANBAT tier=Uber>")
      elsif choice == 2
        $network.send("<RANBAT tier=OU>")
      elsif choice == 3
        $network.send("<RANBAT tier=BL>")
      elsif choice == 4
        $network.send("<RANBAT tier=UU>")
      elsif choice == 5
        $network.send("<RANBAT tier=RU>")
      elsif choice == 6
        $network.send("<RANBAT tier=NU>")
      else
        $network.send("<RANBAT cancel>")
        return tradeorbattle
      end
    end
    
    def randbattlenotallowed
      Kernel.pbMessage("That tier is beneath you.")
      return tradeorbattle
    end
 
  def rndbattle_check(player)
      commands=[_INTL("Accept"),_INTL("Decline")]
      choice=Kernel.pbMessage(_INTL("User #{player} sent you a random battle request, What do you want to do?"),commands)
      if choice == 0
        
        
        
    if !$Trainer.party[0] || $Trainer.party[0].egg? || $Trainer.party[0].hp<1
      Kernel.pbMessage("You need to be able to use the first Pokemon in your party.")
      return tradeorbattle
      break
    end
    
     for i in 0..$Trainer.party.length-1
      $Trainer.party[i].heal
    end
    $game_variables[124]=Array.new
    for i in 0..$Trainer.party.length-1
      $game_variables[124][i]=$Trainer.party[i].clone
    end
    $game_switches[371]=true    
    $game_switches[406]=true
    for i in $Trainer.party
        i.level=50
        i.calcStats
    end
    
    partyTemp=[]
    for poke in $Trainer.party
        partyTemp.push(Marshal.dump(poke))
    end
    
    pokemonArray=[]
    for poke in $Trainer.party
      poke.abilityflag="nil" if !poke.abilityflag
      if !poke.isShiny?
        shininess=0
      else
        shininess=1 
      end
    Kernel.pbMessage(shininess.to_s)
        varArray=[poke.species,
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
        (poke.moves[0] ? poke.moves[0].pp : nil),
        poke.moves[1].id,
        (poke.moves[1] ? poke.moves[1].pp : nil),
        poke.moves[2].id,
        (poke.moves[2] ? poke.moves[2].pp : nil),
        poke.moves[3].id,
        (poke.moves[3] ? poke.moves[3].pp : nil),
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
            var=var.to_s
        end
      pokemonArray.push(varArray.join("^%*"))
    end
  mons=pokemonArray.join("/u/")
    trainerAry=[$Trainer.name,
    $Trainer.id,
    $Trainer.trainertype,
    $Trainer.megaforme,
    $Trainer.clothes.join("s"),
    mons]
    
    serialized=trainerAry.join("/g/")
        $network.send("<BAT user=#{player} trainer=#{serialized}>")
      elsif choice == 1
        $network.send("<RANBAT decline user=#{player}>")
        return tradeorbattle
      end
    end
    
def ranbattle_denied(user)
  Kernel.pbMessage("#{user} has denied your random battle request")
  $network.send("<RANBAT cancel>")
  tradeorbattle
end
 
def getversion()
  _version = "2.0"
#  _version = "6.84" if $DEBUG
  return _version
end
=end