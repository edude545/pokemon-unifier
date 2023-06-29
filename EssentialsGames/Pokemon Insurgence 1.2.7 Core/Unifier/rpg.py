class Table:
	# dim - int
	# x - int
	# y - int
	# z - int
	# data - string array
	def unifier_organize(self):
		# new_data = []
		# for zi in range(self.z):
		# 	layer = []
		# 	for yi in range(self.y):
		# 		row = self.data[yi+self.y*zi].split(" ")
		# 		for xi in range(len(row)):
		# 			row[xi] = int(row[xi], 16)
		# 		layer.append(row)
		# 	new_data.append(layer)
		# self.data = new_data
		new_data = []
		for line in self.data:
			new_data.append(" ".join(list(str(int(n,16)) for n in line.split(" "))))
		self.data = new_data

	def __str__(self):
		return "\n".join(self.data)

class Tone:
	# r - float from -255
	# g - float from -255
	# b - float from -255
	# a - float from 255
	def unifier_organize(self):
		pass

class Color:
	pass

class Map:
	# autoplay_bgm - bool
	# autoplay_bgs - bool
	# bgm - AudioFile
	# bgs - AudioFile
	# data - Table
	# encounter_list - array
	# encounter_step - int
	# events - dictionary, int to Event
	# height - int
	# tileset_id - int
	# width - int

	# expanded - bool
	# name - string
	# order - int
	# parent_id - int
	# scroll_x - int
	# scroll_y - int
	# id - int

	
	def unifier_organize(self):
		pass
	def generate_unity_asset(self, msg=True):
		escaped_chars = "\n    - "
		with open("C:/Users/edude/Documents/Unity Projects/pokemon-unifier/Assets/Data/Insurgence/Maps/{id}.asset".format(id=self.id), "w") as f:
			f.write(f"""%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!114 &11400000
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: 0}}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {{fileID: 11500000, guid: 6031c8c336810bc4cb79fe74eaf8f490, type: 3}}
  m_Name: {self.id}
  m_EditorClassIdentifier: 
  Name: {self.name}
  ID: {self.id}
  TileIDs:
    SizeX: {self.data.x}
    SizeY: {self.data.y}
    SizeZ: {self.data.z}
    s_values: {"".join(escaped_chars+s for s in self.data.data)}
  BackgroundMusicName: {self.bgm.name}
  BackgroundMusicPitch: {self.bgm.pitch}
  BackgroundMusicVolume: {self.bgm.volume}
  AutoplayBackgroundMusic: {int(self.autoplay_bgm)}
  BackgroundSoundName: {self.bgs.name}
  BackgroundSoundPitch: {self.bgs.pitch}
  BackgroundSoundVolume: {self.bgs.volume}
  AutoplayBackgroundSound: {int(self.autoplay_bgs)}
  EncounterStep: {self.encounter_step}
  TilesetID: {self.tileset_id}
  Expanded: {int(self.expanded)}
  Order: {self.order}
  ParentID: {self.parent_id}
  ScrollX: {self.scroll_x}
  ScrollY: {self.scroll_y}
""")

class Tileset:
	# autotile_names - string
	# battleback_name - string
	# fog_blend_type - int
	# fog_hue - int
	# fog_name - string
	# fog_opacity - int
	# fog_sx - int
	# fog_sy - int
	# fog_zoom - int
	# id - int
	# name - string
	# panorama_hue - int
	# panorama_name - string
	# passages - Table
	# priorities - Table
	# terrain_tags - Table
	# tileset_name - string
	def unifier_organize(self):
		pass
	def generate_unity_asset(self, msg=True):
		escaped_chars = "\n    - "
		with open(f"C:/Users/edude/Documents/Unity Projects/pokemon-unifier/Assets/Data/Insurgence/Tilesets/{self.id}.asset", "w") as f:
			f.write(f"""%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!114 &11400000
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: 0}}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {{fileID: 11500000, guid: 2b430a8f386c8bf489edc374d8043204, type: 3}}
  m_Name: {self.id}
  m_EditorClassIdentifier: 
  DisplayName: {self.name}
  TilesetName: {self.tileset_name}
  ID: {self.id}
  AutotileNames: {"".join(escaped_chars+s for s in self.autotile_names)}
  BattlebackName: {self.battleback_name}
  FogBlendType: {self.fog_blend_type}
  FogHue: {self.fog_hue}
  FogName: {self.fog_name}
  FogOpacity: {self.fog_opacity}
  FogSX: {self.fog_sx}
  FogSY: {self.fog_sy}
  FogZoom: {self.fog_zoom}
  PanoramaHue: {self.panorama_hue}
  PanoramaName: {self.panorama_name}
  PassageData: {"".join(escaped_chars+s for s in self.passages.data[0].split(" "))}
  PriorityData: {"".join(escaped_chars+s for s in self.priorities.data[0].split(" "))}
  TerrainTags: {"".join(escaped_chars+s for s in self.terrain_tags.data[0].split(" "))}
""")

class AudioFile:
	# name - string
	# pitch - float
	# volue - float
	def unifier_organize(self):
		pass

class EventCommand:
	# i - int
	# c - int
	# p - ??? list
	def unifier_organize(self):
		pass

class MoveRoute:
	def unifier_organize(self):
		pass

class MoveCommand:
	# code - int
	# parameters - ??? list
	def unifier_organize(self):
		pass

class MapInfo:
	# expanded - bool
	# name - string
	# order - int
	# parent_id - int
	# scroll_x - int
	# scroll_y - int
	def unifier_organize(self):
		pass

class Event:
	# id - int
	# name - string
	# pages - Page list
	# 
	def unifier_organize(self):
		pass

class Page:
	# always_on_top - bool
	# condition - Condition
	# direction_fix - bool
	# graphic - Graphic
	# list - EventCommand list
	# move_frequency - int
	# move_route - MoveRoute
	# move_speed = int
	# move_type = int
	# step_anime = bool
	# through - bool
	# trigger - int
	# walk_anime - bool
	def unifier_organize(self):
		pass

class Condition:
	# self_switch_ch - char
	# self_switch_valid - bool
	# switch1_id - int
	# switch1_valid - bool
	# switch2_id - int
	# switch2_valid - bool
	# variable_id - int
	# variable_valid - bool
	# variable_value - int
	def unifier_organize(self):
		pass

class Graphic:
	# blend_type - int
	# character_hue - int
	# character-name - string
	# direction - int
	# opacity - int
	# pattern - int
	# tile_id - int
	def unifier_organize(self):
		pass