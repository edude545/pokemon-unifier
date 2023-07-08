import bs4
import os

#filenames = os.listdir("bulbapedia")
filenames = ["Raichu.html"]

for filename in filenames:
	with open(f"bulbapedia/{fn}", "r") as html:
		soup = bs4.BeautifulSoup(html, "html.parser")

def parse_levelup_table(table, pokename):
	pass

def parse_tm_table(table, pokename):
	pass

def parse_egg_move_table(table, pokename):
	pass

def parse_prior_evo_table(table, pokename):
	pass

def parse_tutor_table(table, pokename):
	pass

