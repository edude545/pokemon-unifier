class ChallengeChampionship
    def generatePokemon(rank=0)
      if rank == 0
        choiceArray = [3,9,12,15,18,20,22,24,26,28,31,36,40,45,49,53,57,62,73,83,85,89,99,
                        101,103,105,107,110,119,122,124,139,154,162,164,166,168,182,185,189,
                        192,201,202,203,206,210,211,217,222,224,225,226,234,262,267,269,272,
                        275,277,279,284,301,310,311,312,313,314,317,319,321,323,324,326,327,
                        335,336,337,338,340,344,346,348,351,352,358,367,368,369,370,398,400,
                        402,411,414,416,417,419,421,424,428,432,435,441,455,457,463,476,
                        477,500,505,508,510,512,514,516,518,521,528,531,537,538,539,542,545,
                        547,550,556,563,565,569,573,576,581,584,586,587,591,594,596,606,614,
                        626,628,630,631,632]
    elsif rank == 1
        choiceArray = [6,34,38,47,51,55,62,65,68,71,76,78,80,87,91,94,97,101,106,107,115,121,
                        127,128,130,131,132,134,135,136,141,142,143,149,157,160,169,171,178,181,
                        184,186,195,196,197,202,205,208,212,214,227,229,230,235,237,242,248,
                        254,257,260,282,286,289,291,292,295,297,302,303,306,308,330,332,334,350,
                        352,354,362,365,373,376,389,392,395,405,407,409,423,430,437,442,445,450,
                        452,461,462,464,466,467,468,469,470,471,472,473,474,475,476,477,478,479,497,
                        500,503,526,530,534,553,555,560,567,571,579,576,589,591,593,596,601,604,
                        609,612,617,621,623,625,635,637]
                      elsif rank == 2
          choiceArray = [144,145,146,150,151,243,244,245,249,250,251,377,378,379,380,381,382,383,384,385,386,
                          480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,638,639,640,641,642,643,644,645,646,647,648,649]                  
                      end
                     
                      
                      return choiceArray[rand(choiceArray.length)]
                      
                    end
       
  def speech
    i = $game_variables[67]
    Kernel.pbMessage("The mighty Gym Leader... "+getTrainerName+"!") if i < 51 && pbGet(67) != 21
    Kernel.pbMessage("The mighty Gym Leaders... "+getTrainerName+"!") if i < 51 && pbGet(67) == 21
    Kernel.pbMessage("The all-powerful trainer... "+getTrainerName+"!") if i > 50 && i < 78
      Kernel.pbMessage("The legendary hero... "+getTrainerName+"!") if i > 77

    end
          
  def pbRandom(i)
    return rand(i)
    end
    
  
  def getType(i)
    if i == 0
      return "Normal"
      end
    if i == 1
      return "Fighting"
      end
    if i == 2
      return "Flying"
      end
    if i == 3
      return "Poison"
      end
    if i == 4
        return "Ground"
    end
    if i == 5
        return "Rock"
      end
      if i == 6
        return "Bug"
      end
      if i == 7
        return "Ghost"
      end
      if i == 8
        return "Steel"
      end
      if i == 9
        return "Fire"
      end
      if i == 10
        return "Water"
    end
      if i == 11
        return "Grass"
      end
      if i == 12
        return "Electric"
      end
      if i == 13
        return "Psychic"
      end
      if i == 14
        return "Ice"
      end
      if i == 15
        return "Dragon"
      end
      if i == 16
        return "Dark"
      end
      if i == 17
        return "Shadow"
      end
      if i == 18
        return "Fairy"
    end
  end
  def randomGymIntro
    i = $game_variables[78]
    Kernel.pbMessage(_INTL("Prepare yourself! I, {1}, have come to earn the {2} Badge!", 
$game_variables[75],$game_variables[73])) if i==0

    Kernel.pbMessage(_INTL("Ok, ok! You can do this! I'm {1}! I'm here to defeat you!", 
$game_variables[75],$game_variables[73])) if i==1

    Kernel.pbMessage(_INTL("Oh man, this is exciting! My very first Gym Battle! I hope I'm ready!", 
$game_variables[75],$game_variables[73])) if i==2

    Kernel.pbMessage(_INTL("Listen up, you may as well just hand the {2} Badge over! Don't you know who I am?", 
$game_variables[75],$game_variables[73])) if i==3

    Kernel.pbMessage(_INTL("Yeah, let's just get this over with. You're my first Gym, you'll be a pushover.", 
$game_variables[75],$game_variables[73])) if i==4

    Kernel.pbMessage(_INTL("Look, Gym Leaders are morons. Why would you only use one type?", 
$game_variables[75],$game_variables[73])) if i==5

    Kernel.pbMessage(_INTL("The name is {1}. Remember it. Your Gym's going to go out of business after this!", 
$game_variables[75],$game_variables[73])) if i==6

    Kernel.pbMessage(_INTL("Oh no, the Gym Leader! I don't know if I'm ready for this battle!", 
$game_variables[75],$game_variables[73])) if i==7

    Kernel.pbMessage(_INTL("Hold my beer, I got this.", 
$game_variables[75],$game_variables[73])) if i==8

    Kernel.pbMessage(_INTL("My Pokemon and I have been training for a very long time! We're ready for whatever you'll throw at us!", 
$game_variables[75],$game_variables[73])) if i==9

    Kernel.pbMessage(_INTL("Muahahahaha! The {2} Badge will be mine, I'm sure of it!", 
$game_variables[75],$game_variables[73])) if i==10

    Kernel.pbMessage(_INTL("I'm the greatest trainer around- and you're the first step on my journey!", 
$game_variables[75],$game_variables[73])) if i==11

    Kernel.pbMessage(_INTL("I think it would be better if, like, you didn't, like, have a monotype team, like.", 
$game_variables[75],$game_variables[73])) if i==12

    Kernel.pbMessage(_INTL("You've never felt a true battle before me- I am the greatest trainer ever!", 
$game_variables[75],$game_variables[73])) if i==13
  end
def randomGymWin
    i = $game_variables[78]
    Kernel.pbMessage(_INTL("I just wasn't prepared enough, I guess.", 
$game_variables[75],$game_variables[73])) if i==0

    Kernel.pbMessage(_INTL("But... but... I tried so hard...", 
$game_variables[75],$game_variables[73])) if i==1

    Kernel.pbMessage(_INTL("Waaaah! I can't believe I lost!", 
$game_variables[75],$game_variables[73])) if i==2

    Kernel.pbMessage(_INTL("Gyah! How could I lose to someone like you?", 
$game_variables[75],$game_variables[73])) if i==3

    Kernel.pbMessage(_INTL("But, you were supposed to be a pushover! I can't beat anybody else!", 
$game_variables[75],$game_variables[73])) if i==4

    Kernel.pbMessage(_INTL("No! I thought you were a moron!", 
$game_variables[75],$game_variables[73])) if i==5

    Kernel.pbMessage(_INTL("Well, this is awkward, I thought for sure I was going to win.", 
$game_variables[75],$game_variables[73])) if i==6

    Kernel.pbMessage(_INTL("Oh well, I knew I wasn't a good enough battler.", 
$game_variables[75],$game_variables[73])) if i==7

    Kernel.pbMessage(_INTL("Maybe I shouldn't drink beer before a Gym battle.", 
$game_variables[75],$game_variables[73])) if i==8

    Kernel.pbMessage(_INTL("I guess no matter how hard I train, I won't be good enough...", 
$game_variables[75],$game_variables[73])) if i==9

    Kernel.pbMessage(_INTL("All I wanted was the {2} Badge, it just sounded so cool...", 
$game_variables[75],$game_variables[73])) if i==10

    Kernel.pbMessage(_INTL("I was stomped upon! How did that happen?", 
$game_variables[75],$game_variables[73])) if i==11

    Kernel.pbMessage(_INTL("Did I just like, lose?", 
$game_variables[75],$game_variables[73])) if i==12

    Kernel.pbMessage(_INTL("I'm still the second best, so there's that!", 
$game_variables[75],$game_variables[73])) if i==13

  end

  
  
  
  
  def randomGymLose
    i = $game_variables[78]
    Kernel.pbMessage(_INTL("I can't believe it, my first badge! Thanks for the {2} Badge, that was a fun battle!", 
$game_variables[75],$game_variables[73])) if i==0

    Kernel.pbMessage(_INTL("I did my best, and I won the {2} Badge! I'm so happy!", 
$game_variables[75],$game_variables[73])) if i==1

    Kernel.pbMessage(_INTL("Ah! The {2} Badge... amazing! It looks so cool!", 
$game_variables[75],$game_variables[73])) if i==2

    Kernel.pbMessage(_INTL("I knew I would win all along, the {2} Badge isn't worth all that much to me.", 
$game_variables[75],$game_variables[73])) if i==3

    Kernel.pbMessage(_INTL("As I suspected, you were a complete pushover! Thanks for the badge, weakling!", 
$game_variables[75],$game_variables[73])) if i==4

    Kernel.pbMessage(_INTL("This is why you don't use monotype teams!", 
$game_variables[75],$game_variables[73])) if i==5

    Kernel.pbMessage(_INTL("E. Z. Stuff. Gimme that badge, and I'll be on my way!", 
$game_variables[75],$game_variables[73])) if i==6

    Kernel.pbMessage(_INTL("I... I really did it? Oh wow, I feel great! Thank you so much for the {2} Badge!", 
$game_variables[75],$game_variables[73])) if i==7

    Kernel.pbMessage(_INTL("Aww, yeah. The {2} Badge is mine! As my thanks, you can keep the beer.", 
$game_variables[75],$game_variables[73])) if i==8

    Kernel.pbMessage(_INTL("Today is the day my training paid off! I finally earned the {2} Badge! Thank you so much!", 
$game_variables[75],$game_variables[73])) if i==9

    Kernel.pbMessage(_INTL("I can't believe I won that- I genuinely thought I was going to lose there. Thanks for the battle!", 
$game_variables[75],$game_variables[73])) if i==10

    Kernel.pbMessage(_INTL("I was stomped upon! How did that happen?", 
$game_variables[75],$game_variables[73])) if i==11

    Kernel.pbMessage(_INTL("See? I was totally, like, right, that was like, easy. Thanks for like, the {2} Badge!", 
$game_variables[75],$game_variables[73])) if i==12

    Kernel.pbMessage(_INTL("I will always be the best. Thank's for the badge, pushover.", 
$game_variables[75],$game_variables[73])) if i==13

  end
  
  
  
  
  
  
  
  #Youngster
  #Camper
  #Psychic_F
  #Blackbelt
  #CrushGirl
  #Engineer
  #Beauty
  #Juggler
  #Lass
  #CoolTrainer_M
  #CoolTrainer_F
  def getTrainerType(i,string)
    return "Youngster" if i == 0 && string
    return PBTrainers::YOUNGSTER if i == 0 && !string
    return "Camper" if i == 1 && string
    return PBTrainers::CAMPER if i == 1 && !string
    return "Psychic" if i == 2 && string
    return PBTrainers::PSYCHIC_F if i == 2 && !string
    return "Blackbelt" if i == 3 && string
    return PBTrainers::BLACKBELT if i == 3 && !string
    return "Crush Girl" if i == 4 && string
    return PBTrainers::CRUSHGIRL if i == 4 && !string
    return "Engineer" if i == 5 && string
    return PBTrainers::ENGINEER if i == 5 && !string
    return "Beauty" if i == 6 && string
    return PBTrainers::BEAUTY if i == 6 && !string
    return "Juggler" if i == 7 && string
    return PBTrainers::JUGGLER if i == 7 && !string
    return "Lass" if i == 8 && string
    return PBTrainers::LASS if i == 8 && !string
    return "Cool Trainer" if i == 9 && string
    return PBTrainers::COOLTRAINER_M if i == 9 && !string
    return "Cool Trainer" if i == 10 && string
    return PBTrainers::COOLTRAINER_F if i == 10 && !string
    return "Cool Trainer"
  end
  


  
  def randomName(i)
    return "Dakota" if i == 0
    return "Sam" if i == 1
    return "Justice" if i == 2
    return "Phoenix" if i == 3
    return "Casey" if i == 4
    return "Riley" if i == 5
    return "River" if i == 6
    return "Harley" if i == 7
    return "Sage" if i == 8
    return "Quinn" if i == 9
    return "Kamryn" if i == 10
    return "Alex" if i == 11
    return "Taylor" if i == 12
    return "Artemis" if i == 13
    return "Bailey" if i == 14
    return "Brook" if i == 15
    return "Nic" if i == 16
    return "Corey" if i == 17
    return "Eli" if i == 18
    return "Gray" if i == 19
    return "Jamie" if i == 20
    return "Peyton" if i == 21
    return "Ruby" if i == 22
    return "Sapphire" if i == 23
    return "Topaz" if i == 24
    return "Sold" if i == 25
    return "Cash" if i == 26
    return "Skill" if i == 27
    return "Diamond" if i == 28
    return "Pearl" if i == 29
    return "Platinum" if i == 30
    return "Prism" if i == 31
    return "Prime" if i == 32
    return "Obsidia" if i == 33
    return "Melanite" if i == 34
    return "Rey" if i == 35
  end
  
  
  
  
  
  
  
  def getTrainerClass(integer=0)
    i = $game_variables[67]
    i = integer if integer != 0
    return PBTrainers::Challenge_Brock if i == 1
    return PBTrainers::Challenge_Misty if i == 2
    return PBTrainers::Challenge_Surge if i == 3
    return PBTrainers::Challenge_Erika if i == 4
    return PBTrainers::Challenge_Janine if i ==5
    return PBTrainers::Challenge_Sabrina if i == 6
    return PBTrainers::Challenge_Blaine if i == 7
    return PBTrainers::Challenge_Falkner if i ==8
    return PBTrainers::Challenge_Bugsy if i == 9
    return PBTrainers::Challenge_Whitney if i == 10
    return PBTrainers::Challenge_Morty if i == 11
    return PBTrainers::Challenge_Chuck if i == 12
    return PBTrainers::Challenge_Jasmine if i == 13
    return PBTrainers::Challenge_Pryce if i == 14
    return PBTrainers::Challenge_Roxanne if i == 15
    return PBTrainers::Challenge_Brawly if i == 16
    return PBTrainers::Challenge_Wattson if i == 17
    return PBTrainers::Challenge_Flannery if i == 18
    return PBTrainers::Challenge_Norman if i == 19
    return PBTrainers::Challenge_Winona if i == 20
    return PBTrainers::Challenge_TateLisa if i == 21
    return PBTrainers::Challenge_Roark if i ==22
    return PBTrainers::Challenge_Gardenia if i == 23
    return PBTrainers::Challenge_Maylene if i == 24
    return PBTrainers::Challenge_Wake if i == 25
    return PBTrainers::Challenge_Fantina if i == 26
    return PBTrainers::Challenge_Byron if i == 27
    return PBTrainers::Challenge_Candice if i == 28
    return PBTrainers::Challenge_Cilan if i == 29
    return PBTrainers::Challenge_Chili if i == 30
    return PBTrainers::Challenge_Cress if i == 31
    return PBTrainers::Challenge_Lenora if i == 32
    return PBTrainers::Challenge_Burgh if i == 33
    return PBTrainers::Challenge_Elesa if i == 34
    return PBTrainers::Challenge_Clay if i == 35
    return PBTrainers::Challenge_Skyla if i == 36
    return PBTrainers::Challenge_Brycen if i == 37
    return PBTrainers::Challenge_Roxie if i == 38
    return PBTrainers::Challenge_Marlon if i == 39

    return PBTrainers::Challenge_Clair if i == 40
    return PBTrainers::Challenge_Juan if i == 41
    return PBTrainers::Challenge_Volkner if i == 42
    return PBTrainers::Challenge_Drayden if i == 43
    return PBTrainers::Challenge_Lorelei if i == 44
    return PBTrainers::Challenge_Agatha if i == 45
    return PBTrainers::Challenge_Bruno if i == 46
    return PBTrainers::Challenge_Will if i == 47
    return PBTrainers::Challenge_Koga if i == 48
    return PBTrainers::Challenge_Karen if i == 49
    return PBTrainers::Challenge_Sidney if i == 50
    
    return PBTrainers::Challenge_Glacia if i == 51
    return PBTrainers::Challenge_Phoebe if i == 52
    return PBTrainers::Challenge_Drake if i == 53
    return PBTrainers::Challenge_Aaron if i == 54
    return PBTrainers::Challenge_Bertha if i == 55
    return PBTrainers::Challenge_Flint if i == 56
    return PBTrainers::Challenge_Lucian if i == 57
    return PBTrainers::Challenge_Shauntal if i == 58
    return PBTrainers::Challenge_Marshal if i == 59
    return PBTrainers::Challenge_Grimsley if i == 60
    return PBTrainers::Challenge_Caitlin if i == 61
    
    return PBTrainers::Challenge_Lance if i == 62
    return PBTrainers::Challenge_Wallace if i == 63
    return PBTrainers::Challenge_Alder if i == 64
    return PBTrainers::Challenge_Alder if i == 65
    return PBTrainers::Challenge_Iris if i == 66
    return PBTrainers::Challenge_Hilbert if i == 67
    return PBTrainers::Challenge_Hilda if i == 68
    return PBTrainers::Challenge_Cheren if i == 69
    return PBTrainers::Challenge_Bianca if i == 70
    return PBTrainers::Challenge_Nate if i == 71
    return PBTrainers::Challenge_Rosa if i == 72
    return PBTrainers::Challenge_Hugh if i == 73
    return PBTrainers::Challenge_Lucas if i == 74
    return PBTrainers::Challenge_Lucas if i == 75
    return PBTrainers::Challenge_Barry if i == 76
    return PBTrainers::Challenge_Lyra if i == 77
    return PBTrainers::Challenge_Silver if i == 78
  end             

  def getTrainerName(integer=0)
    i = $game_variables[67]
    i = integer if integer != 0
    return "Brock" if i == 1
    return "Misty" if i == 2
    return "Lt. Surge" if i == 3
    return "Erika" if i == 4
    return "Janine" if i == 5
    return "Sabrina" if i == 6
    return "Blaine" if i == 7
    return "Falkner" if i == 8
    return "Bugsy" if i == 9
    return "Whitney" if i == 10
    return "Morty" if i == 11
    return "Chuck" if i == 12
    return "Jasmine" if i == 13
    return "Pryce" if i == 14
    return "Roxanne" if i == 15
    return "Brawly" if i == 16
    return "Wattson" if i == 17
    return "Flannery" if i == 18
    return "Norman" if i == 19
    return "Winona" if i == 20
    return "Tate and Lisa" if i == 21
    return "Roark" if i == 22
    return "Gardenia" if i == 23
    return "Maylene" if i == 24
    return "Crasher Wake" if i == 25
    return "Fantina" if i == 26
    return "Byron" if i == 27
    return "Candice" if i == 28
    return "Cilan" if i == 29
    return "Chili" if i == 30
    return "Cress" if i == 31
    return "Lenora" if i == 32
    return "Burgh" if i == 33
    return "Elesa" if i == 34
    return "Clay" if i == 35
    return "Skyla" if i == 36
    return "Brycen" if i == 37
    return "Roxie" if i == 38
    return "Marlon" if i == 39
    

    return "Clair" if i ==40
    return "Juan" if i ==41
    return "Volkner" if i ==42
    return "Drayden" if i ==43
    return "Lorelei" if i ==44
    return "Agatha" if i ==45
    return "Bruno" if i ==46
    return "Will" if i ==47
    return "Koga" if i ==48
    return "Karen" if i ==49
    return "Sidney" if i ==50
    return "Glacia" if i ==51
    return "Phoebe" if i ==52
    return "Drake" if i ==53
    return "Aaron" if i ==54
    return "Bertha" if i ==55
    return "Flint" if i ==56
    return "Lucian" if i ==57
    return "Shauntal" if i ==58
    return "Marshal" if i ==59
    return "Grimsley" if i ==60
    return "Caitlin" if i ==61


    return "Lance" if i ==62
    return "Lance" if i ==63
    return "Alder" if i ==64
    return "Alder" if i ==65
    return "Iris" if i ==66
    return "Hilbert" if i ==67
    return "Hilda" if i ==68
    return "Cheren" if i ==69
    return "Bianca" if i ==70
    return "Nate" if i ==71
    return "Rosa" if i ==72
    return "Hugh" if i ==73
    return "Lucas" if i ==74
    return "Lucas" if i ==75
    return "Barry" if i ==76
    return "Lyra" if i ==77
    return "Silver" if i ==78
    return "Cock"
              
          
  end
  
 
#  def speech
#    return "Penus"
# end
  
end
#module Kernel
  
  
  def registerMobile(string)
    return true
end


def getAllDeltas
  ary=[]
  for i in 0..PBSpecies.maxValue
      if i >= PBSpecies::DELTABULBASAUR && i <= PBSpecies::DELTAHOOPA
        ary.push(i)
      end
  end
  return ary

end

def mc(string,color)
    if color=="blue"
      return "<c2=65467b14>"+string+"</c2>"
    end
    if color=="red"
      return "<c2=043c3aff>"+string+"</c2>"
    end
  end
  
def fossilManiac
  b="blue"
  Kernel.pbMessage(mc("Why, hello there!",b))
      Kernel.pbMessage(mc("I'm the Fossil Maniac!",b))
      Kernel.pbMessage(mc("Guess what? I'll be pleased as punch to revive your fossils!",b))
      if Kernel.pbConfirmMessage(mc("What do you say? Do you want me to revive a fossil?",b))
        var=pbChooseItemFromList(mc("Choose a fossil.",b),1,:DOMEFOSSIL,:HELIXFOSSIL,:OLDAMBER,
        :ROOTFOSSIL,:CLAWFOSSIL,:ARMORFOSSIL,:SKULLFOSSIL,:COVERFOSSIL,:PLUMEFOSSIL,
        :JAWFOSSIL,:SAILFOSSIL)
        if var==0
          Kernel.pbMessage(mc("Well, you don't have any fossils! You'd better go get some!",b))
        elsif var==-1
          Kernel.pbMessage(mc("Get me a fossil to revive, and I'll do it for you.",b))
        else
          poke=0
          poke=PBSpecies::KABUTO if var==PBItems::DOMEFOSSIL
          poke=PBSpecies::OMANYTE if var==PBItems::HELIXFOSSIL
          poke=PBSpecies::AERODACTYL if var==PBItems::OLDAMBER
          poke=PBSpecies::LILEEP if var==PBItems::ROOTFOSSIL
          poke=PBSpecies::ANORITH if var==PBItems::CLAWFOSSIL
          poke=PBSpecies::SHIELDON if var==PBItems::ARMORFOSSIL
          poke=PBSpecies::CRANIDOS if var==PBItems::SKULLFOSSIL
          poke=PBSpecies::TIRTOUGA if var==PBItems::COVERFOSSIL
          poke=PBSpecies::ARCHEN if var==PBItems::PLUMEFOSSIL
          poke=PBSpecies::TYRUNT if var==PBItems::JAWFOSSIL
          poke=PBSpecies::AMAURA if var==PBItems::SAILFOSSIL
          $PokemonBag.pbDeleteItem(var)
          pbAddPokemon(poke,5)
        end
      else
        
      end
      Kernel.pbMessage(mc("Stop by again!",b))

    end
    
  
def getStarterList
  return [PBSpecies::FROAKIE,PBSpecies::FROGADIER,
      PBSpecies::GRENINJA,PBSpecies::FENNEKIN,PBSpecies::BRAIXEN,
      PBSpecies::DELPHOX,PBSpecies::CHESPIN,PBSpecies::QUILLADIN,PBSpecies::CHESNAUGHT,
      PBSpecies::BUNNELBY,PBSpecies::DIGGERSBY,PBSpecies::PANCHAM,PBSpecies::PANGORO,
      PBSpecies::ESPURR,PBSpecies::MEOWSTIC,PBSpecies::HONEDGE,PBSpecies::DOUBLADE,
      PBSpecies::AEGISLASH,PBSpecies::INKAY,PBSpecies::MALAMAR,PBSpecies::BINACLE,
      PBSpecies::BARBARACLE,PBSpecies::SKRELP,PBSpecies::DRAGALGE,PBSpecies::HELIOPTILE,
      PBSpecies::HELIOLISK,PBSpecies::TYRUNT,PBSpecies::TYRANTRUM,PBSpecies::AMAURA,
      PBSpecies::AURORUS,PBSpecies::SYLVEON,PBSpecies::HAWLUCHA,PBSpecies::CARBINK,
      PBSpecies::GOOMY,PBSpecies::SLIGGOO,PBSpecies::GOODRA,PBSpecies::KLEFKI,
      PBSpecies::BERGMITE,PBSpecies::AVALUGG,PBSpecies::NOIBAT,PBSpecies::XERNEAS,
      PBSpecies::YVELTAL,PBSpecies::NOIVERN,
      PBSpecies::ZYGARDE,PBSpecies::DIANCIE,PBSpecies::VOLCANION,
      PBSpecies::HOOPA]
    end
                                                    
def pbGetOneOfPuzzles
    ary=["Kabuto","Aerodactyl","Ho-oh","Mew","Omanyte"]                                                                        
    randv = rand(ary.length)
    return ary[randv]

  
end

    
    
def pbGenerateRandomStarter
  species = rand(649+getStarterList.length)+1 if $game_switches[321]
  if species > 649 && $game_switches[321]
      species-=649
      getStarterList[species]

  end
        species = 1 if species == 0
    return species
  
  
  end

def doMoonCheck
  hasMove=false
  movePokemon=0
  moveMove=""
  for i in 0..$Trainer.party.length-1
    for j in 0..$Trainer.party[i].moves.length-1
      if $Trainer.party[i].moves[j].id==PBMoves::MOONBLAST ||
         $Trainer.party[i].moves[j].id==PBMoves::MOONLIGHT 
        hasMove=true
        movePokemon=i
        moveMove=j
        break
      end
    end
    if hasMove
      break
    end
  end
  return false if !hasMove
  if Kernel.pbConfirmMessage("Would you like to try filling the stump with the power of the moon?")
    Kernel.pbMessage(_INTL("{1} used {2}!",$Trainer.party[i].name,PBMoves.getName($Trainer.party[i].moves[j].id)))
    pbHiddenMoveAnimation($Trainer.party[i])
    return true
  end
end
  
def doInsurgenceRockSmash
  Kernel.pbMessage("This rock looks breakable.")
  hasMove=false
  movePokemon=0
  moveMove=""
  for i in 0..$Trainer.party.length-1
    for j in 0..$Trainer.party[i].moves.length-1
      if $Trainer.party[i].moves[j].type==PBTypes::FIGHTING && 
         $Trainer.party[i].moves[j].basedamage>0
        #$Trainer.party[i].moves[j].id==PBMoves::ROCKSMASH) ||
        #$Trainer.party[i].moves[j].id==PBMoves::COUNTER ||
        #$Trainer.party[i].moves[j].id==PBMoves::DETECT
          hasMove=true
          movePokemon=i
          moveMove=j
          break
      end
    end
    if hasMove
      break
    end
    
  end
  return false if !hasMove
  if Kernel.pbConfirmMessage("Would you like to break it?")
    Kernel.pbMessage(_INTL("{1} used {2}!",$Trainer.party[i].name,PBMoves.getName($Trainer.party[i].moves[j].id)))
    pbHiddenMoveAnimation($Trainer.party[i])
    
    aryOfSmashPokemon=[PBSpecies::GEODUDE,PBSpecies::GEODUDE,PBSpecies::GEODUDE,
    PBSpecies::GEODUDE,PBSpecies::ROGGENROLA,PBSpecies::ROGGENROLA,PBSpecies::ROGGENROLA,
    PBSpecies::NOSEPASS,PBSpecies::NOSEPASS,PBSpecies::CARBINK,PBSpecies::SHUCKLE,
    PBSpecies::DWEBBLE]
    aryOfSmashItems=[PBItems::HARDSTONE,PBItems::HARDSTONE,
    PBItems::PEARL,PBItems::SOFTSAND,PBItems::HARDSTONE,PBItems::HEARTSCALE,
    PBItems::PEARL,PBItems::SOFTSAND,PBItems::HARDSTONE,PBItems::HEARTSCALE,
    PBItems::PEARL,PBItems::SOFTSAND,PBItems::HARDSTONE,PBItems::HEARTSCALE,
    PBItems::PEARL,PBItems::SOFTSAND,PBItems::DOMEFOSSIL,PBItems::HELIXFOSSIL,
    PBItems::OLDAMBER,PBItems::ROOTFOSSIL,PBItems::CLAWFOSSIL,
    PBItems::SKULLFOSSIL,PBItems::ARMORFOSSIL,PBItems::COVERFOSSIL,PBItems::PLUMEFOSSIL,
    PBItems::SAILFOSSIL,PBItems::JAWFOSSIL,PBItems::IVSTONE]
    return true if rand(2)!=0
    if rand(2)!=0 #Random Pokemon
      levelrand=0
      if $Trainer.party[i].level<6
        levelrand=5
      else
        levelrand=$Trainer.party[i].level - rand(5)
      end
      
      pokerand = rand(aryOfSmashPokemon.length)
      pokemonToUse=aryOfSmashPokemon[pokerand]
      pbWildBattle(pokemonToUse,levelrand)
      return true
      
      
    else #Random Item
      itemrand = rand(aryOfSmashItems.length)
      itemToUse=aryOfSmashItems[itemrand]
      pbItemBall(itemToUse)
    end
    
    
  end
end


def pbChooseSoloStarter
  speciesarray=[
    PBSpecies::ABRA,PBSpecies::ABSOL,PBSpecies::AERODACTYL,PBSpecies::AIPOM,
    PBSpecies::ALOMOMOLA,PBSpecies::AMAURA,PBSpecies::ANORITH,
    PBSpecies::ARCHEN,PBSpecies::ARON,PBSpecies::AUDINO,PBSpecies::AXEW,
    PBSpecies::AZURILL,PBSpecies::BAGON,PBSpecies::BALTOY,PBSpecies::BARBOACH,
    PBSpecies::BASCULIN,PBSpecies::BELDUM,PBSpecies::BELLSPROUT,PBSpecies::BERGMITE,
    PBSpecies::BIDOOF,PBSpecies::BINACLE,PBSpecies::BLITZLE,PBSpecies::BONSLY,
    PBSpecies::BOUFFALANT,PBSpecies::BRONZOR,PBSpecies::BUDEW,PBSpecies::BUIZEL,
    PBSpecies::BULBASAUR,PBSpecies::BUNEARY,PBSpecies::BUNNELBY,PBSpecies::BURMY,
    PBSpecies::CACNEA,PBSpecies::CARBINK,PBSpecies::CARNIVINE,PBSpecies::CARVANHA,
    PBSpecies::CASTFORM,PBSpecies::CATERPIE,PBSpecies::CHARMANDER,PBSpecies::CHATOT,
    PBSpecies::CHERUBI,PBSpecies::CHESPIN,PBSpecies::CHIKORITA,PBSpecies::CHIMCHAR,
    PBSpecies::CHINCHOU,PBSpecies::CHINGLING,PBSpecies::CLAMPERL,PBSpecies::CLAUNCHER,
    PBSpecies::CLEFFA,PBSpecies::COMBEE,PBSpecies::CORPHISH,PBSpecies::CORSOLA,
    PBSpecies::COTTONEE,PBSpecies::CRANIDOS,PBSpecies::CROAGUNK,PBSpecies::CRYOGONAL,
    PBSpecies::CUBCHOO,PBSpecies::CUBONE,PBSpecies::CYNDAQUIL,PBSpecies::DARUMAKA,
    PBSpecies::DEDENNE,PBSpecies::DEERLING,PBSpecies::DEINO,PBSpecies::DELIBIRD,
    PBSpecies::DIGLETT,PBSpecies::DITTO,PBSpecies::DODUO,PBSpecies::DRATINI,
    PBSpecies::DRIFLOON,PBSpecies::DRILBUR,PBSpecies::DROWZEE,PBSpecies::DRUDDIGON,
    PBSpecies::DUCKLETT,PBSpecies::DUNSPARCE,PBSpecies::DURANT,PBSpecies::DUSKULL,
    PBSpecies::DWEBBLE,PBSpecies::EEVEE,PBSpecies::EKANS,PBSpecies::ELECTRIKE,
    PBSpecies::ELEKID,PBSpecies::ELGYEM,PBSpecies::EMOLGA,PBSpecies::ESPURR,
    PBSpecies::EXEGGCUTE,PBSpecies::FARFETCHD,PBSpecies::FEEBAS,PBSpecies::FENNEKIN,
    PBSpecies::FERROSEED,PBSpecies::FINNEON,PBSpecies::FLABEBE,PBSpecies::FLETCHLING,
    PBSpecies::FOONGUS,PBSpecies::FRILLISH,PBSpecies::FROAKIE,PBSpecies::FURFROU,
    PBSpecies::GASTLY,PBSpecies::GEODUDE,PBSpecies::GIBLE,PBSpecies::GIRAFARIG,
    PBSpecies::GLAMEOW,PBSpecies::GLIGAR,PBSpecies::GOLDEEN,PBSpecies::GOLETT,
    PBSpecies::GOOMY,PBSpecies::GOTHITA,PBSpecies::GRIMER,PBSpecies::GROWLITHE,
    PBSpecies::GULPIN,PBSpecies::HAPPINY,PBSpecies::HAWLUCHA,PBSpecies::HEATMOR,
    PBSpecies::HELIOPTILE,PBSpecies::HERACROSS,PBSpecies::HIPPOPOTAS,
    PBSpecies::HONEDGE,PBSpecies::HOOTHOOT,PBSpecies::HOPPIP,PBSpecies::HORSEA,
    PBSpecies::HOUNDOUR,PBSpecies::IGGLYBUFF,PBSpecies::ILLUMISE,PBSpecies::INKAY,
    PBSpecies::JOLTIK,PBSpecies::KABUTO,PBSpecies::KANGASKHAN,PBSpecies::KARRABLAST,
    PBSpecies::KECLEON,PBSpecies::KLEFKI,PBSpecies::KLINK,PBSpecies::KOFFING,
    PBSpecies::KRABBY,PBSpecies::KRICKETOT,PBSpecies::LAPRAS,PBSpecies::LARVESTA,
    PBSpecies::LARVITAR,PBSpecies::LEDYBA,PBSpecies::LICKITUNG,PBSpecies::LILEEP,
    PBSpecies::LILLIPUP,PBSpecies::LITLEO,PBSpecies::LITWICK,PBSpecies::LOTAD,
    PBSpecies::LUNATONE,PBSpecies::LUVDISC,PBSpecies::MACHOP,PBSpecies::MAGBY,
    PBSpecies::MAGIKARP,PBSpecies::MAGNEMITE,PBSpecies::MAKUHITA,PBSpecies::MANKEY,
    PBSpecies::MANTYKE,PBSpecies::MARACTUS,PBSpecies::MAREEP,PBSpecies::MARILL,
    PBSpecies::MAWILE,PBSpecies::MEDITITE,PBSpecies::MEOWTH,PBSpecies::MIENFOO,
    PBSpecies::MILTANK,PBSpecies::MIMEJR,PBSpecies::MINCCINO,PBSpecies::MINUN,
    PBSpecies::MISDREAVUS,PBSpecies::MUDKIP,PBSpecies::MUNCHLAX,PBSpecies::MUNNA,
    PBSpecies::MURKROW,PBSpecies::NATU,PBSpecies::NIDORANfE,PBSpecies::NIDORANmA,
    PBSpecies::NINCADA,PBSpecies::NOIBAT,PBSpecies::NOSEPASS,PBSpecies::NUMEL,
    PBSpecies::ODDISH,PBSpecies::OMANYTE,PBSpecies::ONIX,PBSpecies::OSHAWOTT,
    PBSpecies::PACHIRISU,PBSpecies::PANCHAM,PBSpecies::PANPOUR,PBSpecies::PANSAGE,
    PBSpecies::PANSEAR,PBSpecies::PARAS,PBSpecies::PATRAT,PBSpecies::PAWNIARD,
    PBSpecies::PETILIL,PBSpecies::PHANPY,PBSpecies::PHANTUMP,PBSpecies::PICHU,
    PBSpecies::PIDGEY,PBSpecies::PIDOVE,PBSpecies::PINECO,PBSpecies::PINSIR,
    PBSpecies::PIPLUP,PBSpecies::PLUSLE,PBSpecies::POLIWAG,PBSpecies::PONYTA,
    PBSpecies::POOCHYENA,PBSpecies::PORYGON,PBSpecies::PSYDUCK,PBSpecies::PUMPKABOO,
    PBSpecies::PURRLOIN,PBSpecies::QWILFISH,PBSpecies::RALTS,PBSpecies::RATTATA,
    PBSpecies::RELICANTH,PBSpecies::REMORAID,PBSpecies::RHYHORN,PBSpecies::RIOLU,
    PBSpecies::ROGGENROLA,PBSpecies::ROTOM,PBSpecies::RUFFLET,PBSpecies::SABLEYE,
    PBSpecies::SANDILE,PBSpecies::SANDSHREW,PBSpecies::SAWK,PBSpecies::SCATTERBUG,
    PBSpecies::SCRAGGY,PBSpecies::SCYTHER,PBSpecies::SEEDOT,PBSpecies::SEEL,
    PBSpecies::SENTRET,PBSpecies::SEVIPER,PBSpecies::SEWADDLE,PBSpecies::SHELLDER,
    PBSpecies::SHELLOS,PBSpecies::SHELMET,PBSpecies::SHIELDON,PBSpecies::SHINX,
    PBSpecies::SHROOMISH,PBSpecies::SHUCKLE,PBSpecies::SHUPPET,PBSpecies::SIGILYPH,
    PBSpecies::SKARMORY,PBSpecies::SKIDDO,PBSpecies::SKITTY,PBSpecies::SKORUPI,
    PBSpecies::SKRELP,PBSpecies::SLAKOTH,PBSpecies::SLOWPOKE,PBSpecies::SLUGMA,
    PBSpecies::SMEARGLE,PBSpecies::SMOOCHUM,PBSpecies::SNEASEL,PBSpecies::SNIVY,
    PBSpecies::SNORUNT,PBSpecies::SNOVER,PBSpecies::SNUBBULL,PBSpecies::SOLOSIS,
    PBSpecies::SOLROCK,PBSpecies::SPEAROW,PBSpecies::SPHEAL,PBSpecies::SPINARAK,
    PBSpecies::SPINDA,PBSpecies::SPIRITOMB,PBSpecies::SPOINK,PBSpecies::SPRITZEE,
    PBSpecies::SQUIRTLE,PBSpecies::STANTLER,PBSpecies::STARLY,PBSpecies::STARYU,
    PBSpecies::STUNFISK,PBSpecies::STUNKY,PBSpecies::SUNKERN,PBSpecies::SURSKIT,
    PBSpecies::SWABLU,PBSpecies::SWINUB,PBSpecies::SWIRLIX,PBSpecies::TAILLOW,PBSpecies::TANGELA,
    PBSpecies::TAUROS,PBSpecies::TEDDIURSA,PBSpecies::TENTACOOL,PBSpecies::TEPIG,
    PBSpecies::THROH,PBSpecies::TIMBURR,PBSpecies::TIRTOUGA,PBSpecies::TOGEPI,
    PBSpecies::TORCHIC,PBSpecies::TORKOAL,PBSpecies::TOTODILE,PBSpecies::TRAPINCH,
    PBSpecies::TREECKO,PBSpecies::TROPIUS,PBSpecies::TRUBBISH,PBSpecies::TURTWIG,
    PBSpecies::TYMPOLE,PBSpecies::TYNAMO,PBSpecies::TYROGUE,PBSpecies::TYRUNT,
    PBSpecies::UNOWN,PBSpecies::VANILLITE,PBSpecies::VENIPEDE,PBSpecies::VENONAT,
    PBSpecies::VOLBEAT,PBSpecies::VOLTORB,PBSpecies::VULLABY,PBSpecies::VULPIX,
    PBSpecies::WAILMER,PBSpecies::WEEDLE,PBSpecies::WHISMUR,PBSpecies::WINGULL,
    PBSpecies::WOOBAT,PBSpecies::WOOPER,PBSpecies::WURMPLE,PBSpecies::WYNAUT,
    PBSpecies::YAMASK,PBSpecies::YANMA,PBSpecies::ZANGOOSE,PBSpecies::ZIGZAGOON,
    PBSpecies::ZORUA,PBSpecies::ZUBAT,PBSpecies::DELTABULBASAUR,
    PBSpecies::DELTACHARMANDER,PBSpecies::DELTASQUIRTLE,PBSpecies::DELTAPAWNIARD,
    PBSpecies::DELTARALTS,PBSpecies::DELTASUNKERN,PBSpecies::DELTABERGMITE,
    PBSpecies::DELTASCYTHER,PBSpecies::DELTASCRAGGY,PBSpecies::DELTACOMBEE,
    PBSpecies::DELTAKOFFING,PBSpecies::DELTAPURRLOIN,PBSpecies::DELTAPHANTUMP,
    PBSpecies::DELTASNORUNT,PBSpecies::DELTASHINX,PBSpecies::DELTANOIBAT,
    PBSpecies::DELTABUDEW,PBSpecies::DELTADRIFLOON,PBSpecies::DELTAGRIMER,
    PBSpecies::DELTAWOOPER,PBSpecies::DELTAMUNCHLAX,PBSpecies::DELTAMISDREAVUS,
    PBSpecies::DELTACYNDAQUIL,PBSpecies::DELTATREECKO,PBSpecies::DELTATORCHIC,
    PBSpecies::DELTATURTWIG,PBSpecies::DELTASNIVY,PBSpecies::DELTAFROAKIE,
    PBSpecies::DELTAPIDGEY,PBSpecies::DELTADIGLETT,PBSpecies::DELTAGROWLITHE,
    PBSpecies::DELTAGEODUDE,PBSpecies::DELTATENTACOOL,PBSpecies::DELTADODUO,
    PBSpecies::DELTATANGELA,PBSpecies::DELTADITTO,PBSpecies::DELTAKABUTO,
    PBSpecies::DELTADRATINI,PBSpecies::DELTAHOOTHOOT,PBSpecies::DELTACHINCHOU,
    PBSpecies::DELTAPICHU,PBSpecies::DELTAAIPOM,PBSpecies::DELTAYANMA,
    PBSpecies::DELTAGIRAFARIG,PBSpecies::DELTADUNSPARCE,PBSpecies::DELTASHUCKLE,
    PBSpecies::DELTAREMORAID,PBSpecies::DELTAELEKID,PBSpecies::DELTAMAGBY,
    PBSpecies::DELTALOTAD,PBSpecies::DELTASEEDOT,PBSpecies::DELTASABLEYE,
    PBSpecies::DELTAMAWILE,PBSpecies::DELTAARON,PBSpecies::DELTAMEDITITE,
    PBSpecies::DELTANUMEL,PBSpecies::DELTAPLUSLE,PBSpecies::DELTAMINUN,
    PBSpecies::DELTAWAILMER,PBSpecies::DELTAFEEBAS,PBSpecies::DELTACLAMPERL,
    PBSpecies::DELTABELDUM1,PBSpecies::DELTABELDUM2,PBSpecies::DELTABUNEARY,
    PBSpecies::DELTARIOLU,PBSpecies::DELTACROAGUNK,PBSpecies::DELTAVENIPEDE,
    PBSpecies::DELTAPETILIL1,PBSpecies::DELTAPETILIL2,PBSpecies::DELTASOLOSIS,
    PBSpecies::DELTADARUMAKA,PBSpecies::DELTAMARACTUS,PBSpecies::DELTADWEBBLE1,
    PBSpecies::DELTADWEBBLE2,PBSpecies::DELTAYAMASK,PBSpecies::DELTAEMOLGA,
    PBSpecies::DELTAKARRABLAST,PBSpecies::DELTAFOONGUS,PBSpecies::DELTALITWICK,
    PBSpecies::DELTAAXEW,PBSpecies::DELTAGOLETT,PBSpecies::DELTAHEATMOR,
    PBSpecies::DELTADEINO,PBSpecies::DELTALARVESTA,PBSpecies::DELTAAMAURA,
    PBSpecies::DELTAGOOMY]
  speciesname = []
  for name in speciesarray
      speciesname.push(PBSpecies.getName(name))
  end
  tempint=Kernel.pbMessage("Choose which starter? (Q and W to skip through list.)",speciesname)
  return speciesarray[tempint]
end
def pbNuzlockeMenu
viewport=Viewport.new(0,0,3344,1088) # 512+160 , 384+160
  viewport.z=99999

  sliderwin2=ControlWindow.new(40,0,440,384)
  sliderwin2.viewport=viewport
  talk=sliderwin2.addControl(PlainText.new(_INTL("Choose the settings for your challenge run.")))
  set0=sliderwin2.addControl(Checkbox.new(_INTL("Nuzlocke")))
  set1=sliderwin2.addControl(Checkbox.new(_INTL("Randomized")))
  set2=sliderwin2.addControl(Checkbox.new(_INTL("PP Challenge")))
    set6=sliderwin2.addControl(Checkbox.new(_INTL("Egg Challenge")))
  set3=sliderwin2.addControl(Checkbox.new(_INTL("Solo Run")))# if $game_switches[12]
  set4=sliderwin2.addControl(Checkbox.new(_INTL("Mystery Challenge")))
  set5=sliderwin2.addControl(Checkbox.new(_INTL("Non-Technical Challenge")))
  set7=sliderwin2.addControl(Checkbox.new(_INTL("Bravery Challenge")))
  set8=sliderwin2.addControl(Checkbox.new(_INTL("Wonder Challenge")))
  set9=sliderwin2.addControl(Checkbox.new(_INTL("Ironman Challenge")))
  okbutton=sliderwin2.addButton(_INTL("OK"))
  cancelbutton=sliderwin2.addButton(_INTL("Cancel"))
  loop do
    Graphics.update
    Input.update
    sliderwin2.update
    if sliderwin2.changed?(okbutton) || Input.trigger?(Input::C)
            if sliderwin2.value(set6) && sliderwin2.value(set3)
        Kernel.pbMessage("You cannot do both an Egg Challenge and a Solorun.")
      elsif sliderwin2.value(set6) && sliderwin2.value(set1)
        Kernel.pbMessage("You cannot do both an Egg Challenge and a Randomizer.")
      elsif sliderwin2.value(set8) && sliderwin2.value(set1)
        Kernel.pbMessage("You cannot do both an Wonder Challenge and a Randomizer.")
      elsif sliderwin2.value(set8) && sliderwin2.value(set3)
        Kernel.pbMessage("You cannot do both an Wonder Challenge and a Solo Run.")
      elsif sliderwin2.value(set8) && sliderwin2.value(set6)
        Kernel.pbMessage("You cannot do both an Egg Challenge and an Egg Challenge.")
      elsif !sliderwin2.value(set0) && sliderwin2.value(set9)
        Kernel.pbMessage("If you are doing an Ironman, you must also do a Nuzlocke.")
      else

      if sliderwin2.value(set0)
        $game_switches[71]=true
      end
      if sliderwin2.value(set1)
        $game_switches[321]=true
      end
      if sliderwin2.value(set2)
        $game_switches[345]=true
      end
      if sliderwin2.value(set3)# && $game_switches[12]
        $game_switches[346]=true
      end
      if sliderwin2.value(set4)
        $game_switches[354]=true
      end
      if sliderwin2.value(set5)
        $game_switches[355]=true
      end
      if sliderwin2.value(set6)
        $game_switches[356]=true
      end
      if sliderwin2.value(set7)
        $game_switches[357]=true
      end
      if sliderwin2.value(set8)
        $game_switches[583]=true
      end
      
      if sliderwin2.value(set9)
        $game_switches[584]=true
      end
      break
      end
    
    end
    if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::B)
      break
    end
  end
  sliderwin2.dispose
  viewport.dispose
end


def tryConnect
  if $game_switches[321] || $game_switches[356] || $game_switches[346] || $game_switches[347]
    Kernel.pbMessage("The Challenge Mode you are on cannot go online.")
    $scene=Scene_Map.new      
  else
    $scene=Connect.new
  end  
end

def pbForfeitPPChallenge
  Kernel.pbMessage("The PP Challenge was forfeited.")
  Kernel.pbMessage(_INTL("Pokemon Centers will now heal PP."))
  Kernel.pbMessage("Thank you for participating.")
  $game_switches[345]=false
  Kernel.deleteItemsForfeit
  end
def pbForfeitSolorun
  Kernel.pbMessage("The Solorun was forfeited.")
  Kernel.pbMessage(_INTL("Pokemon are no longer always sent your PC."))
  Kernel.pbMessage(_INTL("Your PC will now be accessible."))
  Kernel.pbMessage("Thank you for participating.")
  $game_switches[346]=false
  $game_switches[347]=false
  Kernel.deleteItemsForfeit
end
def pbForfeitWonder
#        challenges.push("Wonder Challenge") if $game_switches[583]
  Kernel.pbMessage("The Wonder Challenge was forfeited.")
  Kernel.pbMessage(_INTL("You are no longer forced to Wonder Trade Pokemon."))
  Kernel.pbMessage("Thank you for participating.")
  $game_switches[583]=false
  end
def pbForfeitMystery
  Kernel.pbMessage("The Mystery Challenge was forfeited.")
  Kernel.pbMessage(_INTL("All Pokemon are now identifiable."))
  Kernel.pbMessage("Thank you for participating.")
  $game_switches[354]=false
  end
def pbForfeitNonTechnical
  Kernel.pbMessage("The Non-Technical was forfeited.")
  Kernel.pbMessage(_INTL("TMs can now be taught to Pokemon."))
  Kernel.pbMessage("Thank you for participating.")
  $game_switches[355]=false
  Kernel.deleteItemsForfeit
end
def pbForfeitAntiAnte
  Kernel.pbMessage("The Anti-ante was forfeited.")
  Kernel.pbMessage(_INTL("You will now receive money from defeating trainers."))
  Kernel.pbMessage("Thank you for participating.")
  $game_switches[356]=false
end
def pbForfeitBravery
  Kernel.pbMessage("The Bravery Challenge was forfeited.")
  Kernel.pbMessage(_INTL("You may now flee battles."))
  Kernel.pbMessage("Thank you for participating.")
  $game_switches[357]=false
end
def pbForfeitIronman
  Kernel.pbMessage("The Ironman Challenge was forfeited.")
  Kernel.pbMessage(_INTL("Your save data will no longer be deleted."))
  Kernel.pbMessage("Thank you for participating.")
  $game_switches[584]=false
end

def deleteItemsForfeit
  return if $game_switches[345] || $game_switches[346] || $game_switches[347] || $game_switches[355]
  #$PokemonBag.pbDeleteItem(PBItems::DOLLY)
  #$PokemonBag.pbDeleteItem(PBItems::MACHETE)
  #$PokemonBag.pbDeleteItem(PBItems::ROCKETBOOTS)
  #$PokemonBag.pbDeleteItem(PBItems::JETPACK)
  #$PokemonBag.pbDeleteItem(PBItems::PICKAXE)
  #$PokemonBag.pbDeleteItem(PBItems::TIMECALLER)
  #$PokemonBag.pbDeleteItem(PBItems::STARGATE)
  
  #$PokemonBag.pbDeleteItem(PBItems::LAPRAS)
  #$PokemonBag.pbDeleteItem(PBItems::SCUBAGEAR)
  #$PokemonBag.pbDeleteItem(PBItems::HIKINGBOOTS)
  end

def pbCCTryAddItemPlayer
  if $game_variables[75] > 60
    $PokemonBag.pbStoreItem(PBItems::FULLRESTORE,3)
    $PokemonBag.pbStoreItem(PBItems::FULLHEAL,2)
  elsif $game_variables[75] > 45
    $PokemonBag.pbStoreItem(PBItems::FULLRESTORE,2)
    $PokemonBag.pbStoreItem(PBItems::FULLHEAL,1)
  elsif $game_variables[75] > 30
    $PokemonBag.pbStoreItem(PBItems::HYPERPOTION,2)
  elsif $game_variables[75] > 15
    $PokemonBag.pbStoreItem(PBItems::SUPERPOTION,1)
    $PokemonBag.pbStoreItem(PBItems::FULLHEAL,1)
  else
    $PokemonBag.pbStoreItem(PBItems::POTION,1)
  end
end
def pbCCTryAddItemOpponent
  $game_variables[106]=Array.new
  if $game_variables[75] > 60
    $game_variables[106].push(PBItems::REVIVE)
    $game_variables[106].push(PBItems::REVIVE)
    $game_variables[106].push(PBItems::REVIVE)
    $game_variables[106].push(PBItems::FULLRESTORE)
    $game_variables[106].push(PBItems::FULLRESTORE)
    $game_variables[106].push(PBItems::FULLHEAL)
    $game_variables[106].push(PBItems::FULLHEAL)

  elsif $game_variables[75] > 45
    $game_variables[106].push(PBItems::REVIVE)
    $game_variables[106].push(PBItems::REVIVE)
    $game_variables[106].push(PBItems::FULLRESTORE)
    $game_variables[106].push(PBItems::FULLRESTORE)
    $game_variables[106].push(PBItems::FULLHEAL)

  elsif $game_variables[75] > 30
    $game_variables[106].push(PBItems::REVIVE)
    $game_variables[106].push(PBItems::FULLRESTORE)
    $game_variables[106].push(PBItems::MAXPOTION)
    $game_variables[106].push(PBItems::FULLHEAL)
    $game_variables[106].push(PBItems::FULLHEAL)
  elsif $game_variables[75] > 15
    $game_variables[106].push(PBItems::SUPERPOTION)
    $game_variables[106].push(PBItems::SUPERPOTION)
    $game_variables[106].push(PBItems::FULLHEAL)
  else
    $game_variables[106].push(PBItems::REVIVE)
    $game_variables[106].push(PBItems::POTION)
  end
end

def pbQuantity(argument)
    return $PokemonBag.pbQuantity(argument) if $PokemonBag
    return 0
  end
  
def pbFixSoloMoves
#    j = $Trainer.party[0].moves.length

   # j-=1 if j==3
    i = 0
    if isConst?($Trainer.party[0].species,PBSpecies,:ABRA)

      i = PBMoves::POUND
    end

    if isConst?($Trainer.party[0].species,PBSpecies,:BURMY)
      i = PBMoves::POUND
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:FEEBAS)
      i = PBMoves::TACKLE
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:HOPPIP)
      i = PBMoves::POUND
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:IGGLYPUFF)
      i = PBMoves::POUND
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:MAGIKARP)
      i = PBMoves::TACKLE
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:WYNAUT)
      i = PBMoves::POUND
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:RALTS)
      i = PBMoves::TACKLE
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:GASTLY)
      i = PBMoves::ACIDSPRAY
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:LICKITUNG)
      i = PBMoves::POUND
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:PANPOUR)
      i = PBMoves::TACKLE
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:PANSAGE)
      i = PBMoves::TACKLE
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:PANSEAR)
      i = PBMoves::TACKLE
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:ABRA)
      i = PBMoves::POUND
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:YAMASK)
      i = PBMoves::POUND
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:MAWILE)
      i = PBMoves::TACKLE
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:SMEARGLE)
      i = PBMoves::TACKLE
    end
    if isConst?($Trainer.party[0].species,PBSpecies,:DELTAFEEBAS)
      i = PBMoves::TACKLE
    end

   $Trainer.party[0].moves[1]=PBMove.new(i) if i != 0
  end
  
def isClothing(item)
     return $ItemData[item][10]!=100
    #return false
  end
=begin
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
        eventsString[eventNo][Kernel.quickRenderInt(eventPart)]=s2
        eventPart += 1
      }
      eventNo += 1
    }
    $game_variables[84]=eventsString
    $game_variables[86]=Array.new
    baseString[2].each_line("f") {|s|
      s = s.chomp("f")
      $game_variables[86].push(s)
    }
    
  end
  
  def quickRenderInt(int)
    return 0 if int == 0
    int += 1
    return int
  end
=end
  def pbBuyClothes(type)
  ary=[]
  if type==0
      ary=hatArrayFor(pbGet(16))
    end
    if type==1
      ary=shirtArrayFor(pbGet(16))
    end
    if type==2
      ary=pantsArrayFor(pbGet(16))
    end
        if type==3
      ary=backpackArrayFor(pbGet(16))
    end

    if type==4
      ary=shoesArrayFor(pbGet(16))
    end
    
=begin
    if type==0
      ary=hatArrayFor(pbGet(16))
    end
    if type==1
      ary=coatArrayFor(pbGet(16))
    end
    if type==2
      ary=shirtArrayFor(pbGet(16))
    end
    if type==3
      ary=backpackArrayFor(pbGet(16))
    end
    if type==4
      ary=pantsArrayFor(pbGet(16))
    end
    if type==5
      ary=shoesArrayFor(pbGet(16))
    end
=end
    scene=PokemonMartScene.new
      screen=PokemonMartScreen.new(scene,ary)
      screen.pbBuyScreen
    #pbPokemonMart(ary,false)
end

def hatArrayFor(rank)
  return [PBItems::C_HEADBAND,PBItems::C_MINERSHAT,
    PBItems::C_FEDORA,PBItems::C_POOPHAT,
    PBItems::C_BUGCATCHERHAT,PBItems::C_BERET,
    PBItems::C_BEANIE,PBItems::C_YOUNGSTERCAP,PBItems::C_CATEARS,
    PBItems::C_DEVILHORNS,PBItems::C_SILVERCROWN,PBItems::C_GOLDENCROWN]
end

def coatArrayFor(rank)
  return [PBItems::C_KANTOCOAT]
end

def shirtArrayFor(rank)
  return [PBItems::C_JUMPSUIT,PBItems::C_REDSHIRT,PBItems::C_BLUESHIRT,
    PBItems::C_GREENSHIRT,PBItems::C_PURPLESHIRT,PBItems::C_BLACKSHIRT,PBItems::C_ORANGESHIRT,PBItems::C_PINKSHIRT,
    PBItems::C_YELLOWSHIRT,PBItems::C_ALTERNATESUIT,PBItems::C_LORDSSUIT]
end

def backpackArrayFor(rank)
  return [PBItems::C_PURPLEPACK,PBItems::C_BLACKPACK,
    PBItems::C_BLUEPACK,PBItems::C_GREENPACK,PBItems::C_MAGENTAPACK,
    PBItems::C_ORANGEPACK,PBItems::C_REDPACK,PBItems::C_YELLOWPACK ]

end

def pantsArrayFor(rank)
  return [PBItems::C_JUMPPANTS,PBItems::C_BLUEPANTS,PBItems::C_REDPANTS,
    PBItems::C_GREENPANTS,PBItems::C_GRAYPANTS,PBItems::C_ALTERNATEPANTS,PBItems::C_LORDSPANTS]
end


def shoesArrayFor(rank)
  return [PBItems::C_PURPLEHAIR,PBItems::C_BLUEHAIR,PBItems::C_BROWNHAIR,PBItems::C_BLACKHAIR,
    PBItems::C_REDHAIR,PBItems::C_BLONDHAIR,PBItems::C_GREENHAIR,PBItems::C_PINKHAIR,PBItems::C_CYANHAIR]
end
  
def getEgglockeNames
  ary = []
  temp = Dir.entries("Egglocke/")# rescue nil)
  if temp != nil
    for string in temp
      if string.include?(".txt") && !string.include?("readme.txt")
        string = string[0..-5]
        ary.push(string)
      end
    end
  end
  if ary.length==0
      Kernel.pbMessage("No files were found")
      return false
  end
  return ary
end

def constFromStr(mod,str)
    maxconst=0
    for constant in mod.constants
      maxconst=[maxconst,mod.const_get(constant.to_sym)].max
    end
    for i in 1..maxconst
      val=mod.getName(i)
      next if !val || val==""
      return i if val==str
    end
  return 0
end

def checkIsIDLegal(eggid)
  return false if [PBSpecies::MEW,PBSpecies::ZAPDOS,PBSpecies::MOLTRES,
          PBSpecies::ARTICUNO,PBSpecies::MEWTWO,PBSpecies::RAIKOU,PBSpecies::LUGIA,
          PBSpecies::SUICUNE,PBSpecies::ENTEI,PBSpecies::HOOH,PBSpecies::CELEBI,
          PBSpecies::KYOGRE,PBSpecies::GROUDON,PBSpecies::RAYQUAZA,PBSpecies::REGISTEEL,
          PBSpecies::REGICE,PBSpecies::REGIROCK,PBSpecies::LATIOS,PBSpecies::LATIAS,
          PBSpecies::JIRACHI,PBSpecies::DEOXYS,PBSpecies::DIALGA,PBSpecies::PALKIA,
          PBSpecies::GIRATINA,PBSpecies::REGIGIGAS,PBSpecies::HEATRAN,PBSpecies::UXIE,
          PBSpecies::MESPRIT,PBSpecies::AZELF,PBSpecies::DARKRAI,PBSpecies::SHAYMIN,
          PBSpecies::ARCEUS,PBSpecies::ZEKROM,PBSpecies::KYUREM,PBSpecies::RESHIRAM,
          PBSpecies::THUNDURUS,PBSpecies::LANDORUS,PBSpecies::TORNADUS,PBSpecies::VIRIZION,
          PBSpecies::COBALION,PBSpecies::TERRAKION,PBSpecies::KELDEO,PBSpecies::MELOETTA,
          PBSpecies::GENESECT,PBSpecies::XERNEAS,PBSpecies::YVELTAL,PBSpecies::ZYGARDE,
          PBSpecies::CRESSELIA,PBSpecies::PHIONE,PBSpecies::MANAPHY,PBSpecies::VICTINI,
          PBSpecies::DIANCIE,PBSpecies::VOLCANION,PBSpecies::HOOPA,
          PBSpecies::GENEDYR,PBSpecies::THANARUS,PBSpecies::ASCENADAN,PBSpecies::UFI,
          PBSpecies::FENDRAUGR,PBSpecies::MISSINGNO,PBSpecies::DELTAREGIROCK,
          PBSpecies::DELTAREGICE,PBSpecies::DELTAREGISTEEL,PBSpecies::DELTAHOOPA,
          PBSpecies::DELTAMELOETTA].include?(eggid) ||
          pbGetPreviousForm(eggid) != eggid #||
          #[PBSpecies::DELTADRIFLOON,PBSpecies::DELTAPHANTUMP].include?(eggid)
    return true

  end
    def checkIsIDNonLegend(eggid)
  return false if [PBSpecies::MEW,PBSpecies::ZAPDOS,PBSpecies::MOLTRES,
          PBSpecies::ARTICUNO,PBSpecies::MEWTWO,PBSpecies::RAIKOU,PBSpecies::LUGIA,
          PBSpecies::SUICUNE,PBSpecies::ENTEI,PBSpecies::HOOH,PBSpecies::CELEBI,
          PBSpecies::KYOGRE,PBSpecies::GROUDON,PBSpecies::RAYQUAZA,PBSpecies::REGISTEEL,
          PBSpecies::REGICE,PBSpecies::REGIROCK,PBSpecies::LATIOS,PBSpecies::LATIAS,
          PBSpecies::JIRACHI,PBSpecies::DEOXYS,PBSpecies::DIALGA,PBSpecies::PALKIA,
          PBSpecies::GIRATINA,PBSpecies::REGIGIGAS,PBSpecies::HEATRAN,PBSpecies::UXIE,
          PBSpecies::MESPRIT,PBSpecies::AZELF,PBSpecies::DARKRAI,PBSpecies::SHAYMIN,
          PBSpecies::ARCEUS,PBSpecies::ZEKROM,PBSpecies::KYUREM,PBSpecies::RESHIRAM,
          PBSpecies::THUNDURUS,PBSpecies::LANDORUS,PBSpecies::TORNADUS,PBSpecies::VIRIZION,
          PBSpecies::COBALION,PBSpecies::TERRAKION,PBSpecies::KELDEO,PBSpecies::MELOETTA,
          PBSpecies::GENESECT,PBSpecies::XERNEAS,PBSpecies::YVELTAL,PBSpecies::ZYGARDE,
          PBSpecies::CRESSELIA,PBSpecies::PHIONE,PBSpecies::MANAPHY,PBSpecies::VICTINI,
          PBSpecies::DIANCIE,PBSpecies::VOLCANION,PBSpecies::HOOPA,PBSpecies::UFI,
          PBSpecies::GENEDYR,PBSpecies::THANARUS,PBSpecies::ASCENADAN,
          PBSpecies::FENDRAUGR,PBSpecies::MISSINGNO,PBSpecies::DELTAREGICE,
          PBSpecies::DELTAREGIROCK,PBSpecies::DELTAREGISTEEL,
          PBSpecies::DELTAMELOETTA,PBSpecies::DELTAHOOPA,PBSpecies::UFI].include?(eggid)
    return true

  end


    def isMoveLegalForSpecies(species,move,eggEmerald)
      legality=false
      
      movelist=[]
    atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
    offset=atkdata.getOffset(species-1)
    length=atkdata.getLength(species-1)>>1
    atkdata.pos=offset
    for k in 0..length-1
      level=atkdata.fgetw
      move2=atkdata.fgetw
      movelist.push([level,move2])
    end
    atkdata.close
      #ary=movelist
      for i in 0..movelist.length-1
        if movelist[i][1] == move && movelist[i][0] <2
          legality=true 
          break
        end
      end
      if !legality
   #   pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
=begin
     f.pos=(species-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         atk=f.fgetw
         legality=true if atk == move
         break if atk == move
       end
     end
=end
#        Kernel.pbMessage(PBMoves.getName(move))

        eggEmerald.pos=(species-1)*8
        offset=eggEmerald.fgetdw
        length=eggEmerald.fgetdw
        if length>0
        eggEmerald.pos=offset
        first=true
        j=0; loop do break unless j<length
 #       Kernel.pbMessage(PBMoves.getName(move))
          atk=eggEmerald.fgetw
#                  Kernel.pbMessage(PBMoves.getName(atk))

          legality=true if atk == move
           break if atk == move
          j+=1
        end
      end

 # }
 end
      return legality
    end
    
def checkIsItemLegal(itemid)
  return true if [PBItems::FIRESTONE,
  PBItems::THUNDERSTONE,PBItems::LEAFSTONE,PBItems::WATERSTONE,
  PBItems::MOONSTONE,PBItems::SUNSTONE,PBItems::DUSKSTONE,PBItems::DAWNSTONE,
  PBItems::SHINYSTONE,PBItems::ODDKEYSTONE,PBItems::BIGPEARL,
  PBItems::AIRBALLOON,PBItems::EVIOLITE,PBItems::FLOATSTONE,
  PBItems::DESTINYKNOT,PBItems::ROCKYHELMET,PBItems::EJECTBUTTON,
  PBItems::REDCARD,PBItems::SHEDSHELL,PBItems::SMOKEBALL,
  PBItems::LUCKYEGG,PBItems::EXPSHARE,PBItems::AMULETCOIN,
  PBItems::SOOTHEBELL,PBItems::CLEANSETAG,PBItems::CHOICEBAND,
  PBItems::CHOICESCARF,PBItems::CHOICESPECS,PBItems::HEATROCK,
  PBItems::DAMPROCK,PBItems::SMOOTHROCK,PBItems::ICYROCK,PBItems::LIGHTCLAY,
  PBItems::GRIPCLAW,PBItems::BINDINGBAND,PBItems::BIGROOT,PBItems::BLACKSLUDGE,
  PBItems::LEFTOVERS,PBItems::SHELLBELL,PBItems::MENTALHERB,PBItems::WHITEHERB,
  PBItems::POWERHERB,PBItems::ABSORBBULB,PBItems::CELLBATTERY,PBItems::LIFEORB,
  PBItems::EXPERTBELT,PBItems::METRONOME,PBItems::MUSCLEBAND,PBItems::WISEGLASSES,
  PBItems::RAZORCLAW,PBItems::SCOPELENS,PBItems::WIDELENS,PBItems::ZOOMLENS,
  PBItems::KINGSROCK,PBItems::RAZORFANG,PBItems::LAGGINGTAIL,PBItems::QUICKCLAW,
  PBItems::FOCUSBAND,PBItems::FOCUSSASH,PBItems::FLAMEORB,PBItems::TOXICORB,
  PBItems::STICKYBARB,PBItems::IRONBALL,PBItems::RINGTARGET,PBItems::MACHOBRACE,
  PBItems::POWERWEIGHT,PBItems::POWERBRACER,PBItems::POWERBELT,PBItems::POWERLENS,
  PBItems::POWERBAND,PBItems::POWERANKLET,PBItems::LAXINCENSE,PBItems::FULLINCENSE,
  PBItems::LUCKINCENSE,PBItems::FULLINCENSE,PBItems::SEAINCENSE,PBItems::PUREINCENSE,
  PBItems::WAVEINCENSE,PBItems::ROSEINCENSE,PBItems::ODDINCENSE,
  PBItems::ROCKINCENSE,PBItems::CHARCOAL,PBItems::MYSTICWATER,PBItems::MAGNET,
  PBItems::MIRACLESEED,PBItems::NEVERMELTICE,PBItems::BLACKBELT,PBItems::POISONBARB,
  PBItems::SOFTSAND,PBItems::SHARPBEAK,PBItems::TWISTEDSPOON,PBItems::SILVERPOWDER,
  PBItems::HARDSTONE,PBItems::SPELLTAG,PBItems::DRAGONFANG,PBItems::BLACKGLASSES,
  PBItems::METALCOAT,PBItems::SILKSCARF,PBItems::FLAMEPLATE,PBItems::SPLASHPLATE,
  PBItems::ZAPPLATE,PBItems::MEADOWPLATE,PBItems::ICICLEPLATE,PBItems::FISTPLATE,
  PBItems::TOXICPLATE,PBItems::EARTHPLATE,PBItems::SKYPLATE,PBItems::MINDPLATE,
  PBItems::INSECTPLATE,PBItems::STONEPLATE,PBItems::SPOOKYPLATE,PBItems::DRACOPLATE,
  PBItems::PIXIEPLATE,PBItems::DREADPLATE,PBItems::IRONPLATE,PBItems::FIREGEM,PBItems::ELECTRICGEM,PBItems::GRASSGEM,
  PBItems::ICEGEM,PBItems::FIGHTINGGEM,PBItems::POISONGEM,PBItems::GROUNDGEM,PBItems::FLYINGGEM,
  PBItems::PSYCHICGEM,PBItems::BUGGEM,PBItems::ROCKGEM,PBItems::GHOSTGEM,PBItems::DRAGONGEM,
  PBItems::DARKGEM,PBItems::STEELGEM,PBItems::NORMALGEM,PBItems::LIGHTBALL,
  PBItems::LUCKYPUNCH,PBItems::METALPOWDER,PBItems::QUICKPOWDER,PBItems::THICKCLUB,
  PBItems::DEEPSEATOOTH,PBItems::DEEPSEASCALE,PBItems::EVERSTONE,PBItems::DRAGONSCALE,
  PBItems::UPGRADE,PBItems::DUBIOUSDISC,PBItems::PROTECTOR,PBItems::ELECTIRIZER,PBItems::MAGMARIZER,
  PBItems::REAPERCLOTH,PBItems::PRISMSCALE,PBItems::OVALSTONE,PBItems::BERRYJUICE,
  PBItems::LEMONADE,PBItems::MAXELIXIR,PBItems::PPMAX,PBItems::HPUP,
  PBItems::PROTEIN,PBItems::IRON,PBItems::CALCIUM,PBItems::ZINC,PBItems::CARBOS,
  PBItems::RARECANDY,PBItems::MASTERBALL,PBItems::ULTRABALL,PBItems::POKEBALL,
  PBItems::CHERIBERRY,PBItems::CHESTOBERRY,PBItems::PECHABERRY,PBItems::RAWSTBERRY,
  PBItems::ASPEARBERRY,PBItems::LEPPABERRY,PBItems::ORANBERRY,PBItems::LUMBERRY,
  PBItems::OCCABERRY,PBItems::PASSHOBERRY,PBItems::WACANBERRY,PBItems::RINDOBERRY,PBItems::YACHEBERRY,
  PBItems::CHOPLEBERRY,PBItems::KEBIABERRY,PBItems::SHUCABERRY,PBItems::COBABERRY,
  PBItems::PAYAPABERRY,PBItems::TANGABERRY,PBItems::CHARTIBERRY,
  PBItems::HABANBERRY,PBItems::COLBURBERRY,PBItems::BABIRIBERRY,PBItems::CHILANBERRY,
  PBItems::LIECHIBERRY,PBItems::GANLONBERRY,PBItems::SALACBERRY,PBItems::PETAYABERRY,
  PBItems::APICOTBERRY,PBItems::LANSATBERRY,PBItems::STARFBERRY,PBItems::ENIGMABERRY,
  PBItems::MICLEBERRY,PBItems::CUSTAPBERRY,PBItems::JABOCABERRY,PBItems::ROWAPBERRY,
  PBItems::XATTACK3,PBItems::XDEFEND3,PBItems::XSPECIAL3,PBItems::XSPDEF3,PBItems::XSPEED3,
  PBItems::XACCURACY3,PBItems::DIREHIT3,PBItems::GUARDSPEC,PBItems::ABOMASITE,
  PBItems::HERACROSSITE,PBItems::ABSOLITE,PBItems::AERODACTYLITE,PBItems::AGGRONITE,
  PBItems::ALAKAZITE,PBItems::AMPHAROSITE,PBItems::BANNETITE,PBItems::BLASTOISITE,PBItems::BLAZIKENITE,
  PBItems::CHARIZARDITEX,PBItems::CHARIZARDITEY,PBItems::GARCHOMPITE,PBItems::GARDEVOIRITE,
  PBItems::GENGARITE,PBItems::GYARADOSITE,PBItems::HOUNDOOMITE,PBItems::KANGASKHANITE,
  PBItems::LUCARIONITE,PBItems::MANECTRITE,PBItems::MAWILITE,PBItems::MEDICHAMITE,PBItems::SCIZORITE,
  PBItems::PINSIRITE,PBItems::TYRANITARITE,PBItems::VENUSAURITE,PBItems::SCEPTITE,PBItems::SWAMPERTITE,
  PBItems::TYPHLOSIONITE,PBItems::FERALIGATITE,PBItems::MEGANIUMITE,
  PBItems::CACTURNITE,PBItems::CRAWDITE,PBItems::BISHARPITE,
  PBItems::STEELIXITE,PBItems::MILOTITE,PBItems::DELTACHARIZARDITE,PBItems::DELTABLASTOISINITE,PBItems::DELTAVENUSAURITE,PBItems::REUNICLITE,
  PBItems::GALLADITE,PBItems::ASSAULTVEST,PBItems::ALTARITE,PBItems::PIDGEOTITE,
  PBItems::GALLADITE].include?(itemid) || Kernel.pbGetMegaStoneList.include?(itemid) ||
  (itemid >= 288 && itemid <= 382)
  #288-382
  return false
  
end

def pbGetRandomPoke
  deltaAry=[]
  for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
    deltaAry.push(i)
  end
  species=rand(722+deltaAry.length)
  species = 1 if species == 0;
  if species>PBSpecies::VOLCANION
    species=deltaAry[species-722]
  end
  return species
end

def pbCheckForRandomItem(item,escape=false)
  # Exclusions made for...
  # Quest items (never randomized or put into the randomizer pool)
  blacklist=[
    PBItems::MYSTERIOUSSCROLL,
    PBItems::PERSEPHONEPACKAGE,
    PBItems::HIKERSITEM,
    PBItems::ITEM1,
    PBItems::TAXIPIECE,
    PBItems::ITEM2,
    PBItems::ITEM3,
    PBItems::ITEM4,
    PBItems::ITEM5,
    PBItems::ITEM6,
    PBItems::ITEM7
  ]
  if !escape
    # Key items (never randomized or put into the randomizer pool)
    if $game_switches[321] && !blacklist.include?(item) && !pbIsMachine?(item) &&
       $ItemData[item][ITEMPOCKET]!=8 && $ItemData[item][ITEMPOCKET]!=7
      itemAry=[]
      # Random broken Master Ball item
      for i in PBItems::REPEL...PBItems::MASTERBALL2
        itemAry.push(i)
      end
      # Poke Balls (only put into pool after entering Telnor Town the first time)
      if $game_switches[37]
        for i in PBItems::ULTRABALL..PBItems::MOONBALL
          itemAry.push(i)
        end
        itemAry.push(PBItems::NUZLOCKEBALL)
        itemAry.push(PBItems::SNOREBALL)
        itemAry.push(PBItems::ANCIENTBALL)
        itemAry.push(PBItems::DELTABALL)
        itemAry.push(PBItems::SHINYBALL)
        itemAry.push(PBItems::MASTERBALL)
      end
      # Mail (never put into randomizer pool)
      for i in PBItems::CHERIBERRY..PBItems::ROWAPBERRY
        itemAry.push(i)
      end
      for i in PBItems::XATTACK2..PBItems::POKETOY
        itemAry.push(i)
      end
      itemAry.push(PBItems::IVSTONE)
      # ZO items (never put into randomizer pool)
      itemAry.push(PBItems::DREAMMIST)
      for i in PBItems::SCIZORITE..PBItems::CACTURNITE
        itemAry.push(i) if pbCheckMegaStones(i)
      end
      for i in PBItems::REUNICLITE..PBItems::BISHARPITE
        itemAry.push(i) if pbCheckMegaStones(i)
      end
      itemAry.push(PBItems::AGGRONITE) if pbCheckMegaStones(PBItems::AGGRONITE)
      itemAry.push(PBItems::ABOMASITE) if pbCheckMegaStones(PBItems::ABOMASITE)
      itemAry.push(PBItems::ABILITYCAPSULE)
      for i in PBItems::TYPHLOSIONITE..PBItems::KANGASKHANITE
        itemAry.push(i) if pbIsMegaStone?(i) && pbCheckMegaStones(i)
      end
      itemAry.push(PBItems::CRAWDITE) if pbCheckMegaStones(PBItems::CRAWDITE)
      itemAry.push(PBItems::WEAKNESSPOLICY)
      itemAry.push(PBItems::LATIOSITE) if pbCheckMegaStones(PBItems::LATIOSITE)
      itemAry.push(PBItems::LATIASITE) if pbCheckMegaStones(PBItems::LATIASITE)
      itemAry.push(PBItems::MILOTITE) if pbCheckMegaStones(PBItems::MILOTITE)
      itemAry.push(PBItems::ASSAULTVEST)
      itemAry.push(PBItems::SACHET)
      itemAry.push(PBItems::WHIPPEDDREAM)
      # Clothes (never put into randomizer pool)
      for i in PBItems::EEVITE..PBItems::SLOWBRONITE
        itemAry.push(i) if pbIsMegaStone?(i) && pbCheckMegaStones(i)
      end
      itemAry.push(PBItems::PIXIEPLATE)
      itemAry.push(PBItems::GIRAFARIGITE) if pbCheckMegaStones(PBItems::GIRAFARIGITE)
      itemAry.push(PBItems::SUNFLORITE) if pbCheckMegaStones(PBItems::SUNFLORITE)
      itemAry.push(PBItems::DIANCITE) if pbCheckMegaStones(PBItems::DIANCITE)
      itemAry.push(PBItems::ZORONITE) if pbCheckMegaStones(PBItems::ZORONITE)
      itemAry.push(PBItems::DELTABISHARPITE) if pbCheckMegaStones(PBItems::DELTABISHARPITE)
      itemAry.push(PBItems::STUNFISKITE) if pbCheckMegaStones(PBItems::STUNFISKITE)
      itemAry.push(PBItems::ZEBSTRIKITE) if pbCheckMegaStones(PBItems::ZEBSTRIKITE)
      itemAry.push(PBItems::DELTAGARDEVOIRITE) if pbCheckMegaStones(PBItems::DELTAGARDEVOIRITE)
      for i in PBItems::ZEKROMMACHINE..PBItems::FLYGONMACHINE
        itemAry.push(i)
      end
      for i in PBItems::CAMERUPTITE..PBItems::GALLADITE
        itemAry.push(i) if pbIsMegaStone?(i) && pbCheckMegaStones(i)
      end
      itemAry.push(PBItems::SAFETYGOGGLES)
      itemAry.push(PBItems::JIRACHITE) if pbCheckMegaStones(PBItems::JIRACHITE)
      for i in PBItems::TRICKROCK..PBItems::SAILFOSSIL
        itemAry.push(i)
      end
      itemAry.push(PBItems::BLUEORB)
      itemAry.push(PBItems::REDORB)
      for i in PBItems::DELTASCIZORITE..PBItems::SPIRITOMBITE
        itemAry.push(i) if pbCheckMegaStones(i)
      end
      for i in PBItems::SPICYCURRY..PBItems::SPEEDPILL
        itemAry.push(i)
      end
      itemAry.push(PBItems::MILTANKITE) if pbIsMegaStone?(i) && pbCheckMegaStones(i)
      itemAry.push(PBItems::DELTAGALLADITE) if pbCheckMegaStones(PBItems::DELTAGALLADITE)
      itemAry.push(PBItems::CRYOGONITE) if pbCheckMegaStones(PBItems::CRYOGONITE)
      itemAry.push(PBItems::HYDREIGONITE) if pbCheckMegaStones(PBItems::HYDREIGONITE)
      itemAry.push(PBItems::CRYSTALPIECE)
      for i in PBItems::DELTASUNFLORITE..PBItems::POLIWRATHITE
        itemAry.push(i) if pbCheckMegaStones(i)
      end
      itemAry.push(PBItems::DVOLCARONAARMOR)
      for i in PBItems::DELTAMILOTICITE..PBItems::DELTAMETAGROSSITE2
        itemAry.push(i) if pbIsMegaStone?(i) && pbCheckMegaStones(i)
      end
      itemAry.push(PBItems::DELTAMAWILITE) if pbCheckMegaStones(PBItems::DELTAMAWILITE)
      itemAry.push(PBItems::DELTAMEDICHAMITE) if pbCheckMegaStones(PBItems::DELTAMEDICHAMITE)
      for i in PBItems::NOCTURNEINCENSE..PBItems::ROSELIBERRY
        itemAry.push(i)
      end
      itemAry.push(PBItems::FAIRYGEM)
      itemAry.push(PBItems::CRYSTALFRAGMENT) if pbCheckMegaStones(PBItems::DELTABISHARPITE)
        
      item=itemAry[rand(itemAry.length)]
      
    # TMs (randomized but only put into the randomizer pool when receiving a TM/HM that hasn't been picked up yet)
    elsif $game_switches[321] && pbIsMachine?(item)
      tmAry=[]
      pocket=$PokemonBag.pockets[4]
      for i in PBItems::TM01..PBItems::HM06
        tmAry.push(i) if pocket.length==0 || !pocket.flatten.include?(i)
      end
      for i in PBItems::TMH1..PBItems::TMH9
        tmAry.push(i) if pocket.length==0 || !pocket.flatten.include?(i)
      end
      tmAry.push(PBItems::TM96) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM96)
      for i in PBItems::TM107..PBItems::TM124
        tmAry.push(i) if pocket.length==0 || !pocket.flatten.include?(i)
      end
      tmAry.push(PBItems::TM125) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM125)
      tmAry.push(PBItems::TM126) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM126)
      tmAry.push(PBItems::TM127) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM127)
      tmAry.push(PBItems::TM128) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM128)
      tmAry.push(PBItems::TM129) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM129)
      tmAry.push(PBItems::TM130) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM130)
      item=tmAry[rand(tmAry.length)] if tmAry.length>0
    else
      # Do not change item
    end
  end
  return item
end

def pbCheckMegaStones(item)
  pocket=$PokemonBag.pockets[6]
  return true if (pocket.length==0 || !pocket.flatten.include?(item)) && !$game_variables[196].flatten.include?(item)
  return false
end

def pbSetRandomTrade(num,tradetype1=0,tradetype2=0)
  # Request
  if !$game_variables[194].is_a?(Array)
    $game_variables[194]=[]
  end
  # Offer
  if !$game_variables[195].is_a?(Array)
    $game_variables[195]=[]
  end
  # 0 - Pokemon for Pokemon trade
  # 1 - Type for Pokemon trade
  # 2 - Any for Pokemon trade
  # 3 - Specific level for Pokemon trade
  tradetypes=[tradetype1,tradetype2]
  results=[]
  for j in 0...2
    if tradetypes[j]==0
      results[j]=pbGetRandomPoke
    elsif tradetypes[j]==1
      types=[]
      for set1 in 0...9
        types.push(set1)
      end
      for set2 in 10...18
        types.push(set2)
      end
      types.push(21)
      results[j]=types[rand(types.length)]
    elsif tradetypes[j]==2
      results[j]=-1
    elsif tradetypes[j]==3
      results[j]=rand(90)+1
    end
  end
  $game_variables[194][num]=results[0]
  $game_variables[195][num]=results[1]
end

def pbSetRandomMart
  stocklist=[]
  stocklist[0]=[:POTION,:SUPERPOTION,:HYPERPOTION,:ESCAPEROPE,
    :REPEL,:SUPERREPEL,:ICEHEAL,:BURNHEAL,:PARALYZHEAL,:FULLHEAL]
  stocklist[1]=[:POKEBALL,:GREATBALL,:DIVEBALL,:NETBALL,
    :TIMERBALL,:LEVELBALL,:LUXURYBALL,:LUREBALL,:MOONBALL,:FRIENDBALL,
    :LOVEBALL,:HEAVYBALL,:FASTBALL,:REPEATBALL,:HEALBALL,:NESTBALL]
  stocklist[2]=[:SMOKEBALL,:FULLINCENSE,:LAXINCENSE,:LUCKINCENSE,
    :ODDINCENSE,:PUREINCENSE,:ROCKINCENSE,
    :ROSEINCENSE,:SEAINCENSE,:WAVEINCENSE]
  stocklist[3]=[:TM17,:TM21,:TM39,:TM56,:TM82,:TM83,:TM95]
  stocklist[4]=[:HPUP,:PROTEIN,
    :IRON,:CALCIUM,:ZINC,:CARBOS,
    :POWERWEIGHT,:POWERBRACER,:POWERBELT,
    :POWERLENS,:POWERBAND,:POWERANKLET,
    :MACHOBRACE,:HEALTHWING,:MUSCLEWING,
    :RESISTWING,:GENIUSWING,:CLEVERWING,
    :SWIFTWING,:POMEGBERRY,:KELPSYBERRY,
    :QUALOTBERRY,:HONDEWBERRY,:GREPABERRY,
    :TAMATOBERRY]
  stocklist[5]=[:AIRBALLOON,:TOXICORB,:MENTALHERB,
    :POWERHERB,:WHITEHERB,:ABSORBBULB,
    :BERSERKGENE,:EXPERTBELT,:METRONOME,
    :SCOPELENS,:WIDELENS,:ZOOMLENS,
    :QUICKCLAW,:LAGGINGTAIL,:FOCUSBAND,
    :FOCUSSASH,:FLAMEORB,:AMULETCOIN,
    :REDCARD,:EJECTBUTTON,:ROCKYHELMET]
  stocklist[6]=[:DEEPSEASCALE,:DEEPSEATOOTH,:NEVERMELTICE,:DRAGONFANG,
    :ELECTIRIZER,:MAGMARIZER,:KINGSROCK,
    :PROTECTOR,:RAZORFANG,:RAZORCLAW,:UPGRADE,
    :DUBIOUSDISC,:PRISMSCALE,:SOOTHEBELL,:METALCOAT,:DRAGONSCALE,:REAPERCLOTH,
    :CLEANSETAG,:OVALSTONE]
  stocklist[7]=[:FIRESTONE,:THUNDERSTONE,
    :WATERSTONE,:LEAFSTONE,
    :MOONSTONE,:SUNSTONE,
    :SHINYSTONE,:DAWNSTONE,
    :DUSKSTONE,:EVERSTONE]
  stocklist[8]=[PBItems::MOOMOOMILK,
    PBItems::LIGHTBALL,PBItems::BLACKSLUDGE,PBItems::SHOCKDRIVE,
    PBItems::KINGSROCK,PBItems::WHIPPEDDREAM]
  stocklist[9]=[PBItems::ROCKGEM,
    PBItems::EXPSHARE,PBItems::ULTRABALL,
    PBItems::SUPERROD,PBItems::BURNDRIVE,
    PBItems::ENERGYROOT,PBItems::THICKCLUB]
  stocklist[10]=[PBItems::BIGROOT,PBItems::HEALPOWDER,PBItems::TIMERBALL,
    PBItems::CHILLDRIVE,PBItems::SACHET,PBItems::STICK]
  stocklist[11]=[PBItems::SKULLFOSSIL,PBItems::ICEHEAL,
    PBItems::OVALCHARM,PBItems::DUSKBALL,PBItems::DOUSEDRIVE,
    PBItems::ENERGYPOWDER,PBItems::ARMORFOSSIL]
  stocklist[12]=[PBItems::TYRANITARMACHINE,PBItems::LEAVANNYMACHINE,PBItems::FLYGONMACHINE]
  stocklist[13]=[PBItems::CHOICESCARF,PBItems::CHOICEBAND,PBItems::CHOICESPECS,
    PBItems::LIFEORB,PBItems::AMPHAROSITE,PBItems::SLOWBRONITE,
    PBItems::DONPHANITE,PBItems::ABILITYCAPSULE]
  stocklist[14]=[PBItems::TM36,PBItems::TM42,PBItems::TM75,PBItems::TM86,PBItems::TM88]
  stocklist[15]=[PBItems::MOOMOOMILK]
  stocklist[16]=[PBItems::ENERGYROOT,PBItems::ENERGYPOWDER,PBItems::REVIVALHERB,PBItems::HEALPOWDER]
  stocklist[17]=[PBItems::KANGASKHANITE,PBItems::SWAMPERTITE,
    PBItems::CAMERUPTITE,PBItems::LOPUNNITE,PBItems::GARDEVOIRITE,
    PBItems::GALLADITE,PBItems::MEDICHAMITE,PBItems::BANNETITE]
  stocklist[18]=[PBItems::XATTACK,PBItems::XDEFEND,PBItems::XSPEED,
    PBItems::XSPECIAL,PBItems::XSPDEF,PBItems::XACCURACY]
  stocklist[19]=[PBItems::BLUEFLUTE,PBItems::REDFLUTE,PBItems::YELLOWFLUTE,
    PBItems::ITEMURGE,PBItems::ABILITYURGE,PBItems::ITEMDROP]
  stocklist[20]=[PBItems::THICKCLUB,PBItems::LUCKYPUNCH,PBItems::LIGHTBALL,
    PBItems::QUICKPOWDER,PBItems::METALPOWDER,PBItems::STICK,PBItems::SOULDEW]
  stocklist[21]=[PBItems::TM40,PBItems::TM111,PBItems::TM112,PBItems::TM113,PBItems::TM114,PBItems::HM04]
  stocklist[22]=[PBItems::MACHOBRACE,PBItems::DESTINYKNOT,
    PBItems::BLASTOISITE,PBItems::DELTABLASTOISINITE,PBItems::CHARIZARDITEY,
    PBItems::DELTACHARIZARDITE,PBItems::EEVITE,PBItems::VENUSAURITE,PBItems::DELTAVENUSAURITE]
  stocklist[23]=[PBItems::BINDINGBAND,PBItems::RINGTARGET,PBItems::DAMPROCK,
    PBItems::HEATROCK,PBItems::SMOOTHROCK,PBItems::ICYROCK,PBItems::DARKROCK,
    PBItems::TRICKROCK,PBItems::BRIGHTPOWDER,PBItems::SHELLBELL,PBItems::IRONBALL,
    PBItems::LIGHTCLAY,PBItems::MUSCLEBAND,PBItems::WISEGLASSES,PBItems::CELLBATTERY,
    PBItems::EVIOLITE,PBItems::ASSAULTVEST,PBItems::SAFETYGOGGLES,
    PBItems::WEAKNESSPOLICY,PBItems::STICKYBARB,PBItems::LUMINOUSMOSS]
  stocklist[24]=[PBItems::NORMALGEM,PBItems::FIREGEM,PBItems::WATERGEM,
    PBItems::GRASSGEM,PBItems::ELECTRICGEM,PBItems::GROUNDGEM,PBItems::ROCKGEM,
    PBItems::ICEGEM,PBItems::FLYINGGEM,PBItems::BUGGEM,PBItems::POISONGEM,
    PBItems::FIGHTINGGEM,PBItems::PSYCHICGEM,PBItems::GHOSTGEM,PBItems::DRAGONGEM,
    PBItems::DARKGEM,PBItems::STEELGEM,PBItems::FAIRYGEM]
  stocklist[25]=[PBItems::SILKSCARF,PBItems::CHARCOAL,PBItems::MYSTICWATER,
    PBItems::MIRACLESEED,PBItems::MAGNET,PBItems::SOFTSAND,PBItems::HARDSTONE,
    PBItems::NEVERMELTICE,PBItems::SHARPBEAK,PBItems::SILVERPOWDER,
    PBItems::POISONBARB,PBItems::BLACKBELT,PBItems::TWISTEDSPOON,PBItems::SPELLTAG,
    PBItems::DRAGONFANG,PBItems::BLACKGLASSES,PBItems::METALCOAT]
  stocklist[26]=[PBItems::BABIRIBERRY,PBItems::CHARTIBERRY,PBItems::CHILANBERRY,
    PBItems::CHOPLEBERRY,PBItems::COBABERRY,PBItems::COLBURBERRY,
    PBItems::HABANBERRY,PBItems::KASIBBERRY,PBItems::KEBIABERRY,PBItems::OCCABERRY,
    PBItems::PASSHOBERRY,PBItems::PAYAPABERRY,PBItems::RINDOBERRY,
    PBItems::SHUCABERRY,PBItems::TANGABERRY,PBItems::WACANBERRY,
    PBItems::YACHEBERRY,PBItems::ROSELIBERRY]
  stocklist[27]=[PBItems::ORANBERRY,PBItems::PECHABERRY,PBItems::CHERIBERRY,
    PBItems::CHESTOBERRY,PBItems::RAWSTBERRY,PBItems::ASPEARBERRY,
    PBItems::PERSIMBERRY,PBItems::LEPPABERRY,PBItems::SITRUSBERRY,
    PBItems::FIGYBERRY,PBItems::WIKIBERRY,PBItems::MAGOBERRY,PBItems::AGUAVBERRY,
    PBItems::IAPAPABERRY,PBItems::ENIGMABERRY,PBItems::MICLEBERRY,
    PBItems::JABOCABERRY,PBItems::ROWAPBERRY,PBItems::LANSATBERRY,
    PBItems::STARFBERRY,PBItems::LIECHIBERRY,PBItems::GANLONBERRY,
    PBItems::PETAYABERRY,PBItems::APICOTBERRY,PBItems::SALACBERRY,
    PBItems::LUMBERRY,PBItems::CUSTAPBERRY,PBItems::ENIGMABERRY,PBItems::KEEBERRY,
    PBItems::MARANGABERRY]
  stocklist[28]=[PBItems::FLAMEPLATE,PBItems::SPLASHPLATE,PBItems::ZAPPLATE,
    PBItems::MEADOWPLATE,PBItems::ICICLEPLATE,PBItems::FISTPLATE,PBItems::TOXICPLATE,
    PBItems::EARTHPLATE,PBItems::SKYPLATE,PBItems::MINDPLATE,PBItems::INSECTPLATE,
    PBItems::STONEPLATE,PBItems::SPOOKYPLATE,PBItems::DRACOPLATE,
    PBItems::DREADPLATE,PBItems::IRONPLATE]
  
  newStock=[]
  if !$game_variables[196].is_a?(Array)
    $game_variables[196]=[]
  end
  for i in 0...stocklist.length
    $game_variables[196][i]=[]
    for j in 0...stocklist[i].length
      stocklist[i][j]=getID(PBItems,stocklist[i][j]) if !stocklist[i][j].is_a?(Integer)
    end
  end
  if $game_switches[321]
    for i in 0...stocklist.length
      $game_variables[196][i]=[]
      newStockRow=[]
      for j in 0...stocklist[i].length
        stocklist[i][j]=getID(PBItems,stocklist[i][j]) if !stocklist[i][j].is_a?(Integer)
        doAgain=true
        if i===0 && j==0
          newStockRow[j]=pbCheckForRandomItem(stocklist[i][j])
          doAgain=false
        end
        while doAgain
          newItem=pbCheckForRandomItem(stocklist[i][j])
          if (pbIsMachine?(newItem) || pbIsMegaStone?(newItem))
            if pbIsMachine?(newItem)
              pocket=$PokemonBag.pockets[4]
              tmAry=[]
              for k in PBItems::TM01..PBItems::HM06
                tmAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              for k in PBItems::TMH1..PBItems::TMH9
                tmAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              tmAry.push(PBItems::TM96) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM96)
              for k in PBItems::TM107..PBItems::TM124
                tmAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              tmAry.push(PBItems::TM125) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM125)
              tmAry.push(PBItems::TM126) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM126)
              tmAry.push(PBItems::TM127) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM127)
              tmAry.push(PBItems::TM128) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM128)
              tmAry.push(PBItems::TM129) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM129)
              tmAry.push(PBItems::TM130) if pocket.length==0 || !pocket.flatten.include?(PBItems::TM130)   
              
              if tmAry.length>0 && !newStock.flatten.include?(newItem) && 
                 !newStockRow.include?(newItem)
                newItem=newItem
                newStockRow[j]=newItem
                doAgain=false
              else
                newItem=pbCheckForRandomItem(PBItems::RARECANDY)
                newStockRow[j]=newItem
                doAgain=false
              end
            elsif pbIsMegaStone?(newItem)
              pocket=$PokemonBag.pockets[6]
              stoneAry=[]
              for k in PBItems::SCIZORITE..PBItems::CACTURNITE
                stoneAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              for k in PBItems::REUNICLITE..PBItems::BISHARPITE
                stoneAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              stoneAry.push(PBItems::AGGRONITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::AGGRONITE)
              stoneAry.push(PBItems::ABOMASITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::ABOMASITE)
              for k in PBItems::TYPHLOSIONITE..PBItems::KANGASKHANITE
                stoneAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              stoneAry.push(PBItems::CRAWDITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::CRAWDITE)
              stoneAry.push(PBItems::LATIOSITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::LATIOSITE)
              stoneAry.push(PBItems::LATIASITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::LATIASITE)
              stoneAry.push(PBItems::MILOTITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::MILOTITE)
              for k in PBItems::EEVITE..PBItems::SLOWBRONITE
                stoneAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              stoneAry.push(PBItems::GIRAFARIGITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::GIRAFARIGITE)
              stoneAry.push(PBItems::SUNFLORITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::SUNFLORITE)
              stoneAry.push(PBItems::DIANCITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::DIANCITE)
              stoneAry.push(PBItems::ZORONITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::ZORONITE)
              stoneAry.push(PBItems::DELTABISHARPITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::DELTABISHARPITE)
              stoneAry.push(PBItems::STUNFISKITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::STUNFISKITE)
              stoneAry.push(PBItems::ZEBSTRIKITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::STUNFISKITE)
              stoneAry.push(PBItems::DELTAGARDEVOIRITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::STUNFISKITE)
              for k in PBItems::CAMERUPTITE..PBItems::GALLADITE
                stoneAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              stoneAry.push(PBItems::JIRACHITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::JIRACHITE)
              for k in PBItems::DELTASCIZORITE..PBItems::SPIRITOMBITE
                stoneAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              stoneAry.push(PBItems::MILTANKITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::MILTANKITE)
              stoneAry.push(PBItems::DELTAGALLADITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::DELTAGALLADITE)
              stoneAry.push(PBItems::CRYOGONITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::CRYOGONITE)
              stoneAry.push(PBItems::HYDREIGONITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::HYDREIGONITE)
              for k in PBItems::DELTASUNFLORITE..PBItems::POLIWRATHITE
                stoneAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              for k in PBItems::DELTAMILOTICITE..PBItems::DELTAMETAGROSSITE2
                stoneAry.push(k) if pocket.length==0 || !pocket.flatten.include?(k)
              end
              stoneAry.push(PBItems::DELTAMAWILITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::DELTAMAWILITE)
              stoneAry.push(PBItems::DELTAMEDICHAMITE) if pocket.length==0 || !pocket.flatten.include?(PBItems::DELTAMEDICHAMITE)
              stoneAry.push(PBItems::CRYSTALFRAGMENT) if pocket.length==0 || !pocket.flatten.include?(PBItems::CRYSTALFRAGMENT)
              
              if stoneAry.length>0 && !newStock.flatten.include?(newItem) && 
                 !newStockRow.include?(newItem)
                newItem=newItem
                newStockRow[j]=newItem
                doAgain=false
              else
                newItem=pbCheckForRandomItem(PBItems::RARECANDY)
                newStockRow[j]=newItem
                doAgain=false
              end
            end
          elsif !newStockRow.include?(newItem)
            newStockRow[j]=newItem
            doAgain=false
          end
        end
      end
      newStock[i]=newStockRow
      $game_variables[196][i]=newStock[i]
    end
  else
    for i in 0...stocklist.length
      $game_variables[196][i]=[]
      for j in 0...stocklist[i].length
        stocklist[i][j]=getID(PBItems,stocklist[i][j]) if !stocklist[i][j].is_a?(Integer)
      end
      $game_variables[196][i]=stocklist[i]
    end
  end
end

def getEggsFromFile(string,ignore=false)
  records=[]
  constants=""
  itemnames=[]
  itemdescs=[]
  maxValue=0
  eggs=[]
  numberline = 0
  eggEmerald=File.open("Data/eggEmerald.dat","rb")
  shittyloop2=["Hi"]
  for shittyloop in shittyloop2
      temp=false
      pbCompilerEachPreppedLine("Egglocke/"+string+".txt"){|line,lineno|
      linerecord=pbGetCsvRecord(line,lineno,[0,"vsuunnuuuuuuiiii"])#vnsuusuuUN"])
      if temp==false
       numberline += 1
      else
       temp=false
      end
      eggs[numberline] = Array.new
       if linerecord[0]!="" && linerecord[0]
         if linerecord[0].to_i == 0
          return "Error on line "+numberline.to_s+", the first part. Could not read, or not a number." if !ignore
          temp=true
          break
         end
         if !checkIsIDLegal(linerecord[0].to_i)
          return "Pokemon species "+PBSpecies.getName(linerecord[0].to_i).to_s+"("+linerecord[0].to_s+") is illegal. It is either a legendary or a non-basic Pokemon, and is not allowed to be used. (Line:"+numberline.to_s+")" if !ignore
          temp=true
          break
        end
        eggs[numberline][0]=linerecord[0].to_i
      else
        return "Error on line "+numberline.to_s+", the first part. Could not read, or not a number." if !ignore
          temp=true
          break
    end
    
    if linerecord[1]!="" && linerecord[1]
      eggs[numberline][1]=linerecord[1]
    else
       return "Error on line "+numberline.to_s+", the nickname (second part). Could not be read." if !ignore
          temp=true
          break
    end
    
     if linerecord[2]!="" && linerecord[2]
      if checkIsItemLegal(linerecord[2].to_i)
       eggs[numberline][2]=linerecord[2].to_i
        else
         return "Item equipped to Pokemon on line "+numberline+" "+PBItems.getName(linerecord[2].to_i)+" is illegal." if !ignore
          temp=true
          break
      end
     else
       return "Error on line "+numberline.to_s+", the item (third part). Could not be read." if !ignore
          temp=true
          break
     end
     
     if linerecord[3]!=""  && linerecord[3]
       if linerecord[3].to_i < 3 && linerecord[3].to_i > -1
         eggs[numberline][3]=linerecord[3].to_i
       else
       return "Error on line "+numberline.to_s+", the ability (fourth part). Could not be read." if !ignore
          temp=true
          break
        end
     else
       return "Error on line "+numberline.to_s+", the ability (fourth part). Could not be read." if !ignore
          temp=true
          break
     end
     
     if linerecord[4]!="" && linerecord[4]
       if linerecord[4]=="Male"
         linerecord[4]=0
       elsif linerecord[4]=="Female"
         linerecord[4]=1
       elsif linerecord[4]=="Genderless"
         linerecord[4]=2
       else
         linerecord[4]=linerecord[4].to_i
       end
       
       
       tempint = linerecord[4].to_i-1
       eggs[numberline][4]=linerecord[4].to_i
       else
       return "Error on line "+numberline.to_s+", the gender (5th part). Could not be read." if !ignore
          temp=true
          break
     end
     
     if linerecord[5]!="" && linerecord[5] #&& linerecord[5].to_i != 0
         eggs[numberline][5]=parseNature(linerecord[5])
       
     else
       return "Error on line "+numberline.to_s+", the nature (6th part). Could not be read." if !ignore
          temp=true
          break
     end

     for integer in 6..11
         if linerecord[integer]!="" && linerecord[integer]
          eggs[numberline][integer]=linerecord[integer]
         else
       return "Error on line "+numberline.to_s+", in the IVs (6-11th part). Could not be read." if !ignore
          temp=true
          break
     end
   end
      for integer in 12..15
           if linerecord[integer]!="" && linerecord[integer]               
             if isMoveLegalForSpecies(linerecord[0].to_i,linerecord[integer].to_i,eggEmerald)
               eggs[numberline][integer]=linerecord[integer].to_i
             else
           #     return "Move stated on line "+numberline.to_s+" is illegal ("+linerecord[integer].to_s+")." if !ignore
           #     temp=true
           #     break
             end
            else
               return "Error on line "+numberline.to_s+", in the moves (12-15th part). Could not be read." if !ignore
                temp=true
                break
            end
        end
      
#  }
    }
    end
    eggEmerald.close
    return eggs
  end



def pbCheckEggFileValid(string)
     return File.exist?("Egglocke/"+string+".txt")
     
   end
   

   def pbWatchTV
    Kernel.pbMessage("There's nothing good on TV.")
    
    if $Trainer.ablePokemonCount > 0 && rand(20)==0
      levell=10
      for member in $Trainer.party
        if member.level > levell
          levell=member.level
        end
        
      end
      pbWildBattle(PBSpecies::ROTOM,levell)
    end

end

def pbPokeMartWorker
  ary=[:POKEBALL,:POTION,:REPEL,:ANTIDOTE]
  if $game_switches[59]
    ary=[:POKEBALL,:POTION,:SUPERPOTION,:REPEL,:ANTIDOTE]
  end
  if $Trainer.numbadges>=1
    ary=[:POKEBALL,:GREATBALL,:POTION,:SUPERPOTION,:REPEL,:ANTIDOTE,:ICEHEAL,:PARLYZHEAL,:AWAKENING,:BURNHEAL,:ESCAPEROPE]
  end
  if $Trainer.numbadges>=2
    ary=[:POKEBALL,:GREATBALL,:ULTRABALL,:POTION,:SUPERPOTION,:HYPERPOTION,:REVIVE,:REPEL,:SUPERREPEL,:ANTIDOTE,:ICEHEAL,:PARLYZHEAL,:AWAKENING,:BURNHEAL,:ESCAPEROPE]
  end
  if $Trainer.numbadges>=3
    ary=[:POKEBALL,:GREATBALL,:ULTRABALL,:POTION,:SUPERPOTION,:HYPERPOTION,:REVIVE,:REPEL,:SUPERREPEL,:MAXREPEL,:FULLHEAL,:ANTIDOTE,:ICEHEAL,:PARLYZHEAL,:AWAKENING,:BURNHEAL,:ESCAPEROPE]
  end
  if $Trainer.numbadges>=5
    ary=[:POKEBALL,:GREATBALL,:ULTRABALL,:POTION,:SUPERPOTION,:HYPERPOTION,:MAXPOTION,:REVIVE,:REPEL,:SUPERREPEL,:MAXREPEL,:FULLHEAL,:ANTIDOTE,:ICEHEAL,:PARLYZHEAL,:AWAKENING,:BURNHEAL,:ESCAPEROPE]
  end
  if $Trainer.numbadges>=8
    ary=[:POKEBALL,:GREATBALL,:ULTRABALL,:POTION,:SUPERPOTION,:HYPERPOTION,:MAXPOTION,:FULLRESTORE,:REVIVE,:REPEL,:SUPERREPEL,:MAXREPEL,:FULLHEAL,:ANTIDOTE,:ICEHEAL,:PARLYZHEAL,:AWAKENING,:BURNHEAL,:ESCAPEROPE]
  end
  if $game_switches[71] && $Trainer.numbadges>=1
    ary=[:NUZLOCKEBALL].concat(ary)
  end
  
  pbPokemonMart(ary)
end

def pbCheckSaves
  if File.exist?(RTP.getSaveFileName("Game.rxdata")) || 
     File.exist?(RTP.getSaveFileName("Game_1.rxdata")) ||
     File.exist?(RTP.getSaveFileName("Game_2.rxdata"))
    $game_switches[696]=true
  else
    $game_switches[696]=false
  end
end


def listUnmade
  listary=[]
#    def pbFindAnimation(moveid,userIndex)
      move2anim=load_data("Data/move2anim.dat")
    userIndex=0
    for moveid in 0..PBMoves.maxValue-1
    begin
      noflip=false
      if userIndex==0 || userIndex==2 # On player's side
        anim=move2anim[0][moveid]
      else                            # On opposing side
        anim=move2anim[1][moveid]
        noflip=true if anim
        anim=move2anim[0][moveid] if !anim
      end
     # return [anim,noflip] if anim
      listary.push(PBMoves.getName(moveid)) if !anim
      
    #  rescue
    #  return nil
    end
  end
  File.open("Not Done", 'w') do |f2|
        for i in listary
          f2.puts(listary)
          end
                end
    #return nil
  end
  
  def appendToBack(image,trainer)
    return image if $game_variables && $game_variables[41]==15
    append="/boy/"
    append="/girl/" if $game_switches[78]
    appendEnd=""
    appendEnd="b" if trainer.bald && trainer.gender==0 && $game_variables[41]!=2 && 
      $game_variables[41]!=3 && $game_variables[41]!=4 && $game_variables[41]!=13 &&
      $game_variables[41]!=14 && $game_variables[41]!=15 #$game_switches[71]
    appendEnd="c" if trainer.bald && trainer.gender==1 && $game_variables[41]!=2 && 
      $game_variables[41]!=3 && $game_variables[41]!=4 && $game_variables[41]!=13 &&
      $game_variables[41]!=14 && $game_variables[41]!=15 #$game_switches[71]
    
    #Kernel.pbMessage(trainer.clothes[2].to_s)
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes_back"+append+"shirt#{trainer.clothes[2]}")
    image.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes_back"+append+"hair#{trainer.clothes[5]}"+appendEnd)
    image.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
    #      bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes_back"+append+"backpack#{trainer.clothes[3]}"+appendEnd)
    # image.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
    #    if trainer.clothes[0] >= 806 && trainer.clothes[0] <= 809
    #        append = append+"f"
    #    end
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes_back"+append+"hat#{trainer.clothes[0]}")
    image.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
    return image
  end

  def appendToFront(image,trainer,trainercard=false,isbitmap=false)
    begin
    #    return image
    #   if trainer.id.even?
    return image if $game_variables && $game_variables[41]>0
    return image if !trainercard && ![0,1,2,3,178,179].include?(trainer.trainertype)
    append="/boy/"
    #   else
    append="/girl/" if (trainercard && $game_switches[78]) || trainer.gender==1
    #   end
    if !isbitmap
      bitmap=image.bitmap
    else
      bitmap=image
    end
    appendEnd=""
    appendEnd="b" if trainer.bald && trainer.gender==0
    appendEnd="c" if trainer.bald && trainer.gender==1
    return image if !trainer.clothes || !trainer.clothes.is_a?(Array)
    #   bittrip=BitmapCache.load_bitmap("Graphics/Characters/trainer010")
    #   bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes_front"+append+"pants#{trainer.clothes[4]}") if trainer.clothes[4] != 0 && trainer.clothes[4] != 0
    bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) if trainer.clothes[4] != 0 && trainer.clothes[4] != 0  
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes_front"+append+"shirt#{trainer.clothes[2]}")  if trainer.clothes[2] != 0 && trainer.clothes[2] != 0
    bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) if trainer.clothes[2] != 0 && trainer.clothes[2] != 0
    #Kernel.pbMessage(trainer.clothes[2].to_s) if trainer.clothes[2] != 0 && trainer.clothes[2] != 0
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes_front"+append+"hair#{trainer.clothes[5]}"+appendEnd) 
    bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) 
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes_front"+append+"hat#{trainer.clothes[0]}") if trainer.clothes[0] != 0 && trainer.clothes[0] != 0
    bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) if trainer.clothes[0] != 0 && trainer.clothes[0] != 0
    rescue
      Kernel.pbMessage("Error: "+$!)
    end
    return image
  end
  
  def appendToSprite(image,trainer,trainercard=false,isbitmap=false)
    #    return image
    #   if trainer.id.even?
    append="/boy/"
    #   else
    append="/girl/" if trainercard && $game_switches[78]
    #   end
    if !isbitmap
      bitmap=image.bitmap
    else
      bitmap=image
    end
    appendEnd=""
    appendEnd="b" if trainer.bald && trainer.gender==0
    appendEnd="c" if trainer.bald && trainer.gender==1

    return image if !trainer.clothes || !trainer.clothes.is_a?(Array)
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes/pants#{trainer.clothes[4]}") if trainer.clothes[4] != 0 && trainer.clothes[4] != 0
    bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) if trainer.clothes[4] != 0 && trainer.clothes[4] != 0  
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes/shirt#{trainer.clothes[2]}")  if trainer.clothes[2] != 0 && trainer.clothes[2] != 0
    bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) if trainer.clothes[2] != 0 && trainer.clothes[2] != 0
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes/hair#{trainer.clothes[5]}"+appendEnd)  if trainer.clothes[5] != 0 && trainer.clothes[5] != 0
    bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) if trainer.clothes[5] != 0 && trainer.clothes[5] != 0
    #  if trainer.clothes[0] >= 806 && trainer.clothes[0] <= 809
    #       append = append+"f"
    #     end
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes/hat#{trainer.clothes[0]}") if trainer.clothes[0] != 0 && trainer.clothes[0] != 0
    bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height)) if trainer.clothes[0] != 0 && trainer.clothes[0] != 0
    return image
  end
  
  def getPlaceInGame
    #  File.new "Graphics/Titles/reached1.txt","w" 
     
  
    return [0,56,151] if !File::exists?("Graphics/Titles/reached1.txt")
    return [1,45,251] if !File::exists?("Graphics/Titles/reached2.txt")
    return [2,16,643] if !File::exists?("Graphics/Titles/reached3.txt")
    return [3,56,492] if !File::exists?("Graphics/Titles/reached4.txt")
    return [4,55,384]  if !File::exists?("Graphics/Titles/reached5.txt")
    return [5,57,249] if !File::exists?("Graphics/Titles/reached6.txt")
    return [6,10,382] if !File::exists?("Graphics/Titles/reached7.txt")
    return [7,47,644] if !File::exists?("Graphics/Titles/reached8.txt")
    return [8,4,383] if !File::exists?("Graphics/Titles/reached9.txt")
    return [9,47,646] if !File::exists?("Graphics/Titles/reached10.txt")
    return [10,35,485] if !File::exists?("Graphics/Titles/reached11.txt")
    return [11,45,386] if !File::exists?("Graphics/Titles/reached12.txt")
    return [12,16,491] if !File::exists?("Graphics/Titles/reached13.txt")
    return [13,45,487]
  end
  
def setHiddenGrotto(eventid,map)
#  if $game_variables[23][$game_map_map.id] == nil || $game_variables[23][$game_map_map.id] == 0
    # Set Pokemon/Item arrays based on Map ID
    if $game_map.map_id==121
      pokeary=[PBSpecies::EXEGGCUTE,PBSpecies::DURANT,PBSpecies::STUNKY,PBSpecies::HEATMOR]
      itemary=[PBItems::GREATBALL,PBItems::DUSKBALL,PBItems::FULLHEAL,PBItems::SUPERPOTION]
    end
    if $game_map.map_id==161
      pokeary=[PBSpecies::PANSAGE,PBSpecies::CHARMANDER,PBSpecies::THROH,PBSpecies::SAWK]
      itemary=[PBItems::FIRESTONE,PBItems::DUSKSTONE,PBItems::FULLHEAL,PBItems::HYPERPOTION]
    end
    if $game_map.map_id==224
      pokeary=[PBSpecies::SQUIRTLE,PBSpecies::POLIWHIRL,PBSpecies::DELTASUNKERN,PBSpecies::PANPOUR]
      itemary=[PBItems::LEVELBALL,PBItems::GREATBALL]
    end
    if $game_map.map_id==163
      pokeary=[PBSpecies::ELECTRIKE,PBSpecies::DUNSPARCE,PBSpecies::FENNEKIN,PBSpecies::STUNKY]
      itemary=[PBItems::LEAFSTONE,PBItems::REVIVE,PBItems::FULLHEAL,PBItems::ENERGYROOT]
    end
    if $game_map.map_id==348
      pokeary=[PBSpecies::TRAPINCH,PBSpecies::PANCHAM,PBSpecies::HONEDGE,PBSpecies::FENNEKIN]
      itemary=[PBItems::FIRESTONE,PBItems::REVIVE,PBItems::FULLRESTORE,PBItems::MAXPOTION]
    end
    if $game_map.map_id==381
      pokeary=[PBSpecies::SPRITZEE,PBSpecies::SLURPUFF,PBSpecies::DELTAMUNCHLAX,PBSpecies::DELTAMUNCHLAX]
      itemary=[PBItems::ULTRABALL,PBItems::MAXREPEL,PBItems::DUSKBALL,PBItems::MAXPOTION]
    end
    if $game_map.map_id==587
      pokeary=[PBSpecies::SPRITZEE,PBSpecies::SLURPUFF,PBSpecies::DELTAPHANTUMP,PBSpecies::DELTAPHANTUMP]
      itemary=[PBItems::ULTRABALL,PBItems::MAXREPEL,PBItems::DUSKBALL,PBItems::MAXPOTION]
    end
    if $game_map.map_id==348
      pokeary=[PBSpecies::DELTACOMBEE,PBSpecies::TREECKO,PBSpecies::HONEDGE,PBSpecies::MUDKIP]
      itemary=[PBItems::FIRESTONE,PBItems::REVIVE,PBItems::FULLRESTORE,PBItems::MAXPOTION]
    end
    if $game_map.map_id==349
      pokeary=[PBSpecies::TURTWIG,PBSpecies::PHANPY,PBSpecies::HONEDGE,PBSpecies::CHESPIN]
      itemary=[PBItems::LEAFSTONE,PBItems::REVIVE,PBItems::IRON,PBItems::ELIXIR]
    end
    if $game_map.map_id==350
      pokeary=[PBSpecies::CHIMCHAR,PBSpecies::DELTASCRAGGY,PBSpecies::SCRAGGY,PBSpecies::FROAKIE]
      itemary=[PBItems::WATERSTONE,PBItems::ETHER,PBItems::FULLRESTORE,PBItems::CARBOS]
    end
    if $game_map.map_id==567
      pokeary=[PBSpecies::SNEASEL,PBSpecies::GIRAFARIG,PBSpecies::SCRAGGY,PBSpecies::BULBASAUR]
      itemary=[PBItems::ELECTIRIZER,PBItems::ETHER,PBItems::FULLRESTORE,PBItems::ELIXIR]
    end
    if $game_map.map_id==574
      pokeary=[PBSpecies::DARUMAKA,PBSpecies::ZORUA,PBSpecies::HONEDGE,PBSpecies::NOIBAT]
      itemary=[PBItems::MAGMARIZER,PBItems::FIRESTONE,PBItems::WATERSTONE,PBItems::MAXPOTION]
    end
    if $game_map.map_id==594
      pokeary=[PBSpecies::DOUBLADE,PBSpecies::DROWZEE,PBSpecies::PANGORO,PBSpecies::FLOETTE]
      itemary=[PBItems::PROTECTOR,PBItems::THUNDERSTONE,PBItems::MAXPOTION,PBItems::DAWNSTONE]
    end
     if $game_map.map_id==685
       pokeary=[PBSpecies::MUNNA,PBSpecies::DELTACHINCHOU,PBSpecies::DROWZEE,PBSpecies::ZORUA]
      itemary=[PBItems::DREAMMIST,PBItems::DREAMMIST,PBItems::MAXPOTION,PBItems::REVIVE]
    end
    if $game_map.map_id==686
       pokeary=[PBSpecies::DEINO,PBSpecies::SWABLU,PBSpecies::DODUO,PBSpecies::CHARMANDER]
      itemary=[PBItems::WATERSTONE,PBItems::EVERSTONE,PBItems::FIRESTONE,PBItems::REVIVE]
    end
    if $game_map.map_id==687
       pokeary=[PBSpecies::BELDUM,PBSpecies::FROAKIE,PBSpecies::CHESPIN,PBSpecies::BULBASAUR]
      itemary=[PBItems::ICYROCK,PBItems::HARDSTONE,PBItems::DARKROCK,PBItems::REVIVE]
    end

    # If rand function yields 0, set items
    if rand(2)==0
      loot=itemary[rand(itemary.length)]
      # HiddenGrottoItem?
      $game_switches[39]=true
      # HIDDEN_GROTTO_POKE
      $game_variables[24]=loot
      # HIDDEN_GROTTO_RESET
      $game_variables[23]="Object ball"
      # MOST_RECENT_GROTTO
      $game_variables[117]=$game_map.map_id
      # is_render_hiddengrotto
      $game_switches[44]=true
      #    $game_variables[23][$game_map.map_id]=500
    # If rand function yields 1, set Pokemon
    else
      loot=pokeary[rand(pokeary.length)]
      # HiddenGrottoItem?
      $game_switches[39]=false
      # HIDDEN_GROTTO_POKE
      $game_variables[24]=loot
      # is_render_hiddengrotto
      $game_switches[44]=true
      #  lootstring=loot.to_s
      #  Kernel.pbMessage(lootstring.length.to_s)
      #  if lootstring.length==1
      #    loostring="00"+lootstring
      #  elsif lootstring.length==2
      #    loostring="0"+lootstring
      #  end
     
      # HIDDEN_GROTTO_RESET
      $game_variables[23]=sprintf("%03d",loot)
      # MOST_RECENT_GROTTO
      $game_variables[117]=$game_map.map_id
    end
    #  else
    #  $game_switches[44]=false
    #  end
end

def loadHGTexture(eventid,map)
  # MOST_RECENT_GROTTO
  if $game_variables[117]!=$game_map.map_id
    # HIDDEN_GROTTO_RESET
    $game_variables[23]=0
  end
  
  # HIDDEN_GROTTO_RESET
  # Should be able to add an else here which makes the sprite disappear.
  # Setting the event's Through parameter to true also seems doable
  if $game_variables[23] != 0
    map.events[eventid].character_name=$game_variables[23]
    #$game_variables[23]=0
    return true
  end
  return false
end

def pbChangeBackToNormal
  pbChangePlayer($game_variables[112])
  $game_variables[41]=0
  $game_map.need_refresh=true
end

def useShayminAbility
  i = -1
  if $game_map.tileset_name == "ins_outside"
    i = 6
  end
  if $game_map.tileset_name == "ins_black"
    i = 1
  end
  if $game_map.tileset_name == "interior_main"
    i = 0
    end
  if $game_map.tileset_name == "DeepSeaBase"
    i = 4
  end
  return false if i == -1 || $game_map.autotile_names[i]!="slime"

  $game_map.autotile_names[i]="calm transparent water 2" if i == 6
  $game_map.autotile_names[i]="water002" if i == 0
  $game_map.autotile_names[i]="water002" if i == 1
  $game_map.autotile_names[i]="water002" if i == 4
           $game_temp.player_new_map_id=$game_map.map_id
           $game_temp.player_new_x=$game_player.x
           $game_temp.player_new_y=$game_player.y
           $game_temp.player_new_direction=$game_player.direction
           $scene.transfer_player(false)
  
  $data_tilesets = pbLoadRxData("Data/Tilesets")

end

def getIsInPokecenter
    ary=[32,89,97,130,
    131,153,194,
    195,250,251,252,
    253,254,255,256,
    810,811,812,813,814,815,
    816,817,818,
    712,713,715,717,716,718]
    return true if ary.include?($game_map.map_id)
    return false
  
  
end


def pbSlimeCheck(tag)
    i = -1
  if $game_map.tileset_name == "ins_outside"
    i = 6
  end
  if $game_map.tileset_name == "interior_main"
    i = 0
  end
  if $game_map.tileset_name == "ins_black"
    i = 1
  end


  if $game_map.tileset_name == "DeepSeaBase"
    i = 4
    end
  return false if i == -1|| $game_map.autotile_names[i]=="slime"

  return true if tag==PBTerrain::StillWater  
  return false
  
end

def pbUseHeartSwap(specific=false,speValue=0)
  if $PokemonGlobal.surfing
    Kernel.pbMessage("Nothing happened...")
    return
  end
  
  if !specific
    for i in 1..$game_map.events.length
      if $game_map.events[i] != nil
      if $game_map.events[i].x < $game_player.x + 8 && $game_map.events[i].x > $game_player.x - 8
        if $game_map.events[i].y < $game_player.y + 8 && $game_map.events[i].y > $game_player.y - 8
          if $game_map.events[i].name.include?("HeartSwap_S")
            speValue=i
            break
          end
        end
      end
     end
 
    end
   $game_variables[39]=30
   $game_switches[62]=true

  end
  if speValue != 0
  $scene.spriteset.addUserAnimation(HS_Disappear, $game_map.events[speValue].x, $game_map.events[speValue].y)
  $scene.spriteset.addUserAnimation(HS_Disappear, $game_player.x, $game_player.y)
  $game_temp.player_transferring = true
  $game_temp.player_new_map_id = $game_map.map_id
  $game_temp.player_new_x = $game_map.events[speValue].x
  $game_temp.player_new_y = $game_map.events[speValue].y
  $game_temp.player_new_direction = $game_player.direction
  character = pbMapInterpreter.get_character(speValue)
  character.moveto($game_player.x, $game_player.y)

  Graphics.freeze
  $game_temp.transition_processing = true
  $game_temp.transition_name = ""
  
  
  
else
  Kernel.pbMessage("Nothing happened...")
end
end


def pbUseHyperspaceHole(specific=false,speValue=0)
  if $game_map.map_id==463 && !$game_switches[445]
    Kernel.pbMessage("Some mysterious force blocked the ability...")
    return
  end
  
  #Kernel.pbMessage($game_map.events.length.to_s)
  if !specific
    for i in 0..$game_map.events.length
         #   Kernel.pbMessage(i.to_s)
      if $game_map.events[i] != nil
      #        Kernel.pbMessage($game_map.events[i].name)
        if $game_map.events[i].x < $game_player.x + 8 && $game_map.events[i].x > $game_player.x - 8
          if $game_map.events[i].y < $game_player.y + 8 && $game_map.events[i].y > $game_player.y - 8
           #   Kernel.pbMessage($game_map.events[i].name)
            if $game_map.events[i].name.include?("Hoopa_Hole")
              speValue=i
          #    Kernel.pbMessage(speValue.to_s)
              break
            end
          end
        end
       end
     end
     
   $game_variables[39]=30
   $game_switches[62]=true
  end
    if speValue != 0
        $scene.spriteset.addUserAnimation(Hyperspace_Hole, $game_map.events[speValue].x, $game_map.events[speValue].y)
      $game_self_switches[[$game_map.map_id,speValue,"A"]]=true
       $game_map.need_refresh=true
      else
        Kernel.pbMessage("Nothing happened...")
    end
  end

  
def pbGetMegaSpeciesStoneWorks(species,stone)  
  
  if Kernel.pbGetMegaSpeciesList.include?(species) && Kernel.pbGetMegaStoneList.include?(stone)
    if Kernel.pbGetMegaSpeciesList[Kernel.pbGetMegaStoneList.index(stone)]==species
      return true
    end
  end
  return false
end




def pbGetMegaSpeciesList
  ret = [PBSpecies::VENUSAUR,PBSpecies::CHARIZARD,PBSpecies::CHARIZARD,PBSpecies::BLASTOISE,
  PBSpecies::ALAKAZAM,PBSpecies::GENGAR,PBSpecies::KANGASKHAN,PBSpecies::PINSIR,
  PBSpecies::GYARADOS,PBSpecies::AERODACTYL,PBSpecies::MEWTWO,PBSpecies::MEWTWO,
  PBSpecies::AMPHAROS,PBSpecies::SCIZOR,PBSpecies::HERACROSS,PBSpecies::HOUNDOOM,
  PBSpecies::TYRANITAR,PBSpecies::BLAZIKEN,PBSpecies::GARDEVOIR,PBSpecies::MAWILE,
  PBSpecies::AGGRON,PBSpecies::MEDICHAM,PBSpecies::MANECTRIC,PBSpecies::BANETTE,
  PBSpecies::ABSOL,PBSpecies::GARCHOMP,PBSpecies::LUCARIO,
  PBSpecies::ABOMASNOW,PBSpecies::SLOWBRO,PBSpecies::SCEPTILE,PBSpecies::SWAMPERT,
  PBSpecies::SABLEYE,PBSpecies::ALTARIA,PBSpecies::SALAMENCE,PBSpecies::METAGROSS,
  PBSpecies::LATIOS,PBSpecies::LATIAS,PBSpecies::LOPUNNY,PBSpecies::AUDINO,
  PBSpecies::DIANCIE,
  
  PBSpecies::MAGCARGO,
  
  PBSpecies::MEGANIUM,PBSpecies::TYPHLOSION,PBSpecies::FERALIGATR,PBSpecies::BISHARP,
  PBSpecies::CACTURNE,
  PBSpecies::CRAWDAUNT,PBSpecies::MILOTIC,PBSpecies::EEVEE,PBSpecies::MAROWAK,
  PBSpecies::DONPHAN,PBSpecies::REUNICLUS,PBSpecies::GIRAFARIG,
  PBSpecies::DELTAVENUSAUR,PBSpecies::DELTACHARIZARD,PBSpecies::DELTABLASTOISE,
  PBSpecies::SUNFLORA,PBSpecies::CRYOGONAL,PBSpecies::JIRACHI,
  PBSpecies::ZOROARK,PBSpecies::DELTABISHARP,PBSpecies::STUNFISK,
  PBSpecies::ZEBSTRIKA,PBSpecies::DELTAGARDEVOIR,PBSpecies::DELTAPIDGEOT,
  PBSpecies::CAMERUPT,PBSpecies::SHARPEDO,PBSpecies::RAYQUAZA,PBSpecies::PIDGEOT,PBSpecies::BEEDRILL,PBSpecies::GLALIE,PBSpecies::DELTAGALLADE,
  PBSpecies::GALLADE,PBSpecies::FLYGON,PBSpecies::SHIFTRY,PBSpecies::DELTASCIZOR,PBSpecies::GOTHITELLE,PBSpecies::SPIRITOMB,PBSpecies::MILTANK,
  PBSpecies::DELTASUNFLORA,PBSpecies::CHATOT,PBSpecies::HAXORUS,PBSpecies::POLIWRATH,PBSpecies::DELTAMETAGROSS1,PBSpecies::DELTAMETAGROSS2,
  PBSpecies::POLITOED,PBSpecies::DELTAMILOTIC,PBSpecies::DELTALUCARIO,PBSpecies::DELTAFROSLASS,PBSpecies::FROSLASS,
  PBSpecies::DELTAGIRAFARIG,PBSpecies::DELTALOPUNNY,PBSpecies::DELTASABLEYE,PBSpecies::DELTACAMERUPT,
  PBSpecies::DELTATYPHLOSION,PBSpecies::SUDOWOODO,PBSpecies::DELTAGLALIE,PBSpecies::STEELIX,PBSpecies::STEELIX,
  PBSpecies::HYDREIGON,PBSpecies::DELTAMAWILE,PBSpecies::DELTAMEDICHAM,PBSpecies::DELTAMETAGROSS2]
  return ret
end

def pbGetMegaStoneList
  ret = [PBItems::VENUSAURITE,PBItems::CHARIZARDITEX,PBItems::CHARIZARDITEY,PBItems::BLASTOISITE,
  PBItems::ALAKAZITE,PBItems::GENGARITE,PBItems::KANGASKHANITE,PBItems::PINSIRITE,
  PBItems::GYARADOSITE,PBItems::AERODACTYLITE,PBItems::MEWTWONITEX,PBItems::MEWTWONITEY,
  PBItems::AMPHAROSITE,PBItems::SCIZORITE,PBItems::HERACROSSITE,PBItems::HOUNDOOMITE,
  PBItems::TYRANITARITE,PBItems::BLAZIKENITE,PBItems::GARDEVOIRITE,PBItems::MAWILITE,
  PBItems::AGGRONITE,PBItems::MEDICHAMITE,PBItems::MANECTRITE,PBItems::BANNETITE,
  PBItems::ABSOLITE,PBItems::GARCHOMPITE,PBItems::LUCARIONITE,
  PBItems::ABOMASITE,PBItems::SLOWBRONITE,PBItems::SCEPTITE,PBItems::SWAMPERTITE,
  PBItems::SABLITE,PBItems::ALTARITE,PBItems::SALAMENCITE,PBItems::METAGRONITE,
  PBItems::LATIOSITE,PBItems::LATIASITE,PBItems::LOPUNNITE,PBItems::AUDINITE,
  PBItems::DIANCITE,
  
  PBItems::MAGCARGONITE,
  # Make sure Steelix + Steelixite is added back in when Steelixite Z/O shit is sorted with.
  PBItems::MEGANIUMITE,PBItems::TYPHLOSIONITE,PBItems::FERALIGATITE,PBItems::BISHARPITE,
  PBItems::CACTURNITE,
  PBItems::CRAWDITE,PBItems::MILOTITE,PBItems::EEVITE,PBItems::MAROWITE,
  PBItems::DONPHANITE,PBItems::REUNICLITE,PBItems::GIRAFARIGITE,
  PBItems::DELTAVENUSAURITE,PBItems::DELTACHARIZARDITE,PBItems::DELTABLASTOISINITE,
  PBItems::SUNFLORITE,PBItems::CRYOGONITE,PBItems::JIRACHITE,
  PBItems::ZORONITE,PBItems::DELTABISHARPITE,PBItems::STUNFISKITE,
  PBItems::ZEBSTRIKITE,PBItems::DELTAGARDEVOIRITE,PBItems::DELTAPIDGEOTITE,
  PBItems::CAMERUPTITE,PBItems::SHARPEDONITE,PBItems::RAYQUAZITE,PBItems::PIDGEOTITE,PBItems::BEEDRITE,PBItems::GLALITITE,PBItems::DELTAGALLADITE,
  PBItems::GALLADITE,PBItems::FLYGONITE,PBItems::SHIFTRITE,PBItems::DELTASCIZORITE,PBItems::GOTHITITE,PBItems::SPIRITOMBITE,PBItems::MILTANKITE,
  PBItems::DELTASUNFLORITE,PBItems::CHATOTITE,PBItems::HAXORITE,PBItems::POLIWRATHITE,PBItems::DELTAMETAGROSSITE1,PBItems::DELTAMETAGROSSITE2,
  PBItems::POLITOEDITE,PBItems::DELTAMILOTICITE,PBItems::DELTALUCARIONITE,PBItems::DELTAFROSLASSITE,PBItems::FROSLASSITE,
  PBItems::DELTAGIRAFARIGITE,PBItems::DELTALOPUNNITE,PBItems::DELTASABLENITE,PBItems::DELTACAMERUPTITE,
  PBItems::DELTATYPHLOSIONITE,PBItems::SUDOWOODITE,PBItems::DELTAGLALITITE,PBItems::STEELIXITE,PBItems::STEELIXITE2,
  PBItems::HYDREIGONITE,PBItems::DELTAMAWILITE,PBItems::DELTAMEDICHAMITE,
  PBItems::CRYSTALFRAGMENT]
  return ret
end

def pbGetArmorSpeciesList
  ret = [PBSpecies::MEWTWO,PBSpecies::ZEKROM,PBSpecies::TYRANITAR,PBSpecies::LEAVANNY,PBSpecies::FLYGON,PBSpecies::DELTAVOLCARONA]
  return ret
end

def pbGetArmorItemList
  ret = [PBItems::MEWTWOMACHINE,PBItems::ZEKROMMACHINE,PBItems::TYRANITARMACHINE,PBItems::LEAVANNYMACHINE,PBItems::FLYGONMACHINE,PBItems::DVOLCARONAARMOR]
  return ret
end

def pbReturnFormNumber(poke=nil)
  if isConst?(poke.species,PBSpecies,:DELTADITTO) 
    ret=PBTypes::WATER
  elsif isConst?(poke.species,PBSpecies,:ROTOM) ||
        isConst?(poke.species,PBSpecies,:TORNADUS) ||
        isConst?(poke.species,PBSpecies,:THUNDURUS) ||
        isConst?(poke.species,PBSpecies,:LANDORUS) ||
        isConst?(poke.species,PBSpecies,:MACHAMP)
    ret=poke.form
  elsif isConst?(poke.species,PBSpecies,:CASTFORM) ||
    isConst?(poke.species,PBSpecies,:CHERRIM) ||
    isConst?(poke.species,PBSpecies,:DARMANITAN) ||
    isConst?(poke.species,PBSpecies,:AEGISLASH) ||
    isConst?(poke.species,PBSpecies,:GRENINJA) ||
    isConst?(poke.species,PBSpecies,:FROGADIER) ||
    isConst?(poke.species,PBSpecies,:FROAKIE) ||
    isConst?(poke.species,PBSpecies,:KECLEON) ||
    isConst?(poke.species,PBSpecies,:KYOGRE) ||     
    isConst?(poke.species,PBSpecies,:GROUDON) ||
    isConst?(poke.species,PBSpecies,:MELOETTA) ||
    isConst?(poke.species,PBSpecies,:DELTAEMOLGA) ||
    isConst?(poke.species,PBSpecies,:REGIGIGAS) ||
    (isConst?(poke.species,PBSpecies,:GIRATINA) && poke.form==2) ||
    (isConst?(poke.species,PBSpecies,:ARCEUS) && poke.form==19) ||
    (Kernel.pbGetArmorSpeciesList.include?(poke.species) && 
    !Kernel.pbGetArmorItemList.include?(poke.item)) ||
    (isConst?(poke.species,PBSpecies,:GARDEVOIR) && poke.form==1) || 
    (isConst?(poke.species,PBSpecies,:GARDEVOIR) && poke.form==2) || 
    (isConst?(poke.species,PBSpecies,:GARDEVOIR) && poke.form==3) ||
    (isConst?(poke.species,PBSpecies,:LUCARIO) && poke.form==1) || 
    (isConst?(poke.species,PBSpecies,:LUCARIO) && poke.form==2) || 
    (isConst?(poke.species,PBSpecies,:LUCARIO) && poke.form==3) ||
    (isConst?(poke.species,PBSpecies,:DELTATYPHLOSION) && !poke.form==0) ||
    (isConst?(poke.species,PBSpecies,:MEWTWO) && !isConst?(poke.item,PBItems,:MEWTWOMACHINE) && !poke.form==4) ||
    (isConst?(poke.species,PBSpecies,:TYRANITAR) && !isConst?(poke.item,PBItems,:TYRANITARMACHINE)) ||
    (isConst?(poke.species,PBSpecies,:FLYGON) && !isConst?(poke.item,PBItems,:FLYGONMACHINE)) ||
    (!isConst?(poke.species,PBSpecies,:GARDEVOIR) && !isConst?(poke.species,PBSpecies,:LUCARIO) && !isConst?(poke.species,PBSpecies,:MEWTWO) && !isConst?(poke.species,PBSpecies,:TYRANITAR) && 
    !isConst?(poke.species,PBSpecies,:FLYGON) && Kernel.pbGetMegaSpeciesList.include?(poke.species))
    if (isConst?(poke.species,PBSpecies,:GARDEVOIR) && (poke.form==3 || poke.form==2)) || 
       (isConst?(poke.species,PBSpecies,:LUCARIO) && (poke.form==3 || poke.form==2))
      ret=2
    elsif (isConst?(poke.species,PBSpecies,:MEWTWO) && (poke.form==4 || poke.form==5))
      ret=4
    else
      ret=0
    end
  end
  return ret
end

def pbCheckForMew
  if $Trainer
    for i in $Trainer.party
      if i.species==PBSpecies::MEW
        return true
      end
    end
  end
  return false
end

def pbSetCustomMove(int)
  $game_variables[98]=int
end

def pbPushRecent(int)
    $recentPush=Array.new if $recentPush == nil || !$recentPush.is_a?(Array)
    if $recentPush[1] != nil
      $recentPush[2]=$recentPush[1]
      $recentPush[1]=$recentPush[0]
      $recentPush[0]=int
    elsif $recentPush[0] != nil
      $recentPush[1]=$recentPush[0]
      $recentPush[0]=int
    else
      $recentPush[0]=int
    end
end

def pbTradeEvolution(int)
    ary=[PBSpecies::BOLDORE,
    PBSpecies::CLAMPERL,
    PBSpecies::CLAMPERL,
    PBSpecies::DELTACLAMPERL,
    PBSpecies::DELTACLAMPERL,
    
    PBSpecies::DELTAKARRABLAST,
    PBSpecies::DUSCLOPS,
    PBSpecies::ELECTABUZZ,
    PBSpecies::DELTAGRAVELER,
    PBSpecies::FEEBAS, #10
    
    PBSpecies::DELTAFEEBAS,
    PBSpecies::GRAVELER,
    PBSpecies::GURDURR,
    PBSpecies::HAUNTER,
    PBSpecies::KADABRA, #15
    
    PBSpecies::KARRABLAST,
    PBSpecies::MACHOKE,
    PBSpecies::MAGMAR,
    PBSpecies::ONIX,
    PBSpecies::PHANTUMP, #20
    
    PBSpecies::POLIWHIRL,
    PBSpecies::PORYGON,
    PBSpecies::PORYGON2,
    PBSpecies::PUMPKABOO,
    PBSpecies::RHYDON,
    
    PBSpecies::SCYTHER,
    PBSpecies::SEADRA,
    PBSpecies::SHELMET,
    PBSpecies::SLOWPOKE,
    PBSpecies::SPRITZEE, #30
    
    PBSpecies::SWIRLIX,
    PBSpecies::DELTASCYTHER,
    PBSpecies::DELTAPHANTUMP,
    PBSpecies::DELTAMAGMAR,
    PBSpecies::DELTAELECTABUZZ]
    
    ary1=[PBItems::POTION,
    PBItems::DEEPSEASCALE,
    PBItems::DEEPSEATOOTH,
    PBItems::DRAGONFANG,
    PBItems::DRAGONSCALE, #5
    
    PBItems::POTION,
    PBItems::REAPERCLOTH,
    PBItems::ELECTIRIZER,
    PBItems::POTION,
    PBItems::PRISMSCALE, #10
    
    PBItems::CLEANSETAG,
    PBItems::POTION,
    PBItems::POTION,
    PBItems::POTION,
    PBItems::POTION, #15
    
    PBItems::POTION,
    PBItems::POTION,
    PBItems::MAGMARIZER,
    PBItems::METALCOAT,
    PBItems::POTION, #20
    
    PBItems::KINGSROCK,
    PBItems::UPGRADE,
    PBItems::DUBIOUSDISC,
    PBItems::POTION,
    PBItems::PROTECTOR, #25
    
    PBItems::METALCOAT,
    PBItems::DRAGONSCALE,
    PBItems::POTION,
    PBItems::KINGSROCK,
    PBItems::SACHET, #30
    
    PBItems::WHIPPEDDREAM,
    PBItems::NEVERMELTICE,
    PBItems::POTION,
    PBItems::MAGMARIZER,
    PBItems::ELECTIRIZER]
    
    ary2=[PBSpecies::GIGALITH,PBSpecies::GOREBYSS,PBSpecies::HUNTAIL,PBSpecies::DELTAHUNTAIL,PBSpecies::DELTAGOREBYSS,PBSpecies::DELTAESCAVALIER,
    PBSpecies::DUSKNOIR,PBSpecies::ELECTIVIRE,PBSpecies::DELTAGOLEM,
    PBSpecies::MILOTIC,PBSpecies::DELTAMILOTIC,PBSpecies::GOLEM,PBSpecies::CONKELDURR,PBSpecies::GENGAR,
    PBSpecies::ALAKAZAM,PBSpecies::ESCAVALIER,PBSpecies::MACHAMP,PBSpecies::MAGMORTAR,
    PBSpecies::STEELIX,PBSpecies::TREVENANT,PBSpecies::POLITOED,PBSpecies::PORYGON2,
    PBSpecies::PORYGONZ,PBSpecies::GOURGEIST,PBSpecies::RHYPERIOR,PBSpecies::SCIZOR,
    PBSpecies::KINGDRA,PBSpecies::ACCELGOR,PBSpecies::SLOWKING,PBSpecies::AROMATISSE,
    PBSpecies::SLURPUFF,PBSpecies::DELTASCIZOR,PBSpecies::DELTATREVENANT,PBSpecies::DELTAMAGMORTAR,PBSpecies::DELTAELECTIVIRE]
    
    if ary.include?($Trainer.party[int].species)
      speciesvar=ary.index($Trainer.party[int].species)
      itemvar=ary1.index($Trainer.party[int].item)
      if itemvar==2 && ary[2]==$Trainer.party[int].species
        evo=PokemonEvolutionScene.new
        evo.pbStartScreen($Trainer.party[int],ary2[2])
        evo.pbEvolution
        evo.pbEndScreen
        return 2  
      end
      if itemvar==4 && ary[4]==$Trainer.party[int].species
        evo=PokemonEvolutionScene.new
        evo.pbStartScreen($Trainer.party[int],ary2[4])
        evo.pbEvolution
        evo.pbEndScreen
        return 2  
      end
      if ary1[speciesvar] == PBItems::POTION || ary1[speciesvar] == $Trainer.party[int].item
        evo=PokemonEvolutionScene.new     
        evo.pbStartScreen($Trainer.party[int],ary2[speciesvar])
        evo.pbEvolution
        evo.pbEndScreen
        return 2
      else
        return 1
      end
    else
        return 0
    end
end

def generateColorForPokepon
  Kernel.createPokeponFile
  var=$game_variables[125]
  $game_variables[125]=0
  if rand(12)==0
    $game_variables[125]=3
    return 2
  end
  if rand(2200)==0
    $game_variables[125]=4
    return 3
  end
  if rand(50)==0 && !$game_switches[373]
    $game_variables[125]=1
    return 1
  end
  if rand(50)==0 && !$game_switches[372]
    $game_variables[125]=2
    return 1
  end
  return 0
end

def createPokeponFile
  if File::exists?("Graphics/Tilesets/backup.txt")
    File.delete("Graphics/Tilesets/backup.txt")
  end
  
  File.open("Graphics/Tilesets/backup.txt", 'w') do |f2|
     tstring="Backup notification."
     f2.puts(tstring)
  end
             #   hasGenerated=true
            #else
            #end
end

def deletePokeponFile
  if File::exists?("Graphics/Tilesets/backup.txt")
      File.delete("Graphics/Tilesets/backup.txt")
    end
end
  

def generatePokeponItem
  var=$game_variables[125]
  ary=[]
  case var
  when 0
    ary=[PBItems::RARECANDY,
    PBItems::RARECANDY,PBItems::IVSTONE,PBItems::PEARL,
    PBItems::IVSTONE,PBItems::STARDUST,
    PBItems::BIGNUGGET,PBItems::HEARTSCALE,PBItems::HEARTSCALE,
    PBItems::TINYMUSHROOM,PBItems::TINYMUSHROOM,PBItems::TINYMUSHROOM,
    PBItems::BIGMUSHROOM,PBItems::BIGMUSHROOM,PBItems::FIRESTONE,PBItems::FIRESTONE,
    PBItems::WATERSTONE,PBItems::WATERSTONE,PBItems::THUNDERSTONE,
    PBItems::THUNDERSTONE,PBItems::LEAFSTONE,PBItems::LEAFSTONE]
  when 1
    ary=[PBItems::GIRAFARIGITE]
    $game_switches[373]=true
  when 2
    ary=[PBItems::DELTASUNFLORITE]
    $game_switches[372]=true
  when 3
    for i in 0..PBNatures.maxValue-1
      ary.push(i)
    end
    # rando=rand(PBNatures.maxValue)###(rand(PBNatures.maxValue))
  end
  $game_variables[126]=ary[rand(ary.length)] if ary.length != 0  
end

def getPokemonRaceMaps(pokemon)
  ary=[]
    #if pbSpeciesCompatible?(pokemon,PBMoves::SURF)
   #   ary.push(["DickFuck",1])
  #  elsif pbSpeciesCompatible?(pokemon,PBMoves::FLY)
   #   ary.push(["DickFuck",1])
    #else
      ary.push(["Flower Fields",1])
      ary.push(["Golden Sands",2])
      ary.push(["Rocky Road",3])
      ary.push(["Ice Path",4])
      #ary.push(["Outer Reaches",5])
  #  end
    return ary
end


def pbStartRace
  $game_variables[1]=$Trainer.party[$game_variables[1]]
  ary=Kernel.getPokemonRaceMaps($game_variables[1].species)
  #ary=Kernel.getPokemonRaceMaps($Trainer.party[$game_variables[1]].species)
  ary2=[]
  for i in ary
    ary2.push(i[0])
  end
  $game_variables[3]=Kernel.pbMessage("Which track would you like to race on?",ary2)
  Kernel.pbMessage("Very well! Have fun!")
  Kernel.pbMessage("Remember- avoid hazards, and try to touch the boosters!")
  Kernel.pbMessage("Good luck!")
  $game_variables[3]=ary[$game_variables[3]][1]
  $game_variables[61]=$game_variables[1]
  $game_variables[63]=[]
  for i in 0..3
    $game_variables[63][i]=0
  end
  
  pbCommonEvent(21)
end

def pbSetRaceSprite
  #$game_variables[1]=$Trainer.party[$game_variables[1]]
  #$game_variables[1]=change_sprite($Trainer.party[0].species, $Trainer.party[0].form,$Trainer.party[0].isShiny?,false,$Trainer.party[0].gender==1)
  append="%03d"
  if $game_variables[1].gender==1 && FileTest.image_exist?("Graphics/Characters/"+sprintf(append+"f",$game_variables[1].species))
    append+="f"
  end
  if $game_variables[1].isShiny?
    append+="s"
  end
  if $game_variables[1].form!=0
    append+=("_"+$game_variables[1].form.to_s)
  end
  pbChangePlayer($PokemonGlobal.playerID,sprintf(append,pbGet(1).species))
  $game_variables[63]=Array.new
  for i in 0..3
    pbGet(63)[i]=0
  end
end

def pbFinishRace(forfeit=false)
  peopleFinishedBefore=0
  if !forfeit
    for i in 1..3
      evi=$game_map.events[i]
      peopleFinishedBefore += 1 if evi.y<=9
    end
    Kernel.pbMessage("Look at that! A spectacular finish by "+$Trainer.name+"'s "+$game_variables[61].name+"!")
    $game_variables[62]=peopleFinishedBefore 
  $game_switches[163]=false
  case $game_variables[62]
      when 0
        Kernel.pbMessage($game_variables[61].name+" takes first place with a time of "+($game_variables[64]/20).to_s+" seconds! Congratulations!")
      when 1
        Kernel.pbMessage($game_variables[61].name+" takes second place with a time of "+($game_variables[64]/20).to_s+" seconds! Well done!")
      when 2
        Kernel.pbMessage($game_variables[61].name+" takes third place with a time of "+($game_variables[64]/20).to_s+" seconds! Nice work!")
      when 3
        Kernel.pbMessage($game_variables[61].name+" takes fourth place with a time of "+($game_variables[64]/20).to_s+" seconds! Better luck next time!")
      end
        else
    $game_variables[62]=3   
    $game_switches[163]=false
  end

  pbCommonEvent(20)    
   # $game_variables[64]
end

  
def pbGetMoveForEvent(eventno)
  return if !$game_switches[137]  
  event=$game_map.events[eventno]
  for evi in 1..$game_map.events.length-1
      if $game_map.events[evi]
        if !$game_map.events[eventno].moving? && $game_map.events[evi].x==event.x && $game_map.events[evi].y==event.y && $game_map.events[evi].name.include?("RAMP")
          event.jump(0,-1)
          return
        end
        if !$game_map.events[eventno].moving? && $game_map.events[evi].x==event.x && $game_map.events[evi].y==event.y && $game_map.events[evi].name.include?("Finish")
          return
        end
        if rand(4) != 0 && !$game_map.events[eventno].moving? && $game_map.events[evi].x==event.x && $game_map.events[evi].y==event.y && $game_map.events[evi].name.include?("AI_TURN_LEFT")
          event.move_left
          return
        end
        if rand(4) != 0 && !$game_map.events[eventno].moving? && $game_map.events[evi].x==event.x && $game_map.events[evi].y==event.y && $game_map.events[evi].name.include?("AI_TURN_RIGHT")
          event.move_right
          return
        end
      end
    end
    closeEvents=[]
    for evno in 1..$game_map.events.length-1
      if $game_map.events[evno] != nil
        ev=$game_map.events[evno]
        if ev.x>event.x-6 && ev.x<event.x+6
          if ev.y<event.y && ev.y>event.y-11
            closeEvents.push(ev)
          end
        end
      end
    end
      
    if !$game_map.events[eventno].moving?
      up=60
      left=2
      right=2
      down=0
      if !event.passable?(event.x, event.y, 8)
        up = 0
        while 1==1
        left += (event.passable?(event.x-1, event.y, 8) ? 128 : -128)
        break if left != right
        right += (event.passable?(event.x+1, event.y, 8) ? 128 : -128)
        break if left != right
        left += (event.passable?(event.x-2, event.y, 8) ? 64 : -64)
        break if left != right
        right += (event.passable?(event.x+2, event.y, 8) ? 64 : -64)
        break if left != right
        left += (event.passable?(event.x-3, event.y, 8) ? 32 : -32)
        break if left != right
        right += (event.passable?(event.x+3, event.y, 8) ? 32 : -32)
        break if left != right
        left += (event.passable?(event.x-4, event.y, 8) ? 16 : -16)
        break if left != right
        right += (event.passable?(event.x+4, event.y, 8) ? 16 : -16)
        break if left != right
        left += (event.passable?(event.x-5, event.y, 8) ? 8 : -8)
        break if left != right
        right += (event.passable?(event.x+5, event.y, 8) ? 8 : -8)
        break if left != right
        left += (event.passable?(event.x-6, event.y, 8) ? 4 : -4)
        break if left != right
        right += (event.passable?(event.x+6, event.y, 8) ? 4 : -4)
        break if left != right
        left += (event.passable?(event.x-7, event.y, 8) ? 2 : -2)
        break if left != right
        right += (event.passable?(event.x+7, event.y, 8) ? 2 : -2)
        break if left != right
        left += (event.passable?(event.x-8, event.y, 8) ? 1 : -1)
        break if left != right
        right += (event.passable?(event.x+8, event.y, 8) ? 1 : -1)
        break if left != right
        left = 0 if !event.passable?(event.x, event.y, 4)
        break if left != right
        right = 0 if !event.passable?(event.x, event.y, 6)
      end
      left = 0 if left < 0
      right = 0 if right < 0
      left = 0 if !event.passable?(event.x, event.y, 4)
      right = 0 if !event.passable?(event.x, event.y, 6)
      if left == right
        left = 1
        right = 0
      end
    

    else
      left = 0 if !event.passable?(event.x, event.y, 4)
      right = 0 if !event.passable?(event.x, event.y, 6)
=begin
    closeEvents=[]
    for evno in 1..$game_map.events.length-1
      if $game_map.events[evno] != nil
      ev=$game_map.events[evno]
        if ev.x>event.x-6 && ev.x<event.x+6
          if ev.y<event.y && ev.y>event.y-11
            closeEvents.push(ev)
          end
        end
      end
    end
    
    for ev in closeEvents
        if ev.y==event.y && ev.x != event.x && ev.name.include?("Speed_Boost")
          up+=((10-(event.y-ev.y).abs)*10).abs
        end
        if ev.y==event.y && ev.x != event.x && ev.name.include?("RAMP")
          up+=((10-(event.y-ev.y).abs)*3).abs
        end

        if ev.name.include?("Speed_Boost") && ev.y!=event.y
        #  up+=((10-(event.y-ev.y))*10)-(10*(ev.x-event.x).abs)
          left+=(10*(ev.y-event.y).abs)/9 if ev.x<event.x
          right+=(10*(ev.y-event.y).abs)/9 if ev.x>event.x
        end

      end
=end
=begin
    for xz in event.x-5..event.x+5
        for yz in event.y..event.y-11
                  if yz==event.y && yx != event.x && pbIsGrassTag?($game_map.terrain_tag(xz,yz))
           #         up-=(10-(event.y-yz))*2
                  end
                  if yz != event.y && pbIsGrassTag?($game_map.terrain_tag(xz,yz))
          #          up-=((10-(event.y-yz))*2)-(2*(yz-event.x).abs)
                    left-=(2*(yz-event.y).abs) if yz<event.x
                    right-=(2*(eyz-event.y).abs) if yz>event.x
                  end
        end
    end
=end
    end
 #raise (up.to_s)
    if up < 0
      up = 0
    end
    if left < 0
      left = 0
    end
    if right < 0
      right = 0
    end
    if down < 0
      down = 0
    end
=begin
  if pbIsGrassTag?($game_map.terrain_tag(event.x,event.y-5)) || pbIsGrassTag?($game_map.terrain_tag(event.x,event.y-4)) || pbIsGrassTag?($game_map.terrain_tag(event.x,event.y-3)) || pbIsGrassTag?($game_map.terrain_tag(event.x,event.y-2)) || pbIsGrassTag?($game_map.terrain_tag(event.x,event.y-1))
    if !pbIsGrassTag?($game_map.terrain_tag(event.x-3,event.y-5))
      if (event.passable?(event.x-2,event.y-5,4) && event.passable?(event.x-1,event.y-5,4) && event.passable?(event.x,event.y-5,4)) || 
      (event.passable?(event.x-2,event.y-4,4) && event.passable?(event.x-1,event.y-4,4) && event.passable?(event.x,event.y-4,4)) || 
      (event.passable?(event.x-2,event.y-3,4) && event.passable?(event.x-1,event.y-3,4) && event.passable?(event.x,event.y-3,4)) || 
      (event.passable?(event.x-2,event.y-2,4) && event.passable?(event.x-1,event.y-2,4) && event.passable?(event.x,event.y-2,4)) || 
      (event.passable?(event.x-2,event.y-1,4) && event.passable?(event.x-1,event.y-1,4) && event.passable?(event.x,event.y-1,4))
        pathfind(event.x-3,event.y-5,event) if rand(10)==0
      end
    end
    
    if !pbIsGrassTag?($game_map.terrain_tag(event.x+3,event.y-5))
      if (event.passable?(event.x+2,event.y-5,4) && event.passable?(event.x+1,event.y-5,4) && event.passable?(event.x,event.y-5,4)) || 
      (event.passable?(event.x+2,event.y-4,4) && event.passable?(event.x+1,event.y-4,4) && event.passable?(event.x,event.y-4,4)) || 
      (event.passable?(event.x+2,event.y-3,4) && event.passable?(event.x+1,event.y-3,4) && event.passable?(event.x,event.y-3,4)) || 
      (event.passable?(event.x+2,event.y-2,4) && event.passable?(event.x+1,event.y-2,4) && event.passable?(event.x,event.y-2,4)) || 
      (event.passable?(event.x+2,event.y-1,4) && event.passable?(event.x+1,event.y-1,4) && event.passable?(event.x,event.y-1,4)) 
        pathfind(event.x+3,event.y-5,event) if rand(10)==0
      end
    end
  end
=end
    if up==left && left==right
      up += 1
      right += 1
    end
    total=up+left+right+down
    #raise(up.to_s+" "+left.to_s+" "+right.to_s+" "+down.to_s)
    var=rand(total)
    if var < up 
      event.move_up
    elsif var >= up && var < up+left
      event.move_left
    elsif var >= up+left && var < up+left+right
      event.move_right
    elsif var >= up+left+right
      #event.move_down
    end
  end
end

def pbGetRandomBerry
    itemAry=[PBItems::CHERIBERRY,PBItems::CHESTOBERRY,
    PBItems::PECHABERRY,PBItems::RAWSTBERRY,PBItems::ASPEARBERRY,
    PBItems::LEPPABERRY,PBItems::SITRUSBERRY,PBItems::PERSIMBERRY,
    PBItems::LUMBERRY,PBItems::CHERIBERRY,PBItems::CHESTOBERRY,
    PBItems::PECHABERRY,PBItems::RAWSTBERRY,PBItems::ASPEARBERRY,
    PBItems::LEPPABERRY,PBItems::SITRUSBERRY,PBItems::PERSIMBERRY,
    PBItems::LUMBERRY,PBItems::CHERIBERRY,PBItems::CHESTOBERRY,
    PBItems::PECHABERRY,PBItems::RAWSTBERRY,PBItems::ASPEARBERRY,
    PBItems::LEPPABERRY,PBItems::SITRUSBERRY,PBItems::PERSIMBERRY,
    PBItems::LUMBERRY,PBItems::OCCABERRY,PBItems::PASSHOBERRY,PBItems::WACANBERRY,
    PBItems::RINDOBERRY,PBItems::YACHEBERRY,PBItems::CHOPLEBERRY,PBItems::KEBIABERRY,
    PBItems::SHUCABERRY,PBItems::COBABERRY,PBItems::PAYAPABERRY,PBItems::TANGABERRY,
    PBItems::CHARTIBERRY,PBItems::KASIBBERRY,PBItems::HABANBERRY,PBItems::COLBURBERRY,
    PBItems::BABIRIBERRY,PBItems::CHILANBERRY]
    item=itemAry[rand(itemAry.length)]
    Kernel.pbReceiveItem(item)
end

def getRecipes
    ary=[
      [[PBItems::ENERGYROOT,1],[PBItems::ENERGYPOWDER,1],[PBItems::BIGROOT,1]],
      
      [[PBItems::BIGROOT,1],[PBItems::FRESHWATER,1],[PBItems::LEFTOVERS,1]],
      
      [[PBItems::FRESHWATER,1],[PBItems::ENERGYROOT,1],[PBItems::MYSTICWATER,1]],
      
      [[PBItems::FRESHWATER,1],[PBItems::ENERGYPOWDER,1],[PBItems::MYSTICWATER,1]],
      
      [[PBItems::HPUP,1],[PBItems::PROTEIN,1],[PBItems::ZINC,1],[PBItems::CARBOS,1],
      [PBItems::IRON,1],[PBItems::CALCIUM,1],[PBItems::RARECANDY,2]],
      
   #   [[PBItems::LAVACOOKIE,1],[PBItems::SITRUSBERRY,1],[PBItems::MAGICCOOKIE,1]],
      [[PBItems::LAVACOOKIE,1],[PBItems::FRESHWATER,1],[PBItems::SPICYCURRY,1]],

      [[PBItems::REVIVE,1],[PBItems::PEARL,1],[PBItems::MAXREVIVE,1]],
      
      [[PBItems::POTION,1],[PBItems::PEARL,1],[PBItems::FULLRESTORE,1]],
      
      [[PBItems::SUPERPOTION,1],[PBItems::PEARL,1],[PBItems::FULLRESTORE,1]],
      
      [[PBItems::HYPERPOTION,1],[PBItems::PEARL,1],[PBItems::FULLRESTORE,1]],
      
      [[PBItems::MAXPOTION,1],[PBItems::PEARL,1],[PBItems::FULLRESTORE,1]],
      
      [[PBItems::ELIXIR,1],[PBItems::PEARL,1],[PBItems::MAXELIXIR,1]],
      
      [[PBItems::ETHER,1],[PBItems::PEARL,1],[PBItems::MAXETHER,1]],
      
       [[PBItems::REVIVE,1],[PBItems::NUGGET,1],[PBItems::MAXREVIVE,1]],
       
      [[PBItems::POTION,1],[PBItems::NUGGET,1],[PBItems::FULLRESTORE,1]],
      
      [[PBItems::SUPERPOTION,1],[PBItems::NUGGET,1],[PBItems::FULLRESTORE,1]],
      
      [[PBItems::HYPERPOTION,1],[PBItems::NUGGET,1],[PBItems::FULLRESTORE,1]],
      
      [[PBItems::MAXPOTION,1],[PBItems::NUGGET,1],[PBItems::FULLRESTORE,1]],
      
      [[PBItems::ELIXIR,1],[PBItems::NUGGET,1],[PBItems::MAXELIXIR,1]],
      
      [[PBItems::ETHER,1],[PBItems::NUGGET,1],[PBItems::MAXETHER,1]],     
      
      [[PBItems::IVSTONE,1],[PBItems::RARECANDY,3],[PBItems::DREAMMIST,1]],
      
      [[PBItems::DREAMMIST,1],[PBItems::RARECANDY,3],[PBItems::IVSTONE,1]],

      [[PBItems::HPUP,10],[PBItems::RARECANDY,3],[PBItems::HPPILL,1]],
      
      [[PBItems::PROTEIN,10],[PBItems::RARECANDY,3],[PBItems::ATKPILL,1]],
      
      [[PBItems::IRON,10],[PBItems::RARECANDY,3],[PBItems::DEFPILL,1]],
      
      [[PBItems::CARBOS,10],[PBItems::RARECANDY,3],[PBItems::SPEEDPILL,1]],
      
      [[PBItems::CALCIUM,10],[PBItems::RARECANDY,3],[PBItems::SPATKPILL,1]],
      
      [[PBItems::ZINC,10],[PBItems::RARECANDY,3],[PBItems::SPDEFPILL,1]]
    ]
    return ary
end


def pbCheckForRecipes
  for recipe in Kernel.getRecipes
    for i in 0..recipe.length-2
      if $PokemonBag.pbQuantity(recipe[i][0]) < recipe[i][1]
        
      else
        return true
      end
    end
  end
end

def doRecipes
  while 1==1
    aryOfRecipes=[]
    for recipe in Kernel.getRecipes
      hasNot=false
      for i in 0..recipe.length-2
      #Kernel.pbMessage(_INTL("Bag: {1}",PBItems.getName(recipe[i][0])))
      #Kernel.pbMessage(_INTL("Required: {1}",recipe[i][1]))
        if $PokemonBag.pbQuantity(recipe[i][0]) < recipe[i][1]
          hasNot=true 
        end
      end
      if !hasNot
          aryOfRecipes.push(recipe)
          #Kernel.pbMessage(_INTL("Result: {1}",aryOfRecipes))
        end
    end
    nameAry=[]
    for i in aryOfRecipes
        nameAry.push(PBItems.getName(i[i.length-1][0]))
    end
  #  look 1==1
    nameAry.push("(None)")
    v=Kernel.pbMessage("Well, what shall I cook for you?",nameAry)
    if v != nameAry.length-1
      Kernel.pbMessage("Ah, yes, wonderful!")
      Kernel.pbMessage("This will require me to use:")
      for i in 0..aryOfRecipes[v].length-2
        #Kernel.pbMessage(aryOfRecipes[v][i][1].to_s)
       # Kernel.pbMessage(PBItems.getName(aryOfRecipes[v][i][0]))
        Kernel.pbMessage(aryOfRecipes[v][i][1].to_s+" of "+PBItems.getName(aryOfRecipes[v][i][0])+".")
      end
      if Kernel.pbConfirmMessage("Is this acceptable?")
        for j in 0..aryOfRecipes[v].length-2
          $PokemonBag.pbDeleteItem(aryOfRecipes[v][j][0],aryOfRecipes[v][j][1])
        end
        Kernel.pbReceiveItem(aryOfRecipes[v][aryOfRecipes[v].length-1][0])
        Kernel.pbMessage("Come back, any time!")
        break
      end
    else
      Kernel.pbMessage("Come back if you want some food!")
      break
    end
  end
end

def getTreats
    ary=[
      PBItems::ASPEARBERRY,PBItems::BALMMUSHROOM,PBItems::BERRYJUICE,
      PBItems::BIGMUSHROOM,PBItems::CASTELIACONE,PBItems::CHERIBERRY,
      PBItems::CHESTOBERRY,PBItems::ENERGYROOT,PBItems::HONEY,
      PBItems::LAVACOOKIE,PBItems::LEFTOVERS,PBItems::LEPPABERRY,
      PBItems::LUMBERRY,PBItems::OLDGATEAU,PBItems::ORANBERRY,
      PBItems::PECHABERRY,PBItems::PERSIMBERRY,PBItems::RAGECANDYBAR,
      PBItems::RARECANDY,PBItems::RAWSTBERRY,PBItems::SITRUSBERRY,
      PBItems::SPICYCURRY,PBItems::SWEETHEART,PBItems::TINYMUSHROOM,
      PBItems::WHIPPEDDREAM
    ]
    return ary
end
  
def getBadTreats
    ary=[
      PBItems::ASPEARBERRY,PBItems::BALMMUSHROOM,PBItems::BERRYJUICE,
      PBItems::BIGMUSHROOM,PBItems::CHERIBERRY,PBItems::CHESTOBERRY,
      PBItems::ENERGYROOT,PBItems::LEFTOVERS,PBItems::LEPPABERRY,
      PBItems::LUMBERRY,PBItems::ORANBERRY,PBItems::PECHABERRY,
      PBItems::PERSIMBERRY,PBItems::RAWSTBERRY,PBItems::SITRUSBERRY,
      PBItems::SPICYCURRY,PBItems::TINYMUSHROOM
    ]
    return ary
end

def doTreats
  treats=Kernel.getTreats
  aryOfTreats=[]
  for i in 0...treats.length
    if $PokemonBag.pbQuantity(treats[i]) > 0
      aryOfTreats.push(treats[i])
    end
  end
  if aryOfTreats.length==0
    Kernel.pbMessage("Hmm...there don't appear to be any items that can be used as treats in the bag.")
    return false
  end
  badTreats=Kernel.getBadTreats
  nameAry=[]
  for i in 0...aryOfTreats.length
    nameAry.push(PBItems.getName(aryOfTreats[i]))
  end
  nameAry.push("(None)")
  v=Kernel.pbMessage("What will you leave behind in the tree?",nameAry)
  if v != nameAry.length-1
    $game_variables[190]=aryOfTreats[v]
    if badTreats.include?($game_variables[190])
      $game_switches[681]=true
    end
    Kernel.pbMessage(_INTL("Left behind 1 {1}.",nameAry[v]))
    $PokemonBag.pbDeleteItem(aryOfTreats[v],1)
    Kernel.pbMessage(_INTL("Try checking back later to see if anything has taken the {1}.",nameAry[v]))
  else
    Kernel.pbMessage("The mystery continues to go unsolved.")
  end
  return true
end

def areThereSponsors
  ary=Kernel.getSortedLegalSponsorInfo
  if ary.length>0
    return true
  end
  
  #for aryLim in ary
  #    return true if $game_variables[65]>aryLim[2]
  #    return true if ($game_variables[66]/$game_variables[65])>=aryLim[3]
  #end
  return false
end

def getRewardFromSponsors
  racesDone=$game_variables[65]-$game_variables[130]
  if racesDone==0
    Kernel.pbMessage("There's no reward availiable from your sponsors right now.")
    Kernel.pbMessage("We apologize for the inconvenience.")
    return false
  end
  moneyMulti=$game_variables[129][3]
  #Kernel.pbMessage(moneyMulti.to_s)
  money=moneyMulti*50*racesDone
  $Trainer.money += money
  Kernel.pbMessage("Obtained $"+money.to_s+"!")
  itemarray=[]
  if $game_variables[129].length>4
    for i in 4..$game_variables[129].length-1
        if (rand(150)+1) <= $game_variables[129][i][1]
          itemarray.push($game_variables[129][i][0])
        end
      end
      for item in itemarray
        Kernel.pbReceiveItem(item)
      end
      
  end
  
$game_variables[130]=$game_variables[65]



end

def getSortedLegalSponsorInfo
  ary1=Kernel.getSponsorInfo
  ary2=[]
  while 1==1
    #Kernel.pbMessage(ary2.length.to_s)
    legal=false
    lowestLegal=-1
    for i in 0..ary1.length-1
      if $game_variables[65]>=ary1[i][1] && ($game_variables[66]/$game_variables[65])>=ary1[i][2]
        if (ary2.length==0 || !ary2.include?(ary1[i])) && (lowestLegal==-1 || ary1[i][3] < ary1[lowestLegal][3])
          lowestLegal=i
        end
      end
    end
    if lowestLegal==-1
      break
    else
      ary2.push(ary1[lowestLegal])
  #    for j in 0..ary2.length-1
    #  end
    end
  end

  return ary2
end

def getSponsorInfo
  #Name, Min Races, Min Ratio, Output, Item #1....
  ary=[
  ["Devon Corp",50,40,225,[PBItems::MASTERBALL,2],[PBItems::ULTRABALL,90],[PBItems::GREATBALL,90],[PBItems::DUSKBALL,90],[PBItems::TIMERBALL,90],
[PBItems::SHINYBALL,5],[PBItems::DELTABALL,5],[PBItems::QUICKBALL,50]],
  
  ["Vileplume Berry Harvest",4,10,30,[PBItems::ORANBERRY,140],[PBItems::SITRUSBERRY,20],[PBItems::RAWSTBERRY,30],[PBItems::LEPPABERRY,45],[PBItems::LUMBERRY,30],[PBItems::PECHABERRY,45]],
  
  ["Vanillite Ice Cream Co.",8,15,25,[PBItems::CASTELIACONE,50]],
  
  ["MooMooMiltank Inc.",15,20,45,[PBItems::MOOMOOMILK,100]],
  
  ["Torren Miners Association",20,21,63,[PBItems::HARDSTONE,10],[PBItems::PEARL,1],[PBItems::FIRESTONE,7],[PBItems::WATERSTONE,7],[PBItems::LEAFSTONE,7],[PBItems::THUNDERSTONE,7]],
  
  ["Pelipper Postal Office",28,25,67],
  
  ["Kricketune Knockoffs",1,-10,9,[PBItems::POTION,140]],
  ["Chespin's Cheaps",3,5,15],
  
  ["Technical Machines Plc.",45,30,130,[PBItems::TM74,10],[PBItems::TM75,10],[PBItems::TM81,10],[PBItems::TM83,10],[PBItems::TM85,10]],
  
  ["Furfrou Fresh Water",18,15,72,[PBItems::FRESHWATER,100]],
  
  ["Charco Roasted Meats",10,16,33],
  
  ["PokeTraptions",25,30,76],
  
  ["Exploud Night Club",14,30,67],
  
  ["ODS Clothing Store",23,25,76],
  
  ["Darkrai Dreamcatchers",12,19,36],
  
  ["Oak Consolidated LLC",26,20,78],
  
  ["Porygon E-Banking",40,15,97],
  
  ["Jolteon Computers",37,35,115],
  
  ["Lapras Luxury Cruises",33,21,96],

  ["Conkeldurr Construction",5,12,20]]

return ary  
  
end

def dropRank
  rank=$game_variables[69]
  if rank!=nil
    case rank
    when "Novice"
      $game_variables[169]=1
    when "Junior"
      $game_variables[169]=3
    when "Veteran"
      $game_variables[169]=5
    when "Victor"
      $game_variables[169]=10
    when "Hero"
      $game_variables[169]=15
    when "Champion"
      $game_variables[169]=20
    when "Master"
      $game_variables[169]=25
    when "Legend"
      $game_variables[169]=30
    when "Lord"
      $game_variables[169]=35
    when "Titan"
      $game_variables[169]=40
    when "Monarch"
      $game_variables[169]=45
    when "Suzerain"
      $game_variables[169]=50
    else
      $game_variables[169]=0
    end
  end
end

  def getPseudoLegendary
    pbChoosePokemon(1,2,
      proc{|poke|(poke.species==PBSpecies::LARVITAR || poke.species==PBSpecies::PUPITAR || 
        poke.species==PBSpecies::TYRANITAR ||
        poke.species==PBSpecies::DRATINI || poke.species==PBSpecies::DRAGONAIR || poke.species==PBSpecies::DRAGONITE ||
        poke.species==PBSpecies::BELDUM || poke.species==PBSpecies::METANG || poke.species==PBSpecies::METAGROSS ||
        poke.species==PBSpecies::BAGON || poke.species==PBSpecies::SHELGON || poke.species==PBSpecies::SALAMENCE ||
        poke.species==PBSpecies::GABITE || poke.species==PBSpecies::GARCHOMP || poke.species==PBSpecies::GIBLE ||
        poke.species==PBSpecies::DEINO || poke.species==PBSpecies::ZWEILOUS || poke.species==PBSpecies::HYDREIGON ||
        poke.species==PBSpecies::SLIGGOO || poke.species==PBSpecies::GOODRA || poke.species==PBSpecies::GOOMY ||
        poke.species==PBSpecies::DELTADRATINI || poke.species==PBSpecies::DELTADRAGONAIR || 
        poke.species==PBSpecies::DELTADRAGONITE ||
        poke.species==PBSpecies::DELTABELDUM1 || poke.species==PBSpecies::DELTAMETANG1 || 
        poke.species==PBSpecies::DELTAMETAGROSS1 ||
        poke.species==PBSpecies::DELTABELDUM2 || poke.species==PBSpecies::DELTAMETANG2 || 
        poke.species==PBSpecies::DELTAMETAGROSS2 ||
        poke.species==PBSpecies::DELTADEINO || poke.species==PBSpecies::DELTAZWEILOUS || 
        poke.species==PBSpecies::DELTAHYDREIGON ||
        poke.species==PBSpecies::DELTASLIGGOO || poke.species==PBSpecies::DELTAGOODRA || 
        poke.species==PBSpecies::DELTAGOOMY)})
  end


  def doPikaTaxi(pay=true)
    scene=PokemonRegionMapScene.new(-1,false)
    screen=PokemonRegionMap.new(scene)
    ret=screen.pbStartFlyScreen
    $PokemonTemp.flydata=ret
    #             @scene.pbStartScene(@party,
    #                @party.length>1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
    if !$PokemonTemp.flydata
      Kernel.pbMessage(_INTL("Come back if you change your mind..."))
    else
      Kernel.pbMessage(_INTL("Let's get going, then!"))
      $Trainer.money -= 500 if pay
      pbFadeOutIn(99999){
        $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
        $game_temp.player_new_x=$PokemonTemp.flydata[1]
        $game_temp.player_new_y=$PokemonTemp.flydata[2]
        $game_switches[172]=false
        if $game_temp.player_new_map_id==238 && $game_switches[391] && !$game_switches[158]
          $game_temp.player_new_map_id=276
        end
        $PokemonTemp.flydata=nil
        $game_temp.player_new_direction=2
        $scene.transfer_player
        $game_player.move_down
        $game_map.autoplay
        $game_map.refresh
        $game_screen.weather(0,0,0)
        weather=pbGetMetadata($game_map.map_id,MetadataWeather)
        $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
      }
      pbEraseEscapePoint 
    end
  end
 

  def doLegendEntrance(legend)
    
    pokemonID4Name={
      "Arceus" => PBSpecies::ARCEUS,
      "Darkrai" => PBSpecies::DARKRAI,
      "Giratina" => PBSpecies::GIRATINA,
      "Groudon" => PBSpecies::GROUDON,
      "Ho-oh" => PBSpecies::HOOH,
      "Landorus" => PBSpecies::LANDORUS,
      "Lugia" => PBSpecies::LUGIA,
      "Mewtwo" => PBSpecies::MEWTWO,
      "Missingno" => PBSpecies::MISSINGNO,
      "Original" => PBSpecies::KYUREM,
      "Genesect" => PBSpecies::GENESECT,
      "Zygarde" => PBSpecies::ZYGARDE,
      "Regigigas" => PBSpecies::REGIGIGAS,

      
      "Reshiram" => PBSpecies::RESHIRAM,
      "Rayquaza" => PBSpecies::RAYQUAZA,
      "Thundurus" => PBSpecies::THUNDURUS,
      "Mew" => PBSpecies::MEW
    }
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999

    if
     (FileTest.image_exist?("Graphics/Pictures/AlchemicalBG_"+legend) &&
     FileTest.image_exist?("Graphics/Pictures/Alchemical_"+legend))
    viewplayer=Viewport.new(0,0,Graphics.width,Graphics.height)
   #viewplayer=Viewport.new(0,0,Graphics.width+16,Graphics.height+40)
    viewplayer.z=99999
    xoffset=(Graphics.width/2)/10
    xoffset=xoffset.round
    xoffset=xoffset*10
    overlay=Sprite.new(viewport)
    overlay.bitmap=Bitmap.new(Graphics.width,Graphics.height)
    pbSetSystemFont(overlay.bitmap)
    #bar1=Sprite.new(viewplayer)
   # bar1.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/AlchemicalBG_"+legend)
  #  bar1.bitmap=BitmapCache.load_bitmap("Graphics/Transitions/bar_transparent")
   # bar1.x=-xoffset
    # Animation
#    10.times do
#      bar1.x+=xoffset/10
#      pbWait(1)
#end
    pbSEPlay("Sword2")

   bar1=AnimatedPlane.new(viewplayer)
   bar1.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/AlchemicalBG_"+legend)
   bar1.opacity=0
   alchemy=AnimatedPlane.new(viewplayer)
   alchemy.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/Alchemical_"+legend)
   alchemy.opacity=0
    eyes=AnimatedPlane.new(viewplayer)
   eyes.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/AlchemicalEyes_"+legend)
   eyes.opacity=0
  zygarde=AnimatedPlane.new(viewplayer)
   zygarde.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/zygarde_animation")
   zygarde.opacity=0
   51.times do
           bar1.ox-=16
     bar1.opacity+=5
     pbWait(1)
   end
   
    100.times do
      bar1.ox-=16
      pbWait(1)
    end
    
    pbPlayCry(pokemonID4Name[legend])
    51.times do
      bar1.ox-=16
      alchemy.opacity+=5
      pbWait(1)
    end
    20.times do
      bar1.ox-=16
      #alchemy.opacity+=5
      pbWait(1)
    end
    51.times do
      bar1.ox-=16
      alchemy.opacity-=5
      pbWait(1)
    end
    30.times do
      bar1.ox-=16
      #alchemy.opacity+=5
      pbWait(1)
    end
    pbPlayCry(pokemonID4Name[legend])
    51.times do
      bar1.ox-=16
      alchemy.opacity+=5
      pbWait(1)
    end
    20.times do
      bar1.ox-=16
      #alchemy.opacity+=5
      pbWait(1)
    end
    51.times do
      bar1.ox-=16
      alchemy.opacity-=5
      pbWait(1)
    end
    30.times do
      bar1.ox-=16
      #alchemy.opacity+=5
      pbWait(1)
    end
    pbPlayCry(pokemonID4Name[legend])
    51.times do
      bar1.ox-=16
      alchemy.opacity+=5
      pbWait(1)
    end
    
    
    40.times do
      bar1.ox-=16
      pbWait(1)
    end
    eyes.opacity=50 if legend!="Original"
    51.times do
      zygarde.opacity+=5 if legend=="Original"
      pbWait(1)
    end
    
#    $game_screen.start_shake(10,10,20) 160 times ->
    for l in 0..8
    pbSEPlay(RPG::AudioFile.new("MiningCollapse",90,100)) rescue nil
      5.times do
        viewplayer.ox+=4
        bar1.ox-=16
        pbWait(1)
      end
    pbSEPlay(RPG::AudioFile.new("MiningCollapse",90,100)) rescue nil

      5.times do
        viewplayer.ox-=4
        bar1.ox-=16
        pbWait(1)
      end
    pbSEPlay(RPG::AudioFile.new("MiningCollapse",90,100)) rescue nil
      5.times do
        viewplayer.ox-=4
        bar1.ox-=16
        pbWait(1)
      end
    pbSEPlay(RPG::AudioFile.new("MiningCollapse",90,100)) rescue nil
      5.times do
        viewplayer.ox+=4
        bar1.ox-=16
        pbWait(1)
      end
      if l<2
        eyes.ox += 512
      end
    end
    

    25.times do
     bar1.ox-=16
     alchemy.opacity-=10
     bar1.opacity-=10
     pbWait(1)
   end
       bar1.dispose
    alchemy.dispose

   25.times do
     #bar1.ox-=16
          eyes.opacity-=10

     pbWait(1)
   end
   
    overlay.dispose
    bar1.dispose
    #player.dispose
    viewplayer.dispose
    handled=true  
  end
 end
#end

=begin
def pbHolonTeleport
  aryOfMaps=[["Settlement Foxtrot",447],
  ["Settlement Oscar",459],
  ["Settlement Alfa",459],
  ["Settlement Juliet",459]]
  aryOfOptions=[]
  aryOfIDs=[]
  for map in aryOfMaps
    if $PokemonGlobal.visitedMaps[map[1]]
      aryOfOptions.push(map[0])
      aryOfIDs.push(map[1])
    end
  end
end

=end

 def useRelicSong
   worked=false
   for i in 1..$game_map.events.length 
      
     ev=$game_map.events[i]
    
   
     if ev && ev.name.include?("usic_Note_Reli") # Bring it here
    #   Kernel.pbMessage(ev.x.to_s + " " + ev.y.to_s)
       if ev.x < $game_player.x + 2 && ev.x > $game_player.x - 2
         if ev.y < $game_player.y + 2 && ev.y > $game_player.y - 2
           if ev.y == $game_player.y && ev.x==$game_player.x
             Kernel.pbMessage("How are you on top of the note?")
             
            else
           worked=true
           $game_system.map_interpreter.pbSetSelfSwitch(ev.id,"D",true,$game_map.map_id)
         #   $game_self_switches[[365,28,"D"]] = true
           $game_map.need_refresh=true
           end
           end
       end
     end
   end
   if !worked
     Kernel.pbMessage("But nothing happened...")
     end
   end
   

def getCrystalCount
  begin
  val=0
  val += $PokemonBag.pbQuantity(PBItems::CRYSTALPIECE)
  for poke in $Trainer.party[i]
    val += 1 if poke.item==PBItems::CRYSTALPIECE
  end
  for box in $PokemonStorage.boxes
    for poke in box.pokemon
      val += 1 if poke.item==PBItems::CRYSTALPIECE
    end
  end

  if val<3 && $game_switches[12]
    $PokemonBag.pbStoreItem(PBItems::CRYSTALPIECE,3-val)
  elsif val>3 && $game_switches[12]
    $PokemonBag.pbDeleteItem(PBItems::CRYSTALPIECE,val-3)
  end
  rescue
  end

end
 
def sortBoxes(algorithm,boxNo=-1)
  #Kernel.pbMessage(boxNo.to_s)
  #put pokemon into array
  aryMons=[]
  if boxNo==-1
    pbEachBoxedPokemon{|pkmn,box|
      aryMons.push(pkmn)
    }
  else
    for j in 0..$PokemonStorage.maxPokemon(boxNo)
      if $PokemonStorage[boxNo][j] != nil
            aryMons.push($PokemonStorage[boxNo][j])
      end
    end
  end

  for x in aryMons
    #  Kernel.pbMessage(x.name + " notdicks")
  end
  #  Kernel.pbMessage(aryMons.length.to_s)
  case algorithm #all algorithms use quicksort (n log n)
  when 0 # Alphabetical (species)
    aryMons.sort!{|x,y|PBSpecies.getName(x.species)<=>PBSpecies.getName(y.species)}
  when 1 # Alphabetical (nickname)
    aryMons.sort!{ |x,y| (x.name)<=>(y.name)}       
  when 2 # Dex Number
    aryMons.sort!{ |x,y| (x.species) <=> (y.species) }     #when 2 # BST
  when 3 # Type
    aryMons.sort!{ |x,y| (x.type1) <=> (y.type1) }     #when 2 # BST
  end
  for x in aryMons
  end
  acc1=0
  if boxNo == -1
    for i in 0...$PokemonStorage.maxBoxes
      for j in 0...$PokemonStorage.maxPokemon(i)
        if aryMons[acc1] != nil
          $PokemonStorage[i][j]=aryMons[acc1]
          acc1 += 1
        else
          $PokemonStorage[i][j]=nil
        end
      end
    end
  else
    for j in 0...$PokemonStorage.maxPokemon(boxNo)
      if aryMons[acc1] != nil
        $PokemonStorage[boxNo][j]=aryMons[acc1]
        acc1 += 1
      else
        $PokemonStorage[boxNo][j]=nil
      end
    end
  end
  # move pokemon from array back into boxes, wipe rest of boxes
end

def checkCrystalPieces(pokepc=false,playerpc=false,pokeparty=false,daycare=false)
  if pokepc
    for i in 0...$PokemonStorage.maxBoxes
      for j in 0...$PokemonStorage.maxPokemon(i)
        if $PokemonStorage[i][j]!=nil
          x=$PokemonStorage[i][j]
          if x.item==PBItems::CRYSTALPIECE
            x.item=0
          end
        end
      end
    end
  end
  
  if playerpc
    if $PokemonGlobal.pcItemStorage && !$PokemonGlobal.pcItemStorage.empty?
      storage=$PokemonGlobal.pcItemStorage
      item=PBItems::CRYSTALPIECE
      qty=storage.pbQuantity(item)
      storage.pbDeleteItem(item,qty)
    end
  end
  
  if pokeparty
    for i in $Trainer.party
      if i.item==PBItems::CRYSTALPIECE
        i.item=0
      end
    end
  end
  
  if daycare
    poke1=$PokemonGlobal.daycare[0][0]
    poke2=$PokemonGlobal.daycare[0][0]
    if poke1!=nil
      poke1.item=0 if poke1.item==PBItems::CRYSTALPIECE
    end
    if poke2!=nil
      poke2.item=0 if poke2.item==PBItems::CRYSTALPIECE
    end
  end
end


 def useTesseract
   worked=false
   tesseractMaps={
       339 => 357, # Safari Zone - don't forget to change the second one!
       357 => 339,
       
       360 => 361,
       361 => 360,
       
       282 => 369,
       369 => 282,
       
       393 => 396, #route 14
       396 => 393,
       
       505 => 508,
       510 => 508,
       511 => 508,
       512 => 508,
       513 => 508,
       514 => 508,
       515 => 508,
       516 => 508,
       
       549 => 551,
       551 => 549,

       452 => 563,
       563 => 452,
       
       443 => 585,
       585 => 443,
       
       363 => 643,
       643 => 363,
       
              662 => 663,
                     663 => 662,

        122 => 764,
        764 => 122
    }
    
    savex=39
                savey=59
    
    
   for i in 1..$game_map.events.length
      
     ev=$game_map.events[i]
    
      
     if ev && ev.name.include?("Tesseract_Spot_1") # Go there
      if $game_map.map_id!=363 || $game_switches[556]
       if ev.x < $game_player.x + 3 && ev.x > $game_player.x - 3

         if ev.y < $game_player.y + 3 && ev.y > $game_player.y - 3
                              $game_temp.player_new_map_id=tesseractMaps[$game_map.map_id]

           worked=true
                  pbFadeOutInWhite(99999){
                  savex=0
                  savey=0
                  if $game_map.map_id==508 # DEEP MANTLE LOGIC
                    for o in 1..$game_map.events.length-1
                      ev2 = $game_map.events[o]
                      next if !ev2.name.include?("HeartSwap_S")
                        mapp=0
                      if ev2.x==33
                        case ev2.y
                          when 16
                            mapp=515
                          when 17
                            mapp=510
                          when 18
                            mapp=511
                          when 19
                            mapp=512
                          when 20
                            mapp=513
                          when 21
                            mapp=514
                          when 22
                            mapp=516
                          else
                            mapp=505
                    
                          end
                        else
                          mapp=505
                        end
                        savex=ev2.x
                        savey=ev2.y
                      $game_temp.player_new_map_id=mapp
                        break
                      end
                      
                    else 
                      mapp=0
                   $game_temp.player_new_map_id=tesseractMaps[$game_map.map_id]
                 end
                 thing=false
                 
                  if tesseractMaps[$game_map.map_id]==662 # mision 5
                    for o in 1..$game_map.events.length-1
                      ev2 = $game_map.events[o]
                      next if !ev2
                      next if !ev2.name.include?("HeartSwap_S")
                        savex=ev2.x
                        savey=ev2.y
                        thing=true
                        break
                      end
                      end                    
                  
                 $game_temp.player_new_x=$game_player.x
                  $game_temp.player_new_y=$game_player.y
                $game_temp.player_new_direction=$game_player.direction
                $scene.transfer_player
                @wait_count = 12 * 2
                if mapp==505
                  for u in 1..$game_map.events.length-1
                    ev3 = $game_map.events[u]
                    next if !ev3.name.include?("DERELICT")
                    ev3.x=savex
                    ev3.y=savey
                    break
                  end
                  
                end
                
                
                
                if thing
                  for u in 1..$game_map.events.length-1
                    ev3 = $game_map.events[u]
                    next if !ev3.name.include?("HeartSwap_S")

                    ev3.x=savex
                    ev3.y=savey
                    ev3.update
                    break
                  end
                  
                end
                
                $game_map.autoplay
                $game_map.refresh

                }
                return
         end
       end
       end
     end
     
     if ev && ev.name.include?("Tesseract_Spot_2") # Bring it here
       if ev.x < $game_player.x + 4 && ev.x > $game_player.x - 4
         if ev.y < $game_player.y + 4 && ev.y > $game_player.y - 4
           if ev.y == $game_player.y && ev.x==$game_player.x
             Kernel.pbMessage("Don't stand directly on the rift!")
             
            else
           worked=true
           $game_system.map_interpreter.pbSetSelfSwitch(ev.id,"D",true,$game_map.map_id)
         #   $game_self_switches[[365,28,"D"]] = true
           $game_map.need_refresh=true
           end
           end
       end
     end
   end
   if !worked
     Kernel.pbMessage("But nothing happened...")
     end
   end
   


#end
=begin
rotations
0==top left
1==top right
2==bottom right
3==bottom left


emitter=15,13
=end
def pbGenerateMirrors
    $game_variables[144]=Array.new
    $game_variables[145]=Array.new
    for i in 0..220
      $game_variables[145][i]=false
    end
    for i in 0..220
      $game_variables[144][i]=0
    end
    
end

def pbTurnMirror(x,y)
  if Kernel.pbConfirmMessage("Would you like to rotate this mirror?")
    Kernel.pbChangeMirror(Kernel.getMirrorAt(x,y))
  else
    $game_variables[148]=40
  end
  
end


def pbChangeMirror(mirrorID)
  if mirrorID < 0
    Kernel.pbMessage("error: no mirror found")
    return
  end
  
  $game_variables[144][mirrorID]+=1
  if $game_variables[144][mirrorID]>3
    $game_variables[144][mirrorID]=0
  end
  #  Kernel.pbMessage(mirrorID.to_s+" "+$game_variables[144][mirrorID].to_s)
  Kernel.pbDrawLasers
end

def translateDir(currDir)
  return (currDir + 2) % 4
end


def pbDrawLasers
  for i in 1..$game_map.events.length-1
      pbMapInterpreter.pbSetSelfSwitch(i,"A",false)
  end
   for i in 0..220
      $game_variables[145][i]=false
    end
  currDir=2
  currX=12#12
  currY=14 
  currY=10 if $game_map.map_id==542#10
  tick=0
  while 1==1
    tick+=1
    currY+=(currDir-1) if currDir==0 || currDir==2
    currX+=1 if currDir ==1
    currX-=1 if currDir ==3
    if activateEventAt(currX,currY)
    #checks if there's a mirror at currX,currY)
       if getMirrorAt(currX,currY)!=-1 && $game_map.events[getMirrorAt(currX,currY)].name.include?("c") #((currX-7)%8)==0 && ((currY-11)%8)==0
            #Kernel.pbMessage(translateDir(currDir).to_s)
            
            currDir=getDirectionReflect(getMirrorAt(currX,currY),translateDir(currDir))
            if currDir<0
               deActivateEventAt(currX,currY)
              break
            end
        end
        else
         break 
       end
      end
   if $game_map.map_id==542
      currX=14
      currY=26
      currDir=2
      tick=0
      while 1==1
        currY+=(currDir-1) if currDir==0 || currDir==2
        currX+=1 if currDir ==1
        currX-=1 if currDir ==3
        if activateEventAt(currX,currY)

          if getMirrorAt(currX,currY)!=-1 && $game_map.events[getMirrorAt(currX,currY)].name.include?("c") #((currX-7)%8)==0 && ((currY-11)%8)==0
 
            currDir=getDirectionReflect(getMirrorAt(currX,currY),translateDir(currDir))
if currDir<0
              deActivateEventAt(currX,currY)

              break
            end
            tick += 1
          end
        else
           break 
          end
        end
        

      end
      $game_variables[148]=20

  for i in 1..$game_map.events.length-1
      pbMapInterpreter.pbSetSelfSwitch(i,"A",false)
      pbMapInterpreter.pbSetSelfSwitch(i,"B",false)

      $game_map.events[i].update  if $game_map.events[i]
      if i==183
     end
   end

end

def getMirrorAt(x,y)
  for i in 1..$game_map.events.length-1
     if $game_map.events[i] && $game_map.events[i].x==x && $game_map.events[i].y==y
    
       return i
        end
      end
      return -1
    end
    
    
def activateEventAt(x,y)
    for i in 1..$game_map.events.length-1
        if $game_map.events[i] && $game_map.events[i].x==x && $game_map.events[i].y==y
            $game_variables[145][i]=true
            return true
        end
      end
      return false
    
end
def deActivateEventAt(x,y)
    for i in 1..$game_map.events.length-1
        if $game_map.events[i].x==x && $game_map.events[i].y==y
            $game_variables[145][i]=false
            return true
        end
      end
      return false
    
end

=begin
-1 = no reflect
0 = up
1 = right
2 = down
3 = left
=end
def getDirectionReflect(mirrorID,fromDir)
  case $game_variables[144][mirrorID]
    when 0
      if fromDir==0
        return 3
      elsif fromDir==3
        return 0
      else
        return -1
      end
    when 1
      if fromDir==0
        return 1
      elsif fromDir==1
        return 0
      else
        return -1
      end
    when 2
      if fromDir==2
        return 1
      elsif fromDir==1
        return 2
      else
        return -1
      end
    when 3
      if fromDir==2
        return 3
      elsif fromDir==3
        return 2
      else
        return -1
      end
  end
  return -1
end

def getSoarAreas
  areas=[
          #[mapID,startx,starty,endx,endy,center]
          [2,145,111,150,118,146,112],
          [3,141,97,153,110,0,0],
          [43,135,87,144,95,143,92],
          [80,125,93,135,98,0,0],
          [81,122,99,128,105,0,0],
          [82,109,95,119,111,116,99],
          [83,109,95,119,111,116,99],
          [126,114,115,121,120,0,0],
          [122,127,87,131,01,0,0],
          [109,117,122,127,128,119,123],
          [128,119,129,126,135,0,0],
          [129,120,136,136,144,125,141],
          [150,121,145,135,151,0,0],
          [151,108,137,117,144,0,0],
          [152,98,138,107,144,101,140],
          [173,87,134,97,146,0,0],
          [175,88,130,94,133,91,131],
          [176,84,121,90,127,0,0],
          [177,84,117,88,119,0,0],
          [178,81,102,91,116,84,111],
          [223,69,112,73,115,0,0],
          [228,67,122,73,130,67,125],
          [229,68,131,73,139,0,0],
          [230,66,141,76,150,71,145],
          [231,68,153,74,159,0,0],
          [232,78,153,88,163,0,0],
          [233,54,133,63,138,0,0],
          [234,41,132,53,144,49,138],
          [235,49,127,53,131,0,0],
          [270,42,145,52,150,0,0],
          [236,46,120,51,126,0,0],
          [237,42,111,51,119,0,0],
          [238,37,95,52,109,44,106],
          [239,37,90,43,93,0,0],
          [239,27,89,35,96,0,0],
          [240,23,76,40,87,32,82],
          [244,28,58,46,72,0,0],
          [393,73,47,82,55,0,0],
          [245,48,58,57,70,49,59],
          [246,52,48,56,55,0,0],
          [247,51,35,59,47,54,45],
          [287,67,38,73,47,0,0],
          [288,59,43,66,48,0,0],
          [391,84,48,93,58,86,56],
          [393,73,47,82,55,0,0],
          [397,96,47,105,55,0,0],
          [399,106,55,121,65,109,62],
          [441,109,65,119,72,0,0],
          [400,119,48,127,55,0,0],
          [401,121,32,129,45,0,0],
          [405,119,16,128,30,120,26],
          [406,118,7,130,15,0,0],
          [409,132,56,141,68,0,0],
          [407,129,69,141,75,139,70],
          [408,160,62,168,68,164,65],
          [528,78,79,85,87,0,0],
          [412,161,33,160,61,0,0],
          [421,163,24,169,29,166,27],
          [425,148,143,154,149,0,0],
          [527,67,66,82,78,77,67],
          [527,149,172,159,182,0,0],
                    [765,173,124,179,133,177,129], # pit of snakes
                    [738,25,178,29,182,27,180], # pit of snakes
          [798,69,17,82,27,76,19],# Dev island
          [78,0,0,0,0,119,123], #secret bases 
          [115,0,0,0,0,119,123], #secret bases 
          [118,0,0,0,0,119,123], #secret bases 
          [164,0,0,0,0,119,123], #secret bases 
          [189,0,0,0,0,119,123], #secret bases 
          [353,0,0,0,0,119,123], #secret bases 
          [389,0,0,0,0,119,123], #secret bases 
          [730,0,0,0,0,119,123], #secret bases 
          [728,0,0,0,0,119,123], #secret bases 
          [726,0,0,0,0,119,123]] #secret bases 

      return areas
    end
    
    
    
    
    
    
    def getSoarAreasHolon
  areas=[
          #[mapID,startx,starty,endx,endy,center]
          [447,44,114,54,129,46,120], #foxtrot
          [451,39,90,57,111,0,0],  #grasslands
          [459,61,89,73,95,67,92], # oscar
          [453,64,99,78,114,0,0], #desert
          [452,76,77,92,95,0,0], #marsh
          [488,56,68,73,84,0,0], #lake
          [461,60,54,69,62,64,57], #alfa
          [454,74,51,91,68,0,0], # jungle
          [455,59,30,74,50,0,0], # mountain
          [460,61,22,67,28,63,25], # juliet
          [769,116,11,121,16,27,64], # lost pond
          [456,62,16,67,21,0,0]]
        #  [769,117,12,120,15,]   # volcano
          
          
          
          
          
      return areas
    end
    
    
    
    
    
    
    
    
    
    
    
 def interactWithSoarEvent
   healspot=pbGetHealingSpot(@mapX,@mapY)
        if healspot && $PokemonGlobal.visitedMaps[healspot[0]]
        end
      end
      
   
def runSoaringOdds
  if $game_map.map_id==676
    for ev in $game_map.events.values
      if ev.name.include?("rand")
        if ev.name.include?("pelipper") && rand(1)==0# && rand(3)==0
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("altaria") && rand(3)==0 #&& rand(3)==0
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("swellow") && rand(3)<2 #&& rand(3)==0
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("drifblim") && rand(6)==0# && rand(3)==0
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("braviary") && rand(6)==0 #&& rand(3)==0
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("salamence") && rand(24)==0 #&& rand(3)==0
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("wailord") && rand(3)==0 #&& rand(3)==0
          ev.tempSwitches["A"]=true
        end
        
      end
    
    end
  end
  

   if $game_map.map_id==749
    for ev in $game_map.events.values
      if ev.name.include?("rand")
        if ev.name.include?("pelipper") && rand(1)==0# && rand(3)==0 #skiploom
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("staraptor") && rand(3)==0 #&& rand(3)==0 #altaria
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("pidgeot") && rand(3)<2 #&& rand(3)==0 #swellow
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("sigilyph") && rand(6)==0# && rand(3)==0 #drifblim
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("skarmory") && rand(6)==0 #&& rand(3)==0 #braviary
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("dragonite") && rand(24)==0 #&& rand(3)==0 #salamence
          ev.tempSwitches["A"]=true
        end
        if ev.name.include?("drifblim") && rand(3)==0 #&& rand(3)==0
          ev.tempSwitches["A"]=true
        end
        end
      end
    
    end 

  $game_map.need_refresh=true
  
  
end
=begin
def checkTeamLegal
  legalCount=0
  for poke in $Trainer.party
    if poke.eggsteps<1
      
    end
    






end

=end

### BEANS ###
def compileFrontierData(doubles=false)
    txtSource="Data/rocketsingles.txt"
    txtSource="Data/rocketdoubles.txt" if doubles
    arrayOfMons=[]
    File.open(txtSource,"r"){|f|
        i=0
        if "hay" =~ /hay/
          Kernel.pbMessage("haytest")
        end
        if "#hay" =~ /\#hay/
          Kernel.pbMessage("#test")
        end
        if "#hay" =~ /\#.*/
          Kernel.pbMessage("#test2")
        end
        
        
        f.each_line {|line|
        if !(line =~ /\#.*/)# && !(line =~ /\ss*/)
          if line =~ /[a-zA-Z]/
            ln=line.split(",")
            pkmn=PokeBattle_Pokemon.new(parseSpecies(ln[0]),ln[1].to_i)
            pkmn.item=parseItem(ln[2])
            pkmn.moves[0]=PBMove.new(parseMove(ln[3])) if ln[3] != ""
            pkmn.moves[1]=PBMove.new(parseMove(ln[4])) if ln[4] != ""
            pkmn.moves[2]=PBMove.new(parseMove(ln[5])) if ln[5] != ""
            pkmn.moves[3]=PBMove.new(parseMove(ln[6])) if ln[6] != ""
            pkmn.setAbility(ln[7].to_i)
            #pkmn.setGender(ln[8].to_i)
            pkmn.form=ln[9].to_i
            pkmn.setNature(parseNature(ln[11]))
            for ivs in 0...6
              val=ln[12].to_i
              #Kernel.pbMessage(_INTL("Val " + ivs.to_s + ": {1}",val))
              pkmn.iv[ivs]=val
              #Kernel.pbMessage(_INTL("IV: {1}",pkmn.iv[ivs]))
            end
            #for ivs in 0..6
            #  Kernel.pbMessage(_INTL("{1}",pkmn.iv[ivs]))
            #end
            pkmn.happiness=ln[13].to_i
            setEVs(pkmn,ln[16].to_i)
            #for ivs in 0...6
            #  Kernel.pbMessage(_INTL("EV " + ivs.to_s + ": {1}",pkmn.ev[ivs]))
            #end
            arrayOfMons[i]=pkmn
          else
            i=line.to_i
          end
        end
        }
      }
#  File.close("Data/rocketsingles.txt")
    save_data(arrayOfMons,"Data/rocketdoubles.dat")
  #raise "end"
  return arrayOfMons
end
def setEVs(pokemon,id)
  ### BEANS ###
#def setEVs(pokemon,id,idx)
    #Kernel.pbMessage(_INTL("2: {1}",id))
    #if id==nil
    #  id=0
    #end
    #case idx
    #when 0
    #  pokemon.ev[0]=id #HP
    #when 1
    #  pokemon.ev[1]=id #Attack
    #when 2
    #  pokemon.ev[2]=id #Defense
    #when 3
    #  pokemon.ev[4]=id #Special Attack
    #when 4
    #  pokemon.ev[5]=id #Special Defense
    #when 5
    #  pokemon.ev[3]=id #Speed
    #end
    #for i in 0...6
    #  if pokemon.ev[i]==nil
    #    pokemon.ev[i]=0
    #  end
    #end
    pokemon.ev[0]=252 if id > 0 && id < 6 #HP
    pokemon.ev[1]=252 if id==1 || id==6 || id==7 || id==8 || id==9 #attack
    pokemon.ev[2]=252 if id==2 || id==6 || id==10 || id==11 || id==12 #defense
    pokemon.ev[3]=252 if id==3 || id==7 || id==10 || id==13 || id==14 #speed
  #  Kernel.pbMessage("speed "+pokemon.name) if id==3 || id==7 || id==10 || id==13 || id==14
    pokemon.ev[4]=252 if id==4 || id==8 || id==11 || id==13 || id==15 #spatk
    pokemon.ev[5]=252 if id==5 || id==9 || id==12 || id==14 || id==15#spdef
end

   def parseItem(item)
  clonitem=item.upcase
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBItems,clonitem,
     _INTL("Undefined item constant name: %s\r\nName must consist only of letters, numbers, and\r\nunderscores and can't begin with a number.\r\nMake sure the item is defined in\r\nPBS/items.txt.\r\n{1}",
     FileLineData.linereport))
end

def parseSpecies(item)
  clonitem=item.upcase
  clonitem.gsub!(/^[\s\n]*/){}
  clonitem.gsub!(/[\s\n]*$/){}
  clonitem="NIDORANmA" if clonitem=="NIDORANMA"
  clonitem="NIDORANfE" if clonitem=="NIDORANFE"
  return pbGetConst(PBSpecies,clonitem,_INTL("Undefined species constant name: [%s]\r\nName must consist only of letters, numbers, and\r\nunderscores and can't begin with a number.\r\nMake sure the name is defined in\r\nPBS/pokemon.txt.\r\n{1}",FileLineData.linereport))
end

def parseMove(item)
  clonitem=item.upcase
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBMoves,clonitem,_INTL("Undefined move constant name: %s\r\nName must consist only of letters, numbers, and\r\nunderscores and can't begin with a number.\r\nMake sure the name is defined in\r\nPBS/moves.txt.\r\n{1}",FileLineData.linereport))
end

def parseNature(item)
  clonitem=item.upcase
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBNatures,clonitem,_INTL("Undefined nature constant name: %s\r\nName must consist only of letters, numbers, and\r\nunderscores and can't begin with a number.\r\nMake sure the name is defined in\r\nthe script section PBNatures.\r\n{1}",FileLineData.linereport))
end
       
def getTrainerForUsername(trainer)
  #begin
  $network = DeukNetwork.new
  $network.open
  #  Kernel.pbMessage(trainer)
  $network.send("<GETBAT|username=#{trainer}>")
  time1 = Time.now
  loop do
    message = $network.listen
    if message != nil && message != ""
      case message
      when /<BASETRA result=(.*) trainer=(.*)>/
        $network.send("<DSC>")
        if $1.to_i != 1
          return false
        else
                     
=begin
          val=[JSON.encode(trainertemp)].pack("m")
=end
          File.open("ah1", "wb"){|f|
             f.write($2)
          }
          trainer=JSON.decode($2.to_s.unpack("m")[0])
          tr = objecttotrainer(trainer)
          return tr
        end
      end
    end
    if (Time.now - time1).to_i > 100
      break
    end
  end
  $network.send("<DSC>")
  return false
  # rescue
  # end
end
    

def objecttotrainer(tr)
  trainer = PokeBattle_Trainer.new(tr["name"],tr["trainertype"].to_i)
  for i in 0..(tr["party"]).length - 1
      trainer.party[i]=GTSHandler.objecttobattler(tr["party"][i])
  end
  #trainer.gender = tr["gender"]
  trainer.custom = tr["custom"]
  #raise "boom "+ tr["clothes"][0].to_s + " "+tr["clothes"][1].to_s if tr["clothes"].is_a?(Array)
  for i in 0..5
    trainer.clothes[i] = tr["clothes"][i].to_i
  end
  return trainer
end


def setSpriteTrainerBase(trainer,spriteID)
  
=begin
  charbitmap needs to be changed
  @character_sprites
  @spritesets[map]
  @spritesets
=end
  #raise $scene.spriteset.character_sprites[spriteID]
  #charbitmap=$scene.spriteset.character_sprites[spriteID].charbitmap
    for sprite in $scene.spriteset.character_sprites
      if sprite.character.is_a?(Game_Event)
        if sprite.character.name.include?("PC 0") 
          #character_name="trchar001"
          #sprite.update
          charbitmap=sprite.charbitmap
        end
      else
     #   sprite.update
      end
    end

    append="/"

    
#          sprite = Sprite_Character.new(@viewport1, @map.events[i])
#      @character_sprites.push(sprite)
#      @reflectedSprites.push(ReflectedSprite.new(sprite,@map.events[i],@viewport1))

  for i in 0...5
    #raise i.to_s
    #i=0
       #   Kernel.pbMessage(trainer.clothes[i].to_s)

    trainer.clothes[i] = 0 if trainer.clothes[i]==nil 
  end
     # Kernel.pbMessage(trainer.clothes[5].to_s)
    if trainer.clothes[4] >= 0 && trainer.clothes[3] >= 0 && trainer.clothes[2] >= 0 && trainer.clothes[1] >= 0 && trainer.clothes[0] >= 0 
    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"pants#{trainer.clothes[4]}")
    charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))    
          
        bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"shirt#{trainer.clothes[2]}")
    charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))

    
         bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"coat#{trainer.clothes[1]}")
    charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))

    bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"backpack#{trainer.clothes[3]}")
    charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
  #if $PokemonGlobal.playerID>0
          
            bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"hair#{trainer.clothes[5]}")
    charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
    if trainer && trainer.clothes && trainer.clothes[0] && trainer.clothes[0] >= 806 && trainer.clothes[0] <= 809 && trainer.gender==1
        append = append+"f"
    end
    
        bittrip=BitmapCache.load_bitmap("Graphics/Characters/Clothes"+append+"hat#{trainer.clothes[0]}")
    charbitmap.bitmap.blt(0,0,bittrip,Rect.new(0,0,bittrip.width,bittrip.height))
  end
end



	def makeTeamString
		pokemonArray=[]
		for poke in $Trainer.party
			poke.abilityflag="nil" if !poke.abilityflag
			if !poke.isShiny?
				shininess=0
			else
				shininess=1 
			end
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
				poke.abilityflag,
        poke.pokerus
			]
			for var in pokemonArray
				var=var.to_s
			end
			pokemonArray.push(varArray.join("^%*"))
		end
		mons=pokemonArray.join("/u/")
		return mons
	end

def eliteFourDifficulty(hard=false)
  if [428,429,430,431,491,774].include?($game_map.map_id)
    if $PokemonSystem.chooseDifficulty==1 && !hard
        return true
    end
    if $PokemonSystem.chooseDifficulty==2 && hard
        return true
    end
  end
  return false
end