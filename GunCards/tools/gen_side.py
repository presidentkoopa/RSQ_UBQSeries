#!/usr/bin/env python3
"""RSQ Gun Cards: THE WATCH CARD's pieces (owner 2026-10-31 02:47): the full card lies flat on the side of the gun at
the back of the grip hand, facing you when you check your watch knuckles up.

    python3 tools/gen_side.py --iwad <freedoom2.wad>      (the DoomFont glyphs come from it: use Freedoom, BSD)

WHERE (rig-measured, doom2 + BD22 VR, right hand knuckles up: gun across the body, twisted -90): the gun's outboard
side (model X -) faces the eyes; along the gun, model Y + reads left to right (the muzzle, Y -, is on the left); and
model Z + (the gun's top) is DOWN the card. So the card is the plane X = SIDE_X, its columns run along Y and its rows
along Z.

HOW (v2, 2026-10-31 03:20): EVERY ROW AND COLUMN IS BAKED -- a glyph per (row, column), so nothing is turned at run
time and the text sits flat and straight (turning rows about the model origin slid and tilted them near the wrist).
OLD NOTE: A layer's y turns its model about the model's X axis (hw_weapon.cpp:108: pitch, 1/4 degree a unit), which keeps a
piece in that plane and moves it along Z: so ROWS are placed at run time. A layer's x would turn it out of the plane,
so COLUMNS are baked: every glyph is built once per column (sprite per column, frame per glyph). The runtime turns
each piece by atan(dz / |Y of its column|) (the pitch radius is that column's distance along Y from the axis).
The panel is one piece per template height, white rim and grey fill, tinted per gun at run time.
The mirrored twins (the physical left hand, drawn mirrored by the engine) flip the picture and the column order.

Writes voxels/w*.kvx and wp*.kvx, a SIDE block in VOXELDEF.txt, sprites/ws/*.png placeholders and
zscript/rsqgc/side_states.zs (class RSQGC_SideStates: Glyph(font, mirrored, column, code), Panel(mirrored, h),
the column positions, the layout constants)."""
import argparse, os, struct
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
# TURNED HALF ROUND (owner 2026-10-31, in the headset on SteamVR: "the wrist card is upsidedown"): every piece is turned
# 180 degrees in the card's plane about the wrist (along the forearm at the card's middle, at the wrist's height), so
# the title is at the other end and the text reads the other way up. WS_ROT=0 lays it the old way (the rig's).
ROT180 = os.environ.get('WS_ROT', '1') == '1'
ROT_YC = None   # set in main(): the card's middle along the forearm
ROT_ZC = -11.3  # the wrist's height (gen_cards.py WRIST)
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

def piece(im, out, scale_px, y0, z0, mirror, x_off, side=0):
    """im is laid in the plane X = SIDE_X - x_off: picture columns along +Y from y0, rows along +Z from z0."""
    w, h = im.size
    if mirror: im = im.transpose(Image.FLIP_LEFT_RIGHT)
    if ROT180:
        im = im.rotate(180)
        y0 = 2 * ROT_YC - y0 - w * scale_px
        z0 = 2 * ROT_ZC - z0 - h * scale_px
    q = im.convert('RGB').quantize(255); raw = q.getpalette()[:765]
    pal = [tuple(raw[i:i + 3]) for i in range(0, len(raw), 3)] + [(0, 0, 0)] * 256
    vox = {}
    for y in range(h):
        for x in range(w):
            if im.getpixel((x, y))[3] >= 60:
                vox[(0, x, y)] = q.getpixel((x, y))    # KVX x = across the card plane (model X), y along Y, z down
    s = scale_px
    X = (SIDE_X - x_off) if side == 0 else (-SIDE_X + x_off)
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
    for ri, (fi, gap) in enumerate(ROWS):
        fname, src, cw, ch, sc = FONTS[fi]
        glyphs = doom if src == 'doom' else ermac
        codes = [c for c in sorted(glyphs) if c in CHARS]
        row_codes.append(codes)
        gw = cw * sc
        ncols = font_cols[fi]
        z0 = CARD_Z0 + row_z[ri] * s
        for fam, (side, m) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
            mm = m ^ side
            for col in range(ncols):
                y0 = CARD_Y0 + (PAD + col * gw) * s
                if mm: y0 = CARD_Y0 + (CARD_W - PAD - (col + 1) * gw) * s
                frames = []
                for gi, c in enumerate(codes):
                    if gi % 26 == 0:
                        spr = new_sprite(); frames.append((spr, []))
                    g = glyphs[c]
                    if sc != 1.0: g = g.resize((max(1, round(g.width * sc)), max(1, round(g.height * sc))), Image.NEAREST)
                    lump = 'w%x%d%02d%02x' % (ri, fam, col, c)
                    cell = Image.new('RGBA', (max(1, round(gw)), max(1, round(ch * sc))), (0, 0, 0, 0))
                    cell.alpha_composite(g, ((cell.width - g.width) // 2, 0))
                    count += piece(cell, os.path.join(vdir, lump + '.kvx'), s, y0, z0, mm, FRONT, side)
                    vdef.append('%s%s = "%s" { Scale = %g }' % (spr, letters[gi % 26], lump, s))
                    Image.new('RGBA', (1, 1)).save(os.path.join(sdir, '%s%s0.png' % (spr, letters[gi % 26])))
                    frames[-1][1].append((letters[gi % 26], c))
                states.append(('R%x%d%02d' % (ri, fam, col), frames))
    pstates = []
    for hi, ph in enumerate(PANEL_H):
        big = Image.new('RGBA', (CARD_W * 4, ph * 4), (0, 0, 0, 0)); d = ImageDraw.Draw(big)
        d.rounded_rectangle((0, 0, CARD_W * 4 - 1, ph * 4 - 1), 22, fill=(235, 235, 235, 255))
        d.rounded_rectangle((8, 8, CARD_W * 4 - 9, ph * 4 - 9), 16, fill=(96, 96, 96, 255))
        im = big.resize((CARD_W, ph), Image.LANCZOS)
        for fam, (side, m) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
            spr = new_sprite(); lump = 'wp%d%d' % (hi, fam)
            count += piece(im, os.path.join(vdir, lump + '.kvx'), s, CARD_Y0, CARD_Z0, m ^ side, 0.0, side)
            vdef.append('%sA = "%s" { Scale = %g }' % (spr, lump, s))
            Image.new('RGBA', (1, 1)).save(os.path.join(sdir, '%sA0.png' % spr))
            pstates.append(('P%d%d' % (hi, fam), spr))
    vpath = os.path.join(ROOT, 'VOXELDEF.txt'); old = open(vpath).read() if os.path.exists(vpath) else ''
    a0, a1 = '// >>> SIDE (tools/gen_side.py)', '// <<< SIDE'
    if a0 in old: pre, rest = old.split(a0, 1); post = rest.split(a1, 1)[1]
    else: pre, post = old.rstrip('\n') + '\n\n', ''
    open(vpath, 'w').write(pre + a0 + '\n' + '\n'.join(vdef) + '\n' + a1 + post)
    z = ['// GENERATED by tools/gen_side.py -- do not edit. The watch card flat on each side of the wrist (owner 03:00).',
         '// Every row and column is baked: Glyph(row, family, column, code); family = side * 2 + mirrored.',
         'class RSQGC_SideStates : Weapon', '{',
         '\tDefault { +WEAPON.CHEATNOTWEAPON +WEAPON.NOAUTOSWITCHTO Weapon.SelectionOrder 99999; }',
         '\tconst ROWS = %d;' % len(ROWS),
         '\tstatic const int ROW_FONT[] = { %s };' % ', '.join(str(r[0]) for r in ROWS),
         '\tstatic const int FONT_COLS[] = { %s };' % ', '.join(map(str, font_cols)),
         '\tstatic const int ROW_BOTTOM_PX[] = { %s };' % ', '.join(str(int(row_z[i] + FONTS[ROWS[i][0]][3] * FONTS[ROWS[i][0]][4] + PAD + 0.999)) for i in range(len(ROWS))),
         '\tstatic const int PANEL_H[] = { %s };' % ', '.join(map(str, PANEL_H)),
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
          '\t\tswitch ((row * 4 + fam) * 100 + col)', '\t\t{']
    for label, frames in states:
        ri, fam, col = int(label[1], 16), int(label[2]), int(label[3:])
        z.append('\t\tcase %d: st = d.FindState("%s"); break;' % ((ri * 4 + fam) * 100 + col, label))
    z += ['\t\t}', '\t\treturn Walk(st, idx);', '\t}',
          '\tstatic State Panel(int fam, int hi)', '\t{', '\t\tlet d = GetDefaultByType("RSQGC_SideStates");',
          '\t\tswitch (hi * 4 + fam)', '\t\t{']
    for label, spr in pstates:
        hi, fam = int(label[1]), int(label[2])
        z.append('\t\tcase %d: return d.FindState("%s");' % (hi * 4 + fam, label))
    z += ['\t\t}', '\t\treturn null;', '\t}', '}', '']
    open(os.path.join(ROOT, 'zscript', 'rsqgc', 'side_states.zs'), 'w').write('\n'.join(z))
    print('sprites %d, voxels %d, cells %d, font cols %s, card %d px tall' % (sprite_n[0], len(vdef), count, font_cols, used_h))

if __name__ == '__main__':
    main()
