"""Arcade-language mockups (design only; no mod code). python3 -I panels.py p1 p2 ... p8
Text drawn only with the series' fonts, decoded by design/mockups/fonts/make_font_sheets.py (afonts.py).
Backgrounds: bg/ = rig frames captured with run.sh + final*.sh + probe/ on doom2 -> brutal22test6 -> BD_VoxelPack -> BD22 VR (+ RSQ_VisualRewards for p8)."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image, ImageDraw, ImageFilter, ImageChops
import afonts as F
from comp import *
FR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'bg')          # rig frames used (QZD 17.3 left eye, 960 px, 90 deg)
OUT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
def fr(n): return load(os.path.join(FR, n + '.jpg'))
def pl(i): return F.pal(i)
def light(c, k): return tuple(min(255, int(v + (255 - v) * k)) for v in c)
def dark(c, k): return tuple(int(v * k) for v in c)
SC = (120, 60, 840, 780)   # scene crop out of the 960 eye: the central 72 degrees, 720 x 720

def crop_step(img, cx, cy, w, h):
    return img.crop((int(cx - w / 2), int(cy - h / 2), int(cx + w / 2), int(cy + h / 2)))

# ---------------------------------------------------------------- 8 JACKPOT
def p8():
    base = fr('F5/f00016')
    G, GL = pl(161), pl(160)
    def scene(stage):
        im = base.copy()
        # bits fly from the kills to the off-hand bank: a short streak toward the lower left (hand); bank counter at the wrist
        cx, cy = 480, 300
        if stage >= 0:
            fz = word(F.JFO, 'FRENZY', 30, dark(pl(215), .35), pl(213))
            put(im, fz, cx, cy - 52 if stage < 2 else cy - 120, pl(215), 9, 1.2, 2)
        clock = {0: '10:00', 1: '04:12', 2: '00:00'}[stage]
        ck = F.seven(clock, 34 if stage < 2 else 26, on=GL, off=dark(G, .35), off_alpha=70)
        put(im, ck, cx, cy - 8 if stage < 2 else cy - 82, G, 8, 1.0, 1)
        bank = {0: '0', 1: '38', 2: '61'}[stage]
        b = word(F.FN2, 'BANK ' + bank + ' BITS', 14, dark(GL, .5), GL)
        if stage == 2:
            jp = word(F.JFO, 'JACKPOT', 46, dark(G, .4), light(GL, .5))
            put(im, jp, cx, cy - 18, pl(231), 14, 1.6, 2)
            pay = word_any(F.JFOB, '+6100', 38, dark(GL, .6), light(GL, .6))
            put(im, pay, cx, cy + 42, G, 10, 1.3, 2)
        return im
    s0, s1, s2 = scene(0), scene(1), scene(2)
    # step frames: crops round the shout
    steps = [crop_step(s, 480, 315, 520, 320) for s in (s0, s1, s2)]
    panel(8, 'JACKPOT AND FRENZY', s2.crop(SC), steps,
          ['When: a DOWN, a big combo or a lit target starts FRENZY. For 10 s every bit banks double;',
           'the bank keeps counting (on your off-hand wrist, not drawn here: the hand is out of shot). At 00:00 the bank pays out in one shout over the kill zone.',
           'Where: the shout hangs 8 m out over the room the kills were in (it does not follow your head); the clock above it.'],
          ['Fonts: FRENZY / JACKPOT = JFO small (metal, tinted); +6100 = JFO big digits; clock = DOWN seven-segment (gold, not DOWN red);',
           '       wrist bank line would be RSSCFN2.   Colours: PLAYPAL 161/160 gold, 213/215 orange, 231 yellow glow.',
           'Size (at 8 m): JACKPOT 0.53 m cap height (3.8 deg); +6100 0.63 m (4.5 deg); clock 0.57 m; FRENZY 0.53 m.',
           'Background: rig frame, Doom II MAP04, BD22 monsters killed with RSQ VisualRewards bits bursting (real bits).'],
          os.path.join(OUT, 'p8_jackpot_frenzy.png'),
          ['FRENZY starts: 10:00', 'bank 38 bits: 04:12', 'JACKPOT +6100: 00:00'])


# ---------------------------------------------------------------- 1 LOCK-ON
def p1():
    fr_ = [fr('R1/f00011'), fr('R1/f00016'), fr('R1/f00021')]
    cols = [pl(112), pl(231), pl(176)]
    radii = [70, 56, 46]; arcs = [1.0, 1.0, 1.0]
    imx, imy = 462, 468
    outs = []
    for i, (im, c, r) in enumerate(zip(fr_, cols, radii)):
        im = im.copy()
        rg = ring(r, c, thick=4, ticks=4, px=2, rot=[0, 20, 45][i], glow_r=[5, 7, 10][i])
        put(im, rg, imx, imy)
        if i == 2:  # a second, outer flash ring: the "now" beat
            put(im, ring(r + 12, c, thick=2, ticks=0, px=2, glow_r=6), imx, imy, alpha=0.55)
        outs.append(im)
    box = (232, 318, 712, 638)
    steps = [o.crop(box) for o in outs]
    panel(1, 'LOCK-ON RING', outs[2].crop((150, 250, 790, 700)), steps,
          ['What: a ring closes on the monster that is about to shoot you, on the monster itself.',
           'Green when he has seen you and starts the attack, yellow while he winds up, red the beat before the shot leaves his hand.',
           'Only attackers get one; the zombie on the left is not attacking, so no ring. Gone when he fires or dies.'],
          ['Font: none (a ring is the word). Colours: PLAYPAL 112 green, 231 yellow, 176 red; soft glow of the same colour, no box.',
           'Size: ring 2.7 m wide round a 1.75 m Imp at 9.4 m (16 deg), closing to 1.8 m (11 deg); stroke 8 cm; chunky 2x2 pixels as drawn here.',
           'Background: rig frames, Doom II MAP04, BD22 Imp (fireball forming in hand in the 2nd and 3rd frames), QZD 17.3 left eye.'],
          os.path.join(OUT, 'p1_lockon_ring.png'),
          ['0.0 s  sees you: green', '0.4 s  winds up: yellow', '0.7 s  about to fire: red'])

# ---------------------------------------------------------------- 3 SHOT WORDS
def p3():
    base = fr('R3/f00018')
    # the streak, far to near: each word pops at its head, then rises and fades as the next lands
    heads = [(489, 520), (604, 522), (556, 522), (368, 492)]
    W = [('GOOD', pl(80), 11), ('GREAT', pl(231), 12), ('AMAZING', pl(215), 14), ('PERFECT', pl(160), 18)]
    rise = [62, 44, 24, 0]; fade = [0.3, 0.45, 0.7, 1.0]
    def words(im, upto, last_k=1.0, flash=False):
        for i in range(upto):
            (hx, hy), (w, c, h) = heads[i], W[i]
            last = i == upto - 1
            k = last_k if last else 1.0
            lo, hi = ((110, 110, 110), (255, 255, 255)) if (flash and last) else (dark(c, .35), light(c, .35))
            img = word_any(F.JFO, w, h * k, lo, hi)
            put(im, img, hx, hy - 26 - rise[i] - int(h * k * .5), c, 5 + i, 0.9 + .2 * i, 2, alpha=fade[i])
        return im
    main = words(base.copy(), 4)
    st = [words(base.copy(), 4, 1.7, True), words(base.copy(), 4, 0.85), words(base.copy(), 4, 1.0)]
    box = (230, 380, 670, 600)
    panel(3, 'SHOT-QUALITY WORDS', main.crop((150, 250, 790, 700)), [x.crop(box) for x in st],
          ['What: each headshot in a row gets a louder word at the head it hit: GOOD, GREAT, AMAZING, PERFECT.',
           'A body shot or a miss ends the streak and the next headshot starts again at GOOD.',
           'Where/when: on the head, the instant it is hit. Each word holds 0.6 s; as the next lands, the older words rise and fade, so the streak reads as a ladder.'],
          ['Font: JFO small (our metal font), tinted. Colours: PLAYPAL 80 white, 231 yellow, 215 orange, 160 pale gold; glow in the same colour.',
           'Size: cap height 0.30 m (GOOD, 13 m: 1.3 deg) up to 0.35 m (PERFECT, 9.4 m: 2.1 deg). Motion: pops in white at 1.7x, undershoots, settles; older words rise and fade.',
           'Background: rig frame, Doom II MAP04 barrel hall, BD22 RifleZombies and ShotgunGuy (frozen with the freeze cheat).'],
          os.path.join(OUT, 'p3_shot_words.png'),
          ['PERFECT pops: white, 1.7x', '+2 tics: 0.85x', '+5 tics: settles, colour'])

# ---------------------------------------------------------------- 4 NUMBER + COMBO TIER
SCORE = {'base': ((0xC0, 0xB0, 0x20), (0xFF, 0xD0, 0x30)), 'style': ((0x90, 0xC0, 0x20), (0xB8, 0xFF, 0x30)),
         'daring': ((0xC0, 0x60, 0x20), (0xFF, 0x80, 0x30)), 'melee': ((0x70, 0x90, 0xD0), (0xA0, 0xC8, 0xFF))}
def p4():
    base = fr('R3/f00024')
    hx, hy = 482, 470
    def rowimg(n, name, fam, h=12):
        lo, hi = SCORE[fam]
        a = word_any(F.FN2, n, h, dark(lo, .5), hi); b = word_any(F.FN2, name, h, (0x80, 0x80, 0x80), (0xFF, 0xFF, 0xFF))
        out = Image.new('RGBA', (a.width + 8 + b.width, max(a.height, b.height)), (0, 0, 0, 0))
        out.alpha_composite(a, (0, 0)); out.alpha_composite(b, (a.width + 8, 0)); return out
    def scene(stage, pop=1.0):
        im = base.copy()
        total = {0: '+20', 1: '+30', 2: '+45'}[stage]
        lo, hi = SCORE['base']
        n = word_any(F.FON, total, 26 * pop, dark(lo, .4) if pop == 1 else (110, 110, 110), hi if pop == 1 else (255, 255, 255))
        put(im, n, hx, hy, (0xFF, 0xD0, 0x30), 8, 1.2, 2)
        if stage >= 1:
            lo2, hi2 = SCORE['style']
            t = word_any(F.FN2, 'TRAP SHOOTER', 15 * (pop if stage == 1 else 1), dark(lo2, .45), light(hi2, .2))
            put(im, t, hx, hy - 40, hi2, 8, 1.3, 2)
        rows = [('+20', 'BASE', 'base')] + ([('+10', 'TRAP SHOOTER', 'style')] if stage >= 1 else []) + ([('+15', 'HEADSHOT', 'daring')] if stage >= 2 else [])
        y = hy + 30
        for r in rows:
            put(im, rowimg(*r), hx - 40, y, (0, 0, 0), 3, 0.8, 1, 'l'); y += 17
        return im
    steps = [scene(0, 1.6), scene(1, 1.6), scene(2, 1.0)]
    box = (262, 340, 702, 600)
    panel(4, 'HIT NUMBER AND COMBO NAME', scene(2).crop((150, 250, 790, 700)), [s.crop(box) for s in steps],
          ['What: where the kill lands, its points pop out as one number; the chain\'s name stamps above it; the rows that paid list under it.',
           'Uppercut a zombie, finish it with the shotgun: TRAP SHOOTER (RSQ Score\'s own combo, glove.upper > gun.shotgun).',
           'The number rolls up as each row pays (+20 base, +10 the combo, +15 the headshot). Same names and colours as Score\'s breakdown.'],
          ['Fonts: the number = RSSCFON (Score line font); the combo name and rows = RSSCFN2 (Score breakdown font).',
           'Colours: Score TEXTCOLO families: Base gold #FFD030, Style green #B8FF30, Daring orange #FF8030; names white. Example values;',
           '       Trap Shooter pays 50% of base (Score/zscript/rsscore/combos.zs:25). Size at 10 m: number 0.56 m (3.1 deg), name 0.32 m, rows 0.26 m.',
           'Background: rig frame, Doom II MAP04, BD22 RifleZombie gibbing (kill monsters, then freeze).'],
          os.path.join(OUT, 'p4_hit_number_combo.png'),
          ['hit: +20 pops white', 'TRAP SHOOTER stamps', '+45, rows listed'])

# ---------------------------------------------------------------- 5 LIT TARGET
def p5():
    a = fr('R3/f00018'); b = fr('R3/f00019')
    d = ImageChops.difference(a.convert('RGB'), b.convert('RGB')).convert('L').point(lambda v: 255 if v > 30 else 0)
    d = d.filter(ImageFilter.MaxFilter(7)).filter(ImageFilter.MinFilter(7))
    ff = d.convert('RGB'); ImageDraw.floodfill(ff, (0, 0), (90, 90, 90)); d = ff.convert('L').point(lambda v: 0 if v == 90 else 255)
    bx, by = 579, 520
    C = pl(215)
    def scene(level, collected=False):
        im = a.copy()
        if not collected:
            o = outline(d, light(C, .2), width=3, glow_r=10, strength=1.2 + level)
            if level < 1:
                o.putalpha(o.getchannel('A').point(lambda v: int(v * (0.25 + 0.75 * level))))
            im.alpha_composite(o)
            im.alpha_composite(tintfill(d, light(C, .3), 0.25 * level))
            v = word_any(F.FON, '+500', 22, dark(C, .4), light(C, .4))
            put(im, v, bx, by - 22, C, 8, 0.6 + level, 2, alpha=0.5 + 0.5 * level)
        else:
            im = b.copy()
            v = word_any(F.FON, '+500', 30, (110, 110, 110), (255, 255, 255))
            put(im, v, bx, by - 50, C, 12, 1.8, 2)
        return im
    steps = [scene(0.0), scene(1.0), scene(0, True)]
    # value colours chip: the four insert colours as glowing values
    chip = Image.new('RGBA', (480, 300), (20, 20, 24, 255))
    for i, (val, c) in enumerate([('+100', pl(80)), ('+250', pl(231)), ('+500', pl(215)), ('+1000', pl(176))]):
        put(chip, word_any(F.FON, val, 26, dark(c, .4), light(c, .3)), 240, 82 + i * 56, c, 8, 1.2, 2)
    box = (339, 380, 819, 680)
    panel(5, 'THE LEVEL LIGHTS THE NEXT TARGET', scene(1.0).crop((240, 300, 880, 750)), [s.crop(box) for s in steps] + [chip],
          ['What: like a pinball insert, the level lights the next thing worth shooting: a barrel (or a monster) gets a glowing',
           'outline in its value colour and its value floats over it. It breathes while lit. Shoot it: the value jumps up white and',
           'is paid, and the next target somewhere in the room lights. Only one lit target at a time.'],
          ['Font: RSSCFON (Score line font) for the value. Outline: the target\'s own silhouette, 3 px line + soft glow, no box.',
           'Colour = value: PLAYPAL 80 white +100, 231 yellow +250, 215 orange +500, 176 red +1000 (4th frame).',
           'Size: value 0.29 m at 6.3 m (2.6 deg), 0.39 m when paid. Outline from the barrel\'s exact pixels (two frozen rig frames, barrel hidden in one).',
           'Background: rig frames, Doom II MAP04 barrel hall, BD_VoxelPack barrel (BarrelVOX), BD22 zombies.'],
          os.path.join(OUT, 'p5_lit_target.png'),
          ['breathing: dim', 'breathing: full', 'shot: +500 paid', 'colour = value'])

# ---------------------------------------------------------------- 6 ROOM TIMER
def p6():
    live = fr('R1/f00011'); clear = fr('R1/f00038')
    dx, dy = 480, 352     # over the far door, 15 m away
    def timer(im, secs, col, frac, bonus=None, pop=1.0):
        s = '%02d' % secs
        dig = word_any(F.DIGL, s, 30 * pop, dark(col, .35), light(col, .25))
        put(im, dig, dx, dy, col, 8, 1.2, 2)
        n = 12; segw = 9; x0 = dx - (n * (segw + 3)) // 2
        bar = Image.new('RGBA', (n * (segw + 3), 6), (0, 0, 0, 0)); bd = ImageDraw.Draw(bar)
        for k in range(n):
            on = k < round(frac * n)
            bd.rectangle([k * (segw + 3), 0, k * (segw + 3) + segw - 1, 5], fill=(col + (255,)) if on else (dark(col, .3) + (110,)))
        put(im, bar, dx, dy + 26, col, 5, 1.0, 1)
        if bonus:
            put(im, word_any(F.JFO, 'ROOM CLEAR', 15, dark(pl(80), .4), (255, 255, 255)), dx, dy - 40, pl(200), 7, 1.0, 2)
            put(im, word_any(F.JFO, bonus, 18 * pop, dark(pl(160), .4), light(pl(160), .5)), dx, dy + 62, pl(161), 9, 1.3, 2)
        return im
    s0 = timer(live.copy(), 4, pl(176), 4 / 30)
    s1 = timer(clear.copy(), 30, pl(112), 1.0, 'TIME BONUS +400', 1.5)
    s2 = timer(clear.copy(), 30, pl(112), 1.0, 'TIME BONUS +400', 1.0)
    box = (240, 255, 720, 515)
    panel(6, 'ROOM TIMER AND TIME BONUS', s2.crop((150, 230, 790, 680)), [s0.crop(box), s1.crop(box), s2.crop(box)],
          ['What: each fight room has a clock hung over its exit. It counts down while monsters are left (red when low).',
           'Kill the last one: ROOM CLEAR, the seconds you had left pay a TIME BONUS, and the clock refills for the next room.',
           'Where: over the far door of the room (20 m off here), so you see it while you fight and read it on the way out.'],
          ['Fonts: seconds = BD22 DIGIFONT_LARGE (DIGLNUM) tinted; ROOM CLEAR / TIME BONUS = JFO small. Refill = 12 lit ticks, no frame.',
           'Colours: PLAYPAL 176 red (low), 112 green (full), 160/161 gold bonus, 80 white + 200 blue glow for ROOM CLEAR.',
           'Size: digits 1.25 m at 20 m (3.6 deg); words 0.6-0.75 m (1.7-2.1 deg). Motion: bonus pops at 1.5x and settles; ticks refill left to right in 0.3 s.',
           'Background: rig frames, Doom II MAP04 courtyard: BD22 Imp alive (1st), corpses after the room is cleared (2nd, 3rd).'],
          os.path.join(OUT, 'p6_room_timer.png'),
          ['04 s left, 1 monster', 'cleared: bonus pops', 'refilled to 30 s'])

# ---------------------------------------------------------------- 7 LEVEL END
def p7():
    base = fr(P7BG)
    cx, top = 480, 300
    RED = pl(176)
    def scene(stage):
        im = base.copy()
        put(im, word_any(F.JFO, 'LEVEL CLEAR', 22, dark(pl(80), .4), (255, 255, 255)), cx, top, pl(176), 8, 0.9, 2)
        rows = [('KILLS', {0: '0%', 1: '100%', 2: '100%'}[stage]), ('ITEMS', {0: '0%', 1: '61%', 2: '92%'}[stage]), ('SECRET', {0: '0%', 1: '0%', 2: '67%'}[stage])]
        y = top + 38
        for lab, val in rows:
            l = word_any(STC, lab, 17, None, None)
            v = word_any(F.STTNUM, val, 19, None, None)
            put(im, l, cx - 140, y, (0, 0, 0), 3, 0.9, 1, 'l'); put(im, v, cx + 140 - v.width, y, (0, 0, 0), 3, 0.9, 1, 'l')
            y += 28
        bonus = {0: '0', 1: '4250', 2: '8500'}[stage]
        put(im, word_any(F.FON, 'BONUS', 19, (0x40, 0x30, 0x10), (0xFF, 0xD0, 0x30)), cx - 140, y + 6, (0, 0, 0), 3, 0.9, 1, 'l')
        bv = word_any(F.FON, bonus, 22, (0x40, 0x30, 0x10), (0xFF, 0xD0, 0x30))
        put(im, bv, cx + 140 - bv.width, y + 6, (0xFF, 0xD0, 0x30), 6, 1.0, 1, 'l')
        if stage == 2:
            g = word_any(F.JFO, 'S', 96, dark(pl(160), .35), light(pl(160), .6))
            put(im, g, cx + 235, top + 80, pl(231), 16, 1.8, 3)
        return im
    st = [scene(0), scene(1), scene(2)]
    box = (290, 250, 770, 490)
    panel(7, 'LEVEL END: TALLY AND GRADE', st[2].crop((140, 180, 780, 630)), [s.crop(box) for s in st],
          ['What: at the exit the level hangs its tally in the air in front of you, like a pinball end-of-ball bonus:',
           'kills, items and secrets count up as in Doom\'s own tally, each converts into BONUS points that roll into your Score, then the grade slams in.',
           'Grades S (top), A, B, C, D. Where: 7 m ahead over the exit line, until you step through; you can read it while walking.'],
          ['Fonts: labels = Doom II STCFN (SmallFont, red); figures = Doom II STTNUM (status-bar numerals; this IWAD\'s WINUM 0 reads as a diamond); BONUS = RSSCFON gold;',
           '       LEVEL CLEAR = JFO small; the grade = JFO small, tinted gold. Colours: IWAD red as drawn, Score gold #FFD030, PLAYPAL 160 gold + 231 yellow glow for S.',
           'Size: rows 0.28 m at 7 m (2.3 deg), LEVEL CLEAR 0.32 m, grade letter 1.4 m (11 deg). Motion: rows count up one after another (~0.4 s each), S slams.',
           'Background: rig frame, Doom II MAP04 corridor 7 m short of the exit line (linedef special 52 at x 2208), level cleared (kill monsters).'],
          os.path.join(OUT, 'p7_level_end_grade.png'),
          ['counting: 0', 'counting: 4250', 'done: 8500, grade S'])

STC = {c: g for c, g in F.STC.items()}
P7BG = 'F6b/f00024'


# ---------------------------------------------------------------- 2 DANGER FLASH
def p2():
    base = fr('R2b/f00016')
    tx, ty = 476, 612        # the centre Imp's fireball: on a line to your head
    mx, my = 287, 716        # the near ball: already going wide left, no flash
    R = pl(176)
    def scene(on):
        im = base.copy()
        if on > 0:
            for rr, aa in ((22 + 8 * on, 1.0), (34 + 12 * on, 0.55)):   # a ripple, not a crosshair: lock-on owns the ticks
                put(im, ring(int(rr), R, thick=3, ticks=0, px=2, glow_r=int(6 + 6 * on)), tx, ty, alpha=min(1, on) * aa)
            # the ball's own red flash: a hot halo in its place
            halo = Image.new('RGBA', (120, 120), (0, 0, 0, 0)); ImageDraw.Draw(halo).ellipse([40, 40, 80, 80], fill=R + (255,))
            halo = halo.filter(ImageFilter.GaussianBlur(10))
            put(im, halo, tx, ty, alpha=0.8 * on)
            ex = word_any(F.DBIG, '!', 30, None, None)
            put(im, ex, tx, ty - 62, R, 6, 1.2 * on, 2, alpha=min(1, on))
        return im
    st = [scene(1.0), scene(0.0), scene(1.3)]
    box = (240, 470, 700, 790)
    panel(2, 'DANGER FLASH', st[2].crop((150, 330, 790, 780)), [s.crop(box) for s in st],
          ['What: of all the shots in the air, only the one that will hit you flashes red, so you know which one to dodge.',
           'Here the centre Imp\'s fireball is on a line to your head: it gets a red halo, a red ripple and a "!" (no crosshair ticks: those mean lock-on).',
           'The big fireball in front is already going wide to your left: it does not flash. The flash beats ~4 times a second until it hits or you move out.'],
          ['Font: DBIGFONT "!" (Doom II big font). Colour: PLAYPAL 176 red only (no other colour means danger), glow in the same red.',
           'Size: inner ripple ~5 deg, outer ~8 deg, opening on each beat; "!" ~3 deg tall. Nothing on the screen edges: it sits on the shot itself.',
           'Background: rig frame, Doom II MAP02, three BD22 Imps (FireBall_SlaughterFest projectiles in flight), QZD 17.3 left eye.'],
          os.path.join(OUT, 'p2_danger_flash.png'),
          ['beat on', 'beat off (0.12 s)', 'next beat, stronger'])

if __name__ == '__main__':
    for n in sys.argv[1:]: globals()[n]()
