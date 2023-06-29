################################################################################
# "Triple Triad" mini-game
# By Unknown
################################################################################
class PokemonGlobalMetadata
  attr_accessor :ids

  def ids
    @ids=IDStorage.new if !@ids
    return @triads
  end
end



class IDStorage
  def maxSize
    return PBSpecies.getCount
  end

  def maxPerSlot
    return 99
  end

  def initialize
    @items=[]
  end

  def empty?
    return @items.length==0
  end

  def length
    @items.length
  end

  def [](i)
    @items[i]
  end

  def getItem(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][0]
    end
  end

  def getCount(index)
    if index<0 || index>=@items.length
      return 0
    else
      return @items[index][1]
    end
  end

  def pbQuantity(item)
    return ItemStorageHelper.pbQuantity(@items,self.maxSize,item)
  end

  def pbDeleteItem(item,qty=1)
    return ItemStorageHelper.pbDeleteItem(@items,self.maxSize,item,qty)
  end

  def pbCanStore?(item,qty=1)
    return ItemStorageHelper.pbCanStore?(@items,self.maxSize,self.maxPerSlot,item,qty)
  end

  def pbStoreItem(item,qty=1)
    return ItemStorageHelper.pbStoreItem(@items,self.maxSize,self.maxPerSlot,item,qty)
  end
end

def createIDs
  
    $game_variables[51]= Array.new
      for j in 1..121
          $game_variables[51][j]=Array.new

    $game_variables[51][j][2]= false
  end
  
    $game_variables[51][1][0]="Jeremy"
    $game_variables[51][1][1]= PBTrainers::HIKER
    $game_variables[51][1][3]=5000
    $game_variables[51][1][4]=true
    
    $game_variables[51][2][0]="Xephos"
    $game_variables[51][2][1]= PBTrainers::YOGSCAST_Lewis
    $game_variables[51][2][3]=0
    $game_variables[51][2][4]=true

    $game_variables[51][3][0]="Honeydew"
    $game_variables[51][3][1]= PBTrainers::YOGSCAST_Simon
    $game_variables[51][3][3]=0
    $game_variables[51][3][4]=true

    $game_variables[51][4][0]="LividCoffee"
    $game_variables[51][4][1]= PBTrainers::YOGSCAST_Duncan
    $game_variables[51][4][3]=0
    $game_variables[51][4][4]=true

    $game_variables[51][5][0]="Sjin"
    $game_variables[51][5][1]= PBTrainers::YOGSCAST_Sjin
    $game_variables[51][5][3]=0
    $game_variables[51][5][4]=false

    $game_variables[51][6][0]="Sips"
    $game_variables[51][6][1]=PBTrainers::YOGSCAST_Sips
    $game_variables[51][6][3]=0
    $game_variables[51][6][4]=false
    
    $game_variables[51][7][0]="Martyn"
    $game_variables[51][7][1]= PBTrainers::YOGSCAST_Martyn
    $game_variables[51][7][3]=0
    $game_variables[51][7][4]=false
        $game_variables[51][7][2]=true

    $game_variables[51][8][0]="Zoeya"
    $game_variables[51][8][1]= PBTrainers::YOGSCAST_Zoey
    $game_variables[51][8][3]=0
    $game_variables[51][8][4]=false
    
    $game_variables[51][9][0]="Lomadia"
    $game_variables[51][9][1]= PBTrainers::YOGSCAST_Hannah
    $game_variables[51][9][3]=0
    $game_variables[51][9][4]=true
    
    $game_variables[51][10][0]="Rythian"
    $game_variables[51][10][1]= PBTrainers::YOGSCAST_Rythian
    $game_variables[51][10][3]=0
    $game_variables[51][10][4]=false
    
    $game_variables[51][11][0]="Teep"
    $game_variables[51][11][1]= PBTrainers::YOGSCAST_Teep
    $game_variables[51][11][3]=0
    $game_variables[51][11][4]=false
    
    $game_variables[51][12][0]="Kim"
    $game_variables[51][12][1]= PBTrainers::YOGSCAST_Kim
    $game_variables[51][12][3]=0
    $game_variables[51][12][4]=true
    
        $game_variables[51][13][0]="Sammy"
    $game_variables[51][13][1]= PBTrainers::COOLTRAINER_M
    $game_variables[51][13][3]=0
    $game_variables[51][13][4]=true
  
    integer = 14
    
    $game_variables[51][integer][0]="Joey"
    $game_variables[51][integer][1]= PBTrainers::YOUNGSTER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Halo"
    $game_variables[51][integer][1]= PBTrainers::POKEMANIAC
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="AntiSpud"
    $game_variables[51][integer][1]= PBTrainers::COOLTRAINER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Lyra"
    $game_variables[51][integer][1]= PBTrainers::AROMALADY
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Taylor"
    $game_variables[51][integer][1]= PBTrainers::BLACKBELT
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Tristen"
    $game_variables[51][integer][1]= PBTrainers::NINJA
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Joel"
    $game_variables[51][integer][1]= PBTrainers::YOUNGSTER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Solid"
    $game_variables[51][integer][1]= PBTrainers::HIKER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Cyneryk"
    $game_variables[51][integer][1]= PBTrainers::GENTLEMAN
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Swirl"
    $game_variables[51][integer][1]= PBTrainers::SCIENTIST
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Teo"
    $game_variables[51][integer][1]= PBTrainers::COOLTRAINER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Jeaux"
    $game_variables[51][integer][1]= PBTrainers::POKEMONRANGER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Captain Canuck"
    $game_variables[51][integer][1]= PBTrainers::HIKER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Old MacDonald"
    $game_variables[51][integer][1]= PBTrainers::GENTLEMAN
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Sandy"
    $game_variables[51][integer][1]= PBTrainers::RUINMANIAC
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Wisdom"
    $game_variables[51][integer][1]= PBTrainers::PSYCHIC_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Telid"
    $game_variables[51][integer][1]= PBTrainers::POKEMANIAC
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Jonah"
    $game_variables[51][integer][1]= PBTrainers::FISHERMAN
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Beauly"
    $game_variables[51][integer][1]= PBTrainers::BLACKBELT
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Jordan"
    $game_variables[51][integer][1]= PBTrainers::JUGGLER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Moe Toor"
    $game_variables[51][integer][1]= PBTrainers::ENGINEER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Mika"
    $game_variables[51][integer][1]= PBTrainers::PSYCHIC_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Handrew"
    $game_variables[51][integer][1]= PBTrainers::POKEMONRANGER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Tesla"
    $game_variables[51][integer][1]= PBTrainers::SCIENTIST
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Stork"
    $game_variables[51][integer][1]= PBTrainers::BIRDKEEPER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Ira Nee"
    $game_variables[51][integer][1]= PBTrainers::AROMALADY
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Friendless"
    $game_variables[51][integer][1]= PBTrainers::CAMPER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Rosh"
    $game_variables[51][integer][1]= PBTrainers::JUGGLER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Millikan"
    $game_variables[51][integer][1]= PBTrainers::SWIMMER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Grasseh"
    $game_variables[51][integer][1]= PBTrainers::POKEMONRANGER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Mike Bay"
    $game_variables[51][integer][1]= PBTrainers::GAMBLER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Mandarin"
    $game_variables[51][integer][1]= PBTrainers::NINJA
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Teno"
    $game_variables[51][integer][1]= PBTrainers::SUPERNERD
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Gary McDirvish"
    $game_variables[51][integer][1]= PBTrainers::BUGCATCHER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Bruce"
    $game_variables[51][integer][1]= PBTrainers::NINJA
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Ali"
    $game_variables[51][integer][1]= PBTrainers::BLACKBELT
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Nikolaj"
    $game_variables[51][integer][1]= PBTrainers::SAILOR
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Eli"
    $game_variables[51][integer][1]= PBTrainers::NINJA
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Supermodel Box"
    $game_variables[51][integer][1]= PBTrainers::COOLTRAINER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Talia"
    $game_variables[51][integer][1]= PBTrainers::COOLTRAINER_F
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Isaac"
    $game_variables[51][integer][1]= PBTrainers::CUEBALL
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Knegoff"
    $game_variables[51][integer][1]= PBTrainers::RUINMANIAC
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Seclea"
    $game_variables[51][integer][1]= PBTrainers::LADY
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Hiro"
    $game_variables[51][integer][1]= PBTrainers::BURGLAR
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Danzee"
    $game_variables[51][integer][1]= PBTrainers::POKEMONRANGER_F
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Corbin"
    $game_variables[51][integer][1]= PBTrainers::BURGLAR
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Shadowmirror"
    $game_variables[51][integer][1]= PBTrainers::YOUNGSTER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Jake"
    $game_variables[51][integer][1]= PBTrainers::PSYCHIC_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Andrew"
    $game_variables[51][integer][1]= PBTrainers::PSYCHIC_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Jack-Wilf"
    $game_variables[51][integer][1]= PBTrainers::SCIENTIST
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="MC Paint"
    $game_variables[51][integer][1]= PBTrainers::PAINTER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Toomas"
    $game_variables[51][integer][1]= PBTrainers::YOUNGSTER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Poseidon"
    $game_variables[51][integer][1]= PBTrainers::TUBER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Nathan"
    $game_variables[51][integer][1]= PBTrainers::SCIENTIST
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="LordNick"
    $game_variables[51][integer][1]= PBTrainers::POKEMONBREEDER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Jodjuya"
    $game_variables[51][integer][1]= PBTrainers::SUPERNERD
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Alex"
    $game_variables[51][integer][1]= PBTrainers::GENTLEMAN
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Geiom"
    $game_variables[51][integer][1]= PBTrainers::RUINMANIAC
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
  
    $game_variables[51][72][0]="Guillaume"
    $game_variables[51][72][1]= PBTrainers::PAINTER
    $game_variables[51][72][3]=0
    $game_variables[51][72][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Miles"
    $game_variables[51][integer][1]= PBTrainers::GENTLEMAN
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Jakonater"
    $game_variables[51][integer][1]= PBTrainers::COOLTRAINER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Weevil Underwood"
    $game_variables[51][integer][1]= PBTrainers::BUGCATCHER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Yousef"
    $game_variables[51][integer][1]= PBTrainers::COOLTRAINER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Swagger McFee"
    $game_variables[51][integer][1]= PBTrainers::COOLTRAINER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Shadow"
    $game_variables[51][integer][1]= PBTrainers::PSYCHIC_F
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Roger"
    $game_variables[51][integer][1]= PBTrainers::PSYCHIC_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="TheAlphaGamer"
    $game_variables[51][integer][1]= PBTrainers::COOLTRAINER_M
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1
    
    $game_variables[51][integer][0]="Jyro"
    $game_variables[51][integer][1]= PBTrainers::SUPERNERD
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    
        $game_variables[51][integer][0]="Braid"
    $game_variables[51][integer][1]= PBTrainers::FREELANCER
    $game_variables[51][integer][3]=0
    $game_variables[51][integer][4]=true
    integer = integer + 1

    for j in 1..121
  $game_variables[51][j][3]= (rand(10) + 1) * 1000
      end
  $game_switches[167]=true
end

def pbBuyIDs
  if !$game_switches[167]
     createIDs
  end

  commands=[]
  realcommands=[]
  for i in 1..121
    # name = 0, type = 1, bought = 2, price = 3, hasvalue = 4
    #$game_variables[51][0][name]
    #$game_variables[51][0][type]
    #$game_variables[51][0][bought]
    #$game_variables[51][0][price]
    #$game_variables[51][0][hasvalue]
 #   $game_variables[51]= Array.new
 #   $game_variables[51][i]=Array.new
 #   $game_variables[51][i][0]="Jeremy"
 #   $game_variables[51][i][1]= PBTrainers::HIKER
 #   $game_variables[51][i][2]= false
 #   $game_variables[51][i][3]=5000
 #   $game_variables[51][i][4]=false
 
 
    if !$game_variables[51][i].is_a?(Array) || $game_variables[51][i] == nil
      $game_variables[51][i] = Array.new
              $game_variables[51][i][0]="Braid"
    $game_variables[51][i][1]= PBTrainers::FREELANCER
    $game_variables[51][i][2]=false
    $game_variables[51][i][3]=10000
    $game_variables[51][i][4]=true
  end
  
    if !$game_variables[51][i][2] && $game_variables[51][i][4]
          price=$game_variables[51][i][3]
      commands.push([price,$game_variables[51][i][0],_INTL("{1} {2} ${3}",PBTrainers.getName($game_variables[51][i][1]),$game_variables[51][i][0],price),i])
    end
    
      end
  if commands.length==0
    Kernel.pbMessage(_INTL("You have purchased every avaliable Trainer ID!")) 
    return
  end
  
  #commands.sort!{|a,b| 
  #   if a[0]==b[0]
  #     a[1]<=>b[1] # sort by name
  #   else
  #     a[0]<=>b[0] # sort by price
  #   end
#  }
  for command in commands
    realcommands.push(command[2])
  end
  # Scroll right before showing screen
  pbScrollMap(4,3,5)
  cmdwindow=Window_CommandPokemonEx.newWithSize(realcommands,0,0,256,Graphics.height)
  cmdwindow.z=99999
  moneyString=_INTL("${1}",$Trainer.money)
  goldwindow=Window_UnformattedTextPokemon.newWithSize(
     _INTL("Money:\n{1}",moneyString),0,0,32,32)
  goldwindow.resizeToFit(goldwindow.text,Graphics.width)
  goldwindow.y=0
  goldwindow.x=Graphics.width-goldwindow.width
  goldwindow.z=99999
  Graphics.frame_reset
  done=false
  while !done
    loop do
      Graphics.update
      Input.update
      cmdwindow.active=true
      cmdwindow.update
      goldwindow.update
      if Input.trigger?(Input::B)
        done=true
        break
      end
      if Input.trigger?(Input::C)
        price=commands[cmdwindow.index][0]
        item=commands[cmdwindow.index][3]
        itemname=commands[cmdwindow.index][1]
        cmdwindow.active=false
        cmdwindow.update
        if $Trainer.money<price
          Kernel.pbMessage(_INTL("You don't have enough money."))
          break
        end
        maxafford=(price<=0) ? 99 : $Trainer.money/price
        maxafford=99 if maxafford>99
        params=ChooseNumberParams.new
        params.setRange(1,maxafford)
        params.setInitialValue(1)
        params.setCancelValue(0)
        quantity=1
  #      quantity=Kernel.pbMessageChooseNumber(
  #         _INTL("",itemname),params)
        if quantity>0
          price*=quantity
          if !Kernel.pbConfirmMessage(_INTL("The {1} ID? Certainly. That will be ${2}. OK?",itemname,price))
            break
          end
          if $Trainer.money<price
            Kernel.pbMessage(_INTL("You don't have enough money."))
            break
          end
          poop = 4
          if poop == 5
            Kernel.pbMessage(_INTL("You have no room for more cards."))
          else
            $game_variables[51][item][2]=true
            $Trainer.money-=price
            moneyString=_INTL("${1}",$Trainer.money)
            goldwindow.text=_INTL("Money:\n{1}",moneyString)
            Kernel.pbMessage(_INTL("Here you are!\r\nThank you!"))
                          cmdwindow.dispose
            done = true
            break

          end
        end
      end
    end
  end
  cmdwindow.dispose
  goldwindow.dispose
  Graphics.frame_reset
  # Scroll right before showing screen
  pbScrollMap(6,3,5)
end

def pbBattleIDs

  commands=[]
  realcommands=[]
  for i in 1..81
    # name = 0, type = 1, bought = 2, price = 3, hasvalue = 4
    #$game_variables[51][0][name]
    #$game_variables[51][0][type]
    #$game_variables[51][0][bought]
    #$game_variables[51][0][price]
    #$game_variables[51][0][hasvalue]
 #   $game_variables[51]= Array.new
 #   $game_variables[51][i]=Array.new
 #   $game_variables[51][i][0]="Jeremy"
 #   $game_variables[51][i][1]= PBTrainers::HIKER
 #   $game_variables[51][i][2]= false
 #   $game_variables[51][i][3]=5000
 #   $game_variables[51][i][4]=false
    
    if $game_variables[51][i][2] || $DEBUG
      price=$game_variables[51][i][3]
      commands.push([price,$game_variables[51][i][0],_INTL("{1} {2}",PBTrainers.getName($game_variables[51][i][1]),$game_variables[51][i][0],price),i])
    end
    
    end
  if commands.length==0
    Kernel.pbMessage(_INTL("You have not purchased any Trainer IDs!")) 
    return
  end
  
  #commands.sort!{|a,b| 
  #   if a[0]==b[0]
  #     a[1]<=>b[1] # sort by name
  #   else
  #     a[0]<=>b[0] # sort by price
  #   end
#  }
  for command in commands
    realcommands.push(command[2])
  end
  # Scroll right before showing screen
  pbScrollMap(4,3,5)
  cmdwindow=Window_CommandPokemonEx.newWithSize(realcommands,0,0,256,Graphics.height)
  cmdwindow.z=99999
  moneyString=_INTL("${1}",$Trainer.money)
  goldwindow=Window_UnformattedTextPokemon.newWithSize(
     _INTL("Money:\n{1}",moneyString),0,0,32,32)
  goldwindow.resizeToFit(goldwindow.text,Graphics.width)
  goldwindow.y=0
  goldwindow.x=Graphics.width-goldwindow.width
  goldwindow.z=99999
  Graphics.frame_reset
  done=false
  while !done
    loop do
      Graphics.update
      Input.update
      cmdwindow.active=true
      cmdwindow.update
      goldwindow.update
      if Input.trigger?(Input::B)
        done=true
        break
      end
      if Input.trigger?(Input::C)
        price=commands[cmdwindow.index][0]
        item=commands[cmdwindow.index][3]
        itemname=commands[cmdwindow.index][1]
        cmdwindow.active=false
        cmdwindow.update
#        maxafford=(price<=0) ? 99 : $Trainer.money/price
#        maxafford=99 if maxafford>99
#        params=ChooseNumberParams.new
#        params.setRange(1,maxafford)
 #       params.setInitialValue(1)
 #       params.setCancelValue(0)
        quantity=1
  #      quantity=Kernel.pbMessageChooseNumber(
  #         _INTL("",itemname),params)
        if quantity>0
         # if !Kernel.pbConfirmMessage(_INTL("The {1} ID? Certainly. That will be ${2}. OK?",itemname,price))
         #   break
         # end
          poop = 4
          if poop == 5
            Kernel.pbMessage(_INTL("You have no room for more cards."))
          else
  #          $game_variables[51][item][4]=true
  #          moneyString=_INTL("${1}",$Trainer.money)
  #          goldwindow.text=_INTL("Money:\n{1}",moneyString)
 #           pbTrainerIntro(:HIKER)
            $PokemonGlobal.nextBattleBack="Field"
                #$game_variables[51][0][name]
    #$game_variables[51][0][type]
    #$game_variables[51][0][bought]
    #$game_variables[51][0][price]
    #$game_variables[51][0][hasvalue]
            Kernel.pbMessage(_INTL("Battle is beginning! Be prepared!"))
            pbTrainerBattle($game_variables[51][item][1],$game_variables[51][item][0],_I("\bYou beat me!\nBut how?"),false,0)
          end
        end
      end
    end
  end
  cmdwindow.dispose
  goldwindow.dispose
  Graphics.frame_reset
  # Scroll right before showing screen
  pbScrollMap(6,3,5)
end

def pbTriadList
  commands=[]
  for i in 0...$PokemonGlobal.triads.length
    item=$PokemonGlobal.triads[i]
    speciesname=PBSpecies.getName(item[0])
    commands.push(_INTL("{1} x{2}",speciesname,item[1]))
  end
  commands.push(_INTL("CANCEL"))
  if commands.length==1
    Kernel.pbMessage(_INTL("You have no cards."))
    return
  end
  cmdwindow=Window_CommandPokemonEx.newWithSize(commands,0,0,256,Graphics.height)
  cmdwindow.z=99999
  sprite=Sprite.new
  sprite.z=99999
  sprite.x=256+40
  sprite.y=48
  moneyString=_INTL("${1}",$Trainer.money)
  done=false
  lastIndex=-1
  while !done
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      if lastIndex!=cmdwindow.index
        sprite.bitmap.dispose if sprite.bitmap
        if cmdwindow.index<$PokemonGlobal.triads.length
          sprite.bitmap=TriadCard.new($PokemonGlobal.triads.getItem(cmdwindow.index)).createBitmap(1)
        end
        lastIndex=cmdwindow.index
      end
      if Input.trigger?(Input::B)
        done=true
        break
      end
      if Input.trigger?(Input::C)
        if cmdwindow.index>=$PokemonGlobal.triads.length
          done=true
          break
        end
      end
    end
  end
  cmdwindow.dispose
  sprite.dispose
end
