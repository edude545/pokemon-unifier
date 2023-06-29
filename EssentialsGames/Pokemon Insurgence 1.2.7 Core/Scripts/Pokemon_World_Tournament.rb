#===============================================================================
# Pokemon World Tournament script created by Luka S.J.
# Please give credit when used
#===============================================================================
# Place the script above Main and you're ready to go. This script aims to 
# provide a full PWT experience for Essentials (minus the nice visual part).
# I've even gone a little further, and added some things not present in the
# official PWT.
# Call it in a script/even script as PokemonWorldTournament.new
#
#===============================================================================
# Settings
#===============================================================================
# Here you can configure the various aspects of the system.
# Trainers should be defined through the editor, or the PBS file, but should be
# linked/called here just the same way you would in a normal trainer event
#
# This is a list of the types of battles available
# Make sure that World Leaders is in the list after all the other Gym Leader
# Tournament branches.
  BATTLE_LIST = [
                  "School Trainers",
                  "Challenge Championships",
                  "Kanto Leaders",
                  "Johto Leaders",
                  "Hoenn Leaders",
                  "Sinnoh Leaders",
                  "Unova Leaders",
                  "World Leaders",
                  "World Champions",
                  "World Champions",
                  "Rental Masters", # not yet implemented
                  "Mix Master" # not yet implemented
                ]
# This is a list of the Pokemon that cannot be used in the PWT                
  BAN_LIST = [
              PBSpecies::MEWTWO,
              PBSpecies::MEW,
              PBSpecies::HOOH,
              PBSpecies::LUGIA,
              PBSpecies::CELEBI,
              PBSpecies::KYOGRE,
              PBSpecies::GROUDON,
              PBSpecies::RAYQUAZA,
              PBSpecies::JIRACHI,
              PBSpecies::DEOXYS,
              PBSpecies::DIALGA,
              PBSpecies::PALKIA,
              PBSpecies::GIRATINA,
              PBSpecies::PHIONE,
              PBSpecies::MANAPHY,
              PBSpecies::DARKRAI,
              PBSpecies::SHAYMIN,
              PBSpecies::ARCEUS,
              PBSpecies::VICTINI,
              PBSpecies::ZEKROM,
              PBSpecies::RESHIRAM,
              PBSpecies::KYUREM,
              PBSpecies::KELDEO,
              PBSpecies::MELOETTA,
              PBSpecies::GENESECT,
              PBSpecies::XERNEAS,
              PBSpecies::YVELTAL,
              PBSpecies::ZYGARDE,
              PBSpecies::DIANCIE,
              PBSpecies::VOLCANION,
              PBSpecies::HOOPA,
              PBSpecies::DELTAMELOETTA,
              PBSpecies::DELTAHOOPA,
              PBSpecies::UFI,
            ]
  
# This is the list of all the defined trainers
# Trainers are defined as arrays containing:
# [ trainer type , trainer name , player victory speech , player loss speech , region they are from , City/Town they are from , Sprite image name (this can be left blank, and the sprite will be used as Leader_Name) ]
#
# The index of the trainer list has to correspond with the category type.
# If you're creating your own trainer list, make sure it has at least 8 entries, otherwise it won't work.
  TRAINER_LIST = [
                    [
                    [PBTrainers::NINJABOY,"Kyle","What? No fair! You can't beat a ninja!","Ah-hah! The ninja arts prevailed after all!","Torren","Midna Town"],
                    [PBTrainers::PRESCHOOLER_M,"Thomas","What? Impossible!","Ahah! You've been outsmarted by me!","Torren","Midna Town"],
                    [PBTrainers::TUBER_M,"Toby","I guess I lost...","Wow! I won!","Torren","Midna Town"],
                    [PBTrainers::RIVAL1,"Damian","You completely shut me down!","I completely shut you down!","Torren","Telnor Town"],
                    [PBTrainers::PRESCHOOLER_F,"Tamara","I have to study harder next time!","Yes! I knew those lessons would pay off!","Torren","Midna Town"],
                    [PBTrainers::RIVAL_NORA,"Nora","I couldn't win... \nIs it possible there's a better trainer than me?","I knew it! I knew I was the better trainer!","Torren","Midna Town"],
                    [PBTrainers::CAMPER,"Simon","I think I learned a lot from this battle!","If you learned something from this battle, then you should consider it a victory!","Torren","Midna Town"],
                    [PBTrainers::PICNICKER,"Daniella","Next time, I'm sure to win!","Practice hard, and you'll beat me next time!","Torren","Midna Town"],
                    [PBTrainers::YOUNGSTER,"Sean","Hmph! You must have cheated!","W-wow! I... I actually won!","Torren","Midna Town,"]
                    ],
                  #-------------------------------------------------------------
                  # List of all the trainers for the Kanto Leaders Tournament
                  [
                    [PBTrainers::Challenge_Brock,"Brock","Looks like you were the sturdier of us.","My barrier was tough to break. Maybe next time.","Kanto","Pewter City"],
                    [PBTrainers::Challenge_Misty,"Misty","You are a skilled Trainer, I have to admit that.","Looks like out of the two of us, I was the better Trainer.","Kanto","Cerulean City"],
                    [PBTrainers::Challenge_Surge,"Lt. Surge","You shocked me to my very core, soldier!","At ease son, not everyone can beat me.","Kanto","Vermillion City"],
                    [PBTrainers::Challenge_Erika,"Erika","Oh my! \n Looks like I've underestimated you.","Keep practicing hard, and one day you will be the victor.","Kanto","Celadon City"],                    
                    [PBTrainers::Challenge_Sabrina,"Sabrina","Impossible! I did not predict this!","The outcome was just as I predicted.","Kanto","Saffron City"],
                    [PBTrainers::Challenge_Janine,"Janine","You've got a great battle technique!","My technique was the superior one!","Kanto","Fuchsia City"],
                    [PBTrainers::Challenge_Blaine,"Blaine","Your flame burnt me up!","My flames are not something everyone can handle.","Kanto","Cinnabar Island"],                  
                    [PBTrainers::Challenge_Giovanni,"Giovanni","What? \nMe, lose?!","I could have never lost to a kid like you!","Kanto","Viridian City"], 
                    [PBTrainers::Challenge_Orion,"Orion","Aw, man...","Good game!","Torren","Suntouched City"],
                    [PBTrainers::Challenge_Xavier,"Xavier","Whoa, not bad!","I'm always serious about battling!","Torren","Vipik City"],
                    [PBTrainers::Challenge_East,"East","Splendid.","I'm sure this was just a fluke.","Torren","Helios City"],
                    [PBTrainers::Challenge_Harmony,"Harmony","You did it! Great job!","I've been waiting for this moment!","Torren","Sonata City"],                    
                    [PBTrainers::Challenge_Anastasia,"Anastasia","I thought I'd made progress but my displacement is still zero...","Don't feel bad, absolute zero is cool too!","Torren","Kepler City"],
                    [PBTrainers::Challenge_Falkner,"Falkner","I understand... I'll bow out gracefully.","My birds and I will always fly!","Johto","Violet City"],
                    [PBTrainers::Challenge_Bugsy,"Bugsy","Aw, that's the end of it...","My tough Bug Pokemon cannot be defeated easily.","Johto","Azalea Town"],
                    [PBTrainers::Challenge_Whitney,"Whitney","Ugh...","You really are strong! But I won't lose to you!","Johto","Goldenrod City"],                   
                    [PBTrainers::Challenge_Morty,"Morty","How is this possible...","We've got more discipline than anyone else!","Johto","Ecruteak City"],
                    [PBTrainers::Challenge_Chuck,"Chuck","We...lost...","No... Not...yet...","Johto","Cianwood City"],
                    [PBTrainers::Challenge_Jasmine,"Jasmine","Well done...","Steel will hang on to the very last!","Johto","Olivine City"],
                    [PBTrainers::Challenge_Pryce,"Pryce","Hmm. Seems as if my luck has run out.","My luck has not run out just yet.","Johto","Mahogany Town"],
                    [PBTrainers::Challenge_Clair,"Clair","I lost... I don't believe it. There must be some mistake...","I was destined to win! I had already decided that!","Johto","Blackthorn City"],
                    [PBTrainers::Challenge_Roxanne,"Roxanne","So... I lost...","I learned many things from our battle.","Hoenn","Rustboro City"],
                    [PBTrainers::Challenge_Brawly,"Brawly","Whoa, wow! You made a much bigger splash than I expected!","All right! I rode the big wave!","Hoenn","Dewford Town"],                    
                    [PBTrainers::Challenge_Wattson,"Wattson","Wahahahah! Fine, I lost! You ended up giving me a thrill!","Wahahahah! Well, I won! How was the battle? Thrilling, right?","Hoenn","Mauville City"],                   
                    [PBTrainers::Challenge_Flannery,"Flannery","Oh... I guess I was trying too hard...","I... I won! I guess my well-honed moves worked!","Hoenn","Lavaridge Town"],
                    [PBTrainers::Challenge_Norman,"Norman","... I... I can't... I can't believe it. I lost to you?","We both gave everything we had. That was a wonderful match.","Hoenn","Petalburg City"],
                    [PBTrainers::Challenge_Winona,"Winona","A Trainer that commands Pokémon with more grace than I...","Our elegant dance is finished!","Hoenn","Fortree City"],      
                    [PBTrainers::Challenge_TateLisa,"Tate&Liza","Oh! The combination of me and my Pokémon...","The combination of me and my Pokémon was superior!","Hoenn","Mossdeep City"],                    
                    [PBTrainers::Challenge_Juan,"Juan","Ahahaha, excellent! Very well, you are the winner.","Ahahaha, I'm the winner! Which is to say, you lost.","Hoenn","Sootopolis City"],
                    [PBTrainers::Challenge_Roark,"Roark","W-what? That can't be! My buffed-up Pokémon!","No way I would have lost to you!","Sinnoh","Oreburgh City"],
                    [PBTrainers::Challenge_Gardenia,"Gardenia","Amazing! You're very good, aren't you?","You did not have me concerned at all.","Sinnoh","Eterna City"],
                    [PBTrainers::Challenge_Fantina,"Fantina","You are so fantastically strong. I know now why I have lost.","Never give up, never surrender!","Sinnoh","Hearthome City"],                  
                    [PBTrainers::Challenge_Maylene,"Maylene","I shall admit defeat... You are much too strong.","I take battling very seriously.","Sinnoh","Veilstone City"],
                    [PBTrainers::Challenge_Wake,"Wake","Hunwah! It's gone and ended! How will I say... I want more! I wanted to battle a lot more!","I had a great time battling with you!","Sinnoh","Solaceon"],
                    [PBTrainers::Challenge_Byron,"Byron","Hmm! My sturdy Pokémon, defeated!","Though you may lost today, the road of a great Trainer still lies ahead of you.","Sinnoh","Canalave City"],                          
                    [PBTrainers::Challenge_Candice,"Candice","I must say, I've warmed up to you! I might even admire you a little.","I'm tough because I know how to focus. It's all about focus!","Sinnoh","Snowpoint City"],                      
                    [PBTrainers::Challenge_Volkner,"Volkner","You've got me beat... Your desire and the noble way your Pokémon battled for you... I even felt thrilled during our match. That was a very good battle.","You guys are tough! But we surpass your toughness!","Sinnoh","Sunyshore City"],
                    [PBTrainers::Challenge_Cilan,"Cilan","Huh? Is it over?","Huh? Did I win?","Unova","Striaton City"],
                    [PBTrainers::Challenge_Cress,"Cress","Lose? Me? I don't believe this.","This is the appropriate result when I'm your opponent.","Unova","Striaton City"],
                    [PBTrainers::Challenge_Chili,"Chili","You got me. I am...burned...out...","I'm on fire! Play with me, and you'll get burned!","Unova","Striaton City"],                   
                    [PBTrainers::Challenge_Lenora,"Lenora","You're impressive! And quite charming, aren't you?!","What's wrong? Could it be you misread what moves I was going to use?","Unova","Nacrene City"],
                    [PBTrainers::Challenge_Roxie,"Roxie","Wait! I was right in the middle of the chorus!","Looks like I knocked some sense outta ya!","Unova","Virbank City"],
                    [PBTrainers::Challenge_Burgh,"Burgh","Is it over? Has my muse abandoned me?"," bug Pokémon are scurrying with excitement of battling!","Unova","Castelia City"],
                    [PBTrainers::Challenge_Elesa,"Elesa","I meant to make your head spin, but you shocked me instead.","My Pokemon shined brilliantly!","Unova","Nimbasa City"],
                    [PBTrainers::Challenge_Clay,"Clay","Well, I've had enough... and just so you know, I didn't go easy on you.","Sorry, I didn't go easy on you.","Unova","Driftveil City"],
                    [PBTrainers::Challenge_Skyla,"Skyla","Being your opponent in battle is a new source of strength to me. Thank you!","Next time, why don't you try something else?","Unova","Mistralton City"],
                    [PBTrainers::Challenge_Brycen,"Brycen","The wonderful combination of you and your Pokémon! What a beautiful friendship!","Extreme conditions really test you and train you!","Unova","Icirrus City"],
                    [PBTrainers::Challenge_Drayden,"Drayden","This intense feeling that floods me after a defeat... I don't know how to describe it.","I'm grateful we had a chance to meet and battle.","Unova","Opelucid City"],
                    [PBTrainers::Challenge_Eduard,"Eduard","Well I'll be!","Not this time!","Torren","Roggan Town"],                  
                    [PBTrainers::Challenge_Yuki,"Yuki","Your skills are marvelous, as usual.","Oh dear, it appears you slipped up this time.","Torren","Sonata City"],
                    [PBTrainers::Challenge_London,"London","It would seem that I am still no match for you.","Oh? Well this is certainly a surprise.","Torren","Nexa Town"],                    
                    [PBTrainers::Challenge_Lorelei,"Lorelei","...Things shouldn't be this way!","You're better than I thought. But I'm still stronger!","Kanto","Indigo Plateau"],
                    [PBTrainers::Challenge_Bruno,"Bruno","Why?! ...How could we lose?","You can challenge me all you like, but the results will never change!","Kanto","Indigo Plateau"],
                    [PBTrainers::Challenge_Agatha,"Agatha","Oh, my! You're something special, child!","That is how a real Trainer battles!","Kanto","Indigo Plateau"],                    
                    [PBTrainers::Challenge_Will,"Will","I... I can't...believe it...","Sorry about that, but I'm shooting for the top myself.","Kanto","Indigo Plateau"],
                    [PBTrainers::Challenge_Koga,"Koga","Ah! You've proven your worth!","Have you learned to fear the techniques of the ninja?","Kanto","Indigo Plateau"],
                    [PBTrainers::Challenge_Karen,"Karen","Well, aren't you good. I like that in a Trainer.","That's about what I expected.","Kanto","Indigo Plateau"],                  
                    [PBTrainers::Challenge_Sidney,"Sidney","Well, how do you like that? I lost! Eh, it was fun, so it doesn't matter.","No hard feelings!","Hoenn","Evergrande City"],                    
                    [PBTrainers::Challenge_Phoebe,"Phoebe","Oh, darn. I've gone and lost.","Hmmp, what a shame.","Hoenn","Evergrande City"],
                    [PBTrainers::Challenge_Glacia,"Glacia","You and your Pokémon... How hot your spirits burn!","I hope you have learned how fearsome the Hoenn Pokémon League can truly be!","Hoenn","Evergrande City"],
                    [PBTrainers::Challenge_Drake,"Drake","Superb, it should be said.","For us to battle alongside Pokemon as partners, do you know what it takes? If you don't, you will never prevail over me!","Hoenn","Evergrande City"],
                    [PBTrainers::Challenge_Aaron,"Aaron","I will now concede defeat. But I think you came to see how great Bug-type Pokémon can be.","Battling is a deep and complex affair...","Sinnoh","Pokemon League"],                    
                    [PBTrainers::Challenge_Bertha,"Bertha","Well! Dear child, I must say, that was most impressive","Dear child, don't assume for an instant that you've won.","Sinnoh","Pokemon League"],
                    [PBTrainers::Challenge_Flint,"Flint","...! I don't believe it! I lost! I didn't take you for granted. But I didn't expect you to win!","Battles aren't about appearances or what's weak or strong. It all comes down to whether the combatants can burn hot or not.","Sinnoh","Pokemon League City"],
                    [PBTrainers::Challenge_Lucian,"Lucian","I see. Your power is real.","Hmm... Now what should I do...","Sinnoh","Pokemon League"],
                    [PBTrainers::Challenge_Shauntal,"Shauntal","My feeling is you're a great Trainer!","Oh! It's not your fault! This is how battles always are","Unova","Pokemon League"],                    
                    [PBTrainers::Challenge_Grimsley,"Grimsley","Victory shines like a bright light. And right now, you and your Pokémon are shining brilliantly.","If you're a true Pokémon battler, you'll reflect upon your loss and think about how to win next time!","Unova","Pokemon League"],
                    [PBTrainers::Challenge_Marshal,"Marshal","Whew! Well done! As your battles continue, aim for even greater heights!","There is no single strongest Pokémon or sole best combination... That's why it is difficult to keep winning.","Unova","Pokemon League City"],
                    [PBTrainers::Challenge_Caitlin,"Caitlin","You and your Pokémon are both excellent and elegant.","My Pokémon and I learned a lot! I offer you my thanks.","Unova","Pokemon League"],                    
                    [PBTrainers::Challenge_Blue,"Blue","So this is the standard over here...","Just as I expected! We were too much for you!","Kanto","Indigo Plateau"],                    
                    [PBTrainers::Challenge_Lance,"Lance","...It's over. But it's an odd feeling. I'm not angry that I lost. In fact, I feel happy.","I never give up, no matter what. You must be the same?","Johto","Indigo Plateau"],
                    [PBTrainers::Challenge_Wallace,"Wallace","I, the Hoenn Champion, fall in defeat... That was wonderful work.","The Pokémon you sent into battle...at times they were strong, at times they were weak. One day you will overcome your weakness.","Hoenn","Evergrande City"],
                    [PBTrainers::Challenge_Iris,"Iris","Aghhhh... I did my best, but we lost...","Hah! I knew that we could win!","Unova","Pokemon League"],
                    [PBTrainers::Challenge_Alder,"Alder","Well done! You certainly are an unmatched talent!","Use the battle with me as a stepping stone and move forward!","Unova","Pokemon League"]               
                  ],
#                    [PBTrainers::Challenge_Cynthia,"Cynthia","It seems that you are the most powerful Trainer.","For now, you're just a powerful challenger.","Sinnoh","Pokemon League"],                 
#                    [PBTrainers::Challenge_Red,"Red","...\n...","...\n...","Kanto","Mt. Silver"],
#                    [PBTrainers::Challenge_Steven,"Steven","I, the Champion, fall in defeat... Kudos to you, \PN! You are a truly noble Pokemon Trainer!","You might not have won today, but that does not make you a weak Trainer.","Hoenn","Evergrande City"]   
                  #-
                  [
                  # List of all the trainers for the Kanto Leaders Tournament
                    [PBTrainers::LEADER_0,"Brock","Looks like you were the sturdier of us.","My barrier was tough to break. Maybe next time.","Kanto","Pewter City"],
                    [PBTrainers::LEADER_1,"Misty","You are a skilled Trainer, I have to admit that.","Looks like out of the two of us, I was the better Trainer.","Kanto","Cerulean City"],
                    [PBTrainers::LEADER_2,"Lt.Surge","You shocked me to my very core, soldier!","At ease son, not everyone can beat me.","Kanto","Vermillion City"],
                    [PBTrainers::LEADER_3,"Erika","Oh my! \n Looks like I've underestimated you.","Keep practicing hard, and one day you will be the victor.","Kanto","Celadon City"],
                    [PBTrainers::LEADER_4,"Sabrina","Impossible! I did not predict this!","The outcome was just as I predicted.","Kanto","Saffron City"],
                    [PBTrainers::LEADER_5,"Janine","You've got a great battle technique!","My technique was the superior one!","Kanto","Fuchsia City"],
                    [PBTrainers::LEADER_6,"Blaine","Your flame burnt me up!","My flames are not something everyone can handle.","Kanto","Cinnabar Island"],
                    [PBTrainers::LEADER_7,"Giovanni","What? \nMe, lose?!","I could have never lost to a kid like you!","Kanto","Viridian City"]
                  ],
                  #-------------------------------------------------------------
                  #-------------------------------------------------------------
                  [
                  # List of all the trainers for the Johto Leaders Tournament
                    [PBTrainers::LEADER_8,"Falkner","I understand... I'll bow out gracefully.","My birds and I will always fly!","Johto","Violet City"],
                    [PBTrainers::LEADER_9,"Bugsy","Aw, that's the end of it...","My tough Bug Pokemon cannot be defeated easily.","Johto","Azlea Town"],
                    [PBTrainers::LEADER_10,"Whitney","Ugh...","You really are strong! But I won't lose to you!","Johto","Goldenrod City"],
                    [PBTrainers::LEADER_11,"Morty","How is this possible...","We've got more discipline than anyone else!","Johto","Ecruteak City"],
                    [PBTrainers::LEADER_12,"Chuck","We...lost...","No... Not...yet...","Johto","Cianwood City"],
                    [PBTrainers::LEADER_13,"Jasmine","Well done...","Steel will hang on to the very last!","Johto","Olivine City"],
                    [PBTrainers::LEADER_14,"Pryce","Hmm. Seems as if my luck has run out.","My luck has not run out just yet.","Johto","Mahogany Town"],
                    [PBTrainers::LEADER_15,"Clair","I lost... I don't believe it. There must be some mistake...","I was destined to win! I had already decided that!","Johto","Blackthorn City"]
                  ],
                  #-------------------------------------------------------------
                  #-------------------------------------------------------------
                  [
                  # List of all the trainers for the Hoenn Leaders Tournament
                    [PBTrainers::LEADER_16,"Roxanne","So... I lost...","I learned many things from our battle.","Hoenn","Rustboro City"],
                    [PBTrainers::LEADER_17,"Brawly","Whoa, wow! You made a much bigger splash than I expected!","All right! I rode the big wave!","Hoenn","Dewford Town"],
                    [PBTrainers::LEADER_18,"Wattson","Wahahahah! Fine, I lost! You ended up giving me a thrill!","Wahahahah! Well, I won! How was the battle? Thrilling, right?","Hoenn","Mauville City"],
                    [PBTrainers::LEADER_19,"Flannery","Oh... I guess I was trying too hard...","I... I won! I guess my well-honed moves worked!","Hoenn","Lavaridge Town"],
                    [PBTrainers::LEADER_20,"Norman","... I... I can't... I can't believe it. I lost to you?","We both gave everything we had. That was a wonderful match.","Hoenn","Petalburg City"],
                    [PBTrainers::LEADER_21,"Winona","A Trainer that commands Pokémon with more grace than I...","Our elegant dance is finished!","Hoenn","Fortree City"],
                    [PBTrainers::LEADER_22,"Tate&Liza","Oh! The combination of me and my Pokémon...","The combination of me and my Pokémon was superior!","Hoenn","Mossdeep City"],
                    [PBTrainers::LEADER_24,"Juan","Ahahaha, excellent! Very well, you are the winner.","Ahahaha, I'm the winner! Which is to say, you lost.","Hoenn","Sootopolis City"]
                  ],
                  #-------------------------------------------------------------
                  #-------------------------------------------------------------
                  [
                  # List of all the trainers for the Sinnoh Leaders Tournament
                    [PBTrainers::LEADER_25,"Roark","W-what? That can't be! My buffed-up Pokémon!","No way I would have lost to you!","Sinnoh","Oreburgh City"],
                    [PBTrainers::LEADER_26,"Gardenia","Amazing! You're very good, aren't you?","You did not have me concerned at all.","Sinnoh","Eterna City"],
                    [PBTrainers::LEADER_27,"Fantina","You are so fantastically strong. I know now why I have lost.","Never give up, never surrender!","Sinnoh","Hearthome City"],
                    [PBTrainers::LEADER_28,"Mayleene","I shall admit defeat... You are much too strong.","I take battling very seriously.","Sinnoh","Veilstone City"],
                    [PBTrainers::LEADER_29,"Wake","Hunwah! It's gone and ended! How will I say... I want more! I wanted to battle a lot more!","I had a great time battling with you!","Sinnoh","Solaceon"],
                    [PBTrainers::LEADER_30,"Byron","Hmm! My sturdy Pokémon, defeated!","Though you may lost today, the road of a great Trainer still lies ahead of you.","Sinnoh","Canalave City"],
                    [PBTrainers::LEADER_31,"Candice","I must say, I've warmed up to you! I might even admire you a little.","I'm tough because I know how to focus. It's all about focus!","Sinnoh","Snowpoint City"],
                    [PBTrainers::LEADER_32,"Volkner","You've got me beat... Your desire and the noble way your Pokémon battled for you... I even felt thrilled during our match. That was a very good battle.","You guys are tough! But we surpass your toughness!","Sinnoh","Sunyshore City"]
                  ],
                  #-------------------------------------------------------------
                  #-------------------------------------------------------------
                  [
                  # List of all the trainers for the Unova Leaders Tournament
                    [PBTrainers::LEADER_33,"Cheren","This! This is what a real Pokémon battle is!","You were a powerful opponent, there is no denying that.","Unova","Aspertia City"],
                    [PBTrainers::LEADER_34,"Roxie","Wait! I was right in the middle of the chorus!","Looks like I knocked some sense outta ya!","Unova","Virbank City"],
                    [PBTrainers::LEADER_35,"Burgh","Is it over? Has my muse abandoned me?"," bug Pokémon are scurrying with excitement of battling!","Unova","Castelia City"],
                    [PBTrainers::LEADER_36,"Elesa","I meant to make your head spin, but you shocked me instead.","My Pokemon shined brilliantly!","Unova","Nimbasa City"],
                    [PBTrainers::LEADER_37,"Clay","Well, I've had enough... and just so you know, I didn't go easy on you.","Sorry, I didn't go easy on you.","Unova","Driftveil City"],
                    [PBTrainers::LEADER_38,"Skyla","Being your opponent in battle is a new source of strength to me. Thank you!","Next time, why don't you try something else?","Unova","Mistralton City"],
                    [PBTrainers::LEADER_39,"Drayden","This intense feeling that floods me after a defeat... I don't know how to describe it.","I'm grateful we had a chance to meet and battle.","Unova","Opelucid City"],
                    [PBTrainers::LEADER_40,"Marlon","You totally rocked that! You're raising some wicked Pokémon. You got this Trainer thing down!","Fightin' you felt real good, so I kept goin' and goin'.","Unova","Humilau City"]
                  ],
=begin
                [
                  # List of all the trainers for the Unova Leaders Tournament
                    [PBTrainers::LEADER_41,"Viola","Let me take a photo of this moment! A great battle, indeed!","The battle came down to a photo finish, but I pulled through in the end!","Kalos","Santalune City"],
                    [PBTrainers::LEADER_42,"Grant","You're the only wall I am unable to surmount!","Don't give up! Even though I've beaten you today, there's always next time.","Kalos","Cyllage City"],
                    [PBTrainers::LEADER_43,"Korrina","You share such a close bond with your Pokemon!","Great battle! I hope you come back so we can battle again!","Kalos","Shalour City"],
                    [PBTrainers::LEADER_44,"Ramos","Yeh believe in yer Pokemon, and they believe in yeh too.","A true friendship with Pokemon takes time! \nSpend more time with your Pokemon!","Kalos","Coumarine City"],
                    [PBTrainers::LEADER_45,"Clemont","Your passion for battle inspires me!","Now you see the power of the Trainer-Grow-Stronger Machine v2!","Kalos","Lumiose City"],
                    [PBTrainers::LEADER_46,"Valerie","That was truly a captivating battle!","Oh goodness, what a pity...","Kalos","Laverre City"],
                    [PBTrainers::LEADER_47,"Olympia","Create your own path. \nLet nothing get in your way. \nYour fate, your future.","Winner and a loser. A winged Pokemon leads on, to the goal of both.","Kalos","Anistar City"],
                    [PBTrainers::LEADER_48,"Wulfric","Outstanding! I'm as tough as an iceberg, but you've smashed me!","Your Pokemon put all their effort into this battle. You should be proud of yourself","Kalos","Snowbelle City"]
                  ],
=end
                  #-------------------------------------------------------------
                  # Generates the list for the World Leaders Tournament
                  [ "slot reserved for World Leaders Tournament" ],
                  #-------------------------------------------------------------
                  #-------------------------------------------------------------
                  [
                  # List of all the trainers for the World Champions Tournament
                    [PBTrainers::CHAMPION_0,"Blue","So this is the standard over here...","Just as I expected! We were too much for you!","Kanto","Indigo Plateau"],
                    [PBTrainers::CHAMPION_1,"Lance","…It’s over. But it’s an odd feeling. I’m not angry that I lost. In fact, I feel happy.","I never give up, no matter what. You must be the same?","Johto","Indigo Plateau"],
                    [PBTrainers::CHAMPION_2,"Wallace","I, the Champion, fall in defeat... That was wonderful work.","The Pokémon you sent into battle...at times they were strong, at times they were weak. One day you will overcome your weakness.","Hoenn","Evergrande City"],
                    [PBTrainers::CHAMPION_3,"Cynthia","It seems that you are the most powerful Trainer.","For now, you're just a powerful challenger.","Sinnoh","Pokemon League"],
                    [PBTrainers::CHAMPION_4,"Iris","Aghhhh... I did my best, but we lost...","Hah! I knew that we could win!","Unova","Pokemon League"],
                    [PBTrainers::CHAMPION_5,"Alder","Well done! You certainly are an unmatched talent!","Use the battle with me as a stepping stone and move forward!","Unova","Pokemon League"],
                    [PBTrainers::CHAMPION_6,"Red","...\n...","...\n...","Kanto","Mt. Silver"],
                    [PBTrainers::CHAMPION_7,"Steven","I, the Champion, fall in defeat... Kudos to you, \PN! You are a truly noble Pokemon Trainer!","You might not have won today, but that does not make you a weak Trainer.","Hoenn","Evergrande City"]
                  ],
                  #-------------------------------------------------------------
                  # Generates the list for the Rental Masters Tournament
                  [ "slot reserved for Rental Masters Tournament" ],
                  #-------------------------------------------------------------
                  #-------------------------------------------------------------
                  # Generates the list for the Mix Masters Tournament
                  [ "slot reserved for Mix Masters Tournament" ]
                  #-------------------------------------------------------------
                ]
#===============================================================================

class PokemonWorldTournament
  
# Starts up the PWT system and generates missing trainer categories  
  def initialize(isschool=false,announce=false)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=9999
    @sprites["scoreboard"]=Sprite.new(@viewport)
    @sprites["scoreboard"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["scoreboard"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
    @sprites["scoreboard"].opacity=0
    
    $Trainer.battle_points=0 if !$Trainer.battle_points
    if !$Trainer.pwt_wins or $Trainer.pwt_wins.length<BATTLE_LIST.length
      $Trainer.pwt_wins=[]
      for i in 0...BATTLE_LIST.length
        $Trainer.pwt_wins.push(0)
      end
    end
        
    @current_party = Marshal.load(Marshal.dump($Trainer.party))
    
    self.generateWorldLeaders if BATTLE_LIST.include?("World Leaders")
    self.generateRentalMasters if BATTLE_LIST.include?("Rental Masters")
    self.generateMixMasters if BATTLE_LIST.include?("Mix Masters")
    
    self.introduction if !isschool
    @tournament_type = chooseTournament(isschool)
    return cancelEntry if !@tournament_type
    @battle_type = chooseBattle if !isschool
    @battle_type= 0  if isschool
    return cancelEntry if !@battle_type
    @modified_party = choosePokemon(isschool)
    @party_items=[]
    if @modified_party!="notEligible" && @modified_party
      for i in 0...@modified_party.length
        @party_items[i]=@modified_party[i].item
      end
    end
    
    if @modified_party=="notEligible"
      Kernel.pbMessage(_INTL("We're terribly sorry, but your Pokemon are not eligible for the Tournament."))
      Kernel.pbMessage(_INTL(showBanList))
      Kernel.pbMessage(_INTL("Please come back once your Pokemon Party has been adjusted."))
    elsif !@modified_party
      cancelEntry
    else
      #5000.times do
        self.generateRounds(isschool)
      #end
      ret=self.startTournament(announce,isschool)
      for pokemon in $Trainer.party
        for i in 0...@current_party.length
          if !pokemon.is_a?(String) && @current_party[i].personalID==pokemon.personalID
            @current_party[i].hp=pokemon.hp
          end
        end
      end
    end
    
    @sprites["scoreboard"].bitmap.clear
    @sprites["scoreboard"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
    15.times do
      @sprites["scoreboard"].opacity-=17
      pbWait(1)
    end
    case ret
    when "win"
      if !isschool
     # Kernel.pbMessage(_INTL("Congratulations on today's win."))
     # Kernel.pbMessage(_INTL("For your victory you have earned 3 BP."))
     # Kernel.pbMessage(_INTL("We hope to see you again."))
      $Trainer.pwt_wins[@tournament_type]+=1
      $Trainer.battle_points+=3
      end
    when "loss"
#      Kernel.pbMessage(_INTL("I'm sorry that you lost this tournament."))
#      Kernel.pbMessage(_INTL("Maybe you'll have better luck next time."))
      cancelEntry
    end
    $Trainer.party = @current_party
    $game_variables[1]=1
    $game_variables[1]=5 if ret == "win"
   # return true if ret == "win"
   # Kernel.pbMessage("nein")
   # return false
  end
    
# The function used to generate the World Leaders Tournament trainers
  def generateWorldLeaders
    index = BATTLE_LIST.index("Worlders")
    return false if index.nil?
    full_list = []
    for i in 0...index
      for j in 0...TRAINER_LIST[i].length
        full_list.push(TRAINER_LIST[i][j])
      end
    end
    trainers = []
    
    loop do
      n = rand(full_list.length)
      trainer = full_list[n]
      full_list.delete_at(n)
      trainers.push(trainer)
      break if trainers.length>7
    end
          
    TRAINER_LIST[index] = trainers
  end  
  
# The function used to generate the RentalMasters Tournament trainers
  def generateRentalMasters
    index = BATTLE_LIST.index("Rentalers")
    return false if index.nil?
    full_list = []
    for i in 0...index
      if i!=BATTLE_LIST.index("Worlders")
        for j in 0...TRAINER_LIST[i].length
          full_list.push(TRAINER_LIST[i][j])
        end
      end
    end
    trainers = []
    
    loop do
      n = rand(full_list.length)
      trainer = full_list[n]
      full_list.delete_at(n)
      trainers.push(trainer)
      break if trainers.length>7
    end
          
    TRAINER_LIST[index] = trainers
  end  
  
# The function used to generate the RentalMasters Tournament trainers
  def generateMixMasters
    index = BATTLE_LIST.index("Mixer")
    return false if index.nil?
    full_list = []
    for i in 0...index
      if i!=BATTLE_LIST.index("Worlders") or i!=BATTLE_LIST.index("Rentalers")
        for j in 0...TRAINER_LIST[i].length
          full_list.push(TRAINER_LIST[i][j])
        end
      end
    end
    trainers = []
    
    loop do
      n = rand(full_list.length)
      trainer = full_list[n]
      full_list.delete_at(n)
      trainers.push(trainer)
      break if trainers.length>7
    end
          
    TRAINER_LIST[index] = trainers
  end  
 
# Creates a small introductory conversation
  def introduction
    Kernel.pbMessage(_INTL("Hello, and welcome to the Pokemon World Tournament!"))
    Kernel.pbMessage(_INTL("The place where the strongest gather to compete."))
  end
  
  def announceContest(trainer,i)
    n=rand(4)
    if i==7
      Kernel.pbMessage(_INTL("Announcer: Last but not least, joining us is our very own #{$Trainer.name}!")) if (@player_index==i)
      Kernel.pbMessage(_INTL("Announcer: Last but not least, joining our stadium is #{trainer[1]} from #{trainer[5]}, #{trainer[4]}!")) if !(@player_index==i)
      return true
    end
    case n
    when 0
      Kernel.pbMessage(_INTL("Announcer: Our local youth has talent too, please join me in welcoming #{$Trainer.name}!")) if (@player_index==i)
      Kernel.pbMessage(_INTL("Announcer: Visiting us all the way from #{trainer[5]}, #{trainer[4]}, is #{trainer[1]}!")) if !(@player_index==i)
    when 1
      Kernel.pbMessage(_INTL("Announcer: Spot no. #{i+1} takes a local trainer by the name, #{$Trainer.name}!")) if (@player_index==i)
      Kernel.pbMessage(_INTL("Announcer: Spot no. #{i+1} takes #{trainer[1]} from #{trainer[5]}, #{trainer[4]}!")) if !(@player_index==i)
    when 2
      Kernel.pbMessage(_INTL("Announcer: Our very own aspiring challenger #{$Trainer.name} is here to make a name for themself!")) if (@player_index==i)
      Kernel.pbMessage(_INTL("Announcer: From #{trainer[5]}, #{trainer[4]}, comes the legendary #{trainer[1]}!")) if !(@player_index==i)
    when 3
      Kernel.pbMessage(_INTL("Announcer: The next trainer is #{$Trainer.name} from our very own region!")) if (@player_index==i)
      Kernel.pbMessage(_INTL("Announcer: The next trainer is from #{trainer[5]}, #{trainer[4]}. Please, put your hands together for #{trainer[1]}!")) if !(@player_index==i)
    end
    
  end
  
# Cancels the entry into the Tournament
  def cancelEntry
    Kernel.pbMessage(_INTL("We hope to see you again."))
    return false
  end
  
# Creates a list of choices depending on the types of battles in BATTLE_LIST
  def chooseTournament(school)
    return 0 if school
    return 1
    choices = []
    for i in 0...BATTLE_LIST.index("Worlders")
      choices.push(BATTLE_LIST[i])
    end
    if ($Trainer.pwt_wins[BATTLE_LIST.index("Kantoers")]>0 && 
        $Trainer.pwt_wins[BATTLE_LIST.index("Johtoers")]>0 && 
        $Trainer.pwt_wins[BATTLE_LIST.index("Hoenners")]>0 && 
        $Trainer.pwt_wins[BATTLE_LIST.index("Sinnohers")]>0 &&
        $Trainer.pwt_wins[BATTLE_LIST.index("Unovaers")]>0)
      choices.push("Worlders")
    end
    if ($Trainer.pwt_wins[BATTLE_LIST.index("Worldpions")]>0)
      choices.push("Rentalers")
    end
    if ($Trainer.pwt_wins[BATTLE_LIST.index("Worldpions")]>0)
      choices.push("Mixer")
    end
    if ($Trainer.pwt_wins[BATTLE_LIST.index("Worlders")]>0)
      choices.push("Worldpions")
    end
    choices.push("Cancel")
    cmd=Kernel.pbMessage(_INTL("Which Tournament would you like to participate in?"),choices,choices.index("Cancel"))
    return false if choices[cmd]=="Cancel"
    return cmd
  end
  
# Allows the player to choose which style of battle they would like to do
  def chooseBattle
    return 0
    choices = ["Single","Double","Full","Sudden Death","Cancel"]
    cmd=Kernel.pbMessage(_INTL("Which type of Battle would you like to participate in?"),choices,choices.length-1)
    return false if cmd==choices.length-1
    return cmd
  end
  
# Checks if the party is eligible
  def partyEligible?
    case @battle_type
    when 0
      length = 3
    when 1
      length = 4
    when 2 
      length = 6
    when 3
      length = 1
    end
    count=0
    return false if $Trainer.party.length < length
    for i in 0...$Trainer.party.length
      if (isConst?($Trainer.party[i].species,PBSpecies,:LATIOS) && isConst?($Trainer.party[i].item,PBItems,:SOULDEW)) ||
         (isConst?($Trainer.party[i].species,PBSpecies,:LATIAS) && isConst?($Trainer.party[i].item,PBItems,:SOULDEW)) ||
         (isConst?($Trainer.party[i].species,PBSpecies,:REGIGIGAS) && isConst?($Trainer.party[i].item,PBItems,:CRYSTALPIECE))
        # Do not add these Pokemon to the eligible Pokemon list 
      else
        count+=1 if !(BAN_LIST.include?($Trainer.party[i].species)) && !($Trainer.party[i].egg?)
      end
    end
    
    return true if count>=length
    return false
  end

# Creates a new trainer party based on the battle type, and the Pokemon chosen to enter
  def choosePokemon(isschool)
    return $Trainer.party if isschool
    ret=false
    return "notEligible" if !partyEligible?
    case @battle_type
    when 0
      length = 3
    when 1
      length = 4
    when 2 
      length = 6
    when 3
      length = 1
    end
    maxLength=length
    case @battle_type
    when 0
      maxLength = 3
    when 1
      maxLength = 4
    end
    
    Kernel.pbMessage(_INTL("Please choose the Pokemon you would like to participate."))
    ruleset=PokemonRuleSet.new
    ruleset.addPokemonRule(RestrictSpecies.new)
    ruleset.setNumberRange(length,maxLength)
    pbFadeOutIn(99999){
       scene=PokemonScreen_Scene.new
       screen=PokemonScreen.new(scene,$Trainer.party)
       ret=screen.pbPokemonMultipleEntryScreenEx(ruleset)
    }
    return ret
  end
  
# Creates the initial trainer list for the first round, depending on the category chosen
  def generateRounds(isschool)
    $game_variables[185]=Array.new
    for i in 0...@modified_party.length
      $game_variables[185]=@modified_party[i].level
      @modified_party[i].level=50 if !isschool
      @modified_party[i].calcStats
    end
    
    @trainer_list = []
    full_list = TRAINER_LIST[@tournament_type].clone
    if !isschool
      loop do
        n = rand(full_list.length)
        trainer = full_list[n]
        #Kernel.pbMessage(_INTL("{1}",full_list.length))
        #if trainer==nil
        #  Kernel.pbMessage(_INTL("{1}",full_list.length))
        #  Kernel.pbMessage(_INTL("{1}",n))
        #end
        #  Kernel.pbMessage(_INTL("Length: {1}",full_list.length))
        #for i in 0...full_list.length
        #  Kernel.pbMessage(_INTL("{1}, {2}, {3}",full_list[i][0],full_list[i][1],full_list[i][6]))
        #end
        full_list.delete_at(n)
        @trainer_list.push(trainer)
        break if @trainer_list.length>7
      end
    else
      @trainer_list=full_list
     # for i in 0..full_list.length
     #   trainer = full_list[i]
        #full_list.delete_at(i)
     #   @trainer_list.push(trainer)
     # end
    end
  
    n = rand(8)
    n = 1 if isschool
    @player_index = n
    @player_index_int = @player_index
    #if @trainer_list.length<8 || @trainer_list.length>8
    #  for i in 0...@trainer_list.length
    #    Kernel.pbMessage(_INTL("{1},",@trainer_list[i][0]))
    #    Kernel.pbMessage(_INTL("{1},",@trainer_list[i][1]))
    #    Kernel.pbMessage(_INTL("{1}",@trainer_list[i][6]))
    #  end
    #end
    for i in 0...@trainer_list.length
    #Kernel.pbMessage(_INTL("{1}",i))
    #Kernel.pbMessage("trainer"+("%03d"%@trainer_list[i][0]))
      if $game_map.map_id==709
        #if @trainer_list[i]==nil
        #  for j in 0...@trainer_list.length
        #  Kernel.pbMessage(_INTL("{1}",@trainer_list[j]))
        #  end
        #end
        @trainer_list[i].push("trainer"+("%03d"%@trainer_list[i][0])) #if @trainer_list[i][6].nil? && !@trainer_list[i][1].is_a?(PokeBattle_Pokemon)
      else
        @trainer_list[i].push("trchar"+("%03d"%@trainer_list[i][0])) if @trainer_list[i][6].nil? && !@trainer_list[i][1].is_a?(PokeBattle_Pokemon)
      end
    end
  
    @trainer_list[n] = @modified_party    
    $Trainer.party = @modified_party
    @trainer_list_int=@trainer_list
  end
  
# Outputs a message which lists all the Pokemon banned from the Tournament
  def showBanList
    msg = ""
    for i in 0...BAN_LIST.length
      
      pkmn = PokeBattle_Pokemon.new(BAN_LIST[i],1,nil,false)
      msg+="#{pkmn.name}, "
    end
    msg+="Latios and Latias if holding a Soul Dew, Pokemon holding their respective Crystal Pieces, and Eggs are not eligible for entry in the Tournament."
    
    return msg
  end
  
# Handles the tournament branch
# and adds some additional flavour such as an announcer talking
  def startTournament(announce,school)
    @round=0
    doublebattle=false
    doublebattle=true if @battle_type==1
    15.times do
      @sprites["scoreboard"].opacity+=17
      pbWait(1)
    end
    Kernel.pbMessage(_INTL("Announcer: Welcome to the #{BATTLE_LIST[@tournament_type]} Tournament!")) if !school
    Kernel.pbMessage(_INTL("Announcer: Today we have 8 very eager contestants, waiting to compete for the title of \"Champion\".")) if !school
    Kernel.pbMessage(_INTL("Today we have 8 very eager students, ready to compete for the title of \"Champion\".")) if school
    Kernel.pbMessage(_INTL("Announcer: Let us turn our attention to the scoreboard, to see who will be competing today.")) if !school
    Kernel.pbMessage(_INTL("Let's have a look, shall we?")) if school
    self.createScoreBoard(@trainer_list)
    for i in 0...8
      announceContest(@trainer_list[i],i) if announce
    end
    Kernel.pbMessage(_INTL("Without further ado, let the first match begin!")) if school
    Kernel.pbMessage(_INTL("Announcer: Without further ado, let the first match begin.")) if !school
    trainer=self.generateRound1
    Kernel.pbMessage(_INTL("Announcer: This will be a battle between #{$Trainer.name} and #{trainer[1]}!"))
    tempvar=0
    $school=school
    outcome=pbPWTTrainerBattle(trainer[0],trainer[1],trainer[2],trainer[3],doublebattle,tempvar)
    if outcome==1
      @round=1
      Kernel.pbMessage(_INTL("Announcer: Wow! What an exciting first round!"))
      Kernel.pbMessage(_INTL("Announcer: The stadium is getting heated up, and the contestants are on fire!"))
      Kernel.pbMessage(_INTL("Announcer: Let us turn our attention back to the scoreboard for the results."))
      trainer=self.generateRound2(school)
      self.createScoreBoard(@trainer_list)
      Kernel.pbMessage(_INTL("Announcer: It looks like the next match will be between #{$Trainer.name} and #{trainer[1]}."))
      Kernel.pbMessage(_INTL("Announcer: Let the battle begin!"))
      if trainer[1].include?("Damian")
        tempvar=$game_variables[7]+3
      end

      outcome=pbPWTTrainerBattle(trainer[0],trainer[1],trainer[2],trainer[3],doublebattle,tempvar)
      if outcome==1
        @round=2
        Kernel.pbMessage(_INTL("Announcer: What spectacular matches!"))
        Kernel.pbMessage(_INTL("Announcer: These trainers are really giving it all."))
        Kernel.pbMessage(_INTL("Announcer: Let's direct our attention at the scoreboard one final time."))
        trainer=self.generateRound3(school)
        self.createScoreBoard(@trainer_list)
        Kernel.pbMessage(_INTL("Announcer: Alright! It's all set!"))
        Kernel.pbMessage(_INTL("Announcer: The final match of this tournament will be between #{$Trainer.name} and #{trainer[1]}!"))
        Kernel.pbMessage(_INTL("Announcer: May the best trainer win!"))
            if trainer[1]=="Nora" 
        tempvar=$game_variables[7]-1
      end

        outcome=pbPWTTrainerBattle(trainer[0],trainer[1],trainer[2],trainer[3],doublebattle,tempvar)
        if outcome==1
          Kernel.pbMessage(_INTL("Announcer: What an amazing battle!"))
          Kernel.pbMessage(_INTL("Announcer: Both the trainers put up a great fight, but our very own #{$Trainer.name} was the one to come out on top!"))
          Kernel.pbMessage(_INTL("Announcer: Congratulations #{$Trainer.name}! You have certainly earned today's title of \"Champion\"!"))

          Kernel.pbMessage(_INTL("Announcer: That's all we have time for. I hope you enjoyed today's contest. And we hope to see you again soon."))
          return "win"
        end
      end
    end
    return "loss"
  end
  def getStringForType
    if $Trainer.trainertype<100
      return "00"+$Trainer.trainertype.to_s
    else
     return $Trainer.trainertype.to_s
   end
   
  end
# Creates a basic Image illustrating a scoreboard
  def createScoreBoard(list)
    nlist=[]
    for i in 0...list.length
      nlist.push(list[i][0])
    end
    x=0
    y=0
    @sprites["scoreboard"].bitmap.clear
    @sprites["scoreboard"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
    @sprites["scoreboard"].bitmap.blt(0,0,BitmapCache.load_bitmap("Graphics/Pictures/scoreboard"),Rect.new(0,0,Graphics.width,Graphics.height))
    pbSetSystemFont(@sprites["scoreboard"].bitmap)
    for i in 0...@trainer_list_int.length
      opacity=255
      if i==@player_index_int
        trname="#{$Trainer.name}"
        meta=pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
   #     char=pbGetPlayerGraphic(meta,1)
        char=pbGetPlayerWalkingGraphic
        if $game_map.map_id==709
          bitmap=BitmapCache.load_bitmap("Graphics/Characters/trainer"+getStringForType)
        else
          bitmap=BitmapCache.load_bitmap("Graphics/Characters/trchar"+getStringForType)
        end
        
      for i in 0..5
        $Trainer.clothes[i] = 0 if $Trainer.clothes[i]==nil
      end
  #   appendToFront(image,trainer,trainercard=false,isbitmap=false)
      bitmap=Kernel.appendToFront(bitmap,$Trainer,true,true) if $game_map.map_id==709
      else
        opacity=80 if !(nlist.include?(@trainer_list_int[i][0]))
        trname=@trainer_list_int[i][1]
        #strtouse="%03d" % @trainer_list_int[i][6]
        #bitmap=BitmapCache.load_bitmap("Graphics/Characters/"+strtouse)
      begin
          bitmap=BitmapCache.load_bitmap("Graphics/Characters/#{@trainer_list_int[i][6]}")
        rescue
                    bitmap=BitmapCache.load_bitmap("Graphics/Characters/trainer000")
      end
      
      end
      if $game_map.map_id==108           #20+
        @sprites["scoreboard"].bitmap.blt((Graphics.width-24-(bitmap.width/4))*x,20+(Graphics.height/6)*y,bitmap,Rect.new(0,0,bitmap.width/4,bitmap.height/4),opacity)
      else
       # if i==@player_index_int
       #   @sprites["scoreboard"].bitmap.blt(20+(Graphics.width-24-(bitmap.width/4))*x,20+(Graphics.height/6)*y,bitmap,Rect.new(0,0,bitmap.width,bitmap.height/4),opacity)
       # else
          @sprites["scoreboard"].bitmap.blt((Graphics.width-24-(bitmap.width/4))*x - 12,20+(Graphics.height/6)*y,bitmap,Rect.new(30,0,bitmap.width,64),opacity)
      
       # end
        
      end
      text=[["#{trname}",24+(bitmap.width/4)+(Graphics.width-32-(bitmap.width/2))*x -20,34+(Graphics.height/6)*y,x*1,Color.new(255,255,255),Color.new(80,80,80)]]
      pbDrawTextPositions(@sprites["scoreboard"].bitmap,text)
      y+=1
      x+=1 if y>3
      y=0 if y>3
    end
      
  end
    
# Heals your party
  def healParty
    for pokemon in $Trainer.party
      pokemon.heal if !pokemon.is_a?(String) && (!$game_switches[71] || pokemon.hp>0)
      for i in 0...@current_party.length
        if !pokemon.is_a?(String) && @current_party[i].personalID==pokemon.personalID
          @current_party[i].hp=pokemon.hp
        end
      end
      pokemon.form=Kernel.pbReturnFormNumber(pokemon)
    end
  end
  
  def replaceItems
    for i in 0...$Trainer.party.length
      $Trainer.party[i].item=@party_items[i]
    end
  end

  def generateRound1
    healParty
    replaceItems
    case @player_index
    when 0
      trainer=@trainer_list[1]
    when 1
      trainer=@trainer_list[0]
    when 2
      trainer=@trainer_list[3]
    when 3
      trainer=@trainer_list[2]
    when 4
      trainer=@trainer_list[5]
    when 5
      trainer=@trainer_list[4]
    when 6
      trainer=@trainer_list[7]
    when 7
      trainer=@trainer_list[6]
    end
    return trainer
  end
  
  def generateRound2(isschool)
    healParty
    replaceItems
#    list=["","","",""]
   list=[]
    case @player_index
    when 0
      @player_index=0
      list[0]=@modified_party
  #    list[1]=@trainer_list[2+rand(2)] if !isschool
      list[1]=@trainer_list[3] #if isschool
  #    list[2]=@trainer_list[4+rand(2)] if !isschool
      list[2]=@trainer_list[4] #if isschool
      list[3]=@trainer_list[6+rand(2)]
    when 1
       @player_index=0
     
      list[0]=@modified_party
     # list[1]=@trainer_list[2+rand(2)] if !isschool
      list[1]=@trainer_list[3] #if isschool
      #list[2]=@trainer_list[4+rand(2)] if !isschool
      list[2]=@trainer_list[5] #if isschool
      list[3]=@trainer_list[6+rand(2)]
    when 2
      @player_index=1
      list[1]=@modified_party
      list[0]=@trainer_list[0+rand(2)]
      list[2]=@trainer_list[4+rand(2)]
      list[3]=@trainer_list[6+rand(2)]
    when 3
      @player_index=1
      list[1]=@modified_party
      list[0]=@trainer_list[0+rand(2)]
      list[2]=@trainer_list[4+rand(2)]
      list[3]=@trainer_list[6+rand(2)]
    when 4
      @player_index=2
      list[2]=@modified_party
      list[0]=@trainer_list[0+rand(2)]
      list[1]=@trainer_list[2+rand(2)]
      list[3]=@trainer_list[6+rand(2)]
    when 5
      @player_index=2
      list[2]=@modified_party
      list[0]=@trainer_list[0+rand(2)]
      list[1]=@trainer_list[2+rand(2)]
      list[3]=@trainer_list[6+rand(2)]
    when 6
      @player_index=3
      list[3]=@modified_party
      list[0]=@trainer_list[0+rand(2)]
      list[1]=@trainer_list[2+rand(2)]
      list[2]=@trainer_list[4+rand(2)]
    when 7
      @player_index=3
      list[3]=@modified_party
      list[0]=@trainer_list[0+rand(2)]
      list[1]=@trainer_list[2+rand(2)]
      list[2]=@trainer_list[4+rand(2)]
    end
    @trainer_list=list
    case @player_index
    when 0
      trainer=@trainer_list[1]
    when 1
      trainer=@trainer_list[0]
    when 2
      trainer=@trainer_list[3]
    when 3
      trainer=@trainer_list[2]
    end
    return trainer
  end
  
  def generateRound3(isschool)
    healParty
    replaceItems
    list=["","","",""]
    case @player_index
    when 0
      @player_index=0
      list[0]=@modified_party
      list[1]=@trainer_list[2+rand(2)]
      list[1]=@trainer_list[2] if isschool
    when 1
      @player_index=0
      list[0]=@modified_party
      list[1]=@trainer_list[2+rand(2)]
    when 2
      @player_index=1
      list[1]=@modified_party
      list[0]=@trainer_list[0+rand(2)]
    when 3
      @player_index=1
      list[1]=@modified_party
      list[0]=@trainer_list[0+rand(2)]
    end
    @trainer_list=list
    case @player_index
    when 0
      trainer=@trainer_list[1]
    when 1
      trainer=@trainer_list[0]
    end
    return trainer
  end

end

#===============================================================================
# PWT battle rules
#===============================================================================
class RestrictSpecies
 def initialize
  @specieslist=BAN_LIST.clone
 end
 def isSpecies?(species,specieslist)
  for s in specieslist
   return true if species==s
  end
  return false  
 end
 def isValid?(pokemon)
  count=0
    if (isConst?(pokemon.species,PBSpecies,:LATIOS) && isConst?(pokemon.item,PBItems,:SOULDEW)) ||
       (isConst?(pokemon.species,PBSpecies,:LATIAS) && isConst?(pokemon.item,PBItems,:SOULDEW)) ||
       (isConst?(pokemon.species,PBSpecies,:REGIGIGAS) && isConst?(pokemon.item,PBItems,:CRYSTALPIECE))
      count+=1
    elsif isSpecies?(pokemon.species,@specieslist) && !(pokemon.egg?)
      count+=1
    end
    return count==0
  end
end

#===============================================================================
# Exta classes and functions for PWT trainer and battle generation
#===============================================================================

class PokeBattle_Trainer
  attr_accessor(:battle_points)
  attr_accessor(:pwt_wins)
end

# Generates a new PWT styled trainer, where the party is randomized (from the options in the trainer party definition of PBS/trainers.txt)
def pbPWTLoadTrainer(trainerid,trainername,partyid=0)
  success=false
  items=[]
  party=[]
  opponent=nil
  generateFromNormal=true
  case @battle_type
  when 0
    length = 3
  when 1
    length = 4
  when 2 
    length = 6
  when 3
    length = 1
  end
  random=$game_switches[321] && $game_map.map_id==108
  if $PokemonSystem.chooseDifficulty==0
    trainers=load_data("Data/trainers_easy.dat")
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      generateFromNormal=false
      items=trainer[2].clone
      name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
      for i in RIVALNAMES
        if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
          name=$game_variables[i[1]]
        end
      end
      opponent=PokeBattle_Trainer.new(name,thistrainerid)
      opponent.setForeignID($Trainer) if $Trainer
      for poke in trainer[3]
        species=poke[0]
        if random
          if Kernel.pbGetMegaStoneList.include?(poke[2])
            species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
            item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
            #cowctus
          else
            if !poke[15]
              #  species=rand(649) 
              #species = rand(721)+1
              #species = 1 if species == 0
              deltaAry=[]
              for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
                deltaAry.push(i)
              end
              species=rand(721+deltaAry.length+1)
              species = 1 if species == 0
              if species>PBSpecies::VOLCANION
                species=deltaAry[species-722]
              end
            end
          end                      
        end
        level=poke[1]
        pokemon=PokeBattle_Pokemon.new(species,level,opponent)
        if !random
          pokemon.form=poke[9]
        else
          pokemon.form=0
        end
        pokemon.resetMoves
        pokemon.item=poke[2]
        if !random
          if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
            for k in 0...4
              pokemon.moves[k]=PBMove.new(poke[3+k])
            end
            pokemon.moves.compact!
          end
        elsif item==PBItems::RAYQUAZITE
          pokemon.moves[0]=PBMove.new(PBMoves::DRAGONSASCENT)
          pokemon.item=0
        end
        #if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
        #  k=0
        #  for move in [3,4,5,6]
        #    pokemon.moves[k]=PBMove.new(poke[move])
        #    k+=1
        #  end
        #  pokemon.moves.compact!
        #end
        pokemon.setAbility(poke[7])
        if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
          pokemon.form=rand(7)+1
        end
        pokemon.setGender(poke[8])
        if poke[10]   # if this is a shiny Pokémon
          pokemon.makeShiny
        else
          pokemon.makeNotShiny
        end
        pokemon.setNature(poke[11])
        iv=poke[12]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
        pokemon.happiness=poke[13]
        if !random
          pokemon.name=poke[14] if poke[14] && poke[14]!=""
        end
        #pokemon.name=poke[14] if poke[14] && poke[14]!=""
        if poke[15]   # if this is a Shadow Pokémon
          pokemon.makeShadow rescue nil
          pokemon.pbUpdateShadowMoves(true) rescue nil
          pokemon.makeNotShiny
        end
        #pokemon.ballused=poke[TPBALL]
        if poke[16] && poke[16] != ""
          setEVs(pokemon,poke[16].to_i)
        end
    
        pokemon.calcStats
        party.push(pokemon)
      end
      #old_party=party
      #new_party=[]
      #count=0
      #loop do
      #  n=rand(old_party.length)
      #  new_party.push(old_party[n])
      #  old_party.delete_at(n)
      #  break if new_party.length>=length
      #end
      #party=new_party
      success=true
      break
    end
  elsif $PokemonSystem.chooseDifficulty==2
    trainers=load_data("Data/trainers_hard.dat")
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      generateFromNormal=false
      items=trainer[2].clone
      name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
      for i in RIVALNAMES
        if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
          name=$game_variables[i[1]]
        end
      end
      opponent=PokeBattle_Trainer.new(name,thistrainerid)
      opponent.setForeignID($Trainer) if $Trainer
      for poke in trainer[3]
        species=poke[0]
        if random
          if Kernel.pbGetMegaStoneList.include?(poke[2])
            species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
            item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
            #cowctus
          else
            if !poke[15]
              #  species=rand(649) 
              #species = rand(721)+1
              #species = 1 if species == 0
              deltaAry=[]
              for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
                deltaAry.push(i)
              end
              species=rand(721+deltaAry.length+1)
              species = 1 if species == 0
              if species>PBSpecies::VOLCANION
                species=deltaAry[species-722]
              end
            end
          end                      
        end
        level=poke[1]
        pokemon=PokeBattle_Pokemon.new(species,level,opponent)
        if !random
          pokemon.form=poke[9]
        else
          pokemon.form=0
        end
        pokemon.resetMoves
        pokemon.item=poke[2]
        if !random
          if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
            for k in 0...4
              pokemon.moves[k]=PBMove.new(poke[3+k])
            end
            pokemon.moves.compact!
          end
        elsif item==PBItems::RAYQUAZITE
          pokemon.moves[0]=PBMove.new(PBMoves::DRAGONSASCENT)
          pokemon.item=0
        end
        #if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
        #  k=0
        #  for move in [3,4,5,6]
        #    pokemon.moves[k]=PBMove.new(poke[move])
        #    k+=1
        #  end
        #  pokemon.moves.compact!
        #end
        pokemon.setAbility(poke[7])
        if pokemon.species==PBSpecies::DELTAMUK && isConst?(pokemon.ability,PBAbilities,:REGURGITATION)
          pokemon.form=rand(7)+1
        end
        pokemon.setGender(poke[8])
        if poke[10]   # if this is a shiny Pokémon
          pokemon.makeShiny
        else
          pokemon.makeNotShiny
        end
        pokemon.setNature(poke[11])
        iv=poke[12]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
        pokemon.happiness=poke[13]
        if !random
          pokemon.name=poke[14] if poke[14] && poke[14]!=""
        end
        #pokemon.name=poke[14] if poke[14] && poke[14]!=""
        if poke[15]   # if this is a Shadow Pokémon
          pokemon.makeShadow rescue nil
          pokemon.pbUpdateShadowMoves(true) rescue nil
          pokemon.makeNotShiny
        end
        #pokemon.ballused=poke[TPBALL]
        if poke[16] && poke[16] != ""
          setEVs(pokemon,poke[16].to_i)
        end
    
        pokemon.calcStats
        party.push(pokemon)
      end
      #old_party=party
      #new_party=[]
      #count=0
      #loop do
      #  n=rand(old_party.length)
      #  new_party.push(old_party[n])
      #  old_party.delete_at(n)
      #  break if new_party.length>=length
      #end
      #party=new_party
      success=true
      break
    end
  end
  if generateFromNormal || $PokemonSystem.chooseDifficulty==1
    trainers=load_data("Data/trainers.dat")
    for trainer in trainers
      name=trainer[1]
      thistrainerid=trainer[0]
      thispartyid=trainer[4]
      next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
      items=trainer[2].clone
      name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
      for i in RIVALNAMES
        if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
          name=$game_variables[i[1]]
        end
      end
      
      opponent=PokeBattle_Trainer.new(name,thistrainerid)
      opponent.setForeignID($Trainer) if $Trainer
      for poke in trainer[3]
        species=poke[0]
        if $game_switches[321] && $game_map.map_id==108
          if Kernel.pbGetMegaStoneList.include?(poke[2])
            species=Kernel.pbGetMegaSpeciesList[rand(Kernel.pbGetMegaSpeciesList.length)]
            item=Kernel.pbGetMegaStoneList[Kernel.pbGetMegaSpeciesList.index(species)]
            #cowctus
          else
            if !poke[15]
              #  species=rand(649) 
              #species = rand(721)+1
              #species = 1 if species == 0
              deltaAry=[]
              for i in PBSpecies::DELTABULBASAUR..(PBSpecies::UFI)
                deltaAry.push(i)
              end
              species=rand(721+deltaAry.length+1)
              species = 1 if species == 0
              if species>PBSpecies::VOLCANION
                species=deltaAry[species-722]
              end
            end
          end                      
        end
        level=poke[1]
        pokemon=PokeBattle_Pokemon.new(species,level,opponent)
        pokemon.form=poke[9]
        pokemon.resetMoves
        pokemon.item=poke[2]
        if poke[3]>0 || poke[4]>0 || poke[5]>0 || poke[6]>0
          k=0
          for move in [3,4,5,6]
            pokemon.moves[k]=PBMove.new(poke[move])
            k+=1
          end
          pokemon.moves.compact!
        end
        pokemon.setAbility(poke[7])
        pokemon.setGender(poke[8])
        if poke[10]   # if this is a shiny Pokémon
          pokemon.makeShiny
        else
          pokemon.makeNotShiny
        end
        pokemon.setNature(poke[11])
        iv=poke[12]
        for i in 0...6
          pokemon.iv[i]=iv&0x1F
          pokemon.ev[i]=[85,level*3/2].min
        end
        pokemon.happiness=poke[13]
        pokemon.name=poke[14] if poke[14] && poke[14]!=""
        if poke[15]   # if this is a Shadow Pokémon
          pokemon.makeShadow rescue nil
          pokemon.pbUpdateShadowMoves(true) rescue nil
          pokemon.makeNotShiny
        end
        #pokemon.ballused=poke[TPBALL]
        if poke[16] && poke[16] != ""
          setEVs(pokemon,poke[16].to_i)
        end
    
        pokemon.calcStats
        party.push(pokemon)
      end
      #old_party=party
      #new_party=[]
      #count=0
      #loop do
      #  n=rand(old_party.length)
      #  new_party.push(old_party[n])
      #  old_party.delete_at(n)
      #  break if new_party.length>=length
      #end
      #party=new_party
      success=true
      break
    end
  end
  return success ? [opponent,items,party] : nil
end

# Creates the PWT styled battle, where exp gain, money gain and switching is disabled
def pbPWTTrainerBattle(trainerid,trainername,endspeech,endspeechwin,
                    doublebattle=false,trainerparty=0,canlose=true)
  #              Kernel.pbMessage(trainerparty.to_s)
  trainerparty=5 if !$school
  if $Trainer.pokemonCount==0
    Kernel.pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    return false
  end
  if !$PokemonTemp.waitingTrainer && $Trainer.ablePokemonCount>1 &&
     pbMapInterpreterRunning?
    thisEvent=pbMapInterpreter.get_character(0)
    triggeredEvents=$game_player.pbTriggeredTrainerEvents([2],false)
    otherEvent=[]
    for i in triggeredEvents
      if i.id!=thisEvent.id && !$game_self_switches[[$game_map.map_id,i.id,"A"]]
        otherEvent.push(i)
      end
    end
    if otherEvent.length==1
      trainer=pbLoadTrainer(trainerid,trainername,trainerparty)
      if !trainer
        pbMissingTrainer(trainerid,trainername,trainerparty)
        return false
      end
      if trainer[2].length<=3
        $PokemonTemp.waitingTrainer=[trainer,thisEvent.id,endspeech,doublebattle]
        return false
      end
    end
  end
  trainer=pbPWTLoadTrainer(trainerid,trainername,trainerparty)
  if !trainer
    pbMissingTrainer(trainerid,trainername,trainerparty)
    return false
  end
  playerparty=$Trainer.party
  playertrainer=$Trainer
  fullparty1=false
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,playerparty,trainer[2],playertrainer,trainer[0])
  battle.fullparty1=fullparty1
  battle.doublebattle=doublebattle
  battle.endspeech=endspeech
  battle.endspeechwin=endspeechwin
  battle.items=trainer[1]
  trainerbgm=pbGetTrainerBattleBGM(trainer[0])
  #  trainerbgm="PWT Finals.mp3" if @round==2 && !(["World Champions","Rental Masters","Mix Master"].include?(BATTLE_LIST[@tournament_type]))
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2
    if $PokemonTemp.waitingTrainer
      pbMapInterpreter.pbSetSelfSwitch(
          $PokemonTemp.waitingTrainer[1],"A",true
      )
      $PokemonTemp.waitingTrainer=nil
    end
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  #  battle.internalbattle=false
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  pbBattleAnimation(trainerbgm,trainer[0].trainertype,trainer[0].name) { 
      pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
      }
      for i in $Trainer.party; (i.makeUnmega rescue nil); end
      if $PokemonGlobal.partner
        pbHealAll
        for i in $PokemonGlobal.partner[3]
          i.heal
          i.makeUnmega rescue nil
        end
      end
      if decision==2 || decision==5
        if canlose
          for i in $Trainer.party; i.heal; end
          for i in 0...10
            Graphics.update
          end
        else
          $game_system.bgm_unpause
          $game_system.bgs_unpause
          Kernel.pbStartOver
        end
      else
        Events.onEndBattle.trigger(nil,decision)
        if decision==1
          if $PokemonTemp.waitingTrainer
          pbMapInterpreter.pbSetSelfSwitch(
              $PokemonTemp.waitingTrainer[1],"A",true
            )
          end
        end
      end
  }
  Input.update
  $PokemonTemp.waitingTrainer=nil
  return decision
end