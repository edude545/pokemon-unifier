import yaml
from yaml.loader import Loader

with open("../YAML-processed/Map018.yaml", "r") as f:
	map018 = yaml.load(f.read(),Loader)

obj = map018["events"][1]["pages"][0]["list"][2]

print(obj)
print()