import bs4
import urllib.request

# https://stackoverflow.com/questions/13303449/urllib2-httperror-http-error-403-forbidden
hdr = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
       'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
       'Accept-Encoding': 'none',
       'Accept-Language': 'en-US,en;q=0.8',
       'Connection': 'keep-alive'}

with open("pokenames.txt", "r") as f:
	pokenames = f.read().split(" \n")
urls = []
for name in pokenames:
	urls.append(f"https://pokemondb.net/pokedex/{name.lower()}/moves/8")

# Header
csv = "game_id,pkmn,move_name,learntype,level"

def make_record(game_id, pkmn, learntype, tr):
	# https://scrapfly.io/blog/how-to-scrape-tables-with-beautifulsoup/
	row = [el.text.strip() for el in tr.find_all("td")]
	global csv
	if learntype == "lvl":
		csv += f"\n{game_id},\"{pkmn},\"{row[1]}\",{learntype},{row[0]}"
	elif learntype == "tm" or learntype == "tr":
		csv += f"\n{game_id},\"{pkmn},\"{row[1]}\",{learntype},"
	else:
		csv += f"\n{game_id},\"{pkmn}\",\"{row[0]}\",{learntype},"

# a learntype form is a form with tabs for each regional form that represents all the different forms' learnsets for a single learntype (e.g. level, tm, tutor, egg moves etc.)
def parse_learntype_form(learntype, learntype_form):
	rawnames = [tag.text for tag in learntype_form.find("div", {"class":"sv-tabs-tab-list"}).find_all("a")]
	print(rawnames)

def parse_table(learntype, pokename, table):
	for tr_i, tr in enumerate(table.find_all("tr")):
		if tr_i != 0:
			make_record(game_id, pokename, learntype, tr)

learntypes = {
	"Moves learnt by level up" : "lvl",
	"Moves learnt by TM" : "tm",
	"Moves learnt by TR" : "tr",
	"Moves learnt on evolution" : "evo",
	"Moves learnt by reminder" : "rem",
	"Egg moves" : "egg",
	"Move Tutor moves" : "tutor"
}

# might have to use this at some point
pkmn_with_regional_forms = ["Rattata", "Raticate", "Raichu", "Sandshrew", "Sandslash", "Vulpix", "Ninetales", "Diglett", "Dugtrio", "Meowth", "Persian", "Geodude", "Graveler", "Golem", "Grimer", "Muk", "Exeggutor", "Marowak", "Ponyta", "Rapidash", "Farfetch'd", "Koffing", "Weezing", "Mr. Mime", "Corsola", "Zigzagoon", "Linoone", "Darumaka", "Darmanitan", "Yamask", "Stunfisk", "Slowpoke", "Slowbro", "Slowking", "Articuno", "Zapdos", "Moltres", "Growlithe", "Arcanine", "Voltorb", "Electrode"," Typhlosion", "Qwilfish", "Sneasel", "Samurott", "Lilligant", "Basculin", "Zorua", "Zoroark", "Braviary", "Sliggoo", "Goodra", "Avalugg", "Decidueye", "Tauros", "Wooper"]

def learntype_comparator(tag):
	return tag.name == "div" and tag.has_attr("class") and ("tabset-moves-game-form" in tag["class"] or ("grid-col" in tag.parent["class"]))

for i in [51]:
	request = urllib.request.Request(urls[i], headers=hdr)
	response = urllib.request.urlopen(request)
	html = response.read().decode("utf-8")
	soup = bs4.BeautifulSoup(html, "html.parser")
	tabset_moves_game_div = soup.find("div", {"class":"tabset-moves-game sv-tabs-wrapper"})

	game_panel_list = tabset_moves_game_div.find("div", {"class":"sv-tabs-panel-list"}, recursive=False)
	
	game_panels = game_panel_list.find_all("div", {"class":"sv-tabs-panel"}, recursive=False)
	for game_panel in game_panels:
		h3s = [el.text for el in game_panel.find_all("h3")] # Table titles, e.g. "Moves learnt by TM"
		tables = game_panel.find_all("table")
		print(len(tables))
		print(h3s)

		learntype_forms = game_panel.find_all(learntype_comparator)
		print([el["class"] for el in learntype_forms])
		for ltf in learntype_forms:
			if "tabset-moves-game-form" in ltf["class"]:
				parse_learntype_form("tm",ltf)
			else:
				parse_table("tm","Bulbasaur",ltf.find("div", {"class":"data-table"}))
		print()

with open("learnset.csv", "w") as f:
	f.write(csv)