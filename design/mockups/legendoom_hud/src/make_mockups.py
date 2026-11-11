#!/usr/bin/env python3
"""LegenDoom HUD redesign mockups (owner 11-11 15:05: "the legendoom hud is a nightmare, we need to redesign it in our
style"). Mockups only: no mod code is touched. Code only, no rig run (owner 11-11 15:07): the base is an EXISTING rig
frame (2026-11-10 batch, launch P3A, frame f00144, 480 px per eye, shown 2x nearest = 960) and "today" is rebuilt from
LegenDoom 3.0's ACS / TEXTURES / fonts, not captured.

  python3 -I design/mockups/legendoom_hud/src/make_mockups.py <LegenDoom_3.0 unzipped dir> <base frame> <MGUNA0.png>

Reads: LegenDoom's own fonts (ZD2012, MINIPLIC: FON2) and art (E_MURDER, ECHGZ0, HUDBOX5); the series' fonts
(Score/RSSCFN2.fon2, the IWAD's STCFN / STYSNUM, VisualRewards' QVW glyphs); BD22's MGUNA0 (the Minigun's pickup
sprite, which LD mode's RSLD_LegendaryPickup wears). Writes the PNGs one folder up.
"""
import importlib.util, os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)
REPO = os.path.abspath(os.path.join(OUT, '..', '..', '..'))
LD, BASE, MGUN = sys.argv[1], sys.argv[2], sys.argv[3]
WAD = '/home/claude/gamedata/doom2.wad'

spec = importlib.util.spec_from_file_location('fs', os.path.join(REPO, 'design', 'mockups', 'fonts', 'make_font_sheets.py'))
fs = importlib.util.module_from_spec(spec); spec.loader.exec_module(fs)

# ---- fonts -----------------------------------------------------------------------------------------------------------
ZD, _ = fs.fon2(open(os.path.join(LD, 'ZD2012'), 'rb').read())        # LegenDoom's title font (EffectScreen)
MP, _ = fs.fon2(open(os.path.join(LD, 'MINIPLIC'), 'rb').read())      # LegenDoom's description font
CB, _ = fs.fon2(open(os.path.join(REPO, 'Score', 'RSSCFN2.fon2'), 'rb').read())   # Score's breakdown / combo font
wad = fs.Wad(WAD)
SF = {c: wad.patch('STCFN%03d' % c) for c in range(33, 96) if wad.patch('STCFN%03d' % c)}   # IWAD SmallFont
YN = {48 + i: wad.patch('STYSNUM%d' % i) for i in range(10)}                              # INDEXFONT_DOOM
QV = os.path.join(REPO, 'VisualRewards', 'pk3', 'graphics', 'rsqvrw')

# LegenDoom's rarity colours (LEGENDINF.acs rarityColors[]: CR_GREEN, CR_BLUE, CR_PURPLE, CR_ORANGE), as ramps
RAR = {'common': ((0, 60, 0), (90, 255, 90)), 'uncommon': ((0, 20, 90), (110, 150, 255)),
       'rare': ((60, 0, 70), (230, 110, 255)), 'epic': ((90, 40, 0), (255, 190, 70))}
EPIC = (255, 160, 40)
CARD_FILL = (0x17, 0x0D, 0x26)      # GBOVR skin A (rsq/ui/skin_a_menus.zs RSQUI_A_Look)
CARD_DARK = (0x0C, 0x08, 0x18)
GREY = (0xB4, 0xB4, 0xBC); WHITE = (0xF2, 0xF2, 0xF2); GOLD = (0xF0, 0xC0, 0x20)


def txt(font, s, lo, hi, scale=1.0, space=4, gap=1):
    gl = []
    for ch in s:
        g = font.get(ord(ch)) or font.get(ord(ch.upper()))
        gl.append(g if g is not None else Image.new('RGBA', (space, 1), (0, 0, 0, 0)))
    im = fs.tint(fs.row(gl, 1, gap), lo, hi)
    if scale != 1: im = im.resize((max(1, round(im.width * scale)), max(1, round(im.height * scale))), Image.NEAREST)
    return im


def ld(path):
    return Image.open(os.path.join(LD, path)).convert('RGBA')


def sc(im, k):
    return im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.NEAREST)


def put(dst, im, x, y, anchor='lt', alpha=1.0):
    """anchor: l/c/r + t/m/b"""
    if alpha < 1:
        im = im.copy(); a = im.split()[3].point(lambda v: int(v * alpha)); im.putalpha(a)
    ax = {'l': 0, 'c': im.width // 2, 'r': im.width}[anchor[0]]
    ay = {'t': 0, 'm': im.height // 2, 'b': im.height}[anchor[1]]
    dst.alpha_composite(im, (int(x - ax), int(y - ay)))


def glow(im, col, r=3, k=1.6):
    a = im.split()[3].filter(ImageFilter.GaussianBlur(r)).point(lambda v: min(255, int(v * k)))
    g = Image.new('RGBA', im.size, col + (0,)); g.putalpha(a); return g


def pad(im, p):
    o = Image.new('RGBA', (im.width + 2 * p, im.height + 2 * p), (0, 0, 0, 0)); o.alpha_composite(im, (p, p)); return o


# ---- SOTN style A words (design/mockups/sotn_words/mock.py, the look the owner picked: two-tone, dark box) ------------
def qv(c):
    p = os.path.join(QV, 'QVW%03d.png' % ord(c))
    return Image.open(p).convert('RGBA') if os.path.exists(p) else None


def sotn(word, h, top, bot, box=2):
    gs = [qv(c) for c in word]
    gs = [g.resize((max(1, int(g.width * h / g.height)), h), Image.NEAREST) if g else None for g in gs]
    w = sum((g.width if g else h // 2) + 1 for g in gs)
    m = Image.new('L', (w, h), 0); x = 0
    for g in gs:
        if g:
            r, gg, b, a = g.split(); lum = Image.merge('RGB', (r, gg, b)).convert('L')
            m.paste(lum.point(lambda v: v if v > 75 else 0), (x, 0), a); x += g.width + 1
        else: x += h // 2 + 1
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0)); px = im.load(); mp = m.load()
    for y in range(h):
        c = top if y < h / 2 else bot
        for xx in range(w):
            if mp[xx, y]:
                k = 0.55 + 0.45 * mp[xx, y] / 255.0
                px[xx, y] = tuple(min(255, int(v * k * 1.15)) for v in c) + (255,)
    out = Image.new('RGBA', (w + 2 * box, h + 2 * box), (0, 0, 0, 0)); a = im.split()[3]
    for dx in range(-box, box + 1):
        for dy in range(-box, box + 1):
            out.paste(Image.new('RGBA', im.size, (8, 8, 10, 255)), (box + dx, box + dy), a)
    out.alpha_composite(im, (box, box)); return out


# ---- the HUD plane on this frame ---------------------------------------------------------------------------------------
# Measured on the base frame (2x of P3A f00144): the status bar (320 units wide, its bottom the bottom of the screen)
# spans x 310..695, bottom y 736, so 1 unit = 1.203 px and a 320x240 HudMessage screen (SetHudSize 320, 240) is
# x 310..695, y 447..736. Gun Bonsai VR's gauges sit at its top (y 448), which agrees. Estimate: the engine's own VR
# HUD projection was not read for this.
S = 385 / 320.0
def U(u, v): return 310 + u * S, 447 + v * S


def base():
    return Image.open(BASE).convert('RGBA').resize((960, 960), Image.NEAREST)


# ---- page layout -----------------------------------------------------------------------------------------------------
FT = '/usr/share/fonts/truetype/dejavu/'
F_T = ImageFont.truetype(FT + 'DejaVuSans-Bold.ttf', 30)
F_S = ImageFont.truetype(FT + 'DejaVuSans.ttf', 17)
F_L = ImageFont.truetype(FT + 'DejaVuSans-Bold.ttf', 17)
F_B = ImageFont.truetype(FT + 'DejaVuSans.ttf', 16)


def page(name, title, sub, frame, insets, bullets, ih=330):
    """frame: the 960 composite at rig scale; insets: [(label, image, crop box)]; bullets: [(head, text)]"""
    W, H = 1940, 1090
    pg = Image.new('RGBA', (W, H), (16, 14, 20, 255)); d = ImageDraw.Draw(pg)
    d.text((20, 14), title, font=F_T, fill=(255, 205, 110))
    d.text((20, 54), sub, font=F_S, fill=(170, 170, 180))
    pg.alpha_composite(frame, (10, 90))
    d.rectangle((10, 90, 969, 1049), outline=(70, 60, 90))
    d.text((14, 1056), 'rig scale: base frame P3A f00144 (480 px per eye, shown 2x). Mockup, not a capture.', font=F_B, fill=(150, 150, 160))
    x0, y = 990, 90
    for label, im, box in insets:
        cr = im.crop(box)
        k = min(930 / cr.width, ih / cr.height)
        z = cr.resize((int(cr.width * k), int(cr.height * k)), Image.NEAREST)
        d.text((x0, y), label, font=F_L, fill=(220, 220, 230)); y += 24
        pg.alpha_composite(z, (x0, y)); d.rectangle((x0, y, x0 + z.width - 1, y + z.height - 1), outline=(70, 60, 90))
        y += z.height + 14
    for head, t in bullets:
        d.text((x0, y), head, font=F_L, fill=(255, 205, 110))
        # wrap
        words, line, yy = t.split(), '', y
        xx = x0 + int(d.textlength(head + '  ', font=F_L))
        for w in words:
            if d.textlength(line + w + ' ', font=F_B) > 930 - (xx - x0):
                d.text((xx, yy), line, font=F_B, fill=(210, 210, 215)); yy += 20; line = ''; xx = x0 + 14
            line += w + ' '
        d.text((xx, yy), line, font=F_B, fill=(210, 210, 215)); y = yy + 26
    pg.convert('RGB').save(os.path.join(OUT, name), optimize=True)
    return pg


# ---- 00: today, rebuilt from LegenDoom's code ---------------------------------------------------------------------------
def today():
    f = base()
    # LEGNDLIB.acs "EffectScreen" (SetHudSize 320 x 240), for an Epic Murderous drop on the chaingun slot (the Rifle's family
    # in LD mode): title ZD2012 in the rarity colour, centred, top at y 20; the weapon icon LCHGEPIC (ECHGZ0 at scale 0.3:
    # 240 x 73 units) centred at 160,120; the effect icon E_MURDER (42 x 42 units) at 160,153.6; the description in MINIPLIC
    # centred, top at y 180. Holds 7.5 s + 2.5 s fade; Use, Fire or Alt-fire clears it.
    t = txt(ZD, 'Murderous Chaingun', *RAR['epic'], S, gap=0)
    put(f, t, *U(160, 20), 'ct')
    wi = ld('sprites/Chaingun/ECHGZ0'); wi = wi.resize((round(240 * S), round(73 * S)), Image.NEAREST)
    put(f, wi, *U(160, 120), 'cm')
    ei = ld('graphics/EffectIcons/Epic/E_MURDER'); ei = sc(ei, S)
    put(f, ei, *U(160, 240 / 1.6), 'cm')
    d1 = txt(MP, 'Killing enemies gives you a short, extendable 3x damage boost', (90, 90, 90), (255, 255, 255), S, gap=0)
    put(f, d1, *U(160, 180), 'ct')
    d2 = txt(MP, "''I'm a freight train o' death!''", (110, 50, 0), (255, 170, 60), S, gap=0)
    put(f, d2, *U(160, 180 + 2 * 10), 'ct')
    # LEGENDPLY.acs "LDPlayerLoop": each running buff, a row from x 160 at the top: HUDBOX5 frame, the I_ icon (42 px at
    # scale 6 = 7 units), the seconds in INDEXFONT_DOOM (STYSNUM) in the rarity's colour (Murderous: CR_ORANGE)
    bx = ld('graphics/HUD/HUDBOX5'); put(f, sc(bx, S), *U(160, 6), 'ct')
    put(f, sc(ld('graphics/EffectIcons/Epic/E_MURDER'), S * 7 / 42), *U(160, 16), 'ct')
    put(f, fs.tint(fs.text_with(YN, '7', 1), (110, 50, 0), (255, 170, 60)).resize((round(4 * S), round(6 * S)), Image.NEAREST), *U(161, 24), 'cm')
    # the console / notify copy (HUDMSG_LOG) and Upgrading's centre Print: not drawn here (see README)
    page('00_today_from_code.png', 'LegenDoom today (rebuilt from its code, not captured)',
         'The pickup screen (EffectScreen) at 320x240 on the shared HUD plane, plus the buff-timer row. 10 s; Fire clears it.',
         f, [('HUD plane, zoomed: the pickup screen lands on the Gun Bonsai VR gauges and the Score line', f, (220, 430, 800, 745))],
         [('Covers', 'the gauges, Score and the view centre for up to 10 s, at the moment a fight just ended.'),
          ('Dismiss', 'Use, Fire or Alt-fire: Fire also fires the gun in your hand.'),
          ('Names', 'LegenDoom\'s own: "Chaingun" for a drop that powers the Rifle / Minigun family.'),
          ('Icon', 'the Doom sprite of LegenDoom\'s chaingun (not our gun), 240 units wide.'),
          ('Timers', 'buff seconds as tiny yellow numerals in a box at the top, over the gauges.'),
          ('Monster', 'nothing on the HUD: no name, level or bar. A legendary looks normal until half health, then a pentagram of particles, red/black after-images.')], ih=600)


# ---- A: fold into Gun Bonsai VR (gauge row + one level-up style card) ------------------------------------------------------
def card(w, h, col, title, sub, desc, icon):
    c = Image.new('RGBA', (w, h), (0, 0, 0, 0)); d = ImageDraw.Draw(c)
    d.rectangle((0, 0, w - 1, h - 1), fill=CARD_FILL + (235,))
    d.rectangle((0, 0, w - 1, h - 1), outline=col + (255,), width=2)
    d.rectangle((3, 3, w - 4, h - 4), outline=tuple(int(v * 0.45) for v in col) + (255,), width=1)
    tt = txt(SF, title, tuple(v // 3 for v in col), col, 1)
    if tt.width > w - 10: tt = sc(tt, (w - 10) / tt.width)
    put(c, tt, w // 2, 6, 'ct')
    st = txt(CB, sub, (90, 90, 95), GREY, 1); put(c, st, w // 2, 6 + tt.height + 3, 'ct')
    y = 6 + tt.height + st.height + 8
    for line in desc:
        lt = txt(CB, line, (120, 120, 120), WHITE, 1); put(c, lt, 7, y); y += lt.height + 3
    bs = 38; bx, by = w - bs - 7, h - bs - 7
    d.rectangle((bx, by, bx + bs, by + bs), fill=CARD_DARK + (255,), outline=col + (255,), width=1)
    put(c, sc(icon, (bs - 6) / icon.width), bx + bs // 2 + 1, by + bs // 2 + 1, 'cm')
    return c


def dir_a():
    ic = ld('graphics/EffectIcons/Epic/E_MURDER')
    f1 = base()
    # under the gun hand's gauge octagon (right, x 585..615), outward, clear of Score's line (x 505..570): a rarity pip +
    # the power's name in Score's combo font, rarity colour, and a drain line for the running buff (Murderous: x3).
    # Nothing at the top of the view.
    gx, gy = 584, 485
    row = txt(CB, 'MURDEROUS', *RAR['epic'], 1)
    put(f1, sc(ic, 9 / 42), gx, gy)
    put(f1, glow(pad(row, 4), EPIC, 2, 0.9), gx + 11 - 4, gy - 4)
    put(f1, row, gx + 11, gy)
    d = ImageDraw.Draw(f1)
    x1 = gx + 11 + row.width
    d.rectangle((gx, gy + row.height + 3, x1, gy + row.height + 4), fill=(60, 30, 10, 255))
    d.rectangle((gx, gy + row.height + 3, gx + int((x1 - gx) * 0.6), gy + row.height + 4), fill=EPIC + (255,))
    xt = txt(CB, 'X3', (110, 80, 0), (255, 230, 120), 1); put(f1, xt, x1 + 3, gy, 'lt')
    # the gauge octagon's edge takes the rarity colour as a corner tick (the cycle keeps running on the rest)
    d.line((598, 449, 615, 449), fill=EPIC + (255,), width=2); d.line((615, 449, 615, 465), fill=EPIC + (255,), width=2)
    # state 2: the pickup, as ONE Gun Bonsai VR level-up card, on the HUD plane, not a menu: no key to close, 3 s, then
    # it folds into the gauge row above
    f2 = f1.copy()
    c = card(150, 104, EPIC, 'MURDEROUS', 'EPIC  RIFLE / MINIGUN',
             ['KILLS GIVE A SHORT,', 'EXTENDABLE', '3X DAMAGE BOOST'], ic)
    put(f2, glow(pad(c, 6), EPIC, 4, 0.5), 503, 512 - 6, 'ct')
    put(f2, c, 503, 512, 'ct')
    page('A_gunbonsai_gauge_and_card.png', 'Direction A: fold it into Gun Bonsai VR',
         'The power lives under the gun hand\'s gauge; the pickup is one Gun Bonsai VR card for 3 s that folds into that row.',
         f2, [('In play: a row under the gun hand\'s gauge: icon, name, X3 and its drain; a rarity tick', f1, (380, 440, 700, 512)),
              ('On pickup: one Gun Bonsai VR style card, 3 s, no key, then it folds into the row', f2, (380, 440, 700, 625))],
         [('Keeps', 'rarity colours, the power name, LegenDoom\'s icon art, the buff timer.'),
          ('Moves', 'name and timer under the gauge of the hand holding the gun; pickup screen into a GBOVR card.'),
          ('Drops', 'the 240-unit Doom sprite, the quote, Fire-to-close, the top-of-view timer row, LD\'s weapon names.'),
          ('Shares', 'HUD space with GBOVR and Score: the row pushes Score\'s line like a drawn ShieldSaw gauge does.')])


# ---- B: words in the world over the monster and the drop (SOTN style A) --------------------------------------------------
def dir_b():
    f1 = base()
    # a dormant legendary in view the first time: LEGENDARY over its head, gold two-tone, billboard glyphs
    w = sotn('LEGENDARY', 14, (240, 150, 20), (255, 236, 120))
    put(f1, w, 168, 428, 'cb')
    # state 2: it rises at half health (LDMonsterInit): RISEN! in red, LegenDoom's own pentagram and after-images stay
    f2 = base(); d = ImageDraw.Draw(f2)
    mon = f2.crop((110, 435, 225, 655)); r = mon.copy(); px = r.load()
    for y in range(r.height):
        for x in range(r.width):
            p = px[x, y]
            if p[0] + p[1] + p[2] > 120: px[x, y] = (200, 20, 20, 110)
            else: px[x, y] = (0, 0, 0, 0)
    f2.alpha_composite(r, (104, 437))
    import math
    cx, cy, rx, ry = 168, 650, 70, 14
    for i in range(5):
        a1 = math.radians(-90 + i * 144); a2 = math.radians(-90 + (i + 1) * 144)
        d.line((cx + rx * math.cos(a1), cy + ry * math.sin(a1), cx + rx * math.cos(a2), cy + ry * math.sin(a2)), fill=(255, 40, 30, 255), width=2)
    d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), outline=(255, 40, 30, 255), width=2)
    rw = sotn('RISEN!', 18, (255, 80, 90), (255, 140, 140), 3)
    put(f2, rw, 168, 426, 'cb')
    # state 3: the drop: our Minigun (LD mode's pickup) glowing, EPIC over it, the power's name under, in the world
    f3 = base()
    mg = sc(Image.open(MGUN).convert('RGBA'), 1.6)
    put(f3, glow(pad(mg, 8), EPIC, 6, 1.2), 470, 840, 'cb'); put(f3, mg, 470, 832, 'cb')
    put(f3, sotn('EPIC', 13, (240, 150, 20), (255, 236, 120)), 470, 776, 'cb')
    put(f3, sotn('MURDEROUS', 8, (200, 200, 205), (255, 255, 255), 2), 470, 790, 'cb')
    # the running buff as a word over the gun hand (moves with the gun): X3 and the seconds
    put(f3, sotn('X3', 12, (240, 150, 20), (255, 236, 120)), 640, 600, 'cb')
    put(f3, txt(SF, '7S', (120, 120, 120), WHITE, 1.4), 662, 598, 'lb')
    # page frame: the legendary named, the drop, the buff (three moments drawn on one frame for the left side)
    full = base(); put(full, w, 168, 428, 'cb')
    full.alpha_composite(f3.crop((380, 560, 720, 860)), (380, 560))
    page('B_world_words_sotn.png', 'Direction B: words in the world (SOTN style A)',
         'Billboard glyphs over the legendary, over its drop and over the gun; the HUD plane is left to GBOVR and Score.',
         full, [('A legendary in view: LEGENDARY over it (once, then the VisualRewards gem stays)', f1, (60, 390, 300, 520)),
                ('It rises at half health: RISEN! in red; LegenDoom\'s pentagram and after-images stay as they are', f2, (40, 390, 300, 680)),
                ('Its drop: our gun (LD mode\'s pickup) glowing, EPIC and the power over it', f3, (390, 750, 550, 850)),
                ('The running buff: X3 and its seconds over the gun, moving with the hand', f3, (560, 560, 760, 640))],
         [('Keeps', 'rarity colours, the power name, LegenDoom\'s monster effects (pentagram, after-images).'),
          ('Moves', 'the pickup screen to words over the drop, seen BEFORE you take it; the buff to the gun.'),
          ('Adds', 'LEGENDARY / RISEN! over the monster: LegenDoom shows nothing for it today.'),
          ('Drops', 'everything LegenDoom puts on the HUD plane. The description goes to the Wheel card / status screen.')], ih=170)


# ---- C: a compact wrist panel on the off hand ----------------------------------------------------------------------------
def panel(flash=False):
    w, h = 250, 78
    p = Image.new('RGBA', (w, h), (0, 0, 0, 0)); d = ImageDraw.Draw(p)
    d.rectangle((0, 0, w - 1, h - 1), fill=(10, 8, 14, 225))
    d.rectangle((0, 0, w - 1, h - 1), outline=(EPIC if flash else (90, 70, 110)) + (255,), width=3 if flash else 1)
    d.rectangle((0, 0, 4, h - 1), fill=EPIC + (255,))                         # rarity stripe
    ic = ld('graphics/EffectIcons/Epic/E_MURDER')
    d.rectangle((10, 8, 44, 42), fill=CARD_DARK + (255,), outline=EPIC + (255,))
    put(p, sc(ic, 32 / 42), 27, 25, 'cm')
    put(p, txt(CB, 'MURDEROUS', *RAR['epic'], 2), 52, 8)
    put(p, txt(CB, 'EPIC  RIFLE', (90, 90, 95), GREY, 1), 52, 26)
    # the buff: seconds in the IWAD SmallFont gold (Score's wrist digits) and a drain bar
    put(p, txt(SF, '07', (110, 80, 0), GOLD, 1.6), w - 8, 10, 'rt')
    put(p, txt(CB, 'X3', (110, 80, 0), (255, 230, 120), 1), w - 8, 30, 'rt')
    d.rectangle((52, 38, w - 40, 40), fill=(60, 30, 10, 255)); d.rectangle((52, 38, 52 + int((w - 92) * 0.6), 40), fill=EPIC + (255,))
    # the other hand's gun
    d.line((10, 50, w - 8, 50), fill=(50, 45, 60, 255))
    put(p, txt(CB, 'OFF  MOONLIGHT', (90, 90, 95), GREY, 1), 10, 56)
    put(p, txt(CB, 'NO POWER', (60, 60, 65), (120, 120, 128), 1), w - 8, 56, 'rt')
    return p


def skew(im, k=0.18):
    w, h = im.size
    return im.transform((w, int(h + w * k)), Image.AFFINE, (1, 0, 0, -k, 1, 0), Image.BILINEAR)


def dir_c():
    f1 = base()
    pn = skew(panel())
    put(f1, pn, 40, 900, 'lb')
    f2 = base()
    put(f2, glow(pad(skew(panel(True)), 8), EPIC, 6, 1.0), 32, 908, 'lb'); put(f2, skew(panel(True)), 40, 900, 'lb')
    put(f2, sotn('EPIC!', 16, (240, 150, 20), (255, 236, 120), 3), 165, 770, 'cb')
    page('C_wrist_panel.png', 'Direction C: a compact wrist panel',
         'On the off hand\'s wrist, where Score\'s wrist digits and the remote panel already live; nothing on the HUD plane.',
         f1, [('In play: both guns\' powers, the running buff\'s seconds and drain, on the wrist (look to read it)', f1, (20, 730, 330, 920)),
              ('On pickup: the panel flashes in the rarity colour and EPIC! pops over it for a second', f2, (20, 730, 330, 920))],
         [('Keeps', 'rarity colours, power names, LegenDoom\'s icon, the buff timer; both hands at a glance.'),
          ('Moves', 'everything LegenDoom draws to one panel you look at when you choose to (watch check).'),
          ('Drops', 'the pickup screen, the top-of-view row, the description (Wheel card / status screen has it).'),
          ('Note', 'needs the off hand free to read; with a saber or shield in it the panel shares that wrist.')])



# ---- D: B's monster words + A's pickup card (owner 11-11 15:22) -----------------------------------------------------------
# LegenDoom's four rarities (LEGENDINF.acs rarityColors[]: CR_GREEN, CR_BLUE, CR_PURPLE, CR_ORANGE; LegenDoom 3.0 has no
# fifth "legendary" rarity: Epic is the top), with one chaingun-slot power of each (decorate/Chaingun, LANGUAGE.effect*)
RARS = [('COMMON', (90, 230, 90), (40, 140, 40), (150, 255, 120), 'Common/E_DETERM', 'DETERMINED',
         ['WHILE NOT', 'ATTACKING, MAKES', 'YOU 50% TOUGHER']),
        ('UNCOMMON', (100, 150, 255), (40, 80, 200), (170, 210, 255), 'Uncommon/E_BERSER', 'BERSERKER',
         ['MORE DAMAGE THE', 'LOWER YOUR HEALTH']),
        ('RARE', (220, 110, 255), (130, 40, 170), (240, 180, 255), 'Rare/E_VAMPIR', 'VAMPIRIC',
         ['ATTACKS DRAIN LIFE', 'FROM ENEMIES']),
        ('EPIC', EPIC, (240, 150, 20), (255, 236, 120), 'Epic/E_MURDER', 'MURDEROUS',
         ['KILLS GIVE A SHORT,', 'EXTENDABLE', '3X DAMAGE BOOST'])]


def card2(r, gun='RIFLE', icon=True, shimmer=None, w=150, h=104):
    """r: a RARS row. gun: the name on the sub line. icon: the icon box. shimmer: None, 0 or 1 (SOTN's two looks)."""
    name, col, top, bot, icp, power, desc = r
    c = Image.new('RGBA', (w, h), (0, 0, 0, 0)); d = ImageDraw.Draw(c)
    d.rectangle((0, 0, w - 1, h - 1), fill=CARD_FILL + (235,))
    d.rectangle((0, 0, w - 1, h - 1), outline=col + (255,), width=2)
    d.rectangle((3, 3, w - 4, h - 4), outline=tuple(int(v * 0.45) for v in col) + (255,), width=1)
    if shimmer is None:
        tt = txt(SF, power, tuple(v // 3 for v in col), col, 1)
    else:   # SOTN style A: two-tone, dark box, flashing between two looks
        looks = [(top, bot), (tuple(min(255, v + 70) for v in top), (255, 255, 235))]
        tt = sotn(power, 9, *looks[shimmer], 1)
    if tt.width > w - 10: tt = sc(tt, (w - 10) / tt.width)
    put(c, tt, w // 2, 5, 'ct')
    st = txt(CB, name + '  ' + gun, (90, 90, 95), GREY, 1); put(c, st, w // 2, 5 + tt.height + 3, 'ct')
    y = 5 + tt.height + st.height + 8
    ic = ld('graphics/EffectIcons/' + icp)
    if icon:
        for line in desc:
            lt = txt(CB, line, (120, 120, 120), WHITE, 1); put(c, lt, 7, y); y += lt.height + 3
        bs = 38; bx, by = w - bs - 7, h - bs - 7
        d.rectangle((bx, by, bx + bs, by + bs), fill=CARD_DARK + (255,), outline=col + (255,), width=1)
        put(c, sc(ic, (bs - 6) / ic.width), bx + bs // 2 + 1, by + bs // 2 + 1, 'cm')
    else:   # no box: the text takes the card, centred; a rarity bar at the foot
        y += 4
        for line in desc:
            lt = txt(CB, line, (120, 120, 120), WHITE, 1); put(c, lt, w // 2, y, 'ct'); y += lt.height + 4
        d.rectangle((10, h - 12, w - 11, h - 10), fill=col + (255,))
    return c


def gauge_row(f, r=RARS[3]):
    name, col, top, bot, icp, power, desc = r
    gx, gy = 584, 485
    row = txt(CB, power, tuple(v // 3 for v in col), col, 1)
    put(f, sc(ld('graphics/EffectIcons/' + icp), 9 / 42), gx, gy)
    put(f, glow(pad(row, 4), col, 2, 0.9), gx + 11 - 4, gy - 4); put(f, row, gx + 11, gy)
    d = ImageDraw.Draw(f); x1 = gx + 11 + row.width
    d.rectangle((gx, gy + row.height + 3, x1, gy + row.height + 4), fill=(60, 30, 10, 255))
    d.rectangle((gx, gy + row.height + 3, gx + int((x1 - gx) * 0.6), gy + row.height + 4), fill=col + (255,))
    put(f, txt(CB, 'X3', (110, 80, 0), (255, 230, 120), 1), x1 + 3, gy)
    d.line((598, 449, 615, 449), fill=col + (255,), width=2); d.line((615, 449, 615, 465), fill=col + (255,), width=2)


def gun_x3(f):
    put(f, sotn('X3', 12, (240, 150, 20), (255, 236, 120)), 640, 600, 'cb')
    put(f, txt(SF, '7S', (120, 120, 120), WHITE, 1.4), 662, 598, 'lb')


def legendary(f):
    put(f, sotn('LEGENDARY', 14, (240, 150, 20), (255, 236, 120)), 168, 428, 'cb')


def risen(f):
    import math
    d = ImageDraw.Draw(f)
    r = f.crop((110, 435, 225, 655)); px = r.load()
    for y in range(r.height):
        for x in range(r.width):
            p = px[x, y]
            px[x, y] = (200, 20, 20, 110) if p[0] + p[1] + p[2] > 120 else (0, 0, 0, 0)
    f.alpha_composite(r, (104, 437))
    cx, cy, rx, ry = 168, 650, 70, 14
    for i in range(5):
        a1 = math.radians(-90 + i * 144); a2 = math.radians(-90 + (i + 1) * 144)
        d.line((cx + rx * math.cos(a1), cy + ry * math.sin(a1), cx + rx * math.cos(a2), cy + ry * math.sin(a2)), fill=(255, 40, 30, 255), width=2)
    d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), outline=(255, 40, 30, 255), width=2)
    put(f, sotn('RISEN!', 18, (255, 80, 90), (255, 140, 140), 3), 168, 426, 'cb')


def drop(f):
    mg = sc(Image.open(MGUN).convert('RGBA'), 1.6)
    put(f, glow(pad(mg, 8), EPIC, 6, 1.2), 470, 840, 'cb'); put(f, mg, 470, 832, 'cb')
    put(f, sotn('EPIC', 13, (240, 150, 20), (255, 236, 120)), 470, 776, 'cb')
    put(f, sotn('MURDEROUS', 8, (200, 200, 205), (255, 255, 255), 2), 470, 790, 'cb')


def with_card(f, c=None, alpha=1.0, y=512):
    c = c or card2(RARS[3])
    put(f, glow(pad(c, 6), EPIC, 4, 0.5), 503, y - 6, 'ct', alpha); put(f, c, 503, y, 'ct', alpha)


def dir_d():
    # 1. overview
    scene = base(); legendary(scene); with_card(scene)
    o1 = base(); gauge_row(o1)
    o2 = base(); gun_x3(o2)
    page('D_overview.png', 'Direction D: B\'s monster words + A\'s pickup card',
         'LEGENDARY over the monster (left, with the card you get on taking its drop, two moments on one frame). Then pick one:',
         scene, [('Option 1: the power stays in a row under the gun hand\'s gauge (HUD plane, A)', o1, (380, 440, 700, 512)),
                 ('Option 2: the power stays as X3 and its seconds over the gun, moving with it (world, B)', o2, (520, 540, 760, 660))],
         [('Monster', 'LEGENDARY on sight, RISEN! in red with LegenDoom\'s pentagram and after-images (B).'),
          ('Pickup', 'one Gun Bonsai VR card, 3 s, no key, in the rarity colour (A). Variants: D_card_variants.png.'),
          ('After', 'option 1 (gauge row) or option 2 (X3 over the gun): the card folds into whichever is picked.'),
          ('Drops', 'LegenDoom\'s pickup screen, Fire-to-close, the buff row at the top of the view.')], ih=300)

    # 2. card variants: row 1 the four rarities (V4 layout), row 2 the four versions on Epic
    Z = 3
    cols = []
    for r in RARS: cols.append((r[0] + ': ' + r[5], card2(r)))
    vars_ = [('V1  LegenDoom\'s name (CHAINGUN), icon box', card2(RARS[3], gun='CHAINGUN')),
             ('V2  No icon box (text centred, rarity bar)', card2(RARS[3], icon=False)),
             ('V3  SOTN A title shimmer (look 1 / look 2)', None),
             ('V4  Our gun\'s name (BD22 VR\'s Rifle), icon box', card2(RARS[3]))]
    W, H = 1940, 1150
    pg = Image.new('RGBA', (W, H), (16, 14, 20, 255)); d = ImageDraw.Draw(pg)
    d.text((20, 14), 'Direction D: the pickup card, variants', font=F_T, fill=(255, 205, 110))
    d.text((20, 54), 'Gun Bonsai VR level-up card style (skin A: #170D26 fill, double outline in the card colour, SmallFont title). '
           'Drawn at rig scale (150 x 104 px on the 960 frame), shown 3x.', font=F_S, fill=(170, 170, 180))
    def row_at(y, items, head):
        d.text((20, y), head, font=F_L, fill=(255, 205, 110)); y += 28
        x = 20
        for label, c in items:
            d.text((x, y), label, font=F_L, fill=(220, 220, 230))
            if c is None:   # the shimmer: look 1 as the card, look 2's title strip under it (D_card_V3_shimmer.gif moves)
                a = sc(card2(RARS[3], shimmer=0), Z); pg.alpha_composite(a, (x, y + 26))
                b = sc(card2(RARS[3], shimmer=1).crop((0, 0, 150, 18)), Z)
                pg.alpha_composite(b, (x, y + 26 + a.height + 30))
                d.text((x, y + 26 + a.height + 6), 'look 2 (the title flashes between the two; see the GIF):', font=F_B, fill=(170, 170, 180))
            else:
                pg.alpha_composite(sc(c, Z), (x, y + 26))
            x += 470
        return y + 26 + 104 * Z + 20
    y = row_at(92, cols, 'Rarity frames: LegenDoom\'s four rarities, one chaingun-slot power each, V4 layout')
    row_at(y, vars_, 'Versions, on the Epic card')
    pg.convert('RGB').save(os.path.join(OUT, 'D_card_variants.png'), optimize=True)
    # the shimmer as a GIF (8 frames a look, as in sotn_words)
    fr = []
    for i in range(16):
        im = Image.new('RGBA', (150 * 3 + 20, 104 * 3 + 20), (16, 14, 20, 255))
        im.alpha_composite(sc(card2(RARS[3], shimmer=(i // 4) % 2), 3), (10, 10)); fr.append(im.convert('P', palette=Image.ADAPTIVE))
    fr[0].save(os.path.join(OUT, 'D_card_V3_shimmer.gif'), save_all=True, append_images=fr[1:], duration=70, loop=0)

    # 3. the sequence
    s1 = base(); legendary(s1)
    s2 = base(); risen(s2)
    s3 = base(); drop(s3)
    s4 = base(); with_card(s4)
    s5 = base(); gauge_row(s5); with_card(s5, sc(card2(RARS[3]), 0.5), 0.45, 492)
    d5 = ImageDraw.Draw(s5); d5.line((540, 500, 584, 490), fill=(255, 200, 120, 200), width=1)
    s6 = base(); gun_x3(s6); with_card(s6, sc(card2(RARS[3]), 0.5), 0.45, 540)
    d6 = ImageDraw.Draw(s6); d6.line((540, 560, 632, 592), fill=(255, 200, 120, 200), width=1)
    tiles = [('1  On sight: LEGENDARY over it', s1, (40, 380, 300, 670)),
             ('2  At half health: RISEN!, red after-images, pentagram', s2, (40, 380, 300, 670)),
             ('3  Its drop glows: EPIC and the power over it', s3, (370, 740, 570, 870)),
             ('4  Taken: the card, 3 s, no key', s4, (360, 430, 650, 630)),
             ('5a Then it folds into the gauge row (option 1)', s5, (360, 430, 700, 560)),
             ('5b ...or into X3 over the gun (option 2)', s6, (430, 480, 720, 640))]
    W, H = 1940, 1090
    pg = Image.new('RGBA', (W, H), (16, 14, 20, 255)); d = ImageDraw.Draw(pg)
    d.text((20, 14), 'Direction D: the moments in order', font=F_T, fill=(255, 205, 110))
    d.text((20, 54), 'Each tile is a crop of the same rig frame (P3A f00144) with the mockup drawn at rig scale, zoomed. '
           'Steps 5a and 5b: the card shrinking toward where it lands (mid-fold).', font=F_S, fill=(170, 170, 180))
    tw, th = 620, 440
    for i, (label, im, box) in enumerate(tiles):
        x = 20 + (i % 3) * (tw + 16); y = 92 + (i // 3) * (th + 50)
        d.text((x, y), label, font=F_L, fill=(220, 220, 230))
        cr = im.crop(box); k = min(tw / cr.width, th / cr.height)
        z = cr.resize((int(cr.width * k), int(cr.height * k)), Image.NEAREST)
        pg.alpha_composite(z, (x, y + 26)); d.rectangle((x, y + 26, x + z.width - 1, y + 26 + z.height - 1), outline=(70, 60, 90))
    pg.convert('RGB').save(os.path.join(OUT, 'D_sequence.png'), optimize=True)


if __name__ == '__main__':
    today(); dir_a(); dir_b(); dir_c(); dir_d()
    print('written to', OUT)
