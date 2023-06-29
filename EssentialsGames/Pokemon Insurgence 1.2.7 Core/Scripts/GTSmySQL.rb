######### Variables
URL = "http://zeta-omicron.net23.net/GTS_get.php"
VAR = [7,8,6] # Value 1: Stored Pokemon Data, Value 2 Stored Name Data, and 3 if do or don't have a deposited pokemon
LISTING = "All" # pokemon search listing type (Seen,Owned, and All)
CHECKEVO = true # If you want to check evolutions after trade....
OID = 25 # online ID (dependant on ID and Secret ID and a random 0-512 at the end)
###################### Startup

def pbStartGTS
  if $game_variables[OID] == 0
    $game_variables[OID]="#{$Trainer.id}#{rand(512)}"
  end
  if $game_variables[VAR[2]] == 0
    $game_variables[VAR[2]] = "Deposit Pokemon"
  end
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
  commands=CommandList.new
  commands.add("own",_INTL("{1}", $game_variables[VAR[2]]))
  commands.add("search",_INTL("Search for Pokemon"))
  sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
  cmdwindow=sprites["cmdwindow"]
  cmdwindow.viewport=viewport
  cmdwindow.resizeToFit(cmdwindow.commands)
  cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.x=0
  cmdwindow.y=0
  cmdwindow.visible=true
  pbFadeInAndShow(sprites)
  ret=-1
      loop do
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        ret=-1
        break
        return ret
      end
      if Input.trigger?(Input::C)
        ret=cmdwindow.index
        break
      end
    end
    break if ret==-1
    cmd=commands.getCommand(ret)
    if cmd == "own"
      pbPokemonGate()
    elsif cmd == "search"
      pbSearchListGTS()
    end
  end
end

###################### Multi Methods

#### This method turns a species name (pikachu for example) into it's number(25 for example)
def pbGetSpeciesNumber(name)
  # Works
  for i in 0..PBSpecies.maxValue
    if PBSpecies.getName(i) == name
      return i
    end
  end
  return false
end


def pbDeleteGTSPokemon(poke)
  # Works
  x=false
  for i in 0..40
    for j in 0..30
      if $PokemonStorage[i][j] == poke

        $PokemonStorage[i][j] = nil
        x=true
      end
      if x=true
        break
      end
    end
  if x=true
    break
  end
  
  end
  if x == true
    return
  else
    for i in 0..$Trainer.party.length
      if $Trainer.party[i] == poke
        pbRemovePokemonAt(i)
      end
    end
  end
end
      

def pbCompleteTradeGTS(get,send)
  # Works
  if $Trainer.party.length < 6
    # sends the Taken/Delete info to the file.
    get=pbStringToPoke(get)
    pbAddToPartySilent(get)
    # evolution check
    pbDeletePokemonGTS
    get2=get
    pbTakenPokemon(get2,send)
    if CHECKEVO==true
    newspecies=Kernel.pbCheckEvolution(get)
      if newspecies>0
        # Start evolution scene
        evo=PokemonEvolutionScene.new
        evo.pbStartScreen(get,newspecies)
        evo.pbEvolution
        evo.pbEndScreen
      end
    end
      pbSave
      Kernel.pbMessage(_INTL("The game has been saved and the trade was successful!"))
      return true
  else
    Kernel.pbMessage("Your party is full!")
    return
  end
end

def pbGetBoxPokemon
  # Works
  $game_switches[50] = true
  $game_variables[1] = $game_variables[VAR[0]]
  $game_variables[VAR[0]] = false
  pbFadeOutIn(99999){
  scene=PokemonStorageScene.new
  screen=PokemonStorageScreen.new(
  scene,$PokemonStorage)
  screen.pbStartScreen(2)
  }
  return
end

def pbSetRestrictions
  # Works
  lary=[0,0]
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
  allow = "X"
  $game_variables[1] = "X"
  commands=CommandList.new
  commands.add("poke",_INTL("Wanted Pokemon: {1}", "X"))
  commands.add("lvl",_INTL("Level Restrictions: {1} - {2}",lary[0],lary[1]))
  commands.add("search",_INTL("Send {1}", allow))
  sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
  cmdwindow=sprites["cmdwindow"]
  cmdwindow.viewport=viewport
  cmdwindow.resizeToFit(cmdwindow.commands)
  cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.x=0
  cmdwindow.y=0
  cmdwindow.visible=true
  pbFadeInAndShow(sprites)
  ret=-1
      loop do
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        ret=-1
        break
        return false
      end
      if Input.trigger?(Input::C)
        ret=cmdwindow.index
        break
      end
    end
    break if ret==-1
    cmd=commands.getCommand(ret)
    if cmd == "poke"
      $game_variables[1]=pbPokeList()
      ret=cmdwindow.index
      commands=CommandList.new
      commands.add("poke",_INTL("Wanted Pokemon: {1}", $game_variables[1]))
      commands.add("lvl",_INTL("Level Restrictions: {1} - {2}",lary[0],lary[1]))
      commands.add("search",_INTL("Send {1}", allow))
      sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
      cmdwindow=sprites["cmdwindow"]
      cmdwindow.viewport=viewport
      cmdwindow.resizeToFit(cmdwindow.commands)
      cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
      cmdwindow.x=0
      cmdwindow.y=0
      cmdwindow.visible=true
      pbFadeInAndShow(sprites)
      allow = "O" if $game_variables[1] != "X" and lary[0] > 0 and lary[1] >= lary[0]
      ret=-1
    elsif cmd == "lvl"
      ret=pbSearchLevel("min")
      ret2=pbSearchLevel("max")
      lary=[ret,ret2]
      ret=cmdwindow.index
      commands=CommandList.new
      commands.add("poke",_INTL("Wanted Pokemon: {1}", $game_variables[1]))
      commands.add("lvl",_INTL("Level Restrictions: {1} - {2}",lary[0],lary[1]))
      commands.add("search",_INTL("Send {1}", allow))
      sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
      cmdwindow=sprites["cmdwindow"]
      cmdwindow.viewport=viewport
      cmdwindow.resizeToFit(cmdwindow.commands)
      cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
      cmdwindow.x=0
      cmdwindow.y=0
      cmdwindow.visible=true
      pbFadeInAndShow(sprites)
      allow = "O" if $game_variables[1] != "X" and lary[0] > 0 and lary[1] >= lary[0]
      ret=-1
    elsif cmd == "search"
      if allow == "O"
        ret=[pbGetSpeciesNumber($game_variables[1]),lary]
        return ret
      end
    end
  end
end

def pbSearchLevel(type)
  # Works
  if type == "min"
    params=ChooseNumberParams.new
    params.setRange(1,PBExperience::MAXLEVEL)
    params.setInitialValue(5)
    params.setCancelValue(1)
    level=Kernel.pbMessageChooseNumber(
    _INTL("Minumum Level to Search."),params)
  elsif type == "max"
    params=ChooseNumberParams.new
    params.setRange(1,PBExperience::MAXLEVEL)
    params.setInitialValue(100)
    params.setCancelValue(1)
    level=Kernel.pbMessageChooseNumber(
    _INTL("Maximum Level to Search."),params)
  end
end  

def pbPokeList()
  # Works
  default=1
  cmdwin=pbListWindow([],200)
  commands=[]
  for i in 1..PBSpecies.maxValue
    if $Trainer.seen[i] and LISTING == "Seen"
      commands.push(_ISPRINTF("{1:s}",PBSpecies.getName(i)))
    end
    if $Trainer.owned[i] and LISTING == "Owned"
      commands.push(_ISPRINTF("{1:s}",PBSpecies.getName(i)))
    end
    if LISTING == "All"
      commands.push(_ISPRINTF("{1:s}",PBSpecies.getName(i)))
    end
  end
  ret=pbCommands2(cmdwin,commands,-1,default-1,true) 
  cmdwin.dispose
  if ret >= 0
    $game_variables[1]=commands[ret]
  end
  return $game_variables[1]
end


###################### Upload

def pbPokemonGate
  # Works
  if $game_variables[VAR[2]] == "Deposit Pokemon"
    pbDepositPokemon
  else
    pbGTSSummary
  end
end

def pbDepositPokemon
  # Works
  pbGetBoxPokemon
  if $game_variables[1] == -1 || $game_variables[1] == 0
    Kernel.pbMessage(_INTL("No pokemon has been selected."))
    return
  end

  $game_variables[VAR[0]]=$game_variables[1]

  restrict=pbSetRestrictions
  pbSendPokemon($game_variables[VAR[0]],restrict)
  pbDeleteGTSPokemon($game_variables[VAR[0]])
  pbGTSSummary
  $game_variables[VAR[2]] = "Pokemon Summary"
end

def pbGTSSummary
  # Works 
   if !$game_variables[VAR[0]].instance_of?(PokeBattle_Pokemon)
      $game_variables[VAR[0]] = $game_variables[VAR[0]][0]
    end
    
    
  data=pbCheckTaken
  data=data.split("(!!)")
  if data[0] == "Yes"
    pbCompleteTradeGTS(data[1],$game_variables[VAR[0]])
    return
  end


 # Kernel.pbMessage(_INTL("name: {1}",$game_variables[VAR[0]].name))
  poke=$game_variables[VAR[0]]
  return if !poke
  scene=PokemonSummaryScene.new
  screen=PokemonSummary.new(scene)
  pbFadeOutIn(99999){
    screen.pbStartScreen([poke],0)
  }
  if Kernel.pbConfirmMessageSerious(_INTL("Would you like your pokemon back?"))
    return Kernel.pbMessage(_INTL("Your party is full!")) if $Trainer.party.length == 6
    pbAddToPartySilent(poke)
    $game_variables[VAR[2]] = "Deposit Pokemon"
  end
  return
end


###################### Search Methods

def pbSearchListGTS()
  # Works
  lary=[0,0]
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
  allow = "X"
  $game_variables[1] = "X"
  commands=CommandList.new
  commands.add("poke",_INTL("Search Pokemon: {1}", "X"))
  commands.add("lvl",_INTL("Level Restrictions: {1} - {2}",lary[0],lary[1]))
  commands.add("search",_INTL("Search {1}", allow))
  sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
  cmdwindow=sprites["cmdwindow"]
  cmdwindow.viewport=viewport
  cmdwindow.resizeToFit(cmdwindow.commands)
  cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.x=0
  cmdwindow.y=0
  cmdwindow.visible=true
  pbFadeInAndShow(sprites)
  ret=-1
      loop do
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        ret=-1
        break
        return false
      end
      if Input.trigger?(Input::C)
        ret=cmdwindow.index
        break
      end
    end
    break if ret==-1
    cmd=commands.getCommand(ret)
    if cmd == "poke"
      $game_variables[1]=pbPokeList()
      ret=cmdwindow.index
      commands=CommandList.new
      commands.add("poke",_INTL("Search Pokemon: {1}", $game_variables[1]))
      commands.add("lvl",_INTL("Level Restrictions: {1} - {2}",lary[0],lary[1]))
      allow = "O" if $game_variables[1] != "X" and lary[0] > 0 and lary[1] >= lary[0]
      commands.add("search",_INTL("Search {1}", allow))
      sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
      cmdwindow=sprites["cmdwindow"]
      cmdwindow.viewport=viewport
      cmdwindow.resizeToFit(cmdwindow.commands)
      cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
      cmdwindow.x=0
      cmdwindow.y=0
      cmdwindow.visible=true
      pbFadeInAndShow(sprites)
      allow = "O" if $game_variables[1] != "X" and lary[0] > 0 and lary[1] >= lary[0]
      ret=-1
    elsif cmd == "lvl"
      ret=pbSearchLevel("min")
      ret2=pbSearchLevel("max")
      lary=[ret,ret2]
      ret=cmdwindow.index
      commands=CommandList.new
      commands.add("poke",_INTL("Search Pokemon: {1}", $game_variables[1]))
      commands.add("lvl",_INTL("Level Restrictions: {1} - {2}",lary[0],lary[1]))
      commands.add("search",_INTL("Search {1}", allow))
      sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
      cmdwindow=sprites["cmdwindow"]
      cmdwindow.viewport=viewport
      cmdwindow.resizeToFit(cmdwindow.commands)
      cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
      cmdwindow.x=0
      cmdwindow.y=0
      cmdwindow.visible=true
      pbFadeInAndShow(sprites)
      allow = "O" if $game_variables[1] != "X" and lary[0] > 0 and lary[1] >= lary[0]
      ret=-1
    elsif cmd == "search"
      if allow == "O"
 #       if !$game_variables[VAR[0]].instance_of?(PokeBattle_Pokemon)
 #       pbStartSearchGTS(pbGetSpeciesNumber($game_variables[1][0]),lary)
 #     else
        pbStartSearchGTS(pbGetSpeciesNumber($game_variables[1]),lary)
#      end
    end
  end
  end
end

def pbStartSearchGTS(species,lary)
  data=pbSearchPokemon([species,lary])
  if data == "None" || data == "" 
    Kernel.pbMessage(_INTL("There are no pokemon with those attributes."))
    return false
  end
  if data == "prob1" || data =="prob2"
     Kernel.pbMessage(_INTL("Houston, we have a problem."))
     return false
   end
  x=data.split("(!!)")
  num=pbGetGTSTradeListing(x)
  return if num == -1
  if !pbGetData(data,num)
    return
  end
  
  data=pbGetData(data,num)
  code=data[num][1]
  wanted=data[num][2].to_i
  lary=[data[num][3].to_i,data[num][4].to_i]
  species=data[num][7].to_i
  level=data[num][8].to_i
  prev=$game_variables[VAR[0]]
  return if !Kernel.pbConfirmMessage(_INTL("Pokemon: {1}, Level: {2}, Wants {3} Levels: {4}-{5}",PBSpecies.getName(species),level,PBSpecies.getName(wanted),lary[0],lary[1]))
  pbGetBoxPokemon()
  poke=$game_variables[1]
  if $game_variables[VAR[0]] == false
    $game_variables[VAR[0]] = prev
    return
  end
  $game_variables[VAR[0]] = prev
#  poke2=$game_variables[50][0]
#  $game_variables[VAR[0]] = prev
#  selected=ary[1]
#  poke3=ary[2]
  x=pbCheckPokemonGTS(poke[0],wanted,lary)
  return false if x==false
  pbCompleteTradeGTS(code,$game_variables[VAR[0]])
end


def pbCheckPokemonGTS(poke,wanted,lary)
#  print poke.species
#  print poke.level
  species=false
  level=false
  if poke.species == wanted
    species = true
  end
  if poke.level >= lary[0] and poke.level <= lary[1]
    level = true
  end
  if species == true and level == true
    return true
  else
    Kernel.pbMessage(_INTL("This isn't the correct pokemon!"))
    return false
  end
end

########## Displays all pokemon's visible data (Name/Level)
def pbGetGTSTradeListing(get)
  i=0
  default=1
  cmdwin=pbListWindow([],200)
  commands=[]
    while i < get.length do
      commands.push(_INTL("{1}: {2} ",PBSpecies.getName(get[i+7].to_i),get[i+8]))
      i+=9
    end
  ret=pbCommands2(cmdwin,commands,-1,default-1,true) 
  cmdwin.dispose
  return ret
end


###################### Other Methods
# Not tested but should work
def pbGetData(data,num) # Get's data..
  data=pbSeperateMain(data)
  if data[5*num] == "Yes"
    Kernel.pbMessage("\rThis Pokemon has already been taken!")
  end
  
  if $game_variables[34] == 1
    Kernel.pbMessage("\rThis is your Pokemon!")
    return false
  end
  
 #   Kernel.pbMessage("trainer", data[num][0].to_i)  
 #   str=data[1].split("/!!/") # This splits the string at every /!i/
 #   return false if data[5].to_i == $Trainer.id
  ret=[data[1*num],data[2*num],data[3*num],data[4],data[7],data[8]]
  # Returns ret which consists of: Code, Wanted, Level1, Level2, Species, Level, ID
  return ret
end


###################### Send Methods

# All the below Works

### Sends the startoff data to the Database
def pbSendPokemon(pkmn, restrict)
  pkstr=pkmn.pbToString(pkmn)
  send={
  "Request" => "send_pokemon",
  "ID" => id,
  "Code" => pkstr,
  "Wanted" => restrict[0],
  "Level1" => restrict[1][0],
  "Level2" => restrict[1][1],
  "Level" => pkmn[0].level,
  "Species" => pkmn[0].species
  }
  #PBExperience.pbGetLevelFromExperience(pkmn.exp,pkmn.growthrate)
  # Returns 1
  print pbPostData(URL,send)
  return pbPostData(URL,send)
end

### Searches for Pokemon with the attributes of restrict and Taken = no
def pbSearchPokemon(restrict)
  id=$game_variables[OID]
  send={
  "Request" => "search_pokemon",
  "Wanted" => restrict[0],
  "Level1" => restrict[1][0],
  "Level2" => restrict[1][1]
  }
  # Returns Array of Pokemon....
#  if pbPostData(URL,send) == nil || pbPostData(URL,send) == ""
#    Kernel.pbMessage("NIL")
#  end
  
#    Kernel.pbMessage(_INTL("heh and #{pbPostData(URL,send)}",pbDownloadToString(URL)))
  
  return pbPostData(URL,send) 
  end
  

### Deletes your pokemon from the database (used for completing trade/withdrawing)
def pbDeletePokemonGTS
  id=$game_variables[OID]
  send={
  "Request" => "delete_pokemon",
  "ID" => id
  }
  # Returns 1
  return pbPostData(URL,send)
end

### If someone took a pokemon this is called so we may insert new pokemon into it.
def pbTakenPokemon(code1,code2)
#egege
  send={
  "Request" => "pokemon_taken",
  "Pokemon" => code1,
  "New" => code2
  }
  var = pbPostData(URL,send)
  # Returns Array of new sutff?
  return var
  end

### Checks if your pokemon is taken (checks by ID)
def pbCheckTaken
  id=$game_variables[OID]
  send={
  "Request" => "taken_pokemon",
  "ID" => id
  }
  # Returns Array Of Taken?
  return pbPostData(URL,send)
end
######################### Seperation Methods
def pbSeperateMain(data) # Main seperator
  ary=data.split("(!!)")
  ret=[]
  j=0
  k=0
  for i in 0..ary.length-1
    ret[i]=[]
  end
  for i in 0..ary.length-1
    ret[j][i]=ary[i] if ary[i] != "Array"
    j+=1 if k >= 8
    k+=1
    k=0 if k>=8
  end
    str=ary[1].split("/!!/") # This splits the string at every /!i/
    $game_variables[34] = 1 if str[5].to_i == $Trainer.id

  return ret #ID, Pokemon, Wanted, Level1, Level2, Taken, Taken Code, Species, Level
end

def pbSeperateTaken(data) # Takes Taken/Taken Code data only
  ary=data.split("(!!)")
  ret=[ary[5],ary[6]]
  return ret # Taken, Taken Code
end


############################## Testing
### This is for pre-developed methods for posting, it's not needed delete it if you want.
def pbTestPost
  x=pbSendPokemon($Trainer.party[0],[493,[1,100]])
  x=pbSearchPokemon([460,[1,100]])
  x=x.split("(!!)")
  for i in x
    print i if i != "Array"
  end
end


def pbTestCode
  x=$Trainer.party[0].toString
  print x
  pbAddPokemon2(pbStringToPoke(x))
end

########################### Others

  def pbToString(pkmn)
    if !pkmn.instance_of?(PokeBattle_Pokemon)
      pkmn = pkmn[0]
    end
    str="#{pkmn.species}/!!/#{pkmn.level}/!!/#{pkmn.iv[0]}!@$#{pkmn.iv[1]}!@$#{pkmn.iv[2]}!@$#{pkmn.iv[3]}!@$#{pkmn.iv[4]}!@$#{pkmn.iv[5]}/!!/"
    str="#{str}#{pkmn.ev[0]}!@$#{pkmn.ev[1]}!@$#{pkmn.ev[2]}!@$#{pkmn.ev[3]}!@$#{pkmn.ev[4]}!@$#{pkmn.ev[5]}/!!/#{pkmn.personalID}/!!/"
    str="#{str}#{pkmn.trainerID}/!!/#{pkmn.pokerus}/!!/#{pkmn.pokerusTime}/!!/#{pkmn.item}/!!/#{pkmn.mail}/!!/"
    str="#{str}#{pkmn.name}/!!/"
    str="#{str}#{pkmn.exp}/!!/#{pkmn.moves[0].id}!@$#{pkmn.moves[0].pp}!@$#{pkmn.moves[0].ppup}/!!/#{pkmn.moves[1].id}/!!/"
    str="#{str}#{pkmn.moves[1].pp}!@$#{pkmn.moves[1].ppup}/!!/#{pkmn.moves[2].id}!@$#{pkmn.moves[2].pp}!@$#{pkmn.moves[2].ppup}/!!/"
    str="#{str}#{pkmn.moves[3].id}!@$#{pkmn.moves[3].pp}!@$#{pkmn.moves[3].ppup}/!!/"
    str="#{str}#{pkmn.ballused}/!!/#{pkmn.obtainMap}/!!/#{pkmn.obtainLevel}/!!/#{pkmn.language}/!!/#{pkmn.ot}/!!/"
    return str # now we return the string
  #  Kernel.pbMessage(_INTL("heh {1}",$PokemonStorage[0][0].name))
 # Kernel.pbMessage(_INTL("language {1}", pkmn.name))
=begin
  str="#{@species}/!!/#{pkmn.level}/!!/"
    str="#{str}#{getIvHandle(pkmn,0)}/!!/"
    str="#{str}#{getIvHandle(pkmn,1)}/!!/#{getIvHandle(pkmn,2)}/!!/"
    str="#{str}#{getIvHandle(pkmn,3)}/!!/#{getIvHandle(pkmn,4)}/!!/#{getIvHandle(pkmn,5)}/!!/"
    str="#{str}#{getEvHandle(pkmn,0)}/!!/#{getEvHandle(pkmn,1)}/!!/#{getEvHandle(pkmn,2)}/!!/#{getEvHandle(pkmn,3)}/!!/#{getEvHandle(pkmn,4)}/!!/#{getEvHandle(pkmn,5)}/!!/#{@personalID}/!!/"
    str="#{str}#{@trainerID}/!!/#{@pokerus}/!!/#{@pokerusTime}/!!/#{@item}/!!/#{@mail}/!!/"
    str="#{str}#{@name}/!!/"
    str="#{str}#{@exp}/!!/#{getMoveIDHandle(pkmn,0)}/!!/#{getMovePPHandle(pkmn,0)}/!!/#{getMovePPUpHandle(pkmn,0)}/!!/#{getMoveIDHandle(pkmn,1)}/!!/"
    str="#{str}#{getMovePPHandle(pkmn,1)}/!!/#{getMovePPUpHandle(pkmn,1)}/!!/#{getMoveIDHandle(pkmn,2)}/!!/#{getMovePPHandle(pkmn,2)}/!!/#{getMovePPUpHandle(pkmn,2)}/!!/"
    str="#{str}#{getMoveIDHandle(pkmn,3)}/!!/#{getMovePPHandle(pkmn,3)}/!!/#{getMovePPUpHandle(pkmn,3)}/!!/"
    str="#{str}#{@ballused}/!!/#{@obtainMap}/!!/#{@obtainLevel}/!!/#{@language}/!!/"
    return str # now we return the string
=end
  end

def getIvHandle(pkmn,i)
    return pkmn.iv[i]
  end
  def getEvHandle(pkmn,i)
    return pkmn.ev[i]
  end
  def getMoveIDHandle(pkmn,i)
    return pkmn.moves[i].id
  end
  def getMovePPHandle(pkmn,i)
    return pkmn.moves[i].pp
  end
  def getMovePPUpHandle(pkmn,i)
    return pkmn.moves[i].ppup
  end
  

def pbStringToPoke(str)
  ary=str.split("/!!/") # This splits the string at every /!i/
  pkmn=PokeBattle_Pokemon.new(1,1)
  pkmn.species=ary[0].to_i
  pkmn.level=ary[1].to_i if ary[1].to_i == 0
  pkmn.iv=ary[2].split("!@$")# This splits the string at every !@$
  for i in 0..pkmn.iv.length-1
    pkmn.iv[i]=pkmn.iv[i].to_i
  end
  pkmn.ev=ary[3].split("!@$") # This splits the string at every !@$
  for i in 0..pkmn.ev.length-1
    pkmn.ev[i]=pkmn.ev[i].to_i
  end
  pkmn.personalID=ary[4].to_i
  pkmn.trainerID=ary[5].to_i
  pkmn.pokerus=ary[6].to_i
  pkmn.pokerusTime=ary[7]
  pkmn.item=ary[8].to_i
  pkmn.name=ary[10]
  pkmn.exp=ary[11].to_i
  # Move1
  move=ary[12].split("!@$")
  pkmn.moves[0]=PBMove.new(move[0].to_i)
  pkmn.moves[0].ppup=move[2].to_i
  # Move2
  move=ary[13].split("!@$")
  pkmn.moves[1]=PBMove.new(move[0].to_i)
  pkmn.moves[1].ppup=move[2].to_i
  # Move3
  move=ary[14].split("!@$")
  pkmn.moves[2]=PBMove.new(move[0].to_i)
  pkmn.moves[2].ppup=move[2].to_i
  # Move4
  move=ary[15].split("!@$")
  pkmn.moves[3]=PBMove.new(move[0].to_i)
  pkmn.moves[3].ppup=move[2].to_i
  pkmn.ballused=ary[16].to_i
  pkmn.obtainMap=ary[17]
  pkmn.obtainLevel=ary[18].to_i
  pkmn.language=ary[19]
  pkmn.ot=ary[20]
  
  pkmn.calcStats
  return pkmn
  
=begin  pkmn=PokeBattle_Pokemon.new(1,1)
  pkmn.species=ary[0].to_i
  pkmn.level=ary[1].to_i if ary[1].to_i == 0
  pkmn.iv[0]=ary[2].to_i
  pkmn.iv[1]=ary[3].to_i
  pkmn.iv[2]=ary[4].to_i
  pkmn.iv[3]=ary[5].to_i
  pkmn.iv[4]=ary[6].to_i
  pkmn.iv[5]=ary[7].to_i
  pkmn.ev[0]=ary[8].to_i
  pkmn.ev[1]=ary[9].to_i
  pkmn.ev[2]=ary[10].to_i
  pkmn.ev[3]=ary[11].to_i
  pkmn.ev[4]=ary[12].to_i
  pkmn.ev[5]=ary[13].to_i
  pkmn.personalID=ary[14].to_i
  pkmn.trainerID=ary[15].to_i
  pkmn.pokerus=ary[16].to_i
  pkmn.pokerusTime=ary[17]
  pkmn.item=ary[18].to_i
  pkmn.name=ary[20]
  pkmn.exp=ary[21].to_i
  pkmn.moves[0]=PBMove.new(ary[22].to_i)
  pkmn.moves[0].ppup=ary[23].to_i
  pkmn.moves[1]=PBMove.new(ary[24].to_i)
  pkmn.moves[1].ppup=ary[25].to_i
  pkmn.moves[2]=PBMove.new(ary[26].to_i)
  pkmn.moves[2].ppup=ary[27].to_i
  pkmn.moves[3]=PBMove.new(ary[28].to_i)
  pkmn.moves[3].ppup=ary[29].to_i
  pkmn.ballused=ary[30].to_i
  pkmn.obtainMap=ary[31]
  pkmn.obtainLevel=ary[32].to_i
  pkmn.language=ary[33]
=end
#  pkmn.iv=ary[2].split("/!i/")# This splits the string at every /!i/
#  for i in 0..pkmn.iv.length-1
#    pkmn.iv[i]=pkmn.iv[i].to_i
#  end
 # pkmn.ev=ary[3].split("/!i/") # This splits the string at every /!i/
 # for i in 0..pkmn.ev.length-1
 #   pkmn.ev[i]=pkmn.ev[i].to_i
 # end
#  pkmn.personalID=ary[4].to_i
#  pkmn.trainerID=ary[5].to_i
#  pkmn.pokerus=ary[6].to_i
#  pkmn.pokerusTime=ary[7]
#  pkmn.item=ary[8].to_i
#  pkmn.name=ary[10]
#  pkmn.exp=ary[11].to_i
  # Move1
#  move=ary[12].split("/!i/")
#  pkmn.moves[0]=PBMove.new(move[0].to_i)
#  pkmn.moves[0].ppup=move[2].to_i
  # Move2
#  move=ary[13].split("/!i/")
#  pkmn.moves[1]=PBMove.new(move[0].to_i)
#  pkmn.moves[1].ppup=move[2].to_i
  # Move3
#  move=ary[14].split("/!i/")
#  pkmn.moves[2]=PBMove.new(move[0].to_i)
#  pkmn.moves[2].ppup=move[2].to_i
  # Move4
#  move=ary[15].split("/!i/")
#  pkmn.moves[3]=PBMove.new(move[0].to_i)
#  pkmn.moves[3].ppup=move[2].to_i
#  pkmn.ballused=ary[16].to_i
#  pkmn.obtainMap=ary[17]
#  pkmn.obtainLevel=ary[18].to_i
#  pkmn.language=ary[19]
  end
