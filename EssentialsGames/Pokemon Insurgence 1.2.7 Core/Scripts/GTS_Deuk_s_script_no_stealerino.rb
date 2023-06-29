class GTSHandler
  @Connect
  class << self
    attr_accessor :Connect
  end
  #Handles the menu choices
  def self.handlegts()
    commands = [_INTL("Create Trade"), _INTL("Find Trade"), _INTL("My Trades"),
                _INTL("Cancel")]
    choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands)
    if choice == 0
      create_trade
    elsif choice == 1
      find_trade
    elsif choice == 2
      $network.send("<GTSMINE>")
    else
      return @Connect.tradeorbattle
    end
  end

  def self.create_trade
    pbChoosePokemon(1, 2, proc { |poke|
      !poke.egg? && poke.hp > 0
    }) #TODO
    if $game_variables[1] == -1
      handlegts
    else
      index = $game_variables[1]
      pokestring = [JSON.encode($Trainer.party[index])].pack("m")
      req = GTSRequestHolder.new

      pokemonList = ["(Any)", "(Search)"]
      for poke in 1..PBSpecies.maxValue - 1
        if $Trainer.seen[poke]
          name = PBSpecies.getName(poke)
          name = "Delta " + PBSpecies.getName(poke) if poke >= PBSpecies::DELTABULBASAUR
          pokemonList.push(poke.to_s + ": " + PBSpecies.getName(poke))
        end
      end
      pokeVar = Kernel.pbMessage("Please select a Pokemon to search for.", pokemonList)
      if pokeVar < 0
        handlegts
      elsif pokeVar == 0
        req.Species = 0
      elsif pokeVar == 1
        req.Species = -1
        searchTerm = pbEnterText("Search for what Pokemon?", 3, 14).downcase
        if searchTerm.include?("delta")
          searchTerm.slice!("delta")
          searchTerm.strip!
          for i in PBSpecies::DELTABULBASAUR..PBSpecies.maxValue - 1
            if PBSpecies.getName(i).include?(searchTerm)
              req.Species = i
              break
            end
          end
        else
          searchTerm.strip!
          for i in PBSpecies::BULBASAUR..PBSpecies::MISSINGNO
            if PBSpecies.getName(i).include?(searchTerm)
              req.Species = i
              break
            end
          end
        end
      else
        tempAry = []
        for poke in 1..PBSpecies.maxValue - 1
          if $Trainer.seen[poke]
            tempAry.push(poke)
          end
        end
        req.Species = tempAry[pokeVar - 2]
      end
      if req.Species == -1
        Kernel.pbMessage("Pokemon not found.")
        tradeorbattle
      else
        params = ChooseNumberParams.new
        params.setRange(1, 100)
        params.setInitialValue(0)
        params.setCancelValue(0)
        req.MinLevel = Kernel.pbMessageChooseNumber(_INTL("What is the minimum level you want to search for?"), params)

        ary = ["Male", "Female", "(Any)"]
        req.Gender = Kernel.pbMessage("What gender are you searching for?", ary)

        natureAry = []

        for i in 0..24
          natureAry.push(PBNatures.getName(i))
        end
        natureAry.push("(Any)")
        req.Nature = Kernel.pbMessage("What nature would you like to search for?", natureAry)
      end

      reqstring = [JSON.encode(req)].pack("m")
      $game_variables[181] = pokestring
      $network.send("<GTSCREATE|offer=#{pokestring}|request=#{reqstring}|index=#{index}>")
    end
  end

  def self.checkgtscreate(result, teamindex)
    if result == 0
      Kernel.pbMessage("You were banned from the server")
      return @Connect.tradeorbattle
    elsif result == 1
      Kernel.pbMessage("You already have the maximum number of allowed trades!")
      return @Connect.tradeorbattle
    elsif result == 2
      Kernel.pbMessage("Something went wrong with your request")
      return @Connect.tradeorbattle
    elsif result == 3
      $Trainer.party.delete_at(teamindex)
      Kernel.pbMessage("Your trade was succesfully uploaded")
      pbSave
      return @Connect.tradeorbattle
    end
  end
  ###################################################
  #Simple function to request open trades in the GTS#
  ###############################################################
  #GTSIndex indicates the position you want to receive trades in#
  ###############################################################
  def self.find_trade(gtsindex = 0)
    #the filter class can be found at the bottom of this script
    #general rule of thumb, by changing nothing nothing is filtered out
    filter = RequestFilter.new()
    pokemonList = ["(Any)", "(Search)"]
    for poke in 1..PBSpecies.maxValue - 1
      if $Trainer.seen[poke]
        name = PBSpecies.getName(poke)
        name = "Delta " + PBSpecies.getName(poke) if poke >= PBSpecies::DELTABULBASAUR
        pokemonList.push(poke.to_s + ": " + PBSpecies.getName(poke))
      end
    end
    pokeVar = Kernel.pbMessage("Please select a Pokemon to search for.", pokemonList)
    if pokeVar < 0
      tradeorbattle
    elsif pokeVar == 0
      filter.Species = 0
    elsif pokeVar == 1
      filter.Species = -1
      searchTerm = pbEnterText("Search for what Pokemon?", 3, 14).downcase
      if searchTerm.include?("delta")
        searchTerm.slice!("delta")
        searchTerm.strip!
        for i in PBSpecies::DELTABULBASAUR..PBSpecies.maxValue - 1
          if PBSpecies.getName(i).include?(searchTerm)
            filter.Species = i
            break
          end
        end
      else
        searchTerm.strip!
        for i in PBSpecies::BULBASAUR..PBSpecies::MISSINGNO
          if PBSpecies.getName(i).include?(searchTerm)
            filter.Species = i
            break
          end
        end
      end
    else
      tempAry = []
      for poke in 1..PBSpecies.maxValue - 1
        if $Trainer.seen[poke]
          tempAry.push(poke)
        end
      end
      filter.Species = tempAry[pokeVar - 2]
    end
    if filter.Species == -1
      Kernel.pbMessage("Pokemon not found.")
      return @Connect.tradeorbattle
    else
      params = ChooseNumberParams.new
      params.setRange(1, 100)
      params.setInitialValue(0)
      params.setCancelValue(0)
      filter.MinLevel = Kernel.pbMessageChooseNumber(_INTL("What is the minimum level you want to search for?"), params)

      ary = ["Male", "Female", "(Any)"]
      filter.Gender = Kernel.pbMessage("What gender are you searching for?", ary)

      natureAry = []
      for i in 0..24 #24
        natureAry.push(PBNatures.getName(i))
      end
      natureAry.push("(Any)")
      # for opt in natureAry
      ##   Kernel.pbMessage(opt)
      #end

      filter.Nature = Kernel.pbMessage("What nature would you like to search for?", natureAry)
      #Kernel.pbMessage(filter.Nature.to_s)

      #  Kernel.pbMessage(filter.Species.to_s)
      serializefilter = [(JSON.encode(filter))].pack("m")
      $network.send("<GTSREQUEST|index=#{gtsindex}|filter=#{serializefilter}>")
    end
  end
  #############################
  # Display open trades in GTS#
  ###########################################################################
  #Occurs when receives callback message from server, where string contains #
  #a joined array of Pokemon data separated by \r. Function splits up array,#
  #turns the JSON string into an anonymous object, then displays the trades #
  ###########################################################################
  #Own bool indicates if the Trades displayed are the players own trades,in #
  #that case, display options to cancel or, if it's accepted, to receive the#
  #Pokemon traded for it                                                    #
  ###########################################################################
  def self.displaytrades(str, own = false)
    decompressed = str.unpack("m")[0]
    arr = decompressed.split("\r")
    tradearr = []
    if arr.length == 0
      Kernel.pbMessage("No Pokemon found.")
      return @Connect.tradeorbattle
    end

    for pokestr in arr
      obj = JSON.decode(pokestr)
      if obj != nil
        tradearr.push(obj)
      end
    end
    #TODO: visual representation of Pokemon in the GTS
    #trades are contained as anonymous objects in the tradearr
    #Pokemons, and requirements are stored in hashes, and can be accessed as such:
    #Request = obj["Request"], MinLevel = obj["Request"]["MinLevel"]
    #OfferedPokemon = obj["Offer"]
    #Offered Pokemon contains all public attributes of a PokeBattle_Pokemon,
    #with the exact same names
    #i.e. obj["Offer"]["species"]
    #lastly the object also contains a bool, obj["Accepted"]
    #this indicates whether the Pokemon has already been traded
    #If the own bool is false, display the option to offer a Pokemon, using
    #gts_offer function,
    #if it's true, display the option to either cancel or, if obj["Accepted"]
    #is true, to collect the trade.
    #lastly the object contains the trade index (obj["Index"]), which is used
    #to send messages to the server of the index of the trade (makes it possible
    #for the server to known what trade you are talking about)

    #ALSO TODO make sure that the uplaod does the requests too
    partyOfTrades = []
    @reqData = []

    for i in 0..tradearr.length - 1
      partyOfTrades.push(objecttobattler(tradearr[i]["Offer"]))
      @reqData.push(tradearr[i]["Request"])
    end
    $own = own
    #  arrrs=[]
    #  for i in 0..tradearr.length-1
    #    arrrs[i]=tradearr[i]["Offer"]
    #  end

    while 1 == 1
      pbChoosePokemon(1, 2, nil, false, partyOfTrades, tradearr)
      var = $game_variables[1]
      if var < 0
        break
      elsif var == 4
        find_trade(tradearr[0]["Index"] - 4)
      elsif var == 5
        find_trade(tradearr[3]["Index"] + 1)
      elsif own
        ary = ["(Cancel)"]
        if tradearr[var]["Accepted"]
          ary.push("Accept")
        end

        var2 = Kernel.pbMessage("This is your own. Select an option.", ary)
        if ary[var2] == "(Cancel)"
          gts_cancel(tradearr[var]["Index"])
          return
          #          find_trade(tradearr[0]["Index"])
          #        else
        end
      elsif tradearr[var]["Accepted"]
        Kernel.pbMessage("This trade has already been accepted.")
        find_trade(tradearr[0]["Index"])
      else
        pbChoosePokemon(1, 2, proc { |poke|
          !poke.egg? &&
          (poke.species == tradearr[var]["Request"]["Species"] || tradearr[var]["Request"]["Species"] == 0) &&
          poke.level >= tradearr[var]["Request"]["MinLevel"] &&
          (poke.gender == tradearr[var]["Request"]["Gender"] || tradearr[var]["Request"]["Gender"] == 2) &&
          (poke.nature == tradearr[var]["Request"]["Nature"] || tradearr[var]["Request"]["Nature"] == 25)
        })
        if pbGet(1) >= 0
          gts_offer($game_variables[1], tradearr[var]["Index"])
          break
        end
      end
    end

    #Kernel.pbMessage(tradearr.length.to_s)
    $own = nil
    return @Connect.tradeorbattle
  end

  ##################################################
  #Simple function to request own trades in the GTS#
  ##################################################
  def self.own_trades
    $network.send("<GTSMINE>")
  end

  ##################################################
  #Function to make an offer for a Pokemon         #
  ##################################################
  #Takes int for index of team position of offer,  #
  #and an int for the index of the trade           #
  ##################################################
  def self.gts_offer(teamindex, tradeindex)
    pokestring = [JSON.encode($Trainer.party[teamindex])].pack("m")
    $tempteamno = teamindex
    $network.send("<GTSOFFER|offer=#{pokestring}|id=#{tradeindex}>")
  end

  ##########################################################
  #Simple function to display result after making an offer #
  #pkmn contains string "nil", unless result is 3.         #
  ##########################################################
  def self.gts_offer_response(result, pkmn)
    if result == 0
      Kernel.pbMessage("You have been banned from the online server")
      return @Connect.tradeorbattle
    elsif result == 1
      Kernel.pbMessage("This trade has already been traded away")
      return @Connect.tradeorbattle
    elsif result == 2
      Kernel.pbMessage("Your offered Pokemon doesn't fill the requirements for this trade")
      return @Connect.tradeorbattle
    elsif result != 3
      return @Connect.tradeorbattle
    end
    #if we arrived here the trade is accepted, and the pkmn variable contains
    #the new Pokemon
    $Trainer[$tempteamno] = objecttobattler(JSON.decode(pkmn.unpack("m")[0]))
    Kernel.pbMessage("The trade was accepted!")
  end
  #####################################
  #Function to cancel a players trade #
  #####################################
  # index should be index of the trade#
  #####################################
  def self.gts_cancel(index)
    $network.send("<GTSCANCEL|id=#{index}>")
  end

  def self.gts_cancel_response(result, pkmn)
    if result == 0
      Kernel.pbMessage("You do not own that trade.")
      return @Connect.tradeorbattle
    elsif result == 1
      Kernel.pbMessage("That trade was already accepted.")
      return @Connect.tradeorbattle
    elsif result != 2
      return @Connect.tradeorbattle
    end

    #Trade has been cancelled, put the pokemon back in the team/PC
    #deserialize string pkmn to object, turn object into Battler
    battler = objecttobattler(JSON.decode(pkmn.unpack("m")[0]))
    pbAddPokemonSilent(battler)
    pbSave
    return @Connect.tradeorbattle
  end

  #####################################
  #Function to collect a players trade#
  #####################################
  # index should be index of the trade#
  #####################################
  def self.gts_collect(index)
    #    Kernel.pbMessage("Sending collect response...")
    $network.send("<GTSCOLLECT|id=#{index}>")
  end

  def self.gts_cancel(index)
    #    Kernel.pbMessage("Sending collect response...")
    $network.send("<GTSCANCEL|id=#{index}>")
  end

  def self.gts_collect_response(result, pkmn)
    #  Kernel.pbMessage("Hmm?")
    if result == 0
      Kernel.pbMessage("You do not own that trade")
      return @Connect.tradeorbattle
    elsif result == 1
      Kernel.pbMessage("That trade has not been accepted yet")
      return @Connect.tradeorbattle
    elsif result != 2
      return @Connect.tradeorbattle
    end

    #Trade has been completed, put new pokemon in Team/PC
    #deserialize string into object, turn object into Battler
    battler = objecttobattler(JSON.decode(pkmn.unpack("m")[0]))
    Kernel.pbMessage("Received the trade!")
    pbAddPokemonSilent(battler)
    pbSave
  end

  def self.objecttobattler(obj, withlevel = false)
    species = obj["species"].to_i
    exp = obj["exp"].to_i

    dexdata = pbOpenDexData
    pbDexDataOffset(dexdata, species, 20)
    growth = dexdata.fgetb
    dexdata.close
    if !withlevel
      level = PBExperience.pbGetLevelFromExperience(exp, growth)
    else
      level = obj["level"]
    end

    battler = PokeBattle_Pokemon.new(species, level)
    battler.ev = obj["ev"] if obj["ev"].is_a?(Array)
    battler.hp = obj["hp"].to_i
    battler.iv = obj["iv"] if obj["ev"].is_a?(Array)
    battler.ot = obj["ot"].to_s
    battler.exp = obj["exp"].to_i
    battler.setNature(obj["nature"].to_i)
    battler.item = obj["item"].to_i
    #battler.setAbility(obj["abilityflag"])
    battler.abilityflag = obj["abilityflag"].to_i
    if obj["genderflag"]==""
      battler.genderflag=nil
    else
      battler.genderflag = obj["genderflag"]
    end
    battler.mail = nil
    battler.name = obj["name"].to_s
    #battler.fused = nil
    begin
      battler.moves = []
      for i in 0..(obj["moves"].length - 1)
        m = PBMove.new(obj["moves"][i]["id"].to_i)
        m.pp = obj["moves"][i]["pp"].to_i
        m.ppup = obj["moves"][i]["ppup"].to_i
        battler.moves.push(m)
      end
    rescue
    end
    battler.personalID = obj["personalID"].to_i
    shinyHash = {"true" => true, true => true, "false" => false, false => false}
    battler.makeShiny if shinyHash[obj["isShiny"]]
    for key in obj.keys
      #Kernel.pbMessage(key)
    end
    battler.calcStats
    if obj["ribbons"].kind_of?(Array)
      begin
        battler.ribbons = []
        for i in obj["ribbons"] do
          if (i.is_a?(Integer))
            ribbon = getID(PBRibbons, i)
            battler.ribbons.push(ribbon)
          end
        end
      rescue
      end
    else 
      battler.ribbons = []
    end
    
    #battler.ribbons = obj["ribbons"]
    #if obj["ribbons"].is_a?(Integer)
    #  begin
    #    battler.ribbons = []
    #    for i in 0..(obj["ribbons"].length-1)
    #      ribbon=getID(PBRibbons,i) if !ribbon.is_a?(Integer)
    #      battler.ribbons.push(ribbon)
    #    end
    #    rescue
    #  end
    #else
    #  battler.ribbons=[0]
    #end
    
    battler.ballused = obj["ballused"]
    battler.eggsteps = obj["eggsteps"]
    battler.language = obj["language"]
    if obj["markings"] == ""
      battler.markings = 0
    else
      battler.markings = obj["markings"].to_i
    end
    #battler.markings = obj["abilityflag"]
    battler.otgender = obj["otgender"].to_i
    battler.happiness = obj["happiness"].to_i
    battler.obtainMap = obj["obtainMap"].to_i
    battler.trainerID = obj["trainerID"].to_i
    battler.hatchedMap = obj["hatchedMap"].to_i
    battler.obtainMode = obj["obtainMode"].to_i
    battler.obtainText = _INTL(obj["obtainText"].to_s)
    battler.itemInitial = obj["itemInitial"].to_i
    battler.itemRecycle = obj["itemRecycle"].to_i
    battler.obtainLevel = obj["obtainLevel"].to_i
    battler.statusCount = obj["statusCount"].to_i
    battler.ballcapsule0 = obj["ballcapsule0"]
    battler.ballcapsule1 = obj["ballcapsule1"]
    battler.ballcapsule2 = obj["ballcapsule2"]
    battler.ballcapsule3 = obj["ballcapsule3"]
    battler.ballcapsule4 = obj["ballcapsule4"]
    battler.ballcapsule5 = obj["ballcapsule5"]
    battler.ballcapsule6 = obj["ballcapsule6"]
    battler.ballcapsule7 = obj["ballcapsule7"]
    battler.timeReceived = obj["timeReceived"]
    battler.pokerus = obj["pokerus"].to_i
    battler.normalMewtwo = obj["normalMewtwo"]=='true'
    battler.shadowMewtwo = obj["shadowMewtwo"]=='true'
    battler.form = obj["form"].to_i
    battler.zygardeForm = obj["zygardeForm"].to_i
    #battler.eggmovesarray = obj["eggmovesarray"] 
    if obj["eggmovesarray"].is_a?(Array)
      begin
        battler.eggmovesarray = []
        for i in 0..(obj["eggmovesarray"].length - 1)
          m = PBMove.new(obj["eggmovesarray"][i]["id"].to_i)
          #m.pp = obj["eggmovesarray"][i]["pp"].to_i
          #m.ppup = obj["eggmovesarray"][i]["ppup"].to_i
          battler.eggmovesarray.push(m)
        end
      rescue
      end
    end
    battler.timeEggHatched = obj["timeEggHatched"].to_i
    #battler.fused = obj["fused"]
    #if obj["fused"]=="" || obj["fused"]==nil || obj["fused"]==false
    #  battler.fused=nil
    #elsif objecttobattler(JSON.decode(obj["fused"]))!=nil
    #  battler.fused = objecttobattler(JSON.decode(obj["fused"]))
    #else
    #  battler.fused=nil
    #end
    $Trainer.seen[species]=true
    $Trainer.owned[species]=true
    return battler
  end
end

class RequestFilter
  attr_accessor :MinLevel
  attr_accessor :Species
  attr_accessor :Gender
  attr_accessor :Nature

  @MinLevel = 0
  @Species = 0
  @Nature = 0
  @Gender = 0

  def initialize()
    @MinLevel = 0
    @Species = 0
    @Gender = 2
    @Nature = 25
  end
end