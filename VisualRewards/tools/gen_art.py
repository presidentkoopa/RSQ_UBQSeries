#!/usr/bin/env python3
"""gen_art.py -- produce every bar image and TEXTURES.rsqthp from coldcite's Top HP Bars 1.04 art.

  Classic (set A) and Red (set B) are coldcite's own PNGs, byte for byte (renamed lumps only).
  The colour-blind and high-contrast sets are coldcite's style-A frames recoloured pixel by pixel:
  each fill pixel keeps its brightness relative to its band's mean (so his block texture stays),
  only the hue changes; on top they carry shape cues that do not depend on colour:
    mid band (40-65 %)  one darker line through the middle of every block
    low band (5-35 %)   diagonal hatching (and the bar pulses in game, see bar.zs)
  The overheal strip, its lap pips and the marker icons are drawn here, in the same block grid.

Run from anywhere: python3 tools/gen_art.py   (writes pk3/graphics/rsqthp/*.png and pk3/TEXTURES.rsqthp)
"""
import os, shutil
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SRC = os.path.join(ROOT, 'original_1.04', 'graphics')
OUT = os.path.join(ROOT, 'pk3', 'graphics', 'rsqthp')
TEX = os.path.join(ROOT, 'pk3', 'TEXTURES.rsqthp')

LEVELS = ['XX', '99'] + ['%02d' % i for i in range(95, 0, -5)] + ['00']   # frames A..V
FRAMES = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

# Palette sets.  'src' = coldcite's own style, else recoloured from style A.
# check = the simulations cvd_check.py measures this set under.
SCHEMES = [
  dict(set='A', name='Classic', src='A', high=(100,126,100), mid=(153,133,89), low=(152,88,88), over=(255,200,40)),
  dict(set='B', name='Red',     src='B', high=(138,100,100), mid=(138,100,100), low=(138,100,100), over=(255,200,40)),
  dict(set='C', name='ProDeutan', high=(86,180,233), mid=(240,228,66), low=(213,94,0), over=(250,250,255),
       invul=(150,150,150), border=(50,50,50), check=['protan','deutan']),
  dict(set='D', name='Tritan', high=(0,170,170), mid=(235,235,235), low=(220,30,60), over=(255,170,0),
       invul=(150,150,150), border=(50,50,50), check=['tritan']),
  dict(set='E', name='HighContrast', high=(255,255,255), mid=(255,220,0), low=(255,70,0), over=(0,230,255),
       invul=(170,170,170), border=(255,255,255), back=(0,0,0,150), check=['protan','deutan','tritan']),
]

def band_of(level):
    if level == 'XX': return 'invul'
    if level == '00': return None
    v = int(level)
    if v >= 70: return 'high'
    if v >= 40: return 'mid'
    return 'low'

def luma(p): return 0.299*p[0] + 0.587*p[1] + 0.114*p[2]

def load(style, level):
    return Image.open(os.path.join(SRC, 'HP_%s_%s.png' % (style, level))).convert('RGBA')

def band_means():
    """mean luma of the opaque fill pixels of each band in style A (measured off his frames)."""
    out = {}
    for band, lvl in (('high', '90'), ('mid', '60'), ('low', '30'), ('invul', 'XX')):
        im = load('A', lvl); px = im.load(); s = n = 0
        for y in range(1, 10):
            for x in range(1, 111):
                p = px[x, y]
                if p[3] >= 254: s += luma(p); n += 1
        out[band] = s / n
    return out

def recolour(level, sc, means):
    im = load('A', level); px = im.load(); w, h = im.size
    band = band_of(level)
    tgt = sc.get(band) if band != 'invul' else sc['invul']
    border = sc['border']; back = sc.get('back')
    o = Image.new('RGBA', (w, h)); op = o.load()
    for y in range(h):
        for x in range(w):
            p = px[x, y]
            edge = x == 0 or x == w-1 or y == 0 or y == h-1
            if edge:
                op[x, y] = border + (p[3],) if p[3] else (0, 0, 0, 0)
            elif p[3] == 0:
                op[x, y] = back if back else (0, 0, 0, 0)
            elif back and (x == 1 or x == w-2 or y == 1 or y == h-2):
                op[x, y] = back   # high contrast: a dark 1 px inset, so a white fill never merges with the white rim
            elif p[3] < 254:      # coldcite's half-step "ghost" block: flat band colour, see-through
                a = p[3] if not back else max(p[3], 110)
                c = tgt
                if back:          # over the dark backing: blend so it stays readable
                    op[x, y] = tuple(int(c[i]*a/255 + back[i]*(1-a/255)) for i in range(3)) + (max(a, back[3]),)
                else:
                    op[x, y] = c + (a,)
            else:
                k = luma(p) / means[band]
                c = [min(255, int(round(t * k))) for t in tgt]
                if band == 'mid' and y == 5:
                    c = [int(v * 0.35) for v in c]
                if band == 'low' and (x + y) % 4 == 0:
                    c = [int(v * 0.45) for v in c]
                op[x, y] = tuple(c) + (255,)
    return o

def strip(sc, fill20):
    """overheal strip: 112x5, coldcite's border, 10 blocks of 11 px, chevrons; odd steps = ghost."""
    border = sc.get('border', (50, 50, 50)); back = sc.get('back'); c = sc['over']
    im = Image.new('RGBA', (112, 5), (0, 0, 0, 0)); px = im.load()
    for x in range(112):
        px[x, 0] = border + (255,); px[x, 4] = border + (255,)
    for y in range(5):
        px[0, y] = border + (255,); px[111, y] = border + (255,)
    whole = fill20 // 2; half = fill20 % 2
    for y in range(1, 4):
        for x in range(1, 111):
            blk = (x - 1) // 11; col = (x - 1) % 11
            if blk < whole:
                v = list(c)
                chev = (col + (1 if y == 2 else 0)) % 4 == 0      # ">" chevrons every 4 px
                if col == 10: v = [int(t * 0.55) for t in v]       # block seam, as his blocks have
                elif chev: v = [int(t * 0.62) for t in v]
                px[x, y] = tuple(v) + (255,)
            elif blk == whole and half:
                px[x, y] = tuple(c) + (90,)
            elif back:
                px[x, y] = back
    return im

def pip(sc):
    """one lap pip: a 5x5 diamond in the overheal colour with a dark rim."""
    c = sc['over']; rim = (20, 20, 20, 255)
    im = Image.new('RGBA', (5, 5), (0, 0, 0, 0)); px = im.load()
    for y in range(5):
        for x in range(5):
            d = abs(x - 2) + abs(y - 2)
            if d <= 1: px[x, y] = c + (255,)
            elif d == 2: px[x, y] = rim
    return im

# marker icons, 9x9: '#' rim (black), 'o' colour, '.' clear.  Four different SHAPES, so no colour is needed.
ICONS = [
  ('hooked',  (235, 235, 245), [   # a hook
    '...###...', '..#ooo#..', '..#o#o#..', '...#.#o#.', '.....#o#.', '.##..#o#.', '#o#.#oo#.', '#oooooo#.', '.######..']),
  ('stunned', (255, 225, 40), [    # a star
    '....#....', '...#o#...', '####o####', '#ooooooo#', '.#ooooo#.', '..#ooo#..', '.#oo#oo#.', '.#o#.#o#.', '.##...##.']),
  ('locked',  (255, 70, 60), [     # a reticle
    '..#####..', '.#ooooo#.', '#o##o##o#', '#o#.o.#o#', '#oooooo o#'.replace(' ', '')[:9], '#o#.o.#o#', '#o##o##o#', '.#ooooo#.', '..#####..']),
  ('gripped', (120, 190, 255), [   # a claw: three fingers and a palm
    '#.#.#.#..', 'o#o#o#o#.', 'o#o#o#o#.', 'o#o#o#o#.', '#ooooooo#', '#ooooooo#', '.#ooooo#.', '..#ooo#..', '...###...']),
]

# status icons (owner's picks 36 and 37, 2026-10-31), 9x9 like the markers, one at a time, RIGHT of the bar
# (sprite RSYF): A frozen = a snowflake (held in a hit-stop: its freezetics), B held = a padlock (RSQ DistanceGrab's
# Headlock or human shield). Different SHAPES again, so no colour is needed.
STATUS = [
  ('frozen', (150, 220, 255), [    # a snowflake: three crossed strokes
    '.#.###.#.', '#o##o##o#', '.#o#o#o#.', '.##ooo##.', '#ooooooo#', '.##ooo##.', '.#o#o#o#.', '#o##o##o#', '.#.###.#.']),
  ('held',    (255, 150, 40), [    # a padlock
    '..#####..', '.#ooooo#.', '.#o#.#o#.', '#########', '#ooooooo#', '#ooo#ooo#', '#ooo#ooo#', '#ooooooo#', '#########']),
]
# RAISED (owner's QoL pick HP8, 2026-10-31): an Arch-Vile brought it back. An upward arrow, a third shape, 9x9 again;
# it stays for the monster's life, in the slot right of the status icon (frames C..E: raised alone / + frozen / + held).
RAISED = ('raised', (200, 140, 255), [
    '....#....', '...#o#...', '..#ooo#..', '.#ooooo#.', '###ooo###', '..#ooo#..', '..#ooo#..', '..#ooo#..', '..#####..'])
# MINIBOSS (2026-11-01, #16): RSQ_Miniboss's set piece, asked through its service (RSQMB_Service "miniboss" /
# "thrall"). Sprite RSYI, ABOVE the bar's centre, clear of the overheal strip: A the miniboss = a crown, B its thrall =
# a chain link. Two more shapes, so no colour is needed.
BOSSMARK = [
  ('miniboss', (255, 200, 40), [   # a crown
    '#...#...#', '#o#.#o#.#', '#oo#ooo##', '#ooooooo#', '#ooooooo#', '#o#o#o#o#', '#ooooooo#', '#ooooooo#', '#########']),
  ('thrall',   (200, 200, 210), [  # a chain link
    '..#####..', '.#ooooo#.', '#oo###oo#', '#o#...#o#', '#o#...#o#', '#o#...#o#', '#oo###oo#', '.#ooooo#.', '..#####..']),
]
# THE 11-05 ICONS (owner-approved mock-up, 2026-11-05: scratchpad icons/mock.py NEW and PIP). Same rules: black rim, one
# colour, a distinct SHAPE each.
#   whipped    a coiled lash, a 5th MARKER bit (16) left of the bar: RSQ Whip's wrap / lasso / bola (it used to borrow hooked)
#   ally       a heart, right of the bar on every friendly monster's bar (a cue that is not the blue colour alone)
#   burning    a flame, right of the bar while fire damage keeps landing on it (BD22's flamethrower, fire on the ground...)
#   legendary  a gem, above the bar (where the crown goes) on a LegenDoom legendary that has turned
#   tier pips  0-4 gold 5x5 pips right of the crown, one per Bossfight tier (RSQMB_Service "tier" 0..4; owner 11-05:
#              tier 0 = the bare crown, tier 4 = 4 pips)
WHIPPED = ('whipped', (190, 130, 70), [
    '..####...', '.#oooo#..', '#o####o#.', '#o#..#o#.', '.#o##o#..', '..#oo#...', '.#o##o#..', '#o#..#o#.', '###..###.'])
ALLY = ('ally', (90, 160, 255), [
    '.##...##.', '#oo#.#oo#', '#ooo#ooo#', '#ooooooo#', '#ooooooo#', '.#ooooo#.', '..#ooo#..', '...#o#...', '....#....'])
BURNING = ('burning', (255, 95, 20), [
    '....#....', '...#o#...', '..#oo#.#.', '..#ooo#o#', '.#oooo#o#', '#ooo#ooo#', '#oo#.#oo#', '#oo#.#oo#', '.#######.'])
LEGENDARY = ('legendary', (255, 95, 210), [
    '....#....', '...#o#...', '..#ooo#..', '.#oo#oo#.', '#oo#.#oo#', '.#oo#oo#.', '..#ooo#..', '...#o#...', '....#....'])
TIER_PIP = ((255, 200, 40), ['.###.', '#ooo#', '#ooo#', '#ooo#', '.###.'])

# FRIENDLY (owner's QoL pick HP2, an option): coldcite's Red set (B) with red and blue swapped, so allies read blue
# with his block texture and border kept. Sprite RSYG, frames as the main sets.
FRIEND_SRC = 'B'

def icon(rows, c):
    im = Image.new('RGBA', (len(rows[0]), len(rows)), (0, 0, 0, 0)); px = im.load()
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch == '#': px[x, y] = (15, 15, 15, 255)
            elif ch == 'o': px[x, y] = c + (255,)
    return im

def main():
    if os.path.isdir(OUT): shutil.rmtree(OUT)
    os.makedirs(OUT)
    means = band_means()
    tex = ['// GENERATED by tools/gen_art.py from coldcite\'s Top HP Bars 1.04 art -- do not hand-edit.',
           '// Main bar: sprite RSY<set>, frames A..V = %s.' % ' '.join(LEVELS),
           '// Overheal: sprite RS<set 1-5><pips 0-4>, frames A..T = 5..100 %% of the strip.',
           '// Markers: sprite RSYZ, frames A..O = bit mask 1..15 (1 hooked, 2 stunned, 4 locked, 8 gripped);',
           '//   sprite RSYW, frames A..P = whipped (bit 16) + mask 0..15 (whipped nearest the bar, the rest packed outward).',
           '// Status: sprite RSYF, frame = s + 3 * (raised + 2 * (burning + 2 * ally)) - 1, s 0 none / 1 frozen / 2 held:',
           '//   A frozen, B held, C raised, D frozen + raised, E held + raised, ... W ally + held + burning + raised.',
           '//   Laid out from the bar outward: ally, raised, frozen or held, burning (the lasting ones nearest the bar).',
           '// Friendly main bar: sprite RSYG (frames as RSYA). Damage chunk: sprite RSYH, frame A.',
           '// Above the bar: sprite RSYI, A crown (miniboss), B chain link (thrall), C gem (legendary), D crown + gem,',
           '//   E link + gem, F..I crown + 1..4 tier pips, J..M crown + 1..4 pips + gem (gem left of the crown, pips right).', '']
    for si, sc in enumerate(SCHEMES):
        s = sc['set']
        for fi, lvl in enumerate(LEVELS):
            lump = 'RQM%s%s' % (s, lvl)
            if sc.get('src'):
                shutil.copyfile(os.path.join(SRC, 'HP_%s_%s.png' % (sc['src'], lvl)), os.path.join(OUT, lump + '.png'))
            else:
                recolour(lvl, sc, means).save(os.path.join(OUT, lump + '.png'))
            tex += ['Sprite "RSY%s%s0", 112, 11' % (s, FRAMES[fi]), '{', '\tOffset 56, 11', '\tPatch "%s", 0, 0' % lump, '}']
        for f in range(1, 21):
            strip(sc, f).save(os.path.join(OUT, 'RQO%s%02d.png' % (s, f * 5 if f < 20 else 99)))
        pip(sc).save(os.path.join(OUT, 'RQP%s.png' % s))
        for p in range(5):
            for f in range(1, 21):
                tex += ['Sprite "RS%d%d%s0", 137, 5' % (si + 1, p, FRAMES[f - 1]), '{', '\tOffset 56, 17',
                        '\tPatch "RQO%s%02d", 0, 0' % (s, f * 5 if f < 20 else 99)]
                tex += ['\tPatch "RQP%s", %d, 0' % (s, 113 + 6 * i) for i in range(p)]
                tex += ['}']
    for k, (name, c, rows) in enumerate(ICONS):
        icon(rows, c).save(os.path.join(OUT, 'RQK%d.png' % (k + 1)))
    for bits in range(1, 16):
        # drawn at TWICE the bar's scale (bar.zs), so in bar pixels: right edge 2 px left of the bar,
        # centred on its height -> offset (40 + 58/2, 5.5/2 + 4.5)
        tex += ['Sprite "RSYZ%s0", 40, 9' % FRAMES[bits - 1], '{', '\tOffset 69, 7']
        tex += ['\tPatch "RQK%d", %d, 0' % (k + 1, 31 - 10 * k) for k in range(4) if bits & (1 << k)]
        tex += ['}']
    # WHIPPED (bit 16): sprite RSYW, frame = the other four bits (0..15). Five slots, 10 icon px apart, the whipped lash in
    # the slot nearest the bar (where hooked sits in RSYZ), then the others in bit order outward, packed.
    icon(WHIPPED[2], WHIPPED[1]).save(os.path.join(OUT, 'RQK5.png'))
    for bits in range(16):
        tex += ['Sprite "RSYW%s0", 50, 9' % FRAMES[bits], '{', '\tOffset 79, 7', '\tPatch "RQK5", 41, 0']
        slot = 1
        for k in range(4):
            if bits & (1 << k):
                tex += ['\tPatch "RQK%d", %d, 0' % (k + 1, 41 - 10 * slot)]; slot += 1
        tex += ['}']
    for k, (name, c, rows) in enumerate(STATUS):
        icon(rows, c).save(os.path.join(OUT, 'RQS%d.png' % (k + 1)))
    icon(RAISED[2], RAISED[1]).save(os.path.join(OUT, 'RQS3.png'))
    icon(ALLY[2], ALLY[1]).save(os.path.join(OUT, 'RQS4.png'))
    icon(BURNING[2], BURNING[1]).save(os.path.join(OUT, 'RQS5.png'))
    # Twice the bar's scale like the markers: the first icon's left edge 2 px right of the bar (56 + 2 = 58 bar px = 29 icon
    # px), centred on its height (offset y as the markers'). The sprite starts AT the bar's centre (offset 0) and the icons
    # sit 29 px into it, 10 px apart: a negative x offset (-29, the icon alone) drew nothing on the rig.
    # frame = s + 3 * (raised + 2 * (burning + 2 * ally)) - 1 (A..E are the frames as they were before 11-05)
    for f in range(1, 24):
        st, r, b, a = f % 3, (f // 3) % 2, (f // 6) % 2, (f // 12) % 2
        lumps = []
        if a: lumps.append('RQS4')
        if r: lumps.append('RQS3')
        if st: lumps.append('RQS%d' % st)
        if b: lumps.append('RQS5')
        tex += ['Sprite "RSYF%s0", %d, 9' % (FRAMES[f - 1], 29 + 10 * len(lumps) - 1), '{', '\tOffset 0, 7']
        tex += ['\tPatch "%s", %d, 0' % (l, 29 + 10 * i) for i, l in enumerate(lumps)]
        tex += ['}']
    # miniboss marks: twice the bar's scale like the other icons; centred across (offset x 4 of 9), bottom 10 icon px
    # (20 bar px) above the bar's origin, which is 3 px above the overheal strip's top (17 bar px)
    # 11-05: one sprite, 43 icon px wide, its origin the crown's centre (x 14): gem 0..8, crown / link / lone gem 10..18,
    # tier pips at 20, 26, 32, 38 (5 px, 1 px apart), 3 px down from the icon's top (the mock-up's placement). So the crown
    # stays where it was over the bar, a legendary miniboss's gem sits LEFT of it and its pips RIGHT: nothing overlaps.
    for k, (name, c, rows) in enumerate(BOSSMARK):
        icon(rows, c).save(os.path.join(OUT, 'RQB%d.png' % (k + 1)))
    icon(LEGENDARY[2], LEGENDARY[1]).save(os.path.join(OUT, 'RQB3.png'))
    icon(TIER_PIP[1], TIER_PIP[0]).save(os.path.join(OUT, 'RQB4.png'))
    top = [('RQB1', 0, 0), ('RQB2', 0, 0), ('RQB3', 0, 0), ('RQB1', 1, 0), ('RQB2', 1, 0)]   # A..E: (centre icon, gem, pips)
    top += [('RQB1', 0, n) for n in (1, 2, 3, 4)] + [('RQB1', 1, n) for n in (1, 2, 3, 4)]   # F..I, J..M
    for f, (mid, gem, pips) in enumerate(top):
        tex += ['Sprite "RSYI%s0", 43, 9' % FRAMES[f], '{', '\tOffset 14, 19', '\tPatch "%s", 10, 0' % mid]
        if gem: tex += ['\tPatch "RQB3", 0, 0']
        tex += ['\tPatch "RQB4", %d, 3' % (20 + 6 * i) for i in range(pips)]
        tex += ['}']
    # friendly set (HP2): coldcite's B with R and B swapped
    for fi, lvl in enumerate(LEVELS):
        lump = 'RQMF%s' % lvl
        im = Image.open(os.path.join(SRC, 'HP_%s_%s.png' % (FRIEND_SRC, lvl))).convert('RGBA')
        r, g, b, a = im.split()
        Image.merge('RGBA', (b, g, r, a)).save(os.path.join(OUT, lump + '.png'))
        tex += ['Sprite "RSYG%s0", 112, 11' % FRAMES[fi], '{', '\tOffset 56, 11', '\tPatch "%s", 0, 0' % lump, '}']
    # damage chunk (HP1, an option): one white column the height of the bar's inside (rows 1..9); the bar stretches it
    # across the lost health (bar.zs) and puts its left edge there, so the offset is x 0, y 10 (bar origin = bottom)
    Image.new('RGBA', (1, 9), (255, 255, 255, 255)).save(os.path.join(OUT, 'RQCH.png'))
    tex += ['Sprite "RSYHA0", 1, 9', '{', '\tOffset 0, 10', '\tPatch "RQCH", 0, 0', '}']
    open(TEX, 'w').write('\n'.join(tex) + '\n')
    print('wrote', len(os.listdir(OUT)), 'images and', TEX)

if __name__ == '__main__':
    main()
