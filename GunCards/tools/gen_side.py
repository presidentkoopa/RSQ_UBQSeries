#!/usr/bin/env python3
"""RSQ Gun Cards: THE WATCH CARD's pieces (owner 2026-10-31 02:47): the full card lies flat on the side of the gun at
the back of the grip hand, facing you when you check your watch knuckles up.

    python3 tools/gen_side.py --iwad <freedoom2.wad>      (the DoomFont glyphs come from it: use Freedoom, BSD)

WHERE (rig-measured, doom2 + BD22 VR, right hand knuckles up: gun across the body, twisted -90): the gun's outboard
side (model X -) faces the eyes; along the gun, model Y + reads left to right (the muzzle, Y -, is on the left); and
model Z + (the gun's top) is DOWN the card. So the card is the plane X = SIDE_X, its columns run along Y and its rows
along Z.

HOW (v3, 2026-11-02): COLUMNS ARE BAKED, ROWS ARE TURNED. v2 (2026-10-31) baked a glyph per (row, column): 31,580
sprite frames, which pushed the owner's load order past 65,535 sprite frames in all. The engine indexes a sprite's first
frame with 16 bits (r_data/sprites.h spritedef_t.spriteframes is uint16_t), so every sprite past that wrapped onto
another sprite's frames: on the watch check, card pieces drew as RSQ LaserSight's beam rods tinted the card's colour
(owner: "three rows of voxels extend out from my gun, like three voxel lasers, the color of my weapon"; rig 2026-11-02:
71,152 frames with every series pk3; the rods show with all of them and vanish without LaserSight or the cards).
Now each glyph is baked once per FONT, family and column, at a reference height (ROW_MID), and the row is a turn: the
piece's turning point (VOXELDEF YOffset / ZOffset: RenderHUDModel turns a layer's model about the point its offsets name,
models.cpp:248-263) sits TURN_L cm back along the forearm toward the player, at the reference height; a layer's y turns
the model about the hand's right axis (the card's normal) through that point (hw_weapon.cpp:108, (y - 32) / -4
degrees), which, that far away, lifts the piece in the card's plane: side_states.zs ROW_Y is the exact turn per row and
family. The row also tilts by that angle (at most 1.7 degrees, the top and bottom lines) and slides along the forearm by
at most 0.06 cm. The Up / Down slider adds to the same turn, scaled (NUDGE_K) so a degree still moves the card as far as
it did about the model origin. ~5,500 frames instead of 31,580.
THE ENGINE'S WEAPON SCALE (vr_weaponScale, default 1.02, models.cpp:277) scales the model about its turning point after
the offsets, so the baked pieces assume 1.02: any other value slides the whole watch card along the forearm by
(1.02 - scale) x 167 cm (3.3 cm at 1.00), panel and text together. A turn about a point to the side of the hand (to slide
columns) would move the card off the wrist instead, which is why the rows, not the columns, are turned.
OLDER NOTES: v2 baked every row and column; v1 placed rows at run time with y about the model origin and baked columns
(the rows slid and tilted: the origin is only ~20 cm away).
The panel is one piece per template height, white rim and grey fill, tinted per gun at run time; it shares the turning
point (so the weapon scale moves it with the text).
The mirrored twins (the physical left hand, drawn mirrored by the engine) flip the picture and the column order.

Writes voxels/w*.kvx and wp*.kvx, a SIDE block in VOXELDEF.txt, sprites/ws/*.png placeholders and
zscript/rsqgc/side_states.zs (class RSQGC_SideStates: Glyph(row, family, column, code), RowY(row, family), Panel(family,
h), the layout constants)."""
import argparse, os, struct, math
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)   # the GunCards folder
import sys; sys.path.insert(0, HERE)
from gen_cards import write_kvx

# ---- the card, model cm -----------------------------------------------------------------------------------
SIDE_X = -4.5          # flat on the side of the wrist: the measured wrist centre X 0.4, radius ~4 cm (side 1 at +4.5)
CARD_Y0 = -22.6        # centred on the wrist along the forearm (wrist Y -16.9, card 11.4 cm)
CARD_Z0 = -14.6        # top edge: the card centred on the wrist's height (Z -11.3)
PX = 0.13              # cm per card pixel
CARD_W = 88            # px (11.4 cm)
PANEL_H = [44, 56, 68, 80, 94]   # px: the panel heights the runtime can pick (the smallest that holds the last row used)
# QoL GC8 (owner, 2026-10-31): the cards take the room's light: no Bright on the states (hw_weapon.cpp GetWeaponLighting)
BRIGHT = ''
FRONT = 0.18           # glyphs stand this far nearer the eye than the panel (X -)
PAD = 4                # px
PITCH_SIGN = int(os.environ.get('WS_PS', '-1'))   # rig-measured: +1 if a positive turn moves a piece down the card
FLIP_Y = os.environ.get('WS_FY', '1') == '1'
FLIP_Z = os.environ.get('WS_FZ', '1') == '1'
# WHICH WAY UP (2026-11-02, owner in the headset: "I look at the back of my wrist ... the card is upside down"). The text
# is baked TWO ways, and the runtime picks per tic from the pose (card.zs SideRot): family rot 0 is the layout above (rig:
# upright with the right hand across the chest, back of the wrist up, the eyes above it); rot 1 is every piece turned
# 180 degrees in the card's plane about the card's middle (along the forearm at the card's middle, at the wrist's height).
# The 2026-10-31 fix turned every piece half round for good ("upside down on SteamVR"); in the true watch pose that read
# upside down on both hands (rig frames 2026-11-02), so the turn is now chosen from where the gun's top points on screen.
# The other side of the wrist (the palm side, X = +SIDE_X) is gone: in the watch check it faces away from the eyes.
ROT_YC = None   # set in main(): the card's middle along the forearm
TURN_L = 150.0  # cm: the pieces' turning point, this far back along the forearm toward the player (HOW v3)
ROW_MID = None  # set in main(): the reference height every glyph is baked at (rot 0: the middle of the rows' span)
WEAPON_SCALE = 1.02   # vr_weaponScale's default (hw_vrmodes.cpp:107): the turning point is placed for it
ROT_ZC = -11.3  # the wrist's height (gen_cards.py WRIST)
# CRISPER TEXT (2026-11-02, owner: "how do we make the text less blurry?"):
#  - a glyph is no longer shrunk by resampling (the 0.75 small font lost whole pixel rows to a NEAREST resize: 7 rows
#    became 5); every glyph keeps all its pixels and the VOXEL is made smaller instead (VOXELDEF Scale = PX * scale);
#  - every piece has at most 16 colours and each colour fills an aligned 4 x 4 block of the voxel's 16 x 16 palette
#    texture (models_voxel.cpp FVoxelTexture: a voxel face samples its colour's texel centre), with the face pointing at
#    the block's inner texel, so the engine's linear / mipmap filtering of that texture no longer mixes a glyph's white
#    with its neighbours in the palette (the padding black) at a distance.
# fonts: (name, source, cell w px, cell h px, scale) -- monospaced columns
FONTS = [('SMALL', 'doom', 6, 7, 0.75), ('TITLE', 'doom', 8, 7, 1.0), ('DIGIT', 'ermac', 12, 12, 1.0)]

def doom_glyphs(iwad):
    d = open(iwad, 'rb').read()
    n, off = struct.unpack('<4xii', d[:12])
    lumps = {}
    for i in range(n):
        o, sz, nm = struct.unpack('<ii8s', d[off + 16 * i:off + 16 * i + 16])
        lumps[nm.rstrip(b'\0').decode('latin1')] = (o, sz)
    po, _ = lumps['PLAYPAL']; P = d[po:po + 768]
    out = {}
    for c in range(33, 96):
        nm = 'STCFN%03d' % c
        if nm not in lumps: continue
        o, sz = lumps[nm]; b = d[o:o + sz]
        w, h = struct.unpack('<hh', b[:4]); cols = struct.unpack('<%di' % w, b[8:8 + 4 * w])
        im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        for x, cp in enumerate(cols):
            p = cp
            while b[p] != 255:
                top, ln = b[p], b[p + 1]
                for k in range(ln):
                    v = b[p + 3 + k]
                    # white glyphs (the runtime tints), keeping the font's shading as brightness
                    l = int(0.299 * P[3 * v] + 0.587 * P[3 * v + 1] + 0.114 * P[3 * v + 2])
                    l = min(255, int(l * 1.6) + 40)
                    im.putpixel((x, top + k), (l, l, l, 255))
                p += 4 + ln
        out[c] = im
    return out

def ermac_glyphs():
    art = os.path.join(HERE, 'card_art'); out = {}
    for c in range(48, 58):
        out[c] = Image.open(os.path.join(art, 'digit_%s.png' % chr(c))).convert('RGBA')
    # QoL GC2: '+' for "+N" on a pickup (gen_cards.py extra_art draws it in Ermac's digit style)
    out[43] = Image.open(os.path.join(art, 'digit_plus.png')).convert('RGBA')
    return out

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

def piece(im, out, scale_px, y0, z0, mirror, x_off, rot=0, turn=(0.0, 0.0)):
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
            if im.getpixel((x, y))[3] >= 60:
                vox[(0, x, y)] = idx[q.getpixel((x, y))]    # KVX x = across the card plane (model X), y along Y, z down
    s = scale_px
    X = SIDE_X - x_off
    # the model is scaled by the weapon scale about the turning point after the offsets (models.cpp:248-277), so the
    # piece is laid at (place - turn / scale): it then lands exactly where it did about the model origin
    y0 -= turn[0] / WEAPON_SCALE; z0 -= turn[1] / WEAPON_SCALE
    # KVX: model Y = -kvx y offset, model Z = -kvx z offset (gen_cards.py header). The picture's +x runs along +Y,
    # its +y (down) along +Z: so the kvx y axis must point along -Y and kvx z along -Z: flip both.
    fb = w - 1 if FLIP_Y else 0; fc = h - 1 if FLIP_Z else 0
    vox = {(a, abs(fb - b), abs(fc - c)): v for (a, b, c), v in vox.items()}
    # pivot such that picture pixel (0,0)'s corner lands at (X, y0, z0): voxel index (0, w-1, h-1) is that pixel.
    piv = (0.5 + X / s, (w - 1) + 1.0 + y0 / s, (h - 1) + 1.0 + z0 / s)
    write_kvx(out, vox, (1, w, h), piv, pal)
    return len(vox)


# the rows of the card, top to bottom: (font index, gap after in px). Fixed layout; the runtime fills them.
ROWS = [(1, 2), (0, 1), (2, 2), (0, 2), (0, 1), (0, 1), (0, 1), (0, 1), (0, 1), (0, 1), (0, 1)]
#        title  word   digits  then eight small lines the runtime fills in order (side.zs Line): the QoL round's
#                              grenades / kills / keys lines, then Gun Bonsai's LV bar, upgrades and +more
CHARS = [c for c in range(33, 96) if chr(c).isalnum() or chr(c) in "+-=/%.:'()#!"]

def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--iwad', required=True); a = ap.parse_args()
    global ROT_YC
    ROT_YC = CARD_Y0 + CARD_W * PX / 2.0
    vdir = os.path.join(ROOT, 'voxels'); sdir = os.path.join(ROOT, 'sprites', 'ws')
    os.makedirs(vdir, exist_ok=True); os.makedirs(sdir, exist_ok=True)
    import re
    for f in os.listdir(vdir):
        if re.match(r'^w[0-9a-f][0-3]\d\d[0-9a-f]{2}\.kvx$', f) or re.match(r'^w[0-5][01]\d\d[0-9a-f]{2}\.kvx$', f) or re.match(r'^wp\d+\.kvx$', f):
            os.remove(os.path.join(vdir, f))
    for f in os.listdir(sdir): os.remove(os.path.join(sdir, f))
    doom = doom_glyphs(a.iwad); ermac = ermac_glyphs()
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    vdef, states = [], []
    sprite_n = [0]
    B36 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    def new_sprite():
        sprite_n[0] += 1
        n = sprite_n[0]
        # 36 x 36 names under WZ; the QoL round's two extra rows run past them, into WQ (checked free in Brutal Doom,
        # its VR pack, the voxel pack and every series VOXELDEF / MODELDEF)
        pre = ['WZ', 'WQ'][n // 1296]
        n %= 1296
        return pre + B36[n // 36] + B36[n % 36]
    count = 0
    s = PX
    font_cols, row_z, row_codes = [], [], []
    for fi, (fname, src, cw, ch, sc) in enumerate(FONTS):
        font_cols.append(int((CARD_W - 2 * PAD) // (cw * sc)))
    z = PAD
    for ri, (fi, gap) in enumerate(ROWS):
        row_z.append(z)
        z += FONTS[fi][3] * FONTS[fi][4] + gap
    used_h = z + PAD
    # the reference height: the middle of the span of the rows' centres (rot 0); rot 1 mirrors it about ROT_ZC
    global ROW_MID
    cen = [CARD_Z0 + (row_z[ri] + FONTS[fi][3] * FONTS[fi][4] / 2.0) * s for ri, (fi, gap) in enumerate(ROWS)]
    ROW_MID = (min(cen) + max(cen)) / 2.0
    def mid(rot): return ROW_MID if rot == 0 else 2 * ROT_ZC - ROW_MID
    FAMS = ((0, 0), (0, 1), (1, 0), (1, 1))   # (rot, mirrored)
    for fi, (fname, src, cw, ch, sc) in enumerate(FONTS):
        glyphs = doom if src == 'doom' else ermac
        codes = [c for c in sorted(glyphs) if c in CHARS]
        gw = cw * sc
        hcm = ch * sc * s
        for fam, (rot, mm) in enumerate(FAMS):
            for col in range(font_cols[fi]):
                y0 = CARD_Y0 + (PAD + col * gw) * s
                if mm: y0 = CARD_Y0 + (CARD_W - PAD - (col + 1) * gw) * s
                z0 = ROW_MID - hcm / 2.0          # piece() turns it half round for rot 1, to mid(1)
                frames = []
                for gi, c in enumerate(codes):
                    if gi % 26 == 0:
                        spr = new_sprite(); frames.append((spr, []))
                    g = glyphs[c]
                    # the glyph at full resolution in a cell of the font's own pixels; the voxel is scaled instead
                    lump = 'w%x%d%02d%02x' % (fi, fam, col, c)
                    cell = Image.new('RGBA', (cw, ch), (0, 0, 0, 0))
                    cell.alpha_composite(g, ((cell.width - g.width) // 2, 0))
                    vs = s * sc
                    count += piece(cell, os.path.join(vdir, lump + '.kvx'), vs, y0, z0, mm, FRONT, rot, (TURN_L, mid(rot)))
                    vdef.append('%s%s = "%s" { Scale = %g YOffset = %g ZOffset = %g }' % (spr, letters[gi % 26], lump, round(vs, 6), TURN_L, round(mid(rot), 4)))
                    Image.new('RGBA', (1, 1)).save(os.path.join(sdir, '%s%s0.png' % (spr, letters[gi % 26])))
                    frames[-1][1].append((letters[gi % 26], c))
                states.append(('F%d%d%02d' % (fi, fam, col), frames))
    # ROW_Y: the layer y offset (from 32) that lifts a glyph from the reference height to its row. The card middle's
    # glyph centre relative to the turning point, in the hand frame (y up, z toward the player): y = 0, z = ROT_YC -
    # TURN_L. GL's rotate(t, 1, 0, 0) takes (y, z) to (y cos t - z sin t, y sin t + z cos t), so the lift is
    # (TURN_L - ROT_YC) sin t; rotation.Y = (y - 32) / -4 (hw_weapon.cpp:108). All of it is scaled by the weapon scale
    # about the turning point, which keeps the turn exact.
    ws = WEAPON_SCALE
    def solve(yr, zr, want):
        # t with yr cos t - zr sin t = want (the smaller root)
        r = math.hypot(yr, zr); ph = math.atan2(-zr, yr)
        c = math.acos(max(-1.0, min(1.0, want / r)))
        return min((c + ph, -c + ph), key=abs)
    row_y = []
    for ri, (fi, gap) in enumerate(ROWS):
        for fam, (rot, mm) in enumerate(FAMS):
            target = cen[ri] if rot == 0 else 2 * ROT_ZC - cen[ri]
            # the card middle's glyph, drawn: ws * (its place) about the model origin; relative to the turning point:
            yr, zr = ws * mid(rot) - mid(rot), ws * ROT_YC - TURN_L
            t = solve(yr, zr, ws * target - mid(rot))
            row_y.append(round(-4 * math.degrees(t), 5))
    # NUDGE_K: the Up / Down slider turned the card about the model origin (the rows' middle is ws * ~19 cm from that
    # axis); about the far turning point the same lift needs this much of that turn
    nudge_k = ws * math.hypot(ROT_YC, ROW_MID) / (TURN_L - ws * ROT_YC)
    pstates = []
    for hi, ph in enumerate(PANEL_H):
        big = Image.new('RGBA', (CARD_W * 4, ph * 4), (0, 0, 0, 0)); d = ImageDraw.Draw(big)
        d.rounded_rectangle((0, 0, CARD_W * 4 - 1, ph * 4 - 1), 22, fill=(235, 235, 235, 255))
        d.rounded_rectangle((8, 8, CARD_W * 4 - 9, ph * 4 - 9), 16, fill=(96, 96, 96, 255))
        im = big.resize((CARD_W, ph), Image.LANCZOS)
        for fam, (rot, m) in enumerate(FAMS):
            spr = new_sprite(); lump = 'wp%d%d' % (hi, fam)
            count += piece(im, os.path.join(vdir, lump + '.kvx'), s, CARD_Y0, CARD_Z0, m, 0.0, rot, (TURN_L, mid(rot)))
            vdef.append('%sA = "%s" { Scale = %g YOffset = %g ZOffset = %g }' % (spr, lump, s, TURN_L, round(mid(rot), 4)))
            Image.new('RGBA', (1, 1)).save(os.path.join(sdir, '%sA0.png' % spr))
            pstates.append(('P%d%d' % (hi, fam), spr))
    vpath = os.path.join(ROOT, 'VOXELDEF.txt'); old = open(vpath).read() if os.path.exists(vpath) else ''
    a0, a1 = '// >>> SIDE (tools/gen_side.py)', '// <<< SIDE'
    if a0 in old: pre, rest = old.split(a0, 1); post = rest.split(a1, 1)[1]
    else: pre, post = old.rstrip('\n') + '\n\n', ''
    open(vpath, 'w').write(pre + a0 + '\n' + '\n'.join(vdef) + '\n' + a1 + post)
    z = ['// GENERATED by tools/gen_side.py -- do not edit. The watch card flat on the back-of-the-hand side of the wrist.',
         '// Columns are baked, rows are turns: Glyph(row, family, column, code) at the reference height, RowY(row, family) the',
         '// layer y that lifts it to its row (tools/gen_side.py HOW v3); family = rot * 2 + mirrored (rot 1: turned half round).',
         'class RSQGC_SideStates : Weapon', '{',
         '\tDefault { +WEAPON.CHEATNOTWEAPON +WEAPON.NOAUTOSWITCHTO Weapon.SelectionOrder 99999; }',
         '\tconst ROWS = %d;' % len(ROWS),
         '\tstatic const int ROW_FONT[] = { %s };' % ', '.join(str(r[0]) for r in ROWS),
         '\tstatic const int FONT_COLS[] = { %s };' % ', '.join(map(str, font_cols)),
         '\tstatic const int ROW_BOTTOM_PX[] = { %s };' % ', '.join(str(int(row_z[i] + FONTS[ROWS[i][0]][3] * FONTS[ROWS[i][0]][4] + PAD + 0.999)) for i in range(len(ROWS))),
         '\tstatic const int PANEL_H[] = { %s };' % ', '.join(map(str, PANEL_H)),
         '\t// layer y offset from 32 per row * 4 + family: the turn that lifts a glyph from the reference height to its row',
         '\tstatic const double ROW_Y[] = { %s };' % ', '.join('%g' % v for v in row_y),
         '\t// the Up / Down slider: degrees about the far turning point per degree it used to turn about the model origin',
         '\tconst NUDGE_K = %.6f;' % nudge_k,
         '\tStates', '\t{']
    for label, frames in states:
        z.append('\t%s:' % label)
        for spr, fl in frames:
            for fr, c in fl: z.append('\t\t%s %s -1%s;' % (spr, fr, BRIGHT))
        z.append('\t\tStop;')
    for label, spr in pstates:
        z.append('\t%s:' % label); z.append('\t\t%s A -1%s;' % (spr, BRIGHT)); z.append('\t\tStop;')
    z += ['\t}', '', '\tprivate static State Walk(State s, int n) { for (int i = 0; i < n && s; i++) s = s.NextState; return s; }']
    for fi in range(len(FONTS)):
        src = FONTS[fi][1]
        codes = [c for c in sorted(doom if src == 'doom' else ermac) if c in CHARS]
        z.append('\tstatic const int CODES%d[] = { %s };' % (fi, ', '.join(map(str, codes))))
    z += ['\tstatic int IndexOf(int font, int code)', '\t{',
          '\t\tif (font == 0) { for (int i = 0; i < RSQGC_SideStates.CODES0.Size(); i++) if (RSQGC_SideStates.CODES0[i] == code) return i; }',
          '\t\telse if (font == 1) { for (int i = 0; i < RSQGC_SideStates.CODES1.Size(); i++) if (RSQGC_SideStates.CODES1[i] == code) return i; }',
          '\t\telse { for (int i = 0; i < RSQGC_SideStates.CODES2.Size(); i++) if (RSQGC_SideStates.CODES2[i] == code) return i; }',
          '\t\treturn -1;', '\t}',
          '\tstatic State Glyph(int row, int fam, int col, int code)', '\t{',
          '\t\tif (code >= 97 && code <= 122) code -= 32;',
          '\t\tif (row < 0 || row >= ROWS) return null;',
          '\t\tint font = RSQGC_SideStates.ROW_FONT[row];',
          '\t\tif (col < 0 || col >= RSQGC_SideStates.FONT_COLS[font]) return null;',
          '\t\tint idx = IndexOf(font, code);', '\t\tif (idx < 0) return null;',
          '\t\tlet d = GetDefaultByType("RSQGC_SideStates");', '\t\tState st = null;',
          '\t\tswitch ((font * 4 + fam) * 100 + col)', '\t\t{']
    for label, frames in states:
        fi, fam, col = int(label[1]), int(label[2]), int(label[3:])
        z.append('\t\tcase %d: st = d.FindState("%s"); break;' % ((fi * 4 + fam) * 100 + col, label))
    z += ['\t\t}', '\t\treturn Walk(st, idx);', '\t}',
          '\tstatic double RowY(int row, int fam)', '\t{',
          '\t\tif (row < 0 || row >= ROWS || fam < 0 || fam > 3) return 0;',
          '\t\treturn RSQGC_SideStates.ROW_Y[row * 4 + fam];', '\t}',
          '\tstatic State Panel(int fam, int hi)', '\t{', '\t\tlet d = GetDefaultByType("RSQGC_SideStates");',
          '\t\tswitch (hi * 4 + fam)', '\t\t{']
    for label, spr in pstates:
        hi, fam = int(label[1]), int(label[2])
        z.append('\t\tcase %d: return d.FindState("%s");' % (hi * 4 + fam, label))
    z += ['\t\t}', '\t\treturn null;', '\t}', '}', '']
    open(os.path.join(ROOT, 'zscript', 'rsqgc', 'side_states.zs'), 'w').write('\n'.join(z))
    print('sprites %d, voxels %d, cells %d, font cols %s, card %d px tall, row mid %.2f, nudge k %.4f' % (sprite_n[0], len(vdef), count, font_cols, used_h, ROW_MID, nudge_k))

if __name__ == '__main__':
    main()
