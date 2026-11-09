import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from variants_v2 import *
from look import grid
w = sys.argv[1]
if w == '1': f, p = V1b(); print(grid(f, p, 'v1b', -1, 26, 9, (150, 60, 450, 630)))
if w == '2': f, p = V2b(); print(grid(f, p, 'v2b', -1, 35, 9, (150, 0, 450, 720)))
if w == '3': f, p = V3b(); print(grid(f, p, 'v3b', -1, 30, 10, (150, 0, 450, 750)))
if w == '4': f, p = V4b(); print(grid(f, p, 'v4b', -1, 72, 9, (0, 0, 720, 720)))
