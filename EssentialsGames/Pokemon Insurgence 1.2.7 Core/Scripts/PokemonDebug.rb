class PokemonDataCopy
  attr_accessor :dataOldHash
  attr_accessor :dataNewHash
  attr_accessor :dataTime
  attr_accessor :data

  def crc32(x)
    return Zlib::crc32(x)
  end

  def readfile(filename)
    File.open(filename, "rb"){|f|
       f.read
    }
  end

  def writefile(str,filename)
    File.open(filename, "wb"){|f|
       f.write(str)
    }
  end

  def filetime(filename)
    File.open(filename, "r"){|f|
       f.mtime
    }
  end

  def initialize(data,datasave)
    @datafile=data
    @datasave=datasave
    @data=readfile(@datafile)
    @dataOldHash=crc32(@data)
    @dataTime=filetime(@datafile)
  end

  def changed?
    ts=readfile(@datafile)
    tsDate=filetime(@datafile)
    tsHash=crc32(ts)
    return tsHash!=@dataNewHash && tsHash!=@dataOldHash && tsDate > @dataTime
  end

  def save(newtilesets)
    newdata=Marshal.dump(newtilesets)
    if !changed?
      @data=newdata
      @dataNewHash=crc32(newdata)
      writefile(newdata,@datafile)
    else
      @dataOldHash=crc32(@data)
      @dataNewHash=crc32(newdata)
      @dataTime=filetime(@datafile)
      @data=newdata
      writefile(newdata,@datafile)
    end
    save_data(self,@datasave)
  end
end



class PokemonDataWrapper
  attr_reader :data

  def initialize(file,savefile,prompt)
    @savefile=savefile
    @file=file
    if pbRgssExists?(@savefile)
      @ts=load_data(@savefile)
      if !@ts.changed? || prompt.call==true
        @data=Marshal.load(StringInput.new(@ts.data))
      else
        @ts=PokemonDataCopy.new(@file,@savefile)
        @data=load_data(@file)
      end
    else
      @ts=PokemonDataCopy.new(@file,@savefile)
      @data=load_data(@file)
    end
  end

  def save
    @ts.save(@data)
  end
end



def pbMapTree
  mapinfos=pbLoadRxData("Data/MapInfos")
  maplevels=[]
  retarray=[]
  for i in mapinfos.keys
    info=mapinfos[i]
    level=-1
    while info
      info=mapinfos[info.parent_id]
      level+=1
    end
    if level>=0
      info=mapinfos[i]
      maplevels.push([i,level,info.parent_id,info.order])
    end
  end
  maplevels.sort!{|a,b|
     next a[1]<=>b[1] if a[1]!=b[1] # level
     next a[2]<=>b[2] if a[2]!=b[2] # parent ID
     next a[3]<=>b[3] # order
  }
  stack=[]
  stack.push(0,0)
  while stack.length>0
    parent = stack[stack.length-1]
    index = stack[stack.length-2]
    if index>=maplevels.length
      stack.pop
      stack.pop
      next
    end
    maplevel=maplevels[index]
    stack[stack.length-2]+=1
    if maplevel[2]!=parent
      stack.pop
      stack.pop
      next
    end
    retarray.push([maplevel[0],mapinfos[maplevel[0]].name,maplevel[1]])
    for i in index+1...maplevels.length
      if maplevels[i][2]==maplevel[0]
        stack.push(i)
        stack.push(maplevel[0])
        break
      end
    end
  end
  return retarray
end

def pbExtractText
  msgwindow=Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
  MessageTypes.extract("intl.txt")
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("All text in the game was extracted and saved to intl.txt.\1"))
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("To localize the text for a particular language, translate every second line in the file.\1"))
  Kernel.pbMessageDisplay(msgwindow,
     _INTL("After translating, choose \"Compile Text.\""))
  Kernel.pbDisposeMessageWindow(msgwindow)
end

def pbCompileTextUI
  msgwindow=Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
  begin
    pbCompileText
    Kernel.pbMessageDisplay(msgwindow,
       _INTL("Successfully compiled text and saved it to intl.dat."))
    Kernel.pbMessageDisplay(msgwindow,
       _INTL("To use the file in a game, place the file in the Data folder under a different name, and edit the LANGUAGES array in the Settings script."))
    rescue RuntimeError
    Kernel.pbMessageDisplay(msgwindow,
       _INTL("Failed to compile text:  {1}",$!.message))
  end
  Kernel.pbDisposeMessageWindow(msgwindow)
end



class CommandList
  def initialize
    @commandHash={}
    @commands=[]
  end

  def getCommand(index)
    for key in @commandHash.keys
      return key if @commandHash[key]==index
    end
    return nil
  end

  def add(key,value)
    @commandHash[key]=@commands.length
    @commands.push(value)
  end

  def list
    @commands.clone
  end
end



def pbDefaultMap()
  return $game_map.map_id if $game_map
  return $data_system.edit_map_id if $data_system
  return 0
end

def pbWarpToMap()
  mapid=pbListScreen(_INTL("WARP TO MAP"),MapLister.new(pbDefaultMap()))
  if mapid>0
    map=Game_Map.new
    map.setup(mapid)
    success=false
    x=0
    y=0
    100.times do
      x=rand(map.width)
      y=rand(map.height)
      next if !map.passableStrict?(x,y,$game_player)
      blocked=false
      for event in map.events.values
        if event.x == x && event.y == y && !event.through
          blocked=true if self != $game_player || event.character_name != ""
        end
      end
      next if blocked
      success=true
      break
    end
    if !success
      x=rand(map.width)
      y=rand(map.height)
    end
    return [mapid,x,y]
  end
  return nil
end

def pbDebugMenu

  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
  commands=CommandList.new
  commands.add("switches",_INTL("Switches"))
  commands.add("variables",_INTL("Variables"))
  commands.add("refreshmap",_INTL("Refresh Map"))
  commands.add("warp",_INTL("Warp to Map"))
  commands.add("healparty",_INTL("Heal Party"))
  commands.add("additem",_INTL("Add Item"))
  commands.add("fillbag",_INTL("Fill Bag"))
  commands.add("clearbag",_INTL("Empty Bag"))
  commands.add("addpokemon",_INTL("Add Pokémon"))
  commands.add("fillboxes",_INTL("Fill Storage Boxes"))
  commands.add("clearboxes",_INTL("Clear Storage Boxes"))
  commands.add("usepc",_INTL("Use PC"))
  commands.add("setplayer",_INTL("Set Player Character"))
  commands.add("renameplayer",_INTL("Rename Player"))
  commands.add("randomid",_INTL("Randomise Player's ID"))
  commands.add("setmoney",_INTL("Set Money"))
  commands.add("setcoins",_INTL("Set Coins"))
  commands.add("setbadges",_INTL("Set Badges"))
  commands.add("readyrematches",_INTL("Ready Phone Rematches"))
  commands.add("mysterygift",_INTL("Manage Mystery Gifts"))
  commands.add("daycarecheck",_INTL("Check Day Care"))
  commands.add("forceegg",_INTL("Force Day Care Egg"))
  commands.add("quickhatch",_INTL("Quick Hatch"))
  commands.add("roamerstatus",_INTL("Roaming Pokémon Status"))
  commands.add("roam",_INTL("Advance Roaming"))
  commands.add("setencounters",_INTL("Set Encounters")) 
  commands.add("setmetadata",_INTL("Set Metadata")) 
  commands.add("terraintags",_INTL("Set Terrain Tags"))
  commands.add("trainertypes",_INTL("Edit Trainer Types"))
  commands.add("resettrainers",_INTL("Reset Trainers"))
  commands.add("testwildbattle",_INTL("Test Wild Battle"))
  commands.add("testdoublewildbattle",_INTL("Test Double Wild Battle"))
  commands.add("testtrainerbattle",_INTL("Test Trainer Battle"))
  commands.add("testdoubletrainerbattle",_INTL("Test Double Trainer Battle"))
  commands.add("relicstone",_INTL("Relic Stone"))
  commands.add("purifychamber",_INTL("Purify Chamber"))
  commands.add("extracttext",_INTL("Extract Text"))
  commands.add("compiletext",_INTL("Compile Text"))
  commands.add("compiledata",_INTL("Compile Data"))
  commands.add("visualeditor",_INTL("Visual Editor"))
  commands.add("animeditor",_INTL("Animation Editor"))
  commands.add("debugconsole",_INTL("Debug Console"))
  sprites["cmdwindow"]=Window_CommandPokemonEx.new(commands.list)
  cmdwindow=sprites["cmdwindow"]
  cmdwindow.viewport=viewport
  cmdwindow.resizeToFit(cmdwindow.commands)
  cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.x=0
  cmdwindow.y=0
  cmdwindow.visible=true
  #$PokemonBag.pbStoreItem(PBItems::HACKERCALL)
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
      end
      if Input.trigger?(Input::C)
        ret=cmdwindow.index
        break
      end
    end
    break if ret==-1
    cmd=commands.getCommand(ret)
    if cmd=="switches"
      pbFadeOutIn(99999) { pbDebugScreen(0) }
    elsif cmd=="variables"
      pbFadeOutIn(99999) { pbDebugScreen(1) }
    elsif cmd=="refreshmap"
      $game_map.need_refresh = true
      Kernel.pbMessage(_INTL("The map will refresh."))
    elsif cmd=="warp"
      map=pbWarpToMap()
      if map
        pbFadeOutAndHide(sprites)
        pbDisposeSpriteHash(sprites)
        viewport.dispose
        if $scene.is_a?(Scene_Map)
          $game_temp.player_new_map_id=map[0]
          $game_temp.player_new_x=map[1]
          $game_temp.player_new_y=map[2]
          $game_temp.player_new_direction=2
          $scene.transfer_player
          $game_map.autoplay
          $game_map.refresh
        else
          Kernel.pbCancelVehicles
          $MapFactory.setup(map[0])
          $game_player.moveto(map[1],map[2])
          $game_player.turn_down
          $game_map.update
          $game_map.autoplay
          $game_map.refresh
        end
        return
      end
    elsif cmd=="healparty"
      for i in $Trainer.party
        i.heal
      end
      Kernel.pbMessage(_INTL("Your Pokémon were healed."))
    elsif cmd=="additem"
      item=pbListScreen(_INTL("ADD ITEM"),ItemLister.new(0))
      if item && item>0
        params=ChooseNumberParams.new
        params.setRange(1,99)
        params.setInitialValue(1)
        params.setCancelValue(0)
        qty=Kernel.pbMessageChooseNumber(
           _INTL("Choose the number of items."),params
        )
        if qty>0
          if qty==1
            Kernel.pbReceiveItem(item)
          else
            Kernel.pbMessage(_INTL("The item was added."))
            $PokemonBag.pbStoreItem(item,qty)
          end
        end
      end
    elsif cmd=="fillbag"
      params=ChooseNumberParams.new
      params.setRange(1,99)
      params.setInitialValue(1)
      params.setCancelValue(0)
      qty=Kernel.pbMessageChooseNumber(
         _INTL("Choose the number of items."),params
      )
      if qty>0
        itemconsts=[]
        for i in PBItems.constants
          itemconsts.push(PBItems.const_get(i))
        end
        itemconsts.sort!{|a,b| a<=>b}
        for i in itemconsts
          $PokemonBag.pbStoreItem(i,qty)
        end
        Kernel.pbMessage(_INTL("The Bag was filled with {1} of each item.",qty))
      end
    elsif cmd=="clearbag"
      $PokemonBag.clear
      Kernel.pbMessage(_INTL("The Bag was cleared."))
    elsif cmd=="addpokemon"
      species=pbChooseSpeciesOrdered(1)
      if species!=0
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level=Kernel.pbMessageChooseNumber(
           _INTL("Set the Pokémon's level."),params)
        if level>0
          pbAddPokemon(species,level)
        end
      end
    elsif cmd=="fillboxes"
      $Trainer.formseen=[] if !$Trainer.formseen
      $Trainer.formlastseen=[] if !$Trainer.formlastseen
      for i in 1..PBSpecies.maxValue
        pkmn=PokeBattle_Pokemon.new(i,50,$Trainer)
        $PokemonStorage[(i-1)/$PokemonStorage.maxPokemon(0),
                        (i-1)%$PokemonStorage.maxPokemon(0)]=pkmn
        $Trainer.seen[i]=true
        $Trainer.owned[i]=true
        $Trainer.formlastseen[i]=[] if !$Trainer.formlastseen[i]
        $Trainer.formlastseen[i]=[0,0] if $Trainer.formlastseen[i]==[]
        if !$Trainer.formseen[i]
          $Trainer.formseen[i]=[[],[]]
        end
        for j in 0..27
          $Trainer.formseen[i][0][j]=true
          $Trainer.formseen[i][1][j]=true
        end
      end
      Kernel.pbMessage(_INTL("Boxes were filled with one Pokémon of each species."))
    elsif cmd=="clearboxes"
      for i in 0...$PokemonStorage.maxBoxes
        for j in 0...$PokemonStorage.maxPokemon(i)
          $PokemonStorage[i,j]=nil
        end
      end
      Kernel.pbMessage(_INTL("The Boxes were cleared."))
    elsif cmd=="usepc"
      pbPokeCenterPC
    elsif cmd=="setplayer"
      limit=0
      for i in 0...8
        meta=pbGetMetadata(0,MetadataPlayerA+i)
        if !meta
          limit=i
          break
        end
      end
      if limit<=1
        Kernel.pbMessage(_INTL("There is only one player defined."))
      else
        params=ChooseNumberParams.new
        params.setRange(0,limit-1)
        params.setDefaultValue($PokemonGlobal.playerID)
        newid=Kernel.pbMessageChooseNumber(
           _INTL("Choose the new player character."),params)
        if newid!=$PokemonGlobal.playerID
          pbChangePlayer(newid)
          Kernel.pbMessage(_INTL("The player character was changed."))
        end
      end
    elsif cmd=="renameplayer"
      $Trainer.name="Elise"
      trname=pbEnterText("Your name?",0,7,$Trainer.name)
      if trname==""
        trainertype=pbGetPlayerTrainerType
        gender=pbGetTrainerTypeGender(trainertype) 
        trname=pbSuggestTrainerName(gender)
      end
      $Trainer.name=trname
      Kernel.pbMessage(_INTL("The player's name was changed to {1}.",$Trainer.name))
    elsif cmd=="randomid"
      $Trainer.id=rand(256)
      $Trainer.id|=rand(256)<<8
      $Trainer.id|=rand(256)<<16
      $Trainer.id|=rand(256)<<24
      Kernel.pbMessage(_INTL("The player's ID was changed to {1} (2).",$Trainer.publicID,$Trainer.id))
    elsif cmd=="setmoney"
      params=ChooseNumberParams.new
      params.setMaxDigits(6)
      params.setDefaultValue($Trainer.money)
      $Trainer.money=Kernel.pbMessageChooseNumber(
         _INTL("Set the player's money."),params)
      Kernel.pbMessage(_INTL("You now have ${1}.",$Trainer.money))
    elsif cmd=="setcoins"
      params=ChooseNumberParams.new
      params.setRange(0,MAXCOINS)
      params.setDefaultValue($PokemonGlobal.coins)
      $PokemonGlobal.coins=Kernel.pbMessageChooseNumber(
         _INTL("Set the player's Coin amount."),params)
      Kernel.pbMessage(_INTL("You now have {1} Coins.",$PokemonGlobal.coins))
    elsif cmd=="setbadges"
      badgecmd=0
      loop do
        badgecmds=[]
        for i in 0...32
          badgecmds.push(_INTL("{1} Badge {2}",$Trainer.badges[i] ? _INTL("[Y]") : _INTL("[  ]"),i+1))
        end
        badgecmd=Kernel.pbShowCommands(nil,badgecmds,-1,badgecmd)
        break if badgecmd<0
        $Trainer.badges[badgecmd]=!$Trainer.badges[badgecmd]
      end
    elsif cmd=="readyrematches"
      if !$PokemonGlobal.phoneNumbers || $PokemonGlobal.phoneNumbers.length==0
        Kernel.pbMessage(_INTL("There are no trainers in the Phone."))
      else
        for i in $PokemonGlobal.phoneNumbers
          if i.length==8 # A trainer with an event
            i[4]=2
          end
        end
        Kernel.pbMessage(_INTL("All trainers in the Phone are now ready to rebattle."))
      end
    elsif cmd=="mysterygift"
      pbManageMysteryGifts
    elsif cmd=="daycarecheck"
      if $PokemonGlobal.daycare
        num=pbDayCareDeposited
        Kernel.pbMessage(_INTL("{1} Pokémon are in the Day Care.",num))
        if num>0
          for i in 0...num
            pkmn=$PokemonGlobal.daycare[i][0]
            initlevel=$PokemonGlobal.daycare[i][1]
            gender=[_INTL("♂"),_INTL("♀"),_INTL("genderless")][pkmn.gender]
            break if !pkmn
            Kernel.pbMessage(_INTL("{1} ({2}), level {3} (deposited at level {4})",
               pkmn.name,gender,pkmn.level,initlevel))
          end
        end
        if $PokemonGlobal.daycareEgg==1
          Kernel.pbMessage(_INTL("An egg is waiting to be picked up."))
        elsif pbDayCareDeposited==2
          if pbDayCareGetCompat==0
            Kernel.pbMessage(_INTL("The deposited Pokémon can't breed."))
          else
            Kernel.pbMessage(_INTL("The deposited Pokémon can breed."))
          end
        end
      end
    elsif cmd=="forceegg"
      if $PokemonGlobal.daycare
        if pbDayCareDeposited!=2
          Kernel.pbMessage(_INTL("There aren't 2 Pokémon in the Day Care."))
        elsif $PokemonGlobal.daycareEgg==1
          Kernel.pbMessage(_INTL("An egg is already waiting."))
        elsif pbDayCareGetCompat==0
          Kernel.pbMessage(_INTL("The deposited Pokémon can't breed."))
        else
          $PokemonGlobal.daycareEgg=1
          Kernel.pbMessage(_INTL("An egg is now waiting in the Day Care."))
        end
      end
    elsif cmd=="quickhatch"
      for pokemon in $Trainer.party
        pokemon.eggsteps=1 if pokemon.egg?
      end
      Kernel.pbMessage(_INTL("All eggs on your party now require one step to hatch."))
    elsif cmd=="roamerstatus"
      if RoamingSpecies.length==0
        Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
      else
        for i in 0...RoamingSpecies.length
          poke=RoamingSpecies[i]
          if $game_switches[poke[2]]
            status=$PokemonGlobal.roamPokemon[i]
            if status==true
              if $PokemonGlobal.roamPokemonCaught[i]
                statustext=_INTL("caught")
              else
                statustext=_INTL("defeated")
              end
            else
              curmap=$PokemonGlobal.roamPosition[i]
              if curmap
                mapinfos=$RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
                statustext=_INTL("roaming on map {1} ({2})",curmap,mapinfos[curmap].name)
                statustext+=_INTL(" (this map)") if curmap==$game_map.map_id
              else
                statustext=_INTL("roaming (map not set)")
              end
            end
          else
            statustext=_INTL("not roaming (switch {1} is off)",poke[2])
          end
          text=_INTL("{1} lv.{2}, {3}.",
             PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1],statustext)
          Kernel.pbMessage(text)
        end
      end
    elsif cmd=="roam"
      if RoamingSpecies.length==0
        Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
      else
        pbRoamPokemon(true)
        Kernel.pbMessage(_INTL("Pokémon have roamed."))
      end
    elsif cmd=="setencounters"
      encdata=load_data("Data/encounters.dat")
      oldencdata=Marshal.dump(encdata)
      mapedited=false
      map=pbDefaultMap()
      loop do
        map=pbListScreen(_INTL("SET ENCOUNTERS"),MapLister.new(map))
        break if map<=0
        mapedited=true if map==pbDefaultMap()
        pbEncounterEditorMap(encdata,map)
      end
      save_data(encdata,"Data/encounters.dat")
      pbSaveEncounterData()
      pbClearData()
    elsif cmd=="setmetadata"
      pbMetadataScreen(pbDefaultMap())
      pbClearData()
    elsif cmd=="terraintags"
      pbFadeOutIn(99999) { pbTilesetScreen }
    elsif cmd=="trainertypes"
      pbFadeOutIn(99999) { pbTrainerTypeEditor }
    elsif cmd=="resettrainers"
      if $game_map
        for event in $game_map.events.values
          if event.name[/Trainer\(\d+\)/]
            $game_self_switches[[$game_map.map_id,event.id,"A"]]=false
            $game_self_switches[[$game_map.map_id,event.id,"B"]]=false
          end
        end
        $game_map.need_refresh=true
        Kernel.pbMessage(_INTL("All Trainers on this map were reset."))
      else
        Kernel.pbMessage(_INTL("This command can't be used here."))
      end
    elsif cmd=="testwildbattle"
      species=pbChooseSpeciesOrdered(1)
      if species!=0
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level=Kernel.pbMessageChooseNumber(
           _INTL("Set the Pokémon's level."),params)
        if level>0
          pbWildBattle(species,level)
        end
      end
    elsif cmd=="testdoublewildbattle"
      Kernel.pbMessage(_INTL("Choose the first Pokémon."))
      species1=pbChooseSpeciesOrdered(1)
      if species1!=0
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level1=Kernel.pbMessageChooseNumber(
           _INTL("Set the first Pokémon's level."),params)
        if level1>0
          Kernel.pbMessage(_INTL("Choose the second Pokémon."))
          species2=pbChooseSpeciesOrdered(1)
          if species2!=0
            params=ChooseNumberParams.new
            params.setRange(1,PBExperience::MAXLEVEL)
            params.setInitialValue(5)
            params.setCancelValue(0)
            level2=Kernel.pbMessageChooseNumber(
               _INTL("Set the second Pokémon's level."),params)
            if level2>0
              pbDoubleWildBattle(species1,level1,species2,level2)
            end
          end
        end
      end
    elsif cmd=="testtrainerbattle"
      battle=pbListScreen(_INTL("SINGLE TRAINER"),TrainerBattleLister.new(0,false))
      if battle
        trainerdata=battle[1]
        pbTrainerBattle(trainerdata[0],trainerdata[1],"...",false,trainerdata[4],true)
      end
    elsif cmd=="testdoubletrainerbattle"
      battle1=pbListScreen(_INTL("DOUBLE TRAINER 1"),TrainerBattleLister.new(0,false))
      if battle1
        battle2=pbListScreen(_INTL("DOUBLE TRAINER 2"),TrainerBattleLister.new(0,false))
        if battle2
          trainerdata1=battle1[1]
          trainerdata2=battle2[1]
          pbDoubleTrainerBattle(trainerdata1[0],trainerdata1[1],trainerdata1[4],"...",
                                trainerdata2[0],trainerdata2[1],trainerdata2[4],"...",
                                true)
        end
      end
    elsif cmd=="relicstone"
      pbRelicStone()
    elsif cmd=="purifychamber"
      pbPurifyChamber()
    elsif cmd=="extracttext"
      pbExtractText
    elsif cmd=="compiletext"
      pbCompileTextUI
    elsif cmd=="compiledata"
      msgwindow=Kernel.pbCreateMessageWindow
      pbCompileAllData(true) {|msg| Kernel.pbMessageDisplay(msgwindow,msg,false) }
      Kernel.pbMessageDisplay(msgwindow,_INTL("All game data was compiled."))
      Kernel.pbDisposeMessageWindow(msgwindow)
    elsif cmd=="visualeditor"
      pbFadeOutIn(99999) { pbEditorScreen }
    elsif cmd=="animeditor"
      pbFadeOutIn(99999) { pbAnimationEditor }
    elsif cmd=="debugconsole"
      Console::setup_console
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end



class SpriteWindow_DebugRight < Window_DrawableCommand
  attr_reader :mode

  def initialize
    super(0, 0, Graphics.width, Graphics.height)
  end

  def shadowtext(x,y,w,h,t,align=0)
    width=self.contents.text_size(t).width
    if align==2
      x+=(w-width)
    elsif align==1
      x+=(w/2)-(width/2)
    end
    pbDrawShadowText(self.contents,x,y,[width,w].max,h,t,
       Color.new(12*8,12*8,12*8),Color.new(26*8,26*8,25*8))
  end

  def drawItem(index,count,rect)
    pbSetNarrowFont(self.contents)
    if @mode == 0
      name = $data_system.switches[index+1]
      status = $game_switches[index+1] ? "[ON]" : "[OFF]"
    else
      name = $data_system.variables[index+1]
      status = $game_variables[index+1].to_s
    end
    if name == nil
      name = ''
    end
    id_text = sprintf("%04d:", index+1)
    width = self.contents.text_size(id_text).width
    rect=drawCursor(index,rect)
    totalWidth=rect.width
    idWidth=totalWidth*15/100
    nameWidth=totalWidth*65/100
    statusWidth=totalWidth*20/100
    self.shadowtext(rect.x, rect.y, idWidth, rect.height, id_text)
    self.shadowtext(rect.x+idWidth, rect.y, nameWidth, rect.height, name)
    self.shadowtext(rect.x+idWidth+nameWidth, rect.y, statusWidth, rect.height, status, 2)
  end

  def itemCount
    return (@mode==0) ? $data_system.switches.size-1 : $data_system.variables.size-1
  end

  def mode=(mode)
    @mode = mode
    refresh
  end
end



def pbDebugSetVariable(id,diff)
  pbPlayCursorSE()
  $game_variables[id]=0 if $game_variables[id]==nil
  if $game_variables[id].is_a?(Numeric)
    $game_variables[id]=[$game_variables[id]+diff,99999999].min
    $game_variables[id]=[$game_variables[id],-99999999].max
  end
end

def pbDebugVariableScreen(id)
  value=0
  if $game_variables[id].is_a?(Numeric)
    value=$game_variables[id]
  end
  params=ChooseNumberParams.new
  params.setDefaultValue(value)
  params.setMaxDigits(8)
  params.setNegativesAllowed(true)
  value=Kernel.pbMessageChooseNumber(_INTL("Set variable {1}.",id),params)
  $game_variables[id]=[value,99999999].min
  $game_variables[id]=[$game_variables[id],-99999999].max
end

def pbDebugScreen(mode)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites={}
  sprites["right_window"] = SpriteWindow_DebugRight.new  
  right_window=sprites["right_window"]
  right_window.mode=mode
  right_window.viewport=viewport
  right_window.active=true
  right_window.index=0
  pbFadeInAndShow(sprites)
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      break
    end
    current_id = right_window.index+1
    if mode == 0
      if Input.trigger?(Input::C)
        pbPlayDecisionSE()
        $game_switches[current_id] = (not $game_switches[current_id])
        right_window.refresh
      end
    elsif mode == 1
      if Input.repeat?(Input::RIGHT)
        pbDebugSetVariable(current_id,1)
        right_window.refresh
      elsif Input.repeat?(Input::LEFT)
        pbDebugSetVariable(current_id,-1)
        right_window.refresh
      elsif Input.trigger?(Input::C)
        pbDebugVariableScreen(current_id)
        right_window.refresh
      end
    end
  end
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end



class Scene_Debug
  def main
    Graphics.transition(15)
    pbDebugMenu
    $scene=Scene_Map.new
    $game_map.refresh
    Graphics.freeze
  end
end