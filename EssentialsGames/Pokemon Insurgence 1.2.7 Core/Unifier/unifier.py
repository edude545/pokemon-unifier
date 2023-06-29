import yaml, base64, rpg, sys, json
from yaml.loader import Loader

# rtpo = {
# 	"!ruby/object:RPG::Map" 						: "!!python/object:RPG.Map",
# 	"!ruby/object:RPG::AudioFile" 					: "!!python/object:RPG.AudioFile",
# 	"!ruby/object:Table" 							: "!!python/object:__main__.Table",
# 	"!ruby/object:RPG::Event" 						: "!!python/object:RPG.Event.Event",
# 	"!ruby/object:RPG::Event::Page" 				: "!!python/object:RPG.Event.Page.Page",
# 	"!ruby/object:RPG::Event::Page::Condition" 		: "!!python/object:RPG.Event.Page.Condition",
# 	"!ruby/object:RPG::Event::Page::Graphic" 		: "!!python/object:RPG.Event.Page.Graphic",
# 	"!ruby/object:RPG::EventCommand" 				: "!!python/object:RPG.EventCommand",
# 	"!ruby/object:RPG::MoveRoute" 					: "!!python/object:RPG.MoveRoute",
# 	"!ruby/object:RPG::MoveCommand" 				: "!!python/object:RPG.MoveCommand",
# 	"!ruby/object:Tone" 							: "!!python/object:__main__.Tone",
# 	"!ruby/object:RPG::MapInfo"						: "!!python/object:RPG.MapInfo",
# 	"!ruby/object:Color"							: "!!python/object:__main__.Color",
# 	"!ruby/object:RPG::Tileset"						: "!!python/object:RPG.Tileset"
# }


rtpo = {
	"!ruby/object:RPG::MapInfo"						: "!!python/object:rpg.MapInfo",
	"!ruby/object:RPG::Map" 						: "!!python/object:rpg.Map",
	"!ruby/object:RPG::AudioFile" 					: "!!python/object:rpg.AudioFile",
	"!ruby/object:Table" 							: "!!python/object:rpg.Table",
	"!ruby/object:RPG::Event::Page::Condition" 		: "!!python/object:rpg.Condition",
	"!ruby/object:RPG::Event::Page::Graphic" 		: "!!python/object:rpg.Graphic",
	"!ruby/object:RPG::Event::Page" 				: "!!python/object:rpg.Page",
	"!ruby/object:RPG::EventCommand" 				: "!!python/object:rpg.EventCommand",
	"!ruby/object:RPG::Event" 						: "!!python/object:rpg.Event",
	"!ruby/object:RPG::MoveRoute" 					: "!!python/object:rpg.MoveRoute",
	"!ruby/object:RPG::MoveCommand" 				: "!!python/object:rpg.MoveCommand",
	"!ruby/object:Tone" 							: "!!python/object:rpg.Tone",
	"!ruby/object:Color"							: "!!python/object:rpg.Color",
	"!ruby/object:RPG::Tileset"						: "!!python/object:rpg.Tileset"
}

ruby_to_python_objects = {}
for k in rtpo:
	ruby_to_python_objects[k+"\n"] = rtpo[k] + "\n"
	ruby_to_python_objects[k+" "] = rtpo[k] + " "

# The unpacked YAML files have references to Ruby/RPGMaker classes.
# This function replaces them with references to the respective Python classes, which have been reconstructed in the rpg module.
def pythonize(filename, msg=True):
	if msg: print(f"Pythonizing class names in {filename}.yaml...")
	with open(f"../YAML/{filename}.yaml","r") as inp:
		s = inp.read()
	for k in ruby_to_python_objects:
		s = s.replace(k, ruby_to_python_objects[k])
	s = s.replace("!binary","!!binary")
	with open(f"../YAML-processed/{filename}.yaml","w") as out:
		out.write(s)
	if msg: print("Done")

def derubyize(filename, msg=True):
	if msg: print(f"Removing class references in {filename}.yaml...")
	with open(f"../YAML/{filename}.yaml","r") as inp:
		s = inp.read()
	for k in rtpo:
		s = s.replace(k, "")
	s = s.replace("!binary", "")
	with open(f"../YAML-processed/{filename}.yaml","w") as out:
		out.write(s)
	if msg: print("Done")

# Loads a YAML. It must be processed, i.e. either pythonized or derubyized.
def load(filename):
	with open(f"../YAML-processed/{filename}.yaml","r") as f:
		return yaml.load(f.read(),Loader)

def recursive_organize(obj):
	if hasattr(obj,"unifier_organize"):
		obj.unifier_organize()
		for field in dir(obj):
			if field[0] != '_':
				attr = getattr(obj,field)
				if type(attr) is dict:
					for val in attr.values():
						if type(val) is not type:
							recursive_organize(val)
				elif type(attr) is list:
					for el in attr:
						if type(el) is not type:
							recursive_organize(el)
				elif type(attr) is not type:
					recursive_organize(attr)
	
def mapnames():
	for i in range(1,833):
		yield "Map"+"0"*(3-len(str(i)))+str(i)

def pythonize_maps():
	print("Pythonizing maps, this may take a while...")
	for mn in mapnames():
		pythonize(mn, msg=False)
	print("Done")

def derubyize_maps():
	print("Derubyizing maps, this may take a while...")
	for mn in mapnames():
		derubyize(mn, msg=False)
	print("\nDone")

def generate_map_asset(filename, mapinfo, msg=True):
	mapyaml = load(filename)
	recursive_organize(mapyaml)
	mapyaml.expanded = mapinfo.expanded
	name = mapinfos[i].name
	mapyaml.name = str(name,"utf-8") if type(name) is bytes else name
	mapyaml.order = mapinfos[i].order
	mapyaml.parent_id = mapinfo.parent_id
	mapyaml.scroll_x = mapinfo.scroll_x
	mapyaml.scroll_y = mapinfo.scroll_y
	mapyaml.id = i
	mapyaml.generate_unity_asset(msg=msg)

def generate_all_map_assets(msg=True):
	mapinfos = load("MapInfos.yaml")
	for i,mn in enumerate(mapnames()):
		generate_map_asset(mn, mapinfos[i], msg=msg)

def convert_to_json(filename, msg=True):
	print(f"Converting {filename}.yaml to json...")
	with open(f"../JSON/{filename}.json", "w") as out:
		out.write(json.dumps(load(filename), indent="\t"))
	print("Done")

def make_map_jsons():
	print("Making map jsons for Unity...")
	for mn in mapnames():
		convert_to_json(mn, msg=False)
	print("Done!")

# ===== ===== ===== ===== ===== 

# pythonize_object_names("MapInfos.yaml")
# mapinfos = load("MapInfos.yaml")
# for k in mapinfos:
# 	mapinfos[k].id = k
# 	recursive_organize(mapinfos[k])
# 	mapinfos[k].generate_unity_asset()

# ===== ===== ===== ===== =====

# pythonize_object_names("Tilesets.yaml")
# tilesets = load("Tilesets.yaml")
# for i in range(len(tilesets)):
# 	if (tilesets[i]) is not None:
# 		tilesets[i].id = i
# 		recursive_organize(tilesets[i])
# 		tilesets[i].generate_unity_asset()

# ===== ===== ===== ===== =====

def run_unifier(args):
	if args[0] == "pythonize":
		if args[1] == "maps":
			print("test")
			pythonize_maps()
		else:
			pythonize(args[1])
	elif args[0] == "derubyize":
		if args[1] == "maps":
			derubyize_maps()
		else:
			derubyize(args[1])
	elif args[0] == "makejson":
		if args[1] == "maps":
			make_map_jsons()
		else:
			convert_to_json(args[1])
	# elif args[0] == "makeassets":
	# 	if args[1] == "maps":
	# 		generate_all_map_assets()
	# 	else:
	# 		print(f"Argument {args[1]} not recognized")

def run(s):
	run_unifier(s.split(" "))

# run("derubyize maps")
# run("makejson maps")
# run("derubyize MapInfos")
# run("makejson MapInfos")
run("derubyize Tilesets")
run("makejson Tilesets")