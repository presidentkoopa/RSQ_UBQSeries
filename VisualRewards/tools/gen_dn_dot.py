"""gen_dn_dot.py -- the damage numbers' decimal point (2026-11-06, RSQ SlowMo's DOWN "+0.5s"): JFO's metal digits (J) and
JFO small (S) have no '.' (code 2E). It is cut from each font's own '+' glyph: the crossing of its two bars (the bar's
width, with the glow round it), set on the digits' baseline in a narrow cell of the same height. Writes
pk3/graphics/rsqthpdn/RQN<J|S><0|1>2E.png. Run: python3 tools/gen_dn_dot.py"""
import os, sys
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from gen_dn_art import grab, OUT

def dot(font, q):
    plus = Image.open(os.path.join(OUT, 'RQN%s%d2B.png' % (font, q))).convert('RGBA')
    zero = Image.open(os.path.join(OUT, 'RQN%s%d30.png' % (font, q))).convert('RGBA')
    W, H = plus.size
    a = W * 12 // 64 if W >= 32 else max(2, W * 14 // 64)   # half the square: the bar's half-width plus its glow
    cx, cy = W // 2, H // 2
    sq = plus.crop((cx - a, cy - a, cx + a, cy + a))
    bottom = zero.getbbox()[3]                             # the digits' baseline (with its glow)
    cell = Image.new('RGBA', (2 * a + 2, H), (0, 0, 0, 0))
    cell.paste(sq, (1, bottom - 2 * a))
    name = 'RQN%s%d2E' % (font, q)
    p = os.path.join(OUT, name + '.png')
    cell.save(p, optimize=True)
    grab(p, cell.width // 2, cell.height // 2)
    print('wrote', name, cell.size)

for f in ('J', 'S'):
    for q in (0, 1):
        dot(f, q)
