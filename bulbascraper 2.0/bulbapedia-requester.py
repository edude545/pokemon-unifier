import bs4
import urllib.request
import time
import re

# https://stackoverflow.com/questions/13303449/urllib2-httperror-http-error-403-forbidden
hdr = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
       'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
       'Accept-Encoding': 'none',
       'Accept-Language': 'en-US,en;q=0.8',
       'Connection': 'keep-alive'}

with open("pokenames.txt", "r", encoding="utf-8") as f:
	pokenames = f.read().split(" \n")
urls = []
for name in pokenames:
	urls.append(f"https://bulbapedia.bulbagarden.net/wiki/{urllib.parse.quote(name)}_(Pok%C3%A9mon)")

# Header
learnset_csv = "game_id,pkmn,move_name,learntype,level"

def urlEncodeNonAscii(b):
    return re.sub('[\x80-\xFF]', lambda c: '%%%02x' % ord(c.group(0)), b)

errors = []
for i in range(len(urls)):
	filename = f"{pokenames[i]}.html"
	urls[i] = urls[i].replace(" ","_")
	request = urllib.request.Request(urls[i], headers=hdr)
	try:
		response = urllib.request.urlopen(request)
	except Exception as e:
		print(f"{str(e)}: No data written to {filename}")
		errors.append(filename)
		continue
	html = response.read()
	
	with open(f"bulbapedia/{filename}", "wb") as out:
		out.write(html)
		print(f"Written to {filename}")

print(f"Encountered problems with files: {errors}")