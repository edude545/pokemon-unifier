def getRandomEggNicknameFor(pkmn)
  case pkmn
    when PBSpecies::BULBASAUR
      ary=["Brutus","Floraxion","Teabell","Spuds","Big Meech","JPP","Jurassic",
      "Mossflower","The One","Thickums","Shrek","Poison Ivy","Leaf","Axel",
      "Triassic"]
    when PBSpecies::CHARMANDER
      ary=["Smaug","Rocks","Dracossack","Natsu","Greymon","Pyrao","Caliburn",
      "Torch","Nova","Charcoal","Fire Baby","Rathalos","Big Meech","Salamander",
      "Blaze","Peril","Meteor","Morpheus","Pat Boivin","Blaize","Vetro"]
      when PBSpecies::SQUIRTLE
      ary=["Squirter","Shellshocker","Turtleface","Koopa","Squirtlocke","Leonardo",
      "Bubbles","True Blue","Raphael","Donatello","ARMCANNONS","Hydroxide",
      "Crush","Squad"]
    when PBSpecies::CATERPIE
      ary=["Kathy","Stormageddon","Freedom","Trogdor","Arabesque","Destruction",
      "Power","Buggy"]
    when PBSpecies::WEEDLE
      ary=["Weevil","Underwood","Sting","Hakuna","Oppression","Grunt",
      "Hornet","Britt Reid"]
    when PBSpecies::KRABBY
      ary=["BttrThnCrwdnt","Crab","Deikan"]
    when PBSpecies::PIDGEY
      ary=["Chip","BirdJesus","Amelia","Alexa","Aska","Pierrot","Brian","Scribes"]
    when PBSpecies::RATTATA
      ary=["TOPPERCENT","Joey","Mus","Gunner"]
    when PBSpecies::SPEAROW
      ary=["Phobos","Arrow","Orlando","Juliet","BirdXenu"]
    when PBSpecies::EKANS
      ary=["Medusa","Dave","Jafar","Destro","Jessie","Quiver","Temptation","Jessie"]
    when PBSpecies::SANDSHREW
      ary=["Drew","Abram","Bullet","Lee","Dillon","Pangolin","Slasher","Deathmole"]
    when PBSpecies::NIDORANfE
      ary=["Nido-chan","She-Bob","Isabella","Beyonce"]
    when PBSpecies::NIDORANmA
      ary=["Nido-kun","Caesar","Ferdinand","Orion","Jay-Z","Iskandar"]
    when PBSpecies::VULPIX
      ary=["Kiara","Naruto","Inari","Amber","Kurama","Kitsune","Kyuubi","Willow","Bubbles","Hurik"]
    when PBSpecies::ZUBAT
      ary=["Wayne","BruceWayne","Nosferatu","Carmilla","Vlad","DarkKnight","Vylk","Annoying","Brobat",
      "Exile","Ophelia"]
    when PBSpecies::ODDISH
      ary=["Oddball","Flora","Erika","Herbert","Addict","Nuptup","Normalish","Happy"]
    when PBSpecies::PARAS
      ary=["Helen","Underwood","Zombie","Infected","Mushroom","Zoeya"]
    when PBSpecies::VENONAT
      ary=["Evil Furby","Furby","Pest","Lyssa","Koga","ATV","AATTVVV","Viola"]
    when PBSpecies::DIGLETT
      ary=["Doug","Richter","Unbodied","Avogadro","Unoriginal"]
    when PBSpecies::MEOWTH
      ary=["Claws","Kismet","Goldie","Crook","Nya","Narbles","Giovanni"]
    when PBSpecies::PSYDUCK
      ary=["Rubber","Riisotto","Rene","God","Lynn","Quack","Helmsman"]
    when PBSpecies::MANKEY
      ary=["Pork-Chop","Gung-Ho","Straw","ChimpChamp","Rogue"]
    when PBSpecies::GROWLITHE
      ary=["Woof","Hotdog","Buddy","Ludwig","N-Dizzle","Sergeant","Flare",
      "Ouaf","Kane","Buffy","Rawrrawr","Aiden"]
    when PBSpecies::POLIWAG
      ary=["Snoop","Puddle","Toady","Satoshi","Swag","Paulie","Poliswag"]
    when PBSpecies::ABRA
      ary=["Pietro","Psycho","Sabrina","Dumbledore","Gandalf","Mage","Grindelwald",
      "Elysium","Harvy","Wheaties","UriGeller","Argneir"]
    when PBSpecies::MACHOP
      ary=["Ryu","OldSpiceGuy","Fighter","Vince","Drax","Cesaro","Bork Lazer","Vishnu",
      "Strongman"]
    when PBSpecies::BELLSPROUT
      ary=["Drake","Bellarus","Vice","Lily","Toothy","Venus","IAteMyTrainer","Weed"]
    when PBSpecies::TENTACOOL
      ary=["Squilliam","LL Cruel Jr","Gelato","Cthulhu","Leebin"]
    when PBSpecies::GEODUDE
      ary=["Sandfroid","Detritus","Tank","Dillon","Rocky","Aquadude",
      "Gaia","RockNRoll","RobVanDam"]
    when PBSpecies::PONYTA
      ary=["Apocalypse","Blazehoof","Ardor","MyLittleNO","Jasper","Charcolt",
      "Twilight"]
    when PBSpecies::SLOWPOKE
      ary=["King Poke","Confuscius","Azelea","Decimation","Slouch"]
    when PBSpecies::MAGNEMITE
      ary=["PKSparkxx","Wall-Z","Cadmium","Magneto","Annihilation","Nue","Flux",
      "Bzzt"]
    when PBSpecies::FARFETCHD
      ary=["Malarkey","Devastation","Quacklin","LEEKLORD","WhenPigsFly","Howard"]
    when PBSpecies::DODUO
      ary=["Doddsy","Darwin","Hydra","Skitzo","Penou","Triforce","SixEyes","Headcopter"]
    when PBSpecies::SEEL
      ary=["Bad Name","Bubbles","Seal","Walnor","Navy","Blubber"]
    when PBSpecies::GRIMER
      ary=["Mira","Experiment","Graham","Pollution","Sludge","Slime","Fudge"]
    when PBSpecies::SHELLDER
      ary=["Link'd","Oliver","Bad Joke","Smasher","Spearshot"]
    when PBSpecies::GASTLY
      ary=["King Boo","Hitchcock","Elvis","Nox","Mittens","Toxon",
      "Unshell'd","Spiritos","Gasser","Sting","Cheshire","Midnight","Specter",
      "Blight","Morty"]
    when PBSpecies::ONIX
      ary=["Brock","Onua","Prism","Terra","Quarry","Carnegie","Medusa"]
    when PBSpecies::NOSEPASS
      ary=["NOSE","MUSTACHE"]
    when PBSpecies::DROWZEE
      ary=["Sorcerer","Piper","Master"]
    when PBSpecies::VOLTORB
      ary=["Xzibit","Pokeball","Deidara","Atom","Esphere","Explosion","Splodey"]
    when PBSpecies::EXEGGCUTE
      ary=["Facepalm","Benedict","Lemons","Samuel","Arnold"]
    when PBSpecies::CUBONE
      ary=["Issues","Ysabel","Orphan","Joey","BoneWarrior","Protector","Birger","Ayla","Clubber"]
    when PBSpecies::LICKITUNG
      ary=["Whipit","Tom","Thong","Linguist"]
    when PBSpecies::KOFFING
      ary=["Smaug","Smogon","Rubella","Mustard","James","Writhe","Gaston",
      "COFFEE","Koga"]
    when PBSpecies::RHYHORN
      ary=["Giovanni","Rex","Ryan","Rhyno"]
    when PBSpecies::TANGELA
      ary=["Knotts","Hairbrush","Typhoid","Hairspray"]
    when PBSpecies::KANGASKHAN
      ary=["Kangaroo Jack","MommaBear","Lisa","Smogonaroo","Miss VGC"]
    when PBSpecies::HORSEA
      ary=["Juvia","Atlantis","Seabiscuit","Cavalier","Aphrodite","Bub","Amphitrite",
      "Dragunov","Hera","Bubbles","Juan","Ellie","Poseidon"]
    when PBSpecies::GOLDEEN
      ary=["Santiago","Dean","Nemo","Martin"]
    when PBSpecies::STARYU
      ary=["Patrick","Misty","Konata","Xephos"]
    when PBSpecies::SCYTHER
      ary=["JazzyTazzy","SuperSentai","Xerses","Reaper","Cecil","Kha'zix","Slicer","Karkat","Reapress","Edward","Bugsy","Shinigami","BeatsPaper","Julius","Scissors"]
    when PBSpecies::PINSIR
      ary=["Sir Pin","Stag","Death Grip","Free Hugs","Killer Bug","Guillotine"]
    when PBSpecies::TAUROS
      ary=["Bullion","Bully","Gonzo"]
    when PBSpecies::MAGIKARP
      ary=["God","Doctor Karp","Worthless","Vic","Carpe Diem","Swim Shady","Sweeper","Magiccrap","Percival","BOWB4ME"]
    when PBSpecies::LAPRAS
      ary=["T-Pain","LADpras","Poseidon","Neptune","Loosha","Nessie"]
    when PBSpecies::DITTO
      ary=["Vegas","Whatever","Lover","Mewthree","Clayface"]
    when PBSpecies::EEVEE
      ary=["Eon","Aurora","Bob","Racecar","Darwin","Fluff ball","eeveE","Evarian","Gary","Furball","Flouf","Tora","Stevie","Choices","Caspian","Carrie","Moonmist","Conan","Swageon","TwitchJoke","Stefan","Blue"]
    when PBSpecies::PORYGON
      ary=["cmdrd","Datapwnz",".jpg","Linux","Porygon3","Blender","ERR404","Zeta","Emotion","01010100"]
    when PBSpecies::OMANYTE
      ary=["Lord Helix","27thLord","Herkimer","LORD HELIX","HIS HOLINESS","Cthulhu","Spiral"]
    when PBSpecies::KABUTO
      ary=["Anarchist","Samurai","Kallan","Reaper","PreGenesect"]
    when PBSpecies::AERODACTYL
      ary=["Pazuzu","Jafar","Thistle","Pterry"]
    when PBSpecies::SNORLAX
      ary=["Kumbhkarn","Lazy","Sloth"]
    when PBSpecies::DRATINI
      ary=["Barney","Dragoon","Laolith","Patrick","Draciel","Puff","Musette","Dakota","Fabius","Pebble","Clair","Katie"]
    when PBSpecies::CHIKORITA
      ary=["Chai","Sage","Feuille","Planta","Saffron","PeachyKeen","Perosa","Hannah","Herbie"]
    when PBSpecies::CYNDAQUIL
      ary=["Blaze Run","Ignatius","Bakudan","Pyro","Axel","Blaze","Hephaestus","Vulcan","Volcano","420Blazeit","Tybrosion"]
    when PBSpecies::TOTODILE
      ary=["InteriorCA","Steve Irwin","Hook","Arlong","Sobek","Sploosh","PirateBay","Lazorgator"]
    when PBSpecies::SENTRET
      ary=["Scout","Vergil","Bo","Drummer","Slink"]
    when PBSpecies::HOOTHOOT
      ary=["Dr. Hoot","Athena","Minerva","Hedwig","Nocturne"]
    when PBSpecies::LEDYBA
      ary=["Ladybugz","Junior","Kepler","Hexaped","Stinkoman"]
    when PBSpecies::SPINARAK
      ary=["RonWeasley","Oberyn","Aragog","Ariadne","Yamame","Anansi","Yokai","Georg"]
    when PBSpecies::CHINCHOU
      ary=["Jabun","Illuminati","Deeplight","Trapfish"]
    when PBSpecies::PICHU
      ary=["Voltage","Flashbolt","Surge","Teddy","Cheese","Quark","Gertrude","Aloysius","Lt. Surge","Sparky","Bolt","Misaka","Wattage","Ash","Swagichu","Shocker","Sparkra","Sparky","Ori","Zeus","Jupiter","Cheese","Basil","Voltaire","Joltie"]
    when PBSpecies::CLEFFA
      ary=["Luna","Ford","Luma","Martian"]
    when PBSpecies::IGGLYBUFF
      ary=["Zoeya","Zoey","Selena","Squigglymuff","Bouncer","Zeppelin","YoomTAH"]
    when PBSpecies::TOGEPI
      ary=["Misty","Metronome","Eggbert","Humpty","BigBird","Papabird","Paraflinch","Tanker","Hatchling","Bliss","Euphoria","Utopia","Hardboiled"]
    when PBSpecies::NATU
      ary=["So Raven","views","Watchtower","DOOT DOOT","Seer"]
    when PBSpecies::MAREEP
      ary=["Mary","Amphabulous","Tesla","Edison","Shelly","Voltaire","Ovis","Coulamb","Ampere","Bipen","Fluffy","Sparkle","AndroidsDream","Volted","Popcorn","Gold"]
    when PBSpecies::AIPOM
      ary=["Handtail","Dexter","Pinkie","Clapper","Handy"]
    when PBSpecies::HOPPIP
      ary=["Dandy","Skippy","Dandelion"]
    when PBSpecies::YANMA
      ary=["Yang","Zip","Jack Bauer","Zeppelin","Hindenberg"]
    when PBSpecies::WOOPER
      ary=["Woooop","Quagmire","Derp","Elodie","Muddy","Hmm?","Janet","Arsenio"]
    when PBSpecies::MURKROW
      ary=["Dandylion","Quoth","Don","Murder","Morigan","Vespera","Nevermore","Layton","Bloodraven","Heath","Witchbird","Coroner","Narumi","Pilgrim","DatSoRaven"]
    when PBSpecies::MISDREAVUS
      ary=["Mystique","Weatherwax","Fantina","Midna"]
    when PBSpecies::UNOWN
      ary=["Alpha-bits","SpookyLetter","LETTERS"]
    when PBSpecies::GIRAFARIG
      ary=["Hannah","Neckbird","Twofaced","OGiraffe"]
    when PBSpecies::PINECO
      ary=["Explode","Bill","Bastion","Fortress","Piney","Stronghold","Pikey","Turret"]
    when PBSpecies::DUNSPARCE
      ary=["Megasparce","God","Arceus","Stan","Augur","Quixote","Dun-Dun","Sparcey","Derp","Sparced","Divinity","Holiness"]
    when PBSpecies::GLIGAR
      ary=["Vespers","Wayne","Bruce","Darkleer","Peach","HR Gligar","Facepumper","Repulsa"]
    when PBSpecies::SNUBBULL
      ary=["Hubble","Jeremy","Drax","Ashley","Rabble"]
    when PBSpecies::QWILFISH
      ary=["Qwilideux","Pierce","Gourmet","Bloat"]
    when PBSpecies::SHUCKLE
      ary=["Shuck Norris","Oran","BerlinWall","Shuckaduck","Juice"]
    when PBSpecies::HERACROSS
      ary=["Juno","Hammerhead","Mohammed","PunchBuggy"]
    when PBSpecies::SNEASEL
      ary=["Renegade","Hanzo","Kyara","Fatima","Blink","Isis","Streya"]
    when PBSpecies::TEDDIURSA
      ary=["Tovarishch","Desmond","Copyleft","Honey","Teddy","Ditka","Stalin","Lenin"]
    when PBSpecies::SLUGMA
      ary=["Ambrym","Caldera","Snelly","Slugga"]
    when PBSpecies::SWINUB
      ary=["Fort Minor","Truffles","Bovis","Horatio","Dragon","ChocolateBar","Gaia","Pryce","Tauntaun"]
    when PBSpecies::CORSOLA
      ary=["Epsom","Coral","Reef","Australia"]
    when PBSpecies::REMORAID
      ary=["Colt","Bess","Remington","Gatling","Bullet","Rifle","DrOctopus"]
    when PBSpecies::DELIBIRD
      ary=["Hogfather","Klaus","Clause","SANTAAA!","Swagbird","Kowalski"]
    when PBSpecies::SKARMORY
      ary=["Falchion","Toledo","Maxim","Eyan","Songbird","Starscream"]
    when PBSpecies::HOUNDOUR
      ary=["Dante","Pluto","Dober","Hellhound","Blister","Inferno","Sirius","Cuddles","Skulldown"]
    when PBSpecies::PHANPY
      ary=["Packy","Dumbo","CircusPeanuts","Stampy"]
    when PBSpecies::STANTLER
      ary=["Prongs","Tony","Blitzen","Rudolph","Comet","Vixen","Prancer"]
    when PBSpecies::SMEARGLE
      ary=["Picasso","DeviantArt","Kahlo","Renoir","Salvador"]
    when PBSpecies::TYROGUE
      ary=["Tyrone","Sensei","Rocky","Bruce","Tyrus","Ryu","Chuck","Erasmo"]
    when PBSpecies::SMOOCHUM
      ary=["MJ","Nicki","Smoocher","Yama-uba","Lady Gaga","NickiMinaj","Diva","Bootylicious","Lucy","Dr. Kisses"]
    when PBSpecies::ELEKID
      ary=["Ze","Laxus","Billy","Matt","Buzz Saw","Thor","ShockSquatch","Bzzz","Volten","Ampere","Shockwave","Dev","Sparkplug","Sparky","Zaprong","VoltDisney","Shocker","Static","Aero"]
    when PBSpecies::MAGBY
      ary=["Iroh","Kinko","Blaine","Ignis","Sol","Incinerator","Surtr"]
    when PBSpecies::MILTANK
      ary=["Malt","TheHeatedMoo","Whitney"]
    when PBSpecies::LARVITAR
      ary=["Texas","Tardis","Kappa","Drax","Cruz","RawrTar"]
    when PBSpecies::TREECKO
      ary=["Mudkip","Trey","Soul","Canopy","SirFndleBtm","Bracken","Thyme","Jukain","Razor","Ozzy"]
    when PBSpecies::TORCHIC
      ary=["KFC","Dolan","Colonel","Sanders","Inedible","Talon","TBP","Firefeather","Firefighter","Blaze","Phoenix","Chicko","Chili","Pyropuncher","Cpt Falcon"]
    when PBSpecies::MUDKIP
      ary=["Halo","Kappa","Neo","Deuk","Ogre","Skipper","Kipling","Cobalt","Troy","Ozzy","Swampy","Teach","Tsunami","Bruiser","Max","Kipper","Bloodcrypt","Robin","Nog","Kipling"]
    when PBSpecies::POOCHYENA
      ary=["Lassie","Lyca","Lycaon","Hysteria","Wolf","Raindrop","Poochie"]
    when PBSpecies::ZIGZAGOON
      ary=["Malarkey","Cody","Zoom","Stardust","Rocket","Ziggler"]
    when PBSpecies::WURMPLE
      ary=["Wormy","Dante","Vorm Hat"]
    when PBSpecies::LOTAD
      ary=["Juan Pedro","Miror","Ocho","Amigo","Fiesta","Lily's Pad"]
    when PBSpecies::SEEDOT
      ary=["Leifinator","Carlos","Deku","Locke","Pinocchio"]
    when PBSpecies::TAILLOW
      ary=["Wave","Tailglow","Kendrick","Destroyer","Gabriel","Ezakiel"]
    when PBSpecies::WINGULL
      ary=["Sidney","Pelly","Peeko","Typhoon","Wingo Star","EVERWHERE!"]
    when PBSpecies::SUNKERN
      ary=["Divinity","Destruction","Incarnate","UberMaterial"]
    when PBSpecies::RALTS
      ary=["M'Lady","Circe","Jezebel","Succubus","Anathema","Claire","Solomon","Serenity","M'Waifu","Sylvia","Psy-Shocker","Melony","Melody","Jupiter","Swordswipe"]
    when PBSpecies::SURSKIT
      ary=["Radish","Strider","Skeeter"]
    when PBSpecies::SHROOMISH
      ary=["WeedWizard","Emmy","Gus","Quentin","Toadstool","Achoo","Freyr","Boom Boom"]
    when PBSpecies::SLAKOTH
      ary=["Bread","George","Norman","Maurice"]
    when PBSpecies::NINCADA
      ary=["PlsNoSR","Asami","Etho","Kyoto","Shinobuzz","Zer0"]
    when PBSpecies::WHISMUR
      ary=["Ekho","Carol","TD4W","Trumpet","Noise","Cacophany","Echo","TORGUE","Radiohead"]
    when PBSpecies::MAKUHITA
      ary=["Bolin","Sandbag","Jakes","Bunraku","Brawly","GarbageFace","Trash Head"]
    when PBSpecies::AZURILL
      ary=["Bubble","Silmarillion","Thick Fat","Nexus","Tewi","Azusa","Amanda","Chihiro","Pikablu","Bleezus"]
    when PBSpecies::SKITTY
      ary=["Milkshake","Happy","Sarah","Kat","Hope","Daffodil","Sawyer","Rhyme"]
    when PBSpecies::SABLEYE
      ary=["Shade","Gamzee","Nigel","Gemini","Gemineye"]
    when PBSpecies::MAWILE
      ary=["Gnashley","Ashley","Cannonball","WreckingBall"]
    when PBSpecies::ARON
      ary=["Aaron","Alexandria","Carnegie","Krusty","Don Krieg","Metalbro","Iron","Truck","MetalGear?","Rocky","Diana"]
    when PBSpecies::MEDITITE
      ary=["Yoga","Tunak","Jackie","Raw Strength","Focus"]
    when PBSpecies::ELECTRIKE
      ary=["Raiko","Bolt","Thunder","Sparx","Wattson","Zuul"]
    when PBSpecies::PLUSLE
      ary=["Plutarch","Remus"]
    when PBSpecies::MINUN
      ary=["Minos","MinunXT"]
    when PBSpecies::VOLBEAT
      ary=["Tristan","Tristen","Unloved"]
    when PBSpecies::ILLUMISE
      ary=["Iseult","Lola Montez","Serenade"]
    when PBSpecies::GULPIN
      ary=["Noms","Gasper","Devourer","Nom Nom"]
    when PBSpecies::CARVANHA
      ary=["Carson","Sharknado"]
    when PBSpecies::WAILMER
      ary=["Mizu","HWOSA","Tiny","Blimp","Mass","SkittysWidow","ur mom"]
    when PBSpecies::NUMEL
      ary=["Caldera","Pompeii","Humphrey","Krakatoa","Vesuvius"]
    when PBSpecies::TORKOAL
      ary=["Coakley","Smokestack","Flannery"]
    when PBSpecies::SPOINK
      ary=["Hamlet","Slinky","Waddles","Jambon","Breakfast","SomePig"]
    when PBSpecies::SPINDA
      ary=["Vertigo","Twist","Loopy","LunaLovegood"]
    when PBSpecies::TRAPINCH
      ary=["Ackbar","Gobi","Memphis","Kalahari","Euan","Kenor","Nugget","Tsubasa","Melinda","Santy","Griptoy"]
    when PBSpecies::CACNEA
      ary=["PinsAndNeedles","Peyote","Satan","Cactuar","CactusJack"]
    when PBSpecies::SWABLU
      ary=["Qwerty","Skye","Soprano","Angel","Gabriel","Michael","Flit","Earhart","Cirrus","Cirrostratus","Lenessia"]
    when PBSpecies::ZANGOOSE
      ary=["Jean","Scarface","4","Anakin","Warrior"]
    when PBSpecies::SEVIPER
      ary=["Lucius","Venom","Medusa","Snakeysnakey","Nagini"]
    when PBSpecies::LUNATONE
      ary=["Moonlight","Phobos","Deimos","Ganymede","Artemis","Liza"]
    when PBSpecies::SOLROCK
      ary=["Delphi","Amun","Apollo","Betelgeuse","Tate","Dwayne"]
    when PBSpecies::BARBOACH
      ary=["Manchu","Quaker","Whiskmiral","Barbrady"]
    when PBSpecies::CORPHISH
      ary=["Clawdia","Crawford","Zoidberg","Clawmander","Pistol","Clawdia","Mr Bagels","Starlord"]
    when PBSpecies::BALTOY
      ary=["Rosetta","Jouet","Jupiter","Rusev"]
    when PBSpecies::LILEEP
      ary=["Rudy","Tentacles","SWISHYSWOOSH"]
    when PBSpecies::ANORITH
      ary=["Jericho","Armor","Dr. Claw"]
    when PBSpecies::FEEBAS
      ary=["FABULOUS","Forte","Ya'Majesty","Coral","Miss Hoenn","Wallace","Breeze"]
    when PBSpecies::CASTFORM
      ary=["Weatherman","Anchorman","Will Ferrel"]
    when PBSpecies::KECLEON
      ary=["Anana","Keklz","CYMK"]
    when PBSpecies::SHUPPET
      ary=["Muppet","Silas","Eldridge","Rotom","Marion","Styx","Lethe","Insurrector","Oogy Boogy"]
    when PBSpecies::DUSKULL
      ary=["Moriarty","Dustin","Pestilence","Dusty","Frightmare"]
    when PBSpecies::TROPIUS
      ary=["Trophelia","Monsanto","Berkley","Gilligan","FREEBANANA"]
    when PBSpecies::ABSOL
      ary=["Yin","Yang","Angst","Tiresias","Erastus","ShadeStrider","Pandora","Dusk","Erin","Dark","Abyss","Grimm"]
    when PBSpecies::WYNAUT
      ary=["1TrueGod","Bob","Beelzebub","Kevin","I think it","Because","Tagged","Zoidberg","Ghostface"]
    when PBSpecies::SNORUNT
      ary=["Sno","Yukon","Icecom","Corncicle","Antartica","Hermione","Candice","Ice2SeeU"]
    when PBSpecies::SPHEAL
      ary=["Tundra","Taiga","Atlantica","SphealWithIt"]
    when PBSpecies::CLAMPERL
      ary=["Palkia","Perlin","Depth"]
    when PBSpecies::RELICANTH
      ary=["Durkon","Ancient","Primordial"]
    when PBSpecies::LUVDISC
      ary=["Cassanova","TruLuv","<3","Casablanca"]
    when PBSpecies::BAGON
      ary=["Saphira","Orville","Dennis","Ziggler","Prince","SpaceSweeper","Wu-Tang","Bryan","Gojira","Cereal","Garyx"]
    when PBSpecies::BELDUM
      ary=["Robocop","Wykydtron","Metalocalypse","Fish","Magnum","PRDX-7","Take Down","Lego","Crystalisk","John","Cobalt","Elimi","BOOM","Microarm","WALL-E","HAL-9000","GLaDOS"]
    when PBSpecies::TURTWIG
      ary=["Pangaea","Atlas","Chelonii","Cypress","Hadyn","Handel"]
    when PBSpecies::CHIMCHAR
      ary=["Mnky","Dante","Chimpchips","Simia","Asura","Blaze","Mozart","Limono","Paul","Kong","Sun Wukong"]
    when PBSpecies::PIPLUP
      ary=["Napoleon","Pingu","Dewey","Gunter","Trident","Liszt","Quacky","Aegis","Pudge"]
    when PBSpecies::STARLY
      ary=["YOLO","Ace","Polaris","Avis","Zephyr","Flit","Hunter","Aster","Sky","Sterling","Erebos","Overpowered","Starlord"]
    when PBSpecies::BIDOOF
      ary=["Jesus","Paul","Buck","Doofus","Bucky","Arceus","Bidoofus","Fluffy","GOD","The Legend","HM Slave","Britta","Mocha"]
    when PBSpecies::KRICKETOT
      ary=["Fiddle","Viola","Thimble","TURNDWN4WUT","Jiminy"]
    when PBSpecies::SHINX
      ary=["Leon","Tigris","Shocky","Flicker","Shou","Sin","Fenrir","Muse","Volkner","Aslan","Lyra","Shadowbolt"]
    when PBSpecies::BUDEW
      ary=["Juliet","Bouquet","TuxedoManth","Roxy","Thorn","Rosebud","Gardenia","MntnBudew"]
    when PBSpecies::CRANIDOS
      ary=["Yorick","Skuld","Douglas","Lance","Roark"]
    when PBSpecies::SHIELDON
      ary=["Bastille","Sentinel","Gaston","Byron"]
    when PBSpecies::BURMY
      ary=["Serif","Burmeister","Burgess"]
    when PBSpecies::COMBEE
      ary=["Buzzkill","Honey","Lorde"]
    when PBSpecies::PACHIRISU
      ary=["Scrat","Watson","Hammy","Threat"]
    when PBSpecies::BUIZEL
      ary=["Jazz","Tails","Sahas","Tony","Wake","Float"]
    when PBSpecies::CHERUBI
      ary=["Cheri","Kaiser","Blossom"]
    when PBSpecies::SHELLOS
      ary=["Gaston","Slugger","Octavian","Octavius"]
    when PBSpecies::DRIFLOON
      ary=["Hindenburg","Lanky","Static","Flo","Pop","Zephyr","Ryugen","BlimpDaddy"]
    when PBSpecies::BUNEARY
      ary=["Lepus","Fumbles","Reisen","Bunni","Easter"]
    when PBSpecies::GLAMEOW
      ary=["Coil","Josie","Bellatrix","Bubba"]
    when PBSpecies::CHINGLING
      ary=["Kagura","Euphony","Belle","Treble","Vale","Blingbling"]
    when PBSpecies::STUNKY
      ary=["Kimchi","Putrefaction","HarryPooter","Febreeze","Kit"]
    when PBSpecies::BRONZOR
      ary=["Lebronze","Cacophany","Valyria","Tank","Android","Ominous"]
    when PBSpecies::BONSLY
      ary=["Woody","Allen","Ash","Bosch","Trevenant","Groot","Faker","Pinocchio","Cucumber","Sprout","Fauxilage"]
    when PBSpecies::MIMEJR
      ary=["Scarred Child","Harley","Quinn","Chaplin","Marx","Mimien","Marcel","Jojo","Saville"]
    when PBSpecies::HAPPINY
      ary=["Maureen","Charmi","Humpty","Hulk","Nurse","Phil","Pink Blob"]
    when PBSpecies::CHATOT
      ary=["Potty","Jester","Dingart","Parrot"]
    when PBSpecies::SPIRITOMB
      ary=["Nirvana","Gandalf","ManySpirits","Darkness","Eternity"]
    when PBSpecies::GIBLE
      ary=["Darude","ChainChomp","GIBBY","Landshark","Sharknado","Earthfang","Megalodon","Rex","Sharkeisha","John","Fleetfire","Emperor","Sharkboy","Nidhogg","Useless","Khan"]
    when PBSpecies::MUNCHLAX
      ary=["Dewey","Mac","Eglon","Lummox","Taft","ObesityLOL","Muta","Glutto","Rex","Omnomnivore","Jabba","Tiny","Beef","Gentoo","Chillax"]
    when PBSpecies::RIOLU
      ary=["Pranith","Anubis","Chakra","Jet","Blametruth","Goku","Lil' Mac","Lucas","Strifen","Brec","Lulu","Pacquiao","Lucius","Raaz","Rio","Zephyr","Artemis","Nyack","Ares","Aura","Dayman","Clive","Maylene"]
    when PBSpecies::HIPPOPOTAS
      ary=["Tillie","HungryHippo","Tawaret","Sable","Darude","Tillie"]
    when PBSpecies::SKORUPI
      ary=["Gorax","Cassius","Brutus","Hemlock","Scorpio","Vice","Arsenic"]
    when PBSpecies::CROAGUNK
      ary=["Rani","Francis","Acid","Soul","FrogOfEVIL"]
    when PBSpecies::CARNIVINE
      ary=["Venus","Badass","Flaptrap","Flytrap"]
    when PBSpecies::FINNEON
      ary=["Frances","Irrelevant","RELEVANT","Tetra","Iku","Vegas","Lumi","Lumia","Useless","Dory"]
    when PBSpecies::MANTYKE
      ary=["Billy Ray","Ray","Rayman","SingWithMe","Kyte","^_^","Bayleen"]
    when PBSpecies::SNOVER
      ary=["Snowball","Snowden","Edward","Romney","Good4USA","Scrooge","Nevergreen","Daikon","Todd","Sweater","Obama"]
    when PBSpecies::ROTOM
      ary=["Motorgeist","Tom","Voltergeist","Puck","Buzz","EZ-BakeOven","Mowtom","Rinse Cycle","Sonny","Gheist","Strom","Edison","Lenz"]
    when PBSpecies::SNIVY
      ary=["Smugmug","Saladczar","Riddle","Naja","Herb","Viper","Hebi","Debussy","Aloe","Sassafras","Smuglord"]
    when PBSpecies::TEPIG
      ary=["Porcus","Hamlet","Wilbur","Kevin Bacon","Hickory","Broham","Baconator","Bacon","Blaze"]
    when PBSpecies::OSHAWOTT
      ary=["UwottM8","Torpedo","Xanefer","Chopin","Bluejay","Revolver"]
    when PBSpecies::PATRAT
      ary=["Argus","Vermin","Lenora"]
    when PBSpecies::LILLIPUP
      ary=["Canis","FrankerZ","Rudy","Colin","TerrirTerror","Partridge","Cheren","Cheddar","SgtScruffy"]
    when PBSpecies::PURRLOIN
      ary=["Turpin","Burglar","Priscilla","MsDemeanor","Zoe","Catwoman"]
    when PBSpecies::PANSAGE
      ary=["Peter","Herb","Basil","Cilan"]
    when PBSpecies::PANSEAR
      ary=["Boilder","Takua","Cardinal","Chili"]
    when PBSpecies::PANPOUR
      ary=["Eddie","Liquid","Cress"]
    when PBSpecies::MUNNA
      ary=["Reverie","Moonshine","Inception"]
    when PBSpecies::PIDOVE
      ary=["Gallus","Whisper","Derpity","Dove"]
    when PBSpecies::BLITZLE
      ary=["Maximus","Equus","Thunderblast","Henry"]
    when PBSpecies::ROGGENROLA
      ary=["Elvis","Carbon","Solid","LedZeppelin","Grackle","Slater","OneManBand"]
    when PBSpecies::WOOBAT
      ary=["Wu","Amour","WooWooWoo"]
    when PBSpecies::DRILBUR
      ary=["Bottles","ScarfMe","Wolverine","dIG dUG","Tara","Dorugon","Simon","Honeydew","Clay","Juggernaut","Ubers"]
    when PBSpecies::AUDINO
      ary=["PrincessTNT","Flamingo","EXP Farm"]
    when PBSpecies::TIMBURR
      ary=["Stalone","Timburrton","Clown Nose","Banjo","Pitbull"]
    when PBSpecies::TYMPOLE
      ary=["Tempo","Warbler","OPAsHell"]
    when PBSpecies::THROH
      ary=["Norris","ThatSht","Red"]
    when PBSpecies::SAWK
      ary=["Blue","Hawk","Norris2"]
    when PBSpecies::SEWADDLE
      ary=["Chai","Earl","Stitch","Maple","Silky","CocoonyLoony","Burgh","Patchouli"]
    when PBSpecies::VENIPEDE
      ary=["Crawlie","Wren","Roxie","Booster","Powerworm"]
    when PBSpecies::COTTONEE
      ary=["Antebellum","Jo","Filliam","TrollBait"]
    when PBSpecies::PETILIL
      ary=["Lilith","Satou","Dahlia","Yuuka"]
    when PBSpecies::BASCULIN
      ary=["FISHIE","BIGFISHIE","DrSeussFish"]
    when PBSpecies::SANDILE
      ary=["Red Skull","Vector","Nixon","Schnappi","Gold Digger","Riff"]
    when PBSpecies::DARUMAKA
      ary=["Pepper","Chicken","Kobashi"]
    when PBSpecies::MARACTUS
      ary=["Mojave","Monster","Merri","Prickle","Cactus"]
    when PBSpecies::DWEBBLE
      ary=["Dwalin","Cavebug","Krusty Krab","Lasagna"]
    when PBSpecies::SCRAGGY
      ary=["Al","Scrap","Pepper","Thug","Swagger","Callum","Views"]
    when PBSpecies::SIGILYPH
      ary=["Nazca","Totem","Oberon","Unown Evo","Titania","Borealis","Aztec"]
    when PBSpecies::YAMASK
      ary=["Tut","Pharoah","Osiris","Raven","Isis"]
    when PBSpecies::TIRTOUGA
      ary=["T.W.","Archelon","Senor Turtle","Galapagos","Leonardo","Crush"]
    when PBSpecies::ARCHEN
      ary=["Max","Archie","RockBird","Useless","Pessimist","Rage Quit"]
    when PBSpecies::TRUBBISH
      ary=["B.O","Trashley","Raxus","Gruel","Landfill","Turkey","I'm Sorry","urmom","Dirty Dan","Nash Grier"]
    when PBSpecies::ZORUA
      ary=["Twila","Eclipse","Midnight","Ylvis","Zavulon","Loki","Zorro","Matthias","Shadow","Kitsune","DerrenBrown","Illusion","Xion","Cario","NotZoroark"]
    when PBSpecies::MINCCINO
      ary=["Sauron","Destruction","Tails","Jimmy"]
    when PBSpecies::GOTHITA
      ary=["Darla","Enoby","Romaine","Tharja","Belle","Quail","Kim","Lulu"]
    when PBSpecies::SOLOSIS
      ary=["Jellybean","Anaphase","Prophase","Hooke","Marie","Chromosome","Cell","Claire","Protozoan"]
    when PBSpecies::DUCKLETT
      ary=["Daffy","Odette","Cygnet","Swan","Skyla"]
    when PBSpecies::VANILLITE
      ary=["Ice-man","Softon","Byrne","Chili","Icy","Penguin","Haagen-Daaz"]
    when PBSpecies::DEERLING
      ary=["Diary","Myrrh","Chickadee"]
    when PBSpecies::EMOLGA
      ary=["Benjamin","Ambergris","Rocky","Elesa"]
    when PBSpecies::KARRABLAST
      ary=["Sensei","Galahad","Uriah","Scarab","Soldierside"]
    when PBSpecies::FOONGUS
      ary=["Mushy","Amanita","Fun Guy","Zoeya","Blackrock"]
    when PBSpecies::FRILLISH
      ary=["IggyAzalea","Lusitania","Royall","BlueBelle","Marlon","U Jelly?"]
    when PBSpecies::ALOMOMOLA
      ary=["LOVE","LuvdiscEvo","Irrelevant","<3Broken"]
    when PBSpecies::JOLTIK
      ary=["Parker","Jitterbug","Static","Joan","Usain Jolt"]
    when PBSpecies::FERROSEED
      ary=["Fluffy","Fergus","Barbara","uTorrent","Casey","Spikey","Fluffy","Fluffy"]
    when PBSpecies::KLINK
      ary=["Gottam","SilverLining","Choo Choo"]
    when PBSpecies::TYNAMO
      ary=["Anguilla","Jasper","Floaty","SlipperyEel","NoWeaknesses"]
    when PBSpecies::ELGYEM
      ary=["Foreigner","Pluto","Psmythe","Luna","Andromeda","Orion","Venus","Mars","Archon","Rigley","Ligray","Zaphod","Chozo","Marvin","Kepler","Hubble","Yoda","Prometheus"]
    when PBSpecies::LITWICK
      ary=["Shround","Damien","Flitwick","Candlejack","Lumiere","Jack","Ghost Rider"]
    when PBSpecies::AXEW
      ary=["Arxand","Haxornoob","Zeke","Candlejack","Executioner","Guillotine","Blaxorus","Iris","Mr Rogers"]
    when PBSpecies::CUBCHOO
      ary=["#CANADA","Canadia","Freeze","Stalin","Frostbite","Brycen","Lenin","Abominable"]
    when PBSpecies::CRYOGONAL
      ary=["Khione","Snowflake","Benvolio","Beauty"]
    when PBSpecies::SHELMET
      ary=["Escargot","Speedsnake","FireReks"]
    when PBSpecies::STUNFISK
      ary=["Ninjifisk","Destruction","Divinity","2nd Dimension","Ascension","Arceus","Mega-Arceus"]
    when PBSpecies::MIENFOO
      ary=["Miyagi","Kojo","Ana","HiJumpMiss"]
    when PBSpecies::DRUDDIGON
      ary=["Braig","LegoDragon","Drayden"]
    when PBSpecies::GOLETT
      ary=["Dorfl","Ghoul-Aid","Lagann","Gurren","Max","Gilgamech","Rhodes","EasterIsland","Talos"]
    when PBSpecies::PAWNIARD
      ary=["Descole","BlackKnight","Rider","Accel","Checkmate","Punky","Slasher","Weth","Trial","Zanki","Robocop","Blade","Rook","Mordred"]
    when PBSpecies::BOUFFALANT
      ary=["Mayhem","BlackDynamite","AfroTauros","SamuelJ"]
    when PBSpecies::RUFFLET
      ary=["Murica","Ventus","Avia","Eagle","USA","Feather","Colbert"]
    when PBSpecies::VULLABY
      ary=["Buzzard","Vulture","StallBird","Endless","Foul"]
    when PBSpecies::HEATMOR
      ary=["Arthur","Heatran","Snortfire","Snort","Pyrao"]
    when PBSpecies::DURANT
      ary=["Flik","Kevin","DuranDuran","SmallSlaking","Basketball"]
    when PBSpecies::DEINO
      ary=["King","Ghetsis2016","Ghetsis","Grima","LittleD","Dracossack","BlackHippy","Goebbels","Triforce","Alanna","Rage","Draco"]
    when PBSpecies::LARVESTA
      ary=["Trident","Solstice","Inferno","Huxley","Infermoth","Spock","Soleil","Fiesta","Sekhmet"]
    when PBSpecies::CHESPIN
      ary=["Chou","Cyrus","Chrus","Chester","Eli","Hector","Xyris","Marron"]
    when PBSpecies::FENNEKIN
      ary=["Janus","Kinnekins","Aihal","Luke","Press B","Fox","Ylvis","Oracle","Star Fox","Mozilla","Firefox","Rincewind","Mahotsukai"]
    when PBSpecies::FROAKIE
      ary=["Glenn","Froable","Worgen","Snoop Frog","Will Smith","Mikasa","Kuna","Ninja","Black Star","Kermit","Shinobi"]
    when PBSpecies::BUNNELBY
      ary=["Gaius","Thugs Bunny","Bulk Ears","Tho"]
    when PBSpecies::FLETCHLING
      ary=["Miltin","Bobhigs","SuzeHatesThis","fire","Phoenix","NotMoltres","Porsche","TalonLAME","Okuu","Utshuo","SuzeParrot","Scissor","BasedGod","Pippy","Yune"]
    when PBSpecies::SCATTERBUG
      ary=["Nick","Viola","Pixelle","Eris","Dementia"]
    when PBSpecies::LITLEO
      ary=["Paula","Dakota","Sekhmet","Pride","Simba","Mufasa"]
    when PBSpecies::FLABEBE
      ary=["Flora","Crutch","AZ","Calliope","Ocarina","Lyra","Timpani","Flore"]
    when PBSpecies::SKIDDO
      ary=["Brome","Kristoph","Ramos","Bryan","Cranston","Billy","Harley"]
    when PBSpecies::PANCHAM
      ary=["Akira","Pandamonium","Shifu","Banjo","Po"]
    when PBSpecies::FURFROU
      ary=["Royal Pain","Llama","Cleo","Cleopatra"]
    when PBSpecies::ESPURR
      ary=["KittyPurry","Mimi","Dem Eyes","Olympia","Purrito","Scarred.","Psyche"]
    when PBSpecies::HONEDGE
      ary=["Deadpool","MasterSword","Excalibur","Masamume","Amatsu","Katana","Hexcalibur","Murasame","Soul Eater","Claymore","Smogonsword","Falchion","Aeon","lelsmogon","Stabby","HelixSlash","Buster","Damocles","Blade"]
      when PBSpecies::SPRITZEE
      ary=["Octavia","Forgotten","Fairy","Proper","Paris"]
    when PBSpecies::SWIRLIX
      ary=["Eclair","Derpy","Sweetie","Cotton","Fairydrum"]
    when PBSpecies::INKAY
      ary=["NU","Cthulhu","Sushi","PapaShango","Seija","Lovecraft"]
    when PBSpecies::BINACLE
      ary=["Barney","Apple Pie","Barnacles","Smash/Crush"]
    when PBSpecies::SKRELP
      ary=["Seor","Kelper","Kelpie","Horsea","Muckhorse","Sludge","Limpet"]
    when PBSpecies::CLAUNCHER
      ary=["Crusty","Pulser","Lobster","R.Handed","Claws"]
    when PBSpecies::HAWLUCHA
      ary=["Lucha","Libre","Superbird","Luchador","WWE"]
    when PBSpecies::HELIOPTILE
      ary=["Dibl","Alan","Clemont","Becquerel","Solaris"]
    when PBSpecies::TYRUNT
      ary=["T-Rekt","Tyrone","Terrowrist","Grant","Terry","Tiny","Sue","Rex","Wexter"]
    when PBSpecies::AMAURA
      ary=["Littlefoot","Borealis","Yuki","Extinct","Rainbow","Niflheim"]
    when PBSpecies::DEDENNE
      ary=["Flash","Hammish","DrgnSlayer","Pikaclone"]
    when PBSpecies::CARBINK
      ary=["Mythril","Binky","Unleashed","Hallows"]
    when PBSpecies::GOOMY
      ary=["Lord Goomy","Xenith","Gooroo","Gummy Bear"]
    when PBSpecies::KLEFKI
      ary=["SmogonKeys","Destati","BoobooKeys","Shenanigans","Vimes"]
    when PBSpecies::PHANTUMP
      ary=["Arbor","Sudowoodo","Groot","Skulkid"]
    when PBSpecies::PUMPKABOO
      ary=["Plum","Linus","Halloween"]
    when PBSpecies::BERGMITE
      ary=["Antartica","Iceberg","Freezing","Titanic","Bernie","Wulfric"]
    when PBSpecies::NOIBAT
      ary=["Nowi","Wyvern","Radio","Decibel","Leopold","Pippy","Bruce","Draco"]
    when PBSpecies::DELTACHARMANDER
      ary=["Shadowzard","Hellfire","Ghostfire"]
    when PBSpecies::DELTABULBASAUR
      ary=["Psychosaur","Brainz","Delta Dino","Not Kanto"]
    when PBSpecies::DELTASQUIRTLE
      ary=["Focus","Cannons","Destruction","Not Kanto2"]
    when PBSpecies::DELTAPAWNIARD
      ary=["Birdman","Hawlucha2","Sky","Hunter"]
    when PBSpecies::DELTASUNKERN
      ary=["Divinity","Fireflower"]
    when PBSpecies::DELTABERGMITE
      ary=["Dragonstone","Entombed"]
    when PBSpecies::DELTARALTS
      ary=["Elsa","Ice Queen","Frozen"]
    when PBSpecies::DELTASCYTHER
      ary=["Cleaver","Predator","Snow Stalker"]
    when PBSpecies::DELTASCRAGGY
      ary=["Dank","Hippiehood"]
    when PBSpecies::DELTACOMBEE
      ary=["Drone","Ro-B-ot"]
    when PBSpecies::DELTAPURRLOIN
      ary=["sp00ky","EdgeCat"]
    when PBSpecies::DELTAPHANTUMP
      ary=["Guardian","Forester"]
    when PBSpecies::DELTASNORUNT
      ary=["Inferno","Cheeseball"]
    when PBSpecies::DELTAKOFFING
      ary=["Amplifier","Thunderball"]
    when PBSpecies::DELTASHINX
      ary=["Venom","Injector"]
    when PBSpecies::DELTANOIBAT
      ary=["SteelWing","Sounder"]
    when PBSpecies::DELTABUDEW
      ary=["Librarian","BlackRose"]
    when PBSpecies::DELTABUDEW
      ary=["Librarian","BlackRose"]
    when PBSpecies::DELTADRIFLOON
      ary=["Hot Air","Balloon"]
    when PBSpecies::DELTAGRIMER
      ary=["Sandman","Sahara","Haboob"]
    when PBSpecies::DELTAWOOPER
      ary=["Jack","Tricky","Hallows"]
    when PBSpecies::DELTAMUNCHLAX
      ary=["Hungry","Chubs","Sakura","Herbie"]
    when PBSpecies::DELTAMISDREAVUS
      ary=["Krampus","Snowy","Frost"]
    when PBSpecies::DELTACYNDAQUIL
      ary=["Tesla","Edison","Sanga","Zeusaquil"]
    when PBSpecies::DELTATREECKO
      ary=["Sensei","Dojo"]
    when PBSpecies::DELTATORCHIC
      ary=["Horus","Bossman"]
    when PBSpecies::DELTATURTWIG
      ary=["AllTheWay","Crush","Chukwa"]
    when PBSpecies::DELTASNIVY
      ary=["Rogue","Pirate","Avast"]
    when PBSpecies::DELTAFROAKIE
      ary=["Treetops","OTK"]
    when PBSpecies::DELTAPIDGEY
      ary=["Cockatrice","Stone"]
    when PBSpecies::DELTADIGLETT
      ary=["Iceball","Puff Son","Snurrower"]
    when PBSpecies::DELTAGROWLITHE
      ary=["Bestie","BFF","Draco"]
    when PBSpecies::DELTAGEODUDE
      ary=["Ruin","Talos","Kythera"]
    when PBSpecies::DELTATENTACOOL
      ary=["Shoggoth","Audrey2"]
    when PBSpecies::DELTADODUO
      ary=["D. Brown","Urigeller"]
    when PBSpecies::DELTATANGELA
      ary=["Rocky","Rapunzel"]
    when PBSpecies::DELTADITTO
      ary=["Blob","Easy"]
   when PBSpecies::DELTAKABUTO
      ary=["Coldsteel","Scissors"]
  when PBSpecies::DELTADRATINI
      ary=["Hydrox","Aido Wedo"]
  when PBSpecies::DELTAHOOTHOOT
      ary=["Frosteye","Everwinter"]
    when PBSpecies::DELTACHINCHOU
      ary=["Wrangler Fish","Nox"]
    when PBSpecies::DELTAPICHU
      ary=["Icarus","Apache"]
    when PBSpecies::DELTAAIPOM
      ary=["Meta","Tellus"]
    when PBSpecies::DELTAYANMA
      ary=["Plague","Suckle"]
    when PBSpecies::DELTAGIRAFARIG
      ary=["Racecar","Rotator","Tattarrattat"]
    when PBSpecies::DELTADUNSPARCE
      ary=["Vermin","Divinity"]
    when PBSpecies::DELTASHUCKLE
      ary=["Punchbag","Ali"]
    when PBSpecies::DELTAREMORAID
      ary=["Combustion","Engine"]
    when PBSpecies::DELTAELEKID
      ary=["Hardrock","David"]
    when PBSpecies::DELTAMAGBY
      ary=["Yasen","Vanguard"]
    when PBSpecies::DELTALOTAD
      ary=["Warlock","Merlin"]
    when PBSpecies::DELTASEEDOT
      ary=["Current","Voltage"]
    when PBSpecies::DELTASABLEYE
      ary=["Ruby","Inferno"]
    when PBSpecies::DELTAMAWILE
      ary=["Audrey2.0","Venus","Vore"]
    when PBSpecies::DELTAARON
      ary=["Hyperion","Ares","Destroyer"]
    when PBSpecies::DELTAMEDITITE
      ary=["Tumnus","Grover"]
    when PBSpecies::DELTANUMEL
      ary=["Chernobyl","Isotope"]
    when PBSpecies::DELTAPLUSLE
      ary=["Heartfire","Hearth"]
    when PBSpecies::DELTAMINUN
      ary=["Snowfall","Bittersweet"]
    when PBSpecies::DELTAWAILMER
      ary=["Skyfall","Cumulus"]
    when PBSpecies::DELTAFEEBAS
      ary=["Apophis","Apep"]
    when PBSpecies::DELTACLAMPERL
      ary=["Leviathan","Thalasso"]
    when PBSpecies::DELTABELDUM1
      ary=["Arachne","Morales"]
    when PBSpecies::DELTABELDUM2
      ary=["Construct","Dwemer","Automaton"]
    when PBSpecies::DELTABUNEARY
      ary=["Bunninja"]
    when PBSpecies::DELTARIOLU
      ary=["Anubis","Tombkeeper"]
    when PBSpecies::DELTACROAGUNK
      ary=["Firekeeper","Burner"]
    when PBSpecies::DELTAVENIPEDE
      ary=["Hellspawn","Belphegor"]
    when PBSpecies::DELTAPETILIL1 #water/fire
      ary=["Steam","Mermail"]
    when PBSpecies::DELTAPETILIL2
      ary=["Titania","Oberon"]
    when PBSpecies::DELTASOLOSIS
      ary=["Haunt","Ouija"]
    when PBSpecies::DELTADARUMAKA
      ary=["Poltergeist","Returner"]
    when PBSpecies::DELTAMARACTUS
      ary=["HK-47","FOOM"]
    when PBSpecies::DELTADWEBBLE1
      ary=["Geoff","Terrence"]
    when PBSpecies::DELTADWEBBLE2
      ary=["Gateau","Maldoche"]
    when PBSpecies::DELTAYAMASK
      ary=["Aerosol"]
    when PBSpecies::DELTAEMOLGA
      ary=["Gremlin","Imp"]
    when PBSpecies::DELTAKARRABLAST
      ary=["Pixie Dust","Tinkerbell"]
    when PBSpecies::DELTAFOONGUS
      ary=["Shroomed","Fungus"]
    when PBSpecies::DELTALITWICK
      ary=["Chandelier","Disney"]
    when PBSpecies::DELTAAXEW
      ary=["Rogue","Blackbeard","Buccaneer"]
    when PBSpecies::DELTAGOLETT
      ary=["Talos","Automaton","Titan","Vulcan"]
    when PBSpecies::DELTAHEATMOR
      ary=["Lawrence"]
    when PBSpecies::DELTADEINO
      ary=["Jafar","Kobra"]
    when PBSpecies::DELTALARVESTA
      ary=["Void","Extraterrestrial"]
    when PBSpecies::DELTAAMAURA
      ary=["Newfoundland"]
    when PBSpecies::DELTAGOOMY
      ary=["Sticky","Gooey"]

    end
    raise ""+pkmn.to_s if ary==nil
    return ary[rand(ary.length)]
  end

def getRandomEggItemFor(pkmn,num)
    case pkmn
    when PBSpecies::BULBASAUR
      ary=[PBItems::BLACKSLUDGE,PBItems::VENUSAURITE,PBItems::BIGROOT]
    when PBSpecies::CHARMANDER
      ary=[PBItems::CHARIZARDITEX,PBItems::CHARIZARDITEY,PBItems::CHOICESCARF,PBItems::FLAMEPLATE]
      when PBSpecies::SQUIRTLE
      ary=[PBItems::BLASTOISITE,PBItems::CHOICESPECS,PBItems::LEFTOVERS]
    when PBSpecies::CATERPIE
      ary=[PBItems::FOCUSSASH,PBItems::BUGGEM]
    when PBSpecies::WEEDLE
      ary=[PBItems::LIFEORB,PBItems::FOCUSSASH]
    when PBSpecies::KRABBY
      ary=[PBItems::LIFEORB,PBItems::CHOICEBAND]
    when PBSpecies::PIDGEY
      ary=[PBItems::CHOICEBAND,PBItems::LIFEORB,PBItems::FLYINGGEM,PBItems::SKYPLATE]
    when PBSpecies::RATTATA
      ary=[PBItems::FOCUSSASH,PBItems::TOXICORB]
    when PBSpecies::SPEAROW
      ary=[PBItems::CHOICESCARF,PBItems::LUMBERRY]
    when PBSpecies::EKANS
      ary=[PBItems::LIFEORB,PBItems::BLACKSLUDGE]
    when PBSpecies::SANDSHREW
      ary=[PBItems::LEFTOVERS,PBItems::LUMBERRY,PBItems::LIFEORB,PBItems::SMOOTHROCK]
    when PBSpecies::NIDORANfE
      ary=[PBItems::CHOICESCARF,PBItems::EXPERTBELT,PBItems::LIFEORB]
    when PBSpecies::NIDORANmA
      ary=[PBItems::CHOICESCARF,PBItems::EXPERTBELT,PBItems::LIFEORB]
    when PBSpecies::VULPIX
      ary=[PBItems::HEATROCK,PBItems::LEFTOVERS,PBItems::AIRBALLOON]
    when PBSpecies::ZUBAT
      ary=[PBItems::BLACKSLUDGE,PBItems::LEFTOVERS,PBItems::CHOICEBAND]
    when PBSpecies::ODDISH
      ary=[PBItems::LEAFSTONE,PBItems::SUNSTONE,PBItems::LEFTOVERS]
    when PBSpecies::PARAS
      ary=[PBItems::FOCUSSASH,PBItems::LEFTOVERS]
    when PBSpecies::VENONAT
      ary=[PBItems::FOCUSSASH,PBItems::LIFEORB,PBItems::BLACKSLUDGE]
    when PBSpecies::DIGLETT
      ary=[PBItems::AIRBALLOON,PBItems::EARTHPLATE]
    when PBSpecies::MEOWTH
      ary=[PBItems::LIFEORB,PBItems::SILKSCARF]
    when PBSpecies::PSYDUCK
      ary=[PBItems::CHOICESCARF,PBItems::LEFTOVERS]
    when PBSpecies::MANKEY
      ary=[PBItems::CHOICEBAND,PBItems::CHOICESCARF,PBItems::EXPERTBELT,PBItems::FISTPLATE,PBItems::LIFEORB]
    when PBSpecies::GROWLITHE
      ary=[PBItems::LIFEORB,PBItems::LEFTOVERS,PBItems::CHOICEBAND]
    when PBSpecies::POLIWAG
      ary=[PBItems::KINGSROCK,PBItems::DAMPROCK,PBItems::LEFTOVERS]
    when PBSpecies::ABRA
      ary=[PBItems::ALAKAZITE,PBItems::FOCUSSASH]
    when PBSpecies::MACHOP
      ary=[PBItems::ASSAULTVEST,PBItems::EXPERTBELT]
    when PBSpecies::BELLSPROUT
      ary=[PBItems::LIFEORB,PBItems::WEAKNESSPOLICY,PBItems::BLACKSLUDGE]
    when PBSpecies::TENTACOOL
      ary=[PBItems::BLACKSLUDGE]
    when PBSpecies::GEODUDE
      ary=[PBItems::WEAKNESSPOLICY,PBItems::CUSTAPBERRY]
    when PBSpecies::PONYTA
      ary=[PBItems::LIFEORB,PBItems::CHOICEBAND,PBItems::LEFTOVERS]
    when PBSpecies::SLOWPOKE
      ary=[PBItems::SLOWBRONITE,PBItems::LIFEORB,PBItems::LEFTOVERS,PBItems::KINGSROCK]
    when PBSpecies::MAGNEMITE
      ary=[PBItems::AIRBALLOON,PBItems::CHOICESPECS]
    when PBSpecies::FARFETCHD
      ary=[PBItems::STICK]
    when PBSpecies::DODUO
      ary=[PBItems::CHOICESCARF,PBItems::SKYPLATE,PBItems::CHOICEBAND]
    when PBSpecies::SEEL
      ary=[PBItems::LEFTOVERS,PBItems::WEAKNESSPOLICY]
    when PBSpecies::GRIMER
      ary=[PBItems::BLACKSLUDGE,PBItems::PBItems::ASSAULTVEST]
    when PBSpecies::SHELLDER
      ary=[PBItems::KINGSROCK,PBItems::WATERSTONE]
    when PBSpecies::GASTLY
      ary=[PBItems::GENGARITE,PBItems::BLACKSLUDGE,PBItems::FOCUSSASH]
    when PBSpecies::ONIX
      ary=[PBItems::METALCOAT,PBItems::PBItems::STEELIXITE]
    when PBSpecies::DROWZEE
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::VOLTORB
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::EXEGGCUTE
      ary=[PBItems::CHOICESPECS,PBItems::LEFTOVERS]
    when PBSpecies::CUBONE
      ary=[PBItems::THICKCLUB,PBItems::MAROWITE]
    when PBSpecies::LICKITUNG
      ary=[PBItems::CHOICEBAND,PBItems::LEFTOVERS]
    when PBSpecies::KOFFING
      ary=[PBItems::BLACKSLUDGE]
    when PBSpecies::RHYHORN
      ary=[PBItems::PROTECTOR]
    when PBSpecies::TANGELA
      ary=[PBItems::ASSAULTVEST,PBItems::LEFTOVERS,PBItems::LIFEORB]
    when PBSpecies::KANGASKHAN
      ary=[PBItems::KANGASKHANITE]
    when PBSpecies::HORSEA
      ary=[PBItems::SCOPELENS,PBItems::PBItems::DRAGONSCALE]
    when PBSpecies::GOLDEEN
      ary=[PBItems::LIFEORB]
    when PBSpecies::STARYU
      ary=[PBItems::LEFTOVERS,PBItems::LIFEORB,PBItems::EXPERTBELT,PBItems::CHOICESCARF,PBItems::CHOICESPECS]
    when PBSpecies::SCYTHER
      ary=[PBItems::SCIZORITE,PBItems::METALCOAT]
    when PBSpecies::PINSIR
      ary=[PBItems::PINSIRITE,PBItems::CHOICESCARF]
    when PBSpecies::TAUROS
      ary=[PBItems::LIFEORB,PBItems::CHOICESCARF]
    when PBSpecies::MAGIKARP
      ary=[PBItems::LEFTOVERS,PBItems::GYARADOSITE]
    when PBSpecies::LAPRAS
      ary=[PBItems::ASSAULTVEST,PBItems::PBItems::LEFTOVERS]
    when PBSpecies::DITTO
      ary=[PBItems::CHOICESCARF]
    when PBSpecies::EEVEE
      ary=[PBItems::WATERSTONE,PBItems::FIRESTONE,PBItems::THUNDERSTONE,PBItems::EEVITE]
    when PBSpecies::PORYGON
      ary=[PBItems::DUBIOUSDISC,PBItems::UPGRADE]
    when PBSpecies::OMANYTE
      ary=[PBItems::CHOICESPECS,PBItems::WHITEHERB]
    when PBSpecies::KABUTO
      ary=[PBItems::LIFEORB,PBItems::CHOICEBAND]
    when PBSpecies::AERODACTYL
      ary=[PBItems::AERODACTYLITE,PBItems::CHOICEBAND]
    when PBSpecies::SNORLAX
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::DRATINI
      ary=[PBItems::WEAKNESSPOLICY,PBItems::LUMBERRY]
    when PBSpecies::CHIKORITA
      ary=[PBItems::MEGANIUMITE,PBItems::LEFTOVERS]
    when PBSpecies::CYNDAQUIL
      ary=[PBItems::CHOICESPECS,PBItems::TYPHLOSIONITE]
    when PBSpecies::TOTODILE
      ary=[PBItems::LIFEORB,PBItems::FERALIGATITE]
    when PBSpecies::SENTRET
      ary=[PBItems::SITRUSBERRY]
    when PBSpecies::HOOTHOOT
      ary=[PBItems::CHOICESPECS,PBItems::ASSAULTVEST]
    when PBSpecies::LEDYBA
      ary=[PBItems::FOCUSSASH,PBItems::LIGHTCLAY]
    when PBSpecies::SPINARAK
      ary=[PBItems::FOCUSSASH,PBItems::LEFTOVERS]
    when PBSpecies::CHINCHOU
      ary=[PBItems::LEFTOVERS,PBItems::CHOICESPECS]
    when PBSpecies::PICHU
      ary=[PBItems::THUNDERSTONE,PBItems::LIGHTBALL]
    when PBSpecies::CLEFFA
      ary=[PBItems::LEFTOVERS,PBItems::LIFEORB,PBItems::MOONSTONE]
    when PBSpecies::IGGLYBUFF
      ary=[PBItems::LEFTOVERS,PBItems::MOONSTONE]
    when PBSpecies::TOGEPI
      ary=[PBItems::LEFTOVERS,PBItems::SHINYSTONE]
    when PBSpecies::NATU
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::MAREEP
      ary=[PBItems::AMPHAROSITE,PBItems::LIFEORB]
    when PBSpecies::MARILL
      ary=[PBItems::SITRUSBERRY,PBItems::ASSAULTVEST,PBItems::CHOICEBAND]
    when PBSpecies::AIPOM
      ary=[PBItems::LIFEORB]
    when PBSpecies::HOPPIP
      ary=[PBItems::LEFTOVERS,PBItems::FLYINGGEM,PBItems::HEATROCK]
    when PBSpecies::YANMA
      ary=[PBItems::FOCUSSASH,PBItems::CHOICESPECS,PBItems::LIFEORB]
    when PBSpecies::WOOPER
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::MURKROW
      ary=[PBItems::DUSKSTONE]
    when PBSpecies::MISDREAVUS
      ary=[PBItems::DUSKSTONE]
    when PBSpecies::UNOWN
      ary=[PBItems::CHOICESPECS]
    when PBSpecies::GIRAFARIG
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST,PBItems::GIRAFARIGITE]
    when PBSpecies::PINECO
      ary=[PBItems::LEFTOVERS,PBItems::CUSTAPBERRY]
    when PBSpecies::DUNSPARCE
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::SUNKERN
      ary=[PBItems::HEATROCK,PBItems::LIFEORB,PBItems::SUNFLORITE]
    when PBSpecies::GLIGAR
      ary=[PBItems::LEFTOVERS,PBItems::TOXICORB]
    when PBSpecies::SNUBBULL
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::QWILFISH
      ary=[PBItems::FOCUSSASH,PBItems::SPLASHPLATE]
    when PBSpecies::SHUCKLE
      ary=[PBItems::MENTALHERB]
    when PBSpecies::HERACROSS
      ary=[PBItems::HERACROSSITE,PBItems::BUGGEM,PBItems::FIGHTINGGEM]
    when PBSpecies::SNEASEL
      ary=[PBItems::LIFEORB,PBItems::CHOICEBAND]
    when PBSpecies::TEDDIURSA
      ary=[PBItems::TOXICORB,PBItems::TOXICORB]
    when PBSpecies::SLUGMA
      ary=[PBItems::LEFTOVERS,PBItems::FLAMEPLATE]
    when PBSpecies::SWINUB
      ary=[PBItems::FOCUSSASH,PBItems::CHOICEBAND]
    when PBSpecies::CORSOLA
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::REMORAID
      ary=[PBItems::CHOICESPECS]
    when PBSpecies::DELIBIRD
      ary=[PBItems::FOCUSSASH,PBItems::CHOICEBAND]
    when PBSpecies::SKARMORY
      ary=[PBItems::LEFTOVERS,PBItems::ROCKYHELMET]
    when PBSpecies::HOUNDOUR
      ary=[PBItems::HOUNDOOMITE,PBItems::LIFEORB]
    when PBSpecies::PHANPY
      ary=[PBItems::DONPHANITE,PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::STANTLER
      ary=[PBItems::LIFEORB]
    when PBSpecies::SMEARGLE
      ary=[PBItems::FOCUSSASH,PBItems::LEFTOVERS]
    when PBSpecies::TYROGUE
      ary=[PBItems::LEFTOVERS,PBItems::SITRUSBERRY,PBItems::LIFEORB,PBItems::CHOICESCARF]
    when PBSpecies::SMOOCHUM
      ary=[PBItems::CHOICESCARF,PBItems::LIFEORB,PBItems::LEFTOVERS]
    when PBSpecies::ELEKID
      ary=[PBItems::LIFEORB,PBItems::AIRBALLOON]
    when PBSpecies::MAGBY
      ary=[PBItems::CHOICESPECS]
    when PBSpecies::MILTANK
      ary=[PBItems::LIFEORB]
    when PBSpecies::LARVITAR
      ary=[PBItems::TYRANITARITE,PBItems::CHOICESCARF,PBItems::SMOOTHROCK]
    when PBSpecies::TREECKO
      ary=[PBItems::SCEPTITE,PBItems::LIFEORB]
    when PBSpecies::TORCHIC
      ary=[PBItems::FOCUSSASH,PBItems::BLAZIKENITE]
    when PBSpecies::MUDKIP
      ary=[PBItems::LEFTOVERS,PBItems::SWAMPERTITE]
    when PBSpecies::POOCHYENA
      ary=[PBItems::LIFEORB,PBItems::BLACKGLASSES]
    when PBSpecies::ZIGZAGOON
      ary=[PBItems::SITRUSBERRY,PBItems::SILKSCARF]
    when PBSpecies::WURMPLE
      ary=[PBItems::FOCUSSASH,PBItems::LIFEORB,PBItems::BLACKSLUDGE]
    when PBSpecies::LOTAD
      ary=[PBItems::DAMPROCK,PBItems::LIFEORB,PBItems::LEFTOVERS]
    when PBSpecies::SEEDOT
      ary=[PBItems::SHIFTRITE,PBItems::LIFEORB,PBItems::DREADPLATE]
    when PBSpecies::TAILLOW
      ary=[PBItems::CHOICESPECS,PBItems::TOXICORB]
    when PBSpecies::WINGULL
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::RALTS
      ary=[PBItems::GARDEVOIRITE,PBItems::CHOICESPECS,PBItems::LEFTOVERS,PBItems::DAWNSTONE]
    when PBSpecies::SURSKIT
      ary=[PBItems::FOCUSSASH,PBItems::LEFTOVERS]
    when PBSpecies::SHROOMISH
      ary=[PBItems::TOXICORB,PBItems::FOCUSSASH]
    when PBSpecies::SLAKOTH
      ary=[PBItems::CHOICEBAND]
    when PBSpecies::NINCADA
      ary=[PBItems::FOCUSSASH,PBItems::LIFEORB]
    when PBSpecies::WHISMUR
      ary=[PBItems::CHOICESPECS,PBItems::EVIOLITE]
    when PBSpecies::MAKUHITA
      ary=[PBItems::LEFTOVERS,PBItems::FLAMEORB]
    when PBSpecies::AZURILL
      ary=[PBItems::SITRUSBERRY,PBItems::ASSAULTVEST,PBItems::CHOICEBAND]
    when PBSpecies::SKITTY
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::SABLEYE
      ary=[PBItems::SABLITE,PBItems::LEFTOVERS]
    when PBSpecies::MAWILE
      ary=[PBItems::MAWILITE]
    when PBSpecies::ARON
      ary=[PBItems::SHELLBELL,PBItems::AGGRONITE]
    when PBSpecies::MEDITITE
      ary=[PBItems::MEDICHAMITE,PBItems::CHOICEBAND]
    when PBSpecies::ELECTRIKE
      ary=[PBItems::MANECTRITE,PBItems::CHOICESPECS]
    when PBSpecies::PLUSLE
      ary=[PBItems::LEFTOVERS,PBItems::CHOICESPECS]
    when PBSpecies::MINUN
      ary=[PBItems::LEFTOVERS,PBItems::CHOICESPECS]
    when PBSpecies::VOLBEAT
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::ILLUMISE
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::GULPIN
      ary=[PBItems::BLACKSLUDGE,PBItems::ASSAULTVEST]
    when PBSpecies::CARVANHA
      ary=[PBItems::LIFEORB]
    when PBSpecies::WAILMER
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::NUMEL
      ary=[PBItems::LEFTOVERS,PBItems::CHOICESPECS]
    when PBSpecies::TORKOAL
      ary=[PBItems::LEFTOVERS,PBItems::WHITEHERB]
    when PBSpecies::SPOINK
      ary=[PBItems::CHOICESPECS,PBItems::LEFTOVERS]
    when PBSpecies::SPINDA
      ary=[PBItems::CHOICEBAND]
    when PBSpecies::TRAPINCH
      ary=[PBItems::FLYGONITE,PBItems::CHOICEBAND]
    when PBSpecies::CACNEA
      ary=[PBItems::CACTURNITE,PBItems::FOCUSSASH,PBItems::LIFEORB]
    when PBSpecies::SWABLU
      ary=[PBItems::ALTARITE,PBItems::LIFEORB]
    when PBSpecies::ZANGOOSE
      ary=[PBItems::TOXICORB]
    when PBSpecies::SEVIPER
      ary=[PBItems::LIFEORB,PBItems::BLACKSLUDGE]
    when PBSpecies::LUNATONE
      ary=[PBItems::LIFEORB,PBItems::LEFTOVERS,PBItems::LIGHTCLAY]
    when PBSpecies::SOLROCK
      ary=[PBItems::LIFEORB,PBItems::LEFTOVERS,PBItems::LIGHTCLAY]
    when PBSpecies::BARBOACH
      ary=[PBItems::LEFTOVERS,PBItems::LIFEORB]
    when PBSpecies::CORPHISH
      ary=[PBItems::CRAWDITE,PBItems::LIFEORB]
    when PBSpecies::BALTOY
      ary=[PBItems::LIGHTCLAY,PBItems::LEFTOVERS]
    when PBSpecies::LILEEP
      ary=[PBItems::ASSAULTVEST,PBItems::LEFTOVERS]
    when PBSpecies::ANORITH
      ary=[PBItems::CHOICEBAND,PBItems::LIFEORB]
    when PBSpecies::FEEBAS
      ary=[PBItems::LEFTOVERS,PBItems::MILOTITE]
    when PBSpecies::CASTFORM
      ary=[PBItems::EXPERTBELT]
    when PBSpecies::KECLEON
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::SHUPPET
      ary=[PBItems::FOCUSSASH,PBItems::BANNETITE]
    when PBSpecies::DUSKULL
      ary=[PBItems::LEFTOVERS,PBItems::REAPERCLOTH]
    when PBSpecies::TROPIUS
      ary=[PBItems::FOCUSSASH,PBItems::LUMBERRY,PBItems::SITRUSBERRY]
    when PBSpecies::CHIMECHO
      ary=[PBItems::LIGHTCLAY,PBItems::LEFTOVERS]
    when PBSpecies::ABSOL
      ary=[PBItems::ABSOLITE]
    when PBSpecies::WYNAUT
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::SNORUNT
      ary=[PBItems::DAWNSTONE,PBItems::FOCUSSASH]
    when PBSpecies::SPHEAL
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::CLAMPERL
      ary=[PBItems::LEFTOVERS,PBItems::WHITEHERB]
    when PBSpecies::RELICANTH
      ary=[PBItems::CHOICEBAND,PBItems::LIFEORB]
    when PBSpecies::LUVDISC
      ary=[PBItems::DAMPROCK,PBItems::LIFEORB]
    when PBSpecies::BAGON
      ary=[PBItems::SALAMENCITE,PBItems::CHOICESCARF]
    when PBSpecies::BELDUM
      ary=[PBItems::METAGRONITE,PBItems::LEFTOVERS,PBItems::LIGHTCLAY]
    when PBSpecies::TURTWIG
      ary=[PBItems::CHOICEBAND,PBItems::LEFTOVERS]
    when PBSpecies::CHIMCHAR
      ary=[PBItems::LIFEORB,PBItems::CHOICEBAND]
    when PBSpecies::PIPLUP
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::STARLY
      ary=[PBItems::CHOICEBAND,PBItems::CHOICESCARF]
    when PBSpecies::BIDOOF
      ary=[PBItems::LEFTOVERS,PBItems::CHESTOBERRY]
    when PBSpecies::KRICKETOT
      ary=[PBItems::FOCUSSASH,PBItems::LIFEORB]
    when PBSpecies::SHINX
      ary=[PBItems::LIFEORB,PBItems::EXPERTBELT]
    when PBSpecies::BUDEW
      ary=[PBItems::LIFEORB,PBItems::BLACKSLUDGE]
    when PBSpecies::CRANIDOS
      ary=[PBItems::LIFEORB,PBItems::CHOICEBAND]
    when PBSpecies::SHIELDON
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::BURMY
      ary=[PBItems::CHOICESPECS,PBItems::LEFTOVERS,PBItems::LIFEORB]
    when PBSpecies::COMBEE
      ary=[PBItems::LEFTOVERS,PBItems::FOCUSSASH]
    when PBSpecies::PACHIRISU
      ary=[PBItems::AIRBALLOON,PBItems::CHOICESPECS,PBItems::ZAPPLATE]
    when PBSpecies::BUIZEL
      ary=[PBItems::CHOICEBAND]
    when PBSpecies::CHERUBI
      ary=[PBItems::LEFTOVERS,PBItems::LIFEORB]
    when PBSpecies::SHELLOS
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::DRIFLOON
      ary=[PBItems::ASSAULTVEST,PBItems::LEFTOVERS,PBItems::CHESTOBERRY]
    when PBSpecies::BUNEARY
      ary=[PBItems::LOPUNNITE,PBItems::CHOICESCARF]
    when PBSpecies::GLAMEOW
      ary=[PBItems::SILKSCARF,PBItems::LIFEORB,PBItems::NORMALGEM]
    when PBSpecies::CHINGLING
      ary=[PBItems::LIGHTCLAY,PBItems::LEFTOVERS]
    when PBSpecies::STUNKY
      ary=[PBItems::BLACKSLUDGE,PBItems::LEFTOVERS,PBItems::AIRBALLOON]
    when PBSpecies::BRONZOR
      ary=[PBItems::LIGHTCLAY,PBItems::LEFTOVERS]
    when PBSpecies::BONSLY
      ary=[PBItems::LEFTOVERS,PBItems::CHOICEBAND]
    when PBSpecies::MIMEJR
      ary=[PBItems::LEFTOVERS,PBItems::LIFEORB]
    when PBSpecies::HAPPINY
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::CHATOT
      ary=[PBItems::LEFTOVERS,PBItems::LIFEORB,PBItems::WEAKNESSPOLICY]
    when PBSpecies::SPIRITOMB
      ary=[PBItems::LEFTOVERS,PBItems::BLACKGLASSES,PBItems::CHOICESPECS,PBItems::CHOICEBAND]
    when PBSpecies::GIBLE
      ary=[PBItems::GARCHOMPITE,PBItems::CHOICESCARF]
    when PBSpecies::NOSEPASS
      ary=[PBItems::WEAKNESSPOLICY,PBItems::LEFTOVERS]
    when PBSpecies::MUNCHLAX
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::RIOLU
      ary=[PBItems::LUCARIONITE,PBItems::LIFEORB]
    when PBSpecies::HIPPOPOTAS
      ary=[PBItems::LEFTOVERS,PBItems::SMOOTHROCK]
    when PBSpecies::SKORUPI
      ary=[PBItems::LUMBERRY,PBItems::BLACKSLUDGE,PBItems::LIFEORB]
    when PBSpecies::CROAGUNK
      ary=[PBItems::BLACKSLUDGE,PBItems::LIFEORB]
    when PBSpecies::CARNIVINE
      ary=[PBItems::FOCUSSASH,PBItems::LEFTOVERS]
    when PBSpecies::FINNEON
      ary=[PBItems::DAMPROCK,PBItems::LEFTOVERS,PBItems::CHOICESPECS]
    when PBSpecies::MANTYKE
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::SNOVER
      ary=[PBItems::ABOMASITE,PBItems::FOCUSSASH]
    when PBSpecies::ROTOM
      ary=[PBItems::LEFTOVERS,PBItems::AIRBALLOON]
    when PBSpecies::SNIVY
      ary=[PBItems::LIGHTCLAY,PBItems::LIFEORB]
    when PBSpecies::TEPIG
      ary=[PBItems::EXPERTBELT,PBItems::CHOICESCARF]
    when PBSpecies::OSHAWOTT
      ary=[PBItems::LIFEORB,PBItems::LUMBERRY]
    when PBSpecies::HAWLUCHA
      ary=[PBItems::LIFEORB,PBItems::FLYINGGEM]
    when PBSpecies::PATRAT
      ary=[PBItems::LIFEORB]
    when PBSpecies::LILLIPUP
      ary=[PBItems::CHOICEBAND,PBItems::LIFEORB]
    when PBSpecies::PURRLOIN
      ary=[PBItems::BLACKGLASSES,PBItems::DAMPROCK]
    when PBSpecies::PANSAGE
      ary=[PBItems::CHOICESPECS,PBItems::MEADOWPLATE]
    when PBSpecies::PANSEAR
      ary=[PBItems::CHOICESPECS,PBItems::FLAMEPLATE]
    when PBSpecies::PANPOUR
      ary=[PBItems::CHOICESPECS,PBItems::SPLASHPLATE]
    when PBSpecies::MUNNA
      ary=[PBItems::LEFTOVERS,PBItems::LIGHTCLAY]
    when PBSpecies::PIDOVE
      ary=[PBItems::LEFTOVERS,PBItems::FOCUSSASH]
    when PBSpecies::BLITZLE
      ary=[PBItems::CHOICESCARF,PBItems::LIFEORB,PBItems::EXPERTBELT]
    when PBSpecies::ROGGENROLA
      ary=[PBItems::CUSTAPBERRY,PBItems::WEAKNESSPOLICY]
    when PBSpecies::WOOBAT
      ary=[PBItems::CHOICESPECS,PBItems::LIFEORB]
    when PBSpecies::DRILBUR
      ary=[PBItems::LIFEORB,PBItems::ASSAULTVEST]
    when PBSpecies::AUDINO
      ary=[PBItems::AUDINITE,PBItems::LEFTOVERS]
    when PBSpecies::TIMBURR
      ary=[PBItems::EXPERTBELT,PBItems::LIFEORB]
    when PBSpecies::TYMPOLE
      ary=[PBItems::LIFEORB]
    when PBSpecies::THROH
      ary=[PBItems::WEAKNESSPOLICY,PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::SAWK
      ary=[PBItems::WEAKNESSPOLICY,PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::SEWADDLE
      ary=[PBItems::FOCUSSASH,PBItems::LIFEORB]
    when PBSpecies::VENIPEDE
      ary=[PBItems::LIFEORB,PBItems::MENTALHERB]
    when PBSpecies::COTTONEE
      ary=[PBItems::LEFTOVERS,PBItems::FOCUSSASH]
    when PBSpecies::PETILIL
      ary=[PBItems::LIFEORB,PBItems::CHOICESCARF]
    when PBSpecies::BASCULIN
      ary=[PBItems::CHOICEBAND]
    when PBSpecies::SANDILE
      ary=[PBItems::LIFEORB,PBItems::CHOICESCARF,PBItems::CHOICEBAND]
    when PBSpecies::DARUMAKA
      ary=[PBItems::CHOICEBAND,PBItems::CHOICESCARF]
    when PBSpecies::MARACTUS
      ary=[PBItems::FOCUSSASH,PBItems::LEFTOVERS]
    when PBSpecies::DWEBBLE
      ary=[PBItems::WHITEHERB,PBItems::LUMBERRY]
    when PBSpecies::SCRAGGY
      ary=[PBItems::LUMBERRY,PBItems::LIFEORB]
    when PBSpecies::SIGILYPH
      ary=[PBItems::FLAMEORB,PBItems::WEAKNESSPOLICY]
    when PBSpecies::YAMASK
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::TIRTOUGA
      ary=[PBItems::WHITEHERB,PBItems::LIFEORB,PBItems::LUMBERRY]
    when PBSpecies::ARCHEN
      ary=[PBItems::FLYINGGEM]
    when PBSpecies::TRUBBISH
      ary=[PBItems::FOCUSSASH,PBItems::ASSAULTVEST]
    when PBSpecies::ZORUA
      ary=[PBItems::FOCUSSASH,PBItems::LIFEORB]
    when PBSpecies::MINCCINO
      ary=[PBItems::LIFEORB,PBItems::KINGSROCK]
    when PBSpecies::GOTHITA
      ary=[PBItems::CHOICESPECS,PBItems::LEFTOVERS]
    when PBSpecies::SOLOSIS
      ary=[PBItems::TOXICORB,PBItems::LIFEORB,PBItems::LEFTOVERS,PBItems::REUNICLITE]
    when PBSpecies::DUCKLETT
      ary=[PBItems::LIFEORB,PBItems::FOCUSSASH]
    when PBSpecies::VANILLITE
      ary=[PBItems::ICICLEPLATE,PBItems::LIFEORB,PBItems::LEFTOVERS]
    when PBSpecies::DEERLING
      ary=[PBItems::LIFEORB,PBItems::CHOICEBAND,PBItems::LEFTOVERS]
    when PBSpecies::EMOLGA
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::KARRABLAST
      ary=[PBItems::ASSAULTVEST,PBItems::CHOICEBAND]
    when PBSpecies::FOONGUS
      ary=[PBItems::ASSAULTVEST,PBItems::BLACKSLUDGE]
    when PBSpecies::FRILLISH
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::ALOMOMOLA
      ary=[PBItems::LEFTOVERS,PBItems::ROCKYHELMET]
    when PBSpecies::JOLTIK
      ary=[PBItems::FOCUSSASH,PBItems::WEAKNESSPOLICY]
    when PBSpecies::FERROSEED
      ary=[PBItems::ROCKYHELMET]
    when PBSpecies::KLINK
      ary=[PBItems::LIFEORB,PBItems::LEFTOVERS]
    when PBSpecies::TYNAMO
      ary=[PBItems::ASSAULTVEST,PBItems::LEFTOVERS]
    when PBSpecies::ELGYEM
      ary=[PBItems::CHOICESPECS,PBItems::LIFEORB]
    when PBSpecies::LITWICK
      ary=[PBItems::LEFTOVERS,PBItems::CHOICESCARF]
    when PBSpecies::AXEW
      ary=[PBItems::WEAKNESSPOLICY,PBItems::CHOICEBAND,PBItems::CHOICESCARF]
    when PBSpecies::CUBCHOO
      ary=[PBItems::LIFEORB,PBItems::FOCUSSASH]
    when PBSpecies::CRYOGONAL
      ary=[PBItems::FOCUSSASH,PBItems::LEFTOVERS]
    when PBSpecies::SHELMET
      ary=[PBItems::FOCUSSASH,PBItems::LIFEORB]
    when PBSpecies::STUNFISK
      ary=[PBItems::WEAKNESSPOLICY,PBItems::ASSAULTVEST]
    when PBSpecies::MIENFOO
      ary=[PBItems::LIFEORB]
    when PBSpecies::DRUDDIGON
      ary=[PBItems::LIFEORB,PBItems::ASSAULTVEST,PBItems::CHOICEBAND,PBItems::ROCKYHELMET]
    when PBSpecies::GOLETT
      ary=[PBItems::LEFTOVERS,PBItems::CHOICEBAND]
    when PBSpecies::PAWNIARD
      ary=[PBItems::BISHARPITE,PBItems::LIFEORB,PBItems::FOCUSSASH,PBItems::CHOICEBAND]
    when PBSpecies::BOUFFALANT
      ary=[PBItems::LIFEORB,PBItems::CHOICEBAND]
    when PBSpecies::RUFFLET
      ary=[PBItems::CHOICESCARF,PBItems::LIFEORB]
    when PBSpecies::VULLABY
      ary=[PBItems::LEFTOVERS,PBItems::ROCKYHELMET]
    when PBSpecies::HEATMOR
      ary=[PBItems::EXPERTBELT,PBItems::LIFEORB]
    when PBSpecies::DURANT
      ary=[PBItems::CHOICEBAND,PBItems::LIFEORB,PBItems::LUMBERRY]
    when PBSpecies::DEINO
      ary=[PBItems::EXPERTBELT,PBItems::CHOICESPECS]
    when PBSpecies::LARVESTA
      ary=[PBItems::WEAKNESSPOLICY,PBItems::FOCUSSASH,PBItems::LUMBERRY]
    when PBSpecies::CHESPIN
      ary=[PBItems::LEFTOVERS,PBItems::ROCKYHELMET]
    when PBSpecies::FENNEKIN
      ary=[PBItems::CHOICESCARF,PBItems::CHOICESPECS,PBItems::LIFEORB,PBItems::EXPERTBELT,PBItems::LEFTOVERS]
    when PBSpecies::FROAKIE
      ary=[PBItems::LIFEORB]
    when PBSpecies::BUNNELBY
      ary=[PBItems::CHOICESCARF,PBItems::FOCUSSASH,PBItems::LIFEORB]
    when PBSpecies::FLETCHLING
      ary=[PBItems::LEFTOVERS,PBItems::CHOICEBAND,PBItems::LIFEORB,PBItems::SKYPLATE]
    when PBSpecies::SCATTERBUG
      ary=[PBItems::FOCUSSASH,PBItems::LIFEORB]
    when PBSpecies::LITLEO
      ary=[PBItems::CHOICESPECS,PBItems::LIFEORB,PBItems::EXPERTBELT]
    when PBSpecies::FLABEBE
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::SKIDDO
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::PANCHAM
      ary=[PBItems::CHOICEBAND,PBItems::LIFEORB]
    when PBSpecies::FURFROU
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::ESPURR
      ary=[PBItems::LIFEORB,PBItems::LIGHTCLAY]
    when PBSpecies::HONEDGE
      ary=[PBItems::LEFTOVERS,PBItems::EVIOLITE]
    when PBSpecies::SPRITZEE
      ary=[PBItems::LEFTOVERS,PBItems::PIXIEPLATE]
    when PBSpecies::SWIRLIX
      ary=[PBItems::SITRUSBERRY,PBItems::LEFTOVERS]
    when PBSpecies::INKAY
      ary=[PBItems::LEFTOVERS,PBItems::SITRUSBERRY]
    when PBSpecies::BINACLE
      ary=[PBItems::WHITEHERB,PBItems::FOCUSSASH]
    when PBSpecies::SKRELP
      ary=[PBItems::LEFTOVERS,PBItems::LIFEORB,PBItems::BLACKSLUDGE,PBItems::CHOICESPECS]
    when PBSpecies::CLAUNCHER
      ary=[PBItems::LIFEORB,PBItems::ASSAULTVEST,PBItems::LEFTOVERS]
    when PBSpecies::HELIOPTILE
      ary=[PBItems::CHOICESPECS,PBItems::LIFEORB]
    when PBSpecies::TYRUNT
      ary=[PBItems::FOCUSSASH,PBItems::CHOICEBAND,PBItems::LEFTOVERS,PBItems::WEAKNESSPOLICY]
    when PBSpecies::AMAURA
      ary=[PBItems::FOCUSSASH]
    when PBSpecies::DEDENNE
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::CARBINK
      ary=[PBItems::LIGHTCLAY,PBItems::LEFTOVERS]
    when PBSpecies::GOOMY
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::KLEFKI
      ary=[PBItems::LEFTOVERS,PBItems::LIGHTCLAY]
    when PBSpecies::PHANTUMP
      ary=[PBItems::LEFTOVERS,PBItems::SITRUSBERRY,PBItems::LUMBERRY]
    when PBSpecies::PUMPKABOO
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::BERGMITE
      ary=[PBItems::FOCUSSASH,PBItems::LEFTOVERS]
    when PBSpecies::NOIBAT
      ary=[PBItems::CHOICESPECS,PBItems::LIFEORB,PBItems::EXPERTBELT]
    when PBSpecies::DELTACHARMANDER
      ary=[PBItems::DELTACHARIZARDITE,PBItems::CHOICESPECS]
    when PBSpecies::DELTABULBASAUR
      ary=[PBItems::DELTAVENUSAURITE,PBItems::CHOICESPECS]
    when PBSpecies::DELTASQUIRTLE
      ary=[PBItems::CHOICESPECS,PBItems::DELTABLASTOISINITE]
    
    when PBSpecies::DELTAPAWNIARD
      ary=[PBItems::LIFEORB,PBItems::DELTABISHARPITE,PBItems::CHOICEBAND]
    when PBSpecies::DELTASUNKERN
      ary=[PBItems::BLACKSLUDGE,PBItems::FLAMEPLATE]
    when PBSpecies::DELTABERGMITE
      ary=[PBItems::DRAGONFANG,PBItems::FOCUSSASH,PBItems::LEFTOVERS]
    when PBSpecies::DELTARALTS
      ary=[PBItems::CHOICESPECS,PBItems::ICICLEPLATE] #PBItems::DELTAGARDEVOIRITE
    when PBSpecies::DELTASCYTHER
      ary=[PBItems::LEFTOVERS,PBItems::LIFEORB] #PBItems::DELTASCIZORITE
    when PBSpecies::DELTASCRAGGY
      ary=[PBItems::LEFTOVERS,PBItems::EXPERTBELT]
    when PBSpecies::DELTACOMBEE
      ary=[PBItems::CHOICESCARF,PBItems::LEFTOVERS,PBItems::LIFEORB]
    when PBSpecies::DELTAKOFFING
      ary=[PBItems::CHOICESPECS,PBItems::LEFTOVERS]
    when PBSpecies::DELTAPURRLOIN
      ary=[PBItems::CHOICESPECS,PBItems::CHOICESCARF]
    when PBSpecies::DELTAPHANTUMP
      ary=[PBItems::CHOICESPECS,PBItems::LEFTOVERS]
    when PBSpecies::DELTASNORUNT
      ary=[PBItems::EXPERTBELT,PBItems::LEFTOVERS]
    when PBSpecies::DELTASHINX
      ary=[PBItems::POISONGEM,PBItems::LEFTOVERS]
    when PBSpecies::DELTANOIBAT
      ary=[PBItems::AIRBALLOON,PBItems::CHOICESPECS]
    when PBSpecies::DELTABUDEW
      ary=[PBItems::CHOICESPECS,PBItems::LEFTOVERS]
    when PBSpecies::DELTADRIFLOON
      ary=[PBItems::CHOICESPECS,PBItems::LEFTOVERS]
    when PBSpecies::DELTAGRIMER
      ary=[PBItems::ASSAULTVEST,PBItems::LEFTOVERS]
    when PBSpecies::DELTAWOOPER
      ary=[PBItems::LEFTOVERS,PBItems::CHOICESCARF]
    when PBSpecies::DELTAMUNCHLAX
      ary=[PBItems::SHELLBELL]
    when PBSpecies::DELTAMISDREAVUS
      ary=[PBItems::ICEGEM,PBItems::ICYROCK]
    when PBSpecies::DELTACYNDAQUIL
      ary=[PBItems::DELTATYPHLOSIONITE,PBItems::LIFEORB]
    when PBSpecies::DELTATREECKO
      ary=[PBItems::EXPERTBELT]
    when PBSpecies::DELTATORCHIC
      ary=[PBItems::CHOICESCARF,PBItems::EXPERTBELT,PBItems::LIFEORB]
    when PBSpecies::DELTATURTWIG
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::DELTASNIVY
      ary=[PBItems::RARECANDY,PBItems::EXPERTBELT,PBItems::LIFEORB]
    when PBSpecies::DELTAFROAKIE
      ary=[PBItems::GRASSGEM,PBItems::FIREGEM,PBItems::LIFEORB]
    when PBSpecies::DELTAPIDGEY
      ary=[PBItems::HARDSTONE,PBItems::LEFTOVERS]

    when PBSpecies::DELTADIGLETT
      ary=[PBItems::ICYROCK,PBItems::FOCUSSASH]
    when PBSpecies::DELTAGROWLITHE
      ary=[PBItems::SHINYSTONE]
    when PBSpecies::DELTAGEODUDE
      ary=[PBItems::LEFTOVERS,PBItems::SHELLBELL]
    when PBSpecies::DELTATENTACOOL
      ary=[PBItems::BLACKSLUDGE]
    when PBSpecies::DELTADODUO
      ary=[PBItems::TWISTEDSPOON]
    when PBSpecies::DELTATANGELA
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::DELTADITTO
      ary=[PBItems::LEFTOVERS]
   when PBSpecies::DELTAKABUTO
      ary=[PBItems::CHOICEBAND,PBItems::CHOICESCARF]
  when PBSpecies::DELTADRATINI
      ary=[PBItems::LEPPABERRY,PBItems::ELECTRICGEM,PBItems::WEAKNESSPOLICY]
  when PBSpecies::DELTAHOOTHOOT
      ary=[PBItems::FOCUSSASH,PBItems::ICEGEM]
    when PBSpecies::DELTACHINCHOU
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::DELTAPICHU
      
      ary=[PBItems::IRONBALL,PBItems::FLYINGGEM,PBItems::FOCUSSASH]
    when PBSpecies::DELTAAIPOM
      ary=[PBItems::SPELLTAG]
    when PBSpecies::DELTAYANMA
      ary=[PBItems::WEAKNESSPOLICY,PBItems::ASSAULTVEST,PBItems::FOCUSSASH]
    when PBSpecies::DELTAGIRAFARIG
      ary=[PBItems::DELTAGIRAFARIGITE,PBItems::EXPERTBELT]
    when PBSpecies::DELTADUNSPARCE
      ary=[PBItems::LEFTOVERS,PBItems::BUGGEM]
    when PBSpecies::DELTASHUCKLE
      ary=[PBItems::LEFTOVERS,PBItems::AMULETCOIN]
    when PBSpecies::DELTAREMORAID
      ary=[PBItems::AMULETCOIN,PBItems::CHOICESPECS]
    when PBSpecies::DELTAELEKID
      ary=[PBItems::CHOICEBAND,PBItems::LIFEORB]
    when PBSpecies::DELTAMAGBY
      ary=[PBItems::LEFTOVERS,PBItems::CHOICESPECS]
    when PBSpecies::DELTALOTAD
      ary=[PBItems::CHOICESPECS,PBItems::MYSTICWATER]
    when PBSpecies::DELTASEEDOT
      ary=[PBItems::AIRBALLOON]
    when PBSpecies::DELTASABLEYE
      ary=[PBItems::DELTASABLENITE]
    when PBSpecies::DELTAMAWILE
      ary=[PBItems::DELTAMAWILITE,PBItems::LEFTOVERS,PBItems::CHOICEBAND]
    when PBSpecies::DELTAARON
      ary=[PBItems::WEAKNESSPOLICY]
    when PBSpecies::DELTAMEDITITE
      ary=[PBItems::EXPERTBELT,PBItems::DELTAMEDICHAMITE]
    when PBSpecies::DELTANUMEL
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::DELTAPLUSLE
      ary=[PBItems::FIREGEM]
    when PBSpecies::DELTAMINUN
      ary=[PBItems::ICEGEM]
    when PBSpecies::DELTAWAILMER
      ary=[PBItems::WEAKNESSPOLICY,PBItems::EXPERTBELT]
    when PBSpecies::DELTAFEEBAS
      ary=[PBItems::CHOICESPECS,PBItems::DELTAMILOTICITE]
    when PBSpecies::DELTACLAMPERL
      ary=[PBItems::DRAGONFANG,PBItems::DRAGONSCALE]
    when PBSpecies::DELTABELDUM1
      ary=[PBItems::CHOICEBAND]
    when PBSpecies::DELTABELDUM2
      ary=[PBItems::CHOICEBAND]
    when PBSpecies::DELTABUNEARY
      ary=[PBItems::EXPERTBELT,PBItems::DELTALOPUNNITE]
    when PBSpecies::DELTARIOLU
      ary=[PBItems::DELTALUCARIONITE,PBItems::CHOICEBAND]
    when PBSpecies::DELTACROAGUNK
      ary=[PBItems::LIFEORB,PBItems::RARECANDY]
    when PBSpecies::DELTAVENIPEDE
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    when PBSpecies::DELTAPETILIL1 #water/fire
      
      ary=[PBItems::MYSTICWATER]
    when PBSpecies::DELTAPETILIL2
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::DELTASOLOSIS
      ary=[PBItems::CHOICESPECS,PBItems::ASSAULTVEST]
    when PBSpecies::DELTADARUMAKA
      ary=[PBItems::EXPERTBELT,PBItems::CHOICEBAND]
    when PBSpecies::DELTAMARACTUS
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::DELTADWEBBLE1
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::DELTADWEBBLE2
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::DELTAYAMASK
      ary=[PBItems::RARECANDY]
    when PBSpecies::DELTAEMOLGA
      ary=[PBItems::FIREGEM,PBItems::CHOICESCARF]
    when PBSpecies::DELTAKARRABLAST
      ary=[PBItems::WEAKNESSPOLICY]
    when PBSpecies::DELTAFOONGUS
      ary=[PBItems::LEFTOVERS]
    when PBSpecies::DELTALITWICK
      ary=[PBItems::ASSAULTVEST]
    when PBSpecies::DELTAAXEW
      ary=[PBItems::CHOICEBAND,PBItems::EXPERTBELT]
    when PBSpecies::DELTAGOLETT
      ary=[PBItems::CHOICEBAND]
    when PBSpecies::DELTAHEATMOR
      ary=[PBItems::WEAKNESSPOLICY]
    when PBSpecies::DELTADEINO
      ary=[PBItems::EXPERTBELT]
    when PBSpecies::DELTALARVESTA
      ary=[PBItems::DVOLCARONAARMOR]
    when PBSpecies::DELTAAMAURA
      ary=[PBItems::LEFTOVERS,PBItems::GRASSGEM]
    when PBSpecies::DELTAGOOMY
      ary=[PBItems::LEFTOVERS,PBItems::ASSAULTVEST]
    end
    
      

    return ary[rand(ary.length)]
    
end

  

def getRandomEggNatureFor(pkmn,num)
    case pkmn
    when PBSpecies::BULBASAUR
      ary=[PBNatures::TIMID,PBNatures::BOLD,PBNatures::MODEST,PBNatures::CALM]
    when PBSpecies::CHARMANDER
      ary=[PBNatures::ADAMANT,PBNatures::MODEST]
      when PBSpecies::SQUIRTLE
      ary=[PBNatures::MDOEST,PBNatures::TIMID]
    when PBSpecies::CATERPIE
      ary=[PBNatures::MODEST,PBNatures::TIMID]
    when PBSpecies::WEEDLE
      ary=[PBNatures::JOLLY]
    when PBSpecies::PIDGEY
      ary=[PBNatures::JOLLY,PBNatures::ADAMANT]
    when PBSpecies::RATTATA
      ary=[PBNatures::JOLLY,PBNatures::ADAMANT]
    when PBSpecies::SPEAROW
      ary=[PBNatures::ADAMANT,PBNatures::JOLLY]
    when PBSpecies::EKANS
      ary=[PBNatures::ADAMANT,PBNatures::JOLLY]
    when PBSpecies::SANDSHREW
      ary=[PBNatures::ADAMANT,PBNatures::JOLLY]
    when PBSpecies::NIDORANfE
      ary=[PBNatures::MODEST,PBNatures::TIMID]
    when PBSpecies::NIDORANmA
      ary=[PBNatures::MODEST,PBNatures::TIMID]
    when PBSpecies::CLEFAIRY
      ary=[PBNatures::CALM,PBNatures::BOLD]
    when PBSpecies::VULPIX
      ary=[PBNatures::MODEST]
    when PBSpecies::ZUBAT
      ary=[PBNatures::JOLLY,PBNatures::ADAMANT]
    when PBSpecies::ODDISH
      ary=[PBNatures::BOLD,PBNatures::CALM,PBNatures::MODEST]
    when PBSpecies::PARAS
      ary=[PBNatures::CAREFUL,PBNatures::IMPISH]
    when PBSpecies::VENONAT
      ary=[PBNatures::TIMID,PBNatures::MODEST]
    when PBSpecies::DIGLETT
      ary=[PBNatures::JOLLY,PBNatures::ADAMANT]
    when PBSpecies::MEOWTH
      ary=[PBNatures::JOLLY,PBNatures::ADAMANT]
    when PBSpecies::PSYDUCK
      ary=[PBNatures::MODEST]
    when PBSpecies::MANKEY
      ary=[PBNatures::JOLLY,PBNatures::ADAMANT]
    when PBSpecies::GROWLITHE
      ary=[PBNatures::IMPISH,PBNatures::ADAMANT]
    when PBSpecies::POLIWAG
      ary=[PBNatures::TIMID,PBNatures::JOLLY,PBNatures::MODEST]
    when PBSpecies::ABRA
      ary=[PBNatures::TIMID,PBNatures::MODEST]
    when PBSpecies::MACHOP
      ary=[PBNatures::JOLLY,PBNatures::ADAMANT]
    when PBSpecies::BELLSPROUT
      ary=[PBNatures::TIMID,PBNatures::CALM]
    when PBSpecies::TENTACOOL
      ary=[PBNatures::CALM]
    when PBSpecies::GEODUDE
      ary=[PBNatures::ADAMANT]
    when PBSpecies::PONYTA
      ary=[PBNatures::ADAMANT,PBNatures::JOLLY]
=begin
    when PBSpecies::SLOWPOKE
      ary=[]
    when PBSpecies::MAGNEMITE
      ary=[]
    when PBSpecies::FARFETCHD
      ary=[]
    when PBSpecies::DODUO
      ary=[]
    when PBSpecies::SEEL
      ary=[]
    when PBSpecies::GRIMER
      ary=[]
    when PBSpecies::SHELLDER
      ary=[]
    when PBSpecies::GASTLY
      ary=[]
    when PBSpecies::ONIX
      ary=[]
    when PBSpecies::DROWZEE
      ary=[]
    when PBSpecies::HYPNO
      ary=[]
    when PBSpecies::VOLTORB
      ary=[]
    when PBSpecies::EXEGGCUTE
      ary=[]
    when PBSpecies::CUBONE
      ary=[]
    when PBSpecies::LICKITUNG
      ary=[]
    when PBSpecies::KOFFING
      ary=[]
    when PBSpecies::RHYHORN
      ary=[]
    when PBSpecies::TANGELA
      ary=[]
    when PBSpecies::KANGASKHAN
      ary=[]
    when PBSpecies::HORSEA
      ary=[]
    when PBSpecies::GOLDEEN
      ary=[]
    when PBSpecies::STARYU
      ary=[]
    when PBSpecies::MRMIME
      ary=[]
    when PBSpecies::SCYTHER
      ary=[]
    when PBSpecies::JYNX
      ary=[]
    when PBSpecies::PINSIR
      ary=[]
    when PBSpecies::TAUROS
      ary=[]
    when PBSpecies::MAGIKARP
      ary=[]
    when PBSpecies::LAPRAS
      ary=[]
    when PBSpecies::DITTO
      ary=[]
    when PBSpecies::EEVEE
      ary=[]
    when PBSpecies::PORYGON
      ary=[]
    when PBSpecies::OMANYTE
      ary=[]
    when PBSpecies::KABUTO
      ary=[]
    when PBSpecies::AERODACTYL
      ary=[]
    when PBSpecies::SNORLAX
      ary=[]
    when PBSpecies::DRATINI
      ary=[]
    when PBSpecies::CHIKORITA
      ary=[]
    when PBSpecies::CYNDAQUIL
      ary=[]
    when PBSpecies::TOTODILE
      ary=[]
    when PBSpecies::SENTRET
      ary=[]
    when PBSpecies::HOOTHOOT
      ary=[]
    when PBSpecies::LEDYBA
      ary=[]
    when PBSpecies::SPINARAK
      ary=[]
    when PBSpecies::CHINCHOU
      ary=[]
    when PBSpecies::PICHU
      ary=[]
    when PBSpecies::CLEFFA
      ary=[]
    when PBSpecies::IGGLYBUFF
      ary=[]
    when PBSpecies::TOGEPI
      ary=[]
    when PBSpecies::NATU
      ary=[]
    when PBSpecies::MAREEP
      ary=[]
    when PBSpecies::MARILL
      ary=[]
    when PBSpecies::AIPOM
      ary=[]
    when PBSpecies::HOPPIP
      ary=[]
    when PBSpecies::YANMA
      ary=[]
    when PBSpecies::WOOPER
      ary=[]
    when PBSpecies::MURKROW
      ary=[]
    when PBSpecies::MISDREAVUS
      ary=[]
    when PBSpecies::UNOWN
      ary=[]
    when PBSpecies::GIRAFARIG
      ary=[]
    when PBSpecies::PINECO
      ary=[]
    when PBSpecies::DUNSPARCE
      ary=[]
    when PBSpecies::GLIGAR
      ary=[]
    when PBSpecies::SNUBBULL
      ary=[]
    when PBSpecies::QWILFISH
      ary=[]
    when PBSpecies::SHUCKLE
      ary=[]
    when PBSpecies::HERACROSS
      ary=[]
    when PBSpecies::SNEASEL
      ary=[]
    when PBSpecies::TEDDIURSA
      ary=[]
    when PBSpecies::SLUGMA
      ary=[]
    when PBSpecies::SWINUB
      ary=[]
    when PBSpecies::CORSOLA
      ary=[]
    when PBSpecies::REMORAID
      ary=[]
    when PBSpecies::DELIBIRD
      ary=[]
    when PBSpecies::SKARMORY
      ary=[]
    when PBSpecies::HOUNDOUR
      ary=[]
    when PBSpecies::PHANPY
      ary=[]
    when PBSpecies::STANTLER
      ary=[]
    when PBSpecies::SMEARGLE
      ary=[]
    when PBSpecies::TYROGUE
      ary=[]
    when PBSpecies::SMOOCHUM
      ary=[]
    when PBSpecies::ELEKID
      ary=[]
    when PBSpecies::MAGBY
      ary=[]
    when PBSpecies::MILTANK
      ary=[]
    when PBSpecies::LARVITAR
      ary=[]
    when PBSpecies::TREECKO
      ary=[]
    when PBSpecies::TORCHIC
      ary=[]
    when PBSpecies::MUDKIP
      ary=[]
    when PBSpecies::POOCHYENA
      ary=[]
    when PBSpecies::ZIGZAGOON
      ary=[]
    when PBSpecies::WURMPLE
      ary=[]
    when PBSpecies::LOTAD
      ary=[]
    when PBSpecies::SEEDOT
      ary=[]
    when PBSpecies::TAILLOW
      ary=[]
    when PBSpecies::WINGULL
      ary=[]
    when PBSpecies::RALTS
      ary=[]
    when PBSpecies::SURSKIT
      ary=[]
    when PBSpecies::SHROOMISH
      ary=[]
    when PBSpecies::SLAKOTH
      ary=[]
    when PBSpecies::NINCADA
      ary=[]
    when PBSpecies::WHISMUR
      ary=[]
    when PBSpecies::MAKUHITA
      ary=[]
    when PBSpecies::AZURILL
      ary=[]
    when PBSpecies::SKITTY
      ary=[]
    when PBSpecies::DELCATTY
      ary=[]
    when PBSpecies::SABLEYE
      ary=[]
    when PBSpecies::MAWILE
      ary=[]
    when PBSpecies::ARON
      ary=[]
    when PBSpecies::MEDITITE
      ary=[]
    when PBSpecies::ELECTRIKE
      ary=[]
    when PBSpecies::PLUSLE
      ary=[]
    when PBSpecies::MINUN
      ary=[]
    when PBSpecies::VOLBEAT
      ary=[]
    when PBSpecies::ILLUMISE
      ary=[]
    when PBSpecies::GULPIN
      ary=[]
    when PBSpecies::CARVANHA
      ary=[]
    when PBSpecies::WAILMER
      ary=[]
    when PBSpecies::NUMEL
      ary=[]
    when PBSpecies::TORKOAL
      ary=[]
    when PBSpecies::SPOINK
      ary=[]
    when PBSpecies::SPINDA
      ary=[]
    when PBSpecies::TRAPINCH
      ary=[]
    when PBSpecies::CACNEA
      ary=[]
    when PBSpecies::SWABLU
      ary=[]
    when PBSpecies::ZANGOOSE
      ary=[]
    when PBSpecies::SEVIPER
      ary=[]
    when PBSpecies::LUNATONE
      ary=[]
    when PBSpecies::SOLROCK
      ary=[]
    when PBSpecies::BARBOACH
      ary=[]
    when PBSpecies::CORPHISH
      ary=[]
    when PBSpecies::BALTOY
      ary=[]
    when PBSpecies::LILEEP
      ary=[]
    when PBSpecies::ANORITH
      ary=[]
    when PBSpecies::FEEBAS
      ary=[]
    when PBSpecies::CASTFORM
      ary=[]
    when PBSpecies::KECLEON
      ary=[]
    when PBSpecies::SHUPPET
      ary=[]
    when PBSpecies::DUSKULL
      ary=[]
    when PBSpecies::TROPIUS
      ary=[]
    when PBSpecies::CHIMECHO
      ary=[]
    when PBSpecies::ABSOL
      ary=[]
    when PBSpecies::WYNAUT
      ary=[]
    when PBSpecies::SNORUNT
      ary=[]
    when PBSpecies::SPHEAL
      ary=[]
    when PBSpecies::CLAMPERL
      ary=[]
    when PBSpecies::RELICANTH
      ary=[]
    when PBSpecies::LUVDISC
      ary=[]
    when PBSpecies::BAGON
      ary=[]
    when PBSpecies::BELDUM
      ary=[]
    when PBSpecies::TURTWIG
      ary=[]
    when PBSpecies::CHIMCHAR
      ary=[]
    when PBSpecies::PIPLUP
      ary=[]
    when PBSpecies::STARLY
      ary=[]
    when PBSpecies::BIDOOF
      ary=[]
    when PBSpecies::KRICKETOT
      ary=[]
    when PBSpecies::SHINX
      ary=[]
    when PBSpecies::BUDEW
      ary=[]
    when PBSpecies::CRANIDOS
      ary=[]
    when PBSpecies::SHIELDON
      ary=[]
    when PBSpecies::BURMY
      ary=[]
    when PBSpecies::COMBEE
      ary=[]
    when PBSpecies::PACHIRISU
      ary=[]
    when PBSpecies::BUIZEL
      ary=[]
    when PBSpecies::CHERUBI
      ary=[]
    when PBSpecies::SHELLOS
      ary=[]
    when PBSpecies::DRIFLOON
      ary=[]
    when PBSpecies::BUNEARY
      ary=[]
    when PBSpecies::GLAMEOW
      ary=[]
    when PBSpecies::CHINGLING
      ary=[]
    when PBSpecies::STUNKY
      ary=[]
    when PBSpecies::BRONZOR
      ary=[]
    when PBSpecies::BONSLY
      ary=[]
    when PBSpecies::MIMEJR
      ary=[]
    when PBSpecies::HAPPINY
      ary=[]
    when PBSpecies::CHATOT
      ary=[]
    when PBSpecies::SPIRITOMB
      ary=[]
    when PBSpecies::GIBLE
      ary=[]
    when PBSpecies::MUNCHLAX
      ary=[]
    when PBSpecies::RIOLU
      ary=[]
    when PBSpecies::HIPPOPOTAS
      ary=[]
    when PBSpecies::SKORUPI
      ary=[]
    when PBSpecies::CROAGUNK
      ary=[]
    when PBSpecies::CARNIVINE
      ary=[]
    when PBSpecies::FINNEON
      ary=[]
    when PBSpecies::MANTYKE
      ary=[]
    when PBSpecies::SNOVER
      ary=[]
    when PBSpecies::ROTOM
      ary=[]
    when PBSpecies::SNIVY
      ary=[]
    when PBSpecies::TEPIG
      ary=[]
    when PBSpecies::OSHAWOTT
      ary=[]
    when PBSpecies::PATRAT
      ary=[]
    when PBSpecies::LILLIPUP
      ary=[]
    when PBSpecies::PURRLOIN
      ary=[]
    when PBSpecies::PANSAGE
      ary=[]
    when PBSpecies::PANSEAR
      ary=[]
    when PBSpecies::PANPOUR
      ary=[]
    when PBSpecies::MUNNA
      ary=[]
    when PBSpecies::PIDOVE
      ary=[]
    when PBSpecies::BLITZLE
      ary=[]
    when PBSpecies::ROGGENROLA
      ary=[]
    when PBSpecies::WOOBAT
      ary=[]
    when PBSpecies::DRILBUR
      ary=[]
    when PBSpecies::EXCADRILL
      ary=[]
    when PBSpecies::AUDINO
      ary=[]
    when PBSpecies::TIMBURR
      ary=[]
    when PBSpecies::TYMPOLE
      ary=[]
    when PBSpecies::THROH
      ary=[]
    when PBSpecies::SAWK
      ary=[]
    when PBSpecies::SEWADDLE
      ary=[]
    when PBSpecies::VENIPEDE
      ary=[]
    when PBSpecies::COTTONEE
      ary=[]
    when PBSpecies::PETILIL
      ary=[]
    when PBSpecies::BASCULIN
      ary=[]
    when PBSpecies::SANDILE
      ary=[]
    when PBSpecies::DARUMAKA
      ary=[]
    when PBSpecies::MARACTUS
      ary=[]
    when PBSpecies::DWEBBLE
      ary=[]
    when PBSpecies::SCRAGGY
      ary=[]
    when PBSpecies::SIGILYPH
      ary=[]
    when PBSpecies::YAMASK
      ary=[]
    when PBSpecies::TIRTOUGA
      ary=[]
    when PBSpecies::ARCHEN
      ary=[]
    when PBSpecies::TRUBBISH
      ary=[]
    when PBSpecies::ZORUA
      ary=[]
    when PBSpecies::MINCCINO
      ary=[]
    when PBSpecies::GOTHITA
      ary=[]
    when PBSpecies::SOLOSIS
      ary=[]
    when PBSpecies::DUCKLETT
      ary=[]
    when PBSpecies::VANILLITE
      ary=[]
    when PBSpecies::DEERLING
      ary=[]
    when PBSpecies::EMOLGA
      ary=[]
    when PBSpecies::KARRABLAST
      ary=[]
    when PBSpecies::FOONGUS
      ary=[]
    when PBSpecies::FRILLISH
      ary=[]
    when PBSpecies::ALOMOMOLA
      ary=[]
    when PBSpecies::JOLTIK
      ary=[]
    when PBSpecies::FERROSEED
      ary=[]
    when PBSpecies::KLINK
      ary=[]
    when PBSpecies::TYNAMO
      ary=[]
    when PBSpecies::ELGYEM
      ary=[]
    when PBSpecies::LITWICK
      ary=[]
    when PBSpecies::AXEW
      ary=[]
    when PBSpecies::CUBCHOO
      ary=[]
    when PBSpecies::CRYOGONAL
      ary=[]
    when PBSpecies::SHELMET
      ary=[]
    when PBSpecies::STUNFISK
      ary=[]
    when PBSpecies::MIENFOO
      ary=[]
    when PBSpecies::DRUDDIGON
      ary=[]
    when PBSpecies::GOLETT
      ary=[]
    when PBSpecies::PAWNIARD
      ary=[]
    when PBSpecies::BOUFFALANT
      ary=[]
    when PBSpecies::RUFFLET
      ary=[]
    when PBSpecies::VULLABY
      ary=[]
    when PBSpecies::HEATMOR
      ary=[]
    when PBSpecies::DURANT
      ary=[]
    when PBSpecies::DEINO
      ary=[]
    when PBSpecies::LARVESTA
      ary=[]
    when PBSpecies::CHESPIN
      ary=[]
    when PBSpecies::FENNEKIN
      ary=[]
    when PBSpecies::FROAKIE
      ary=[]
    when PBSpecies::BUNNELBY
      ary=[]
    when PBSpecies::FLETCHLING
      ary=[]
    when PBSpecies::SCATTERBUG
      ary=[]
    when PBSpecies::LITLEO
      ary=[]
    when PBSpecies::FLABEBE
      ary=[]
    when PBSpecies::SKIDDO
      ary=[]
    when PBSpecies::PANCHAM
      ary=[]
    when PBSpecies::FURFROU
      ary=[]
    when PBSpecies::ESPURR
      ary=[]
    when PBSpecies::HONEDGE
      ary=[]
    when PBSpecies::SPRITZEE
      ary=[]
    when PBSpecies::SWIRLIX
      ary=[]
    when PBSpecies::INKAY
      ary=[]
    when PBSpecies::BINACLE
      ary=[]
    when PBSpecies::SKRELP
      ary=[]
    when PBSpecies::CLAUNCHER
      ary=[]
    when PBSpecies::HELIOPTILE
      ary=[]
    when PBSpecies::TYRUNT
      ary=[]
    when PBSpecies::AMAURA
      ary=[]
    when PBSpecies::DEDENNE
      ary=[]
    when PBSpecies::CARBINK
      ary=[]
    when PBSpecies::GOOMY
      ary=[]
    when PBSpecies::KLEFKI
      ary=[]
    when PBSpecies::PHANTUMP
      ary=[]
    when PBSpecies::PUMPKABOO
      ary=[]
    when PBSpecies::BERGMITE
      ary=[]
    when PBSpecies::NOIBAT
      ary=[]
    when PBSpecies::DELTACHARMANDER
      ary=[]
    when PBSpecies::DELTABULBASAUR
      ary=[]
    when PBSpecies::DELTASQUIRTLE
      ary=[]
=end
    end
end
