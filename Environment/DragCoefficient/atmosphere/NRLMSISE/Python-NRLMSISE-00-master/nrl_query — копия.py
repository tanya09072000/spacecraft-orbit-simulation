from nrlmsise_00 import *
from nrlmsise_00_header import *
from datetime import datetime

import sys
import json

alt = float(sys.argv[1])

date_str = sys.argv[2]

lat = float(sys.argv[3])
lon = float(sys.argv[4])

f107  = float(sys.argv[5])
f107a = float(sys.argv[6])
ap    = float(sys.argv[7])

dt = datetime.strptime(date_str,"%Y-%m-%d %H:%M:%S")
doy = dt.timetuple().tm_yday

inp = nrlmsise_input()

inp.doy = doy
inp.sec = (dt.hour*3600+ dt.minute*60+ dt.second)

inp.alt = alt

inp.g_lat = lat
inp.g_long = lon
ut = inp.sec / 3600.0
inp.lst = (ut + lon/15.0) % 24.0

inp.f107 = f107
inp.f107A = f107a
inp.ap = ap

flags = nrlmsise_flags()

for i in range(24):
    flags.switches[i] = 1

out = nrlmsise_output()

gtd7(inp, flags, out)

masses = [4,16,28,32,40,1,14]

n = [
    out.d[0],
    out.d[1],
    out.d[2],
    out.d[3],
    out.d[4],
    out.d[6],
    out.d[7]
]

N = sum(n)

if N > 0:
    ammw = sum(m*x for m,x in zip(masses,n))/N
else:
    ammw = 28.97

result = {
    "rho": out.d[5],
    "tinf": out.t[0],
    "tlocal": out.t[1],
    "ammw": ammw
}

print(json.dumps(result))