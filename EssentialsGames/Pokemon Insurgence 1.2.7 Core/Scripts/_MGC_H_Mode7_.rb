#============================================================================
# H-Mode7 Engine
# V.1.2.1 - 15/05/2011
# Author : MGC (MGCaladtogel)
# Heightmaps cache by DerVVulman
#
# A mode 7 engine using heightsmap to add a 3D effect.
# Refer to the HM7 topic on save-point.org for explanation.
#============================================================================
#----------------------------------------------------------------------------
#Instructions :
#
#What is required :
#- the script (above main, as usual)
#- the file MGC_Hmode7.dll at the root of your project
#- specific autotiles, tilesets, textures and heightmaps
#
#To activate the H-Mode7, you must add [HM7] to the map name.
#The following tags are optionnal :
#[HMAPXXX] : XXX is the identifier of the ground heightmap that must be used for the map
#[#XX] : XX is the angle of slant (in degree) : 0 -> 80, 0 by default
#[%XXX] : XXX is the angle of rotation (in degree) : 0 -> 359, 0 by default
#[X] : enable horizontal map looping
#[Y] : enable vertical map looping
#[DA] : deactivate animated autotiles
#[AFXXX] : XXX is the animations period for animated autotiles : 1 -> 999, 20 frames by default
#[DL] : deactivate automatic lighting effects
#[RX] : X = 1 -> high resolution (default)
#     : X = 2 -> medium resolution (to increase performance)
#     : X = 3 -> low resolution (to drastically increase performance)
#[CX] : X = 0 -> no vertical offset (default)
#     : X = 1 -> vertical offset so that the camera do not cut the ground at the bottom of the screen.
#                Should be used only when the horizon is visible.
#     : X = 2 -> vertical offset so that the camera do not cut the map at the bottom of the screen.
#                Should be used only when the horizon is visible.
#[DF] : deactivate the filter (better quality, drastically decrease performance)
#[HF] : refresh the map every two frames (less fluent, increase performance)
#[E] (V.1.2.1) : edmhotta's request to have less cut elements at the bottom of the screen.
#                May cause massive lag, especially when rotating. 
#[DB] (V.1.2.1) : cut elements at the bottom of the screen are not black (but still cut)
#
#You can also associate a keyword to a configuration at the beginning of the script.
#For example, with the following command :
#HM7::Maps_Settings["MyKeyword"] = ["#60", "X", "HMAP3"]
#if a map name contains "MyKeyword", then the HM7 will be activated, with a slant angle of 60 degrees, horizontal looping,
#and using the picture "Heightmap_003" as ground heightmap.
#
#
#Commands :
#
#- To set a new angle of slant (0~80) :
#$scene.hm7_set_alpha(new angle)
#To slide progressively into a new angle of slant :
#$scene.hm7_to_alpha(new angle, speed)
#To increase/decrease the slant :
#$scene.hm7_increase_alpha(value)
#
#- To set a new angle of rotation (0~379) :
#$scene.hm7_set_theta(new angle)
#To slide progressively into a new angle of rotation :
#$scene.hm7_to_theta(angle, speed, dir)
#To increase/decrease the angle of rotation :
#$scene.hm7_increase_theta(value)
#
#- To set a new zoom level (in percentage - default = 100) :
#$scene.hm7_set_zoom(new value)
#To slide progressively into a new zoom level :
#$scene.hm7_to_zoom(value, speed)
#To increase/decrease the zoom level :
#$scene.hm7_increase_zoom(value)
#
#- To change the horizon light fading :
#$scene.hm7_set_fading(red, green, blue, flag)
#flag = 1 : the color determined by (red, green, blue) will be added to the horizon line
#flag = 0 : the color determined by (red, green, blue) will be substracted to the horizon line
#
#- To set the altitude of an event :
#add a comment in the commands list with : "Altitude X", where X is the
#height value ("Altitude 64" will draw the event 64 pixels above its original position)
#- To set the altitude of the player :
#use : $game_player.altitude = X
#- To have a fixed altitude for an event (not dependant on the maps heights) :
#add the comment "Floating" in the commands list
#- To have a fixed altitude for the player :
#use : $game_player.floating = true
#============================================================================
module HM7
  # To access maps names
  Data_Maps = load_data("Data/MapInfos.rxdata")
  Maps_Settings = {}
  # Prepare your own settings for mode7 maps
  # Just put the first parameter in a map's name
  # For example :
  Maps_Settings["Worldmap"] = ["#60", "X", "Y"]
  # -> will  be called  when "Worldmap" is included in the name
  # Add any number of settings you want
  
  # V.1.1 : 8-directions graphics
  # Rows of character sets : the first represents the character that faces the screen,
  # then the character rotates in the trigonometric direction
  Dirs = {}
  # 4 directions :
  Dirs[4] = [0, 2, 3, 1]
  # 8 directions :
  Dirs[8] = [0, 6, 2, 7, 3, 5, 1, 4]
  # you can change these values or add directions
  #- To set the number of directions of an event :
  # add a comment in the event's commands list with : "Directions X"
  #- To set the number of directions for the player (before assigning its graphics) :
  # use : $game_player.directions = X
end