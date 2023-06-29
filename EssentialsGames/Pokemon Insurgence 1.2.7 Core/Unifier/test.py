print("=: digit denotes autotile/tileset membership (3 bits)")
print("-: digit denotes spritesheet samples (5 bits)")
print("       ===_____")
for hx in [0x60, 0x61, 0x62, 0x64, 0x68, 0x70, 0x74, 0x78, 0x7c]:
	binstr = bin(hx).replace("0b","00000000")
	hexstr = hex(hx)
	print(binstr,hexstr)
	# print(" "+binstr[-2])
	# print(binstr[-1]+binstr[-3]+binstr[-4])
	# print(" "+binstr[-5])

def pixel_coord_to_index(xpx, ypx):
	xtile = xpx // 32; ytile = ypx // 32
	print(f"{xtile} from left, {ytile} from top")
	index = ytile * 8 + xtile
	print(f"index: {index}")
	return index

def index_to_pixel_coord(index):
	ytile = index // 8
	xtile = index % 8
	ypx = ytile * 32
	xpx = xtile * 32
	print(f"{xtile} from left, {ytile} from top, or in pixels:")
	print(f"{xpx} from left, {ypx} from top")


def test(xpx, ypx):
	index_to_pixel_coord(pixel_coord_to_index(xpx,ypx))
	print("")

test(128, 10816)
test(32, 0)
test(1, 32)
test(160, 544)

def twos(val, bytes):
    import sys
    b = val.to_bytes(bytes, byteorder=sys.byteorder, signed=False)                                                          
    return int.from_bytes(b, byteorder=sys.byteorder, signed=True)

print(twos(2147483647, 4))

def numberToBase(n, b):
    if n == 0:
        return "0"
    digits = []
    while n:
        digits.append(int(n % b))
        n //= b
    return "".join(str(d) for d in digits[::-1])

for i in range(48):
	print(numberToBase(i,2))