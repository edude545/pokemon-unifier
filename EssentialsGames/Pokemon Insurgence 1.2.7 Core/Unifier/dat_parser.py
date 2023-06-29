with open("../dat/trainers.dat", "rb") as f:
	raw = f.read();

items = []

def sba(ba):
	ret = ""
	cur = ""
	for b in ba:
		cur = hex(b)[2:]
		if len(cur) == 1: cur = "0"+cur
		ret += cur + " "
	print(ret[:-1])

def sbas(ba):
	ret = ""
	cur = ""
	for b in ba:
		ret += chr(b)
	print(ret)

def s(ba):
	sba(ba)
	sbas(ba)
	print("")

class Trainer:
	def __init__(self, raw):
		self.raw = raw
		self.dat1 = raw[0:4]
		self.name = ""
		raw = raw[4:]
		for i in range(len(raw)):
			if raw[i] == 0x5b:
				raw = raw[i:]
				break
			else:
				self.name += chr(raw[i])
	def show(self):
		s(self.raw)
		s(self.dat1)

begin_entry = bytearray([0x5b, 0x0a])
begin_entry_i = 0

trainers = []
current = bytearray()
# for b in raw:
# 	current.append(b)
# 	if b == begin_entry[begin_entry_i]:
# 		begin_entry_i += 1
# 		if begin_entry_i == len(begin_entry):
# 			trainers.append(Trainer(current))
# 			current = bytearray()
# 			begin_entry_i = 0
# 	else:
# 		begin_entry_i = 0
raw = raw.split(bytearray([0x5b,0x0a]))[1:]
for traw in raw:
	trainers.append(Trainer(traw))


print(f"Found {len(trainers)} entries")

#print(trainers[9].name)
trainers[9].show()