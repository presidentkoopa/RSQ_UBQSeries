#!/usr/bin/env python3
"""RSQ Gun Cards: build the SMALL CARD voxels (the card beside the wrist stub) from Ermac's Force Unleashed holo art.

    python3 tools/gen_cards.py [--art <folder with ammo_bg*.png, digit_*.png, ammo.png ...>]

Writes into the GunCards folder:  voxels/wk*.kvx, VOXELDEF.txt (between the CARD markers),
sprites/wk/*.png (1x1 placeholders so the sprite names exist), zscript/rsqgc/card_states.zs.

WHY VOXELS. A weapon layer draws as a HUD model at the hand it belongs to; the engine picks the hand by
who owns the layer (models.cpp:221, the off hand when the owner is the off-hand weapon). MODELDEF is keyed
by the OWNER's class, so on the off hand -- owned by whatever gun a weapon pack put there -- only a
VOXELDEF voxel can draw (FindModelFrameRaw falls back to voxels for any class). One method, both hands.

WHERE THINGS GO (rig-measured 2026-10-30, QZD 17.3, hw_openxrdevice.cpp GetHandTransform +
models.cpp RenderHUDModel). Model units are centimetres in the hand's frame (0.01 of the metre frame):
  model Y = depth along the hand, + toward the player; the grip is about Y = -38, the stock top -24.
  model Z = up. model X = sideways, + to the player's LEFT as the gun points away (right hand);
  KVX x itself grows to the player's right, y away from the player, z down, so the pivot that puts a
  piece's centre at (X, Y, Z) is centre + (X, Y, Z) / scale.
The physical LEFT hand is drawn mirrored in X (hw_vrmodes.cpp:467, unless the gun is NoAutoReverse), so
every piece has a mirrored twin (picture flipped, X negated) and the card code picks per hand.
The card can be nudged at run time: the layer's x / y turn the model about its origin (1 unit = 1/4
degree, about 0.11 cm at the card), which is how rsqgc_side / rsqgc_up move it without new voxels.

Ermac's art (the panels): CREDITS.txt. Since 2026-11-03 (owner: "JFO fonts for everything now") every word and digit
is JFO (tools/jfo.py: the AMMO / MAGAZINE / CHAMBER word and RELOAD from its SmallFont, the counts and '+' from its
BigFont digits), at the two Text Qualities (Quest: half-resolution glyphs, PCVR: full), in the same places and sizes
as Ermac's were. Ermac's panels stay. Run again after changing the art or the layout; the output is deterministic.
"""
import argparse, os, struct, sys
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jfo

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)   # the GunCards folder

# ---- the layout, in model centimetres -----------------------------------------------------------
CARD = (-6.6, -16.9, -11.3)   # the small card (owner 03:30): beside the wrist stub, to the right on the main hand
                              # (the engine mirrors the left hand, so there it sits to the left). WRIST = (0.4, -16.9, -11.3), measured from
                              # BD22 VR's hand mesh (fbx_b1_R.md3 wrist ring at md3 (-7.1,-0.4,-1.3), MODELDEF Offset 0 -24 -10); rig-confirmed
                              # (rig, doom2, from behind: centred over BD22 VR's rifle and pistol at X ~ 1)
PANEL_W, PANEL_H, PANEL_S = 48, 48, 0.1          # 4.8 cm square (Ermac's panels are square)
FRONT = 0.20                                      # glyphs stand this far in front of the panel
LABEL_S = 0.045                                   # Ermac's 88x12 labels: 4.0 x 0.54 cm
BIG_S, SMALL_S = 0.13, 0.08                       # 12 px digits: 1.56 cm and 0.96 cm
# slot centres relative to the card centre (X + = player's left, Z + = up)
LABEL_AT = (0.0, 0.0, 1.75)
# CENTRED NUMBERS (owner 2026-11-03 08:20): five slots half a digit apart, so a 1-, 2- or 3-digit count sits in the
# card's middle (slots 2 / 1, 3 / 0, 2, 4); RELOAD keeps its own place (RELOAD_AT)
BIG_AT = [(1.6, 0.0, -0.2), (0.8, 0.0, -0.2), (0.0, 0.0, -0.2), (-0.8, 0.0, -0.2), (-1.6, 0.0, -0.2)]
SMALL_AT = [(0.9, 0.0, -1.85), (0.45, 0.0, -1.85), (0.0, 0.0, -1.85), (-0.45, 0.0, -1.85), (-0.9, 0.0, -1.85)]   # the reserve (or the other gun, on a both-hands card)
LABELS = ['ammo', 'magazine', 'chamber']
LABEL_BOX = (4.0, 0.54)                           # cm: each JFO word fits the box Ermac's word filled
GLYPHS = [str(d) for d in range(10)] + ['plus']   # JFO BigFont 0-9 and '+' (QoL GC2, "+N" on a pickup)
QUALITIES = (True, False)                         # Text Quality 0 Quest (half resolution), 1 PCVR: frames q * n + k
# RELOAD (QoL GC3) in the big number's place on an empty magazine: one word piece, Ermac's lettering (reload.png,
# made below from his own letters), centred where the three big digits are
RELOAD_BOX = (4.5, 0.74)                          # cm, as Ermac's RELOAD (the three big slots span 4.8 cm)
RELOAD_S = 0.062                                  # Ermac's RELOAD: 72 x 12 px, 4.5 x 0.74 cm
# SMALL CARD FONT (owner 2026-11-03 07:58): JFO by default, Ermac's own lettering and digits as the option. Ermac's frames
# follow JFO's in the label (frames 6-8) and RELOAD (frame 2) sprites; his digits have sprites of their own (Q<d>E / F).
ERMAC_GLYPHS = [str(d) for d in range(10)] + ['plus']
RELOAD_AT = (0.0, 0.0, -0.2)
# QoL GC8 (owner, 2026-10-31): the cards take the room's light. A HUD model is lit by the player's sector unless its
# state is Bright (hw_weapon.cpp GetWeaponLighting), so the generated states carry no Bright.
BRIGHT = ''


def extra_art(art):
    """QoL GC2 / GC3: the two pieces Ermac did not draw, made in his style, written into the art folder (deterministic).
    reload.png: R (chamber), E (magazine), L (chamber's C, its top bar cut away), O (ammo), A (magazine), D (chamber's B
    with ammo's O inside: B's square back, O's open middle). Each letter is its 8-px stroke run plus 2 px either side.
    digit_plus.png: a '+' in his digit style: 2-px strokes, light over mid grey, a black outline."""
    T, K = (0, 0, 0, 0), (0, 0, 0, 255)
    def cell(f, x0):
        return Image.open(os.path.join(art, f)).convert('RGBA').crop((x0 - 2, 0, x0 + 10, 12))
    R = cell('chamber.png', 68); E = cell('magazine.png', 78); O = cell('ammo.png', 38); A = cell('magazine.png', 14)
    L = cell('chamber.png', 2)
    for y in range(12):
        for x in range(12):
            if (y <= 3 or 4 <= y <= 7) and x >= 4: L.putpixel((x, y), T)
            if y <= 2 and x == 3: L.putpixel((x, y), K)
    D = cell('chamber.png', 46)
    for y in range(3, 9):
        for x in range(12): D.putpixel((x, y), O.getpixel((x, y)))
    word = Image.new('RGBA', (72, 12), T)
    for i, g in enumerate((R, E, L, O, A, D)): word.alpha_composite(g, (i * 12, 0))
    word.save(os.path.join(art, 'reload.png'))
    rows = ['............', '....aaaa....', '....abca....', '....abca....', 'aaaaabcaaaaa', 'abccccccccba',
            'abbbbbbbbbba', 'aaaaabcaaaaa', '....abca....', '....abca....', '....aaaa....', '............']
    pal = {'a': K, 'b': (127, 127, 127, 255), 'c': (191, 191, 191, 255), '.': T}
    plus = Image.new('RGBA', (12, 12), T)
    for y, r in enumerate(rows):
        for x, ch in enumerate(r): plus.putpixel((x, y), pal[ch])
    plus.save(os.path.join(art, 'digit_plus.png'))


def write_kvx(path, vox, size, pivot, pal):
    """vox[(x, y, z)] = palette index (0..254); KVX z grows DOWN. pivot in voxels (fractional ok)."""
    xs, ys, zs = size
    cols = []
    for x in range(xs):
        row = []
        for y in range(ys):
            zz = sorted(z for (a, b, z) in vox if a == x and b == y)
            data = b''
            i = 0
            while i < len(zz):
                j = i
                while j + 1 < len(zz) and zz[j + 1] == zz[j] + 1: j += 1
                data += bytes([zz[i], j - i + 1, 0x3f]) + bytes(vox[(x, y, zz[k])] for k in range(i, j + 1))
                i = j + 1
            row.append(data)
        cols.append(row)
    base = (xs + 1) * 4 + xs * (ys + 1) * 2
    xoff, xyoff, body = [], [], b''
    for x in range(xs):
        xoff.append(base + len(body))
        o, offs = 0, []
        for y in range(ys):
            offs.append(o); o += len(cols[x][y])
        offs.append(o); xyoff.append(offs)
        body += b''.join(cols[x])
    xoff.append(base + len(body))
    mip = struct.pack('<6i', xs, ys, zs, int(round(pivot[0] * 256)), int(round(pivot[1] * 256)), int(round(pivot[2] * 256)))
    mip += struct.pack('<%di' % (xs + 1), *xoff)
    for offs in xyoff: mip += struct.pack('<%dh' % (ys + 1), *offs)
    mip += body
    p = bytearray(768)
    for i, c in enumerate(pal[:256]):
        p[3 * i:3 * i + 3] = bytes(v >> 2 for v in c)
    with open(path, 'wb') as f:
        f.write(struct.pack('<i', len(mip)) + mip + bytes(p))


def card_piece(png, w, h, scale, local, mirror, out, alpha_cut=60, dy=0.0):
    """A flat piece facing the player (KVX x = across, z = down, one voxel deep in y), at CARD + local.
    The engine mirrors the physical left hand, which also puts the card on that hand's inboard side.
    The mirrored twin flips the picture and the piece's place WITHIN the card, so after the engine's
    mirror it reads left to right again; the card itself stays where the mirror puts it."""
    src = Image.open(png).convert('RGBA')
    im = src.resize((w, h), Image.NEAREST if max(src.size) <= 96 else Image.LANCZOS)
    if mirror: im = im.transpose(Image.FLIP_LEFT_RIGHT)
    q = im.convert('RGB').quantize(255)
    raw = q.getpalette()[:255 * 3]
    pal = [tuple(raw[i:i + 3]) for i in range(0, len(raw), 3)]
    pal += [(0, 0, 0)] * (256 - len(pal))
    vox = {}
    for y in range(h):
        for x in range(w):
            if im.getpixel((x, y))[3] >= alpha_cut:
                # KVX x grows to the player's right (rig: an unmirrored '4' read true this way)
                vox[(x, 0, y)] = q.getpixel((x, y))
    lx, ly, lz = local
    if mirror: lx = -lx
    X, Y, Z = CARD[0] + lx, CARD[1] + ly + dy, CARD[2] + lz
    piv = (w / 2.0 + X / scale, 0.5 + Y / scale, h / 2.0 + Z / scale)
    write_kvx(out, vox, (w, 1, h), piv, pal)
    return len(vox)


def jfo_piece(im, scale, local, mirror, out, dy=0.0, cut=100):
    """card_piece for a JFO image at its own resolution: scale = cm per image pixel, centred at CARD + local"""
    w, h = im.size
    if mirror: im = im.transpose(Image.FLIP_LEFT_RIGHT)
    # 16 colours (the runtime tints JFO by brightness), each an aligned 4 x 4 block of the voxel's 16 x 16 palette texture
    # as on the watch card (gen_side.py block_palette): texture filtering cannot mix a glyph's shades with the padding
    q = im.convert('RGB').quantize(16)
    raw = q.getpalette()[:16 * 3]
    pal = [(0, 0, 0)] * 256
    idx = {}
    for k in range(len(raw) // 3):
        bx, by = k % 4, k // 4
        for yy in range(4):
            for xx in range(4): pal[(by * 4 + yy) * 16 + bx * 4 + xx] = tuple(raw[3 * k:3 * k + 3])
        idx[k] = (by * 4 + 1) * 16 + bx * 4 + 1
    vox = {}
    for y in range(h):
        for x in range(w):
            if im.getpixel((x, y))[3] >= cut: vox[(x, 0, y)] = idx[q.getpixel((x, y))]
    lx, ly, lz = local
    if mirror: lx = -lx
    X, Y, Z = CARD[0] + lx, CARD[1] + ly + dy, CARD[2] + lz
    piv = (w / 2.0 + X / scale, 0.5 + Y / scale, h / 2.0 + Z / scale)
    write_kvx(out, vox, (w, 1, h), piv, pal)
    return len(vox)


def fit(im, box):
    """cm per pixel that fits the image in a (w, h) cm box"""
    return min(box[0] / im.size[0], box[1] / im.size[1])


def add(a, b): return tuple(x + y for x, y in zip(a, b))


# IN AND OUT (owner 2026-10-31: "i want to be able to move the ammo card in and out, in addition to left right and
# up down"). A layer's x / y only turn a model about its origin, so a move along the forearm cannot be done at run
# time: the card is baked at DEPTHS (cm along model Y, + toward the player) and rsqgc_in picks one.
DEPTHS = [-6.0, -4.5, -3.0, -1.5, 0.0, 1.5, 3.0, 4.5, 6.0]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--art', default=os.path.join(HERE, 'card_art'))
    a = ap.parse_args()
    art = a.art
    extra_art(art)   # Ermac-style RELOAD / '+' for the Ermac font option (Small Card Font: Ermac)
    vdir = os.path.join(ROOT, 'voxels'); os.makedirs(vdir, exist_ok=True)
    sdir = os.path.join(ROOT, 'sprites', 'wk'); os.makedirs(sdir, exist_ok=True)
    for f in os.listdir(vdir):
        if f.startswith('wk') and f.endswith('.kvx'): os.remove(os.path.join(vdir, f))
    for f in os.listdir(sdir): os.remove(os.path.join(sdir, f))

    vdef, states, count = [], [], 0
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

    def frame(sprite, fr, lump, scale):
        vdef.append('%s%s = "%s" { Scale = %g }' % (sprite, fr, lump, scale))
        Image.new('RGBA', (1, 1), (0, 0, 0, 0)).save(os.path.join(sdir, '%s%s0.png' % (sprite, fr)))

    import re
    bgs = sorted(int(re.match(r'ammo_bg(\d+)\.png$', f).group(1)) for f in os.listdir(art) if re.match(r'ammo_bg\d+\.png$', f))
    for di, dy in enumerate(DEPTHS):
     dc = str(di)
     for m in (0, 1):
        mc = 'NM'[m]
        # panels: sprite Q<d>P<N|M>, frames A.. = ammo_bg1..19
        spr = 'Q' + dc + 'P' + mc
        line = []
        for s, bg in enumerate(bgs):
            lump = 'wk%sp%s%02d' % (dc, mc.lower(), bg)
            count += card_piece(os.path.join(art, 'ammo_bg%d.png' % bg), PANEL_W, PANEL_H, PANEL_S, (0, 0, 0), m,
                                os.path.join(vdir, lump + '.kvx'), dy=dy)
            frame(spr, letters[s], lump, PANEL_S); line.append(letters[s])
        states.append(('P%s%s' % (mc, dc), spr, line))
        # labels: Q<d>L<N|M>, frames q * 3 + k (JFO words)
        spr = 'Q' + dc + 'L' + mc
        line = []
        for qi, half in enumerate(QUALITIES):
            for k, name in enumerate(LABELS):
                im = jfo.word(name.upper(), half)
                sc = fit(im, LABEL_BOX)
                lump = 'wk%sl%s%d' % (dc, mc.lower(), qi * 3 + k)
                count += jfo_piece(im, sc, add(LABEL_AT, (0, FRONT, 0)), m, os.path.join(vdir, lump + '.kvx'), dy=dy)
                frame(spr, letters[qi * 3 + k], lump, sc); line.append(letters[qi * 3 + k])
        for k, name in enumerate(LABELS):   # Ermac's words, frames 6-8
            lump = 'wk%sl%s%d' % (dc, mc.lower(), 6 + k)
            count += card_piece(os.path.join(art, name + '.png'), 88, 12, LABEL_S,
                                add(LABEL_AT, (0, FRONT, 0)), m, os.path.join(vdir, lump + '.kvx'), dy=dy)
            frame(spr, letters[6 + k], lump, LABEL_S); line.append(letters[6 + k])
        states.append(('L%s%s' % (mc, dc), spr, line))
        # RELOAD (GC3): Q<d>R<N|M>, frame A Quest, B PCVR
        spr = 'Q' + dc + 'R' + mc
        line = []
        for qi, half in enumerate(QUALITIES):
            im = jfo.word('RELOAD', half)
            sc = fit(im, RELOAD_BOX)
            lump = 'wk%sr%s%d' % (dc, mc.lower(), qi)
            count += jfo_piece(im, sc, add(RELOAD_AT, (0, FRONT, 0)), m, os.path.join(vdir, lump + '.kvx'), dy=dy)
            frame(spr, letters[qi], lump, sc); line.append(letters[qi])
        lump = 'wk%sr%s2' % (dc, mc.lower())   # Ermac's RELOAD, frame C
        count += card_piece(os.path.join(art, 'reload.png'), 72, 12, RELOAD_S, add(RELOAD_AT, (0, FRONT, 0)), m,
                            os.path.join(vdir, lump + '.kvx'), dy=dy)
        frame(spr, 'C', lump, RELOAD_S); line.append('C')
        states.append(('R%s%s' % (mc, dc), spr, line))
        # Ermac's digits: Q<d><E|F><0..9> (E big, F small; mirror * 5 + slot), frames 0-9, '+'
        for kind, slots, scale in (('E', BIG_AT, BIG_S), ('F', SMALL_AT, SMALL_S)):
            for si, sat in enumerate(slots):
                spr = 'Q%s%s%d' % (dc, kind, m * 5 + si)
                line = []
                for gi, g in enumerate(ERMAC_GLYPHS):
                    lump = 'wk%s%s%s%d%s' % (dc, kind.lower(), mc.lower(), si, g if len(g) == 1 else 'p')
                    count += card_piece(os.path.join(art, 'digit_%s.png' % g), 12, 12, scale,
                                        add(sat, (0, FRONT, 0)), m, os.path.join(vdir, lump + '.kvx'), dy=dy)
                    frame(spr, letters[gi], lump, scale); line.append(letters[gi])
                states.append(('%s%s%d%s' % (kind, mc, si, dc), spr, line))
        # digits: Q<d><B|S><0..9> (mirror * 5 + slot), frames q * 11 + glyph (JFO BigFont)
        for kind, slots, hcm in (('B', BIG_AT, BIG_S * 12), ('S', SMALL_AT, SMALL_S * 12)):
            for si, sat in enumerate(slots):
                spr = 'Q%s%s%d' % (dc, kind, m * 5 + si)
                line = []
                for qi, half in enumerate(QUALITIES):
                    for gi, g in enumerate(GLYPHS):
                        im = jfo.glyph('big', 43 if g == 'plus' else ord(g), half)[0]
                        sc = hcm / im.size[1]
                        k = qi * len(GLYPHS) + gi
                        lump = 'wk%s%s%s%d%s' % (dc, kind.lower(), mc.lower(), si, ('%x' % k) if k < 16 else chr(ord('g') + k - 16))   # 8 chars at most
                        count += jfo_piece(im, sc, add(sat, (0, FRONT, 0)), m, os.path.join(vdir, lump + '.kvx'), dy=dy)
                        frame(spr, letters[k], lump, sc); line.append(letters[k])
                states.append(('%s%s%d%s' % (kind, mc, si, dc), spr, line))

    # VOXELDEF block
    vpath = os.path.join(ROOT, 'VOXELDEF.txt')
    old = open(vpath).read() if os.path.exists(vpath) else ''
    a0, a1 = '// >>> CARD (tools/gen_cards.py)', '// <<< CARD'
    if a0 in old:
        pre, rest = old.split(a0, 1); post = rest.split(a1, 1)[1]
    else:
        pre, post = old, ''
    with open(vpath, 'w') as f:
        f.write(pre.rstrip('\n') + ('\n\n' if pre.strip() else '') + a0 + '\n' + '\n'.join(vdef) + '\n' + a1 + post.rstrip('\n') + '\n')

    # ZScript: the states, one label per piece, frames in order (the card walks NextState)
    z = ['// GENERATED by tools/gen_cards.py -- do not edit. The on-gun card pieces (RSQ Gun Cards).',
         '// On a Weapon class so a layer owned by the off-hand gun accepts them (p_pspr.cpp:544-551).',
         'class RSQGC_CardStates : Weapon',
         '{',
         '\tDefault { +WEAPON.CHEATNOTWEAPON +WEAPON.NOAUTOSWITCHTO Weapon.SelectionOrder 99999; }',
         '\tconst STYLES = %d;   // Ermac ammo_bg %s, in that order' % (len(bgs), ' '.join(map(str, bgs))),
         '\tconst LABELS = %d;' % len(LABELS),
         '\tconst GLYPHS = %d;   // 0-9, then + (GLYPH_PLUS); frame q * GLYPHS + glyph (q: Text Quality)' % len(GLYPHS),
         '\tconst GLYPH_PLUS = %d;' % GLYPHS.index('plus'),
         '\tconst SLOTS = %d;' % len(BIG_AT),
         '\tStates', '\t{']
    for label, spr, frames in states:
        z.append('\t%s:' % label)
        for fr in frames: z.append('\t\t%s %s -1%s;' % (spr, fr, BRIGHT))
        z.append('\t\tStop;')
    z += ['\t}', '',
          '\t// The first state of a piece. kind 0 panel, 1 label (JFO q * 3 + word, Ermac 6 + word), 2 big digit, 3 small digit',
          '\t// (JFO, q * GLYPHS + glyph), 4 RELOAD (JFO q, Ermac 2), 5 / 6 Ermac big / small digit; slot for digits.',
          '\tconst ERMAC_LABEL = 6;',
          '\tconst ERMAC_RELOAD = 2;',
          '\t// (FindState wants a constant label, hence the table.)',
          '\t// depth: which of the baked DEPTHS (rsqgc_in), 0..%d, %d is where the owner placed it.' % (len(DEPTHS) - 1, DEPTHS.index(0.0)),
          '\tconst DEPTHS = %d;' % len(DEPTHS),
          '\tconst DEPTH_STEP = %g;   // cm between them' % (DEPTHS[1] - DEPTHS[0]),
          '\tstatic State Piece(int kind, bool mirrored, int slot = 0, int depth = %d)' % DEPTHS.index(0.0),
          '\t{',
          '\t\tlet d = GetDefaultByType("RSQGC_CardStates");',
          '\t\tint k = depth * 1000 + kind * 100 + (mirrored ? 10 : 0) + slot;',
          '\t\tswitch (k)', '\t\t{']
    for label, spr, frames in states:
        kind = {'P': 0, 'L': 1, 'B': 2, 'S': 3, 'R': 4, 'E': 5, 'F': 6}[label[0]]
        mir = 1 if label[1] == 'M' else 0
        dep = int(label[-1])
        slot = int(label[2:-1]) if len(label) > 3 else 0
        z.append('\t\tcase %d: return d.FindState("%s");' % (dep * 1000 + kind * 100 + mir * 10 + slot, label))
    z += ['\t\t}', '\t\treturn null;', '\t}', '}', '']
    with open(os.path.join(ROOT, 'zscript', 'rsqgc', 'card_states.zs'), 'w') as f:
        f.write('\n'.join(z))
    print('voxels %d, frames %d, voxel cells %d' % (len(vdef), len(vdef), count))


if __name__ == '__main__':
    main()
