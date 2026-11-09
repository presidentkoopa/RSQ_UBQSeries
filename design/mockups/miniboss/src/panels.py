"""RSQ Miniboss rework mockups (design only; nothing of the rework is built). python3 -I panels.py p1 .. p7 sheet
Composited the way the arcade-language panels are (design/mockups/arcade_language): real rig frames + the series' own
fonts and HUD art, drawn where they would sit. Text only in the series' fonts (afonts.py, decoded from the real files).
Backgrounds: bg/ = rig frames (QuestZDoom 17.3 rig, left eye, 960 px), 2026-11-09, Doom II MAP02, the full load order;
a 1.25x MeatGrinder baron (RS_MGBaron, Purple) with three ColorfulHell imps, spawned by a test-only probe; the room glow
from RSQ Glow In The Dark's own events (event.wave / event.tint), the tier flash from RSQ Monsters' own retier.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image, ImageDraw, ImageFilter, ImageChops, ImageEnhance
import afonts as F
from comp import *

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)
REPO = '/home/claude/rsq_ubqseries'
def fr(n): return load(os.path.join(HERE, 'bg', 'f%05d.jpg' % n))
SC = (0, 250, 960, 850)          # the scene crop out of the 960 eye: the room, the ceiling band (where the HUD sits)
def scene(n): return fr(n).crop(SC)
def pl(i): return F.pal(i)
def light(c, k): return tuple(min(255, int(v + (255 - v) * k)) for v in c)
def dark(c, k): return tuple(int(v * k) for v in c)

# ---------------------------------------------------------------- the HUD art (real, from the series)
E = Image.open(os.path.join(REPO, 'SlowMo', 'graphics', 'RSQSMHE.png')).convert('RGBA')      # coldcite's bar, empty (gen_gauges.py)
WB = Image.open(os.path.join(REPO, 'SlowMo', 'graphics', 'RSQSMHW.png')).convert('RGBA')     # the same bar full, white (tinted)
SK1 = Image.open(os.path.join(REPO, 'Miniboss', 'graphics', 'RSQMBSK1.png')).convert('RGBA') # the Bossfight meter's crowned skull
HG = Image.open(os.path.join(REPO, 'SlowMo', 'graphics', 'RSQSMHG.png')).convert('RGBA')     # SlowMo's countdown hourglass

# RSQ ladder colours (the tier names RSQ Monsters uses)
PURPLE, RED, FIREBLU = (170, 70, 255), (235, 40, 40), (60, 160, 255)
SILVER, GREYSEG = (200, 205, 215), (125, 128, 135)
GOLD_LO, GOLD_HI = (0x40, 0x30, 0x10), (0xFF, 0xD0, 0x30)   # Score's base gold (TEXTCOLO)
DARING = ((0xC0, 0x60, 0x20), (0xFF, 0x80, 0x30))           # Score's Daring family (Miniboss, Bossfight rows)

def tintw(im, col):
    r, g, b, a = im.split()
    r = r.point(lambda v: v * col[0] // 255); g = g.point(lambda v: v * col[1] // 255); b = b.point(lambda v: v * col[2] // 255)
    return Image.merge('RGBA', (r, g, b, a))

def hbar(w, h, frac, col):
    """coldcite's bar at w x h (nearest): the empty bar, the white bar tinted `col` cut to `frac` from the left"""
    e = E.resize((w, h), Image.NEAREST)
    if frac > 0:
        f = tintw(WB.resize((w, h), Image.NEAREST), col)
        cut = max(1, int(round(w * frac)))
        e.alpha_composite(f.crop((0, 0, cut, h)), (0, 0))
    return e

# PLACEHOLDER ART: the shield icon (no shield art exists in the series yet). Drawn on the skull's 16 x 16 grid and outline.
SHIELD = ['.##############.',
          '#hhhhhhhhhhhhhs#',
          '#hwwwwwwwwwwwws#',
          '#hwwwwwssswwwws#',
          '#hwwwwwsdswwwws#',
          '#hwwssssdsssswd#',
          '#hwwsddddddddsd#',
          '#hwwssssdsssssd#',
          '.#wwwwwsdswwwd#.',
          '.#wwwwwsdswwwd#.',
          '..#wwwwsdswwd#..',
          '..#wwwwsssswd#..',
          '...#wwwwwwwd#...',
          '....#wwwwwd#....',
          '.....#wwdd#.....',
          '......####......']
def shield_icon(k=4, bright=1.0):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0)); p = im.load()
    C = {'#': (15, 15, 15), 'h': (250, 252, 255), 'w': (196, 202, 214), 's': (150, 156, 170), 'd': (98, 104, 118)}
    for y, r in enumerate(SHIELD):
        for x, ch in enumerate(r):
            if ch in C:
                c = C[ch] if ch == '#' else light(C[ch], max(0, bright - 1)) if bright > 1 else C[ch]
                p[x, y] = c + (255,)
    return im.resize((16 * k, 16 * k), Image.NEAREST)

def stepbar(w, frac, steps=3, col=(255, 200, 60)):
    """RSQ SlowMo DOWN's reward bar, redrawn for the HUD (downhud.zs): steps thin -> tall left to right, each a #0b0b0d
    border round a #202024 track; the fill a moving gradient of its colour; it drains from the right (tall end first)"""
    hs = [9, 16, 26][:steps] if steps == 3 else [9 + 17 * i // max(1, steps - 1) for i in range(steps)]
    H = max(hs) + 6
    im = Image.new('RGBA', (w, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    sw = w // steps
    for i, h in enumerate(hs):
        x0, x1 = i * sw, (i + 1) * sw - 3
        y0 = H - h - 3
        d.rectangle([x0, y0, x1, H - 1], fill=(0x0b, 0x0b, 0x0d, 255))
        d.rectangle([x0 + 3, y0 + 3, x1 - 3, H - 4], fill=(0x20, 0x20, 0x24, 255))
        # fill: the part of this step left of the drain point
        fx = int(w * frac)
        if fx > x0 + 3:
            for x in range(x0 + 3, min(x1 - 3, fx) + 1):
                t = (x / w)
                c = tuple(int(min(255, v * (0.78 + 0.35 * math.sin(t * 9.0) ** 2))) for v in col)
                d.line([(x, y0 + 3), (x, H - 4)], fill=c + (255,))
    return im

def stack(thr=None, main=1.0, maincol=PURPLE, lives=2, window=None, shield=True, lifecol=None, W=380):
    """the HUD bar stack (MINIBOSS_REWORK.md): thrall bar (one segment a thrall) with the shield icon, the window step bar,
    the main bar with the Bossfight skull, the thin life bars. thr: list of segment states: ('shield'|'open'|'broken', frac)"""
    lifecol = lifecol or maincol
    parts = []
    gap = 10
    if thr:
        n = len(thr); sw = (W - gap * (n - 1)) // n
        row = Image.new('RGBA', (W, 26), (0, 0, 0, 0))
        for i, (st, f) in enumerate(thr):
            col = GREYSEG if st == 'shield' else (maincol if st == 'open' else (60, 60, 60))
            seg = hbar(sw, 22, f if st != 'broken' else 0, col)
            row.alpha_composite(seg, (i * (sw + gap), 2))
        parts.append(('thr', row))
    if window is not None:
        parts.append(('win', stepbar(W, window, len(thr) if thr else 3)))
    m = Image.new('RGBA', (W, 30), (0, 0, 0, 0))
    m.alpha_composite(hbar(W - 34, 24, main, maincol), (34, 3))
    m.alpha_composite(SK1.resize((30, 30), Image.NEAREST), (0, 0))
    parts.append(('main', m))
    for i in range(lives):
        parts.append(('life', hbar(W - 34, 7, 1.0, lifecol)))
    H = sum(p.height for _, p in parts) + 6 * len(parts)
    im = Image.new('RGBA', (W, H + 40), (0, 0, 0, 0))
    y = 0
    for k, p in parts:
        x = 34 if k == 'life' else 0
        im.alpha_composite(p, (x, y)); y += p.height + (4 if k == 'life' else 6)
    return im

def hud(img, st, y=12):
    """the stack on the view's top centre (screen space: it is the HUD), with a soft dark glow so it reads on any wall"""
    out, pad = F.glow(st, (0, 0, 0), 4, 0.9, 1)
    img.alpha_composite(out, (img.width // 2 - out.width // 2, y - pad))

def shield_over(img, y=12, bright=1.0):
    si = shield_icon(4, bright)
    g, pad = F.glow(si, (230, 235, 245), 7, 1.0 + 0.6 * (bright - 1), 1)
    img.alpha_composite(g, (img.width // 2 - g.width // 2, y - pad - 18))

def target(img, x, y, h=14, k=1.0, pulse=0.0):
    w = word_any(F.FON, 'TARGET!', h * k, GOLD_LO, light(GOLD_HI, pulse * 0.6))
    put(img, w, x, y, (255, 190, 40), int(4 + 6 * pulse), 0.9 + 0.8 * pulse, 2)

def guard(img, x, y, h=18, white=0.0, alpha=1.0):
    lo, hi = ((90, 95, 108), (230, 234, 242)) if white < 0.5 else ((225, 228, 235), (255, 255, 255))
    w = word_any(F.FON, 'GUARD!', h, lo, hi)
    put(img, w, x, y, (225, 230, 240), 6 + int(4 * white), 0.9 + 0.8 * white, 2, alpha=alpha)

def grey_x(img, x, y, h=18, alpha=1.0, trail=None):
    g = word_any(F.JFO, 'X', h, (70, 70, 76), (200, 200, 208))
    if trail:
        d = ImageDraw.Draw(img)
        for i in range(6):
            t = i / 6.0
            px = trail[0] + (x - trail[0]) * t; py = trail[1] + (y - trail[1]) * t - math.sin(t * math.pi) * 10
            d.ellipse([px - 1, py - 1, px + 1, py + 1], fill=(150, 150, 155, int(80 + 120 * t)))
    put(img, g, x, y, (150, 150, 158), 4, 0.9, 2, alpha=alpha)

def grade(img, col, amount=0.55):
    """MOCKUP grade (the room glow the rework asks for): pulls the low-saturation pixels (walls, floor) toward a colour,
    leaves the saturated ones (the monsters' own colours) alone"""
    rgb = img.convert('RGB')
    hsv = rgb.convert('HSV'); s = hsv.split()[1]
    w = s.point(lambda v: int(255 * min(1.0, max(0.0, 1.0 - (v - 90) / 120.0)) * amount))
    lum = rgb.convert('L')
    tinted = Image.merge('RGB', [lum.point(lambda v, c=c: min(255, int(v * (0.35 + 0.9 * c / 255)))) for c in col])
    out = Image.composite(tinted, rgb, w).convert('RGBA')
    return out

def slow(img):
    """MOCKUP: slow motion reads as a slight desaturation and SlowMo's own countdown bar + hourglass (real art)"""
    im = ImageEnhance.Color(img.convert('RGB')).enhance(0.7).convert('RGBA')
    bar = hbar(260, 16, 0.62, (120, 200, 255))
    row = Image.new('RGBA', (300, 22), (0, 0, 0, 0)); row.alpha_composite(HG.resize((22, 22), Image.NEAREST), (0, 0)); row.alpha_composite(bar, (32, 3))
    put(im, row, im.width // 2, im.height - 30, (0, 0, 0), 3, 0.8, 1)
    return im

def pop(img, x, y, col, r=26, k=1.0):
    """PLACEHOLDER effect: the thrall's power leaving (a sphere pops)"""
    halo = Image.new('RGBA', (160, 160), (0, 0, 0, 0)); ImageDraw.Draw(halo).ellipse([80 - r * k, 80 - r * k, 80 + r * k, 80 + r * k], fill=col + (255,))
    halo = halo.filter(ImageFilter.GaussianBlur(10))
    put(img, halo, x, y, alpha=0.85)
    put(img, ring(int(r * 1.7 * k), col, thick=3, ticks=0, px=2, glow_r=8), x, y, alpha=0.9)
    core = Image.new('RGBA', (40, 40), (0, 0, 0, 0)); ImageDraw.Draw(core).ellipse([12, 12, 28, 28], fill=(255, 250, 230, 255))
    put(img, core.filter(ImageFilter.GaussianBlur(2)), x, y)

import textwrap
_panel = panel
def panel(num, title, scene_, steps, notes, legend, out, labels):
    wrap = lambda ls, w: [x for l in ls for x in textwrap.wrap(l, w, subsequent_indent='    ')]
    # the step labels go on a dark band at the foot of each step (the HUD sits at the top)
    lab = []
    for im, t in zip(steps, labels):
        im = im.copy(); d = ImageDraw.Draw(im)
        f = sans(26, True)
        d.rectangle([0, im.height - 44, im.width, im.height], fill=(0, 0, 0, 170))
        d.text((14, im.height - 38), t, fill=(240, 240, 240), font=f)
        lab.append(im)
    return _panel(num, title, scene_, lab, wrap(notes, 128), wrap(legend, 150), out, None)

def steps_of(imgs, box=(170, 0, 770, 380)):
    return [i.crop(box) for i in imgs]

MB = (455, 230)      # the miniboss's chest in the scene crop (f00169..f00183)
THR = [(243, 205), (590, 262), (828, 205)]   # the three thralls' heads (left, centre, right)

NOTE_HUD = 'HUD: coldcite\'s bar (RSQSMHE/W, gen_gauges.py) for every bar; the Bossfight skull RSQMBSK1; words in RS Score\'s RSSCFON.'
NOTE_BG = 'Background: rig frame, 2026-11-09 (QZD 17.3 rig, left eye, Doom II MAP02): a 1.25x MeatGrinder baron and three ColorfulHell imps, spawned by a test probe.'

# ---------------------------------------------------------------- 1 ARRIVAL
def p1():
    a, b = scene(166), scene(169)
    def lay(im, up):
        im = im.copy()
        if up <= 0: return im
        top = Image.new('RGBA', im.size, (0, 0, 0, 0))
        hud(top, stack(thr=[('shield', 1.0)] * 3, main=up, maincol=PURPLE, lives=2))
        shield_over(top)
        if up < 1: top.putalpha(top.getchannel('A').point(lambda v: int(v * 0.55)))
        im.alpha_composite(top)
        return im
    main = lay(b, 1.0)
    panel(1, 'ARRIVAL', main, steps_of([lay(a, 0), lay(b, 0.5), main]),
          ['A Bossfight lands: the miniboss, 1.25x (its hitbox too), and its three thralls, all Boosted Legendary Champions,',
           'each in a teleport fog. RSQ Glow In The Dark rolls a wave of the miniboss\'s colour (here Purple) out from where it lands.',
           'The HUD stack comes up with it: the thrall bar (three grey segments, the shield), its main bar, two thin life bars.'],
          [NOTE_HUD,
           'Real in the frame: the fogs (BD22\'s TeleportFog), the 1.25x MeatGrinder baron, the GITD wave (event.wave A040FF, from RSQ Glow In The Dark).',
           'Not shown: the Champions colours and icons (Champions was off for this run). ' + NOTE_BG],
          os.path.join(OUT, 'p1_arrival.png'), ['it lands: no HUD yet', 'fog and wave; the stack rises', 'the stack is up, full'])

# ---------------------------------------------------------------- 2 SHIELD UP
def p2():
    base = grade(scene(177), (150, 162, 185), 0.8)
    def lay(stage):
        im = base.copy()
        hud(im, stack(thr=[('shield', 1.0)] * 3, main=1.0, maincol=PURPLE, lives=2))
        shield_over(im, bright=1.0 + 0.5 * (stage == 1))
        for (x, y) in THR: target(im, x, y - 30, 12)
        if stage >= 0:
            # the shot that just hit it: Guard! pops silver, flickers white, drifts up; grey Xs bounce off
            gy = {0: 150, 1: 146, 2: 128, 3: 148}[stage]
            guard(im, MB[0], gy, 20 if stage != 2 else 18, white=1.0 if stage == 1 else 0.0, alpha=0.6 if stage == 2 else 1.0)
            xs = [((MB[0] - 40, MB[1] - 14), (MB[0] - 8, MB[1] + 2)), ((MB[0] + 42, MB[1] - 28), (MB[0] + 10, MB[1] - 8)),
                  ((MB[0] - 56, MB[1] + 24), (MB[0] - 6, MB[1] + 16))]
            n = 3 if stage == 3 else 1 + stage
            for i, (p, o) in enumerate(xs[:n]):
                grey_x(im, p[0], p[1], 18, alpha=1.0 if stage == 3 else max(0.35, 1.0 - 0.3 * (stage - i)), trail=o)
        return im
    st = [lay(0), lay(1), lay(2)]
    panel(2, 'SHIELD UP', lay(3), steps_of(st),
          ['While its thralls live the miniboss is shielded: every shot on it pops "Guard!" over it in RS Score\'s font, silver',
           'flickering to white, drifting up and fading (the Castlevania number), and a grey X bounces off where the shot hit.',
           '"Target!" hangs over each thrall. The fight room\'s glow holds a steady cold grey.'],
          [NOTE_HUD + ' Grey X: the damage-number X (JFO small, VisualRewards dn_art), grey.',
           'Glow: the rig ran RSQ Glow In The Dark\'s event.tint 8A93A6; on this room\'s brown walls it read olive, so the cold grey is GRADED in this mockup.',
           'Placeholder art: the shield icon (none in the series yet). ' + NOTE_BG],
          os.path.join(OUT, 'p2_shield_up.png'), ['shot lands: Guard! silver', 'flicker: white', 'drifts up, fades; Xs bounce'])

# ---------------------------------------------------------------- 3 THRALL KILLED
def p3():
    base = scene(180)
    def lay(stage):
        im = grade(slow(base), (255, 196, 70), 0.85)
        win = {0: 1.0, 1: 0.62, 2: 0.3}[stage]
        seg = {0: 1.0, 1: 0.72, 2: 0.4}[stage]
        hud(im, stack(thr=[('open', seg), ('open', 1.0), ('open', 1.0)], main=1.0, maincol=PURPLE, lives=2, window=win, shield=False))
        pop(im, THR[1][0], THR[1][1] + 18, (255, 140, 40), k={0: 0.7, 1: 1.0, 2: 1.3}[stage])
        k = {0: 1.6, 1: 1.25, 2: 1.4}[stage]
        target(im, MB[0], MB[1] - 80, 20, k=k, pulse={0: 1.0, 1: 0.3, 2: 0.8}[stage])
        for (x, y) in (THR[0], THR[2]): target(im, x, y - 26, 8)
        return im
    st = [lay(0), lay(1), lay(2)]
    panel(3, 'THRALL KILLED', st[2], steps_of(st),
          ['Kill a thrall: the world slows, the power it gave the miniboss leaves it (a sphere pops), and the shield is gone.',
           'A big pulsing "Target!" over the miniboss, the thralls\' Target! shrunk. Under the segments, the window: DOWN\'s reward bar',
           'on the HUD, one step a thrall (1 s each), tallest first. Break the open segment (its share of the miniboss\'s health) before',
           'it drains; the step you break it in sets Score\'s pay. The room\'s glow turns gold.'],
          [NOTE_HUD + ' Window: DOWN\'s bar as downhud.zs draws it (steps thin/normal/tall, #0b0b0d border, #202024 track), gold.',
           'Slow motion: SlowMo\'s countdown bar and hourglass (RSQSMHE/W, RSQSMHG) and a desaturation (graded here). Gold glow: GRADED in this mockup.',
           'Placeholder: the sphere pop (an orange burst here: the colour of the power it carried). The dying imp is the real frame. ' + NOTE_BG],
          os.path.join(OUT, 'p3_thrall_killed.png'), ['the pop: Target! slams', 'window draining', 'one step left'])

# ---------------------------------------------------------------- 4 WINDOW MISSED
def p4():
    frames = [scene(181), scene(182), scene(183)]
    def lay(im, stage):
        im = im.copy()
        col = PURPLE if stage == 0 else RED
        st_ = 'open' if stage == 0 else 'shield'
        hud(im, stack(thr=[(st_, 0.86), (st_, 1.0), (st_, 1.0)], main=1.0, maincol=col, lives=2,
                      window=0.0 if stage == 0 else None, shield=stage > 0))
        if stage > 0: shield_over(im)
        return im
    st = [lay(f, i) for i, f in enumerate(frames)]
    panel(4, 'WINDOW MISSED', st[1], steps_of(st),
          ['The window ran out with the segment unbroken: the miniboss and its thralls tier up, by how much segment was left',
           '(a sliver +1, about half +2, untouched +3; map-wide by option). Each blinks white (the tier flash), then comes back a few',
           'colours higher: here Purple to Red, the thralls to Purple and Yellow. The shield is back up.'],
          ['Real in the frames: RSQ Monsters\' own tier flash and the colour change (RS_Retier.Request on the miniboss and both thralls);',
           'the flash\'s white (rs_tier_flashwhite) reads grey in this room\'s light.',
           'HUD: the window bar drained to nothing, the segment left at 86% (left frame); then the shield and the stack in the new colour.',
           NOTE_BG],
          os.path.join(OUT, 'p4_window_missed.png'), ['the flash: all blink white', 'still flashing, thralls changed', 'a few colours higher'])

# ---------------------------------------------------------------- 5 ONE-ON-ONE
def p5():
    frames = [scene(197), scene(200), scene(200)]
    MBp = (432, 232)
    def lay(im, frac, pulse):
        im = im.copy()
        hud(im, stack(thr=None, main=frac, maincol=RED, lives=2))
        target(im, MBp[0], MBp[1] - 80, 18, k=1.3, pulse=pulse)
        return im
    st = [lay(frames[0], 1.0, 0.6), lay(frames[1], 0.62, 0.2), lay(frames[2], 0.3, 0.8)]
    panel(5, 'ONE-ON-ONE', st[1], steps_of(st, (150, 0, 750, 380)),
          ['Every segment broken: no thralls, no thrall bar. It is you and the miniboss: its main bar in its colour, draining',
           'as you hit it, the thin life bars under it, "Target!" over it.'],
          [NOTE_HUD,
           'Glow: real (RSQ Glow In The Dark\'s event.tint in the miniboss\'s colour, Red).', NOTE_BG],
          os.path.join(OUT, 'p5_one_on_one.png'), ['all segments broken', 'main bar draining', 'nearly empty'])

# ---------------------------------------------------------------- 6 LIFE LOST
def p6():
    a, b, c = scene(197), scene(201), scene(216)
    MBp = (432, 232)
    def lay(im, stage):
        im = im.copy()
        if stage == 0: hud(im, stack(main=0.0, maincol=RED, lives=2))
        elif stage == 1: hud(im, stack(main=0.5, maincol=(235, 235, 240), lives=1, lifecol=RED))
        else: hud(im, stack(main=1.0, maincol=FIREBLU, lives=1))
        if stage == 2: target(im, MBp[0], MBp[1] - 80, 18, k=1.3, pulse=0.5)
        return im
    st = [lay(a, 0), lay(b, 1), lay(c, 2)]
    panel(6, 'LIFE LOST', st[2], steps_of(st, (150, 0, 750, 380)),
          ['The main bar empties: the miniboss uses a life. The next life bar rises into the main bar and refills it, the miniboss',
           'blinks and comes back a colour higher (Red to FireBlu), and the fight room\'s glow takes its new colour.',
           'No thralls rise: it fights its last lives alone.'],
          ['Real in the frames: RSQ Monsters\' tier flash and colour change, and RSQ Glow In The Dark\'s event.tint in the new colour (30A0FF).',
           'HUD: empty bar (left); the refill sweeping in, one life bar fewer (middle); full in FireBlu (right).', NOTE_BG],
          os.path.join(OUT, 'p6_life_lost.png'), ['main bar empty', 'the flash; the refill', 'a colour higher, new glow'])

# ---------------------------------------------------------------- 7 DEATH
def rowimg(n, name, fam, h=13):
    lo, hi = fam
    a = word_any(F.FN2, n, h, dark(lo, .5), hi); b = word_any(F.FN2, name, h, (0x80, 0x80, 0x80), (0xFF, 0xFF, 0xFF))
    out = Image.new('RGBA', (a.width + 8 + b.width, max(a.height, b.height)), (0, 0, 0, 0))
    out.alpha_composite(a, (0, 0)); out.alpha_composite(b, (a.width + 8, 0)); return out

def p7():
    a, b, c = scene(222), scene(226), scene(226)
    def lay(im, stage):
        im = im.copy()
        if stage < 2: hud(im, stack(main=0.0, maincol=FIREBLU, lives=0))
        if stage >= 1:
            x, y = 470, 120
            lo, hi = GOLD_LO, GOLD_HI
            put(im, word_any(F.FON, '+9000', 26, dark(lo, .4), hi), x, y, (0xFF, 0xD0, 0x30), 8, 1.2, 2)
            yy = y + 30
            for r in [('+4000', 'MINIBOSS', DARING), ('+5000', 'BOSSFIGHT', DARING)][: (1 if stage == 1 else 2)]:
                put(im, rowimg(*r), x - 60, yy, (0, 0, 0), 3, 0.8, 1, 'l'); yy += 17
        return im
    st = [lay(a, 0), lay(b, 1), lay(c, 2)]
    panel(7, 'DEATH', st[2], steps_of(st, (150, 0, 750, 380)),
          ['It dies: a map-wide RSQ Glow In The Dark wave in its colour, then the colours re-roll. Its loot drops, and Score pays',
           'its Miniboss and Bossfight rows on the kill: the total pops over the body, the rows that paid under it.'],
          ['Real in the frames: the death and gore; a megasphere and a soulsphere spawned for the shot as loot; the coloured orbs are RSQ',
           'VisualRewards\' Kill Rewards bits. The GITD wave (event.wave 30A0FF) was sent; in a still the room just reads blue (the life-lost tint too).',
           'Score: the rows are Score\'s own (RS_Award_Miniboss, RS_Award_Bossfight: Daring family colours, RSSCFN2); the points are EXAMPLE values.',
           NOTE_BG],
          os.path.join(OUT, 'p7_death.png'), ['it dies: the wave', 'the loot; Miniboss pays', 'Bossfight pays'])

# ---------------------------------------------------------------- the contact sheet
def sheet():
    names = ['p1_arrival', 'p2_shield_up', 'p3_thrall_killed', 'p4_window_missed', 'p5_one_on_one', 'p6_life_lost', 'p7_death']
    ims = [Image.open(os.path.join(OUT, n + '.png')).convert('RGB') for n in names]
    cw = 710
    th = [im.resize((cw, int(im.height * cw / im.width)), Image.LANCZOS) for im in ims]
    rows = [th[i:i + 2] for i in range(0, len(th), 2)]
    H = sum(max(t.height for t in r) for r in rows) + 10 * (len(rows) + 1)
    can = Image.new('RGB', (cw * 2 + 30, H), (14, 14, 18))
    y = 10
    for r in rows:
        x = 10
        for t in r: can.paste(t, (x, y)); x += cw + 10
        y += max(t.height for t in r) + 10
    can.save(os.path.join(OUT, 'contact_sheet.png'), optimize=True)   # full colour: a 256-colour sheet lost the ladder colours

if __name__ == '__main__':
    for n in sys.argv[1:]: globals()[n]()
