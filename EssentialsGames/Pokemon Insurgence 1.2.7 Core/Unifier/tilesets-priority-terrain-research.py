import yaml
from yaml.loader import Loader
import rpg

def load(filename):
	with open("../YAML-pythonized/"+filename,"r") as f:
		return yaml.load(f.read(),Loader)

def flatten_table(table):
	return table.data[0]

file = load("Tilesets.yaml")

ins_outside = file[1]

priorities = flatten_table(ins_outside.priorities)
terrain_tags = flatten_table(ins_outside.terrain_tags)

print(priorities)
print()
print(terrain_tags)


# TODO: Go back to unifier.py and repythonize all the dumped YAML files. Having to mimic the RPGMaker class hierarchy is really annoying.
# Also TODO: It's probably not good to keep making these shitty little research scripts. Should look into Tkinter and try making something like PKHeX.
# It would be really helpful to display ID/priority/terraintag data alongside the actual tile sprite.
# Or maybe figure out a way to do this in unity since the tile lookup code is already there