from nrlmsise_00 import *

inp = nrlmsise_input()

inp.doy = 1
inp.sec = 43200

inp.alt = 500

inp.g_lat = 0
inp.g_long = 0
inp.lst = 12

inp.f107 = 150
inp.f107A = 150
inp.ap = 4

flags = nrlmsise_flags()

for i in range(24):
    flags.switches[i] = 1

out = nrlmsise_output()

gtd7(inp, flags, out)

print(out.d[5])
print(out.t[0])
print(out.t[1])