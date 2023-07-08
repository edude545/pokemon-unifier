import math

hdr = "default,name,form,type1,type2,ability1,ability2,abilityh,base stat total,hp,attack,defense,special attack,special defense,speed,group1,group2,catch_rate,egg_cycles,base_happiness,category,percentage_male,exp_group,height_m,weight_kg,pokedex,item_common,item_uncommon,item_rare,exp_yield"

gender_rates = {
	"Female50Percent" : "0.5",
	"FemaleOneEighth" : "0.875",
	"Genderless" : None,
	"Female75Percent" : "0.25",
	"Female25Percent" : "0.75",
	"AlwaysFemale" : "0",
	"AlwaysMale" : "1"
}

# abilities = {"CUTECHARM" : "Cute Charm", "OVERCOAT" : "Water Absorb", "SANDVEIL" : "Sand Veil", "FLAMEBODY" : "Flame Body", "FILTER" : "Filter", "CLOUDNINE" : "Cloud Nine", "WATERVEIL" : "Water Veil", "WATERABSORB" : "Water Absorb", "LEVITATE" : "Levitate", "DEFIANT" : "Defiant", "VENOMOUS" : "Venomous", "FRIENDGUARD" : "Friend Guard", "IRONFIST" : "Iron Fist", "STRONGJAWS" : "Strong Jaws", "BATTLEARMOR" : "Battle Armor", "PRANKSTER" : "Prankster"}

abilities = {}

def process_type(t):
	t = t.lower()
	return t[0].upper() + t[1:]

egg_groups = {
	
}

def process_pkmn(pkmn, file):
	ab = [abilities[a] for a in pkmn["Abilities"].split(",")]
	for a in ab:
		all_upper = True
		for c in a:
			if c.islower(): all_upper = False; break
		if all_upper: print(a.replace("\n",""))
	stats = pkmn["BaseStats"].split(",")
	t1 = process_type(pkmn["Type1"])
	t2 = process_type(pkmn["Type2"]) if "Type2" in pkmn else ""
	eggs = pkmn["Compatability"].split(",")
	egg1 = egg_groups[pkmn[0]]
	egg2 = egg_groups[pkmn[1]] if len(eggs) > 0 else ""
	add_record({
		"name" : pkmn["Name"],
		"type1" : t1,
		"type2" : t2,
		"ability1" : ab[0],
		"ability2" : ab[0] if len(ab) == 1 else ab[1],
		"abilityh" : abilities[pkmn["HiddenAbility"]] if "HiddenAbility" in pkmn else ab[0],
		"base stat total" : sum([int(s) for s in stats]),
		"hp" : stats[0],
		"attack" : stats[1],
		"defense" : stats[2],
		"speed" : stats[3],
		"special attack" : stats[4],
		"special defense" : stats[5],
		"catch_rate" : pkmn["Rareness"],
		"egg_cycles" : str(math.floor(int(pkmn["StepsToHatch"])/256)),
		"exp_group" : pkmn["GrowthRate"],
		"base_happiness" : pkmn["Happiness"],
		"category" : pkmn["Kind"],
		"percentage_male" : gender_rates[pkmn["GenderRate"]],
		"height_m" : pkmn["Height"],
		"weight_kg" : pkmn["Weight"],
		"exp_yield" : pkmn["BaseEXP"]
	}, file)

header_indices = {}
headers = hdr.split(",")
for i,col in enumerate(headers):
	header_indices[col] = i
row_length = len(headers)

def add_record(record_dict, file):
	record = ["" for i in range(row_length)]
	for k in record_dict:
		record[header_indices[k]] = str(record_dict[k])
	print(",".join(record))
	file.write("\n" + ",".join(record))
	#print(record)

def load_lines(filename):
	with open(f"../PBS/{filename}.txt", "r", encoding="utf-8") as f:
		return f.readlines()

def read_abilities_file():
	lines = load_lines("abilities")
	for line in lines:
		split = line.split(",")
		abilities[split[1]] = split[2]

def read_pokemon_file():
	read_abilities_file()
	lines = load_lines("pokemon")
	current = {}
	with open("../CSV/pokemon.txt", "w") as out:
		out.write(hdr)
		for line in lines:
			line = line.replace("\n","")
			if (line[0] == "["):
				if current != {}: process_pkmn(current, out)
				current = {}
				continue
			key,val = line.split("=")
			current[key] = val

read_pokemon_file()