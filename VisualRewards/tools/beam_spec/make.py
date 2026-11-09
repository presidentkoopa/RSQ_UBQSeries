import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from variants import *
from look import grid
which = sys.argv[1:] or ['1','2','3','4']
F = {'1': ('V1_eos', V1), '2': ('V2_arcade', V2), '3': ('V3_zpillar', V3), '4': ('V4_boss', V4)}
for w in which:
    name, fn = F[w]; fr, pre = fn()
    save_gif(fr, f'{OUT}/{name}_full.gif'); save_gif(fr, f'{OUT}/{name}_half.gif', half=True)
    print(name, len(fr), 'frames, effect starts at frame', pre)
