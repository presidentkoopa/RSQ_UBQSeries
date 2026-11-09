import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from variants_v3 import *
from look import grid
w = sys.argv[1]
f, p = V3c(w); print(len(f), grid(f, p, f'v3c_{w}', -1, 30, 8, (150, 0, 450, f[0].height)))
