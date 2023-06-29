=begin
                              PasswordGift v1.0
                               by FlipelyFlip

heyey,
this little snippet allows you to create a Password Gift part.
You enter a password and if the password is correct, you will
gain a pre-defined item.

To call the script you have only use the call-script event code
and enter this:

Scene_Gift.new(minlength, maxlength)

minlength = minimum of letters or symbols to enter (default 1)
maxlength = maximum of letters or symbols to enter (default 8)

To setup a password, it's important that you know, that you have to
put a PBItems:: before the item name or a PBSpecies:: before a pokemon name!
All items and Pokemons you will find in your PBS folder.

that's all you have to know in this snippet (:
=end

#=============================================================================
# Password Module
#-----------------------------------------------------------------------------
# Here you can define the Items you will gain for the different passwords
#=============================================================================
module Password

  # this is the hash to define
#  Gifts = { # <-- do not remove!!
  # "password" => [PBItems::Item_Name, Switch_ID, pokemon=false]
  # "password" => [PBSpecies::Pokemon_Name, Switch_ID, pokemon=true, Level]
#  "PASSWORD" => [PBItems::POTION, 198, false],
#  "GIOVANNI" => [PBItems::POTION, 198, false]
  # important!! if you add more passwords don't
  # forget the Komma until you reacht the last line
=begin
  "bACK2daFTr" => [PBItems::MILLENIUMENGINE2, 199, false],
  "1370pesterbot" => [PBSpecies::LATIOS, 201, true, 60],
  "682unkillable" => [PBSpecies::LATIAS, 202 , true, 60],
  "wOmeNiNhErit" => [PBItems::DINOTICKET, 203, false],
  "mADRiGal4" => [PBItems::MUSICTICKET, 204, false],
  "eVILmaN" => [PBItems::BLACKTICKET, 205, false],
  "BELLandBRASS" => [PBItems::TOWERPHOTOGRAPH, 206, false],
  "OR1G1NALmew" => [PBItems::EXTERMINATORLICENSE, 207, false],
    "GRAHAM.M.V" => [PBSpecies::MANAPHY, 211, true, 1],
  "REFROBATE" => [PBSpecies::KABUTO, 213, true, 5],
  "craPPYGift" => [PBItems::PIECEOFPAPER, 214, false],
  "protect" => [PBItems::TM17, 216, false],
  "brickbreak" => [PBItems::TM31, 215, false],
  "TrustMe;)" => [PBItems::MEDICALLICENSE, 217, false],
  "loldasscary" => [PBItems::BLACKTICKET2, 218, false],
=end

#  } # <-- do not remove!!
end  
