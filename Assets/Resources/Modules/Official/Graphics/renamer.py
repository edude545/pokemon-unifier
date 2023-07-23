import os

path = "gen8/icons/small"

filenames = os.listdir(path)

print(filenames)

for fn in filenames:
	newfn = "icon" + fn.replace("_g","-Gigantamax")
	print(f"{fn} ==> {newfn}")
	os.rename(f"{path}/{fn}", f"{path}/{newfn}")