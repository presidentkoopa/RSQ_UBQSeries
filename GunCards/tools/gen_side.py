#!/usr/bin/env python3
"""RSQ Gun Cards: THE WATCH CARD's pieces (owner 2026-10-31 02:47): the full card lies flat on the side of the gun at
the back of the grip hand, facing you when you check your watch knuckles up.

    python3 tools/gen_side.py          (no IWAD needed since v4: the text is JFO, card_art/jfo; the keys card_art/keys)

v4 (owner's design, 2026-11-03, approved from mockups gcmock/mock5.py cards 1, 3 and 4): no title row; three cards
(Weapon: MAG / RESERVE, the counts big, GRENADES, KILLS; Status: H / A, health and armour big, a row of key icons and
G:n; Both: MAG / RESERVE, the counts, "H 100" / "A 50", the key icons and G:n); all text JFO (jfo.py), proportional as
in the mockup, at two qualities (Quest = half-resolution glyphs, PCVR = full); the card 100 card px (13 cm) wide with
the mockup's 5 px padding.

WHERE (rig-measured, doom2 + BD22 VR, right hand knuckles up: gun across the body, twisted -90): the gun's outboard
side (model X -) faces the eyes; along the gun, model Y + reads left to right (the muzzle, Y -, is on the left); and
model Z + (the gun's top) is DOWN the card. So the card is the plane X = SIDE_X, its columns run along Y and its rows
along Z.

HOW (v3, 2026-11-02, kept): COLUMNS ARE BAKED, ROWS ARE TURNED. The engine indexes a sprite's first frame with 16 bits
(r_data/sprites.h spritedef_t.spriteframes is uint16_t), so the whole load order must stay under 65,535 sprite frames
(v2's 31,580 frames wrapped RSQ LaserSight's beam onto the card). Each glyph is baked once per set (font x quality),
family and column at a reference height (ROW_MID), and the row is a turn: the piece's turning point (VOXELDEF YOffset /
ZOffset: RenderHUDModel turns a layer's model about the point its offsets name, models.cpp:248-263) sits TURN_L cm back
along the forearm toward the player, at the reference height; a layer's y turns the model about the hand's right axis
(the card's normal) through that point (hw_weapon.cpp:108, (y - 32) / -4 degrees), which, that far away, lifts the
piece in the card's plane: side_states.zs ROW_Y is the exact turn per row and family. A layer has one turn, so only one
of the two card directions can be placed at run time; the other (the columns) is baked. A turn about a point to the
side of the hand (to slide columns instead) would slide the card off the wrist at another weapon scale.
THE ENGINE'S WEAPON SCALE (vr_weaponScale, default 1.02, models.cpp:277) scales the model about its turning point after
the offsets, so the baked pieces assume 1.02: any other value slides the whole watch card along the forearm by
(1.02 - scale) x 167 cm (3.3 cm at 1.00), panel and text together.

PROPORTIONAL TEXT ON BAKED COLUMNS (v4). JFO has two glyph widths (jfo.py NARROW_MAX: I : and a few more are half
width). The card's text area (90 px) is a grid of UNITS: the small font 25 units of 3.6 px (a glyph 2 units, a narrow one
1: mock5.py's advances, 7.14 and 3.78 px, within 0.4 px), the big digits 13 units of 6.92 px (a digit 2 units: the
mockup's 13.86 px). Every glyph is baked at every unit of its set, so left-aligned text starts at unit 0 and right-
aligned text ends at the last unit exactly as the mockup lays it.
THE KEYS: the voxel pack's own key voxels (Voxels/Keys/*KEYA / *SKUA.kvx, keycards by Ghostpilot, skulls by Voxelbro)
seen from the front (card_art/keys/vp_*.png), and Freedoom's status-bar keys (card_art/keys/fd_*.png, BSD) for when the
voxel pack is not loaded; each lit and dark grey (mock5.py dimmed()), at its slot: the three keycards at slots 0-2, the
three skulls at slots 0-2 on a skull-only map or after the keycards (variant 1). The real voxels cannot lie on the card:
a VOXELDEF voxel can only be turned about the vertical (AngleOffset), and the card lies in the plane of the gun's side.

Every piece has at most 16 colours, each filling an aligned 4 x 4 block of the voxel's 16 x 16 palette texture, so
texture filtering does not mix a glyph's colour with its neighbours; glyphs keep all their pixels (the voxel is
scaled, not the picture). Families: rot 0 / rot 1 (turned half round) x mirrored (the physical left hand); card.zs
SideRot picks the rot from the pose.

Writes voxels/w*.kvx, wp*.kvx, wy*.kvx, a SIDE block in VOXELDEF.txt, sprites/ws/*.png placeholders and
zscript/rsqgc/side_states.zs (class RSQGC_SideStates)."""
import argparse, os, math, re
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)   # the GunCards folder
import sys; sys.path.insert(0, HERE)
from gen_cards import write_kvx
import jfo

# ---- the card, model cm -----------------------------------------------------------------------------------
SIDE_X = -4.5          # flat on the side of the wrist: the measured wrist centre X 0.4, radius ~4 cm
PX = 0.13              # cm per card pixel
CARD_W = 100           # px (13 cm, owner 2026-11-03)
CARD_Y0 = -16.9 - CARD_W * PX / 2.0   # centred on the wrist along the forearm (wrist Y -16.9)
PAD = 5                # px (the mockup's)
BRIGHT = ''            # QoL GC8: the cards take the room's light (hw_weapon.cpp GetWeaponLighting)
FRONT = 0.18           # glyphs stand this far nearer the eye than the panel (X -)
FLIP_Y = True; FLIP_Z = True
TURN_L = 150.0         # cm: the pieces' turning point, this far back along the forearm toward the player
WEAPON_SCALE = 1.02    # vr_weaponScale's default (hw_vrmodes.cpp:107)
ROT_ZC = -11.3         # the wrist's height (gen_cards.py WRIST)
ROT_YC = CARD_Y0 + CARD_W * PX / 2.0
ROW_MID = None

# ---- the grid -------------------------------------------------------------------------------------------
TEXT_W = CARD_W - 2 * PAD
# sets: (font, half resolution, glyph px -> card px, units, unit px)
SETS = [('small', True, 0.42, 25, TEXT_W / 25.0), ('small', False, 0.21, 25, TEXT_W / 25.0),
        ('big', True, 0.42, 13, TEXT_W / 13.0), ('big', False, 0.21, 13, TEXT_W / 13.0)]
H_SMALL = 32 * 0.21    # 6.72 px
H_BIG = 64 * 0.21      # 13.44 px
H_KEY = 11.0
GAP = {'s': 2, 'd': 3, 'k': 3}
H = {'s': H_SMALL, 'd': H_BIG, 'k': H_KEY}

# ---- the rows (mock5.py card()): each row id is a line the runtime can fill; z from the card's top edge, px ----
def _rows():
    rows = []   # (name, kind, top px, height px, bottom-with-gap px)
    z0 = PAD
    def add(name, kind, top, as_text_in=None):
        h = H[kind]
        rows.append((name, kind, top, h, top + h + GAP[kind]))
        return top + h + GAP[kind]
    z = add('labels', 's', z0)             # 0 MAG / RESERVE, H / A
    z = add('counts', 'd', z)              # 1 the counts, big
    r2 = z
    z_s2 = add('line2', 's', r2)           # 2 GRENADES / H 100
    add('keys2', 'k', r2)                  # 3 the key row of the Status card
    rows.append(('keys2text', 's', r2 + (H_KEY - H_SMALL) / 2, H_SMALL, r2 + H_KEY + GAP['k']))   # 4 G:n on it
    z_s3 = add('line3', 's', z_s2)         # 5 KILLS
    add('keys3', 'k', z_s2)                # 6 the key row of the Both card
    rows.append(('keys3text', 's', z_s2 + (H_KEY - H_SMALL) / 2, H_SMALL, z_s2 + H_KEY + GAP['k']))  # 7
    z = z_s3
    for i in range(6):                     # 8..13 Gun Bonsai: LV bar, four upgrades, "+N MORE"
        z = add('gb%d' % i, 's', z)
    return rows
ROWS = _rows()
CARD_Z0 = ROT_ZC - (ROWS[5][4] + PAD - 1) * PX / 2.0   # the Weapon card (4 rows) centred on the wrist's height

# ---- keys ---------------------------------------------------------------------------------------------------
KEY_TYPES = ['RKEY', 'YKEY', 'BKEY', 'RSKU', 'YSKU', 'BSKU']
KEY_BOX_W, KEY_BOX_H, KEY_PITCH, KEY_GROUP_GAP = 9.0, 10.5, 10.2, 2.5
def key_slot_x(t, var):
    i = t % 3
    if t < 3 or var == 0: return PAD + i * KEY_PITCH
    return PAD + 3 * KEY_PITCH + KEY_GROUP_GAP + i * KEY_PITCH
KEYS_END_UNIT = [int(math.ceil((key_slot_x(5, v) + KEY_BOX_W + 2 - PAD) / SETS[0][4])) for v in (0, 1)]   # "+N" after them

def dimmed(g):
    g = g.copy(); px = g.load()
    for y in range(g.size[1]):
        for x in range(g.size[0]):
            r, gg, b, a = px[x, y]
            if a: l = int((r + gg + b) / 3 * 0.18) + 18; px[x, y] = (l, l, l, 255)
    return g


def block_palette(im):
    """At most 16 colours, each an aligned 4 x 4 block of the 16 x 16 palette texture: (indexed image, palette, index map).
    A voxel face samples its colour index's texel centre (models_voxel.cpp AddVertex); the index used is the block's
    inner texel (row 1, column 1 of the block), so bilinear and the first two mip levels stay inside the block."""
    rgb = im.convert('RGB')
    q = rgb.quantize(16, method=Image.Quantize.MEDIANCUT) if hasattr(Image, 'Quantize') else rgb.quantize(16)
    raw = q.getpalette()[:48]
    cols = [tuple(raw[i:i + 3]) for i in range(0, len(raw), 3)]
    pal = [(0, 0, 0)] * 256
    idx = {}
    for k, c in enumerate(cols):
        bx, by = k % 4, k // 4
        for yy in range(4):
            for xx in range(4):
                pal[(by * 4 + yy) * 16 + bx * 4 + xx] = c
        idx[k] = (by * 4 + 1) * 16 + bx * 4 + 1
    pal[255] = (0, 0, 0)
    return q, pal, idx

def piece(im, out, scale_px, y0, z0, mirror, x_off, rot=0, turn=(0.0, 0.0), cut=60):
    """im is laid in the plane X = SIDE_X - x_off: picture columns along +Y from y0, rows along +Z from z0.
    rot 1: turned 180 degrees in that plane about the card's middle (ROT_YC, ROT_ZC). turn: the turning point's model
    (Y, Z) (the VOXELDEF offsets put the model's origin there), so the piece is laid relative to it."""
    w, h = im.size
    if mirror: im = im.transpose(Image.FLIP_LEFT_RIGHT)
    if rot:
        im = im.rotate(180)
        y0 = 2 * ROT_YC - y0 - w * scale_px
        z0 = 2 * ROT_ZC - z0 - h * scale_px
    q, pal, idx = block_palette(im)
    vox = {}
    for y in range(h):
        for x in range(w):
            if im.getpixel((x, y))[3] >= cut:
                vox[(0, x, y)] = idx[q.getpixel((x, y))]    # KVX x = across the card plane (model X), y along Y, z down
    s = scale_px
    X = SIDE_X - x_off
    # the model is scaled by the weapon scale about the turning point after the offsets (models.cpp:248-277), so the
    # piece is laid at (place - turn / scale): it then lands exactly where it did about the model origin
    y0 -= turn[0] / WEAPON_SCALE; z0 -= turn[1] / WEAPON_SCALE
    fb = w - 1 if FLIP_Y else 0; fc = h - 1 if FLIP_Z else 0
    vox = {(a, abs(fb - b), abs(fc - c)): v for (a, b, c), v in vox.items()}
    piv = (0.5 + X / s, (w - 1) + 1.0 + y0 / s, (h - 1) + 1.0 + z0 / s)
    write_kvx(out, vox, (1, w, h), piv, pal)
    return len(vox)


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--iwad', help='unused since v4 (kept so old command lines work)')
    ap.parse_args()
    vdir = os.path.join(ROOT, 'voxels'); sdir = os.path.join(ROOT, 'sprites', 'ws')
    os.makedirs(vdir, exist_ok=True); os.makedirs(sdir, exist_ok=True)
    for f in os.listdir(vdir):
        if re.match(r'^w[0-9a-f][0-3]\d\d[0-9a-f]{2}\.kvx$', f) or re.match(r'^w[0-5][01]\d\d[0-9a-f]{2}\.kvx$', f) \
           or re.match(r'^wp\d+\.kvx$', f) or re.match(r'^wy\d+\.kvx$', f):
            os.remove(os.path.join(vdir, f))
    for f in os.listdir(sdir): os.remove(os.path.join(sdir, f))
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    B36 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    vdef, states = [], []
    sprite_n = [0]
    def new_sprite():
        # 36 x 36 names under WZ (checked free in Brutal Doom, its VR pack, the voxel pack and every series VOXELDEF /
        # MODELDEF); v4 needs fewer than 1,296 so WQ (v3's overflow) is no longer used
        n = sprite_n[0]; sprite_n[0] += 1
        assert n < 1296
        return 'WZ' + B36[n // 36] + B36[n % 36]
    cells = {s: [0, 0] for s in range(4)}   # set -> [voxels, glyph pieces], for the report
    s = PX
    global ROW_MID
    cen = [CARD_Z0 + (top + h / 2.0) * s for (_, _, top, h, _) in ROWS]
    ROW_MID = (min(cen) + max(cen)) / 2.0
    def mid(rot): return ROW_MID if rot == 0 else 2 * ROT_ZC - ROW_MID
    FAMS = ((0, 0), (0, 1), (1, 0), (1, 1))   # (rot, mirrored)

    def frame_list(label, items):
        """items: [(lump, scale, rot)] in frame order -> state label with as many WZ sprites as needed"""
        fr = []
        for gi, (lump, sc, rot) in enumerate(items):
            if gi % 26 == 0: spr = new_sprite()
            L = letters[gi % 26]
            vdef.append('%s%s = "%s" { Scale = %g YOffset = %g ZOffset = %g }' % (spr, L, lump, round(sc, 6), TURN_L, round(mid(rot), 4)))
            Image.new('RGBA', (1, 1)).save(os.path.join(sdir, '%s%s0.png' % (spr, L)))
            fr.append((spr, L))
        states.append((label, fr))

    # ---- glyphs: every code at every unit, per set and family
    adv = {}
    for si, (kind, half, sc, nunits, u) in enumerate(SETS):
        codes = jfo.SMALL_CODES if kind == 'small' else jfo.BIG_CODES
        imgs = {c: jfo.glyph(kind, c, half)[0] for c in codes}
        for c in codes: adv[(kind, c)] = jfo.units(kind, c)
        gpx = sc                               # card px per pixel of this (maybe halved) glyph
        vs = gpx * s                           # cm per glyph pixel: the voxel's scale
        for fam, (rot, mm) in enumerate(FAMS):
            for pos in range(nunits):
                items = []
                for c in codes:
                    g = imgs[c]
                    iw = g.size[0] * gpx
                    x_px = PAD + pos * u + (adv[(kind, c)] * u - iw) / 2.0
                    y0 = CARD_Y0 + (x_px if not mm else CARD_W - x_px - iw) * s
                    z0 = ROW_MID - g.size[1] * vs / 2.0
                    lump = 'w%d%d%02d%02x' % (si, fam, pos, c)
                    n = piece(g, os.path.join(vdir, lump + '.kvx'), vs, y0, z0, mm, FRONT, rot, (TURN_L, mid(rot)), cut=100)
                    if fam == 0 and pos == 0: cells[si][0] += n; cells[si][1] += 1
                    items.append((lump, vs, rot))
                frame_list('F%d%d%02d' % (si, fam, pos), items)
    # ---- keys: per source (0 voxel pack, 1 Freedoom) and family: (type, variant, dim) frames
    key_cells = [0, 0]
    for src, pre in enumerate(('vp', 'fd')):
        art = {t: Image.open(os.path.join(HERE, 'card_art', 'keys', '%s_%s.png' % (pre, t))).convert('RGBA') for t in KEY_TYPES}
        for fam, (rot, mm) in enumerate(FAMS):
            items = []
            for t, name in enumerate(KEY_TYPES):
                g0 = art[name]
                kp = min(KEY_BOX_W / g0.size[0], KEY_BOX_H / g0.size[1])   # card px per icon pixel
                if src == 0: kp = min(kp, 0.62 if t < 3 else 0.33)          # the mockup's sizes
                vs = kp * s
                iw, ih = g0.size[0] * kp, g0.size[1] * kp
                for var in (0, 1):
                    xb = key_slot_x(t, var)
                    x_px = xb + (KEY_BOX_W - iw) / 2.0
                    y0 = CARD_Y0 + (x_px if not mm else CARD_W - x_px - iw) * s
                    z0 = ROW_MID - ih * s / 2.0
                    for dim in (0, 1):
                        g = dimmed(g0) if dim else g0
                        lump = 'wy%d%d%d%d%d' % (src, fam, t, var, dim)
                        n = piece(g, os.path.join(vdir, lump + '.kvx'), vs, y0, z0, mm, FRONT, rot, (TURN_L, mid(rot)), cut=128)
                        if fam == 0 and var == 0 and dim == 0: key_cells[src] += n
                        items.append((lump, vs, rot))
            frame_list('K%d%d' % (src, fam), items)
    # ---- panels: one per height the cards can end at
    needs = sorted(set(int(math.ceil(r[4] + PAD - 1)) for r in ROWS))
    panel_h = needs
    for fam, (rot, m) in enumerate(FAMS):
        items = []
        for hi, ph in enumerate(panel_h):
            big = Image.new('RGBA', (CARD_W * 4, ph * 4), (0, 0, 0, 0)); d = ImageDraw.Draw(big)
            d.rounded_rectangle((0, 0, CARD_W * 4 - 1, ph * 4 - 1), 22, fill=(235, 235, 235, 255))
            d.rounded_rectangle((8, 8, CARD_W * 4 - 9, ph * 4 - 9), 16, fill=(96, 96, 96, 255))
            im = big.resize((CARD_W, ph), Image.LANCZOS)
            lump = 'wp%02d%d' % (hi, fam)
            piece(im, os.path.join(vdir, lump + '.kvx'), s, CARD_Y0, CARD_Z0, m, 0.0, rot, (TURN_L, mid(rot)))
            items.append((lump, s, rot))
        frame_list('P%d' % fam, items)
    # ---- ROW_Y: the layer y offset (from 32) that lifts a piece from the reference height to its row (v3's solve)
    ws = WEAPON_SCALE
    def solve(yr, zr, want):
        r = math.hypot(yr, zr); ph = math.atan2(-zr, yr)
        c = math.acos(max(-1.0, min(1.0, want / r)))
        return min((c + ph, -c + ph), key=abs)
    row_y = []
    for ri in range(len(ROWS)):
        for fam, (rot, mm) in enumerate(FAMS):
            target = cen[ri] if rot == 0 else 2 * ROT_ZC - cen[ri]
            yr, zr = ws * mid(rot) - mid(rot), ws * ROT_YC - TURN_L
            t = solve(yr, zr, ws * target - mid(rot))
            row_y.append(round(-4 * math.degrees(t), 5))
    nudge_k = ws * math.hypot(ROT_YC, ROW_MID) / (TURN_L - ws * ROT_YC)
    # ---- VOXELDEF
    vpath = os.path.join(ROOT, 'VOXELDEF.txt'); old = open(vpath).read() if os.path.exists(vpath) else ''
    a0, a1 = '// >>> SIDE (tools/gen_side.py)', '// <<< SIDE'
    if a0 in old: pre, rest = old.split(a0, 1); post = rest.split(a1, 1)[1]
    else: pre, post = old.rstrip('\n') + '\n\n', ''
    open(vpath, 'w').write(pre + a0 + '\n' + '\n'.join(vdef) + '\n' + a1 + post)
    # ---- ZScript
    def tbl(kind, f):
        codes = jfo.SMALL_CODES if kind == 'small' else jfo.BIG_CODES
        return ', '.join(str(f(c, codes)) for c in range(128))
    z = ['// GENERATED by tools/gen_side.py -- do not edit. The watch card flat on the back-of-the-hand side of the wrist (v4,',
         '// the owner\'s 2026-11-03 design, JFO text). Columns are baked on a unit grid, rows are turns: Glyph(set, family, unit,',
         '// code) at the reference height, RowY(row, family) the layer y that lifts it to its row (tools/gen_side.py).',
         '// set: 0 small Quest, 1 small PCVR, 2 big Quest, 3 big PCVR; family = rot * 2 + mirrored (rot 1: turned half round).',
         'class RSQGC_SideStates : Weapon', '{',
         '\tDefault { +WEAPON.CHEATNOTWEAPON +WEAPON.NOAUTOSWITCHTO Weapon.SelectionOrder 99999; }',
         '\tconst ROWS = %d;' % len(ROWS),
         '\t// row ids: %s' % ', '.join('%d %s' % (i, r[0]) for i, r in enumerate(ROWS)),
         '\tconst R_LABELS = 0; const R_COUNTS = 1; const R_LINE2 = 2; const R_KEYS2 = 3; const R_KEYS2TEXT = 4;',
         '\tconst R_LINE3 = 5; const R_KEYS3 = 6; const R_KEYS3TEXT = 7; const R_GB0 = 8;',
         '\tconst SMALL_UNITS = %d;' % SETS[0][3],
         '\tconst BIG_UNITS = %d;' % SETS[2][3],
         '\tconst KEYS_END0 = %d; const KEYS_END1 = %d;   // the first small unit after the key icons (variant 0 / 1)' % tuple(KEYS_END_UNIT),
         '\tstatic const int SMALL_IDX[] = { %s };' % tbl('small', lambda c, cs: cs.index(c) if c in cs else -1),
         '\tstatic const int BIG_IDX[] = { %s };' % tbl('big', lambda c, cs: cs.index(c) if c in cs else -1),
         '\tstatic const int SMALL_ADV[] = { %s };' % tbl('small', lambda c, cs: adv[('small', c)] if c in cs else 0),
         '\t// the panel height (px) a card needs when this row is its last, and the heights baked',
         '\tstatic const int PANEL_NEED[] = { %s };' % ', '.join(str(int(math.ceil(r[4] + PAD - 1))) for r in ROWS),
         '\tstatic const int PANEL_H[] = { %s };' % ', '.join(map(str, panel_h)),
         '\t// layer y offset from 32 per row * 4 + family: the turn that lifts a piece from the reference height to its row',
         '\tstatic const double ROW_Y[] = { %s };' % ', '.join('%g' % v for v in row_y),
         '\t// the Up / Down slider: degrees about the far turning point per degree it used to turn about the model origin',
         '\tconst NUDGE_K = %.6f;' % nudge_k,
         '\tStates', '\t{']
    for label, frames in states:
        z.append('\t%s:' % label)
        for spr, fr in frames: z.append('\t\t%s %s -1%s;' % (spr, fr, BRIGHT))
        z.append('\t\tStop;')
    z += ['\t}', '',
          '\tprivate static State Walk(State s, int n) { for (int i = 0; i < n && s; i++) s = s.NextState; return s; }',
          '\tstatic int Adv(int code) { return code >= 0 && code < 128 ? RSQGC_SideStates.SMALL_ADV[code] : 0; }',
          '\tstatic State Glyph(int set, int fam, int pos, int code)', '\t{',
          '\t\tif (code >= 97 && code <= 122) code -= 32;',
          '\t\tif (code < 0 || code >= 128 || set < 0 || set > 3 || fam < 0 || fam > 3) return null;',
          '\t\tint idx = set < 2 ? RSQGC_SideStates.SMALL_IDX[code] : RSQGC_SideStates.BIG_IDX[code];',
          '\t\tif (idx < 0 || pos < 0 || pos >= (set < 2 ? SMALL_UNITS : BIG_UNITS)) return null;',
          '\t\tlet d = GetDefaultByType("RSQGC_SideStates");', '\t\tState st = null;',
          '\t\tswitch ((set * 4 + fam) * 100 + pos)', '\t\t{']
    for label, frames in states:
        if label[0] != 'F': continue
        si, fam, pos = int(label[1]), int(label[2]), int(label[3:])
        z.append('\t\tcase %d: st = d.FindState("%s"); break;' % ((si * 4 + fam) * 100 + pos, label))
    z += ['\t\t}', '\t\treturn Walk(st, idx);', '\t}',
          '\t// src 0 the voxel pack\'s keys, 1 Freedoom\'s; type 0-2 red / yellow / blue keycard, 3-5 the skulls; var 1: a skull',
          '\t// placed after the keycards; dim: not held (dark grey)',
          '\tstatic State Key(int src, int fam, int type, int after, int dim)', '\t{',
          '\t\tif (src < 0 || src > 1 || fam < 0 || fam > 3 || type < 0 || type > 5) return null;',
          '\t\tlet d = GetDefaultByType("RSQGC_SideStates");', '\t\tState st = null;',
          '\t\tswitch (src * 4 + fam)', '\t\t{']
    for label, frames in states:
        if label[0] != 'K': continue
        src, fam = int(label[1]), int(label[2])
        z.append('\t\tcase %d: st = d.FindState("%s"); break;' % (src * 4 + fam, label))
    z += ['\t\t}', '\t\treturn Walk(st, (type * 2 + (after ? 1 : 0)) * 2 + (dim ? 1 : 0));', '\t}',
          '\tstatic double RowY(int row, int fam)', '\t{',
          '\t\tif (row < 0 || row >= ROWS || fam < 0 || fam > 3) return 0;',
          '\t\treturn RSQGC_SideStates.ROW_Y[row * 4 + fam];', '\t}',
          '\tstatic State Panel(int fam, int hi)', '\t{', '\t\tlet d = GetDefaultByType("RSQGC_SideStates");',
          '\t\tState st = null;', '\t\tswitch (fam)', '\t\t{']
    for label, frames in states:
        if label[0] != 'P': continue
        z.append('\t\tcase %d: st = d.FindState("%s"); break;' % (int(label[1]), label))
    z += ['\t\t}', '\t\treturn Walk(st, hi);', '\t}', '}', '']
    open(os.path.join(ROOT, 'zscript', 'rsqgc', 'side_states.zs'), 'w').write('\n'.join(z))
    print('sprites %d, frames %d, row mid %.2f, nudge k %.4f, card z0 %.2f, panels %s' % (sprite_n[0], len(vdef), ROW_MID, nudge_k, CARD_Z0, panel_h))
    for si, (kind, half, *_r) in enumerate(SETS):
        print('  set %d %s %s: %d glyphs, %d voxels for one of each (avg %.0f)' % (si, kind, 'Quest' if half else 'PCVR', cells[si][1], cells[si][0], cells[si][0] / max(1, cells[si][1])))
    print('  keys: voxel pack %d voxels for the six, Freedoom %d' % tuple(key_cells))

if __name__ == '__main__':
    main()
