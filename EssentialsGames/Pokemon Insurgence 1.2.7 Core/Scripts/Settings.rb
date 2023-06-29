 #===============================================================================
 #===============================================================================
# * The maximum level Pokémon can reach.
# * The level of newly hatched Pokémon.
# * The odds of a newly generated Pokémon being shiny (out of 65536).
# * The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
#===============================================================================
MAXIMUMLEVEL       = 120
EGGINITIALLEVEL    = 1
SHINYPOKEMONCHANCE = 16
POKERUSCHANCE      = 3
$Bubble = 0

#===============================================================================
# * The default screen width (at a zoom of 1.0; size is half this at zoom 0.5).
# * The default screen height (at a zoom of 1.0).
# * The default screen zoom. (1.0 means each tile is 32x32 pixels, 0.5 means
#      each tile is 16x16 pixels.)
# * Map view mode (0=original, 1=custom, 2=perspective).
#===============================================================================
DEFAULTSCREENWIDTH  = 512
DEFAULTSCREENHEIGHT = 384
DEFAULTSCREENZOOM   = 1.0
MAPVIEWMODE         = 1
# To forbid the player from changing the screen size themselves, quote out or
# delete the relevant bit of code in the PokemonOptions script section.

#===============================================================================
# * Whether poisoned Pokémon will lose HP while walking around in the field.
# * Whether poisoned Pokémon will faint while walking around in the field
#      (true), or survive the poisoning with 1HP (false).
# * Whether fishing automatically hooks the Pokémon (if false, there is a
#      reaction test first).
# * Whether TMs can be used infinitely as in Gen 5 (true), or are one use only
#      as in older Gens (false).
# * Whether the player can surface from anywhere while diving (true), or only in
#      spots where they could dive down from above (false).
# * Whether a move's physical/special category depends on the move itself as in
#      newer Gens (true), or on its type as in older Gens (false).
# * Whether the Exp gained from beating a Pokémon should be scaled depending on
#      the gainer's level as in Gen 5 (true), or not as in older Gens (false).
#===============================================================================
POISONINFIELD         = true
POISONFAINTINFIELD    = false
FISHINGAUTOHOOK       = false
INFINITETMS           = true
DIVINGSURFACEANYWHERE = false
USEMOVECATEGORY       = true
USENEWEXPFORMULA      = true

#===============================================================================
# * Pairs of map IDs, where the location signpost isn't shown when moving from
#      one of the maps in a pair to the other (and vice versa).  Useful for
#      single long routes/towns that are spread over multiple maps.
# e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
#   Moving between two maps that have the exact same name won't show the
#      location signpost anyway, so you don't need to list those maps here.
#===============================================================================
NOSIGNPOSTS = []

#===============================================================================
# * Whether outdoor maps should be shaded according to the time of day.
#===============================================================================
ENABLESHADING = true

#===============================================================================
# * The minimum number of badges required to boost each stat of a player's
#      Pokémon by 1.1x, while using moves in battle only.
# * Whether the badge restriction on using certain hidden moves is either owning
#      at least a certain number of badges (true), or owning a particular badge
#      (false).
# * Depending on HIDDENMOVESCOUNTBADGES, either the number of badges required to
#      use each hidden move, or the specific badge number required to use each
#      move.  Remember that badge 0 is the first badge, badge 7 is the eighth
#      badge, etc.
# e.g. To require the second badge, put false and 1.
#      To require at least 2 badges, put true and 2.
#===============================================================================
BADGESBOOSTATTACK      = 2
BADGESBOOSTDEFENSE     = 3
BADGESBOOSTSPEED       = 5
BADGESBOOSTSPATK       = 7
BADGESBOOSTSPDEF       = 8
HIDDENMOVESCOUNTBADGES = true
BADGEFORSURF           = 1
BADGEFORCUT            = 3
BADGEFORFLASH          = 0
BADGEFORSTRENGTH       = 0
BADGEFORFLY            = 4
BADGEFORDIVE           = 5
BADGEFORWATERFALL      = 6
BADGEFORROCKSMASH      = 7
BADGEFORROCKCLIMB      = 9

MBLVAR = false

LEVELCAPS = [
  [57,17], #Tournament
  [59,19], #Ruin
  [4,25], #Orion
  [75,30], #Nora
  [5,35], #Xavier
  [131,45], #Taen
  [6,49], #East
  [390,53],  #Alpha
  [133,58], #Audrey
  [7,55], #Harmony
  [158,59], #Audrey
  [8,60], #Anastasia
  [142,62], #Taen
  [146,65], #Zenith
  [9,68], #Diana
  [152,70], #Taen
  
  
  [10,79], #Calreath
  [435,83], #Zenith
  [447,85], #Damian
  [11,87], #Adam
  [12,98], #E4
  [509,120]
  ] #POST 1.1 <-CHANGE THIS

#1 = HM = STRENGTH
#2 = ST = ATTACK
#3 = HM = CUT
#4 = HM = FLY
#5 = HM = SURF
#6 = HM = WATERFALL
#7 = HM = ROCK SMASH
#8 = HM = DIVE

#===============================================================================
# * The names of each pocket of the Bag.  Leave the first entry blank.
# * The maximum number of slots per pocket (-1 means infinite number).  Ignore
#      the first number (0).
# * The maximum number of items each slot in the Bag can hold.
# * Whether each pocket in turn auto-sorts itself by item ID number.  Ignore
#      the first entry (the 0).
# * The pocket number containing all berries.  Is opened when choosing one to
#      plant, and cannot view a different pocket while doing so.
# * The number of boxes in Pokémon storage.
#===============================================================================
def pbPocketNames; return ["",
   _INTL("Items"),
   _INTL("Medicine"),
   _INTL("Poké Balls"),
   _INTL("TMs & HMs"),
   _INTL("Berries"),
   _INTL("Mega Stones"),
   _INTL("Clothes"),
   _INTL("Key Items")
]; end
MAXPOCKETSIZE  = [0,-1,-1,-1,-1,-1,-1,-1,-1]
BAGMAXPERSLOT  = 999
POCKETAUTOSORT = [0,false,false,false,true,true,false,false,false]
BERRYPOCKET    = 5
STORAGEBOXES   = 24 

#===============================================================================
# * Whether the Pokédex list shown is the one for the player's current region
#      (true), or whether a menu pops up for the player to manually choose which
#      Dex list to view when appropriate (false).
# * The names of each Dex list in the game, in order and with National Dex on
#      the end.  This is also the order that $PokemonGlobal.pokedexUnlocked is
#      in, which records which Dexes have been unlocked (first is unlocked by
#      default).
#      Each entry can instead be an array like ["Kanto Pokédex",0], where the
#      name comes first followed by the region the list corresponds to (as
#      defined in "townmap.txt").  This is used to decide which region map to
#      show when looking at a species' nest from that Dex list (if not set,
#      shows the player's current region).
# * Whether all forms of a given species will be immediately available to view
#      in the Pokédex so long as that species has been seen at all (true), or
#      whether each form needs to be seen specifically before that form appears
#      in the Pokédex (false).
#===============================================================================
DEXDEPENDSONLOCATION = false
def pbDexNames; return [
     _INTL("National Pokédex")
  ]
end
ALWAYSSHOWALLFORMS = true

#===============================================================================
# * The amount of money the player starts the game with.
# * The maximum amount of money the player can have.
# * The maximum number of Game Corner coins the player can have.
#===============================================================================
INITIALMONEY = 3000
MAXMONEY     = 999999
MAXCOINS     = 99999

#===============================================================================
# * A set of arrays each containing a trainer type followed by a Global Variable
#      number.  If the variable isn't set to 0, then all trainers with the
#      associated trainer type will be named as whatever is in that variable.
#===============================================================================
RIVALNAMES = [
   [:POKEMONTRAINER_Brendan,12]
]

#===============================================================================
# * A list of maps used by roaming Pokémon.  Each map has an array of other maps
#      it can lead to.
# * A set of arrays each containing the details of a roaming Pokémon.  The
#      information within is as follows:
#      - Species.
#      - Level.
#      - Global Switch; the Pokémon roams while this is ON.
#      - Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
#           4=surfing/fishing).  See bottom of PokemonRoaming for lists.
#      - Name of BGM to play for that encounter (optional).
#      - Roaming areas specifically for this Pokémon (optional).
#===============================================================================
RoamingAreas = {
   5  => [21,28,31,39,41,44,47,66,69],
   21 => [5,28,31,39,41,44,47,66,69],
   28 => [5,21,31,39,41,44,47,66,69],
   31 => [5,21,28,39,41,44,47,66,69],
   39 => [5,21,28,31,41,44,47,66,69],
   41 => [5,21,28,31,39,44,47,66,69],
   44 => [5,21,28,31,39,41,47,66,69],
   47 => [5,21,28,31,39,41,44,66,69],
   66 => [5,21,28,31,39,41,44,47,69],
   69 => [5,21,28,31,39,41,44,47,66]
}
RoamingSpecies = [
   [:LATIAS, 30, 36, 0, "002-Battle02x"],
   [:LATIOS, 30, 36, 0, "002-Battle02x"],
   [:KYOGRE, 40, 37, 2, nil,{
       189  => [212,299],
       212 => [189,299,191],
       320 => [189,212,191],
       191 => [212,299] }],
   [:ENTEI, 40, 38, 1, nil]
]

#===============================================================================
# * A set of arrays each containing details of a graphic to be shown on the
#      region map if appropriate.  The values for each array are as follows:
#      - Region number.
#      - Global Switch; the graphic is shown if this is ON (non-wall maps only).
#      - X coordinate of the graphic on the map, in squares.
#      - Y coordinate of the graphic on the map, in squares.
#      - Name of the graphic, found in the Graphics/Pictures folder.
#      - The graphic will always (true) or never (false) be shown on a wall map.
#===============================================================================
REGIONMAPEXTRAS = [
#   [0,50,17,1,"mapHiddenDoxy",false],
#   [0,51,21,0,"mapHiddenFaraday",false],
#   [0,52,20,2,"mapHiddenFaraday",false]

]

#===============================================================================
# * The number of steps allowed before a Safari Zone game is over (0=infinite).
# * The number of seconds a Bug Catching Contest lasts for (0=infinite).
#===============================================================================
SAFARISTEPS    = 600
BUGCONTESTTIME = 1200

#===============================================================================
# * The Global Switch that is set to ON when the player whites out.
# * The Global Switch that is set to ON when the player has seen Pokérus in the
#      Poké Center, and doesn't need to be told about it again.
# * The ID of the common event that runs when the player starts fishing (runs
#      instead of showing the casting animation).
# * The ID of the common event that runs when the player stops fishing (runs
#      instead of showing the reeling in animation).
#===============================================================================
STARTING_OVER_SWITCH    = 1
SEEN_POKERUS_SWITCH     = 2
FISHINGBEGINCOMMONEVENT = -1
FISHINGENDCOMMONEVENT   = -1

#===============================================================================
# * The ID of the animation played when the player steps on grass (shows grass
#      rustling).
# * The ID of the animation played when a trainer notices the player (an
#      exclamation bubble).
#===============================================================================
GRASS_ANIMATION_ID       = 1
EXCLAMATION_ANIMATION_ID = 3

#===============================================================================
# * An array of available languages in the game, and their corresponding
#      message file in the Data folder.  Edit only if you have 2 or more
#      languages to choose from.
#===============================================================================
LANGUAGES = [  
 #["English","english5.dat"]
 # ["More languages to come!","english2.dat"]
]

#===========================f====================================================
# * Whether names can be typed using the keyboard (true) or chosen letter by
#      letter as in the official games (false).
#===============================================================================
USEKEYBOARDTEXTENTRY = true
#=========================================================
# ● Config Script For Your Game Here
# Change the emo_ to what ever number is the cell holding the animation
#=========================================================
Current_Following_Variable = 36
CommonEvent = 4
ItemWalk=26
Walking_Time_Variable = 27
V_Create = 84
Doom_Desire = 85
Hyperspace_Hole = 86
Heart_Swap = 87
Tesseract = 88
Relic_Song = 89
Seed_Flare = 90
HS_Disappear = 92
Animation_Come_Out = 93
Animation_Come_In = 94
Emo_Happy = 65
Emo_Normal = 4
Emo_Hate = 9
Emo_Poison= 7
Emo_sing= 13
Emo_exclaim= 3
Emo_love= 10
Emo_tired = 11
Emo_sleep = 12 
Emo_annyoyed = 8
Emo_sad = 6