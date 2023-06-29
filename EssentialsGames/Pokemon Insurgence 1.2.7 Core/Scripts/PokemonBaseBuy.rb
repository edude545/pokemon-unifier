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



class UpgradeStorage
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


def pbBuyUpgradesPre
  commands=[]
  realcommands=[]
    # name, price, switch 
    if(!$game_switches[94])
      commands.push([1000,"Mart Worker",_INTL("W: {2} ${1}",1000,("Mart Worker")),94])
    end
    if(!$game_switches[93])
      commands.push([2500,"Fossil Maniac",_INTL("W: {2} ${1}",2500,("Fossil Maniac")),93])
    end
    if(!$game_switches[95])
      commands.push([3500,"Trade Master",_INTL("W: {2} ${1}",3500,("Trade Master")),95])
    end
    if(!$game_switches[96])
      commands.push([3000,"Trainer",_INTL("W: {2} ${1}",3000,("Trainer")),96])
    end
#    if(!$game_switches[97])
#      commands.push([7000,"Clone",_INTL("W: {2} ${1}",7000,("Clone")),97])
#    end
    if(!$game_switches[101])&&($game_switches[92])
      commands.push([7000,"Professor",_INTL("W: {2} ${1}",7000,("Professor")),101])
    end
    if(!$game_switches[102])&&($game_switches[92])
      commands.push([3000,"Trader (Upgrade)",_INTL("W: {2} ${1}",3000,("Trader (Upgrade)")),102])
    end
    if(!$game_switches[103])&&($game_switches[92])
      commands.push([4000,"Mythologist",_INTL("W: {2} ${1}",4000,("Mythologist")),103])
    end
    if(!$game_switches[104])&&($game_switches[92])
      commands.push([6000,"Pokegear Designer",_INTL("W: {2} ${1}",6000,("Pokegear Designer")),104])
    end
    if(!$game_switches[105])&&($game_switches[92])
      commands.push([5000,"Tailor",_INTL("W: {2} ${1}",5000,("Tailor")),105])
    end
    if(!$game_switches[98])
      commands.push([8000,"Mining Cave",_INTL("SB: {2} ${1}",8000,("Mining Cave")),98])
    end
    if(!$game_switches[99])
      commands.push([7000,"Dungeon",_INTL("SB: {2} ${1}",7000,("Dungeon")),99])
    end
    if(!$game_switches[100])
      commands.push([9000,"Platform",_INTL("SB: {2} ${1}",9000,("Platform")),100])
    end
    if(!$game_switches[107])&&($game_switches[92])
      commands.push([1000,"Gastly",_INTL("PK: {2} ${1}",1000,("Gastly")),107])
    end
    if(!$game_switches[108])&&($game_switches[92])
      commands.push([1000,"Magnemite",_INTL("PK: {2} ${1}",1000,("Magnemite")),108])
    end
    if(!$game_switches[109])&&($game_switches[92])
      commands.push([1000,"Shuppet",_INTL("PK: {2} ${1}",1000,("Shuppet")),109])
    end
    if(!$game_switches[110])&&($game_switches[92])
      commands.push([1000,"Mr. Mime",_INTL("PK: {2} ${1}",1000,("Mr. Mime")),110])
    end
    if(!$game_switches[113])&&($game_switches[92])
      commands.push([4000,"Gideon",_INTL("GL: {2} ${1}",4000,("Gideon")),113])
    end
    if(!$game_switches[114])&&($game_switches[92])
      commands.push([4000,"Jonathan",_INTL("GL: {2} ${1}",4000,("Jonathan")),114])
    end
    if(!$game_switches[115])&&($game_switches[92])
      commands.push([4000,"PK-096",_INTL("GL: {2} ${1}",4000,("PK-096")),115])
    end
    if(!$game_switches[116])&&($game_switches[92])
      commands.push([4000,"Graham",_INTL("GL: {2} ${1}",4000,("Graham")),116])
    end
    if(!$game_switches[117])&&($game_switches[92])
      commands.push([4000,"Avery",_INTL("GL: {2} ${1}",4000,("Avery")),117])
    end
    if(!$game_switches[118])&&($game_switches[92])
      commands.push([4000,"Demetri",_INTL("GL: {2} ${1}",4000,("Demetri")),118])
    end
    if(!$game_switches[119])&&($game_switches[92])
      commands.push([4000,"Miranda",_INTL("GL: {2} ${1}",4000,("Miranda")),119])
    end
    if(!$game_switches[79])
      commands.push([1000,"Escape Route SE",_INTL("SE: {2} ${1}",1000,("Escape Route")),79])
    end
    if(!$game_switches[80])
      commands.push([1000,"Superior SE",_INTL("SE: {2} ${1}",1000,("Superior Town")),80])
    end
    if(!$game_switches[81])
      commands.push([1000,"Fianga SE",_INTL("SE: {2} ${1}",1000,("Fianga City")),81])
    end
    if(!$game_switches[82])
      commands.push([1000,"Kivu SE",_INTL("SE: {2} ${1}",1000,("Kivu Town")),82])
    end
    if(!$game_switches[83])
      commands.push([1000,"Ladoga SE",_INTL("SE: {2} ${1}",1000,("Ladoga Town")),83])
    end
    if(!$game_switches[84])
      commands.push([1000,"Blackfist SE",_INTL("SE: {2} ${1}",1000,("Blackfist City")),84])
    end
        if(!$game_switches[85])
      commands.push([1000,"Huron SE",_INTL("SE: {2} ${1}",1000,("Huron Town")),85])
    end
    
    if(!$game_switches[244] && $game_switches[257])
      commands.push([3000,"Blue Move Tutor",_INTL("W: {2} ${1}",3000,("Blue Move Tutor")),244])
    end
    if(!$game_switches[245] && $game_switches[257])
      commands.push([3000,"Green Move Tutor",_INTL("W: {2} ${1}",3000,("Green Move Tutor")),245])
    end
    if(!$game_switches[246] && $game_switches[257])
      commands.push([3000,"Yellow Move Tutor",_INTL("W: {2} ${1}",3000,("Yellow Move Tutor")),246])
    end
    if(!$game_switches[247] && $game_switches[257])
      commands.push([3000,"Red Move Tutor",_INTL("W: {2} ${1}",3000,("Red Move Tutor")),247])
    end
    if(!$game_switches[248] && $game_switches[257])
      commands.push([4000,"Day Care",_INTL("W: {2} ${1}",4000,("Day Care")),248])
    end
    if(!$game_switches[249] && $game_switches[257])
      commands.push([4000,"Day Care Garden",_INTL("SB: {2} ${1}",4000,("Day Care Garden")),249])
    end
    if(!$game_switches[250] && $game_switches[257])
      commands.push([2000,"Egg Hatching Tunnel",_INTL("SB: {2} ${1}",2000,("Egg Hatching Tunnel")),250])
    end
    if(!$game_switches[251] && $game_switches[257])
      commands.push([3500,"EV Resetter",_INTL("W: {2} ${1}",3500,("EV Resetter")),251])
    end
    if(!$game_switches[252] && $game_switches[257])
      commands.push([5000,"Online Worker",_INTL("W: {2} ${1}",5000,("Online Worker")),252])
    end
    if(!$game_switches[253] && $game_switches[257])
      commands.push([1500,"Name Rater",_INTL("W: {2} ${1}",1500,("Name Rater")),253])
    end
    if(!$game_switches[254] && $game_switches[257])
      commands.push([2500,"Move Relearner",_INTL("W: {2} ${1}",2500,("Move Relearner")),254])
    end
    if(!$game_switches[255] && $game_switches[257])
      commands.push([1500,"Move Deleter",_INTL("W: {2} ${1}",1500,("Move Deleter")),255])
    end
    if(!$game_switches[256] && $game_switches[257])
      commands.push([4000,"IV Changer",_INTL("W: {2} ${1}",4000,("IV Changer")),256])
    end
    if(!$game_switches[258] && $game_switches[257])
      commands.push([2000,"Hall of Glory",_INTL("SB: {2} ${1}",2000,("Hall of Glory")),258])
    end
    if(!$game_switches[260] && $game_switches[257])
      commands.push([3500,"Mart (Upgrade)",_INTL("W: {2} ${1}",3500,("Mart (Upgrade)")),260])
    end
    if(!$game_switches[261] && $game_switches[257])
      commands.push([5000,"Event Move Tutor",_INTL("W: {2} ${1}",5000,("Event Move Tutor")),261])
    end
    if commands.length==0
    Kernel.pbMessage(_INTL("You have purchased every avaliable upgrade for now!")) 
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
          if !Kernel.pbConfirmMessage(_INTL("The {1} upgrade? Certainly. That will be ${2}. OK?",itemname,price))
            break
          end
          if $Trainer.money<price
            Kernel.pbMessage(_INTL("You don't have enough money."))
            break
          end
          poop = 4
          if poop == 5
            Kernel.pbMessage(_INTL("You have no room for more upgrades."))
          else
            $game_switches[item]=true
            $Trainer.money-=price
            moneyString=_INTL("${1}",$Trainer.money)
            goldwindow.text=_INTL("Money:\n{1}",moneyString)
            Kernel.pbMessage(_INTL("Here you are!\r\nThank you!"))

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
def red(text)
    colorize(text,31)
end
def colorize(text, color_code)
  "\e[#{color_code}m#{text}e[0m"
end
